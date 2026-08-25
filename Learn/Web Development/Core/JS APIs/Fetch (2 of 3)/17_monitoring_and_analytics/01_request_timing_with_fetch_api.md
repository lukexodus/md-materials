## Request Timing with Fetch API


### Performance API Integration

#### Resource Timing Entries

Access detailed timing information for fetch requests using the Performance API:

```javascript
async function fetchWithTiming(url, options = {}) {
  const startMark = `fetch-start-${Date.now()}`;
  performance.mark(startMark);

  const response = await fetch(url, options);

  const endMark = `fetch-end-${Date.now()}`;
  performance.mark(endMark);

  // Get resource timing entry
  const entries = performance.getEntriesByType('resource');
  const entry = entries.find(e => e.name === url);

  return {
    response,
    timing: entry ? extractTimingMetrics(entry) : null
  };
}

function extractTimingMetrics(entry) {
  return {
    // DNS lookup
    dnsLookup: entry.domainLookupEnd - entry.domainLookupStart,
    
    // TCP connection
    tcpConnection: entry.connectEnd - entry.connectStart,
    
    // TLS negotiation
    tlsNegotiation: entry.secureConnectionStart > 0 
      ? entry.connectEnd - entry.secureConnectionStart 
      : 0,
    
    // Request time (sending)
    requestTime: entry.responseStart - entry.requestStart,
    
    // Response time (receiving)
    responseTime: entry.responseEnd - entry.responseStart,
    
    // Total time
    totalTime: entry.responseEnd - entry.startTime,
    
    // Time to first byte
    ttfb: entry.responseStart - entry.requestStart,
    
    // Transfer size
    transferSize: entry.transferSize,
    encodedBodySize: entry.encodedBodySize,
    decodedBodySize: entry.decodedBodySize
  };
}
```

#### Performance Observer Pattern

Monitor fetch requests in real-time using PerformanceObserver:

```javascript
class FetchPerformanceMonitor {
  constructor() {
    this.metrics = new Map();
    this.observer = null;
  }

  start() {
    this.observer = new PerformanceObserver((list) => {
      for (const entry of list.getEntries()) {
        if (entry.initiatorType === 'fetch' || entry.initiatorType === 'xmlhttprequest') {
          this.recordMetric(entry);
        }
      }
    });

    this.observer.observe({ 
      entryTypes: ['resource'],
      buffered: true 
    });
  }

  recordMetric(entry) {
    const metric = {
      url: entry.name,
      duration: entry.duration,
      startTime: entry.startTime,
      dns: entry.domainLookupEnd - entry.domainLookupStart,
      tcp: entry.connectEnd - entry.connectStart,
      ttfb: entry.responseStart - entry.requestStart,
      download: entry.responseEnd - entry.responseStart,
      size: entry.transferSize,
      cached: entry.transferSize === 0 && entry.decodedBodySize > 0,
      protocol: entry.nextHopProtocol
    };

    this.metrics.set(entry.name, metric);
    this.onMetricRecorded?.(metric);
  }

  getMetrics(url) {
    return url ? this.metrics.get(url) : Array.from(this.metrics.values());
  }

  getAverageMetrics() {
    const metrics = Array.from(this.metrics.values());
    if (metrics.length === 0) return null;

    return {
      avgDuration: this.average(metrics, 'duration'),
      avgTTFB: this.average(metrics, 'ttfb'),
      avgDownload: this.average(metrics, 'download'),
      avgSize: this.average(metrics, 'size'),
      totalRequests: metrics.length,
      cachedRequests: metrics.filter(m => m.cached).length
    };
  }

  average(array, property) {
    return array.reduce((sum, item) => sum + item[property], 0) / array.length;
  }

  stop() {
    this.observer?.disconnect();
    this.observer = null;
  }

  clear() {
    this.metrics.clear();
  }
}
```

### Manual Timing Implementation

#### High-Resolution Timestamps

Use `performance.now()` for accurate timing measurements:

```javascript
class ManualTimer {
  constructor() {
    this.startTime = null;
    this.phases = [];
  }

  start() {
    this.startTime = performance.now();
    this.phases = [];
    return this;
  }

  mark(label) {
    if (!this.startTime) {
      throw new Error('Timer not started');
    }
    
    const now = performance.now();
    this.phases.push({
      label,
      timestamp: now,
      elapsed: now - this.startTime
    });
    
    return this;
  }

  stop() {
    this.mark('end');
    return this.getReport();
  }

  getReport() {
    if (this.phases.length === 0) return null;

    const report = {
      totalDuration: this.phases[this.phases.length - 1].elapsed,
      phases: []
    };

    for (let i = 0; i < this.phases.length; i++) {
      const phase = this.phases[i];
      const previousTime = i > 0 ? this.phases[i - 1].timestamp : this.startTime;
      
      report.phases.push({
        label: phase.label,
        duration: phase.timestamp - previousTime,
        elapsed: phase.elapsed
      });
    }

    return report;
  }
}

async function fetchWithManualTiming(url, options = {}) {
  const timer = new ManualTimer().start();

  timer.mark('fetch-initiated');
  
  const response = await fetch(url, options);
  timer.mark('headers-received');

  const data = await response.json();
  timer.mark('body-parsed');

  return {
    data,
    timing: timer.stop()
  };
}
```

#### Comprehensive Request Lifecycle Timing

Track all phases of a fetch request:

```javascript
class DetailedRequestTimer {
  async fetch(url, options = {}) {
    const timing = {
      queueTime: performance.now(),
      dnsStart: null,
      dnsEnd: null,
      connectStart: null,
      connectEnd: null,
      tlsStart: null,
      tlsEnd: null,
      requestStart: null,
      responseStart: null,
      responseEnd: null,
      parseStart: null,
      parseEnd: null
    };

    // Request starts
    timing.requestStart = performance.now();

    let response;
    try {
      response = await fetch(url, options);
      timing.responseStart = performance.now();
    } catch (error) {
      timing.error = error.message;
      timing.responseEnd = performance.now();
      throw error;
    }

    // Parse response
    timing.parseStart = performance.now();
    const contentType = response.headers.get('content-type');
    
    let data;
    if (contentType?.includes('application/json')) {
      data = await response.json();
    } else if (contentType?.includes('text/')) {
      data = await response.text();
    } else {
      data = await response.blob();
    }
    
    timing.parseEnd = performance.now();
    timing.responseEnd = performance.now();

    // Try to get resource timing entry
    const resourceEntry = this.getResourceTiming(url);
    if (resourceEntry) {
      timing.dnsStart = resourceEntry.domainLookupStart;
      timing.dnsEnd = resourceEntry.domainLookupEnd;
      timing.connectStart = resourceEntry.connectStart;
      timing.connectEnd = resourceEntry.connectEnd;
      timing.tlsStart = resourceEntry.secureConnectionStart;
      timing.tlsEnd = resourceEntry.connectEnd;
    }

    return {
      data,
      response,
      timing: this.calculateDurations(timing)
    };
  }

  getResourceTiming(url) {
    const entries = performance.getEntriesByType('resource');
    return entries.find(e => e.name === url);
  }

  calculateDurations(timing) {
    return {
      raw: timing,
      durations: {
        queue: timing.requestStart - timing.queueTime,
        dns: timing.dnsEnd && timing.dnsStart 
          ? timing.dnsEnd - timing.dnsStart 
          : null,
        connect: timing.connectEnd && timing.connectStart
          ? timing.connectEnd - timing.connectStart
          : null,
        tls: timing.tlsEnd && timing.tlsStart
          ? timing.tlsEnd - timing.tlsStart
          : null,
        request: timing.responseStart - timing.requestStart,
        response: timing.parseStart - timing.responseStart,
        parse: timing.parseEnd - timing.parseStart,
        total: timing.responseEnd - timing.queueTime
      }
    };
  }
}
```

### Timeout Implementation

#### Basic Timeout with AbortController

Implement request timeouts using AbortController:

```javascript
async function fetchWithTimeout(url, options = {}, timeout = 5000) {
  const controller = new AbortController();
  const timeoutId = setTimeout(() => controller.abort(), timeout);

  const startTime = performance.now();

  try {
    const response = await fetch(url, {
      ...options,
      signal: controller.signal
    });

    clearTimeout(timeoutId);
    
    const duration = performance.now() - startTime;
    
    return {
      response,
      duration,
      timedOut: false
    };
  } catch (error) {
    clearTimeout(timeoutId);
    
    const duration = performance.now() - startTime;
    
    if (error.name === 'AbortError') {
      throw new Error(`Request timeout after ${duration}ms`);
    }
    
    throw error;
  }
}
```

#### Progressive Timeout Strategy

Implement different timeouts for different phases:

```javascript
class ProgressiveTimeoutFetch {
  constructor(options = {}) {
    this.timeouts = {
      connection: options.connectionTimeout || 5000,
      headers: options.headersTimeout || 10000,
      body: options.bodyTimeout || 30000,
      total: options.totalTimeout || 60000
    };
  }

  async fetch(url, options = {}) {
    const controller = new AbortController();
    const timing = {
      start: performance.now(),
      connected: null,
      headersReceived: null,
      bodyReceived: null
    };

    // Set total timeout
    const totalTimeout = setTimeout(
      () => this.abortWithReason(controller, 'total timeout'),
      this.timeouts.total
    );

    // Set connection timeout
    const connectionTimeout = setTimeout(
      () => this.abortWithReason(controller, 'connection timeout'),
      this.timeouts.connection
    );

    try {
      // Start fetch
      const response = await fetch(url, {
        ...options,
        signal: controller.signal
      });

      timing.connected = performance.now();
      clearTimeout(connectionTimeout);

      // Set headers timeout
      const headersTimeout = setTimeout(
        () => this.abortWithReason(controller, 'headers timeout'),
        this.timeouts.headers
      );

      // Headers are already available
      timing.headersReceived = performance.now();
      clearTimeout(headersTimeout);

      // Set body timeout
      const bodyTimeout = setTimeout(
        () => this.abortWithReason(controller, 'body timeout'),
        this.timeouts.body
      );

      // Read body
      const data = await this.readBody(response);
      timing.bodyReceived = performance.now();
      
      clearTimeout(bodyTimeout);
      clearTimeout(totalTimeout);

      return {
        data,
        response,
        timing: this.calculateTimings(timing)
      };

    } catch (error) {
      clearTimeout(connectionTimeout);
      clearTimeout(totalTimeout);
      
      timing.bodyReceived = performance.now();
      
      throw {
        error,
        timing: this.calculateTimings(timing),
        phase: this.determineFailurePhase(timing)
      };
    }
  }

  abortWithReason(controller, reason) {
    controller.abort();
    controller.reason = reason;
  }

  async readBody(response) {
    const contentType = response.headers.get('content-type');
    
    if (contentType?.includes('application/json')) {
      return await response.json();
    } else if (contentType?.includes('text/')) {
      return await response.text();
    } else {
      return await response.blob();
    }
  }

  calculateTimings(timing) {
    return {
      connection: timing.connected ? timing.connected - timing.start : null,
      headers: timing.headersReceived ? timing.headersReceived - timing.connected : null,
      body: timing.bodyReceived && timing.headersReceived 
        ? timing.bodyReceived - timing.headersReceived 
        : null,
      total: timing.bodyReceived - timing.start
    };
  }

  determineFailurePhase(timing) {
    if (!timing.connected) return 'connection';
    if (!timing.headersReceived) return 'headers';
    if (!timing.bodyReceived) return 'body';
    return 'unknown';
  }
}
```

#### Adaptive Timeout

Adjust timeouts based on historical performance:

```javascript
class AdaptiveTimeoutFetch {
  constructor(options = {}) {
    this.baseTimeout = options.baseTimeout || 5000;
    this.minTimeout = options.minTimeout || 1000;
    this.maxTimeout = options.maxTimeout || 30000;
    this.history = [];
    this.maxHistorySize = options.maxHistorySize || 100;
    this.multiplier = options.multiplier || 2.5;
  }

  async fetch(url, options = {}) {
    const timeout = this.calculateTimeout();
    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), timeout);

    const startTime = performance.now();

    try {
      const response = await fetch(url, {
        ...options,
        signal: controller.signal
      });

      const duration = performance.now() - startTime;
      clearTimeout(timeoutId);

      this.recordSuccess(duration);

      return { response, duration, timeout };

    } catch (error) {
      const duration = performance.now() - startTime;
      clearTimeout(timeoutId);

      if (error.name === 'AbortError') {
        this.recordTimeout(duration);
        throw new Error(`Adaptive timeout (${timeout}ms) exceeded`);
      }

      this.recordFailure(duration);
      throw error;
    }
  }

  calculateTimeout() {
    if (this.history.length === 0) {
      return this.baseTimeout;
    }

    const successfulRequests = this.history.filter(h => h.success);
    
    if (successfulRequests.length === 0) {
      return Math.min(this.baseTimeout * 2, this.maxTimeout);
    }

    // Calculate percentile (95th)
    const durations = successfulRequests
      .map(h => h.duration)
      .sort((a, b) => a - b);
    
    const index = Math.floor(durations.length * 0.95);
    const p95 = durations[index];

    // Apply multiplier and constrain
    const calculatedTimeout = p95 * this.multiplier;
    return Math.max(
      this.minTimeout,
      Math.min(calculatedTimeout, this.maxTimeout)
    );
  }

  recordSuccess(duration) {
    this.addToHistory({ duration, success: true, timedOut: false });
  }

  recordTimeout(duration) {
    this.addToHistory({ duration, success: false, timedOut: true });
  }

  recordFailure(duration) {
    this.addToHistory({ duration, success: false, timedOut: false });
  }

  addToHistory(entry) {
    this.history.push({
      ...entry,
      timestamp: Date.now()
    });

    if (this.history.length > this.maxHistorySize) {
      this.history.shift();
    }
  }

  getStats() {
    const successful = this.history.filter(h => h.success);
    const timedOut = this.history.filter(h => h.timedOut);

    return {
      totalRequests: this.history.length,
      successfulRequests: successful.length,
      timedOutRequests: timedOut.length,
      successRate: successful.length / this.history.length,
      currentTimeout: this.calculateTimeout(),
      avgDuration: successful.length > 0
        ? successful.reduce((sum, h) => sum + h.duration, 0) / successful.length
        : 0
    };
  }

  reset() {
    this.history = [];
  }
}
```

### Request Retry with Timing

#### Exponential Backoff with Timing

Implement retry logic with exponential backoff and timing tracking:

```javascript
class RetryWithTiming {
  constructor(options = {}) {
    this.maxRetries = options.maxRetries || 3;
    this.baseDelay = options.baseDelay || 1000;
    this.maxDelay = options.maxDelay || 30000;
    this.timeout = options.timeout || 10000;
    this.retryableStatuses = options.retryableStatuses || [408, 429, 500, 502, 503, 504];
  }

  async fetch(url, options = {}) {
    const attempts = [];
    let lastError;

    for (let attempt = 0; attempt <= this.maxRetries; attempt++) {
      const attemptTiming = {
        attempt: attempt + 1,
        startTime: performance.now(),
        endTime: null,
        duration: null,
        status: null,
        error: null
      };

      try {
        const result = await this.attemptFetch(url, options);
        
        attemptTiming.endTime = performance.now();
        attemptTiming.duration = attemptTiming.endTime - attemptTiming.startTime;
        attemptTiming.status = result.response.status;
        
        attempts.push(attemptTiming);

        // Success
        if (result.response.ok) {
          return {
            ...result,
            attempts,
            totalAttempts: attempts.length,
            totalDuration: attempts.reduce((sum, a) => sum + a.duration, 0)
          };
        }

        // Non-retryable status
        if (!this.retryableStatuses.includes(result.response.status)) {
          throw new Error(`Non-retryable status: ${result.response.status}`);
        }

        lastError = new Error(`HTTP ${result.response.status}`);

      } catch (error) {
        attemptTiming.endTime = performance.now();
        attemptTiming.duration = attemptTiming.endTime - attemptTiming.startTime;
        attemptTiming.error = error.message;
        
        attempts.push(attemptTiming);
        lastError = error;
      }

      // Don't wait after last attempt
      if (attempt < this.maxRetries) {
        const delay = this.calculateDelay(attempt);
        await this.sleep(delay);
      }
    }

    throw {
      error: lastError,
      attempts,
      totalAttempts: attempts.length,
      totalDuration: attempts.reduce((sum, a) => sum + a.duration, 0)
    };
  }

  async attemptFetch(url, options) {
    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), this.timeout);

    try {
      const response = await fetch(url, {
        ...options,
        signal: controller.signal
      });

      clearTimeout(timeoutId);
      return { response };

    } catch (error) {
      clearTimeout(timeoutId);
      throw error;
    }
  }

  calculateDelay(attempt) {
    const exponentialDelay = this.baseDelay * Math.pow(2, attempt);
    const jitter = Math.random() * 0.3 * exponentialDelay;
    return Math.min(exponentialDelay + jitter, this.maxDelay);
  }

  sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
  }
}
```

#### Conditional Retry Based on Timing

Make retry decisions based on request timing patterns:

```javascript
class SmartRetryFetch {
  constructor(options = {}) {
    this.maxRetries = options.maxRetries || 3;
    this.fastFailThreshold = options.fastFailThreshold || 100;
    this.slowResponseThreshold = options.slowResponseThreshold || 5000;
    this.timeout = options.timeout || 10000;
  }

  async fetch(url, options = {}) {
    const attempts = [];
    
    for (let attempt = 0; attempt <= this.maxRetries; attempt++) {
      const startTime = performance.now();
      
      try {
        const response = await this.attemptFetch(url, options);
        const duration = performance.now() - startTime;

        attempts.push({
          attempt: attempt + 1,
          duration,
          status: response.status,
          success: response.ok
        });

        if (response.ok) {
          return {
            response,
            attempts,
            strategy: this.describeStrategy(attempts)
          };
        }

        // Analyze timing to decide retry strategy
        const shouldRetry = this.analyzeAndDecideRetry(
          response,
          duration,
          attempt,
          attempts
        );

        if (!shouldRetry) {
          throw new Error(`Non-retryable failure after ${duration}ms`);
        }

        // Calculate adaptive delay
        const delay = this.calculateAdaptiveDelay(attempts);
        await this.sleep(delay);

      } catch (error) {
        const duration = performance.now() - startTime;

        attempts.push({
          attempt: attempt + 1,
          duration,
          error: error.message,
          success: false
        });

        if (attempt === this.maxRetries) {
          throw { error, attempts };
        }

        const delay = this.calculateAdaptiveDelay(attempts);
        await this.sleep(delay);
      }
    }
  }

  analyzeAndDecideRetry(response, duration, attempt, attempts) {
    // Fast failure suggests client-side or network issue
    if (duration < this.fastFailThreshold) {
      return attempt < 2; // Only retry fast failures twice
    }

    // Slow response suggests server overload
    if (duration > this.slowResponseThreshold) {
      return true; // Always retry slow responses
    }

    // Check for specific status codes
    if (response.status === 429) {
      // Rate limit - check for Retry-After header
      const retryAfter = response.headers.get('Retry-After');
      return retryAfter !== null;
    }

    if ([500, 502, 503, 504].includes(response.status)) {
      // Server errors - retry with backoff
      return true;
    }

    // Default: don't retry client errors
    return false;
  }

  calculateAdaptiveDelay(attempts) {
    const lastAttempt = attempts[attempts.length - 1];
    
    // Fast failures get shorter delays
    if (lastAttempt.duration < this.fastFailThreshold) {
      return 500 * Math.pow(1.5, attempts.length);
    }

    // Slow responses get longer delays
    if (lastAttempt.duration > this.slowResponseThreshold) {
      return 3000 * Math.pow(2, attempts.length);
    }

    // Standard exponential backoff
    return 1000 * Math.pow(2, attempts.length);
  }

  async attemptFetch(url, options) {
    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), this.timeout);

    try {
      const response = await fetch(url, {
        ...options,
        signal: controller.signal
      });

      clearTimeout(timeoutId);
      return response;

    } catch (error) {
      clearTimeout(timeoutId);
      throw error;
    }
  }

  describeStrategy(attempts) {
    const durations = attempts.map(a => a.duration);
    const avgDuration = durations.reduce((sum, d) => sum + d, 0) / durations.length;

    if (avgDuration < this.fastFailThreshold) {
      return 'fast-fail-recovery';
    } else if (avgDuration > this.slowResponseThreshold) {
      return 'slow-response-backoff';
    } else {
      return 'standard-retry';
    }
  }

  sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
  }
}
```

### Performance Monitoring and Analysis

#### Request Performance Aggregator

Collect and analyze timing data across multiple requests:

```javascript
class RequestPerformanceAnalyzer {
  constructor() {
    this.requests = [];
    this.buckets = {
      fast: [], // < 100ms
      normal: [], // 100-500ms
      slow: [], // 500-2000ms
      verySlow: [] // > 2000ms
    };
  }

  recordRequest(timing) {
    const request = {
      url: timing.url,
      duration: timing.duration,
      timestamp: Date.now(),
      status: timing.status,
      size: timing.size,
      cached: timing.cached
    };

    this.requests.push(request);
    this.categorizeRequest(request);

    // Keep only last 1000 requests
    if (this.requests.length > 1000) {
      this.requests.shift();
    }
  }

  categorizeRequest(request) {
    if (request.duration < 100) {
      this.buckets.fast.push(request);
    } else if (request.duration < 500) {
      this.buckets.normal.push(request);
    } else if (request.duration < 2000) {
      this.buckets.slow.push(request);
    } else {
      this.buckets.verySlow.push(request);
    }

    // Maintain bucket sizes
    Object.keys(this.buckets).forEach(key => {
      if (this.buckets[key].length > 250) {
        this.buckets[key].shift();
      }
    });
  }

  getStatistics() {
    if (this.requests.length === 0) return null;

    const durations = this.requests.map(r => r.duration).sort((a, b) => a - b);
    const sizes = this.requests.map(r => r.size || 0).sort((a, b) => a - b);

    return {
      totalRequests: this.requests.length,
      distribution: {
        fast: this.buckets.fast.length,
        normal: this.buckets.normal.length,
        slow: this.buckets.slow.length,
        verySlow: this.buckets.verySlow.length
      },
      duration: {
        min: Math.min(...durations),
        max: Math.max(...durations),
        mean: durations.reduce((sum, d) => sum + d, 0) / durations.length,
        median: durations[Math.floor(durations.length / 2)],
        p95: durations[Math.floor(durations.length * 0.95)],
        p99: durations[Math.floor(durations.length * 0.99)]
      },
      size: {
        min: Math.min(...sizes),
        max: Math.max(...sizes),
        mean: sizes.reduce((sum, s) => sum + s, 0) / sizes.length,
        median: sizes[Math.floor(sizes.length / 2)],
        total: sizes.reduce((sum, s) => sum + s, 0)
      },
      cacheHitRate: this.requests.filter(r => r.cached).length / this.requests.length
    };
  }

  getSlowestRequests(limit = 10) {
    return [...this.requests]
      .sort((a, b) => b.duration - a.duration)
      .slice(0, limit);
  }

  getRequestsByUrl(url) {
    return this.requests.filter(r => r.url === url);
  }

  getUrlStatistics(url) {
    const urlRequests = this.getRequestsByUrl(url);
    if (urlRequests.length === 0) return null;

    const durations = urlRequests.map(r => r.duration);

    return {
      url,
      count: urlRequests.length,
      avgDuration: durations.reduce((sum, d) => sum + d, 0) / durations.length,
      minDuration: Math.min(...durations),
      maxDuration: Math.max(...durations)
    };
  }

  detectAnomalies() {
    const stats = this.getStatistics();
    if (!stats) return [];

    const anomalies = [];

    // Detect sudden performance degradation
    const recent = this.requests.slice(-50);
    const older = this.requests.slice(-100, -50);

    if (recent.length > 0 && older.length > 0) {
      const recentAvg = recent.reduce((sum, r) => sum + r.duration, 0) / recent.length;
      const olderAvg = older.reduce((sum, r) => sum + r.duration, 0) / older.length;

      if (recentAvg > olderAvg * 2) {
        anomalies.push({
          type: 'performance-degradation',
          severity: 'high',
          recentAvg,
          olderAvg,
          increase: ((recentAvg - olderAvg) / olderAvg * 100).toFixed(1) + '%'
        });
      }
    }

    // Detect unusually slow requests
    const recentSlow = recent.filter(r => r.duration > stats.duration.p95);
    if (recentSlow.length > recent.length * 0.2) {
      anomalies.push({
        type: 'high-latency-spike',
        severity: 'medium',
        affectedRequests: recentSlow.length,
        totalRecent: recent.length
      });
    }

    return anomalies;
  }

  reset() {
    this.requests = [];
    Object.keys(this.buckets).forEach(key => {
      this.buckets[key] = [];
    });
  }
}
```

