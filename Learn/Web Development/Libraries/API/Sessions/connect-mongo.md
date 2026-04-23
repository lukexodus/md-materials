# Comprehensive Guide to the `connect-mongo` Library

`connect-mongo` is a MongoDB session store for the `express-session` middleware. It persists session data to a MongoDB collection instead of keeping it in memory, which means sessions survive server restarts and work across multiple server instances.

---

## Prerequisites

- Node.js 12 or later (v4.x of `connect-mongo` requires Node 12+)
- An accessible MongoDB instance
- `express-session` installed

---

## Installation

```bash
npm install connect-mongo express-session
```

For MongoDB driver compatibility, `connect-mongo` v4 and later use the native `mongodb` driver directly. You do not need `mongoose` unless your application already uses it.

---

## How It Works

`express-session` stores session data somewhere. By default it uses an in-memory store, which is lost on restart and does not scale across processes. `connect-mongo` replaces that in-memory store with a MongoDB collection. Each session becomes one document in that collection. The library handles reads, writes, and deletions automatically as `express-session` calls the store interface.

---

## Basic Setup

### With a MongoDB Connection String

```js
const express = require('express');
const session = require('express-session');
const MongoStore = require('connect-mongo');

const app = express();

app.use(session({
  secret: 'your-secret-key',
  resave: false,
  saveUninitialized: false,
  store: MongoStore.create({
    mongoUrl: 'mongodb://localhost:27017/mydb'
  })
}));
```

`MongoStore.create()` is the constructor introduced in v4. The older `new MongoStore()` syntax is not supported in v4+.

### With an Existing Mongoose Connection

```js
const mongoose = require('mongoose');
const session = require('express-session');
const MongoStore = require('connect-mongo');

await mongoose.connect('mongodb://localhost:27017/mydb');

app.use(session({
  secret: 'your-secret-key',
  resave: false,
  saveUninitialized: false,
  store: MongoStore.create({
    client: mongoose.connection.getClient()
  })
}));
```

### With an Existing Native MongoDB Client

```js
const { MongoClient } = require('mongodb');
const MongoStore = require('connect-mongo');

const client = new MongoClient('mongodb://localhost:27017');
await client.connect();

const store = MongoStore.create({
  client: client,
  dbName: 'mydb'
});
```

---

## Configuration Options

All options are passed to `MongoStore.create({})`.

### Connection Options

Exactly one of `mongoUrl`, `client`, or `clientPromise` must be provided.

`mongoUrl` — a MongoDB connection string. The library creates and manages its own connection internally.

```js
MongoStore.create({
  mongoUrl: 'mongodb://localhost:27017/mydb'
})
```

`client` — an already-connected `MongoClient` instance. Useful when your application already manages its own database connection.

```js
MongoStore.create({
  client: existingClient,
  dbName: 'mydb'
})
```

`clientPromise` — a `Promise` that resolves to a connected `MongoClient`. Useful in environments where the client is initialized asynchronously before the store is configured.

```js
const clientPromise = MongoClient.connect('mongodb://localhost:27017');

MongoStore.create({
  clientPromise: clientPromise,
  dbName: 'mydb'
})
```

### Storage Options

`dbName` — the database to use. If omitted, the database is taken from the connection string or the client's default.

```js
MongoStore.create({
  mongoUrl: 'mongodb://localhost:27017',
  dbName: 'sessions_db'
})
```

`collectionName` — the collection where sessions are stored. Defaults to `'sessions'`.

```js
MongoStore.create({
  mongoUrl: 'mongodb://localhost:27017/mydb',
  collectionName: 'user_sessions'
})
```

`stringify` — when `true` (default), session data is serialized to a JSON string before storage. When `false`, session data is stored as a native BSON document, which allows querying individual fields but requires session values to be BSON-compatible.

```js
MongoStore.create({
  mongoUrl: 'mongodb://localhost:27017/mydb',
  stringify: false
})
```

### TTL and Expiry Options

`ttl` — time-to-live in seconds for session documents. Defaults to the session's `maxAge` if set, otherwise `86400` (24 hours). MongoDB removes expired documents via a TTL index on the `expires` field.

```js
MongoStore.create({
  mongoUrl: 'mongodb://localhost:27017/mydb',
  ttl: 60 * 60 * 2  // 2 hours
})
```

`autoRemove` — controls how expired sessions are removed. Accepted values:

- `'native'` (default) — relies on MongoDB's TTL index. MongoDB removes expired documents automatically but not instantly; there is typically a delay of up to 60 seconds.
- `'interval'` — the library itself polls and removes expired sessions on a configurable interval.
- `'disabled'` — no automatic removal. You are responsible for cleanup.

