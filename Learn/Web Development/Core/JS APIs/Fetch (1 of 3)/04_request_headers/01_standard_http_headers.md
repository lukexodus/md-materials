## Standard HTTP Headers


### General Headers

Headers applicable to both requests and responses, providing information about the message itself rather than the content.

**Cache-Control**

Directives for caching mechanisms in both requests and responses.

Request directives:

- `no-cache`: Requires validation with origin server before using cached response
- `no-store`: Prohibits storage of request or response
- `max-age=<seconds>`: Maximum age of cached response client will accept
- `max-stale[=<seconds>]`: Client accepts stale responses
- `min-fresh=<seconds>`: Client wants response fresh for at least specified time
- `no-transform`: Intermediaries must not transform content
- `only-if-cached`: Client wants cached response only, no network fetch

Response directives:

- `public`: Any cache may store response
- `private`: Only client-specific cache may store response
- `no-cache`: Must revalidate with origin before using
- `no-store`: Must not store any part of request or response
- `max-age=<seconds>`: Maximum time response considered fresh
- `s-maxage=<seconds>`: Overrides max-age for shared caches
- `must-revalidate`: Once stale, must revalidate before reuse
- `proxy-revalidate`: Like must-revalidate but only for shared caches
- `immutable`: Response body will not change; revalidation unnecessary
- `stale-while-revalidate=<seconds>`: Serve stale response while revalidating
- `stale-if-error=<seconds>`: Serve stale response if revalidation fails

**Connection**

Controls whether network connection stays open after current transaction.

Values:

- `keep-alive`: Maintain persistent connection
- `close`: Close connection after response
- `Upgrade`: Connection will upgrade to different protocol

HTTP/1.1 defaults to `keep-alive`. HTTP/2 prohibits this header.

**Date**

Timestamp when message was originated.

```
Date: Wed, 21 Oct 2015 07:28:00 GMT
```

Format follows RFC 5322 (updated RFC 2822). All HTTP dates use GMT timezone.

**Pragma**

Legacy HTTP/1.0 cache control. Only defined value:

```
Pragma: no-cache
```

Equivalent to `Cache-Control: no-cache`. Included for backward compatibility.

**Trailer**

Indicates presence of trailer fields in chunked transfer encoding.

```
Trailer: Expires, Content-MD5
```

Allows header fields after message body in chunked encoding.

**Transfer-Encoding**

Specifies encoding form used to transfer message body.

```
Transfer-Encoding: chunked
Transfer-Encoding: compress, chunked
```

Values: `chunked`, `compress`, `deflate`, `gzip`, `identity`

Applied in order listed. Must include `chunked` if used.

**Upgrade**

Proposes protocol upgrade or switch.

```
Upgrade: HTTP/2.0, SHTTP/1.3, IRC/6.9, RTA/x11
```

Paired with `Connection: Upgrade`. Server responds with `101 Switching Protocols` if accepting.

**Via**

Added by proxies and gateways to track message forwarding.

```
Via: 1.1 vegur
Via: 1.0 fred, 1.1 example.com (Apache/1.1)
```

Format: `<protocol-version> <received-by> [<comment>]`

**Warning**

Carries additional information about message status or transformation.

```
Warning: 110 anderson/1.3.37 "Response is stale"
Warning: 299 - "Miscellaneous warning"
```

Format: `<warn-code> <warn-agent> "<warn-text>" ["<warn-date>"]`

Common codes:

- `110`: Response is Stale
- `111`: Revalidation Failed
- `112`: Disconnected Operation
- `113`: Heuristic Expiration
- `199`: Miscellaneous Warning
- `214`: Transformation Applied
- `299`: Miscellaneous Persistent Warning

### Request Headers

Headers sent by client to provide information about request or client preferences.

**Accept**

Media types client can process, with quality values.

```
Accept: text/html, application/xhtml+xml, application/xml;q=0.9, */*;q=0.8
Accept: application/json
```

Quality values (q) range 0-1, default 1.0. Server selects best match.

**Accept-Charset**

Character sets client supports.

```
Accept-Charset: utf-8, iso-8859-1;q=0.5
Accept-Charset: utf-8, *;q=0.8
```

