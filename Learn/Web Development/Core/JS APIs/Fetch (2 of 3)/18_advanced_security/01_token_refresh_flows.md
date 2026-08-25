## Token Refresh Flows


### Basic Token Refresh Pattern

Token refresh mechanisms maintain authenticated sessions by obtaining new access tokens before expiration. The fetch API handles authentication headers and token exchange requests with the authorization server.

```javascript
class TokenManager {
  constructor(tokenEndpoint, clientId) {
    this.tokenEndpoint = tokenEndpoint;
    this.clientId = clientId;
    this.accessToken = null;
    this.refreshToken = null;
    this.expiresAt = null;
  }
  
  setTokens(accessToken, refreshToken, expiresIn) {
    this.accessToken = accessToken;
    this.refreshToken = refreshToken;
    // Set expiry slightly before actual expiration (buffer of 60 seconds)
    this.expiresAt = Date.now() + (expiresIn * 1000) - 60000;
  }
  
  isTokenExpired() {
    return !this.accessToken || Date.now() >= this.expiresAt;
  }
  
  async refreshAccessToken() {
    if (!this.refreshToken) {
      throw new Error('No refresh token available');
    }
    
    const response = await fetch(this.tokenEndpoint, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: new URLSearchParams({
        grant_type: 'refresh_token',
        refresh_token: this.refreshToken,
        client_id: this.clientId
      })
    });
    
    if (!response.ok) {
      throw new Error(`Token refresh failed: ${response.status}`);
    }
    
    const data = await response.json();
    this.setTokens(data.access_token, data.refresh_token, data.expires_in);
    
    return this.accessToken;
  }
  
  async getValidToken() {
    if (this.isTokenExpired()) {
      await this.refreshAccessToken();
    }
    return this.accessToken;
  }
}

const tokenManager = new TokenManager('https://auth.example.com/oauth/token', 'client_123');
```

### Automatic Token Refresh Interceptor

Request interceptors automatically refresh tokens before making API calls, ensuring seamless authentication without manual intervention.

```javascript
class AuthenticatedFetch {
  constructor(tokenManager) {
    this.tokenManager = tokenManager;
  }
  
  async fetch(url, options = {}) {
    const token = await this.tokenManager.getValidToken();
    
    const authOptions = {
      ...options,
      headers: {
        ...options.headers,
        'Authorization': `Bearer ${token}`
      }
    };
    
    let response = await fetch(url, authOptions);
    
    // Handle token expiration during request
    if (response.status === 401) {
      await this.tokenManager.refreshAccessToken();
      const newToken = this.tokenManager.accessToken;
      
      authOptions.headers['Authorization'] = `Bearer ${newToken}`;
      response = await fetch(url, authOptions);
    }
    
    return response;
  }
}

const authenticatedFetch = new AuthenticatedFetch(tokenManager);

// Usage
const response = await authenticatedFetch.fetch('https://api.example.com/user/profile');
const data = await response.json();
```

### Proactive Token Refresh

Proactive refresh strategies renew tokens before expiration, preventing interruptions during critical operations.

```javascript
class ProactiveTokenManager extends TokenManager {
  constructor(tokenEndpoint, clientId, refreshThreshold = 300000) {
    super(tokenEndpoint, clientId);
    this.refreshThreshold = refreshThreshold; // 5 minutes default
    this.refreshTimer = null;
  }
  
  setTokens(accessToken, refreshToken, expiresIn) {
    super.setTokens(accessToken, refreshToken, expiresIn);
    this.scheduleProactiveRefresh();
  }
  
  scheduleProactiveRefresh() {
    if (this.refreshTimer) {
      clearTimeout(this.refreshTimer);
    }
    
    const timeUntilRefresh = Math.max(
      0,
      this.expiresAt - Date.now() - this.refreshThreshold
    );
    
    this.refreshTimer = setTimeout(async () => {
      try {
        await this.refreshAccessToken();
      } catch (error) {
        console.error('Proactive token refresh failed:', error);
        // Retry with exponential backoff
        setTimeout(() => this.refreshAccessToken(), 5000);
      }
    }, timeUntilRefresh);
  }
  
  clearSchedule() {
    if (this.refreshTimer) {
      clearTimeout(this.refreshTimer);
      this.refreshTimer = null;
    }
  }
}

const proactiveTokenManager = new ProactiveTokenManager(
  'https://auth.example.com/oauth/token',
  'client_123',
  300000 // Refresh 5 minutes before expiration
);
```

