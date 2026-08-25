## Referrer and ReferrerPolicy


### Referrer Header Mechanics

#### Default Referrer Behavior

When making fetch requests, browsers automatically include a `Referer` header (note the historical misspelling) containing the URL of the page making the request. This allows servers to track navigation patterns and implement security measures.

```javascript
// Default behavior - browser sends current page URL as referrer
fetch('https://api.example.com/data')
  .then(response => response.json());
// Referer header: https://yoursite.com/page
```

#### Custom Referrer Values

The `referrer` option explicitly controls what referrer information is sent:

```javascript
// Send specific URL as referrer
fetch('https://api.example.com/data', {
  referrer: 'https://custom-referrer.com/source'
});

// Send no referrer
fetch('https://api.example.com/data', {
  referrer: ''
});

// Use client/document (default browser behavior)
fetch('https://api.example.com/data', {
  referrer: 'about:client'
});
```

Accepted values:

- Empty string `''`: Omit the Referer header entirely
- `'about:client'`: Use the default referrer (current page URL)
- Absolute URL string: Send specific URL as referrer (must be same-origin or fail)

### ReferrerPolicy Configuration

#### Policy Directives

The `referrerPolicy` option controls how much referrer information is sent under different conditions:

```javascript
// Strict: never send referrer
fetch('https://api.example.com/data', {
  referrerPolicy: 'no-referrer'
});

// Send full URL for same-origin, nothing for cross-origin
fetch('https://api.example.com/data', {
  referrerPolicy: 'same-origin'
});

// Send origin only (no path/query) for cross-origin
fetch('https://api.example.com/data', {
  referrerPolicy: 'strict-origin'
});
```

#### Complete Policy Options

**`no-referrer`** Never send referrer information under any circumstances.

```javascript
fetch('/api/sensitive', { referrerPolicy: 'no-referrer' });
// Referer header: (not sent)
```

**`no-referrer-when-downgrade`** (default) Send full referrer to same or more secure destinations (HTTPS→HTTPS, HTTP→HTTP, HTTP→HTTPS), but not when downgrading security (HTTPS→HTTP).

```javascript
// From https://site.com/page
fetch('https://api.example.com/data', { 
  referrerPolicy: 'no-referrer-when-downgrade' 
});
// Referer: https://site.com/page

fetch('http://api.example.com/data', { 
  referrerPolicy: 'no-referrer-when-downgrade' 
});
// Referer: (not sent - downgrade from HTTPS to HTTP)
```

**`origin`** Send only the origin (protocol, domain, port), stripping path and query parameters.

```javascript
// From https://site.com/admin/users?id=123
fetch('https://api.example.com/data', { 
  referrerPolicy: 'origin' 
});
// Referer: https://site.com
```

**`origin-when-cross-origin`** Send full URL for same-origin requests, but only origin for cross-origin requests.

```javascript
// From https://site.com/page/detail
fetch('https://site.com/api/data', { 
  referrerPolicy: 'origin-when-cross-origin' 
});
// Referer: https://site.com/page/detail

fetch('https://other.com/api/data', { 
  referrerPolicy: 'origin-when-cross-origin' 
});
// Referer: https://site.com
```

**`same-origin`** Send full referrer for same-origin requests, no referrer for cross-origin.

```javascript
// From https://site.com/page
fetch('https://site.com/api/data', { 
  referrerPolicy: 'same-origin' 
});
// Referer: https://site.com/page

fetch('https://other.com/api/data', { 
  referrerPolicy: 'same-origin' 
});
// Referer: (not sent)
```

**`strict-origin`** Send only origin to same-or-more-secure destinations, nothing when downgrading.

```javascript
// From https://site.com/admin
fetch('https://api.example.com/data', { 
  referrerPolicy: 'strict-origin' 
});
// Referer: https://site.com

fetch('http://api.example.com/data', { 
  referrerPolicy: 'strict-origin' 
});
// Referer: (not sent - downgrade)
```

**`strict-origin-when-cross-origin`** Send full URL for same-origin, only origin for cross-origin to same-or-more-secure destinations, nothing when downgrading.

```javascript
// From https://site.com/page
fetch('https://site.com/api/data', { 
  referrerPolicy: 'strict-origin-when-cross-origin' 
});
// Referer: https://site.com/page

fetch('https://other.com/api/data', { 
  referrerPolicy: 'strict-origin-when-cross-origin' 
});
// Referer: https://site.com

fetch('http://other.com/api/data', { 
  referrerPolicy: 'strict-origin-when-cross-origin' 
});
// Referer: (not sent - downgrade)
```

**`unsafe-url`** Always send the full URL as referrer, regardless of security. [Unverified: This exposes potentially sensitive URL information in all contexts].