UTF-8 assumed acceptable if not specified. Largely deprecated as UTF-8 dominates.

**Accept-Encoding**

Compression algorithms client supports.

```
Accept-Encoding: gzip, deflate, br
Accept-Encoding: gzip;q=1.0, identity;q=0.5, *;q=0
```

Common values: `gzip`, `deflate`, `br` (Brotli), `compress`, `identity` (no encoding), `*` (any)

**Accept-Language**

Preferred natural languages for response.

```
Accept-Language: en-US, en;q=0.9, fr;q=0.8
Accept-Language: de-DE, de;q=0.9, en;q=0.8
```

Language tags follow RFC 5646. Quality values indicate preference.

**Authorization**

Credentials for authenticating client to server.

```
Authorization: Basic dXNlcjpwYXNzd29yZA==
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
Authorization: Digest username="user", realm="protected", nonce="dcd98b7102dd2f0e8b11d0f600bfb0c093"
```

Schemes: `Basic`, `Bearer`, `Digest`, `HOBA`, `Mutual`, `Negotiate`, `OAuth`, `SCRAM-SHA-1`, `SCRAM-SHA-256`, `vapid`

**Cookie**

Stored cookies sent to server.

```
Cookie: sessionid=abc123; theme=dark; lang=en
```

Multiple cookies separated by semicolons. No quality values or attributes (those only in Set-Cookie).

**Expect**

Expected behavior server must support.

```
Expect: 100-continue
```

Only defined expectation is `100-continue`. Client expects server to respond with `100 Continue` before sending request body. Useful for large payloads to avoid sending data to servers that will reject.

**From**

Email address of user controlling client.

```
From: user@example.com
```

Intended for logging and identifying source of invalid requests. Privacy concerns limit usage.

**Host**

Domain name and port of target server.

```
Host: example.com
Host: example.com:8080
```

Required in HTTP/1.1. Enables virtual hosting (multiple domains on single IP).

**If-Match**

Makes request conditional on matching ETag.

```
If-Match: "33a64df551425fcc55e4d42a148795d9f25f89d4"
If-Match: "v1", "v2", "v3"
If-Match: *
```

Used with PUT/PATCH/DELETE to prevent lost updates. Server returns `412 Precondition Failed` if no match.

**If-Modified-Since**

Makes GET/HEAD conditional on modification date.

```
If-Modified-Since: Wed, 21 Oct 2015 07:28:00 GMT
```

Server returns `304 Not Modified` if resource unchanged since specified date.

**If-None-Match**

Makes request conditional on non-matching ETag.

```
If-None-Match: "33a64df551425fcc55e4d42a148795d9f25f89d4"
If-None-Match: "v1", "v2", "v3"
If-None-Match: *
```

For GET/HEAD: Returns `304 Not Modified` if ETag matches. For other methods: Returns `412 Precondition Failed` if ETag matches.

Used for cache validation and preventing lost updates.

**If-Range**

Combines conditional request with range request.

```
If-Range: "33a64df551425fcc55e4d42a148795d9f25f89d4"
If-Range: Wed, 21 Oct 2015 07:28:00 GMT
```

If condition matches, server returns specified range. Otherwise, returns entire resource.

**If-Unmodified-Since**

Makes request conditional on no modification since date.

```
If-Unmodified-Since: Wed, 21 Oct 2015 07:28:00 GMT
```

Server returns `412 Precondition Failed` if resource modified. Used with unsafe methods to prevent lost updates.

**Max-Forwards**

Limits proxy/gateway hops for TRACE and OPTIONS methods.

```
Max-Forwards: 10
```

Each proxy decrements value. At zero, proxy must respond rather than forward.

**Proxy-Authorization**

Credentials for authenticating to proxy.

```
Proxy-Authorization: Basic dXNlcjpwYXNzd29yZA==
```

Similar to Authorization but for proxy authentication.

**Range**

Requests specific byte range(s) of resource.

```
Range: bytes=0-1023
Range: bytes=0-1023, 2048-4095
Range: bytes=-1024
Range: bytes=1024-
```

Formats:

