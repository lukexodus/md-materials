## Secure Headers


### Content Security Policy (CSP)

Content Security Policy restricts resource loading sources to prevent XSS attacks, clickjacking, and code injection. Configure CSP through headers returned by the server.

```javascript
const response = await fetch('/api/data', {
  method: 'POST',
  headers: {
    'Content-Security-Policy': "default-src 'self'; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline'; img-src 'self' data: https:; connect-src 'self' https://api.example.com"
  },
  body: JSON.stringify({ data })
});
```

CSP directives control specific resource types:

```javascript
const cspDirectives = {
  'default-src': "'self'",
  'script-src': "'self' 'unsafe-eval' https://cdn.example.com",
  'style-src': "'self' 'unsafe-inline' https://fonts.googleapis.com",
  'img-src': "'self' data: blob: https:",
  'font-src': "'self' https://fonts.gstatic.com",
  'connect-src': "'self' https://api.example.com wss://socket.example.com",
  'media-src': "'self' https://media.example.com",
  'object-src': "'none'",
  'frame-ancestors': "'none'",
  'base-uri': "'self'",
  'form-action': "'self'",
  'upgrade-insecure-requests': ''
};

const cspHeader = Object.entries(cspDirectives)
  .map(([key, value]) => `${key} ${value}`)
  .join('; ');
```

### Strict Transport Security (HSTS)

HSTS forces browsers to use HTTPS connections exclusively, preventing protocol downgrade attacks and cookie hijacking.

```javascript
// Server-side header configuration
const hstsHeader = 'max-age=31536000; includeSubDomains; preload';

// Client-side verification
const checkHSTS = (response) => {
  const hsts = response.headers.get('Strict-Transport-Security');
  if (!hsts) {
    console.warn('HSTS header missing');
    return false;
  }
  
  const hasMaxAge = /max-age=\d+/.test(hsts);
  const hasSubDomains = hsts.includes('includeSubDomains');
  const hasPreload = hsts.includes('preload');
  
  return { hasMaxAge, hasSubDomains, hasPreload };
};

const response = await fetch('https://api.example.com/data');
const hstsStatus = checkHSTS(response);
```

### X-Frame-Options

X-Frame-Options prevents clickjacking by controlling whether pages can be embedded in frames or iframes.

```javascript
// Three possible values:
// DENY - cannot be framed at all
// SAMEORIGIN - can only be framed by same origin
// ALLOW-FROM uri - can be framed by specific URI (deprecated)

const secureFetch = async (url, options = {}) => {
  const response = await fetch(url, options);
  
  const xFrameOptions = response.headers.get('X-Frame-Options');
  if (!xFrameOptions || xFrameOptions === 'ALLOW-FROM') {
    console.warn('Weak or missing X-Frame-Options header');
  }
  
  return response;
};
```

Modern alternative using CSP:

```javascript
const framingProtection = {
  'Content-Security-Policy': "frame-ancestors 'none'", // equivalent to DENY
  // or
  'Content-Security-Policy': "frame-ancestors 'self'", // equivalent to SAMEORIGIN
  // or
  'Content-Security-Policy': "frame-ancestors https://trusted.example.com"
};
```

### X-Content-Type-Options

X-Content-Type-Options prevents MIME type sniffing, forcing browsers to respect declared content types.

```javascript
const response = await fetch('/api/file', {
  headers: {
    'X-Content-Type-Options': 'nosniff'
  }
});

// Verify the header is present
const verifyNoSniff = (response) => {
  const noSniff = response.headers.get('X-Content-Type-Options');
  if (noSniff !== 'nosniff') {
    console.warn('X-Content-Type-Options not set to nosniff');
    return false;
  }
  return true;
};

verifyNoSniff(response);
```

### Referrer-Policy

Referrer-Policy controls how much referrer information is sent with requests, protecting user privacy and preventing information leakage.

