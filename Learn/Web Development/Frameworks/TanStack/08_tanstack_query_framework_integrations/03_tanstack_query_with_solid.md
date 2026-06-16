## TanStack Query with Solid

TanStack Query has a dedicated SolidJS adapter — `@tanstack/solid-query` — that exposes the same core concepts as the React integration but is built around SolidJS primitives: signals, stores, and fine-grained reactivity. Understanding the differences between the React and Solid adapters is as important as knowing their similarities.

---

### Installation

```bash
npm install @tanstack/solid-query
```

For DevTools:

```bash
npm install @tanstack/solid-query-devtools
```

---

### Initial Setup

#### QueryClient and QueryClientProvider

Setup mirrors the React adapter structurally, but imports come from `@tanstack/solid-query`.

```tsx
import { QueryClient, QueryClientProvider } from '@tanstack/solid-query'
import { SolidQueryDevtools } from '@tanstack/solid-query-devtools'
import { render } from 'solid-js/web'

const queryClient = new QueryClient()

function App() {
  return (
    <QueryClientProvider client={queryClient}>
      <MyApp />
      <SolidQueryDevtools initialIsOpen={false} />
    </QueryClientProvider>
  )
}

render(() => <App />, document.getElementById('root')!)
```

**Key Points:**
- `QueryClient` is the same class used across all framework adapters — it is framework-agnostic.
- `QueryClientProvider` uses SolidJS context under the hood, not React context.
- The DevTools component is Solid-native and does not depend on React DevTools.

---

### Core Difference: Reactivity Model

This is the most important conceptual difference between the React and Solid adapters.

In React, hooks re-run the entire function body on state change. In Solid, reactivity is signal-based and granular — only the expressions that read a signal re-evaluate.

As a result, the Solid adapter returns **reactive accessors (functions)** rather than plain values for most properties.

**React adapter:**
```tsx
const { data, isPending, isError } = useQuery(...)
// `data` is a plain value — component re-renders on change
```

**Solid adapter:**
```tsx
const query = createQuery(...)
// `query.data`, `query.isPending`, `query.isError` are reactive properties
// accessed inside JSX or effects — no manual signal wrapping needed
```

In Solid, you access these properties directly in JSX or inside `createEffect`, and Solid's fine-grained reactivity handles re-evaluation automatically.

---

### createQuery — Fetching Data

The Solid equivalent of `useQuery` is `createQuery`.

```tsx
import { createQuery } from '@tanstack/solid-query'

function UserProfile(props: { userId: string }) {
  const query = createQuery(() => ({
    queryKey: ['user', props.userId],
    queryFn: () => fetch(`/api/users/${props.userId}`).then(res => res.json()),
  }))

  return (
    <div>
      {query.isPending && <p>Loading...</p>}
      {query.isError && <p>Error: {query.error?.message}</p>}
      {query.isSuccess && <p>{query.data.name}</p>}
    </div>
  )
}
```

**Key Points:**
- `createQuery` accepts a **function** that returns the options object — this is a critical difference from the React adapter.
- The options function is a reactive computation. When reactive values inside it (like `props.userId`) change, the query automatically re-runs with updated options.
- Properties on the returned `query` object (`query.data`, `query.isPending`, etc.) are reactive and safe to read in JSX or `createEffect`.

#### Why the Options Must Be a Function

In SolidJS, props and signals must be read inside a tracking scope to establish reactive dependencies. If you pass a plain object, `props.userId` is read once at call time and the query never reacts to prop changes.

```tsx
// CORRECT — reactive: query re-runs when props.userId changes
const query = createQuery(() => ({
  queryKey: ['user', props.userId],
  queryFn: () => fetchUser(props.userId),
}))

// INCORRECT — non-reactive: query key is captured once at creation
const query = createQuery({
  queryKey: ['user', props.userId],
  queryFn: () => fetchUser(props.userId),
})
```

This pattern is consistent across all Solid adapter primitives.

---

### createQuery Options

All standard TanStack Query options are supported. The same rules apply: pass them inside the reactive function.

