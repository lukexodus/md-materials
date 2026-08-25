## Cache API Integration with Fetch API


### Understanding the Cache Interface

The Cache API provides a storage mechanism for Request/Response object pairs that are cached in long-lived memory. Each Cache object represents a named cache that persists across browser sessions. The CacheStorage interface manages multiple Cache instances, accessible via `window.caches` or `self.caches` in service workers.

```javascript
// Accessing the cache storage
const cache = await caches.open('my-cache-v1');
```

### Core Cache Operations with Fetch

#### Storing Fetch Responses

The `cache.put()` method stores a Request/Response pair explicitly, while `cache.add()` and `cache.addAll()` fetch and store in a single operation.

```javascript
// Explicit put with fetch
const response = await fetch('/api/data');
const cache = await caches.open('api-cache');
await cache.put('/api/data', response.clone());

// Direct add (fetches internally)
await cache.add('/api/data');

// Batch adding
await cache.addAll([
  '/api/users',
  '/api/posts',
  '/assets/style.css'
]);
```

**Critical consideration**: Response objects can only be read once due to their body being a ReadableStream. Always use `response.clone()` when caching a response you also need to return or process.

### Reading from Cache

#### Basic Cache Retrieval

```javascript
const cache = await caches.open('my-cache-v1');
const cachedResponse = await cache.match('/api/data');

if (cachedResponse) {
  const data = await cachedResponse.json();
  // Use cached data
}
```

#### Cache Matching with Options

The `match()` method accepts an options object for fine-grained control:

```javascript
const response = await cache.match(request, {
  ignoreSearch: true,    // Ignore query parameters
  ignoreMethod: false,   // Respect HTTP method
  ignoreVary: false      // Respect Vary header
});
```

### Cache-First Strategy Pattern

This strategy checks the cache before making network requests, falling back to fetch when necessary:

```javascript
async function cacheFirst(request) {
  const cache = await caches.open('my-cache-v1');
  const cachedResponse = await cache.match(request);
  
  if (cachedResponse) {
    return cachedResponse;
  }
  
  const networkResponse = await fetch(request);
  
  // Cache the new response for future use
  if (networkResponse.ok) {
    cache.put(request, networkResponse.clone());
  }
  
  return networkResponse;
}
```

### Network-First Strategy Pattern

This prioritizes fresh data but falls back to cache on network failure:

```javascript
async function networkFirst(request) {
  const cache = await caches.open('my-cache-v1');
  
  try {
    const networkResponse = await fetch(request);
    
    if (networkResponse.ok) {
      cache.put(request, networkResponse.clone());
    }
    
    return networkResponse;
  } catch (error) {
    const cachedResponse = await cache.match(request);
    
    if (cachedResponse) {
      return cachedResponse;
    }
    
    throw error;
  }
}
```

### Stale-While-Revalidate Pattern

Returns cached content immediately while fetching fresh data in the background:

```javascript
async function staleWhileRevalidate(request) {
  const cache = await caches.open('my-cache-v1');
  const cachedResponse = await cache.match(request);
  
  // Fetch fresh data in background
  const fetchPromise = fetch(request).then(networkResponse => {
    if (networkResponse.ok) {
      cache.put(request, networkResponse.clone());
    }
    return networkResponse;
  });
  
  // Return cached version immediately if available
  return cachedResponse || fetchPromise;
}
```

### Cache Invalidation and Updates

#### Deleting Specific Entries

```javascript
const cache = await caches.open('my-cache-v1');
const deleted = await cache.delete('/api/data');

// With options
await cache.delete(request, {
  ignoreSearch: true,
  ignoreMethod: false,
  ignoreVary: false
});
```

#### Deleting Entire Caches

```javascript
// Delete a specific cache
await caches.delete('my-cache-v1');

// Delete old cache versions
const cacheNames = await caches.keys();
await Promise.all(
  cacheNames
    .filter(name => name !== 'my-cache-v2')
    .map(name => caches.delete(name))
);
```

#### Cache Versioning Strategy

```javascript
const CACHE_VERSION = 'v2';
const CACHE_NAME = `my-app-${CACHE_VERSION}`;

// During service worker activation
self.addEventListener('activate', event => {
  event.waitUntil(
    caches.keys().then(cacheNames => {
      return Promise.all(
        cacheNames
          .filter(name => name !== CACHE_NAME)
          .map(name => caches.delete(name))
      );
    })
  );
});
```

### Query and Inspection Methods

#### Listing Cache Contents

```javascript
const cache = await caches.open('my-cache-v1');
const requests = await cache.keys();

requests.forEach(request => {
  console.log(request.url);
});

// Filter specific patterns
const apiRequests = requests.filter(req => 
  req.url.includes('/api/')
);
```

#### Checking Multiple Caches

