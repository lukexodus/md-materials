## Server Options and Configuration Object

The Fastify factory function accepts a single configuration object that controls the behavior of the server, router, logger, serializer, and HTTP layer. This topic covers all documented options in depth. Some options interact with underlying Node.js or third-party libraries; behavior for those is noted with appropriate labels.

---

### Structure of the Configuration Object

The configuration object is passed directly to the Fastify factory function. All properties are optional. Unrecognized properties are silently ignored. [Inference — exact handling of unrecognized keys may vary by version; consult release notes for the version in use]

```js
const app = require('fastify')({
  // options go here
})
```

The object is consumed at instantiation time. Modifying it after the instance is created has no effect.

---

### Logging Options

#### `logger`

Controls the built-in `pino` logger.

| Value | Effect |
|---|---|
| `false` | Logger disabled; `app.log` is a no-op object (default) |
| `true` | Logger enabled with pino defaults |
| Object | Logger enabled; object is passed to pino as configuration |

**Example** — structured logger for production:

```js
const app = require('fastify')({
  logger: {
    level: 'warn',
    serializers: {
      req(request) {
        return {
          method: request.method,
          url: request.url,
          remoteAddress: request.ip
        }
      }
    }
  }
})
```

**Example** — pretty-printed logger for development:

```js
const app = require('fastify')({
  logger: {
    level: 'debug',
    transport: {
      target: 'pino-pretty',
      options: { colorize: true }
    }
  }
})
```

#### `loggerInstance`

Provides an external logger instance instead of having Fastify create one. The instance must conform to the pino logger interface.

```js
const pino = require('pino')
const logger = pino({ level: 'info' })

const app = require('fastify')({ loggerInstance: logger })
```

**Key Points**

- `logger` and `loggerInstance` are mutually exclusive; providing both results in an error [Unverified — verify against the specific version in use]
- The external instance is used as-is; Fastify does not apply additional configuration to it

#### `disableRequestLogging`

When `true`, suppresses the automatic log entries Fastify emits at the start and end of each request. Defaults to `false`.

```js
const app = require('fastify')({ disableRequestLogging: true })
```

Useful when request logging is handled by a custom `onRequest` or `onResponse` hook.

---

### Request ID Options

#### `requestIdHeader`

The name of the HTTP header from which Fastify reads an incoming request ID. Defaults to `'request-id'`.

```js
const app = require('fastify')({ requestIdHeader: 'x-correlation-id' })
```

Set to `false` to disable header-based request ID reading entirely; IDs will always be generated.

#### `requestIdLogLabel`

The key name used for the request ID in log output. Defaults to `'reqId'`.

```js
const app = require('fastify')({ requestIdLogLabel: 'traceId' })
```

#### `genReqId`

A function that generates a request ID when the `requestIdHeader` is absent or disabled. Receives the raw Node.js `IncomingMessage` as its argument.

```js
const { randomUUID } = require('crypto')

const app = require('fastify')({
  genReqId: (req) => randomUUID()
})
```

**Key Points**

- The function must return a value that can be serialized as a log field (string or number)
- If both `requestIdHeader` is present and `genReqId` is configured, the header takes precedence [Inference — verify against the specific version in use]

---

### Routing Options

#### `caseSensitive`

Controls whether the router treats paths as case-sensitive. Defaults to `true`.

```js
const app = require('fastify')({ caseSensitive: false })
```

When `false`, `/Users` and `/users` resolve to the same route handler.

[Inference] Disabling case sensitivity may have a performance cost in route resolution depending on the router implementation. Behavior should be validated against the version in use.

#### `ignoreTrailingSlash`

When `true`, `/resource` and `/resource/` are treated as identical routes. Defaults to `false`.

```js
const app = require('fastify')({ ignoreTrailingSlash: true })
```

#### `ignoreDuplicateSlashes`

When `true`, consecutive slashes in paths are collapsed. Defaults to `false`.

```js
const app = require('fastify')({ ignoreDuplicateSlashes: true })
// /users//profile treated as /users/profile
```

#### `maxParamLength`

Maximum character length for route parameter values. Defaults to `100`. Requests with parameters exceeding this length receive a `404` response.

```js
const app = require('fastify')({ maxParamLength: 500 })
```

#### `allowUnsafeRegex`

When `true`, permits the use of potentially unsafe regular expressions in route paths. Defaults to `false`. Unsafe regex can be a vector for ReDoS attacks.