```tsx
const query = createQuery(() => ({
  queryKey: ['todos', filters()],
  queryFn: () => fetchTodos(filters()),

  staleTime: 1000 * 60 * 5,
  gcTime: 1000 * 60 * 10,
  refetchOnWindowFocus: true,
  retry: 3,
  enabled: !!userId(),          // Signal-based enabled flag
  select: (data) => data.items,
  placeholderData: keepPreviousData,
}))
```

**Key Points:**
- `enabled` can reference signals directly inside the options function.
- `select` transforms data before it reaches the component, without altering the cache.
- `placeholderData: keepPreviousData` is the v5 pattern for retaining previous data during pagination transitions.

---

### Dependent Queries

Because the options function is reactive, dependent queries are expressed naturally using signals.

```tsx
import { createQuery } from '@tanstack/solid-query'
import { createSignal } from 'solid-js'

function UserProjects() {
  const userQuery = createQuery(() => ({
    queryKey: ['user'],
    queryFn: fetchCurrentUser,
  }))

  const projectsQuery = createQuery(() => ({
    queryKey: ['projects', userQuery.data?.id],
    queryFn: () => fetchProjects(userQuery.data!.id),
    enabled: !!userQuery.data?.id,
  }))

  return (
    <div>
      {projectsQuery.isPending && <p>Loading projects...</p>}
      {projectsQuery.data?.map(p => <div>{p.name}</div>)}
    </div>
  )
}
```

**Key Points:**
- `userQuery.data?.id` is read inside the reactive options function, so when it changes, `projectsQuery` automatically reconfigures.
- `enabled: !!userQuery.data?.id` gates the second query without any manual effect or watcher.

---

### createMutation — Writing Data

The Solid equivalent of `useMutation` is `createMutation`.

```tsx
import { createMutation, useQueryClient } from '@tanstack/solid-query'

function AddTodo() {
  const queryClient = useQueryClient()

  const mutation = createMutation(() => ({
    mutationFn: (newTodo: { title: string }) =>
      fetch('/api/todos', {
        method: 'POST',
        body: JSON.stringify(newTodo),
      }).then(res => res.json()),

    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['todos'] })
    },

    onError: (error) => {
      console.error('Mutation failed:', error)
    },
  }))

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

**Key Points:**
- Like `createQuery`, `createMutation` takes a function returning the options object.
- `mutation.mutate()` is called imperatively, same as in React.
- `mutation.isPending`, `mutation.isSuccess`, `mutation.isError`, and `mutation.data` are all reactive properties.

#### Mutation Lifecycle Callbacks

The same four callbacks are available and behave identically to the React adapter:

| Callback | Timing | Use Case |
|---|---|---|
| `onMutate` | Before mutationFn fires | Optimistic updates |
| `onSuccess` | After successful mutationFn | Invalidation, redirects |
| `onError` | After failed mutationFn | Rollback, error display |
| `onSettled` | After either outcome | Cleanup, final sync |

---

### Optimistic Updates

The pattern is identical to React, but signal reads inside `onMutate` must be handled carefully to avoid reading stale closures.

```tsx
const queryClient = useQueryClient()

const mutation = createMutation(() => ({
  mutationFn: updateTodo,

  onMutate: async (updatedTodo) => {
    await queryClient.cancelQueries({ queryKey: ['todos'] })

    const previousTodos = queryClient.getQueryData(['todos'])

    queryClient.setQueryData(['todos'], (old: Todo[]) =>
      old.map(todo =>
        todo.id === updatedTodo.id ? { ...todo, ...updatedTodo } : todo
      )
    )

    return { previousTodos }
  },

  onError: (_err, _variables, context) => {
    queryClient.setQueryData(['todos'], context?.previousTodos)
  },

  onSettled: () => {
    queryClient.invalidateQueries({ queryKey: ['todos'] })
  },
}))
```

**Key Points:**
- `onMutate`, `onError`, and `onSettled` are not reactive scopes — they are plain async callbacks. Signal reads inside them are not tracked. [Inference: this is consistent with how Solid handles event handlers and async code outside of `createEffect`.]
- The snapshot-and-rollback pattern works the same way as in React.

---

### createQueries — Parallel Queries

`createQueries` runs multiple queries in parallel and returns a reactive array of results.

```tsx
import { createQueries } from '@tanstack/solid-query'

