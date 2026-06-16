## HTTP Client with undici

### What is undici

undici is the HTTP/1.1 and HTTP/2 client library built into Node.js core (available as `node:undici` from Node.js 18.13+ and as a standalone npm package for earlier versions). It was written from scratch to replace the legacy `http` module for outbound HTTP, offering significantly lower overhead, connection pooling, and a modern async API.

Fastify uses undici internally. For inter-service HTTP calls in a Fastify application, undici is the idiomatic choice.

**Key Points**

- undici is available as `node:undici` (built-in) and as the `undici` npm package — prefer the built-in where Node.js version allows
- It does not wrap the legacy `http`/`https` modules — it is an independent implementation
- undici manages persistent connection pools by default, amortizing TCP handshake cost across requests
- [Inference] Performance characteristics depend on pool configuration, request concurrency, and payload size — default settings may not be optimal for all workloads; behavior may vary

---

### Installing

bash

```bash
# As npm package (for Node.js < 18.13, or to pin a specific version)
npm install undici

# From Node.js 18.13+, no install needed:
import { request } from 'node:undici'
```

---

### Core API Surface

| Export | Purpose |
| --- | --- |
| `request` | Single-shot HTTP request with connection pooling |
| `fetch` | WHATWG Fetch-compatible API (uses undici internally) |
| `stream` | Stream response body directly to a writable |
| `pipeline` | Pipe request/response through transform streams |
| `connect` | Open a raw TCP/TLS tunnel |
| `upgrade` | HTTP upgrade (WebSocket) |
| `Pool` | Explicit connection pool to a single origin |
| `Client` | Single persistent connection to an origin |
| `Dispatcher` | Base class for custom transport/interceptor |
| `MockAgent` | In-process HTTP mocking for tests |
| `Agent` | Global dispatcher managing multiple origin pools |

---

### Basic Request

js

```js
import { request } from 'undici'

const { statusCode, headers, body } = await request(
  'https://api.example.com/users/1'
)

console.log(statusCode)          // 200
console.log(headers['content-type'])

// Body must be explicitly consumed — leaving it unconsumed leaks the connection
const data = await body.json()
console.log(data)
```

**Key Points**

- The `body` is a `Readable` stream — it must be consumed (`body.json()`, `body.text()`, `body.arrayBuffer()`) or explicitly destroyed (`body.destroy()`) on every response
- Failing to consume the body holds the connection open and blocks the pool [Inference — exact behavior depends on undici version and pool configuration]
- `body.json()` parses the response as JSON; it does not validate the Content-Type header

---

### POST, PUT, PATCH with Body

js

```js
import { request } from 'undici'

const { statusCode, body } = await request('https://api.example.com/orders', {
  method: 'POST',
  headers: {
    'content-type': 'application/json',
    'authorization': `Bearer ${token}`
  },
  body: JSON.stringify({
    userId: '123',
    items: [{ productId: 'abc', quantity: 2 }]
  })
})

if (statusCode !== 201) {
  const err = await body.json()
  throw Object.assign(new Error('Order creation failed'), {
    statusCode,
    upstream: err
  })
}

const order = await body.json()
```

**Key Points**

- `body` in the request options accepts a `string`, `Buffer`, `Uint8Array`, `Readable`, or `FormData`
- Always set `content-type` explicitly when sending a body — undici does not infer it
- Non-2xx responses do not throw by default — the caller must check `statusCode`

---

### Request Options Reference

js

```js
const { statusCode, body } = await request(url, {
  method: 'GET',                  // Default: GET
  headers: {},                    // Key-value pairs
  body: null,                     // Request body (string | Buffer | Readable)
  query: { page: 1, limit: 20 }, // Appended as query string — undici >= 5.8
  reset: false,                   // If true, closes connection after request
  signal: abortController.signal, // AbortSignal for cancellation
  headersTimeout: 30_000,         // ms to wait for response headers
  bodyTimeout: 30_000,            // ms to wait for response body
  maxRedirections: 0,             // Follow redirects (0 = do not follow)
  throwOnError: false,            // Throw on 4xx/5xx if true
  upgrade: null,                  // Protocol upgrade header value
  idempotent: true                // Whether request can be retried on socket error
})
```

