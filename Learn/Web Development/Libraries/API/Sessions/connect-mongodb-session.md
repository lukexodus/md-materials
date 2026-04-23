# connect-mongodb-session

`connect-mongodb-session` is a MongoDB-backed session store for `express-session`. It persists session data to a MongoDB collection, enabling sessions to survive process restarts and scale across multiple server instances.

---

## Installation

```bash
npm install connect-mongodb-session express-session
```

---

## Basic Usage

```js
const express = require('express');
const session = require('express-session');
const MongoDBStore = require('connect-mongodb-session')(session);

const app = express();

const store = new MongoDBStore({
  uri: 'mongodb://localhost:27017/myapp',
  collection: 'sessions',
});

app.use(
  session({
    secret: process.env.SESSION_SECRET,
    resave: false,
    saveUninitialized: false,
    store: store,
    cookie: {
      maxAge: 1000 * 60 * 60 * 24, // 1 day in milliseconds
    },
  })
);
```

The store is passed directly to `express-session` via the `store` option.

---

## Constructor Options

```js
new MongoDBStore({
  uri: 'mongodb://localhost:27017/myapp',   // required
  collection: 'sessions',                   // default: 'mySessions'
  databaseName: 'myapp',                    // override DB from URI
  connectionOptions: {},                     // passed to MongoClient
  ttl: 14 * 24 * 60 * 60,                  // TTL in seconds; default: session cookie maxAge or 14 days
  autoRemove: 'native',                     // TTL index strategy
  autoRemoveInterval: 10,                   // minutes, used when autoRemove is 'interval'
  touchAfter: 0,                            // lazy session update threshold in seconds
  crypto: {                                 // optional encryption
    secret: false,
  },
});
```

---

## Options Reference

### uri

**Required.** MongoDB connection string. Supports all URI formats accepted by the MongoDB Node.js driver, including replica sets and Atlas connection strings.

```js
uri: 'mongodb+srv://user:pass@cluster.mongodb.net/myapp?retryWrites=true'
```

### collection

Name of the MongoDB collection where sessions are stored. Defaults to `'mySessions'`. Setting an explicit value is recommended to avoid confusion.

```js
collection: 'sessions'
```

### databaseName

Overrides the database name in the URI. Useful when the URI does not include a database name or when you need to target a different database than the one in the connection string.

```js
databaseName: 'session_db'
```

### connectionOptions

Options object passed directly to `MongoClient`. Use for TLS configuration, authentication mechanisms, connection pool sizing, and other driver-level settings.

```js
connectionOptions: {
  tls: true,
  tlsCAFile: '/path/to/ca.pem',
  maxPoolSize: 10,
}
```

### ttl

Time-to-live for session documents in seconds. When a session expires, MongoDB removes it via a TTL index. If not set, the store falls back to the `maxAge` of the session cookie, or 14 days if neither is defined.

```js
ttl: 60 * 60 * 24 * 7  // 7 days
```

### autoRemove

Controls how expired sessions are removed.

|Value|Behavior|
|---|---|
|`'native'`|Creates a MongoDB TTL index on the `expires` field (default)|
|`'interval'`|Runs a periodic query to delete expired documents|
|`'disabled'`|No automatic removal; handle externally|

`'native'` is recommended for most deployments. It offloads expiry to MongoDB's background TTL reaper and does not require additional application-level scheduling.

```js
autoRemove: 'native'
```

### autoRemoveInterval

Interval in minutes between expired session purges when `autoRemove` is `'interval'`. Default is `10`.

```js
autoRemoveInterval: 30
```

### touchAfter

Reduces writes by only updating the session's `lastModified` timestamp if more than `touchAfter` seconds have elapsed since the last update. This applies only when the session data itself has not changed.

Setting `touchAfter: 0` (default) updates on every request. Setting a positive value is useful for reducing write load on high-traffic applications.

```js
touchAfter: 24 * 3600  // update at most once per day if data unchanged
```

### crypto.secret

Enables AES-256-CBC encryption of session data at rest. Set to a string secret. If `false` (default), sessions are stored in plaintext.

```js
crypto: {
  secret: process.env.SESSION_ENCRYPTION_SECRET,
}
```

[Unverified — the specific encryption implementation details (key derivation, IV handling) are not documented in depth in the official README; review the source before relying on this for sensitive data.]

---

## Error Handling

The store emits an `'error'` event on connection failures or MongoDB errors. Without a listener, an unhandled `'error'` event crashes the Node.js process.

```js
store.on('error', (err) => {
  console.error('Session store error:', err);
});
```

Always attach an error listener before passing the store to `express-session`.

---

## Connection Readiness

The store connects to MongoDB asynchronously. The store emits a `'connected'` event when ready.

```js
store.on('connected', () => {
  console.log('Session store connected');
  app.listen(3000);
});
```

`express-session` buffers requests while the store is connecting, so delaying `app.listen` until `'connected'` is a defensive practice, not strictly required.

---

## Session Document Structure

