## ETag and Conditional Requests in Fastify

ETags (Entity Tags) and conditional requests form a precise cache validation mechanism. Rather than serving a full response body when content has not changed, the server returns `304 Not Modified` — confirming freshness without retransmitting data. This reduces bandwidth, lowers latency for clients with cached content, and decreases server processing for unchanged resources.

---

### The Problem ETags Solve

`max-age` tells a cache how long a response is fresh. Once it expires, the cache must decide whether to re-fetch. Without a validator, the only option is a full re-fetch. With an ETag, the cache sends the stored ETag back to the server — the server compares it against the current version and either confirms nothing changed (`304`) or sends the new content (`200`).

Fastify ServerClient / CacheFastify ServerClient / CacheStores response + ETagServes cached bodyUpdates cacheGET /resource200 OK + ETag: "v1" + bodyGET /resource (If-None-Match: "v1")Compute current ETag → "v1"304 Not Modified (no body)GET /resource (If-None-Match: "v1")Compute current ETag → "v2"200 OK + ETag: "v2" + new body

---

### ETag Fundamentals

An ETag is an opaque string that identifies a specific version of a resource. It is set in the `ETag` response header and echoed back by the client in `If-None-Match` on subsequent requests.

#### Strong vs Weak ETags

| Type | Format | Meaning |
| --- | --- | --- |
| Strong | `"abc123"` | Byte-for-byte identical — same octets, same encoding |
| Weak | `W/"abc123"` | Semantically equivalent — content is the same, encoding or metadata may differ |

**Key Points:**

- Strong ETags are used for byte-range requests. Weak ETags cannot be used with `If-Range`.
- Weak ETags are appropriate when the response body is semantically identical but may differ in minor ways — a gzip/identity encoding difference, a dynamically inserted timestamp, or whitespace normalization.
- ETags must be quoted strings in the header value. Unquoted ETags are invalid per the HTTP specification.

---

### Conditional Request Headers

#### Client → Server (Request Headers)

| Header | Used With | Behavior |
| --- | --- | --- |
| `If-None-Match` | `ETag` | Return `304` if resource ETag matches any listed value |
| `If-Match` | `ETag` | Return `412` if resource ETag does not match |
| `If-Modified-Since` | `Last-Modified` | Return `304` if resource not modified since this date |
| `If-Unmodified-Since` | `Last-Modified` | Return `412` if resource was modified since this date |
| `If-Range` | `ETag` or `Last-Modified` | Resume partial download only if resource unchanged |

#### Server → Client (Response Codes)

| Code | Meaning |
| --- | --- |
| `200 OK` | Resource changed — full body returned |
| `304 Not Modified` | Resource unchanged — no body, use cached copy |
| `412 Precondition Failed` | Condition in `If-Match` or `If-Unmodified-Since` not met |

---

### Manual ETag Implementation

#### Hash-Based ETag

The most reliable approach: compute a hash of the response content. The same content always produces the same ETag.

js

```js
import { createHash } from 'node:crypto'

function generateETag(content) {
  const hash = createHash('sha1')
    .update(typeof content === 'string' ? content : JSON.stringify(content))
    .digest('hex')
  return `"${hash}"`
}

fastify.get('/api/config', async (request, reply) => {
  const config = await db.getConfig()
  const etag = generateETag(config)

  if (request.headers['if-none-match'] === etag) {
    return reply.status(304).send()
  }

  reply.headers({
    'ETag': etag,
    'Cache-Control': 'public, max-age=300',
  })
  return config
})
```

#### Version-Based ETag

When records carry a version counter or updated timestamp, derive the ETag from that instead of hashing the full body — cheaper for large payloads.

js

```js
fastify.get('/articles/:id', async (request, reply) => {
  const article = await db.getArticle(request.params.id)

  if (!article) {
    return reply.status(404).send({ error: 'Not Found' })
  }

  // Use version column from database
  const etag = `"${article.id}-${article.version}"`

  if (request.headers['if-none-match'] === etag) {
    return reply.status(304).send()
  }

  reply.headers({
    'ETag': etag,
    'Cache-Control': 'public, max-age=60',
  })
  return article
})
```

**Key Points:**

- Version-based ETags are faster than hashing large bodies but require the data source to provide a reliable version signal.
- If the version counter is reset (e.g., database restore), previously issued ETags may collide with new content — include a suffix or epoch if this is a concern.

---

### Using @fastify/etag Plugin

@fastify/etag automatically generates ETags for all responses and handles `If-None-Match` comparison, reducing boilerplate significantly.

#### Installation

bash

```bash
npm install @fastify/etag
```

