## Redirect Handling


### Redirect Types and Fetch Behavior

Fetch API handles HTTP redirects automatically but with specific rules based on status codes:

**3xx Status Codes:**

- **301 Moved Permanently** - Followed automatically, method may change to GET
- **302 Found** - Followed automatically, method may change to GET
- **303 See Other** - Followed automatically, always changes to GET
- **307 Temporary Redirect** - Followed automatically, preserves method and body
- **308 Permanent Redirect** - Followed automatically, preserves method and body

```javascript
fetch('https://api.example.com/redirect')
// Automatically follows to final destination
// Returns response from final location
```

### Redirect Mode Control

```javascript
fetch('https://api.example.com/data', {
  redirect: 'follow'  // default behavior
});

fetch('https://api.example.com/data', {
  redirect: 'error'   // reject on any redirect
});

fetch('https://api.example.com/data', {
  redirect: 'manual'  // return opaque redirect response
});
```

**`redirect: 'follow'`** (default)

- Automatically follows up to a browser-specific limit (typically 20 redirects)
- Returns final response after all redirects complete
- Transparent to application code

**`redirect: 'error'`**

- Rejects promise if server returns any 3xx status
- Useful when redirects indicate misconfiguration or security issues

```javascript
fetch('https://api.example.com/data', {
  redirect: 'error'
})
.catch(error => {
  // Catches any redirect attempt
  console.error('Unexpected redirect:', error);
});
```

**`redirect: 'manual'`**

- Returns opaque response (type: 'opaqueredirect')
- Cannot access response body, headers, or status
- Primarily for Service Workers

```javascript
fetch('https://api.example.com/data', {
  redirect: 'manual'
})
.then(response => {
  console.log(response.type);  // 'opaqueredirect'
  console.log(response.status); // 0
  console.log(response.url);    // empty string
});
```

### Method Preservation Across Redirects

**301/302 redirect behavior:**

```javascript
// Original POST request
fetch('https://api.example.com/old-endpoint', {
  method: 'POST',
  body: JSON.stringify({ data: 'value' })
});

// Server responds: 301 → https://api.example.com/new-endpoint
// Browser converts to GET request (body discarded)
```

Historical behavior causes POST/PUT/PATCH/DELETE to become GET on 301/302 redirects. This follows legacy browser behavior for compatibility.

**307/308 redirect behavior:**

```javascript
// Original POST request
fetch('https://api.example.com/old-endpoint', {
  method: 'POST',
  body: JSON.stringify({ data: 'value' })
});

// Server responds: 307 → https://api.example.com/new-endpoint
// Browser preserves POST method and re-sends body
```

307 and 308 guarantee method and body preservation. Use these for redirecting non-GET requests.

### URL Access After Redirects

```javascript
fetch('https://api.example.com/redirect-chain')
  .then(response => {
    console.log(response.url);  // Final URL after all redirects
    // Cannot access intermediate URLs in redirect chain
  });
```

`response.url` contains the final destination URL only. The fetch API does not expose intermediate redirect URLs in the chain.

### CORS Requirements for Redirects

**Each redirect must include CORS headers:**

```javascript
// From https://myapp.com
fetch('https://api1.example.com/redirect')
```

Required headers at each step:

1. **Initial response (redirect):**
    
    ```
    HTTP/1.1 302 Found
    Location: https://api2.example.com/data
    Access-Control-Allow-Origin: https://myapp.com
    ```
    
2. **Final response:**
    
    ```
    HTTP/1.1 200 OK
    Access-Control-Allow-Origin: https://myapp.com
    ```
    

Missing CORS headers on any redirect response causes the entire request to fail.

### Cross-Origin Redirect Limitations

**Same-origin redirects:**

```javascript
// From https://myapp.com
fetch('https://myapp.com/redirect')
// Can redirect anywhere without CORS restrictions on redirect response
```

**Cross-origin redirects:**

```javascript
// From https://myapp.com
fetch('https://api.example.com/redirect')
// All redirect responses need CORS headers
// Final destination needs CORS headers
```

[Inference] Same-origin initial requests can redirect to cross-origin destinations, but the redirect response itself doesn't require CORS headers in this case—only the final destination does.

### Redirect Loops and Limits

```javascript
fetch('https://api.example.com/infinite-redirect')
// Browser enforces maximum redirect count
```

Browsers typically limit redirects to 20 hops. Exceeding this causes:

```
TypeError: Failed to fetch
```

The exact limit varies by browser. [Unverified] Chrome, Firefox, and Safari use 20 as the default limit, but this may have changed.

### Body Consumption in Redirect Chains

```javascript
fetch('https://api.example.com/redirect', {
  method: 'POST',
  body: JSON.stringify({ data: 'value' })
});
```

