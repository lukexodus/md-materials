# `connect-pg-simple` Comprehensive Guide

## What It Is

`connect-pg-simple` is a PostgreSQL session store for `express-session`. It persists session data to a PostgreSQL table, making it suitable for production use where `MemoryStore` is not viable — particularly in multi-process or multi-instance deployments.

It uses the `pg` (node-postgres) package to communicate with PostgreSQL.

---

## Installation

```bash
npm install connect-pg-simple pg
```

---

## Database Setup

You must create the session table before the store can function. `connect-pg-simple` ships with a SQL file for this.

### Using the bundled SQL file

```bash
psql -U youruser -d yourdb -f node_modules/connect-pg-simple/table.sql
```

### Manual table creation

```sql
CREATE TABLE "session" (
  "sid"    varchar      NOT NULL COLLATE "default",
  "sess"   json         NOT NULL,
  "expire" timestamp(6) NOT NULL
)
WITH (OIDS=FALSE);

ALTER TABLE "session" ADD CONSTRAINT "session_pkey"
  PRIMARY KEY ("sid") NOT DEFERRABLE INITIALLY IMMEDIATE;

CREATE INDEX "IDX_session_expire" ON "session" ("expire");
```

The index on `expire` is important — it is used by the pruning query that removes expired sessions.

---

## Basic Setup

```js
const express = require('express');
const session = require('express-session');
const pgSession = require('connect-pg-simple')(session);
const { Pool } = require('pg');

const pool = new Pool({
  connectionString: process.env.DATABASE_URL
});

const app = express();

app.use(session({
  store: new pgSession({
    pool,
    tableName: 'session'
  }),
  secret: process.env.SESSION_SECRET,
  resave: false,
  saveUninitialized: false,
  cookie: {
    maxAge: 1000 * 60 * 60 * 24, // 24 hours
    httpOnly: true,
    secure: process.env.NODE_ENV === 'production',
    sameSite: 'lax'
  }
}));
```

Note the initialization pattern: `require('connect-pg-simple')(session)`. The package exports a factory function that takes `express-session` itself (or a compatible `Store` base class) as its argument.

---

## Configuration Options

### `pool`

A `pg.Pool` instance. This is the recommended way to provide a database connection. The store does not create or manage the pool's lifecycle — you own it.

```js
const pool = new Pool({ connectionString: process.env.DATABASE_URL });
new pgSession({ pool });
```

### `pgPromise`

Alternatively, pass a `pg-promise` database object instead of a `pg.Pool`. Only one of `pool` or `pgPromise` should be provided.

```js
const pgp = require('pg-promise')();
const db = pgp(process.env.DATABASE_URL);
new pgSession({ pgPromise: db });
```

### `conString` / `conObject`

Legacy options. Pass a connection string or connection config object directly. Internally, the store will create its own pool. Using an external `pool` is preferred.

### `tableName`

Name of the session table. Defaults to `'session'`.

```js
tableName: 'user_sessions'
```

### `schemaName`

PostgreSQL schema name, if the table lives outside the default `public` schema.

```js
schemaName: 'app',
tableName: 'sessions'
// queries will target app.sessions
```

### `ttl`

Time-to-live in seconds for stored sessions. Overrides the `maxAge` derived from `req.session.cookie`.

If not set, the TTL is inferred from `cookie.maxAge` or `cookie.expires`. If neither is set on the cookie, sessions do not expire unless explicitly pruned or destroyed.

```js
ttl: 86400 // 1 day in seconds
```

### `disableTouch`

Defaults to `false`. When `false`, the store updates the `expire` column on every `touch()` call, keeping active sessions alive.

Set to `true` to disable this behavior. Sessions will then expire at their original `expire` time regardless of activity. This reduces write load at the cost of session persistence accuracy.

```js
disableTouch: true
```

### `pruneSessionInterval`

Interval in seconds between automatic deletions of expired sessions. Defaults to `60` (once per minute).

Set to `false` to disable automatic pruning entirely.

```js
pruneSessionInterval: 300  // every 5 minutes
pruneSessionInterval: false // disable
```

When pruning runs, it executes:

```sql
DELETE FROM "session" WHERE expire < NOW()
```

### `pruneSessionRandomizedInterval`

When set, randomizes the prune interval to avoid thundering herd problems in multi-instance deployments. The actual interval is randomized within a range derived from `pruneSessionInterval`.

[Inference] In deployments with multiple app instances all sharing one database, synchronized pruning from every instance at the same second could cause unnecessary write contention. Randomization distributes the load. Behavior specifics depend on the version in use.

```js
pruneSessionRandomizedInterval: true
```

### `errorLog`

A function called when an error occurs in the store. Defaults to `console.error`.

```js
errorLog: (err) => myLogger.error('Session store error', err)
```

---

## How It Works

### Session read (`get`)

When a request arrives with a session cookie, `express-session` calls `store.get(sid, callback)`. The store queries:

```sql
SELECT sess FROM "session" WHERE sid = $1 AND expire >= NOW()
```

If the row exists and has not expired, the `sess` JSON column is parsed and returned as the session object. If the row is missing or expired, a new session is initialized.

### Session write (`set`)

