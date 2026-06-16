## Fastify — Default Error Handling Behavior

### Overview

Fastify has a built-in error handling system that intercepts errors thrown or passed during the request lifecycle and converts them into structured HTTP responses. Understanding the default behavior — what Fastify catches, how it formats errors, and where in the lifecycle errors are handled — is necessary before customizing or extending error handling.

---

### How Fastify Catches Errors

Fastify wraps route handlers and hooks in error-catching logic. When an error is thrown (or a rejected promise propagates), Fastify intercepts it and passes it to the error handler rather than crashing the process.

js

```
import Fastify from 'fastify'

const fastify = Fastify()

fastify.get('/error', async (request, reply) => {
  throw new Error('something went wrong')
})

await fastify.listen({ port: 3000 })
```

**Output** (GET `/error`):

json

```
{
  "statusCode": 500,
  "error": "Internal Server Error",
  "message": "something went wrong"
}
```

**Key Points:**

- The thrown `Error` is caught automatically
- Fastify responds with HTTP `500` by default for generic errors
- The response body follows Fastify's default error schema

---

### Default Error Response Shape

Fastify's default error response is a JSON object with three fields.

json

```
{
  "statusCode": 400,
  "error": "Bad Request",
  "message": "A descriptive message"
}
```

| Field | Type | Description |
| --- | --- | --- |
| `statusCode` | `number` | The HTTP status code |
| `error` | `string` | The standard HTTP reason phrase for the status |
| `message` | `string` | The error message string |

This shape is produced by the default error serializer and is consistent across all unhandled errors unless overridden.

---

### HTTP Errors with `@fastify/sensible` vs Plain Errors

A plain `new Error()` always produces a `500` response. To produce a specific HTTP status code, use an HTTP error object — either from `@fastify/sensible` or by manually setting `statusCode` on the error.

#### Setting `statusCode` manually

js

```
fastify.get('/not-found', async (request, reply) => {
  const err = new Error('Resource not found')
  err.statusCode = 404
  throw err
})
```

**Output**:

json

```
{
  "statusCode": 404,
  "error": "Not Found",
  "message": "Resource not found"
}
```

#### Using `reply.code()` and `send()`

js

```
fastify.get('/forbidden', async (request, reply) => {
  return reply.code(403).send({ message: 'Forbidden' })
})
```

This bypasses the error handler entirely — the response is sent directly. The error handler is only invoked when an error is thrown or passed via `reply.send(error)`.

---

### `reply.send(error)`

Passing an `Error` instance directly to `reply.send()` triggers the error handler.

js

```
fastify.get('/manual', async (request, reply) => {
  const err = new Error('manually sent error')
  err.statusCode = 422
  reply.send(err)
})
```

**Output**:

json

```
{
  "statusCode": 422,
  "error": "Unprocessable Entity",
  "message": "manually sent error"
}
```

**Key Points:**

- Passing an `Error` to `reply.send()` is equivalent to throwing it from a handler
- The default error handler processes it the same way
- Non-error values passed to `reply.send()` are sent as normal responses

---

### Where the Error Handler Sits in the Lifecycle

Fastify's error handler is invoked when an error propagates out of any hook or handler in the lifecycle. It is not a hook itself but a dedicated handler registered on the instance.

```
onRequest → preParsing → preValidation → preHandler → handler
                                                          ↓ (error thrown)
                                                    Error Handler
                                                          ↓
                                                       onSend
                                                          ↓
                                                    onResponse
```

**Key Points:**

- Errors from any lifecycle phase route to the error handler
- After the error handler runs, the `onSend` hook still fires
- `onResponse` fires after the response is sent regardless of whether an error occurred
- [Inference] If an error occurs inside `onSend` itself, behavior may differ by version — consult Fastify documentation for the version in use

---

### Validation Errors

Fastify performs automatic input validation using JSON Schema. When a request fails validation, Fastify generates a `400 Bad Request` error without invoking the route handler.

js

```
fastify.post('/user', {
  schema: {
    body: {
      type: 'object',
      required: ['name'],
      properties: {
        name: { type: 'string' }
      }
    }
  }
}, async (request, reply) => {
  return request.body
})
```

**Request** (POST `/user` with body `{}`):

**Output**:

json

```
{
  "statusCode": 400,
  "error": "Bad Request",
  "message": "body must have required property 'name'"
}
```

**Key Points:**

- Validation errors are generated by Fastify's schema validation layer (powered by Ajv by default)
- The error message reflects the specific validation failure
- The route handler is never called when validation fails
- The message format is determined by Ajv's error reporting and may vary by configuration

