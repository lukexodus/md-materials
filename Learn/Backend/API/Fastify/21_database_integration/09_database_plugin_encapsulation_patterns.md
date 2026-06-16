## Database Plugin Encapsulation Patterns

### Overview

Encapsulation in Fastify determines the scope in which decorators, hooks, and plugins are visible. Understanding and deliberately applying encapsulation patterns is critical when integrating databases — it controls whether a `db` instance is available application-wide or confined to a specific subsystem.

Fastify's plugin system is built on a directed acyclic graph of scopes. Each `fastify.register()` call creates a child scope. Decorators and hooks registered inside that scope are invisible to parent or sibling scopes — unless the plugin is wrapped with `fastify-plugin` (`fp`), which breaks encapsulation intentionally to share the decoration upward.

---

### Fastify Scope Model

Root Fastify InstancePlugin A - fp wrappedPlugin B - scopedDecorates root: fastify.dbvisible everywhereDecorates child only:invisible to siblingsRoute /users - seesfastify.db from Plugin ARoute /internal - seeschild decoration only

> **Key Points**
>
> - `fastify-plugin` causes the plugin's decorations to be applied to the scope that called `register()`, effectively hoisting them.
> - Without `fastify-plugin`, a plugin's `decorate()` calls are invisible outside its own scope and descendants.
> - Behavior is determined at registration time, not at request time.

---

### Core Building Block: `fastify-plugin`

`fastify-plugin` (`fp`) is a small utility that marks a plugin as non-encapsulated. Any `decorate`, `addHook`, or `addSchema` call inside an `fp`-wrapped plugin applies to the parent scope.

#### Installation

bash

```bash
npm install fastify-plugin
```

#### Behavior Difference

**Without `fp` — scoped (encapsulated):**

js

```js
// plugins/db-scoped.js
async function dbPlugin(fastify, options) {
  fastify.decorate('db', { query: () => {} })
}

export default dbPlugin  // No fp wrapping
```

js

```js
// app.js
await fastify.register(dbPlugin)

// fastify.db is undefined here — decoration is scoped inside the plugin
console.log(fastify.db)  // undefined
```

**With `fp` — shared (non-encapsulated):**

js

```js
// plugins/db-shared.js
import fp from 'fastify-plugin'

async function dbPlugin(fastify, options) {
  fastify.decorate('db', { query: () => {} })
}

export default fp(dbPlugin)
```

js

```js
// app.js
await fastify.register(dbPlugin)

// fastify.db is now available on the root instance
console.log(fastify.db)  // { query: [Function] }
```

---

### Pattern 1 — Global Shared Plugin (Most Common)

The most widely used pattern. The database plugin is wrapped with `fp` and registered at the root level, making the `db` decoration available throughout the entire application.

js

```js
// plugins/database.js
import fp from 'fastify-plugin'
import pg from 'pg'

const { Pool } = pg

async function databasePlugin(fastify, options) {
  const pool = new Pool({
    connectionString: options.connectionString || process.env.DATABASE_URL,
    max: options.max || 10
  })

  const client = await pool.connect()
  client.release()
  fastify.log.info('Database pool ready')

  fastify.decorate('db', pool)

  fastify.addHook('onClose', async (instance) => {
    await instance.db.end()
  })
}

export default fp(databasePlugin, {
  name: 'database',
  fastify: '4.x'
})
```

js

```js
// app.js
import Fastify from 'fastify'
import databasePlugin from './plugins/database.js'
import usersRoutes from './routes/users.js'
import ordersRoutes from './routes/orders.js'

const fastify = Fastify({ logger: true })

// Registered once, available everywhere due to fp
await fastify.register(databasePlugin, {
  connectionString: process.env.DATABASE_URL
})

await fastify.register(usersRoutes, { prefix: '/users' })
await fastify.register(ordersRoutes, { prefix: '/orders' })

await fastify.listen({ port: 3000 })
```

**In any route file:**

js

```js
// routes/users.js
export default async function usersRoutes(fastify, options) {
  fastify.get('/', async (request, reply) => {
    const { rows } = await fastify.db.query('SELECT * FROM users')
    return rows
  })
}
```

> **Key Points**
>
> - `fastify.db` is accessible via `fastify` in plugin scope and via `request.server.db` in route handler functions.
> - This pattern is appropriate when all routes share the same database.

---

### Pattern 2 — Scoped Plugin (Encapsulated Access)

Register the database plugin without `fp` inside a specific sub-scope. Only routes registered within that same scope can access the decoration. Sibling or parent scopes cannot.

js

```js
// app.js
import Fastify from 'fastify'

const fastify = Fastify({ logger: true })

// Admin subsystem with its own DB connection
fastify.register(async function adminScope(fastify) {
  // Register db WITHOUT fp — scoped to adminScope only
  fastify.register(async function adminDbPlugin(fastify) {
    fastify.decorate('adminDb', createAdminPool())
    fastify.addHook('onClose', async (i) => await i.adminDb.end())
  })

  fastify.get('/admin/users', async (request, reply) => {
    // adminDb is accessible here
    const { rows } = await fastify.adminDb.query('SELECT * FROM users')
    return rows
  })
})

// Public routes — adminDb is NOT accessible here
fastify.get('/status', async (request, reply) => {
  return { ok: true }
  // fastify.adminDb is undefined in this scope
})
```

