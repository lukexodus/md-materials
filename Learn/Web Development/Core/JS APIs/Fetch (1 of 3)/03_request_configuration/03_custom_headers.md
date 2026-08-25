## Custom Headers


### Header Categories

Custom headers fall into several categories based on their origin and purpose:

**Application-Specific Headers** Headers defined by the application for internal communication between client and server. These typically use prefixes like `X-` (legacy convention) or application namespaces (e.g., `MyApp-Session-ID`, `API-Key`).

**Standardized Extension Headers** Headers that started as custom but became de facto standards through widespread adoption (e.g., `X-Forwarded-For`, `X-Content-Type-Options`).

**Proprietary Headers** Browser or CDN-specific headers that provide additional functionality (e.g., `CF-Ray` from Cloudflare, `X-Chrome-UMA-Enabled`).

### Setting Custom Headers

**Fetch API**

```javascript
fetch('https://api.example.com/data', {
  headers: {
    'X-API-Key': 'abc123',
    'X-Request-ID': crypto.randomUUID(),
    'X-Custom-Metadata': JSON.stringify({user: 'john'})
  }
});
```

**XMLHttpRequest**

```javascript
const xhr = new XMLHttpRequest();
xhr.open('GET', 'https://api.example.com/data');
xhr.setRequestHeader('X-API-Key', 'abc123');
xhr.setRequestHeader('X-Request-ID', crypto.randomUUID());
xhr.send();
```

**Server-Side (Node.js Example)**

```javascript
response.setHeader('X-Response-Time', '42ms');
response.setHeader('X-Server-Version', '2.1.0');
```

### Browser Restrictions on Custom Headers

**Forbidden Headers**

Browsers prevent JavaScript from setting certain headers to maintain security and protocol integrity. These forbidden header names include:

- `Accept-Charset`
- `Accept-Encoding`
- `Access-Control-Request-Headers`
- `Access-Control-Request-Method`
- `Connection`
- `Content-Length`
- `Cookie`
- `Date`
- `DNT`
- `Expect`
- `Host`
- `Keep-Alive`
- `Origin`
- `Referer`
- `TE`
- `Trailer`
- `Transfer-Encoding`
- `Upgrade`
- `Via`

Headers starting with `Proxy-` or `Sec-` are also forbidden from JavaScript manipulation.

**CORS Safelisted Headers**

For cross-origin requests, only certain headers are allowed without triggering a preflight:

- `Accept`
- `Accept-Language`
- `Content-Language`
- `Content-Type` (limited to `application/x-www-form-urlencoded`, `multipart/form-data`, or `text/plain`)

Any custom header triggers a CORS preflight OPTIONS request.

### CORS Preflight for Custom Headers

When sending custom headers cross-origin, the browser first sends a preflight request:

**Preflight Request:**

```
OPTIONS /api/resource HTTP/1.1
Host: api.example.com
Origin: https://myapp.com
Access-Control-Request-Method: POST
Access-Control-Request-Headers: x-api-key, x-request-id
```

**Required Server Response:**

```
HTTP/1.1 200 OK
Access-Control-Allow-Origin: https://myapp.com
Access-Control-Allow-Methods: POST, GET, OPTIONS
Access-Control-Allow-Headers: x-api-key, x-request-id
Access-Control-Max-Age: 86400
```

The `Access-Control-Allow-Headers` must explicitly list custom headers. Wildcards (`*`) work but exclude credentials mode.

### Common Custom Header Patterns

**Authentication Headers**

```javascript
// Bearer token
headers: {
  'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIs...'
}

// API key
headers: {
  'X-API-Key': 'sk_live_abc123...',
  'X-API-Secret': 'secret_key'
}

// Custom auth scheme
headers: {
  'X-Auth-Token': 'token123',
  'X-Auth-User': 'user@example.com'
}
```

**Request Tracking**

```javascript
headers: {
  'X-Request-ID': crypto.randomUUID(),
  'X-Correlation-ID': sessionId,
  'X-Trace-ID': generateTraceId()
}
```

These enable distributed tracing across microservices and help debug issues by tracking requests through multiple systems.

**Client Metadata**

```javascript
headers: {
  'X-Client-Version': '2.5.1',
  'X-Platform': 'web',
  'X-Device-ID': deviceIdentifier,
  'X-Session-ID': sessionToken
}
```

**Content Negotiation Extensions**

