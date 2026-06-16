## Connecting to PostgreSQL with @fastify/postgres

`@fastify/postgres` is the officially scoped Fastify plugin for PostgreSQL integration. It wraps `pg` (the `node-postgres` library) and exposes a decorated `fastify.pg` interface across the application, managing connection pooling and lifecycle automatically within Fastify's plugin system.

---

### How It Works

`@fastify/postgres` registers a `pg.Pool` instance (from `node-postgres`) and decorates the Fastify instance with `fastify.pg`. The pool is created on plugin registration and closed gracefully when Fastify shuts down via the `onClose` hook.

**Key Points:**

- The underlying library is `pg` (`node-postgres`) — `@fastify/postgres` is a thin integration layer, not a replacement
- Connection pooling is handled by `pg.Pool` internally; individual connections are checked out from the pool per query and returned automatically
- The plugin hooks into Fastify's `onClose` to drain the pool on shutdown [Inference: based on standard `@fastify/postgres` behavior; verify against current plugin source if shutdown correctness is critical]

---

### Installation

bash

```bash
npm install @fastify/postgres
```

`pg` is a peer dependency and must be installed separately if not already present:

bash

```bash
npm install pg
npm install --save-dev @types/pg   # for TypeScript
```

---

### Basic Registration

typescript

```typescript
import Fastify from 'fastify'
import postgres from '@fastify/postgres'

const fastify = Fastify({ logger: true })

await fastify.register(postgres, {
  connectionString: 'postgresql://user:password@localhost:5432/mydb'
})

await fastify.listen({ port: 3000 })
```

The `connectionString` is the standard PostgreSQL URI format:

```
postgresql://[user]:[password]@[host]:[port]/[database]
```

Alternatively, pass individual connection parameters:

typescript

```typescript
await fastify.register(postgres, {
  host: 'localhost',
  port: 5432,
  database: 'mydb',
  user: 'user',
  password: 'password'
})
```

**Key Points:**

- Registration is asynchronous — `await` the `register` call or use `.ready()` before accessing `fastify.pg`
- The plugin uses `pg.Pool` by default; all pool configuration options accepted by `pg.Pool` are passed through [Inference: based on `@fastify/postgres` documentation; verify supported pass-through options against current version]
- Never hardcode credentials in source — use environment variables

---

### Environment-Based Configuration

typescript

```typescript
await fastify.register(postgres, {
  connectionString: process.env.DATABASE_URL
})
```

With individual fields:

typescript

```typescript
await fastify.register(postgres, {
  host:     process.env.PGHOST     ?? 'localhost',
  port:     Number(process.env.PGPORT ?? 5432),
  database: process.env.PGDATABASE ?? 'mydb',
  user:     process.env.PGUSER     ?? 'user',
  password: process.env.PGPASSWORD
})
```

**Key Points:**

- `pg` also reads standard `PG*` environment variables (`PGHOST`, `PGPORT`, `PGDATABASE`, `PGUSER`, `PGPASSWORD`) natively, so in some configurations you may not need to pass connection options explicitly [Inference: based on `pg` documentation; behavior may vary by deployment environment]

---

### The `fastify.pg` Decorator

After registration, `fastify.pg` exposes the following interface:

| Member | Type | Description |
| --- | --- | --- |
| `fastify.pg.connect()` | `Promise<PoolClient>` | Check out a client from the pool |
| `fastify.pg.query()` | `Promise<QueryResult>` | Run a query using a pool-managed client |
| `fastify.pg.pool` | `pg.Pool` | Direct access to the underlying pool |
| `fastify.pg.Client` | Constructor | The `pg.Client` class, for manual client creation |

---

### Running Queries

#### Pool Query (Recommended for Simple Queries)

`fastify.pg.query()` borrows a client, runs the query, and returns the client to the pool automatically.

typescript

```typescript
fastify.get('/users', async (request, reply) => {
  const result = await fastify.pg.query('SELECT id, name, email FROM users')
  return result.rows
})
```

**With parameterized queries:**

typescript

```typescript
fastify.get('/users/:id', async (request, reply) => {
  const { id } = request.params as { id: string }

  const result = await fastify.pg.query(
    'SELECT id, name, email FROM users WHERE id = $1',
    [id]
  )

  if (result.rows.length === 0) {
    return reply.code(404).send({ error: 'User not found' })
  }

  return result.rows[0]
})
```

**Key Points:**

- Always use parameterized queries (`$1`, `$2`, ...) for user-supplied values — never interpolate values directly into SQL strings
- Parameterization prevents SQL injection at the `pg` driver level [Inference: based on `pg` documentation; this is a well-established property of parameterized queries in database drivers, though correctness depends on consistent use]
- `result.rows` is a typed array of row objects; column names become object keys

