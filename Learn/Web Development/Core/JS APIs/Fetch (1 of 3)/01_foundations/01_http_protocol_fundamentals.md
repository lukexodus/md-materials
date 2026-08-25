## HTTP Protocol Fundamentals


### Request-Response Cycle

HTTP operates as a stateless, application-layer protocol where clients initiate requests and servers return responses. Each transaction is independent—the protocol itself retains no memory of previous exchanges. A complete cycle involves the client opening a TCP connection, sending an HTTP request, receiving the server's response, and typically closing the connection (though persistent connections modify this pattern).

### Request Structure

An HTTP request consists of three components: the request line, headers, and an optional body.

The request line contains the method (GET, POST, PUT, DELETE, etc.), the request target (typically a URI path), and the HTTP version. For example: `GET /api/users/123 HTTP/1.1`.

Headers provide metadata about the request. Common headers include `Host` (required in HTTP/1.1), `User-Agent`, `Accept` (content types the client can process), `Content-Type` (format of the request body), `Authorization` (credentials), and `Cookie` (session data). Headers follow a key-value format separated by colons.

The request body carries data for methods like POST, PUT, or PATCH. The body's format depends on the `Content-Type` header—common types include `application/json`, `application/x-www-form-urlencoded`, and `multipart/form-data`.

### Response Structure

HTTP responses mirror the request structure with a status line, headers, and optional body.

The status line includes the HTTP version, a three-digit status code, and a reason phrase. Example: `HTTP/1.1 200 OK`.

Status codes are grouped into five classes:

- **1xx (Informational)**: Interim responses, like `100 Continue`
- **2xx (Success)**: Request succeeded, such as `200 OK`, `201 Created`, `204 No Content`
- **3xx (Redirection)**: Further action needed, including `301 Moved Permanently`, `302 Found`, `304 Not Modified`
- **4xx (Client Error)**: Client-side problems, like `400 Bad Request`, `401 Unauthorized`, `403 Forbidden`, `404 Not Found`, `429 Too Many Requests`
- **5xx (Server Error)**: Server failures, such as `500 Internal Server Error`, `502 Bad Gateway`, `503 Service Unavailable`

Response headers convey metadata about the response. Key headers include `Content-Type`, `Content-Length`, `Cache-Control`, `Set-Cookie` (instructs client to store cookies), `Location` (redirect target), and `ETag` (resource version identifier).

### HTTP Methods

**GET** retrieves resources without side effects. It's idempotent—multiple identical requests produce the same result. GET requests should not include a body, though some servers may accept it.

**POST** submits data to create new resources or trigger processing. It's neither safe nor idempotent—repeated requests may create multiple resources.

**PUT** replaces a resource entirely or creates it at a specific URI. It's idempotent but not safe—sending the same PUT multiple times leaves the resource in the same state.

**PATCH** applies partial modifications. Unlike PUT, it doesn't require sending the complete resource representation.

**DELETE** removes resources. It's idempotent—deleting an already-deleted resource typically returns `404` or `204`.

**HEAD** behaves like GET but returns only headers, no body. Useful for checking resource metadata or existence without transferring content.

**OPTIONS** describes communication options for the target resource. Servers return allowed methods via the `Allow` header. CORS preflight requests use OPTIONS.

**CONNECT** establishes a tunnel, typically for SSL/TLS connections through proxies.

**TRACE** performs a message loop-back test along the path to the target resource. Often disabled for security reasons.

### Headers in Detail

**Request Headers:**

- `Accept-*` headers (`Accept`, `Accept-Language`, `Accept-Encoding`) inform the server of client capabilities
- `If-*` conditional headers (`If-Modified-Since`, `If-None-Match`) enable conditional requests
- `Range` requests partial content
- `Referer` indicates the previous page
- `Origin` identifies the request's origin for CORS

**Response Headers:**

- `Access-Control-*` headers manage CORS policies
- `Cache-Control` and `Expires` govern caching behavior
- `Content-Encoding` specifies compression (gzip, deflate, br)
- `Transfer-Encoding: chunked` indicates streaming responses
- `WWW-Authenticate` specifies authentication schemes after `401`

**General Headers:**

- `Connection` controls connection persistence (`keep-alive`, `close`)
- `Date` provides the message origination timestamp
- `Via` tracks proxies in the request/response chain

### Persistent Connections

HTTP/1.0 closed connections after each request. HTTP/1.1 introduced persistent connections (`Connection: keep-alive` is default), allowing multiple requests over a single TCP connection. This reduces latency from TCP handshakes and slow-start.

The `Keep-Alive` header can specify timeout and maximum requests: `Keep-Alive: timeout=5, max=100`.

### Content Negotiation

Servers select response representations based on client preferences expressed through `Accept` headers:

**Proactive negotiation**: Server chooses based on request headers **Reactive negotiation**: Server returns `300 Multiple Choices` or `406 Not Acceptable`, letting the client decide **Transparent negotiation**: Intermediary caches perform negotiation

The `Vary` header indicates which request headers affect the response representation, guiding cache behavior.

### Caching Mechanisms

HTTP caching reduces server load and improves response times. Cache behavior is controlled through several mechanisms:

**`Cache-Control` directives:**

- `public`: Any cache may store
- `private`: Only client caches, not shared proxies
- `no-cache`: Must revalidate with server before use
- `no-store`: Do not cache at all
- `max-age=<seconds>`: Resource freshness lifetime
- `must-revalidate`: Stale caches must validate before use
- `immutable`: Resource never changes during freshness period

**Validation:**

- `ETag` provides a resource version identifier; clients send `If-None-Match` to validate
- `Last-Modified` timestamp enables `If-Modified-Since` conditional requests
- Successful validation returns `304 Not Modified` with no body

