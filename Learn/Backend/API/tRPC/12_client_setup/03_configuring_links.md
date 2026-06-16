## tRPC Client — Configuring Links

Links are the middleware layer of the tRPC client. They form a chain that every request and response passes through before reaching the server and before being returned to the caller. Configuring links correctly determines how your client communicates, handles errors, and logs traffic.

---

### What a Link Is

A link is a function that receives an operation (a query, mutation, or subscription) and returns an observable. Each link in the chain can inspect, modify, forward, or terminate the operation. The final link in the chain is always a *terminating link* — it sends the request over the network and produces a response.

Links are passed to the `createTRPCClient` or `createTRPCReact` client factory via the `links` array.

```ts
import { createTRPCClient } from '@trpc/client';
import { httpBatchLink } from '@trpc/client';
import type { AppRouter } from '../server/router';

const client = createTRPCClient<AppRouter>({
  links: [
    httpBatchLink({
      url: 'http://localhost:3000/api/trpc',
    }),
  ],
});
```

---

### The Links Array and Execution Order

Links execute in order for outgoing requests and in reverse order for incoming responses — identical in concept to Express middleware or the Fetch API interceptor pattern.

```
Request  →  [Link 1]  →  [Link 2]  →  [Terminating Link]  →  Server
Response ←  [Link 1]  ←  [Link 2]  ←  [Terminating Link]  ←  Server
```

**Key Points**
- Every element except the last may be a non-terminating (passthrough) link.
- The last element must be a terminating link. Placing a non-terminating link last will cause requests to hang, as nothing sends them to the server.
- Order matters: a logging link placed before an auth link sees the request before credentials are attached.

---

### Built-in Links

#### httpBatchLink

The standard terminating link. Batches multiple simultaneous procedure calls into a single HTTP request.

```ts
import { httpBatchLink } from '@trpc/client';

httpBatchLink({
  url: '/api/trpc',
  headers() {
    return {
      Authorization: `Bearer ${getToken()}`,
    };
  },
})
```

**Key Points**
- Batching is enabled by default. Multiple calls made in the same tick are grouped into one request.
- The `headers` option accepts a static object or a function (sync or async) that returns headers per request.
- Batching can cause issues if individual procedures have different authentication requirements or caching rules.

#### httpLink

The non-batching variant. Each procedure call produces exactly one HTTP request. Useful when batching is undesirable — for example, when individual requests need distinct cache headers or when debugging.

```ts
import { httpLink } from '@trpc/client';

httpLink({
  url: '/api/trpc',
})
```

#### httpBatchStreamLink

A streaming variant of `httpBatchLink` introduced to support deferred/streamed responses. Responses arrive as a stream rather than waiting for all batched results to resolve.

```ts
import { httpBatchStreamLink } from '@trpc/client';

httpBatchStreamLink({
  url: '/api/trpc',
})
```

**Key Points**
- Requires the server to be configured with a compatible response formatter.
- [Inference] Particularly beneficial when batched queries have highly variable response times, since fast responses arrive immediately rather than waiting for the slowest.

#### wsLink

The terminating link for WebSocket connections. Required for subscriptions.

```ts
import { wsLink, createWSClient } from '@trpc/client';

const wsClient = createWSClient({
  url: 'ws://localhost:3000/api/trpc',
});

wsLink({
  client: wsClient,
})
```

#### splitLink

Not a terminating link itself, but a conditional router. It directs operations to one link or another based on a predicate.

```ts
import { splitLink, wsLink, httpBatchLink, createWSClient } from '@trpc/client';

const wsClient = createWSClient({ url: 'ws://localhost:3000/api/trpc' });

splitLink({
  condition(op) {
    return op.type === 'subscription';
  },
  true: wsLink({ client: wsClient }),
  false: httpBatchLink({ url: '/api/trpc' }),
})
```

This is the canonical pattern for applications that use both HTTP and WebSockets: subscriptions go to `wsLink`, everything else goes to `httpBatchLink`.

#### loggerLink

A non-terminating link for development logging. Logs outgoing operations and incoming results to the console.

```ts
import { loggerLink } from '@trpc/client';

loggerLink({
  enabled(opts) {
    return process.env.NODE_ENV === 'development';
  },
})
```

**Key Points**
- Place `loggerLink` before the terminating link so it observes the full round trip.
- The `enabled` function receives the operation and result, allowing conditional logging (e.g., log only errors in production).

---

### Writing a Custom Link

A custom link is a function matching the `TRPCLink<TRouter>` type. It receives `opts` containing the operation and the `next` function to forward to the next link in the chain.

```ts
import type { TRPCLink } from '@trpc/client';
import { observable } from '@trpc/server/observable';
import type { AppRouter } from '../server/router';

const customHeaderLink: TRPCLink<AppRouter> = () => {
  return ({ next, op }) => {
    // Modify the operation context before forwarding
    return observable((observer) => {
      const subscription = next(op).subscribe({
        next(value) {
          observer.next(value);
        },
        error(err) {
          observer.error(err);
        },
        complete() {
          observer.complete();
        },
      });

      return subscription;
    });
  };
};
```

