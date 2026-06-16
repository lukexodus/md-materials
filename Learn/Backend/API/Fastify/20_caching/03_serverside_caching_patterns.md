## Server-Side Caching Patterns in Fastify

Server-side caching stores computed results, database query outputs, or external API responses in fast storage so subsequent requests can be served without repeating expensive work. Unlike HTTP cache headers — which instruct downstream clients and proxies — server-side caching is entirely within the server's control and invisible to the client. Fastify's plugin system and hook lifecycle provide multiple integration points for caching at different granularities.

---

### Why Server-Side Caching

With CacheYesNoRequestCache Hit?ResponseRoute HandlerDatabase / APIPopulate CacheWithout CacheRequestRoute HandlerDatabase / APIResponse

Common motivations:

- **Reduce database load** — repeated identical queries served from memory
- **Absorb traffic spikes** — popular resources served without hitting slow backends
- **Improve tail latency** — cache hits have predictable, low response times
- **Rate limit external APIs** — avoid exceeding third-party quotas by caching their responses

---

### Caching Layers in a Fastify Application

MissMissIncoming RequestRoute-Level CacheService / Data-AccessLayer CacheDatabase or External APIResponse

| Layer | Granularity | Typical Store | Use Case |
| --- | --- | --- | --- |
| Route-level | Full response | Redis, in-memory | Cacheable GET endpoints |
| Service-level | Function result | In-memory, Redis | Repeated business logic calls |
| Data-access level | Query result | Redis, in-memory | Expensive or repeated queries |
| Distributed | Shared across instances | Redis, Memcached | Multi-instance deployments |

---

### In-Memory Caching

The simplest form — a Map or purpose-built in-memory store local to the process.

#### Naive Map Cache

js

```js
const cache = new Map()

fastify.get('/api/config', async (request, reply) => {
  const key = 'config'

  if (cache.has(key)) {
    reply.header('X-Cache', 'HIT')
    return cache.get(key)
  }

  const config = await db.getConfig()
  cache.set(key, config)

  reply.header('X-Cache', 'MISS')
  return config
})
```

**Key Points:**

- A plain `Map` has no TTL, no size limit, and no eviction — it grows indefinitely. Suitable only for truly static data or short-lived processes.
- Does not share state across multiple Fastify instances.

---

### TTL-Based In-Memory Cache

Add time-to-live semantics manually or via a purpose-built library.

#### Manual TTL Wrapper

js

```js
class TTLCache {
  #store = new Map()

  set(key, value, ttlMs) {
    const expiresAt = Date.now() + ttlMs
    this.#store.set(key, { value, expiresAt })
  }

  get(key) {
    const entry = this.#store.get(key)
    if (!entry) return undefined
    if (Date.now() > entry.expiresAt) {
      this.#store.delete(key)
      return undefined
    }
    return entry.value
  }

  has(key) {
    return this.get(key) !== undefined
  }

  delete(key) {
    this.#store.delete(key)
  }

  clear() {
    this.#store.clear()
  }
}

const cache = new TTLCache()

fastify.get('/api/rates', async (request, reply) => {
  const key = 'exchange-rates'
  const cached = cache.get(key)

  if (cached !== undefined) {
    reply.header('X-Cache', 'HIT')
    return cached
  }

  const rates = await fetchExchangeRates()
  cache.set(key, rates, 5 * 60 * 1000)  // 5 minutes

  reply.header('X-Cache', 'MISS')
  return rates
})
```

#### Using `lru-cache`

A production-grade in-memory cache with LRU eviction and TTL support:

bash

```bash
npm install lru-cache
```

js

```js
import { LRUCache } from 'lru-cache'

const cache = new LRUCache({
  max: 500,                  // Maximum number of entries
  ttl: 1000 * 60 * 5,       // 5 minutes TTL (ms)
  ttlAutopurge: false,       // Don't scan on every set — lazy eviction
  allowStale: false,         // Don't return expired values
})

fastify.get('/api/products', async (request, reply) => {
  const key = `products:${request.query.category ?? 'all'}`
  const cached = cache.get(key)

  if (cached !== undefined) {
    reply.header('X-Cache', 'HIT')
    return cached
  }

  const products = await db.getProducts(request.query.category)
  cache.set(key, products)

  reply.header('X-Cache', 'MISS')
  return products
})
```

