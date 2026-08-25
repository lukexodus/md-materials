## Request Prioritization


### Priority Queue Management

The fetch API processes requests through the browser's internal priority queue system. Browsers assign priority levels based on resource type, timing, and explicitly set priority hints. High-priority requests execute before low-priority ones when network connections reach their limit.

### Priority Levels

Modern browsers recognize three explicit priority levels through the `priority` option:

- **high**: Critical resources needed immediately for initial render or user interaction
- **low**: Deferrable resources that don't block rendering or interaction
- **auto**: Browser determines priority based on resource type and context (default)

```javascript
fetch('/critical-api', { priority: 'high' });
fetch('/analytics', { priority: 'low' });
```

### Default Priority Assignment

[Inference] Without explicit priority hints, browsers typically assign priorities based on these patterns:

- **Highest**: HTML documents, synchronous XHR, early fetch requests
- **High**: CSS, fonts requested early, images in viewport
- **Medium**: Scripts, deferred/async scripts
- **Low**: Prefetch requests, images outside viewport
- **Lowest**: Beacon requests, late-discovered resources

### Browser Preconnection and Prefetch

Browsers maintain connection pools with limits per domain (typically 6-8 connections per host). Priority affects which requests consume these limited connections first. Lower-priority requests queue until connections become available.

```javascript
// Preconnect for anticipated high-priority requests
const link = document.createElement('link');
link.rel = 'preconnect';
link.href = 'https://api.example.com';
document.head.appendChild(link);
```

### Priority Hints Standard

The Priority Hints API (`fetchpriority` attribute for HTML elements, `priority` for fetch) provides explicit control:

```javascript
// Boost a critical API call
fetch('/user-session', { 
  priority: 'high',
  credentials: 'include'
});

// Defer non-critical data
fetch('/recommendations', { 
  priority: 'low' 
}).then(response => {
  // Process when bandwidth available
});
```

### Request Ordering Strategies

#### Sequential Critical Path

Execute high-priority requests first, then trigger dependent requests:

```javascript
async function loadCriticalThenDeferred() {
  // Critical data first
  const session = await fetch('/session', { priority: 'high' });
  const userData = await session.json();
  
  // Then lower-priority enhancements
  fetch('/preferences', { priority: 'low' });
  fetch('/suggestions', { priority: 'low' });
}
```

#### Parallel with Priority

Launch multiple requests simultaneously but with different priorities:

```javascript
Promise.all([
  fetch('/essential-data', { priority: 'high' }),
  fetch('/supplemental-data', { priority: 'low' }),
  fetch('/metrics', { priority: 'low' })
]);
```

### Bandwidth-Aware Prioritization

[Inference] Combine Network Information API with priority hints to adapt request strategies:

```javascript
async function adaptiveFetch(url, data) {
  const connection = navigator.connection;
  
  // On slow connections, prioritize more aggressively
  const priority = connection?.effectiveType === '4g' ? 'auto' : 'high';
  
  return fetch(url, {
    priority,
    body: JSON.stringify(data),
    method: 'POST'
  });
}
```

**Disclaimer**: [Unverified] Browser behavior regarding network-aware priority adjustment is not guaranteed and varies by implementation.

### AbortController for Dynamic Prioritization

Cancel lower-priority requests when higher-priority ones arrive:

```javascript
let currentRequest = null;

async function fetchWithCancellation(url, priority) {
  // Cancel previous low-priority request if new high-priority arrives
  if (currentRequest && priority === 'high') {
    currentRequest.abort();
  }
  
  const controller = new AbortController();
  currentRequest = controller;
  
  try {
    return await fetch(url, {
      signal: controller.signal,
      priority
    });
  } catch (err) {
    if (err.name === 'AbortError') {
      console.log('Request cancelled for higher priority');
    }
    throw err;
  }
}
```

### Queue Management Patterns

#### Manual Request Queue

```javascript
class RequestQueue {
  constructor() {
    this.highPriority = [];
    this.lowPriority = [];
    this.active = 0;
    this.maxConcurrent = 6;
  }
  
  async add(url, options = {}) {
    const request = { url, options };
    const queue = options.priority === 'high' 
      ? this.highPriority 
      : this.lowPriority;
    
    queue.push(request);
    return this.process();
  }
  
  async process() {
    if (this.active >= this.maxConcurrent) return;
    
    // Process high-priority first
    const request = this.highPriority.shift() || this.lowPriority.shift();
    if (!request) return;
    
    this.active++;
    
    try {
      const response = await fetch(request.url, request.options);
      return response;
    } finally {
      this.active--;
      this.process(); // Process next queued request
    }
  }
}
```

