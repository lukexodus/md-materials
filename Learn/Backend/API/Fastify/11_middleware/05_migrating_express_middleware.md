## Migrating Express Middleware

### Overview

Migrating Express middleware to Fastify is not a mechanical one-to-one translation. The two frameworks have different architectural assumptions: Express uses a flat, sequential middleware chain operating on raw Node.js objects with framework-added properties, while Fastify uses a structured lifecycle with discrete hook phases, a plugin encapsulation model, and decorated request/reply objects. A successful migration requires understanding what each piece of Express middleware is doing and mapping that responsibility to the appropriate Fastify construct.

---

### Conceptual Mapping

Before touching code, identify what category each Express middleware belongs to. The category determines which Fastify construct replaces it.

| Express Pattern | Fastify Equivalent |
|---|---|
| `app.use(fn)` — global middleware | `fastify.addHook('onRequest', fn)` or `fastify.addHook('preHandler', fn)` |
| `app.use('/path', fn)` — path-scoped middleware | Scoped plugin with `addHook` |
| `app.use(express.json())` — body parsing | Built-in — Fastify parses JSON by default |
| `app.use(express.urlencoded())` — form parsing | `@fastify/formbody` plugin |
| `app.use(cors())` | `@fastify/cors` plugin |
| `app.use(helmet())` | `@fastify/helmet` plugin |
| `app.use(morgan())` | Fastify's built-in `logger` option or `onResponse` hook |
| `app.use(session())` | `@fastify/session` or `@fastify/secure-session` |
| `app.use(passport.initialize())` | `@fastify/passport` |
| `app.use(rateLimit())` | `@fastify/rate-limit` |
| `app.use(compression())` | `@fastify/compress` |
| Error middleware `(err, req, res, next)` | `fastify.setErrorHandler(fn)` |
| `req.body` | `request.body` (available from `preValidation` onward) |
| `res.json()` / `res.send()` | `reply.send()` |
| `res.status(code)` | `reply.code(code)` |
| `req.params` / `req.query` | `request.params` / `request.query` |

---

### Step 1 — Audit Existing Middleware

Before writing any Fastify code, list every `app.use()` call and classify each one:

1. **Has an official Fastify equivalent plugin** — replace with the plugin directly
2. **Is a well-known npm package with no Fastify plugin** — evaluate `@fastify/middie` as a temporary bridge
3. **Is custom application logic** — migrate to the appropriate hook phase
4. **Is an error handler** — migrate to `setErrorHandler`

---

### Step 2 — Replace Well-Supported Middleware with Official Plugins

For the most common middleware categories, Fastify maintains official plugins that integrate natively with its lifecycle. These are preferable to running Express middleware through `@fastify/middie`.

```js
// Express
const express = require('express')
const cors = require('cors')
const helmet = require('helmet')
const rateLimit = require('express-rate-limit')

const app = express()
app.use(express.json())
app.use(cors({ origin: 'https://example.com' }))
app.use(helmet())
app.use(rateLimit({ windowMs: 60_000, max: 100 }))
```

```js
// Fastify equivalent
import Fastify from 'fastify'
import cors from '@fastify/cors'
import helmet from '@fastify/helmet'
import rateLimit from '@fastify/rate-limit'

const fastify = Fastify()

// JSON parsing is built in — no registration needed

await fastify.register(cors, { origin: 'https://example.com' })
await fastify.register(helmet)
await fastify.register(rateLimit, { max: 100, timeWindow: '1 minute' })
```

**Key Points:**
- `express.json()` has no Fastify equivalent to register — JSON body parsing is active by default for requests with `Content-Type: application/json`
- Official `@fastify/*` plugins hook into Fastify's lifecycle correctly and support encapsulation; running the Express originals through `@fastify/middie` does not

---

### Step 3 — Migrate Custom Middleware to Hooks

Custom Express middleware typically performs one of a small set of tasks. Each maps to a specific Fastify hook.

#### Authentication / Token Validation

