## Request Initialization Options


### Method Specification

The HTTP method defines the request's semantic intent and expected behavior. GET retrieves resources without side effects, supporting caching and idempotency. POST submits data for processing, typically creating resources or triggering operations with side effects. PUT replaces entire resources idempotently. PATCH applies partial modifications to resources. DELETE removes resources. HEAD retrieves headers without the body, useful for checking resource existence or metadata. OPTIONS queries supported methods and CORS policies. TRACE echoes the request for debugging. CONNECT establishes tunnels for proxying.

Method selection affects caching behavior, safety guarantees, and idempotency properties. Safe methods (GET, HEAD, OPTIONS) shouldn't modify server state. Idempotent methods (GET, PUT, DELETE, HEAD, OPTIONS) produce the same result when repeated.

### URL and Path Configuration

The target URL combines multiple components: protocol scheme (http, https), hostname or IP address, optional port number (defaults: 80 for HTTP, 443 for HTTPS), path identifying the resource, query string containing key-value parameters, and fragment identifier for client-side navigation.

Query parameters encode data in the URL using `key=value` pairs separated by ampersands. Special characters require percent-encoding (URL encoding) where spaces become `%20` or `+`, and reserved characters get escaped. Multiple values for the same key can be represented as `key=value1&key=value2` or `key[]=value1&key[]=value2` depending on server parsing conventions.

Path parameters embed values directly in the URL structure (`/users/123/posts/456`) rather than query strings, typically representing resource identifiers in RESTful designs. This pattern creates cleaner URLs and clearer hierarchical relationships between resources.

Base URLs can be configured separately from relative paths, enabling environment-specific configuration where the same path logic works across development, staging, and production endpoints by swapping base URLs.

### Headers Configuration

Headers provide metadata controlling request processing and client capabilities. Each header consists of a case-insensitive name and a value, with multiple values separated by commas or multiple header instances with the same name.

**Content negotiation headers** inform the server about acceptable response formats. Accept specifies media types (`application/json`, `text/html`, `*/*`) with optional quality values (`q=0.8`) indicating preference. Accept-Language prioritizes human languages. Accept-Encoding lists supported compression algorithms (gzip, deflate, br, identity). Accept-Charset specifies character encoding preferences.

**Authentication headers** carry credentials. Authorization contains tokens in various schemes: `Bearer <token>` for JWT and OAuth tokens, `Basic <base64(username:password)>` for basic authentication, `Digest` for digest authentication, or custom schemes. API keys may travel in Authorization, custom headers (`X-API-Key`), or query parameters (less secure).

**Content description headers** characterize request bodies. Content-Type specifies the media type and optional charset (`application/json; charset=utf-8`, `multipart/form-data; boundary=----WebKitFormBoundary`, `application/x-www-form-urlencoded`). Content-Length indicates body size in bytes. Content-Encoding specifies compression applied to the body. Content-Language indicates the body's natural language.

**Caching and validation headers** control cache behavior. Cache-Control directives like `no-cache`, `no-store`, `max-age=3600`, or `must-revalidate` specify caching policy. If-Modified-Since and If-None-Match enable conditional requests using timestamps or ETags respectively. If-Match and If-Unmodified-Since support optimistic concurrency control.

**Connection management headers** control the underlying TCP connection. Connection: keep-alive maintains persistent connections, while Connection: close forces closure after the response. Keep-Alive specifies timeout and maximum request parameters.

**CORS-related headers** enable cross-origin requests. Origin identifies the requesting origin. Access-Control-Request-Method and Access-Control-Request-Headers appear in preflight OPTIONS requests to query allowed methods and headers.

**Custom headers** extend functionality beyond standard headers. Common conventions prefix custom headers with `X-` (though this convention is deprecated) or use vendor-specific prefixes. Examples include `X-Request-ID` for distributed tracing, `X-Forwarded-For` preserving original client IPs through proxies, and `X-CSRF-Token` for CSRF protection.

### Body Content and Encoding

Request bodies carry payload data for methods like POST, PUT, and PATCH. Body format must match the Content-Type header's media type.

**JSON bodies** (`application/json`) serialize structured data as JSON strings. Objects, arrays, and primitive values nest arbitrarily. JSON's text-based format makes it human-readable and language-agnostic, though larger than binary formats. Unicode characters require proper encoding in UTF-8.

