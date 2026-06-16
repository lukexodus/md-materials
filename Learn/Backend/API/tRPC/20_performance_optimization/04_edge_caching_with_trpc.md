## Edge Caching with tRPC

Edge caching places responses in CDN nodes geographically close to users, eliminating origin round trips entirely for cache-hit requests. For tRPC, this requires deliberate configuration — the default setup produces responses that CDNs will not cache.

---

### Why tRPC Is Not Edge-Cached by Default

Out of the box, tRPC produces responses that CDNs treat as uncacheable for several reasons:

- No `Cache-Control` header is set, so CDNs default to pass-through behavior
- Batched requests produce URLs containing multiple procedure names and all serialized inputs, making cache keys too specific to produce hits across users
- POST requests (mutations) are never cached by CDNs by convention
- Authenticated requests with `Authorization` or `Cookie` headers are typically excluded from CDN caches

Making tRPC edge-cacheable requires addressing each of these explicitly.

---

### Prerequisites for Edge Caching a tRPC Procedure

A procedure is a candidate for edge caching only when all of the following hold:

- It is a `query` (not a mutation or subscription)
- Its result does not depend on the requesting user's identity or session
- Its result is identical for all users given the same input
- It is routed through a non-batching link so it gets its own stable URL
- The server sets appropriate `Cache-Control` headers via `responseMeta`

---

### Step 1 — Route Public Procedures Through `httpLink`

Batched URLs are not edge-cacheable. Public procedures must be routed through `httpLink` so each gets its own URL.

```ts
// src/utils/trpc.ts
import {
  createTRPCProxyClient,
  httpLink,
  httpBatchLink,
  splitLink,
} from '@trpc/client';
import type { AppRouter } from '../server/router';

export const trpc = createTRPCProxyClient<AppRouter>({
  links: [
    splitLink({
      condition: (op) => op.context.edge === true,
      true: httpLink({ url: '/api/trpc' }),
      false: httpBatchLink({ url: '/api/trpc' }),
    }),
  ],
});
```

**Usage:**

```ts
const { data } = trpc.public.getCategories.useQuery(undefined, {
  context: { edge: true },
  staleTime: 60_000,
});
```

This produces a stable, cacheable URL:

```
GET /api/trpc/public.getCategories?input=%7B%7D
```

Rather than a batched, effectively unique URL:

```
GET /api/trpc/public.getCategories,user.getSettings?batch=1&input=...
```

---

### Step 2 — Set `Cache-Control` Headers via `responseMeta`

Without response headers instructing the CDN to cache, no caching occurs regardless of URL stability.

```ts
// pages/api/trpc/[trpc].ts
import { nextApiHandler } from '@trpc/server/adapters/next';
import { appRouter } from '../../../server/router';

export default nextApiHandler({
  router: appRouter,
  createContext,
  responseMeta({ paths, errors, type }) {
    const isPublic = paths?.every((p) => p.startsWith('public.'));
    const isQuery = type === 'query';
    const noErrors = errors.length === 0;

    if (isPublic && isQuery && noErrors) {
      return {
        headers: {
          // CDN caches for 60s; serves stale for up to 5 minutes while revalidating
          'Cache-Control': 'public, s-maxage=60, stale-while-revalidate=300',
        },
      };
    }

    // Prevent caching of private or errored responses
    return {
      headers: {
        'Cache-Control': 'private, no-store',
      },
    };
  },
});
```

**Key Points**

- `s-maxage` is the CDN TTL. `max-age` is the browser TTL. Setting only `s-maxage` caches at the CDN but not in the browser — often the right choice for data you want to control centrally.
- `stale-while-revalidate` allows the CDN to immediately serve a stale response while fetching a fresh one in the background. This eliminates the latency spike at TTL expiry.
- Returning `private, no-store` as the fallback ensures that any response that does not explicitly qualify for caching is never cached.
- `errors.length === 0` is a required guard. Caching error responses at the edge means all users receive the error until the CDN TTL expires.

---

### `Cache-Control` Combination Patterns

| Pattern | Effect |
| --- | --- |
| `public, s-maxage=60` | CDN caches for 60s; browser does not cache |
| `public, max-age=60` | Browser caches for 60s; CDN may also cache |
| `public, s-maxage=60, stale-while-revalidate=300` | CDN caches 60s; serves stale for 300s more while refreshing |
| `public, s-maxage=0, stale-while-revalidate=86400` | CDN always revalidates but serves stale immediately |
| `private, no-store` | No caching at any layer |
| `no-cache` | CDN must revalidate before serving; not the same as `no-store` |

