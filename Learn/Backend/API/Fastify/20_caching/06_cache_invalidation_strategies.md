## Cache Invalidation Strategies

Cache invalidation is the process of removing or marking cached data as stale when the underlying source data changes. It is widely regarded as one of the hardest problems in distributed systems — not because the mechanics are complex, but because correctness requires precise knowledge of when data has changed and what cached representations depend on it.

---

### The Core Problem

A cache stores a snapshot of data at a point in time. When the source changes, the cache holds a lie. Invalidation is the act of reconciling that divergence.

The challenge is timing: invalidate too early and you lose cache benefit; invalidate too late and clients receive stale data. There is no universally correct answer — the right strategy depends on your consistency requirements and data mutation patterns.

**Key Points:**

- Invalidation is a correctness concern, not just a performance concern
- Every caching strategy implicitly accepts some window of staleness [Inference: derived from CAP theorem tradeoffs; actual staleness window depends on implementation]
- In Fastify, invalidation is not handled by any built-in mechanism — it must be designed and implemented explicitly

---

### TTL-Based Expiry (Passive Invalidation)

The simplest strategy: every cached entry carries a time-to-live. When the TTL elapses, the cache store discards the entry automatically. The next request triggers a fresh fetch.

typescript

```typescript
// Store with 60-second TTL
await fastify.redis.setex('cache:GET:/products', 60, payload)
```

**No explicit invalidation code is required.** The cache self-heals after each TTL window.

**Characteristics:**

| Property | Value |
| --- | --- |
| Implementation complexity | Low |
| Consistency guarantee | Eventual (within TTL window) |
| Invalidation granularity | Time-only; no content awareness |
| Suitable for | Infrequently changing, low-stakes data |

**Key Points:**

- TTL-based expiry accepts a bounded staleness window equal to the TTL duration
- Choosing TTL is a product decision, not a technical one — it encodes how much staleness your application can tolerate
- A TTL of zero effectively disables caching for that key
- Redis `SETEX` and `SET ... EX` both support TTL natively; the entry is automatically removed on expiry

**Limitation:** If source data changes one second after a cache entry is stored and the TTL is 3600 seconds, clients receive stale data for up to 3599 more seconds. TTL-based expiry provides no mechanism to react to mutations.

---

### Event-Based (Active) Invalidation

When a mutation occurs — a `POST`, `PUT`, `PATCH`, or `DELETE` — explicitly delete or update the affected cache keys. This is the most direct approach to keeping the cache consistent with the source.

typescript

```typescript
// Route that mutates data
fastify.put('/products/:id', async (request, reply) => {
  const { id } = request.params as { id: string }
  const updated = await db.updateProduct(id, request.body)

  // Invalidate the specific product cache
  await fastify.redis.del(`cache:GET:/products/${id}`)

  // Invalidate the product list (it may include this product)
  await fastify.redis.del('cache:GET:/products')

  return updated
})
```

**Key Points:**

- Deletion is immediate — the next request fetches fresh data
- You must identify every cache key that depends on the mutated data; missing one results in stale reads
- This approach requires tight coupling between mutation handlers and cache key naming conventions
- Suitable when mutation points are well-defined and finite

**Limitation:** As the application grows, tracking all keys affected by a given mutation becomes increasingly difficult to reason about and maintain. This is the fundamental scaling problem with key-level invalidation.

---

### Pattern-Based Invalidation

Instead of deleting specific keys, delete all keys matching a naming pattern. This is useful when a mutation affects a family of related cached responses (e.g., all paginated views of a product list).

**Using `SCAN` (production-safe):**

typescript

```typescript
async function invalidateByPattern(
  redis: Redis,
  pattern: string
): Promise<number> {
  let cursor = 0
  let deletedCount = 0

  do {
    const [nextCursor, keys] = await redis.scan(
      cursor,
      'MATCH', pattern,
      'COUNT', 100
    )
    cursor = parseInt(nextCursor, 10)

    if (keys.length > 0) {
      await redis.del(...keys)
      deletedCount += keys.length
    }
  } while (cursor !== 0)

  return deletedCount
}

// Usage in a mutation handler
fastify.post('/products', async (request, reply) => {
  const product = await db.createProduct(request.body)

  // Invalidate all product-related cache entries
  await invalidateByPattern(fastify.redis, 'cache:GET:/products*')

  return product
})
```

**[Inference]:** `SCAN` iterates the keyspace incrementally without blocking Redis, unlike `KEYS` which is a blocking O(N) operation. For large keyspaces, `KEYS` with a wildcard pattern can block Redis for measurable durations. Behavior depends on keyspace size and Redis version.

