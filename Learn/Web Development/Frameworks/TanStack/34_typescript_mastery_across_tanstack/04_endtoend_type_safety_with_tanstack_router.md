## End-to-End Type Safety with TanStack Router

TanStack Router is built type-first. Unlike most routing libraries where types are retrofitted via code generation or manual annotation, TanStack Router derives types directly from your route definitions — path parameters, search parameters, loader data, and route context all flow through the component tree without manual casting.

---

### How TanStack Router Achieves End-to-End Type Safety

The router's type system is grounded in a single registered type: the route tree. Every route you define contributes its parameter shapes, loader return types, and context types to a global type that TypeScript can query at any call site.

```ts
// src/routeTree.gen.ts (auto-generated or manually composed)
import { RootRoute, Router } from '@tanstack/react-router'

const routeTree = rootRoute.addChildren([
  indexRoute,
  usersRoute.addChildren([userRoute]),
])

const router = new Router({ routeTree })

// Register the router instance globally for type inference
declare module '@tanstack/react-router' {
  interface Register {
    router: typeof router
  }
}
```

**Key Points**
- The `Register` interface augmentation is the single source of truth for all router types
- Once registered, every TanStack Router hook and utility infers from this type automatically
- Removing or changing a route causes TypeScript errors at every usage site — changes propagate immediately [Inference — depends on TypeScript project configuration and incremental build settings]

---

### Path Parameter Typing

Path parameters are inferred from the route's `path` string. No separate type definition is required.

```ts
import { createFileRoute } from '@tanstack/react-router'

export const Route = createFileRoute('/users/$userId/posts/$postId')({
  component: UserPost,
})

function UserPost() {
  const { userId, postId } = Route.useParams()
  // userId: string
  // postId: string
  return <div>{userId} — {postId}</div>
}
```

**Key Points**
- Every `$`-prefixed segment becomes a typed key on the params object
- Params are always `string` at the type level, matching URL reality — parse to other types explicitly if needed
- Accessing a param key that does not exist in the route path is a compile-time error
- `useParams` without a route context (called from a non-route component) requires a `{ from }` or `{ strict: false }` option — see below

---

### `strict` vs. Non-Strict Parameter Access

TanStack Router distinguishes between strict (route-specific) and non-strict (any-route) parameter access.

```ts
// Strict — only works inside the matched route's component tree
const params = Route.useParams()
// params: { userId: string; postId: string }

// Non-strict — usable in shared/layout components
import { useParams } from '@tanstack/react-router'

const params = useParams({ strict: false })
// params: Partial<AllParams>  ← union of all possible params, all optional

// From a specific route — strict, but outside the component
const params = useParams({ from: '/users/$userId/posts/$postId' })
// params: { userId: string; postId: string }
```

**Key Points**
- `strict: false` gives a wide partial type — always narrow before use
- `{ from: '...' }` provides the same precision as `Route.useParams()` from any location
- Prefer `Route.useParams()` inside the route's own component for the most precise type

---

### Search Parameter Typing with Validation

Search parameters require explicit schema definition because URL search strings are inherently untyped. TanStack Router uses a `validateSearch` function to define and validate the shape.

```ts
import { createFileRoute } from '@tanstack/react-router'
import { z } from 'zod'
import { zodValidator } from '@tanstack/zod-adapter'

const searchSchema = z.object({
  page: z.number().int().min(1).default(1),
  filter: z.string().optional(),
  sort: z.enum(['asc', 'desc']).default('asc'),
})

export const Route = createFileRoute('/products')({
  validateSearch: zodValidator(searchSchema),
  component: ProductList,
})

function ProductList() {
  const { page, filter, sort } = Route.useSearch()
  // page:   number
  // filter: string | undefined
  // sort:   "asc" | "desc"
}
```

**Key Points**
- `validateSearch` runs at runtime on navigation — it both validates and types the search params
- Without `validateSearch`, search params are typed as `Record<string, unknown>`
- Zod is the most common validator, but TanStack Router accepts any function matching `(input: unknown) => T`
- Default values in the schema mean the type reflects post-default shapes, not raw URL strings [Important — the inferred type reflects the validated output, not the raw input]

---

### Navigating with Typed Search and Path Params

`useNavigate`, `<Link>`, and `router.navigate` all enforce types derived from the route tree.

```ts
import { Link, useNavigate } from '@tanstack/react-router'

// Link — TypeScript enforces params and search shape
<Link
  to="/users/$userId/posts/$postId"
  params={{ userId: '42', postId: '7' }}
  search={{ page: 1, sort: 'asc' }}
>
  View Post
</Link>

// useNavigate
const navigate = useNavigate()

navigate({
  to: '/products',
  search: (prev) => ({ ...prev, page: prev.page + 1 }),
})
```

**Key Points**
- Providing an incorrect `params` key or a search value of the wrong type is a compile-time error
- The `search` updater function receives the current search state as its argument, typed from `validateSearch`
- Navigating to a route that does not exist in the route tree is a compile-time error
- [Inference] The completeness of these checks depends on whether `routeTree.gen.ts` is up to date with your file structure

---

### Loader Data Typing

Loader return types flow directly into the component via `Route.useLoaderData()`.

```ts
import { createFileRoute } from '@tanstack/react-router'
import { queryClient } from '../queryClient'
import { userQueryOptions } from '../queries/user'

export const Route = createFileRoute('/users/$userId')({
  loader: async ({ params }) => {
    // params.userId: string  ← typed from route path
    return queryClient.ensureQueryData(userQueryOptions(params.userId))
  },
  component: UserPage,
})

function UserPage() {
  const user = Route.useLoaderData()
  // user: User  ← inferred from loader return type, non-undefined
}
```

