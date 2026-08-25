## Performance Profiling


### Basic Timing Measurement

Using `performance.now()` for high-resolution timing:

```javascript
const start = performance.now();

const response = await fetch('https://api.example.com/data');
const data = await response.json();

const end = performance.now();
const duration = end - start;

console.log(`Request completed in ${duration.toFixed(2)}ms`);
```

### Breaking Down Request Phases

```javascript
async function profileFetchPhases(url, options = {}) {
  const timings = {
    start: performance.now(),
    fetchStart: 0,
    responseStart: 0,
    responseEnd: 0,
    parseStart: 0,
    parseEnd: 0
  };

  timings.fetchStart = performance.now();
  const response = await fetch(url, options);
  timings.responseStart = performance.now();

  const data = await response.json();
  timings.responseEnd = performance.now();
  timings.parseStart = timings.responseEnd;
  timings.parseEnd = performance.now();

  return {
    data,
    phases: {
      fetch: timings.responseStart - timings.fetchStart,
      download: timings.responseEnd - timings.responseStart,
      parse: timings.parseEnd - timings.parseStart,
      total: timings.parseEnd - timings.start
    }
  };
}

// Usage
const result = await profileFetchPhases('https://api.example.com/data');
console.log('Timing phases:', result.phases);
```

### Resource Timing API Integration

The Resource Timing API provides detailed performance data for fetched resources:

```javascript
async function fetchWithResourceTiming(url, options = {}) {
  const startMark = `fetch-start-${Date.now()}`;
  performance.mark(startMark);

  const response = await fetch(url, options);
  const data = await response.json();

  const endMark = `fetch-end-${Date.now()}`;
  performance.mark(endMark);

  // Get resource timing entry
  const entries = performance.getEntriesByType('resource');
  const entry = entries.find(e => e.name === url);

  return {
    data,
    timing: entry ? {
      duration: entry.duration,
      fetchStart: entry.fetchStart,
      domainLookupStart: entry.domainLookupStart,
      domainLookupEnd: entry.domainLookupEnd,
      connectStart: entry.connectStart,
      connectEnd: entry.connectEnd,
      secureConnectionStart: entry.secureConnectionStart,
      requestStart: entry.requestStart,
      responseStart: entry.responseStart,
      responseEnd: entry.responseEnd,
      transferSize: entry.transferSize,
      encodedBodySize: entry.encodedBodySize,
      decodedBodySize: entry.decodedBodySize
    } : null
  };
}
```

### Calculating Detailed Metrics

```javascript
function analyzeResourceTiming(entry) {
  if (!entry) return null;

  return {
    // DNS lookup time
    dns: entry.domainLookupEnd - entry.domainLookupStart,
    
    // TCP connection time
    tcp: entry.connectEnd - entry.connectStart,
    
    // TLS negotiation time (HTTPS only)
    tls: entry.secureConnectionStart > 0 
      ? entry.connectEnd - entry.secureConnectionStart 
      : 0,
    
    // Time to first byte (TTFB)
    ttfb: entry.responseStart - entry.requestStart,
    
    // Content download time
    download: entry.responseEnd - entry.responseStart,
    
    // Total request time
    total: entry.responseEnd - entry.fetchStart,
    
    // Size metrics
    transferSize: entry.transferSize,
    encodedBodySize: entry.encodedBodySize,
    decodedBodySize: entry.decodedBodySize,
    
    // Compression ratio
    compressionRatio: entry.encodedBodySize > 0
      ? (entry.decodedBodySize / entry.encodedBodySize).toFixed(2)
      : 1
  };
}

// Usage
const result = await fetchWithResourceTiming('https://api.example.com/data');
const metrics = analyzeResourceTiming(result.timing);
console.log('Detailed metrics:', metrics);
```

### Performance Observer for Continuous Monitoring

