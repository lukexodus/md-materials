## Role-Based Access Control Patterns

### Overview

Role-Based Access Control (RBAC) is an authorization model where permissions are assigned to roles, and roles are assigned to users. In Fastify, RBAC sits in the **authorization** layer — it runs after authentication has established *who* the user is, and determines *what* they are allowed to do. Fastify provides no built-in RBAC system; instead, patterns are composed from hooks, decorators, and plugins to fit the application's complexity.

---

### RBAC vs. Authentication

NoYesNoYesRequestAuthenticationWho are you?ValidIdentity?401 UnauthorizedAuthorization / RBACWhat can you do?HasPermission?403 ForbiddenRoute Handler

**Key Points:**

- **401 Unauthorized** — identity could not be verified.
- **403 Forbidden** — identity is known but lacks permission.
- RBAC logic should never run before authentication is confirmed.
- These are separable concerns — keep them in distinct layers.

---

### Data Model Concepts

#### Flat Roles

The simplest model: each user has one or more role strings.

js

```js
const user = {
  id: 42,
  username: 'arya',
  roles: ['editor', 'viewer']
}
```

#### Roles with Permissions

A richer model where roles map to granular permission strings:

js

```js
const rolePermissions = {
  admin:   ['user:read', 'user:write', 'user:delete', 'post:publish'],
  editor:  ['post:read', 'post:write', 'post:publish'],
  viewer:  ['post:read'],
  support: ['user:read', 'post:read']
}
```

#### Hierarchical Roles

[Inference] For complex systems, roles can inherit from parent roles, though this requires a traversal function and adds implementation complexity.

js

```js
const roleHierarchy = {
  superadmin: ['admin'],
  admin:      ['editor', 'support'],
  editor:     ['viewer'],
  viewer:     []
}
```

---

### Pattern 1 — Inline Role Check

The simplest approach: check `request.user.roles` directly inside the route handler.

js

```js
fastify.delete('/posts/:id', async (request, reply) => {
  if (!request.user.roles.includes('admin')) {
    return reply.status(403).send({ error: 'Forbidden' })
  }

  await db.posts.delete(request.params.id)
  return { deleted: true }
})
```

**Key Points:**

- Simple and readable for small applications.
- Does not scale — role logic is scattered across handlers with no central enforcement point.
- Suitable for prototypes or routes with unique, non-reusable access rules.

---

### Pattern 2 — Role-Checking Decorator

Centralizes the role check behind a reusable `fastify` decorator.

js

```js
fastify.decorate('requireRoles', function (roles) {
  return async function (request, reply) {
    const userRoles = request.user?.roles ?? []
    const hasRole = roles.some(role => userRoles.includes(role))

    if (!hasRole) {
      return reply.status(403).send({
        statusCode: 403,
        error: 'Forbidden',
        message: `Requires one of: ${roles.join(', ')}`
      })
    }
  }
})
```

#### Usage

js

```js
fastify.get(
  '/admin/users',
  { onRequest: [fastify.authenticate, fastify.requireRoles(['admin'])] },
  async (request, reply) => {
    return await db.users.findAll()
  }
)

fastify.put(
  '/posts/:id',
  { onRequest: [fastify.authenticate, fastify.requireRoles(['admin', 'editor'])] },
  async (request, reply) => {
    return await db.posts.update(request.params.id, request.body)
  }
)
```

**Key Points:**

- The decorator returns a function, making it composable with `onRequest` arrays.
- `some` implements OR logic — any one of the listed roles is sufficient.
- For AND logic (user must have all listed roles), replace `some` with `every`.

---

### Pattern 3 — Permission-Based Decorator

Rather than checking roles directly, check derived permissions. This decouples route definitions from role names.

js

