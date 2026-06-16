### Request ID and Logging Integration

Fastify assigns a unique identifier to every incoming request and automatically threads it through the request-scoped logger. This pairing — request ID plus structured logging — is one of Fastify's most production-relevant built-in features, enabling full traceability across a request's lifecycle without manual instrumentation.

---

#### `request.id`

Every request processed by Fastify is assigned an ID, accessible as `request.id`.

js

```
fastify.get('/ping', async (request, reply) => {
  return { requestId: request.id }
})
```

**Key Points:**

- Assigned before any hook or handler runs
- Available throughout the entire request lifecycle
- Automatically included in every log entry emitted via `request.log`
- The default value is an incrementing integer cast to a string (`'1'`, `'2'`, etc.)

---

#### Default ID Generation

Fastify uses an internal counter to generate request IDs by default. The counter increments per request and resets when the server restarts.

js

```
// First request:  id = '1'
// Second request: id = '2'
// ...and so on
```

**Key Points:**

- IDs are not guaranteed to be unique across server restarts or multiple instances
- Not suitable as globally unique identifiers without customization
- Suitable for local tracing and log correlation within a single server process

---

#### Custom ID Generation — `genReqId`

The `genReqId` server option accepts a function that receives the raw Node.js `IncomingMessage` and returns a string (or value coercible to string) to use as the request ID.

##### Using a UUID

js

```
import { randomUUID } from 'crypto'
import Fastify from 'fastify'

const fastify = Fastify({
  genReqId: (req) => randomUUID()
})
```

##### Propagating an Upstream ID

A common production pattern is to forward a trace ID from an upstream service or API gateway.

js

```
import { randomUUID } from 'crypto'

const fastify = Fastify({
  genReqId: (req) => {
    return req.headers['x-request-id']
      ?? req.headers['x-trace-id']
      ?? randomUUID()
  }
})
```

**Key Points:**

- `genReqId` receives the raw `http.IncomingMessage`, not Fastify's `request` wrapper — access headers via `req.headers` directly
- If the upstream header is absent, fall back to a generated ID to avoid `undefined` becoming the request ID
- The return value should be a string — other types may work but are not formally documented; verify against your version

---

#### `request.log` — The Request-Scoped Logger

Fastify creates a child Pino logger for each request, bound to that request's ID. It is exposed as `request.log`.

js

```
fastify.get('/example', async (request, reply) => {
  request.log.info('handler reached')
  request.log.warn({ userId: 42 }, 'suspicious activity')
  request.log.error({ err: new Error('oops') }, 'something failed')
  return { ok: true }
})
```

**Example log output (newline-delimited JSON):**

json

```
{"level":30,"time":1700000000000,"reqId":"1","msg":"handler reached"}
{"level":40,"time":1700000000001,"reqId":"1","userId":42,"msg":"suspicious activity"}
{"level":50,"time":1700000000002,"reqId":"1","err":{"type":"Error","message":"oops"},"msg":"something failed"}
```

**Key Points:**

- `request.log` is a Pino child logger — all Pino log levels (`trace`, `debug`, `info`, `warn`, `error`, `fatal`) are available
- The `reqId` field is automatically injected into every entry — you do not add it manually
- Prefer `request.log` over `fastify.log` inside handlers and hooks for correlated, traceable output
- `fastify.log` is the root logger — it does not carry request context

---

#### Automatic Lifecycle Logging

Fastify emits log entries automatically at key points in the request lifecycle without any configuration.

| Event | Log Level | Message |
| --- | --- | --- |
| Request received | `info` | `incoming request` |
| Response sent | `info` | `request completed` |
| Route not found | `info` | — |
| Unhandled error | `error` | — |

**Example of automatic entries for a single request:**

json

```
{"level":30,"reqId":"1","req":{"method":"GET","url":"/ping","hostname":"localhost:3000"},"msg":"incoming request"}
{"level":30,"reqId":"1","res":{"statusCode":200},"responseTime":3.21,"msg":"request completed"}
```

> [Inference] The exact fields included in automatic log entries (`req`, `res`, `responseTime`) depend on Fastify's serializer configuration. Default serializers are provided by Fastify but can be overridden. Actual output may vary by version.

---

#### Customizing Log Serializers

Fastify allows you to control how `req` and `res` objects are serialized in log entries.

js

