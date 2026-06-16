## Connection Pooling in Fastify

### Overview

Connection pooling is a technique where a set of database connections is created and maintained for reuse across multiple requests, rather than opening and closing a new connection for each operation. In Fastify applications, pooling is managed either by the database client library itself, by a dedicated pooling library, or by a Fastify plugin that wraps both.

SQLite, covered in the previous topic, does not use connection pooling in the traditional sense — it is single-file and typically uses a single connection or WAL mode for concurrency. Connection pooling becomes relevant primarily with client-server databases: **PostgreSQL**, **MySQL**, **MariaDB**, and **MSSQL**.

---

### Why Connection Pooling Matters

Opening a new database connection involves:

- TCP handshake with the database server
- Authentication and session setup
- Memory allocation on both client and server

Without pooling, high-traffic Fastify applications can exhaust database connection limits or introduce significant per-request latency.

**Key benefits of pooling:**

- Reuses existing authenticated connections
- Limits total concurrent connections to the database server
- Reduces connection setup latency per request
- Provides a queue for requests when all connections are in use

> **Key Points**
>
> - Pool size tuning is workload-dependent. A pool that is too small causes queuing; one that is too large can overwhelm the database server. [Inference — optimal values vary per system.]
> - Pooling behavior and queue management differ between libraries. Always consult the specific library's documentation.

---

### Connection Pool Lifecycle in Fastify

The standard pattern in Fastify is:

```
App Start → Register Plugin → Pool Created → Decorate fastify.db
                                                      ↓
                             Requests use connections from pool
                                                      ↓
                          App Close → onClose hook → Pool drained
```

This maps cleanly to Fastify's plugin and lifecycle system.

---

### PostgreSQL Pooling with `@fastify/postgres`

`@fastify/postgres` is the official Fastify plugin wrapping `pg` (node-postgres), which includes a built-in connection pool via `pg.Pool`.

#### Installation

bash

```bash
npm install @fastify/postgres
```

#### Registration

js

```js
import Fastify from 'fastify'
import fastifyPostgres from '@fastify/postgres'

const fastify = Fastify({ logger: true })

await fastify.register(fastifyPostgres, {
  connectionString: 'postgresql://user:password@localhost:5432/mydb',
  // Pool configuration passed directly to pg.Pool
  max: 10,           // Maximum connections in pool
  min: 2,            // Minimum idle connections maintained
  idleTimeoutMillis: 30000,   // Close idle connections after 30s
  connectionTimeoutMillis: 2000  // Fail if connection not acquired in 2s
})
```

#### Using the Pool in Routes

js

```js
fastify.get('/users', async (request, reply) => {
  const client = await request.server.pg.connect()

  try {
    const result = await client.query('SELECT * FROM users')
    return result.rows
  } finally {
    client.release()  // Always release back to pool
  }
})
```

**Shorthand query (no manual client management):**

js

```js
fastify.get('/users', async (request, reply) => {
  const { rows } = await request.server.pg.query(
    'SELECT * FROM users'
  )
  return rows
})
```

> **Key Points**
>
> - The shorthand `.query()` method acquires and releases a client internally.
> - Manual `client.connect()` / `client.release()` is necessary when running multiple queries in a single transaction.
> - Failing to call `client.release()` will exhaust the pool over time. Always use `try/finally`.

---

### PostgreSQL Pooling with `pg` Directly

If you prefer not to use the official plugin, you can wrap `pg.Pool` manually.

js

```js
// plugins/postgres.js
import fp from 'fastify-plugin'
import pg from 'pg'

const { Pool } = pg

async function postgresPlugin(fastify, options) {
  const pool = new Pool({
    host: options.host || 'localhost',
    port: options.port || 5432,
    database: options.database,
    user: options.user,
    password: options.password,
    max: options.max || 10,
    idleTimeoutMillis: options.idleTimeoutMillis || 30000,
    connectionTimeoutMillis: options.connectionTimeoutMillis || 2000
  })

  // Verify connectivity at startup
  const client = await pool.connect()
  client.release()
  fastify.log.info('PostgreSQL pool connected')

  fastify.decorate('pg', pool)

  fastify.addHook('onClose', async (instance) => {
    await instance.pg.end()
  })
}

export default fp(postgresPlugin)
```

