## TanStack Query — Cache Management — Observer Pattern and Subscriptions

---

### What Is the Observer Pattern?

The observer pattern is a behavioral design pattern where an object (the **subject** or **observable**) maintains a list of dependents (**observers**) and notifies them automatically when its state changes.

In TanStack Query, this pattern is foundational to how UI components stay synchronized with cached server data — without polling or manual refresh logic.

**Key Points:**
- The cache acts as the subject
- Query observers act as the dependents
- Components subscribe by mounting a query; they unsubscribe on unmount
- Notifications trigger re-renders only when relevant data changes

---

### Core Entities in the Subscription Model

Understanding the observer pattern in TanStack Query requires knowing which internal classes are involved.

#### QueryClient

The top-level manager. Owns the `QueryCache` and `MutationCache`. All interactions from user code go through this.

#### QueryCache

Holds all active `Query` instances, keyed by their serialized query key. Acts as the central registry.

#### Query

Represents a single cached entry. Tracks:
- Current data and error state
- Fetch status (`fetching`, `paused`, `idle`)
- Observer list
- Garbage collection timer

#### QueryObserver

The bridge between a `Query` instance and a component. Created when a component calls `useQuery`. Responsible for:
- Subscribing to a `Query`
- Computing a derived result to pass to the component
- Notifying the component when the result changes

---

### Subscription Lifecycle

The following describes the lifecycle of an observer subscription. Actual internal behavior may vary across versions — treat implementation details as [Inference] based on publicly readable source code.

```
Component mounts
      │
      ▼
useQuery() called
      │
      ▼
QueryObserver created
      │
      ▼
Observer subscribes to Query
(Query.addObserver)
      │
      ▼
If no cached data → fetch triggered
      │
      ▼
Data arrives → Query notifies all observers
      │
      ▼
Each observer computes new result
      │
      ▼
Component re-renders if result changed
      │
      ▼
Component unmounts
      │
      ▼
Observer unsubscribes
(Query.removeObserver)
      │
      ▼
If 0 observers remain → GC timer starts
```

