## TanStack Query — Cache Management — Global Cache Callbacks

---

### What Are Global Cache Callbacks?

Global cache callbacks are handler functions registered on the `QueryCache` or `MutationCache` at the time they are created. They fire in response to cache-level events — such as a query erroring, succeeding, or settling — across **all** queries or mutations in the application, without needing to configure handlers on individual `useQuery` or `useMutation` calls.

**Key Points:**
- Registered once, on the cache instance itself
- Apply to every query or mutation that passes through that cache
- Commonly used for centralized error reporting, logging, and toast notifications
- Do not replace per-query callbacks — both can coexist

---

### Where They Are Configured

Global callbacks are passed as options when constructing `QueryCache` or `MutationCache`, which are then provided to `QueryClient`.

```ts
import { QueryClient, QueryCache, MutationCache } from '@tanstack/react-query'

const queryClient = new QueryClient({
  queryCache: new QueryCache({
    onError: (error, query) => { /* ... */ },
    onSuccess: (data, query) => { /* ... */ },
    onSettled: (data, error, query) => { /* ... */ },
  }),
  mutationCache: new MutationCache({
    onError: (error, variables, context, mutation) => { /* ... */ },
    onSuccess: (data, variables, context, mutation) => { /* ... */ },
    onSettled: (data, error, variables, context, mutation) => { /* ... */ },
    onMutate: (variables, mutation) => { /* ... */ },
  }),
})
```

This `queryClient` is then provided to the app via `QueryClientProvider` as normal.

---

### QueryCache Global Callbacks

#### `onError`

Fires when any query in the cache transitions to an error state.

```ts
new QueryCache({
  onError: (error, query) => {
    console.error(`Query failed:`, query.queryKey, error)
  },
})
```

**Parameters:**

| Parameter | Type | Description |
|---|---|---|
| `error` | `Error` | The error thrown by the query function |
| `query` | `Query` | The internal `Query` instance that failed |

**Key Points:**
- `query.queryKey` gives the key of the failing query
- `query.state` gives the full current state at the time of the callback
- [Inference] This fires after the query has exhausted its retry attempts, not on each failed attempt — exact timing may vary by version

#### `onSuccess`

Fires when any query successfully resolves with data.

```ts
new QueryCache({
  onSuccess: (data, query) => {
    console.log(`Query succeeded:`, query.queryKey, data)
  },
})
```

**Parameters:**

| Parameter | Type | Description |
|---|---|---|
| `data` | `unknown` | The resolved data returned by the query function |
| `query` | `Query` | The internal `Query` instance that succeeded |

#### `onSettled`

Fires after any query completes, regardless of outcome.

```ts
new QueryCache({
  onSettled: (data, error, query) => {
    console.log('Query settled:', query.queryKey)
  },
})
```

**Parameters:**

| Parameter | Type | Description |
|---|---|---|
| `data` | `unknown \| undefined` | Resolved data, or `undefined` on error |
| `error` | `Error \| null` | Error, or `null` on success |
| `query` | `Query` | The internal `Query` instance |

---

### MutationCache Global Callbacks

Mutation cache callbacks receive additional arguments because mutations carry variables, context, and identity metadata.

#### `onError`

```ts
new MutationCache({
  onError: (error, variables, context, mutation) => {
    console.error('Mutation failed:', mutation.options.mutationKey, error)
  },
})
```

#### `onSuccess`

```ts
new MutationCache({
  onSuccess: (data, variables, context, mutation) => {
    console.log('Mutation succeeded:', data)
  },
})
```

#### `onSettled`

```ts
new MutationCache({
  onSettled: (data, error, variables, context, mutation) => {
    console.log('Mutation settled')
  },
})
```

#### `onMutate`

Fires before the mutation function executes. Mirrors the per-mutation `onMutate` but applies globally.

```ts
new MutationCache({
  onMutate: (variables, mutation) => {
    console.log('Mutation starting with:', variables)
  },
})
```

**MutationCache callback parameters:**

| Parameter | Description |
|---|---|
| `data` | Resolved mutation result |
| `error` | Error if mutation failed |
| `variables` | Variables passed to `mutate()` |
| `context` | Value returned from per-mutation `onMutate` (for optimistic updates) |
| `mutation` | Internal `Mutation` instance |

---

### Execution Order: Global vs. Per-Query Callbacks

Both global cache callbacks and per-query/mutation callbacks can be active simultaneously. [Inference] based on observable behavior: per-query callbacks (defined in `useQuery` or `useMutation` options) fire before global cache callbacks. Exact ordering is not guaranteed and may change across versions — do not rely on this order for correctness.

```ts
// Per-query callback
useQuery({
  queryKey: ['user'],
  queryFn: fetchUser,
  onError: (error) => {
    // [Inference] fires first
    console.log('Local onError')
  },
})

// Global cache callback
new QueryCache({
  onError: (error, query) => {
    // [Inference] fires after local
    console.log('Global onError')
  },
})
```