**Form-encoded bodies** (`application/x-www-form-urlencoded`) encode key-value pairs similarly to query strings: `key1=value1&key2=value2`. Special characters are percent-encoded. This format handles simple flat data structures but struggles with nested objects or arrays.

**Multipart bodies** (`multipart/form-data`) enable file uploads and mixed content types within a single request. Each part has its own headers and content, separated by boundary strings declared in the Content-Type header. Parts can contain text fields, binary files, or nested multipart structures. Each part specifies Content-Disposition with field name and optional filename, plus Content-Type for the part's media type.

**Binary bodies** (`application/octet-stream`) transmit raw bytes without additional encoding, used for file uploads where the entire body represents a single file. Content-Length becomes critical for determining where the body ends.

**XML bodies** (`application/xml` or `text/xml`) structure data hierarchically using markup tags. While JSON has largely supplanted XML in modern APIs, XML remains common in SOAP services, configuration files, and legacy systems.

**Plain text bodies** (`text/plain`) send unstructured text data. The charset parameter specifies character encoding (typically UTF-8).

**Streaming bodies** transmit data incrementally rather than buffering the entire payload. Chunked transfer encoding (`Transfer-Encoding: chunked`) sends variable-sized chunks, each prefixed with its size in hexadecimal. This enables transmitting bodies of unknown length, useful for real-time data, large file uploads, or generated content.

### Timeout Configuration

Timeout settings balance responsiveness against allowing time for legitimate slow operations. Multiple timeout types control different phases of the request lifecycle.

**Connection timeout** limits the time to establish a TCP connection with the server. This includes DNS resolution, TCP handshake, and for HTTPS, TLS negotiation. Typical values range from 5-30 seconds. Short timeouts fail fast on unreachable or overloaded servers, while longer timeouts accommodate slow networks or distant servers.

**Read/receive timeout** constrains the time between receiving successive bytes of the response. This prevents indefinite blocking on stalled connections where the server stops sending data mid-response. The timeout resets each time data arrives, so responses can exceed the timeout as long as data flows continuously. Values typically range from 30-120 seconds depending on expected response complexity.

**Write/send timeout** limits the time between sending successive bytes of the request body. Relevant primarily for large request bodies, this prevents hanging on slow or unresponsive servers. Similar to read timeout, it resets when progress occurs.

**Overall/total timeout** caps the entire request/response cycle duration from initiation through completion. This provides an absolute upper bound regardless of progress, preventing requests from consuming resources indefinitely even if making intermittent progress. Must exceed the sum of connection and transfer times for legitimate requests.

### Redirect Handling

HTTP redirects (3xx status codes) instruct clients to retrieve the resource from a different location. Redirect handling options control automatic following behavior.

**Automatic redirect following** transparently follows redirects up to a maximum depth (typically 5-20 redirects) to prevent infinite loops. The client makes additional requests to the locations specified in Location headers until receiving a non-redirect response or hitting the limit.

**Method preservation** determines whether redirects maintain the original HTTP method. [Inference: Historically, many clients changed POST to GET when following redirects, though modern standards specify method preservation for 307 and 308 status codes specifically.] 301 (Moved Permanently) and 302 (Found) often cause clients to switch POST/PUT requests to GET. 303 (See Other) explicitly instructs changing to GET. 307 (Temporary Redirect) and 308 (Permanent Redirect) require preserving the method and body.

**Redirect policies** can be configured as: always follow (default for most clients), never follow (useful for testing or scraping), follow same-origin only (security measure preventing redirect-based attacks), or follow with custom logic (examining status codes and locations before deciding).

**Referrer handling** during redirects determines what Referrer header gets sent in subsequent requests. Options include omitting referrer for security, preserving the original request URL, or using the intermediate redirect URL.

### Retry Logic

Network unreliability and transient server errors necessitate retry mechanisms for resilient applications. Retry configuration balances reliability against avoiding overloading struggling services.

**Retry conditions** specify which failures trigger retries: network errors (connection refused, timeout, DNS failure), specific HTTP status codes (408 Request Timeout, 429 Too Many Requests, 500 Internal Server Error, 502 Bad Gateway, 503 Service Unavailable, 504 Gateway Timeout), or custom logic examining response characteristics. Safe, idempotent methods (GET, HEAD, PUT, DELETE) can be retried safely, while POST requires careful consideration of side effects.

