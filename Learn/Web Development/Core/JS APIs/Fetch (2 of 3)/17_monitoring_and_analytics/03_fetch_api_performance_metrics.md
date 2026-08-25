## Fetch API Performance Metrics


### Resource Timing API Integration

The Fetch API integrates with the Resource Timing API through `PerformanceResourceTiming` entries, automatically captured for every fetch request. Access these entries via:

```javascript
const entries = performance.getEntriesByType('resource');
const fetchEntries = entries.filter(e => e.initiatorType === 'fetch');
```

Alternatively, use `PerformanceObserver` for real-time monitoring:

```javascript
const observer = new PerformanceObserver((list) => {
  list.getEntries().forEach((entry) => {
    if (entry.initiatorType === 'fetch') {
      console.log(entry);
    }
  });
});
observer.observe({ entryTypes: ['resource'] });
```

### Key Timing Metrics

#### DNS Resolution Time

Time spent resolving the domain name to an IP address:

```javascript
const dnsTime = entry.domainLookupEnd - entry.domainLookupStart;
```

Zero values indicate cached DNS or same-origin requests.

#### TCP Connection Time

Time to establish TCP connection:

```javascript
const tcpTime = entry.connectEnd - entry.connectStart;
```

#### TLS Negotiation Time

For HTTPS requests, measure TLS handshake duration:

```javascript
const tlsTime = entry.connectEnd - entry.secureConnectionStart;
```

`secureConnectionStart` is zero for non-HTTPS requests.

#### Request Time

Time from request initiation to first byte received (TTFB):

```javascript
const requestTime = entry.responseStart - entry.requestStart;
```

This includes network latency and server processing time.

#### Response Time

Time to download the complete response body:

```javascript
const responseTime = entry.responseEnd - entry.responseStart;
```

#### Total Duration

End-to-end request duration:

```javascript
const totalTime = entry.responseEnd - entry.fetchStart;
```

Or use the convenience property:

```javascript
const totalTime = entry.duration;
```

### Transfer Size Metrics

#### Encoded Body Size

Compressed size of the response body (as transferred over network):

```javascript
const encodedSize = entry.encodedBodySize;
```

#### Decoded Body Size

Uncompressed size of the response body:

```javascript
const decodedSize = entry.decodedBodySize;
```

#### Transfer Size

Total bytes transferred including HTTP headers:

```javascript
const transferSize = entry.transferSize;
```

Special values:

- `0`: Resource served from cache (no network transfer)
- Non-zero but less than `encodedBodySize`: Partial response from cache with revalidation

#### Compression Ratio

Calculate compression efficiency:

```javascript
const compressionRatio = 1 - (entry.encodedBodySize / entry.decodedBodySize);
const compressionPercent = compressionRatio * 100;
```

### Cache Performance Analysis

#### Cache Hit Detection

```javascript
const isCacheHit = entry.transferSize === 0;
const isRevalidated = entry.transferSize > 0 && entry.transferSize < entry.encodedBodySize;
```

#### Cache vs Network Comparison

```javascript
function analyzeCache(entry) {
  if (entry.transferSize === 0) {
    return 'full-cache';
  } else if (entry.transferSize < entry.encodedBodySize) {
    return 'revalidated';
  } else {
    return 'network';
  }
}
```

### Protocol and Connection Analysis

#### HTTP Protocol Version

```javascript
const protocol = entry.nextHopProtocol;
// Common values: 'http/1.1', 'h2', 'h3'
```

#### Connection Reuse Detection

Check if connection was reused:

```javascript
const connectionReused = entry.connectStart === entry.connectEnd;
```

Zero duration indicates existing connection was reused.

### Server Timing API

Capture custom server-side metrics sent via `Server-Timing` header:

```javascript
const serverTimings = entry.serverTiming;
serverTimings.forEach(timing => {
  console.log(`${timing.name}: ${timing.duration}ms`);
  console.log(`Description: ${timing.description}`);
});
```

Server must send header:

```
Server-Timing: db;dur=53, app;dur=47.2;desc="Application processing"
```

### Measuring Fetch Operations Manually

For operations not captured by Resource Timing:

#### Performance.mark() and Performance.measure()

```javascript
performance.mark('fetch-start');

fetch('https://api.example.com/data')
  .then(response => response.json())
  .then(data => {
    performance.mark('fetch-end');
    performance.measure('fetch-duration', 'fetch-start', 'fetch-end');
    
    const measure = performance.getEntriesByName('fetch-duration')[0];
    console.log(`Fetch took ${measure.duration}ms`);
  });
```

#### High-Resolution Timestamps

Use `performance.now()` for microsecond precision:

```javascript
const start = performance.now();

await fetch('https://api.example.com/data');

const end = performance.now();
const duration = end - start;
```

### Response Body Processing Time

