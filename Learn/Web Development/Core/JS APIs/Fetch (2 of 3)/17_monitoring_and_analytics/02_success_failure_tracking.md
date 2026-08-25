## Success/Failure Tracking


### Response Status Detection

#### HTTP Status Code Analysis

```javascript
async function fetchWithStatusTracking(url) {
  try {
    const response = await fetch(url);
    
    // Track successful HTTP responses (2xx)
    if (response.ok) {
      console.log(`Success: ${response.status} ${response.statusText}`);
      return await response.json();
    }
    
    // Track client errors (4xx)
    if (response.status >= 400 && response.status < 500) {
      console.error(`Client Error: ${response.status}`);
      throw new Error(`Client error: ${response.status}`);
    }
    
    // Track server errors (5xx)
    if (response.status >= 500) {
      console.error(`Server Error: ${response.status}`);
      throw new Error(`Server error: ${response.status}`);
    }
    
    // Track other status codes
    console.warn(`Unexpected status: ${response.status}`);
    throw new Error(`Unexpected status: ${response.status}`);
  } catch (error) {
    console.error('Request failed:', error);
    throw error;
  }
}
```

#### Granular Status Code Tracking

```javascript
class StatusTracker {
  constructor() {
    this.stats = {
      '2xx': 0,
      '3xx': 0,
      '4xx': 0,
      '5xx': 0,
      specific: {}
    };
  }

  trackResponse(response) {
    const status = response.status;
    const category = `${Math.floor(status / 100)}xx`;
    
    this.stats[category]++;
    this.stats.specific[status] = (this.stats.specific[status] || 0) + 1;
    
    return {
      status,
      category,
      ok: response.ok,
      timestamp: Date.now()
    };
  }

  getStats() {
    return {
      ...this.stats,
      total: Object.values(this.stats.specific).reduce((a, b) => a + b, 0),
      successRate: this.calculateSuccessRate()
    };
  }

  calculateSuccessRate() {
    const total = this.stats['2xx'] + this.stats['3xx'] + 
                  this.stats['4xx'] + this.stats['5xx'];
    return total > 0 ? (this.stats['2xx'] / total) * 100 : 0;
  }
}

const tracker = new StatusTracker();

async function trackedFetch(url) {
  const response = await fetch(url);
  const statusInfo = tracker.trackResponse(response);
  console.log('Status tracked:', statusInfo);
  return response;
}
```

### Network Error Detection

#### Connection Failures

```javascript
async function fetchWithNetworkTracking(url) {
  const startTime = Date.now();
  
  try {
    const response = await fetch(url);
    const duration = Date.now() - startTime;
    
    console.log(`Request succeeded in ${duration}ms`);
    return response;
  } catch (error) {
    const duration = Date.now() - startTime;
    
    // Track different network error types
    if (error instanceof TypeError) {
      console.error('Network failure:', {
        type: 'NetworkError',
        message: error.message,
        duration,
        possibleCauses: ['No internet', 'DNS failure', 'CORS issue', 'Blocked request']
      });
    } else if (error.name === 'AbortError') {
      console.error('Request aborted:', { duration });
    } else {
      console.error('Unknown error:', error);
    }
    
    throw error;
  }
}
```

#### Timeout Detection

```javascript
async function fetchWithTimeout(url, timeout = 5000) {
  const controller = new AbortController();
  const timeoutId = setTimeout(() => controller.abort(), timeout);
  const startTime = Date.now();
  
  try {
    const response = await fetch(url, { signal: controller.signal });
    const duration = Date.now() - startTime;
    
    clearTimeout(timeoutId);
    console.log(`Request completed in ${duration}ms`);
    return response;
  } catch (error) {
    clearTimeout(timeoutId);
    const duration = Date.now() - startTime;
    
    if (error.name === 'AbortError') {
      console.error('Request timeout:', {
        url,
        timeout,
        duration
      });
      throw new Error(`Request timeout after ${timeout}ms`);
    }
    
    throw error;
  }
}
```

### Comprehensive Tracking System

#### Multi-Metric Tracker

