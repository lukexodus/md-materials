## Adding Middleware with addHook

### Overview

Fastify's native alternative to Express-style middleware is its hook system, exposed through the `addHook` method. Rather than a linear middleware chain, Fastify uses discrete lifecycle events at which you can intercept and act on requests, replies, or the application itself. `addHook` is the primary mechanism for registering functions that execute at specific points in this lifecycle.

This is the idiomatic Fastify approach to cross-cutting concerns such as authentication, logging, request mutation, and response transformation.

---

### The Fastify Request Lifecycle

Understanding where hooks fit requires understanding the lifecycle order:

```
Incoming Request
       │
       ▼
  onRequest
       │
       ▼
  preParsing
       │
       ▼
  Body Parsing
       │
       ▼
  preValidation
       │
       ▼
  Validation
       │
       ▼
  preHandler
       │
       ▼
  Route Handler
       │
       ▼
  preSerialization
       │
       ▼
  Serialization
       │
       ▼
  onSend
       │
       ▼
  Response Sent
       │
       ▼
  onResponse
```

Each named point above corresponds to a hookable lifecycle event.

---

### Syntax

```js
fastify.addHook(hookName, handlerFunction)
```

Hook handler signatures vary by hook type. Request/reply hooks receive Fastify's decorated `request` and `reply` objects, unlike `@fastify/middie` middleware which receives raw Node.js objects.

---

### Request/Reply Lifecycle Hooks

These hooks participate in the per-request pipeline.

#### onRequest

Runs first, before any parsing. Suitable for authentication checks, IP filtering, or early rejection.

```js
fastify.addHook('onRequest', async (request, reply) => {
  if (!request.headers['x-api-key']) {
    reply.code(401).send({ error: 'Missing API key' })
  }
})
```

**Key Points:**
- `request.body` is not yet available at this stage
- Calling `reply.send()` here short-circuits the lifecycle — the route handler will not execute
- Async handlers that throw will be caught by Fastify's error handler

#### preParsing

Runs after `onRequest` but before the body is parsed. Receives an additional `payload` argument — the raw readable stream of the request body.

```js
fastify.addHook('preParsing', async (request, reply, payload) => {
  // payload is a Node.js Readable stream
  // Must return the payload (original or replaced)
  return payload
})
```

**Key Points:**
- You must return the payload from this hook, even if unchanged
- This hook is suited for body decryption or decompression before Fastify's parsers run

#### preValidation

Runs after parsing, before schema validation. `request.body`, `request.query`, and `request.params` are populated.

```js
fastify.addHook('preValidation', async (request, reply) => {
  // Normalize input before it hits the schema validator
  if (request.body && typeof request.body.email === 'string') {
    request.body.email = request.body.email.toLowerCase()
  }
})
```

#### preHandler

Runs after validation, immediately before the route handler. This is the closest equivalent to Express's `app.use()` middleware in terms of timing.

```js
fastify.addHook('preHandler', async (request, reply) => {
  const user = await getUserFromToken(request.headers.authorization)
  if (!user) {
    reply.code(403).send({ error: 'Forbidden' })
    return
  }
  request.user = user
})
```

**Key Points:**
- `request.body` is available and validated at this point
- Attaching data to `request` here (e.g., `request.user`) makes it accessible in the route handler
- [Inference] This is the most commonly used hook for authentication and authorization logic, though the appropriate hook depends on your specific requirements

#### preSerialization

Runs after the route handler returns a payload, before serialization. Receives the payload as a third argument.

```js
fastify.addHook('preSerialization', async (request, reply, payload) => {
  // Wrap all responses in a standard envelope
  return { data: payload, timestamp: Date.now() }
})
```

**Key Points:**
- Must return the payload (modified or original)
- Does not run if the payload is a `string`, `Buffer`, `stream`, or `null`

#### onSend

Runs after serialization, just before the response is sent. The serialized payload (a string or Buffer) is passed as the third argument.

```js
fastify.addHook('onSend', async (request, reply, payload) => {
  reply.header('X-Response-Time', Date.now() - request.startTime)
  return payload
})
```

**Key Points:**
- Must return the payload
- At this stage the payload is already serialized — modifying it means working with raw strings or Buffers
- Suitable for adding response headers

#### onResponse

Runs after the response has been sent to the client. Cannot modify the response.

```js
fastify.addHook('onResponse', async (request, reply) => {
  fastify.log.info({
    url: request.url,
    statusCode: reply.statusCode,
    responseTime: reply.elapsedTime
  })
})
```

