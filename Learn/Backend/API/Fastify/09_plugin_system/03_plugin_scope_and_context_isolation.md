### Plugin Scope and Context Isolation

Fastify's encapsulation is not just a convenience feature — it is the core architectural guarantee that makes large Fastify applications composable and predictable. This topic covers exactly what is isolated, what is inherited, how the boundaries work, and how to reason about scope at runtime.

---

#### What "Scope" Means in Fastify

Every call to `fastify.register()` produces a **new child instance** — a scoped copy of the Fastify instance. This child inherits the state of its parent **at the moment of registration**, but any additions made inside the child do not propagate upward or sideways.

This is not middleware stacking. It is a **tree of instances**.

Root Instancedecorators: Ahooks: H1Child 1inherits: A, H1adds: B, H2Child 2inherits: A, H1no access to: B, H2Grandchild of C1inherits: A, H1, B, H2

---

#### What Is Isolated Per Scope

The following are **scope-local** by default — they do not escape the plugin boundary:

| Entity | Isolated? | Notes |
| --- | --- | --- |
| `fastify.decorate()` additions | Yes | Not visible to parent or siblings |
| `addHook()` hooks | Yes | Only apply to routes in same or child scope |
| Routes (`get`, `post`, etc.) | Yes | Always scoped, never leak |
| `setErrorHandler()` | Yes | Applies only within the scope |
| `setNotFoundHandler()` | Yes | Scoped to the plugin |
| `setReplySerializer()` | Yes | Scoped serialization behavior |
| `setValidatorCompiler()` | Yes | Scoped validation behavior |

---

#### What Is Inherited From Parent

A child scope receives a snapshot of its parent's state at registration time:

js

```
fastify.decorate('config', { env: 'production' })

fastify.register(async function child(fastify) {
  console.log(fastify.config.env)  // 'production' — inherited
})
```

**Key Points:**

- Inheritance is a **snapshot at registration time**, not a live reference.
- If the parent adds a decorator *after* `register()` is called, the child does not receive it.

js

```
fastify.register(async function child(fastify) {
  console.log(fastify.lateAdd)  // undefined — registered too late
})

fastify.decorate('lateAdd', true)  // added after register() call
```

[Inference] The snapshot behavior is a consequence of `avvio`'s deferred execution model. The child captures parent state at queue time, not at execution time. Actual behavior may vary — this should be verified against the specific Fastify version in use.

---

#### Scope Isolation in Practice

##### Decorators

js

```
fastify.register(async function pluginA(fastify) {
  fastify.decorate('serviceA', {})
  console.log(fastify.serviceA)  // accessible
})

fastify.register(async function pluginB(fastify) {
  console.log(fastify.serviceA)  // undefined — not visible here
})
```

##### Hooks

js

```
fastify.register(async function authScope(fastify) {
  fastify.addHook('onRequest', authMiddleware)

  fastify.get('/secure', secureHandler)
  // authMiddleware runs for /secure
})

fastify.get('/public', publicHandler)
// authMiddleware does NOT run for /public
```

This is the standard pattern for applying authentication to a subset of routes without a conditional check inside the hook itself.

##### Error Handlers

js

```
fastify.register(async function apiScope(fastify) {
  fastify.setErrorHandler(async (error, request, reply) => {
    reply.status(500).send({ error: 'API error', message: error.message })
  })

  fastify.get('/data', riskyHandler)
})

fastify.get('/other', otherHandler)
// /other uses the root error handler, not the scoped one
```

---

#### The Scope Tree at Runtime

Each scoped instance maintains its own:

- Hook pipeline
- Decorator registry
- Error handler reference
- Not-found handler reference
- Reply serializer
- Validator compiler

```
graph LR
  subgraph Root
    RH["hooks: [H1]"]
    RD["decorators: {db}"]
    RE["errorHandler: default"]
  end

  subgraph Child A
    AH["hooks: [H1, H2]"]
    AD["decorators: {db, cache}"]
    AE["errorHandler: customA"]
  end

  subgraph Child B
    BH["hooks: [H1]"]
    BD["decorators: {db}"]
    BE["errorHandler: default"]
  end

  Root -->|inherits| Child A
  Root -->|inherits| Child B
```

---

#### Sibling Isolation

Siblings share nothing except what was defined in their common ancestor.

