## Stale-While-Revalidate


### Core Concept

Stale-while-revalidate is a caching strategy where cached content is served immediately (even if stale) while simultaneously fetching fresh content in the background. This provides instant responses while ensuring eventual consistency.

The strategy originates from the HTTP `Cache-Control` header directive:

```http
Cache-Control: max-age=3600, stale-while-revalidate=86400
```

This tells the browser: serve from cache for 1 hour, and for the next 24 hours serve stale content while fetching fresh data.

### HTTP Cache-Control Implementation

The `stale-while-revalidate` directive works at the HTTP caching layer:

```javascript
// Server response
fetch('/api/data')
  .then(response => {
    // Response includes:
    // Cache-Control: max-age=60, stale-while-revalidate=3600
    return response.json();
  });
```

**Freshness Window (`max-age`):** Content is considered fresh and served directly from cache.

**Revalidation Window (`stale-while-revalidate`):** Content is stale but served from cache while the browser asynchronously revalidates.

**Beyond Revalidation Window:** Content is not served from cache; the browser waits for fresh data.

### Browser Support

Native `Cache-Control: stale-while-revalidate` support:

- Chrome 75+ (June 2019)
- Edge 79+ (January 2020)
- Firefox 68+ (July 2019) - behind flag until Firefox 79

**No Native Support:**

- Safari (all versions as of January 2025)
- Internet Explorer (all versions)

[Unverified] Safari may have added support after January 2025.

### Manual Implementation Pattern

Implementing SWR without native browser support:

```javascript
async function fetchWithSWR(url, options = {}) {
  const cacheKey = url;
  const cached = await getCachedData(cacheKey);
  
  // Return stale data immediately
  if (cached && cached.stale) {
    // Trigger background revalidation
    revalidateInBackground(url, cacheKey, options);
    return cached.data;
  }
  
  // Return fresh cached data
  if (cached && !cached.stale) {
    return cached.data;
  }
  
  // No cache, fetch fresh
  const response = await fetch(url, options);
  const data = await response.json();
  
  await setCachedData(cacheKey, data);
  return data;
}

function revalidateInBackground(url, cacheKey, options) {
  fetch(url, options)
    .then(response => response.json())
    .then(data => setCachedData(cacheKey, data))
    .catch(err => console.error('Revalidation failed:', err));
}
```

### Cache Storage API Integration

Using the Cache API for persistent storage:

```javascript
async function getCachedData(cacheKey) {
  const cache = await caches.open('swr-cache-v1');
  const cached = await cache.match(cacheKey);
  
  if (!cached) return null;
  
  const data = await cached.json();
  const cachedTime = new Date(cached.headers.get('X-Cached-Time'));
  const age = Date.now() - cachedTime.getTime();
  
  const maxAge = 60000; // 60 seconds fresh
  const staleTime = 3600000; // 1 hour stale-while-revalidate
  
  return {
    data,
    stale: age > maxAge,
    expired: age > maxAge + staleTime
  };
}

async function setCachedData(cacheKey, data) {
  const cache = await caches.open('swr-cache-v1');
  const response = new Response(JSON.stringify(data), {
    headers: {
      'Content-Type': 'application/json',
      'X-Cached-Time': new Date().toISOString()
    }
  });
  
  await cache.put(cacheKey, response);
}
```

### Service Worker Implementation

Service workers provide powerful SWR control:

```javascript
// service-worker.js
self.addEventListener('fetch', event => {
  if (event.request.url.includes('/api/')) {
    event.respondWith(staleWhileRevalidate(event.request));
  }
});

async function staleWhileRevalidate(request) {
  const cache = await caches.open('api-cache-v1');
  const cached = await cache.match(request);
  
  // Fetch fresh data in background
  const fetchPromise = fetch(request).then(response => {
    cache.put(request, response.clone());
    return response;
  });
  
  // Return cached immediately if available
  return cached || fetchPromise;
}
```

### Libraries and Frameworks

**SWR (Vercel):**

```javascript
import useSWR from 'swr';

function Profile() {
  const { data, error, isLoading } = useSWR('/api/user', fetcher);
  
  if (error) return <div>Failed to load</div>;
  if (isLoading) return <div>Loading...</div>;
  return <div>Hello {data.name}!</div>;
}

const fetcher = url => fetch(url).then(res => res.json());
```

The library handles:

- Automatic revalidation on focus
- Interval polling
- Deduplication of requests
- Cache invalidation

**React Query (TanStack Query):**