**Why not `KEYS`:**

typescript

```typescript
// Do not use in production
const keys = await fastify.redis.keys('cache:*')
// KEYS is O(N) and blocks the Redis event loop
```

**Key Points:**

- Pattern-based invalidation requires a consistent, predictable key naming convention
- It trades precision for coverage — it may invalidate more keys than strictly necessary
- The extra evictions cause additional cache misses but do not cause incorrect results

---

### Tag-Based Invalidation

Associate cache keys with one or more logical tags. When a tag is invalidated, all keys associated with that tag are evicted. This decouples cache keys from invalidation logic.

**Implementation using Redis Sets:**

Each tag maps to a Redis Set containing the cache keys associated with it. When a tag is invalidated, all keys in its Set are deleted.

typescript

```typescript
// Cache store utility
async function setWithTags(
  redis: Redis,
  key: string,
  value: string,
  ttl: number,
  tags: string[]
): Promise<void> {
  const pipeline = redis.pipeline()

  // Store the cached value
  pipeline.setex(key, ttl, value)

  // Register the key under each tag
  for (const tag of tags) {
    pipeline.sadd(`tag:${tag}`, key)
    pipeline.expire(`tag:${tag}`, ttl) // Tag set expires with data
  }

  await pipeline.exec()
}

// Invalidation utility
async function invalidateTag(redis: Redis, tag: string): Promise<void> {
  const tagKey = `tag:${tag}`
  const keys = await redis.smembers(tagKey)

  if (keys.length > 0) {
    const pipeline = redis.pipeline()
    pipeline.del(...keys)   // Delete all cached responses
    pipeline.del(tagKey)    // Delete the tag set itself
    await pipeline.exec()
  }
}
```

**Usage in route handlers:**

typescript

```typescript
// Storing with tags in onSend hook
fastify.addHook('onSend', async (request, reply, payload) => {
  if (request.method !== 'GET' || typeof payload !== 'string') return payload

  const tags = (request.routeOptions as any).config?.cacheTags ?? []
  const key = `cache:${request.url}`

  await setWithTags(fastify.redis, key, payload, 300, tags)
  return payload
})

// Route declares its tags
fastify.get('/products', {
  config: { cacheTags: ['products'] }
}, async () => {
  return db.getProducts()
})

fastify.get('/products/:id', {
  config: { cacheTags: ['products', 'product-detail'] }
}, async (request) => {
  const { id } = request.params as { id: string }
  return db.getProduct(id)
})

// Mutation invalidates by tag
fastify.put('/products/:id', async (request, reply) => {
  const result = await db.updateProduct(
    (request.params as any).id,
    request.body
  )
  await invalidateTag(fastify.redis, 'products')
  return result
})
```

**Key Points:**

- Tag-based invalidation scales well: adding a new route only requires declaring its tags, not updating invalidation logic elsewhere
- A single mutation can invalidate multiple tag groups simultaneously
- The tag-to-key registry itself must be kept consistent; if a cached entry expires before its tag set, the tag set may contain stale references (dangling keys) — these are harmless but accumulate over time [Inference]
- Tag sets should be cleaned periodically or given appropriate TTLs to prevent unbounded growth

---

### Mermaid: Tag-Based Invalidation Flow

YesNoPUT /products/42Update DBinvalidateTag: 'products'SMEMBERS tag:productsKeys found?DEL cache keys + DELtag:productsNo-opNext GET fetches freshdata

---

### Write-Through Caching

Instead of invalidating on mutation, update the cache at write time. When a mutation occurs, both the database and the cache are updated atomically (or near-atomically) within the same request.

typescript

```typescript
fastify.put('/products/:id', async (request, reply) => {
  const { id } = request.params as { id: string }
  const updated = await db.updateProduct(id, request.body)

  // Write updated value into cache immediately
  const key = `cache:GET:/products/${id}`
  await fastify.redis.setex(key, 300, JSON.stringify(updated))

  return updated
})
```

**Characteristics:**

| Property | Value |
| --- | --- |
| Staleness window | Near-zero (bounded by write latency) |
| Complexity | Medium |
| Risk | Cache and DB may diverge if write to cache fails |
| Suitable for | High-read, low-write data where consistency matters |

**Key Points:**

