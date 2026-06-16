## Understanding Fastify's Performance Model

Fastify is designed from the ground up with performance as a primary constraint, not an afterthought. Its internal architecture makes deliberate tradeoffs at every layer — routing, serialization, validation, and the request lifecycle — to minimize overhead per request. Understanding these tradeoffs helps explain both why Fastify is fast and how to avoid patterns that undermine it.

---

### The Core Design Philosophy

Fastify's performance model rests on four pillars:

- **Ahead-of-time compilation** — schemas and serializers are compiled once at startup, not per request
- **Radix tree routing** — route lookup is O(log n) in the number of routes, not O(n)
- **Avoid unnecessary allocations** — minimize object creation in the hot path
- **Schema-driven code generation** — JSON serialization uses generated functions rather than generic `JSON.stringify`

These are architectural decisions baked into the framework. Application code can work with or against them.

---

### Routing: Radix Tree

Fastify uses `find-my-way`, a radix tree (compressed prefix trie) router. Route matching is performed by traversing the tree structure rather than iterating a flat list of route patterns.

**Key Points:**
- Static routes (no parameters) are matched in constant time via a hash lookup within the tree
- Parametric routes (`:id`) require tree traversal proportional to path depth, not total route count
- Wildcard routes are matched last within their subtree
- Method matching (GET, POST, etc.) is a secondary lookup after path matching

```ts
// These are stored as separate branches in the radix tree
fastify.get('/users', handler);           // static
fastify.get('/users/:id', handler);       // parametric
fastify.get('/users/:id/posts', handler); // deeper parametric
fastify.get('/files/*', handler);         // wildcard
```

Adding hundreds of routes does not linearly degrade lookup time for existing routes. [Inference: worst-case traversal depth is bounded by path segment count, not route count; actual performance depends on tree shape and input distribution]

---

### Radix Tree Diagram

<svg viewBox="0 0 640 320" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="12">
  <defs>
    <marker id="arr" markerWidth="7" markerHeight="7" refX="5" refY="3" orient="auto">
      <path d="M0,0 L0,6 L7,3 z" fill="#64748b"/>
    </marker>
  </defs>

  <!-- Root -->
  <rect x="280" y="20" width="80" height="34" rx="6" fill="#1e293b" stroke="#38bdf8" stroke-width="1.5"/>
  <text x="320" y="42" text-anchor="middle" fill="#38bdf8">/</text>

  <!-- Level 1: users, files -->
  <rect x="120" y="100" width="100" height="34" rx="6" fill="#1e293b" stroke="#f472b6" stroke-width="1.5"/>
  <text x="170" y="122" text-anchor="middle" fill="#f472b6">users</text>

  <rect x="420" y="100" width="100" height="34" rx="6" fill="#1e293b" stroke="#f472b6" stroke-width="1.5"/>
  <text x="470" y="122" text-anchor="middle" fill="#f472b6">files</text>

  <!-- Level 2: :id, * -->
  <rect x="60" y="190" width="100" height="34" rx="6" fill="#1e293b" stroke="#fbbf24" stroke-width="1.5"/>
  <text x="110" y="212" text-anchor="middle" fill="#fbbf24">:id</text>

  <rect x="180" y="190" width="100" height="34" rx="6" fill="#1e293b" stroke="#4ade80" stroke-width="1.5"/>
  <text x="230" y="212" text-anchor="middle" fill="#4ade80">GET ✓</text>

  <rect x="420" y="190" width="100" height="34" rx="6" fill="#1e293b" stroke="#fbbf24" stroke-width="1.5"/>
  <text x="470" y="212" text-anchor="middle" fill="#fbbf24">* wildcard</text>

  <!-- Level 3: posts -->
  <rect x="60" y="270" width="100" height="34" rx="6" fill="#1e293b" stroke="#4ade80" stroke-width="1.5"/>
  <text x="110" y="292" text-anchor="middle" fill="#4ade80">posts</text>

  <!-- Lines -->
  <line x1="320" y1="54" x2="170" y2="100" stroke="#64748b" stroke-width="1" marker-end="url(#arr)"/>
  <line x1="320" y1="54" x2="470" y2="100" stroke="#64748b" stroke-width="1" marker-end="url(#arr)"/>
  <line x1="170" y1="134" x2="110" y2="190" stroke="#64748b" stroke-width="1" marker-end="url(#arr)"/>
  <line x1="170" y1="134" x2="230" y2="190" stroke="#64748b" stroke-width="1" marker-end="url(#arr)"/>
  <line x1="470" y1="134" x2="470" y2="190" stroke="#64748b" stroke-width="1" marker-end="url(#arr)"/>
  <line x1="110" y1="224" x2="110" y2="270" stroke="#64748b" stroke-width="1" marker-end="url(#arr)"/>

  <text x="320" y="310" text-anchor="middle" fill="#475569" font-size="11">Path segments form tree branches; matching traverses depth, not breadth</text>