---

### Step 3 — Vary Headers for Input-Dependent Responses

When a procedure's result depends on its input (e.g., `getPostById({ id })`), the URL already encodes the input as a query parameter, making URLs input-specific by default. The CDN uses the full URL as the cache key, so different inputs naturally produce different cache entries.

However, if headers influence the response — such as an `Accept-Language` header affecting locale-specific content — the CDN must be instructed to vary its cache key on those headers.

```ts
if (isPublic && isQuery && noErrors) {
  return {
    headers: {
      'Cache-Control': 'public, s-maxage=60, stale-while-revalidate=300',
      'Vary': 'Accept-Language',
    },
  };
}
```

[Inference: `Vary: Authorization` or `Vary: Cookie` effectively disables CDN caching for most CDNs because nearly every request has a unique value for these headers. Avoid varying on auth-related headers for publicly cached responses.]

---

### CDN-Specific Configuration

Different CDN providers have different behaviors, terminology, and configuration surfaces. The `Cache-Control` header is the standard mechanism, but some CDNs require additional configuration.

#### Vercel

Vercel respects `Cache-Control` headers from Next.js API routes. The `s-maxage` directive populates Vercel's edge cache. Stale-while-revalidate is supported.

```ts
// No additional config needed beyond Cache-Control headers
// Vercel reads s-maxage and populates its edge network automatically
```

[Inference: Vercel's edge caching behavior for API routes may differ from its behavior for pages and edge functions. Verify current behavior against Vercel's documentation, as caching policies for API routes have changed across Next.js and Vercel platform versions.]

#### Cloudflare

Cloudflare caches `GET` responses by default only for static asset extensions. For API routes, explicit cache rules or `Cache-Control` headers with `public` are required.

```ts
// Cloudflare respects Cache-Control: public, s-maxage=N
// Additional cache rules can be configured in the Cloudflare dashboard
// or via Cloudflare Workers for fine-grained control
```

