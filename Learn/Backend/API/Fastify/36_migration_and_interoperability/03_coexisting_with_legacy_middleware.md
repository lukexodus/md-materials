## Coexisting with Legacy Middleware in Fastify

Fastify's architecture is fundamentally different from Express and Koa — it does not natively support the `(req, res, next)` middleware signature. However, real-world migration scenarios often require running legacy Express-style middleware alongside Fastify during a transition period. Fastify provides an official compatibility layer for this purpose.

---

### The Compatibility Problem

Express middleware expects:

- `req` as a Node.js `IncomingMessage` with Express extensions (e.g., `req.params`, `req.body` already parsed)
- `res` as a Node.js `ServerResponse` with Express extensions (e.g., `res.json()`, `res.send()`)
- A `next()` callback to pass control

Fastify's request/reply objects wrap the raw Node.js objects and expose a different API. Passing Fastify's objects directly into Express middleware will cause failures or silent misbehavior. [Inference: The exact failure mode depends on which properties the middleware accesses; behavior may vary.]

---

### `@fastify/middie` — The Official Middleware Compatibility Layer

The `@fastify/middie` plugin provides a Connect/Express-compatible middleware engine for Fastify. It does not patch Fastify's request/reply objects with Express methods — it only enables the `(req, res, next)` call signature to function.

bash

```bash
npm install @fastify/middie
```

**Registration:**

typescript

```typescript
import Fastify from 'fastify'
import middie from '@fastify/middie'

const app = Fastify({ logger: true })

await app.register(middie)

// Now use .use() to mount legacy middleware
app.use(legacyMiddlewareFunction)

await app.listen({ port: 3000 })
```

After registering `middie`, Fastify exposes an `app.use()` method that accepts standard Connect-style middleware.

---

### Scoping Middleware with Path Prefixes

`app.use()` accepts an optional path prefix, limiting middleware execution to matching routes:

typescript

```typescript
await app.register(middie)

app.use('/api/v1', legacyAuthMiddleware)
app.use('/admin', legacySessionMiddleware)
```

**Key Points:**

- The prefix match is prefix-based, not exact — `/api/v1` will match `/api/v1/users`, `/api/v1/orders`, etc.
- Middleware registered without a prefix runs on every request.
- [Inference] Ordering of `app.use()` calls affects execution order within the same scope, consistent with Connect behavior — though edge cases may vary.

---

### `@fastify/express` — Full Express Compatibility

If the legacy middleware relies on Express-specific augmentations (`req.app`, `res.json()`, `req.route`, etc.), `@fastify/middie` alone is insufficient. Use `@fastify/express` instead, which mounts a full Express application inside Fastify:

bash

```bash
npm install @fastify/express
```

typescript

```typescript
import Fastify from 'fastify'
import expressPlugin from '@fastify/express'
import express from 'express'
import cors from 'cors'
import helmet from 'helmet'

const app = Fastify({ logger: true })

await app.register(expressPlugin)

// Use Express middleware directly
app.use(cors())
app.use(helmet())
app.use(express.json())

await app.listen({ port: 3000 })
```

**Key Points:**

- `@fastify/express` patches the raw Node.js `req`/`res` objects with Express-compatible properties before passing them to middleware.
- This has a measurable performance cost compared to native Fastify hooks. [Unverified: exact overhead figures — benchmark in your specific environment.]
- This approach is intended as a transitional bridge, not a permanent architecture.

---

### What Legacy Middleware Cannot Access

Even with `@fastify/middie` or `@fastify/express`, certain Fastify-specific features are not available inside legacy middleware:

| Feature | Available in Legacy Middleware? |
| --- | --- |
| `request.params` (Fastify) | No — use `req.params` if Express-patched |
| `reply.send()` | No |
| Fastify lifecycle hooks | No |
| Decorators on `request`/`reply` | No |
| Schema validation results | No |
| `request.log` (Fastify logger) | No — `req.log` may not exist |

[Inference] Attempting to access Fastify-specific objects from within legacy middleware will likely result in `undefined` or a runtime error, depending on which property is accessed. Behavior is not guaranteed to be consistent across versions.

---

### Execution Order: Hooks vs. Middleware

When `middie` is registered, middleware registered via `app.use()` runs during the `onRequest` lifecycle phase, before Fastify's own route handlers but alongside other `onRequest` hooks.

```
Incoming Request
       │
  [onRequest hooks]  ◄── middie middleware runs here
       │
  [preParsing hooks]
       │
  [Body parsing]
       │
  [preValidation hooks]
       │
  [Schema validation]
       │
  [preHandler hooks]
       │
  [Route handler]
       │
  [onSend hooks]
       │
  Response sent
```

**Key Points:**

- Middleware running at `onRequest` does not have access to the parsed body — body parsing has not occurred yet.
- If legacy middleware depends on a parsed body (e.g., it reads `req.body`), you must parse the body before the middleware runs, or migrate that logic to a Fastify `preHandler` hook.
- [Inference] Registering `middie` inside a scoped plugin will limit middleware execution to that plugin's route scope, consistent with Fastify's encapsulation model — verify behavior for your plugin nesting structure.

---

### Accessing the Parsed Body in Middleware

Because `app.use()` middleware runs before body parsing, `req.body` will be `undefined` by default. Workarounds:

**Option 1 — Use a body-parsing middleware inside `app.use()`:**

typescript

