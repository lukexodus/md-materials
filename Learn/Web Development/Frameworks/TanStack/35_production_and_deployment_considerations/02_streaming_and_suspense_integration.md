## Streaming and Suspense Integration

---

### Overview

React's streaming SSR allows the server to flush HTML in chunks rather than waiting for the entire page to render. TanStack Query integrates with this model through `useSuspenseQuery` and related hooks, enabling components to participate in React's Suspense-based data-fetching lifecycle. When combined with streaming, this allows above-the-fold content to reach the browser immediately while slower data continues to resolve server-side and stream in progressively.

---

### React Suspense Primer (as it applies to TanStack Query)

Suspense works by catching thrown Promises. When a component throws a Promise, React renders the nearest `<Suspense>` boundary's `fallback` instead. When the Promise resolves, React retries rendering the component.

TanStack Query's `useSuspenseQuery` hooks are built around this contract. Rather than returning `{ data: undefined, isLoading: true }`, they throw a Promise when data is not yet available, deferring rendering to the Suspense boundary.

**Key Points**

- `useQuery` — never suspends; returns loading/error state as flags.
- `useSuspenseQuery` — suspends while loading; throws on error (caught by error boundaries).
- [Inference] Whether a given component suspends depends on whether its data is already in the cache at render time; behavior may vary based on `staleTime`, cache state, and timing.

---

### useSuspenseQuery

#### Basic Usage

tsx

```tsx
"use client";
import { useSuspenseQuery } from "@tanstack/react-query";

export function PostList() {
  // data is always defined here — no undefined check needed
  const { data } = useSuspenseQuery({
    queryKey: ["posts"],
    queryFn: fetchPosts,
  });

  return (
    <ul>
      {data.map((post) => (
        <li key={post.id}>{post.title}</li>
      ))}
    </ul>
  );
}
```

tsx

```tsx
// Parent
import { Suspense } from "react";

export default function Page() {
  return (
    <Suspense fallback={<p>Loading posts…</p>}>
      <PostList />
    </Suspense>
  );
}
```

**Key Points**

- `data` is typed as `TData`, not `TData | undefined`. TypeScript benefits from this narrowing automatically.
- The component will not render past the `useSuspenseQuery` call until data is available.
- Errors during fetch are thrown and must be caught by a React error boundary.

---

### useSuspenseQuery vs useQuery — Behavioral Comparison

| Behavior | `useQuery` | `useSuspenseQuery` |
| --- | --- | --- |
| Returns while loading | Yes (`isLoading: true`) | No (suspends) |
| `data` type | `TData | undefined` | `TData` |
| Error handling | `isError`, `error` flags | Throws to error boundary |
| Works without Suspense wrapper | Yes | No — will throw unhandled |
| Compatible with streaming SSR | Partial | Yes |
| `enabled: false` support | Yes | Limited — [Inference] behavior may differ from `useQuery` |

---

### useSuspenseInfiniteQuery

For paginated or infinite scroll patterns, the Suspense-compatible variant is `useSuspenseInfiniteQuery`:

tsx

```tsx
"use client";
import { useSuspenseInfiniteQuery } from "@tanstack/react-query";

export function InfinitePostList() {
  const { data, fetchNextPage, hasNextPage } = useSuspenseInfiniteQuery({
    queryKey: ["posts", "infinite"],
    queryFn: ({ pageParam }) => fetchPosts({ page: pageParam }),
    initialPageParam: 0,
    getNextPageParam: (lastPage) => lastPage.nextCursor ?? undefined,
  });

  return (
    <>
      {data.pages.flatMap((page) =>
        page.items.map((post) => <p key={post.id}>{post.title}</p>)
      )}
      {hasNextPage && (
        <button onClick={() => fetchNextPage()}>Load more</button>
      )}
    </>
  );
}
```

**Key Points**

- Initial page suspends; subsequent pages fetched via `fetchNextPage` do not trigger a new Suspense boundary.
- `data.pages` is always defined when the component renders.

---

### useSuspenseQueries

For fetching multiple independent queries in parallel within a single component while still suspending:

tsx

```tsx
"use client";
import { useSuspenseQueries } from "@tanstack/react-query";

export function Dashboard() {
  const [postsResult, userResult] = useSuspenseQueries({
    queries: [
      { queryKey: ["posts"], queryFn: fetchPosts },
      { queryKey: ["user"], queryFn: fetchUser },
    ],
  });

  // Both postsResult.data and userResult.data are defined here
  return (
    <div>
      <h2>{userResult.data.name}</h2>
      <PostList posts={postsResult.data} />
    </div>
  );
}
```

**Key Points**

- All queries in `useSuspenseQueries` must resolve before the component renders.
- This is equivalent to wrapping multiple `useSuspenseQuery` calls but avoids sequential suspension (waterfall).
- [Inference] The queries run in parallel; the component suspends until all are resolved.

---

### Streaming SSR Architecture

In Next.js App Router, React streams HTML from the server in chunks. Suspense boundaries act as flush points — the server can send resolved content as it becomes available without blocking on slower queries.

```
Server render begins
│
├── Layout (no Suspense) → flushed immediately
│
├── <Suspense fallback="Loading user…">
│     └── <UserProfile />  ← useSuspenseQuery(["user"])
│           → resolves quickly → streamed in first
│
└── <Suspense fallback="Loading feed…">
      └── <Feed />  ← useSuspenseQuery(["feed"])
            → resolves slowly → streamed in later
```

The browser receives the layout shell and the user profile while still waiting for the feed. The feed's fallback is replaced in-place by the browser as the stream delivers it.

---

### Streaming Flow Diagram

<svg viewBox="0 0 740 460" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="12">
<rect width="740" height="460" fill="#0f1117" rx="12"/>
<!-- Title -->

<text x="370" y="30" text-anchor="middle" fill="`#7c8cf8`" font-size="14" font-weight="bold">Streaming SSR with Suspense Boundaries</text>

<!-- Timeline axis -->
<line x1="60" y1="60" x2="680" y2="60" stroke="#2a2d3e" stroke-width="1"/>
<text x="60" y="55" fill="#4b5270" font-size="10">t=0ms</text>
<text x="240" y="55" fill="#4b5270" font-size="10">t=200ms</text>
<text x="420" y="55" fill="#4b5270" font-size="10">t=600ms</text>
<text x="590" y="55" fill="#4b5270" font-size="10">t=1200ms</text>
<!-- Row labels -->

<text x="30" y="100" fill="`#8891c0`" font-size="11" text-anchor="middle" transform="rotate(-30,30,100)">Shell</text>
<text x="30" y="180" fill="`#8891c0`" font-size="11" text-anchor="middle">User</text>
<text x="30" y="260" fill="`#8891c0`" font-size="11" text-anchor="middle">Feed</text>
<text x="30" y="340" fill="`#8891c0`" font-size="11" text-anchor="middle">Browser</text>

