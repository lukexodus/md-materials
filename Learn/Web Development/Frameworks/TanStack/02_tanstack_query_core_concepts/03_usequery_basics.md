## useQuery Basics

### Overview

`useQuery` is the primary hook for fetching and caching server data in TanStack Query. It handles the full lifecycle of a data request: initiating the fetch, tracking loading and error states, caching the result, and determining when data needs to be refreshed.

---

### Minimal Usage

```tsx
import { useQuery } from '@tanstack/react-query'

function Todos() {
  const { data, isPending, isError } = useQuery({
    queryKey: ['todos'],
    queryFn: () => fetch('/api/todos').then(res => res.json()),
  })

  if (isPending) return <p>Loading...</p>
  if (isError) return <p>Something went wrong.</p>

  return <ul>{data.map(todo => <li key={todo.id}>{todo.title}</li>)}</ul>
}
```

The two required fields are `queryKey` and `queryFn`. Everything else is optional configuration.

---

### queryKey

The `queryKey` is an array that uniquely identifies a query in the cache. TanStack Query uses it to store, retrieve, and invalidate cached data.

```ts
// Static key — same result every time
useQuery({ queryKey: ['todos'], queryFn: fetchTodos })

// Dynamic key — varies by parameter
useQuery({ queryKey: ['todo', id], queryFn: () => fetchTodo(id) })

// Multi-segment key — useful for namespacing
useQuery({ queryKey: ['projects', projectId, 'tasks'], queryFn: fetchTasks })
```

**Key Points:**
- Keys are serialized for comparison. `['todo', 1]` and `['todo', 2]` are treated as distinct cache entries.
- Objects inside the key are compared by value, not reference. `{ status: 'active' }` and `{ status: 'active' }` are considered equal.
- Order within the key matters. `['todo', id]` and `[id, 'todo']` are different keys.
- All variables used inside `queryFn` that affect the result should be included in the key. This keeps the cache accurate.

**Example — including filter state in the key:**

```ts
const { data } = useQuery({
  queryKey: ['todos', { status, page }],
  queryFn: () => fetchTodos({ status, page }),
})
```

> [Inference] Omitting variables from the key that are used in `queryFn` is likely to cause stale or incorrect cache hits. Behavior may vary depending on when those variables change relative to renders.

---

### queryFn

`queryFn` is the function that performs the actual data fetch. It must return a Promise that either resolves with data or rejects with an error.

```ts
// Using fetch
queryFn: () => fetch('/api/todos').then(res => res.json())

// Using axios
queryFn: () => axios.get('/api/todos').then(res => res.data)

// Async/await form
queryFn: async () => {
  const res = await fetch('/api/todos')
  if (!res.ok) throw new Error('Network response was not ok')
  return res.json()
}
```

**Key Points:**
- TanStack Query determines success or failure by whether the Promise resolves or rejects. A resolved Promise with an HTTP error status (e.g., 404) is not automatically treated as an error — you must throw explicitly.
- The `queryFn` receives a `QueryFunctionContext` object as its argument, which includes the `queryKey` and an `AbortSignal` for cancellation.

**Using the context argument:**

```ts
useQuery({
  queryKey: ['todo', id],
  queryFn: ({ queryKey, signal }) => {
    const [, todoId] = queryKey
    return fetch(`/api/todos/${todoId}`, { signal }).then(res => res.json())
  },
})
```

Passing `signal` to `fetch` allows TanStack Query to cancel in-flight requests when a query becomes obsolete.

---

### Return Values

`useQuery` returns an object with status fields, data, and metadata. The most commonly used fields:

| Field | Type | Description |
|---|---|---|
| `data` | `TData \| undefined` | The resolved result of `queryFn` |
| `isPending` | `boolean` | No data yet; query has not resolved |
| `isFetching` | `boolean` | A fetch is currently in progress |
| `isSuccess` | `boolean` | Data is available |
| `isError` | `boolean` | The last fetch threw or rejected |
| `error` | `TError \| null` | The error object if `isError` is true |
| `status` | `'pending' \| 'error' \| 'success'` | Derived status string |
| `fetchStatus` | `'fetching' \| 'paused' \| 'idle'` | Current fetch activity |
| `refetch` | `function` | Manually trigger a refetch |

**Key Points:**
- `isPending` and `isFetching` are distinct. A query can be `isFetching: true` while `isPending: false` — this happens during a background refresh when cached data already exists.
- `status` and `fetchStatus` are orthogonal. A query can be `status: 'success'` and `fetchStatus: 'fetching'` simultaneously.

---

### status vs fetchStatus

This distinction is a common source of confusion.

```
status       — reflects the state of the data
fetchStatus  — reflects whether a network request is active
```

