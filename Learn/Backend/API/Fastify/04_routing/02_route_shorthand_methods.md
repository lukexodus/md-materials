## Route Shorthand Methods

Fastify's shorthand methods are the primary API most applications use to register routes. They are thin wrappers over `fastify.route()` that reduce boilerplate by accepting the path and optional configuration as positional arguments rather than a single configuration object.

---

### What "Shorthand" Means in Fastify

Every shorthand method internally delegates to `fastify.route()`. The shorthand form trades configurability for brevity. When a route requires minimal options, the shorthand is preferred. When options grow complex, switching to `fastify.route()` is appropriate without any behavioral difference.

**Key Points:**
- Shorthand methods and `fastify.route()` produce identical internal route registrations. [Behavior may vary in edge cases involving plugins.]
- All shorthand methods are available directly on the Fastify instance and on any encapsulated plugin scope.

---

### Complete Shorthand Signatures

Every shorthand method shares the same three-argument signature:

```
fastify.METHOD(path, [options], handler)
```

The supported methods are:

```js
fastify.get(path, [options], handler)
fastify.post(path, [options], handler)
fastify.put(path, [options], handler)
fastify.patch(path, [options], handler)
fastify.delete(path, [options], handler)
fastify.head(path, [options], handler)
fastify.options(path, [options], handler)
```

`HEAD` and `OPTIONS` are included alongside the five primary verbs. Fastify does not automatically generate HEAD or OPTIONS responses — each must be explicitly registered if needed. [Unverified — behavior for auto-generated HEAD may depend on Fastify version; consult documentation.]

---

### Argument Breakdown

#### Path

The first argument is always the route path string. It may be a static path, a parametric path, or a wildcard path.

```js
fastify.get('/users', handler)           // static
fastify.get('/users/:id', handler)       // parametric
fastify.get('/files/*', handler)         // wildcard
```

#### Options

The second argument is an optional plain object. When omitted, Fastify treats the second argument as the handler if it is a function. All properties that `fastify.route()` accepts in its config object are valid here.

Commonly used option properties:

| Property | Purpose |
|----------|---------|
| `schema` | Defines validation and serialization schema |
| `preHandler` | Route-level hook(s) executed before the handler |
| `preValidation` | Route-level hook(s) executed before validation |
| `onRequest` | Route-level hook(s) executed at request start |
| `onSend` | Route-level hook(s) executed before response is sent |
| `onResponse` | Route-level hook(s) executed after response is sent |
| `config` | Arbitrary route-level metadata object |
| `version` | Version constraint for the route |
| `constraints` | Route matching constraints |
| `attachValidation` | Attach validation errors to request instead of rejecting |
| `bodyLimit` | Per-route maximum body size in bytes |
| `logLevel` | Per-route log level override |
| `exposeHeadRoute` | Whether to auto-expose a HEAD route (GET only) |

#### Handler

The handler is a function with the signature `(request, reply)`. It may be async or callback-style.

```js
// Inline async handler
fastify.get('/items', async (request, reply) => {
  return []
})

// Named function reference
async function listItems(request, reply) {
  return []
}
fastify.get('/items', listItems)
```

**Key Points:**
- Passing a named function reference (rather than an inline arrow function) improves stack trace readability during debugging.
- The handler may also be supplied as `options.handler` when using the options object, though this pattern is more common with `fastify.route()`.

---

### Handler Supplied Inside Options

Fastify allows the handler to be embedded inside the options object rather than as a third positional argument. This makes the shorthand behave like a two-argument call to `fastify.route()`.

```js
fastify.post('/users', {
  schema: {
    body: {
      type: 'object',
      required: ['name'],
      properties: {
        name: { type: 'string' }
      }
    }
  },
  handler: async (request, reply) => {
    reply.code(201).send({ id: 1, name: request.body.name })
  }
})
```

**Key Points:**
- When `handler` is inside options, no third argument should be passed. [Behavior when both are supplied may vary — avoid supplying both.]
- This pattern is useful when generating route objects programmatically or when sharing option objects across routes.

---

### The `options` Object in Practice

#### Schema

Schema is the most frequently used option. It controls validation of the incoming request and serialization of the outgoing response.

```js
fastify.post('/orders', {
  schema: {
    body: {
      type: 'object',
      required: ['productId', 'quantity'],
      properties: {
        productId: { type: 'integer' },
        quantity: { type: 'integer', minimum: 1 }
      }
    },
    response: {
      201: {
        type: 'object',
        properties: {
          orderId: { type: 'integer' },
          status: { type: 'string' }
        }
      }
    }
  }
}, async (request, reply) => {
  reply.code(201).send({ orderId: 99, status: 'pending' })
})
```

#### `bodyLimit`

Overrides the global body size limit for a specific route. The value is in bytes.

```js
fastify.post('/upload', {
  bodyLimit: 10 * 1024 * 1024 // 10 MB
}, async (request, reply) => {
  return { received: true }
})
```

#### `logLevel`

Sets the log level for all log entries produced by this route's lifecycle, independent of the global log level.

```js
fastify.get('/health', {
  logLevel: 'warn'
}, async (request, reply) => {
  return { status: 'ok' }
})
```

**Key Points:**
- Setting `logLevel: 'warn'` on high-frequency routes like `/health` or `/metrics` reduces log noise without affecting other routes.
- Log level changes apply to Fastify's internal lifecycle logging for that route. [Behavior may vary with custom loggers.]

#### `config`

A free-form metadata object attached to the route. Accessible inside hooks via `reply.context.config` or `request.routeOptions.config` depending on Fastify version.

```js
fastify.get('/admin/stats', {
  config: {
    requiresRole: 'admin',
    rateLimit: 10
  }
}, async (request, reply) => {
  return { visits: 1000 }
})
```

