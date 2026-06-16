## Transaction Management in Fastify

### Overview

A database transaction is a unit of work that executes as a single atomic operation — either all statements succeed and are committed, or any failure causes all changes to be rolled back. In Fastify applications, transaction management spans several concerns: acquiring a connection from the pool, coordinating multi-statement operations, handling errors and rollbacks, and releasing connections reliably regardless of outcome.

Transactions are essential when multiple database writes must remain consistent — for example, debiting one account while crediting another, or inserting a parent record before its children. Partial writes without transaction protection can leave the database in an inconsistent state.

---

### ACID Properties (Reference)

| Property | Meaning |
| --- | --- |
| **Atomicity** | All statements in the transaction succeed, or none do |
| **Consistency** | The database moves from one valid state to another |
| **Isolation** | Concurrent transactions do not interfere with each other |
| **Durability** | Committed changes persist even after system failure |

> Isolation behavior depends on the isolation level configured and the database engine. Default isolation levels differ between PostgreSQL, MySQL, and SQLite. [Unverified for all engines — verify against your specific database documentation.]

---

### The Core Transaction Pattern

Regardless of database or library, the structure of a safe transaction follows this shape:

```
acquire connection from pool
  begin transaction
    execute statement 1
    execute statement 2
    ...
  if all succeed → commit
  if any throw   → rollback
release connection to pool (always)
```

The `finally` block is essential. Without it, a thrown error before `release()` exhausts the connection pool over time.

---

### PostgreSQL Transactions with `pg`

#### Basic Pattern

js

```js
fastify.post('/transfer', async (request, reply) => {
  const { fromId, toId, amount } = request.body
  const client = await fastify.db.connect()

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
    request.log.error({ err }, 'Transfer failed, rolled back')
    return reply.code(500).send({ error: 'Transfer failed' })
  } finally {
    client.release()
  }
})
```

> **Key Points**
>
> - `BEGIN`, `COMMIT`, and `ROLLBACK` are sent as raw SQL strings to the same client connection.
> - All statements within the transaction must use the same `client` instance — using `pool.query()` routes to a different connection and falls outside the transaction.
> - `client.release()` in `finally` runs whether the transaction committed or rolled back.

---

### Reusable Transaction Helper

Repeating the `BEGIN / COMMIT / ROLLBACK / finally` pattern in every route is error-prone. Extract it into a reusable utility.

js

```js
// lib/withTransaction.js
export async function withTransaction(pool, callback) {
  const client = await pool.connect()

  try {
    await client.query('BEGIN')
    const result = await callback(client)
    await client.query('COMMIT')
    return result
  } catch (err) {
    await client.query('ROLLBACK')
    throw err  // Re-throw so the caller handles the error
  } finally {
    client.release()
  }
}
```

**Usage in a route:**

js

```js
// routes/orders.js
import { withTransaction } from '../lib/withTransaction.js'

fastify.post('/orders', async (request, reply) => {
  const { userId, items } = request.body

  try {
    const order = await withTransaction(fastify.db, async (client) => {
      const { rows: [newOrder] } = await client.query(
        'INSERT INTO orders (user_id, status) VALUES ($1, $2) RETURNING *',
        [userId, 'pending']
      )

      for (const item of items) {
        await client.query(
          'INSERT INTO order_items (order_id, product_id, qty) VALUES ($1, $2, $3)',
          [newOrder.id, item.productId, item.qty]
        )
        await client.query(
          'UPDATE inventory SET qty = qty - $1 WHERE product_id = $2',
          [item.qty, item.productId]
        )
      }

      return newOrder
    })

    return reply.code(201).send(order)
  } catch (err) {
    request.log.error({ err }, 'Order creation failed')
    return reply.code(500).send({ error: 'Order failed' })
  }
})
```

---

### Decorating the Transaction Helper onto Fastify

Register the helper as a Fastify decoration so it is available across all routes without importing it explicitly.

js

```js
// plugins/database.js
import fp from 'fastify-plugin'
import pg from 'pg'

const { Pool } = pg

async function databasePlugin(fastify, options) {
  const pool = new Pool({
    connectionString: options.connectionString || process.env.DATABASE_URL
  })

  const client = await pool.connect()
  client.release()

  async function withTransaction(callback) {
    const conn = await pool.connect()
    try {
      await conn.query('BEGIN')
      const result = await callback(conn)
      await conn.query('COMMIT')
      return result
    } catch (err) {
      await conn.query('ROLLBACK')
      throw err
    } finally {
      conn.release()
    }
  }

  fastify.decorate('db', pool)
  fastify.decorate('withTransaction', withTransaction)

  fastify.addHook('onClose', async (instance) => {
    await instance.db.end()
  })
}

export default fp(databasePlugin, { name: 'database' })
```

**In routes:**

js

```js
fastify.post('/transfer', async (request, reply) => {
  const { fromId, toId, amount } = request.body

  try {
    await fastify.withTransaction(async (client) => {
      await client.query(
        'UPDATE accounts SET balance = balance - $1 WHERE id = $2',
        [amount, fromId]
      )
      await client.query(
        'UPDATE accounts SET balance = balance + $1 WHERE id = $2',
        [amount, toId]
      )
    })
    return { success: true }
  } catch (err) {
    request.log.error({ err }, 'Transfer failed')
    return reply.code(500).send({ error: 'Transfer failed' })
  }
})
```

