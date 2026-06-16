## TanStack Query with Svelte

TanStack Query provides a dedicated Svelte adapter — `@tanstack/svelte-query` — that integrates with Svelte's reactive store system. The adapter supports both Svelte 4 and Svelte 5, though the programming model differs between them. This article covers setup, core primitives, reactivity patterns, and the distinctions between Svelte versions.

---

### Installation

```bash
npm install @tanstack/svelte-query
```

For DevTools:

```bash
npm install @tanstack/svelte-query-devtools
```

---

### Initial Setup

#### QueryClient and QueryClientProvider

In Svelte, the `QueryClient` is provided to the component tree using the `QueryClientProvider` component.

```svelte
<!-- App.svelte -->
<script>
  import { QueryClient, QueryClientProvider } from '@tanstack/svelte-query'
  import { SvelteQueryDevtools } from '@tanstack/svelte-query-devtools'
  import MyApp from './MyApp.svelte'

  const queryClient = new QueryClient()
</script>

<QueryClientProvider client={queryClient}>
  <MyApp />
  <SvelteQueryDevtools initialIsOpen={false} />
</QueryClientProvider>
```

**Key Points:**
- `QueryClient` is the same framework-agnostic class used across all adapters.
- `QueryClientProvider` uses Svelte's context API (`setContext` / `getContext`) under the hood.
- The DevTools component is Svelte-native and does not depend on React.

---

### Core Difference: Svelte 4 vs. Svelte 5

The Svelte adapter works differently depending on which version of Svelte you are using. This is the most important thing to establish before writing any query code.

| Concern | Svelte 4 | Svelte 5 |
|---|---|---|
| Reactivity primitive | Svelte stores (`Readable`) | Runes (`$state`, `$derived`) |
| Return type | A Svelte store — must use `$` prefix | A plain reactive object |
| Options reactivity | Reactive stores or `$:` blocks | Plain values or runes |
| Import source | `@tanstack/svelte-query` | `@tanstack/svelte-query` |

Both versions share the same import paths and primitive names. The difference is in how the return values are consumed.

---

### Svelte 4 — createQuery

In Svelte 4, `createQuery` returns a **Svelte readable store**. You access its value using the `$` auto-subscription prefix in templates and scripts.

```svelte
<!-- UserProfile.svelte (Svelte 4) -->
<script>
  import { createQuery } from '@tanstack/svelte-query'

  export let userId

  const query = createQuery({
    queryKey: ['user', userId],
    queryFn: () => fetch(`/api/users/${userId}`).then(r => r.json()),
  })
</script>

{#if $query.isPending}
  <p>Loading...</p>
{:else if $query.isError}
  <p>Error: {$query.error.message}</p>
{:else}
  <p>{$query.data.name}</p>
{/if}
```

**Key Points:**
- `query` is a store — you must use `$query` to read its current value in templates and reactive statements.
- Forgetting the `$` prefix returns the store object itself, not its current value. This is a common source of bugs.
- The options object is passed directly (not as a function), unlike the Solid adapter.

#### Reactive Options in Svelte 4

When query options depend on reactive values (props, stores, local state), use a reactive `$:` block to recreate the query when dependencies change.

```svelte
<script>
  import { createQuery } from '@tanstack/svelte-query'
  import { writable } from 'svelte/store'

  export let userId

  // Recreate query when userId changes
  $: query = createQuery({
    queryKey: ['user', userId],
    queryFn: () => fetch(`/api/users/${userId}`).then(r => r.json()),
  })
</script>

{#if $query.isPending}
  <p>Loading...</p>
{:else}
  <p>{$query.data?.name}</p>
{/if}
```

**Key Points:**
- The `$:` reactive block re-runs `createQuery` when `userId` changes, producing a new store.
- [Inference] Creating a new query instance rather than updating options may cause a brief `isPending` flash if the key has no cached data. Behavior may vary depending on cache state.

---

### Svelte 5 — createQuery with Runes

In Svelte 5, `createQuery` returns a **plain reactive object** powered by Svelte 5 runes. The `$` prefix is no longer needed.

