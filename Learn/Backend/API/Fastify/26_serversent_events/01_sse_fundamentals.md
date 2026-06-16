## SSE Fundamentals

### What Are Server-Sent Events?

Server-Sent Events (SSE) is a web standard that enables a server to push data to a client over a single, long-lived HTTP connection. Unlike WebSockets, SSE is unidirectional — data flows only from server to client. The client initiates the connection, and the server streams events as they occur.

SSE is defined in the HTML Living Standard and is natively supported in most modern browsers via the `EventSource` API.

**Key Points:**

- Unidirectional: server → client only
- Built on plain HTTP (no protocol upgrade required)
- Automatic reconnection is handled by the browser's `EventSource`
- Text-based wire format (`text/event-stream`)
- Works with existing HTTP infrastructure (proxies, load balancers) — with caveats

---

### The `text/event-stream` Wire Format

SSE uses a simple, line-based text format. The server sets the `Content-Type` header to `text/event-stream`, then writes newline-delimited fields.

#### Field Types

| Field | Purpose |
| --- | --- |
| `data:` | The payload of the event |
| `event:` | Named event type (optional) |
| `id:` | Event ID for reconnection tracking (optional) |
| `retry:` | Reconnect delay in milliseconds (optional) |

A blank line (`\n\n`) terminates each event and signals the client to dispatch it.

**Example — Minimal event:**

```
data: Hello, world!\n\n
```

**Example — Multi-line data:**

```
data: {"user": "luke"}\n
data: {"status": "active"}\n
\n
```

[Inference] Multi-line `data:` fields are concatenated by the client with a newline character between them before dispatch. Behavior may vary across `EventSource` implementations.

**Example — Named event with ID:**

```
id: 42\n
event: userJoined\n
data: {"name": "luke"}\n
\n
```

**Example — Retry hint:**

```
retry: 5000\n
data: reconnect in 5 seconds if disconnected\n
\n
```

---

### The HTTP Response Contract

To establish an SSE stream, the server must respond with specific headers:

http

```http
HTTP/1.1 200 OK
Content-Type: text/event-stream
Cache-Control: no-cache
Connection: keep-alive
```

**Key Points:**

- `Content-Type: text/event-stream` is mandatory — clients reject streams without it
- `Cache-Control: no-cache` prevents intermediaries from buffering the stream
- `Connection: keep-alive` signals the connection must remain open
- The response body is never terminated by the server during normal operation; the stream stays open indefinitely

[Inference] Some reverse proxies (e.g., Nginx) buffer responses by default. SSE may appear to hang unless proxy buffering is explicitly disabled (`X-Accel-Buffering: no` or equivalent). Behavior depends on your infrastructure.

---

### How the Browser `EventSource` API Works

The client uses the built-in `EventSource` interface:

javascript

```javascript
const source = new EventSource('/events');

// Generic message handler (listens to unnamed events)
source.onmessage = (event) => {
  console.log('Received:', event.data);
};

// Named event handler
source.addEventListener('userJoined', (event) => {
  const payload = JSON.parse(event.data);
  console.log('User joined:', payload.name);
});

// Error handler
source.onerror = (err) => {
  console.error('SSE error:', err);
};

// Close the connection from the client side
source.close();
```

**Key Points:**

- `EventSource` automatically reconnects after disconnection, using the last received `id` in the `Last-Event-ID` request header
- The `retry:` field sent by the server overrides the default reconnect delay (browser default varies; [Unverified] typically 3000ms)
- `EventSource` only supports GET requests with no custom request body
- To send custom headers (e.g., `Authorization`), `EventSource` alone is insufficient — alternatives are discussed below

---

### Reconnection and the `Last-Event-ID` Header

SSE has built-in reconnection semantics. When a connection drops, the browser automatically reconnects and sends:

http

```http
GET /events HTTP/1.1
Last-Event-ID: 42
```

The server reads this header and resumes streaming from after event `42`. This requires the server to maintain some form of event history or cursor — SSE itself does not define how the server stores or retrieves past events.

**Key Points:**

- If no `id:` field was ever sent, `Last-Event-ID` will be absent on reconnect
- [Inference] If the server has no event history, it typically ignores `Last-Event-ID` and simply resumes from the current state
- Event replay is an application-level concern, not an SSE protocol guarantee

---

### SSE vs WebSockets vs Long Polling

