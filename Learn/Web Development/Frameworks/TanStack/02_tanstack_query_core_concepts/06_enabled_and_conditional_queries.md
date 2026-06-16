## TanStack Query — Core Concepts — Enabled and Conditional Queries

---

### What Is the `enabled` Option?

The `enabled` option is a boolean flag on `useQuery` (and related hooks) that controls whether a query is allowed to automatically run. When `enabled` is `false`, the query will not fetch on mount, will not refetch in the background, and will not respond to query key changes.

**Key Points**
- Accepts a `boolean` or a function returning a `boolean` (v5+)
- Defaults to `true`
- Does not prevent manual fetching via `refetch()`
- Affects automatic fetching only

```ts
useQuery({
  queryKey: ['todos'],
  queryFn: fetchTodos,
  enabled: false, // query will never auto-fetch
})
```

---

### Why Use Conditional Queries?

Several common scenarios require a query to wait before executing:

- A required value (e.g., user ID, token) is not yet available
- A preceding query must complete first (dependent queries)
- User interaction must occur before fetching begins (lazy queries)
- Feature flags or permissions gate the fetch

---

### Dependent Queries

The most common use case is waiting for one query's data before executing another. This is achieved by passing the upstream result into `enabled`.

```ts
const { data: user } = useQuery({
  queryKey: ['user', userId],
  queryFn: () => fetchUser(userId),
})

const { data: projects } = useQuery({
  queryKey: ['projects', user?.id],
  queryFn: () => fetchProjects(user!.id),
  enabled: !!user,
})
```

**Key Points**
- `!!user` evaluates to `false` while `user` is `undefined` (loading or not yet fetched)
- Once `user` resolves, `enabled` becomes `true` and the second query fires automatically
- The non-null assertion `user!.id` is safe because `enabled` guards execution
- Include all upstream dependencies in the query key to maintain cache correctness

---

### Query Status When `enabled: false`

When a query is disabled before it has ever fetched, its state differs from a loading query.

| Field | Value |
|---|---|
| `status` | `'pending'` |
| `fetchStatus` | `'idle'` |
| `isPending` | `true` |
| `isFetching` | `false` |
| `data` | `undefined` |

**Key Points**
- In TanStack Query v5, `status: 'pending'` combined with `fetchStatus: 'idle'` is the signal that a query is disabled and has never fetched — distinct from a query that is actively loading (`fetchStatus: 'fetching'`)
- Prior to v5, disabled queries had `status: 'loading'`, which caused confusion with genuinely loading queries — this was a known pain point addressed in v5
- Always check both `status` and `fetchStatus` (or use `isPending && !isFetching`) to differentiate disabled from in-flight queries

```ts
const { isPending, isFetching, data } = useQuery({
  queryKey: ['projects', user?.id],
  queryFn: () => fetchProjects(user!.id),
  enabled: !!user,
})

if (isPending && !isFetching) {
  return <p>Waiting for user data...</p>
}
```

---

### Lazy Queries (Fetch on Demand)

A query can be configured to only run when explicitly triggered — for example, on a button click. Start with `enabled: false` and use the returned `refetch` function.

```ts
const { data, isFetching, refetch } = useQuery({
  queryKey: ['search', query],
  queryFn: () => searchItems(query),
  enabled: false,
})

return (
  <div>
    <button onClick={() => refetch()}>Search</button>
    {isFetching && <p>Loading...</p>}
    {data && <Results data={data} />}
  </div>
)
```

**Key Points**
- `refetch()` triggers a fetch regardless of `enabled`
- [Inference] This pattern is useful for search-on-submit UIs but may conflict with expectations around stale data — if `refetch` is called and cached data exists, it will refetch based on `staleTime` settings unless `refetch({ cancelRefetch: false })` is used carefully
- For event-driven data mutations, `useMutation` is often more appropriate than a lazy query

---

### Dynamic `enabled` with Variables

When `enabled` depends on a runtime value, use a derived boolean expression.

```ts
function UserProjects({ userId }: { userId: string | null }) {
  const { data } = useQuery({
    queryKey: ['projects', userId],
    queryFn: () => fetchProjects(userId!),
    enabled: userId !== null && userId !== '',
  })
}
```

**Key Points**
- Avoid passing `enabled: undefined` — this is treated as `true` in most versions but behavior may vary; always resolve to an explicit boolean
- [Inference] Coercing with `!!value` is convenient but may unintentionally disable queries for falsy-but-valid values (e.g., `0`, `''`) — prefer explicit checks when the value type warrants it

---

### `enabled` as a Function (v5)

In TanStack Query v5, `enabled` can accept a function for cases where the condition should be evaluated lazily or derived from query state.

```ts
useQuery({
  queryKey: ['todos'],
  queryFn: fetchTodos,
  enabled: () => userStore.isAuthenticated(),
})
```

**Key Points**
- [Unverified] This form may be evaluated at subscription time rather than render time — consult current documentation for precise evaluation timing
- Primarily useful when the condition lives outside React state (e.g., in a Zustand store or external singleton)

---

### Skipping Queries with `skipToken` (v5)

