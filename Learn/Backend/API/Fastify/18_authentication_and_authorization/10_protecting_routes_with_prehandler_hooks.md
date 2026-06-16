## Protecting Routes with preHandler Hooks

### Overview

The `preHandler` hook is Fastify's last hook before the route handler executes. It runs after the request body has been parsed and schema validation has passed, giving it access to the fully populated `request` object — including `request.body`, `request.params`, `request.query`, and any properties attached by earlier hooks. This makes `preHandler` the appropriate location for guards that require parsed request data, resource fetching, ownership verification, or any logic that depends on knowing both the identity of the caller and the content of the request.

---

### Position in the Request Lifecycle

onRequestAuth / JWT verifypreParsingBody ParsingpreValidationSchema ValidationpreHandlerOwnership / ResourcechecksRoute HandleronSendResponse Sent

**Key Points:**

- `onRequest` — runs before parsing; no body available. Use for authentication (JWT verify, API key check).
- `preHandler` — runs after parsing and validation; full request data available. Use for authorization checks that depend on body content, resource state, or ownership.
- Schema validation failure short-circuits before `preHandler` — expensive DB checks inside `preHandler` are not reached for invalid request bodies.
- Both hook stages can coexist on the same route, each receiving a fully typed `request` and `reply`.

---

### Defining a `preHandler` Guard

A `preHandler` hook function has the same signature as any Fastify hook:

js

```js
async function myGuard (request, reply) {
  // inspect request.body, request.params, request.user, etc.
  // call reply.send() or throw to halt the request
  // return normally to allow the request to proceed
}
```

Attached to a route:

js

```js
fastify.post('/posts', {
  preHandler: myGuard
}, async (request, reply) => {
  return db.posts.create(request.body)
})
```

Or as an array for multiple sequential guards:

js

```js
fastify.put('/posts/:id', {
  preHandler: [requireOwnership, validateQuota]
}, async (request, reply) => {
  return db.posts.update(request.params.id, request.body)
})
```

---

### Pattern 1 — Ownership Verification

The most common `preHandler` use case: confirm the authenticated user owns the resource being modified.

js

```js
async function requireOwnership (request, reply) {
  const post = await db.posts.findById(request.params.id)

  if (!post) {
    return reply.status(404).send({
      statusCode: 404,
      error: 'Not Found',
      message: 'Post does not exist'
    })
  }

  const isOwner = post.authorId === request.user.id
  const isAdmin = request.user.roles?.includes('admin') ?? false

  if (!isOwner && !isAdmin) {
    return reply.status(403).send({
      statusCode: 403,
      error: 'Forbidden',
      message: 'You do not own this resource'
    })
  }

  // Attach resource to request — avoids a second DB query in the handler
  request.post = post
}

fastify.put('/posts/:id', {
  onRequest: [fastify.authenticate],
  preHandler: [requireOwnership],
  schema: {
    body: {
      type: 'object',
      required: ['title', 'content'],
      properties: {
        title:   { type: 'string' },
        content: { type: 'string' }
      }
    }
  }
}, async (request, reply) => {
  // request.post already fetched and verified
  return db.posts.update(request.post.id, request.body)
})
```

**Key Points:**

- Attaching the fetched resource to `request` is a common pattern — it avoids redundant DB queries in the handler.
- The `onRequest` hook handles authentication; `preHandler` handles ownership — concerns remain separated.
- Returning a `404` for missing resources (rather than `403`) avoids leaking whether a resource exists to unauthorized callers. The correct choice depends on whether resource existence is itself sensitive. [Inference]

---

### Pattern 2 — Body-Dependent Authorization

When the authorization decision depends on what is being submitted, `preHandler` has access to `request.body` after parsing.

js

```js
async function preventSelfDemotion (request, reply) {
  const { userId, role } = request.body

  // Prevent admins from changing their own role
  if (userId === request.user.id && role !== 'admin') {
    return reply.status(403).send({
      statusCode: 403,
      error: 'Forbidden',
      message: 'You cannot change your own role'
    })
  }
}

fastify.patch('/users/:id/role', {
  onRequest: [fastify.authenticate, fastify.requireAdmin],
  preHandler: [preventSelfDemotion],
  schema: {
    body: {
      type: 'object',
      required: ['userId', 'role'],
      properties: {
        userId: { type: 'integer' },
        role:   { type: 'string', enum: ['admin', 'editor', 'viewer'] }
      }
    }
  }
}, async (request, reply) => {
  return db.users.updateRole(request.body.userId, request.body.role)
})
```

**Key Points:**

- `request.body` is only available after parsing — this check cannot be placed in `onRequest`.
- Schema validation has already confirmed `userId` and `role` are present and correctly typed before `preHandler` runs.
- [Inference] Body-dependent guards are common in admin APIs where the same role can perform some but not all mutations.

---

### Pattern 3 — Resource State Validation

Checking that a resource is in a valid state for the requested operation:

js