```javascript
const referrerPolicies = [
  'no-referrer',                    // Never send referrer
  'no-referrer-when-downgrade',     // Default, no referrer on HTTPS->HTTP
  'origin',                         // Send only origin
  'origin-when-cross-origin',       // Full URL for same-origin, origin only for cross-origin
  'same-origin',                    // Send referrer for same-origin only
  'strict-origin',                  // Send origin, but not on HTTPS->HTTP
  'strict-origin-when-cross-origin', // Full URL same-origin, origin cross-origin, none on downgrade
  'unsafe-url'                      // Always send full URL (avoid this)
];

const response = await fetch('/api/data', {
  referrerPolicy: 'strict-origin-when-cross-origin'
});

// Or set via header
const response2 = await fetch('/api/data', {
  headers: {
    'Referrer-Policy': 'no-referrer'
  }
});
```

### Permissions-Policy

Permissions-Policy (formerly Feature-Policy) controls which browser features and APIs can be used.

```javascript
const permissionsPolicy = [
  'camera=()',                    // Disable camera
  'microphone=()',                // Disable microphone
  'geolocation=(self)',           // Allow geolocation for same-origin only
  'payment=(self "https://trusted.com")', // Allow payment for specific origins
  'usb=()',                       // Disable USB access
  'fullscreen=(self)',            // Allow fullscreen for same-origin
  'autoplay=()',                  // Disable autoplay
  'accelerometer=()',             // Disable accelerometer
  'gyroscope=()',                 // Disable gyroscope
  'magnetometer=()',              // Disable magnetometer
  'picture-in-picture=(self)'     // Allow PiP for same-origin
].join(', ');

// Server sets this header
// Client can verify it
const checkPermissionsPolicy = (response) => {
  const policy = response.headers.get('Permissions-Policy');
  return policy || 'No Permissions-Policy set';
};
```

### Cross-Origin-Embedder-Policy (COEP)

COEP prevents documents from loading cross-origin resources that don't explicitly grant permission.

```javascript
// require-corp: requires explicit CORP header from cross-origin resources
// credentialless: loads cross-origin resources without credentials
// unsafe-none: no enforcement (default)

const coepHeaders = {
  'Cross-Origin-Embedder-Policy': 'require-corp',
  'Cross-Origin-Resource-Policy': 'same-origin'
};

const response = await fetch('/api/resource', {
  headers: coepHeaders
});

// Verify COEP is enabled
const verifyCoep = (response) => {
  const coep = response.headers.get('Cross-Origin-Embedder-Policy');
  return coep === 'require-corp' || coep === 'credentialless';
};
```

### Cross-Origin-Opener-Policy (COOP)

COOP isolates browsing context groups, preventing cross-origin documents from interacting with popup windows.

```javascript
const coopValues = [
  'unsafe-none',           // Default, no isolation
  'same-origin',           // Isolates from cross-origin documents
  'same-origin-allow-popups' // Allows popups to stay in same group
];

const secureWindowOpen = async () => {
  // Fetch with COOP header
  const response = await fetch('/secure-page', {
    headers: {
      'Cross-Origin-Opener-Policy': 'same-origin'
    }
  });
  
  return response;
};

// Check if cross-origin isolation is enabled
const checkCrossOriginIsolation = () => {
  if (window.crossOriginIsolated) {
    console.log('Cross-origin isolation is active');
    // Can use SharedArrayBuffer and high-precision timers
    return true;
  }
  return false;
};
```

### Cross-Origin-Resource-Policy (CORP)

CORP protects resources from being loaded by cross-origin pages, preventing Spectre-style attacks.

```javascript
const corpValues = {
  'same-origin': 'same-origin',     // Only same-origin can load
  'same-site': 'same-site',         // Same-site can load
  'cross-origin': 'cross-origin'    // Anyone can load
};

const protectedResourceFetch = async (url) => {
  const response = await fetch(url, {
    headers: {
      'Cross-Origin-Resource-Policy': 'same-origin'
    }
  });
  
  const corp = response.headers.get('Cross-Origin-Resource-Policy');
  if (!corp) {
    console.warn('CORP header missing - resource may be vulnerable');
  }
  
  return response;
};
```