[Unverified: Cloudflare's default behavior for non-static API responses may vary by plan and configuration. Verify against current Cloudflare documentation.]

#### AWS CloudFront

CloudFront uses cache behaviors tied to URL path patterns. You configure which paths are cached and with what TTLs in the CloudFront distribution settings. `Cache-Control` headers from the origin are respected within the bounds of the configured TTL range.

```
Cache Behavior:
  Path Pattern: /api/trpc/public.*
  Cache Policy: CachingOptimized (or custom)
  Origin Request Policy: AllViewerExceptHostHeader
  TTL: Min 0, Default 60, Max 86400
```

[Unverified: the exact CloudFront cache behavior configuration depends on your distribution version and whether you use legacy cache settings or cache policies. Verify against current AWS documentation.]

---

### Edge Caching Flow

DatabaseOrigin ServerCDN Edge NodeUser (Browser)DatabaseOrigin ServerCDN Edge NodeUser (Browser)alt[Cache hit][Cache miss or expired]GET /api/trpc/public.getCategories?input={}Cached response (0ms origin latency)Forward requestQuery databaseResultResponse + Cache-Control: public, s-maxage=60Response (stored in edge cache)

---

### Stale-While-Revalidate Behavior

OriginCDN EdgeUser (t=62s)User (t=61s)User (t=0s)OriginCDN EdgeUser (t=62s)User (t=61s)User (t=0s)Request (cache miss)ForwardResponse, s-maxage=60, swr=300Fresh responseRequest (TTL expired, within SWR window)Stale response (immediate)Background revalidationFresh response storedRequest (after revalidation)Fresh response (no origin hit)

`stale-while-revalidate` eliminates the latency spike that would otherwise occur at TTL expiry, at the cost of one user receiving a slightly stale response during the revalidation window.

---

### Surrogate Keys and Tag-Based Invalidation

Some CDNs support tag-based (surrogate key) invalidation, which allows purging all cached responses associated with a logical entity — for example, all cached responses that include data for `post-123` — without knowing every specific URL.

**Cloudflare Cache Tags:**

```ts
responseMeta({ paths, errors, type, ctx }) {
  if (/* cacheable conditions */) {
    return {
      headers: {
        'Cache-Control': 'public, s-maxage=300',
        'Cache-Tag': `post-${ctx.postId}, category-${ctx.categoryId}`,
      },
    };
  }
  return {};
},
```

Purge by tag via Cloudflare API:

```ts
await fetch(
  `https://api.cloudflare.com/client/v4/zones/${ZONE_ID}/cache/tags`,
  {
    method: 'DELETE',
    headers: {
      'Authorization': `Bearer ${CF_API_TOKEN}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({ tags: [`post-${postId}`] }),
  }
);
```

[Unverified: Cloudflare Cache Tags are available on Enterprise plans. Availability on other plans may differ. Verify against current Cloudflare documentation.]

**Vercel `x-vercel-cache-tags`:**

[Unverified: Vercel's tag-based invalidation API and header names may have changed since the time of writing. Verify against current Vercel documentation before implementing.]

---

### On-Demand Revalidation

Rather than waiting for TTL expiry, you can trigger CDN cache invalidation from a mutation procedure.

**Vercel — revalidate a path:**

```ts
import { revalidatePath } from 'next/cache'; // Next.js 13+ App Router

updatePost: authedProcedure
  .input(z.object({ id: z.string(), title: z.string() }))
  .mutation(async ({ input }) => {
    const updated = await db.post.update({
      where: { id: input.id },
      data: { title: input.title },
    });

    // Invalidate the CDN-cached tRPC response for this post
    revalidatePath(`/api/trpc/public.getPostById`);
    return updated;
  }),
```

[Inference: `revalidatePath` in Next.js App Router targets page routes and may not directly purge API route caches in all configurations. Verify the interaction between `revalidatePath`, tRPC API routes, and Vercel's edge cache against current Next.js and Vercel documentation.]

---

### Combining Edge Cache with Server-Side Cache

Edge caching and server-side caching (Redis, LRU) are complementary:

yesnoyesnoRequestCDN cache hit?Serve from edgeOrigin serverServer cache hit?Serve from Redis/LRUDatabaseWrite to server cacheWrite Cache-ControlheaderCDN stores responseClient receives response

- CDN handles geographically distributed caching, eliminating origin round trips for the most frequently requested responses
- Server-side cache (Redis) handles the remaining origin requests, reducing database load when the CDN has not cached a response or the cache has been purged

---

### What Must Never Be Edge-Cached

- Any response derived from user session, identity, or authentication state
- Responses to POST requests (mutations)
- Responses containing `Set-Cookie` headers — most CDNs refuse to cache these or strip the cookie
- Responses with `Authorization` or `Cookie` in the `Vary` header
- Error responses

[Inference: some CDNs can be configured to cache authenticated responses using a stripped or transformed cache key. This is an advanced configuration that requires careful security review to avoid serving one user's data to another. It is not a default or recommended approach.]

---

### Common Pitfalls

**Caching batched responses at the edge** — A batched URL encodes all procedure names and all inputs. Different users making the same logical request in different batch combinations produce different URLs, yielding effectively zero cache hit rate. Always route edge-cacheable procedures through `httpLink`.

**Setting `Cache-Control: public` on responses that include user data** — If a single response contains both public and user-specific data, the entire response must be treated as private. Design procedures so public and private data are fetched separately.

**Not guarding on `errors.length`** — A `500` or `404` response cached at the edge serves that error to all users for the duration of the TTL. Always return `no-store` for error responses.

**Relying on `Cache-Control` alone without verifying CDN behavior** — CDNs interpret `Cache-Control` directives with varying fidelity. Test that your specific CDN is actually caching responses by inspecting CDN-specific headers in the response (e.g., `X-Cache: HIT`, `CF-Cache-Status: HIT`, `X-Vercel-Cache: HIT`).

**Forgetting `Vary` when response content depends on request headers** — A procedure whose output varies by `Accept-Language` but omits `Vary: Accept-Language` will serve cached content in one language to users requesting another.

**Treating `no-cache` as equivalent to `no-store`** — `no-cache` means the CDN must revalidate with the origin before serving. `no-store` means nothing is stored. For genuinely sensitive data, use `no-store`.

---

### Summary

Edge caching with tRPC requires four coordinated changes: routing public procedures through `httpLink` so each gets a stable, individually cacheable URL; setting `Cache-Control` headers with `responseMeta` to instruct CDNs to cache responses; designing procedures so that cacheable and user-specific data are cleanly separated; and implementing an invalidation strategy — TTL, tag-based purge, or on-demand revalidation — appropriate to how frequently data changes. Without all four in place, either the CDN does not cache, or it caches the wrong responses, serving stale or private data incorrectly.