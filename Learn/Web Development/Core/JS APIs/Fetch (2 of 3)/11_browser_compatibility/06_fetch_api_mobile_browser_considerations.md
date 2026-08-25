## Fetch API: Mobile Browser Considerations


### Network Connectivity Variations

#### Cellular Network Transitions

Mobile devices frequently transition between network types (4G/5G, WiFi, airplane mode). Active fetch requests may fail mid-transfer during these transitions. Implement retry logic with exponential backoff:

```javascript
async function fetchWithRetry(url, options = {}, maxRetries = 3) {
  for (let i = 0; i < maxRetries; i++) {
    try {
      const response = await fetch(url, options);
      if (!response.ok) throw new Error(`HTTP ${response.status}`);
      return response;
    } catch (error) {
      if (i === maxRetries - 1) throw error;
      await new Promise(resolve => setTimeout(resolve, Math.pow(2, i) * 1000));
    }
  }
}
```

#### Connection Quality Detection

Mobile networks exhibit variable latency and bandwidth. The Network Information API provides connection characteristics:

```javascript
if ('connection' in navigator) {
  const connection = navigator.connection;
  const effectiveType = connection.effectiveType; // '4g', '3g', '2g', 'slow-2g'
  
  if (effectiveType === 'slow-2g' || effectiveType === '2g') {
    // Reduce payload size, increase timeout
  }
}
```

**[Inference]** Connection quality metrics suggest appropriate timeout values, though actual performance varies by location and carrier.

#### Offline-First Patterns

Mobile devices lose connectivity regularly. Service Workers combined with fetch enable offline operation:

```javascript
self.addEventListener('fetch', (event) => {
  event.respondWith(
    caches.match(event.request)
      .then(cached => cached || fetch(event.request))
      .catch(() => caches.match('/offline.html'))
  );
});
```

Background Sync API queues fetch requests when offline:

```javascript
// Register sync when offline
if ('serviceWorker' in navigator && 'sync' in self.registration) {
  await self.registration.sync.register('sync-posts');
}

// Execute when connection restored
self.addEventListener('sync', (event) => {
  if (event.tag === 'sync-posts') {
    event.waitUntil(syncPendingPosts());
  }
});
```

### Memory Constraints

#### Streaming Large Responses

Mobile devices have limited RAM compared to desktop systems. Stream large responses rather than loading entirely into memory:

```javascript
const response = await fetch('/large-file.json');
const reader = response.body.getReader();
const decoder = new TextDecoder();

while (true) {
  const { done, value } = await reader.read();
  if (done) break;
  
  const chunk = decoder.decode(value, { stream: true });
  processChunk(chunk); // Process incrementally
}
```

#### Request Body Streaming

Uploading large files consumes memory. Stream request bodies when supported:

```javascript
async function* fileChunkGenerator(file) {
  const chunkSize = 64 * 1024; // 64KB chunks
  let offset = 0;
  
  while (offset < file.size) {
    const chunk = file.slice(offset, offset + chunkSize);
    yield await chunk.arrayBuffer();
    offset += chunkSize;
  }
}

const stream = new ReadableStream({
  async start(controller) {
    for await (const chunk of fileChunkGenerator(file)) {
      controller.enqueue(new Uint8Array(chunk));
    }
    controller.close();
  }
});

await fetch('/upload', {
  method: 'POST',
  body: stream,
  duplex: 'half' // Required for request streaming
});
```

#### Response Cloning Caution

Cloning responses duplicates data in memory. Avoid unless necessary:

```javascript
// Problematic on mobile
const response = await fetch('/data');
const clone = response.clone();
const data1 = await response.json();
const data2 = await clone.json();

// Better approach
const response = await fetch('/data');
const data = await response.json();
// Use data for multiple purposes
```

### Battery and Power Management

#### Request Batching

Frequent small requests drain battery by keeping radio active. Batch operations:

```javascript
// Instead of multiple requests
for (const id of ids) {
  await fetch(`/api/item/${id}`);
}

// Batch into single request
await fetch('/api/items', {
  method: 'POST',
  body: JSON.stringify({ ids })
});
```

#### Request Prioritization

