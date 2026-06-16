## Caching Strategies on the Server

Server-side caching in tRPC reduces the cost of repeated procedure calls by storing and reusing results. Because tRPC procedures are plain functions, caching can be applied at multiple layers — HTTP response headers, in-process memory, distributed caches, and CDN edge nodes — with different trade-offs at each level.

---

### Where Caching Can Be Applied

HTTP requestcache misscache missClientCDNProxyServerResponse Middleware /HeadersProcedure LayerIn-process CacheDatabase

Each layer has different scope, invalidation characteristics, and operational cost.

---

### Layer Overview

| Layer | Scope | Invalidation | Latency Saved |
| --- | --- | --- | --- |
| CDN / edge cache | Global | TTL, purge API | Full round trip |
| HTTP response headers | Per client | TTL (`Cache-Control`) | Full round trip |
| Distributed cache (Redis) | Cross-process | Explicit or TTL | DB round trip |
| In-process memory cache | Single server instance | TTL, explicit | DB round trip |
| React Query / SWR | Per browser tab | TTL, refetch | Full round trip |

This document covers the server-side layers: HTTP headers, in-process caching, and distributed caching.

---

### HTTP Response Headers and `responseMeta`

tRPC adapters expose a `responseMeta` option that allows setting HTTP response headers — including caching headers — based on the procedure path, input, result, or errors.

```ts
// pages/api/trpc/[trpc].ts (Next.js)
import { nextApiHandler } from '@trpc/server/adapters/next';
import { appRouter } from '../../../server/router';

export default nextApiHandler({
  router: appRouter,
  createContext,
  responseMeta({ paths, errors, type }) {
    const allPublic = paths?.every((path) => path.startsWith('public.'));
    const noErrors = errors.length === 0;
    const isQuery = type === 'query';

    if (allPublic && noErrors && isQuery) {
      return {
        headers: {
          'Cache-Control': 'public, s-maxage=60, stale-while-revalidate=300',
        },
      };
    }

    return {};
  },
});
```

**Key Points**

- `paths` is an array of procedure paths in the current request. For batched requests it may contain multiple paths.
- `errors` contains any errors thrown during the request. Always return conservative cache headers (or none) when errors are present.
- `type` distinguishes `query`, `mutation`, and `subscription`. Only queries are semantically appropriate for caching.
- `s-maxage` controls the CDN cache TTL; `max-age` controls the browser cache TTL; `stale-while-revalidate` allows stale content to be served while a background refresh occurs.

---

### `Cache-Control` Directive Reference

| Directive | Effect |
| --- | --- |
| `public` | Response may be cached by CDN and shared caches |
| `private` | Response may only be cached by the browser (not CDN) |
| `no-store` | Response must not be cached at any layer |
| `max-age=N` | Browser cache TTL in seconds |
| `s-maxage=N` | CDN / shared cache TTL in seconds (overrides `max-age` for CDNs) |
| `stale-while-revalidate=N` | Serve stale content for N seconds while fetching fresh content in background |
| `stale-if-error=N` | Serve stale content for N seconds if origin returns an error |
| `must-revalidate` | Cache must revalidate with origin once TTL expires |

---

### Differentiating Public and Private Procedures

A common pattern is to namespace public (unauthenticated, cacheable) procedures and private (user-specific, non-cacheable) procedures, then use `responseMeta` to apply different cache headers per namespace.

```ts
export const appRouter = t.router({
  public: t.router({
    getCategories: publicProcedure.query(() => db.category.findMany()),
    getPostById: publicProcedure
      .input(z.object({ id: z.string() }))
      .query(({ input }) => db.post.findUnique({ where: { id: input.id } })),
  }),
  user: t.router({
    getProfile: authedProcedure.query(({ ctx }) => ctx.user),
    getSettings: authedProcedure.query(({ ctx }) => db.settings.findUnique({ where: { userId: ctx.user.id } })),
  }),
});
```

