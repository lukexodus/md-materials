## SQLite Integration in Fastify

### Overview

SQLite is a lightweight, file-based relational database that requires no separate server process. Integrating it with Fastify is common for development environments, embedded applications, CLI tools, and low-traffic services. The most popular Node.js library for SQLite is `better-sqlite3`, which offers a synchronous API, and `@databases/sqlite`, which is async. This guide focuses on `better-sqlite3` due to its performance characteristics and wide adoption, with a section on `@databases/sqlite` as an alternative.

---

### Installing Dependencies

bash

```bash
npm install better-sqlite3
npm install --save-dev @types/better-sqlite3  # if using TypeScript
```

For the Fastify plugin wrapper approach:

bash

```bash
npm install better-sqlite3 @fastify/plugin  # @fastify/plugin is optional but useful for encapsulation
```

---

### Connecting SQLite Using a Fastify Plugin

The recommended pattern is to wrap the database connection in a Fastify plugin registered with `fastify.decorate()`, making the `db` instance available across the application.

**Basic Plugin Setup**

js

```js
// plugins/sqlite.js
import fp from 'fastify-plugin'
import Database from 'better-sqlite3'

async function sqlitePlugin(fastify, options) {
  const db = new Database(options.dbPath || './app.db', {
    verbose: options.verbose ? console.log : null
  })

  // Enable WAL mode for better read concurrency
  db.pragma('journal_mode = WAL')

  fastify.decorate('db', db)

  fastify.addHook('onClose', (instance, done) => {
    instance.db.close()
    done()
  })
}

export default fp(sqlitePlugin, {
  name: 'sqlite-plugin',
  fastify: '4.x'
})
```

**Registering the Plugin**

js

```js
// app.js
import Fastify from 'fastify'
import sqlitePlugin from './plugins/sqlite.js'

const fastify = Fastify({ logger: true })

await fastify.register(sqlitePlugin, {
  dbPath: './data/myapp.db',
  verbose: false
})

await fastify.listen({ port: 3000 })
```

---

### Schema Initialization

Initialize tables on startup using the plugin, before the server begins accepting requests.

js

```js
async function sqlitePlugin(fastify, options) {
  const db = new Database(options.dbPath || './app.db')

  db.pragma('journal_mode = WAL')
  db.pragma('foreign_keys = ON')

  // Run schema setup
  db.exec(`
    CREATE TABLE IF NOT EXISTS users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      email TEXT UNIQUE NOT NULL,
      created_at TEXT DEFAULT (datetime('now'))
    );

    CREATE TABLE IF NOT EXISTS posts (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id INTEGER NOT NULL,
      title TEXT NOT NULL,
      body TEXT,
      FOREIGN KEY (user_id) REFERENCES users(id)
    );
  `)

  fastify.decorate('db', db)

  fastify.addHook('onClose', (instance, done) => {
    instance.db.close()
    done()
  })
}
```

---

### CRUD Operations in Route Handlers

Once `db` is decorated onto the Fastify instance, it is accessible via `fastify.db` in plugins and `request.server.db` in route handlers.

#### Create

js

```js
fastify.post('/users', async (request, reply) => {
  const { name, email } = request.body

  const stmt = request.server.db.prepare(
    'INSERT INTO users (name, email) VALUES (?, ?)'
  )

  const result = stmt.run(name, email)

  return reply.code(201).send({ id: result.lastInsertRowid })
})
```

#### Read (single and list)

js

```js
fastify.get('/users/:id', async (request, reply) => {
  const stmt = request.server.db.prepare(
    'SELECT * FROM users WHERE id = ?'
  )
  const user = stmt.get(request.params.id)

  if (!user) return reply.code(404).send({ error: 'Not found' })
  return user
})

fastify.get('/users', async (request, reply) => {
  const stmt = request.server.db.prepare('SELECT * FROM users')
  return stmt.all()
})
```

#### Update

js