**Key Points**

- `headersTimeout` and `bodyTimeout` are independent — a slow upstream can stall on body even after headers arrive
- `maxRedirections: 0` is the default — redirects are not followed unless explicitly set; set with caution as undici does not restrict redirect targets
- `throwOnError: true` causes undici to throw a `ResponseStatusCodeError` for 4xx and 5xx responses — useful for reducing status code checks [Inference — availability depends on undici version]
- `signal` integrates with the standard `AbortController` API for request cancellation

---

### Connection Pool with `Pool`

The `request` shorthand uses a global `Agent` with implicit pooling. For fine-grained control over a specific origin, use `Pool` explicitly:

js

```js
import { Pool } from 'undici'

const pool = new Pool('https://api.example.com', {
  connections: 10,          // Max concurrent connections to this origin
  pipelining: 1,            // Requests pipelined per connection (1 = no pipelining)
  keepAliveTimeout: 10_000, // ms before idle connection is closed
  keepAliveMaxTimeout: 60_000,
  connect: {
    rejectUnauthorized: true,   // TLS: reject invalid certs (default: true)
    timeout: 5_000              // TLS/TCP connection timeout
  }
})

const { statusCode, body } = await pool.request({
  path: '/users/1',
  method: 'GET',
  headers: { authorization: `Bearer ${token}` }
})

const data = await body.json()

// Destroy the pool when the service shuts down
await pool.destroy()
```

**Key Points**

- `Pool` distributes requests across `connections` persistent TCP connections — higher concurrency exhausts the pool and queues requests
- `pipelining: 0` disables pipelining entirely; `pipelining > 1` sends multiple requests per connection before receiving responses — not all servers support this correctly [Inference]
- `Pool` is per-origin — one pool per `https://hostname:port` combination; do not create a pool per request

---

### Encapsulating a Pool as a Fastify Plugin

js

```js
// plugins/httpClient.js
import fp from 'fastify-plugin'
import { Pool } from 'undici'

async function httpClientPlugin(app, opts) {
  const pools = new Map()

  function getPool(origin) {
    if (!pools.has(origin)) {
      pools.set(origin, new Pool(origin, {
        connections: opts.connections ?? 10,
        keepAliveTimeout: opts.keepAliveTimeout ?? 10_000,
        connect: {
          rejectUnauthorized: opts.rejectUnauthorized ?? true,
          timeout: opts.connectTimeout ?? 5_000
        }
      }))
    }
    return pools.get(origin)
  }

  app.decorate('http', {
    async get(url, options = {}) {
      const parsed = new URL(url)
      const pool = getPool(`${parsed.protocol}//${parsed.host}`)
      const { statusCode, body } = await pool.request({
        path: parsed.pathname + parsed.search,
        method: 'GET',
        headers: options.headers ?? {},
        signal: options.signal,
        headersTimeout: options.headersTimeout ?? 10_000,
        bodyTimeout: options.bodyTimeout ?? 30_000
      })
      return { statusCode, body }
    },

    async post(url, payload, options = {}) {
      const parsed = new URL(url)
      const pool = getPool(`${parsed.protocol}//${parsed.host}`)
      const { statusCode, body } = await pool.request({
        path: parsed.pathname + parsed.search,
        method: 'POST',
        headers: {
          'content-type': 'application/json',
          ...options.headers
        },
        body: JSON.stringify(payload),
        signal: options.signal,
        headersTimeout: options.headersTimeout ?? 10_000,
        bodyTimeout: options.bodyTimeout ?? 30_000
      })
      return { statusCode, body }
    }
  })

  app.addHook('onClose', async () => {
    await Promise.all([...pools.values()].map(p => p.destroy()))
  })
}

export default fp(httpClientPlugin)
```

js

```js
// Usage in a route
app.get('/checkout', async (request) => {
  const { statusCode, body } = await app.http.get(
    `${config.paymentsServiceUrl}/status`,
    { headers: { 'x-correlation-id': request.correlationId } }
  )

  if (statusCode !== 200) {
    const err = await body.json()
    throw app.httpErrors.badGateway('Payments service unavailable')
  }

  return body.json()
})
```

---

### `Client` for Single Persistent Connection

`Client` maintains exactly one TCP connection to an origin — appropriate for low-concurrency or ordered-request scenarios:

js

```js
import { Client } from 'undici'

