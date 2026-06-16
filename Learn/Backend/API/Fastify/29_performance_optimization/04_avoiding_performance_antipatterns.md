## Avoiding Performance Anti-Patterns

Fastify's architecture provides a high performance ceiling, but application code can erode that ceiling significantly. Most performance problems in Fastify applications are not framework limitations — they are patterns applied incorrectly or in the wrong context. This article catalogs the most common anti-patterns, explains the mechanism of harm for each, and provides corrected alternatives.

---

### Anti-Pattern 1: Missing Response Schemas

The most impactful single omission in a Fastify application is a missing `response` schema. Without one, Fastify falls back to `JSON.stringify` for every response on that route.

```ts
// Anti-pattern — JSON.stringify path, runtime type inspection, no field filtering
fastify.get('/users', {
  handler: async () => db.users.findAll(),
});
```

```ts
// Correct — compiled fast-json-stringify path
fastify.get('/users', {
  schema: {
    response: {
      200: {
        type: 'array',
        items: {
          type: 'object',
          properties: {
            id: { type: 'string' },
            name: { type: 'string' },
            email: { type: 'string' },
          },
          required: ['id', 'name', 'email'],
        },
      },
    },
  },
  handler: async () => db.users.findAll(),
});
```

**Why it hurts:** `JSON.stringify` inspects every value's type at runtime, enumerates object keys, and serializes all fields including internal or sensitive ones. The compiled serializer does none of this — it follows a fixed code path generated from the schema at startup.

---

### Anti-Pattern 2: Registering Schemas or Validators Inside Handlers

Schema compilation is expensive. Doing it inside a handler means it runs on every request rather than once at startup.

```ts
// Anti-pattern — recompiles Ajv schema on every request
fastify.post('/orders', async (request) => {
  const validate = new Ajv().compile({
    type: 'object',
    required: ['userId', 'items'],
    properties: {
      userId: { type: 'string' },
      items: { type: 'array' },
    },
  });

  if (!validate(request.body)) {
    throw new Error('Invalid body');
  }

  return db.orders.create(request.body);
});
```

```ts
// Correct — compilation happens once at startup
fastify.post('/orders', {
  schema: {
    body: {
      type: 'object',
      required: ['userId', 'items'],
      properties: {
        userId: { type: 'string' },
        items: { type: 'array' },
      },
    },
  },
  handler: async (request) => db.orders.create(request.body),
});
```

**Why it hurts:** `new Ajv().compile()` walks the schema tree and generates a validator function. At 1000 req/s, this runs 1000 times per second, allocating validator functions and intermediate objects that immediately become garbage.

---

### Anti-Pattern 3: Root-Scoped Hooks Doing Route-Specific Work

Hooks registered on the root Fastify instance run for every request, including routes that do not need them.

```ts
// Anti-pattern — authentication runs for /healthz, /metrics, and every public route
fastify.addHook('preHandler', async (request, reply) => {
  await verifyJWT(request);
});

fastify.get('/healthz', async () => ({ status: 'ok' }));         // does not need auth
fastify.get('/metrics', async () => getMetrics());               // does not need auth
fastify.get('/api/users', { handler: userHandler });             // needs auth
```

```ts
// Correct — auth scoped to the plugin that contains protected routes
fastify.register(async (instance) => {
  instance.addHook('preHandler', async (request, reply) => {
    await verifyJWT(request);
  });

  instance.get('/api/users', { handler: userHandler });
  instance.get('/api/orders', { handler: orderHandler });
});

// Public routes — no auth hook runs
fastify.get('/healthz', async () => ({ status: 'ok' }));
fastify.get('/metrics', async () => getMetrics());
```

**Why it hurts:** Every hook invocation is a function call and, for async hooks, a microtask queue turn. A `preHandler` that calls `verifyJWT` — which likely performs a crypto operation or a cache lookup — adds measurable latency to every single request, including those that have no business going through authentication.

---

### Anti-Pattern 4: Synchronous CPU Work in Handlers

