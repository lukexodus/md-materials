## Redis with @fastify/redis

`@fastify/redis` is the officially scoped Fastify plugin for Redis integration. It wraps `ioredis` — a full-featured Redis client for Node.js — and decorates the Fastify instance with `fastify.redis`, managing the connection lifecycle within Fastify's plugin system. Redis in this context serves as a general-purpose data structure store: used for caching, session storage, pub/sub messaging, rate limiting, queues, and distributed locking.

---

### What `@fastify/redis` Provides

| Feature | Description |
| --- | --- |
| `fastify.redis` decorator | Shared `ioredis` client instance across all routes and plugins |
| Lifecycle management | Connects on startup, closes on `fastify.close()` via `onClose` hook |
| Multiple named instances | Register multiple Redis connections under distinct namespaces |
| Full `ioredis` API | All `ioredis` commands, pipelining, Lua scripting, and cluster support |
| Existing client support | Pass a pre-configured `ioredis` instance rather than connection options |

**Key Points:**

- `@fastify/redis` is a thin integration layer — the underlying client is `ioredis`, not the `redis` (node-redis) package
- All Redis commands, options, and behaviors documented in `ioredis` apply directly [Inference: based on plugin documentation; verify against current `@fastify/redis` version]
- The plugin does not abstract Redis commands — `fastify.redis` is the `ioredis` client instance directly

---

### Installation

bash

```bash
npm install @fastify/redis
```

`ioredis` is a peer dependency:

bash

```bash
npm install ioredis
npm install --save-dev @types/ioredis   # If needed; ioredis ships its own types
```

**Key Points:**

- `ioredis` ships TypeScript types in its main package as of recent versions — `@types/ioredis` may be redundant [Unverified: verify against your installed `ioredis` version]

---

### Basic Registration

typescript

```typescript
import Fastify from 'fastify'
import fastifyRedis from '@fastify/redis'

const fastify = Fastify({ logger: true })

await fastify.register(fastifyRedis, {
  host: '127.0.0.1',
  port: 6379,
  password: process.env.REDIS_PASSWORD,
  db: 0
})

await fastify.listen({ port: 3000 })
```

**With a connection URL:**

typescript

```typescript
await fastify.register(fastifyRedis, {
  url: process.env.REDIS_URL   // e.g. redis://:password@host:6379/0
})
```

**Key Points:**

- `db` selects the Redis logical database (0–15 by default); different databases share the same server but have isolated keyspaces
- Credentials should come from environment variables — never hardcode Redis passwords in source
- The plugin calls `client.quit()` in an `onClose` hook automatically — no manual cleanup required in most cases [Inference: based on `@fastify/redis` documented behavior; verify against current version]

---

### Passing a Pre-Configured `ioredis` Instance

For advanced `ioredis` configuration not exposed through plugin options — such as TLS, Sentinel, or Cluster mode — construct the client manually and pass it to the plugin.

typescript

```typescript
import { Redis } from 'ioredis'

const redisClient = new Redis({
  host: process.env.REDIS_HOST ?? 'localhost',
  port: parseInt(process.env.REDIS_PORT ?? '6379', 10),
  password: process.env.REDIS_PASSWORD,
  tls: process.env.NODE_ENV === 'production' ? {} : undefined,
  retryStrategy: (times) => Math.min(times * 100, 3_000),
  maxRetriesPerRequest: 3,
  enableReadyCheck: true,
  lazyConnect: false
})

await fastify.register(fastifyRedis, { client: redisClient })
```

**Key Points:**

- When passing an existing `client`, the plugin does not call `client.quit()` on `fastify.close()` by default — manage the lifecycle manually or set `closeClient: true` in plugin options [Unverified: verify `closeClient` option against current `@fastify/redis` version]
- `retryStrategy` controls reconnection backoff — the function receives the number of retry attempts and returns the delay in milliseconds; returning `null` stops retrying [Inference: based on `ioredis` documentation]
- `lazyConnect: false` (the default) connects immediately on instantiation; `lazyConnect: true` defers connection until the first command is issued

---

### TypeScript Declaration

