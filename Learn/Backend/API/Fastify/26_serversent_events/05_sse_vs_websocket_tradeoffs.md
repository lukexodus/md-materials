## SSE vs WebSocket Trade-offs

### Framing the Comparison

SSE and WebSockets solve overlapping but distinct problems. Choosing between them based on a feature checklist alone misses the deeper question: what communication model does the application actually require? This topic examines the trade-offs across protocol mechanics, infrastructure behavior, browser API constraints, implementation complexity in Fastify, and operational characteristics.

---

### Protocol Fundamentals

#### SSE

SSE runs entirely over HTTP. The client makes a standard GET request; the server responds with `Content-Type: text/event-stream` and holds the connection open, writing chunks. No protocol upgrade occurs. The connection is unidirectional: server → client only.

```
Client                    Server
  |--- GET /events -------->|
  |<-- 200 text/event-stream|
  |<-- data: event1 --------|
  |<-- data: event2 --------|
  |         (open)          |
```

#### WebSockets

WebSockets begin as HTTP but immediately upgrade to the WebSocket protocol (`ws://` or `wss://`). After the upgrade handshake, both sides can send frames at any time. The connection is bidirectional and full-duplex.

```
Client                    Server
  |--- GET /ws ------------>|  HTTP Upgrade request
  |    Upgrade: websocket   |
  |<-- 101 Switching -------|  Protocol upgrade
  |<== frame <==============>|  Bidirectional frames
  |<== frame <==============>|
```

**Key Points:**

- SSE is a request-response model with a persistent body — it is still HTTP
- WebSockets are a separate protocol with a distinct framing format, opcodes, and connection lifecycle
- [Inference] The distinction matters for infrastructure: anything that understands HTTP generally handles SSE; WebSocket support requires explicit handling at each network layer

---

### Directionality

This is the most fundamental difference and should drive the initial decision.

| Scenario | SSE | WebSocket |
| --- | --- | --- |
| Server pushes updates to client | ✓ | ✓ |
| Client sends messages to server | ✗ (HTTP only) | ✓ |
| Bidirectional real-time messaging | ✗ | ✓ |
| Notifications, feeds, live data | ✓ (simpler) | ✓ (overkill) |
| Chat, collaborative editing | ✗ | ✓ |
| Command-response over persistent connection | ✗ | ✓ |

**Key Points:**

- SSE clients can still send data to the server — via separate HTTP requests (e.g., POST/PUT) — but this is not part of the SSE connection itself
- [Inference] For applications where client-to-server messages are infrequent (e.g., acknowledging a notification), the SSE + HTTP request hybrid is often simpler than a full WebSocket implementation
- If the client needs to stream data to the server, SSE is not applicable

---

### Connection Model and HTTP Compatibility

#### SSE and HTTP/1.1 Connection Limits

Under HTTP/1.1, browsers limit concurrent connections per origin — commonly six. Each open `EventSource` occupies one slot. Multiple tabs each opening an SSE connection to the same origin can exhaust this pool.

```
Tab 1: EventSource → connection slot 1
Tab 2: EventSource → connection slot 2
Tab 3: EventSource → connection slot 3
...
Tab 6: EventSource → connection slot 6  ← pool exhausted
Tab 7: All HTTP requests stall
```

#### SSE and HTTP/2

HTTP/2 multiplexes all streams over a single TCP connection. Multiple SSE connections from the same browser to the same origin share one underlying connection, effectively removing the per-origin limit.

[Inference] Fastify with HTTP/2 enabled may mitigate the connection limit problem for SSE. The practical impact depends on the HTTP/2 implementation, server configuration, and client behavior — verify against your deployment environment.

#### WebSockets and HTTP

WebSockets upgrade out of HTTP entirely. They are not subject to the six-connection limit in the same way, but they do consume one TCP connection per socket. [Inference] Under very high numbers of concurrent WebSocket connections from the same client, OS-level socket limits may apply — this is a more extreme scenario than typical browser usage.

---

### Infrastructure and Proxy Behavior

This is frequently the deciding factor in enterprise or cloud environments.

#### SSE Through Proxies

SSE is standard HTTP with a long-lived response body. Most HTTP proxies handle this correctly, but some buffer responses before forwarding them, breaking the streaming behavior.

Known issues:

- Nginx buffers proxy responses by default — requires `proxy_buffering off` or `X-Accel-Buffering: no`
- Some CDNs terminate SSE connections at their edge nodes — [Unverified] behavior varies widely by provider and configuration
- HTTP/1.0 proxies may not support persistent connections at all

Fastify mitigation:

javascript

