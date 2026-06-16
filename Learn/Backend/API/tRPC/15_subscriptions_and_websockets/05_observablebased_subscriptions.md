## Observable-based Subscriptions

### What Are Observable-based Subscriptions in tRPC

tRPC's subscription system is built on **observables** — a push-based primitive that models a stream of values over time. Rather than returning a single response like a query or mutation, a subscription procedure returns an observable that emits values to connected clients as events occur on the server.

tRPC ships its own lightweight observable implementation (`@trpc/server/observable`) rather than depending on RxJS, though the concept is the same.

---

### The Observable Primitive

tRPC exposes an `observable()` factory from `@trpc/server/observable`.

```ts
import { observable } from '@trpc/server/observable';
```

The factory accepts a **subscriber function** that receives an `observer` object. The observer has three methods:

| Method | Description |
|---|---|
| `observer.next(value)` | Emit a value to the subscriber |
| `observer.error(err)` | Emit an error and terminate the stream |
| `observer.complete()` | Signal the stream has ended cleanly |

The subscriber function may return a **cleanup function**, which tRPC calls when the client unsubscribes or the connection drops.

**Example — minimal observable:**

```ts
const obs = observable<number>((observer) => {
  let count = 0;
  const interval = setInterval(() => {
    observer.next(count++);
  }, 1000);

  // Cleanup on unsubscribe
  return () => clearInterval(interval);
});
```

---

### Defining a Subscription Procedure

Subscription procedures are defined with `.subscription()` on a router. The handler must return an observable typed to the data shape clients will receive.

```ts
import { router, publicProcedure } from './trpc';
import { observable } from '@trpc/server/observable';

export const appRouter = router({
  onCount: publicProcedure
    .subscription(() => {
      return observable<number>((observer) => {
        let count = 0;
        const timer = setInterval(() => {
          observer.next(count++);
        }, 1000);

        return () => clearInterval(timer);
      });
    }),
});
```

**Key Points:**
- The return type is `Observable<TData>`, not a `Promise`.
- No `async` is required on the handler itself, though the body may perform async setup before returning the observable.
- The cleanup function is critical — forgetting it leaks resources on the server.

---

### Transport Requirement: WebSockets

Subscriptions require a stateful transport. The standard HTTP adapter cannot carry subscriptions. You must use the **WebSocket adapter** from `@trpc/server/adapters/ws`.

```ts
import { createWSServer } from '@trpc/server/adapters/ws';
import { WebSocketServer } from 'ws';
import { appRouter } from './router';

const wss = new WebSocketServer({ port: 3001 });

createWSServer({
  router: appRouter,
  wss,
  createContext: () => ({}),
});

console.log('WebSocket server listening on ws://localhost:3001');
```

[Inference] tRPC's HTTP adapters do not expose a subscription pathway — the WebSocket adapter manages the persistent connection lifecycle that subscriptions depend on. Behavior may vary depending on deployment environment.

---

### Observable Lifecycle

The diagram below illustrates the lifecycle of a subscription observable from client connection to cleanup.

