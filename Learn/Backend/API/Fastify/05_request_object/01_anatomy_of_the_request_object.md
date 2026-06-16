### Anatomy of the Request Object

Fastify wraps the native Node.js `IncomingMessage` in its own `Request` object, exposing a structured, Fastify-specific interface. This object is the first argument passed to every route handler and hook that operates on incoming data.

---

#### The Request Object in Context

js

```
fastify.get('/example', async (request, reply) => {
  // `request` is Fastify's Request object
})
```

The raw Node.js request is still accessible but direct use is generally discouraged in favor of Fastify's abstractions.

---

#### `request.id`

A unique identifier assigned to each incoming request by Fastify's request ID generation logic.

js

```
fastify.get('/ping', async (request, reply) => {
  return { requestId: request.id }
})
```

**Key Points:**

- The default ID is an incrementing integer, cast to a string
- You can override the ID generator at the server level via the `genReqId` option
- The request ID is also automatically included in Fastify's log entries for that request

js

```
const fastify = Fastify({
  genReqId: (req) => `custom-${Date.now()}`
})
```

---

#### `request.params`

Contains the route parameter values parsed from the URL path.

js

```
fastify.get('/user/:id/post/:postId', async (request, reply) => {
  const { id, postId } = request.params
  return { id, postId }
})
```

**Key Points:**

- Keys correspond to the named segments defined in the route pattern
- Values are always strings — type coercion is not applied automatically
- Validated and transformed if a JSON Schema is defined for `params`

---

#### `request.query`

Contains the parsed query string as a plain object.

js

```
// GET /search?term=fastify&page=2
fastify.get('/search', async (request, reply) => {
  const { term, page } = request.query
  return { term, page }
})
```

**Key Points:**

- Fastify uses the `fast-querystring` parser by default (as of recent versions — verify against your installed version)
- You can replace the query string parser via the `querystringParser` server option
- Values are strings unless a schema with `coerceTypes` is applied

---

#### `request.body`

Contains the parsed request body. Only populated for methods that carry a body (`POST`, `PUT`, `PATCH`, etc.).

js

```
fastify.post('/user', async (request, reply) => {
  const { name, email } = request.body
  return { received: true, name }
})
```

**Key Points:**

- Fastify parses `application/json` bodies by default
- `text/plain` and `application/x-www-form-urlencoded` require additional content type parsers or plugins
- `request.body` is `null` for requests without a body or with an unsupported content type (behavior may vary by configuration)
- Validation via JSON Schema runs after parsing, before the handler

---

#### `request.headers`

A plain object containing the incoming HTTP headers, keyed in lowercase.

js

```
fastify.get('/info', async (request, reply) => {
  const auth = request.headers['authorization']
  const contentType = request.headers['content-type']
  return { auth, contentType }
})
```

**Key Points:**

- All header names are lowercased per the HTTP/1.1 spec and Node.js behavior
- Mutating `request.headers` directly is possible but not recommended — behavior may vary across lifecycle hooks
- Custom headers set by clients are accessible here directly

---

#### `request.raw`

The underlying Node.js `http.IncomingMessage` object.

js

```
fastify.get('/raw', async (request, reply) => {
  const nodeReq = request.raw
  // nodeReq is the native Node.js request
})
```

**Key Points:**

- Useful when you need access to the raw stream, socket, or properties not exposed by Fastify's abstraction
- Direct use bypasses Fastify's parsing and validation — use with caution

---

#### `request.server`

A reference to the Fastify instance that received the request.

js

```
fastify.get('/status', async (request, reply) => {
  const instance = request.server
  // access decorators, plugins, etc.
})
```

[Inference] This is useful when you need to access server-level decorators or services from within a handler without closing over the `fastify` variable directly. Behavior is consistent with encapsulation boundaries — decorated properties may not be visible across plugin scopes.

---

#### `request.log`

A child logger scoped to the current request, automatically tagged with `request.id`.

js

```
fastify.get('/log-demo', async (request, reply) => {
  request.log.info('Handler reached')
  request.log.warn({ userId: 42 }, 'Something to watch')
  return { ok: true }
})
```

**Key Points:**

- Built on Pino — the same logger as `fastify.log`, but child-scoped
- All log entries from `request.log` automatically include the request ID
- Prefer `request.log` over `console.log` or `fastify.log` inside handlers for traceable, correlated output

---

#### `request.method`

The HTTP method of the incoming request, as an uppercase string.

