# Comprehensive Guide to the `pg` Node.js Library

`pg` (also called `node-postgres`) is the most widely used PostgreSQL client for Node.js. It provides both a low-level client interface and a connection pool, supports async/await, parameterized queries, transactions, streams, and notifications. This guide covers the full surface area of the library from installation to advanced usage.

---

## Installation

```bash
npm install pg
```

For TypeScript users, install the type definitions separately:

```bash
npm install --save-dev @types/pg
```

Optional: if you want to use the native bindings (C++ libpq wrapper, faster but requires build tools):

```bash
npm install pg-native
```

---

## Core Concepts

The `pg` library exposes two primary classes:

- `Client` — a single database connection you manage manually.
- `Pool` — a managed pool of connections, recommended for most applications.

Both share nearly the same query API. The difference is lifecycle management: a `Client` must be explicitly connected and disconnected; a `Pool` borrows and returns connections automatically.

---

## Connecting with `Client`

### Basic Connection

```js
const { Client } = require('pg');

const client = new Client({
  host: 'localhost',
  port: 5432,
  database: 'mydb',
  user: 'myuser',
  password: 'mypassword',
});

await client.connect();
// ... run queries ...
await client.end();
```

### Connection via Connection String

```js
const client = new Client({
  connectionString: 'postgresql://myuser:mypassword@localhost:5432/mydb',
});
```

### Connection via Environment Variables

If no configuration is passed, `pg` reads standard `libpq` environment variables:

|Variable|Default|
|---|---|
|`PGHOST`|`localhost`|
|`PGPORT`|`5432`|
|`PGDATABASE`|Current OS user|
|`PGUSER`|Current OS user|
|`PGPASSWORD`|_(none)_|
|`PGCONNSTRING`|_(none)_|

```js
// Reads all connection info from environment
const client = new Client();
await client.connect();
```

---

## Connecting with `Pool`

### Basic Pool Setup

```js
const { Pool } = require('pg');

const pool = new Pool({
  host: 'localhost',
  port: 5432,
  database: 'mydb',
  user: 'myuser',
  password: 'mypassword',
  max: 10,              // maximum connections in pool
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 2000,
});
```

### Pool Configuration Options

|Option|Type|Description|
|---|---|---|
|`max`|number|Max connections. Default: `10`|
|`min`|number|Min idle connections. Default: `0`|
|`idleTimeoutMillis`|number|Time before idle connection is closed. Default: `10000`|
|`connectionTimeoutMillis`|number|Time to wait for a connection before erroring. Default: `0` (no timeout)|
|`maxUses`|number|Number of times a connection can be reused before being destroyed. Default: `Infinity`|
|`allowExitOnIdle`|boolean|Allow Node process to exit if pool is idle. Default: `false`|

### Using Pool Directly

The pool exposes a `query()` method that borrows a connection, runs the query, and returns it automatically:

```js
const result = await pool.query('SELECT NOW()');
console.log(result.rows[0]);
```

### Manually Checking Out a Client from a Pool

Use this when you need to run multiple queries on the same connection (e.g., transactions):

```js
const client = await pool.connect();
try {
  await client.query('BEGIN');
  await client.query('INSERT INTO users(name) VALUES($1)', ['Alice']);
  await client.query('COMMIT');
} catch (err) {
  await client.query('ROLLBACK');
  throw err;
} finally {
  client.release(); // Always release back to the pool
}
```

**Important:** Always call `client.release()` in a `finally` block. Failing to release a client will exhaust the pool.

---

## Running Queries

### Simple Query

```js
const result = await pool.query('SELECT * FROM users');
console.log(result.rows);      // array of row objects
console.log(result.rowCount);  // number of rows returned/affected
```

### The `QueryResult` Object

Every query returns a `QueryResult` with these fields:

|Field|Type|Description|
|---|---|---|
|`rows`|`object[]`|Array of row objects, keyed by column name|
|`rowCount`|`number`|Rows returned (SELECT) or affected (INSERT/UPDATE/DELETE)|
|`fields`|`FieldInfo[]`|Metadata about each column|
|`command`|`string`|SQL command tag (e.g., `"SELECT"`, `"INSERT"`)|
|`oid`|`number`|OID of an inserted row (if applicable)|

### Parameterized Queries

Always use parameterized queries to avoid SQL injection. Parameters are passed as `$1`, `$2`, etc.:

```js
const result = await pool.query(
  'SELECT * FROM users WHERE id = $1 AND active = $2',
  [42, true]
);
```