Node.js is single-threaded. Synchronous computation in a handler blocks the event loop for the entire duration, preventing all other concurrent requests from progressing.

```ts
// Anti-pattern — blocks event loop during computation
fastify.post('/report', async (request) => {
  const data = request.body.records;

  // CPU-bound: blocks for potentially hundreds of milliseconds
  const result = data.reduce((acc, row) => {
    return heavyStatisticalComputation(acc, row);
  }, {});

  return result;
});
```

```ts
// Correct — offload to a worker thread
import { runInWorker } from './workerPool.js';

fastify.post('/report', async (request) => {
  const result = await runInWorker('heavyComputation', request.body.records);
  return result;
});
```

Or offload to a job queue if the result does not need to be returned synchronously:

```ts
fastify.post('/report', async (request, reply) => {
  const job = await fastify.queues.report.add('compute', request.body);
  return reply.code(202).send({ jobId: job.id });
});
```

**Why it hurts:** While the CPU-bound operation runs, no I/O callbacks fire. Requests waiting for database responses, other handlers, or timers are all frozen. Latency for concurrent requests spikes proportionally to the computation duration. [Inference: impact depends on the degree of concurrency; lightly loaded servers may not show this problem until traffic grows]

---

### Anti-Pattern 5: Awaiting Unnecessary Promises

Every `await` suspends the current async function and schedules a microtask. Awaiting values that are not actually promises, or awaiting sequentially when operations are independent, adds latency.

```ts
// Anti-pattern — sequential awaits for independent operations
fastify.get('/dashboard', async (request) => {
  const user = await db.users.findById(request.user.id);
  const orders = await db.orders.findByUser(request.user.id);  // waits for user first
  const notifications = await db.notifications.findByUser(request.user.id); // waits for orders first

  return { user, orders, notifications };
});
```

```ts
// Correct — concurrent independent queries
fastify.get('/dashboard', async (request) => {
  const [user, orders, notifications] = await Promise.all([
    db.users.findById(request.user.id),
    db.orders.findByUser(request.user.id),
    db.notifications.findByUser(request.user.id),
  ]);

  return { user, orders, notifications };
});
```

**Why it hurts:** Sequential awaits serialize I/O that could proceed concurrently. If each query takes 20ms, sequential execution takes 60ms minimum. Concurrent execution takes roughly 20ms (the duration of the slowest query). At scale, this difference directly impacts p95 and p99 latency. [Inference: actual improvement depends on database connection pool size and server capacity; if the pool is exhausted, concurrent queries queue at the pool level]

---

### Anti-Pattern 6: Excessive Object Spreading in the Hot Path

Object spread (`{ ...obj }`) creates a shallow copy with a new object allocation. In handlers that process many requests per second, this contributes to GC pressure.

```ts
// Anti-pattern — multiple spreads, multiple allocations per request
fastify.get('/users/:id', async (request) => {
  const user = await db.users.findById(request.params.id);
  const withDefaults = { role: 'user', ...user };
  const withTimestamp = { ...withDefaults, servedAt: Date.now() };
  return withTimestamp;
});
```

```ts
// Better — single object, direct property assignment
fastify.get('/users/:id', async (request) => {
  const user = await db.users.findById(request.params.id);
  user.role = user.role ?? 'user';
  user.servedAt = Date.now();
  return user;
  // response schema strips any fields not declared in the schema
});
```

**Why it hurts:** Each spread allocates a new object and copies all enumerable properties. With a response schema in place, the serializer already handles field filtering — there is no need to create intermediate objects to control output shape. [Inference: GC pressure from spread operators is most significant at high request rates with large objects; profiling with `0x` or `--prof` is needed to confirm impact for a specific application]

---

### Anti-Pattern 7: Logging Inside Tight Loops or Per-Item in Arrays

Logging is not free even with Pino. Emitting a log entry per item in a large array processed inside a handler multiplies I/O and serialization cost.

```ts
// Anti-pattern — log per item
fastify.post('/import', async (request) => {
  for (const item of request.body.items) {
    fastify.log.info({ item }, 'Processing item'); // potentially thousands of log calls
    await processItem(item);
  }
});
```

