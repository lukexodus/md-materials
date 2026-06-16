## Response Caching with Plugins

Response caching is the practice of storing the output of a route handler and returning that stored output for subsequent identical requests — bypassing handler execution entirely or partially. In Fastify, this is typically achieved via plugins that hook into the request/reply lifecycle.

---

### Why Cache Responses

Without caching, every request triggers the full handler pipeline: database queries, computation, serialization. For data that changes infrequently, this is wasteful.

Caching trades memory or storage for reduced latency and reduced backend load. The tradeoff is staleness: cached data may not reflect the latest state.

**Key Points:**

- Caching is appropriate for read-heavy, infrequently changing data
- It is inappropriate for responses that are user-specific, highly dynamic, or sensitive
- Cache invalidation — deciding when to discard stored data — is the primary operational challenge [Inference: based on general caching theory; specific behavior depends on implementation]

---

### How Fastify Plugins Enable Caching

Fastify does not include a built-in response cache. Plugins integrate caching by intercepting the request/reply lifecycle using Fastify's hooks (`onRequest`, `onSend`, `preParsing`, etc.) and decorators.

The general pattern:

1. On incoming request, compute a cache key (typically from URL, method, query params)
2. Check the cache store for a hit
3. If hit: reply immediately with cached data, skip the handler
4. If miss: allow the handler to run, then store the response before sending

```
Request
  │
  ▼
[onRequest hook] → Cache hit? ──Yes──▶ Reply with cached data
  │
  No
  │
  ▼
Route Handler executes
  │
  ▼
[onSend hook] → Store response in cache
  │
  ▼
Reply to client
```

---

### @fastify/caching

`@fastify/caching` is the officially scoped plugin for HTTP cache-control semantics. Its primary purpose is managing **HTTP caching headers** (`Cache-Control`, `ETag`, `Last-Modified`) rather than server-side storage.

**Installation:**

bash

```bash
npm install @fastify/caching
```

**Registration:**

typescript

```typescript
import Fastify from 'fastify'
import caching from '@fastify/caching'

const fastify = Fastify()

await fastify.register(caching, {
  privacy: caching.privacy.PUBLIC,
  expiresIn: 300, // seconds
  serverExpiresIn: 300
})
```

**Usage in a route:**

typescript

```typescript
fastify.get('/products', async (request, reply) => {
  reply.etag('products-v1')
  reply.expires(new Date(Date.now() + 300_000))

  return { products: [] }
})
```

**Key Points:**

- `reply.etag(value)` sets the `ETag` header; clients can use this for conditional `GET` requests
- `reply.expires(date)` sets the `Expires` header
- `privacy` controls whether `Cache-Control` is `public` or `private`
- This plugin instructs HTTP clients and intermediary proxies on caching behavior — it does **not** store responses server-side
- Actual caching occurs in the client or CDN layer [Inference: based on HTTP caching specification behavior; actual caching depends on client/proxy implementation]

**`onRequest` hook behavior:** The plugin also decorates the request with `cacheability` and `now` properties for conditional request processing.

---

### @fastify/reply-from and Proxy-Layer Caching

[Inference] When Fastify acts as a reverse proxy using `@fastify/reply-from`, caching can be layered at the proxy boundary. This is an architectural pattern rather than a dedicated cache plugin feature.

---

### Server-Side Response Caching with @fastify/cache (Community)

For actual server-side storage of response bodies, the community plugin `fastify-cache` and similar plugins extend the pattern. However, the most widely documented approach uses `@fastify/redis` or `ioredis` directly within a custom caching plugin.

**[Unverified]:** There is no single official Fastify plugin that provides out-of-the-box server-side response body caching with a storage backend as of the last verified documentation. Implementations are typically custom or community-maintained. Verify against the current Fastify plugin ecosystem before use.

---

### Building a Server-Side Cache Plugin with Redis

A common production pattern is a custom plugin using Redis as the cache store.

**Plugin structure:**

typescript

```typescript
// plugins/responseCache.ts
import fp from 'fastify-plugin'
import type { FastifyPluginAsync } from 'fastify'

interface CacheOptions {
  ttl: number // seconds
}

const responseCachePlugin: FastifyPluginAsync<CacheOptions> = async (fastify, options) => {
  const { ttl } = options

  fastify.addHook('onRequest', async (request, reply) => {
    if (request.method !== 'GET') return

    const key = `cache:${request.url}`
    const cached = await fastify.redis.get(key)

    if (cached) {
      reply.header('x-cache', 'HIT')
      reply.header('content-type', 'application/json')
      reply.send(JSON.parse(cached))
    }
  })

  fastify.addHook('onSend', async (request, reply, payload) => {
    if (request.method !== 'GET') return payload
    if (reply.getHeader('x-cache') === 'HIT') return payload

    const key = `cache:${request.url}`

    if (typeof payload === 'string') {
      await fastify.redis.setex(key, ttl, payload)
    }

    reply.header('x-cache', 'MISS')
    return payload
  })
}

export default fp(responseCachePlugin)
```

