### Registering Plugins with `fastify.register`

`fastify.register()` is the single mechanism for adding plugins, routes, hooks, and decorators within an encapsulated scope. Understanding its signature, options, and async behavior is necessary for structuring any Fastify application correctly.

---

#### Method Signature

js

```
fastify.register(plugin, options)
```

| Parameter | Type | Description |
| --- | --- | --- |
| `plugin` | `Function` | A function with signature `(instance, opts, done)` or `async (instance, opts)` |
| `options` | `Object` | *(Optional)* Passed as the second argument to the plugin function |

---

#### Plugin Function Signatures

Fastify accepts both callback-style and async plugin functions.

**Callback style:**

js

```
function myPlugin(fastify, options, done) {
  fastify.get('/hello', async () => ({ hello: 'world' }))
  done()
}
```

**Async style:**

js

```
async function myPlugin(fastify, options) {
  fastify.get('/hello', async () => ({ hello: 'world' }))
}
```

**Key Points:**

- In callback style, `done()` must be called to signal completion. Forgetting it will cause the server to hang during initialization.
- In async style, the returned promise signals completion — `done` is not used.
- Mixing async functions with explicit `done()` calls can produce unexpected behavior and should be avoided.

---

#### Basic Registration

js

```
const fastify = require('fastify')()

async function greetPlugin(fastify, options) {
  fastify.get('/greet', async () => {
    return { message: `Hello, ${options.name}` }
  })
}

fastify.register(greetPlugin, { name: 'World' })
```

**Output:** `GET /greet` returns `{ "message": "Hello, World" }`

---

#### Built-in Registration Options

Fastify recognizes certain keys in the options object and handles them internally.

##### `prefix`

Prepends a URL prefix to all routes registered inside the plugin.

js

```
fastify.register(async function(fastify) {
  fastify.get('/users', handler)      // → /api/users
  fastify.get('/users/:id', handler)  // → /api/users/:id
}, { prefix: '/api' })
```

**Key Points:**

- The prefix applies only to routes inside that plugin scope.
- Nested `register` calls inside a prefixed plugin inherit and extend the prefix.

js

```
fastify.register(async function(fastify) {
  fastify.register(async function(fastify) {
    fastify.get('/list', handler)  // → /v1/items/list
  }, { prefix: '/items' })
}, { prefix: '/v1' })
```

##### `logLevel`

Sets the log level for all routes in the plugin scope.

js

```
fastify.register(myPlugin, { logLevel: 'warn' })
```

##### `logSerializers`

Provides custom log serializers scoped to the plugin.

js

```
fastify.register(myPlugin, {
  logSerializers: {
    res: (res) => ({ statusCode: res.statusCode })
  }
})
```

---

#### Passing Options to Plugins

Options are plain objects passed as the second argument and received as the `opts` parameter in the plugin function.

js

```
async function dbPlugin(fastify, options) {
  const client = createClient({
    host: options.host,
    port: options.port
  })
  fastify.decorate('db', client)
}

fastify.register(dbPlugin, { host: 'localhost', port: 5432 })
```

[Inference] Options are passed by reference for objects. Mutations to the options object inside the plugin may affect the original — behavior may vary depending on how options are processed internally.

---

#### Registration Is Asynchronous and Deferred

`fastify.register()` does **not** execute the plugin immediately. It queues the plugin for execution during the boot sequence managed by `avvio`.

js

```
fastify.register(async function(fastify) {
  fastify.decorate('db', {})
})

// This will throw — 'db' is not yet decorated at this point
console.log(fastify.db)  // undefined or error
```

Plugin contents are only available after `fastify.ready()` resolves.

js

```
await fastify.ready()
console.log(fastify.db)  // now accessible (if fp-wrapped)
```

---

#### Nested Registration

Plugins can call `fastify.register()` internally, creating a child scope.

js

```
async function parentPlugin(fastify, options) {
  fastify.decorate('shared', true)

  fastify.register(async function childPlugin(fastify) {
    // inherits 'shared' from parent
    fastify.get('/child', async () => ({ shared: fastify.shared }))
  })
}

fastify.register(parentPlugin)
```

RootparentPlugindecorates: sharedchildPlugininherits: shared

---

#### Registering External Modules

Third-party Fastify plugins follow the same registration pattern.

js

```
const fastifyCors = require('@fastify/cors')
const fastifyJwt = require('@fastify/jwt')

fastify.register(fastifyCors, {
  origin: '*'
})

fastify.register(fastifyJwt, {
  secret: process.env.JWT_SECRET
})
```

**Key Points:**

- Most official `@fastify/*` plugins are wrapped with `fastify-plugin` internally, so their decorators are available on the root instance after registration.
- Plugin registration order matters — a plugin that depends on a decorator must be registered after the plugin that provides it.

---

#### Registration Order and Dependencies

Because registration is deferred, ordering is critical for plugins with dependencies.

js

```
// Correct — db registered before routes that use it
fastify.register(require('./plugins/db'))
fastify.register(require('./routes/users'))  // can safely use fastify.db
```

js

```
// Incorrect — routes registered before db is available
fastify.register(require('./routes/users'))  // fastify.db may not exist yet
fastify.register(require('./plugins/db'))
```

[Inference] When using `fastify-plugin`-wrapped plugins, the decorator is merged into the parent scope and should be available to sibling plugins registered after it. This relies on correct async sequencing — behavior may vary if plugin functions are not properly awaited or `done` is misused.

---

#### Registering Inline Arrow Functions

While valid, inline registration of complex logic reduces reusability and testability.

js

```
// Acceptable for small, isolated cases
fastify.register(async (fastify) => {
  fastify.get('/ping', async () => 'pong')
})
```

**Key Points:**

- Inline plugins cannot be easily unit tested in isolation.
- Named functions improve stack traces and debugging.

---

#### `register` vs Direct Declaration

| Approach | Encapsulated | Use Case |
| --- | --- | --- |
| `fastify.register(fn)` | Yes | Routes, scoped hooks, isolated features |
| `fastify.decorate()` directly on root | No | Global utilities (before `ready()`) |
| `fastify-plugin`-wrapped register | No (merged) | Shared infrastructure |

---

#### Common Mistakes

**Forgetting `done()` in callback-style plugins:**

js

```
// Hangs — done never called
function brokenPlugin(fastify, options, done) {
  fastify.get('/x', handler)
  // done() missing
}
```

**Accessing registered decorators before `ready()`:**

js

```
fastify.register(fp(dbPlugin))
fastify.db.query(...)  // Error — not yet initialized
```

**Mixing async and done:**

js

```
// Avoid — undefined behavior
async function badPlugin(fastify, options, done) {
  await someSetup()
  done()  // should not be used with async plugins
}
```

---

#### Summary

**Conclusion:**
`fastify.register()` is the entry point for all plugin-based composition in Fastify. Its deferred, async-safe execution model, combined with scope encapsulation, allows applications to be structured as trees of isolated, composable units. Key behaviors — prefixing, option passing, load order, and scope inheritance — are all controlled through this single method.