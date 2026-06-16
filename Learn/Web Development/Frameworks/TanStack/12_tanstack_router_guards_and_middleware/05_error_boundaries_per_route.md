## Error Boundaries per Route

TanStack Router integrates error boundary behavior directly into the route definition. Each route can declare its own `errorComponent`, which renders when the route's `loader`, `beforeLoad`, or component throws an unhandled error. This scopes error UI to the affected route rather than collapsing the entire page.

---

### How Route-Level Error Boundaries Work

When an error is thrown anywhere in a route's lifecycle — `beforeLoad`, `loader`, or the component itself — TanStack Router catches it and renders the nearest `errorComponent` in the ancestor chain. Routes that did not error continue rendering normally.

This mirrors React's `<ErrorBoundary>` concept but is integrated into the router's own rendering pipeline and does not require manually wrapping routes in React error boundary components.

---

### Defining an `errorComponent`

ts

```ts
export const Route = createFileRoute('/dashboard')({
  loader: async () => {
    return await fetchDashboardData()
  },
  errorComponent: ({ error }) => {
    return <div>Failed to load dashboard: {error.message}</div>
  },
  component: DashboardComponent,
})
```

**Key Points:**

- `errorComponent` receives an `error` prop containing the thrown value
- It replaces the route's normal `component` when an error is present
- The rest of the rendered tree — parent routes, sibling routes — is unaffected

---

### The `errorComponent` Prop Signature

ts

```ts
errorComponent: (props: {
  error: Error
  reset: () => void
}) => ReactNode
```

| Prop | Type | Description |
| --- | --- | --- |
| `error` | `Error` | The thrown error object |
| `reset` | `() => void` | Clears the error state and retries the route |

---

### Using `reset` to Retry

`reset` clears the error boundary and re-runs the route's `loader` and `beforeLoad`. It is the primary recovery mechanism for transient errors:

tsx

```tsx
errorComponent: ({ error, reset }) => {
  return (
    <div>
      <p>Something went wrong: {error.message}</p>
      <button onClick={reset}>Try again</button>
    </div>
  )
}
```

**Key Points:**

- `reset` re-executes the full route lifecycle — `beforeLoad` and `loader` run again
- If the underlying condition has not changed, the error will recur [Inference — reset is a retry, not a fix; behavior depends on what caused the error]
- For errors caused by stale data or temporary network failures, `reset` is appropriate; for logic errors it will loop

---

### Error Propagation and the Nearest Boundary

If a route does not define an `errorComponent`, its error propagates upward to the nearest ancestor that does. This follows the same model as React error boundaries:

```
__root.tsx          errorComponent defined ← catches if nothing else does
  └── _layout.tsx   no errorComponent
        └── dashboard.tsx  loader throws
              → error propagates to __root.tsx errorComponent
```

If no route in the tree defines an `errorComponent`, the error is unhandled and surfaces as an uncaught exception. [Inference — exact behavior for unhandled route errors depends on the React version and renderer; verify in your environment]

---

### Root-Level Fallback

A root route `errorComponent` acts as the application-wide fallback for any unhandled route error:

ts

```ts
// routes/__root.tsx
export const Route = createRootRouteWithContext<RouterContext>()({
  errorComponent: ({ error, reset }) => {
    return (
      <div>
        <h1>Application Error</h1>
        <p>{error.message}</p>
        <button onClick={reset}>Reload</button>
      </div>
    )
  },
  component: RootComponent,
})
```

**Key Points:**

- This renders in place of the entire route tree when triggered
- More specific `errorComponent` definitions on child routes take precedence and prevent propagation to the root
- A root fallback is a safety net, not a substitute for granular error handling

---

### Scoped Error Boundaries Preserve Layout

The primary advantage of per-route error boundaries over a single application-wide boundary is layout preservation. When a leaf route errors, its parent layout routes remain rendered:

```
__root.tsx           ← renders normally (header, nav)
  └── _layout.tsx    ← renders normally (sidebar)
        └── /reports ← errorComponent renders here only
```

The user retains navigation context and can move to other parts of the application without a full page error.

---

### Distinguishing Error Types

`error` is typed as `Error` but may be any thrown value in practice. Narrowing the type enables differentiated error UI:

tsx

```tsx
errorComponent: ({ error, reset }) => {
  if (error instanceof NotFoundError) {
    return <p>Resource not found.</p>
  }

  if (error instanceof UnauthorizedError) {
    return <p>You do not have permission to view this.</p>
  }

  return (
    <div>
      <p>Unexpected error: {error.message}</p>
      <button onClick={reset}>Retry</button>
    </div>
  )
}
```

