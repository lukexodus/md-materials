## Remix Integration with TanStack Query

Remix has its own data loading primitives — `loader`, `action`, and `useFetcher` — which handle server-side data fetching natively. TanStack Query is not required for basic data loading in Remix, but it adds value when you need **client-side caching**, **background refetching**, **optimistic updates**, **polling**, or **fine-grained cache invalidation** beyond what Remix's built-in model provides. This document covers setup, SSR prefetching via loaders, client-side usage, and the boundary between Remix's data model and TanStack Query's cache.

---

### When to Use TanStack Query in Remix

Remix's `loader` + `useLoaderData` pattern handles one-time server fetches well. TanStack Query becomes useful when you need:

- Client-side cache that persists across navigations without reloading from the server
- Background refetching on window focus, reconnect, or interval
- Query deduplication across multiple components
- Optimistic updates with rollback
- Paginated or infinite queries with cached pages
- Fine-grained invalidation independent of Remix's revalidation model

[Inference] Using both Remix loaders and TanStack Query together is a deliberate architectural choice. They are not mutually exclusive — Remix loaders can seed TanStack Query's cache via dehydration, and TanStack Query can manage subsequent client-side interactions. Behavior of the combined system depends on how both are configured.

---

### Installation

```bash
npm install @tanstack/react-query
npm install @tanstack/react-query-devtools  # optional
```

No Remix-specific adapter is required.

---

### Shared QueryClient Factory

```ts
// app/lib/queryClient.ts
import { QueryClient } from '@tanstack/react-query'

export function makeQueryClient() {
  return new QueryClient({
    defaultOptions: {
      queries: {
        staleTime: 60 * 1000,
      },
    },
  })
}
```

---

### Provider Setup

In Remix, the root layout (`app/root.tsx`) is the correct place to mount `QueryClientProvider`. It must be a Client Component context — Remix does not use RSC, so there is no `'use client'` directive needed.

```tsx
// app/root.tsx
import { useState } from 'react'
import {
  Links,
  Meta,
  Outlet,
  Scripts,
  ScrollRestoration,
} from '@remix-run/react'
import { QueryClientProvider } from '@tanstack/react-query'
import { ReactQueryDevtools } from '@tanstack/react-query-devtools'
import { makeQueryClient } from '~/lib/queryClient'

export default function App() {
  const [queryClient] = useState(() => makeQueryClient())

  return (
    <html lang="en">
      <head>
        <Meta />
        <Links />
      </head>
      <body>
        <QueryClientProvider client={queryClient}>
          <Outlet />
          <ReactQueryDevtools initialIsOpen={false} />
        </QueryClientProvider>
        <ScrollRestoration />
        <Scripts />
      </body>
    </html>
  )
}
```

**Key Points**
- `useState(() => makeQueryClient())` ensures the client is created once per browser session and not recreated on re-renders.
- Remix renders `root.tsx` on both the server and the client. On the server, `useState` runs once and the result is discarded — a new `QueryClient` is implicitly created per request in this context. [Inference] The server-rendered `QueryClientProvider` is not meaningful for cache state — SSR cache seeding is handled via dehydration in loaders, not via the root provider.

---

### SSR with Loaders: Basic Pattern

Remix `loader` functions run on the server before the route renders. They are the correct location to prefetch TanStack Query data for SSR.

```tsx
// app/routes/posts.tsx
import { json } from '@remix-run/node'
import { useLoaderData } from '@remix-run/react'
import {
  dehydrate,
  HydrationBoundary,
  QueryClient,
  useQuery,
} from '@tanstack/react-query'
import { fetchPosts } from '~/lib/api'

export async function loader() {
  const queryClient = new QueryClient({
    defaultOptions: { queries: { staleTime: 60 * 1000 } },
  })

  await queryClient.prefetchQuery({
    queryKey: ['posts'],
    queryFn: fetchPosts,
  })

  return json({
    dehydratedState: dehydrate(queryClient),
  })
}

function PostsList() {
  const { data, isPending, isError } = useQuery({
    queryKey: ['posts'],
    queryFn: fetchPosts,
  })

  if (isPending) return <p>Loading...</p>
  if (isError) return <p>Error loading posts.</p>

  return (
    <ul>
      {data.map(post => (
        <li key={post.id}>{post.title}</li>
      ))}
    </ul>
  )
}

export default function PostsRoute() {
  const { dehydratedState } = useLoaderData<typeof loader>()

  return (
    <HydrationBoundary state={dehydratedState}>
      <PostsList />
    </HydrationBoundary>
  )
}
```

**Key Points**
- A new `QueryClient` must be created inside each `loader` invocation — never reuse a module-level instance on the server.
- `json()` serializes the dehydrated state to JSON automatically. `dehydratedState` is a plain object, so it serializes cleanly.
- The `queryKey` in the `loader`'s `prefetchQuery` and in the component's `useQuery` must match exactly.

