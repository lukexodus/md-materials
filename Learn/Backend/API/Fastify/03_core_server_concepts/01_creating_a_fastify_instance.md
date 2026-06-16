## Creating a Fastify Instance

The Fastify instance is the central object of every Fastify application. It is created by calling the Fastify factory function and serves as the root from which plugins, routes, hooks, and decorators are registered. Understanding how to create and configure the instance correctly is foundational to all subsequent Fastify development.

---

### Importing Fastify

Fastify supports both CommonJS and ES Module import styles.

**CommonJS**:

```js
const fastify = require('fastify')
```

**ES Modules**:

```js
import Fastify from 'fastify'
```

**Key Points**

- The default export is a factory function, not a class
- The factory function is called to produce an instance; it is not instantiated with `new`
- Named exports are also available for specific utilities, but the factory is the default export

---

### Calling the Factory Function

The factory function accepts an optional configuration object. Calling it without arguments uses all defaults.

**Example** — no options:

```js
const fastify = require('fastify')
const app = fastify()
```

**Example** — with options:

```js
const app = fastify({
  logger: true,
  requestIdHeader: 'x-request-id',
  trustProxy: true
})
```

The return value is a Fastify instance, conventionally named `app`, `fastify`, or `server`. All three names appear in community code; there is no enforced naming convention.

---

### Factory Options

The factory function accepts a single configuration object. All properties are optional.

#### Logger

Controls Fastify's built-in logger, which is powered by `pino`.

```js
const app = fastify({ logger: true })
```

| Value | Behavior |
|---|---|
| `false` | Logger disabled (default) |
| `true` | Logger enabled with pino defaults |
| Object | Logger enabled with pino configuration options |

**Example** — logger with pretty printing for development:

```js
const app = fastify({
  logger: {
    level: 'info',
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

**Key Points**

- `pino-pretty` must be installed separately (`npm install --save-dev pino-pretty`)
- Pretty printing is intended for development only; it adds overhead and is not recommended in production [Inference]
- The logger instance is accessible as `app.log` (`app.log.info(...)`, `app.log.error(...)`, etc.)

#### `requestIdHeader`

The HTTP header from which Fastify reads the request ID. Defaults to `'request-id'`.

```js
const app = fastify({ requestIdHeader: 'x-request-id' })
```

If the header is absent, Fastify generates an ID using the `genReqId` function.

#### `genReqId`

A custom function for generating request IDs when the `requestIdHeader` is not present.

```js
const { randomUUID } = require('crypto')

const app = fastify({
  genReqId: () => randomUUID()
})
```

#### `trustProxy`

Controls whether Fastify trusts the `X-Forwarded-*` headers set by a proxy. Affects `request.ip`, `request.ips`, `request.hostname`, and `request.protocol`.

```js
const app = fastify({ trustProxy: true })
```

Acceptable values include `true`, `false`, an IP address string, a CIDR string, or an array of these. [Inference — exact behavior depends on the underlying proxy-addr library]

#### `bodyLimit`

Maximum allowed size in bytes for request bodies. Defaults to `1048576` (1 MiB).

```js
const app = fastify({ bodyLimit: 5 * 1024 * 1024 }) // 5 MiB
```

Requests exceeding this limit receive a `413 Payload Too Large` response.

#### `caseSensitive`

Controls whether route matching is case-sensitive. Defaults to `true`.

```js
const app = fastify({ caseSensitive: false })
```

When `false`, `/Users` and `/users` match the same route. [Inference — disabling case sensitivity may affect router performance; consult Fastify documentation for the specific version in use]

#### `ignoreTrailingSlash`

When `true`, treats `/users` and `/users/` as the same route. Defaults to `false`.

```js
const app = fastify({ ignoreTrailingSlash: true })
```

#### `maxParamLength`

Maximum length of route parameters. Defaults to `100` characters. Requests with parameters exceeding this length result in a `404`.

```js
const app = fastify({ maxParamLength: 200 })
```

#### `ajv`

Configuration passed to the underlying AJV instance used for schema validation.

```js
const app = fastify({
  ajv: {
    customOptions: {
      strict: 'log',
      keywords: ['example']
    }
  }
})
```

#### `return503OnClosing`

When `true`, Fastify responds with `503 Service Unavailable` to incoming requests while the server is closing. Defaults to `true`.

```js
const app = fastify({ return503OnClosing: false })
```

#### `http2`

Enables HTTP/2 support. Requires a compatible server setup.

```js
const app = fastify({ http2: true })
```

#### `https`

Passes HTTPS options to the underlying Node.js `https` server. Accepts the same options as `https.createServer()`.

```js
const fs = require('fs')

