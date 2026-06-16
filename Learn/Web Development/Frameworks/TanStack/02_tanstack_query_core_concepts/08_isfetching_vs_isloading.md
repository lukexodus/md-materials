## TanStack Query — Core Concepts — `isFetching` vs `isLoading`

---

### Why This Distinction Matters

`isFetching` and `isLoading` are two of the most frequently misread flags in TanStack Query, particularly for developers migrating from v4 to v5. They appear similar but answer fundamentally different questions about query state. Conflating them produces incorrect loading indicators — either showing spinners when data is already available, or missing them during background refetches.

---

### Definitions

**`isFetching`**
Derived from `fetchStatus === 'fetching'`. True whenever the query function is actively executing — regardless of whether cached data exists.

**`isLoading`**
Derived from `isPending && isFetching`. True only when the query is on its **first ever fetch** — no cached data exists and the query function is currently running.

```ts
const { isFetching, isLoading } = useQuery({
  queryKey: ['todos'],
  queryFn: fetchTodos,
})
```

---

### Side-by-Side Comparison

| Scenario | `isFetching` | `isLoading` |
|---|---|---|
| First fetch, in progress | `true` | `true` |
| First fetch, complete | `false` | `false` |
| Background refetch in progress | `true` | `false` |
| Background refetch complete | `false` | `false` |
| Query disabled, never fetched | `false` | `false` |
| Retrying after error (no prior data) | `true` | `true` |
| Retrying after error (prior data exists) | `true` | `false` |

**Key Points**
- `isLoading` is always a subset of `isFetching` — whenever `isLoading` is `true`, `isFetching` is also `true`
- The reverse is not true — `isFetching` can be `true` while `isLoading` is `false`

---

### The Core Difference Illustrated

<svg viewBox="0 0 700 340" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="12">
  <defs>
    <marker id="arr2" markerWidth="8" markerHeight="6" refX="6" refY="3" orient="auto">
      <path d="M0,0 L0,6 L8,3 z" fill="#64748b"/>
    </marker>
  </defs>

  <!-- Timeline axis -->
  <line x1="60" y1="290" x2="660" y2="290" stroke="#475569" stroke-width="1.5" marker-end="url(#arr2)"/>
  <text x="665" y="294" fill="#64748b" font-size="11">time</text>

  <!-- Phase labels -->
  <text x="110" y="22" text-anchor="middle" fill="#94a3b8" font-size="11">Initial fetch</text>
  <text x="320" y="22" text-anchor="middle" fill="#94a3b8" font-size="11">Data cached</text>
  <text x="530" y="22" text-anchor="middle" fill="#94a3b8" font-size="11">Background refetch</text>

  <!-- Phase dividers -->
  <line x1="210" y1="15" x2="210" y2="290" stroke="#334155" stroke-width="1" stroke-dasharray="4,3"/>
  <line x1="430" y1="15" x2="430" y2="290" stroke="#334155" stroke-width="1" stroke-dasharray="4,3"/>

  <!-- isFetching row -->
  <text x="55" y="100" text-anchor="end" fill="#93c5fd" font-size="12" font-weight="bold">isFetching</text>
  <!-- true block: initial fetch -->
  <rect x="62" y="78" width="146" height="28" rx="4" fill="#1e3a5f" stroke="#3b82f6" stroke-width="1.5"/>
  <text x="135" y="97" text-anchor="middle" fill="#93c5fd" font-weight="bold">true</text>
  <!-- false block: cached -->
  <rect x="212" y="78" width="216" height="28" rx="4" fill="#1e293b" stroke="#475569" stroke-width="1"/>
  <text x="320" y="97" text-anchor="middle" fill="#64748b">false</text>
  <!-- true block: background refetch -->
  <rect x="432" y="78" width="196" height="28" rx="4" fill="#1e3a5f" stroke="#3b82f6" stroke-width="1.5"/>
  <text x="530" y="97" text-anchor="middle" fill="#93c5fd" font-weight="bold">true</text>

  <!-- isLoading row -->
  <text x="55" y="175" text-anchor="end" fill="#86efac" font-size="12" font-weight="bold">isLoading</text>
  <!-- true block: initial fetch only -->
  <rect x="62" y="153" width="146" height="28" rx="4" fill="#14532d" stroke="#22c55e" stroke-width="1.5"/>
  <text x="135" y="172" text-anchor="middle" fill="#86efac" font-weight="bold">true</text>
  <!-- false block: cached -->
  <rect x="212" y="153" width="216" height="28" rx="4" fill="#1e293b" stroke="#475569" stroke-width="1"/>
  <text x="320" y="172" text-anchor="middle" fill="#64748b">false</text>
  <!-- false block: background refetch -->
  <rect x="432" y="153" width="196" height="28" rx="4" fill="#1e293b" stroke="#475569" stroke-width="1"/>
  <text x="530" y="172" text-anchor="middle" fill="#64748b">false</text>

  <!-- data row -->
  <text x="55" y="250" text-anchor="end" fill="#e2e8f0" font-size="12">data</text>
  <!-- undefined block -->
  <rect x="62" y="228" width="146" height="28" rx="4" fill="#1e293b" stroke="#475569" stroke-width="1"/>
  <text x="135" y="247" text-anchor="middle" fill="#64748b">undefined</text>
  <!-- data available -->
  <rect x="212" y="228" width="416" height="28" rx="4" fill="#292524" stroke="#78716c" stroke-width="1"/>
  <text x="420" y="247" text-anchor="middle" fill="#d6d3d1">Todo[] (stale during refetch)</text>

  <!-- Annotation: background refetch -->
  <text x="530" y="200" text-anchor="middle" fill="#f97316" font-size="10">data still available</text>
  <text x="530" y="213" text-anchor="middle" fill="#f97316" font-size="10">while refetching</text>
