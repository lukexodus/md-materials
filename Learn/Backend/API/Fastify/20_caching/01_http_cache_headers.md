## HTTP Cache Headers in Fastify

HTTP caching controls whether browsers and intermediate caches (CDNs, proxies) may store and reuse responses. Correctly configured cache headers reduce server load, decrease latency for returning users, and lower bandwidth consumption. Misconfigured headers cause stale content, privacy leaks, or unnecessary revalidation round-trips. Fastify provides direct access to response headers, giving full control over caching behavior.

---

### How HTTP Caching Works

```
flowchart TD
    A[Client makes request] --> B{Response in cache?}
    B -- No --> C[Forward to origin server]
    C --> D[Server responds with headers]
    D --> E{Cacheable?}
    E -- Yes --> F[Store in cache]
    F --> G[Return response to client]
    E -- No --> G
    B -- Yes --> H{Cache still fresh?}
    H -- Yes --> I[Return cached response directly]
    H -- No --> J{Has ETag or Last-Modified?}
    J -- Yes --> K[Conditional request to origin]
    K -- L{304 Not Modified?}
    L -- Yes --> M[Update cache metadata, return cached body]
    L -- No --> D
    J -- No --> C
```

---

### Cache Header Overview

| Header | Direction | Purpose |
| --- | --- | --- |
| `Cache-Control` | Response (and Request) | Primary caching instructions |
| `Expires` | Response | Absolute expiry time (legacy) |
| `ETag` | Response | Opaque validator for conditional requests |
| `Last-Modified` | Response | Timestamp validator for conditional requests |
| `If-None-Match` | Request | Conditional GET using ETag |
| `If-Modified-Since` | Request | Conditional GET using timestamp |
| `Vary` | Response | Declares which request headers affect the cached response |
| `Age` | Response | Time in seconds the response has been in a proxy cache |
| `Pragma` | Response | Legacy HTTP/1.0 no-cache (largely obsolete) |

---

### Cache-Control Directives

`Cache-Control` is the authoritative caching header in HTTP/1.1. It accepts one or more comma-separated directives.

#### Response Directives

| Directive | Effect |
| --- | --- |
| `max-age=<seconds>` | Cache is fresh for this many seconds from the response date |
| `s-maxage=<seconds>` | Overrides `max-age` for shared caches (CDNs, proxies) |
| `no-cache` | Cache may store the response but must revalidate before each use |
| `no-store` | Cache must not store the response at all |
| `private` | Only the end-user's browser may cache; shared caches must not |
| `public` | Any cache may store the response, even if normally non-cacheable |
| `must-revalidate` | Once stale, the cache must revalidate before serving |
| `proxy-revalidate` | Like `must-revalidate` but for shared caches only |
| `immutable` | Content will never change during `max-age` — skip revalidation |
| `stale-while-revalidate=<seconds>` | Serve stale while revalidating in background |
| `stale-if-error=<seconds>` | Serve stale if origin returns error |
| `no-transform` | Intermediaries must not transform the response body |

#### Common Combinations

```
Cache-Control: no-store
```

Sensitive data — never cache.

```
Cache-Control: no-cache
```

Always revalidate — cache may store but must check freshness before use.

```
Cache-Control: private, max-age=300
```

Cache in browser only, fresh for 5 minutes.

```
Cache-Control: public, max-age=3600
```

Any cache may store, fresh for 1 hour.

```
Cache-Control: public, max-age=31536000, immutable
```

Static asset with content hash in URL — cache for 1 year, never revalidate.

```
Cache-Control: public, max-age=0, must-revalidate
```

Cache may store but must revalidate every time — equivalent to `no-cache` in practice.

```
Cache-Control: public, s-maxage=86400, stale-while-revalidate=3600
```

CDN caches for 24 hours; after expiry, serves stale for up to 1 hour while fetching fresh.

---

### Setting Cache Headers in Fastify

Fastify does not set `Cache-Control` by default. All caching headers must be set explicitly.

#### Setting Headers Directly on a Reply

js

```js
fastify.get('/article/:id', async (request, reply) => {
  const article = await db.getArticle(request.params.id)

  reply.header('Cache-Control', 'public, max-age=300, stale-while-revalidate=60')
  return article
})
```

#### Using `reply.header` vs `reply.headers`

js

```js
// Single header
reply.header('Cache-Control', 'no-store')

// Multiple headers at once
reply.headers({
  'Cache-Control': 'public, max-age=3600',
  'Vary': 'Accept-Encoding',
})
```