```ts
// Better — log summary, not per-item
fastify.post('/import', async (request) => {
  const { items } = request.body;
  fastify.log.info({ count: items.length }, 'Starting import');

  for (const item of items) {
    await processItem(item);
  }

  fastify.log.info({ count: items.length }, 'Import complete');
});
```

**Why it hurts:** Each Pino log call serializes its argument to JSON and writes to an async buffer. At fine granularity, this adds serialization cost that can exceed the cost of the actual work. Pino's async transport mitigates but does not eliminate this. [Inference: impact depends on log volume relative to stdout bandwidth and the downstream log sink's capacity]

---

### Anti-Pattern 8: Not Setting prefetch / Connection Pool Limits

Without bounded concurrency at the I/O layer, a traffic spike causes all requests to flood the database simultaneously. The database becomes the bottleneck, and queue depth at the connection pool grows unboundedly.

```ts
// Anti-pattern — unbounded pool, no concurrency control
const db = new Pool({ connectionString: process.env.DATABASE_URL });
// default max connections may be very high or unlimited depending on the driver
```

```ts
// Better — explicitly bounded pool
const db = new Pool({
  connectionString: process.env.DATABASE_URL,
  max: 20,              // hard cap on concurrent connections
  idleTimeoutMillis: 10000,
  connectionTimeoutMillis: 3000,
});
```

**Why it hurts:** Databases have a finite number of connections they can handle efficiently. Beyond that point, they degrade significantly. A bounded pool queues excess requests in Node.js (fast, cheap) rather than overwhelming the database (slow, expensive). [Inference: optimal pool size depends on database server capacity, query complexity, and Fastify instance count; no single number is universally correct]

---

### Anti-Pattern 9: Using pino-pretty in Production

`pino-pretty` formats JSON log output into human-readable text. It is a development convenience that adds non-trivial overhead.

```ts
// Anti-pattern in production — formatting overhead on every log line
const fastify = Fastify({
  logger: {
    transport: {
      target: 'pino-pretty',
      options: { colorize: true },
    },
  },
});
```

```ts
// Correct for production — raw JSON to stdout
const fastify = Fastify({
  logger: {
    level: process.env.LOG_LEVEL ?? 'info',
  },
});
```

Route `pino-pretty` through an environment variable so it activates only in development:

```ts
const fastify = Fastify({
  logger: {
    level: process.env.LOG_LEVEL ?? 'info',
    ...(process.env.NODE_ENV === 'development' && {
      transport: { target: 'pino-pretty' },
    }),
  },
});
```

---

### Anti-Pattern 10: Parsing Bodies on Routes That Do Not Need Them

Fastify parses the request body for every route by default when a `Content-Type` matches a registered parser. Routes that do not use `request.body` still pay the parsing cost.

```ts
// Anti-pattern — body is parsed but never used
fastify.get('/status', async (request) => {
  // GET request, body is irrelevant, but parsing runs if Content-Type is sent
  return { uptime: process.uptime() };
});
```

```ts
// Better — explicitly skip body parsing for routes that don't need it
fastify.get('/status', {
  config: { rawBody: false },
  handler: async () => ({ uptime: process.uptime() }),
});
```

For routes that receive large bodies that must be rejected early, add a `contentLength` limit:

```ts
fastify.register(import('@fastify/multipart'), {
  limits: {
    fileSize: 10 * 1024 * 1024, // 10MB max
    files: 1,
  },
});
```

**Why it hurts:** Body parsing involves reading the stream, buffering chunks, and running the parser (JSON.parse for JSON bodies). For GET, HEAD, and OPTIONS routes, this work produces nothing useful.

---

### Anti-Pattern 11: reply.send() Inside an async Handler

In an `async` handler, `return` is the idiomatic way to send a response. Using `reply.send()` inside an `async` handler and also returning a value leads to double-send errors or confusing behavior.

```ts
// Anti-pattern — mixing return and reply.send in async handler
fastify.get('/data', async (request, reply) => {
  const data = await fetchData();
  reply.send(data);        // sends response
  return data;             // attempts to send again — error or silent ignore
});
```

