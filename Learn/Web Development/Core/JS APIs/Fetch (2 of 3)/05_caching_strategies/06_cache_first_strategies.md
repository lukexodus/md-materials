## Cache-First Strategies


### Core Concept

Cache-first strategies prioritize serving resources from the cache before attempting network requests. The browser or service worker checks the cache first; only if the resource is not found does it fall back to the network. This approach optimizes for speed and offline functionality.

### Basic Cache-First Implementation

#### Service Worker Pattern

```javascript
self.addEventListener('fetch', (event) => {
  event.respondWith(
    caches.match(event.request)
      .then((cachedResponse) => {
        if (cachedResponse) {
          return cachedResponse;
        }
        return fetch(event.request);
      })
  );
});
```

#### With Cache Population

```javascript
self.addEventListener('fetch', (event) => {
  event.respondWith(
    caches.match(event.request)
      .then((cachedResponse) => {
        if (cachedResponse) {
          return cachedResponse;
        }
        
        return fetch(event.request).then((networkResponse) => {
          // Cache the network response for future requests
          return caches.open('dynamic-cache-v1').then((cache) => {
            cache.put(event.request, networkResponse.clone());
            return networkResponse;
          });
        });
      })
  );
});
```

### Strategy Variants

#### Cache-First with Network Fallback

The standard pattern where cache is always checked first:

```javascript
async function cacheFirst(request) {
  const cachedResponse = await caches.match(request);
  
  if (cachedResponse) {
    return cachedResponse;
  }
  
  try {
    const networkResponse = await fetch(request);
    
    if (networkResponse.ok) {
      const cache = await caches.open('runtime-cache');
      cache.put(request, networkResponse.clone());
    }
    
    return networkResponse;
  } catch (error) {
    // Network failed and no cache available
    return new Response('Network error occurred', {
      status: 408,
      headers: { 'Content-Type': 'text/plain' }
    });
  }
}

self.addEventListener('fetch', (event) => {
  event.respondWith(cacheFirst(event.request));
});
```

#### Cache-First with Timeout

Attempt network request if cache lookup takes too long:

```javascript
async function cacheFirstWithTimeout(request, timeout = 500) {
  const cachePromise = caches.match(request);
  const timeoutPromise = new Promise((resolve) => {
    setTimeout(() => resolve(null), timeout);
  });
  
  const cachedResponse = await Promise.race([
    cachePromise,
    timeoutPromise
  ]);
  
  if (cachedResponse) {
    return cachedResponse;
  }
  
  // Cache lookup timed out or returned nothing
  const networkResponse = await fetch(request);
  
  if (networkResponse.ok) {
    const cache = await caches.open('runtime-cache');
    cache.put(request, networkResponse.clone());
  }
  
  return networkResponse;
}
```

#### Cache-First with Background Update (Stale-While-Revalidate)

Return cached content immediately while updating cache in background:

```javascript
async function cacheFirstBackgroundUpdate(request) {
  const cachedResponse = await caches.match(request);
  
  // Initiate background fetch
  const fetchPromise = fetch(request).then((networkResponse) => {
    if (networkResponse.ok) {
      caches.open('dynamic-cache').then((cache) => {
        cache.put(request, networkResponse.clone());
      });
    }
    return networkResponse;
  });
  
  // Return cached version immediately, or wait for network
  return cachedResponse || fetchPromise;
}
```

### Selective Caching Strategies

#### By Resource Type

```javascript
self.addEventListener('fetch', (event) => {
  const { request } = event;
  const url = new URL(request.url);
  
  // Images: cache-first with long TTL
  if (request.destination === 'image') {
    event.respondWith(cacheFirstImage(request));
  }
  // Scripts and styles: cache-first with versioning
  else if (request.destination === 'script' || request.destination === 'style') {
    event.respondWith(cacheFirstAsset(request));
  }
  // API calls: network-first
  else if (url.pathname.startsWith('/api/')) {
    event.respondWith(networkFirst(request));
  }
  // Everything else: cache-first
  else {
    event.respondWith(cacheFirst(request));
  }
});
```

#### By URL Pattern

