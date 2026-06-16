## Error Monitoring for TanStack Query Failures

---

### Overview

Error monitoring in TanStack Query spans several layers: detecting query and mutation failures at the hook level, propagating errors to global handlers, integrating with external observability platforms (Sentry, Datadog, etc.), and surfacing errors appropriately in the UI. TanStack Query provides multiple interception points — per-query callbacks, global `QueryCache` and `MutationCache` event listeners, and Suspense-compatible error boundaries — that together form a complete error observability pipeline.

---

### Error Representation in TanStack Query

When a `queryFn` throws or returns a rejected Promise, TanStack Query captures the thrown value as the query's error state. The error is typed as `unknown` by default in v5.

ts

```ts
const { data, error, isError } = useQuery({
  queryKey: ["posts"],
  queryFn: async () => {
    const res = await fetch("/api/posts");
    if (!res.ok) throw new Error(`HTTP ${res.status}`);
    return res.json();
  },
});

if (isError) {
  // error is typed as unknown in v5
  console.error(error);
}
```

**Key Points**

- In v5, `error` is `unknown` rather than `Error | null`. Narrowing is required before accessing properties.
- TanStack Query does not coerce thrown values — anything thrown from `queryFn` becomes the error, including strings, numbers, or plain objects.
- [Inference] Consistently throwing `Error` instances (rather than arbitrary values) makes downstream error handling and monitoring integrations more reliable; behavior of third-party monitoring SDKs may vary for non-Error values.

#### Narrowing Unknown Errors

ts

```ts
import { isError } from "@tanstack/react-query";

function getErrorMessage(error: unknown): string {
  if (error instanceof Error) return error.message;
  if (typeof error === "string") return error;
  return "An unknown error occurred";
}
```

---

### Retry Behavior and Error Timing

By default, TanStack Query retries failed queries 3 times with exponential backoff before setting `isError: true`. Error monitoring integrations should account for this — the error state surfaces only after all retries are exhausted.

ts

```ts
useQuery({
  queryKey: ["posts"],
  queryFn: fetchPosts,
  retry: 3,                        // default
  retryDelay: attemptIndex =>
    Math.min(1000 * 2 ** attemptIndex, 30000), // default exponential backoff
});
```

**Key Points**

- The `onError` equivalent (via `QueryCache`) fires after all retries are exhausted, not on each attempt.
- [Inference] If monitoring every failed attempt (not just final failures) is required, the `queryFn` itself is the appropriate interception point rather than TanStack Query's error callbacks.
- Setting `retry: false` surfaces errors immediately; useful for monitoring latency-sensitive failure detection.

---

### Global Error Handling via QueryCache

The most reliable interception point for global error monitoring is the `QueryCache` `onError` callback, configured when the `QueryClient` is instantiated. This fires once per query after retries are exhausted.

ts

```ts
import { QueryClient, QueryCache, MutationCache } from "@tanstack/react-query";

const queryClient = new QueryClient({
  queryCache: new QueryCache({
    onError: (error, query) => {
      // error: unknown
      // query: Query object with queryKey, state, meta, etc.
      console.error(
        `Query failed: ${JSON.stringify(query.queryKey)}`,
        error
      );

      // Send to monitoring platform
      reportError(error, {
        queryKey: query.queryKey,
        queryHash: query.queryHash,
      });
    },
  }),
  mutationCache: new MutationCache({
    onError: (error, variables, context, mutation) => {
      console.error("Mutation failed:", error);

      reportError(error, {
        mutationKey: mutation.options.mutationKey,
        variables,
      });
    },
  }),
});
```

**Key Points**