```javascript
headers: {
  'X-API-Version': 'v2',
  'X-Response-Format': 'compact',
  'X-Include-Deprecated': 'false'
}
```

**Rate Limiting Information**

Server response headers communicating rate limit status:

```
X-RateLimit-Limit: 1000
X-RateLimit-Remaining: 847
X-RateLimit-Reset: 1640000000
X-RateLimit-Retry-After: 3600
```

### Header Naming Conventions

**Legacy X- Prefix**

Historically, custom headers used the `X-` prefix (e.g., `X-Custom-Header`). RFC 6648 deprecated this convention in 2012, but many systems still use it.

**Modern Naming**

Current best practice uses descriptive names without the `X-` prefix:

- `API-Key` instead of `X-API-Key`
- `Request-ID` instead of `X-Request-ID`

[Inference] In practice, both conventions coexist, and the choice often depends on established API patterns or legacy compatibility requirements.

**Case Sensitivity**

HTTP header names are case-insensitive per RFC specifications. However, HTTP/2 and HTTP/3 require lowercase header names. Browsers normalize header names, but servers should handle case-insensitively.

### Response Header Access

**Reading Response Headers**

```javascript
fetch('https://api.example.com/data')
  .then(response => {
    const customHeader = response.headers.get('X-Custom-Data');
    const rateLimit = response.headers.get('X-RateLimit-Remaining');
    
    // Iterate all headers
    response.headers.forEach((value, key) => {
      console.log(`${key}: ${value}`);
    });
  });
```

**CORS Exposure**

By default, JavaScript can only read CORS-safelisted response headers:

- `Cache-Control`
- `Content-Language`
- `Content-Length`
- `Content-Type`
- `Expires`
- `Last-Modified`
- `Pragma`

To expose custom response headers cross-origin, servers must include:

```
Access-Control-Expose-Headers: X-Custom-Data, X-RateLimit-Remaining
```

Without this header, `response.headers.get('X-Custom-Data')` returns `null` even if the server sent it.

### Security Considerations

**Information Leakage**

Custom headers can leak sensitive information if not properly protected:

- **API keys in headers**: Vulnerable to XSS attacks if stored in JavaScript-accessible locations
- **Internal architecture details**: Headers like `X-Server-ID` or `X-Backend-Host` expose infrastructure
- **User information**: Headers containing PII should be encrypted or avoided

**Header Injection**

User-controlled content in headers creates injection vulnerabilities:

```javascript
// Vulnerable
const userId = getUserInput(); // Could contain "\r\nX-Admin: true"
fetch('/api', {
  headers: {'X-User-ID': userId}
});
```

Browsers typically prevent CRLF injection, but server-side code must validate header values to prevent HTTP response splitting attacks.

**Size Limits**

Headers have practical size constraints:

- Total request header size: Typically 8KB-16KB
- Individual header size: Usually no hard limit, but practically under 8KB
- Number of headers: Often limited to 100-200 per request

Exceeding these limits causes `431 Request Header Fields Too Large` errors.

### Caching Implications

**Vary Header**

Custom headers used for content negotiation should be listed in the `Vary` response header:

```
Vary: Accept-Language, X-API-Version, X-Device-Type
```

This instructs caches to store separate versions based on these header values. Overuse of `Vary` reduces cache efficiency.

**Cache Keys**

CDNs and proxy caches may include custom headers in cache keys. Headers like `X-User-ID` or `X-Session-ID` effectively disable caching by creating unique cache entries per user.

### Middleware and Proxy Headers

**Forwarding Headers**

Proxies and load balancers add headers tracking request routing:

```
X-Forwarded-For: 203.0.113.195, 198.51.100.178
X-Forwarded-Proto: https
X-Forwarded-Host: example.com
X-Real-IP: 203.0.113.195
```

**Standard Forwarded Header**

RFC 7239 defines a standardized `Forwarded` header replacing the `X-Forwarded-*` variants:

```
Forwarded: for=203.0.113.195;proto=https;host=example.com
```

[Inference] Adoption of the standard `Forwarded` header remains limited, with most systems still using the `X-Forwarded-*` headers due to legacy support requirements.

### Service Worker Interception

Service workers can read, modify, or add custom headers:

```javascript
self.addEventListener('fetch', (event) => {
  const request = event.request;
  
  // Read custom header
  const apiKey = request.headers.get('X-API-Key');
  
  // Create modified request
  const modifiedRequest = new Request(request, {
    headers: new Headers({
      ...Object.fromEntries(request.headers),
      'X-Service-Worker': 'active',
      'X-Cache-Strategy': 'network-first'
    })
  });
  
  event.respondWith(fetch(modifiedRequest));
});
```

Service workers can add headers that wouldn't trigger preflight since the final request originates from the service worker's scope.

### Server-Sent Events (SSE) Headers

SSE connections support custom headers in the initial request:

```javascript
const eventSource = new EventSource('https://api.example.com/events', {
  // Note: EventSource doesn't support custom headers directly
  // Must use alternatives like query parameters or cookies
});
```

[Unverified] The EventSource API specification doesn't provide a standard mechanism for custom headers. Workarounds include using query parameters for authentication or relying on cookies.

### WebSocket Handshake Headers

WebSocket upgrades allow custom headers during the handshake:

```javascript
const ws = new WebSocket('wss://api.example.com/socket');
// Note: Browser WebSocket API doesn't support custom headers
```

Browser WebSocket APIs don't support custom headers directly. Solutions include:

- Sending authentication in the initial frame after connection
- Using query parameters in the WebSocket URL
- Utilizing subprotocol negotiation via `Sec-WebSocket-Protocol`

Server-side WebSocket libraries can access and set custom headers during the handshake.

### Header Compression

**HTTP/2 HPACK**

HTTP/2 compresses headers using HPACK, which maintains a dynamic table of previously sent header name-value pairs. Frequently used custom headers benefit from compression after first transmission.

**HTTP/3 QPACK**

HTTP/3 uses QPACK, an improved header compression allowing out-of-order delivery while maintaining compression efficiency. Custom headers with predictable values compress well.

**Compression Considerations**

Highly variable custom header values (like unique request IDs or timestamps) compress poorly. Static custom headers (like API versions) compress effectively after first use.

### Header Inspection Tools

**Browser DevTools**

Network tab displays all request/response headers:

- Chrome DevTools: Network → Select request → Headers tab
- Firefox Developer Tools: Network → Select request → Headers tab
- Safari Web Inspector: Network → Select request → Headers section

**Programmatic Access**

```javascript
// Log all request headers (in Service Worker)
self.addEventListener('fetch', (event) => {
  console.log('Request headers:');
  for (const [key, value] of event.request.headers.entries()) {
    console.log(`${key}: ${value}`);
  }
});
```

### Header Best Practices

**Naming Guidelines**

1. Use descriptive, self-documenting names: `API-Version` over `AV`
2. Be consistent within your API: Don't mix `X-User-ID` and `UserID`
3. Use hyphens for word separation: `Request-ID` not `RequestID` or `request_id`
4. Avoid overly generic names that might conflict: `App-Token` instead of `Token`

**Performance Optimization**

1. Minimize custom header count to reduce preflight overhead
2. Keep header values compact (avoid large JSON payloads)
3. Use cookies for authentication when possible (automatically handled, no preflight)
4. Consider query parameters for simple API versioning instead of headers

**Security Best Practices**

1. Never put sensitive data in headers without HTTPS
2. Validate and sanitize all header values server-side
3. Use `HttpOnly` cookies for tokens instead of custom headers when possible
4. Implement rate limiting based on header abuse patterns
5. Log custom header usage for security monitoring

### Custom Headers in Testing

**Mocking Headers**

Test frameworks can inject custom headers:

```javascript
// Jest with fetch-mock
fetchMock.get('https://api.example.com/data', {
  body: {data: 'test'},
  headers: {
    'X-Response-Time': '15ms',
    'X-Cache-Status': 'HIT'
  }
});

// Cypress
cy.intercept('GET', '/api/data', (req) => {
  req.headers['X-Test-Mode'] = 'true';
  req.headers['X-Mock-User'] = 'test-user';
});
```

**Header Assertions**

```javascript
// Testing outgoing headers
test('sends custom headers', async () => {
  const response = await fetch('/api/data', {
    headers: {'X-API-Key': 'test-key'}
  });
  
  expect(mockFetch).toHaveBeenCalledWith(
    expect.anything(),
    expect.objectContaining({
      headers: expect.objectContaining({
        'X-API-Key': 'test-key'
      })
    })
  );
});

// Testing received headers
test('receives rate limit headers', async () => {
  const response = await fetch('/api/data');
  expect(response.headers.get('X-RateLimit-Remaining')).toBe('99');
});
```

---

