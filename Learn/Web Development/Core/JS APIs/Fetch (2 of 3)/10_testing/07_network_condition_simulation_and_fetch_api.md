## Network Condition Simulation and Fetch API


### Browser DevTools Network Throttling

#### Chrome DevTools

Chrome provides built-in network throttling in the Network panel.

**Preset Profiles:**

- Fast 3G: 1.6 Mbps down, 750 Kbps up, 562.5 ms RTT
- Slow 3G: 400 Kbps down, 400 Kbps up, 2000 ms RTT
- Offline: Complete network disconnection

**Custom Throttling:**

```
Download: Custom Kbps
Upload: Custom Kbps
Latency: Custom ms
```

Throttling affects all network requests including fetch, XHR, WebSocket, and resource loading.

**Programmatic Detection:** [Inference] DevTools throttling cannot be detected programmatically. The browser reports throttled speeds as actual connection speeds.

#### Firefox DevTools

Firefox offers similar throttling in the Network Monitor.

**Preset Profiles:**

- GPRS: 50 Kbps, 500 ms latency
- Regular 2G: 250 Kbps, 300 ms latency
- Good 2G: 450 Kbps, 150 ms latency
- Regular 3G: 750 Kbps, 100 ms latency
- Good 3G: 1.5 Mbps, 40 ms latency
- Regular 4G: 4 Mbps, 20 ms latency
- DSL: 2 Mbps, 5 ms latency
- Wi-Fi: 30 Mbps, 2 ms latency

#### Safari/WebKit

Safari provides throttling through the Network Link Conditioner preference pane (macOS).

Profiles include:

- 3G
- DSL
- Edge
- High Latency DNS
- LTE
- Wi-Fi

### Network Information API

The Network Information API provides information about the connection, but does not simulate conditions.

```javascript
if ('connection' in navigator) {
  const connection = navigator.connection || 
                     navigator.mozConnection || 
                     navigator.webkitConnection;
  
  console.log('Effective Type:', connection.effectiveType); // '4g', '3g', '2g', 'slow-2g'
  console.log('Downlink:', connection.downlink, 'Mbps');
  console.log('RTT:', connection.rtt, 'ms');
  console.log('Save Data:', connection.saveData);
}
```

**Monitoring Changes:**

```javascript
connection.addEventListener('change', () => {
  console.log('Connection changed to:', connection.effectiveType);
  // Adapt fetch behavior based on connection quality
});
```

**Adaptive Fetch Strategy:**

```javascript
function adaptiveFetch(url, options = {}) {
  const connection = navigator.connection;
  
  if (connection) {
    if (connection.saveData) {
      // User has data saver enabled
      options.priority = 'low';
    }
    
    if (connection.effectiveType === 'slow-2g' || 
        connection.effectiveType === '2g') {
      // Reduce quality or quantity of data
      url += '?quality=low';
    }
  }
  
  return fetch(url, options);
}
```

[Unverified] Browser support for the Network Information API varies. Chrome and Edge support it fully, while Firefox and Safari have limited or no support.

### Manual Simulation Techniques

#### Delay Wrapper Function

Create a wrapper that adds artificial delays:

```javascript
function delayedFetch(url, options = {}, delayMs = 1000) {
  return new Promise((resolve, reject) => {
    setTimeout(() => {
      fetch(url, options)
        .then(resolve)
        .catch(reject);
    }, delayMs);
  });
}

// Simulate 2-second network delay
delayedFetch('/api/data', {}, 2000)
  .then(response => response.json())
  .then(data => console.log(data));
```

#### Random Latency Simulation

Simulate variable latency:

```javascript
function fetchWithRandomLatency(url, options = {}, minMs = 100, maxMs = 3000) {
  const delay = Math.random() * (maxMs - minMs) + minMs;
  
  return new Promise((resolve, reject) => {
    setTimeout(() => {
      fetch(url, options)
        .then(resolve)
        .catch(reject);
    }, delay);
  });
}
```

#### Bandwidth Throttling Simulation

Simulate slow downloads by reading response in chunks:

```javascript
async function throttledFetch(url, bytesPerSecond = 50000) {
  const response = await fetch(url);
  const reader = response.body.getReader();
  const contentLength = +response.headers.get('Content-Length');
  
  let receivedBytes = 0;
  const chunks = [];
  const startTime = Date.now();
  
  while (true) {
    const { done, value } = await reader.read();
    
    if (done) break;
    
    chunks.push(value);
    receivedBytes += value.length;
    
    // Calculate how long we should have taken
    const expectedTime = (receivedBytes / bytesPerSecond) * 1000;
    const actualTime = Date.now() - startTime;
    const delay = expectedTime - actualTime;
    
    if (delay > 0) {
      await new Promise(resolve => setTimeout(resolve, delay));
    }
  }
  
  const blob = new Blob(chunks);
  return new Response(blob, {
    status: response.status,
    statusText: response.statusText,
    headers: response.headers
  });
}

// Throttle to 50KB/s
throttledFetch('/large-file.zip', 50000)
  .then(response => response.blob())
  .then(blob => console.log('Downloaded:', blob.size, 'bytes'));
```

#### Packet Loss Simulation

Simulate unreliable connections with random failures:

```javascript
function unreliableFetch(url, options = {}, failureRate = 0.3) {
  if (Math.random() < failureRate) {
    return Promise.reject(new TypeError('Network request failed'));
  }
  
  return fetch(url, options);
}

// 30% chance of failure
unreliableFetch('/api/data', {}, 0.3)
  .then(response => response.json())
  .catch(error => console.error('Request failed:', error));
```

#### Progressive Degradation

Simulate progressive network degradation:

```javascript
class NetworkSimulator {
  constructor() {
    this.latency = 0;
    this.bandwidth = Infinity;
    this.failureRate = 0;
  }
  
  setConditions(latency, bandwidth, failureRate = 0) {
    this.latency = latency;
    this.bandwidth = bandwidth;
    this.failureRate = failureRate;
  }
  
  async fetch(url, options = {}) {
    // Simulate packet loss
    if (Math.random() < this.failureRate) {
      throw new TypeError('Simulated network failure');
    }
    
    // Simulate initial latency
    await new Promise(resolve => setTimeout(resolve, this.latency));
    
    const response = await fetch(url, options);
    
    // Simulate bandwidth throttling if reading body
    if (this.bandwidth !== Infinity) {
      return this.throttleResponse(response);
    }
    
    return response;
  }
  
  async throttleResponse(response) {
    const reader = response.body.getReader();
    const chunks = [];
    const startTime = Date.now();
    let receivedBytes = 0;
    
    while (true) {
      const { done, value } = await reader.read();
      if (done) break;
      
      chunks.push(value);
      receivedBytes += value.length;
      
      const expectedTime = (receivedBytes / this.bandwidth) * 1000;
      const actualTime = Date.now() - startTime;
      const delay = expectedTime - actualTime;
      
      if (delay > 0) {
        await new Promise(resolve => setTimeout(resolve, delay));
      }
    }
    
    const blob = new Blob(chunks);
    return new Response(blob, {
      status: response.status,
      statusText: response.statusText,
      headers: response.headers
    });
  }
}

// Usage
const simulator = new NetworkSimulator();
simulator.setConditions(500, 50000, 0.1); // 500ms latency, 50KB/s, 10% failure

simulator.fetch('/api/data')
  .then(response => response.json())
  .then(data => console.log(data))
  .catch(error => console.error(error));
```

### Service Worker Simulation

Service Workers provide powerful network interception for realistic simulation.

```javascript
// sw.js
self.addEventListener('fetch', event => {
  const url = new URL(event.request.url);
  
  // Only simulate for API requests
  if (url.pathname.startsWith('/api/')) {
    event.respondWith(simulateNetworkConditions(event.request));
  }
});

async function simulateNetworkConditions(request) {
  const conditions = {
    latency: 1000,      // 1 second delay
    bandwidth: 100000,  // 100KB/s
    failureRate: 0.05   // 5% failure rate
  };
  
  // Simulate packet loss
  if (Math.random() < conditions.failureRate) {
    return new Response(null, {
      status: 0,
      statusText: 'Network simulation: packet loss'
    });
  }
  
  // Simulate initial latency
  await new Promise(resolve => setTimeout(resolve, conditions.latency));
  
  // Fetch actual response
  const response = await fetch(request);
  
  // Simulate bandwidth throttling
  return throttleResponse(response, conditions.bandwidth);
}

async function throttleResponse(response, bytesPerSecond) {
  const reader = response.body.getReader();
  const stream = new ReadableStream({
    async start(controller) {
      const startTime = Date.now();
      let totalBytes = 0;
      
      while (true) {
        const { done, value } = await reader.read();
        
        if (done) {
          controller.close();
          break;
        }
        
        totalBytes += value.length;
        const expectedTime = (totalBytes / bytesPerSecond) * 1000;
        const actualTime = Date.now() - startTime;
        const delay = expectedTime - actualTime;
        
        if (delay > 0) {
          await new Promise(resolve => setTimeout(resolve, delay));
        }
        
        controller.enqueue(value);
      }
    }
  });
  
  return new Response(stream, {
    status: response.status,
    statusText: response.statusText,
    headers: response.headers
  });
}
```