```js
MongoStore.create({
  mongoUrl: 'mongodb://localhost:27017/mydb',
  autoRemove: 'interval',
  autoRemoveInterval: 10  // minutes, only used when autoRemove is 'interval'
})
```

`touchAfter` — lazy session update in seconds. When set, the store only updates a session's expiry timestamp in MongoDB if more than `touchAfter` seconds have passed since the last update. This reduces write operations when sessions are frequently read but rarely modified.

```js
MongoStore.create({
  mongoUrl: 'mongodb://localhost:27017/mydb',
  touchAfter: 24 * 3600  // only re-save once per day unless data changes
})
```

Note: `touchAfter` only affects the session's touch/expiry update. If the session data itself changes, it is always written immediately regardless of this setting.

### Crypto Options

`crypto` — enables encryption of session data at rest. Pass an object with a `secret` string.

```js
MongoStore.create({
  mongoUrl: 'mongodb://localhost:27017/mydb',
  crypto: {
    secret: 'your-encryption-secret'
  }
})
```

When `crypto.secret` is set, session data is encrypted before writing to MongoDB and decrypted on read. The encryption uses AES-256-CBC. Changing or losing the secret invalidates all existing sessions.

### Serialization Options

`serialize` and `unserialize` — custom functions for converting session data to and from the stored format. Useful if you need a format other than JSON.

```js
MongoStore.create({
  mongoUrl: 'mongodb://localhost:27017/mydb',
  serialize: (session) => JSON.stringify(session),
  unserialize: (session) => JSON.parse(session)
})
```

---

## Session Document Structure

Each session is stored as a MongoDB document. With default settings (stringify: true), it looks like this:

```json
{
  "_id": "s%3AaBcDeFgHiJkL...",
  "expires": "2024-12-01T00:00:00.000Z",
  "session": "{\"cookie\":{\"originalMaxAge\":null,\"expires\":null,\"httpOnly\":true,\"path\":\"/\"},\"userId\":123}"
}
```

With `stringify: false`, the session field is a nested object rather than a JSON string, making individual fields queryable.

A TTL index on the `expires` field is created automatically. This is what MongoDB uses to expire documents when `autoRemove` is `'native'`.

---

## Accessing the Store Instance

You may need a reference to the store to call methods on it directly.

```js
const store = MongoStore.create({
  mongoUrl: 'mongodb://localhost:27017/mydb'
});

app.use(session({
  secret: 'secret',
  resave: false,
  saveUninitialized: false,
  store: store
}));

// Later:
store.destroy('session-id', callback);
store.clear(callback);
store.length(callback);
store.all(callback);
```

---

## Store Methods

These are part of the `express-session` store interface. You can call them directly when needed (for example, to invalidate a session server-side).

`store.destroy(sessionId, callback)` — deletes a single session by ID.

`store.clear(callback)` — deletes all sessions in the collection.

`store.length(callback)` — returns the count of stored sessions.

`store.all(callback)` — returns all sessions as an array.

`store.get(sessionId, callback)` — retrieves a session by ID.

`store.set(sessionId, session, callback)` — creates or overwrites a session.

`store.touch(sessionId, session, callback)` — updates the expiry of an existing session without changing its data.

---

## Events

The store emits events you can listen to.

```js
store.on('create', (sessionId) => {
  console.log('Session created:', sessionId);
});

store.on('update', (sessionId) => {
  console.log('Session updated:', sessionId);
});

store.on('set', (sessionId) => {
  // Fired on both create and update
});

store.on('destroy', (sessionId) => {
  console.log('Session destroyed:', sessionId);
});

store.on('error', (error) => {
  console.error('Session store error:', error);
});
```

---

## TypeScript Usage

```ts
import session from 'express-session';
import MongoStore from 'connect-mongo';

app.use(session({
  secret: process.env.SESSION_SECRET!,
  resave: false,
  saveUninitialized: false,
  store: MongoStore.create({
    mongoUrl: process.env.MONGODB_URI!,
    collectionName: 'sessions',
    ttl: 60 * 60 * 24,
    touchAfter: 60 * 60
  })
}));
```

---

## Environment-Based Configuration

```js
const MongoStore = require('connect-mongo');

const store = MongoStore.create({
  mongoUrl: process.env.MONGODB_URI,
  dbName: process.env.DB_NAME || 'myapp',
  collectionName: 'sessions',
  ttl: parseInt(process.env.SESSION_TTL || '86400', 10),
  touchAfter: 3600,
  crypto: process.env.SESSION_ENCRYPTION_SECRET
    ? { secret: process.env.SESSION_ENCRYPTION_SECRET }
    : undefined
});
```

