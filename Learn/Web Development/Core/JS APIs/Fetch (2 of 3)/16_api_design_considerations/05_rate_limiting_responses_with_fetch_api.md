## Rate Limiting Responses with Fetch API


### Understanding Rate Limit Response Headers

APIs typically communicate rate limit information through standardized HTTP headers:

```javascript
async function checkRateLimitHeaders(response) {
  const headers = {
    limit: response.headers.get('X-RateLimit-Limit'),
    remaining: response.headers.get('X-RateLimit-Remaining'),
    reset: response.headers.get('X-RateLimit-Reset'),
    retryAfter: response.headers.get('Retry-After')
  };
  
  return {
    limit: parseInt(headers.limit) || null,
    remaining: parseInt(headers.remaining) || null,
    reset: parseInt(headers.reset) || null,
    retryAfter: parseInt(headers.retryAfter) || null
  };
}
```

Common header naming conventions:

- `X-RateLimit-Limit` / `X-Rate-Limit-Limit` / `RateLimit-Limit`
- `X-RateLimit-Remaining` / `X-Rate-Limit-Remaining` / `RateLimit-Remaining`
- `X-RateLimit-Reset` / `X-Rate-Limit-Reset` / `RateLimit-Reset`
- `Retry-After` (standard HTTP header)

### Detecting Rate Limit Status

Identify when rate limits are hit through status codes and headers:

```javascript
class RateLimitDetector {
  static isRateLimited(response) {
    // Check 429 status code (standard)
    if (response.status === 429) {
      return true;
    }
    
    // Check 403 with rate limit indicator
    if (response.status === 403) {
      const rateLimitRemaining = response.headers.get('X-RateLimit-Remaining');
      if (rateLimitRemaining === '0') {
        return true;
      }
    }
    
    return false;
  }
  
  static getRetryDelay(response) {
    // Check Retry-After header (seconds or HTTP date)
    const retryAfter = response.headers.get('Retry-After');
    if (retryAfter) {
      // If numeric, it's seconds
      if (/^\d+$/.test(retryAfter)) {
        return parseInt(retryAfter) * 1000;
      }
      
      // If date string, calculate milliseconds until that time
      const retryDate = new Date(retryAfter);
      return Math.max(0, retryDate.getTime() - Date.now());
    }
    
    // Check X-RateLimit-Reset (typically Unix timestamp)
    const resetTime = response.headers.get('X-RateLimit-Reset');
    if (resetTime) {
      const resetTimestamp = parseInt(resetTime) * 1000;
      return Math.max(0, resetTimestamp - Date.now());
    }
    
    // Default fallback
    return 60000; // 1 minute
  }
}
```

### Basic Retry with Exponential Backoff

Implement retry logic when rate limits are encountered:

```javascript
class RateLimitedFetch {
  constructor(maxRetries = 3) {
    this.maxRetries = maxRetries;
  }
  
  async fetch(url, options = {}, attempt = 1) {
    try {
      const response = await fetch(url, options);
      
      if (RateLimitDetector.isRateLimited(response)) {
        if (attempt >= this.maxRetries) {
          throw new RateLimitError('Max retries exceeded', response);
        }
        
        const delay = RateLimitDetector.getRetryDelay(response);
        console.log(`Rate limited. Retrying after ${delay}ms`);
        
        await this.sleep(delay);
        return this.fetch(url, options, attempt + 1);
      }
      
      return response;
    } catch (error) {
      if (error instanceof RateLimitError) {
        throw error;
      }
      throw error;
    }
  }
  
  sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
  }
}

class RateLimitError extends Error {
  constructor(message, response) {
    super(message);
    this.name = 'RateLimitError';
    this.response = response;
  }
}
```

### Request Queue Pattern

Queue requests to avoid hitting rate limits:

```javascript
class RequestQueue {
  constructor(rateLimit, interval) {
    this.queue = [];
    this.processing = false;
    this.rateLimit = rateLimit; // requests per interval
    this.interval = interval; // milliseconds
    this.requestCount = 0;
    this.windowStart = Date.now();
  }
  
  async enqueue(url, options = {}) {
    return new Promise((resolve, reject) => {
      this.queue.push({ url, options, resolve, reject });
      this.process();
    });
  }
  
  async process() {
    if (this.processing || this.queue.length === 0) {
      return;
    }
    
    this.processing = true;
    
    // Sort by priority
    this.queue.sort((a, b) => {
      const priorities = { high: 3, medium: 2, low: 1 };
      return priorities[b.priority] - priorities[a.priority];
    });
    
    while (this.queue.length > 0) {
      // Check circuit breaker
      if (this.enableCircuitBreaker && this.circuitBreaker.getState().state === 'OPEN') {
        await this.sleep(1000);
        continue;
      }
      
      // Wait if needed
      const waitTime = await this.getWaitTime();
      if (waitTime > 0) {
        await this.sleep(waitTime);
      }
      
      const request = this.queue.shift();
      
      try {
        // Make request
        const response = await fetch(request.url, request.options);
        
        // Update tracker
        const endpoint = new URL(request.url).pathname;
        this.tracker.updateFromResponse(endpoint, response);
        
        // Check if rate limited
        if (RateLimitDetector.isRateLimited(response)) {
          if (request.attempts < this.maxRetries) {
            request.attempts++;
            const retryDelay = RateLimitDetector.getRetryDelay(response);
            await this.sleep(retryDelay);
            this.queue.unshift(request);
            
            if (this.enableCircuitBreaker) {
              this.circuitBreaker.recordFailure();
            }
            
            continue;
          } else {
            request.reject(new RateLimitError('Max retries exceeded', response));
          }
        } else {
          this.recordRequest();
          
          if (this.enableCircuitBreaker) {
            this.circuitBreaker.recordSuccess();
          }
          
          request.resolve(response);
        }
      } catch (error) {
        if (request.attempts < this.maxRetries) {
          request.attempts++;
          this.queue.unshift(request);
        } else {
          request.reject(error);
        }
      }
    }
    
    this.processing = false;
  }
  
  recordRequest() {
    this.requests.push(Date.now());
    this.cleanOldRequests();
  }
  
  cleanOldRequests() {
    const cutoff = Date.now() - this.windowMs;
    this.requests = this.requests.filter(timestamp => timestamp > cutoff);
  }
  
  async getWaitTime() {
    this.cleanOldRequests();
    
    if (this.requests.length < this.currentRate) {
      return 0;
    }
    
    const oldestRequest = this.requests[0];
    return Math.max(0, (oldestRequest + this.windowMs) - Date.now());
  }
  
  sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
  }
  
  getStatus() {
    this.cleanOldRequests();
    
    return {
      queueLength: this.queue.length,
      requestsInWindow: this.requests.length,
      remainingRequests: this.currentRate - this.requests.length,
      currentRate: this.currentRate,
      circuitBreakerState: this.circuitBreaker?.getState() || null
    };
  }
  
  reset() {
    this.requests = [];
    this.queue = [];
    if (this.circuitBreaker) {
      this.circuitBreaker.reset();
    }
  }
}

// Usage example
const rateLimiter = new ComprehensiveRateLimiter({
  maxRequests: 100,
  windowMs: 60000,
  maxRetries: 3,
  enableAdaptive: true,
  enableCircuitBreaker: true
});

// Make rate-limited request
const response = await rateLimiter.fetch('/api/data', {
  method: 'GET'
}, 'high');

// Check status
console.log(rateLimiter.getStatus());;
    }
    
    this.processing = true;
    
    while (this.queue.length > 0) {
      await this.waitIfNeeded();
      
      const request = this.queue.shift();
      
      try {
        const response = await fetch(request.url, request.options);
        request.resolve(response);
      } catch (error) {
        request.reject(error);
      }
      
      this.requestCount++;
    }
    
    this.processing = false;
  }
  
  async waitIfNeeded() {
    const now = Date.now();
    const elapsed = now - this.windowStart;
    
    if (elapsed >= this.interval) {
      // Reset window
      this.windowStart = now;
      this.requestCount = 0;
      return;
    }
    
    if (this.requestCount >= this.rateLimit) {
      // Wait until window expires
      const waitTime = this.interval - elapsed;
      await this.sleep(waitTime);
      this.windowStart = Date.now();
      this.requestCount = 0;
    }
  }
  
  sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
  }
  
  getQueueLength() {
    return this.queue.length;
  }
}

// Usage: 10 requests per second
const queue = new RequestQueue(10, 1000);

async function makeRequest(url) {
  const response = await queue.enqueue(url);
  return response.json();
}
```

