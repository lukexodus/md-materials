## Log Transport and Destinations

Fastify uses [Pino](https://getpino.io/) as its built-in logger. Pino follows a **transport-based architecture** where log records are written as newline-delimited JSON to `stdout` by default, and separate processes or streams handle formatting, filtering, and routing to destinations.

---

### How Pino's Transport Model Works

Pino separates **log production** from **log consumption**. The application writes raw JSON logs at high speed; transports consume those logs asynchronously or synchronously depending on configuration.

There are two broad approaches:

- **Stream-based** — pipe log output to a writable stream directly in the same process
- **Worker-based** (`pino.transport()`) — offload log processing to a separate worker thread, introduced in Pino v7+

Fastify exposes Pino's transport configuration through the `logger` option passed to the Fastify factory.

---

### Default Destination: stdout

Unless configured otherwise, Fastify logs go to `process.stdout` as newline-delimited JSON.

```js
const fastify = require('fastify')({
  logger: true
})
```

This is equivalent to Pino's default behavior. No transport is configured; JSON lines flow directly to `stdout`.

**Key Points**
- Lowest overhead path
- Suitable for containerized environments where a log collector (e.g., Fluentd, Logstash) reads `stdout`
- No formatting is applied at the application level

---

### pino-pretty for Human-Readable Output

`pino-pretty` is a Pino transport that formats JSON logs into colored, human-readable output. It is intended for **development only** due to its formatting overhead.

**Installation**

```bash
npm install pino-pretty
```

**Using pino-pretty as a transport (worker-based)**

```js
const fastify = require('fastify')({
  logger: {
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

**Key Points**
- `target` refers to the npm package name or a file path
- Runs in a worker thread; the main thread is not blocked by formatting
- Do not use in production — formatting adds latency and increases output size

---

### Multiple Destinations with `pino.transport()`

Pino supports routing logs to multiple destinations simultaneously using the `targets` array within `pino.transport()`.

```js
const pino = require('pino')

const transport = pino.transport({
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
})

const fastify = require('fastify')({ logger: { stream: transport } })
```

**Key Points**
- Each target can have its own `level` filter
- Targets run in separate worker threads
- `pino/file` is a built-in Pino target for writing to a file path

---

### Writing to a File with `pino/file`

`pino/file` is a built-in transport target. It writes logs to a specified file path without requiring an external package.

```js
const fastify = require('fastify')({
  logger: {
    transport: {
      target: 'pino/file',
      options: {
        destination: './logs/app.log',
        mkdir: true
      }
    }
  }
})
```

- `destination` — absolute or relative file path
- `mkdir: true` — creates the directory if it does not exist

> **Note:** File rotation is not handled by `pino/file`. Use an external tool such as `logrotate` or `pino-roll` for rotation.

---

### Log Rotation with pino-roll

`pino-roll` is a Pino transport that supports automatic log file rotation by size or time interval.

**Installation**

```bash
npm install pino-roll
```

```js
const fastify = require('fastify')({
  logger: {
    transport: {
      target: 'pino-roll',
      options: {
        file: './logs/app.log',
        frequency: 'daily',
        mkdir: true
      }
    }
  }
})
```

**Key Points**
- `frequency` accepts `'hourly'`, `'daily'`, or a number of milliseconds
- `size` option accepts values like `'10m'` (10 megabytes) for size-based rotation
- [Inference] Combining both `frequency` and `size` may trigger rotation on whichever condition is met first — verify against `pino-roll` documentation for your version, as behavior may vary

---

### Sending Logs to External Systems

For production systems, logs are commonly shipped to external platforms. This is typically done through one of two strategies:

**Strategy 1 — Sidecar / collector reads stdout**

The application writes JSON to `stdout`; an external agent (e.g., Fluent Bit, Vector, Filebeat) reads and forwards logs. No transport configuration is needed in Fastify.

**Strategy 2 — In-process transport to external destination**

A Pino-compatible transport package handles delivery directly.

| Destination | Package |
|---|---|
| Elasticsearch | `pino-elasticsearch` |
| Loki (Grafana) | `pino-loki` |
| Datadog | `pino-datadog-transport` |
| Seq | `pino-seq` |
| AWS CloudWatch | community packages (verify current maintenance status) |

**Example — pino-loki**

```bash
npm install pino-loki
```

```js
const fastify = require('fastify')({
  logger: {
    transport: {
      target: 'pino-loki',
      options: {
        host: 'http://localhost:3100',
        labels: { app: 'my-fastify-app' }
      }
    }
  }
})
```

[Unverified] Package maintenance status and API compatibility for third-party transports should be verified independently before use in production. Behavior is not guaranteed to match documentation for all versions.

---

### Custom Stream as Destination

You can pass any Node.js writable stream as the log destination using the `stream` property under `logger`.

```js
const fs = require('fs')
const fastify = require('fastify')({
  logger: {
    stream: fs.createWriteStream('./logs/app.log', { flags: 'a' })
  }
})
```

**Key Points**
- This runs synchronously in the main thread — no worker offloading
- [Inference] For high-throughput scenarios, this approach may introduce backpressure on the main event loop compared to worker-based transports; actual impact depends on write volume and system I/O
- Suitable for simple setups or low-traffic services

---

### Using a Custom Transport Target (File Path)

The `target` field also accepts an absolute or relative file path to a local module, useful for custom transport logic.

```js
// my-transport.js
module.exports = require('pino-abstract-transport')(async function (source) {
  for await (const log of source) {
    // custom processing, e.g., send to an internal HTTP endpoint
    console.log('CUSTOM:', log)
  }
})
```

```js
const fastify = require('fastify')({
  logger: {
    transport: {
      target: './my-transport.js'
    }
  }
})
```

`pino-abstract-transport` is the recommended base for building custom transports. It handles the worker thread setup and async iteration protocol.

---

### Transport Configuration Summary

| Approach | Runs In | Use Case |
|---|---|---|
| Default stdout | Main thread | Containers, collectors |
| `pino/file` | Worker thread | Simple file output |
| `pino-pretty` | Worker thread | Development only |
| `pino-roll` | Worker thread | File rotation |
| Custom stream | Main thread | Low-traffic, custom sinks |
| External package transport | Worker thread | Loki, Elasticsearch, etc. |
| Custom target module | Worker thread | Proprietary destinations |

---

### Disabling the Logger

If no logging is needed, pass `logger: false` to the Fastify factory.

```js
const fastify = require('fastify')({ logger: false })
```

This disables Pino entirely; `fastify.log` methods become no-ops.

---

**Conclusion**

Fastify delegates all transport and destination concerns to Pino. For most production deployments, writing JSON to `stdout` and relying on an external collector is the lowest-overhead approach. When in-process routing is required, `pino.transport()` with the `targets` array provides flexible, worker-offloaded delivery to multiple destinations simultaneously. Third-party transport packages extend this to external observability platforms, though their compatibility and maintenance status should be verified independently.