## Custom error handler with `setErrorHandler`

### What is `setErrorHandler`?

Fastify provides a dedicated mechanism for centralized error handling through `fastify.setErrorHandler()`. Rather than writing per-route try/catch blocks, you register a single handler that intercepts any error thrown or passed to `done()` within the server's scope.

The handler receives three arguments: the `Error` object, the `FastifyRequest`, and the `FastifyReply`. From there, you decide the response shape, log the error, and call `reply.send()`.

js

```
fastify.setErrorHandler(function (error, request, reply) {
  reply.status(500).send({ error: 'Internal Server Error' })
})
```

---

### Signature

ts

```
fastify.setErrorHandler(
  handler: (
    error: FastifyError,
    request: FastifyRequest,
    reply: FastifyReply
  ) => void | Promise<void>
): FastifyInstance
```

The handler may be synchronous or `async`. Fastify detects the return type and awaits accordingly.

---

### How errors reach the handler

Errors flow into `setErrorHandler` from three sources:

- A route handler that `throw`s an error
- A hook (e.g., `onRequest`, `preHandler`) that passes an error to `done(error)` or `throw`s in an async hook
- Fastify's own validation layer, when request validation fails

The diagram below shows this flow:

V

visualize



V

visualize show_widget



---

### Fastify's default error handler

If you do not call `setErrorHandler`, Fastify uses its own built-in handler. That default handler:

- Logs the error via Fastify's logger
- Sends a JSON response using the error's `statusCode` (or `500` if none is set) and `message`

The default response shape looks like:

json

```
{
  "statusCode": 500,
  "error": "Internal Server Error",
  "message": "Something went wrong"
}
```

Registering a custom handler replaces this behavior entirely for the scope it is applied to.

---

### Basic example

js

```
import Fastify from 'fastify'

const fastify = Fastify({ logger: true })

fastify.setErrorHandler(function (error, request, reply) {
  request.log.error(error)

  const statusCode = error.statusCode ?? 500

  reply.status(statusCode).send({
    success: false,
    statusCode,
    message: error.message || 'An unexpected error occurred',
  })
})

fastify.get('/boom', async () => {
  throw new Error('Something broke')
})

await fastify.listen({ port: 3000 })
```

**Output** (on GET `/boom`):

json

```
{
  "success": false,
  "statusCode": 500,
  "message": "Something broke"
}
```

---

### Using `http-errors` or custom error classes

Fastify errors carry an optional `statusCode` property. The most common pattern is to use a library like `@fastify/http-errors` or `http-errors` to throw semantically meaningful errors.

js

```
import createError from 'http-errors'

fastify.get('/secure', async (request) => {
  if (!request.headers.authorization) {
    throw createError(401, 'Authorization header missing')
  }
  return { data: 'protected' }
})

fastify.setErrorHandler(function (error, request, reply) {
  const statusCode = error.statusCode ?? 500
  reply.status(statusCode).send({
    statusCode,
    error: error.name,
    message: error.message,
  })
})
```

Alternatively, define your own error subclass:

js

```
class AppError extends Error {
  constructor(message, statusCode = 500) {
    super(message)
    this.name = 'AppError'
    this.statusCode = statusCode
  }
}

fastify.get('/resource', async () => {
  throw new AppError('Resource not found', 404)
})
```

---

### Async error handlers