- `bytes=<start>-<end>`: Specific range (inclusive)
- `bytes=-<suffix-length>`: Last N bytes
- `bytes=<start>-`: From start to end
- Multiple ranges separated by commas

**Referer**

URL of page that linked to current request.

```
Referer: https://example.com/page.html
```

Misspelling is intentional (historical). Used for analytics, logging, caching optimization. Privacy-sensitive.

**TE**

Transfer encodings client accepts in response.

```
TE: trailers
TE: trailers, deflate;q=0.5
```

Similar to Accept-Encoding but for transfer encodings (not content encodings). `trailers` indicates client accepts trailer fields.

**User-Agent**

Client software identification.

```
User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36
User-Agent: curl/7.64.1
```

Format varies widely. Contains browser/client name, version, platform, rendering engine. Used for statistics, compatibility detection.

### Response Headers

Headers sent by server providing information about response or server.

**Accept-Ranges**

Indicates server support for range requests.

```
Accept-Ranges: bytes
Accept-Ranges: none
```

`bytes`: Server supports byte-range requests `none`: Server does not support range requests

**Age**

Time in seconds since response generated at origin server.

```
Age: 3600
```

Primarily used by caches to indicate staleness.

**ETag**

Identifier for specific version of resource.

```
ETag: "33a64df551425fcc55e4d42a148795d9f25f89d4"
ETag: W/"33a64df551425fcc55e4d42a148795d9f25f89d4"
```

Strong ETags: Any change produces different value Weak ETags: Prefixed with `W/`, semantically equivalent resources may share

Used for cache validation and optimistic concurrency control.

**Location**

URL to redirect client or location of newly created resource.

```
Location: https://example.com/new-location
Location: /new-page
```

Used with 3xx redirects and 201 Created status. Can be absolute or relative URL.

**Proxy-Authenticate**

Authentication method proxy requires.

```
Proxy-Authenticate: Basic realm="Access to internal site"
```

Sent with `407 Proxy Authentication Required`. Similar to WWW-Authenticate but for proxies.

**Retry-After**

Indicates how long client should wait before making follow-up request.

```
Retry-After: 120
Retry-After: Wed, 21 Oct 2015 07:28:00 GMT
```

Used with `503 Service Unavailable` or `429 Too Many Requests`. Value in seconds or HTTP date.

**Server**

Information about origin server software.

```
Server: Apache/2.4.1 (Unix)
Server: nginx/1.21.0
Server: cloudflare
```

Analogous to User-Agent. Often simplified or removed for security reasons.

**Vary**

Lists request headers that determine response variation.

```
Vary: Accept-Encoding
Vary: User-Agent, Accept-Encoding
Vary: *
```

Tells caches which headers create different response versions. `*` means response varies based on factors not expressible via headers.

**WWW-Authenticate**

Authentication method required for resource access.

```
WWW-Authenticate: Basic realm="Protected Area"
WWW-Authenticate: Bearer realm="example", charset="UTF-8"
WWW-Authenticate: Digest realm="protected", qop="auth", nonce="dcd98b7102dd2f0e8b11d0f600bfb0c093"
```

Sent with `401 Unauthorized`. Can specify multiple challenges.

### Entity Headers

Headers describing message body content or resource.

**Allow**

Lists HTTP methods resource supports.

```
Allow: GET, HEAD, OPTIONS
Allow: GET, POST, PUT, DELETE
```

Used with `405 Method Not Allowed` or OPTIONS response.

**Content-Encoding**

Encoding transformations applied to message body.

```
Content-Encoding: gzip
Content-Encoding: deflate, gzip
```

Applied encodings listed in order. Client must decode in reverse order. Different from Transfer-Encoding (which applies to message transport).

**Content-Language**

Natural language(s) of intended audience.

```
Content-Language: en
Content-Language: en-US
Content-Language: en, fr
```

Does not necessarily describe all languages in content.

**Content-Length**

Size of message body in bytes.

```
Content-Length: 3495
```

Required for persistent connections unless using chunked encoding. Must match actual body size.

**Content-Location**

Alternate URL for returned content.

```
Content-Location: /documents/report.pdf
Content-Location: https://example.com/documents/report.pdf
```

Indicates URL where identical resource can be accessed. Useful when content negotiation or other mechanisms return variant.