```
const fastify = Fastify({
  logger: {
    serializers: {
      req(request) {
        return {
          method:    request.method,
          url:       request.url,
          userAgent: request.headers['user-agent'],
          ip:        request.socket.remoteAddress
        }
      },
      res(reply) {
        return {
          statusCode: reply.statusCode
        }
      }
    }
  }
})
```

**Key Points:**

- Serializers apply to the automatic lifecycle log entries, not to manual `request.log` calls
- Keep serializers lean — they run on every request
- Avoid logging sensitive headers (e.g. `authorization`, `cookie`) in serializers

---

#### Log Level Configuration

##### Global Log Level

js

```
const fastify = Fastify({
  logger: { level: 'warn' }
})
```

Only `warn`, `error`, and `fatal` entries are emitted. `info`, `debug`, and `trace` are suppressed.

##### Per-Route Log Level

js

```
fastify.get('/verbose', {
  logLevel: 'debug',
  handler: async (request, reply) => {
    request.log.debug('debug entry visible for this route only')
    return { ok: true }
  }
})
```

**Key Points:**

- `logLevel` on a route overrides the global level for that route's request-scoped logger
- Useful for increasing verbosity on specific endpoints during debugging without affecting the rest of the server

---

#### Disabling Logging Per Route

js

```
fastify.get('/healthz', {
  logLevel: 'silent',
  handler: async (request, reply) => {
    return { status: 'ok' }
  }
})
```

Setting `logLevel: 'silent'` suppresses all log output for that route, including the automatic `incoming request` and `request completed` entries. This is commonly applied to health check endpoints to reduce log noise.

---

#### Using `request.log` in Hooks

`request.log` is available in all hooks that receive the `request` object.

js

```
fastify.addHook('onRequest', async (request, reply) => {
  request.log.info({ url: request.url }, 'onRequest hook')
})

fastify.addHook('preHandler', async (request, reply) => {
  request.log.debug({ body: request.body }, 'preHandler hook')
})

fastify.addHook('onResponse', async (request, reply) => {
  request.log.info({ statusCode: reply.statusCode }, 'onResponse hook')
})
```

All entries across hooks and the handler share the same `reqId`, making it straightforward to reconstruct the full lifecycle of a request from logs.

---

#### Correlating Logs Across Services

When Fastify sits behind a gateway or alongside other services, propagating the request ID outward enables end-to-end trace correlation.

js

```
import fetch from 'node-fetch'

fastify.get('/data', async (request, reply) => {
  const upstream = await fetch('https://internal-service/api', {
    headers: {
      'x-request-id': request.id
    }
  })

  const data = await upstream.json()
  request.log.info({ upstream: data }, 'upstream response received')
  return data
})
```

The downstream service receives `x-request-id`, logs it, and its entries can be joined with Fastify's log entries by that shared ID.

---

#### Redacting Sensitive Fields

Pino supports field redaction via the `redact` option, preventing sensitive data from appearing in logs.

js

```
const fastify = Fastify({
  logger: {
    redact: [
      'req.headers.authorization',
      'req.headers.cookie',
      'body.password',
      'body.creditCard'
    ]
  }
})
```

Redacted fields are replaced with `'[Redacted]'` in log output.

> [Inference] Redaction applies to the Pino logger's output serialization. Fields must be specified using dot-notation paths relative to the logged object structure. The exact paths depend on your serializer configuration — verify that your serializer exposes the fields at the paths you specify.

---

#### Pretty Printing in Development

js

```
const fastify = Fastify({
  logger: {
    transport: {
      target: 'pino-pretty',
      options: {
        translateTime: 'HH:MM:ss Z',
        ignore: 'pid,hostname'
      }
    }
  }
})
```

**Key Points:**

- `pino-pretty` must be installed separately: `npm install pino-pretty`
- Not recommended for production — pretty printing is slower and produces larger output than NDJSON
- Use only in development environments

---

#### Summary of Key Behaviors

| Feature | Behavior |
| --- | --- |
| Default ID format | Incrementing integer string (`'1'`, `'2'`, …) |
| Custom ID | Via `genReqId` server option |
| Logger type | Pino child logger, scoped per request |
| Auto `reqId` injection | Handled by Fastify — no manual steps needed |
| Lifecycle log entries | Emitted automatically by Fastify |
| Per-route log level | Via `logLevel` route option |
| Silent routes | `logLevel: 'silent'` suppresses all entries |

---

#### Related Topics

- Pino logger configuration and transports
- Lifecycle hooks and logging within them
- `genReqId` and distributed tracing patterns
- Redaction and log security
- `reply.log` — same logger, accessible from the reply side