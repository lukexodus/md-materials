## TanStack Query — Core Concepts — Query Status: Loading, Error, Success

---

### Overview

Every query managed by TanStack Query has an associated status that reflects the current state of its data lifecycle. Understanding these statuses — and the auxiliary flags derived from them — is essential for building correct loading states, error boundaries, and data-driven UI.

TanStack Query v5 models query state using **two orthogonal axes**:

- **`status`** — reflects whether data exists in cache
- **`fetchStatus`** — reflects whether the query function is currently running

These two fields replace the single-axis model from earlier versions and must be read together for accurate state interpretation.

---

### The `status` Field

`status` describes the data availability state of the query.

| Value | Meaning |
|---|---|
| `'pending'` | No cached data exists yet |
| `'error'` | The last fetch attempt failed; no valid data |
| `'success'` | Data has been successfully fetched and cached |

```ts
const { status, data, error } = useQuery({
  queryKey: ['todos'],
  queryFn: fetchTodos,
})

if (status === 'pending') return <p>Loading...</p>
if (status === 'error') return <p>Error occurred</p>
return <TodoList data={data} />
```

**Key Points**
- `status` transitions are driven by cache state, not network activity
- A query can be `'success'` while simultaneously refetching in the background
- In v4 and earlier, the pending state was called `'loading'` — this was renamed to `'pending'` in v5 to reduce confusion with the `isLoading` flag

---

### The `fetchStatus` Field

`fetchStatus` describes whether the query function is currently executing.

| Value | Meaning |
|---|---|
| `'fetching'` | Query function is actively running |
| `'paused'` | Query wanted to fetch but was paused (e.g., no network) |
| `'idle'` | Query function is not running |

**Key Points**
- `fetchStatus` is independent of `status` — any combination is possible
- A query with `status: 'success'` and `fetchStatus: 'fetching'` is a background refetch
- A query with `status: 'pending'` and `fetchStatus: 'idle'` is disabled and has never fetched
- `fetchStatus: 'paused'` requires the `networkMode` option to be set appropriately (default is `'online'`)

---

### How `status` and `fetchStatus` Combine

The two-axis model produces meaningful combinations that a single status field cannot express.

```
status: 'pending'  + fetchStatus: 'fetching' → Initial load in progress
status: 'pending'  + fetchStatus: 'idle'     → Disabled, never fetched
status: 'pending'  + fetchStatus: 'paused'   → Waiting for network (first fetch)
status: 'success'  + fetchStatus: 'fetching' → Background refetch
status: 'success'  + fetchStatus: 'idle'     → Data available, at rest
status: 'error'    + fetchStatus: 'fetching' → Retrying after failure
status: 'error'    + fetchStatus: 'idle'     → Failed, no active retry
```

A diagram of the primary transitions:

<svg viewBox="0 0 720 400" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="13">
  <!-- Nodes -->
  <!-- Pending/Idle (disabled) -->
  <rect x="20" y="160" width="180" height="60" rx="8" fill="#1e293b" stroke="#64748b" stroke-width="1.5"/>
  <text x="110" y="185" text-anchor="middle" fill="#94a3b8" font-size="11">status</text>
  <text x="110" y="200" text-anchor="middle" fill="#f8fafc" font-weight="bold">'pending'</text>
  <text x="110" y="215" text-anchor="middle" fill="#64748b" font-size="11">fetchStatus: 'idle'</text>

  <!-- Pending/Fetching (initial load) -->
  <rect x="270" y="60" width="180" height="60" rx="8" fill="#1e3a5f" stroke="#3b82f6" stroke-width="1.5"/>
  <text x="360" y="85" text-anchor="middle" fill="#93c5fd" font-size="11">status</text>
  <text x="360" y="100" text-anchor="middle" fill="#f8fafc" font-weight="bold">'pending'</text>
  <text x="360" y="115" text-anchor="middle" fill="#93c5fd" font-size="11">fetchStatus: 'fetching'</text>

  <!-- Success/Idle -->
  <rect x="520" y="160" width="180" height="60" rx="8" fill="#14532d" stroke="#22c55e" stroke-width="1.5"/>
  <text x="610" y="185" text-anchor="middle" fill="#86efac" font-size="11">status</text>
  <text x="610" y="200" text-anchor="middle" fill="#f8fafc" font-weight="bold">'success'</text>
  <text x="610" y="215" text-anchor="middle" fill="#86efac" font-size="11">fetchStatus: 'idle'</text>

  <!-- Success/Fetching (background refetch) -->
  <rect x="520" y="60" width="180" height="60" rx="8" fill="#14532d" stroke="#86efac" stroke-width="1.5" stroke-dasharray="5,3"/>
  <text x="610" y="85" text-anchor="middle" fill="#86efac" font-size="11">status</text>
  <text x="610" y="100" text-anchor="middle" fill="#f8fafc" font-weight="bold">'success'</text>
  <text x="610" y="115" text-anchor="middle" fill="#86efac" font-size="11">fetchStatus: 'fetching'</text>

  <!-- Error/Idle -->
  <rect x="270" y="300" width="180" height="60" rx="8" fill="#450a0a" stroke="#ef4444" stroke-width="1.5"/>
  <text x="360" y="325" text-anchor="middle" fill="#fca5a5" font-size="11">status</text>
  <text x="360" y="340" text-anchor="middle" fill="#f8fafc" font-weight="bold">'error'</text>
  <text x="360" y="355" text-anchor="middle" fill="#fca5a5" font-size="11">fetchStatus: 'idle'</text>

  <!-- Arrows -->
  <!-- disabled → initial fetch -->
  <line x1="200" y1="175" x2="268" y2="105" stroke="#64748b" stroke-width="1.5" marker-end="url(#arr)"/>
  <text x="218" y="133" fill="#64748b" font-size="10">enabled</text>

  <!-- initial fetch → success -->
  <line x1="450" y1="90" x2="518" y2="90" stroke="#3b82f6" stroke-width="1.5" marker-end="url(#arr)"/>
  <text x="460" y="82" fill="#3b82f6" font-size="10">resolves</text>

  <!-- initial fetch → error -->
  <line x1="360" y1="120" x2="360" y2="298" stroke="#ef4444" stroke-width="1.5" marker-end="url(#arr)"/>
  <text x="366" y="215" fill="#ef4444" font-size="10">rejects</text>

  <!-- success/idle → success/fetching (refetch) -->
  <path d="M610 160 Q610 130 610 120" stroke="#22c55e" stroke-width="1.5" fill="none" marker-end="url(#arr)" stroke-dasharray="4,3"/>
  <text x="616" y="145" fill="#22c55e" font-size="10">refetch</text>

  <!-- success/fetching → success/idle -->
  <line x1="520" y1="100" x2="360" y2="100" stroke="#64748b" stroke-width="1" stroke-dasharray="3,3"/>

  <!-- error → fetching (retry) -->
  <line x1="270" y1="320" x2="202" y2="205" stroke="#f97316" stroke-width="1.5" marker-end="url(#arr)"/>
  <text x="192" y="265" fill="#f97316" font-size="10">retry</text>

  <!-- Arrow marker -->
  <defs>
    <marker id="arr" markerWidth="8" markerHeight="8" refX="6" refY="3" orient="auto">
      <path d="M0,0 L0,6 L8,3 z" fill="#94a3b8"/>
    </marker>
  </defs>
</svg>

---

### Boolean Convenience Flags

TanStack Query derives several boolean flags from `status` and `fetchStatus`. These are the values most commonly used in component rendering logic.

| Flag | Equivalent to | Notes |
|---|---|---|
| `isPending` | `status === 'pending'` | True when no cached data exists |
| `isSuccess` | `status === 'success'` | True when data is available |
| `isError` | `status === 'error'` | True when last fetch failed |
| `isFetching` | `fetchStatus === 'fetching'` | True during any active fetch |
| `isLoading` | `isPending && isFetching` | True only on the very first fetch |
| `isRefetching` | `isFetching && !isPending` | True only during background refetches |
| `isPaused` | `fetchStatus === 'paused'` | True when fetch is awaiting network |

**Key Points**
- `isLoading` is the v5 replacement for what `isLoading` meant in v4 — an initial fetch in progress
- `isRefetching` is false during an initial load; it is only true when data already exists and a new fetch is running
- `isFetching` is true in both initial load and background refetch scenarios — use it to show any network activity indicator

---

### Rendering Patterns

#### Pattern 1 — Sequential status checks

```ts
const { status, data, error } = useQuery({
  queryKey: ['todos'],
  queryFn: fetchTodos,
})

if (status === 'pending') return <LoadingSpinner />
if (status === 'error') return <ErrorMessage error={error} />
return <TodoList todos={data} />
```

After the two early returns, TypeScript narrows `data` to the resolved type — `undefined` is excluded.

#### Pattern 2 — Boolean flags

```ts
const { isPending, isError, isSuccess, data, error } = useQuery({
  queryKey: ['todos'],
  queryFn: fetchTodos,
})

if (isPending) return <LoadingSpinner />
if (isError) return <ErrorMessage error={error} />
if (isSuccess) return <TodoList todos={data} />
```

#### Pattern 3 — Show stale data during background refetch

```ts
const { data, isRefetching, isError } = useQuery({
  queryKey: ['todos'],
  queryFn: fetchTodos,
})

return (
  <div>
    {isRefetching && <RefetchIndicator />}
    {isError && <ErrorBanner />}
    {data && <TodoList todos={data} />}
  </div>
)
```

**Key Points**
- When `isRefetching` is true, `data` still holds the previous successful result — the UI can display stale data while a fresh fetch runs
- This is one of the core UX advantages of TanStack Query's caching model