<svg viewBox="0 0 680 520" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="13">
  <!-- Background -->
  <rect width="680" height="520" fill="#0f1117" rx="12"/>

  <!-- Title -->
  <text x="340" y="36" text-anchor="middle" fill="#e2e8f0" font-size="15" font-weight="bold">Observer Subscription Lifecycle</text>

  <!-- QueryCache box -->
  <rect x="240" y="60" width="200" height="44" rx="8" fill="#1e293b" stroke="#334155" stroke-width="1.5"/>
  <text x="340" y="78" text-anchor="middle" fill="#94a3b8" font-size="11">QueryCache</text>
  <text x="340" y="95" text-anchor="middle" fill="#e2e8f0" font-size="12" font-weight="bold">Query Instance</text>

  <!-- Arrow down -->
  <line x1="340" y1="104" x2="340" y2="130" stroke="#475569" stroke-width="1.5" marker-end="url(#arr)"/>

  <!-- Observer row -->
  <!-- Observer A -->
  <rect x="60" y="130" width="160" height="44" rx="8" fill="#1e293b" stroke="#6366f1" stroke-width="1.5"/>
  <text x="140" y="148" text-anchor="middle" fill="#818cf8" font-size="11">QueryObserver A</text>
  <text x="140" y="165" text-anchor="middle" fill="#e2e8f0" font-size="12">useQuery (Comp 1)</text>

  <!-- Observer B -->
  <rect x="260" y="130" width="160" height="44" rx="8" fill="#1e293b" stroke="#6366f1" stroke-width="1.5"/>
  <text x="340" y="148" text-anchor="middle" fill="#818cf8" font-size="11">QueryObserver B</text>
  <text x="340" y="165" text-anchor="middle" fill="#e2e8f0" font-size="12">useQuery (Comp 2)</text>

  <!-- Observer C -->
  <rect x="460" y="130" width="160" height="44" rx="8" fill="#1e293b" stroke="#6366f1" stroke-width="1.5"/>
  <text x="540" y="148" text-anchor="middle" fill="#818cf8" font-size="11">QueryObserver C</text>
  <text x="540" y="165" text-anchor="middle" fill="#e2e8f0" font-size="12">useQuery (Comp 3)</text>

  <!-- Lines from Query to Observers -->
  <line x1="290" y1="104" x2="140" y2="130" stroke="#6366f1" stroke-width="1.2" stroke-dasharray="4,3"/>
  <line x1="340" y1="104" x2="340" y2="130" stroke="#6366f1" stroke-width="1.2" stroke-dasharray="4,3"/>
  <line x1="390" y1="104" x2="540" y2="130" stroke="#6366f1" stroke-width="1.2" stroke-dasharray="4,3"/>

  <!-- Label: subscribe -->
  <text x="190" y="122" fill="#6366f1" font-size="10">subscribe</text>

  <!-- Arrow down from observers to notify -->
  <line x1="140" y1="174" x2="140" y2="210" stroke="#475569" stroke-width="1.2" marker-end="url(#arr)"/>
  <line x1="340" y1="174" x2="340" y2="210" stroke="#475569" stroke-width="1.2" marker-end="url(#arr)"/>
  <line x1="540" y1="174" x2="540" y2="210" stroke="#475569" stroke-width="1.2" marker-end="url(#arr)"/>

  <!-- Component boxes -->
  <rect x="60" y="210" width="160" height="36" rx="8" fill="#0f172a" stroke="#22d3ee" stroke-width="1.5"/>
  <text x="140" y="233" text-anchor="middle" fill="#22d3ee" font-size="12">Component 1</text>

  <rect x="260" y="210" width="160" height="36" rx="8" fill="#0f172a" stroke="#22d3ee" stroke-width="1.5"/>
  <text x="340" y="233" text-anchor="middle" fill="#22d3ee" font-size="12">Component 2</text>

  <rect x="460" y="210" width="160" height="36" rx="8" fill="#0f172a" stroke="#22d3ee" stroke-width="1.5"/>
  <text x="540" y="233" text-anchor="middle" fill="#22d3ee" font-size="12">Component 3</text>

  <!-- Data fetch flow -->
  <rect x="180" y="290" width="320" height="44" rx="8" fill="#1e293b" stroke="#f59e0b" stroke-width="1.5"/>
  <text x="340" y="308" text-anchor="middle" fill="#fbbf24" font-size="11">Network / Fetch Layer</text>
  <text x="340" y="325" text-anchor="middle" fill="#e2e8f0" font-size="12">Data arrives → Query updates</text>

  <!-- Arrow up from fetch to Query -->
  <line x1="340" y1="290" x2="340" y2="244" stroke="#f59e0b" stroke-width="1.5" marker-end="url(#arrY)"/>
  <text x="352" y="272" fill="#f59e0b" font-size="10">notify</text>

  <!-- GC Box -->
  <rect x="180" y="380" width="320" height="44" rx="8" fill="#1e293b" stroke="#f87171" stroke-width="1.5"/>
  <text x="340" y="398" text-anchor="middle" fill="#f87171" font-size="11">GC Timer Starts</text>
  <text x="340" y="415" text-anchor="middle" fill="#e2e8f0" font-size="12">when observer count → 0</text>

  <!-- Arrow from component unmount to GC -->
  <line x1="340" y1="334" x2="340" y2="380" stroke="#f87171" stroke-width="1.2" stroke-dasharray="4,3" marker-end="url(#arrR)"/>
  <text x="348" y="362" fill="#f87171" font-size="10">unmount</text>

  <!-- GC to cache eviction -->
  <rect x="220" y="458" width="240" height="36" rx="8" fill="#0f172a" stroke="#475569" stroke-width="1.5"/>
  <text x="340" y="481" text-anchor="middle" fill="#94a3b8" font-size="12">Cache Entry Evicted</text>
  <line x1="340" y1="424" x2="340" y2="458" stroke="#475569" stroke-width="1.2" marker-end="url(#arrG)"/>

  <!-- Arrow markers -->
  <defs>
    <marker id="arr" markerWidth="8" markerHeight="8" refX="6" refY="3" orient="auto">
      <path d="M0,0 L0,6 L8,3 z" fill="#475569"/>
    </marker>
    <marker id="arrY" markerWidth="8" markerHeight="8" refX="6" refY="3" orient="auto">
      <path d="M0,0 L0,6 L8,3 z" fill="#f59e0b"/>
    </marker>
    <marker id="arrR" markerWidth="8" markerHeight="8" refX="6" refY="3" orient="auto">
      <path d="M0,0 L0,6 L8,3 z" fill="#f87171"/>
    </marker>
    <marker id="arrG" markerWidth="8" markerHeight="8" refX="6" refY="3" orient="auto">
      <path d="M0,0 L0,6 L8,3 z" fill="#475569"/>
    </marker>
  </defs>
</svg>

---

### How QueryObserver Computes Results

Each observer does not blindly forward every cache update to its component. It computes a **derived result object** and compares it to the previous one. A re-render is triggered only when the result is considered changed.

[Inference] The comparison is based on structural equality of selected fields, not deep equality of the full cache entry. Exact diffing behavior may vary by version.

```ts
// Simplified conceptual representation — not actual source code
const result = observer.getCurrentResult()
// {
//   data: T | undefined,
//   error: Error | null,
//   status: 'pending' | 'error' | 'success',
//   fetchStatus: 'fetching' | 'paused' | 'idle',
//   isLoading: boolean,
//   isFetching: boolean,
//   ...
// }
```

