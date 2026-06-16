## What is TanStack Query

### Overview

TanStack Query is an **asynchronous state management library** for web applications. It manages the full lifecycle of server-side data — fetching, caching, synchronizing, and updating — without requiring you to write manual loading state, cache invalidation logic, or background refresh code.

Originally created by Tanner Linsley as **React Query**, it was rebranded and restructured under the TanStack umbrella at v4, gaining a framework-agnostic core with official adapters for React, Vue, Solid, Svelte, and Angular. The React adapter (`@tanstack/react-query`) remains the most widely used.

---

### The Core Problem It Solves

Most web applications need data from a server. The naive approach uses component-local state:

```ts
// Common pattern before TanStack Query
const [data, setData]     = useState(null)
const [loading, setLoading] = useState(true)
const [error, setError]   = useState(null)

useEffect(() => {
  fetch('/api/users')
    .then(res => res.json())
    .then(setData)
    .catch(setError)
    .finally(() => setLoading(false))
}, [])
```

This approach has compounding problems at scale:

| Problem | What Happens |
|---|---|
| **No caching** | Every component mount re-fetches, even for identical data |
| **No deduplication** | Two components mounting simultaneously fire two identical requests |
| **No background refresh** | Data goes stale with no mechanism to detect or correct it |
| **No synchronization** | Mutations in one component do not update data in another |
| **Manual state** | Every fetch requires three state variables and cleanup logic |
| **Race conditions** | Slow responses from earlier requests can overwrite newer ones |

TanStack Query addresses all of these problems through a **centralized, observable cache** with a declarative query API.

---

### The Mental Model

TanStack Query draws a clear distinction between two types of state:

<svg viewBox="0 0 720 300" xmlns="http://www.w3.org/2000/svg" font-family="ui-monospace, monospace" font-size="12">
  <rect width="720" height="300" fill="#0f1117" rx="12"/>

  <!-- Client State Box -->
  <rect x="30" y="40" width="300" height="210" rx="8" fill="#1a1a2e" stroke="#6366f1" stroke-width="1.5"/>
  <text x="180" y="68" fill="#a5b4fc" text-anchor="middle" font-weight="bold" font-size="13">Client State</text>
  <text x="180" y="90" fill="#4b5563" text-anchor="middle" font-size="11">Owned by the application</text>

  <text x="60" y="120" fill="#818cf8" font-size="11">✦  UI open/closed state</text>
  <text x="60" y="143" fill="#818cf8" font-size="11">✦  Selected tab or step</text>
  <text x="60" y="166" fill="#818cf8" font-size="11">✦  Form draft values</text>
  <text x="60" y="189" fill="#818cf8" font-size="11">✦  Dark / light mode</text>
  <text x="60" y="212" fill="#818cf8" font-size="11">✦  Sidebar width</text>

  <text x="180" y="238" fill="#374151" text-anchor="middle" font-size="10">useState · useReducer · Zustand</text>

  <!-- Server State Box -->
  <rect x="390" y="40" width="300" height="210" rx="8" fill="#1a2e1a" stroke="#10b981" stroke-width="1.5"/>
  <text x="540" y="68" fill="#6ee7b7" text-anchor="middle" font-weight="bold" font-size="13">Server State</text>
  <text x="540" y="90" fill="#4b5563" text-anchor="middle" font-size="11">Owned by the server</text>

  <text x="420" y="120" fill="#34d399" font-size="11">✦  User profile data</text>
  <text x="420" y="143" fill="#34d399" font-size="11">✦  API list responses</text>
  <text x="420" y="166" fill="#34d399" font-size="11">✦  Database records</text>
  <text x="420" y="189" fill="#34d399" font-size="11">✦  Aggregated metrics</text>
  <text x="420" y="212" fill="#34d399" font-size="11">✦  File metadata</text>

  <text x="540" y="238" fill="#374151" text-anchor="middle" font-size="10">TanStack Query</text>

  <!-- VS divider -->
  <text x="360" y="155" fill="#4b5563" text-anchor="middle" font-weight="bold" font-size="14">VS</text>
