## Flat Plugin Architecture

Flat plugin architecture is an organizational pattern for Fastify applications where all plugins are registered at the same encapsulation scope — directly on the root Fastify instance — rather than nested inside one another. It trades deep plugin hierarchies for a linear, predictable registration sequence where every plugin has access to everything registered before it.

---

### What "Flat" Means in Fastify

Fastify's plugin system is hierarchical by default. Plugins registered inside other plugins are encapsulated — they inherit from their parent scope but do not expose their decorators or hooks upward or to sibling plugins.

A **nested** architecture looks like:

```js
fastify.register(async function parentPlugin (fastify) {
  fastify.decorate('db', dbConnection)

  fastify.register(async function childPlugin (fastify) {
    // Can access fastify.db — inherited from parent
    fastify.get('/users', async () => fastify.db.query('SELECT * FROM users'))
  })
})
```

A **flat** architecture avoids nesting entirely:

```js
// All registered at root level, sequentially
fastify.register(dbPlugin)           // adds fastify.db
fastify.register(authPlugin)         // can use fastify.db
fastify.register(userRoutes)         // can use fastify.db and fastify.auth
```

Each plugin at the root level uses `fastify-plugin` (`fp`) to break encapsulation, making its decorators and hooks available to all subsequently registered plugins at the same level.

---

### The Role of `fastify-plugin` in Flat Architecture

Without `fp`, each registered plugin creates a new encapsulation scope. Its decorators are invisible to siblings:

```js
// ❌ Without fp — encapsulation is preserved
fastify.register(async function (fastify) {
  fastify.decorate('db', connection)
})

fastify.register(async function (fastify) {
  console.log(fastify.db) // undefined — sibling cannot see db
})
```

With `fp`, the plugin's additions are applied to the parent (root) scope:

```js
const fp = require('fastify-plugin')

// ✅ With fp — decorator is hoisted to root scope
fastify.register(fp(async function (fastify) {
  fastify.decorate('db', connection)
}))

fastify.register(async function (fastify) {
  console.log(fastify.db) // available — hoisted to root
})
```

In flat architecture, **infrastructure plugins use `fp`** and **route plugins do not**.

---

### Structure of a Flat Plugin Application

```
app.js
plugins/
├── env.js          ← fp-wrapped: config decorator
├── db.js           ← fp-wrapped: database decorator
├── redis.js        ← fp-wrapped: cache decorator
├── auth.js         ← fp-wrapped: authentication hooks/decorators
└── sensible.js     ← fp-wrapped: HTTP error helpers
routes/
├── health.js       ← no fp: GET /health
├── users.js        ← no fp: GET /users, POST /users
└── admin.js        ← no fp: admin routes
```

```js
// app.js
const path = require('path')
const fp = require('fastify-plugin')
const AutoLoad = require('@fastify/autoload')

module.exports = fp(async function app (fastify, opts) {
  // Infrastructure — registered at root, fp-wrapped internally
  fastify.register(require('./plugins/env'))
  fastify.register(require('./plugins/db'))
  fastify.register(require('./plugins/redis'))
  fastify.register(require('./plugins/auth'))
  fastify.register(require('./plugins/sensible'))

  // Routes — registered at root, no fp, scoped encapsulation
  fastify.register(require('./routes/health'))
  fastify.register(require('./routes/users'))
  fastify.register(require('./routes/admin'))
})
```

All plugins and routes are siblings at the same level. No plugin nests inside another.

---

### Registration Sequence and Dependency Availability

Fastify processes plugin registrations asynchronously but **in order**. A plugin registered after another can access its decorators only if the earlier plugin used `fp`.

```js
fastify.register(dbPlugin)    // fp-wrapped: adds fastify.db
fastify.register(authPlugin)  // fp-wrapped: can use fastify.db ✅
fastify.register(userRoutes)  // no fp: can use fastify.db and fastify.auth ✅
```

Reversing order breaks the dependency:

```js
fastify.register(userRoutes)  // tries to use fastify.db — not yet registered ❌
fastify.register(dbPlugin)
```

> [Inference] Fastify's plugin system is queue-based — plugins are loaded in registration order. A decorator referenced before its provider plugin has run will be `undefined` at the time of access. Behavior may vary depending on whether the access occurs at registration time or inside a hook/handler.