```svelte
<!-- UserProfile.svelte (Svelte 5) -->
<script>
  import { createQuery } from '@tanstack/svelte-query'

  let { userId } = $props()

  const query = createQuery({
    queryKey: ['user', userId],
    queryFn: () => fetch(`/api/users/${userId}`).then(r => r.json()),
  })
</script>

{#if query.isPending}
  <p>Loading...</p>
{:else if query.isError}
  <p>Error: {query.error.message}</p>
{:else}
  <p>{query.data.name}</p>
{/if}
```

**Key Points:**
- No `$` prefix needed — `query.isPending`, `query.data`, etc. are accessed directly.
- `$props()` is the Svelte 5 rune for receiving component props.
- The returned object's properties update reactively without store subscription boilerplate.

#### Reactive Options in Svelte 5

In Svelte 5, pass a **function** returning the options to make the query reactive to changing values.

```svelte
<script>
  import { createQuery } from '@tanstack/svelte-query'

  let { userId } = $props()

  const query = createQuery(() => ({
    queryKey: ['user', userId],
    queryFn: () => fetch(`/api/users/${userId}`).then(r => r.json()),
  }))
</script>
```

**Key Points:**
- The function form is the Svelte 5 pattern for reactive options — consistent with the Solid adapter.
- When `userId` (a rune-tracked prop) changes, the query key updates and a new fetch is triggered automatically.
- In Svelte 5, passing a plain object instead of a function means the options are captured once at creation time — the query does not react to prop changes. [Inference: this is consistent with how Svelte 5 runes track reads, but verify with the current adapter version.]

---

### createMutation — Writing Data

#### Svelte 4

```svelte
<script>
  import { createMutation, useQueryClient } from '@tanstack/svelte-query'

  const queryClient = useQueryClient()

  const mutation = createMutation({
    mutationFn: (newTodo) =>
      fetch('/api/todos', {
        method: 'POST',
        body: JSON.stringify(newTodo),
      }).then(r => r.json()),

    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['todos'] })
    },
  })
</script>

<button
  on:click={() => $mutation.mutate({ title: 'New Task' })}
  disabled={$mutation.isPending}
>
  {$mutation.isPending ? 'Adding...' : 'Add Todo'}
</button>
```

#### Svelte 5

```svelte
<script>
  import { createMutation, useQueryClient } from '@tanstack/svelte-query'

  const queryClient = useQueryClient()

  const mutation = createMutation(() => ({
    mutationFn: (newTodo) =>
      fetch('/api/todos', {
        method: 'POST',
        body: JSON.stringify(newTodo),
      }).then(r => r.json()),

    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['todos'] })
    },
  }))
</script>

<button
  onclick={() => mutation.mutate({ title: 'New Task' })}
  disabled={mutation.isPending}
>
  {mutation.isPending ? 'Adding...' : 'Add Todo'}
</button>
```

**Key Points:**
- In Svelte 4: `$mutation.mutate()` and `$mutation.isPending` (store subscription).
- In Svelte 5: `mutation.mutate()` and `mutation.isPending` (plain reactive object).
- Event handler syntax differs: `on:click` in Svelte 4, `onclick` in Svelte 5.

---

### Mutation Lifecycle Callbacks

Both versions support the same four callbacks:

| Callback | Timing | Use Case |
|---|---|---|
| `onMutate` | Before mutationFn fires | Optimistic updates |
| `onSuccess` | After successful mutationFn | Cache invalidation |
| `onError` | After failed mutationFn | Rollback, error display |
| `onSettled` | After either outcome | Cleanup |

---

### Optimistic Updates

The snapshot-and-rollback pattern works the same across adapters.

```svelte
<script>
  import { createMutation, useQueryClient } from '@tanstack/svelte-query'

  const queryClient = useQueryClient()

  // Svelte 5 shown; for Svelte 4, remove function wrapper and use $mutation
  const mutation = createMutation(() => ({
    mutationFn: updateTodo,

    onMutate: async (updatedTodo) => {
      await queryClient.cancelQueries({ queryKey: ['todos'] })

      const previousTodos = queryClient.getQueryData(['todos'])

      queryClient.setQueryData(['todos'], (old) =>
        old.map(todo =>
          todo.id === updatedTodo.id ? { ...todo, ...updatedTodo } : todo
        )
      )

      return { previousTodos }
    },

    onError: (_err, _vars, context) => {
      queryClient.setQueryData(['todos'], context?.previousTodos)
    },

    onSettled: () => {
      queryClient.invalidateQueries({ queryKey: ['todos'] })
    },
  }))
</script>
```