```js
fastify.put('/users/:id', async (request, reply) => {
  const { name, email } = request.body
  const stmt = request.server.db.prepare(
    'UPDATE users SET name = ?, email = ? WHERE id = ?'
  )
  const result = stmt.run(name, email, request.params.id)

  if (result.changes === 0) return reply.code(404).send({ error: 'Not found' })
  return { updated: true }
})
```

#### Delete

js

```js
fastify.delete('/users/:id', async (request, reply) => {
  const stmt = request.server.db.prepare(
    'DELETE FROM users WHERE id = ?'
  )
  const result = stmt.run(request.params.id)

  if (result.changes === 0) return reply.code(404).send({ error: 'Not found' })
  return { deleted: true }
})
```

---

### Using Transactions

`better-sqlite3` supports synchronous transactions natively via `db.transaction()`. This wraps multiple statements atomically.

js

```js
fastify.post('/transfer', async (request, reply) => {
  const { fromId, toId, amount } = request.body
  const db = request.server.db

  const deduct = db.prepare(
    'UPDATE accounts SET balance = balance - ? WHERE id = ?'
  )
  const credit = db.prepare(
    'UPDATE accounts SET balance = balance + ? WHERE id = ?'
  )

  const transfer = db.transaction((from, to, amt) => {
    deduct.run(amt, from)
    credit.run(amt, to)
  })

  try {
    transfer(fromId, toId, amount)
    return { success: true }
  } catch (err) {
    request.log.error(err)
    return reply.code(500).send({ error: 'Transfer failed' })
  }
})
```

> **Key Points**
>
> - `db.transaction()` returns a function. Calling that function executes all statements inside a single transaction.
> - If any statement throws, the transaction is automatically rolled back.
> - Behavior may vary depending on SQLite pragma settings and library version. [Inference]

---

### Prepared Statements and Performance

`better-sqlite3` compiles SQL once via `db.prepare()` and reuses it. Storing prepared statements at plugin initialization (rather than per-request) reduces overhead.

js

```js
async function sqlitePlugin(fastify, options) {
  const db = new Database(options.dbPath || './app.db')
  db.pragma('journal_mode = WAL')

  const statements = {
    getUserById: db.prepare('SELECT * FROM users WHERE id = ?'),
    getAllUsers: db.prepare('SELECT * FROM users'),
    insertUser: db.prepare('INSERT INTO users (name, email) VALUES (?, ?)'),
    deleteUser: db.prepare('DELETE FROM users WHERE id = ?')
  }

  fastify.decorate('db', db)
  fastify.decorate('stmt', statements)

  fastify.addHook('onClose', (instance, done) => {
    instance.db.close()
    done()
  })
}
```

**Using pre-compiled statements in routes:**

js

```js
fastify.get('/users/:id', async (request, reply) => {
  const user = request.server.stmt.getUserById.get(request.params.id)
  if (!user) return reply.code(404).send({ error: 'Not found' })
  return user
})
```

---

### Input Validation with JSON Schema

Combine Fastify's built-in schema validation with SQLite operations to reject invalid input before hitting the database.

js

```js
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
    201: {
      type: 'object',
      properties: {
        id: { type: 'integer' }
      }
    }
  }
}

fastify.post('/users', { schema: createUserSchema }, async (request, reply) => {
  const { name, email } = request.body
  const result = request.server.stmt.insertUser.run(name, email)
  return reply.code(201).send({ id: result.lastInsertRowid })
})
```

---

### Error Handling for Database Errors

SQLite errors (e.g., unique constraint violations) throw synchronously in `better-sqlite3`. Handle them explicitly.

js

```js
fastify.post('/users', { schema: createUserSchema }, async (request, reply) => {
  const { name, email } = request.body

  try {
    const result = request.server.stmt.insertUser.run(name, email)
    return reply.code(201).send({ id: result.lastInsertRowid })
  } catch (err) {
    if (err.code === 'SQLITE_CONSTRAINT_UNIQUE') {
      return reply.code(409).send({ error: 'Email already exists' })
    }
    request.log.error(err)
    return reply.code(500).send({ error: 'Database error' })
  }
})
```

