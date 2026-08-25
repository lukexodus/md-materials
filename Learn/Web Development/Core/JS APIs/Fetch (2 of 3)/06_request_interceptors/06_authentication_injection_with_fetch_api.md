## Authentication Injection with Fetch API


### Authorization Header

The `Authorization` header is the primary mechanism for injecting authentication credentials into fetch requests.

```javascript
const response = await fetch('/api/protected', {
  headers: {
    'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...'
  }
});
```

**Common Authorization Schemes:**

- `Bearer <token>` - OAuth 2.0, JWT tokens
- `Basic <credentials>` - Base64-encoded username:password
- `Digest <credentials>` - Digest authentication
- `API-Key <key>` - Custom API key schemes

### Bearer Token Authentication

OAuth 2.0 and JWT token injection pattern.

```javascript
class AuthenticatedFetch {
  constructor(accessToken) {
    this.accessToken = accessToken;
  }
  
  async fetch(url, options = {}) {
    return fetch(url, {
      ...options,
      headers: {
        ...options.headers,
        'Authorization': `Bearer ${this.accessToken}`
      }
    });
  }
}

// Usage
const authFetch = new AuthenticatedFetch('your-jwt-token');
const response = await authFetch.fetch('/api/user/profile');
```

### Basic Authentication

HTTP Basic Authentication with base64-encoded credentials.

```javascript
function createBasicAuthHeader(username, password) {
  const credentials = btoa(`${username}:${password}`);
  return `Basic ${credentials}`;
}

const response = await fetch('/api/protected', {
  headers: {
    'Authorization': createBasicAuthHeader('user@example.com', 'password123')
  }
});
```

**Security Note:** Basic authentication transmits credentials with every request and should only be used over HTTPS.

### Custom API Key Headers

Many APIs use custom headers for API key authentication.

```javascript
const response = await fetch('https://api.example.com/data', {
  headers: {
    'X-API-Key': 'your-api-key-here',
    'Content-Type': 'application/json'
  }
});

// Alternative header names
const response2 = await fetch('https://api.example.com/data', {
  headers: {
    'X-Auth-Token': 'token',
    'X-Client-Id': 'client-id',
    'X-Client-Secret': 'client-secret'
  }
});
```

### Token Refresh Pattern

Automatic token refresh when access tokens expire.

```javascript
class TokenManager {
  constructor(accessToken, refreshToken) {
    this.accessToken = accessToken;
    this.refreshToken = refreshToken;
    this.refreshPromise = null;
  }
  
  async fetch(url, options = {}) {
    try {
      return await this.fetchWithAuth(url, options);
    } catch (error) {
      if (error.status === 401) {
        // Token expired, refresh and retry
        await this.refreshAccessToken();
        return await this.fetchWithAuth(url, options);
      }
      throw error;
    }
  }
  
  async fetchWithAuth(url, options = {}) {
    const response = await fetch(url, {
      ...options,
      headers: {
        ...options.headers,
        'Authorization': `Bearer ${this.accessToken}`
      }
    });
    
    if (response.status === 401) {
      const error = new Error('Unauthorized');
      error.status = 401;
      throw error;
    }
    
    return response;
  }
  
  async refreshAccessToken() {
    // Prevent multiple simultaneous refresh requests
    if (this.refreshPromise) {
      return this.refreshPromise;
    }
    
    this.refreshPromise = (async () => {
      try {
        const response = await fetch('/auth/refresh', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({
            refreshToken: this.refreshToken
          })
        });
        
        if (!response.ok) {
          throw new Error('Refresh failed');
        }
        
        const data = await response.json();
        this.accessToken = data.accessToken;
        
        if (data.refreshToken) {
          this.refreshToken = data.refreshToken;
        }
        
      } finally {
        this.refreshPromise = null;
      }
    })();
    
    return this.refreshPromise;
  }
}

// Usage
const tokenManager = new TokenManager('access-token', 'refresh-token');
const response = await tokenManager.fetch('/api/protected-resource');
```

### Credentials Mode

The `credentials` option controls cookie and authentication header transmission.

```javascript
// Send cookies only for same-origin requests (default)
const response1 = await fetch('/api/data', {
  credentials: 'same-origin'
});

// Always send cookies, even cross-origin
const response2 = await fetch('https://api.example.com/data', {
  credentials: 'include'
});

// Never send cookies
const response3 = await fetch('/api/data', {
  credentials: 'omit'
});
```

**CORS Requirements for `credentials: 'include'`:**

