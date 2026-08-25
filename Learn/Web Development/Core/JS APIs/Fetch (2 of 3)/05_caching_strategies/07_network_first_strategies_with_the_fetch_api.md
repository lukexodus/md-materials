## Network-First Strategies with the Fetch API


### Core Concept

Network-first strategies prioritize fetching fresh data from the network, falling back to cached data only when the network is unavailable or fails. This approach ensures users receive the most current data while maintaining offline functionality. The strategy is particularly valuable for dynamic content, API responses, and resources where freshness is critical.

### Basic Network-First Implementation

```javascript
async function networkFirst(request) {
  try {
    const networkResponse = await fetch(request);
    
    if (networkResponse.ok) {
      // Cache the successful response
      const cache = await caches.open('dynamic-v1');
      cache.put(request, networkResponse.clone());
      return networkResponse;
    }
    
    // If network response is not ok, try cache
    return await caches.match(request) || networkResponse;
  } catch (error) {
    // Network failed, try cache
    const cachedResponse = await caches.match(request);
    
    if (cachedResponse) {
      return cachedResponse;
    }
    
    // No cache available, return error response
    return new Response('Network error and no cache available', {
      status: 503,
      statusText: 'Service Unavailable'
    });
  }
}
```

### Network-First with Timeout

Prevent waiting too long for slow network responses:

```javascript
async function networkFirstWithTimeout(request, timeout = 3000) {
  const timeoutPromise = new Promise((_, reject) => {
    setTimeout(() => reject(new Error('Network timeout')), timeout);
  });
  
  try {
    const networkResponse = await Promise.race([
      fetch(request),
      timeoutPromise
    ]);
    
    if (networkResponse.ok) {
      const cache = await caches.open('dynamic-v1');
      cache.put(request, networkResponse.clone());
    }
    
    return networkResponse;
  } catch (error) {
    console.log('Network failed or timed out, using cache');
    
    const cachedResponse = await caches.match(request);
    
    if (cachedResponse) {
      return cachedResponse;
    }
    
    return new Response(JSON.stringify({ error: 'No connection' }), {
      status: 408,
      statusText: 'Request Timeout',
      headers: { 'Content-Type': 'application/json' }
    });
  }
}
```

### Service Worker Integration

Implement network-first in a service worker for comprehensive offline support:

```javascript
// service-worker.js
const CACHE_NAME = 'network-first-v1';
const TIMEOUT = 5000;

self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME).then((cache) => {
      return cache.addAll([
        '/offline.html',
        '/offline.css'
      ]);
    })
  );
});

self.addEventListener('fetch', (event) => {
  // Apply network-first to API requests
  if (event.request.url.includes('/api/')) {
    event.respondWith(networkFirstStrategy(event.request));
  }
});

async function networkFirstStrategy(request) {
  const cache = await caches.open(CACHE_NAME);
  
  try {
    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), TIMEOUT);
    
    const networkResponse = await fetch(request, {
      signal: controller.signal
    });
    
    clearTimeout(timeoutId);
    
    if (networkResponse.ok) {
      cache.put(request, networkResponse.clone());
    }
    
    return networkResponse;
  } catch (error) {
    console.log('Fetching from cache:', request.url);
    
    const cachedResponse = await cache.match(request);
    
    if (cachedResponse) {
      return cachedResponse;
    }
    
    // Return offline page for navigation requests
    if (request.mode === 'navigate') {
      return cache.match('/offline.html');
    }
    
    return new Response(
      JSON.stringify({ 
        error: 'Network unavailable',
        cached: false 
      }),
      {
        status: 503,
        headers: { 'Content-Type': 'application/json' }
      }
    );
  }
}
```

### Conditional Network-First

Apply network-first selectively based on request characteristics:

```javascript
class ConditionalNetworkFirst {
  constructor(config = {}) {
    this.cacheName = config.cacheName || 'conditional-cache-v1';
    this.timeout = config.timeout || 5000;
    this.maxAge = config.maxAge || 3600000; // 1 hour default
  }
  
  shouldUseNetworkFirst(request) {
    const url = new URL(request.url);
    
    // Always use network-first for:
    // - POST/PUT/DELETE requests
    // - URLs with query parameters indicating freshness needed
    // - Specific paths
    
    if (request.method !== 'GET') {
      return true;
    }
    
    if (url.searchParams.has('nocache')) {
      return true;
    }
    
    const freshPaths = ['/api/live/', '/api/realtime/', '/api/current/'];
    return freshPaths.some(path => url.pathname.includes(path));
  }
  
  async fetch(request) {
    if (!this.shouldUseNetworkFirst(request)) {
      // Use cache-first for other requests
      return this.cacheFirst(request);
    }
    
    return this.networkFirst(request);
  }
  
  async networkFirst(request) {
    try {
      const controller = new AbortController();
      const timeoutId = setTimeout(() => controller.abort(), this.timeout);
      
      const response = await fetch(request, {
        signal: controller.signal
      });
      
      clearTimeout(timeoutId);
      
      if (response.ok) {
        await this.updateCache(request, response.clone());
      }
      
      return response;
    } catch (error) {
      const cached = await this.getCached(request);
      
      if (cached) {
        return this.addStaleHeader(cached);
      }
      
      throw error;
    }
  }
  
  async cacheFirst(request) {
    const cached = await this.getCached(request);
    
    if (cached && !this.isExpired(cached)) {
      return cached;
    }
    
    try {
      const response = await fetch(request);
      
      if (response.ok) {
        await this.updateCache(request, response.clone());
      }
      
      return response;
    } catch (error) {
      if (cached) {
        return this.addStaleHeader(cached);
      }
      throw error;
    }
  }
  
  async updateCache(request, response) {
    const cache = await caches.open(this.cacheName);
    const metadata = {
      timestamp: Date.now(),
      headers: Object.fromEntries(response.headers.entries())
    };
    
    // Store metadata separately
    await cache.put(
      this.getMetadataKey(request),
      new Response(JSON.stringify(metadata))
    );
    
    await cache.put(request, response);
  }
  
  async getCached(request) {
    const cache = await caches.open(this.cacheName);
    return cache.match(request);
  }
  
  async isExpired(response) {
    const cache = await caches.open(this.cacheName);
    const metadataResponse = await cache.match(
      this.getMetadataKey(response.url)
    );
    
    if (!metadataResponse) return true;
    
    const metadata = await metadataResponse.json();
    const age = Date.now() - metadata.timestamp;
    
    return age > this.maxAge;
  }
  
  getMetadataKey(request) {
    const url = typeof request === 'string' ? request : request.url;
    return `${url}__metadata__`;
  }
  
  addStaleHeader(response) {
    const headers = new Headers(response.headers);
    headers.set('X-Cache-Status', 'stale');
    
    return new Response(response.body, {
      status: response.status,
      statusText: response.statusText,
      headers
    });
  }
}

// Usage
const fetcher = new ConditionalNetworkFirst({
  timeout: 3000,
  maxAge: 600000 // 10 minutes
});

const response = await fetcher.fetch(new Request('/api/data'));
```

### Background Sync for Failed Requests

Queue failed network requests for retry when connection is restored:

```javascript
// service-worker.js
const QUEUE_NAME = 'failed-requests';

self.addEventListener('sync', (event) => {
  if (event.tag === 'retry-failed-requests') {
    event.waitUntil(retryFailedRequests());
  }
});

async function networkFirstWithQueue(request) {
  try {
    const response = await fetch(request.clone());
    
    if (response.ok) {
      const cache = await caches.open('dynamic-v1');
      cache.put(request, response.clone());
    }
    
    return response;
  } catch (error) {
    // Queue for background sync
    await queueRequest(request);
    
    // Try cache
    const cached = await caches.match(request);
    
    if (cached) {
      return addQueuedHeader(cached);
    }
    
    return new Response(JSON.stringify({
      error: 'Request queued for retry',
      queued: true
    }), {
      status: 202,
      headers: { 'Content-Type': 'application/json' }
    });
  }
}

async function queueRequest(request) {
  const cache = await caches.open(QUEUE_NAME);
  const queuedRequest = {
    url: request.url,
    method: request.method,
    headers: Object.fromEntries(request.headers.entries()),
    body: request.method !== 'GET' ? await request.text() : null,
    timestamp: Date.now()
  };
  
  await cache.put(
    new Request(request.url + '__queued__' + Date.now()),
    new Response(JSON.stringify(queuedRequest))
  );
  
  // Register background sync
  if ('sync' in self.registration) {
    await self.registration.sync.register('retry-failed-requests');
  }
}

async function retryFailedRequests() {
  const cache = await caches.open(QUEUE_NAME);
  const requests = await cache.keys();
  
  for (const request of requests) {
    try {
      const response = await cache.match(request);
      const queuedRequest = await response.json();
      
      const retryResponse = await fetch(queuedRequest.url, {
        method: queuedRequest.method,
        headers: queuedRequest.headers,
        body: queuedRequest.body
      });
      
      if (retryResponse.ok) {
        await cache.delete(request);
        
        // Send message to client about successful retry
        const clients = await self.clients.matchAll();
        clients.forEach(client => {
          client.postMessage({
            type: 'request-retry-success',
            url: queuedRequest.url
          });
        });
      }
    } catch (error) {
      console.log('Retry failed, will try again later');
    }
  }
}

function addQueuedHeader(response) {
  const headers = new Headers(response.headers);
  headers.set('X-Request-Status', 'queued');
  
  return new Response(response.body, {
    status: response.status,
    statusText: response.statusText,
    headers
  });
}
```