---

### 404 — Route Not Found

When no route matches the incoming request, Fastify responds with a `404` using its built-in not-found handler.

**Output** (GET `/nonexistent`):

json

```
{
  "message": "Route GET:/nonexistent not found",
  "error": "Not Found",
  "statusCode": 404
}
```

**Key Points:**

- The not-found handler is separate from the general error handler
- It can be replaced with `fastify.setNotFoundHandler()`
- The default message includes the HTTP method and URL

---

### 405 — Method Not Allowed

If a route exists for a URL but not for the requested HTTP method, Fastify responds with `405`.

**Output** (POST `/users` when only GET is defined):

json

```
{
  "message": "Route POST:/users not found",
  "error": "Not Found",
  "statusCode": 404
}
```

> [Inference] Fastify's default behavior for method-not-allowed may return `404` rather than `405` depending on version and configuration. A true `405` with an `Allow` header is not guaranteed by default. Verify against the version in use.

---

### Async vs Callback-Style Handlers

Fastify handles errors differently depending on whether the handler is async or callback-style.

#### Async handler — throw or return rejected promise

js

```
fastify.get('/async', async (request, reply) => {
  throw new Error('async error') // caught automatically
})
```

#### Callback-style handler — use `reply.send(error)`

js

```
fastify.get('/callback', (request, reply) => {
  reply.send(new Error('callback error'))
})
```

**Key Points:**

- In async handlers, thrown errors and rejected promises are caught by Fastify
- In callback-style handlers, uncaught errors must be passed to `reply.send()`
- Throwing synchronously inside a non-async handler may not be caught reliably by Fastify in all versions — [Inference] based on how Fastify wraps handlers; behavior may vary

---

### The Default Error Handler

Fastify's built-in default error handler is the function that runs when no custom error handler has been set. It:

- Reads `error.statusCode` (or defaults to `500`)
- Derives the HTTP reason phrase from the status code
- Sets the response `Content-Type` to `application/json`
- Sends the standard three-field JSON body

It is equivalent to:

js

```
fastify.setErrorHandler(function (error, request, reply) {
  const statusCode = error.statusCode || 500
  reply.code(statusCode).send({
    statusCode,
    error: httpErrorName(statusCode), // e.g. 'Internal Server Error'
    message: error.message
  })
})
```

> [Inference] The above is a conceptual approximation of the default error handler's behavior based on Fastify's documentation and source. The actual implementation may differ. Behavior is not guaranteed to match this exactly across all versions.

---

### Error Logging

Fastify logs errors automatically using its built-in logger (Pino). By default, errors with a status code of `500` or above are logged at the `error` level; errors with a status code below `500` are logged at the `info` level.

```
{"level":50,"time":...,"msg":"something went wrong","err":{...}}
```

> [Inference] Log level thresholds for errors are based on Fastify's documented behavior. Actual log levels may depend on configuration and Fastify version.

---

### `error.validation` — Validation Error Detail

When a validation error occurs, Fastify attaches a `validation` array to the error object. This contains the raw Ajv validation errors.

js

```
fastify.setErrorHandler((error, request, reply) => {
  if (error.validation) {
    // error.validation is an array of Ajv error objects
    reply.code(400).send({
      statusCode: 400,
      issues: error.validation
    })
    return
  }
  reply.send(error)
})
```

**Key Points:**

- `error.validation` is only present on validation errors
- It gives access to the full Ajv error detail, including field paths and keywords
- This is the primary hook for customizing validation error responses

---

### Common Default Behaviors Summary

| Scenario                               | Default Status   | Default Message Source   |
| -------------------------------------- | ---------------- | ------------------------ |
| Thrown `new Error()`                   | `500`            | `error.message`          |
| Error with `statusCode` set            | That status code | `error.message`          |
| JSON Schema validation failure         | `400`            | Ajv error message        |
| No matching route                      | `404`            | Fastify built-in message |
| Unhandled promise rejection in handler | `500`            | Rejection message        |

---

### Summary

| Concept | Detail |
| --- | --- |
| Error catching | Automatic for async handlers; manual for callback-style |
| Default response shape | `{ statusCode, error, message }` |
| Generic error status | `500` unless `error.statusCode` is set |
| Validation errors | `400`, generated before handler runs |
| Not-found errors | `404`, handled by separate not-found handler |
| Error logging | Automatic via Pino; level depends on status code |
| Validation detail | Available on `error.validation` array |
| Customization point | `fastify.setErrorHandler()` — covered separately |