## Fastify — Using Decorators Across Plugins

### Overview

Fastify's plugin system is built on encapsulation: each plugin runs in its own scope, and anything registered inside it — decorators, hooks, routes — is not visible outside by default. This is intentional and useful for isolation, but it means that sharing decorators across plugins requires deliberate design.

The primary tool for sharing decorators across plugin boundaries is `fastify-plugin` (`fp`).

---

### Encapsulation Recap

When a plugin is registered with `fastify.register()`, Fastify creates a child scope. Decorators added inside that scope are not visible to the parent or to sibling plugins.

js

```
import Fastify from 'fastify'

const fastify = Fastify()

fastify.register(async (instance) => {
  instance.decorate('db', { query: async () => [] })

  // ✓ accessible here
  console.log(instance.db)
})

fastify.ready(() => {
  // ✗ not accessible — 'db' was scoped to the child plugin
  console.log(fastify.db) // undefined
})
```

**Key Points:**

- `instance` is a child scope of `fastify`
- Decorators on `instance` do not propagate upward
- This is Fastify's default encapsulation behavior

---

### Escaping Encapsulation with `fastify-plugin`

`fastify-plugin` (`fp`) is a utility that tells Fastify not to create a new child scope for the wrapped plugin. The plugin's registrations — decorators, hooks — are applied directly to the parent scope, making them visible to all other plugins registered on that same parent.

js

```
import Fastify from 'fastify'
import fp from 'fastify-plugin'

const fastify = Fastify()

const dbPlugin = fp(async (instance) => {
  instance.decorate('db', { query: async () => [] })
})

fastify.register(dbPlugin)

fastify.register(async (instance) => {
  // ✓ accessible — dbPlugin used fp(), so 'db' is on the parent scope
  const result = await instance.db.query('SELECT 1')
  return result
})

await fastify.listen({ port: 3000 })
```

**Key Points:**

- Wrapping with `fp()` removes encapsulation for that plugin
- The decorator is registered on the scope where `fastify.register(dbPlugin)` is called
- All sibling plugins registered on the same scope can access it

---

### Registration Order Matters

Even with `fp()`, Fastify loads plugins sequentially. A plugin that depends on a decorator must be registered **after** the plugin that provides it.

js

```
// ✓ Correct order
fastify.register(dbPlugin)      // provides 'db'
fastify.register(repoPlugin)    // consumes 'db'

// ✗ Incorrect order — 'db' not yet available when repoPlugin loads
fastify.register(repoPlugin)
fastify.register(dbPlugin)
```

> **Disclaimer:** Plugin load order behavior is based on Fastify's documented sequential plugin loading. Actual behavior may vary depending on async plugin internals and Fastify version.

---

### Typical Pattern — Shared Service Plugin

The most common real-world pattern is a shared service (database, cache, config) registered with `fp()` at the root level, consumed by feature plugins.

js

```
// plugins/db.js
import fp from 'fastify-plugin'

export default fp(async (fastify) => {
  const db = {
    query: async (sql) => {
      // simulate query
      return [{ id: 1 }]
    }
  }

  fastify.decorate('db', db)
}, {
  name: 'db-plugin',
  fastify: '4.x'
})
```

js

```
// plugins/users.js
export default async function usersPlugin(fastify) {
  fastify.get('/users', async (request, reply) => {
    return fastify.db.query('SELECT * FROM users')
  })
}
```

js

```
// app.js
import Fastify from 'fastify'
import dbPlugin from './plugins/db.js'
import usersPlugin from './plugins/users.js'

const fastify = Fastify()

fastify.register(dbPlugin)
fastify.register(usersPlugin) // 'db' is available here

await fastify.listen({ port: 3000 })
```

---

### `fp()` Options — Metadata

`fp()` accepts an optional second argument for metadata. This is not required but improves maintainability and error messages.

js

```
export default fp(async (fastify) => {
  fastify.decorate('config', { env: process.env.NODE_ENV })
}, {
  name: 'config-plugin',   // identifies the plugin in error messages
  fastify: '4.x',          // declares compatible Fastify version range
  dependencies: ['db-plugin'] // declares plugin-level dependencies by name
})
```

