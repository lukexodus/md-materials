## HTTP errors with `@fastify/sensible`

### What is `@fastify/sensible`?

`@fastify/sensible` is an official Fastify plugin that adds a collection of utilities to the `fastify` and `reply` instances. Its primary contribution to error handling is a set of named HTTP error methods that let you throw or send semantically meaningful errors without manually constructing error objects or memorizing status codes.

It also adds `reply.vary`, `reply.cacheControl`, assertion helpers, and a few other conveniences — but error handling is its most-used feature in practice.

---

### Installation and registration

bash

```
npm install @fastify/sensible
```

js

```
import Fastify from 'fastify'
import sensible from '@fastify/sensible'

const fastify = Fastify()
await fastify.register(sensible)
```

After registration, error methods are available on both `fastify.httpErrors` and `reply.httpErrors`, and shorthand methods are available directly on `reply`.

---

### Two ways to use it

`@fastify/sensible` exposes errors in two forms:

**1. `fastify.httpErrors.<name>(message?)` — creates an error object**

Use this when you want to `throw` an error from a route or helper function:

js

```
fastify.get('/user/:id', async (request) => {
  const user = await db.findUser(request.params.id)
  if (!user) {
    throw fastify.httpErrors.notFound('User not found')
  }
  return user
})
```

**2. `reply.<name>(message?)` — sends the response directly**

Use this when you are inside a handler and want to immediately send without throwing:

js

```
fastify.get('/restricted', async (request, reply) => {
  if (!request.headers.authorization) {
    return reply.unauthorized('Missing authorization header')
  }
  return { data: 'ok' }
})
```

Both forms produce a properly shaped error with the correct `statusCode`, `error` name, and `message`. [Inference: the underlying error objects are compatible with `http-errors`-style errors; behavior of downstream error handlers may vary depending on how they inspect the error.]

---

### Available error methods

The table below lists the named methods grouped by HTTP status class. Each corresponds to a standard HTTP status code.

#### 4xx — client errors

| Method | Status | HTTP error name |
| --- | --- | --- |
| `badRequest(msg?)` | 400 | Bad Request |
| `unauthorized(msg?)` | 401 | Unauthorized |
| `paymentRequired(msg?)` | 402 | Payment Required |
| `forbidden(msg?)` | 403 | Forbidden |
| `notFound(msg?)` | 404 | Not Found |
| `methodNotAllowed(msg?)` | 405 | Method Not Allowed |
| `notAcceptable(msg?)` | 406 | Not Acceptable |
| `proxyAuthRequired(msg?)` | 407 | Proxy Auth Required |
| `clientTimeout(msg?)` | 408 | Request Timeout |
| `conflict(msg?)` | 409 | Conflict |
| `gone(msg?)` | 410 | Gone |
| `lengthRequired(msg?)` | 411 | Length Required |
| `preconditionFailed(msg?)` | 412 | Precondition Failed |
| `payloadTooLarge(msg?)` | 413 | Payload Too Large |
| `uriTooLong(msg?)` | 414 | URI Too Long |
| `unsupportedMediaType(msg?)` | 415 | Unsupported Media Type |
| `rangeNotSatisfiable(msg?)` | 416 | Range Not Satisfiable |
| `expectationFailed(msg?)` | 417 | Expectation Failed |
| `imATeapot(msg?)` | 418 | I'm a Teapot |
| `misdirectedRequest(msg?)` | 421 | Misdirected Request |
| `unprocessableEntity(msg?)` | 422 | Unprocessable Entity |
| `locked(msg?)` | 423 | Locked |
| `failedDependency(msg?)` | 424 | Failed Dependency |
| `tooEarly(msg?)` | 425 | Too Early |
| `upgradeRequired(msg?)` | 426 | Upgrade Required |
| `preconditionRequired(msg?)` | 428 | Precondition Required |
| `tooManyRequests(msg?)` | 429 | Too Many Requests |
| `requestHeaderFieldsTooLarge(msg?)` | 431 | Request Header Fields Too Large |
| `unavailableForLegalReasons(msg?)` | 451 | Unavailable For Legal Reasons |

#### 5xx — server errors

| Method | Status | HTTP error name |
| --- | --- | --- |
| `internalServerError(msg?)` | 500 | Internal Server Error |
| `notImplemented(msg?)` | 501 | Not Implemented |
| `badGateway(msg?)` | 502 | Bad Gateway |
| `serviceUnavailable(msg?)` | 503 | Service Unavailable |
| `gatewayTimeout(msg?)` | 504 | Gateway Timeout |
| `httpVersionNotSupported(msg?)` | 505 | HTTP Version Not Supported |
| `variantAlsoNegotiates(msg?)` | 506 | Variant Also Negotiates |
| `insufficientStorage(msg?)` | 507 | Insufficient Storage |
| `loopDetected(msg?)` | 508 | Loop Detected |
| `bandwidthLimitExceeded(msg?)` | 509 | Bandwidth Limit Exceeded |
| `notExtended(msg?)` | 510 | Not Extended |
| `networkAuthenticationRequired(msg?)` | 511 | Network Authentication Required |

