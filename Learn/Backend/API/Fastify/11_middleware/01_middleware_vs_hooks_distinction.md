## Fastify — Middleware vs Hooks Distinction

### Overview

Fastify and Express-style middleware are fundamentally different mechanisms for intercepting and processing requests. While both sit between an incoming request and a route handler, they operate at different layers, integrate differently with the framework, and carry different performance characteristics. Understanding this distinction is essential when migrating from Express, evaluating third-party packages, or deciding where to place cross-cutting logic in a Fastify application.

---

### Conceptual Difference

**Middleware** (Express-style) is a Node.js convention — a function with the signature `(req, res, next)` that operates on the raw Node.js `IncomingMessage` and `ServerResponse` objects. It predates Fastify and exists at the HTTP adapter layer, below Fastify's abstractions.

**Hooks** are Fastify-native — functions that plug into specific, named points in Fastify's own request lifecycle. They receive Fastify's enriched `request` and `reply` objects, with full access to decorators, schema validation results, logging, and serialization.

The distinction can be summarized as:

| | Middleware | Hooks |
|---|---|---|
| Origin | Connect / Express convention | Fastify-native |
| Signature | `(req, res, next)` | `(request, reply, [done])` |
| Object type | Raw Node.js objects | Fastify `Request` / `Reply` |
| Lifecycle awareness | None — runs before Fastify routing | Full — tied to named lifecycle points |
| Encapsulation | Limited | Full plugin-scope encapsulation |
| Performance | Lower — bypasses Fastify optimizations | Higher — integrated into Fastify internals |
| Access to decorators | ❌ | ✅ |
| Access to parsed body | ❌ (pre-parse) | ✅ (post-parse hooks) |
| Error handling | `next(err)` | `throw` or `done(err)` |

---

### Where Each Operates in the Lifecycle

Middleware runs **before** Fastify takes control of the request. Hooks run **within** Fastify's lifecycle at precisely defined points.

<svg viewBox="0 0 680 430" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="12">
  <defs>
    <marker id="arr" markerWidth="8" markerHeight="8" refX="6" refY="3" orient="auto">
      <path d="M0,0 L0,6 L8,3 z" fill="#64748b"/>
    </marker>
  </defs>

  <!-- Incoming -->
  <rect x="240" y="10" width="200" height="36" rx="6" fill="#e2e8f0" stroke="#94a3b8" stroke-width="1.5"/>
  <text x="340" y="33" text-anchor="middle" fill="#334155" font-weight="bold">Incoming Request</text>
  <line x1="340" y1="46" x2="340" y2="70" stroke="#64748b" stroke-width="1.5" marker-end="url(#arr)"/>

  <!-- Middleware zone -->
  <rect x="80" y="70" width="520" height="90" rx="8" fill="#fef3c7" stroke="#f59e0b" stroke-width="1.5" stroke-dasharray="6,3"/>
  <text x="100" y="88" fill="#b45309" font-weight="bold" font-size="11">Middleware Layer (Express-style)</text>
  <rect x="160" y="94" width="140" height="34" rx="5" fill="#fde68a" stroke="#f59e0b" stroke-width="1"/>
  <text x="230" y="116" text-anchor="middle" fill="#92400e">Middleware 1</text>
  <line x1="300" y1="111" x2="340" y2="111" stroke="#b45309" stroke-width="1.5" marker-end="url(#arr)"/>
  <rect x="340" y="94" width="140" height="34" rx="5" fill="#fde68a" stroke="#f59e0b" stroke-width="1"/>
  <text x="410" y="116" text-anchor="middle" fill="#92400e">Middleware 2</text>
  <text x="340" y="152" text-anchor="middle" fill="#92400e" font-size="10">raw req / res — no Fastify context</text>

  <line x1="340" y1="160" x2="340" y2="184" stroke="#64748b" stroke-width="1.5" marker-end="url(#arr)"/>

  <!-- Fastify zone -->
  <rect x="80" y="184" width="520" height="218" rx="8" fill="#eff6ff" stroke="#3b82f6" stroke-width="1.5" stroke-dasharray="6,3"/>
  <text x="100" y="202" fill="#1d4ed8" font-weight="bold" font-size="11">Fastify Lifecycle (Hooks Layer)</text>

  <!-- Hook rows -->
  <!-- onRequest -->
  <rect x="180" y="208" width="320" height="28" rx="5" fill="#bfdbfe" stroke="#3b82f6" stroke-width="1"/>
  <text x="340" y="227" text-anchor="middle" fill="#1e3a8a">onRequest hook — Fastify request/reply objects available</text>
  <line x1="340" y1="236" x2="340" y2="248" stroke="#64748b" stroke-width="1.5" marker-end="url(#arr)"/>

  <!-- preParsing -->
  <rect x="180" y="248" width="320" height="28" rx="5" fill="#bfdbfe" stroke="#3b82f6" stroke-width="1"/>
  <text x="340" y="267" text-anchor="middle" fill="#1e3a8a">preParsing hook</text>
  <line x1="340" y1="276" x2="340" y2="288" stroke="#64748b" stroke-width="1.5" marker-end="url(#arr)"/>

  <!-- preHandler -->
  <rect x="180" y="288" width="320" height="28" rx="5" fill="#bfdbfe" stroke="#3b82f6" stroke-width="1"/>
  <text x="340" y="307" text-anchor="middle" fill="#1e3a8a">preHandler hook — body parsed, decorators available</text>
  <line x1="340" y1="316" x2="340" y2="328" stroke="#64748b" stroke-width="1.5" marker-end="url(#arr)"/>

  <!-- Handler -->
  <rect x="220" y="328" width="240" height="34" rx="6" fill="#dcfce7" stroke="#16a34a" stroke-width="1.5"/>
  <text x="340" y="350" text-anchor="middle" fill="#14532d" font-weight="bold">Route Handler</text>

  <line x1="340" y1="362" x2="340" y2="386" stroke="#64748b" stroke-width="1.5" marker-end="url(#arr)"/>

  <!-- Response -->
  <rect x="240" y="386" width="200" height="34" rx="6" fill="#e2e8f0" stroke="#94a3b8" stroke-width="1.5"/>
  <text x="340" y="408" text-anchor="middle" fill="#334155" font-weight="bold">Response Sent</text>
