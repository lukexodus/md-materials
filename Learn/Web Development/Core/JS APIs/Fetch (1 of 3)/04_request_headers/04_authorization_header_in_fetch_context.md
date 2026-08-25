## Authorization Header in Fetch Context


### Basic Syntax

The `Authorization` header transmits credentials to authenticate HTTP requests. Standard syntax:

```javascript
fetch(url, {
  headers: {
    'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...'
  }
});
```

### Authentication Schemes

#### Bearer Token (Most Common for APIs)

Used for OAuth 2.0, JWT, and generic API tokens:

```javascript
const token = 'your-access-token';

fetch(url, {
  headers: {
    'Authorization': `Bearer ${token}`
  }
});
```

The scheme name `Bearer` is case-insensitive but conventionally capitalized. Space between scheme and token is required.

#### Basic Authentication

Encodes username:password in Base64:

```javascript
const username = 'user';
const password = 'pass';
const credentials = btoa(`${username}:${password}`);

fetch(url, {
  headers: {
    'Authorization': `Basic ${credentials}`
  }
});
```

**Security note**: Basic auth transmits credentials in every request. Always use HTTPS.

#### API Key (Custom Schemes)

Some APIs use custom header schemes:

```javascript
// Custom scheme
fetch(url, {
  headers: {
    'Authorization': `ApiKey ${apiKey}`
  }
});

// Or non-Authorization headers
fetch(url, {
  headers: {
    'X-API-Key': apiKey,
    'X-API-Secret': apiSecret
  }
});
```

#### Digest Authentication

Rarely used in modern fetch contexts. Requires complex challenge-response:

```javascript
// Digest auth typically requires parsing WWW-Authenticate challenge
// and computing hash responses - not commonly implemented in fetch
```

[Inference] Digest authentication is complex enough that libraries or browser built-in handling is typically preferred over manual implementation.

### Dynamic Token Management

#### Retrieving Tokens from Storage

```javascript
const token = localStorage.getItem('access_token');

fetch(url, {
  headers: {
    'Authorization': token ? `Bearer ${token}` : undefined
  }
});
```

**Security consideration**: localStorage is vulnerable to XSS. For sensitive tokens, consider httpOnly cookies or sessionStorage with appropriate security measures.

#### Token Refresh Pattern

```javascript
async function fetchWithAuth(url, options = {}) {
  let token = getAccessToken();
  
  const response = await fetch(url, {
    ...options,
    headers: {
      ...options.headers,
      'Authorization': `Bearer ${token}`
    }
  });
  
  // Token expired
  if (response.status === 401) {
    token = await refreshAccessToken();
    
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
}

async function refreshAccessToken() {
  const refreshToken = getRefreshToken();
  
  const response = await fetch('/auth/refresh', {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${refreshToken}`
    }
  });
  
  const { access_token } = await response.json();
  setAccessToken(access_token);
  return access_token;
}
```

### Headers Object Construction

#### Using Headers Constructor

```javascript
const headers = new Headers();
headers.append('Authorization', `Bearer ${token}`);
headers.append('Content-Type', 'application/json');

fetch(url, { headers });
```

#### Conditional Header Inclusion

```javascript
const headers = {
  'Content-Type': 'application/json',
  ...(token && { 'Authorization': `Bearer ${token}` })
};

fetch(url, { headers });
```

### CORS and Authorization

The `Authorization` header triggers CORS preflight requests. Server must respond with appropriate headers:

```javascript
// Client-side - no special handling needed
fetch('https://api.example.com/data', {
  headers: {
    'Authorization': `Bearer ${token}`
  }
});

// Server must respond to OPTIONS preflight with:
// Access-Control-Allow-Origin: https://your-domain.com
// Access-Control-Allow-Headers: Authorization, Content-Type
// Access-Control-Allow-Methods: GET, POST, etc.
```

Credentials mode considerations:

```javascript
// For cross-origin requests with Authorization
fetch(url, {
  credentials: 'include', // If using cookies alongside Authorization
  headers: {
    'Authorization': `Bearer ${token}`
  }
});
```

[Inference] The `credentials: 'include'` mode is typically unnecessary when using `Authorization` header alone, as the token is explicitly provided. It's relevant when combining with cookie-based authentication.

### Request Interceptor Pattern

Creating a wrapper for consistent auth handling:

```javascript
class AuthenticatedFetch {
  constructor(baseURL, getToken) {
    this.baseURL = baseURL;
    this.getToken = getToken;
  }
  