const client = new Client('https://internal-service:4001', {
  keepAliveTimeout: 30_000,
  pipelining: 1
})

// Requests are serialized through one connection
const { statusCode, body } = await client.request({
  path: '/metrics',
  method: 'GET'
})

await body.text() // consume
await client.close()
```

**Key Points**

- `Client` queues requests when the connection is in use — concurrency is 1 unless pipelining is enabled
- Use `Pool` for high-concurrency workloads; `Client` for ordered or low-frequency calls
- `client.close()` waits for in-flight requests to complete; `client.destroy()` aborts them immediately

---

### Streaming Response Bodies

For large responses (file downloads, proxied content), streaming avoids buffering the entire response in memory:

js

```js
import { stream } from 'undici'
import { createWriteStream } from 'fs'

// Stream response directly to a file
await stream(
  'https://files.example.com/report.csv',
  { method: 'GET' },
  ({ statusCode, headers }) => {
    if (statusCode !== 200) {
      throw new Error(`Unexpected status: ${statusCode}`)
    }
    // Return a Writable — the body is piped into it
    return createWriteStream('/tmp/report.csv')
  }
)
```

#### Proxying a Response Through Fastify

js

```js
import { request } from 'undici'

app.get('/proxy/report', async (request, reply) => {
  const { statusCode, headers, body } = await request(
    'https://upstream.example.com/report.csv'
  )

  reply.code(statusCode)
  reply.header('content-type', headers['content-type'])
  reply.header('content-disposition', headers['content-disposition'])

  // Pipe the upstream body directly to the Fastify reply
  return reply.send(body)
})
```

**Key Points**

- `reply.send(stream)` accepts a `Readable` — Fastify pipes it to the response without buffering [Inference — verify with Fastify version for stream support]
- Do not `await body.json()` before `reply.send(body)` — consuming the body and then sending it doubles memory usage
- Set `content-length` if the upstream provides it, enabling the client to display download progress

---

### Request Cancellation with AbortController

js

```js
import { request } from 'undici'

app.get('/slow-upstream', async (req, reply) => {
  const controller = new AbortController()

  // Cancel the upstream request if the client disconnects
  req.raw.on('close', () => {
    if (!reply.sent) controller.abort()
  })

  try {
    const { statusCode, body } = await request(
      'https://slow-service.example.com/data',
      {
        signal: controller.signal,
        headersTimeout: 10_000
      }
    )
    return body.json()
  } catch (err) {
    if (err.name === 'AbortError') {
      // Client disconnected — no response needed
      req.log.info('Upstream request cancelled: client disconnected')
      return
    }
    throw err
  }
})
```

**Key Points**

- `AbortController` is the standard Web API — undici integrates with it natively
- Cancelled requests release their pool connection immediately [Inference]
- Checking `reply.sent` before aborting prevents aborting after a response has already been sent

---

### Using the WHATWG Fetch API

undici exports a `fetch` function compatible with the browser Fetch API. Node.js 18+ exposes it globally via `globalThis.fetch` (also backed by undici):

js

```js
import { fetch } from 'undici'
// Or in Node.js 18+: use globalThis.fetch directly

const response = await fetch('https://api.example.com/users', {
  method: 'POST',
  headers: { 'content-type': 'application/json' },
  body: JSON.stringify({ name: 'Alice' })
})

if (!response.ok) {
  throw new Error(`HTTP error: ${response.status}`)
}

const user = await response.json()
```

**Key Points**

- `fetch` is more portable (same API in browsers and Node.js) but offers less control than `Pool` or `Client` — no explicit pool size, timeout configuration requires `AbortController`
- `response.ok` is `true` for status codes 200–299
- `fetch` does not expose the raw connection pool — for production inter-service calls where pool tuning matters, prefer `Pool` or `request` directly
- [Inference] `globalThis.fetch` in Node.js and the `undici` npm `fetch` export may differ in minor behaviors across versions; verify against the Node.js release notes for the version in use

---

### MockAgent for Testing

`MockAgent` intercepts HTTP calls in-process — no network, no test server required:

js

```js
import { MockAgent, setGlobalDispatcher, getGlobalDispatcher } from 'undici'
import { test, before, after } from 'node:test'
import assert from 'node:assert'

