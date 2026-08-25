## Request Pooling with Fetch API


### Basic Request Deduplication

Preventing duplicate concurrent requests to the same resource:

```javascript
const pendingRequests = new Map();

async function fetchWithDeduplication(url, options = {}) {
  const key = `${url}-${JSON.stringify(options)}`;
  
  // Return existing promise if request is in flight
  if (pendingRequests.has(key)) {
    return pendingRequests.get(key);
  }
  
  // Create new request promise
  const requestPromise = fetch(url, options)
    .then(response => response.clone())
    .finally(() => {
      // Clean up after request completes
      pendingRequests.delete(key);
    });
  
  pendingRequests.set(key, requestPromise);
  
  return requestPromise;
}

// Multiple calls return the same promise
const promise1 = fetchWithDeduplication('/api/data');
const promise2 = fetchWithDeduplication('/api/data'); // Reuses promise1
const promise3 = fetchWithDeduplication('/api/data'); // Reuses promise1
```

### Request Pool Manager

Managing concurrent request limits with queuing:

```javascript
class RequestPool {
  constructor(maxConcurrent = 6) {
    this.maxConcurrent = maxConcurrent;
    this.activeRequests = 0;
    this.queue = [];
  }
  
  async fetch(url, options = {}) {
    // Wait if at capacity
    if (this.activeRequests >= this.maxConcurrent) {
      await this._enqueue();
    }
    
    this.activeRequests++;
    
    try {
      const response = await fetch(url, options);
      return response;
    } finally {
      this.activeRequests--;
      this._dequeue();
    }
  }
  
  _enqueue() {
    return new Promise(resolve => {
      this.queue.push(resolve);
    });
  }
  
  _dequeue() {
    if (this.queue.length > 0) {
      const resolve = this.queue.shift();
      resolve();
    }
  }
  
  getStats() {
    return {
      active: this.activeRequests,
      queued: this.queue.length,
      capacity: this.maxConcurrent
    };
  }
}

const pool = new RequestPool(3);

// Only 3 requests execute concurrently, rest queue
Promise.all([
  pool.fetch('/api/1'),
  pool.fetch('/api/2'),
  pool.fetch('/api/3'),
  pool.fetch('/api/4'), // Queued
  pool.fetch('/api/5'), // Queued
  pool.fetch('/api/6')  // Queued
]);
```

### Priority-Based Request Queue

Executing high-priority requests before low-priority ones:

```javascript
class PriorityRequestPool {
  constructor(maxConcurrent = 6) {
    this.maxConcurrent = maxConcurrent;
    this.activeRequests = 0;
    this.queues = {
      critical: [],
      high: [],
      normal: [],
      low: []
    };
  }
  
  async fetch(url, options = {}, priority = 'normal') {
    if (this.activeRequests >= this.maxConcurrent) {
      await this._enqueue(priority);
    }
    
    this.activeRequests++;
    
    try {
      const response = await fetch(url, options);
      return response;
    } finally {
      this.activeRequests--;
      this._dequeue();
    }
  }
  
  _enqueue(priority) {
    return new Promise(resolve => {
      this.queues[priority].push(resolve);
    });
  }
  
  _dequeue() {
    // Process queues in priority order
    const priorities = ['critical', 'high', 'normal', 'low'];
    
    for (const priority of priorities) {
      if (this.queues[priority].length > 0) {
        const resolve = this.queues[priority].shift();
        resolve();
        return;
      }
    }
  }
  
  getQueueDepth() {
    return {
      critical: this.queues.critical.length,
      high: this.queues.high.length,
      normal: this.queues.normal.length,
      low: this.queues.low.length,
      total: Object.values(this.queues).reduce((sum, q) => sum + q.length, 0)
    };
  }
}

const pool = new PriorityRequestPool(2);

// Critical requests execute first
pool.fetch('/api/analytics', {}, 'low');
pool.fetch('/api/user', {}, 'critical');  // Executes immediately
pool.fetch('/api/settings', {}, 'high');   // Executes second
pool.fetch('/api/logs', {}, 'low');
```

### Per-Domain Connection Pooling

Limiting concurrent requests per domain:

```javascript
class DomainRequestPool {
  constructor(maxPerDomain = 6) {
    this.maxPerDomain = maxPerDomain;
    this.domainPools = new Map();
  }
  
  async fetch(url, options = {}) {
    const domain = new URL(url).origin;
    
    if (!this.domainPools.has(domain)) {
      this.domainPools.set(domain, {
        active: 0,
        queue: []
      });
    }
    
    const pool = this.domainPools.get(domain);
    
    // Wait if domain at capacity
    if (pool.active >= this.maxPerDomain) {
      await new Promise(resolve => pool.queue.push(resolve));
    }
    
    pool.active++;
    
    try {
      const response = await fetch(url, options);
      return response;
    } finally {
      pool.active--;
      
      // Process next queued request for this domain
      if (pool.queue.length > 0) {
        const resolve = pool.queue.shift();
        resolve();
      }
    }
  }
  
  getDomainStats(domain) {
    const pool = this.domainPools.get(domain);
    if (!pool) return null;
    
    return {
      active: pool.active,
      queued: pool.queue.length
    };
  }
  
  getAllStats() {
    const stats = {};
    
    for (const [domain, pool] of this.domainPools) {
      stats[domain] = {
        active: pool.active,
        queued: pool.queue.length
      };
    }
    
    return stats;
  }
}

const pool = new DomainRequestPool(2);

// Each domain limited to 2 concurrent requests
pool.fetch('https://api1.com/data');
pool.fetch('https://api1.com/users');
pool.fetch('https://api1.com/posts');  // Queued for api1.com
pool.fetch('https://api2.com/data');   // Executes immediately (different domain)
```

### Request Batching

Combining multiple requests into a single batch:

```javascript
class RequestBatcher {
  constructor(batchInterval = 50, maxBatchSize = 10) {
    this.batchInterval = batchInterval;
    this.maxBatchSize = maxBatchSize;
    this.pending = [];
    this.timer = null;
  }
  
  async fetch(url, options = {}) {
    return new Promise((resolve, reject) => {
      this.pending.push({ url, options, resolve, reject });
      
      // Flush immediately if batch full
      if (this.pending.length >= this.maxBatchSize) {
        this._flush();
      } else {
        // Schedule flush
        this._scheduleFlush();
      }
    });
  }
  
  _scheduleFlush() {
    if (this.timer) return;
    
    this.timer = setTimeout(() => {
      this._flush();
    }, this.batchInterval);
  }
  
  async _flush() {
    if (this.timer) {
      clearTimeout(this.timer);
      this.timer = null;
    }
    
    if (this.pending.length === 0) return;
    
    const batch = this.pending.splice(0, this.maxBatchSize);
    
    // Execute all requests in parallel
    const results = await Promise.allSettled(
      batch.map(({ url, options }) => fetch(url, options))
    );
    
    // Resolve/reject individual promises
    results.forEach((result, index) => {
      const { resolve, reject } = batch[index];
      
      if (result.status === 'fulfilled') {
        resolve(result.value);
      } else {
        reject(result.reason);
      }
    });
  }
  
  getPendingCount() {
    return this.pending.length;
  }
}

const batcher = new RequestBatcher(100, 5);

// These requests are batched and executed together
batcher.fetch('/api/1');
batcher.fetch('/api/2');
batcher.fetch('/api/3');
// After 100ms or 5 requests, batch executes
```

### Adaptive Request Pooling

Dynamically adjusting pool size based on performance:

```javascript
class AdaptiveRequestPool {
  constructor(initialSize = 6) {
    this.maxConcurrent = initialSize;
    this.minConcurrent = 2;
    this.maxLimit = 12;
    this.activeRequests = 0;
    this.queue = [];
    this.metrics = {
      successCount: 0,
      errorCount: 0,
      totalLatency: 0,
      requestCount: 0
    };
  }
  
  async fetch(url, options = {}) {
    if (this.activeRequests >= this.maxConcurrent) {
      await this._enqueue();
    }
    
    this.activeRequests++;
    const startTime = performance.now();
    
    try {
      const response = await fetch(url, options);
      
      const latency = performance.now() - startTime;
      this._recordSuccess(latency);
      
      return response;
    } catch (error) {
      this._recordError();
      throw error;
    } finally {
      this.activeRequests--;
      this._dequeue();
      this._adjustPoolSize();
    }
  }
  
  _recordSuccess(latency) {
    this.metrics.successCount++;
    this.metrics.totalLatency += latency;
    this.metrics.requestCount++;
  }
  
  _recordError() {
    this.metrics.errorCount++;
    this.metrics.requestCount++;
  }
  
  _adjustPoolSize() {
    // Only adjust every 10 requests
    if (this.metrics.requestCount % 10 !== 0) return;
    
    const errorRate = this.metrics.errorCount / this.metrics.requestCount;
    const avgLatency = this.metrics.totalLatency / this.metrics.successCount;
    
    // Decrease pool size if high error rate
    if (errorRate > 0.1 && this.maxConcurrent > this.minConcurrent) {
      this.maxConcurrent = Math.max(
        this.minConcurrent,
        this.maxConcurrent - 1
      );
      console.log(`Decreased pool size to ${this.maxConcurrent}`);
    }
    // Increase pool size if low latency and no errors
    else if (errorRate < 0.05 && avgLatency < 500 && this.maxConcurrent < this.maxLimit) {
      this.maxConcurrent = Math.min(
        this.maxLimit,
        this.maxConcurrent + 1
      );
      console.log(`Increased pool size to ${this.maxConcurrent}`);
    }
  }
  
  _enqueue() {
    return new Promise(resolve => this.queue.push(resolve));
  }
  
  _dequeue() {
    if (this.queue.length > 0) {
      const resolve = this.queue.shift();
      resolve();
    }
  }
  
  getMetrics() {
    return {
      ...this.metrics,
      errorRate: (this.metrics.errorCount / this.metrics.requestCount * 100).toFixed(2) + '%',
      avgLatency: (this.metrics.totalLatency / this.metrics.successCount).toFixed(2) + 'ms',
      poolSize: this.maxConcurrent,
      active: this.activeRequests,
      queued: this.queue.length
    };
  }
}
```

