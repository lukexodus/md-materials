## Wrapping Fastify in Other Frameworks

In most migration scenarios, Fastify is the destination — the framework taking over from something else. However, some architectures require the inverse: embedding Fastify inside another framework, runtime, or deployment environment. This covers the patterns, constraints, and tradeoffs of using Fastify as an inner HTTP engine rather than the outermost server.

---

### When This Pattern Applies

- A legacy framework owns the HTTP server lifecycle but individual subsystems need Fastify's performance or plugin ecosystem
- Fastify is deployed as a handler inside a serverless runtime (AWS Lambda, Google Cloud Functions, Cloudflare Workers) that manages its own request/response lifecycle
- A monorepo or micro-frontend architecture routes specific path prefixes to a Fastify sub-application managed by a parent orchestrator
- A framework-agnostic HTTP adapter layer (e.g., Hono, Hapi) acts as the outer shell while Fastify handles a bounded subdomain

[Inference] This pattern is less common than migrating to Fastify as the top-level server. The added indirection introduces complexity that should be justified by a concrete architectural constraint.

---

### Core Concept — Fastify Without Its Own `listen()`

Fastify does not have to call `listen()` to process requests. The `fastify.inject()` method (used in tests) and the `fastify.routing()` / raw handler approach allow Fastify to process requests from an externally supplied Node.js HTTP server or serverless invocation.

The relevant method is:

```typescript
await fastify.ready()
fastify.server // the underlying Node.js net.Server — can be passed externally
```

Or, for handler-style usage:

```typescript
await fastify.ready()

// Pass raw Node.js req/res into Fastify's router
fastify.server.emit('request', req, res)
```

[Inference] Directly emitting `request` events on `fastify.server` is not a documented public API for production use — behavior may vary across Fastify versions. Prefer adapter libraries where they exist.

---

### Pattern 1 — Fastify Inside an Existing Node.js HTTP Server

If a parent framework already owns a `http.Server` instance, Fastify can be initialized without creating its own server by passing the existing server in:

```typescript
import http from 'http'
import Fastify from 'fastify'

// Parent owns the server
const server = http.createServer()

// Fastify uses the parent's server
const fastify = Fastify({
  serverFactory: (handler) => {
    server.on('request', handler)
    return server
  }
})

fastify.get('/fastify-route', async () => ({ source: 'fastify' }))

await fastify.ready()

server.listen(3000, () => {
  console.log('Parent server listening, Fastify routing active')
})
```

**Key Points:**
- `serverFactory` is the official Fastify API for supplying an external server instance.
- The parent server emits `request` events; Fastify registers as a handler for those events.
- The parent server controls `listen()`, `close()`, TLS, and socket configuration.
- Fastify's lifecycle hooks (`onReady`, `onClose`) still fire — but `onClose` must be triggered manually via `fastify.close()` if the parent server handles shutdown.

---

### Pattern 2 — Serverless Deployment (AWS Lambda)

Serverless runtimes do not run a persistent HTTP server. Instead, they invoke a handler function per request. The standard adapter for this is `@fastify/aws-lambda` (formerly `aws-lambda-fastify`).

```bash
npm install @fastify/aws-lambda
```

```typescript
import Fastify, { FastifyInstance } from 'fastify'
import awsLambdaFastify from '@fastify/aws-lambda'

const fastify: FastifyInstance = Fastify({ logger: true })

fastify.get('/hello', async () => ({ message: 'Hello from Lambda' }))
fastify.post('/echo', async (request) => request.body)

// Build the Lambda handler — Fastify is initialized once per cold start
const proxy = awsLambdaFastify(fastify)

// Lambda entry point
export const handler = async (event: any, context: any) => {
  await fastify.ready()
  return proxy(event, context)
}
```

