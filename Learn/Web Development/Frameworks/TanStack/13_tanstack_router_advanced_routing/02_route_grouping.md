## Route Grouping

Route grouping in TanStack Router is the practice of organizing routes into logical collections that share layout, guards, loaders, or context — without necessarily sharing a URL prefix. It is an organizational and behavioral tool, not a URL design tool.

---

### What Route Grouping Means

A route group is any set of routes collected under a common ancestor. That ancestor may be:

- A **pathless layout route** — groups routes with shared behavior, no URL contribution
- A **named layout route** — groups routes under a shared URL prefix with shared UI
- A **directory** — organizes files without implying any routing behavior on its own

The term "route group" does not refer to a specific API primitive. It describes the structural pattern of using a common parent to collect related routes.

---

### Grouping with Pathless Layout Routes

The most common grouping mechanism. A pathless layout route (prefixed with `_`) acts as an invisible parent that contributes behavior — guards, context, loaders, UI — to all routes nested within it, without appearing in the URL:

```
routes/
  __root.tsx
  _authenticated.tsx          ← group: all authenticated routes
  _authenticated/
    dashboard.tsx             → /dashboard
    settings.tsx              → /settings
    profile.tsx               → /profile
  _public.tsx                 ← group: all public routes
  _public/
    home.tsx                  → /
    about.tsx                 → /about
  login.tsx                   → /login
```

`_authenticated` and `_public` are groups. Each enforces different behavior on its children without affecting their URLs.

---

### Grouping with Named Layout Routes

When a shared URL prefix is appropriate, a named layout route creates a group whose children also share a path segment:

```
routes/
  admin.tsx                   ← group + URL: /admin
  admin/
    users.tsx                 → /admin/users
    roles.tsx                 → /admin/roles
    audit.tsx                 → /admin/audit
```

The `admin.tsx` layout provides shared UI (admin nav, permission guard) and a URL prefix. All children are reachable under `/admin`.

---

### Grouping for Shared Guards

A route group's pathless parent is the correct location for a guard shared across all members:

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
  component: () => <Outlet />,
})
```

Every route inside `_authenticated/` is protected. No child route defines its own guard.

---

### Grouping for Shared Layout UI

A group parent can contribute UI shared by all members. Children render into the `<Outlet />`:

```tsx
// routes/_dashboard.tsx
export const Route = createFileRoute('/_dashboard')({
  component: () => (
    <div className="dashboard-shell">
      <DashboardSidebar />
      <main>
        <Outlet />
      </main>
    </div>
  ),
})
```

```
routes/
  _dashboard.tsx
  _dashboard/
    overview.tsx      → /overview
    analytics.tsx     → /analytics
    reports.tsx       → /reports
```

All three routes share the sidebar without repeating it or prefixing their URLs with `dashboard`.

---

### Grouping for Shared Loaders

A group parent can run a loader once for all its children. Children access the result via the parent route's `useLoaderData`:

```ts
// routes/_app.tsx
export const Route = createFileRoute('/_app')({
  loader: async ({ context }) => {
    const [preferences, notifications] = await Promise.all([
      fetchPreferences(context.user.id),
      fetchNotifications(context.user.id),
    ])
    return { preferences, notifications }
  },
  component: () => <Outlet />,
})
```

```tsx
// routes/_app/dashboard.tsx
import { Route as AppRoute } from '../_app'

function DashboardComponent() {
  const { preferences, notifications } = AppRoute.useLoaderData()
  // ...
}
```

**Key Points:**
- The parent loader runs once when entering the group — not per child navigation
- Children do not re-trigger the parent loader when navigating between siblings [Inference — loader re-execution depends on staleness and cache configuration; verify in your version]
- This avoids duplicate fetches for data shared across all routes in the group

---

### Grouping for Shared Context

`beforeLoad` on a group parent can return context extensions available to all children's `beforeLoad` and `loader` hooks:

```ts
// routes/_admin.tsx
export const Route = createFileRoute('/_admin')({
  beforeLoad: ({ context }) => {
    if (context.user.role !== 'admin') {
      throw redirect({ to: '/unauthorized' })
    }
    return {
      adminPermissions: context.user.permissions,
    }
  },
  component: () => <Outlet />,
})
```

```ts
// routes/_admin/users.tsx
export const Route = createFileRoute('/_admin/users')({
  loader: ({ context }) => {
    // context.adminPermissions available here
    return fetchUsers(context.adminPermissions)
  },
})
```

---

### Multiple Independent Groups at the Same Level

Multiple groups can coexist at the same directory level without interfering:

```
routes/
  __root.tsx

  _public.tsx              ← public group (no auth required)
  _public/
    home.tsx               → /
    about.tsx              → /about
    pricing.tsx            → /pricing

  _authenticated.tsx       ← auth required
  _authenticated/
    dashboard.tsx          → /dashboard
    profile.tsx            → /profile

  _admin.tsx               ← auth + admin role required
  _admin/
    users.tsx              → /users
    audit.tsx              → /audit

  login.tsx                → /login
  404.tsx