```js
const app = require('fastify')({ allowUnsafeRegex: false })
```

[Inference] Enabling this option without careful review of route patterns carries security risk. Behavior depends on the underlying `find-my-way` router version.

#### `useSemicolonDelimiter`

When `true`, semicolons in URLs are treated as query string delimiters in addition to `&`. Defaults to `false`.

```js
const app = require('fastify')({ useSemicolonDelimiter: true })
```

---

### Body Parsing Options

#### `bodyLimit`

Maximum allowed size in bytes for request bodies across all routes. Defaults to `1048576` (1 MiB). Requests exceeding this limit receive a `413 Payload Too Large` response.

```js
const app = require('fastify')({ bodyLimit: 10 * 1024 * 1024 }) // 10 MiB
```

This can be overridden per-route via the route's own `bodyLimit` option.

---

### HTTP and Network Options

#### `trustProxy`

Configures whether Fastify trusts proxy-set headers such as `X-Forwarded-For`, `X-Forwarded-Host`, and `X-Forwarded-Proto`. Affects `request.ip`, `request.ips`, `request.hostname`, and `request.protocol`. Defaults to `false`.

```js
const app = require('fastify')({ trustProxy: true })
```

Accepted values:

| Value | Behavior |
|---|---|
| `true` | Trust all proxies |
| `false` | Trust no proxies (default) |
| String (IP or CIDR) | Trust the specified address |
| Array of strings | Trust any address in the list |
| Number `n` | Trust the nth hop from the right in `X-Forwarded-For` |

[Inference] Proxy trust configuration interacts with the `proxy-addr` library internally. Exact behavior for edge cases should be verified against that library's documentation.

#### `http2`

Enables HTTP/2 support. Defaults to `false`. Requires either `https` options or an `http2` compatible setup.

```js
const app = require('fastify')({
  http2: true,
  https: {
    key: fs.readFileSync('./server.key'),
    cert: fs.readFileSync('./server.cert')
  }
})
```

#### `https`

Passes an options object to Node.js's `https.createServer()`. When provided, Fastify creates an HTTPS server instead of HTTP.

```js
const app = require('fastify')({
  https: {
    key: fs.readFileSync('./key.pem'),
    cert: fs.readFileSync('./cert.pem'),
    passphrase: 'optional-passphrase'
  }
})
```

#### `serverFactory`

A custom factory function for creating the underlying Node.js HTTP/HTTPS server. Used when the default server creation behavior needs to be replaced.

```js
const http = require('http')

const app = require('fastify')({
  serverFactory: (handler, opts) => {
    const server = http.createServer((req, res) => {
      handler(req, res)
    })
    return server
  }
})
```

**Key Points**

- The factory receives the Fastify request handler and the original options object
- Must return a Node.js-compatible server object
- Overrides `http2` and `https` options if provided simultaneously [Inference]

#### `rewriteUrl`

A function that rewrites the request URL before routing. Receives the raw Node.js `IncomingMessage` and returns a string.

```js
const app = require('fastify')({
  rewriteUrl: (req) => {
    return req.url.replace('/v1', '')
  }
})
```

---

### Closing and Shutdown Options

#### `return503OnClosing`

When `true`, Fastify responds with `503 Service Unavailable` to new incoming requests while the server is in the process of closing. Defaults to `true`.

```js
const app = require('fastify')({ return503OnClosing: false })
```

Useful when a load balancer or upstream proxy handles drain logic independently.

#### `closeGraceDelay` [Unverified — introduced in a specific minor version; verify availability in the version in use]

The time in milliseconds Fastify waits for in-flight requests to complete before forcibly closing. Used in conjunction with `@fastify/close-with-grace`.

---

### Validation and Serialization Options

#### `ajv`

Configuration passed to the AJV instance Fastify uses internally for JSON Schema validation.

```js
const app = require('fastify')({
  ajv: {
    customOptions: {
      strict: 'log',
      coerceTypes: 'array',
      useDefaults: true,
      keywords: ['example']
    },
    plugins: [
      require('ajv-formats')
    ]
  }
})
```

**Key Points**

- `customOptions` maps directly to AJV constructor options
- `plugins` is an array of AJV plugin functions applied after the AJV instance is created
- Changing AJV options affects all route schema validation globally

#### `schemaController`

An advanced option for replacing Fastify's schema compilation and validation infrastructure.

