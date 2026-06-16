## Link and Navigation in TanStack Router

---

### Overview

TanStack Router provides a suite of type-safe navigation primitives. Every destination — whether expressed in JSX via `<Link>`, imperatively via `useNavigate`, or declaratively via `redirect` — is validated at compile time against the route tree when type generation is active. Mismatched paths, missing params, or invalid search params produce TypeScript errors before reaching the browser.

**Key Points:**
- `<Link>` is the primary JSX navigation component — it renders an `<a>` tag and manages active state
- `useNavigate` provides imperative navigation from event handlers and effects
- `redirect` is used inside loaders and `beforeLoad` to redirect before a route renders
- All navigation APIs share the same destination interface: `to`, `params`, `search`, `hash`, and more
- Type safety across all navigation APIs requires the router's generated type file (`routeTree.gen.ts`) to be present and up to date

---

### The `<Link>` Component

`<Link>` is the standard way to navigate between routes in JSX. It renders a native `<a>` element, supports keyboard navigation, and participates in the browser's native link behavior (right-click, open in new tab, etc.).

```tsx
import { Link } from '@tanstack/react-router'

function Nav() {
  return (
    <nav>
      <Link to="/">Home</Link>
      <Link to="/dashboard">Dashboard</Link>
      <Link to="/dashboard/settings">Settings</Link>
    </nav>
  )
}
```

#### Linking to Parameterized Routes

Routes with dynamic segments require a `params` prop. TypeScript enforces the correct shape.

```tsx
<Link to="/users/$userId" params={{ userId: '42' }}>
  View User
</Link>
```

For routes with multiple parameters:

```tsx
<Link
  to="/orgs/$orgId/repos/$repoId"
  params={{ orgId: 'acme', repoId: 'core' }}
>
  View Repo
</Link>
```

#### Including Search Params

The `search` prop attaches query string parameters to the destination URL. Like `params`, it is type-checked against the route's declared search schema when one is defined.

```tsx
<Link
  to="/products"
  search={{ category: 'electronics', page: 1 }}
>
  Electronics
</Link>
```

#### Hash Navigation

```tsx
<Link to="/docs/intro" hash="installation">
  Jump to Installation
</Link>
```

---

### Active Link Styling

`<Link>` applies CSS classes and inline styles when the destination matches the current URL. This is the standard mechanism for highlighting active nav items.

#### Default Active Behavior

By default, TanStack Router marks a link as active when the current URL **starts with** the link's `to` path. This means a link to `/dashboard` is active on both `/dashboard` and `/dashboard/settings`.

```tsx
<Link
  to="/dashboard"
  className="nav-link"
  activeClassName="nav-link--active"
>
  Dashboard
</Link>
```

#### Exact Matching

To mark a link active only on an exact URL match, use `activeOptions={{ exact: true }}`. This is important for index route links.

```tsx
<Link
  to="/dashboard"
  activeOptions={{ exact: true }}
  activeClassName="nav-link--active"
>
  Dashboard Home
</Link>
```

#### `activeProps` and `inactiveProps`

Instead of separate class name props, you can supply full prop objects that are merged onto the `<a>` element when active or inactive.

```tsx
<Link
  to="/dashboard"
  activeProps={{ className: 'active', 'aria-current': 'page' }}
  inactiveProps={{ className: 'inactive' }}
>
  Dashboard
</Link>
```

#### Matching Search Params in Active State

By default, active detection ignores search params. To include them:

```tsx
<Link
  to="/products"
  search={{ category: 'electronics' }}
  activeOptions={{ exact: true, includeSearch: true }}
  activeProps={{ className: 'active' }}
>
  Electronics
</Link>
```

**Key Points:**
- `exact: true` prevents prefix matching from activating parent links when on a child route
- `includeSearch: true` requires the current URL's search params to match the link's `search` for the active state to apply
- `activeProps` and `inactiveProps` are merged with any other props on the `<Link>`, not replacing them
- `aria-current="page"` should be applied to the active link for accessibility — `activeProps` is the idiomatic way to do this

---

### Pending State

`<Link>` exposes a pending state while the destination route's loader is resolving. This allows inline loading indicators without external state.

```tsx
<Link
  to="/dashboard"
  pendingProps={{ className: 'nav-link nav-link--pending' }}
>
  {({ isPending }) => (
    <>
      Dashboard
      {isPending && <Spinner />}
    </>
  )}
</Link>
```