```javascript
// Server must respond with:
// Access-Control-Allow-Credentials: true
// Access-Control-Allow-Origin: https://specific-origin.com (not *)

const response = await fetch('https://api.example.com/data', {
  credentials: 'include',
  headers: {
    'Authorization': 'Bearer token'
  }
});
```

### Cookie-Based Authentication

Session cookies are automatically sent when `credentials` is configured.

```javascript
// Login request sets session cookie
const loginResponse = await fetch('/auth/login', {
  method: 'POST',
  credentials: 'include', // Receive and store cookies
  headers: {
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({
    username: 'user',
    password: 'pass'
  })
});

// Subsequent requests automatically include session cookie
const dataResponse = await fetch('/api/protected', {
  credentials: 'include' // Send cookies
});
```

### Interceptor Pattern

Global authentication injection for all fetch requests.

```javascript
class FetchInterceptor {
  constructor() {
    this.requestInterceptors = [];
    this.responseInterceptors = [];
  }
  
  addRequestInterceptor(interceptor) {
    this.requestInterceptors.push(interceptor);
  }
  
  addResponseInterceptor(interceptor) {
    this.responseInterceptors.push(interceptor);
  }
  
  async fetch(url, options = {}) {
    // Apply request interceptors
    let modifiedOptions = { ...options };
    for (const interceptor of this.requestInterceptors) {
      modifiedOptions = await interceptor(url, modifiedOptions);
    }
    
    // Make request
    let response = await fetch(url, modifiedOptions);
    
    // Apply response interceptors
    for (const interceptor of this.responseInterceptors) {
      response = await interceptor(response, url, modifiedOptions);
    }
    
    return response;
  }
}

// Setup
const interceptor = new FetchInterceptor();

// Add auth interceptor
interceptor.addRequestInterceptor(async (url, options) => {
  const token = await getAccessToken();
  return {
    ...options,
    headers: {
      ...options.headers,
      'Authorization': `Bearer ${token}`
    }
  };
});

// Add retry interceptor for 401s
interceptor.addResponseInterceptor(async (response, url, options) => {
  if (response.status === 401) {
    await refreshToken();
    const token = await getAccessToken();
    
    // Retry with new token
    return fetch(url, {
      ...options,
      headers: {
        ...options.headers,
        'Authorization': `Bearer ${token}`
      }
    });
  }
  return response;
});

// Usage
const response = await interceptor.fetch('/api/data');
```

### Proxy Pattern for Authentication

Wrapper function that adds authentication to all requests.

```javascript
const authenticatedFetch = (() => {
  let token = null;
  
  return async (url, options = {}) => {
    if (!token) {
      token = await loadTokenFromStorage();
    }
    
    return fetch(url, {
      ...options,
      headers: {
        ...options.headers,
        'Authorization': `Bearer ${token}`
      }
    });
  };
})();

// Replace global fetch
const originalFetch = window.fetch;
window.fetch = authenticatedFetch;

// All fetch calls now include authentication
const response = await fetch('/api/data');
```

### Multi-Tenant Authentication

Injecting tenant identifiers alongside authentication.

```javascript
class MultiTenantFetch {
  constructor(token, tenantId) {
    this.token = token;
    this.tenantId = tenantId;
  }
  
  async fetch(url, options = {}) {
    return fetch(url, {
      ...options,
      headers: {
        ...options.headers,
        'Authorization': `Bearer ${this.token}`,
        'X-Tenant-ID': this.tenantId
      }
    });
  }
}

// Usage
const tenantFetch = new MultiTenantFetch('jwt-token', 'tenant-123');
const response = await tenantFetch.fetch('/api/resources');
```

### OAuth 2.0 Flow Integration

Complete OAuth 2.0 authorization code flow with fetch.

```javascript
class OAuth2Client {
  constructor(clientId, redirectUri, authEndpoint, tokenEndpoint) {
    this.clientId = clientId;
    this.redirectUri = redirectUri;
    this.authEndpoint = authEndpoint;
    this.tokenEndpoint = tokenEndpoint;
    this.accessToken = null;
    this.refreshToken = null;
  }
  
  getAuthorizationUrl(state, scope = 'read write') {
    const params = new URLSearchParams({
      client_id: this.clientId,
      redirect_uri: this.redirectUri,
      response_type: 'code',
      scope,
      state
    });
    
    return `${this.authEndpoint}?${params}`;
  }
  
  async exchangeCodeForToken(code) {
    const response = await fetch(this.tokenEndpoint, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded'
      },
      body: new URLSearchParams({
        grant_type: 'authorization_code',
        code,
        client_id: this.clientId,
        redirect_uri: this.redirectUri
      })
    });
    
    if (!response.ok) {
      throw new Error('Token exchange failed');
    }
    
    const data = await response.json();
    this.accessToken = data.access_token;
    this.refreshToken = data.refresh_token;
    
    return data;
  }
  
  async fetchWithAuth(url, options = {}) {
    if (!this.accessToken) {
      throw new Error('Not authenticated');
    }
    
    return fetch(url, {
      ...options,
      headers: {
        ...options.headers,
        'Authorization': `Bearer ${this.accessToken}`
      }
    });
  }
}
```