```ts
responseMeta({ paths, errors, type }) {
  const allPublic = paths?.every((p) => p.startsWith('public.'));
  const noErrors = errors.length === 0;

  if (allPublic && noErrors && type === 'query') {
    return {
      headers: { 'Cache-Control': 'public, s-maxage=120, stale-while-revalidate=600' },
    };
  }

  if (!allPublic) {
    return {
      headers: { 'Cache-Control': 'private, no-store' },
    };
  }

  return {};
},
```

---

### Batching and CDN Caching Conflict

Batched requests combine multiple procedure names into a single URL. This makes CDN caching largely ineffective for batched queries because:

- The cache key is the full URL, which includes all procedure names and all inputs
- Two users requesting the same public procedure but in different batches produce different URLs and different cache keys
- A cached batch result is only reusable for an identical combination of procedures and inputs

**Resolution:** Route publicly cacheable procedures through `httpLink` (no batching) via `splitLink`, so each gets its own stable, cacheable URL.

```ts
// Client configuration
splitLink({
  condition: (op) => op.context.cacheable === true,
  true: httpLink({ url: '/api/trpc' }),
  false: httpBatchLink({ url: '/api/trpc' }),
})
```

```ts
// Usage
const { data } = trpc.public.getCategories.useQuery(undefined, {
  context: { cacheable: true },
  staleTime: 120_000,
});
```

---

### In-Process Caching with a Simple Map

The simplest form of server-side result caching uses a `Map` to store results in memory within the server process. This is suitable for development, low-traffic services, or data that rarely changes.

```ts
// src/server/cache/inProcess.ts
interface CacheEntry<T> {
  value: T;
  expiresAt: number;
}

const store = new Map<string, CacheEntry<unknown>>();

export function getCached<T>(key: string): T | undefined {
  const entry = store.get(key);
  if (!entry) return undefined;
  if (Date.now() > entry.expiresAt) {
    store.delete(key);
    return undefined;
  }
  return entry.value as T;
}

export function setCached<T>(key: string, value: T, ttlMs: number): void {
  store.set(key, { value, expiresAt: Date.now() + ttlMs });
}

export function invalidateCached(key: string): void {
  store.delete(key);
}
```

**Usage in a procedure:**

```ts
import { getCached, setCached } from '../cache/inProcess';

export const appRouter = t.router({
  public: t.router({
    getCategories: publicProcedure.query(async () => {
      const cacheKey = 'public:getCategories';
      const cached = getCached<Category[]>(cacheKey);
      if (cached) return cached;

      const result = await db.category.findMany();
      setCached(cacheKey, result, 60_000); // 60 seconds TTL
      return result;
    }),
  }),
});
```

**Key Points**

- In-process caches do not survive server restarts.
- In multi-instance deployments (multiple server processes), each instance maintains its own cache. Cache state is not shared, and invalidation on one instance does not propagate to others.
- A `Map` has no built-in size limit. Under high cardinality (many unique cache keys), memory usage grows unboundedly. [Inference: for production use, an LRU-bounded cache is safer than a plain `Map`.]

---

### In-Process Caching with an LRU Cache

An LRU (Least Recently Used) cache evicts the least recently accessed entries when the cache reaches its size limit, bounding memory usage.

```bash
npm install lru-cache
```

```ts
// src/server/cache/lru.ts
import { LRUCache } from 'lru-cache';

const cache = new LRUCache<string, unknown>({
  max: 500,          // Maximum number of entries
  ttl: 60_000,       // Default TTL in milliseconds
  ttlAutopurge: true,
});

export function getCachedLRU<T>(key: string): T | undefined {
  return cache.get(key) as T | undefined;
}

export function setCachedLRU<T>(key: string, value: T, ttlMs?: number): void {
  cache.set(key, value, ttlMs ? { ttl: ttlMs } : undefined);
}

export function invalidateLRU(key: string): void {
  cache.delete(key);
}

export function invalidateByPrefix(prefix: string): void {
  for (const key of cache.keys()) {
    if (key.startsWith(prefix)) cache.delete(key);
  }
}
```

**Usage:**

