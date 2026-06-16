## DataLoader Integration in Fastify GraphQL

### What is DataLoader

DataLoader is a utility library originally created by Facebook (now Meta) for batching and caching data-fetching operations in GraphQL servers. It addresses the **N+1 query problem**, a common performance issue where resolving a list of N items triggers N additional database queries for related data.

In a Fastify + GraphQL setup, DataLoader instances are typically created per-request and attached to the GraphQL context so all resolvers share them.

**Key Points**

- DataLoader batches multiple individual `.load(key)` calls made within the same event loop tick into a single batch function call
- It also caches results per-request by default, so loading the same key twice only fetches once
- DataLoader is framework-agnostic; Fastify integration is done manually via context injection

---

### Installing DataLoader

bash

```bash
npm install dataloader
```

DataLoader has no peer dependencies and works with any async data source (PostgreSQL, MongoDB, REST APIs, etc.).

---

### The N+1 Problem Illustrated

Consider a GraphQL query that fetches posts and their authors:

graphql

```graphql
query {
  posts {
    id
    title
    author {
      name
    }
  }
}
```

Without DataLoader, the resolver chain executes:

1. One query: `SELECT * FROM posts` → returns 100 posts
2. 100 queries: `SELECT * FROM users WHERE id = ?` — one per post

This results in **101 queries** for a single GraphQL request.

---

### Basic DataLoader Construction

A DataLoader requires a **batch function**: an async function that receives an array of keys and returns a matching array of values (same order, same length).

js

```js
import DataLoader from 'dataloader'

// batchKeys: array of user IDs collected during one tick
async function batchLoadUsers(batchKeys) {
  const users = await db.query(
    'SELECT * FROM users WHERE id = ANY($1)',
    [batchKeys]
  )

  // Must return results in the same order as batchKeys
  const userMap = new Map(users.map(u => [u.id, u]))
  return batchKeys.map(id => userMap.get(id) ?? new Error(`User ${id} not found`))
}

const userLoader = new DataLoader(batchLoadUsers)
```

**Key Points**

- The batch function receives `batchKeys` as a plain array — never a Set
- The return array **must** be the same length as `batchKeys` and in the same order
- Return an `Error` instance at a position to signal a per-key failure without rejecting the whole batch
- If ordering cannot be guaranteed (e.g., SQL `IN` clause), you must manually reorder results

---

### Per-Request DataLoader Instances

DataLoader's default cache is per-instance. To avoid leaking data between users, **create a new DataLoader instance for every request** — not once at startup.

In Fastify with `mercurius`:

js

```js
import Fastify from 'fastify'
import mercurius from 'mercurius'
import DataLoader from 'dataloader'
import { schema } from './schema.js'
import { resolvers } from './resolvers.js'
import { db } from './db.js'

const app = Fastify()

async function batchLoadUsers(ids) {
  const users = await db.query('SELECT * FROM users WHERE id = ANY($1)', [ids])
  const map = new Map(users.rows.map(u => [String(u.id), u]))
  return ids.map(id => map.get(String(id)) ?? new Error(`Not found: ${id}`))
}

app.register(mercurius, {
  schema,
  resolvers,
  context: (request, reply) => {
    // Called once per request — new loaders every time
    return {
      db,
      loaders: {
        user: new DataLoader(batchLoadUsers),
      }
    }
  }
})

await app.listen({ port: 3000 })
```

**Key Points**

- `context` in mercurius is a function (not an object) so it executes per request
- Attach all loaders under a namespaced key (e.g., `loaders`) to keep context organized
- The `db` connection pool is shared; only the DataLoader instances are per-request

---

### Using DataLoader in Resolvers

js

```js
// resolvers.js
export const resolvers = {
  Query: {
    posts: async (_, __, { db }) => {
      const result = await db.query('SELECT * FROM posts')
      return result.rows
    }
  },
  Post: {
    // This resolver is called once per post — DataLoader batches all calls
    author: async (post, _, { loaders }) => {
      return loaders.user.load(String(post.author_id))
    }
  }
}
```

**What happens at runtime:**

1. `Query.posts` returns 100 posts
2. GraphQL calls `Post.author` 100 times — one per post
3. Each call invokes `loaders.user.load(id)` — but does not immediately fetch
4. After the current tick, DataLoader collects all 100 IDs and calls `batchLoadUsers` once
5. One SQL query runs: `SELECT * FROM users WHERE id = ANY($1)` with 100 IDs

**Result: 2 total queries instead of 101.**

---

### Loader Factory Pattern

For larger applications with many entity types, define a factory function that constructs all loaders for a request:

js

