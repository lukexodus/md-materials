## Deferred and Streamed Data

TanStack Router supports deferring slow data so that fast data renders immediately while slower parts of the page load progressively. This avoids blocking the entire route render on a single slow loader result.

---

### The Problem Deferred Data Solves

A route loader normally blocks navigation until it resolves completely. If a loader fetches three independent resources and one is slow, the entire navigation waits for the slowest fetch before anything renders.

Deferred data breaks this blocking behavior. Fast data is returned immediately and rendered. Slow data is wrapped in a promise and streamed in asynchronously, resolving into the component after the initial render completes.

---

### `defer` — Marking Data as Deferred

TanStack Router provides a `defer` utility to wrap a promise and signal to the router that it should not block on that value:

ts

```ts
import { createFileRoute, defer } from '@tanstack/react-router'

export const Route = createFileRoute('/dashboard')({
  loader: async () => {
    const criticalData = await fetchCriticalData()

    return {
      criticalData,
      slowData: defer(fetchSlowData()),
    }
  },
})
```

**Key Points:**

- `criticalData` is awaited — navigation blocks until it resolves
- `fetchSlowData()` is passed unwrapped into `defer` — the promise is not awaited
- The router receives both values immediately; only the deferred one is pending
- The route renders as soon as the non-deferred values are ready

---

### `Await` — Consuming Deferred Data in Components

The `<Await>` component is the counterpart to `defer`. It accepts a deferred promise and renders its children once the promise resolves, with a fallback for the pending state:

tsx

```tsx
import { createFileRoute, defer, Await } from '@tanstack/react-router'
import { Suspense } from 'react'

export const Route = createFileRoute('/dashboard')({
  loader: async () => {
    const criticalData = await fetchCriticalData()
    return {
      criticalData,
      slowData: defer(fetchSlowData()),
    }
  },
  component: DashboardComponent,
})

function DashboardComponent() {
  const { criticalData, slowData } = Route.useLoaderData()

  return (
    <div>
      <h1>{criticalData.title}</h1>

      <Suspense fallback={<p>Loading additional data...</p>}>
        <Await promise={slowData}>
          {(resolved) => <SlowSection data={resolved} />}
        </Await>
      </Suspense>
    </div>
  )
}
```

**Key Points:**

- `<Await>` must be wrapped in `<Suspense>` to handle the pending state
- The render prop receives the resolved value once the promise settles
- `criticalData` is available synchronously — no `<Await>` needed
- Multiple deferred values can each have their own `<Await>` and `<Suspense>` boundary

---

### Error Handling for Deferred Promises

Deferred promises can reject. Errors are surfaced through an `<ErrorBoundary>` wrapping the `<Await>`:

tsx

```tsx
import { ErrorBoundary } from 'react'

<ErrorBoundary fallback={<p>Failed to load section.</p>}>
  <Suspense fallback={<p>Loading...</p>}>
    <Await promise={slowData}>
      {(resolved) => <SlowSection data={resolved} />}
    </Await>
  </Suspense>
</ErrorBoundary>
```

**Key Points:**

- Without an `<ErrorBoundary>`, a rejected deferred promise propagates as an unhandled error [Inference — standard React Suspense error behavior; verify in your version]
- The route-level `errorComponent` does not automatically catch errors from deferred promises — a local `<ErrorBoundary>` is the appropriate boundary
- The non-deferred parts of the page remain rendered even if a deferred promise rejects

---

### Multiple Deferred Values

A loader can return multiple deferred promises independently. Each resolves and renders on its own schedule:

ts

```ts
loader: async () => {
  const header = await fetchHeader()

  return {
    header,
    analytics: defer(fetchAnalytics()),
    recommendations: defer(fetchRecommendations()),
  }
}
```

tsx

```tsx
function PageComponent() {
  const { header, analytics, recommendations } = Route.useLoaderData()

  return (
    <div>
      <Header data={header} />

      <Suspense fallback={<Spinner />}>
        <Await promise={analytics}>
          {(data) => <AnalyticsPanel data={data} />}
        </Await>
      </Suspense>

      <Suspense fallback={<Spinner />}>
        <Await promise={recommendations}>
          {(data) => <RecommendationsList data={data} />}
        </Await>
      </Suspense>
    </div>
  )
}
```

Each `<Await>` resolves independently. Whichever promise settles first renders first, without waiting for the other.

---

### Deferred Data and Preloading

When a route is preloaded (via hover or focus), deferred promises are also initiated during preload. [Inference — the loader runs in full during preload; deferred promises start at that point]

By the time the user navigates, fast data is already resolved and slow data may be partially or fully resolved, depending on elapsed time. Behavior depends on preload timing and cache state; resolution is not guaranteed.

---

### Deferred Data and SSR

TanStack Router supports streaming deferred data in SSR environments. When rendering on the server, deferred promises stream their resolved values to the client as they settle, progressively hydrating the page.

**Key Points:**

- SSR streaming requires a server environment and adapter that supports streaming responses (e.g., React's `renderToPipeableStream` or `renderToReadableStream`)
- The client runtime receives the deferred data embedded in the stream and resolves the `<Await>` without a client-side fetch [Inference — standard TanStack Router SSR streaming pattern; implementation details depend on your server setup]
- SSR streaming setup is adapter-specific; verify configuration requirements for your deployment target

---

### `defer` Is Not a Data-Fetching Primitive

`defer` does not fetch data. It wraps an existing promise. The fetch itself must be initiated before or within the `defer` call:

ts

```ts
// Correct — fetch is initiated, promise is passed to defer
slowData: defer(fetchSlowData())

// Incorrect conceptually — defer does not trigger the fetch
slowData: defer(() => fetchSlowData()) // [Unverified whether this form is accepted; check API]
```

The promise must be live at the moment `defer` is called so that fetching begins immediately in parallel with the awaited portions of the loader.

---

### Comparison: Awaited vs Deferred

| Characteristic | Awaited Data | Deferred Data |
| --- | --- | --- |
| Blocks navigation | Yes | No |
| Available on first render | Yes | No — resolves later |
| Requires `<Await>` | No | Yes |
| Requires `<Suspense>` | No | Yes |
| Error boundary needed | Route-level | Local `<ErrorBoundary>` |
| SSR behavior | Included in initial HTML | Streamed progressively |

---

### When to Use Deferred Data

**Good candidates for deferral:**

- Non-critical supplementary content (analytics panels, recommendations, activity feeds)
- Data from slow third-party APIs that do not affect primary page function
- Content below the fold that the user will not see immediately

**Poor candidates for deferral:**

- Data required to render the primary content of the page
- Data needed for SEO-critical content in SSR contexts
- Data that other synchronous parts of the component depend on

---

**Related Topics:**

- `defer` and `Await` API reference — full option and prop details
- SSR streaming setup — adapter configuration for progressive rendering
- `<Suspense>` and `<ErrorBoundary>` patterns in React — foundational concepts
- Loader caching and stale time — how deferred results interact with the cache
- Parallel loaders — structuring loaders to maximize concurrent fetching
- Preloading and deferred data — interaction between intent preload and pending promises
- TanStack Start — full-stack streaming and SSR context