TanStack Query v5 introduced `skipToken` as a type-safe alternative to `enabled: false`. When `queryFn` is set to `skipToken`, the query is permanently disabled.

```ts
import { skipToken } from '@tanstack/react-query'

const { data } = useQuery({
  queryKey: ['user', userId],
  queryFn: userId ? () => fetchUser(userId) : skipToken,
})
```

**Key Points**
- `skipToken` replaces the need to pair `enabled: false` with a placeholder `queryFn`
- Improves TypeScript inference — when `skipToken` is used conditionally, the inferred `data` type reflects the non-skip branch correctly
- Cannot be combined with `enabled` — using `skipToken` as `queryFn` implicitly disables the query
- [Inference] Preferred in v5+ codebases for conditional fetch patterns involving optional parameters, as it collocates the condition with the function rather than separating it into the `enabled` option

```ts
// ✅ Type-safe conditional fetch
const queryFn = userId !== undefined
  ? () => fetchUser(userId)
  : skipToken

useQuery({ queryKey: ['user', userId], queryFn })
```

---

### Comparison: `enabled` vs `skipToken`

| Aspect | `enabled: false` | `skipToken` |
|---|---|---|
| Availability | v3+ | v5+ |
| Type safety | Manual | Improved inference |
| `queryFn` required | Yes (separate) | Replaces `queryFn` |
| Works with `refetch()` | Yes | No (query is inert) |
| Use case | Runtime toggle | Conditional parameter |

---

### Re-enabling a Disabled Query

When `enabled` transitions from `false` to `true`, TanStack Query automatically triggers a fetch if no valid cached data exists.

```ts
const [enabled, setEnabled] = useState(false)

const { data } = useQuery({
  queryKey: ['todos'],
  queryFn: fetchTodos,
  enabled,
})

// Toggling enabled triggers a fetch
<button onClick={() => setEnabled(true)}>Load Todos</button>
```

**Key Points**
- No manual `refetch()` call is required when `enabled` changes
- If data already exists in cache and is not stale, the fetch may be skipped — behavior depends on `staleTime` configuration
- [Inference] Toggling `enabled` back to `false` after data has loaded does not clear the cache or remove the data — it only pauses further automatic refetching

---

### Combining `enabled` with `staleTime`

When a query becomes enabled, TanStack Query checks the cache before fetching. If cached data exists and is within `staleTime`, no network request is made.

```ts
useQuery({
  queryKey: ['user', userId],
  queryFn: () => fetchUser(userId),
  enabled: !!userId,
  staleTime: 5 * 60 * 1000, // 5 minutes
})
```

**Key Points**
- Useful for queries that may be re-enabled after the component unmounts and remounts
- [Inference] Setting a meaningful `staleTime` alongside `enabled` prevents redundant fetches when the enabling condition flips rapidly (e.g., during navigation)

---

### Common Patterns

**Pattern 1 — Wait for authentication**
```ts
const { data: session } = useQuery({
  queryKey: ['session'],
  queryFn: fetchSession,
})

const { data: profile } = useQuery({
  queryKey: ['profile', session?.userId],
  queryFn: () => fetchProfile(session!.userId),
  enabled: !!session?.userId,
})
```

**Pattern 2 — Wait for form input**
```ts
const [searchTerm, setSearchTerm] = useState('')

const { data } = useQuery({
  queryKey: ['search', searchTerm],
  queryFn: () => search(searchTerm),
  enabled: searchTerm.length >= 3,
})
```

**Pattern 3 — Feature flag gating**
```ts
const { data } = useQuery({
  queryKey: ['beta-feature-data'],
  queryFn: fetchBetaData,
  enabled: featureFlags.betaEnabled && !!currentUser,
})
```

---

### Pitfalls

**Stale query key with disabled query**
If the query key changes while `enabled` is `false`, TanStack Query registers the new key but does not fetch until `enabled` becomes `true`. This is expected behavior but can cause confusion.

**Non-boolean `enabled` values**
Passing a non-boolean (e.g., a string or object) to `enabled` may produce unexpected results. Always resolve to an explicit `true` or `false`.

```ts
// ❌ Potentially problematic
enabled: userId  // truthy string, but not a boolean

// ✅ Explicit
enabled: !!userId
```

**Forgetting `isFetching` vs `isPending`**
A disabled query that has never fetched will have `isPending: true`. Relying on `isPending` alone to show a loading spinner will show it indefinitely for disabled queries.

```ts
// ❌ Shows spinner even when query is just disabled
if (isPending) return <Spinner />

// ✅ Distinguishes disabled from loading
if (isPending && isFetching) return <Spinner />
if (isPending && !isFetching) return <p>Waiting...</p>
```

---

**Conclusion**

The `enabled` option and `skipToken` give precise, declarative control over when queries execute. They are essential for dependent query chains, lazy fetch patterns, and permission-gated data. The key to using them correctly is understanding the distinction between `status` and `fetchStatus`, choosing the right primitive for the use case (`enabled` for runtime toggles, `skipToken` for conditional parameters in v5+), and keeping query keys synchronized with all variables the query function depends on. Behavior described here applies primarily to TanStack Query v5; some behavior differs in earlier versions.