```javascript
const CACHE_STRATEGIES = {
  static: /\.(js|css|png|jpg|jpeg|svg|gif|woff2?)$/,
  api: /\/api\//,
  pages: /\.(html|htm)$/
};

self.addEventListener('fetch', (event) => {
  const url = new URL(event.request.url);
  
  if (CACHE_STRATEGIES.static.test(url.pathname)) {
    event.respondWith(cacheFirstLongTerm(event.request));
  } else if (CACHE_STRATEGIES.api.test(url.pathname)) {
    event.respondWith(networkFirstWithCache(event.request));
  } else if (CACHE_STRATEGIES.pages.test(url.pathname)) {
    event.respondWith(cacheFirstWithUpdate(event.request));
  } else {
    event.respondWith(fetch(event.request));
  }
});
```

### Cache Expiration and Freshness

#### Time-Based Expiration

```javascript
const CACHE_DURATION = 24 * 60 * 60 * 1000; // 24 hours

async function cacheFirstWithExpiration(request) {
  const cache = await caches.open('timed-cache');
  const cachedResponse = await cache.match(request);
  
  if (cachedResponse) {
    const cachedDate = new Date(cachedResponse.headers.get('sw-cached-date'));
    const now = new Date();
    
    if (now - cachedDate < CACHE_DURATION) {
      return cachedResponse;
    }
    
    // Cache expired, delete and fetch fresh
    await cache.delete(request);
  }
  
  const networkResponse = await fetch(request);
  
  if (networkResponse.ok) {
    const responseToCache = networkResponse.clone();
    const headers = new Headers(responseToCache.headers);
    headers.append('sw-cached-date', new Date().toISOString());
    
    const responseWithDate = new Response(responseToCache.body, {
      status: responseToCache.status,
      statusText: responseToCache.statusText,
      headers: headers
    });
    
    await cache.put(request, responseWithDate);
  }
  
  return networkResponse;
}
```

#### ETag-Based Validation

```javascript
async function cacheFirstWithETag(request) {
  const cache = await caches.open('etag-cache');
  const cachedResponse = await cache.match(request);
  
  if (cachedResponse) {
    const etag = cachedResponse.headers.get('etag');
    
    if (etag) {
      // Send conditional request
      const conditionalRequest = new Request(request, {
        headers: {
          'If-None-Match': etag
        }
      });
      
      try {
        const networkResponse = await fetch(conditionalRequest);
        
        if (networkResponse.status === 304) {
          // Not modified, return cached version
          return cachedResponse;
        }
        
        // Modified, cache new version
        if (networkResponse.ok) {
          await cache.put(request, networkResponse.clone());
        }
        
        return networkResponse;
      } catch (error) {
        // Network error, return cached version
        return cachedResponse;
      }
    }
    
    return cachedResponse;
  }
  
  // No cache, fetch from network
  const networkResponse = await fetch(request);
  
  if (networkResponse.ok) {
    await cache.put(request, networkResponse.clone());
  }
  
  return networkResponse;
}
```

### Cache Management

#### Size-Limited Cache

```javascript
class CacheManager {
  constructor(cacheName, maxItems = 50) {
    this.cacheName = cacheName;
    this.maxItems = maxItems;
  }
  
  async put(request, response) {
    const cache = await caches.open(this.cacheName);
    await cache.put(request, response);
    await this.trimCache();
  }
  
  async trimCache() {
    const cache = await caches.open(this.cacheName);
    const keys = await cache.keys();
    
    if (keys.length > this.maxItems) {
      // Remove oldest entries (FIFO)
      const keysToDelete = keys.slice(0, keys.length - this.maxItems);
      
      await Promise.all(
        keysToDelete.map(key => cache.delete(key))
      );
    }
  }
  
  async match(request) {
    const cache = await caches.open(this.cacheName);
    return cache.match(request);
  }
}

const imageCache = new CacheManager('images-v1', 100);

async function cacheFirstManagedSize(request) {
  const cachedResponse = await imageCache.match(request);
  
  if (cachedResponse) {
    return cachedResponse;
  }
  
  const networkResponse = await fetch(request);
  
  if (networkResponse.ok) {
    await imageCache.put(request, networkResponse.clone());
  }
  
  return networkResponse;
}
```

#### LRU Cache Implementation