```typescript
import bodyParser from 'body-parser'

await app.register(middie)
app.use(bodyParser.json()) // parse before other middleware
app.use(legacyMiddlewareThatNeedsBody)
```

**Option 2 — Migrate the logic to a `preHandler` hook:**

typescript

```typescript
app.addHook('preHandler', async (request, reply) => {
  // request.body is available here — parsed by Fastify
  const body = request.body as Record<string, unknown>
  // replicate legacy middleware logic here
})
```

Option 2 is preferred for new code during migration. Option 1 preserves the existing middleware without modification.

---

### Encapsulation and Scoped Middleware Registration

Fastify's plugin system is encapsulation-first. Registering `middie` inside a scoped plugin means its `app.use()` calls are scoped to that plugin's routes:

typescript

```typescript
import fp from 'fastify-plugin'

// NOT wrapped in fp — middleware is scoped to this plugin only
async function legacyRoutes(app: FastifyInstance) {
  await app.register(middie)
  app.use(legacyAuthMiddleware)

  app.get('/legacy/resource', async (request, reply) => {
    return { data: 'protected' }
  })
}

app.register(legacyRoutes, { prefix: '/v1' })
```

Routes outside `legacyRoutes` will not be affected by `legacyAuthMiddleware`.

If you wrap `legacyRoutes` with `fastify-plugin` (`fp`), the `app.use()` registration escapes encapsulation and applies globally. [Inference] This is consistent with how all decorators and hooks behave when `fp` is used — confirm behavior in your Fastify version.

---

### Common Legacy Middleware and Migration Status

| Middleware | `@fastify/middie` sufficient? | Native Fastify equivalent |
| --- | --- | --- |
| `cors` | Yes | `@fastify/cors` |
| `helmet` | Yes | `@fastify/helmet` |
| `morgan` (logging) | Yes | Built-in Pino logger |
| `body-parser` | Yes | Built-in — `Content-Type` parsing |
| `express-session` | Requires `@fastify/express` | `@fastify/session` |
| `passport` | Requires `@fastify/express` | `@fastify/passport` |
| `multer` (file upload) | Requires `@fastify/express` | `@fastify/multipart` |
| Custom auth middleware | Depends on req/res usage | Migrate to `preHandler` hook |

---

### Practical Migration Pattern

A realistic incremental migration keeps legacy middleware running while new routes use native Fastify patterns:

typescript

```typescript
import Fastify from 'fastify'
import middie from '@fastify/middie'
import fp from 'fastify-plugin'
import { legacyRateLimiter, legacyRequestLogger } from './legacy/middleware'

const app = Fastify({ logger: true })

// Phase 1: Register compat layer globally
await app.register(fp(async (instance) => {
  await instance.register(middie)
  instance.use(legacyRequestLogger) // keep until Pino hooks are configured
  instance.use('/api/v1', legacyRateLimiter) // keep until @fastify/rate-limit is configured
}))

// Phase 2: New routes use native patterns only
app.register(async (instance) => {
  instance.addHook('preHandler', nativeAuthHook)

  instance.get('/api/v2/users', async (request, reply) => {
    return { users: [] }
  })
}, { prefix: '/api/v2' })

await app.listen({ port: 3000 })
```

**Key Points:**

- Legacy middleware remains on `/api/v1` while `/api/v2` uses Fastify-native hooks.
- This allows progressive migration without a full rewrite.
- Remove `middie` registrations as each middleware is replaced with a native equivalent.

---

### Performance Considerations

Using `@fastify/middie` or `@fastify/express` introduces overhead compared to native Fastify hooks:

- Each middleware function involves additional function calls and object traversal not present in native hooks.
- `@fastify/express` has higher overhead than `@fastify/middie` because it patches req/res with Express augmentations on every request.
- [Unverified] Specific throughput impact varies by middleware and environment — measure with a profiler or load testing tool (e.g., `autocannon`) in your deployment context.

The performance cost is generally acceptable during migration but is a reason to complete the migration rather than leave it indefinitely.

---

### Debugging Middleware Integration Issues

**Symptom: Middleware never calls `next()`**

- Check whether the middleware throws synchronously without calling `next(err)` or `next()`.
- Some legacy middleware expects specific `req` properties (e.g., `req.app`) that are absent without `@fastify/express`.

**Symptom: `req.body` is `undefined` inside middleware**

- Body parsing has not occurred at the `onRequest` phase. Add a body parser before the middleware or migrate to `preHandler`.

**Symptom: Middleware runs on routes where it should not**

- Confirm the path prefix passed to `app.use()`.
- Confirm whether `middie` was registered inside or outside a scoped plugin.
- Confirm whether `fastify-plugin` (`fp`) was used, which escapes encapsulation.

**Symptom: Response already sent / headers already written**

- Legacy middleware called `res.end()` or `res.send()` before Fastify's route handler ran.
- Refactor the middleware to call `next()` instead of terminating the response, or convert it to a Fastify hook that calls `reply.send()`.

---

**Related Topics:**

- Migrating Express route handlers to Fastify route handlers
- `@fastify/passport` — replacing Passport.js middleware
- `@fastify/session` — replacing `express-session`
- `@fastify/cors` and `@fastify/helmet` — replacing middleware with plugins
- Fastify plugin encapsulation and `fastify-plugin` (`fp`) behavior
- `onRequest` hook patterns as middleware replacements
- Load testing Fastify with `autocannon` to benchmark migration impact