---

### Common Caching Patterns

#### Static Assets (Hashed Filenames)

When asset filenames include a content hash (e.g., `app.a1b2c3.js`), the content is guaranteed to change with the filename. Cache aggressively.

js

```js
fastify.get('/static/:file', async (request, reply) => {
  const content = await readFile(`./public/${request.params.file}`)
  reply.headers({
    'Cache-Control': 'public, max-age=31536000, immutable',
    'Content-Type': 'application/javascript',
  })
  return reply.send(content)
})
```

**Key Points:**

- `immutable` tells browsers not to revalidate during `max-age`, skipping the conditional request entirely.
- Only use `immutable` when the URL itself changes with the content (cache-busting URLs). Applying it to mutable URLs causes stale content to be served.

#### HTML Pages (Frequently Updated)

js

```js
fastify.get('/', async (request, reply) => {
  reply.header('Cache-Control', 'public, max-age=0, must-revalidate')
  return reply.view('index.html')
})
```

Or equivalently:

js

```js
reply.header('Cache-Control', 'no-cache')
```

#### API Responses (Short-Lived)

js

```js
fastify.get('/api/summary', async (request, reply) => {
  const data = await getSummary()
  reply.header('Cache-Control', 'private, max-age=60')
  return data
})
```

#### Sensitive Data (Never Cache)

js

```js
fastify.get('/api/account', async (request, reply) => {
  const account = await getAccount(request.user.id)
  reply.header('Cache-Control', 'no-store')
  return account
})
```

#### CDN-Cached API with Stale Fallback

js

```js
fastify.get('/api/products', async (request, reply) => {
  const products = await getProducts()
  reply.header(
    'Cache-Control',
    'public, s-maxage=3600, stale-while-revalidate=600, stale-if-error=86400'
  )
  return products
})
```

**Key Points:**

- `s-maxage=3600` — CDN caches for 1 hour.
- `stale-while-revalidate=600` — CDN may serve stale for 10 minutes while fetching fresh.
- `stale-if-error=86400` — if the origin fails, CDN may serve stale for up to 24 hours.
- Browser behavior with `stale-while-revalidate` and `stale-if-error` varies by implementation. [Inference: these directives are well-supported in major CDNs but browser support is less consistent.]

---

### ETags and Conditional Requests

An ETag is an opaque identifier for a specific version of a resource. When the client has a cached response with an ETag, it sends `If-None-Match` on the next request. If the resource has not changed, the server returns `304 Not Modified` with no body — saving bandwidth.

#### Setting an ETag Manually

js

```js
import { createHash } from 'node:crypto'

fastify.get('/api/config', async (request, reply) => {
  const config = await getConfig()
  const body = JSON.stringify(config)

  const etag = `"${createHash('sha1').update(body).digest('hex')}"`

  // Check If-None-Match
  if (request.headers['if-none-match'] === etag) {
    return reply.status(304).send()
  }

  reply.headers({
    'ETag': etag,
    'Cache-Control': 'public, max-age=300',
  })
  return reply.send(body)
})
```

**Key Points:**

- ETags must be quoted strings in the header: `"abc123"` not `abc123`.
- A strong ETag (quoted string) indicates byte-for-byte equivalence. A weak ETag (`W/"abc123"`) indicates semantic equivalence.
- `304 Not Modified` responses must not include a body but should include the same headers (`ETag`, `Cache-Control`) as the original `200`.

#### Weak ETags

js

```js
const etag = `W/"${createHash('md5').update(lastModifiedTimestamp).digest('hex')}"`
reply.header('ETag', etag)
```

Use weak ETags when the content is semantically equivalent but not byte-for-byte identical (e.g., response body includes a dynamically generated timestamp).

---

### Last-Modified and If-Modified-Since

`Last-Modified` provides a timestamp-based alternative to ETags.

js

```js
fastify.get('/document/:id', async (request, reply) => {
  const doc = await getDocument(request.params.id)
  const lastModified = new Date(doc.updatedAt).toUTCString()

  // Check If-Modified-Since
  const ifModifiedSince = request.headers['if-modified-since']
  if (ifModifiedSince && new Date(ifModifiedSince) >= new Date(doc.updatedAt)) {
    return reply.status(304).send()
  }

  reply.headers({
    'Last-Modified': lastModified,
    'Cache-Control': 'public, max-age=600',
  })
  return doc
})
```

**Key Points:**