### Concurrent Request Deduplication

Multiple simultaneous requests should not trigger duplicate token refresh attempts. Request deduplication ensures a single refresh operation serves all pending requests.

```javascript
class DedupedTokenManager extends TokenManager {
  constructor(tokenEndpoint, clientId) {
    super(tokenEndpoint, clientId);
    this.refreshPromise = null;
  }
  
  async refreshAccessToken() {
    // Return existing refresh promise if refresh is already in progress
    if (this.refreshPromise) {
      return this.refreshPromise;
    }
    
    this.refreshPromise = (async () => {
      try {
        if (!this.refreshToken) {
          throw new Error('No refresh token available');
        }
        
        const response = await fetch(this.tokenEndpoint, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
          },
          body: new URLSearchParams({
            grant_type: 'refresh_token',
            refresh_token: this.refreshToken,
            client_id: this.clientId
          })
        });
        
        if (!response.ok) {
          throw new Error(`Token refresh failed: ${response.status}`);
        }
        
        const data = await response.json();
        this.setTokens(data.access_token, data.refresh_token, data.expires_in);
        
        return this.accessToken;
      } finally {
        this.refreshPromise = null;
      }
    })();
    
    return this.refreshPromise;
  }
}

// Multiple concurrent requests will share the same refresh operation
const dedupedManager = new DedupedTokenManager('https://auth.example.com/oauth/token', 'client_123');

// These will trigger only one refresh
Promise.all([
  authenticatedFetch.fetch('https://api.example.com/endpoint1'),
  authenticatedFetch.fetch('https://api.example.com/endpoint2'),
  authenticatedFetch.fetch('https://api.example.com/endpoint3')
]);
```

### Token Persistence and Restoration

Persisting tokens across browser sessions requires secure storage mechanisms while managing the refresh lifecycle.

```javascript
class PersistentTokenManager extends DedupedTokenManager {
  constructor(tokenEndpoint, clientId, storageKey = 'auth_tokens') {
    super(tokenEndpoint, clientId);
    this.storageKey = storageKey;
    this.restoreTokens();
  }
  
  setTokens(accessToken, refreshToken, expiresIn) {
    super.setTokens(accessToken, refreshToken, expiresIn);
    this.persistTokens();
  }
  
  persistTokens() {
    const tokenData = {
      accessToken: this.accessToken,
      refreshToken: this.refreshToken,
      expiresAt: this.expiresAt
    };
    
    try {
      localStorage.setItem(this.storageKey, JSON.stringify(tokenData));
    } catch (error) {
      console.error('Failed to persist tokens:', error);
    }
  }
  
  restoreTokens() {
    try {
      const stored = localStorage.getItem(this.storageKey);
      if (!stored) return;
      
      const tokenData = JSON.parse(stored);
      this.accessToken = tokenData.accessToken;
      this.refreshToken = tokenData.refreshToken;
      this.expiresAt = tokenData.expiresAt;
      
      // Immediately refresh if expired
      if (this.isTokenExpired() && this.refreshToken) {
        this.refreshAccessToken().catch(error => {
          console.error('Failed to restore session:', error);
          this.clearTokens();
        });
      }
    } catch (error) {
      console.error('Failed to restore tokens:', error);
      this.clearTokens();
    }
  }
  
  clearTokens() {
    this.accessToken = null;
    this.refreshToken = null;
    this.expiresAt = null;
    
    try {
      localStorage.removeItem(this.storageKey);
    } catch (error) {
      console.error('Failed to clear tokens:', error);
    }
  }
}

const persistentManager = new PersistentTokenManager(
  'https://auth.example.com/oauth/token',
  'client_123'
);
```

### Refresh Token Rotation

Token rotation enhances security by issuing new refresh tokens with each access token refresh, invalidating previous refresh tokens.