**Content-MD5**

Base64-encoded MD5 hash of message body.

```
Content-MD5: Q2hlY2sgSW50ZWdyaXR5IQ==
```

Provides end-to-end integrity check. Deprecated in favor of other integrity mechanisms.

**Content-Range**

Indicates position of partial content within full resource.

```
Content-Range: bytes 0-1023/5000
Content-Range: bytes 2048-4095/*
Content-Range: bytes */5000
```

Format: `<unit> <range-start>-<range-end>/<total-size>`

`*` for unknown values. Used with `206 Partial Content` or `416 Range Not Satisfiable`.

**Content-Type**

Media type of message body.

```
Content-Type: text/html; charset=utf-8
Content-Type: application/json
Content-Type: multipart/form-data; boundary=----WebKitFormBoundary7MA4YWxkTrZu0gW
```

Includes media type and optional parameters (charset, boundary). Essential for proper content interpretation.

**Expires**

Date/time after which response considered stale.

```
Expires: Wed, 21 Oct 2015 07:28:00 GMT
Expires: 0
```

HTTP date or invalid date (`0`) for already-expired. `Cache-Control: max-age` takes precedence if both present.

**Last-Modified**

Date/time resource last modified.

```
Last-Modified: Wed, 21 Oct 2015 07:28:00 GMT
```

Used for cache validation with If-Modified-Since. Less precise than ETags but widely supported.

### CORS Headers

Headers controlling cross-origin resource sharing.

**Access-Control-Allow-Origin**

Specifies origins permitted to access resource.

```
Access-Control-Allow-Origin: *
Access-Control-Allow-Origin: https://example.com
Access-Control-Allow-Origin: https://example.com, https://another.com
```

`*` allows all origins. Specific origins required when credentials included.

**Access-Control-Allow-Credentials**

Indicates whether response can be exposed when credentials included.

```
Access-Control-Allow-Credentials: true
```

Only valid value is `true`. Omit if false. Cannot combine with `Access-Control-Allow-Origin: *`.

**Access-Control-Allow-Methods**

Lists HTTP methods allowed for cross-origin requests.

```
Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS
```

Responds to preflight OPTIONS request.

**Access-Control-Allow-Headers**

Lists headers allowed in actual request.

```
Access-Control-Allow-Headers: Content-Type, Authorization, X-Custom-Header
```

Responds to preflight OPTIONS request specifying which custom headers permitted.

**Access-Control-Expose-Headers**

Lists response headers accessible to client-side code.

```
Access-Control-Expose-Headers: Content-Length, X-Request-ID
```

By default, only simple response headers exposed: Cache-Control, Content-Language, Content-Type, Expires, Last-Modified, Pragma.

**Access-Control-Max-Age**

How long preflight response can be cached.

```
Access-Control-Max-Age: 86400
```

Value in seconds. Reduces preflight request frequency.

**Access-Control-Request-Method**

Used in preflight to indicate actual request method.

```
Access-Control-Request-Method: PUT
```

Sent by browser in OPTIONS preflight request.

**Access-Control-Request-Headers**

Used in preflight to indicate actual request headers.

```
Access-Control-Request-Headers: Content-Type, X-Custom-Header
```

Sent by browser in OPTIONS preflight request.

**Origin**

Indicates request origin (scheme, host, port).

```
Origin: https://example.com
Origin: https://example.com:8080
```

Sent automatically by browsers for cross-origin requests. Servers use for CORS decisions.

### Security Headers

Headers enhancing security of web applications.

**Content-Security-Policy**

Controls resources browser allowed to load.

```
Content-Security-Policy: default-src 'self'; script-src 'self' https://trusted.cdn.com; style-src 'self' 'unsafe-inline'
```

Directives:

- `default-src`: Fallback for other directives
- `script-src`: Valid JavaScript sources
- `style-src`: Valid stylesheet sources
- `img-src`: Valid image sources
- `connect-src`: Valid AJAX/WebSocket/EventSource endpoints
- `font-src`: Valid font sources
- `object-src`: Valid plugin sources
- `media-src`: Valid audio/video sources
- `frame-src`: Valid iframe sources
- `frame-ancestors`: Valid parent frames
- `base-uri`: Valid <base> element URLs
- `form-action`: Valid form submission targets
- `upgrade-insecure-requests`: Upgrades HTTP to HTTPS
- `block-all-mixed-content`: Blocks HTTP resources on HTTPS pages