</svg>

---

### v4 vs v5: The Naming Change

In TanStack Query v4, `isLoading` had the same meaning as `isFetching` in v5 — it was true during **any** active fetch. This caused a common bug: showing a full-page spinner during background refetches, replacing visible data unnecessarily.

v5 corrected this by redefining `isLoading` to mean only the **initial load**, and introducing `isInitialLoading` in v4 as a transitional name (which became `isLoading` in v5).

| Flag | v4 meaning | v5 meaning |
|---|---|---|
| `isLoading` | Any active fetch (`isFetching && isPending` was called `isInitialLoading`) | First fetch only (`isPending && isFetching`) |
| `isInitialLoading` | First fetch only (introduced late in v4) | Removed (use `isLoading`) |
| `isFetching` | Any active fetch | Any active fetch (unchanged) |

**Key Points**
- Code migrating from v4 that uses `isLoading` to gate a full-page spinner may behave differently in v5 — the spinner will no longer appear during background refetches
- This is intentional and generally the correct behavior, but warrants review during migration

---

### When to Use Each Flag

**Use `isLoading` when:**
- Rendering a skeleton screen or full-page placeholder on first load
- The UI has no data to show yet and needs a distinct empty/loading state
- Distinguishing "never loaded" from "loaded and refreshing"

```ts
const { isLoading, data } = useQuery({
  queryKey: ['todos'],
  queryFn: fetchTodos,
})

if (isLoading) return <SkeletonList />
return <TodoList todos={data!} />
```

**Use `isFetching` when:**
- Showing a subtle network activity indicator (spinner in header, progress bar)
- Indicating that data may be refreshing without hiding existing content
- Tracking any query activity, including background refetches

```ts
const { isFetching, data } = useQuery({
  queryKey: ['todos'],
  queryFn: fetchTodos,
})

return (
  <div>
    {isFetching && <TopProgressBar />}
    <TodoList todos={data ?? []} />
  </div>
)
```

---

### Combining Both Flags

Both flags are often used together to produce layered UX: a full placeholder on first load, and a subtle indicator on subsequent fetches.

```ts
const { isLoading, isFetching, isError, data, error } = useQuery({
  queryKey: ['todos'],
  queryFn: fetchTodos,
})

if (isLoading) return <SkeletonList />
if (isError) return <ErrorMessage error={error} />

return (
  <div>
    {isFetching && <RefreshIndicator />}
    <TodoList todos={data!} />
  </div>
)
```

**Example output across lifecycle stages:**

| Stage | UI rendered |
|---|---|
| First fetch | `<SkeletonList />` only |
| First fetch complete | `<TodoList />` only |
| Background refetch | `<RefreshIndicator />` + `<TodoList />` |
| Background refetch complete | `<TodoList />` only |
| Error on first fetch | `<ErrorMessage />` only |

---

### `useIsFetching` — Global Fetch Indicator

For application-level indicators (e.g., a loading bar in a nav header), TanStack Query provides `useIsFetching`, which returns the total count of currently fetching queries.

```ts
import { useIsFetching } from '@tanstack/react-query'

function GlobalSpinner() {
  const fetchingCount = useIsFetching()
  if (fetchingCount === 0) return null
  return <Spinner />
}
```

**Key Points**
- Returns a number, not a boolean — `> 0` means at least one query is fetching
- Reflects `isFetching` semantics (any active fetch), not `isLoading` semantics
- Useful as a drop-in global loading indicator without coupling to specific queries
- Filters can be passed to scope it to specific query keys: `useIsFetching({ queryKey: ['todos'] })`

---

### Common Mistakes

**Mistake 1 — Using `isLoading` to gate any network activity**

```ts
// ❌ Hides data during background refetches
if (isLoading) return <Spinner />
return <List data={data} />

// ✅ Shows data while refetch runs in background
if (isLoading) return <Spinner />
return (
  <>
    {isFetching && <SmallSpinner />}
    <List data={data} />
  </>
)
```

**Mistake 2 — Using `isFetching` as the first-load gate**

```ts
// ❌ Shows skeleton on every background refetch
if (isFetching) return <SkeletonList />
return <List data={data} />

// ✅ Skeleton only on true first load
if (isLoading) return <SkeletonList />
return <List data={data} />
```

**Mistake 3 — Ignoring that disabled queries have `isLoading: false`**

A query with `enabled: false` that has never fetched has `isPending: true` but `isFetching: false`, so `isLoading` is `false`. This means `isLoading` alone cannot detect "waiting to load" for disabled queries.

```ts
const { isLoading, isPending, isFetching } = useQuery({
  queryKey: ['projects', userId],
  queryFn: () => fetchProjects(userId!),
  enabled: !!userId,
})

// isLoading === false when disabled (isPending true but isFetching false)
// Must check isPending && !isFetching to detect the disabled/waiting state
if (isPending && !isFetching) return <p>Waiting for user ID…</p>
if (isLoading) return <Spinner />
```

---

### Quick Reference

```
isFetching = fetchStatus === 'fetching'
           = true during ANY active fetch (initial or background)

isLoading  = isPending && isFetching
           = true ONLY on the very first fetch (no cached data + actively fetching)
```

---

**Conclusion**

`isFetching` and `isLoading` are complementary, not interchangeable. `isLoading` answers "is this the first time data is being fetched?" while `isFetching` answers "is the query function running right now?" Using them correctly produces UIs that show skeleton placeholders only on first load while displaying stale data transparently during background refreshes — one of TanStack Query's primary UX advantages. The v4-to-v5 rename of `isLoading` semantics is a common migration pitfall and warrants explicit review when upgrading.