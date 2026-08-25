## Credentials Option: omit, same-origin, include


### Overview

The `credentials` option in the Fetch API controls whether user credentials (cookies, HTTP authentication, TLS client certificates) are included in the request and whether credentials from the response are processed by the browser.

### The Three Credential Modes

#### `omit`

Explicitly excludes credentials from both the request and response processing.

```javascript
fetch('https://api.example.com/data', {
  credentials: 'omit'
});
```

**Request Behavior:**

- No cookies sent, even for same-origin requests
- No Authorization headers sent
- No TLS client certificates used

**Response Behavior:**

- `Set-Cookie` headers ignored by browser
- WWW-Authenticate challenges ignored
- No credential storage occurs

**Use Cases:**

- Public API endpoints that don't require authentication
- Preventing credential leakage to untrusted origins
- Anonymous requests where you want to ensure no identifying information is sent
- Stateless requests that should not create sessions

**Example - Public Data Fetch:**

```javascript
// Fetch public weather data without any credentials
const response = await fetch('https://api.weather.gov/forecast', {
  credentials: 'omit'
});
const weatherData = await response.json();
```

**Example - Preventing Credential Leakage:**

```javascript
// Ensure no cookies are sent to third-party analytics
fetch('https://analytics.example.com/track', {
  method: 'POST',
  credentials: 'omit',
  body: JSON.stringify({ event: 'page_view' })
});
```

#### `same-origin` (default)

Includes credentials only for requests to the same origin as the calling script.

```javascript
fetch('https://api.example.com/data', {
  credentials: 'same-origin'
});

// Equivalent to:
fetch('https://api.example.com/data');
```

**Request Behavior:**

- Same-origin: All cookies, auth headers, and certificates sent
- Cross-origin: No credentials sent
- Subdomains count as cross-origin (e.g., `app.example.com` vs `api.example.com`)

**Response Behavior:**

- Same-origin: `Set-Cookie` and authentication responses processed
- Cross-origin: Credential-setting headers ignored

**Origin Matching Rules:** An origin is "same" only when protocol, domain, and port all match exactly:

```javascript
// Current page: https://example.com:443

// Same-origin (credentials sent):
fetch('/api/data');
fetch('https://example.com/api/data');
fetch('https://example.com:443/api/data');

// Cross-origin (credentials NOT sent):
fetch('http://example.com/api/data');        // Different protocol
fetch('https://api.example.com/data');       // Different subdomain
fetch('https://example.com:8080/data');      // Different port
fetch('https://example.org/data');           // Different domain
```

**Use Cases:**

- Default secure behavior for most applications
- Internal API calls within the same domain
- When you want automatic credential inclusion for your own resources
- Preventing cross-origin credential exposure by default

**Example - Same-Origin API Calls:**

```javascript
// On https://example.com, calling own API
async function getUserProfile() {
  const response = await fetch('/api/user/profile', {
    credentials: 'same-origin' // explicit, but this is default
  });
  
  if (!response.ok) {
    throw new Error('Failed to fetch profile');
  }
  
  return response.json();
}
```

**Example - Mixed Origin Requests:**

```javascript
// On https://example.com
async function loadData() {
  // Credentials included (same-origin)
  const userResponse = await fetch('/api/user', {
    credentials: 'same-origin'
  });
  
  // Credentials NOT included (cross-origin)
  const publicResponse = await fetch('https://cdn.example.com/data.json', {
    credentials: 'same-origin'
  });
}
```

#### `include`

Includes credentials for all requests, regardless of origin.

```javascript
fetch('https://api.example.com/data', {
  credentials: 'include'
});
```

**Request Behavior:**

- Same-origin: All credentials sent (same as `same-origin`)
- Cross-origin: All credentials sent (requires CORS approval)

**Response Behavior:**

- Same-origin: All credential-setting headers processed
- Cross-origin: Credential-setting headers processed only if CORS headers allow

**CORS Requirements:**

For cross-origin requests with `credentials: 'include'`, the server must send:

```http
Access-Control-Allow-Origin: https://example.com
Access-Control-Allow-Credentials: true
```

**Restrictions:**

