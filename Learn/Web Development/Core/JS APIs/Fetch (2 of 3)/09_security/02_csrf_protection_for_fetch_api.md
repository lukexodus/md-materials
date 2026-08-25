## CSRF Protection for Fetch API


### Token-Based Protection

#### Synchronizer Token Pattern

The most common CSRF protection mechanism involves including a unique token in each request that the server validates. When using fetch, tokens are typically embedded in the page and sent with each state-changing request.

```javascript
// Token from meta tag
const csrfToken = document.querySelector('meta[name="csrf-token"]').content;

fetch('/api/resource', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'X-CSRF-Token': csrfToken
  },
  body: JSON.stringify(data)
});
```

#### Token Storage Locations

**Meta Tags**: Most frameworks inject tokens into HTML meta tags for easy JavaScript access.

```html
<meta name="csrf-token" content="abc123xyz">
```

**Hidden Form Fields**: Traditional approach that can be read for fetch requests.

```javascript
const token = document.querySelector('input[name="_csrf"]').value;
```

**Response Headers**: Tokens can be retrieved from initial page load responses and cached.

```javascript
const response = await fetch('/api/init');
const token = response.headers.get('X-CSRF-Token');
// Store for subsequent requests
```

#### Token Rotation

Implementing token rotation requires handling token updates after each request or after specific intervals.

```javascript
let currentToken = document.querySelector('meta[name="csrf-token"]').content;

async function protectedFetch(url, options = {}) {
  const response = await fetch(url, {
    ...options,
    headers: {
      ...options.headers,
      'X-CSRF-Token': currentToken
    }
  });
  
  // Update token if server provides new one
  const newToken = response.headers.get('X-New-CSRF-Token');
  if (newToken) {
    currentToken = newToken;
    document.querySelector('meta[name="csrf-token"]').content = newToken;
  }
  
  return response;
}
```

### Cookie-Based Protection

#### Double Submit Cookie Pattern

The server sets a CSRF token in a cookie, and the client reads it and sends it back in a header. The server compares both values.

```javascript
function getCookie(name) {
  const value = `; ${document.cookie}`;
  const parts = value.split(`; ${name}=`);
  if (parts.length === 2) return parts.pop().split(';').shift();
}

fetch('/api/resource', {
  method: 'POST',
  headers: {
    'X-CSRF-Token': getCookie('csrf_token')
  },
  credentials: 'same-origin',
  body: JSON.stringify(data)
});
```

#### Encrypted Double Submit

Enhanced security through encryption where the cookie value is encrypted differently from the header value, but both derive from the same secret.

```javascript
// Server sets: csrf_cookie=encryptedValue1
// Client sends: X-CSRF-Token=encryptedValue2
// Server decrypts both and verifies they match the same underlying token

fetch('/api/resource', {
  method: 'POST',
  headers: {
    'X-CSRF-Token': getCookie('xsrf-token')
  },
  credentials: 'include'
});
```

### SameSite Cookie Attribute

Modern browsers support the SameSite attribute which provides built-in CSRF protection by controlling when cookies are sent with cross-site requests.

#### SameSite=Strict

Cookies are only sent with same-site requests, providing strong CSRF protection but potentially breaking legitimate cross-site navigation.

```javascript
// Cookies with SameSite=Strict won't be sent with this fetch from another origin
fetch('https://api.example.com/resource', {
  method: 'POST',
  credentials: 'include'
});
```

#### SameSite=Lax

Cookies are sent with top-level navigation GET requests but not with cross-site POST, PUT, DELETE, or embedded requests.

```javascript
// From different origin:
// GET navigation: cookies sent
// POST via fetch: cookies NOT sent (CSRF protection)

fetch('https://api.example.com/resource', {
  method: 'POST',
  credentials: 'include'
  // Cookies won't be included if SameSite=Lax
});
```

#### SameSite=None with Secure

Required for legitimate cross-site requests. Must be paired with Secure attribute (HTTPS only).

```javascript
// Allow cross-origin requests with cookies
fetch('https://api.example.com/resource', {
  method: 'POST',
  credentials: 'include',
  // Server must set: Set-Cookie: session=abc; SameSite=None; Secure
});
```

### Custom Request Headers

Leveraging the browser's CORS preflight mechanism provides CSRF protection by requiring custom headers that simple forms cannot send.

#### Custom Header Verification

