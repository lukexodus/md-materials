## TanStack Query with Vue

### Overview

TanStack Query's Vue adapter (`@tanstack/vue-query`) brings the full Query feature set to Vue 3 applications. It wraps the framework-agnostic core with Vue-specific composables, reactive refs, and plugin-based setup. The API surface closely mirrors the React adapter with adjustments for Vue's reactivity system and composition API conventions.

---

### Installation

```bash
# npm
npm install @tanstack/vue-query

# pnpm
pnpm add @tanstack/vue-query

# yarn
yarn add @tanstack/vue-query
```

**Key Points:**
- Requires Vue 3. Vue 2 is not supported by the current major version. [Unverified: community forks may exist for Vue 2.]
- `@tanstack/vue-query` depends on `@tanstack/query-core` which is installed automatically as a peer dependency.

---

### Setup and Configuration

#### Registering the Plugin

```ts
// main.ts
import { createApp } from 'vue'
import { VueQueryPlugin, QueryClient } from '@tanstack/vue-query'
import App from './App.vue'

const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 30_000,
      gcTime: 5 * 60 * 1000,
      retry: 2,
    },
  },
})

const app = createApp(App)
app.use(VueQueryPlugin, { queryClient })
app.mount('#app')
```

**Key Points:**
- Passing a pre-constructed `QueryClient` to the plugin gives full control over default options.
- If no `queryClient` is provided, the plugin constructs one internally with library defaults.
- The plugin registers the `QueryClient` via Vue's `provide`/`inject` system, making it available to all descendant components.

#### Accessing the QueryClient Directly

```ts
import { useQueryClient } from '@tanstack/vue-query'

const queryClient = useQueryClient()
```

---

### `useQuery` — Core Data Fetching

```vue
<script setup lang="ts">
import { useQuery } from '@tanstack/vue-query'

const { data, isPending, isError, error, isFetching } = useQuery({
  queryKey: ['posts'],
  queryFn: () => fetch('/api/posts').then(res => res.json()),
})
</script>

<template>
  <div v-if="isPending">Loading…</div>
  <div v-else-if="isError">Error: {{ error.message }}</div>
  <ul v-else>
    <li v-for="post in data" :key="post.id">{{ post.title }}</li>
  </ul>
</template>
```

#### Return Values

| Property      | Type                                     | Description                                  |
| ------------- | ---------------------------------------- | -------------------------------------------- |
| `data`        | `Ref<T \| undefined>`                    | Resolved query data                          |
| `isPending`   | `Ref<boolean>`                           | No data yet, fetch in progress               |
| `isSuccess`   | `Ref<boolean>`                           | Data available                               |
| `isError`     | `Ref<boolean>`                           | Last fetch failed                            |
| `error`       | `Ref<Error \| null>`                     | Error object if `isError` is true            |
| `isFetching`  | `Ref<boolean>`                           | Any fetch in progress (including background) |
| `isStale`     | `Ref<boolean>`                           | Data has exceeded `staleTime`                |
| `refetch`     | `() => Promise`                          | Manually trigger a refetch                   |
| `status`      | `Ref<'pending' \| 'success' \| 'error'>` | Coarse status                                |
| `fetchStatus` | `Ref<'fetching' \| 'paused' \| 'idle'>`  | Network-level status                         |

**Key Points:**
- All returned values are Vue `Ref`s. Access their values with `.value` in `<script setup>` logic; they unwrap automatically in templates.

---

### Reactive Query Keys

Query keys in Vue can be reactive, allowing queries to automatically re-run when their dependencies change. Pass a computed ref or a function returning an array.

```vue
<script setup lang="ts">
import { ref, computed } from 'vue'
import { useQuery } from '@tanstack/vue-query'

const userId = ref(1)

const { data } = useQuery({
  queryKey: computed(() => ['user', userId.value]),
  queryFn: () => fetch(`/api/users/${userId.value}`).then(r => r.json()),
})

function switchUser(id: number) {
  userId.value = id // query re-runs automatically
}
</script>
```