```javascript
// Match across all caches
const response = await caches.match('/api/data');

// List all cache names
const allCaches = await caches.keys();
console.log(allCaches); // ['cache-v1', 'cache-v2', 'images']
```

### Request/Response Matching Details

#### URL Matching Behavior

The Cache API performs strict URL matching by default:

```javascript
// These are considered different URLs
await cache.put('https://api.example.com/data', response1);
await cache.match('https://api.example.com/data?id=1'); // null

// Use ignoreSearch to match regardless of query params
await cache.match('https://api.example.com/data?id=1', {
  ignoreSearch: true
}); // Returns response1
```

#### Vary Header Handling

The Vary response header affects cache matching:

```javascript
// Response with Vary: Accept-Language
const response = await fetch('/api/content');
await cache.put(request, response);

// Must match the Vary header values to retrieve
const match = await cache.match(request); // Checks Accept-Language header
```

### Service Worker Integration

#### Installation Phase Caching

```javascript
const CACHE_NAME = 'app-v1';
const urlsToCache = [
  '/',
  '/styles/main.css',
  '/scripts/app.js'
];

self.addEventListener('install', event => {
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then(cache => cache.addAll(urlsToCache))
  );
});
```

#### Fetch Event Interception

```javascript
self.addEventListener('fetch', event => {
  event.respondWith(
    caches.match(event.request)
      .then(cachedResponse => {
        if (cachedResponse) {
          return cachedResponse;
        }
        
        return fetch(event.request).then(response => {
          // Don't cache non-GET requests or failed responses
          if (event.request.method !== 'GET' || !response.ok) {
            return response;
          }
          
          const responseToCache = response.clone();
          caches.open(CACHE_NAME)
            .then(cache => {
              cache.put(event.request, responseToCache);
            });
          
          return response;
        });
      })
  );
});
```

### Advanced Caching Strategies

#### Cache with Network Timeout

```javascript
async function cacheWithTimeout(request, timeout = 3000) {
  const cache = await caches.open('my-cache-v1');
  
  const timeoutPromise = new Promise((_, reject) => 
    setTimeout(() => reject(new Error('Network timeout')), timeout)
  );
  
  try {
    const networkResponse = await Promise.race([
      fetch(request),
      timeoutPromise
    ]);
    
    cache.put(request, networkResponse.clone());
    return networkResponse;
  } catch (error) {
    const cachedResponse = await cache.match(request);
    if (cachedResponse) {
      return cachedResponse;
    }
    throw error;
  }
}
```

#### Cache Then Network with Update

```javascript
async function cacheThenNetworkUpdate(request, callback) {
  const cache = await caches.open('my-cache-v1');
  
  // Return cached immediately
  const cachedResponse = await cache.match(request);
  if (cachedResponse) {
    callback(cachedResponse.clone());
  }
  
  // Fetch and update
  try {
    const networkResponse = await fetch(request);
    if (networkResponse.ok) {
      cache.put(request, networkResponse.clone());
      callback(networkResponse.clone());
    }
  } catch (error) {
    if (!cachedResponse) {
      throw error;
    }
  }
}

// Usage
cacheThenNetworkUpdate('/api/data', response => {
  response.json().then(data => updateUI(data));
});
```

#### Selective Caching Based on Criteria

```javascript
function shouldCache(request, response) {
  // Only cache successful GET requests
  if (request.method !== 'GET' || !response.ok) {
    return false;
  }
  
  // Don't cache certain content types
  const contentType = response.headers.get('Content-Type') || '';
  if (contentType.includes('text/html')) {
    return false;
  }
  
  // Don't cache responses with no-store
  const cacheControl = response.headers.get('Cache-Control') || '';
  if (cacheControl.includes('no-store')) {
    return false;
  }
  
  return true;
}

self.addEventListener('fetch', event => {
  event.respondWith(
    fetch(event.request).then(response => {
      if (shouldCache(event.request, response)) {
        const cache = caches.open('selective-cache');
        cache.then(c => c.put(event.request, response.clone()));
      }
      return response;
    })
  );
});
```

### Cache Size Management

#### Manual Cache Pruning

```javascript
async function pruneCache(cacheName, maxItems) {
  const cache = await caches.open(cacheName);
  const keys = await cache.keys();
  
  if (keys.length > maxItems) {
    // Remove oldest entries (FIFO approach)
    const keysToDelete = keys.slice(0, keys.length - maxItems);
    await Promise.all(
      keysToDelete.map(key => cache.delete(key))
    );
  }
}
```

#### Time-Based Expiration