<svg viewBox="0 0 700 420" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="13">
  <!-- Background -->
  <rect width="700" height="420" fill="#0f1117" rx="12"/>

  <!-- Title -->
  <text x="350" y="34" text-anchor="middle" fill="#e2e8f0" font-size="14" font-weight="bold">Observable Subscription Lifecycle</text>

  <!-- Columns -->
  <text x="130" y="64" text-anchor="middle" fill="#7dd3fc" font-size="12" font-weight="bold">CLIENT</text>
  <text x="370" y="64" text-anchor="middle" fill="#86efac" font-size="12" font-weight="bold">tRPC TRANSPORT</text>
  <text x="590" y="64" text-anchor="middle" fill="#f9a8d4" font-size="12" font-weight="bold">SERVER OBSERVABLE</text>

  <!-- Swimlane dividers -->
  <line x1="250" y1="50" x2="250" y2="400" stroke="#2d3748" stroke-width="1" stroke-dasharray="4,4"/>
  <line x1="490" y1="50" x2="490" y2="400" stroke="#2d3748" stroke-width="1" stroke-dasharray="4,4"/>

  <!-- Step 1: subscribe -->
  <rect x="60" y="80" width="140" height="32" rx="6" fill="#1e3a5f" stroke="#7dd3fc" stroke-width="1"/>
  <text x="130" y="101" text-anchor="middle" fill="#7dd3fc" font-size="12">subscribe()</text>

  <line x1="200" y1="96" x2="490" y2="96" stroke="#7dd3fc" stroke-width="1.5" marker-end="url(#arrowBlue)"/>
  <text x="340" y="89" text-anchor="middle" fill="#94a3b8" font-size="11">WS message: subscription.start</text>

  <!-- Step 2: observable created -->
  <rect x="520" y="80" width="140" height="32" rx="6" fill="#3b1f3b" stroke="#f9a8d4" stroke-width="1"/>
  <text x="590" y="101" text-anchor="middle" fill="#f9a8d4" font-size="12">observable created</text>

  <!-- Step 3: subscriber fn runs -->
  <rect x="520" y="132" width="140" height="32" rx="6" fill="#3b1f3b" stroke="#f9a8d4" stroke-width="1"/>
  <text x="590" y="153" text-anchor="middle" fill="#f9a8d4" font-size="12">subscriber fn runs</text>

  <!-- Step 4: next() emitted -->
  <rect x="520" y="184" width="140" height="32" rx="6" fill="#3b1f3b" stroke="#f9a8d4" stroke-width="1"/>
  <text x="590" y="205" text-anchor="middle" fill="#f9a8d4" font-size="12">observer.next(value)</text>

  <line x1="520" y1="200" x2="250" y2="200" stroke="#f9a8d4" stroke-width="1.5" marker-end="url(#arrowPink)"/>
  <text x="383" y="193" text-anchor="middle" fill="#94a3b8" font-size="11">WS message: data</text>

  <!-- Step 5: client receives -->
  <rect x="60" y="184" width="140" height="32" rx="6" fill="#1e3a5f" stroke="#7dd3fc" stroke-width="1"/>
  <text x="130" y="205" text-anchor="middle" fill="#7dd3fc" font-size="12">onData callback</text>

  <!-- Step 6: more next() -->
  <rect x="520" y="236" width="140" height="32" rx="6" fill="#3b1f3b" stroke="#f9a8d4" stroke-width="1"/>
  <text x="590" y="257" text-anchor="middle" fill="#f9a8d4" font-size="12">observer.next(value)</text>

  <line x1="520" y1="252" x2="250" y2="252" stroke="#f9a8d4" stroke-width="1.5" marker-end="url(#arrowPink)"/>

  <rect x="60" y="236" width="140" height="32" rx="6" fill="#1e3a5f" stroke="#7dd3fc" stroke-width="1"/>
  <text x="130" y="257" text-anchor="middle" fill="#7dd3fc" font-size="12">onData callback</text>

  <!-- Step 7: unsubscribe -->
  <rect x="60" y="300" width="140" height="32" rx="6" fill="#1e3a5f" stroke="#7dd3fc" stroke-width="1"/>
  <text x="130" y="321" text-anchor="middle" fill="#7dd3fc" font-size="12">unsubscribe()</text>

  <line x1="200" y1="316" x2="490" y2="316" stroke="#7dd3fc" stroke-width="1.5" marker-end="url(#arrowBlue)"/>
  <text x="340" y="309" text-anchor="middle" fill="#94a3b8" font-size="11">WS message: subscription.stop</text>

  <!-- Step 8: cleanup -->
  <rect x="520" y="300" width="140" height="32" rx="6" fill="#3b1f3b" stroke="#f9a8d4" stroke-width="1"/>
  <text x="590" y="321" text-anchor="middle" fill="#f9a8d4" font-size="12">cleanup() called</text>

  <!-- vertical flow arrows on server side -->
  <line x1="590" y1="112" x2="590" y2="130" stroke="#f9a8d4" stroke-width="1" marker-end="url(#arrowPink)"/>
  <line x1="590" y1="164" x2="590" y2="182" stroke="#f9a8d4" stroke-width="1" marker-end="url(#arrowPink)"/>
  <line x1="590" y1="216" x2="590" y2="234" stroke="#f9a8d4" stroke-width="1" marker-end="url(#arrowPink)"/>

  <!-- Arrow markers -->
  <defs>
    <marker id="arrowBlue" markerWidth="8" markerHeight="8" refX="6" refY="3" orient="auto">
      <path d="M0,0 L0,6 L8,3 z" fill="#7dd3fc"/>
    </marker>
    <marker id="arrowPink" markerWidth="8" markerHeight="8" refX="6" refY="3" orient="auto">
      <path d="M0,0 L0,6 L8,3 z" fill="#f9a8d4"/>
    </marker>
  </defs>