**Content-Security-Policy-Report-Only**

CSP in report-only mode (violations reported but not enforced).

```
Content-Security-Policy-Report-Only: default-src 'self'; report-uri /csp-violation-report
```

Allows testing policies before enforcement.

**Strict-Transport-Security**

Enforces HTTPS connections.

```
Strict-Transport-Security: max-age=31536000; includeSubDomains; preload
```

Parameters:

- `max-age`: Duration (seconds) to remember HTTPS-only rule
- `includeSubDomains`: Apply to all subdomains
- `preload`: Request inclusion in browser HSTS preload lists

**X-Content-Type-Options**

Prevents MIME type sniffing.

```
X-Content-Type-Options: nosniff
```

Only defined value: `nosniff`. Forces browser to respect declared Content-Type.

**X-Frame-Options**

Controls whether page can be displayed in frame/iframe.

```
X-Frame-Options: DENY
X-Frame-Options: SAMEORIGIN
X-Frame-Options: ALLOW-FROM https://example.com
```

Values:

- `DENY`: No framing allowed
- `SAMEORIGIN`: Only same-origin framing
- `ALLOW-FROM <uri>`: Specific origin allowed (limited browser support)

Largely superseded by CSP `frame-ancestors` directive.

**X-XSS-Protection**

Enables/configures XSS filter in older browsers.

```
X-XSS-Protection: 0
X-XSS-Protection: 1
X-XSS-Protection: 1; mode=block
X-XSS-Protection: 1; report=https://example.com/report
```

Largely deprecated. Modern browsers rely on CSP instead.

**Referrer-Policy**

Controls referrer information sent with requests.

```
Referrer-Policy: no-referrer
Referrer-Policy: no-referrer-when-downgrade
Referrer-Policy: origin
Referrer-Policy: origin-when-cross-origin
Referrer-Policy: same-origin
Referrer-Policy: strict-origin
Referrer-Policy: strict-origin-when-cross-origin
Referrer-Policy: unsafe-url
```

Policies:

- `no-referrer`: Never send referrer
- `no-referrer-when-downgrade`: Send except HTTPS→HTTP (default)
- `origin`: Send only origin
- `origin-when-cross-origin`: Full URL for same-origin, origin only cross-origin
- `same-origin`: Send only for same-origin requests
- `strict-origin`: Send origin except HTTPS→HTTP
- `strict-origin-when-cross-origin`: Full URL same-origin, origin cross-origin (except HTTPS→HTTP)
- `unsafe-url`: Always send full URL

**Permissions-Policy**

Controls browser features and APIs available to page.

```
Permissions-Policy: geolocation=(), microphone=(), camera=(self)
Permissions-Policy: payment=(self "https://trusted-payment.com")
```

Formerly Feature-Policy. Format: `<directive>=(<allowlist>)`

Common directives: `accelerometer`, `ambient-light-sensor`, `autoplay`, `battery`, `camera`, `display-capture`, `geolocation`, `gyroscope`, `magnetometer`, `microphone`, `midi`, `payment`, `usb`, `vibrate`, `vr`

Allowlist values: `*` (all origins), `self` (same origin), `src` (iframe src), `none`/`()` (blocked), specific origins

**Cross-Origin-Embedder-Policy**

Controls loading cross-origin resources without explicit permission.

```
Cross-Origin-Embedder-Policy: unsafe-none
Cross-Origin-Embedder-Policy: require-corp
```

Values:

- `unsafe-none`: Default, no restrictions
- `require-corp`: Resources must have CORP header or be same-origin

Required for certain powerful features like SharedArrayBuffer.

**Cross-Origin-Opener-Policy**

Isolates browsing context from cross-origin windows.

```
Cross-Origin-Opener-Policy: unsafe-none
Cross-Origin-Opener-Policy: same-origin
Cross-Origin-Opener-Policy: same-origin-allow-popups
```

