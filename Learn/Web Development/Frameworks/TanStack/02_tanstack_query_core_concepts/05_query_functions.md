## TanStack Query — Core Concepts — Query Functions

---

### What Is a Query Function?

A query function is the function passed to `useQuery` (or related hooks) that performs the actual data fetching. TanStack Query does not dictate how data is fetched — it only requires that the query function returns a **Promise** that either resolves with data or rejects with an error.

**Key Points**
- Must return a `Promise`
- Resolved value becomes the cached data
- Rejected Promise (or thrown error) triggers error state
- Can be any async operation: `fetch`, `axios`, GraphQL client, etc.

---

### Basic Syntax

```ts
useQuery({
  queryKey: ['todos'],
  queryFn: () => fetch('/api/todos').then(res => res.json()),
})
```

The `queryFn` property accepts any function matching this signature:

```ts
type QueryFunction<TData, TQueryKey extends QueryKey> = (
  context: QueryFunctionContext<TQueryKey>
) => TData | Promise<TData>
```

---

### The Query Function Context

TanStack Query automatically passes a `QueryFunctionContext` object as the first argument to every query function. This is useful for accessing the query key and other metadata inside the function body.

```ts
useQuery({
  queryKey: ['todos', { status: 'active', page: 1 }],
  queryFn: ({ queryKey }) => {
    const [_key, filters] = queryKey
    return fetchTodos(filters)
  },
})
```

**Context properties:**

| Property | Type | Description |
|---|---|---|
| `queryKey` | `QueryKey` | The full query key for this query |
| `signal` | `AbortSignal` | For request cancellation |
| `meta` | `Record<string, unknown> \| undefined` | Optional metadata passed via `meta` option |
| `pageParam` | `unknown` | Used in infinite queries (see Infinite Queries) |
| `direction` | `'forward' \| 'backward'` | Infinite query fetch direction |

---

### Using the AbortSignal

TanStack Query provides an `AbortSignal` via the context object. Passing this signal to your fetch call allows TanStack Query to cancel in-flight requests when a query becomes inactive (e.g., component unmounts).

```ts
useQuery({
  queryKey: ['todos'],
  queryFn: ({ signal }) =>
    fetch('/api/todos', { signal }).then(res => res.json()),
})
```

**Key Points**
- Cancellation is cooperative — the fetch must accept and respect the signal
- `axios` supports `signal` directly as of v0.22+
- If the signal is not forwarded, the HTTP request will complete even after the query is abandoned
- [Inference] Failing to pass the signal may increase unnecessary network load in apps with frequent route changes

---

### Error Handling

If the query function throws or returns a rejected Promise, TanStack Query treats the query as failed and populates the `error` field.

```ts
useQuery({
  queryKey: ['todos'],
  queryFn: async () => {
    const res = await fetch('/api/todos')
    if (!res.ok) {
      throw new Error(`Request failed: ${res.status}`)
    }
    return res.json()
  },
})
```

**Key Points**
- `fetch` does **not** throw on non-2xx status codes by default — you must check `res.ok` manually
- `axios` throws automatically on non-2xx responses
- The thrown value becomes `query.error`
- TanStack Query will retry failed queries according to the `retry` option (default: 3 retries)

---

### Returning `null` or `undefined`

Query functions may return `null` or `undefined`. These are treated as valid resolved values, not errors. The query enters a success state with `data` set to `null` or `undefined`.

```ts
useQuery({
  queryKey: ['user', userId],
  queryFn: async () => {
    const user = await getUser(userId)
    return user ?? null  // explicitly returning null is valid
  },
})
```

**Key Points**
- Behavior may vary depending on how downstream code handles `undefined` data
- [Inference] Returning `undefined` can cause confusion if the query is expected to always populate data — prefer `null` for "empty but successful" states

---

### Inline vs. Extracted Query Functions

Query functions can be defined inline or extracted for reuse.

**Inline**
```ts
useQuery({
  queryKey: ['todos'],
  queryFn: () => axios.get('/api/todos').then(r => r.data),
})
```

**Extracted (reusable)**
```ts
const fetchTodos = async (): Promise<Todo[]> => {
  const res = await axios.get('/api/todos')
  return res.data
}

useQuery({
  queryKey: ['todos'],
  queryFn: fetchTodos,
})
```

