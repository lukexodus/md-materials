## Service Worker Caching with Fetch API


### Cache Storage API Fundamentals

Service workers access caches through the CacheStorage interface, available via the global `caches` object:

```javascript
// Open or create a cache
const cache = await caches.open('my-cache-v1');

// Add single resource
await cache.add('/styles.css');

// Add multiple resources
await cache.addAll([
  '/index.html',
  '/styles.css',
  '/script.js',
  '/image.png'
]);

// Store custom response
await cache.put('/api/data', new Response('{"key":"value"}'));

// Retrieve cached response
const response = await cache.match('/styles.css');

// Delete cached response
await cache.delete('/styles.css');

// Get all cached request URLs
const requests = await cache.keys();
```

### Cache Lifecycle Management

Managing cache versions and cleanup:

```javascript
const CACHE_VERSION = 'v2';
const CACHE_NAME = `my-app-${CACHE_VERSION}`;

self.addEventListener('install', event => {
  event.waitUntil(
    caches.open(CACHE_NAME).then(cache => {
      return cache.addAll([
        '/',
        '/index.html',
        '/styles.css',
        '/script.js'
      ]);
    })
  );
  
  // Activate immediately without waiting
  self.skipWaiting();
});

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
  
  // Take control of all clients immediately
  return self.clients.claim();
});
```

### Caching Strategies

#### Cache First (Cache Falling Back to Network)

Prioritizes cached content, fetches from network if cache miss:

```javascript
self.addEventListener('fetch', event => {
  event.respondWith(
    caches.match(event.request).then(cached => {
      if (cached) {
        return cached;
      }
      
      return fetch(event.request).then(response => {
        // Clone response before caching
        const responseClone = response.clone();
        
        caches.open(CACHE_NAME).then(cache => {
          cache.put(event.request, responseClone);
        });
        
        return response;
      });
    })
  );
});
```

#### Network First (Network Falling Back to Cache)

Attempts network first, falls back to cache on failure:

```javascript
self.addEventListener('fetch', event => {
  event.respondWith(
    fetch(event.request)
      .then(response => {
        const responseClone = response.clone();
        
        caches.open(CACHE_NAME).then(cache => {
          cache.put(event.request, responseClone);
        });
        
        return response;
      })
      .catch(() => {
        return caches.match(event.request);
      })
  );
});
```

#### Stale While Revalidate

Returns cached content immediately while fetching fresh content in background:

```javascript
self.addEventListener('fetch', event => {
  event.respondWith(
    caches.match(event.request).then(cached => {
      const fetchPromise = fetch(event.request).then(response => {
        const responseClone = response.clone();
        
        caches.open(CACHE_NAME).then(cache => {
          cache.put(event.request, responseClone);
        });
        
        return response;
      });
      
      // Return cached immediately, update cache in background
      return cached || fetchPromise;
    })
  );
});
```

#### Network Only

Always fetches from network, bypasses cache:

```javascript
self.addEventListener('fetch', event => {
  event.respondWith(fetch(event.request));
});
```

#### Cache Only

Only serves cached content, never fetches from network:

```javascript
self.addEventListener('fetch', event => {
  event.respondWith(caches.match(event.request));
});
```

### Strategy-Based Routing

Applying different strategies based on request characteristics:

```javascript
self.addEventListener('fetch', event => {
  const { request } = event;
  const url = new URL(request.url);
  
  // Cache first for static assets
  if (url.pathname.match(/\.(css|js|png|jpg|jpeg|gif|svg|woff2?)$/)) {
    event.respondWith(cacheFirst(request));
    return;
  }
  
  // Network first for API calls
  if (url.pathname.startsWith('/api/')) {
    event.respondWith(networkFirst(request));
    return;
  }
  
  // Stale while revalidate for HTML pages
  if (request.headers.get('Accept').includes('text/html')) {
    event.respondWith(staleWhileRevalidate(request));
    return;
  }
  
  // Network only for everything else
  event.respondWith(fetch(request));
});

async function cacheFirst(request) {
  const cached = await caches.match(request);
  if (cached) return cached;
  
  const response = await fetch(request);
  const cache = await caches.open(CACHE_NAME);
  cache.put(request, response.clone());
  return response;
}

async function networkFirst(request) {
  try {
    const response = await fetch(request);
    const cache = await caches.open(CACHE_NAME);
    cache.put(request, response.clone());
    return response;
  } catch (error) {
    const cached = await caches.match(request);
    if (cached) return cached;
    throw error;
  }
}

async function staleWhileRevalidate(request) {
  const cached = await caches.match(request);
  
  const fetchPromise = fetch(request).then(response => {
    caches.open(CACHE_NAME).then(cache => {
      cache.put(request, response.clone());
    });
    return response;
  });
  
  return cached || fetchPromise;
}
```