**Registering the Service Worker:**

```javascript
if ('serviceWorker' in navigator) {
  navigator.serviceWorker.register('/sw.js')
    .then(registration => {
      console.log('Network simulator registered');
    });
}
```

### Timeout Simulation

#### AbortController with Timeout

```javascript
function fetchWithTimeout(url, options = {}, timeoutMs = 5000) {
  const controller = new AbortController();
  const timeoutId = setTimeout(() => controller.abort(), timeoutMs);
  
  return fetch(url, {
    ...options,
    signal: controller.signal
  }).finally(() => clearTimeout(timeoutId));
}

// Abort after 3 seconds
fetchWithTimeout('/api/slow-endpoint', {}, 3000)
  .then(response => response.json())
  .catch(error => {
    if (error.name === 'AbortError') {
      console.error('Request timed out');
    }
  });
```

#### Configurable Timeout Simulator

```javascript
class TimeoutSimulator {
  constructor(defaultTimeout = 10000) {
    this.defaultTimeout = defaultTimeout;
  }
  
  fetch(url, options = {}, timeout = this.defaultTimeout) {
    const controller = new AbortController();
    
    const timeoutId = setTimeout(() => {
      controller.abort();
    }, timeout);
    
    return fetch(url, {
      ...options,
      signal: controller.signal
    }).finally(() => {
      clearTimeout(timeoutId);
    });
  }
}

const simulator = new TimeoutSimulator(5000);

// Fast timeout for testing
simulator.fetch('/api/data', {}, 1000)
  .catch(error => console.error('Timed out'));
```

### Offline Simulation

#### Manual Offline Mode

```javascript
class OfflineSimulator {
  constructor() {
    this.isOffline = false;
  }
  
  setOffline(offline) {
    this.isOffline = offline;
  }
  
  fetch(url, options = {}) {
    if (this.isOffline) {
      return Promise.reject(new TypeError('Failed to fetch'));
    }
    
    return fetch(url, options);
  }
}

const simulator = new OfflineSimulator();

// Simulate going offline
simulator.setOffline(true);

simulator.fetch('/api/data')
  .catch(error => console.error('Network is offline'));

// Back online
simulator.setOffline(false);
```

#### Detecting Online/Offline

```javascript
// Check current status
console.log('Online:', navigator.onLine);

// Listen for changes
window.addEventListener('online', () => {
  console.log('Connection restored');
  // Retry failed requests
});

window.addEventListener('offline', () => {
  console.log('Connection lost');
  // Queue requests for later
});

// Fetch with offline handling
async function resilientFetch(url, options = {}) {
  if (!navigator.onLine) {
    throw new Error('Network is offline');
  }
  
  try {
    return await fetch(url, options);
  } catch (error) {
    if (!navigator.onLine) {
      throw new Error('Lost connection during request');
    }
    throw error;
  }
}
```

### Request Queueing for Offline

```javascript
class OfflineQueue {
  constructor() {
    this.queue = [];
    this.isOnline = navigator.onLine;
    
    window.addEventListener('online', () => {
      this.isOnline = true;
      this.processQueue();
    });
    
    window.addEventListener('offline', () => {
      this.isOnline = false;
    });
  }
  
  async fetch(url, options = {}) {
    if (this.isOnline) {
      try {
        return await fetch(url, options);
      } catch (error) {
        // Queue if failed
        return this.enqueue(url, options);
      }
    } else {
      return this.enqueue(url, options);
    }
  }
  
  enqueue(url, options) {
    return new Promise((resolve, reject) => {
      this.queue.push({ url, options, resolve, reject });
    });
  }
  
  async processQueue() {
    while (this.queue.length > 0 && this.isOnline) {
      const { url, options, resolve, reject } = this.queue.shift();
      
      try {
        const response = await fetch(url, options);
        resolve(response);
      } catch (error) {
        reject(error);
        // Re-queue if failed
        this.queue.unshift({ url, options, resolve, reject });
        break;
      }
    }
  }
}

const queue = new OfflineQueue();

// Will queue if offline, execute when online
queue.fetch('/api/data')
  .then(response => response.json())
  .then(data => console.log(data));
```

