## Feature-Based Modular Structure

Feature-based modular structure organizes a Fastify application by business domain or product feature rather than by technical layer. Instead of grouping all routes together and all plugins together across the entire application, each feature owns its routes, its scoped plugins, its hooks, and its schemas in a self-contained directory. The result is a codebase where adding, modifying, or removing a feature involves touching one directory rather than multiple scattered locations.

---

### Structural Philosophy

**Layer-based structure** (what `fastify generate` produces by default):

```
app/
├── plugins/         ← all infrastructure, all features
├── routes/          ← all routes, all features
├── schemas/         ← all schemas, all features
└── hooks/           ← all hooks, all features
```

**Feature-based structure:**

```
app/
├── plugins/         ← only truly global infrastructure
└── features/
    ├── users/       ← everything about users
    ├── products/    ← everything about products
    ├── orders/      ← everything about orders
    └── admin/       ← everything about admin
```

Each feature directory is a self-contained Fastify plugin that encapsulates its own routes, schemas, hooks, and feature-local services. Global plugins (database, config, auth) remain at the application root and are made available via `fastify-plugin`.

---

### Single Feature Directory Layout

A well-structured feature module:

```
features/users/
├── index.js          ← feature entry plugin, registers everything below
├── routes.js         ← route definitions
├── schemas.js        ← JSON schemas for request/response
├── hooks.js          ← feature-scoped hooks (preHandler, etc.)
├── service.js        ← business logic, isolated from Fastify
└── repository.js     ← data access layer
```

This layout is a convention, not a framework requirement. The files and their names can vary — what matters is that `index.js` is the single entry point that composes the rest.

---

### Feature Entry Plugin (`index.js`)

The entry plugin is a regular Fastify plugin — **not** wrapped with `fastify-plugin`. This preserves encapsulation: hooks and decorators added inside the feature are scoped to it and do not leak to other features.

```js
// features/users/index.js
'use strict'

const hooks = require('./hooks')
const routes = require('./routes')

async function usersFeature (fastify, opts) {
  // Register feature-scoped hooks first
  fastify.register(hooks)

  // Register routes
  fastify.register(routes)
}

module.exports = usersFeature
```

Global decorators (`fastify.db`, `fastify.config`, `fastify.authenticate`) registered at the root with `fp` are available here through scope inheritance.

---

### Routes File

```js
// features/users/routes.js
'use strict'

const {
  getUsersSchema,
  getUserByIdSchema,
  createUserSchema
} = require('./schemas')

const UserService = require('./service')

async function userRoutes (fastify, opts) {
  const service = new UserService(fastify.db)

  fastify.get('/', { schema: getUsersSchema }, async (req, reply) => {
    return service.getAll()
  })

  fastify.get('/:id', { schema: getUserByIdSchema }, async (req, reply) => {
    const user = await service.getById(req.params.id)
    if (!user) throw fastify.httpErrors.notFound('User not found')
    return user
  })

  fastify.post('/', { schema: createUserSchema }, async (req, reply) => {
    const user = await service.create(req.body)
    return reply.code(201).send(user)
  })
}

module.exports = userRoutes
```

---

### Schemas File

Keeping schemas co-located with the feature that owns them prevents schema sprawl and makes it immediately clear which contracts apply to which feature:

```js
// features/users/schemas.js
'use strict'

const userSchema = {
  type: 'object',
  properties: {
    id: { type: 'integer' },
    name: { type: 'string' },
    email: { type: 'string', format: 'email' },
    createdAt: { type: 'string', format: 'date-time' }
  }
}

const getUsersSchema = {
  response: {
    200: {
      type: 'array',
      items: userSchema
    }
  }
}

const getUserByIdSchema = {
  params: {
    type: 'object',
    required: ['id'],
    properties: {
      id: { type: 'integer' }
    }
  },
  response: {
    200: userSchema,
    404: {
      type: 'object',
      properties: {
        message: { type: 'string' }
      }
    }
  }
}

const createUserSchema = {
  body: {
    type: 'object',
    required: ['name', 'email'],
    properties: {
      name: { type: 'string', minLength: 1 },
      email: { type: 'string', format: 'email' }
    }
  },
  response: {
    201: userSchema
  }
}

module.exports = { getUsersSchema, getUserByIdSchema, createUserSchema }
```

---

### Hooks File

Feature-scoped hooks apply only within the feature's encapsulation context:

```js
// features/users/hooks.js
'use strict'

async function userHooks (fastify, opts) {
  // Applies to all routes registered in this feature scope
  fastify.addHook('preHandler', fastify.authenticate)

  fastify.addHook('onSend', async (req, reply, payload) => {
    reply.header('X-Resource', 'users')
    return payload
  })
}

module.exports = userHooks
```

Because `usersFeature` is not wrapped with `fp`, and `userHooks` is registered inside it, these hooks do not apply to any other feature.

---

### Service Layer

The service encapsulates business logic and is independent of Fastify. It receives dependencies (the db pool, config values) through its constructor rather than accessing `fastify` directly. This makes it testable without a Fastify instance:

