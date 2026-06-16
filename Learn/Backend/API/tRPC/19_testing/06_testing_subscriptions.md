## Testing Subscriptions

tRPC subscriptions use server-sent events (SSE) or WebSockets to push data from server to client over a persistent connection. Testing them requires different strategies than queries and mutations because the response is not a single value — it is a stream of events over time.

---

### How tRPC Subscriptions Work

A subscription procedure returns an async iterable (or an observable, depending on the version). The server pushes values to the client as they are emitted. The client maintains a persistent connection and receives each emission as it arrives.

```ts
import { initTRPC } from '@trpc/server';
import { observable } from '@trpc/server/observable';

const t = initTRPC.create();

export const appRouter = t.router({
  onCount: t.procedure.subscription(() => {
    return observable<number>((emit) => {
      let count = 0;
      const interval = setInterval(() => {
        emit.next(count++);
      }, 100);
      return () => clearInterval(interval);
    });
  }),
});
```

[Inference: tRPC v11 moves toward async iterables as the preferred subscription return type over RxJS observables. Verify which pattern applies to your version before writing tests.]

---

### Testing Approaches

| Approach | Transport | What It Covers |
| --- | --- | --- |
| Unit test the observable/iterable directly | None | Emission logic, teardown, error handling |
| Integration test via WebSocket client | WebSocket | Full transport, reconnection, serialization |
| Integration test via SSE | HTTP/SSE | SSE transport, event stream format |
| `createCaller` (limited) | None | Basic emission; no transport or teardown |

---

### Unit Testing the Observable Directly

The most isolated approach extracts the observable factory from the procedure and tests it independently. This avoids any transport layer.

```ts
// src/subscriptions/counter.test.ts
import { describe, expect, it, vi } from 'vitest';
import { observable } from '@trpc/server/observable';

function createCounterObservable(limit: number) {
  return observable<number>((emit) => {
    let count = 0;
    const interval = setInterval(() => {
      if (count >= limit) {
        emit.complete();
        return;
      }
      emit.next(count++);
    }, 10);

    return () => clearInterval(interval);
  });
}

describe('counter observable', () => {
  it('emits the expected sequence of values', async () => {
    const values: number[] = [];

    await new Promise<void>((resolve) => {
      const sub = createCounterObservable(3).subscribe({
        next: (val) => values.push(val),
        complete: resolve,
      });
    });

    expect(values).toEqual([0, 1, 2]);
  });

  it('calls the teardown function on unsubscribe', () => {
    const clearIntervalSpy = vi.spyOn(global, 'clearInterval');
    const obs = createCounterObservable(100);
    const sub = obs.subscribe({ next: () => {} });
    sub.unsubscribe();
    expect(clearIntervalSpy).toHaveBeenCalled();
    clearIntervalSpy.mockRestore();
  });
});
```

**Key Points**

- Extracting the observable factory into a standalone function makes it testable without constructing a router.
- The teardown test verifies that resources (timers, event listeners, database cursors) are released on unsubscribe — a common source of memory leaks.
- `emit.complete()` signals the end of the stream; the test resolves the outer `Promise` on that signal.

---

### Testing with Async Iterables (tRPC v11+)

If your version uses async iterables instead of observables, the test structure changes accordingly.

```ts
async function* createCounterIterable(limit: number) {
  for (let i = 0; i < limit; i++) {
    await new Promise((r) => setTimeout(r, 10));
    yield i;
  }
}

describe('counter async iterable', () => {
  it('yields the expected values', async () => {
    const values: number[] = [];

    for await (const value of createCounterIterable(3)) {
      values.push(value);
    }

    expect(values).toEqual([0, 1, 2]);
  });

  it('can be aborted early via AbortSignal', async () => {
    const controller = new AbortController();
    const values: number[] = [];

    async function consume(signal: AbortSignal) {
      for await (const value of createCounterIterable(100)) {
        if (signal.aborted) break;
        values.push(value);
        if (values.length === 2) controller.abort();
      }
    }

    await consume(controller.signal);
    expect(values).toEqual([0, 1]);
  });
});
```