```javascript
fetch('/api/resource', {
  method: 'POST',
  headers: {
    'X-Requested-With': 'XMLHttpRequest',
    'Content-Type': 'application/json'
  },
  credentials: 'same-origin',
  body: JSON.stringify(data)
});
```

The server verifies the presence of the custom header, which cannot be set by a simple HTML form submission from another origin.

#### CORS Preflight Protection

Non-simple requests trigger a preflight, which attackers cannot forge from victim browsers.

```javascript
// This triggers preflight due to custom header
fetch('https://api.example.com/resource', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'X-Custom-Header': 'value'
  },
  credentials: 'include'
});
```

### Origin and Referer Validation

#### Origin Header Checking

The Origin header is automatically added by browsers for cross-origin requests and cannot be modified by JavaScript.

```javascript
// Browser automatically adds Origin header
fetch('https://api.example.com/resource', {
  method: 'POST',
  credentials: 'include'
});

// Server-side validation:
// if (origin !== 'https://trusted-domain.com') reject()
```

#### Referer Header Validation

Less reliable than Origin due to privacy policies that may strip it, but can provide additional verification.

```javascript
fetch('/api/resource', {
  method: 'POST',
  referrerPolicy: 'strict-origin-when-cross-origin'
});

// Server checks Referer matches expected domain
```

### Credential Modes and CSRF

#### credentials: 'same-origin'

Default behavior that prevents cookies from being sent cross-origin, providing inherent CSRF protection for cross-origin scenarios.

```javascript
// Cookies only sent if request is same-origin
fetch('/api/resource', {
  method: 'POST',
  credentials: 'same-origin'
});
```

#### credentials: 'include'

Explicitly includes cookies in cross-origin requests, requiring additional CSRF protection mechanisms.

```javascript
// Vulnerable if no additional CSRF protection
fetch('https://api.example.com/resource', {
  method: 'POST',
  credentials: 'include',
  headers: {
    'X-CSRF-Token': token  // Required!
  }
});
```

#### credentials: 'omit'

Never sends cookies, eliminating CSRF risk but also authentication context.

```javascript
// No CSRF risk, but no authentication
fetch('/api/public-resource', {
  method: 'POST',
  credentials: 'omit'
});
```

### Framework-Specific Implementations

#### Express.js with csurf

```javascript
// Client-side
const csrfToken = document.querySelector('meta[name="csrf-token"]').content;

async function secureRequest(url, data) {
  return fetch(url, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'CSRF-Token': csrfToken
    },
    credentials: 'same-origin',
    body: JSON.stringify(data)
  });
}
```

#### Django

Django expects the token in the X-CSRFToken header by default.

```javascript
function getCSRFToken() {
  return document.querySelector('[name=csrfmiddlewaretoken]').value ||
         getCookie('csrftoken');
}

fetch('/api/resource/', {
  method: 'POST',
  headers: {
    'X-CSRFToken': getCSRFToken(),
    'Content-Type': 'application/json'
  },
  credentials: 'same-origin',
  body: JSON.stringify(data)
});
```

#### Rails

Rails uses a token in the meta tag and expects it in the X-CSRF-Token header.

```javascript
const token = document.querySelector('meta[name="csrf-token"]').content;

fetch('/resources', {
  method: 'POST',
  headers: {
    'X-CSRF-Token': token,
    'Content-Type': 'application/json'
  },
  credentials: 'same-origin',
  body: JSON.stringify(data)
});
```

#### Spring Security

```javascript
const token = document.querySelector('meta[name="_csrf"]').content;
const header = document.querySelector('meta[name="_csrf_header"]').content;

fetch('/api/resource', {
  method: 'POST',
  headers: {
    [header]: token,
    'Content-Type': 'application/json'
  },
  credentials: 'same-origin',
  body: JSON.stringify(data)
});
```

### Interceptor Patterns

#### Global Fetch Wrapper

Creating a wrapper function that automatically handles CSRF tokens for all requests.

```javascript
const originalFetch = window.fetch;

window.fetch = function(url, options = {}) {
  const csrfToken = document.querySelector('meta[name="csrf-token"]').content;
  
  // Only add CSRF token for state-changing methods
  if (options.method && ['POST', 'PUT', 'PATCH', 'DELETE'].includes(options.method.toUpperCase())) {
    options.headers = {
      ...options.headers,
      'X-CSRF-Token': csrfToken
    };
  }
  
  return originalFetch(url, options);
};
```

#### Fetch Interceptor Class

Object-oriented approach for managing CSRF protection.