#### Pattern 4 — Distinguishing disabled from loading

```ts
const { isPending, isFetching } = useQuery({
  queryKey: ['projects', user?.id],
  queryFn: () => fetchProjects(user!.id),
  enabled: !!user,
})

if (isPending && isFetching) return <p>Fetching projects…</p>
if (isPending && !isFetching) return <p>Waiting for user…</p>
```

---

### The `error` Field

When `status === 'error'`, the `error` field contains the thrown value from the query function.

```ts
const { isError, error } = useQuery<Todo[], Error>({
  queryKey: ['todos'],
  queryFn: fetchTodos,
})

if (isError) {
  return <p>Failed: {error.message}</p>
}
```

**Key Points**
- `error` is typed as `TError | null` — it is `null` when the query is not in error state
- The default `TError` type in v5 is `Error`; earlier versions used `unknown`
- [Inference] Casting `error` to `Error` without the generic type parameter may cause TypeScript to infer `unknown`, requiring a type guard before accessing `.message`
- TanStack Query retries failed queries before setting `status: 'error'` — by default, up to 3 retries with exponential backoff

---

### Retry Behavior and Error State Timing

A query does not immediately enter `status: 'error'` on the first rejected Promise. The default retry policy delays error state.

```ts
useQuery({
  queryKey: ['todos'],
  queryFn: fetchTodos,
  retry: 3,             // retry up to 3 times (default)
  retryDelay: 1000,     // fixed 1s delay (default is exponential)
})
```

**Key Points**
- While retrying, `fetchStatus` is `'fetching'` and `status` remains `'pending'` (if no prior data) or `'success'` (if prior data exists)
- `status` only transitions to `'error'` after all retries are exhausted
- Setting `retry: false` causes immediate error state on first rejection
- `retryDelay` can accept a function: `(attemptIndex) => Math.min(1000 * 2 ** attemptIndex, 30000)` is the default exponential backoff

---

### `isStale` and Background Refetch Context

`isStale` is a related flag that indicates whether cached data is considered outdated according to `staleTime`.

```ts
const { data, isStale, isRefetching } = useQuery({
  queryKey: ['todos'],
  queryFn: fetchTodos,
  staleTime: 60 * 1000,
})
```

**Key Points**
- Stale data is not automatically removed — it remains in cache and is served to components
- Background refetches are triggered when a stale query is accessed (e.g., window refocus, component mount)
- `isStale: true` does not mean a refetch is in progress — only `isFetching` or `isRefetching` indicates that
- `staleTime: Infinity` disables automatic staleness — data is considered fresh indefinitely

---

### Global Status Observation

The `useIsFetching` and `useIsRestoring` hooks provide application-level fetch state without being tied to a specific query.

```ts
import { useIsFetching } from '@tanstack/react-query'

function GlobalLoadingIndicator() {
  const isFetching = useIsFetching()
  return isFetching > 0 ? <Spinner /> : null
}
```

**Key Points**
- `useIsFetching` returns the count of currently fetching queries across the entire `QueryClient`
- Useful for global loading bars or indicators outside of individual components
- Does not distinguish between initial loads and background refetches

---

### TypeScript Narrowing with Status

Because `data` is typed as `TData | undefined`, TypeScript requires narrowing before safe access. Status checks perform this narrowing.

```ts
const { status, data } = useQuery<Todo[]>({
  queryKey: ['todos'],
  queryFn: fetchTodos,
})

// Without narrowing — data is Todo[] | undefined
// data.map(...)  ❌ TypeScript error: data may be undefined

if (status === 'success') {
  // data is narrowed to Todo[] here
  data.map(todo => todo.title)  // ✅
}
```

**Key Points**
- The `isSuccess` flag does not currently narrow `data` in all TypeScript configurations — using `status === 'success'` or an explicit `if (data)` guard is more reliable for narrowing
- [Inference] Future TypeScript improvements or TanStack Query type updates may improve narrowing via boolean flags — consult current type definitions

---

### v4 vs v5 Status Changes

| Aspect | v4 | v5 |
|---|---|---|
| Pending state name | `'loading'` | `'pending'` |
| `isLoading` meaning | Any active fetch | First fetch only |
| `isInitialLoading` | Separate flag | Replaced by `isLoading` |
| Error type default | `unknown` | `Error` |
| Disabled query status | `status: 'loading'` | `status: 'pending'`, `fetchStatus: 'idle'` |

---

**Conclusion**

Query status in TanStack Query v5 is a two-dimensional model: `status` tracks data availability and `fetchStatus` tracks network activity. Reading both together — directly or via derived boolean flags — is necessary to accurately represent loading, background refresh, disabled, and error states in UI. Relying on a single flag such as `isPending` without considering `fetchStatus` is a common source of subtle rendering bugs. Behavior described here reflects TanStack Query v5; earlier versions differ in status naming and flag semantics.