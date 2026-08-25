## Fetch API Custom Metrics


### User Timing API for Fetch Operations

Create custom performance marks and measures around fetch operations:

```javascript
performance.mark('user-action-start');

const response = await fetch('/api/data');
performance.mark('fetch-complete');

const data = await response.json();
performance.mark('parsing-complete');

performance.measure('fetch-duration', 'user-action-start', 'fetch-complete');
performance.measure('parse-duration', 'fetch-complete', 'parsing-complete');
performance.measure('total-operation', 'user-action-start', 'parsing-complete');

const measures = performance.getEntriesByType('measure');
measures.forEach(measure => {
  console.log(`${measure.name}: ${measure.duration}ms`);
});
```

### Custom Metric Collection Classes

#### Basic Fetch Metrics Collector

```javascript
class FetchMetrics {
  constructor(name) {
    this.name = name;
    this.startTime = null;
    this.endTime = null;
    this.metrics = {};
  }
  
  start() {
    this.startTime = performance.now();
    this.metrics.startTimestamp = Date.now();
  }
  
  recordFetchStart() {
    this.metrics.fetchStartTime = performance.now();
  }
  
  recordFetchEnd() {
    this.metrics.fetchEndTime = performance.now();
    this.metrics.fetchDuration = this.metrics.fetchEndTime - this.metrics.fetchStartTime;
  }
  
  recordParseStart() {
    this.metrics.parseStartTime = performance.now();
  }
  
  recordParseEnd() {
    this.metrics.parseEndTime = performance.now();
    this.metrics.parseDuration = this.metrics.parseEndTime - this.metrics.parseStartTime;
  }
  
  end() {
    this.endTime = performance.now();
    this.metrics.totalDuration = this.endTime - this.startTime;
    this.metrics.endTimestamp = Date.now();
    return this.metrics;
  }
}

// Usage
const metrics = new FetchMetrics('api-call');
metrics.start();

metrics.recordFetchStart();
const response = await fetch('/api/data');
metrics.recordFetchEnd();

metrics.recordParseStart();
const data = await response.json();
metrics.recordParseEnd();

console.log(metrics.end());
```

#### Advanced Metrics with Metadata

```javascript
class DetailedFetchMetrics {
  constructor(url, options = {}) {
    this.url = url;
    this.method = options.method || 'GET';
    this.startTime = performance.now();
    this.phases = {};
    this.metadata = {};
    this.errors = [];
  }
  
  phase(name) {
    const now = performance.now();
    const previousPhase = this.currentPhase;
    
    if (previousPhase) {
      this.phases[previousPhase].end = now;
      this.phases[previousPhase].duration = now - this.phases[previousPhase].start;
    }
    
    this.phases[name] = {
      start: now,
      end: null,
      duration: null
    };
    
    this.currentPhase = name;
    return this;
  }
  
  addMetadata(key, value) {
    this.metadata[key] = value;
    return this;
  }
  
  recordError(error) {
    this.errors.push({
      message: error.message,
      timestamp: performance.now(),
      phase: this.currentPhase
    });
    return this;
  }
  
  complete() {
    if (this.currentPhase) {
      const now = performance.now();
      this.phases[this.currentPhase].end = now;
      this.phases[this.currentPhase].duration = now - this.phases[this.currentPhase].start;
    }
    
    return {
      url: this.url,
      method: this.method,
      totalDuration: performance.now() - this.startTime,
      phases: this.phases,
      metadata: this.metadata,
      errors: this.errors,
      timestamp: Date.now()
    };
  }
}

// Usage
const metrics = new DetailedFetchMetrics('/api/users', { method: 'POST' });

metrics.phase('validation').addMetadata('payloadSize', JSON.stringify(data).length);

try {
  metrics.phase('network');
  const response = await fetch('/api/users', {
    method: 'POST',
    body: JSON.stringify(data)
  });
  
  metrics.addMetadata('statusCode', response.status)
        .addMetadata('contentType', response.headers.get('content-type'));
  
  metrics.phase('deserialization');
  const result = await response.json();
  
  metrics.addMetadata('resultSize', JSON.stringify(result).length);
} catch (error) {
  metrics.recordError(error);
}

console.log(metrics.complete());
```

### Business Logic Metrics

Track custom business-relevant metrics:

```javascript
class BusinessMetrics {
  constructor() {
    this.metrics = {};
  }
  
  async trackDataFreshness(url, cacheKey) {
    const cached = localStorage.getItem(cacheKey);
    const cacheTimestamp = localStorage.getItem(`${cacheKey}_timestamp`);
    
    const startTime = performance.now();
    const response = await fetch(url);
    const data = await response.json();
    
    const freshness = cacheTimestamp ? 
      Date.now() - parseInt(cacheTimestamp) : null;
    
    return {
      fetchDuration: performance.now() - startTime,
      dataFreshness: freshness,
      cacheHit: !!cached,
      cacheAge: freshness ? `${(freshness / 1000 / 60).toFixed(2)} minutes` : 'N/A'
    };
  }
  
  async trackConversionPath(steps) {
    const metrics = {
      steps: [],
      totalDuration: 0,
      stepCount: steps.length
    };
    
    const overallStart = performance.now();
    
    for (const step of steps) {
      const stepStart = performance.now();
      
      try {
        await step.action();
        
        metrics.steps.push({
          name: step.name,
          duration: performance.now() - stepStart,
          success: true
        });
      } catch (error) {
        metrics.steps.push({
          name: step.name,
          duration: performance.now() - stepStart,
          success: false,
          error: error.message
        });
        break;
      }
    }
    
    metrics.totalDuration = performance.now() - overallStart;
    metrics.completionRate = metrics.steps.filter(s => s.success).length / steps.length;
    
    return metrics;
  }
  
  async trackSearchQuality(query, resultsUrl) {
    const startTime = performance.now();
    const response = await fetch(resultsUrl);
    const results = await response.json();
    
    return {
      query,
      responseTime: performance.now() - startTime,
      resultCount: results.length,
      emptyResults: results.length === 0,
      avgResultSize: results.reduce((sum, r) => sum + JSON.stringify(r).length, 0) / results.length
    };
  }
}
```

### Retry and Resilience Metrics

Track retry behavior and failure patterns:

```javascript
class RetryMetrics {
  constructor(maxRetries = 3) {
    this.maxRetries = maxRetries;
    this.attempts = [];
  }
  
  async fetchWithRetry(url, options = {}) {
    const startTime = performance.now();
    
    for (let attempt = 1; attempt <= this.maxRetries; attempt++) {
      const attemptStart = performance.now();
      
      try {
        const response = await fetch(url, options);
        
        this.attempts.push({
          attempt,
          duration: performance.now() - attemptStart,
          success: true,
          statusCode: response.status
        });
        
        return {
          response,
          metrics: this.getMetrics(performance.now() - startTime)
        };
      } catch (error) {
        this.attempts.push({
          attempt,
          duration: performance.now() - attemptStart,
          success: false,
          error: error.name,
          errorMessage: error.message
        });
        
        if (attempt === this.maxRetries) {
          return {
            response: null,
            metrics: this.getMetrics(performance.now() - startTime)
          };
        }
        
        // Exponential backoff
        await new Promise(resolve => setTimeout(resolve, Math.pow(2, attempt) * 100));
      }
    }
  }
  
  getMetrics(totalDuration) {
    const successfulAttempts = this.attempts.filter(a => a.success).length;
    const failedAttempts = this.attempts.filter(a => !a.success).length;
    
    return {
      totalDuration,
      attemptsCount: this.attempts.length,
      successfulAttempts,
      failedAttempts,
      successRate: successfulAttempts / this.attempts.length,
      attempts: this.attempts,
      finalStatus: this.attempts[this.attempts.length - 1].success ? 'success' : 'failed'
    };
  }
}

// Usage
const retryMetrics = new RetryMetrics(3);
const result = await retryMetrics.fetchWithRetry('/api/unreliable-endpoint');
console.log(result.metrics);
```

### Request Waterfall Tracking

Track dependencies and sequential/parallel request patterns:

```javascript
class WaterfallMetrics {
  constructor() {
    this.requests = [];
    this.startTime = performance.now();
  }
  
  async trackRequest(name, fetchPromise, dependencies = []) {
    const request = {
      name,
      dependencies,
      startTime: performance.now(),
      endTime: null,
      duration: null,
      startOffset: performance.now() - this.startTime
    };
    
    try {
      const result = await fetchPromise;
      request.endTime = performance.now();
      request.duration = request.endTime - request.startTime;
      request.success = true;
      this.requests.push(request);
      return result;
    } catch (error) {
      request.endTime = performance.now();
      request.duration = request.endTime - request.startTime;
      request.success = false;
      request.error = error.message;
      this.requests.push(request);
      throw error;
    }
  }
  
  getWaterfall() {
    return {
      totalDuration: performance.now() - this.startTime,
      requests: this.requests,
      criticalPath: this.calculateCriticalPath(),
      parallelismScore: this.calculateParallelism()
    };
  }
  
  calculateCriticalPath() {
    // [Inference] Find longest dependency chain
    const paths = [];
    
    const findPath = (request, currentPath = []) => {
      const newPath = [...currentPath, request];
      
      const dependents = this.requests.filter(r => 
        r.dependencies.includes(request.name)
      );
      
      if (dependents.length === 0) {
        paths.push(newPath);
      } else {
        dependents.forEach(dep => findPath(dep, newPath));
      }
    };
    
    const roots = this.requests.filter(r => r.dependencies.length === 0);
    roots.forEach(root => findPath(root));
    
    const longestPath = paths.reduce((longest, current) => {
      const currentDuration = current.reduce((sum, r) => sum + r.duration, 0);
      const longestDuration = longest.reduce((sum, r) => sum + r.duration, 0);
      return currentDuration > longestDuration ? current : longest;
    }, []);
    
    return {
      requests: longestPath.map(r => r.name),
      duration: longestPath.reduce((sum, r) => sum + r.duration, 0)
    };
  }
  
  calculateParallelism() {
    // [Inference] Measure how parallel the execution was
    const totalRequestTime = this.requests.reduce((sum, r) => sum + r.duration, 0);
    const wallClockTime = performance.now() - this.startTime;
    return totalRequestTime / wallClockTime;
  }
}

// Usage
const waterfall = new WaterfallMetrics();

const user = await waterfall.trackRequest('user', fetch('/api/user'));
const [profile, settings] = await Promise.all([
  waterfall.trackRequest('profile', fetch('/api/profile'), ['user']),
  waterfall.trackRequest('settings', fetch('/api/settings'), ['user'])
]);
const recommendations = await waterfall.trackRequest(
  'recommendations',
  fetch('/api/recommendations'),
  ['profile']
);

console.log(waterfall.getWaterfall());
```

### Bandwidth and Throughput Metrics

Calculate custom bandwidth metrics:

```javascript
class BandwidthMetrics {
  async measureThroughput(url) {
    const startTime = performance.now();
    let bytesReceived = 0;
    let chunks = [];
    
    const response = await fetch(url);
    const reader = response.body.getReader();
    
    while (true) {
      const { done, value } = await reader.read();
      if (done) break;
      
      bytesReceived += value.length;
      chunks.push({
        timestamp: performance.now(),
        size: value.length,
        totalReceived: bytesReceived
      });
    }
    
    const totalTime = performance.now() - startTime;
    
    return {
      totalBytes: bytesReceived,
      totalTime,
      averageThroughput: (bytesReceived / totalTime) * 1000, // bytes per second
      throughputMBps: ((bytesReceived / totalTime) * 1000) / (1024 * 1024),
      chunks: chunks.length,
      chunkMetrics: this.analyzeChunks(chunks)
    };
  }
  
  analyzeChunks(chunks) {
    if (chunks.length < 2) return null;
    
    const throughputs = [];
    
    for (let i = 1; i < chunks.length; i++) {
      const timeDiff = chunks[i].timestamp - chunks[i - 1].timestamp;
      const sizeDiff = chunks[i].size;
      const throughput = (sizeDiff / timeDiff) * 1000; // bytes per second
      throughputs.push(throughput);
    }
    
    throughputs.sort((a, b) => a - b);
    
    return {
      minThroughput: throughputs[0],
      maxThroughput: throughputs[throughputs.length - 1],
      medianThroughput: throughputs[Math.floor(throughputs.length / 2)],
      variability: (throughputs[throughputs.length - 1] - throughputs[0]) / throughputs[0]
    };
  }
  
  async measureLatency(url, samples = 5) {
    const latencies = [];
    
    for (let i = 0; i < samples; i++) {
      const start = performance.now();
      
      await fetch(url, { method: 'HEAD' });
      
      const latency = performance.now() - start;
      latencies.push(latency);
      
      // Small delay between samples
      if (i < samples - 1) {
        await new Promise(resolve => setTimeout(resolve, 100));
      }
    }
    
    latencies.sort((a, b) => a - b);
    
    return {
      samples: latencies,
      min: latencies[0],
      max: latencies[latencies.length - 1],
      average: latencies.reduce((a, b) => a + b) / latencies.length,
      median: latencies[Math.floor(latencies.length / 2)],
      jitter: latencies[latencies.length - 1] - latencies[0]
    };
  }
}
```