```js
const rolePermissions = {
  admin:   ['user:read', 'user:write', 'user:delete', 'post:read', 'post:write', 'post:delete', 'post:publish'],
  editor:  ['post:read', 'post:write', 'post:publish'],
  viewer:  ['post:read'],
  support: ['user:read', 'post:read']
}

function getPermissions (roles = []) {
  const perms = new Set()
  for (const role of roles) {
    for (const perm of rolePermissions[role] ?? []) {
      perms.add(perm)
    }
  }
  return perms
}

fastify.decorate('requirePermission', function (permission) {
  return async function (request, reply) {
    const userRoles = request.user?.roles ?? []
    const permissions = getPermissions(userRoles)

    if (!permissions.has(permission)) {
      return reply.status(403).send({
        statusCode: 403,
        error: 'Forbidden',
        message: `Missing permission: ${permission}`
      })
    }
  }
})
```

#### Usage

js

```js
fastify.delete(
  '/posts/:id',
  { onRequest: [fastify.authenticate, fastify.requirePermission('post:delete')] },
  async (request, reply) => {
    await db.posts.delete(request.params.id)
    return { deleted: true }
  }
)
```

**Key Points:**

- Routes declare required permissions, not roles — adding a new role with `post:delete` requires no route changes.
- Permission strings (`resource:action`) are a common convention but any consistent scheme works.
- `getPermissions` can be memoized or cached per request if the role list is large. [Inference]

---

### Pattern 4 — Hook-Based Scope Enforcement

Apply RBAC at the plugin scope level using `addHook`. All routes within the scope inherit the check automatically.

js

```js
// Admin scope — all routes require 'admin' role
fastify.register(async function adminScope (instance) {
  instance.addHook('onRequest', async (request, reply) => {
    await request.jwtVerify()
    if (!request.user.roles.includes('admin')) {
      return reply.status(403).send({ error: 'Admin access required' })
    }
  })

  instance.get('/admin/users', async () => db.users.findAll())
  instance.delete('/admin/users/:id', async (req) => db.users.delete(req.params.id))
  instance.get('/admin/audit-log', async () => db.auditLog.findAll())
}, { prefix: '/admin' })

// Editor scope — routes require 'editor' or 'admin' role
fastify.register(async function editorScope (instance) {
  instance.addHook('onRequest', async (request, reply) => {
    await request.jwtVerify()
    const allowed = ['admin', 'editor']
    if (!request.user.roles.some(r => allowed.includes(r))) {
      return reply.status(403).send({ error: 'Editor access required' })
    }
  })

  instance.post('/posts', async (req) => db.posts.create(req.body))
  instance.put('/posts/:id', async (req) => db.posts.update(req.params.id, req.body))
}, { prefix: '/editor' })
```

**Key Points:**

- Encapsulation means hooks do not leak between scopes.
- Adding a new route inside the scope automatically inherits RBAC — no per-route annotation needed.
- Prefix options keep URL namespacing clean.

---

### Pattern 5 — Route Schema `meta` Annotation

Attach role metadata to the route schema and enforce it in a global `onRequest` hook. This co-locates the access rule with the route definition while keeping enforcement logic centralized.

js

```js
// Global enforcement hook
fastify.addHook('onRequest', async (request, reply) => {
  const routeConfig = request.routeOptions?.config
  if (!routeConfig?.roles) return  // no role restriction on this route

  if (!request.user) {
    return reply.status(401).send({ error: 'Unauthorized' })
  }

  const userRoles = request.user.roles ?? []
  const hasRole = routeConfig.roles.some(r => userRoles.includes(r))

  if (!hasRole) {
    return reply.status(403).send({ error: 'Forbidden' })
  }
})

// Route definitions with role annotations
fastify.get('/posts', {
  config: { roles: ['viewer', 'editor', 'admin'] }
}, async () => db.posts.findAll())

fastify.post('/posts', {
  config: { roles: ['editor', 'admin'] }
}, async (request) => db.posts.create(request.body))

fastify.delete('/posts/:id', {
  config: { roles: ['admin'] }
}, async (request) => db.posts.delete(request.params.id))
```

**Key Points:**