```js
async function requireDraftStatus (request, reply) {
  const post = await db.posts.findById(request.params.id)

  if (!post) {
    return reply.status(404).send({ error: 'Post not found' })
  }

  if (post.status !== 'draft') {
    return reply.status(409).send({
      statusCode: 409,
      error: 'Conflict',
      message: `Cannot edit a post with status: ${post.status}`
    })
  }

  request.post = post
}

fastify.put('/posts/:id/content', {
  onRequest: [fastify.authenticate],
  preHandler: [requireOwnership, requireDraftStatus]
}, async (request, reply) => {
  return db.posts.updateContent(request.post.id, request.body.content)
})
```

**Key Points:**

- Multiple `preHandler` functions run in array order — `requireOwnership` runs before `requireDraftStatus`, so `request.post` is available to the second guard if set by the first.
- `409 Conflict` is appropriate for valid requests rejected due to resource state. [Inference] Actual HTTP status semantics are context-dependent.
- Resource state guards encapsulate business rules that would otherwise clutter the handler.

---

### Pattern 4 — Rate and Quota Enforcement

Applying per-user quotas as a `preHandler` guard:

js

```js
async function enforcePostQuota (request, reply) {
  const count = await db.posts.countByUser(request.user.id)
  const limit = request.user.plan === 'free' ? 10 : Infinity

  if (count >= limit) {
    return reply.status(429).send({
      statusCode: 429,
      error: 'Too Many Requests',
      message: `Post limit of ${limit} reached for your plan`
    })
  }
}

fastify.post('/posts', {
  onRequest: [fastify.authenticate],
  preHandler: [enforcePostQuota]
}, async (request, reply) => {
  return db.posts.create({ ...request.body, authorId: request.user.id })
})
```

---

### Pattern 5 — Multi-Tenancy Isolation

Confirming the resource belongs to the authenticated user's tenant:

js

```js
async function requireTenantMatch (request, reply) {
  const resource = await db.documents.findById(request.params.id)

  if (!resource) {
    return reply.status(404).send({ error: 'Not found' })
  }

  if (resource.tenantId !== request.user.tenantId) {
    // Return 404 rather than 403 to avoid confirming cross-tenant resource existence
    return reply.status(404).send({ error: 'Not found' })
  }

  request.document = resource
}

fastify.get('/documents/:id', {
  onRequest: [fastify.authenticate],
  preHandler: [requireTenantMatch]
}, async (request, reply) => {
  return request.document
})
```

**Key Points:**

- Returning `404` instead of `403` for cross-tenant access prevents tenants from inferring the existence of other tenants' resources.
- `request.user.tenantId` must be set by the authentication layer — not trusted from request input.
- [Inference] Multi-tenancy isolation is one of the more critical security properties in SaaS applications — test this boundary explicitly.

---

### Pattern 6 — Scoped `preHandler` via `addHook`

Applying a `preHandler` guard to all routes within a plugin scope:

js

```js
fastify.register(async function publishedPostsScope (instance) {
  // All routes in this scope require a published post to exist
  instance.addHook('preHandler', async (request, reply) => {
    if (!request.params.id) return  // skip routes without :id param

    const post = await db.posts.findById(request.params.id)

    if (!post || post.status !== 'published') {
      return reply.status(404).send({ error: 'Not found' })
    }

    request.post = post
  })

  instance.get('/posts/:id', async (request) => request.post)
  instance.get('/posts/:id/comments', async (request) => db.comments.findByPost(request.post.id))
  instance.get('/posts/:id/author', async (request) => db.users.findById(request.post.authorId))
}, { prefix: '/public' })
```

**Key Points:**

- `addHook('preHandler', ...)` within a `register` scope applies only to routes inside that scope.
- Routes outside the scope are unaffected.
- Scoped `preHandler` hooks reduce repetition for groups of routes that share the same pre-conditions.

---

### Pattern 7 — Conditional Guard Logic

A single `preHandler` that applies different rules depending on HTTP method or route context:

js

```js
async function flexiblePostGuard (request, reply) {
  const post = await db.posts.findById(request.params.id)

  if (!post) {
    return reply.status(404).send({ error: 'Not found' })
  }

  request.post = post

  // Read-only access: any authenticated user
  if (request.method === 'GET') return

  // Write access: owner or admin only
  const isOwner = post.authorId === request.user.id
  const isAdmin = request.user.roles?.includes('admin') ?? false

  if (!isOwner && !isAdmin) {
    return reply.status(403).send({ error: 'Forbidden' })
  }
}

fastify.get('/posts/:id',    { onRequest: [fastify.authenticate], preHandler: [flexiblePostGuard] }, async (req) => req.post)
fastify.put('/posts/:id',    { onRequest: [fastify.authenticate], preHandler: [flexiblePostGuard] }, async (req) => db.posts.update(req.post.id, req.body))
fastify.delete('/posts/:id', { onRequest: [fastify.authenticate], preHandler: [flexiblePostGuard] }, async (req) => db.posts.delete(req.post.id))
```