```javascript
class RotatingTokenManager extends PersistentTokenManager {
  async refreshAccessToken() {
    if (this.refreshPromise) {
      return this.refreshPromise;
    }
    
    this.refreshPromise = (async () => {
      try {
        if (!this.refreshToken) {
          throw new Error('No refresh token available');
        }
        
        const oldRefreshToken = this.refreshToken;
        
        const response = await fetch(this.tokenEndpoint, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
          },
          body: new URLSearchParams({
            grant_type: 'refresh_token',
            refresh_token: oldRefreshToken,
            client_id: this.clientId
          })
        });
        
        if (!response.ok) {
          // [Inference] Refresh token might be invalidated
          if (response.status === 401) {
            this.clearTokens();
            throw new Error('Refresh token invalid or expired');
          }
          throw new Error(`Token refresh failed: ${response.status}`);
        }
        
        const data = await response.json();
        
        // Server provides new refresh token with each refresh
        this.setTokens(
          data.access_token,
          data.refresh_token || oldRefreshToken, // Fallback if not rotated
          data.expires_in
        );
        
        return this.accessToken;
      } finally {
        this.refreshPromise = null;
      }
    })();
    
    return this.refreshPromise;
  }
}
```

### Silent Token Refresh with Hidden Iframe

Single Page Applications can leverage hidden iframes for silent token refresh using authorization server session cookies.

```javascript
class SilentTokenRefresh {
  constructor(authEndpoint, clientId, redirectUri) {
    this.authEndpoint = authEndpoint;
    this.clientId = clientId;
    this.redirectUri = redirectUri;
    this.iframe = null;
    this.refreshPromise = null;
  }
  
  async refreshToken() {
    if (this.refreshPromise) {
      return this.refreshPromise;
    }
    
    this.refreshPromise = new Promise((resolve, reject) => {
      // Create hidden iframe
      this.iframe = document.createElement('iframe');
      this.iframe.style.display = 'none';
      this.iframe.sandbox = 'allow-same-origin allow-scripts allow-forms';
      
      const timeoutId = setTimeout(() => {
        this.cleanup();
        reject(new Error('Silent refresh timeout'));
      }, 10000);
      
      // Listen for token response
      const messageHandler = (event) => {
        if (event.origin !== new URL(this.authEndpoint).origin) {
          return;
        }
        
        clearTimeout(timeoutId);
        window.removeEventListener('message', messageHandler);
        this.cleanup();
        
        if (event.data.error) {
          reject(new Error(event.data.error));
        } else {
          resolve(event.data);
        }
        
        this.refreshPromise = null;
      };
      
      window.addEventListener('message', messageHandler);
      
      // Build authorization URL with prompt=none
      const params = new URLSearchParams({
        client_id: this.clientId,
        redirect_uri: this.redirectUri,
        response_type: 'token',
        scope: 'openid profile email',
        prompt: 'none'
      });
      
      this.iframe.src = `${this.authEndpoint}?${params.toString()}`;
      document.body.appendChild(this.iframe);
    });
    
    return this.refreshPromise;
  }
  
  cleanup() {
    if (this.iframe && this.iframe.parentNode) {
      this.iframe.parentNode.removeChild(this.iframe);
      this.iframe = null;
    }
  }
}

const silentRefresh = new SilentTokenRefresh(
  'https://auth.example.com/authorize',
  'client_123',
  'https://app.example.com/callback'
);
```

### Refresh Failure Handling

Graceful degradation when refresh operations fail requires clear user communication and session recovery strategies.

```javascript
class RobustTokenManager extends RotatingTokenManager {
  constructor(tokenEndpoint, clientId, onRefreshFailure) {
    super(tokenEndpoint, clientId);
    this.onRefreshFailure = onRefreshFailure;
    this.refreshAttempts = 0;
    this.maxRetries = 3;
  }
  
  async refreshAccessToken() {
    try {
      const token = await super.refreshAccessToken();
      this.refreshAttempts = 0; // Reset on success
      return token;
    } catch (error) {
      this.refreshAttempts++;
      
      if (this.refreshAttempts >= this.maxRetries) {
        this.handleRefreshFailure(error);
        throw error;
      }
      
      // Exponential backoff retry
      const delay = Math.pow(2, this.refreshAttempts) * 1000;
      await new Promise(resolve => setTimeout(resolve, delay));
      
      return this.refreshAccessToken();
    }
  }
  
  handleRefreshFailure(error) {
    console.error('Token refresh failed after retries:', error);
    this.clearTokens();
    
    if (this.onRefreshFailure) {
      this.onRefreshFailure(error);
    }
  }
}

const robustManager = new RobustTokenManager(
  'https://auth.example.com/oauth/token',
  'client_123',
  (error) => {
    // Redirect to login or show session expired modal
    window.location.href = '/login?session_expired=true';
  }
);
```