**Key Points:**

- LRU (Least Recently Used) eviction discards the least recently accessed entry when `max` is reached.
- `ttlAutopurge: false` defers cleanup to access time rather than running periodic sweeps — lower overhead, slightly less predictable memory use.
- `allowStale: true` returns an expired entry while triggering a background refresh — useful for stale-while-revalidate patterns.

---

### @fastify/caching Plugin

@fastify/caching integrates `abstract-cache` into Fastify, exposing a `fastify.cache` decorator.

bash

```bash
npm install @fastify/caching abstract-cache
```

js

```js
import Fastify from 'fastify'
import caching from '@fastify/caching'

const fastify = Fastify()

await fastify.register(caching, {
  privacy: caching.privacy.NOCACHE,
  expiresIn: 300,               // Seconds
  serverExpiresIn: 300,
})

fastify.get('/data', async (request, reply) => {
  reply.etag('data-v1')  // Sets ETag header
  return { data: [] }
})
```

**Key Points:**

- @fastify/caching is primarily focused on HTTP caching headers and ETags, not in-process data storage.
- For data-level caching, use `lru-cache`, Redis, or a custom solution directly.
- [Inference: @fastify/caching does not replace route-level data caching — it complements it by managing cache-related response headers.]

---

### Redis-Backed Caching

Redis is the standard choice for shared, persistent, multi-instance caching.

#### Setup

bash

```bash
npm install ioredis
```

js

```js
import Redis from 'ioredis'

const redis = new Redis({
  host: process.env.REDIS_HOST ?? 'localhost',
  port: Number(process.env.REDIS_PORT ?? 6379),
  lazyConnect: true,
})

await redis.connect()

// Decorate Fastify with the Redis client for global access
fastify.decorate('redis', redis)
```

#### Cache Helper Utility

js

```js
// lib/cache.js
export function makeCache(redis) {
  return {
    async get(key) {
      const value = await redis.get(key)
      return value ? JSON.parse(value) : null
    },

    async set(key, value, ttlSeconds) {
      await redis.set(key, JSON.stringify(value), 'EX', ttlSeconds)
    },

    async del(key) {
      await redis.del(key)
    },

    async delPattern(pattern) {
      // Use with caution on large keyspaces — SCAN is safer than KEYS
      const keys = await redis.keys(pattern)
      if (keys.length > 0) await redis.del(...keys)
    },
  }
}
```

#### Route-Level Redis Cache

js

```js
fastify.get('/api/articles', async (request, reply) => {
  const key = `articles:${request.query.page ?? 1}`
  const cached = await fastify.redis.get(key)

  if (cached) {
    reply.header('X-Cache', 'HIT')
    return JSON.parse(cached)
  }

  const articles = await db.getArticles({ page: request.query.page ?? 1 })

  await fastify.redis.set(
    key,
    JSON.stringify(articles),
    'EX', 120   // 120 seconds TTL
  )

  reply.header('X-Cache', 'MISS')
  return articles
})
```

---

### Cache-Aside Pattern

The most common pattern: the application manages cache population and invalidation explicitly.

1. Read2a. Hit2b. Miss3. Result4. WriteAppCacheDatabase

js

```js
async function getUser(userId, cache, db) {
  const key = `user:${userId}`

  // 1. Check cache
  const cached = await cache.get(key)
  if (cached) return cached

  // 2. Fetch from source
  const user = await db.findUser(userId)
  if (!user) return null

  // 3. Populate cache
  await cache.set(key, user, 300)  // 5 minutes

  return user
}

fastify.get('/users/:id', async (request, reply) => {
  const user = await getUser(
    request.params.id,
    fastify.cache,
    fastify.db,
  )

  if (!user) return reply.status(404).send({ error: 'Not Found' })
  return user
})
```