**Key Points:**

- Sharing one `preHandler` across methods reduces duplication while allowing method-specific branching.
- [Inference] This pattern works best when multiple methods act on the same resource — consolidating the resource fetch and access check in one place.

---

### Passing Context Between Guards and Handlers

`preHandler` guards can enrich `request` with data for downstream use, avoiding redundant queries:

js

```js
// Extend the request type in TypeScript
declare module 'fastify' {
  interface FastifyRequest {
    post?: Post
    organization?: Organization
  }
}

// Guard fetches and attaches
async function loadPost (request, reply) {
  const post = await db.posts.findById(request.params.id)
  if (!post) return reply.status(404).send({ error: 'Not found' })
  request.post = post
}

async function loadOrganization (request, reply) {
  const org = await db.organizations.findById(request.post.organizationId)
  if (!org) return reply.status(500).send({ error: 'Data integrity error' })
  request.organization = org
}

async function requireOrgMembership (request, reply) {
  const isMember = await db.memberships.exists({
    userId: request.user.id,
    organizationId: request.organization.id
  })
  if (!isMember) return reply.status(403).send({ error: 'Not a member' })
}

fastify.get('/posts/:id', {
  onRequest: [fastify.authenticate],
  preHandler: [loadPost, loadOrganization, requireOrgMembership]
}, async (request, reply) => {
  // request.post and request.organization are fully populated
  return {
    post: request.post,
    org:  request.organization.name
  }
})
```

**Key Points:**

- Guards run in array order — later guards can depend on `request` properties set by earlier ones.
- This forms a lightweight middleware pipeline specific to the route's needs.
- [Inference] For complex dependency chains, consider consolidating into a single `preHandler` to make execution order explicit and avoid hidden coupling between guards.

---

### Error Handling in `preHandler`

Guards can signal failure in two ways — both halt the request:

#### Method 1 — `reply.send()`

js

```js
async function myGuard (request, reply) {
  if (!authorized) {
    return reply.status(403).send({ error: 'Forbidden' })
  }
}
```

#### Method 2 — Throw a Fastify Error

js

```js
import createError from '@fastify/error'

const Forbidden = createError('FORBIDDEN', 'Access denied', 403)

async function myGuard (request, reply) {
  if (!authorized) {
    throw new Forbidden()
  }
}
```

**Key Points:**

- Both approaches produce a response and stop the handler from running.
- Throwing integrates with Fastify's `setErrorHandler` — custom error handlers receive the thrown error.
- `reply.send()` gives direct control over the response shape.
- Using `@fastify/error` produces consistent, typed error objects that serialize predictably. [Inference]
- Do not `return` after `reply.send()` without the `return` keyword — without it, the function continues executing. Always use `return reply.send(...)` or `reply.send(...); return` to halt execution cleanly.

---

### `preHandler` vs. `onRequest` — Decision Guide

YesNoYes, for resource fetchNoYesNoYesNoNew Route GuardNeedsrequest.body?preHandlerNeedsrequest.paramsor query?Resource fetchneeded?onRequestAlso needauthentication first?onRequest: authenticatepreHandler:ownership/resourcecheck

| Concern | Hook |
| --- | --- |
| JWT / token verification | `onRequest` |
| API key check | `onRequest` |
| Role / permission check (from token) | `onRequest` |
| Ownership check (requires DB) | `preHandler` |
| Resource existence check | `preHandler` |
| Body-dependent authorization | `preHandler` |
| Resource state validation | `preHandler` |
| Quota / rate enforcement (per-resource) | `preHandler` |
| Multi-tenancy isolation (with resource fetch) | `preHandler` |

---

### Security Considerations

- Always run authentication in `onRequest` before resource-fetching guards in `preHandler` — a `preHandler` guard that reads `request.user` without a prior auth check may operate on an undefined or spoofed user. Behavior may vary.
- Avoid exposing internal error details in guard responses — log the full error server-side and return a generic message to the client.
- `preHandler` guards that perform DB queries are subject to the same injection risks as any DB call — use parameterized queries.
- Attaching sensitive data to `request` (e.g., `request.post`) is accessible to all subsequent hooks and the handler — avoid attaching data that should not be visible at later stages.
- When returning `404` to mask resource existence, be consistent — returning `403` for some callers and `404` for others can still leak information. [Inference]
- Test that guard failures correctly prevent handler execution — a misconfigured guard that sends a reply but does not return may still allow the handler to run, producing double-response warnings or data leaks. Behavior may vary by Fastify version.

---

**Related Topics:**

- `onRequest` vs. `preHandler` hook timing and tradeoffs
- Composing guards with `@fastify/auth`
- Attaching user context to `request` via `onRequest`
- `@fastify/error` for structured, typed error creation
- Resource caching strategies to reduce DB calls in `preHandler` guards
- Integration testing auth flows with `fastify.inject()`
- Schema validation as a first-pass input guard before `preHandler`