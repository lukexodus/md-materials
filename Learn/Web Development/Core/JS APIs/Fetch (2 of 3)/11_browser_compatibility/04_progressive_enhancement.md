## Progressive Enhancement


### Core Strategy

Progressive enhancement builds fetch-based features as layers, starting with basic functionality and adding capabilities based on browser support and network conditions. The baseline uses standard HTTP semantics, with enhancements added through feature detection.

### Feature Detection Patterns

```javascript
// Basic fetch availability
const hasFetch = typeof fetch !== 'undefined';

// Streaming support
const hasStreaming = hasFetch && 
  typeof ReadableStream !== 'undefined' &&
  typeof Response.prototype.body !== 'undefined';

// Request cloning
const hasCloning = hasFetch && 
  typeof Request.prototype.clone === 'function';

// AbortController
const hasAbort = typeof AbortController !== 'undefined';

// Network Information API
const hasNetworkInfo = 'connection' in navigator;

// Service Worker
const hasServiceWorker = 'serviceWorker' in navigator;
```

### Graceful Degradation Hierarchy

#### Level 1: XMLHttpRequest Fallback

When fetch is unavailable, fall back to XMLHttpRequest with similar interface:

```javascript
function request(url, options = {}) {
  if (typeof fetch !== 'undefined') {
    return fetch(url, options);
  }
  
  // XHR fallback
  return new Promise((resolve, reject) => {
    const xhr = new XMLHttpRequest();
    xhr.open(options.method || 'GET', url);
    
    // Set headers
    if (options.headers) {
      Object.entries(options.headers).forEach(([key, value]) => {
        xhr.setRequestHeader(key, value);
      });
    }
    
    xhr.onload = () => {
      resolve({
        ok: xhr.status >= 200 && xhr.status < 300,
        status: xhr.status,
        statusText: xhr.statusText,
        headers: parseHeaders(xhr.getAllResponseHeaders()),
        text: () => Promise.resolve(xhr.responseText),
        json: () => Promise.resolve(JSON.parse(xhr.responseText)),
        blob: () => Promise.resolve(new Blob([xhr.response]))
      });
    };
    
    xhr.onerror = () => reject(new Error('Network error'));
    xhr.send(options.body);
  });
}

function parseHeaders(headerString) {
  const headers = new Map();
  headerString.split('\r\n').forEach(line => {
    const [key, value] = line.split(': ');
    if (key) headers.set(key.toLowerCase(), value);
  });
  return headers;
}
```

#### Level 2: Basic Fetch

Simplest fetch operations with minimal options:

```javascript
async function basicFetch(url) {
  try {
    const response = await fetch(url);
    if (!response.ok) {
      throw new Error(`HTTP ${response.status}`);
    }
    return await response.json();
  } catch (error) {
    console.error('Fetch failed:', error);
    throw error;
  }
}
```

#### Level 3: Enhanced Fetch with Timeouts

Add timeout support where AbortController is available:

```javascript
async function fetchWithTimeout(url, options = {}, timeout = 5000) {
  if (typeof AbortController !== 'undefined') {
    const controller = new AbortController();
    const id = setTimeout(() => controller.abort(), timeout);
    
    try {
      const response = await fetch(url, {
        ...options,
        signal: controller.signal
      });
      clearTimeout(id);
      return response;
    } catch (error) {
      clearTimeout(id);
      if (error.name === 'AbortError') {
        throw new Error('Request timeout');
      }
      throw error;
    }
  }
  
  // Fallback: no timeout support
  return fetch(url, options);
}
```

#### Level 4: Streaming Response Handling

Process response streams when supported:

```javascript
async function fetchWithProgress(url, onProgress) {
  const response = await fetch(url);
  
  // Check streaming support
  if (!response.body || typeof ReadableStream === 'undefined') {
    // Fallback: load entire response
    const data = await response.arrayBuffer();
    onProgress?.(data.byteLength, data.byteLength);
    return data;
  }
  
  const reader = response.body.getReader();
  const contentLength = +response.headers.get('Content-Length');
  
  let receivedLength = 0;
  const chunks = [];
  
  while (true) {
    const {done, value} = await reader.read();
    
    if (done) break;
    
    chunks.push(value);
    receivedLength += value.length;
    onProgress?.(receivedLength, contentLength);
  }
  
  // Concatenate chunks
  const chunksAll = new Uint8Array(receivedLength);
  let position = 0;
  for (const chunk of chunks) {
    chunksAll.set(chunk, position);
    position += chunk.length;
  }
  
  return chunksAll.buffer;
}
```

### Network-Aware Enhancement

Adapt behavior based on connection quality:

```javascript
function getNetworkStrategy() {
  if (!('connection' in navigator)) {
    return 'default';
  }
  
  const conn = navigator.connection;
  const effectiveType = conn.effectiveType;
  
  // [Inference] These thresholds represent common categorizations
  if (effectiveType === 'slow-2g' || effectiveType === '2g') {
    return 'minimal';
  }
  
  if (effectiveType === '3g') {
    return 'moderate';
  }
  
  if (conn.saveData) {
    return 'minimal';
  }
  
  return 'full';
}

async function adaptiveFetch(url, options = {}) {
  const strategy = getNetworkStrategy();
  
  switch (strategy) {
    case 'minimal':
      // Reduce payload, increase timeout
      return fetchWithTimeout(url, {
        ...options,
        headers: {
          ...options.headers,
          'Accept-Encoding': 'gzip, deflate',
          'X-Network-Quality': 'low'
        }
      }, 15000);
      
    case 'moderate':
      return fetchWithTimeout(url, options, 10000);
      
    case 'full':
    default:
      return fetchWithTimeout(url, options, 5000);
  }
}
```

### Retry with Exponential Backoff

Layer retry logic when network is unreliable:

```javascript
async function fetchWithRetry(url, options = {}, maxRetries = 3) {
  let lastError;
  
  for (let attempt = 0; attempt <= maxRetries; attempt++) {
    try {
      const response = await fetch(url, options);
      
      // Don't retry on client errors
      if (response.status >= 400 && response.status < 500) {
        return response;
      }
      
      if (response.ok) {
        return response;
      }
      
      // Server error: might be temporary
      if (attempt === maxRetries) {
        return response;
      }
      
    } catch (error) {
      lastError = error;
      
      // Don't retry on abort
      if (error.name === 'AbortError') {
        throw error;
      }
      
      if (attempt === maxRetries) {
        throw error;
      }
    }
    
    // Exponential backoff: 1s, 2s, 4s
    const delay = Math.pow(2, attempt) * 1000;
    await new Promise(resolve => setTimeout(resolve, delay));
  }
  
  throw lastError;
}
```

### Service Worker Enhancement

Cache responses when Service Worker is available:

```javascript
// In main thread
async function fetchWithCacheFirst(url, options = {}) {
  if ('serviceWorker' in navigator && navigator.serviceWorker.controller) {
    // Service worker is active, will handle caching
    return fetch(url, options);
  }
  
  // No service worker: direct fetch only
  return fetch(url, options);
}

// In service worker
self.addEventListener('fetch', event => {
  event.respondWith(
    caches.match(event.request).then(cached => {
      // Return cached or fetch new
      return cached || fetch(event.request).then(response => {
        // Cache successful GET requests
        if (event.request.method === 'GET' && response.ok) {
          const responseClone = response.clone();
          caches.open('v1').then(cache => {
            cache.put(event.request, responseClone);
          });
        }
        return response;
      });
    })
  );
});
```

### Request Deduplication

Avoid duplicate concurrent requests:

```javascript
class FetchDeduplicator {
  constructor() {
    this.pending = new Map();
  }
  
  async fetch(url, options = {}) {
    const key = this.createKey(url, options);
    
    if (this.pending.has(key)) {
      // Return existing promise
      return this.pending.get(key);
    }
    
    const promise = fetch(url, options)
      .then(response => {
        // Clone for multiple consumers if supported
        if (typeof response.clone === 'function') {
          return response;
        }
        return response;
      })
      .finally(() => {
        this.pending.delete(key);
      });
    
    this.pending.set(key, promise);
    return promise;
  }
  
  createKey(url, options) {
    return `${options.method || 'GET'}:${url}`;
  }
}

const deduplicator = new FetchDeduplicator();
```