<!-- Row separator lines -->
<line x1="55" y1="130" x2="690" y2="130" stroke="#1e2230" stroke-width="1"/>
<line x1="55" y1="210" x2="690" y2="210" stroke="#1e2230" stroke-width="1"/>
<line x1="55" y1="290" x2="690" y2="290" stroke="#1e2230" stroke-width="1"/>
<line x1="55" y1="390" x2="690" y2="390" stroke="#1e2230" stroke-width="1"/>
<!-- Shell: immediate flush -->
<rect x="60" y="78" width="120" height="34" fill="#1e2a4a" rx="5" stroke="#7c8cf8" stroke-width="1"/>
<text x="120" y="99" text-anchor="middle" fill="#c9d1f5" font-size="11">Layout shell</text>
<line x1="180" y1="95" x2="200" y2="95" stroke="#7c8cf8" stroke-width="1.5" stroke-dasharray="4,2" marker-end="url(#aB)"/>
<text x="210" y="91" fill="#7c8cf8" font-size="10">flushed immediately</text>
<!-- User: fast query -->
<rect x="60" y="145" width="160" height="34" fill="#1a2e20" rx="5" stroke="#34d399" stroke-width="1" stroke-dasharray="4,2"/>
<text x="140" y="163" text-anchor="middle" fill="#8891c0" font-size="11">fetching ["user"]…</text>
<rect x="240" y="145" width="100" height="34" fill="#1a2e20" rx="5" stroke="#34d399" stroke-width="1"/>
<text x="290" y="163" text-anchor="middle" fill="#c9d1f5" font-size="11">resolved ✓</text>
<line x1="340" y1="162" x2="365" y2="162" stroke="#34d399" stroke-width="1.5" marker-end="url(#aG)"/>
<text x="370" y="158" fill="#34d399" font-size="10">streamed</text>
<!-- Feed: slow query -->
<rect x="60" y="225" width="360" height="34" fill="#2a1a10" rx="5" stroke="#f59e0b" stroke-width="1" stroke-dasharray="4,2"/>
<text x="240" y="243" text-anchor="middle" fill="#8891c0" font-size="11">fetching ["feed"]… (slow)</text>
<rect x="420" y="225" width="120" height="34" fill="#2a1a10" rx="5" stroke="#f59e0b" stroke-width="1"/>
<text x="480" y="243" text-anchor="middle" fill="#c9d1f5" font-size="11">resolved ✓</text>
<line x1="540" y1="242" x2="565" y2="242" stroke="#f59e0b" stroke-width="1.5" marker-end="url(#aY)"/>
<text x="570" y="238" fill="#f59e0b" font-size="10">streamed</text>
<!-- Browser receives -->
<rect x="60" y="305" width="120" height="30" fill="#1e2230" rx="4" stroke="#7c8cf8" stroke-width="1"/>
<text x="120" y="324" text-anchor="middle" fill="#c9d1f5" font-size="10">shell + fallbacks</text>
<rect x="240" y="305" width="120" height="30" fill="#1e2230" rx="4" stroke="#34d399" stroke-width="1"/>
<text x="300" y="324" text-anchor="middle" fill="#c9d1f5" font-size="10">user profile</text>
<rect x="420" y="305" width="160" height="30" fill="#1e2230" rx="4" stroke="#f59e0b" stroke-width="1"/>
<text x="500" y="324" text-anchor="middle" fill="#c9d1f5" font-size="10">feed replaces fallback</text>
<!-- Browser bar label -->

<text x="370" y="375" text-anchor="middle" fill="`#4b5270`" font-size="11">Progressive content arrival in browser</text>
<line x1="60" y1="360" x2="620" y2="360" stroke="`#4b5270`" stroke-width="1" stroke-dasharray="3,4"/>

<!-- Arrow markers -->
<defs>
<marker id="aB" markerWidth="7" markerHeight="7" refX="5" refY="3" orient="auto">
<path d="M0,0 L0,6 L7,3 z" fill="#7c8cf8"/>
</marker>
<marker id="aG" markerWidth="7" markerHeight="7" refX="5" refY="3" orient="auto">
<path d="M0,0 L0,6 L7,3 z" fill="#34d399"/>
</marker>
<marker id="aY" markerWidth="7" markerHeight="7" refX="5" refY="3" orient="auto">
<path d="M0,0 L0,6 L7,3 z" fill="#f59e0b"/>
</marker>
</defs>
</svg>

---

### Combining Prefetching with Suspense

Prefetching on the server eliminates the Suspense fallback entirely for hydrated data. The component receives data from the cache on first render and never suspends on the client.

tsx

```tsx
// page.tsx (Server Component)
import { QueryClient, dehydrate, HydrationBoundary } from "@tanstack/react-query";
import { Suspense } from "react";
import { PostList } from "./PostList";

export default async function Page() {
  const queryClient = new QueryClient();

  // Data is ready before the component renders
  await queryClient.prefetchQuery({
    queryKey: ["posts"],
    queryFn: fetchPosts,
  });

  return (
    <HydrationBoundary state={dehydrate(queryClient)}>
      {/* Suspense boundary still present as a safety net */}
      <Suspense fallback={<p>Loading…</p>}>
        <PostList />
      </Suspense>
    </HydrationBoundary>
  );
}
```