### Multi-Tab Token Synchronization

Coordinating token refresh across multiple browser tabs prevents race conditions and ensures consistent authentication state.

```javascript
class MultiTabTokenManager extends RobustTokenManager {
  constructor(tokenEndpoint, clientId, onRefreshFailure) {
    super(tokenEndpoint, clientId, onRefreshFailure);
    this.broadcastChannel = new BroadcastChannel('token_sync');
    this.setupSyncListeners();
  }
  
  setupSyncListeners() {
    // Listen for storage changes from other tabs
    window.addEventListener('storage', (event) => {
      if (event.key === this.storageKey && event.newValue) {
        try {
          const tokenData = JSON.parse(event.newValue);
          this.accessToken = tokenData.accessToken;
          this.refreshToken = tokenData.refreshToken;
          this.expiresAt = tokenData.expiresAt;
        } catch (error) {
          console.error('Failed to sync tokens from storage:', error);
        }
      }
    });
    
    // Listen for broadcast messages from other tabs
    this.broadcastChannel.onmessage = (event) => {
      if (event.data.type === 'TOKEN_REFRESHED') {
        this.accessToken = event.data.accessToken;
        this.refreshToken = event.data.refreshToken;
        this.expiresAt = event.data.expiresAt;
      } else if (event.data.type === 'TOKENS_CLEARED') {
        this.clearTokens();
      }
    };
  }
  
  async refreshAccessToken() {
    // Acquire lock to prevent simultaneous refreshes across tabs
    if (navigator.locks) {
      return navigator.locks.request('token_refresh_lock', async () => {
        // Check if another tab already refreshed
        this.restoreTokens();
        if (!this.isTokenExpired()) {
          return this.accessToken;
        }
        
        const token = await super.refreshAccessToken();
        this.broadcastTokenRefresh();
        return token;
      });
    }
    
    // Fallback for browsers without Web Locks API
    const token = await super.refreshAccessToken();
    this.broadcastTokenRefresh();
    return token;
  }
  
  broadcastTokenRefresh() {
    this.broadcastChannel.postMessage({
      type: 'TOKEN_REFRESHED',
      accessToken: this.accessToken,
      refreshToken: this.refreshToken,
      expiresAt: this.expiresAt
    });
  }
  
  clearTokens() {
    super.clearTokens();
    this.broadcastChannel.postMessage({
      type: 'TOKENS_CLEARED'
    });
  }
}

const multiTabManager = new MultiTabTokenManager(
  'https://auth.example.com/oauth/token',
  'client_123',
  (error) => {
    window.location.href = '/login?session_expired=true';
  }
);
```

### Request Queue During Refresh

Queuing API requests during token refresh prevents request failures and maintains operation order.

```javascript
class QueuedAuthenticatedFetch extends AuthenticatedFetch {
  constructor(tokenManager) {
    super(tokenManager);
    this.requestQueue = [];
    this.isRefreshing = false;
  }
  
  async fetch(url, options = {}) {
    // Check if refresh is needed
    if (this.tokenManager.isTokenExpired() && !this.isRefreshing) {
      this.isRefreshing = true;
      
      try {
        await this.tokenManager.refreshAccessToken();
      } catch (error) {
        this.isRefreshing = false;
        this.requestQueue = [];
        throw error;
      }
      
      this.isRefreshing = false;
      this.processQueue();
    }
    
    // Queue request if refresh is in progress
    if (this.isRefreshing) {
      return new Promise((resolve, reject) => {
        this.requestQueue.push({ url, options, resolve, reject });
      });
    }
    
    // Execute request with current token
    const token = this.tokenManager.accessToken;
    const authOptions = {
      ...options,
      headers: {
        ...options.headers,
        'Authorization': `Bearer ${token}`
      }
    };
    
    const response = await fetch(url, authOptions);
    
    // Handle unexpected expiration
    if (response.status === 401 && !this.isRefreshing) {
      this.isRefreshing = true;
      
      try {
        await this.tokenManager.refreshAccessToken();
        this.isRefreshing = false;
        this.processQueue();
        
        // Retry current request
        authOptions.headers['Authorization'] = `Bearer ${this.tokenManager.accessToken}`;
        return fetch(url, authOptions);
      } catch (error) {
        this.isRefreshing = false;
        this.requestQueue = [];
        throw error;
      }
    }
    
    return response;
  }
  
  async processQueue() {
    const queue = [...this.requestQueue];
    this.requestQueue = [];
    
    for (const { url, options, resolve, reject } of queue) {
      try {
        const response = await this.fetch(url, options);
        resolve(response);
      } catch (error) {
        reject(error);
      }
    }
  }
}

const queuedFetch = new QueuedAuthenticatedFetch(multiTabManager);

// Multiple requests during refresh are queued
Promise.all([
  queuedFetch.fetch('https://api.example.com/endpoint1'),
  queuedFetch.fetch('https://api.example.com/endpoint2'),
  queuedFetch.fetch('https://api.example.com/endpoint3')
]);
```

