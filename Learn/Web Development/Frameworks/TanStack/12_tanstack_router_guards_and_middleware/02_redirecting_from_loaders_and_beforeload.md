## Redirecting from Loaders and beforeLoad

TanStack Router handles redirects thrown inside `beforeLoad` and `loader` as first-class navigation events. Throwing a `redirect` immediately halts the current navigation and initiates a new one, without rendering the route or completing remaining hooks.

---

### The `redirect` Utility

`redirect` is imported from `@tanstack/react-router` and constructs a redirect descriptor. It must be thrown — not returned:

ts

```ts
import { redirect } from '@tanstack/react-router'

throw redirect({ to: '/login' })
```

Returning `redirect(...)` without throwing has no effect. The router only acts on thrown redirects.

---

### Throwing from `beforeLoad`

The most common location for redirects. Executes before any loader work begins:

ts

```ts
export const Route = createFileRoute('/settings')({
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

**Key Points:**

- No loader runs if `beforeLoad` throws
- Parent `beforeLoad` hooks run before child ones — a parent redirect prevents all child hooks from executing
- `location.href` preserves the originally attempted URL for post-login restoration

---

### Throwing from `loader`

Redirects inside `loader` are also supported. The redirect fires after `beforeLoad` completes but before the component renders:

ts

```ts
export const Route = createFileRoute('/dashboard')({
  loader: async ({ context }) => {
    const profile = await fetchProfile(context.auth.user.id)

    if (profile.requiresOnboarding) {
      throw redirect({ to: '/onboarding' })
    }

    return profile
  },
})
```

**Key Points:**

- Prefer `beforeLoad` for auth redirects — `loader` has already begun data work when its redirect fires
- `loader` redirects are appropriate when the redirect condition depends on fetched data
- Throwing from `loader` discards any data fetched up to that point

---

### `redirect` Options

ts

```ts
throw redirect({
  to: '/target',
  search: { key: 'value' },
  params: { id: '42' },
  hash: 'section',
  replace: true,
  resetScroll: false,
  statusCode: 301,
})
```

| Option | Type | Description |
| --- | --- | --- |
| `to` | `string` | Target route path |
| `search` | `object` | Search params to include on destination |
| `params` | `object` | Path params for parameterized routes |
| `hash` | `string` | Hash fragment on destination URL |
| `replace` | `boolean` | Replace history entry instead of pushing |
| `resetScroll` | `boolean` | Whether to reset scroll on arrival |
| `statusCode` | `number` | HTTP status code for SSR redirects (e.g. `301`, `302`) |

**Key Points:**

- `statusCode` is only meaningful in SSR environments — it sets the HTTP response status
- `replace: true` prevents the redirected-from route from appearing in browser history, which is appropriate for auth redirects where back-navigation should not return to the guarded route
- All options follow the same shape as `router.navigate`

---

### Preserving the Intended Destination

A standard pattern passes the originally attempted URL as a search param so the login page can redirect back after authentication:

ts

```ts
// Guard — capture attempted location
beforeLoad: ({ location }) => {
  if (!context.auth.isAuthenticated) {
    throw redirect({
      to: '/login',
      search: { redirect: location.href },
    })
  }
}
```

ts

```ts
// Login route — read and use the redirect param
export const Route = createFileRoute('/login')({
  validateSearch: (search) => ({
    redirect: (search.redirect as string) ?? '/',
  }),
  component: LoginComponent,
})

