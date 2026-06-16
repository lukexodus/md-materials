## Next.js Integration with TanStack Query

TanStack Query integrates with Next.js across both the **Pages Router** and the **App Router**. Each router has distinct SSR conventions, and TanStack Query adapts to both using the same dehydration/hydration primitives. This document covers setup, SSR patterns, streaming, and production-grade conventions for both routers.

---

### Installation

```bash
npm install @tanstack/react-query
npm install @tanstack/react-query-devtools  # optional
```

No Next.js-specific adapter is required. All integration is handled through standard TanStack Query APIs.

---

### Shared QueryClient Factory

Regardless of which router you use, create a `makeQueryClient` factory to ensure consistent configuration and prevent instance sharing across requests.

```ts
// lib/queryClient.ts
import { QueryClient } from '@tanstack/react-query'

export function makeQueryClient() {
  return new QueryClient({
    defaultOptions: {
      queries: {
        // Prevent immediate refetch after SSR hydration
        staleTime: 60 * 1000,
      },
    },
  })
}
```

**Key Points**
- Always call `makeQueryClient()` per server request — never use a module-level singleton on the server.
- On the client, create one instance and reuse it for the lifetime of the page session.

---

### Pages Router

#### Provider Setup

```tsx
// pages/_app.tsx
import { useState } from 'react'
import { QueryClientProvider } from '@tanstack/react-query'
import { ReactQueryDevtools } from '@tanstack/react-query-devtools'
import { makeQueryClient } from '@/lib/queryClient'
import type { AppProps } from 'next/app'

export default function App({ Component, pageProps }: AppProps) {
  const [queryClient] = useState(() => makeQueryClient())

  return (
    <QueryClientProvider client={queryClient}>
      <Component {...pageProps} />
      <ReactQueryDevtools initialIsOpen={false} />
    </QueryClientProvider>
  )
}
```

**Key Points**
- `useState(() => makeQueryClient())` ensures the client is created once per browser session and is not recreated on re-renders.
- Do not initialize `queryClient` outside of `useState` in a component — doing so would recreate it on every render in development or create a shared instance in SSR.

---

#### SSR with `getServerSideProps`

```tsx
// pages/posts.tsx
import {
  dehydrate,
  HydrationBoundary,
  QueryClient,
  useQuery,
} from '@tanstack/react-query'
import { fetchPosts } from '@/lib/api'
import type { GetServerSideProps } from 'next'

export const getServerSideProps: GetServerSideProps = async () => {
  const queryClient = new QueryClient({
    defaultOptions: { queries: { staleTime: 60 * 1000 } },
  })

  await queryClient.prefetchQuery({
    queryKey: ['posts'],
    queryFn: fetchPosts,
  })

  return {
    props: {
      dehydratedState: dehydrate(queryClient),
    },
  }
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

export default function PostsPage({ dehydratedState }) {
  return (
    <HydrationBoundary state={dehydratedState}>
      <PostsList />
    </HydrationBoundary>
  )
}
```

---

#### SSR with `getStaticProps`

`getStaticProps` follows the same pattern as `getServerSideProps`. The dehydrated state is baked into the static HTML at build time.

```tsx
export const getStaticProps: GetStaticProps = async () => {
  const queryClient = new QueryClient({
    defaultOptions: { queries: { staleTime: 60 * 1000 } },
  })

  await queryClient.prefetchQuery({
    queryKey: ['posts'],
    queryFn: fetchPosts,
  })

  return {
    props: {
      dehydratedState: dehydrate(queryClient),
    },
    revalidate: 60, // ISR: regenerate every 60 seconds
  }
}
```

[Inference] With ISR, the dehydrated state embedded at build/revalidation time will be served to all users until the next revalidation cycle. Clients may see data that is up to `revalidate` seconds old. Whether the client refetches immediately depends on `staleTime` configuration — behavior is not guaranteed.

---

#### Prefetching Multiple Queries

```ts
export const getServerSideProps: GetServerSideProps = async ({ params }) => {
  const queryClient = new QueryClient()
  const userId = params?.id as string

  await Promise.all([
    queryClient.prefetchQuery({
      queryKey: ['user', userId],
      queryFn: () => fetchUser(userId),
    }),
    queryClient.prefetchQuery({
      queryKey: ['user', userId, 'posts'],
      queryFn: () => fetchUserPosts(userId),
    }),
  ])

  return {
    props: { dehydratedState: dehydrate(queryClient) },
  }
}
```

**Key Points**
- Use `Promise.all` when queries are independent — they run in parallel and reduce total SSR latency.
- Use sequential `await` only when one query's result is needed as input to another.

---

### App Router

The App Router introduces React Server Components (RSC), which changes the integration model meaningfully.

#### Provider Setup

