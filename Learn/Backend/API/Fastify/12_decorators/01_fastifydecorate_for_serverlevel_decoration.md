## fastify.decorate for Server-Level Decoration

### Overview

`fastify.decorate()` is the mechanism for adding custom properties and methods to the Fastify server instance itself. It is the correct way to attach shared utilities, configuration values, database connections, service clients, or helper functions that need to be accessible across the application via the `fastify` instance — rather than attaching them directly to the instance object outside of Fastify's awareness.

Fastify enforces decoration through this API rather than allowing arbitrary property assignment because it enables encapsulation tracking, duplicate detection, and dependency declaration between plugins.

---

### Basic Syntax

```js
fastify.decorate(name, value, dependencies?)
```

| Parameter | Type | Description |
|---|---|---|
| `name` | `string` | The property name to add to the instance |
| `value` | `any` | The value — a function, object, primitive, or `null` placeholder |
| `dependencies` | `string[]` | Optional. Names of decorations that must exist before this one |

After decoration, the value is accessible as `fastify[name]` anywhere the instance is in scope.

---

### Decorating with a Value

```js
fastify.decorate('config', {
  appName: 'MyService',
  version: '1.0.0',
  environment: process.env.NODE_ENV || 'development'
})

fastify.get('/info', async (request, reply) => {
  return {
    app: fastify.config.appName,
    env: fastify.config.environment
  }
})
```

---

### Decorating with a Function

```js
fastify.decorate('formatError', (message, code) => ({
  error: { message, code }
}))

fastify.get('/example', async (request, reply) => {
  if (!request.params.id) {
    return fastify.formatError('Missing ID', 'MISSING_PARAM')
  }
  return { ok: true }
})
```

**Key Points:**
- Functions decorated onto the instance are called as `fastify.methodName()`
- Inside hook and handler functions, `fastify` is accessible via closure when defined in the same scope, or via the `instance` argument in plugin callbacks

---

### Decorating with a Database Connection

A very common use case is attaching a database client so it is accessible throughout the application.

```js
import Fastify from 'fastify'
import { MongoClient } from 'mongodb'
import fp from 'fastify-plugin'

async function dbPlugin(fastify, options) {
  const client = new MongoClient(options.uri)
  await client.connect()

  fastify.decorate('db', client.db(options.dbName))

  fastify.addHook('onClose', async () => {
    await client.close()
  })
}

export default fp(dbPlugin)
```

```js
// Registration
await fastify.register(dbPlugin, {
  uri: 'mongodb://localhost:27017',
  dbName: 'myapp'
})

// Usage in a route
fastify.get('/users', async (request, reply) => {
  const users = await fastify.db.collection('users').find().toArray()
  return users
})
```

**Key Points:**
- Wrapping the plugin with `fp` (fastify-plugin) ensures `fastify.db` escapes the plugin's encapsulation scope and is visible to all sibling and parent scopes
- The `onClose` hook ensures the connection is cleaned up when `fastify.close()` is called
- Without `fp`, `fastify.db` would only be accessible inside `dbPlugin` and its children

---

### Duplicate Decoration Detection

Fastify throws if you attempt to decorate the same name twice on the same instance. This is intentional — it prevents accidental overwrites that would otherwise be silent bugs.

```js
fastify.decorate('util', { helper: () => {} })
fastify.decorate('util', { otherHelper: () => {} }) // throws FST_ERR_DEC_ALREADY_PRESENT
```

**Output:**
```
FastifyError: FST_ERR_DEC_ALREADY_PRESENT: The decorator 'util' has already been added
```

**Key Points:**
- This error fires at registration time, not at request time — it surfaces early
- To check whether a decoration already exists before registering: `fastify.hasDecorator('util')`

```js
if (!fastify.hasDecorator('util')) {
  fastify.decorate('util', { helper: () => {} })
}
```

---

### Declaring Dependencies Between Decorations

The optional third argument accepts an array of decorator names that must already exist on the instance before this decoration is applied. Fastify validates this at registration time.

```js
fastify.decorate('db', dbClient)

fastify.decorate('userRepository', {
  findById: (id) => fastify.db.collection('users').findOne({ _id: id })
}, ['db']) // declares dependency on 'db'
```

If `db` is not yet decorated when `userRepository` is registered, Fastify throws:

```
FastifyError: FST_ERR_DEC_MISSING_DEPENDENCY: The decorator 'userRepository'
has a missing dependency: 'db'
```

**Key Points:**
- Dependency declarations make plugin load order requirements explicit and self-documenting
- This prevents subtle bugs where a decoration is used before its dependency has been registered