```javascript
async function cacheWithExpiry(request, response, maxAge) {
  const cache = await caches.open('time-based-cache');
  
  // Create modified response with expiry metadata
  const expiryTime = Date.now() + maxAge;
  const modifiedResponse = new Response(response.body, {
    status: response.status,
    statusText: response.statusText,
    headers: new Headers(response.headers)
  });
  
  modifiedResponse.headers.set('X-Cache-Expiry', expiryTime.toString());
  await cache.put(request, modifiedResponse);
}

async function matchWithExpiry(request) {
  const cache = await caches.open('time-based-cache');
  const response = await cache.match(request);
  
  if (!response) {
    return null;
  }
  
  const expiryTime = response.headers.get('X-Cache-Expiry');
  if (expiryTime && Date.now() > parseInt(expiryTime)) {
    await cache.delete(request);
    return null;
  }
  
  return response;
}
```

### Error Handling Patterns

#### Graceful Degradation

```javascript
async function fetchWithCacheFallback(request) {
  const cache = await caches.open('my-cache-v1');
  
  try {
    const response = await fetch(request);
    
    if (response.ok) {
      cache.put(request, response.clone());
      return response;
    }
    
    // Network responded but with error status
    const cached = await cache.match(request);
    return cached || response;
  } catch (networkError) {
    // Network failed completely
    const cached = await cache.match(request);
    
    if (cached) {
      return cached;
    }
    
    // Return offline fallback page
    return cache.match('/offline.html');
  }
}
```

#### Cache Operation Error Handling

```javascript
async function safeCacheOperation(operation) {
  try {
    return await operation();
  } catch (error) {
    // QuotaExceededError handling
    if (error.name === 'QuotaExceededError') {
      console.error('Cache storage quota exceeded');
      // Implement cleanup strategy
      await cleanupOldCaches();
      return null;
    }
    
    console.error('Cache operation failed:', error);
    return null;
  }
}

// Usage
await safeCacheOperation(async () => {
  const cache = await caches.open('my-cache');
  return cache.put(request, response);
});
```

### Cross-Origin Resource Caching

#### Opaque Responses

```javascript
// Opaque responses from no-cors requests
const response = await fetch('https://third-party.com/image.jpg', {
  mode: 'no-cors'
});

const cache = await caches.open('images');
await cache.put(request, response);

// [Inference] Opaque responses can be cached but have limitations
// - Cannot read response body or headers
// - Status is always 0
// - Can only verify successful cache through retrieval
```

#### CORS-Enabled Resources

```javascript
// Full access to CORS-enabled responses
const response = await fetch('https://api.example.com/data', {
  mode: 'cors'
});

if (response.ok) {
  const cache = await caches.open('api-cache');
  await cache.put(request, response.clone());
  
  // Can access response details
  console.log(response.status);
  console.log(response.headers.get('Content-Type'));
}
```

### Performance Considerations

#### Parallel Cache Operations

```javascript
// Parallel cache checks across multiple caches
async function findInAnyCaches(request) {
  const cacheNames = await caches.keys();
  
  const searchPromises = cacheNames.map(name =>
    caches.open(name).then(cache => cache.match(request))
  );
  
  const results = await Promise.all(searchPromises);
  return results.find(response => response !== undefined);
}
```

#### Batch Cache Updates

```javascript
async function updateMultipleEntries(entries) {
  const cache = await caches.open('my-cache-v1');
  
  await Promise.all(
    entries.map(({ request, response }) => 
      cache.put(request, response)
    )
  );
}
```

### Cache API Limitations and Constraints

#### Storage Quota

[Inference] The Cache API is subject to browser storage quotas, which vary by browser and available disk space. Exceeding quotas results in `QuotaExceededError`. The Storage API can query available space:

```javascript
if ('storage' in navigator && 'estimate' in navigator.storage) {
  const estimate = await navigator.storage.estimate();
  const percentUsed = (estimate.usage / estimate.quota) * 100;
  console.log(`Using ${percentUsed.toFixed(2)}% of storage`);
}
```

#### Request Matching Restrictions

- Only HTTP/HTTPS schemes are cached
- Request method matters (default matching respects method)
- Fragment identifiers are ignored in URLs
- Credentials mode affects opaque response caching

### Testing and Debugging

#### Cache Inspection in DevTools

```javascript
// Programmatic cache inspection utility
async function inspectCache(cacheName) {
  const cache = await caches.open(cacheName);
  const requests = await cache.keys();
  
  const entries = await Promise.all(
    requests.map(async request => {
      const response = await cache.match(request);
      return {
        url: request.url,
        method: request.method,
        status: response.status,
        headers: Object.fromEntries(response.headers.entries())
      };
    })
  );
  
  return entries;
}
```

#### Cache State Verification

```javascript
async function verifyCacheState(expectedUrls, cacheName) {
  const cache = await caches.open(cacheName);
  const requests = await cache.keys();
  const cachedUrls = requests.map(req => req.url);
  
  const missing = expectedUrls.filter(url => !cachedUrls.includes(url));
  const unexpected = cachedUrls.filter(url => !expectedUrls.includes(url));
  
  return { missing, unexpected, allPresent: missing.length === 0 };
}
```

---

