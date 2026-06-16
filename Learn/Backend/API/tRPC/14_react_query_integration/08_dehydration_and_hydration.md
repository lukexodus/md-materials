### Dehydration and Hydration

Dehydration and hydration are the serialization mechanism that allows server-fetched query data to travel from the server's `QueryClient` into the client's `QueryClient` across an HTTP response. tRPC does not implement this mechanism itself — it is provided by TanStack Query — but tRPC's server-side helpers are designed to produce output that feeds directly into it. Understanding dehydration and hydration at the TanStack Query level is necessary for diagnosing issues and configuring behavior correctly.

---

#### Core Concepts

| Term | Definition |
| --- | --- |
| **Dehydration** | Serializing a `QueryClient`'s in-memory cache into a plain, JSON-serializable object |
| **Hydration** | Deserializing that object back into a `QueryClient`'s cache on the client |
| **Dehydrated state** | The plain object produced by `dehydrate()` — safe to embed in HTML or pass as a prop |
| **HydrationBoundary** | A React component that rehydrates a dehydrated state into the nearest `QueryClient` |

The dehydrated state is not a network response format — it is an internal TanStack Query data structure. Its shape [Inference] may change between TanStack Query major versions; do not rely on its internal structure directly.

---

#### Relationship to tRPC

tRPC's `createServerSideHelpers` maintains an internal `QueryClient`. When you call `helpers.<procedure>.prefetch()`, the result is written into that `QueryClient`'s cache using the same cache key that the corresponding client-side `useQuery` hook will look up. Dehydration then serializes that cache for transport.

prefetch writes datadehydrateembedded in HTMLor passed as propHydrationBoundaryuseQuery reads cachetRPC Server Caller(createServerSideHelpers)Server QueryClient(in-memory cache)Dehydrated State(plain JS object)Client receives pageClient QueryClient(in-memory cache)Component renderswithout loading state

---

#### dehydrate

`dehydrate` is exported from `@tanstack/react-query`. It accepts a `QueryClient` and returns a plain object representing its current cache state.

```ts
import { dehydrate, QueryClient } from '@tanstack/react-query';

const queryClient = new QueryClient();
// ... populate queryClient with prefetched data ...

const dehydratedState = dehydrate(queryClient);
```

The dehydrated state contains an array of query entries, each including:

- The query key
- The query data
- The data's `updatedAt` timestamp
- The query status

[Inference] Only queries in a `success` or `error` status are included in the dehydrated state by default. Queries still in a `loading` state are excluded. This behavior is configurable via `dehydrate` options.

##### Configuring What Gets Dehydrated

```ts
const dehydratedState = dehydrate(queryClient, {
  shouldDehydrateQuery: (query) => {
    // Default behavior: only include successful queries
    // Override to include errored queries too
    return query.state.status === 'success' || query.state.status === 'error';
  },
});
```

**Key Points:**

- By default, queries that threw an error on the server are not included in the dehydrated state — the client will fetch them fresh and handle the error client-side
- Including errored queries via `shouldDehydrateQuery` [Inference] allows the client to immediately display an error state without a round-trip, but requires the error to be serializable

---

#### HydrationBoundary

`HydrationBoundary` is a React component that takes a dehydrated state and merges it into the nearest `QueryClient` (provided by `QueryClientProvider`) during render.

tsx

```
import { HydrationBoundary, dehydrate } from '@tanstack/react-query';

// Server component (App Router)
export default async function Page() {
  const helpers = await getServerHelpers();
  await helpers.user.list.prefetch();

  return (
    <HydrationBoundary state={dehydrate(helpers.queryClient)}>
      <UserList />
    </HydrationBoundary>
  );
}
```

**Key Points:**

- `HydrationBoundary` can appear anywhere in the tree — it does not need to wrap the entire application
- Multiple `HydrationBoundary` components can exist in the same tree, each with different dehydrated states [Inference]
- A `HydrationBoundary` with no `state` prop (or `state={undefined}`) is a no-op

---

#### How Hydration Merges Data

When `HydrationBoundary` processes the dehydrated state, TanStack Query [Inference] merges each query entry into the client `QueryClient` using the following logic:

- If the query key does not exist in the client cache → the entry is added
- If the query key already exists and the dehydrated entry is **newer** → the dehydrated entry replaces the client entry
- If the query key already exists and the client entry is **newer** → the client entry is kept

This merge strategy means hydration is safe to apply even if the client has already fetched some data (e.g., from a previous navigation). [Inference] "Newer" is determined by the `dataUpdatedAt` timestamp. Actual merge behavior may vary by TanStack Query version.