### Token Bucket Algorithm

Implement smooth rate limiting with burst capacity:

```javascript
class TokenBucket {
  constructor(capacity, refillRate, refillInterval = 1000) {
    this.capacity = capacity; // max tokens
    this.tokens = capacity; // current tokens
    this.refillRate = refillRate; // tokens added per interval
    this.refillInterval = refillInterval; // milliseconds
    this.lastRefill = Date.now();
    this.queue = [];
  }
  
  startRefilling() {
    this.refillTimer = setInterval(() => {
      this.refill();
    }, this.refillInterval);
  }
  
  stopRefilling() {
    if (this.refillTimer) {
      clearInterval(this.refillTimer);
    }
  }
  
  refill() {
    const now = Date.now();
    const elapsed = now - this.lastRefill;
    const tokensToAdd = Math.floor((elapsed / this.refillInterval) * this.refillRate);
    
    this.tokens = Math.min(this.capacity, this.tokens + tokensToAdd);
    this.lastRefill = now;
    
    this.processQueue();
  }
  
  async acquire(tokensNeeded = 1) {
    return new Promise((resolve) => {
      if (this.tokens >= tokensNeeded) {
        this.tokens -= tokensNeeded;
        resolve();
      } else {
        this.queue.push({ tokensNeeded, resolve });
      }
    });
  }
  
  processQueue() {
    while (this.queue.length > 0 && this.tokens >= this.queue[0].tokensNeeded) {
      const request = this.queue.shift();
      this.tokens -= request.tokensNeeded;
      request.resolve();
    }
  }
  
  async fetch(url, options = {}, tokensNeeded = 1) {
    await this.acquire(tokensNeeded);
    return fetch(url, options);
  }
  
  getAvailableTokens() {
    return this.tokens;
  }
}

// Usage: 10 token capacity, refill 2 tokens per second
const bucket = new TokenBucket(10, 2, 1000);
bucket.startRefilling();

async function makeRequest(url) {
  const response = await bucket.fetch(url);
  return response.json();
}
```

### Sliding Window Rate Limiter

Track requests with precise time-based windows:

```javascript
class SlidingWindowLimiter {
  constructor(maxRequests, windowMs) {
    this.maxRequests = maxRequests;
    this.windowMs = windowMs;
    this.requests = [];
  }
  
  cleanOldRequests() {
    const cutoff = Date.now() - this.windowMs;
    this.requests = this.requests.filter(timestamp => timestamp > cutoff);
  }
  
  canMakeRequest() {
    this.cleanOldRequests();
    return this.requests.length < this.maxRequests;
  }
  
  recordRequest() {
    this.requests.push(Date.now());
  }
  
  async waitForSlot() {
    this.cleanOldRequests();
    
    if (this.requests.length < this.maxRequests) {
      return 0;
    }
    
    // Calculate when oldest request expires
    const oldestRequest = this.requests[0];
    const waitTime = (oldestRequest + this.windowMs) - Date.now();
    return Math.max(0, waitTime);
  }
  
  async fetch(url, options = {}) {
    const waitTime = await this.waitForSlot();
    
    if (waitTime > 0) {
      await this.sleep(waitTime);
    }
    
    this.recordRequest();
    return fetch(url, options);
  }
  
  sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
  }
  
  getRemainingRequests() {
    this.cleanOldRequests();
    return this.maxRequests - this.requests.length;
  }
  
  getResetTime() {
    this.cleanOldRequests();
    if (this.requests.length === 0) {
      return 0;
    }
    return this.requests[0] + this.windowMs;
  }
}

// Usage: 100 requests per minute
const limiter = new SlidingWindowLimiter(100, 60000);

async function makeRequest(url) {
  const response = await limiter.fetch(url);
  return response.json();
}
```