---

### Dependent Queries

#### Svelte 4

```svelte
<script>
  import { createQuery } from '@tanstack/svelte-query'

  export let userId

  $: userQuery = createQuery({
    queryKey: ['user', userId],
    queryFn: () => fetchUser(userId),
  })

  $: projectsQuery = createQuery({
    queryKey: ['projects', $userQuery.data?.id],
    queryFn: () => fetchProjects($userQuery.data.id),
    enabled: !!$userQuery.data?.id,
  })
</script>

{#if $projectsQuery.isPending}
  <p>Loading projects...</p>
{:else}
  {#each $projectsQuery.data ?? [] as project}
    <p>{project.name}</p>
  {/each}
{/if}
```

#### Svelte 5

```svelte
<script>
  import { createQuery } from '@tanstack/svelte-query'

  let { userId } = $props()

  const userQuery = createQuery(() => ({
    queryKey: ['user', userId],
    queryFn: () => fetchUser(userId),
  }))

  const projectsQuery = createQuery(() => ({
    queryKey: ['projects', userQuery.data?.id],
    queryFn: () => fetchProjects(userQuery.data!.id),
    enabled: !!userQuery.data?.id,
  }))
</script>

{#if projectsQuery.isPending}
  <p>Loading projects...</p>
{:else}
  {#each projectsQuery.data ?? [] as project}
    <p>{project.name}</p>
  {/each}
{/if}
```

**Key Points:**
- In Svelte 5, `userQuery.data?.id` is read inside the reactive options function, establishing the dependency automatically.
- In Svelte 4, reading `$userQuery.data?.id` inside a `$:` block achieves the same effect through Svelte's reactive statement tracking.

---

### createQueries — Parallel Queries

#### Svelte 4

```svelte
<script>
  import { createQueries } from '@tanstack/svelte-query'

  export let userIds

  $: queries = createQueries({
    queries: userIds.map(id => ({
      queryKey: ['user', id],
      queryFn: () => fetchUser(id),
    })),
  })
</script>

{#each $queries as query}
  <p>{query.isPending ? 'Loading...' : query.data?.name}</p>
{/each}
```

#### Svelte 5

```svelte
<script>
  import { createQueries } from '@tanstack/svelte-query'

  let { userIds } = $props()

  const queries = createQueries(() => ({
    queries: userIds.map(id => ({
      queryKey: ['user', id],
      queryFn: () => fetchUser(id),
    })),
  }))
</script>

{#each queries as query}
  <p>{query.isPending ? 'Loading...' : query.data?.name}</p>
{/each}
```

---

### createInfiniteQuery — Infinite Scroll

#### Svelte 5

```svelte
<script>
  import { createInfiniteQuery } from '@tanstack/svelte-query'

  const query = createInfiniteQuery(() => ({
    queryKey: ['items'],
    queryFn: ({ pageParam }) => fetchItems(pageParam),
    initialPageParam: 1,
    getNextPageParam: (lastPage) => lastPage.nextCursor ?? undefined,
  }))
</script>

{#each query.data?.pages ?? [] as page}
  {#each page.items as item}
    <div>{item.name}</div>
  {/each}
{/each}

<button
  onclick={() => query.fetchNextPage()}
  disabled={!query.hasNextPage || query.isFetchingNextPage}
>
  {query.isFetchingNextPage ? 'Loading more...' : 'Load More'}
</button>
```

**Key Points:**
- In Svelte 4, replace the function wrapper with a plain object and use `$query` prefix throughout.
- `data?.pages` may be `undefined` before the first fetch completes — guard with `?? []`.

---

### useQueryClient

`useQueryClient` reads the `QueryClient` from Svelte context. Usage is identical in both Svelte 4 and 5.