---

### MySQL Transactions with `mysql2`

MySQL transactions follow a similar pattern but use connection-level methods rather than raw SQL strings for begin/commit/rollback.

js

```js
fastify.post('/transfer', async (request, reply) => {
  const { fromId, toId, amount } = request.body
  const conn = await fastify.mysql.getConnection()

  try {
    await conn.beginTransaction()

    await conn.query(
      'UPDATE accounts SET balance = balance - ? WHERE id = ?',
      [amount, fromId]
    )
    await conn.query(
      'UPDATE accounts SET balance = balance + ? WHERE id = ?',
      [amount, toId]
    )

    await conn.commit()
    return { success: true }
  } catch (err) {
    await conn.rollback()
    request.log.error({ err }, 'Transfer failed, rolled back')
    return reply.code(500).send({ error: 'Transfer failed' })
  } finally {
    conn.release()
  }
})
```

**Reusable helper for MySQL:**

js

```js
// lib/withMysqlTransaction.js
export async function withMysqlTransaction(pool, callback) {
  const conn = await pool.getConnection()

  try {
    await conn.beginTransaction()
    const result = await callback(conn)
    await conn.commit()
    return result
  } catch (err) {
    await conn.rollback()
    throw err
  } finally {
    conn.release()
  }
}
```

---

### SQLite Transactions with `better-sqlite3`

`better-sqlite3` is synchronous. It provides a `db.transaction()` method that wraps a function in an implicit `BEGIN / COMMIT / ROLLBACK` without manual management.

js

```js
// Defined once at plugin initialization
const transferFunds = fastify.db.transaction((fromId, toId, amount) => {
  const deduct = fastify.db.prepare(
    'UPDATE accounts SET balance = balance - ? WHERE id = ?'
  )
  const credit = fastify.db.prepare(
    'UPDATE accounts SET balance = balance + ? WHERE id = ?'
  )

  deduct.run(amount, fromId)
  credit.run(amount, toId)
})
```

js

```js
fastify.post('/transfer', async (request, reply) => {
  const { fromId, toId, amount } = request.body

  try {
    transferFunds(fromId, toId, amount)
    return { success: true }
  } catch (err) {
    request.log.error({ err }, 'Transfer failed')
    return reply.code(500).send({ error: 'Transfer failed' })
  }
})
```

> **Key Points**
>
> - `db.transaction()` automatically rolls back if the wrapped function throws.
> - Nested `db.transaction()` calls in `better-sqlite3` use SQLite savepoints internally. [Inference — verify against `better-sqlite3` documentation for your version.]
> - Because `better-sqlite3` is synchronous, there is no `await` and no `finally`/`release()` needed.

---

### Savepoints (Nested Transactions)

Some databases support savepoints — named checkpoints within a transaction that allow partial rollback without aborting the entire transaction.

js

```js
async function withSavepoint(client, savepointName, callback) {
  await client.query(`SAVEPOINT ${savepointName}`)
  try {
    const result = await callback(client)
    await client.query(`RELEASE SAVEPOINT ${savepointName}`)
    return result
  } catch (err) {
    await client.query(`ROLLBACK TO SAVEPOINT ${savepointName}`)
    throw err
  }
}
```

**Usage within an outer transaction:**

js

```js
await withTransaction(fastify.db, async (client) => {
  await client.query(
    'INSERT INTO orders (user_id) VALUES ($1)', [userId]
  )

  // Attempt bonus points — non-critical, partial rollback on failure
  try {
    await withSavepoint(client, 'bonus_points', async (c) => {
      await c.query(
        'UPDATE loyalty SET points = points + $1 WHERE user_id = $2',
        [100, userId]
      )
    })
  } catch (err) {
    fastify.log.warn({ err }, 'Bonus points failed, continuing')
    // Outer transaction continues — only the savepoint was rolled back
  }
})
```

> Savepoint support and behavior varies by database engine and isolation level. [Unverified for all engines — verify against your database documentation.]

---

### Transaction Isolation Levels

Isolation levels control how concurrent transactions interact. Set them per-transaction when stricter or more relaxed guarantees are needed.

js

```js
// PostgreSQL — set isolation level after BEGIN
await client.query('BEGIN')
await client.query('SET TRANSACTION ISOLATION LEVEL SERIALIZABLE')
// ... statements
await client.query('COMMIT')
```

| Isolation Level | Dirty Read | Non-repeatable Read | Phantom Read |
| --- | --- | --- | --- |
| `READ UNCOMMITTED` | Possible | Possible | Possible |
| `READ COMMITTED` (PG default) | Prevented | Possible | Possible |
| `REPEATABLE READ` | Prevented | Prevented | Possible |
| `SERIALIZABLE` | Prevented | Prevented | Prevented |