```javascript
class RequestTracker {
  constructor() {
    this.requests = [];
    this.metrics = {
      total: 0,
      successful: 0,
      failed: 0,
      timedOut: 0,
      aborted: 0,
      networkErrors: 0,
      totalDuration: 0
    };
  }

  async track(url, options = {}) {
    const requestId = this.generateId();
    const startTime = Date.now();
    
    const request = {
      id: requestId,
      url,
      startTime,
      status: 'pending'
    };
    
    this.requests.push(request);
    this.metrics.total++;

    try {
      const response = await fetch(url, options);
      const duration = Date.now() - startTime;
      
      request.status = 'completed';
      request.httpStatus = response.status;
      request.ok = response.ok;
      request.duration = duration;
      request.endTime = Date.now();
      
      this.metrics.totalDuration += duration;
      
      if (response.ok) {
        this.metrics.successful++;
      } else {
        this.metrics.failed++;
      }
      
      return response;
    } catch (error) {
      const duration = Date.now() - startTime;
      
      request.status = 'failed';
      request.error = error.message;
      request.errorType = error.name;
      request.duration = duration;
      request.endTime = Date.now();
      
      this.metrics.totalDuration += duration;
      
      if (error.name === 'AbortError') {
        this.metrics.aborted++;
      } else if (error instanceof TypeError) {
        this.metrics.networkErrors++;
      } else {
        this.metrics.failed++;
      }
      
      throw error;
    }
  }

  generateId() {
    return `req_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
  }

  getMetrics() {
    const avgDuration = this.metrics.total > 0 
      ? this.metrics.totalDuration / this.metrics.total 
      : 0;
    
    return {
      ...this.metrics,
      averageDuration: Math.round(avgDuration),
      successRate: this.metrics.total > 0 
        ? (this.metrics.successful / this.metrics.total * 100).toFixed(2) 
        : 0,
      failureRate: this.metrics.total > 0 
        ? (this.metrics.failed / this.metrics.total * 100).toFixed(2) 
        : 0
    };
  }

  getRecentRequests(limit = 10) {
    return this.requests.slice(-limit);
  }

  getFailedRequests() {
    return this.requests.filter(req => req.status === 'failed');
  }

  reset() {
    this.requests = [];
    this.metrics = {
      total: 0,
      successful: 0,
      failed: 0,
      timedOut: 0,
      aborted: 0,
      networkErrors: 0,
      totalDuration: 0
    };
  }
}

// Usage
const tracker = new RequestTracker();

async function makeTrackedRequest(url) {
  try {
    const response = await tracker.track(url);
    console.log('Metrics:', tracker.getMetrics());
    return response;
  } catch (error) {
    console.error('Request failed');
    console.log('Failed requests:', tracker.getFailedRequests());
  }
}
```

### Response Validation

#### Content Type Validation

```javascript
async function fetchWithContentValidation(url, expectedType = 'application/json') {
  try {
    const response = await fetch(url);
    
    if (!response.ok) {
      throw new Error(`HTTP ${response.status}`);
    }
    
    const contentType = response.headers.get('content-type');
    
    if (!contentType || !contentType.includes(expectedType)) {
      console.error('Content type mismatch:', {
        expected: expectedType,
        received: contentType,
        url
      });
      throw new Error(`Expected ${expectedType}, got ${contentType}`);
    }
    
    console.log('Content type validated:', contentType);
    return response;
  } catch (error) {
    console.error('Validation failed:', error);
    throw error;
  }
}
```

#### Response Body Validation

```javascript
async function fetchWithBodyValidation(url, validator) {
  try {
    const response = await fetch(url);
    
    if (!response.ok) {
      throw new Error(`HTTP ${response.status}`);
    }
    
    const data = await response.json();
    
    if (validator && !validator(data)) {
      console.error('Response validation failed:', {
        url,
        data
      });
      throw new Error('Response body validation failed');
    }
    
    console.log('Response validated successfully');
    return data;
  } catch (error) {
    if (error instanceof SyntaxError) {
      console.error('JSON parse error:', error);
      throw new Error('Invalid JSON response');
    }
    throw error;
  }
}

// Usage
await fetchWithBodyValidation('/api/user', (data) => {
  return data && typeof data.id === 'number' && typeof data.name === 'string';
});
```

### Retry Tracking

#### Retry Counter Implementation

```javascript
class RetryTracker {
  constructor(maxRetries = 3) {
    this.maxRetries = maxRetries;
    this.attempts = new Map();
  }