**Note:** Per-query `onSuccess`, `onError`, and `onSettled` options on `useQuery` were **deprecated** in TanStack Query v5. Global cache callbacks remain the recommended pattern for side effects in v5 and later.

---

### Common Use Case — Centralized Error Toasts

Rather than adding error handling to every individual query, global callbacks allow a single registration point.

```ts
import toast from 'react-hot-toast'

const queryClient = new QueryClient({
  queryCache: new QueryCache({
    onError: (error, query) => {
      // Optionally read metadata from query options
      const message =
        (query.meta?.errorMessage as string) ?? error.message ?? 'Something went wrong'
      toast.error(message)
    },
  }),
})
```

Queries can then attach custom metadata via `meta`:

```ts
useQuery({
  queryKey: ['orders'],
  queryFn: fetchOrders,
  meta: {
    errorMessage: 'Failed to load orders. Please try again.',
  },
})
```

**Key Points:**
- `query.meta` is a plain object you define; TanStack Query does not interpret it
- The global callback reads from `meta` to customize behavior per-query without coupling logic into each hook call
- This pattern keeps toast/notification logic out of components entirely

---

### Common Use Case — Global Logging and Monitoring

```ts
import * as Sentry from '@sentry/browser'

const queryClient = new QueryClient({
  queryCache: new QueryCache({
    onError: (error, query) => {
      Sentry.captureException(error, {
        extra: {
          queryKey: query.queryKey,
          queryHash: query.queryHash,
        },
      })
    },
  }),
  mutationCache: new MutationCache({
    onError: (error, variables, _context, mutation) => {
      Sentry.captureException(error, {
        extra: {
          mutationKey: mutation.options.mutationKey,
          variables,
        },
      })
    },
  }),
})
```

---

### Common Use Case — Global Authentication Handling

Global `onError` is a natural place to handle `401 Unauthorized` or `403 Forbidden` responses across all queries.

```ts
new QueryCache({
  onError: (error) => {
    if (error instanceof ApiError && error.status === 401) {
      // Redirect to login or trigger token refresh
      window.location.href = '/login'
    }
  },
})
```

**Key Points:**
- Avoids repeating auth-redirect logic in every query
- [Inference] Care is needed if multiple queries fail simultaneously — the callback may fire multiple times in rapid succession. Debouncing or a flag may be appropriate depending on the redirect mechanism

---

### Relationship to `defaultOptions`

Global cache callbacks and `defaultOptions` are complementary but distinct mechanisms.

| Feature | `defaultOptions` | Global Cache Callbacks |
|---|---|---|
| Purpose | Set default query/mutation config | React to cache-level events |
| Applies to | Query behavior (staleTime, retry, etc.) | Side effects (logging, toasts) |
| Access to Query instance | No | Yes (`query`, `mutation` params) |
| Location | `QueryClient` constructor | `QueryCache` / `MutationCache` constructor |

```ts
const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 60_000,
      retry: 2,
    },
  },
  queryCache: new QueryCache({
    onError: (error, query) => {
      // side effects here
    },
  }),
})
```

---

### What the `Query` Instance Exposes in Callbacks

Within a `QueryCache` callback, the second argument is the internal `Query` object. Useful properties include:

| Property | Description |
|---|---|
| `query.queryKey` | The key array for this query |
| `query.queryHash` | Serialized string form of the key |
| `query.state` | Full state object (data, error, status, fetchStatus) |
| `query.meta` | Custom metadata object attached via `meta` option |
| `query.options` | The resolved options for this query |
| `query.getObserversCount()` | Number of active observers |

[Inference] Not all properties are part of the stable public API. Properties prefixed with `_` or undocumented in the official API reference should be treated as internal and subject to change.

---

### Caveats and Considerations

**Global callbacks fire for background refetches too.**
A background refetch that errors will trigger `onError` even if the component is showing stale data and the user sees no visible failure. Consider checking `query.state.dataUpdatedAt` or similar to distinguish first-load errors from background errors if needed.

**They are not a replacement for error boundaries.**
Global cache callbacks handle side effects. React error boundaries handle rendering failures. Both are needed in a robust application.

**MutationCache `onMutate` does not support returning context.**
Unlike the per-mutation `onMutate` (which can return a value used as `context` for rollback), the global `MutationCache.onMutate` does not propagate a return value as context. [Inference] The `context` in global `onError`/`onSettled` comes from the per-mutation `onMutate` only.

---

**Conclusion:**
Global cache callbacks are the idiomatic TanStack Query mechanism — especially in v5 — for centralizing cross-cutting concerns such as error reporting, authentication handling, and observability. They provide access to the internal `Query` or `Mutation` instance, enabling context-aware behavior without scattering side-effect logic across individual hooks. Pairing them with `query.meta` yields a flexible, scalable pattern for production applications.