---

### Encapsulation Behavior

`fastify.decorate()` follows the same encapsulation rules as hooks and plugins. A decoration added inside a `register` callback is visible to that scope and its children, but not to sibling scopes or parent scopes — unless `fastify-plugin` is used.

```js
fastify.register(async function scopeA(instance) {
  instance.decorate('scopedUtil', () => 'only in A')

  instance.get('/a', async () => ({
    util: instance.scopedUtil() // works
  }))
})

fastify.register(async function scopeB(instance) {
  instance.get('/b', async () => ({
    util: instance.scopedUtil() // throws — scopedUtil not defined in scopeB
  }))
})
```

To make a decoration available globally, either register it on the root `fastify` instance directly, or wrap the decorating plugin with `fastify-plugin`.

---

### Null Placeholder Pattern

When a plugin needs to reserve a decoration name but populate it asynchronously or lazily, `null` can be used as a placeholder value. This registers the name immediately, satisfying any `dependencies` declarations in other plugins, while the actual value is assigned later.

```js
fastify.decorate('cache', null)

// Later, after async setup
fastify.cache = await buildCacheClient()
```

**Key Points:**
- This pattern is valid but uncommon; [Inference] in most cases, performing async setup inside a plugin registered with `fastify.register()` and using `await` within the async plugin callback is the cleaner approach, as Fastify waits for plugin promises to resolve before continuing
- Direct property assignment after the initial `decorate()` call bypasses Fastify's tracking for that update

---

### Accessing the Instance in Plugins and Hooks

Inside a plugin callback, the first argument is the scoped Fastify instance. This is the correct reference to use for calling decorations within that scope.

```js
async function myPlugin(fastify, options) {
  fastify.decorate('greet', (name) => `Hello, ${name}`)

  fastify.get('/greet/:name', async (request) => {
    return { message: fastify.greet(request.params.name) }
  })
}
```

Inside hook handlers and route handlers defined outside a plugin, the root `fastify` instance is accessible via closure.

```js
fastify.decorate('logger', customLogger)

fastify.addHook('onRequest', async (request) => {
  fastify.logger.info(request.url) // closure over root fastify
})
```

---

### decorate vs. Direct Property Assignment

Fastify does not prevent direct property assignment on the instance (`fastify.myProp = value`), but doing so bypasses Fastify's decoration tracking, duplicate detection, and dependency resolution.

| Aspect | `fastify.decorate()` | Direct assignment |
|---|---|---|
| Duplicate detection | Yes — throws on conflict | No — silent overwrite |
| Dependency declaration | Supported | Not supported |
| Encapsulation tracking | Participates | Does not participate |
| Recommended | Yes | No |

**Key Points:**
- [Inference] Direct assignment may work in simple cases but is likely to cause subtle issues in plugin-heavy or encapsulated architectures; `decorate()` is the safe and supported path

---

### Related Decoration APIs

`fastify.decorate()` is one of three decoration methods. Each targets a different object.

| Method | Decorates | Accessible on |
|---|---|---|
| `fastify.decorate()` | The Fastify server instance | `fastify.name` |
| `fastify.decorateRequest()` | Per-request `request` object | `request.name` in hooks and handlers |
| `fastify.decorateReply()` | Per-reply `reply` object | `reply.name` in hooks and handlers |

`decorateRequest` and `decorateReply` are covered in their own topics. The choice between them depends on whether the data or utility belongs to the server, the request, or the reply.

---

### Full Example — Plugin with Decoration and Cleanup

```js
import Fastify from 'fastify'
import fp from 'fastify-plugin'

async function redisPlugin(fastify, options) {
  const client = createRedisClient(options)
  await client.connect()

  fastify.decorate('redis', client)

  fastify.addHook('onClose', async () => {
    await client.disconnect()
  })
}

const fastify = Fastify({ logger: true })

await fastify.register(fp(redisPlugin), { host: 'localhost', port: 6379 })

fastify.get('/cache/:key', async (request) => {
  const value = await fastify.redis.get(request.params.key)
  return { key: request.params.key, value }
})

await fastify.listen({ port: 3000 })
```

---

**Conclusion:** `fastify.decorate()` is the correct and supported way to extend the Fastify server instance with shared state, utilities, and service clients. It participates in Fastify's encapsulation model, provides duplicate detection, and supports explicit dependency declarations between plugins. For anything that needs to live on the server instance and be accessible across the application — database connections, configuration objects, shared helpers — `decorate()` is the appropriate mechanism.