### Proxy-Based Simulation

#### Local Proxy Server

Use tools like Toxiproxy or custom proxy servers to simulate network conditions at the network layer.

**Toxiproxy Example (external tool, not JavaScript):**

```bash
# Add latency
toxiproxy-cli toxic add -t latency -a latency=1000 myapi

# Add bandwidth limit
toxiproxy-cli toxic add -t bandwidth -a rate=100 myapi

# Simulate slow close
toxiproxy-cli toxic add -t slow_close -a delay=5000 myapi
```

[Inference] Proxy-based simulation provides more realistic results than client-side simulation because it affects the actual network stack.

#### Custom Node.js Proxy

```javascript
// proxy-server.js (Node.js)
const http = require('http');
const httpProxy = require('http-proxy');

const proxy = httpProxy.createProxyServer({});

const config = {
  latency: 500,
  bandwidth: 50000, // bytes per second
  failureRate: 0.1
};

const server = http.createServer((req, res) => {
  // Simulate packet loss
  if (Math.random() < config.failureRate) {
    res.writeHead(503);
    res.end('Simulated network failure');
    return;
  }
  
  // Add latency
  setTimeout(() => {
    proxy.web(req, res, {
      target: 'http://localhost:3000'
    });
  }, config.latency);
});

// Throttle response bandwidth
proxy.on('proxyRes', (proxyRes, req, res) => {
  const originalWrite = res.write;
  const originalEnd = res.end;
  let sentBytes = 0;
  const startTime = Date.now();
  
  res.write = function(chunk) {
    sentBytes += chunk.length;
    const expectedTime = (sentBytes / config.bandwidth) * 1000;
    const actualTime = Date.now() - startTime;
    const delay = expectedTime - actualTime;
    
    if (delay > 0) {
      setTimeout(() => {
        originalWrite.call(res, chunk);
      }, delay);
    } else {
      originalWrite.call(res, chunk);
    }
  };
});

server.listen(8080);
```

### Testing Strategies

#### Automated Testing with Simulation

```javascript
describe('API requests under poor network', () => {
  let simulator;
  
  beforeEach(() => {
    simulator = new NetworkSimulator();
  });
  
  it('should handle slow connections', async () => {
    simulator.setConditions(2000, 10000); // 2s latency, 10KB/s
    
    const start = Date.now();
    const response = await simulator.fetch('/api/data');
    const duration = Date.now() - start;
    
    expect(duration).toBeGreaterThan(2000);
    expect(response.ok).toBe(true);
  });
  
  it('should retry on network failure', async () => {
    simulator.setConditions(0, Infinity, 0.5); // 50% failure
    
    let attempts = 0;
    let success = false;
    
    while (attempts < 5 && !success) {
      try {
        await simulator.fetch('/api/data');
        success = true;
      } catch (error) {
        attempts++;
      }
    }
    
    expect(success || attempts === 5).toBe(true);
  });
});
```

#### Load Testing with Varied Conditions

```javascript
async function loadTest(url, concurrency = 10, conditions = {}) {
  const simulator = new NetworkSimulator();
  simulator.setConditions(
    conditions.latency || 0,
    conditions.bandwidth || Infinity,
    conditions.failureRate || 0
  );
  
  const requests = Array(concurrency).fill(null).map((_, i) => 
    simulator.fetch(url)
      .then(() => ({ success: true, index: i }))
      .catch(error => ({ success: false, index: i, error }))
  );
  
  const results = await Promise.all(requests);
  
  const successful = results.filter(r => r.success).length;
  const failed = results.filter(r => !r.success).length;
  
  return {
    total: concurrency,
    successful,
    failed,
    successRate: successful / concurrency
  };
}

// Test with 3G conditions
loadTest('/api/data', 50, {
  latency: 100,
  bandwidth: 750000,
  failureRate: 0.05
}).then(results => console.log(results));
```