**Key Points**
- `useLoaderData()` returns the loader's resolved type directly — no `undefined` because the loader must complete before the component renders
- If the loader throws, the component does not render — the error boundary activates instead
- The loader's `params` argument is typed from the route path, preventing access to non-existent params
- Loader data is not automatically refetched on rerender — it reflects the value at the time of navigation [Important]

---

### Integrating TanStack Query with Loaders for Full Type Flow

The combination of `queryOptions`, loader prefetching, and `useQuery` creates a fully typed pipeline from server to component.

```ts
// queries/user.ts
import { queryOptions } from '@tanstack/react-query'
import { fetchJson } from '../lib/fetch'

export const userQueryOptions = (userId: string) =>
  queryOptions({
    queryKey: ['user', userId],
    queryFn: () => fetchJson<User>(`/api/users/${userId}`),
  })

// routes/users.$userId.tsx
export const Route = createFileRoute('/users/$userId')({
  loader: ({ params, context: { queryClient } }) =>
    queryClient.ensureQueryData(userQueryOptions(params.userId)),

  component: function UserPage() {
    const { userId } = Route.useParams()
    const { data: user } = useQuery(userQueryOptions(userId))
    // user: User | undefined  ← undefined possible if cache is stale
    // OR
    const loaderUser = Route.useLoaderData()
    // loaderUser: User  ← non-undefined, guaranteed by loader
  },
})
```

**Key Points**
- Using both `useLoaderData` and `useQuery` with the same `queryOptions` is a valid pattern — the loader primes the cache, `useQuery` subscribes to updates
- `useLoaderData` gives `User`; `useQuery` gives `User | undefined` — choose based on whether you need reactivity
- The type pipeline is: `fetchJson<User>` → `queryOptions` → `ensureQueryData` → `useLoaderData` → component, with no manual annotation at any step [Inference — assuming all functions are correctly typed upstream]

---

### Route Context Typing

Route context passes typed values (such as `queryClient`, auth state, or services) down the route tree without prop drilling.

```ts
// Root route context definition
import { createRootRouteWithContext } from '@tanstack/react-router'
import type { QueryClient } from '@tanstack/react-query'

interface RouterContext {
  queryClient: QueryClient
  auth: { userId: string | null }
}

export const rootRoute = createRootRouteWithContext<RouterContext>()({
  component: RootLayout,
})

// Router setup
const router = createRouter({
  routeTree,
  context: {
    queryClient,
    auth: { userId: null },
  },
})
```

Accessing context in a loader:

```ts
export const Route = createFileRoute('/dashboard')({
  loader: ({ context }) => {
    // context.queryClient: QueryClient  ← typed
    // context.auth:        { userId: string | null }
    if (!context.auth.userId) throw redirect({ to: '/login' })
    return context.queryClient.ensureQueryData(dashboardQueryOptions)
  },
})
```

**Key Points**
- `createRootRouteWithContext<T>()` defines the shape of the context available to all descendant routes
- Child routes can extend context by returning additional values from their `beforeLoad` functions
- Context is available in `loader`, `beforeLoad`, and `component` (via `Route.useRouteContext()`)
- Context values are not reactive by default — mutations to context after router creation may not propagate predictably [Important]

---

### Typed Redirects

`redirect` throws are typed and checked against the route tree.

```ts
import { redirect } from '@tanstack/react-router'

export const Route = createFileRoute('/admin')({
  beforeLoad: ({ context }) => {
    if (!context.auth.userId) {
      throw redirect({
        to: '/login',
        search: { redirect: '/admin' },
        // 'to' is checked against known routes
        // 'search' is checked against /login's validateSearch schema
      })
    }
  },
})
```

**Key Points**
- Redirecting to an unknown route is a compile-time error
- The `search` object in a redirect is type-checked against the target route's search schema if one is defined
- `replace`, `resetScroll`, and other redirect options are also typed

---

### File-Based Routing and `routeTree.gen.ts`

When using file-based routing with the TanStack Router Vite or CLI plugin, the route tree is auto-generated into `routeTree.gen.ts`. This file is the foundation of all router type inference.

```
src/
  routes/
    __root.tsx          → root route
    index.tsx           → /
    users/
      index.tsx         → /users
      $userId.tsx       → /users/$userId
      $userId.posts/
        $postId.tsx     → /users/$userId/posts/$postId
```

```ts
// main.tsx
import { routeTree } from './routeTree.gen'

const router = createRouter({ routeTree })

declare module '@tanstack/react-router' {
  interface Register {
    router: typeof router
  }
}
```

**Key Points**
- `routeTree.gen.ts` should not be manually edited — it is overwritten on each generation
- Keeping the file committed to version control means CI has access to the full type tree
- If `routeTree.gen.ts` is out of sync with your route files, TypeScript will reflect a stale route tree — regenerate before relying on type errors as a signal [Important]
- The generation step must be part of your dev and build workflow for type safety to hold end-to-end

---

### Full Type Flow Summary

```
Route path string
  └─► path params typed (string)

validateSearch schema
  └─► search params typed (validated output shape)

createRootRouteWithContext<T>
  └─► context typed throughout route tree

loader return type
  └─► useLoaderData() typed (non-undefined)

queryOptions<T>
  └─► ensureQueryData → useLoaderData → User
  └─► useQuery        → data: User | undefined

routeTree + Register
  └─► Link, navigate, useParams, useSearch — all checked against known routes
```

---

**Related Topics**
- Typed route guards with `beforeLoad` and context-based auth
- Nested layouts and inherited loader data types
- `useRouteContext` vs. React Context — when to use each
- Code-splitting and lazy routes without losing type safety
- TanStack Router devtools and inspecting inferred types at runtime
- Integrating TanStack Form with router search params for typed filter state
- `notFound()` throwing and typed 404 boundaries