```javascript
import { useQuery } from '@tanstack/react-query';

function Profile() {
  const { data, isLoading } = useQuery({
    queryKey: ['user'],
    queryFn: () => fetch('/api/user').then(res => res.json()),
    staleTime: 60000, // Consider fresh for 60s
    cacheTime: 300000, // Keep in cache for 5min
  });
  
  return <div>{data?.name}</div>;
}
```

**Workbox:**

```javascript
import { StaleWhileRevalidate } from 'workbox-strategies';
import { registerRoute } from 'workbox-routing';

registerRoute(
  ({url}) => url.pathname.startsWith('/api/'),
  new StaleWhileRevalidate({
    cacheName: 'api-cache',
    plugins: [
      {
        cacheKeyWillBeUsed: async ({request}) => request.url,
      }
    ]
  })
);
```

### Configuration Parameters

**Max Age (Freshness Period):** Duration content is considered fresh. No revalidation occurs during this period.

```javascript
const maxAge = 60; // 60 seconds
```

**Stale Window (Revalidation Period):** Duration stale content can be served while revalidating.

```javascript
const staleWhileRevalidate = 3600; // 1 hour
```

**Cache Time (Retention):** How long data stays in cache before being purged.

```javascript
const cacheTime = 86400; // 24 hours
```

### Revalidation Triggers

**On Mount:**

```javascript
useSWR('/api/data', fetcher, {
  revalidateOnMount: true
});
```

**On Focus:**

```javascript
useSWR('/api/data', fetcher, {
  revalidateOnFocus: true
});
```

**On Reconnect:**

```javascript
useSWR('/api/data', fetcher, {
  revalidateOnReconnect: true
});
```

**Interval Polling:**

```javascript
useSWR('/api/data', fetcher, {
  refreshInterval: 3000 // Revalidate every 3s
});
```

**Manual Revalidation:**

```javascript
const { data, mutate } = useSWR('/api/data', fetcher);

// Trigger revalidation
mutate();
```

### Cache Invalidation

**Mutation with Optimistic Updates:**

```javascript
import { useSWRConfig } from 'swr';

function UpdateButton() {
  const { mutate } = useSWRConfig();
  
  const updateUser = async () => {
    // Optimistically update cache
    mutate('/api/user', { name: 'New Name' }, false);
    
    // Send update to server
    await fetch('/api/user', {
      method: 'PUT',
      body: JSON.stringify({ name: 'New Name' })
    });
    
    // Revalidate to confirm
    mutate('/api/user');
  };
  
  return <button onClick={updateUser}>Update</button>;
}
```

**Cache Invalidation Patterns:**

```javascript
// Invalidate single key
mutate('/api/user');

// Invalidate by pattern
mutate(key => key.startsWith('/api/users/'));

// Clear specific cache
cache.delete(new Request('/api/data'));

// Clear all caches
caches.keys().then(names => {
  names.forEach(name => caches.delete(name));
});
```

### Error Handling

**Stale-If-Error:**

Serve stale content if revalidation fails:

```javascript
async function fetchWithStaleIfError(url) {
  const cached = await getCachedData(url);
  
  try {
    const response = await fetch(url);
    if (!response.ok) throw new Error('Fetch failed');
    
    const data = await response.json();
    await setCachedData(url, data);
    return data;
  } catch (error) {
    // Return stale data on error
    if (cached) {
      console.warn('Using stale data due to error:', error);
      return cached.data;
    }
    throw error;
  }
}
```

**HTTP Header:**

```http
Cache-Control: max-age=60, stale-while-revalidate=3600, stale-if-error=86400
```

### Deduplication

Prevent multiple simultaneous requests for the same resource:

```javascript
const pendingRequests = new Map();

async function fetchWithDedup(url) {
  // Return existing pending request
  if (pendingRequests.has(url)) {
    return pendingRequests.get(url);
  }
  
  // Create new request
  const promise = fetch(url)
    .then(response => response.json())
    .finally(() => pendingRequests.delete(url));
  
  pendingRequests.set(url, promise);
  return promise;
}
```

### Memory Considerations

**Cache Size Limits:**

```javascript
async function pruneCacheIfNeeded() {
  const cache = await caches.open('swr-cache-v1');
  const requests = await cache.keys();
  
  const maxEntries = 100;
  if (requests.length > maxEntries) {
    // Remove oldest entries
    const toDelete = requests.slice(0, requests.length - maxEntries);
    await Promise.all(toDelete.map(req => cache.delete(req)));
  }
}
```

**Storage Quota:**