```js
// features/users/service.js
'use strict'

class UserService {
  constructor (db) {
    this.db = db
  }

  async getAll () {
    const result = await this.db.query(
      'SELECT id, name, email, created_at AS "createdAt" FROM users ORDER BY id'
    )
    return result.rows
  }

  async getById (id) {
    const result = await this.db.query(
      'SELECT id, name, email, created_at AS "createdAt" FROM users WHERE id = $1',
      [id]
    )
    return result.rows[0] ?? null
  }

  async create ({ name, email }) {
    const result = await this.db.query(
      'INSERT INTO users (name, email) VALUES ($1, $2) RETURNING id, name, email, created_at AS "createdAt"',
      [name, email]
    )
    return result.rows[0]
  }
}

module.exports = UserService
```

---

### Repository Layer (Optional)

For applications with complex data access needs, separate the query logic from the service:

```js
// features/users/repository.js
'use strict'

class UserRepository {
  constructor (db) {
    this.db = db
  }

  async findAll () {
    const { rows } = await this.db.query(
      'SELECT id, name, email, created_at AS "createdAt" FROM users'
    )
    return rows
  }

  async findById (id) {
    const { rows } = await this.db.query(
      'SELECT id, name, email, created_at AS "createdAt" FROM users WHERE id = $1',
      [id]
    )
    return rows[0] ?? null
  }

  async insert ({ name, email }) {
    const { rows } = await this.db.query(
      'INSERT INTO users (name, email) VALUES ($1, $2) RETURNING *',
      [name, email]
    )
    return rows[0]
  }
}

module.exports = UserRepository
```

The service then uses the repository:

```js
// features/users/service.js
class UserService {
  constructor (repository) {
    this.repository = repository
  }

  async getById (id) {
    return this.repository.findById(id)
  }
}
```

> [Inference] Whether to use a repository layer depends on the complexity of the data access logic and the need for mocking in tests. For simple CRUD, a service calling the DB directly is sufficient.

---

### Application Root Composition

The root `app.js` registers global infrastructure then each feature under its own prefix:

```js
// app.js
'use strict'

const path = require('path')
const fp = require('fastify-plugin')

// Global infrastructure plugins
const envPlugin = require('./plugins/00-env')
const dbPlugin = require('./plugins/01-db')
const authPlugin = require('./plugins/02-auth')

// Feature plugins
const usersFeature = require('./features/users')
const productsFeature = require('./features/products')
const ordersFeature = require('./features/orders')
const adminFeature = require('./features/admin')

module.exports = fp(async function app (fastify, opts) {
  // Infrastructure — fp-wrapped, available to all features
  await fastify.register(envPlugin)
  await fastify.register(dbPlugin)
  await fastify.register(authPlugin)

  // Features — each mounted under its own prefix
  fastify.register(usersFeature,    { prefix: '/users' })
  fastify.register(productsFeature, { prefix: '/products' })
  fastify.register(ordersFeature,   { prefix: '/orders' })
  fastify.register(adminFeature,    { prefix: '/admin' })
})
```

Each feature receives the prefix as part of its `opts`, and all routes defined inside inherit it automatically.

---

### Full Directory Layout

```
my-app/
├── app.js
├── package.json
├── plugins/
│   ├── 00-env.js
│   ├── 01-db.js
│   └── 02-auth.js
├── features/
│   ├── users/
│   │   ├── index.js
│   │   ├── routes.js
│   │   ├── schemas.js
│   │   ├── hooks.js
│   │   ├── service.js
│   │   └── repository.js
│   ├── products/
│   │   ├── index.js
│   │   ├── routes.js
│   │   ├── schemas.js
│   │   └── service.js
│   ├── orders/
│   │   ├── index.js
│   │   ├── routes.js
│   │   ├── schemas.js
│   │   ├── hooks.js
│   │   └── service.js
│   └── admin/
│       ├── index.js
│       ├── routes.js
│       └── hooks.js
└── test/
    ├── helper.js
    └── features/
        ├── users/
        │   ├── routes.test.js
        │   └── service.test.js
        ├── products/
        └── orders/
```

---

### Using `@fastify/autoload` for Feature Discovery

Instead of manually importing each feature, autoload can discover feature directories automatically:

```js
// app.js
const AutoLoad = require('@fastify/autoload')
const path = require('path')

module.exports = async function app (fastify, opts) {
  // Global infrastructure
  await fastify.register(AutoLoad, {
    dir: path.join(__dirname, 'plugins'),
    options: opts
  })

  // Features — each directory becomes a plugin, prefix inferred from dirname
  fastify.register(AutoLoad, {
    dir: path.join(__dirname, 'features'),
    options: opts,
    dirNameRoutePrefix: true    // features/users → prefix /users
  })
}
```

Each feature's `index.js` is loaded by autoload and mounted under a prefix derived from the directory name.

> [Inference] `dirNameRoutePrefix` causes autoload to use the directory name as a URL prefix. A feature at `features/users/index.js` is mounted at `/users`. Verify this behavior with `fastify print-routes` for your version of `@fastify/autoload`.

