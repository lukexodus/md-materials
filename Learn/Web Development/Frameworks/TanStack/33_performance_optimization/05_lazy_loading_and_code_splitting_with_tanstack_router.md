## Lazy Loading and Code Splitting

### Overview

TanStack Router provides built-in support for lazy loading route components and splitting your application bundle so that only the code required for the current route is loaded. This reduces initial bundle size and improves time-to-interactive for large applications.

---

### Why Code Splitting Matters

In a single-page application, all route components are typically bundled together. As the application grows, this increases the initial JavaScript payload, slowing down first load even for users who never visit most routes.

Code splitting defers loading of route-specific code until the route is actually visited. TanStack Router integrates this at the route definition level.

---

### The `lazy` Route Option

Each route object in TanStack Router accepts a `lazy` property. This is an async function that returns a partial route definition — specifically, the `component`, `errorComponent`, `pendingComponent`, and `notFoundComponent` fields.

ts

```ts
// routes/dashboard.lazy.ts
import { createLazyFileRoute } from '@tanstack/react-router'

export const Route = createLazyFileRoute('/dashboard')({
  component: Dashboard,
})

function Dashboard() {
  return <div>Dashboard</div>
}
```

The `.lazy.ts` file convention is recognized by TanStack Router's code generation tooling. [Inference] The router's Vite/bundler plugin uses this convention to emit a dynamic `import()` for the file, creating a separate chunk. Behavior depends on bundler configuration and is not guaranteed to split automatically without the plugin.

---

### File-Based Routing: The `.lazy.ts` Convention

When using TanStack Router's file-based routing (via `@tanstack/router-plugin` for Vite or a compatible bundler), route files are split into two files:

| File | Contents |
| --- | --- |
| `routeName.tsx` | Loader, search params, guards, meta — code needed before render |
| `routeName.lazy.tsx` | Component, error/pending components — deferred until render |

**Example**

```
src/routes/
  posts.tsx          ← loader, validateSearch, beforeLoad
  posts.lazy.tsx     ← PostsComponent (deferred)
  posts.$postId.tsx
  posts.$postId.lazy.tsx
```

This separation means the loader runs eagerly (it must, to fetch data), while the UI component is deferred. [Inference] This pattern is particularly useful when loaders are lightweight but components have heavy dependencies (e.g., charting libraries, rich text editors).

---

### Manual Route Splitting (Without File-Based Routing)

When defining routes manually with `createRoute`, you attach the `lazy` function directly:

ts

```ts
import { createRoute, lazyRouteComponent } from '@tanstack/react-router'

const dashboardRoute = createRoute({
  getParentRoute: () => rootRoute,
  path: '/dashboard',
  component: lazyRouteComponent(
    () => import('./components/Dashboard'),
    'Dashboard' // named export
  ),
})
```

`lazyRouteComponent` is a helper that wraps a dynamic import and returns a component suitable for use as a route's `component`. It handles the Promise resolution and integrates with Router's Suspense-based rendering.

Alternatively, using the raw `lazy` option:

ts

```ts
const dashboardRoute = createRoute({
  getParentRoute: () => rootRoute,
  path: '/dashboard',
}).lazy(() =>
  import('./routes/dashboard.lazy').then((m) => m.Route)
)
```

**Key Points**

- The `.lazy()` call returns the route object enriched with deferred fields.
- The `component` in the lazy file is not included in the main bundle.
- The route's `loader`, `beforeLoad`, `validateSearch`, and other non-component properties still reside in the primary route definition and load eagerly.

---

### Parallel Loading: Preloading Routes

TanStack Router supports route preloading, which fetches lazy chunks and runs loaders before the user navigates — typically triggered on hover or focus of a `<Link>`.

ts

```ts
<Link to="/dashboard" preload="intent">
  Dashboard
</Link>
```

**`preload` values:**

| Value | Behavior |
| --- | --- |
| `"intent"` | Preloads on pointer enter or focus |
| `false` | No preloading |

Preloading is configured globally on the router:

ts

```ts
const router = createRouter({
  routeTree,
  defaultPreload: 'intent',
  defaultPreloadDelay: 100, // ms delay before triggering
})
```

