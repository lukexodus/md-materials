## Preloading Routes on Hover and Focus

TanStack Router includes built-in support for preloading route data before the user explicitly navigates. This allows data fetching to begin the moment a user signals intent — by hovering over a link or focusing it via keyboard — reducing perceived load time when the navigation finally occurs.

---

### What Preloading Does

When a user hovers over or focuses a `<Link>`, TanStack Router can trigger the target route's loader ahead of the actual navigation. By the time the user clicks or presses Enter, the data may already be cached, making the transition appear nearly instantaneous.

Preloading integrates directly with the router's loader and caching system. It does not require a separate data-fetching library to participate.

---

### Enabling Preloading

Preloading is configured at two levels: globally on the router, and per-link as an override.

#### Global Configuration

Pass the `defaultPreload` option when creating the router:

ts

```ts
import { createRouter } from '@tanstack/react-router'
import { routeTree } from './routeTree.gen'

const router = createRouter({
  routeTree,
  defaultPreload: 'intent',
})
```

The `'intent'` strategy activates preloading on both hover and focus events on any `<Link>` rendered by the router.

**Accepted values for `defaultPreload`:**

| Value | Behavior |
| --- | --- |
| `false` | Preloading disabled (default) |
| `'intent'` | Preload on hover or focus |
| `'viewport'` | [Unverified — check current API docs] Preload when link enters viewport |
| `'render'` | Preload immediately when the link renders |

> **Disclaimer:** The availability and exact behavior of each strategy may vary across versions. Verify against your installed version's changelog.

#### Per-Link Override

Individual `<Link>` components accept a `preload` prop that overrides the global setting:

tsx

```tsx
<Link to="/dashboard" preload="intent">
  Dashboard
</Link>
```

To disable preloading for a specific link even when globally enabled:

tsx

```tsx
<Link to="/heavy-route" preload={false}>
  Skip Preload
</Link>
```

---

### Preload Delay

To avoid unnecessary requests triggered by accidental or brief hovers, a delay can be configured:

ts

```ts
const router = createRouter({
  routeTree,
  defaultPreload: 'intent',
  defaultPreloadDelay: 100, // milliseconds
})
```

**Key Points:**

- The default delay is `50ms` [Inference — verify in source; may differ across versions]
- The preload is cancelled if the user moves away before the delay elapses
- Setting `defaultPreloadDelay: 0` fires immediately on hover/focus with no debounce

Per-link delay override is not directly exposed as a prop on `<Link>` as of recent stable versions. [Unverified — check current API surface]

---

### How the Loader Participates

Preloading invokes the same `loader` function defined on the route. No separate configuration is needed inside the loader itself:

ts

```ts
export const Route = createFileRoute('/dashboard')({
  loader: async () => {
    const data = await fetchDashboardData()
    return data
  },
  component: DashboardComponent,
})
```

When preloaded, the result is stored in the router's internal cache. If the user navigates before the cache entry expires, the cached result is used and the loader is not called again.

**Key Points:**

- The loader runs in the background during preload
- Navigation after a successful preload skips redundant loader execution [Inference — dependent on cache state and timing; not guaranteed]
- Loader errors during preload are silently discarded; they will re-surface only when actual navigation occurs [Inference — behavior may vary; verify in your version]

---

### Preload Cache Lifetime

The duration a preloaded result remains valid is controlled by `defaultPreloadStaleTime`:

ts

```ts
const router = createRouter({
  routeTree,
  defaultPreload: 'intent',
  defaultPreloadDelay: 100,
  defaultPreloadStaleTime: 10_000, // 10 seconds in ms
})
```

**Key Points:**

- If navigation occurs within the stale window, cached data is used
- After the stale time elapses, the next navigation re-runs the loader
- `defaultPreloadStaleTime` is distinct from `defaultStaleTime`, which governs post-navigation cache behavior

Per-route override via `routeOptions.preloadStaleTime` is [Unverified — confirm in API docs for your version].

---

### Preloading with External Data Libraries

When routes delegate data fetching to an external library (e.g., TanStack Query), the loader typically calls `ensureQueryData` or equivalent to warm the query cache:

ts

```ts
import { queryClient } from './queryClient'
import { dashboardQueryOptions } from './queries'

export const Route = createFileRoute('/dashboard')({
  loader: () => queryClient.ensureQueryData(dashboardQueryOptions),
  component: DashboardComponent,
})
```

During a preload trigger, the router calls this loader, which populates the external query cache. When the user navigates and the component mounts, the query cache already holds the data, producing an immediate render.

**Key Points:**

- This pattern makes preloading transparent to the component layer
- The component simply reads from the query cache regardless of whether navigation was preloaded or not
- `ensureQueryData` does not refetch if fresh data already exists, preventing duplicate requests [Inference — standard TanStack Query behavior; verify for your query library version]

---

### `<Link>` Event Hooks

`<Link>` does not expose raw `onMouseEnter` or `onFocus` props for intercepting preload events directly. [Unverified — confirm in current API] The preload lifecycle is managed internally by the router.

Standard event props like `onClick` remain available and are unaffected by preloading:

tsx

```tsx
<Link
  to="/reports"
  preload="intent"
  onClick={() => analytics.track('reports_clicked')}
>
  Reports
</Link>
```

---

### `preloadRoute` — Manual Programmatic Preloading

Beyond hover and focus, preloading can be triggered imperatively using the router instance:

ts

```ts
const router = useRouter()

const handleMouseEnter = () => {
  router.preloadRoute({ to: '/dashboard' })
}
```

**Key Points:**

- Accepts the same `NavigateOptions` shape used by `router.navigate`
- Useful when building custom link components or non-anchor interactive elements
- The result is stored in the same cache as intent-based preloads

---

### Observing Preload Behavior

No built-in UI indicator exists for preload activity. During development, network activity in browser DevTools is the primary observable signal. A preload request appears as a fetch initiated before the user clicks.

[Inference] TanStack Router DevTools, if installed, may surface pending preload states, but the exact UI representation depends on the DevTools version.

---

### Common Pitfalls

**Preloading expensive loaders indiscriminately**
If a loader performs costly operations, enabling `'intent'` globally may trigger unnecessary work on casual hover. Consider setting `preload={false}` on specific links or increasing `defaultPreloadDelay`.

**Assuming preloaded data is always used**
If the user navigates after the stale window closes, or if the cache is invalidated between preload and navigation, the loader runs again. Behavior is not guaranteed to be cache-hit every time.

**Using `'intent'` on mobile**
Hover events do not fire reliably on touch devices. On mobile, `'intent'` preloading has no practical trigger. [Inference — standard browser behavior; touch interactions do not produce `mouseenter`]

---

**Related Topics:**

- `defaultStaleTime` vs `defaultPreloadStaleTime` — understanding the two cache lifetimes
- Route loader caching and `gcTime` — garbage collection of unused cache entries
- `router.preloadRoute` API — full programmatic preloading reference
- Loader dependencies and `loaderDeps` — cache keying by search params or context
- Integrating TanStack Query `ensureQueryData` in loaders
- `<Link>` component API — full prop reference
- TanStack Router DevTools — inspecting loader and cache state