---

#### Passing Dehydrated State (App Router vs Pages Router)

##### App Router

In the App Router, the server component directly passes the dehydrated state as a prop to `HydrationBoundary`:

tsx

```
// app/users/page.tsx (Server Component)
import { dehydrate, HydrationBoundary } from '@tanstack/react-query';
import { getServerHelpers } from '../../utils/trpc-server';
import { UserList } from './UserList';

export default async function UsersPage() {
  const helpers = await getServerHelpers();
  await helpers.user.list.prefetch();

  return (
    <HydrationBoundary state={dehydrate(helpers.queryClient)}>
      <UserList />
    </HydrationBoundary>
  );
}
```

##### Pages Router

In the Pages Router, the dehydrated state travels through `getServerSideProps` as a serialized prop:

```ts
// pages/users/index.tsx
export async function getServerSideProps() {
  const helpers = createServerSideHelpers({ /* ... */ });
  await helpers.user.list.prefetch();

  return {
    props: {
      trpcState: helpers.dehydrate(),
    },
  };
}
```

The `trpcState` prop is then consumed in `_app.tsx` via `HydrationBoundary`:

tsx

```
// pages/_app.tsx
function MyApp({ Component, pageProps }) {
  return (
    <trpc.Provider /* ... */>
      <QueryClientProvider client={queryClient}>
        <HydrationBoundary state={pageProps.trpcState}>
          <Component {...pageProps} />
        </HydrationBoundary>
      </QueryClientProvider>
    </trpc.Provider>
  );
}
```

**Key Points:**

- In the Pages Router, `helpers.dehydrate()` is a convenience wrapper around `dehydrate(helpers.queryClient)` — [Inference] they produce equivalent output
- The dehydrated state passes through Next.js's `getServerSideProps` serialization boundary, which uses `JSON.stringify` internally — this is why a transformer like `superjson` is needed to handle types that are not native JSON (e.g., `Date`, `Map`, `Set`, `BigInt`)

---

#### Transformers and Serialization

The dehydrated state must survive serialization across the server-client boundary. In Next.js, this boundary uses `JSON.stringify` / `JSON.parse`, which does not preserve:

- `Date` objects (serialized as strings, not restored as `Date`)
- `undefined` values (dropped)
- `Map`, `Set`, `BigInt`, and other non-JSON primitives

tRPC addresses this with a pluggable transformer, most commonly `superjson`:

```ts
import superjson from 'superjson';

// Transformer must be configured in three places:
// 1. tRPC router init
const t = initTRPC.create({ transformer: superjson });

// 2. createServerSideHelpers
createServerSideHelpers({ transformer: superjson, /* ... */ });

// 3. tRPC React client
trpc.createClient({ transformer: superjson, links: [ /* ... */ ] });
```

[Inference] If `superjson` is configured in only some of these locations, serialization may succeed in some cases and silently corrupt data in others — particularly for `Date` values, which become strings without `superjson` restoration. This is a common source of difficult-to-diagnose bugs.

##### What superjson Does

`superjson` extends JSON with a metadata layer that records the original type of each value alongside its serialized form:

```json
{
  "json": { "createdAt": "2024-01-15T10:30:00.000Z" },
  "meta": { "values": { "createdAt": ["Date"] } }
}
```

On deserialization, the metadata is used to restore the original type. Without `superjson`, `createdAt` would be a `string` on the client even if the server returned a `Date`.

---

#### Dehydration in the Context of RSC (React Server Components)

With React Server Components, there is an emerging alternative to the `dehydrate` / `HydrationBoundary` pattern. Some tRPC setups use direct RSC data fetching without a `QueryClient` at all on the server, instead passing data as props to client components. [Speculation] A fully RSC-native tRPC data fetching pattern may reduce or eliminate the need for explicit dehydration in future versions; consult the tRPC and TanStack Query release notes for current guidance on RSC integration.

---

#### staleTime and Immediate Refetching

A common issue after hydration is that TanStack Query immediately refetches hydrated data because the default `staleTime` is `0`, meaning data is considered stale as soon as it is received.

```ts
// Without staleTime: hydrated data is immediately stale
// TanStack Query may trigger a background refetch on mount

// Set a non-zero staleTime to treat hydrated data as fresh
const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 1000 * 60, // 1 minute
    },
  },
});
```

[Inference] The exact refetch behavior depends on `refetchOnMount` and `refetchOnWindowFocus` settings in addition to `staleTime`. A combination of `staleTime: Infinity` and manual invalidation gives the most explicit control, at the cost of requiring deliberate cache management.