```svelte
<script>
  import { useQueryClient } from '@tanstack/svelte-query'

  const queryClient = useQueryClient()

  function refresh() {
    queryClient.invalidateQueries({ queryKey: ['todos'] })
  }
</script>

<button onclick={refresh}>Refresh</button>
```

**Key Points:**
- `useQueryClient` must be called during component initialization — it reads from Svelte's context, which is only available at that time.
- The returned `QueryClient` is a stable reference, not a store or rune.

---

### Prefetching

Prefetching is framework-agnostic and uses the `QueryClient` directly.

```svelte
<script>
  import { useQueryClient } from '@tanstack/svelte-query'

  const queryClient = useQueryClient()

  let { userId } = $props()   // Svelte 5; use `export let userId` in Svelte 4

  function prefetchUser() {
    queryClient.prefetchQuery({
      queryKey: ['user', userId],
      queryFn: () => fetchUser(userId),
    })
  }
</script>

<a href="/users/{userId}" onmouseenter={prefetchUser}>
  View Profile
</a>
```

---

### Error Handling

#### Per-Query

```svelte
<!-- Svelte 5 -->
{#if query.isError}
  <p>Error: {query.error?.message}</p>
{/if}
```

#### Global via QueryClient

```svelte
<script>
  import { QueryClient, QueryCache, MutationCache } from '@tanstack/svelte-query'

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
</script>
```

---

### TypeScript Integration

Type inference flows from `queryFn` in both Svelte versions.

```svelte
<script lang="ts">
  import { createQuery } from '@tanstack/svelte-query'

  type User = { id: string; name: string }

  let { userId } = $props()

  // `query.data` inferred as `User | undefined`
  const query = createQuery<User>(() => ({
    queryKey: ['user', userId],
    queryFn: (): Promise<User> => fetchUser(userId),
  }))
</script>
```

**Key Points:**
- Add `lang="ts"` to the `<script>` tag to enable TypeScript in Svelte components.
- In Svelte 4, the store type is `Readable<QueryObserverResult<User>>` — the `$query` subscription unwraps it automatically.
- Explicit generic parameters on `createQuery<TData, TError>` allow narrowing both data and error types.

---

### React / Solid / Svelte Adapter Comparison

| Concern | React | Solid | Svelte 4 | Svelte 5 |
|---|---|---|---|---|
| Primitive name | `useQuery` | `createQuery` | `createQuery` | `createQuery` |
| Options argument | Plain object | Reactive function | Plain object | Reactive function |
| Return type | Plain values | Reactive properties | Svelte store | Reactive object |
| Read syntax | `data` | `query.data` | `$query.data` | `query.data` |
| Reactivity mechanism | Re-render | Signals | `$:` blocks + stores | Runes |
| Mutation primitive | `useMutation` | `createMutation` | `createMutation` | `createMutation` |
| Event handler syntax | `onClick` | `onClick` | `on:click` | `onclick` |

---

### DevTools

```svelte
<!-- App.svelte -->
<script>
  import { QueryClient, QueryClientProvider } from '@tanstack/svelte-query'
  import { SvelteQueryDevtools } from '@tanstack/svelte-query-devtools'

  const queryClient = new QueryClient()
</script>

<QueryClientProvider client={queryClient}>
  <slot />
  <SvelteQueryDevtools initialIsOpen={false} />
</QueryClientProvider>
```

**Key Points:**
- `SvelteQueryDevtools` is Svelte-native — it does not depend on React.
- [Inference] Standard bundler configurations typically exclude DevTools from production builds via `NODE_ENV` checks — verify this for your setup.

---

**Related Topics:**
- TanStack Query with Vue (`@tanstack/vue-query`)
- SvelteKit integration — SSR, load functions, and hydration with TanStack Query
- Svelte 5 runes deep dive — `$state`, `$derived`, `$effect`
- Comparing `createQuery` with Svelte's native `load` + `invalidate` pattern
- Persisting the query cache in SvelteKit applications
- Testing TanStack Query in Svelte with `@testing-library/svelte`
- TanStack Router with SvelteKit — prefetching and route loaders