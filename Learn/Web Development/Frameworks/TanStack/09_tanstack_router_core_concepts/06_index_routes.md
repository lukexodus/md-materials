## Index Routes in TanStack Router

---

### What Is an Index Route?

An index route is a special child route that matches its parent's path **exactly**, with no additional URL segment. It serves as the default content rendered inside a parent layout's `<Outlet />` when no deeper child segment is present in the URL.

**Key Points:**

- An index route matches `/dashboard` when the parent route is `/dashboard` — it does not match `/dashboard/anything`
- It is a sibling of other child routes, not a parent of them
- Without an index route, navigating to a parent path renders the parent layout with an empty `<Outlet />`
- Index routes participate fully in the route lifecycle: they can define loaders, search params, context, and components like any other route

---

### File-Based Index Routes

In file-based routing, an index route is created by naming the file `index.tsx` inside a route directory. The router automatically treats it as the default child.

```
src/routes/
  __root.tsx
  dashboard.tsx          ← layout for /dashboard
  dashboard/
    index.tsx            → matches /dashboard exactly
    settings.tsx         → matches /dashboard/settings
    profile.tsx          → matches /dashboard/profile
```

**Example — `dashboard/index.tsx`:**

tsx

```tsx
import { createFileRoute } from '@tanstack/react-router'

export const Route = createFileRoute('/dashboard/')({
  component: DashboardHome,
})

function DashboardHome() {
  return (
    <div>
      <h2>Welcome to the Dashboard</h2>
      <p>Select an item from the sidebar to get started.</p>
    </div>
  )
}
```

**Key Points:**

- The path string passed to `createFileRoute` for an index is `/dashboard/` — note the trailing slash, which signals the index position
- The file lives inside the `dashboard/` directory, not at the same level as `dashboard.tsx`
- `dashboard.tsx` (the layout) and `dashboard/index.tsx` (the index) are distinct files with distinct roles

---

### Code-Based Index Routes

In code-based routing, an index route is defined by setting `path` to `'/'` on a route whose parent already owns the base segment.

ts

```ts
import {
  createRootRoute,
  createRoute,
  createRouter,
} from '@tanstack/react-router'

const rootRoute = createRootRoute({ component: RootLayout })

const dashboardRoute = createRoute({
  getParentRoute: () => rootRoute,
  path: 'dashboard',
  component: DashboardLayout,
})

const dashboardIndexRoute = createRoute({
  getParentRoute: () => dashboardRoute,
  path: '/',               // ← index: matches /dashboard exactly
  component: DashboardHome,
})

const dashboardSettingsRoute = createRoute({
  getParentRoute: () => dashboardRoute,
  path: 'settings',
  component: SettingsPage,
})

const routeTree = rootRoute.addChildren([
  dashboardRoute.addChildren([
    dashboardIndexRoute,
    dashboardSettingsRoute,
  ]),
])

const router = createRouter({ routeTree })
```

> [Inference] Some versions of TanStack Router may also accept an `index: true` property in place of `path: '/'` for clarity. Verify against your installed version's documentation and changelog, as API surface details may vary.

---

### The Root Index Route

The root route (`__root.tsx`) can also have an index child. This index matches `/` exactly and is the default landing page of the application.

**File-based:**

```
src/routes/
  __root.tsx
  index.tsx         → matches / exactly
  about.tsx         → matches /about
```

**`index.tsx`:**

tsx

```tsx
import { createFileRoute } from '@tanstack/react-router'

export const Route = createFileRoute('/')({
  component: HomePage,
})

function HomePage() {
  return <h1>Home</h1>
}
```

**Key Points:**

- The root index is the most common index route in any application
- It renders inside the root layout's `<Outlet />`
- Without it, navigating to `/` renders only the root layout shell with no content

---

### Index Routes and Loaders

Index routes support loaders in exactly the same way as any other route. The loader runs when the index is the active match, and its data is scoped to the index route.

tsx

```tsx
export const Route = createFileRoute('/dashboard/')({
  loader: async () => {
    const summary = await fetchDashboardSummary()
    return { summary }
  },
  component: DashboardHome,
})

function DashboardHome() {
  const { summary } = Route.useLoaderData()

  return (
    <div>
      <h2>Dashboard Summary</h2>
      <p>Active users: {summary.activeUsers}</p>
      <p>Revenue: {summary.revenue}</p>
    </div>
  )
}
```

**Key Points:**

- The index loader runs independently of the parent layout's loader
- Both loaders may run in parallel when navigating directly to the index URL — actual execution order and parallelism depend on data dependencies and router internals
- The parent layout accesses its own loader data; the index accesses its own separately

---

### Navigating to an Index Route

