## SSR and Hydration Patterns in TanStack Query

---

### Overview

Server-Side Rendering (SSR) with TanStack Query involves prefetching data on the server, serializing that data into the HTML payload, and then rehydrating it on the client so React can pick up without redundant network requests. TanStack Query v5 introduced a significantly revised approach to this workflow, replacing the older `initialData` pattern and the v4 `dehydrate`/`Hydrate` component model with a more robust, streaming-compatible architecture.

---

### Core Concepts

#### The Dehydration/Hydration Lifecycle

The SSR flow with TanStack Query follows a consistent pattern:

1. **Server**: A `QueryClient` is instantiated per request, queries are prefetched, and the cache is serialized ("dehydrated") into a plain JavaScript object.
2. **Transport**: The dehydrated state is embedded into the HTML response.
3. **Client**: A `QueryClient` is instantiated (once, for the session), the dehydrated state is rehydrated into it, and the cache is populated before the first render.

This avoids the "waterfall on mount" problem where components fetch data only after they render on the client, causing layout shifts and duplicate requests.

---

### Setting Up the QueryClient for SSR

#### Server-Side QueryClient Instantiation

A critical requirement is that the server-side `QueryClient` must be created **per request**, not as a module-level singleton. A shared singleton would cause data leakage between concurrent requests.

ts

```ts
// app/page.tsx (Next.js App Router example)
import { QueryClient, dehydrate, HydrationBoundary } from "@tanstack/react-query";
import { MyComponent } from "./MyComponent";

export default async function Page() {
  const queryClient = new QueryClient();

  await queryClient.prefetchQuery({
    queryKey: ["posts"],
    queryFn: fetchPosts,
  });

  return (
    <HydrationBoundary state={dehydrate(queryClient)}>
      <MyComponent />
    </HydrationBoundary>
  );
}
```

**Key Points**

- `new QueryClient()` is called inside the async component (per request).
- `prefetchQuery` populates the cache before dehydration.
- `dehydrate(queryClient)` serializes the cache state.
- `HydrationBoundary` rehydrates the state into the nearest client-side `QueryClient`.

---

### The HydrationBoundary Component

`HydrationBoundary` (introduced in v5, replacing the `Hydrate` component from v4) accepts a `state` prop containing a dehydrated cache snapshot. On the client, it merges this snapshot into the existing `QueryClient` cache.

tsx

```tsx
// Client component
"use client";

import { useQuery } from "@tanstack/react-query";

export function MyComponent() {
  const { data } = useQuery({
    queryKey: ["posts"],
    queryFn: fetchPosts,
  });

  return <div>{data?.map(post => <p key={post.id}>{post.title}</p>)}</div>;
}
```

Because the cache was populated by `HydrationBoundary`, `useQuery` will find the data immediately — no network request is made on mount under normal conditions. [Inference: this assumes the query key matches exactly and the data has not gone stale; actual behavior depends on `staleTime` configuration.]

---

### staleTime and SSR

By default, TanStack Query marks all data as stale immediately. On the client, a stale query is eligible for a background refetch — which means even hydrated data may trigger a network request on mount if `staleTime` is `0`.

To avoid unnecessary refetches of freshly server-rendered data:

ts

```ts
const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 60 * 1000, // 1 minute
    },
  },
});
```

**Key Points**

- Set `staleTime` to a non-zero value for queries that were just prefetched on the server.
- This can be configured globally or per-query.
- [Inference] A `staleTime` matching or exceeding the typical server-to-client render time reduces redundant refetches in most cases; actual behavior depends on render timing and network conditions.

---

### Prefetching Patterns

#### prefetchQuery vs ensureQueryData

Both methods populate the query cache, but they differ in return behavior:

| Method | Returns | Use Case |
| --- | --- | --- |
| `prefetchQuery` | `Promise<void>` | Fire-and-forget prefetch; errors are suppressed |
| `ensureQueryData` | `Promise<TData>` | Returns data; re-uses cached data if fresh |

ts

```ts
// prefetchQuery — errors do not throw
await queryClient.prefetchQuery({
  queryKey: ["user", userId],
  queryFn: () => fetchUser(userId),
});

// ensureQueryData — returns data, useful when you need it server-side
const user = await queryClient.ensureQueryData({
  queryKey: ["user", userId],
  queryFn: () => fetchUser(userId),
});
```

#### Prefetching Multiple Queries

ts

```ts
await Promise.all([
  queryClient.prefetchQuery({ queryKey: ["posts"], queryFn: fetchPosts }),
  queryClient.prefetchQuery({ queryKey: ["tags"], queryFn: fetchTags }),
]);
```