**Key Points:**
- When `queryKey` is a `computed`, TanStack Query watches it reactively. A new key value triggers a new fetch and may produce a new cache entry.
- [Inference] Passing a plain (non-reactive) array as `queryKey` will not react to external ref changes. Wrap in `computed` whenever the key depends on reactive state.

---

### `enabled` — Conditional and Dependent Queries

Use a reactive `enabled` option to prevent a query from running until a condition is met.

```vue
<script setup lang="ts">
import { ref, computed } from 'vue'
import { useQuery } from '@tanstack/vue-query'

const userId = ref<number | null>(null)

const { data: user } = useQuery({
  queryKey: computed(() => ['user', userId.value]),
  queryFn: () => fetch(`/api/users/${userId.value}`).then(r => r.json()),
  enabled: computed(() => userId.value !== null),
})
</script>
```

**Dependent query pattern:**

```vue
<script setup lang="ts">
import { computed } from 'vue'
import { useQuery } from '@tanstack/vue-query'

const { data: user, isSuccess } = useQuery({
  queryKey: ['currentUser'],
  queryFn: fetchCurrentUser,
})

const { data: orders } = useQuery({
  queryKey: computed(() => ['orders', user.value?.id]),
  queryFn: () => fetchOrders(user.value!.id),
  enabled: computed(() => isSuccess.value && !!user.value?.id),
})
</script>
```

---

### `useMutation` — Mutations

```vue
<script setup lang="ts">
import { useMutation, useQueryClient } from '@tanstack/vue-query'

const queryClient = useQueryClient()

const { mutate, isPending, isError, error } = useMutation({
  mutationFn: (newPost: { title: string; body: string }) =>
    fetch('/api/posts', {
      method: 'POST',
      body: JSON.stringify(newPost),
    }).then(r => r.json()),
  onSuccess: () => {
    queryClient.invalidateQueries({ queryKey: ['posts'] })
  },
  onError: (err) => {
    console.error('Mutation failed:', err)
  },
})

function handleSubmit(title: string, body: string) {
  mutate({ title, body })
}
</script>
```

#### `mutate` vs `mutateAsync`

| Method | Behavior |
|---|---|
| `mutate` | Fire-and-forget; errors are handled by `onError` callback |
| `mutateAsync` | Returns a Promise; errors must be caught by the caller |

```ts
// Using mutateAsync with try/catch
const { mutateAsync } = useMutation({ mutationFn: createPost })

async function handleSubmit(data: PostData) {
  try {
    const result = await mutateAsync(data)
    router.push(`/posts/${result.id}`)
  } catch (err) {
    // handle locally
  }
}
```

---

### Parallel Queries with `useQueries`

```vue
<script setup lang="ts">
import { useQueries } from '@tanstack/vue-query'

const ids = [1, 2, 3]

const results = useQueries({
  queries: ids.map(id => ({
    queryKey: ['post', id],
    queryFn: () => fetch(`/api/posts/${id}`).then(r => r.json()),
  })),
})
</script>

<template>
  <div v-for="(result, i) in results" :key="i">
    <span v-if="result.isPending">Loading post {{ i + 1 }}…</span>
    <span v-else>{{ result.data?.title }}</span>
  </div>
</template>
```

**Key Points:**
- `useQueries` returns an array of query result objects, each a reactive ref bundle.
- [Inference] The `queries` array itself can be a computed ref to make the set of parallel queries reactive, though verify this against your version's documentation.

---

### Infinite Queries with `useInfiniteQuery`

```vue
<script setup lang="ts">
import { useInfiniteQuery } from '@tanstack/vue-query'

const {
  data,
  fetchNextPage,
  hasNextPage,
  isFetchingNextPage,
  isPending,
} = useInfiniteQuery({
  queryKey: ['posts', 'infinite'],
  queryFn: ({ pageParam }) =>
    fetch(`/api/posts?page=${pageParam}`).then(r => r.json()),
  initialPageParam: 1,
  getNextPageParam: (lastPage, allPages) =>
    lastPage.hasMore ? allPages.length + 1 : undefined,
})
</script>

<template>
  <div v-if="isPending">Loading…</div>
  <template v-else>
    <ul>
      <li
        v-for="post in data.pages.flatMap(p => p.items)"
        :key="post.id"
      >
        {{ post.title }}
      </li>
    </ul>
    <button
      v-if="hasNextPage"
      :disabled="isFetchingNextPage"
      @click="fetchNextPage"
    >
      {{ isFetchingNextPage ? 'Loading more…' : 'Load more' }}
    </button>
  </template>
</template>
```