```js
const app = require('fastify')({
  schemaController: {
    bucket: (parentSchemas) => { /* custom schema bucket */ },
    compilersFactory: {
      buildValidator: (externalSchemas, ajvOptions) => { /* custom validator */ },
      buildSerializer: (externalSchemas, serializerOptions) => { /* custom serializer */ }
    }
  }
})
```

[Inference] This option is intended for advanced use cases such as replacing AJV with a different validator or integrating custom serialization. Incorrect implementation may break schema validation globally.

#### `serializerOpts`

Options passed to the `fast-json-stringify` instance used for response serialization.

```js
const app = require('fastify')({
  serializerOpts: {
    rounding: 'ceil'
  }
})
```

#### `jsonShorthand`

When `true` (default), allows shorthand JSON Schema definitions in route schemas. When `false`, requires fully explicit JSON Schema objects.

```js
const app = require('fastify')({ jsonShorthand: false })
```

---

### Plugin and Encapsulation Options

#### `pluginTimeout`

Maximum time in milliseconds Fastify waits for a plugin to load before throwing a timeout error. Defaults to `10000` (10 seconds).

```js
const app = require('fastify')({ pluginTimeout: 30000 })
```

Increase this value for plugins with slow initialization (e.g., database connections with retry logic).

---

### Miscellaneous Options

#### `exposeHeadRoutes`

When `true`, Fastify automatically creates `HEAD` routes for every `GET` route registered. Defaults to `true` in Fastify v4+. [Unverified — default value may differ across major versions]

```js
const app = require('fastify')({ exposeHeadRoutes: false })
```

#### `constraints`

Custom route constraints for the router. Allows routes to be matched based on arbitrary request properties beyond method and URL.

```js
const app = require('fastify')({
  constraints: {
    version: require('./versionConstraint')
  }
})
```

[Inference] Custom constraints require implementing the `find-my-way` constraint interface. Behavior and API are tied to the `find-my-way` version bundled with Fastify.

#### `forceCloseConnections`

Controls how Fastify closes keep-alive connections during shutdown.

| Value | Behavior |
|---|---|
| `true` | Force-close all keep-alive connections on `app.close()` |
| `false` | Do not force-close (default) |
| `'idle'` | Close only idle keep-alive connections |

```js
const app = require('fastify')({ forceCloseConnections: 'idle' })
```

---

### Complete Configuration Reference

| Option | Type | Default | Category |
|---|---|---|---|
| `logger` | Boolean / Object | `false` | Logging |
| `loggerInstance` | Object | — | Logging |
| `disableRequestLogging` | Boolean | `false` | Logging |
| `requestIdHeader` | String / `false` | `'request-id'` | Request ID |
| `requestIdLogLabel` | String | `'reqId'` | Request ID |
| `genReqId` | Function | Internal counter | Request ID |
| `caseSensitive` | Boolean | `true` | Routing |
| `ignoreTrailingSlash` | Boolean | `false` | Routing |
| `ignoreDuplicateSlashes` | Boolean | `false` | Routing |
| `maxParamLength` | Number | `100` | Routing |
| `allowUnsafeRegex` | Boolean | `false` | Routing |
| `bodyLimit` | Number | `1048576` | Parsing |
| `trustProxy` | Boolean / String / Array / Number | `false` | Network |
| `http2` | Boolean | `false` | Network |
| `https` | Object | — | Network |
| `serverFactory` | Function | — | Network |
| `rewriteUrl` | Function | — | Network |
| `return503OnClosing` | Boolean | `true` | Shutdown |
| `forceCloseConnections` | Boolean / `'idle'` | `false` | Shutdown |
| `pluginTimeout` | Number | `10000` | Plugins |
| `ajv` | Object | — | Validation |
| `serializerOpts` | Object | — | Serialization |
| `schemaController` | Object | — | Validation |
| `jsonShorthand` | Boolean | `true` | Validation |
| `exposeHeadRoutes` | Boolean | `true` (v4+) | Routing |
| `constraints` | Object | — | Routing |

---

**Conclusion**

The Fastify configuration object provides control over every major behavioral layer of the server — logging, routing, parsing, validation, serialization, network, and lifecycle. Most options have sensible defaults and do not require explicit configuration in typical projects. Options relating to AJV, schema controllers, and server factories are advanced and carry higher implementation risk if misconfigured. All default values should be verified against the specific Fastify major version in use, as defaults have changed across releases.