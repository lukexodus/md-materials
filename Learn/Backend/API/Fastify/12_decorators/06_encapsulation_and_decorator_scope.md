## Fastify — Encapsulation and Decorator Scope

### Overview

Encapsulation is a foundational design principle in Fastify. Every plugin registered via `fastify.register()` receives its own child scope — an isolated context that inherits from its parent but does not expose its own additions back upward or sideways. Decorators, hooks, and routes registered within a scope stay within that scope unless explicitly configured to propagate.

Understanding how scope affects decorators is essential for building predictable, maintainable Fastify applications.

---

### How Scopes Are Created

Each call to `fastify.register()` creates a new child scope. The child inherits everything from its parent at the time of creation, but additions made inside the child do not travel back to the parent.

js

```
import Fastify from 'fastify'

const fastify = Fastify() // root scope

fastify.register(async (child) => {
  // 'child' is a new scope, inheriting from 'fastify'
  child.decorate('util', () => 'hello')

  console.log(child.util()) // ✓ 'hello'
  console.log(child.hasDecorator('util')) // ✓ true
})

fastify.ready(() => {
  console.log(fastify.hasDecorator('util')) // ✗ false — not propagated
})
```

**Key Points:**

- `child` inherits from `fastify` (root)
- `util` is added to `child` — it does not propagate upward
- The root scope is unaware of `util`

---

### Inheritance Direction

Scope inheritance flows **downward only**. A child scope sees everything its parent has, but the parent does not see what the child adds.

inherits downinherits downinherits downinherits downRoot ScopePlugin A ScopePlugin B ScopePlugin A1 ScopePlugin A2 Scope

**Key Points:**

- `Plugin A Scope` sees root decorators
- `Plugin B Scope` sees root decorators
- `Plugin A Scope` does **not** see decorators added inside `Plugin B Scope`
- `Plugin A1 Scope` sees both root and Plugin A decorators
- Root sees none of the child additions

---

### Decorator Scope — `decorate`

A decorator registered on a scope is available to that scope and all its descendants, but not to its parent or siblings.

js

```
const fastify = Fastify()

fastify.decorate('rootUtil', () => 'root') // available everywhere

fastify.register(async (pluginA) => {
  pluginA.decorate('aUtil', () => 'a')

  pluginA.register(async (childOfA) => {
    // ✓ sees both rootUtil and aUtil
    childOfA.rootUtil()
    childOfA.aUtil()
  })
})

fastify.register(async (pluginB) => {
  // ✓ sees rootUtil
  fastify.rootUtil()

  // ✗ does not see aUtil — sibling scope
  // fastify.aUtil() → undefined or error
})
```

---

### Decorator Scope — `decorateRequest` and `decorateReply`

Request and reply decorators follow the same scoping rules. A `decorateRequest` call inside a plugin scope attaches the property only to requests handled by routes within that scope.

js

```
fastify.register(async (instance) => {
  instance.decorateRequest('tenantId', null)

  instance.addHook('onRequest', async (request) => {
    request.tenantId = 'tenant-abc'
  })

  instance.get('/scoped', async (request) => {
    return { tenantId: request.tenantId } // ✓ available
  })
})

fastify.get('/unscoped', async (request) => {
  return { tenantId: request.tenantId } // ✗ undefined — not in scope
})
```

**Key Points:**

- `tenantId` exists on `request` only for routes inside the plugin scope
- Routes outside the scope do not have the property initialized by that decorator
- [Inference] Accessing an unregistered decorator property on `request` returns `undefined` at runtime rather than throwing, but this behavior may vary by Fastify version

---

### Visualizing Decorator Visibility

decorates: rootUtildecorates: aUtilRootPlugin APlugin BPlugin A1

| Scope | Sees `rootUtil` | Sees `aUtil` |
| --- | --- | --- |
| Root | ✓ | ✗ |
| Plugin A | ✓ | ✓ |
| Plugin B | ✓ | ✗ |
| Plugin A1 | ✓ | ✓ |

---

### Checking Decorator Existence

Fastify provides `hasDecorator`, `hasRequestDecorator`, and `hasReplyDecorator` to check whether a decorator exists on a given scope. These are scope-aware.

js

```
fastify.decorate('db', {})

fastify.register(async (instance) => {
  console.log(instance.hasDecorator('db'))         // ✓ true — inherited
  console.log(instance.hasDecorator('nonExistent')) // ✗ false

  instance.decorate('local', 42)
  console.log(instance.hasDecorator('local'))       // ✓ true
})

fastify.ready(() => {
  console.log(fastify.hasDecorator('local'))        // ✗ false — not propagated
})
```

These methods are useful for writing defensive plugin code that checks for prerequisites before registering.

js