#### Basic Registration

js

```js
import Fastify from 'fastify'
import etag from '@fastify/etag'

const fastify = Fastify()

await fastify.register(etag)

fastify.get('/data', async () => {
  return { items: [1, 2, 3] }
})

await fastify.listen({ port: 3000 })
```

With no additional configuration, @fastify/etag computes a hash of every response body and:

- Adds the `ETag` header to the response.
- Returns `304 Not Modified` if the computed ETag matches `If-None-Match`.

#### Weak ETags

js

```js
await fastify.register(etag, { weak: true })
// ETag: W/"abc123"
```

#### Algorithm Selection

js

```js
await fastify.register(etag, {
  algorithm: 'fnv1a',  // Default: fnv1a (fast, non-cryptographic)
})
```

[Inference: @fastify/etag uses a non-cryptographic hash (fnv1a or similar) for performance rather than SHA-1 or MD5. Non-cryptographic hashes are appropriate for cache validation but should not be used for security-sensitive integrity checks.]

#### Per-Route Opt-Out

js

```js
await fastify.register(etag)

// This route skips ETag generation
fastify.get('/stream', {
  config: { etag: false },
  handler: async (request, reply) => {
    // Streaming response
  },
})
```

[Unverified: the exact config key for disabling per-route ETag varies by plugin version — consult the @fastify/etag documentation for the version in use.]

---

### `304 Not Modified` Response Rules

A `304` response must conform to specific HTTP rules:

- **No body** — the response body must be empty.
- **Same headers as the `200`** — `ETag`, `Cache-Control`, `Vary`, `Expires`, and `Last-Modified` should be repeated so the client can update its cached metadata.
- **Must not include** `Content-Length` or `Transfer-Encoding`.

js

```js
fastify.get('/resource', async (request, reply) => {
  const data = await getData()
  const etag = `"${hash(data)}"`

  const headers = {
    'ETag': etag,
    'Cache-Control': 'public, max-age=600',
    'Vary': 'Accept-Encoding',
  }

  if (request.headers['if-none-match'] === etag) {
    reply.headers(headers)           // Repeat cache headers on 304
    return reply.status(304).send()  // No body
  }

  reply.headers(headers)
  return data
})
```

---

### `If-Match` and Optimistic Concurrency

`If-Match` is used for write operations — it confirms the client is operating on the version it thinks it has before allowing a mutation. This prevents the "lost update" problem.

ServerClient BClient AServerClient BClient AGET /document/1 → ETag: "v1"GET /document/1 → ETag: "v1"PUT /document/1 (If-Match: "v1") → updates, new ETag: "v2"200 OK + ETag: "v2"PUT /document/1 (If-Match: "v1") → stale!412 Precondition Failed

#### Implementing `If-Match` in Fastify

js

```js
fastify.put('/documents/:id', async (request, reply) => {
  const doc = await db.getDocument(request.params.id)

  if (!doc) {
    return reply.status(404).send({ error: 'Not Found' })
  }

  const currentETag = `"${doc.version}"`
  const clientETag = request.headers['if-match']

  // If-Match is present, it must match
  if (clientETag && clientETag !== currentETag && clientETag !== '*') {
    return reply.status(412).send({
      statusCode: 412,
      error: 'Precondition Failed',
      message: 'Document was modified by another client. Fetch the latest version and retry.',
      currentETag,
    })
  }

  const updated = await db.updateDocument(request.params.id, request.body)
  const newETag = `"${updated.version}"`

  reply.headers({
    'ETag': newETag,
    'Cache-Control': 'no-cache',
  })
  return updated
})
```

**Key Points:**

- `If-Match: *` means "proceed if the resource exists at all," regardless of version.
- `412 Precondition Failed` is the correct response when `If-Match` fails — not `409 Conflict`, though `409` is sometimes used by convention in REST APIs.
- If `If-Match` is absent, the update proceeds without concurrency checking — the client opted out.

#### Requiring `If-Match` for All Writes

To enforce optimistic concurrency on every mutation:

js

```js
fastify.put('/documents/:id', async (request, reply) => {
  if (!request.headers['if-match']) {
    return reply.status(428).send({
      statusCode: 428,
      error: 'Precondition Required',
      message: 'If-Match header is required for updates.',
    })
  }
  // ... rest of handler
})
```

`428 Precondition Required` is the correct status code for a missing required precondition header.

---

### Combining ETag and Last-Modified

Providing both `ETag` and `Last-Modified` gives clients and caches multiple validation options. ETags take precedence over `Last-Modified` when both are present in a conditional request.

js

