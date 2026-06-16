## Iterating Based on Performance Profiling

### Overview

Performance profiling in a tRPC application involves identifying bottlenecks at the procedure level, the transport layer, the database query layer, and the client-side data-fetching layer. Once bottlenecks are located, targeted iterations — caching, batching, query optimization, or structural refactoring — are applied and measured against a baseline.

---

### What to Profile

tRPC applications have several distinct layers, each with its own performance characteristics:

```
Client (React)
  └── TanStack Query cache
        └── tRPC HTTP client (batching, links)
              └── HTTP transport (latency, payload size)
                    └── tRPC router (middleware, procedure execution)
                          └── Business logic / ORM
                                └── Database
```

Profiling should cover all layers rather than assuming the bottleneck is at any single point.

---

### Measuring Baseline Performance

Before iterating, establish a measurable baseline. Without a baseline, improvements cannot be quantified.

#### Server-Side Timing Middleware

```ts
// server/trpc.ts
import { initTRPC } from '@trpc/server';
import { performance } from 'perf_hooks';

const t = initTRPC.context<Context>().create();

export const timedProcedure = t.procedure.use(async ({ path, type, next }) => {
  const start = performance.now();
  const result = await next();
  const durationMs = performance.now() - start;

  console.log(JSON.stringify({
    path,
    type,
    durationMs: durationMs.toFixed(2),
    ok: result.ok,
  }));

  return result;
});
```

**Key Points**

- `performance.now()` provides sub-millisecond resolution. `Date.now()` is sufficient for coarse measurements but less precise.
- This middleware captures total procedure time including middleware chain execution and business logic, but excludes network transport time.
- [Inference] Logging every request in high-traffic production environments may add measurable overhead. Consider sampling (e.g., log 1 in 100 requests) using a flag or environment variable.

#### Capturing Per-Procedure Metrics

```ts
const procedureMetrics: Record<string, number[]> = {};

export const profilingMiddleware = t.middleware(async ({ path, next }) => {
  const start = performance.now();
  const result = await next();
  const duration = performance.now() - start;

  if (!procedureMetrics[path]) procedureMetrics[path] = [];
  procedureMetrics[path].push(duration);

  return result;
});

// Expose aggregated stats via a health/metrics procedure
export const appRouter = router({
  _metrics: publicProcedure.query(() => {
    return Object.entries(procedureMetrics).map(([path, durations]) => ({
      path,
      count: durations.length,
      avgMs: durations.reduce((a, b) => a + b, 0) / durations.length,
      maxMs: Math.max(...durations),
      p95Ms: durations.sort((a, b) => a - b)[Math.floor(durations.length * 0.95)],
    }));
  }),
});
```

[Inference] In-memory metric accumulation like this is suitable for single-instance development profiling. In multi-instance or serverless production deployments, metrics will not aggregate across instances. Use a dedicated metrics store (Prometheus, Datadog, etc.) in those environments.

---

### Profiling with OpenTelemetry

OpenTelemetry provides standardized distributed tracing that spans the full request lifecycle.

#### Setup

```bash
pnpm add @opentelemetry/sdk-node @opentelemetry/auto-instrumentations-node \
         @opentelemetry/exporter-otlp-http
```

```ts
// server/instrumentation.ts — import BEFORE all other modules
import { NodeSDK } from '@opentelemetry/sdk-node';
import { getNodeAutoInstrumentations } from '@opentelemetry/auto-instrumentations-node';
import { OTLPTraceExporter } from '@opentelemetry/exporter-otlp-http';

const sdk = new NodeSDK({
  traceExporter: new OTLPTraceExporter({
    url: process.env.OTEL_EXPORTER_OTLP_ENDPOINT,
  }),
  instrumentations: [getNodeAutoInstrumentations()],
});

sdk.start();
```

#### tRPC-Specific Spans

```ts
import { trace } from '@opentelemetry/api';

const tracer = trace.getTracer('trpc-server');

export const tracingMiddleware = t.middleware(async ({ path, type, next }) => {
  return tracer.startActiveSpan(`trpc.${type}.${path}`, async (span) => {
    try {
      const result = await next();
      span.setStatus({ code: result.ok ? 1 : 2 });
      return result;
    } finally {
      span.end();
    }
  });
});
```

Spans will appear in any OTLP-compatible backend: Jaeger, Tempo, Honeycomb, or Datadog APM.

---

### Identifying Slow Procedures

Once timing data is collected, sort procedures by average or p95 duration. Common patterns:

| Pattern | Likely Cause |
|---|---|
| One procedure consistently slow | N+1 query, missing index, heavy computation |
| All procedures slow after cold start | Unoptimized imports, large bundle |
| Procedures slow under concurrent load | Connection pool exhaustion |
| Intermittent slowness | Network jitter, GC pauses, lock contention |

---

### Optimizing Database Queries

#### Identifying N+1 Queries

N+1 is the most common database performance issue in tRPC procedures that return lists.

**Before (N+1):**

```ts
export const postRouter = router({
  list: publicProcedure.query(async () => {
    const posts = await db.post.findMany();
    // Executes one query per post — N+1
    return Promise.all(posts.map(async (post) => ({
      ...post,
      author: await db.user.findUnique({ where: { id: post.authorId } }),
    })));
  }),
});
```

**After (single query with include):**

```ts
export const postRouter = router({
  list: publicProcedure.query(async () => {
    return db.post.findMany({
      include: { author: true },
    });
  }),
});
```

[Inference] Prisma's `include` generates a `JOIN` or batched query depending on the relation type. The exact SQL emitted may vary. Verify with `prisma.$on('query', ...)` logging in development.

#### Enabling Prisma Query Logging

```ts
const db = new PrismaClient({
  log: [
    { emit: 'event', level: 'query' },
  ],
});

db.$on('query', (e) => {
  console.log(`Query: ${e.query}`);
  console.log(`Duration: ${e.duration}ms`);
});
```

#### Adding Database Indexes

If a procedure filters on a non-primary-key field and queries are slow:

```prisma
model Post {
  id        String   @id @default(cuid())
  authorId  String
  createdAt DateTime @default(now())

  @@index([authorId])
  @@index([createdAt])
}
```

```bash
pnpm prisma migrate dev --name add-post-indexes
```

**Key Points**

- Indexes improve read performance but add overhead to writes. Do not index every column indiscriminately.
- [Inference] Composite indexes (`@@index([authorId, createdAt])`) outperform separate indexes when both fields appear together in `WHERE` clauses, but this is query-dependent.

---

### Caching at the Procedure Level

#### In-Memory Cache (Simple)

```ts
import { LRUCache } from 'lru-cache';

const cache = new LRUCache<string, unknown>({
  max: 500,
  ttl: 1000 * 60 * 5, // 5 minutes
});

export const cachedProcedure = t.procedure.use(async ({ path, rawInput, next }) => {
  const key = `${path}:${JSON.stringify(rawInput)}`;
  const cached = cache.get(key);
  if (cached !== undefined) return cached as ReturnType<typeof next>;

  const result = await next();
  if (result.ok) cache.set(key, result);
  return result;
});
```

[Inference] In-memory caching does not survive process restarts and does not share state across multiple server instances. For multi-instance deployments, use Redis.

#### Redis Cache

```ts
import { createClient } from 'redis';

const redis = createClient({ url: process.env.REDIS_URL });
await redis.connect();

export const redisCachedMiddleware = t.middleware(async ({ path, rawInput, next }) => {
  const key = `trpc:${path}:${JSON.stringify(rawInput)}`;
  const cached = await redis.get(key);

  if (cached) {
    const parsed = JSON.parse(cached);
    return parsed;
  }

  const result = await next();

  if (result.ok) {
    await redis.setEx(key, 300, JSON.stringify(result)); // 300s TTL
  }

  return result;
});
```

**Key Points**

- Redis cache keys must account for user identity if the procedure returns user-specific data. Include user ID in the cache key or avoid caching authenticated procedures this way.
- [Inference] Caching mutation results is generally incorrect. Apply caching middleware only to query procedures.

---

### Optimizing tRPC Batch Requests

tRPC's `httpBatchLink` batches multiple concurrent client queries into a single HTTP request by default.

#### Verifying Batching is Active

```ts
// client/trpc.ts
import { httpBatchLink } from '@trpc/client';

export const trpc = createTRPCReact<AppRouter>();

export const trpcClient = trpc.createClient({
  links: [
    httpBatchLink({
      url: '/api/trpc',
      maxURLLength: 2083, // batches exceeding this split into multiple requests
    }),
  ],
});
```

#### Tuning Batch Size

If individual batched requests are large, they may time out or exceed URL length limits (for GET requests). Tune `maxURLLength` or switch to POST-based batching:

```ts
httpBatchLink({
  url: '/api/trpc',
  maxURLLength: 4096,
})
```

[Inference] Batching reduces the number of HTTP round trips but increases the size of individual requests. In environments with strict payload size limits (e.g., some API gateways), large batches may be rejected. Behavior is platform-dependent.

#### Disabling Batching Selectively

For procedures where latency matters more than request count (e.g., real-time dashboards), batching can introduce artificial delay waiting for other queries:

```ts
import { httpLink } from '@trpc/client';

// Per-client: disable batching entirely
trpc.createClient({
  links: [httpLink({ url: '/api/trpc' })],
});
```

Or use `splitLink` to route specific procedures unbatched:

```ts
import { splitLink, httpBatchLink, httpLink } from '@trpc/client';

trpc.createClient({
  links: [
    splitLink({
      condition: (op) => op.path === 'dashboard.realtime',
      true: httpLink({ url: '/api/trpc' }),
      false: httpBatchLink({ url: '/api/trpc' }),
    }),
  ],
});
```

---

### Client-Side Query Optimization

#### Stale Time Tuning

Every tRPC query backed by TanStack Query has a `staleTime`. Increasing it reduces refetch frequency.

```ts
// Global default
const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 1000 * 60 * 2, // 2 minutes
    },
  },
});
```

```ts
// Per-query override
const { data } = trpc.posts.list.useQuery(undefined, {
  staleTime: 1000 * 60 * 10, // 10 minutes for this query
});
```

#### Prefetching on the Server

For Next.js, prefetching tRPC queries server-side eliminates the client-side loading state entirely:

```ts
// app/page.tsx (Next.js App Router)
import { createServerSideHelpers } from '@trpc/react-query/server';
import { appRouter } from '@/server/trpc';

export default async function Page() {
  const helpers = createServerSideHelpers({
    router: appRouter,
    ctx: {},
  });

  await helpers.posts.list.prefetch();

  return (
    <HydrateClient state={helpers.dehydrate()}>
      <PostList />
    </HydrateClient>
  );
}
```

The client renders immediately with data — no loading spinner on first paint.

#### Avoiding Redundant Refetches

```ts
const { data } = trpc.user.profile.useQuery(undefined, {
  refetchOnWindowFocus: false,  // Don't refetch when tab regains focus
  refetchOnReconnect: false,    // Don't refetch on network reconnect
  refetchOnMount: false,        // Don't refetch if data is already in cache
});
```

**Key Points**

- [Inference] `refetchOnWindowFocus` is enabled by default in TanStack Query and may cause unexpected network traffic in apps where users frequently switch tabs. Disabling it globally is a common optimization in data-heavy dashboards.

---

### Payload Size Optimization

Large response payloads increase serialization cost and transfer time.

#### Select Only Required Fields

```ts
// Prisma — select instead of include
const posts = await db.post.findMany({
  select: {
    id: true,
    title: true,
    createdAt: true,
    author: {
      select: { name: true },
    },
  },
});
```

This avoids sending large fields (e.g., full post body) when only list metadata is needed.

#### Pagination

```ts
export const postRouter = router({
  list: publicProcedure
    .input(z.object({
      cursor: z.string().optional(),
      limit: z.number().min(1).max(100).default(20),
    }))
    .query(async ({ input }) => {
      const posts = await db.post.findMany({
        take: input.limit + 1,
        cursor: input.cursor ? { id: input.cursor } : undefined,
        orderBy: { createdAt: 'desc' },
      });

      const hasMore = posts.length > input.limit;
      return {
        items: posts.slice(0, input.limit),
        nextCursor: hasMore ? posts[input.limit - 1].id : undefined,
      };
    }),
});
```

Cursor-based pagination avoids the performance degradation of large `OFFSET` values in SQL.

---

### Profiling the Client Bundle

If the frontend is slow to load, the tRPC client setup or shared router types may be contributing to bundle size.

```bash
# Vite bundle analysis
pnpm add -D rollup-plugin-visualizer
```

```ts
// vite.config.ts
import { visualizer } from 'rollup-plugin-visualizer';

export default defineConfig({
  plugins: [
    visualizer({ open: true, filename: 'bundle-stats.html' }),
  ],
});
```

```bash
pnpm build
# Opens bundle-stats.html in the browser automatically
```

**Key Points**

- [Inference] tRPC itself has a small runtime footprint. Large bundles are more commonly caused by ORM code (e.g., Prisma client) being accidentally included in the frontend bundle via shared packages. Verify that server-only code is not imported on the client.

#### Preventing Server Code in Client Bundle

```ts
// packages/trpc/server.ts — add a server-only guard
import 'server-only'; // Next.js package; throws at build time if imported client-side
```

Or use path aliases to enforce the boundary:

```json
// tsconfig.json
{
  "paths": {
    "@trpc/server": ["./src/server/trpc.ts"]
  }
}
```

---

### Iterative Profiling Loop

```
1. Measure — collect baseline metrics (p50, p95, p99 durations per procedure)
2. Identify — find the highest-impact bottleneck
3. Hypothesize — form a specific, testable explanation
4. Change — make one targeted change
5. Measure again — compare against baseline
6. Accept or revert — keep the change if it improves the metric; revert if not
```