```javascript
class FetchPerformanceMonitor {
  constructor() {
    this.metrics = [];
    this.observer = null;
  }

  start() {
    if (!('PerformanceObserver' in window)) {
      console.warn('PerformanceObserver not supported');
      return;
    }

    this.observer = new PerformanceObserver((list) => {
      for (const entry of list.getEntries()) {
        if (entry.initiatorType === 'fetch' || entry.initiatorType === 'xmlhttprequest') {
          this.metrics.push({
            url: entry.name,
            timestamp: entry.startTime,
            duration: entry.duration,
            transferSize: entry.transferSize,
            protocol: entry.nextHopProtocol,
            details: this.analyzeEntry(entry)
          });
        }
      }
    });

    this.observer.observe({ entryTypes: ['resource'] });
  }

  stop() {
    if (this.observer) {
      this.observer.disconnect();
      this.observer = null;
    }
  }

  analyzeEntry(entry) {
    return {
      dns: entry.domainLookupEnd - entry.domainLookupStart,
      tcp: entry.connectEnd - entry.connectStart,
      tls: entry.secureConnectionStart > 0 
        ? entry.connectEnd - entry.secureConnectionStart 
        : 0,
      ttfb: entry.responseStart - entry.requestStart,
      download: entry.responseEnd - entry.responseStart
    };
  }

  getMetrics() {
    return this.metrics;
  }

  getAverages() {
    if (this.metrics.length === 0) return null;

    const sum = this.metrics.reduce((acc, m) => ({
      duration: acc.duration + m.duration,
      transferSize: acc.transferSize + (m.transferSize || 0),
      dns: acc.dns + (m.details.dns || 0),
      tcp: acc.tcp + (m.details.tcp || 0),
      ttfb: acc.ttfb + (m.details.ttfb || 0),
      download: acc.download + (m.details.download || 0)
    }), { duration: 0, transferSize: 0, dns: 0, tcp: 0, ttfb: 0, download: 0 });

    const count = this.metrics.length;

    return {
      duration: sum.duration / count,
      transferSize: sum.transferSize / count,
      dns: sum.dns / count,
      tcp: sum.tcp / count,
      ttfb: sum.ttfb / count,
      download: sum.download / count,
      count
    };
  }

  clear() {
    this.metrics = [];
  }
}

// Usage
const monitor = new FetchPerformanceMonitor();
monitor.start();

// Make requests...
await fetch('https://api.example.com/data1');
await fetch('https://api.example.com/data2');

// Later...
const averages = monitor.getAverages();
console.log('Average metrics:', averages);
monitor.stop();
```

### Performance Marks and Measures

```javascript
async function fetchWithMarks(url, options = {}) {
  const markId = `fetch-${Date.now()}`;
  
  performance.mark(`${markId}-start`);
  
  const response = await fetch(url, options);
  performance.mark(`${markId}-response-received`);
  
  const data = await response.json();
  performance.mark(`${markId}-parsed`);
  
  // Create measures
  performance.measure(
    `${markId}-network`,
    `${markId}-start`,
    `${markId}-response-received`
  );
  
  performance.measure(
    `${markId}-parsing`,
    `${markId}-response-received`,
    `${markId}-parsed`
  );
  
  performance.measure(
    `${markId}-total`,
    `${markId}-start`,
    `${markId}-parsed`
  );
  
  // Retrieve measures
  const network = performance.getEntriesByName(`${markId}-network`)[0];
  const parsing = performance.getEntriesByName(`${markId}-parsing`)[0];
  const total = performance.getEntriesByName(`${markId}-total`)[0];
  
  // Cleanup
  performance.clearMarks(`${markId}-start`);
  performance.clearMarks(`${markId}-response-received`);
  performance.clearMarks(`${markId}-parsed`);
  performance.clearMeasures(`${markId}-network`);
  performance.clearMeasures(`${markId}-parsing`);
  performance.clearMeasures(`${markId}-total`);
  
  return {
    data,
    timings: {
      network: network.duration,
      parsing: parsing.duration,
      total: total.duration
    }
  };
}
```

