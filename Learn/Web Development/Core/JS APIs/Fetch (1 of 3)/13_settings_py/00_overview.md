## Overview

CORS_ALLOWED_ORIGINS = [
    "https://app.example.com",
    "https://admin.example.com",
]

CORS_ALLOW_CREDENTIALS = True

CORS_ALLOW_METHODS = [
    'DELETE',
    'GET',
    'OPTIONS',
    'PATCH',
    'POST',
    'PUT',
]

CORS_ALLOW_HEADERS = [
    'accept',
    'authorization',
    'content-type',
    'x-csrf-token',
]

CORS_EXPOSE_HEADERS = [
    'x-total-count',
]

CORS_PREFLIGHT_MAX_AGE = 86400
```

### Security Considerations

**Never use wildcard with credentials:**

```javascript
// DANGEROUS - Browser will reject
res.setHeader('Access-Control-Allow-Origin', '*');
res.setHeader('Access-Control-Allow-Credentials', 'true');
```

**Validate origins from whitelist:**

```javascript
const ALLOWED_ORIGINS = [
  'https://app.example.com',
  'https://admin.example.com'
];

app.use((req, res, next) => {
  const origin = req.headers.origin;
  
  if (ALLOWED_ORIGINS.includes(origin)) {
    res.setHeader('Access-Control-Allow-Origin', origin);
  } else {
    // Log suspicious origins
    console.warn(`Blocked CORS request from: ${origin}`);
  }
  
  next();
});
```

**Avoid reflecting origin without validation:**

```javascript
// DANGEROUS - Allows any origin
res.setHeader('Access-Control-Allow-Origin', req.headers.origin);

// SAFE - Validate first
const origin = req.headers.origin;
if (isAllowedOrigin(origin)) {
  res.setHeader('Access-Control-Allow-Origin', origin);
}
```

**Limit exposed headers:**

```javascript
// Don't expose sensitive headers
res.setHeader('Access-Control-Expose-Headers', 'X-Total-Count, X-Page');
// Not: 'Set-Cookie, Authorization, X-API-Key'
```

**Minimize Max-Age in development:**

```javascript
const maxAge = process.env.NODE_ENV === 'production' ? 86400 : 600;
res.setHeader('Access-Control-Max-Age', maxAge);
```

### Common CORS Errors and Solutions

**Error: "No 'Access-Control-Allow-Origin' header"**

```javascript
// Solution: Add the header to response
res.setHeader('Access-Control-Allow-Origin', 'https://your-app.com');
```

**Error: "Credentials mode is 'include' but Access-Control-Allow-Origin is '*'"**

```javascript
// Solution: Use specific origin with credentials
res.setHeader('Access-Control-Allow-Origin', 'https://your-app.com');
res.setHeader('Access-Control-Allow-Credentials', 'true');
```

**Error: "Method X is not allowed by Access-Control-Allow-Methods"**

```javascript
// Solution: Add the method to allowed methods
res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, PATCH');
```

**Error: "Request header X is not allowed"**

```javascript
// Solution: Add header to Access-Control-Allow-Headers
res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization, X-Custom-Header');
```

**Error: Preflight request not handled**

```javascript
// Solution: Handle OPTIONS method
app.options('*', (req, res) => {
  res.setHeader('Access-Control-Allow-Origin', 'https://your-app.com');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
  res.sendStatus(204);
});
```

### Advanced Patterns

**Origin pattern matching:**

```javascript
function isAllowedOrigin(origin) {
  const allowedPatterns = [
    /^https:\/\/.*\.example\.com$/,  // All subdomains
    /^http:\/\/localhost:\d+$/,       // Localhost with any port
  ];
  
  return allowedPatterns.some(pattern => pattern.test(origin));
}

app.use((req, res, next) => {
  const origin = req.headers.origin;
  if (origin && isAllowedOrigin(origin)) {
    res.setHeader('Access-Control-Allow-Origin', origin);
  }
  next();
});
```

**Per-route CORS configuration:**

```javascript
const strictCors = (req, res, next) => {
  res.setHeader('Access-Control-Allow-Origin', 'https://trusted.example.com');
  res.setHeader('Access-Control-Allow-Credentials', 'true');
  next();
};

const publicCors = (req, res, next) => {
  res.setHeader('Access-Control-Allow-Origin', '*');
  next();
};

app.get('/api/public', publicCors, getPublicData);
app.get('/api/private', strictCors, getPrivateData);
```

**Conditional credentials:**

```javascript
app.use((req, res, next) => {
  const origin = req.headers.origin;
  
  if (trustedOrigins.includes(origin)) {
    res.setHeader('Access-Control-Allow-Origin', origin);
    res.setHeader('Access-Control-Allow-Credentials', 'true');
  } else if (publicOrigins.includes(origin)) {
    res.setHeader('Access-Control-Allow-Origin', origin);
    // No credentials
  }
  
  next();
});
```

**Vary header for caching:**

```javascript
app.use((req, res, next) => {
  // Indicate that response varies by Origin header
  res.setHeader('Vary', 'Origin');
  
  const origin = req.headers.origin;
  if (allowedOrigins.includes(origin)) {
    res.setHeader('Access-Control-Allow-Origin', origin);
  }
  
  next();
});
```

### Testing CORS Configuration

**Using curl:**

```bash