### Request Prioritization

Queue and prioritize requests based on importance:

```javascript
class FetchQueue {
  constructor(concurrency = 6) {
    this.concurrency = concurrency;
    this.running = 0;
    this.queue = [];
  }
  
  async fetch(url, options = {}, priority = 0) {
    return new Promise((resolve, reject) => {
      this.queue.push({
        url,
        options,
        priority,
        resolve,
        reject
      });
      
      // Sort by priority (higher first)
      this.queue.sort((a, b) => b.priority - a.priority);
      
      this.processQueue();
    });
  }
  
  async processQueue() {
    while (this.running < this.concurrency && this.queue.length > 0) {
      const task = this.queue.shift();
      this.running++;
      
      try {
        const response = await fetch(task.url, task.options);
        task.resolve(response);
      } catch (error) {
        task.reject(error);
      } finally {
        this.running--;
        this.processQueue();
      }
    }
  }
}

const queue = new FetchQueue();

// Usage
queue.fetch('/critical', {}, 10); // High priority
queue.fetch('/analytics', {}, 1); // Low priority
```

### Response Type Negotiation

Request appropriate formats based on support:

```javascript
async function fetchWithFormatNegotiation(url, options = {}) {
  const supportedFormats = [];
  
  // Check modern format support
  if (typeof WebP !== 'undefined' || 
      document.createElement('canvas').toDataURL('image/webp').indexOf('data:image/webp') === 0) {
    supportedFormats.push('image/webp');
  }
  
  if (typeof AVIF !== 'undefined') {
    supportedFormats.push('image/avif');
  }
  
  supportedFormats.push('image/jpeg', 'image/png');
  
  return fetch(url, {
    ...options,
    headers: {
      ...options.headers,
      'Accept': supportedFormats.join(', ')
    }
  });
}
```

### Bandwidth-Aware Loading

Adjust quality based on available bandwidth:

```javascript
function getImageQuality() {
  if (!('connection' in navigator)) {
    return 'high';
  }
  
  const conn = navigator.connection;
  
  // [Inference] These mappings represent common quality tiers
  if (conn.saveData) {
    return 'low';
  }
  
  if (conn.effectiveType === '4g' && conn.downlink > 5) {
    return 'high';
  }
  
  if (conn.effectiveType === '3g' || conn.effectiveType === '4g') {
    return 'medium';
  }
  
  return 'low';
}

async function fetchImage(baseUrl) {
  const quality = getImageQuality();
  const url = `${baseUrl}?quality=${quality}`;
  
  return fetch(url);
}
```

### Offline Support with Background Sync

Queue requests when offline, sync when online:

```javascript
class OfflineQueue {
  constructor(dbName = 'offline-queue') {
    this.dbName = dbName;
    this.init();
  }
  
  async init() {
    if (typeof indexedDB === 'undefined') {
      this.fallbackQueue = [];
      return;
    }
    
    return new Promise((resolve, reject) => {
      const request = indexedDB.open(this.dbName, 1);
      
      request.onerror = () => reject(request.error);
      request.onsuccess = () => {
        this.db = request.result;
        resolve();
      };
      
      request.onupgradeneeded = (event) => {
        const db = event.target.result;
        if (!db.objectStoreNames.contains('requests')) {
          db.createObjectStore('requests', { autoIncrement: true });
        }
      };
    });
  }
  
  async add(url, options) {
    if (!this.db) {
      this.fallbackQueue.push({ url, options });
      return;
    }
    
    return new Promise((resolve, reject) => {
      const transaction = this.db.transaction(['requests'], 'readwrite');
      const store = transaction.objectStore('requests');
      const request = store.add({ url, options, timestamp: Date.now() });
      
      request.onsuccess = () => resolve();
      request.onerror = () => reject(request.error);
    });
  }
  
  async processQueue() {
    if (!navigator.onLine) return;
    
    // Process fallback queue
    if (this.fallbackQueue && this.fallbackQueue.length > 0) {
      for (const item of this.fallbackQueue) {
        try {
          await fetch(item.url, item.options);
        } catch (error) {
          console.error('Failed to sync:', error);
        }
      }
      this.fallbackQueue = [];
      return;
    }
    
    if (!this.db) return;
    
    const transaction = this.db.transaction(['requests'], 'readonly');
    const store = transaction.objectStore('requests');
    const request = store.getAll();
    
    request.onsuccess = async () => {
      const items = request.result;
      
      for (const item of items) {
        try {
          await fetch(item.url, item.options);
          // Remove from queue on success
          const deleteTransaction = this.db.transaction(['requests'], 'readwrite');
          const deleteStore = deleteTransaction.objectStore('requests');
          deleteStore.delete(item.id);
        } catch (error) {
          console.error('Failed to sync:', error);
        }
      }
    };
  }
}

const offlineQueue = new OfflineQueue();

window.addEventListener('online', () => {
  offlineQueue.processQueue();
});

async function resilientFetch(url, options = {}) {
  if (!navigator.onLine) {
    await offlineQueue.add(url, options);
    throw new Error('Offline: queued for later');
  }
  
  try {
    return await fetch(url, options);
  } catch (error) {
    if (!navigator.onLine) {
      await offlineQueue.add(url, options);
      throw new Error('Offline: queued for later');
    }
    throw error;
  }
}
```

### Progressive Response Processing

Start rendering before complete response:

```javascript
async function fetchAndRenderProgressive(url, onChunk) {
  const response = await fetch(url);
  
  // Check for streaming support
  if (!response.body || typeof ReadableStream === 'undefined') {
    const data = await response.text();
    onChunk(data, true);
    return;
  }
  
  const reader = response.body.getReader();
  const decoder = new TextDecoder();
  let buffer = '';
  
  while (true) {
    const {done, value} = await reader.read();
    
    if (done) {
      if (buffer) {
        onChunk(buffer, true);
      }
      break;
    }
    
    buffer += decoder.decode(value, {stream: true});
    
    // Process complete lines
    const lines = buffer.split('\n');
    buffer = lines.pop(); // Keep incomplete line
    
    for (const line of lines) {
      if (line.trim()) {
        onChunk(line, false);
      }
    }
  }
}
```

### Prefetch Strategies

Intelligently prefetch based on user behavior:

```javascript
class PrefetchManager {
  constructor() {
    this.prefetched = new Set();
    this.observer = null;
    
    if ('IntersectionObserver' in window) {
      this.setupIntersectionObserver();
    }
  }
  
  setupIntersectionObserver() {
    this.observer = new IntersectionObserver((entries) => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          const url = entry.target.dataset.prefetch;
          if (url && !this.prefetched.has(url)) {
            this.prefetch(url);
          }
        }
      });
    }, { rootMargin: '50px' });
  }
  
  async prefetch(url) {
    if (this.prefetched.has(url)) return;
    
    this.prefetched.add(url);
    
    // Use low priority if supported
    const options = {};
    if ('priority' in Request.prototype) {
      options.priority = 'low';
    }
    
    try {
      const response = await fetch(url, options);
      
      // Cache if service worker available
      if ('caches' in window) {
        const cache = await caches.open('prefetch-v1');
        cache.put(url, response.clone());
      }
    } catch (error) {
      console.warn('Prefetch failed:', url);
      this.prefetched.delete(url);
    }
  }
  
  observe(element) {
    if (this.observer) {
      this.observer.observe(element);
    } else {
      // Fallback: prefetch on hover
      element.addEventListener('mouseenter', () => {
        const url = element.dataset.prefetch;
        if (url) this.prefetch(url);
      }, { once: true });
    }
  }
}

const prefetcher = new PrefetchManager();
```

### Coordinated Multi-Request Loading

Load related resources efficiently:

```javascript
async function fetchDependencies(urls, options = {}) {
  // Check if we can use parallel loading
  const canParallel = typeof Promise.all === 'function';
  
  if (canParallel) {
    // Modern: parallel requests
    return Promise.all(urls.map(url => fetch(url, options)));
  }
  
  // Fallback: sequential
  const results = [];
  for (const url of urls) {
    results.push(await fetch(url, options));
  }
  return results;
}

async function fetchWithDependencies(primaryUrl, dependencyUrls = []) {
  // Start primary request
  const primaryPromise = fetch(primaryUrl);
  
  // Start dependencies with lower priority if supported
  const dependencyOptions = {};
  if ('priority' in Request.prototype) {
    dependencyOptions.priority = 'low';
  }
  
  const dependencyPromises = dependencyUrls.map(url => 
    fetch(url, dependencyOptions)
  );
  
  // Wait for primary first
  const primary = await primaryPromise;
  
  // Then wait for dependencies
  const dependencies = await Promise.all(dependencyPromises);
  
  return { primary, dependencies };
}
```

### Complete Progressive Enhancement Wrapper

Combine all layers into unified interface:

```javascript
class EnhancedFetch {
  constructor(config = {}) {
    this.config = {
      timeout: 5000,
      retries: 3,
      deduplicate: true,
      queue: true,
      offline: true,
      concurrency: 6,
      ...config
    };
    
    if (this.config.deduplicate) {
      this.deduplicator = new FetchDeduplicator();
    }
    
    if (this.config.queue) {
      this.queue = new FetchQueue(this.config.concurrency);
    }
    
    if (this.config.offline) {
      this.offlineQueue = new OfflineQueue();
    }
  }
  
  async fetch(url, options = {}) {
    // Layer 1: Check basic fetch support
    if (typeof fetch === 'undefined') {
      return this.xhrFallback(url, options);
    }
    
    // Layer 2: Offline handling
    if (this.config.offline && !navigator.onLine) {
      await this.offlineQueue.add(url, options);
      throw new Error('Offline: request queued');
    }
    
    // Layer 3: Deduplication
    if (this.config.deduplicate && options.method !== 'POST') {
      return this.deduplicator.fetch(url, options);
    }
    
    // Layer 4: Queue management
    if (this.config.queue) {
      return this.queue.fetch(url, options, options.priority || 0);
    }
    
    // Layer 5: Network-aware with retry and timeout
    return this.enhancedFetch(url, options);
  }
  
  async enhancedFetch(url, options) {
    const strategy = getNetworkStrategy();
    const timeout = this.getTimeoutForStrategy(strategy);
    
    return fetchWithRetry(
      url,
      options,
      this.config.retries
    ).then(response => 
      this.addTimeoutToResponse(response, timeout)
    );
  }
  
  getTimeoutForStrategy(strategy) {
    const timeouts = {
      minimal: 15000,
      moderate: 10000,
      full: this.config.timeout
    };
    return timeouts[strategy] || this.config.timeout;
  }
  
  async addTimeoutToResponse(response, timeout) {
    if (typeof AbortController === 'undefined') {
      return response;
    }
    
    // Wrap response body with timeout
    if (response.body && typeof ReadableStream !== 'undefined') {
      const controller = new AbortController();
      const timeoutId = setTimeout(() => controller.abort(), timeout);
      
      const reader = response.body.getReader();
      const stream = new ReadableStream({
        async start(controller) {
          try {
            while (true) {
              const {done, value} = await reader.read();
              if (done) break;
              controller.enqueue(value);
            }
            controller.close();
          } catch (error) {
            controller.error(error);
          } finally {
            clearTimeout(timeoutId);
          }
        }
      });
      
      return new Response(stream, {
        headers: response.headers,
        status: response.status,
        statusText: response.statusText
      });
    }
    
    return response;
  }
  
  xhrFallback(url, options) {
    return request(url, options);
  }
}

// Usage
const client = new EnhancedFetch({
  timeout: 5000,
  retries: 3,
  deduplicate: true,
  queue: true,
  offline: true
});

await client.fetch('/api/data');
```

---