let originalDispatcher

before(() => {
  originalDispatcher = getGlobalDispatcher()

  const mockAgent = new MockAgent()
  mockAgent.disableNetConnect()   // Throw on any non-mocked request
  setGlobalDispatcher(mockAgent)

  const mockPool = mockAgent.get('https://users-service')

  // Mock a specific endpoint
  mockPool
    .intercept({ path: '/users/1', method: 'GET' })
    .reply(200, { id: '1', name: 'Alice' }, {
      headers: { 'content-type': 'application/json' }
    })

  // Mock a failure response
  mockPool
    .intercept({ path: '/users/999', method: 'GET' })
    .reply(404, { error: 'Not found' }, {
      headers: { 'content-type': 'application/json' }
    })
})

after(() => {
  setGlobalDispatcher(originalDispatcher)
})

test('fetches a user successfully', async () => {
  const { statusCode, body } = await request('https://users-service/users/1')
  assert.strictEqual(statusCode, 200)
  const data = await body.json()
  assert.strictEqual(data.name, 'Alice')
})

test('handles 404 from users service', async () => {
  const { statusCode, body } = await request('https://users-service/users/999')
  assert.strictEqual(statusCode, 404)
  await body.consume() // consume even on error paths
})
```

**Key Points**

- `mockAgent.disableNetConnect()` causes any non-intercepted request to throw — prevents accidental real network calls in tests
- `MockAgent` intercepts at the dispatcher level — no monkey-patching, no network socket involved
- `intercept` can be called multiple times to mock sequences of responses
- Always restore the original dispatcher (`setGlobalDispatcher(originalDispatcher)`) after tests to avoid polluting other test suites

---

### MockAgent with Fastify inject

Combining `MockAgent` with Fastify's `inject` covers the full request path in-process:

js

```js
import Fastify from 'fastify'
import { MockAgent, setGlobalDispatcher } from 'undici'
import { test } from 'node:test'
import assert from 'node:assert'
import buildApp from '../app.js'

test('GET /orders/:id enriches with user data', async (t) => {
  const mockAgent = new MockAgent()
  mockAgent.disableNetConnect()
  setGlobalDispatcher(mockAgent)

  mockAgent
    .get('http://users-service:4001')
    .intercept({ path: '/users/42', method: 'GET' })
    .reply(200, { id: '42', name: 'Bob' }, {
      headers: { 'content-type': 'application/json' }
    })

  const app = await buildApp()
  t.after(async () => {
    await app.close()
    setGlobalDispatcher(new MockAgent()) // reset
  })

  const response = await app.inject({
    method: 'GET',
    url: '/orders/order-99',
    headers: { authorization: 'Bearer test-token' }
  })

  assert.strictEqual(response.statusCode, 200)
  const body = response.json()
  assert.strictEqual(body.user.name, 'Bob')
})
```

---

### Retry Logic with undici

undici does not include built-in retry logic — retries are the caller's responsibility:

js

```js
import { request } from 'undici'

async function requestWithRetry(url, options = {}, retryOptions = {}) {
  const {
    retries = 3,
    retryOn = [429, 503, 502],
    baseDelayMs = 100,
    maxDelayMs = 2000
  } = retryOptions

  let lastError

  for (let attempt = 1; attempt <= retries; attempt++) {
    try {
      const response = await request(url, options)

      if (retryOn.includes(response.statusCode)) {
        // Consume body to release connection before retrying
        await response.body.text()
        lastError = Object.assign(
          new Error(`Retryable status: ${response.statusCode}`),
          { statusCode: response.statusCode }
        )
      } else {
        return response
      }
    } catch (err) {
      if (err.name === 'AbortError') throw err   // Do not retry cancellations
      lastError = err
    }

    if (attempt < retries) {
      // Exponential backoff with jitter
      const delay = Math.min(baseDelayMs * 2 ** (attempt - 1), maxDelayMs)
      const jitter = Math.random() * delay * 0.2
      await new Promise(resolve => setTimeout(resolve, delay + jitter))
    }
  }

  throw lastError
}
```

**Key Points**

- The body must be consumed (`body.text()`) before retrying — not consuming it holds the connection [Inference]
- Do not retry non-idempotent methods (POST, PATCH) without explicit server-side idempotency keys — retrying a POST may create duplicate resources
- Jitter distributes retry timing across instances, reducing thundering herd on a recovering upstream [Inference]
- `AbortError` is explicitly not retried — propagate cancellations immediately

---

### Timeout Configuration Strategy

js

```js
// Conservative defaults for inter-service calls
const INTER_SERVICE_DEFAULTS = {
  headersTimeout: 5_000,    // Upstream must send headers within 5s
  bodyTimeout: 15_000       // Body must complete within 15s of headers
}