The Priority Hints API influences browser scheduling:

```javascript
// Critical data fetch
fetch('/api/user', { priority: 'high' });

// Background analytics
fetch('/analytics', { priority: 'low' });

// Preload resources
fetch('/future-data', { priority: 'low' });
```

**[Unverified]** Browser adherence to priority hints varies across mobile browsers and may not consistently affect power consumption.

#### Background Fetch API

Large downloads continue when app is backgrounded or closed:

```javascript
if ('BackgroundFetchManager' in self) {
  const registration = await navigator.serviceWorker.ready;
  await registration.backgroundFetch.fetch('download-id', ['/large-file.zip'], {
    title: 'Downloading content',
    icons: [{ src: '/icon.png', sizes: '300x300', type: 'image/png' }],
    downloadTotal: 50 * 1024 * 1024 // 50MB
  });
}
```

### Browser-Specific Limitations

#### iOS Safari Restrictions

iOS Safari implements stricter fetch behavior than other mobile browsers.

##### Request Limitations in Background

Fetch requests in background tabs or when app is inactive face aggressive termination. Requests typically timeout after 30 seconds when backgrounded.

**[Inference]** This appears designed to conserve battery and system resources, though Apple doesn't document specific timeouts.

##### Private Browsing Mode

Private browsing restricts persistent storage. Service Worker caching and IndexedDB may be unavailable:

```javascript
try {
  await caches.open('my-cache');
} catch (error) {
  // Handle private browsing mode
  console.warn('Caching unavailable');
}
```

##### WebKit Cookie Restrictions

iOS Safari's Intelligent Tracking Prevention affects fetch with credentials:

```javascript
// May not send cookies in cross-origin requests
fetch('https://api.example.com/data', {
  credentials: 'include'
});
```

#### Android Chrome Considerations

##### Data Saver Mode

When Data Saver is enabled, Chrome may proxy requests through Google servers, compressing responses and potentially modifying headers.

##### Lite Mode Warnings

Chrome Lite Mode optimizes resources. Requests may be delayed or modified for bandwidth reduction.

#### Samsung Internet

Samsung Internet includes enhanced tracking protection and ad blocking that may affect fetch requests to third-party domains.

### Request Timeout Handling

#### Mobile-Appropriate Timeouts

Mobile networks have higher latency than desktop broadband. Implement longer, adaptive timeouts:

```javascript
const controller = new AbortController();
const timeout = connection?.effectiveType === '2g' ? 30000 : 10000;

const timeoutId = setTimeout(() => controller.abort(), timeout);

try {
  const response = await fetch(url, { signal: controller.signal });
  clearTimeout(timeoutId);
  return response;
} catch (error) {
  if (error.name === 'AbortError') {
    // Handle timeout
  }
}
```

#### Progressive Timeout Strategy

Increase timeout duration for retries:

```javascript
async function fetchWithProgressiveTimeout(url, baseTimeout = 5000) {
  let attempt = 0;
  
  while (attempt < 3) {
    const controller = new AbortController();
    const timeout = baseTimeout * Math.pow(2, attempt);
    const timeoutId = setTimeout(() => controller.abort(), timeout);
    
    try {
      const response = await fetch(url, { signal: controller.signal });
      clearTimeout(timeoutId);
      return response;
    } catch (error) {
      clearTimeout(timeoutId);
      if (attempt === 2 || error.name !== 'AbortError') throw error;
      attempt++;
    }
  }
}
```

### CORS and Mobile-Specific Issues

#### Preflight Request Overhead

Mobile networks have higher latency, making CORS preflight requests costly. Minimize by using simple requests when possible:

```javascript
// Simple request (no preflight)
fetch('https://api.example.com/data', {
  method: 'GET',
  headers: {
    'Accept': 'application/json'
  }
});

// Triggers preflight
fetch('https://api.example.com/data', {
  method: 'GET',
  headers: {
    'X-Custom-Header': 'value',
    'Accept': 'application/json'
  }
});
```

#### Mixed Content Blocking

Mobile browsers strictly enforce HTTPS requirements. Fetch to HTTP resources from HTTPS pages fails:

```javascript
// Fails on HTTPS page
fetch('http://insecure-api.com/data');

// Upgrade to HTTPS
fetch('https://insecure-api.com/data');
```

### Headers and Mobile Optimization

#### Compression Headers

Explicitly request compression to reduce mobile data usage:

```javascript
fetch(url, {
  headers: {
    'Accept-Encoding': 'gzip, deflate, br'
  }
});
```

Most browsers send this automatically, but explicit inclusion ensures consistency.

#### Accept Headers for Mobile Content

Request mobile-optimized content variants:

```javascript
fetch('/api/content', {
  headers: {
    'Accept': 'application/json',
    'X-Requested-With': 'XMLHttpRequest',
    'Viewport-Width': window.innerWidth.toString()
  }
});
```

**[Inference]** Server-side adaptation based on viewport requires custom implementation; this isn't standardized behavior.

### Cache Strategies for Mobile

#### Cache-Control Directives

Leverage browser caching aggressively on mobile to reduce network usage:

```javascript
fetch('/static/data.json', {
  headers: {
    'Cache-Control': 'max-age=3600, stale-while-revalidate=86400'
  }
});
```

**Note:** Cache-Control in request headers suggests preferences but doesn't override server directives.

#### Service Worker Caching Strategies

Implement different strategies based on resource type:

```javascript
self.addEventListener('fetch', (event) => {
  const url = new URL(event.request.url);
  
  // Cache-first for static assets
  if (url.pathname.startsWith('/static/')) {
    event.respondWith(
      caches.match(event.request)
        .then(cached => cached || fetch(event.request))
    );
  }
  
  // Network-first for API calls
  if (url.pathname.startsWith('/api/')) {
    event.respondWith(
      fetch(event.request)
        .catch(() => caches.match(event.request))
    );
  }
  
  // Stale-while-revalidate for dynamic content
  if (url.pathname.startsWith('/content/')) {
    event.respondWith(
      caches.match(event.request)
        .then(cached => {
          const fetchPromise = fetch(event.request)
            .then(response => {
              caches.open('dynamic-v1').then(cache => {
                cache.put(event.request, response.clone());
              });
              return response;
            });
          return cached || fetchPromise;
        })
    );
  }
});
```

### Debugging Mobile Fetch Issues

#### Remote Debugging

Use remote debugging tools for real device testing:

- Chrome DevTools for Android via USB debugging
- Safari Web Inspector for iOS via cable connection

#### Network Throttling Simulation

Simulate mobile network conditions in desktop DevTools:

```javascript
// Add artificial delays for testing
async function fetchWithSimulatedLatency(url, latency = 1000) {
  await new Promise(resolve => setTimeout(resolve, latency));
  return fetch(url);
}
```

#### Logging Connection State

Monitor network changes during fetch operations:

```javascript
let currentConnection = navigator.connection?.effectiveType;

navigator.connection?.addEventListener('change', () => {
  console.log('Connection changed:', {
    from: currentConnection,
    to: navigator.connection.effectiveType
  });
  currentConnection = navigator.connection.effectiveType;
});

fetch('/api/data')
  .then(response => {
    console.log('Fetch completed on:', currentConnection);
  });
```

### Performance Monitoring

#### Navigation Timing API

Measure fetch performance in context:

```javascript
const observer = new PerformanceObserver((list) => {
  for (const entry of list.getEntries()) {
    if (entry.initiatorType === 'fetch') {
      console.log({
        url: entry.name,
        duration: entry.duration,
        transferSize: entry.transferSize,
        decodedBodySize: entry.decodedBodySize
      });
    }
  }
});

observer.observe({ entryTypes: ['resource'] });
```

#### Custom Metrics Collection

Track fetch success rates and performance:

```javascript
const fetchMetrics = {
  attempts: 0,
  successes: 0,
  failures: 0,
  totalDuration: 0
};

async function monitoredFetch(url, options) {
  fetchMetrics.attempts++;
  const startTime = performance.now();
  
  try {
    const response = await fetch(url, options);
    fetchMetrics.successes++;
    return response;
  } catch (error) {
    fetchMetrics.failures++;
    throw error;
  } finally {
    fetchMetrics.totalDuration += performance.now() - startTime;
  }
}
```