**Key Points:**
- `data.pages` is an array of page results. Flatten with `.flatMap` to render all items.
- `getNextPageParam` returning `undefined` signals no further pages; `hasNextPage` becomes `false`.
- `initialPageParam` is required in v5. [Unverified: whether earlier v5 minor releases required this — check your version.]

---

### Prefetching

```ts
// In a route guard or setup function
import { useQueryClient } from '@tanstack/vue-query'

const queryClient = useQueryClient()

await queryClient.prefetchQuery({
  queryKey: ['posts'],
  queryFn: fetchPosts,
})
```

Prefetching populates the cache before a component mounts. When the component calls `useQuery` with the same key, it reads from cache immediately without a loading state (provided data is still fresh).

---

### SSR with Nuxt

For Nuxt 3, TanStack Query provides SSR support via state dehydration and rehydration.

```ts
// plugins/vue-query.ts
import type { DehydratedState, VueQueryPluginOptions } from '@tanstack/vue-query'
import { VueQueryPlugin, QueryClient, hydrate, dehydrate } from '@tanstack/vue-query'
import { defineNuxtPlugin, useState } from '#app'

export default defineNuxtPlugin((nuxt) => {
  const vueQueryState = useState<DehydratedState | null>('vue-query')

  const queryClient = new QueryClient()
  const options: VueQueryPluginOptions = { queryClient }

  nuxt.vueApp.use(VueQueryPlugin, options)

  if (process.server) {
    nuxt.hooks.hook('app:rendered', () => {
      vueQueryState.value = dehydrate(queryClient)
    })
  }

  if (process.client) {
    nuxt.hooks.hook('app:created', () => {
      hydrate(queryClient, vueQueryState.value)
    })
  }
})
```

**Key Points:**
- `dehydrate` serializes the cache state on the server.
- `hydrate` restores it on the client, allowing components to read from cache without an additional network request on first render.
- [Inference] This pattern requires that server-side `prefetchQuery` calls complete before `app:rendered` fires. Verify execution order in your Nuxt version.

---

### Optimistic Updates

```ts
const queryClient = useQueryClient()

const { mutate } = useMutation({
  mutationFn: updatePost,
  onMutate: async (updatedPost) => {
    await queryClient.cancelQueries({ queryKey: ['posts'] })
    const previous = queryClient.getQueryData(['posts'])
    queryClient.setQueryData(['posts'], (old: Post[]) =>
      old.map(p => p.id === updatedPost.id ? { ...p, ...updatedPost } : p)
    )
    return { previous }
  },
  onError: (_err, _vars, context) => {
    if (context?.previous) {
      queryClient.setQueryData(['posts'], context.previous)
    }
  },
  onSettled: () => {
    queryClient.invalidateQueries({ queryKey: ['posts'] })
  },
})
```

**Key Points:**
- `cancelQueries` halts in-flight refetches to avoid overwriting the optimistic update.
- `onMutate` returns a context object that is passed to `onError` and `onSettled`.
- `onError` rolls back to the snapshot captured before the optimistic update.
- `onSettled` invalidates the query to sync with server state regardless of outcome.

---

### DevTools for Vue

```bash
npm install @tanstack/vue-query-devtools
```

```vue
<script setup lang="ts">
import { VueQueryDevtools } from '@tanstack/vue-query-devtools'
</script>

<template>
  <RouterView />
  <VueQueryDevtools />
</template>
```

**Key Points:**
- The DevTools component reads from the plugin-provided `QueryClient` automatically.
- It renders only in development by default (`process.env.NODE_ENV === 'development'`). [Inference] Verify this behavior with your bundler configuration.
- Props (`initialIsOpen`, `buttonPosition`, `position`) mirror the React adapter. [Unverified: exact prop parity — consult the Vue DevTools package documentation.]

---