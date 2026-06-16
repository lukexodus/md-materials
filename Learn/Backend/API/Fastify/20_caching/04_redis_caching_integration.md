## Redis Caching Integration in Fastify

Redis is the dominant choice for server-side caching in distributed Fastify deployments. As an in-memory data structure store with built-in persistence, pub/sub, atomic operations, and rich data types, Redis goes well beyond a simple key-value cache. This topic covers ioredis integration, connection management, data patterns, pipelining, scripting, and production concerns specific to Fastify applications.

---

### Why Redis Over In-Memory Caching

| Concern | In-Process Memory | Redis |
| --- | --- | --- |
| Shared across instances | No | Yes |
| Survives process restart | No | Optional (RDB/AOF) |
| Eviction policies | Manual / LRU library | Built-in (8 policies) |
| Data structures | JS objects | Strings, Hashes, Lists, Sets, Sorted Sets, Streams |
| TTL support | Manual | Native (`EX`, `PX`, `EXAT`) |
| Atomic operations | Limited (single-threaded JS) | Native (single-threaded Redis) |
| Pub/Sub | Not built-in | Native |
| Memory visibility | Per-process | Centralized |

---

### Installation

bash

```bash
npm install ioredis
```

ioredis is the most widely used Redis client for Node.js. It supports Redis Cluster, Sentinel, pipelining, Lua scripting, and automatic reconnection.

---

### Basic Connection

js

```js
import Redis from 'ioredis'

const redis = new Redis({
  host: process.env.REDIS_HOST ?? 'localhost',
  port: Number(process.env.REDIS_PORT ?? 6379),
  password: process.env.REDIS_PASSWORD,
  db: Number(process.env.REDIS_DB ?? 0),
  lazyConnect: true,           // Don't connect until first command
  enableReadyCheck: true,      // Wait for Redis to be ready before resolving
  maxRetriesPerRequest: 3,     // Retry failed commands up to 3 times
  retryStrategy: (times) => {
    if (times > 10) return null  // Stop retrying after 10 attempts
    return Math.min(times * 200, 2000)  // Exponential backoff, max 2s
  },
})

await redis.connect()
```

---

### Registering Redis as a Fastify Plugin

Expose Redis globally via a decorator so all routes and plugins can access a single shared client.

js

```js
// plugins/redis.js
import fp from 'fastify-plugin'
import Redis from 'ioredis'

async function redisPlugin(fastify, options) {
  const redis = new Redis({
    host: options.host ?? process.env.REDIS_HOST ?? 'localhost',
    port: Number(options.port ?? process.env.REDIS_PORT ?? 6379),
    password: options.password ?? process.env.REDIS_PASSWORD,
    lazyConnect: true,
    retryStrategy: (times) => {
      if (times > 10) return null
      return Math.min(times * 200, 2000)
    },
  })

  await redis.connect()

  fastify.decorate('redis', redis)

  fastify.addHook('onClose', async () => {
    await redis.quit()
  })
}

export default fp(redisPlugin, {
  name: 'redis',
  fastify: '5.x',
})
```

js

```js
// app.js
await fastify.register(redisPlugin, {
  host: 'localhost',
  port: 6379,
})

// Available on all routes
fastify.get('/test', async (request, reply) => {
  await fastify.redis.set('ping', 'pong', 'EX', 60)
  return { value: await fastify.redis.get('ping') }
})
```

**Key Points:**

- `fastify-plugin` breaks encapsulation — the `redis` decorator is available to the entire application, not just the registering scope.
- `onClose` hook calls `redis.quit()` to gracefully drain pending commands before disconnecting. Use `redis.disconnect()` for immediate disconnection without draining.
- A single Redis client instance handles connection pooling internally — do not create multiple clients for the same Redis server unless you have a specific reason (e.g., separate pub/sub client).

---

### Cache Helper Abstraction

Wrap raw Redis commands in a reusable helper that handles serialization, error handling, and consistent TTL management.

js

