### Reply Object — `reply.raw` Access

`reply.raw` is a reference to the underlying Node.js `http.ServerResponse` object that Fastify wraps. It provides direct access to the raw HTTP response, bypassing Fastify's abstractions entirely.

---

#### What `reply.raw` Is

When a request arrives, Node.js creates an `http.IncomingMessage` (the request) and an `http.ServerResponse` (the response). Fastify wraps these in its own `Request` and `Reply` objects, adding its lifecycle, serialization, and hook system on top.

`reply.raw` gives you a direct reference to the unwrapped `http.ServerResponse`.

js

```
fastify.get('/inspect', (request, reply) => {
  console.log(reply.raw); // http.ServerResponse instance
  return reply.send('ok');
});
```

Similarly, `request.raw` exposes the underlying `http.IncomingMessage`.

---

#### Accessing Response Properties Directly

Because `reply.raw` is a standard Node.js `ServerResponse`, all native properties and methods are available.

js

```
fastify.get('/native', (request, reply) => {
  console.log(reply.raw.headersSent);   // boolean — whether headers have been flushed
  console.log(reply.raw.writableEnded); // boolean — whether end() has been called
  console.log(reply.raw.statusCode);    // number — current status code
  return reply.send('ok');
});
```

| Property | Type | Description |
| --- | --- | --- |
| `headersSent` | `boolean` | `true` if headers have already been flushed to the client |
| `writableEnded` | `boolean` | `true` if `end()` has been called |
| `writableFinished` | `boolean` | `true` if all data has been flushed to the OS |
| `statusCode` | `number` | The current HTTP status code |
| `statusMessage` | `string` | The HTTP status message |

---

#### Writing Headers via `reply.raw`

Headers can be set directly using native `ServerResponse` methods.

js

```
fastify.get('/raw-headers', (request, reply) => {
  reply.raw.setHeader('X-Custom', 'value');
  reply.raw.setHeader('Content-Type', 'text/plain');
  return reply.send('ok');
});
```

> [Inference] Headers set via `reply.raw.setHeader()` and those set via `reply.header()` operate on the same underlying response object. Mixing both in the same handler may produce unexpected results depending on the order of calls. Behavior may vary.

---

#### Reading Headers Set on `reply.raw`

js

```
fastify.get('/read-raw-header', (request, reply) => {
  reply.raw.setHeader('X-Trace', 'abc');

  const value = reply.raw.getHeader('X-Trace'); // 'abc'
  const all = reply.raw.getHeaders();            // { 'x-trace': 'abc' }

  return reply.send({ value, all });
});
```

Native `ServerResponse` header methods available on `reply.raw`:

| Method | Description |
| --- | --- |
| `setHeader(name, value)` | Set a single header |
| `getHeader(name)` | Get a single header value |
| `getHeaders()` | Get all headers as an object |
| `hasHeader(name)` | Check if a header exists |
| `removeHeader(name)` | Remove a header |
| `writeHead(statusCode, headers)` | Write status and headers in one call |

---

#### Writing the Response Body Directly

`reply.raw` can be written to directly using `write()` and `end()`.

js

```
fastify.get('/direct-write', (request, reply) => {
  reply.raw.writeHead(200, { 'Content-Type': 'text/plain' });
  reply.raw.write('part one\n');
  reply.raw.write('part two\n');
  reply.raw.end();
});
```

> [Inference] When writing directly to `reply.raw` without calling `reply.hijack()`, Fastify is not notified that the response has been handled. This may result in Fastify attempting to finalize the reply after the handler returns. Pairing `reply.raw` writes with `reply.hijack()` is the recommended approach when bypassing Fastify's lifecycle.

---

#### Accessing the Underlying Socket

`reply.raw.socket` exposes the raw TCP or TLS socket for the connection. This is rarely needed outside of advanced use cases such as WebSocket upgrades or connection-level control.

js

```
fastify.get('/socket-info', (request, reply) => {
  const socket = reply.raw.socket;
  console.log(socket.remoteAddress); // client IP
  console.log(socket.remotePort);    // client port
  return reply.send({ ip: socket.remoteAddress });
});
```

> [Inference] Direct socket manipulation is highly low-level and falls outside Fastify's scope. Incorrect socket handling may corrupt the HTTP connection. Use only when there is no higher-level alternative.

---

#### Checking `headersSent` Before Writing

`reply.raw.headersSent` is useful for guarding against double-write attempts, particularly in error handlers or cleanup logic.

js

```
fastify.get('/guarded', async (request, reply) => {
  try {
    await someOperation();
    return reply.send({ ok: true });
  } catch (err) {
    if (!reply.raw.headersSent) {
      return reply.code(500).send({ error: 'Operation failed' });
    }
    // Headers already sent — cannot send error response
    fastify.log.error('Error after headers sent:', err);
  }
});
```

---

#### `reply.raw` vs. `reply` — Key Differences

| Capability | `reply` (Fastify) | `reply.raw` (Node.js) |
| --- | --- | --- |
| Serialization | Automatic | Manual |
| Schema validation | Applied | Bypassed |
| Hook execution (`onSend`) | Yes | No |
| `Content-Type` inference | Yes | No |
| Error handling integration | Yes | No |
| Streaming support | Via `reply.send(stream)` | Via `write()` / `end()` |
| Lifecycle awareness | Full | None |

---

#### Common Legitimate Use Cases

**Checking if the response was already sent:**

js

```
if (reply.raw.headersSent) {
  fastify.log.warn('Response already sent');
}
```

**Reading the socket remote address:**

js

```
const clientIp = reply.raw.socket?.remoteAddress;
```

**Integrating third-party middleware that expects a raw `ServerResponse`:**

js

```
fastify.get('/compat', (request, reply) => {
  reply.hijack();
  legacyMiddleware(request.raw, reply.raw, () => {
    reply.raw.end();
  });
});
```

**Passing to a WebSocket upgrade handler:**

js

```
reply.hijack();
wsServer.handleUpgrade(request.raw, reply.raw.socket, Buffer.alloc(0), (ws) => {
  wsServer.emit('connection', ws, request.raw);
});
```

---

#### What to Avoid

- **Mixing `reply.header()` and `reply.raw.setHeader()` for the same header name** — order of precedence is not guaranteed
- **Writing to `reply.raw` without `reply.hijack()`** — Fastify may attempt a second send
- **Calling `reply.raw.end()` and then `reply.send()`** — results in a double-end error
- **Direct socket writes** — bypasses HTTP framing entirely and is almost never appropriate

---

#### Summary

- `reply.raw` is the native Node.js `http.ServerResponse` wrapped by Fastify's `Reply`
- It exposes native properties such as `headersSent`, `writableEnded`, `statusCode`, and `socket`
- Direct writes to `reply.raw` bypass Fastify's serialization, hooks, and lifecycle management
- Always pair direct `reply.raw` usage with `reply.hijack()` when intentionally bypassing Fastify
- Use `reply.raw` for compatibility with legacy middleware, WebSocket upgrades, socket inspection, or guarding against double-sends
- Prefer Fastify's `reply` API for all standard response handling