</svg>

---

### Input Validation on Subscriptions

Like queries and mutations, subscriptions support `.input()` for validated parameters. This is commonly used to scope subscriptions — for example, subscribing only to events for a specific resource ID.

```ts
import { z } from 'zod';

export const appRouter = router({
  onPostUpdate: publicProcedure
    .input(z.object({ postId: z.string() }))
    .subscription(({ input }) => {
      return observable<{ postId: string; content: string }>((observer) => {
        // [Inference] In a real system, you would attach to an event emitter
        // or message bus here, filtered by input.postId
        const handler = (event: { postId: string; content: string }) => {
          if (event.postId === input.postId) {
            observer.next(event);
          }
        };

        eventEmitter.on('post.updated', handler);

        return () => eventEmitter.off('post.updated', handler);
      });
    }),
});
```

---

### Context and Authentication in Subscriptions

The `ctx` object created by `createContext` is available in subscription handlers just as in queries and mutations. This is typically used to authenticate the WebSocket connection before allowing a subscription to proceed.

```ts
export const appRouter = router({
  onAdminEvent: publicProcedure
    .subscription(({ ctx }) => {
      if (!ctx.user || ctx.user.role !== 'admin') {
        throw new TRPCError({ code: 'UNAUTHORIZED' });
      }

      return observable<string>((observer) => {
        const handler = (msg: string) => observer.next(msg);
        adminEmitter.on('event', handler);
        return () => adminEmitter.off('event', handler);
      });
    }),
});
```

**Key Points:**
- `createContext` for WebSocket servers receives a `CreateWSSContextFnOptions` object, which includes the raw WebSocket and HTTP upgrade request — not an Express-style `req`/`res` pair.
- Authentication tokens are typically extracted from the upgrade request headers or query string at context creation time.

---

### Completing and Erroring a Stream

Beyond `next()`, an observable can signal terminal states:

**Completing cleanly:**

```ts
observable<number>((observer) => {
  observer.next(1);
  observer.next(2);
  observer.complete(); // signals no more values; client subscription ends
  return () => {};
});
```

**Emitting an error:**

```ts
observable<number>((observer) => {
  try {
    // ... setup
  } catch (err) {
    observer.error(err); // propagates a TRPCClientError to the subscriber
  }
  return () => {};
});
```

[Inference] Calling `observer.error()` or `observer.complete()` should terminate the observable's active emissions. Actual behavior depends on tRPC version and transport implementation — verify against the version in use.

---

### Client-Side Subscription (React / vanilla)

On the client, `.subscribe()` is called on a subscription procedure. It accepts an object with `onData`, `onError`, and `onComplete` callbacks.

**Vanilla tRPC client:**

```ts
const subscription = trpc.onCount.subscribe(undefined, {
  onData(value) {
    console.log('received:', value);
  },
  onError(err) {
    console.error('subscription error:', err);
  },
  onComplete() {
    console.log('stream complete');
  },
});

// To unsubscribe:
subscription.unsubscribe();
```

**With `@trpc/react-query` (inside a component):**