### Memory Profiling

**[Inference]**: Memory usage tracking through `performance.memory` is Chrome-specific and may not be available or accurate in all browsers.

```javascript
class FetchMemoryProfiler {
  constructor() {
    this.hasMemoryAPI = 'memory' in performance;
  }

  getMemorySnapshot() {
    if (!this.hasMemoryAPI) {
      return null;
    }

    return {
      usedJSHeapSize: performance.memory.usedJSHeapSize,
      totalJSHeapSize: performance.memory.totalJSHeapSize,
      jsHeapSizeLimit: performance.memory.jsHeapSizeLimit
    };
  }

  async profileFetchMemory(url, options = {}) {
    if (!this.hasMemoryAPI) {
      console.warn('Memory API not available');
      return { data: null, memory: null };
    }

    const before = this.getMemorySnapshot();
    
    const response = await fetch(url, options);
    const data = await response.json();
    
    const after = this.getMemorySnapshot();
    
    return {
      data,
      memory: {
        before,
        after,
        delta: after.usedJSHeapSize - before.usedJSHeapSize,
        percentage: ((after.usedJSHeapSize - before.usedJSHeapSize) / before.usedJSHeapSize * 100).toFixed(2)
      }
    };
  }
}
```

### Profiling Streaming Responses

```javascript
async function profileStreamingFetch(url, options = {}) {
  const timings = {
    start: performance.now(),
    firstChunk: null,
    chunks: [],
    end: null
  };

  const response = await fetch(url, options);
  const reader = response.body.getReader();
  
  let firstChunk = true;
  let totalBytes = 0;

  try {
    while (true) {
      const chunkStart = performance.now();
      const { done, value } = await reader.read();
      
      if (done) break;
      
      const chunkEnd = performance.now();
      
      if (firstChunk) {
        timings.firstChunk = chunkEnd - timings.start;
        firstChunk = false;
      }
      
      totalBytes += value.length;
      
      timings.chunks.push({
        size: value.length,
        duration: chunkEnd - chunkStart,
        timestamp: chunkEnd - timings.start
      });
    }
  } finally {
    reader.releaseLock();
  }
  
  timings.end = performance.now();
  
  return {
    totalBytes,
    totalDuration: timings.end - timings.start,
    firstChunkTime: timings.firstChunk,
    avgChunkSize: totalBytes / timings.chunks.length,
    avgChunkDuration: timings.chunks.reduce((sum, c) => sum + c.duration, 0) / timings.chunks.length,
    chunks: timings.chunks,
    throughput: (totalBytes / ((timings.end - timings.start) / 1000)).toFixed(2) // bytes per second
  };
}
```

### Profiling Concurrent Requests

```javascript
async function profileConcurrentFetches(urls, options = {}) {
  const startTime = performance.now();
  const results = [];

  const promises = urls.map(async (url, index) => {
    const requestStart = performance.now();
    
    try {
      const response = await fetch(url, options);
      const responseReceived = performance.now();
      
      const data = await response.json();
      const parseComplete = performance.now();
      
      return {
        url,
        index,
        success: true,
        timings: {
          queue: requestStart - startTime,
          network: responseReceived - requestStart,
          parse: parseComplete - responseReceived,
          total: parseComplete - requestStart
        },
        size: JSON.stringify(data).length,
        data
      };
    } catch (error) {
      return {
        url,
        index,
        success: false,
        error: error.message,
        timings: {
          total: performance.now() - requestStart
        }
      };
    }
  });

  const allResults = await Promise.all(promises);
  const endTime = performance.now();

  return {
    results: allResults,
    summary: {
      total: endTime - startTime,
      successful: allResults.filter(r => r.success).length,
      failed: allResults.filter(r => !r.success).length,
      avgNetworkTime: allResults
        .filter(r => r.success)
        .reduce((sum, r) => sum + r.timings.network, 0) / allResults.filter(r => r.success).length,
      maxTime: Math.max(...allResults.map(r => r.timings.total)),
      minTime: Math.min(...allResults.map(r => r.timings.total))
    }
  };
}
```

