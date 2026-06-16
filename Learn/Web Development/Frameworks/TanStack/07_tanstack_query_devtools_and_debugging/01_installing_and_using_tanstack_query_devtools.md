## TanStack Query DevTools — Installation and Usage

### Overview

TanStack Query ships its developer tooling as a separate package. The DevTools panel provides a real-time visual interface for inspecting query cache state, observing query lifecycle transitions, and manually triggering refetches or cache invalidations during development.

---

### Installation

Install the DevTools package alongside TanStack Query:

```bash
# npm
npm install @tanstack/react-query-devtools

# pnpm
pnpm add @tanstack/react-query-devtools

# yarn
yarn add @tanstack/react-query-devtools
```

The DevTools package is versioned in sync with `@tanstack/react-query`. Mismatched major versions may produce unexpected behavior. [Unverified: patch-level compatibility guarantees are not documented explicitly.]

---

### Basic Setup

Mount `ReactQueryDevtools` inside your `QueryClientProvider`. It does not require any props to function.

```tsx
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { ReactQueryDevtools } from '@tanstack/react-query-devtools'

const queryClient = new QueryClient()

function App() {
  return (
    <QueryClientProvider client={queryClient}>
      <YourApp />
      <ReactQueryDevtools />
    </QueryClientProvider>
  )
}
```

**Key Points:**
- The DevTools component reads from the nearest `QueryClient` via context.
- It renders a floating toggle button (the TanStack logo) fixed to the screen corner by default.
- The panel opens as an overlay; it does not displace page layout.

---

### Production Exclusion

By default, `ReactQueryDevtools` renders only when `process.env.NODE_ENV === 'development'`. No manual conditional is required in most bundler setups.

[Inference] If your bundler does not set `NODE_ENV` correctly (e.g., custom build pipelines), the DevTools may render in production. Verify your build configuration independently.

For explicit control, use lazy loading via dynamic import to guarantee the module is excluded from production bundles:

```tsx
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { lazy, Suspense } from 'react'

const ReactQueryDevtools =
  process.env.NODE_ENV === 'production'
    ? () => null
    : lazy(() =>
        import('@tanstack/react-query-devtools').then((mod) => ({
          default: mod.ReactQueryDevtools,
        }))
      )

const queryClient = new QueryClient()

function App() {
  return (
    <QueryClientProvider client={queryClient}>
      <YourApp />
      <Suspense fallback={null}>
        <ReactQueryDevtools />
      </Suspense>
    </QueryClientProvider>
  )
}
```

This approach excludes the DevTools module from the production bundle at the tree-shaking level, depending on bundler support.

---

### Props Reference

| Prop | Type | Default | Description |
|---|---|---|---|
| `initialIsOpen` | `boolean` | `false` | Opens the panel on first render |
| `buttonPosition` | `'top-left' \| 'top-right' \| 'bottom-left' \| 'bottom-right'` | `'bottom-left'` | Position of the floating toggle button |
| `position` | `'top' \| 'bottom' \| 'left' \| 'right'` | `'bottom'` | Edge where the panel docks |
| `client` | `QueryClient` | Context client | Override the QueryClient to inspect |
| `errorTypes` | `ErrorType[]` | `undefined` | Register custom error types for toggling query errors |
| `styleNonce` | `string` | `undefined` | CSP nonce for injected style tags |

**Example — open by default, docked to the right:**

```tsx
<ReactQueryDevtools initialIsOpen={true} position="right" buttonPosition="top-right" />
```

---

### Panel Anatomy

The DevTools panel is divided into several regions:

```
┌─────────────────────────────────────────────────────┐
│  🔍 Filter queries       [Sort] [Active] [Inactive]  │
├──────────────┬──────────────────────────────────────┤
│              │  Query Key: ['todos', { page: 1 }]   │
│  Query List  │  Status: fresh                       │
│              │  Last Updated: 2s ago                │
│  ['todos']   │  Observers: 2                        │
│  ['user',1]  │                                      │
│  ['posts']   │  [Refetch] [Invalidate] [Reset]      │
│              │  [Remove]  [Trigger Loading]         │
│              │  [Trigger Error]                     │
├──────────────┴──────────────────────────────────────┤
│  Data Explorer (JSON tree)                          │
└─────────────────────────────────────────────────────┘
```