```javascript
reply.raw.writeHead(200, {
  'Content-Type': 'text/event-stream',
  'Cache-Control': 'no-cache',
  'Connection': 'keep-alive',
  'X-Accel-Buffering': 'no', // Nginx-specific header
});
```

#### WebSockets Through Proxies

WebSocket connections require the proxy to understand and forward the HTTP Upgrade handshake. Many older or misconfigured proxies do not:

- Corporate HTTP proxies often block or strip `Upgrade` headers
- Some load balancers require explicit WebSocket support configuration
- [Inference] Environments with strict HTTP inspection (DLP, corporate firewalls) are more likely to interfere with WebSocket connections than with SSE

**Nginx WebSocket proxy config (required):**

nginx

```nginx
location /ws {
  proxy_pass http://backend;
  proxy_http_version 1.1;
  proxy_set_header Upgrade $http_upgrade;
  proxy_set_header Connection "Upgrade";
}
```

**Key Points:**

- SSE is generally more proxy-compatible than WebSockets by default
- [Inference] In environments where proxy configuration is outside your control, SSE has a higher probability of working without intervention
- WebSockets in controlled infrastructure (your own servers, known load balancers) are well-supported when configured explicitly

---

### Browser API Comparison

#### `EventSource` (SSE)

javascript

```javascript
const source = new EventSource('/events', { withCredentials: true });

source.onmessage = (e) => console.log(e.data);
source.addEventListener('custom', (e) => console.log(e.data));
source.onerror = (e) => console.error(e);
source.close();
```

Constraints:

- GET requests only — no custom HTTP method
- No custom request headers (no `Authorization: Bearer ...`)
- Text data only — no binary frames
- Automatic reconnection with `Last-Event-ID` is built in
- No explicit ping/pong mechanism

#### `WebSocket`

javascript

```javascript
const ws = new WebSocket('wss://example.com/ws');

ws.onopen = () => ws.send(JSON.stringify({ type: 'subscribe', channel: 'events' }));
ws.onmessage = (e) => console.log(e.data);
ws.onerror = (e) => console.error(e);
ws.onclose = (e) => console.log('closed', e.code, e.reason);
```

Capabilities:

- Bidirectional at any time after open
- Binary frames supported (`ArrayBuffer`, `Blob`)
- No automatic reconnection — must implement manually
- No built-in `Last-Message-ID` semantics — application must define
- Custom subprotocols via `Sec-WebSocket-Protocol`

**Key Points:**

- `EventSource` has simpler semantics but narrower capability
- WebSocket reconnection logic must be written by the application — [Inference] this is a common source of bugs (missed events, state desync) if not handled carefully
- The absence of native auth header support in `EventSource` forces workarounds (query param tokens, cookies, or `fetch-event-source`)

---

### Authentication

#### SSE Authentication

`EventSource` does not support custom headers. Options:

javascript

```javascript
// Option 1: Token in query parameter (weaker security posture)
// [Inference] Tokens in URLs appear in server logs, browser history,
// and referrer headers — generally not recommended for sensitive tokens
const source = new EventSource(`/events?token=${jwt}`);

// Option 2: Cookie-based auth (EventSource sends cookies automatically
// when withCredentials: true and the endpoint is same-origin or CORS-configured)
const source = new EventSource('/events', { withCredentials: true });

// Option 3: fetch-event-source (custom headers supported)
await fetchEventSource('/events', {
  headers: { Authorization: `Bearer ${jwt}` },
  // ...
});
```

#### WebSocket Authentication

WebSocket handshake headers are set by the browser and cannot include custom `Authorization` headers directly. Same constraints apply:

javascript

```javascript
// Option 1: Token in query parameter
const ws = new WebSocket(`wss://example.com/ws?token=${jwt}`);

// Option 2: Send auth message immediately after open
ws.onopen = () => {
  ws.send(JSON.stringify({ type: 'auth', token: jwt }));
};

// Option 3: Cookie-based (automatic)
```

**Key Points:**

- Both SSE and WebSockets share the same browser-imposed authentication constraints at connection time
- [Inference] The "send auth as first message" WebSocket pattern is common but exposes a window between connection open and auth receipt — connections must be treated as unauthenticated until the auth message is processed
- In Fastify, both approaches can validate auth in a plugin `onRequest` hook before the connection is established

---

### Fastify Implementation Complexity

#### SSE in Fastify

javascript

```javascript
// Core implementation — no additional dependencies
fastify.get('/events', (request, reply) => {
  reply.raw.writeHead(200, {
    'Content-Type': 'text/event-stream',
    'Cache-Control': 'no-cache',
    'Connection': 'keep-alive',
  });

  const interval = setInterval(() => {
    reply.raw.write(`data: ${JSON.stringify({ ts: Date.now() })}\n\n`);
  }, 1000);

  request.raw.on('close', () => clearInterval(interval));
});
```

No additional dependencies. Wire format is plain text. Debugging with `curl` is trivial:

bash

```bash
curl -N http://localhost:3000/events
```

#### WebSockets in Fastify

Requires `@fastify/websocket`:

bash

```bash
npm install @fastify/websocket
```

javascript

```javascript
import fastifyWebsocket from '@fastify/websocket';

