## Stale-While-Revalidate


### HTTP Cache-Control Directive

`stale-while-revalidate` is a Cache-Control extension that allows serving stale cached responses while asynchronously fetching fresh content in the background. It accepts a duration in seconds during which stale content remains servable after expiration.

```http
Cache-Control: max-age=3600, stale-while-revalidate=86400
```

This header instructs the browser:

- Serve cached response for 3600 seconds (1 hour) as fresh
- After expiration, serve stale cached response for up to 86400 seconds (24 hours) additional while revalidating
- During revalidation window, update cache in background without blocking the response

### Operational Timeline

```
Time 0s:           Response cached with max-age=3600, swr=86400
Time 0-3600s:      Cache is fresh, served directly
Time 3600s:        Cache expires, enters stale period
Time 3601-90000s:  Stale response served immediately + background fetch initiated
Time 90000s+:      Cache fully expired, must revalidate before serving
```

### Background Revalidation Mechanism

When a request hits during the stale window:

1. Browser immediately returns the stale cached response
2. Browser simultaneously initiates a background fetch to the origin
3. Background fetch updates the cache when complete
4. Subsequent requests receive the updated content

```javascript
// Request at time=4000s (past max-age, within swr window)
fetch('/api/data')
  .then(response => response.json())
  .then(data => {
    // Receives stale data immediately
    // Browser fetches fresh data in background
  });

// Next request receives updated content (if background fetch completed)
```

[Inference] The background revalidation is best-effort; if the background fetch fails, the stale content continues to be served until the stale-while-revalidate window expires.

### Combining with Other Directives

#### With must-revalidate

```http
Cache-Control: max-age=3600, stale-while-revalidate=86400, must-revalidate
```

`must-revalidate` takes precedence after max-age expires, preventing stale content from being served. The combination is contradictory and typically results in `must-revalidate` overriding `stale-while-revalidate`. [Inference] Browser behavior may vary, but most implementations honor `must-revalidate`.

#### With stale-if-error

```http
Cache-Control: max-age=3600, stale-while-revalidate=86400, stale-if-error=604800
```

These directives work together:

- `stale-while-revalidate`: Serves stale content while revalidating successfully
- `stale-if-error`: Serves stale content when revalidation fails (network error, 5xx status)

The `stale-if-error` window typically extends beyond `stale-while-revalidate` for fallback coverage.

#### With immutable

```http
Cache-Control: max-age=31536000, immutable, stale-while-revalidate=86400
```

`immutable` indicates the resource never changes during its freshness lifetime. Adding `stale-while-revalidate` is redundant since immutable resources shouldn't require revalidation. [Inference] Browsers likely ignore `stale-while-revalidate` when `immutable` is present.

#### With no-cache

```http
Cache-Control: no-cache, stale-while-revalidate=86400
```

`no-cache` requires validation before serving any cached response, making `stale-while-revalidate` ineffective. The directives conflict fundamentally.

### Browser Support and Implementation

#### Current Support

Modern browsers (Chrome 75+, Firefox 68+, Edge 79+, Safari 15.4+) support `stale-while-revalidate`. Older browsers ignore the directive and follow standard cache behavior.

```javascript
// Feature detection (indirect)
// No direct API to detect stale-while-revalidate support
// Observe timing to infer behavior [Unverified approach]
```

#### Service Worker Interaction

Service Workers can intercept requests and implement custom stale-while-revalidate logic:

```javascript
self.addEventListener('fetch', (event) => {
  event.respondWith(
    caches.match(event.request).then((cachedResponse) => {
      const fetchPromise = fetch(event.request).then((networkResponse) => {
        // Update cache with fresh response
        caches.open('v1').then((cache) => {
          cache.put(event.request, networkResponse.clone());
        });
        return networkResponse;
      });

      // Return cached response immediately, or wait for network
      return cachedResponse || fetchPromise;
    })
  );
});
```

This pattern provides manual control over stale-while-revalidate behavior regardless of server headers.

### Use Cases

#### Social Media Feeds

```http
Cache-Control: max-age=60, stale-while-revalidate=3600
```

Serve slightly outdated feed content immediately while fetching latest posts in background. Users see content instantly; refreshing shows updated posts.

#### User Profiles