const app = fastify({
  https: {
    key: fs.readFileSync('./key.pem'),
    cert: fs.readFileSync('./cert.pem')
  }
})
```

---

### The Instance Object

After calling the factory, the returned instance exposes the Fastify API surface.

**Key Points**

- `app.register()` — registers plugins
- `app.route()` / `app.get()` / `app.post()` etc. — defines routes
- `app.addHook()` — registers lifecycle hooks
- `app.decorate()` — adds custom properties to the instance
- `app.listen()` — starts the HTTP server
- `app.inject()` — sends a synthetic HTTP request without starting a server (used in testing)
- `app.close()` — shuts down the server and triggers `onClose` hooks
- `app.log` — the pino logger instance (or a no-op logger if logging is disabled)
- `app.ready()` — resolves after all plugins have loaded; useful for deferring operations until initialization is complete

---

### Async/Await and the Instance Lifecycle

Fastify's plugin system is asynchronous. The instance is not fully initialized until all registered plugins have loaded. `app.ready()` can be awaited to ensure the instance is ready before use.

**Example**:

```js
const app = fastify({ logger: true })

app.register(require('./plugins/db'))
app.register(require('./routes/users'))

await app.ready()
// All plugins have loaded; decorators and routes are available
```

In practice, `app.listen()` implicitly calls `ready()` before binding the port, so explicit `ready()` calls are most useful in testing or scripted contexts.

---

### Creating the Instance in a Factory Function

The recommended pattern wraps instance creation in an exported async function, separating construction from server startup.

**Example** — `app.js`:

```js
const fastify = require('fastify')

async function buildApp(opts = {}) {
  const app = fastify(opts)

  await app.register(require('./plugins/db'))
  await app.register(require('./routes/users'), { prefix: '/users' })

  return app
}

module.exports = buildApp
```

**Example** — `server.js`:

```js
const buildApp = require('./app')

async function start() {
  const app = await buildApp({
    logger: {
      level: 'info',
      transport: { target: 'pino-pretty' }
    }
  })

  await app.listen({ port: process.env.PORT || 3000, host: '0.0.0.0' })
}

start()
```

**Key Points**

- `opts` is passed through to the Fastify factory, allowing callers to override configuration
- Tests can call `buildApp()` with test-specific options (e.g., disabled logger)
- The factory function pattern is independent of `fastify-cli` conventions, though compatible with them

---

### Multiple Instances

Fastify does not enforce a singleton pattern. Multiple independent instances can be created in the same process.

**Example**:

```js
const publicApp = fastify({ logger: true })
const adminApp = fastify({ logger: true })

publicApp.listen({ port: 3000 })
adminApp.listen({ port: 4000 })
```

[Inference] Running multiple instances in one process is possible but is an uncommon pattern in production. Resource management (database connections, port conflicts) must be handled explicitly.

---

### Instance Verification Example

A minimal working instance that responds to a request:

```js
const fastify = require('fastify')({ logger: true })

fastify.get('/', async (request, reply) => {
  return { status: 'ok' }
})

fastify.listen({ port: 3000, host: '0.0.0.0' }, (err) => {
  if (err) {
    fastify.log.error(err)
    process.exit(1)
  }
})
```

**Output** (approximate — actual log format depends on pino configuration):

```
{"level":30,"time":...,"msg":"Server listening at http://0.0.0.0:3000"}
```

---

### Common Mistakes

| Mistake | Effect | Correction |
|---|---|---|
| Using `new fastify()` | TypeError | Call `fastify()` without `new` |
| Registering plugins after `listen()` | [Unverified — may throw or be silently ignored depending on version] | Register all plugins before calling `listen()` |
| Not awaiting `listen()` | Errors may be uncaught | Use `await app.listen(...)` or handle the callback error |
| Passing logger options to `listen()` instead of the factory | Logger not configured | Pass logger options to the factory function |

---

**Conclusion**

The Fastify instance is created by calling the factory function with an optional configuration object. All application behavior — routes, plugins, hooks, decorators — is registered on this instance before the server starts. The factory function pattern, separating `buildApp()` from `server.js`, is the most broadly applicable structure and is recommended for testability and flexibility. Configuration options passed to the factory determine core behaviors including logging, body limits, proxy trust, and routing semantics.