Parallelizing prefetches reduces total server-side data loading time.

---

### Nested HydrationBoundary Usage

`HydrationBoundary` components can be nested. Each boundary injects its own dehydrated state into the shared `QueryClient`. This is particularly useful in Next.js App Router layouts where different layout segments prefetch different data.

tsx

```tsx
// layout.tsx
export default async function Layout({ children }) {
  const queryClient = new QueryClient();
  await queryClient.prefetchQuery({ queryKey: ["user"], queryFn: fetchUser });

  return (
    <HydrationBoundary state={dehydrate(queryClient)}>
      {children}
    </HydrationBoundary>
  );
}

// page.tsx
export default async function Page() {
  const queryClient = new QueryClient();
  await queryClient.prefetchQuery({ queryKey: ["posts"], queryFn: fetchPosts });

  return (
    <HydrationBoundary state={dehydrate(queryClient)}>
      <PostList />
    </HydrationBoundary>
  );
}
```

**Key Points**

- Each segment creates its own server-side `QueryClient`.
- Both dehydrated states are merged into the client's single `QueryClient` instance.
- There is no conflict as long as query keys do not collide with incompatible data.

---

### Streaming SSR and Suspense Integration

TanStack Query v5 is designed to work with React's streaming SSR (`renderToPipeableStream` / Next.js App Router streaming). When combined with `<Suspense>`, queries that are not yet resolved on the server can stream in as they complete.

#### useSuspenseQuery in Streaming Contexts

tsx

```tsx
"use client";
import { useSuspenseQuery } from "@tanstack/react-query";

export function PostList() {
  const { data } = useSuspenseQuery({
    queryKey: ["posts"],
    queryFn: fetchPosts,
  });

  return <ul>{data.map(p => <li key={p.id}>{p.title}</li>)}</ul>;
}
```

tsx

```tsx
// page.tsx
import { Suspense } from "react";

export default function Page() {
  return (
    <Suspense fallback={<p>Loading posts...</p>}>
      <PostList />
    </Suspense>
  );
}
```

**Key Points**

- `useSuspenseQuery` throws a Promise when data is not available, triggering the nearest `<Suspense>` boundary.
- When used with streaming SSR, React can flush the Suspense fallback first and then stream the resolved content.
- [Inference] Combining `prefetchQuery` on the server with `useSuspenseQuery` on the client typically avoids the loading fallback when data is successfully prefetched; behavior depends on timing and whether the prefetched data is still considered fresh.

---

### The dehydrate Function

`dehydrate` serializes the `QueryClient` cache into a plain JSON-compatible object. By default, it only dehydrates **successful** queries.

ts

```ts
import { dehydrate } from "@tanstack/react-query";

const dehydratedState = dehydrate(queryClient);
// dehydratedState is a plain object safe to JSON.stringify
```

#### Dehydrating Errors (v5)

In v5, you can configure `dehydrate` to include failed queries:

ts

```ts
const dehydratedState = dehydrate(queryClient, {
  shouldDehydrateQuery: (query) =>
    query.state.status === "success" || query.state.status === "error",
});
```

This allows error states to be transported to the client so the component can render an error UI immediately without re-fetching.

---

### Hydration Flow Diagram