```http
Cache-Control: max-age=300, stale-while-revalidate=86400
```

Profile data changes infrequently. Serve cached profiles immediately, update in background. Balance freshness with perceived performance.

#### API Responses with Frequent Updates

```http
Cache-Control: max-age=30, stale-while-revalidate=600
```

Short freshness window with longer stale tolerance. Appropriate for dashboards, analytics, or monitoring interfaces where slightly stale data is acceptable.

#### Static Assets with Versioning

```http
Cache-Control: max-age=3600, stale-while-revalidate=604800
```

CSS/JS files that change occasionally. Serve cached versions immediately, update in background when new versions deploy. Combine with versioned filenames for cache busting.

#### News Articles

```http
Cache-Control: max-age=300, stale-while-revalidate=86400
```

Article content rarely changes after publication. Aggressive stale tolerance provides availability during network issues or origin downtime.

### Performance Characteristics

#### Latency Reduction

First request after expiration:

- Without `stale-while-revalidate`: Blocks for network round-trip (100-500ms typical)
- With `stale-while-revalidate`: Serves from cache (1-10ms typical)

Performance improvement is most pronounced for:

- High-latency connections
- Mobile networks
- Users far from origin servers

#### Network Traffic

Background revalidation occurs on every request during the stale window, potentially increasing server load:

```
User A requests at t=3601s: Serves stale + revalidates
User B requests at t=3602s: Serves stale + revalidates (duplicate)
User C requests at t=3603s: Serves stale + revalidates (duplicate)
```

[Inference] Browsers may implement request coalescing to prevent duplicate background fetches, but this behavior is not standardized.

#### Cache Storage Pressure

Stale responses remain in cache longer, consuming storage space. For aggressive `stale-while-revalidate` values (weeks/months), monitor cache size limits.

### Server-Side Considerations

#### Origin Load Patterns

Background revalidation shifts when cache misses occur but doesn't eliminate them. Origin sees:

- Requests spread over stale window rather than concentrated at expiration
- [Inference] Potentially higher total request volume if multiple clients trigger separate revalidations

#### Response Size Implications

Large responses benefit more from immediate stale serving:

```http
# 5MB video response
Cache-Control: max-age=3600, stale-while-revalidate=86400
```

Downloading 5MB in foreground blocks rendering; serving stale immediately improves user experience significantly.

Small responses (few KB) have minimal latency difference:

```http
# 2KB JSON response
Cache-Control: max-age=60, stale-while-revalidate=300
```

Benefit is less pronounced but still positive.

### CDN and Proxy Behavior

#### Shared Caches

CDNs and forward proxies may handle `stale-while-revalidate` differently than browsers:

- **Cloudflare**: Supports `stale-while-revalidate`, revalidates to origin in background
- **Fastly**: Supports via `stale-if-error` and `stale-while-revalidate` directives
- **AWS CloudFront**: [Unverified] Support status unclear; may require custom Lambda@Edge logic
- **Nginx**: Requires custom configuration with proxy_cache_use_stale and background updates

```nginx
# Nginx configuration for similar behavior
proxy_cache_use_stale updating;
proxy_cache_background_update on;
proxy_cache_valid 200 1h;
```

#### Shared Cache Considerations

When CDNs use `stale-while-revalidate`, all users benefit from a single background revalidation:

```
CDN cache expires at t=3600s
First user request at t=3601s: Triggers single revalidation
All subsequent users during revalidation: Receive stale content
After revalidation completes: All users receive fresh content
```

This is more efficient than per-client revalidation in browser caches.

### Testing and Verification

#### Manual Testing

```bash
# Initial request - should cache response
curl -i https://example.com/api/data

# Note Date and Age headers
# Wait until max-age expires

# Request during stale window - should serve instantly
time curl https://example.com/api/data

# Check if background revalidation occurred
# Request again after brief delay
curl -i https://example.com/api/data
```

Expect immediate response during stale window, with updated content on subsequent request.

#### Chrome DevTools

1. Open Network tab
2. Disable cache in DevTools settings
3. Make request, note Cache-Control header
4. Re-enable cache, wait for max-age to expire
5. Make request again during stale window
6. Observe "(from disk cache)" status with fast timing
7. Check for additional background request [Inference] (may not be visible in DevTools)

