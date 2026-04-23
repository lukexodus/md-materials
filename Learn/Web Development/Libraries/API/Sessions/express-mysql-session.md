# express-mysql-session

`express-mysql-session` is a MySQL session store for `express-session`. It persists session data to a MySQL (or MariaDB) table, enabling sessions to survive process restarts and work across multiple server instances.

---

## Installation

```bash
npm install express-mysql-session express-session
```

---

## Basic Usage

```js
const express = require('express');
const session = require('express-session');
const MySQLStore = require('express-mysql-session')(session);

const app = express();

const store = new MySQLStore({
  host: 'localhost',
  port: 3306,
  user: 'root',
  password: process.env.DB_PASSWORD,
  database: 'myapp',
});

app.use(
  session({
    secret: process.env.SESSION_SECRET,
    resave: false,
    saveUninitialized: false,
    store: store,
    cookie: {
      maxAge: 1000 * 60 * 60 * 24,
    },
  })
);
```

---

## Constructor Signatures

The store accepts either a connection options object, an existing `mysql2` connection, or an existing `mysql2` pool.

### Options object (store manages connection)

```js
const store = new MySQLStore(options);
```

### Existing connection

```js
const mysql = require('mysql2/promise');

const connection = await mysql.createConnection({ ... });
const store = new MySQLStore(options, connection);
```

### Existing pool

```js
const pool = mysql.createPool({ ... });
const store = new MySQLStore(options, pool);
```

When passing an existing connection or pool, the store uses it directly and does not create its own. The store will not close it on cleanup — that remains the caller's responsibility.

---

## Constructor Options

```js
new MySQLStore({
  // Connection (if not passing existing connection/pool)
  host: 'localhost',
  port: 3306,
  user: 'root',
  password: '',
  database: 'myapp',

  // Table
  schema: {
    tableName: 'sessions',
    columnNames: {
      session_id: 'session_id',
      expires: 'expires',
      data: 'data',
    },
  },

  // Behavior
  createDatabaseTable: true,
  connectionLimit: 1,
  checkExpirationInterval: 900000,   // ms; how often to clear expired sessions
  expiration: 86400000,              // ms; max session age if cookie has no maxAge
  endConnectionOnClose: true,        // close connection when store is closed
  disableTouch: false,               // disable session touch (TTL refresh)
});
```

---

## Options Reference

### host / port / user / password / database

Standard MySQL connection parameters. Used only when the store creates its own connection. Ignored when an existing connection or pool is passed.

### schema.tableName

Name of the table where sessions are stored. Default: `'sessions'`.

```js
schema: { tableName: 'user_sessions' }
```

### schema.columnNames

Rename the three columns used by the store. All three must be present if overriding.

```js
schema: {
  tableName: 'sessions',
  columnNames: {
    session_id: 'sid',
    expires: 'exp',
    data: 'payload',
  },
}
```

Useful when the defaults conflict with reserved words or existing schema conventions.

### createDatabaseTable

When `true` (default), the store creates the sessions table automatically on startup if it does not exist. Set to `false` if managing the schema externally.

```js
createDatabaseTable: false
```

Manual schema equivalent:

```sql
CREATE TABLE IF NOT EXISTS `sessions` (
  `session_id` VARCHAR(128) NOT NULL,
  `expires` INT(11) UNSIGNED NOT NULL,
  `data` MEDIUMTEXT,
  PRIMARY KEY (`session_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;