function MultiUserView(props: { userIds: string[] }) {
  const queries = createQueries(() => ({
    queries: props.userIds.map(id => ({
      queryKey: ['user', id],
      queryFn: () => fetchUser(id),
    })),
  }))

  return (
    <For each={queries}>
      {(query) => (
        <div>
          {query.isPending ? 'Loading...' : query.data?.name}
        </div>
      )}
    </For>
  )
}
```

**Key Points:**
- The outer options are wrapped in a reactive function, same as `createQuery`.
- `queries` is a reactive array — Solid's `<For>` component should be used to iterate over it efficiently.
- Each element in the returned array behaves like a `createQuery` result.

---

### createInfiniteQuery — Infinite Scroll

```tsx
import { createInfiniteQuery } from '@tanstack/solid-query'

function InfiniteList() {
  const query = createInfiniteQuery(() => ({
    queryKey: ['items'],
    queryFn: ({ pageParam }) => fetchItems(pageParam),
    initialPageParam: 1,
    getNextPageParam: (lastPage) => lastPage.nextCursor ?? undefined,
  }))

  return (
    <div>
      <For each={query.data?.pages}>
        {(page) => (
          <For each={page.items}>
            {(item) => <div>{item.name}</div>}
          </For>
        )}
      </For>
      <button
        onClick={() => query.fetchNextPage()}
        disabled={!query.hasNextPage || query.isFetchingNextPage}
      >
        {query.isFetchingNextPage ? 'Loading more...' : 'Load More'}
      </button>
    </div>
  )
}
```

**Key Points:**
- `createInfiniteQuery` returns a reactive result object — the same properties (`hasNextPage`, `isFetchingNextPage`, `fetchNextPage`) are available as in the React adapter.
- `data.pages` is a reactive array and should be iterated with `<For>`, not `.map()` in JSX, for efficient DOM updates. [Inference: using `.map()` may work but bypasses Solid's keyed diffing — behavior may vary.]

---

### useQueryClient

`useQueryClient` is identical to the React adapter in name and behavior. It reads the `QueryClient` from Solid context.

```tsx
import { useQueryClient } from '@tanstack/solid-query'

function MyComponent() {
  const queryClient = useQueryClient()

  const handleRefresh = () => {
    queryClient.invalidateQueries({ queryKey: ['todos'] })
  }

  return <button onClick={handleRefresh}>Refresh</button>
}
```

**Key Points:**
- `useQueryClient` must be called inside a component or reactive root — it reads from Solid's context system.
- The returned `QueryClient` instance is not itself a signal. It is stable and safe to use in event handlers and effects without tracking concerns.

---

### Suspense Integration

SolidJS has built-in `Suspense` support, and TanStack Query integrates with it via `createQuery`'s standard behavior or the dedicated `deferStream` option.

```tsx
import { createQuery } from '@tanstack/solid-query'
import { Suspense } from 'solid-js'

