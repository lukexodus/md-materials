## TanStack Query with React

TanStack Query (formerly React Query) was originally built for React and remains most deeply integrated with it. This article covers the full scope of using TanStack Query in a React application — from setup to advanced patterns.

---

### Installation

```bash
npm install @tanstack/react-query
```

For DevTools (strongly recommended during development):

```bash
npm install @tanstack/react-query-devtools
```

---

### Initial Setup

#### QueryClient and QueryClientProvider

Every React app using TanStack Query needs a `QueryClient` instance and a `QueryClientProvider` wrapping the component tree.

```tsx
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { ReactQueryDevtools } from '@tanstack/react-query-devtools'

const queryClient = new QueryClient()

function App() {
  return (
    <QueryClientProvider client={queryClient}>
      <MyApp />
      <ReactQueryDevtools initialIsOpen={false} />
    </QueryClientProvider>
  )
}
```

**Key Points:**
- `QueryClient` holds the cache, configuration, and query/mutation state.
- `QueryClientProvider` makes the client available to all child components via React context.
- The DevTools panel is only included in non-production builds when configured properly. [Inference: tree-shaking and environment checks may vary by bundler setup.]

---

### useQuery — Fetching Data

`useQuery` is the primary hook for reading and caching remote data.

```tsx
import { useQuery } from '@tanstack/react-query'

function UserProfile({ userId }: { userId: string }) {
  const { data, isPending, isError, error } = useQuery({
    queryKey: ['user', userId],
    queryFn: () => fetch(`/api/users/${userId}`).then(res => res.json()),
  })

  if (isPending) return <p>Loading...</p>
  if (isError) return <p>Error: {error.message}</p>

  return <div>{data.name}</div>
}
```

**Key Points:**
- `queryKey` uniquely identifies the query in the cache. Arrays are the convention — the first element is typically a string namespace, followed by variables.
- `queryFn` must return a promise. It receives a `QueryFunctionContext` object.
- Status flags like `isPending`, `isSuccess`, and `isError` are derived from the `status` field.

#### Status vs. FetchStatus

TanStack Query v5 distinguishes two orthogonal state dimensions:

| Property | Values | Meaning |
|---|---|---|
| `status` | `pending`, `success`, `error` | State of the data |
| `fetchStatus` | `fetching`, `paused`, `idle` | State of the network request |

This means a query can be `status: 'success'` and `fetchStatus: 'fetching'` simultaneously — when cached data exists but a background refetch is occurring.

---

### Query Keys in Depth

Query keys are the foundation of the cache. Every unique key maps to a unique cache entry.

```tsx
// Static key — fetches once and caches indefinitely (until stale)
useQuery({ queryKey: ['todos'], queryFn: fetchTodos })

// Dynamic key — re-fetches when userId changes
useQuery({ queryKey: ['user', userId], queryFn: () => fetchUser(userId) })

// Nested object in key — useful for complex filter sets
useQuery({
  queryKey: ['todos', { status: 'open', priority: 'high' }],
  queryFn: () => fetchFilteredTodos({ status: 'open', priority: 'high' }),
})
```

**Key Points:**
- Keys are serialized for comparison. Object key order does not matter — `{ a: 1, b: 2 }` and `{ b: 2, a: 1 }` are treated as equal.
- When any element of the key array changes, a new fetch is triggered.
- All variables used inside `queryFn` should appear in `queryKey` to avoid stale closure bugs. [Inference: This is a design guideline, not enforced by the library at runtime.]

---

### useQuery Options — Common Configuration

```tsx
useQuery({
  queryKey: ['todos'],
  queryFn: fetchTodos,

  staleTime: 1000 * 60 * 5,      // Data stays fresh for 5 minutes
  gcTime: 1000 * 60 * 10,        // Cache held for 10 minutes after unmount
  refetchOnWindowFocus: true,    // Refetch when user returns to tab
  refetchOnMount: true,          // Refetch when component mounts
  refetchInterval: false,        // Polling disabled by default
  retry: 3,                      // Retry failed requests 3 times
  retryDelay: attemptIndex =>    // Exponential backoff
    Math.min(1000 * 2 ** attemptIndex, 30000),
  enabled: !!userId,             // Conditionally run query
  select: data => data.items,    // Transform/select from returned data
  placeholderData: keepPreviousData, // v5: keep old data while fetching new
})
```