```
┌─────────────────────────────────────────────────────────────┐
│              Communication Pattern Comparison               │
├────────────────┬──────────────┬──────────────┬─────────────┤
│ Feature        │ SSE          │ WebSockets   │ Long Poll   │
├────────────────┼──────────────┼──────────────┼─────────────┤
│ Direction      │ Server→Client│ Bidirectional│ Server→     │
│                │              │              │ Client      │
├────────────────┼──────────────┼──────────────┼─────────────┤
│ Protocol       │ HTTP         │ WS (upgrade) │ HTTP        │
├────────────────┼──────────────┼──────────────┼─────────────┤
│ Auto-reconnect │ Yes (native) │ No           │ Manual      │
├────────────────┼──────────────┼──────────────┼─────────────┤
│ Browser API    │ EventSource  │ WebSocket    │ fetch/XHR   │
├────────────────┼──────────────┼──────────────┼─────────────┤
│ Proxy-friendly │ Generally    │ Varies       │ Yes         │
├────────────────┼──────────────┼──────────────┼─────────────┤
│ Binary support │ No           │ Yes          │ Yes         │
├────────────────┼──────────────┼──────────────┼─────────────┤
│ Overhead       │ Low          │ Low          │ High        │
└────────────────┴──────────────┴──────────────┴─────────────┘
```

**Key Points:**

- SSE is appropriate when the client does not need to send a stream of messages back to the server
- WebSockets are appropriate for bidirectional, low-latency communication (e.g., chat, gaming)
- Long polling is a fallback pattern with higher overhead; [Inference] it is generally superseded by SSE in environments that support it
- [Inference] SSE's HTTP/2 multiplexing support may reduce connection overhead compared to HTTP/1.1 WebSocket connections in some configurations — behavior depends on server and client implementation

---

### HTTP/2 and SSE

Under HTTP/1.1, browsers limit concurrent connections per domain (commonly 6). Each open `EventSource` occupies one connection slot. Under HTTP/2, multiple SSE streams are multiplexed over a single TCP connection, removing this practical constraint.

[Inference] Fastify with HTTP/2 enabled [Unverified — verify Fastify HTTP/2 configuration specifics] may allow many simultaneous SSE streams without hitting per-domain connection limits. Actual behavior depends on the HTTP/2 implementation and client support.

---

### CORS and SSE

SSE requests are subject to CORS. If the SSE endpoint is on a different origin, the server must include the appropriate `Access-Control-Allow-Origin` header. Additionally, `EventSource` supports credentials:

javascript

```javascript
const source = new EventSource('/events', { withCredentials: true });
```

This sends cookies and auth headers. The server must respond with:

http

```http
Access-Control-Allow-Origin: https://your-client-origin.com
Access-Control-Allow-Credentials: true
```

[Inference] Wildcards (`*`) in `Access-Control-Allow-Origin` are incompatible with `withCredentials: true`. This is a browser-enforced CORS constraint, not an SSE-specific rule.

---

### Limitations and Considerations

#### What `EventSource` Cannot Do

- Send POST requests or custom HTTP headers natively
- Transmit binary data (SSE is text-only)
- Work without HTTPS in mixed-content browser environments [Unverified — browser policies vary and evolve]

#### Workarounds

- Pass authentication tokens as query parameters (security trade-off: tokens appear in logs and browser history — [Inference] this is generally considered a weaker security posture)
- Use a library like `@microsoft/fetch-event-source` which builds SSE over `fetch`, enabling custom headers and POST requests
- Proxy auth through a cookie-based session

#### Scalability Considerations

- Each SSE connection is a persistent HTTP connection — the server holds state per connected client
- [Inference] Under high concurrency, this may exhaust file descriptors or memory — exact limits depend on the OS, Fastify configuration, and Node.js version
- Horizontal scaling across multiple server instances requires a shared pub/sub layer (e.g., Redis) to fan out events to clients connected to different nodes — this is an architectural concern, not an SSE protocol feature

---

### Minimal Raw SSE Example (Node.js, no framework)

To ground the concepts before moving to Fastify-specific implementation:

javascript

```javascript
const http = require('http');

const server = http.createServer((req, res) => {
  if (req.url === '/events') {
    res.writeHead(200, {
      'Content-Type': 'text/event-stream',
      'Cache-Control': 'no-cache',
      'Connection': 'keep-alive',
    });

    let counter = 0;
    const interval = setInterval(() => {
      res.write(`id: ${counter}\n`);
      res.write(`data: {"count": ${counter}}\n\n`);
      counter++;
    }, 1000);

    req.on('close', () => {
      clearInterval(interval);
    });
  } else {
    res.writeHead(404);
    res.end();
  }
});

server.listen(3000);
```

**Key Points:**

- `res.write()` sends chunks without closing the connection
- `req.on('close')` fires when the client disconnects — cleanup is essential to avoid leaking intervals or event listeners
- No `res.end()` is called for the SSE route; the connection remains open

---

**Next Steps**

**Related Topics:**

- Implementing SSE in Fastify (route setup, `reply.raw`, response headers)
- Managing client connections and cleanup in Fastify
- Broadcasting events to multiple SSE clients
- Using `fastify-sse-v2` or similar plugins
- SSE with authentication (JWT via query param vs. cookie vs. fetch-event-source)
- Redis pub/sub for SSE fan-out in clustered Fastify deployments
- HTTP/2 configuration in Fastify and its effect on SSE
- Replacing `EventSource` with `@microsoft/fetch-event-source`