```js
// Express
app.use((req, res, next) => {
  const token = req.headers.authorization
  if (!token) return res.status(401).json({ error: 'Unauthorized' })
  req.user = verifyToken(token)
  next()
})
```

```js
// Fastify — onRequest (no body needed) or preHandler (body needed)
fastify.addHook('onRequest', async (request, reply) => {
  const token = request.headers.authorization
  if (!token) {
    reply.code(401).send({ error: 'Unauthorized' })
    return
  }
  request.user = verifyToken(token)
})
```

**Key Points:**
- `request.user` is accessible in route handlers after this hook runs
- If `verifyToken` needs `request.body`, use `preHandler` instead of `onRequest`
- Fastify's `request` object accepts arbitrary property assignment; [Inference] for TypeScript projects, augmenting the `FastifyRequest` interface is advisable for type safety, though this is a convention rather than a strict requirement

#### Request Logging / Timing

```js
// Express
app.use((req, res, next) => {
  req.startTime = Date.now()
  next()
})
```

```js
// Fastify
fastify.addHook('onRequest', async (request) => {
  request.startTime = Date.now()
})

fastify.addHook('onResponse', async (request, reply) => {
  fastify.log.info({
    url: request.url,
    method: request.method,
    statusCode: reply.statusCode,
    duration: Date.now() - request.startTime
  })
})
```

**Key Points:**
- Fastify's built-in logger already records request completion with `responseTime` when the `logger` option is enabled — custom timing middleware may be redundant
- `reply.elapsedTime` is available in `onResponse` as an alternative to manual timing

#### Request Mutation / Header Normalization

```js
// Express
app.use((req, res, next) => {
  req.body.email = req.body.email?.toLowerCase()
  next()
})
```

```js
// Fastify — preValidation runs after parsing, before schema validation
fastify.addHook('preValidation', async (request) => {
  if (request.body?.email) {
    request.body.email = request.body.email.toLowerCase()
  }
})
```

#### Response Wrapping

```js
// Express
app.use((req, res, next) => {
  const originalJson = res.json.bind(res)
  res.json = (data) => originalJson({ success: true, data })
  next()
})
```

```js
// Fastify — preSerialization wraps the payload before serialization
fastify.addHook('preSerialization', async (request, reply, payload) => {
  return { success: true, data: payload }
})
```

**Key Points:**
- `preSerialization` does not run when the payload is a `string`, `Buffer`, `stream`, or `null`
- [Inference] The Express pattern of monkey-patching `res.json` is generally not reproducible or necessary in Fastify; `preSerialization` is the intended mechanism

---

### Step 4 — Migrate Error Handling Middleware

Express error handling middleware uses a four-argument signature: `(err, req, res, next)`. Fastify replaces this entirely with `setErrorHandler`.

```js
// Express
app.use((err, req, res, next) => {
  console.error(err)
  res.status(err.status || 500).json({
    error: err.message || 'Internal Server Error'
  })
})
```

```js
// Fastify
fastify.setErrorHandler(async (error, request, reply) => {
  fastify.log.error(error)
  reply.code(error.statusCode || 500).send({
    error: error.message || 'Internal Server Error'
  })
})
```

**Key Points:**
- `setErrorHandler` applies within its registration scope — set it on the root instance for global error handling
- Fastify provides a sensible default error handler; `setErrorHandler` overrides it
- The `onError` hook can complement `setErrorHandler` for side effects such as sending errors to an external tracker, but `onError` cannot modify the response

---

### Step 5 — Handle Middleware with No Direct Equivalent

For Express middleware that has no official Fastify plugin and no straightforward hook equivalent, two options exist.

#### Option A — Temporary Bridge with @fastify/middie

Use `@fastify/middie` as a short-term measure while a proper migration is planned. This keeps the application functional without requiring an immediate rewrite.

```js
import middie from '@fastify/middie'
import legacyMiddleware from './legacy/some-middleware.js'

await fastify.register(middie)
fastify.use(legacyMiddleware)
```