`@fastify/redis` ships its own type augmentation for `FastifyInstance`. If `fastify.redis` does not resolve in your editor, ensure the plugin package is imported:

typescript

```typescript
import '@fastify/redis'
// FastifyInstance is now augmented with .redis: Redis
```

For named instances, additional augmentation may be needed [Unverified: verify against current `@fastify/redis` TypeScript definitions].

---

### Multiple Named Connections

Register the plugin multiple times with the `namespace` option to maintain distinct connections — for example, one for caching and one for session storage.

typescript

```typescript
await fastify.register(fastifyRedis, {
  url: process.env.REDIS_CACHE_URL,
  namespace: 'cache'
})

await fastify.register(fastifyRedis, {
  url: process.env.REDIS_SESSION_URL,
  namespace: 'session'
})
```

**Access by namespace:**

typescript

```typescript
fastify.get('/example', async (request, reply) => {
  await fastify.redis.cache.set('key', 'value', 'EX', 60)
  await fastify.redis.session.set('sess:abc', JSON.stringify({ userId: 1 }), 'EX', 3600)
  return { ok: true }
})
```

**Key Points:**

- Without a `namespace`, the plugin decorates `fastify.redis` directly
- With a `namespace`, the plugin decorates `fastify.redis[namespace]`
- Each namespace maintains an independent connection pool and configuration
- Separating caches from session stores prevents a cache flush (`FLUSHDB`) from clearing sessions [Inference]

---

### Core `ioredis` Command Patterns

`fastify.redis` exposes the full `ioredis` API. The following patterns cover the most common use cases.

#### String Commands

typescript

```typescript
// SET with expiry
await fastify.redis.set('user:42:name', 'Alice')
await fastify.redis.set('user:42:token', 'abc123', 'EX', 3600)    // Expires in 1 hour
await fastify.redis.set('lock:resource', '1', 'EX', 10, 'NX')     // SET if Not eXists

// GET
const name = await fastify.redis.get('user:42:name')   // 'Alice' | null

// DELETE
await fastify.redis.del('user:42:token')

// EXISTS
const exists = await fastify.redis.exists('user:42:name')  // 1 | 0

// TTL inspection
const ttl = await fastify.redis.ttl('user:42:token')   // seconds remaining; -1 = no TTL; -2 = key absent

// Atomic increment/decrement
await fastify.redis.incr('counter:page_views')
await fastify.redis.incrby('counter:downloads', 5)
await fastify.redis.decr('counter:remaining')
```

#### Hash Commands

Hashes store field-value maps within a single key — suitable for structured objects.

typescript

```typescript
// Set individual fields
await fastify.redis.hset('user:42', 'name', 'Alice', 'email', 'alice@example.com')

// Set multiple fields from an object
await fastify.redis.hset('user:42', {
  name: 'Alice',
  email: 'alice@example.com',
  role: 'admin'
})

// Get one field
const name = await fastify.redis.hget('user:42', 'name')

// Get all fields
const user = await fastify.redis.hgetall('user:42')
// Returns: { name: 'Alice', email: 'alice@example.com', role: 'admin' }

// Delete a field
await fastify.redis.hdel('user:42', 'role')

// Check field existence
const hasEmail = await fastify.redis.hexists('user:42', 'email')  // 1 | 0
```

**Key Points:**

- `hgetall` returns an empty object (`{}`) when the key does not exist — not `null` [Inference: based on `ioredis` behavior; verify against your version]
- Hashes are more memory-efficient than storing each field as a separate string key when the object is accessed together [Inference: based on Redis memory optimization documentation]
- Hashes do not support nested objects — values must be strings; serialize nested data as JSON

#### List Commands

typescript

```typescript
// Push to head (left) or tail (right)
await fastify.redis.lpush('queue:jobs', JSON.stringify({ type: 'email', to: 'alice@example.com' }))
await fastify.redis.rpush('log:events', JSON.stringify({ event: 'login', userId: 42 }))

// Pop from head or tail
const job = await fastify.redis.lpop('queue:jobs')

// Blocking pop (waits up to N seconds for an item)
const [listKey, value] = await fastify.redis.blpop('queue:jobs', 5)

// Range (0-indexed; -1 = last element)
const items = await fastify.redis.lrange('log:events', 0, -1)

// Length
const length = await fastify.redis.llen('queue:jobs')
```

