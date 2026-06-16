## Scoped vs Global Middleware

### Overview

In Fastify, "middleware" in the broad sense — hooks, plugins, decorators, and route handlers — participates in an encapsulation model inherited from its plugin system. Every plugin registered with `fastify.register()` creates an isolated child scope. Whether a hook or plugin applies globally or only within a specific scope depends on where it is registered and whether encapsulation is intentionally broken.

Understanding scope is fundamental to structuring Fastify applications correctly. Misplacing a hook registration is a common source of bugs where middleware applies to routes it should not, or fails to apply to routes it should.

---

### The Encapsulation Model

Fastify's plugin system is built on [`avvio`](https://github.com/fastify/avvio), which constructs a directed acyclic graph of plugins. Each `fastify.register()` call creates a child context that inherits from its parent but does not expose additions back upward or sideways to sibling scopes.

```
Root (fastify)
├── Plugin A  (child scope)
│   └── Plugin A1  (grandchild scope)
└── Plugin B  (child scope, sibling of A)
```

**Key Points:**
- A hook or decoration registered in Plugin A is visible to Plugin A1 (child inherits from parent)
- A hook registered in Plugin A is not visible to Plugin B (siblings do not share scope)
- A hook registered on the root `fastify` instance is visible to all plugins
- Additions made inside a plugin do not propagate upward to the parent

---

### Global Hooks

A hook registered directly on the root Fastify instance, before any `register` calls that define routes, applies to all requests regardless of which route or plugin handles them.

```js
import Fastify from 'fastify'

const fastify = Fastify()

// Global — applies to every route in the application
fastify.addHook('onRequest', async (request, reply) => {
  request.startTime = Date.now()
})

fastify.register(async function routesA(instance) {
  instance.get('/a', async () => ({ route: 'a' }))
})

fastify.register(async function routesB(instance) {
  instance.get('/b', async () => ({ route: 'b' }))
})

await fastify.listen({ port: 3000 })
```

Both `/a` and `/b` pass through the `onRequest` hook above.

**Key Points:**
- Registration order matters — hooks registered on the root instance before `register` calls are reliably global
- [Inference] Hooks registered on the root instance after child plugins have already loaded may behave unexpectedly in some configurations; registering global hooks early is the safer pattern, though behavior may vary
- Global hooks are appropriate for concerns that must apply universally: request timing, global logging, security headers

---

### Scoped Hooks

A hook registered inside a `fastify.register()` callback applies only to routes defined within that same plugin scope and any of its children.

```js
fastify.register(async function privateRoutes(instance) {

  // Scoped — applies only within this plugin
  instance.addHook('onRequest', async (request, reply) => {
    if (!request.headers.authorization) {
      reply.code(401).send({ error: 'Unauthorized' })
    }
  })

  instance.get('/profile', async () => ({ user: 'data' }))
  instance.get('/settings', async () => ({ settings: {} }))
})

fastify.register(async function publicRoutes(instance) {
  // No hook here — these routes are unprotected
  instance.get('/health', async () => ({ status: 'ok' }))
  instance.get('/login', async () => ({ token: '...' }))
})
```

`/profile` and `/settings` are protected. `/health` and `/login` are not.

---

### Child Scopes Inherit from Parents

Hooks registered in a parent scope are inherited by child scopes registered within it.

```js
fastify.register(async function parent(instance) {

  instance.addHook('onRequest', async (request, reply) => {
    console.log('Parent hook:', request.url)
  })

  // Child inherits the parent's onRequest hook
  instance.register(async function child(childInstance) {
    childInstance.get('/child-route', async () => ({ level: 'child' }))
  })

  instance.get('/parent-route', async () => ({ level: 'parent' }))
})
```

Both `/parent-route` and `/child-route` pass through the `onRequest` hook, but routes outside `parent` do not.

---

### Breaking Encapsulation with fastify-plugin

When a plugin is wrapped with `fastify-plugin`, its additions are propagated to the parent scope rather than being confined to the child. This is the standard mechanism for shared infrastructure — database connections, authentication utilities, decorators — that multiple sibling scopes need.

