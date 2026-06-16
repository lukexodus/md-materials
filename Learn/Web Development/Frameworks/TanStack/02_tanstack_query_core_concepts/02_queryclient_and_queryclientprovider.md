## QueryClient and QueryClientProvider

### Overview

`QueryClient` and `QueryClientProvider` are the foundational setup layer of TanStack Query. Every feature — caching, background refetching, invalidation, mutations — operates through a `QueryClient` instance. The `QueryClientProvider` makes that instance available to the entire React component tree via React context.

---

### QueryClient

`QueryClient` is the central coordinator of TanStack Query. It owns the query cache, manages default configurations, and exposes an imperative API for interacting with cached data.

**Creating an instance:**

```ts
import { QueryClient } from '@tanstack/react-query'

const queryClient = new QueryClient()
```

You can optionally pass a configuration object:

```ts
const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 1000 * 60 * 5,   // 5 minutes
      retry: 2,
    },
    mutations: {
      retry: 0,
    },
  },
})
```

**Key Points:**
- `defaultOptions.queries` sets fallback behavior for all `useQuery` calls unless overridden at the call site.
- `defaultOptions.mutations` sets fallback behavior for all `useMutation` calls.
- The `QueryClient` holds a `QueryCache` and a `MutationCache` internally. You can pass custom instances of these if needed (e.g., for attaching global error handlers).

**Attaching global cache-level handlers:**

```ts
import { QueryClient, QueryCache, MutationCache } from '@tanstack/react-query'

const queryClient = new QueryClient({
  queryCache: new QueryCache({
    onError: (error, query) => {
      console.error(`Query error [${String(query.queryKey)}]:`, error)
    },
  }),
  mutationCache: new MutationCache({
    onError: (error) => {
      console.error('Mutation error:', error)
    },
  }),
})
```

> [Inference] Global cache-level handlers may be more reliable for centralized logging than per-query `onError` callbacks, since the latter are subject to change in behavior across versions. Behavior may vary — verify against the version you are using.

---

### QueryClientProvider

`QueryClientProvider` is a React context provider. It accepts a `QueryClient` instance and makes it available to all descendant components.

```tsx
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'

const queryClient = new QueryClient()

function App() {
  return (
    <QueryClientProvider client={queryClient}>
      <YourApp />
    </QueryClientProvider>
  )
}
```

**Key Points:**
- The `client` prop is required.
- Any component inside `QueryClientProvider` can access the client via `useQueryClient()`.
- Components outside the provider cannot access the query cache through TanStack Query hooks.

---

### Instance Placement

Where you instantiate `QueryClient` matters.

**Correct — stable reference:**

```tsx
// Outside the component, or stabilized with useState/useRef
const queryClient = new QueryClient()

function App() {
  return (
    <QueryClientProvider client={queryClient}>
      <YourApp />
    </QueryClientProvider>
  )
}
```

**Also correct — stabilized inside a component:**

```tsx
function App() {
  const [queryClient] = useState(() => new QueryClient())

  return (
    <QueryClientProvider client={queryClient}>
      <YourApp />
    </QueryClientProvider>
  )
}
```

**Problematic — unstable reference:**

```tsx
function App() {
  // Re-creates a new QueryClient on every render
  const queryClient = new QueryClient()

  return (
    <QueryClientProvider client={queryClient}>
      <YourApp />
    </QueryClientProvider>
  )
}
```

> [Inference] Creating a `QueryClient` directly inside the component body without stabilization is likely to cause the cache to reset on every render, discarding all cached data. Actual behavior may vary depending on React's render behavior and your environment.

The `useState` initializer form (`() => new QueryClient()`) is the recommended pattern when the client must be created inside a component, such as in frameworks that server-render the component tree per request.

---

### useQueryClient

Any component inside the provider can retrieve the current `QueryClient` instance:

```tsx
import { useQueryClient } from '@tanstack/react-query'

function SomeComponent() {
  const queryClient = useQueryClient()

  const handleRefresh = () => {
    queryClient.invalidateQueries({ queryKey: ['todos'] })
  }

  return <button onClick={handleRefresh}>Refresh Todos</button>
}
```

This is used for imperative operations: invalidation, prefetching, manually setting cache data, and canceling queries.

---

### Server-Side Rendering Considerations

When using SSR (e.g., with Next.js or Remix), a new `QueryClient` instance should be created per request — not shared across requests — to avoid leaking data between users.

```tsx
// Per-request instantiation (SSR context)
function App() {
  const [queryClient] = useState(
    () =>
      new QueryClient({
        defaultOptions: {
          queries: {
            staleTime: 60 * 1000,
          },
        },
      })
  )

  return (
    <QueryClientProvider client={queryClient}>
      <YourApp />
    </QueryClientProvider>
  )
}
```

> [Inference] Sharing a single `QueryClient` across server-rendered requests is likely to cause data leakage between users because the cache is shared state. This is a commonly documented risk but actual behavior depends on your framework and rendering strategy.

---

### ReactQueryDevtools (Optional but Recommended)

The devtools component, when added inside the provider, gives a visual interface for inspecting the cache during development.

```tsx
import { ReactQueryDevtools } from '@tanstack/react-query-devtools'

function App() {
  return (
    <QueryClientProvider client={queryClient}>
      <YourApp />
      <ReactQueryDevtools initialIsOpen={false} />
    </QueryClientProvider>
  )
}
```

**Key Points:**
- Devtools are typically stripped from production builds when using a bundler that respects `process.env.NODE_ENV`.
- They must be inside `QueryClientProvider` to function.

---

### Configuration Precedence

Options set at the `QueryClient` level serve as defaults. They are overridden by options set at the `useQuery` or `useMutation` call site.

```
QueryClient defaultOptions
    ↓ overridden by
useQuery / useMutation options
```

**Example:**

```ts
// QueryClient sets staleTime to 5 minutes globally
const queryClient = new QueryClient({
  defaultOptions: { queries: { staleTime: 1000 * 60 * 5 } },
})

// This specific query overrides staleTime to 0
useQuery({
  queryKey: ['live-data'],
  queryFn: fetchLiveData,
  staleTime: 0,
})
```

> Behavior at the call site takes precedence over defaults. This applies to all options supported by `defaultOptions`. Behavior may vary — consult the TanStack Query documentation for the version in use.

---

### Summary

| Concept | Role |
|---|---|
| `QueryClient` | Owns the cache; configures global defaults; exposes imperative API |
| `QueryClientProvider` | Injects the client into React context |
| `useQueryClient()` | Retrieves the client inside any descendant component |
| `defaultOptions` | Sets fallback query/mutation behavior; overridable per call |
| Per-request instantiation | Required for SSR to avoid cross-request data leakage |