**Key Points:**

- `blpop` blocks the connection until an item is available or the timeout elapses — use a dedicated `ioredis` instance for blocking commands, not the shared `fastify.redis` client, as blocking one command blocks all commands on that connection [Inference: based on `ioredis` and Redis architecture; verify for your use case]
- Lists are ordered by insertion — suitable for queues (`rpush` + `blpop`) and stacks (`lpush` + `lpop`)

#### Set Commands

typescript

```typescript
// Add members
await fastify.redis.sadd('tags:post:42', 'typescript', 'fastify', 'redis')

// Check membership
const isMember = await fastify.redis.sismember('tags:post:42', 'fastify')  // 1 | 0

// Get all members
const tags = await fastify.redis.smembers('tags:post:42')

// Remove members
await fastify.redis.srem('tags:post:42', 'redis')

// Set cardinality
const count = await fastify.redis.scard('tags:post:42')
```

#### Sorted Set Commands

Sorted sets associate each member with a floating-point score — members are ordered by score.

typescript

```typescript
// Add with score
await fastify.redis.zadd('leaderboard', 1500, 'alice', 2300, 'bob', 900, 'carol')

// Get rank (0-indexed, ascending)
const rank = await fastify.redis.zrank('leaderboard', 'alice')

// Get top N by score (descending)
const top3 = await fastify.redis.zrevrange('leaderboard', 0, 2, 'WITHSCORES')

// Increment score
await fastify.redis.zincrby('leaderboard', 100, 'alice')

// Count members in score range
const count = await fastify.redis.zcount('leaderboard', 1000, 2000)
```

---

### Pipelining

Pipelining sends multiple commands to Redis in a single round-trip, reducing network latency for batched operations.

typescript

```typescript
fastify.get('/dashboard/:userId', async (request) => {
  const { userId } = request.params as { userId: string }

  const pipeline = fastify.redis.pipeline()

  pipeline.get(`user:${userId}:profile`)
  pipeline.get(`user:${userId}:preferences`)
  pipeline.zrevrange(`user:${userId}:activity`, 0, 9)
  pipeline.hgetall(`user:${userId}:stats`)

  const results = await pipeline.exec()
  // results: Array of [error, value] tuples

  const [
    [, profile],
    [, preferences],
    [, activity],
    [, stats]
  ] = results ?? []

  return {
    profile: profile ? JSON.parse(profile as string) : null,
    preferences: preferences ? JSON.parse(preferences as string) : null,
    activity,
    stats
  }
})
```

**Key Points:**

- `pipeline.exec()` returns an array of `[Error | null, result]` tuples — one per command in insertion order
- Errors in individual pipeline commands do not abort the pipeline — other commands still execute [Inference: based on `ioredis` documentation; behavior differs from transactions]
- Pipelining is a network optimization — it does not provide atomicity. For atomic multi-command execution, use `MULTI`/`EXEC` transactions

---

### Transactions (`MULTI`/`EXEC`)

Redis transactions execute a queued set of commands atomically — no other client can interleave commands between `MULTI` and `EXEC`.

typescript

```typescript
async function atomicTransfer(
  redis: Redis,
  fromKey: string,
  toKey: string,
  amount: number
): Promise<void> {
  const results = await redis
    .multi()
    .decrby(fromKey, amount)
    .incrby(toKey, amount)
    .exec()

  if (!results) throw new Error('Transaction aborted (WATCH conflict)')
}
```

**With `WATCH` for optimistic locking:**

typescript

```typescript
async function conditionalUpdate(
  redis: Redis,
  key: string,
  expectedValue: string,
  newValue: string
): Promise<boolean> {
  await redis.watch(key)

  const current = await redis.get(key)
  if (current !== expectedValue) {
    await redis.unwatch()
    return false
  }

  const results = await redis
    .multi()
    .set(key, newValue)
    .exec()

  // null result means WATCH detected a change — transaction aborted
  return results !== null
}
```

**Key Points:**