```js
import fp from 'fastify-plugin'

async function authPlugin(fastify, options) {
  fastify.addHook('onRequest', async (request, reply) => {
    if (!request.headers.authorization) {
      reply.code(401).send({ error: 'Unauthorized' })
    }
  })
}

// Without fp(): hook is scoped, only visible inside this register
// With fp(): hook escapes encapsulation, visible to parent and siblings
fastify.register(fp(authPlugin))

fastify.register(async function routes(instance) {
  // This route is protected because authPlugin used fp()
  instance.get('/protected', async () => ({ ok: true }))
})
```

**Key Points:**
- `fastify-plugin` is the deliberate, explicit way to share hooks and decorators across scope boundaries
- Using it indiscriminately eliminates Fastify's encapsulation guarantees — apply it only to plugins intended as shared infrastructure
- Plugins wrapped with `fastify-plugin` should not define routes; they are intended for side effects and shared state

---

### Combining Scoped and Global Hooks

A common real-world pattern applies a global hook for universal concerns and scoped hooks for route-group-specific concerns.

```js
// Global — all routes
fastify.addHook('onRequest', async (request, reply) => {
  request.startTime = Date.now()
})

// Global — all routes
fastify.addHook('onResponse', async (request, reply) => {
  fastify.log.info({ url: request.url, ms: Date.now() - request.startTime })
})

// Scoped — only admin routes
fastify.register(async function adminRoutes(instance) {
  instance.addHook('preHandler', async (request, reply) => {
    if (!request.headers['x-admin-token']) {
      reply.code(403).send({ error: 'Forbidden' })
    }
  })

  instance.get('/admin/users', async () => ({ users: [] }))
})

// Scoped — public routes, no additional hooks
fastify.register(async function publicRoutes(instance) {
  instance.get('/status', async () => ({ status: 'ok' }))
})
```

---

### Hook Execution Order Across Scopes

When a route is matched, all hooks that apply to it — from root down through the matching scope chain — execute in registration order, outermost first.

```
Root onRequest hook(s)
  └── Parent scope onRequest hook(s)
        └── Child scope onRequest hook(s)
              └── Route handler
```

**Example:**

```js
fastify.addHook('onRequest', async (request) => {
  console.log('1 — root')
})

fastify.register(async function outer(instance) {
  instance.addHook('onRequest', async (request) => {
    console.log('2 — outer')
  })

  instance.register(async function inner(innerInstance) {
    innerInstance.addHook('onRequest', async (request) => {
      console.log('3 — inner')
    })

    innerInstance.get('/deep', async () => ({ depth: 3 }))
  })
})
```

A request to `/deep` produces:

**Output:**
```
1 — root
2 — outer
3 — inner
```

---

### Common Mistakes

#### Registering a scoped hook at the wrong level

```js
// Intended to protect only /admin routes,
// but registered at root — applies to everything
fastify.addHook('preHandler', async (request, reply) => {
  requireAdminToken(request, reply)
})

fastify.register(async function adminRoutes(instance) {
  instance.get('/admin/dashboard', async () => ({}))
})

fastify.get('/public', async () => ({ ok: true })) // Also protected — unintended
```

Fix: move the `addHook` call inside the `adminRoutes` plugin.

#### Expecting a scoped plugin to affect sibling routes

```js
fastify.register(async function pluginA(instance) {
  instance.addHook('onRequest', async (request) => {
    console.log('pluginA hook')
  })
})

fastify.register(async function pluginB(instance) {
  // pluginA's hook does NOT run for routes in pluginB
  instance.get('/b', async () => ({}))
})
```

Fix: use `fastify-plugin` or register the hook at the root level.

---

### Decision Guide

| Requirement | Approach |
|---|---|
| Hook applies to all routes | Register on root `fastify` before plugins |
| Hook applies to a specific group of routes | Register inside a `fastify.register()` scope |
| Hook must be shared across sibling plugins | Wrap with `fastify-plugin` |
| Hook must not leak outside its module | Use plain `register` without `fastify-plugin` |
| Infrastructure shared globally (DB, auth) | Plugin wrapped with `fastify-plugin` |

---

**Conclusion:** Fastify's encapsulation model gives precise control over where hooks and plugins apply. Global hooks belong on the root instance; scoped hooks belong inside `register` callbacks. `fastify-plugin` is the explicit escape hatch for sharing behavior across scope boundaries. Getting this right produces applications where each scope is self-contained, authorization boundaries are structurally enforced, and unintended hook bleed between route groups is avoided by design rather than by convention.