Alternatively, `pendingClassName` and `pendingProps` are applied during the pending window:

```tsx
<Link
  to="/dashboard"
  pendingClassName="loading"
  pendingProps={{ 'aria-busy': 'true' }}
>
  Dashboard
</Link>
```

> [Inference] The render prop form (`{({ isPending }) => ...}`) and the `pendingProps`/`pendingClassName` props may not both be available in all versions. Confirm which API your version supports.

---

### Relative Links

By default, `to` is an absolute path from the root. For relative navigation within the current route's subtree, use `from` to establish the base.

```tsx
// Current route: /dashboard/settings
<Link from="/dashboard/settings" to="..">
  Back to Dashboard
</Link>

// Navigate to a sibling
<Link from="/dashboard/settings" to="../profile">
  Profile
</Link>
```

`..` navigates up one segment relative to the `from` path. `from` is required for relative navigation to be typed correctly, since the router needs a known base to resolve relative destinations.

**Key Points:**
- Relative links use `from` to anchor the base route
- `..` goes up one route segment; `../sibling` goes up then into a sibling
- Without `from`, `to` is treated as absolute
- [Inference] Relative link behavior follows the route tree hierarchy, not the raw URL string — a `..` from a pathless layout route may behave differently than expected. Test relative links in your specific route tree.

---

### `useNavigate`

`useNavigate` returns a `navigate` function for imperative navigation — useful in event handlers, form submissions, and effects.

```tsx
import { useNavigate } from '@tanstack/react-router'

function LoginForm() {
  const navigate = useNavigate()

  const handleSubmit = async (credentials) => {
    await login(credentials)
    navigate({ to: '/dashboard' })
  }

  return <form onSubmit={handleSubmit}>...</form>
}
```

#### With Params and Search

```tsx
navigate({
  to: '/users/$userId',
  params: { userId: '42' },
  search: { tab: 'activity' },
})
```

#### Replacing History

By default, navigation pushes a new entry onto the browser history stack. To replace the current entry instead (so the back button does not return to the previous page):

```tsx
navigate({ to: '/dashboard', replace: true })
```

#### Relative Navigation

```tsx
const navigate = useNavigate({ from: '/dashboard/settings' })

// Later:
navigate({ to: '..', replace: false })
```

Passing `from` to `useNavigate` establishes a default base for all calls from that hook instance.

---

### `redirect` in Loaders and `beforeLoad`

`redirect` is thrown (not returned) inside `loader` and `beforeLoad` to redirect before the route renders. It is the standard pattern for auth guards and conditional routing.

```tsx
import { createFileRoute, redirect } from '@tanstack/react-router'

export const Route = createFileRoute('/dashboard')({
  beforeLoad: ({ context }) => {
    if (!context.auth.isAuthenticated()) {
      throw redirect({ to: '/login', search: { returnTo: '/dashboard' } })
    }
  },
  component: DashboardPage,
})
```

#### Redirect Options

```tsx
throw redirect({
  to: '/login',
  params: {},
  search: { returnTo: '/protected' },
  replace: true,     // replace history entry instead of push
  reloadDocument: false,
})
```

**Key Points:**
- `redirect` must be `throw`n, not returned — returning it has no effect
- It can be thrown from both `beforeLoad` and `loader`
- `replace: true` prevents the login page from appearing in the back-navigation history, which is almost always the correct behavior for auth redirects
- The destination is fully type-checked: `to`, `params`, and `search` are validated against the route tree

---

### `useRouterState` and Current Location

To read the current location without navigating, use `useRouterState`.

```tsx
import { useRouterState } from '@tanstack/react-router'

function Breadcrumb() {
  const { location } = useRouterState()

  return <p>Current path: {location.pathname}</p>
}
```

For reading just the current route's matched params or search, prefer `Route.useParams()` and `Route.useSearch()` within route components.

---

### `useMatchRoute`

`useMatchRoute` returns a function that tests whether a given destination matches the current URL, without rendering anything. This is useful for building custom active indicators outside of `<Link>`.

```tsx
import { useMatchRoute } from '@tanstack/react-router'

function CustomNavItem({ to, label }) {
  const matchRoute = useMatchRoute()
  const isActive = matchRoute({ to, fuzzy: true })

  return (
    <div className={isActive ? 'active' : ''}>
      <Link to={to}>{label}</Link>
    </div>
  )
}
```