- Write-through ensures the cache is warm after every mutation — there is no cold-miss after invalidation
- If the cache write fails after the DB write succeeds, the cache holds stale data until TTL expires [Inference: failure modes depend on error handling implementation]
- A TTL should still be applied as a safety net against missed updates
- This pattern requires the serialized form written to cache to exactly match what the GET handler would produce — divergence in serialization logic causes subtle bugs [Inference]

---

### Stale-While-Revalidate

Return the stale cached response immediately while asynchronously triggering a background refresh. The client receives a fast response; the cache is updated in the background for the next request.

typescript

```typescript
fastify.addHook('onRequest', async (request, reply) => {
  if (request.method !== 'GET') return

  const key = `cache:${request.url}`
  const metaKey = `meta:${request.url}`

  const [cached, meta] = await Promise.all([
    fastify.redis.get(key),
    fastify.redis.get(metaKey)
  ])

  if (!cached) return // Full miss — let handler run normally

  const { storedAt, ttl } = JSON.parse(meta ?? '{}')
  const age = (Date.now() - storedAt) / 1000

  if (age < ttl) {
    // Fresh — serve directly
    reply.header('x-cache', 'HIT')
    reply.send(JSON.parse(cached))
    return
  }

  // Stale — serve immediately, revalidate in background
  reply.header('x-cache', 'STALE')
  reply.send(JSON.parse(cached))

  // Background refresh (do not await)
  setImmediate(async () => {
    try {
      const fresh = await fetchFreshData(request.url)
      await fastify.redis.setex(key, ttl, JSON.stringify(fresh))
      await fastify.redis.setex(
        metaKey,
        ttl,
        JSON.stringify({ storedAt: Date.now(), ttl })
      )
    } catch (err) {
      fastify.log.error(err, 'Background cache revalidation failed')
    }
  })
})
```

**[Inference]:** `setImmediate` executes after the current event loop tick, meaning the reply is sent before the background fetch begins. This pattern avoids blocking the response but introduces a window where multiple concurrent requests may each trigger a background refresh simultaneously — the cache stampede problem.

**Key Points:**

- This is a latency optimization: stale data is served rather than waiting for a fresh fetch
- Background refresh logic must replicate the same data-fetching logic as the route handler — this creates coupling [Inference]
- Suitable for data where serving slightly stale values is acceptable (e.g., product catalog, public content)
- Not suitable for financial data, inventory counts, or anything requiring strong consistency

---

### Cache Stampede Prevention

A cache stampede (also called a thundering herd) occurs when a popular cache key expires and many concurrent requests all experience a miss simultaneously, each triggering a full database query.

```
Key expires
    │
    ├── Request 1 → MISS → DB query
    ├── Request 2 → MISS → DB query
    ├── Request 3 → MISS → DB query
    └── ... N concurrent requests → N DB queries
```

**Mutex lock pattern using Redis `SET NX`:**

typescript

```typescript
async function getOrFetch(
  redis: Redis,
  key: string,
  fetchFn: () => Promise<string>,
  ttl: number
): Promise<string> {
  const cached = await redis.get(key)
  if (cached) return cached

  const lockKey = `lock:${key}`
  const lockTtl = 10 // seconds

  // Attempt to acquire lock
  const acquired = await redis.set(lockKey, '1', 'EX', lockTtl, 'NX')

  if (acquired) {
    try {
      const fresh = await fetchFn()
      await redis.setex(key, ttl, fresh)
      return fresh
    } finally {
      await redis.del(lockKey)
    }
  } else {
    // Lock held by another request — wait and retry
    await new Promise(resolve => setTimeout(resolve, 100))
    const retried = await redis.get(key)
    return retried ?? await fetchFn() // Fallback if still missing
  }
}
```

**Key Points:**

- `SET key value EX ttl NX` is atomic in Redis — only one caller succeeds in acquiring the lock [Inference: based on Redis documentation; behavior is consistent across standard Redis deployments but should be verified for Redis Cluster configurations]
- Other requests wait briefly and then read the key populated by the lock holder
- The fallback `fetchFn()` on retry is a safety net for cases where the lock holder fails — this means in degraded conditions, some duplicate queries may still occur [Inference]
- Lock TTL must exceed the expected fetch duration; if the fetch takes longer than the lock TTL, two requests may hold the lock simultaneously

---

### Versioned Cache Keys

Append a version identifier to cache keys. To invalidate an entire category of cached data, increment the version. Old keys become unreachable and expire via TTL naturally.

typescript