</svg>

---

### JSON Serialization: fast-json-stringify

Generic `JSON.stringify` must inspect every value at runtime to determine its type and structure. Fastify uses `fast-json-stringify`, which compiles a **dedicated serialization function** from a JSON Schema at startup time.

**Key Points:**
- The compiled function has a fixed code path for the known schema shape
- No runtime type introspection per field
- Properties not in the schema are excluded from output — this is a security and performance feature
- `fast-json-stringify` is 2–5× faster than `JSON.stringify` for schema-conforming objects [Unverified: exact speedup varies by payload shape, Node.js version, and schema complexity; treat as an order-of-magnitude approximation]

```ts
fastify.get('/users/:id', {
  schema: {
    response: {
      200: {
        type: 'object',
        properties: {
          id: { type: 'string' },
          name: { type: 'string' },
          email: { type: 'string' },
        },
      },
    },
  },
  handler: async (request, reply) => {
    return { id: '1', name: 'Alice', email: 'alice@example.com', _internal: 'stripped' };
    // _internal is not in schema — it is excluded from the response
  },
});
```

If no response schema is provided, Fastify falls back to `JSON.stringify`. This works but forfeits the serialization optimization.

---

### JSON Validation: Ajv

Incoming request bodies, query strings, params, and headers are validated using **Ajv** (Another JSON Validator), also compiled at startup.