  async fetch(url, options = {}) {
    const key = `${url}:${JSON.stringify(options)}`;
    
    if (!this.attempts.has(key)) {
      this.attempts.set(key, {
        count: 0,
        failures: [],
        lastAttempt: null
      });
    }
    
    const attempt = this.attempts.get(key);
    
    for (let i = 0; i <= this.maxRetries; i++) {
      attempt.count++;
      attempt.lastAttempt = Date.now();
      
      try {
        console.log(`Attempt ${i + 1}/${this.maxRetries + 1} for ${url}`);
        const response = await fetch(url, options);
        
        if (response.ok) {
          console.log(`Success on attempt ${i + 1}`);
          this.attempts.delete(key);
          return response;
        }
        
        attempt.failures.push({
          attempt: i + 1,
          status: response.status,
          timestamp: Date.now()
        });
        
        if (i === this.maxRetries) {
          throw new Error(`Max retries (${this.maxRetries}) exceeded`);
        }
        
        await this.delay(Math.pow(2, i) * 1000);
      } catch (error) {
        attempt.failures.push({
          attempt: i + 1,
          error: error.message,
          timestamp: Date.now()
        });
        
        if (i === this.maxRetries) {
          console.error(`All ${this.maxRetries + 1} attempts failed for ${url}`);
          throw error;
        }
        
        await this.delay(Math.pow(2, i) * 1000);
      }
    }
  }

  delay(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
  }

  getAttemptHistory() {
    return Array.from(this.attempts.entries()).map(([key, data]) => ({
      request: key,
      ...data
    }));
  }
}
```

### Success Rate Monitoring

#### Time-Window Success Rate

```javascript
class SuccessRateMonitor {
  constructor(windowSize = 60000) { // 1 minute window
    this.windowSize = windowSize;
    this.events = [];
  }

  recordSuccess(url, duration) {
    this.events.push({
      url,
      success: true,
      timestamp: Date.now(),
      duration
    });
    this.cleanup();
  }

  recordFailure(url, error) {
    this.events.push({
      url,
      success: false,
      timestamp: Date.now(),
      error: error.message
    });
    this.cleanup();
  }

  cleanup() {
    const cutoff = Date.now() - this.windowSize;
    this.events = this.events.filter(e => e.timestamp > cutoff);
  }

  getSuccessRate(url = null) {
    this.cleanup();
    
    const filtered = url 
      ? this.events.filter(e => e.url === url)
      : this.events;
    
    if (filtered.length === 0) return 100;
    
    const successful = filtered.filter(e => e.success).length;
    return (successful / filtered.length) * 100;
  }

  getStats(url = null) {
    this.cleanup();
    
    const filtered = url 
      ? this.events.filter(e => e.url === url)
      : this.events;
    
    const successful = filtered.filter(e => e.success);
    const failed = filtered.filter(e => !e.success);
    
    const durations = successful.map(e => e.duration).filter(d => d !== undefined);
    const avgDuration = durations.length > 0
      ? durations.reduce((a, b) => a + b, 0) / durations.length
      : 0;
    
    return {
      total: filtered.length,
      successful: successful.length,
      failed: failed.length,
      successRate: this.getSuccessRate(url),
      avgDuration: Math.round(avgDuration),
      timeWindow: this.windowSize
    };
  }
}

// Usage with fetch
const monitor = new SuccessRateMonitor();

async function monitoredFetch(url) {
  const startTime = Date.now();
  
  try {
    const response = await fetch(url);
    const duration = Date.now() - startTime;
    
    if (response.ok) {
      monitor.recordSuccess(url, duration);
    } else {
      monitor.recordFailure(url, new Error(`HTTP ${response.status}`));
    }
    
    return response;
  } catch (error) {
    monitor.recordFailure(url, error);
    throw error;
  }
}
```

### Error Categorization

#### Structured Error Tracking

```javascript
class ErrorCategorizer {
  constructor() {
    this.errors = {
      network: [],
      http: [],
      timeout: [],
      abort: [],
      parse: [],
      validation: [],
      unknown: []
    };
  }