**Key Points:**

- Cache population happens on demand (lazy loading) — only data that is requested gets cached.
- The application is responsible for invalidating or updating cache entries on write.
- Suitable for most read-heavy workloads.

---

### Write-Through Pattern

On write, update both the database and the cache atomically. The cache is always in sync.

js

```js
async function updateUser(userId, data, cache, db) {
  // 1. Write to database
  const updated = await db.updateUser(userId, data)

  // 2. Update cache immediately
  await cache.set(`user:${userId}`, updated, 300)

  return updated
}

fastify.put('/users/:id', async (request, reply) => {
  const updated = await updateUser(
    request.params.id,
    request.body,
    fastify.cache,
    fastify.db,
  )
  return updated
})
```

**Key Points:**

- The cache is always consistent with the database immediately after a write.
- Slightly higher write latency — two operations per write instead of one.
- If the cache write fails after the database write succeeds, the cache becomes stale. Consider wrapping in a retry or accepting brief inconsistency.
- [Inference: true atomicity across a database write and a Redis write is not achievable without a distributed transaction mechanism — most implementations accept a small window of inconsistency.]

---

### Write-Behind (Write-Back) Pattern

Write to the cache immediately and persist to the database asynchronously. Optimizes write latency at the cost of durability.

js

```js
const writeQueue = new Map()

async function saveUserAsync(userId, data, cache, db) {
  // 1. Write to cache immediately — client gets fast response
  await cache.set(`user:${userId}`, data, 300)

  // 2. Queue database write
  writeQueue.set(userId, data)
}

// Flush queue to database periodically
setInterval(async () => {
  for (const [userId, data] of writeQueue) {
    try {
      await db.updateUser(userId, data)
      writeQueue.delete(userId)
    } catch (err) {
      fastify.log.error({ userId, err }, 'Write-behind flush failed')
    }
  }
}, 5000)
```

**Key Points:**

- Write-behind improves write throughput significantly but risks data loss if the process crashes before the flush.
- Suitable for non-critical data (user preferences, analytics events, view counts) — not financial or transactional data.
- [Inference: a Redis list or stream is a safer queue for write-behind than an in-memory Map, which is lost on process crash.]

---

### Read-Through Pattern

The cache itself is responsible for fetching from the source on a miss, rather than the application.

js

```js
class ReadThroughCache {
  #store
  #loader

  constructor(store, loader) {
    this.#store = store
    this.#loader = loader
  }

  async get(key, ttlSeconds = 300) {
    const cached = await this.#store.get(key)
    if (cached !== null) return cached

    const value = await this.#loader(key)
    if (value !== null) {
      await this.#store.set(key, value, ttlSeconds)
    }
    return value
  }

  async invalidate(key) {
    await this.#store.del(key)
  }
}

const userCache = new ReadThroughCache(
  fastify.cache,
  async (key) => {
    const id = key.replace('user:', '')
    return db.findUser(id)
  }
)

fastify.get('/users/:id', async (request, reply) => {
  const user = await userCache.get(`user:${request.params.id}`)
  if (!user) return reply.status(404).send({ error: 'Not Found' })
  return user
})
```

**Key Points:**

- Read-through abstracts cache logic from route handlers — handlers simply call `cache.get`.
- The loader function encapsulates the data-fetching strategy.
- Well-suited for wrapping repository or data-access classes.

---

### Request-Level Caching (Deduplication)

Within a single request, the same data may be fetched multiple times by different parts of the handler chain (hooks, plugins, nested function calls). A request-scoped cache deduplicates these.

js

```js
fastify.addHook('onRequest', (request, reply, done) => {
  request.dataCache = new Map()
  done()
})

async function getUserCached(request, userId) {
  const key = `user:${userId}`

  if (request.dataCache.has(key)) {
    return request.dataCache.get(key)
  }

  const user = await db.findUser(userId)
  request.dataCache.set(key, user)
  return user
}

fastify.get('/dashboard/:userId', async (request, reply) => {
  // Both calls resolve to the same fetch — second is free
  const user = await getUserCached(request, request.params.userId)
  const perms = await getPermissions(request, request.params.userId)
  // getPermissions also calls getUserCached internally
  return { user, perms }
})
```

