## Nested Routes and Layouts in TanStack Router

---

### What Are Nested Routes?

Nested routes allow you to define a hierarchy of routes where child routes render *inside* their parent routes. This mirrors the natural nesting of UI — a dashboard shell wrapping a settings panel, for example. TanStack Router supports nested routes as a first-class concept, meaning the router itself manages which components render at which level of the tree.

In TanStack Router, routes are composed into a **route tree**. Each node in that tree corresponds to a URL segment, and child nodes correspond to deeper URL segments beneath the parent.

**Key Points:**

- A parent route renders its component, which includes an `<Outlet />` — a placeholder where child route components are injected
- The full URL is assembled by concatenating the path segments of all ancestors and the matched child
- Multiple levels of nesting are supported

---

### Defining a Route Tree

TanStack Router supports two primary authoring modes: **file-based routing** (recommended) and **code-based routing**. Both produce the same route tree structure.

#### File-Based Route Tree

With the Vite plugin or CLI tooling, file names map directly to route segments. A typical file structure:

```
src/routes/
  __root.tsx
  dashboard.tsx
  dashboard/
    index.tsx
    settings.tsx
    profile.tsx
```

This produces the following URL structure:

```
/                        → __root.tsx
/dashboard               → dashboard.tsx  (layout)
/dashboard/              → dashboard/index.tsx
/dashboard/settings      → dashboard/settings.tsx
/dashboard/profile       → dashboard/profile.tsx
```

The file `dashboard.tsx` acts as a **layout route** for everything under `/dashboard`. It renders shared UI and an `<Outlet />` where children appear.

#### Code-Based Route Tree

ts

```ts
import {
  createRootRoute,
  createRoute,
  createRouter,
} from '@tanstack/react-router'

const rootRoute = createRootRoute({
  component: RootComponent,
})

const dashboardRoute = createRoute({
  getParentRoute: () => rootRoute,
  path: 'dashboard',
  component: DashboardLayout,
})

const settingsRoute = createRoute({
  getParentRoute: () => dashboardRoute,
  path: 'settings',
  component: SettingsPage,
})

const routeTree = rootRoute.addChildren([
  dashboardRoute.addChildren([settingsRoute]),
])

const router = createRouter({ routeTree })
```

**Key Points:**

- `getParentRoute` is required in code-based mode to establish the hierarchy
- `addChildren` assembles the tree explicitly
- The router derives the full path by walking up the parent chain

---

### The `<Outlet />` Component

`<Outlet />` is the mechanism by which a parent route renders its matched child. Without it, child routes have no place to appear in the DOM.

tsx

```tsx
// DashboardLayout.tsx
import { Outlet } from '@tanstack/react-router'

function DashboardLayout() {
  return (
    <div className="dashboard-shell">
      <nav>
        <a href="/dashboard/settings">Settings</a>
        <a href="/dashboard/profile">Profile</a>
      </nav>

      <main>
        <Outlet />  {/* child route renders here */}
      </main>
    </div>
  )
}
```

**Key Points:**

- Each layout component should render exactly one `<Outlet />` for its direct children
- Deeply nested layouts each render their own `<Outlet />`, chaining downward
- If a parent has no `<Outlet />`, matched children will not render — this is a common source of bugs

---

### The Root Route

Every TanStack Router app has a single **root route** created with `createRootRoute`. It is the ancestor of all other routes and typically renders global UI: navigation bars, theme providers, toast containers, and the top-level `<Outlet />`.

tsx

```tsx
// __root.tsx (file-based) or root route (code-based)
import { createRootRoute, Outlet } from '@tanstack/react-router'

export const Route = createRootRoute({
  component: () => (
    <div>
      <GlobalNav />
      <Outlet />
    </div>
  ),
})
```

The root route's path is implicitly `/`. It always matches, regardless of the current URL.

---

### Layout Routes (Pathless Parents)

A **layout route** provides shared UI and data loading for a group of child routes *without contributing a path segment to the URL*. In file-based routing, this is done using the `_` prefix convention.

```
src/routes/
  __root.tsx
  _authed.tsx            ← layout route, no path segment
  _authed/
    dashboard.tsx        → /dashboard
    profile.tsx          → /profile
```

The file `_authed.tsx` can enforce authentication and render shared chrome, but the URLs for its children remain `/dashboard` and `/profile` — not `/_authed/dashboard`.

**In code-based routing**, omit the `path` property (or set `id` instead) to create a pathless layout route:

ts

```ts
const authedLayout = createRoute({
  getParentRoute: () => rootRoute,
  id: 'authed',           // id instead of path = pathless/layout route
  component: AuthedLayout,
})

const dashboardRoute = createRoute({
  getParentRoute: () => authedLayout,
  path: 'dashboard',
  component: DashboardPage,
})
```

