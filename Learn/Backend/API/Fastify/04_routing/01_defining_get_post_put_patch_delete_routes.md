## Defining GET, POST, PUT, PATCH, DELETE routes

Fastify provides dedicated methods for registering routes that correspond to the five most commonly used HTTP verbs. Each method maps directly to an HTTP operation and follows a consistent API, making route definitions predictable and readable.

---

### HTTP Methods and Their Semantic Purpose

Before examining Fastify's API, it helps to understand the intended role of each HTTP verb, as Fastify's design encourages adherence to these conventions.

| Method | Semantic Purpose | Typical Body? |
|--------|-----------------|---------------|
| GET | Retrieve a resource | No |
| POST | Create a new resource | Yes |
| PUT | Replace a resource entirely | Yes |
| PATCH | Partially update a resource | Yes |
| DELETE | Remove a resource | Optional |

---

### The Shorthand Route Methods

Fastify exposes a shorthand method for each verb directly on the Fastify instance. The general signature is:

```
fastify.<method>(path, [options], handler)
```

The `options` object is optional. The `handler` can be passed inline or provided as a property inside `options`.

---

### GET

GET routes handle data retrieval. The handler receives a request and reply object. Because GET requests conventionally carry no body, Fastify does not parse a body for them by default.

```js
fastify.get('/users', async (request, reply) => {
  return { users: [] }
})
```

**Key Points:**
- Returning a value from an `async` handler automatically serializes it and sends it as the response.
- No `reply.send()` is required when using `return`, though both styles are supported.
- Body parsing is skipped for GET requests. [Behavior may vary depending on plugins or custom parser configuration.]

---

### POST

POST routes handle resource creation. The request body is parsed automatically based on the `Content-Type` header, provided the appropriate content type parser is registered (Fastify includes a JSON parser by default).

```js
fastify.post('/users', async (request, reply) => {
  const { name, email } = request.body
  // persist user...
  reply.code(201).send({ id: 1, name, email })
})
```

**Key Points:**
- `reply.code(201)` sets the HTTP status code before sending.
- `request.body` is populated by Fastify's content type parser.
- If the `Content-Type` header does not match a registered parser, Fastify returns a `415 Unsupported Media Type` error.

---

### PUT

PUT routes conventionally replace an entire resource at a given URI. The client is expected to send the full representation of the resource.

```js
fastify.put('/users/:id', async (request, reply) => {
  const { id } = request.params
  const { name, email } = request.body
  // replace user with id...
  return { id, name, email }
})
```

**Key Points:**
- Route parameters such as `:id` are accessible via `request.params`.
- PUT is intended to be idempotent — calling it multiple times with the same data should produce the same result. Fastify does not enforce idempotency; this is a convention to uphold in application logic.

---

### PATCH

PATCH routes handle partial updates. The client sends only the fields that should change, rather than the full resource.

```js
fastify.patch('/users/:id', async (request, reply) => {
  const { id } = request.params
  const updates = request.body
  // apply partial update...
  return { id, ...updates }
})
```

**Key Points:**
- The distinction between PUT and PATCH is semantic and enforced by application logic, not by Fastify itself.
- PATCH requests are not guaranteed to be idempotent, though they may be designed that way. [Inference based on HTTP specification conventions.]

---

### DELETE

DELETE routes handle resource removal. A body is not required but is allowed by the HTTP specification. Fastify does not parse a body for DELETE requests by default.

```js
fastify.delete('/users/:id', async (request, reply) => {
  const { id } = request.params
  // delete user with id...
  reply.code(204).send()
})
```

**Key Points:**
- `204 No Content` is a common response for successful deletions that return no body.
- `reply.send()` with no arguments sends an empty body.
- If a body is required on DELETE for a specific use case, a custom content type parser and route-level `config` may be needed. [Unverified — consult Fastify documentation for body parsing on DELETE.]

---

### Using the Generic `fastify.route()` Method

All shorthand methods are convenience wrappers around `fastify.route()`, which accepts a single configuration object. This is useful when a route requires extensive configuration or when routes are generated programmatically.

```js
fastify.route({
  method: 'POST',
  url: '/users',
  schema: {
    body: {
      type: 'object',
      required: ['name', 'email'],
      properties: {
        name: { type: 'string' },
        email: { type: 'string', format: 'email' }
      }
    },
    response: {
      201: {
        type: 'object',
        properties: {
          id: { type: 'integer' },
          name: { type: 'string' },
          email: { type: 'string' }
        }
      }
    }
  },
  handler: async (request, reply) => {
    const { name, email } = request.body
    reply.code(201).send({ id: 1, name, email })
  }
})
```

**Key Points:**
- The `method` property also accepts an array of strings (e.g., `['GET', 'HEAD']`) to register multiple methods on the same path with a single declaration.
- The `url` property is used instead of the positional path argument.
- Inline schema definition enables Fastify's built-in validation and response serialization pipeline.

---

### Handling Multiple Methods on One Path

When a single path needs to respond to more than one method, each method is registered separately, or the `route()` method is used with a `method` array.