**Example** — reading config inside a `preHandler` hook:

```js
fastify.addHook('preHandler', async (request, reply) => {
  const { requiresRole } = request.routeOptions.config
  if (requiresRole && !userHasRole(request.user, requiresRole)) {
    reply.code(403).send({ message: 'Forbidden' })
  }
})
```

#### `attachValidation`

When `true`, validation errors are attached to `request.validationError` instead of being automatically sent as a `400` response. This gives the handler control over how validation errors are presented.

```js
fastify.post('/lenient', {
  attachValidation: true,
  schema: {
    body: {
      type: 'object',
      properties: { age: { type: 'integer' } }
    }
  }
}, async (request, reply) => {
  if (request.validationError) {
    return reply.code(422).send({
      error: 'Validation failed',
      details: request.validationError.message
    })
  }
  return { received: request.body }
})
```

---

### Route-Level Hooks in Shorthand Options

Hooks can be scoped to a single route by passing them inside the options object. They accept a single hook function or an array of hook functions.

```js
async function authenticate(request, reply) {
  if (!request.headers.authorization) {
    reply.code(401).send({ message: 'Unauthorized' })
  }
}

async function authorize(request, reply) {
  // role check logic
}

fastify.delete('/resources/:id', {
  preHandler: [authenticate, authorize]
}, async (request, reply) => {
  reply.code(204).send()
})
```

**Key Points:**
- Route-level hooks run after any hooks of the same type registered at the plugin or global scope.
- Hooks registered in `preHandler`, `preValidation`, etc. at the route level do not affect other routes, even within the same plugin scope.
- Returning or calling `reply.send()` inside a hook short-circuits the handler execution. [Behavior may vary — test hook ordering in complex setups.]

---

### `exposeHeadRoute` on GET Routes

By default, Fastify may automatically create a HEAD route for every GET route. This behavior is controlled globally by the `exposeHeadRoutes` server option and can be overridden per route using `exposeHeadRoute`.

```js
// Suppress the automatic HEAD route for this specific GET
fastify.get('/stream', {
  exposeHeadRoute: false
}, async (request, reply) => {
  return { data: '...' }
})
```

**Key Points:**
- `exposeHeadRoutes` (plural) is the server-level option; `exposeHeadRoute` (singular) is the per-route override.
- [Unverified — the exact default value of `exposeHeadRoutes` may differ across Fastify versions; verify against the installed version's documentation.]

---

### Constraints

Route constraints allow Fastify to match routes based on criteria beyond path and method, such as the `Host` header or a custom value.

```js
fastify.get('/api/data', {
  constraints: { host: 'api.example.com' }
}, async (request, reply) => {
  return { source: 'api host' }
})

fastify.get('/api/data', {
  constraints: { host: 'internal.example.com' }
}, async (request, reply) => {
  return { source: 'internal host' }
})
```

**Key Points:**
- Both routes share the same method and path but are distinct registrations due to differing constraints.
- Custom constraints require registering a constraint strategy on the Fastify instance. Built-in constraints include `host` and `version`.
- [Behavior may vary depending on the router implementation in use.]

---

### Version Constraints

Version constraints allow multiple versions of the same route to coexist, selected via the `Accept-Version` request header.

```js
fastify.get('/user', {
  constraints: { version: '1.0.0' }
}, async (request, reply) => {
  return { version: 1, name: 'Alice' }
})

fastify.get('/user', {
  constraints: { version: '2.0.0' }
}, async (request, reply) => {
  return { version: 2, username: 'alice' }
})
```

**Example** request:

```
GET /user
Accept-Version: 1.0.0
```

**Output:**

```json
{ "version": 1, "name": "Alice" }
```

**Key Points:**
- Version matching follows semver semantics — a client requesting `1.x` will match `1.0.0`. [Behavior may vary; verify semver matching rules in Fastify's router documentation.]
- If no matching version is found, Fastify returns a `404`.

---

### Reusing Option Objects

When multiple routes share common configuration, the options object can be defined once and spread or referenced.

```js
const protectedRoute = {
  preHandler: [authenticate],
  config: { requiresAuth: true }
}

fastify.get('/profile', {
  ...protectedRoute,
  schema: { response: { 200: profileSchema } }
}, getProfileHandler)

fastify.put('/profile', {
  ...protectedRoute,
  schema: { body: updateProfileSchema }
}, updateProfileHandler)
```

**Key Points:**
- Object spreading creates a shallow copy. If option values are objects or arrays (such as `preHandler`), ensure spreading behaves as intended and does not produce shared mutable references.
- This pattern reduces repetition but can obscure which options apply to a given route. Clear naming of shared option objects helps maintain readability.

---

### Shorthand vs `fastify.route()` — When to Prefer Each

| Situation | Preferred Form |
|-----------|---------------|
| Simple route with few or no options | Shorthand |
| Route with extensive schema and hooks | Either — personal/team preference |
| Programmatically generating routes in a loop | `fastify.route()` |
| Registering multiple methods on the same path | `fastify.route()` with `method` array |
| Sharing a single config object across registrations | `fastify.route()` |

---

**Conclusion**

Fastify's shorthand methods — `get`, `post`, `put`, `patch`, `delete`, `head`, and `options` — provide a consistent three-argument API for route registration. The optional options object supports the full range of Fastify route configuration: schema, hooks, constraints, body limits, log levels, and custom metadata. For straightforward routes, the shorthand form is idiomatic; for complex or programmatic registrations, `fastify.route()` accepts the same options in a single configuration object without behavioral difference.

**Next Steps**

- `fastify.route()` — the full route configuration object
- Route parameters: named params, wildcards, and regex constraints
- Schema validation — request body, query string, params, and headers
- Plugin scoping and how route registration interacts with encapsulation