```js
// lib/redis-cache.js
export class RedisCache {
  #client
  #defaultTTL
  #namespace

  constructor(client, { defaultTTL = 300, namespace = '' } = {}) {
    this.#client = client
    this.#defaultTTL = defaultTTL
    this.#namespace = namespace
  }

  #key(key) {
    return this.#namespace ? `${this.#namespace}:${key}` : key
  }

  async get(key) {
    const value = await this.#client.get(this.#key(key))
    if (value === null) return null
    try {
      return JSON.parse(value)
    } catch {
      return value  // Return raw string if not valid JSON
    }
  }

  async set(key, value, ttl = this.#defaultTTL) {
    const serialized = typeof value === 'string' ? value : JSON.stringify(value)
    await this.#client.set(this.#key(key), serialized, 'EX', ttl)
  }

  async del(...keys) {
    await this.#client.del(...keys.map(k => this.#key(k)))
  }

  async exists(key) {
    return (await this.#client.exists(this.#key(key))) === 1
  }

  async ttl(key) {
    return this.#client.ttl(this.#key(key))
  }

  async getOrSet(key, loader, ttl = this.#defaultTTL) {
    const cached = await this.get(key)
    if (cached !== null) return cached

    const value = await loader()
    if (value !== null && value !== undefined) {
      await this.set(key, value, ttl)
    }
    return value
  }

  async invalidatePrefix(prefix) {
    // Use SCAN to avoid blocking Redis with KEYS on large datasets
    let cursor = '0'
    const fullPrefix = this.#key(prefix)

    do {
      const [nextCursor, keys] = await this.#client.scan(
        cursor,
        'MATCH', `${fullPrefix}*`,
        'COUNT', 100,
      )
      cursor = nextCursor
      if (keys.length > 0) {
        await this.#client.del(...keys)
      }
    } while (cursor !== '0')
  }
}
```

js

```js
// Register cache helper as a decorator
fastify.decorate('cache', new RedisCache(fastify.redis, {
  namespace: 'app',
  defaultTTL: 300,
}))

fastify.get('/api/products', async (request, reply) => {
  const products = await fastify.cache.getOrSet(
    `products:${request.query.category ?? 'all'}`,
    () => db.getProducts(request.query.category),
    120,
  )
  return products
})
```

---

### Redis Data Types for Caching

#### Strings — Single Values

The most common caching primitive. Stores any serialized value.

js

```js
// Set with TTL
await redis.set('config:global', JSON.stringify(config), 'EX', 3600)

// Get
const config = JSON.parse(await redis.get('config:global') ?? 'null')

// Set only if not exists (NX) — useful for locks
await redis.set('lock:job', '1', 'EX', 30, 'NX')

// Set and get previous value atomically (Redis 6.2+)
const previous = await redis.getset('key', newValue)
```

#### Hashes — Structured Objects

Store object fields individually. Useful when you need to read or update individual fields without deserializing the whole object.

js

```js
const userId = '42'

// Store user fields
await redis.hset(`user:${userId}`, {
  name: 'Alice',
  email: 'alice@example.com',
  role: 'admin',
  updatedAt: Date.now().toString(),
})
await redis.expire(`user:${userId}`, 3600)

// Read all fields
const user = await redis.hgetall(`user:${userId}`)

// Read a single field
const role = await redis.hget(`user:${userId}`, 'role')

// Update a single field without touching others
await redis.hset(`user:${userId}`, 'role', 'viewer')
```

**Key Points:**

- Hash fields are always strings in Redis — serialize numbers and booleans as strings and parse on read.
- `hgetall` returns an empty object (`{}`) if the key does not exist — check for this explicitly if absence is meaningful.

#### Sets — Unique Collections

Useful for membership checks and tag-based invalidation.

js

```js
// Add items to a set
await redis.sadd('active-sessions', sessionId)
await redis.expire('active-sessions', 86400)

// Check membership
const isActive = await redis.sismember('active-sessions', sessionId)

// Get all members
const sessions = await redis.smembers('active-sessions')

// Remove a member
await redis.srem('active-sessions', sessionId)
```

#### Sorted Sets — Ranked Data

Store items with a numeric score. Ideal for leaderboards, rate limiting windows, and time-ordered data.

js

```js
const now = Date.now()