- `MULTI`/`EXEC` guarantees atomicity — all commands execute or none do; however, Redis does not roll back on runtime errors within a transaction [Inference: this is a documented Redis design decision — command errors within a transaction are returned in the results array, not rolled back]
- `WATCH` marks keys for optimistic locking — if any watched key is modified between `WATCH` and `EXEC`, the transaction returns `null` and must be retried [Inference: based on Redis documentation]
- Redis transactions differ fundamentally from SQL transactions — there is no partial rollback

---

### Mermaid: `@fastify/redis` Integration Architecture

```
flowchart TD
    A[Fastify App] --> B[@fastify/redis plugin]
    B --> C[ioredis Client]
    C --> D[fastify.decorate redis]
    D --> E[Route Handlers / Hooks / Plugins]
    E --> F[fastify.redis.get / set / pipeline / multi ...]
    F --> G[TCP Connection Pool]
    G --> H[(Redis Server)]
    B --> I[onClose: client.quit]
```

---

### Lua Scripting with `eval` and `defineCommand`

For complex atomic operations that exceed `MULTI`/`EXEC` capabilities, Redis supports Lua scripts executed atomically on the server.

typescript

```typescript
// Atomic rate limiter script
const rateLimitScript = `
  local key = KEYS[1]
  local limit = tonumber(ARGV[1])
  local window = tonumber(ARGV[2])
  local current = redis.call('INCR', key)
  if current == 1 then
    redis.call('EXPIRE', key, window)
  end
  return current
`

fastify.get('/api/data', async (request, reply) => {
  const ip = request.ip
  const key = `ratelimit:${ip}`

  const count = await fastify.redis.eval(
    rateLimitScript,
    1,        // number of keys
    key,      // KEYS[1]
    '100',    // ARGV[1]: limit
    '60'      // ARGV[2]: window in seconds
  ) as number

  if (count > 100) {
    return reply.code(429).send({ error: 'Rate limit exceeded' })
  }

  return getData()
})
```

**Define reusable commands with `defineCommand`:**

typescript

```typescript
import { Redis } from 'ioredis'

// Extend ioredis with a custom command
declare module 'ioredis' {
  interface Redis {
    rateLimit(key: string, limit: string, window: string): Promise<number>
  }
}

redisClient.defineCommand('rateLimit', {
  numberOfKeys: 1,
  lua: rateLimitScript
})

// Usage
const count = await fastify.redis.rateLimit(key, '100', '60')
```

**Key Points:**

- Lua scripts execute atomically on the Redis server — no other commands can interleave during script execution [Inference: based on Redis documentation; atomicity is a documented guarantee of `EVAL`]
- `KEYS` and `ARGV` arrays in Lua are 1-indexed
- `defineCommand` registers a named command on the `ioredis` instance — it uses `EVALSHA` for efficiency after the first call [Inference: based on `ioredis` documentation]
- Scripts that take too long block the Redis event loop — keep Lua scripts brief [Inference]

---

### Pub/Sub Messaging

Redis Pub/Sub allows decoupled message passing between publishers and subscribers. Subscribers listen on channels; publishers send to channels without knowledge of subscribers.

typescript

```typescript
// plugins/redisPubSub.ts
import fp from 'fastify-plugin'
import { Redis } from 'ioredis'

declare module 'fastify' {
  interface FastifyInstance {
    publisher: Redis
    subscriber: Redis
  }
}

const pubSubPlugin = fp(async (fastify) => {
  // Pub/Sub requires dedicated connections
  const publisher  = new Redis({ url: process.env.REDIS_URL })
  const subscriber = new Redis({ url: process.env.REDIS_URL })

  await subscriber.subscribe('notifications', 'events')

  subscriber.on('message', (channel, message) => {
    fastify.log.info({ channel, message }, 'Redis message received')
    // Dispatch to application handlers
  })

  fastify.decorate('publisher', publisher)
  fastify.decorate('subscriber', subscriber)

  fastify.addHook('onClose', async () => {
    await subscriber.unsubscribe()
    await publisher.quit()
    await subscriber.quit()
  })
})

export default pubSubPlugin
```

**Publishing from a route:**

typescript