### Multi-Tier Rate Limiting

Handle different rate limits for different endpoints:

```javascript
class MultiTierRateLimiter {
  constructor() {
    this.limiters = new Map();
  }
  
  addLimiter(key, limiter) {
    this.limiters.set(key, limiter);
  }
  
  getLimiterForEndpoint(url) {
    // Check for specific endpoint limiters
    for (const [pattern, limiter] of this.limiters.entries()) {
      if (url.includes(pattern)) {
        return limiter;
      }
    }
    
    // Return default limiter
    return this.limiters.get('default');
  }
  
  async fetch(url, options = {}) {
    const limiter = this.getLimiterForEndpoint(url);
    
    if (!limiter) {
      return fetch(url, options);
    }
    
    return limiter.fetch(url, options);
  }
  
  getStatus(key) {
    const limiter = this.limiters.get(key);
    if (!limiter) return null;
    
    return {
      remaining: limiter.getRemainingRequests?.() || null,
      resetTime: limiter.getResetTime?.() || null
    };
  }
}

// Usage
const rateLimiter = new MultiTierRateLimiter();

// Strict limit for search endpoint
rateLimiter.addLimiter('/api/search', new SlidingWindowLimiter(10, 60000));

// Moderate limit for user data
rateLimiter.addLimiter('/api/users', new SlidingWindowLimiter(50, 60000));

// Generous default
rateLimiter.addLimiter('default', new SlidingWindowLimiter(100, 60000));

const response = await rateLimiter.fetch('/api/search?q=test');
```

### Adaptive Rate Limiting

Dynamically adjust request rate based on responses:

```javascript
class AdaptiveRateLimiter {
  constructor(initialRate = 10, minRate = 1, maxRate = 100) {
    this.currentRate = initialRate;
    this.minRate = minRate;
    this.maxRate = maxRate;
    this.interval = 1000;
    this.successCount = 0;
    this.failureCount = 0;
    this.queue = [];
    this.processing = false;
  }
  
  async enqueue(url, options = {}) {
    return new Promise((resolve, reject) => {
      this.queue.push({ url, options, resolve, reject });
      this.process();
    });
  }
  
  async process() {
    if (this.processing || this.queue.length === 0) {
      return;
    }
    
    this.processing = true;
    
    while (this.queue.length > 0) {
      const delay = this.interval / this.currentRate;
      await this.sleep(delay);
      
      const request = this.queue.shift();
      
      try {
        const response = await fetch(request.url, request.options);
        
        if (RateLimitDetector.isRateLimited(response)) {
          this.handleRateLimit(response);
          // Re-queue the request
          this.queue.unshift(request);
          continue;
        }
        
        this.handleSuccess();
        request.resolve(response);
      } catch (error) {
        this.handleFailure();
        request.reject(error);
      }
    }
    
    this.processing = false;
  }
  
  handleRateLimit(response) {
    this.failureCount++;
    
    // Decrease rate by 50%
    this.currentRate = Math.max(
      this.minRate,
      Math.floor(this.currentRate * 0.5)
    );
    
    console.log(`Rate limited. Reduced rate to ${this.currentRate} req/s`);
    
    // Get delay from headers
    const delay = RateLimitDetector.getRetryDelay(response);
    return this.sleep(delay);
  }
  
  handleSuccess() {
    this.successCount++;
    
    // After 10 successful requests, try increasing rate
    if (this.successCount % 10 === 0) {
      this.currentRate = Math.min(
        this.maxRate,
        Math.floor(this.currentRate * 1.1)
      );
      console.log(`Increased rate to ${this.currentRate} req/s`);
    }
  }
  
  handleFailure() {
    this.failureCount++;
    
    // After 3 failures, decrease rate
    if (this.failureCount % 3 === 0) {
      this.currentRate = Math.max(
        this.minRate,
        Math.floor(this.currentRate * 0.9)
      );
    }
  }
  
  sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
  }
  
  getCurrentRate() {
    return this.currentRate;
  }
}

// Usage
const limiter = new AdaptiveRateLimiter(10, 1, 50);
const response = await limiter.enqueue('/api/data');
```