---

#### Nested HydrationBoundary

Multiple `HydrationBoundary` instances can be nested, each responsible for hydrating data relevant to a portion of the page:

tsx

```
// Layout-level hydration (shared data)
export default async function Layout({ children }) {
  const helpers = await getServerHelpers();
  await helpers.user.currentUser.prefetch();

  return (
    <HydrationBoundary state={dehydrate(helpers.queryClient)}>
      {children}
    </HydrationBoundary>
  );
}

// Page-level hydration (page-specific data)
export default async function PostsPage() {
  const helpers = await getServerHelpers();
  await helpers.post.list.prefetch();

  return (
    <HydrationBoundary state={dehydrate(helpers.queryClient)}>
      <PostList />
    </HydrationBoundary>
  );
}
```

**Key Points:**

- Each `HydrationBoundary` hydrates into the same underlying `QueryClient` — there is only one `QueryClient` per React tree [Inference]
- Nesting `HydrationBoundary` components is purely organizational; it does not create separate cache scopes

---

#### Debugging Dehydrated State

To inspect what is being dehydrated:

```ts
const dehydratedState = dehydrate(helpers.queryClient);

// Log the queries included in the dehydrated state
console.log(
  dehydratedState.queries.map(q => ({
    key: q.queryKey,
    status: q.state.status,
    dataUpdatedAt: q.state.dataUpdatedAt,
  }))
);
```

[Inference] The `queries` array on the dehydrated state contains one entry per cached query that passed the `shouldDehydrateQuery` filter. If a query you expect to be hydrated is missing, check whether it was prefetched before `dehydrate` was called and whether its status was `success` at that point.

---

#### Common Mistakes

##### Calling dehydrate Before prefetch Completes

```ts
// ❌ dehydrate called before prefetch resolves
const helpers = await getServerHelpers();
helpers.user.list.prefetch(); // Missing await
const state = dehydrate(helpers.queryClient); // Cache is empty

// ✅ Correct
await helpers.user.list.prefetch();
const state = dehydrate(helpers.queryClient);
```

##### Mismatched Transformer

```ts
// ❌ superjson on server, no transformer on client
// Server: createServerSideHelpers({ transformer: superjson })
// Client: trpc.createClient({ /* no transformer */ })
// Result: Date objects arrive as strings; metadata is not processed

// ✅ superjson configured consistently in all three locations
```

##### Creating a New QueryClient per Render

tsx

```
// ❌ New QueryClient on every render — hydrated state is lost immediately
function MyApp({ pageProps }) {
  const queryClient = new QueryClient(); // Recreated every render

  return (
    <QueryClientProvider client={queryClient}>
      <HydrationBoundary state={pageProps.trpcState}>
        <Component {...pageProps} />
      </HydrationBoundary>
    </QueryClientProvider>
  );
}

// ✅ Stable QueryClient reference
function MyApp({ pageProps }) {
  const [queryClient] = useState(() => new QueryClient());

  return (
    <QueryClientProvider client={queryClient}>
      <HydrationBoundary state={pageProps.trpcState}>
        <Component {...pageProps} />
      </HydrationBoundary>
    </QueryClientProvider>
  );
}
```

---

#### API Reference Summary

| API | Package | Purpose |
| --- | --- | --- |
| `dehydrate(queryClient, options?)` | `@tanstack/react-query` | Serialize QueryClient cache to plain object |
| `hydrate(queryClient, state)` | `@tanstack/react-query` | Imperatively merge dehydrated state into QueryClient |
| `HydrationBoundary` | `@tanstack/react-query` | React component that hydrates state into nearest QueryClient |
| `helpers.dehydrate()` | `@trpc/react-query/server` | Convenience wrapper around `dehydrate(helpers.queryClient)` |
| `helpers.queryClient` | `@trpc/react-query/server` | Direct access to the internal QueryClient |

---

**Conclusion:**
Dehydration and hydration are TanStack Query mechanisms that tRPC plugs into via `createServerSideHelpers`. `dehydrate` serializes the server `QueryClient` cache into a portable plain object; `HydrationBoundary` merges that object into the client `QueryClient` before components render, eliminating loading states for prefetched data. Correct behavior depends on transformer consistency across server and client configuration, non-zero `staleTime` to avoid immediate refetching, and awaiting all prefetch calls before dehydrating. All cache merge and staleness behavior is governed by TanStack Query internals; consult its documentation for authoritative version-specific details.