### Request Coalescing

Merging identical pending requests:

```javascript
class RequestCoalescer {
  constructor(coalescingWindow = 100) {
    this.coalescingWindow = coalescingWindow;
    this.pendingRequests = new Map();
  }
  
  async fetch(url, options = {}) {
    const key = this._generateKey(url, options);
    
    // Check for existing request
    if (this.pendingRequests.has(key)) {
      const existing = this.pendingRequests.get(key);
      
      // Add to listeners
      return new Promise((resolve, reject) => {
        existing.listeners.push({ resolve, reject });
      });
    }
    
    // Create new request entry
    const entry = {
      listeners: [],
      timer: null,
      promise: null
    };
    
    this.pendingRequests.set(key, entry);
    
    // Schedule request execution
    entry.timer = setTimeout(() => {
      this._executeRequest(key, url, options);
    }, this.coalescingWindow);
    
    // Return promise for first caller
    return new Promise((resolve, reject) => {
      entry.listeners.push({ resolve, reject });
    });
  }
  
  async _executeRequest(key, url, options) {
    const entry = this.pendingRequests.get(key);
    if (!entry) return;
    
    try {
      const response = await fetch(url, options);
      
      // Resolve all listeners with cloned responses
      for (const { resolve } of entry.listeners) {
        resolve(response.clone());
      }
    } catch (error) {
      // Reject all listeners
      for (const { reject } of entry.listeners) {
        reject(error);
      }
    } finally {
      this.pendingRequests.delete(key);
    }
  }
  
  _generateKey(url, options) {
    const method = options.method || 'GET';
    const body = options.body || '';
    const headers = JSON.stringify(options.headers || {});
    return `${method}:${url}:${body}:${headers}`;
  }
  
  flush(url, options = {}) {
    const key = this._generateKey(url, options);
    const entry = this.pendingRequests.get(key);
    
    if (entry && entry.timer) {
      clearTimeout(entry.timer);
      this._executeRequest(key, url, options);
    }
  }
}

const coalescer = new RequestCoalescer(50);

// These three calls coalesce into a single request
coalescer.fetch('/api/data');
coalescer.fetch('/api/data');
coalescer.fetch('/api/data');
// Single request executes after 50ms, all three callers get response
```

### Weighted Request Pool

Allocating pool capacity based on request weights:

```javascript
class WeightedRequestPool {
  constructor(maxConcurrent = 10) {
    this.maxConcurrent = maxConcurrent;
    this.currentWeight = 0;
    this.queue = [];
  }
  
  async fetch(url, options = {}, weight = 1) {
    // Wait until sufficient capacity available
    while (this.currentWeight + weight > this.maxConcurrent) {
      await new Promise(resolve => this.queue.push({ resolve, weight }));
    }
    
    this.currentWeight += weight;
    
    try {
      const response = await fetch(url, options);
      return response;
    } finally {
      this.currentWeight -= weight;
      this._processQueue();
    }
  }
  
  _processQueue() {
    // Process queue in order, fitting requests that have available capacity
    let i = 0;
    
    while (i < this.queue.length) {
      const { resolve, weight } = this.queue[i];
      
      if (this.currentWeight + weight <= this.maxConcurrent) {
        this.queue.splice(i, 1);
        resolve();
      } else {
        i++;
      }
    }
  }
  
  getCapacity() {
    return {
      used: this.currentWeight,
      available: this.maxConcurrent - this.currentWeight,
      total: this.maxConcurrent,
      queued: this.queue.length
    };
  }
}

const pool = new WeightedRequestPool(10);

// Heavy request consumes more capacity
pool.fetch('/api/large-download', {}, 5);  // Weight: 5
pool.fetch('/api/data', {}, 1);            // Weight: 1
pool.fetch('/api/small', {}, 1);           // Weight: 1
pool.fetch('/api/medium', {}, 2);          // Weight: 2
pool.fetch('/api/another', {}, 2);         // Queued (would exceed 10)
```

### Request Pool with Timeout

Enforcing maximum wait time in queue:

```javascript
class TimeoutRequestPool {
  constructor(maxConcurrent = 6, queueTimeout = 5000) {
    this.maxConcurrent = maxConcurrent;
    this.queueTimeout = queueTimeout;
    this.activeRequests = 0;
    this.queue = [];
  }
  
  async fetch(url, options = {}) {
    if (this.activeRequests >= this.maxConcurrent) {
      await this._enqueueWithTimeout();
    }
    
    this.activeRequests++;
    
    try {
      const response = await fetch(url, options);
      return response;
    } finally {
      this.activeRequests--;
      this._dequeue();
    }
  }
  
  _enqueueWithTimeout() {
    return new Promise((resolve, reject) => {
      const timer = setTimeout(() => {
        // Remove from queue
        const index = this.queue.findIndex(item => item.resolve === resolve);
        if (index !== -1) {
          this.queue.splice(index, 1);
        }
        
        reject(new Error('Request queue timeout exceeded'));
      }, this.queueTimeout);
      
      this.queue.push({ resolve, timer });
    });
  }
  
  _dequeue() {
    if (this.queue.length > 0) {
      const { resolve, timer } = this.queue.shift();
      clearTimeout(timer);
      resolve();
    }
  }
}

const pool = new TimeoutRequestPool(2, 3000);

// If queued for more than 3 seconds, request fails
try {
  await pool.fetch('/api/data');
} catch (error) {
  console.error('Request timeout:', error.message);
}
```

### Circuit Breaker Pattern

Preventing requests to failing endpoints:

```javascript
class CircuitBreakerPool {
  constructor(maxConcurrent = 6, failureThreshold = 5, resetTimeout = 30000) {
    this.maxConcurrent = maxConcurrent;
    this.failureThreshold = failureThreshold;
    this.resetTimeout = resetTimeout;
    this.activeRequests = 0;
    this.queue = [];
    this.circuits = new Map();
  }
  
  async fetch(url, options = {}) {
    const endpoint = new URL(url).origin + new URL(url).pathname;
    
    // Check circuit state
    const circuit = this._getCircuit(endpoint);
    
    if (circuit.state === 'open') {
      throw new Error(`Circuit breaker open for ${endpoint}`);
    }
    
    if (this.activeRequests >= this.maxConcurrent) {
      await this._enqueue();
    }
    
    this.activeRequests++;
    
    try {
      const response = await fetch(url, options);
      
      if (response.ok) {
        this._recordSuccess(endpoint);
      } else {
        this._recordFailure(endpoint);
      }
      
      return response;
    } catch (error) {
      this._recordFailure(endpoint);
      throw error;
    } finally {
      this.activeRequests--;
      this._dequeue();
    }
  }
  
  _getCircuit(endpoint) {
    if (!this.circuits.has(endpoint)) {
      this.circuits.set(endpoint, {
        state: 'closed',
        failures: 0,
        successes: 0,
        nextAttempt: null
      });
    }
    
    const circuit = this.circuits.get(endpoint);
    
    // Check if should transition from open to half-open
    if (circuit.state === 'open' && Date.now() >= circuit.nextAttempt) {
      circuit.state = 'half-open';
      circuit.failures = 0;
    }
    
    return circuit;
  }
  
  _recordSuccess(endpoint) {
    const circuit = this.circuits.get(endpoint);
    
    if (circuit.state === 'half-open') {
      // Successful request in half-open state closes circuit
      circuit.state = 'closed';
      circuit.failures = 0;
      circuit.successes = 0;
    } else {
      circuit.successes++;
    }
  }
  
  _recordFailure(endpoint) {
    const circuit = this.circuits.get(endpoint);
    circuit.failures++;
    
    if (circuit.failures >= this.failureThreshold) {
      circuit.state = 'open';
      circuit.nextAttempt = Date.now() + this.resetTimeout;
      console.log(`Circuit opened for ${endpoint}, retry after ${this.resetTimeout}ms`);
    }
  }
  
  _enqueue() {
    return new Promise(resolve => this.queue.push(resolve));
  }
  
  _dequeue() {
    if (this.queue.length > 0) {
      const resolve = this.queue.shift();
      resolve();
    }
  }
  
  getCircuitState(endpoint) {
    return this.circuits.get(endpoint) || null;
  }
  
  resetCircuit(endpoint) {
    if (this.circuits.has(endpoint)) {
      this.circuits.set(endpoint, {
        state: 'closed',
        failures: 0,
        successes: 0,
        nextAttempt: null
      });
    }
  }
}
```