  async fetch(endpoint, options = {}) {
    const token = await this.getToken();
    const url = `${this.baseURL}${endpoint}`;
    
    return fetch(url, {
      ...options,
      headers: {
        ...options.headers,
        ...(token && { 'Authorization': `Bearer ${token}` })
      }
    });
  }
  
  get(endpoint, options) {
    return this.fetch(endpoint, { ...options, method: 'GET' });
  }
  
  post(endpoint, data, options) {
    return this.fetch(endpoint, {
      ...options,
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        ...options?.headers
      },
      body: JSON.stringify(data)
    });
  }
}

// Usage
const api = new AuthenticatedFetch('https://api.example.com', () => localStorage.getItem('token'));
const response = await api.get('/users');
```

### Multiple Authentication Methods

Handling different auth schemes dynamically:

```javascript
function getAuthHeader(authType, credentials) {
  switch (authType) {
    case 'bearer':
      return `Bearer ${credentials.token}`;
    
    case 'basic':
      return `Basic ${btoa(`${credentials.username}:${credentials.password}`)}`;
    
    case 'apikey':
      return `ApiKey ${credentials.key}`;
    
    default:
      return null;
  }
}

fetch(url, {
  headers: {
    'Authorization': getAuthHeader('bearer', { token: 'abc123' })
  }
});
```

### Token Expiration Handling

#### Proactive Expiration Check

```javascript
function isTokenExpired(token) {
  try {
    const payload = JSON.parse(atob(token.split('.')[1]));
    return payload.exp * 1000 < Date.now();
  } catch (e) {
    return true;
  }
}

async function fetchWithValidToken(url, options = {}) {
  let token = getAccessToken();
  
  if (isTokenExpired(token)) {
    token = await refreshAccessToken();
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

[Inference] This assumes JWT format with standard `exp` claim. Non-JWT tokens require alternative expiration tracking mechanisms.

#### Retry Queue for Concurrent Requests

```javascript
class TokenManager {
  constructor() {
    this.refreshPromise = null;
  }
  
  async getValidToken() {
    let token = getAccessToken();
    
    if (isTokenExpired(token)) {
      // Prevent multiple simultaneous refresh attempts
      if (!this.refreshPromise) {
        this.refreshPromise = this.refresh().finally(() => {
          this.refreshPromise = null;
        });
      }
      token = await this.refreshPromise;
    }
    
    return token;
  }
  
  async refresh() {
    const refreshToken = getRefreshToken();
    const response = await fetch('/auth/refresh', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${refreshToken}`
      }
    });
    
    const { access_token } = await response.json();
    setAccessToken(access_token);
    return access_token;
  }
}

const tokenManager = new TokenManager();

async function authenticatedFetch(url, options = {}) {
  const token = await tokenManager.getValidToken();
  
  return fetch(url, {
    ...options,
    headers: {
      ...options.headers,
      'Authorization': `Bearer ${token}`
    }
  });
}
```

### Security Best Practices

#### Avoiding Token Exposure

```javascript
// Never log tokens
console.log(`Fetching with token: ${token}`); // BAD

// Never send tokens to untrusted origins
const trustedDomains = ['api.example.com', 'auth.example.com'];

function shouldIncludeAuth(url) {
  const urlObj = new URL(url);
  return trustedDomains.includes(urlObj.hostname);
}

fetch(url, {
  headers: {
    ...(shouldIncludeAuth(url) && { 'Authorization': `Bearer ${token}` })
  }
});
```

#### Removing Sensitive Headers from Error Logs

```javascript
async function safeFetch(url, options = {}) {
  try {
    return await fetch(url, options);
  } catch (error) {
    // Strip Authorization before logging
    const safeOptions = {
      ...options,
      headers: {
        ...options.headers,
        Authorization: '[REDACTED]'
      }
    };
    
    console.error('Fetch failed:', { url, options: safeOptions, error });
    throw error;
  }
}
```

### Authorization with Different Content Types

#### Form Data with Auth

```javascript
const formData = new FormData();
formData.append('file', fileInput.files[0]);

