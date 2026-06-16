## TanStack Query DevTools — Debugging Stale Queries

### Overview

A query becomes stale when the elapsed time since its last successful fetch exceeds its configured `staleTime`. Stale queries are not automatically removed or refetched — they remain in the cache and continue serving their cached data, but they are eligible for a background refetch the next time a configured trigger fires. Debugging stale query behavior involves understanding why a query is stale sooner or later than expected, why refetches are or are not occurring, and whether stale data is reaching the UI unintentionally.

---

### How Staleness Works

```
Fetch completes (data written to cache)
            │
            ▼
      [fresh] state
            │
     staleTime elapses
            │
            ▼
      [stale] state  ◄─── eligible for background refetch
            │
   trigger fires (focus, mount, interval, manual)
            │
            ▼
      [fetching] (background)
            │
     ┌──────┴──────┐
     ▼             ▼
  success        error
 [fresh]      [stale/error]
```

Staleness is a property of the cache entry, not of the component. A query is stale across all observers simultaneously. If three components share the same query key, all three serve stale data until the next successful refetch.

---

### Locating Stale Queries in DevTools

Open the DevTools panel and use the **Stale** filter toggle. This narrows the query list to entries whose current state is `stale`.

For each stale entry, the detail pane provides:

- **Data Updated At** — the timestamp of the last successful fetch; compare this against the configured `staleTime` to confirm expected staleness timing
- **Observer Count** — whether any component is actively subscribed
- **Status badge** — `stale` (yellow) confirms the cache entry has exceeded `staleTime`

**Key Points:**
- A query that is immediately `stale` on mount has `staleTime: 0`, which is the default.
- A query that remains `fresh` longer than expected may be inheriting a `staleTime` override from `QueryClient` defaults or from a specific `useQuery` call.

---

### Common Causes of Unexpected Staleness

#### Default `staleTime` is Zero

Out of the box, every query has `staleTime: 0`. This means data is considered stale the moment it arrives. Any refetch trigger — window focus, component remount, manual invalidation — will initiate a background refetch.

This is intentional behavior for consistency, but it produces frequent network requests in applications that do not override `staleTime`.

**Diagnosis in DevTools:** A query that oscillates rapidly between `fetching` → `fresh` → `stale` with no delay is operating with `staleTime: 0`.

#### `staleTime` Set Inconsistently Across Call Sites

If `useQuery` is called in multiple components with the same key but different `staleTime` values, the effective `staleTime` applied to the cache entry is [Inference] determined by the most recently mounted observer. This can produce inconsistent staleness behavior depending on component mount order.

```ts
// Component A
useQuery({ queryKey: ['config'], queryFn: fetchConfig, staleTime: 60_000 })

// Component B — same key, different staleTime
useQuery({ queryKey: ['config'], queryFn: fetchConfig, staleTime: 0 })
```

**Diagnosis in DevTools:** If the query appears stale immediately despite expecting a delay, check whether another component with the same key has a lower or zero `staleTime`.

#### Clock Skew or Timestamp Issues

`staleTime` is measured against `Date.now()` at the time the data was last updated. If the system clock shifts (e.g., NTP correction, VM suspension, device sleep), the elapsed time calculation may behave unexpectedly.

[Inference] This is uncommon in development but worth considering in environments with frequent clock adjustments.

#### Manual Invalidation Overriding `staleTime`

`queryClient.invalidateQueries()` marks queries stale regardless of their `staleTime`. A query that appears stale sooner than its `staleTime` suggests may have been explicitly invalidated elsewhere in the codebase.

**Diagnosis:** Add a temporary log inside `queryClient.invalidateQueries()` calls, or search the codebase for all `invalidateQueries` calls matching the affected key pattern.

---

### Refetch Triggers and Why They May Not Fire

A stale query does not refetch on its own — a trigger must fire. If a query is stale but not refetching when expected, the relevant trigger may be disabled or the query may have no active observers.

#### Default Refetch Triggers

| Trigger | Option | Default |
|---|---|---|
| Window regains focus | `refetchOnWindowFocus` | `true` |
| Component mounts with stale data | `refetchOnMount` | `true` |
| Network reconnects | `refetchOnReconnect` | `true` |
| Interval | `refetchInterval` | `false` |

#### Diagnosing a Stale Query That Is Not Refetching

**Step 1 — Check observer count.**
In the DevTools detail pane, if observer count is `0`, the query is inactive. Refetch triggers that depend on component lifecycle (`refetchOnMount`, `refetchOnWindowFocus`) do not fire for inactive queries.

**Step 2 — Check `enabled` flag.**
A query with `enabled: false` will not refetch regardless of trigger or staleness state. In DevTools, a disabled query will not transition to `fetching` even when manually triggered via the Refetch button — the button action is [Inference] still subject to the `enabled` constraint in some versions.