- `Access-Control-Allow-Origin` cannot be `*`
- `Access-Control-Allow-Headers` cannot be `*`
- `Access-Control-Allow-Methods` cannot be `*`
- Must specify exact origin or use dynamic origin reflection

**Use Cases:**

- Authenticated cross-origin API requests
- Single sign-on (SSO) implementations
- Microservices architectures with authentication
- Cross-subdomain authenticated requests

**Example - Cross-Origin Authenticated Request:**

```javascript
// From https://app.example.com to https://api.example.com
async function fetchUserData() {
  try {
    const response = await fetch('https://api.example.com/user', {
      credentials: 'include',
      headers: {
        'Content-Type': 'application/json'
      }
    });
    
    if (response.status === 401) {
      // Redirect to login
      window.location.href = '/login';
      return;
    }
    
    return await response.json();
  } catch (error) {
    console.error('Failed to fetch user data:', error);
    throw error;
  }
}
```

**Example - Cross-Subdomain Session Sharing:**

```javascript
// From https://shop.example.com accessing https://api.example.com
async function addToCart(productId, quantity) {
  const response = await fetch('https://api.example.com/cart/add', {
    method: 'POST',
    credentials: 'include', // Send session cookie cross-subdomain
    headers: {
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({ productId, quantity })
  });
  
  return response.json();
}
```

### Credential Types Affected

#### HTTP Cookies

**Sent in Request:**

```http
GET /api/data HTTP/1.1
Host: api.example.com
Cookie: sessionId=abc123; userId=456
```

**Set in Response:**

```http
HTTP/1.1 200 OK
Set-Cookie: sessionId=xyz789; Path=/; HttpOnly; Secure
```

**Behavior by Mode:**

- `omit`: Never sends cookies, ignores Set-Cookie
- `same-origin`: Sends/receives cookies for same origin only
- `include`: Sends/receives cookies for all origins (if allowed)

#### HTTP Authentication

**Basic Authentication Example:**

```javascript
// Browser previously authenticated via WWW-Authenticate challenge
fetch('https://api.example.com/protected', {
  credentials: 'include' // Includes Authorization header
});
```

**Request with stored credentials:**

```http
GET /protected HTTP/1.1
Host: api.example.com
Authorization: Basic dXNlcm5hbWU6cGFzc3dvcmQ=
```

#### TLS Client Certificates

When the browser has client certificates installed:

```javascript
fetch('https://secure-api.example.com/data', {
  credentials: 'include' // Uses client certificate if available
});
```

[Inference] The browser automatically selects and presents the appropriate client certificate during the TLS handshake when credentials are included.

### Comparison Matrix

|Aspect|`omit`|`same-origin`|`include`|
|---|---|---|---|
|Same-origin cookies|❌ Not sent|✅ Sent|✅ Sent|
|Cross-origin cookies|❌ Not sent|❌ Not sent|✅ Sent (if CORS allows)|
|Set-Cookie processing (same-origin)|❌ Ignored|✅ Processed|✅ Processed|
|Set-Cookie processing (cross-origin)|❌ Ignored|❌ Ignored|✅ Processed (if CORS allows)|
|HTTP Auth headers|❌ Not sent|✅ Same-origin only|✅ Always sent|
|TLS client certificates|❌ Not used|✅ Same-origin only|✅ Always used|
|Default behavior|No|Yes|No|
|Requires CORS headers|No|No|Yes (cross-origin)|

### Practical Decision Tree

**Choose `omit` when:**

- Accessing public APIs that don't require authentication
- You want to guarantee no credentials are leaked
- Making requests to untrusted origins
- Implementing anonymous tracking or analytics

**Choose `same-origin` when:**

- Building a traditional web application with backend on same origin
- You want the default secure behavior
- Not making authenticated cross-origin requests
- Working with internal APIs only

**Choose `include` when:**

- Making authenticated requests to a different origin
- Implementing cross-subdomain authentication
- Using cookie-based SSO systems
- Building microservices with shared authentication
- Accessing APIs that require session cookies from a different domain

### Security Implications

#### With `omit`

**Security Benefits:**

- No risk of CSRF attacks (no credentials to steal)
- No credential leakage to third parties
- Prevents session fixation attacks

**Limitations:**

- Cannot implement authentication with this mode
- Cannot track users across requests