</svg>

---

### Middleware in Fastify — How It Works

Fastify does not natively support Express-style middleware. To use it, the `@fastify/middie` plugin must be registered. This plugin integrates a middleware-compatible layer into Fastify's pipeline.

```js
import Fastify from 'fastify';
import middie from '@fastify/middie';

const fastify = Fastify({ logger: true });

await fastify.register(middie);

// Now middleware can be used
fastify.use('/api', (req, res, next) => {
  console.log('Middleware — raw req.url:', req.url);
  // req and res are Node.js IncomingMessage and ServerResponse
  // No access to fastify.request, fastify.reply, or decorators
  next();
});

fastify.get('/api/data', async () => ({ ok: true }));

await fastify.listen({ port: 3000 });
```

**Key Points:**
- `@fastify/middie` must be explicitly installed and registered
- `fastify.use()` becomes available only after `middie` is registered
- Middleware receives raw Node.js objects — not Fastify's `Request`/`Reply`
- Middleware cannot access properties added via `fastify.decorateRequest()`
- Middleware runs before routing, so `req.routerPath` and similar Fastify-specific properties are not yet populated

---

### Hooks in Fastify — Native Integration

Hooks are registered via `fastify.addHook()` and are first-class citizens of the Fastify lifecycle. They receive the fully constructed Fastify `request` and `reply` objects.

```js
fastify.addHook('onRequest', async (request, reply) => {
  console.log('Hook — request.id:', request.id);
  console.log('Hook — request.ip:', request.ip);
  // Full access to Fastify's request object, decorators, log, etc.
});

fastify.get('/data', async (request, reply) => {
  return { ok: true };
});
```

Hooks integrate with Fastify's schema validation, serialization, logging, and error handling without any additional setup.

---

### Key Differences in Practice

#### Access to Fastify Decorators

```js
fastify.decorateRequest('user', null);

// Middleware — decorator NOT accessible
fastify.use((req, res, next) => {
  console.log(req.user); // undefined — decorators are Fastify-level
  next();
});

// Hook — decorator IS accessible
fastify.addHook('preHandler', async (request, reply) => {
  console.log(request.user); // null (or populated value if set earlier)
});
```

#### Access to Parsed Body

Middleware runs before Fastify parses the request body. Hooks at and after `preParsing` have access to body data at the appropriate stage.

```js
// Middleware — body not yet parsed
fastify.use((req, res, next) => {
  console.log(req.body); // undefined
  next();
});

// preHandler hook — body is parsed and available
fastify.addHook('preHandler', async (request, reply) => {
  console.log(request.body); // { name: 'Alice' } — parsed and validated
});
```

#### Error Handling

```js
// Middleware error handling — Express convention
fastify.use((req, res, next) => {
  next(new Error('Middleware error'));
});

// Hook error handling — Fastify native
fastify.addHook('onRequest', async (request, reply) => {
  throw new Error('Hook error'); // Fastify catches and routes to error handler
});

// Callback-style hook
fastify.addHook('onRequest', function (request, reply, done) {
  done(new Error('Hook error'));
});
```