Each session is stored as a document in the configured collection:

```json
{
  "_id": "s%3AaBcDeFgHiJkL...",
  "session": {
    "cookie": {
      "originalMaxAge": 86400000,
      "expires": "2024-12-01T00:00:00.000Z",
      "httpOnly": true,
      "path": "/"
    },
    "userId": 42
  },
  "expires": "2024-12-01T00:00:00.000Z"
}
```

- `_id` — the session ID (URL-encoded)
- `session` — the full session object including cookie metadata and any application data written to `req.session`
- `expires` — the field used by the TTL index for automatic removal

---

## TTL Index

When `autoRemove` is `'native'`, the store creates a TTL index on the `expires` field:

```js
{ expires: 1 }, { expireAfterSeconds: 0 }
```

MongoDB's TTL reaper runs approximately every 60 seconds, so session documents may persist briefly past their `expires` value. This is a MongoDB behavior, not a store behavior. [Unverified — exact TTL reaper interval may vary by MongoDB version and server configuration.]

You can verify the index exists:

```js
db.sessions.getIndexes()
```

---

## Reusing an Existing Connection

`connect-mongodb-session` manages its own connection internally and does not accept an existing `MongoClient` instance directly.

If you need to share a connection (e.g., with Mongoose), one approach is to point both at the same URI and let the MongoDB driver handle connection pooling. They will use separate pool instances.

[Inference — there is no official API for injecting an existing client; sharing connections at the application level requires a workaround or a different store library such as `connect-mongo`.]

---

## Use with Mongoose

`connect-mongodb-session` does not depend on Mongoose and does not use the Mongoose connection. Configure it with the same URI independently:

```js
const mongoose = require('mongoose');
const MongoDBStore = require('connect-mongodb-session')(session);

mongoose.connect(process.env.MONGO_URI);

const store = new MongoDBStore({
  uri: process.env.MONGO_URI,
  collection: 'sessions',
});
```

Both will connect independently to the same MongoDB server.

---

## express-session Options Relevant to the Store

These `express-session` options interact directly with store behavior:

### resave

Set to `false`. Prevents the session from being saved back to the store on every request if it was not modified. Reduces unnecessary writes.

```js
resave: false
```

### saveUninitialized

Set to `false`. Prevents uninitialized sessions (new sessions with no data written) from being persisted. Reduces storage of empty sessions and aligns with GDPR/cookie consent requirements.

```js
saveUninitialized: false
```

### cookie.maxAge

Controls session cookie lifetime in milliseconds. This value is used to derive the session `expires` field in the store if `ttl` is not explicitly set.

```js
cookie: { maxAge: 1000 * 60 * 60 * 24 * 7 }  // 7 days
```

### cookie.secure

Send the cookie only over HTTPS. Should be `true` in production.

```js
cookie: { secure: true }
```

Requires the Express app to trust the proxy if behind a load balancer:

```js
app.set('trust proxy', 1);
```

### cookie.httpOnly

Prevents client-side JavaScript from reading the cookie. Default `true`. Do not disable unless explicitly required.

---

## Clearing All Sessions

Delete all documents in the sessions collection directly:

```js
const { MongoClient } = require('mongodb');

const client = new MongoClient(process.env.MONGO_URI);
await client.connect();
await client.db().collection('sessions').deleteMany({});
await client.close();
```

There is no built-in `store.clear()` API in `connect-mongodb-session`.

[Unverified — verify against the current release; API surface may have changed.]

---

## Manual Session Destruction

Destroy a session from a route handler:

```js
app.post('/logout', (req, res) => {
  req.session.destroy((err) => {
    if (err) return res.status(500).send('Logout failed');
    res.clearCookie('connect.sid');
    res.redirect('/login');
  });
});
```

`req.session.destroy` removes the session document from the store and clears the in-memory session object.

---

## Common Mistakes

**No error listener on the store.** An unhandled `'error'` event crashes the process. Always attach one.

**Setting `resave: true`.** Causes every request to write to MongoDB regardless of whether session data changed. Combine with `touchAfter` and `resave: false` to minimize writes.

**Not setting `cookie.secure` in production.** Session cookies transmitted over HTTP are vulnerable to interception.

**Not setting `saveUninitialized: false`.** Every unauthenticated request creates and persists a session document, bloating the collection.

**Assuming TTL expiry is immediate.** MongoDB's TTL reaper runs on an interval. Expired sessions are not removed the instant they expire.

**Storing large objects in `req.session`.** The entire session object is serialized to a single MongoDB document. MongoDB documents have a 16MB size limit, and large sessions increase read/write overhead on every request.

---

## Reference

- Repository: [github.com/mongodb-js/connect-mongodb-session](https://github.com/mongodb-js/connect-mongodb-session)
- `express-session`: [github.com/expressjs/session](https://github.com/expressjs/session)
- MongoDB TTL Indexes: [www.mongodb.com/docs/manual/core/index-ttl](https://www.mongodb.com/docs/manual/core/index-ttl/)