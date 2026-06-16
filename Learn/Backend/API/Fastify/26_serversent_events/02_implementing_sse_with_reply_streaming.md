## Implementing SSE with Reply Streaming

### Overview

Fastify's response lifecycle is designed around sending a complete response. SSE requires a different pattern: holding the connection open and writing data incrementally. In Fastify, this is done by bypassing the normal reply serialization pipeline and writing directly to the underlying Node.js stream via `reply.raw`.

---

### Why `reply.raw` Is Necessary

Fastify's `reply.send()` finalizes and closes the response. For SSE, the response must remain open indefinitely. `reply.raw` exposes the underlying `http.ServerResponse` (or `http2.Http2ServerResponse`) object, which supports `write()` without closing the connection.

**Key Points:**

- `reply.send()` must not be called on an SSE route — it terminates the response
- `reply.raw.write()` sends a chunk and keeps the connection open
- `reply.raw.end()` closes the connection explicitly when needed
- Once you write to `reply.raw` directly, Fastify's serialization, schema validation output, and lifecycle hooks that depend on `reply.send()` no longer apply to the body

[Inference] Fastify does not natively detect that you are bypassing `reply.send()`. If route lifecycle hooks or plugins expect `reply.send()` to be called, behavior may be inconsistent. This is an application-level concern.

---

### Setting SSE Response Headers

Headers must be written before the first `reply.raw.write()` call. Use `reply.raw.writeHead()` or set headers individually before writing:

javascript

```javascript
fastify.get('/events', (request, reply) => {
  reply.raw.writeHead(200, {
    'Content-Type': 'text/event-stream',
    'Cache-Control': 'no-cache',
    'Connection': 'keep-alive',
    'X-Accel-Buffering': 'no', // Disables Nginx proxy buffering
  });
});
```

Alternatively, using Fastify's `reply` header API before dropping to `reply.raw`:

javascript

```javascript
fastify.get('/events', (request, reply) => {
  reply
    .header('Content-Type', 'text/event-stream')
    .header('Cache-Control', 'no-cache')
    .header('Connection', 'keep-alive')
    .header('X-Accel-Buffering', 'no');

  reply.raw.write(''); // Begin flushing headers
});
```

[Inference] Calling `reply.header()` followed by `reply.raw.write()` without `reply.raw.writeHead()` may not consistently flush headers in all Node.js versions or Fastify versions. Using `reply.raw.writeHead()` is the more explicit and reliable approach. Behavior may vary — verify against your Fastify version.

---

### Writing SSE Events

A helper function to format SSE fields keeps the implementation clean and consistent:

javascript

```javascript
function sseEvent({ id, event, data, retry } = {}) {
  let payload = '';

  if (id !== undefined)    payload += `id: ${id}\n`;
  if (event !== undefined) payload += `event: ${event}\n`;
  if (retry !== undefined) payload += `retry: ${retry}\n`;

  // data must always be present; multi-line values split across multiple data: lines
  const lines = String(data).split('\n');
  for (const line of lines) {
    payload += `data: ${line}\n`;
  }

  payload += '\n'; // Blank line terminates the event
  return payload;
}
```

**Example — Sending events in a route:**

javascript

```javascript
fastify.get('/events', (request, reply) => {
  reply.raw.writeHead(200, {
    'Content-Type': 'text/event-stream',
    'Cache-Control': 'no-cache',
    'Connection': 'keep-alive',
    'X-Accel-Buffering': 'no',
  });

  let counter = 0;

  const interval = setInterval(() => {
    const chunk = sseEvent({
      id: counter,
      event: 'tick',
      data: JSON.stringify({ count: counter }),
    });

    reply.raw.write(chunk);
    counter++;
  }, 1000);

  // Clean up when the client disconnects
  request.raw.on('close', () => {
    clearInterval(interval);
  });
});
```

**Output (wire format):**

```
id: 0
event: tick
data: {"count":0}

id: 1
event: tick
data: {"count":1}
```

---

### Detecting Client Disconnection

Failure to clean up on disconnect leaks intervals, listeners, and memory. The `close` event on `request.raw` (the underlying `http.IncomingMessage`) fires when the client closes the connection.

javascript

```javascript
request.raw.on('close', () => {
  // Perform cleanup here
  clearInterval(interval);
  clearTimeout(timeout);
  // Remove from any subscriber list, etc.
});
```

[Inference] The `close` event fires for both intentional client disconnects and network interruptions. There is no built-in distinction between the two at the Node.js HTTP layer — handling them identically is the standard approach.

**Key Points:**

- Always attach a `close` listener for every SSE route
- [Inference] Omitting cleanup may cause intervals or callbacks to continue executing against a closed socket, producing write errors or silent memory leaks — behavior depends on Node.js version and error handling

---

### Handling `write()` Errors

`reply.raw.write()` returns `false` when the internal buffer is full (backpressure) and may throw or emit an error if the socket is closed. Basic defensive handling:

javascript

```javascript
function safWrite(raw, chunk) {
  if (raw.destroyed || raw.writableEnded) return false;
  return raw.write(chunk);
}
```