#### Real-Time Performance Dashboard

Create a live monitoring system for fetch performance:

```javascript
class PerformanceDashboard {
  constructor() {
    this.analyzer = new RequestPerformanceAnalyzer();
    this.monitor = new FetchPerformanceMonitor();
    this.alerts = [];
    this.thresholds = {
      slowRequest: 1000,
      verySlowRequest: 3000,
      errorRate: 0.1,
      cacheHitRate: 0.5
    };
  }

  start() {
    this.monitor.onMetricRecorded = (metric) => {
      this.analyzer.recordRequest(metric);
      this.checkThresholds(metric);
    };

    this.monitor.start();

    // Periodic analysis
    this.analysisInterval = setInterval(() => {
      this.performPeriodicAnalysis();
    }, 30000); // Every 30 seconds
  }

  checkThresholds(metric) {
    // Check for slow requests
    if (metric.duration > this.thresholds.verySlowRequest) {
      this.addAlert({
        type: 'very-slow-request',
        severity: 'high',
        url: metric.url,
        duration: metric.duration,
        timestamp: Date.now()
      });
    } else if (metric.duration > this.thresholds.slowRequest) {
      this.addAlert({
        type: 'slow-request',
        severity: 'medium',
        url: metric.url,
        duration: metric.duration,
        timestamp: Date.now()
      });
    }

    // Check cache performance
    const stats = this.analyzer.getStatistics();
    if (stats && stats.cacheHitRate < this.thresholds.cacheHitRate) {
      this.addAlert({
        type: 'low-cache-hit-rate',
        severity: 'low',
        rate: stats.cacheHitRate,
        threshold: this.thresholds.cacheHitRate,
        timestamp: Date.now()
      });
    }
  }

  performPeriodicAnalysis() {
    const stats = this.analyzer.getStatistics();
    if (!stats) return;

    // Detect anomalies
    const anomalies = this.analyzer.detectAnomalies();
    anomalies.forEach(anomaly => this.addAlert(anomaly));

    // Emit dashboard update
    this.onDashboardUpdate?.({
      stats,
      alerts: this.getRecentAlerts(10),
      slowestRequests: this.analyzer.getSlowestRequests(5)
    });
  }

  addAlert(alert) {
    this.alerts.push({
      ...alert,
      id: `alert-${Date.now()}-${Math.random()}`
    });

    // Keep only last 100 alerts
    if (this.alerts.length > 100) {
      this.alerts.shift();
    }

    this.onAlert?.(alert);
  }

  getRecentAlerts(limit = 10) {
    return [...this.alerts]
      .sort((a, b) => b.timestamp - a.timestamp)
      .slice(0, limit);
  }

  getAlertsByType(type) {
    return this.alerts.filter(a => a.type === type);
  }

  getDashboardData() {
    const stats = this.analyzer.getStatistics();
    
    return {
      stats,
      alerts: this.getRecentAlerts(10),
      slowestRequests: this.analyzer.getSlowestRequests(5),
      recentAnomalies: this.analyzer.detectAnomalies()
    };
  }

  stop() {
    this.monitor.stop();
    clearInterval(this.analysisInterval);
  }

  reset() {
    this.analyzer.reset();
    this.alerts = [];
  }
}
```

### Network Quality Detection

#### Connection Speed Estimation

Estimate network speed based on request timing:

```javascript
class NetworkSpeedEstimator {
  constructor() {
    this.measurements = [];
    this.maxMeasurements = 50;
  }

  async measureSpeed(testUrl, testSizeBytes) {
    const startTime = performance.now();
    
    try {
      const response = await fetch(testUrl);
      const blob = await response.blob();
      
      const endTime = performance.now();
      const duration = endTime - startTime;
      const sizeBytes = blob.size || testSizeBytes;
      
      // Calculate speed in Mbps
      const speedMbps = (sizeBytes * 8) / (duration / 1000) / 1_000_000;
      
      this.recordMeasurement({
        timestamp: Date.now(),
        duration,
        sizeBytes,
        speedMbps
      });

      return {
        speedMbps,
        duration,
        sizeBytes,
        classification: this.classifySpeed(speedMbps)
      };

    } catch (error) {
      return {
        error: error.message,
        speedMbps: 0,
        classification: 'offline'
      };
    }
  }

  recordMeasurement(measurement) {
    this.measurements.push(measurement);
    
    if (this.measurements.length > this.maxMeasurements) {
      this.measurements.shift();
    }
  }

  getAverageSpeed() {
    if (this.measurements.length === 0) return null;

    const speeds = this.measurements.map(m => m.speedMbps);
    const avgSpeed = speeds.reduce((sum, s) => sum + s, 0) / speeds.length;

    return {
      avgSpeedMbps: avgSpeed,
      classification: this.classifySpeed(avgSpeed),
      measurements: this.measurements.length
    };
  }

  classifySpeed(mbps) {
    if (mbps === 0) return 'offline';
    if (mbps < 0.5) return 'slow-2g';
    if (mbps < 2) return '2g';
    if (mbps < 10) return '3g';
    if (mbps < 50) return '4g';
    return '5g';
  }

  getCurrentQuality() {
    const avg = this.getAverageSpeed();
    if (!avg) return null;

    return {
      ...avg,
      recommendation: this.getRecommendation(avg.classification)
    };
  }

  getRecommendation(classification) {
    const recommendations = {
      'offline': {
        prefetch: false,
        imageQuality: 'none',
        videoQuality: 'none',
        polling: false
      },
      'slow-2g': {
        prefetch: false,
        imageQuality: 'low',
        videoQuality: 'none',
        polling: false
      },
      '2g': {
        prefetch: false,
        imageQuality: 'low',
        videoQuality: 'low',
        polling: true
      },
      '3g': {
        prefetch: true,
        imageQuality: 'medium',
        videoQuality: 'medium',
        polling: true
      },
      '4g': {
        prefetch: true,
        imageQuality: 'high',
        videoQuality: 'high',
        polling: true
      },
      '5g': {
        prefetch: true,
        imageQuality: 'max',
        videoQuality: 'max',
        polling: true
      }
    };

    return recommendations[classification];
  }

  reset() {
    this.measurements = [];
  }
}
```

#### Network Information API Integration

Leverage the Network Information API when available:

```javascript
class NetworkConditionMonitor {
  constructor() {
    this.connection = navigator.connection || 
                     navigator.mozConnection || 
                     navigator.webkitConnection;
    this.listeners = new Set();
    this.currentConditions = this.getConditions();
  }

  start() {
    if (this.connection) {
      this.connection.addEventListener('change', () => {
        this.currentConditions = this.getConditions();
        this.notifyListeners();
      });
    }

    // Fallback: periodic manual testing
    this.fallbackInterval = setInterval(() => {
      if (!this.connection) {
        this.performFallbackDetection();
      }
    }, 30000);
  }

  getConditions() {
    if (!this.connection) {
      return {
        type: 'unknown',
        effectiveType: 'unknown',
        downlink: null,
        rtt: null,
        saveData: false
      };
    }

    return {
      type: this.connection.type || 'unknown',
      effectiveType: this.connection.effectiveType || 'unknown',
      downlink: this.connection.downlink || null,
      rtt: this.connection.rtt || null,
      saveData: this.connection.saveData || false,
      downlinkMax: this.connection.downlinkMax || null
    };
  }

  async performFallbackDetection() {
    const testImage = new Image();
    const startTime = performance.now();
    
    testImage.onload = () => {
      const duration = performance.now() - startTime;
      this.estimateConditionsFromLatency(duration);
    };

    testImage.onerror = () => {
      this.currentConditions.effectiveType = 'offline';
      this.notifyListeners();
    };

    // Small test image (1x1 pixel)
    testImage.src = `data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7?t=${Date.now()}`;
  }

  estimateConditionsFromLatency(latency) {
    let effectiveType;
    
    if (latency < 50) {
      effectiveType = '4g';
    } else if (latency < 150) {
      effectiveType = '3g';
    } else if (latency < 500) {
      effectiveType = '2g';
    } else {
      effectiveType = 'slow-2g';
    }

    this.currentConditions = {
      ...this.currentConditions,
      effectiveType,
      rtt: latency
    };

    this.notifyListeners();
  }

  onChange(callback) {
    this.listeners.add(callback);
    return () => this.listeners.delete(callback);
  }

  notifyListeners() {
    this.listeners.forEach(callback => {
      callback(this.currentConditions);
    });
  }

  shouldOptimize() {
    const { effectiveType, saveData } = this.currentConditions;
    
    return saveData || 
           effectiveType === 'slow-2g' || 
           effectiveType === '2g';
  }

  getOptimizationStrategy() {
    const { effectiveType, saveData, downlink } = this.currentConditions;

    if (saveData) {
      return {
        maxImageQuality: 'low',
        prefetchEnabled: false,
        lazyLoadThreshold: 0,
        maxConcurrentRequests: 2
      };
    }

    switch (effectiveType) {
      case 'slow-2g':
      case '2g':
        return {
          maxImageQuality: 'low',
          prefetchEnabled: false,
          lazyLoadThreshold: 100,
          maxConcurrentRequests: 2
        };
      
      case '3g':
        return {
          maxImageQuality: 'medium',
          prefetchEnabled: true,
          lazyLoadThreshold: 200,
          maxConcurrentRequests: 4
        };
      
      case '4g':
      default:
        return {
          maxImageQuality: 'high',
          prefetchEnabled: true,
          lazyLoadThreshold: 500,
          maxConcurrentRequests: 6
        };
    }
  }

  stop() {
    clearInterval(this.fallbackInterval);
  }
}
```

### Request Prioritization

#### Priority Queue Implementation

Implement a priority-based request queue:

```javascript
class PriorityRequestQueue {
  constructor(options = {}) {
    this.maxConcurrent = options.maxConcurrent || 6;
    this.queues = {
      critical: [],
      high: [],
      normal: [],
      low: []
    };
    this.active = new Set();
    this.completed = [];
  }

  async fetch(url, options = {}, priority = 'normal') {
    return new Promise((resolve, reject) => {
      const request = {
        url,
        options,
        priority,
        resolve,
        reject,
        timestamp: performance.now(),
        queueTime: null,
        startTime: null,
        endTime: null
      };

      this.enqueue(request);
      this.processQueue();
    });
  }

  enqueue(request) {
    if (!this.queues[request.priority]) {
      request.priority = 'normal';
    }

    this.queues[request.priority].push(request);
    request.queueTime = performance.now();
  }

  async processQueue() {
    if (this.active.size >= this.maxConcurrent) {
      return;
    }

    const request = this.dequeue();
    if (!request) return;

    this.active.add(request);
    request.startTime = performance.now();

    try {
      const response = await fetch(request.url, request.options);
      request.endTime = performance.now();
      
      this.recordTiming(request, response);
      request.resolve(response);

    } catch (error) {
      request.endTime = performance.now();
      request.error = error.message;
      
      this.recordTiming(request, null);
      request.reject(error);

    } finally {
      this.active.delete(request);
      this.processQueue(); // Process next
    }
  }

  dequeue() {
    // Priority order: critical > high > normal > low
    const priorities = ['critical', 'high', 'normal', 'low'];
    
    for (const priority of priorities) {
      if (this.queues[priority].length > 0) {
        return this.queues[priority].shift();
      }
    }

    return null;
  }

  recordTiming(request, response) {
    const timing = {
      url: request.url,
      priority: request.priority,
      queuedAt: request.timestamp,
      queueDuration: request.startTime - request.queueTime,
      requestDuration: request.endTime - request.startTime,
      totalDuration: request.endTime - request.timestamp,
      status: response?.status || null,
      error: request.error || null
    };

    this.completed.push(timing);

    // Keep only last 1000
    if (this.completed.length > 1000) {
      this.completed.shift();
    }
  }

  getStats() {
    const stats = {
      queued: Object.values(this.queues).reduce((sum, q) => sum + q.length, 0),
      active: this.active.size,
      completed: this.completed.length,
      byPriority: {}
    };

    Object.keys(this.queues).forEach(priority => {
      const priorityRequests = this.completed.filter(r => r.priority === priority);
      
      if (priorityRequests.length > 0) {
        const queueDurations = priorityRequests.map(r => r.queueDuration);
        const requestDurations = priorityRequests.map(r => r.requestDuration);

        stats.byPriority[priority] = {
          count: priorityRequests.length,
          avgQueueTime: queueDurations.reduce((sum, d) => sum + d, 0) / queueDurations.length,
          avgRequestTime: requestDurations.reduce((sum, d) => sum + d, 0) / requestDurations.length
        };
      }
    });

    return stats;
  }

  clear() {
    Object.keys(this.queues).forEach(key => {
      this.queues[key] = [];
    });
  }
}
```

#### Adaptive Concurrency Control

Dynamically adjust concurrent requests based on performance:

```javascript
class AdaptiveConcurrencyController {
  constructor(options = {}) {
    this.minConcurrent = options.minConcurrent || 2;
    this.maxConcurrent = options.maxConcurrent || 10;
    this.currentConcurrent = options.initialConcurrent || 4;
    this.queue = [];
    this.active = new Set();
    this.metrics = {
      successRate: 1.0,
      avgLatency: 0,
      recentLatencies: []
    };
  }

  async fetch(url, options = {}) {
    return new Promise((resolve, reject) => {
      const request = {
        url,
        options,
        resolve,
        reject,
        startTime: null,
        endTime: null
      };

      this.queue.push(request);
      this.processQueue();
    });
  }

  async processQueue() {
    while (this.active.size < this.currentConcurrent && this.queue.length > 0) {
      const request = this.queue.shift();
      this.executeRequest(request);
    }
  }

  async executeRequest(request) {
    this.active.add(request);
    request.startTime = performance.now();

    try {
      const response = await fetch(request.url, request.options);
      request.endTime = performance.now();
      
      this.recordSuccess(request);
      request.resolve(response);

    } catch (error) {
      request.endTime = performance.now();
      
      this.recordFailure(request);
      request.reject(error);

    } finally {
      this.active.delete(request);
      this.adjustConcurrency();
      this.processQueue();
    }
  }

  recordSuccess(request) {
    const latency = request.endTime - request.startTime;
    
    this.metrics.recentLatencies.push(latency);
    if (this.metrics.recentLatencies.length > 50) {
      this.metrics.recentLatencies.shift();
    }

    this.metrics.avgLatency = 
      this.metrics.recentLatencies.reduce((sum, l) => sum + l, 0) / 
      this.metrics.recentLatencies.length;

    // Update success rate (exponential moving average)
    this.metrics.successRate = this.metrics.successRate * 0.9 + 0.1;
  }

  recordFailure(request) {
    // Update success rate (exponential moving average)
    this.metrics.successRate = this.metrics.successRate * 0.9;
  }

  adjustConcurrency() {
    const { successRate, avgLatency, recentLatencies } = this.metrics;

    if (recentLatencies.length < 10) return; // Need more data

    // Calculate latency trend
    const recentAvg = recentLatencies.slice(-10).reduce((sum, l) => sum + l, 0) / 10;
    const olderAvg = recentLatencies.slice(-20, -10).reduce((sum, l) => sum + l, 0) / 10;

    // Increase concurrency if:
    // - Success rate is high (> 0.95)
    // - Latency is stable or improving
    // - Not at max
    if (successRate > 0.95 && 
        recentAvg <= olderAvg * 1.1 && 
        this.currentConcurrent < this.maxConcurrent) {
      this.currentConcurrent = Math.min(
        this.currentConcurrent + 1,
        this.maxConcurrent
      );
    }

    // Decrease concurrency if:
    // - Success rate is low (< 0.8)
    // - Latency is increasing
    // - Not at min
    if ((successRate < 0.8 || recentAvg > olderAvg * 1.5) && 
        this.currentConcurrent > this.minConcurrent) {
      this.currentConcurrent = Math.max(
        this.currentConcurrent - 1,
        this.minConcurrent
      );
    }
  }

  getStats() {
    return {
      currentConcurrency: this.currentConcurrent,
      queued: this.queue.length,
      active: this.active.size,
      metrics: {
        successRate: this.metrics.successRate,
        avgLatency: this.metrics.avgLatency
      }
    };
  }
}
```