```javascript
class FetchInterceptor {
  constructor() {
    this.token = null;
    this.refreshToken();
  }
  
  refreshToken() {
    this.token = document.querySelector('meta[name="csrf-token"]')?.content;
  }
  
  async fetch(url, options = {}) {
    const needsToken = options.method && 
                       ['POST', 'PUT', 'PATCH', 'DELETE'].includes(options.method.toUpperCase());
    
    if (needsToken) {
      options.headers = {
        ...options.headers,
        'X-CSRF-Token': this.token
      };
    }
    
    const response = await fetch(url, options);
    
    // Handle token expiration
    if (response.status === 403) {
      const error = await response.json();
      if (error.code === 'CSRF_TOKEN_INVALID') {
        this.refreshToken();
        // Retry once with new token
        options.headers['X-CSRF-Token'] = this.token;
        return fetch(url, options);
      }
    }
    
    return response;
  }
}

const secureFetch = new FetchInterceptor();
```

### Error Handling

#### CSRF Token Validation Failures

```javascript
async function protectedRequest(url, data) {
  try {
    const response = await fetch(url, {
      method: 'POST',
      headers: {
        'X-CSRF-Token': getToken(),
        'Content-Type': 'application/json'
      },
      credentials: 'same-origin',
      body: JSON.stringify(data)
    });
    
    if (response.status === 403) {
      const error = await response.json();
      
      if (error.code === 'CSRF_TOKEN_MISSING') {
        console.error('CSRF token not included in request');
        // Refresh page to get new token
        window.location.reload();
      } else if (error.code === 'CSRF_TOKEN_INVALID') {
        console.error('CSRF token is invalid or expired');
        // Attempt to fetch new token
        await refreshCSRFToken();
        // Retry request
        return protectedRequest(url, data);
      }
    }
    
    return response;
  } catch (error) {
    console.error('Request failed:', error);
    throw error;
  }
}
```

#### Token Expiration Handling

```javascript
async function refreshCSRFToken() {
  const response = await fetch('/api/csrf-token', {
    method: 'GET',
    credentials: 'same-origin'
  });
  
  const { token } = await response.json();
  document.querySelector('meta[name="csrf-token"]').content = token;
  return token;
}

async function fetchWithTokenRefresh(url, options) {
  let response = await fetch(url, {
    ...options,
    headers: {
      ...options.headers,
      'X-CSRF-Token': getToken()
    }
  });
  
  // If token expired, refresh and retry
  if (response.status === 403) {
    await refreshCSRFToken();
    response = await fetch(url, {
      ...options,
      headers: {
        ...options.headers,
        'X-CSRF-Token': getToken()
      }
    });
  }
  
  return response;
}
```

### Multi-Tab Synchronization

When users have multiple tabs open, token updates in one tab need to be synchronized with others.

#### localStorage Synchronization

```javascript
// Tab 1: Updates token
function updateCSRFToken(newToken) {
  localStorage.setItem('csrf-token', newToken);
  document.querySelector('meta[name="csrf-token"]').content = newToken;
  
  // Trigger storage event for other tabs
  window.dispatchEvent(new Event('storage'));
}

// All tabs: Listen for updates
window.addEventListener('storage', (e) => {
  if (e.key === 'csrf-token') {
    document.querySelector('meta[name="csrf-token"]').content = e.newValue;
  }
});
```

#### BroadcastChannel API

```javascript
const csrfChannel = new BroadcastChannel('csrf-token-updates');

// Send token update to other tabs
function broadcastTokenUpdate(newToken) {
  csrfChannel.postMessage({ token: newToken });
  document.querySelector('meta[name="csrf-token"]').content = newToken;
}

// Receive token updates from other tabs
csrfChannel.onmessage = (event) => {
  document.querySelector('meta[name="csrf-token"]').content = event.data.token;
};
```

### Testing CSRF Protection

#### Verifying Token Presence

```javascript
// Test helper to verify CSRF token is included
function verifyCSRFProtection(url, options) {
  const headers = new Headers(options.headers);
  const hasCSRFToken = headers.has('X-CSRF-Token') || 
                        headers.has('CSRF-Token');
  
  if (!hasCSRFToken && ['POST', 'PUT', 'PATCH', 'DELETE'].includes(options.method)) {
    console.warn(`CSRF token missing for ${options.method} request to ${url}`);
  }
  
  return fetch(url, options);
}
```

#### Simulating CSRF Attacks