Use TanStack Router's `<Link>` component to navigate to an index route. Because the index matches the parent path exactly, linking to the parent path is sufficient.

tsx

```tsx
import { Link } from '@tanstack/react-router'

function Sidebar() {
  return (
    <nav>
      {/* Links to the dashboard index (/dashboard) */}
      <Link to="/dashboard">Dashboard Home</Link>

      {/* Links to a named child route */}
      <Link to="/dashboard/settings">Settings</Link>
    </nav>
  )
}
```

**Active link behavior:**

`<Link>` applies an active class when its `to` matches the current URL. Because `/dashboard` is also a prefix of `/dashboard/settings`, you may need `exact` matching to avoid the dashboard home link appearing active on child pages.

tsx

```tsx
<Link to="/dashboard" activeOptions={{ exact: true }}>
  Dashboard Home
</Link>
```

> [Inference] The exact behavior of `activeOptions` and its interaction with index routes may depend on router version. Test in your environment to confirm behavior.

---

### Index Routes vs. Layout Routes: Key Distinction

These two concepts are often confused. The table below clarifies the difference:

| Concept | Has URL segment? | Renders in `<Outlet />`? | Can have loader? | Purpose |
| --- | --- | --- | --- | --- |
| Layout route | No (pathless) | Inside its own parent's outlet | Yes | Shared UI/data wrapper |
| Index route | No new segment | Inside parent layout's outlet | Yes | Default content at parent path |
| Regular child route | Yes | Inside parent layout's outlet | Yes | Content at a deeper path |

**Example:**

```
/dashboard          → DashboardLayout renders; DashboardIndex renders inside its <Outlet />
/dashboard/settings → DashboardLayout renders; SettingsPage renders inside its <Outlet />
```

When the user is at `/dashboard`, the index is active. When they move to `/dashboard/settings`, the index unmounts and `SettingsPage` mounts — but `DashboardLayout` stays mounted throughout, because its route remains matched.

---

### Visual: Index Route Matching

<svg viewBox="0 0 640 370" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="12">
<rect width="640" height="370" fill="#0f1117" rx="12"/>
<!-- Column headers -->

<text x="60" y="30" fill="`#718096`" font-size="11">URL</text>
<text x="260" y="30" fill="`#718096`" font-size="11">MATCHED ROUTES (outermost → innermost)</text>

<!-- Divider -->
<line x1="20" y1="38" x2="620" y2="38" stroke="#2d3148" stroke-width="1"/>
<!-- Row 1: / -->
<rect x="20" y="50" width="160" height="36" rx="5" fill="#1e2230" stroke="#4f6ef7" stroke-width="1"/>
<text x="100" y="73" text-anchor="middle" fill="#e2e8f0">/</text>

<text x="210" y="73" fill="`#718096`">→</text>
<rect x="230" y="50" width="100" height="36" rx="5" fill="`#1a2040`" stroke="`#4f6ef7`" stroke-width="1"/>
<text x="280" y="69" text-anchor="middle" fill="`#4f6ef7`" font-size="10">__root</text>
<text x="280" y="80" text-anchor="middle" fill="`#a0aec0`" font-size="10">RootLayout</text>

<text x="338" y="73" fill="`#718096`">+</text>

<rect x="355" y="50" width="120" height="36" rx="5" fill="#1a2040" stroke="#b794f4" stroke-width="1"/>
<text x="415" y="69" text-anchor="middle" fill="#b794f4" font-size="10">index /</text>
<text x="415" y="80" text-anchor="middle" fill="#a0aec0" font-size="10">HomePage</text>
<!-- Row 2: /dashboard -->
<rect x="20" y="106" width="160" height="36" rx="5" fill="#1e2230" stroke="#4f6ef7" stroke-width="1"/>
<text x="100" y="129" text-anchor="middle" fill="#e2e8f0">/dashboard</text>

<text x="210" y="129" fill="`#718096`">→</text>
<rect x="230" y="106" width="100" height="36" rx="5" fill="`#1a2040`" stroke="`#4f6ef7`" stroke-width="1"/>
<text x="280" y="125" text-anchor="middle" fill="`#4f6ef7`" font-size="10">__root</text>
<text x="280" y="136" text-anchor="middle" fill="`#a0aec0`" font-size="10">RootLayout</text>

<text x="338" y="129" fill="`#718096`">+</text>

<rect x="355" y="106" width="120" height="36" rx="5" fill="#1a2040" stroke="#4f6ef7" stroke-width="1"/>
<text x="415" y="125" text-anchor="middle" fill="#4f6ef7" font-size="10">dashboard</text>
<text x="415" y="136" text-anchor="middle" fill="#a0aec0" font-size="10">DashboardLayout</text>

