# Comprehensive Guide to connect-redis

`connect-redis` is a Redis-backed session store for use with the `express-session` middleware in Node.js. It allows Express applications to persist session data in Redis rather than in-memory, which is volatile and unsuitable for production.

---

## What connect-redis Does

By default, `express-session` stores sessions in memory using a `MemoryStore`. This works during development but has serious drawbacks in production: sessions are lost on restart, and the store does not scale across multiple processes or servers.

`connect-redis` replaces `MemoryStore` with a Redis-backed store. Sessions are serialized and saved to Redis with configurable TTLs (time-to-live), making them durable and shareable across server instances.

---

## Version History and Breaking Changes

`connect-redis` has undergone significant API changes across major versions. The version you use determines how you initialize the store.

### v7 and above (current)

Starting from v7, the library dropped support for the legacy callback-based initialization pattern. The `session` object is no longer passed into the constructor. Instead, you pass a Redis client directly.

```js
import RedisStore from "connect-redis";
import session from "express-session";
import { createClient } from "redis";

const redisClient = createClient();
await redisClient.connect();

const store = new RedisStore({ client: redisClient });

app.use(
  session({
    store,
    secret: "your-secret",
    resave: false,
    saveUninitialized: false,
  })
);
```

### v6 and below (legacy)

In older versions, the store class was obtained by passing `session` into a function:

```js
const session = require("express-session");
const RedisStore = require("connect-redis")(session);
const redis = require("redis");

const client = redis.createClient();

app.use(
  session({
    store: new RedisStore({ client }),
    secret: "your-secret",
    resave: false,
    saveUninitialized: false,
  })
);
```

> **Important:** Do not mix v6 patterns with v7+. They are incompatible. Check `package.json` or `npm list connect-redis` to confirm your installed version.

---

## Prerequisites

- Node.js (v14+ recommended for top-level `await` and ESM support)
- A running Redis instance (local, Docker, or hosted such as Redis Cloud, Upstash, AWS ElastiCache)
- `express` and `express-session` installed

---

## Installation

```bash
npm install connect-redis express-session redis
```

This installs:

- `connect-redis` — the session store adapter
- `express-session` — the session middleware
- `redis` — the official Node.js Redis client (v4+)

You can also use `ioredis` as the Redis client instead of the official `redis` package. Both are supported.

---

## Basic Setup (CommonJS)

```js
const express = require("express");
const session = require("express-session");
const RedisStore = require("connect-redis").default;
const { createClient } = require("redis");

const app = express();

const redisClient = createClient({
  url: "redis://localhost:6379",
});

redisClient.on("error", (err) => console.error("Redis client error:", err));

(async () => {
  await redisClient.connect();

  app.use(
    session({
      store: new RedisStore({ client: redisClient }),
      secret: process.env.SESSION_SECRET,
      resave: false,
      saveUninitialized: false,
      cookie: {
        secure: process.env.NODE_ENV === "production",
        httpOnly: true,
        maxAge: 1000 * 60 * 60 * 24, // 1 day in ms
      },
    })
  );

  app.listen(3000, () => console.log("Server running on port 3000"));
})();
```

> **Note on `.default`:** In CommonJS environments with `connect-redis` v7+, you must access `.default` on the `require()` call because the package ships as an ES module.

---

## Basic Setup (ESM / TypeScript)

```ts
import express from "express";
import session from "express-session";
import RedisStore from "connect-redis";
import { createClient } from "redis";

const app = express();

const redisClient = createClient({ url: "redis://localhost:6379" });
redisClient.on("error", (err) => console.error("Redis error:", err));
await redisClient.connect();

app.use(
  session({
    store: new RedisStore({ client: redisClient }),
    secret: process.env.SESSION_SECRET!,
    resave: false,
    saveUninitialized: false,
    cookie: {
      secure: true,
      httpOnly: true,
      sameSite: "lax",
      maxAge: 86400000,
    },
  })
);
```

---

## RedisStore Options

These are the options you can pass to `new RedisStore({...})`:

### `client` (required)

The Redis client instance. Must be connected before being passed in. Supports `redis` (v4+) and `ioredis`.

```js
new RedisStore({ client: redisClient })
```

### `prefix`

A string prefix applied to all session keys stored in Redis. Defaults to `"sess:"`.

```js
new RedisStore({ client: redisClient, prefix: "myapp:sess:" })
```

This is useful if you share one Redis instance between multiple applications or services.

### `ttl`

Time-to-live for sessions in Redis, in seconds. If not set, `connect-redis` derives the TTL from `cookie.maxAge`. If neither is set, sessions do not expire in Redis automatically.

