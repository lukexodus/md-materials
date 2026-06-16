## Subscription Procedures

### Overview

Subscription procedures enable real-time, server-to-client data streams. Unlike queries and mutations — which follow a request/response cycle — subscriptions maintain a persistent connection over which the server pushes events as they occur. tRPC implements subscriptions using **WebSockets** as the transport layer, requiring a WebSocket-capable server and a corresponding WebSocket link on the client.

Subscriptions are defined with `.subscription()` and must return an observable created via tRPC's built-in `observable` helper or a compatible async iterable.

---

### How tRPC Subscriptions Work

```
Client                          Server
  │                               │
  │── WebSocket handshake ────────►│
  │                               │
  │── subscribe: post.onCreate ──►│
  │                               │
  │◄─ event: { id, title } ───────│
  │◄─ event: { id, title } ───────│
  │◄─ event: { id, title } ───────│
  │                               │
  │── unsubscribe ───────────────►│
  │                               │
  │◄─ WebSocket close ────────────│
```

**Key Points**
- The WebSocket connection is shared across all active subscriptions from a single client. tRPC multiplexes multiple subscriptions over one socket.
- Queries and mutations can continue to use HTTP links while only subscriptions use the WebSocket link, via `splitLink`.
- The server pushes events — the client does not poll.

---

### Dependencies

```bash
npm install @trpc/server @trpc/client ws
npm install --save-dev @types/ws
```

For the client (React):

```bash
npm install @trpc/client @trpc/react-query @tanstack/react-query
```

**Key Points**
- `ws` is the WebSocket server library for Node.js. It is required on the server side.
- Browsers have a native `WebSocket` global — no additional client library is needed for the browser client.
- `ws` is a peer dependency of `@trpc/server`'s WebSocket adapter. [Inference] Confirm the required version against the tRPC documentation for your installed version.

---

### Server Setup

#### WebSocket-Capable Server

The standalone HTTP server and the WebSocket server must both be running. tRPC provides `applyWSSHandler` to attach the WebSocket handler to an existing `ws.Server` instance.

```ts
// src/index.ts
import { createHTTPServer } from '@trpc/server/adapters/standalone';
import { applyWSSHandler } from '@trpc/server/adapters/ws';
import { WebSocketServer } from 'ws';
import { appRouter } from './server/router';
import { createContext } from './server/context';

// HTTP server for queries and mutations
const httpServer = createHTTPServer({
  router: appRouter,
  createContext,
});

httpServer.listen(3000);

// WebSocket server for subscriptions
const wss = new WebSocketServer({ port: 3001 });

applyWSSHandler({
  wss,
  router: appRouter,
  createContext,
});

console.log('HTTP server listening on http://localhost:3000');
console.log('WebSocket server listening on ws://localhost:3001');
```

**Key Points**
- HTTP and WebSocket servers run on separate ports here. They can share a port using Node.js's `http.Server` upgrade mechanism, but separate ports are simpler to configure and reason about.
- `applyWSSHandler` returns a handler object with a `broadcastReconnectNotification()` method, useful for notifying clients when the server restarts.
- Queries and mutations remain available over HTTP. The WebSocket server handles subscription traffic and can also handle queries and mutations if the client routes them there.

---

### Defining a Subscription Procedure

#### Using `observable`

```ts
// server/router/post.router.ts
import { z } from 'zod';
import { observable } from '@trpc/server/observable';
import { EventEmitter } from 'events';
import { router, publicProcedure } from '../trpc';

// Shared event emitter — in production, replace with a proper pub/sub system
const ee = new EventEmitter();

export const postRouter = router({
  onCreate: publicProcedure
    .input(z.object({
      authorId: z.string().optional(),
    }))
    .subscription(({ input }) => {
      return observable<{ id: string; title: string; authorId: string }>((emit) => {
        function onPost(data: { id: string; title: string; authorId: string }) {
          if (!input.authorId || data.authorId === input.authorId) {
            emit.next(data);
          }
        }

        ee.on('post:created', onPost);

        // Cleanup: called when client unsubscribes or disconnects
        return () => {
          ee.off('post:created', onPost);
        };
      });
    }),
});
```