### Authorization Headers

Proper handling of authorization tokens in requests.

```javascript
// Bearer token authentication
const authenticatedFetch = async (url, token, options = {}) => {
  return fetch(url, {
    ...options,
    headers: {
      ...options.headers,
      'Authorization': `Bearer ${token}`,
      'Content-Type': 'application/json'
    }
  });
};

// Basic authentication (avoid in production, use OAuth/Bearer tokens)
const basicAuthFetch = async (url, username, password) => {
  const credentials = btoa(`${username}:${password}`);
  return fetch(url, {
    headers: {
      'Authorization': `Basic ${credentials}`
    }
  });
};

// API key authentication
const apiKeyFetch = async (url, apiKey) => {
  return fetch(url, {
    headers: {
      'X-API-Key': apiKey,
      // or
      'Authorization': `ApiKey ${apiKey}`
    }
  });
};
```

### Custom Security Headers

Application-specific security headers for additional protection.

```javascript
const customSecurityHeaders = {
  'X-Request-ID': crypto.randomUUID(),           // Request tracking
  'X-Correlation-ID': crypto.randomUUID(),       // Cross-service tracking
  'X-CSRF-Token': getCsrfToken(),                // CSRF protection
  'X-API-Version': '2.0',                        // API versioning
  'X-Client-ID': getClientId(),                  // Client identification
  'X-Request-Signature': generateSignature(),    // Request signing
  'X-Timestamp': Date.now().toString()           // Timestamp for replay protection
};

const secureRequest = async (url, data) => {
  return fetch(url, {
    method: 'POST',
    headers: {
      ...customSecurityHeaders,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify(data)
  });
};
```

### CSRF Token Handling

Cross-Site Request Forgery protection through token validation.

```javascript
// Retrieve CSRF token from meta tag or cookie
const getCsrfToken = () => {
  // From meta tag
  const metaToken = document.querySelector('meta[name="csrf-token"]')?.content;
  if (metaToken) return metaToken;
  
  // From cookie
  const cookieMatch = document.cookie.match(/XSRF-TOKEN=([^;]+)/);
  return cookieMatch ? decodeURIComponent(cookieMatch[1]) : null;
};

// Include CSRF token in requests
const csrfProtectedFetch = async (url, options = {}) => {
  const csrfToken = getCsrfToken();
  
  return fetch(url, {
    ...options,
    headers: {
      ...options.headers,
      'X-CSRF-Token': csrfToken,
      // Some frameworks use X-XSRF-Token instead
      'X-XSRF-Token': csrfToken
    },
    credentials: 'same-origin' // Required for cookie-based CSRF
  });
};

// Double-submit cookie pattern
const doubleSubmitFetch = async (url, options = {}) => {
  const token = getCsrfToken();
  
  return fetch(url, {
    ...options,
    headers: {
      ...options.headers,
      'X-CSRF-Token': token
    },
    credentials: 'include'
  });
};
```

### Rate Limiting Headers

Headers that communicate rate limit status to clients.

```javascript
const checkRateLimits = (response) => {
  return {
    limit: response.headers.get('X-RateLimit-Limit'),
    remaining: response.headers.get('X-RateLimit-Remaining'),
    reset: response.headers.get('X-RateLimit-Reset'),
    retryAfter: response.headers.get('Retry-After')
  };
};

const rateLimitAwareFetch = async (url, options = {}) => {
  const response = await fetch(url, options);
  
  if (response.status === 429) {
    const limits = checkRateLimits(response);
    const retryAfter = parseInt(limits.retryAfter || '60', 10);
    
    console.warn(`Rate limited. Retry after ${retryAfter} seconds`);
    
    // Wait and retry
    await new Promise(resolve => setTimeout(resolve, retryAfter * 1000));
    return rateLimitAwareFetch(url, options);
  }
  
  const limits = checkRateLimits(response);
  if (limits.remaining && parseInt(limits.remaining) < 10) {
    console.warn(`Low rate limit remaining: ${limits.remaining}`);
  }
  
  return response;
};
```