// Add to leaderboard with score
await redis.zadd('leaderboard', score, userId)

// Get top 10 (highest scores)
const top10 = await redis.zrevrange('leaderboard', 0, 9, 'WITHSCORES')

// Remove entries older than 1 hour (sliding window)
await redis.zremrangebyscore('requests', '-inf', now - 3_600_000)

// Count entries in a score range
const count = await redis.zcount('requests', now - 60_000, now)
```

#### Lists — Queues and Stacks

js

```js
// Push to queue
await redis.rpush('job-queue', JSON.stringify(job))

// Pop from queue (blocking, waits up to 5 seconds)
const [, rawJob] = await redis.blpop('job-queue', 5) ?? []
const job = rawJob ? JSON.parse(rawJob) : null
```

---

### Pipelining

Pipelining batches multiple Redis commands into a single network round-trip, dramatically reducing latency for bulk operations.

js

```js
// Without pipeline — 3 round-trips
await redis.set('a', '1')
await redis.set('b', '2')
await redis.set('c', '3')

// With pipeline — 1 round-trip
const pipeline = redis.pipeline()
pipeline.set('a', '1', 'EX', 300)
pipeline.set('b', '2', 'EX', 300)
pipeline.set('c', '3', 'EX', 300)
const results = await pipeline.exec()
// results: [[null, 'OK'], [null, 'OK'], [null, 'OK']]
// Each element is [error, result]
```

#### Pipelining Reads and Writes Together

js

```js
async function getUserWithPreferences(redis, userId) {
  const pipeline = redis.pipeline()
  pipeline.hgetall(`user:${userId}`)
  pipeline.smembers(`user:${userId}:roles`)
  pipeline.get(`user:${userId}:preferences`)

  const [[, user], [, roles], [, rawPrefs]] = await pipeline.exec()

  return {
    ...user,
    roles,
    preferences: rawPrefs ? JSON.parse(rawPrefs) : {},
  }
}
```

**Key Points:**

- Pipeline commands are not atomic — they execute in order but other commands can interleave between them in a multi-client environment.
- For atomicity across multiple commands, use transactions (`MULTI`/`EXEC`) or Lua scripts.
- `pipeline.exec()` returns an array of `[error, result]` pairs — always check errors for individual commands.

---

### Transactions (MULTI/EXEC)

Transactions execute a block of commands atomically — no other client's commands interleave.

js

```js
async function incrementWithLimit(redis, key, limit, ttl) {
  const multi = redis.multi()
  multi.incr(key)
  multi.expire(key, ttl)
  const [[, count]] = await multi.exec()
  return count <= limit
}
```

#### Optimistic Locking with WATCH

`WATCH` monitors keys for changes. If a watched key changes before `EXEC`, the transaction aborts and returns `null`.

js

```js
async function transferCredits(redis, fromKey, toKey, amount) {
  let result = null

  while (result === null) {
    await redis.watch(fromKey)

    const balance = Number(await redis.get(fromKey) ?? 0)
    if (balance < amount) {
      await redis.unwatch()
      throw new Error('Insufficient credits')
    }

    result = await redis
      .multi()
      .decrby(fromKey, amount)
      .incrby(toKey, amount)
      .exec()
    // result is null if fromKey was modified by another client → retry
  }

  return result
}
```

**Key Points:**

- `WATCH` implements optimistic concurrency — suitable for low-contention scenarios.
- Under high contention, repeated retries can degrade performance. Lua scripts may be a better fit.
- [Inference: ioredis's `multi()` handles `WATCH` correctly but behavior in cluster mode may differ — verify for your deployment topology.]

---

### Lua Scripting

Lua scripts execute atomically on the Redis server — no other commands run between lines of the script. This is the most reliable way to implement complex atomic operations.

js

```js
// Atomic get-and-extend-TTL
const getAndRefresh = redis.defineCommand('getAndRefresh', {
  numberOfKeys: 1,
  lua: `
    local value = redis.call('GET', KEYS[1])
    if value then
      redis.call('EXPIRE', KEYS[1], ARGV[1])
    end
    return value
  `,
})

