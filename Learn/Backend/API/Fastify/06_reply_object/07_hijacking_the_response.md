### Reply Object — Hijacking the Response

Response hijacking refers to taking direct control of the underlying Node.js `http.ServerResponse` object, bypassing Fastify's normal reply lifecycle. This is an advanced technique used when Fastify's abstraction layer needs to be partially or fully circumvented.

---

#### What Hijacking Means

Normally, Fastify manages the full response lifecycle: serialization, hook execution, header setting, and sending. Hijacking means writing directly to `reply.raw` — the raw Node.js `ServerResponse` — and signaling to Fastify that it should no longer manage the response.

> [Inference] The term "hijacking" in this context refers to intentional developer action, not a security concern. It is a documented pattern in Fastify for low-level response control.

---

#### Accessing the Raw Response

`reply.raw` exposes the underlying `http.ServerResponse` instance.

js

```
fastify.get('/hijack', (request, reply) => {
  reply.raw.writeHead(200, { 'Content-Type': 'text/plain' });
  reply.raw.write('Hello ');
  reply.raw.write('World');
  reply.raw.end();
});
```

At this point, Fastify is unaware that the response has been sent. This can cause issues unless Fastify is explicitly informed.

---

#### The Problem Without Notification

If you write to `reply.raw` without notifying Fastify, it may attempt to send its own response after your handler returns, potentially causing errors or double-response attempts.

js

```
// Potentially problematic — Fastify may still try to finalize the reply
fastify.get('/unsafe', async (request, reply) => {
  reply.raw.writeHead(200, {});
  reply.raw.end('done');
  // Fastify expects a return value or reply.send() — conflict may occur
});
```

> [Unverified] The exact error produced by this scenario may vary depending on the Fastify version and handler type (async vs callback). Behavior is not guaranteed.

---

#### Using `reply.hijack()`

`reply.hijack()` tells Fastify to relinquish control of the response. After calling it, Fastify will not attempt to send anything, and no further `onSend` or `onResponse` hooks will be triggered by Fastify's lifecycle.

js

```
fastify.get('/controlled', (request, reply) => {
  reply.hijack();

  reply.raw.writeHead(200, { 'Content-Type': 'text/plain' });
  reply.raw.write('Taking control');
  reply.raw.end();
});
```

**Key points:**

- Call `reply.hijack()` before writing to `reply.raw`
- After hijacking, all response writing is the developer's responsibility
- Fastify will not call `reply.send()`, apply serialization, or execute `onSend` hooks

---

#### Hook Behavior After Hijack

Once `reply.hijack()` is called, Fastify skips the remaining response lifecycle for that request.

| Hook | Behavior After Hijack |
| --- | --- |
| `onRequest` | Still runs (hijack not yet called) |
| `preHandler` | Still runs (hijack not yet called) |
| `onSend` | Skipped |
| `onResponse` | Skipped |
| Serialization | Skipped |
| Error handler | Skipped |

> [Inference] Hooks that have already executed before `reply.hijack()` is called are unaffected. The hijack only prevents subsequent lifecycle steps from running. Confirm this behavior against your Fastify version, as lifecycle details may vary.

---

#### Hijacking in a Plugin or Hook

Hijacking can also be performed inside hooks, which allows short-circuiting the entire request lifecycle before it reaches the route handler.

js

```
fastify.addHook('onRequest', (request, reply, done) => {
  if (request.headers['x-legacy-client']) {
    reply.hijack();
    reply.raw.writeHead(200, { 'Content-Type': 'text/plain' });
    reply.raw.end('Legacy response');
    return done();
  }
  done();
});
```

> [Inference] Calling `done()` after hijacking signals to Fastify that the hook is complete. The hijack call prevents Fastify from sending its own response. Behavior may vary depending on hook type and Fastify version.

---

#### Hijacking for WebSocket Upgrades

One practical use case for hijacking is handling HTTP upgrade requests for WebSockets, where the HTTP connection must be taken over entirely.

js

```
fastify.get('/ws', (request, reply) => {
  if (request.raw.headers.upgrade?.toLowerCase() !== 'websocket') {
    return reply.code(400).send({ error: 'WebSocket upgrade required' });
  }

  reply.hijack();

  // Hand off to a WebSocket library using request.raw and reply.raw.socket
  // e.g., wsServer.handleUpgrade(request.raw, reply.raw.socket, ...)
});
```

> [Inference] This is a simplified illustration. In practice, WebSocket handling in Fastify is most commonly done via the `@fastify/websocket` plugin, which manages the upgrade internally.

---

#### Hijacking vs. Using `reply.raw` Directly

These two approaches are related but distinct:

|  | `reply.raw` only | `reply.hijack()` + `reply.raw` |
| --- | --- | --- |
| Fastify notified | No | Yes |
| `onSend` hook | May still run | Skipped |
| Risk of double-send | Higher | Lower |
| Recommended | No | Yes, when bypassing lifecycle |

Always pair direct `reply.raw` usage with `reply.hijack()` when you intend to fully bypass Fastify's response lifecycle.

---

#### Responsibility After Hijacking

After calling `reply.hijack()`, the following become the developer's full responsibility:

- Writing correct status codes via `reply.raw.writeHead()`
- Setting all necessary headers manually
- Writing the response body with `reply.raw.write()`
- Closing the response with `reply.raw.end()`
- Handling stream errors and socket cleanup
- Managing backpressure if writing large payloads

> [Inference] Fastify provides no further assistance after hijacking. Incomplete responses (e.g., forgetting `reply.raw.end()`) may leave the client connection hanging. Behavior depends on the Node.js HTTP implementation.

---

#### When to Use Hijacking

Hijacking is appropriate in narrow, specific scenarios:

- Implementing custom protocol upgrades (e.g., WebSockets without a plugin)
- Integrating third-party middleware that writes directly to `ServerResponse`
- Low-level SSE implementations requiring precise control
- Proxying or tunneling where raw socket access is needed

For the vast majority of use cases, Fastify's standard `reply` API — including `reply.send()` and streaming — is sufficient and preferable.

---

#### Summary

- `reply.hijack()` signals to Fastify to relinquish response control
- After hijacking, write directly using `reply.raw.writeHead()`, `reply.raw.write()`, and `reply.raw.end()`
- Fastify skips `onSend`, serialization, and `onResponse` hooks after hijacking
- Always call `reply.hijack()` before writing to `reply.raw` when intentionally bypassing the lifecycle
- Use this pattern sparingly; standard Fastify reply methods cover most use cases