The handler may be `async`. Fastify awaits it automatically. [Inference: this relies on Fastify's internal error handler pipeline detecting the returned Promise; behavior may vary if you mix async and synchronous `reply.send()` patterns within the same handler.]

js

```
fastify.setErrorHandler(async function (error, request, reply) {
  await someLoggingService.record(error)

  reply.status(error.statusCode ?? 500).send({
    message: error.message,
  })
})
```

---

### Handling validation errors

When a request fails JSON Schema validation, Fastify generates an error of type `FST_ERR_VALIDATION`. The error object has:

- `statusCode`: `400`
- `validation`: an array of AJV validation error objects
- `validationContext`: the part of the request that failed (e.g., `'body'`, `'querystring'`)

js

```
fastify.setErrorHandler(function (error, request, reply) {
  if (error.validation) {
    return reply.status(400).send({
      statusCode: 400,
      error: 'Validation Error',
      context: error.validationContext,
      details: error.validation,
    })
  }

  reply.status(error.statusCode ?? 500).send({
    statusCode: error.statusCode ?? 500,
    message: error.message,
  })
})
```

**Example `details` array entry:**

json

```
{
  "instancePath": "/age",
  "schemaPath": "#/properties/age/minimum",
  "keyword": "minimum",
  "params": { "limit": 0 },
  "message": "must be >= 0"
}
```

---

### Scope-aware error handlers

`setErrorHandler` respects Fastify's plugin encapsulation model. A handler registered inside an `fastify.register()` scope applies only to routes within that scope. The root-level handler acts as a fallback when no scoped handler matches.

js

```
fastify.setErrorHandler(function (error, request, reply) {
  // Root fallback
  reply.status(500).send({ message: 'Global error' })
})

fastify.register(async function adminPlugin(instance) {
  instance.setErrorHandler(function (error, request, reply) {
    // Only applies to routes registered inside adminPlugin
    reply.status(error.statusCode ?? 500).send({
      admin: true,
      message: error.message,
    })
  })

  instance.get('/admin/data', async () => {
    throw new Error('Admin failure')
  })
})

fastify.get('/public', async () => {
  throw new Error('Public failure') // → hits root handler
})
```

**Key Points:**

- Scoped handlers do not affect parent or sibling scopes.
- If a scoped handler is not found, Fastify walks up the scope chain to the nearest registered handler.
- This mirrors how `addHook` and `decorate` behave within Fastify's encapsulation model.

---

### Re-throwing from the error handler

If your error handler itself throws, Fastify catches that secondary error and sends a `500` using its internal fallback. This is a last-resort mechanism. [Inference: deliberately re-throwing is generally not recommended as the fallback response is minimal and bypasses your custom shape.]

---

### Sending a reply from inside a hook vs. the error handler

If a hook calls `reply.send()` directly (e.g., in `onRequest` to reject auth early), the error handler is **not** invoked. The error handler is only triggered when an error propagates — not when a hook sends a response intentionally.

---

### Error handler and `reply.sent`

Once `reply.sent` is `true`, calling `reply.send()` again has no effect. Within the error handler, Fastify has not yet sent the response (assuming the error originated from a route or hook, not from calling `reply.send()` after the response was already sent). Always check `reply.sent` if your handler may be reached from unusual paths.

js

```
fastify.setErrorHandler(function (error, request, reply) {
  if (reply.sent) return  // Response already gone; nothing to do
  reply.status(500).send({ message: error.message })
})
```

---

### Practical pattern: centralized error classification

A common production pattern is to classify errors by type in a single handler and delegate to different response formats.

js

```
fastify.setErrorHandler(function (error, request, reply) {
  // Validation errors (from JSON Schema)
  if (error.validation) {
    return reply.status(400).send({
      type: 'VALIDATION_ERROR',
      details: error.validation,
    })
  }

  // Known application errors with explicit status codes
  if (error.statusCode && error.statusCode < 500) {
    return reply.status(error.statusCode).send({
      type: 'CLIENT_ERROR',
      message: error.message,
    })
  }

  // Unknown / server-side errors — log and obscure
  request.log.error({ err: error }, 'Unhandled server error')
  reply.status(500).send({
    type: 'SERVER_ERROR',
    message: 'An internal error occurred',
  })
})
```

This pattern keeps error response shapes consistent and avoids leaking stack traces or internal messages to clients on server-side failures.

---

### Summary table

| Scenario                             | Reaches `setErrorHandler`?           |
| ------------------------------------ | ------------------------------------ |
| Route handler `throw`s               | Yes                                  |
| Async route rejects                  | Yes                                  |
| Hook passes `done(err)`              | Yes                                  |
| Async hook `throw`s                  | Yes                                  |
| JSON Schema validation fails         | Yes                                  |
| Hook calls `reply.send()` directly   | No                                   |
| Response already sent (`reply.sent`) | No — but handler may still be called |
| Error handler itself throws          | Secondary fallback, not re-entered   |