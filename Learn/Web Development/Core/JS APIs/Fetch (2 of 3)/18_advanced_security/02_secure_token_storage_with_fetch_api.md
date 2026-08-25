## Secure Token Storage with Fetch API


### Storage Location Considerations

Tokens (authentication tokens, API keys, session identifiers) require careful storage to balance security and usability. Each storage mechanism presents distinct security trade-offs.

**localStorage/sessionStorage vulnerabilities:**

- Accessible to any JavaScript code including third-party scripts
- Vulnerable to XSS attacks
- Persist across page reloads (localStorage) or browser session (sessionStorage)
- Not sent automatically with requests
- Domain-scoped but accessible to all scripts on that domain

**Cookie-based storage:**

- Can be configured with HttpOnly flag (inaccessible to JavaScript)
- Automatically sent with requests to matching domains
- Vulnerable to CSRF if not properly protected
- Can use Secure flag for HTTPS-only transmission
- Supports SameSite attribute for CSRF protection

**In-memory storage:**

- Lost on page reload/navigation
- Not vulnerable to XSS persistence
- Requires re-authentication more frequently
- Best security profile for sensitive tokens

```javascript
class TokenStore {
  constructor() {
    // In-memory storage - most secure but not persistent
    this.memoryStore = new Map();
  }
  
  // Store in memory only
  setInMemory(key, token) {
    this.memoryStore.set(key, {
      token,
      timestamp: Date.now()
    });
  }
  
  getInMemory(key) {
    const stored = this.memoryStore.get(key);
    return stored ? stored.token : null;
  }
  
  // Clear all tokens
  clearAll() {
    this.memoryStore.clear();
  }
  
  // Check if token exists
  has(key) {
    return this.memoryStore.has(key);
  }
}

// Usage with fetch
const tokenStore = new TokenStore();

// Store token after authentication
async function login(credentials) {
  const response = await fetch('/auth/login', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(credentials)
  });
  
  const data = await response.json();
  tokenStore.setInMemory('accessToken', data.accessToken);
  tokenStore.setInMemory('refreshToken', data.refreshToken);
}

// Use token in requests
async function authenticatedFetch(url, options = {}) {
  const token = tokenStore.getInMemory('accessToken');
  
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
```

### Token Encryption in Storage

When persistent storage is required, encrypting tokens adds a layer of defense. [Inference: This approach reduces but does not eliminate XSS risk, as the encryption key must also be stored]

```javascript
class EncryptedTokenStore {
  constructor(encryptionKey) {
    this.key = encryptionKey;
  }
  
  async deriveKey(password) {
    const encoder = new TextEncoder();
    const keyMaterial = await crypto.subtle.importKey(
      'raw',
      encoder.encode(password),
      { name: 'PBKDF2' },
      false,
      ['deriveKey']
    );
    
    return crypto.subtle.deriveKey(
      {
        name: 'PBKDF2',
        salt: encoder.encode('static-salt'), // [Unverified: Production should use dynamic salt]
        iterations: 100000,
        hash: 'SHA-256'
      },
      keyMaterial,
      { name: 'AES-GCM', length: 256 },
      false,
      ['encrypt', 'decrypt']
    );
  }
  
  async encrypt(text, key) {
    const encoder = new TextEncoder();
    const data = encoder.encode(text);
    const iv = crypto.getRandomValues(new Uint8Array(12));
    
    const encrypted = await crypto.subtle.encrypt(
      { name: 'AES-GCM', iv },
      key,
      data
    );
    
    // Combine IV and encrypted data
    const combined = new Uint8Array(iv.length + encrypted.byteLength);
    combined.set(iv, 0);
    combined.set(new Uint8Array(encrypted), iv.length);
    
    return btoa(String.fromCharCode(...combined));
  }
  
  async decrypt(encryptedText, key) {
    const combined = Uint8Array.from(atob(encryptedText), c => c.charCodeAt(0));
    const iv = combined.slice(0, 12);
    const data = combined.slice(12);
    
    const decrypted = await crypto.subtle.decrypt(
      { name: 'AES-GCM', iv },
      key,
      data
    );
    
    return new TextDecoder().decode(decrypted);
  }
  
  async setToken(tokenName, token, password) {
    const key = await this.deriveKey(password);
    const encrypted = await this.encrypt(token, key);
    sessionStorage.setItem(tokenName, encrypted);
  }
  
  async getToken(tokenName, password) {
    const encrypted = sessionStorage.getItem(tokenName);
    if (!encrypted) return null;
    
    try {
      const key = await this.deriveKey(password);
      return await this.decrypt(encrypted, key);
    } catch {
      return null;
    }
  }
}
```