#### Manual Client Checkout (for Transactions)

When you need to run multiple queries within a single transaction, check out a client explicitly and manage it manually.

typescript

```typescript
fastify.post('/transfer', async (request, reply) => {
  const { fromId, toId, amount } = request.body as {
    fromId: number
    toId: number
    amount: number
  }

  const client = await fastify.pg.connect()

  try {
    await client.query('BEGIN')

    await client.query(
      'UPDATE accounts SET balance = balance - $1 WHERE id = $2',
      [amount, fromId]
    )

    await client.query(
      'UPDATE accounts SET balance = balance + $1 WHERE id = $2',
      [amount, toId]
    )

    await client.query('COMMIT')

    return { success: true }
  } catch (err) {
    await client.query('ROLLBACK')
    throw err
  } finally {
    client.release()
  }
})
```

**Key Points:**

- `client.release()` must always be called — whether the transaction succeeds or fails. The `finally` block enforces this
- Failing to call `release()` leaks the connection back to the pool, eventually exhausting available connections [Inference: based on `pg.Pool` behavior; pool exhaustion manifests as hanging requests waiting for an available client]
- `ROLLBACK` on error ensures the partial transaction does not persist
- `throw err` after rollback re-throws the error to Fastify's error handler

---

### TypeScript Typing for Query Results

`pg.query` accepts a generic type parameter for row shape:

typescript

```typescript
interface User {
  id: number
  name: string
  email: string
  created_at: Date
}

fastify.get('/users/:id', async (request, reply) => {
  const { id } = request.params as { id: string }

  const result = await fastify.pg.query<User>(
    'SELECT id, name, email, created_at FROM users WHERE id = $1',
    [id]
  )

  const user: User | undefined = result.rows[0]

  if (!user) {
    return reply.code(404).send({ error: 'Not found' })
  }

  return user
})
```

**[Inference]:** TypeScript generics on `pg.query` provide compile-time type safety for `result.rows`, but they do not validate that the actual database columns match the declared type at runtime. A mismatch between the SQL projection and the TypeScript interface produces no runtime error — only incorrect types. Verify column names and types match the interface.

---

### Connection Pool Configuration

`@fastify/postgres` passes pool options directly to `pg.Pool`:

typescript

```typescript
await fastify.register(postgres, {
  connectionString: process.env.DATABASE_URL,
  // Pool options
  max: 20,              // Maximum pool size (default: 10 in pg)
  min: 2,               // Minimum idle connections [Unverified: verify this option is supported by your pg version]
  idleTimeoutMillis: 30_000,   // Remove idle clients after 30s
  connectionTimeoutMillis: 2_000, // Fail if no client available within 2s
  allowExitOnIdle: false         // Keep process alive while pool has clients
})
```

**Key Points:**

- `max` controls the maximum number of concurrent database connections. Set this based on your PostgreSQL server's `max_connections` setting and the number of application instances [Inference]
- `connectionTimeoutMillis` prevents indefinite hanging when the pool is exhausted — requests fail fast instead
- `idleTimeoutMillis` releases idle connections back to PostgreSQL, reducing resource consumption during low-traffic periods
- Pool sizing is application-specific; there is no universally correct value [Inference: based on general connection pool theory]

---

### Multiple Named Connections

`@fastify/postgres` supports registering multiple database connections under different namespaces using the `name` option.

typescript

```typescript
// Primary database
await fastify.register(postgres, {
  connectionString: process.env.PRIMARY_DATABASE_URL,
  name: 'primary'
})

// Read replica
await fastify.register(postgres, {
  connectionString: process.env.REPLICA_DATABASE_URL,
  name: 'replica'
})
```

**Access by name:**

typescript

```typescript
// Write to primary
await fastify.pg.primary.query(
  'INSERT INTO events (type, payload) VALUES ($1, $2)',
  ['user.created', JSON.stringify(payload)]
)

// Read from replica
const result = await fastify.pg.replica.query(
  'SELECT * FROM events ORDER BY created_at DESC LIMIT 50'
)
```

**Key Points:**

- Without a `name`, the plugin decorates `fastify.pg` directly
- With a `name`, the plugin decorates `fastify.pg[name]`
- Mixing named and unnamed registrations is supported [Inference: verify against current plugin documentation]
- This pattern is useful for read/write splitting or connecting to multiple databases within the same application

---

### Mermaid: Request Lifecycle with `@fastify/postgres`

PostgreSQLPgPoolFastifyClientPostgreSQLPgPoolFastifyClientClient returned to pool automatically (query)or on client.release() (connect)HTTP Requestpg.query() or connect()Acquire connection + execute queryResult rowsQueryResult / PoolClientHTTP Response