- `Last-Modified` values must be in HTTP date format: `Thu, 01 Jan 2026 00:00:00 GMT`.
- `If-Modified-Since` comparisons use seconds precision — sub-second changes are not detectable.
- ETags are generally preferred over `Last-Modified` when both are feasible, as they are more precise and not subject to clock skew. Using both together is valid and provides maximum compatibility.

---

### The `Vary` Header

`Vary` tells caches that the response may differ depending on specific request headers. A cache must store separate entries for each distinct combination of the listed headers.

js

```js
// Response varies by encoding — caches store compressed and uncompressed separately
reply.header('Vary', 'Accept-Encoding')

// Response varies by authorization — each user gets their own cached version
reply.header('Vary', 'Authorization')

// Multiple fields
reply.header('Vary', 'Accept-Encoding, Accept-Language')
```

**Key Points:**

- `Vary: *` tells caches the response varies in a way that cannot be described — effectively disabling caching at shared caches.
- `Vary: Authorization` is important for authenticated endpoints cached at a CDN. Without it, a CDN may serve one user's response to another.
- `Vary: Accept-Encoding` is commonly set automatically by compression middleware. Confirm whether your setup (e.g., @fastify/compress) handles this automatically.

---

### Global Cache Headers via Hooks

Apply a default `Cache-Control` policy across all routes using an `onSend` hook, with per-route overrides:

js

```js
fastify.addHook('onSend', (request, reply, payload, done) => {
  // Only set default if not already defined by the route
  if (!reply.hasHeader('cache-control')) {
    reply.header('Cache-Control', 'no-store')
  }
  done()
})

// This route overrides the default
fastify.get('/api/public-data', async (request, reply) => {
  reply.header('Cache-Control', 'public, max-age=60')
  return { data: [] }
})

// This route inherits no-store from the hook
fastify.get('/api/user', async (request, reply) => {
  return { user: request.user }
})
```

**Key Points:**

- `reply.hasHeader('cache-control')` (lowercase) checks for a previously set header.
- The `onSend` hook fires just before the response is sent, after route handlers complete.
- This is a safe default-deny approach: routes explicitly opt into caching rather than caching by accident.

---

### Decorating Routes with Cache Metadata

A structured approach: declare caching intent in route config and apply headers centrally.

js

```js
// Plugin that reads route config and applies headers
fastify.addHook('onSend', (request, reply, payload, done) => {
  const routeConfig = request.routeOptions?.config ?? {}
  const cacheConfig = routeConfig.cache

  if (cacheConfig === false || cacheConfig === undefined) {
    if (!reply.hasHeader('cache-control')) {
      reply.header('Cache-Control', 'no-store')
    }
  } else if (typeof cacheConfig === 'string') {
    reply.header('Cache-Control', cacheConfig)
  }

  done()
})

// Routes declare their own cache policy
fastify.get('/products', {
  config: { cache: 'public, max-age=300, stale-while-revalidate=60' },
  handler: async () => ({ products: [] }),
})

fastify.get('/profile', {
  config: { cache: false },  // Explicitly no-store
  handler: async (request) => ({ user: request.user }),
})
```

---

### Cache-Control with @fastify/static

When using @fastify/static to serve files, configure caching via the `maxAge` option:

js

```js
import fastifyStatic from '@fastify/static'
import { join } from 'node:path'

await fastify.register(fastifyStatic, {
  root: join(import.meta.dirname, 'public'),
  prefix: '/assets/',
  maxAge: '1y',           // 1 year in ms or string (parsed by the plugin)
  immutable: true,        // Adds immutable directive
  etag: true,             // ETag generation (default: true)
  lastModified: true,     // Last-Modified header (default: true)
})
```

**Key Points:**

