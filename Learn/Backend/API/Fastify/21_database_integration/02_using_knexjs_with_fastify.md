## Using Knex.js with Fastify

Knex.js is a SQL query builder for Node.js that supports PostgreSQL, MySQL, SQLite3, and several other databases. It sits between raw `pg`/`mysql2` drivers and full ORMs — providing a composable, chainable JavaScript API for constructing queries while keeping you close to SQL semantics. In Fastify, Knex is integrated as a plugin-decorated instance rather than through an official scoped plugin.

---

### What Knex Provides

| Feature | Description |
| --- | --- |
| Query builder | Chainable API for `SELECT`, `INSERT`, `UPDATE`, `DELETE` |
| Schema builder | Create, alter, and drop tables programmatically |
| Migrations | Version-controlled schema changes via CLI and API |
| Seeds | Populate tables with initial or test data |
| Transaction API | Managed transactions with commit/rollback |
| Connection pooling | Built on `tarn.js`; configurable pool size and lifecycle |
| Multi-dialect | Single API across PostgreSQL, MySQL, SQLite3, MSSQL, Oracle |

Knex does not provide an entity model, relations, or an ORM abstraction. It produces and executes SQL — nothing more. [Inference: based on Knex documentation; feature set may evolve across versions]

---

### Installation

bash

```bash
npm install knex pg
```

For other databases, substitute the appropriate driver:

bash

```bash
npm install knex mysql2       # MySQL / MariaDB
npm install knex better-sqlite3  # SQLite3
```

TypeScript types are included in the `knex` package as of recent versions — no separate `@types/knex` is required. [Unverified: verify against your installed Knex version]

---

### Knex Initialization

Knex is initialized by calling the `knex()` factory with a configuration object. This creates a configured instance with an internal connection pool.

typescript

```typescript
// db/knex.ts
import knexLib from 'knex'

const knex = knexLib({
  client: 'pg',
  connection: {
    connectionString: process.env.DATABASE_URL,
    ssl: process.env.NODE_ENV === 'production'
      ? { rejectUnauthorized: false }
      : false
  },
  pool: {
    min: 2,
    max: 10
  },
  acquireConnectionTimeout: 10_000
})

export default knex
```

**Key Points:**

- The `client` field specifies the dialect — `'pg'`, `'mysql2'`, `'sqlite3'`, etc.
- `connection` accepts either a connection string or a connection object
- `pool.min` and `pool.max` control the `tarn.js` pool; defaults are `min: 2`, `max: 10` [Unverified: verify defaults against your Knex version]
- `acquireConnectionTimeout` sets how long Knex waits for a connection before throwing — prevents indefinite hangs under pool exhaustion

---

### Integrating Knex as a Fastify Plugin

There is no official `@fastify/knex` scoped plugin. The standard pattern is to wrap Knex in a custom plugin using `fastify-plugin` and decorate the Fastify instance.

typescript

```typescript
// plugins/knex.ts
import fp from 'fastify-plugin'
import knexLib, { Knex } from 'knex'
import type { FastifyPluginAsync } from 'fastify'

declare module 'fastify' {
  interface FastifyInstance {
    knex: Knex
  }
}

const knexPlugin: FastifyPluginAsync = async (fastify) => {
  const knex = knexLib({
    client: 'pg',
    connection: process.env.DATABASE_URL,
    pool: { min: 2, max: 10 }
  })

  // Verify connectivity on startup
  await knex.raw('SELECT 1')

  fastify.decorate('knex', knex)

  fastify.addHook('onClose', async () => {
    await knex.destroy()
  })
}

export default fp(knexPlugin)
```

**Registration in the main application:**

typescript

```typescript
// app.ts
import Fastify from 'fastify'
import knexPlugin from './plugins/knex'

const fastify = Fastify({ logger: true })

await fastify.register(knexPlugin)
await fastify.listen({ port: 3000 })
```

**Key Points:**

- `fp()` (fastify-plugin) breaks encapsulation so `fastify.knex` is available across all scopes
- `knex.raw('SELECT 1')` on startup fails fast if the database is unreachable — prevents the application from starting in a broken state [Inference: behavior depends on network conditions and timeout configuration]
- `onClose` hook calls `knex.destroy()` which drains the connection pool on shutdown
- The `declare module 'fastify'` block augments TypeScript's `FastifyInstance` type so `fastify.knex` resolves correctly across the codebase

---

### Basic Query Operations

#### SELECT

typescript