#### The `enabled` Option

`enabled: false` prevents a query from running automatically. This is the standard pattern for dependent queries:

```tsx
const { data: user } = useQuery({
  queryKey: ['user', userId],
  queryFn: () => fetchUser(userId),
  enabled: !!userId,
})

const { data: projects } = useQuery({
  queryKey: ['projects', user?.id],
  queryFn: () => fetchProjects(user!.id),
  enabled: !!user?.id,
})
```

#### The `select` Option

`select` transforms data before it reaches the component, without modifying the cache:

```tsx
const { data: userNames } = useQuery({
  queryKey: ['users'],
  queryFn: fetchUsers,
  select: (data) => data.map(user => user.name),
})
```

**Key Points:**
- `select` runs after each successful fetch.
- If the function reference is stable (e.g., defined outside the component or wrapped in `useCallback`), TanStack Query may skip re-running it when the underlying data hasn't changed. [Inference: memoization behavior may vary; verify in the version you are using.]

---

### useMutation — Writing Data

`useMutation` handles create, update, and delete operations.

```tsx
import { useMutation, useQueryClient } from '@tanstack/react-query'

function AddTodo() {
  const queryClient = useQueryClient()

  const mutation = useMutation({
    mutationFn: (newTodo: { title: string }) =>
      fetch('/api/todos', {
        method: 'POST',
        body: JSON.stringify(newTodo),
      }).then(res => res.json()),

    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['todos'] })
    },

    onError: (error) => {
      console.error('Failed to add todo:', error)
    },
  })

  return (
    <button
      onClick={() => mutation.mutate({ title: 'New Task' })}
      disabled={mutation.isPending}
    >
      {mutation.isPending ? 'Adding...' : 'Add Todo'}
    </button>
  )
}
```

#### Mutation Lifecycle Callbacks

| Callback | Timing | Use Case |
|---|---|---|
| `onMutate` | Before mutationFn fires | Optimistic updates |
| `onSuccess` | After successful mutationFn | Cache invalidation, redirects |
| `onError` | After failed mutationFn | Rollback, error display |
| `onSettled` | After either outcome | Cleanup, final sync |

---

### Optimistic Updates

Optimistic updates modify the cache before the server responds, then reconcile after.

```tsx
const queryClient = useQueryClient()

const mutation = useMutation({
  mutationFn: updateTodo,

  onMutate: async (updatedTodo) => {
    // Cancel any in-flight refetches to avoid overwriting
    await queryClient.cancelQueries({ queryKey: ['todos'] })

    // Snapshot current cache value
    const previousTodos = queryClient.getQueryData(['todos'])

    // Optimistically update cache
    queryClient.setQueryData(['todos'], (old: Todo[]) =>
      old.map(todo =>
        todo.id === updatedTodo.id ? { ...todo, ...updatedTodo } : todo
      )
    )

    // Return context for rollback
    return { previousTodos }
  },

  onError: (_err, _variables, context) => {
    // Rollback to snapshot on error
    queryClient.setQueryData(['todos'], context?.previousTodos)
  },

  onSettled: () => {
    queryClient.invalidateQueries({ queryKey: ['todos'] })
  },
})
```

**Key Points:**
- `onMutate` must return the snapshot context for `onError` to receive it.
- `cancelQueries` is important — without it, a background refetch could overwrite the optimistic value before the mutation completes. [Inference: race condition likelihood depends on `staleTime` and `refetchOnWindowFocus` settings.]

---

### Query Invalidation

Invalidation marks cached data as stale and triggers a refetch if the query is currently observed.