// Looser defaults for external third-party APIs
const EXTERNAL_API_DEFAULTS = {
  headersTimeout: 10_000,
  bodyTimeout: 60_000
}

// Tight defaults for health/readiness checks
const HEALTH_CHECK_DEFAULTS = {
  headersTimeout: 1_000,
  bodyTimeout: 2_000
}
```

**Key Points**

- `headersTimeout` guards against slow TTFB (time-to-first-byte) from an overloaded upstream
- `bodyTimeout` guards against stalled or slow streaming responses
- Setting both timeouts is required — setting only one leaves the other unbounded [Inference]
- Timeouts throw `HeadersTimeoutError` or `BodyTimeoutError` — catch and handle them distinctly if different behavior is needed

---

### Diagram: Connection Pool Lifecycle

Upstream ServiceConnection 2Connection 1undici PoolFastify RouteUpstream ServiceConnection 2Connection 1undici PoolFastify RouteConnections held open for next request (keep-alive)request("/users/1")request("/users/2")assign request 1assign request 2GET /users/1 (keep-alive)GET /users/2 (keep-alive)200 { id: 1 }200 { id: 2 }connection returned to poolconnection returned to poolresponses delivered

---

### Common Pitfalls

**1. Not consuming the response body**

js

```js
// WRONG — body not consumed; connection held indefinitely
const { statusCode, body } = await request(url)
if (statusCode !== 200) return // body leaked

// CORRECT — always consume or destroy
const { statusCode, body } = await request(url)
if (statusCode !== 200) {
  await body.text()  // or body.destroy()
  throw new Error(`Unexpected status: ${statusCode}`)
}
return body.json()
```

**2. Creating a new Pool per request**

js

```js
// WRONG — creates a new TCP connection every request; defeats pooling
app.get('/data', async () => {
  const pool = new Pool('https://upstream.example.com')
  const { body } = await pool.request({ path: '/data', method: 'GET' })
  return body.json()
})

// CORRECT — pool is created once (at plugin registration) and reused
app.get('/data', async () => {
  const { body } = await app.http.get('https://upstream.example.com/data')
  return body.json()
})
```

**3. Ignoring non-2xx status codes**

js

```js
// WRONG — treats all responses as success
const { body } = await request(url)
return body.json() // may parse an error body as if it were data

// CORRECT — check status before parsing
const { statusCode, body } = await request(url)
if (statusCode >= 400) {
  const err = await body.json()
  throw Object.assign(new Error('Upstream error'), { statusCode, upstream: err })
}
return body.json()
```

**4. Setting no timeouts**

js

```js
// WRONG — a stalled upstream connection holds the pool connection open indefinitely
const { body } = await request(url)

// CORRECT — always set both timeout values
const { body } = await request(url, {
  headersTimeout: 5_000,
  bodyTimeout: 15_000
})
```

---

**Related Topics**

- HTTP/2 with undici: `h2c` and TLS-based HTTP/2 client connections
- `undici` interceptors for logging, authentication headers, and retry middleware
- Proxying upstream responses with Fastify and undici streams
- `@fastify/reply-from` for transparent HTTP proxying
- Comparing undici, `node-fetch`, `axios`, and `got` for Node.js HTTP clients
- WebSocket upgrade with `undici` and Fastify
- Rate limiting outbound requests with a token bucket using undici interceptors