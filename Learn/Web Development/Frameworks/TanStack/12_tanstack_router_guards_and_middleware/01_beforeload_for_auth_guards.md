## beforeLoad for Auth Guards

`beforeLoad` is a route lifecycle hook that runs before the loader. It is the canonical location for authentication and authorization checks in TanStack Router. If the user is not permitted to access a route, `beforeLoad` can redirect or throw before any data fetching begins.

---

### Position in the Lifecycle

Route hooks execute in this order:

```
beforeLoad → loader → component render
```

**Key Points:**

- `beforeLoad` runs before `loader` — no loader work is wasted on unauthorized access
- `beforeLoad` runs on every navigation to the route, including back/forward and preloads
- Parent route `beforeLoad` hooks run before child route `beforeLoad` hooks, making layout routes a natural place for shared auth guards

---

### Basic Signature

ts

```ts
export const Route = createFileRoute('/dashboard')({
  beforeLoad: async ({ context, location }) => {
    // perform checks here
  },
  loader: async () => { /* ... */ },
  component: DashboardComponent,
})
```

**Parameters available in `beforeLoad`:**

| Parameter | Description |
| --- | --- |
| `context` | Router context object — typically carries auth state |
| `location` | Current `location` object including `pathname`, `search`, `hash` |
| `params` | Parsed path params for the current route |
| `search` | Parsed search params for the current route |
| `cause` | `'enter'` or `'stay'` — whether the route is being entered fresh or staying mounted |

---

### Redirecting Unauthenticated Users

The standard pattern is to call `redirect` (imported from TanStack Router) and throw it inside `beforeLoad`:

ts

```ts
import { createFileRoute, redirect } from '@tanstack/react-router'

export const Route = createFileRoute('/dashboard')({
  beforeLoad: async ({ context, location }) => {
    if (!context.auth.isAuthenticated) {
      throw redirect({
        to: '/login',
        search: {
          redirect: location.href,
        },
      })
    }
  },
})
```

**Key Points:**

