## Headers in REST APIs


### Core HTTP Headers

**Content-Type** Specifies the media type of the request or response body. Informs the recipient how to parse and interpret the payload.

Request example:

```
POST /users
Content-Type: application/json

{"name": "Alice", "email": "alice@example.com"}
```

Response example:

```
HTTP/1.1 200 OK
Content-Type: application/json; charset=utf-8

{"id": 123, "name": "Alice"}
```

Common values:

- `application/json` - JSON data (most common in REST APIs)
- `application/xml` - XML data
- `text/html` - HTML documents
- `text/plain` - Plain text
- `application/x-www-form-urlencoded` - Form data
- `multipart/form-data` - File uploads with form data
- `application/octet-stream` - Binary data
- `image/jpeg`, `image/png`, `video/mp4` - Media files

The charset parameter specifies character encoding, typically UTF-8.

**Content-Length** Indicates the size of the request or response body in bytes.

```
POST /upload
Content-Type: application/octet-stream
Content-Length: 2048576

[binary data]
```

Servers and clients use Content-Length to:

- Allocate appropriate buffers
- Detect incomplete transmissions
- Display upload/download progress
- Validate payload completeness

HTTP/1.1 requires Content-Length for messages with bodies unless using chunked transfer encoding.

**Accept** Clients specify acceptable response media types. Servers select the best match or return 406 Not Acceptable if unable to satisfy.

```
GET /users/123
Accept: application/json, application/xml;q=0.9, */*;q=0.8
```

Quality values (q parameter) range from 0 to 1:

- 1.0 (default when omitted): Highest preference
- 0.9: Slightly less preferred
- 0.1: Minimally acceptable
- 0: Not acceptable (equivalent to omitting)

Servers examine Accept headers and respond with the best matching format:

```
HTTP/1.1 200 OK
Content-Type: application/json

{"id": 123, "name": "Alice"}
```

**Accept-Language** Specifies preferred natural languages for the response.

```
GET /articles/456
Accept-Language: en-US, en;q=0.9, es;q=0.8
```

Prefers US English, then any English, then Spanish. Servers return content in the best available language:

```
HTTP/1.1 200 OK
Content-Language: en-US

{"title": "Getting Started", "content": "..."}
```

**Accept-Encoding** Indicates acceptable content compression algorithms.

```
GET /large-dataset
Accept-Encoding: gzip, deflate, br
```

- `gzip`: Common, well-supported compression
- `deflate`: Less common compression
- `br` (Brotli): Modern, efficient compression
- `identity`: No compression (often implicit)

Servers compress responses when appropriate:

```
HTTP/1.1 200 OK
Content-Encoding: gzip
Content-Type: application/json
Content-Length: 1247

[compressed data]
```

Compression reduces bandwidth significantly for text-based formats. JSON, XML, and HTML often compress to 10-20% of original size.

**Accept-Charset** Specifies acceptable character encodings. Declining in relevance as UTF-8 becomes universal.

```
Accept-Charset: utf-8, iso-8859-1;q=0.7
```

Most modern APIs assume UTF-8 and ignore this header.

### Authentication and Authorization Headers

**Authorization** Carries credentials for authenticating the client to the server.

**Bearer Token Authentication:**

```
GET /protected/resource
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIn0.dozjgNryP4J3jVmNHl0w5N_XgL0n3I9PlFUP0THsR8U
```

Most common for API authentication. Tokens may be opaque identifiers or self-contained JWTs.

**Basic Authentication:**

```
GET /api/data
Authorization: Basic dXNlcm5hbWU6cGFzc3dvcmQ=
```

Base64-encoded `username:password`. Simple but requires HTTPS—encoding is not encryption.

**API Key Authentication:**

```
GET /api/data
Authorization: ApiKey sk_live_abc123def456
```

Custom schemes vary by implementation. Some APIs use `Authorization: Bearer` for API keys.

**Digest Authentication:**

```
Authorization: Digest username="user", realm="api@example.com", nonce="dcd98b7102dd2f0e8b11d0f600bfb0c093", uri="/api/data", response="6629fae49393a05397450978507c4ef1"
```

More secure than Basic but complex. Rarely used in modern APIs.

**Custom API Key Headers:** Some APIs use custom headers instead of Authorization:

```
GET /api/data
X-API-Key: sk_live_abc123def456
API-Key: sk_live_abc123def456
```

Custom headers are less standard but sometimes preferred for specific use cases.

**WWW-Authenticate** Servers use this to challenge clients for authentication when Authorization is missing or invalid:

```
GET /protected/resource

HTTP/1.1 401 Unauthorized
WWW-Authenticate: Bearer realm="api", error="invalid_token", error_description="Token expired"
```

Indicates authentication scheme and required parameters. Clients respond with appropriate Authorization header.

**Proxy-Authorization and Proxy-Authenticate** Similar to Authorization/WWW-Authenticate but for proxy server authentication:

```
GET /api/data
Proxy-Authorization: Basic cHJveHl1c2VyOnBhc3M=
```

Used when requests pass through authenticating proxies.

### Caching Headers

**Cache-Control** Primary mechanism for controlling caching behavior in requests and responses.

**Response directives:**

```
Cache-Control: public, max-age=3600, must-revalidate
```

- `public`: Any cache (browser, CDN, proxy) can store the response
- `private`: Only client-specific caches (browser) can store, not shared caches
- `no-cache`: Must revalidate with origin server before using cached copy
- `no-store`: Must not store the response anywhere, even temporarily
- `max-age=seconds`: Response is fresh for specified duration
- `s-maxage=seconds`: Like max-age but only for shared caches (CDN, proxies)
- `must-revalidate`: Stale responses must not be served without revalidation
- `proxy-revalidate`: Like must-revalidate but only for shared caches
- `immutable`: Response will never change during freshness lifetime
- `no-transform`: Intermediaries must not modify the response

**Request directives:**

```
GET /api/data
Cache-Control: no-cache, no-store
```

- `no-cache`: Client wants fresh response, not cached copy
- `no-store`: Client demands no caching anywhere
- `max-age=seconds`: Client accepts cached responses up to this age
- `max-stale=seconds`: Client accepts stale responses within this staleness period
- `min-fresh=seconds`: Client wants responses fresh for at least this duration
- `only-if-cached`: Client wants cached responses only, no network request

**Combining directives:**

```
Cache-Control: public, max-age=86400, s-maxage=31536000, immutable
```

Browser caches for 24 hours, CDNs cache for 1 year, response never changes.

**ETag** Entity tag uniquely identifies a specific version of a resource. Enables efficient caching and concurrency control.

**Strong ETag:**

```
ETag: "33a64df551425fcc55e4d42a148795d9f25f89d4"
```

Byte-for-byte identical resources have identical strong ETags. Any change produces a different ETag.

**Weak ETag:**

```
ETag: W/"0815"
```

Prefix `W/` indicates semantic equivalence rather than byte-identical. Minor changes (formatting, whitespace, comments) don't change weak ETags.

**Conditional requests with ETags:**

Client retrieves resource:

```
GET /api/users/123

HTTP/1.1 200 OK
ETag: "v42"
Cache-Control: max-age=300

{"id": 123, "name": "Alice"}
```

Later, client validates cache:

```
GET /api/users/123
If-None-Match: "v42"

HTTP/1.1 304 Not Modified
ETag: "v42"
Cache-Control: max-age=300
```

No body returned—client uses cached copy.

If resource changed:

```
GET /api/users/123
If-None-Match: "v42"

HTTP/1.1 200 OK
ETag: "v43"

{"id": 123, "name": "Alice Updated"}
```

**If-Match (Precondition for Updates):**

```
PUT /api/users/123
If-Match: "v42"
Content-Type: application/json

{"id": 123, "name": "Alice Modified"}
```

Succeeds only if current ETag is "v42":

```
HTTP/1.1 200 OK
ETag: "v43"

{"id": 123, "name": "Alice Modified", "updated_at": "2024-12-16T12:00:00Z"}
```

If resource changed (different ETag):

```
HTTP/1.1 412 Precondition Failed
ETag: "v43"

{"error": "Resource was modified by another client"}
```

**If-None-Match (Conditional GET and PUT):** For GET, returns 304 if ETag matches (described above).

For PUT, creates only if resource doesn't exist:

```
PUT /api/users/456
If-None-Match: *
Content-Type: application/json

{"name": "Bob"}

HTTP/1.1 201 Created
Location: /api/users/456
ETag: "v1"
```

If resource exists:

```
HTTP/1.1 412 Precondition Failed
ETag: "v5"

{"error": "Resource already exists"}
```

**Last-Modified and If-Modified-Since** Timestamp-based alternative to ETags.

```
GET /api/articles/789

HTTP/1.1 200 OK
Last-Modified: Wed, 15 Dec 2024 10:00:00 GMT
Cache-Control: max-age=3600

{"title": "Article Title", "content": "..."}
```

Conditional request:

```
GET /api/articles/789
If-Modified-Since: Wed, 15 Dec 2024 10:00:00 GMT

HTTP/1.1 304 Not Modified
Last-Modified: Wed, 15 Dec 2024 10:00:00 GMT
```

**If-Unmodified-Since:** Update only if not modified since specified time:

```
PUT /api/articles/789
If-Unmodified-Since: Wed, 15 Dec 2024 10:00:00 GMT
Content-Type: application/json

{"title": "Updated Title"}

HTTP/1.1 412 Precondition Failed
Last-Modified: Wed, 15 Dec 2024 11:30:00 GMT
```

**Expires** Legacy caching mechanism specifying absolute expiration time.

```
Expires: Thu, 16 Dec 2025 12:00:00 GMT
```

Cache-Control max-age takes precedence when both are present. Expires remains for HTTP/1.0 compatibility.

**Vary** Indicates which request headers affect the response content. Caches must store separate entries for different values of these headers.

```
HTTP/1.1 200 OK
Content-Type: application/json
Vary: Accept-Encoding, Accept-Language

{"message": "Hello"}
```

Cache stores separate entries for different combinations of Accept-Encoding and Accept-Language values.

Without Vary, caches might serve gzipped content to clients that don't support compression, or English content to clients requesting Spanish.

**Age** Indicates how long the response has been in cache (in seconds).

```
HTTP/1.1 200 OK
Cache-Control: max-age=3600
Age: 1200

{"data": "cached content"}
```

Response is 1200 seconds old, fresh for another 2400 seconds (3600 - 1200).

### Request Context Headers

**User-Agent** Identifies the client making the request—browser, mobile app, bot, or custom application.

```
GET /api/data
User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36
```

Servers use User-Agent to:

- Provide client-appropriate responses
- Track API usage by client type
- Block malicious bots
- Gather analytics

APIs should document expected User-Agent format for custom clients:

```
User-Agent: MyApp/2.1.0 (iOS 15.0)
User-Agent: MyCompany-Bot/1.0 (+https://example.com/bot-info)
```

**Referer** Indicates the URL of the page that linked to the current request.

```
GET /api/widget-data
Referer: https://example.com/dashboard
```

Note the misspelling (should be "Referrer") persists in HTTP specifications.

Servers use Referer for:

- Analytics and tracking referral sources
- Security checks (validating requests come from expected origins)
- CSRF protection (though inadequate alone)

Privacy concerns and browser policies increasingly restrict or omit Referer. Never rely solely on Referer for security decisions.

**Referrer-Policy** Controls how much referrer information is included in requests:

```
Referrer-Policy: no-referrer
Referrer-Policy: origin
Referrer-Policy: strict-origin-when-cross-origin
```

- `no-referrer`: Never send Referer header
- `origin`: Send only origin (scheme, host, port), not full URL
- `same-origin`: Send full URL for same-origin, omit for cross-origin
- `strict-origin-when-cross-origin`: Full URL for same-origin, only origin for cross-origin HTTPS, nothing for HTTPS→HTTP

**Host** Specifies the host and port of the target server. Required in HTTP/1.1.

```
GET /api/users
Host: api.example.com
```

Enables virtual hosting—multiple domains on single IP address. Servers use Host to route requests to appropriate applications.

HTTP/2 uses the `:authority` pseudo-header instead of Host.

**Origin** Indicates the origin (scheme, host, port) of the request. Critical for CORS.

```
POST /api/data
Origin: https://app.example.com
Content-Type: application/json

{"key": "value"}
```

Browsers automatically include Origin for cross-origin requests. Servers check Origin against allowlists and respond with appropriate CORS headers.

### Response Context Headers

**Location** Provides the URI of a resource, used in several contexts:

**Resource creation (201 Created):**

```
POST /users

HTTP/1.1 201 Created
Location: /users/789
Content-Type: application/json

{"id": 789, "name": "Charlie"}
```

**Redirection (3xx status codes):**

```
GET /old-path

HTTP/1.1 301 Moved Permanently
Location: /new-path
```

**Asynchronous operation status:**

```
POST /heavy-operation

HTTP/1.1 202 Accepted
Location: /operations/abc123

{"operation_id": "abc123", "status": "pending"}
```

**Allow** Lists HTTP methods supported by the resource. Included in 405 Method Not Allowed responses and OPTIONS responses.

```
DELETE /api/public-info

HTTP/1.1 405 Method Not Allowed
Allow: GET, HEAD, OPTIONS

{"error": "DELETE not permitted on this resource"}
```

**OPTIONS request:**

```
OPTIONS /api/users/123

HTTP/1.1 200 OK
Allow: GET, PUT, PATCH, DELETE, HEAD, OPTIONS
```

**Server** Identifies the server software handling the request.

```
HTTP/1.1 200 OK
Server: nginx/1.21.0
```

Often omitted or obscured for security reasons—exposing server versions aids attackers in identifying vulnerabilities. Many deployments customize or remove this header.

**Retry-After** Indicates when the client should retry after rate limiting or temporary unavailability.

**Seconds:**

```
HTTP/1.1 429 Too Many Requests
Retry-After: 3600

{"error": "Rate limit exceeded"}
```

Client should wait 3600 seconds (1 hour) before retrying.

**HTTP Date:**

```
HTTP/1.1 503 Service Unavailable
Retry-After: Wed, 16 Dec 2024 14:00:00 GMT

{"error": "Maintenance in progress"}
```

Client should retry after the specified time.

**Date** Timestamp when the response was generated.

```
HTTP/1.1 200 OK
Date: Wed, 16 Dec 2024 12:30:00 GMT
```

Used for cache calculations, age determination, and logging. Required in HTTP/1.1 responses (except in specific error conditions).

### Rate Limiting Headers

APIs use various header naming conventions for rate limiting. No single standard exists, though patterns have emerged.

**Common Pattern (X-RateLimit-*):**

```
HTTP/1.1 200 OK
X-RateLimit-Limit: 1000
X-RateLimit-Remaining: 247
X-RateLimit-Reset: 1702732800

{"data": "response content"}
```

- `X-RateLimit-Limit`: Maximum requests allowed in the time window
- `X-RateLimit-Remaining`: Requests remaining in current window
- `X-RateLimit-Reset`: Unix timestamp when the window resets

**Alternative Naming (RateLimit-*):**

```
RateLimit-Limit: 1000
RateLimit-Remaining: 247
RateLimit-Reset: 1702732800
```

Drops the `X-` prefix, which was historically used for custom headers.

**GitHub Style:**

```
X-RateLimit-Limit: 5000
X-RateLimit-Remaining: 4987
X-RateLimit-Reset: 1702732800
X-RateLimit-Used: 13
```

Adds `X-RateLimit-Used` showing consumed requests.

**Twitter Style:**

```
X-Rate-Limit-Limit: 900
X-Rate-Limit-Remaining: 847
X-Rate-Limit-Reset: 1702732800
```

Uses hyphens instead of camel case.

**When Limit Exceeded:**

```
HTTP/1.1 429 Too Many Requests
X-RateLimit-Limit: 1000
X-RateLimit-Remaining: 0
X-RateLimit-Reset: 1702732800
Retry-After: 3600

{"error": "Rate limit exceeded", "message": "Try again in 1 hour"}
```

Combines rate limit headers with Retry-After for clear guidance.

**Per-Resource Rate Limits:** Different endpoints may have different limits:

```
GET /api/search

HTTP/1.1 200 OK
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 73
X-RateLimit-Reset: 1702732800
X-RateLimit-Resource: search
```

`X-RateLimit-Resource` or similar identifies which limit applies.

**Multiple Limit Types:**

```
X-RateLimit-Limit: 1000
X-RateLimit-Remaining: 247
X-RateLimit-Reset: 1702732800
X-RateLimit-Minute-Limit: 100
X-RateLimit-Minute-Remaining: 47
X-RateLimit-Minute-Reset: 1702729260
```

Tracks both hourly and per-minute limits simultaneously.

### CORS Headers

**Access-Control-Allow-Origin** Specifies which origins can access the resource.

**Specific origin:**

```
HTTP/1.1 200 OK
Access-Control-Allow-Origin: https://app.example.com
```

Only `https://app.example.com` can access this resource.

**Wildcard (any origin):**

```
Access-Control-Allow-Origin: *
```

Any origin can access. Cannot be used with credentials (cookies, authorization headers).

**Dynamic origin (reflection):** Server reflects the request Origin:

```
GET /api/data
Origin: https://trusted.example.com

HTTP/1.1 200 OK
Access-Control-Allow-Origin: https://trusted.example.com
```

[Unverified] Servers should validate Origin against an allowlist before reflecting—blindly reflecting Origin creates security vulnerabilities.

**Access-Control-Allow-Methods** Lists HTTP methods allowed for cross-origin requests.

```
HTTP/1.1 200 OK
Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS
```

Responds to preflight OPTIONS requests indicating which methods the actual request may use.

**Access-Control-Allow-Headers** Specifies which request headers the client can send.

```
HTTP/1.1 200 OK
Access-Control-Allow-Headers: Content-Type, Authorization, X-Custom-Header
```

Browsers send preflight requests when using non-simple headers. Simple headers (Accept, Accept-Language, Content-Language, Content-Type with specific values) don't require explicit permission.

**Access-Control-Expose-Headers** Lists response headers that JavaScript can access.

```
HTTP/1.1 200 OK
Access-Control-Expose-Headers: X-Total-Count, X-Page-Number, ETag
X-Total-Count: 1543
X-Page-Number: 1
ETag: "v42"
```

By default, JavaScript can only access simple response headers (Cache-Control, Content-Language, Content-Type, Expires, Last-Modified, Pragma). Custom headers require explicit exposure.

**Access-Control-Allow-Credentials** Indicates whether the response can be exposed when credentials are included.

```
HTTP/1.1 200 OK
Access-Control-Allow-Origin: https://app.example.com
Access-Control-Allow-Credentials: true
```

Enables cookies, authorization headers, and TLS client certificates in cross-origin requests. Requires specific origin (cannot use wildcard).

**Access-Control-Max-Age** Specifies how long preflight responses can be cached.

```
HTTP/1.1 200 OK
Access-Control-Allow-Origin: https://app.example.com
Access-Control-Allow-Methods: GET, POST, PUT, DELETE
Access-Control-Max-Age: 86400
```

Browsers cache preflight responses for 86400 seconds (24 hours), reducing preflight overhead.

**Preflight Request Example:**

```
OPTIONS /api/users
Origin: https://app.example.com
Access-Control-Request-Method: POST
Access-Control-Request-Headers: Content-Type, Authorization

HTTP/1.1 200 OK
Access-Control-Allow-Origin: https://app.example.com
Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS
Access-Control-Allow-Headers: Content-Type, Authorization
Access-Control-Max-Age: 3600
```

After successful preflight, actual request proceeds:

```
POST /api/users
Origin: https://app.example.com
Authorization: Bearer token123
Content-Type: application/json

{"name": "Diana"}

HTTP/1.1 201 Created
Access-Control-Allow-Origin: https://app.example.com
Location: /api/users/890
```

### Range and Content-Range Headers

**Range (Request)** Requests specific byte ranges of a resource.

**Single range:**

```
GET /files/video.mp4
Range: bytes=0-1023
```

Requests first 1024 bytes (bytes 0-1023 inclusive).

**Multiple ranges:**

```
GET /files/document.pdf
Range: bytes=0-499, 1000-1499, 5000-5999
```

Requests three separate byte ranges.

**Open-ended range:**

```
Range: bytes=1000-
```

Requests from byte 1000 to end of file.

```
Range: bytes=-500
```

Requests last 500 bytes.

**Content-Range (Response)** Indicates which portion of the resource is being returned.

**Single range response:**

```
GET /files/video.mp4
Range: bytes=0-1023

HTTP/1.1 206 Partial Content
Content-Range: bytes 0-1023/10485760
Content-Length: 1024
Content-Type: video/mp4

[1024 bytes of data]
```

`0-1023/10485760` means bytes 0-1023 of a 10MB file.

**Unsatisfiable range:**

```
GET /files/small.txt
Range: bytes=1000-2000

HTTP/1.1 416 Range Not Satisfiable
Content-Range: bytes */543

{"error": "Requested range exceeds file size"}
```

File is only 543 bytes; cannot satisfy request for bytes 1000-2000.

**Accept-Ranges** Indicates whether the server supports range requests.

```
HEAD /files/video.mp4

HTTP/1.1 200 OK
Accept-Ranges: bytes
Content-Length: 10485760
```

