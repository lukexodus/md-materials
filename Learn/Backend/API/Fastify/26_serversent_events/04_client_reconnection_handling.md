## Client Reconnection Handling

### What Reconnection Means in SSE

SSE reconnection is a protocol-level feature built into the `EventSource` API. When a connection drops — due to a network interruption, server restart, proxy timeout, or any other cause — the browser automatically attempts to re-establish the connection after a delay. The server receives this as a new, ordinary HTTP GET request, with one addition: the `Last-Event-ID` header carrying the ID of the last event the client successfully received.

The SSE protocol defines the transport mechanics. Everything else — event storage, replay, gap detection, and client state recovery — is the application's responsibility.

---

### The Reconnection Sequence

```
Client                            Server
  |                                 |
  |--- GET /events ---------------->|
  |<-- 200 + SSE headers -----------|
  |<-- id:1 data:{"x":1} ----------|
  |<-- id:2 data:{"x":2} ----------|
  |                                 |
  |  [connection drops]             |
  |                                 |
  |  [waits retry ms]               |
  |                                 |
  |--- GET /events ---------------->|
  |    Last-Event-ID: 2             |
  |<-- 200 + SSE headers -----------|
  |<-- id:3 data:{"x":3} ----------| ← server resumes from id 3
  |<-- id:4 data:{"x":4} ----------|
```

**Key Points:**

- The browser sends `Last-Event-ID` automatically — no client-side code is required
- The server must read this header and decide what to do with it
- If the server has no event history, it cannot replay missed events — the header is simply ignored
- [Inference] If events were missed during the disconnection window and the server has no store, those events are permanently lost from the client's perspective

---

### Reading `Last-Event-ID` in Fastify

javascript

```javascript
fastify.get('/events', (request, reply) => {
  const rawLastId = request.headers['last-event-id'];
  const lastId = rawLastId !== undefined ? parseInt(rawLastId, 10) : null;

  reply.raw.writeHead(200, {
    'Content-Type': 'text/event-stream',
    'Cache-Control': 'no-cache',
    'Connection': 'keep-alive',
    'X-Accel-Buffering': 'no',
  });

  if (lastId !== null) {
    // Client is reconnecting — resume or replay from lastId
    replayFrom(lastId, reply);
  } else {
    // Fresh connection
    reply.raw.write(': connected\n\n');
  }

  // Continue streaming new events...
});
```

**Key Points:**

- `last-event-id` is lowercase in Node.js HTTP headers (HTTP/1.1 headers are case-insensitive but Node.js normalizes them to lowercase)
- `parseInt` with radix `10` is used defensively — treat any non-numeric value as an absent ID
- [Inference] A missing `Last-Event-ID` header indicates either a fresh connection or a client whose `EventSource` was constructed without having received any prior events — the two cases are indistinguishable at the HTTP layer

---

### The `retry` Field and Reconnect Delay

The server can instruct the client how long to wait before reconnecting by sending a `retry:` field:

javascript

```javascript
// Send once at connection start to set the client's reconnect delay
reply.raw.write('retry: 3000\n\n'); // 3 seconds
```

**Key Points:**

- `retry` is specified in milliseconds
- The client stores this value and uses it for all subsequent reconnections until a new `retry` field is received
- [Unverified] Browser default retry delay when no `retry` field has been received — commonly cited as 3000ms but this is implementation-defined and may differ across browsers
- The `retry` field can be sent at any time, not only at connection start — [Inference] sending a longer delay after a server-side error may reduce reconnection storms under load

---

### Event ID Strategy

Event IDs must be chosen deliberately. The ID scheme determines what the server can do on reconnection.

#### Monotonic Integer IDs

Simple, predictable, and easy to replay from:

javascript

```javascript
let globalId = 0;

function nextId() {
  return ++globalId;
}
```

[Inference] A global in-process counter resets on server restart. After a restart, the server has no knowledge of the last ID a client received, and replay is impossible without a persistent store. This is a fundamental limitation of in-memory ID generation.

#### Timestamp-Based IDs

javascript

```javascript
function nextId() {
  return Date.now().toString();
}
```

**Key Points:**

- Timestamps are monotonically increasing in normal operation
- [Inference] Clock skew, NTP adjustments, or multiple server instances may produce non-monotonic timestamps — use with caution in distributed systems
- Timestamps do not directly index into an event store without additional lookup logic