**When to use this pattern:**

- Admin vs public route separation with different DB credentials
- Microservice-style sub-applications within one Fastify instance
- Plugins that should not pollute the global namespace

---

### Pattern 3 — Multiple Named Database Decorations

When an application needs connections to more than one database, register each as a separately named decoration.

js

```js
// plugins/databases.js
import fp from 'fastify-plugin'
import pg from 'pg'
import mysql from 'mysql2/promise'

const { Pool } = pg

async function databasesPlugin(fastify, options) {
  // Primary PostgreSQL
  const pgPool = new Pool({
    connectionString: process.env.PRIMARY_DB_URL,
    max: 10
  })

  // Analytics MySQL
  const mysqlPool = await mysql.createPool({
    host: process.env.ANALYTICS_DB_HOST,
    user: process.env.ANALYTICS_DB_USER,
    password: process.env.ANALYTICS_DB_PASS,
    database: process.env.ANALYTICS_DB_NAME,
    connectionLimit: 5
  })

  fastify.decorate('primaryDb', pgPool)
  fastify.decorate('analyticsDb', mysqlPool)

  fastify.addHook('onClose', async (instance) => {
    await instance.primaryDb.end()
    await instance.analyticsDb.end()
  })
}

export default fp(databasesPlugin, { name: 'databases' })
```

js

```js
// routes/report.js
export default async function reportRoutes(fastify, options) {
  fastify.get('/report', async (request, reply) => {
    const [pgResult, mysqlResult] = await Promise.all([
      fastify.primaryDb.query('SELECT count(*) FROM orders'),
      fastify.analyticsDb.query('SELECT sum(revenue) FROM daily_stats')
    ])

    return {
      orderCount: pgResult.rows[0].count,
      totalRevenue: mysqlResult[0][0]['sum(revenue)']
    }
  })
}
```

---

### Pattern 4 — Repository Pattern via Decoration

Rather than exposing the raw pool, decorate the Fastify instance with a repository object that encapsulates all query logic. Routes interact with the repository, not with SQL directly.

js

```js
// repositories/userRepository.js
export function createUserRepository(db) {
  return {
    async findAll() {
      const { rows } = await db.query('SELECT * FROM users')
      return rows
    },

    async findById(id) {
      const { rows } = await db.query(
        'SELECT * FROM users WHERE id = $1', [id]
      )
      return rows[0] || null
    },

    async create({ name, email }) {
      const { rows } = await db.query(
        'INSERT INTO users (name, email) VALUES ($1, $2) RETURNING *',
        [name, email]
      )
      return rows[0]
    },

    async deleteById(id) {
      const result = await db.query(
        'DELETE FROM users WHERE id = $1', [id]
      )
      return result.rowCount > 0
    }
  }
}
```

js

```js
// plugins/repositories.js
import fp from 'fastify-plugin'
import { Pool } from 'pg'
import { createUserRepository } from '../repositories/userRepository.js'
import { createOrderRepository } from '../repositories/orderRepository.js'

async function repositoriesPlugin(fastify, options) {
  const pool = new Pool({ connectionString: process.env.DATABASE_URL })

  fastify.decorate('db', pool)
  fastify.decorate('repos', {
    users: createUserRepository(pool),
    orders: createOrderRepository(pool)
  })

  fastify.addHook('onClose', async (instance) => {
    await instance.db.end()
  })
}

export default fp(repositoriesPlugin, { name: 'repositories' })
```

js

```js
// routes/users.js
export default async function usersRoutes(fastify, options) {
  fastify.get('/', async (request, reply) => {
    return fastify.repos.users.findAll()
  })

  fastify.get('/:id', async (request, reply) => {
    const user = await fastify.repos.users.findById(request.params.id)
    if (!user) return reply.code(404).send({ error: 'Not found' })
    return user
  })

  fastify.post('/', async (request, reply) => {
    const user = await fastify.repos.users.create(request.body)
    return reply.code(201).send(user)
  })
}
```

> **Key Points**
>
> - Routes contain no SQL. All query logic lives in repository functions.
> - Repositories are plain functions — they are testable independently of Fastify.
> - The pattern adds a layer of indirection. [Inference — whether this is beneficial depends on team size and project complexity.]

---

### Pattern 5 — Plugin with Dependency Declaration

Fastify plugins can declare dependencies on other named plugins using the `dependencies` option in `fastify-plugin`. This makes load order requirements explicit and produces clear errors if a dependency is missing.

js