fetch(url, {
  method: 'POST',
  headers: {
    'Authorization': `Bearer ${token}`
    // Do NOT set Content-Type for FormData - browser sets it with boundary
  },
  body: formData
});
```

#### GraphQL with Auth

```javascript
fetch('/graphql', {
  method: 'POST',
  headers: {
    'Authorization': `Bearer ${token}`,
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({
    query: `
      query GetUser($id: ID!) {
        user(id: $id) {
          name
          email
        }
      }
    `,
    variables: { id: '123' }
  })
});
```

### Handling 401 Unauthorized Responses

```javascript
async function fetchWithAuthRetry(url, options = {}, maxRetries = 1) {
  let token = getAccessToken();
  
  for (let attempt = 0; attempt <= maxRetries; attempt++) {
    const response = await fetch(url, {
      ...options,
      headers: {
        ...options.headers,
        'Authorization': `Bearer ${token}`
      }
    });
    
    if (response.status === 401 && attempt < maxRetries) {
      // Attempt token refresh
      try {
        token = await refreshAccessToken();
        continue;
      } catch (refreshError) {
        // Refresh failed - redirect to login or handle accordingly
        handleAuthenticationFailure();
        throw new Error('Authentication failed');
      }
    }
    
    return response;
  }
}
```

### Authorization with Server-Sent Events (SSE)

SSE doesn't support custom headers via EventSource. Workarounds:

```javascript
// Option 1: Token in URL (less secure)
const token = getAccessToken();
const eventSource = new EventSource(`/events?token=${token}`);

// Option 2: Use fetch for initial connection, then stream
async function authenticatedSSE(url) {
  const response = await fetch(url, {
    headers: {
      'Authorization': `Bearer ${token}`,
      'Accept': 'text/event-stream'
    }
  });
  
  const reader = response.body.getReader();
  const decoder = new TextDecoder();
  
  while (true) {
    const { done, value } = await reader.read();
    if (done) break;
    
    const chunk = decoder.decode(value);
    // Process SSE data manually
  }
}
```

[Inference] The standard EventSource API limitation with headers is a known constraint. The fetch-based streaming approach provides header support but requires manual SSE parsing.

### Complete Production-Ready Pattern

```javascript
class AuthClient {
  constructor(config) {
    this.baseURL = config.baseURL;
    this.tokenManager = new TokenManager(config);
    this.maxRetries = config.maxRetries || 1;
  }
  
  async fetch(endpoint, options = {}) {
    const url = `${this.baseURL}${endpoint}`;
    
    for (let attempt = 0; attempt <= this.maxRetries; attempt++) {
      try {
        const token = await this.tokenManager.getValidToken();
        
        const response = await fetch(url, {
          ...options,
          headers: {
            ...options.headers,
            'Authorization': `Bearer ${token}`
          }
        });
        
        // Handle 401 with retry
        if (response.status === 401 && attempt < this.maxRetries) {
          await this.tokenManager.forceRefresh();
          continue;
        }
        
        // Handle other errors
        if (!response.ok) {
          throw new Error(`HTTP ${response.status}: ${response.statusText}`);
        }
        
        return response;
        
      } catch (error) {
        if (attempt === this.maxRetries) throw error;
      }
    }
  }
  
  async get(endpoint, options) {
    return this.fetch(endpoint, { ...options, method: 'GET' });
  }
  
  async post(endpoint, data, options) {
    return this.fetch(endpoint, {
      ...options,
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        ...options?.headers
      },
      body: JSON.stringify(data)
    });
  }
  
  async put(endpoint, data, options) {
    return this.fetch(endpoint, {
      ...options,
      method: 'PUT',
      headers: {
        'Content-Type': 'application/json',
        ...options?.headers
      },
      body: JSON.stringify(data)
    });
  }
  
  async delete(endpoint, options) {
    return this.fetch(endpoint, { ...options, method: 'DELETE' });
  }
}
```

---