### Cache Performance Analysis

```javascript
async function profileCachePerformance(url, options = {}) {
  const profiles = [];

  // First request (likely cache miss)
  const firstStart = performance.now();
  await fetch(url, { ...options, cache: 'default' });
  const firstDuration = performance.now() - firstStart;
  
  profiles.push({
    attempt: 1,
    cacheStatus: 'miss',
    duration: firstDuration
  });

  // Wait briefly
  await new Promise(resolve => setTimeout(resolve, 100));

  // Second request (likely cache hit)
  const secondStart = performance.now();
  await fetch(url, { ...options, cache: 'default' });
  const secondDuration = performance.now() - secondStart;
  
  profiles.push({
    attempt: 2,
    cacheStatus: 'hit',
    duration: secondDuration
  });

  // Force reload (cache miss)
  const reloadStart = performance.now();
  await fetch(url, { ...options, cache: 'reload' });
  const reloadDuration = performance.now() - reloadStart;
  
  profiles.push({
    attempt: 3,
    cacheStatus: 'forced-miss',
    duration: reloadDuration
  });

  return {
    profiles,
    analysis: {
      cacheSpeedup: ((firstDuration - secondDuration) / firstDuration * 100).toFixed(2) + '%',
      cachedRequestTime: secondDuration,
      uncachedRequestTime: firstDuration
    }
  };
}
```

### Network Throttling Detection

**[Inference]**: Network conditions cannot be directly detected but can be inferred from timing patterns.

```javascript
class NetworkPerformanceAnalyzer {
  constructor() {
    this.samples = [];
  }

  async measureConnectionQuality(testUrl, sampleCount = 5) {
    const samples = [];

    for (let i = 0; i < sampleCount; i++) {
      const start = performance.now();
      
      try {
        const response = await fetch(testUrl, { cache: 'no-store' });
        await response.blob();
        
        const duration = performance.now() - start;
        samples.push({ success: true, duration });
      } catch (error) {
        samples.push({ success: false, duration: null });
      }
      
      // Brief delay between samples
      if (i < sampleCount - 1) {
        await new Promise(resolve => setTimeout(resolve, 100));
      }
    }

    const successful = samples.filter(s => s.success);
    const durations = successful.map(s => s.duration);
    
    if (durations.length === 0) {
      return { quality: 'unknown', samples };
    }

    const avg = durations.reduce((a, b) => a + b, 0) / durations.length;
    const variance = durations.reduce((sum, d) => sum + Math.pow(d - avg, 2), 0) / durations.length;
    const stdDev = Math.sqrt(variance);

    return {
      quality: this.classifyQuality(avg, stdDev),
      stats: {
        average: avg,
        min: Math.min(...durations),
        max: Math.max(...durations),
        stdDev,
        variance,
        successRate: (successful.length / samples.length * 100).toFixed(2) + '%'
      },
      samples
    };
  }

  classifyQuality(avg, stdDev) {
    // [Inference]: These thresholds are approximate classifications
    if (avg < 100 && stdDev < 50) return 'excellent';
    if (avg < 300 && stdDev < 100) return 'good';
    if (avg < 1000 && stdDev < 300) return 'fair';
    return 'poor';
  }
}
```

### Waterfall Visualization Data