### Token Expiration and Refresh Flow

Implementing token expiration checking and automatic refresh prevents using expired tokens and reduces exposure window.

```javascript
class TokenManager {
  constructor() {
    this.tokens = new Map();
    this.refreshPromise = null;
  }
  
  setTokens(accessToken, refreshToken, expiresIn) {
    const expiresAt = Date.now() + (expiresIn * 1000);
    
    this.tokens.set('access', {
      token: accessToken,
      expiresAt
    });
    
    if (refreshToken) {
      this.tokens.set('refresh', {
        token: refreshToken,
        expiresAt: null // Refresh tokens typically have longer/no expiration
      });
    }
  }
  
  getAccessToken() {
    const stored = this.tokens.get('access');
    if (!stored) return null;
    
    // Check if expired
    if (Date.now() >= stored.expiresAt) {
      return null;
    }
    
    return stored.token;
  }
  
  isAccessTokenExpired() {
    const stored = this.tokens.get('access');
    if (!stored) return true;
    
    return Date.now() >= stored.expiresAt;
  }
  
  shouldRefresh() {
    const stored = this.tokens.get('access');
    if (!stored) return false;
    
    // Refresh when 5 minutes remain
    const fiveMinutes = 5 * 60 * 1000;
    return Date.now() >= (stored.expiresAt - fiveMinutes);
  }
  
  async refreshAccessToken() {
    // Prevent multiple simultaneous refresh requests
    if (this.refreshPromise) {
      return this.refreshPromise;
    }
    
    const refreshToken = this.tokens.get('refresh')?.token;
    if (!refreshToken) {
      throw new Error('No refresh token available');
    }
    
    this.refreshPromise = (async () => {
      try {
        const response = await fetch('/auth/refresh', {
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
        this.setTokens(data.accessToken, data.refreshToken, data.expiresIn);
        
        return data.accessToken;
      } finally {
        this.refreshPromise = null;
      }
    })();
    
    return this.refreshPromise;
  }
  
  clearTokens() {
    this.tokens.clear();
  }
}

// Automatic refresh interceptor
async function fetchWithTokenRefresh(url, options = {}) {
  const tokenManager = window.tokenManager;
  
  // Check if token needs refresh
  if (tokenManager.shouldRefresh()) {
    try {
      await tokenManager.refreshAccessToken();
    } catch (error) {
      // Refresh failed, clear tokens and redirect to login
      tokenManager.clearTokens();
      window.location.href = '/login';
      throw error;
    }
  }
  
  const token = tokenManager.getAccessToken();
  if (!token) {
    throw new Error('No valid access token');
  }
  
  const response = await fetch(url, {
    ...options,
    headers: {
      ...options.headers,
      'Authorization': `Bearer ${token}`
    }
  });
  
  // Handle 401 by attempting refresh once
  if (response.status === 401) {
    try {
      await tokenManager.refreshAccessToken();
      const newToken = tokenManager.getAccessToken();
      
      // Retry original request with new token
      return fetch(url, {
        ...options,
        headers: {
          ...options.headers,
          'Authorization': `Bearer ${newToken}`
        }
      });
    } catch {
      tokenManager.clearTokens();
      window.location.href = '/login';
      throw new Error('Authentication failed');
    }
  }
  
  return response;
}
```