function LoginComponent() {
  const { redirect: redirectTo } = Route.useSearch()
  const router = useRouter()

  const handleLogin = async () => {
    await login()
    router.navigate({ to: redirectTo })
  }

  return <LoginForm onSubmit={handleLogin} />
}
```

**Key Points:**

- `validateSearch` ensures the `redirect` param is typed and defaulted safely
- `location.href` includes the full path plus search and hash — appropriate for deep link restoration
- Validate or sanitize `redirect` values before navigating to them to avoid open redirect vulnerabilities [Inference — standard security practice; TanStack Router does not automatically sanitize this value]

---

### Typed Redirect Destinations

When using file-based routing with generated types, `to` is type-checked against known routes. Navigating to an unknown path produces a TypeScript error:

ts

```ts
// Type error if '/nonexistent' is not a registered route
throw redirect({ to: '/nonexistent' })
```

For dynamic or externally sourced redirect targets, `as string` casting or runtime validation is necessary, accepting the loss of type safety.

---

### `redirect` with Path Params

When the destination route contains path parameters, they must be supplied:

ts

```ts
throw redirect({
  to: '/users/$userId',
  params: { userId: context.auth.user.id },
})
```

Omitting required params produces a TypeScript error when types are generated.

---

### Redirecting to External URLs

`redirect` targets registered routes only. For external URLs, use `window.location` directly inside `beforeLoad` or `loader`, or a platform-appropriate navigation mechanism:

ts

```ts
beforeLoad: () => {
  window.location.href = 'https://external-auth-provider.com/login'
}
```

[Inference] This is not a thrown redirect — it is imperative navigation. The router does not track or handle this transition. In SSR environments, a different mechanism is required since `window` is not available on the server.

---

### SSR Redirects

In SSR environments, thrown redirects signal to the server to respond with an HTTP redirect rather than rendering HTML. The `statusCode` option controls the response code:

ts

```ts
throw redirect({
  to: '/login',
  statusCode: 302,
})
```

**Key Points:**

- Without `statusCode`, SSR redirect behavior depends on the adapter and framework defaults [Unverified — verify with your specific TanStack Start or SSR adapter]
- Client-side navigations ignore `statusCode` entirely
- SSR redirect handling requires a server adapter that integrates with TanStack Router's response system

---

### Redirect vs Throwing an Error

| Scenario | Use |
| --- | --- |
| User is unauthenticated | `throw redirect({ to: '/login' })` |
| User lacks permission | `throw redirect({ to: '/unauthorized' })` |
| Data condition requires different route | `throw redirect({ to: '/other' })` |
| Unexpected failure | `throw new Error(...)` → `errorComponent` |
| Resource not found | `throw notFound()` → `notFoundComponent` |

`redirect`, `Error`, and `notFound()` are all thrown — the distinction is in what the router does with each.

---

### Redirect Loops

If a redirect target also redirects (e.g., `/login` redirects to `/dashboard` which redirects back to `/login`), the router enters an infinite redirect loop. TanStack Router does not automatically detect or break redirect cycles. [Inference — no built-in cycle detection is documented; verify in your version]

Guard against this by checking auth state before redirecting from the login route:

ts

```ts
// login route beforeLoad
beforeLoad: ({ context }) => {
  if (context.auth.isAuthenticated) {
    throw redirect({ to: '/dashboard' })
  }
}
```

This ensures already-authenticated users are redirected away from the login page, and unauthenticated users are never sent back there from a protected route.

---

### `notFound` — a Related Throw

For missing resources, TanStack Router provides `notFound()` as a parallel to `redirect`:

ts

```ts
import { notFound } from '@tanstack/react-router'

loader: async ({ params }) => {
  const item = await fetchItem(params.id)
  if (!item) throw notFound()
  return item
}
```

`notFound()` renders the nearest `notFoundComponent` rather than triggering a navigation. It is not a redirect but follows the same throw-based control flow pattern.

---

**Related Topics:**

- `beforeLoad` for auth guards — redirect patterns in the pre-loader hook
- `validateSearch` — typing and defaulting search params including redirect targets
- `notFound` and `notFoundComponent` — handling missing resources
- `errorComponent` — handling thrown errors in the route tree
- Router context and `createRootRouteWithContext` — supplying auth state to guards
- SSR and TanStack Start — server-side redirect response handling
- Open redirect vulnerabilities — sanitizing externally sourced redirect targets