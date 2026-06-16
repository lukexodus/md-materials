### Plugin Architecture and Encapsulation Model

Fastify's plugin system is one of its most distinctive design choices. Rather than a flat middleware chain, Fastify organizes application logic into a tree of isolated scopes — each plugin living in its own encapsulated context.

---

#### What a Plugin Is

In Fastify, a plugin is a function with a specific signature:

js

```
async function myPlugin(fastify, options) {
  // register routes, hooks, decorators here
}
```

It receives the Fastify instance and an options object. Plugins are registered via `fastify.register()`.

js

```
fastify.register(myPlugin, { prefix: '/api' })
```

---

#### The Encapsulation Model

Fastify uses a **scope tree** — not a flat chain. Each call to `fastify.register()` creates a **child scope** that inherits from its parent but is isolated from its siblings.

Root InstancePlugin A (child scope)Plugin B (child scope)Plugin A1 (grandchild)

**Key Points:**

- A child scope **inherits** decorators, hooks, and plugins from its parent at registration time.
- Changes made inside a child scope — new decorators, hooks, routes — do **not** propagate upward to the parent or sideways to siblings.
- This isolation is enforced by Fastify's internal use of `avvio`, its plugin boot library.

---

#### Inheritance Direction

Root(decorates: db, auth)Plugin Ainherits: db, authadds: cachePlugin Binherits: db, authno access to: cache

[Inference] Inheritance flows strictly downward. Sibling plugins do not share state unless it was defined at a common ancestor. This behavior is documented but actual runtime behavior may vary based on registration order and async timing.

---

#### Practical Encapsulation Example

js

```
const fastify = require('fastify')()

// Root-level decorator — available everywhere
fastify.decorate('db', { query: () => {} })

fastify.register(async function pluginA(instance) {
  // instance inherits 'db'
  instance.decorate('cache', {})  // only available inside pluginA and its children

  instance.get('/a', async (req, reply) => {
    instance.cache  // accessible
    instance.db     // accessible
  })
})

fastify.register(async function pluginB(instance) {
  instance.db     // accessible — inherited from root
  instance.cache  // undefined — not visible here
})
```

**Output:** Routes in Plugin B cannot access `cache` because it was declared inside Plugin A's scope.

---

#### `fastify-plugin` — Opting Out of Encapsulation

Sometimes you want a plugin to expose its decorators or hooks to the parent scope — for example, a database connector that should be available application-wide.

Wrapping a plugin with `fastify-plugin` breaks encapsulation for that plugin:

js

```
const fp = require('fastify-plugin')

async function dbConnector(fastify, options) {
  fastify.decorate('db', createConnection(options))
}

module.exports = fp(dbConnector)
```

When registered, `db` will be available in the parent scope and all sibling plugins registered after it.

Root InstancedbConnector(fp-wrapped)decorates: db on ROOTPlugin Acan access: dbPlugin Bcan access: db

**Key Points:**

- `fastify-plugin` skips scope isolation for that specific plugin.
- It is the standard pattern for shared infrastructure plugins (databases, auth, config).
- Plugins that are **not** wrapped with `fastify-plugin` always produce an isolated scope.

---

#### Hook Encapsulation

Hooks follow the same rules as decorators.

js

```
fastify.register(async function scopedPlugin(instance) {
  instance.addHook('onRequest', async (req, reply) => {
    // Only runs for routes registered inside this scope
  })

  instance.get('/protected', handler)
})

fastify.get('/public', handler)
// The onRequest hook above does NOT run for /public
```

This makes it possible to apply authentication hooks only to specific route groups without affecting the rest of the application.

---

#### Plugin Load Order and `avvio`

Fastify's boot sequence is managed by `avvio`, which enforces an **ordered, async-safe** initialization of all plugins before the server begins accepting requests.

**Key Points:**

- Plugins are loaded in registration order.
- Each plugin fully initializes before the next one starts — this prevents race conditions during startup.
- `fastify.ready()` or `fastify.listen()` waits for the entire plugin tree to finish loading.

[Inference] The sequential nature of `avvio` means that a plugin registered later can rely on decorators added by a `fastify-plugin`-wrapped plugin registered earlier. Actual behavior depends on correct async/await usage in plugin functions.

---

#### Scope Tree — Full Mental Model

Root Scopeglobal hooks, decoratorsfp-wrapped plugin(merges into Root)Scoped Plugin 1isolated hooks/decoratorsScoped Plugin 2isolated hooks/decoratorsChild of Scoped Plugin 1inherits from S1 + Root

---

#### Common Patterns

| Pattern | Tool | Effect |
| --- | --- | --- |
| Shared infrastructure | `fastify-plugin` | Merges into parent scope |
| Route grouping | Scoped plugin | Isolated hooks and decorators |
| Prefix namespacing | `register` + `prefix` option | Routes scoped under a URL prefix |
| Per-scope auth | Scoped `onRequest` hook | Auth only on specific route groups |

---

#### Summary

**Conclusion:**
Fastify's encapsulation model gives precise control over what is shared and what is isolated. The default behavior is isolation — decorators, hooks, and routes stay within their scope. `fastify-plugin` is the deliberate escape hatch for application-wide concerns. Understanding this tree-shaped scope model is foundational to structuring any non-trivial Fastify application.