**Key Points:**
- `fuzzy: true` applies prefix matching (same as the default `<Link>` active behavior)
- `fuzzy: false` (default) requires an exact match
- Returns the matched params object if the route matches, or `false` if it does not — the truthiness of the return value indicates whether the route is active

---

### Navigation Options Reference

The following options are shared across `<Link>`, `navigate()`, and `redirect()`:

| Option | Type | Purpose |
|---|---|---|
| `to` | string (route path) | Destination route path |
| `params` | object | Dynamic segment values |
| `search` | object or function | Query string params |
| `hash` | string | URL hash fragment |
| `replace` | boolean | Replace vs push history |
| `from` | string | Base route for relative navigation |
| `reloadDocument` | boolean | Force a full page reload |
| `state` | object | History state (not in URL) |

**`search` as a function:**

When you want to preserve existing search params and only update some of them, pass a function to `search`:

```tsx
<Link
  to="."
  search={(prev) => ({ ...prev, page: prev.page + 1 })}
>
  Next Page
</Link>
```

This reads the current search params and merges changes, preventing unintentional loss of other params.

---

### Visual: Navigation API Decision Map

<svg viewBox="0 0 660 430" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="12">
  <rect width="660" height="430" fill="#0f1117" rx="12"/>

  <!-- Title -->
  <text x="30" y="30" fill="#718096" font-size="11">WHICH NAVIGATION API TO USE?</text>
  <line x1="20" y1="38" x2="640" y2="38" stroke="#2d3148" stroke-width="1"/>

  <!-- Start node -->
  <rect x="250" y="52" width="160" height="36" rx="6" fill="#1e2230" stroke="#4f6ef7" stroke-width="1.5"/>
  <text x="330" y="75" text-anchor="middle" fill="#e2e8f0">Navigation needed</text>

  <!-- Decision 1: JSX or imperative -->
  <line x1="330" y1="88" x2="330" y2="118" stroke="#4f6ef7" stroke-width="1" stroke-dasharray="4 2"/>
  <rect x="200" y="118" width="260" height="36" rx="6" fill="#1e2230" stroke="#718096" stroke-width="1"/>
  <text x="330" y="141" text-anchor="middle" fill="#a0aec0">Rendering in JSX?</text>

  <!-- Yes branch (left) -->
  <line x1="200" y1="136" x2="120" y2="136" stroke="#68d391" stroke-width="1"/>
  <text x="155" y="130" text-anchor="middle" fill="#68d391" font-size="10">yes</text>
  <line x1="120" y1="136" x2="120" y2="186" stroke="#68d391" stroke-width="1"/>

  <!-- No branch (right) -->
  <line x1="460" y1="136" x2="540" y2="136" stroke="#fc8181" stroke-width="1"/>
  <text x="500" y="130" text-anchor="middle" fill="#fc8181" font-size="10">no</text>
  <line x1="540" y1="136" x2="540" y2="186" stroke="#fc8181" stroke-width="1"/>

  <!-- Link box -->
  <rect x="40" y="186" width="160" height="36" rx="6" fill="#1a2040" stroke="#68d391" stroke-width="1.5"/>
  <text x="120" y="205" text-anchor="middle" fill="#68d391" font-size="11">&lt;Link&gt;</text>
  <text x="120" y="218" text-anchor="middle" fill="#718096" font-size="10">anchor, active state</text>

  <!-- Imperative decision -->
  <rect x="430" y="186" width="220" height="36" rx="6" fill="#1e2230" stroke="#718096" stroke-width="1"/>
  <text x="540" y="209" text-anchor="middle" fill="#a0aec0">Inside loader / beforeLoad?</text>

  <!-- Yes: redirect -->
  <line x1="540" y1="222" x2="540" y2="262" stroke="#68d391" stroke-width="1"/>
  <text x="553" y="248" fill="#68d391" font-size="10">yes</text>
  <rect x="430" y="262" width="220" height="36" rx="6" fill="#1a2040" stroke="#f6ad55" stroke-width="1.5"/>
  <text x="540" y="281" text-anchor="middle" fill="#f6ad55" font-size="11">throw redirect()</text>
  <text x="540" y="294" text-anchor="middle" fill="#718096" font-size="10">guards, auth, conditional</text>

  <!-- No: useNavigate -->
  <line x1="430" y1="204" x2="330" y2="204" stroke="#fc8181" stroke-width="1"/>
  <text x="375" y="198" text-anchor="middle" fill="#fc8181" font-size="10">no</text>
  <line x1="330" y1="204" x2="330" y2="262" stroke="#fc8181" stroke-width="1"/>
  <rect x="210" y="262" width="240" height="36" rx="6" fill="#1a2040" stroke="#b794f4" stroke-width="1.5"/>
  <text x="330" y="281" text-anchor="middle" fill="#b794f4" font-size="11">useNavigate()</text>
  <text x="330" y="294" text-anchor="middle" fill="#718096" font-size="10">handlers, effects, forms</text>

  <!-- Link sub-decisions -->
  <line x1="120" y1="222" x2="120" y2="310" stroke="#68d391" stroke-width="1" stroke-dasharray="3 2"/>

  <rect x="30" y="310" width="190" height="30" rx="5" fill="#1e2230" stroke="#2d3148" stroke-width="1"/>
  <text x="125" y="330" text-anchor="middle" fill="#a0aec0" font-size="11">Need active/pending state?</text>
  <text x="45" y="358" fill="#68d391" font-size="10">yes → activeProps / activeClassName</text>
  <text x="45" y="374" fill="#fc8181" font-size="10">no  → plain &lt;a&gt; or &lt;Link&gt; without activeProps</text>

  <!-- Read-only note -->
  <rect x="20" y="395" width="620" height="26" rx="6" fill="#1a1d2e" stroke="#2d3148" stroke-width="1"/>
  <text x="330" y="412" text-anchor="middle" fill="#718096" font-size="11">Read current location without navigating → useRouterState() · useMatchRoute() · Route.useParams() · Route.useSearch()</text>