**Key Points:**

- Request-scoped caches are automatically discarded at request end — no invalidation needed.
- Useful in GraphQL resolvers, nested service calls, and middleware chains where the same data is requested multiple times per request.
- This pattern is sometimes called a **DataLoader**-style approach, popularized by Facebook's DataLoader library.

---

### Route-Level Response Caching via Hook

Cache entire serialized responses at the `onSend` hook and return them on subsequent matching requests.

js

```js
import { LRUCache } from 'lru-cache'

const responseCache = new LRUCache({
  max: 200,
  ttl: 1000 * 60,  // 1 minute
})

function cacheableRoute(options = {}) {
  const { ttl = 1000 * 60, keyFn } = options

  return {
    onRequest: async (request, reply) => {
      const key = keyFn ? keyFn(request) : request.url
      const cached = responseCache.get(key)

      if (cached) {
        reply
          .status(cached.statusCode)
          .headers(cached.headers)
          .header('X-Cache', 'HIT')
        return reply.send(cached.body)
      }

      request.cacheKey = key
    },

    onSend: async (request, reply, payload) => {
      if (request.cacheKey && reply.statusCode === 200) {
        responseCache.set(
          request.cacheKey,
          {
            statusCode: reply.statusCode,
            headers: reply.getHeaders(),
            body: payload,
          },
          { ttl }
        )
      }
      return payload
    },
  }
}

fastify.get('/api/public-feed', {
  ...cacheableRoute({ ttl: 30_000 }),
  handler: async () => {
    return await buildFeed()
  },
})
```

**Key Points:**

- This approach caches the full serialized response, bypassing serialization on cache hits.
- The cache key must uniquely represent the response variation — include query parameters, relevant headers, or locale in the key for routes where these affect output.
- Only cache `200` responses — error responses should not be cached at this level.
- [Inference: returning early from `onRequest` with `reply.send` bypasses subsequent hooks and the route handler. Verify this behavior against the Fastify version in use.]

---

### Cache Key Design

A cache key must uniquely identify a cacheable unit. Poor key design causes cache collisions (wrong data served) or excessive cache misses (no reuse).

#### Principles

js

```js
// Too broad — collides across users
const key = 'articles'

// Too narrow — never reuses (includes timestamp)
const key = `articles:${Date.now()}`

// Good — captures all variation dimensions
const key = [
  'articles',
  `page:${query.page ?? 1}`,
  `limit:${query.limit ?? 20}`,
  `category:${query.category ?? 'all'}`,
  `lang:${headers['accept-language'] ?? 'en'}`,
].join(':')
```

#### User-Scoped Keys

js

```js
// Per-user cache — avoid sharing private data
const key = `dashboard:user:${request.user.id}`
```

#### Versioned Keys

Include a version prefix to invalidate all cache entries globally without flushing the entire store:

js

```js
const CACHE_VERSION = 'v3'
const key = `${CACHE_VERSION}:articles:page:${page}`

// To bust the entire cache, increment CACHE_VERSION
```

---

### Cache Invalidation Strategies

Cache invalidation is one of the most challenging aspects of caching. The core approaches:

#### Time-Based (TTL)

Let entries expire naturally. Simple but may serve stale data until expiry.

js

```js
await redis.set(key, value, 'EX', 300)  // Expires in 5 minutes
```

#### Event-Driven Invalidation

Invalidate on write — delete or update cache entries when the underlying data changes.

js

```js
fastify.post('/articles', async (request, reply) => {
  const article = await db.createArticle(request.body)

  // Invalidate related cache keys
  await fastify.redis.del('articles:page:1')
  await fastify.redis.del(`articles:category:${article.category}`)

  reply.status(201)
  return article
})
```