**Key Points**

- When `prefetchQuery` completes before dehydration, the client cache is populated before `PostList` renders.
- [Inference] `useSuspenseQuery` in `PostList` will find data in cache and will not trigger the Suspense fallback under normal conditions; actual behavior depends on whether the cache entry is still considered fresh at render time.
- Keeping the `<Suspense>` boundary is still recommended as a fallback for cache misses or stale-triggered refetches.

---

### Selective Streaming with Multiple Boundaries

Suspense boundaries can be placed at different levels to stream independent sections concurrently rather than blocking the whole page on the slowest query.

tsx

```tsx
export default function DashboardPage() {
  return (
    <main>
      {/* Renders immediately — no data dependency */}
      <Header />

      {/* Streams as soon as user data resolves */}
      <Suspense fallback={<UserSkeleton />}>
        <UserProfile />
      </Suspense>

      {/* Streams independently — does not block UserProfile */}
      <Suspense fallback={<FeedSkeleton />}>
        <Feed />
      </Suspense>

      {/* Streams independently */}
      <Suspense fallback={<StatsSkeleton />}>
        <StatsPanel />
      </Suspense>
    </main>
  );
}
```

**Key Points**

- Each `<Suspense>` boundary is independent. A slow `<StatsPanel>` does not delay `<UserProfile>`.
- Skeleton components as fallbacks maintain layout stability during streaming.
- Nesting Suspense boundaries is valid; the nearest boundary catches the suspend.

---

### Error Boundaries with Suspense

`useSuspenseQuery` throws errors rather than returning them as state. An error boundary must be present to catch them.

tsx

```tsx
"use client";
import { Component } from "react";

class QueryErrorBoundary extends Component {
  state = { hasError: false, error: null };

  static getDerivedStateFromError(error) {
    return { hasError: true, error };
  }

  render() {
    if (this.state.hasError) {
      return <p>Failed to load: {this.state.error?.message}</p>;
    }
    return this.props.children;
  }
}
```

tsx

```tsx
export default function Page() {
  return (
    <QueryErrorBoundary>
      <Suspense fallback={<p>Loading…</p>}>
        <PostList />
      </Suspense>
    </QueryErrorBoundary>
  );
}
```

Alternatively, use the `react-error-boundary` package for a declarative API:

tsx

```tsx
import { ErrorBoundary } from "react-error-boundary";

export default function Page() {
  return (
    <ErrorBoundary fallback={<p>Something went wrong.</p>}>
      <Suspense fallback={<p>Loading…</p>}>
        <PostList />
      </Suspense>
    </QueryErrorBoundary>
  );
}
```

**Key Points**

- Error boundaries must be class components or use a library like `react-error-boundary`.
- Placing the error boundary outside the Suspense boundary catches both fetch errors and render errors.
- [Inference] Without an error boundary, an unhandled thrown error from `useSuspenseQuery` will propagate to the React root and crash the component tree; behavior depends on the React version and renderer.

---

### Retry Behavior with Suspense

By default, TanStack Query retries failed queries up to 3 times with exponential backoff. In a Suspense context, this means the component remains suspended during retries — the fallback stays visible until all retries are exhausted or the query succeeds.

ts

```ts
useSuspenseQuery({
  queryKey: ["posts"],
  queryFn: fetchPosts,
  retry: 1, // Reduce retries for faster error surfacing in SSR/streaming contexts
  retryDelay: 500,
});
```

**Key Points**

- Excessive retries in a streaming SSR context may delay content delivery.
- [Inference] Configuring a lower `retry` count for server-critical queries may improve perceived performance; actual impact depends on query failure rates and network conditions.

---

### ReactQueryStreamedHydration (Experimental)

TanStack Query provides an experimental `ReactQueryStreamedHydration` component from `@tanstack/react-query-next-experimental` that integrates more deeply with React's streaming model. Instead of dehydrating the entire cache upfront, it streams individual query results as they resolve alongside the component HTML.

tsx