**Key Points:**

- `raw.destroyed` is `true` after the socket is destroyed (e.g., after disconnect)
- `raw.writableEnded` is `true` after `end()` has been called
- [Inference] Writing to a destroyed stream does not always throw synchronously — behavior depends on the stream implementation and Node.js version. Defensive checks are advisable.

---

### Complete Route Example with Schema Bypass

Fastify enforces response schema validation when a schema is defined. For SSE routes, response schema validation should be omitted or the route marked to skip serialization:

javascript

```javascript
fastify.get(
  '/events',
  {
    schema: {
      // Do not define a response schema for SSE routes
      // Fastify will not serialize reply.raw writes regardless,
      // but an incorrect response schema may interfere with hooks
    },
  },
  (request, reply) => {
    reply.raw.writeHead(200, {
      'Content-Type': 'text/event-stream',
      'Cache-Control': 'no-cache',
      'Connection': 'keep-alive',
      'X-Accel-Buffering': 'no',
    });

    // Send an initial comment to flush headers and confirm connection
    reply.raw.write(': connected\n\n');

    let id = 0;

    const interval = setInterval(() => {
      if (reply.raw.destroyed) {
        clearInterval(interval);
        return;
      }

      reply.raw.write(sseEvent({
        id: id++,
        event: 'update',
        data: JSON.stringify({ time: Date.now() }),
      }));
    }, 2000);

    request.raw.on('close', () => {
      clearInterval(interval);
    });
  }
);
```

**Key Points:**

- The SSE comment line (`: connected\n\n`) is ignored by the `EventSource` API but causes headers to flush immediately in some environments — [Inference] this may help avoid perceived latency on first connection, though behavior varies by proxy and browser
- The `id` counter increments per event to support `Last-Event-ID` reconnection

---

### Reading `Last-Event-ID` on Reconnect

When the browser reconnects after a disconnect, it sends the last received event ID:

javascript

```javascript
fastify.get('/events', (request, reply) => {
  const lastId = request.headers['last-event-id'];
  const resumeFrom = lastId ? parseInt(lastId, 10) : 0;

  reply.raw.writeHead(200, {
    'Content-Type': 'text/event-stream',
    'Cache-Control': 'no-cache',
    'Connection': 'keep-alive',
  });

  // [Inference] Application logic to replay events from resumeFrom
  // would go here — SSE does not define how the server stores events
  let id = resumeFrom;

  const interval = setInterval(() => {
    reply.raw.write(sseEvent({
      id: id++,
      event: 'update',
      data: JSON.stringify({ sequence: id }),
    }));
  }, 1000);

  request.raw.on('close', () => clearInterval(interval));
});
```

---

### Sending a Keepalive Comment

Proxies and load balancers may close idle connections. Periodic SSE comments (lines beginning with `:`) serve as keepalives without dispatching events to the client:

javascript

```javascript
const keepalive = setInterval(() => {
  if (!reply.raw.destroyed) {
    reply.raw.write(': keepalive\n\n');
  }
}, 15000);

request.raw.on('close', () => {
  clearInterval(interval);
  clearInterval(keepalive);
});
```

**Key Points:**

- Comment lines are defined in the SSE spec as lines beginning with `:`
- They are silently discarded by `EventSource` — no event is dispatched
- [Inference] A 15–30 second interval is a common convention; the appropriate interval depends on proxy timeout configuration in your environment

---

### Connection Lifecycle Diagram

<svg viewBox="0 0 740 420" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="13">
<!-- Background -->
<rect width="740" height="420" fill="#0f1117" rx="12"/>
<!-- Title -->

<text x="370" y="30" text-anchor="middle" fill="`#e2e8f0`" font-size="14" font-weight="bold">SSE Connection Lifecycle in Fastify</text>

<!-- Client column -->

<text x="110" y="65" text-anchor="middle" fill="`#7dd3fc`" font-size="13" font-weight="bold">Client</text>
<line x1="110" y1="75" x2="110" y2="390" stroke="`#7dd3fc`" stroke-width="1.5" stroke-dasharray="4,3"/>

<!-- Fastify column -->

<text x="370" y="65" text-anchor="middle" fill="`#86efac`" font-size="13" font-weight="bold">Fastify Route</text>
<line x1="370" y1="75" x2="370" y2="390" stroke="`#86efac`" stroke-width="1.5" stroke-dasharray="4,3"/>

<!-- Node.js Stream column -->

<text x="620" y="65" text-anchor="middle" fill="`#f9a8d4`" font-size="13" font-weight="bold">reply.raw</text>
<line x1="620" y1="75" x2="620" y2="390" stroke="`#f9a8d4`" stroke-width="1.5" stroke-dasharray="4,3"/>