**Key Points:**

- Layout routes are useful for grouping routes that share loaders, context, or UI without altering the URL
- The `id` field distinguishes a pathless layout route from a standard route in code-based mode
- [Inference] This pattern is commonly used for auth guards, though the enforcement logic itself is up to the developer — TanStack Router does not enforce auth automatically

---

### How Nesting Renders: The Component Stack

When a user navigates to `/dashboard/settings`, TanStack Router matches the full route chain and renders components from outermost to innermost:

```
RootComponent
  └── DashboardLayout        (renders <Outlet />)
        └── SettingsPage
```

Each level renders independently. TanStack Router re-renders only the components affected by a navigation change — parent layouts remain mounted if the parent route is still matched.

> [Inference] This behavior resembles React's reconciliation model, but specific re-render behavior depends on the router version, component structure, and React's own diffing. Behavior may vary.

---

### Index Routes

An **index route** matches the parent's exact path with no additional segment. It is the default child when no deeper segment is specified.

In file-based routing:

```
dashboard/
  index.tsx     → matches /dashboard exactly
  settings.tsx  → matches /dashboard/settings
```

In code-based routing:

ts

```ts
const dashboardIndexRoute = createRoute({
  getParentRoute: () => dashboardRoute,
  path: '/',       // or use index: true in some versions
  component: DashboardHome,
})
```

**Key Points:**

- Index routes prevent a blank `<Outlet />` when a user lands on the parent path
- They are siblings of other child routes, not parents

---

### Nested Loaders

Each route in the nested tree can define its own `loader`. TanStack Router runs loaders in parallel where possible, and each loader's data is scoped to its own route.

ts

```ts
const dashboardRoute = createRoute({
  getParentRoute: () => rootRoute,
  path: 'dashboard',
  loader: () => fetchDashboardMeta(),
  component: DashboardLayout,
})

const settingsRoute = createRoute({
  getParentRoute: () => dashboardRoute,
  path: 'settings',
  loader: () => fetchUserSettings(),
  component: SettingsPage,
})
```

Within `SettingsPage`, you access only the settings loader's data. Within `DashboardLayout`, you access the dashboard loader's data. Each route owns its loader result.

ts

```ts
// Inside SettingsPage
const { data } = settingsRoute.useLoaderData()

// Inside DashboardLayout
const { data } = dashboardRoute.useLoaderData()
```

> Behavior of parallel vs. sequential loader execution may depend on data dependencies and router configuration. Verify against the version you are using.

---

### Nested Search Params and Context

Each route can declare its own search params schema and contribute to a shared **route context**. Context flows *downward* through the tree — a parent can inject context that all children can read.

ts

```ts
const rootRoute = createRootRoute({
  context(): AppContext {
    return { queryClient, authService }
  },
})

const dashboardRoute = createRoute({
  getParentRoute: () => rootRoute,
  path: 'dashboard',
  beforeLoad: ({ context }) => {
    // context.authService is available here
    if (!context.authService.isAuthenticated()) {
      throw redirect({ to: '/login' })
    }
  },
})
```

**Key Points:**

- Context is typed end-to-end when using TypeScript — child routes see a merged context type
- Context does not flow upward; parents cannot access context injected by children

---

### Visual: Nested Route Tree Structure