---

### Feature-Scoped Schema Registration

For features that use shared schemas across multiple routes, register schemas at the feature scope rather than globally:

```js
// features/users/index.js
async function usersFeature (fastify, opts) {
  // Register shared schema for $ref use within this feature
  fastify.addSchema({
    $id: 'UserSchema',
    type: 'object',
    properties: {
      id: { type: 'integer' },
      name: { type: 'string' },
      email: { type: 'string', format: 'email' }
    }
  })

  fastify.register(require('./hooks'))
  fastify.register(require('./routes'))
}

module.exports = usersFeature
```

Routes within the feature can then reference `UserSchema` via `$ref`:

```js
const getUsersSchema = {
  response: {
    200: {
      type: 'array',
      items: { $ref: 'UserSchema#' }
    }
  }
}
```

> [Inference] Schemas registered inside an encapsulated plugin (no `fp`) are scoped to that plugin's context. They are not accessible outside the feature unless registered at the root or with `fp`. Behavior should be verified — schema scoping rules interact with Fastify's encapsulation in ways that may differ across versions.

---

### Cross-Feature Dependencies

Features occasionally need shared logic from other features — for example, an `orders` feature that needs to look up a `user`. The correct approach is **not** to import one feature's internals from another, but to:

1. Extract the shared logic into a global plugin decorator
2. Or pass a shared service instance through the Fastify decorator system

```js
// plugins/03-user-service.js — promoted to global plugin
const fp = require('fastify-plugin')
const UserRepository = require('../features/users/repository')
const UserService = require('../features/users/service')

module.exports = fp(async function (fastify) {
  const repo = new UserRepository(fastify.db)
  fastify.decorate('userService', new UserService(repo))
}, { name: 'user-service', dependencies: ['db-plugin'] })
```

The `orders` feature then uses `fastify.userService` without coupling to `users` internals:

```js
// features/orders/routes.js
fastify.post('/', async (req, reply) => {
  const user = await fastify.userService.getById(req.body.userId)
  if (!user) throw fastify.httpErrors.notFound('User not found')
  // proceed with order creation
})
```

---

### Testing Feature Modules

#### Testing the Service in Isolation

```js
// test/features/users/service.test.js
const { test } = require('node:test')
const UserService = require('../../../features/users/service')

test('getById returns null for unknown id', async (t) => {
  const mockDb = {
    query: async () => ({ rows: [] })
  }
  const service = new UserService(mockDb)
  const result = await service.getById(999)
  t.assert.equal(result, null)
})
```

No Fastify instance required — the service is a plain class.

#### Testing Routes via Injection

```js
// test/features/users/routes.test.js
const { test } = require('node:test')
const { build } = require('../../helper')

test('GET /users returns array', async (t) => {
  const app = await build(t)
  const res = await app.inject({ method: 'GET', url: '/users' })
  t.assert.equal(res.statusCode, 200)
  t.assert.ok(Array.isArray(JSON.parse(res.payload)))
})

test('POST /users creates a user', async (t) => {
  const app = await build(t)
  const res = await app.inject({
    method: 'POST',
    url: '/users',
    payload: { name: 'Alice', email: 'alice@example.com' }
  })
  t.assert.equal(res.statusCode, 201)
})
```

---

### Encapsulation Summary

```
fastify (root)
├── envPlugin (fp)        → fastify.config available everywhere
├── dbPlugin (fp)         → fastify.db available everywhere
├── authPlugin (fp)       → fastify.authenticate available everywhere
│
├── usersFeature          ← encapsulated scope
│   ├── userHooks         ← preHandler: authenticate (scoped to users)
│   └── userRoutes        ← GET /users, POST /users, GET /users/:id
│
├── productsFeature       ← encapsulated scope
│   └── productRoutes     ← GET /products, GET /products/:id
│
└── adminFeature          ← encapsulated scope
    ├── adminHooks        ← preHandler: requireAdmin (scoped to admin)
    └── adminRoutes       ← GET /admin/reports, GET /admin/users
```

Each feature is an isolated island that inherits root-level infrastructure but does not expose its internal hooks to siblings.

---

### When to Use Feature-Based Structure

Feature-based structure becomes beneficial when:

- The application has three or more distinct business domains
- Multiple developers or teams work on different features simultaneously
- Features have divergent authentication, validation, or hook requirements
- Individual features need to be tested, deployed, or reasoned about independently

For very small applications (one or two features), the overhead of the directory structure may outweigh the organizational benefit. [Inference] The appropriate threshold depends on team size, codebase growth rate, and how frequently features are added or removed.

---

**Related Topics:**
- Fastify encapsulation model and plugin scoping rules
- `fastify-plugin` (`fp`) and when to break encapsulation
- `@fastify/autoload` `dirNameRoutePrefix` and index file resolution
- Schema registration scope and `$ref` resolution across plugins
- Dependency injection patterns in Fastify via decorators
- Service and repository layer testing without Fastify
- Monorepo strategies for large Fastify applications