```js
fastify.get('/posts/:id', async (request, reply) => {
  const post = await db.getPost(request.params.id)
  const etag = `"${post.id}-${post.updatedAt.getTime()}"`
  const lastModified = post.updatedAt.toUTCString()

  // Check ETag first (takes precedence)
  if (request.headers['if-none-match'] === etag) {
    return reply.status(304)
      .headers({ 'ETag': etag, 'Last-Modified': lastModified })
      .send()
  }

  // Fall back to Last-Modified check
  const ifModifiedSince = request.headers['if-modified-since']
  if (ifModifiedSince && new Date(ifModifiedSince) >= post.updatedAt) {
    return reply.status(304)
      .headers({ 'ETag': etag, 'Last-Modified': lastModified })
      .send()
  }

  reply.headers({
    'ETag': etag,
    'Last-Modified': lastModified,
    'Cache-Control': 'public, max-age=300',
  })
  return post
})
```

---

### ETag Across Multiple Server Instances

In-memory or process-local ETag generation causes inconsistency when multiple Fastify instances serve the same route — each instance may produce a different ETag for the same resource, causing clients to re-fetch unnecessarily on each request that lands on a different instance.

#### Stable ETag Strategies for Multi-Instance Deployments

**Content hash (recommended):**
The same content always produces the same hash regardless of which instance handles the request.

js

```js
const etag = `"${createHash('sha1').update(JSON.stringify(data)).digest('hex')}"`
```

**Database version:**
Use a version column, `updated_at` timestamp, or row checksum from the database — consistent across all instances.

js

```js
const etag = `"${row.id}-${row.version}"`
```

**Avoid:**

- Incrementing counters stored in instance memory
- Using `Date.now()` at generation time rather than from the data source
- Random values regenerated on each request

---

### ETag for Collection Resources

ETags on list endpoints require a strategy for representing the aggregate version of a collection.

js

```js
fastify.get('/api/tags', async (request, reply) => {
  const tags = await db.getTags()

  // Option 1: Hash the entire serialized collection
  const etag = `"${createHash('sha1').update(JSON.stringify(tags)).digest('hex')}"`

  // Option 2: Use the max updatedAt across all items (cheaper for large sets)
  // const maxUpdated = Math.max(...tags.map(t => t.updatedAt.getTime()))
  // const etag = `"tags-${maxUpdated}"`

  // Option 3: Use a collection version counter from the database
  // const meta = await db.getCollectionMeta('tags')
  // const etag = `"tags-v${meta.version}"`

  if (request.headers['if-none-match'] === etag) {
    return reply.status(304).send()
  }

  reply.headers({
    'ETag': etag,
    'Cache-Control': 'public, max-age=120',
  })
  return tags
})
```

**Key Points:**

- Hashing the full collection is accurate but expensive for large datasets — the entire result set must be fetched and serialized to compute the hash.
- Max-timestamp strategies are cheaper but may miss deletions (if the newest item is deleted, the timestamp does not change).
- A dedicated version counter in the database (incremented on any mutation to the collection) is both cheap and accurate.

---

### ETag Hook for Consistent Application

Apply ETag logic uniformly across routes without repeating it in every handler:

js

```js
import { createHash } from 'node:crypto'

fastify.addHook('onSend', (request, reply, payload, done) => {
  // Only apply to GET/HEAD responses without an existing ETag
  if (
    !['GET', 'HEAD'].includes(request.method) ||
    reply.hasHeader('etag') ||
    reply.statusCode !== 200 ||
    typeof payload !== 'string'
  ) {
    return done(null, payload)
  }

  const etag = `"${createHash('sha1').update(payload).digest('hex')}"`
  reply.header('ETag', etag)

  if (request.headers['if-none-match'] === etag) {
    reply.status(304)
    return done(null, '')  // Empty body for 304
  }

  done(null, payload)
})
```

**Key Points:**

- The `onSend` hook receives the serialized payload as a string — hashing at this stage is accurate but means the full body has already been generated.
- Skipping non-`200` responses avoids generating ETags for error responses.
- Routes that set their own `ETag` header take precedence — the hook checks `reply.hasHeader('etag')` first.
- [Inference: behavior with streaming responses or Buffer payloads may differ — add type guards appropriate to your response types.]

---

### Testing Conditional Requests

js