---

### SSR with Dynamic Route Parameters

```tsx
// app/routes/posts.$id.tsx
import { json } from '@remix-run/node'
import { useLoaderData, useParams } from '@remix-run/react'
import {
  dehydrate,
  HydrationBoundary,
  QueryClient,
  useQuery,
} from '@tanstack/react-query'
import { fetchPost } from '~/lib/api'
import type { LoaderFunctionArgs } from '@remix-run/node'

export async function loader({ params }: LoaderFunctionArgs) {
  const { id } = params
  const queryClient = new QueryClient()

  await queryClient.prefetchQuery({
    queryKey: ['post', id],
    queryFn: () => fetchPost(id!),
  })

  return json({ dehydratedState: dehydrate(queryClient) })
}

function PostDetail() {
  const { id } = useParams()

  const { data, isPending, isError } = useQuery({
    queryKey: ['post', id],
    queryFn: () => fetchPost(id!),
  })

  if (isPending) return <p>Loading...</p>
  if (isError) return <p>Error.</p>

  return (
    <article>
      <h1>{data.title}</h1>
      <p>{data.body}</p>
    </article>
  )
}

export default function PostRoute() {
  const { dehydratedState } = useLoaderData<typeof loader>()

  return (
    <HydrationBoundary state={dehydratedState}>
      <PostDetail />
    </HydrationBoundary>
  )
}
```

---

### Prefetching Multiple Queries in a Loader

```ts
export async function loader({ params }: LoaderFunctionArgs) {
  const queryClient = new QueryClient()
  const { id } = params

  await Promise.all([
    queryClient.prefetchQuery({
      queryKey: ['post', id],
      queryFn: () => fetchPost(id!),
    }),
    queryClient.prefetchQuery({
      queryKey: ['post', id, 'comments'],
      queryFn: () => fetchPostComments(id!),
    }),
    queryClient.prefetchQuery({
      queryKey: ['post', id, 'related'],
      queryFn: () => fetchRelatedPosts(id!),
    }),
  ])

  return json({ dehydratedState: dehydrate(queryClient) })
}
```

**Key Points**
- Use `Promise.all` for independent queries — they run in parallel on the server.
- Use sequential `await` only when one query's result feeds into another's parameters.

---

### Authentication and Request Context in Loaders

Remix `loader` functions receive the full `Request` object, making it straightforward to pass auth context to server-side fetchers.

```ts
// app/routes/profile.tsx
export async function loader({ request }: LoaderFunctionArgs) {
  const cookieHeader = request.headers.get('Cookie')
  const session = await getSession(cookieHeader)
  const token = session.get('authToken')

  if (!token) {
    throw redirect('/login')
  }

  const queryClient = new QueryClient()

  await queryClient.prefetchQuery({
    queryKey: ['profile'],
    queryFn: () => fetchProfile(token),
  })

  return json({ dehydratedState: dehydrate(queryClient) })
}
```

**Key Points**
- The `token` is used only within the `loader` — it is not serialized into the dehydrated state. Only the resulting data (the profile object) is included.
- The client-side `queryFn` must authenticate independently, typically by sending cookies automatically with `credentials: 'include'` or reading from a client-accessible cookie.
- [Inference] If the server and client fetchers use different authentication mechanisms or return different data shapes, the hydrated data and subsequent client refetches may differ. Align server and client fetchers carefully.

---

### Client-Only Queries (No SSR Prefetch)

Not every query needs SSR. Queries for user-specific, interactive, or non-critical data can run entirely on the client without a loader prefetch.

```tsx
// app/routes/dashboard.tsx
import { useQuery } from '@tanstack/react-query'
import { fetchUserActivity } from '~/lib/api'

export default function Dashboard() {
  const { data, isPending } = useQuery({
    queryKey: ['userActivity'],
    queryFn: fetchUserActivity,
    refetchInterval: 30_000, // Poll every 30 seconds
  })

  if (isPending) return <p>Loading activity...</p>

  return <ActivityFeed data={data} />
}
```

No `loader` is required. The query runs on mount in the browser. This is identical to standard TanStack Query usage outside of SSR.

---

### Mutations with Remix Actions

Remix `action` functions handle form submissions and mutations on the server. TanStack Query mutations (`useMutation`) handle client-side mutation state. These can be used independently or together.

#### Pattern 1: Remix Action Only (no TanStack Query mutation)

Use when you want Remix's progressive enhancement (works without JS) and are comfortable with full-page revalidation.