Making multiple changes simultaneously makes it impossible to isolate what caused an improvement or regression.

---

### Performance Profiling Diagram

<svg viewBox="0 0 720 420" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="13">
  <!-- Background -->
  <rect width="720" height="420" fill="#0f1117" rx="12"/>

  <!-- Title -->
  <text x="360" y="36" text-anchor="middle" fill="#e2e8f0" font-size="15" font-weight="bold">tRPC Performance Profiling Layers</text>

  <!-- Layer boxes -->
  <!-- Client -->
  <rect x="60" y="60" width="600" height="52" rx="6" fill="#1e2130" stroke="#4f46e5" stroke-width="1.5"/>
  <text x="80" y="81" fill="#a5b4fc" font-weight="bold">CLIENT</text>
  <text x="80" y="100" fill="#94a3b8" font-size="11">TanStack Query cache · staleTime · prefetch · refetch config</text>
  <text x="640" y="91" text-anchor="end" fill="#64748b" font-size="11">Bundle size · hydration cost</text>

  <!-- Transport -->
  <rect x="60" y="128" width="600" height="52" rx="6" fill="#1e2130" stroke="#0ea5e9" stroke-width="1.5"/>
  <text x="80" y="149" fill="#7dd3fc" font-weight="bold">TRANSPORT</text>
  <text x="80" y="168" fill="#94a3b8" font-size="11">httpBatchLink · batch size · maxURLLength · splitLink routing</text>
  <text x="640" y="158" text-anchor="end" fill="#64748b" font-size="11">Round trips · payload size</text>

  <!-- Middleware -->
  <rect x="60" y="196" width="600" height="52" rx="6" fill="#1e2130" stroke="#f59e0b" stroke-width="1.5"/>
  <text x="80" y="217" fill="#fcd34d" font-weight="bold">MIDDLEWARE / ROUTER</text>
  <text x="80" y="236" fill="#94a3b8" font-size="11">Auth checks · timing middleware · input validation · tracing spans</text>
  <text x="640" y="226" text-anchor="end" fill="#64748b" font-size="11">Middleware chain cost</text>

  <!-- Business Logic -->
  <rect x="60" y="264" width="600" height="52" rx="6" fill="#1e2130" stroke="#10b981" stroke-width="1.5"/>
  <text x="80" y="285" fill="#6ee7b7" font-weight="bold">BUSINESS LOGIC / ORM</text>
  <text x="80" y="304" fill="#94a3b8" font-size="11">N+1 detection · select projection · pagination · in-memory / Redis cache</text>
  <text x="640" y="294" text-anchor="end" fill="#64748b" font-size="11">CPU · serialization</text>

  <!-- Database -->
  <rect x="60" y="332" width="600" height="52" rx="6" fill="#1e2130" stroke="#ec4899" stroke-width="1.5"/>
  <text x="80" y="353" fill="#f9a8d4" font-weight="bold">DATABASE</text>
  <text x="80" y="372" fill="#94a3b8" font-size="11">Query plans · indexes · connection pooling · migration timing</text>
  <text x="640" y="362" text-anchor="end" fill="#64748b" font-size="11">I/O · lock contention</text>

  <!-- Arrows -->
  <line x1="360" y1="112" x2="360" y2="128" stroke="#475569" stroke-width="1.5" marker-end="url(#arrow)"/>
  <line x1="360" y1="180" x2="360" y2="196" stroke="#475569" stroke-width="1.5" marker-end="url(#arrow)"/>
  <line x1="360" y1="248" x2="360" y2="264" stroke="#475569" stroke-width="1.5" marker-end="url(#arrow)"/>
  <line x1="360" y1="316" x2="360" y2="332" stroke="#475569" stroke-width="1.5" marker-end="url(#arrow)"/>

  <defs>
    <marker id="arrow" markerWidth="8" markerHeight="8" refX="4" refY="4" orient="auto">
      <path d="M0,0 L0,8 L8,4 z" fill="#475569"/>
    </marker>
  </defs>
</svg>

---

**Related Topics**

- Load testing tRPC endpoints with `k6` or `autocannon`
- Streaming responses and deferred data with tRPC subscriptions
- Edge caching strategies (CDN-level caching for public tRPC queries)
- Profiling Prisma query plans with `EXPLAIN ANALYZE`
- React DevTools Profiler integration with TanStack Query
- Reducing cold start time in serverless tRPC deployments
- Per-user rate limiting as a stability measure under load
- Prometheus + Grafana dashboard setup for tRPC metrics