```

### connectionLimit

Number of connections in the internally managed pool. Default: `1`. Only applies when the store creates its own connection. For higher concurrency, increase this value or pass an external pool.

```js
connectionLimit: 10
```

### checkExpirationInterval

Interval in milliseconds at which the store runs a query to delete expired session rows. Default: `900000` (15 minutes). Set to `0` to disable.

```js
checkExpirationInterval: 60000  // every 1 minute
```

Unlike MongoDB's TTL index, expiration cleanup is handled entirely in application code via this interval. Expired sessions are not removed by the database engine itself.

### expiration

Maximum session lifetime in milliseconds when the session cookie has no `maxAge`. Default: `86400000` (24 hours).

```js
expiration: 1000 * 60 * 60 * 24 * 7  // 7 days
```

### endConnectionOnClose

When `true` (default), the store closes the MySQL connection when `store.close()` is called. Set to `false` when passing an external connection that your application manages independently.

```js
endConnectionOnClose: false
```

### disableTouch

When `true`, disables the `touch` method, preventing the store from refreshing the session expiry on each request. Default: `false`.

```js
disableTouch: true
```

Reduces write load when session TTL refresh is not required. Equivalent in effect to `touchAfter` in `connect-mongodb-session`, though without a threshold — it is all-or-nothing.

---

## Session Table Structure

When `createDatabaseTable` is `true`, the store creates a table with this structure:

```sql
CREATE TABLE `sessions` (
  `session_id` VARCHAR(128) NOT NULL,
  `expires`    INT(11) UNSIGNED NOT NULL,
  `data`       MEDIUMTEXT,
  PRIMARY KEY (`session_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;
```

- `session_id` — the session ID string from `express-session`
- `expires` — Unix timestamp (seconds) of session expiry
- `data` — JSON-serialized session object

`MEDIUMTEXT` supports up to 16MB of session data per row. Large session objects increase per-request read/write cost.

---

## Reusing an Existing mysql2 Connection or Pool

Passing an existing connection avoids redundant connections and lets you share connection pool resources:

```js
const mysql = require('mysql2/promise');
const session = require('express-session');
const MySQLStore = require('express-mysql-session')(session);

const pool = mysql.createPool({
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
  waitForConnections: true,
  connectionLimit: 10,
});

const store = new MySQLStore({}, pool);
```

Pass an empty options object `{}` as the first argument when providing an existing connection. Options such as `host`, `user`, and `database` are ignored in this case.

---

## Use with Sequelize

`express-mysql-session` does not integrate with Sequelize directly, but you can extract the underlying pool from a Sequelize instance:

```js
const { Sequelize } = require('sequelize');
const MySQLStore = require('express-mysql-session')(session);

const sequelize = new Sequelize(process.env.DB_NAME, process.env.DB_USER, process.env.DB_PASSWORD, {
  host: process.env.DB_HOST,
  dialect: 'mysql',
});

const store = new MySQLStore({}, sequelize.connectionManager.pool);
```

[Unverified — Sequelize's internal pool API is not part of its public contract and may change across versions. Verify against your Sequelize version before use.]

---

## Error Handling

The store does not emit an `'error'` event in the same way as some other stores. Errors surface through `express-session` callbacks and as thrown exceptions in async paths.

Attach a handler via the `express-session` store error convention:

```js
store.on('error', (err) => {
  console.error('Session store error:', err);
});
```

[Unverified — the official README does not prominently document event emission; verify event behavior against the current release source.]

Also handle connection-level errors on any externally managed pool:

```js
pool.on('error', (err) => {
  console.error('MySQL pool error:', err);
});
```

---

## Closing the Store

Call `store.close()` for graceful shutdown. This stops the expiration interval timer and, if `endConnectionOnClose` is `true`, closes the connection.

```js
process.on('SIGTERM', async () => {
  await store.close();
  process.exit(0);
});
```

Failing to close the store leaves the expiration interval timer running, which can prevent the process from exiting cleanly.

---

## Manual Session Destruction

```js
app.post('/logout', (req, res) => {
  req.session.destroy((err) => {
    if (err) return res.status(500).send('Logout failed');
    res.clearCookie('connect.sid');
    res.redirect('/login');
  });
});
```

`req.session.destroy` removes the session row from MySQL and clears the in-memory session object.

---

## Clearing All Sessions

```js
store.clear((err) => {
  if (err) console.error('Failed to clear sessions:', err);
});
```

Executes `DELETE FROM sessions` on the store's table.

---

## Manually Fetching a Session

```js
store.get(sessionId, (err, session) => {
  if (err) console.error(err);
  console.log(session);
});
```

---

## Manually Setting a Session

```js
store.set(sessionId, sessionData, (err) => {
  if (err) console.error(err);
});
```

---

## Manually Destroying a Session

```js
store.destroy(sessionId, (err) => {
  if (err) console.error(err);
});
```

---

## Counting Active Sessions

```js
store.length((err, count) => {
  if (err) console.error(err);
  console.log('Active sessions:', count);
});
```

Returns the number of non-expired session rows.

---

## express-session Options Relevant to the Store

### resave

Set to `false`. Avoids rewriting unchanged sessions to MySQL on every request.

```js
resave: false
```

### saveUninitialized

Set to `false`. Prevents empty sessions from being persisted, reducing table bloat and aligning with cookie consent requirements.

```js
saveUninitialized: false
```

### cookie.secure

Set to `true` in production. Restricts the session cookie to HTTPS.

```js
cookie: { secure: true }
```

Requires trust proxy if behind a reverse proxy:

```js
app.set('trust proxy', 1);
```

### cookie.httpOnly

Prevents client-side JavaScript from accessing the session cookie. Default `true`. Do not disable without deliberate reason.

### cookie.maxAge

Session cookie lifetime in milliseconds. Used to derive the `expires` column value. If unset, `expiration` from the store options is used instead.

```js
cookie: { maxAge: 1000 * 60 * 60 * 24 * 7 }
```

---

## Common Mistakes

**Not calling `store.close()` on shutdown.** The expiration interval holds a reference that keeps the event loop alive, preventing clean process exit.

**Using `resave: true`.** Every request writes to MySQL regardless of whether session data changed, increasing database load unnecessarily.

**Not setting `saveUninitialized: false`.** Unauthenticated requests each create a session row, bloating the sessions table.

**Storing large objects in `req.session`.** The entire session is serialized into a single `MEDIUMTEXT` column and read back on every request. Keep session data minimal.

**Setting `checkExpirationInterval: 0` without an external cleanup mechanism.** Expired rows accumulate indefinitely. Either keep the interval enabled or manage cleanup externally with a scheduled query.

**Not handling pool errors on externally managed connections.** An unhandled pool `'error'` event crashes the process.

**Assuming `createDatabaseTable: true` will migrate schema changes.** The store only creates the table if it does not exist. It does not alter an existing table. Schema changes must be applied manually.

---

## Reference

- Repository: [github.com/chill117/express-mysql-session](https://github.com/chill117/express-mysql-session)
- `express-session`: [github.com/expressjs/session](https://github.com/expressjs/session)
- `mysql2`: [github.com/sidorares/node-mysql2](https://github.com/sidorares/node-mysql2)