The observer compares the new result to the previous one before signaling the component to re-render.

---

### The `select` Option and Derived Subscriptions

The `select` option allows a component to subscribe to a **transformation** of the cached data rather than the raw data. This narrows what triggers a re-render.

```ts
const { data } = useQuery({
  queryKey: ['users'],
  queryFn: fetchUsers,
  select: (data) => data.filter(u => u.active),
})
```

**Key Points:**
- The full raw result is still cached centrally
- Each observer applies its own `select` independently
- If the selected output has not changed (by reference or structural equality), the component does not re-render — [Inference] based on observable behavior; not guaranteed across all versions
- Multiple components can each select different slices of the same query without separate fetches

---

### Multiple Observers on the Same Query

When two or more components use the same query key, they share a single `Query` instance in the cache. Each gets its own `QueryObserver`, but only one network request is made.

```ts
// Component A
const { data } = useQuery({ queryKey: ['posts'], queryFn: fetchPosts })

// Component B — same key, different component
const { data } = useQuery({ queryKey: ['posts'], queryFn: fetchPosts })
```

**Key Points:**
- One fetch, two observers, two re-renders (coordinated)
- Both components receive the same underlying cached data
- Deduplication is a direct consequence of the shared `Query` instance model

---

### Observer Count and Garbage Collection

The number of active observers directly controls the cache entry's lifecycle.

| Observer Count | Effect |
|---|---|
| ≥ 1 | Query is considered **active**; GC timer does not run |
| 0 | Query becomes **inactive**; GC timer starts |
| 0 after `gcTime` | Cache entry is removed |

Default `gcTime` is 5 minutes (300,000 ms).

```ts
useQuery({
  queryKey: ['profile'],
  queryFn: fetchProfile,
  gcTime: 10 * 60 * 1000, // 10 minutes
})
```

When a component unmounts, its observer is removed. If it was the last observer, the timer begins. If a component remounts before the timer expires, the cached data is reused immediately and a background refetch may occur depending on `staleTime`.

---

### `enabled` and Conditional Subscriptions

Setting `enabled: false` creates an observer that does not trigger a fetch. The observer is still registered against the query, but it sits in a passive state.

```ts
const { data } = useQuery({
  queryKey: ['user', userId],
  queryFn: () => fetchUser(userId),
  enabled: !!userId,
})
```

**Key Points:**
- When `enabled` transitions from `false` to `true`, the observer triggers a fetch
- This is a controlled subscription — the observer exists but defers execution
- [Inference] The query instance may still be created in the cache even when `enabled: false`, depending on version

---

### Manual Subscription via `QueryObserver` (Advanced)

Outside of React, you can manually create and manage a `QueryObserver`. This is useful for integrations, non-React renderers, or testing.

```ts
import { QueryClient, QueryObserver } from '@tanstack/query-core'

const queryClient = new QueryClient()

const observer = new QueryObserver(queryClient, {
  queryKey: ['posts'],
  queryFn: fetchPosts,
})

const unsubscribe = observer.subscribe((result) => {
  console.log('Result changed:', result)
})

// Later — clean up
unsubscribe()
```

**Key Points:**
- `observer.subscribe(callback)` returns an unsubscribe function
- The callback receives the full result object on every relevant change
- This mirrors exactly what `useQuery` does internally in framework adapters
- Useful for understanding the raw mechanism beneath the React hook abstraction

---

### Notification Batching

[Inference] TanStack Query batches notifications to observers within a single synchronous update cycle to avoid redundant re-renders. This behavior is influenced by the framework renderer (React 18 automatic batching, for example). Exact batching semantics are not guaranteed and may differ across environments.

In React 18+, state updates triggered by external subscriptions (such as observer notifications) are automatically batched by the React scheduler, which [Inference] reduces the number of intermediate renders during rapid successive cache updates.

---

### Summary Table

| Concept | Role |
|---|---|
| `QueryCache` | Holds all `Query` instances |
| `Query` | Central state + observer list for one key |
| `QueryObserver` | Bridges one component to one `Query` |
| `subscribe()` | Registers observer; may trigger fetch |
| `unsubscribe()` | Removes observer; may start GC timer |
| `select` | Per-observer data transformation |
| `enabled` | Controls whether observer activates fetch |
| `gcTime` | Delay before inactive entry is evicted |

---

**Conclusion:**
The observer pattern is not just an implementation detail in TanStack Query — it is the architectural reason the library achieves automatic synchronization, fetch deduplication, and fine-grained re-render control simultaneously. Understanding observer lifecycles directly informs decisions about `gcTime`, `staleTime`, `enabled`, and `select` in production applications.