<svg viewBox="0 0 720 400" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="13">
<!-- Background -->
<rect width="720" height="400" fill="#0f1117" rx="12"/>
<!-- SERVER column -->
<rect x="30" y="30" width="200" height="30" fill="#1e2230" rx="6"/>
<text x="130" y="50" text-anchor="middle" fill="#7c8cf8" font-weight="bold" font-size="14">SERVER</text>
<!-- CLIENT column -->
<rect x="490" y="30" width="200" height="30" fill="#1e2230" rx="6"/>
<text x="590" y="50" text-anchor="middle" fill="#34d399" font-weight="bold" font-size="14">CLIENT</text>
<!-- Server boxes -->
<rect x="30" y="80" width="200" height="44" fill="#1e2230" rx="6" stroke="#7c8cf8" stroke-width="1"/>
<text x="130" y="97" text-anchor="middle" fill="#c9d1f5" font-size="12">new QueryClient()</text>
<text x="130" y="113" text-anchor="middle" fill="#8891c0" font-size="11">(per request)</text>
<rect x="30" y="154" width="200" height="44" fill="#1e2230" rx="6" stroke="#7c8cf8" stroke-width="1"/>
<text x="130" y="171" text-anchor="middle" fill="#c9d1f5" font-size="12">prefetchQuery()</text>
<text x="130" y="187" text-anchor="middle" fill="#8891c0" font-size="11">populate cache</text>
<rect x="30" y="228" width="200" height="44" fill="#1e2230" rx="6" stroke="#7c8cf8" stroke-width="1"/>
<text x="130" y="245" text-anchor="middle" fill="#c9d1f5" font-size="12">dehydrate(queryClient)</text>
<text x="130" y="261" text-anchor="middle" fill="#8891c0" font-size="11">serialize cache</text>
<rect x="30" y="302" width="200" height="44" fill="#1e2230" rx="6" stroke="#7c8cf8" stroke-width="1"/>
<text x="130" y="319" text-anchor="middle" fill="#c9d1f5" font-size="12">Embed in HTML</text>
<text x="130" y="335" text-anchor="middle" fill="#8891c0" font-size="11">__NEXT_DATA__ / RSC</text>
<!-- Arrows server column -->
<line x1="130" y1="124" x2="130" y2="154" stroke="#4b5270" stroke-width="1.5" marker-end="url(#arr)"/>
<line x1="130" y1="198" x2="130" y2="228" stroke="#4b5270" stroke-width="1.5" marker-end="url(#arr)"/>
<line x1="130" y1="272" x2="130" y2="302" stroke="#4b5270" stroke-width="1.5" marker-end="url(#arr)"/>
<!-- Transfer arrow -->
<line x1="230" y1="324" x2="490" y2="324" stroke="#f59e0b" stroke-width="1.5" stroke-dasharray="6,3" marker-end="url(#arrY)"/>
<text x="360" y="315" text-anchor="middle" fill="#f59e0b" font-size="11">HTTP Response</text>
<!-- Client boxes -->
<rect x="490" y="80" width="200" height="44" fill="#0f2318" rx="6" stroke="#34d399" stroke-width="1"/>
<text x="590" y="97" text-anchor="middle" fill="#c9d1f5" font-size="12">QueryClientProvider</text>
<text x="590" y="113" text-anchor="middle" fill="#8891c0" font-size="11">singleton client</text>
<rect x="490" y="154" width="200" height="44" fill="#0f2318" rx="6" stroke="#34d399" stroke-width="1"/>
<text x="590" y="171" text-anchor="middle" fill="#c9d1f5" font-size="12">HydrationBoundary</text>
<text x="590" y="187" text-anchor="middle" fill="#8891c0" font-size="11">state=dehydratedState</text>
<rect x="490" y="228" width="200" height="44" fill="#0f2318" rx="6" stroke="#34d399" stroke-width="1"/>
<text x="590" y="245" text-anchor="middle" fill="#c9d1f5" font-size="12">Cache populated</text>
<text x="590" y="261" text-anchor="middle" fill="#8891c0" font-size="11">no refetch on mount</text>
<rect x="490" y="302" width="200" height="44" fill="#0f2318" rx="6" stroke="#34d399" stroke-width="1"/>
<text x="590" y="319" text-anchor="middle" fill="#c9d1f5" font-size="12">useQuery / useSuspenseQuery</text>
<text x="590" y="335" text-anchor="middle" fill="#8891c0" font-size="11">reads from cache</text>
<!-- Arrows client column -->
<line x1="590" y1="124" x2="590" y2="154" stroke="#4b5270" stroke-width="1.5" marker-end="url(#arr)"/>
<line x1="590" y1="198" x2="590" y2="228" stroke="#4b5270" stroke-width="1.5" marker-end="url(#arr)"/>
<line x1="590" y1="272" x2="590" y2="302" stroke="#4b5270" stroke-width="1.5" marker-end="url(#arr)"/>
<!-- Arrow marker definitions -->
<defs>
<marker id="arr" markerWidth="8" markerHeight="8" refX="6" refY="3" orient="auto">
<path d="M0,0 L0,6 L8,3 z" fill="#4b5270"/>
</marker>
<marker id="arrY" markerWidth="8" markerHeight="8" refX="6" refY="3" orient="auto">
<path d="M0,0 L0,6 L8,3 z" fill="#f59e0b"/>
</marker>
</defs>
</svg>

---

### Error Handling in SSR Prefetches

`prefetchQuery` silently swallows errors by design — a failed prefetch does not crash the server render. The component on the client will then attempt to fetch the data itself.

If you need to handle errors explicitly:

ts

```ts
try {
  await queryClient.fetchQuery({
    queryKey: ["posts"],
    queryFn: fetchPosts,
  });
} catch (err) {
  // Log server-side, render fallback, or rethrow
  console.error("Prefetch failed:", err);
}
```

`fetchQuery` (unlike `prefetchQuery`) throws on failure, giving you explicit control.

---

### Framework-Specific Patterns

#### Next.js App Router

