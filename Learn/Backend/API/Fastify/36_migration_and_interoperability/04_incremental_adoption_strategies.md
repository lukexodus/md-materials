## Incremental Adoption Strategies

Migrating a production Express (or similar) application to Fastify rarely happens in a single cutover. Incremental adoption means running both frameworks concurrently, moving routes and middleware piece by piece, and validating each step before proceeding. This document covers the architectural patterns, tooling, and operational practices that make incremental adoption viable.

---

### Why Incremental Adoption

A full rewrite carries significant risk: behavioral regressions, loss of institutional knowledge embedded in middleware chains, and extended periods where no new features ship. Incremental adoption distributes that risk across a controlled timeline.

**Key Points:**
- Each migrated route can be independently tested and rolled back.
- Performance improvements from Fastify become visible early, providing migration momentum.
- Teams can build familiarity with Fastify patterns before owning the entire codebase.
- [Inference] Organizational risk tolerance and traffic volume are the primary factors determining how aggressive the migration pace can be — no universal timeline applies.

---

### Strategy 1 — Reverse Proxy Routing (Infrastructure-Level Split)

The lowest-risk approach: run Express and Fastify as separate processes. A reverse proxy (nginx, Caddy, or a cloud load balancer) routes requests to one or the other based on path prefix, header, or other criteria.

```
Client
  │
  ▼
[nginx / load balancer]
  │
  ├── /api/v2/*  ──► Fastify (port 3001)
  │
  └── /api/v1/*  ──► Express (port 3000)
```

**nginx configuration example:**

```nginx
upstream express_backend {
    server 127.0.0.1:3000;
}

upstream fastify_backend {
    server 127.0.0.1:3001;
}

server {
    listen 80;

    location /api/v2/ {
        proxy_pass http://fastify_backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }

    location /api/v1/ {
        proxy_pass http://express_backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

**Key Points:**
- Both applications are fully independent — no shared code path at the Node.js level.
- Shared state (sessions, caches, databases) must be externalized (Redis, a database) so both processes can access it.
- Deployment, scaling, and rollback are independent per process.
- This approach works regardless of how tightly coupled the Express app is internally.
- [Inference] This is the safest starting point for large or heavily stateful applications where the internal coupling makes in-process coexistence difficult.

---

### Strategy 2 — Fastify as a Wrapper Around Express

Mount the existing Express application inside Fastify using `@fastify/express`. All existing Express routes and middleware continue to function. New routes are added as native Fastify handlers.

```typescript
import Fastify from 'fastify'
import expressPlugin from '@fastify/express'
import { createLegacyApp } from './legacy/app' // existing Express app factory

const fastify = Fastify({ logger: true })

await fastify.register(expressPlugin)

// Mount legacy Express app — all existing routes still function
const legacyApp = createLegacyApp()
fastify.use(legacyApp)

// New routes — native Fastify
fastify.register(async (instance) => {
  instance.get('/api/v2/health', async () => ({ status: 'ok' }))
}, { prefix: '/api/v2' })

await fastify.listen({ port: 3000 })
```

**Key Points:**
- A single port, a single process, no infrastructure changes required.
- Existing Express routes are served by Fastify's HTTP server, meaning Fastify's request lifecycle applies up to the point where control passes to Express.
- New functionality is built natively in Fastify from day one.
- [Unverified] Middleware execution order when mixing `app.use()` (Express layer) and Fastify hooks may produce unexpected results in edge cases — integration test all shared paths.

---

### Strategy 3 — Route-by-Route Migration Inside a Single Fastify Instance

Once `@fastify/middie` or `@fastify/express` is registered, routes can be moved one at a time from Express handlers into Fastify route definitions. This is the core incremental unit of work.

**Migration unit — single route:**

```typescript
// Before: Express route (in legacy app)
// app.get('/users/:id', authenticate, validateId, getUserById)

// After: Fastify equivalent
import { FastifyInstance, FastifyRequest, FastifyReply } from 'fastify'

interface GetUserParams {
  id: string
}

async function userRoutes(fastify: FastifyInstance) {
  fastify.addHook('preHandler', nativeAuthHook) // replaces authenticate middleware

  fastify.get<{ Params: GetUserParams }>(
    '/users/:id',
    {
      schema: {
        params: {
          type: 'object',
          properties: { id: { type: 'string', format: 'uuid' } },
          required: ['id']
        },
        response: {
          200: {
            type: 'object',
            properties: {
              id: { type: 'string' },
              name: { type: 'string' },
              email: { type: 'string' }
            }
          }
        }
      }
    },
    async (request, reply) => {
      const { id } = request.params
      const user = await getUserById(id)
      if (!user) return reply.status(404).send({ error: 'Not found' })
      return user
    }
  )
}