</svg>

Server state is fundamentally different from client state because:

- It is **remote** — you do not own or control it directly
- It is **asynchronous** — access requires a network round-trip
- It is **shared** — other users or processes may change it without your knowledge
- It can become **stale** — your local copy diverges from the server's truth over time

TanStack Query treats server state as a **cache of remote data** rather than owned application state. Your code describes *what* data it needs; TanStack Query decides *when* to fetch, *how long* to keep it, and *when* to refresh it.

---

### Key Concepts

#### Query

A **query** is a declarative subscription to an asynchronous data source. It is identified by a **query key** and executed by a **query function**.

```ts
const { data, isLoading, isError } = useQuery({
  queryKey: ['users'],
  queryFn: () => fetch('/api/users').then(res => res.json()),
})
```

When a component mounts with this query, TanStack Query:
1. Checks the cache for an entry matching `['users']`
2. Returns cached data immediately if available and not stale
3. Fires the `queryFn` in the background if data is stale or absent
4. Updates all subscribers when fresh data arrives

---

#### Query Key

The query key is the **unique identifier for a cached entry**. It is an array that can contain strings, numbers, objects, or nested arrays. TanStack Query uses deep equality to match keys.

```ts
// Static key — identifies a fixed resource
queryKey: ['users']

// Dynamic key — identifies a specific resource by ID
queryKey: ['users', userId]

// Structured key — includes filter parameters
queryKey: ['users', { status: 'active', page: 2 }]
```

**Key Points:**
- Keys are serialized for cache lookup — objects inside keys are compared by value, not reference
- Changing any part of the key causes the query to be treated as a different cache entry
- Key design has a direct impact on cache granularity and invalidation behavior — a poorly designed key scheme leads to over- or under-fetching

---

#### Query Function

The query function is **any function that returns a Promise**. TanStack Query is agnostic to how you fetch data — it works with `fetch`, `axios`, GraphQL clients, or any other async mechanism.

```ts
// With fetch
queryFn: () => fetch('/api/users').then(res => res.json())

// With axios
queryFn: () => axios.get('/api/users').then(res => res.data)

// With a typed API client
queryFn: () => apiClient.users.list()

// Accessing the query key inside queryFn
queryFn: ({ queryKey }) => {
  const [, userId] = queryKey
  return fetch(`/api/users/${userId}`).then(res => res.json())
}
```

**Key Points:**
- The query function must throw or return a rejected Promise on failure — TanStack Query uses this to transition the query to an error state
- The query function receives a `QueryFunctionContext` object as its argument, which includes the `queryKey`, `signal` (for abort), and `pageParam` (for infinite queries)

---

#### Stale Time and Cache Time

Two configuration values control how long data is considered fresh and how long it is retained in memory:

```ts
useQuery({
  queryKey: ['users'],
  queryFn: fetchUsers,
  staleTime: 1000 * 60 * 5,   // data is fresh for 5 minutes
  gcTime:    1000 * 60 * 10,  // removed from cache 10 minutes after last subscriber
})
```

| Option | Default | Meaning |
|---|---|---|
| `staleTime` | `0` | How long fetched data is considered fresh. Fresh data is not refetched on mount. |
| `gcTime` | `5 minutes` | How long inactive (unsubscribed) cache entries are retained before garbage collection. |

**Key Points:**
- With the default `staleTime: 0`, every component mount triggers a background refetch — the cached data is returned immediately, then updated when the refetch completes
- `staleTime` should be tuned to how frequently your data actually changes on the server — static reference data can use `Infinity`; live feed data may stay at `0`
- `gcTime` was called `cacheTime` in v4 — renamed in v5 to better reflect its purpose [behavior may vary in v4 codebases]

---