**Retry strategies** include immediate retry (rarely appropriate), fixed delay (constant interval between attempts), exponential backoff (doubling delay after each failure), and exponential backoff with jitter (adding randomness to prevent thundering herd). Example progression: 1s, 2s, 4s, 8s with jitter might become 1.2s, 2.4s, 3.9s, 8.1s.

**Maximum retry attempts** limit total tries (typically 3-5) before giving up and propagating the failure upstream. Combined with timeout settings, this bounds total time spent on failed requests.

**Backoff multipliers and maximum delay** configure exponential backoff behavior. Multiplier (commonly 2) determines growth rate, while maximum delay caps the interval (e.g., 60 seconds) preventing excessively long waits.

### Authentication and Authorization

Authentication mechanisms verify client identity, while authorization determines permitted actions. Configuration options enable various schemes.

**Token-based authentication** includes bearer tokens in the Authorization header. OAuth 2.0 access tokens grant limited access based on scopes. JWT (JSON Web Tokens) encode claims and signatures enabling stateless verification. API keys identify applications or services. Tokens may require refresh when expired, either automatically (refresh token flow) or through re-authentication.

**Basic authentication** encodes username and password as base64 in the Authorization header. Despite simplicity, it's inherently insecure without HTTPS since credentials are easily decoded. Used primarily for internal services or when simpler mechanisms suffice.

**Digest authentication** improves on basic auth by hashing credentials with nonces, preventing credential exposure even without HTTPS. However, complexity and better alternatives (HTTPS + bearer tokens) have made it uncommon.

**Certificate-based authentication** (mutual TLS) requires clients to present X.509 certificates during TLS handshake, cryptographically proving identity. Used in high-security environments, service-to-service communication, and IoT devices.

**Session-based authentication** relies on cookies containing session IDs. The initial login establishes the session, with subsequent requests including the session cookie automatically. Cookie options (SameSite, Secure, HttpOnly) control transmission and security properties.

### CORS Configuration

Cross-Origin Resource Sharing (CORS) enables browsers to make requests across origins (different protocol, domain, or port). Client-side JavaScript triggers CORS policies, while servers control permissions through response headers.

**Simple requests** (GET, HEAD, POST with limited content types and headers) proceed directly. The browser includes an Origin header, and the server responds with Access-Control-Allow-Origin specifying allowed origins or `*` for public APIs.

**Preflight requests** occur for non-simple requests. The browser sends an OPTIONS request with Access-Control-Request-Method and Access-Control-Request-Headers describing the intended request. The server responds with allowed methods, headers, origins, and whether credentials are permitted. The browser then sends the actual request if permitted, or blocks it otherwise.

**Credentials in cross-origin requests** (cookies, authorization headers) require explicit opt-in via the `credentials` option (omit, same-origin, include) on the client and Access-Control-Allow-Credentials: true from the server. When allowing credentials, Access-Control-Allow-Origin cannot be `*` but must specify exact origins.

### Request Signing

Request signing cryptographically authenticates requests, proving the sender possesses a secret key without transmitting the key itself. This prevents tampering and replay attacks.

**HMAC-based signing** computes a hash of the request components (method, path, headers, body) using a shared secret key. The signature travels in a custom header or as part of the Authorization header. The server recomputes the signature using its copy of the secret key and compares signatures to validate authenticity.

**Signature components** typically include: timestamp (preventing replay), nonce (unique per request), HTTP method, request path and query parameters, selected headers (especially Content-Type and Content-Length), and body content or body hash. Including timestamps requires clock synchronization between client and server.

**AWS Signature Version 4** exemplifies production signing schemes. It creates a canonical request string, computes a string-to-sign including scope and timestamp, derives signing keys from secret key and date, and produces an HMAC-SHA256 signature. The Authorization header contains the algorithm, credentials, signed headers, and signature.

### Compression

Compression reduces transmitted data size at the cost of CPU cycles for encoding/decoding. Configuration determines which content gets compressed and using which algorithms.