**Key Points:**
- `fastify.ready()` is awaited once. On subsequent warm invocations the promise resolves immediately — Fastify does not reinitialize.
- The adapter translates the Lambda `event` object into a Fastify-compatible request and maps the Fastify response back into the Lambda response format.
- Cold start time includes Fastify plugin registration — keep the plugin tree lean for latency-sensitive Lambda functions.
- `fastify.listen()` is never called.
- [Unverified] Behavior of streaming responses, WebSocket upgrades, and long-lived connections inside Lambda is not guaranteed — Lambda's execution model has hard timeouts and does not support persistent connections in the standard invocation model.

---

### Pattern 3 — Google Cloud Functions / Cloud Run

Cloud Functions follow the same handler-per-invocation model as Lambda. Cloud Run runs a persistent container, so Fastify can call `listen()` normally there. For Cloud Functions:

```typescript
import Fastify from 'fastify'
import { HttpFunction } from '@google-cloud/functions-framework'

const fastify = Fastify({ logger: true })

fastify.get('/ping', async () => ({ pong: true }))

let isReady = false

export const gcfHandler: HttpFunction = async (req, res) => {
  if (!isReady) {
    await fastify.ready()
    isReady = true
  }

  // Emit the GCF req/res into Fastify's server
  fastify.server.emit('request', req, res)
}
```

[Inference] Manually emitting `request` events is fragile. A purpose-built adapter (similar to `@fastify/aws-lambda`) is preferable if one exists for the target runtime. Verify compatibility with the specific GCF Node.js runtime version.

---

### Pattern 4 — Fastify as a Sub-Application Inside Hapi

Hapi has its own plugin and lifecycle model. Embedding Fastify inside Hapi requires routing specific requests manually from Hapi's handler into Fastify's server using the `serverFactory` approach or `fastify.inject()`.

```typescript
import Hapi from '@hapi/hapi'
import Fastify from 'fastify'

const fastify = Fastify()
fastify.get('/internal/data', async () => ({ data: [1, 2, 3] }))
await fastify.ready()

const hapi = Hapi.server({ port: 3000 })

// Route a Hapi path to Fastify via inject
hapi.route({
  method: 'GET',
  path: '/internal/{path*}',
  handler: async (request, h) => {
    const response = await fastify.inject({
      method: request.method.toUpperCase() as any,
      url: request.path,
      headers: request.headers as any,
      payload: request.payload as any
    })

    return h.response(response.body)
      .code(response.statusCode)
      .type(response.headers['content-type'] ?? 'application/json')
  }
})

await hapi.start()
```

**Key Points:**
- `fastify.inject()` is designed for testing but technically functions for in-process request dispatch.
- This avoids network overhead — the request does not go through a TCP socket.
- Header forwarding requires care — not all headers from Hapi's request are safe or appropriate to forward.
- [Inference] Using `inject()` in production bypasses Fastify's real HTTP parsing path and may behave differently from a real HTTP request in edge cases. This pattern is not commonly recommended for production use — use the `serverFactory` approach or a reverse proxy if possible.

---

### Pattern 5 — Fastify Inside an Express Application

The inverse of the common migration direction: Express owns the server, Fastify handles specific routes.

```typescript
import express from 'express'
import http from 'http'
import Fastify from 'fastify'

const expressApp = express()
const server = http.createServer(expressApp)

const fastify = Fastify({
  serverFactory: (handler) => {
    // Do not attach to server here — we'll delegate manually
    return server
  }
})

fastify.get('/fastify/*', async (request) => ({
  handledBy: 'fastify',
  path: request.url
}))

await fastify.ready()

// Delegate specific paths to Fastify
expressApp.use('/fastify', (req, res) => {
  fastify.server.emit('request', req, res)
})

// Express handles everything else
expressApp.get('/express', (req, res) => {
  res.json({ handledBy: 'express' })
})

server.listen(3000)
```

[Inference] Route delegation via `server.emit('request', req, res)` is not an officially documented production pattern. The behavior of Fastify's router when receiving a request that has already been partially processed by Express middleware is not guaranteed. Test all delegated paths thoroughly.

---

### Pattern 6 — Cloudflare Workers

