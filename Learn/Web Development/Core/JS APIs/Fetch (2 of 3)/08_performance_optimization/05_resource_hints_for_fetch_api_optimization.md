## Resource Hints for Fetch API Optimization


### DNS Prefetch

DNS prefetch resolves domain names before resources are requested, reducing DNS lookup latency.

```html
<link rel="dns-prefetch" href="https://api.example.com">
```

When the browser encounters this hint, it performs DNS resolution in the background. Later fetch requests to that domain skip the DNS lookup phase.

**Impact on fetch timing:**

- Eliminates DNS lookup time (typically 20-120ms)
- Only affects the first request to a domain
- Subsequent requests use the cached DNS result

**Best practices:**

- Apply to domains used in fetch calls but not referenced in initial HTML
- Most beneficial for third-party API domains
- Low overhead—browsers queue these efficiently

**Limitations:**

- Does not establish TCP connections
- Does not perform TLS handshakes
- Only resolves DNS

### Preconnect

Preconnect performs DNS resolution, TCP handshake, and TLS negotiation before resources are requested.

```html
<link rel="preconnect" href="https://api.example.com">
<link rel="preconnect" href="https://api.example.com" crossorigin>
```

**Connection establishment stages:**

1. DNS resolution
2. TCP connection (SYN, SYN-ACK, ACK)
3. TLS handshake (for HTTPS)

**The `crossorigin` attribute:**

Without `crossorigin`: Opens a connection for same-origin or no-credentials requests.

With `crossorigin`: Opens a connection that includes credentials (cookies, auth headers). Required when fetch requests use `credentials: 'include'` or `credentials: 'same-origin'` (for cross-origin requests).

```javascript
// This fetch requires crossorigin preconnect
fetch('https://api.example.com/data', {
  credentials: 'include'
});
```

**Impact on fetch timing:**

- Eliminates connection setup time (typically 100-500ms for HTTPS)
- Most impactful for first request to a domain
- Connections remain open for reuse (HTTP keep-alive)

**Resource considerations:**

- Each preconnect consumes a socket
- Browsers limit concurrent connections per domain (typically 6)
- Unused connections time out (typically 60-120 seconds)
- More expensive than dns-prefetch

**Best practices:**

- Limit to 4-6 critical domains maximum
- Use for domains where fetch requests are highly likely (>80% probability)
- Prefer for API endpoints called during initial page load
- Consider removing hints for domains that become less critical

**Comparison to dns-prefetch:**

|Metric|dns-prefetch|preconnect|
|---|---|---|
|DNS resolution|✓|✓|
|TCP connection|✗|✓|
|TLS handshake|✗|✓|
|Resource cost|Low|Medium|
|Time saved|20-120ms|100-500ms|

### Prefetch

Prefetch downloads resources during idle time, storing them in HTTP cache for future use.

```html
<link rel="prefetch" href="https://api.example.com/data.json">
<link rel="prefetch" href="https://api.example.com/data.json" as="fetch" crossorigin>
```

**Behavior characteristics:**

- Lowest priority fetch (below all active requests)
- Executes during browser idle time
- Subject to HTTP caching rules
- Does not execute JavaScript or process responses beyond caching

**The `as` attribute:**

Specifies resource type, affecting caching and request headers:

```html
<link rel="prefetch" href="/api/user" as="fetch">
<link rel="prefetch" href="/data.json" as="fetch">
<link rel="prefetch" href="/image.jpg" as="image">
```

When `as="fetch"`, the browser:

- Uses appropriate `Accept` headers
- Respects CORS policies
- Caches according to HTTP headers

**Interaction with Cache API:**

Prefetched resources go into HTTP cache, not Cache API. To use Cache API:

```javascript
// Manual prefetch into Cache API
if ('serviceWorker' in navigator && 'caches' in window) {
  caches.open('api-cache-v1').then(cache => {
    cache.add('/api/data');
  });
}
```

**When prefetch helps fetch calls:**

1. **Navigation prefetch**: User likely to navigate to a page that fetches data

```html
<!-- On page A, prefetch data needed by page B -->
<link rel="prefetch" href="/api/profile">
```

2. **Deferred feature prefetch**: Feature will be used but not immediately

```html
<!-- Prefetch data for modal opened on user action -->
<link rel="prefetch" href="/api/product-details">
```

3. **Predictive prefetch**: Analytics indicate high probability of request

```javascript
// Add prefetch hint dynamically based on user behavior
const link = document.createElement('link');
link.rel = 'prefetch';
link.href = '/api/recommended-products';
link.as = 'fetch';
document.head.appendChild(link);
```