- @fastify/static handles ETag and `Last-Modified` generation automatically for files.
- `maxAge` accepts milliseconds or a string like `'1d'`, `'1y'` depending on the plugin version. [Unverified: string format support may vary — check the version's documentation.]
- `immutable: true` appends the `immutable` directive to `Cache-Control`.

---

### Cache-Control with Compression

When using @fastify/compress, compressed responses must be cached separately from uncompressed ones:

js

```js
await fastify.register(compress, { global: true })

fastify.get('/data', async (request, reply) => {
  reply.headers({
    'Cache-Control': 'public, max-age=3600',
    'Vary': 'Accept-Encoding',   // Critical: separate cache entries per encoding
  })
  return largeDataset
})
```

[Inference: @fastify/compress may set `Vary: Accept-Encoding` automatically. Verify whether your version does so to avoid setting it redundantly or omitting it where needed.]

---

### `Expires` Header (Legacy)

`Expires` predates `Cache-Control` and specifies an absolute expiry date. It is obsolete for most purposes — `Cache-Control: max-age` is preferred. If both are present, `Cache-Control` takes precedence in HTTP/1.1.

js

```js
const expires = new Date(Date.now() + 3600 * 1000).toUTCString()
reply.header('Expires', expires)
```

Setting `Expires` to a past date is equivalent to `no-cache` in HTTP/1.0 clients. Avoid `Expires` in new implementations unless supporting very old HTTP/1.0 intermediaries is required.

---

### Preventing Caching of Authenticated Content at CDNs

A common misconfiguration is caching authenticated API responses at a CDN, causing one user's data to be served to another.

js

```js
// Dangerous — CDN may cache and serve to any user
reply.header('Cache-Control', 'public, max-age=60')

// Safe — CDN does not cache; browser may cache for 60s
reply.header('Cache-Control', 'private, max-age=60')

// Safest for sensitive data
reply.header('Cache-Control', 'no-store')
```

**Key Points:**

- `public` does not mean "publicly accessible" — it means "any cache may store this."
- `private` means only the end-user's browser may cache — shared caches (CDNs, proxies) must not.
- When in doubt, use `no-store` for any response containing user-specific or sensitive data.

---

### Testing Cache Headers

js

```js
import { test } from 'node:test'
import assert from 'node:assert'
import Fastify from 'fastify'

test('sets correct Cache-Control for public endpoint', async () => {
  const app = Fastify()

  app.get('/products', async (request, reply) => {
    reply.header('Cache-Control', 'public, max-age=300')
    return { products: [] }
  })

  await app.ready()

  const res = await app.inject({ method: 'GET', url: '/products' })
  assert.strictEqual(res.headers['cache-control'], 'public, max-age=300')
})

test('returns 304 when ETag matches', async () => {
  const app = Fastify()

  app.get('/item', async (request, reply) => {
    const etag = '"abc123"'
    if (request.headers['if-none-match'] === etag) {
      return reply.status(304).send()
    }
    reply.header('ETag', etag)
    return { item: 'data' }
  })

  await app.ready()

  const res = await app.inject({
    method: 'GET',
    url: '/item',
    headers: { 'if-none-match': '"abc123"' },
  })

  assert.strictEqual(res.statusCode, 304)
})
```

---

### Common Pitfalls

#### Caching Error Responses

Error responses (4xx, 5xx) can be cached if `Cache-Control` is not explicitly set. A CDN caching a `500` response will serve it to all users until it expires.

js

```js
fastify.setErrorHandler((error, request, reply) => {
  reply.header('Cache-Control', 'no-store')
  reply.status(error.statusCode ?? 500).send({ error: error.message })
})
```

#### Missing `Vary` on Content-Negotiated Responses

If your response body varies by `Accept`, `Accept-Language`, or `Accept-Encoding` but `Vary` is not set, caches may serve the wrong variant.

#### `no-cache` Is Not `no-store`

`no-cache` permits storage but requires revalidation. `no-store` forbids storage entirely. These are frequently confused.

| Intent | Correct Directive |
| --- | --- |
| "Never store this" | `no-store` |
| "Store but always revalidate" | `no-cache` |
| "Store for N seconds, then revalidate" | `max-age=N, must-revalidate` |

#### ETag Inconsistency Across Instances

If ETag generation is based on in-memory state or process-specific data, different server instances may produce different ETags for the same resource, causing unnecessary revalidation in multi-instance deployments. Base ETags on stable, shared data (database record version, content hash).

#### `immutable` on Mutable URLs

`immutable` tells browsers to never revalidate during `max-age`. On a URL that can return different content (no cache-busting), this causes stale content to be served for the full `max-age` duration even after updates.

---

**Related Topics:**

- `@fastify/static` — serving files with automatic ETag and `Last-Modified` support
- `@fastify/compress` — compression middleware and its interaction with `Vary`
- CDN integration — configuring Fastify responses for Cloudflare, CloudFront, and Fastly
- Stale-while-revalidate patterns — background revalidation strategies at the application layer
- Cache invalidation strategies — purging CDN caches on content updates
- `@fastify/etag` plugin — automatic ETag generation for Fastify responses
- HTTP conditional requests — deep dive into `If-Match`, `If-Unmodified-Since`, range requests
- Service Workers and browser caching — client-side caching layered on top of HTTP headers