```typescript
fastify.get('/users', async () => {
  return fastify.knex('users').select('id', 'name', 'email')
})

// With WHERE
fastify.get('/users/:id', async (request, reply) => {
  const { id } = request.params as { id: string }

  const user = await fastify.knex('users')
    .select('id', 'name', 'email')
    .where({ id })
    .first()

  if (!user) return reply.code(404).send({ error: 'Not found' })
  return user
})
```

**Key Points:**

- `.first()` returns a single row object or `undefined` — it appends `LIMIT 1` to the query
- `.select()` without arguments returns all columns (`SELECT *`)
- Knex parameterizes all values automatically — the `.where({ id })` shorthand is safe [Inference: based on Knex documentation; always verify parameterization is applied when using raw expressions]

#### INSERT

typescript

```typescript
fastify.post('/users', async (request, reply) => {
  const { name, email } = request.body as { name: string; email: string }

  const [user] = await fastify.knex('users')
    .insert({ name, email })
    .returning(['id', 'name', 'email', 'created_at'])

  return reply.code(201).send(user)
})
```

**Key Points:**

- `.returning()` is PostgreSQL-specific — it returns the inserted row(s) without a separate `SELECT`
- For MySQL/SQLite, `.returning()` is not supported; use `.insert()` and read `result[0]` as the inserted ID, then query separately [Inference: based on Knex dialect documentation]
- The result of `.insert().returning()` is an array — destructure or index accordingly

#### UPDATE

typescript

```typescript
fastify.put('/users/:id', async (request, reply) => {
  const { id } = request.params as { id: string }
  const { name, email } = request.body as { name: string; email: string }

  const [updated] = await fastify.knex('users')
    .where({ id })
    .update({ name, email, updated_at: fastify.knex.fn.now() })
    .returning(['id', 'name', 'email', 'updated_at'])

  if (!updated) return reply.code(404).send({ error: 'Not found' })
  return updated
})
```

**Key Points:**

- `knex.fn.now()` produces the SQL `CURRENT_TIMESTAMP` function call — it does not pass a JavaScript `Date` object as a parameter [Inference: based on Knex documentation]
- `.where()` must be present on UPDATE — omitting it updates all rows in the table

#### DELETE

typescript

```typescript
fastify.delete('/users/:id', async (request, reply) => {
  const { id } = request.params as { id: string }

  const count = await fastify.knex('users').where({ id }).delete()

  if (count === 0) return reply.code(404).send({ error: 'Not found' })
  return reply.code(204).send()
})
```

**Key Points:**

- `.delete()` returns the number of rows deleted
- A count of `0` indicates the target row did not exist

---

### Query Builder Composition

Knex queries are chainable and composable — partial queries can be built and extended conditionally.

typescript

```typescript
fastify.get('/users', async (request) => {
  const { name, email, page = '1', limit = '20' } = request.query as {
    name?: string
    email?: string
    page?: string
    limit?: string
  }

  const pageNum = Math.max(1, parseInt(page, 10))
  const limitNum = Math.min(100, parseInt(limit, 10))
  const offset = (pageNum - 1) * limitNum

  let query = fastify.knex('users').select('id', 'name', 'email')

  if (name) query = query.where('name', 'ilike', `%${name}%`)
  if (email) query = query.where({ email })

  const users = await query
    .orderBy('created_at', 'desc')
    .limit(limitNum)
    .offset(offset)

  return users
})
```

**Key Points:**