```
const safePlugin = fp(async (fastify) => {
  if (!fastify.hasDecorator('db')) {
    throw new Error('db decorator is required before loading safePlugin')
  }

  fastify.decorate('repo', { find: async () => fastify.db.query('SELECT 1') })
})
```

---

### Registering at Root to Share Across All Plugins

The simplest way to make a decorator available everywhere is to register it on the root instance before any plugins.

js

```
const fastify = Fastify()

// Registered on root — available to all plugins
fastify.decorate('config', { env: 'production' })
fastify.decorateRequest('user', null)
fastify.decorateReply('requestStartTime', null)

fastify.register(pluginA) // sees config, user, requestStartTime
fastify.register(pluginB) // sees config, user, requestStartTime
```

This approach is straightforward but bypasses encapsulation entirely for those decorators. It is appropriate for truly global concerns.

---

### Escaping Encapsulation with `fastify-plugin`

When a decorator must be defined inside a plugin (for organizational or dependency reasons) but needs to be visible to sibling plugins, wrap it with `fastify-plugin`.

js

```
import fp from 'fastify-plugin'

const dbPlugin = fp(async (fastify) => {
  fastify.decorate('db', { query: async () => [] })
})

fastify.register(dbPlugin)   // 'db' propagates to root scope
fastify.register(pluginA)    // ✓ sees 'db'
fastify.register(pluginB)    // ✓ sees 'db'
```

Without `fp()`, `db` would be scoped to the child created by `fastify.register(dbPlugin)` and invisible to `pluginA` and `pluginB`.

---

### Duplicate Decorator Registration

Fastify throws an error if you attempt to register a decorator with the same name on the same scope twice. This applies even if the values differ.

js

```
fastify.decorate('util', 1)
fastify.decorate('util', 2) // ✗ Throws — duplicate decorator on same scope
```

However, a child scope can register a decorator with the same name as one in its parent. This **shadows** the parent decorator within the child scope.

js

```
fastify.decorate('logger', { level: 'info' })

fastify.register(async (instance) => {
  // ✓ allowed — shadows parent 'logger' in this scope only
  instance.decorate('logger', { level: 'debug' })

  console.log(instance.logger.level) // 'debug'
})

fastify.ready(() => {
  console.log(fastify.logger.level) // 'info' — root unchanged
})
```

> [Inference] Decorator shadowing in child scopes is an observed behavior based on Fastify's encapsulation model. Whether Fastify emits a warning or error in this case may vary by version. Verify against the version in use.

---

### Encapsulation and Hooks

Hooks follow the same scoping rules as decorators. A hook registered inside a plugin only runs for routes within that plugin's scope.

js

```
fastify.register(async (instance) => {
  instance.decorateRequest('user', null)

  // This hook only runs for routes inside this plugin
  instance.addHook('preHandler', async (request) => {
    request.user = { id: 1 }
  })

  instance.get('/inside', async (request) => {
    return request.user // ✓ { id: 1 }
  })
})

fastify.get('/outside', async (request) => {
  return request.user // ✗ undefined — hook did not run
})
```

This makes encapsulation a powerful tool for applying cross-cutting concerns (auth, logging, rate limiting) to specific route groups without affecting the rest of the application.

---

### Common Mistakes

| Mistake | Problem | Fix |
| --- | --- | --- |
| Expecting child decorators to be visible in parent | Scope flows downward only | Use `fp()` or root-level registration |
| Registering same decorator twice on same scope | Startup error | Check with `hasDecorator` first, or restructure |
| Assuming sibling plugins share scope | Siblings are isolated | Use shared parent scope or `fp()` |
| Forgetting hooks are also scoped | Hook does not run for routes outside plugin | Register hook at root or use `fp()` |
| Using root-level registration for everything | Loses encapsulation benefits | Reserve root-level for truly global concerns |

---

### Scope Decision Guide

| Requirement | Approach |
| --- | --- |
| Available to all plugins and routes | Register on root before any plugins |
| Defined in a plugin, shared with siblings | Wrap provider plugin with `fp()` |
| Available only within one feature plugin | Register inside that plugin without `fp()` |
| Available to a subtree of plugins | Register on the common ancestor scope |

---

### Summary

| Concept | Detail |
| --- | --- |
| Default scope | Each `register()` call creates an isolated child scope |
| Inheritance direction | Downward only — children see parents, not vice versa |
| Sibling visibility | Siblings cannot see each other's decorators by default |
| Sharing decorators | Root-level registration or `fp()` on the provider plugin |
| Duplicate registration | Throws on same scope; shadowing is possible in child scopes |
| Hooks and decorators | Both follow the same encapsulation rules |
| Scope inspection | `hasDecorator`, `hasRequestDecorator`, `hasReplyDecorator` |