```typescript
fastify.post('/notify', async (request) => {
  const { userId, message } = request.body as { userId: string; message: string }

  await fastify.publisher.publish(
    'notifications',
    JSON.stringify({ userId, message, timestamp: Date.now() })
  )

  return { published: true }
})
```

**Key Points:**

- A subscribed `ioredis` connection enters a restricted mode — it can only issue subscribe/unsubscribe commands, not regular Redis commands [Inference: based on Redis protocol specification]
- Pub/Sub therefore requires at least two connections: one for subscribing, one for regular commands and publishing
- Messages are not persisted — if no subscriber is listening when a message is published, the message is lost [Inference: based on Redis Pub/Sub design; use Redis Streams for durable messaging]
- For durable, persistent messaging consider Redis Streams (`XADD`, `XREAD`) instead of Pub/Sub [Inference]

---

### Key Naming Conventions

Redis has a flat keyspace. Consistent key naming prevents collisions and enables pattern-based operations.

```
<namespace>:<entity>:<id>:<field>

Examples:
  cache:user:42
  cache:GET:/api/products
  session:abc123def456
  ratelimit:192.168.1.1
  lock:job:email-sender
  tag:products
  version:catalog
```

**Key Points:**

- Colons (`:`) are the conventional separator — Redis does not treat them specially, but many Redis GUI tools use them to build a tree view
- Keep keys short — Redis stores keys in memory; long keys increase memory usage across millions of entries [Inference]
- Avoid including user-supplied input directly in key names without sanitization — spaces, colons, and special characters can cause unexpected behavior [Inference]

---

### Connection Options Reference

typescript

```typescript
new Redis({
  host: 'localhost',
  port: 6379,
  password: process.env.REDIS_PASSWORD,
  db: 0,

  // Reconnection
  retryStrategy: (times) => Math.min(times * 50, 2_000),
  maxRetriesPerRequest: 3,

  // Timeouts
  connectTimeout: 10_000,
  commandTimeout: 5_000,

  // TLS (for Redis over SSL)
  tls: process.env.NODE_ENV === 'production' ? {} : undefined,

  // Connection name (visible in Redis CLIENT LIST)
  connectionName: 'fastify-app',

  // Keeps connection alive
  keepAlive: 30_000,

  // Suppress ready check (speeds up connection)
  enableReadyCheck: true,

  // Lazy connection
  lazyConnect: false
})
```

**Key Points:**

- `retryStrategy` returning `null` disables reconnection — the client throws on subsequent commands [Inference: based on `ioredis` documentation]
- `commandTimeout` causes commands to fail if Redis does not respond within the timeout — prevents indefinite request hangs [Inference]
- `connectionName` appears in `CLIENT LIST` output on the Redis server — aids debugging in multi-client environments [Inference]

---

### Common Patterns Summary

| Use Case | Redis Data Structure | Key Commands |
| --- | --- | --- |
| Response cache | String | `SET ... EX`, `GET`, `DEL` |
| Session storage | String or Hash | `SET ... EX`, `HSET`, `HGETALL` |
| Rate limiting | String | `INCR`, `EXPIRE` |
| Distributed lock | String | `SET ... EX NX`, `DEL` |
| Job queue | List | `RPUSH`, `BLPOP` |
| Leaderboard | Sorted Set | `ZADD`, `ZREVRANGE` |
| Tag-based cache invalidation | Set | `SADD`, `SMEMBERS`, `DEL` |
| Pub/Sub messaging | — | `PUBLISH`, `SUBSCRIBE` |
| Feature flags | Hash | `HSET`, `HGET` |
| Versioned cache namespace | String | `INCR`, `GET` |

---

**Related Topics:**

- Redis Streams (`XADD`, `XREAD`, `XGROUP`) for durable event streaming
- Redis Cluster configuration with `ioredis` Cluster client
- Redis Sentinel for high-availability failover
- Rate limiting with `@fastify/rate-limit` and its Redis store
- Session management with `@fastify/session` and a Redis store
- Keyspace notifications for reactive cache invalidation
- `ioredis-mock` for unit testing Redis-dependent code
- Redis persistence modes: RDB snapshots vs AOF logging
- Monitoring Redis with `INFO`, `MONITOR`, and Redis Insights