#### Tag-Based Invalidation

Associate cache entries with tags; invalidate all entries sharing a tag.

js

```js
// Store tag → keys mapping in Redis sets
async function setWithTags(redis, key, value, ttl, tags) {
  const pipeline = redis.pipeline()
  pipeline.set(key, JSON.stringify(value), 'EX', ttl)

  for (const tag of tags) {
    pipeline.sadd(`tag:${tag}`, key)
    pipeline.expire(`tag:${tag}`, ttl)
  }

  await pipeline.exec()
}

async function invalidateTag(redis, tag) {
  const keys = await redis.smembers(`tag:${tag}`)
  if (keys.length > 0) {
    const pipeline = redis.pipeline()
    keys.forEach(k => pipeline.del(k))
    pipeline.del(`tag:${tag}`)
    await pipeline.exec()
  }
}

// Usage
await setWithTags(redis, `article:${id}`, article, 300, ['articles', `author:${article.authorId}`])

// Invalidate all articles when any article changes
await invalidateTag(redis, 'articles')

// Invalidate all content by a specific author
await invalidateTag(redis, `author:${authorId}`)
```

#### Versioned Namespaces

Increment a version counter; include it in all cache keys. Invalidating all keys is instant — just bump the version.

js

```js
async function getCacheVersion(redis, namespace) {
  return await redis.get(`version:${namespace}`) ?? '1'
}

async function bumpVersion(redis, namespace) {
  return await redis.incr(`version:${namespace}`)
}

// Read
const version = await getCacheVersion(redis, 'articles')
const key = `articles:v${version}:page:${page}`

// Invalidate all articles cache entries instantly
await bumpVersion(redis, 'articles')
// Old keys become orphaned and expire naturally via TTL
```

---

### Stampede Protection (Cache Warming)

When a popular cache entry expires, multiple concurrent requests may simultaneously attempt to regenerate it — all hitting the database at once. This is a **cache stampede** (also called **thundering herd**).

DatabaseCacheRequest 3Request 2Request 1DatabaseCacheRequest 3Request 2Request 13× load spikeGET key → MISSGET key → MISSGET key → MISSQuery (expensive)Query (expensive)Query (expensive)

#### Solution: Lock-Based Regeneration

js

```js
const locks = new Map()

async function getWithStampedeProtection(redis, key, loader, ttl) {
  // 1. Check cache
  const cached = await redis.get(key)
  if (cached) return JSON.parse(cached)

  // 2. Check if another request is already regenerating
  if (locks.has(key)) {
    // Wait for the in-flight request to finish
    return locks.get(key)
  }

  // 3. Acquire lock — store the promise so others can await it
  const promise = (async () => {
    try {
      const value = await loader()
      await redis.set(key, JSON.stringify(value), 'EX', ttl)
      return value
    } finally {
      locks.delete(key)
    }
  })()

  locks.set(key, promise)
  return promise
}

fastify.get('/api/leaderboard', async (request, reply) => {
  const data = await getWithStampedeProtection(
    fastify.redis,
    'leaderboard:top100',
    () => db.getTopUsers(100),
    60
  )
  return data
})
```

**Key Points:**

- The `locks` Map deduplicates in-flight requests within a single process.
- For multi-instance deployments, use a Redis-based distributed lock (e.g., `redlock`) to coordinate across instances.
- [Inference: the in-memory lock approach shown works only within a single Node.js process — it does not prevent stampedes across multiple Fastify instances.]

#### Stale-While-Revalidate at the Application Layer

Serve stale data immediately while refreshing asynchronously:

js

```js
const cache = new LRUCache({ max: 500, ttl: 60_000, allowStale: true })
const refreshing = new Set()

async function getStaleWhileRevalidate(key, loader) {
  const stale = cache.get(key)  // Returns expired value when allowStale: true

  if (stale !== undefined) {
    // Serve stale immediately; refresh in background if not already refreshing
    if (cache.getRemainingTTL(key) <= 0 && !refreshing.has(key)) {
      refreshing.add(key)
      loader()
        .then(fresh => cache.set(key, fresh))
        .catch(err => fastify.log.error(err, 'Background cache refresh failed'))
        .finally(() => refreshing.delete(key))
    }
    return stale
  }

  // No stale entry — must wait for fresh value
  const fresh = await loader()
  cache.set(key, fresh)
  return fresh
}
```