### Preload and Priority

Combine `<link rel="preload">` with fetchpriority for early resource hints:

```html
<link rel="preload" 
      href="/critical-api-data" 
      as="fetch" 
      fetchpriority="high"
      crossorigin>
```

Then fetch with matching priority:

```javascript
fetch('/critical-api-data', { 
  priority: 'high',
  credentials: 'include' 
});
```

### Service Worker Interception

Service workers can reorder or modify request priorities:

```javascript
// In service worker
self.addEventListener('fetch', event => {
  const url = new URL(event.request.url);
  
  // Boost priority for specific endpoints
  if (url.pathname.startsWith('/api/critical')) {
    const modifiedRequest = new Request(event.request, {
      priority: 'high'
    });
    event.respondWith(fetch(modifiedRequest));
    return;
  }
  
  event.respondWith(fetch(event.request));
});
```

**Disclaimer**: [Unverified] Service worker ability to modify request priority may vary by browser implementation.

### Priority Inversion Avoidance

Prevent low-priority requests from blocking high-priority ones:

```javascript
async function fetchWithTimeout(url, options = {}) {
  const timeout = options.priority === 'low' ? 10000 : 5000;
  const controller = new AbortController();
  
  const timeoutId = setTimeout(() => controller.abort(), timeout);
  
  try {
    return await fetch(url, {
      ...options,
      signal: controller.signal
    });
  } finally {
    clearTimeout(timeoutId);
  }
}
```

### HTTP/2 and HTTP/3 Prioritization

HTTP/2 provides stream prioritization at protocol level. Browsers map fetch priority hints to HTTP/2 stream weights and dependencies:

- High priority: Higher stream weight (e.g., 256)
- Low priority: Lower stream weight (e.g., 16)
- Dependencies: Chain requests to ensure critical resources load first

HTTP/3 (QUIC) uses similar prioritization with extensible priority frames.

### Request Coalescing

Batch multiple low-priority requests to reduce overhead:

```javascript
class RequestBatcher {
  constructor(delay = 100) {
    this.queue = [];
    this.timer = null;
    this.delay = delay;
  }
  
  add(url, options) {
    return new Promise((resolve, reject) => {
      this.queue.push({ url, options, resolve, reject });
      
      if (!this.timer) {
        this.timer = setTimeout(() => this.flush(), this.delay);
      }
    });
  }
  
  async flush() {
    const batch = this.queue.splice(0);
    this.timer = null;
    
    const results = await Promise.allSettled(
      batch.map(({ url, options }) => fetch(url, options))
    );
    
    results.forEach((result, i) => {
      if (result.status === 'fulfilled') {
        batch[i].resolve(result.value);
      } else {
        batch[i].reject(result.reason);
      }
    });
  }
}
```

### Browser Compatibility

Priority hints support varies:

- Chrome/Edge: Full support for `priority` option (Chrome 101+)
- Safari: Partial support (Safari 17.2+)
- Firefox: Under development

[Unverified] Feature detection recommended:

```javascript
const supportsPriority = 'priority' in Request.prototype;

fetch(url, supportsPriority ? { priority: 'high' } : {});
```

### Performance Monitoring

Track how prioritization affects load times:

```javascript
async function fetchWithMetrics(url, options = {}) {
  const start = performance.now();
  const priority = options.priority || 'auto';
  
  try {
    const response = await fetch(url, options);
    const duration = performance.now() - start;
    
    // Log timing by priority
    console.log(`[${priority}] ${url}: ${duration.toFixed(2)}ms`);
    
    return response;
  } catch (err) {
    const duration = performance.now() - start;
    console.error(`[${priority}] ${url} failed after ${duration.toFixed(2)}ms`);
    throw err;
  }
}
```

### Resource Hints Interaction

Priority hints work alongside other resource hints:

```html
<!-- Preconnect with priority -->
<link rel="preconnect" href="https://api.example.com">

<!-- DNS prefetch for low-priority domains -->
<link rel="dns-prefetch" href="https://cdn.example.com">

<!-- Preload critical resources -->
<link rel="preload" href="/api/init" as="fetch" fetchpriority="high">
```

Fetch requests inherit or override these hints:

```javascript
// Uses preconnected socket with high priority
fetch('https://api.example.com/data', { priority: 'high' });
```

---

