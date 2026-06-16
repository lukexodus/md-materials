## Parallel Route Rendering

TanStack Router does not have a dedicated "parallel routes" primitive in the same sense as some other frameworks. Parallelism in TanStack Router operates at the loader level — multiple loaders across sibling and nested routes, and multiple fetches within a single loader, can execute concurrently. Understanding where parallelism occurs and how to structure routes and loaders to take advantage of it is the core of this topic.

---

### Where Parallelism Occurs

TanStack Router executes loaders in parallel when it can determine that multiple routes will be rendered for a given navigation. On a navigation to a nested route, the router identifies all routes in the matched hierarchy and runs their loaders concurrently — not sequentially:

```
Navigation to /dashboard/reports

Matched routes:
  __root
  _authenticated       ← loader runs ┐
  _dashboard           ← loader runs ├─ concurrently
  dashboard/reports    ← loader runs ┘
```

All three loaders start at the same time. The route renders when all loaders resolve.

**Key Points:**
- Parallelism is automatic — no explicit configuration is needed to enable concurrent loader execution across matched routes
- `beforeLoad` hooks are sequential (parent before child); loaders are parallel [Inference — verify exact sequencing guarantees in your version]
- The render waits for the slowest loader unless deferred data is used

---

### `beforeLoad` Is Sequential, Loaders Are Parallel

This distinction is significant. `beforeLoad` runs top-down sequentially because each hook may extend context that the next depends on. Loaders run in parallel because they consume finalized context and do not depend on each other:

```
__root beforeLoad
  ↓ (sequential)
_authenticated beforeLoad
  ↓ (sequential)
dashboard/reports beforeLoad
  ↓ (all beforeLoad complete — context is finalized)

__root loader          ┐
_authenticated loader  ├─ parallel
dashboard/reports loader ┘
```

Expensive async work in `beforeLoad` adds sequential latency to every navigation through that route. Expensive work belongs in `loader`.

---

### Parallel Fetches Within a Single Loader

Within a single route's loader, independent data fetches should be initiated concurrently using `Promise.all` or equivalent:

```ts
// Sequential — slow
loader: async ({ context }) => {
  const user = await fetchUser(context.user.id)
  const posts = await fetchPosts(context.user.id)
  const stats = await fetchStats(context.user.id)
  return { user, posts, stats }
}
```

```ts
// Parallel — fast
loader: async ({ context }) => {
  const [user, posts, stats] = await Promise.all([
    fetchUser(context.user.id),
    fetchPosts(context.user.id),
    fetchStats(context.user.id),
  ])
  return { user, posts, stats }
}
```

**Key Points:**
- `Promise.all` fails fast — if any fetch rejects, the entire `Promise.all` rejects [Inference — standard `Promise.all` behavior]
- For independent fetches where partial failure is acceptable, `Promise.allSettled` preserves individual results and errors
- Initiating fetches without `await` and collecting them into `Promise.all` ensures they start simultaneously

---

### `Promise.allSettled` for Resilient Parallel Fetches

```ts
loader: async ({ context }) => {
  const [userResult, postsResult] = await Promise.allSettled([
    fetchUser(context.user.id),
    fetchPosts(context.user.id),
  ])

  return {
    user: userResult.status === 'fulfilled' ? userResult.value : null,
    posts: postsResult.status === 'fulfilled' ? postsResult.value : [],
    errors: {
      user: userResult.status === 'rejected' ? userResult.reason : null,
      posts: postsResult.status === 'rejected' ? postsResult.reason : null,
    },
  }
}
```

**Key Points:**
- Each fetch result is inspected independently — a single failure does not abort the rest
- The component receives all results including partial failures, and can render accordingly
- Error handling moves into the component or loader return value rather than the route `errorComponent`

---

### Parallel Loaders with TanStack Query

When routes delegate fetching to TanStack Query via `ensureQueryData`, parallel execution happens naturally — each route's loader populates its own query cache entry simultaneously:

```ts
// _dashboard.tsx loader
loader: ({ context }) =>
  context.queryClient.ensureQueryData(dashboardQueryOptions)

// dashboard/reports.tsx loader
loader: ({ context }) =>
  context.queryClient.ensureQueryData(reportsQueryOptions)
```

Both `ensureQueryData` calls run in parallel across their respective route loaders. Neither waits for the other.

**Key Points:**
- TanStack Query deduplicates identical in-flight requests — if two loaders request the same query key simultaneously, only one network request fires [Inference — standard TanStack Query deduplication behavior; verify for your version]
- Components read from the query cache synchronously after loaders resolve — no additional fetch occurs on mount

---

### Deferred Data for Mixed-Speed Loaders

When one loader in a parallel set is significantly slower than others, it blocks the render for all matched routes. Deferred data breaks this coupling — slow data is wrapped in `defer` and streamed in after the initial render:

```ts
// dashboard/reports.tsx
loader: async ({ context }) => {
  const summary = await fetchSummary(context.user.id) // fast

  return {
    summary,
    details: defer(fetchDetails(context.user.id)), // slow — non-blocking
  }
}
```