```tsx
const queryClient = useQueryClient()

// Invalidate a specific query
queryClient.invalidateQueries({ queryKey: ['todos'] })

// Invalidate all queries matching a prefix
queryClient.invalidateQueries({ queryKey: ['todos'] })

// Exact match only
queryClient.invalidateQueries({ queryKey: ['todos'], exact: true })

// Invalidate everything
queryClient.invalidateQueries()
```

**Key Points:**
- Invalidation only triggers a refetch when a component is actively subscribed to the query.
- Unsubscribed (inactive) queries are marked stale but not immediately refetched.

---

### Pagination

#### Basic Pagination with `keepPreviousData`

```tsx
import { keepPreviousData, useQuery } from '@tanstack/react-query'
import { useState } from 'react'

function PaginatedList() {
  const [page, setPage] = useState(1)

  const { data, isPending, isPlaceholderData } = useQuery({
    queryKey: ['items', page],
    queryFn: () => fetchItems(page),
    placeholderData: keepPreviousData,
  })

  return (
    <div>
      {isPending ? <p>Loading...</p> : data?.items.map(item => (
        <div key={item.id}>{item.name}</div>
      ))}
      <button
        onClick={() => setPage(p => p - 1)}
        disabled={page === 1}
      >
        Previous
      </button>
      <button
        onClick={() => setPage(p => p + 1)}
        disabled={isPlaceholderData || !data?.hasMore}
      >
        Next
      </button>
    </div>
  )
}
```

**Key Points:**
- `keepPreviousData` (imported as a sentinel value in v5) replaces the old `keepPreviousData: true` boolean option.
- `isPlaceholderData` is `true` when the displayed data comes from a previous query key — useful for disabling the "Next" button before new data arrives.

---

### Infinite Queries

`useInfiniteQuery` supports cursor- or page-based infinite scroll.

```tsx
import { useInfiniteQuery } from '@tanstack/react-query'

function InfiniteList() {
  const {
    data,
    fetchNextPage,
    hasNextPage,
    isFetchingNextPage,
  } = useInfiniteQuery({
    queryKey: ['items'],
    queryFn: ({ pageParam }) => fetchItems(pageParam),
    initialPageParam: 1,
    getNextPageParam: (lastPage) => lastPage.nextCursor ?? undefined,
  })

  return (
    <div>
      {data?.pages.map((page, i) => (
        <div key={i}>
          {page.items.map(item => (
            <div key={item.id}>{item.name}</div>
          ))}
        </div>
      ))}
      <button
        onClick={() => fetchNextPage()}
        disabled={!hasNextPage || isFetchingNextPage}
      >
        {isFetchingNextPage ? 'Loading more...' : 'Load More'}
      </button>
    </div>
  )
}
```

**Key Points:**
- `initialPageParam` (v5, replaces `defaultPageParam`) sets the first page parameter.
- `getNextPageParam` receives the last page's response and returns the next cursor. Returning `undefined` signals no more pages.
- `data.pages` is an array of all fetched page responses.

---

### Prefetching

Prefetching populates the cache before a component that needs the data mounts.

```tsx
// In a route loader, event handler, or parent component
await queryClient.prefetchQuery({
  queryKey: ['user', userId],
  queryFn: () => fetchUser(userId),
})
```

**Example — Prefetch on hover:**

```tsx
function UserLink({ userId }: { userId: string }) {
  const queryClient = useQueryClient()

  return (
    
      href={`/users/${userId}`}
      onMouseEnter={() => {
        queryClient.prefetchQuery({
          queryKey: ['user', userId],
          queryFn: () => fetchUser(userId),
          staleTime: 1000 * 60,
        })
      }}
    >
      View Profile
    </a>
  )
}
```

**Key Points:**
- If the data is already fresh in cache, `prefetchQuery` does nothing.
- Prefetched data is subject to the same `gcTime` as any other cache entry.

---

### useQueryClient

`useQueryClient` returns the nearest `QueryClient` from context. Use it to imperatively interact with the cache.