js

```
request.method // e.g., 'GET', 'POST', 'DELETE'
```

---

#### `request.url`

The raw URL string including the path and query string, as received by Node.js.

js

```
// GET /search?q=hello
request.url // '/search?q=hello'
```

**Key Points:**

- This is the raw, unparsed URL — not just the pathname
- For the parsed query string, use `request.query`
- For route parameters, use `request.params`

---

#### `request.routerPath` and `request.routeOptions.url`

`request.routerPath` exposes the route pattern that matched the request, as opposed to the actual URL.

js

```
fastify.get('/user/:id', async (request, reply) => {
  console.log(request.url)         // '/user/42'
  console.log(request.routerPath)  // '/user/:id'
})
```

> [Unverified] `request.routerPath` is available in earlier Fastify versions. In Fastify v4+, `request.routeOptions.url` is the preferred property for accessing the matched route pattern. Verify against your installed version's changelog.

---

#### `request.routeOptions`

An object containing the options the matched route was registered with.

js

```
fastify.get('/typed', {
  config: { role: 'admin' },
  handler: async (request, reply) => {
    console.log(request.routeOptions.config) // { role: 'admin' }
  }
})
```

**Key Points:**

- Useful for accessing per-route metadata inside shared hooks or handlers
- `request.routeOptions.config` is commonly used to attach authorization metadata or feature flags to routes

---

#### `request.ip` and `request.ips`

`request.ip` returns the client's IP address. `request.ips` returns an array when `trustProxy` is enabled and `X-Forwarded-For` headers are present.

js

```
const fastify = Fastify({ trustProxy: true })

fastify.get('/who', async (request, reply) => {
  return {
    ip: request.ip,
    ips: request.ips   // available only when trustProxy is enabled
  }
})
```

**Key Points:**

- Without `trustProxy`, `request.ip` reflects the direct socket remote address
- With `trustProxy`, Fastify parses `X-Forwarded-For` to determine the originating IP
- `request.ips` is `undefined` when `trustProxy` is not enabled

---

#### `request.hostname`

The hostname derived from the `Host` header (or `X-Forwarded-Host` when `trustProxy` is enabled).

js

```
request.hostname // e.g., 'api.example.com'
```

---

#### `request.protocol`

The protocol string, either `'http'` or `'https'`.

js

```
request.protocol // 'https'
```

> [Inference] When running behind a reverse proxy, `request.protocol` reflects the forwarded protocol if `trustProxy` is enabled. Without it, the value is derived from the socket connection type. Behavior may vary by environment.

---

#### Custom Properties via Decorators

You can extend the `Request` object with custom properties using `fastify.decorateRequest`.

js

```
fastify.decorateRequest('user', null)

fastify.addHook('preHandler', async (request, reply) => {
  request.user = await getUserFromToken(request.headers.authorization)
})

fastify.get('/profile', async (request, reply) => {
  return { user: request.user }
})
```

**Key Points:**

- Always declare the decorator before use, ideally at server startup
- The initial value passed to `decorateRequest` should match the intended type — using `null` for objects is a common pattern
- TypeScript users can augment the `FastifyRequest` interface to get type-safe access to decorated properties

---

#### Property Reference Summary

| Property | Type | Description |
| --- | --- | --- |
| `request.id` | `string` | Unique request identifier |
| `request.params` | `object` | Parsed URL path parameters |
| `request.query` | `object` | Parsed query string |
| `request.body` | `any` | Parsed request body |
| `request.headers` | `object` | Incoming HTTP headers (lowercased) |
| `request.raw` | `IncomingMessage` | Native Node.js request object |
| `request.server` | `FastifyInstance` | The Fastify server instance |
| `request.log` | `Logger` | Request-scoped Pino child logger |
| `request.method` | `string` | HTTP method (uppercase) |
| `request.url` | `string` | Raw URL with query string |
| `request.routerPath` | `string` | Matched route pattern |
| `request.routeOptions` | `object` | Route registration options |
| `request.ip` | `string` | Client IP address |
| `request.ips` | `string[]` | Proxy chain IPs (trustProxy only) |
| `request.hostname` | `string` | Derived hostname |
| `request.protocol` | `string` | `'http'` or `'https'` |

---

#### Related Topics

- Anatomy of the Reply object
- JSON Schema validation for params, query, body, and headers
- `decorateRequest` and plugin encapsulation
- Lifecycle hooks and request mutation