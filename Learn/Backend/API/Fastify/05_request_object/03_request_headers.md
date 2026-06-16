### Request Headers

Fastify exposes incoming HTTP headers through `request.headers`, a plain object populated by Node.js before Fastify's lifecycle begins. Understanding how headers are accessed, validated, mutated, and extended is essential for building middleware-style logic, authentication flows, and content negotiation.

---

#### Accessing Headers

js

```
fastify.get('/info', async (request, reply) => {
  const auth    = request.headers['authorization']
  const ct      = request.headers['content-type']
  const ua      = request.headers['user-agent']
  const xrid    = request.headers['x-request-id']

  return { auth, ct, ua, xrid }
})
```

**Key Points:**

- All header names are lowercased — this is Node.js behavior inherited by Fastify
- Access headers using bracket notation with lowercase string keys
- Missing headers return `undefined`, not `null`
- `request.headers` is a plain object, not a `Headers` instance (unlike the Fetch API)

---

#### Header Name Casing

HTTP header names are case-insensitive by spec, but Node.js normalizes them to lowercase when parsing. This means `Authorization`, `AUTHORIZATION`, and `authorization` all arrive as `'authorization'` on `request.headers`.

js

```
// Sent by client: Authorization: Bearer abc123
request.headers['authorization'] // 'Bearer abc123'
request.headers['Authorization'] // undefined
```

Always use lowercase keys when reading from `request.headers`.

---

#### Common Headers and Typical Uses

##### Authorization

js

```
fastify.addHook('preHandler', async (request, reply) => {
  const auth = request.headers['authorization']

  if (!auth || !auth.startsWith('Bearer ')) {
    return reply.code(401).send({ error: 'Unauthorized' })
  }

  const token = auth.slice(7)
  // validate token...
})
```

##### Content-Type

js

```
fastify.post('/upload', async (request, reply) => {
  const contentType = request.headers['content-type']

  if (!contentType?.includes('application/json')) {
    return reply.code(415).send({ error: 'Unsupported Media Type' })
  }

  return { body: request.body }
})
```

> [Inference] Fastify's built-in content type parser already rejects unsupported content types before the handler runs when no matching parser is registered. Manually checking `content-type` in the handler is typically only necessary for conditional logic within a handler that supports multiple types.

##### Accept

js

```
fastify.get('/data', async (request, reply) => {
  const accept = request.headers['accept']

  if (accept?.includes('text/csv')) {
    reply.header('Content-Type', 'text/csv')
    return 'id,name\n1,Alice'
  }

  return { id: 1, name: 'Alice' }
})
```

##### Custom and Forwarded Headers

js

```
fastify.get('/trace', async (request, reply) => {
  return {
    traceId:   request.headers['x-trace-id'],
    forwarded: request.headers['x-forwarded-for'],
    realIp:    request.headers['x-real-ip']
  }
})
```

---

#### Schema Validation for Headers

Fastify supports JSON Schema validation on request headers via the `headers` key in the route schema.

js

```
fastify.get('/secure', {
  schema: {
    headers: {
      type: 'object',
      required: ['authorization', 'x-api-version'],
      properties: {
        authorization:   { type: 'string' },
        'x-api-version': { type: 'string', enum: ['v1', 'v2'] }
      }
    }
  },
  handler: async (request, reply) => {
    return { version: request.headers['x-api-version'] }
  }
})
```

A request missing `authorization` or providing an unsupported `x-api-version` receives a `400` before the handler is reached.

**Key Points:**

- Header schema keys must be lowercase to match Node.js normalization
- `additionalProperties: false` is not recommended for headers — browsers and proxies frequently inject headers you do not control, and rejecting them causes unexpected failures
- Required header validation is a practical alternative to writing manual checks in hooks

---

#### Headers Are Read-Only by Convention

`request.headers` is technically mutable in JavaScript, but modifying it directly is not recommended. Mutations may not propagate reliably across hooks, and Fastify does not formally document mutation as a supported pattern.