const value = await redis.getAndRefresh('session:abc', 1800)
```

#### Rate Limiter in Lua

js

```js
const rateLimitScript = redis.defineCommand('rateLimit', {
  numberOfKeys: 1,
  lua: `
    local key = KEYS[1]
    local limit = tonumber(ARGV[1])
    local window = tonumber(ARGV[2])
    local now = tonumber(ARGV[3])

    local count = redis.call('INCR', key)
    if count == 1 then
      redis.call('PEXPIRE', key, window)
    end

    if count > limit then
      local ttl = redis.call('PTTL', key)
      return {0, ttl}   -- {allowed, retryAfterMs}
    end

    return {1, 0}       -- {allowed, retryAfterMs}
  `,
})

async function checkRateLimit(redis, identifier, limit, windowMs) {
  const [allowed, retryAfter] = await redis.rateLimit(
    `rl:${identifier}`,
    limit,
    windowMs,
    Date.now(),
  )
  return { allowed: allowed === 1, retryAfter }
}
```

**Key Points:**

- `defineCommand` registers a Lua script with ioredis and computes a SHA for `EVALSHA` caching.
- Lua scripts block Redis for their duration — keep scripts short and avoid expensive loops.
- Keys must be declared explicitly (`KEYS[n]`) for Redis Cluster compatibility.
- [Inference: Lua scripts in Redis Cluster are restricted to keys on the same hash slot. Scripts that operate on keys across slots will fail in cluster mode.]

---

### Cache-Aside Pattern with Redis

js

```js
fastify.get('/api/articles/:id', async (request, reply) => {
  const key = `article:${request.params.id}`

  // 1. Check cache
  const cached = await fastify.redis.get(key)
  if (cached) {
    reply.header('X-Cache', 'HIT')
    return JSON.parse(cached)
  }

  // 2. Fetch from database
  const article = await db.getArticle(request.params.id)
  if (!article) return reply.status(404).send({ error: 'Not Found' })

  // 3. Store in cache
  await fastify.redis.set(key, JSON.stringify(article), 'EX', 300)

  reply.header('X-Cache', 'MISS')
  return article
})

// Invalidate on update
fastify.put('/api/articles/:id', async (request, reply) => {
  const updated = await db.updateArticle(request.params.id, request.body)
  await fastify.redis.del(`article:${request.params.id}`)
  return updated
})
```

---

### Distributed Locking with Redlock

For stampede protection and mutual exclusion across multiple Fastify instances, use the Redlock algorithm.

bash

```bash
npm install redlock
```

js

```js
import Redlock from 'redlock'

const redlock = new Redlock([redis], {
  retryCount: 5,
  retryDelay: 200,    // ms between retries
  retryJitter: 100,   // Random jitter added to retryDelay
})

async function getWithLock(redis, redlock, key, loader, ttl) {
  const cached = await redis.get(key)
  if (cached) return JSON.parse(cached)

  // Acquire distributed lock — only one instance regenerates
  const lock = await redlock.acquire([`lock:${key}`], 5000)

  try {
    // Double-check after acquiring lock — another instance may have populated it
    const doubleCheck = await redis.get(key)
    if (doubleCheck) return JSON.parse(doubleCheck)

    const value = await loader()
    await redis.set(key, JSON.stringify(value), 'EX', ttl)
    return value
  } finally {
    await lock.release()
  }
}
```

**Key Points:**

- The double-check after acquiring the lock prevents redundant regeneration when multiple instances were waiting for the lock.
- Lock TTL (5000ms here) must exceed the expected loader execution time. If the loader takes longer than the lock TTL, the lock expires and another instance may acquire it.
- Redlock requires an odd number of independent Redis nodes for strong guarantees. Against a single Redis instance, it degrades to a simple `SET NX` lock. [Inference: for most application caching scenarios, a single-node lock is sufficient — true Redlock guarantees require a multi-node setup.]

---

### Pub/Sub for Cache Invalidation

When one Fastify instance updates data, broadcast invalidation events to all instances via Redis pub/sub.

js

```js
// plugins/cache-invalidation.js
import fp from 'fastify-plugin'
import Redis from 'ioredis'