<svg viewBox="0 0 640 260" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="13">
  <rect width="640" height="260" fill="#1e1e2e" rx="10"/>

  <!-- Headers -->
  <text x="30" y="36" fill="#cba6f7" font-weight="bold" font-size="14">status</text>
  <text x="220" y="36" fill="#89dceb" font-weight="bold" font-size="14">fetchStatus</text>
  <text x="420" y="36" fill="#a6e3a1" font-weight="bold" font-size="14">Meaning</text>

  <!-- Divider -->
  <line x1="20" y1="48" x2="620" y2="48" stroke="#45475a" stroke-width="1"/>

  <!-- Row 1 -->
  <text x="30" y="74" fill="#f5c2e7">pending</text>
  <text x="220" y="74" fill="#f5c2e7">fetching</text>
  <text x="420" y="74" fill="#cdd6f4">Initial fetch in progress</text>

  <!-- Row 2 -->
  <text x="30" y="110" fill="#f5c2e7">success</text>
  <text x="220" y="110" fill="#f5c2e7">idle</text>
  <text x="420" y="110" fill="#cdd6f4">Data in cache, no fetch active</text>

  <!-- Row 3 -->
  <text x="30" y="146" fill="#f5c2e7">success</text>
  <text x="220" y="146" fill="#f5c2e7">fetching</text>
  <text x="420" y="146" fill="#cdd6f4">Background refresh in progress</text>

  <!-- Row 4 -->
  <text x="30" y="182" fill="#f5c2e7">error</text>
  <text x="220" y="182" fill="#f5c2e7">idle</text>
  <text x="420" y="182" fill="#cdd6f4">Fetch failed, no retry pending</text>

  <!-- Row 5 -->
  <text x="30" y="218" fill="#f5c2e7">pending</text>
  <text x="220" y="218" fill="#f5c2e7">paused</text>
  <text x="420" y="218" fill="#cdd6f4">Offline; fetch queued</text>
</svg>

---

### Common Configuration Options

```ts
useQuery({
  queryKey: ['todos'],
  queryFn: fetchTodos,

  staleTime: 1000 * 60 * 5,   // Data stays fresh for 5 minutes
  gcTime: 1000 * 60 * 10,     // Cache retained 10 minutes after unmount
  retry: 3,                    // Retry failed queries up to 3 times
  retryDelay: 1000,            // 1 second between retries (or a function)
  refetchOnWindowFocus: true,  // Refetch when window regains focus
  refetchOnMount: true,        // Refetch when component mounts
  enabled: !!userId,           // Only run query when condition is true
  placeholderData: [],         // Shown while data is pending
  select: (data) => data.items, // Transform data before returning
})
```

**Key Points:**
- `staleTime` controls how long data is considered fresh. While fresh, no background refetch is triggered on mount or focus.
- `gcTime` (formerly `cacheTime` in v4) controls how long unused cache entries are retained in memory after all observers unmount.
- `enabled: false` prevents the query from running. Useful for dependent queries.
- `select` transforms the data returned to the component without affecting the raw cached value.

---

### Dependent Queries

Use `enabled` to delay a query until prerequisite data is available:

```ts
const { data: user } = useQuery({
  queryKey: ['user', userId],
  queryFn: () => fetchUser(userId),
})

const { data: orders } = useQuery({
  queryKey: ['orders', user?.id],
  queryFn: () => fetchOrders(user.id),
  enabled: !!user?.id,
})
```

> [Inference] When `enabled` is `false`, the query stays in `pending` status with `fetchStatus: 'idle'` until the condition becomes truthy. Actual state transitions may vary — verify against the version in use.

---

### The select Option

`select` lets you derive a transformed value from the raw cached data:

```ts
const { data: todoTitles } = useQuery({
  queryKey: ['todos'],
  queryFn: fetchTodos,
  select: (data) => data.map(todo => todo.title),
})
```

**Key Points:**
- The raw data in the cache is not modified by `select`.
- Multiple components can use the same `queryKey` with different `select` transforms — each gets its own derived value.
- [Inference] `select` may help reduce unnecessary re-renders if the derived value is stable across fetches, since TanStack Query performs a shallow comparison on the selected result. Behavior may vary.

---

### refetch

The `refetch` function returned by `useQuery` manually triggers a fetch regardless of staleness:

```ts
const { data, refetch } = useQuery({
  queryKey: ['todos'],
  queryFn: fetchTodos,
})

return <button onClick={() => refetch()}>Reload</button>
```

**Key Points:**
- `refetch` bypasses `staleTime`. It always initiates a new request.
- For cache-wide invalidation (e.g., after a mutation), `queryClient.invalidateQueries()` is generally preferred over calling `refetch` directly on individual queries.

---

### Summary

| Concept | Purpose |
|---|---|
| `queryKey` | Uniquely identifies and scopes cached data |
| `queryFn` | Performs the fetch; must resolve or reject |
| `data` | The cached result, available after success |
| `isPending` | True when no data has resolved yet |
| `isFetching` | True whenever a network request is active |
| `staleTime` | Duration data is considered fresh |
| `gcTime` | Duration cache is retained after unmount |
| `enabled` | Conditionally suppresses query execution |
| `select` | Transforms data for the component without altering the cache |