- `QueryCache.onError` receives the final error and the full `Query` instance.
- `query.queryKey` provides context for identifying which resource failed.
- `query.meta` can carry custom metadata set per-query (see [Meta-Driven Monitoring](#meta-driven-monitoring) below).
- This is the single authoritative place to hook monitoring — avoids duplicating `onError` across every `useQuery` call.

---

### Global Error Handling via QueryClient defaultOptions

An alternative (or complement) to `QueryCache.onError` is setting default `onError` behavior through `defaultOptions`. In v5, per-query `onError` callbacks were removed from `useQuery` options; side effects on error must go through `QueryCache` or mutation-level callbacks on `useMutation`.

ts

```ts
const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      retry: 2,
      staleTime: 1000 * 60,
    },
    mutations: {
      retry: 0,
    },
  },
  queryCache: new QueryCache({
    onError: (error, query) => reportToMonitoring(error, query),
  }),
});
```

---

### Per-Query Error Context via meta

The `meta` field on each query carries arbitrary user-defined metadata. This is the recommended pattern for attaching monitoring context (feature name, severity, owner team) to individual queries without polluting the query key.

ts

```ts
useQuery({
  queryKey: ["orders", orderId],
  queryFn: () => fetchOrder(orderId),
  meta: {
    errorMessage: "Failed to load order details",
    feature: "checkout",
    severity: "high",
    team: "payments",
  },
});
```

In the global `QueryCache.onError`:

ts

```ts
new QueryCache({
  onError: (error, query) => {
    const meta = query.meta as Record<string, unknown> | undefined;

    reportError(error, {
      queryKey: query.queryKey,
      feature: meta?.feature,
      severity: meta?.severity,
      team: meta?.team,
      userMessage: meta?.errorMessage,
    });

    // Optionally surface a toast using meta
    if (meta?.errorMessage && typeof meta.errorMessage === "string") {
      showToast({ type: "error", message: meta.errorMessage });
    }
  },
});
```

**Key Points**

- `meta` is typed as `Record<string, unknown>` in v5; cast to a specific interface for stricter typing.
- This pattern separates monitoring metadata from query identity and fetching logic.
- [Inference] Using `meta` for toast messages in a global handler reduces duplication across many query call sites; whether this suits a given application's architecture depends on its notification system.

---

### Sentry Integration

Sentry captures exceptions automatically in many frameworks, but TanStack Query errors may not reach Sentry's automatic instrumentation because they are caught internally. Explicit capture in the `QueryCache` handler is required.

ts

```ts
import * as Sentry from "@sentry/react";
import { QueryCache, QueryClient } from "@tanstack/react-query";

const queryClient = new QueryClient({
  queryCache: new QueryCache({
    onError: (error, query) => {
      Sentry.withScope((scope) => {
        scope.setTag("queryKey", JSON.stringify(query.queryKey));
        scope.setTag("queryHash", query.queryHash);
        scope.setContext("query", {
          queryKey: query.queryKey,
          state: query.state.status,
          meta: query.meta,
        });
        scope.setLevel(
          (query.meta?.severity as Sentry.SeverityLevel) ?? "error"
        );

        if (error instanceof Error) {
          Sentry.captureException(error);
        } else {
          Sentry.captureMessage(
            `Non-Error query failure: ${JSON.stringify(error)}`,
            "error"
          );
        }
      });
    },
  }),
});
```

**Key Points**

- `Sentry.withScope` isolates query context to the individual error event without polluting the global scope.
- Non-`Error` thrown values require `captureMessage` rather than `captureException`.
- [Inference] Sentry's automatic React error boundary integration will catch errors thrown by `useSuspenseQuery` if Sentry's `ErrorBoundary` component wraps the tree; behavior depends on Sentry SDK version and configuration.

---

### Datadog RUM Integration

ts

```ts
import { datadogRum } from "@datadog/browser-rum";
import { QueryCache, QueryClient } from "@tanstack/react-query";

const queryClient = new QueryClient({
  queryCache: new QueryCache({
    onError: (error, query) => {
      datadogRum.addError(error instanceof Error ? error : new Error(String(error)), {
        queryKey: JSON.stringify(query.queryKey),
        queryHash: query.queryHash,
        feature: query.meta?.feature as string | undefined,
      });
    },
  }),
});
```

**Key Points**

- `datadogRum.addError` expects an `Error` instance; coerce non-Error values explicitly.
- Custom attributes passed as the second argument appear in Datadog RUM error context.
- [Unverified] Specific Datadog RUM SDK method signatures may vary by version; verify against current Datadog documentation. Disclaimer: SDK behavior is not guaranteed to match this example across all versions.

---

### Monitoring Architecture Diagram

<svg viewBox="0 0 740 420" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="12">
<rect width="740" height="420" fill="#0f1117" rx="12"/>
<text x="370" y="30" text-anchor="middle" fill="#7c8cf8" font-size="14" font-weight="bold">TanStack Query Error Monitoring Pipeline</text>
<!-- queryFn -->
<rect x="40" y="60" width="150" height="44" fill="#1e2230" rx="6" stroke="#7c8cf8" stroke-width="1"/>
<text x="115" y="78" text-anchor="middle" fill="#c9d1f5" font-size="11">queryFn throws</text>
<text x="115" y="94" text-anchor="middle" fill="#8891c0" font-size="10">any value</text>
<!-- Retry engine -->
<rect x="230" y="60" width="160" height="44" fill="#1e2230" rx="6" stroke="#4b5270" stroke-width="1"/>
<text x="310" y="78" text-anchor="middle" fill="#c9d1f5" font-size="11">Retry engine</text>
<text x="310" y="94" text-anchor="middle" fill="#8891c0" font-size="10">default: 3 retries</text>
<!-- Arrow: queryFn → retry -->
<line x1="190" y1="82" x2="228" y2="82" stroke="#4b5270" stroke-width="1.5" marker-end="url(#a1)"/>
<!-- QueryCache.onError -->
<rect x="430" y="60" width="180" height="44" fill="#1a2e20" rx="6" stroke="#34d399" stroke-width="1"/>
<text x="520" y="78" text-anchor="middle" fill="#c9d1f5" font-size="11">QueryCache.onError</text>
<text x="520" y="94" text-anchor="middle" fill="#8891c0" font-size="10">global handler</text>
<!-- Arrow: retry → QueryCache -->
<line x1="390" y1="82" x2="428" y2="82" stroke="#34d399" stroke-width="1.5" marker-end="url(#aG)"/>
<text x="409" y="76" fill="#34d399" font-size="9">exhausted</text>
<!-- Three output branches from QueryCache.onError -->
<!-- Branch 1: Sentry -->
<rect x="310" y="180" width="140" height="40" fill="#2a1a10" rx="6" stroke="#f59e0b" stroke-width="1"/>
<text x="380" y="200" text-anchor="middle" fill="#c9d1f5" font-size="11">Sentry / Datadog</text>
<text x="380" y="213" text-anchor="middle" fill="#8891c0" font-size="10">captureException</text>
<!-- Branch 2: Toast -->
<rect x="490" y="180" width="130" height="40" fill="#1a1a2e" rx="6" stroke="#7c8cf8" stroke-width="1"/>
<text x="555" y="200" text-anchor="middle" fill="#c9d1f5" font-size="11">Toast / UI Alert</text>
<text x="555" y="213" text-anchor="middle" fill="#8891c0" font-size="10">via meta.errorMessage</text>
<!-- Branch 3: Logger -->
<rect x="130" y="180" width="140" height="40" fill="#1e2230" rx="6" stroke="#4b5270" stroke-width="1"/>
<text x="200" y="200" text-anchor="middle" fill="#c9d1f5" font-size="11">Logger / Console</text>
<text x="200" y="213" text-anchor="middle" fill="#8891c0" font-size="10">structured logging</text>
<!-- Arrows from QueryCache to branches -->
<line x1="520" y1="104" x2="520" y2="140" stroke="#34d399" stroke-width="1" stroke-dasharray="3,3"/>
<line x1="520" y1="140" x2="380" y2="140" stroke="#34d399" stroke-width="1" stroke-dasharray="3,3"/>
<line x1="520" y1="140" x2="555" y2="140" stroke="#34d399" stroke-width="1" stroke-dasharray="3,3"/>
<line x1="520" y1="140" x2="200" y2="140" stroke="#34d399" stroke-width="1" stroke-dasharray="3,3"/>
<line x1="380" y1="140" x2="380" y2="180" stroke="#f59e0b" stroke-width="1.5" marker-end="url(#aY)"/>
<line x1="555" y1="140" x2="555" y2="180" stroke="#7c8cf8" stroke-width="1.5" marker-end="url(#aB)"/>
<line x1="200" y1="140" x2="200" y2="180" stroke="#4b5270" stroke-width="1.5" marker-end="url(#a1)"/>
<!-- Suspense path -->
<rect x="40" y="290" width="200" height="44" fill="#1e2230" rx="6" stroke="#ec4899" stroke-width="1"/>
<text x="140" y="308" text-anchor="middle" fill="#c9d1f5" font-size="11">useSuspenseQuery</text>
<text x="140" y="324" text-anchor="middle" fill="#8891c0" font-size="10">throws to error boundary</text>
<rect x="280" y="290" width="200" height="44" fill="#1e2230" rx="6" stroke="#ec4899" stroke-width="1"/>
<text x="380" y="308" text-anchor="middle" fill="#c9d1f5" font-size="11">ErrorBoundary</text>
<text x="380" y="324" text-anchor="middle" fill="#8891c0" font-size="10">catches + renders fallback</text>
<rect x="520" y="290" width="180" height="44" fill="#1e2230" rx="6" stroke="#ec4899" stroke-width="1"/>
<text x="610" y="308" text-anchor="middle" fill="#c9d1f5" font-size="11">QueryErrorResetBoundary</text>
<text x="610" y="324" text-anchor="middle" fill="#8891c0" font-size="10">retry on reset</text>
<line x1="240" y1="312" x2="278" y2="312" stroke="#ec4899" stroke-width="1.5" marker-end="url(#aP)"/>
<line x1="480" y1="312" x2="518" y2="312" stroke="#ec4899" stroke-width="1.5" marker-end="url(#aP)"/>

<text x="370" y="270" text-anchor="middle" fill="`#ec4899`" font-size="11">Suspense / Error Boundary Path</text>
<line x1="100" y1="275" x2="630" y2="275" stroke="`#ec4899`" stroke-width="0.5" stroke-dasharray="4,4"/>

<!-- Arrow markers -->
<defs>
<marker id="a1" markerWidth="7" markerHeight="7" refX="5" refY="3" orient="auto">
<path d="M0,0 L0,6 L7,3 z" fill="#4b5270"/>
</marker>
<marker id="aG" markerWidth="7" markerHeight="7" refX="5" refY="3" orient="auto">
<path d="M0,0 L0,6 L7,3 z" fill="#34d399"/>
</marker>
<marker id="aY" markerWidth="7" markerHeight="7" refX="5" refY="3" orient="auto">
<path d="M0,0 L0,6 L7,3 z" fill="#f59e0b"/>
</marker>
<marker id="aB" markerWidth="7" markerHeight="7" refX="5" refY="3" orient="auto">
<path d="M0,0 L0,6 L7,3 z" fill="#7c8cf8"/>
</marker>
<marker id="aP" markerWidth="7" markerHeight="7" refX="5" refY="3" orient="auto">
<path d="M0,0 L0,6 L7,3 z" fill="#ec4899"/>
</marker>
</defs>
</svg>

---

### QueryErrorResetBoundary

`QueryErrorResetBoundary` works with error boundaries to allow users to retry failed queries. When an error boundary resets, it signals TanStack Query to clear the error state and re-attempt the suspended query.

tsx

```tsx
import {
  QueryErrorResetBoundary,
} from "@tanstack/react-query";
import { ErrorBoundary } from "react-error-boundary";
import { Suspense } from "react";

export function SafePostList() {
  return (
    <QueryErrorResetBoundary>
      {({ reset }) => (
        <ErrorBoundary
          onReset={reset}
          fallbackRender={({ resetErrorBoundary, error }) => (
            <div>
              <p>Failed to load: {error.message}</p>
              <button onClick={resetErrorBoundary}>Retry</button>
            </div>
          )}
        >
          <Suspense fallback={<p>Loading…</p>}>
            <PostList />
          </Suspense>
        </ErrorBoundary>
      )}
    </QueryErrorResetBoundary>
  );
}
```

**Key Points**

- `QueryErrorResetBoundary` exposes a `reset` function that must be called when the error boundary resets.
- Without calling `reset`, the query remains in error state and re-suspending will immediately throw again.
- [Inference] This pattern is well-suited for non-critical UI panels where users can self-recover without a full page reload.

---

### Monitoring Mutations

Mutations have their own error lifecycle. Global mutation error monitoring goes through `MutationCache`:

ts

```ts
import { MutationCache, QueryClient } from "@tanstack/react-query";

const queryClient = new QueryClient({
  mutationCache: new MutationCache({
    onError: (error, variables, context, mutation) => {
      reportError(error, {
        mutationKey: mutation.options.mutationKey,
        variables,
        // meta is available on mutations too
        meta: mutation.options.meta,
      });
    },
  }),
});
```

Per-mutation error handling at the call site remains available via `useMutation`:

ts

```ts
const mutation = useMutation({
  mutationFn: createPost,
  onError: (error, variables, context) => {
    // Local handler — fires in addition to MutationCache.onError
    showToast(`Could not create post: ${getErrorMessage(error)}`);
  },
});
```

**Key Points**

- Both `MutationCache.onError` and `useMutation`'s `onError` fire independently; they are not mutually exclusive.
- [Inference] Avoid logging the same error twice to a monitoring platform by handling global reporting only in `MutationCache.onError` and reserving `useMutation.onError` for local UI effects.
- `variables` in `MutationCache.onError` contains the arguments passed to `mutationFn` — useful for debugging but may contain PII; redact before logging.

---

### Structured Error Logging Pattern

For applications that need structured logs (JSON format for log aggregation pipelines), a consistent error log schema can be applied in the `QueryCache` handler:

ts

```ts
interface QueryErrorLog {
  timestamp: string;
  level: "error";
  event: "query_failure";
  queryKey: unknown[];
  queryHash: string;
  errorType: string;
  errorMessage: string;
  retryCount: number;
  feature?: string;
  team?: string;
}

new QueryCache({
  onError: (error, query) => {
    const log: QueryErrorLog = {
      timestamp: new Date().toISOString(),
      level: "error",
      event: "query_failure",
      queryKey: query.queryKey as unknown[],
      queryHash: query.queryHash,
      errorType: error instanceof Error ? error.constructor.name : typeof error,
      errorMessage: error instanceof Error ? error.message : String(error),
      retryCount: query.state.fetchFailureCount,
      feature: query.meta?.feature as string | undefined,
      team: query.meta?.team as string | undefined,
    };

    console.error(JSON.stringify(log));
    // Or: sendToLogAggregator(log);
  },
});
```

**Key Points**

- `query.state.fetchFailureCount` tracks how many attempts were made before the final failure.
- Structured JSON logs are consumable by tools like Loki, CloudWatch Logs Insights, and Datadog Log Management.
- [Inference] Including `queryHash` in logs aids in correlating errors across multiple users hitting the same query.

---

### Differentiating Error Types

Not all query failures are equal. HTTP errors, network failures, and application-level errors warrant different monitoring responses.

ts

```ts
class HttpError extends Error {
  constructor(
    public status: number,
    public statusText: string,
    message: string
  ) {
    super(message);
    this.name = "HttpError";
  }
}

async function fetchWithErrorHandling(url: string) {
  const res = await fetch(url);
  if (!res.ok) {
    throw new HttpError(res.status, res.statusText, `${res.status} ${res.statusText}`);
  }
  return res.json();
}
```

In the `QueryCache` handler:

ts

```ts
new QueryCache({
  onError: (error, query) => {
    if (error instanceof HttpError) {
      if (error.status >= 500) {
        // Server error — high severity
        reportError(error, { severity: "critical" });
      } else if (error.status === 404) {
        // Not found — may be expected, low severity
        reportError(error, { severity: "warning" });
      } else if (error.status === 401 || error.status === 403) {
        // Auth error — handle separately, may not need monitoring
        redirectToLogin();
        return;
      }
    } else {
      // Network error or unexpected throw
      reportError(error, { severity: "error", type: "network" });
    }
  },
});
```

**Key Points**

- Custom error classes enable precise branching in the global handler.
- 4xx errors often represent expected states (missing resources, expired sessions) and may not warrant the same monitoring severity as 5xx errors.
- [Inference] Filtering 401/403 errors from monitoring reduces noise in authentication-gated applications; whether this is appropriate depends on the security model.

---

### Suppressing Expected Errors from Monitoring

Some errors are anticipated (offline mode, expected 404s) and should not trigger monitoring alerts. The `meta` field can carry a suppression flag:

ts

```ts
useQuery({
  queryKey: ["draft", draftId],
  queryFn: () => fetchDraft(draftId),
  meta: {
    suppressMonitoring: true,
  },
});
```

ts

```ts
new QueryCache({
  onError: (error, query) => {
    if (query.meta?.suppressMonitoring) return;
    reportError(error, { queryKey: query.queryKey });
  },
});
```

---

### Testing Error Monitoring Hooks

Verifying that the `QueryCache.onError` handler fires correctly requires testing with a controlled `QueryClient`:

ts

```ts
import { QueryClient, QueryCache } from "@tanstack/react-query";
import { renderHook, waitFor } from "@testing-library/react";

test("QueryCache.onError fires after query failure", async () => {
  const onError = vi.fn();

  const queryClient = new QueryClient({
    queryCache: new QueryCache({ onError }),
    defaultOptions: { queries: { retry: false } },
  });

  const wrapper = ({ children }) => (
    <QueryClientProvider client={queryClient}>{children}</QueryClientProvider>
  );

  renderHook(
    () =>
      useQuery({
        queryKey: ["test"],
        queryFn: () => Promise.reject(new Error("fetch failed")),
      }),
    { wrapper }
  );

  await waitFor(() => expect(onError).toHaveBeenCalledOnce());

  const [error, query] = onError.mock.calls[0];
  expect(error.message).toBe("fetch failed");
  expect(query.queryKey).toEqual(["test"]);
});
```

**Key Points**

- Set `retry: false` in tests to avoid waiting for retry delays.
- `vi.fn()` (Vitest) or `jest.fn()` both work as mock handlers.
- Test the `query` argument to verify that metadata and query key are correctly threaded through.

---

**Related Topics**

- `QueryObserver` for programmatic query state observation outside React
- Custom `QueryCache` event listeners (`subscribe`) for fine-grained event tracking
- OpenTelemetry tracing integration with `queryFn` spans
- Network error detection and offline mode handling
- `onSettled` in mutations for monitoring both success and failure
- Alerting thresholds and error rate dashboards in Datadog / Sentry
- Deduplication of query errors in monitoring platforms
- `throwOnError` option and its interaction with Suspense error boundaries