</svg>

---

### Type Safety and Generated Routes

All navigation APIs are typed against the route tree when `routeTree.gen.ts` is present and registered. This means:

```ts
// router.ts
import { routeTree } from './routeTree.gen'
import { createRouter } from '@tanstack/react-router'

const router = createRouter({ routeTree })

declare module '@tanstack/react-router' {
  interface Register {
    router: typeof router
  }
}
```

Once registered, every `to` prop, `params` object, and `search` object is validated against the actual route tree at compile time. Navigating to a nonexistent route, omitting a required param, or passing a search param that does not match the route's schema are all TypeScript errors.

**Key Points:**
- The `Register` interface declaration is what activates global type safety — without it, the router functions but loses type checking across navigation APIs
- `routeTree.gen.ts` is regenerated whenever routes change during development via the Vite plugin or `tsr watch`
- Type errors in navigation props do not prevent runtime execution — they are compile-time only warnings unless your build pipeline enforces type checking

---

### Common Mistakes

**Using `<a href>` instead of `<Link>`**
A plain `<a>` tag triggers a full page reload, bypassing the router entirely. Always use `<Link>` for in-app navigation.

**Forgetting `params` on a parameterized `to`**
Omitting `params` when `to` contains a dynamic segment throws a runtime error. TypeScript will catch this at compile time if types are generated.

**Not using `replace: true` in auth redirects**
Redirecting to login without `replace: true` adds the protected route to the history stack. Users pressing back are returned to the protected route, triggering the redirect again. Use `replace: true` in `redirect()` for auth flows.

**Using `exact: false` (default) on index links**
A link to `/dashboard` without `exact: true` appears active on all `/dashboard/*` URLs. Index route links almost always need `exact: true`.

**Mutating search params with a static object**
Passing `search={{ page: 2 }}` replaces all search params with only `page`. Use the function form — `search={(prev) => ({ ...prev, page: 2 })}` — to merge changes into existing params.

**Throwing `redirect` outside a loader or `beforeLoad`**
`redirect` is only meaningful when thrown inside `loader` or `beforeLoad`. Throwing it in a component or event handler does not produce the expected navigation behavior.

---

**Related Topics:**
- Search params schemas and validation with Zod (`validateSearch`)
- Route context and passing auth state into `beforeLoad`
- Preloading routes on hover with `<Link preload="intent">`
- `viewTransition` option on `<Link>` for animated page transitions
- Scroll restoration behavior on navigation
- `useMatch` and `useMatches` for inspecting the matched route stack
- `RouterProvider` and `createRouter` setup
- History modes: browser history, hash history, memory history