Parameters can be any JavaScript value that `pg` knows how to serialize: strings, numbers, booleans, `Date`, `null`, arrays, and objects (serialized as JSON).

### Query Config Object

Instead of positional arguments, you can pass a config object:

```js
const result = await pool.query({
  text: 'SELECT * FROM users WHERE id = $1',
  values: [42],
  rowMode: 'array',   // return rows as arrays instead of objects
  name: 'fetch-user', // prepared statement name (optional)
});
```

---

## Prepared Statements

Named prepared statements are parsed and planned once on the server, then reused for subsequent executions. This can improve performance for frequently-run queries.

```js
const query = {
  name: 'get-user',
  text: 'SELECT * FROM users WHERE id = $1',
  values: [1],
};

// First call: prepares and executes
await client.query(query);

// Subsequent calls with same `name`: reuses the plan
await client.query({ ...query, values: [2] });
```

**Note:** Prepared statements are per-connection. They are not shared across pool connections.

---

## Data Type Handling

### Type Parsing

`pg` parses PostgreSQL types into native JavaScript types automatically for common types:

|PostgreSQL Type|JavaScript Type|
|---|---|
|`integer`, `smallint`, `bigint`|`string` (bigint is kept as string to avoid precision loss)|
|`float`, `double precision`|`number`|
|`boolean`|`boolean`|
|`timestamp`, `timestamptz`|`Date`|
|`json`, `jsonb`|parsed `object`|
|`text`, `varchar`|`string`|
|`bytea`|`Buffer`|
|`array`|`Array`|
|`null`|`null`|

**Note on bigint:** PostgreSQL `bigint` values are returned as `string` by default because JavaScript `number` cannot represent all 64-bit integers without precision loss. If you need numeric operations, use `BigInt()` or a library like `pg-bigint`.

### Custom Type Parsers

You can override the default parser for any PostgreSQL type using its OID:

```js
const { types } = require('pg');

// Parse bigint as JavaScript BigInt
types.setTypeParser(20, (val) => BigInt(val));

// Parse numeric/decimal as float
types.setTypeParser(1700, (val) => parseFloat(val));
```

You can look up OIDs from the `pg_type` system catalog.

### Serializing Custom Types

For INSERT/UPDATE, you can control how values are serialized by overriding the type serializer:

```js
types.setTypeParser(1082, (val) => val); // Keep date as string, no Date parsing
```

---

## Transactions

### Manual Transaction Management

```js
const client = await pool.connect();
try {
  await client.query('BEGIN');

  const result = await client.query(
    'INSERT INTO orders(user_id, total) VALUES($1, $2) RETURNING id',
    [userId, total]
  );
  const orderId = result.rows[0].id;

  await client.query(
    'INSERT INTO order_items(order_id, product_id) VALUES($1, $2)',
    [orderId, productId]
  );

  await client.query('COMMIT');
  return orderId;
} catch (err) {
  await client.query('ROLLBACK');
  throw err;
} finally {
  client.release();
}
```

### Savepoints

```js
await client.query('BEGIN');
await client.query('SAVEPOINT my_savepoint');

try {
  await client.query('INSERT INTO risky_table VALUES($1)', [value]);
  await client.query('RELEASE SAVEPOINT my_savepoint');
} catch (err) {
  await client.query('ROLLBACK TO SAVEPOINT my_savepoint');
}

await client.query('COMMIT');
```

---

## Streaming Large Result Sets

For very large queries, loading all rows into memory at once is impractical. `pg` supports the `pg-query-stream` package for cursor-based streaming:

```bash
npm install pg-query-stream
```

```js
const QueryStream = require('pg-query-stream');
const { pipeline } = require('stream/promises');
const { createWriteStream } = require('fs');

const client = await pool.connect();
try {
  const query = new QueryStream('SELECT * FROM large_table');
  const stream = client.query(query);

  stream.on('data', (row) => {
    console.log(row);
  });

  stream.on('end', () => {
    client.release();
  });

  stream.on('error', (err) => {
    client.release(true); // destroy connection on error
    console.error(err);
  });
} catch (err) {
  client.release(true);
  throw err;
}
```

---

## LISTEN / NOTIFY

PostgreSQL's `LISTEN`/`NOTIFY` mechanism lets the database push messages to connected clients. This is useful for real-time event patterns.

### Listening

```js
const client = new Client();
await client.connect();

client.on('notification', (msg) => {
  console.log('Channel:', msg.channel);
  console.log('Payload:', msg.payload);
});

await client.query('LISTEN my_channel');
```