### Circuit Breaker Pattern

Prevent cascading failures when rate limits are consistently hit:

```javascript
class CircuitBreaker {
  constructor(threshold = 5, timeout = 60000) {
    this.state = 'CLOSED'; // CLOSED, OPEN, HALF_OPEN
    this.failureCount = 0;
    this.threshold = threshold;
    this.timeout = timeout;
    this.nextAttempt = Date.now();
  }
  
  async fetch(url, options = {}) {
    if (this.state === 'OPEN') {
      if (Date.now() < this.nextAttempt) {
        throw new Error('Circuit breaker is OPEN');
      }
      this.state = 'HALF_OPEN';
    }
    
    try {
      const response = await fetch(url, options);
      
      if (RateLimitDetector.isRateLimited(response)) {
        this.recordFailure();
        throw new RateLimitError('Rate limit exceeded', response);
      }
      
      this.recordSuccess();
      return response;
    } catch (error) {
      this.recordFailure();
      throw error;
    }
  }
  
  recordSuccess() {
    this.failureCount = 0;
    
    if (this.state === 'HALF_OPEN') {
      this.state = 'CLOSED';
      console.log('Circuit breaker CLOSED');
    }
  }
  
  recordFailure() {
    this.failureCount++;
    
    if (this.failureCount >= this.threshold) {
      this.state = 'OPEN';
      this.nextAttempt = Date.now() + this.timeout;
      console.log(`Circuit breaker OPEN until ${new Date(this.nextAttempt)}`);
    }
  }
  
  getState() {
    return {
      state: this.state,
      failureCount: this.failureCount,
      nextAttempt: this.state === 'OPEN' ? this.nextAttempt : null
    };
  }
  
  reset() {
    this.state = 'CLOSED';
    this.failureCount = 0;
  }
}

// Usage with rate limiter
class RateLimitedFetchWithCircuitBreaker {
  constructor() {
    this.circuitBreaker = new CircuitBreaker(5, 60000);
    this.rateLimiter = new SlidingWindowLimiter(100, 60000);
  }
  
  async fetch(url, options = {}) {
    try {
      return await this.circuitBreaker.fetch(url, async (url, opts) => {
        return this.rateLimiter.fetch(url, opts);
      });
    } catch (error) {
      if (error instanceof RateLimitError) {
        console.error('Rate limit hit, circuit may open');
      }
      throw error;
    }
  }
}
```

### Rate Limit State Tracker

Monitor and expose rate limit state to application:

```javascript
class RateLimitTracker {
  constructor() {
    this.limits = new Map();
    this.listeners = [];
  }
  
  updateFromResponse(endpoint, response) {
    const limit = parseInt(response.headers.get('X-RateLimit-Limit')) || null;
    const remaining = parseInt(response.headers.get('X-RateLimit-Remaining')) || null;
    const reset = parseInt(response.headers.get('X-RateLimit-Reset')) || null;
    
    const state = {
      endpoint,
      limit,
      remaining,
      reset: reset ? reset * 1000 : null,
      updatedAt: Date.now()
    };
    
    this.limits.set(endpoint, state);
    this.notifyListeners(endpoint, state);
    
    return state;
  }
  
  getState(endpoint) {
    return this.limits.get(endpoint) || null;
  }
  
  getAllStates() {
    return Array.from(this.limits.entries()).map(([endpoint, state]) => ({
      endpoint,
      ...state
    }));
  }
  
  subscribe(callback) {
    this.listeners.push(callback);
    return () => {
      this.listeners = this.listeners.filter(cb => cb !== callback);
    };
  }
  
  notifyListeners(endpoint, state) {
    this.listeners.forEach(callback => {
      try {
        callback(endpoint, state);
      } catch (error) {
        console.error('Listener error:', error);
      }
    });
  }
  
  isNearLimit(endpoint, threshold = 0.1) {
    const state = this.limits.get(endpoint);
    if (!state || !state.limit || !state.remaining) {
      return false;
    }
    
    const percentRemaining = state.remaining / state.limit;
    return percentRemaining <= threshold;
  }
  
  getTimeUntilReset(endpoint) {
    const state = this.limits.get(endpoint);
    if (!state || !state.reset) {
      return null;
    }
    
    return Math.max(0, state.reset - Date.now());
  }
}

// Usage
const tracker = new RateLimitTracker();

// Subscribe to changes
tracker.subscribe((endpoint, state) => {
  console.log(`Rate limit updated for ${endpoint}:`, state);
  
  if (state.remaining !== null && state.remaining < 10) {
    console.warn(`Low rate limit remaining for ${endpoint}`);
  }
});

// Update after each request
async function trackedFetch(url, options = {}) {
  const endpoint = new URL(url).pathname;
  const response = await fetch(url, options);
  
  tracker.updateFromResponse(endpoint, response);
  
  return response;
}
```