Values:

- `unsafe-none`: Default, no isolation
- `same-origin`: Isolates from cross-origin windows
- `same-origin-allow-popups`: Same-origin isolation except popups to non-COOP pages

**Cross-Origin-Resource-Policy**

Declares whether resource can be loaded cross-origin.

```
Cross-Origin-Resource-Policy: same-origin
Cross-Origin-Resource-Policy: same-site
Cross-Origin-Resource-Policy: cross-origin
```

Protects against side-channel attacks like Spectre.

### Custom and Extension Headers

**X-Forwarded-For**

Identifies originating client IP when behind proxies.

```
X-Forwarded-For: 203.0.113.195
X-Forwarded-For: 203.0.113.195, 70.41.3.18, 150.172.238.178
```

Left-most IP is original client. Each proxy appends client IP it saw.

Not standardized. `Forwarded` header is standardized replacement.

**X-Forwarded-Host**

Original Host header value when behind proxies.

```
X-Forwarded-Host: example.com
```

**X-Forwarded-Proto**

Original protocol (HTTP/HTTPS) when behind proxies.

```
X-Forwarded-Proto: https
```

**Forwarded**

Standardized version of X-Forwarded-* headers.

```
Forwarded: for=192.0.2.60;proto=http;by=203.0.113.43
Forwarded: for=192.0.2.43, for=198.51.100.17
```

Parameters: `by` (proxy interface), `for` (client), `host` (original Host), `proto` (protocol)

**X-Real-IP**

Alternative to X-Forwarded-For, typically single IP.

```
X-Real-IP: 203.0.113.195
```

Used by some proxies (notably nginx).

**X-Request-ID** / **X-Correlation-ID**

Unique identifier for tracking request through distributed systems.

```
X-Request-ID: f058ebd6-02f7-4d3f-942e-904344e8cde5
X-Correlation-ID: abc123-def456-ghi789
```

Format varies. Often UUID. Helps correlate logs across services.

**X-Powered-By**

Technology powering the website.

```
X-Powered-By: PHP/7.4.3
X-Powered-By: Express
```

Often removed in production for security (information leakage).

**X-Rate-Limit-***

Rate limiting information.

```
X-Rate-Limit-Limit: 100
X-Rate-Limit-Remaining: 87
X-Rate-Limit-Reset: 1634567890
```

Not standardized. Various conventions exist. Common headers:

- `X-Rate-Limit-Limit`: Maximum requests per window
- `X-Rate-Limit-Remaining`: Remaining requests in current window
- `X-Rate-Limit-Reset`: Timestamp when limit resets (Unix epoch or HTTP date)

### Cookie-Related Headers

**Set-Cookie**

Sends cookie from server to client.

```
Set-Cookie: sessionid=abc123; Path=/; Domain=example.com; Secure; HttpOnly; SameSite=Strict; Max-Age=3600
```

Attributes:

- `Expires`: Expiration date (HTTP date format)
- `Max-Age`: Lifetime in seconds (takes precedence over Expires)
- `Domain`: Domain cookie valid for (defaults to current domain, excluding subdomains)
- `Path`: URL path cookie valid for (defaults to current path)
- `Secure`: Only send over HTTPS
- `HttpOnly`: Inaccessible to JavaScript
- `SameSite`: CSRF protection
    - `Strict`: Only same-site requests
    - `Lax`: Same-site + top-level navigation from external sites
    - `None`: All requests (requires Secure)

Multiple Set-Cookie headers can appear in single response (one per cookie).

### Content Negotiation Headers

**Accept-Patch**

Advertises supported patch document formats.

```
Accept-Patch: application/json-patch+json, application/merge-patch+json
```

Sent in OPTIONS response or 415 Unsupported Media Type.

**Accept-Post**

Advertises supported POST request content types.

```
Accept-Post: application/json, application/xml, text/plain
```

Informs clients which media types server accepts for POST.

**Accept-Datetime**

Requests specific datetime version of resource (Memento protocol).

```
Accept-Datetime: Thu, 31 May 2007 20:35:00 GMT
```

Used with web archives and versioned resources.

### WebSocket Headers

**Sec-WebSocket-Key**

