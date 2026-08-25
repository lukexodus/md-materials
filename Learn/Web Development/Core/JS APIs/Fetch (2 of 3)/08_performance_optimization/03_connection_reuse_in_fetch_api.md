## Connection Reuse in Fetch API


### HTTP Connection Mechanics

HTTP connections involve TCP handshakes and, for HTTPS, TLS negotiation. These processes add latency—typically 1-3 round trips before any application data transfers. Connection reuse (HTTP keep-alive or persistent connections) allows multiple requests to share the same TCP connection, eliminating redundant handshakes.

The fetch API doesn't provide direct control over connection reuse. The browser's underlying HTTP client manages connection pooling automatically based on the HTTP protocol version and server support.

### HTTP/1.1 Persistent Connections

HTTP/1.1 enables persistent connections by default through the `Connection: keep-alive` header. After a request completes, the TCP connection remains open for subsequent requests to the same origin.

**Connection pooling behavior:**

- Browsers maintain per-origin connection pools (typically 6-8 connections per origin in HTTP/1.1)
- Connections remain idle for a timeout period (often 60-120 seconds) before closure
- Sequential fetch requests to the same origin automatically reuse available connections

**Limitations:**

- Head-of-line blocking: requests must complete sequentially on each connection
- Connection limits constrain parallelism for HTTP/1.1

```javascript
// These requests will reuse connections from the pool
for (let i = 0; i < 10; i++) {
  fetch('https://api.example.com/data/' + i);
}
// Browser manages connection reuse automatically
```

### HTTP/2 Multiplexing

HTTP/2 fundamentally changes connection reuse through multiplexing. A single TCP connection handles multiple concurrent request/response streams.

**Key characteristics:**

- One connection per origin typically suffices
- Requests and responses interleave at the frame level
- Eliminates head-of-line blocking at the HTTP layer
- Server push capability (though rarely used with fetch)

The fetch API transparently uses HTTP/2 when both browser and server support it. No code changes are required.

```javascript
// All these concurrent requests use the same HTTP/2 connection
Promise.all([
  fetch('https://api.example.com/users'),
  fetch('https://api.example.com/posts'),
  fetch('https://api.example.com/comments')
]);
```

### HTTP/3 and QUIC

HTTP/3 runs over QUIC (UDP-based) instead of TCP. It maintains connection-oriented semantics while reducing connection establishment latency and improving resilience to network changes.

**Benefits for connection reuse:**

- 0-RTT connection resumption for subsequent connections
- Connection migration (survives IP address changes)
- No head-of-line blocking at the transport layer

Browsers automatically negotiate HTTP/3 through Alt-Svc mechanisms. Fetch API usage remains unchanged.

### Connection Pooling Implementation Details

[Inference] Browsers implement connection pools with these typical behaviors:

**Pool organization:**

- Separate pools per origin (protocol + domain + port)
- Subdomain connections don't share pools with parent domains
- Different protocols (HTTP vs HTTPS) use separate pools

**Connection lifecycle:**

- Idle timeout: connections close after inactivity
- Maximum lifetime: connections may refresh after extended use
- Server-directed closure: `Connection: close` header forces termination

**Pool limits:**

- Per-origin concurrent connection limits (HTTP/1.1)
- Global connection limits across all origins
- HTTP/2 typically uses 1 connection per origin

### Request Credentials and Connection Isolation

The `credentials` option affects connection reuse indirectly through connection isolation requirements.

```javascript
fetch('https://api.example.com/data', {
  credentials: 'include'  // Sends cookies
});
```

[Inference] Browsers may partition connection pools based on:

- Cookie state (credentialed vs non-credentialed requests)
- Third-party context isolation
- Privacy partitioning mechanisms (e.g., Firefox's network partitioning)

### Cross-Origin Connection Behavior

Connections are not shared across different origins due to security boundaries.

```javascript
// These use separate connection pools
fetch('https://api.example.com/data');
fetch('https://cdn.example.com/assets');  // Different subdomain
fetch('https://api.example.org/data');    // Different domain
```

Even with CORS-enabled resources, connection pools remain isolated per origin.

### Connection Coalescing in HTTP/2

[Inference] HTTP/2 allows connection coalescing when multiple origins resolve to the same IP address and share a valid TLS certificate covering both domains.

**Requirements for coalescing:**

- Same IP address
- Certificate validity for both origins
- Both origins use HTTPS
- Same HTTP/2 connection settings

This is transparent to fetch API usage but can improve performance for CDNs serving multiple domains from the same infrastructure.

### Keep-Alive Header Manipulation

The fetch API doesn't expose the `Connection` header for modification in requests. Browsers control this automatically.

```javascript
// This attempt is typically ignored or throws an error
fetch('https://api.example.com/data', {
  headers: {
    'Connection': 'close'  // Forbidden header - browser ignores
  }
});
```

The browser prevents direct manipulation of connection management headers to maintain protocol correctness and security.

### Connection Reuse Observability

The fetch API provides no direct visibility into connection reuse. Indirect indicators include:

**Timing information from Performance API:**

```javascript
performance.getEntriesByType('resource')
  .filter(entry => entry.initiatorType === 'fetch')
  .forEach(entry => {
    const connectTime = entry.connectEnd - entry.connectStart;
    // connectTime ≈ 0 suggests connection reuse
    console.log(`${entry.name}: ${connectTime}ms connect time`);
  });
```

A `connectEnd - connectStart` value near zero indicates an existing connection was reused (no TCP handshake occurred).

**TLS timing:**

```javascript
const entry = performance.getEntriesByName('https://api.example.com/data')[0];
const sslTime = entry.requestStart - entry.secureConnectionStart;
// Low sslTime suggests TLS session resumption or connection reuse
```

### Server-Side Connection Management

Server responses influence connection reuse through headers:

**Keep-alive parameters (HTTP/1.1):**

```
Connection: keep-alive
Keep-Alive: timeout=60, max=100
```

The `timeout` indicates how long the server keeps idle connections open; `max` limits requests per connection.

**Connection closure:**

```
Connection: close
```

Forces connection termination after the response completes. Subsequent requests establish new connections.

### Performance Implications

Connection reuse significantly impacts performance metrics:

**Latency reduction:**

- Eliminates TCP handshake (1 round trip, ~10-50ms)
- Eliminates TLS handshake (1-2 round trips, ~50-200ms)
- Cumulative savings for multiple requests

**Resource utilization:**

- Fewer file descriptors and socket buffers
- Reduced CPU overhead from handshake cryptography
- Lower network overhead (fewer SYN/ACK packets)

**Application-level considerations:**

```javascript
// Sequential requests benefit from connection reuse
async function fetchSequential(urls) {
  const results = [];
  for (const url of urls) {
    results.push(await fetch(url));  // Reuses connection
  }
  return results;
}

// Parallel requests may use connection pool
async function fetchParallel(urls) {
  return Promise.all(urls.map(url => fetch(url)));
  // HTTP/1.1: uses multiple pooled connections
  // HTTP/2: multiplexes on single connection
}
```

### Connection Reuse Failures

Connections may not be reused in several scenarios:

**Server-side reasons:**

- Server sends `Connection: close`
- Idle timeout expiration
- Server restart or configuration change
- Maximum requests per connection reached

**Client-side reasons:**

- Connection pool full (HTTP/1.1)
- Browser tab/window closure
- Network change (without HTTP/3 connection migration)
- Connection error or timeout on previous request

**Network-level issues:**

- Proxy or middlebox interference
- NAT timeout
- Firewall state expiration

### Interaction with AbortController

Aborting a fetch request doesn't necessarily close the underlying connection:

```javascript
const controller = new AbortController();

fetch('https://api.example.com/data', {
  signal: controller.signal
});

controller.abort();
// Connection may remain in pool for reuse
```

[Inference] The HTTP client typically keeps the connection alive unless the request was actively transmitting when aborted. The connection returns to the pool after cleanup.

### DNS and Connection Reuse

DNS resolution occurs before connection establishment. Connection reuse bypasses this step:

```javascript
// First request: DNS lookup + connection establishment
await fetch('https://api.example.com/data');

// Subsequent request: reuses connection (no DNS lookup needed)
await fetch('https://api.example.com/more-data');
```

DNS changes between requests don't affect existing connections—they continue to the original IP until closed. New connections use the updated DNS resolution.

### TLS Session Resumption

Separate from TCP connection reuse, TLS session resumption allows abbreviated handshakes on new connections:

**Session ID resumption:**

- Client sends previous session ID
- Server resumes if session still cached
- Reduces TLS handshake to 1 round trip

**Session tickets (RFC 5077):**

- Server sends encrypted session state to client
- Client presents ticket on reconnection
- Eliminates server-side session storage

This is distinct from connection reuse but provides similar latency benefits when connections must be re-established.

### Preconnect and DNS Prefetch

Resource hints can prime connection pools before fetch calls:

```html
<link rel="preconnect" href="https://api.example.com">
<link rel="dns-prefetch" href="https://cdn.example.com">
```

```javascript
// Connection already established from preconnect hint
fetch('https://api.example.com/data');  // Lower latency
```

These hints don't directly control connection reuse but ensure warm connections exist in the pool when fetch executes.

### Service Worker Considerations

Service workers intercept fetch requests before they reach the network layer:

```javascript
// In service worker
self.addEventListener('fetch', event => {
  event.respondWith(
    caches.match(event.request)
      .then(response => response || fetch(event.request))
  );
});
```

When a service worker calls `fetch()`, that request uses the service worker's connection pool, separate from the page's pool. [Inference] This isolation prevents interference between page and service worker network activity.

### Priority and Connection Allocation

[Inference] Browsers implement request prioritization that affects connection pool usage:

**HTTP/1.1:**

- High-priority requests may preempt connection allocation
- Lower-priority requests wait for available connections

**HTTP/2:**

- Priority frames guide server resource allocation
- All requests share the multiplexed connection

The fetch API's `priority` option (experimental) hints at this:

```javascript
fetch('https://api.example.com/critical', {
  priority: 'high'
});

fetch('https://api.example.com/background', {
  priority: 'low'
});
```

### Connection Warmth and Cold Starts

The state of connections affects performance:

**Warm connections:**

- Already in pool, immediately available
- TCP slow start already ramped up
- Optimal throughput

**Cold connections:**

- Require establishment overhead
- TCP slow start limits initial throughput
- Congestion window grows over time

Long-running applications benefit from keeping connections warm through periodic requests:

```javascript
// Keep-alive pattern
setInterval(() => {
  fetch('https://api.example.com/health', {
    method: 'HEAD'  // Minimal overhead
  }).catch(() => {});  // Ignore errors
}, 30000);  // Every 30 seconds
```

[Unverified] This pattern may help maintain persistent connections, though browsers and servers have their own timeout management that may override such attempts.

---