### Batch Request Handler

Combine multiple requests to reduce rate limit consumption:

```javascript
class BatchRequestHandler {
  constructor(batchSize = 10, batchDelay = 100) {
    this.batchSize = batchSize;
    this.batchDelay = batchDelay;
    this.pendingRequests = [];
    this.batchTimer = null;
  }
  
  async request(url, options = {}) {
    return new Promise((resolve, reject) => {
      this.pendingRequests.push({ url, options, resolve, reject });
      
      if (this.pendingRequests.length >= this.batchSize) {
        this.flush();
      } else if (!this.batchTimer) {
        this.batchTimer = setTimeout(() => this.flush(), this.batchDelay);
      }
    });
  }
  
  async flush() {
    if (this.batchTimer) {
      clearTimeout(this.batchTimer);
      this.batchTimer = null;
    }
    
    if (this.pendingRequests.length === 0) {
      return;
    }
    
    const batch = this.pendingRequests.splice(0);
    
    try {
      // Combine requests into single batch request
      const batchPayload = batch.map(req => ({
        url: req.url,
        method: req.options.method || 'GET',
        body: req.options.body
      }));
      
      const response = await fetch('/api/batch', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ requests: batchPayload })
      });
      
      const results = await response.json();
      
      // Resolve individual promises
      batch.forEach((req, index) => {
        req.resolve(results[index]);
      });
    } catch (error) {
      // Reject all promises in batch
      batch.forEach(req => req.reject(error));
    }
  }
  
  getQueueSize() {
    return this.pendingRequests.length;
  }
}

// Usage
const batcher = new BatchRequestHandler(10, 100);

async function fetchWithBatching(url) {
  return batcher.request(url);
}
```

### Priority Queue for Requests

Handle requests with different priorities:

```javascript
class PriorityRequestQueue {
  constructor(rateLimit, interval) {
    this.queues = {
      high: [],
      medium: [],
      low: []
    };
    this.processing = false;
    this.rateLimit = rateLimit;
    this.interval = interval;
    this.requestCount = 0;
    this.windowStart = Date.now();
  }
  
  async enqueue(url, options = {}, priority = 'medium') {
    return new Promise((resolve, reject) => {
      const queue = this.queues[priority] || this.queues.medium;
      queue.push({ url, options, resolve, reject, priority });
      this.process();
    });
  }
  
  async process() {
    if (this.processing) {
      return;
    }
    
    this.processing = true;
    
    while (this.hasRequests()) {
      await this.waitIfNeeded();
      
      const request = this.getNextRequest();
      if (!request) break;
      
      try {
        const response = await fetch(request.url, request.options);
        request.resolve(response);
      } catch (error) {
        request.reject(error);
      }
      
      this.requestCount++;
    }
    
    this.processing = false;
  }
  
  hasRequests() {
    return this.queues.high.length > 0 ||
           this.queues.medium.length > 0 ||
           this.queues.low.length > 0;
  }
  
  getNextRequest() {
    if (this.queues.high.length > 0) {
      return this.queues.high.shift();
    }
    if (this.queues.medium.length > 0) {
      return this.queues.medium.shift();
    }
    if (this.queues.low.length > 0) {
      return this.queues.low.shift();
    }
    return null;
  }
  
  async waitIfNeeded() {
    const now = Date.now();
    const elapsed = now - this.windowStart;
    
    if (elapsed >= this.interval) {
      this.windowStart = now;
      this.requestCount = 0;
      return;
    }
    
    if (this.requestCount >= this.rateLimit) {
      const waitTime = this.interval - elapsed;
      await this.sleep(waitTime);
      this.windowStart = Date.now();
      this.requestCount = 0;
    }
  }
  
  sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
  }
  
  getQueueLengths() {
    return {
      high: this.queues.high.length,
      medium: this.queues.medium.length,
      low: this.queues.low.length
    };
  }
}

// Usage
const queue = new PriorityRequestQueue(10, 1000);

// High priority request
await queue.enqueue('/api/critical', {}, 'high');

// Medium priority (default)
await queue.enqueue('/api/normal', {});

// Low priority
await queue.enqueue('/api/background', {}, 'low');
```