js

```js
// Usage in route
fastify.get('/users/:id', async (request, reply) => {
  const { rows } = await request.server.pg.query(
    'SELECT * FROM users WHERE id = $1',
    [request.params.id]
  )
  if (!rows.length) return reply.code(404).send({ error: 'Not found' })
  return rows[0]
})
```

---

### MySQL / MariaDB Pooling with `mysql2`

`mysql2` includes built-in pool support and is the most common MySQL client for Node.js.

#### Installation

bash

```bash
npm install mysql2
```

#### Plugin

js

```js
// plugins/mysql.js
import fp from 'fastify-plugin'
import mysql from 'mysql2/promise'

async function mysqlPlugin(fastify, options) {
  const pool = mysql.createPool({
    host: options.host || 'localhost',
    port: options.port || 3306,
    user: options.user,
    password: options.password,
    database: options.database,
    waitForConnections: true,
    connectionLimit: options.connectionLimit || 10,
    queueLimit: 0  // 0 = unlimited queue
  })

  // Verify connectivity
  const conn = await pool.getConnection()
  conn.release()
  fastify.log.info('MySQL pool connected')

  fastify.decorate('mysql', pool)

  fastify.addHook('onClose', async (instance) => {
    await instance.mysql.end()
  })
}

export default fp(mysqlPlugin)
```

#### Using the Pool

js

```js
fastify.get('/products', async (request, reply) => {
  const [rows] = await request.server.mysql.query(
    'SELECT * FROM products'
  )
  return rows
})
```

**With a manual connection for transactions:**

js

```js
fastify.post('/order', async (request, reply) => {
  const conn = await request.server.mysql.getConnection()

  try {
    await conn.beginTransaction()

    await conn.query(
      'INSERT INTO orders (user_id, total) VALUES (?, ?)',
      [request.body.userId, request.body.total]
    )
    await conn.query(
      'UPDATE inventory SET quantity = quantity - ? WHERE product_id = ?',
      [request.body.qty, request.body.productId]
    )

    await conn.commit()
    return { success: true }
  } catch (err) {
    await conn.rollback()
    request.log.error(err)
    return reply.code(500).send({ error: 'Order failed' })
  } finally {
    conn.release()
  }
})
```

---

### Pool Configuration Parameters Explained

The following parameters appear across most pooling libraries with similar semantics:

| Parameter | Description | Typical Default |
| --- | --- | --- |
| `max` / `connectionLimit` | Maximum concurrent connections | 10 |
| `min` | Minimum idle connections kept alive | 0–2 |
| `idleTimeoutMillis` | Time before idle connection is closed | 10,000–30,000ms |
| `connectionTimeoutMillis` | Max wait time to acquire a connection | 0 (indefinite) or 2,000ms |
| `queueLimit` | Max queued requests when pool is full | 0 (unlimited) |
| `waitForConnections` | Whether to queue or error when pool full | `true` |

> **Key Points**
>
> - Parameter names differ between `pg`, `mysql2`, and other clients. Always verify against the library's own documentation.
> - Setting `connectionTimeoutMillis` to a non-zero value is recommended for production to avoid indefinite request hangs. [Inference]

---

### Multiple Named Pools

`@fastify/postgres` supports multiple named pool instances for multi-database setups.

js

```js
await fastify.register(fastifyPostgres, {
  name: 'primary',
  connectionString: 'postgresql://user:pass@primary-host/mydb'
})

await fastify.register(fastifyPostgres, {
  name: 'analytics',
  connectionString: 'postgresql://user:pass@analytics-host/analytics'
})
```

**Access by name:**

js

```js
fastify.get('/report', async (request, reply) => {
  const { rows } = await request.server.pg.analytics.query(
    'SELECT * FROM report_summary'
  )
  return rows
})
```

> When no `name` is provided, the pool is accessible as `fastify.pg`. When named, it is accessible as `fastify.pg[name]`. [Inference based on plugin conventions — verify against `@fastify/postgres` documentation for your version.]

---

### Pool Monitoring and Health Checks