export default fp(async function cacheInvalidation(fastify) {
  // Separate client for subscriptions — subscribed clients cannot send regular commands
  const subscriber = new Redis({
    host: process.env.REDIS_HOST,
    port: Number(process.env.REDIS_PORT ?? 6379),
  })

  await subscriber.subscribe('cache:invalidate')

  subscriber.on('message', (channel, message) => {
    if (channel === 'cache:invalidate') {
      const { key } = JSON.parse(message)
      fastify.log.info({ key }, 'Received cache invalidation')
      // Clear from local in-memory cache if one exists
      fastify.lruCache?.delete(key)
    }
  })

  fastify.decorate('publishInvalidation', async (key) => {
    await fastify.redis.publish('cache:invalidate', JSON.stringify({ key }))
  })

  fastify.addHook('onClose', async () => {
    await subscriber.quit()
  })
})
```

js

```js
// Invalidate across all instances on write
fastify.put('/api/config', async (request, reply) => {
  const config = await db.updateConfig(request.body)

  // Delete from Redis
  await fastify.redis.del('config:global')

  // Notify all instances to clear their local caches
  await fastify.publishInvalidation('config:global')

  return config
})
```

**Key Points:**

- A subscriber client cannot issue regular Redis commands while subscribed — always use a separate client for subscriptions.
- Pub/sub is fire-and-forget — messages are not persisted. If an instance is temporarily offline, it will not receive the invalidation. TTL-based expiry is the safety net.
- For reliable message delivery, consider Redis Streams instead of pub/sub.

---

### Keyspace Notifications

Redis can emit events when keys expire or are deleted, enabling reactive cache behavior.

js

```js
// Enable keyspace notifications in Redis config or via command
await redis.config('SET', 'notify-keyspace-events', 'Ex')  // Expired events

const subscriber = new Redis({ host: 'localhost' })

// Subscribe to expiration events on db 0
await subscriber.subscribe('__keyevent@0__:expired')

subscriber.on('message', (channel, key) => {
  fastify.log.info({ key }, 'Key expired — triggering refresh')
  // Optionally pre-warm cache for this key
})
```

**Key Points:**

- Keyspace notifications have a performance cost — enable only what is needed (`E` = keyevent, `x` = expired, `g` = generic commands).
- [Inference: keyspace notifications may be delayed slightly under high Redis load — do not rely on them for hard real-time guarantees.]

---

### Connection Pooling and Multiple Redis Databases

ioredis manages a single persistent connection per client. For workloads that benefit from isolation:

js

```js
// Separate Redis databases (logical isolation, same server)
const sessionRedis = new Redis({ host: 'localhost', db: 1 })
const cacheRedis   = new Redis({ host: 'localhost', db: 2 })
const queueRedis   = new Redis({ host: 'localhost', db: 3 })

fastify.decorate('sessionStore', sessionRedis)
fastify.decorate('cache', cacheRedis)
fastify.decorate('queue', queueRedis)
```

**Key Points:**

- Redis databases (`SELECT 0–15` by default) provide logical separation on a single server — they do not provide performance isolation or independent memory limits.
- Redis Cluster does not support multiple databases — all keys are in `db 0`.
- For true isolation (separate memory, eviction policies, persistence), use separate Redis instances or Redis Cluster namespacing.

---

### Redis Cluster

js

```js
import { Cluster } from 'ioredis'

const cluster = new Cluster(
  [
    { host: 'redis-node-1', port: 6379 },
    { host: 'redis-node-2', port: 6379 },
    { host: 'redis-node-3', port: 6379 },
  ],
  {
    redisOptions: {
      password: process.env.REDIS_PASSWORD,
    },
    clusterRetryStrategy: (times) => Math.min(times * 300, 3000),
    enableReadyCheck: true,
    scaleReads: 'slave',  // Read from replicas to distribute load
  }
)