<svg viewBox="0 0 640 400" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="13">
<!-- Background -->
<rect width="640" height="400" fill="#0f1117" rx="12"/>
<!-- Root -->
<rect x="240" y="20" width="160" height="40" rx="6" fill="#1e2230" stroke="#4f6ef7" stroke-width="1.5"/>
<text x="320" y="45" text-anchor="middle" fill="#a0aec0" font-size="12">__root.tsx</text>
<text x="320" y="32" text-anchor="middle" fill="#4f6ef7" font-size="10">ROOT /</text>
<!-- Line root → _authed -->
<line x1="320" y1="60" x2="180" y2="100" stroke="#4f6ef7" stroke-width="1" stroke-dasharray="4 2"/>
<!-- Line root → dashboard -->
<line x1="320" y1="60" x2="460" y2="100" stroke="#4f6ef7" stroke-width="1" stroke-dasharray="4 2"/>
<!-- _authed layout (pathless) -->
<rect x="80" y="100" width="200" height="40" rx="6" fill="#1e2230" stroke="#f6ad55" stroke-width="1.5"/>
<text x="180" y="125" text-anchor="middle" fill="#a0aec0" font-size="12">_authed.tsx</text>
<text x="180" y="113" text-anchor="middle" fill="#f6ad55" font-size="10">LAYOUT (no path segment)</text>
<!-- dashboard route -->
<rect x="360" y="100" width="200" height="40" rx="6" fill="#1e2230" stroke="#4f6ef7" stroke-width="1.5"/>
<text x="460" y="125" text-anchor="middle" fill="#a0aec0" font-size="12">dashboard.tsx</text>
<text x="460" y="113" text-anchor="middle" fill="#4f6ef7" font-size="10">ROUTE /dashboard</text>
<!-- Lines _authed → children -->
<line x1="180" y1="140" x2="120" y2="200" stroke="#f6ad55" stroke-width="1" stroke-dasharray="4 2"/>
<line x1="180" y1="140" x2="240" y2="200" stroke="#f6ad55" stroke-width="1" stroke-dasharray="4 2"/>
<!-- _authed/profile -->
<rect x="40" y="200" width="160" height="40" rx="6" fill="#1e2230" stroke="#68d391" stroke-width="1.5"/>
<text x="120" y="225" text-anchor="middle" fill="#a0aec0" font-size="12">profile.tsx</text>
<text x="120" y="213" text-anchor="middle" fill="#68d391" font-size="10">ROUTE /profile</text>
<!-- _authed/settings -->
<rect x="210" y="200" width="160" height="40" rx="6" fill="#1e2230" stroke="#68d391" stroke-width="1.5"/>
<text x="290" y="225" text-anchor="middle" fill="#a0aec0" font-size="12">settings.tsx</text>
<text x="290" y="213" text-anchor="middle" fill="#68d391" font-size="10">ROUTE /settings</text>
<!-- Lines dashboard → children -->
<line x1="460" y1="140" x2="420" y2="200" stroke="#4f6ef7" stroke-width="1" stroke-dasharray="4 2"/>
<line x1="460" y1="140" x2="520" y2="200" stroke="#4f6ef7" stroke-width="1" stroke-dasharray="4 2"/>
<!-- dashboard/index -->
<rect x="340" y="200" width="160" height="40" rx="6" fill="#1e2230" stroke="#b794f4" stroke-width="1.5"/>
<text x="420" y="225" text-anchor="middle" fill="#a0aec0" font-size="12">dashboard/index.tsx</text>
<text x="420" y="213" text-anchor="middle" fill="#b794f4" font-size="10">INDEX /dashboard</text>
<!-- dashboard/settings -->
<rect x="510" y="200" width="110" height="40" rx="6" fill="#1e2230" stroke="#68d391" stroke-width="1.5"/>
<text x="565" y="225" text-anchor="middle" fill="#a0aec0" font-size="12">settings.tsx</text>
<text x="565" y="213" text-anchor="middle" fill="#68d391" font-size="10">/dashboard/settings</text>
<!-- Legend -->
<rect x="20" y="310" width="600" height="72" rx="6" fill="#1a1d2e" stroke="#2d3148" stroke-width="1"/>
<text x="40" y="330" fill="#718096" font-size="11">LEGEND</text>
<rect x="40" y="340" width="12" height="12" rx="2" fill="#4f6ef7"/>
<text x="58" y="351" fill="#a0aec0" font-size="11">Standard route (path segment)</text>
<rect x="220" y="340" width="12" height="12" rx="2" fill="#f6ad55"/>
<text x="238" y="351" fill="#a0aec0" font-size="11">Layout / pathless route</text>
<rect x="400" y="340" width="12" height="12" rx="2" fill="#b794f4"/>
<text x="418" y="351" fill="#a0aec0" font-size="11">Index route</text>
<rect x="40" y="364" width="12" height="12" rx="2" fill="#68d391"/>
<text x="58" y="375" fill="#a0aec0" font-size="11">Leaf route (renders final page content)</text>
</svg>

---

### Common Mistakes

**Missing `<Outlet />`**
The most frequent issue. If a parent route's component does not render `<Outlet />`, child routes will match in the router but produce no visible output.

**Incorrect `getParentRoute`**
In code-based routing, pointing a route at the wrong parent silently misplaces it in the tree, producing incorrect URL construction and rendering.

**Confusing path routes with layout routes**
A file named `dashboard.tsx` (with a path) and a file named `_dashboard.tsx` (pathless) behave differently. Mixing them unintentionally causes URL construction errors.

**Index route not defined**
Navigating to a parent path with no index route renders only the parent layout with an empty `<Outlet />`. Always define an index route if a parent path should show content.

---

**Related Topics:**

- Dynamic route segments (`:param` syntax and `useParams`)
- Search params schemas and validation with Zod
- Route loaders and the data loading lifecycle
- `beforeLoad` and `loader` for authentication guards
- `<Link>` component and active link styling in nested trees
- Error boundaries and `errorComponent` per route
- Pending UI and `pendingComponent` in nested loaders
- Route context and dependency injection patterns
- Scroll restoration in nested layouts
- TanStack Router Devtools for inspecting the route tree