### Request Matching Options

Fine-grained control over cache matching:

```javascript
// Ignore query parameters
const response = await cache.match(request, {
  ignoreSearch: true
});

// Ignore request method (match GET for POST)
const response = await cache.match(request, {
  ignoreMethod: true
});

// Ignore vary header
const response = await cache.match(request, {
  ignoreVary: true
});

// Complete control
const response = await cache.match(request, {
  ignoreSearch: true,
  ignoreMethod: false,
  ignoreVary: false
});
```

### Conditional Caching

Caching based on response characteristics:

```javascript
self.addEventListener('fetch', event => {
  event.respondWith(
    fetch(event.request).then(response => {
      // Only cache successful responses
      if (!response || response.status !== 200 || response.type === 'error') {
        return response;
      }
      
      // Only cache specific content types
      const contentType = response.headers.get('Content-Type');
      if (!contentType || !contentType.includes('text/html')) {
        return response;
      }
      
      // Check response size
      const contentLength = response.headers.get('Content-Length');
      if (contentLength && parseInt(contentLength) > 5 * 1024 * 1024) {
        // Skip caching files over 5MB
        return response;
      }
      
      const responseClone = response.clone();
      
      caches.open(CACHE_NAME).then(cache => {
        cache.put(event.request, responseClone);
      });
      
      return response;
    })
  );
});
```

### Cache Expiration

Implementing time-based cache invalidation:

```javascript
const CACHE_EXPIRATION = 24 * 60 * 60 * 1000; // 24 hours

async function getCachedWithExpiration(request) {
  const cache = await caches.open(CACHE_NAME);
  const cached = await cache.match(request);
  
  if (!cached) return null;
  
  // Check custom expiration header
  const cachedTime = cached.headers.get('sw-cached-time');
  
  if (cachedTime) {
    const age = Date.now() - parseInt(cachedTime);
    if (age > CACHE_EXPIRATION) {
      // Expired, delete from cache
      await cache.delete(request);
      return null;
    }
  }
  
  return cached;
}

async function cacheWithExpiration(request, response) {
  const cache = await caches.open(CACHE_NAME);
  
  // Add timestamp header
  const headers = new Headers(response.headers);
  headers.set('sw-cached-time', Date.now().toString());
  
  const modifiedResponse = new Response(response.body, {
    status: response.status,
    statusText: response.statusText,
    headers: headers
  });
  
  await cache.put(request, modifiedResponse);
}

self.addEventListener('fetch', event => {
  event.respondWith(
    getCachedWithExpiration(event.request).then(cached => {
      if (cached) return cached;
      
      return fetch(event.request).then(response => {
        cacheWithExpiration(event.request, response.clone());
        return response;
      });
    })
  );
});
```

### Cache Quota Management

Monitoring and managing storage usage:

```javascript
async function getCacheSize(cacheName) {
  const cache = await caches.open(cacheName);
  const keys = await cache.keys();
  
  let totalSize = 0;
  
  for (const request of keys) {
    const response = await cache.match(request);
    const blob = await response.blob();
    totalSize += blob.size;
  }
  
  return totalSize;
}

async function enforceQuota(maxSize) {
  const cache = await caches.open(CACHE_NAME);
  const keys = await cache.keys();
  
  // Build array with sizes and timestamps
  const entries = [];
  
  for (const request of keys) {
    const response = await cache.match(request);
    const blob = await response.blob();
    const timestamp = response.headers.get('sw-cached-time') || '0';
    
    entries.push({
      request,
      size: blob.size,
      timestamp: parseInt(timestamp)
    });
  }
  
  // Sort by timestamp (oldest first)
  entries.sort((a, b) => a.timestamp - b.timestamp);
  
  let currentSize = entries.reduce((sum, e) => sum + e.size, 0);
  
  // Remove oldest entries until under quota
  for (const entry of entries) {
    if (currentSize <= maxSize) break;
    
    await cache.delete(entry.request);
    currentSize -= entry.size;
  }
}

// Run periodically
self.addEventListener('activate', event => {
  event.waitUntil(
    enforceQuota(50 * 1024 * 1024) // 50MB limit
  );
});
```

### Precaching Strategy

Loading critical resources during installation:

```javascript
const PRECACHE_URLS = [
  '/',
  '/index.html',
  '/styles/main.css',
  '/scripts/app.js',
  '/images/logo.png',
  '/fonts/roboto.woff2'
];

self.addEventListener('install', event => {
  event.waitUntil(
    caches.open(CACHE_NAME).then(cache => {
      return cache.addAll(PRECACHE_URLS);
    }).then(() => {
      return self.skipWaiting();
    })
  );
});

// Serve precached resources with cache-first strategy
self.addEventListener('fetch', event => {
  const url = new URL(event.request.url);
  
  if (PRECACHE_URLS.includes(url.pathname)) {
    event.respondWith(
      caches.match(event.request).then(cached => {
        return cached || fetch(event.request);
      })
    );
  }
});
```

### Runtime Caching

Dynamically caching resources as they're requested:

```javascript
const RUNTIME_CACHE = 'runtime-cache-v1';
const MAX_RUNTIME_ENTRIES = 50;

async function addToRuntimeCache(request, response) {
  const cache = await caches.open(RUNTIME_CACHE);
  
  // Enforce max entries
  const keys = await cache.keys();
  
  if (keys.length >= MAX_RUNTIME_ENTRIES) {
    // Remove first (oldest) entry
    await cache.delete(keys[0]);
  }
  
  await cache.put(request, response);
}

self.addEventListener('fetch', event => {
  // Skip non-GET requests
  if (event.request.method !== 'GET') {
    return;
  }
  
  event.respondWith(
    fetch(event.request)
      .then(response => {
        // Only cache successful responses
        if (response.status === 200) {
          addToRuntimeCache(event.request, response.clone());
        }
        return response;
      })
      .catch(() => {
        return caches.match(event.request);
      })
  );
});
```

### Offline Fallback

Serving fallback content when offline:

```javascript
const OFFLINE_PAGE = '/offline.html';
const OFFLINE_IMAGE = '/images/offline.png';

self.addEventListener('install', event => {
  event.waitUntil(
    caches.open(CACHE_NAME).then(cache => {
      return cache.addAll([OFFLINE_PAGE, OFFLINE_IMAGE]);
    })
  );
});

self.addEventListener('fetch', event => {
  event.respondWith(
    fetch(event.request)
      .catch(() => {
        return caches.match(event.request).then(cached => {
          if (cached) return cached;
          
          // Serve offline page for navigation requests
          if (event.request.mode === 'navigate') {
            return caches.match(OFFLINE_PAGE);
          }
          
          // Serve offline image for image requests
          if (event.request.destination === 'image') {
            return caches.match(OFFLINE_IMAGE);
          }
          
          // Return minimal response for other requests
          return new Response('Offline', {
            status: 503,
            statusText: 'Service Unavailable',
            headers: new Headers({
              'Content-Type': 'text/plain'
            })
          });
        });
      })
  );
});
```

### Cache Versioning and Migration

Managing multiple cache versions:

```javascript
const CACHE_CONFIG = {
  static: 'static-v1',
  dynamic: 'dynamic-v1',
  api: 'api-v1'
};

self.addEventListener('install', event => {
  event.waitUntil(
    Promise.all([
      caches.open(CACHE_CONFIG.static).then(cache => {
        return cache.addAll([
          '/index.html',
          '/styles.css',
          '/script.js'
        ]);
      }),
      caches.open(CACHE_CONFIG.dynamic),
      caches.open(CACHE_CONFIG.api)
    ])
  );
});

self.addEventListener('activate', event => {
  const validCaches = Object.values(CACHE_CONFIG);
  
  event.waitUntil(
    caches.keys().then(cacheNames => {
      return Promise.all(
        cacheNames
          .filter(name => !validCaches.includes(name))
          .map(name => caches.delete(name))
      );
    })
  );
});

self.addEventListener('fetch', event => {
  const url = new URL(event.request.url);
  
  // Route to appropriate cache
  if (url.pathname.startsWith('/api/')) {
    event.respondWith(handleApiRequest(event.request));
  } else if (url.pathname.match(/\.(css|js|png)$/)) {
    event.respondWith(handleStaticRequest(event.request));
  } else {
    event.respondWith(handleDynamicRequest(event.request));
  }
});

async function handleStaticRequest(request) {
  const cache = await caches.open(CACHE_CONFIG.static);
  const cached = await cache.match(request);
  return cached || fetch(request);
}

async function handleDynamicRequest(request) {
  const cache = await caches.open(CACHE_CONFIG.dynamic);
  
  try {
    const response = await fetch(request);
    cache.put(request, response.clone());
    return response;
  } catch (error) {
    return await cache.match(request);
  }
}

async function handleApiRequest(request) {
  const cache = await caches.open(CACHE_CONFIG.api);
  
  const fetchPromise = fetch(request).then(response => {
    if (response.ok) {
      cache.put(request, response.clone());
    }
    return response;
  });
  
  const cached = await cache.match(request);
  return cached || fetchPromise;
}
```