**Request body compression** requires setting Content-Encoding to indicate the algorithm (gzip, deflate, br for Brotli). Servers must support the specified encoding to decompress the body. [Inference: Not all servers accept compressed request bodies, so this option may cause failures with incompatible servers.]

**Response compression acceptance** uses the Accept-Encoding header listing supported algorithms with optional quality values. The server chooses an encoding or sends uncompressed content. The response's Content-Encoding header indicates which algorithm was used, if any.

**Compression algorithms** differ in trade-offs. Gzip provides good compression and universal support. Brotli achieves better compression ratios but requires more CPU and has less universal support. Deflate is older and less efficient than gzip.

### Proxying

Proxy configuration routes requests through intermediary servers for various purposes: anonymity, caching, authentication, traffic filtering, or bypassing network restrictions.

**HTTP proxies** forward HTTP requests to the target server. The client sends the full URL (absolute URI form) in the request line to the proxy, which then makes the request to the origin server. The proxy may modify headers, add authentication, or cache responses.

**HTTPS proxies** use the CONNECT method to establish a tunnel through the proxy to the target server. The proxy forwards TCP bytes without inspecting encrypted content, maintaining end-to-end encryption between client and origin server.

**Proxy authentication** requires credentials to use the proxy service, separate from authentication with the origin server. Proxy-Authorization header carries credentials, and 407 Proxy Authentication Required responses indicate missing or invalid proxy credentials.

**No-proxy lists** specify hostnames or patterns that should bypass the proxy. Common entries include localhost, local IP ranges (127.0.0.0/8, 10.0.0.0/8), and internal domain names. This prevents routing internal traffic through external proxies.

### Priority and Scheduling

HTTP/2 and HTTP/3 enable request prioritization, allowing clients to indicate relative importance when multiplexing multiple requests over a single connection.

**Request priority** assigns weights and dependencies. Higher-priority requests receive more bandwidth share when resources are constrained. Dependencies create parent-child relationships where child streams should be processed only after parents complete. [Inference: Actual prioritization behavior depends on server implementation—not all servers respect client priority hints equally.]

**Weight values** range from 1-256, with higher values indicating greater importance relative to siblings at the same priority level. Servers distribute resources proportionally to weights among competing streams.

### Integrity and Validation

Request options can enforce integrity constraints ensuring responses match expected characteristics.

**Subresource Integrity (SRI)** for fetched resources specifies expected cryptographic hashes. The client computes the hash of received content and rejects responses not matching the expected hash, preventing compromised CDNs or man-in-the-middle attacks from serving malicious content. Hashes use algorithms like SHA-256, SHA-384, or SHA-512.

**Content validation options** can enforce expected Content-Type, Content-Length ranges, or custom validation logic examining response characteristics before accepting the response.

### Metadata and Tracking

Additional options attach metadata for logging, monitoring, and distributed tracing without affecting request semantics.

**Request IDs** uniquely identify each request for correlation across logs, traces, and monitoring systems. Generated by the client or intermediary proxies, these IDs (UUID or similar) travel in custom headers like X-Request-ID and propagate through service chains.

**Tracing context** for distributed tracing includes trace ID (identifying the overall transaction), span ID (identifying this request's work), parent span ID (linking to the calling service), and sampling flags (controlling trace retention). Headers follow standards like W3C Trace Context or vendor-specific formats (X-B3-TraceId, etc.).

**Tags and labels** attach arbitrary key-value metadata useful for monitoring dashboards, alerting rules, or analytics. These typically don't travel in the HTTP request but are associated with client-side metrics and logs.

### Cancellation

Request cancellation aborts in-flight requests, freeing client and server resources when the response is no longer needed. Useful when users navigate away, search queries update, or timeouts expire.

**Abort signals** provide a standardized cancellation mechanism. An AbortController creates an AbortSignal that can be passed to fetch requests. Calling abort() on the controller triggers cancellation, causing the request to reject with an abort error. [Inference: Server-side cancellation depends on implementation—closing the TCP connection may not immediately stop server processing if the request was already queued or executing.]

**Cleanup behavior** determines what happens when cancellation occurs: immediate connection closure, allowing in-flight writes to complete, or waiting for critical sections to finish. Client libraries handle cleanup automatically, but application code must handle abort errors appropriately.

---