Measure deserialization overhead:

```javascript
const fetchStart = performance.now();
const response = await fetch('https://api.example.com/data');
const fetchEnd = performance.now();

const parseStart = performance.now();
const data = await response.json();
const parseEnd = performance.now();

console.log(`Network: ${fetchEnd - fetchStart}ms`);
console.log(`Parsing: ${parseEnd - parseStart}ms`);
```

### Streaming Performance Metrics

For streaming responses, track progressive data consumption:

```javascript
const response = await fetch('https://api.example.com/large-file');
const reader = response.body.getReader();

let bytesReceived = 0;
let chunks = 0;
const startTime = performance.now();

while (true) {
  const { done, value } = await reader.read();
  if (done) break;
  
  bytesReceived += value.length;
  chunks++;
  
  const elapsed = performance.now() - startTime;
  const throughput = (bytesReceived / 1024 / 1024) / (elapsed / 1000);
  console.log(`Throughput: ${throughput.toFixed(2)} MB/s`);
}
```

### Request Timing Breakdown Visualization

Complete timing breakdown analysis:

```javascript
function analyzeRequestTiming(entry) {
  const phases = {
    redirect: entry.redirectEnd - entry.redirectStart,
    appCache: entry.domainLookupStart - entry.fetchStart,
    dns: entry.domainLookupEnd - entry.domainLookupStart,
    tcp: entry.connectEnd - entry.connectStart,
    ssl: entry.connectEnd - entry.secureConnectionStart,
    request: entry.responseStart - entry.requestStart,
    response: entry.responseEnd - entry.responseStart
  };
  
  return phases;
}
```

### Batch Request Performance

Measure parallel fetch performance:

```javascript
const urls = ['url1', 'url2', 'url3'];
const startTime = performance.now();

const results = await Promise.all(
  urls.map(url => fetch(url))
);

const endTime = performance.now();
const parallelDuration = endTime - startTime;

// Compare with sequential
const sequentialStart = performance.now();
for (const url of urls) {
  await fetch(url);
}
const sequentialDuration = performance.now() - sequentialStart;

console.log(`Parallel: ${parallelDuration}ms`);
console.log(`Sequential: ${sequentialDuration}ms`);
console.log(`Speedup: ${(sequentialDuration / parallelDuration).toFixed(2)}x`);
```

### Network Quality Estimation

[Inference] Estimate network conditions based on timing patterns:

```javascript
function estimateNetworkQuality(entry) {
  const ttfb = entry.responseStart - entry.requestStart;
  const downloadTime = entry.responseEnd - entry.responseStart;
  const throughput = entry.encodedBodySize / downloadTime;
  
  return {
    latency: ttfb,
    bandwidth: throughput * 1000 / 1024, // KB/s
    quality: ttfb < 100 ? 'excellent' : 
             ttfb < 300 ? 'good' : 
             ttfb < 1000 ? 'fair' : 'poor'
  };
}
```

### Long Task Detection During Fetch

Monitor if fetch operations cause main thread blocking:

```javascript
const longTaskObserver = new PerformanceObserver((list) => {
  list.getEntries().forEach((entry) => {
    if (entry.duration > 50) {
      console.warn(`Long task detected: ${entry.duration}ms`);
    }
  });
});
longTaskObserver.observe({ entryTypes: ['longtask'] });
```

### Memory Impact Tracking

Monitor memory consumption during large fetches:

```javascript
if (performance.memory) {
  const memBefore = performance.memory.usedJSHeapSize;
  
  const response = await fetch('https://api.example.com/large-data');
  const data = await response.json();
  
  const memAfter = performance.memory.usedJSHeapSize;
  const memDelta = (memAfter - memBefore) / 1024 / 1024;
  
  console.log(`Memory increase: ${memDelta.toFixed(2)} MB`);
}
```

Note: `performance.memory` is non-standard and only available in Chromium-based browsers.

### Request Prioritization Metrics

Track fetch priority impact:

```javascript
// High priority fetch
const highPriorityStart = performance.now();
await fetch('critical-resource', { priority: 'high' });
const highPriorityTime = performance.now() - highPriorityStart;

// Low priority fetch
const lowPriorityStart = performance.now();
await fetch('non-critical-resource', { priority: 'low' });
const lowPriorityTime = performance.now() - lowPriorityStart;
```

### Retry and Timeout Metrics

Track retry attempts and timeout occurrences:

```javascript
async function fetchWithMetrics(url, options = {}) {
  const maxRetries = 3;
  let attempt = 0;
  let timeouts = 0;
  
  while (attempt < maxRetries) {
    attempt++;
    const startTime = performance.now();
    
    try {
      const controller = new AbortController();
      const timeoutId = setTimeout(() => {
        controller.abort();
        timeouts++;
      }, 5000);
      
      const response = await fetch(url, {
        ...options,
        signal: controller.signal
      });
      
      clearTimeout(timeoutId);
      const duration = performance.now() - startTime;
      
      return {
        response,
        metrics: {
          attempts: attempt,
          timeouts,
          duration
        }
      };
    } catch (error) {
      if (attempt === maxRetries) throw error;
    }
  }
}
```