#### Programmatic Verification

```javascript
async function testStaleWhileRevalidate(url) {
  const start = performance.now();
  const response = await fetch(url);
  const duration = performance.now() - start;
  
  const age = parseInt(response.headers.get('age') || '0');
  const cacheControl = response.headers.get('cache-control');
  
  console.log({
    duration,
    age,
    cacheControl,
    fromCache: duration < 50 // [Inference] Fast response suggests cache hit
  });
}
```

### Security and Privacy Implications

#### Serving Stale Authenticated Content

```http
Cache-Control: max-age=300, stale-while-revalidate=3600, private
```

Stale user-specific content may expose outdated information:

- Old notification counts
- Stale permission states
- Outdated security-sensitive data

For authenticated endpoints, prefer shorter `stale-while-revalidate` windows or avoid entirely.

#### Cache Poisoning Concerns

If an attacker successfully poisons the cache during the fresh period, `stale-while-revalidate` extends the poisoned content's lifetime. Combine with:

```http
Cache-Control: max-age=3600, stale-while-revalidate=86400
Vary: Origin, Accept-Encoding
```

Proper `Vary` headers prevent shared cache poisoning across different request contexts.

#### Privacy Considerations

Background revalidation generates network requests without explicit user action. In privacy-sensitive contexts, this may be undesirable. [Inference] Browsers in private/incognito mode may disable or limit background revalidation.

### Error Handling During Revalidation

#### Network Failures

When background revalidation fails:

```
Time 3601s: Serve stale content, initiate background fetch
Background fetch: Network error (DNS failure, timeout, etc.)
Time 3602s: Another request arrives
```

[Inference] Browser behavior varies:

- May retry revalidation on next request
- May serve stale content until stale-while-revalidate window expires
- May mark cache entry for eager revalidation

#### Server Errors (5xx)

```http
Cache-Control: max-age=3600, stale-while-revalidate=86400, stale-if-error=604800
```

Background revalidation receives 500 Internal Server Error:

- `stale-if-error` allows serving stale content during errors
- Cache entry remains stale but servable
- [Inference] Next revalidation attempt may occur on subsequent request or after a delay

#### Client Errors (4xx)

Background revalidation receives 404 Not Found:

- [Inference] Cache entry is likely invalidated
- Stale content no longer served
- Subsequent requests receive the 404 directly

### Monitoring and Observability

#### Server-Side Metrics

Track revalidation requests at the origin:

```javascript
// Express.js middleware example
app.use((req, res, next) => {
  // Detect potential revalidation request
  if (req.headers['cache-control']?.includes('max-age=0')) {
    metrics.increment('cache.revalidation');
  }
  next();
});
```

[Inference] Distinguishing background revalidations from normal requests requires heuristics since browsers don't send explicit signals.

#### Client-Side Metrics

```javascript
// Measure cache hit rates
const observer = new PerformanceObserver((list) => {
  for (const entry of list.getEntries()) {
    if (entry.entryType === 'resource') {
      const fromCache = entry.transferSize === 0 && entry.decodedBodySize > 0;
      analytics.track('resource_loaded', {
        fromCache,
        duration: entry.duration,
        url: entry.name
      });
    }
  }
});
observer.observe({ entryTypes: ['resource'] });
```

#### CDN Analytics

Most CDNs provide cache hit/miss metrics:

- Cache HIT: Served from CDN cache (fresh or stale)
- Cache MISS: Fetched from origin
- Cache UPDATING: [Inference] Some CDNs may indicate background revalidation separately

### Comparison with Alternative Strategies

#### Versus No Caching

```http
# No caching
Cache-Control: no-store

# With stale-while-revalidate
Cache-Control: max-age=60, stale-while-revalidate=300
```

No caching: Every request hits origin, consistent latency With SWR: First request fast (from cache), always up-to-date eventually

#### Versus Long max-age

```http
# Long max-age
Cache-Control: max-age=86400

# Shorter max-age with SWR
Cache-Control: max-age=3600, stale-while-revalidate=82800
```

Long max-age: Content may be stale for 24 hours SWR approach: Content updates more frequently while maintaining fast responses

#### Versus ETag Validation