### Content Security Policy Integration

CSP headers restrict where scripts can be loaded from and what operations they can perform, reducing XSS risk.

```javascript
// Server sends CSP header:
// Content-Security-Policy: 
//   default-src 'self'; 
//   script-src 'self' 'nonce-{random}'; 
//   connect-src 'self' https://api.example.com;
//   style-src 'self' 'unsafe-inline'

// Client-side token handling remains the same
// but inline scripts and eval are blocked, reducing XSS vectors

// Check CSP support and configuration
function checkCSPSupport() {
  const meta = document.querySelector('meta[http-equiv="Content-Security-Policy"]');
  const hasCSP = meta || 
                 document.securityPolicy || 
                 !!window.SecurityPolicyViolationEvent;
  
  return hasCSP;
}

// Listen for CSP violations
document.addEventListener('securitypolicyviolation', (e) => {
  // Log violation for security monitoring
  fetch('/security/csp-violation', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      blockedURI: e.blockedURI,
      violatedDirective: e.violatedDirective,
      originalPolicy: e.originalPolicy,
      sourceFile: e.sourceFile,
      lineNumber: e.lineNumber
    }),
    keepalive: true
  });
});
```

### Subresource Integrity for Token Scripts

When loading token management libraries from CDNs, SRI prevents tampering.

```html
<script 
  src="https://cdn.example.com/auth-lib.js"
  integrity="sha384-oqVuAfXRKap7fdgcCY5uykM6+R9GqQ8K/uxQ"
  crossorigin="anonymous">
</script>
```

```javascript
// Verify dynamically loaded scripts
async function loadSecureScript(url, expectedHash) {
  const response = await fetch(url);
  const content = await response.text();
  
  // Calculate hash
  const encoder = new TextEncoder();
  const data = encoder.encode(content);
  const hashBuffer = await crypto.subtle.digest('SHA-384', data);
  const hashArray = Array.from(new Uint8Array(hashBuffer));
  const hashBase64 = btoa(String.fromCharCode(...hashArray));
  
  if (hashBase64 !== expectedHash) {
    throw new Error('Script integrity check failed');
  }
  
  // Execute script
  const script = document.createElement('script');
  script.textContent = content;
  document.head.appendChild(script);
}
```

### Token Scope Limitation

Limiting token permissions reduces impact if compromised.

```javascript
class ScopedTokenManager {
  constructor() {
    this.tokens = new Map();
  }
  
  // Store multiple tokens with different scopes
  setToken(scope, token, expiresIn) {
    this.tokens.set(scope, {
      token,
      expiresAt: Date.now() + (expiresIn * 1000),
      scope
    });
  }
  
  getToken(requiredScope) {
    const stored = this.tokens.get(requiredScope);
    
    if (!stored || Date.now() >= stored.expiresAt) {
      return null;
    }
    
    return stored.token;
  }
  
  // Request token with minimal required scope
  async requestScopedToken(scope) {
    const response = await fetch('/auth/token', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ scope })
    });
    
    const data = await response.json();
    this.setToken(scope, data.token, data.expiresIn);
    return data.token;
  }
}

// Usage
const scopedManager = new ScopedTokenManager();

// Get read-only token for fetching data
async function fetchUserData() {
  const token = scopedManager.getToken('read:user') || 
                await scopedManager.requestScopedToken('read:user');
  
  return fetch('/api/user', {
    headers: { 'Authorization': `Bearer ${token}` }
  });
}

// Get write token only when needed
async function updateUserData(updates) {
  const token = scopedManager.getToken('write:user') || 
                await scopedManager.requestScopedToken('write:user');
  
  return fetch('/api/user', {
    method: 'PATCH',
    headers: {
      'Authorization': `Bearer ${token}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify(updates)
  });
}
```

### Fingerprinting and Device Binding

Binding tokens to device characteristics makes stolen tokens harder to use on different devices. [Inference: This adds friction and may not prevent sophisticated attacks]

```javascript
class DeviceBoundTokenManager {
  async generateDeviceFingerprint() {
    const components = [];
    
    // Screen properties
    components.push(`${screen.width}x${screen.height}x${screen.colorDepth}`);
    
    // Timezone
    components.push(Intl.DateTimeFormat().resolvedOptions().timeZone);
    
    // Language
    components.push(navigator.language);
    
    // Hardware concurrency
    components.push(navigator.hardwareConcurrency);
    
    // Canvas fingerprint
    const canvas = document.createElement('canvas');
    const ctx = canvas.getContext('2d');
    ctx.textBaseline = 'top';
    ctx.font = '14px Arial';
    ctx.fillText('fingerprint', 2, 2);
    components.push(canvas.toDataURL().slice(-50));
    
    // Hash all components
    const fingerprint = components.join('|');
    const encoder = new TextEncoder();
    const data = encoder.encode(fingerprint);
    const hashBuffer = await crypto.subtle.digest('SHA-256', data);
    const hashArray = Array.from(new Uint8Array(hashBuffer));
    
    return hashArray.map(b => b.toString(16).padStart(2, '0')).join('');
  }
  
