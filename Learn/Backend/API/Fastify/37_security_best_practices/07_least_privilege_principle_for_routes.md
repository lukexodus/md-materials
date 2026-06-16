## Least Privilege Principle for Routes

The least privilege principle, applied to Fastify routes, means each route should have access only to the permissions, data, and capabilities strictly necessary to fulfill its purpose — nothing more. This limits the blast radius of bugs, misconfigurations, or compromised logic.

---

### Why It Matters in Fastify

Fastify's plugin and hook architecture makes it well-suited for enforcing least privilege. Encapsulation via `fastify-plugin` boundaries and scoped hooks means access controls can be applied per-scope rather than globally, reducing the risk of overly permissive configurations leaking across routes.

---

### Route-Level Authentication Scoping

Avoid applying authentication globally when not all routes require it. Instead, scope authentication hooks to only the routes that need them.

**Example — Scoped authentication using encapsulation:**

js

```js
// Public routes — no auth
fastify.register(async function publicRoutes(instance) {
  instance.get('/health', async () => ({ status: 'ok' }))
  instance.get('/docs', async () => ({ docs: '...' }))
})

// Protected routes — auth applied only here
fastify.register(async function protectedRoutes(instance) {
  instance.addHook('onRequest', async (request, reply) => {
    await request.jwtVerify()
  })

  instance.get('/account', async (request) => {
    return { user: request.user }
  })

  instance.delete('/account', async (request) => {
    // deletion logic
  })
})
```

**Key Points:**

- `publicRoutes` and `protectedRoutes` are separate encapsulated scopes
- The `onRequest` hook only runs for routes registered inside `protectedRoutes`
- Global hook registration would apply auth to `/health` and `/docs` unnecessarily

---

### Role-Based Access Control Per Route

Authentication (who you are) is not the same as authorization (what you can do). Apply role checks at the route level, not just at the plugin boundary.

**Example — Role check inside a route handler:**

js

```js
fastify.get('/admin/users', {
  onRequest: [fastify.authenticate],
}, async (request, reply) => {
  if (!request.user.roles.includes('admin')) {
    return reply.code(403).send({ error: 'Forbidden' })
  }
  return getAllUsers()
})
```

**Example — Reusable role guard as a hook factory:**

js

```js
function requireRole(role) {
  return async function (request, reply) {
    if (!request.user?.roles?.includes(role)) {
      return reply.code(403).send({ error: 'Forbidden' })
    }
  }
}

fastify.get('/reports', {
  onRequest: [fastify.authenticate, requireRole('analyst')],
}, async (request) => {
  return getReports()
})

fastify.post('/config', {
  onRequest: [fastify.authenticate, requireRole('admin')],
}, async (request) => {
  return updateConfig(request.body)
})
```

**Key Points:**

- Each route declares exactly which roles can access it
- `requireRole` is composable — chain it after authentication
- Behavior of role checks depends on correct population of `request.user`; verify your auth plugin sets this reliably [Inference]

---

### Restricting Request Surface Area with JSON Schema

Least privilege applies to data too. Use Fastify's schema validation to restrict what a route accepts — reject unexpected fields before handler logic runs.

**Example — Strict body schema:**

js

```js
fastify.post('/transfer', {
  schema: {
    body: {
      type: 'object',
      properties: {
        toAccountId: { type: 'string', format: 'uuid' },
        amount: { type: 'number', minimum: 0.01, maximum: 10000 },
      },
      required: ['toAccountId', 'amount'],
      additionalProperties: false, // rejects extra fields
    },
  },
}, async (request) => {
  const { toAccountId, amount } = request.body
  return initiateTransfer(toAccountId, amount)
})
```

**Key Points:**

- `additionalProperties: false` drops unknown fields before they reach your handler
- `maximum` on `amount` limits the scope of a single operation
- Schema validation runs before hooks in Fastify's lifecycle — it is an early gate [Inference based on Fastify lifecycle order; verify against your Fastify version]

---

### Scoping Decorators and Services

Avoid decorating the root `fastify` instance with services that only specific routes need. Use encapsulated scopes to limit service exposure.

**Example — Scoped database client:**

js

```js
fastify.register(async function adminScope(instance) {
  // Only this scope gets the admin DB client
  instance.decorate('adminDb', createAdminDbClient())

  instance.addHook('onRequest', fastify.authenticate)
  instance.addHook('onRequest', requireRole('admin'))

  instance.get('/admin/raw-query', async (request) => {
    return instance.adminDb.query(request.query.sql)
  })
})
```