### Resource-Aware Request Pool

Adjusting pool size based on system resources:

```javascript
class ResourceAwarePool {
  constructor() {
    this.maxConcurrent = this._calculateOptimalSize();
    this.activeRequests = 0;
    this.queue = [];
    this._monitorResources();
  }
  
  _calculateOptimalSize() {
    // Base on available memory and connection capabilities
    const memory = navigator.deviceMemory || 4; // GB
    const connection = navigator.connection?.effectiveType || '4g';
    
    let baseSize = 6;
    
    // Adjust for memory
    if (memory >= 8) {
      baseSize += 4;
    } else if (memory <= 2) {
      baseSize -= 2;
    }
    
    // Adjust for connection
    if (connection === 'slow-2g' || connection === '2g') {
      baseSize = Math.max(2, baseSize - 3);
    } else if (connection === '3g') {
      baseSize = Math.max(3, baseSize - 2);
    }
    
    return Math.max(2, Math.min(12, baseSize));
  }
  
  _monitorResources() {
    // Adjust pool size when connection changes
    if (navigator.connection) {
      navigator.connection.addEventListener('change', () => {
        const newSize = this._calculateOptimalSize();
        
        if (newSize !== this.maxConcurrent) {
          console.log(`Adjusting pool size: ${this.maxConcurrent} → ${newSize}`);
          this.maxConcurrent = newSize;
          
          // Process queue if capacity increased
          if (newSize > this.maxConcurrent) {
            while (this.queue.length > 0 && this.activeRequests < this.maxConcurrent) {
              this._dequeue();
            }
          }
        }
      });
    }
  }
  
  async fetch(url, options = {}) {
    if (this.activeRequests >= this.maxConcurrent) {
      await this._enqueue();
    }
    
    this.activeRequests++;
    
    try {
      const response = await fetch(url, options);
      return response;
    } finally {
      this.activeRequests--;
      this._dequeue();
    }
  }
  
  _enqueue() {
    return new Promise(resolve => this.queue.push(resolve));
  }
  
  _dequeue() {
    if (this.queue.length > 0) {
      const resolve = this.queue.shift();
      resolve();
    }
  }
  
  getPoolInfo() {
    return {
      maxConcurrent: this.maxConcurrent,
      active: this.activeRequests,
      queued: this.queue.length,
      memory: navigator.deviceMemory,
      connection: navigator.connection?.effectiveType
    };
  }
}
```

### Retry-Aware Request Pool

Integrating retry logic with pooling:

```javascript
class RetryRequestPool {
  constructor(maxConcurrent = 6, maxRetries = 3) {
    this.maxConcurrent = maxConcurrent;
    this.maxRetries = maxRetries;
    this.activeRequests = 0;
    this.queue = [];
  }
  
  async fetch(url, options = {}, retryOptions = {}) {
    const {
      maxRetries = this.maxRetries,
      retryDelay = 1000,
      backoffMultiplier = 2,
      retryOn = [408, 429, 500, 502, 503, 504]
    } = retryOptions;
    
    let lastError;
    
    for (let attempt = 0; attempt <= maxRetries; attempt++) {
      if (this.activeRequests >= this.maxConcurrent) {
        await this._enqueue();
      }
      
      this.activeRequests++;
      
      try {
        const response = await fetch(url, options);
        
        // Check if should retry based on status
        if (attempt < maxRetries && retryOn.includes(response.status)) {
          this.activeRequests--;
          this._dequeue();
          
          const delay = retryDelay * Math.pow(backoffMultiplier, attempt);
          await new Promise(resolve => setTimeout(resolve, delay));
          continue;
        }
        
        return response;
      } catch (error) {
        lastError = error;
        
        // Retry on network errors
        if (attempt < maxRetries) {
          this.activeRequests--;
          this._dequeue();
          
          const delay = retryDelay * Math.pow(backoffMultiplier, attempt);
          await new Promise(resolve => setTimeout(resolve, delay));
          continue;
        }
      } finally {
        if (attempt === maxRetries) {
          this.activeRequests--;
          this._dequeue();
        }
      }
    }
    
    throw lastError;
  }
  
  _enqueue() {
    return new Promise(resolve => this.queue.push(resolve));
  }
  
  _dequeue() {
    if (this.queue.length > 0) {
      const resolve = this.queue.shift();
      resolve();
    }
  }
}

const pool = new RetryRequestPool(3, 3);

// Automatically retries with exponential backoff
await pool.fetch('/api/data', {}, {
  maxRetries: 5,
  retryDelay: 500,
  backoffMultiplier: 2,
  retryOn: [429, 503]
});
```