Server supports byte range requests.

```
Accept-Ranges: none
```

Server does not support range requests.

**Multipart Range Response:** When multiple ranges are requested, the response uses multipart format:

```
GET /files/document.pdf
Range: bytes=0-99, 500-599

HTTP/1.1 206 Partial Content
Content-Type: multipart/byteranges; boundary=BOUNDARY
Content-Length: 346

--BOUNDARY
Content-Type: application/pdf
Content-Range: bytes 0-99/5000

[100 bytes]
--BOUNDARY
Content-Type: application/pdf
Content-Range: bytes 500-599/5000

[100 bytes]
--BOUNDARY--
```

### Custom and Extension Headers

**X- Prefix (Deprecated)** Historically, custom headers used `X-` prefix:

```
X-Request-ID: abc-123-def-456
X-API-Version: 2
X-Custom-Auth: special-token
```

RFC 6648 deprecated this convention. Modern practice uses clear, descriptive names without `X-`:

```
Request-ID: abc-123-def-456
API-Version: 2
```

Many APIs still use `X-` prefix due to legacy or convention.

**Request-ID / X-Request-ID** Unique identifier for tracking requests through distributed systems.

```
POST /api/orders
Request-ID: 550e8400-e29b-41d4-a716-446655440000

HTTP/1.1 201 Created
Request-ID: 550e8400-e29b-41d4-a716-446655440000
```

Server echoes the Request-ID or generates one if not provided. Enables correlation across logs, traces, and systems.

**Idempotency-Key** Enables idempotent POST requests:

```
POST /payments
Idempotency-Key: 7f3d5c9e-8b4a-4e7f-9c2d-1a6b8e4f3c9d
Content-Type: application/json

{"amount": 100.00, "currency": "USD"}

HTTP/1.1 201 Created
Idempotency-Key: 7f3d5c9e-8b4a-4e7f-9c2d-1a6b8e4f3c9d
```

Repeated requests with the same key return the original response without re-processing.

**API-Version / X-API-Version** Specifies API version via header instead of URI:

```
GET /users/123
API-Version: 2024-12-01

HTTP/1.1 200 OK
API-Version: 2024-12-01
```

Alternative to `/v1/users/123` URI versioning.

**X-Total-Count** Common in paginated responses, indicates total number of items:

```
GET /users?page=1&per_page=20

HTTP/1.1 200 OK
X-Total-Count: 1543
Content-Type: application/json

[{...}, {...}, ...]
```

Clients use this to calculate total pages and display pagination controls.

**Link (RFC 8288)** Provides relationship-based links, particularly useful for pagination:

```
GET /articles?page=2&per_page=50

HTTP/1.1 200 OK
Link: </articles?page=1&per_page=50>; rel="prev",
      </articles?page=3&per_page=50>; rel="next",
      </articles?page=1&per_page=50>; rel="first",
      </articles?page=20&per_page=50>; rel="last"
```

Relationships (`rel` parameter):

- `next`: Next page
- `prev`/`previous`: Previous page
- `first`: First page
- `last`: Last page
- `self`: Current resource
- `alternate`: Alternative representation

**X-Forwarded-For** Identifies originating IP address when requests pass through proxies or load balancers:

```
X-Forwarded-For: 203.0.113.45, 198.51.100.17
```

First IP is original client, subsequent IPs are intermediaries. [Inference] Servers should validate and sanitize this header as clients can forge it—trust only entries added by controlled infrastructure.

**X-Forwarded-Proto** Indicates the original protocol (HTTP or HTTPS) before proxies:

```
X-Forwarded-Proto: https
```

Servers behind load balancers use this to determine if the original request was secure.

**X-Forwarded-Host** Original Host header before proxies modified it:

```
X-Forwarded-Host: api.example.com
```

**Forwarded (RFC 7239)** Standardized replacement for X-Forwarded-* headers:

```
Forwarded: for=203.0.113.45; proto=https; host=api.example.com
```

More structured and standardized but less widely adopted than X-Forwarded-* variants.

### Security Headers

**Strict-Transport-Security (HSTS)** Forces browsers to use HTTPS for future requests:

```
Strict-Transport-Security: max-age=31536000; includeSubDomains; preload
```

- `max-age=31536000`: Enforce HTTPS for 1 year
- `includeSubDomains`: Apply to all subdomains
- `preload`: Eligible for browser preload lists

[Unverified] Once sent, browsers refuse HTTP connections for the specified duration—cannot be easily reversed if misconfigured.

**Content-Security-Policy (CSP)** Controls resources the page can load, mitigating XSS attacks:

```
Content-Security-Policy: default-src 'self'; script-src 'self' 'unsafe-inline'; connect-src 'self' https://api.example.com
```

Less relevant for pure API responses (JSON/XML), more important for APIs serving HTML.

**X-Content-Type-Options** Prevents MIME type sniffing:

```
X-Content-Type-Options: nosniff
```

Browsers strictly follow Content-Type header instead of attempting to infer content types.

**X-Frame-Options** Controls whether responses can be embedded in frames:

```
X-Frame-Options: DENY
X-Frame-Options: SAMEORIGIN
X-Frame-Options: ALLOW-FROM https://trusted.example.com
```

- `DENY`: Cannot be framed
- `SAMEORIGIN`: Can be framed only by same origin
- `ALLOW-FROM`: Can be framed by specified origin

Superseded by Content-Security-Policy frame-ancestors directive but still widely used.

**X-XSS-Protection** Legacy header enabling browser XSS filters:

```
X-XSS-Protection: 1; mode=block
```

Deprecated in favor of Content-Security-Policy but still used for older browser compatibility.

### Conditional Request Headers

**If-Match** Processes request only if resource ETag matches:

```
PUT /api/users/123
If-Match: "v42"
If-Match: "v42", "v41", "v40"
```

Multiple ETags can be specified. Succeeds if current ETag matches any.

```
If-Match: *
```

Wildcard succeeds if resource exists (regardless of ETag).

**If-None-Match** Inverse of If-Match:

```
GET /api/users/123
If-None-Match: "v42"
```

For GET: Returns 304 if ETag matches (resource unchanged).
For PUT/POST: Succeeds only if ETag doesn't match (typically used with wildcard `*` to prevent overwriting existing resources).

**If-Modified-Since**
Processes request only if resource modified after specified time:

```

GET /api/articles/456 If-Modified-Since: Wed, 15 Dec 2024 10:00:00 GMT

```

Returns 304 if not modified since that time.

**If-Unmodified-Since**
Processes request only if resource not modified since specified time:

```

PUT /api/articles/456 If-Unmodified-Since: Wed, 15 Dec 2024 10:00:00 GMT

```

Returns 412 if modified since that time. Prevents overwriting newer versions.

**If-Range**
Combines conditional request with range request:

```

GET /files/video.mp4 Range: bytes=1000000- If-Range: "etag-value"

```

If resource matches ETag, returns partial content (206). If resource changed, returns complete resource (200), allowing client to restart with new version.

### Connection Management Headers

**Connection**
Controls connection persistence:

```

Connection: keep-alive Connection: close

```

- `keep-alive`: Maintain connection for multiple requests (default in HTTP/1.1)
- `close`: Close connection after response

HTTP/1.1 assumes persistent connections. HTTP/2 deprecates this header.

**Keep-Alive**
Parameters for persistent connections:

```

Keep-Alive: timeout=5, max=100

```

- `timeout`: Seconds the connection stays open while idle
- `max`: Maximum requests on this connection

Used with `Connection: keep-alive`.

**TE**
Client indicates acceptable transfer encodings:

```

TE: trailers, deflate;q=0.5

```

Similar to Accept-Encoding but for transfer encodings rather than content encodings.

**Transfer-Encoding**
Specifies encoding applied during transmission:

```

Transfer-Encoding: chunked Transfer-Encoding: gzip, chunked

```

- `chunked`: Response sent in chunks (size unknown in advance)
- `gzip`, `deflate`: Compression applied
- `identity`: No encoding (rarely specified)

Chunked encoding enables streaming responses without knowing total size upfront.

**Trailer**
Announces which headers will appear in chunked encoding trailers:

```

HTTP/1.1 200 OK Transfer-Encoding: chunked Trailer: X-Checksum, X-Processing-Time

5 Hello 5 World 0 X-Checksum: abc123 X-Processing-Time: 45ms

```

Trailers appear after the message body, useful for headers whose values aren't known until processing completes.

### Deprecation and Sunset Headers

**Deprecation (RFC draft)**
Signals that a resource or endpoint is deprecated:

```

HTTP/1.1 200 OK Deprecation: true Deprecation: Wed, 01 Jan 2025 00:00:00 GMT

```

Boolean `true` or date when deprecation takes effect. Clients should transition away from deprecated endpoints.

**Sunset (RFC 8594)**
Indicates when a resource will become unavailable:

```

HTTP/1.1 200 OK Sunset: Wed, 31 Dec 2025 23:59:59 GMT Link: [https://api.example.com/docs/migration](https://api.example.com/docs/migration); rel="sunset"

```

Provides date of removal. Link header can point to migration documentation.

Combined usage:
```

Deprecation: Sun, 01 Jun 2025 00:00:00 GMT Sunset: Sat, 01 Jan 2026 00:00:00 GMT

```

Deprecated June 2025, removed January 2026.

### Warning Header (Deprecated)

**Warning**
Originally for cache warnings, now deprecated:

```

Warning: 110 - "Response is Stale" Warning: 199 - "Miscellaneous Warning"

```

HTTP/1.1 defined various warning codes. Modern practices prefer structured error responses in message bodies over Warning headers.

### Header Size Limits and Best Practices

**Practical Limits:**
- Total request header size: Typically 8KB-16KB (server-dependent)
- Individual header: No standard limit, but 4KB is safe
- Number of headers: No standard limit, but hundreds cause problems

Exceeding limits results in 431 Request Header Fields Too Large.

**Design Recommendations:**

Use standard headers when available—don't create custom headers for functionality that existing headers provide.

Keep header values concise. Long authorization tokens, extensive cookies, or verbose custom headers consume the header size budget.

Prefer request bodies over headers for large data. Headers are for metadata; bodies carry content.

Document custom headers clearly—specify format, constraints, and behavior.

Version custom headers if they may evolve. Include version in the header name or value structure.

Validate header values rigorously—headers come from untrusted clients and may contain injection attacks or malformed data.

Use lowercase for custom header names in HTTP/2 and HTTP/3 (requirements). HTTP/1.1 is case-insensitive but consistency helps.

Avoid redundancy—don't include information already available through other headers or the request itself.

Consider privacy—headers appear in logs, so avoid including sensitive information when possible.
```

---

# Request Body

## FormData API

### Core Concepts

The FormData API provides a programmatic interface for constructing and manipulating form data as key-value pairs. It represents the data structure used when submitting HTML forms with `enctype="multipart/form-data"`, but can be used independently of actual form elements.

FormData objects are particularly useful for:

- Uploading files via XHR or Fetch
- Constructing form submissions programmatically
- Appending binary data alongside text fields
- Sending mixed content types in a single request

### Creating FormData Objects

**Empty FormData**

```javascript
const formData = new FormData();
formData.append('username', 'john_doe');
formData.append('email', 'john@example.com');
```

**From Existing Form Element**

```javascript
const form = document.querySelector('#myForm');
const formData = new FormData(form);

// All form fields are automatically captured
// including <input>, <select>, <textarea>, and file inputs
```

**From Form with Submitter Context**

```javascript
const form = document.querySelector('#myForm');
const submitButton = document.querySelector('#submitBtn');

// Second parameter captures the submitter element
const formData = new FormData(form, submitButton);
// If submitButton has name/value, it's included in formData
```

### Adding Data

**append() Method**

Adds a new value for a key, or adds another value if the key already exists:

```javascript
const formData = new FormData();

// Text values
formData.append('username', 'john_doe');
formData.append('age', 25);
formData.append('age', 30); // Multiple values for same key

// Boolean and numeric values are converted to strings
formData.append('active', true); // Stored as "true"
formData.append('count', 42); // Stored as "42"
```

**set() Method**

Replaces any existing values for a key with a single new value:

```javascript
const formData = new FormData();
formData.append('username', 'john');
formData.append('username', 'jane'); // Now has 2 values

formData.set('username', 'alice'); // Replaces both with single value
```

### File Uploads

**File Input Elements**

```javascript
const fileInput = document.querySelector('#fileUpload');
const file = fileInput.files[0];

const formData = new FormData();
formData.append('document', file);
formData.append('description', 'Important document');
```

**Multiple Files**

```javascript
const fileInput = document.querySelector('#multipleFiles');

const formData = new FormData();
for (const file of fileInput.files) {
  formData.append('files', file); // Same key for multiple files
}

// Alternative: different keys
Array.from(fileInput.files).forEach((file, index) => {
  formData.append(`file_${index}`, file);
});
```

**Blob Objects**

```javascript
const blob = new Blob(['Hello, world!'], { type: 'text/plain' });
formData.append('textfile', blob, 'hello.txt'); // Third param is filename

// Canvas to blob
canvas.toBlob((blob) => {
  formData.append('screenshot', blob, 'screenshot.png');
});
```

**File Constructor**

```javascript
const fileContent = new Uint8Array([137, 80, 78, 71]); // PNG header
const file = new File([fileContent], 'image.png', { type: 'image/png' });

formData.append('customFile', file);
```

### Reading Data

**get() Method**

Returns the first value associated with a key:

```javascript
const formData = new FormData();
formData.append('username', 'john');
formData.append('username', 'jane');

const value = formData.get('username'); // Returns 'john'
const missing = formData.get('nonexistent'); // Returns null
```

**getAll() Method**

Returns all values associated with a key as an array:

```javascript
const formData = new FormData();
formData.append('tag', 'javascript');
formData.append('tag', 'web');
formData.append('tag', 'api');

const tags = formData.getAll('tag'); 
// Returns ['javascript', 'web', 'api']

const noTags = formData.getAll('nonexistent'); 
// Returns []
```

**has() Method**

Checks if a key exists:

```javascript
const formData = new FormData();
formData.append('username', 'john');

formData.has('username'); // true
formData.has('email'); // false
```

### Modifying Data

**delete() Method**

Removes all values for a key:

```javascript
const formData = new FormData();
formData.append('username', 'john');
formData.append('username', 'jane');

formData.delete('username');
formData.has('username'); // false
```

**set() Method for Updates**

```javascript
const formData = new FormData();
formData.append('count', 1);
formData.set('count', 2); // Replaces value

// For files, set() also accepts filename parameter
formData.set('file', blob, 'updated.txt');
```

### Iteration

**entries() Method**

Returns an iterator of [key, value] pairs:

```javascript
const formData = new FormData();
formData.append('username', 'john');
formData.append('email', 'john@example.com');
formData.append('tags', 'js');
formData.append('tags', 'api');

for (const [key, value] of formData.entries()) {
  console.log(key, value);
}
// Output:
// username john
// email john@example.com
// tags js
// tags api
```

**keys() Method**

Returns an iterator of keys:

```javascript
for (const key of formData.keys()) {
  console.log(key);
}
// Output: username, email, tags, tags
```

**values() Method**

Returns an iterator of values:

```javascript
for (const value of formData.values()) {
  console.log(value);
}
// Output: john, john@example.com, js, api
```

**forEach() Method**

```javascript
formData.forEach((value, key) => {
  console.log(`${key}: ${value}`);
});

// With index parameter
formData.forEach((value, key, formData) => {
  console.log(`${key}: ${value}`);
  // Third parameter is the FormData object itself
});
```

### Sending FormData

**Fetch API**

```javascript
const formData = new FormData();
formData.append('username', 'john');
formData.append('file', fileInput.files[0]);

fetch('https://api.example.com/upload', {
  method: 'POST',
  body: formData
  // Do NOT set Content-Type header manually
  // Browser sets it automatically with boundary parameter
})
  .then(response => response.json())
  .then(data => console.log(data));
```

**XMLHttpRequest**

```javascript
const xhr = new XMLHttpRequest();
xhr.open('POST', 'https://api.example.com/upload');

xhr.upload.addEventListener('progress', (e) => {
  if (e.lengthComputable) {
    const percentComplete = (e.loaded / e.total) * 100;
    console.log(`Upload: ${percentComplete}%`);
  }
});

xhr.addEventListener('load', () => {
  console.log('Upload complete');
});

xhr.send(formData);
```

**Automatic Content-Type**

When sending FormData, browsers automatically set:

```
Content-Type: multipart/form-data; boundary=----WebKitFormBoundary7MA4YWxkTrZu0gW
```

The boundary parameter is a unique string used to separate form fields in the request body. Never set `Content-Type` manually when sending FormData, as the browser must generate the boundary.

### Content-Type Encoding

**multipart/form-data Structure**

FormData is transmitted as multipart/form-data:

```
------WebKitFormBoundary7MA4YWxkTrZu0gW
Content-Disposition: form-data; name="username"

john_doe
------WebKitFormBoundary7MA4YWxkTrZu0gW
Content-Disposition: form-data; name="file"; filename="document.pdf"
Content-Type: application/pdf

[binary data]
------WebKitFormBoundary7MA4YWxkTrZu0gW--
```

Each field is separated by the boundary string, with metadata headers followed by the actual data.

**File Metadata**

For file uploads, the browser includes:

- `Content-Disposition`: Contains field name and filename
- `Content-Type`: MIME type of the file

```
Content-Disposition: form-data; name="avatar"; filename="photo.jpg"
Content-Type: image/jpeg
```

### Converting FormData

**To URLSearchParams**

```javascript
const formData = new FormData();
formData.append('username', 'john');
formData.append('age', 25);

const params = new URLSearchParams(formData);
console.log(params.toString()); 
// username=john&age=25

// Note: Files are converted to "[object File]" string
// This conversion is rarely useful for file uploads
```

**To Plain Object**

```javascript
const formData = new FormData();
formData.append('username', 'john');
formData.append('email', 'john@example.com');

// Single values per key
const obj = Object.fromEntries(formData.entries());
// { username: 'john', email: 'john@example.com' }

// Multiple values handling
const objWithArrays = {};
for (const [key, value] of formData.entries()) {
  if (objWithArrays[key]) {
    if (Array.isArray(objWithArrays[key])) {
      objWithArrays[key].push(value);
    } else {
      objWithArrays[key] = [objWithArrays[key], value];
    }
  } else {
    objWithArrays[key] = value;
  }
}
```

**To JSON**

```javascript
// Direct conversion loses file data
const json = JSON.stringify(Object.fromEntries(formData));

// Files become: {"file": {}}
// Blobs become: {"blob": {}}
```

FormData cannot be directly serialized to JSON with file preservation. For JSON APIs with file uploads, use alternative approaches:

- Base64 encode files within JSON
- Send files separately via FormData, then reference in JSON payload
- Use multipart/form-data and parse on server

### From JSON to FormData

```javascript
const data = {
  username: 'john',
  email: 'john@example.com',
  tags: ['javascript', 'web'],
  active: true
};

const formData = new FormData();

Object.entries(data).forEach(([key, value]) => {
  if (Array.isArray(value)) {
    value.forEach(item => formData.append(key, item));
  } else {
    formData.append(key, value);
  }
});
```

### File Name Handling

**Extracting File Names**

```javascript
const formData = new FormData();
formData.append('file', file);

const uploadedFile = formData.get('file');
if (uploadedFile instanceof File) {
  console.log(uploadedFile.name); // Original filename
  console.log(uploadedFile.type); // MIME type
  console.log(uploadedFile.size); // Size in bytes
  console.log(uploadedFile.lastModified); // Timestamp
}
```

**Custom File Names**

```javascript
// Override filename for Blob
const blob = new Blob(['content'], { type: 'text/plain' });
formData.append('file', blob, 'custom-name.txt');

// Override filename for File
const file = fileInput.files[0];
formData.append('file', file, 'renamed-file.pdf');
```

### CORS Considerations

FormData follows standard CORS rules:

```javascript
fetch('https://api.example.com/upload', {
  method: 'POST',
  body: formData,
  credentials: 'include' // Include cookies cross-origin
});
```

Server must respond with appropriate headers:

```
Access-Control-Allow-Origin: https://yoursite.com
Access-Control-Allow-Methods: POST, OPTIONS
Access-Control-Allow-Headers: Content-Type
```

FormData requests are never simple requests (they use `multipart/form-data`), so they trigger CORS preflight.

### Size Limitations

**Browser Limits**

[Inference] Browsers typically don't impose specific FormData size limits in memory, but practical constraints include:

- Available RAM for constructing the FormData object
- Server request size limits (often 10MB-100MB default)
- Network timeouts for large uploads
- Maximum file sizes in file input elements

**Server Configuration**

Common server limits:

- nginx: `client_max_body_size` (default 1MB)
- Apache: `LimitRequestBody` (default unlimited, practically limited by system)
- Node.js Express: `body-parser` or `multer` limits
- PHP: `upload_max_filesize` and `post_max_size`

### Progress Monitoring

**Upload Progress with XHR**

```javascript
const xhr = new XMLHttpRequest();
xhr.open('POST', '/upload');

xhr.upload.addEventListener('progress', (e) => {
  if (e.lengthComputable) {
    const percentComplete = (e.loaded / e.total) * 100;
    updateProgressBar(percentComplete);
  }
});