### Stale-While-Revalidate Pattern

Return cached content immediately while fetching fresh data in the background:

```javascript
async function staleWhileRevalidate(request) {
  const cache = await caches.open('swr-cache-v1');
  const cachedResponse = await cache.match(request);
  
  // Fetch fresh data in background
  const fetchPromise = fetch(request).then(async (response) => {
    if (response.ok) {
      await cache.put(request, response.clone());
    }
    return response;
  }).catch(() => null);
  
  // Return cached immediately if available
  if (cachedResponse) {
    // Don't await - let it update in background
    fetchPromise;
    return cachedResponse;
  }
  
  // No cache, wait for network
  return fetchPromise || new Response('Not available', { status: 503 });
}
```

### Network-First with Race Condition

Race between network and cache after timeout:

```javascript
async function networkFirstRace(request, fastTimeout = 1000) {
  const cache = await caches.open('race-cache-v1');
  
  const networkPromise = fetch(request).then(async (response) => {
    if (response.ok) {
      await cache.put(request, response.clone());
    }
    return { source: 'network', response };
  });
  
  const timeoutPromise = new Promise((resolve) => {
    setTimeout(async () => {
      const cached = await cache.match(request);
      if (cached) {
        resolve({ source: 'cache', response: cached });
      }
    }, fastTimeout);
  });
  
  try {
    // Race between network and timeout
    const result = await Promise.race([
      networkPromise,
      timeoutPromise
    ].filter(Boolean));
    
    if (result.response) {
      return result.response;
    }
    
    // If race didn't produce result, wait for network
    const networkResult = await networkPromise;
    return networkResult.response;
  } catch (error) {
    const cached = await cache.match(request);
    
    if (cached) {
      return cached;
    }
    
    throw error;
  }
}
```

### Adaptive Timeout Strategy

Adjust timeout based on historical performance:

```javascript
class AdaptiveNetworkFirst {
  constructor() {
    this.cacheName = 'adaptive-cache-v1';
    this.performanceCache = new Map();
    this.defaultTimeout = 3000;
    this.minTimeout = 1000;
    this.maxTimeout = 10000;
  }
  
  getAdaptiveTimeout(url) {
    const urlKey = new URL(url).pathname;
    const history = this.performanceCache.get(urlKey) || [];
    
    if (history.length === 0) {
      return this.defaultTimeout;
    }
    
    // Calculate average response time
    const avg = history.reduce((sum, time) => sum + time, 0) / history.length;
    
    // Add buffer (1.5x average)
    const timeout = Math.min(
      Math.max(avg * 1.5, this.minTimeout),
      this.maxTimeout
    );
    
    return Math.round(timeout);
  }
  
  recordPerformance(url, duration) {
    const urlKey = new URL(url).pathname;
    const history = this.performanceCache.get(urlKey) || [];
    
    history.push(duration);
    
    // Keep last 10 measurements
    if (history.length > 10) {
      history.shift();
    }
    
    this.performanceCache.set(urlKey, history);
  }
  
  async fetch(request) {
    const url = request.url;
    const timeout = this.getAdaptiveTimeout(url);
    const startTime = performance.now();
    
    try {
      const controller = new AbortController();
      const timeoutId = setTimeout(() => controller.abort(), timeout);
      
      const response = await fetch(request, {
        signal: controller.signal
      });
      
      clearTimeout(timeoutId);
      
      const duration = performance.now() - startTime;
      this.recordPerformance(url, duration);
      
      if (response.ok) {
        const cache = await caches.open(this.cacheName);
        await cache.put(request, response.clone());
      }
      
      return response;
    } catch (error) {
      const cache = await caches.open(this.cacheName);
      const cached = await cache.match(request);
      
      if (cached) {
        return cached;
      }
      
      throw error;
    }
  }
}

// Usage
const adaptiveFetcher = new AdaptiveNetworkFirst();
const response = await adaptiveFetcher.fetch(new Request('/api/data'));
```

### Priority-Based Network-First

Handle multiple concurrent requests with priority:

```javascript
class PriorityNetworkFirst {
  constructor() {
    this.cacheName = 'priority-cache-v1';
    this.requestQueue = [];
    this.activeRequests = new Map();
    this.maxConcurrent = 4;
    this.processing = false;
  }
  
  async fetch(request, priority = 'normal') {
    return new Promise((resolve, reject) => {
      this.requestQueue.push({
        request,
        priority,
        resolve,
        reject,
        timestamp: Date.now()
      });
      
      this.requestQueue.sort((a, b) => {
        const priorityOrder = { high: 0, normal: 1, low: 2 };
        return priorityOrder[a.priority] - priorityOrder[b.priority];
      });
      
      this.processQueue();
    });
  }
  
  async processQueue() {
    if (this.processing) return;
    this.processing = true;
    
    while (this.requestQueue.length > 0 && 
           this.activeRequests.size < this.maxConcurrent) {
      const item = this.requestQueue.shift();
      this.executeRequest(item);
    }
    
    this.processing = false;
  }
  
  async executeRequest({ request, resolve, reject, timestamp }) {
    const requestId = `${request.url}-${timestamp}`;
    this.activeRequests.set(requestId, true);
    
    try {
      const response = await this.networkFirst(request);
      resolve(response);
    } catch (error) {
      reject(error);
    } finally {
      this.activeRequests.delete(requestId);
      this.processQueue();
    }
  }
  
  async networkFirst(request) {
    try {
      const response = await fetch(request);
      
      if (response.ok) {
        const cache = await caches.open(this.cacheName);
        await cache.put(request, response.clone());
      }
      
      return response;
    } catch (error) {
      const cache = await caches.open(this.cacheName);
      const cached = await cache.match(request);
      
      if (cached) {
        return cached;
      }
      
      throw error;
    }
  }
}

// Usage
const priorityFetcher = new PriorityNetworkFirst();

// High priority request
const criticalData = priorityFetcher.fetch(
  new Request('/api/critical'),
  'high'
);

// Normal priority
const normalData = priorityFetcher.fetch(
  new Request('/api/data'),
  'normal'
);

// Low priority
const backgroundData = priorityFetcher.fetch(
  new Request('/api/background'),
  'low'
);
```

### Network-First with Partial Response

Return partial cached data while waiting for network:

```javascript
async function networkFirstWithPartial(request) {
  const cache = await caches.open('partial-cache-v1');
  const cached = await cache.match(request);
  
  if (cached) {
    // Return cached data with indicator
    const cachedData = await cached.json();
    
    // Send partial response immediately
    const partialResponse = new Response(
      JSON.stringify({
        data: cachedData,
        partial: true,
        loading: true
      }),
      {
        headers: {
          'Content-Type': 'application/json',
          'X-Cache-Status': 'partial'
        }
      }
    );
    
    // Fetch fresh data in background
    fetch(request).then(async (response) => {
      if (response.ok) {
        await cache.put(request, response.clone());
        
        // Notify about fresh data via BroadcastChannel
        const channel = new BroadcastChannel('data-updates');
        const freshData = await response.json();
        channel.postMessage({
          url: request.url,
          data: freshData
        });
      }
    }).catch(() => {});
    
    return partialResponse;
  }
  
  // No cache, wait for network
  const response = await fetch(request);
  
  if (response.ok) {
    await cache.put(request, response.clone());
  }
  
  return response;
}

// Client-side listener
const channel = new BroadcastChannel('data-updates');
channel.addEventListener('message', (event) => {
  console.log('Fresh data received:', event.data);
  // Update UI with fresh data
});
```

### Connection-Aware Strategy

Adapt behavior based on connection quality:

```javascript
class ConnectionAwareNetworkFirst {
  constructor() {
    this.cacheName = 'connection-aware-v1';
  }
  
  getConnectionQuality() {
    const connection = navigator.connection;
    
    if (!connection) {
      return 'unknown';
    }
    
    const effectiveType = connection.effectiveType;
    const saveData = connection.saveData;
    
    if (saveData) {
      return 'save-data';
    }
    
    switch (effectiveType) {
      case 'slow-2g':
      case '2g':
        return 'poor';
      case '3g':
        return 'moderate';
      case '4g':
        return 'good';
      default:
        return 'unknown';
    }
  }
  
  async fetch(request) {
    const quality = this.getConnectionQuality();
    
    switch (quality) {
      case 'poor':
      case 'save-data':
        return this.cacheFirst(request);
      
      case 'moderate':
        return this.networkFirstWithShortTimeout(request, 2000);
      
      case 'good':
      case 'unknown':
      default:
        return this.networkFirst(request, 5000);
    }
  }
  
  async networkFirst(request, timeout) {
    try {
      const controller = new AbortController();
      const timeoutId = setTimeout(() => controller.abort(), timeout);
      
      const response = await fetch(request, {
        signal: controller.signal
      });
      
      clearTimeout(timeoutId);
      
      if (response.ok) {
        const cache = await caches.open(this.cacheName);
        await cache.put(request, response.clone());
      }
      
      return response;
    } catch (error) {
      return this.fallbackToCache(request);
    }
  }
  
  async networkFirstWithShortTimeout(request, timeout) {
    return this.networkFirst(request, timeout);
  }
  
  async cacheFirst(request) {
    const cache = await caches.open(this.cacheName);
    const cached = await cache.match(request);
    
    if (cached) {
      // Update cache in background
      fetch(request).then(response => {
        if (response.ok) {
          cache.put(request, response.clone());
        }
      }).catch(() => {});
      
      return cached;
    }
    
    return fetch(request);
  }
  
  async fallbackToCache(request) {
    const cache = await caches.open(this.cacheName);
    const cached = await cache.match(request);
    
    if (cached) {
      return cached;
    }
    
    return new Response('Network unavailable', { status: 503 });
  }
}

// Usage with connection monitoring
const fetcher = new ConnectionAwareNetworkFirst();

navigator.connection?.addEventListener('change', () => {
  console.log('Connection changed:', fetcher.getConnectionQuality());
});

const response = await fetcher.fetch(new Request('/api/data'));
```

### Metrics and Monitoring

Track network-first strategy performance:

```javascript
class MonitoredNetworkFirst {
  constructor() {
    this.cacheName = 'monitored-cache-v1';
    this.metrics = {
      networkHits: 0,
      cacheHits: 0,
      failures: 0,
      averageNetworkTime: 0,
      timeouts: 0
    };
  }
  
  async fetch(request, timeout = 5000) {
    const startTime = performance.now();
    
    try {
      const controller = new AbortController();
      const timeoutId = setTimeout(() => {
        controller.abort();
        this.metrics.timeouts++;
      }, timeout);
      
      const response = await fetch(request, {
        signal: controller.signal
      });
      
      clearTimeout(timeoutId);
      
      const duration = performance.now() - startTime;
      this.updateNetworkMetrics(duration);
      
      if (response.ok) {
        this.metrics.networkHits++;
        const cache = await caches.open(this.cacheName);
        await cache.put(request, response.clone());
      }
      
      return response;
    } catch (error) {
      this.metrics.failures++;
      
      const cache = await caches.open(this.cacheName);
      const cached = await cache.match(request);
      
      if (cached) {
        this.metrics.cacheHits++;
        return cached;
      }
      
      throw error;
    }
  }
  
  updateNetworkMetrics(duration) {
    const total = this.metrics.networkHits + 1;
    this.metrics.averageNetworkTime = 
      (this.metrics.averageNetworkTime * (total - 1) + duration) / total;
  }
  
  getMetrics() {
    const total = this.metrics.networkHits + this.metrics.cacheHits;
    
    return {
      ...this.metrics,
      cacheHitRate: total > 0 ? this.metrics.cacheHits / total : 0,
      failureRate: total > 0 ? this.metrics.failures / total : 0
    };
  }
  
  resetMetrics() {
    this.metrics = {
      networkHits: 0,
      cacheHits: 0,
      failures: 0,
      averageNetworkTime: 0,
      timeouts: 0
    };
  }
}

// Usage
const monitoredFetcher = new MonitoredNetworkFirst();

// Make requests
await monitoredFetcher.fetch(new Request('/api/data1'));
await monitoredFetcher.fetch(new Request('/api/data2'));

// Check metrics
console.log(monitoredFetcher.getMetrics());
// {
//   networkHits: 2,
//   cacheHits: 0,
//   failures: 0,
//   averageNetworkTime: 245.5,
//   timeouts: 0,
//   cacheHitRate: 0,
//   failureRate: 0
// }
```

### Best Practices Summary

Set appropriate timeouts based on expected response times and connection quality. Always implement fallback to cache when network fails. Update cache with successful network responses to ensure fresh data for future fallbacks. Consider using different strategies for different types of requests based on their freshness requirements. Implement proper error handling and user feedback mechanisms. Monitor network conditions and adapt strategy accordingly. Use background sync for critical requests that fail. Implement request queuing for offline scenarios. Track metrics to optimize timeout values and cache policies. Consider the trade-off between freshness and availability for each use case. Clean up expired cache entries periodically to manage storage. Test thoroughly with various network conditions including offline, slow connections, and timeouts.

---