### JWT Token Parsing

Extracting information from JWT tokens for conditional authentication.

```javascript
function parseJWT(token) {
  try {
    const base64Url = token.split('.')[1];
    const base64 = base64Url.replace(/-/g, '+').replace(/_/g, '/');
    const jsonPayload = decodeURIComponent(
      atob(base64)
        .split('')
        .map(c => '%' + ('00' + c.charCodeAt(0).toString(16)).slice(-2))
        .join('')
    );
    
    return JSON.parse(jsonPayload);
  } catch (error) {
    return null;
  }
}

function isTokenExpired(token) {
  const payload = parseJWT(token);
  if (!payload || !payload.exp) return true;
  
  return Date.now() >= payload.exp * 1000;
}

async function fetchWithTokenCheck(url, token, options = {}) {
  if (isTokenExpired(token)) {
    token = await refreshToken();
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

### Header Priority and Merging

Handling authentication header conflicts and merging.

```javascript
function mergeFetchOptions(defaults, overrides) {
  return {
    ...defaults,
    ...overrides,
    headers: {
      ...defaults.headers,
      ...overrides.headers
    }
  };
}

const defaultAuthOptions = {
  headers: {
    'Authorization': 'Bearer default-token',
    'X-Client-Version': '1.0.0'
  }
};

// Override Authorization but keep other defaults
const response = await fetch('/api/data', mergeFetchOptions(
  defaultAuthOptions,
  {
    headers: {
      'Authorization': 'Bearer specific-token'
    }
  }
));
```

### Device Fingerprinting

Adding device identifiers to authentication headers.

```javascript
async function getDeviceFingerprint() {
  const components = [
    navigator.userAgent,
    navigator.language,
    screen.width,
    screen.height,
    new Date().getTimezoneOffset()
  ];
  
  const fingerprint = components.join('|');
  
  // Hash the fingerprint
  const encoder = new TextEncoder();
  const data = encoder.encode(fingerprint);
  const hashBuffer = await crypto.subtle.digest('SHA-256', data);
  const hashArray = Array.from(new Uint8Array(hashBuffer));
  return hashArray.map(b => b.toString(16).padStart(2, '0')).join('');
}

async function fetchWithDeviceAuth(url, token, options = {}) {
  const deviceId = await getDeviceFingerprint();
  
  return fetch(url, {
    ...options,
    headers: {
      ...options.headers,
      'Authorization': `Bearer ${token}`,
      'X-Device-ID': deviceId
    }
  });
}
```

### Request Signing

HMAC-based request signature for authentication.

```javascript
async function signRequest(method, url, body, secretKey) {
  const timestamp = Date.now().toString();
  const message = `${method}\n${url}\n${timestamp}\n${body || ''}`;
  
  const encoder = new TextEncoder();
  const keyData = encoder.encode(secretKey);
  const messageData = encoder.encode(message);
  
  const key = await crypto.subtle.importKey(
    'raw',
    keyData,
    { name: 'HMAC', hash: 'SHA-256' },
    false,
    ['sign']
  );
  
  const signature = await crypto.subtle.sign('HMAC', key, messageData);
  const signatureArray = Array.from(new Uint8Array(signature));
  const signatureHex = signatureArray
    .map(b => b.toString(16).padStart(2, '0'))
    .join('');
  
  return { signature: signatureHex, timestamp };
}

async function fetchWithSignature(url, secretKey, options = {}) {
  const method = options.method || 'GET';
  const body = options.body;
  
  const { signature, timestamp } = await signRequest(method, url, body, secretKey);
  
  return fetch(url, {
    ...options,
    headers: {
      ...options.headers,
      'X-Signature': signature,
      'X-Timestamp': timestamp
    }
  });
}

// Usage
const response = await fetchWithSignature(
  '/api/data',
  'secret-key',
  {
    method: 'POST',
    body: JSON.stringify({ data: 'value' })
  }
);
```

### Rate Limit Token Bucket

Client-side rate limiting with authentication awareness.

```javascript
class RateLimitedFetch {
  constructor(token, requestsPerSecond = 10) {
    this.token = token;
    this.requestsPerSecond = requestsPerSecond;
    this.tokens = requestsPerSecond;
    this.lastRefill = Date.now();
  }
  