```http
# ETag-based validation
Cache-Control: no-cache
ETag: "abc123"

# SWR approach
Cache-Control: max-age=3600, stale-while-revalidate=86400
```

ETag validation: Always validates before serving (304 Not Modified saves bandwidth but not latency) SWR: Serves immediately during stale window, validates in background (saves both)

### Advanced Patterns

#### Adaptive Stale Windows

```javascript
// Server-side logic to adjust based on content change frequency
function getCacheControl(resourceType) {
  const configs = {
    userProfile: 'max-age=300, stale-while-revalidate=86400',
    newsFeed: 'max-age=60, stale-while-revalidate=600',
    staticAsset: 'max-age=31536000, immutable'
  };
  return configs[resourceType];
}
```

#### Conditional Stale Serving

Service Worker can implement conditional logic:

```javascript
self.addEventListener('fetch', (event) => {
  event.respondWith(
    caches.match(event.request).then((cached) => {
      if (!cached) return fetch(event.request);
      
      const cacheTime = new Date(cached.headers.get('date'));
      const age = Date.now() - cacheTime;
      const maxAge = 3600000; // 1 hour
      const staleTime = 86400000; // 24 hours
      
      const networkFetch = fetch(event.request).then((response) => {
        caches.open('v1').then((cache) => {
          cache.put(event.request, response.clone());
        });
        return response;
      });
      
      // Only serve stale during certain conditions
      if (age < maxAge) {
        return cached; // Fresh
      } else if (age < maxAge + staleTime && navigator.connection?.effectiveType === '4g') {
        networkFetch; // Fire and forget [Inference]
        return cached; // Serve stale on fast connections
      } else {
        return networkFetch; // Wait for network on slow connections or expired
      }
    })
  );
});
```

#### Progressive Enhancement

```javascript
// Client-side fallback for browsers without SWR support [Inference]
async function fetchWithSWR(url, options = {}) {
  const cacheKey = `swr-${url}`;
  
  try {
    const cached = localStorage.getItem(cacheKey);
    if (cached) {
      const { data, timestamp } = JSON.parse(cached);
      const age = Date.now() - timestamp;
      
      if (age < 3600000) {
        // Fresh, return immediately
        return data;
      } else if (age < 90000000) {
        // Stale, return and revalidate
        fetch(url, options)
          .then(r => r.json())
          .then(fresh => {
            localStorage.setItem(cacheKey, JSON.stringify({
              data: fresh,
              timestamp: Date.now()
            }));
          });
        return data;
      }
    }
  } catch (e) {
    // LocalStorage unavailable or corrupt
  }
  
  // No cache or expired, fetch fresh
  const response = await fetch(url, options);
  const data = await response.json();
  
  try {
    localStorage.setItem(cacheKey, JSON.stringify({
      data,
      timestamp: Date.now()
    }));
  } catch (e) {
    // Storage quota exceeded
  }
  
  return data;
}
```

### Framework and Library Support

#### Next.js

Next.js can set cache headers via configuration:

```javascript
// next.config.js
module.exports = {
  async headers() {
    return [
      {
        source: '/api/:path*',
        headers: [
          {
            key: 'Cache-Control',
            value: 'max-age=60, stale-while-revalidate=86400'
          }
        ]
      }
    ];
  }
};
```

#### SWR Library (React)

The SWR library implements stale-while-revalidate pattern at the application level:

```javascript
import useSWR from 'swr';

function Profile() {
  const { data, error } = useSWR('/api/user', fetcher);
  
  // Returns cached data immediately, revalidates in background
  if (error) return <div>Failed to load</div>;
  if (!data) return <div>Loading...</div>;
  return <div>Hello {data.name}!</div>;
}
```

This provides SWR behavior regardless of server headers, with client-side control.

#### React Query

```javascript
import { useQuery } from 'react-query';

function Dashboard() {
  const { data } = useQuery('dashboard', fetchDashboard, {
    staleTime: 60000, // Consider fresh for 1 minute
    cacheTime: 86400000, // Keep in cache for 24 hours
    refetchOnMount: 'always' // Revalidate on component mount
  });
  
  return <div>{/* Render dashboard */}</div>;
}
```

Implements similar patterns with JavaScript-based caching rather than HTTP caching.

---