#### UUID / Opaque IDs

javascript

```javascript
import { randomUUID } from 'crypto';

function nextId() {
  return randomUUID();
}
```

**Key Points:**

- Globally unique but carry no ordering information
- [Inference] Only useful as IDs if the event store supports lookup by opaque key — not suitable for range-based replay (e.g., "give me all events after this one")

---

### In-Memory Event Buffer (Simple Replay)

For low-volume streams where persistence is not required, a bounded in-memory ring buffer holds recent events for replay on reconnect:

javascript

```javascript
class EventBuffer {
  #buffer = [];
  #maxSize;

  constructor(maxSize = 100) {
    this.#maxSize = maxSize;
  }

  push(event) {
    this.#buffer.push(event);
    if (this.#buffer.length > this.#maxSize) {
      this.#buffer.shift(); // Drop oldest
    }
  }

  since(lastId) {
    const idx = this.#buffer.findIndex(e => e.id === lastId);
    if (idx === -1) return []; // lastId not in buffer — gap too large
    return this.#buffer.slice(idx + 1);
  }

  get latest() {
    return this.#buffer.at(-1) ?? null;
  }
}

const buffer = new EventBuffer(200);
```

**Usage in a route:**

javascript

```javascript
fastify.get('/events', (request, reply) => {
  const rawLastId = request.headers['last-event-id'];
  const lastId = rawLastId ? parseInt(rawLastId, 10) : null;

  reply.raw.writeHead(200, {
    'Content-Type': 'text/event-stream',
    'Cache-Control': 'no-cache',
    'Connection': 'keep-alive',
    'X-Accel-Buffering': 'no',
  });

  // Replay missed events if reconnecting
  if (lastId !== null) {
    const missed = buffer.since(lastId);

    if (missed.length === 0 && lastId !== null) {
      // Gap too large — signal client to reset state
      reply.raw.write(sseEvent({
        event: 'reset',
        data: JSON.stringify({ reason: 'gap_too_large' }),
      }));
    } else {
      for (const event of missed) {
        reply.raw.write(sseEvent(event));
      }
    }
  }

  // Subscribe to new events (see broadcasting topic)
  // ...
});
```

**Key Points:**

- `since()` returns an empty array when `lastId` is not in the buffer — this means the client has been disconnected longer than the buffer covers
- The `reset` event is an application-level convention — [Inference] the client must handle it explicitly (e.g., reload state from a REST endpoint)
- [Inference] Buffer size should be chosen based on event frequency and expected maximum disconnection duration — there is no universal formula

---

### Detecting a Gap

A gap occurs when the client's `Last-Event-ID` refers to an event that is no longer in the buffer (or was never stored):

```
Buffer: [id:150, id:151, id:152, ..., id:300]
Client Last-Event-ID: 80   ← not in buffer → gap
```

Gap handling options:

| Strategy | Description | Trade-off |
| --- | --- | --- |
| Ignore and resume | Stream from current position | Client misses events silently |
| Send `reset` event | Signal client to reload from REST | Requires client-side handling |
| Reject with 409 | HTTP error, client handles | Breaks `EventSource` auto-reconnect |
| Expand buffer | Keep more history | Memory cost |
| Persist events | Use a database or Redis | Operational complexity |

[Inference] Rejecting with a non-2xx status code causes `EventSource` to fire its `onerror` handler and continue retrying — the client does not stop reconnecting automatically. This may cause a reconnection loop if the gap condition persists.

---

### Preventing Reconnection Storms

When a server restarts or becomes temporarily unavailable, all connected clients attempt to reconnect simultaneously. This can overwhelm the recovering server.

#### Exponential Backoff via `retry`

The SSE protocol's `retry` field does not support exponential backoff natively — it sets a fixed delay. [Inference] True exponential backoff requires client-side implementation, which is not possible with the native `EventSource` API.

Mitigation strategies available server-side:

**Increasing `retry` under load:**

javascript

```javascript
// Send a longer retry delay before closing under high load
reply.raw.write('retry: 10000\n\n');
reply.raw.write(sseEvent({
  event: 'backoff',
  data: JSON.stringify({ retryAfter: 10000 }),
}));
reply.raw.end();
```

**Jitter via query parameter (client must cooperate):**

javascript