  async storeTokenWithFingerprint(token, expiresIn) {
    const fingerprint = await this.generateDeviceFingerprint();
    
    sessionStorage.setItem('token', JSON.stringify({
      token,
      fingerprint,
      expiresAt: Date.now() + (expiresIn * 1000)
    }));
  }
  
  async getTokenIfValid() {
    const stored = sessionStorage.getItem('token');
    if (!stored) return null;
    
    try {
      const data = JSON.parse(stored);
      
      // Check expiration
      if (Date.now() >= data.expiresAt) {
        return null;
      }
      
      // Verify fingerprint matches
      const currentFingerprint = await this.generateDeviceFingerprint();
      if (currentFingerprint !== data.fingerprint) {
        // Fingerprint mismatch - possible token theft
        sessionStorage.removeItem('token');
        return null;
      }
      
      return data.token;
    } catch {
      return null;
    }
  }
}
```

### Rate Limiting Token Usage

Implementing client-side rate limiting reduces impact of compromised tokens.

```javascript
class RateLimitedTokenManager {
  constructor(maxRequestsPerMinute = 60) {
    this.maxRequests = maxRequestsPerMinute;
    this.requests = [];
    this.token = null;
  }
  
  setToken(token) {
    this.token = token;
  }
  
  canMakeRequest() {
    const now = Date.now();
    const oneMinuteAgo = now - 60000;
    
    // Remove requests older than 1 minute
    this.requests = this.requests.filter(time => time > oneMinuteAgo);
    
    return this.requests.length < this.maxRequests;
  }
  
  recordRequest() {
    this.requests.push(Date.now());
  }
  
  async fetchWithRateLimit(url, options = {}) {
    if (!this.canMakeRequest()) {
      throw new Error('Rate limit exceeded');
    }
    
    if (!this.token) {
      throw new Error('No token available');
    }
    
    this.recordRequest();
    
    return fetch(url, {
      ...options,
      headers: {
        ...options.headers,
        'Authorization': `Bearer ${this.token}`
      }
    });
  }
  
  getRemainingRequests() {
    const now = Date.now();
    const oneMinuteAgo = now - 60000;
    const recentRequests = this.requests.filter(time => time > oneMinuteAgo);
    
    return this.maxRequests - recentRequests.length;
  }
  
  getResetTime() {
    if (this.requests.length === 0) return 0;
    
    const oldestRequest = Math.min(...this.requests);
    const resetTime = oldestRequest + 60000;
    
    return Math.max(0, resetTime - Date.now());
  }
}
```

### Secure Token Transmission

Ensuring tokens are only sent over secure channels and not logged or exposed.

```javascript
class SecureTokenFetcher {
  constructor(token) {
    this.token = token;
  }
  