### Cross-Origin Timing Information

Timing details are restricted for cross-origin requests unless CORS headers permit:

```javascript
// Server must send: Timing-Allow-Origin: *
// Or: Timing-Allow-Origin: https://your-domain.com

const entry = performance.getEntriesByType('resource')
  .find(e => e.name === 'https://api.example.com/data');

if (entry.domainLookupStart === 0 && 
    entry.connectStart === 0 && 
    entry.requestStart === 0) {
  console.log('Detailed timing blocked by CORS');
}
```

### Performance Budget Monitoring

Set and enforce performance budgets:

```javascript
const PERFORMANCE_BUDGET = {
  maxDuration: 1000,      // ms
  maxTransferSize: 500000, // bytes
  maxTTFB: 200            // ms
};

function checkPerformanceBudget(entry) {
  const violations = [];
  
  if (entry.duration > PERFORMANCE_BUDGET.maxDuration) {
    violations.push(`Duration exceeded: ${entry.duration}ms`);
  }
  
  if (entry.transferSize > PERFORMANCE_BUDGET.maxTransferSize) {
    violations.push(`Transfer size exceeded: ${entry.transferSize} bytes`);
  }
  
  const ttfb = entry.responseStart - entry.requestStart;
  if (ttfb > PERFORMANCE_BUDGET.maxTTFB) {
    violations.push(`TTFB exceeded: ${ttfb}ms`);
  }
  
  return violations;
}
```

### User-Centric Performance Metrics

Correlate fetch operations with user experience:

```javascript
function measureUserImpact(entry) {
  // Calculate if fetch blocked user interaction
  const blockingTime = entry.duration;
  
  // [Inference] Estimate perceived performance
  const isPerceptiblyFast = entry.duration < 100;
  const causedJank = blockingTime > 50;
  
  return {
    blockingTime,
    isPerceptiblyFast,
    causedJank,
    userImpact: causedJank ? 'negative' : 'neutral'
  };
}
```

### Aggregated Performance Reporting

Collect and analyze performance across multiple requests:

```javascript
class FetchPerformanceMonitor {
  constructor() {
    this.metrics = [];
  }
  
  observe() {
    const observer = new PerformanceObserver((list) => {
      list.getEntries().forEach((entry) => {
        if (entry.initiatorType === 'fetch') {
          this.metrics.push({
            url: entry.name,
            duration: entry.duration,
            transferSize: entry.transferSize,
            protocol: entry.nextHopProtocol,
            cached: entry.transferSize === 0
          });
        }
      });
    });
    
    observer.observe({ entryTypes: ['resource'] });
    return observer;
  }
  
  getStats() {
    const durations = this.metrics.map(m => m.duration);
    const sizes = this.metrics.map(m => m.transferSize);
    
    return {
      totalRequests: this.metrics.length,
      averageDuration: durations.reduce((a, b) => a + b, 0) / durations.length,
      medianDuration: this.median(durations),
      p95Duration: this.percentile(durations, 95),
      totalTransferred: sizes.reduce((a, b) => a + b, 0),
      cacheHitRate: this.metrics.filter(m => m.cached).length / this.metrics.length
    };
  }
  
  median(arr) {
    const sorted = [...arr].sort((a, b) => a - b);
    const mid = Math.floor(sorted.length / 2);
    return sorted.length % 2 ? sorted[mid] : (sorted[mid - 1] + sorted[mid]) / 2;
  }
  
  percentile(arr, p) {
    const sorted = [...arr].sort((a, b) => a - b);
    const index = Math.ceil((p / 100) * sorted.length) - 1;
    return sorted[index];
  }
}
```

### Real User Monitoring (RUM) Integration

Export metrics for analytics platforms:

```javascript
function exportFetchMetrics(entry) {
  const metrics = {
    timestamp: Date.now(),
    url: entry.name,
    duration: entry.duration,
    transferSize: entry.transferSize,
    protocol: entry.nextHopProtocol,
    cached: entry.transferSize === 0,
    ttfb: entry.responseStart - entry.requestStart,
    dns: entry.domainLookupEnd - entry.domainLookupStart,
    tcp: entry.connectEnd - entry.connectStart,
    ssl: entry.secureConnectionStart > 0 ? 
         entry.connectEnd - entry.secureConnectionStart : 0
  };
  
  // Send to analytics endpoint
  navigator.sendBeacon('/analytics/fetch-metrics', JSON.stringify(metrics));
}
```

---