---

### Caching with Fastify Plugins and Encapsulation

Register cache instances within scoped plugins to isolate concerns:

js

```js
// plugins/cache.js
import fp from 'fastify-plugin'
import { LRUCache } from 'lru-cache'

export default fp(async function cachePlugin(fastify, options) {
  const cache = new LRUCache({
    max: options.max ?? 1000,
    ttl: options.ttl ?? 60_000,
  })

  fastify.decorate('lruCache', cache)

  fastify.addHook('onClose', () => {
    cache.clear()
  })
})
```

js

```js
// app.js
await fastify.register(cachePlugin, { max: 500, ttl: 300_000 })

// Available globally due to fastify-plugin (no encapsulation)
fastify.lruCache.set('key', 'value')
```

**Key Points:**

- Wrapping with `fastify-plugin` breaks encapsulation — the decorator is available to the entire application.
- Without `fastify-plugin`, the decorator is scoped to the plugin and its children only.
- `onClose` hook clears the cache on shutdown, releasing memory cleanly.

---

### Monitoring Cache Performance

Track hit/miss rates to evaluate cache effectiveness:

js

```js
const stats = { hits: 0, misses: 0 }

fastify.addHook('onRequest', (request, reply, done) => {
  request.cacheStats = stats
  done()
})

// In your cache helper
async function getCached(key, loader, ttl) {
  const cached = await redis.get(key)

  if (cached) {
    stats.hits++
    return JSON.parse(cached)
  }

  stats.misses++
  const value = await loader()
  await redis.set(key, JSON.stringify(value), 'EX', ttl)
  return value
}

// Expose stats endpoint
fastify.get('/internal/cache-stats', async () => ({
  ...stats,
  hitRate: stats.hits / (stats.hits + stats.misses || 1),
}))
```

---

### Common Pitfalls

#### Caching User-Specific Data at a Shared Key

js

```js
// Dangerous — all users see the same cached profile
const key = 'user-profile'

// Correct — scoped to user
const key = `user-profile:${request.user.id}`
```

#### Caching Error States

If a loader throws and the error is accidentally cached, all subsequent requests receive the cached error until TTL expires.

js

```js
try {
  const value = await loader()
  await cache.set(key, value, ttl)
  return value
} catch (err) {
  // Do not cache errors — let them propagate
  throw err
}
```

#### Ignoring Cache Serialization Cost

JSON serialization and deserialization of large objects has measurable cost. For very large payloads, consider MessagePack or other binary formats, or cache at a higher abstraction level.

#### Unbounded In-Memory Cache Growth

A plain `Map` with no eviction policy will consume increasing memory over the lifetime of the process. Always set `max` on LRU caches and monitor memory usage.

#### Silent Stale Reads After Schema Changes

If the cached data structure changes (e.g., a field is renamed), old cached entries will return the old shape until they expire. Use versioned cache keys or flush the cache on deployment.

js

```js
const SCHEMA_VERSION = 'v2'
const key = `${SCHEMA_VERSION}:user:${id}`
```

---

**Related Topics:**

- Redis integration with ioredis — connection pooling, pipelining, and cluster support
- HTTP cache headers — `Cache-Control`, `Vary`, and `ETag` as client-facing complements
- ETag and conditional requests — validator-based cache coherence at the HTTP layer
- `@fastify/rate-limit` with Redis — shared state across instances using the same Redis client
- Distributed locks with Redlock — stampede protection across multiple instances
- Cache warming strategies — pre-populating caches on startup or deployment
- Fastify decorators and plugin encapsulation — structuring shared cache instances correctly
- Observability and metrics — integrating cache hit/miss rates with Prometheus and Grafana