Because `QueryClientProvider` uses React context, it must live in a Client Component. Create a dedicated `Providers` wrapper:

```tsx
// app/providers.tsx
'use client'

import { useState } from 'react'
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { ReactQueryDevtools } from '@tanstack/react-query-devtools'
import { makeQueryClient } from '@/lib/queryClient'

let browserQueryClient: QueryClient | undefined

function getQueryClient() {
  if (typeof window === 'undefined') {
    return makeQueryClient()
  }
  if (!browserQueryClient) {
    browserQueryClient = makeQueryClient()
  }
  return browserQueryClient
}

export function Providers({ children }: { children: React.ReactNode }) {
  const [queryClient] = useState(() => getQueryClient())

  return (
    <QueryClientProvider client={queryClient}>
      {children}
      <ReactQueryDevtools initialIsOpen={false} />
    </QueryClientProvider>
  )
}
```

```tsx
// app/layout.tsx  (Server Component)
import { Providers } from './providers'

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body>
        <Providers>{children}</Providers>
      </body>
    </html>
  )
}
```

**Key Points**
- The `getQueryClient` guard (`browserQueryClient`) ensures a single client instance is reused across navigations on the browser.
- On the server, `typeof window === 'undefined'` is `true` — a fresh client is always created, preventing cross-request contamination.
- [Inference] Using `useState(() => getQueryClient())` instead of directly calling `getQueryClient()` in the component body prevents the guard from being bypassed during React's double-invocation in Strict Mode. Behavior may vary across React versions.

---

#### Prefetching in Server Components

```tsx
// app/posts/page.tsx  (Server Component)
import {
  dehydrate,
  HydrationBoundary,
  QueryClient,
} from '@tanstack/react-query'
import { fetchPosts } from '@/lib/api'
import { PostsList } from './PostsList'

export default async function PostsPage() {
  const queryClient = new QueryClient()

  await queryClient.prefetchQuery({
    queryKey: ['posts'],
    queryFn: fetchPosts,
  })

  return (
    <HydrationBoundary state={dehydrate(queryClient)}>
      <PostsList />
    </HydrationBoundary>
  )
}
```

```tsx
// app/posts/PostsList.tsx  (Client Component)
'use client'

import { useQuery } from '@tanstack/react-query'
import { fetchPosts } from '@/lib/api'

export function PostsList() {
  const { data, isPending, isError } = useQuery({
    queryKey: ['posts'],
    queryFn: fetchPosts,
  })

  if (isPending) return <p>Loading...</p>
  if (isError) return <p>Error loading posts.</p>

  return (
    <ul>
      {data.map(post => <li key={post.id}>{post.title}</li>)}
    </ul>
  )
}
```

**Key Points**
- Server Components are `async` — always `await` prefetch calls before rendering.
- The `queryFn` in the Client Component must be executable in the browser. It cannot use server-only modules (e.g., direct database clients, `fs`, or `next/headers`). Use a shared isomorphic fetch function or a Next.js API route.
- `HydrationBoundary` is itself a Client Component. Rendering it from a Server Component is valid — RSC can render Client Components.

---

#### Route Segment with Dynamic Parameters

```tsx
// app/posts/[id]/page.tsx  (Server Component)
import {
  dehydrate,
  HydrationBoundary,
  QueryClient,
} from '@tanstack/react-query'
import { fetchPost, fetchPostComments } from '@/lib/api'
import { PostDetail } from './PostDetail'

interface Props {
  params: { id: string }
}

export default async function PostPage({ params }: Props) {
  const queryClient = new QueryClient()

  await Promise.all([
    queryClient.prefetchQuery({
      queryKey: ['post', params.id],
      queryFn: () => fetchPost(params.id),
    }),
    queryClient.prefetchQuery({
      queryKey: ['post', params.id, 'comments'],
      queryFn: () => fetchPostComments(params.id),
    }),
  ])

  return (
    <HydrationBoundary state={dehydrate(queryClient)}>
      <PostDetail id={params.id} />
    </HydrationBoundary>
  )
}
```

---

#### `generateStaticParams` with Prefetching

For statically generated dynamic routes:

```tsx
// app/posts/[id]/page.tsx
export async function generateStaticParams() {
  const posts = await fetchAllPosts()
  return posts.map(post => ({ id: post.id.toString() }))
}

export default async function PostPage({ params }: Props) {
  const queryClient = new QueryClient()

  await queryClient.prefetchQuery({
    queryKey: ['post', params.id],
    queryFn: () => fetchPost(params.id),
  })

  return (
    <HydrationBoundary state={dehydrate(queryClient)}>
      <PostDetail id={params.id} />
    </HydrationBoundary>
  )
}
```

---

### Streaming SSR with Suspense (App Router)