Errors from middleware are caught by `@fastify/middie` and forwarded into Fastify's error handling. Errors from hooks are handled natively by Fastify's lifecycle.

---

### Performance Implications

Fastify is designed for high throughput. Using Express-style middleware introduces overhead because:

- Middleware operates outside Fastify's optimized routing and serialization pipeline
- `@fastify/middie` adds an integration layer with its own processing cost
- Raw Node.js `req`/`res` objects bypass Fastify's pooled `Request`/`Reply` construction optimizations [Inference]

Hooks, by contrast, are deeply integrated into Fastify's internal lifecycle and benefit from its zero-overhead abstraction design goals.

> **Disclaimer:** Actual performance differences depend on the specific middleware or hook logic, request volume, payload size, and runtime environment. Benchmarking in a representative environment is recommended before drawing conclusions.

---

### When to Use Middleware

Despite the overhead, middleware is appropriate in specific situations:

- **Migrating from Express:** Reusing existing Express middleware packages without rewriting them
- **Third-party packages with no Fastify equivalent:** Some libraries only expose a middleware interface
- **Temporary compatibility layers:** During incremental migration from an Express codebase to Fastify

**Example — Using an Express-compatible CORS middleware:**

```js
import cors from 'cors'; // Express-style middleware

await fastify.register(middie);
fastify.use(cors({ origin: 'https://example.com' }));
```

> **Note:** For most common middleware use cases (CORS, rate limiting, compression, authentication), Fastify-native plugins exist (e.g. `@fastify/cors`, `@fastify/rate-limit`) and are strongly preferred over Express middleware equivalents.

---

### When to Use Hooks

Hooks should be the default choice for all cross-cutting concerns in a Fastify application:

- Authentication and authorization
- Request enrichment and context building
- Logging and tracing
- Input validation preprocessing
- Response transformation
- Metrics collection
- Graceful shutdown and resource cleanup

They are more capable, more performant, and integrate cleanly with Fastify's encapsulation model.

---

### Compatibility Note — @fastify/middie vs @fastify/express

Two plugins provide middleware compatibility in Fastify:

| Plugin | Purpose |
|---|---|
| `@fastify/middie` | Lightweight middleware support via `fastify.use()` |
| `@fastify/express` | Full Express compatibility layer — mounts an Express app inside Fastify |

`@fastify/express` is significantly heavier and intended for scenarios where an entire Express application is being embedded. [Inference: it carries substantially more overhead than `@fastify/middie`.] For individual middleware functions, `@fastify/middie` is the appropriate choice.

---

### Migration Pattern — Middleware to Hook

When migrating an Express middleware to a Fastify hook, the primary changes are:

- Replace `(req, res, next)` with `async (request, reply)` or `(request, reply, done)`
- Replace `next(err)` with `throw err` or `done(err)`
- Replace `next()` with `return` (async) or `done()` (callback)
- Replace raw `req` properties with their Fastify equivalents

**Before (Express middleware):**

```js
function authenticate(req, res, next) {
  const token = req.headers.authorization;
  if (!token) {
    return res.status(401).json({ error: 'Unauthorized' });
  }
  req.user = verifyToken(token);
  next();
}
```

**After (Fastify hook):**

```js
fastify.addHook('onRequest', async (request, reply) => {
  const token = request.headers.authorization;
  if (!token) {
    reply.code(401).send({ error: 'Unauthorized' });
    return;
  }
  request.user = verifyToken(token);
});
```

---

### Summary

| Concern | Middleware | Hook |
|---|---|---|
| Requires additional plugin | ✅ (`@fastify/middie`) | ❌ (built-in) |
| Access to Fastify decorators | ❌ | ✅ |
| Access to parsed body | ❌ | ✅ (post-parse hooks) |
| Encapsulation support | ❌ | ✅ |
| Lifecycle precision | ❌ (pre-routing only) | ✅ (named lifecycle points) |
| Performance | Lower | Higher |
| Recommended for new code | ❌ | ✅ |
| Useful for Express migration | ✅ | — |

---

**Conclusion:**
Middleware and hooks serve overlapping purposes but operate at fundamentally different layers. Middleware is a compatibility mechanism — useful for reusing Express ecosystem packages or migrating existing code, but limited in capability and integration depth. Hooks are Fastify's native answer to cross-cutting concerns, offering lifecycle precision, full access to Fastify's request and reply objects, plugin-scope encapsulation, and superior performance. For all new Fastify development, hooks are the correct and idiomatic choice.