export default userRoutes
```

**Checklist for each migrated route:**
- Replace middleware chain with equivalent `preHandler` hooks or plugin-level hooks
- Add JSON Schema for params, querystring, body, and response
- Replace `res.json()` / `res.send()` with `return` or `reply.send()`
- Replace `next(err)` error propagation with thrown errors or `reply.send(error)`
- Add integration tests before removing the Express route

---

### Strategy 4 — Feature Flag Routing

Route incoming requests to either the Express or Fastify handler based on a runtime flag. This allows gradual traffic shifting without infrastructure changes.

```typescript
import Fastify from 'fastify'
import expressPlugin from '@fastify/express'
import { legacyGetUser } from './legacy/handlers/user'

const fastify = Fastify({ logger: true })
await fastify.register(expressPlugin)

const MIGRATION_FLAGS = {
  useNewUserHandler: process.env.USE_NEW_USER_HANDLER === 'true'
}

fastify.get('/users/:id', async (request, reply) => {
  if (MIGRATION_FLAGS.useNewUserHandler) {
    // New Fastify-native handler
    const user = await getUserFromService(request.params.id)
    return user
  }

  // Fall through to Express handler
  return new Promise<void>((resolve, reject) => {
    legacyGetUser(request.raw, reply.raw, (err?: Error) => {
      if (err) reject(err)
      else resolve()
    })
  })
})
```

**Key Points:**
- Flags can be toggled via environment variables, a feature flag service, or a config store — no redeploy required if using a remote config.
- This enables canary-style rollout: enable the new handler for a percentage of traffic and monitor error rates before full cutover.
- [Inference] Calling Express handlers manually via their raw `req`/`res` objects is fragile if those handlers depend on Express augmentations — test thoroughly and prefer `@fastify/express` for patching if needed.

---

### Strategy 5 — Plugin-Scoped Migration

Fastify's encapsulation model makes plugin-scoped migration natural. Group related legacy routes into a plugin, register it with `@fastify/middie` scoped, and migrate plugin by plugin.

```typescript
// legacy-users-plugin.ts — still uses middleware compat
async function legacyUsersPlugin(fastify: FastifyInstance) {
  await fastify.register(middie)
  fastify.use(legacyAuthMiddleware)

  fastify.get('/users', legacyListUsersHandler)
  fastify.get('/users/:id', legacyGetUserHandler)
  fastify.post('/users', legacyCreateUserHandler)
}

// native-users-plugin.ts — fully migrated
async function nativeUsersPlugin(fastify: FastifyInstance) {
  fastify.addHook('preHandler', nativeAuthHook)

  fastify.get('/users', { schema: listUsersSchema }, listUsersHandler)
  fastify.get('/users/:id', { schema: getUserSchema }, getUserHandler)
  fastify.post('/users', { schema: createUserSchema }, createUserHandler)
}

// In app bootstrap — swap when ready
app.register(
  process.env.USERS_MIGRATED === 'true' ? nativeUsersPlugin : legacyUsersPlugin,
  { prefix: '/api' }
)
```

This pattern makes the migration boundary explicit and swappable at the plugin level.

---

### Shared State During Migration

Both the legacy and new handlers must operate on the same underlying state. Strategies:

**Database:** No special handling required — both handlers use the same connection pool or ORM. Ensure connection pool sizing accounts for both codepaths running simultaneously.

**Sessions:** If the legacy system uses `express-session` with a Redis store, the Fastify side must read from the same Redis store using compatible key formats. `@fastify/session` supports pluggable stores including `connect-redis`.

```typescript
import fastifySession from '@fastify/session'
import connectRedis from 'connect-redis'
import { redisClient } from './redis'

const RedisStore = connectRedis(fastifySession as any) // [Inference] type cast may be needed depending on version

fastify.register(fastifySession, {
  secret: process.env.SESSION_SECRET!,
  store: new RedisStore({ client: redisClient }),
  cookie: { secure: false }
})
```

**In-memory state:** Any state held in Express middleware closures or module-level variables will not be visible to the Fastify process if using Strategy 1 (separate processes). Externalize to Redis, a database, or a shared cache before splitting.

---

### Testing During Incremental Migration

Each migrated route needs a test that runs against both the legacy and new implementations to confirm behavioral equivalence.

```typescript
// equivalence.test.ts
import Fastify from 'fastify'
import express from 'express'
import supertest from 'supertest'
import { legacyApp } from './legacy/app'
import { buildFastifyApp } from './fastify/app'

