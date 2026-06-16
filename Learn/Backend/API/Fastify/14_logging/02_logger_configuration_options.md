## Logger Configuration Options in Fastify

Fastify exposes Pino's full configuration surface through the `logger` option at server instantiation. This topic covers every significant configuration knob — what it does, when to use it, and how it interacts with Fastify's request lifecycle.

---

### Configuration Entry Point

All logger configuration is passed to the `logger` key in the Fastify options object:

```js
const fastify = require('fastify')({
  logger: { /* Pino options here */ }
})
```

Passing `logger: true` is equivalent to passing `logger: {}` with all defaults applied.

Passing `logger: false` (the default) disables logging entirely. `fastify.log` and `request.log` are still available but are no-op instances.

---

### `level`

Controls the minimum severity of log lines emitted. Messages below this level are discarded before serialization.

```js
const fastify = require('fastify')({
  logger: { level: 'debug' }
})
```

| Value | Numeric | Emits |
|---|---|---|
| `trace` | 10 | Everything |
| `debug` | 20 | debug and above |
| `info` | 30 | info and above (default) |
| `warn` | 40 | warn and above |
| `error` | 50 | error and fatal only |
| `fatal` | 60 | fatal only |
| `silent` | Infinity | Nothing |

**Key Points:**
- `silent` completely suppresses all output without disabling the logger instance.
- Level filtering happens before serialization, so suppressed messages incur near-zero cost. [Inference — consistent with Pino's documented level guard design]
- The level can be changed at runtime: `fastify.log.level = 'warn'`

---

### `transport`

Configures how log output is written. Pino's transport system uses worker threads to handle output asynchronously, keeping the main thread unblocked.

#### Single transport

```js
const fastify = require('fastify')({
  logger: {
    level: 'info',
    transport: {
      target: 'pino-pretty',
      options: {
        colorize: true,
        translateTime: 'SYS:standard',
        ignore: 'pid,hostname'
      }
    }
  }
})
```

#### Multiple transports (pipeline)

```js
const fastify = require('fastify')({
  logger: {
    transport: {
      targets: [
        {
          target: 'pino-pretty',
          level: 'debug',
          options: { colorize: true }
        },
        {
          target: 'pino/file',
          level: 'warn',
          options: { destination: '/var/log/app/warn.log', mkdir: true }
        }
      ]
    }
  }
})
```

**Key Points:**
- `pino/file` is a built-in Pino transport for writing to a file path.
- Each entry in `targets` can have its own `level`, allowing different output destinations to capture different severity thresholds.
- Transports run in worker threads. Modules used as transport targets must be resolvable as Node.js module specifiers. [Inference — based on Pino transport architecture documentation]
- `pino-pretty` is for development only. Its formatting overhead makes it inappropriate for production. [Inference]

---

### `serializers`

Controls how specific keys are converted to their log representation. Pino applies serializers per key name.

```js
const fastify = require('fastify')({
  logger: {
    serializers: {
      req (request) {
        return {
          method: request.method,
          url: request.url,
          ip: request.ip,
          userAgent: request.headers['user-agent'] ?? 'unknown'
        }
      },
      res (reply) {
        return {
          statusCode: reply.statusCode
        }
      },
      err (error) {
        return {
          type: error.constructor.name,
          message: error.message,
          code: error.code,
          stack: error.stack
        }
      }
    }
  }
})
```

**Key Points:**
- `req`, `res`, and `err` are the three keys Fastify uses in its automatic log lines. Overriding them replaces Fastify's defaults for those keys.
- The `err` serializer fires when a value is logged under the key `err` (e.g., `log.error({ err: error }, 'msg')`).
- Serializers are applied at serialization time, not at log-call time.
- Custom serializers on other keys (e.g., `user`, `order`) are also supported and fire whenever that key appears in a log object.

---

### `redact`

Removes or replaces sensitive field values before output. Operates on the serialized log object.

#### Simple array form

```js
const fastify = require('fastify')({
  logger: {
    redact: ['req.headers.authorization', 'req.headers.cookie']
  }
})
```

#### Object form with custom censor

```js
const fastify = require('fastify')({
  logger: {
    redact: {
      paths: [
        'req.headers.authorization',
        'req.headers.cookie',
        '*.password',
        '*.token',
        'req.body.creditCard'
      ],
      censor: '[REDACTED]'
    }
  }
})
```

**Key Points:**
- Paths use a dot-notation syntax. Wildcards (`*`) match any key at that depth.
- The `censor` value replaces the redacted field. Defaults to `'[Redacted]'` if not specified.
- Redaction does not mutate the original object in memory; it operates during JSON serialization. [Inference — based on Pino's `fast-redact` library design]
- `req.body` is not logged by default in Fastify's automatic request log. If you log body content manually, add appropriate redaction paths.
- Redaction paths must match the structure of the serialized object, not the raw Node.js object. Use the `req` serializer shape as reference.

---

### `genReqId`

Provides a custom function for generating request IDs:

```js
const { randomUUID } = require('crypto')

const fastify = require('fastify')({
  logger: true,
  genReqId (request) {
    return request.headers['x-request-id']
      ?? request.headers['x-correlation-id']
      ?? randomUUID()
  }
})
```

**Key Points:**
- The generated ID is stored on `request.id` and bound to every `request.log` line.
- Propagating IDs from upstream headers (`x-request-id`) enables distributed tracing correlation across services.
- `genReqId` is a top-level Fastify option, not a Pino option. It is passed alongside `logger`, not inside it.
- `randomUUID()` is available in Node.js 14.17+.

---

### `requestIdHeader`

Specifies which incoming header Fastify reads for the request ID instead of generating one:

```js
const fastify = require('fastify')({
  logger: true,
  requestIdHeader: 'x-request-id'
})
```

**Key Points:**
- If the header is present, its value is used as `request.id` directly.
- If absent, `genReqId` is called as a fallback.
- Set to `false` to disable header-based ID extraction entirely and always use `genReqId`.
- `requestIdHeader` is a top-level Fastify option, not a Pino option.

---

### `requestIdLogLabel`

Controls the key name used for the request ID in log output. Defaults to `'reqId'`:

```js
const fastify = require('fastify')({
  logger: true,
  requestIdLogLabel: 'traceId'
})
```

**Output with custom label:**
```json
{
  "level": 30,
  "traceId": "abc-123",
  "msg": "incoming request"
}
```

**Key Points:**
- Changing this label is useful when integrating with log aggregators that expect a specific field name for correlation (e.g., `traceId`, `correlationId`).
- `requestIdLogLabel` is a top-level Fastify option.

---

### `disableRequestLogging`

Suppresses the automatic `"incoming request"` and `"request completed"` log lines globally:

```js
const fastify = require('fastify')({
  logger: true,
  disableRequestLogging: true
})
```

**Key Points:**
- `request.log` remains available for manual use inside handlers and hooks.
- Useful when you want full control over what is logged per request without removing the logger entirely.
- Individual routes can also suppress automatic logging via `logLevel: 'silent'` without disabling it globally.

---

### Per-Route Log Level (`logLevel`)

Each route can override the effective log level for its automatic request/response logs:

```js
fastify.get('/healthcheck', {
  logLevel: 'silent'
}, async () => ({ status: 'ok' }))

fastify.post('/payment', {
  logLevel: 'debug'
}, async (request, reply) => {
  // ...
})
```

**Key Points:**
- `logLevel: 'silent'` suppresses automatic logs for that route only, useful for health check endpoints that would otherwise flood logs.
- Manual `request.log` calls inside the handler are not affected by `logLevel`. [Inference — `logLevel` controls Fastify's automatic hook-level logs, not the child logger instance itself]
- Setting `logLevel: 'debug'` on a specific route emits more granular automatic logs for that route even if the global level is `info`.

---

### Per-Route Log Serializer (`logSerializers`)

Routes can override the serializer for specific keys:

```js
fastify.get('/admin/users', {
  logSerializers: {
    res (reply) {
      return {
        statusCode: reply.statusCode,
        headers: reply.getHeaders()
      }
    }
  }
}, async () => { /* ... */ })
```

**Key Points:**
- `logSerializers` at the route level merges with (not replaces) the global serializers. [Inference — verify behavior in your Fastify version]
- Useful for routes where additional response detail is needed in logs without affecting global serialization.

---

### `timestamp`

Controls the timestamp format emitted in each log line:

```js
const pino = require('pino')

const fastify = require('fastify')({
  logger: {
    timestamp: pino.stdTimeFunctions.isoTime
  }
})
```

| `stdTimeFunctions` value | Output format |
|---|---|
| `epochTime` (default) | Unix epoch in milliseconds |
| `unixTime` | Unix epoch in seconds |
| `isoTime` | ISO 8601 string |
| `nullTime` | No timestamp field emitted |

Custom timestamp function:

```js
const fastify = require('fastify')({
  logger: {
    timestamp: () => `,"time":"${new Date().toISOString()}"`
  }
})
```

**Key Points:**
- The custom function must return a string in the form `,"key":"value"` — it is spliced directly into the raw JSON output. [Inference — this is Pino's documented low-level timestamp API; incorrect formatting will produce invalid JSON]
- `pino.stdTimeFunctions` is the safest way to change timestamp format without manual string construction.

---

### `base`

Adds fixed fields to every log line. Defaults to including `pid` and `hostname`:

```js
const fastify = require('fastify')({
  logger: {
    base: {
      pid: process.pid,
      hostname: require('os').hostname(),
      service: 'payment-service',
      version: process.env.APP_VERSION ?? 'unknown'
    }
  }
})
```

Setting `base: null` removes `pid` and `hostname` entirely:

```js
const fastify = require('fastify')({
  logger: {
    base: null
  }
})
```

**Key Points:**
- Adding `service` and `version` to `base` is a common production practice for multi-service log aggregation.
- Fields in `base` appear in every log line, including child loggers.

---

### `formatters`

Low-level control over how log levels and bindings are represented in JSON output:

```js
const fastify = require('fastify')({
  logger: {
    formatters: {
      level (label, number) {
        return { severity: label.toUpperCase() }
        // replaces numeric "level" field with string "severity"
      },
      bindings (bindings) {
        return {
          pid: bindings.pid,
          host: bindings.hostname,
          node: process.version
        }
      },
      log (object) {
        return object // identity; can transform all log objects here
      }
    }
  }
})
```

**Key Points:**
- `formatters.level` is commonly used to produce `"severity": "INFO"` instead of `"level": 30` — a format expected by Google Cloud Logging and similar platforms.
- `formatters.bindings` controls the shape of `base` fields as they appear in output.
- `formatters.log` transforms the entire log object before serialization; use with care as it applies to every line.

---

### `messageKey`

Changes the key used for the log message string. Defaults to `'msg'`:

```js
const fastify = require('fastify')({
  logger: {
    messageKey: 'message'
  }
})
```

**Output:**
```json
{ "level": 30, "message": "incoming request" }
```

**Key Points:**
- Some log aggregation platforms expect `"message"` rather than `"msg"`. Changing this avoids a transformation step in the pipeline.

---

### `errorKey`

Changes the key name under which error objects are serialized. Defaults to `'err'`:

```js
const fastify = require('fastify')({
  logger: {
    errorKey: 'error'
  }
})
```

After this change, log calls use the new key:

```js
request.log.error({ error: someError }, 'Handler failed')
```

**Key Points:**
- Changing `errorKey` requires updating all existing `{ err: error }` log call patterns in the codebase. [Inference]
- Consistent with platforms that index on `"error"` rather than `"err"`.

---

### Configuration Reference Summary

| Option | Location | Default | Purpose |
|---|---|---|---|
| `level` | `logger` | `'info'` | Minimum log severity |
| `transport` | `logger` | stdout JSON | Output destination and format |
| `serializers` | `logger` | Fastify defaults | Per-key object serialization |
| `redact` | `logger` | None | Sensitive field suppression |
| `timestamp` | `logger` | `epochTime` | Timestamp format |
| `base` | `logger` | `{ pid, hostname }` | Fields added to every line |
| `formatters` | `logger` | Pino defaults | Level/binding/log shape |
| `messageKey` | `logger` | `'msg'` | Message field name |
| `errorKey` | `logger` | `'err'` | Error field name |
| `genReqId` | Top-level Fastify | Incrementing int | Request ID generation |
| `requestIdHeader` | Top-level Fastify | `'request-id'` | Header to read for request ID |
| `requestIdLogLabel` | Top-level Fastify | `'reqId'` | Log field name for request ID |
| `disableRequestLogging` | Top-level Fastify | `false` | Suppress automatic req/res logs |
| `logLevel` | Route option | Inherits global | Per-route log level override |
| `logSerializers` | Route option | Inherits global | Per-route serializer override |