---

### Plugin Encapsulation and Scoping

Because `@fastify/postgres` uses `fastify-plugin` internally, it breaks encapsulation and decorates the root Fastify instance. This means `fastify.pg` is available in all scopes — child plugins, routes, and hooks — without re-registration.

typescript

```typescript
// app.ts
await fastify.register(postgres, { connectionString: process.env.DATABASE_URL })

// routes/users.ts — fastify.pg is accessible here without re-registering
export default async function userRoutes(fastify: FastifyInstance) {
  fastify.get('/users', async () => {
    return (await fastify.pg.query('SELECT * FROM users')).rows
  })
}
```

**Key Points:**

- This is different from plugins that do not use `fastify-plugin` — those would require the consumer to pass the decorated instance down explicitly
- The tradeoff is that `fastify.pg` becomes a global dependency; all routes in all scopes can access it

---

### Graceful Shutdown

`@fastify/postgres` registers an `onClose` hook that drains the pool when `fastify.close()` is called. No manual cleanup is required in most cases.

typescript

```typescript
// fastify.close() triggers pool.end() internally
process.on('SIGTERM', async () => {
  await fastify.close()
  process.exit(0)
})
```

**[Inference]:** Pool draining waits for in-flight queries to complete before closing connections. The duration of this wait depends on active query duration. If queries are long-running, shutdown may be delayed. Verify this behavior against current `@fastify/postgres` and `pg` versions if shutdown timing is a concern.

---

### Error Handling

Database errors surface as thrown exceptions within `async` route handlers and are caught by Fastify's error handler.

typescript

```typescript
fastify.get('/users/:id', async (request, reply) => {
  try {
    const { id } = request.params as { id: string }
    const result = await fastify.pg.query<User>(
      'SELECT * FROM users WHERE id = $1',
      [id]
    )
    if (!result.rows[0]) return reply.code(404).send({ error: 'Not found' })
    return result.rows[0]
  } catch (err: any) {
    // pg errors include a .code property (PostgreSQL error code)
    if (err.code === '23505') {
      return reply.code(409).send({ error: 'Duplicate entry' })
    }
    throw err // Re-throw unknown errors to Fastify's default error handler
  }
})
```

**Common PostgreSQL error codes:**

| Code | Meaning |
| --- | --- |
| `23505` | Unique violation |
| `23503` | Foreign key violation |
| `23502` | Not null violation |
| `42P01` | Undefined table |
| `08006` | Connection failure |
| `40001` | Serialization failure (retry candidate) |

**Key Points:**

- `pg` errors include a `code` property containing the 5-character PostgreSQL error code
- Re-throwing unknown errors allows Fastify's `setErrorHandler` to handle them centrally
- Connection errors (`08006`) may indicate pool exhaustion or network issues — log them with sufficient context for diagnosis

---

### Health Check Route

A common pattern is exposing a `/health` endpoint that verifies database connectivity:

typescript

```typescript
fastify.get('/health', async (request, reply) => {
  try {
    await fastify.pg.query('SELECT 1')
    return { status: 'ok', database: 'connected' }
  } catch (err) {
    fastify.log.error(err, 'Database health check failed')
    return reply.code(503).send({ status: 'error', database: 'unreachable' })
  }
})
```

**Key Points:**

- `SELECT 1` is a minimal query that validates the connection without touching application tables
- A `503` response signals to load balancers and orchestrators that the instance is not ready to serve traffic [Inference: depends on load balancer configuration]

---

### Declaring Types for `fastify.pg` in TypeScript

When using TypeScript, you may need to augment Fastify's type definitions if your editor does not resolve `fastify.pg` automatically:

typescript

```typescript
// types/fastify.d.ts
import '@fastify/postgres'
// @fastify/postgres ships its own type augmentation;
// importing it ensures FastifyInstance is extended with .pg
```

If using named connections, the types may require additional augmentation depending on the plugin version [Unverified: verify against current `@fastify/postgres` TypeScript definitions].

---

**Related Topics:**

- Running database migrations with `node-postgres` and tools like `node-pg-migrate` or `Flyway`
- Query builders with `pg`: using `slonik` or `kysely` as typed query layers
- Using `@fastify/postgres` with connection string secrets from environment managers (Vault, AWS Secrets Manager)
- Read/write splitting patterns with named pool instances
- Prepared statements with `pg` for repeated query optimization
- PostgreSQL `LISTEN`/`NOTIFY` for real-time event delivery via `pg`
- Integration testing Fastify routes with a real PostgreSQL instance using `testcontainers`
- Row-level security and passing request context to PostgreSQL session variables