```javascript
if (navigator.storage && navigator.storage.estimate) {
  const estimate = await navigator.storage.estimate();
  const percentUsed = (estimate.usage / estimate.quota) * 100;
  console.log(`Storage: ${percentUsed.toFixed(2)}% used`);
}
```

### Race Condition Handling

**Last-Write-Wins:**

```javascript
let latestRequestId = 0;

async function fetchWithRaceProtection(url) {
  const requestId = ++latestRequestId;
  
  const cached = await getCachedData(url);
  if (cached) {
    // Return cached data immediately
    setTimeout(() => revalidate(url, requestId), 0);
    return cached.data;
  }
  
  return revalidate(url, requestId);
}

async function revalidate(url, requestId) {
  const data = await fetch(url).then(r => r.json());
  
  // Only update if this is still the latest request
  if (requestId === latestRequestId) {
    await setCachedData(url, data);
    return data;
  }
}
```

### Conditional Requests

Optimize revalidation with `ETag` and `Last-Modified`:

```javascript
async function fetchWithConditional(url) {
  const cache = await caches.open('swr-cache-v1');
  const cached = await cache.match(url);
  
  const headers = {};
  if (cached) {
    const etag = cached.headers.get('ETag');
    const lastModified = cached.headers.get('Last-Modified');
    
    if (etag) headers['If-None-Match'] = etag;
    if (lastModified) headers['If-Modified-Since'] = lastModified;
  }
  
  const response = await fetch(url, { headers });
  
  // 304 Not Modified - cached content is still fresh
  if (response.status === 304) {
    return cached;
  }
  
  // Update cache with fresh content
  await cache.put(url, response.clone());
  return response;
}
```

### Performance Benefits

**Perceived Performance:** Users see content instantly from cache rather than waiting for network requests.

**Reduced Server Load:** Fewer blocking requests to the server during the freshness period.

**Bandwidth Efficiency:** Content is fetched in background, not blocking user interaction.

**Offline Resilience:** Stale content can be served when network is unavailable.

### Drawbacks and Tradeoffs

**Stale Data Display:** Users may see outdated information briefly.

**Increased Bandwidth:** Background revalidation consumes bandwidth even when users don't notice updates.

**Cache Storage Overhead:** Requires managing cache storage and eviction policies.

**Complexity:** Requires careful handling of cache keys, invalidation, and race conditions.

### CDN Integration

CDNs like Cloudflare and Fastly support `stale-while-revalidate`:

```javascript
// Cloudflare Cache-Control
Response.headers.set(
  'Cache-Control',
  'public, max-age=60, stale-while-revalidate=3600'
);
```

**Cloudflare:** Respects `stale-while-revalidate` directive at edge locations.

**Fastly:** Supports via `stale-while-revalidate` and `stale-if-error` directives.

**AWS CloudFront:** [Unverified] May support `stale-while-revalidate` as of 2024 or later.

### Testing Strategies

**Simulating Stale Data:**

```javascript
// Mock cache with stale data
beforeEach(() => {
  const staleData = { name: 'Stale User' };
  const timestamp = Date.now() - 120000; // 2 minutes ago
  
  cache.put('/api/user', new Response(JSON.stringify(staleData), {
    headers: { 'X-Cached-Time': new Date(timestamp).toISOString() }
  }));
});

test('serves stale data while revalidating', async () => {
  const result = await fetchWithSWR('/api/user');
  expect(result.name).toBe('Stale User');
  
  // Wait for revalidation
  await new Promise(resolve => setTimeout(resolve, 100));
  
  const fresh = await getCachedData('/api/user');
  expect(fresh.data.name).toBe('Fresh User');
});
```

**Network Throttling:**

Test behavior under slow network conditions using browser DevTools or programmatically.

### GraphQL Integration

SWR with GraphQL queries:

```javascript
import useSWR from 'swr';

const query = `
  query User($id: ID!) {
    user(id: $id) {
      id
      name
      email
    }
  }
`;

function useUser(id) {
  return useSWR([query, id], ([query, id]) =>
    fetch('/graphql', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ query, variables: { id } })
    }).then(res => res.json())
  );
}
```

### WebSocket and Real-Time Updates

Combining SWR with WebSocket for real-time data:

```javascript
const { data, mutate } = useSWR('/api/data', fetcher);

useEffect(() => {
  const ws = new WebSocket('wss://api.example.com');
  
  ws.onmessage = (event) => {
    const update = JSON.parse(event.data);
    // Update cache with real-time data
    mutate(update, false);
  };
  
  return () => ws.close();
}, []);
```

---

