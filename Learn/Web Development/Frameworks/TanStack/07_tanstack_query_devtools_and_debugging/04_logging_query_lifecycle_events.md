## TanStack Query — Logging Query Lifecycle Events

### Overview

TanStack Query does not emit lifecycle events through a built-in event emitter API in the way that some libraries do. Observing query lifecycle events — fetch start, success, error, cancellation, cache updates — requires hooking into the available extension points: query-level callbacks, `QueryCache` event listeners, and `QueryClient` observer APIs. This is useful for debugging, telemetry, analytics, and structured logging pipelines.

---

### Query-Level Callbacks

The most direct way to log individual query events is through the callback options available on `useQuery` and `queryClient.fetchQuery`.

```ts
useQuery({
  queryKey: ['orders'],
  queryFn: fetchOrders,
  meta: { label: 'orders-list' },
})
```

As of TanStack Query v5, the `onSuccess`, `onError`, and `onSettled` callbacks were removed from `useQuery`. [Unverified: exact version of removal for all framework adapters — verify against your adapter's changelog.]

Lifecycle observation for individual queries in v5 is handled through:

- `QueryCache` global event listeners (covered below)
- The `meta` field for attaching contextual labels
- Side effects inside `queryFn` itself
- `useEffect` watching `data` and `error` from `useQuery`

---

### Observing Lifecycle via `useEffect`

For component-scoped logging, watch `data`, `error`, `isFetching`, and `status` as reactive values:

```ts
const { data, error, isFetching, status, fetchStatus } = useQuery({
  queryKey: ['orders'],
  queryFn: fetchOrders,
})

useEffect(() => {
  if (isFetching) {
    console.log('[orders] fetch started')
  }
}, [isFetching])

useEffect(() => {
  if (status === 'success' && data) {
    console.log('[orders] fetch succeeded', { data })
  }
}, [status, data])

useEffect(() => {
  if (status === 'error' && error) {
    console.error('[orders] fetch failed', { error })
  }
}, [status, error])
```

**Key Points:**
- `isFetching` becomes `true` for both initial fetches and background refetches. Logging on `isFetching` captures both.
- `status` reflects the data availability state (`pending`, `success`, `error`), not whether a fetch is in progress.
- `fetchStatus` (`'fetching'`, `'paused'`, `'idle'`) provides finer resolution on the network-level state.
- [Inference] This approach produces per-component logs. If the same query is observed by multiple components, each will fire its own effects, potentially producing duplicate log entries.

---

### `QueryCache` Global Event Listener

The most comprehensive approach to lifecycle logging is subscribing to the `QueryCache` event system. This is the recommended pattern for application-wide observability.

#### Setup

```ts
import { QueryClient, QueryCache } from '@tanstack/react-query'

const queryCache = new QueryCache({
  onError: (error, query) => {
    console.error('[QueryCache] query error', {
      queryKey: query.queryKey,
      error,
    })
  },
  onSuccess: (data, query) => {
    console.log('[QueryCache] query success', {
      queryKey: query.queryKey,
    })
  },
  onSettled: (data, error, query) => {
    console.log('[QueryCache] query settled', {
      queryKey: query.queryKey,
      hasData: data !== undefined,
      hasError: error !== null,
    })
  },
})

const queryClient = new QueryClient({ queryCache })
```

**Key Points:**
- These callbacks fire for every query managed by this `QueryClient`, not just a single query key.
- `onError` here fires at the cache level — after all retries are exhausted.
- `onSuccess` fires whenever a fetch resolves successfully, including background refetches.

---

### `QueryCache.subscribe` — Full Event Stream

Beyond the constructor callbacks, `QueryCache` exposes a `subscribe` method that receives all internal cache events as a stream. This is the most granular observability surface available.

```ts
const unsubscribe = queryClient.getQueryCache().subscribe((event) => {
  console.log('[QueryCache event]', {
    type: event.type,
    queryKey: event.query.queryKey,
    queryHash: event.query.queryHash,
    state: event.query.state,
  })
})

// Call unsubscribe() when no longer needed to avoid memory leaks
```

#### Event Types

| `event.type` | When it fires |
|---|---|
| `added` | A new query key is registered in the cache for the first time |
| `removed` | A query is garbage collected and removed from the cache |
| `updated` | Any state change on the query (fetch start, success, error, data update) |
| `observerAdded` | A component mounts and subscribes to a query |
| `observerRemoved` | A component unmounts and unsubscribes |
| `observerResultsUpdated` | An observer's result object changes (distinct from cache state change) |

[Inference] The `updated` event is the most frequent. Filtering by `event.action?.type` within the `updated` event provides finer resolution. The internal action types are not part of the public API and may change across minor versions — use with caution.

#### Filtering for Specific Lifecycle Moments

```ts
queryClient.getQueryCache().subscribe((event) => {
  const { type, query } = event

  if (type === 'added') {
    console.log('[lifecycle] query registered', query.queryKey)
  }

  if (type === 'removed') {
    console.log('[lifecycle] query garbage collected', query.queryKey)
  }

  if (type === 'updated') {
    const { status, fetchStatus } = query.state

    if (fetchStatus === 'fetching') {
      console.log('[lifecycle] fetch started', query.queryKey)
    }

    if (status === 'success') {
      console.log('[lifecycle] fetch succeeded', query.queryKey, query.state.data)
    }

    if (status === 'error') {
      console.error('[lifecycle] fetch errored', query.queryKey, query.state.error)
    }
  }
})
```

**Key Points:**
- The `updated` event fires multiple times per fetch cycle (on fetch start, on completion, on state transitions). Guard log statements with specific state checks to avoid flooding output.
- `query.state` reflects the state after the event has been applied.

---

### Attaching Context with `meta`

The `meta` field on query options is a freeform object that is accessible on the `Query` instance inside cache callbacks. Use it to attach structured context for log enrichment.

```ts
useQuery({
  queryKey: ['invoice', invoiceId],
  queryFn: () => fetchInvoice(invoiceId),
  meta: {
    label: 'invoice-detail',
    module: 'billing',
    critical: true,
  },
})
```

```ts
const queryCache = new QueryCache({
  onError: (error, query) => {
    const { label, module, critical } = query.meta ?? {}
    console.error('[query error]', {
      label,
      module,
      critical,
      key: query.queryKey,
      message: error.message,
    })
  },
})
```

**Key Points:**
- `meta` is not typed by default. Augment the `Register` interface in TypeScript to add type safety:

```ts
declare module '@tanstack/react-query' {
  interface Register {
    queryMeta: {
      label?: string
      module?: string
      critical?: boolean
    }
  }
}
```

- [Inference] This pattern is particularly useful for routing cache-level errors to different log sinks (e.g., critical queries to an alerting service, others to standard logging).

---

### Logging Retry Attempts

TanStack Query retries failed queries automatically (default: 3 retries with exponential backoff). Retry attempts are not exposed as a distinct event type on `QueryCache`. To log retry attempts, intercept inside `queryFn` or use a wrapper:

```ts
function withRetryLogging<T>(
  key: string,
  fn: () => Promise<T>
): () => Promise<T> {
  let attempt = 0
  return async () => {
    attempt++
    console.log(`[retry] ${key} — attempt ${attempt}`)
    try {
      const result = await fn()
      console.log(`[retry] ${key} — succeeded on attempt ${attempt}`)
      return result
    } catch (error) {
      console.warn(`[retry] ${key} — failed on attempt ${attempt}`, error)
      throw error
    }
  }
}

useQuery({
  queryKey: ['payments'],
  queryFn: withRetryLogging('payments', fetchPayments),
})
```

[Inference] Because TanStack Query calls `queryFn` again on each retry, the wrapper function is re-invoked per attempt. The `attempt` counter is captured in the outer closure and increments across retries for a single query lifecycle. This behavior depends on closure semantics and is not a documented guarantee.

---

### Structured Log Output Pattern

For production-grade logging pipelines, normalize query lifecycle events into a consistent structure before forwarding to a log sink:

```ts
type QueryLifecycleEvent = {
  timestamp: string
  event: string
  queryKey: unknown[]
  queryHash: string
  meta?: Record<string, unknown>
  error?: string
  durationMs?: number
}

const fetchStartTimes = new Map<string, number>()

queryClient.getQueryCache().subscribe((event) => {
  const { query, type } = event
  const base = {
    timestamp: new Date().toISOString(),
    queryKey: query.queryKey,
    queryHash: query.queryHash,
    meta: query.meta ?? {},
  }

  if (type === 'updated') {
    const { fetchStatus, status } = query.state

    if (fetchStatus === 'fetching') {
      fetchStartTimes.set(query.queryHash, Date.now())
      log({ ...base, event: 'fetch_start' })
    }

    if (status === 'success' && fetchStatus === 'idle') {
      const start = fetchStartTimes.get(query.queryHash)
      const durationMs = start ? Date.now() - start : undefined
      fetchStartTimes.delete(query.queryHash)
      log({ ...base, event: 'fetch_success', durationMs })
    }

    if (status === 'error') {
      const start = fetchStartTimes.get(query.queryHash)
      const durationMs = start ? Date.now() - start : undefined
      fetchStartTimes.delete(query.queryHash)
      log({
        ...base,
        event: 'fetch_error',
        durationMs,
        error: String(query.state.error),
      })
    }
  }

  if (type === 'removed') {
    log({ ...base, event: 'cache_gc' })
  }
})

function log(entry: QueryLifecycleEvent) {
  // Replace with your log sink: console, Datadog, Sentry, etc.
  console.log(JSON.stringify(entry))
}
```

**Key Points:**
- `fetchStartTimes` tracks when each fetch began using `queryHash` as the key, enabling duration calculation.
- [Inference] Concurrent fetches for the same query key (e.g., triggered by rapid remounts) may overwrite the start time. For high-concurrency scenarios, a more robust tracking strategy may be needed.
- The `log` function is the single exit point — swap it for any external sink without changing event detection logic.

---

### Cleanup and Memory Considerations

`QueryCache.subscribe` returns an unsubscribe function. Always call it when the subscription is no longer needed to avoid memory leaks and stale listeners:

```ts
// In a non-React context (e.g., a service module)
const unsubscribe = queryClient.getQueryCache().subscribe(handler)

// When tearing down
unsubscribe()
```

In React, register the subscription in a top-level effect with proper cleanup:

```ts
useEffect(() => {
  const unsubscribe = queryClient.getQueryCache().subscribe((event) => {
    // handle event
  })
  return unsubscribe
}, [queryClient])
```

[Inference] Subscribing inside a component that remounts frequently will register multiple listeners unless cleanup is handled correctly. The `useEffect` cleanup pattern above addresses this under normal React rendering behavior, but behavior may vary under concurrent mode or strict mode double-invocation.

---