```js
import { test } from 'node:test'
import assert from 'node:assert'
import Fastify from 'fastify'
import { createHash } from 'node:crypto'

async function buildApp() {
  const app = Fastify()

  const resource = { data: 'hello', version: 1 }

  app.get('/resource', async (request, reply) => {
    const etag = `"${resource.version}"`

    if (request.headers['if-none-match'] === etag) {
      return reply.status(304).header('ETag', etag).send()
    }

    reply.header('ETag', etag)
    return resource
  })

  app.put('/resource', async (request, reply) => {
    const etag = `"${resource.version}"`
    const clientETag = request.headers['if-match']

    if (clientETag && clientETag !== etag) {
      return reply.status(412).send({ error: 'Precondition Failed' })
    }

    resource.data = request.body.data
    resource.version += 1

    reply.header('ETag', `"${resource.version}"`)
    return resource
  })

  await app.ready()
  return app
}

test('returns ETag on first request', async () => {
  const app = await buildApp()
  const res = await app.inject({ method: 'GET', url: '/resource' })
  assert.ok(res.headers['etag'])
  assert.strictEqual(res.statusCode, 200)
})

test('returns 304 when ETag matches', async () => {
  const app = await buildApp()
  const first = await app.inject({ method: 'GET', url: '/resource' })
  const etag = first.headers['etag']

  const second = await app.inject({
    method: 'GET',
    url: '/resource',
    headers: { 'if-none-match': etag },
  })

  assert.strictEqual(second.statusCode, 304)
  assert.strictEqual(second.body, '')
})

test('returns 412 on stale If-Match', async () => {
  const app = await buildApp()
  const res = await app.inject({
    method: 'PUT',
    url: '/resource',
    headers: {
      'if-match': '"999"',
      'content-type': 'application/json',
    },
    body: JSON.stringify({ data: 'updated' }),
  })
  assert.strictEqual(res.statusCode, 412)
})

test('updates when If-Match is current', async () => {
  const app = await buildApp()
  const res = await app.inject({
    method: 'PUT',
    url: '/resource',
    headers: {
      'if-match': '"1"',
      'content-type': 'application/json',
    },
    body: JSON.stringify({ data: 'updated' }),
  })
  assert.strictEqual(res.statusCode, 200)
  assert.strictEqual(res.headers['etag'], '"2"')
})
```

---

### Common Pitfalls

#### Sending a Body with `304`

`304 Not Modified` must have no body. Sending one violates HTTP and may cause client parsing errors or ignored body content.

js

```js
// Incorrect
return reply.status(304).send({ message: 'not modified' })

// Correct
return reply.status(304).send()
```

#### Unquoted ETag Values

ETags must be quoted strings. An unquoted ETag is not a valid HTTP ETag.

js

```js
reply.header('ETag', 'abc123')       // Invalid
reply.header('ETag', '"abc123"')     // Valid strong ETag
reply.header('ETag', 'W/"abc123"')   // Valid weak ETag
```

#### Comparing ETags with `===`

Exact string comparison (`===`) works for simple cases but does not handle the ETag list format. `If-None-Match` may contain multiple ETags:

```
If-None-Match: "v1", "v2", "v3"
```

A robust comparison:

js

```js
function etagMatches(ifNoneMatch, etag) {
  if (!ifNoneMatch) return false
  if (ifNoneMatch === '*') return true
  return ifNoneMatch
    .split(',')
    .map(e => e.trim())
    .includes(etag)
}
```

#### Hashing Unstable Serializations

`JSON.stringify` does not guarantee property order across all JavaScript engines or versions. Two objects with the same data may serialize differently.

js

```js
// Potentially unstable
const etag = hash(JSON.stringify(obj))

// More stable: sort keys
import { createHash } from 'node:crypto'

function stableHash(obj) {
  const stable = JSON.stringify(obj, Object.keys(obj).sort())
  return createHash('sha1').update(stable).digest('hex')
}
```

[Inference: key ordering in `JSON.stringify` is consistent within a single V8 version for objects created the same way, but can vary with different insertion orders. For ETags derived from database queries, column order is usually stable — verify for your specific case.]

#### Forgetting ETag on `304` Response

The `304` response should repeat the `ETag` header so the client updates its stored validator. Omitting it means the client retains the old ETag for future requests, which is usually fine but prevents the client from updating to a new ETag format if you change your strategy.

---

**Related Topics:**

- HTTP cache headers — `Cache-Control`, `max-age`, `stale-while-revalidate`, and `Vary`
- `@fastify/etag` plugin — automatic ETag generation and `If-None-Match` handling
- `@fastify/static` — file serving with built-in ETag and `Last-Modified` support
- Optimistic concurrency in REST APIs — `If-Match`, `412`, and lost update prevention
- Range requests and `If-Range` — partial content delivery with ETag validation
- Idempotency keys — complementary pattern for safe mutation retries
- CDN cache invalidation — how ETags and surrogate keys interact with CDN purging