  categorize(error, context = {}) {
    const errorEntry = {
      message: error.message,
      timestamp: Date.now(),
      ...context
    };

    if (error.name === 'AbortError') {
      this.errors.abort.push(errorEntry);
      return 'abort';
    }
    
    if (error.name === 'TimeoutError' || error.message.includes('timeout')) {
      this.errors.timeout.push(errorEntry);
      return 'timeout';
    }
    
    if (error instanceof TypeError) {
      this.errors.network.push(errorEntry);
      return 'network';
    }
    
    if (error instanceof SyntaxError) {
      this.errors.parse.push(errorEntry);
      return 'parse';
    }
    
    if (error.message.includes('HTTP')) {
      this.errors.http.push(errorEntry);
      return 'http';
    }
    
    if (error.message.includes('validation')) {
      this.errors.validation.push(errorEntry);
      return 'validation';
    }
    
    this.errors.unknown.push(errorEntry);
    return 'unknown';
  }

  getErrorStats() {
    return Object.entries(this.errors).map(([category, errors]) => ({
      category,
      count: errors.length,
      recent: errors.slice(-5)
    }));
  }

  getMostCommonError() {
    const counts = Object.entries(this.errors).map(([category, errors]) => ({
      category,
      count: errors.length
    }));
    
    return counts.sort((a, b) => b.count - a.count)[0];
  }
}

// Usage
const categorizer = new ErrorCategorizer();

async function categorizedFetch(url) {
  try {
    const response = await fetch(url);
    
    if (!response.ok) {
      const error = new Error(`HTTP ${response.status}`);
      categorizer.categorize(error, { url, status: response.status });
      throw error;
    }
    
    return response;
  } catch (error) {
    const category = categorizer.categorize(error, { url });
    console.error(`${category} error:`, error.message);
    throw error;
  }
}
```

### Latency Tracking

#### Performance Timing

```javascript
class LatencyTracker {
  constructor() {
    this.measurements = [];
    this.buckets = {
      fast: 0,      // < 100ms
      medium: 0,    // 100-500ms
      slow: 0,      // 500-2000ms
      verySlow: 0   // > 2000ms
    };
  }

  async trackFetch(url, options = {}) {
    const timings = {
      start: performance.now(),
      dnsStart: null,
      connectStart: null,
      requestStart: null,
      responseStart: null,
      responseEnd: null
    };
    
    try {
      const response = await fetch(url, options);
      timings.responseEnd = performance.now();
      
      const duration = timings.responseEnd - timings.start;
      
      this.recordMeasurement({
        url,
        duration,
        timestamp: Date.now()
      });
      
      this.categorizeDuration(duration);
      
      // Try to get detailed timing if available
      if (window.performance) {
        const entries = performance.getEntriesByType('resource');
        const entry = entries.find(e => e.name === url);
        
        if (entry) {
          timings.dnsStart = entry.domainLookupStart;
          timings.connectStart = entry.connectStart;
          timings.requestStart = entry.requestStart;
          timings.responseStart = entry.responseStart;
        }
      }
      
      return { response, timings, duration };
    } catch (error) {
      timings.responseEnd = performance.now();
      const duration = timings.responseEnd - timings.start;
      
      this.recordMeasurement({
        url,
        duration,
        error: error.message,
        timestamp: Date.now()
      });
      
      throw error;
    }
  }

  recordMeasurement(measurement) {
    this.measurements.push(measurement);
    if (this.measurements.length > 1000) {
      this.measurements.shift();
    }
  }

  categorizeDuration(duration) {
    if (duration < 100) {
      this.buckets.fast++;
    } else if (duration < 500) {
      this.buckets.medium++;
    } else if (duration < 2000) {
      this.buckets.slow++;
    } else {
      this.buckets.verySlow++;
    }
  }

  getStats() {
    const durations = this.measurements
      .filter(m => !m.error)
      .map(m => m.duration);
    
    if (durations.length === 0) {
      return {
        count: 0,
        avg: 0,
        min: 0,
        max: 0,
        p50: 0,
        p95: 0,
        p99: 0
      };
    }
    
    durations.sort((a, b) => a - b);
    
    return {
      count: durations.length,
      avg: durations.reduce((a, b) => a + b, 0) / durations.length,
      min: durations[0],
      max: durations[durations.length - 1],
      p50: this.percentile(durations, 50),
      p95: this.percentile(durations, 95),
      p99: this.percentile(durations, 99),
      distribution: this.buckets
    };
  }

  percentile(sorted, p) {
    const index = Math.ceil((p / 100) * sorted.length) - 1;
    return sorted[index];
  }
}
```

### Batch Request Tracking

#### Parallel Request Monitoring

```javascript
class BatchTracker {
  constructor() {
    this.batches = [];
  }