```ts
getCategories: publicProcedure.query(async () => {
  const key = 'categories:all';
  const cached = getCachedLRU<Category[]>(key);
  if (cached) return cached;

  const result = await db.category.findMany();
  setCachedLRU(key, result, 120_000);
  return result;
}),
```

---

### Distributed Caching with Redis

For multi-instance deployments, a distributed cache like Redis ensures all server instances share the same cached state and that invalidation propagates everywhere.

```bash
npm install ioredis
```

```ts
// src/server/cache/redis.ts
import Redis from 'ioredis';

const redis = new Redis(process.env.REDIS_URL ?? 'redis://localhost:6379');

export async function getRedis<T>(key: string): Promise<T | null> {
  const raw = await redis.get(key);
  if (!raw) return null;
  try {
    return JSON.parse(raw) as T;
  } catch {
    return null;
  }
}

export async function setRedis<T>(key: string, value: T, ttlSeconds: number): Promise<void> {
  await redis.set(key, JSON.stringify(value), 'EX', ttlSeconds);
}

export async function invalidateRedis(key: string): Promise<void> {
  await redis.del(key);
}

export async function invalidateByPattern(pattern: string): Promise<void> {
  const keys = await redis.keys(pattern);
  if (keys.length > 0) await redis.del(...keys);
}
```

**Usage in a procedure:**

```ts
getPostById: publicProcedure
  .input(z.object({ id: z.string() }))
  .query(async ({ input }) => {
    const key = `post:${input.id}`;
    const cached = await getRedis<Post>(key);
    if (cached) return cached;

    const post = await db.post.findUnique({ where: { id: input.id } });
    if (!post) throw new TRPCError({ code: 'NOT_FOUND' });

    await setRedis(key, post, 300); // 5 minutes TTL
    return post;
  }),
```

**Key Points**

- `JSON.parse` / `JSON.stringify` handles serialization. Types that are not JSON-serializable (e.g., `Date`, `Map`, `BigInt`) require a custom serializer or a transformer like superjson. [Inference: storing a `Date` via `JSON.stringify` will deserialize as a string, not a `Date`. This is a common source of type mismatch bugs.]
- `KEYS` is suitable for low-traffic invalidation by pattern but scans the entire keyspace. For high-traffic production use, prefer structured key namespacing and `DEL` by exact key rather than `KEYS` with a glob pattern.

---

### Cache Key Design

Cache key design determines both cache hit rate and invalidation precision. A poor key strategy produces either too many misses (keys too specific) or stale data (keys too broad).

**Recommended key structure:**

```
{namespace}:{procedure}:{serialized-input}
```

```ts
function buildCacheKey(procedure: string, input: unknown): string {
  return `trpc:${procedure}:${JSON.stringify(input)}`;
}
```

**Examples:**

```
trpc:public.getCategories:null
trpc:public.getPostById:{"id":"post-123"}
trpc:user.getDashboard:{"userId":"u-456"}
```

**Key Points**

- Include all inputs that affect the result. Omitting an input dimension causes different inputs to share a cache entry.
- For procedures with no input, use a fixed suffix (e.g., `:null` or `:all`) to make the key explicit.
- Namespace keys by procedure path so `invalidateByPrefix('trpc:public.getPostById:')` can purge all cached variants of one procedure without affecting others.

---

### Cache-Aside Pattern

All examples above follow the cache-aside pattern: the application is responsible for reading from and writing to the cache explicitly.

yesnoProcedureCache hit?Return cached valueDatabaseWrite to cacheReturn value

This is the most common pattern for tRPC procedures because it is explicit, easy to reason about, and gives full control over TTL and invalidation per procedure.

---

### Caching in Middleware

Caching logic can be extracted into a tRPC middleware, applied to any procedure that opts in. This centralizes the cache read/write logic and keeps procedure resolvers clean.