```javascript
// From https://site.com/user/profile?token=secret
fetch('http://third-party.com/tracking', { 
  referrerPolicy: 'unsafe-url' 
});
// Referer: https://site.com/user/profile?token=secret
// Warning: Exposes query parameters even on downgrade
```

### Policy Hierarchy and Precedence

#### Multiple Policy Sources

Referrer policies can be set at multiple levels with specific precedence:

1. Fetch request `referrerPolicy` option (highest priority)
2. `<meta name="referrer">` tag
3. `Referrer-Policy` HTTP response header
4. Browser default (usually `no-referrer-when-downgrade`)

```javascript
// Request-level policy overrides all others
fetch('/api/data', { 
  referrerPolicy: 'no-referrer' 
});
// Uses no-referrer regardless of meta tag or headers
```

#### Document-Level Policies

```html
<!-- Set default for all requests from this page -->
<meta name="referrer" content="strict-origin-when-cross-origin">
```

```javascript
// This request inherits the meta tag policy
fetch('/api/data');

// This request overrides it
fetch('/api/sensitive', { referrerPolicy: 'no-referrer' });
```

### Security Considerations

#### Privacy Protection Patterns

Preventing referrer leakage for sensitive URLs:

```javascript
// Admin panel requests - hide referrer completely
fetch('/api/admin/users', {
  referrerPolicy: 'no-referrer',
  credentials: 'include'
});

// Public API with sensitive query params
const url = new URL('/search', window.location.origin);
url.searchParams.set('query', sensitiveSearchTerm);

fetch(url, {
  referrerPolicy: 'origin' // Strip query params from referrer
});
```

#### Third-Party API Integration

Controlling information exposure to external services:

```javascript
// Analytics or tracking - minimal exposure
fetch('https://analytics.third-party.com/event', {
  method: 'POST',
  referrerPolicy: 'strict-origin', // Only send domain, not path
  body: JSON.stringify({ event: 'page_view' })
});

// Payment processor - no referrer leakage
fetch('https://payment-gateway.com/checkout', {
  method: 'POST',
  referrerPolicy: 'no-referrer',
  body: JSON.stringify(paymentData)
});
```

#### HTTPS to HTTP Downgrade Protection

[Inference: Browsers typically block or warn about HTTPS→HTTP downgrades]:

```javascript
// From HTTPS page
fetch('http://insecure-api.com/data', {
  referrerPolicy: 'strict-origin'
});
// Referer: (not sent due to downgrade protection)

// Explicitly allow (not recommended)
fetch('http://insecure-api.com/data', {
  referrerPolicy: 'unsafe-url'
});
// Referer: https://yoursite.com/page (sent despite downgrade)
```

### Cross-Origin Resource Sharing (CORS) Interaction

#### Preflight Request Referrers

CORS preflight OPTIONS requests include referrer information based on the specified policy:

```javascript
fetch('https://api.other-domain.com/data', {
  method: 'POST',
  referrerPolicy: 'origin',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({ data: 'value' })
});
// Preflight OPTIONS request:
// Referer: https://yoursite.com

// Actual POST request:
// Referer: https://yoursite.com
```

#### Conditional Referrer for CORS

Adjusting referrer policy based on destination:

```javascript
function fetchWithAdaptiveReferrer(url, options = {}) {
  const targetOrigin = new URL(url).origin;
  const currentOrigin = window.location.origin;
  
  const referrerPolicy = targetOrigin === currentOrigin
    ? 'same-origin'  // Full referrer for same-origin
    : 'strict-origin'; // Origin only for cross-origin
  
  return fetch(url, {
    ...options,
    referrerPolicy
  });
}

fetchWithAdaptiveReferrer('https://api.example.com/data');
```

### Debugging and Inspection

#### Verifying Sent Referrers

Inspect actual referrer headers in browser DevTools:

```javascript
// Server endpoint to echo headers back
fetch('/api/echo-headers', {
  referrerPolicy: 'strict-origin'
})
  .then(r => r.json())
  .then(headers => {
    console.log('Referer sent:', headers.referer);
  });
```

#### Testing Different Policies

Utility function for testing policy effects:

```javascript
async function testReferrerPolicy(url, policy) {
  const response = await fetch(url, {
    referrerPolicy: policy,
    method: 'GET'
  });
  
  // Some APIs echo back the received headers
  const headers = await response.json();
  console.log(`Policy: ${policy}`);
  console.log(`Referrer received by server: ${headers.referer || '(none)'}`);
  console.log(`Current page: ${window.location.href}`);
  console.log('---');
}

// Test suite
const policies = [
  'no-referrer',
  'origin',
  'strict-origin',
  'strict-origin-when-cross-origin'
];

policies.forEach(policy => 
  testReferrerPolicy('https://httpbin.org/headers', policy)
);
```