---

### Response shape

When an error is thrown or sent via these methods, the response body follows this structure:

json

```
{
  "statusCode": 404,
  "error": "Not Found",
  "message": "User not found"
}
```

If no message is passed, `message` defaults to the HTTP status phrase (e.g., `"Not Found"`).

---

### Practical examples

#### Authorization check

js

```
fastify.get('/profile', async (request, reply) => {
  if (!request.user) {
    throw fastify.httpErrors.unauthorized()
  }
  return request.user
})
```

#### Resource lookup

js

```
fastify.get('/posts/:id', async (request) => {
  const post = await db.getPost(request.params.id)
  if (!post) throw fastify.httpErrors.notFound(`Post ${request.params.id} not found`)
  return post
})
```

#### Conflict on creation

js

```
fastify.post('/users', async (request) => {
  const existing = await db.findByEmail(request.body.email)
  if (existing) throw fastify.httpErrors.conflict('Email already registered')
  return db.createUser(request.body)
})
```

#### Rate limiting (manual)

js

```
fastify.addHook('onRequest', async (request) => {
  const allowed = await rateLimiter.check(request.ip)
  if (!allowed) throw fastify.httpErrors.tooManyRequests('Rate limit exceeded')
})
```

---

### Using `createError` for reusable factories

`@fastify/sensible` also exposes `fastify.httpErrors.createError(statusCode, message)` for constructing arbitrary HTTP errors by status code when the named methods don't cover your case:

js

```
const err = fastify.httpErrors.createError(418, "I'm a teapot and proud of it")
throw err
```

This is useful when the status code is determined dynamically.

---

### Integration with `setErrorHandler`

Errors thrown via `@fastify/sensible` carry a `statusCode` property, so they integrate cleanly with a custom `setErrorHandler`:

js

```
fastify.setErrorHandler(function (error, request, reply) {
  const statusCode = error.statusCode ?? 500

  if (statusCode < 500) {
    return reply.status(statusCode).send({
      statusCode,
      error: error.name,
      message: error.message,
    })
  }

  request.log.error(error)
  reply.status(500).send({
    statusCode: 500,
    error: 'Internal Server Error',
    message: 'Something went wrong',
  })
})
```

The flow looks like this:

V

visualize



V

visualize show_widget



---

### `assert` helpers

Beyond HTTP errors, `@fastify/sensible` also adds `fastify.assert` — a set of assertion helpers that throw HTTP errors when a condition is falsy. This is a concise alternative to explicit `if` guards.

js

```
fastify.get('/item/:id', async (request) => {
  const item = await db.find(request.params.id)

  fastify.assert(item, 404, 'Item not found')
  fastify.assert.ok(item.active, 403, 'Item is inactive')
  fastify.assert.equal(item.owner, request.user.id, 403, 'Forbidden')
  fastify.assert.notEqual(item.status, 'deleted', 410, 'Item is gone')

  return item
})
```

Available assert variants:

| Method | Throws when |
| --- | --- |
| `fastify.assert(val, code, msg)` | `val` is falsy |
| `fastify.assert.ok(val, code, msg)` | `val` is falsy |
| `fastify.assert.equal(a, b, code, msg)` | `a != b` |
| `fastify.assert.notEqual(a, b, code, msg)` | `a == b` |
| `fastify.assert.strictEqual(a, b, code, msg)` | `a !== b` |
| `fastify.assert.notStrictEqual(a, b, code, msg)` | `a === b` |
| `fastify.assert.deepEqual(a, b, code, msg)` | deep inequality |
| `fastify.assert.notDeepEqual(a, b, code, msg)` | deep equality |

---

### Scope behavior

`@fastify/sensible` decorates the root `fastify` instance. Because Fastify decorators registered on the root are accessible across all scopes, `fastify.httpErrors` is available everywhere — including inside child plugins. [Inference: this relies on decorator propagation behavior; verify if you are using `fastify-plugin` wrappers that alter encapsulation.]

---

### Summary

| Approach | When to use |
| --- | --- |
| `throw fastify.httpErrors.notFound()` | Inside async route or helper |
| `return reply.notFound()` | Inside handler, want to send immediately |
| `fastify.assert(val, 404, msg)` | Inline guard — concise alternative to `if` |
| `fastify.httpErrors.createError(code, msg)` | Dynamic status code at runtime |