Custom error classes thrown from `loader` or `beforeLoad` allow the `errorComponent` to respond to specific failure modes rather than treating all errors identically.

---

### `notFoundComponent` — a Parallel Concept

TanStack Router separates the concept of "not found" from general errors. Throwing `notFound()` from a `loader` renders the route's `notFoundComponent` rather than its `errorComponent`:

ts

```ts
import { notFound } from '@tanstack/react-router'

loader: async ({ params }) => {
  const item = await fetchItem(params.id)
  if (!item) throw notFound()
  return item
}
```

ts

```ts
export const Route = createFileRoute('/items/$id')({
  notFoundComponent: () => <p>Item not found.</p>,
  errorComponent: ({ error }) => <p>Error: {error.message}</p>,
  // ...
})
```

**Key Points:**

- `notFound()` is not an `Error` — it does not trigger `errorComponent`
- Both `errorComponent` and `notFoundComponent` can be defined on the same route independently
- `notFoundComponent` propagates upward to the nearest ancestor that defines it, following the same rules as `errorComponent`

---

### `useRouteContext` and `useLoaderData` Inside `errorComponent`

Route hooks are not available inside `errorComponent` because the route's loader may not have completed successfully. [Inference — accessing `useLoaderData` inside an `errorComponent` for the same route may throw or return undefined; verify in your version]

Parent route context and loader data remain accessible through their own route hooks if needed in a shared error UI.

---

### `CatchBoundary` — Inline Component-Level Boundaries

For errors that occur within a component's render — not in `loader` or `beforeLoad` — TanStack Router provides a `CatchBoundary` component for inline placement:

tsx

```tsx
import { CatchBoundary } from '@tanstack/react-router'

function DashboardComponent() {
  return (
    <div>
      <Header />
      <CatchBoundary
        getResetKey={() => 'widget-section'}
        onCatch={(error) => console.error(error)}
        errorComponent={({ error, reset }) => (
          <div>
            <p>Widget failed: {error.message}</p>
            <button onClick={reset}>Retry</button>
          </div>
        )}
      >
        <WidgetSection />
      </CatchBoundary>
    </div>
  )
}
```

**Key Points:**

- `CatchBoundary` is a React component, not a route option
- It handles render-time errors within a component subtree, independent of the route boundary
- `getResetKey` returns a string; when the key changes, the boundary resets automatically [Inference — verify exact reset key behavior in your version]
- Useful for isolating unstable or third-party child components within an otherwise stable route

---

### `ErrorComponent` — the Default Error UI

TanStack Router ships a default `ErrorComponent` that is used when no `errorComponent` is specified on a route. It renders a minimal error display including the error message and a stack trace in development. [Unverified — exact default UI may differ across versions; verify in your installed version]

It can be imported and used directly as a base, extended, or replaced entirely:

tsx

```tsx
import { ErrorComponent } from '@tanstack/react-router'

errorComponent: ({ error, reset }) => {
  // log to error reporting service
  reportError(error)

  return <ErrorComponent error={error} reset={reset} />
}
```

---

### Errors from `beforeLoad` vs `loader`

Both `beforeLoad` and `loader` errors are caught by `errorComponent`. The distinction matters for what work was done before the error occurred:

| Source | Work done before error | `errorComponent` triggered |
| --- | --- | --- |
| `beforeLoad` | Nothing — loader never started | Yes |
| `loader` | `beforeLoad` completed | Yes |
| Component render | Both hooks completed | Yes |

In all cases the same `errorComponent` handles the error. The `error` prop does not indicate which lifecycle phase threw. [Inference — no built-in phase metadata on the error prop; verify if your version adds this]

---

### Logging and Reporting Errors

`errorComponent` is an appropriate location to trigger error reporting to an external service:

tsx

```tsx
errorComponent: ({ error, reset }) => {
  useEffect(() => {
    reportToSentry(error)
  }, [error])

  return (
    <div>
      <p>Something went wrong.</p>
      <button onClick={reset}>Try again</button>
    </div>
  )
}
```

**Key Points:**

- `useEffect` is safe inside `errorComponent` since it is a normal React component
- Avoid calling reporting logic unconditionally at render time to prevent duplicate reports on re-renders

---

**Related Topics:**

- `notFoundComponent` and `notFound()` — handling missing resource errors distinctly
- `CatchBoundary` — inline component-level error isolation
- `ErrorComponent` default export — extending the built-in error UI
- `loader` error handling — throwing typed errors from data fetching
- `beforeLoad` — errors thrown during pre-navigation checks
- Error propagation in nested routes — ancestor fallback behavior
- Integrating error reporting services — Sentry, Datadog, and similar tools