## Layout Routes and Pathless Routes

TanStack Router supports routes that contribute to the component tree without contributing a segment to the URL. These are layout routes and pathless routes — structurally distinct from leaf routes but essential for organizing shared UI, shared loaders, and shared guards across groups of routes.

---

### What Layout Routes Are

A layout route wraps a group of child routes with shared UI. It renders an `<Outlet />` where its children appear. The parent layout remains mounted as the user navigates between children — only the outlet region re-renders.

Every route with children is technically a layout route in this sense. The distinction becomes meaningful when a route contributes UI but no URL segment.

---

### Pathless Layout Routes

A pathless layout route is a route whose path does not add a segment to the URL. Its children inherit the URL structure as if the layout did not exist, but they receive the layout's component wrapping, `beforeLoad` context extension, and loader data.

In file-based routing, a pathless layout is created with a leading underscore:

```
routes/
  __root.tsx
  _app.tsx              ← pathless layout
  _app/
    dashboard.tsx       → URL: /dashboard
    settings.tsx        → URL: /settings
  login.tsx             → URL: /login
```

`_app.tsx` wraps `dashboard` and `settings` but contributes no URL segment. `/dashboard` and `/settings` are full URLs — `_app` is invisible in the address bar.

---

### Defining a Pathless Layout Route

ts

```ts
// routes/_app.tsx
import { createFileRoute, Outlet } from '@tanstack/react-router'

export const Route = createFileRoute('/_app')({
  component: AppLayout,
})

function AppLayout() {
  return (
    <div className="app-shell">
      <Sidebar />
      <main>
        <Outlet />
      </main>
    </div>
  )
}
```

Child routes render into the `<Outlet />`. The sidebar and shell are shared across all children without repeating them in every route component.

---

### Defining a Named Layout Route (with URL segment)

A layout route can also carry a URL segment. This is a standard nested route where the parent contributes both a path segment and shared UI:

```
routes/
  dashboard.tsx         → URL: /dashboard  (layout)
  dashboard/
    overview.tsx        → URL: /dashboard/overview
    reports.tsx         → URL: /dashboard/reports
```

ts

```ts
// routes/dashboard.tsx
export const Route = createFileRoute('/dashboard')({
  component: DashboardLayout,
})

function DashboardLayout() {
  return (
    <section>
      <DashboardNav />
      <Outlet />
    </section>
  )
}
```

**Key Points:**

- `/dashboard` itself renders `DashboardLayout` with an empty outlet if visited directly
- `/dashboard/overview` renders `DashboardLayout` with `OverviewComponent` in the outlet
- The layout stays mounted as the user navigates between `/dashboard/overview` and `/dashboard/reports`

---

### `<Outlet />` — Required in Layout Components

Any route component that has children must render `<Outlet />`. Without it, child route components are never mounted:

tsx

```tsx
import { Outlet } from '@tanstack/react-router'

function AppLayout() {
  return (
    <div>
      <Header />
      <Outlet />  {/* children render here */}
      <Footer />
    </div>
  )
}
```

**Key Points:**

- `<Outlet />` is a TanStack Router export, not React Router's
- A layout component that omits `<Outlet />` silently swallows all child routes [Inference — child components simply do not render; no error is thrown]
- Multiple outlets in a single layout are not supported in the standard model — each layout has one outlet

---

### Pathless Routes for Shared `beforeLoad`

A pathless layout route is a natural location for shared auth guards. All routes nested under it inherit the guard without each route defining its own:

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
    return { user: context.auth.user! }
  },
  component: () => <Outlet />,  // no UI — pass-through
})
```

```
routes/
  _authenticated.tsx     ← guard and context extension
  _authenticated/
    dashboard.tsx         ← protected, no guard needed
    settings.tsx          ← protected, no guard needed
  login.tsx               ← outside, unguarded