### Refresh Token Expiration Handling

Managing refresh token expiration requires detecting terminal authentication failures and initiating re-authentication flows.

```javascript
class TokenManagerWithReauth extends MultiTabTokenManager {
  constructor(tokenEndpoint, clientId, loginUrl) {
    super(tokenEndpoint, clientId);
    this.loginUrl = loginUrl;
    this.reauthInProgress = false;
  }
  
  async refreshAccessToken() {
    try {
      return await super.refreshAccessToken();
    } catch (error) {
      // Check if refresh token is expired or invalid
      if (this.isRefreshTokenInvalid(error)) {
        this.initiateReauthentication();
        throw new Error('Refresh token expired, reauthentication required');
      }
      throw error;
    }
  }
  
  isRefreshTokenInvalid(error) {
    // [Inference] Error messages vary by authorization server implementation
    return error.message.includes('invalid') || 
           error.message.includes('expired') ||
           error.message.includes('401');
  }
  
  initiateReauthentication() {
    if (this.reauthInProgress) return;
    
    this.reauthInProgress = true;
    this.clearTokens();
    
    // Save current location for post-login redirect
    sessionStorage.setItem('post_login_redirect', window.location.href);
    
    // Redirect to login
    window.location.href = this.loginUrl;
  }
}

const reauthManager = new TokenManagerWithReauth(
  'https://auth.example.com/oauth/token',
  'client_123',
  '/login'
);
```

### Background Token Refresh with Service Workers

Service workers enable background token refresh even when application tabs are closed, maintaining active sessions.

```javascript
// service-worker.js
let tokenManager = null;

self.addEventListener('message', (event) => {
  if (event.data.type === 'INIT_TOKEN_MANAGER') {
    tokenManager = {
      tokenEndpoint: event.data.tokenEndpoint,
      clientId: event.data.clientId,
      refreshToken: event.data.refreshToken,
      expiresAt: event.data.expiresAt
    };
    
    scheduleBackgroundRefresh();
  }
});

async function refreshToken() {
  if (!tokenManager || !tokenManager.refreshToken) return;
  
  try {
    const response = await fetch(tokenManager.tokenEndpoint, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: new URLSearchParams({
        grant_type: 'refresh_token',
        refresh_token: tokenManager.refreshToken,
        client_id: tokenManager.clientId
      })
    });
    
    if (response.ok) {
      const data = await response.json();
      tokenManager.refreshToken = data.refresh_token;
      tokenManager.expiresAt = Date.now() + (data.expires_in * 1000);
      
      // Notify all clients
      const clients = await self.clients.matchAll();
      clients.forEach(client => {
        client.postMessage({
          type: 'TOKEN_REFRESHED',
          accessToken: data.access_token,
          refreshToken: data.refresh_token,
          expiresIn: data.expires_in
        });
      });
      
      scheduleBackgroundRefresh();
    }
  } catch (error) {
    console.error('Background token refresh failed:', error);
  }
}

function scheduleBackgroundRefresh() {
  if (!tokenManager) return;
  
  const timeUntilRefresh = Math.max(
    0,
    tokenManager.expiresAt - Date.now() - 300000 // 5 minutes before expiry
  );
  
  setTimeout(refreshToken, timeUntilRefresh);
}

// Client-side initialization
// main.js
if ('serviceWorker' in navigator) {
  navigator.serviceWorker.register('/service-worker.js').then(registration => {
    navigator.serviceWorker.controller?.postMessage({
      type: 'INIT_TOKEN_MANAGER',
      tokenEndpoint: 'https://auth.example.com/oauth/token',
      clientId: 'client_123',
      refreshToken: persistentManager.refreshToken,
      expiresAt: persistentManager.expiresAt
    });
  });
  
  navigator.serviceWorker.addEventListener('message', (event) => {
    if (event.data.type === 'TOKEN_REFRESHED') {
      persistentManager.setTokens(
        event.data.accessToken,
        event.data.refreshToken,
        event.data.expiresIn
      );
    }
  });
}
```

