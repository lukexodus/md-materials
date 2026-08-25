## Browser Networking Basics


### Network Stack Architecture

The browser network stack operates as a multi-layered system that handles all HTTP/HTTPS communications. Modern browsers implement this stack with several key components: the network service (often running in a separate process for security), socket pools for connection management, disk cache for storing responses, and certificate verification systems.

The network service manages request prioritization, scheduling multiple concurrent requests while respecting connection limits. Browsers typically limit connections to 6-8 per domain (HTTP/1.1) but can handle many more with HTTP/2's multiplexing capabilities over a single connection.

### Connection Management

**Connection Pooling**

Browsers maintain pools of persistent TCP connections to reduce latency. When a request completes, the connection remains open for a timeout period (typically 60-120 seconds for keep-alive). Subsequent requests to the same origin reuse these connections, eliminating the TCP handshake and TLS negotiation overhead.

Connection pools are keyed by origin (scheme + host + port) and proxy configuration. HTTP/2 connections use a single multiplexed connection per origin, while HTTP/1.1 maintains multiple parallel connections.

**Connection Preconnection**

Browsers support several connection optimization hints:

- `dns-prefetch`: Resolves DNS early for cross-origin resources
- `preconnect`: Establishes full connection (DNS + TCP + TLS) before the resource is needed
- `prefetch`: Downloads resources for future navigation
- `preload`: High-priority fetch for current page resources

### DNS Resolution

The browser DNS resolver operates with multiple cache layers:

1. **Browser DNS cache**: In-memory cache with TTL from DNS records
2. **OS DNS cache**: System-level cache shared across applications
3. **Router cache**: Network-level caching
4. **ISP recursive resolvers**: External DNS servers

DNS resolution can significantly impact page load time. A cold DNS lookup might take 20-120ms, while cached lookups return instantly. Modern browsers implement DNS prefetching for links on the page, speculatively resolving domains the user might navigate to.

### HTTP Request Lifecycle

**Request Initiation**

When JavaScript calls `fetch()` or the browser parses an HTML resource reference, the request enters the network stack's scheduling queue. The scheduler assigns priority based on resource type:

- HTML documents: Highest
- CSS: Very High
- JavaScript: High/Medium (depending on async/defer)
- Images: Low/Medium
- XHR/Fetch: Varies by developer-set priority

**Request Headers**

The browser automatically appends headers:

- `User-Agent`: Browser identification
- `Accept`: MIME types the browser can handle
- `Accept-Encoding`: Supported compression (gzip, br, deflate)
- `Accept-Language`: Language preferences
- `Cookie`: Relevant cookies for the domain
- `Referer`: Previous page URL (with policy restrictions)
- `Origin`: For CORS requests
- `Connection`: Keep-alive behavior

### TLS/SSL Handshake

For HTTPS requests, the browser performs a TLS handshake:

1. **ClientHello**: Browser sends supported cipher suites, TLS versions, and extensions
2. **ServerHello**: Server selects cipher suite and provides certificate
3. **Certificate Verification**: Browser validates certificate chain against root CAs, checks revocation status (OCSP/CRLSets), and verifies domain name
4. **Key Exchange**: Establishes session keys using chosen algorithm (RSA, ECDHE, etc.)
5. **Finished**: Both parties confirm handshake completion

Modern browsers support TLS 1.2 and 1.3. TLS 1.3 reduces handshake to 1-RTT (round-trip time) compared to 2-RTT for TLS 1.2, and enables 0-RTT for resumed sessions.

### HTTP Protocol Versions

**HTTP/1.1**

The traditional protocol uses text-based headers and establishes multiple parallel connections. Key limitations include head-of-line blocking (requests must complete in order on each connection) and header verbosity on every request.

**HTTP/2**

Introduces binary framing, header compression (HPACK), and multiplexing. A single TCP connection carries multiple bidirectional streams. Benefits:

- Stream prioritization and dependencies
- Server push (server proactively sends resources)
- Reduced overhead from compressed headers
- No head-of-line blocking at HTTP layer

**HTTP/3 (QUIC)**

Runs over UDP instead of TCP, eliminating TCP's head-of-line blocking entirely. Each stream is independent at the transport layer. QUIC includes:

- Built-in TLS 1.3 (no separate handshake)
- Connection migration (survives IP address changes)
- Improved congestion control
- 0-RTT connection establishment for repeated visits

### CORS (Cross-Origin Resource Sharing)

Browsers enforce the same-origin policy, blocking cross-origin requests by default. CORS provides a controlled relaxation through HTTP headers.

**Simple Requests** (GET, HEAD, POST with limited content types) proceed directly, with the browser checking response headers:

- `Access-Control-Allow-Origin`: Permitted origins
- `Access-Control-Allow-Credentials`: Cookie inclusion

**Preflight Requests** (other methods, custom headers) trigger an OPTIONS request first:

```
OPTIONS /resource HTTP/1.1
Origin: https://example.com
Access-Control-Request-Method: PUT
Access-Control-Request-Headers: X-Custom-Header
```

The server responds with allowed methods and headers. Only if approved does the actual request proceed.

### Caching

**HTTP Cache**

The browser cache stores responses based on cache headers:

- `Cache-Control`: Primary directive (max-age, no-cache, no-store, private, public)
- `Expires`: Absolute expiration time (legacy, superseded by Cache-Control)
- `ETag`: Resource version identifier for conditional requests
- `Last-Modified`: Timestamp for conditional requests

**Cache Revalidation**

When cached content might be stale, the browser sends conditional requests:

- `If-None-Match: [ETag]`: Checks if resource changed
- `If-Modified-Since: [date]`: Checks modification time

The server responds with `304 Not Modified` if unchanged, or `200 OK` with new content.

**Cache Storage**

Browsers implement multiple cache types:

- **HTTP cache**: Disk-based storage for HTTP responses
- **Service Worker cache**: Programmable cache API
- **Memory cache**: Fast in-memory cache for current page session
- **Push cache**: Temporary storage for HTTP/2 server push

### Cookies and State Management

**Cookie Transmission**

The browser automatically includes cookies matching the request domain and path. Cookie attributes control behavior:

- `Domain`: Scope to domain and subdomains
- `Path`: URL path restriction
- `Secure`: HTTPS-only transmission
- `HttpOnly`: Blocks JavaScript access
- `SameSite`: Controls cross-site sending (Strict/Lax/None)
- `Max-Age`/`Expires`: Lifetime control

**Cookie Limits**

Browsers enforce limits per domain (typically 50-180 cookies, 4KB per cookie). Exceeding limits causes oldest cookies to be evicted.

### Request Credentials

**Credential Modes**

The `credentials` option in Fetch API controls cookie/auth inclusion:

- `omit`: Never send credentials
- `same-origin`: Send for same-origin only (default)
- `include`: Send for cross-origin (requires CORS approval)

**Authentication**

Browsers handle HTTP authentication (Basic, Digest) automatically, prompting users for credentials and caching them for the session. Modern applications typically use token-based auth (Bearer tokens in Authorization header) instead.

### Network Security

**Mixed Content Blocking**

HTTPS pages cannot load "active" mixed content (scripts, stylesheets, iframes, XHR) over HTTP. The browser blocks these requests to prevent MITM attacks. Passive content (images, video, audio) may trigger warnings but often loads.

**Certificate Transparency**

Browsers require Certificate Transparency logs for newly issued certificates. Sites must provide Signed Certificate Timestamps (SCTs) proving certificate logging, or the browser rejects the connection.

**HSTS (HTTP Strict Transport Security)**

The `Strict-Transport-Security` header forces HTTPS for future visits. Once received, the browser upgrades all HTTP requests to HTTPS for the specified max-age duration. HSTS preload lists allow sites to enforce HTTPS even on first visit.

### Resource Timing API

Browsers expose detailed network timing through `performance.getEntriesByType('navigation')` and `performance.getEntriesByType('resource')`:

- `domainLookupStart/End`: DNS resolution time
- `connectStart/End`: TCP connection time
- `secureConnectionStart`: TLS handshake start
- `requestStart`: Request sent to server
- `responseStart`: First byte received (TTFB)
- `responseEnd`: Response fully received
- `transferSize`: Bytes transferred (including headers)
- `encodedBodySize`: Compressed response size
- `decodedBodySize`: Uncompressed response size

### Service Workers and Network Interception

Service workers act as programmable network proxies. The `fetch` event allows intercepting all network requests from the page:

```javascript
self.addEventListener('fetch', (event) => {
  event.respondWith(
    // Return cached response, network response, or synthetic response
  );
});
```

This enables offline functionality, custom caching strategies, and response manipulation. Service workers intercept requests before they reach the HTTP cache.

### Network Throttling and Adaptability

**Network Information API**

The `navigator.connection` API exposes network conditions:

- `effectiveType`: Estimated connection type (4g, 3g, 2g, slow-2g)
- `downlink`: Estimated bandwidth in Mbps
- `rtt`: Estimated round-trip time
- `saveData`: User's data saver preference

Applications can adapt resource loading based on these signals.

### Protocol Negotiation

**ALPN (Application-Layer Protocol Negotiation)**

During TLS handshake, the browser advertises supported HTTP versions (h2, http/1.1, h3). The server selects the protocol, determining whether the connection uses HTTP/1.1, HTTP/2, or HTTP/3.

**Alt-Svc Header**

Servers can advertise alternative services through the `Alt-Svc` header, informing browsers that HTTP/3 is available on a specific UDP port. The browser can then upgrade to HTTP/3 for subsequent requests.

### Request Prioritization

HTTP/2 and HTTP/3 support priority signals:

- **Weight**: Relative importance (1-256)
- **Dependencies**: Parent-child relationships between streams
- **Exclusive flag**: Takes all parent's resources

[Inference] Browsers use internal heuristics to assign priorities based on resource type, timing, and visibility. The exact algorithms vary by browser and version.

### Network Error Handling

The browser generates errors for various failure conditions:

- `net::ERR_NAME_NOT_RESOLVED`: DNS failure
- `net::ERR_CONNECTION_REFUSED`: Server not accepting connections
- `net::ERR_CONNECTION_TIMED_OUT`: Connection timeout
- `net::ERR_CERT_AUTHORITY_INVALID`: Certificate validation failed
- `net::ERR_CERT_DATE_INVALID`: Certificate expired or not yet valid
- `net::ERR_SSL_PROTOCOL_ERROR`: TLS handshake failure

Applications receive these as promise rejections (Fetch API) or error events (XHR), typically without detailed error information for security reasons.

### Proxy Configuration

Browsers support multiple proxy protocols:

- **HTTP proxy**: Routes HTTP requests through proxy server
- **HTTPS proxy**: Tunnels TLS connections via CONNECT method
- **SOCKS proxy**: Protocol-agnostic proxy at lower network layer
- **PAC (Proxy Auto-Config)**: JavaScript file determining proxy per URL

System-level proxy settings typically apply browser-wide, though some browsers allow per-profile configuration.

---

