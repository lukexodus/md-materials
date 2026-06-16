## Custom Constraint Strategies in Fastify

Custom constraint strategies allow you to extend Fastify's routing system beyond its built-in constraints (such as `version` and `host`). By defining your own constraint strategy, you can match routes based on arbitrary request properties — such as custom headers, tenant identifiers, feature flags, or any value derivable from the request object.

---

### What Are Constraint Strategies?

Fastify's router (powered by `find-my-way`) supports a pluggable constraint system. Each constraint strategy defines:

- **How to derive a constraint value** from an incoming request
- **How to store and match** constraint values against registered routes
- **A name** used to reference the strategy in route definitions

This allows route selection to go beyond URL shape and HTTP method.

---

### Anatomy of a Custom Constraint Strategy

A constraint strategy is a plain object conforming to a specific interface:

```js
const myStrategy = {
  name: 'myConstraintName',       // Unique identifier
  storage: function () {           // Factory: returns a storage instance
    let constraints = {}
    return {
      get (value) {
        return constraints[value] ?? null
      },
      set (value, store) {
        constraints[value] = store
      },
      del (value) {
        delete constraints[value]
      },
      empty () {
        constraints = {}
      }
    }
  },
  deriveConstraint (req, ctx) {   // Extracts value from incoming request
    return req.headers['x-my-header']
  },
  validate (value) {              // Optional: validates constraint values at route registration
    if (typeof value !== 'string') {
      throw new Error('Constraint value must be a string')
    }
  },
  mustMatchWhenDefined: true      // If true, routes without this constraint won't match when value is present
}
```

**Key Points:**
- `name` must be unique across all registered strategies.
- `storage()` is called once per route tree node; it must return a fresh storage object each time.
- `deriveConstraint` runs on every incoming request — keep it fast.
- `mustMatchWhenDefined` controls fallback behavior (explained below).

---

### Registering a Custom Constraint Strategy

Pass the strategy to Fastify during instantiation via `constraints`:

```js
const fastify = require('fastify')({
  constraints: {
    myConstraintName: myStrategy
  }
})
```

Or register it after instantiation using `addConstraintStrategy`:

```js
fastify.addConstraintStrategy(myStrategy)
```

> **Note:** Strategies must be registered before any route that uses them. [Inference] Registration order matters because route compilation may occur at plugin initialization time; behavior may vary across Fastify versions.

---

### Defining Routes with Custom Constraints

Once a strategy is registered, use its `name` as a key inside the `constraints` option of a route:

```js
fastify.get('/resource', {
  constraints: {
    myConstraintName: 'expected-value'
  }
}, async (req, reply) => {
  return { matched: true }
})
```

You can register multiple routes with the same URL and method but different constraint values:

```js
fastify.get('/resource', {
  constraints: { myConstraintName: 'alpha' }
}, async () => ({ variant: 'alpha' }))

fastify.get('/resource', {
  constraints: { myConstraintName: 'beta' }
}, async () => ({ variant: 'beta' }))
```

Fastify will route requests to the appropriate handler based on the derived constraint value.

---

### Practical Example: Tenant-Based Routing

A multi-tenant API that routes requests by a `x-tenant-id` header.

**Strategy definition:**

```js
const tenantConstraint = {
  name: 'tenant',
  storage () {
    let tenants = {}
    return {
      get (tenantId) { return tenants[tenantId] ?? null },
      set (tenantId, store) { tenants[tenantId] = store },
      del (tenantId) { delete tenants[tenantId] },
      empty () { tenants = {} }
    }
  },
  deriveConstraint (req) {
    return req.headers['x-tenant-id']
  },
  validate (value) {
    if (typeof value !== 'string' || value.trim() === '') {
      throw new TypeError('tenant constraint must be a non-empty string')
    }
  },
  mustMatchWhenDefined: true
}
```

**Registration and routes:**

```js
const fastify = require('fastify')()

fastify.addConstraintStrategy(tenantConstraint)

fastify.get('/settings', {
  constraints: { tenant: 'acme' }
}, async () => {
  return { tenant: 'acme', theme: 'dark' }
})

fastify.get('/settings', {
  constraints: { tenant: 'globex' }
}, async () => {
  return { tenant: 'globex', theme: 'light' }
})

fastify.listen({ port: 3000 })
```