```

Each group enforces its own behavior independently. Routes belong to exactly one group at each level of the tree.

---

### Nested Groups

Groups can be nested. An outer group applies broader behavior; inner groups apply narrower behavior:

```
routes/
  _authenticated.tsx            ← auth guard
  _authenticated/
    _admin.tsx                  ← admin role guard (nested)
    _admin/
      users.tsx                 → /users
      audit.tsx                 → /audit
    dashboard.tsx               → /dashboard
    settings.tsx                → /settings
```

```
Navigation to /users:
  _authenticated beforeLoad   ← auth check
  _admin beforeLoad           ← role check
  users loader
  users component
```

Navigation to `/dashboard` only passes through `_authenticated` — not `_admin`.

---

### Directory-Only Grouping (No Behavior)

A directory can organize files visually without adding any route behavior. This requires a corresponding route file for the directory to be recognized:

```
routes/
  dashboard.tsx               → /dashboard (layout)
  dashboard/
    overview.tsx              → /dashboard/overview
    analytics/
      traffic.tsx             → /dashboard/analytics/traffic
      conversions.tsx         → /dashboard/analytics/conversions
```

The `analytics/` directory groups related files in the filesystem without adding a URL segment, as long as no `analytics.tsx` route file is created. [Inference — directory-only grouping without a corresponding route file depends on file-based routing resolution; verify behavior in your version's router generator]

---

### Grouping and the Generated Route Tree

File-based routing generates a route tree (`routeTree.gen.ts`) that reflects the file structure. Groups appear as intermediate nodes in that tree. The generated types propagate the context and loader data types from group parents to all children automatically.

**Key Points:**
- Renaming or reorganizing group files requires regenerating the route tree
- Generated IDs for pathless routes use the underscore form (`/_authenticated`) as their route ID in the tree
- TypeScript errors in child routes often trace back to a mismatch in the group parent's context or loader types

---

### Grouping vs Repeating Configuration

Without grouping, each route independently declares its guards, loaders, and UI:

```ts
// Without grouping — repeated on every route
export const Route = createFileRoute('/dashboard')({
  beforeLoad: ({ context }) => {
    if (!context.auth.isAuthenticated) throw redirect({ to: '/login' })
  },
  loader: async ({ context }) => fetchPreferences(context.user.id),
  component: () => <><DashboardSidebar /><DashboardComponent /></>,
})
```

With grouping, the repeated concerns move to the parent once:

```ts
// Group parent handles it for all children
export const Route = createFileRoute('/_app')({
  beforeLoad: ({ context }) => {
    if (!context.auth.isAuthenticated) throw redirect({ to: '/login' })
    return { user: context.auth.user! }
  },
  loader: async ({ context }) => fetchPreferences(context.user.id),
  component: () => <><AppSidebar /><Outlet /></>,
})
```

**Key Points:**
- Grouping reduces duplication and centralizes behavior that applies across a set of routes
- Changes to a shared guard or loader apply automatically to all routes in the group
- The tradeoff is indirection — the behavior of a child route is not fully visible from the child file alone

---

### When to Use Each Group Type

| Need | Group type |
|---|---|
| Shared auth guard, no URL prefix | Pathless layout (`_name.tsx`) |
| Shared UI, no URL prefix | Pathless layout with component |
| Shared URL prefix and UI | Named layout route |
| Shared loader data across routes | Pathless or named layout with loader |
| Visual file organization only | Directory (no route file) |
| Role-based subsection | Nested pathless layout |

---

**Related Topics:**
- Pathless layout routes — the primary grouping primitive
- Named layout routes — grouping with a URL prefix
- `beforeLoad` for shared guards — guard pattern on group parents
- Context extension across the route tree — propagating enriched context to group children
- Shared loaders on layout routes — fetching once for a group
- File-based routing conventions — naming rules for groups and layouts
- Route tree generation — how groups appear in `routeTree.gen.ts`
- Nested groups — layering guards and layouts for role-based subsections