#### With `same-origin`

**Security Benefits:**

- Prevents cross-origin credential exposure by default
- Reduces CSRF attack surface
- No risk of sending cookies to third-party origins

**Limitations:**

- Cannot share authentication across subdomains
- Microservices on different subdomains need token-based auth

**CSRF Considerations:** [Inference] Same-origin requests with credentials are potentially vulnerable to CSRF if the server doesn't implement additional protections like CSRF tokens or SameSite cookie attributes.

#### With `include`

**Security Risks:**

- Increased CSRF attack surface
- Credentials sent to cross-origin destinations
- Requires careful CORS configuration
- Cookie leakage if CORS misconfigured

**Required Protections:**

- CSRF tokens for state-changing operations
- Strict CORS origin validation
- SameSite cookie attributes
- Origin header verification server-side

**Example - CSRF Protection with `include`:**

```javascript
// Step 1: Get CSRF token
const tokenResponse = await fetch('https://api.example.com/csrf-token', {
  credentials: 'include'
});
const { token } = await tokenResponse.json();

// Step 2: Include token in state-changing request
await fetch('https://api.example.com/update', {
  method: 'POST',
  credentials: 'include',
  headers: {
    'Content-Type': 'application/json',
    'X-CSRF-Token': token
  },
  body: JSON.stringify({ data: 'value' })
});
```

### Cookie Attributes Interaction

The `credentials` mode works in conjunction with cookie attributes:

#### SameSite Attribute

```http
Set-Cookie: sessionId=abc; SameSite=Strict
Set-Cookie: sessionId=abc; SameSite=Lax
Set-Cookie: sessionId=abc; SameSite=None; Secure
```

**Interaction with `credentials`:**

|credentials|SameSite=Strict|SameSite=Lax|SameSite=None|
|---|---|---|---|
|`omit`|Not sent|Not sent|Not sent|
|`same-origin`|Sent same-origin|Sent same-origin|Sent same-origin|
|`include`|Sent same-site only|Sent cross-site (top-level nav)|Sent cross-origin|

**Example - Cross-Origin Cookie Setup:**

```javascript
// Server must set cookie with proper attributes for cross-origin use
// Server response:
// Set-Cookie: sessionId=abc123; SameSite=None; Secure; HttpOnly

// Client request:
fetch('https://api.example.com/data', {
  credentials: 'include' // Cookie will be sent
});
```

### Error Handling Patterns

#### Detecting Missing Credentials

```javascript
async function authenticatedFetch(url, options = {}) {
  const response = await fetch(url, {
    ...options,
    credentials: 'include'
  });
  
  if (response.status === 401) {
    console.error('Authentication required - credentials missing or invalid');
    // Redirect to login or refresh token
    throw new Error('Unauthorized');
  }
  
  if (response.status === 403) {
    console.error('Forbidden - valid credentials but insufficient permissions');
    throw new Error('Forbidden');
  }
  
  return response;
}
```

#### Handling CORS Credential Errors

```javascript
async function crossOriginAuthFetch(url) {
  try {
    const response = await fetch(url, {
      credentials: 'include'
    });
    return response;
  } catch (error) {
    // CORS errors typically manifest as TypeError
    if (error instanceof TypeError) {
      console.error('CORS error - possible causes:');
      console.error('- Server missing Access-Control-Allow-Credentials header');
      console.error('- Server using wildcard (*) for Access-Control-Allow-Origin');
      console.error('- Network failure');
    }
    throw error;
  }
}
```

### Mode Switching Patterns

#### Dynamic Credential Mode

```javascript
function fetchWithDynamicCredentials(url, requireAuth = false) {
  const isLocalhost = url.startsWith('http://localhost') || 
                      url.startsWith('http://127.0.0.1');
  
  let credentialsMode;
  
  if (isLocalhost) {
    credentialsMode = 'same-origin';
  } else if (requireAuth) {
    credentialsMode = 'include';
  } else {
    credentialsMode = 'omit';
  }
  
  return fetch(url, {
    credentials: credentialsMode
  });
}
```

#### Environment-Based Configuration

