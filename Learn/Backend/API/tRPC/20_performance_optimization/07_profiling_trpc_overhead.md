## Profiling tRPC Overhead

### What Is tRPC Overhead?

tRPC overhead refers to the processing cost introduced by the tRPC layer itself — separate from your business logic — during a procedure call. This includes input parsing, middleware execution, context creation, serialization, and transport handling.

**Key Points:**

- tRPC is a thin layer over your existing HTTP server; its intrinsic overhead is generally low. [Inference]
- Profiling helps distinguish tRPC-layer cost from application-layer cost (database queries, external APIs, etc.)
- Overhead is most visible under high request volume or in latency-sensitive environments.

---

### Where Overhead Can Accumulate

Understanding the request lifecycle helps isolate where time is spent:

```
Client Request
     │
     ▼
┌─────────────────────────────────┐
│        HTTP Server Layer        │  ← Express / Fastify / Next.js
└────────────────┬────────────────┘
                 │
                 ▼
┌─────────────────────────────────┐
│       tRPC Request Handler      │  ← fetchRequestHandler / etc.
└────────────────┬────────────────┘
                 │
                 ▼
┌─────────────────────────────────┐
│        Context Creation         │  ← createContext()
└────────────────┬────────────────┘
                 │
                 ▼
┌─────────────────────────────────┐
│       Middleware Chain          │  ← .use() middlewares
└────────────────┬────────────────┘
                 │
                 ▼
┌─────────────────────────────────┐
│        Input Parsing (Zod)      │  ← .input() schema validation
└────────────────┬────────────────┘
                 │
                 ▼
┌─────────────────────────────────┐
│        Procedure Handler        │  ← your resolver function
└────────────────┬────────────────┘
                 │
                 ▼
┌─────────────────────────────────┐
│     Output Serialization        │  ← JSON / superjson
└────────────────┬────────────────┘
                 │
                 ▼
              Response
```

Each stage is a candidate for profiling. [Inference] The majority of latency in typical applications lives in the procedure handler (I/O), not in tRPC's own layers — but this should be verified for your specific app.

---

### Instrumentation Strategy

#### Timing with `performance.now()`

The simplest approach — insert timing calls around specific stages using tRPC middleware:

```ts
import { middleware } from './trpc';

export const timingMiddleware = middleware(async ({ next, path }) => {
  const start = performance.now();

  const result = await next();

  const duration = performance.now() - start;
  console.log(`[tRPC] ${path} — ${duration.toFixed(2)}ms`);

  return result;
});
```

Apply globally in your base procedure:

```ts
export const publicProcedure = t.procedure.use(timingMiddleware);
```

**Output:**

```
[tRPC] user.getById — 3.41ms
[tRPC] post.list — 12.87ms
```

[Inference] This measures total procedure time including middleware and handler, not tRPC framework cost in isolation. Behavior may vary.

---

#### Isolating tRPC Framework Cost

To approximate tRPC's own cost, create a no-op procedure and measure it:

```ts
export const noop = publicProcedure
  .query(() => ({ ok: true }));
```

Call this procedure repeatedly under load and record latency. The measured time represents tRPC overhead without any application logic — context creation, middleware, serialization, and transport.

[Inference] This gives a baseline approximation. It does not perfectly isolate all framework costs, as context creation varies per request.

---

#### Granular Stage Timing

To profile individual stages, emit timestamps at each boundary:

```ts
export const granularTimingMiddleware = middleware(async ({ next, path, ctx }) => {
  const marks: Record<string, number> = {};

  marks.middlewareEnter = performance.now();

  const result = await next();

  marks.handlerExit = performance.now();

  console.log(`[${path}] middleware→handler: ${(marks.handlerExit - marks.middlewareEnter).toFixed(2)}ms`);

  return result;
});
```

For context creation timing, instrument `createContext` directly:

```ts
export async function createContext(opts: CreateNextContextOptions) {
  const start = performance.now();

  const ctx = await buildContext(opts);

  console.log(`[context] creation: ${(performance.now() - start).toFixed(2)}ms`);

  return ctx;
}
```

---

### Using Node.js Built-in Profiler

For deeper CPU profiling, use Node.js's `--prof` flag:

```bash
node --prof server.js
```

Then process the output:

```bash
node --prof-process isolate-*.log > processed.txt
```

Look for tRPC internal functions in the tick profile output. [Unverified: exact function names visible in profiles depend on your tRPC version and whether source maps are available.]

---

### Using Clinic.js

Clinic.js is a Node.js profiling toolkit that can surface tRPC overhead visually.

```bash
npm install -g clinic
clinic doctor -- node server.js
```

Run your load test while Clinic observes, then open the generated report. Look for:

- Event loop lag spikes during request handling
- CPU usage patterns correlated with request volume

[Inference] Clinic is most useful for identifying systemic issues (event loop blocking, GC pressure) rather than per-procedure tRPC overhead specifically.