```javascript
class FetchWaterfallProfiler {
  constructor() {
    this.requests = [];
  }

  async profileRequest(url, options = {}, label = '') {
    const id = `req-${this.requests.length}`;
    const startTime = performance.now();
    
    const entry = {
      id,
      label: label || url,
      url,
      startTime,
      phases: {}
    };

    try {
      const responseStart = performance.now();
      const response = await fetch(url, options);
      const responseReceived = performance.now();
      
      const data = await response.json();
      const parseComplete = performance.now();
      
      entry.phases = {
        queued: { start: 0, duration: 0 },
        dns: { start: 0, duration: 0 },
        tcp: { start: 0, duration: 0 },
        request: { start: 0, duration: responseReceived - responseStart },
        download: { start: responseReceived - startTime, duration: parseComplete - responseReceived }
      };
      
      entry.endTime = parseComplete;
      entry.totalDuration = parseComplete - startTime;
      entry.success = true;
      entry.status = response.status;
      
      // Try to get resource timing for more detail
      const resourceEntry = performance.getEntriesByName(url)[0];
      if (resourceEntry) {
        this.enhanceWithResourceTiming(entry, resourceEntry, startTime);
      }
      
    } catch (error) {
      entry.endTime = performance.now();
      entry.totalDuration = entry.endTime - startTime;
      entry.success = false;
      entry.error = error.message;
    }
    
    this.requests.push(entry);
    return entry;
  }

  enhanceWithResourceTiming(entry, resourceEntry, baseTime) {
    entry.phases = {
      dns: {
        start: resourceEntry.domainLookupStart,
        duration: resourceEntry.domainLookupEnd - resourceEntry.domainLookupStart
      },
      tcp: {
        start: resourceEntry.connectStart,
        duration: resourceEntry.connectEnd - resourceEntry.connectStart
      },
      tls: {
        start: resourceEntry.secureConnectionStart,
        duration: resourceEntry.secureConnectionStart > 0 
          ? resourceEntry.connectEnd - resourceEntry.secureConnectionStart 
          : 0
      },
      request: {
        start: resourceEntry.requestStart,
        duration: resourceEntry.responseStart - resourceEntry.requestStart
      },
      download: {
        start: resourceEntry.responseStart,
        duration: resourceEntry.responseEnd - resourceEntry.responseStart
      }
    };
  }

  getWaterfallData() {
    if (this.requests.length === 0) return null;

    const minStart = Math.min(...this.requests.map(r => r.startTime));
    
    return {
      requests: this.requests.map(req => ({
        ...req,
        relativeStart: req.startTime - minStart,
        relativeEnd: req.endTime - minStart
      })),
      totalSpan: Math.max(...this.requests.map(r => r.endTime)) - minStart
    };
  }

  clear() {
    this.requests = [];
  }
}

// Usage
const profiler = new FetchWaterfallProfiler();

await profiler.profileRequest('https://api.example.com/users', {}, 'Users API');
await profiler.profileRequest('https://api.example.com/posts', {}, 'Posts API');
await profiler.profileRequest('https://api.example.com/comments', {}, 'Comments API');

const waterfall = profiler.getWaterfallData();
console.log('Waterfall data:', waterfall);
```

### Custom Performance Budget

```javascript
class PerformanceBudget {
  constructor(budgets) {
    this.budgets = budgets; // e.g., { dns: 50, tcp: 100, ttfb: 200, download: 500 }
    this.violations = [];
  }

  async checkFetch(url, options = {}) {
    const start = performance.now();
    const response = await fetch(url, options);
    await response.json();
    
    // Get resource timing
    const entries = performance.getEntriesByName(url);
    const entry = entries[entries.length - 1];
    
    if (!entry) {
      return { passed: false, reason: 'No timing data available' };
    }

    const metrics = {
      dns: entry.domainLookupEnd - entry.domainLookupStart,
      tcp: entry.connectEnd - entry.connectStart,
      ttfb: entry.responseStart - entry.requestStart,
      download: entry.responseEnd - entry.responseStart,
      total: entry.responseEnd - entry.fetchStart
    };

    const violations = [];
    
    for (const [metric, budget] of Object.entries(this.budgets)) {
      if (metrics[metric] > budget) {
        violations.push({
          metric,
          actual: metrics[metric],
          budget,
          exceeded: metrics[metric] - budget
        });
      }
    }

    if (violations.length > 0) {
      this.violations.push({ url, violations, timestamp: Date.now() });
    }

    return {
      passed: violations.length === 0,
      metrics,
      violations
    };
  }

  getViolations() {
    return this.violations;
  }

  clear() {
    this.violations = [];
  }
}

// Usage
const budget = new PerformanceBudget({
  dns: 50,
  tcp: 100,
  ttfb: 200,
  download: 500,
  total: 1000
});

const result = await budget.checkFetch('https://api.example.com/data');
if (!result.passed) {
  console.warn('Performance budget violations:', result.violations);
}
```