  async secureFetch(url, options = {}) {
    // Verify HTTPS
    const urlObj = new URL(url, location.href);
    if (urlObj.protocol !== 'https:' && location.protocol === 'https:') {
      throw new Error('Cannot send token over insecure connection');
    }
    
    // Clone options to avoid mutating original
    const secureOptions = { ...options };
    
    // Ensure headers object exists
    secureOptions.headers = new Headers(secureOptions.headers || {});
    
    // Add authorization header
    secureOptions.headers.set('Authorization', `Bearer ${this.token}`);
    
    // Prevent credentials from being cached in browser history
    secureOptions.cache = 'no-store';
    
    try {
      const response = await fetch(url, secureOptions);
      return response;
    } catch (error) {
      // Don't expose token in error messages
      const sanitizedError = new Error(
        `Fetch failed: ${error.message.replace(this.token, '[REDACTED]')}`
      );
      throw sanitizedError;
    }
  }
  
  // Clear token from memory
  destroy() {
    this.token = null;
  }
}

// Prevent token exposure in browser dev tools
Object.defineProperty(window, 'sensitiveToken', {
  get() {
    console.warn('Access to token detected');
    return '[PROTECTED]';
  },
  set(value) {
    // Store in closure, not directly on window
    this._token = value;
  },
  configurable: false,
  enumerable: false
});
```

### Token Rotation Strategy

Regularly rotating tokens limits exposure window.

```javascript
class RotatingTokenManager {
  constructor(rotationInterval = 15 * 60 * 1000) { // 15 minutes
    this.rotationInterval = rotationInterval;
    this.currentToken = null;
    this.nextToken = null;
    this.rotationTimer = null;
    this.lastRotation = null;
  }
  
  async initialize(initialToken) {
    this.currentToken = initialToken;
    this.lastRotation = Date.now();
    this.scheduleRotation();
    
    // Pre-fetch next token
    await this.prefetchNextToken();
  }
  
  scheduleRotation() {
    if (this.rotationTimer) {
      clearTimeout(this.rotationTimer);
    }
    
    this.rotationTimer = setTimeout(
      () => this.rotateToken(),
      this.rotationInterval
    );
  }
  