**Key Points:**
- Ajv compiles JSON Schema into a validation function once when the route is registered
- Per-request validation executes the compiled function, not a generic schema interpreter
- Invalid requests are rejected before reaching the handler — the handler only runs with validated data
- Type coercion is applied to query string and path parameters (strings coerced to numbers, booleans, etc.) [Inference: coercion behavior depends on Ajv configuration; `coerceTypes` must be enabled, which is Fastify's default for query/params]

```ts
fastify.post('/orders', {
  schema: {
    body: {
      type: 'object',
      required: ['userId', 'items'],
      properties: {
        userId: { type: 'string', format: 'uuid' },
        items: {
          type: 'array',
          minItems: 1,
          items: {
            type: 'object',
            required: ['productId', 'quantity'],
            properties: {
              productId: { type: 'string' },
              quantity: { type: 'integer', minimum: 1 },
            },
          },
        },
      },
    },
  },
  handler: async (request, reply) => {
    // request.body is guaranteed valid here
  },
});
```

---

### The Request Lifecycle and Hook Overhead

Every Fastify request passes through a defined lifecycle. Each hook adds overhead proportional to its execution cost.

```
Incoming Request
      │
      ▼
  onRequest hooks         ← runs before parsing
      │
      ▼
  preParsing hooks        ← can modify raw stream
      │
      ▼
  Body Parsing
      │
      ▼
  preValidation hooks     ← runs before Ajv validation
      │
      ▼
  Ajv Validation
      │
      ▼
  preHandler hooks        ← authentication, authorization
      │
      ▼
  Route Handler
      │
      ▼
  preSerialization hooks  ← can modify reply payload before serialization
      │
      ▼
  fast-json-stringify
      │
      ▼
  onSend hooks            ← runs on final serialized payload
      │
      ▼
  Response sent
      │
      ▼
  onResponse hooks        ← logging, metrics
```

**Key Points:**
- Hooks registered at the root instance run for every request — scope them to plugins where possible
- Each async hook adds a microtask queue turn even if it does nothing significant
- `onRequest` and `onResponse` are the least expensive positions for logging and tracing
- Avoid synchronous CPU work in hooks — it blocks the event loop for all concurrent requests

---

### Object Allocation and the Hot Path

JavaScript's garbage collector introduces latency proportional to allocation rate. Fastify's internal code avoids allocating new objects in the per-request hot path where possible.

**Patterns that increase allocation pressure:**

```ts
// Creates a new object on every request
fastify.addHook('preHandler', async (request) => {
  request.context = { startTime: Date.now(), traceId: randomUUID() };
});

// Spreads create shallow copies — new object per call
fastify.get('/data', async (request) => {
  const result = await fetchData();
  return { ...result, processedAt: Date.now() }; // new object
});
```

**Lower-allocation alternatives:**

```ts
// Mutate existing object rather than creating a new one
fastify.addHook('preHandler', async (request) => {
  request.startTime = Date.now(); // decorate directly, no new object
});

// Return the object directly if schema strips unwanted fields
fastify.get('/data', async (request) => {
  const result = await fetchData();
  result.processedAt = Date.now(); // mutate if safe
  return result;
});
```

[Inference: object allocation impact depends heavily on GC pressure and Node.js version; these optimizations matter most under high-concurrency sustained load, not for low-traffic services]

---

### Plugins and Encapsulation Overhead

Fastify's plugin system uses `avvio` for dependency-ordered async initialization. At startup, each plugin registers its routes, hooks, and decorators into a scoped context tree.

**Key Points:**
- Plugin initialization is a startup cost, not a per-request cost
- Deep plugin nesting does not add per-request overhead — scoped hooks are flattened at registration time [Inference: based on Fastify's documented context inheritance model; actual implementation details may vary across versions]
- `fastify-plugin` (`fp`) breaks encapsulation intentionally — use it for shared infrastructure (database, auth) but not for route modules

---

### Async/Await and the Event Loop

Fastify is fully async. Every handler and hook is awaited. Understanding how Node.js schedules async work is relevant to throughput.

**Key Points:**
- `async` functions that `await` I/O (database queries, HTTP calls) yield the event loop, allowing other requests to proceed — this is the primary concurrency mechanism
- CPU-bound work in a handler blocks the event loop for all concurrent requests — offload to worker threads or a queue
- Returning a value directly from a handler (no `reply.send()`) is slightly more efficient because it avoids an extra function call [Inference: difference is negligible for most workloads]

```ts
// Both are valid; returning directly is marginally simpler
fastify.get('/ping', async () => ({ pong: true }));

fastify.get('/ping', async (request, reply) => {
  reply.send({ pong: true });
});
```

---

### Benchmarking Considerations

Fastify consistently performs well in benchmarks against Express, Hapi, and Koa. [Unverified: published benchmark results vary by scenario, Node.js version, hardware, and measurement methodology; treat third-party benchmarks as indicative, not definitive]

Factors that affect real-world performance relative to benchmarks:
- Middleware and hook count
- Schema coverage (routes without schemas serialize slower)
- Database and I/O wait time (usually dominates over framework overhead at scale)
- Body parser configuration (`Content-Type` detection adds overhead if many types are registered)
- Logger configuration (`pino` is fast, but synchronous transports or excessive log volume add cost)

---

### Pino: Structured Logging Without Blocking

Fastify uses `pino` as its default logger. Pino writes JSON logs asynchronously to stdout, avoiding synchronous `console.log` overhead in the hot path.

```ts
const fastify = Fastify({
  logger: {
    level: 'info',
    transport: {
      target: 'pino-pretty', // development only — adds overhead
    },
  },
});
```

**Key Points:**
- `pino-pretty` is for development only — it adds significant processing overhead [Inference: exact overhead depends on log volume; avoid in production]
- In production, pipe raw JSON output to a log aggregator externally
- `request.log` inherits the request-scoped child logger with `reqId` bound automatically

---

### Performance Anti-Patterns

| Anti-pattern | Why it hurts | Alternative |
|---|---|---|
| No response schema | Falls back to `JSON.stringify` | Add `schema.response` to every route |
| Root-scoped hooks doing per-request work | Runs for all requests including irrelevant routes | Scope hooks to plugins |
| Synchronous CPU work in handlers | Blocks event loop | Worker threads or job queue |
| `pino-pretty` in production | Log formatting overhead | Raw JSON to stdout |
| Excessive object spreading in hot path | GC pressure | Mutate or return directly |
| Registering schemas inside handlers | Recompiles per request | Register schemas at startup |
| Large unvalidated `request.body` | No early rejection, handler receives raw data | Always define body schema |

---

### Schema Compilation Timing

Schemas must be compiled before requests arrive. Fastify does this during `fastify.listen()` or `fastify.ready()` — both trigger the full plugin and route registration lifecycle.

```ts
// Correct: schema registered at route definition time
fastify.post('/items', {
  schema: { body: itemSchema },
  handler: itemHandler,
});

// Incorrect: schema defined inside handler — recompiled on every call
fastify.post('/items', async (request) => {
  const validate = ajv.compile(itemSchema); // do not do this
  validate(request.body);
});
```

---

**Related Topics:**
- Profiling Fastify applications with `0x` and Node.js `--prof`
- Worker threads for CPU-bound tasks in Fastify
- Connection pooling and its interaction with async throughput
- HTTP/2 and Keep-Alive effects on Fastify throughput
- Memory profiling and heap snapshot analysis in Node.js
- Benchmarking with `autocannon` and interpreting results
- Schema reuse with `$ref` and `addSchema` for compilation efficiency
- Fastify's `reply.hijack()` for bypassing the serialization pipeline