Random value proving browser supports WebSockets.

```
Sec-WebSocket-Key: dGhlIHNhbXBsZSBub25jZQ==
```

Base64-encoded random 16-byte value. Server uses to compute Sec-WebSocket-Accept.

**Sec-WebSocket-Accept**

Server's computed response to Sec-WebSocket-Key.

```
Sec-WebSocket-Accept: s3pPLMBiTxaQ9kYGzzhZRbK+xOo=
```

Proves server understands WebSocket protocol. Computed from key + magic string, SHA-1 hashed, base64-encoded.

**Sec-WebSocket-Version**

WebSocket protocol version.

```
Sec-WebSocket-Version: 13
```

Current version is 13.

**Sec-WebSocket-Protocol**

Requested sub-protocols.

```
Sec-WebSocket-Protocol: chat, superchat
```

Client proposes application-level protocols. Server selects one in response.

**Sec-WebSocket-Extensions**

Requested protocol extensions.

```
Sec-WebSocket-Extensions: permessage-deflate; client_max_window_bits
```

Common extension: `permessage-deflate` (compression)

### HTTP/2 Pseudo-Headers

Not actual HTTP headers but used in HTTP/2 framing.

**:method**

HTTP method (GET, POST, etc.)

**:scheme**

URL scheme (http, https)

**:authority**

Authority portion of URL (host + optional port)

**:path**

Path and query string

**:status**

Response status code (responses only)

These replace parts of HTTP/1.1 request/status lines. In HTTP/2, transmitted as header-like fields with `:` prefix.

### Deprecation and Timing Headers

**Deprecation**

Indicates resource deprecated, with optional timestamp.

```
Deprecation: true
Deprecation: @1640995200
```

Boolean or Unix timestamp. Alerts clients to plan migrations.

**Sunset**

Date/time resource will be removed.

```
Sunset: Wed, 21 Oct 2025 07:28:00 GMT
```

HTTP date format. More specific than Deprecation.

**Server-Timing**

Performance metrics from server.

```
Server-Timing: db;dur=53, app;dur=47.2
Server-Timing: cache;desc="Cache Read";dur=23.2, db;dur=53, app;dur=47.2
```

Metric format: `<name>;dur=<duration>;desc="<description>"`

Duration in milliseconds. Visible in browser developer tools.

**Timing-Allow-Origin**

Origins allowed to access Resource Timing API data.

```
Timing-Allow-Origin: *
Timing-Allow-Origin: https://example.com
```

Without this, cross-origin resources show limited timing data.

### Client Hints

Request headers allowing proactive content negotiation based on device/network conditions.

**Sec-CH-UA**

User agent's brand and version.

```
Sec-CH-UA: " Not A;Brand";v="99", "Chromium";v="96", "Google Chrome";v="96"
```

Structured header with brand list. Part of User-Agent Client Hints replacing traditional User-Agent.

**Sec-CH-UA-Mobile**

Whether user agent is mobile device.

```
Sec-CH-UA-Mobile: ?1
```

Structured boolean: `?1` (true) or `?0` (false)

**Sec-CH-UA-Platform**

Platform/OS user agent runs on.

```
Sec-CH-UA-Platform: "Windows"
```

Common values: "Android", "Chrome OS", "iOS", "Linux", "macOS", "Windows"

**Sec-CH-UA-Arch**

Platform architecture.

```
Sec-CH-UA-Arch: "x86"
```

Examples: "x86", "ARM"

**Sec-CH-UA-Bitness**

Architecture bitness.

```
Sec-CH-UA-Bitness: "64"
```

Typically "32" or "64"

**Sec-CH-UA-Model**

Device model.

```
Sec-CH-UA-Model: "Pixel 5"
```

Empty string for desktop.

**Sec-CH-UA-Full-Version**

Complete user agent version.

```
Sec-CH-UA-Full-Version: "96.0.4664.45"
```

**Device-Memory**

Approximate device RAM in GB.

```
Device-Memory: 8
```

Values:

```
0.25, 0.5, 1, 2, 4, 8 (rounded to specific tiers)
```

**Viewport-Width**

Layout viewport width in CSS pixels.

```
Viewport-Width: 1920
```