> Isolation guarantees are enforced by the database engine, not by the application or library. [Inference — actual behavior depends on the database engine's implementation.]

---

### Error Handling and Retry Logic

Some transaction failures are transient — for example, `SERIALIZABLE` isolation can produce serialization failures under concurrent load. A retry wrapper handles these cases.

js

```js
// lib/withRetryTransaction.js
const SERIALIZATION_FAILURE = '40001'
const DEADLOCK_DETECTED = '40P01'

export async function withRetryTransaction(pool, callback, maxRetries = 3) {
  let attempt = 0

  while (attempt < maxRetries) {
    const client = await pool.connect()

    try {
      await client.query('BEGIN')
      await client.query(
        'SET TRANSACTION ISOLATION LEVEL SERIALIZABLE'
      )
      const result = await callback(client)
      await client.query('COMMIT')
      return result
    } catch (err) {
      await client.query('ROLLBACK')

      const isRetryable =
        err.code === SERIALIZATION_FAILURE ||
        err.code === DEADLOCK_DETECTED

      if (isRetryable && attempt < maxRetries - 1) {
        attempt++
        const delay = 50 * Math.pow(2, attempt) // exponential backoff
        await new Promise((res) => setTimeout(res, delay))
        continue
      }

      throw err
    } finally {
      client.release()
    }
  }
}
```

js

```js
fastify.post('/checkout', async (request, reply) => {
  try {
    await withRetryTransaction(fastify.db, async (client) => {
      // Serializable operations here
    })
    return { success: true }
  } catch (err) {
    if (err.code === '40001') {
      return reply.code(409).send({ error: 'Conflict, please retry' })
    }
    return reply.code(500).send({ error: 'Checkout failed' })
  }
})
```

> **Key Points**
>
> - PostgreSQL error codes `40001` (serialization failure) and `40P01` (deadlock) are standard, but verifying against your PostgreSQL version documentation is recommended.
> - Retry logic adds latency. Apply it selectively to operations where serialization failures are realistically expected. [Inference]

---

### Transaction Flow Diagram

DatabaseDB ClientwithTransaction()Route HandlerDatabaseDB ClientwithTransaction()Route Handleralt[All succeed][Any throws]withTransaction(callback)pool.connect()BEGINcallback(client)statement 1statement 2COMMITreturn resultROLLBACKclient.release()throw errclient.release()

---

### Knex.js Transaction API

Knex provides a first-class transaction API that handles `BEGIN / COMMIT / ROLLBACK` internally.

js

```js
fastify.post('/order', async (request, reply) => {
  const { userId, items } = request.body

  try {
    const order = await fastify.knex.transaction(async (trx) => {
      const [newOrder] = await trx('orders')
        .insert({ user_id: userId, status: 'pending' })
        .returning('*')

      for (const item of items) {
        await trx('order_items').insert({
          order_id: newOrder.id,
          product_id: item.productId,
          qty: item.qty
        })
      }

      return newOrder
    })

    return reply.code(201).send(order)
  } catch (err) {
    request.log.error({ err }, 'Order failed')
    return reply.code(500).send({ error: 'Order failed' })
  }
})
```

> **Key Points**
>
> - The `trx` object passed to the callback behaves like a Knex query builder but is scoped to the transaction.
> - Knex automatically rolls back if the callback throws and commits if it resolves.
> - All queries inside the callback must use `trx`, not the root `fastify.knex` instance.

---

### Common Mistakes

**Using the pool instead of the client inside a transaction:**

js

```js
// ❌ Wrong — pool.query() uses a different connection
await client.query('BEGIN')
await fastify.db.query('UPDATE ...')  // Outside the transaction
await client.query('COMMIT')

// ✓ Correct — all statements use the same client
await client.query('BEGIN')
await client.query('UPDATE ...')
await client.query('COMMIT')
```

**Forgetting `client.release()` on error:**

js

```js
// ❌ Wrong — release() never called on error path
try {
  await client.query('BEGIN')
  await client.query('UPDATE ...')
  await client.query('COMMIT')
  client.release()
} catch (err) {
  await client.query('ROLLBACK')
  // release() missing here — pool leaks
}

// ✓ Correct
try {
  // ...
} catch (err) {
  await client.query('ROLLBACK')
} finally {
  client.release()  // Always runs
}
```

**Swallowing errors after rollback:**

js

```js
// ❌ Wrong — error is silently swallowed
} catch (err) {
  await client.query('ROLLBACK')
  return { success: false }  // Caller doesn't know what failed
}

// ✓ Correct — re-throw or return a meaningful error response
} catch (err) {
  await client.query('ROLLBACK')
  throw err  // Let the helper or route handle it
}
```

---

**Related Topics**

- Optimistic locking and version columns as an alternative to serializable isolation
- Distributed transactions and the two-phase commit problem
- Outbox pattern for reliable event publishing alongside transactions
- Saga pattern for multi-service transaction coordination
- Prisma and Drizzle ORM transaction APIs in Fastify
- Database error codes by engine (PostgreSQL, MySQL, SQLite)
- Fastify `onError` hook for centralized transaction error logging
- Connection pool exhaustion under high transaction load