#### Automatic Refetch Triggers

TanStack Query refetches data automatically on several events, without requiring manual intervention:

| Trigger | Default Behavior |
|---|---|
| Component mounts | Refetch if data is stale |
| Window regains focus | Refetch if data is stale |
| Network reconnects | Refetch if data is stale |
| Query key changes | Fetch immediately for new key |
| Manual invalidation | Refetch regardless of staleness |

Each trigger can be configured or disabled:

```ts
useQuery({
  queryKey: ['users'],
  queryFn: fetchUsers,
  refetchOnWindowFocus:   false,
  refetchOnReconnect:     true,
  refetchOnMount:         true,
  refetchInterval:        1000 * 30,  // poll every 30 seconds
})
```

---

#### Mutation

A **mutation** handles data writes — POST, PUT, PATCH, DELETE operations. Unlike queries, mutations are imperative: they fire when explicitly called.

```ts
const mutation = useMutation({
  mutationFn: (newUser: NewUser) =>
    fetch('/api/users', {
      method: 'POST',
      body: JSON.stringify(newUser),
    }).then(res => res.json()),

  onSuccess: () => {
    queryClient.invalidateQueries({ queryKey: ['users'] })
  },
})

// Trigger the mutation
mutation.mutate({ name: 'Alice', email: 'alice@example.com' })
```

**Key Points:**
- `useMutation` does not cache results — it manages only the in-flight state of a write operation
- `invalidateQueries` after a successful mutation marks related queries as stale, triggering an automatic background refetch in any mounted subscriber
- `mutateAsync` is available for use in `async/await` flows where you need to `await` the mutation result

---

#### Query Client

The `QueryClient` is the central cache instance. It holds all cached query data and exposes methods for interacting with the cache imperatively.

```ts
const queryClient = useQueryClient()

// Invalidate a query (marks stale, triggers refetch if mounted)
queryClient.invalidateQueries({ queryKey: ['users'] })

// Manually set cache data
queryClient.setQueryData(['users', userId], updatedUser)

// Prefetch a query (fetch without subscribing)
await queryClient.prefetchQuery({
  queryKey: ['users'],
  queryFn: fetchUsers,
})

// Remove a query from cache entirely
queryClient.removeQueries({ queryKey: ['users'] })
```

---

### Query Lifecycle

The following diagram illustrates the states a query moves through during its lifecycle:

<svg viewBox="0 0 740 420" xmlns="http://www.w3.org/2000/svg" font-family="ui-monospace, monospace" font-size="12">
  <rect width="740" height="420" fill="#0f1117" rx="12"/>

  <!-- States -->
  <!-- Idle/Pending -->
  <rect x="290" y="30" width="160" height="44" rx="8" fill="#1e293b" stroke="#64748b" stroke-width="1.5"/>
  <text x="370" y="52" fill="#94a3b8" text-anchor="middle" font-weight="bold">pending</text>
  <text x="370" y="67" fill="#475569" text-anchor="middle" font-size="10">No data yet</text>

  <!-- Fetching -->
  <rect x="290" y="130" width="160" height="44" rx="8" fill="#1e3a5f" stroke="#3b82f6" stroke-width="1.5"/>
  <text x="370" y="152" fill="#60a5fa" text-anchor="middle" font-weight="bold">fetching</text>
  <text x="370" y="167" fill="#1d4ed8" text-anchor="middle" font-size="10">queryFn running</text>

  <!-- Success -->
  <rect x="100" y="250" width="160" height="44" rx="8" fill="#134e3a" stroke="#10b981" stroke-width="1.5"/>
  <text x="180" y="272" fill="#34d399" text-anchor="middle" font-weight="bold">success</text>
  <text x="180" y="287" fill="#065f46" text-anchor="middle" font-size="10">Data in cache</text>

  <!-- Error -->
  <rect x="480" y="250" width="160" height="44" rx="8" fill="#450a0a" stroke="#ef4444" stroke-width="1.5"/>
  <text x="560" y="272" fill="#fca5a5" text-anchor="middle" font-weight="bold">error</text>
  <text x="560" y="287" fill="#7f1d1d" text-anchor="middle" font-size="10">queryFn rejected</text>

  <!-- Stale -->
  <rect x="100" y="350" width="160" height="44" rx="8" fill="#451f1f" stroke="#f59e0b" stroke-width="1.5"/>
  <text x="180" y="372" fill="#fbbf24" text-anchor="middle" font-weight="bold">stale</text>
  <text x="180" y="387" fill="#92400e" text-anchor="middle" font-size="10">staleTime elapsed</text>

  <!-- Arrows -->
  <defs>
    <marker id="a2" markerWidth="8" markerHeight="8" refX="6" refY="3" orient="auto">
      <path d="M0,0 L0,6 L8,3 z" fill="#4b5563"/>
    </marker>
  </defs>

  <!-- pending → fetching -->
  <line x1="370" y1="74" x2="370" y2="130" stroke="#4b5563" stroke-width="1.5" marker-end="url(#a2)"/>
  <text x="378" y="108" fill="#6b7280" font-size="10">mount / subscribe</text>

  <!-- fetching → success -->
  <line x1="320" y1="174" x2="220" y2="250" stroke="#10b981" stroke-width="1.5" marker-end="url(#a2)"/>
  <text x="228" y="222" fill="#10b981" font-size="10">resolved</text>

  <!-- fetching → error -->
  <line x1="420" y1="174" x2="520" y2="250" stroke="#ef4444" stroke-width="1.5" marker-end="url(#a2)"/>
  <text x="470" y="222" fill="#ef4444" font-size="10">rejected</text>

  <!-- success → stale -->
  <line x1="180" y1="294" x2="180" y2="350" stroke="#f59e0b" stroke-width="1.5" marker-end="url(#a2)"/>
  <text x="188" y="328" fill="#f59e0b" font-size="10">staleTime elapsed</text>

  <!-- stale → fetching (refetch) -->
  <path d="M100,372 Q30,300 290,152" fill="none" stroke="#3b82f6" stroke-width="1.5" stroke-dasharray="5,3" marker-end="url(#a2)"/>
  <text x="38" y="270" fill="#3b82f6" font-size="10">refetch</text>
  <text x="38" y="282" fill="#3b82f6" font-size="10">trigger</text>

  <!-- error → fetching (retry) -->
  <path d="M640,272 Q710,200 450,152" fill="none" stroke="#f87171" stroke-width="1.5" stroke-dasharray="5,3" marker-end="url(#a2)"/>
  <text x="648" y="210" fill="#f87171" font-size="10">retry</text>
</svg>

---

### Status Fields

TanStack Query exposes several derived status fields to simplify conditional rendering:

```ts
const {
  data,
  status,          // 'pending' | 'success' | 'error'
  fetchStatus,     // 'fetching' | 'paused' | 'idle'
  isLoading,       // true when status === 'pending' && fetchStatus === 'fetching'
  isPending,       // true when status === 'pending'
  isSuccess,       // true when status === 'success'
  isError,         // true when status === 'error'
  isFetching,      // true whenever a fetch is in-flight (including background)
  isRefetching,    // true when refetching data that already exists in cache
  isStale,         // true when data has exceeded staleTime
  error,           // the Error object if status === 'error'
} = useQuery({ queryKey: ['users'], queryFn: fetchUsers })
```

**Key Points:**
- `isFetching` is true during both initial fetches and background refetches — useful for showing subtle refresh indicators without blocking the UI
- `isLoading` is specifically the state where there is no cached data *and* a fetch is in-flight — the "spinner" state
- `status` and `fetchStatus` are separate axes: a query can be in `success` status while also `fetching` in the background [behavior may vary in edge cases]

---