  refillTokens() {
    const now = Date.now();
    const timePassed = (now - this.lastRefill) / 1000;
    const tokensToAdd = timePassed * this.requestsPerSecond;
    
    this.tokens = Math.min(
      this.requestsPerSecond,
      this.tokens + tokensToAdd
    );
    this.lastRefill = now;
  }
  
  async fetch(url, options = {}) {
    this.refillTokens();
    
    if (this.tokens < 1) {
      const waitTime = (1 - this.tokens) / this.requestsPerSecond * 1000;
      await new Promise(resolve => setTimeout(resolve, waitTime));
      this.refillTokens();
    }
    
    this.tokens -= 1;
    
    return fetch(url, {
      ...options,
      headers: {
        ...options.headers,
        'Authorization': `Bearer ${this.token}`
      }
    });
  }
}
```

### Service Worker Authentication Injection

Injecting authentication at the service worker level.

```javascript
// service-worker.js
self.addEventListener('fetch', (event) => {
  if (event.request.url.includes('/api/')) {
    event.respondWith(handleAuthenticatedRequest(event.request));
  }
});

async function handleAuthenticatedRequest(request) {
  // Get token from IndexedDB or cache
  const token = await getTokenFromStorage();
  
  // Clone and modify request
  const headers = new Headers(request.headers);
  headers.set('Authorization', `Bearer ${token}`);
  
  const authenticatedRequest = new Request(request, {
    headers
  });
  
  return fetch(authenticatedRequest);
}

async function getTokenFromStorage() {
  const cache = await caches.open('auth-cache');
  const response = await cache.match('auth-token');
  
  if (response) {
    const data = await response.json();
    return data.token;
  }
  
  return null;
}
```

### Client Credentials Flow

OAuth 2.0 client credentials grant for machine-to-machine authentication.

```javascript
class ClientCredentialsAuth {
  constructor(clientId, clientSecret, tokenEndpoint) {
    this.clientId = clientId;
    this.clientSecret = clientSecret;
    this.tokenEndpoint = tokenEndpoint;
    this.accessToken = null;
    this.expiresAt = null;
  }
  
  async getAccessToken() {
    // Return cached token if still valid
    if (this.accessToken && this.expiresAt > Date.now()) {
      return this.accessToken;
    }
    
    // Request new token
    const credentials = btoa(`${this.clientId}:${this.clientSecret}`);
    
    const response = await fetch(this.tokenEndpoint, {
      method: 'POST',
      headers: {
        'Authorization': `Basic ${credentials}`,
        'Content-Type': 'application/x-www-form-urlencoded'
      },
      body: new URLSearchParams({
        grant_type: 'client_credentials'
      })
    });
    
    if (!response.ok) {
      throw new Error('Failed to obtain access token');
    }
    
    const data = await response.json();
    this.accessToken = data.access_token;
    this.expiresAt = Date.now() + (data.expires_in * 1000);
    
    return this.accessToken;
  }
  
  async fetch(url, options = {}) {
    const token = await this.getAccessToken();
    
    return fetch(url, {
      ...options,
      headers: {
        ...options.headers,
        'Authorization': `Bearer ${token}`
      }
    });
  }
}
```

### Impersonation Headers

Admin impersonation with preserved authentication.

```javascript
async function fetchWithImpersonation(url, adminToken, impersonateUserId, options = {}) {
  return fetch(url, {
    ...options,
    headers: {
      ...options.headers,
      'Authorization': `Bearer ${adminToken}`,
      'X-Impersonate-User': impersonateUserId
    }
  });
}

// Usage
const response = await fetchWithImpersonation(
  '/api/user/profile',
  'admin-token',
  'user-123'
);
```

### Conditional Authentication

Applying authentication only when required.

```javascript
class ConditionalAuthFetch {
  constructor(token) {
    this.token = token;
    this.publicEndpoints = ['/api/public', '/health'];
  }
  
  requiresAuth(url) {
    const urlPath = new URL(url, location.origin).pathname;
    return !this.publicEndpoints.some(endpoint => 
      urlPath.startsWith(endpoint)
    );
  }
  
