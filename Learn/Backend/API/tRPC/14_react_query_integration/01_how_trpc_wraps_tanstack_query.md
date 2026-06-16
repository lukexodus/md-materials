## tRPC — How tRPC wraps TanStack Query

### Overview

tRPC's React integration (`@trpc/react-query`) does not implement its own data-fetching or caching layer. Instead, it generates a set of typed wrappers around TanStack Query's existing hooks — `useQuery`, `useMutation`, `useInfiniteQuery`, and others. The result is that all caching, background refetching, invalidation, and synchronization behavior comes directly from TanStack Query. tRPC contributes type safety and query key management on top of it.

**Key Points**

- tRPC does not replace TanStack Query — it wraps it
- Every `trpc.x.useQuery()` call delegates to TanStack Query's `useQuery` internally
- The underlying `QueryClient` is the same standard TanStack Query `QueryClient`
- TanStack Query behavior (stale time, retry, cache time) applies without modification [Inference: unless tRPC sets defaults in its internal configuration; verify against the version in use]

---

### Setup: Two Providers

The integration requires two providers in the React tree — one for tRPC and one for TanStack Query.

```tsx
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { httpBatchLink } from '@trpc/client';
import { createTRPCReact } from '@trpc/react-query';
import type { AppRouter } from '../server/router';

export const trpc = createTRPCReact<AppRouter>();

const queryClient = new QueryClient();

const trpcClient = trpc.createClient({
  links: [
    httpBatchLink({ url: 'http://localhost:3000/api/trpc' }),
  ],
});

export function App() {
  return (
    <trpc.Provider client={trpcClient} queryClient={queryClient}>
      <QueryClientProvider client={queryClient}>
        <YourApp />
      </QueryClientProvider>
    </trpc.Provider>
  );
}
```

**Key Points**

- `trpc.Provider` receives both the tRPC client and the `QueryClient`
- `QueryClientProvider` must also wrap the tree — tRPC's provider does not replace it
- Both providers reference the **same** `QueryClient` instance — this is required for invalidation and shared cache access to work correctly

---

### `createTRPCReact` — What It Produces

`createTRPCReact<AppRouter>()` returns a proxy object that mirrors the shape of your router. Each leaf procedure on the router becomes an object with hook methods attached.

```ts
// Given a router with:
// appRouter.user.getById
// appRouter.user.create
// appRouter.post.list

trpc.user.getById.useQuery(...)
trpc.user.create.useMutation(...)
trpc.post.list.useInfiniteQuery(...)
```

The proxy is traversed at call time — no code is generated at build time. [Inference: the proxy is built dynamically using JavaScript `Proxy` objects; exact implementation details may vary across versions.]

---

### How `useQuery` Is Wrapped

When you call `trpc.someRoute.useQuery(input, options)`, tRPC:

1. Serializes the procedure path and input into a **query key**
2. Constructs a `queryFn` that calls the tRPC client with that path and input
3. Passes both the key and the function to TanStack Query's `useQuery`
4. Returns TanStack Query's result object directly

```tsx
// What you write
const result = trpc.user.getById.useQuery({ id: '1' });

// Approximate internal equivalent [Inference]
const result = useQuery({
  queryKey: [['user', 'getById'], { input: { id: '1' }, type: 'query' }],
  queryFn: () => trpcClient.user.getById.query({ id: '1' }),
});
```

The returned `result` object is the standard TanStack Query result — `data`, `error`, `isLoading`, `isFetching`, `status`, and so on. tRPC does not wrap or transform this object. [Inference: any tRPC-specific fields, if present, would be additions; verify against current type definitions.]

---

### Query Key Structure

tRPC manages query keys internally using a consistent structure. Understanding this is necessary for manual cache operations.

The key shape used by `@trpc/react-query` is:

```ts
[path: string[], { input: TInput; type: 'query' | 'infinite' }]
// Example:
[['user', 'getById'], { input: { id: '1' }, type: 'query' }]
```