**Key Points:**
- Registration order is the dependency graph in flat architecture.
- There is no automatic dependency resolution — order is the developer's responsibility.
- `fastify print-plugins` reveals the actual load sequence.

---

### Infrastructure Plugin Pattern

Each infrastructure plugin follows the same structure: async function, `fp`-wrapped, adds exactly one concern to the instance.

```js
// plugins/db.js
'use strict'

const fp = require('fastify-plugin')
const { Pool } = require('pg')

async function dbPlugin (fastify, opts) {
  const pool = new Pool({
    connectionString: fastify.config.DATABASE_URL
  })

  // Verify connection at startup
  await pool.query('SELECT 1')

  fastify.decorate('db', pool)

  fastify.addHook('onClose', async () => {
    await pool.end()
  })
}

module.exports = fp(dbPlugin, {
  name: 'db-plugin',
  dependencies: ['env-plugin']   // fastify-plugin dependency declaration
})
```

**Key Points:**
- `dependencies` in `fp` metadata causes Fastify to throw if a named plugin has not been registered before this one — a declarative guard against misordered registration.
- `onClose` hooks release the resource when `fastify.close()` is called — critical for scripts, tests, and graceful shutdown.
- Each plugin does one thing and decorates the instance with one named property.

---

### Plugin Dependency Declarations

`fastify-plugin` supports a `dependencies` array in its metadata object. Each entry is the `name` of another `fp`-wrapped plugin that must already be registered:

```js
module.exports = fp(authPlugin, {
  name: 'auth-plugin',
  dependencies: ['env-plugin', 'db-plugin']
})
```

If `db-plugin` has not been registered before `auth-plugin` loads, Fastify throws:

```
Error: The dependency 'db-plugin' of plugin 'auth-plugin' is not registered
```

This converts a runtime undefined-decorator bug into an explicit startup error.

> [Inference] Dependency declarations do not alter registration order — they only validate it. The developer must still register plugins in the correct sequence. These checks occur at plugin initialization time and may not fire until `fastify.ready()` is awaited.

---

### Route Plugin Pattern

Route plugins do not use `fp`. This preserves encapsulation — hooks added inside a route plugin do not leak to siblings:

```js
// routes/users.js
'use strict'

async function userRoutes (fastify, opts) {
  // fastify.db, fastify.config, fastify.auth are available
  // because they were registered at root with fp

  // This preHandler only applies to routes in this file
  fastify.addHook('preHandler', fastify.auth.requireLogin)

  fastify.get('/users', async (req, reply) => {
    const users = await fastify.db.query('SELECT * FROM users')
    return users.rows
  })

  fastify.post('/users', async (req, reply) => {
    const { name, email } = req.body
    await fastify.db.query(
      'INSERT INTO users (name, email) VALUES ($1, $2)',
      [name, email]
    )
    return reply.code(201).send({ created: true })
  })
}

module.exports = userRoutes
```

The `preHandler` hook registered here applies only to `/users` routes, not to `/health` or `/admin` — because `userRoutes` is not wrapped with `fp`.

---

### Flat Architecture vs. Nested Architecture

```
Nested:                          Flat:
                                 
fastify (root)                   fastify (root)
└── appPlugin (fp)               ├── envPlugin (fp)
    ├── envPlugin (fp)           ├── dbPlugin (fp)
    ├── dbPlugin (fp)            ├── authPlugin (fp)
    │   └── authPlugin (fp)      ├── healthRoutes
    └── routes                   ├── userRoutes
        ├── healthRoutes         └── adminRoutes
        ├── userRoutes
        └── adminRoutes
```

| Characteristic | Nested | Flat |
|---|---|---|
| Dependency visibility | Controlled by parent scope | Controlled by registration order |
| Encapsulation | Hierarchical | Explicit (fp vs. no fp) |
| Load order reasoning | Tree traversal | Linear sequence |
| Plugin isolation | Natural | Manual (no-fp route plugins) |
| Debugging | Harder (deep trees) | Easier (linear sequence) |
| Scalability | Better for very large apps | Better for small–medium apps |

---

### Using `@fastify/autoload` in Flat Architecture

Autoload works naturally with flat architecture. Two separate autoload calls load infrastructure then routes:

```js
const AutoLoad = require('@fastify/autoload')
const path = require('path')

module.exports = async function app (fastify, opts) {
  // Plugins first — all fp-wrapped, loaded alphabetically
  await fastify.register(AutoLoad, {
    dir: path.join(__dirname, 'plugins'),
    options: opts
  })

  // Routes second — none fp-wrapped
  fastify.register(AutoLoad, {
    dir: path.join(__dirname, 'routes'),
    options: opts
  })
}
```

> **Note:** The first `register` call uses `await` to ensure all plugins are fully initialized before routes are registered. Without `await`, Fastify's async queue still handles order correctly in most cases — but explicit `await` makes the intent unambiguous.

> [Inference] Whether `await` on `fastify.register` is meaningful depends on internal Fastify queue mechanics. In practice the queue handles ordering, but `await` improves readability and intent clarity. Behavior may vary across Fastify versions.

---

### Controlling Load Order with Filename Prefixes

When using autoload, alphabetical load order determines dependency availability. Use numeric prefixes to enforce explicit ordering:

```
plugins/
├── 00-env.js        ← loads first: config available to all
├── 01-db.js         ← loads second: needs fastify.config
├── 02-redis.js      ← loads third: needs fastify.config
├── 03-auth.js       ← loads fourth: needs fastify.db
└── 04-sensible.js   ← loads fifth: no dependencies
```

Without numeric prefixes, `auth.js` would load before `db.js` alphabetically, causing `fastify.db` to be undefined when `auth.js` initializes.

---

### Practical Example: Full Flat Application

```js
// plugins/00-env.js
const fp = require('fastify-plugin')
const fastifyEnv = require('@fastify/env')

const schema = {
  type: 'object',
  required: ['DATABASE_URL'],
  properties: {
    DATABASE_URL: { type: 'string' },
    NODE_ENV: { type: 'string', default: 'development' },
    PORT: { type: 'integer', default: 3000 }
  }
}

module.exports = fp(async function envPlugin (fastify) {
  await fastify.register(fastifyEnv, { schema, dotenv: true })
}, { name: 'env-plugin' })
```

```js
// plugins/01-db.js
const fp = require('fastify-plugin')
const { Pool } = require('pg')

module.exports = fp(async function dbPlugin (fastify) {
  const pool = new Pool({ connectionString: fastify.config.DATABASE_URL })
  await pool.query('SELECT 1')
  fastify.decorate('db', pool)
  fastify.addHook('onClose', async () => pool.end())
}, { name: 'db-plugin', dependencies: ['env-plugin'] })
```

```js
// plugins/02-auth.js
const fp = require('fastify-plugin')
const fastifyJwt = require('@fastify/jwt')

module.exports = fp(async function authPlugin (fastify) {
  fastify.register(fastifyJwt, { secret: fastify.config.JWT_SECRET })

  fastify.decorate('authenticate', async function (req, reply) {
    try {
      await req.jwtVerify()
    } catch (err) {
      reply.send(err)
    }
  })
}, { name: 'auth-plugin', dependencies: ['env-plugin'] })
```

```js
// routes/users.js
module.exports = async function userRoutes (fastify, opts) {
  fastify.get('/users', {
    preHandler: [fastify.authenticate]
  }, async (req, reply) => {
    const result = await fastify.db.query('SELECT id, name FROM users')
    return result.rows
  })
}
```

---

### When Flat Architecture Is Appropriate

Flat architecture suits applications where:

- The plugin graph is a simple dependency chain (env → db → auth → routes)
- The team benefits from a linear, easy-to-read registration sequence
- Plugins do not need to be conditionally composed or swapped at runtime
- The application is small to medium in scale

It becomes harder to maintain when:

- Multiple groups of routes need different subsets of plugins
- Conditional plugin registration based on environment or feature flags is needed
- The application is large enough that a single flat list of registrations becomes long and hard to reason about

In those cases, selective use of nesting — grouping related routes and their scoped plugins under a shared parent — is more appropriate than enforcing flatness throughout.

---

**Related Topics:**
- `fastify-plugin` (`fp`) encapsulation mechanics and `dependencies` metadata
- Fastify plugin lifecycle and `fastify.ready()`
- `@fastify/autoload` load ordering and filename prefix conventions
- Nested plugin architecture and scope isolation patterns
- Decorator patterns (`fastify.decorate`, `decorateRequest`, `decorateReply`)
- `fastify print-plugins` for visualizing registration order
- Plugin timeout debugging and dependency error messages