The route renders as soon as `summary` is available. `details` resolves asynchronously and populates its `<Await>` boundary independently.

---

### Sibling Route Loaders

Sibling routes — routes at the same level of the tree that are simultaneously active — run their loaders in parallel. This is common in nested layouts where a parent layout and a child route are both matched:

```
/dashboard/overview

Matched:
  _app          loader: fetchPreferences()  ┐ parallel
  _dashboard    loader: fetchNavItems()     ├ parallel
  overview      loader: fetchOverviewData() ┘ parallel
```

No route's loader waits for a sibling's loader to complete.

---

### Structuring Routes to Maximize Parallelism

Route structure directly affects how much loader work runs in parallel. Flatter trees with independent loaders parallelize better than deep chains with interdependent data:

**Less parallel — data dependency chain:**
```ts
// parent loader fetches userId, child loader needs it
// child cannot start until parent resolves

// parent
loader: async () => {
  const { userId } = await fetchSession()
  return { userId }
}

// child — must wait for parent loader to resolve
loader: async ({ context }) => {
  // if userId came from parent loader data, child blocks on parent
}
```

**More parallel — shared context, independent loaders:**
```ts
// userId in router context — available before any loader starts
// both loaders start simultaneously

// parent
loader: ({ context }) => fetchParentData(context.user.id)

// child
loader: ({ context }) => fetchChildData(context.user.id)
```

**Key Points:**
- Data that child loaders depend on belongs in router context (via `beforeLoad`), not in parent loader return values
- Parent loader return values are not available to child loaders — only context is [Inference — verify this constraint in your version; this is the documented model but edge cases may exist]
- Moving shared dependencies into context via `beforeLoad` unlocks full parallel execution across the matched route hierarchy

---

### Waterfall Patterns to Avoid

A waterfall occurs when fetch B cannot start until fetch A completes, even though B does not depend on A's result:

```ts
// Waterfall inside a loader — avoidable
loader: async ({ context }) => {
  const user = await fetchUser(context.user.id)   // A
  const posts = await fetchPosts(context.user.id) // B waits for A unnecessarily
  return { user, posts }
}
```

```ts
// Parallel — no waterfall
loader: async ({ context }) => {
  const [user, posts] = await Promise.all([
    fetchUser(context.user.id),
    fetchPosts(context.user.id),
  ])
  return { user, posts }
}
```

Across routes, waterfall risk appears when a child route's loader depends on data that only exists in a parent route's loader return — rather than in context. Restructuring that dependency into context resolves the waterfall.

---

### Loader Parallelism and `defaultPreload`

During preloads triggered by hover or focus, all matched route loaders for the target route hierarchy start in parallel — the same as a real navigation. Preloading a deeply nested route warms all ancestor and descendant loaders simultaneously. [Inference — preload follows the same matched route resolution as navigation; verify full preload parallelism behavior in your version]

---

### No Built-in "Slots" or Named Outlets

TanStack Router does not support rendering multiple independent route components into named slots within a single layout — a pattern sometimes called parallel routes in other frameworks. Each layout has a single `<Outlet />` that renders one matched child at a time.

[Inference] Rendering multiple independent data regions within a single route is achieved through:
- Multiple `defer`-wrapped promises within one loader, each with its own `<Await>` and `<Suspense>`
- Multiple TanStack Query `useQuery` calls within a component, each independently suspending
- Manually composing data from a single loader that fetches in parallel internally

---

### Parallel Rendering with TanStack Query `useSuspenseQuery`

Components that use `useSuspenseQuery` can participate in React's concurrent rendering model. Multiple `useSuspenseQuery` calls within a component suspend independently when wrapped in separate `<Suspense>` boundaries:

```tsx
function DashboardComponent() {
  return (
    <div>
      <Suspense fallback={<Spinner />}>
        <UserPanel />       {/* useSuspenseQuery inside */}
      </Suspense>
      <Suspense fallback={<Spinner />}>
        <StatsPanel />      {/* useSuspenseQuery inside */}
      </Suspense>
    </div>
  )
}
```

Each panel fetches and renders independently. A slow `StatsPanel` does not block `UserPanel` from appearing.

**Key Points:**
- This is component-level parallelism, not route-level parallelism
- TanStack Query handles the fetch deduplication and cache management
- Requires React 18+ concurrent features for full benefit [Inference — `useSuspenseQuery` behavior is tied to React's Suspense implementation]

---

**Related Topics:**
- `defer` and deferred data — non-blocking slow fetches within a loader
- `Promise.all` and `Promise.allSettled` — parallel fetch patterns within a loader
- `beforeLoad` context extension — placing shared data in context to unlock loader parallelism
- TanStack Query `ensureQueryData` in loaders — query-based parallel loading
- `useSuspenseQuery` — component-level parallel data fetching with Suspense
- Waterfall patterns — identifying and resolving sequential fetch chains
- Preloading — parallel loader execution during hover and focus preloads