### Sending a Notification (from Node or SQL)

From Node.js:

```js
await pool.query("SELECT pg_notify('my_channel', 'hello world')");
```

From PostgreSQL directly:

```sql
NOTIFY my_channel, 'hello world';
```

**Note:** The listening `Client` must stay connected. Do not use a pool client for long-lived `LISTEN` connections because releasing it back to the pool will discard the listener. Use a dedicated, persistent `Client` instance.

### Cleaning Up

```js
await client.query('UNLISTEN my_channel');
await client.end();
```

---

## Error Handling

### Error Object Properties

`pg` throws instances of `Error` with additional PostgreSQL-specific properties when a query fails:

|Property|Description|
|---|---|
|`message`|Human-readable error message|
|`code`|PostgreSQL error code (e.g., `'23505'` for unique violation)|
|`detail`|Detail field from PostgreSQL error|
|`hint`|Optional hint from PostgreSQL|
|`position`|Character position in the query string|
|`internalPosition`|Position in internal query|
|`internalQuery`|Internal query text|
|`where`|Context of the error|
|`schema`|Schema name (if relevant)|
|`table`|Table name (if relevant)|
|`column`|Column name (if relevant)|
|`dataType`|Data type name (if relevant)|
|`constraint`|Constraint name (if relevant)|

### Common PostgreSQL Error Codes

|Code|Meaning|
|---|---|
|`23505`|Unique violation|
|`23503`|Foreign key violation|
|`23502`|Not null violation|
|`42P01`|Undefined table|
|`42703`|Undefined column|
|`08006`|Connection failure|
|`57014`|Query canceled|

### Handling Errors

```js
try {
  await pool.query('INSERT INTO users(email) VALUES($1)', ['duplicate@example.com']);
} catch (err) {
  if (err.code === '23505') {
    console.error('Email already exists:', err.detail);
  } else {
    throw err;
  }
}
```

### Pool Error Events

Errors on idle pool connections are emitted as events. Without a handler, they will crash the process:

```js
pool.on('error', (err, client) => {
  console.error('Unexpected error on idle client', err);
});
```

---

## SSL / TLS Connections

### Enabling SSL

```js
const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: {
    rejectUnauthorized: false, // for self-signed certs (development only)
  },
});
```

### With a Custom CA Certificate

```js
const fs = require('fs');

const pool = new Pool({
  ssl: {
    rejectUnauthorized: true,
    ca: fs.readFileSync('/path/to/server-cert.pem').toString(),
  },
});
```

**Security note:** Setting `rejectUnauthorized: false` disables certificate verification. This is acceptable for local development but should never be used in production environments where security matters.

---

## Copying Data (COPY)

PostgreSQL's `COPY` command is the fastest way to bulk-load data. `pg` supports it via streams.

### COPY FROM (importing data)

```js
const { from } = require('pg-copy-streams');
const fs = require('fs');

const client = await pool.connect();
try {
  const stream = client.query(from('COPY users(name, email) FROM STDIN CSV'));
  const fileStream = fs.createReadStream('/path/to/data.csv');
  await pipeline(fileStream, stream);
} finally {
  client.release();
}
```

### COPY TO (exporting data)

```js
const { to } = require('pg-copy-streams');

const client = await pool.connect();
try {
  const stream = client.query(to('COPY users TO STDOUT CSV HEADER'));
  const fileStream = fs.createWriteStream('/path/to/output.csv');
  await pipeline(stream, fileStream);
} finally {
  client.release();
}
```

Install `pg-copy-streams` separately:

```bash
npm install pg-copy-streams
```

---

## Pool Events

The `Pool` class emits several events you can hook into:

|Event|Description|
|---|---|
|`connect`|A new client has been created and connected|
|`acquire`|A client has been checked out from the pool|
|`remove`|A client has been removed from the pool|
|`error`|An error occurred on an idle client|

```js
pool.on('connect', (client) => {
  console.log('New client connected');
});

pool.on('acquire', (client) => {
  console.log('Client acquired from pool');
});

pool.on('remove', (client) => {
  console.log('Client removed from pool');
});
```

---

## Ending the Pool

When your application shuts down, drain the pool gracefully:

```js
process.on('SIGINT', async () => {
  await pool.end();
  console.log('Pool closed');
  process.exit(0);
});
```

`pool.end()` waits for all checked-out clients to be released and then destroys all connections.

