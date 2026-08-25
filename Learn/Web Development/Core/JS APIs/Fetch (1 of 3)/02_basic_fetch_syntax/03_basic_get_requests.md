## Basic GET Requests


### Request Structure

A GET request consists of a request line, headers, and an empty body. The request line contains the method (GET), the target URI, and the HTTP version.

```
GET /api/users/123 HTTP/1.1
Host: api.example.com
User-Agent: Mozilla/5.0
Accept: application/json
```

The URI may include a path, query parameters, and fragment identifier. Query parameters follow the `?` delimiter and use `&` to separate multiple parameters.

```
GET /search?q=javascript&category=tutorials&page=2 HTTP/1.1
```

### Query Parameters

Query parameters encode data in the URL using key-value pairs. Special characters require percent-encoding (URL encoding) to maintain URI validity.

```
/search?name=John%20Doe&email=user%40example.com
```

Common encoding rules:

- Space: `%20` or `+`
- `@`: `%40`
- `#`: `%23`
- `&`: `%26`
- `=`: `%3D`

### Headers

Request headers provide metadata about the request, client capabilities, and authentication credentials.

**Common GET request headers:**

- `Host`: Target server domain (required in HTTP/1.1)
- `Accept`: Media types the client can process
- `Accept-Language`: Preferred response language
- `Accept-Encoding`: Supported compression methods (gzip, deflate, br)
- `User-Agent`: Client application identifier
- `Authorization`: Authentication credentials
- `Cookie`: Stored cookies for the domain
- `Cache-Control`: Caching directives
- `If-None-Match`: ETag for conditional requests
- `If-Modified-Since`: Timestamp for conditional requests
- `Referer`: Previous page URL
- `Connection`: Connection management (keep-alive, close)

### Response Structure

The server responds with a status line, headers, and optional body content.

```
HTTP/1.1 200 OK
Content-Type: application/json
Content-Length: 157
Cache-Control: max-age=3600
ETag: "33a64df551425fcc55e4d42a148795d9f25f89d4"

{"id": 123, "name": "John Doe", "email": "john@example.com"}
```

### Status Codes for GET Requests

**2xx Success:**

- `200 OK`: Request succeeded, response body contains requested resource
- `204 No Content`: Request succeeded, no response body

**3xx Redirection:**

- `301 Moved Permanently`: Resource permanently relocated
- `302 Found`: Resource temporarily relocated
- `304 Not Modified`: Cached version is still valid

**4xx Client Errors:**

- `400 Bad Request`: Malformed syntax or invalid parameters
- `401 Unauthorized`: Authentication required
- `403 Forbidden`: Access denied despite authentication
- `404 Not Found`: Resource does not exist
- `405 Method Not Allowed`: GET not supported for this resource
- `429 Too Many Requests`: Rate limit exceeded

**5xx Server Errors:**

- `500 Internal Server Error`: Unhandled server exception
- `502 Bad Gateway`: Invalid response from upstream server
- `503 Service Unavailable`: Server temporarily cannot handle request
- `504 Gateway Timeout`: Upstream server timeout

### Idempotency and Safety

GET requests are both safe and idempotent:

- **Safe**: The request does not modify server state
- **Idempotent**: Multiple identical requests produce the same result

[Inference] This design principle guides caching strategies and retry logic, though actual implementation depends on server-side code respecting REST conventions.

### Caching Behavior

GET responses are cacheable by default. Servers control caching through headers:

```
Cache-Control: public, max-age=3600
Cache-Control: private, no-cache
Cache-Control: no-store
```

**Conditional requests** reduce bandwidth by validating cached content:

```
GET /api/users/123 HTTP/1.1
If-None-Match: "33a64df551425fcc55e4d42a148795d9f25f89d4"
```

If content hasn't changed, the server responds with `304 Not Modified` without a body.

### Content Negotiation

Clients specify preferred response formats through `Accept` headers:

```
Accept: application/json
Accept: text/html, application/xml;q=0.9, */*;q=0.8
```

Quality values (q) indicate preference order. Servers respond with `Content-Type` indicating the actual format:

```
Content-Type: application/json; charset=utf-8
```

If the server cannot provide an acceptable format, it responds with `406 Not Acceptable`.

### Query String Length Limits

While HTTP specification doesn't define maximum URL length, practical limits exist:

- Most browsers: 2,000+ characters
- Web servers: Varies (Apache: 8,190 bytes default, Nginx: 4,096-8,192 bytes)
- Proxies and CDNs: May impose stricter limits

[Inference] For large datasets, POST requests with body content become preferable, though this represents a design choice rather than a protocol requirement.

### CORS Preflight

Cross-origin GET requests with custom headers trigger preflight OPTIONS requests:

```
OPTIONS /api/users HTTP/1.1
Origin: https://example.com
Access-Control-Request-Method: GET
Access-Control-Request-Headers: X-Custom-Header
```

Simple GET requests (standard headers only) proceed without preflight.

### Authentication Patterns

**Bearer Token:**

```
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**Basic Authentication:**

```
Authorization: Basic dXNlcm5hbWU6cGFzc3dvcmQ=
```

**API Key:**

```
X-API-Key: abc123def456
```

Or via query parameter:

```
GET /api/users?api_key=abc123def456
```

### Connection Management

HTTP/1.1 uses persistent connections by default:

```
Connection: keep-alive
Keep-Alive: timeout=5, max=100
```

The connection remains open for subsequent requests, reducing TCP handshake overhead.

HTTP/2 multiplexes multiple requests over a single connection, eliminating the need for explicit connection management headers.

### Compression

Clients indicate compression support:

```
Accept-Encoding: gzip, deflate, br
```

Servers compress response bodies when beneficial:

```
Content-Encoding: gzip
Content-Length: 1247
```

The `Content-Length` reflects compressed size. Clients decompress transparently.

### Range Requests

Clients request partial content using byte ranges:

```
GET /video.mp4 HTTP/1.1
Range: bytes=0-1023
```

Server responds with `206 Partial Content`:

```
HTTP/1.1 206 Partial Content
Content-Range: bytes 0-1023/5000000
Content-Length: 1024
```

This enables resumable downloads and streaming media.

### Performance Considerations

**DNS Resolution**: Domain lookup adds latency; DNS caching reduces subsequent requests.

**TCP Handshake**: Three-way handshake adds round-trip time; connection reuse mitigates this.

**TLS Negotiation**: HTTPS adds cryptographic handshake; session resumption reduces overhead.

**Server Processing**: Backend queries, database access, and business logic execution time.

**Network Latency**: Physical distance between client and server affects transfer time.

**Response Size**: Larger payloads increase transfer time; compression and pagination help.

### Error Handling Patterns

Clients should implement retry logic with exponential backoff for transient failures (5xx errors, timeouts). Permanent failures (4xx errors except 429) should not retry.

```javascript
// Example pattern (not production code)
async function getWithRetry(url, maxRetries = 3) {
  for (let i = 0; i < maxRetries; i++) {
    try {
      const response = await fetch(url);
      if (response.ok) return response;
      if (response.status >= 400 && response.status < 500) {
        throw new Error('Client error');
      }
      // Retry on 5xx
      await sleep(Math.pow(2, i) * 1000);
    } catch (error) {
      if (i === maxRetries - 1) throw error;
    }
  }
}
```

[Unverified] Specific retry strategies depend on application requirements and server tolerance for repeated requests.

---