```tsx
// app/routes/posts.new.tsx
import { json, redirect } from '@remix-run/node'
import { Form } from '@remix-run/react'
import type { ActionFunctionArgs } from '@remix-run/node'

export async function action({ request }: ActionFunctionArgs) {
  const formData = await request.formData()
  const title = formData.get('title') as string

  await createPost({ title })

  return redirect('/posts')
}

export default function NewPost() {
  return (
    <Form method="post">
      <input name="title" placeholder="Post title" />
      <button type="submit">Create</button>
    </Form>
  )
}
```

#### Pattern 2: TanStack Query `useMutation` + Manual Cache Invalidation

Use when you need optimistic updates, mutation loading states, or fine-grained cache control after a mutation.

```tsx
// app/routes/posts.tsx (Client Component section)
import { useMutation, useQueryClient } from '@tanstack/react-query'
import { createPost } from '~/lib/api'

function NewPostForm() {
  const queryClient = useQueryClient()

  const mutation = useMutation({
    mutationFn: createPost,
    onSuccess: () => {
      // Invalidate the posts list so it refetches
      queryClient.invalidateQueries({ queryKey: ['posts'] })
    },
  })

  function handleSubmit(e: React.FormEvent<HTMLFormElement>) {
    e.preventDefault()
    const form = e.currentTarget
    const title = new FormData(form).get('title') as string
    mutation.mutate({ title })
  }

  return (
    <form onSubmit={handleSubmit}>
      <input name="title" placeholder="Post title" />
      <button type="submit" disabled={mutation.isPending}>
        {mutation.isPending ? 'Creating...' : 'Create'}
      </button>
      {mutation.isError && <p>Error: {mutation.error.message}</p>}
    </form>
  )
}
```

---

### Cache Invalidation After Remix Navigation

Remix revalidates its own loader data on navigation and after actions. TanStack Query's cache is independent — it does not automatically invalidate when Remix revalidates.

To synchronize TanStack Query cache invalidation with Remix navigations, listen to Remix's navigation state:

```tsx
// app/root.tsx or a layout component
import { useEffect } from 'react'
import { useNavigation, useQueryClient } from '@remix-run/react'
// Note: useQueryClient is from @tanstack/react-query
import { useQueryClient as useTanstackQueryClient } from '@tanstack/react-query'

function NavigationInvalidator() {
  const navigation = useNavigation()
  const queryClient = useTanstackQueryClient()

  useEffect(() => {
    // After a successful form submission (action), invalidate all queries
    if (navigation.state === 'idle' && navigation.formMethod) {
      queryClient.invalidateQueries()
    }
  }, [navigation.state, navigation.formMethod, queryClient])

  return null
}
```

[Inference] Invalidating all queries on every action may cause unnecessary refetches. A more targeted approach — invalidating specific query keys based on the route or action being submitted — is preferable in production. The correct invalidation strategy depends entirely on application data dependencies, which are not predictable in general.

---

### Using `useFetcher` Alongside TanStack Query

Remix's `useFetcher` triggers loader or action calls imperatively without navigating. It can be used alongside TanStack Query when you need Remix's server infrastructure for a specific call while TanStack Query manages the cache.

```tsx
import { useFetcher } from '@remix-run/react'
import { useQueryClient } from '@tanstack/react-query'
import { useEffect } from 'react'

function LikeButton({ postId }: { postId: string }) {
  const fetcher = useFetcher()
  const queryClient = useQueryClient()

  useEffect(() => {
    // After the fetcher completes, update the TanStack Query cache
    if (fetcher.state === 'idle' && fetcher.data?.success) {
      queryClient.invalidateQueries({ queryKey: ['post', postId] })
    }
  }, [fetcher.state, fetcher.data, postId, queryClient])

  return (
    <fetcher.Form method="post" action={`/posts/${postId}/like`}>
      <button type="submit">
        {fetcher.state !== 'idle' ? 'Liking...' : 'Like'}
      </button>
    </fetcher.Form>
  )
}
```

---

### Infinite Queries with SSR