### Common Patterns and Use Cases

#### API Key Protection

Preventing API keys in URLs from leaking via referrer:

```javascript
// Bad: API key in URL could leak via referrer
const badUrl = 'https://api.service.com/data?key=secret123';
fetch(badUrl);
// Potential leak if referrer is sent elsewhere

// Good: Use headers + strict referrer policy
fetch('https://api.service.com/data', {
  referrerPolicy: 'no-referrer',
  headers: {
    'Authorization': 'Bearer secret123'
  }
});
```

#### Single Page Application (SPA) Navigation

Managing referrers during client-side routing:

```javascript
// SPA route change handler
function navigateToRoute(path, apiEndpoint) {
  // Update URL without page reload
  window.history.pushState({}, '', path);
  
  // Fetch data with appropriate referrer
  fetch(apiEndpoint, {
    // Use origin-when-cross-origin to send full URL to same-origin
    // but only origin to external APIs
    referrerPolicy: 'origin-when-cross-origin'
  })
    .then(r => r.json())
    .then(data => updateView(data));
}
```

#### Progressive Enhancement

Fallback for browsers without referrerPolicy support:

```javascript
function safeFetch(url, options = {}) {
  const fetchOptions = { ...options };
  
  // Check if referrerPolicy is supported
  if ('referrerPolicy' in new Request('')) {
    fetchOptions.referrerPolicy = 'strict-origin-when-cross-origin';
  } else {
    // [Inference: Fallback behavior for older browsers]
    // Older browsers may not support referrerPolicy option
    console.warn('referrerPolicy not supported, using browser default');
  }
  
  return fetch(url, fetchOptions);
}
```

#### Content Delivery Networks (CDN)

Optimizing referrer for CDN requests:

```javascript
// Image or asset loading from CDN
fetch('https://cdn.example.com/images/photo.jpg', {
  referrerPolicy: 'no-referrer' // CDN doesn't need referrer info
})
  .then(r => r.blob())
  .then(blob => {
    const img = document.createElement('img');
    img.src = URL.createObjectURL(blob);
    document.body.appendChild(img);
  });
```

### Performance Implications

#### Reduced Header Size

Using restrictive referrer policies can reduce request header size:

```javascript
// Full URL referrer (larger header)
// From: https://example.com/very/long/path/to/page?with=many&query=parameters
fetch('/api/data', { referrerPolicy: 'unsafe-url' });
// Referer: https://example.com/very/long/path/to/page?with=many&query=parameters

// Origin only (smaller header)
fetch('/api/data', { referrerPolicy: 'origin' });
// Referer: https://example.com
```

#### Caching Considerations

[Inference: Referrer headers may affect caching behavior]:

```javascript
// Different referrers might trigger separate cache entries
// Using consistent referrer policy aids caching

fetch('/api/public-data', {
  referrerPolicy: 'no-referrer', // Consistent across all requests
  cache: 'default'
});
```

### Framework-Specific Integration

#### Setting Global Defaults

Wrapper for consistent referrer policy across application:

```javascript
// API client with default policy
class APIClient {
  constructor(baseURL, defaultPolicy = 'strict-origin-when-cross-origin') {
    this.baseURL = baseURL;
    this.defaultPolicy = defaultPolicy;
  }
  
  fetch(endpoint, options = {}) {
    return fetch(`${this.baseURL}${endpoint}`, {
      referrerPolicy: this.defaultPolicy,
      ...options,
      // Allow override if explicitly set
      ...(options.referrerPolicy && { 
        referrerPolicy: options.referrerPolicy 
      })
    });
  }
}

const api = new APIClient('https://api.example.com');
api.fetch('/users'); // Uses default policy
api.fetch('/sensitive', { 
  referrerPolicy: 'no-referrer' 
}); // Override for sensitive endpoint
```

#### Middleware Pattern

Intercepting and modifying referrer policies:

```javascript
function createFetchWithReferrerMiddleware(policyFn) {
  return function enhancedFetch(url, options = {}) {
    const policy = policyFn(url, options);
    return fetch(url, {
      ...options,
      referrerPolicy: policy
    });
  };
}

// Dynamic policy based on URL
const smartFetch = createFetchWithReferrerMiddleware((url) => {
  const urlObj = new URL(url, window.location.origin);
  
  if (urlObj.pathname.includes('/admin/')) {
    return 'no-referrer';
  }
  if (urlObj.origin === window.location.origin) {
    return 'same-origin';
  }
  return 'strict-origin';
});

smartFetch('/admin/users'); // no-referrer
smartFetch('/api/public'); // same-origin
smartFetch('https://external.com/data'); // strict-origin
```

---