xhr.upload.addEventListener('load', () => {
  console.log('Upload finished');
});

xhr.upload.addEventListener('error', () => {
  console.error('Upload failed');
});

xhr.upload.addEventListener('abort', () => {
  console.log('Upload cancelled');
});

xhr.send(formData);
```

**Fetch API Limitations**

[Unverified] The Fetch API does not currently provide a standard mechanism for monitoring upload progress. Some browsers may support experimental APIs or extensions, but there's no cross-browser standard.

Workarounds include:

- Using XHR for uploads requiring progress
- Server-sent events for server-side progress updates
- Polling a status endpoint after initiating upload

### FormData and Service Workers

Service workers can intercept and modify FormData requests:

```javascript
self.addEventListener('fetch', (event) => {
  if (event.request.method === 'POST') {
    event.respondWith(
      event.request.formData().then((formData) => {
        // Add timestamp
        formData.append('timestamp', Date.now());
        
        // Create new request with modified FormData
        const modifiedRequest = new Request(event.request.url, {
          method: 'POST',
          body: formData,
          headers: event.request.headers
        });
        
        return fetch(modifiedRequest);
      })
    );
  }
});
```

**Reading FormData in Service Workers**

```javascript
// Clone request to read body (body can only be read once)
const clonedRequest = event.request.clone();

clonedRequest.formData().then((formData) => {
  console.log('Intercepted form data:');
  for (const [key, value] of formData.entries()) {
    console.log(key, value);
  }
});
```

### Common Patterns

**Form Submission Handler**

```javascript
document.querySelector('#myForm').addEventListener('submit', async (e) => {
  e.preventDefault();
  
  const formData = new FormData(e.target);
  
  // Add additional data
  formData.append('timestamp', Date.now());
  formData.append('source', 'web-app');
  
  try {
    const response = await fetch('/api/submit', {
      method: 'POST',
      body: formData
    });
    
    if (response.ok) {
      const result = await response.json();
      console.log('Success:', result);
    } else {
      console.error('Error:', response.status);
    }
  } catch (error) {
    console.error('Network error:', error);
  }
});
```

**File Upload with Preview**

```javascript
const fileInput = document.querySelector('#fileInput');
const preview = document.querySelector('#preview');

fileInput.addEventListener('change', (e) => {
  const file = e.target.files[0];
  
  if (file && file.type.startsWith('image/')) {
    const reader = new FileReader();
    
    reader.onload = (e) => {
      preview.src = e.target.result;
    };
    
    reader.readAsDataURL(file);
    
    // Prepare FormData for upload
    const formData = new FormData();
    formData.append('image', file);
    formData.append('caption', 'User uploaded image');
    
    uploadImage(formData);
  }
});

async function uploadImage(formData) {
  const response = await fetch('/api/upload-image', {
    method: 'POST',
    body: formData
  });
  
  const result = await response.json();
  console.log('Uploaded:', result.url);
}
```

**Dynamic Field Addition**

```javascript
const formData = new FormData();

// Add fields based on conditions
const includeOptionalFields = true;

formData.append('required_field', 'value');

if (includeOptionalFields) {
  formData.append('optional_field', 'optional_value');
}

// Add array of values
const selectedItems = ['item1', 'item2', 'item3'];
selectedItems.forEach(item => {
  formData.append('items[]', item);
});

// Add nested data (server must parse)
const userData = { name: 'John', age: 30 };
formData.append('user', JSON.stringify(userData));
```

### Debugging FormData

**Logging Contents**

```javascript
function logFormData(formData) {
  console.log('FormData contents:');
  for (const [key, value] of formData.entries()) {
    if (value instanceof File) {
      console.log(`${key}: File(${value.name}, ${value.size} bytes, ${value.type})`);
    } else if (value instanceof Blob) {
      console.log(`${key}: Blob(${value.size} bytes, ${value.type})`);
    } else {
      console.log(`${key}: ${value}`);
    }
  }
}

const formData = new FormData(form);
logFormData(formData);
```

**Network Inspection**

Browser DevTools show FormData in the Network tab:

- Request payload shows individual form fields
- Files display with name, type, and size
- Preview tab shows parsed form data structure

### Security Considerations

**File Type Validation**

```javascript
const allowedTypes = ['image/jpeg', 'image/png', 'image/gif'];
const file = fileInput.files[0];

if (file && !allowedTypes.includes(file.type)) {
  console.error('Invalid file type');
  return;
}

// Note: Client-side validation is not sufficient
// Always validate on server (MIME type can be spoofed)
```

**File Size Validation**

```javascript
const maxSize = 5 * 1024 * 1024; // 5MB
const file = fileInput.files[0];

if (file && file.size > maxSize) {
  console.error('File too large');
  return;
}
```

**CSRF Protection**

```javascript
// Include CSRF token in FormData
const formData = new FormData(form);
const csrfToken = document.querySelector('meta[name="csrf-token"]').content;
formData.append('_csrf', csrfToken);

fetch('/api/submit', {
  method: 'POST',
  body: formData,
  credentials: 'same-origin' // Include cookies
});
```

**Content Sanitization**

[Inference] FormData itself doesn't sanitize input. Server-side validation and sanitization are essential:

- Validate field names and values
- Check file MIME types and content (not just extension)
- Scan uploaded files for malware
- Limit file sizes and number of files
- Validate image dimensions for image uploads

### Browser Compatibility

FormData API is widely supported in modern browsers. Key features and their support:

- Basic FormData: All modern browsers
- `FormData(form)` constructor: All modern browsers
- Iteration methods (`entries()`, `keys()`, `values()`): All modern browsers
- `set()` method: All modern browsers
- Second parameter of `FormData(form, submitter)`: [Inference] Supported in recent browser versions, but may not be available in older browsers

For legacy browser support, polyfills are available for iteration methods.

---

# Request Body

## FormData API

### Core Concepts

The FormData API provides a programmatic interface for constructing and manipulating form data as key-value pairs. It represents the data structure used when submitting HTML forms with `enctype="multipart/form-data"`, but can be used independently of actual form elements.

FormData objects are particularly useful for:

- Uploading files via XHR or Fetch
- Constructing form submissions programmatically
- Appending binary data alongside text fields
- Sending mixed content types in a single request

### Creating FormData Objects

**Empty FormData**

```javascript
const formData = new FormData();
formData.append('username', 'john_doe');
formData.append('email', 'john@example.com');
```

**From Existing Form Element**

```javascript
const form = document.querySelector('#myForm');
const formData = new FormData(form);

// All form fields are automatically captured
// including <input>, <select>, <textarea>, and file inputs
```

**From Form with Submitter Context**

```javascript
const form = document.querySelector('#myForm');
const submitButton = document.querySelector('#submitBtn');

// Second parameter captures the submitter element
const formData = new FormData(form, submitButton);
// If submitButton has name/value, it's included in formData
```

### Adding Data

**append() Method**

Adds a new value for a key, or adds another value if the key already exists:

```javascript
const formData = new FormData();

// Text values
formData.append('username', 'john_doe');
formData.append('age', 25);
formData.append('age', 30); // Multiple values for same key

// Boolean and numeric values are converted to strings
formData.append('active', true); // Stored as "true"
formData.append('count', 42); // Stored as "42"
```

**set() Method**

Replaces any existing values for a key with a single new value:

```javascript
const formData = new FormData();
formData.append('username', 'john');
formData.append('username', 'jane'); // Now has 2 values

formData.set('username', 'alice'); // Replaces both with single value
```

### File Uploads

**File Input Elements**

```javascript
const fileInput = document.querySelector('#fileUpload');
const file = fileInput.files[0];

const formData = new FormData();
formData.append('document', file);
formData.append('description', 'Important document');
```

**Multiple Files**

```javascript
const fileInput = document.querySelector('#multipleFiles');

const formData = new FormData();
for (const file of fileInput.files) {
  formData.append('files', file); // Same key for multiple files
}

// Alternative: different keys
Array.from(fileInput.files).forEach((file, index) => {
  formData.append(`file_${index}`, file);
});
```

**Blob Objects**

```javascript
const blob = new Blob(['Hello, world!'], { type: 'text/plain' });
formData.append('textfile', blob, 'hello.txt'); // Third param is filename

// Canvas to blob
canvas.toBlob((blob) => {
  formData.append('screenshot', blob, 'screenshot.png');
});
```

**File Constructor**

```javascript
const fileContent = new Uint8Array([137, 80, 78, 71]); // PNG header
const file = new File([fileContent], 'image.png', { type: 'image/png' });

formData.append('customFile', file);
```

### Reading Data

**get() Method**

Returns the first value associated with a key:

```javascript
const formData = new FormData();
formData.append('username', 'john');
formData.append('username', 'jane');

const value = formData.get('username'); // Returns 'john'
const missing = formData.get('nonexistent'); // Returns null
```

**getAll() Method**

Returns all values associated with a key as an array:

```javascript
const formData = new FormData();
formData.append('tag', 'javascript');
formData.append('tag', 'web');
formData.append('tag', 'api');

const tags = formData.getAll('tag'); 
// Returns ['javascript', 'web', 'api']

const noTags = formData.getAll('nonexistent'); 
// Returns []
```

**has() Method**

Checks if a key exists:

```javascript
const formData = new FormData();
formData.append('username', 'john');

formData.has('username'); // true
formData.has('email'); // false
```

### Modifying Data

**delete() Method**

Removes all values for a key:

```javascript
const formData = new FormData();
formData.append('username', 'john');
formData.append('username', 'jane');

formData.delete('username');
formData.has('username'); // false
```

**set() Method for Updates**

```javascript
const formData = new FormData();
formData.append('count', 1);
formData.set('count', 2); // Replaces value

// For files, set() also accepts filename parameter
formData.set('file', blob, 'updated.txt');
```

### Iteration

**entries() Method**

Returns an iterator of [key, value] pairs:

```javascript
const formData = new FormData();
formData.append('username', 'john');
formData.append('email', 'john@example.com');
formData.append('tags', 'js');
formData.append('tags', 'api');

for (const [key, value] of formData.entries()) {
  console.log(key, value);
}
// Output:
// username john
// email john@example.com
// tags js
// tags api
```

**keys() Method**

Returns an iterator of keys:

```javascript
for (const key of formData.keys()) {
  console.log(key);
}
// Output: username, email, tags, tags
```

**values() Method**

Returns an iterator of values:

```javascript
for (const value of formData.values()) {
  console.log(value);
}
// Output: john, john@example.com, js, api
```

**forEach() Method**

```javascript
formData.forEach((value, key) => {
  console.log(`${key}: ${value}`);
});

// With index parameter
formData.forEach((value, key, formData) => {
  console.log(`${key}: ${value}`);
  // Third parameter is the FormData object itself
});
```

### Sending FormData

**Fetch API**

```javascript
const formData = new FormData();
formData.append('username', 'john');
formData.append('file', fileInput.files[0]);

fetch('https://api.example.com/upload', {
  method: 'POST',
  body: formData
  // Do NOT set Content-Type header manually
  // Browser sets it automatically with boundary parameter
})
  .then(response => response.json())
  .then(data => console.log(data));
```

**XMLHttpRequest**

```javascript
const xhr = new XMLHttpRequest();
xhr.open('POST', 'https://api.example.com/upload');

xhr.upload.addEventListener('progress', (e) => {
  if (e.lengthComputable) {
    const percentComplete = (e.loaded / e.total) * 100;
    console.log(`Upload: ${percentComplete}%`);
  }
});

xhr.addEventListener('load', () => {
  console.log('Upload complete');
});

xhr.send(formData);
```

**Automatic Content-Type**

When sending FormData, browsers automatically set:

```
Content-Type: multipart/form-data; boundary=----WebKitFormBoundary7MA4YWxkTrZu0gW
```

The boundary parameter is a unique string used to separate form fields in the request body. Never set `Content-Type` manually when sending FormData, as the browser must generate the boundary.

### Content-Type Encoding

**multipart/form-data Structure**

FormData is transmitted as multipart/form-data:

```
------WebKitFormBoundary7MA4YWxkTrZu0gW
Content-Disposition: form-data; name="username"

john_doe
------WebKitFormBoundary7MA4YWxkTrZu0gW
Content-Disposition: form-data; name="file"; filename="document.pdf"
Content-Type: application/pdf

[binary data]
------WebKitFormBoundary7MA4YWxkTrZu0gW--
```

Each field is separated by the boundary string, with metadata headers followed by the actual data.

**File Metadata**

For file uploads, the browser includes:

- `Content-Disposition`: Contains field name and filename
- `Content-Type`: MIME type of the file

```
Content-Disposition: form-data; name="avatar"; filename="photo.jpg"
Content-Type: image/jpeg
```

### Converting FormData

**To URLSearchParams**

```javascript
const formData = new FormData();
formData.append('username', 'john');
formData.append('age', 25);

const params = new URLSearchParams(formData);
console.log(params.toString()); 
// username=john&age=25

// Note: Files are converted to "[object File]" string
// This conversion is rarely useful for file uploads
```

**To Plain Object**

```javascript
const formData = new FormData();
formData.append('username', 'john');
formData.append('email', 'john@example.com');

// Single values per key
const obj = Object.fromEntries(formData.entries());
// { username: 'john', email: 'john@example.com' }

// Multiple values handling
const objWithArrays = {};
for (const [key, value] of formData.entries()) {
  if (objWithArrays[key]) {
    if (Array.isArray(objWithArrays[key])) {
      objWithArrays[key].push(value);
    } else {
      objWithArrays[key] = [objWithArrays[key], value];
    }
  } else {
    objWithArrays[key] = value;
  }
}
```

**To JSON**

```javascript
// Direct conversion loses file data
const json = JSON.stringify(Object.fromEntries(formData));

// Files become: {"file": {}}
// Blobs become: {"blob": {}}
```

FormData cannot be directly serialized to JSON with file preservation. For JSON APIs with file uploads, use alternative approaches:

- Base64 encode files within JSON
- Send files separately via FormData, then reference in JSON payload
- Use multipart/form-data and parse on server

### From JSON to FormData

```javascript
const data = {
  username: 'john',
  email: 'john@example.com',
  tags: ['javascript', 'web'],
  active: true
};

const formData = new FormData();

Object.entries(data).forEach(([key, value]) => {
  if (Array.isArray(value)) {
    value.forEach(item => formData.append(key, item));
  } else {
    formData.append(key, value);
  }
});
```

### File Name Handling

**Extracting File Names**

```javascript
const formData = new FormData();
formData.append('file', file);

const uploadedFile = formData.get('file');
if (uploadedFile instanceof File) {
  console.log(uploadedFile.name); // Original filename
  console.log(uploadedFile.type); // MIME type
  console.log(uploadedFile.size); // Size in bytes
  console.log(uploadedFile.lastModified); // Timestamp
}
```

**Custom File Names**

```javascript
// Override filename for Blob
const blob = new Blob(['content'], { type: 'text/plain' });
formData.append('file', blob, 'custom-name.txt');

// Override filename for File
const file = fileInput.files[0];
formData.append('file', file, 'renamed-file.pdf');
```

### CORS Considerations

FormData follows standard CORS rules:

```javascript
fetch('https://api.example.com/upload', {
  method: 'POST',
  body: formData,
  credentials: 'include' // Include cookies cross-origin
});
```

Server must respond with appropriate headers:

```
Access-Control-Allow-Origin: https://yoursite.com
Access-Control-Allow-Methods: POST, OPTIONS
Access-Control-Allow-Headers: Content-Type
```

FormData requests are never simple requests (they use `multipart/form-data`), so they trigger CORS preflight.

### Size Limitations

**Browser Limits**

[Inference] Browsers typically don't impose specific FormData size limits in memory, but practical constraints include:

- Available RAM for constructing the FormData object
- Server request size limits (often 10MB-100MB default)
- Network timeouts for large uploads
- Maximum file sizes in file input elements

**Server Configuration**

Common server limits:

- nginx: `client_max_body_size` (default 1MB)
- Apache: `LimitRequestBody` (default unlimited, practically limited by system)
- Node.js Express: `body-parser` or `multer` limits
- PHP: `upload_max_filesize` and `post_max_size`

### Progress Monitoring

**Upload Progress with XHR**

```javascript
const xhr = new XMLHttpRequest();
xhr.open('POST', '/upload');

xhr.upload.addEventListener('progress', (e) => {
  if (e.lengthComputable) {
    const percentComplete = (e.loaded / e.total) * 100;
    updateProgressBar(percentComplete);
  }
});

xhr.upload.addEventListener('load', () => {
  console.log('Upload finished');
});

xhr.upload.addEventListener('error', () => {
  console.error('Upload failed');
});

xhr.upload.addEventListener('abort', () => {
  console.log('Upload cancelled');
});

xhr.send(formData);
```

**Fetch API Limitations**

[Unverified] The Fetch API does not currently provide a standard mechanism for monitoring upload progress. Some browsers may support experimental APIs or extensions, but there's no cross-browser standard.

Workarounds include:

- Using XHR for uploads requiring progress
- Server-sent events for server-side progress updates
- Polling a status endpoint after initiating upload

### FormData and Service Workers

Service workers can intercept and modify FormData requests:

```javascript
self.addEventListener('fetch', (event) => {
  if (event.request.method === 'POST') {
    event.respondWith(
      event.request.formData().then((formData) => {
        // Add timestamp
        formData.append('timestamp', Date.now());
        
        // Create new request with modified FormData
        const modifiedRequest = new Request(event.request.url, {
          method: 'POST',
          body: formData,
          headers: event.request.headers
        });
        
        return fetch(modifiedRequest);
      })
    );
  }
});
```

**Reading FormData in Service Workers**

```javascript
// Clone request to read body (body can only be read once)
const clonedRequest = event.request.clone();

clonedRequest.formData().then((formData) => {
  console.log('Intercepted form data:');
  for (const [key, value] of formData.entries()) {
    console.log(key, value);
  }
});
```

### Common Patterns

**Form Submission Handler**

```javascript
document.querySelector('#myForm').addEventListener('submit', async (e) => {
  e.preventDefault();
  
  const formData = new FormData(e.target);
  
  // Add additional data
  formData.append('timestamp', Date.now());
  formData.append('source', 'web-app');
  
  try {
    const response = await fetch('/api/submit', {
      method: 'POST',
      body: formData
    });
    
    if (response.ok) {
      const result = await response.json();
      console.log('Success:', result);
    } else {
      console.error('Error:', response.status);
    }
  } catch (error) {
    console.error('Network error:', error);
  }
});
```

**File Upload with Preview**

```javascript
const fileInput = document.querySelector('#fileInput');
const preview = document.querySelector('#preview');

fileInput.addEventListener('change', (e) => {
  const file = e.target.files[0];
  
  if (file && file.type.startsWith('image/')) {
    const reader = new FileReader();
    
    reader.onload = (e) => {
      preview.src = e.target.result;
    };
    
    reader.readAsDataURL(file);
    
    // Prepare FormData for upload
    const formData = new FormData();
    formData.append('image', file);
    formData.append('caption', 'User uploaded image');
    
    uploadImage(formData);
  }
});

async function uploadImage(formData) {
  const response = await fetch('/api/upload-image', {
    method: 'POST',
    body: formData
  });
  
  const result = await response.json();
  console.log('Uploaded:', result.url);
}
```

**Dynamic Field Addition**

```javascript
const formData = new FormData();

// Add fields based on conditions
const includeOptionalFields = true;

formData.append('required_field', 'value');

if (includeOptionalFields) {
  formData.append('optional_field', 'optional_value');
}

// Add array of values
const selectedItems = ['item1', 'item2', 'item3'];
selectedItems.forEach(item => {
  formData.append('items[]', item);
});

// Add nested data (server must parse)
const userData = { name: 'John', age: 30 };
formData.append('user', JSON.stringify(userData));
```

### Debugging FormData

**Logging Contents**

```javascript
function logFormData(formData) {
  console.log('FormData contents:');
  for (const [key, value] of formData.entries()) {
    if (value instanceof File) {
      console.log(`${key}: File(${value.name}, ${value.size} bytes, ${value.type})`);
    } else if (value instanceof Blob) {
      console.log(`${key}: Blob(${value.size} bytes, ${value.type})`);
    } else {
      console.log(`${key}: ${value}`);
    }
  }
}

const formData = new FormData(form);
logFormData(formData);
```

**Network Inspection**

Browser DevTools show FormData in the Network tab:

- Request payload shows individual form fields
- Files display with name, type, and size
- Preview tab shows parsed form data structure

### Security Considerations

**File Type Validation**

```javascript
const allowedTypes = ['image/jpeg', 'image/png', 'image/gif'];
const file = fileInput.files[0];

if (file && !allowedTypes.includes(file.type)) {
  console.error('Invalid file type');
  return;
}

// Note: Client-side validation is not sufficient
// Always validate on server (MIME type can be spoofed)
```

**File Size Validation**

```javascript
const maxSize = 5 * 1024 * 1024; // 5MB
const file = fileInput.files[0];

if (file && file.size > maxSize) {
  console.error('File too large');
  return;
}
```

**CSRF Protection**

```javascript
// Include CSRF token in FormData
const formData = new FormData(form);
const csrfToken = document.querySelector('meta[name="csrf-token"]').content;
formData.append('_csrf', csrfToken);