After the response is sent (or on explicit `save()`), `express-session` calls `store.set(sid, sessionData, callback)`. The store performs an upsert:

```sql
INSERT INTO "session" (sid, sess, expire)
VALUES ($1, $2, $3)
ON CONFLICT (sid)
DO UPDATE SET sess = $2, expire = $3
```

### Session touch (`touch`)

If `rolling: true` or `req.session.touch()` is called, `express-session` calls `store.touch(sid, session, callback)`. This updates only the `expire` column without rewriting `sess`.

```sql
UPDATE "session" SET expire = $2 WHERE sid = $1
```

Disabled when `disableTouch: true`.

### Session deletion (`destroy`)

`req.session.destroy()` calls `store.destroy(sid, callback)`:

```sql
DELETE FROM "session" WHERE sid = $1
```

---

## Pool Configuration Recommendations

Because the store shares a `pg.Pool` with the rest of your application, pool sizing affects both session operations and application queries.

```js
const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  max: 20,                  // maximum pool size
  idleTimeoutMillis: 30000, // close idle clients after 30s
  connectionTimeoutMillis: 2000 // fail fast if no connection available
});
```

If session traffic is high and you want to isolate it from application query traffic, you can create a dedicated pool solely for the session store.

```js
const appPool = new Pool({ connectionString: process.env.DATABASE_URL, max: 15 });
const sessionPool = new Pool({ connectionString: process.env.DATABASE_URL, max: 5 });

new pgSession({ pool: sessionPool });
```

---

## Multi-Instance Deployments

Because session data is stored in PostgreSQL (external to any single process), multiple Node.js instances can share the same session store without coordination. Each instance reads from and writes to the same table.

One side effect: every instance runs its own pruning interval by default. With `pruneSessionInterval` at the default of 60 seconds and ten instances, you get ten pruning queries per minute against the same table. Options:

- Increase `pruneSessionInterval` on all instances.
- Enable `pruneSessionRandomizedInterval`.
- Set `pruneSessionInterval: false` on all instances and run pruning externally (e.g., a cron job or a pg_cron scheduled query).

External pruning via pg_cron:

```sql
SELECT cron.schedule('prune-sessions', '*/5 * * * *',
  $$DELETE FROM "session" WHERE expire < NOW()$$);
```

---

## TLS / SSL Connections

Pass SSL config through the `Pool`:

```js
const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: {
    rejectUnauthorized: true,
    ca: fs.readFileSync('/path/to/ca.pem').toString()
  }
});
```

For managed services (Heroku, Railway, Supabase, Render) that provide `DATABASE_URL` with `?sslmode=require`, you may need:

```js
ssl: { rejectUnauthorized: false }
```

This disables certificate verification. [Inference] This is acceptable in environments where the connection stays within a private network or the provider's internal routing, but reduces the protection TLS provides against MITM attacks on external connections.

---

## Error Handling

The store calls `errorLog` on internal errors but does not re-throw them to Express's error handler by default. This means a failing session store will silently log rather than crash the request.

If you need to surface store errors (e.g., for monitoring), provide a custom `errorLog`:

```js
new pgSession({
  pool,
  errorLog: (err) => {
    metrics.increment('session.store.error');
    logger.error(err);
  }
});
```

---

## Migrating from `MemoryStore`

1. Create the session table using the SQL above.
2. Install `connect-pg-simple` and `pg`.
3. Replace the `store` option in your `session()` call.
4. Existing in-memory sessions are lost on the transition — users will need to log in again.
5. Set `ttl` or confirm `cookie.maxAge` is set, so rows do not accumulate indefinitely.

---

## Full Example

```js
require('dotenv').config();
const express = require('express');
const session = require('express-session');
const pgSession = require('connect-pg-simple')(session);
const { Pool } = require('pg');

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: process.env.NODE_ENV === 'production'
    ? { rejectUnauthorized: true }
    : false
});

const app = express();

if (process.env.NODE_ENV === 'production') {
  app.set('trust proxy', 1);
}

app.use(session({
  store: new pgSession({
    pool,
    tableName: 'session',
    ttl: 86400,                    // 1 day
    pruneSessionInterval: 300,     // prune every 5 minutes
    disableTouch: false,
    errorLog: console.error
  }),
  secret: process.env.SESSION_SECRET,
  resave: false,
  saveUninitialized: false,
  name: 'sid',
  cookie: {
    httpOnly: true,
    secure: process.env.NODE_ENV === 'production',
    maxAge: 1000 * 60 * 60 * 24,  // 24 hours
    sameSite: 'lax'
  }
}));

app.post('/login', (req, res, next) => {
  const user = validateUser(req.body); // defined elsewhere
  if (!user) return res.status(401).send('Unauthorized');

  req.session.regenerate((err) => {
    if (err) return next(err);
    req.session.userId = user.id;
    req.session.save((err) => {
      if (err) return next(err);
      res.redirect('/dashboard');
    });
  });
});

app.post('/logout', (req, res, next) => {
  req.session.destroy((err) => {
    if (err) return next(err);
    res.clearCookie('sid');
    res.redirect('/login');
  });
});

app.listen(3000);
```