### Cache Effectiveness Metrics

Custom cache hit/miss tracking:

```javascript
class CacheMetrics {
  constructor() {
    this.cacheStats = {
      hits: 0,
      misses: 0,
      partialHits: 0,
      requests: []
    };
  }
  
  async fetchWithCacheTracking(url, options = {}) {
    const startTime = performance.now();
    const cacheMode = options.cache || 'default';
    
    const response = await fetch(url, options);
    const duration = performance.now() - startTime;
    
    // Check if served from cache
    const wasCached = response.headers.get('x-cache') === 'HIT' || 
                      response.headers.has('age');
    
    const requestMetric = {
      url,
      timestamp: Date.now(),
      duration,
      cached: wasCached,
      cacheMode,
      statusCode: response.status
    };
    
    if (wasCached) {
      this.cacheStats.hits++;
    } else {
      this.cacheStats.misses++;
    }
    
    this.cacheStats.requests.push(requestMetric);
    
    return { response, metrics: requestMetric };
  }
  
  getEffectiveness() {
    const total = this.cacheStats.hits + this.cacheStats.misses;
    
    return {
      hitRate: total > 0 ? this.cacheStats.hits / total : 0,
      missRate: total > 0 ? this.cacheStats.misses / total : 0,
      totalRequests: total,
      hits: this.cacheStats.hits,
      misses: this.cacheStats.misses,
      averageHitDuration: this.calculateAverageDuration(true),
      averageMissDuration: this.calculateAverageDuration(false)
    };
  }
  
  calculateAverageDuration(cached) {
    const filtered = this.cacheStats.requests.filter(r => r.cached === cached);
    if (filtered.length === 0) return 0;
    return filtered.reduce((sum, r) => sum + r.duration, 0) / filtered.length;
  }
}
```

### Error Rate and Reliability Metrics

Track error patterns and reliability:

```javascript
class ReliabilityMetrics {
  constructor(window = 100) {
    this.window = window;
    this.requests = [];
  }
  
  async trackRequest(url, options = {}) {
    const startTime = performance.now();
    const request = {
      url,
      timestamp: Date.now(),
      startTime,
      endTime: null,
      duration: null,
      success: false,
      statusCode: null,
      error: null
    };
    
    try {
      const response = await fetch(url, options);
      request.endTime = performance.now();
      request.duration = request.endTime - request.startTime;
      request.statusCode = response.status;
      request.success = response.ok;
      
      this.requests.push(request);
      this.trimWindow();
      
      return { response, metrics: this.getMetrics() };
    } catch (error) {
      request.endTime = performance.now();
      request.duration = request.endTime - request.startTime;
      request.error = error.name;
      request.success = false;
      
      this.requests.push(request);
      this.trimWindow();
      
      throw error;
    }
  }
  
  trimWindow() {
    if (this.requests.length > this.window) {
      this.requests = this.requests.slice(-this.window);
    }
  }
  
  getMetrics() {
    const successful = this.requests.filter(r => r.success);
    const failed = this.requests.filter(r => !r.success);
    
    return {
      totalRequests: this.requests.length,
      successfulRequests: successful.length,
      failedRequests: failed.length,
      successRate: successful.length / this.requests.length,
      errorRate: failed.length / this.requests.length,
      availability: this.calculateAvailability(),
      mtbf: this.calculateMTBF(),
      errorsByType: this.groupErrorsByType()
    };
  }
  
  calculateAvailability() {
    // [Inference] Calculate uptime percentage based on success rate
    const successful = this.requests.filter(r => r.success).length;
    return successful / this.requests.length;
  }
  
  calculateMTBF() {
    // [Inference] Mean time between failures
    const failures = this.requests
      .map((r, i) => ({ ...r, index: i }))
      .filter(r => !r.success);
    
    if (failures.length < 2) return null;
    
    const timeBetweenFailures = [];
    for (let i = 1; i < failures.length; i++) {
      const timeDiff = failures[i].timestamp - failures[i - 1].timestamp;
      timeBetweenFailures.push(timeDiff);
    }
    
    return timeBetweenFailures.reduce((a, b) => a + b) / timeBetweenFailures.length;
  }
  
  groupErrorsByType() {
    const errors = this.requests.filter(r => !r.success);
    const grouped = {};
    
    errors.forEach(error => {
      const key = error.error || `HTTP ${error.statusCode}`;
      grouped[key] = (grouped[key] || 0) + 1;
    });
    
    return grouped;
  }
}
```