**Heuristic caching**: When no explicit freshness information exists, caches may use heuristics (often 10% of the `Last-Modified` age).

### Cookies and State Management

Since HTTP is stateless, cookies provide session continuity. The server sends `Set-Cookie` headers, and clients return `Cookie` headers in subsequent requests.

**`Set-Cookie` attributes:**

- `Domain`: Scope of the cookie
- `Path`: URL path restriction
- `Expires` / `Max-Age`: Lifetime control
- `Secure`: HTTPS-only transmission
- `HttpOnly`: Prevents JavaScript access, mitigating XSS
- `SameSite`: Controls cross-site sending (`Strict`, `Lax`, `None`)

### Authentication

HTTP supports several authentication schemes communicated via `WWW-Authenticate` and `Authorization` headers:

**Basic Authentication**: Encodes credentials as Base64 (not encryption). Format: `Authorization: Basic <base64(username:password)>`. Should only be used over HTTPS.

**Digest Authentication**: Uses challenge-response with MD5 hashing, avoiding plaintext transmission.

**Bearer Token**: Common in OAuth 2.0. Format: `Authorization: Bearer <token>`.

### Content Encoding and Transfer Encoding

**Content-Encoding** compresses the body before transmission. Common values: `gzip`, `deflate`, `br` (Brotli). The client indicates support via `Accept-Encoding`, and the server responds with `Content-Encoding`.

**Transfer-Encoding** transforms the message itself. `Transfer-Encoding: chunked` sends data in chunks without knowing total size upfront. Each chunk includes its size in hexadecimal, followed by data, ending with a zero-size chunk.

### Range Requests

Clients request partial content using the `Range` header: `Range: bytes=0-1023`. Useful for resuming downloads or streaming.

The server responds with `206 Partial Content` and includes `Content-Range` specifying the delivered range: `Content-Range: bytes 0-1023/5000`.

If the server doesn't support ranges, it returns `200 OK` with the full resource. The `Accept-Ranges: bytes` header indicates range support.

### Redirects

Redirection status codes (3xx) instruct clients to fetch the resource from a different location, specified in the `Location` header.

**301 Moved Permanently**: Search engines update their indexes. Browsers may change POST to GET.

**302 Found**: Temporary redirect. Original URI should be used for future requests. Browsers may change POST to GET.

**303 See Other**: Explicitly instructs the client to use GET for the redirect, regardless of the original method.

**307 Temporary Redirect**: Guarantees the method and body are preserved in the redirected request.

**308 Permanent Redirect**: Like 301 but guarantees method preservation.

### CORS (Cross-Origin Resource Sharing)

CORS enables controlled cross-origin requests through headers:

**Simple requests** (GET, HEAD, POST with limited content types) include an `Origin` header. The server responds with `Access-Control-Allow-Origin` specifying allowed origins (`*` for any, or specific origins).

**Preflight requests** use OPTIONS for non-simple requests (custom headers, methods like PUT/DELETE, non-simple content types). The browser sends:

- `Access-Control-Request-Method`
- `Access-Control-Request-Headers`

The server responds with:

- `Access-Control-Allow-Methods`
- `Access-Control-Allow-Headers`
- `Access-Control-Max-Age` (cache duration for preflight results)

**Credentials**: `Access-Control-Allow-Credentials: true` permits cookies/auth. When true, `Access-Control-Allow-Origin` cannot be `*`.

### Connection Management

**HTTP/1.0**: One request per connection (unless `Connection: keep-alive` is negotiated).

**HTTP/1.1**: Persistent connections by default. Pipelining allows sending multiple requests without waiting for responses, though head-of-line blocking limits its effectiveness.

**Connection pooling**: Clients maintain multiple persistent connections to the same server to parallelize requests.

The `Connection: close` header signals that the connection will close after the response completes.

### HTTP Semantics

**Idempotency**: Methods (GET, PUT, DELETE, HEAD, OPTIONS, TRACE) that produce the same result regardless of repetition. POST and PATCH are not idempotent.

**Safety**: Methods (GET, HEAD, OPTIONS, TRACE) that don't modify server state. Safe methods are also idempotent.

**Cachability**: GET, HEAD, and POST responses may be cached (though POST caching is rare in practice). PUT, DELETE, PATCH typically aren't cached.

### Message Body Handling

The message body presence and length are determined by:

1. Responses to HEAD requests never include a body
2. `204 No Content` and `304 Not Modified` responses have no body
3. `Content-Length` header specifies the exact body size
4. `Transfer-Encoding: chunked` indicates variable-size body transmitted in chunks
5. Connection closure signals body end (HTTP/1.0 style, not reliable)

When both `Content-Length` and `Transfer-Encoding` are present, `Transfer-Encoding` takes precedence.

### URL Encoding

Special characters in URLs must be percent-encoded. Reserved characters (`?`, `&`, `=`, `/`, `#`, etc.) have special meaning. Unreserved characters (alphanumeric, `-`, `_`, `.`, `~`) don't require encoding.

Format: `%` followed by two hexadecimal digits representing the byte value. Space becomes `%20` (or `+` in query strings with `application/x-www-form-urlencoded`).

### Error Handling

Clients should handle various error scenarios:

**Network failures**: Connection timeouts, DNS resolution failures, unreachable hosts.

**HTTP errors**: Status codes indicate different failure types. 4xx errors suggest client-side issues (fix the request); 5xx errors indicate server problems (retry may help).

**Retries**: Idempotent methods (GET, PUT, DELETE) can be safely retried. Non-idempotent methods (POST) require careful consideration—duplicates may cause issues.

**Exponential backoff**: When retrying, progressively increase delay between attempts to avoid overwhelming servers.

---