**For 307/308 redirects:**

- Body must be re-transmitted to each redirected location
- Body must be replayable (string, ArrayBuffer, or Blob)
- Streams cannot be replayed across redirects

```javascript
// This will fail on 307/308 redirects
const stream = new ReadableStream({...});
fetch('https://api.example.com/redirect', {
  method: 'POST',
  body: stream  // Non-replayable
});
// Error: Body stream already consumed
```

### Credentials Across Redirect Boundaries

```javascript
fetch('https://api.example.com/redirect', {
  credentials: 'include'
});
```

**Same-origin redirects:**

- Credentials (cookies, auth headers) preserved automatically

**Cross-origin redirects:**

- Credentials handling depends on final destination
- `credentials: 'include'` sends credentials to final cross-origin destination if CORS allows
- `credentials: 'same-origin'` strips credentials when redirecting cross-origin

```javascript
// From https://myapp.com
fetch('https://api1.example.com/redirect', {
  credentials: 'same-origin'
});
// Redirects to https://api2.example.com/data
// Credentials NOT sent to api2.example.com
```

### Header Preservation

**Standard headers:** Most standard request headers are preserved across redirects:

- `Accept`
- `Accept-Language`
- `Content-Type` (when method preserved)
- `User-Agent`

**Custom headers:**

```javascript
fetch('https://api.example.com/redirect', {
  headers: {
    'X-Custom-Header': 'value',
    'Authorization': 'Bearer token'
  }
});
```

Custom headers are preserved on same-origin redirects. Cross-origin redirect behavior for custom headers varies by browser and [Unverified] may be stripped for security reasons in some implementations.

**Authorization header specific behavior:**

```javascript
fetch('https://api.example.com/redirect', {
  headers: { 'Authorization': 'Bearer token' }
});
// Redirects to https://different-domain.com/data
```

[Inference] Browsers typically strip `Authorization` headers when redirecting to a different origin to prevent credential leakage, even if the redirect is followed automatically.

### Referrer Policy and Redirects

```javascript
fetch('https://api.example.com/redirect', {
  referrerPolicy: 'no-referrer'
});
```

Referrer policy affects what information is sent in the `Referer` header across redirects:

- `no-referrer` - No referer sent at any step
- `origin` - Only origin sent
- `same-origin` - Referer only for same-origin redirects
- `strict-origin-when-cross-origin` - Full URL for same-origin, origin only for cross-origin HTTPS

The policy applies to each redirect hop individually.

### Timing Information

```javascript
fetch('https://api.example.com/redirect')
  .then(response => {
    // Response received after all redirects complete
    // No way to measure individual redirect timing via fetch API
  });
```

Performance API provides redirect timing:

```javascript
performance.getEntriesByType('navigation').forEach(entry => {
  console.log('Redirect time:', entry.redirectEnd - entry.redirectStart);
  console.log('Redirect count:', entry.redirectCount);
});
```

This only works for navigation requests, not fetch() calls. [Unverified] Resource Timing API may provide redirect information for fetch requests in some browsers.

### Protocol Downgrades

```javascript
// From HTTPS page
fetch('https://api.example.com/redirect')
// Redirects to http://insecure.example.com/data
```

**HTTPS to HTTP redirects are blocked:**

- Mixed content policy prevents following redirect
- Fetch promise rejects
- Error appears similar to CORS failure

**HTTP to HTTPS redirects are allowed:**

```javascript
// From HTTP page
fetch('http://api.example.com/redirect')
// Can redirect to https://secure.example.com/data
```

This follows standard mixed content rules where downgrading security is blocked but upgrading is permitted.

### Redirect with Fragment Identifiers

```javascript
fetch('https://api.example.com/redirect')
// Server responds: 302 → https://example.com/data#section
```

Fragment identifiers (`#section`) in redirect `Location` headers are preserved in `response.url` but are not sent to the server. The browser handles fragments client-side.

```javascript
fetch('https://api.example.com/data#section')
  .then(response => {
    console.log(response.url);  // Includes #section
  });
```

The fragment is never transmitted in the HTTP request; it's purely for client-side processing.

### Conditional Redirects Based on Request Headers

Servers may redirect based on request headers:

```javascript
// Request with Accept: application/json
fetch('https://api.example.com/resource', {
  headers: { 'Accept': 'application/json' }
});
// May redirect to JSON-specific endpoint

// Request with Accept: text/html
fetch('https://api.example.com/resource', {
  headers: { 'Accept': 'text/html' }
});
// May redirect to HTML-specific endpoint
```

This is content negotiation via redirects. Headers are preserved and influence redirect destination.