<text x="482" y="129" fill="`#718096`">+</text>

<rect x="498" y="106" width="120" height="36" rx="5" fill="#1a2040" stroke="#b794f4" stroke-width="1"/>
<text x="558" y="125" text-anchor="middle" fill="#b794f4" font-size="10">index /</text>
<text x="558" y="136" text-anchor="middle" fill="#a0aec0" font-size="10">DashboardHome</text>
<!-- Row 3: /dashboard/settings -->
<rect x="20" y="162" width="160" height="36" rx="5" fill="#1e2230" stroke="#4f6ef7" stroke-width="1"/>
<text x="100" y="185" text-anchor="middle" fill="#e2e8f0">/dashboard/settings</text>

<text x="210" y="185" fill="`#718096`">→</text>
<rect x="230" y="162" width="100" height="36" rx="5" fill="`#1a2040`" stroke="`#4f6ef7`" stroke-width="1"/>
<text x="280" y="181" text-anchor="middle" fill="`#4f6ef7`" font-size="10">__root</text>
<text x="280" y="192" text-anchor="middle" fill="`#a0aec0`" font-size="10">RootLayout</text>

<text x="338" y="185" fill="`#718096`">+</text>

<rect x="355" y="162" width="120" height="36" rx="5" fill="#1a2040" stroke="#4f6ef7" stroke-width="1"/>
<text x="415" y="181" text-anchor="middle" fill="#4f6ef7" font-size="10">dashboard</text>
<text x="415" y="192" text-anchor="middle" fill="#a0aec0" font-size="10">DashboardLayout</text>

<text x="482" y="185" fill="`#718096`">+</text>

<rect x="498" y="162" width="120" height="36" rx="5" fill="#1a2040" stroke="#68d391" stroke-width="1"/>
<text x="558" y="181" text-anchor="middle" fill="#68d391" font-size="10">settings</text>
<text x="558" y="192" text-anchor="middle" fill="#a0aec0" font-size="10">SettingsPage</text>
<!-- Divider -->
<line x1="20" y1="215" x2="620" y2="215" stroke="#2d3148" stroke-width="1"/>
<!-- Observation note -->

<text x="30" y="238" fill="`#718096`" font-size="11">OBSERVATION</text>
<text x="30" y="258" fill="`#a0aec0`" font-size="11">At /dashboard: DashboardIndex is active. SettingsPage is NOT mounted.</text>
<text x="30" y="276" fill="`#a0aec0`" font-size="11">At /dashboard/settings: DashboardIndex is NOT mounted. SettingsPage is active.</text>
<text x="30" y="294" fill="`#a0aec0`" font-size="11">In both cases: RootLayout and DashboardLayout remain mounted.</text>

<!-- Legend -->
<rect x="20" y="316" width="600" height="40" rx="6" fill="#1a1d2e" stroke="#2d3148" stroke-width="1"/>
<rect x="40" y="330" width="10" height="10" rx="2" fill="#b794f4"/>
<text x="56" y="340" fill="#a0aec0" font-size="11">Index route</text>
<rect x="180" y="330" width="10" height="10" rx="2" fill="#4f6ef7"/>
<text x="196" y="340" fill="#a0aec0" font-size="11">Layout / standard route</text>
<rect x="380" y="330" width="10" height="10" rx="2" fill="#68d391"/>
<text x="396" y="340" fill="#a0aec0" font-size="11">Leaf route (non-index)</text>
</svg>

---

### Common Mistakes

**Placing `index.tsx` at the wrong level**
`dashboard/index.tsx` (inside the directory) is the index for `/dashboard`. A file at `dashboard.tsx` alongside a `dashboard/` directory is the *layout*, not the index. These are different files.

**Linking to an index without `exact` active matching**
A `<Link to="/dashboard">` will appear active on both `/dashboard` and `/dashboard/settings` unless `activeOptions={{ exact: true }}` is set, because `/dashboard` is a prefix of the longer path.

**Expecting the parent layout to handle index content**
The parent layout's `component` renders the chrome (nav, sidebar, shell). The index route's `component` renders the default inner content. Mixing these into one file defeats the purpose of having an index.

**No index route at the root**
Omitting `index.tsx` at the root means navigating to `/` renders only the root layout with a blank `<Outlet />`. Always define a root index unless the root path intentionally redirects elsewhere.

---

**Related Topics:**

- Redirecting from a parent path to an index using `redirect` in `beforeLoad`
- `<Link>` active state and `activeOptions` configuration
- Nested loaders and parallel data fetching
- Layout routes (pathless routes with `id`)
- `notFoundComponent` for unmatched routes
- Route guards and `beforeLoad` in index routes
- Search params on index routes