### Cache Warming

Preloading resources based on usage patterns:

```javascript
// Warm cache with likely next pages
async function warmCache(urls) {
  const cache = await caches.open(CACHE_NAME);
  
  for (const url of urls) {
    try {
      const response = await fetch(url);
      if (response.ok) {
        await cache.put(url, response);
      }
    } catch (error) {
      console.log(`Failed to warm cache for ${url}`);
    }
  }
}

self.addEventListener('message', event => {
  if (event.data.type === 'WARM_CACHE') {
    event.waitUntil(warmCache(event.data.urls));
  }
});

// In page context
navigator.serviceWorker.controller.postMessage({
  type: 'WARM_CACHE',
  urls: ['/page2.html', '/page3.html', '/data.json']
});
```

### Background Sync for Cache Updates

Updating cache when connectivity is restored:

```javascript
self.addEventListener('sync', event => {
  if (event.tag === 'update-cache') {
    event.waitUntil(updateCache());
  }
});

async function updateCache() {
  const cache = await caches.open(CACHE_NAME);
  const keys = await cache.keys();
  
  const updatePromises = keys.map(async request => {
    try {
      const response = await fetch(request);
      if (response.ok) {
        await cache.put(request, response);
      }
    } catch (error) {
      // Network error, skip update
    }
  });
  
  await Promise.all(updatePromises);
}

// Register sync from page
navigator.serviceWorker.ready.then(registration => {
  return registration.sync.register('update-cache');
});
```

### Cache Debugging and Inspection

Tools for monitoring cache state:

```javascript
// Expose cache inspection via message
self.addEventListener('message', async event => {
  if (event.data.type === 'GET_CACHE_INFO') {
    const cacheNames = await caches.keys();
    const info = {};
    
    for (const name of cacheNames) {
      const cache = await caches.open(name);
      const keys = await cache.keys();
      
      info[name] = {
        count: keys.length,
        urls: keys.map(req => req.url)
      };
    }
    
    event.ports[0].postMessage(info);
  }
  
  if (event.data.type === 'CLEAR_CACHE') {
    const cacheNames = await caches.keys();
    await Promise.all(cacheNames.map(name => caches.delete(name)));
    event.ports[0].postMessage({ success: true });
  }
});

// In page context
async function getCacheInfo() {
  const messageChannel = new MessageChannel();
  
  return new Promise(resolve => {
    messageChannel.port1.onmessage = event => {
      resolve(event.data);
    };
    
    navigator.serviceWorker.controller.postMessage(
      { type: 'GET_CACHE_INFO' },
      [messageChannel.port2]
    );
  });
}

async function clearAllCaches() {
  const messageChannel = new MessageChannel();
  
  return new Promise(resolve => {
    messageChannel.port1.onmessage = event => {
      resolve(event.data);
    };
    
    navigator.serviceWorker.controller.postMessage(
      { type: 'CLEAR_CACHE' },
      [messageChannel.port2]
    );
  });
}
```

### Cross-Origin Resource Caching

Handling CORS and opaque responses:

```javascript
self.addEventListener('fetch', event => {
  const url = new URL(event.request.url);
  
  // Cross-origin request
  if (url.origin !== self.location.origin) {
    event.respondWith(handleCrossOrigin(event.request));
    return;
  }
  
  // Same-origin request
  event.respondWith(handleSameOrigin(event.request));
});

async function handleCrossOrigin(request) {
  const cached = await caches.match(request);
  if (cached) return cached;
  
  try {
    // Opaque responses (no-cors mode)
    const response = await fetch(request, { mode: 'no-cors' });
    
    // Note: Cannot read opaque response details
    // response.status will be 0, response.ok will be false
    
    const cache = await caches.open(CACHE_NAME);
    await cache.put(request, response.clone());
    
    return response;
  } catch (error) {
    return cached || new Response('Network error', { status: 408 });
  }
}

async function handleSameOrigin(request) {
  try {
    const response = await fetch(request);
    
    if (response.ok) {
      const cache = await caches.open(CACHE_NAME);
      await cache.put(request, response.clone());
    }
    
    return response;
  } catch (error) {
    return await caches.match(request);
  }
}
```

### Selective Cache Invalidation

Removing specific cached resources:

```javascript
async function invalidateCache(pattern) {
  const cacheNames = await caches.keys();
  
  for (const name of cacheNames) {
    const cache = await caches.open(name);
    const requests = await cache.keys();
    
    for (const request of requests) {
      if (pattern.test(request.url)) {
        await cache.delete(request);
      }
    }
  }
}

self.addEventListener('message', event => {
  if (event.data.type === 'INVALIDATE_CACHE') {
    const pattern = new RegExp(event.data.pattern);
    event.waitUntil(invalidateCache(pattern));
  }
});

// Invalidate all API responses
navigator.serviceWorker.controller.postMessage({
  type: 'INVALIDATE_CACHE',
  pattern: '/api/'
});

// Invalidate specific resource
navigator.serviceWorker.controller.postMessage({
  type: 'INVALIDATE_CACHE',
  pattern: '/images/old-logo\\.png$'
});
```

### Cache Performance Monitoring

Tracking cache hit rates and performance:

```javascript
const cacheStats = {
  hits: 0,
  misses: 0,
  errors: 0
};

self.addEventListener('fetch', event => {
  event.respondWith(
    caches.match(event.request).then(cached => {
      if (cached) {
        cacheStats.hits++;
        return cached;
      }
      
      cacheStats.misses++;
      
      return fetch(event.request)
        .then(response => {
          const cache = caches.open(CACHE_NAME);
          cache.then(c => c.put(event.request, response.clone()));
          return response;
        })
        .catch(error => {
          cacheStats.errors++;
          throw error;
        });
    })
  );
});

self.addEventListener('message', event => {
  if (event.data.type === 'GET_STATS') {
    const total = cacheStats.hits + cacheStats.misses;
    const hitRate = total > 0 ? (cacheStats.hits / total * 100).toFixed(2) : 0;
    
    event.ports[0].postMessage({
      ...cacheStats,
      hitRate: `${hitRate}%`,
      total
    });
  }
  
  if (event.data.type === 'RESET_STATS') {
    cacheStats.hits = 0;
    cacheStats.misses = 0;
    cacheStats.errors = 0;
    event.ports[0].postMessage({ success: true });
  }
});
```

### Streamed Response Caching

Caching while streaming to client:

```javascript
async function cacheAndStream(request) {
  const response = await fetch(request);
  
  const cache = await caches.open(CACHE_NAME);
  
  // Create readable stream that tees the response
  const { readable, writable } = new TransformStream();
  
  const reader = response.body.getReader();
  const writer = writable.getWriter();
  const chunks = [];
  
  // Stream to both client and cache
  reader.read().then(function processChunk({ done, value }) {
    if (done) {
      writer.close();
      
      // Store complete response in cache
      const blob = new Blob(chunks);
      const cachedResponse = new Response(blob, {
        status: response.status,
        statusText: response.statusText,
        headers: response.headers
      });
      
      cache.put(request, cachedResponse);
      return;
    }
    
    chunks.push(value);
    writer.write(value);
    
    return reader.read().then(processChunk);
  });
  
  return new Response(readable, {
    status: response.status,
    statusText: response.statusText,
    headers: response.headers
  });
}
```

### Cache Prioritization

Prioritizing important resources:

```javascript
const CACHE_PRIORITIES = {
  critical: ['/', '/index.html', '/app.js', '/styles.css'],
  high: ['/images/logo.png', '/fonts/main.woff2'],
  medium: ['/api/user', '/api/settings'],
  low: ['/api/analytics', '/tracking.js']
};

async function enforcePriority() {
  const cache = await caches.open(CACHE_NAME);
  const requests = await cache.keys();
  
  // Calculate current cache size
  let totalSize = 0;
  const entries = [];
  
  for (const request of requests) {
    const response = await cache.match(request);
    const blob = await response.blob();
    const priority = getPriority(request.url);
    
    entries.push({
      request,
      size: blob.size,
      priority
    });
    
    totalSize += blob.size;
  }
  
  // If over quota, remove lowest priority items
  const MAX_SIZE = 50 * 1024 * 1024; // 50MB
  
  if (totalSize > MAX_SIZE) {
    entries.sort((a, b) => a.priority - b.priority);
    
    for (const entry of entries) {
      if (totalSize <= MAX_SIZE) break;
      
      if (entry.priority >= 3) { // Only remove low priority
        await cache.delete(entry.request);
        totalSize -= entry.size;
      }
    }
  }
}

function getPriority(url) {
  if (CACHE_PRIORITIES.critical.some(u => url.includes(u))) return 0;
  if (CACHE_PRIORITIES.high.some(u => url.includes(u))) return 1;
  if (CACHE_PRIORITIES.medium.some(u => url.includes(u))) return 2;
  return 3; // low priority
}
```

---