**Cache matching:**

When fetch executes, the browser checks:

1. Memory cache
2. HTTP disk cache (where prefetch stores data)
3. Service Worker cache (if intercepted)

The request must match:

- URL (exactly)
- HTTP method (prefetch uses GET)
- CORS mode
- Credentials mode

**Mismatch scenarios:**

```javascript
// Prefetch executed
// <link rel="prefetch" href="/api/data">

// This matches - uses cache
fetch('/api/data');

// This doesn't match - makes new request
fetch('/api/data', { method: 'POST' });

// This doesn't match - makes new request
fetch('/api/data', { credentials: 'include' });
```

**Best practices:**

- Use for resources with >50% probability of use
- Verify cache headers allow caching (check `Cache-Control`)
- Monitor actual cache hit rates
- Consider data transfer costs (mobile networks)
- Avoid prefetching authenticated endpoints without careful consideration

**Cache validation:**

Prefetched resources still respect cache validation:

```http
Cache-Control: max-age=3600, must-revalidate
ETag: "abc123"
```

Future fetch may trigger conditional request:

```http
If-None-Match: "abc123"
```

Server responds `304 Not Modified` (cache hit) or `200 OK` (cache miss).

### Combining Hints

Hints work in sequence based on resource needs:

**Pattern 1: Connect then prefetch**

```html
<!-- Establish connection first -->
<link rel="preconnect" href="https://api.example.com">
<!-- Then prefetch specific resource -->
<link rel="prefetch" href="https://api.example.com/data.json" as="fetch">
```

[Inference] The connection established by preconnect may be reused by prefetch, though timing depends on when the browser schedules the prefetch operation.

**Pattern 2: Progressive hints**

```html
<!-- For domains where you'll definitely fetch -->
<link rel="preconnect" href="https://critical-api.com" crossorigin>

<!-- For domains you might fetch from -->
<link rel="dns-prefetch" href="https://possible-api.com">

<!-- For specific resources likely needed next -->
<link rel="prefetch" href="https://critical-api.com/next-page-data" as="fetch">
```

**Pattern 3: Conditional prefetch after connection**

```javascript
// Establish connection early
const preconnect = document.createElement('link');
preconnect.rel = 'preconnect';
preconnect.href = 'https://api.example.com';
document.head.appendChild(preconnect);

// Later, based on user behavior, prefetch data
if (userLikelyToNeedData) {
  const prefetch = document.createElement('link');
  prefetch.rel = 'prefetch';
  prefetch.href = 'https://api.example.com/data';
  prefetch.as = 'fetch';
  document.head.appendChild(prefetch);
}
```

### Dynamic Hint Management

Add hints programmatically based on runtime conditions:

```javascript
function addResourceHint(rel, href, options = {}) {
  const link = document.createElement('link');
  link.rel = rel;
  link.href = href;
  
  if (options.as) link.as = options.as;
  if (options.crossorigin) link.crossOrigin = options.crossorigin;
  
  document.head.appendChild(link);
  return link;
}

// Usage
addResourceHint('preconnect', 'https://api.example.com', { 
  crossorigin: 'anonymous' 
});

addResourceHint('prefetch', '/api/next-data', { 
  as: 'fetch' 
});
```

**Removing hints:**

```javascript
// Remove hint when no longer needed
const link = document.querySelector('link[rel="preconnect"][href="https://api.example.com"]');
if (link) {
  link.remove();
}
```

[Inference] Removing a preconnect hint does not immediately close the connection; the browser manages connection lifecycle independently. Removing hints primarily prevents new connections from being opened.

**Intersection Observer pattern:**

Prefetch when user scrolls near content:

```javascript
const observer = new IntersectionObserver((entries) => {
  entries.forEach(entry => {
    if (entry.isIntersecting) {
      const url = entry.target.dataset.prefetchUrl;
      addResourceHint('prefetch', url, { as: 'fetch' });
      observer.unobserve(entry.target);
    }
  });
}, { rootMargin: '200px' });

// Observe elements that will need data
document.querySelectorAll('[data-prefetch-url]').forEach(el => {
  observer.observe(el);
});
```

### Priority Hints

Control fetch priority relative to other resources:

```html
<link rel="prefetch" href="/api/data" fetchpriority="low">
```

```javascript
fetch('/api/critical-data', {
  priority: 'high'
});

fetch('/api/background-data', {
  priority: 'low'
});
```

**Priority values:**