| Option | Type | Description |
| --- | --- | --- |
| `name` | `string` | Plugin name used in error messages and dependency tracking |
| `fastify` | `string` | Compatible Fastify version range |
| `dependencies` | `string[]` | Names of other `fp()` plugins that must be loaded first |

> [Inference] Plugin-level `dependencies` in `fp()` options operates at the plugin registration level, distinct from decorator-level dependencies declared in the third argument of `decorate`. Behavior may vary by version.

---

### Plugin-Level vs Decorator-Level Dependencies

These are two separate mechanisms that serve related but distinct purposes.

| Mechanism | Declared in | Checks |
| --- | --- | --- |
| Decorator dependency | Third arg of `decorate` / `decorateRequest` / `decorateReply` | Whether a named decorator exists on the same scope |
| Plugin dependency | `fp()` options `dependencies` array | Whether a named `fp()` plugin has been registered |

js

```
// Decorator-level dependency
fastify.decorateRequest('permissions', null, ['user'])

// Plugin-level dependency (fp options)
export default fp(async (fastify) => { ... }, {
  dependencies: ['db-plugin']
})
```

---

### `decorateRequest` and `decorateReply` Across Plugins

Request and reply decorators follow the same scoping rules. Registering them inside a non-`fp()` plugin scopes them to that plugin's routes only.

js

```
// Scoped — only available to routes inside this plugin
fastify.register(async (instance) => {
  instance.decorateRequest('tenantId', null)

  instance.get('/tenant', async (request) => {
    return { tenantId: request.tenantId }
  })
})

// ✗ Routes outside the plugin do not have 'tenantId'
fastify.get('/outside', async (request) => {
  return { tenantId: request.tenantId } // undefined
})
```

To share a request or reply decorator across all routes, register it with `fp()` or at the root level before any plugins.

js

```
// Root-level — available everywhere
fastify.decorateRequest('tenantId', null)

fastify.register(pluginA) // has access to request.tenantId
fastify.register(pluginB) // has access to request.tenantId
```

---

### Visualizing Scope Propagation

decorate db propagatesto rootreads fastify.dbreads fastify.dbRoot Fastify Instancefp plugin — dbFeature Plugin — usersFeature Plugin — orders

**Key Points:**

- `fp()` causes the decorator to propagate to the parent (`A`)
- `C` and `D` both read from the root scope, where `db` now lives
- Without `fp()`, `db` would remain inside `B` and be invisible to `C` and `D`

---

### Common Mistakes

| Mistake | Problem | Fix |
| --- | --- | --- |
| Registering shared decorator without `fp()` | Decorator scoped to child only | Wrap plugin with `fp()` |
| Registering consumer plugin before provider | Decorator not yet available | Reorder registrations |
| Using `fp()` on every plugin indiscriminately | Loses encapsulation benefits | Use `fp()` only for genuinely shared services |
| Declaring decorator dependencies without `fp()` | Dependency check may pass in scope but fail elsewhere | Pair dependency declarations with proper scoping |

---

### When to Use `fp()` vs Encapsulation

| Scenario | Recommendation |
| --- | --- |
| Database, config, auth service | `fp()` — shared across all plugins |
| Feature-specific hooks or helpers | Encapsulated — no `fp()` |
| Request/reply decorators used everywhere | Root-level or `fp()` |
| Request/reply decorators for one feature | Inside that feature's plugin only |

---

### Summary

| Concept | Detail |
| --- | --- |
| Default behavior | Plugins are encapsulated — decorators do not leak out |
| Sharing decorators | Wrap provider plugin with `fp()` |
| Load order | Provider must be registered before consumer |
| `fp()` options | `name`, `fastify`, `dependencies` for metadata and plugin-level deps |
| Root-level registration | Alternative to `fp()` for simple cases |
| Request/reply decorators | Follow the same scoping rules as `decorate` |