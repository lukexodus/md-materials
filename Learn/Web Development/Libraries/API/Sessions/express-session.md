# `express-session` 

## What It Is

`express-session` is a session middleware for Express.js. It creates a session object on `req.session` that persists across HTTP requests for a given client, using a session ID stored in a cookie.

It does **not** store session data in the cookie itself — only the session ID. Session data lives on the server (or in a connected store).

---

## Installation

```bash
npm install express-session
```

---

## Basic Setup

```js
const express = require('express');
const session = require('express-session');

const app = express();

app.use(session({
  secret: 'your-secret-key',
  resave: false,
  saveUninitialized: false,
  cookie: { secure: false }
}));
```

---

## Configuration Options

### `secret` (required)

Used to sign the session ID cookie. Prevents clients from tampering with the cookie value.

Accepts a string or an array of strings. When an array is provided, only the first secret is used to sign new sessions; all are used for verification (enabling secret rotation).

```js
secret: ['new-secret', 'old-secret']
```

### `resave`

Forces the session to be saved back to the session store on every request, even if it was not modified.

- `false` — recommended. Only saves if the session was modified.
- `true` — can cause race conditions under concurrent requests.

### `saveUninitialized`

Controls whether a new, unmodified session is saved to the store.

- `false` — recommended for login-gated apps. Reduces store pollution and complies better with consent laws (GDPR).
- `true` — saves a session even if nothing was written to it.

### `cookie`

Controls the session cookie sent to the client.

|Property|Type|Description|
|---|---|---|
|`httpOnly`|boolean|Bars JavaScript access to the cookie. Defaults to `true`.|
|`secure`|boolean|Cookie sent only over HTTPS. Set `true` in production.|
|`maxAge`|number|Expiry in milliseconds from now.|
|`expires`|Date|Absolute expiry date. `maxAge` takes precedence if both are set.|
|`sameSite`|string/boolean|CSRF mitigation. Values: `'strict'`, `'lax'`, `'none'`.|
|`domain`|string|Restricts cookie to a domain.|
|`path`|string|Cookie path. Defaults to `'/'`.|

```js
cookie: {
  httpOnly: true,
  secure: true,
  maxAge: 1000 * 60 * 60 * 24, // 24 hours
  sameSite: 'lax'
}
```

### `name`

Name of the session ID cookie. Defaults to `'connect.sid'`. Changing this is a minor obscurity measure.

```js
name: 'sid'
```

### `store`

Where sessions are stored. Defaults to `MemoryStore`, which is only suitable for development. See the **Stores** section below.

### `genid`

A function that returns a custom session ID string. Receives `req` as an argument. The default uses `uid-safe` to generate a random ID.

```js
genid: (req) => require('uuid').v4()
```

### `rolling`

If `true`, the cookie expiration is reset on every response, keeping the session alive as long as the user is active. Defaults to `false`.

### `unset`

Controls what happens to the session in the store when `req.session` is deleted or set to `null`.

- `'keep'` — keeps the session in the store (default).
- `'destroy'` — deletes the session from the store.

---

## The `req.session` Object

Once the middleware runs, `req.session` is available in all subsequent middleware and route handlers.

### Reading and writing

```js
// Write
req.session.userId = 42;
req.session.cart = ['item1', 'item2'];

// Read
console.log(req.session.userId);
```

### `req.session.id`

The session ID (read-only alias of `req.sessionID`).

### `req.session.cookie`

A live reference to the session's cookie settings. You can modify per-session cookie properties here.

```js
// Extend session for "remember me"
req.session.cookie.maxAge = 1000 * 60 * 60 * 24 * 30; // 30 days
```

### `req.session.save(callback)`

Explicitly saves the session to the store. Normally called automatically, but necessary when redirecting immediately after writing to the session.

```js
req.session.userId = user.id;
req.session.save((err) => {
  if (err) return next(err);
  res.redirect('/dashboard');
});
```

### `req.session.reload(callback)`

Reloads the session data from the store, discarding any unsaved in-memory changes.

```js
req.session.reload((err) => {
  if (err) return next(err);
  // req.session is now fresh from the store
});
```

### `req.session.destroy(callback)`

Deletes the session from the store and clears `req.session`. The cookie is **not** automatically cleared — you must do that manually if needed.

```js
req.session.destroy((err) => {
  res.clearCookie('connect.sid');
  res.redirect('/login');
});
```

### `req.session.regenerate(callback)`

Creates a new session ID, copies existing session data, and saves it. Used to prevent session fixation attacks — regenerate after login.

```js
req.session.regenerate((err) => {
  if (err) return next(err);
  req.session.userId = user.id;
  res.redirect('/dashboard');
});
```

### `req.session.touch()`

Resets the cookie's `maxAge` to keep it alive without saving other data. Useful in conjunction with `rolling: false`.

---

## Session Stores

### Default: `MemoryStore`

Stores sessions in process memory. Ships with `express-session`.

**Do not use in production:**

- Memory leaks over time (no eviction by default).
- Sessions are lost on process restart.
- Does not work across multiple server instances.

### Compatible Stores

These are third-party packages that implement the required store interface.