fastify.decorate('redis', cluster)
```

**Key Points:**

- In Cluster mode, keys are distributed across nodes by hash slot (based on the key name or hash tag).
- Multi-key operations (`MGET`, `DEL` with multiple keys, pipelines spanning keys) only work if all keys are on the same hash slot.
- Use hash tags to force related keys onto the same slot: `user:{42}:profile` and `user:{42}:roles` share the slot for `42`.

js

```js
// Hash tags — both keys land on the same slot
const profileKey = `user:{${userId}}:profile`
const rolesKey   = `user:{${userId}}:roles`

const pipeline = redis.pipeline()
pipeline.get(profileKey)
pipeline.get(rolesKey)
const [[, profile], [, roles]] = await pipeline.exec()
```

---

### Redis Sentinel (High Availability)

js

```js
const redis = new Redis({
  sentinels: [
    { host: 'sentinel-1', port: 26379 },
    { host: 'sentinel-2', port: 26379 },
    { host: 'sentinel-3', port: 26379 },
  ],
  name: 'mymaster',           // Sentinel master group name
  password: process.env.REDIS_PASSWORD,
  sentinelPassword: process.env.SENTINEL_PASSWORD,
  role: 'master',             // Connect to master for writes
})
```

**Key Points:**

- Sentinel monitors Redis masters and replicas and promotes a replica automatically on master failure.
- ioredis handles failover transparently — it reconnects to the new master after promotion.
- [Inference: commands in-flight during a failover may fail — implement retry logic for idempotent cache operations.]

---

### Error Handling and Resilience

Redis should not be in the critical path for correctness — treat cache failures as degraded performance, not application failures.

js

```js
async function safeGet(redis, key) {
  try {
    const value = await redis.get(key)
    return value ? JSON.parse(value) : null
  } catch (err) {
    fastify.log.warn({ err, key }, 'Redis GET failed — cache miss')
    return null  // Treat as cache miss, not a fatal error
  }
}

async function safeSet(redis, key, value, ttl) {
  try {
    await redis.set(key, JSON.stringify(value), 'EX', ttl)
  } catch (err) {
    fastify.log.warn({ err, key }, 'Redis SET failed — continuing without cache')
    // Non-fatal — the response is still served correctly
  }
}

fastify.get('/api/data', async (request, reply) => {
  const key = 'data:summary'

  const cached = await safeGet(fastify.redis, key)
  if (cached) return cached

  const data = await db.getSummary()
  await safeSet(fastify.redis, key, data, 300)
  return data
})
```

#### Connection Events

js

```js
redis.on('connect', () => fastify.log.info('Redis connected'))
redis.on('ready', () => fastify.log.info('Redis ready'))
redis.on('error', (err) => fastify.log.error({ err }, 'Redis error'))
redis.on('close', () => fastify.log.warn('Redis connection closed'))
redis.on('reconnecting', (delay) => fastify.log.warn({ delay }, 'Redis reconnecting'))
```

---

### Eviction Policies

Configure Redis to evict keys when memory is full. Set via `redis.conf` or the `CONFIG SET` command:

bash

```bash
# In redis.conf
maxmemory 512mb
maxmemory-policy allkeys-lru
```

| Policy | Behavior |
| --- | --- |
| `noeviction` | Return error on write when full (default) |
| `allkeys-lru` | Evict least recently used keys across all keys |
| `allkeys-lfu` | Evict least frequently used keys across all keys |
| `volatile-lru` | Evict LRU keys with a TTL set |
| `volatile-lfu` | Evict LFU keys with a TTL set |
| `volatile-ttl` | Evict keys with shortest TTL |
| `allkeys-random` | Evict random keys |
| `volatile-random` | Evict random keys with TTL |

**Key Points:**

- `allkeys-lru` is the most common choice for a pure cache deployment — Redis can evict any key to make space.
- `noeviction` is appropriate when Redis is used as a primary store, not a cache.
- `volatile-lru` is useful when mixing cached (TTL) and persistent (no TTL) data in the same instance.

---

### Health Check Integration

js

```js
fastify.get('/health', async (request, reply) => {
  const checks = { redis: 'unknown', database: 'unknown' }

  try {
    const pong = await fastify.redis.ping()
    checks.redis = pong === 'PONG' ? 'ok' : 'degraded'
  } catch (err) {
    checks.redis = 'error'
  }

  try {
    await db.query('SELECT 1')
    checks.database = 'ok'
  } catch {
    checks.database = 'error'
  }

  const healthy = Object.values(checks).every(v => v === 'ok')
  reply.status(healthy ? 200 : 503)
  return { status: healthy ? 'ok' : 'degraded', checks }
})
```

---

### Common Pitfalls

#### Using `KEYS` in Production

`KEYS pattern` scans the entire keyspace synchronously, blocking Redis for the duration. Use `SCAN` instead — it iterates incrementally.

js

```js
// Never in production
const keys = await redis.keys('user:*')