### POST to GET Conversion Workarounds

When 307/308 are unavailable but POST must be preserved:

```javascript
fetch('https://api.example.com/old-endpoint', {
  method: 'POST',
  redirect: 'manual'
})
.then(response => {
  if (response.type === 'opaqueredirect') {
    // Handle redirect manually
    // Note: Cannot access Location header directly
  }
});
```

[Inference] Manual redirect handling with fetch API is severely limited due to opaque response restrictions. Alternative approaches like server-side proxy or client-side logic to construct new URL are typically more practical.

### Redirect Security Considerations

**Open redirect vulnerabilities:**

```javascript
// Server redirects to user-supplied URL
fetch('https://api.example.com/redirect?url=https://evil.com')
```

Fetch API follows these redirects automatically. Applications should validate redirect destinations when dealing with user-controlled redirect targets.

**Redirect-based timing attacks:**

```javascript
const start = performance.now();
fetch('https://api.example.com/check-resource')
  .then(() => {
    const duration = performance.now() - start;
    // Duration may reveal information about intermediate redirects
  });
```

[Inference] Timing differences in redirect chains could potentially leak information about server-side logic or resource existence, though practical exploitation depends on network variance.

### Service Worker Redirect Interception

```javascript
// In service worker
self.addEventListener('fetch', event => {
  event.respondWith(
    fetch(event.request, { redirect: 'manual' })
      .then(response => {
        if (response.type === 'opaqueredirect') {
          // Service worker can inspect and modify redirect behavior
          // Has access to Location header
          const location = response.headers.get('Location');
          return fetch(location);
        }
        return response;
      })
  );
});
```

Service Workers have special permissions with `redirect: 'manual'` that regular page contexts lack, including access to redirect headers.

### Relative vs Absolute Redirect Locations

```javascript
fetch('https://api.example.com/old/path/endpoint')
// Server responds with relative Location
// Location: ../new/endpoint
```

Browsers resolve relative `Location` headers based on the current request URL:

- `../new/endpoint` resolves to `https://api.example.com/new/endpoint`
- `/absolute/path` resolves to `https://api.example.com/absolute/path`
- `//other.example.com/path` resolves to `https://other.example.com/path`

Full URL resolution rules follow RFC 3986.

### Cached Redirect Handling

**301 and 308 (permanent redirects):**

```javascript
fetch('https://api.example.com/old-endpoint')
// First request: 301 → https://api.example.com/new-endpoint
// Subsequent requests may go directly to new-endpoint
```

Browsers cache permanent redirects. Future requests to the original URL may skip it entirely and go directly to the redirect target. This caching behavior varies by browser and `Cache-Control` headers.

**302, 303, 307 (temporary redirects):** Not typically cached without explicit `Cache-Control` directives. Each request follows the redirect chain.

### Redirect Count Access

```javascript
fetch('https://api.example.com/redirect-chain')
  .then(response => {
    // No direct way to get redirect count from response object
  });
```

Fetch API does not expose redirect count. For navigation requests, use Performance API:

```javascript
performance.getEntriesByType('navigation')[0].redirectCount
```

For fetch requests, [Unverified] redirect count is not accessible through standard APIs.

### Query Parameter Preservation

```javascript
fetch('https://api.example.com/redirect?key=value&token=abc123')
// Server responds: 302 → Location: /new-endpoint
```

**Relative redirects without query string:** Query parameters from original request are NOT automatically carried to redirect destination. The redirect `Location` must explicitly include them.

**Absolute redirects:**

```
Location: https://api.example.com/new-endpoint?key=value&token=abc123
```

Server must construct complete URL with any necessary query parameters.

### Multiple Consecutive Same-Origin Redirects

```javascript
fetch('https://api.example.com/redirect1')
// → https://api.example.com/redirect2
// → https://api.example.com/redirect3
// → https://api.example.com/final
```

Each redirect is treated independently. Headers, CORS checks (if cross-origin mid-chain), and method preservation rules apply at each step. Performance implications increase with chain length.

### Integrity Attribute and Redirects

```javascript
fetch('https://cdn.example.com/library.js', {
  integrity: 'sha384-abc123...'
})
// Redirects to https://cdn2.example.com/library.js
```

Subresource integrity verification occurs on the final resource after all redirects. The integrity hash must match the final response content, not intermediate redirect responses.

### Redirect with Authentication Challenges

```javascript
fetch('https://api.example.com/protected', {
  headers: { 'Authorization': 'Bearer token' }
})
// Server responds: 302 → /login
```

[Inference] If authentication fails, servers may redirect to login pages. For API contexts, returning 401 with appropriate headers is typically preferred over redirects, as redirect chains can complicate error handling in application code.

---

