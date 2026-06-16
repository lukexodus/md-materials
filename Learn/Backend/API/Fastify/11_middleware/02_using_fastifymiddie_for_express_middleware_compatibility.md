## Using @fastify/middie for Express Middleware Compatibility

### Overview

Fastify does not use the Express-style middleware signature `(req, res, next)` natively. Its plugin and hook system serves a similar purpose but is architecturally different. `@fastify/middie` is an official Fastify plugin that bridges this gap by enabling Express-compatible middleware to run inside a Fastify application without requiring a full migration away from existing middleware logic.

This is useful when adopting Fastify incrementally, reusing existing Express middleware, or integrating third-party packages that expose an Express-style interface.

---

### How @fastify/middie Works

`@fastify/middie` wraps Fastify's hook system — specifically the `onRequest` hook — to accept and execute middleware written in the `(req, res, next)` format. Internally it uses the [`middie`](https://github.com/fastify/middie) package, which is a minimal middleware runner built on [`reusify`](https://github.com/mcollina/reusify) for performance.

**Key Points:**
- Middleware registered via `middie` runs during the `onRequest` lifecycle phase
- The `req` and `res` objects passed to the middleware are Node.js's raw `http.IncomingMessage` and `http.ServerResponse`, not Fastify's decorated `request` and `reply` objects
- Fastify's own decorations and plugins are not available inside Express middleware running through `middie`

---

### Installation

```bash
npm install @fastify/middie
```

---

### Basic Registration

Register the plugin before calling `use()`. Like all Fastify plugins, `@fastify/middie` must be registered and awaited (or used with `fastify-plugin` patterns) before use.

```js
import Fastify from 'fastify'
import middie from '@fastify/middie'

const fastify = Fastify({ logger: true })

await fastify.register(middie)

// Now fastify.use() is available
fastify.use('/api', (req, res, next) => {
  console.log('Middleware hit:', req.url)
  next()
})

await fastify.listen({ port: 3000 })
```

**Key Points:**
- `fastify.use()` becomes available only after `@fastify/middie` is registered
- Attempting to call `fastify.use()` before registration will throw a runtime error
- The first argument to `fastify.use()` is an optional path prefix; omitting it applies the middleware globally

---

### Path-Scoped Middleware

```js
await fastify.register(middie)

fastify.use('/admin', (req, res, next) => {
  const token = req.headers['x-admin-token']
  if (!token) {
    res.statusCode = 401
    res.end('Unauthorized')
    return
  }
  next()
})
```

**Key Points:**
- Path matching is prefix-based, not exact — `/admin` matches `/admin/users`, `/admin/settings`, etc.
- This behavior mirrors Express's `app.use()` routing semantics

---

### Using Third-Party Express Middleware

A common use case is integrating existing npm packages that expose Express middleware.

```js
import Fastify from 'fastify'
import middie from '@fastify/middie'
import cors from 'cors'
import morgan from 'morgan'

const fastify = Fastify()

await fastify.register(middie)

fastify.use(cors({ origin: '*' }))
fastify.use(morgan('combined'))

fastify.get('/', async (request, reply) => {
  return { status: 'ok' }
})

await fastify.listen({ port: 3000 })
```

**Key Points:**
- `cors` and `morgan` here are standard Express middleware packages — they work without modification
- [Inference] Most Express middleware that only reads/writes HTTP headers or the request body and calls `next()` is likely compatible, though behavior may vary; test each package individually
- Middleware that depends on Express-specific properties (e.g., `req.app`, `res.json()`, `res.send()`) may not work correctly through `middie`, as those are not present on the raw Node.js objects

---

### Scoping Middleware with Fastify's Plugin System

Because Fastify's plugin system is encapsulated, `fastify.use()` registered inside a plugin scope applies only within that scope unless you use `fastify-plugin` to break encapsulation.

```js
import Fastify from 'fastify'
import middie from '@fastify/middie'
import fp from 'fastify-plugin'

const fastify = Fastify()

await fastify.register(middie)

// Scoped — middleware applies only to routes in this plugin
fastify.register(async function (instance) {
  instance.use((req, res, next) => {
    console.log('Scoped middleware')
    next()
  })

  instance.get('/scoped', async () => ({ scoped: true }))
})

// This route does NOT go through the scoped middleware
fastify.get('/unscoped', async () => ({ scoped: false }))

await fastify.listen({ port: 3000 })
```

---

### Middleware Execution Order

Middleware registered via `fastify.use()` executes during the `onRequest` hook phase, before route handlers and before Fastify's body parsing.

```
Request
  │
  ▼
onRequest hooks (middie middleware runs here)
  │
  ▼
preParsing hooks
  │
  ▼
Body parsing
  │
  ▼
preValidation hooks
  │
  ▼
Route handler
```

**Key Points:**
- Because middleware runs before body parsing, `req.body` is not populated inside Express middleware going through `middie`
- If your middleware needs request body access, use Fastify's `preHandler` hook instead, which runs after parsing

---

### Limitations and Considerations

#### Raw Node.js objects only

Inside `middie`-wrapped middleware, `req` and `res` are the raw Node.js objects. Fastify decorations added via `fastify.decorateRequest()` or `fastify.decorateReply()` are not accessible.

```js
// This will NOT work inside middie middleware:
fastify.use((req, res, next) => {
  console.log(req.myCustomDecoration) // undefined
  next()
})
```

#### No access to Fastify's reply methods

Express middleware running through `middie` must use raw Node.js response methods:

```js
fastify.use((req, res, next) => {
  // Correct — raw Node.js
  res.statusCode = 200
  res.setHeader('Content-Type', 'application/json')
  res.end(JSON.stringify({ ok: true }))

  // Incorrect — these don't exist here
  // reply.send({ ok: true })
})
```

#### Async middleware

`middie` does not natively support async middleware in the `async (req, res, next) => {}` form the same way some Express extensions do. [Inference] Errors thrown from async middleware may not be caught by Fastify's error handler reliably; it is advisable to wrap async logic in a try/catch and call `next(err)` explicitly.

```js
fastify.use(async (req, res, next) => {
  try {
    await someAsyncOperation()
    next()
  } catch (err) {
    next(err)
  }
})
```

---

### Comparison: @fastify/middie vs. @fastify/express

| Feature | @fastify/middie | @fastify/express |
|---|---|---|
| Purpose | Run Express middleware in Fastify | Run a full Express app inside Fastify |
| Overhead | Low | Higher |
| Express `req`/`res` extensions | No | Yes |
| Recommended for | Selective middleware reuse | Full Express compatibility layer |
| Migration use case | Partial | Full |

**Key Points:**
- Prefer `@fastify/middie` when you only need to reuse specific middleware
- `@fastify/express` mounts a full Express instance and carries considerably more overhead — use it only when a complete compatibility layer is necessary
- For greenfield Fastify projects, neither should be necessary; native Fastify hooks and plugins are the preferred approach

---

### When to Use @fastify/middie

- Migrating an Express application to Fastify incrementally and reusing existing middleware during the transition
- Integrating a third-party npm package that only exposes an Express middleware interface with no Fastify alternative
- Applying lightweight request interceptors (logging, basic header manipulation) during the `onRequest` phase without rewriting them as Fastify hooks

**Conclusion:** `@fastify/middie` is a practical compatibility bridge for situations where Express middleware must coexist with Fastify. It is not a substitute for Fastify's native plugin and hook system, and should be used with awareness of its constraints — particularly around object access, lifecycle placement, and async error handling. For new Fastify development, native hooks are preferred.