js

```
fastify.register(async function sibling1(fastify) {
  fastify.decorate('x', 1)
})

fastify.register(async function sibling2(fastify) {
  // fastify.x is undefined here
  // sibling1's decorator never reaches sibling2
})
```

There is no sideways communication between sibling scopes unless a value is defined at the parent level — typically via `fastify-plugin`.

---

#### Breaking Isolation Intentionally — `fastify-plugin`

When a plugin is wrapped with `fastify-plugin`, its scope is merged back into the parent. This is the only supported mechanism for sharing decorators and hooks across sibling plugins.

js

```
const fp = require('fastify-plugin')

fastify.register(fp(async function(fastify) {
  fastify.decorate('db', createDb())
}))

fastify.register(async function(fastify) {
  fastify.db  // accessible — fp merged 'db' into root
})
```

decorator promotedRoot Instancefp-wrapped pluginmerges db → RootScoped Plugincan access db

**Key Points:**

- `fastify-plugin` does not create a child scope — it executes in the parent's scope.
- Hooks added inside an `fp`-wrapped plugin are also promoted to the parent scope.
- This means hooks in an `fp`-wrapped plugin run for **all routes** in the application, not just a subset.

---

#### Scope and Route Prefixes

A `prefix` option does not affect scope isolation — it only affects URL construction. Two plugins with the same prefix are still fully isolated from each other.

js

```
fastify.register(async function(fastify) {
  fastify.decorate('x', 1)
  fastify.get('/route', handler)  // → /api/route
}, { prefix: '/api' })

fastify.register(async function(fastify) {
  // fastify.x still undefined — prefix does not merge scopes
  fastify.get('/other', handler)  // → /api/other
}, { prefix: '/api' })
```

---

#### Context Isolation and Request Lifecycle

Scope isolation applies to the **application-level setup** — decorators, hooks, and handlers. At request time, each request has its own `Request` and `Reply` instance, but these are not shared across concurrent requests regardless of scope.

[Inference] Mutable state attached to the Fastify instance via `decorate()` is shared across all requests within that scope. Race conditions are possible if decorated values are mutated per-request. This is a common source of bugs and should be handled carefully.

js

```
// Risky — shared mutable state on the instance
fastify.decorate('counter', 0)
fastify.get('/count', async () => {
  fastify.counter++       // shared across all requests
  return fastify.counter  // not reliable under concurrency
})

// Safer — state scoped to the request
fastify.decorateRequest('counter', 0)
fastify.get('/count', async (req) => {
  req.counter++
  return req.counter
})
```

---

#### `decorateRequest` and `decorateReply` — Per-Request Scope

Beyond instance-level decoration, Fastify provides `decorateRequest` and `decorateReply` to attach properties to individual request and reply objects. These are scoped to a single request lifecycle.

js

```
fastify.decorateRequest('user', null)

fastify.addHook('onRequest', async (req) => {
  req.user = await getUserFromToken(req.headers.authorization)
})

fastify.get('/profile', async (req) => {
  return req.user
})
```

**Key Points:**

- `decorateRequest` and `decorateReply` must be called before routes that use them.
- They follow the same scope rules — declared in a child scope, they are not visible in siblings or the parent.
- Reference types (objects, arrays) used as default values in `decorateRequest` should be initialized with `null` and set per-request to avoid shared state across requests.

---

#### Visualizing Full Scope Behavior

Rootdecorators: db (fp)hooks: globalLogAuth Scopehooks:onRequest→verifyJwtroutes: /admin/\*Public Scopehooks: none addedroutes: /public/\*Admin Sub-scopehooks:onRequest→verifyRoleroutes: /admin/settings

In this structure:

- `/public/*` routes run only `globalLog`
- `/admin/*` routes run `globalLog` + `verifyJwt`
- `/admin/settings` routes run `globalLog` + `verifyJwt` + `verifyRole`

---

#### Summary

**Conclusion:**
Scope isolation in Fastify is precise and structural. Each `register()` call creates a child instance that inherits from its parent but exposes nothing upward or sideways. This makes it possible to compose large applications from independent modules, apply hooks and error handlers to exact route subsets, and reason about behavior without global side effects. The only intentional escape hatch is `fastify-plugin`, which promotes a plugin's additions back to the parent scope.