- `high`: Fetch before most other resources
- `low`: Fetch after more critical resources
- `auto`: Browser determines priority (default)

[Unverified] The exact prioritization algorithm and how priority values affect request scheduling varies by browser implementation and may depend on connection availability, current page state, and other factors.

**Prefetch always has low priority**, but `fetchpriority` can adjust within that constraint:

```html
<!-- Even lower priority prefetch -->
<link rel="prefetch" href="/api/data" fetchpriority="low">
```

### Monitoring and Debugging

**Performance Timeline API:**

```javascript
// Observe resource timing
const observer = new PerformanceObserver((list) => {
  list.getEntries().forEach(entry => {
    if (entry.initiatorType === 'fetch') {
      console.log('Fetch timing:', {
        name: entry.name,
        duration: entry.duration,
        dnsTime: entry.domainLookupEnd - entry.domainLookupStart,
        tcpTime: entry.connectEnd - entry.connectStart,
        tlsTime: entry.requestStart - entry.secureConnectionStart,
        waitTime: entry.responseStart - entry.requestStart,
        downloadTime: entry.responseEnd - entry.responseStart
      });
    }
  });
});

observer.observe({ entryTypes: ['resource'] });
```

**Checking cache hits:**

```javascript
fetch('/api/data')
  .then(response => {
    // Check if response came from cache
    const cacheHeader = response.headers.get('age');
    const fromCache = cacheHeader !== null;
    console.log('From cache:', fromCache);
    return response.json();
  });
```

[Inference] The presence of an `Age` header suggests the response came from cache, though this detection method depends on server configuration and may not work in all scenarios.

**Chrome DevTools:**

Network panel shows:

- Prefetch requests marked with "Prefetch" type
- Connection timing breakdown
- Whether DNS/connection was reused
- Cache status (from memory/disk cache)

**Resource Timing breakdown:**

```javascript
performance.getEntriesByType('resource')
  .filter(entry => entry.initiatorType === 'fetch')
  .forEach(entry => {
    const metrics = {
      dns: entry.domainLookupEnd - entry.domainLookupStart,
      tcp: entry.connectEnd - entry.connectStart,
      tls: entry.connectEnd - entry.secureConnectionStart,
      ttfb: entry.responseStart - entry.requestStart,
      download: entry.responseEnd - entry.responseStart,
      total: entry.duration
    };
    
    // Zero DNS/TCP time indicates connection reuse
    if (metrics.dns === 0 && metrics.tcp === 0) {
      console.log('Connection reused for', entry.name);
    }
  });
```

### Security and Privacy Considerations

**CORS requirements:**

Preconnect with credentials requires CORS:

```html
<!-- Requires CORS headers when used -->
<link rel="preconnect" href="https://api.example.com" crossorigin>
```

Server must send:

```http
Access-Control-Allow-Origin: https://your-site.com
Access-Control-Allow-Credentials: true
```

**Privacy implications:**

[Inference] Resource hints may leak information about user navigation intent:

- Prefetch hints reveal expected navigation paths
- DNS prefetch indicates domains user might visit
- Preconnect shows likely future interactions

Some browsers may limit or disable hints in private browsing mode.

**CSP (Content Security Policy):**

Resource hints must comply with CSP directives:

```http
Content-Security-Policy: connect-src 'self' https://api.example.com
```

Preconnect or fetch to other origins will be blocked.

**Timing attacks:**

[Speculation] Prefetch timing could theoretically reveal information about cache state or network topology to malicious scripts, though browsers implement mitigations to reduce timing precision.

### Browser Support and Fallbacks

**Feature detection:**

```javascript
function supportsResourceHint(rel) {
  const link = document.createElement('link');
  return link.relList && link.relList.supports(rel);
}

if (supportsResourceHint('preconnect')) {
  addResourceHint('preconnect', 'https://api.example.com');
} else if (supportsResourceHint('dns-prefetch')) {
  addResourceHint('dns-prefetch', 'https://api.example.com');
}
```

**Graceful degradation:**

Hints are performance optimizations—fetch works without them:

```html
<!-- Enhancement, not requirement -->
<link rel="preconnect" href="https://api.example.com">

<script>
  // Works regardless of hint support
  fetch('https://api.example.com/data')
    .then(response => response.json());
</script>
```

**Cross-browser considerations:**

[Unverified] Different browsers may implement resource hint prioritization, timing, and resource limits differently. Test performance in target browsers to verify benefits.

Safari has historically had more limited support for some hints compared to Chrome/Firefox.

---