The App Router supports React streaming. When combined with `useSuspenseQuery`, components that have prefetched data resolve immediately; unprefetched queries suspend their Suspense boundary until the client fetches.

```tsx
// app/posts/page.tsx  (Server Component)
import { Suspense } from 'react'
import {
  dehydrate,
  HydrationBoundary,
  QueryClient,
} from '@tanstack/react-query'
import { fetchPosts } from '@/lib/api'
import { PostsList } from './PostsList'

export default async function PostsPage() {
  const queryClient = new QueryClient()

  await queryClient.prefetchQuery({
    queryKey: ['posts'],
    queryFn: fetchPosts,
  })

  return (
    <HydrationBoundary state={dehydrate(queryClient)}>
      <Suspense fallback={<p>Loading posts...</p>}>
        <PostsList />
      </Suspense>
    </HydrationBoundary>
  )
}
```

```tsx
// app/posts/PostsList.tsx  (Client Component)
'use client'

import { useSuspenseQuery } from '@tanstack/react-query'
import { fetchPosts } from '@/lib/api'

export function PostsList() {
  // Never returns isPending — suspends instead
  const { data } = useSuspenseQuery({
    queryKey: ['posts'],
    queryFn: fetchPosts,
  })

  return (
    <ul>
      {data.map(post => <li key={post.id}>{post.title}</li>)}
    </ul>
  )
}
```

**Key Points**
- `useSuspenseQuery` eliminates the `isPending` branch — the component only renders when data is available.
- If the query was prefetched and hydrated, the Suspense fallback will not appear on initial render.
- [Inference] If the query was not prefetched, the Suspense fallback renders on the server and the client fetches on mount. Streaming behavior depends on the React and Next.js versions in use — behavior is not guaranteed to be identical across versions.

---

### Prefetch Utility Pattern (App Router)

To avoid repeating `new QueryClient()` boilerplate across many Server Components, a utility function can centralize prefetching logic:

```ts
// lib/prefetch.ts
import {
  dehydrate,
  QueryClient,
  type FetchQueryOptions,
} from '@tanstack/react-query'

export async function prefetchAndDehydrate(
  queries: FetchQueryOptions[]
) {
  const queryClient = new QueryClient({
    defaultOptions: { queries: { staleTime: 60 * 1000 } },
  })

  await Promise.all(
    queries.map(options => queryClient.prefetchQuery(options))
  )

  return dehydrate(queryClient)
}
```

```tsx
// app/dashboard/page.tsx
import { HydrationBoundary } from '@tanstack/react-query'
import { prefetchAndDehydrate } from '@/lib/prefetch'
import { fetchUser, fetchStats } from '@/lib/api'
import { Dashboard } from './Dashboard'

export default async function DashboardPage() {
  const dehydratedState = await prefetchAndDehydrate([
    { queryKey: ['user'], queryFn: fetchUser },
    { queryKey: ['stats'], queryFn: fetchStats },
  ])

  return (
    <HydrationBoundary state={dehydratedState}>
      <Dashboard />
    </HydrationBoundary>
  )
}
```

---

### Handling Authentication and Request Context

In SSR, queries often need to include authentication headers or cookies. In the App Router, use `next/headers` to access cookies server-side — but only within Server Components or Route Handlers.

```tsx
// app/profile/page.tsx  (Server Component)
import { cookies } from 'next/headers'
import { dehydrate, HydrationBoundary, QueryClient } from '@tanstack/react-query'
import { Profile } from './Profile'

async function fetchProfile(token: string) {
  const res = await fetch('https://api.example.com/profile', {
    headers: { Authorization: `Bearer ${token}` },
  })
  if (!res.ok) throw new Error('Failed to fetch profile')
  return res.json()
}

export default async function ProfilePage() {
  const cookieStore = cookies()
  const token = cookieStore.get('auth-token')?.value ?? ''

  const queryClient = new QueryClient()

  await queryClient.prefetchQuery({
    queryKey: ['profile'],
    queryFn: () => fetchProfile(token),
  })

  return (
    <HydrationBoundary state={dehydrate(queryClient)}>
      <Profile />
    </HydrationBoundary>
  )
}
```

**Key Points**
- The `token` is used only on the server — it is not passed to the client or exposed in the dehydrated state (only the resulting data is serialized).
- The client-side `queryFn` in `<Profile />` must use a different method to authenticate (e.g., browser cookies sent automatically via `credentials: 'include'`).
- [Inference] If the server and client `queryFn` implementations diverge significantly, data returned may differ between SSR and client refetches. Design shared API contracts carefully.

---

### Next.js `fetch` Caching Considerations

Next.js extends the native `fetch` API with caching options (`next.revalidate`, `cache`). When used inside a `queryFn`, these interact with both Next.js's data cache and TanStack Query's cache.