await fastify.register(fastifyWebsocket);

fastify.get('/ws', { websocket: true }, (socket, request) => {
  socket.on('message', (message) => {
    socket.send(JSON.stringify({ echo: message.toString() }));
  });

  socket.on('close', () => {
    // Cleanup
  });
});
```

**Key Points:**

- WebSocket implementation in Fastify requires a plugin and a distinct route option (`{ websocket: true }`)
- WebSocket routes cannot be tested with `fastify.inject()` — integration tests require a real HTTP upgrade
- SSE routes can be partially tested with `fastify.inject()` but streaming behavior requires additional handling
- [Inference] WebSocket message framing, opcode handling, and connection state management are abstracted by `@fastify/websocket` (built on `ws`) — the application still manages reconnection and message sequencing

---

### Scalability and Server Load

#### Per-Connection Cost

Both SSE and WebSocket connections hold open a TCP connection and consume server resources for the duration.

| Resource | SSE | WebSocket |
| --- | --- | --- |
| TCP connection | 1 per client | 1 per client |
| Node.js stream | `http.ServerResponse` | `ws.WebSocket` |
| Memory per idle connection | Low (no active work) | Low (no active work) |
| Server-side event loop impact | Interval/timer driven | Event-driven (message handler) |

[Inference] For read-only broadcast scenarios (many clients receiving the same events), SSE and WebSocket have comparable per-connection resource costs. The difference emerges in routing complexity: broadcasting to N WebSocket clients requires iterating a client registry; SSE is identical in this regard.

#### Horizontal Scaling

Neither SSE nor WebSockets are inherently sticky — but both require that events reach the correct server instance:

```
Client A → Instance 1 (SSE)
Client B → Instance 2 (SSE)
Event published to Instance 1 → Client B never receives it
```

Both require a pub/sub layer (Redis, NATS, etc.) for fan-out. This is an application architecture concern, not a protocol difference.

---

### Decision Framework

<svg viewBox="0 0 740 500" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="12">
<rect width="740" height="500" fill="#0f1117" rx="12"/>
<text x="370" y="30" text-anchor="middle" fill="#e2e8f0" font-size="14" font-weight="bold">SSE vs WebSocket — Decision Flow</text>
<!-- Start -->
<rect x="280" y="50" width="180" height="36" rx="18" fill="#1e293b" stroke="#7dd3fc" stroke-width="1.5"/>
<text x="370" y="73" text-anchor="middle" fill="#7dd3fc" font-size="12">New real-time feature</text>
<line x1="370" y1="86" x2="370" y2="112" stroke="#475569" stroke-width="1.5" marker-end="url(#da)"/>
<!-- Q1 -->
<polygon points="370,112 520,150 370,188 220,150" fill="#1e293b" stroke="#fbbf24" stroke-width="1.5"/>
<text x="370" y="146" text-anchor="middle" fill="#fbbf24" font-size="11">Client needs to send</text>
<text x="370" y="162" text-anchor="middle" fill="#fbbf24" font-size="11">data over the stream?</text>
<!-- Yes → WebSocket -->
<line x1="520" y1="150" x2="640" y2="150" stroke="#475569" stroke-width="1.5" marker-end="url(#da)"/>
<text x="578" y="143" text-anchor="middle" fill="#94a3b8" font-size="10">Yes</text>
<rect x="640" y="130" width="90" height="40" rx="6" fill="#1e293b" stroke="#f9a8d4" stroke-width="1.5"/>
<text x="685" y="155" text-anchor="middle" fill="#f9a8d4" font-size="12">WebSocket</text>
<!-- No -->
<line x1="370" y1="188" x2="370" y2="218" stroke="#475569" stroke-width="1.5" marker-end="url(#da)"/>
<text x="382" y="208" fill="#94a3b8" font-size="10">No</text>
<!-- Q2 -->
<polygon points="370,218 520,256 370,294 220,256" fill="#1e293b" stroke="#fbbf24" stroke-width="1.5"/>
<text x="370" y="252" text-anchor="middle" fill="#fbbf24" font-size="11">Binary data required?</text>
<text x="370" y="268" text-anchor="middle" fill="#fbbf24" font-size="10">(audio, video, binary frames)</text>
<!-- Yes → WebSocket -->
<line x1="520" y1="256" x2="640" y2="256" stroke="#475569" stroke-width="1.5" marker-end="url(#da)"/>
<text x="578" y="249" text-anchor="middle" fill="#94a3b8" font-size="10">Yes</text>
<rect x="640" y="236" width="90" height="40" rx="6" fill="#1e293b" stroke="#f9a8d4" stroke-width="1.5"/>
<text x="685" y="261" text-anchor="middle" fill="#f9a8d4" font-size="12">WebSocket</text>
<!-- No -->
<line x1="370" y1="294" x2="370" y2="324" stroke="#475569" stroke-width="1.5" marker-end="url(#da)"/>
<text x="382" y="314" fill="#94a3b8" font-size="10">No</text>
<!-- Q3 -->
<polygon points="370,324 520,362 370,400 220,362" fill="#1e293b" stroke="#fbbf24" stroke-width="1.5"/>
<text x="370" y="356" text-anchor="middle" fill="#fbbf24" font-size="11">Proxy/firewall control</text>
<text x="370" y="372" text-anchor="middle" fill="#fbbf24" font-size="11">is limited?</text>
<!-- Yes → SSE preferred -->
<line x1="220" y1="362" x2="100" y2="362" stroke="#475569" stroke-width="1.5" marker-end="url(#da)"/>
<text x="160" y="355" text-anchor="middle" fill="#94a3b8" font-size="10">Yes</text>
<rect x="20" y="342" width="80" height="40" rx="6" fill="#1e293b" stroke="#86efac" stroke-width="1.5"/>
<text x="60" y="357" text-anchor="middle" fill="#86efac" font-size="11">SSE</text>
<text x="60" y="373" text-anchor="middle" fill="#86efac" font-size="10">preferred</text>
<!-- No -->
<line x1="370" y1="400" x2="370" y2="430" stroke="#475569" stroke-width="1.5" marker-end="url(#da)"/>
<text x="382" y="420" fill="#94a3b8" font-size="10">No</text>
<!-- Final -->
<rect x="255" y="430" width="230" height="50" rx="8" fill="#1e293b" stroke="#a78bfa" stroke-width="1.5"/>
<text x="370" y="450" text-anchor="middle" fill="#a78bfa" font-size="11">Either works — prefer SSE</text>
<text x="370" y="466" text-anchor="middle" fill="#94a3b8" font-size="10">for simpler implementation</text>
<defs>
<marker id="da" markerWidth="7" markerHeight="7" refX="5" refY="3" orient="auto">
<path d="M0,0 L0,6 L7,3 z" fill="#475569"/>
</marker>
</defs>
</svg>

---

### Consolidated Trade-off Summary

| Dimension | SSE | WebSocket |
| --- | --- | --- |
| Directionality | Server → Client | Bidirectional |
| Protocol | HTTP | HTTP upgrade → WS |
| Binary support | No | Yes |
| Auto-reconnect | Yes (native) | No (manual) |
| `Last-Event-ID` semantics | Built-in | Application-defined |
| Custom auth headers | Not natively | Not natively |
| Proxy compatibility | High (standard HTTP) | Requires explicit support |
| HTTP/2 multiplexing | Yes | No (separate connections) |
| Fastify dependency | None | `@fastify/websocket` |
| Debugging ease | High (`curl -N`) | Lower (binary framing) |
| Reconnection storms | Mitigated by `retry` | Application responsibility |
| Implementation complexity | Low | Moderate |
| Horizontal scale requirement | Pub/sub layer | Pub/sub layer |

---

### When the Answer Is Not Clear-Cut

[Inference] Many production systems that appear to need WebSockets on initial analysis are actually well-served by SSE plus ordinary HTTP. Common examples:

- **Notification feeds** — server pushes; client dismisses via REST POST
- **Live dashboards** — server streams metrics; client filters via query params on reconnect
- **Progress indicators** — server streams job progress; client has no messages to send
- **AI response streaming** — server streams token output; client submitted the prompt via HTTP POST

[Inference] The inverse is also true: if the application roadmap includes features that require bidirectional messaging, starting with WebSockets avoids a later migration. Architectural decisions should account for known near-term requirements, not only the immediate feature.

---

**Related Topics:**

- Implementing WebSockets in Fastify with `@fastify/websocket`
- Hybrid architectures (SSE for server push + REST for client messages)
- AI token streaming over SSE in Fastify
- Pub/sub fan-out for SSE and WebSocket in clustered deployments
- `@microsoft/fetch-event-source` for SSE with full HTTP control
- Load balancer and reverse proxy configuration for SSE and WebSocket
- Testing WebSocket routes in Fastify