**Registration:**

typescript

```typescript
await fastify.register(import('./plugins/redis'))         // registers fastify.redis
await fastify.register(import('./plugins/responseCache'), { ttl: 60 })
```

**Key Points:**

- `onRequest` checks the cache before the handler runs; if a hit is found, `reply.send()` is called and the handler is bypassed
- `onSend` receives the serialized payload and stores it; at this point serialization has already occurred
- `fastify-plugin` (`fp`) is used to avoid plugin encapsulation, making the cache hook apply globally [Inference: based on documented `fastify-plugin` behavior; scope depends on where registration occurs]
- Storing `payload` in `onSend` means you are storing the already-serialized JSON string, which avoids re-serialization cost on cache hits

**[Inference]:** Calling `reply.send()` inside `onRequest` causes Fastify to skip subsequent lifecycle hooks including the route handler. This behavior is consistent with Fastify's documented hook short-circuit mechanism but may vary with future versions.

---

### Cache Key Design

A cache key must uniquely identify a cacheable response. Poor key design leads to either cache collisions (wrong data served) or excessive cache fragmentation (low hit rate).

**Factors to include in a cache key:**

| Factor | When to Include |
| --- | --- |
| URL path | Always |
| Query string | When query params affect response |
| `Accept` header | When content negotiation is used |
| User identity | Never (turns cache into per-user store; defeats purpose) |
| API version | When versioning affects response shape |

**Example — composite key:**

typescript

```typescript
const key = `cache:${request.method}:${request.url}:${request.headers['accept'] ?? 'json'}`
```

**Key Points:**

- Including user-specific data in keys creates unbounded key spaces and potential data leakage between users
- Query string inclusion must be consistent — normalize parameter order if clients send params in varying order [Inference]

---

### TTL Strategy

TTL (time-to-live) defines how long a cached response is considered valid.

typescript

```typescript
// Short TTL for frequently updated data
await redis.setex(key, 10, payload)  // 10 seconds

// Long TTL for static reference data
await redis.setex(key, 3600, payload) // 1 hour
```

**Considerations:**