// Safe alternative
async function scanKeys(redis, pattern) {
  const found = []
  let cursor = '0'
  do {
    const [next, keys] = await redis.scan(cursor, 'MATCH', pattern, 'COUNT', 100)
    cursor = next
    found.push(...keys)
  } while (cursor !== '0')
  return found
}
```

#### Storing Large Objects Without Compression

Serializing large JavaScript objects directly to JSON produces verbose strings that consume Redis memory and increase network I/O. For large payloads, consider compression:

js

```js
import { gzip, gunzip } from 'node:zlib'
import { promisify } from 'node:util'

const gzipAsync = promisify(gzip)
const gunzipAsync = promisify(gunzip)

async function setCompressed(redis, key, value, ttl) {
  const json = JSON.stringify(value)
  const compressed = await gzipAsync(json)
  await redis.set(key, compressed, 'EX', ttl)
}

async function getCompressed(redis, key) {
  const compressed = await redis.getBuffer(key)  // Returns Buffer, not string
  if (!compressed) return null
  const json = await gunzipAsync(compressed)
  return JSON.parse(json.toString())
}
```

#### Not Handling `null` vs Missing Key

`redis.get()` returns `null` for both a key that does not exist and a key explicitly set to the string `"null"`. Design cache values to avoid ambiguity.

js

```js
// Ambiguous — was the value null, or was the key missing?
const value = await redis.get(key)
if (value === null) { /* miss or null? */ }

// Unambiguous — use a sentinel or check existence separately
const [value, exists] = await redis.pipeline().get(key).exists(key).exec()
```

#### Forgetting to Set TTL

A key set without a TTL persists in Redis indefinitely. Under `allkeys-lru` this is fine (it will eventually be evicted), but under `volatile-lru` or `noeviction`, it is never evicted and consumes memory forever.

js

```js
// Dangerous if maxmemory-policy is not allkeys-lru
await redis.set(key, value)

// Always explicit
await redis.set(key, value, 'EX', 3600)
```

#### Sharing a Subscribed Client for Regular Commands

A client in `subscribe` or `psubscribe` mode cannot issue regular commands — it throws an error.

js

```js
// Wrong — one client for both
await redis.subscribe('events')
await redis.get('some-key')  // Error: subscriber clients cannot send regular commands

// Correct — separate clients
const subscriber = new Redis(redisOptions)
const publisher  = new Redis(redisOptions)
await subscriber.subscribe('events')
await publisher.get('some-key')  // Fine
```

---

**Related Topics:**

- Server-side caching patterns — cache-aside, write-through, stampede protection
- `@fastify/rate-limit` with Redis — shared rate limit counters across instances
- Redis Streams — reliable message delivery as an alternative to pub/sub
- Session management with Redis — `@fastify/session` backed by a Redis store
- Redlock algorithm — distributed locking across multiple Redis nodes
- Redis persistence (RDB and AOF) — durability tradeoffs for cache vs primary store
- Monitoring Redis — keyspace metrics, memory usage, and hit rate with Redis INFO and Prometheus
- MessagePack vs JSON — binary serialization for reduced Redis memory footprint