- Knex queries are lazy — no SQL is executed until `.then()` is called (i.e., when the query is `await`ed)
- Reassigning to `query` is safe — each chained method returns a new query builder instance [Inference: based on Knex's immutable-builder design; verify if this applies to all methods in your version]
- `'ilike'` is PostgreSQL-specific (case-insensitive LIKE); use `'like'` for MySQL/SQLite

---

### Transactions

Knex provides two transaction APIs: callback-based and promise-based.

#### Callback-Based (Recommended)

typescript

```typescript
fastify.post('/transfer', async (request, reply) => {
  const { fromId, toId, amount } = request.body as {
    fromId: number
    toId: number
    amount: number
  }

  await fastify.knex.transaction(async (trx) => {
    await trx('accounts')
      .where({ id: fromId })
      .decrement('balance', amount)

    await trx('accounts')
      .where({ id: toId })
      .increment('balance', amount)

    await trx('transaction_log').insert({
      from_id: fromId,
      to_id: toId,
      amount,
      created_at: trx.fn.now()
    })
  })

  return { success: true }
})
```

**Key Points:**

- If any query inside the callback throws, Knex automatically calls `ROLLBACK` and re-throws the error
- If the callback resolves without error, Knex calls `COMMIT`
- All queries inside the transaction must use `trx` — not the top-level `fastify.knex` — to participate in the transaction
- `trx` has the same query builder API as `knex`

#### Promise-Based (Manual Control)

typescript

```typescript
const trx = await fastify.knex.transaction()
try {
  await trx('accounts').where({ id: fromId }).decrement('balance', amount)
  await trx('accounts').where({ id: toId }).increment('balance', amount)
  await trx.commit()
} catch (err) {
  await trx.rollback()
  throw err
}
```

**Key Points:**

- Manual transactions require explicit `commit()` and `rollback()` calls
- The callback-based form is generally preferred — it removes the possibility of forgetting to commit or rollback [Inference]

---

### Mermaid: Query Builder to SQL Flow

knex table.select / .where / .orderByQuery Builder Objectawait / .thenSQL string generatedParameterized valuesextractedpg driver executes queryResult rows returned

---

### Schema Builder

Knex can create and modify database tables programmatically. This is most commonly used within migration files rather than application routes.

typescript

```typescript
// Create a table
await fastify.knex.schema.createTable('users', (table) => {
  table.increments('id').primary()
  table.string('name', 255).notNullable()
  table.string('email', 255).notNullable().unique()
  table.string('password_hash', 255).notNullable()
  table.timestamps(true, true)  // created_at, updated_at with defaults
})

// Add a column
await fastify.knex.schema.alterTable('users', (table) => {
  table.string('phone', 50).nullable()
})

// Drop a table
await fastify.knex.schema.dropTableIfExists('users')
```

**Key Points:**

- `.timestamps(true, true)` creates `created_at` and `updated_at` columns with `DEFAULT CURRENT_TIMESTAMP` [Inference: behavior and SQL emitted differ by dialect]
- Schema builder operations are DDL — they execute immediately when awaited and cannot be easily rolled back in PostgreSQL [Inference]
- Schema changes in application startup code are fragile in production; use the migrations CLI instead

---

### Migrations

Knex has a built-in migration system. Migrations are JavaScript/TypeScript files with `up` and `down` functions representing forward and rollback operations.

**`knexfile.ts` — configuration for the CLI:**

typescript

```typescript
import type { Knex } from 'knex'

const config: { [key: string]: Knex.Config } = {
  development: {
    client: 'pg',
    connection: process.env.DATABASE_URL,
    migrations: {
      directory: './migrations',
      extension: 'ts'
    },
    seeds: {
      directory: './seeds'
    }
  },
  production: {
    client: 'pg',
    connection: process.env.DATABASE_URL,
    pool: { min: 2, max: 20 },
    migrations: {
      directory: './migrations',
      extension: 'ts'
    }
  }
}

export default config
```

**A migration file:**

typescript

```typescript
// migrations/20240601000000_create_users.ts
import type { Knex } from 'knex'

export async function up(knex: Knex): Promise<void> {
  await knex.schema.createTable('users', (table) => {
    table.increments('id').primary()
    table.string('name', 255).notNullable()
    table.string('email', 255).notNullable().unique()
    table.timestamp('created_at').defaultTo(knex.fn.now())
    table.timestamp('updated_at').defaultTo(knex.fn.now())
  })
}

export async function down(knex: Knex): Promise<void> {
  await knex.schema.dropTableIfExists('users')
}
```

**Running migrations:**

bash

```bash
npx knex migrate:latest       # Run all pending migrations
npx knex migrate:rollback     # Roll back the last batch
npx knex migrate:status       # Show migration status
npx knex migrate:make create_users  # Generate a new migration file
```

**Key Points:**

- Knex tracks applied migrations in a `knex_migrations` table it creates automatically
- `migrate:latest` is idempotent — it only runs migrations not yet applied
- The `down` function should precisely reverse the `up` function — incomplete reversals cause inconsistent schema state
- Running `migrate:latest` on application startup is a common pattern in development but carries risk in production under concurrent deployments [Inference]

---

### Seeds

Seeds populate the database with initial or fixture data.

typescript

```typescript
// seeds/users.ts
import type { Knex } from 'knex'

export async function seed(knex: Knex): Promise<void> {
  await knex('users').del()

  await knex('users').insert([
    { name: 'Alice', email: 'alice@example.com' },
    { name: 'Bob',   email: 'bob@example.com' }
  ])
}
```

bash

```bash
npx knex seed:run              # Run all seed files
npx knex seed:make users       # Generate a new seed file
```

**Key Points:**

- Seeds are not tracked like migrations — running `seed:run` multiple times re-runs all seed files
- Seeds should only be used for development/test environments; running them in production truncates real data [Inference]

---

### Raw Queries

When the query builder is insufficient, Knex provides `knex.raw()` for direct SQL execution with parameterization.

typescript

```typescript
// Parameterized raw query
const result = await fastify.knex.raw(
  'SELECT * FROM users WHERE email = ? AND active = ?',
  [email, true]
)

const users = result.rows  // pg returns rows on result.rows
```

**PostgreSQL-style binding:**

typescript

```typescript
const result = await fastify.knex.raw(
  'SELECT * FROM users WHERE id = :id',
  { id: 42 }
)
```

**Key Points:**

- `?` bindings are used for MySQL; `?` also works with `pg` via Knex's abstraction layer [Unverified: verify binding syntax behavior across dialects in your Knex version]
- Named bindings (`:id`) are supported as an alternative
- `knex.raw()` bypasses the query builder — SQL injection is possible if values are interpolated directly rather than passed as bindings. Always use the bindings parameter

---

### TypeScript Generics with Knex

Knex supports table-level TypeScript generics for typed query results:

typescript

```typescript
interface User {
  id: number
  name: string
  email: string
  created_at: Date
  updated_at: Date
}

// Typed SELECT
const users = await fastify.knex<User>('users')
  .select('id', 'name', 'email')
  .where({ active: true })
// users: Partial<User>[] — column selection narrows the type

// Typed INSERT with returning
const [user] = await fastify.knex<User>('users')
  .insert({ name: 'Alice', email: 'alice@example.com' })
  .returning('*')
// user: User
```

**[Inference]:** Knex's TypeScript generics are a best-effort type layer — they do not validate at runtime that the database columns match the declared interface. Type mismatches between the interface and the actual schema surface as runtime bugs, not compile errors. Column selection narrowing behavior depends on Knex version.

---

### Knex vs Raw `pg` in Fastify

| Concern | Raw `pg` | Knex |
| --- | --- | --- |
| Query construction | Raw SQL strings | Chainable builder API |
| Parameterization | Manual `$1, $2` | Automatic |
| Migrations | External tool required | Built-in |
| Schema builder | None | Built-in |
| Multi-dialect | No | Yes |
| Learning curve | Lower (SQL knowledge sufficient) | Medium |
| Abstraction overhead | None | Minimal [Inference] |
| Debugging | SQL is explicit | Must inspect generated SQL |

**Key Points:**

- Knex is not an ORM — it does not manage entity relationships, lazy loading, or identity maps
- Knex is appropriate when you want composable query construction without giving up SQL visibility
- Raw `pg` is appropriate when queries are simple, fixed, and performance overhead must be minimal [Inference]

---

### Debugging: Inspecting Generated SQL

typescript

```typescript
// Log the SQL without executing
const sql = fastify.knex('users')
  .select('id', 'name')
  .where({ active: true })
  .toSQL()
  .toNative()

fastify.log.debug({ sql: sql.sql, bindings: sql.bindings }, 'Generated query')
```

**Enable query logging globally:**

typescript

```typescript
const knex = knexLib({
  client: 'pg',
  connection: process.env.DATABASE_URL,
  debug: process.env.NODE_ENV !== 'production'
})

knex.on('query', (query) => {
  fastify.log.debug({ sql: query.sql, bindings: query.bindings }, 'Knex query')
})
```

**Key Points:**

- `.toSQL().toNative()` returns the SQL string and binding array without executing — useful for debugging and logging
- The `debug: true` option or the `query` event logs every executed query; disable in production due to log volume and potential exposure of query parameters [Inference]

---

**Related Topics:**

- Knex with `objection.js` — adding a lightweight ORM layer on top of Knex
- Knex connection pooling tuning for high-concurrency Fastify applications
- Running Knex migrations programmatically on Fastify startup
- Knex batch inserts and `chunkSize` for large dataset operations
- Soft deletes with Knex (`deleted_at` column pattern)
- Pagination patterns: offset-based vs cursor-based with Knex
- Knex with multiple schemas in PostgreSQL
- Testing Knex queries with `testcontainers` and a real PostgreSQL instance
- Replacing Knex with `kysely` for stricter TypeScript type safety