**Key Points:**

- `adminDb` is not accessible outside `adminScope`
- Routes in other scopes cannot accidentally call `adminDb`
- This relies on Fastify's encapsulation model; using `fastify-plugin` to wrap `adminScope` would break this isolation [Inference]

---

### Limiting Response Data Per Role

A route returning more data than the caller is authorized to see violates least privilege on the output side. Serialize responses according to the caller's role.

**Example — Conditional response shaping:**

js

```js
fastify.get('/user/:id', {
  onRequest: [fastify.authenticate],
}, async (request) => {
  const user = await getUser(request.params.id)

  if (request.user.roles.includes('admin')) {
    return user // full object
  }

  // Non-admins get a reduced view
  const { id, name, email } = user
  return { id, name, email }
})
```

[Inference] For larger applications, a dedicated serialization layer or a library such as `fast-json-stringify` with role-specific schemas [Unverified — verify library compatibility] may be preferable over inline destructuring.

---

### Rate Limiting Per Route

Restricting how frequently a route can be called is a form of privilege limitation — it prevents abuse of elevated operations.

**Example — Route-specific rate limit with `@fastify/rate-limit`:**

js

```js
await fastify.register(import('@fastify/rate-limit'), {
  global: false, // do not apply globally
})

fastify.post('/login', {
  config: {
    rateLimit: {
      max: 5,
      timeWindow: '1 minute',
    },
  },
}, async (request, reply) => {
  return attemptLogin(request.body)
})
```

**Key Points:**

- `global: false` means rate limiting must be opted into per route
- Sensitive routes like `/login`, `/forgot-password`, `/transfer` benefit most
- Actual enforcement behavior depends on the plugin version and storage backend [Unverified]

---

### Avoiding Over-Privileged Middleware

Global `preHandler` or `onRequest` hooks registered on the root instance run for every route, including public ones. Audit global hooks carefully.

**Example — Problematic global hook:**

js

```js
// This runs on ALL routes including /health, /docs, /public/*
fastify.addHook('preHandler', async (request, reply) => {
  await someHeavyAuthCheck(request)
})
```

**Example — Preferred: scope the hook:**

js

```js
fastify.register(async function sensitiveScope(instance) {
  instance.addHook('preHandler', async (request, reply) => {
    await someHeavyAuthCheck(request)
  })

  instance.get('/sensitive-data', async (request) => { /* ... */ })
})
```

---

### Route Options: `exposeHeadRoutes` and Method Restriction

Fastify automatically creates `HEAD` routes for every `GET` route by default (`exposeHeadRoutes: true`). If your authorization logic is tied to the HTTP method, this can create unintended access paths.

**Example — Disable auto HEAD routes globally or per-route:**

js

```js
const fastify = Fastify({ exposeHeadRoutes: false })

// Or per-route (Fastify v4+):
fastify.get('/secure-resource', {
  exposeHeadRoute: false,
  onRequest: [fastify.authenticate],
}, async () => {
  return sensitiveResource()
})
```

[Inference] Whether `HEAD` routes bypass authorization hooks depends on how your hooks are registered; test this explicitly in your setup.

---

### Privilege Audit Checklist

| Concern | What to Check |
| --- | --- |
| Authentication scope | Is auth applied only to routes that need it? |
| Role authorization | Does each sensitive route check the caller's role? |
| Schema strictness | Is `additionalProperties: false` set on body schemas? |
| Decorator exposure | Are privileged decorators scoped, not global? |
| Response data | Does the response omit fields the caller shouldn't see? |
| Rate limiting | Are high-risk routes rate-limited independently? |
| Global hooks | Do any global hooks run unnecessarily on public routes? |
| HTTP methods | Are unneeded methods (HEAD, OPTIONS) exposing routes? |

---

**Related Topics:**

- JWT verification and token scope enforcement in Fastify
- `@fastify/auth` for composable authorization strategies
- Fastify plugin encapsulation and scope isolation (deep dive)
- JSON Schema `additionalProperties` and response serialization schemas
- `@fastify/rate-limit` configuration and Redis-backed storage
- Audit logging per route with `onResponse` hooks
- CORS configuration and per-route origin whitelisting