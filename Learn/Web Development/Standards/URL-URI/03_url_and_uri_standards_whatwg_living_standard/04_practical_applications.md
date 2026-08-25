## Practical Applications


### Web Development

**Link construction:**

```javascript
function buildProductURL(baseURL, productId, filters) {
  const url = new URL(`/products/${productId}`, baseURL);
  Object.entries(filters).forEach(([key, value]) => {
    url.searchParams.set(key, value);
  });
  return url.href;
}

// Usage
buildProductURL('https://shop.example.com', '12345', {
  color: 'blue',
  size: 'large'
});
// Result: https://shop.example.com/products/12345?color=blue&size=large
```

**URL manipulation:**

```javascript
function addTrackingParams(urlString, campaign) {
  const url = new URL(urlString);
  url.searchParams.set('utm_source', campaign.source);
  url.searchParams.set('utm_medium', campaign.medium);
  url.searchParams.set('utm_campaign', campaign.name);
  return url.href;
}
```

### Security Considerations

**URL validation for open redirects:**

```javascript
function isSafeRedirect(redirectURL, allowedHosts) {
  try {
    const url = new URL(redirectURL, window.location.origin);
    return allowedHosts.includes(url.hostname);
  } catch {
    return false;
  }
}
```

**Sanitizing user input:**

```javascript
function sanitizeURL(userInput) {
  try {
    const url = new URL(userInput);
    // Only allow http and https
    if (!['http:', 'https:'].includes(url.protocol)) {
      throw new Error('Invalid protocol');
    }
    return url.href;
  } catch {
    throw new Error('Invalid URL');
  }
}
```

### Server-Side Processing

**Request routing:**

```javascript
// Node.js example
const { URL } = require('url');

function routeRequest(request) {
  const url = new URL(request.url, `http://${request.headers.host}`);
  
  // Extract components for routing
  const path = url.pathname;
  const queryParams = Object.fromEntries(url.searchParams);
  
  return { path, queryParams };
}
```