```js
// Separate shorthand registrations
fastify.get('/items/:id', getItemHandler)
fastify.put('/items/:id', replaceItemHandler)
fastify.patch('/items/:id', updateItemHandler)
fastify.delete('/items/:id', deleteItemHandler)
```

```js
// Combined via fastify.route()
fastify.route({
  method: ['PUT', 'PATCH'],
  url: '/items/:id',
  handler: async (request, reply) => {
    // handle both PUT and PATCH
  }
})
```

**Key Points:**
- Combining PUT and PATCH in a single handler is only appropriate if the application logic can meaningfully distinguish between them via `request.method`. Otherwise, separate handlers are clearer.
- Fastify registers each method-path combination as a distinct route internally. [Behavior may vary in edge cases involving plugins or route prefixes.]

---

### Schema Validation Per Method

Each method can declare its own schema, scoped to the specific route registration. This allows validation rules to differ by verb on the same path.

```js
fastify.post('/articles', {
  schema: {
    body: {
      type: 'object',
      required: ['title', 'content'],
      properties: {
        title: { type: 'string' },
        content: { type: 'string' }
      }
    }
  }
}, async (request, reply) => {
  reply.code(201).send({ id: 42, ...request.body })
})

fastify.patch('/articles/:id', {
  schema: {
    body: {
      type: 'object',
      properties: {
        title: { type: 'string' },
        content: { type: 'string' }
      }
    }
  }
}, async (request, reply) => {
  return { id: request.params.id, ...request.body }
})
```

**Key Points:**
- POST requires `title` and `content`; PATCH makes both optional, reflecting their different semantic expectations.
- Schema validation runs before the handler. Requests failing validation are rejected with a `400 Bad Request` before handler code executes. [Behavior may vary depending on custom validators or schema compilation settings.]

---

### Response Serialization by Status Code

Response schemas can be defined per status code, allowing Fastify to serialize and strip unexpected fields from responses efficiently.

```js
fastify.get('/users/:id', {
  schema: {
    response: {
      200: {
        type: 'object',
        properties: {
          id: { type: 'integer' },
          name: { type: 'string' }
        }
      },
      404: {
        type: 'object',
        properties: {
          message: { type: 'string' }
        }
      }
    }
  }
}, async (request, reply) => {
  const user = findUser(request.params.id)
  if (!user) {
    return reply.code(404).send({ message: 'User not found' })
  }
  return user
})
```

**Key Points:**
- Response serialization is handled by `fast-json-stringify` under the hood. [Behavior may vary with custom serializers.]
- Fields not declared in the response schema are omitted from the output, which can act as an implicit data filter. This is a side effect to be mindful of when debugging.

---

### Route Handler Patterns: Async vs Callback

Fastify supports both async/await and callback-style handlers.

**Async handler (recommended):**

```js
fastify.get('/ping', async (request, reply) => {
  return { pong: true }
})
```

**Callback-style handler:**

```js
fastify.get('/ping', (request, reply) => {
  reply.send({ pong: true })
})
```

**Key Points:**
- In async handlers, returning a value is equivalent to calling `reply.send()` with that value.
- Mixing `return` and `reply.send()` in the same async handler may cause unexpected behavior. [Behavior may vary — it is advisable to use one style consistently per handler.]
- Throwing an error inside an async handler delegates error handling to Fastify's error handler automatically.

---

### Practical Example: A Minimal REST Resource

The following illustrates all five methods applied to a single `/products` resource.

```js
const products = new Map()
let nextId = 1

fastify.get('/products', async () => {
  return Array.from(products.values())
})

fastify.get('/products/:id', async (request, reply) => {
  const product = products.get(Number(request.params.id))
  if (!product) return reply.code(404).send({ message: 'Not found' })
  return product
})

fastify.post('/products', async (request, reply) => {
  const product = { id: nextId++, ...request.body }
  products.set(product.id, product)
  reply.code(201).send(product)
})

fastify.put('/products/:id', async (request, reply) => {
  const id = Number(request.params.id)
  if (!products.has(id)) return reply.code(404).send({ message: 'Not found' })
  const product = { id, ...request.body }
  products.set(id, product)
  return product
})

fastify.patch('/products/:id', async (request, reply) => {
  const id = Number(request.params.id)
  const existing = products.get(id)
  if (!existing) return reply.code(404).send({ message: 'Not found' })
  const updated = { ...existing, ...request.body }
  products.set(id, updated)
  return updated
})

fastify.delete('/products/:id', async (request, reply) => {
  const id = Number(request.params.id)
  if (!products.delete(id)) return reply.code(404).send({ message: 'Not found' })
  reply.code(204).send()
})
```

This example uses an in-memory `Map` for simplicity. In production, a database layer would replace direct `Map` operations.

---

**Conclusion**

Fastify's shorthand methods — `fastify.get`, `fastify.post`, `fastify.put`, `fastify.patch`, and `fastify.delete` — provide a consistent, low-boilerplate API for defining HTTP routes. Each method accepts an optional schema for validation and serialization, and handlers can be written in async or callback style. The underlying `fastify.route()` method offers the same capability with full configuration control, suitable for complex or programmatically generated routes.

**Next Steps**

- Route parameters and query string handling
- Schema-based request validation in depth
- Reply lifecycle and response methods
- Error handling per route and globally