- `redirect` must be thrown, not returned — returning it has no effect [Inference — consistent with TanStack Router's error-based control flow; verify in your version]
- `location.href` captures the attempted URL so the login page can redirect back after successful authentication
- The redirect is processed immediately; no downstream hooks or loaders execute

---

### Router Context for Auth State

`beforeLoad` receives `context`, which is the router-level context object. Auth state is typically injected here when the router is created:

ts

```ts
// main.tsx
const router = createRouter({
  routeTree,
  context: {
    auth: {
      isAuthenticated: false,
      user: null,
    },
  },
})
```

In practice, auth state comes from a live source — a store, a hook result, or a session check — and is passed into context on each render:

tsx

```tsx
function App() {
  const auth = useAuth() // your auth hook

  return (
    <RouterProvider
      router={router}
      context={{ auth }}
    />
  )
}
```

`beforeLoad` then reads from `context.auth`:

ts

```ts
beforeLoad: ({ context }) => {
  if (!context.auth.isAuthenticated) {
    throw redirect({ to: '/login' })
  }
}
```

**Key Points:**

- Context is not reactive inside `beforeLoad` — it reflects the value at the time of navigation
- Passing a live auth object ensures `beforeLoad` always sees current auth state at the moment of route entry
- TypeScript typing for context requires declaration merging or the `createRootRouteWithContext` helper

---

### Typing the Router Context

To get full TypeScript inference on `context` inside `beforeLoad`, define the context shape using `createRootRouteWithContext`:

ts

```ts
// routes/__root.tsx
import { createRootRouteWithContext } from '@tanstack/react-router'

interface RouterContext {
  auth: {
    isAuthenticated: boolean
    user: User | null
  }
}

export const Route = createRootRouteWithContext<RouterContext>()({
  component: RootComponent,
})
```

All child routes now receive a fully typed `context` parameter in `beforeLoad` and `loader`.

---

### Shared Guards on Layout Routes

Rather than repeating auth checks on every protected route, a single layout route can guard an entire subtree:

ts

```ts
// routes/_authenticated.tsx
export const Route = createFileRoute('/_authenticated')({
  beforeLoad: ({ context, location }) => {
    if (!context.auth.isAuthenticated) {
      throw redirect({
        to: '/login',
        search: { redirect: location.href },
      })
    }
  },
})
```

All routes nested under `_authenticated` inherit this guard. No individual route needs its own auth check.

```
routes/
  __root.tsx
  _authenticated.tsx         ← guard lives here
  _authenticated/
    dashboard.tsx            ← protected automatically
    settings.tsx             ← protected automatically
  login.tsx                  ← outside the layout, no guard
```

**Key Points:**

- The leading underscore makes `_authenticated` a pathless layout route — it adds no segment to the URL
- This is the recommended pattern for protecting groups of routes without URL repetition

---

### Role and Permission Guards

`beforeLoad` is not limited to authentication. Authorization checks — roles, permissions, feature flags — follow the same pattern:

ts

```ts
beforeLoad: ({ context }) => {
  if (!context.auth.isAuthenticated) {
    throw redirect({ to: '/login' })
  }

  if (!context.auth.user?.roles.includes('admin')) {
    throw redirect({ to: '/unauthorized' })
  }
}
```

Checks can be composed sequentially. The first `throw` encountered short-circuits the rest.

---

### Throwing Errors Instead of Redirecting

Instead of redirecting, `beforeLoad` can throw a plain error to trigger the route's `errorComponent`:

ts

```ts
beforeLoad: ({ context }) => {
  if (!context.auth.isAuthenticated) {
    throw new Error('You must be logged in to view this page.')
  }
}
```

**Key Points:**

- Thrown errors propagate to the nearest `errorComponent` in the route tree
- This is appropriate when the intent is to show an error page rather than silently redirect
- `redirect` is generally preferred for auth flows; thrown errors are more appropriate for unexpected access violations

---

### Returning Data from `beforeLoad`

`beforeLoad` can return an object. Properties on that object are merged into the route context and become available in the `loader` and component via `context`:

ts

```ts
beforeLoad: async ({ context }) => {
  if (!context.auth.isAuthenticated) {
    throw redirect({ to: '/login' })
  }

  // Enrich context with verified user
  return {
    user: context.auth.user,
  }
},
loader: async ({ context }) => {
  // context.user is now available here
  const data = await fetchUserData(context.user.id)
  return data
},
```

**Key Points:**

- Returned values are shallow-merged into the context for downstream hooks
- This avoids re-deriving auth data in the loader when `beforeLoad` already verified it
- The return type influences TypeScript inference in `loader` and child route contexts [Inference — verify inference behavior in your version]

---

### `beforeLoad` on the Root Route

A `beforeLoad` on `__root.tsx` runs on every navigation across the entire application. This is appropriate for session refresh logic or global auth state initialization:

ts

```ts
// routes/__root.tsx
export const Route = createRootRouteWithContext<RouterContext>()({
  beforeLoad: async ({ context }) => {
    if (!context.auth.isAuthenticated) {
      await context.auth.tryRefreshSession()
    }
  },
  component: RootComponent,
})
```

**Key Points:**

- Root `beforeLoad` runs before all other route `beforeLoad` hooks
- Expensive operations here affect every navigation — keep them minimal or guarded by conditions
- Session refresh in root `beforeLoad` is a common pattern to silently restore sessions on page load [Inference — pattern is widely documented in TanStack Router examples; behavior depends on your auth implementation]

---

### `beforeLoad` vs `loader` for Auth

| Concern | `beforeLoad` | `loader` |
| --- | --- | --- |
| Auth check and redirect | Preferred | Possible but wasteful |
| Fetch protected data | Not intended | Correct location |
| Access to `context` | Yes | Yes |
| Runs before loader | Yes | N/A |
| Can enrich context | Yes (via return) | No |
| Can redirect | Yes | Yes, but after loader work starts |

---

### `cause` — Skipping Checks on Re-renders

The `cause` parameter indicates whether the route is being freshly entered (`'enter'`) or remains mounted during a sibling or child navigation (`'stay'`):

ts

```ts
beforeLoad: ({ context, cause }) => {
  if (cause === 'stay') return // skip re-checking on internal navigations

  if (!context.auth.isAuthenticated) {
    throw redirect({ to: '/login' })
  }
}
```

[Inference] This optimization is situational. Auth checks are typically cheap enough that skipping on `'stay'` is unnecessary, but it may matter for checks that involve async operations.

---

**Related Topics:**

- `createRootRouteWithContext` — typing and initializing router context
- Router context passing via `RouterProvider` — wiring live auth state
- Pathless layout routes — grouping protected routes without URL impact
- `redirect` API — full options including `replace`, `throw`, and `statusCode`
- `loader` context parameter — consuming enriched context from `beforeLoad`
- `onError` and `errorComponent` — handling thrown errors in the route tree
- Role-based access with fine-grained permissions — extending auth guards to authorization