**Width**

Desired resource width in physical pixels.

```
Width: 1920
```

Used for image optimization.

**DPR**

Device pixel ratio.

```
DPR: 2
```

Pixels per CSS pixel. Common values: 1, 1.5, 2, 3

**Downlink**

Effective connection bandwidth (Mbps).

```
Downlink: 10
```

Estimated based on recent connections.

**ECT**

Effective connection type.

```
ECT: 4g
```

Values: `slow-2g`, `2g`, `3g`, `4g`

**RTT**

Round-trip time estimate (ms).

```
RTT: 100
```

Application-layer RTT.

**Save-Data**

Client preference for reduced data usage.

```
Save-Data: on
```

Only defined value: `on`. Omit when off.

**Accept-CH**

Advertises client hints server supports.

```
Accept-CH: DPR, Viewport-Width, Width
```

Comma-separated list. Sent by server to request specific hints.

**Accept-CH-Lifetime**

Duration (seconds) to remember Accept-CH preference.

```
Accept-CH-Lifetime: 86400
```

[Unverified] Deprecated in favor of Permissions-Policy mechanism for client hints.

### Link Header

**Link**

Relationships between current resource and other resources.

```
Link: <https://example.com/page2>; rel="next"
Link: <https://cdn.example.com/style.css>; rel="preload"; as="style"
Link: <https://example.com>; rel="canonical"
```

Format: `<URI>; rel="<relationship>"; [optional-params]`

Common `rel` values:

- `alternate`: Alternate representation
- `canonical`: Preferred URL
- `dns-prefetch`: Hint to pre-resolve DNS
- `icon`: Icon resource
- `manifest`: Web app manifest
- `next`/`prev`: Pagination
- `preconnect`: Hint to pre-connect
- `prefetch`: Hint to fetch for future navigation
- `preload`: Hint to fetch for current page
- `prerender`: Hint to pre-render
- `stylesheet`: CSS stylesheet

Additional parameters: `as` (resource type), `type` (MIME type), `media` (media query), `crossorigin`, `integrity`

Multiple Link headers or comma-separated values allowed.

### Alt-Svc

**Alt-Svc**

Advertises alternative services (protocol/host/port combinations).

```
Alt-Svc: h2=":443"; ma=2592000
Alt-Svc: h2="alt.example.com:443", h2=":443"
Alt-Svc: clear
```

Format: `<protocol>=<alt-authority>; ma=<max-age-seconds>`

Allows advertising HTTP/2, HTTP/3, or alternative hosts for same resource. `clear` removes previous advertisements.

Common protocols: `h2` (HTTP/2), `h3` (HTTP/3)

### Keep-Alive

**Keep-Alive**

Parameters for persistent connection.

```
Keep-Alive: timeout=5, max=100
```

Parameters:

- `timeout`: Seconds server will keep idle connection open
- `max`: Maximum requests on connection before closing

HTTP/1.1 only (HTTP/2 manages connections differently). Requires `Connection: keep-alive` header.

### NEL and Reporting

**NEL**

Network Error Logging configuration.

```
NEL: {"report_to":"default","max_age":2592000,"include_subdomains":true}
```

JSON object configuring network error reporting. Parameters:

- `report_to`: Reporting group name
- `max_age`: Policy lifetime (seconds)
- `include_subdomains`: Apply to subdomains
- `success_fraction`: Fraction of successful requests to report (0-1)
- `failure_fraction`: Fraction of failed requests to report (0-1)

**Report-To**

Defines endpoints for violation/error reporting.

```
Report-To: {"group":"default","max_age":10886400,"endpoints":[{"url":"https://example.com/reports"}],"include_subdomains":true}
```

JSON object with:

- `group`: Group name
- `max_age`: Policy lifetime
- `endpoints`: Array of reporting endpoints
- `include_subdomains`: Apply to subdomains

Used by CSP, NEL, and other reporting mechanisms.

**Reporting-Endpoints**

Newer alternative to Report-To.

```
Reporting-Endpoints: default="https://example.com/reports", csp-endpoint="https://example.com/csp-reports"
```

Simpler syntax than Report-To. Named endpoints for different report types.

---