Limitations of this approach are covered in the `@fastify/middie` topic. In brief: the middleware receives raw Node.js objects, Fastify decorations are not accessible, and async error handling requires explicit `next(err)` calls.

#### Option B — Rewrite as a Fastify Plugin

For middleware that is sufficiently complex or central to the application, rewriting as a native Fastify plugin is the preferable long-term path.

```js
// Express middleware
function tenantMiddleware(req, res, next) {
  const tenantId = req.headers['x-tenant-id']
  if (!tenantId) return res.status(400).json({ error: 'Missing tenant' })
  req.tenant = resolveTenant(tenantId)
  next()
}

// Fastify plugin equivalent
import fp from 'fastify-plugin'

async function tenantPlugin(fastify) {
  fastify.addHook('onRequest', async (request, reply) => {
    const tenantId = request.headers['x-tenant-id']
    if (!tenantId) {
      reply.code(400).send({ error: 'Missing tenant' })
      return
    }
    request.tenant = resolveTenant(tenantId)
  })
}

export default fp(tenantPlugin)
```

```js
// Registration
await fastify.register(tenantPlugin)
```

---

### Step 6 — Verify Hook Placement for Body Access

A frequent migration bug is placing logic that requires `request.body` in `onRequest`, where the body has not yet been parsed.

| Needs access to | Use hook |
|---|---|
| Headers only | `onRequest` |
| Raw body stream | `preParsing` |
| Parsed body | `preValidation` or `preHandler` |
| Validated body | `preHandler` |

```js
// Bug — body is undefined at onRequest
fastify.addHook('onRequest', async (request) => {
  console.log(request.body) // undefined
})

// Correct
fastify.addHook('preHandler', async (request) => {
  console.log(request.body) // populated and validated
})
```

---

### Incremental Migration Strategy

For large Express applications, a full rewrite is often impractical. An incremental approach reduces risk.

1. Install `@fastify/middie` and register it globally
2. Move all existing Express middleware through `fastify.use()` — the application runs under Fastify with compatibility shims in place
3. Identify and replace middleware that has official Fastify plugin equivalents first (cors, helmet, rate-limit, session)
4. Migrate custom middleware one piece at a time to native hooks, removing the corresponding `fastify.use()` call after each migration
5. Remove `@fastify/middie` once no `fastify.use()` calls remain

**Key Points:**
- Steps 3 and 4 can proceed in any order and at any pace
- [Inference] Running `@fastify/middie` alongside native hooks in the same application is expected to work during transition, though the interaction between the two should be tested for each middleware being migrated; behavior is not guaranteed in all configurations

---

### Things That Do Not Translate Directly

Some Express patterns have no clean Fastify equivalent and require rethinking rather than translating.

**`res.locals`** — Express middleware commonly attaches shared per-request state to `res.locals`. Fastify has no `locals` object. Use `request` directly: `request.myProperty = value`.

**Middleware order as security boundary** — In Express, placing `authenticate` before a route group in the middleware chain is the security mechanism. In Fastify, the security boundary is structural: use scoped hooks inside plugin scopes. Relying on registration order alone in Fastify without scoping is a riskier pattern.

**`next('route')`** — Express supports skipping to the next matching route via `next('route')`. Fastify has no equivalent; routing is resolved before hooks run.

**`app.use(express.static())`** — Serve static files with `@fastify/static` instead.

---

**Conclusion:** Migrating Express middleware to Fastify is primarily a process of reclassification — identifying what each middleware does and selecting the appropriate Fastify construct. Official `@fastify/*` plugins replace the most common packages directly. Custom logic maps to specific hook phases based on what data is needed and at what point in the lifecycle. `@fastify/middie` provides a short-term bridge for complex or third-party middleware that cannot be immediately replaced, but is not a long-term substitute for native Fastify patterns. The migration is most reliable when done incrementally, one middleware at a time, with tests verifying behavior at each step.