---

## Recommended `express-session` Settings

These `express-session` options are particularly relevant when using a persistent store.

`resave: false` — do not re-save a session to the store on every request if it was not modified. Setting this to `true` causes unnecessary writes and can conflict with `touchAfter`.

`saveUninitialized: false` — do not save new sessions that have not been modified. This avoids storing empty sessions for every request, including from bots and unauthenticated crawlers.

`rolling: true` — reset the session expiry on every response. Combine with `ttl` to keep active users logged in.

```js
app.use(session({
  secret: 'your-secret',
  resave: false,
  saveUninitialized: false,
  rolling: true,
  cookie: {
    secure: process.env.NODE_ENV === 'production',
    httpOnly: true,
    maxAge: 1000 * 60 * 60 * 24  // 1 day in milliseconds
  },
  store: MongoStore.create({
    mongoUrl: process.env.MONGODB_URI,
    ttl: 60 * 60 * 24,
    touchAfter: 60 * 60
  })
}));
```

Note: `cookie.maxAge` is in milliseconds. `ttl` in `connect-mongo` is in seconds. They should be kept in sync to avoid mismatched expiry behavior.

---

## Common Mistakes and How to Avoid Them

### Using `new MongoStore()` Instead of `MongoStore.create()`

v4 removed the constructor syntax. The only supported way to instantiate the store in v4+ is `MongoStore.create({})`.

### Mismatched `ttl` and `cookie.maxAge` Units

`ttl` is seconds. `cookie.maxAge` is milliseconds. Setting them to the same number without accounting for units results in one expiring 1000x sooner than the other.

### Setting `resave: true` with `touchAfter`

`resave: true` causes `express-session` to save the session on every request. This overrides the lazy-update behavior of `touchAfter`, defeating its purpose.

### Not Handling the `error` Event

If the store emits an `error` event and nothing handles it, Node.js will throw an unhandled error. Always attach an error listener.

```js
store.on('error', (err) => {
  console.error('Session store error:', err);
});
```

### Storing Non-Serializable Values in the Session

When `stringify: true` (default), session data passes through `JSON.stringify`. Values that do not survive that round-trip (class instances, functions, circular references, `undefined`) will be lost or cause errors.

### Using `stringify: false` Without Validating BSON Compatibility

When `stringify: false`, session data is stored as BSON. Types not supported by BSON (such as `Map`, `Set`, or custom class instances) may not serialize correctly.

---

## Querying Sessions Directly

When `stringify: false`, individual fields inside the session are stored as real document fields and are queryable with the MongoDB driver or Mongoose.

```js
const db = client.db('mydb');
const sessions = db.collection('sessions');

// Find all sessions belonging to a specific user
const userSessions = await sessions.find({
  'session.userId': 42
}).toArray();

// Count active sessions
const count = await sessions.countDocuments({
  expires: { $gt: new Date() }
});
```

With `stringify: true` (default), the session field is a JSON string and individual fields cannot be queried this way.

---

## Invalidating Sessions Server-Side

To log out a user from all their sessions server-side (for example, after a password change), query the collection directly and delete matching documents, or use the store methods if you track session IDs.

```js
// With stringify: false — query by user ID
await db.collection('sessions').deleteMany({
  'session.userId': targetUserId
});

// With stringify: true — no direct query possible;
// you must track session IDs in your own user document
```

---

## MongoDB Index

`connect-mongo` creates a TTL index on the `expires` field automatically:

```js
{ expires: 1 }, { expireAfterSeconds: 0 }
```

This index is created on first use if it does not already exist. Do not drop it; MongoDB uses it for automatic expiration when `autoRemove` is `'native'`.

---

## Version History Notes

- v4.0.0 — removed `new MongoStore()` constructor; introduced `MongoStore.create()`. Dropped support for Node < 12 and MongoDB driver v2.
- v4.4.0 — added `crypto` option for at-rest encryption.
- v5.x — requires Node 16+; check the release notes before upgrading from v4.

[Unverified] — version-specific behavior beyond what is documented in the official README may vary. Always verify against the installed version's changelog.

---

## Further Reading

- npm package: `connect-mongo` by Jared Hanson and contributors
- Repository: https://github.com/jdesboeufs/connect-mongo
- `express-session` documentation: https://github.com/expressjs/session
- MongoDB TTL indexes: https://www.mongodb.com/docs/manual/core/index-ttl/