### Request Pool Analytics

Comprehensive monitoring and analytics:

```javascript
class AnalyticsRequestPool {
  constructor(maxConcurrent = 6) {
    this.maxConcurrent = maxConcurrent;
    this.activeRequests = 0;
    this.queue = [];
    this.analytics = {
      total: 0,
      completed: 0,
      failed: 0,
      timeInQueue: [],
      requestDuration: [],
      queueLengthHistory: [],
      activeConcurrentHistory: []
    };
    this._startMonitoring();
  }
  
  async fetch(url, options = {}) {
    const queueStartTime = performance.now();
    
    if (this.activeRequests >= this.maxConcurrent) {
      await this._enqueue();
    }
    
    const queueTime = performance.now() - queueStartTime;
    this.analytics.timeInQueue.push(queueTime);
    
    this.activeRequests++;
    this.analytics.total++;
    
    const requestStartTime = performance.now();
    
    try {
      const response = await fetch(url, options);
      this.analytics.completed++;
      
      const duration = performance.now() - requestStartTime;
      this.analytics.requestDuration.push(duration);
      
      return response;
    } catch (error) {
      this.analytics.failed++;
      throw error;
    } finally {
      this.activeRequests--;
      this._dequeue();
    }
  }
  
  _enqueue() {
    return new Promise(resolve => this.queue.push(resolve));
  }
  
  _dequeue() {
    if (this.queue.length > 0) {
      const resolve = this.queue.shift();
      resolve();
    }
  }
  
  _startMonitoring() {
    setInterval(() => {
      this.analytics.queueLengthHistory.push({
        timestamp: Date.now(),
        length: this.queue.length
      });
      
      this.analytics.activeConcurrentHistory.push({
        timestamp: Date.now(),
        count: this.activeRequests
      });
      
      // Keep only last 100 samples
      if (this.analytics.queueLengthHistory.length > 100) {
        this.analytics.queueLengthHistory.shift();
      }
      if (this.analytics.activeConcurrentHistory.length > 100) {
        this.analytics.activeConcurrentHistory.shift();
      }
    }, 1000);
  }
  
  getAnalytics() {
    const avgQueueTime = this.analytics.timeInQueue.length > 0
      ? this.analytics.timeInQueue.reduce((a, b) => a + b, 0) / this.analytics.timeInQueue.length
      : 0;
    
    const avgDuration = this.analytics.requestDuration.length > 0
      ? this.analytics.requestDuration.reduce((a, b) => a + b, 0) / this.analytics.requestDuration.length
      : 0;
    
    const successRate = this.analytics.total > 0
      ? (this.analytics.completed / this.analytics.total * 100).toFixed(2)
      : 0;
    
    return {
      total: this.analytics.total,
      completed: this.analytics.completed,
      failed: this.analytics.failed,
      successRate: successRate + '%',
      avgQueueTime: avgQueueTime.toFixed(2) + 'ms',
      avgRequestDuration: avgDuration.toFixed(2) + 'ms',
      currentActive: this.activeRequests,
      currentQueued: this.queue.length,
      queueHistory: this.analytics.queueLengthHistory,
      concurrencyHistory: this.analytics.activeConcurrentHistory
    };
  }
  
resetAnalytics() {
  this.analytics = {
    total: 0,
    completed: 0,
    failed: 0,
    timeInQueue: [],
    requestDuration: [],
    queueLengthHistory: [],
    activeConcurrentHistory: []
  };
}
```

---