tRPC exposes a `getQueryKey` utility for working with these keys outside of hooks:

```ts
import { getQueryKey } from '@trpc/react-query';

const key = getQueryKey(trpc.user.getById, { id: '1' }, 'query');
queryClient.invalidateQueries({ queryKey: key });
```

This avoids constructing the key manually, which would be fragile if the internal format changes across versions.

---

### Flow Diagram

<svg viewBox="0 0 680 370" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="12">
  <rect width="680" height="370" fill="#0f1117" rx="12"/>
  <text x="340" y="28" text-anchor="middle" fill="#94a3b8" font-size="12">tRPC React Query — internal call flow</text>

  <!-- Component -->
  <rect x="240" y="48" width="200" height="40" rx="6" fill="#1e293b" stroke="#475569" stroke-width="1.5"/>
  <text x="340" y="73" text-anchor="middle" fill="#e2e8f0" font-size="12">React Component</text>

  <!-- trpc hook -->
  <rect x="200" y="138" width="280" height="40" rx="6" fill="#1e3a5f" stroke="#3b82f6" stroke-width="1.5"/>
  <text x="340" y="157" text-anchor="middle" fill="#93c5fd" font-size="11">trpc.user.getById.useQuery(input)</text>
  <text x="340" y="171" text-anchor="middle" fill="#64748b" font-size="10">@trpc/react-query proxy</text>

  <!-- TanStack useQuery -->
  <rect x="180" y="228" width="320" height="40" rx="6" fill="#2d1f4a" stroke="#a78bfa" stroke-width="1.5"/>
  <text x="340" y="247" text-anchor="middle" fill="#c4b5fd" font-size="11">TanStack Query — useQuery(key, queryFn)</text>
  <text x="340" y="261" text-anchor="middle" fill="#64748b" font-size="10">manages cache, background refetch, status</text>

  <!-- tRPC client -->
  <rect x="40" y="318" width="200" height="36" rx="6" fill="#1a3a2a" stroke="#22c55e" stroke-width="1.5"/>
  <text x="140" y="341" text-anchor="middle" fill="#86efac" font-size="11">tRPC client (link chain)</text>

  <!-- QueryClient cache -->
  <rect x="440" y="318" width="200" height="36" rx="6" fill="#2a1a1a" stroke="#f87171" stroke-width="1.5"/>
  <text x="540" y="341" text-anchor="middle" fill="#fca5a5" font-size="11">QueryClient cache</text>

  <!-- Arrows -->
  <defs>
    <marker id="a1" markerWidth="8" markerHeight="8" refX="6" refY="3" orient="auto">
      <path d="M0,0 L0,6 L8,3 z" fill="#64748b"/>
    </marker>
  </defs>

  <!-- Component -> trpc hook -->
  <line x1="340" y1="88" x2="340" y2="136" stroke="#64748b" stroke-width="1.5" marker-end="url(#a1)"/>
  <text x="348" y="116" fill="#475569" font-size="10">calls</text>

  <!-- trpc hook -> useQuery -->
  <line x1="340" y1="178" x2="340" y2="226" stroke="#64748b" stroke-width="1.5" marker-end="url(#a1)"/>
  <text x="348" y="208" fill="#475569" font-size="10">delegates to</text>

  <!-- useQuery -> tRPC client -->
  <line x1="270" y1="268" x2="200" y2="316" stroke="#64748b" stroke-width="1.5" marker-end="url(#a1)"/>
  <text x="190" y="300" fill="#475569" font-size="10">queryFn</text>

  <!-- useQuery -> cache -->
  <line x1="420" y1="268" x2="490" y2="316" stroke="#64748b" stroke-width="1.5" marker-end="url(#a1)"/>
  <text x="456" y="300" fill="#475569" font-size="10">read/write</text>
</svg>

---

### `useMutation` Wrapper

`trpc.someRoute.useMutation()` wraps TanStack Query's `useMutation`. The procedure path determines which server endpoint is called; input is passed at call time via `mutate` or `mutateAsync`.