### Token Refresh with PKCE

Proof Key for Code Exchange adds security to token refresh flows by preventing authorization code interception attacks.

```javascript
class PKCETokenManager extends TokenManager {
  constructor(authEndpoint, tokenEndpoint, clientId) {
    super(tokenEndpoint, clientId);
    this.authEndpoint = authEndpoint;
    this.codeVerifier = null;
  }
  
  async generatePKCE() {
    // Generate code verifier
    const array = new Uint8Array(32);
    crypto.getRandomValues(array);
    this.codeVerifier = this.base64URLEncode(array);
    
    // Generate code challenge
    const encoder = new TextEncoder();
    const data = encoder.encode(this.codeVerifier);
    const hash = await crypto.subtle.digest('SHA-256', data);
    const codeChallenge = this.base64URLEncode(new Uint8Array(hash));
    
    return { codeVerifier: this.codeVerifier, codeChallenge };
  }
  
  base64URLEncode(buffer) {
    const base64 = btoa(String.fromCharCode(...buffer));
    return base64
      .replace(/\+/g, '-')
      .replace(/\//g, '_')
      .replace(/=/g, '');
  }
  
  async exchangeCodeForToken(authorizationCode) {
    if (!this.codeVerifier) {
      throw new Error('Code verifier not found');
    }
    
    const response = await fetch(this.tokenEndpoint, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: new URLSearchParams({
        grant_type: 'authorization_code',
        code: authorizationCode,
        client_id: this.clientId,
        code_verifier: this.codeVerifier
      })
    });
    
    if (!response.ok) {
      throw new Error(`Token exchange failed: ${response.status}`);
    }
    
    const data = await response.json();
    this.setTokens(data.access_token, data.refresh_token, data.expires_in);
    this.codeVerifier = null; // Clear after use
    
    return data;
  }
}

const pkceManager = new PKCETokenManager(
  'https://auth.example.com/authorize',
  'https://auth.example.com/oauth/token',
  'client_123'
);

// Generate PKCE parameters for authorization request
const { codeChallenge } = await pkceManager.generatePKCE();
```

### Device Flow Token Refresh

Device flow implementations for limited-input devices require specialized token refresh handling with device-specific grant types.

```javascript
class DeviceFlowTokenManager extends TokenManager {
  constructor(tokenEndpoint, clientId, deviceCode) {
    super(tokenEndpoint, clientId);
    this.deviceCode = deviceCode;
  }
  
  async pollForToken(interval = 5000) {
    const pollPromise = new Promise((resolve, reject) => {
      const poll = async () => {
        try {
          const response = await fetch(this.tokenEndpoint, {
            method: 'POST',
            headers: {
              'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: new URLSearchParams({
              grant_type: 'urn:ietf:params:oauth:grant-type:device_code',
              device_code: this.deviceCode,
              client_id: this.clientId
            })
          });
          
          const data = await response.json();
          
          if (response.ok) {
            this.setTokens(data.access_token, data.refresh_token, data.expires_in);
            resolve(data);
          } else if (data.error === 'authorization_pending') {
            setTimeout(poll, interval);
          } else if (data.error === 'slow_down') {
            setTimeout(poll, interval + 5000);
          } else {
            reject(new Error(data.error));
          }
        } catch (error) {
          reject(error);
        }
      };
      
      poll();
    });
    
    return pollPromise;
  }
}

const deviceManager = new DeviceFlowTokenManager(
  'https://auth.example.com/oauth/token',
  'device_client_123',
  'DEVICE_CODE_ABC123'
);

// Start polling for user authorization
await deviceManager.pollForToken();
```

---