The App Router's React Server Components (RSC) model aligns naturally with TanStack Query's SSR approach. Server components act as the prefetch layer; client components use `useQuery` or `useSuspenseQuery` to read from the hydrated cache.

```
app/
├── layout.tsx         ← prefetch shared data (user, nav)
├── page.tsx           ← prefetch page-specific data
└── components/
    └── PostList.tsx   ← "use client", uses useQuery
```

#### Next.js Pages Router

In the Pages Router, prefetching happens inside `getServerSideProps` or `getStaticProps`:

ts

```ts
export async function getServerSideProps() {
  const queryClient = new QueryClient();

  await queryClient.prefetchQuery({
    queryKey: ["posts"],
    queryFn: fetchPosts,
  });

  return {
    props: {
      dehydratedState: dehydrate(queryClient),
    },
  };
}
```

The `_app.tsx` must wrap the tree in both `QueryClientProvider` and `HydrationBoundary`:

tsx

```tsx
// _app.tsx
import { QueryClient, QueryClientProvider, HydrationBoundary } from "@tanstack/react-query";
import { useState } from "react";

export default function App({ Component, pageProps }) {
  const [queryClient] = useState(() => new QueryClient());

  return (
    <QueryClientProvider client={queryClient}>
      <HydrationBoundary state={pageProps.dehydratedState}>
        <Component {...pageProps} />
      </HydrationBoundary>
    </QueryClientProvider>
  );
}
```

**Key Points**

- `useState` with a factory initializer ensures the client-side `QueryClient` is a stable singleton across re-renders without being a module-level variable.
- `pageProps.dehydratedState` is the serialized cache from the server.

---

### Avoiding Common Pitfalls

#### Pitfall 1: Module-Level QueryClient on the Server

ts

```ts
// ❌ Shared across all requests — data leakage risk
const queryClient = new QueryClient();

export async function getServerSideProps() {
  await queryClient.prefetchQuery(...);
}
```

ts

```ts
// ✅ Per-request instantiation
export async function getServerSideProps() {
  const queryClient = new QueryClient();
  await queryClient.prefetchQuery(...);
}
```

#### Pitfall 2: Mismatched Query Keys

The query key used in `prefetchQuery` on the server must exactly match the key used in `useQuery` on the client. A mismatch means the client will not find the cached data and will refetch.

ts

```ts
// Server
await queryClient.prefetchQuery({ queryKey: ["posts", { page: 1 }], queryFn: ... });

// Client — must be identical
useQuery({ queryKey: ["posts", { page: 1 }], queryFn: ... });
```

TanStack Query performs deep equality checks on query keys, so object shape and property order should be consistent. [Inference: key matching follows TanStack Query's internal hashing logic; behavior may vary if keys contain non-serializable values.]

#### Pitfall 3: staleTime: 0 with Prefetched Data

With the default `staleTime` of `0`, hydrated data is immediately considered stale. On mount, `useQuery` may trigger a background refetch even when data was just prefetched. Set an appropriate `staleTime` on the server-side `QueryClient` or per-query to match expected data freshness.

#### Pitfall 4: Non-Serializable Data in Cache

`dehydrate` serializes the cache to JSON. Any non-serializable values (class instances, functions, circular references) in query data will cause serialization to fail or produce incorrect output. Query data must be plain JSON-compatible objects.

---

### Infinite Queries and SSR

Infinite queries (`useInfiniteQuery`) can also be dehydrated and hydrated. The dehydrated state includes all fetched pages.

ts

```ts
await queryClient.prefetchInfiniteQuery({
  queryKey: ["posts", "infinite"],
  queryFn: ({ pageParam }) => fetchPosts({ page: pageParam }),
  initialPageParam: 0,
});
```

**Key Points**

- `prefetchInfiniteQuery` requires `initialPageParam` in v5.
- Only the first page is typically prefetched on the server to keep payload size reasonable. [Inference]
- Subsequent pages are fetched client-side as the user scrolls or triggers `fetchNextPage`.

---

### Security Considerations

Dehydrated state is embedded in the HTML payload and visible to anyone who views the page source. Avoid including sensitive data (tokens, private user data, PII) in prefetched query results unless the page is behind authentication and the transport is secured. [Inference: this applies equally to any server-rendered data mechanism, not uniquely to TanStack Query.]

---

**Related Topics**

- `queryClient.setQueryData` for manual cache population without a fetch
- Server Actions integration with TanStack Query mutations
- Optimistic updates across SSR boundaries
- TanStack Query Devtools in SSR environments
- Edge runtime compatibility and constraints
- `ReactQueryStreamedHydration` for advanced streaming use cases
- Cache invalidation strategies post-hydration
- TanStack Router's `loader` integration with TanStack Query prefetching