- There is no universally correct TTL. It depends on how frequently the underlying data changes and how much staleness is acceptable [Inference]
- Overly long TTLs increase the risk of serving outdated data
- Overly short TTLs reduce cache effectiveness
- TTL can be set per-route rather than globally by checking `request.routeOptions.url` [Inference: based on Fastify's route context availability in hooks; verify against your Fastify version]

---

### Cache Invalidation

Storing responses is straightforward. Knowing when to discard them is not. Fastify plugins do not provide automatic invalidation based on data mutations — this must be implemented explicitly.

**Common strategies:**

**Time-based expiry (TTL):** Simplest approach. Cache expires automatically. No explicit invalidation needed, but data may be stale for the TTL duration.

**Event-based invalidation:** On a `POST`/`PUT`/`DELETE` that mutates data, explicitly delete related cache keys.

typescript

```typescript
fastify.post('/products', async (request, reply) => {
  const result = await createProduct(request.body)

  // Invalidate the product list cache
  await fastify.redis.del('cache:GET:/products')

  return result
})
```

**Tag-based invalidation (pattern delete):** Group related keys under a tag pattern, then delete by pattern.

typescript

```typescript
// Invalidate all product-related cache entries
const keys = await fastify.redis.keys('cache:*:/products*')
if (keys.length > 0) {
  await fastify.redis.del(...keys)
}
```

**[Inference]:** `redis.keys()` with a wildcard pattern is a blocking operation and is not recommended for production use on large keyspaces. Use `SCAN` with cursor iteration instead for production invalidation. Behavior depends on Redis version and configuration.

**SCAN-based invalidation:**

typescript

```typescript
async function deleteByPattern(redis: any, pattern: string): Promise<void> {
  let cursor = '0'
  do {
    const [nextCursor, keys] = await redis.scan(cursor, 'MATCH', pattern, 'COUNT', 100)
    cursor = nextCursor
    if (keys.length > 0) {
      await redis.del(...keys)
    }
  } while (cursor !== '0')
}
```

---

### Conditional Requests and ETags

HTTP provides a mechanism for clients to validate whether their cached copy is still current — conditional requests.

**Flow:**

1. Server responds with `ETag: "abc123"`
2. Client stores the ETag alongside the cached response
3. On next request, client sends `If-None-Match: "abc123"`
4. Server computes the current ETag:
   - If unchanged: responds with `304 Not Modified` (no body)
   - If changed: responds with `200` and new body + new ETag

**With `@fastify/caching`:**

typescript

```typescript
fastify.get('/config', async (request, reply) => {
  const config = await getConfig()
  const etag = computeHash(config) // e.g., md5 or sha256 of content

  reply.etag(etag)

  // @fastify/caching checks If-None-Match automatically
  // If matched, it sends 304 without hitting your return statement
  return config
})
```

**Key Points:**

- `304 Not Modified` responses save bandwidth — no body is transmitted
- ETag computation must be deterministic for the same content [Inference: required for correctness; behavior depends on your hash function]
- `@fastify/caching` handles the `If-None-Match` comparison and short-circuits automatically [Unverified: verify this behavior against current `@fastify/caching` documentation, as plugin internals may change]

---

### Route-Level Cache Control

Rather than applying caching globally, routes can set their own cache semantics.

**Using decorators and per-route options:**

typescript

```typescript
fastify.get('/static-assets', {
  config: { cache: { ttl: 86400 } }  // 1 day
}, async (request, reply) => {
  return getStaticData()
})

fastify.get('/live-feed', {
  config: { cache: { ttl: 0 } }  // No cache
}, async (request, reply) => {
  return getLiveData()
})
```

**Reading config in the hook:**

typescript

```typescript
fastify.addHook('onRequest', async (request, reply) => {
  const cacheConfig = (request.routeOptions as any).config?.cache
  if (!cacheConfig || cacheConfig.ttl === 0) return

  const key = `cache:${request.url}`
  const cached = await fastify.redis.get(key)
  if (cached) {
    reply.send(JSON.parse(cached))
  }
})
```

**[Inference]:** `request.routeOptions` availability and shape may differ between Fastify versions. Verify against your installed version's type definitions.

---

### Caching and Fastify's Serialization

Fastify serializes route return values using `fast-json-stringify` before sending. In the `onSend` hook, `payload` is already the serialized string.

**Implication:** Storing `payload` in `onSend` stores the final serialized output. On cache hit, this string is returned directly — bypassing serialization entirely.

**Key Points:**

- This is more efficient than storing raw objects and re-serializing
- If your serialization schema changes, cached responses may be in the old format until TTL expires — manual invalidation may be necessary [Inference]
- Content-type headers must be set correctly on cache-hit replies (typically `application/json`) since Fastify's serialization pipeline is bypassed

---

### What Not to Cache

Not all responses are candidates for caching.

| Response Type | Cache? | Reason |
| --- | --- | --- |
| User-specific data | No | Would leak data between users |
| Authentication responses | No | Security-sensitive |
| `POST`/`PUT`/`DELETE` responses | Typically no | Mutating operations |
| Paginated queries | With caution | Include page params in key |
| File uploads / streams | No | Not suitable for string storage |
| Responses with `Set-Cookie` | No | Session data must not be cached |

---

### Mermaid: Full Caching Lifecycle

DBHandlerCacheFastifyClientDBHandlerCacheFastifyClientalt[Cache HIT][Cache MISS]GET /productsGET cache:GET:/productscached JSON string200 OK (x-cache: HIT)nullexecute route handlerquerydataresponse objectSETEX cache:GET:/products TTL payload200 OK (x-cache: MISS)

---

### Scoping: Applying Cache to Specific Routes Only

Use Fastify's plugin encapsulation to scope caching to a subset of routes.

typescript

```typescript
// Only routes registered inside this block are cached
fastify.register(async (instance) => {
  instance.addHook('onRequest', cacheCheckHook)
  instance.addHook('onSend', cacheStoreHook)

  instance.get('/products', handler)
  instance.get('/categories', handler)
}, { prefix: '/api/v1' })

// Routes outside this block are unaffected
fastify.get('/health', async () => ({ status: 'ok' }))
```

**Key Points:**

- Plugin encapsulation means hooks registered on a child instance do not affect the parent or sibling scopes
- `fastify-plugin` unwraps encapsulation — do not use `fp()` if you want scoped caching [Inference: based on documented `fastify-plugin` behavior]

---

**Related Topics:**

- Cache warming strategies (pre-populating cache on startup)
- Distributed caching with Redis Cluster
- HTTP `Vary` header and content negotiation caching
- `stale-while-revalidate` patterns in Fastify
- Cache stampede prevention (mutex/lock patterns on cache miss)
- `@fastify/redis` plugin setup and decoration
- Response compression combined with caching (`@fastify/compress`)
- Cache metrics and observability (hit rate, miss rate, eviction tracking)