**Key Points**
- The outer function runs once when the client is initialized.
- The inner function runs once per operation.
- The observable callback runs each time the operation produces a value (relevant for subscriptions, which emit multiple times).
- Custom links are composable: they can modify the `op` object, inspect the response, retry on error, or short-circuit without calling `next`.

---

### Retry Logic via a Custom Link

tRPC does not ship a built-in retry link. [Inference] A custom link is the standard approach for implementing retry behavior. Behavior of retry logic in production depends on implementation and network conditions; outcomes are not guaranteed.

```ts
import type { TRPCLink } from '@trpc/client';
import { observable } from '@trpc/server/observable';
import type { AppRouter } from '../server/router';

const retryLink: TRPCLink<AppRouter> = () => {
  return ({ next, op }) => {
    return observable((observer) => {
      let attempts = 0;

      const attempt = () => {
        attempts++;
        next(op).subscribe({
          next(value) {
            observer.next(value);
          },
          error(err) {
            if (attempts < 3) {
              attempt();
            } else {
              observer.error(err);
            }
          },
          complete() {
            observer.complete();
          },
        });
      };

      attempt();
    });
  };
};
```

---

### Composing Multiple Links

A realistic client setup composes several links:

```ts
import {
  createTRPCClient,
  loggerLink,
  splitLink,
  httpBatchLink,
  wsLink,
  createWSClient,
} from '@trpc/client';
import type { AppRouter } from '../server/router';

const wsClient = createWSClient({
  url: `ws://localhost:3000/api/trpc`,
});

const client = createTRPCClient<AppRouter>({
  links: [
    loggerLink({
      enabled: (opts) =>
        process.env.NODE_ENV === 'development' ||
        (opts.direction === 'down' && opts.result instanceof Error),
    }),
    splitLink({
      condition(op) {
        return op.type === 'subscription';
      },
      true: wsLink({ client: wsClient }),
      false: httpBatchLink({
        url: '/api/trpc',
        headers() {
          return {
            Authorization: `Bearer ${localStorage.getItem('token')}`,
          };
        },
      }),
    }),
  ],
});
```

**Key Points**
- `loggerLink` is first, so it logs every operation regardless of whether it becomes a subscription or an HTTP call.
- `splitLink` is the terminating position logically, because both of its branches are terminating links.
- The `headers` function is called per-request, making it suitable for reading tokens that may change during the session.

---

### The Operation Object

Every link receives an `op` object. Understanding its shape is necessary for writing conditional or transforming links.

| Field | Type | Description |
|---|---|---|
| `id` | `number` | Unique identifier for the operation |
| `type` | `'query' \| 'mutation' \| 'subscription'` | Procedure type |
| `path` | `string` | Dot-separated procedure path (e.g., `user.getById`) |
| `input` | `unknown` | Serialized input passed to the procedure |
| `context` | `object` | Mutable per-operation context shared across links |
| `signal` | `AbortSignal \| null` | Abort signal for cancellation |

The `context` field is particularly useful for passing metadata between links without modifying the input.

---

### Passing Context Between Links

Links can read and write `op.context` to coordinate across the chain.

```ts
// Link A — sets a flag
const markPrivateLink: TRPCLink<AppRouter> = () => {
  return ({ next, op }) => {
    if (op.path.startsWith('admin.')) {
      op.context.requiresAdminToken = true;
    }
    return next(op);
  };
};

// Link B — reads the flag
const authLink: TRPCLink<AppRouter> = () => {
  return ({ next, op }) => {
    const token = op.context.requiresAdminToken
      ? getAdminToken()
      : getUserToken();
    // Attach token to request headers via context or other mechanism
    return next({ ...op, context: { ...op.context, token } });
  };
};
```

[Inference] The exact mechanism for propagating context values into HTTP headers depends on the terminating link's implementation. `httpBatchLink` accepts a `headers` function that can read from a shared store, but does not natively read from `op.context` directly.

---

### Common Mistakes

**Using a non-terminating link as the last entry**
Requests will never be sent. The links array must end with a terminating link (`httpLink`, `httpBatchLink`, `wsLink`, or a `splitLink` whose branches are both terminating).

**Placing loggerLink after the terminating link**
Links after the terminating link are never reached. Logger must come before it.

**Sharing a single `wsClient` instance across multiple client instances**
[Inference] This may produce unexpected behavior with connection lifecycle management. Each logical client should own its WebSocket client instance.

**Reading mutable state synchronously in the `links` array**
The `links` array is evaluated once at client construction. For values that change over time (tokens, feature flags), use the function form of `headers` or a custom link rather than reading the value at construction time.

---