```js
// plugins/repositories.js
import fp from 'fastify-plugin'
import { createUserRepository } from '../repositories/userRepository.js'

async function repositoriesPlugin(fastify, options) {
  // Depends on 'database' plugin being registered first
  fastify.decorate('repos', {
    users: createUserRepository(fastify.db)
  })
}

export default fp(repositoriesPlugin, {
  name: 'repositories',
  dependencies: ['database']  // 'database' is the name given in the db plugin's fp() call
})
```

If `database` has not been registered before `repositories`, Fastify throws at startup:

```
FastifyError: The dependency 'database' of plugin 'repositories' is not registered
```

This makes boot-time errors explicit rather than producing silent undefined references at request time.

---

### Pattern 6 — Per-Request Database Context via `onRequest` Hook

In some cases — such as multi-tenant applications — the correct database connection depends on the incoming request (e.g., a tenant identifier in headers or JWT). Use a hook to attach a per-request connection.

js

```js
// plugins/tenantDb.js
import fp from 'fastify-plugin'

async function tenantDbPlugin(fastify, options) {
  const pools = new Map()

  function getPoolForTenant(tenantId) {
    if (!pools.has(tenantId)) {
      pools.set(tenantId, createPoolForTenant(tenantId))
    }
    return pools.get(tenantId)
  }

  fastify.addHook('onRequest', async (request, reply) => {
    const tenantId = request.headers['x-tenant-id']
    if (!tenantId) {
      return reply.code(400).send({ error: 'Missing tenant ID' })
    }
    request.db = getPoolForTenant(tenantId)
  })

  fastify.addHook('onClose', async () => {
    for (const pool of pools.values()) {
      await pool.end()
    }
  })
}

export default fp(tenantDbPlugin)
```

js

```js
// routes/data.js
fastify.get('/data', async (request, reply) => {
  // request.db is the tenant-specific pool set by the hook
  const { rows } = await request.db.query('SELECT * FROM tenant_data')
  return rows
})
```

> **Key Points**
>
> - `request.db` is set per-request, not on the Fastify instance.
> - Pool caching via `Map` avoids recreating pools on every request. [Inference — production multi-tenant pool management may require eviction strategies and size limits.]
> - This pattern increases complexity. It should be applied only when per-request connection selection is genuinely required. [Inference]

---

### Encapsulation Pattern Comparison

| Pattern | Uses `fp`? | Scope | Best For |
| --- | --- | --- | --- |
| Global shared plugin | Yes | Root | Single DB, whole app |
| Scoped plugin | No | Child scope only | Subsystem isolation |
| Multiple named decorations | Yes | Root | Multiple DB targets |
| Repository pattern | Yes | Root | Query logic separation |
| Dependency declaration | Yes | Root | Explicit load ordering |
| Per-request context hook | Yes | Root (hook) | Multi-tenant, dynamic DB |

---

### Diagram: Encapsulation Scope Visibility

hoists to rootRoot Instance(fastify)fp-wrapped Plugindecorate('db', pool)Scoped Plugindecorate('adminDb', pool)Route /userscan see: db ✓cannotSee: adminDb ✗Route /admincan see: adminDb ✓can see: db ✓

---

### Startup Verification Pattern

Regardless of encapsulation pattern, verify database connectivity at startup and fail fast if the connection cannot be established.

js

```js
async function databasePlugin(fastify, options) {
  const pool = new Pool({ connectionString: options.connectionString })

  try {
    const client = await pool.connect()
    await client.query('SELECT 1')
    client.release()
    fastify.log.info('Database connectivity verified')
  } catch (err) {
    fastify.log.error({ err }, 'Database connection failed at startup')
    throw err  // Prevents Fastify from starting
  }

  fastify.decorate('db', pool)

  fastify.addHook('onClose', async (instance) => {
    await instance.db.end()
  })
}

export default fp(databasePlugin, { name: 'database' })
```

> Throwing inside a plugin's async function causes Fastify's `listen()` or `ready()` to reject, stopping the server from starting. [Inference — actual behavior depends on Fastify version; verify against release notes.]

---

### Directory Structure for Plugin-Based DB Encapsulation

```
project/
├── app.js                    # Root: registers plugins and routes
├── plugins/
│   ├── database.js           # fp-wrapped, global pool
│   └── repositories.js       # fp-wrapped, depends on database
├── repositories/
│   ├── userRepository.js     # Pure query functions
│   └── orderRepository.js
├── routes/
│   ├── users.js              # Uses fastify.repos.users
│   └── orders.js             # Uses fastify.repos.orders
└── test/
    └── users.test.js
```

---

**Related Topics**

- `fastify-plugin` internals and `skip-override` flag
- Fastify plugin load order and `after()` / `ready()` lifecycle
- Dependency injection alternatives (Awilix, tsyringe) with Fastify
- Unit testing repositories independently of Fastify
- Multi-tenant database routing strategies
- Fastify `decorate`, `decorateRequest`, and `decorateReply` differences
- Schema-based multi-tenancy vs database-per-tenant tradeoffs
- Integration testing encapsulated plugins with `fastify.inject()`