**Extracted with context**
```ts
const fetchTodoById = async ({ queryKey }: QueryFunctionContext) => {
  const [, id] = queryKey
  const res = await axios.get(`/api/todos/${id}`)
  return res.data
}

useQuery({
  queryKey: ['todos', todoId],
  queryFn: fetchTodoById,
})
```

**Key Points**
- Extracted functions improve testability and reuse
- When using context-based extraction, the function signature must accept `QueryFunctionContext`
- [Inference] Inline functions defined in component body are recreated each render, but TanStack Query does not use referential equality on `queryFn` to trigger refetches — the `queryKey` drives caching behavior

---

### Query Functions and TypeScript

TanStack Query infers the return type of `useQuery` from the return type of `queryFn`. Explicit typing is optional but recommended for clarity.

```ts
interface Todo {
  id: number
  title: string
  completed: boolean
}

const { data } = useQuery<Todo[]>({
  queryKey: ['todos'],
  queryFn: async (): Promise<Todo[]> => {
    const res = await fetch('/api/todos')
    return res.json()
  },
})
// data is typed as Todo[] | undefined
```

**Key Points**
- `data` is always `TData | undefined` until the query resolves
- Pass generic type parameters to `useQuery<TData, TError>` for full control
- Mismatches between inferred and actual return types may surface at runtime rather than compile time if `res.json()` is used without assertion

---

### Using a Default Query Function

A global default query function can be set on the `QueryClient`. This allows query keys to implicitly define the fetch endpoint, reducing repetition.

```ts
const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      queryFn: async ({ queryKey }) => {
        const [url] = queryKey as string[]
        const res = await fetch(url)
        if (!res.ok) throw new Error('Network response was not ok')
        return res.json()
      },
    },
  },
})

// Now queryKey doubles as the URL
useQuery({ queryKey: ['/api/todos'] })
useQuery({ queryKey: ['/api/users'] })
```

**Key Points**
- Individual `useQuery` calls can still override `queryFn` locally
- This pattern couples query keys to URL structure — [Inference] may reduce flexibility in larger applications where keys carry non-URL metadata
- `queryFn` is required per query OR must be set as a default; omitting both will throw

---

### Dependent (Derived) Query Functions

Query functions can reference external values via closure. Combined with the `enabled` option, this supports dependent queries.

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
- The second query will not execute until `user` is truthy
- `user!.id` is safe here because `enabled: !!user` guards execution
- Query key should include all variables the function depends on to maintain cache correctness

---

### Query Function Best Practices

**Always throw on error**
Never swallow errors silently inside a query function. TanStack Query cannot detect an error state unless the function throws or rejects.

```ts
// ❌ Incorrect — error is hidden
queryFn: async () => {
  try {
    return await fetchData()
  } catch {
    return null
  }
}

// ✅ Correct — let errors propagate
queryFn: () => fetchData()
```

**Include all dependencies in the query key**
The query key acts as the cache key. If your function uses a variable (e.g., `userId`, `page`), it must appear in the key.

```ts
// ❌ Cache miss risk
queryKey: ['user'],
queryFn: () => fetchUser(userId)

// ✅ Correct
queryKey: ['user', userId],
queryFn: () => fetchUser(userId)
```

**Forward the AbortSignal when possible**
```ts
queryFn: ({ signal }) => fetch('/api/data', { signal }).then(r => r.json())
```

**Keep query functions pure and focused**
Query functions should fetch and return data. Side effects (logging, analytics, etc.) are better placed in `onSuccess` callbacks or `useEffect` — though note that `onSuccess` on `useQuery` was deprecated in TanStack Query v5.

---

### Relationship to Query Keys

Query functions and query keys are tightly coupled. The query key determines:

- Whether a cached result exists (cache hit vs. miss)
- When the query should re-run (key change triggers new fetch)
- How the result is shared across components

```
Query Key ──► Cache Lookup ──► [Miss] ──► Query Function Executes
                                │
                             [Hit] ──► Return cached data
```

This means the query function is not called if a valid cached result already exists for the given key (subject to `staleTime` and `gcTime` settings).

---

**Conclusion**

Query functions are the execution core of TanStack Query — they define *what* gets fetched while the library manages *when*, *how often*, and *for whom*. Understanding the context object, error propagation, AbortSignal usage, and the relationship between query keys and functions is foundational to using TanStack Query effectively. Behavior described here applies to TanStack Query v5; some details may differ in earlier versions.