  async trackBatch(requests) {
    const batchId = this.generateBatchId();
    const startTime = Date.now();
    
    const batch = {
      id: batchId,
      startTime,
      requests: requests.map((r, i) => ({
        id: i,
        url: r.url,
        status: 'pending'
      })),
      totalRequests: requests.length,
      completed: 0,
      failed: 0
    };
    
    this.batches.push(batch);
    
    const results = await Promise.allSettled(
      requests.map(async (req, index) => {
        try {
          const response = await fetch(req.url, req.options);
          
          batch.requests[index].status = response.ok ? 'success' : 'failed';
          batch.requests[index].httpStatus = response.status;
          batch.requests[index].duration = Date.now() - startTime;
          
          if (response.ok) {
            batch.completed++;
          } else {
            batch.failed++;
          }
          
          return { index, response, success: response.ok };
        } catch (error) {
          batch.requests[index].status = 'error';
          batch.requests[index].error = error.message;
          batch.requests[index].duration = Date.now() - startTime;
          batch.failed++;
          
          return { index, error, success: false };
        }
      })
    );
    
    batch.endTime = Date.now();
    batch.totalDuration = batch.endTime - batch.startTime;
    batch.successRate = (batch.completed / batch.totalRequests) * 100;
    
    return {
      batchId,
      results,
      stats: this.getBatchStats(batchId)
    };
  }