---

### Load Testing to Surface Overhead

Profiling under low load can obscure real-world overhead. Use a load testing tool to stress the tRPC layer:

#### With `autocannon`:

```bash
npm install -g autocannon
autocannon -c 100 -d 10 http://localhost:3000/api/trpc/user.getById
```

**Key metrics to observe:**

- **Latency p50 / p95 / p99** — distribution reveals tail latency
- **Requests/sec** — throughput ceiling
- **Latency delta vs. baseline** — compare tRPC endpoint vs. a raw HTTP endpoint returning the same data

[Inference] Comparing a tRPC procedure against an equivalent raw Express route returning identical data gives an approximation of tRPC's serialization and routing overhead. Results are environment-dependent.

---

### Identifying Common Overhead Sources

#### Zod Parsing Cost

Zod schema parsing is synchronous and CPU-bound. Complex schemas on high-volume procedures can accumulate.

```ts
// Potentially expensive on high-frequency procedures
.input(
  z.object({
    filters: z.array(z.object({
      field: z.string(),
      op: z.enum(['eq', 'gt', 'lt', 'in']),
      value: z.union([z.string(), z.number(), z.array(z.string())]),
    })).max(20),
  })
)
```

To measure Zod's contribution specifically:

```ts
const schema = z.object({ id: z.string() });

const start = performance.now();
for (let i = 0; i < 10_000; i++) {
  schema.parse({ id: 'abc' });
}
console.log(`Zod parse x10k: ${(performance.now() - start).toFixed(2)}ms`);
```

[Inference] Simpler schemas have lower parse cost. If Zod parsing is a bottleneck, consider schema simplification or caching parsed results where input is predictable. Behavior depends on schema complexity and input size.

---

#### superjson Serialization Cost

If using superjson as a transformer, it adds serialization and deserialization cost beyond standard `JSON.stringify`.

```ts
import superjson from 'superjson';

const data = { date: new Date(), value: 42n };

const start = performance.now();
for (let i = 0; i < 10_000; i++) {
  superjson.stringify(data);
}
console.log(`superjson x10k: ${(performance.now() - start).toFixed(2)}ms`);
```

**Trade-off:** superjson supports `Date`, `BigInt`, `Map`, `Set`, and other non-JSON-native types. If you do not need these, switching to the default JSON transformer removes this cost. [Inference]

---

#### Context Creation Cost

`createContext` runs on every request. Expensive operations here (e.g., database lookups, token verification) directly inflate per-request latency.

```ts
// Potentially expensive if uncached
export async function createContext({ req }: CreateNextContextOptions) {
  const user = await db.user.findUnique({  // DB call on every request
    where: { token: req.headers.authorization }
  });
  return { user };
}
```

**Mitigation:** Cache auth lookups where safe (e.g., short-lived in-memory cache keyed by token), or defer user resolution into a lazy getter on the context object. [Inference] Caching introduces its own correctness tradeoffs — evaluate per use case.

---

### Profiling in Production

> ⚠️ Adding profiling instrumentation in production carries risk: increased log volume, latency from I/O writes, and potential exposure of sensitive path names. Apply carefully.

For production-safe profiling:

- **Sample, don't instrument every request.** Log timing only for a percentage of requests:

```ts
export const sampledTimingMiddleware = middleware(async ({ next, path }) => {
  const shouldSample = Math.random() < 0.01; // 1% sample rate
  const start = shouldSample ? performance.now() : 0;

  const result = await next();

  if (shouldSample) {
    console.log(`[sample] ${path}: ${(performance.now() - start).toFixed(2)}ms`);
  }

  return result;
});
```

- **Use structured logging** (e.g., JSON logs) so metrics can be aggregated by path in your logging platform.
- **Export to OpenTelemetry** for distributed tracing (covered separately).

---

### Profiling Checklist

| Stage | Tool / Method |
| --- | --- |
| Per-procedure latency | Timing middleware with `performance.now()` |
| tRPC framework baseline | No-op procedure benchmark |
| CPU bottlenecks | `node --prof` or Clinic.js |
| Load behavior | autocannon or k6 |
| Zod cost | Isolated parse loop benchmark |
| superjson cost | Isolated stringify benchmark |
| Context creation cost | Timestamp inside `createContext` |
| Production sampling | Sampled middleware at low rate |

---

**Conclusion:**
Profiling tRPC overhead is primarily an exercise in isolating layers: framework cost, Zod parsing, serialization, context creation, and middleware are all separable with targeted instrumentation. In most applications, [Inference] the dominant latency source is application logic (I/O, database), not tRPC itself — but profiling confirms this rather than assuming it. Begin with timing middleware for quick wins, escalate to load testing and CPU profiling for systemic issues.

**Next Steps:**

- Establish a no-op procedure baseline before optimizing anything
- Add sampled timing middleware to staging before production
- Cross-reference profiling data with database query logs to confirm where time is actually spent