fetch('/api/submit', {
  method: 'POST',
  body: formData,
  credentials: 'same-origin' // Include cookies
});
```

**Content Sanitization**

[Inference] FormData itself doesn't sanitize input. Server-side validation and sanitization are essential:

- Validate field names and values
- Check file MIME types and content (not just extension)
- Scan uploaded files for malware
- Limit file sizes and number of files
- Validate image dimensions for image uploads

### Browser Compatibility

FormData API is widely supported in modern browsers. Key features and their support:

- Basic FormData: All modern browsers
- `FormData(form)` constructor: All modern browsers
- Iteration methods (`entries()`, `keys()`, `values()`): All modern browsers
- `set()` method: All modern browsers
- Second parameter of `FormData(form, submitter)`: [Inference] Supported in recent browser versions, but may not be available in older browsers

For legacy browser support, polyfills are available for iteration methods.

---

## JSON Payloads in Fetch Context

### Basic JSON Request

The Fetch API sends JSON by serializing JavaScript objects and setting the appropriate content type.

**Standard pattern:**

```javascript
fetch('https://api.example.com/users', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({
    name: 'John Doe',
    email: 'john@example.com',
    age: 30
  })
})
```

**Critical requirement:** The `body` must be a string. `JSON.stringify()` converts JavaScript objects to JSON strings.

**Common error:**

```javascript
// INCORRECT - will fail or send "[object Object]"
body: { name: 'John' }

// CORRECT
body: JSON.stringify({ name: 'John' })
```

### Response Parsing

**Standard response handling:**

```javascript
fetch('https://api.example.com/users/123')
  .then(response => response.json())
  .then(data => {
    console.log(data.name);
  })
```

**The `.json()` method:**

- Returns a Promise
- Parses response body as JSON
- Throws on invalid JSON
- Consumes the response stream (can only be called once)

**Error handling for invalid JSON:**

```javascript
fetch('https://api.example.com/data')
  .then(response => {
    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }
    return response.json();
  })
  .then(data => console.log(data))
  .catch(error => {
    // Could be network error, HTTP error, or JSON parsing error
    console.error('Error:', error);
  });
```

### Content-Type Header Behavior

**Automatic vs manual setting:**

```javascript
// Fetch does NOT automatically set Content-Type for JSON
fetch(url, {
  method: 'POST',
  body: JSON.stringify(data)
  // Content-Type header NOT set - server may reject request
})

// Must explicitly set Content-Type
fetch(url, {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json'
  },
  body: JSON.stringify(data)
})
```

**Server expectations:** Most REST APIs require the `Content-Type: application/json` header. Without it:

- Some servers return 415 Unsupported Media Type
- Some servers accept but misparse the data
- Some servers default to JSON parsing

[Inference: Server behavior varies by framework and configuration. Best practice is always explicitly setting Content-Type.]

### Handling Different Data Types

#### Strings

```javascript
body: JSON.stringify({ message: "Hello world" })
// Result: {"message":"Hello world"}
```

#### Numbers

```javascript
body: JSON.stringify({ age: 30, price: 19.99 })
// Result: {"age":30,"price":19.99}
```

#### Booleans

```javascript
body: JSON.stringify({ active: true, verified: false })
// Result: {"active":true,"verified":false}
```

#### Null

```javascript
body: JSON.stringify({ middleName: null })
// Result: {"middleName":null}
```

#### Undefined Behavior

```javascript
body: JSON.stringify({ name: "John", nickname: undefined })
// Result: {"name":"John"}
// undefined values are OMITTED
```

#### Arrays

```javascript
body: JSON.stringify({ tags: ['javascript', 'fetch', 'api'] })
// Result: {"tags":["javascript","fetch","api"]}
```

#### Nested Objects

```javascript
body: JSON.stringify({
  user: {
    name: 'John',
    address: {
      city: 'New York',
      zip: '10001'
    }
  }
})
```

#### Dates

```javascript
const data = { created: new Date('2024-01-15') };
body: JSON.stringify(data)
// Result: {"created":"2024-01-15T00:00:00.000Z"}
// Dates serialize to ISO 8601 strings
```

**Parsing dates on response:**

```javascript
fetch(url)
  .then(res => res.json())
  .then(data => {
    // data.created is a STRING, not a Date object
    const dateObj = new Date(data.created);
  })
```

### Special JSON.stringify Behaviors

#### The Replacer Parameter

```javascript
// Filter which properties to include
JSON.stringify(obj, ['name', 'email'])

// Transform values during serialization
JSON.stringify(obj, (key, value) => {
  if (key === 'password') return undefined; // Omit passwords
  return value;
})
```

#### The Space Parameter

```javascript
// Pretty-print for debugging (not for production requests)
JSON.stringify(data, null, 2)
```

**Production usage:** Always use `JSON.stringify(data)` without spacing to minimize payload size.

#### toJSON Method

Objects can define custom JSON serialization:

```javascript
class User {
  constructor(name, password) {
    this.name = name;
    this.password = password;
  }
  
  toJSON() {
    return { name: this.name }; // Exclude password
  }
}

const user = new User('John', 'secret123');
JSON.stringify(user)
// Result: {"name":"John"}
```

### Request Body Size Considerations

**Browser limits:** [Inference: Most browsers impose memory-based limits on request bodies, typically in the range of hundreds of MB to several GB, though practical limits are lower due to performance degradation.]

**Server limits:** Commonly configured to reject bodies exceeding:

- 1-2 MB for typical API requests
- 10-50 MB for file upload endpoints
- Configurable per-endpoint

**Checking payload size:**

```javascript
const payload = JSON.stringify(data);
const sizeInBytes = new Blob([payload]).size;
const sizeInKB = sizeInBytes / 1024;

if (sizeInKB > 1024) {
  console.warn('Payload exceeds 1MB');
}
```

**Optimization strategies:**

- Pagination for large datasets
- Field filtering (sparse fieldsets)
- Compression (not directly in fetch, but server-side with Content-Encoding)
- Chunked requests for bulk operations

### Error Handling Patterns

#### Checking Response Status Before Parsing

```javascript
fetch(url, {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify(data)
})
.then(response => {
  if (!response.ok) {
    // Response body might still contain JSON error details
    return response.json().then(err => {
      throw new Error(err.message || `HTTP ${response.status}`);
    }).catch(() => {
      // JSON parsing failed, use status text
      throw new Error(`HTTP ${response.status}: ${response.statusText}`);
    });
  }
  return response.json();
})
.then(data => console.log('Success:', data))
.catch(error => console.error('Error:', error));
```

#### Handling Non-JSON Responses

```javascript
fetch(url)
  .then(response => {
    const contentType = response.headers.get('content-type');
    if (contentType && contentType.includes('application/json')) {
      return response.json();
    }
    // Server sent non-JSON response
    return response.text().then(text => {
      throw new Error(`Expected JSON, got: ${text}`);
    });
  })
```

#### Empty Response Bodies

```javascript
fetch(url, { method: 'DELETE' })
  .then(response => {
    if (response.status === 204) {
      // No Content - don't try to parse JSON
      return null;
    }
    return response.json();
  })
```

### Advanced Request Patterns

#### Conditional Requests

```javascript
fetch(url, {
  method: 'PUT',
  headers: {
    'Content-Type': 'application/json',
    'If-Match': '"etag-value"' // Optimistic locking
  },
  body: JSON.stringify(data)
})
```

#### Partial Updates (PATCH)

```javascript
// Send only changed fields
fetch(`https://api.example.com/users/${userId}`, {
  method: 'PATCH',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    email: 'newemail@example.com'
    // Other fields unchanged
  })
})
```

#### Batch Requests

```javascript
// Some APIs support batching multiple operations
fetch('https://api.example.com/batch', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    operations: [
      { method: 'POST', path: '/users', body: { name: 'User 1' } },
      { method: 'POST', path: '/users', body: { name: 'User 2' } },
      { method: 'GET', path: '/users/123' }
    ]
  })
})
```

### CORS and JSON Requests

**Preflight triggers:** Complex JSON requests trigger CORS preflight (OPTIONS request) when:

- Using methods other than GET, POST, HEAD
- Including custom headers beyond simple headers
- Content-Type is `application/json` (not a simple content type)

**Simple vs preflighted:**

```javascript
// Triggers preflight (application/json is not simple)
fetch(url, {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify(data)
})

// Also triggers preflight (custom header)
fetch(url, {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'X-Custom-Header': 'value'
  },
  body: JSON.stringify(data)
})
```

**Server CORS requirements for JSON APIs:**

```
Access-Control-Allow-Origin: https://example.com
Access-Control-Allow-Methods: POST, PUT, PATCH, DELETE
Access-Control-Allow-Headers: Content-Type, Authorization
Access-Control-Max-Age: 86400
```

### Credentials and Authentication

#### Including Authentication Headers

```javascript
fetch(url, {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer ' + token
  },
  body: JSON.stringify(data)
})
```

#### Cookies with Credentials

```javascript
fetch(url, {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify(data),
  credentials: 'include' // Send cookies cross-origin
})
```

**CORS requirements with credentials:**

- Server must respond with `Access-Control-Allow-Credentials: true`
- `Access-Control-Allow-Origin` cannot be `*` (must be specific origin)

### Streaming and Large Payloads

**Standard fetch limitation:** The entire body must be in memory before sending.

**Workaround for large data:**

```javascript
// Break into smaller requests
const chunks = largeArray.reduce((acc, item, idx) => {
  const chunkIdx = Math.floor(idx / 100);
  if (!acc[chunkIdx]) acc[chunkIdx] = [];
  acc[chunkIdx].push(item);
  return acc;
}, []);

for (const chunk of chunks) {
  await fetch(url, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(chunk)
  });
}
```

**ReadableStream for request bodies:** Newer browsers support streaming request bodies:

```javascript
const stream = new ReadableStream({
  start(controller) {
    // Push chunks
    controller.enqueue(new TextEncoder().encode(JSON.stringify(chunk1)));
    controller.enqueue(new TextEncoder().encode(JSON.stringify(chunk2)));
    controller.close();
  }
});

fetch(url, {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: stream,
  duplex: 'half' // Required for streaming requests
})
```

[Unverified: Browser support for streaming request bodies varies. Not all browsers support duplex streams.]

### Response Streaming

**Reading JSON responses incrementally:**

```javascript
const response = await fetch(url);
const reader = response.body.getReader();
const decoder = new TextDecoder();
let buffer = '';

while (true) {
  const { done, value } = await reader.read();
  
  if (done) break;
  
  buffer += decoder.decode(value, { stream: true });
  
  // Attempt to parse complete JSON objects from buffer
  // (Requires NDJSON or similar line-delimited format)
  const lines = buffer.split('\n');
  buffer = lines.pop(); // Keep incomplete line in buffer
  
  for (const line of lines) {
    if (line.trim()) {
      const jsonObj = JSON.parse(line);
      console.log('Received:', jsonObj);
    }
  }
}
```

### JSON Parsing Edge Cases

#### Large Numbers

```javascript
const data = { bigNumber: 9007199254740992 }; // Beyond safe integer
fetch(url, {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify(data)
})
// Loss of precision possible for integers > 2^53 - 1
```

**Mitigation:** Send large numbers as strings:

```javascript
body: JSON.stringify({ bigNumber: "9007199254740992" })
```

#### Circular References

```javascript
const obj = { name: 'John' };
obj.self = obj; // Circular reference

JSON.stringify(obj)
// Throws: TypeError: Converting circular structure to JSON
```

**Detection before serialization:**

```javascript
function hasCircularReference(obj, seen = new WeakSet()) {
  if (obj !== null && typeof obj === 'object') {
    if (seen.has(obj)) return true;
    seen.add(obj);
    for (let key in obj) {
      if (hasCircularReference(obj[key], seen)) return true;
    }
  }
  return false;
}
```

#### Symbol Properties

```javascript
const obj = { name: 'John', [Symbol('id')]: 123 };
JSON.stringify(obj)
// Result: {"name":"John"}
// Symbol properties are IGNORED
```

#### Function Properties

```javascript
const obj = { name: 'John', greet: function() { return 'Hello'; } };
JSON.stringify(obj)
// Result: {"name":"John"}
// Function properties are OMITTED
```

### Content Negotiation

**Requesting JSON responses:**

```javascript
fetch(url, {
  headers: {
    'Accept': 'application/json'
  }
})
```

**Handling multiple possible response formats:**

```javascript
fetch(url, {
  headers: {
    'Accept': 'application/json, application/xml;q=0.9'
  }
})
.then(response => {
  const contentType = response.headers.get('content-type');
  if (contentType.includes('application/json')) {
    return response.json();
  } else if (contentType.includes('application/xml')) {
    return response.text(); // Parse XML separately
  }
})
```

### Abort Controllers and Timeouts

**Aborting JSON requests:**

```javascript
const controller = new AbortController();

fetch(url, {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify(data),
  signal: controller.signal
})
.catch(error => {
  if (error.name === 'AbortError') {
    console.log('Request aborted');
  }
});

// Abort after timeout
setTimeout(() => controller.abort(), 5000);
```

**Request timeout wrapper:**

```javascript
function fetchWithTimeout(url, options, timeout = 5000) {
  const controller = new AbortController();
  const timeoutId = setTimeout(() => controller.abort(), timeout);
  
  return fetch(url, {
    ...options,
    signal: controller.signal
  }).finally(() => {
    clearTimeout(timeoutId);
  });
}

fetchWithTimeout(url, {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify(data)
}, 10000)
```

### Performance Optimization

#### Reusing Headers Objects

```javascript
const jsonHeaders = new Headers({
  'Content-Type': 'application/json',
  'Accept': 'application/json'
});

// Reuse for multiple requests
fetch(url1, { method: 'POST', headers: jsonHeaders, body: JSON.stringify(data1) });
fetch(url2, { method: 'POST', headers: jsonHeaders, body: JSON.stringify(data2) });
```

#### Caching Serialized Payloads

```javascript
// Avoid repeated serialization
const serializedData = JSON.stringify(largeObject);

// Use same serialized string for multiple requests
fetch(url1, { method: 'POST', headers: jsonHeaders, body: serializedData });
fetch(url2, { method: 'POST', headers: jsonHeaders, body: serializedData });
```

#### HTTP Caching for GET Requests

```javascript
fetch(url, {
  headers: { 'Accept': 'application/json' },
  cache: 'default' // Use browser cache
})
```

**Cache modes:**

- `default`: Standard cache behavior
- `no-store`: Bypass cache completely
- `reload`: Bypass cache, update cache with response
- `no-cache`: Validate with server before using cached response
- `force-cache`: Use cache if available, even if stale
- `only-if-cached`: Use only cached response, fail if not cached

### Request Cloning

**Cloning for retry logic:**

```javascript
async function fetchWithRetry(url, options, retries = 3) {
  for (let i = 0; i < retries; i++) {
    try {
      const response = await fetch(url, options);
      if (response.ok) return response;
    } catch (error) {
      if (i === retries - 1) throw error;
      await new Promise(resolve => setTimeout(resolve, 1000 * (i + 1)));
    }
  }
}
```

**Body consumption limitation:** Request bodies can only be read once. For retry scenarios, store the serialized body:

```javascript
const body = JSON.stringify(data);

async function attemptRequest() {
  return fetch(url, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: body // Reuse string
  });
}
```

### Security Considerations

#### Sensitive Data in Requests

```javascript
// AVOID: Logging full request bodies
console.log('Sending:', JSON.stringify(data));

// BETTER: Log without sensitive fields
const safeData = { ...data };
delete safeData.password;
delete safeData.creditCard;
console.log('Sending:', JSON.stringify(safeData));
```

#### Response Size Validation

```javascript
fetch(url)
  .then(response => {
    const contentLength = response.headers.get('content-length');
    if (contentLength && parseInt(contentLength) > 5000000) {
      throw new Error('Response too large');
    }
    return response.json();
  })
```

#### JSON Injection Protection

Server-side concern primarily, but clients should validate response structure:

```javascript
fetch(url)
  .then(res => res.json())
  .then(data => {
    // Validate expected structure
    if (typeof data.id !== 'number' || typeof data.name !== 'string') {
      throw new Error('Invalid response structure');
    }
    // Use data
  })
```

### Browser Compatibility

**Fetch API support:** Modern browsers (2015+). For older browsers, polyfills required.

**JSON methods:** `JSON.stringify()` and `JSON.parse()` have near-universal support (IE8+).

**Modern features with limited support:**

- Streaming request bodies: Limited browser support
- `keepalive` option: Not supported in all browsers
- `duplex` option: Required for streaming, new feature

[Unverified: Exact browser version requirements vary. Check compatibility tables for production use.]

---

## URLSearchParams

### Interface Overview

URLSearchParams provides a dedicated API for manipulating URL query strings, replacing manual string parsing and concatenation. The interface operates on key-value pairs representing query parameters, handling encoding, serialization, and multi-value scenarios automatically.

The constructor accepts multiple input formats: query strings (with or without the leading `?`), objects with string properties, arrays of `[key, value]` tuples, or existing URLSearchParams instances for cloning.

```javascript
// From query string
const params1 = new URLSearchParams('?name=value&another=test');
const params2 = new URLSearchParams('name=value&another=test'); // Leading ? optional

// From object
const params3 = new URLSearchParams({
  name: 'value',
  another: 'test'
});

// From array of pairs
const params4 = new URLSearchParams([
  ['name', 'value'],
  ['another', 'test']
]);

// From existing URLSearchParams
const params5 = new URLSearchParams(params1);
```

URLSearchParams instances are mutable—all modification methods alter the object in place rather than returning new instances.

### Core Manipulation Methods

The `append(name, value)` method adds a parameter without removing existing parameters with the same name, enabling multiple values per key. Parameters append in the order they're added.

```javascript
const params = new URLSearchParams();
params.append('tag', 'javascript');
params.append('tag', 'web');
params.append('tag', 'api');
// Results in: tag=javascript&tag=web&tag=api
```

The `set(name, value)` method replaces all existing parameters with the given name, ensuring exactly one value exists for that key. If multiple values existed, all are removed and replaced with the single new value.

```javascript
params.set('tag', 'tutorial');
// Now: tag=tutorial (previous values removed)
```

The `delete(name)` method removes all parameters matching the name, regardless of how many values exist.

```javascript
params.delete('tag');
// All 'tag' parameters removed
```

The `delete(name, value)` overload (added in more recent specifications) removes only parameters matching both name and value, preserving other values for the same name:

```javascript
params.append('color', 'red');
params.append('color', 'blue');
params.append('color', 'green');
params.delete('color', 'blue');
// Results in: color=red&color=green
```

[Unverified] The two-argument `delete()` overload may have limited browser support as of late 2024—checking compatibility is advisable.

### Retrieval Methods

The `get(name)` method returns the first value associated with the parameter name, or `null` if the parameter doesn't exist.

```javascript
params.append('status', 'active');
params.append('status', 'pending');
console.log(params.get('status')); // 'active'
console.log(params.get('missing')); // null
```

The `getAll(name)` method returns an array of all values for the parameter, returning an empty array if the parameter doesn't exist.

```javascript
console.log(params.getAll('status')); // ['active', 'pending']
console.log(params.getAll('missing')); // []
```

The `has(name)` method checks parameter existence without retrieving values, returning a boolean.

```javascript
if (params.has('status')) {
  // Parameter exists with at least one value
}
```

The `has(name, value)` overload (added in more recent specifications) checks whether a specific name-value pair exists:

```javascript
params.has('status', 'active'); // true
params.has('status', 'completed'); // false
```

[Unverified] The two-argument `has()` overload may have limited browser support as of late 2024.

### Iteration and Enumeration

URLSearchParams implements the iterable protocol, making instances directly iterable with `for...of` loops. Iteration yields `[name, value]` pairs in insertion order.

```javascript
const params = new URLSearchParams('a=1&b=2&a=3');
for (const [key, value] of params) {
  console.log(`${key} = ${value}`);
}
// Output:
// a = 1
// b = 2
// a = 3
```

The `entries()` method returns an iterator of `[name, value]` pairs, equivalent to the default iteration:

```javascript
for (const [key, value] of params.entries()) {
  // Same as direct iteration
}
```

The `keys()` method returns an iterator of parameter names, including duplicates for repeated parameters:

```javascript
const params = new URLSearchParams('a=1&b=2&a=3');
for (const key of params.keys()) {
  console.log(key);
}
// Output: a, b, a (duplicates included)
```

The `values()` method returns an iterator of parameter values in order:

```javascript
for (const value of params.values()) {
  console.log(value);
}
// Output: 1, 2, 3
```

The `forEach(callback)` method provides callback-based iteration, invoking the callback with `(value, key, params)` arguments:

```javascript
params.forEach((value, key) => {
  console.log(`${key} = ${value}`);
});
```

The parameter order follows the Map convention where value precedes key in the callback signature, despite the reversed order in array destructuring.

### Serialization

The `toString()` method serializes parameters to a query string without the leading `?` character. The method applies percent-encoding to names and values according to the `application/x-www-form-urlencoded` specification.

```javascript
const params = new URLSearchParams();
params.set('search', 'hello world');
params.set('category', 'news & updates');
console.log(params.toString());
// 'search=hello+world&category=news+%26+updates'
```

Serialization maintains the parameter order established through `append()` and `set()` operations. Empty values serialize as name-only with an equals sign:

```javascript
params.set('empty', '');
console.log(params.toString()); // 'empty='
```

Parameters with `undefined` or `null` values convert to the strings `'undefined'` and `'null'`:

```javascript
params.set('undef', undefined);
params.set('nothing', null);
console.log(params.toString());
// 'undef=undefined&nothing=null'
```

[Inference] This string conversion of undefined and null may cause unexpected behavior—filtering these values before setting parameters prevents unintended serialization.

The serialized output doesn't include the `?` prefix, requiring manual addition when constructing complete URLs:

```javascript
const url = `https://example.com/search?${params.toString()}`;
```

### Encoding Behavior

URLSearchParams applies `application/x-www-form-urlencoded` encoding, which differs from standard percent-encoding in several ways. Spaces encode as `+` characters rather than `%20`:

```javascript
const params = new URLSearchParams();
params.set('name', 'first last');
console.log(params.toString()); // 'name=first+last'
```

The encoding targets the serialized output—accessing values through `get()` returns decoded strings with spaces, not plus signs:

```javascript
console.log(params.get('name')); // 'first last'
```

Reserved characters in parameter names and values receive percent-encoding:

```javascript
params.set('key&special', 'value=test');
console.log(params.toString());
// 'key%26special=value%3Dtest'
```

Non-ASCII characters encode as UTF-8 byte sequences with each byte percent-encoded:

```javascript
params.set('name', '日本語');
console.log(params.toString());
// 'name=%E6%97%A5%E6%9C%AC%E8%AA%9E'
```

The encoding differs from `encodeURIComponent()`, which follows RFC 3986 and encodes spaces as `%20`. Characters like `!`, `'`, `(`, `)`, `*`, and `~` remain unencoded in URLSearchParams but encode with `encodeURIComponent()`:

```javascript
params.set('special', "it's (really) ok!");
console.log(params.toString());
// "special=it's+(really)+ok!"

console.log(encodeURIComponent("it's (really) ok!"));
// "it's%20%28really%29%20ok%21"
```

### Parameter Ordering

URLSearchParams preserves insertion order for parameters. The order reflects the sequence of `append()` and `set()` calls:

```javascript
const params = new URLSearchParams();
params.append('z', '1');
params.append('a', '2');
params.append('m', '3');
console.log(params.toString()); // 'z=1&a=2&m=3'
```

The `sort()` method arranges parameters alphabetically by name, modifying the instance in place:

```javascript
params.sort();
console.log(params.toString()); // 'a=2&m=3&z=1'
```

Parameters with the same name remain grouped together after sorting, maintaining their relative order:

```javascript
params.append('a', '4');
params.sort();
console.log(params.toString()); // 'a=2&a=4&m=3&z=1'
```

Sorting enables consistent URL generation for cache keys or canonical URLs where parameter order shouldn't affect equivalence:

```javascript
function normalizeUrl(url) {
  const parsed = new URL(url);
  parsed.searchParams.sort();
  return parsed.toString();
}
```

### Multi-Value Parameters

URLSearchParams natively supports multiple values per parameter name through repeated `append()` calls. This design accommodates array-like parameters common in REST APIs:

```javascript
const params = new URLSearchParams();
params.append('filter', 'active');
params.append('filter', 'verified');
params.append('filter', 'premium');
// Results in: filter=active&filter=verified&filter=premium
```

Retrieving all values requires `getAll()`, which returns an array:

```javascript
const filters = params.getAll('filter');
// ['active', 'verified', 'premium']
```

Using `get()` returns only the first value:

```javascript
const firstFilter = params.get('filter'); // 'active'
```

The `set()` method replaces all existing values, useful for resetting a parameter:

```javascript
params.set('filter', 'newValue');
console.log(params.getAll('filter')); // ['newValue']
```

Removing individual values while preserving others requires the two-argument `delete()` overload or manual reconstruction:

```javascript
// Manual approach (universal compatibility)
const values = params.getAll('filter').filter(v => v !== 'verified');
params.delete('filter');
values.forEach(v => params.append('filter', v));
```

### Constructor Input Handling

When constructing from objects, only own enumerable string properties are considered. Non-string values convert to strings:

```javascript
const params = new URLSearchParams({
  string: 'text',
  number: 42,
  boolean: true,
  object: { nested: 'value' }
});

console.log(params.get('number')); // '42'
console.log(params.get('boolean')); // 'true'
console.log(params.get('object')); // '[object Object]'
```

[Inference] Object values serialize via `toString()`, typically producing `'[object Object]'` for plain objects—this behavior is rarely useful, suggesting explicit serialization before construction.

Arrays in object values don't automatically expand to multiple parameters:

```javascript
const params = new URLSearchParams({
  tags: ['js', 'web', 'api']
});
console.log(params.get('tags')); // 'js,web,api' (joined, not separate)
```

Proper multi-value handling requires array-of-pairs construction or explicit appending:

```javascript
const tags = ['js', 'web', 'api'];
const params = new URLSearchParams(
  tags.map(tag => ['tags', tag])
);
```

When constructing from strings, the leading `?` is automatically stripped if present:

```javascript
const params1 = new URLSearchParams('?a=1&b=2');
const params2 = new URLSearchParams('a=1&b=2');
// Both produce identical results
```

Malformed query strings parse permissively. Missing values default to empty strings:

```javascript
const params = new URLSearchParams('key1&key2=value2');
console.log(params.get('key1')); // ''
console.log(params.get('key2')); // 'value2'
```

### Size and Content Checking

URLSearchParams provides no direct `size` or `length` property. Counting parameters requires iteration:

```javascript
function countParams(params) {
  let count = 0;
  for (const _ of params) count++;
  return count;
}

// Or using Array conversion
const count = Array.from(params).length;
```

Checking for empty parameter sets:

```javascript
function isEmpty(params) {
  for (const _ of params) return false;
  return true;
}

// Or checking serialization
const isEmpty = params.toString() === '';
```

Getting unique parameter names requires deduplication:

```javascript
function getUniqueKeys(params) {
  return [...new Set(params.keys())];
}
```

Counting values per parameter:

```javascript
function countValues(params, name) {
  return params.getAll(name).length;
}
```

### Integration with Fetch API

URLSearchParams integrates directly with fetch for POST requests with form-encoded bodies. Passing a URLSearchParams instance as the body automatically sets the `Content-Type` header to `application/x-www-form-urlencoded`:

```javascript
const params = new URLSearchParams();
params.set('username', 'user123');
params.set('password', 'secret');

fetch('/login', {
  method: 'POST',
  body: params
  // Content-Type automatically set
});
```

For GET requests, URLSearchParams constructs query strings:

```javascript
const params = new URLSearchParams({
  search: 'javascript',
  limit: '10'
});

fetch(`/api/search?${params.toString()}`);
```

Combining base URLs with parameters:

```javascript
const url = new URL('https://api.example.com/search');
url.search = params.toString();
fetch(url);
```

### Case Sensitivity

Parameter names are case-sensitive. Parameters differing only in case are distinct:

```javascript
params.set('Name', 'value1');
params.set('name', 'value2');
console.log(params.get('Name')); // 'value1'
console.log(params.get('name')); // 'value2'
console.log(params.toString()); // 'Name=value1&name=value2'
```

This differs from HTTP header behavior where header names are case-insensitive. Server-side frameworks may normalize parameter names, but URLSearchParams preserves exact casing.

### Comparison and Equality

URLSearchParams instances don't provide built-in equality comparison. Two instances with identical parameters aren't considered equal:

```javascript
const params1 = new URLSearchParams('a=1&b=2');
const params2 = new URLSearchParams('a=1&b=2');
console.log(params1 === params2); // false
```

Comparing parameter sets requires serialization comparison:

```javascript
function paramsEqual(p1, p2) {
  return p1.toString() === p2.toString();
}
```

This comparison is order-sensitive. For order-independent comparison, sort before comparing:

```javascript
function paramsEqualUnordered(p1, p2) {
  const c1 = new URLSearchParams(p1);
  const c2 = new URLSearchParams(p2);
  c1.sort();
  c2.sort();
  return c1.toString() === c2.toString();
}
```

### Cloning and Immutability

URLSearchParams instances are mutable. Creating independent copies requires explicit cloning through the constructor:

```javascript
const original = new URLSearchParams('a=1&b=2');
const copy = new URLSearchParams(original);

copy.set('c', '3');
console.log(original.toString()); // 'a=1&b=2' (unchanged)
console.log(copy.toString()); // 'a=1&b=2&c=3'
```

Functional approaches to parameter building maintain immutability:

```javascript
function withParam(params, key, value) {
  const newParams = new URLSearchParams(params);
  newParams.set(key, value);
  return newParams;
}

function withoutParam(params, key) {
  const newParams = new URLSearchParams(params);
  newParams.delete(key);
  return newParams;
}
```

Chaining immutable operations:

```javascript
const params = new URLSearchParams();
const final = [
  ['a', '1'],
  ['b', '2'],
  ['c', '3']
].reduce((p, [k, v]) => withParam(p, k, v), params);
```

### Parsing Edge Cases

URLSearchParams handles various edge cases in query string parsing:

**Empty parameters:**

```javascript
const params = new URLSearchParams('a=&b=value');
console.log(params.get('a')); // '' (empty string)
console.log(params.has('a')); // true
```

**Parameters without equals signs:**

```javascript
const params = new URLSearchParams('flag&other=value');
console.log(params.get('flag')); // '' (empty string)
console.log(params.has('flag')); // true
```

**Repeated equals signs:**

```javascript
const params = new URLSearchParams('key=value=extra');
console.log(params.get('key')); // 'value=extra'
```

**Empty query strings:**

```javascript
const params = new URLSearchParams('');
console.log(params.toString()); // '' (empty)
for (const _ of params) {} // No iterations
```

**Ampersand sequences:**

```javascript
const params = new URLSearchParams('a=1&&b=2');
// Empty parameter created between ampersands
console.log(Array.from(params)); // [['a','1'], ['',''], ['b','2']]
```

### Conversion to Other Formats

Converting URLSearchParams to plain objects requires explicit iteration, as no built-in method exists:

```javascript
function toObject(params) {
  const obj = {};
  for (const [key, value] of params) {
    if (obj[key]) {
      // Handle multi-value parameters
      if (Array.isArray(obj[key])) {
        obj[key].push(value);
      } else {
        obj[key] = [obj[key], value];
      }
    } else {
      obj[key] = value;
    }
  }
  return obj;
}
```

Simpler conversion that keeps only first values:

```javascript
function toSimpleObject(params) {
  const obj = {};
  for (const [key, value] of params) {
    if (!(key in obj)) {
      obj[key] = value;
    }
  }
  return obj;
}
```

Converting to JSON requires serialization to object first:

```javascript
const jsonString = JSON.stringify(toObject(params));
```

Converting to Map structures:

```javascript
// Single-value Map
const map = new Map(params);

// Multi-value Map
const multiMap = new Map();
for (const [key, value] of params) {
  if (!multiMap.has(key)) {
    multiMap.set(key, []);
  }
  multiMap.get(key).push(value);
}
```

### Working with FormData

Converting between URLSearchParams and FormData enables different encoding strategies. URLSearchParams uses `application/x-www-form-urlencoded`, while FormData uses `multipart/form-data`.

**URLSearchParams to FormData:**

```javascript
const params = new URLSearchParams('name=value&other=test');
const formData = new FormData();
for (const [key, value] of params) {
  formData.append(key, value);
}
```

**FormData to URLSearchParams:**

```javascript
const formData = new FormData();
formData.append('name', 'value');
formData.append('file', fileBlob);

const params = new URLSearchParams();
for (const [key, value] of formData) {
  // Only string values convert cleanly
  if (typeof value === 'string') {
    params.append(key, value);
  }
}
```

[Inference] File objects in FormData don't convert to URLSearchParams since binary data isn't representable in URL-encoded format. The conversion only preserves text fields.

### Performance Considerations

[Inference] URLSearchParams operations maintain insertion order, suggesting underlying implementations may use ordered data structures (arrays or linked lists) rather than hash maps. This affects performance characteristics for large parameter sets.

Repeated `get()` operations on parameter sets with many duplicate names scan linearly to find the first match. For frequent lookups, caching results or using Map-based structures may improve performance:

```javascript
// Caching first values
const cache = new Map();
for (const [key, value] of params) {
  if (!cache.has(key)) {
    cache.set(key, value);
  }
}
// Subsequent lookups use cache.get(key)
```

The `toString()` method serializes the entire parameter set, potentially expensive for large sets called repeatedly. Caching serialized strings when parameters are stable avoids redundant work:

```javascript
let cachedString = null;
function getCachedString(params) {
  if (!cachedString) {
    cachedString = params.toString();
  }
  return cachedString;
}
```

### Browser and Environment Support

URLSearchParams achieved widespread browser support by 2016, with polyfills available for older environments. The API works identically in browsers and Node.js (native support since Node.js 10).

[Unverified] Recent additions like the two-argument `delete()` and `has()` overloads may not have universal support across all environments as of late 2024.

Node.js provides URLSearchParams through the `url` module:

```javascript
const { URLSearchParams } = require('url');
// Or with ES modules
import { URLSearchParams } from 'url';
```

The browser global `URLSearchParams` and Node.js implementation maintain API compatibility, though internal implementation details may differ.

### Common Patterns and Utilities

**Filtering parameters:**

```javascript
function filterParams(params, predicate) {
  const filtered = new URLSearchParams();
  for (const [key, value] of params) {
    if (predicate(key, value)) {
      filtered.append(key, value);
    }
  }
  return filtered;
}

// Example: remove empty values
const cleaned = filterParams(params, (key, value) => value !== '');
```

**Merging parameter sets:**

```javascript
function mergeParams(...paramSets) {
  const merged = new URLSearchParams();
  for (const params of paramSets) {
    for (const [key, value] of params) {
      merged.append(key, value);
    }
  }
  return merged;
}
```

**Transforming values:**

```javascript
function mapValues(params, transform) {
  const mapped = new URLSearchParams();
  for (const [key, value] of params) {
    mapped.append(key, transform(value, key));
  }
  return mapped;
}

// Example: trim all values
const trimmed = mapValues(params, v => v.trim());
```

**Default values:**

```javascript
function withDefaults(params, defaults) {
  const result = new URLSearchParams(params);
  for (const [key, value] of Object.entries(defaults)) {
    if (!result.has(key)) {
      result.set(key, value);
    }
  }
  return result;
}
```

---

## Blob and File Objects

### Blob Interface

The Blob interface represents a blob, which is a file-like object of immutable, raw data; they can be read as text or binary data, or converted into a ReadableStream so its methods can be used for processing the data.

**Key characteristics:**

- Immutable raw data
- Blobs can represent data that isn't necessarily in a JavaScript-native format
- Can be used anywhere binary data is needed

---

### Blob Constructor

#### Syntax

```javascript
new Blob()
new Blob(blobParts)
new Blob(blobParts, options)
```

#### Parameters

##### `blobParts` (optional)

An iterable object such as an Array, having ArrayBuffers, TypedArrays, DataViews, Blobs, strings, or a mix of any of such elements, that will be put inside the Blob

**Accepted types:**

- `ArrayBuffer`
- `TypedArray` (Uint8Array, Int32Array, etc.)
- `DataView`
- `Blob` (nested blobs)
- `String` - Strings should be well-formed Unicode, and lone surrogates are sanitized using the same algorithm as String.prototype.toWellFormed()

##### `options` (optional)

**Properties:**

- **`type`** (string) - The MIME type of the data that will be stored into the blob. The default value is the empty string, ("")
    
- **`endings`** (string) - How to interpret newline characters (\n) within the contents, if the data is text. The default value, transparent, copies newline characters into the blob without changing them. To convert newlines to the host system's native convention, specify the value native
    

**Values for `endings`:**

- `"transparent"` (default) - No conversion
- `"native"` - Converts `\n` to platform-specific line endings

#### Return Value

A new Blob object containing the specified data

#### Examples

```javascript
// From string
const blob1 = new Blob(['Hello, world!'], { type: 'text/plain' });

// From JSON
const obj = { hello: 'world' };
const blob2 = new Blob([JSON.stringify(obj, null, 2)], {
  type: 'application/json'
});

// From typed array
const bytes = new Uint8Array([72, 101, 108, 108, 111]); // "Hello"
const blob3 = new Blob([bytes], { type: 'application/octet-stream' });

// From ArrayBuffer
const buffer = new ArrayBuffer(8);
const blob4 = new Blob([buffer]);

// Multiple parts
const blob5 = new Blob(
  ['<html>', '<body>Content</body>', '</html>'],
  { type: 'text/html' }
);

// Mixed types
const blob6 = new Blob(
  ['String part ', new Uint8Array([65, 66, 67]), ' more text'],
  { type: 'text/plain' }
);

// From another Blob
const blob7 = new Blob([blob1, blob2]);
```

---

### Blob Instance Properties

#### `size` (Read-only)

**Type:** Number  
The size, in bytes, of the data contained in the Blob object

```javascript
const blob = new Blob(['Hello, world!']);
console.log(blob.size); // 13
```

#### `type` (Read-only)

**Type:** String  
A string indicating the MIME type of the data contained in the Blob. If the type is unknown, this string is empty

```javascript
const blob1 = new Blob(['{}'], { type: 'application/json' });
console.log(blob1.type); // 'application/json'

const blob2 = new Blob(['data']);
console.log(blob2.type); // '' (empty string)
```

---

### Blob Instance Methods

#### `arrayBuffer()`

Returns a promise that resolves with an ArrayBuffer containing the entire contents of the Blob as binary data

**Syntax:**

```javascript
arrayBuffer()
```

**Returns:** `Promise<ArrayBuffer>`

**Example:**

```javascript
const blob = new Blob(['Hello'], { type: 'text/plain' });

blob.arrayBuffer().then(buffer => {
  const uint8 = new Uint8Array(buffer);
  console.log(uint8); // Uint8Array(5) [72, 101, 108, 108, 111]
});

// With async/await
const buffer = await blob.arrayBuffer();
const bytes = new Uint8Array(buffer);
```

#### `bytes()`

Returns a promise that resolves with a Uint8Array containing the contents of the Blob

**Syntax:**

```javascript
bytes()
```

**Returns:** `Promise<Uint8Array>`

**Example:**

```javascript
const blob = new Blob(['Hello']);
const uint8Array = await blob.bytes();
console.log(uint8Array); // Uint8Array(5) [72, 101, 108, 108, 111]
```

#### `slice()`

Returns a new Blob object containing the data in the specified range of bytes of the blob on which it's called

**Syntax:**

```javascript
slice()
slice(start)
slice(start, end)
slice(start, end, contentType)
```

**Parameters:**

- `start` (optional) - Byte offset for start of slice (default: 0). Negative values count from the end
- `end` (optional) - Byte offset for end of slice, exclusive (default: blob.size)
- `contentType` (optional) - MIME type for new blob (default: empty string)

**Returns:** New `Blob` object

**Example:**

```javascript
const blob = new Blob(['Hello, world!'], { type: 'text/plain' });

// Get first 5 bytes
const slice1 = blob.slice(0, 5);
console.log(await slice1.text()); // 'Hello'

// Get last 6 bytes
const slice2 = blob.slice(-6);
console.log(await slice2.text()); // 'world!'

// Get middle portion with new type
const slice3 = blob.slice(7, 12, 'text/html');
console.log(slice3.type); // 'text/html'
console.log(await slice3.text()); // 'world'

// Negative indices
const slice4 = blob.slice(-6, -1);
console.log(await slice4.text()); // 'world'
```

#### `stream()`

Returns a ReadableStream that can be used to read the contents of the Blob

**Syntax:**

```javascript
stream()
```

**Returns:** `ReadableStream`

**Example:**

```javascript
const blob = new Blob(['Hello, world!']);
const stream = blob.stream();
const reader = stream.getReader();

while (true) {
  const { done, value } = await reader.read();
  if (done) break;
  console.log(value); // Uint8Array chunks
}

// Using with Response
const response = new Response(blob.stream());
const text = await response.text();
```

#### `text()`

Returns a promise that resolves with a string containing the entire contents of the Blob interpreted as UTF-8 text

**Syntax:**

```javascript
text()
```

**Returns:** `Promise<string>`

**Example:**

```javascript
const blob = new Blob(['Hello, world!'], { type: 'text/plain' });
const text = await blob.text();
console.log(text); // 'Hello, world!'

// With then()
blob.text().then(text => {
  console.log(text);
});
```

---

### File Interface

The File interface provides information about files and allows JavaScript in a web page to access their content

**Inheritance:**

- A File object is a specific kind of Blob, and can be used in any context that a Blob can
- The File interface also inherits properties from the Blob interface

**How Files are obtained:**

- File objects are generally retrieved from a FileList object returned as a result of a user selecting files using the <input> element, or from a drag and drop operation's DataTransfer object

---

### File Constructor

#### Syntax