```js
// loaders.js
import DataLoader from 'dataloader'

export function createLoaders(db) {
  return {
    user: new DataLoader(async (ids) => {
      const { rows } = await db.query(
        'SELECT * FROM users WHERE id = ANY($1)', [ids]
      )
      const map = new Map(rows.map(r => [String(r.id), r]))
      return ids.map(id => map.get(id) ?? new Error(`User ${id} not found`))
    }),

    post: new DataLoader(async (ids) => {
      const { rows } = await db.query(
        'SELECT * FROM posts WHERE id = ANY($1)', [ids]
      )
      const map = new Map(rows.map(r => [String(r.id), r]))
      return ids.map(id => map.get(id) ?? new Error(`Post ${id} not found`))
    }),

    postsByAuthor: new DataLoader(async (authorIds) => {
      const { rows } = await db.query(
        'SELECT * FROM posts WHERE author_id = ANY($1)', [authorIds]
      )
      // Group posts by author_id — one-to-many relationship
      const grouped = new Map()
      for (const row of rows) {
        const key = String(row.author_id)
        if (!grouped.has(key)) grouped.set(key, [])
        grouped.get(key).push(row)
      }
      return authorIds.map(id => grouped.get(String(id)) ?? [])
    }),
  }
}
```

js

```js
// In Fastify registration
context: (request, reply) => ({
  db,
  loaders: createLoaders(db)
})
```

**Key Points**

- One-to-many loaders (e.g., `postsByAuthor`) return arrays per key, not single values
- Missing keys in one-to-many should return `[]`, not an `Error`, unless absence is genuinely erroneous
- Factory functions make testing loaders in isolation straightforward

---

### DataLoader with Mercurius Loader API

Mercurius has a built-in loader concept that mirrors DataLoader semantics but integrates more tightly with the schema:

js

```js
import mercurius from 'mercurius'

app.register(mercurius, {
  schema,
  resolvers: {
    Query: {
      posts: async () => db.query('SELECT * FROM posts').then(r => r.rows)
    }
  },
  loaders: {
    Post: {
      async author(queries, context) {
        // queries: array of { obj: post, params: {} }
        const ids = queries.map(q => q.obj.author_id)
        const { rows } = await context.db.query(
          'SELECT * FROM users WHERE id = ANY($1)', [ids]
        )
        const map = new Map(rows.map(u => [String(u.id), u]))
        return ids.map(id => map.get(String(id)))
      }
    }
  },
  context: (req, reply) => ({ db })
})
```

**Key Points**

- Mercurius `loaders` is a separate top-level option from `resolvers`
- Each loader function receives `queries` — an array of `{ obj, params }` — and the shared context
- This is mercurius-specific and not portable to other GraphQL servers
- [Inference] Mercurius loaders likely behave similarly to DataLoader batching under the hood, but the exact implementation differs; behavior may vary

---

### Caching Behavior and Cache Invalidation

DataLoader's default in-memory cache is a `Map` keyed by the values passed to `.load()`.

js

```js
const loader = new DataLoader(batchFn)

await loader.load('1') // fetches
await loader.load('1') // returns from cache — no fetch
```

**Disabling the cache** (when data can mutate during a request):

js

```js
const loader = new DataLoader(batchFn, { cache: false })
```

**Manual cache clearing:**

js

```js
loader.clear('1')        // remove one key
loader.clearAll()        // remove all cached values
loader.prime('1', value) // pre-populate cache without fetching
```

**Key Points**

- Cache is per-instance, so per-request by design — there is no cross-request caching by default
- `prime()` is useful when you already have data from a prior query (e.g., a list fetch) and want to pre-fill the cache to avoid redundant individual loads
- [Inference] Disabling the cache may be appropriate when mutations occur mid-request and staleness is a concern; actual behavior depends on execution order

---

### Priming the Cache After List Queries

A common optimization: when fetching a list, prime the loader cache with individual items so subsequent `.load(id)` calls hit cache:

js

```js
export const resolvers = {
  Query: {
    posts: async (_, __, { db, loaders }) => {
      const { rows } = await db.query('SELECT * FROM posts')

      // Prime the post loader with fetched data
      for (const post of rows) {
        loaders.post.prime(String(post.id), post)
      }

      return rows
    }
  },
  Post: {
    // If this resolver is called, the cache is already warm — no extra fetch
    self: async (post, _, { loaders }) => loaders.post.load(String(post.id))
  }
}
```

This is particularly useful in paginated queries or when child resolvers request the same entities already fetched by a parent.

---

### Key Ordering and Type Safety

A frequent source of bugs is mismatched key types. SQL returns numeric IDs; JavaScript may pass string IDs.

js

```js
// Dangerous: key type mismatch
loader.load(1)    // number
loader.load('1')  // string — treated as different keys by DataLoader

// Safe: normalize all keys to strings before passing to .load()
loader.load(String(post.author_id))
```

In the batch function, also normalize incoming keys:

js

```js
async function batchFn(ids) {
  // ids may be strings — ensure SQL receives correct types
  const numericIds = ids.map(Number)
  const { rows } = await db.query(
    'SELECT * FROM users WHERE id = ANY($1)', [numericIds]
  )
  const map = new Map(rows.map(r => [String(r.id), r]))
  return ids.map(id => map.get(String(id)) ?? new Error(`Not found: ${id}`))
}
```

