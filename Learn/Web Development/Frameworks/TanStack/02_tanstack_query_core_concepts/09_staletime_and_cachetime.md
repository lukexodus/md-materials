## TanStack Query — staleTime and cacheTime

### Overview

Two of the most important configuration options in TanStack Query are `staleTime` and `cacheTime` (renamed `gcTime` in v5). They control independent but related behaviors: when data is considered outdated, and when cached data is removed from memory. Conflating them is one of the most common sources of confusion for new users.

---

### What staleTime Controls

`staleTime` defines how long fetched data is considered **fresh**. While data is fresh, TanStack Query will not trigger a background refetch — it serves the cached value as-is.

Once `staleTime` has elapsed, data becomes **stale**. Stale data is not immediately discarded; it is still returned to the component instantly, but a background refetch is triggered on the next opportunity (mount, window focus, or network reconnect, depending on configuration).

**Default value:** `0` — data is considered stale immediately after it is fetched.

```ts
useQuery({
  queryKey: ['user', userId],
  queryFn: fetchUser,
  staleTime: 1000 * 60 * 5, // 5 minutes
})
```

**Key Points**
- Fresh data → no background refetch triggered
- Stale data → refetch triggered, but cached value still shown in the interim
- `staleTime: Infinity` means data never becomes stale for the lifetime of the cache entry

---

### What cacheTime / gcTime Controls

`cacheTime` (v4 and below) / `gcTime` (v5+) defines how long **inactive** query data is kept in memory before being garbage collected.

A query becomes inactive when no component is subscribed to it (i.e., all components using that query have unmounted). The garbage collection timer starts at that point.

**Default value:** `1000 * 60 * 5` (5 minutes)

```ts
useQuery({
  queryKey: ['user', userId],
  queryFn: fetchUser,
  gcTime: 1000 * 60 * 10, // 10 minutes (v5 syntax)
})
```

**Key Points**
- The timer only runs while the query is **inactive** (no subscribers)
- If a component remounts before `gcTime` elapses, the cached data is reused
- After `gcTime` elapses, the cache entry is removed entirely — the next fetch starts from scratch
- Setting `gcTime: 0` means data is removed as soon as all subscribers unmount

---

### The v4 → v5 Rename

In TanStack Query v5, `cacheTime` was renamed to `gcTime` to better reflect its actual purpose — it governs **garbage collection**, not caching in the general sense.

| Option | v4 | v5 |
|---|---|---|
| Stale threshold | `staleTime` | `staleTime` |
| GC threshold | `cacheTime` | `gcTime` |

Using `cacheTime` in v5 will produce a TypeScript error. When reading older documentation or tutorials, treat `cacheTime` and `gcTime` as equivalent.

---

### How They Interact

The two options operate on different axes and are not mutually exclusive.

```
Fetch completes
      │
      ▼
 [staleTime timer starts]
      │
      ├── Before staleTime elapses → data is FRESH, no background refetch
      │
      └── After staleTime elapses → data is STALE, refetch on next trigger
                                             │
                                             ▼
                               Last subscriber unmounts
                                             │
                               [gcTime timer starts]
                                             │
                               After gcTime elapses → cache entry removed
```

A practical consequence: `staleTime` should always be ≤ `gcTime`. If `staleTime` exceeds `gcTime`, the cache entry could be removed before data ever becomes stale — a configuration that is logically valid but [Inference] likely unintentional in most cases.

---

### Common Configurations and Their Behavior

#### Default behavior (staleTime: 0, gcTime: 5 min)

Data goes stale immediately. Every mount or focus event triggers a background refetch. Cached data is shown during the refetch window.

```ts
useQuery({
  queryKey: ['todos'],
  queryFn: fetchTodos,
  // staleTime defaults to 0
  // gcTime defaults to 300_000
})
```

#### Stable reference data (staleTime: Infinity)

Suitable for data that does not change during a session (e.g., feature flags, config, user roles fetched at login).

```ts
useQuery({
  queryKey: ['config'],
  queryFn: fetchConfig,
  staleTime: Infinity,
})
```

[Inference] With `staleTime: Infinity`, background refetches are suppressed for the lifetime of the cache entry. Behavior may vary depending on explicit `invalidateQueries` calls or manual refetch triggers.

#### Aggressive cache eviction (gcTime: 0)

Forces immediate cache removal on unmount. Subsequent mounts always fetch fresh.

```ts
useQuery({
  queryKey: ['sensitive-data'],
  queryFn: fetchSensitiveData,
  gcTime: 0,
})
```

---

### Setting Global Defaults

Both options can be set globally via `QueryClient` to avoid repeating them per query.

```ts
const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 1000 * 60,      // 1 minute
      gcTime: 1000 * 60 * 10,   // 10 minutes (v5)
    },
  },
})
```

Per-query values override global defaults when both are present.

---

### Interaction with Refetch Triggers

`staleTime` gates all automatic refetch triggers. A refetch will only fire automatically if data is stale **and** one of the following occurs:

- The component mounts (`refetchOnMount`)
- The window regains focus (`refetchOnWindowFocus`)
- The network reconnects (`refetchOnReconnect`)
- A `refetchInterval` fires

If data is fresh, none of these triggers will initiate a new fetch — regardless of their individual enabled states. [Inference] This behavior is subject to implementation details in the version being used; verify against the specific version's changelog.

---

### Inspecting staleTime and gcTime at Runtime

The TanStack Query Devtools panel surfaces per-query state, including whether a query is fresh, stale, fetching, inactive, or removed. This is the recommended way to validate that configured values behave as expected in practice.

---

### Summary Table

| Property | Controls | Default | Timer starts when |
|---|---|---|---|
| `staleTime` | When data is considered outdated | `0` | Immediately after fetch |
| `gcTime` / `cacheTime` | When inactive cache is garbage collected | `300_000` (5 min) | When last subscriber unmounts |

---

**Conclusion**

`staleTime` and `gcTime` are orthogonal controls. `staleTime` governs refetch behavior; `gcTime` governs memory retention. Misconfiguring either — especially assuming they are the same thing — leads to either excessive network requests or unexpected cache misses. Understanding their interaction is foundational to tuning TanStack Query for production use.