```javascript
// Client adds jitter before connecting
const jitter = Math.floor(Math.random() * 2000);
const source = new EventSource(`/events?jitter=${jitter}`);
// Server ignores the param but reads it — or client delays the connection itself
```

[Inference] The most effective reconnection storm mitigation requires clients that do not use the native `EventSource` — libraries like `@microsoft/fetch-event-source` allow implementing exponential backoff and jitter on the client side. Native `EventSource` only supports the fixed `retry` delay.

---

### Handling Reconnection in the Client (`fetch-event-source`)

When native `EventSource` limitations are a concern, `@microsoft/fetch-event-source` provides a fetch-based SSE client with full control over reconnection:

javascript

```javascript
import { fetchEventSource } from '@microsoft/fetch-event-source';

let retryDelay = 1000;

await fetchEventSource('/events', {
  headers: {
    Authorization: `Bearer ${token}`,
  },
  onopen(response) {
    if (response.ok) {
      retryDelay = 1000; // Reset on successful open
      return;
    }
    throw new Error(`Unexpected status: ${response.status}`);
  },
  onmessage(event) {
    console.log('Event:', event.data);
  },
  onerror(err) {
    // Return a delay in ms to retry; throw to stop
    retryDelay = Math.min(retryDelay * 2, 30000); // Exponential backoff cap at 30s
    return retryDelay;
  },
});
```

**Key Points:**

- `onerror` returning a number causes the library to wait that many milliseconds before reconnecting
- Custom headers (e.g., `Authorization`) can be sent on every reconnect attempt
- [Inference] The library does not automatically send `Last-Event-ID` unless implemented manually in the `onopen` or request headers — verify against the library version

---

### Full Reconnection Handling Flow