Expose pool state for observability or liveness probes.

**PostgreSQL pool stats:**

js

```js
fastify.get('/health/db', async (request, reply) => {
  const pool = request.server.pg.pool  // access underlying pg.Pool

  return {
    total: pool.totalCount,
    idle: pool.idleCount,
    waiting: pool.waitingCount
  }
})
```

**MySQL — no built-in stats API in `mysql2`.** [Unverified — verify against `mysql2` current release.]

---

### Using Knex.js as a Pool-Aware Query Builder

Knex.js manages its own connection pool (via `tarn.js` internally) and supports PostgreSQL, MySQL, SQLite, and MSSQL.

#### Installation

bash

```bash
npm install knex pg  # or knex mysql2
```

#### Plugin

js

```js
// plugins/knex.js
import fp from 'fastify-plugin'
import knex from 'knex'

async function knexPlugin(fastify, options) {
  const db = knex({
    client: 'pg',
    connection: {
      host: 'localhost',
      port: 5432,
      user: 'user',
      password: 'password',
      database: 'mydb'
    },
    pool: {
      min: 2,
      max: 10,
      acquireTimeoutMillis: 3000,
      idleTimeoutMillis: 30000
    }
  })

  // Verify connectivity
  await db.raw('SELECT 1')
  fastify.log.info('Knex pool ready')

  fastify.decorate('knex', db)

  fastify.addHook('onClose', async (instance) => {
    await instance.knex.destroy()
  })
}

export default fp(knexPlugin)
```

#### Usage

js

```js
fastify.get('/users', async (request, reply) => {
  return request.server.knex('users').select('*')
})

fastify.post('/users', async (request, reply) => {
  const [id] = await request.server.knex('users')
    .insert(request.body)
    .returning('id')
  return reply.code(201).send({ id })
})
```

---

### Pool Exhaustion and Timeout Errors

When all connections in the pool are occupied and new requests arrive:

- If `waitForConnections: true` (MySQL) or no timeout set (pg): requests queue
- If `connectionTimeoutMillis` is exceeded: an error is thrown

**Handling timeout errors explicitly:**

js

```js
fastify.get('/data', async (request, reply) => {
  try {
    const { rows } = await request.server.pg.query('SELECT * FROM data')
    return rows
  } catch (err) {
    if (err.message.includes('timeout')) {
      return reply.code(503).send({ error: 'Database unavailable' })
    }
    request.log.error(err)
    return reply.code(500).send({ error: 'Internal error' })
  }
})
```

> Error message strings for timeout detection are library-specific and may change between versions. [Unverified — prefer checking `err.code` or library-defined error types where available.]

---

### Diagram: Connection Pool Request Flow

Database ServerConnection PoolFastify HandlerRequestDatabase ServerConnection PoolFastify HandlerRequestconnectionTimeoutMillis appliesalt[Connection available][Pool full]HTTP Request arrivesAcquire connectionReturn idle connectionQueue request (waits)Execute queryReturn resultRelease connectionConnection returned to poolSend HTTP response

---

### Environment-Based Pool Configuration

Avoid hardcoding pool settings. Use environment variables for flexibility across environments.

js

```js
const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  max: parseInt(process.env.DB_POOL_MAX || '10'),
  idleTimeoutMillis: parseInt(process.env.DB_IDLE_TIMEOUT || '30000'),
  connectionTimeoutMillis: parseInt(process.env.DB_CONN_TIMEOUT || '2000')
})
```

```
# .env
DATABASE_URL=postgresql://user:pass@localhost:5432/mydb
DB_POOL_MAX=10
DB_IDLE_TIMEOUT=30000
DB_CONN_TIMEOUT=2000
```

---

**Related Topics**

- `@fastify/postgres` advanced usage (named clients, transactional helpers)
- Drizzle ORM and Prisma with built-in connection pooling
- PgBouncer as an external connection pooler for PostgreSQL
- Read replica routing with multiple named pools
- Graceful shutdown and pool draining on `SIGTERM`
- Fastify lifecycle hooks (`onReady`, `onClose`) for resource management
- Health check routes and Kubernetes liveness/readiness probes
- Knex.js migrations and seeding in Fastify projects