```tsx
// app/providers.tsx
"use client";
import { ReactQueryStreamedHydration } from "@tanstack/react-query-next-experimental";
import { QueryClientProvider, QueryClient } from "@tanstack/react-query";
import { useState } from "react";

export function Providers({ children }) {
  const [queryClient] = useState(() => new QueryClient());

  return (
    <QueryClientProvider client={queryClient}>
      <ReactQueryStreamedHydration>
        {children}
      </ReactQueryStreamedHydration>
    </QueryClientProvider>
  );
}
```

tsx

```tsx
// app/layout.tsx
import { Providers } from "./providers";

export default function RootLayout({ children }) {
  return (
    <html>
      <body>
        <Providers>{children}</Providers>
      </body>
    </html>
  );
}
```

**Key Points**

- With `ReactQueryStreamedHydration`, individual query data is sent inline in the stream as each query resolves — no upfront `dehydrate` call needed per page.
- [Unverified] This API is marked experimental as of TanStack Query v5 and is subject to change. Disclaimer: experimental APIs may have undocumented behavior or breaking changes in future releases.
- The trade-off vs. explicit `prefetchQuery` + `dehydrate` is less predictability over exactly when data is serialized and sent.

---

### Transition-Based Rendering with useTransition

For client-side navigation between routes, React's `useTransition` can keep the current UI visible while new Suspense boundaries are resolving, avoiding intermediate fallback flashes.

tsx

```tsx
"use client";
import { useTransition } from "react";
import { useRouter } from "next/navigation";

export function NavLink({ href, children }) {
  const router = useRouter();
  const [isPending, startTransition] = useTransition();

  return (
    <button
      onClick={() => startTransition(() => router.push(href))}
      aria-busy={isPending}
    >
      {children}
      {isPending && " …"}
    </button>
  );
}
```

**Key Points**

- Without `useTransition`, navigating to a page with a Suspense boundary immediately shows the fallback.
- With `useTransition`, React defers the route change and keeps the current page visible until the new page's Suspense boundaries resolve (or a timeout is reached).
- [Inference] This interacts with TanStack Query's prefetching: if the new route's data is prefetched before navigation, the transition completes faster.

---

### Suspense and Background Refetches

A key distinction: `useSuspenseQuery` only suspends on the **initial** load. Background refetches (triggered by window focus, interval, or stale-on-mount) do not cause re-suspension. The component continues to display existing data while the refetch runs silently.

tsx

```tsx
const { data, isFetching } = useSuspenseQuery({
  queryKey: ["posts"],
  queryFn: fetchPosts,
  refetchOnWindowFocus: true,
});

// isFetching is true during background refetch — data is still defined
return (
  <div>
    {isFetching && <span>Refreshing…</span>}
    <PostList posts={data} />
  </div>
);
```

**Key Points**

- `isFetching` distinguishes a background refetch from the initial load.
- The component never re-suspends after the first successful fetch under normal conditions. [Inference: this assumes the query key remains the same; a key change will trigger a new suspension.]

---

### Common Patterns Summary

| Pattern | Tool | When to Use |
| --- | --- | --- |
| Single query, suspending | `useSuspenseQuery` | Most data-fetching components |
| Multiple parallel queries | `useSuspenseQueries` | Dashboard panels, multi-resource views |
| Paginated / infinite data | `useSuspenseInfiniteQuery` | Feed, list with load-more |
| Streaming without upfront dehydrate | `ReactQueryStreamedHydration` | App Router with deep query trees (experimental) |
| Prefetch + stream | `prefetchQuery` + `HydrationBoundary` | SSR pages with known data requirements |

---

**Related Topics**

- `useQuery` with `enabled` and manual Suspense control
- Error boundary reset patterns with `QueryErrorResetBoundary`
- `QueryErrorResetBoundary` for retry UX after errors
- Optimistic updates in Suspense-enabled components
- TanStack Router's `loader` with Suspense integration
- `defer` and partial hydration strategies in Remix
- React `use()` hook and its relationship to Suspense-based data fetching
- Performance profiling of streamed vs. dehydrated SSR payloads