```tsx
const queryClient = useQueryClient()

// Read from cache
const cachedUser = queryClient.getQueryData(['user', userId])

// Write to cache directly
queryClient.setQueryData(['user', userId], updatedUser)

// Refetch without invalidating
queryClient.refetchQueries({ queryKey: ['todos'] })

// Remove from cache entirely
queryClient.removeQueries({ queryKey: ['user', userId] })
```

---

### Suspense Integration

TanStack Query has first-class support for React Suspense.

```tsx
import { useSuspenseQuery } from '@tanstack/react-query'
import { Suspense } from 'react'

function UserProfile({ userId }: { userId: string }) {
  // No isPending check needed — component suspends automatically
  const { data } = useSuspenseQuery({
    queryKey: ['user', userId],
    queryFn: () => fetchUser(userId),
  })

  return <div>{data.name}</div>
}

function App() {
  return (
    <Suspense fallback={<p>Loading...</p>}>
      <UserProfile userId="123" />
    </Suspense>
  )
}
```

**Key Points:**
- `useSuspenseQuery` always returns `data` as defined (never `undefined`) because the component is suspended until data is available.
- Error states must be handled by an `ErrorBoundary` higher in the tree.
- `useSuspenseQuery` does not support `enabled: false` — disabling a suspense query is not a defined pattern and [Inference] may produce unexpected behavior depending on the version.

---

### Error Handling Patterns

#### Per-Query Error Handling

```tsx
const { isError, error } = useQuery({ ... })

if (isError) return <ErrorMessage message={error.message} />
```

#### Global Error Handler via QueryClient

```tsx
const queryClient = new QueryClient({
  queryCache: new QueryCache({
    onError: (error, query) => {
      console.error(`Query ${query.queryKey} failed:`, error)
    },
  }),
  mutationCache: new MutationCache({
    onError: (error) => {
      console.error('Mutation failed:', error)
    },
  }),
})
```

**Key Points:**
- Global handlers fire in addition to, not instead of, per-query handlers.
- This is a useful pattern for centralized error logging or toast notifications. [Inference: exact execution order between global and local handlers may vary — verify with your version.]

---

### TypeScript Integration

TanStack Query v5 is fully typed. Type inference flows from `queryFn` automatically.

```tsx
type User = {
  id: string
  name: string
  email: string
}

// `data` is inferred as `User | undefined`
const { data } = useQuery({
  queryKey: ['user', userId],
  queryFn: (): Promise<User> => fetchUser(userId),
})

// With useSuspenseQuery, `data` is `User` (never undefined)
const { data } = useSuspenseQuery({
  queryKey: ['user', userId],
  queryFn: (): Promise<User> => fetchUser(userId),
})
```

For error typing, TanStack Query defaults `error` to `Error`. You can narrow it:

```tsx
const { error } = useQuery<User, AxiosError>({
  queryKey: ['user', userId],
  queryFn: () => fetchUser(userId),
})
// error is now typed as AxiosError | null
```

---

### DevTools

The React DevTools panel visualizes cache state in real time.

```tsx
import { ReactQueryDevtools } from '@tanstack/react-query-devtools'

function App() {
  return (
    <QueryClientProvider client={queryClient}>
      <MyApp />
      <ReactQueryDevtools initialIsOpen={false} position="bottom" />
    </QueryClientProvider>
  )
}
```

**Key Points:**
- The DevTools panel shows all active queries, their status, data, and staleness.
- It is excluded from production builds when using standard bundler configurations. [Inference: exclusion depends on bundler tree-shaking and `NODE_ENV` checks — verify for your setup.]
- A floating button in the corner toggles the panel open.

---

**Related Topics:**
- `useQueries` — parallel and dynamic query execution
- Query cancellation with `AbortSignal`
- SSR and hydration with TanStack Query (Next.js, Remix)
- `QueryObserver` and manual subscriptions outside React
- Testing strategies for TanStack Query hooks
- TanStack Query with Vue, Svelte, and Solid
- Persisting the query cache (localStorage, IndexedDB)
- Background sync and polling patterns
- Query deduplication internals