```javascript
class LRUCache {
  constructor(cacheName, maxItems = 50) {
    this.cacheName = cacheName;
    this.maxItems = maxItems;
    this.accessLog = [];
  }
  
  async match(request) {
    const cache = await caches.open(this.cacheName);
    const response = await cache.match(request);
    
    if (response) {
      // Update access order
      const url = request.url || request;
      this.accessLog = this.accessLog.filter(u => u !== url);
      this.accessLog.push(url);
    }
    
    return response;
  }
  
  async put(request, response) {
    const cache = await caches.open(this.cacheName);
    const url = request.url || request;
    
    await cache.put(request, response);
    
    this.accessLog = this.accessLog.filter(u => u !== url);
    this.accessLog.push(url);
    
    await this.trimCache(cache);
  }
  
  async trimCache(cache) {
    const keys = await cache.keys();
    
    if (keys.length > this.maxItems) {
      const urlsToKeep = new Set(
        this.accessLog.slice(-this.maxItems)
      );
      
      const keysToDelete = keys.filter(
        key => !urlsToKeep.has(key.url)
      );
      
      await Promise.all(
        keysToDelete.map(key => cache.delete(key))
      );
    }
  }
}
```

### Offline-First Patterns

#### Complete Offline Support

```javascript
const STATIC_CACHE = 'static-v1';
const DYNAMIC_CACHE = 'dynamic-v1';

const STATIC_ASSETS = [
  '/',
  '/index.html',
  '/styles/main.css',
  '/scripts/app.js',
  '/offline.html'
];

self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(STATIC_CACHE)
      .then((cache) => cache.addAll(STATIC_ASSETS))
  );
});

self.addEventListener('fetch', (event) => {
  event.respondWith(
    caches.match(event.request)
      .then((cachedResponse) => {
        if (cachedResponse) {
          return cachedResponse;
        }
        
        return fetch(event.request)
          .then((networkResponse) => {
            // Only cache successful GET requests
            if (event.request.method === 'GET' && networkResponse.ok) {
              const responseToCache = networkResponse.clone();
              
              caches.open(DYNAMIC_CACHE)
                .then((cache) => {
                  cache.put(event.request, responseToCache);
                });
            }
            
            return networkResponse;
          })
          .catch(() => {
            // Network failed, return offline page for navigation requests
            if (event.request.mode === 'navigate') {
              return caches.match('/offline.html');
            }
          });
      })
  );
});
```

#### Offline Queue for Mutations

```javascript
class OfflineQueue {
  constructor() {
    this.queue = [];
    this.storageKey = 'offline-queue';
    this.loadQueue();
  }
  
  async loadQueue() {
    const stored = await this.getFromStorage();
    this.queue = stored || [];
  }
  
  async add(request) {
    const requestData = {
      url: request.url,
      method: request.method,
      headers: Object.fromEntries(request.headers.entries()),
      body: await request.text(),
      timestamp: Date.now()
    };
    
    this.queue.push(requestData);
    await this.saveQueue();
  }
  
  async process() {
    const failedRequests = [];
    
    for (const requestData of this.queue) {
      try {
        const response = await fetch(requestData.url, {
          method: requestData.method,
          headers: requestData.headers,
          body: requestData.body
        });
        
        if (!response.ok) {
          failedRequests.push(requestData);
        }
      } catch (error) {
        failedRequests.push(requestData);
      }
    }
    
    this.queue = failedRequests;
    await this.saveQueue();
    
    return this.queue.length === 0;
  }
  
  async saveQueue() {
    await this.saveToStorage(this.queue);
  }
  
  async getFromStorage() {
    const data = await caches.open('queue-storage')
      .then(cache => cache.match(this.storageKey))
      .then(response => response ? response.json() : null);
    return data;
  }
  
  async saveToStorage(data) {
    const response = new Response(JSON.stringify(data));
    const cache = await caches.open('queue-storage');
    await cache.put(this.storageKey, response);
  }
}

const offlineQueue = new OfflineQueue();

self.addEventListener('fetch', (event) => {
  if (event.request.method !== 'GET') {
    event.respondWith(
      fetch(event.request).catch(() => {
        offlineQueue.add(event.request.clone());
        return new Response(JSON.stringify({ queued: true }), {
          headers: { 'Content-Type': 'application/json' }
        });
      })
    );
  }
});

self.addEventListener('online', () => {
  offlineQueue.process();
});
```