<!-- Step 1: GET /events -->
<line x1="110" y1="100" x2="360" y2="100" stroke="#7dd3fc" stroke-width="1.5" marker-end="url(#arrowBlue)"/>
<text x="230" y="93" text-anchor="middle" fill="#7dd3fc" font-size="11">GET /events</text>
<!-- Step 2: writeHead -->
<line x1="370" y1="120" x2="610" y2="120" stroke="#86efac" stroke-width="1.5" marker-end="url(#arrowGreen)"/>
<text x="490" y="113" text-anchor="middle" fill="#86efac" font-size="11">writeHead(200, SSE headers)</text>
<!-- Step 3: initial flush -->
<line x1="610" y1="140" x2="120" y2="140" stroke="#f9a8d4" stroke-width="1.5" marker-end="url(#arrowPink)"/>
<text x="370" y="133" text-anchor="middle" fill="#f9a8d4" font-size="11">200 OK + headers flushed</text>
<!-- Step 4: write event -->
<line x1="370" y1="180" x2="610" y2="180" stroke="#86efac" stroke-width="1.5" marker-end="url(#arrowGreen)"/>
<text x="490" y="173" text-anchor="middle" fill="#86efac" font-size="11">raw.write(sseEvent(...))</text>
<!-- Step 5: data to client -->
<line x1="610" y1="200" x2="120" y2="200" stroke="#f9a8d4" stroke-width="1.5" marker-end="url(#arrowPink)"/>
<text x="370" y="193" text-anchor="middle" fill="#f9a8d4" font-size="11">event chunk delivered</text>
<!-- Repeat indicator -->
<rect x="310" y="215" width="120" height="22" rx="4" fill="#1e293b" stroke="#475569" stroke-width="1"/>
<text x="370" y="230" text-anchor="middle" fill="#94a3b8" font-size="11">↻ repeats per interval</text>
<!-- Step 6: client disconnects -->
<line x1="110" y1="275" x2="360" y2="275" stroke="#fbbf24" stroke-width="1.5" stroke-dasharray="5,3" marker-end="url(#arrowYellow)"/>
<text x="230" y="268" text-anchor="middle" fill="#fbbf24" font-size="11">connection closed</text>
<!-- Step 7: close event -->
<line x1="370" y1="295" x2="610" y2="295" stroke="#86efac" stroke-width="1.5" marker-end="url(#arrowGreen)"/>
<text x="490" y="288" text-anchor="middle" fill="#86efac" font-size="11">request.raw 'close' fires</text>
<!-- Step 8: cleanup -->
<rect x="270" y="315" width="200" height="28" rx="5" fill="#1e293b" stroke="#f87171" stroke-width="1"/>
<text x="370" y="334" text-anchor="middle" fill="#f87171" font-size="12">clearInterval / cleanup</text>
<!-- raw.destroyed -->
<line x1="370" y1="355" x2="610" y2="355" stroke="#86efac" stroke-width="1" stroke-dasharray="3,3" marker-end="url(#arrowGreen)"/>
<text x="490" y="348" text-anchor="middle" fill="#86efac" font-size="11">raw.destroyed = true</text>
<!-- Arrow markers -->
<defs>
<marker id="arrowBlue" markerWidth="8" markerHeight="8" refX="6" refY="3" orient="auto">
<path d="M0,0 L0,6 L8,3 z" fill="#7dd3fc"/>
</marker>
<marker id="arrowGreen" markerWidth="8" markerHeight="8" refX="6" refY="3" orient="auto">
<path d="M0,0 L0,6 L8,3 z" fill="#86efac"/>
</marker>
<marker id="arrowPink" markerWidth="8" markerHeight="8" refX="6" refY="3" orient="auto">
<path d="M0,0 L0,6 L8,3 z" fill="#f9a8d4"/>
</marker>
<marker id="arrowYellow" markerWidth="8" markerHeight="8" refX="6" refY="3" orient="auto">
<path d="M0,0 L0,6 L8,3 z" fill="#fbbf24"/>
</marker>
</defs>
</svg>

---

### Route Registration Considerations

**Key Points:**

- SSE routes should have no `reply` schema defined for the response body
- If the Fastify instance uses a global `onSend` hook that modifies the response body, [Inference] it may interfere with raw writes — test hooks explicitly against SSE routes
- Compression plugins (e.g., `@fastify/compress`) may attempt to compress the response stream — SSE and response compression are generally incompatible and compression should be disabled per-route

**Example — Disabling compression for an SSE route:**

javascript

```javascript
fastify.get('/events', {
  config: { compress: false }, // plugin-specific config key — verify with your version
}, (request, reply) => {
  // ...
});
```

[Unverified] The exact config key for disabling `@fastify/compress` per-route depends on the plugin version. Consult the plugin documentation for your installed version.

---

**Related Topics:**

- Broadcasting SSE events to multiple connected clients
- Managing a client registry (Map of active SSE connections)
- SSE with authentication and access control in Fastify
- Using `fastify-sse-v2` plugin vs. manual `reply.raw` implementation
- Backpressure handling and writable stream buffering
- SSE over HTTP/2 in Fastify
- Integrating Redis pub/sub for multi-instance SSE fan-out
- Testing SSE routes in Fastify (inject limitations, integration test strategies)