**Key Points**
- `observable` is imported from `@trpc/server/observable`.
- The function passed to `observable` receives an `emit` object with three methods: `emit.next(value)` to push a value, `emit.error(err)` to push an error, and `emit.complete()` to signal the stream is finished.
- The function must return a cleanup function. tRPC calls it when the client unsubscribes or the connection drops. Failing to clean up event listeners causes memory leaks.
- `EventEmitter` is a simple in-process pub/sub mechanism. It does not work across multiple server instances. [Inference] In production, a Redis pub/sub adapter or similar distributed message broker is typically needed for horizontal scalability.

#### Emitting Events from a Mutation

```ts
create: publicProcedure
  .input(z.object({
    title: z.string().min(1),
    authorId: z.string().uuid(),
  }))
  .mutation(async ({ input }) => {
    const post = await db.post.create({ data: input });

    // Notify all subscribers
    ee.emit('post:created', post);

    return post;
  }),
```

**Key Points**
- The mutation emits an event on the shared `EventEmitter` after persisting the record. Any active subscriber receives the event via `emit.next`.
- The `EventEmitter` instance must be shared between the mutation and subscription procedures. Export it from a shared module rather than defining it inline.

---

### Async Iterable Subscriptions

As an alternative to `observable`, tRPC supports async iterables for subscriptions (available from tRPC v11+). [Inference] Verify availability against your installed version.

```ts
import { z } from 'zod';
import { router, publicProcedure } from '../trpc';

export const clockRouter = router({
  tick: publicProcedure
    .subscription(async function* () {
      while (true) {
        yield { time: new Date().toISOString() };
        await new Promise((resolve) => setTimeout(resolve, 1000));
      }
    }),
});
```

**Key Points**
- An `async function*` (async generator) can be returned directly from `.subscription()`.
- The generator yields values one at a time. tRPC sends each yielded value to the client as a subscription event.
- There is no explicit cleanup callback as with `observable`. Cleanup is handled by generator return/throw mechanics when the client disconnects.
- Infinite generators run until the client disconnects or the connection is dropped.

---

### Client Setup

#### Configuring `splitLink`

The client must route subscriptions over WebSocket while sending queries and mutations over HTTP. `splitLink` conditionally applies different links based on the operation type.

```ts
// src/utils/trpc.ts
import { createTRPCReact } from '@trpc/react-query';
import {
  httpBatchLink,
  splitLink,
  createWSClient,
  wsLink,
} from '@trpc/client';
import type { AppRouter } from '../../server/router';

export const trpc = createTRPCReact<AppRouter>();

const wsClient = createWSClient({
  url: 'ws://localhost:3001',
});

export function createTRPCClient() {
  return trpc.createClient({
    links: [
      splitLink({
        condition(op) {
          return op.type === 'subscription';
        },
        true: wsLink({ client: wsClient }),
        false: httpBatchLink({ url: 'http://localhost:3000' }),
      }),
    ],
  });
}
```

**Key Points**
- `splitLink` evaluates `condition` for each operation. When `condition` returns `true`, the `true` link is used; otherwise the `false` link is used.
- `createWSClient` creates a persistent WebSocket client that reconnects automatically on disconnect. [Inference] Reconnection behavior may vary across versions — consult the tRPC WebSocket client documentation.
- The `wsClient` instance should be created once and reused, not recreated on each render.

#### WebSocket-Only Client

If all operations (queries, mutations, subscriptions) should go over WebSocket:

```ts
export function createTRPCClient() {
  return trpc.createClient({
    links: [
      wsLink({ client: wsClient }),
    ],
  });
}
```

---

### Using Subscriptions in React Components

```tsx
import { trpc } from '../utils/trpc';

function PostFeed() {
  const [posts, setPosts] = useState<{ id: string; title: string }[]>([]);

  trpc.post.onCreate.useSubscription(
    { authorId: undefined },
    {
      onData(post) {
        setPosts((prev) => [post, ...prev]);
      },
      onError(err) {
        console.error('Subscription error:', err.message);
      },
    },
  );

  return (
    <ul>
      {posts.map((post) => (
        <li key={post.id}>{post.title}</li>
      ))}
    </ul>
  );
}
```