### Security Headers Validation

Comprehensive validation of security headers in responses.

```javascript
class SecurityHeaderValidator {
  constructor() {
    this.requiredHeaders = {
      'Strict-Transport-Security': /max-age=\d+/,
      'X-Content-Type-Options': /nosniff/,
      'X-Frame-Options': /DENY|SAMEORIGIN/,
      'Referrer-Policy': /.+/,
      'Content-Security-Policy': /.+/
    };
    
    this.recommendedHeaders = {
      'Permissions-Policy': /.+/,
      'Cross-Origin-Embedder-Policy': /require-corp|credentialless/,
      'Cross-Origin-Opener-Policy': /same-origin/,
      'Cross-Origin-Resource-Policy': /same-origin|same-site/
    };
  }
  
  validate(response) {
    const results = {
      passed: [],
      failed: [],
      missing: [],
      warnings: []
    };
    
    // Check required headers
    for (const [header, pattern] of Object.entries(this.requiredHeaders)) {
      const value = response.headers.get(header);
      
      if (!value) {
        results.failed.push({ header, reason: 'Missing' });
      } else if (!pattern.test(value)) {
        results.failed.push({ header, reason: 'Invalid value', value });
      } else {
        results.passed.push(header);
      }
    }
    
    // Check recommended headers
    for (const [header, pattern] of Object.entries(this.recommendedHeaders)) {
      const value = response.headers.get(header);
      
      if (!value) {
        results.warnings.push({ header, reason: 'Missing (recommended)' });
      } else if (!pattern.test(value)) {
        results.warnings.push({ header, reason: 'Weak value', value });
      } else {
        results.passed.push(header);
      }
    }
    
    return results;
  }
  
  report(results) {
    console.group('Security Headers Validation');
    
    if (results.passed.length > 0) {
      console.log('✓ Passed:', results.passed.join(', '));
    }
    
    if (results.failed.length > 0) {
      console.error('✗ Failed:');
      results.failed.forEach(f => 
        console.error(`  - ${f.header}: ${f.reason}`, f.value || '')
      );
    }
    
    if (results.warnings.length > 0) {
      console.warn('⚠ Warnings:');
      results.warnings.forEach(w => 
        console.warn(`  - ${w.header}: ${w.reason}`, w.value || '')
      );
    }
    
    console.groupEnd();
    
    return results.failed.length === 0;
  }
}

const validator = new SecurityHeaderValidator();
const response = await fetch('/api/data');
const results = validator.validate(response);
const isSecure = validator.report(results);
```

### Cache-Control Security

Cache-Control directives that affect security and privacy.

```javascript
const sensitiveDataFetch = async (url) => {
  return fetch(url, {
    headers: {
      'Cache-Control': 'no-store, no-cache, must-revalidate, private',
      'Pragma': 'no-cache',
      'Expires': '0'
    }
  });
};

// Different cache policies for different data types
const cacheStrategies = {
  sensitive: {
    'Cache-Control': 'no-store, no-cache, must-revalidate, private',
    'Pragma': 'no-cache'
  },
  
  authenticated: {
    'Cache-Control': 'private, max-age=0, must-revalidate'
  },
  
  public: {
    'Cache-Control': 'public, max-age=31536000, immutable'
  },
  
  api: {
    'Cache-Control': 'private, no-cache, no-store, must-revalidate'
  }
};

const fetchWithCachePolicy = async (url, dataType = 'sensitive') => {
  return fetch(url, {
    headers: cacheStrategies[dataType]
  });
};
```

### Request Signing

Cryptographic signing of requests for integrity and authentication.