```javascript
new File(fileParts, fileName)
new File(fileParts, fileName, options)
```

#### Parameters

##### `fileParts`

An iterable of `ArrayBuffer`, `TypedArray`, `DataView`, `Blob`, or string values (same as Blob constructor)

##### `fileName`

**Type:** String  
The name of the file

##### `options` (optional)

Extends Blob options with additional properties:

- **`type`** (string) - MIME type (default: `""`)
- **`endings`** (string) - Line ending handling: `"transparent"` or `"native"`
- **`lastModified`** (number) - Timestamp in milliseconds since Unix epoch (default: `Date.now()`)

#### Return Value

A newly constructed `File` object

#### Examples

```javascript
// Basic file creation
const file1 = new File(['Hello, world!'], 'hello.txt', {
  type: 'text/plain'
});

// With lastModified
const file2 = new File(
  ['Content'],
  'document.txt',
  {
    type: 'text/plain',
    lastModified: new Date('2024-01-01').getTime()
  }
);

// From typed array
const bytes = new Uint8Array([0xFF, 0xD8, 0xFF]); // JPEG header
const file3 = new File([bytes], 'image.jpg', {
  type: 'image/jpeg'
});

// From multiple parts
const file4 = new File(
  ['<html>', '<body>Test</body>', '</html>'],
  'page.html',
  { type: 'text/html' }
);

// From Blob
const blob = new Blob(['data']);
const file5 = new File([blob], 'data.bin');
```

---

### File Instance Properties

#### Inherited from Blob

- `size` - File size in bytes
- `type` - MIME type

#### File-specific Properties

##### `name` (Read-only)

**Type:** String  
Returns the name of the file referenced by the File object

```javascript
const file = new File(['content'], 'document.txt');
console.log(file.name); // 'document.txt'

// From input element
const input = document.querySelector('input[type="file"]');
input.addEventListener('change', (e) => {
  const file = e.target.files[0];
  console.log(file.name); // e.g., 'photo.jpg'
});
```

##### `lastModified` (Read-only)

**Type:** Number  
Returns the last modified time of the file, in millisecond since the UNIX epoch (January 1st, 1970 at Midnight)

```javascript
const file = new File(['content'], 'file.txt', {
  lastModified: Date.now()
});

console.log(file.lastModified); // e.g., 1703635200000
console.log(new Date(file.lastModified)); // Converted to Date object

// From user-selected file
input.addEventListener('change', (e) => {
  const file = e.target.files[0];
  const modDate = new Date(file.lastModified);
  console.log(`Last modified: ${modDate.toLocaleDateString()}`);
});
```

##### `webkitRelativePath` (Read-only)

**Type:** String  
Returns the path the URL of the File is relative to

This property is populated when a directory is selected using an `<input>` element with the `webkitdirectory` attribute.

```javascript
// HTML: <input type="file" webkitdirectory>
input.addEventListener('change', (e) => {
  const files = Array.from(e.target.files);
  files.forEach(file => {
    console.log(file.webkitRelativePath);
    // e.g., 'myFolder/subfolder/file.txt'
  });
});
```

##### `lastModifiedDate` (Deprecated, Non-standard)

**Type:** Date  
Returns the last modified Date. Use `lastModified` instead.

---

### Common Use Cases

#### Reading File Input

```javascript
const input = document.querySelector('input[type="file"]');

input.addEventListener('change', async (e) => {
  const file = e.target.files[0];
  
  if (file) {
    console.log('Name:', file.name);
    console.log('Size:', file.size, 'bytes');
    console.log('Type:', file.type);
    console.log('Last modified:', new Date(file.lastModified));
    
    // Read as text
    const text = await file.text();
    console.log('Content:', text);
    
    // Read as ArrayBuffer
    const buffer = await file.arrayBuffer();
    
    // Read as Data URL
    const reader = new FileReader();
    reader.onload = (e) => {
      console.log('Data URL:', e.target.result);
    };
    reader.readAsDataURL(file);
  }
});
```

#### Creating Object URLs

```javascript
const file = input.files[0];
const objectURL = URL.createObjectURL(file);

// Use in image
const img = document.createElement('img');
img.src = objectURL;
document.body.appendChild(img);

// Important: Clean up when done
img.onload = () => {
  URL.revokeObjectURL(objectURL);
};
```

#### Uploading Files with fetch()

```javascript
const file = input.files[0];

// Direct file upload
await fetch('/upload', {
  method: 'POST',
  headers: {
    'Content-Type': file.type
  },
  body: file
});

// With FormData
const formData = new FormData();
formData.append('file', file);
formData.append('description', 'My file');

await fetch('/upload', {
  method: 'POST',
  body: formData
});
```

#### Drag and Drop

```javascript
const dropZone = document.getElementById('drop-zone');

dropZone.addEventListener('dragover', (e) => {
  e.preventDefault();
  dropZone.classList.add('drag-over');
});

dropZone.addEventListener('dragleave', () => {
  dropZone.classList.remove('drag-over');
});

dropZone.addEventListener('drop', async (e) => {
  e.preventDefault();
  dropZone.classList.remove('drag-over');
  
  const files = Array.from(e.dataTransfer.files);
  
  for (const file of files) {
    console.log('Dropped:', file.name);
    // Process file
  }
});
```

#### Creating Blobs from Canvas

```javascript
const canvas = document.querySelector('canvas');

// As Blob
canvas.toBlob((blob) => {
  console.log('Canvas blob:', blob.size, 'bytes');
  
  // Create File from Blob
  const file = new File([blob], 'canvas-image.png', {
    type: 'image/png'
  });
  
  // Upload or download
  const url = URL.createObjectURL(file);
  const a = document.createElement('a');
  a.href = url;
  a.download = file.name;
  a.click();
  URL.revokeObjectURL(url);
}, 'image/png');
```

#### Chunked File Reading

```javascript
async function readFileInChunks(file, chunkSize = 1024 * 1024) {
  const chunks = [];
  let offset = 0;
  
  while (offset < file.size) {
    const chunk = file.slice(offset, offset + chunkSize);
    const buffer = await chunk.arrayBuffer();
    chunks.push(buffer);
    offset += chunkSize;
    
    // Report progress
    const progress = (offset / file.size) * 100;
    console.log(`Progress: ${progress.toFixed(2)}%`);
  }
  
  return chunks;
}

// Usage
const file = input.files[0];
const chunks = await readFileInChunks(file);
```

#### Converting Between Formats

```javascript
// Blob to File
const blob = new Blob(['content'], { type: 'text/plain' });
const file = new File([blob], 'converted.txt', {
  type: blob.type,
  lastModified: Date.now()
});

// File to Blob (already a Blob, but can clone)
const fileAsBlob = file.slice(0, file.size, file.type);

// Blob to ArrayBuffer
const buffer = await blob.arrayBuffer();

// ArrayBuffer to Blob
const newBlob = new Blob([buffer], { type: 'application/octet-stream' });

// Blob to Base64
const reader = new FileReader();
reader.onload = () => {
  const base64 = reader.result; // data:...;base64,xxx
};
reader.readAsDataURL(blob);

// Base64 to Blob
function base64ToBlob(base64, type = 'application/octet-stream') {
  const byteString = atob(base64.split(',')[1]);
  const ab = new ArrayBuffer(byteString.length);
  const ia = new Uint8Array(ab);
  
  for (let i = 0; i < byteString.length; i++) {
    ia[i] = byteString.charCodeAt(i);
  }
  
  return new Blob([ab], { type });
}
```

---

### APIs That Accept Blob/File

In particular, the following APIs accept both Blobs and File objects:

- FileReader
- URL.createObjectURL()
- Window.createImageBitmap() and WorkerGlobalScope.createImageBitmap()
- the body option to fetch()
- XMLHttpRequest.send()

---

### TypeScript Definitions

```typescript
interface Blob {
  readonly size: number;
  readonly type: string;
  
  arrayBuffer(): Promise<ArrayBuffer>;
  bytes(): Promise<Uint8Array>;
  slice(start?: number, end?: number, contentType?: string): Blob;
  stream(): ReadableStream<Uint8Array>;
  text(): Promise<string>;
}

interface BlobConstructor {
  new(blobParts?: BlobPart[], options?: BlobPropertyBag): Blob;
}

type BlobPart = BufferSource | Blob | string;

interface BlobPropertyBag {
  type?: string;
  endings?: 'transparent' | 'native';
}

interface File extends Blob {
  readonly lastModified: number;
  readonly name: string;
  readonly webkitRelativePath: string;
}

interface FileConstructor {
  new(fileParts: BlobPart[], fileName: string, options?: FilePropertyBag): File;
}

interface FilePropertyBag extends BlobPropertyBag {
  lastModified?: number;
}

declare var Blob: BlobConstructor;
declare var File: FileConstructor;
```

---

## ArrayBuffer and Typed Arrays

### ArrayBuffer Architecture

#### Binary Data Container Fundamentals

ArrayBuffer represents a fixed-length raw binary data buffer in memory. It stores data as a contiguous sequence of bytes without interpretation or structure:

```javascript
const buffer = new ArrayBuffer(16); // Allocates 16 bytes
console.log(buffer.byteLength); // 16
```

The ArrayBuffer itself provides no direct access to its contents - it serves purely as a memory allocation. [Inference] The underlying implementation allocates a contiguous block of memory, likely aligned to system word boundaries for optimal access patterns.

ArrayBuffers are resizable in newer implementations:

```javascript
const resizableBuffer = new ArrayBuffer(16, { maxByteLength: 32 });
resizableBuffer.resize(24); // Grow to 24 bytes
console.log(resizableBuffer.byteLength); // 24
```

[Inference] Resizable buffers allocate memory up to `maxByteLength` initially or use memory management strategies that allow growth without full reallocation. Non-resizable buffers have fixed size throughout their lifetime.

#### Memory Allocation Strategies

[Inference] ArrayBuffer allocation requests memory from the JavaScript heap. Large allocations may fail if insufficient contiguous memory exists, throwing RangeError:

```javascript
try {
  const hugeBuffer = new ArrayBuffer(Number.MAX_SAFE_INTEGER);
} catch (e) {
  console.log(e instanceof RangeError); // true - allocation failed
}
```

The allocation is synchronous and immediate - memory is reserved when the constructor completes. This differs from lazy allocation strategies where memory commits only upon access.

#### Zero-Initialization Guarantee

ArrayBuffer contents initialize to zero upon creation:

```javascript
const buffer = new ArrayBuffer(8);
const view = new Uint8Array(buffer);
console.log(view[0]); // 0
console.log(view[7]); // 0
```

This zero-initialization prevents information leakage from previously used memory regions. [Inference] The implementation either allocates pre-zeroed pages from the operating system or explicitly zeros allocated memory before exposing it to JavaScript.

#### Detachment and Transfer Semantics

ArrayBuffers can detach, rendering them unusable:

```javascript
const buffer = new ArrayBuffer(16);
const transferred = buffer.transfer();

console.log(buffer.byteLength); // 0 - original is detached
console.log(transferred.byteLength); // 16 - new buffer owns the data
```

Detachment occurs when:

- Explicitly calling `transfer()` or `transferToFixedLength()`
- Transferring via `postMessage()` to workers or other contexts
- Passing to WebAssembly as transferred memory

[Inference] Detachment prevents use-after-transfer bugs by making the original buffer invalid. Attempting to create views or access detached buffers throws TypeError.

### Typed Array View Fundamentals

#### View-Buffer Relationship

Typed arrays provide structured views into ArrayBuffer memory. A single buffer can have multiple views with different interpretations:

```javascript
const buffer = new ArrayBuffer(16);

const uint8View = new Uint8Array(buffer);
const uint16View = new Uint16Array(buffer);
const uint32View = new Uint32Array(buffer);
const float64View = new Float64Array(buffer);

uint32View[0] = 0x12345678;
console.log(uint8View[0]); // 0x78 (first byte, little-endian)
console.log(uint8View[1]); // 0x56
console.log(uint8View[2]); // 0x34
console.log(uint8View[3]); // 0x12
```

Each view interprets the same underlying bytes according to its element type. Modifying through one view affects reads through all views sharing the buffer.

#### View Constructor Variations

Typed arrays construct through multiple patterns:

```javascript
// From length (creates new buffer)
const array1 = new Uint8Array(10);
console.log(array1.buffer.byteLength); // 10

// From existing buffer
const buffer = new ArrayBuffer(16);
const array2 = new Uint8Array(buffer);

// From buffer with offset
const array3 = new Uint8Array(buffer, 4); // Start at byte 4

// From buffer with offset and length
const array4 = new Uint8Array(buffer, 4, 8); // 8 bytes starting at byte 4

// From iterable
const array5 = new Uint8Array([1, 2, 3, 4]);

// From another typed array
const array6 = new Uint8Array(array5);
```

[Inference] Creating from length allocates a new ArrayBuffer sized to fit the requested elements. Creating from iterables or other typed arrays copies data into a new buffer. Creating from existing buffers shares the underlying memory.

#### Offset and Length Constraints

Views must align to element boundaries and stay within buffer bounds:

```javascript
const buffer = new ArrayBuffer(16);

// Valid - aligned to 4-byte boundaries
const uint32View = new Uint32Array(buffer, 4, 2); // 2 elements at offset 4

// Invalid - offset not aligned to element size
try {
  const badView = new Uint32Array(buffer, 3); // Offset 3 not multiple of 4
} catch (e) {
  console.log(e instanceof RangeError); // true
}

// Invalid - extends beyond buffer
try {
  const badView = new Uint32Array(buffer, 12, 2); // Would need 8 bytes, only 4 available
} catch (e) {
  console.log(e instanceof RangeError); // true
}
```

[Inference] Alignment requirements exist because most CPU architectures require or significantly benefit from aligned memory access. Unaligned access may cause hardware exceptions or severe performance penalties.

### Typed Array Type System

#### Integer Type Variants

**Uint8Array** - 8-bit unsigned integers (0 to 255):

```javascript
const uint8 = new Uint8Array([0, 128, 255]);
uint8[0] = 300; // Wraps to 44 (300 % 256)
console.log(uint8[0]); // 44
```

**Int8Array** - 8-bit signed integers (-128 to 127):

```javascript
const int8 = new Int8Array([0, 127, -128]);
int8[0] = 200; // Wraps to -56
console.log(int8[0]); // -56
```

**Uint16Array** - 16-bit unsigned integers (0 to 65535):

```javascript
const uint16 = new Uint16Array([0, 32768, 65535]);
console.log(uint16.BYTES_PER_ELEMENT); // 2
```

**Int16Array** - 16-bit signed integers (-32768 to 32767):

```javascript
const int16 = new Int16Array([-32768, 0, 32767]);
```

**Uint32Array** - 32-bit unsigned integers (0 to 4294967295):

```javascript
const uint32 = new Uint32Array([0, 2147483648, 4294967295]);
```

**Int32Array** - 32-bit signed integers (-2147483648 to 2147483647):

```javascript
const int32 = new Int32Array([-2147483648, 0, 2147483647]);
```

**BigUint64Array** - 64-bit unsigned integers (0n to 2^64-1):

```javascript
const bigUint64 = new BigUint64Array([0n, 18446744073709551615n]);
bigUint64[0] = 100n; // Must use BigInt literals
```

**BigInt64Array** - 64-bit signed integers (-2^63 to 2^63-1):

```javascript
const bigInt64 = new BigInt64Array([-9223372036854775808n, 9223372036854775807n]);
```

#### Floating Point Type Variants

**Float32Array** - 32-bit IEEE 754 floating point:

```javascript
const float32 = new Float32Array([1.5, -3.14, Infinity, NaN]);
console.log(float32.BYTES_PER_ELEMENT); // 4

// Precision loss compared to 64-bit
float32[0] = 0.1 + 0.2;
console.log(float32[0]); // Approximately 0.30000001192092896
```

[Inference] Float32 represents numbers with approximately 7 decimal digits of precision. Values outside the representable range round to ±Infinity. Very small values round to zero.

**Float64Array** - 64-bit IEEE 754 floating point:

```javascript
const float64 = new Float64Array([1.5, -3.14, Number.MAX_VALUE, Number.MIN_VALUE]);
console.log(float64.BYTES_PER_ELEMENT); // 8

float64[0] = 0.1 + 0.2;
console.log(float64[0]); // 0.30000000000000004 (standard floating point imprecision)
```

Float64 provides approximately 16 decimal digits of precision, matching JavaScript's standard Number type.

#### Specialized Type Variants

**Uint8ClampedArray** - 8-bit unsigned with clamping instead of wrapping:

```javascript
const clamped = new Uint8ClampedArray([0, 128, 255]);

clamped[0] = 300; // Clamps to 255 instead of wrapping
console.log(clamped[0]); // 255

clamped[1] = -50; // Clamps to 0
console.log(clamped[1]); // 0

clamped[2] = 127.8; // Rounds using special rounding rules
console.log(clamped[2]); // 128
```

[Inference] Uint8ClampedArray uses specific rounding rules for fractional values: 0.5 rounds to nearest even number. This type primarily serves canvas image data manipulation where clamping prevents color value overflow artifacts.

### Endianness and Byte Order

#### Platform Endianness Impact

Typed arrays use platform-native byte order (endianness). Most modern systems use little-endian:

```javascript
const buffer = new ArrayBuffer(4);
const uint32View = new Uint32Array(buffer);
const uint8View = new Uint8Array(buffer);

uint32View[0] = 0x12345678;

// Little-endian platform (most common)
console.log(uint8View[0].toString(16)); // 78
console.log(uint8View[1].toString(16)); // 56
console.log(uint8View[2].toString(16)); // 34
console.log(uint8View[3].toString(16)); // 12

// Big-endian platform (rare)
// Would show: 12, 34, 56, 78
```

[Inference] JavaScript engines detect platform endianness at runtime or compile time, configuring typed array operations accordingly. Application code typically shouldn't depend on specific endianness unless interfacing with external systems.

#### DataView for Explicit Endianness Control

DataView provides methods with explicit endianness parameters:

```javascript
const buffer = new ArrayBuffer(8);
const dataView = new DataView(buffer);

// Write as little-endian
dataView.setUint32(0, 0x12345678, true);

// Write as big-endian
dataView.setUint32(4, 0x12345678, false);

const uint8View = new Uint8Array(buffer);
console.log([...uint8View].map(b => b.toString(16)));
// Little-endian bytes at 0-3: 78, 56, 34, 12
// Big-endian bytes at 4-7: 12, 34, 56, 78
```

This enables portable binary format handling where byte order must match external specifications.

### Element Access and Manipulation

#### Index-Based Access

Typed arrays support bracket notation for element access:

```javascript
const array = new Uint16Array([100, 200, 300]);

console.log(array[0]); // 100
console.log(array[1]); // 200

array[0] = 500;
console.log(array[0]); // 500

array[10] = 42; // Out of bounds - no effect
console.log(array[10]); // undefined
console.log(array.length); // Still 3
```

Out-of-bounds access returns undefined for reads and has no effect for writes, unlike regular arrays which grow dynamically.

#### Subarray Views

The `subarray()` method creates a new typed array view referencing the same buffer:

```javascript
const array = new Uint8Array([0, 1, 2, 3, 4, 5, 6, 7]);
const sub = array.subarray(2, 6); // Elements at indices 2-5

console.log(sub.length); // 4
console.log(sub[0]); // 2 (array[2])

sub[0] = 100;
console.log(array[2]); // 100 - shared underlying buffer

console.log(sub.byteOffset); // 2 - offset into original buffer
```

Subarray creates a new view without copying data. Modifications through the subarray affect the original array and vice versa.

#### Slice Creates Independent Copy

The `slice()` method copies elements into a new typed array with its own buffer:

```javascript
const array = new Uint8Array([0, 1, 2, 3, 4, 5]);
const sliced = array.slice(2, 5); // Copies elements 2-4

console.log(sliced.length); // 3
console.log(sliced[0]); // 2

sliced[0] = 100;
console.log(array[2]); // 2 - independent buffers
console.log(sliced[0]); // 100
```

[Inference] Slice allocates a new ArrayBuffer sized to fit the selected elements, then copies data. This operation has O(n) time and space complexity relative to slice length.

### Data Copying and Transfer

#### Set Method for Bulk Copying

The `set()` method copies elements from an array or typed array:

```javascript
const target = new Uint8Array(10);
const source = new Uint8Array([1, 2, 3, 4]);

target.set(source, 2); // Copy source to target starting at index 2

console.log([...target]); // [0, 0, 1, 2, 3, 4, 0, 0, 0, 0]

// Copy from regular array
target.set([10, 11, 12], 0);
console.log([...target]); // [10, 11, 12, 2, 3, 4, 0, 0, 0, 0]
```

[Inference] When copying between typed arrays of the same type, implementations may use optimized memory copy operations (memcpy). Cross-type copying requires element-by-element conversion and assignment.

Bounds checking occurs - attempting to copy beyond target length throws RangeError:

```javascript
const target = new Uint8Array(5);
const source = new Uint8Array([1, 2, 3, 4, 5, 6]);

try {
  target.set(source, 1); // Would need 6 slots, only 4 available from offset 1
} catch (e) {
  console.log(e instanceof RangeError); // true
}
```

#### CopyWithin for In-Place Movement