> [Inference] If you need to attach derived values from headers to the request object — such as a decoded token or resolved user — use `decorateRequest` and populate the decorator in a hook rather than mutating `request.headers` directly. Behavior from direct mutation may vary across versions.

js

```
// Preferred pattern over mutating request.headers
fastify.decorateRequest('user', null)

fastify.addHook('preHandler', async (request, reply) => {
  const token = request.headers['authorization']?.slice(7)
  request.user = token ? decodeToken(token) : null
})
```

---

#### Accessing All Headers

To iterate over all headers or pass them along:

js

```
fastify.get('/proxy', async (request, reply) => {
  const allHeaders = request.headers

  // Forward select headers downstream
  const forwarded = {
    'x-trace-id':   allHeaders['x-trace-id'],
    'x-request-id': allHeaders['x-request-id'],
    'accept':       allHeaders['accept']
  }

  return { forwarded }
})
```

---

#### `request.raw.headers`

The raw headers object on the underlying Node.js `IncomingMessage` is the same object Fastify exposes as `request.headers`. Accessing it via `request.raw.headers` produces identical results.

js

```
request.headers === request.raw.headers // true in most cases
```

> [Unverified] Whether Fastify copies or directly references the raw headers object may differ by version. Treat them as equivalent for reading purposes, but do not rely on reference equality.

##### Raw Header Pairs via `request.raw.rawHeaders`

Node.js also exposes `rawHeaders` — an array of alternating key-value strings, preserving original casing and order, including duplicates.

js

```
fastify.get('/raw-headers', async (request, reply) => {
  return { raw: request.raw.rawHeaders }
})
```

**Output (example):**

json

```
{
  "raw": [
    "Host", "localhost:3000",
    "Authorization", "Bearer abc123",
    "X-Custom", "value"
  ]
}
```

**Key Points:**

- `rawHeaders` is useful when you need to preserve original casing or detect duplicate header names
- It is not part of Fastify's documented API — it is a Node.js `IncomingMessage` property accessed via `request.raw`

---

#### Headers in Hooks

Headers are accessible in all hooks that receive the `request` object. This makes hooks the natural place for header-based authentication, logging, and tracing.

js

```
fastify.addHook('onRequest', async (request, reply) => {
  request.log.info({
    method:  request.method,
    url:     request.url,
    traceId: request.headers['x-trace-id'] ?? 'none'
  }, 'incoming request')
})
```

js

```
fastify.addHook('preValidation', async (request, reply) => {
  const apiKey = request.headers['x-api-key']
  if (!apiKey || apiKey !== process.env.API_KEY) {
    return reply.code(403).send({ error: 'Forbidden' })
  }
})
```

---

#### `request.hostname` and `request.protocol` from Headers

These two convenience properties are derived from headers internally by Fastify:

- `request.hostname` — derived from the `Host` header (or `X-Forwarded-Host` when `trustProxy` is enabled)
- `request.protocol` — derived from the socket type, or `X-Forwarded-Proto` when `trustProxy` is enabled

js

```
fastify.get('/origin', async (request, reply) => {
  return {
    hostname: request.hostname,
    protocol: request.protocol,
    origin:   `${request.protocol}://${request.hostname}`
  }
})
```

---

#### Condensed Reference

| Access Pattern | Returns |
| --- | --- |
| `request.headers` | All headers as a lowercase-keyed object |
| `request.headers['x-key']` | Value of a single header, or `undefined` |
| `request.raw.headers` | Same object via Node.js `IncomingMessage` |
| `request.raw.rawHeaders` | Flat array of raw key-value pairs, case-preserved |
| `request.hostname` | Derived from `Host` or `X-Forwarded-Host` |
| `request.protocol` | Derived from socket or `X-Forwarded-Proto` |

---

#### Related Topics

- Schema validation — `headers` key in route schema
- `decorateRequest` for attaching header-derived data
- `trustProxy` and forwarded header behavior
- Lifecycle hooks for header-based authentication and tracing