```ts
async function fetchPosts() {
  const res = await fetch('https://api.example.com/posts', {
    next: { revalidate: 60 }, // Next.js ISR-style cache for this fetch
  })
  return res.json()
}
```

[Inference] TanStack Query's `staleTime` and Next.js's `fetch` cache operate independently. A query may be fresh in TanStack Query's cache but still trigger a new `fetch` call that hits Next.js's cache rather than the network. The interaction between the two caching layers is not trivially predictable — treat them as separate concerns and test behavior in the target deployment environment.

---

### Error Boundaries in App Router

Pair TanStack Query's error states with Next.js App Router `error.tsx` boundaries:

```tsx
// app/posts/error.tsx  (Client Component — required by Next.js)
'use client'

export default function PostsError({
  error,
  reset,
}: {
  error: Error
  reset: () => void
}) {
  return (
    <div>
      <p>Failed to load posts: {error.message}</p>
      <button onClick={reset}>Retry</button>
    </div>
  )
}
```

```tsx
// app/posts/PostsList.tsx  (Client Component)
'use client'

import { useSuspenseQuery } from '@tanstack/react-query'
import { fetchPosts } from '@/lib/api'

export function PostsList() {
  // useSuspenseQuery throws on error — caught by error.tsx boundary
  const { data } = useSuspenseQuery({
    queryKey: ['posts'],
    queryFn: fetchPosts,
  })

  return <ul>{data.map(p => <li key={p.id}>{p.title}</li>)}</ul>
}
```

[Inference] When `useSuspenseQuery` throws, the nearest React error boundary catches it. Next.js `error.tsx` files act as error boundaries per route segment. The `reset` function provided by Next.js re-renders the segment — this may or may not trigger a new TanStack Query fetch depending on `staleTime` and cache state at the time of reset. Behavior is not guaranteed.

---

### Common Mistakes in Next.js Integration

| Mistake | Router | Consequence | Fix |
|---|---|---|---|
| Module-level `QueryClient` singleton on server | Both | Data leaks between requests | Always create per-request |
| `queryFn` uses server-only module (`next/headers`, `fs`) | App | Runtime error on client | Split server/client fetchers |
| Missing `await` on `prefetchQuery` | Both | Empty dehydrated state | Always `await` |
| `staleTime: 0` (default) | Both | Immediate client refetch after hydration | Set `staleTime > 0` |
| Mismatched `queryKey` server vs client | Both | Cache miss; client fetches | Centralize key definitions |
| Passing sensitive server data into query result | Both | Exposed in HTML payload | Filter sensitive fields before returning |
| Creating `queryClient` outside `useState` in `_app` / providers | Both | Recreated on re-render or shared across SSR | Always use `useState` initializer |

---

### Query Key Factories (Recommended)

Centralizing query key definitions prevents key mismatch between server prefetches and client `useQuery` calls.

```ts
// lib/queryKeys.ts
export const postKeys = {
  all: ['posts'] as const,
  list: () => [...postKeys.all, 'list'] as const,
  detail: (id: string) => [...postKeys.all, 'detail', id] as const,
  comments: (id: string) => [...postKeys.detail(id), 'comments'] as const,
}
```

```ts
// Server
await queryClient.prefetchQuery({
  queryKey: postKeys.list(),
  queryFn: fetchPosts,
})

// Client
const { data } = useQuery({
  queryKey: postKeys.list(),
  queryFn: fetchPosts,
})
```

---

### Pages Router vs App Router — Comparison

| Aspect | Pages Router | App Router |
|---|---|---|
| Prefetch location | `getServerSideProps` / `getStaticProps` | `async` Server Component |
| Provider setup | `_app.tsx` | `app/layout.tsx` + `providers.tsx` |
| Data passing mechanism | `props` | `HydrationBoundary` in Server Component |
| Streaming SSR | Limited (requires manual setup) | Native via Suspense |
| Server-only APIs in queryFn | Possible in `getServerSideProps` | Not possible in client `queryFn` |
| Static generation | `getStaticProps` + `revalidate` | `generateStaticParams` + fetch caching |
| `useSuspenseQuery` support | Possible with manual Suspense | Recommended pattern |

---

**Related Topics**

- TanStack Query with Remix
- `useSuspenseQuery` and Suspense boundaries
- Query key factories and centralized key management
- Streaming SSR and progressive hydration
- TanStack Start SSR patterns
- `prefetchInfiniteQuery` for paginated SSR routes
- Authentication patterns in SSR with TanStack Query
- Next.js Route Handlers as API endpoints for client `queryFn`
- `@tanstack/react-query-next-experimental` (experimental RSC-native adapter) [Unverified — verify current status against official docs]