[Inference: the exact abort/teardown mechanism for async iterable subscriptions in tRPC v11 depends on the adapter implementation. Verify teardown behavior against the official documentation for your version.]

---

### Integration Testing via WebSocket

For a full end-to-end integration test, use tRPC's WebSocket adapter and a real WebSocket client. This exercises the transport, serialization, and subscription lifecycle.

#### Installing Dependencies

```bash
npm install --save-dev ws
npm install --save-dev @types/ws
```

#### Setting Up a WebSocket Test Server

```ts
// src/test/createWsTestServer.ts
import { createWSHandler } from '@trpc/server/adapters/ws';
import { WebSocketServer } from 'ws';
import { appRouter } from '../router';

export function createWsTestServer() {
  const wss = new WebSocketServer({ port: 0 });

  createWSHandler({
    router: appRouter,
    createContext: () => ({}),
    wss,
  });

  const port = (wss.address() as { port: number }).port;

  return {
    port,
    url: `ws://127.0.0.1:${port}`,
    close: () => wss.close(),
  };
}
```

#### Writing the WebSocket Integration Test

```ts
// src/test/subscriptions.integration.test.ts
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { createTRPCProxyClient, createWSClient, wsLink } from '@trpc/client';
import { createWsTestServer } from './createWsTestServer';
import type { AppRouter } from '../router';

let url: string;
let closeServer: () => void;

beforeAll(() => {
  const server = createWsTestServer();
  url = server.url;
  closeServer = server.close;
});

afterAll(() => closeServer());

describe('onCount subscription', () => {
  it('receives the first three emissions', async () => {
    const wsClient = createWSClient({ url });
    const client = createTRPCProxyClient<AppRouter>({
      links: [wsLink({ client: wsClient })],
    });

    const received: number[] = [];

    await new Promise<void>((resolve, reject) => {
      const sub = client.onCount.subscribe(undefined, {
        onData(val) {
          received.push(val);
          if (received.length === 3) {
            sub.unsubscribe();
            resolve();
          }
        },
        onError: reject,
      });
    });

    wsClient.close();
    expect(received).toEqual([0, 1, 2]);
  });
});
```

**Key Points**

- `createWSClient` and `wsLink` are part of `@trpc/client`. They handle the WebSocket handshake and tRPC's subscription protocol automatically.
- `sub.unsubscribe()` sends an unsubscribe message to the server, which should trigger the observable's teardown function.
- Always call `wsClient.close()` after the test to release the WebSocket connection and prevent the test runner from hanging.
- Using port `0` avoids port conflicts when tests run in parallel.

---

### Subscription Lifecycle Diagram

Subscription ProceduretRPC WS HandlerWebSocket ServerTest ClientSubscription ProceduretRPC WS HandlerWebSocket ServerTest ClientWebSocket connectSubscribe message (id, path)Start observable / iterableemit(0)Data message { id, result: 0 }emit(1)Data message { id, result: 1 }Unsubscribe message (id)Teardown (clearInterval, etc.)WebSocket close

---

### Testing Error Emissions

Subscriptions can emit errors via `emit.error()`. Test that the client's `onError` handler receives the correct error.

```ts
import { observable } from '@trpc/server/observable';
import { TRPCError } from '@trpc/server';