---

### Batching Configuration Options

js

```js
const loader = new DataLoader(batchFn, {
  // Maximum keys per batch call (default: unlimited)
  maxBatchSize: 100,

  // Disable batching entirely (each load is immediate)
  batch: false,

  // Custom cache key function (useful for object keys)
  cacheKeyFn: (key) => JSON.stringify(key),

  // Custom cache map (e.g., LRU cache for cross-request caching)
  cacheMap: new LRUCache({ max: 500 })
})
```

**Key Points**

- `maxBatchSize` prevents oversized `IN` clauses in SQL, which some databases limit
- `cacheKeyFn` is required if keys are objects, since object identity (`===`) is used by default
- Passing a custom `cacheMap` that outlives the request introduces cross-request caching — use with caution and explicit invalidation strategy

---

### Error Handling in Batch Functions

js

```js
async function batchLoadUsers(ids) {
  try {
    const { rows } = await db.query(
      'SELECT * FROM users WHERE id = ANY($1)', [ids]
    )
    const map = new Map(rows.map(r => [String(r.id), r]))
    return ids.map(id => {
      const user = map.get(String(id))
      // Per-key error: resolver receives a rejected promise for this key
      return user ?? new Error(`User not found: ${id}`)
    })
  } catch (err) {
    // Batch-level error: all keys in this batch fail
    return ids.map(() => err)
  }
}
```

**Key Points**

- Returning an `Error` instance at a position causes `.load(key)` to reject for that key only
- Throwing from the batch function (or returning a rejected promise) fails **all** keys in the batch
- Resolvers should handle errors from `.load()` via `try/catch` or `.catch()` — unhandled rejections surface as GraphQL field errors

---

### Testing DataLoader in Isolation

js

```js
import DataLoader from 'dataloader'
import { describe, it, expect, vi } from 'vitest'

describe('userLoader', () => {
  it('batches multiple loads into one call', async () => {
    const batchFn = vi.fn(async (ids) =>
      ids.map(id => ({ id, name: `User ${id}` }))
    )

    const loader = new DataLoader(batchFn)

    // Both loads happen in the same tick — batched into one call
    const [u1, u2] = await Promise.all([
      loader.load('1'),
      loader.load('2')
    ])

    expect(batchFn).toHaveBeenCalledTimes(1)
    expect(batchFn).toHaveBeenCalledWith(['1', '2'])
    expect(u1.name).toBe('User 1')
    expect(u2.name).toBe('User 2')
  })

  it('caches repeated loads', async () => {
    const batchFn = vi.fn(async (ids) =>
      ids.map(id => ({ id, name: `User ${id}` }))
    )

    const loader = new DataLoader(batchFn)

    await loader.load('1')
    await loader.load('1') // cache hit

    expect(batchFn).toHaveBeenCalledTimes(1)
  })
})
```

---

### Common Pitfalls

**1. Creating loaders outside the request context (singleton antipattern)**

js

```js
// WRONG — shared loader leaks cache across requests and users
const userLoader = new DataLoader(batchFn) // module-level

app.register(mercurius, {
  context: () => ({ loaders: { user: userLoader } }) // same instance every request
})
```

js

```js
// CORRECT — new instance per request
context: (req) => ({ loaders: { user: new DataLoader(batchFn) } })
```

**2. Returning results in wrong order**

js

```js
// WRONG — returning rows directly without reordering
async function batchFn(ids) {
  const rows = await db.query('SELECT * FROM users WHERE id = ANY($1)', [ids])
  return rows.rows // order matches DB output, not ids array
}

// CORRECT — map results back to id order
return ids.map(id => map.get(String(id)) ?? new Error(`Not found: ${id}`))
```

**3. Forgetting to handle missing keys**

If an ID does not exist in the database, the map lookup returns `undefined`. Returning `undefined` at a position is not the same as returning an `Error` — DataLoader may behave unexpectedly. Always return either a value or an `Error` instance.

---

### Diagram: DataLoader Batching Flow

DatabaseDataLoaderResolver (PostResolver (PostGraphQL ExecutorDatabaseDataLoaderResolver (PostResolver (PostGraphQL ExecutorEnd of tick — batch collectedresolve author (id=10)resolve author (id=20).load("10").load("20")SELECT \* FROM users WHERE id = ANY([10, 20])[user10, user20]user10user20

---

**Related Topics**

- DataLoader with Redis for cross-request caching
- Batching REST API calls with DataLoader (non-database sources)
- Mercurius loaders vs. manual DataLoader: performance comparison
- DataLoader with TypeScript generics for type-safe keys and values
- GraphQL subscriptions and DataLoader (when batching does not apply)
- Persisted queries and DataLoader cache warming strategies
- Monitoring DataLoader batch sizes with Fastify hooks and logging