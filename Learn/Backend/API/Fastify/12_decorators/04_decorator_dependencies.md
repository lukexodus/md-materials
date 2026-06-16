## Fastify — Decorator Dependencies

### Overview

Fastify allows decorators to declare explicit dependencies on other decorators. This mechanism applies to all three decorator types: `fastify.decorate`, `fastify.decorateRequest`, and `fastify.decorateReply`. When a dependency is declared, Fastify verifies at registration time that the required decorator already exists — throwing an error at startup if it does not.

---

### Why Dependencies Matter

Decorators are often built on top of one another. A decorator that computes a value may require another decorator to already be present on the same object. Without a dependency declaration, registration order is implicit and fragile — a plugin loaded in a different order could silently break behavior at runtime.

Declaring dependencies makes the requirement explicit and moves the failure from runtime to startup.

---

### Syntax

The third argument to any decorator registration call accepts an array of decorator name strings.

js

```
fastify.decorate(name, value, dependencies)
fastify.decorateRequest(name, defaultValue, dependencies)
fastify.decorateReply(name, defaultValue, dependencies)
```

| Argument | Type | Description |
| --- | --- | --- |
| `dependencies` | `string[]` | Names of decorators that must be registered before this one |

---

### Basic Example — `decorate`

js

```
import Fastify from 'fastify'

const fastify = Fastify()

fastify.decorate('db', { query: async (sql) => [] })

// 'dbCache' depends on 'db' being present
fastify.decorate('dbCache', new Map(), ['db'])

fastify.get('/data', async (request, reply) => {
  const cached = fastify.dbCache.get('key')
  if (cached) return cached

  const result = await fastify.db.query('SELECT * FROM items')
  fastify.dbCache.set('key', result)
  return result
})

await fastify.listen({ port: 3000 })
```

**Key Points:**

- `'db'` is registered first with no dependencies
- `'dbCache'` declares `['db']` — Fastify checks that `'db'` exists before registering `'dbCache'`
- If `'db'` were missing, Fastify would throw at startup

---

### Basic Example — `decorateRequest`

js

```
fastify.decorateRequest('user', null)

// 'permissions' depends on 'user' being present on request
fastify.decorateRequest('permissions', null, ['user'])

fastify.addHook('preHandler', async (request) => {
  request.user = { id: 1, role: 'admin' }
  request.permissions = request.user.role === 'admin'
    ? ['read', 'write', 'delete']
    : ['read']
})

fastify.get('/permissions', async (request) => {
  return { permissions: request.permissions }
})
```

**Output** (GET `/permissions`):

json

```
{
  "permissions": ["read", "write", "delete"]
}
```

---

### Basic Example — `decorateReply`

js

```
fastify.decorateReply('requestStartTime', null)

// 'elapsedMs' depends on 'requestStartTime'
fastify.decorateReply('elapsedMs', null, ['requestStartTime'])

fastify.addHook('onRequest', async (request, reply) => {
  reply.requestStartTime = Date.now()
})

fastify.addHook('onSend', async (request, reply) => {
  reply.elapsedMs = Date.now() - reply.requestStartTime
})

fastify.get('/timing', async (request, reply) => {
  return { message: 'done' }
})
```

---

### What Fastify Checks

When a decorator with dependencies is registered, Fastify performs the following check:

```
For each name in dependencies[]:
  Is there an existing decorator with that name on the same target?
  → Yes: continue
  → No: throw FastifyError at startup
```

> **Key Point:** This check happens at **registration time**, not at request time. A missing dependency surfaces immediately when the server starts — not during a live request.

---

### Failure Behavior

If a dependency is not satisfied, Fastify throws with a message indicating which decorator is missing.

js

```
// 'db' is NOT registered
fastify.decorate('dbCache', new Map(), ['db'])
// ✗ Throws: FST_ERR_DEC_MISSING_DEPENDENCY or similar
```

**Key Points:**

- The error is thrown synchronously during plugin/decorator registration
- The server will not start successfully
- The error message identifies the missing dependency by name

> [Inference] The exact error code and message format may differ across Fastify versions. Consult the changelog for your version if error handling depends on specific codes.

---

### Cross-Plugin Dependencies

Dependencies work across plugin boundaries, provided the dependent decorator is registered after the dependency — i.e., the plugin providing the dependency is loaded first.

js

```
// Plugin A — provides 'db'
fastify.register(async (instance) => {
  instance.decorate('db', { query: async () => [] })
})

// Plugin B — depends on 'db'
// ⚠️ This may fail depending on load order and scope
fastify.register(async (instance) => {
  instance.decorate('dbCache', new Map(), ['db'])
})
```

> [Inference] Cross-plugin dependency resolution depends on plugin registration order and Fastify's encapsulation boundaries. A decorator registered inside a child plugin scope may not be visible to a sibling plugin. Using `fastify-plugin` to escape encapsulation is the common approach when sharing decorators across plugins. Behavior may vary.

---

### Using `fastify-plugin` for Shared Dependencies

When a decorator must be available across plugin scopes, wrap the registering plugin with `fastify-plugin`. This causes the decorator to be registered on the parent scope rather than the encapsulated child scope.

js

```
import fp from 'fastify-plugin'

const dbPlugin = fp(async (fastify) => {
  fastify.decorate('db', { query: async () => [] })
})

const cachePlugin = fp(async (fastify) => {
  fastify.decorate('dbCache', new Map(), ['db'])
})

fastify.register(dbPlugin)
fastify.register(cachePlugin) // 'db' is visible here because dbPlugin used fp()
```

**Key Points:**

- Without `fp()`, a decorator registered inside a plugin is scoped to that plugin only
- With `fp()`, it propagates to the parent scope and becomes visible to sibling plugins
- The dependency check in `cachePlugin` will pass only if `dbPlugin` is registered first

---

### Dependency Declaration is Not Enforced at Runtime

Declaring a dependency only causes Fastify to check whether the named decorator **exists** at registration time. It does not:

- Enforce that the dependency holds a particular value or type
- Re-check the dependency on every request
- Guarantee logical correctness of how decorators interact

> **Disclaimer:** Dependency declarations are a registration-time existence check only. Logical correctness of how one decorator uses another is the developer's responsibility. Behavior is not guaranteed beyond the existence check.

---

### Chaining Multiple Dependencies

A decorator can declare multiple dependencies at once.

js

```
fastify.decorate('db', { query: async () => [] })
fastify.decorate('logger', { info: console.log })

fastify.decorate('repository', null, ['db', 'logger'])
```

All listed names must be registered before `'repository'` is declared, or Fastify throws at startup.

---

### Summary

| Feature | Detail |
| --- | --- |
| Applies to | `decorate`, `decorateRequest`, `decorateReply` |
| Declared via | Third argument — `string[]` of decorator names |
| Check timing | Registration time (startup), not request time |
| Failure mode | Throws a startup error if dependency is missing |
| Cross-plugin visibility | Requires `fastify-plugin` to escape encapsulation |
| Runtime enforcement | Not enforced — existence check only |