```javascript
class APIClient {
  constructor(baseURL, environment = 'production') {
    this.baseURL = baseURL;
    this.credentials = this.getCredentialsMode(environment);
  }
  
  getCredentialsMode(environment) {
    switch (environment) {
      case 'development':
        return 'same-origin';
      case 'staging':
      case 'production':
        return 'include';
      default:
        return 'omit';
    }
  }
  
  async request(endpoint, options = {}) {
    return fetch(`${this.baseURL}${endpoint}`, {
      ...options,
      credentials: this.credentials
    });
  }
}

const api = new APIClient('https://api.example.com', process.env.NODE_ENV);
```

### Performance Considerations

#### Credential Mode Impact

[Inference] Different credential modes may have performance implications:

**`omit`:**

- Fastest - no credential lookup or transmission
- Smallest request size
- No cookie parsing overhead

**`same-origin`:**

- Moderate - conditional credential lookup
- Server must parse cookies for same-origin requests

**`include`:**

- Potential preflight overhead for cross-origin requests
- Larger request headers (cookies included)
- Server-side origin validation overhead

#### Preflight Caching

```javascript
// Preflight responses can be cached to reduce overhead
// Server sends:
// Access-Control-Max-Age: 86400

// Subsequent requests within 24 hours skip preflight
fetch('https://api.example.com/data', {
  credentials: 'include'
});
```

### Browser DevTools Debugging

#### Inspecting Credential Inclusion

**Network Tab:**

1. Look for `Cookie` header in Request Headers
2. Check `Set-Cookie` in Response Headers
3. Examine preflight OPTIONS request

**Console Errors:**

```
Access to fetch at 'https://api.example.com/data' from origin 
'https://example.com' has been blocked by CORS policy: 
The value of the 'Access-Control-Allow-Credentials' header in 
the response is '' which must be 'true' when the request's 
credentials mode is 'include'.
```

**Application Tab:**

1. Check Cookies section for domain and path
2. Verify SameSite and Secure attributes
3. Confirm cookie is not expired

### Real-World Implementation Examples

#### Multi-Tenant SaaS Application

```javascript
class TenantAPI {
  constructor(tenantSubdomain) {
    this.baseURL = `https://${tenantSubdomain}.saas-app.com`;
  }
  
  async authenticatedRequest(endpoint, options = {}) {
    return fetch(`${this.baseURL}${endpoint}`, {
      ...options,
      credentials: 'include', // Share auth across tenant subdomains
      headers: {
        'Content-Type': 'application/json',
        ...options.headers
      }
    });
  }
  
  async publicRequest(endpoint) {
    return fetch(`${this.baseURL}${endpoint}`, {
      credentials: 'omit' // No auth needed for public endpoints
    });
  }
}
```

#### Mixed Content Types

```javascript
async function loadDashboard() {
  // Authenticated user data - same origin
  const userPromise = fetch('/api/user', {
    credentials: 'same-origin'
  });
  
  // Public market data - cross origin, no auth needed
  const marketPromise = fetch('https://api.market-data.com/rates', {
    credentials: 'omit'
  });
  
  // Cross-origin authenticated analytics
  const analyticsPromise = fetch('https://analytics.company.com/stats', {
    credentials: 'include'
  });
  
  const [user, market, analytics] = await Promise.all([
    userPromise.then(r => r.json()),
    marketPromise.then(r => r.json()),
    analyticsPromise.then(r => r.json())
  ]);
  
  return { user, market, analytics };
}
```

### Testing Different Credential Modes

#### Unit Testing Pattern

```javascript
// Mock fetch for testing
global.fetch = jest.fn();

test('uses correct credentials mode for public API', async () => {
  fetch.mockResolvedValue({
    ok: true,
    json: async () => ({ data: 'public' })
  });
  
  await fetchPublicData();
  
  expect(fetch).toHaveBeenCalledWith(
    expect.any(String),
    expect.objectContaining({
      credentials: 'omit'
    })
  );
});

test('uses include mode for cross-origin auth', async () => {
  fetch.mockResolvedValue({
    ok: true,
    json: async () => ({ user: 'data' })
  });
  
  await fetchUserFromAuthAPI();
  
  expect(fetch).toHaveBeenCalledWith(
    expect.stringContaining('auth-api.example.com'),
    expect.objectContaining({
      credentials: 'include'
    })
  );
});
```

---