#### Query List

- Each entry shows the serialized query key and a colored status badge.
- Clicking a query selects it and populates the detail pane.

#### Status Badges

| Badge | Meaning |
|---|---|
| `fresh` | Data is within `staleTime`; no background refetch scheduled |
| `stale` | Data has exceeded `staleTime`; eligible for refetch on next trigger |
| `fetching` | Network request is in progress |
| `paused` | Fetch is paused (offline mode or `networkMode` config) |
| `inactive` | No active observers (no mounted components consuming this query) |

#### Detail Pane Actions

| Action | Effect |
|---|---|
| **Refetch** | Triggers an immediate background refetch |
| **Invalidate** | Marks query stale and triggers refetch if observed |
| **Reset** | Removes cached data and resets to initial state |
| **Remove** | Deletes the query from the cache entirely |
| **Trigger Loading** | Forces the query into a loading state (for UI testing) |
| **Trigger Error** | Forces an error state using registered `errorTypes` |

---

### Triggering Custom Errors

The `errorTypes` prop accepts an array of error descriptors, each with a `name` and an `initializer` function. This lets you simulate specific error conditions from the panel without modifying application code.

```tsx
<ReactQueryDevtools
  errorTypes={[
    {
      name: 'Unauthorized',
      initializer: (query) => {
        const error = new Error('401 Unauthorized')
        error.name = 'UnauthorizedError'
        return error
      },
    },
    {
      name: 'Server Error',
      initializer: () => new Error('500 Internal Server Error'),
    },
  ]}
/>
```

After registration, each named error appears as a selectable option in the **Trigger Error** dropdown within the detail pane.

---

### Using a Custom QueryClient

When building multi-client setups or testing isolated subtrees, the `client` prop overrides the context-provided client:

```tsx
const debugClient = new QueryClient()

<ReactQueryDevtools client={debugClient} />
```

[Inference] This is primarily useful in testing harnesses or Storybook environments where the component tree's `QueryClientProvider` uses a different client than the one you want to inspect.

---

### DevTools in Non-React Frameworks

TanStack Query supports Vue, Solid, Svelte, and Angular adapters. Each has a corresponding DevTools package.

| Framework | Package |
|---|---|
| React | `@tanstack/react-query-devtools` |
| Vue | `@tanstack/vue-query-devtools` |
| Solid | `@tanstack/solid-query-devtools` |
| Svelte | `@tanstack/svelte-query-devtools` (community-maintained) [Unverified] |
| Angular | DevTools support is limited or unofficial [Unverified] |

The API surface (props, panel behavior) is [Inference] broadly consistent across official adapters, but differences may exist. Consult each adapter's documentation independently.

---

### Embedding the DevTools Panel Inline

For custom layouts or when the floating overlay is undesirable, use the headless `TanStackRouterDevtoolsPanel` or for Query specifically, the `ReactQueryDevtoolsPanel` component:

```tsx
import { ReactQueryDevtoolsPanel } from '@tanstack/react-query-devtools'

function DebugSidebar() {
  return (
    <aside style={{ width: '400px', height: '100vh', overflow: 'auto' }}>
      <ReactQueryDevtoolsPanel />
    </aside>
  )
}
```

**Key Points:**
- `ReactQueryDevtoolsPanel` renders only the panel, without the floating toggle button.
- Useful for embedding the inspector as a permanent sidebar in development layouts.
- It still reads from the nearest `QueryClient` context.

---

### Common Patterns and Tips

**Observing stale time behavior:**
Set a visible `staleTime` and watch the badge transition from `fresh` → `stale` in real time within the DevTools panel. This is useful for validating cache configuration against intended behavior.

**Identifying inactive queries:**
Queries that remain `inactive` after navigation may indicate missing query key consistency or components unmounting earlier than expected.

**Simulating offline behavior:**
Combine DevTools with browser devtools network throttling. Queries in `paused` state will appear in the panel, confirming that `networkMode: 'online'` is functioning as configured.

**Using `initialIsOpen` during active development:**
Set `initialIsOpen={true}` during focused debugging sessions to avoid repeatedly reopening the panel. Remove or revert before committing.

---