**Key Points**
- `useSubscription` establishes the subscription when the component mounts and tears it down when the component unmounts.
- `onData` is called each time the server emits a value via `emit.next`.
- `onError` is called when the server emits an error via `emit.error` or the connection drops unexpectedly.
- There is no `data` return value from `useSubscription` — received data must be managed in local state or an external store.
- React Strict Mode causes components to mount twice in development. This may result in two subscriptions being established briefly, then one being torn down. [Inference] Behavior in production (single mount) is unaffected.

#### Conditional Subscription

```tsx
trpc.post.onCreate.useSubscription(
  { authorId: userId },
  {
    enabled: !!userId,
    onData(post) {
      setPosts((prev) => [post, ...prev]);
    },
  },
);
```

**Key Points**
- `enabled: false` prevents the subscription from being established. The subscription activates when `enabled` becomes `true`.

---

### Vanilla Client Subscriptions

```ts
import { client } from '../utils/client';

const subscription = client.post.onCreate.subscribe(
  { authorId: undefined },
  {
    onData(post) {
      console.log('New post:', post);
    },
    onError(err) {
      console.error('Error:', err);
    },
    onComplete() {
      console.log('Subscription completed');
    },
  },
);

// Unsubscribe manually
subscription.unsubscribe();
```

---

### Reconnection Handling

`createWSClient` handles reconnection internally. When the server restarts, you can broadcast a reconnect notification to all clients:

```ts
// src/index.ts
const handler = applyWSSHandler({
  wss,
  router: appRouter,
  createContext,
});

process.on('SIGTERM', () => {
  handler.broadcastReconnectNotification();
  wss.close();
});
```

**Key Points**
- `broadcastReconnectNotification` sends a message to all connected clients signaling they should reconnect and re-subscribe.
- [Inference] The client-side WebSocket link handles the reconnect notification by closing and reopening the WebSocket connection, which causes active subscriptions to re-subscribe. Exact behavior depends on the tRPC client version.

---

### EventEmitter Module Pattern

To safely share the `EventEmitter` across router files:

```ts
// server/emitter.ts
import { EventEmitter } from 'events';

export const ee = new EventEmitter();
ee.setMaxListeners(100); // increase if many concurrent subscribers are expected
```

```ts
// server/router/post.router.ts
import { ee } from '../emitter';
```

**Key Points**
- Node.js warns when more than 10 listeners are attached to a single event. Increase `maxListeners` for subscription-heavy applications to suppress false positive warnings.
- The `EventEmitter` approach is single-process only. Scaling horizontally requires a distributed pub/sub system such as Redis, NATS, or similar. [Inference]

---

### Comparison: `observable` vs Async Iterable

| Aspect | `observable` | Async iterable (`async function*`) |
|---|---|---|
| Availability | All tRPC v10+ | tRPC v11+ [Inference] |
| Cleanup | Explicit return function | Generator return/throw |
| External event sources | Natural fit (EventEmitter, Redis) | Requires bridging to async iteration |
| Simple periodic output | Verbose | Concise |
| Error emission | `emit.error(err)` | `throw` inside generator |
| Completion signal | `emit.complete()` | Generator `return` |

---

### Common Errors

| Error | Cause | Resolution |
|---|---|---|
| `WebSocket is not open` | Client attempts to subscribe before connection is ready | `createWSClient` handles this internally; verify the WebSocket URL is correct |
| No events received | EventEmitter not shared between mutation and subscription | Export `ee` from a single module |
| Memory leak warning | Cleanup function not removing event listeners | Always call `ee.off` in the cleanup return |
| Subscription not activating | `enabled: false` or wrong `splitLink` condition | Verify `op.type === 'subscription'` in `splitLink` |
| Events lost on reconnect | No replay mechanism | Implement cursor-based event replay or use a message queue |