  async prefetchNextToken() {
    try {
      const response = await fetch('/auth/rotate', {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${this.currentToken}`,
          'Content-Type': 'application/json'
        }
      });
      
      const data = await response.json();
      this.nextToken = data.nextToken;
    } catch (error) {
      console.error('Failed to prefetch next token:', error);
    }
  }
  
  async rotateToken() {
    if (this.nextToken) {
      // Swap to pre-fetched token
      this.currentToken = this.nextToken;
      this.nextToken = null;
      this.lastRotation = Date.now();
    } else {
      // Fallback: fetch new token immediately
      try {
        const response = await fetch('/auth/rotate', {
          method: 'POST',
          headers: {
            'Authorization': `Bearer ${this.currentToken}`,
            'Content-Type': 'application/json'
          }
        });
        
        const data = await response.json();
        this.currentToken = data.nextToken;
        this.lastRotation = Date.now();
      } catch (error) {
        console.error('Token rotation failed:', error);
        return;
      }
    }
    
    // Schedule next rotation and prefetch
    this.scheduleRotation();
    await this.prefetchNextToken();
  }
  
  getCurrentToken() {
    // Check if rotation is overdue
    if (Date.now() - this.lastRotation > this.rotationInterval * 1.5) {
      console.warn('Token rotation overdue');
    }
    
    return this.currentToken;
  }
  
  async fetchWithRotation(url, options = {}) {
    const token = this.getCurrentToken();
    
    return fetch(url, {
      ...options,
      headers: {
        ...options.headers,
        'Authorization': `Bearer ${token}`
      }
    });
  }
  
  destroy() {
    if (this.rotationTimer) {
      clearTimeout(this.rotationTimer);
    }
    this.currentToken = null;
    this.nextToken = null;
  }
}
```

### Secure Token Deletion

Properly clearing tokens from all storage locations when logging out.

```javascript
class SecureTokenCleanup {
  static clearAllTokenStorage() {
    // Clear localStorage
    const localStorageKeys = Object.keys(localStorage);
    localStorageKeys.forEach(key => {
      if (key.includes('token') || key.includes('auth') || key.includes('session')) {
        localStorage.removeItem(key);
      }
    });
    
    // Clear sessionStorage
    const sessionStorageKeys = Object.keys(sessionStorage);
    sessionStorageKeys.forEach(key => {
      if (key.includes('token') || key.includes('auth') || key.includes('session')) {
        sessionStorage.removeItem(key);
      }
    });
    
    // Clear cookies
    document.cookie.split(';').forEach(cookie => {
      const name = cookie.split('=')[0].trim();
      if (name.includes('token') || name.includes('auth') || name.includes('session')) {
        document.cookie = `${name}=; expires=Thu, 01 Jan 1970 00:00:00 UTC; path=/;`;
      }
    });
    
    // Clear any in-memory references
    if (window.tokenManager) {
      window.tokenManager.clearTokens();
      window.tokenManager = null;
    }
  }
  
  static async invalidateOnServer(token) {
    try {
      await fetch('/auth/logout', {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json'
        }
      });
    } catch (error) {
      console.error('Server-side logout failed:', error);
    }
  }
  
  static async secureLogout() {
    // Get current token before clearing
    const token = window.tokenManager?.getAccessToken();
    
    // Invalidate on server first
    if (token) {
      await this.invalidateOnServer(token);
    }
    
    // Clear all client-side storage
    this.clearAllTokenStorage();
    
    // Redirect to login
    window.location.href = '/login';
  }
}

// Usage
document.getElementById('logoutBtn')?.addEventListener('click', () => {
  SecureTokenCleanup.secureLogout();
});

// Also handle browser close/navigation
window.addEventListener('beforeunload', () => {
  const token = window.tokenManager?.getAccessToken();
  if (token) {
    // Use sendBeacon for reliable logout during navigation
    navigator.sendBeacon('/auth/logout', JSON.stringify({ token }));
  }
});
```

### Cross-Origin Token Handling

Managing tokens when making requests to different origins.

```javascript
class CrossOriginTokenManager {
  constructor() {
    this.tokens = new Map();
    this.allowedOrigins = new Set();
  }
  
  addAllowedOrigin(origin) {
    this.allowedOrigins.add(origin);
  }
  
  setTokenForOrigin(origin, token) {
    if (!this.allowedOrigins.has(origin)) {
      throw new Error(`Origin ${origin} not in allowlist`);
    }
    this.tokens.set(origin, token);
  }
  
  getTokenForOrigin(origin) {
    if (!this.allowedOrigins.has(origin)) {
      return null;
    }
    return this.tokens.get(origin);
  }
  
  async fetchCrossOrigin(url, options = {}) {
    const urlObj = new URL(url);
    const origin = urlObj.origin;
    
    // Check if origin is allowed
    if (!this.allowedOrigins.has(origin)) {
      throw new Error(`Requests to ${origin} are not permitted`);
    }
    
    const token = this.tokens.get(origin);
    if (!token) {
      throw new Error(`No token available for ${origin}`);
    }
    
    return fetch(url, {
      ...options,
      headers: {
        ...options.headers,
        'Authorization': `Bearer ${token}`
      },
      // Explicitly set credentials mode
      credentials: 'omit' // Don't send cookies cross-origin
    });
  }
}

// Usage
const crossOriginManager = new CrossOriginTokenManager();
crossOriginManager.addAllowedOrigin('https://api.example.com');
crossOriginManager.addAllowedOrigin('https://cdn.example.com');

// Set different tokens for different services
crossOriginManager.setTokenForOrigin('https://api.example.com', apiToken);
crossOriginManager.setTokenForOrigin('https://cdn.example.com', cdnToken);

// Make cross-origin request
await crossOriginManager.fetchCrossOrigin('https://api.example.com/data');
```

---