**Common SQLite error codes:**

| Code | Meaning |
| --- | --- |
| `SQLITE_CONSTRAINT_UNIQUE` | Unique constraint violation |
| `SQLITE_CONSTRAINT_FOREIGNKEY` | Foreign key violation |
| `SQLITE_BUSY` | Database locked by another connection |
| `SQLITE_READONLY` | Write attempted on read-only DB |

---

### Alternative: `@databases/sqlite` (Async API)

If you prefer a Promise-based API, `@databases/sqlite` wraps SQLite with async/await support.

bash

```bash
npm install @databases/sqlite
```

js

```js
import createConnectionPool from '@databases/sqlite'
import fp from 'fastify-plugin'

async function sqlitePlugin(fastify, options) {
  const db = createConnectionPool(options.dbPath || ':memory:')

  fastify.decorate('db', db)

  fastify.addHook('onClose', async (instance) => {
    await instance.db.dispose()
  })
}

export default fp(sqlitePlugin)
```

**Usage in route:**

js

```js
fastify.get('/users', async (request, reply) => {
  const users = await request.server.db.query(
    sql`SELECT * FROM users`
  )
  return users
})
```

> **Key Points**
>
> - `@databases/sqlite` uses tagged template literals (`sql\`...``) for query construction, which helps avoid SQL injection by design.
> - It wraps `better-sqlite3` internally in some versions. [Unverified — verify against the package's current implementation.]

---

### In-Memory Databases for Testing

Use `:memory:` as the database path to create a temporary in-memory SQLite instance, ideal for unit and integration tests.

js

```js
// test/setup.js
import Fastify from 'fastify'
import sqlitePlugin from '../plugins/sqlite.js'

export function buildApp() {
  const fastify = Fastify()

  fastify.register(sqlitePlugin, { dbPath: ':memory:' })

  return fastify
}
```

js

```js
// test/users.test.js
import { buildApp } from './setup.js'

test('POST /users creates a user', async (t) => {
  const app = buildApp()
  await app.ready()

  const response = await app.inject({
    method: 'POST',
    url: '/users',
    payload: { name: 'Alice', email: 'alice@example.com' }
  })

  t.equal(response.statusCode, 201)
  t.ok(JSON.parse(response.body).id)

  await app.close()
})
```

---

### WAL Mode and Concurrency Considerations

SQLite has limited concurrency compared to client-server databases. Key pragmas that affect behavior:

js

```js
db.pragma('journal_mode = WAL')     // Allows concurrent reads during writes
db.pragma('busy_timeout = 5000')    // Wait up to 5s if DB is locked
db.pragma('foreign_keys = ON')      // Enforce FK constraints (off by default)
db.pragma('synchronous = NORMAL')   // Balance between safety and speed
```

> **Key Points**
>
> - SQLite in WAL mode allows one writer and multiple concurrent readers. [Inference based on SQLite documentation — actual behavior depends on OS and filesystem.]
> - For high-concurrency write workloads, SQLite may not be suitable. Consider PostgreSQL or MySQL for those scenarios. [Inference]
> - `busy_timeout` behavior is not guaranteed to resolve all lock contention scenarios.

---

### Project Structure Reference

```
project/
├── app.js
├── plugins/
│   └── sqlite.js        # DB plugin with decoration and lifecycle hooks
├── routes/
│   └── users.js         # Route handlers using request.server.db
├── data/
│   └── myapp.db         # SQLite database file
└── test/
    └── users.test.js    # Tests using :memory: DB
```

---

**Related Topics**

- Migrations with SQLite (using `better-sqlite3-migrations` or custom migration runners)
- Using Drizzle ORM or Prisma with SQLite and Fastify
- PostgreSQL integration with `@fastify/postgres`
- MySQL / MariaDB integration with `mysql2`
- Connection pooling strategies for database plugins
- Fastify plugin encapsulation and `fastify-plugin` (`fp`)
- Testing Fastify applications with `fastify.inject()`
- Environment-based database configuration (dev SQLite, prod PostgreSQL)