- `request.routeOptions.config` exposes the route-level `config` object inside hooks — this is a Fastify built-in feature.
- Routes without a `roles` config key are treated as public.
- Centralizes enforcement in one place while keeping declarations close to routes.
- [Inference] This pattern works well in codebases where routes are defined declaratively and security reviewers want a single place to audit.

---

### Pattern 6 — RBAC Plugin with `@fastify/auth`

`@fastify/auth` composes multiple auth functions with AND / OR logic, making it useful for combining authentication and role checks cleanly.

js

```js
import fastifyAuth from '@fastify/auth'

await fastify.register(fastifyAuth)

fastify.decorate('verifyJWT', async function (request, reply) {
  await request.jwtVerify()
})

fastify.decorate('verifyAdmin', async function (request, reply) {
  if (!request.user?.roles?.includes('admin')) {
    throw { statusCode: 403, message: 'Admin role required' }
  }
})

fastify.decorate('verifyEditor', async function (request, reply) {
  const allowed = ['admin', 'editor']
  if (!request.user?.roles?.some(r => allowed.includes(r))) {
    throw { statusCode: 403, message: 'Editor role required' }
  }
})

// Must be JWT-authenticated AND have admin role
fastify.delete('/admin/users/:id', {
  onRequest: fastify.auth([fastify.verifyJWT, fastify.verifyAdmin], { relation: 'and' })
}, async (request) => {
  return db.users.delete(request.params.id)
})

// Must be JWT-authenticated AND have editor or admin role
fastify.post('/posts', {
  onRequest: fastify.auth([fastify.verifyJWT, fastify.verifyEditor], { relation: 'and' })
}, async (request) => {
  return db.posts.create(request.body)
})
```

**Key Points:**

- `relation: 'and'` requires all functions to pass; `relation: 'or'` (default) requires at least one.
- Throwing an object with `statusCode` and `message` is a Fastify-compatible error pattern.
- Each decorator is independently testable.

---

### Pattern 7 — Attribute-Based Access Control (ABAC)

An extension of RBAC where decisions depend on resource attributes, not just roles. Useful for ownership checks ("can edit own posts but not others").

js

```js
fastify.put('/posts/:id', {
  onRequest: fastify.authenticate
}, async (request, reply) => {
  const post = await db.posts.findById(request.params.id)

  if (!post) {
    return reply.status(404).send({ error: 'Not found' })
  }

  const isOwner = post.authorId === request.user.id
  const isAdmin = request.user.roles.includes('admin')

  if (!isOwner && !isAdmin) {
    return reply.status(403).send({ error: 'You do not own this post' })
  }

  return db.posts.update(post.id, request.body)
})
```

**Key Points:**

- Pure RBAC cannot express ownership rules — ABAC augments it with resource-level conditions.
- The policy logic (owner OR admin) can be extracted into a dedicated policy function for reuse.
- [Inference] For complex ABAC, dedicated policy engines (e.g., `node-casbin`) provide structured policy definition and evaluation outside application code.

---

### Extracting Roles from JWT Claims

When using `@fastify/jwt`, roles are commonly embedded in the token payload:

js

```js
// Signing — include roles at token creation
const token = fastify.jwt.sign({
  sub: user.id,
  roles: user.roles  // ['admin', 'editor']
})

// Verification — roles available on request.user after jwtVerify()
fastify.addHook('onRequest', async (request, reply) => {
  try {
    await request.jwtVerify()
  } catch {
    // unauthenticated — handled per-route
  }
})

fastify.get('/admin', {
  onRequest: [fastify.authenticate, fastify.requireRoles(['admin'])]
}, async (request) => {
  return { roles: request.user.roles }
})
```

**Key Points:**

- Embedding roles in the JWT avoids a DB lookup on every request — useful for stateless APIs.
- Roles in the token are stale until the token is reissued. If roles change, the old token remains valid until expiry. [Inference] Short token lifetimes or a token revocation mechanism mitigates this.
- Avoid embedding sensitive permission data in JWTs — they are Base64-encoded, not encrypted.