describe('GET /users/:id — behavioral equivalence', () => {
  let fastifyApp: ReturnType<typeof Fastify>
  let expressApp: ReturnType<typeof express>

  beforeAll(async () => {
    fastifyApp = await buildFastifyApp()
    await fastifyApp.ready()
    expressApp = legacyApp()
  })

  afterAll(async () => {
    await fastifyApp.close()
  })

  it('returns the same response shape for a valid user', async () => {
    const userId = 'test-user-123'

    const [fastifyRes, expressRes] = await Promise.all([
      fastifyApp.inject({ method: 'GET', url: `/users/${userId}` }),
      supertest(expressApp).get(`/users/${userId}`)
    ])

    expect(fastifyRes.statusCode).toBe(expressRes.status)
    expect(JSON.parse(fastifyRes.body)).toMatchObject(expressRes.body)
  })

  it('returns 404 for an unknown user with equivalent shape', async () => {
    const [fastifyRes, expressRes] = await Promise.all([
      fastifyApp.inject({ method: 'GET', url: '/users/nonexistent' }),
      supertest(expressApp).get('/users/nonexistent')
    ])

    expect(fastifyRes.statusCode).toBe(404)
    expect(expressRes.status).toBe(404)
  })
})
```

**Key Points:**
- Run equivalence tests in CI on every PR during the migration period.
- Pay particular attention to error response shapes — Express and Fastify produce different default error bodies.
- [Inference] Fastify's built-in schema validation errors follow a specific format (`{ statusCode, error, message }`) that may differ from what the legacy API returned — align them explicitly using a custom error handler.

---

### Error Response Alignment

Fastify's default error serializer produces a different shape than Express's typical `res.status(400).json({ message: '...' })` pattern. During migration, align them:

```typescript
// Custom error handler — match legacy error shape
fastify.setErrorHandler((error, request, reply) => {
  const statusCode = error.statusCode ?? 500

  reply.status(statusCode).send({
    message: error.message,
    ...(process.env.NODE_ENV !== 'production' && { stack: error.stack })
  })
})
```

Apply this early in the migration so error responses are consistent across both systems from the first route cutover.

---

### Migration Tracking

Maintain a visible record of migration status across the codebase. A simple approach is a tracking file committed to the repository:

```markdown
# Migration Status

## Completed
- [x] GET /users/:id
- [x] POST /users
- [x] GET /products

## In Progress
- [ ] GET /orders — handler migrated, middleware not yet replaced
- [ ] POST /orders — blocked on session handling

## Not Started
- [ ] /admin/* (16 routes)
- [ ] /webhooks/* (4 routes)

## Middleware Replaced
- [x] cors → @fastify/cors
- [x] helmet → @fastify/helmet
- [ ] express-session → @fastify/session
- [ ] passport → @fastify/passport
- [ ] multer → @fastify/multipart
```

[Inference] Tracking this in a file co-located with the code keeps migration status visible in code review and reduces the risk of stale entries compared to a separate project management tool.

---

### Operational Rollback Plan

Every migration step should have a defined rollback path before it goes to production.

| Migration unit | Rollback mechanism |
|---|---|
| Reverse proxy split | Update nginx upstream config, reload |
| Feature flag routing | Toggle env var or remote flag off |
| Plugin swap | Revert `USERS_MIGRATED` env var |
| Full cutover | Redeploy previous Express build |

Document the rollback steps for each stage before executing the migration, not after.

---

### Migration Completion Criteria

Consider a migration complete when:
- All routes are registered as native Fastify handlers with JSON Schema
- All Express-style middleware has been replaced with Fastify hooks or plugins
- `@fastify/middie` and `@fastify/express` have been removed from `package.json`
- Error responses are consistent and tested
- Performance benchmarks confirm expected throughput improvement
- All equivalence tests pass and the legacy test suite has been retired or ported

---

**Related Topics:**
- Behavioral equivalence testing with `fastify.inject()` and Supertest
- Custom error handler patterns for legacy API compatibility
- `@fastify/session` and `@fastify/passport` migration from Express equivalents
- Schema-first route design with JSON Schema and TypeBox
- Fastify plugin architecture and encapsulation for team-based migration ownership
- Canary deployments and feature flags with environment-based config
- Load testing migrated routes with `autocannon`