The `copyWithin()` method moves elements within the same typed array:

```javascript
const array = new Uint8Array([0, 1, 2, 3, 4, 5, 6, 7]);

// Copy elements 3-5 to position 0
array.copyWithin(0, 3, 6);

console.log([...array]); // [3, 4, 5, 3, 4, 5, 6, 7]
```

[Inference] CopyWithin handles overlapping regions correctly, using a temporary buffer or bidirectional copy strategy to ensure correct behavior when source and destination overlap.

#### Fill for Uniform Initialization

The `fill()` method sets all or a range of elements to a value:

```javascript
const array = new Uint8Array(10);

array.fill(255); // Fill entire array
console.log([...array]); // [255, 255, 255, ...]

array.fill(0, 2, 5); // Fill indices 2-4 with 0
console.log([...array]); // [255, 255, 0, 0, 0, 255, 255, ...]
```

[Inference] Fill likely uses optimized loops or SIMD operations for performance, especially for large arrays or simple patterns.

### Iteration and Array Methods

#### Standard Array Method Support

Typed arrays implement most Array.prototype methods:

```javascript
const array = new Uint8Array([1, 2, 3, 4, 5]);

// Map
const doubled = array.map(x => x * 2);
console.log(doubled); // Uint8Array [2, 4, 6, 8, 10]

// Filter
const evens = array.filter(x => x % 2 === 0);
console.log(evens); // Uint8Array [2, 4]

// Reduce
const sum = array.reduce((acc, val) => acc + val, 0);
console.log(sum); // 15

// ForEach
array.forEach((val, idx) => {
  console.log(`${idx}: ${val}`);
});

// Find
const found = array.find(x => x > 3);
console.log(found); // 4

// Some/Every
console.log(array.some(x => x > 4)); // true
console.log(array.every(x => x > 0)); // true
```

[Inference] Methods that return arrays (map, filter, slice) return new typed arrays of the same type, not regular arrays. This preserves type information through transformations.

#### Iteration Protocol Implementation

Typed arrays implement iterable protocol:

```javascript
const array = new Uint8Array([10, 20, 30]);

// For-of loop
for (const value of array) {
  console.log(value); // 10, 20, 30
}

// Spread operator
const regular = [...array];
console.log(regular); // [10, 20, 30] - regular array

// Array.from
const copy = Array.from(array);

// Destructuring
const [first, second] = array;
console.log(first, second); // 10, 20
```

Iterator methods provide value, key, and entry iteration:

```javascript
// Values (default iterator)
for (const val of array.values()) {
  console.log(val);
}

// Keys
for (const idx of array.keys()) {
  console.log(idx); // 0, 1, 2
}

// Entries
for (const [idx, val] of array.entries()) {
  console.log(`${idx}: ${val}`);
}
```

#### Sorting with Type Awareness

The `sort()` method sorts in place using numeric comparison:

```javascript
const array = new Uint8Array([5, 2, 8, 1, 9]);

array.sort();
console.log([...array]); // [1, 2, 5, 8, 9]

// Custom comparator
array.sort((a, b) => b - a); // Descending
console.log([...array]); // [9, 8, 5, 2, 1]
```

[Inference] Unlike Array.sort() which converts elements to strings by default, typed array sort() uses numeric comparison. This prevents the ["10", "2"] ordering problem that occurs with string comparison.

### DataView for Mixed-Type Access

#### DataView Construction and Properties

DataView provides flexible, alignment-independent access to buffer contents:

```javascript
const buffer = new ArrayBuffer(16);
const view = new DataView(buffer);

console.log(view.buffer === buffer); // true
console.log(view.byteLength); // 16
console.log(view.byteOffset); // 0

// DataView on buffer slice
const partialView = new DataView(buffer, 4, 8); // 8 bytes starting at offset 4
console.log(partialView.byteLength); // 8
console.log(partialView.byteOffset); // 4
```

DataView doesn't have element indexing - all access occurs through getter/setter methods with explicit byte offsets.

#### Getter Methods with Endianness Control

DataView provides getters for all numeric types:

```javascript
const buffer = new ArrayBuffer(16);
const view = new DataView(buffer);

// Set some data first (using typed array for convenience)
const uint8 = new Uint8Array(buffer);
uint8.set([0x12, 0x34, 0x56, 0x78, 0x9A, 0xBC, 0xDE, 0xF0]);

// Read as 32-bit integer, little-endian
const le = view.getUint32(0, true);
console.log(le.toString(16)); // 0x78563412

// Read same bytes as big-endian
const be = view.getUint32(0, false);
console.log(be.toString(16)); // 0x12345678

// Read as 16-bit integer at offset 2
const u16 = view.getUint16(2, true);
console.log(u16.toString(16)); // 0x9a78

// Read as float
view.setFloat32(8, 3.14159, true);
const f32 = view.getFloat32(8, true);
console.log(f32); // ~3.14159
```

Available getters:

- `getInt8(byteOffset)` - signed 8-bit
- `getUint8(byteOffset)` - unsigned 8-bit
- `getInt16(byteOffset, littleEndian)` - signed 16-bit
- `getUint16(byteOffset, littleEndian)` - unsigned 16-bit
- `getInt32(byteOffset, littleEndian)` - signed 32-bit
- `getUint32(byteOffset, littleEndian)` - unsigned 32-bit
- `getBigInt64(byteOffset, littleEndian)` - signed 64-bit BigInt
- `getBigUint64(byteOffset, littleEndian)` - unsigned 64-bit BigInt
- `getFloat32(byteOffset, littleEndian)` - 32-bit float
- `getFloat64(byteOffset, littleEndian)` - 64-bit float

The `littleEndian` parameter defaults to false (big-endian) when omitted.

#### Setter Methods for Mixed-Type Writing

Corresponding setters write values at specified offsets:

```javascript
const buffer = new ArrayBuffer(16);
const view = new DataView(buffer);

// Write different types at different offsets
view.setUint8(0, 255);
view.setInt16(1, -1000, true); // Little-endian
view.setUint32(3, 0xDEADBEEF, false); // Big-endian
view.setFloat64(7, 3.141592653589793, true);

// Read back with Uint8Array to see bytes
const bytes = new Uint8Array(buffer);
console.log([...bytes].map(b => b.toString(16).padStart(2, '0')));
```

Setters allow unaligned access, which typed arrays cannot support:

```javascript
const buffer = new ArrayBuffer(10);
const view = new DataView(buffer);

// Write 32-bit value at odd offset
view.setUint32(1, 0x12345678, true); // Valid with DataView

// Attempting same with typed array requires alignment
try {
  const uint32 = new Uint32Array(buffer, 1); // Offset 1 not aligned to 4
} catch (e) {
  console.log(e instanceof RangeError); // true
}
```

[Inference] DataView methods perform byte-by-byte operations when necessary, avoiding hardware alignment requirements. This flexibility trades off some performance compared to aligned typed array access.

### Binary Data Patterns and Protocols

#### Structure Serialization

DataView enables reading/writing C-style structures:

```javascript
// Serialize a structure: { id: uint32, x: float32, y: float32, flags: uint8 }
function serializePoint(id, x, y, flags) {
  const buffer = new ArrayBuffer(13);
  const view = new DataView(buffer);
  
  view.setUint32(0, id, true);
  view.setFloat32(4, x, true);
  view.setFloat32(8, y, true);
  view.setUint8(12, flags);
  
  return buffer;
}

// Deserialize
function deserializePoint(buffer) {
  const view = new DataView(buffer);
  
  return {
    id: view.getUint32(0, true),
    x: view.getFloat32(4, true),
    y: view.getFloat32(8, true),
    flags: view.getUint8(12)
  };
}

const buffer = serializePoint(1001, 12.5, -7.3, 0b00001111);
const point = deserializePoint(buffer);
console.log(point); // { id: 1001, x: 12.5, y: -7.3, flags: 15 }
```

This pattern enables binary protocol implementation and interoperability with native code.

#### Bit Field Manipulation

Typed arrays facilitate bit-level operations:

```javascript
const flags = new Uint8Array([0b00000000]);

// Set individual bits
function setBit(array, index, bitPosition) {
  array[index] |= (1 << bitPosition);
}

// Clear bits
function clearBit(array, index, bitPosition) {
  array[index] &= ~(1 << bitPosition);
}

// Test bits
function testBit(array, index, bitPosition) {
  return (array[index] & (1 << bitPosition)) !== 0;
}

setBit(flags, 0, 3); // Set bit 3
setBit(flags, 0, 7); // Set bit 7
console.log(flags[0].toString(2).padStart(8, '0')); // 10001000

console.log(testBit(flags, 0, 3)); // true
console.log(testBit(flags, 0, 2)); // false

clearBit(flags, 0, 3);
console.log(flags[0].toString(2).padStart(8, '0')); // 10000000
```

Multiple flags pack efficiently into typed arrays for memory-efficient boolean storage.

#### Variable-Length Integer Encoding

Implementing variable-length encodings like UTF-8 or Protocol Buffers varints:

```javascript
// Encode unsigned integer as varint (7 bits per byte, MSB indicates continuation)
function encodeVarint(value) {
  const bytes = [];
  
  while (value > 0x7F) {
    bytes.push((value & 0x7F) | 0x80); // Set continuation bit
    value >>>= 7;
  }
  bytes.push(value & 0x7F);
  
  return new Uint8Array(bytes);
}

// Decode varint
function decodeVarint(array, offset = 0) {
  let value = 0;
  let shift = 0;
  let position = offset;
  
  while (position < array.length) {
    const byte = array[position++];
    value |= (byte & 0x7F) << shift;
    
    if ((byte & 0x80) === 0) break; // No continuation bit
    shift += 7;
  }
  
  return { value, bytesRead: position - offset };
}

const encoded = encodeVarint(300);
console.log([...encoded]); // [172, 2] (0b10101100, 0b00000010)

const { value } = decodeVarint(encoded);
console.log(value); // 300
```

This demonstrates using typed arrays for efficient wire format implementations.

### Conversion Between Types

#### Type Conversion Through Views

Creating different typed array views reinterprets the same bytes:

```javascript
const buffer = new ArrayBuffer(4);

const floatView = new Float32Array(buffer);
floatView[0] = 3.14159;

// Reinterpret same bytes as integers
const intView = new Int32Array(buffer);
console.log(intView[0]); // Integer representation of float bits

const uint8View = new Uint8Array(buffer);
console.log([...uint8View]); // Individual bytes of the float
```

[Inference] This enables examining internal representations of floating point numbers, implementing type punning, or debugging binary formats by viewing data through multiple lenses.

#### Value Coercion Rules

Assigning values to typed arrays coerces to the target type:

```javascript
const uint8 = new Uint8Array(5);

// Truncation to integer
uint8[0] = 3.7;
console.log(uint8[0]); // 3

// Wrapping for overflow
uint8[1] = 256;
console.log(uint8[1]); // 0

uint8[2] = -1;
console.log(uint8[2]); // 255

// String to number conversion
uint8[3] = "42";
console.log(uint8[3]); // 42

uint8[4] = "invalid";
console.log(uint8[4]); // 0 (NaN converts to 0)
```

Signed integer arrays use two's complement wrapping:

```javascript
const int8 = new Int8Array(3);

int8[0] = 128; // Wraps to -128
console.log(int8[0]); // -128

int8[1] = -129; // Wraps to 127
console.log(int8[1]); // 127
```

#### Cross-Type Array Creation

Creating a typed array from another typed array copies and converts values:

```javascript
const float32 = new Float32Array([1.1, 2.7, 3.9]);
const uint8 = new Uint8Array(float32);

console.log([...uint8]); // [1, 2, 3] - values truncated

const int8 = new Int8Array([-1, -2, -3]);
const uint8Copy = new Uint8Array(int8);

console.log([...uint8Copy]); // [255, 254, 253] - reinterpreted as unsigned
```

[Inference] Cross-type conversion creates a new buffer and copies elements with appropriate value conversion. This differs from viewing the same buffer through different typed arrays, which reinterprets bytes without value conversion.

### Memory Sharing and Atomics

#### SharedArrayBuffer Fundamentals

SharedArrayBuffer enables memory sharing between workers:

```javascript
// Main thread
const shared = new SharedArrayBuffer(16);
const sharedView = new Int32Array(shared);

sharedView[0] = 42;

worker.postMessage(shared);

// Worker thread
self.onmessage = (event) => {
  const shared = event.data;
  const view = new Int32Array(shared);
  
  console.log(view[0]); // 42 - same memory
  view[0] = 100; // Visible to main thread
};
```

[Inference] SharedArrayBuffer maps to shared memory regions that multiple threads can access simultaneously. This requires careful synchronization to prevent race conditions.

#### Atomic Operations for Synchronization

The Atomics object provides atomic operations on SharedArrayBuffer-backed integer typed arrays:

```javascript
const shared = new SharedArrayBuffer(4);
const view = new Int32Array(shared);

// Atomic add
Atomics.add(view, 0, 5); // Atomically adds 5 to view[0]

// Atomic compare-and-exchange
const old = Atomics.compareExchange(view, 0, 5, 10);
// If view[0] === 5, sets it to 10 and returns 5

// Atomic load/store
Atomics.store(view, 0, 42);
const value = Atomics.load(view, 0);

// Wait/notify for coordination
// Thread 1 waits
Atomics.wait(view, 0, 0); // Blocks until view[0] !== 0 or notified

// Thread 2 notifies
Atomics.store(view, 0, 1);
Atomics.notify(view, 0); // Wake waiting threads
```

[Inference] Atomic operations prevent torn reads/writes where one thread sees partial updates from another. They provide the memory ordering guarantees necessary for lock-free algorithms.

Available atomic operations:

- `Atomics.add()` - Atomic addition
- `Atomics.sub()` - Atomic subtraction
- `Atomics.and()` - Atomic bitwise AND
- `Atomics.or()` - Atomic bitwise OR
- `Atomics.xor()` - Atomic bitwise XOR
- `Atomics.load()` - Atomic read
- `Atomics.store()` - Atomic write
- `Atomics.exchange()` - Atomic swap
- `Atomics.compareExchange()` - Compare-and-swap
- `Atomics.wait()` - Wait for change
- `Atomics.notify()` - Wake waiting threads

#### Race Condition Prevention

Without atomics, concurrent access causes races:

```javascript
// Race condition example
const shared = new SharedArrayBuffer(4);
const view = new Int32Array(shared);
view[0] = 0;

// Multiple workers incrementing
function increment() {
  const current = view[0]; // Read
  // Another worker might read here
  view[0] = current + 1; // Write
}

// Two workers executing increment() simultaneously might both read 0,
// then both write 1, resulting in only one increment instead of two
```

Atomic operations prevent this:

```javascript
// Safe increment
function atomicIncrement() {
  Atomics.add(view, 0, 1); // Atomic read-modify-write
}

// Two workers calling atomicIncrement() correctly results in two increments
```

### Performance Characteristics

#### Access Pattern Performance

Sequential access benefits from CPU cache prefetching:

```javascript
const array = new Float32Array(1000000);

// Fast: sequential access
console.time('sequential');
for (let i = 0; i < array.length; i++) {
  array[i] = i * 2;
}
console.timeEnd('sequential');

// Slower: random access
console.time('random');
for (let i = 0; i < array.length; i++) {
  const randomIndex = Math.floor(Math.random() * array.length);
  array[randomIndex] = i;
}
console.timeEnd('random');
```

[Inference] Sequential access patterns allow CPU hardware prefetchers to load cache lines ahead of access, minimizing memory latency. Random access patterns defeat prefetching, causing cache misses.

#### Type-Specific Performance Differences

[Inference] Operations on smaller integer types may be slower than 32-bit integers on some architectures due to sign/zero extension requirements:

```javascript
// 32-bit operations often fastest
const uint32 = new Uint32Array(1000000);

// 8-bit operations may require extension
const uint8 = new Uint8Array(1000000);

// Floating point performance depends on FPU capabilities
const float64 = new Float64Array(1000000);
```

However, smaller types use less memory bandwidth and cache space, potentially offsetting per-operation costs for large datasets.

#### Alignment Performance Impact

[Inference] Aligned access performs better than unaligned access on most architectures:

```javascript
const buffer = new ArrayBuffer(1024);

// Aligned access (offset multiple of element size)
const alignedView = new Uint32Array(buffer, 0);

// Potentially slower unaligned access via DataView
const dataView = new DataView(buffer);
dataView.setUint32(1, 0x12345678); // Offset 1 not aligned to 4
```

Modern x86 processors handle unaligned access efficiently but with some penalty. ARM processors may have more significant performance impact or require alignment.

#### Subarray vs Slice Performance

Subarray creates views without copying, making it O(1):

```javascript
const large = new Uint8Array(10000000);

console.time('subarray');
const sub = large.subarray(1000, 2000);
console.timeEnd('subarray'); // Very fast, just creates view

console.time('slice');
const sliced = large.slice(1000, 2000);
console.timeEnd('slice'); // Slower, copies 1000 elements
```

Use subarray when shared memory is acceptable, slice when independent copies are needed.

### Integration with Web APIs

#### Canvas ImageData

Canvas ImageData uses Uint8ClampedArray for pixel data:

```javascript
const canvas = document.createElement('canvas');
const ctx = canvas.getContext('2d');
canvas.width = 100;
canvas.height = 100;

const imageData = ctx.getImageData(0, 0, 100, 100);
console.log(imageData.data instanceof Uint8ClampedArray); // true
console.log(imageData.data.length); // 40000 (100 * 100 * 4 RGBA bytes)

// Manipulate pixels directly
for (let i = 0; i < imageData.data.length; i += 4) {
  imageData.data[i] = 255;     // Red
  imageData.data[i + 1] = 0;   // Green
  imageData.data[i + 2] = 0;   // Blue
  imageData.data[i + 3] = 255; // Alpha
}

ctx.putImageData(imageData, 0, 0);
```

[Inference] Uint8ClampedArray's clamping behavior prevents overflow artifacts when performing image operations that might exceed 0-255 range.

#### Web Audio API

AudioBuffer uses Float32Array for sample data:

```javascript
const audioContext = new AudioContext();
const buffer = audioContext.createBuffer(
  2, // stereo
  audioContext.sampleRate * 2, // 2 seconds
  audioContext.sampleRate
);

// Get channel data as Float32Array
const leftChannel = buffer.getChannelData(0);
const rightChannel = buffer.getChannelData(1);

console.log(leftChannel instanceof Float32Array); // true

// Generate sine wave
const frequency = 440; // A4
for (let i = 0; i < leftChannel.length; i++) {
  const t = i / audioContext.sampleRate;
  leftChannel[i] = Math.sin(2 * Math.PI * frequency * t);
  rightChannel[i] = leftChannel[i];
}
```

Float32Array provides the precision necessary for audio sample representation, typically normalized to ±1.0 range.

#### WebGL Buffers

WebGL operations use typed arrays for vertex and texture data:

```javascript
const gl = canvas.getContext('webgl');

// Vertex positions
const vertices = new Float32Array([
  -1.0, -1.0,
   1.0, -1.0,
   0.0,  1.0
]);

const buffer = gl.createBuffer();
gl.bindBuffer(gl.ARRAY_BUFFER, buffer);
gl.bufferData(gl.ARRAY_BUFFER, vertices, gl.STATIC_DRAW);

// Index buffer
const indices = new Uint16Array([0, 1, 2]);
const indexBuffer = gl.createBuffer();
gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, indexBuffer);
gl.bufferData(gl.ELEMENT_ARRAY_BUFFER, indices, gl.STATIC_DRAW);
```

[Inference] WebGL implementations typically pass typed array data directly to GPU memory or perform optimized copies, avoiding intermediate JavaScript array conversions.

#### Fetch and Blob

ArrayBuffer integrates with Fetch API for binary data:

```javascript
// Fetch binary data
const response = await fetch('data.bin');
const buffer = await response.arrayBuffer();
const view = new Uint8Array(buffer);

// Upload binary data
const uploadData = new Uint8Array([1, 2, 3, 4, 5]);
await fetch('/upload', {
  method: 'POST',
  body: uploadData.buffer,
  headers: {
    'Content-Type': 'application/octet-stream'
  }
});

// Create Blob from ArrayBuffer
const blob = new Blob([buffer], { type: 'application/octet-stream' });

// Convert Blob to ArrayBuffer
const blobBuffer = await blob.arrayBuffer();
```

#### File API

File reading produces ArrayBuffer:

```javascript
const fileInput = document.querySelector('input[type="file"]');

fileInput.addEventListener('change', async (e) => {
  const file = e.target.files[0];
  
  // Read as ArrayBuffer
  const buffer = await file.arrayBuffer();
  const view = new Uint8Array(buffer);
  
  // Process binary file data
  console.log('File size:', view.length);
  console.log('First bytes:', view.slice(0, 16));
});
```

### WebAssembly Integration

#### Memory Access from JavaScript

WebAssembly memory exposes as ArrayBuffer:

```javascript
const wasmMemory = new WebAssembly.Memory({ initial: 1 }); // 1 page = 64KB

console.log(wasmMemory.buffer instanceof ArrayBuffer); // true
console.log(wasmMemory.buffer.byteLength); // 65536

// Access WASM memory from JavaScript
const memView = new Uint8Array(wasmMemory.buffer);
memView[0] = 42;

// Grow memory
wasmMemory.grow(1); // Add 1 page

// Note: After grow(), old buffer becomes detached
const newView = new Uint8Array(wasmMemory.buffer);
console.log(newView[0]); // 42 - data preserved
```

[Inference] Memory growth detaches the previous ArrayBuffer to maintain safety. Code must re-acquire buffer references after growth operations.

#### Passing Data to WebAssembly

WebAssembly functions receive memory offsets, not direct array references:

```javascript
// WASM module exports function: processArray(ptr, length)
const wasmInstance = await WebAssembly.instantiateStreaming(
  fetch('module.wasm')
);

const data = new Float32Array([1.0, 2.0, 3.0, 4.0]);

// Allocate space in WASM memory (assuming exported alloc function)
const ptr = wasmInstance.exports.alloc(data.byteLength);

// Copy data to WASM memory
const wasmMemory = new Float32Array(
  wasmInstance.exports.memory.buffer,
  ptr,
  data.length
);
wasmMemory.set(data);

// Call WASM function with pointer and length
wasmInstance.exports.processArray(ptr, data.length);

// Read results back
const results = wasmMemory.slice(0, data.length);
```

This pattern enables efficient data exchange between JavaScript and WebAssembly.

### Security and Safety Considerations

#### Bounds Checking Guarantees

Typed arrays provide automatic bounds checking:

```javascript
const array = new Uint8Array(10);

array[100] = 42; // Out of bounds - no effect
console.log(array[100]); // undefined - no crash

// DataView also bounds-checked
const buffer = new ArrayBuffer(10);
const view = new DataView(buffer);

try {
  view.getUint32(8); // Would read bytes 8-11, but only 0-9 available
} catch (e) {
  console.log(e instanceof RangeError); // true
}
```

[Inference] Bounds checking prevents buffer overflow vulnerabilities that plague C/C++ code. Out-of-bounds reads return undefined, writes have no effect, and DataView methods throw on invalid access.

#### Detached Buffer Protection

Accessing detached buffers throws TypeError:

```javascript
const buffer = new ArrayBuffer(16);
const view = new Uint8Array(buffer);

view[0] = 42; // Works

// Transfer buffer (detaches it)
const transferred = buffer.transfer();

try {
  view[0] = 100; // buffer is detached
} catch (e) {
  console.log(e instanceof TypeError); // true - cannot access detached buffer
}

console.log(buffer.byteLength); // 0 - detached
```

[Inference] Detachment prevents use-after-free bugs by making the original buffer permanently inaccessible rather than leaving dangling references.

#### Type Safety Through Views

Typed arrays enforce element type constraints:

```javascript
const uint8 = new Uint8Array([1, 2, 3]);
const float32 = new Float32Array(uint8.buffer);

// Each view maintains type safety
uint8[0] = 300; // Wraps to 44
console.log(uint8[0]); // 44 - enforced uint8 range

float32[0] = 3.14;
console.log(float32[0]); // 3.14 - valid float
console.log(uint8[0]); // Different interpretation of same bytes
```

[Inference] Type safety prevents accidental misinterpretation when each access explicitly specifies expected type, unlike void* pointers in C which provide no type information.

---

## Text/Plain Bodies

### Character Encoding

Text/plain content requires character encoding specification. Default encoding is US-ASCII if not specified, but UTF-8 is standard practice.

```
Content-Type: text/plain; charset=utf-8
Content-Type: text/plain; charset=iso-8859-1
Content-Type: text/plain; charset=windows-1252
```

The `charset` parameter determines how bytes map to characters. Without explicit charset, content interpretation becomes ambiguous.

UTF-8 encoding handles all Unicode characters using 1-4 bytes per character:

- ASCII characters (U+0000 to U+007F): 1 byte
- Latin extended, Greek, Cyrillic, etc. (U+0080 to U+07FF): 2 bytes
- Most other characters including CJK (U+0800 to U+FFFF): 3 bytes
- Supplementary characters (U+10000 to U+10FFFF): 4 bytes

### Content-Length Calculation

Content-Length represents byte count, not character count. For multi-byte encodings like UTF-8, character count differs from byte count.

```
POST /api/message HTTP/1.1
Content-Type: text/plain; charset=utf-8
Content-Length: 13

Hello, 世界!
```

"Hello, 世界!" is 9 characters but 13 bytes (each Chinese character requires 3 bytes in UTF-8).

Incorrect Content-Length causes truncation or hanging connections. Server may wait for bytes that never arrive or client may disconnect before receiving complete response.

### Line Endings

Text/plain may use different line ending conventions:

- Unix/Linux: LF (`\n`, 0x0A)
- Windows: CRLF (`\r\n`, 0x0D 0x0A)
- Classic Mac: CR (`\r`, 0x0D)

HTTP protocol itself uses CRLF for headers, but message body line endings depend on content origin. Servers and clients should handle all conventions.

```
POST /api/log HTTP/1.1
Content-Type: text/plain; charset=utf-8
Content-Length: 24

Line 1\r\nLine 2\r\nLine 3
```

Some applications normalize line endings on receipt, others preserve original format.

### Whitespace Handling

Text/plain preserves all whitespace characters:

- Space (0x20)
- Tab (0x09)
- Line feed (0x0A)
- Carriage return (0x0D)
- Non-breaking space (0xA0 in ISO-8859-1, 0xC2 0xA0 in UTF-8)

Unlike HTML where consecutive whitespace collapses, text/plain maintains exact spacing:

```
Hello    world
    Indented line
Another line
```

Applications rendering text/plain should display whitespace as-is, typically using monospace fonts.

### Content Disposition

Text/plain responses can specify inline display or download:

```
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline

Content-Type: text/plain; charset=utf-8
Content-Disposition: attachment; filename="data.txt"
```

`inline`: Browser displays content directly `attachment`: Browser prompts download

Filename parameter suggests name for saved file. Should use ASCII characters or percent-encoding for compatibility.

```
Content-Disposition: attachment; filename="report.txt"; filename*=UTF-8''%E3%83%AC%E3%83%9D%E3%83%BC%E3%83%88.txt
```

The `filename*` parameter (RFC 5987) supports UTF-8 filenames for international characters.

### Compression

Text/plain content benefits significantly from compression due to repetitive patterns.

```
Content-Type: text/plain; charset=utf-8
Content-Encoding: gzip
Content-Length: 1247
```

Compression ratios for text typically range 50-90% depending on content structure. Gzip, Deflate, and Brotli all work effectively.

Compressed Content-Length reflects compressed size. Original size not directly indicated (may be inferred after decompression).

### Byte Order Mark (BOM)

UTF-8 content may include optional BOM (0xEF 0xBB 0xBF) at start:

```
Content-Type: text/plain; charset=utf-8
Content-Length: 17

\xEF\xBB\xBFHello, world!
```

BOM presence is controversial:

- Not required for UTF-8 (encoding order is defined)
- Helps some applications detect UTF-8
- Can cause issues with applications treating it as visible characters
- Unix tools often strip or ignore BOM

Best practice: omit BOM for UTF-8, include only if interoperability requires.

### Range Requests

Text/plain supports byte-range requests like other content types:

```
GET /log.txt HTTP/1.1
Range: bytes=0-999
```

Response:

```
HTTP/1.1 206 Partial Content
Content-Type: text/plain; charset=utf-8
Content-Range: bytes 0-999/50000
Content-Length: 1000

[first 1000 bytes of text]
```

Byte ranges may split multi-byte characters in UTF-8, resulting in invalid sequences at boundaries. Applications requesting ranges should handle incomplete characters at boundaries or request complete character ranges.

[Inference] Implementations often request ranges aligned to line boundaries to avoid character splitting issues.

### Streaming

Text/plain works well with streaming/chunked transfer encoding for large or unbounded content:

```
HTTP/1.1 200 OK
Content-Type: text/plain; charset=utf-8
Transfer-Encoding: chunked

1a
First chunk of text data
1c
Second chunk of text data
0

```

Each chunk specifies size in hexadecimal, followed by CRLF, chunk data, and another CRLF. Final chunk has size 0.

Streaming enables:

- Real-time log tailing
- Progress indication for long-running operations
- Server-sent events (though text/event-stream preferred)
- Reduced memory requirements for large files

### Newline Conventions in APIs

REST APIs using text/plain for request bodies should document expected line ending convention:

```
POST /api/bulk-insert HTTP/1.1
Content-Type: text/plain; charset=utf-8
Content-Length: 45

record1,value1,value2
record2,value3,value4
```

Common conventions:

- Unix-style LF for simplicity and consistency
- Accept any line ending variant for flexibility
- Normalize on receipt to internal format

Documentation should specify whether trailing newline is required, optional, or prohibited.

### Special Characters

Text/plain can represent any Unicode character through proper encoding. Common special characters:

**Control characters:**

- Null (0x00): Valid in UTF-8 but often problematic in C-style string handling
- Tab (0x09): Standard whitespace
- Escape (0x1B): Sometimes used for terminal control sequences

**Unicode categories:**

- Zero-width characters (ZWSP, ZWNJ, ZWJ): Valid but invisible
- Direction markers (LRM, RLM, LRE, RLE, PDF): Control text direction
- Private use areas: Valid but application-specific meaning

**Normalization:** Unicode provides multiple representations for some characters (e.g., é as single character U+00E9 or e + combining acute U+0065 U+0301). Applications may normalize to canonical form (NFC) or decomposed form (NFD).

### Maximum Size Limits

No protocol-level maximum for text/plain bodies, but practical limits exist:

**Server limits:**

- Application servers typically limit request body size (1MB-100MB common)
- Web servers impose their own limits (nginx: 1MB default, Apache: no default limit)
- Proxies and load balancers may enforce stricter limits

**Client limits:**

- Browsers don't generally limit response sizes
- Memory constraints affect practical maximum
- Some libraries impose limits (configurable)

Large text files should consider:

- Pagination for structured data
- Streaming for continuous data
- Compression to reduce transfer size
- Alternative formats (binary protocols) for very large datasets

### Content Negotiation

Clients may request text/plain explicitly:

```
GET /resource HTTP/1.1
Accept: text/plain, text/html;q=0.9, application/json;q=0.8
```

Quality values indicate preference. Server selects best match and responds with actual Content-Type.

If server cannot provide text/plain, responds with:

```
HTTP/1.1 406 Not Acceptable
```

Or provides alternative format and lets client decide if acceptable.

### Security Considerations

**Injection attacks:** Text/plain content displayed in browsers doesn't execute scripts, but context matters:

- If application renders as HTML, vulnerable to injection
- If used in shell commands, vulnerable to command injection
- If used in SQL queries, vulnerable to SQL injection

Always validate and sanitize text/plain input before using in other contexts.

**Content sniffing:** Browsers may ignore declared Content-Type and interpret content based on analysis. Text containing HTML-like patterns might be executed as HTML.

Prevent with:

```
X-Content-Type-Options: nosniff
```

**Encoding attacks:** Invalid UTF-8 sequences or overlong encodings can bypass security filters:

- Null bytes encoded as overlong UTF-8
- Directory traversal characters in unexpected encodings
- Homograph attacks using similar-looking Unicode characters

Validate encoding correctness and reject invalid sequences.

**Size-based attacks:** Extremely large text bodies can cause:

- Memory exhaustion (DoS)
- Disk exhaustion (log files)
- CPU exhaustion (processing)

Enforce reasonable limits and implement streaming for large inputs.

### Media Type Parameters

Text/plain supports additional parameters beyond charset:

```
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Type: text/plain; charset=utf-8; delsp=yes
```

**format=flowed** (RFC 3676): Indicates text formatted with flowed text rules:

- Lines ending in space are soft-wrapped (logical continuation)
- Lines without trailing space are hard breaks (paragraph boundaries)
- Allows reflowing text to different display widths

```
This is a long line that has been wrapped 
for transmission but should reflow.
This is a new paragraph.
```

**delsp parameter:**

- `delsp=yes`: Delete trailing space when reflowing
- `delsp=no`: Preserve trailing space

[Unverified] Limited support in modern applications; primarily used in email contexts.

### Language Specification

Content-Language header indicates natural language:

```
Content-Type: text/plain; charset=utf-8
Content-Language: en
Content-Language: en-US
Content-Language: ja
```

Doesn't affect encoding but informs language-aware processing (spell-check, translation, locale-specific rendering).

### Empty Bodies

Text/plain may have empty body:

```
HTTP/1.1 200 OK
Content-Type: text/plain; charset=utf-8
Content-Length: 0

```

Or omit Content-Length with no body (when using Connection: close or HTTP/1.0).

Empty response valid for operations with no output (acknowledgments, deletions).

### MIME Multipart

Text/plain can appear within multipart messages:

```
Content-Type: multipart/mixed; boundary=frontier

--frontier
Content-Type: text/plain; charset=utf-8

First part as plain text
--frontier
Content-Type: text/plain; charset=utf-8

Second part as plain text
--frontier--
```

Each part has its own headers and body. Boundary delimiter separates parts. Final boundary includes trailing `--`.

### Base64 Encoding in Transit

Text/plain sometimes base64-encoded for transport through binary-unsafe channels:

```
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: base64

SGVsbG8sIHdvcmxkIQ==
```

HTTP itself is 8-bit clean, so this primarily appears in:

- Email (MIME)
- Embedded data URLs
- Legacy protocols

Modern HTTP typically sends text/plain directly without additional encoding.

### Concatenation

Multiple text/plain parts can be concatenated directly:

```
HTTP/1.1 200 OK
Content-Type: text/plain; charset=utf-8
Transfer-Encoding: chunked

a
Part one\n
a
Part two\n
0

```

Concatenated result:

```
Part one
Part two
```

This differs from JSON or XML where concatenation produces invalid documents. Text/plain's unstructured nature permits simple concatenation.

### Interoperability

Text/plain maximizes interoperability:

- Viewable in any text editor
- Processable with standard Unix tools (grep, sed, awk)
- No parsing libraries required
- Language-agnostic
- Platform-independent

Trade-off: lacks structure, requiring custom parsing for structured data. Consider alternatives (CSV, JSON, XML) when structure needed.

### Caching

Text/plain cached like other content:

```
Cache-Control: public, max-age=3600
ETag: "33a64df551425fcc55e4d42a148795d9f25f89d4"
Last-Modified: Wed, 21 Oct 2015 07:28:00 GMT
```

Static text files often highly cacheable. Dynamic text (logs, status) typically not cached or with short lifetime.

Vary header indicates cache keys:

```
Vary: Accept-Encoding, Accept-Language
```

Cache stores separate versions for different encodings/languages.

### Content Transformation

Proxies may transform text/plain:

- Compression/decompression
- Charset transcoding
- Line ending normalization
- Whitespace manipulation

Prevent with:

```
Cache-Control: no-transform
```

Transformations can alter Content-Length, Content-Encoding, and introduce subtle bugs if not handled properly.

### Partial Updates

Text/plain supports HTTP PATCH for partial updates, though encoding varies by implementation:

**Plain text replacement:**

```
PATCH /document.txt HTTP/1.1
Content-Type: text/plain; charset=utf-8
Content-Length: 11

New content
```

Complete replacement of resource.

**Line-based operations:** Custom formats specify which lines to add/remove/modify. No standard format exists for text/plain patches.

**Diff format:**

```
PATCH /document.txt HTTP/1.1
Content-Type: text/plain; charset=utf-8

@@ -1,3 +1,3 @@
 Line 1
-Line 2
+Modified line 2
 Line 3
```

Unified diff format, though application/diff-patch better Content-Type choice.

[Inference] Most APIs treat text/plain PATCH as full replacement rather than partial update due to lack of standardized patch format.

### Version Control Headers

Text/plain with version tracking may use custom headers:

```
GET /document.txt HTTP/1.1

HTTP/1.1 200 OK
Content-Type: text/plain; charset=utf-8
X-Document-Version: 42
X-Last-Author: user@example.com
```

Version information enables optimistic concurrency:

```
PUT /document.txt HTTP/1.1
Content-Type: text/plain; charset=utf-8
If-Match: "version-42"

Updated content
```

Server rejects if version changed, preventing lost updates.

### Logging and Debugging

Text/plain ideal for log files and debug output:

```
GET /logs/app.log HTTP/1.1
Range: bytes=-10240

HTTP/1.1 206 Partial Content
Content-Type: text/plain; charset=utf-8
Content-Range: bytes 10234880-10245119/10245120

[recent 10KB of logs]
```

Advantages:

- Human-readable
- Greppable
- Streamable
- Appendable without parsing
- Tool-compatible

Streaming logs:

```
HTTP/1.1 200 OK
Content-Type: text/plain; charset=utf-8
Transfer-Encoding: chunked

[chunks of log data as generated]
```

Client receives log lines as they occur, enabling real-time monitoring.

---

## Multipart Form Data

### API Rejection of Multipart Encoding

The Anthropic API does **not** accept multipart form data (`multipart/form-data`) for any endpoints. All requests must use `application/json` encoding exclusively.

Attempting to send multipart requests results in a `400 Bad Request` error:

```json
{
  "type": "error",
  "error": {
    "type": "invalid_request_error",
    "message": "Invalid content type. Expected application/json"
  }
}
```

### Binary Data Transmission Without Multipart

Despite rejecting multipart encoding, the API supports binary data transmission through base64 encoding embedded within JSON payloads.

#### Image Upload Pattern

Images are transmitted as base64-encoded strings within JSON content blocks:

```json
{
  "model": "claude-sonnet-4-20250514",
  "messages": [{
    "role": "user",
    "content": [
      {
        "type": "image",
        "source": {
          "type": "base64",
          "media_type": "image/jpeg",
          "data": "/9j/4AAQSkZJRgABAQAAAQABAAD..."
        }
      },
      {
        "type": "text",
        "text": "What's in this image?"
      }
    ]
  }]
}
```

The entire request, including the base64 image data, is wrapped in a single JSON envelope with `Content-Type: application/json`.

#### Document Upload Pattern

PDFs follow the identical pattern:

```json
{
  "type": "document",
  "source": {
    "type": "base64",
    "media_type": "application/pdf",
    "data": "JVBERi0xLjQKJeLjz9MKMSAwIG9iago8PAovVHlwZSAv..."
  }
}
```

### Rationale for JSON-Only Architecture

The API's rejection of multipart encoding stems from several design decisions:

#### Parsing Simplicity

JSON-only requests eliminate the complexity of multipart boundary parsing, field extraction, and Content-Disposition header interpretation. Every request follows identical parsing logic regardless of content.

#### Type Safety

JSON schema validation applies uniformly across all request fields. Multipart encoding would require separate validation paths for form fields versus JSON fields.

#### Streaming Compatibility

The API's streaming response model (Server-Sent Events) operates on JSON structures. Accepting multipart requests while returning JSON responses creates asymmetry in the protocol.

#### Base64 Overhead Acceptability

For the API's use cases (images and documents as context for language model inference), the ~33% size overhead of base64 encoding is acceptable given typical file sizes (images: 100KB-5MB, PDFs: <10MB per document).

### Size Implications of Base64 Encoding

Base64 encoding expands binary data by approximately 33%:

|Raw Binary Size|Base64 Encoded Size|Overhead|
|---|---|---|
|100 KB|133 KB|+33 KB|
|1 MB|1.33 MB|+333 KB|
|5 MB|6.67 MB|+1.67 MB|

This overhead is included in request size limits. The API enforces a 5MB limit per individual image or document **after** base64 decoding, meaning the encoded string in JSON can be up to ~6.67MB.

### Request Size Limits

Total request size (including all JSON overhead, multiple images, text content, and base64 data) is limited to:

- **Standard tier**: 10MB per request
- **Images**: 5MB per image (decoded size)
- **Documents**: 32MB per document (decoded size)

Multiple images can be included in a single request as long as the cumulative encoded size remains under the total request limit.

### Alternative: URL-Based Resource Loading

To avoid base64 overhead, resources can be referenced by URL:

```json
{
  "type": "image",
  "source": {
    "type": "url",
    "url": "https://example.com/image.jpg"
  }
}
```

The API fetches the resource directly from the URL, eliminating base64 encoding entirely. This is the preferred method for large files or when files are already hosted.

#### URL Source Requirements

- URLs must use `https://` protocol (http:// rejected for security)
- Resources must be publicly accessible (no authentication supported)
- Response must include correct `Content-Type` header matching the resource type
- Resources must be available within the API's fetch timeout (~10 seconds)

### Performance Characteristics

#### Multipart vs JSON+Base64 Comparison

|Aspect|Multipart Form Data|JSON + Base64|
|---|---|---|
|**Encoding overhead**|None (binary as-is)|+33% size|
|**Parse complexity**|High (boundary detection)|Low (standard JSON)|
|**Request construction**|Complex (libraries needed)|Simple (native JSON)|
|**Type validation**|Mixed (per-field logic)|Uniform (JSON schema)|
|**Network efficiency**|Better for large files|Acceptable for typical sizes|

For the API's target file sizes (images under 5MB), the base64 overhead adds negligible latency (~100-300ms for encoding/decoding on modern hardware).

### Client Implementation Patterns

#### Python Implementation

```python
import base64
import json
import requests