```

**Key Points:**

- The component is a bare `<Outlet />` — the layout adds no UI, only behavior
- All `_authenticated` children receive `context.user` from the `beforeLoad` return
- This is the canonical TanStack Router pattern for protecting route groups

---

### Pathless Routes for Shared Loaders

A pathless layout route can also run a shared loader, making the result available to all children via `useLoaderData` on the parent route:

ts

```ts
// routes/_app.tsx
export const Route = createFileRoute('/_app')({
  loader: async ({ context }) => {
    const preferences = await fetchUserPreferences(context.user.id)
    return { preferences }
  },
  component: AppLayout,
})
```

tsx

```tsx
// routes/_app/dashboard.tsx — child route
function DashboardComponent() {
  const { preferences } = Route.useLoaderData() // Route from _app.tsx
  // ...
}
```

[Inference — accessing a parent route's loader data from a child component requires importing and using the parent's `Route.useLoaderData()`; verify the exact pattern in your version]

---

### Route File Naming Conventions

TanStack Router's file-based routing uses consistent naming conventions to determine route structure:

| File pattern | Route type | URL contribution |
| --- | --- | --- |
| `_name.tsx` | Pathless layout | None |
| `_name/child.tsx` | Child of pathless layout | `/child` |
| `name.tsx` | Standard route | `/name` |
| `name/child.tsx` | Nested child | `/name/child` |
| `__root.tsx` | Root route | None (tree root) |
| `name_.tsx` | Pathless parent with segment [Unverified] | `/name` only |

**Key Points:**

- The underscore prefix is the signal for pathless — it must be at the start of the filename
- Folder names match the route file that owns them: `_app.tsx` and `_app/` are paired
- Double underscores (`__root.tsx`) are reserved for the root route only

---

### Layout Route vs Index Route

A layout route and an index route serve different purposes and are often used together:

```
routes/
  dashboard.tsx          ← layout, renders DashboardLayout + Outlet
  dashboard/
    index.tsx            ← renders at exactly /dashboard
    reports.tsx          ← renders at /dashboard/reports
```

ts

```ts
// routes/dashboard/index.tsx
export const Route = createFileRoute('/dashboard/')({
  component: DashboardIndexComponent,
})
```

**Key Points:**

- Without an `index.tsx`, visiting `/dashboard` renders the layout with an empty outlet
- `index.tsx` provides the default content when no child segment is active
- This is distinct from the layout file itself — the layout wraps; the index fills

---

### Nested Layout Routes

Layouts can be nested. Each level wraps the next with its own UI, guards, and loaders:

```
__root.tsx              ← global shell
  └── _app.tsx          ← authenticated shell (sidebar, nav)
        └── _admin.tsx  ← admin shell (admin toolbar)
              └── users.tsx  → URL: /users
```

tsx

```tsx
// _app.tsx component
function AppLayout() {
  return <div><GlobalNav /><Outlet /></div>
}

// _admin.tsx component
function AdminLayout() {
  return <div><AdminToolbar /><Outlet /></div>
}
```

The rendered output for `/users`:

```
AppLayout
  └── AdminLayout
        └── UsersComponent
```

Each layout mounts once and stays mounted while the user navigates within its subtree.

---

### Scroll Restoration and Layout Stability

Because layout routes remain mounted across child navigations, their component state persists. Scroll position within a layout container, open/closed state of a sidebar, and other UI state survive navigation between sibling routes.

[Inference — state persistence depends on whether the layout component re-renders or fully remounts; TanStack Router's default behavior keeps layout routes mounted during child navigations, but verify remount conditions for your version]

---

### Distinguishing Pathless from Named in Code-Based Routing

In code-based (non-file-based) routing, pathless layouts are created by omitting the `path` option or using an empty string, depending on the API:

ts

```ts
const appLayout = createRoute({
  getParentRoute: () => rootRoute,
  id: 'app',       // id instead of path — marks it as pathless
  component: AppLayout,
})
```

**Key Points:**

- `id` without `path` signals a pathless layout in code-based routing
- `id` must be unique across the route tree
- File-based routing handles this automatically via the underscore naming convention

---

### Common Mistakes

**Forgetting `<Outlet />` in a layout component**
Child routes do not render. No error is thrown — the layout simply appears without its children.

**Nesting files in the wrong folder**
`_app/dashboard.tsx` is a child of `_app.tsx`. Placing `dashboard.tsx` at the root level makes it a sibling, not a child — it receives no layout wrapping.

**Expecting pathless routes to appear in the URL**
Pathless routes are invisible to the URL. If a segment is needed, use a named layout route instead.

**Redefining guards on children of a guarded layout**
Routes nested under `_authenticated` do not need their own auth checks. Duplicating the guard is redundant and increases maintenance surface.

---

**Related Topics:**

- `<Outlet />` — rendering child routes within a layout
- Index routes — default content for a layout when no child is active
- `beforeLoad` for shared guards — protecting route groups via pathless layouts
- Context extension across the route tree — passing enriched context from layout `beforeLoad`
- File-based routing conventions — naming rules for layouts, indexes, and dynamic segments
- Code-based routing — defining layout routes with `id` vs `path`
- Scroll restoration — layout state persistence across child navigations