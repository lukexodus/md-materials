## Fastify Hooks — onTimeout

### Overview

The `onTimeout` hook is a request-level lifecycle hook that fires when a request exceeds the server's configured connection timeout. It provides a dedicated interception point to perform logging, cleanup, or custom response logic before the connection is terminated.

---

### Prerequisites — Enabling Connection Timeout

The `onTimeout` hook only triggers if a timeout is configured on the underlying Node.js HTTP server. Fastify exposes this via the `connectionTimeout` option.

```js
const fastify = Fastify({
  connectionTimeout: 5000, // milliseconds
  logger: true
});
```

> **Disclaimer:** If `connectionTimeout` is not set (or is `0`), the `onTimeout` hook will never fire, regardless of how long a request takes.

---

### Registration

```js
fastify.addHook('onTimeout', async function (request, reply) {
  // timeout handling logic
});
```

Or with a callback:

```js
fastify.addHook('onTimeout', function (request, reply, done) {
  // timeout handling logic
  done();
});
```

**Key Points:**
- Receives the standard `request` and `reply` objects
- Supports both async and callback styles
- Multiple `onTimeout` hooks can be registered and execute in FIFO order
- Respects Fastify's encapsulation — hooks registered in a scoped plugin apply only within that scope
- By the time this hook fires, the connection is already being closed by Node.js; sending a response may not succeed in all cases [Inference]

---

### When onTimeout Fires

The sequence below illustrates where `onTimeout` sits in the request lifecycle relative to other hooks:

```
Incoming Request
      │
      ▼
  onRequest
      │
      ▼
  preParsing
      │
      ▼
  preValidation
      │
      ▼
  preHandler
      │
      ▼
  Route Handler
      │
      ├──── (if timeout exceeded at any point above)
      │                    │
      │                    ▼
      │               onTimeout ◄─── fires here
      │
      ▼
  onSend
      │
      ▼
  onResponse
```

> **Disclaimer:** The timeout can be exceeded at any stage. The exact point of interruption depends on when Node.js fires the socket `timeout` event relative to handler execution.

---

### Example — Logging Timed-Out Requests

```js
const fastify = Fastify({
  connectionTimeout: 3000,
  logger: true
});

fastify.addHook('onTimeout', async function (request, reply) {
  request.log.warn({
    method: request.method,
    url: request.url,
    requestId: request.id
  }, 'Request timed out');
});

fastify.get('/slow', async function (request, reply) {
  await new Promise((resolve) => setTimeout(resolve, 10000)); // 10s delay
  return { message: 'This will likely never be sent' };
});

await fastify.listen({ port: 3000 });
```

**Output** (approximate):
```
{"level":"warn","reqId":"req-1","method":"GET","url":"/slow","msg":"Request timed out"}
```

---

### Example — Emitting Metrics on Timeout

```js
import { incrementCounter } from './metrics.js';

fastify.addHook('onTimeout', async function (request, reply) {
  incrementCounter('http_request_timeouts_total', {
    method: request.method,
    route: request.routerPath
  });

  request.log.error('Timeout on route: %s %s', request.method, request.url);
});
```

This pattern is useful for integrating with Prometheus or similar monitoring systems to track timeout rates per route.

---

### Attempting a Response in onTimeout

While it is technically possible to attempt sending a response inside `onTimeout`, success is not guaranteed. By the time the hook fires, Node.js may have already closed or reset the socket.

```js
fastify.addHook('onTimeout', async function (request, reply) {
  // This may or may not reach the client
  reply
    .code(503)
    .send({ error: 'Request timed out. Please try again.' });
});
```

> **Disclaimer:** Whether the client receives this response depends on the state of the TCP connection at the moment the hook executes. Do not rely on this for guaranteed client-side error delivery. Behavior may vary across Node.js versions and network conditions.

---

### Encapsulation Behavior

Like other Fastify hooks, `onTimeout` respects plugin scope.

```js
// Root-level — applies to all routes
fastify.addHook('onTimeout', async (request, reply) => {
  request.log.warn('Root-level timeout: %s', request.url);
});

// Scoped — applies only to routes within this plugin
fastify.register(async function scopedPlugin(instance) {
  instance.addHook('onTimeout', async (request, reply) => {
    request.log.warn('Scoped timeout: %s', request.url);
  });

  instance.get('/scoped-slow', async () => {
    await new Promise(r => setTimeout(r, 10000));
    return {};
  });
});
```

---

### onTimeout vs Other Error Hooks

| Hook | Trigger | Has request/reply | Typical Use |
|---|---|---|---|
| `onTimeout` | Connection timeout exceeded | Yes | Timeout logging, metrics |
| `onError` | Route handler throws an error | Yes | Error formatting, alerting |
| `onRequestAbort` | Client disconnects early | Yes | Abort cleanup, logging |
| `onClose` | Server shutting down | No (instance only) | Resource teardown |

---

### Combining onTimeout with onRequestAbort

In practice, a timeout often causes the client to abort the connection. Both `onTimeout` and `onRequestAbort` may fire in close succession. [Inference: the ordering between the two is not strictly guaranteed and may depend on socket event timing.]

```js
fastify.addHook('onTimeout', async (request, reply) => {
  request.log.warn('Timeout detected for: %s', request.id);
});

fastify.addHook('onRequestAbort', async (request) => {
  request.log.warn('Client aborted request: %s', request.id);
});
```

To avoid duplicate processing, consider tracking request state with a flag or a `WeakMap`.

---

### Practical Recommendations

- **Always set `connectionTimeout`** if you rely on `onTimeout` — the hook is inert without it
- **Use `onTimeout` for observability** (logging, metrics, tracing spans) rather than response delivery
- **Do not treat `onTimeout` as a guaranteed response channel** — prefer upstream timeout handling (e.g., load balancer or API gateway timeouts) for client-facing guarantees
- **Combine with `onRequestAbort`** for complete coverage of incomplete request scenarios

---

**Conclusion:**
The `onTimeout` hook provides a targeted interception point for requests that exceed the configured connection timeout. Its primary value lies in observability — capturing metrics, emitting structured logs, and closing out tracing spans — rather than response delivery, which cannot be guaranteed once the socket timeout has fired. When used alongside `connectionTimeout` and complementary hooks like `onRequestAbort`, it contributes to a comprehensive picture of request lifecycle health in production Fastify applications.