---

## Using with async/await vs Callbacks

`pg` originally used callbacks. As of v7+, all methods return Promises and work natively with `async/await`. The callback style still works for backward compatibility but is not recommended in new code.

Callback style (legacy):

```js
pool.query('SELECT NOW()', (err, result) => {
  if (err) return console.error(err);
  console.log(result.rows);
});
```

Promise / async style (preferred):

```js
const result = await pool.query('SELECT NOW()');
console.log(result.rows);
```

---

## TypeScript Usage

```ts
import { Pool, QueryResult } from 'pg';

interface User {
  id: number;
  name: string;
  email: string;
}

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
});

async function getUserById(id: number): Promise<User | null> {
  const result: QueryResult<User> = await pool.query(
    'SELECT id, name, email FROM users WHERE id = $1',
    [id]
  );
  return result.rows[0] ?? null;
}
```

---

## Common Patterns

### Helper Function to Abstract Query Logic

```js
async function query(text, params) {
  const start = Date.now();
  const result = await pool.query(text, params);
  const duration = Date.now() - start;
  console.log('Executed query', { text, duration, rows: result.rowCount });
  return result;
}
```

### Reusable Transaction Wrapper

```js
async function withTransaction(fn) {
  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    const result = await fn(client);
    await client.query('COMMIT');
    return result;
  } catch (err) {
    await client.query('ROLLBACK');
    throw err;
  } finally {
    client.release();
  }
}

// Usage
await withTransaction(async (client) => {
  await client.query('UPDATE accounts SET balance = balance - $1 WHERE id = $2', [100, fromId]);
  await client.query('UPDATE accounts SET balance = balance + $1 WHERE id = $2', [100, toId]);
});
```

### Inserting Multiple Rows Efficiently

`pg` does not have a built-in bulk insert helper. A common approach is to construct a parameterized multi-row insert:

```js
function buildInsert(table, rows) {
  const columns = Object.keys(rows[0]);
  const values = [];
  const placeholders = rows.map((row, i) => {
    return '(' + columns.map((col, j) => {
      values.push(row[col]);
      return `$${i * columns.length + j + 1}`;
    }).join(', ') + ')';
  });

  const text = `INSERT INTO ${table} (${columns.join(', ')}) VALUES ${placeholders.join(', ')}`;
  return { text, values };
}

const { text, values } = buildInsert('users', [
  { name: 'Alice', email: 'alice@example.com' },
  { name: 'Bob', email: 'bob@example.com' },
]);

await pool.query(text, values);
```

---

## Debugging and Logging

`pg` does not have a built-in debug logger, but you can wrap the pool's `query` method or intercept at the application layer. For raw protocol-level debugging, set the `DEBUG` environment variable if using `pg-native`, or enable PostgreSQL's `log_statement = 'all'` on the server side.

For application-level query logging:

```js
const originalQuery = pool.query.bind(pool);
pool.query = (text, values) => {
  console.log('[SQL]', typeof text === 'object' ? text.text : text);
  return originalQuery(text, values);
};
```

---

## Security Considerations

### Always Use Parameterized Queries

Never interpolate user input directly into query strings. The following is vulnerable to SQL injection and should never be written:

```js
// UNSAFE — never do this
await pool.query(`SELECT * FROM users WHERE name = '${userInput}'`);
```

Always use the parameterized form:

```js
// Safe
await pool.query('SELECT * FROM users WHERE name = $1', [userInput]);
```

### Limit Database Permissions

The database user your application connects with should have only the permissions it needs. Avoid connecting as a superuser or the database owner in application code.

### Protect Credentials

Store database credentials in environment variables, not in source code. Use a secrets manager in production environments.

---

## Notable Related Packages

|Package|Purpose|
|---|---|
|`pg-pool`|The pool implementation (included in `pg`)|
|`pg-query-stream`|Cursor-based streaming for large result sets|
|`pg-copy-streams`|COPY FROM/TO streaming|
|`pg-native`|Native libpq bindings (faster, requires C build tools)|
|`pg-format`|Safe SQL string formatting (for dynamic identifiers)|
|`postgres` (slonik, etc.)|Alternative PostgreSQL clients with different APIs|

---

## Version Notes

This guide reflects the `pg` library as of v8.x. The v8 series is the current stable line. The library follows semantic versioning; check the [official changelog](https://github.com/brianc/node-postgres/blob/master/CHANGELOG.md) when upgrading major versions, as type parser behavior and SSL defaults have changed in the past.