```javascript
const signRequest = async (method, url, body, secretKey) => {
  const timestamp = Date.now().toString();
  const nonce = crypto.randomUUID();
  
  // Create signature payload
  const payload = [
    method,
    url,
    timestamp,
    nonce,
    body ? JSON.stringify(body) : ''
  ].join('\n');
  
  // Generate HMAC signature
  const encoder = new TextEncoder();
  const keyData = encoder.encode(secretKey);
  const messageData = encoder.encode(payload);
  
  const key = await crypto.subtle.importKey(
    'raw',
    keyData,
    { name: 'HMAC', hash: 'SHA-256' },
    false,
    ['sign']
  );
  
  const signature = await crypto.subtle.sign('HMAC', key, messageData);
  const signatureHex = Array.from(new Uint8Array(signature))
    .map(b => b.toString(16).padStart(2, '0'))
    .join('');
  
  return {
    signature: signatureHex,
    timestamp,
    nonce
  };
};

const signedFetch = async (url, options = {}, secretKey) => {
  const { signature, timestamp, nonce } = await signRequest(
    options.method || 'GET',
    url,
    options.body,
    secretKey
  );
  
  return fetch(url, {
    ...options,
    headers: {
      ...options.headers,
      'X-Signature': signature,
      'X-Timestamp': timestamp,
      'X-Nonce': nonce
    }
  });
};
```

### Origin Validation

Validating origin headers to prevent unauthorized cross-origin requests.

```javascript
const validateOrigin = (response, expectedOrigin) => {
  const origin = response.headers.get('Access-Control-Allow-Origin');
  const vary = response.headers.get('Vary');
  
  // Check if origin matches expected
  if (origin !== expectedOrigin && origin !== '*') {
    console.warn(`Unexpected origin: ${origin}`);
    return false;
  }
  
  // Ensure Vary header includes Origin for proper caching
  if (origin !== '*' && (!vary || !vary.includes('Origin'))) {
    console.warn('Vary header should include Origin');
  }
  
  return true;
};

const originAwareFetch = async (url, expectedOrigin) => {
  const response = await fetch(url, {
    headers: {
      'Origin': window.location.origin
    }
  });
  
  validateOrigin(response, expectedOrigin);
  return response;
};
```

### Security Header Middleware

Utility for consistently applying security headers to all fetch requests.

```javascript
class SecureFetchMiddleware {
  constructor(config = {}) {
    this.defaultHeaders = {
      'X-Content-Type-Options': 'nosniff',
      'X-Frame-Options': 'DENY',
      'Referrer-Policy': 'strict-origin-when-cross-origin',
      ...config.headers
    };
    
    this.csrfEnabled = config.csrf !== false;
    this.authToken = config.authToken;
    this.apiKey = config.apiKey;
  }
  
  async fetch(url, options = {}) {
    const headers = {
      ...this.defaultHeaders,
      ...options.headers
    };
    
    // Add CSRF token if enabled
    if (this.csrfEnabled) {
      const csrfToken = getCsrfToken();
      if (csrfToken) {
        headers['X-CSRF-Token'] = csrfToken;
      }
    }
    
    // Add authentication
    if (this.authToken) {
      headers['Authorization'] = `Bearer ${this.authToken}`;
    }
    
    if (this.apiKey) {
      headers['X-API-Key'] = this.apiKey;
    }
    
    // Add request ID for tracking
    headers['X-Request-ID'] = crypto.randomUUID();
    
    const response = await fetch(url, {
      ...options,
      headers
    });
    
    // Validate response headers
    this.validateResponse(response);
    
    return response;
  }
  
  validateResponse(response) {
    const requiredHeaders = [
      'X-Content-Type-Options',
      'X-Frame-Options'
    ];
    
    const missing = requiredHeaders.filter(
      header => !response.headers.get(header)
    );
    
    if (missing.length > 0) {
      console.warn('Missing security headers:', missing);
    }
  }
  
  setAuthToken(token) {
    this.authToken = token;
  }
  
  setApiKey(key) {
    this.apiKey = key;
  }
}

// Usage
const secureFetch = new SecureFetchMiddleware({
  csrf: true,
  authToken: 'your-jwt-token',
  headers: {
    'Custom-Security-Header': 'value'
  }
});

const response = await secureFetch.fetch('/api/data', {
  method: 'POST',
  body: JSON.stringify({ data: 'value' })
});
```

---