### Performance Optimization

#### Parallel Cache and Network

Race cache against network, return whichever completes first:

```javascript
async function raceStrategy(request) {
  return new Promise((resolve, reject) => {
    let resolved = false;
    
    const maybeResolve = (response) => {
      if (!resolved) {
        resolved = true;
        resolve(response);
      }
    };
    
    const maybeReject = (error) => {
      if (!resolved) {
        resolved = true;
        reject(error);
      }
    };
    
    // Try cache
    caches.match(request)
      .then(cachedResponse => {
        if (cachedResponse) {
          maybeResolve(cachedResponse);
        }
      })
      .catch(() => {});
    
    // Try network
    fetch(request)
      .then(networkResponse => {
        maybeResolve(networkResponse);
        
        if (networkResponse.ok) {
          caches.open('race-cache').then(cache => {
            cache.put(request, networkResponse.clone());
          });
        }
      })
      .catch(maybeReject);
  });
}
```

#### Prefetch Critical Resources

```javascript
self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open('prefetch-v1').then(async (cache) => {
      // Prefetch critical resources
      const criticalResources = [
        '/api/user/profile',
        '/api/content/featured',
        '/api/navigation/menu'
      ];
      
      const responses = await Promise.allSettled(
        criticalResources.map(url => fetch(url))
      );
      
      responses.forEach((result, index) => {
        if (result.status === 'fulfilled' && result.value.ok) {
          cache.put(criticalResources[index], result.value);
        }
      });
    })
  );
});
```

### Advanced Patterns

#### Cache Hierarchy

Multiple cache layers with different priorities:

```javascript
const CACHE_HIERARCHY = [
  'critical-v1',    // Always available
  'frequent-v1',    // Often used
  'occasional-v1'   // Sometimes used
];

async function hierarchicalCache(request) {
  // Check each cache level
  for (const cacheName of CACHE_HIERARCHY) {
    const cache = await caches.open(cacheName);
    const response = await cache.match(request);
    
    if (response) {
      return response;
    }
  }
  
  // Not in any cache, fetch from network
  const networkResponse = await fetch(request);
  
  if (networkResponse.ok) {
    // Determine cache level based on usage pattern
    const cacheLevel = determineCacheLevel(request);
    const cache = await caches.open(cacheLevel);
    await cache.put(request, networkResponse.clone());
  }
  
  return networkResponse;
}

function determineCacheLevel(request) {
  // [Inference] Logic to determine appropriate cache level
  // based on URL patterns, content type, or usage statistics
  
  if (request.destination === 'script' || request.destination === 'style') {
    return 'critical-v1';
  } else if (request.destination === 'image') {
    return 'frequent-v1';
  }
  return 'occasional-v1';
}
```

#### Versioned Cache Strategy

```javascript
const VERSION = '1.0.0';
const CACHE_NAME = `app-cache-${VERSION}`;

self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys().then((cacheNames) => {
      return Promise.all(
        cacheNames
          .filter((name) => name.startsWith('app-cache-') && name !== CACHE_NAME)
          .map((name) => caches.delete(name))
      );
    })
  );
});

async function versionedCacheFirst(request) {
  const cachedResponse = await caches.match(request);
  
  if (cachedResponse) {
    const cacheVersion = cachedResponse.headers.get('x-cache-version');
    
    if (cacheVersion === VERSION) {
      return cachedResponse;
    }
    
    // Version mismatch, delete old cache entry
    const cache = await caches.open(CACHE_NAME);
    await cache.delete(request);
  }
  
  const networkResponse = await fetch(request);
  
  if (networkResponse.ok) {
    const cache = await caches.open(CACHE_NAME);
    const headers = new Headers(networkResponse.headers);
    headers.append('x-cache-version', VERSION);
    
    const versionedResponse = new Response(networkResponse.body, {
      status: networkResponse.status,
      statusText: networkResponse.statusText,
      headers: headers
    });
    
    await cache.put(request, versionedResponse);
    return networkResponse;
  }
  
  return networkResponse;
}
```

---