### Progressive Enhancement Patterns

#### Adaptive Resource Loading

```javascript
async function loadImage(url, quality = 'high') {
  const connection = navigator.connection;
  
  if (connection) {
    if (connection.effectiveType === 'slow-2g' || 
        connection.effectiveType === '2g') {
      quality = 'low';
    } else if (connection.effectiveType === '3g') {
      quality = 'medium';
    }
    
    if (connection.saveData) {
      quality = 'low';
    }
  }
  
  const qualityMap = {
    low: '?w=400&q=50',
    medium: '?w=800&q=75',
    high: '?w=1600&q=90'
  };
  
  return fetch(url + qualityMap[quality]);
}
```

#### Prefetching with Network Awareness

```javascript
async function intelligentPrefetch(urls) {
  const connection = navigator.connection;
  
  // Don't prefetch on slow or metered connections
  if (connection) {
    if (connection.saveData || 
        connection.effectiveType === 'slow-2g' || 
        connection.effectiveType === '2g') {
      console.log('Skipping prefetch due to network conditions');
      return;
    }
  }
  
  // Prefetch in batches
  const batchSize = connection?.effectiveType === '4g' ? 5 : 2;
  
  for (let i = 0; i < urls.length; i += batchSize) {
    const batch = urls.slice(i, i + batchSize);
    await Promise.all(
      batch.map(url => 
        fetch(url, { priority: 'low' })
          .catch(error => console.warn('Prefetch failed:', url))
      )
    );
  }
}
```

### Monitoring and Metrics

#### Performance Monitoring

```javascript
class NetworkMonitor {
  constructor() {
    this.metrics = [];
  }
  
  async fetch(url, options = {}) {
    const start = performance.now();
    const startBytes = this.getTransferredBytes();
    
    try {
      const response = await fetch(url, options);
      const duration = performance.now() - start;
      const bytes = this.getTransferredBytes() - startBytes;
      
      this.metrics.push({
        url,
        duration,
        bytes,
        speed: bytes / (duration / 1000), // bytes per second
        status: response.status,
        success: true,
        timestamp: Date.now()
      });
      
      return response;
    } catch (error) {
      const duration = performance.now() - start;
      
      this.metrics.push({
        url,
        duration,
        success: false,
        error: error.message,
        timestamp: Date.now()
      });
      
      throw error;
    }
  }
  
  getTransferredBytes() {
    // [Inference] This is a simplified approximation
    if (performance.getEntriesByType) {
      const entries = performance.getEntriesByType('resource');
      return entries.reduce((total, entry) => 
        total + (entry.transferSize || 0), 0
      );
    }
    return 0;
  }
  
  getAverageSpeed() {
    const successfulRequests = this.metrics.filter(m => m.success && m.speed);
    if (successfulRequests.length === 0) return 0;
    
    const totalSpeed = successfulRequests.reduce((sum, m) => sum + m.speed, 0);
    return totalSpeed / successfulRequests.length;
  }
  
  getFailureRate() {
    if (this.metrics.length === 0) return 0;
    const failures = this.metrics.filter(m => !m.success).length;
    return failures / this.metrics.length;
  }
}

const monitor = new NetworkMonitor();

monitor.fetch('/api/data')
  .then(response => response.json())
  .then(() => {
    console.log('Average speed:', monitor.getAverageSpeed(), 'bytes/s');
    console.log('Failure rate:', monitor.getFailureRate());
  });
```

### Browser-Specific Considerations

#### Chrome Network Conditions API

[Unverified] Chrome exposes network condition emulation through DevTools Protocol, which can be controlled programmatically via Puppeteer:

```javascript
// Using Puppeteer
const puppeteer = require('puppeteer');

const browser = await puppeteer.launch();
const page = await browser.newPage();

// Emulate slow 3G
const client = await page.target().createCDPSession();
await client.send('Network.emulateNetworkConditions', {
  offline: false,
  downloadThroughput: 400 * 1024 / 8, // 400 Kbps in bytes/s
  uploadThroughput: 400 * 1024 / 8,
  latency: 2000
});

await page.goto('https://example.com');
```

[Inference] This approach is primarily useful for automated testing rather than runtime simulation in production applications.

---