  generateBatchId() {
    return `batch_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
  }

  getBatchStats(batchId) {
    const batch = this.batches.find(b => b.id === batchId);
    if (!batch) return null;
    
    return {
      id: batch.id,
      totalRequests: batch.totalRequests,
      completed: batch.completed,
      failed: batch.failed,
      successRate: batch.successRate,
      totalDuration: batch.totalDuration,
      requests: batch.requests
    };
  }

  getAllBatchStats() {
    return this.batches.map(batch => ({
      id: batch.id,
      totalRequests: batch.totalRequests,
      completed: batch.completed,
      failed: batch.failed,
      successRate: batch.successRate,
      totalDuration: batch.totalDuration
    }));
  }
}

// Usage
const batchTracker = new BatchTracker();

const requests = [
  { url: '/api/user/1' },
  { url: '/api/user/2' },
  { url: '/api/user/3' }
];

const { batchId, results, stats } = await batchTracker.trackBatch(requests);
console.log('Batch completed:', stats);
```

### Circuit Breaker Pattern

#### Failure Threshold Tracking

```javascript
class CircuitBreaker {
  constructor(threshold = 5, timeout = 60000) {
    this.threshold = threshold;
    this.timeout = timeout;
    this.failures = 0;
    this.state = 'CLOSED'; // CLOSED, OPEN, HALF_OPEN
    this.nextAttempt = null;
    this.successCount = 0;
    this.failureCount = 0;
  }

  async fetch(url, options = {}) {
    if (this.state === 'OPEN') {
      if (Date.now() < this.nextAttempt) {
        console.error('Circuit breaker OPEN - request blocked');
        throw new Error('Circuit breaker is OPEN');
      }
      this.state = 'HALF_OPEN';
      console.log('Circuit breaker entering HALF_OPEN state');
    }

    try {
      const response = await fetch(url, options);
      
      if (response.ok) {
        this.onSuccess();
        return response;
      } else {
        this.onFailure();
        throw new Error(`HTTP ${response.status}`);
      }
    } catch (error) {
      this.onFailure();
      throw error;
    }
  }

  onSuccess() {
    this.failures = 0;
    this.successCount++;
    
    if (this.state === 'HALF_OPEN') {
      console.log('Circuit breaker CLOSED after successful request');
      this.state = 'CLOSED';
    }
  }

  onFailure() {
    this.failures++;
    this.failureCount++;
    
    if (this.failures >= this.threshold) {
      this.state = 'OPEN';
      this.nextAttempt = Date.now() + this.timeout;
      console.error(`Circuit breaker OPEN after ${this.failures} failures`);
    }
  }

  getStatus() {
    return {
      state: this.state,
      failures: this.failures,
      threshold: this.threshold,
      successCount: this.successCount,
      failureCount: this.failureCount,
      nextAttempt: this.state === 'OPEN' ? this.nextAttempt : null
    };
  }

  reset() {
    this.failures = 0;
    this.state = 'CLOSED';
    this.nextAttempt = null;
  }
}
```

### Health Check Monitoring

#### Endpoint Health Tracking

```javascript
class HealthMonitor {
  constructor(checkInterval = 30000) {
    this.checkInterval = checkInterval;
    this.endpoints = new Map();
    this.intervalId = null;
  }

  registerEndpoint(name, url, options = {}) {
    this.endpoints.set(name, {
      url,
      options,
      status: 'unknown',
      lastCheck: null,
      lastSuccess: null,
      consecutiveFailures: 0,
      totalChecks: 0,
      successfulChecks: 0,
      history: []
    });
  }

  async checkHealth(name) {
    const endpoint = this.endpoints.get(name);
    if (!endpoint) return null;

    const startTime = Date.now();
    endpoint.totalChecks++;

    try {
      const response = await fetch(endpoint.url, {
        ...endpoint.options,
        signal: AbortSignal.timeout(5000)
      });

      const duration = Date.now() - startTime;
      const isHealthy = response.ok;

      endpoint.lastCheck = Date.now();
      endpoint.status = isHealthy ? 'healthy' : 'unhealthy';
      
      if (isHealthy) {
        endpoint.lastSuccess = Date.now();
        endpoint.consecutiveFailures = 0;
        endpoint.successfulChecks++;
      } else {
        endpoint.consecutiveFailures++;
      }

      const check = {
        timestamp: Date.now(),
        healthy: isHealthy,
        status: response.status,
        duration
      };

      endpoint.history.push(check);
      if (endpoint.history.length > 100) {
        endpoint.history.shift();
      }

      return check;
    } catch (error) {
      const duration = Date.now() - startTime;
      
      endpoint.lastCheck = Date.now();
      endpoint.status = 'down';
      endpoint.consecutiveFailures++;

      const check = {
        timestamp: Date.now(),
        healthy: false,
        error: error.message,
        duration
      };

      endpoint.history.push(check);
      if (endpoint.history.length > 100) {
        endpoint.history.shift();
      }

      return check;
    }
  }

  async checkAll() {
    const results = {};
    
    for (const [name, _] of this.endpoints) {
      results[name] = await this.checkHealth(name);
    }
    
    return results;
  }

  startMonitoring() {
    if (this.intervalId) return;
    
    this.intervalId = setInterval(() => {
      this.checkAll();
    }, this.checkInterval);
    
    // Initial check
    this.checkAll();
  }

  stopMonitoring() {
    if (this.intervalId) {
      clearInterval(this.intervalId);
      this.intervalId = null;
    }
  }

  getEndpointStatus(name) {
    const endpoint = this.endpoints.get(name);
    if (!endpoint) return null;

    const uptime = endpoint.totalChecks > 0
      ? (endpoint.successfulChecks / endpoint.totalChecks) * 100
      : 0;

    return {
      name,
      status: endpoint.status,
      lastCheck: endpoint.lastCheck,
      lastSuccess: endpoint.lastSuccess,
      consecutiveFailures: endpoint.consecutiveFailures,
      uptime: uptime.toFixed(2),
      totalChecks: endpoint.totalChecks,
      successfulChecks: endpoint.successfulChecks,
      recentHistory: endpoint.history.slice(-10)
    };
  }

  getAllStatuses() {
    return Array.from(this.endpoints.keys()).map(name => 
      this.getEndpointStatus(name)
    );
  }
}

// Usage
const monitor = new HealthMonitor(30000);
monitor.registerEndpoint('api', '/api/health');
monitor.registerEndpoint('auth', '/auth/health');
monitor.startMonitoring();

// Get status at any time
const apiStatus = monitor.getEndpointStatus('api');
console.log('API Health:', apiStatus);
```

### Logging Integration

#### Structured Logging

```javascript
class FetchLogger {
  constructor(logLevel = 'info') {
    this.logLevel = logLevel;
    this.levels = { debug: 0, info: 1, warn: 2, error: 3 };
    this.logs = [];
  }

  shouldLog(level) {
    return this.levels[level] >= this.levels[this.logLevel];
  }

  log(level, message, context = {}) {
    if (!this.shouldLog(level)) return;

    const entry = {
      level,
      message,
      timestamp: new Date().toISOString(),
      ...context
    };

    this.logs.push(entry);
    
    // Keep only last 1000 logs
    if (this.logs.length > 1000) {
      this.logs.shift();
    }

    const method = console[level] || console.log;
    method(`[${entry.timestamp}] ${level.toUpperCase()}: ${message}`, context);
  }

  async fetch(url, options = {}) {
    const requestId = this.generateId();
    const startTime = Date.now();

    this.log('info', 'Request started', {
      requestId,
      url,
      method: options.method || 'GET'
    });

    try {
      const response = await fetch(url, options);
      const duration = Date.now() - startTime;

      if (response.ok) {
        this.log('info', 'Request succeeded', {
          requestId,
          url,
          status: response.status,
          duration
        });
      } else {
        this.log('warn', 'Request returned error status', {
          requestId,
          url,
          status: response.status,
          statusText: response.statusText,
          duration
        });
      }

      return response;
    } catch (error) {
      const duration = Date.now() - startTime;

      this.log('error', 'Request failed', {
        requestId,
        url,
        error: error.message,
        errorType: error.name,
        duration
      });

      throw error;
    }
  }

  generateId() {
    return Math.random().toString(36).substr(2, 9);
  }

  getLogs(level = null) {
    if (level) {
      return this.logs.filter(log => log.level === level);
    }
    return this.logs;
  }

  getErrorLogs() {
    return this.logs.filter(log => log.level === 'error');
  }

  clear() {
    this.logs = [];
  }
}
```

### Real-Time Dashboard

#### Live Metrics Display

```javascript
class FetchDashboard {
  constructor() {
    this.metrics = {
      requests: {
        total: 0,
        successful: 0,
        failed: 0,
        pending: 0
      },
      latency: {
        current: 0,
        average: 0,
        min: Infinity,
        max: 0,
        history: []
      },
      errors: {
        network: 0,
        timeout: 0,
        http4xx: 0,
        http5xx: 0
      },
      successRate: 100,
      lastUpdate: null
    };
    
    this.subscribers = new Set();
  }

  subscribe(callback) {
    this.subscribers.add(callback);
    return () => this.subscribers.delete(callback);
  }

  notify() {
    this.subscribers.forEach(callback => {
      try {
        callback(this.getMetrics());
      } catch (error) {
        console.error('Dashboard subscriber error:', error);
      }
    });
  }

  async track(url, options = {}) {
    this.metrics.requests.pending++;
    this.metrics.requests.total++;
    this.notify();

    const startTime = Date.now();

    try {
      const response = await fetch(url, options);
      const latency = Date.now() - startTime;

      this.metrics.requests.pending--;
      this.updateLatency(latency);

      if (response.ok) {
        this.metrics.requests.successful++;
      } else {
        this.metrics.requests.failed++;
        
        if (response.status >= 400 && response.status < 500) {
          this.metrics.errors.http4xx++;
        } else if (response.status >= 500) {
          this.metrics.errors.http5xx++;
        }
      }

      this.updateSuccessRate();
      this.metrics.lastUpdate = Date.now();
      this.notify();

      return response;
    } catch (error) {
      const latency = Date.now() - startTime;

      this.metrics.requests.pending--;
      this.metrics.requests.failed++;
      this.updateLatency(latency);

      if (error.name === 'AbortError') {
        this.metrics.errors.timeout++;
      } else if (error instanceof TypeError) {
        this.metrics.errors.network++;
      }

      this.updateSuccessRate();
      this.metrics.lastUpdate = Date.now();
      this.notify();

      throw error;
    }
  }

  updateLatency(latency) {
    this.metrics.latency.current = latency;
    this.metrics.latency.min = Math.min(this.metrics.latency.min, latency);
    this.metrics.latency.max = Math.max(this.metrics.latency.max, latency);
    
    this.metrics.latency.history.push(latency);
    if (this.metrics.latency.history.length > 100) {
      this.metrics.latency.history.shift();
    }

    this.metrics.latency.average = 
      this.metrics.latency.history.reduce((a, b) => a + b, 0) / 
      this.metrics.latency.history.length;
  }

  updateSuccessRate() {
    const total = this.metrics.requests.successful + this.metrics.requests.failed;
    this.metrics.successRate = total > 0 
      ? (this.metrics.requests.successful / total) * 100 
      : 100;
  }

  getMetrics() {
    return JSON.parse(JSON.stringify(this.metrics));
  }

  reset() {
    this.metrics = {
      requests: { total: 0, successful: 0, failed: 0, pending: 0 },
      latency: { current: 0, average: 0, min: Infinity, max: 0, history: [] },
      errors: { network: 0, timeout: 0, http4xx: 0, http5xx: 0 },
      successRate: 100,
      lastUpdate: null
    };
    this.notify();
  }
}

// Usage
const dashboard = new FetchDashboard();

// Subscribe to updates
dashboard.subscribe((metrics) => {
  console.log('Dashboard updated:', metrics);
  // Update UI with metrics
});

// Make tracked requests
await dashboard.track('/api/data');
```

### Alerting System

#### Threshold-Based Alerts

```javascript
class FetchAlertSystem {
  constructor() {
    this.thresholds = {
      errorRate: 10,        // Percentage
      latency: 2000,        // Milliseconds
      failureStreak: 5,     // Consecutive failures
      successRate: 90       // Percentage
    };
    
    this.state = {
      errorCount: 0,
      totalRequests: 0,
      failureStreak: 0,
      recentLatencies: []
    };
    
    this.alerts = [];
    this.handlers = new Set();
  }

  onAlert(handler) {
    this.handlers.add(handler);
    return () => this.handlers.delete(handler);
  }

  triggerAlert(type, message, severity = 'warning', data = {}) {
    const alert = {
      type,
      message,
      severity,
      timestamp: Date.now(),
      data
    };
    
    this.alerts.push(alert);
    
    this.handlers.forEach(handler => {
      try {
        handler(alert);
      } catch (error) {
        console.error('Alert handler error:', error);
      }
    });
    
    return alert;
  }

  async track(url, options = {}) {
    const startTime = Date.now();
    this.state.totalRequests++;

    try {
      const response = await fetch(url, options);
      const latency = Date.now() - startTime;

      this.state.recentLatencies.push(latency);
      if (this.state.recentLatencies.length > 20) {
        this.state.recentLatencies.shift();
      }

      if (!response.ok) {
        this.state.errorCount++;
        this.state.failureStreak++;
        this.checkThresholds();
      } else {
        this.state.failureStreak = 0;
      }

      if (latency > this.thresholds.latency) {
        this.triggerAlert(
          'high_latency',
          `Request exceeded latency threshold: ${latency}ms`,
          'warning',
          { url, latency, threshold: this.thresholds.latency }
        );
      }

      return response;
    } catch (error) {
      this.state.errorCount++;
      this.state.failureStreak++;
      this.checkThresholds();

      this.triggerAlert(
        'request_failure',
        `Request failed: ${error.message}`,
        'error',
        { url, error: error.message }
      );

      throw error;
    }
  }

  checkThresholds() {
    const errorRate = (this.state.errorCount / this.state.totalRequests) * 100;
    
    if (errorRate > this.thresholds.errorRate) {
      this.triggerAlert(
        'high_error_rate',
        `Error rate exceeded threshold: ${errorRate.toFixed(2)}%`,
        'critical',
        { errorRate, threshold: this.thresholds.errorRate }
      );
    }

    if (this.state.failureStreak >= this.thresholds.failureStreak) {
      this.triggerAlert(
        'failure_streak',
        `${this.state.failureStreak} consecutive failures detected`,
        'critical',
        { streak: this.state.failureStreak }
      );
    }

    const successRate = ((this.state.totalRequests - this.state.errorCount) / 
                        this.state.totalRequests) * 100;
    
    if (successRate < this.thresholds.successRate) {
      this.triggerAlert(
        'low_success_rate',
        `Success rate below threshold: ${successRate.toFixed(2)}%`,
        'warning',
        { successRate, threshold: this.thresholds.successRate }
      );
    }
  }

  getRecentAlerts(count = 10) {
    return this.alerts.slice(-count);
  }

  getCriticalAlerts() {
    return this.alerts.filter(a => a.severity === 'critical');
  }

  clearAlerts() {
    this.alerts = [];
  }

  resetState() {
    this.state = {
      errorCount: 0,
      totalRequests: 0,
      failureStreak: 0,
      recentLatencies: []
    };
  }
}

// Usage
const alertSystem = new FetchAlertSystem();

alertSystem.onAlert((alert) => {
  console.error(`[${alert.severity.toUpperCase()}] ${alert.message}`);
  
  if (alert.severity === 'critical') {
    // Send notification, page admin, etc.
  }
});

await alertSystem.track('/api/data');
```

---

