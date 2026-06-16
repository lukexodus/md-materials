## Route Context

Route context is a typed object that flows through the router and is accessible in `beforeLoad`, `loader`, and other route hooks. It is the primary mechanism for sharing application-wide state — such as auth, query clients, and service instances — with route-level logic without prop drilling or module-level singletons.

---

### What Route Context Is

Context in TanStack Router is a plain object provided at router creation time and optionally extended by each route as navigation proceeds down the tree. Every route in the hierarchy can read from context and contribute additional properties to it for its children.

It is not reactive in the React sense. Context reflects the values present at the time a navigation occurs, not a live subscription to state changes.

---

### Providing Initial Context

Context is passed to `createRouter` via the `context` option:

ts

```ts
import { createRouter } from '@tanstack/react-router'
import { routeTree } from './routeTree.gen'
import { queryClient } from './queryClient'

const router = createRouter({
  routeTree,
  context: {
    queryClient,
    auth: {
      isAuthenticated: false,
      user: null,
    },
  },
})
```

This object becomes the base context available to all routes.

---

### Updating Context on Each Render

Because context is not reactive, live values — such as auth state from a hook — must be passed into `RouterProvider` on each render to stay current:

tsx

```tsx
function App() {
  const auth = useAuth()
  const queryClient = useQueryClient()

  return (
    <RouterProvider
      router={router}
      context={{ auth, queryClient }}
    />
  )
}
```

**Key Points:**

- `RouterProvider` merges the passed `context` with the router's initial context on each render
- When a navigation occurs, `beforeLoad` and `loader` receive the context value from the most recent render
- This pattern ensures auth state seen inside `beforeLoad` reflects reality at the moment of navigation, not at router creation time

---

### Typing Context with `createRootRouteWithContext`

For full TypeScript inference across all routes, define the context shape on the root route using `createRootRouteWithContext`:

ts

```ts
// routes/__root.tsx
import { createRootRouteWithContext } from '@tanstack/react-router'
import type { QueryClient } from '@tanstack/react-query'
import type { AuthState } from '../auth'

interface RouterContext {
  queryClient: QueryClient
  auth: AuthState
}

export const Route = createRootRouteWithContext<RouterContext>()({
  component: RootComponent,
})
```

**Key Points:**

- All child routes automatically receive the typed `context` parameter in `beforeLoad` and `loader`
- Without this, context is typed as `unknown` and requires manual casting
- The interface only needs to be defined once on the root route

---

### Reading Context in `beforeLoad`

ts

```ts
export const Route = createFileRoute('/dashboard')({
  beforeLoad: ({ context }) => {
    if (!context.auth.isAuthenticated) {
      throw redirect({ to: '/login' })
    }
  },
})
```

Context is available as a destructured parameter. No imports or hooks are needed to access it.

---

### Reading Context in `loader`

ts

```ts
export const Route = createFileRoute('/dashboard')({
  loader: ({ context }) => {
    return context.queryClient.ensureQueryData(dashboardQueryOptions)
  },
})
```

**Key Points:**

- `loader` receives the same `context` object as `beforeLoad`
- If `beforeLoad` returns additional properties, those are merged into `context` by the time `loader` runs

---

### Extending Context from `beforeLoad`

Each route's `beforeLoad` can return a plain object. Properties on that object are merged into the context and become available to the current route's `loader` and all child route hooks:

ts

```ts
// routes/_authenticated.tsx
export const Route = createFileRoute('/_authenticated')({
  beforeLoad: ({ context }) => {
    if (!context.auth.isAuthenticated) {
      throw redirect({ to: '/login' })
    }

    return {
      user: context.auth.user,
    }
  },
})
```

ts

```ts
// routes/_authenticated/dashboard.tsx
export const Route = createFileRoute('/_authenticated/dashboard')({
  loader: ({ context }) => {
    // context.user is available here, added by parent beforeLoad
    return fetchDashboardData(context.user.id)
  },
})
```