|Store|Package|
|---|---|
|Redis|`connect-redis`|
|MongoDB|`connect-mongo`|
|PostgreSQL|`connect-pg-simple`|
|MySQL / MariaDB|`express-mysql-session`|
|SQLite|`better-sqlite3-session-store`|
|Memcached|`connect-memcached`|
|File system|`session-file-store`|

### Using `connect-redis` (example)

```js
const session = require('express-session');
const RedisStore = require('connect-redis').default;
const { createClient } = require('redis');

const redisClient = createClient();
await redisClient.connect();

app.use(session({
  store: new RedisStore({ client: redisClient }),
  secret: 'your-secret',
  resave: false,
  saveUninitialized: false,
  cookie: { secure: true }
}));
```

### Using `connect-mongo` (example)

```js
const MongoStore = require('connect-mongo');

app.use(session({
  store: MongoStore.create({ mongoUrl: 'mongodb://localhost/sessions' }),
  secret: 'your-secret',
  resave: false,
  saveUninitialized: false
}));
```

### Custom Store

You can write your own store by extending `session.Store` and implementing `get`, `set`, and `destroy`. Optionally implement `touch` and `all`.

```js
const session = require('express-session');

class MyStore extends session.Store {
  get(sid, callback) { /* retrieve session */ }
  set(sid, sessionData, callback) { /* save session */ }
  destroy(sid, callback) { /* delete session */ }
  touch(sid, sessionData, callback) { /* refresh TTL */ }
}
```

---

## Security Considerations

### Sign your cookies

The `secret` option signs the session ID cookie, allowing the server to detect tampering. This does not encrypt the ID — it only validates its integrity.

### Use `secure: true` in production

Ensures the session cookie is only transmitted over HTTPS.

When running behind a reverse proxy (nginx, etc.), tell Express to trust the proxy:

```js
app.set('trust proxy', 1);
// Then:
cookie: { secure: true }
```

### Session fixation

Always call `req.session.regenerate()` after a privilege change (login, role escalation). This invalidates the pre-authentication session ID.

### `sameSite`

Set `sameSite: 'lax'` or `'strict'` to reduce CSRF exposure. `'none'` requires `secure: true`.

### Secret rotation

Pass an array to `secret` to rotate secrets without immediately invalidating all existing sessions:

```js
secret: ['current-secret', 'previous-secret']
```

### `httpOnly`

Leave `httpOnly: true` (the default). This bars `document.cookie` access from JavaScript running in the browser.

### Short session lifetimes

Use `maxAge` to set a reasonable expiration. Long-lived sessions increase the risk window if a session ID is compromised.

---

## Common Patterns

### Login flow

```js
app.post('/login', async (req, res, next) => {
  const user = await authenticate(req.body);
  if (!user) return res.status(401).send('Invalid credentials');

  req.session.regenerate((err) => {
    if (err) return next(err);
    req.session.userId = user.id;
    req.session.save((err) => {
      if (err) return next(err);
      res.redirect('/dashboard');
    });
  });
});
```

### Logout flow

```js
app.post('/logout', (req, res, next) => {
  req.session.destroy((err) => {
    if (err) return next(err);
    res.clearCookie('connect.sid');
    res.redirect('/login');
  });
});
```

### Auth guard middleware

```js
function requireAuth(req, res, next) {
  if (!req.session.userId) return res.redirect('/login');
  next();
}

app.get('/dashboard', requireAuth, (req, res) => {
  res.send(`Welcome, user ${req.session.userId}`);
});
```

### Flash messages (manual)

```js
// Set
req.session.flash = { type: 'error', message: 'Invalid credentials' };

// Read and clear
app.get('/login', (req, res) => {
  const flash = req.session.flash;
  delete req.session.flash;
  res.render('login', { flash });
});
```

---

## Debugging

Set the `DEBUG` environment variable to see internal logs:

```bash
DEBUG=express-session node app.js
```

---

## Interaction with Body Parser

`express-session` does not depend on `body-parser`. It reads cookies from `req.headers.cookie` directly. However, place `express-session` after `cookie-parser` if you use that, or omit `cookie-parser` entirely — they can conflict when both try to read the same cookie.

---

## Full Minimal Example

```js
const express = require('express');
const session = require('express-session');

const app = express();
app.use(express.urlencoded({ extended: true }));

app.use(session({
  secret: process.env.SESSION_SECRET,
  resave: false,
  saveUninitialized: false,
  cookie: {
    httpOnly: true,
    secure: process.env.NODE_ENV === 'production',
    maxAge: 1000 * 60 * 60 * 2, // 2 hours
    sameSite: 'lax'
  }
}));

app.post('/login', (req, res, next) => {
  // assume validateUser() is defined elsewhere
  const user = validateUser(req.body.username, req.body.password);
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

app.get('/dashboard', (req, res) => {
  if (!req.session.userId) return res.redirect('/login');
  res.send(`Session active for user ${req.session.userId}`);
});

app.post('/logout', (req, res, next) => {
  req.session.destroy((err) => {
    if (err) return next(err);
    res.clearCookie('connect.sid');
    res.redirect('/login');
  });
});

app.listen(3000);
```