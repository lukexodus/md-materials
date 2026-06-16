## Passing Context Through the Route Tree

Context in TanStack Router does not remain static as navigation descends the route tree. Each route in the hierarchy can read the context it receives and optionally extend it — adding or overwriting properties — before passing the result down to child routes. This enables progressively enriched context that reflects accumulated knowledge about the current navigation.

---

### How Context Flows

Context originates at the router level and flows downward through the route tree. Each route's `beforeLoad` receives the context accumulated so far and may return additional properties to merge into it:

```
createRouter({ context: { ... } })
        ↓
__root.tsx        beforeLoad → return { ...additions }
        ↓
_layout.tsx       beforeLoad → return { ...additions }
        ↓
route.tsx         beforeLoad → return { ...additions }
        ↓
loader            receives fully merged context
        ↓
component         reads via useRouteContext()
```

Flow is strictly top-down. No route can inject properties visible to its ancestors or siblings.

---

### Base Context at the Router Level

The starting point for all context is the object passed to `createRouter` and optionally overridden per-render via `RouterProvider`:

ts

```ts
const router = createRouter({
  routeTree,
  context: {
    queryClient,
  },
})
```

tsx

```tsx
function App() {
  const auth = useAuth()

  return (
    <RouterProvider
      router={router}
      context={{ queryClient, auth }}
    />
  )
}
```

Every route in the tree receives at minimum the properties defined here.

---

### Extending Context in `beforeLoad`

Returning a plain object from `beforeLoad` merges its properties into the context for the current route's `loader` and all descendant routes:

ts

```ts
// routes/__root.tsx
export const Route = createRootRouteWithContext<RouterContext>()({
  beforeLoad: async ({ context }) => {
    const session = await context.auth.getSession()
    return { session }
  },
  component: RootComponent,
})
```

ts

```ts
// routes/_authenticated.tsx
export const Route = createFileRoute('/_authenticated')({
  beforeLoad: ({ context }) => {
    // context.session is available here, added by root
    if (!context.session) {
      throw redirect({ to: '/login' })
    }
    return {
      user: context.session.user,
    }
  },
})
```

ts

```ts
// routes/_authenticated/dashboard.tsx
export const Route = createFileRoute('/_authenticated/dashboard')({
  loader: ({ context }) => {
    // context.user is available here, added by _authenticated
    return fetchDashboard(context.user.id)
  },
})
```

Each layer receives what was accumulated above it, adds its own contribution, and passes the result downward.

---

### Merge Behavior

Context extension is a shallow merge. When a child route's `beforeLoad` returns a property that already exists in context, the child's value replaces the parent's for all downstream routes:

ts

```ts
// parent beforeLoad returns
{ role: 'user', theme: 'dark' }

// child beforeLoad returns
{ role: 'admin' }

// context seen by child's loader and grandchildren
{ role: 'admin', theme: 'dark' }
```

**Key Points:**

- Only the immediate child's return value is merged — grandchild routes do not see intermediate states, only the final accumulated result at each level
- Deep merging of nested objects does not occur automatically — returning `{ settings: { theme: 'dark' } }` overwrites the entire `settings` key if one already exists [Inference — standard shallow merge behavior; verify for your version]

---

### Typing Extended Context

TypeScript inference for extended context works through the return type of `beforeLoad`. Child routes infer the available context shape from the parent route's typed return.

For file-based routing, extended context types are propagated through the generated route tree. The key requirement is that the root route is defined with `createRootRouteWithContext`:

ts

```ts
// __root.tsx
interface RouterContext {
  queryClient: QueryClient
  auth: AuthState
}

export const Route = createRootRouteWithContext<RouterContext>()({
  component: RootComponent,
})
```

Child routes automatically receive the base type. Extensions added via `beforeLoad` return values are [Inference] inferred and available to descendant routes in supported versions — verify TypeScript inference behavior for your specific version as this area has evolved across releases.

For explicit control, annotate the return type of `beforeLoad`:

ts

```ts
beforeLoad: ({ context }): { user: User } => {
  if (!context.auth.isAuthenticated) throw redirect({ to: '/login' })
  return { user: context.auth.user! }
}
```

---

### Context Accumulation Across a Full Tree

A realistic example showing context building across three route levels:

ts

```ts
// routes/__root.tsx
export const Route = createRootRouteWithContext<{
  queryClient: QueryClient
  auth: AuthState
}>()({
  beforeLoad: async ({ context }) => {
    const flags = await fetchFeatureFlags()
    return { flags }
    // context now: { queryClient, auth, flags }
  },
})
```

ts