### Custom Performance Observers

Create specialized observers for fetch events:

```javascript
class FetchObserver {
  constructor(callback) {
    this.callback = callback;
    this.metrics = [];
    this.setupObserver();
  }
  
  setupObserver() {
    const observer = new PerformanceObserver((list) => {
      list.getEntries().forEach((entry) => {
        if (entry.initiatorType === 'fetch') {
          const customMetrics = this.enrichMetrics(entry);
          this.metrics.push(customMetrics);
          this.callback(customMetrics);
        }
      });
    });
    
    observer.observe({ entryTypes: ['resource'] });
    this.observer = observer;
  }
  
  enrichMetrics(entry) {
    const dns = entry.domainLookupEnd - entry.domainLookupStart;
    const tcp = entry.connectEnd - entry.connectStart;
    const ssl = entry.secureConnectionStart > 0 ? 
                entry.connectEnd - entry.secureConnectionStart : 0;
    const ttfb = entry.responseStart - entry.requestStart;
    const download = entry.responseEnd - entry.responseStart;
    
    return {
      url: entry.name,
      timestamp: Date.now(),
      
      // Timing breakdown
      timings: {
        dns,
        tcp,
        ssl,
        ttfb,
        download,
        total: entry.duration
      },
      
      // Custom metrics
      wasRedirected: entry.redirectEnd > 0,
      redirectTime: entry.redirectEnd - entry.redirectStart,
      connectionReused: entry.connectStart === entry.connectEnd,
      fromCache: entry.transferSize === 0,
      
      // Size metrics
      transferSize: entry.transferSize,
      encodedBodySize: entry.encodedBodySize,
      decodedBodySize: entry.decodedBodySize,
      compressionRatio: entry.encodedBodySize > 0 ? 
        1 - (entry.encodedBodySize / entry.decodedBodySize) : 0,
      
      // Protocol
      protocol: entry.nextHopProtocol,
      
      // [Inference] Performance classification
      performance: this.classifyPerformance(entry.duration, ttfb),
      
      // Raw entry
      rawEntry: entry
    };
  }
  
  classifyPerformance(duration, ttfb) {
    // [Inference] Classify request performance
    if (duration < 100 && ttfb < 50) return 'excellent';
    if (duration < 300 && ttfb < 150) return 'good';
    if (duration < 1000 && ttfb < 500) return 'fair';
    return 'poor';
  }
  
  getAggregatedMetrics() {
    return {
      totalRequests: this.metrics.length,
      averageDuration: this.average(this.metrics.map(m => m.timings.total)),
      averageTTFB: this.average(this.metrics.map(m => m.timings.ttfb)),
      cacheHitRate: this.metrics.filter(m => m.fromCache).length / this.metrics.length,
      performanceDistribution: this.getPerformanceDistribution()
    };
  }
  
  average(arr) {
    return arr.reduce((a, b) => a + b, 0) / arr.length;
  }
  
  getPerformanceDistribution() {
    const dist = { excellent: 0, good: 0, fair: 0, poor: 0 };
    this.metrics.forEach(m => dist[m.performance]++);
    return dist;
  }
  
  disconnect() {
    this.observer.disconnect();
  }
}

// Usage
const observer = new FetchObserver((metrics) => {
  console.log('Fetch completed:', metrics);
  
  if (metrics.performance === 'poor') {
    console.warn('Poor performance detected:', metrics.url);
  }
});

// Later: observer.disconnect();
```

### Real-time Performance Dashboard Data

Collect metrics for live monitoring:

```javascript
class PerformanceDashboard {
  constructor() {
    this.metrics = {
      requests: [],
      current: {
        rps: 0,
        avgLatency: 0,
        errorRate: 0,
        p50: 0,
        p95: 0,
        p99: 0
      }
    };
    
    this.windowSize = 60000; // 1 minute
    this.updateInterval = 1000; // Update every second
    
    this.startUpdates();
  }
  
  recordRequest(duration, success, error = null) {
    this.metrics.requests.push({
      timestamp: Date.now(),
      duration,
      success,
      error
    });
    
    this.trimWindow();
  }
  
  trimWindow() {
    const cutoff = Date.now() - this.windowSize;
    this.metrics.requests = this.metrics.requests.filter(
      r => r.timestamp > cutoff
    );
  }
  
  startUpdates() {
    this.intervalId = setInterval(() => {
      this.updateMetrics();
    }, this.updateInterval);
  }
  
  updateMetrics() {
    this.trimWindow();
    
    const requests = this.metrics.requests;
    const windowSeconds = this.windowSize / 1000;
    
    // Requests per second
    this.metrics.current.rps = requests.length / windowSeconds;
    
    // Average latency
    const durations = requests.map(r => r.duration);
    this.metrics.current.avgLatency = durations.length > 0 ?
      durations.reduce((a, b) => a + b, 0) / durations.length : 0;
    
    // Error rate
    const errors = requests.filter(r => !r.success);
    this.metrics.current.errorRate = requests.length > 0 ?
      errors.length / requests.length : 0;
    
    // Percentiles
    if (durations.length > 0) {
      durations.sort((a, b) => a - b);
      this.metrics.current.p50 = this.percentile(durations, 50);
      this.metrics.current.p95 = this.percentile(durations, 95);
      this.metrics.current.p99 = this.percentile(durations, 99);
    }
  }
  
  percentile(sortedArray, p) {
    const index = Math.ceil((p / 100) * sortedArray.length) - 1;
    return sortedArray[Math.max(0, index)];
  }
  
  getCurrentMetrics() {
    return { ...this.metrics.current };
  }
  
  stop() {
    clearInterval(this.intervalId);
  }
}

// Usage
const dashboard = new PerformanceDashboard();

async function monitoredFetch(url) {
  const start = performance.now();
  
  try {
    const response = await fetch(url);
    const duration = performance.now() - start;
    dashboard.recordRequest(duration, response.ok);
    return response;
  } catch (error) {
    const duration = performance.now() - start;
    dashboard.recordRequest(duration, false, error.message);
    throw error;
  }
}

// Get current metrics for display
setInterval(() => {
  console.log(dashboard.getCurrentMetrics());
}, 5000);
```

### Custom Metric Export Formats

Export metrics in different formats:

```javascript
class MetricsExporter {
  constructor() {
    this.metrics = [];
  }
  
  addMetric(name, value, tags = {}) {
    this.metrics.push({
      name,
      value,
      tags,
      timestamp: Date.now()
    });
  }
  
  exportPrometheus() {
    // Prometheus exposition format
    return this.metrics.map(m => {
      const tagsStr = Object.entries(m.tags)
        .map(([k, v]) => `${k}="${v}"`)
        .join(',');
      
      return `${m.name}{${tagsStr}} ${m.value} ${m.timestamp}`;
    }).join('\n');
  }
  
  exportStatsd() {
    // StatsD format
    return this.metrics.map(m => {
      const tagsStr = Object.entries(m.tags)
        .map(([k, v]) => `${k}:${v}`)
        .join(',');
      
      return `${m.name}:${m.value}|ms|#${tagsStr}`;
    }).join('\n');
  }
  
  exportJSON() {
    return JSON.stringify(this.metrics, null, 2);
  }
  
  exportCSV() {
    if (this.metrics.length === 0) return '';
    
    const headers = ['timestamp', 'name', 'value', ...Object.keys(this.metrics[0].tags)];
    const rows = this.metrics.map(m => [
      m.timestamp,
      m.name,
      m.value,
      ...Object.values(m.tags)
    ]);
    
    return [
      headers.join(','),
      ...rows.map(r => r.join(','))
    ].join('\n');
  }
}

// Usage
const exporter = new MetricsExporter();

exporter.addMetric('fetch_duration', 245, {
  endpoint: '/api/users',
  method: 'GET',
  status: 200
});

exporter.addMetric('fetch_size', 1024, {
  endpoint: '/api/users',
  type: 'response'
});
```

---