[Inference] Setting a small `defaultPreloadDelay` reduces unnecessary preloads on accidental hovers, but the optimal value depends on observed user behavior and is not universally applicable.

---

### Pending Components During Lazy Load

While a lazy chunk is being fetched, TanStack Router can display a pending (loading) UI. This is configured per-route or globally.

ts

```ts
// In the lazy file or route definition
export const Route = createLazyFileRoute('/dashboard')({
  component: Dashboard,
  pendingComponent: () => <Spinner />,
})
```

Global default:

ts

```ts
const router = createRouter({
  routeTree,
  defaultPendingComponent: () => <GlobalSpinner />,
  defaultPendingMs: 300,       // delay before showing pending UI
  defaultPendingMinMs: 500,    // minimum display time once shown
})
```

**Key Points**

- `defaultPendingMs`: Avoids flash-of-spinner on fast connections by only showing the pending component if loading takes longer than this threshold.
- `defaultPendingMinMs`: Once the pending UI appears, it stays visible for at least this duration, preventing jarring flickers.

---

### Error Handling for Lazy Routes

If a lazy chunk fails to load (e.g., network error, deployment mismatch), the route's `errorComponent` is rendered.

ts

```ts
export const Route = createLazyFileRoute('/dashboard')({
  component: Dashboard,
  errorComponent: ({ error }) => (
    <div>Failed to load this page: {error.message}</div>
  ),
})
```

[Inference] Chunk load failures are more common after deployments that invalidate old bundle filenames. A common mitigation is to reload the page on chunk error, though this behavior must be implemented manually and is not built into the router.

---

### Route-Level Code Splitting Flow

NoYesNoYesUser navigates to/dashboardIs chunk loaded?Fetch dashboard.lazychunkChunk load success?Run loader if definedRender errorComponentRender DashboardcomponentShow pendingComponentif load takes pendingMs

---

### Interaction with Loaders

Loaders are defined in the non-lazy route file and run in parallel with lazy chunk fetching. [Inference] This means data fetching and code downloading can happen concurrently, reducing total navigation latency compared to sequential load-then-fetch patterns. Actual parallelism depends on browser network scheduling and is not guaranteed.

ts

```ts
// posts.tsx (eager — runs immediately on navigation)
export const Route = createFileRoute('/posts')({
  loader: () => fetchPosts(),
})

// posts.lazy.tsx (deferred — fetched concurrently with loader)
export const Route = createLazyFileRoute('/posts')({
  component: PostsPage,
})
```

---

### Bundle Analysis

To verify that splitting is working, inspect the output bundle. With Vite:

bash

```bash
vite build --mode production
npx vite-bundle-visualizer
```

Or configure `rollupOptions`:

ts

```ts
// vite.config.ts
build: {
  rollupOptions: {
    output: {
      manualChunks(id) {
        if (id.includes('node_modules')) return 'vendor'
      }
    }
  }
}
```

[Inference] Route-level chunks will appear as separate files in the dist output when `.lazy.ts` conventions and the router plugin are used correctly. Confirming this via the bundle visualizer is advisable rather than assuming splitting occurred.

---

### Critical Setup Requirement

Lazy loading via the `.lazy.ts` convention requires the TanStack Router Vite plugin (or equivalent bundler plugin). Without it, the convention is not recognized and no splitting occurs.

ts

```ts
// vite.config.ts
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import { TanStackRouterVite } from '@tanstack/router-plugin/vite'

export default defineConfig({
  plugins: [
    TanStackRouterVite(),
    react(),
  ],
})
```

The plugin must be listed before the React plugin. [Unverified — plugin ordering requirements may vary across versions; consult the official changelog if issues arise.]

---

**Related Topics**

- Route preloading strategies and `preloadStaleTime`
- `defaultPendingMs` / `defaultPendingMinMs` tuning
- Combining lazy loading with route-based data fetching
- Error boundaries and chunk load failure recovery
- Bundle analysis and manual `manualChunks` configuration
- Prefetching with `router.preloadRoute()`
- Streaming and deferred data with `defer()` in loaders