```typescript
// Store current version in Redis
async function getCacheVersion(redis: Redis, namespace: string): Promise<string> {
  const version = await redis.get(`version:${namespace}`)
  return version ?? '1'
}

async function incrementVersion(redis: Redis, namespace: string): Promise<void> {
  await redis.incr(`version:${namespace}`)
}

// Build versioned key
async function buildKey(redis: Redis, namespace: string, path: string): Promise<string> {
  const version = await getCacheVersion(redis, namespace)
  return `cache:v${version}:${namespace}:${path}`
}
```

**Usage:**

typescript

```typescript
// onRequest: compute versioned key and check cache
fastify.addHook('onRequest', async (request, reply) => {
  const key = await buildKey(fastify.redis, 'products', request.url)
  const cached = await fastify.redis.get(key)
  if (cached) {
    request.cacheKey = key
    reply.send(JSON.parse(cached))
  }
})

// Mutation: increment version
fastify.post('/products', async (request, reply) => {
  const result = await db.createProduct(request.body)
  await incrementVersion(fastify.redis, 'products')
  return result
})
```

**Key Points:**

- Version increment instantly invalidates all keys in a namespace — no key scanning required
- Old versioned keys are not deleted immediately; they expire via TTL, which means memory usage may temporarily increase after a version bump [Inference]
- This pattern is appropriate for bulk invalidation when fine-grained key tracking is impractical
- An extra Redis read (for the version) is required on every cache lookup — this adds latency [Inference]

---

### Comparing Invalidation Strategies

| Strategy | Consistency | Complexity | Invalidation Precision | Stampede Risk |
| --- | --- | --- | --- | --- |
| TTL expiry | Eventual | Low | None | Low |
| Event-based delete | Strong | Medium | High | Medium |
| Pattern-based delete | Strong | Medium | Medium | Medium |
| Tag-based | Strong | High | High | Medium |
| Write-through | Strong | Medium | High | Low |
| Stale-while-revalidate | Eventual | High | Medium | Low |
| Versioned keys | Strong | Medium | Namespace-level | Low |
| Mutex lock | Strong | High | N/A (stampede prevention) | None |

[Inference: classification is based on general distributed systems principles; actual consistency guarantees depend on implementation correctness and Redis deployment configuration]

---

### Integrating Invalidation into a Fastify Plugin

A complete plugin encapsulating invalidation utilities:

typescript

```typescript
// plugins/cacheInvalidation.ts
import fp from 'fastify-plugin'
import type { FastifyPluginAsync } from 'fastify'
import type { Redis } from 'ioredis'

declare module 'fastify' {
  interface FastifyInstance {
    cache: {
      invalidateKey: (key: string) => Promise<void>
      invalidateTag: (tag: string) => Promise<void>
      invalidatePattern: (pattern: string) => Promise<number>
      incrementVersion: (namespace: string) => Promise<void>
    }
  }
}

const cacheInvalidationPlugin: FastifyPluginAsync = async (fastify) => {
  const redis: Redis = fastify.redis

  async function invalidateKey(key: string): Promise<void> {
    await redis.del(key)
  }

  async function invalidateTag(tag: string): Promise<void> {
    const tagKey = `tag:${tag}`
    const keys = await redis.smembers(tagKey)
    if (keys.length > 0) {
      await redis.del(...keys, tagKey)
    }
  }

  async function invalidatePattern(pattern: string): Promise<number> {
    let cursor = 0
    let count = 0
    do {
      const [next, keys] = await redis.scan(cursor, 'MATCH', pattern, 'COUNT', 100)
      cursor = parseInt(next, 10)
      if (keys.length > 0) {
        await redis.del(...keys)
        count += keys.length
      }
    } while (cursor !== 0)
    return count
  }

  async function incrementVersion(namespace: string): Promise<void> {
    await redis.incr(`version:${namespace}`)
  }

  fastify.decorate('cache', {
    invalidateKey,
    invalidateTag,
    invalidatePattern,
    incrementVersion
  })
}

export default fp(cacheInvalidationPlugin)
```

**Usage anywhere in the application:**

typescript

```typescript
await fastify.cache.invalidateTag('products')
await fastify.cache.invalidatePattern('cache:GET:/users*')
await fastify.cache.incrementVersion('catalog')
```

---

**Related Topics:**

- Cache warming and pre-population on application startup
- Distributed invalidation across multiple Fastify instances (pub/sub with Redis)
- Cache consistency in horizontally scaled deployments
- `stale-if-error` patterns (serving stale on upstream failure)
- Two-phase invalidation for zero-downtime deployments
- Cache observability: tracking hit/miss/eviction rates per strategy
- Redis keyspace notifications for reactive invalidation
- Database-driven invalidation using change data capture (CDC)