---

### Role Hierarchy Resolution

js

```js
const hierarchy = {
  superadmin: ['admin'],
  admin:      ['editor', 'support'],
  editor:     ['viewer'],
  viewer:     []
}

function resolveRoles (roles, visited = new Set()) {
  const resolved = new Set(roles)
  for (const role of roles) {
    if (visited.has(role)) continue
    visited.add(role)
    const inherited = hierarchy[role] ?? []
    for (const r of resolveRoles(inherited, visited)) {
      resolved.add(r)
    }
  }
  return resolved
}

// resolveRoles(['admin']) → Set { 'admin', 'editor', 'support', 'viewer' }
// resolveRoles(['editor']) → Set { 'editor', 'viewer' }
```

**Key Points:**

- `visited` prevents infinite loops in circular hierarchies.
- [Inference] Hierarchy resolution can be precomputed at startup if the hierarchy is static, avoiding repeated traversal per request.

---

### Centralized Policy Module

For larger applications, extract all RBAC logic into a dedicated policy module:

js

```js
// policies/post.policy.js
export function canRead (user) {
  return user.roles.some(r => ['viewer', 'editor', 'admin'].includes(r))
}

export function canWrite (user) {
  return user.roles.some(r => ['editor', 'admin'].includes(r))
}

export function canDelete (user) {
  return user.roles.includes('admin')
}

export function canPublish (user) {
  return user.roles.some(r => ['editor', 'admin'].includes(r))
}

export function canEditOwn (user, post) {
  return post.authorId === user.id || user.roles.includes('admin')
}
```

js

```js
// In route handlers
import * as PostPolicy from './policies/post.policy.js'

fastify.delete('/posts/:id', { onRequest: fastify.authenticate }, async (request, reply) => {
  if (!PostPolicy.canDelete(request.user)) {
    return reply.status(403).send({ error: 'Forbidden' })
  }
  await db.posts.delete(request.params.id)
  return { deleted: true }
})
```

**Key Points:**

- Policy functions are pure — easy to unit test without Fastify context.
- Separating policy from transport (HTTP) is a clean architecture principle.
- Naming policy functions after business intent (`canPublish`) is more expressive than role names alone.

---

### Comparison of Patterns

| Pattern | Centralized | Reusable | Per-Resource | Complexity |
| --- | --- | --- | --- | --- |
| Inline check | No | No | Yes | Low |
| Role decorator | Yes | Yes | No | Low |
| Permission decorator | Yes | Yes | No | Medium |
| Hook-based scope | Yes | Partial | No | Low |
| Route `config` meta | Yes | Yes | No | Medium |
| `@fastify/auth` composition | Yes | Yes | No | Medium |
| ABAC / ownership | Partial | Partial | Yes | High |
| Policy module | Yes | Yes | Yes | Medium |

---

### Security Considerations

- Always authenticate before authorizing — RBAC checks on an unverified `request.user` are unsafe.
- Return `403 Forbidden` (not `404`) for resources that exist but are inaccessible. Returning `404` for authorization failures leaks resource existence information. [Inference] The choice between 403 and 404 depends on whether resource existence itself is sensitive.
- Roles stored in JWTs become stale — use short expiry or a revocation list for roles that change frequently.
- Do not trust roles passed by the client in request bodies or query parameters — always derive them from the verified identity.
- Audit log role-restricted actions — log who performed what and when, especially for destructive operations.
- Apply principle of least privilege — default to the most restrictive access and explicitly grant upward.
- Test authorization boundaries — write tests that assert 403 responses for each role that should be denied.

---

**Related Topics:**

- `@fastify/auth` for composing multiple auth checks
- Attribute-Based Access Control (ABAC) with `node-casbin`
- JWT role claims and token refresh strategies
- Row-level security in PostgreSQL as a complement to app-level RBAC
- Audit logging patterns in Fastify
- Multi-tenancy access control patterns
- Feature flags as a complement to role-based access