### Comprehensive Performance Suite

```javascript
class FetchPerformanceSuite {
  constructor() {
    this.monitor = new FetchPerformanceMonitor();
    this.waterfallProfiler = new FetchWaterfallProfiler();
    this.results = [];
  }

  async profile(url, options = {}, config = {}) {
    const {
      measureMemory = false,
      measureCache = false,
      label = url
    } = config;

    const result = {
      url,
      label,
      timestamp: Date.now(),
      timings: {},
      resourceTiming: null,
      memory: null,
      cache: null
    };

    // Basic timing
    const start = performance.now();
    const response = await fetch(url, options);
    const responseTime = performance.now();
    const data = await response.json();
    const parseTime = performance.now();

    result.timings = {
      network: responseTime - start,
      parse: parseTime - responseTime,
      total: parseTime - start
    };

    // Resource timing
    const entries = performance.getEntriesByName(url);
    if (entries.length > 0) {
      const entry = entries[entries.length - 1];
      result.resourceTiming = analyzeResourceTiming(entry);
    }

    // Memory profiling
    if (measureMemory && 'memory' in performance) {
      const memProfiler = new FetchMemoryProfiler();
      result.memory = memProfiler.getMemorySnapshot();
    }

    // Cache performance
    if (measureCache) {
      result.cache = await profileCachePerformance(url, options);
    }

    this.results.push(result);
    
    return {
      data,
      performance: result
    };
  }

  getReport() {
    if (this.results.length === 0) {
      return { error: 'No profiling data available' };
    }

    const timings = this.results.map(r => r.timings);
    
    return {
      count: this.results.length,
      averages: {
        network: timings.reduce((sum, t) => sum + t.network, 0) / timings.length,
        parse: timings.reduce((sum, t) => sum + t.parse, 0) / timings.length,
        total: timings.reduce((sum, t) => sum + t.total, 0) / timings.length
      },
      min: {
        network: Math.min(...timings.map(t => t.network)),
        parse: Math.min(...timings.map(t => t.parse)),
        total: Math.min(...timings.map(t => t.total))
      },
      max: {
        network: Math.max(...timings.map(t => t.network)),
        parse: Math.max(...timings.map(t => t.parse)),
        total: Math.max(...timings.map(t => t.total))
      },
      results: this.results
    };
  }

  exportData(format = 'json') {
    const report = this.getReport();
    
    if (format === 'json') {
      return JSON.stringify(report, null, 2);
    }
    
    if (format === 'csv') {
      // Simple CSV export
      const headers = ['URL', 'Label', 'Network (ms)', 'Parse (ms)', 'Total (ms)'];
      const rows = this.results.map(r => [
        r.url,
        r.label,
        r.timings.network.toFixed(2),
        r.timings.parse.toFixed(2),
        r.timings.total.toFixed(2)
      ]);
      
      return [headers, ...rows].map(row => row.join(',')).join('\n');
    }
    
    return report;
  }

  clear() {
    this.results = [];
  }
}

// Usage
const suite = new FetchPerformanceSuite();

await suite.profile('https://api.example.com/users', {}, { 
  label: 'Users API',
  measureMemory: true,
  measureCache: true
});

await suite.profile('https://api.example.com/posts', {}, { 
  label: 'Posts API'
});

const report = suite.getReport();
console.log('Performance Report:', report);

// Export as CSV
const csv = suite.exportData('csv');
console.log(csv);
```

---