const errorRouter = t.router({
  failing: t.procedure.subscription(() => {
    return observable<never>((emit) => {
      setTimeout(() => {
        emit.error(new TRPCError({ code: 'INTERNAL_SERVER_ERROR', message: 'Stream failed' }));
      }, 10);
    });
  }),
});
```

```ts
it('calls onError when the subscription emits an error', async () => {
  const error = await new Promise<unknown>((resolve) => {
    const sub = client.failing.subscribe(undefined, {
      onData: () => {},
      onError: resolve,
    });
  });

  expect(error).toMatchObject({ message: 'Stream failed' });
});
```

[Inference: the exact shape of the error received by `onError` depends on tRPC's client-side error transformation. Behavior may vary; verify against your version.]

---

### Testing Subscription Teardown

Verifying that teardown fires correctly is critical for resource management. Use a spy or a shared flag.

```ts
it('calls teardown when the client unsubscribes', async () => {
  let tornDown = false;

  const teardownRouter = t.router({
    tracked: t.procedure.subscription(() => {
      return observable<number>((emit) => {
        const id = setInterval(() => emit.next(1), 50);
        return () => {
          tornDown = true;
          clearInterval(id);
        };
      });
    }),
  });

  // Set up a local test server using teardownRouter
  // ... (same pattern as createWsTestServer, substituting teardownRouter)

  const sub = client.tracked.subscribe(undefined, { onData: () => {} });
  await new Promise((r) => setTimeout(r, 60)); // allow one emission
  sub.unsubscribe();
  await new Promise((r) => setTimeout(r, 20)); // allow teardown to propagate

  expect(tornDown).toBe(true);
});
```

**Key Points**

- There is a small delay between `unsubscribe()` and the teardown executing on the server, because the unsubscribe message must travel over the WebSocket. Allow a short settling time before asserting on the teardown flag.
- [Inference: the exact propagation timing depends on the event loop and network stack. Tests relying on fixed `setTimeout` delays may be flaky under load. Consider using a polling utility or a `Promise`-based teardown signal instead.]

---

### Avoiding Flaky Subscription Tests

Subscription tests are prone to timing-related flakiness. These strategies reduce it:

**Use completion signals instead of fixed timeouts**

```ts
// Fragile
await new Promise((r) => setTimeout(r, 500));
expect(received.length).toBeGreaterThan(0);

// More reliable
await new Promise<void>((resolve) => {
  client.onCount.subscribe(undefined, {
    onData(val) {
      if (val >= 2) resolve();
    },
  });
});
```

**Collect N emissions then assert**

Rather than asserting after a fixed wait, resolve the promise once exactly N values have been received.

**Set a test timeout**

Subscription tests can hang indefinitely if the expected emission never arrives. Set an explicit timeout on the test.

```ts
it('receives three values', async () => {
  // ...
}, 5000); // fail after 5 seconds
```

**Always clean up**

Call `sub.unsubscribe()` and `wsClient.close()` in every test — including tests that fail early. Use `try/finally` or Vitest's `onTestFailed` hook.

---

### Testing with `createCaller` (Limited Use)

`createCaller` can invoke a subscription procedure, but the return value is the raw observable or iterable — not a streaming client subscription. This is useful only for testing that the procedure returns the correct type, not for testing emissions over time.

```ts
it('returns an observable from createCaller', async () => {
  const caller = appRouter.createCaller({});
  const result = await caller.onCount();
  // result is an Observable<number> — not a resolved value
  expect(typeof result.subscribe).toBe('function');
});
```

This approach does not test transport, serialization, or the WebSocket protocol. It is not a substitute for integration testing.

---

### Common Pitfalls

**Not closing the WebSocket client** — An open `wsClient` keeps the Node.js event loop alive and causes Vitest or Jest to hang after tests complete.

**Not closing the WebSocket server** — Similarly, `wss.close()` must be called in `afterAll` or the process will not exit cleanly.

**Fixed `setTimeout` delays for assertions** — These are inherently racey. Prefer event-driven resolution.

**Ignoring teardown** — Failing to test the teardown function means timer leaks and open database cursors will not be caught until production.

**Testing only emissions, not unsubscription** — A subscription that emits correctly but never tears down is a resource leak. Both behaviors need tests.

---

### Summary

Testing tRPC subscriptions requires at least two layers. Unit tests exercise the observable or async iterable factory directly — verifying emission logic, teardown, and error handling without any transport. Integration tests using a real WebSocket server and `@trpc/client` exercise the full lifecycle: connection, subscription protocol, data serialization, and unsubscription. Flakiness is the primary risk; prefer event-driven assertion patterns over fixed timeouts, and always clean up WebSocket clients and servers after each test.