## Route-Level Auth Guards

### Overview

Route-level auth guards are authorization checks attached directly to individual routes rather than applied globally or at the plugin scope. In Fastify, guards are implemented as hook functions — most commonly on `onRequest` or `preHandler` — and can be composed, reused, and combined with schema validation. They provide fine-grained control over which requests reach a handler, and are the primary mechanism for enforcing per-route authentication and authorization policies.

---

### Where Guards Fit in the Lifecycle

Incoming RequestonRequestpreParsingBody ParsingpreValidationSchema ValidationpreHandlerRoute HandleronSendResponse

**Key Points:**

- `onRequest` — fires before body parsing. Preferred for auth guards since rejecting early avoids unnecessary parsing work. JWT verification and role checks belong here.
- `preHandler` — fires after body parsing and schema validation. Use when the guard needs access to the parsed request body (e.g., ownership checks comparing `request.body.userId` to `request.user.id`).
- Both hooks accept arrays — multiple guards can be composed on a single route.
- Behavior may vary if body parsing or schema validation throws before `preHandler` runs.

---

### Attaching Guards to a Route

Guards are passed via the `onRequest` or `preHandler` option in the route definition:

js

```js
fastify.get('/protected', {
  onRequest: [authenticate]
}, async (request, reply) => {
  return { user: request.user }
})
```

Multiple guards run in array order — each must pass before the next executes:

js

```js
fastify.delete('/admin/posts/:id', {
  onRequest: [authenticate, requireAdmin]
}, async (request, reply) => {
  await db.posts.delete(request.params.id)
  return { deleted: true }
})
```

**Key Points:**

- Guards in an array run sequentially, not in parallel.
- If any guard calls `reply.send()` or throws, subsequent guards and the handler are skipped.
- A guard that returns without sending terminates the chain only if it throws — returning normally passes control to the next guard.

---

### Building Reusable Guard Functions

Guard functions match Fastify's hook signature: `async (request, reply) => void`. Throwing or sending a reply signals failure.

#### JWT Authentication Guard

js

```js
async function authenticate (request, reply) {
  try {
    await request.jwtVerify()
  } catch (err) {
    reply.status(401).send({
      statusCode: 401,
      error: 'Unauthorized',
      message: 'Valid JWT required'
    })
  }
}
```

#### Role Guard Factory

js

```js
function requireRole (...roles) {
  return async function (request, reply) {
    const userRoles = request.user?.roles ?? []
    const permitted = roles.some(r => userRoles.includes(r))
    if (!permitted) {
      return reply.status(403).send({
        statusCode: 403,
        error: 'Forbidden',
        message: `Requires one of: ${roles.join(', ')}`
      })
    }
  }
}
```

#### Permission Guard Factory

js

```js
function requirePermission (permission) {
  return async function (request, reply) {
    const userPermissions = resolvePermissions(request.user?.roles ?? [])
    if (!userPermissions.has(permission)) {
      return reply.status(403).send({
        statusCode: 403,
        error: 'Forbidden',
        message: `Missing permission: ${permission}`
      })
    }
  }
}
```

#### Usage

js

```js
fastify.get('/dashboard', {
  onRequest: [authenticate, requireRole('admin', 'editor')]
}, async (request, reply) => {
  return { user: request.user }
})

fastify.delete('/posts/:id', {
  onRequest: [authenticate, requirePermission('post:delete')]
}, async (request, reply) => {
  await db.posts.delete(request.params.id)
  return { deleted: true }
})
```

---

### Decorator-Based Guards

Attaching guards as `fastify` decorators makes them importable and self-documenting across the application.

js

```js
fastify.decorate('authenticate', async function (request, reply) {
  try {
    await request.jwtVerify()
  } catch {
    reply.status(401).send({ error: 'Unauthorized' })
  }
})

fastify.decorate('requireAdmin', async function (request, reply) {
  if (!request.user?.roles?.includes('admin')) {
    reply.status(403).send({ error: 'Admin role required' })
  }
})

fastify.decorate('requireEditor', async function (request, reply) {
  const allowed = ['admin', 'editor']
  if (!request.user?.roles?.some(r => allowed.includes(r))) {
    reply.status(403).send({ error: 'Editor role required' })
  }
})
```

js

```js
fastify.get('/admin/config', {
  onRequest: [fastify.authenticate, fastify.requireAdmin]
}, async (request, reply) => {
  return { config: 'sensitive' }
})

fastify.post('/posts', {
  onRequest: [fastify.authenticate, fastify.requireEditor]
}, async (request, reply) => {
  return db.posts.create(request.body)
})
```

**Key Points:**

- Decorators are available across all scopes after the point of decoration.
- Naming conventions (`requireX`, `verifyX`, `guardX`) signal intent to other developers.
- Guards decorated on the root instance are accessible in all encapsulated child plugins.

---

### Composing Guards with `@fastify/auth`

`@fastify/auth` enables boolean composition of guard functions — OR (any must pass) and AND (all must pass).

bash

```bash
npm install @fastify/auth
```