### Persistent Rate Limit State

Store rate limit state across page reloads:

```javascript
class PersistentRateLimiter {
  constructor(storageKey, maxRequests, windowMs) {
    this.storageKey = storageKey;
    this.maxRequests = maxRequests;
    this.windowMs = windowMs;
    this.loadState();
  }
  
  loadState() {
    try {
      const stored = localStorage.getItem(this.storageKey);
      if (stored) {
        this.requests = JSON.parse(stored);
        this.cleanOldRequests();
      } else {
        this.requests = [];
      }
    } catch (error) {
      console.error('Failed to load rate limit state:', error);
      this.requests = [];
    }
  }
  
  saveState() {
    try {
      localStorage.setItem(this.storageKey, JSON.stringify(this.requests));
    } catch (error) {
      console.error('Failed to save rate limit state:', error);
    }
  }
  
  cleanOldRequests() {
    const cutoff = Date.now() - this.windowMs;
    const initialLength = this.requests.length;
    this.requests = this.requests.filter(timestamp => timestamp > cutoff);
    
    if (this.requests.length !== initialLength) {
      this.saveState();
    }
  }
  
  canMakeRequest() {
    this.cleanOldRequests();
    return this.requests.length < this.maxRequests;
  }
  
  async waitForSlot() {
    this.cleanOldRequests();
    
    if (this.requests.length < this.maxRequests) {
      return 0;
    }
    
    const oldestRequest = this.requests[0];
    const waitTime = (oldestRequest + this.windowMs) - Date.now();
    return Math.max(0, waitTime);
  }
  
  async fetch(url, options = {}) {
    const waitTime = await this.waitForSlot();
    
    if (waitTime > 0) {
      await this.sleep(waitTime);
    }
    
    this.requests.push(Date.now());
    this.saveState();
    
    return fetch(url, options);
  }
  
  sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
  }
  
  getRemainingRequests() {
    this.cleanOldRequests();
    return this.maxRequests - this.requests.length;
  }
  
  reset() {
    this.requests = [];
    this.saveState();
  }
}

// Usage
const limiter = new PersistentRateLimiter('api_rate_limit', 100, 60000);
```

### Complete Rate Limiter Implementation

```javascript
class ComprehensiveRateLimiter {
  constructor(config = {}) {
    // Configuration
    this.maxRequests = config.maxRequests || 100;
    this.windowMs = config.windowMs || 60000;
    this.maxRetries = config.maxRetries || 3;
    this.enableAdaptive = config.enableAdaptive || false;
    this.enableCircuitBreaker = config.enableCircuitBreaker || false;
    
    // State
    this.requests = [];
    this.queue = [];
    this.processing = false;
    this.currentRate = this.maxRequests;
    
    // Components
    this.tracker = new RateLimitTracker();
    
    if (this.enableCircuitBreaker) {
      this.circuitBreaker = new CircuitBreaker(5, 60000);
    }
  }
  
  async fetch(url, options = {}, priority = 'medium') {
    return new Promise((resolve, reject) => {
      this.queue.push({
        url,
        options,
        priority,
        resolve,
        reject,
        attempts: 0
      });
      
      this.process();
    });
  }
  
  async process() {
    if (this.processing || this.queue.length === 0) {
      return
```

---