**Example requests:**

```
GET /settings
x-tenant-id: acme
→ { "tenant": "acme", "theme": "dark" }

GET /settings
x-tenant-id: globex
→ { "tenant": "globex", "theme": "light" }

GET /settings
x-tenant-id: unknown
→ 404 Not Found  (because mustMatchWhenDefined: true)
```

---

### Understanding `mustMatchWhenDefined`

This boolean controls what happens when a request carries a constraint value but no route matches it exactly.

| `mustMatchWhenDefined` | Behavior when no route matches the derived value |
|---|---|
| `true` | Request results in a 404 — no fallback to unconstrained routes |
| `false` | Falls back to routes registered without this constraint |

**Example (fallback with `false`):**

```js
// mustMatchWhenDefined: false on the strategy

fastify.get('/data', {
  constraints: { tenant: 'acme' }
}, async () => ({ source: 'acme-specific' }))

fastify.get('/data', async () => ({ source: 'generic' }))
// ↑ This route has no tenant constraint

// Request with x-tenant-id: unknown → matches generic route
// Request with x-tenant-id: acme   → matches acme-specific route
```

> [Inference] The fallback behavior depends on how `find-my-way` resolves ambiguity in the route tree; exact behavior may vary and should be verified with integration tests.

---

### Combining Multiple Constraints

A single route can use multiple constraints simultaneously — both built-in and custom:

```js
fastify.get('/api/data', {
  constraints: {
    version: '2.0.0',
    tenant: 'acme'
  }
}, async () => {
  return { version: 2, tenant: 'acme' }
})
```

Fastify evaluates all constraints conjunctively — all must match for the route to be selected.

---

### Using `deriveConstraint` with Context

The second argument to `deriveConstraint` is a context object (`ctx`) provided by `find-my-way`. Its shape and content depend on the router version and [Unverified] may not be consistently populated in all Fastify versions.

```js
deriveConstraint (req, ctx) {
  // ctx is available but its structure is router-internal
  return req.headers['x-custom']
}
```

For most use cases, only `req` is needed.

---

### Async Constraints

`deriveConstraint` is expected to be **synchronous**. Fastify's routing phase does not await promises from this function.

> [Inference] If you need async-derived values (e.g., from a cache or database), you would need to resolve and attach them to the request in a pre-routing hook (`onRequest`) before the constraint is evaluated — though this pattern is not officially documented as a supported approach and behavior is not guaranteed.

---

### Validation at Route Registration

The optional `validate(value)` method is called when a route is registered with the constraint. Use it to catch misconfigured routes early:

```js
validate (value) {
  const allowed = ['acme', 'globex', 'initech']
  if (!allowed.includes(value)) {
    throw new Error(`Unknown tenant: "${value}". Must be one of: ${allowed.join(', ')}`)
  }
}
```

This throws at startup (registration time), not at runtime — a useful safeguard.

---

### Performance Considerations

- `deriveConstraint` is called on every request matching the route's path — minimize work done here.
- Avoid object allocation, async operations, or external calls inside `deriveConstraint`.
- The `storage()` factory is called once per internal node, not per request — its contents are long-lived.

> [Inference] Complex storage logic or large constraint value spaces may have non-trivial memory implications; this should be profiled per use case.

---

### Custom Constraint vs. Hook-Based Filtering

An alternative to custom constraints is using `onRequest` or `preHandler` hooks with manual 404/redirect logic. The tradeoff:

| Approach | Route selection | Performance | Clarity |
|---|---|---|---|
| Custom constraint | At router level | Faster (no handler invoked) | Declarative |
| Hook-based filter | Inside handler lifecycle | Slightly more overhead | Imperative |

Custom constraints are preferable when the branching is fundamental to routing identity. Hook-based filtering is more appropriate for access control or conditional logic within a matched route.

---

**Related Topics:**
- Built-in constraints (`version`, `host`) and Accept-Version negotiation
- `find-my-way` internals and route tree structure
- Combining constraints with Fastify plugins and encapsulation
- `onRequest` hook ordering relative to route matching
- Multi-tenant Fastify architecture patterns
- Route conflict detection and ambiguity resolution