```tsx
const createUser = trpc.user.create.useMutation({
  onSuccess: (data) => {
    queryClient.invalidateQueries({ queryKey: getQueryKey(trpc.user.list) });
  },
});

// Trigger the mutation
createUser.mutate({ name: 'Alice', email: 'alice@example.com' });
```

Unlike `useQuery`, mutations are not tied to a query key for caching — TanStack Query does not cache mutation results by default, and tRPC does not change this behavior.

---

### `useInfiniteQuery` Wrapper

`trpc.someRoute.useInfiniteQuery` wraps TanStack Query's `useInfiniteQuery`. The procedure must accept a `cursor` input for pagination to function correctly.

```tsx
const posts = trpc.post.list.useInfiniteQuery(
  { limit: 10 },
  {
    getNextPageParam: (lastPage) => lastPage.nextCursor,
  }
);
```

**Key Points**

- The `cursor` value is injected automatically by TanStack Query on each page fetch via `pageParam`
- The procedure on the server must accept and use this `cursor` field
- All TanStack Query infinite query behavior (page grouping, `fetchNextPage`, `hasNextPage`) applies unchanged

---

### Passing TanStack Query Options

All standard TanStack Query options pass through to the underlying hook. tRPC does not restrict or transform them.

```tsx
trpc.user.getById.useQuery(
  { id: '1' },
  {
    staleTime: 60_000,
    refetchOnWindowFocus: false,
    enabled: !!userId,
    retry: 2,
    onSuccess: (data) => console.log(data),
  }
);
```

These options are the same options accepted by TanStack Query's `useQuery` directly. [Inference: tRPC may add a small number of its own options alongside these; consult the `@trpc/react-query` type definitions for the version in use.]

---

### Context Hook — `useContext` / `useUtils`

tRPC exposes a typed wrapper around the `QueryClient` for imperative cache operations. In recent versions this is accessed via `trpc.useUtils()` (older versions used `trpc.useContext()`).

```tsx
function UserActions() {
  const utils = trpc.useUtils();

  const invalidate = () => {
    utils.user.getById.invalidate({ id: '1' });
  };

  const prefetch = () => {
    utils.user.list.prefetch();
  };

  const setData = () => {
    utils.user.getById.setData({ id: '1' }, (prev) => ({
      ...prev,
      name: 'Updated Name',
    }));
  };

  return <button onClick={invalidate}>Invalidate</button>;
}
```

**Key Points**

- `useUtils()` returns a typed proxy over the `QueryClient`
- Each method (`invalidate`, `prefetch`, `setData`, `getData`, `cancel`) maps to the corresponding TanStack Query `QueryClient` method
- The query key is computed automatically from the procedure path and input — manual key construction is not required
- This is the preferred approach over calling `queryClient` methods directly, because the key format is abstracted away

---

### What tRPC Does Not Change

| TanStack Query Behavior | Changed by tRPC? |
|---|---|
| Cache storage and eviction | No |
| Background refetch logic | No |
| Stale time and cache time | No |
| Retry logic | No |
| Devtools compatibility | No — React Query Devtools work normally |
| `QueryClient` API | No — same instance, same methods |
| `suspense` mode | No |
| Optimistic updates | No |

All of these remain the responsibility of TanStack Query. tRPC is a typed adapter layer, not a replacement.

---

### Summary

tRPC's React integration intercepts procedure calls on the typed proxy, converts them into query keys and query functions, and passes them to TanStack Query's standard hooks. The developer interacts with a typed, router-aware API surface, while TanStack Query handles all data lifecycle concerns underneath. The two systems share a single `QueryClient` instance, which means the full TanStack Query ecosystem — devtools, cache manipulation, invalidation, prefetching — remains available and works as documented by TanStack Query.

---

**Next Steps**

- Query key structure and `getQueryKey` in depth
- `useUtils` / `useContext` — cache operations via typed proxy
- Optimistic updates with tRPC and TanStack Query
- Suspense mode with `useSuspenseQuery`