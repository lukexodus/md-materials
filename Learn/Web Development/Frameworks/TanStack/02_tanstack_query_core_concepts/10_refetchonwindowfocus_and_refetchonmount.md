## TanStack Query — refetchOnWindowFocus and refetchOnMount

### Overview

`refetchOnWindowFocus` and `refetchOnMount` are automatic refetch triggers built into TanStack Query. They determine whether a query re-fetches based on user interaction with the browser window and component lifecycle events, respectively. Both are gated by `staleTime` — they only initiate a fetch if the query's data is already stale.

---

### refetchOnWindowFocus

When the browser window or tab regains focus — for example, after a user switches away and returns — TanStack Query can automatically refetch active stale queries. This behavior is controlled by `refetchOnWindowFocus`.

**Default value:** `true`

```ts
useQuery({
  queryKey: ['inbox'],
  queryFn: fetchInbox,
  refetchOnWindowFocus: true, // default
})
```

**Key Points**
- Only triggers if the query's data is stale at the time of the focus event
- Only affects **active** queries (those with at least one mounted subscriber)
- Fires on the `visibilitychange` browser event and, as a fallback, `focus` on the `window` object
- [Inference] The exact event used may vary across browser environments; behavior is not guaranteed to be identical in all contexts

#### Accepted Values

`refetchOnWindowFocus` accepts a boolean or a function returning a boolean.

```ts
// Always refetch on focus, regardless of staleTime
refetchOnWindowFocus: true

// Never refetch on focus
refetchOnWindowFocus: false

// Conditionally refetch based on query state
refetchOnWindowFocus: (query) => query.state.errorUpdateCount > 0
```

The function form receives the `Query` instance, allowing fine-grained control based on query state at the time of the focus event.

#### Global Configuration

```ts
const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      refetchOnWindowFocus: false, // disable globally
    },
  },
})
```

Per-query values override the global default.

#### Custom Focus Detection

TanStack Query exposes `focusManager` for environments where the default focus detection is unsuitable — React Native, Electron, or test environments are common cases.

```ts
import { focusManager } from '@tanstack/react-query'

// Override focus detection entirely
focusManager.setEventListener((handleFocus) => {
  window.addEventListener('focus', handleFocus)
  return () => window.removeEventListener('focus', handleFocus)
})
```

[Inference] This is primarily relevant when the default `visibilitychange` / `focus` events are unavailable or behave unexpectedly in non-browser runtimes. Verify against your platform's specifics.

---

### refetchOnMount

`refetchOnMount` controls whether a query refetches when a component that uses it **mounts**. This applies to both initial mounts and remounts after unmounting.

**Default value:** `true`

```ts
useQuery({
  queryKey: ['profile'],
  queryFn: fetchProfile,
  refetchOnMount: true, // default
})
```

**Key Points**
- Triggers when a component subscribes to a query for the first time in a render cycle
- If data is fresh at mount time, no refetch occurs regardless of the setting value (when set to `true`)
- If set to `'always'`, a refetch is triggered on every mount regardless of staleness
- If set to `false`, no refetch on mount — the cached value is used as-is until another trigger fires

#### Accepted Values

```ts
// Refetch on mount only if data is stale (default)
refetchOnMount: true

// Never refetch on mount; use cache as-is
refetchOnMount: false

// Always refetch on mount, even if data is fresh
refetchOnMount: 'always'
```

The `'always'` option bypasses `staleTime` — it is the one case where staleness does not gate the refetch.

#### Practical Example — Disabling Mount Refetch

Useful when a parent already fetches and a child component shares the same query key. The child can safely opt out of redundant refetches.

```ts
// Parent fetches
useQuery({ queryKey: ['user'], queryFn: fetchUser })

// Child reads the same cache without triggering a refetch
useQuery({
  queryKey: ['user'],
  queryFn: fetchUser,
  refetchOnMount: false,
})
```

[Inference] Both hooks share the same cache entry due to the matching query key. Whether deduplication occurs at the network level depends on timing and the current query state; behavior may vary.

---

### How staleTime Gates Both Triggers

The relationship between `staleTime` and these two options is central to understanding when refetches actually occur.

```
Window focus event fires
OR
Component mounts
        │
        ▼
  Is data stale?
  (staleTime elapsed?)
        │
   ┌────┴────┐
  YES        NO
   │          │
   ▼          ▼
Refetch    No refetch
triggered  (fresh data
           returned as-is)
```

**Exception:** `refetchOnMount: 'always'` bypasses the staleness check entirely.

---

### Interaction Between the Two Options

Both options can be active simultaneously. They are evaluated independently — a focus event and a mount event each check the staleness state at the time they occur.

| Scenario | refetchOnMount | refetchOnWindowFocus | Result |
|---|---|---|---|
| Component mounts, data fresh | `true` | `true` | No refetch |
| Component mounts, data stale | `true` | `true` | Refetch on mount |
| Window refocused, data stale | `true` | `true` | Refetch on focus |
| Component mounts, data fresh | `'always'` | `true` | Refetch on mount |
| Both disabled | `false` | `false` | No automatic refetch |

---

### Disabling in Test Environments

Automatic refetches triggered by focus and mount events can cause flaky behavior in test environments. A common pattern is to disable both globally in test setup.

```ts
const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      refetchOnWindowFocus: false,
      refetchOnMount: false,
      retry: false,
    },
  },
})
```

[Inference] This reduces non-deterministic fetches during tests, though the appropriate configuration depends on what behavior is under test. Disabling globally may mask regressions in fetch logic.

---

### Observability via Devtools

TanStack Query Devtools will display refetch events as they occur, including the trigger source where available. This is the recommended way to confirm that `refetchOnMount` and `refetchOnWindowFocus` are behaving as configured in a given environment.

---

### Summary Table

| Option | Default | Staleness Required | Accepts `'always'` |
|---|---|---|---|
| `refetchOnMount` | `true` | Yes (unless `'always'`) | Yes |
| `refetchOnWindowFocus` | `true` | Yes | No |

---

**Conclusion**

`refetchOnWindowFocus` and `refetchOnMount` are convenience triggers designed to keep data current in response to natural user behavior. Both are gated by `staleTime` under normal configuration, meaning they work in concert with — not independently of — the staleness model. Understanding which events fire them, when staleness is checked, and how to disable or customize them is essential for controlling fetch behavior across different environments and use cases.