js

```js
import fastifyAuth from '@fastify/auth'
await fastify.register(fastifyAuth)

// AND — must be authenticated AND have admin role
fastify.delete('/admin/users/:id', {
  onRequest: fastify.auth(
    [fastify.authenticate, fastify.requireAdmin],
    { relation: 'and' }
  )
}, async (request, reply) => {
  return db.users.delete(request.params.id)
})

// OR — accept either a JWT token or an API key
fastify.get('/api/data', {
  onRequest: fastify.auth(
    [fastify.verifyJWT, fastify.verifyApiKey],
    { relation: 'or' }
  )
}, async (request, reply) => {
  return { data: [] }
})
```

**Key Points:**

- `relation: 'and'` — all functions must pass without throwing.
- `relation: 'or'` (default) — at least one function must pass; errors from others are suppressed if one succeeds.
- [Inference] OR logic is useful for APIs that support multiple credential types (e.g., user JWT for browser clients, API key for machine clients).

---

### Conditional Guards

Guards that apply different logic depending on route parameters, headers, or context:

js

```js
async function authenticateFlexible (request, reply) {
  const authHeader = request.headers.authorization ?? ''

  if (authHeader.startsWith('Bearer ')) {
    // JWT path
    try {
      await request.jwtVerify()
    } catch {
      return reply.status(401).send({ error: 'Invalid JWT' })
    }
  } else if (authHeader.startsWith('ApiKey ')) {
    // API key path
    const key = authHeader.slice(7)
    const valid = await db.apiKeys.verify(key)
    if (!valid) return reply.status(401).send({ error: 'Invalid API key' })
    request.user = await db.apiKeys.getUser(key)
  } else {
    return reply.status(401).send({ error: 'No credentials provided' })
  }
}
```

---

### Body-Dependent Guards (`preHandler`)

When a guard needs the parsed request body, it must run in `preHandler` (after body parsing):

js

```js
async function requireOwnership (request, reply) {
  const post = await db.posts.findById(request.params.id)

  if (!post) {
    return reply.status(404).send({ error: 'Post not found' })
  }

  const isOwner = post.authorId === request.user.id
  const isAdmin = request.user.roles.includes('admin')

  if (!isOwner && !isAdmin) {
    return reply.status(403).send({ error: 'You do not own this resource' })
  }

  request.post = post  // attach for reuse in handler
}

fastify.put('/posts/:id', {
  onRequest: [fastify.authenticate],
  preHandler: [requireOwnership]
}, async (request, reply) => {
  // request.post is already fetched and verified
  return db.posts.update(request.post.id, request.body)
})
```

**Key Points:**

- Splitting `onRequest` (auth) and `preHandler` (ownership) keeps concerns separated.
- Attaching the fetched resource to `request` avoids a second DB query in the handler.
- `preHandler` guards can still access `request.user` set by earlier `onRequest` guards.

---

### Guard Short-Circuit Patterns

#### Early Return on Public Routes

A guard that allows unauthenticated access to certain routes while requiring auth on others — using route config as a signal:

js

```js
fastify.decorate('optionalAuth', async function (request, reply) {
  const token = request.headers.authorization
  if (!token) return  // allow unauthenticated — request.user remains undefined

  try {
    await request.jwtVerify()
  } catch {
    return reply.status(401).send({ error: 'Invalid token provided' })
  }
})

fastify.get('/posts/:id', {
  onRequest: [fastify.optionalAuth]
}, async (request, reply) => {
  const post = await db.posts.findById(request.params.id)
  const canEdit = request.user?.roles?.includes('editor') ?? false
  return { post, canEdit }
})
```

#### Bypassing Guards on Specific Routes

Using route `config` to signal that a route is intentionally public, checked inside a global guard:

js

```js
fastify.addHook('onRequest', async (request, reply) => {
  if (request.routeOptions?.config?.public) return  // skip auth

  try {
    await request.jwtVerify()
  } catch {
    return reply.status(401).send({ error: 'Unauthorized' })
  }
})

fastify.get('/health', { config: { public: true } }, async () => ({ status: 'ok' }))
fastify.get('/me', async (request) => ({ user: request.user }))
```

**Key Points:**

- `request.routeOptions.config` is a Fastify built-in — no custom instrumentation needed.
- This inverts the default: all routes require auth unless explicitly marked public.
- [Inference] Inverting the default is safer — a developer forgetting to add `config: { public: true }` results in a protected route, not an exposed one.

---

### Combining Schema Validation with Guards

Fastify schema validation runs between `preValidation` and `preHandler`. Guards and schema validation work independently — both must pass:

js

```js
const postSchema = {
  body: {
    type: 'object',
    required: ['title', 'content'],
    properties: {
      title:   { type: 'string', minLength: 1 },
      content: { type: 'string', minLength: 1 }
    }
  }
}

fastify.post('/posts', {
  onRequest: [fastify.authenticate, fastify.requireEditor],
  schema: postSchema
}, async (request, reply) => {
  return db.posts.create({ ...request.body, authorId: request.user.id })
})
```