```js
new RedisStore({ client: redisClient, ttl: 86400 }) // 1 day
```

> [Inference] If `cookie.maxAge` is set and `ttl` is not, `connect-redis` converts `maxAge` (milliseconds) to seconds for the Redis TTL. This is based on documented behavior, but exact handling may vary by version.

### `disableTouch`

By default, `connect-redis` calls Redis `EXPIRE` on every session read to reset the TTL. Setting `disableTouch: true` disables this behavior, meaning session TTLs are only set at creation.

```js
new RedisStore({ client: redisClient, disableTouch: true })
```

This can reduce Redis write load in high-traffic applications, at the cost of sessions potentially expiring before the user is done.

### `disableExpiration` (v7.2+)

When set to `true`, prevents `connect-redis` from setting any TTL on session keys. Sessions persist in Redis until manually deleted. Use with caution.

```js
new RedisStore({ client: redisClient, disableExpiration: true })
```

### `serializer`

An object with `parse` and `stringify` methods used to serialize/deserialize session data. Defaults to `JSON`.

```js
new RedisStore({
  client: redisClient,
  serializer: {
    parse: JSON.parse,
    stringify: JSON.stringify,
  },
})
```

You can supply a custom serializer if you need to handle types that JSON does not support natively (e.g., `Date`, `Map`, `Set`), using libraries such as `superjson` or `devalue`.

---

## Using ioredis Instead of redis

`connect-redis` also works with `ioredis`. The setup is largely the same, but `ioredis` connects automatically on instantiation and does not require an explicit `.connect()` call.

```js
import RedisStore from "connect-redis";
import session from "express-session";
import Redis from "ioredis";

const redisClient = new Redis({
  host: "localhost",
  port: 6379,
});

app.use(
  session({
    store: new RedisStore({ client: redisClient }),
    secret: process.env.SESSION_SECRET,
    resave: false,
    saveUninitialized: false,
  })
);
```

---

## Connecting to a Remote Redis Instance

### Redis Cloud / Upstash / Hosted Redis

```js
const redisClient = createClient({
  url: "rediss://:<password>@<host>:<port>",
});
```

Note the `rediss://` scheme (with double `s`) for TLS connections. Most hosted Redis providers require TLS.

### Redis with Username and Password (ACL)

```js
const redisClient = createClient({
  url: "redis://username:password@localhost:6379",
});
```

### Redis Sentinel

```js
const redisClient = createClient({
  sentinels: [{ host: "sentinel-host", port: 26379 }],
  name: "mymaster",
});
```

> [Unverified] Sentinel support behavior may differ between the `redis` and `ioredis` clients. Verify with the respective client's documentation.

### Redis Cluster

```js
import { createCluster } from "redis";

const redisClient = createCluster({
  rootNodes: [
    { url: "redis://node1:6379" },
    { url: "redis://node2:6380" },
  ],
});
await redisClient.connect();
```

---

## Session Options in express-session

These options are passed to `express-session`, not to `RedisStore`, but they interact closely with session behavior.

### `secret`

A string or array of strings used to sign the session ID cookie. Use a long, random, environment-variable-sourced value in production. Never hardcode it.

### `resave`

Set to `false` for most use cases. When `false`, the session is only written back to the store if it was modified. Reduces unnecessary writes.

### `saveUninitialized`

Set to `false` to avoid storing empty sessions. This also helps comply with laws requiring consent before storing cookies.

### `cookie.secure`

Set to `true` in production to send cookies only over HTTPS. Requires that your server is behind a TLS-terminating proxy (e.g., Nginx, a load balancer).

If your app is behind a proxy, also set:

```js
app.set("trust proxy", 1);
```

Without this, Express may not correctly detect the HTTPS connection and `secure` cookies will not be sent.

### `cookie.httpOnly`

Set to `true` to prevent client-side JavaScript from reading the session cookie.

### `cookie.sameSite`

Controls cross-site cookie behavior. Options: `"strict"`, `"lax"`, `"none"`. Use `"none"` only with `secure: true`, for cross-origin scenarios.

---

## Error Handling

### Handling Redis Connection Errors

Always attach an error listener to the Redis client to prevent unhandled error events from crashing your process:

```js
redisClient.on("error", (err) => {
  console.error("Redis connection error:", err);
});
```

### What Happens When Redis Is Unavailable

[Inference] If Redis becomes unavailable mid-request, session operations (read/write) will likely throw or time out, which can crash the request handler if not caught. This is inferred from how the Node.js `redis` client handles connection failures; actual behavior is not guaranteed and depends on client configuration and error handling in your application.

To handle this defensively, consider wrapping session-dependent routes or adding error middleware:

```js
app.use((err, req, res, next) => {
  if (err.code === "ECONNREFUSED") {
    return res.status(503).json({ error: "Service temporarily unavailable" });
  }
  next(err);
});
```

---

## Inspecting and Debugging Sessions in Redis

You can inspect session data directly in Redis using the CLI:

```bash
redis-cli keys "sess:*"
redis-cli get "sess:<session-id>"
```

The value is typically a JSON string. If you used a custom serializer, the format will differ.

To check TTL remaining on a session:

```bash
redis-cli ttl "sess:<session-id>"
```

---

## Destroying Sessions

From within a route, you can destroy a session programmatically:

```js
app.post("/logout", (req, res) => {
  req.session.destroy((err) => {
    if (err) {
      return res.status(500).json({ error: "Could not log out" });
    }
    res.clearCookie("connect.sid");
    res.redirect("/");
  });
});
```

`session.destroy()` removes the session from Redis and clears the in-memory object. `clearCookie` removes the client-side cookie.

---

## Regenerating Session ID

After privilege escalation (e.g., login), regenerate the session ID to prevent session fixation attacks:

```js
app.post("/login", (req, res) => {
  // authenticate user...
  req.session.regenerate((err) => {
    if (err) return next(err);
    req.session.user = authenticatedUser;
    req.session.save((err) => {
      if (err) return next(err);
      res.redirect("/dashboard");
    });
  });
});
```

`regenerate` creates a new session ID and deletes the old one from Redis. `save` forces the new session to be written immediately.

---

## TypeScript Usage

`connect-redis` ships with its own type definitions. No separate `@types` package is needed.

```ts
import RedisStore from "connect-redis";
import { RedisClientType } from "redis";

const store = new RedisStore({
  client: redisClient as RedisClientType,
  prefix: "app:sess:",
  ttl: 3600,
});
```

For `express-session` types, `req.session` is typed as `Session & Partial<SessionData>`. To add custom properties:

```ts
declare module "express-session" {
  interface SessionData {
    user: {
      id: string;
      role: string;
    };
  }
}
```

---

## Common Pitfalls

### Forgetting to await `redisClient.connect()`

With the official `redis` v4+ client, you must explicitly call and await `.connect()` before using the client. Passing an unconnected client to `RedisStore` will result in errors on session operations.

### Using `.default` in CommonJS

In CommonJS with `connect-redis` v7+:

```js
// Correct
const RedisStore = require("connect-redis").default;

// Incorrect — will throw "RedisStore is not a constructor"
const RedisStore = require("connect-redis");
```

### Not Setting `trust proxy`

If running behind a reverse proxy and using `cookie.secure: true`, Express needs to trust the proxy to correctly detect HTTPS:

```js
app.set("trust proxy", 1);
```

Without this, the cookie will not be sent and sessions will not persist on the client.

### Session Not Persisting After Redirect

If you modify the session and immediately redirect, the session may not be written before the redirect completes. Call `req.session.save()` explicitly before redirecting:

```js
req.session.user = user;
req.session.save((err) => {
  if (err) return next(err);
  res.redirect("/dashboard");
});
```

### TTL Set Too Low

If `cookie.maxAge` or `ttl` is set to a low value, sessions may expire in Redis before the user's cookie expires in the browser. The user will appear logged in (cookie exists) but have no server-side session, causing unexpected authentication failures.

---

## Security Considerations

- Store `SESSION_SECRET` in an environment variable. Never commit it to source control.
- Use a long, random secret (32+ characters).
- Set `cookie.secure: true` and `cookie.httpOnly: true` in production.
- Set `saveUninitialized: false` to avoid pre-authentication session storage.
- Regenerate the session ID after login to mitigate session fixation.
- Consider using Redis ACLs or AUTH to restrict access to the session store.
- If using a shared Redis instance, use a meaningful `prefix` to namespace session keys.

---

## Compatibility Matrix

|connect-redis|redis (npm)|ioredis|express-session|Node.js|
|---|---|---|---|---|
|v7+|v4+|v4+|v1.17+|v14+|
|v6|v3|v4|v1.x|v10+|

> [Unverified] This table is based on general documentation and community references. Verify exact compatibility with the official `connect-redis` README for your specific versions.

---

## Minimal Production Checklist

- Redis client created and connected before app starts
- `SESSION_SECRET` loaded from environment, not hardcoded
- `cookie.secure: true` with `app.set("trust proxy", 1)` behind proxy
- `cookie.httpOnly: true`
- `resave: false` and `saveUninitialized: false`
- `ttl` or `cookie.maxAge` explicitly set
- Error listener attached to Redis client
- Session ID regenerated on login
- Session explicitly destroyed on logout