### Caching Behavior

The cache is the central mechanism that makes TanStack Query valuable. Understanding its behavior prevents common misuse:

```
Query key: ['users']
staleTime: 5 minutes
gcTime:    10 minutes

Timeline:
00:00  Component A mounts → cache miss → fetch fires → data stored
00:01  Component B mounts → cache hit (fresh) → returns cached data, no fetch
05:01  staleTime elapsed → data marked stale
05:02  Component C mounts → cache hit (stale) → returns cached data + background refetch
05:03  Refetch completes → Components A, B, C all update
10:03  All components unmount → gcTime countdown begins
20:03  gcTime elapsed → cache entry removed
```

**Key Points:**
- Multiple components using the same query key share a single cache entry and a single in-flight request — this is **request deduplication**
- Data is returned from cache synchronously before any fetch completes — this enables instant UI responses while fresh data loads in the background
- The garbage collection timer only starts when there are **zero subscribers** — mounted components keep cache entries alive indefinitely

---

### Framework Adapters

TanStack Query's framework-agnostic core is consumed through adapter packages:

| Framework | Package | Primary Hook |
|---|---|---|
| React | `@tanstack/react-query` | `useQuery` |
| Vue | `@tanstack/vue-query` | `useQuery` |
| Solid | `@tanstack/solid-query` | `createQuery` |
| Svelte | `@tanstack/svelte-query` | `createQuery` |
| Angular | `@tanstack/angular-query-experimental` | `injectQuery` |

**Key Points:**
- The React adapter is the most mature and most commonly documented
- The Angular adapter was marked experimental as of the knowledge cutoff — verify current status before production use [Unverified]
- The API surface is largely consistent across adapters, with naming conventions adjusted to match framework idioms (e.g., `createQuery` in Solid follows Solid's reactive primitive naming)

---

### What TanStack Query Is Not

Understanding the boundaries of TanStack Query prevents scope creep:

| It is NOT | Use instead |
|---|---|
| A client state manager | `useState`, Zustand, Jotai, TanStack Store |
| An HTTP client | `fetch`, `axios`, `ky` |
| A GraphQL client | Apollo Client, urql (though Query works with GraphQL) |
| A form library | TanStack Form, React Hook Form |
| A router | TanStack Router, React Router |
| A replacement for all server state | Session/auth state often has distinct requirements |

TanStack Query manages **what you do with the response** — caching, synchronizing, and invalidating — not **how you make the request**.

---

### Comparison with Similar Tools

| Feature | TanStack Query | SWR | RTK Query |
|---|---|---|---|
| Framework support | React, Vue, Solid, Svelte, Angular | React | React (Redux) |
| Mutation management | First-class `useMutation` | Manual | First-class |
| Devtools | Official, robust | Basic | Redux DevTools |
| Cache invalidation | Fine-grained | Tag-based (limited) | Tag-based |
| Infinite queries | Built-in | Built-in | Limited |
| Optimistic updates | Built-in helpers | Manual | Built-in |
| Bundle size (approx.) | ~13kb gzip | ~4kb gzip | Included in RTK |
| Required setup | `QueryClientProvider` | None | Redux store |

[Bundle size figures are approximate and may vary with version and tree-shaking — verify with your bundler. Unverified for current versions.]

---

**Conclusion**

TanStack Query is a purpose-built solution to the problem of **server state** in web applications. It replaces ad hoc `useEffect` + `useState` data fetching patterns with a declarative, cache-driven model that handles deduplication, background refresh, stale detection, and synchronization automatically. Its core abstraction — a query key mapped to a query function, backed by an observable cache — is simple to learn but scales to sophisticated data requirements without fundamental changes in approach.

**Next Steps:**
- Explore `useQuery` in depth: query keys, query functions, and status handling
- Learn `useMutation` and the invalidation pattern for write operations
- Understand query key design — the most consequential architectural decision when using TanStack Query