```ts
// src/server/middleware/withCache.ts
import { getCachedLRU, setCachedLRU } from '../cache/lru';

export function withCache<T>(ttlMs: number) {
  return t.middleware(async ({ path, rawInput, next }) => {
    const key = `trpc:${path}:${JSON.stringify(rawInput)}`;
    const cached = getCachedLRU<T>(key);
    if (cached !== undefined) {
      return { ok: true, data: cached, marker: 'middlewareMarker' } as any;
    }

    const result = await next();

    if (result.ok) {
      setCachedLRU(key, result.data, ttlMs);
    }

    return result;
  });
}
```

[Inference: accessing `result.ok` and `result.data` on the middleware result object depends on the internal shape of tRPC's middleware result type, which is not part of the public API surface and may change across versions. Treat middleware-level caching as an advanced pattern requiring validation against your exact version.]

**Usage:**

```ts
const cachedProcedure = t.procedure.use(withCache(60_000));

export const appRouter = t.router({
  public: t.router({
    getCategories: cachedProcedure.query(() => db.category.findMany()),
  }),
});
```

---

### Invalidation Strategies

Caching without a reliable invalidation strategy leads to stale data. The appropriate strategy depends on how frequently data changes and how much staleness is acceptable.

| Strategy | Mechanism | Suitable When |
| --- | --- | --- |
| TTL expiry | Cache entry expires after N seconds | Data changes infrequently; brief staleness acceptable |
| Write-through invalidation | Mutation procedure deletes or updates cache entry | Data changes via known mutations in the same codebase |
| Event-driven invalidation | External event (webhook, queue) triggers cache purge | Data changes from outside the application |
| Versioned keys | Cache key includes a version token; bump token to invalidate all | Global invalidation needed; no partial invalidation |

**Write-through invalidation example:**

```ts
updatePost: authedProcedure
  .input(z.object({ id: z.string(), title: z.string() }))
  .mutation(async ({ input }) => {
    const updated = await db.post.update({
      where: { id: input.id },
      data: { title: input.title },
    });
    // Invalidate the cached read for this post
    await invalidateRedis(`trpc:public.getPostById:${JSON.stringify({ id: input.id })}`);
    return updated;
  }),
```

---

### Caching and `responseMeta` Together

HTTP response headers and server-side caching work at different layers and complement each other:

- **`responseMeta` + CDN** — caches the HTTP response at the edge, serving identical requests without reaching the origin server at all
- **Server-side cache (Redis/LRU)** — reduces database load when the request does reach the origin

For maximum efficiency, use both: CDN caching for public, stable responses; in-process or Redis caching for data that is expensive to compute but changes too frequently for CDN TTLs.

---

### Common Pitfalls

**Caching authenticated or user-specific data with `public` headers** — If `Cache-Control: public` is set on a response containing user-specific data, a CDN may serve one user's data to another. Always use `private, no-store` for any response derived from user identity or session state.

**Not including all input dimensions in the cache key** — A procedure that filters by `status` but omits `status` from the cache key will return cached results for one status when a different status is requested.

**Using `KEYS` with glob patterns in production Redis** — `KEYS` blocks the Redis event loop during the scan. For high-throughput services, use `SCAN` instead or maintain explicit invalidation sets.

**Caching error responses** — If an error result is stored in the cache, all subsequent requests will receive the cached error until the TTL expires. Only cache successful results.

**Ignoring serialization mismatches** — `Date`, `undefined`, `BigInt`, and class instances do not round-trip through `JSON.stringify`/`JSON.parse` correctly. Use superjson or a custom serializer when these types appear in cached results.

**In-process cache in serverless environments** — Serverless functions are stateless and short-lived. An in-process `Map` or LRU cache is reset on every cold start and not shared between concurrent invocations. Use Redis or an external cache for serverless deployments.

---

### Summary

Server-side caching in tRPC operates at multiple independent layers: HTTP response headers control what CDNs and browsers cache; in-process LRU caches reduce database round trips within a single server instance; Redis provides a shared cache across multiple instances. Each layer requires deliberate cache key design, a clear invalidation strategy, and careful separation of public and private data. The most robust production configurations combine CDN caching for public procedures (routed through `httpLink` to preserve cacheable URLs) with Redis for expensive cross-instance data, and write-through invalidation in mutation procedures.