function UserProfile(props: { userId: string }) {
  const query = createQuery(() => ({
    queryKey: ['user', props.userId],
    queryFn: () => fetchUser(props.userId),
    // Solid's <Suspense> boundary handles the pending state
    deferStream: true,
  }))

  return <div>{query.data?.name}</div>
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
- When used inside a `<Suspense>` boundary, `createQuery` can integrate with Solid's streaming SSR via `deferStream`. [Inference: exact behavior depends on the SSR setup and Solid version — verify for your environment.]
- Unlike React's `useSuspenseQuery`, there is no separate `createSuspenseQuery` primitive in the Solid adapter — the standard `createQuery` participates in Suspense boundaries. [Unverified: confirm with the current version of `@tanstack/solid-query` as the API surface may have changed.]

---

### Error Handling

#### Per-Query Error Handling

```tsx
const query = createQuery(() => ({
  queryKey: ['todos'],
  queryFn: fetchTodos,
}))

return (
  <div>
    {query.isError && <p>Error: {query.error?.message}</p>}
    {query.isSuccess && <For each={query.data}>{(todo) => <p>{todo.title}</p>}</For>}
  </div>
)
```

#### Global Error Handler

```tsx
import { QueryClient, QueryCache, MutationCache } from '@tanstack/solid-query'

const queryClient = new QueryClient({
  queryCache: new QueryCache({
    onError: (error, query) => {
      console.error(`Query failed:`, error)
    },
  }),
  mutationCache: new MutationCache({
    onError: (error) => {
      console.error(`Mutation failed:`, error)
    },
  }),
})
```

---

### TypeScript Integration

Type inference works the same way as the React adapter — types flow from `queryFn`.

```tsx
type User = {
  id: string
  name: string
}

// `query.data` inferred as `User | undefined`
const query = createQuery(() => ({
  queryKey: ['user', props.userId],
  queryFn: (): Promise<User> => fetchUser(props.userId),
}))

// Explicit error typing
const query = createQuery<User, AxiosError>(() => ({
  queryKey: ['user', props.userId],
  queryFn: () => fetchUser(props.userId),
}))
// query.error is typed as AxiosError | null
```

---

### React vs. Solid Adapter — Side-by-Side Comparison

| Concern | React Adapter | Solid Adapter |
|---|---|---|
| Hook / primitive name | `useQuery` | `createQuery` |
| Options argument | Plain object | Reactive function returning object |
| Reactivity model | Re-render based | Signal-based, fine-grained |
| Returned values | Plain values | Reactive properties |
| Mutation primitive | `useMutation` | `createMutation` |
| Parallel queries | `useQueries` | `createQueries` |
| Infinite queries | `useInfiniteQuery` | `createInfiniteQuery` |
| QueryClient access | `useQueryClient` | `useQueryClient` |
| List rendering | `.map()` in JSX | `<For>` component |
| Suspense primitive | `useSuspenseQuery` | `createQuery` + `<Suspense>` |
| Import source | `@tanstack/react-query` | `@tanstack/solid-query` |

---

### Prefetching

Prefetching uses `QueryClient` directly and is framework-agnostic. The API is identical to the React adapter.

```tsx
// In a route handler or event
await queryClient.prefetchQuery({
  queryKey: ['user', userId],
  queryFn: () => fetchUser(userId),
})
```

**Example — Prefetch on hover in Solid:**

```tsx
function UserLink(props: { userId: string }) {
  const queryClient = useQueryClient()

  return (
    
      href={`/users/${props.userId}`}
      onMouseEnter={() => {
        queryClient.prefetchQuery({
          queryKey: ['user', props.userId],
          queryFn: () => fetchUser(props.userId),
        })
      }}
    >
      View Profile
    </a>
  )
}
```

**Key Points:**
- Props must be read inside the event handler (not destructured at the top of the component) to get their current value at the time of the event. [Inference: destructuring Solid props breaks reactivity in computed contexts — the same concern applies here for correctness, though event handlers are not tracked scopes.]

---

### DevTools

```tsx
import { SolidQueryDevtools } from '@tanstack/solid-query-devtools'

function App() {
  return (
    <QueryClientProvider client={queryClient}>
      <MyApp />
      <SolidQueryDevtools initialIsOpen={false} />
    </QueryClientProvider>
  )
}
```

**Key Points:**
- `SolidQueryDevtools` is a Solid-native component — it does not depend on React.
- It provides the same cache inspection capabilities as the React DevTools panel.
- [Inference] It is typically excluded from production builds through standard bundler configuration — verify this for your specific setup.

---

**Related Topics:**
- SolidJS signals and reactivity model (prerequisite conceptual context)
- TanStack Query with Vue (`@tanstack/vue-query`)
- TanStack Query with Svelte (`@tanstack/svelte-query`)
- SSR with TanStack Query and SolidStart
- `createQuery` with SolidJS `createResource` — comparison and tradeoffs
- Persisting the query cache in SolidJS applications
- Testing `createQuery` in SolidJS with `@solidjs/testing-library`
- TanStack Router integration with SolidJS and prefetching