**Key Points:**
- Errors thrown here do not affect the client — the response is already sent
- Suitable for cleanup tasks, metrics recording, or audit logging

---

### Error Lifecycle Hook

#### onError

Runs when an error is passed to Fastify's error pipeline, before the error handler serializes the response.

```js
fastify.addHook('onError', async (request, reply, error) => {
  // Log to an external error tracker
  await externalTracker.capture(error, { url: request.url })
})
```

**Key Points:**
- This hook cannot modify the error or change the response — use `setErrorHandler` for that
- Intended for side effects such as error reporting and observability

---

### Application Lifecycle Hooks

These hooks fire at the application level, not per request.

#### onReady

Fires when Fastify has finished loading all plugins and is about to start listening.

```js
fastify.addHook('onReady', async () => {
  await warmUpCache()
})
```

#### onClose

Fires when `fastify.close()` is called. Suitable for cleanup — closing database connections, flushing buffers.

```js
fastify.addHook('onClose', async (instance) => {
  await instance.db.disconnect()
})
```

#### onListen

Fires after the server begins accepting connections.

```js
fastify.addHook('onListen', async () => {
  console.log('Server is accepting connections')
})
```

---

### Multiple Hooks on the Same Event

Multiple handlers can be registered for the same hook name. They execute in registration order.

```js
fastify.addHook('onRequest', async (request, reply) => {
  request.startTime = Date.now()
})

fastify.addHook('onRequest', async (request, reply) => {
  fastify.log.info('Request received: ' + request.url)
})
```

**Key Points:**
- All registered handlers for a hook run sequentially
- If any handler sends a reply or throws, subsequent handlers in that hook phase do not run

---

### Scoping Hooks with the Plugin System

Hooks registered inside a plugin scope apply only to routes within that scope. This is one of Fastify's most important encapsulation features.

```js
fastify.register(async function publicRoutes(instance) {
  // No hooks here — public access
  instance.get('/health', async () => ({ status: 'ok' }))
})

fastify.register(async function privateRoutes(instance) {
  instance.addHook('onRequest', async (request, reply) => {
    if (!request.headers.authorization) {
      reply.code(401).send({ error: 'Unauthorized' })
    }
  })

  instance.get('/profile', async (request) => {
    return { user: 'data' }
  })
})
```

**Key Points:**
- The `onRequest` hook above applies only to `/profile` and any other routes in `privateRoutes`
- Routes in `publicRoutes` are unaffected
- To apply a hook globally across all scopes, register it on the root `fastify` instance before any `register` calls, or use `fastify-plugin` to escape encapsulation

---

### Callback-Style Hooks

Hooks also support the callback `(request, reply, done)` signature as an alternative to async.

```js
fastify.addHook('onRequest', (request, reply, done) => {
  request.startTime = Date.now()
  done()
})
```

**Key Points:**
- `done()` must always be called, or the request pipeline will stall
- Pass an error as the first argument to `done(err)` to trigger the error pipeline
- Mixing async and callback styles within the same hook registration is not supported — choose one per handler

---

### Hook Handler Summary

| Hook | Body Available | Can Modify Payload | Can Short-Circuit |
|---|---|---|---|
| `onRequest` | No | No | Yes |
| `preParsing` | Stream only | Yes (return new stream) | Yes |
| `preValidation` | Yes | Yes | Yes |
| `preHandler` | Yes (validated) | Yes | Yes |
| `preSerialization` | Yes | Yes (return new payload) | No |
| `onSend` | Serialized only | Yes (return new payload) | No |
| `onResponse` | No | No | No |
| `onError` | No | No | No |

---

### Comparison with Express Middleware

| Aspect | Express `app.use()` | Fastify `addHook()` |
|---|---|---|
| Signature | `(req, res, next)` | `(request, reply, [done])` |
| Objects | Raw Node.js | Fastify-decorated |
| Lifecycle placement | Single chain | Discrete named phases |
| Async support | Limited (depends on version) | Native |
| Scoping | Manual | Automatic via plugin encapsulation |
| Body access | After body-parser middleware | From `preValidation` onward |

---

**Conclusion:** `addHook` is the idiomatic, performant way to implement cross-cutting behavior in Fastify. Choosing the correct hook depends on what data you need and at what point in the lifecycle you need to act. For authentication and authorization, `onRequest` or `preHandler` are typical choices. For response transformation, `preSerialization` or `onSend` are appropriate. Fastify's encapsulation model makes scoped hooks a powerful tool for applying behavior selectively without polluting the global request pipeline.