<svg viewBox="0 0 760 580" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="12">
<rect width="760" height="580" fill="#0f1117" rx="12"/>
<text x="380" y="30" text-anchor="middle" fill="#e2e8f0" font-size="14" font-weight="bold">SSE Reconnection Handling — Server Decision Flow</text>
<!-- Start -->
<rect x="290" y="50" width="180" height="36" rx="18" fill="#1e293b" stroke="#7dd3fc" stroke-width="1.5"/>
<text x="380" y="73" text-anchor="middle" fill="#7dd3fc" font-size="12">GET /events received</text>
<line x1="380" y1="86" x2="380" y2="110" stroke="#475569" stroke-width="1.5" marker-end="url(#a)"/>
<!-- Decision: Last-Event-ID present? -->
<polygon points="380,110 510,148 380,186 250,148" fill="#1e293b" stroke="#fbbf24" stroke-width="1.5"/>
<text x="380" y="144" text-anchor="middle" fill="#fbbf24" font-size="11">Last-Event-ID</text>
<text x="380" y="160" text-anchor="middle" fill="#fbbf24" font-size="11">present?</text>
<!-- No branch — fresh connection -->
<line x1="250" y1="148" x2="100" y2="148" stroke="#475569" stroke-width="1.5" marker-end="url(#a)"/>
<text x="175" y="140" text-anchor="middle" fill="#94a3b8" font-size="10">No</text>
<rect x="30" y="128" width="70" height="40" rx="6" fill="#1e293b" stroke="#86efac" stroke-width="1"/>
<text x="65" y="144" text-anchor="middle" fill="#86efac" font-size="10">Fresh</text>
<text x="65" y="158" text-anchor="middle" fill="#86efac" font-size="10">connection</text>
<line x1="65" y1="168" x2="65" y2="440" stroke="#475569" stroke-width="1" stroke-dasharray="3,3"/>
<line x1="65" y1="440" x2="290" y2="440" stroke="#475569" stroke-width="1" stroke-dasharray="3,3" marker-end="url(#a)"/>
<!-- Yes branch -->
<line x1="380" y1="186" x2="380" y2="215" stroke="#475569" stroke-width="1.5" marker-end="url(#a)"/>
<text x="392" y="205" fill="#94a3b8" font-size="10">Yes</text>
<!-- Decision: ID in buffer? -->
<polygon points="380,215 510,253 380,291 250,253" fill="#1e293b" stroke="#fbbf24" stroke-width="1.5"/>
<text x="380" y="249" text-anchor="middle" fill="#fbbf24" font-size="11">ID found in</text>
<text x="380" y="265" text-anchor="middle" fill="#fbbf24" font-size="11">event store?</text>
<!-- No — gap -->
<line x1="510" y1="253" x2="630" y2="253" stroke="#475569" stroke-width="1.5" marker-end="url(#a)"/>
<text x="568" y="245" text-anchor="middle" fill="#94a3b8" font-size="10">No (gap)</text>
<rect x="630" y="233" width="100" height="40" rx="6" fill="#1e293b" stroke="#f87171" stroke-width="1"/>
<text x="680" y="249" text-anchor="middle" fill="#f87171" font-size="10">Send reset</text>
<text x="680" y="263" text-anchor="middle" fill="#f87171" font-size="10">event</text>
<line x1="680" y1="273" x2="680" y2="440" stroke="#475569" stroke-width="1" stroke-dasharray="3,3"/>
<line x1="680" y1="440" x2="470" y2="440" stroke="#475569" stroke-width="1" stroke-dasharray="3,3" marker-end="url(#a)"/>
<!-- Yes — replay -->
<line x1="380" y1="291" x2="380" y2="320" stroke="#475569" stroke-width="1.5" marker-end="url(#a)"/>
<text x="392" y="310" fill="#94a3b8" font-size="10">Yes</text>
<rect x="290" y="320" width="180" height="40" rx="6" fill="#1e293b" stroke="#a78bfa" stroke-width="1.5"/>
<text x="380" y="336" text-anchor="middle" fill="#a78bfa" font-size="11">Replay missed events</text>
<text x="380" y="352" text-anchor="middle" fill="#94a3b8" font-size="10">buffer.since(lastId)</text>
<line x1="380" y1="360" x2="380" y2="390" stroke="#475569" stroke-width="1.5" marker-end="url(#a)"/>
<!-- Stream new events -->
<rect x="290" y="390" width="180" height="50" rx="6" fill="#1e293b" stroke="#86efac" stroke-width="1.5"/>
<text x="380" y="410" text-anchor="middle" fill="#86efac" font-size="11">Stream new events</text>
<text x="380" y="428" text-anchor="middle" fill="#94a3b8" font-size="10">write() per interval/pub</text>
<line x1="380" y1="440" x2="380" y2="470" stroke="#475569" stroke-width="1.5" marker-end="url(#a)"/>
<!-- Client disconnect -->
<rect x="290" y="470" width="180" height="40" rx="6" fill="#1e293b" stroke="#f9a8d4" stroke-width="1"/>
<text x="380" y="486" text-anchor="middle" fill="#f9a8d4" font-size="11">request.raw 'close'</text>
<text x="380" y="502" text-anchor="middle" fill="#94a3b8" font-size="10">cleanup intervals + listeners</text>
<defs>
<marker id="a" markerWidth="7" markerHeight="7" refX="5" refY="3" orient="auto">
<path d="M0,0 L0,6 L7,3 z" fill="#475569"/>
</marker>
</defs>
</svg>

---

### Schema and Route Considerations

The `Last-Event-ID` header should be declared in the route schema for documentation and validation purposes, though Fastify does not enforce header validation by default:

javascript

```javascript
fastify.get('/events', {
  schema: {
    headers: {
      type: 'object',
      properties: {
        'last-event-id': { type: 'string' },
      },
    },
    // No response schema for SSE routes
  },
}, (request, reply) => {
  // ...
});
```

[Inference] Declaring `last-event-id` in the headers schema does not cause Fastify to reject requests without it — the field is optional. This is documentation and tooling value only.

---

### Summary of Server Responsibilities

| Responsibility | Required | Notes |
| --- | --- | --- |
| Read `Last-Event-ID` | Yes | `request.headers['last-event-id']` |
| Assign event IDs | Yes | Required for replay to work |
| Store recent events | Application-defined | Not required by SSE protocol |
| Replay missed events | Application-defined | Only if store exists |
| Detect and handle gaps | Application-defined | Define a gap response strategy |
| Set `retry` field | Optional | Controls client reconnect delay |
| Send keepalive comments | Recommended | Prevents proxy timeout disconnections |

---

**Related Topics:**

- Persistent event storage for SSE replay (database-backed event log)
- Redis Streams as an SSE event source with cursor-based replay
- Broadcasting SSE to multiple connected clients (client registry)
- Reconnection storm mitigation in clustered Fastify deployments
- Using `@microsoft/fetch-event-source` for exponential backoff
- SSE gap detection and client-side state reset patterns
- Testing SSE reconnection behavior in Fastify integration tests