**Key Points:**

- Schema validation rejects malformed bodies before `preHandler` runs — guards in `preHandler` are not reached for invalid bodies.
- Guards in `onRequest` run before schema validation — they will run even on malformed requests.
- For guards that are expensive (e.g., DB lookups), placing them in `preHandler` avoids running them on bodies that would fail validation anyway.

---

### TypeScript — Typing Guards and Decorated Requests

ts

```ts
import { FastifyRequest, FastifyReply, FastifyInstance } from 'fastify'

// Augment FastifyRequest to include user
declare module 'fastify' {
  interface FastifyRequest {
    user?: {
      id: number
      roles: string[]
    }
  }
  interface FastifyInstance {
    authenticate: (request: FastifyRequest, reply: FastifyReply) => Promise<void>
    requireAdmin: (request: FastifyRequest, reply: FastifyReply) => Promise<void>
  }
}

// Guard implementation
async function authenticate (request: FastifyRequest, reply: FastifyReply): Promise<void> {
  try {
    await request.jwtVerify()
  } catch {
    reply.status(401).send({ error: 'Unauthorized' })
  }
}

// Guard factory with TypeScript
function requireRole (...roles: string[]) {
  return async function (request: FastifyRequest, reply: FastifyReply): Promise<void> {
    const userRoles = request.user?.roles ?? []
    if (!roles.some(r => userRoles.includes(r))) {
      reply.status(403).send({ error: 'Forbidden' })
    }
  }
}
```

---

### Testing Route Guards

Guards should be tested independently from business logic.

js

```js
import { test } from 'node:test'
import assert from 'node:assert'
import Fastify from 'fastify'
import jwt from '@fastify/jwt'

async function buildApp () {
  const app = Fastify()
  await app.register(jwt, { secret: 'test-secret' })

  app.decorate('authenticate', async (request, reply) => {
    try { await request.jwtVerify() }
    catch { reply.status(401).send({ error: 'Unauthorized' }) }
  })

  app.decorate('requireAdmin', async (request, reply) => {
    if (!request.user?.roles?.includes('admin')) {
      reply.status(403).send({ error: 'Forbidden' })
    }
  })

  app.get('/admin', {
    onRequest: [app.authenticate, app.requireAdmin]
  }, async () => ({ ok: true }))

  return app
}

test('rejects unauthenticated requests', async () => {
  const app = await buildApp()
  const res = await app.inject({ method: 'GET', url: '/admin' })
  assert.equal(res.statusCode, 401)
})

test('rejects authenticated non-admin users', async () => {
  const app = await buildApp()
  const token = app.jwt.sign({ id: 1, roles: ['viewer'] })
  const res = await app.inject({
    method: 'GET', url: '/admin',
    headers: { authorization: `Bearer ${token}` }
  })
  assert.equal(res.statusCode, 403)
})

test('allows authenticated admin users', async () => {
  const app = await buildApp()
  const token = app.jwt.sign({ id: 1, roles: ['admin'] })
  const res = await app.inject({
    method: 'GET', url: '/admin',
    headers: { authorization: `Bearer ${token}` }
  })
  assert.equal(res.statusCode, 200)
})
```

**Key Points:**

- `fastify.inject()` sends mock requests without binding to a port — ideal for unit tests.
- Test each guard condition independently: no credentials, wrong role, correct role.
- Guard factories can be tested by passing mock `request` and `reply` objects directly. [Inference]

---

### Guard Placement Decision Guide

Yes, all routesYes, route groupNo, single routeNoYesYesNoNew Auth RequirementApplies tomany routes?Global addHook on rootinstanceaddHook inside registerscopeNeedsrequest body?onRequest array on routepreHandler array on routeMultiple authmethods?fastify.auth with relation

---

### Security Considerations

- Never rely solely on client-supplied role or permission claims in request bodies or query strings — always derive authorization from the verified identity (`request.user`).
- Guards that short-circuit (return early) without sending a reply allow the request to continue — always either `throw`, call `reply.send()`, or return an error object on failure. Forgetting this can silently allow unauthorized access. Behavior may vary depending on Fastify version.
- Avoid async guard functions that swallow exceptions silently — unhandled promise rejections in hooks may not produce the expected 4xx response in all configurations. [Inference]
- Apply guards at `onRequest` rather than `preHandler` when possible — failing early reduces exposure of parsed body data to unauthorized contexts.
- Log failed authorization attempts with enough context (user ID, route, timestamp) to detect abuse patterns.
- Test the negative cases — verify that each guarded route returns the correct status code when credentials are absent, expired, or insufficient.

---

**Related Topics:**

- Composing guards with `@fastify/auth`
- Global vs. scoped hooks for blanket auth enforcement
- `preValidation` vs. `preHandler` hook timing differences
- Rate limiting guarded routes with `@fastify/rate-limit`
- Audit logging for authorization events
- End-to-end testing auth flows with `fastify.inject()`
- OpenAPI / Swagger security scheme annotation for guarded routes