```javascript
// Attempt request without token to verify protection
async function testCSRFProtection() {
  try {
    const response = await fetch('/api/protected-resource', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
        // Intentionally omit CSRF token
      },
      credentials: 'same-origin',
      body: JSON.stringify({ test: 'data' })
    });
    
    if (response.ok) {
      console.error('CSRF protection not working! Request succeeded without token');
    } else if (response.status === 403) {
      console.log('CSRF protection working correctly');
    }
  } catch (error) {
    console.error('Test failed:', error);
  }
}
```

### Security Considerations

#### Token Generation Requirements

CSRF tokens must be cryptographically random, unpredictable, and unique per session or request. Weak token generation undermines the entire protection mechanism.

```javascript
// Client cannot generate secure tokens
// Server must generate: crypto.randomBytes(32).toString('hex')
```

#### Token Lifetime Management

Tokens should expire after a reasonable period or after logout to limit the window of vulnerability.

```javascript
async function checkTokenExpiry() {
  const tokenTimestamp = localStorage.getItem('csrf-token-timestamp');
  const maxAge = 3600000; // 1 hour
  
  if (Date.now() - tokenTimestamp > maxAge) {
    await refreshCSRFToken();
    localStorage.setItem('csrf-token-timestamp', Date.now());
  }
}
```

#### Subdomain Considerations

CSRF protection must account for subdomain attacks where an attacker controls a subdomain of the target domain.

```javascript
// Verify origin matches exactly, not just domain
fetch('/api/resource', {
  method: 'POST',
  headers: {
    'X-CSRF-Token': token
  },
  credentials: 'same-origin'
});

// Server must validate origin precisely:
// Not just: origin.endsWith('example.com')
// But: origin === 'https://app.example.com'
```

#### HTTPS Requirement

CSRF protection relies on secure transmission of tokens. Mixed content or insecure connections can expose tokens to interception.

```javascript
// Ensure all fetch requests use HTTPS in production
const apiUrl = process.env.NODE_ENV === 'production' 
  ? 'https://api.example.com'
  : 'http://localhost:3000';
```

### Integration with Authentication

#### Bearer Tokens vs CSRF

APIs using bearer tokens in Authorization headers are inherently protected from CSRF since attackers cannot access the token.

```javascript
// Bearer token approach - CSRF protection not needed
fetch('/api/resource', {
  method: 'POST',
  headers: {
    'Authorization': `Bearer ${accessToken}`,
    'Content-Type': 'application/json'
  },
  body: JSON.stringify(data)
  // Note: credentials: 'same-origin' or 'omit', NOT 'include'
});
```

#### Session Cookies Requiring CSRF

When authentication relies on cookies, CSRF protection is essential.

```javascript
// Cookie-based auth - CSRF protection required
fetch('/api/resource', {
  method: 'POST',
  headers: {
    'X-CSRF-Token': csrfToken,
    'Content-Type': 'application/json'
  },
  credentials: 'include',  // Sends session cookie
  body: JSON.stringify(data)
});
```

#### Hybrid Approaches

Systems using both cookies and tokens need careful design.

```javascript
// Session cookie for auth + CSRF token for protection
fetch('/api/resource', {
  method: 'POST',
  headers: {
    'X-CSRF-Token': csrfToken,
    'Content-Type': 'application/json'
  },
  credentials: 'same-origin',
  body: JSON.stringify(data)
});
```

### Performance Optimization

#### Token Caching

Cache tokens in memory to avoid repeated DOM queries.

```javascript
class CSRFTokenCache {
  constructor() {
    this.token = null;
    this.lastRefresh = 0;
    this.cacheDuration = 300000; // 5 minutes
  }
  
  getToken() {
    const now = Date.now();
    if (!this.token || (now - this.lastRefresh) > this.cacheDuration) {
      this.token = document.querySelector('meta[name="csrf-token"]')?.content;
      this.lastRefresh = now;
    }
    return this.token;
  }
  
  invalidate() {
    this.token = null;
    this.lastRefresh = 0;
  }
}

const tokenCache = new CSRFTokenCache();
```

#### Batch Request Handling

For multiple simultaneous requests, ensure token is read once and reused.

```javascript
async function batchRequests(urls, data) {
  const token = getToken(); // Read once
  
  const requests = urls.map(url => 
    fetch(url, {
      method: 'POST',
      headers: {
        'X-CSRF-Token': token,  // Reuse for all
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(data)
    })
  );
  
  return Promise.all(requests);
}
```

---