Cloudflare Workers do not run Node.js — they run a V8 isolate with a subset of Web APIs. Fastify depends on Node.js core modules (`http`, `net`, `stream`) and does not run natively in a Worker environment as of the current knowledge cutoff.

[Unverified] Projects exist that attempt to run Fastify in edge runtimes via polyfills, but compatibility and stability are not guaranteed. Hono or itty-router are purpose-built for edge runtimes and are more appropriate choices for Cloudflare Workers.

---

### `serverFactory` API — Reference

`serverFactory` is the official Fastify option for controlling server creation:

```typescript
import Fastify, { FastifyServerFactory } from 'fastify'
import https from 'https'
import fs from 'fs'

const serverFactory: FastifyServerFactory = (handler, opts) => {
  const server = https.createServer(
    {
      key: fs.readFileSync('./server.key'),
      cert: fs.readFileSync('./server.cert')
    },
    handler
  )
  return server
}

const fastify = Fastify({ serverFactory })
```

**Key Points:**
- `handler` is the function Fastify generates internally to process `request` events — pass it directly to the server constructor or attach it via `.on('request', handler)`.
- `opts` contains Fastify's internal server options — [Inference] these are primarily for Fastify's internal use and not intended for direct consumption in `serverFactory`.
- The returned server must be a `net.Server` or compatible interface.
- This is the only officially documented API for external server injection.

---

### Lifecycle Management When Wrapped

When Fastify does not own `listen()`, the consuming framework or runtime must take responsibility for:

| Responsibility | Fastify-owned | Wrapped — ownership |
|---|---|---|
| Port binding | `fastify.listen()` | Parent server / runtime |
| Graceful shutdown | `fastify.close()` | Must be called manually |
| TLS configuration | Fastify options | Parent server |
| Keep-alive / socket tuning | Fastify options | Parent server |
| `onReady` hook | Fires on `fastify.ready()` | Still fires — call explicitly |
| `onClose` hook | Fires on `fastify.close()` | Must call `fastify.close()` explicitly |

**Shutdown example when wrapped:**

```typescript
process.on('SIGTERM', async () => {
  try {
    await fastify.close() // fires onClose hooks, closes plugin resources
    parentServer.close(() => process.exit(0))
  } catch (err) {
    process.exit(1)
  }
})
```

Failing to call `fastify.close()` when the process exits may leave database connections, background timers, or plugin resources open. Behavior of individual plugins on ungraceful exit is not guaranteed.

---

### Performance Considerations

Wrapping introduces overhead relative to Fastify as the top-level server:

- **`serverFactory` pattern:** Minimal overhead — Fastify's request handler is called directly from the parent server's `request` event.
- **`inject()` in production:** Adds serialization/deserialization overhead for every request — [Inference] not suitable for high-throughput paths.
- **Serverless adapters:** Cold start latency depends on plugin registration time. Warm invocation overhead is minimal.
- **Emitting `request` manually:** [Inference] Comparable to `serverFactory` if Fastify has already been initialized, but the pattern is less predictable in terms of internal state handling.

---

### Summary — Pattern Selection

| Scenario | Recommended pattern |
|---|---|
| Serverless (Lambda) | `@fastify/aws-lambda` adapter |
| External HTTP server owns port | `serverFactory` |
| Subsystem routing from another framework | Reverse proxy (nginx) preferred; `serverFactory` if in-process |
| Development / testing | `fastify.inject()` |
| Edge runtime (Cloudflare Workers) | Do not use Fastify — use edge-native framework |
| Cloud Run / containerized | `fastify.listen()` directly — no wrapping needed |

---

**Related Topics:**
- `fastify.inject()` — in-process request dispatch for testing
- Graceful shutdown and `onClose` hooks
- Serverless cold start optimization — plugin registration strategies
- `@fastify/aws-lambda` configuration and binary media types
- `serverFactory` with TLS — HTTPS and HTTP/2 setup
- Fastify with HTTP/2 — `http2: true` and ALPN negotiation
- Reverse proxy configuration for Fastify — `trustProxy` and forwarded headers