### Server Timing API

#### Parsing Server-Timing Headers

Extract and analyze server-side timing information:

```javascript
class ServerTimingParser {
  parseResponse(response) {
    const serverTimingHeader = response.headers.get('Server-Timing');
    
    if (!serverTimingHeader) {
      return null;
    }

    const metrics = this.parseServerTimingHeader(serverTimingHeader);
    
    return {
      metrics,
      total: this.calculateTotal(metrics),
      breakdown: this.createBreakdown(metrics)
    };
  }

  parseServerTimingHeader(header) {
    const metrics = [];
    const entries = header.split(',').map(e => e.trim());

    for (const entry of entries) {
      const metric = this.parseEntry(entry);
      if (metric) {
        metrics.push(metric);
      }
    }

    return metrics;
  }

  parseEntry(entry) {
    // Format: name;dur=123;desc="Description"
    const parts = entry.split(';');
    const name = parts[0].trim();
    
    const metric = { name, duration: null, description: null };

    for (let i = 1; i < parts.length; i++) {
      const part = parts[i].trim();
      
      if (part.startsWith('dur=')) {
        metric.duration = parseFloat(part.substring(4));
      } else if (part.startsWith('desc=')) {
        metric.description = part.substring(5).replace(/^"|"$/g, '');
      }
    }

    return metric;
  }

  calculateTotal(metrics) {
    return metrics.reduce((sum, m) => sum + (m.duration || 0), 0);
  }

  createBreakdown(metrics) {
    const breakdown = {};
    
    for (const metric of metrics) {
      breakdown[metric.name] = {
        duration: metric.duration,
        description: metric.description
      };
    }

    return breakdown;
  }

  async fetchWithServerTiming(url, options = {}) {
    const clientStart = performance.now();
    const response = await fetch(url, options);
    const clientEnd = performance.now();

    const serverTiming = this.parseResponse(response);

    return {
      response,
      timing: {
        client: {
          total: clientEnd - clientStart,
          start: clientStart,
          end: clientEnd
        },
        server: serverTiming
      }
    };
  }
}
```

#### Combined Client-Server Analysis

Correlate client-side and server-side timing:

```javascript
class FullStackTimingAnalyzer {
  constructor() {
    this.parser = new ServerTimingParser();
    this.measurements = [];
  }

  async fetch(url, options = {}) {
    const measurement = {
      url,
      client: {},
      server: {},
      network: {}
    };

    // Client timing
    const clientStart = performance.now();
    measurement.client.queueStart = clientStart;

    try {
      const response = await fetch(url, options);
      const headersReceived = performance.now();
      measurement.client.headersReceived = headersReceived;

      // Parse server timing
      const serverTiming = this.parser.parseResponse(response);
      measurement.server = serverTiming;

      // Read body
      const data = await response.json();
      const clientEnd = performance.now();
      measurement.client.bodyReceived = clientEnd;

      // Calculate network overhead
      this.calculateNetworkOverhead(measurement);

      this.measurements.push(measurement);

      return {
        data,
        response,
        timing: measurement
      };

    } catch (error) {
      measurement.client.error = error.message;
      measurement.client.errorTime = performance.now();
      
      this.measurements.push(measurement);
      throw error;
    }
  }

  calculateNetworkOverhead(measurement) {
    const clientTotal = measurement.client.bodyReceived - measurement.client.queueStart;
    const serverTotal = measurement.server?.total || 0;

    measurement.network = {
      totalRoundTrip: clientTotal,
      serverProcessing: serverTotal,
      networkOverhead: clientTotal - serverTotal,
      overheadPercentage: serverTotal > 0 
        ? ((clientTotal - serverTotal) / clientTotal * 100).toFixed(2) 
        : null
    };
  }

  analyzeBottlenecks() {
    if (this.measurements.length === 0) return null;

    const analysis = {
      serverBottlenecks: [],
      networkBottlenecks: [],
      clientBottlenecks: []
    };

    for (const measurement of this.measurements) {
      const { server, network, client } = measurement;

      // Server bottleneck: server time > 50% of total
      if (server?.total && network.overheadPercentage < 50) {
        analysis.serverBottlenecks.push({
          url: measurement.url,
          serverTime: server.total,
          percentage: 100 - parseFloat(network.overheadPercentage)
        });
      }

      // Network bottleneck: network time > 70% of total
      if (network.overheadPercentage > 70) {
        analysis.networkBottlenecks.push({
          url: measurement.url,
          networkTime: network.networkOverhead,
          percentage: parseFloat(network.overheadPercentage)
        });
      }

      // Client bottleneck: body parsing takes significant time
      const parsingTime = client.bodyReceived - client.headersReceived;
      if (parsingTime > 100) {
        analysis.clientBottlenecks.push({
          url: measurement.url,
          parsingTime
        });
      }
    }

    return analysis;
  }

  getRecommendations() {
    const bottlenecks = this.analyzeBottlenecks();
    const recommendations = [];

    if (bottlenecks.serverBottlenecks.length > 0) {
      recommendations.push({
        type: 'server-optimization',
        priority: 'high',
        message: 'Server processing time is high. Consider database query optimization, caching, or scaling.',
        affectedRequests: bottlenecks.serverBottlenecks.length
      });
    }

    if (bottlenecks.networkBottlenecks.length > 0) {
      recommendations.push({
        type: 'network-optimization',
        priority: 'high',
        message: 'Network latency is high. Consider using CDN, compression, or reducing payload size.',
        affectedRequests: bottlenecks.networkBottlenecks.length
      });
    }

    if (bottlenecks.clientBottlenecks.length > 0) {
      recommendations.push({
        type: 'client-optimization',
        priority: 'medium',
        message: 'Client-side parsing is slow. Consider streaming responses or using more efficient data formats.',
        affectedRequests: bottlenecks.clientBottlenecks.length
      });
    }

    return recommendations;
  }

  reset() {
    this.measurements = [];
  }
}
```

---