```ts
// routes/_authenticated.tsx
export const Route = createFileRoute('/_authenticated')({
  beforeLoad: ({ context }) => {
    if (!context.auth.isAuthenticated) {
      throw redirect({ to: '/login' })
    }
    return { user: context.auth.user! }
    // context now: { queryClient, auth, flags, user }
  },
})
```

ts

```ts
// routes/_authenticated/admin.tsx
export const Route = createFileRoute('/_authenticated/admin')({
  beforeLoad: ({ context }) => {
    if (context.user.role !== 'admin') {
      throw redirect({ to: '/unauthorized' })
    }
    return { adminPermissions: context.user.permissions }
    // context now: { queryClient, auth, flags, user, adminPermissions }
  },
})
```

ts

```ts
// routes/_authenticated/admin/users.tsx
export const Route = createFileRoute('/_authenticated/admin/users')({
  loader: ({ context }) => {
    // Full context available: queryClient, auth, flags, user, adminPermissions
    return context.queryClient.ensureQueryData(
      usersQueryOptions(context.adminPermissions)
    )
  },
})
```

---

### Context in Sibling Routes

Context extensions made by one route are not visible to sibling routes. Each branch of the tree only sees contributions from its own ancestor chain:

```
__root            { queryClient, auth }
├── /dashboard    beforeLoad returns { dashboardConfig }
│   └── /widgets  sees { queryClient, auth, dashboardConfig }
└── /settings     sees { queryClient, auth } only
                  — dashboardConfig is NOT available here
```

Shared context must be contributed by a common ancestor.

---

### Sharing Context Across Route Groups

When multiple route subtrees need the same context enrichment, place that enrichment in their nearest common ancestor — typically a pathless layout route:

ts

```ts
// routes/_app.tsx — common ancestor for all app routes
export const Route = createFileRoute('/_app')({
  beforeLoad: async ({ context }) => {
    const preferences = await fetchUserPreferences(context.auth.user.id)
    return { preferences }
  },
})
```

All routes nested under `_app` receive `preferences` in context. Routes outside `_app` do not.

---

### Context vs Loader Data for Child Routes

Context extension via `beforeLoad` and loader return values serve different purposes:

|  | Context extension (`beforeLoad` return) | Loader data (`loader` return) |
| --- | --- | --- |
| Available in child `beforeLoad` | Yes | No |
| Available in child `loader` | Yes | No |
| Available in component | Via `useRouteContext()` | Via `useLoaderData()` |
| Suitable for | Identity, services, permissions | Fetched application data |
| Blocks child hooks if slow | Yes — `beforeLoad` is sequential | No — loaders can parallelize |

If a value is needed in a child route's `beforeLoad` or `loader`, it must travel through context. Loader data does not propagate downward.

---

### Performance Consideration

Because `beforeLoad` hooks run sequentially down the tree — each waiting for the parent to complete before the child begins — expensive async operations in `beforeLoad` add sequential latency to every navigation through that route.

**Key Points:**

- Keep `beforeLoad` operations fast — synchronous checks, lightweight reads, or cached async results
- Reserve expensive data fetching for `loader`, which the router can parallelize across sibling routes
- If a `beforeLoad` must perform async work (e.g., session validation), consider caching the result to avoid repeat network calls on each navigation [Inference — caching strategy depends on your auth implementation]

---

### `useRouteContext` in Components

Inside a component, the accumulated context at that route level is accessible via `useRouteContext`:

tsx

```tsx
function AdminUsersComponent() {
  const { user, adminPermissions, flags } = Route.useRouteContext()

  return (
    <div>
      {flags.betaFeature && <BetaBadge />}
      <UserTable permissions={adminPermissions} />
    </div>
  )
}
```

**Key Points:**

- Returns the context snapshot from when the route was entered — not a live reactive value
- For live state, read directly from your store or React context
- `Route.useRouteContext()` is scoped to the current route's accumulated context, not the full global context object

---

### Resetting Context for a Subtree

There is no built-in mechanism to reset or isolate context for a subtree. [Unverified — verify in current API docs] All routes inherit from their ancestors. If isolation is needed, the conventional approach is to namespace context properties and overwrite the namespace at the relevant ancestor:

ts

```ts
// parent
return { reportingContext: { scope: 'global' } }

// child overrides the namespace
return { reportingContext: { scope: 'regional' } }
```

Descendants of the child see the overwritten namespace. The parent's value is shadowed for that subtree only.

---

**Related Topics:**

- `createRootRouteWithContext` — root context type definition
- `beforeLoad` return type inference — TypeScript behavior for extended context
- Pathless layout routes — grouping routes under a shared context-enriching ancestor
- `useRouteContext` — consuming context in components
- `loader` context parameter — using accumulated context in data fetching
- Sequential vs parallel execution — `beforeLoad` sequencing and loader parallelism
- Context vs loader data — choosing the right propagation mechanism