**Key Points:**

- Context extension is additive — existing properties are preserved, new ones are merged in
- Overwriting an existing key replaces its value for downstream routes
- This flows strictly downward — child routes cannot inject context visible to parents
- TypeScript inference for extended context requires explicit return type annotation or inference from the return value [Inference — verify inference behavior for your version]

---

### Context Merging Order

As navigation descends the route tree, context is assembled in order:

```
Router-level context (createRouter / RouterProvider)
  ↓ merged with
Root route beforeLoad return
  ↓ merged with
Layout route beforeLoad return
  ↓ merged with
Leaf route beforeLoad return
  ↓ available in
Leaf route loader
```

Each layer sees all properties contributed by layers above it.

---

### Practical Patterns

#### Passing a Query Client

ts

```ts
// __root.tsx
interface RouterContext {
  queryClient: QueryClient
}

// any route loader
loader: ({ context }) => {
  return context.queryClient.ensureQueryData(myQueryOptions)
}
```

This avoids importing the query client as a module-level singleton in every route file.

#### Verifying and Narrowing Auth

ts

```ts
// _authenticated.tsx beforeLoad
return {
  user: context.auth.user!, // narrowed — non-null after auth check
}

// child loader — user is typed as non-nullable
loader: ({ context }) => fetchData(context.user.id)
```

#### Feature Flags

ts

```ts
// router context
context: {
  flags: await fetchFeatureFlags(),
}

// route beforeLoad
beforeLoad: ({ context }) => {
  if (!context.flags.newDashboard) {
    throw redirect({ to: '/dashboard-legacy' })
  }
}
```

---

### Context vs Search Params vs Loader Data

| Mechanism | Purpose | Reactive | Available in hooks |
| --- | --- | --- | --- |
| `context` | App-wide services, auth, config | No | `beforeLoad`, `loader` |
| `search` params | URL-driven state, filters, pagination | Yes (URL-driven) | `beforeLoad`, `loader`, component |
| Loader return | Route-specific fetched data | Via invalidation | Component only |

Context is for infrastructure and identity. Search params are for URL-driven state. Loader return values are for fetched data.

---

### Context Is Not Available in Components

Route context is a hook and lifecycle concept — it is not directly accessible inside the component via a context hook. The component accesses data through `Route.useLoaderData()` or `Route.useRouteContext()`.

`useRouteContext` exposes the context object inside the component:

tsx

```tsx
function DashboardComponent() {
  const context = Route.useRouteContext()
  // context.user, context.queryClient, etc.
}
```

**Key Points:**

- `useRouteContext` is available on the typed `Route` object generated per file
- It returns the context as it existed when the route was entered, not a live reactive value
- For live auth state in components, read from your auth store or hook directly rather than relying on context

---

### Context and Preloading

During route preloads triggered by hover or focus, `beforeLoad` and `loader` run with the context value from the most recent `RouterProvider` render. [Inference — preload uses the router's current state; behavior is consistent with normal navigation context resolution]

---

### Common Mistakes

**Putting context values in `createRouter` only**
If auth state is initialized in `createRouter` context and never updated via `RouterProvider`, `beforeLoad` will always see the initial (likely unauthenticated) value.

**Expecting context to be reactive in components**
`useRouteContext()` returns a snapshot, not a subscription. Live UI updates from auth state changes require a separate reactive source (store, hook, React context).

**Returning non-plain values from `beforeLoad`**
Returned context extensions should be plain serializable objects where possible. [Inference — class instances and functions may cause issues in SSR or devtools serialization; verify for your use case]

---

**Related Topics:**

- `createRootRouteWithContext` — root-level context typing reference
- `beforeLoad` for auth guards — practical context consumption patterns
- `useRouteContext` — accessing context inside components
- `RouterProvider` context prop — passing live values at render time
- Loader context parameter — using context in data fetching
- TanStack Query integration — passing `queryClient` through context
- Context extension and TypeScript inference — typing merged context across route layers