```ts
import { trpc } from '../utils/trpc';

function CountDisplay() {
  trpc.onCount.useSubscription(undefined, {
    onData(value) {
      console.log('tick:', value);
    },
    onError(err) {
      console.error(err);
    },
  });

  return <div>Listening…</div>;
}
```

**Key Points:**
- `useSubscription` manages subscription lifecycle with the component — it subscribes on mount and unsubscribes on unmount. [Inference] Behavior may vary with Strict Mode double-invocation in development.
- The client must be configured with a `wsLink` (or `splitLink` routing subscriptions to a `wsLink`) for subscription calls to reach the WebSocket transport.

---

### Client Link Configuration for Subscriptions

```ts
import { createTRPCClient, createWSClient, wsLink, splitLink, httpBatchLink } from '@trpc/client';
import type { AppRouter } from '../server/router';

const wsClient = createWSClient({
  url: 'ws://localhost:3001',
});

const trpc = createTRPCClient<AppRouter>({
  links: [
    splitLink({
      condition: (op) => op.type === 'subscription',
      true: wsLink({ client: wsClient }),
      false: httpBatchLink({ url: 'http://localhost:3000/trpc' }),
    }),
  ],
});
```

**Key Points:**
- `splitLink` routes subscription operations to `wsLink` and queries/mutations to `httpBatchLink`.
- This is the standard pattern when you want HTTP for queries and WebSockets only for subscriptions.

---

### Event Emitter Pattern

The most common server-side pattern for powering subscriptions is a shared **EventEmitter** instance. Subscription handlers attach listeners on subscribe and remove them on cleanup.

```ts
import { EventEmitter } from 'events';

const ee = new EventEmitter();

export const appRouter = router({
  onMessage: publicProcedure
    .input(z.object({ room: z.string() }))
    .subscription(({ input }) => {
      return observable<{ text: string; author: string }>((observer) => {
        const handler = (msg: { text: string; author: string }) => {
          observer.next(msg);
        };

        ee.on(`message:${input.room}`, handler);
        return () => ee.off(`message:${input.room}`, handler);
      });
    }),

  sendMessage: publicProcedure
    .input(z.object({ room: z.string(), text: z.string(), author: z.string() }))
    .mutation(({ input }) => {
      ee.emit(`message:${input.room}`, { text: input.text, author: input.author });
      return { success: true };
    }),
});
```

**Key Points:**
- The `EventEmitter` instance must be in shared scope — not created per-request.
- In multi-process deployments, a single `EventEmitter` only reaches clients connected to the same process. [Inference] For distributed deployments, a pub/sub system (Redis, etc.) would be needed as a backing store — this is not provided by tRPC itself.

---

### Common Pitfalls

| Pitfall | Effect | Mitigation |
|---|---|---|
| Missing cleanup return | Server-side resource leak on disconnect | Always return a cleanup function from the subscriber |
| No `wsLink` configured | Subscription calls fail silently or throw | Use `splitLink` routing `subscription` type to `wsLink` |
| Calling `observer.next()` after `complete()`/`error()` | [Inference] Undefined behavior — values may be dropped | Guard emissions with a completed flag if needed |
| `EventEmitter` created inside handler | Each subscription gets a separate emitter; mutations on a different emitter have no effect | Hoist `EventEmitter` to module scope |
| Missing auth in context | Unauthorized access to sensitive streams | Throw `TRPCError` early in the subscription handler |

---

### Summary

**Conclusion:**

tRPC subscriptions are built around a minimal observable interface exposing `next`, `error`, and `complete`. The subscriber function receives an observer, performs setup (typically attaching to an event emitter or external stream), and returns a cleanup function. The WebSocket adapter is required as transport. Clients use `wsLink` — usually via `splitLink` — to route subscription operations over WebSockets while keeping queries and mutations on HTTP. Input validation, context, and error handling work consistently with the rest of tRPC's procedure model.

**Next Steps:** Subscription reconnection and error recovery strategies / Using `httpSubscriptionLink` (SSE-based subscriptions, tRPC v11+) / Scaling subscriptions across processes with a pub/sub backend.