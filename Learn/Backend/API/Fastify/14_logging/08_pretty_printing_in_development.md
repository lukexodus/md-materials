## Pretty Printing in Development

JSON log output is optimal for production pipelines but difficult to read during development. Fastify, through Pino, provides several approaches for human-readable log formatting in development environments. All of them add formatting overhead and are not suitable for production use.

---

### Why Raw JSON Is Unreadable in Development

Default Fastify log output looks like this:

```
{"level":30,"time":1717660800000,"pid":12345,"hostname":"dev-machine","reqId":"req-1","req":{"method":"GET","url":"/users","hostname":"localhost:3000","remoteAddress":"127.0.0.1","remotePort":52100},"msg":"incoming request"}
{"level":30,"time":1717660800012,"pid":12345,"hostname":"dev-machine","reqId":"req-1","res":{"statusCode":200},"responseTime":12.34,"msg":"request completed"}
```

Every line is a single minified JSON object. While parseable by machines, it requires mental overhead to scan during active development. Pretty printing reformats this into structured, colored, human-readable output.

---

### Approach 1 — `pino-pretty` as a Transport

`pino-pretty` is the standard Pino formatter. Configured as a transport, it runs in a worker thread and reformats output before writing.

#### Installation

```bash
npm install --save-dev pino-pretty
```

#### Configuration

```js
const fastify = require('fastify')({
  logger: {
    level: 'debug',
    transport: {
      target: 'pino-pretty',
      options: {
        colorize: true,
        translateTime: 'HH:MM:ss Z',
        ignore: 'pid,hostname'
      }
    }
  }
})
```

**Output:**
```
[10:30:00 +0000] INFO (req-1): incoming request
    req: {
      "method": "GET",
      "url": "/users",
      "remoteAddress": "127.0.0.1"
    }
[10:30:00 +0000] INFO (req-1): request completed
    res: {
      "statusCode": 200
    }
    responseTime: 12.34
```

---

### `pino-pretty` Options Reference

| Option | Type | Default | Purpose |
|---|---|---|---|
| `colorize` | `boolean` | `false` | Apply ANSI colors to level labels and keys |
| `colorizeObjects` | `boolean` | `true` | Apply colors to JSON object values |
| `translateTime` | `string` or `boolean` | `false` | Convert epoch timestamp to human-readable format |
| `ignore` | `string` | `''` | Comma-separated list of fields to omit from output |
| `include` | `string` | `''` | Comma-separated list of fields to include (all others omitted) |
| `messageKey` | `string` | `'msg'` | Key to use as the log message |
| `levelKey` | `string` | `'level'` | Key to use as the log level |
| `timestampKey` | `string` | `'time'` | Key to use as the timestamp |
| `singleLine` | `boolean` | `false` | Print log line and all fields on one line |
| `hideObject` | `boolean` | `false` | Suppress the context object; show only the message |
| `errorLikeObjectKeys` | `string[]` | `['err','error']` | Keys treated as error objects for stack trace formatting |
| `errorProps` | `string` | `''` | Comma-separated error properties to display |
| `levelFirst` | `boolean` | `false` | Print level before timestamp |
| `messageFormat` | `string` or `false` | `false` | Custom message line format string |

---

### `translateTime` Format Strings

```js
options: {
  translateTime: 'HH:MM:ss Z'        // 10:30:00 +0000
  translateTime: 'SYS:standard'       // system locale standard format
  translateTime: 'SYS:HH:MM:ss'      // system local time
  translateTime: 'UTC:yyyy-mm-dd'     // UTC date only
  translateTime: true                 // default locale format
}
```

**Key Points:**
- Prefix `SYS:` uses the system's local timezone. Without it, UTC is assumed. [Inference — based on `pino-pretty` documentation; verify in your version]
- `translateTime` adds a formatting step per log line. The overhead is acceptable in development.

---

### `messageFormat` for Custom Log Lines

`messageFormat` allows a template string controlling the primary log line:

```js
transport: {
  target: 'pino-pretty',
  options: {
    colorize: true,
    translateTime: 'HH:MM:ss',
    messageFormat: '{reqId} [{level}] {msg}'
  }
}
```

**Output:**
```
req-1 [INFO] incoming request
```

Variables in `{}` reference top-level fields in the log object. Fields referenced in `messageFormat` are consumed and not repeated in the object block below. [Inference — verify behavior in your `pino-pretty` version]

---

### Approach 2 — `pino-pretty` as a Pipe (CLI)

Instead of configuring the transport inside the application, pipe stdout to `pino-pretty` at the command line. The application emits raw JSON; the terminal formats it:

```bash
node server.js | pino-pretty
```

With options:

```bash
node server.js | pino-pretty --colorize --translateTime 'HH:MM:ss' --ignore 'pid,hostname'
```

**Key Points:**
- This approach keeps the application code free of development-only configuration.
- Raw JSON is preserved if the output is redirected to a file rather than a terminal, making this safe for staging environments where you might want both readable terminal output and file logging. [Inference]
- `pino-pretty` must be installed globally or available via `npx` for this to work.
- This is the approach most aligned with the Pino project's recommendation: keep the application producing JSON and format only at the edge. [Inference — based on Pino documentation guidance]

#### Using `npx` without global install:

```bash
node server.js | npx pino-pretty
```

#### Using a `package.json` script:

```json
{
  "scripts": {
    "dev": "node server.js | pino-pretty --colorize --translateTime 'SYS:HH:MM:ss'"
  }
}
```

---

### Approach 3 — Environment-Conditional Transport

Apply `pino-pretty` only in development by making the transport conditional on the environment:

```js
const isDev = process.env.NODE_ENV !== 'production'

const fastify = require('fastify')({
  logger: {
    level: isDev ? 'debug' : 'info',
    ...(isDev && {
      transport: {
        target: 'pino-pretty',
        options: {
          colorize: true,
          translateTime: 'HH:MM:ss Z',
          ignore: 'pid,hostname'
        }
      }
    })
  }
})
```

**Key Points:**
- When `NODE_ENV=production`, no transport is configured and Pino defaults to raw JSON on stdout.
- The spread conditional `...(isDev && { transport: ... })` avoids an explicit `if` block while keeping the options object inline.
- This is the most common pattern for applications that share a single entry point across environments. [Inference]

---

### Approach 4 — Multiple Transports (Dev + File)

In development you may want both pretty terminal output and a JSON log file for inspection:

```js
const fastify = require('fastify')({
  logger: {
    level: 'debug',
    transport: {
      targets: [
        {
          target: 'pino-pretty',
          level: 'debug',
          options: {
            colorize: true,
            translateTime: 'HH:MM:ss',
            ignore: 'pid,hostname,reqId'
          }
        },
        {
          target: 'pino/file',
          level: 'trace',
          options: {
            destination: './logs/dev.log',
            mkdir: true
          }
        }
      ]
    }
  }
})
```

**Key Points:**
- The terminal shows colored, readable output at `debug` level.
- The file receives full `trace`-level NDJSON for post-mortem inspection.
- Each target can have its own `level` threshold independently.
- `pino/file` is a built-in Pino transport; no additional install is required. [Inference — available in Pino v7+; verify in your version]

---

### `singleLine` Mode

For high-frequency routes where multi-line output is too verbose, `singleLine: true` compresses each log entry to one line:

```js
transport: {
  target: 'pino-pretty',
  options: {
    colorize: true,
    singleLine: true,
    translateTime: 'HH:MM:ss',
    ignore: 'pid,hostname'
  }
}
```

**Output:**
```
[10:30:00] INFO (req-1): incoming request {"req":{"method":"GET","url":"/users"}}
[10:30:00] INFO (req-1): request completed {"res":{"statusCode":200},"responseTime":12.34}
```

**Key Points:**
- `singleLine` is useful when watching high-volume logs in a narrow terminal.
- Object details are still present but compressed inline after the message.

---

### Suppressing Noise from Health Check Routes

Development logs can be cluttered by frequent health check or metrics endpoint calls. Suppress them at the route level:

```js
fastify.get('/healthcheck', {
  logLevel: 'silent'
}, async () => ({ status: 'ok' }))
```

Or use a conditional suppression only in development:

```js
fastify.get('/healthcheck', {
  logLevel: process.env.NODE_ENV === 'development' ? 'silent' : 'info'
}, async () => ({ status: 'ok' }))
```

---

### Pretty Printing Error Output

`pino-pretty` formats stack traces from the `err` key automatically:

```js
fastify.get('/fail', async (request) => {
  throw new Error('Something broke')
})
```

**Pretty output:**
```
[10:30:00] ERROR (req-1): Something broke
    err: {
      "type": "Error",
      "message": "Something broke",
      "stack": "Error: Something broke
          at Object.<anonymous> (/app/server.js:42:9)
          at ..."
    }
```

**Key Points:**
- Stack traces are expanded and indented when using `pino-pretty`.
- The `errorLikeObjectKeys` option controls which keys are treated as error objects. By default `err` and `error` are both handled.
- In production, suppress stack traces in the `err` serializer rather than relying on `pino-pretty` absence to hide them.

---

### Development vs. Production Comparison

| Concern | Development | Production |
|---|---|---|
| Format | `pino-pretty` colored output | Raw NDJSON |
| Log level | `debug` or `trace` | `info` or `warn` |
| Timestamp | Human-readable (`HH:MM:ss`) | Epoch ms or ISO 8601 |
| Stack traces | Visible and expanded | Suppressed in `err` serializer |
| Transport overhead | Acceptable | Not acceptable |
| Health check logs | Suppressed (`logLevel: 'silent'`) | Suppressed or `warn` |
| Output destination | Terminal | Log aggregator |

---

### Full Development Configuration Example

```js
const fastify = require('fastify')({
  logger: {
    level: 'debug',
    transport: {
      targets: [
        {
          target: 'pino-pretty',
          level: 'debug',
          options: {
            colorize: true,
            translateTime: 'SYS:HH:MM:ss',
            ignore: 'pid,hostname',
            errorProps: 'message,stack,code',
            messageFormat: '{reqId} {msg}'
          }
        }
      ]
    },
    serializers: {
      req (request) {
        return {
          method: request.method,
          url: request.url,
          ip: request.ip
        }
      },
      err (error) {
        return {
          type: error.constructor.name,
          message: error.message,
          code: error.code ?? null,
          stack: error.stack
        }
      }
    }
  }
})

// Suppress health check noise
fastify.get('/healthcheck', { logLevel: 'silent' }, async () => ({ status: 'ok' }))
```

---

### Summary

| Approach | Configuration Location | Application Code Impact |
|---|---|---|
| Transport in code | `logger.transport.target: 'pino-pretty'` | Present in source |
| CLI pipe | `node server.js \| pino-pretty` | None |
| `npx` pipe | `node server.js \| npx pino-pretty` | None |
| `package.json` dev script | `scripts.dev` | None |
| Conditional transport | `NODE_ENV` check in logger config | Minimal |
| Multiple targets | `logger.transport.targets` array | Present in source |