```tsx
// app/routes/posts.tsx
import { json } from '@remix-run/node'
import { useLoaderData } from '@remix-run/react'
import {
  dehydrate,
  HydrationBoundary,
  QueryClient,
  useInfiniteQuery,
} from '@tanstack/react-query'
import { fetchPostsPage } from '~/lib/api'

export async function loader() {
  const queryClient = new QueryClient()

  await queryClient.prefetchInfiniteQuery({
    queryKey: ['posts', 'infinite'],
    queryFn: ({ pageParam }) => fetchPostsPage(pageParam),
    initialPageParam: 1,
  })

  return json({ dehydratedState: dehydrate(queryClient) })
}

function InfinitePostsList() {
  const {
    data,
    fetchNextPage,
    hasNextPage,
    isFetchingNextPage,
  } = useInfiniteQuery({
    queryKey: ['posts', 'infinite'],
    queryFn: ({ pageParam }) => fetchPostsPage(pageParam),
    initialPageParam: 1,
    getNextPageParam: (lastPage) => lastPage.nextCursor ?? undefined,
  })

  return (
    <>
      {data?.pages.map((page, i) => (
        <ul key={i}>
          {page.items.map(post => (
            <li key={post.id}>{post.title}</li>
          ))}
        </ul>
      ))}
      <button
        onClick={() => fetchNextPage()}
        disabled={!hasNextPage || isFetchingNextPage}
      >
        {isFetchingNextPage ? 'Loading...' : 'Load more'}
      </button>
    </>
  )
}

export default function PostsRoute() {
  const { dehydratedState } = useLoaderData<typeof loader>()

  return (
    <HydrationBoundary state={dehydratedState}>
      <InfinitePostsList />
    </HydrationBoundary>
  )
}
```

**Key Points**
- `prefetchInfiniteQuery` requires `initialPageParam` — it prefetches only the first page.
- `getNextPageParam` on the client determines subsequent page cursors — it must be defined in `useInfiniteQuery`, not just `prefetchInfiniteQuery`.

---

### Error Handling

```tsx
// app/routes/posts.tsx
export async function loader() {
  const queryClient = new QueryClient()

  try {
    await queryClient.fetchQuery({
      queryKey: ['posts'],
      queryFn: fetchPosts,
    })
  } catch (error) {
    // Option 1: Let Remix handle it — throw a Response
    throw json({ message: 'Failed to load posts' }, { status: 500 })

    // Option 2: Dehydrate the error state so the client receives it
    // (requires shouldDehydrateQuery override — see below)
  }

  return json({ dehydratedState: dehydrate(queryClient) })
}
```

To dehydrate error states so the client renders them without a redundant fetch:

```ts
return json({
  dehydratedState: dehydrate(queryClient, {
    shouldDehydrateQuery: (query) =>
      query.state.status === 'success' ||
      query.state.status === 'error',
  }),
})
```

---

### Remix vs TanStack Query Responsibilities

| Concern | Remix | TanStack Query |
|---|---|---|
| Server data loading | `loader` | `prefetchQuery` (seeds TQ cache) |
| Server mutations | `action` | `useMutation` (client-side state) |
| Client cache | None (no built-in cache) | Full cache with `staleTime`, `gcTime` |
| Background refetching | Not built-in | `refetchOnWindowFocus`, `refetchInterval` |
| Optimistic updates | Limited (via `useFetcher`) | `onMutate`, `onError` rollback |
| Cache invalidation | Full revalidation on navigation | `invalidateQueries` (targeted) |
| Progressive enhancement | Native (works without JS) | Requires JS |
| Pagination / infinite scroll | Manual | `useInfiniteQuery` |

---

### Common Mistakes

| Mistake | Consequence | Fix |
|---|---|---|
| Module-level `QueryClient` in `loader` | Data leakage between requests | Create a new instance inside each `loader` |
| Mismatched `queryKey` in loader vs component | Cache miss; client refetches | Centralize keys in a factory |
| `staleTime: 0` | Immediate refetch after hydration | Set `staleTime > 0` |
| Forgetting `HydrationBoundary` in route component | Dehydrated state ignored | Wrap component tree in `HydrationBoundary` |
| Using Remix `action` and `useMutation` without sync | TanStack cache stale after action | Invalidate on `useMutation.onSuccess` or post-navigation |
| Passing server-only request context to client `queryFn` | Runtime error | Use separate server/client fetchers |

---

### Query Key Factories

```ts
// app/lib/queryKeys.ts
export const postKeys = {
  all: ['posts'] as const,
  list: () => [...postKeys.all, 'list'] as const,
  detail: (id: string) => [...postKeys.all, 'detail', id] as const,
  comments: (id: string) => [...postKeys.detail(id), 'comments'] as const,
}
```

```ts
// In loader
await queryClient.prefetchQuery({
  queryKey: postKeys.list(),
  queryFn: fetchPosts,
})

// In component
const { data } = useQuery({
  queryKey: postKeys.list(),
  queryFn: fetchPosts,
})
```

---

**Related Topics**

- TanStack Query with Next.js App Router
- TanStack Start integration (Remix-like meta-framework built on TanStack Router)
- `useMutation` and optimistic updates
- Cache invalidation strategies with `invalidateQueries`
- `useFetcher` patterns and interoperability
- `prefetchInfiniteQuery` for paginated SSR
- Query key factories and centralized key management
- Remix `defer` and streaming with TanStack Query [Speculation — verify against current Remix and TanStack Query docs]
- Error boundary patterns in Remix with TanStack Query