```ts
useQuery({
  queryKey: ['user', userId],
  queryFn: fetchUser,
  enabled: !!userId, // query is disabled when userId is falsy
})
```

**Step 3 — Check `refetchOnWindowFocus`.**
If the application is already in focus (e.g., the DevTools panel itself is inside the same browser tab), toggling focus may not produce a visible trigger. Switching to another tab and returning is a reliable way to test this.

**Step 4 — Check `networkMode`.**
With `networkMode: 'online'` (default), queries will not fetch or refetch when the browser reports being offline. In DevTools, these appear as `paused`. If the browser incorrectly reports offline status, refetches will not fire.

```ts
// Override to always attempt fetch regardless of network status
useQuery({
  queryKey: ['data'],
  queryFn: fetchData,
  networkMode: 'always',
})
```

---

### Using DevTools to Manually Test Stale Behavior

The DevTools panel exposes direct actions on cache entries that are useful for stale query debugging without modifying application code.

#### Invalidate

Marks the selected query as stale immediately, bypassing its remaining `staleTime`. If the query has active observers, a background refetch is triggered.

**Use for:** Verifying that UI components respond correctly when a query becomes stale mid-session.

#### Refetch

Triggers an unconditional refetch of the selected query regardless of its current staleness state.

**Use for:** Confirming that the `queryFn` executes correctly and that the returned data updates the cache and re-renders the component.

#### Reset

Clears the cached data and returns the query to its initial `pending` state. The next observer mount will trigger a fresh fetch from scratch.

**Use for:** Simulating a cold-load scenario — useful when testing loading states that only appear before any data has been cached.

#### Trigger Loading

Forces the query into a `fetching` state visually. [Unverified: whether this triggers actual network activity or only a state simulation. Behavior may vary across DevTools versions.]

**Use for:** Testing loading UI states and skeleton screens without waiting for network latency.

---

### Debugging `staleTime` Configuration

To verify that `staleTime` is configured as intended, use the following approach:

**Step 1 — Set a short, observable `staleTime` during debugging.**

```ts
useQuery({
  queryKey: ['posts'],
  queryFn: fetchPosts,
  staleTime: 5_000, // 5 seconds — observable in real time
})
```

**Step 2 — Fetch the query and watch the DevTools badge.**
After the fetch completes, the badge shows `fresh`. After 5 seconds, it transitions to `stale`. If the transition happens faster or slower, the effective `staleTime` differs from what was configured.

**Step 3 — Check for global defaults.**
`QueryClient` accepts default options that apply to all queries:

```ts
const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 30_000,
    },
  },
})
```

A `staleTime` set at the `useQuery` call site overrides the global default for that query. If no call-site override exists, the global default applies. If no global default exists, `staleTime` is `0`.

**Step 4 — Confirm with Data Updated At.**
After a successful fetch, note the **Data Updated At** timestamp in DevTools. Add the configured `staleTime` to that timestamp. The badge should transition to `stale` at that computed time.

---

### Stale Queries and the UI

A stale query continues to serve its cached data immediately to any mounting component — it does not block rendering. The background refetch happens asynchronously, and the UI updates when new data arrives.

This means stale data is intentionally visible to users during the refetch window. If this is undesirable:

| Approach | Mechanism | Trade-off |
|---|---|---|
| Increase `staleTime` | Reduces refetch frequency | Data may be genuinely outdated |
| Use `placeholderData` | Shows previous data while refetching | Similar to stale behavior but explicit |
| Use `initialData` | Seeds cache with known-good data | Data must be available at query construction time |
| Set `staleTime: Infinity` | Query never goes stale automatically | Requires manual invalidation to update |

[Inference] For data that changes rarely and where consistency is more important than freshness, `staleTime: Infinity` combined with explicit `invalidateQueries` on mutation success is a common pattern. This is not a guarantee of correctness for all use cases.

---

### Checklist for Stale Query Debugging

- [ ] Confirm `staleTime` at the call site and in `QueryClient` defaults
- [ ] Verify observer count — inactive queries do not trigger background refetches
- [ ] Check `enabled` flag — disabled queries do not refetch
- [ ] Check `refetchOnWindowFocus`, `refetchOnMount`, `refetchOnReconnect` settings
- [ ] Check for `invalidateQueries` calls that may be marking queries stale prematurely
- [ ] Use the **Invalidate** and **Refetch** DevTools actions to test behavior in isolation
- [ ] Watch the `fresh` → `stale` transition timing against the configured `staleTime`
- [ ] Check for inconsistent `staleTime` values across multiple `useQuery` calls sharing the same key

---