  async fetch(url, options = {}) {
    const fetchOptions = { ...options };
    
    if (this.requiresAuth(url)) {
      fetchOptions.headers = {
        ...fetchOptions.headers,
        'Authorization': `Bearer ${this.token}`
      };
    }
    
    return fetch(url, fetchOptions);
  }
}
```

### Exponential Backoff for Auth Failures

Retry logic with exponential backoff for authentication errors.

```javascript
async function fetchWithAuthRetry(url, token, options = {}, maxRetries = 3) {
  let lastError;
  
  for (let attempt = 0; attempt < maxRetries; attempt++) {
    try {
      const response = await fetch(url, {
        ...options,
        headers: {
          ...options.headers,
          'Authorization': `Bearer ${token}`
        }
      });
      
      if (response.status === 401 && attempt < maxRetries - 1) {
        // Authentication failed, refresh token and retry
        token = await refreshAuthToken();
        
        // Exponential backoff
        const delay = Math.pow(2, attempt) * 1000;
        await new Promise(resolve => setTimeout(resolve, delay));
        
        continue;
      }
      
      return response;
      
    } catch (error) {
      lastError = error;
      
      if (attempt < maxRetries - 1) {
        const delay = Math.pow(2, attempt) * 1000;
        await new Promise(resolve => setTimeout(resolve, delay));
      }
    }
  }
  
  throw lastError || new Error('Max retries exceeded');
}
```

### Security Context Headers

Adding security context information to authenticated requests.

```javascript
async function fetchWithSecurityContext(url, token, options = {}) {
  const securityContext = {
    requestId: crypto.randomUUID(),
    timestamp: new Date().toISOString(),
    userAgent: navigator.userAgent,
    referrer: document.referrer || 'direct'
  };
  
  return fetch(url, {
    ...options,
    headers: {
      ...options.headers,
      'Authorization': `Bearer ${token}`,
      'X-Request-ID': securityContext.requestId,
      'X-Request-Timestamp': securityContext.timestamp,
      'X-Client-Info': btoa(JSON.stringify({
        userAgent: securityContext.userAgent,
        referrer: securityContext.referrer
      }))
    }
  });
}
```

### Token Storage Strategies

Different approaches for storing authentication tokens.

```javascript
class TokenStorage {
  // Memory storage (most secure, lost on refresh)
  static setInMemory(token) {
    this._memoryToken = token;
  }
  
  static getFromMemory() {
    return this._memoryToken;
  }
  
  // sessionStorage (per-tab, lost on tab close)
  static setInSession(token) {
    sessionStorage.setItem('auth_token', token);
  }
  
  static getFromSession() {
    return sessionStorage.getItem('auth_token');
  }
  
  // localStorage (persistent, shared across tabs)
  static setInLocal(token) {
    localStorage.setItem('auth_token', token);
  }
  
  static getFromLocal() {
    return localStorage.getItem('auth_token');
  }
  
  // Encrypted storage in IndexedDB
  static async setEncrypted(token, encryptionKey) {
    const encrypted = await this.encrypt(token, encryptionKey);
    
    const db = await this.openDB();
    const transaction = db.transaction(['auth'], 'readwrite');
    const store = transaction.objectStore('auth');
    await store.put({ id: 'token', value: encrypted });
  }
  
  static async getEncrypted(encryptionKey) {
    const db = await this.openDB();
    const transaction = db.transaction(['auth'], 'readonly');
    const store = transaction.objectStore('auth');
    const record = await store.get('token');
    
    if (record) {
      return await this.decrypt(record.value, encryptionKey);
    }
    
    return null;
  }
}
```

### Cross-Tab Authentication Sync

Synchronizing authentication state across browser tabs.

```javascript
class CrossTabAuth {
  constructor() {
    this.token = null;
    this.listeners = [];
    
    // Listen for storage events from other tabs
    window.addEventListener('storage', (e) => {
      if (e.key === 'auth_token') {
        this.token = e.newValue;
        this.notifyListeners();
      }
    });
  }
  
  setToken(token) {
    this.token = token;
    localStorage.setItem('auth_token', token);
    this.notifyListeners();
  }
  
  getToken() {
    if (!this.token) {
      this.token = localStorage.getItem('auth_token');
    }
    return this.token;
  }
  
  clearToken() {
    this.token = null;
    localStorage.removeItem('auth_token');
    this.notifyListeners();
  }
  
  onTokenChange(callback) {
    this.listeners.push(callback);
  }
  
  notifyListeners() {
    this.listeners.forEach(callback => callback(this.token));
  }
  
  async fetch(url, options = {}) {
    const token = this.getToken();
    
    if (!token) {
      throw new Error('No authentication token available');
    }
    
    return fetch(url, {
      ...options,
      headers: {
        ...options.headers,
        'Authorization': `Bearer ${token}`
      }
    });
  }
}

// Usage
const auth = new CrossTabAuth();

auth.onTokenChange((token) => {
  if (!token) {
    // Logged out in another tab
    window.location.href = '/login';
  }
});
```

---