```ts
// Correct — return from async handler
fastify.get('/data', async (request) => {
  return fetchData();
});

// Correct — reply.send without return, non-async handler
fastify.get('/data', (request, reply) => {
  fetchData().then(data => reply.send(data));
});
```

**Why it hurts:** Double-send does not always throw a visible error — in some configurations it is silently dropped. More subtly, the handler continues executing after `reply.send()`, performing work whose results are discarded. This wastes CPU and may cause hooks to fire unexpectedly. [Inference: exact behavior depends on Fastify version and whether `reply.sent` is checked; do not rely on silent failure]

---

### Anti-Pattern 12: Accessing request.body Before Parsing Completes

In hooks that run before `preValidation`, the body has not yet been parsed. Accessing `request.body` there returns `undefined` or an incomplete value.

```ts
// Anti-pattern — body not yet available in onRequest
fastify.addHook('onRequest', async (request) => {
  const { userId } = request.body; // undefined — body not parsed yet
  await logRequest(userId);
});
```

```ts
// Correct — body is available from preValidation onward
fastify.addHook('preHandler', async (request) => {
  const { userId } = request.body; // parsed and validated
  await logRequest(userId);
});
```

**Lifecycle order:**

```
onRequest → preParsing → [body parsing] → preValidation → [validation] → preHandler → handler
```

Body is available from `preValidation` onward. Validated body is available from `preHandler` onward.

---

### Anti-Pattern 13: Attaching Large Objects to request or reply

`request` and `reply` objects are created per-request. Properties added to them are held in memory for the request's lifetime and prevent GC until the request completes.

```ts
// Anti-pattern — attaches full dataset to request
fastify.addHook('preHandler', async (request) => {
  request.allProducts = await db.products.findAll(); // potentially thousands of records
});
```

```ts
// Better — fetch only what the handler needs, pass via scoped variable or minimal decoration
fastify.addHook('preHandler', async (request) => {
  request.userPermissions = await getPermissions(request.user.id); // minimal, scoped
});
```

**Why it hurts:** Large objects attached to `request` remain live until the request lifecycle ends. Under high concurrency, many simultaneous requests each holding a large dataset can exhaust the heap. [Inference: impact depends on object size and concurrent request count; measure with heap profiling before optimizing]

---

### Anti-Pattern Overview

```
┌─────────────────────────────────────────────┬──────────────────────────────────────┐
│ Anti-Pattern                                │ Primary Cost                         │
├─────────────────────────────────────────────┼──────────────────────────────────────┤
│ Missing response schema                     │ Runtime serialization on every req   │
│ Schema compilation in handlers              │ Recompilation on every req           │
│ Root-scoped hooks for partial routes        │ Unnecessary work per request         │
│ Synchronous CPU in handlers                 │ Event loop blocking                  │
│ Sequential awaits for parallel I/O          │ Unnecessary latency accumulation     │
│ Excessive object spreading                  │ GC pressure from allocations         │
│ Per-item logging in loops                   │ Log serialization overhead           │
│ Unbounded connection pools                  │ Database saturation under load       │
│ pino-pretty in production                   │ Log formatting CPU overhead          │
│ Parsing bodies on non-body routes           │ Unnecessary stream buffering         │
│ reply.send + return in async handlers       │ Double-send, wasted computation      │
│ Accessing body before parsing               │ Undefined reads, logic errors        │
│ Large objects on request/reply              │ Heap pressure under concurrency      │
└─────────────────────────────────────────────┴──────────────────────────────────────┘
```

---

**Related Topics:**
- Profiling Fastify with `0x` and flame graphs
- Worker threads for CPU-bound task offloading
- Connection pool tuning for PostgreSQL and MySQL
- Fastify plugin scoping and hook inheritance model
- Heap profiling and memory leak detection in Node.js
- Autocannon load testing and interpreting latency percentiles
- Structured logging best practices with Pino
- Event loop monitoring with `@clinic/doctor` and `perf_hooks`