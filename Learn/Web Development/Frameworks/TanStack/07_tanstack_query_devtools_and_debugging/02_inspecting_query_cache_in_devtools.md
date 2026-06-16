## TanStack Query DevTools — Inspecting the Query Cache

### Overview

The query cache is the central data structure managed by `QueryClient`. Every query that has been fetched, observed, or prefetched exists as an entry in this cache. The DevTools panel exposes the live state of this cache, allowing you to observe data, status transitions, observer counts, and timing metadata without adding debug logging to application code.

---

### What the Cache Contains

Each entry in the query cache is a `Query` instance keyed by a serialized query key. It holds:

| Field | Description |
|---|---|
| **Query Key** | The serialized identifier for this cache entry |
| **State** | Current status (`pending`, `success`, `error`) and fetch status (`fetching`, `paused`, `idle`) |
| **Data** | The last successfully resolved value |
| **Error** | The last error object if the query failed |
| **Observer Count** | Number of mounted components currently subscribed to this query |
| **Updated At** | Timestamp of the last successful data update |
| **Data Updated At** | Timestamp specifically tracking when `data` last changed |
| **Stale Time** | Configured threshold after which data is considered stale |
| **GC Time** | Duration before an inactive query is garbage collected from the cache |

---

### Reading the Query List

The left pane of the DevTools panel lists all current cache entries. Each row displays:

- The **serialized query key** (e.g., `["todos"]`, `["user", 42, "profile"]`)
- A **status badge** reflecting the current combined state
- An **observer count indicator**

#### Status Badge Reference

| Badge Color | Status | Meaning |
|---|---|---|
| Green | `fresh` | Within `staleTime`; no refetch pending |
| Yellow | `stale` | Past `staleTime`; will refetch on next trigger |
| Blue | `fetching` | Active network request in progress |
| Purple | `paused` | Fetch attempted but paused (network offline or `networkMode` config) |
| Gray | `inactive` | No active observers; subject to GC after `gcTime` |

Observer count is displayed as a small badge on the query row. A count of `0` means no mounted component is currently consuming that query.

---

### Filtering and Sorting the Query List

The top bar of the query list provides controls for narrowing the visible entries.

#### Filter by Query Key

Typing in the filter input performs a substring match against the serialized query key string. This is useful when the cache holds many entries and you need to isolate a specific resource.

**Example:** Typing `user` will surface entries like `["user", 1]`, `["users", "list"]`, `["currentUser"]`.

[Inference] The filter operates on the string representation of the key as displayed, not on the raw key structure. Behavior may vary for complex nested keys.

#### Filter by Status

Toggle buttons along the top allow filtering by:

- **Active** — queries with at least one observer
- **Inactive** — queries with zero observers
- **Fresh** — queries within their stale time
- **Fetching** — queries with an in-progress request
- **Paused** — queries blocked from fetching
- **Stale** — queries past their stale time

Multiple toggles can be combined. [Inference] Combination behavior is additive (OR logic), but this is not explicitly documented and may vary across versions.

#### Sort Order

Queries can be sorted by:

- **Status and Updated Time** (default) — groups by lifecycle state, then recency
- **Query Hash** — alphabetical by serialized key
- **Observer Count** — descending by number of active subscribers

---

### Inspecting a Single Cache Entry

Clicking any query row opens the detail pane on the right. This pane is the primary interface for deep cache inspection.

#### Query Key Display

The full query key is shown at the top in its deserialized form. Complex keys with nested objects are rendered with their full structure, making it easier to verify that key construction in application code is producing the intended identifier.

**Example key display:**

```
["posts", { "userId": 5, "status": "published", "page": 2 }]
```

#### Timing Metadata

| Field | What to observe |
|---|---|
| **Data Updated At** | When the cached value last changed — useful for verifying refetch behavior |
| **Last Updated** | Elapsed time since the most recent state change (shown as relative time, e.g., "3s ago") |

Watching **Last Updated** tick upward confirms that no background refetch is occurring. If the value resets frequently, a refetch trigger (window focus, `refetchInterval`, or observer mount) is firing.

#### Observer Count

The observer count in the detail pane confirms how many component instances are subscribed. Patterns to note:

- Count of `0` on a query you expect to be active — a component may have unmounted, or a query key mismatch exists between the data-fetching call and the component consuming it.
- Count unexpectedly high — multiple components may be independently subscribing rather than sharing a single cached entry due to key differences.

---

### Inspecting Cached Data

Below the metadata, the detail pane renders the cached `data` value as an interactive JSON tree.

#### JSON Tree Features

- **Expandable nodes** — nested objects and arrays can be expanded or collapsed
- **Type indicators** — strings, numbers, booleans, null, arrays, and objects are visually differentiated
- **Full depth rendering** — the entire data structure is traversable; there is no depth truncation in the panel

**Key Points:**
- The JSON tree reflects the value stored in cache at the moment of inspection. It does not auto-update while the panel is open unless a refetch occurs and you re-select the query.
- [Inference] For very large cached payloads, rendering the full JSON tree may affect panel performance. This is not documented with specific thresholds.

#### Inspecting Error State

If the query is in an `error` state, the `error` field is displayed in place of (or alongside) the data field, showing the serialized error object including its `message`, `name`, and any additional properties attached to the error.

---

### Observing Cache Lifecycle Transitions

The DevTools are most informative when watched over time rather than as a snapshot. The following transitions are observable in real time:

```
Mount component
      │
      ▼
 [pending / fetching]
      │
      ├─── success ──► [fresh] ──► (staleTime elapses) ──► [stale]
      │                                                          │
      │                                              (trigger: focus / mount / interval)
      │                                                          │
      │                                                   [fetching] ──► [fresh]
      │
      └─── error ──► [error state]
                          │
                    (retry logic)
                          │
                   [fetching] ──► success or error
```

**Key Points:**
- Watching a `fresh` → `stale` transition confirms that `staleTime` is configured as intended.
- A query that immediately transitions `stale` on mount has `staleTime: 0` (the default).
- A query that stays `fresh` longer than expected may have an inherited or overridden `staleTime` from `QueryClient` defaults.

---

### Identifying Cache Misses and Duplicate Entries

A common debugging use case is diagnosing why two components that appear to fetch the same resource result in two separate cache entries and two separate network requests.

#### What to look for

In the query list, if you see two entries that appear to represent the same resource:

```
["user", 1]
["user", "1"]
```

The second key uses a string `"1"` rather than a number `1`. TanStack Query serializes keys deterministically, and type differences in key values produce different hash strings, resulting in separate cache entries.

[Inference] This is one of the most common sources of unintentional cache duplication. The DevTools panel makes it visible because the full key — including type-level differences — is rendered as-is.

#### Other duplication patterns to inspect

- Key arrays with different ordering: `["user", "profile", 1]` vs `["user", 1, "profile"]` are distinct entries.
- Keys with `undefined` values that were unintentionally included in a dynamic key construction.
- Queries with object values in keys where object identity differences (rather than structural differences) were incorrectly assumed to cause duplication — they do not, because TanStack Query hashes by value, not reference. [Inference]

---

### Inspecting Prefetched and Background Queries

Prefetched queries appear in the cache immediately after `queryClient.prefetchQuery()` resolves, even if no component has mounted to observe them. In the DevTools:

- They appear with an observer count of `0`
- Their status will be `fresh` or `stale` depending on when they were prefetched
- They are indistinguishable in appearance from queries that were fetched by a mounted component but whose component has since unmounted

This makes the DevTools useful for verifying that prefetch calls in route loaders or server-side logic are populating the cache as expected before components render.

---

### Cache Persistence and GC Observation

Queries with zero observers begin their garbage collection countdown immediately. The `gcTime` (formerly `cacheTime` in v4) controls how long they persist.

To observe GC behavior:
1. Mount a component that triggers a query.
2. Unmount that component (navigate away, conditionally hide it).
3. Watch the observer count drop to `0` in the DevTools.
4. The entry remains visible in the panel until `gcTime` elapses, after which it disappears from the list.

**Key Points:**
- Default `gcTime` is 5 minutes.
- If an entry disappears faster than expected, `gcTime` may be set to a low value in the query's options or in `QueryClient` defaults.
- If an entry never disappears, a component may still be mounted and observing it, or `gcTime` is set to `Infinity`.

---