### Security Considerations

#### Certificate Pinning Limitations

Mobile browsers don't support HTTP certificate pinning via fetch. Use platform-specific solutions for certificate validation in native wrappers.

#### Content Security Policy

CSP violations affect fetch differently on mobile. Test CSP directives across devices:

```javascript
// CSP may block this
fetch('https://third-party.com/api')
  .catch(error => {
    if (error.message.includes('CSP')) {
      console.error('CSP blocked request');
    }
  });
```

#### User Agent Spoofing Detection

Mobile environments may have inconsistent User-Agent strings. Avoid relying on UA for feature detection:

```javascript
// Bad practice
if (navigator.userAgent.includes('Mobile')) {
  // Mobile-specific code
}

// Better approach
if ('ontouchstart' in window && window.innerWidth < 768) {
  // Touch-enabled narrow viewport
}
```

### Progressive Web App Integration

#### Install Prompts and Fetch

PWA installation affects fetch behavior through Service Workers:

```javascript
window.addEventListener('beforeinstallprompt', (e) => {
  e.preventDefault();
  
  // After installation, Service Worker handles fetches
  window.addEventListener('appinstalled', () => {
    console.log('PWA installed - fetch now routed through SW');
  });
});
```

#### Add to Home Screen Caching

Pre-cache critical resources when PWA is installed:

```javascript
self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open('pwa-v1').then((cache) => {
      return cache.addAll([
        '/',
        '/styles/main.css',
        '/scripts/app.js',
        '/api/initial-data'
      ]);
    })
  );
});
```

### Browser Feature Detection

#### Capabilities Testing

Check feature availability before using advanced fetch capabilities:

```javascript
const capabilities = {
  streams: 'ReadableStream' in window,
  requestStreaming: 'duplex' in Request.prototype,
  backgroundFetch: 'BackgroundFetchManager' in self,
  priorityHints: 'priority' in Request.prototype,
  abortController: 'AbortController' in window
};

// Adapt behavior based on capabilities
if (!capabilities.abortController) {
  // Fallback for timeout handling
}
```

#### Polyfill Strategies

Load polyfills conditionally for older mobile browsers:

```javascript
if (!window.fetch) {
  // Load fetch polyfill
  await import('whatwg-fetch');
}

if (!window.AbortController) {
  await import('abortcontroller-polyfill');
}
```

### Data Usage Optimization

#### Conditional Requests

Use ETags and Last-Modified headers to avoid re-downloading unchanged data:

```javascript
const cachedETag = localStorage.getItem('data-etag');

const response = await fetch('/api/data', {
  headers: cachedETag ? { 'If-None-Match': cachedETag } : {}
});

if (response.status === 304) {
  // Use cached data
  return JSON.parse(localStorage.getItem('data'));
}

localStorage.setItem('data-etag', response.headers.get('ETag'));
const data = await response.json();
localStorage.setItem('data', JSON.stringify(data));
return data;
```

#### Range Requests

Download large files in chunks:

```javascript
async function fetchInRanges(url, chunkSize = 1024 * 1024) { // 1MB chunks
  const headResponse = await fetch(url, { method: 'HEAD' });
  const fileSize = parseInt(headResponse.headers.get('Content-Length'));
  
  const chunks = [];
  for (let start = 0; start < fileSize; start += chunkSize) {
    const end = Math.min(start + chunkSize - 1, fileSize - 1);
    const response = await fetch(url, {
      headers: { 'Range': `bytes=${start}-${end}` }
    });
    chunks.push(await response.blob());
  }
  
  return new Blob(chunks);
}
```

#### Delta Updates

Fetch only changed portions of data:

```javascript
const lastSync = localStorage.getItem('last-sync');

const response = await fetch(`/api/updates?since=${lastSync}`);
const updates = await response.json();

// Merge updates with existing data
const existingData = JSON.parse(localStorage.getItem('data'));
const mergedData = applyUpdates(existingData, updates);

localStorage.setItem('data', JSON.stringify(mergedData));
localStorage.setItem('last-sync', new Date().toISOString());
```

---

