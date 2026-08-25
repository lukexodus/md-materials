## Rate Limiting in Fetch API


### Client-Side Rate Limiting Fundamentals

Client-side rate limiting controls the frequency of outgoing requests to prevent overwhelming servers, avoid hitting API quotas, or manage resource consumption. Unlike server-side rate limiting which rejects requests, client-side implementation queues or delays requests before sending them.

### Basic Rate Limiting Patterns

#### Simple Token Bucket

```javascript
class TokenBucket {
  constructor(capacity, refillRate) {
    this.capacity = capacity;
    this.tokens = capacity;
    this.refillRate = refillRate; // tokens per second
    this.lastRefill = Date.now();
  }
  
  refill() {
    const now = Date.now();
    const timePassed = (now - this.lastRefill) / 1000;
    const tokensToAdd = timePassed * this.refillRate;
    
    this.tokens = Math.min(this.capacity, this.tokens + tokensToAdd);
    this.lastRefill = now;
  }
  
  async consume(tokens = 1) {
    this.refill();
    
    if (this.tokens >= tokens) {
      this.tokens -= tokens;
      return true;
    }
    
    // Wait until enough tokens are available
    const tokensNeeded = tokens - this.tokens;
    const waitTime = (tokensNeeded / this.refillRate) * 1000;
    
    await new Promise(resolve => setTimeout(resolve, waitTime));
    
    this.refill();
    this.tokens -= tokens;
    return true;
  }
}

// Usage
const bucket = new TokenBucket(10, 2); // 10 tokens, refill 2 per second

async function rateLimitedFetch(url, options) {
  await bucket.consume();
  return fetch(url, options);
}
```

#### Fixed Window Counter

```javascript
class FixedWindowRateLimiter {
  constructor(maxRequests, windowMs) {
    this.maxRequests = maxRequests;
    this.windowMs = windowMs;
    this.requests = [];
  }
  
  async acquire() {
    const now = Date.now();
    const windowStart = now - this.windowMs;
    
    // Remove requests outside current window
    this.requests = this.requests.filter(time => time > windowStart);
    
    if (this.requests.length >= this.maxRequests) {
      const oldestRequest = this.requests[0];
      const waitTime = oldestRequest + this.windowMs - now;
      
      await new Promise(resolve => setTimeout(resolve, waitTime));
      return this.acquire();
    }
    
    this.requests.push(now);
  }
}

// Usage: 100 requests per minute
const limiter = new FixedWindowRateLimiter(100, 60000);

async function rateLimitedFetch(url, options) {
  await limiter.acquire();
  return fetch(url, options);
}
```

#### Sliding Window Log

```javascript
class SlidingWindowRateLimiter {
  constructor(maxRequests, windowMs) {
    this.maxRequests = maxRequests;
    this.windowMs = windowMs;
    this.requestLog = [];
  }
  
  async throttle() {
    const now = Date.now();
    const windowStart = now - this.windowMs;
    
    // Clean old entries
    this.requestLog = this.requestLog.filter(timestamp => timestamp > windowStart);
    
    if (this.requestLog.length >= this.maxRequests) {
      const oldestInWindow = this.requestLog[0];
      const waitTime = oldestInWindow + this.windowMs - now + 1;
      
      await new Promise(resolve => setTimeout(resolve, waitTime));
      return this.throttle();
    }
    
    this.requestLog.push(now);
  }
}

const limiter = new SlidingWindowRateLimiter(50, 60000);

async function rateLimitedFetch(url, options) {
  await limiter.throttle();
  return fetch(url, options);
}
```

### Queue-Based Rate Limiting

#### Request Queue with Concurrent Limit

```javascript
class RequestQueue {
  constructor(concurrency = 5, delayMs = 0) {
    this.concurrency = concurrency;
    this.delayMs = delayMs;
    this.running = 0;
    this.queue = [];
  }
  
  async add(fn) {
    return new Promise((resolve, reject) => {
      this.queue.push({ fn, resolve, reject });
      this.process();
    });
  }
  
  async process() {
    if (this.running >= this.concurrency || this.queue.length === 0) {
      return;
    }
    
    this.running++;
    const { fn, resolve, reject } = this.queue.shift();
    
    try {
      const result = await fn();
      resolve(result);
    } catch (error) {
      reject(error);
    } finally {
      this.running--;
      
      if (this.delayMs > 0) {
        await new Promise(resolve => setTimeout(resolve, this.delayMs));
      }
      
      this.process();
    }
  }
  
  async fetch(url, options) {
    return this.add(() => fetch(url, options));
  }
}

// Usage: 5 concurrent requests, 200ms delay between each
const queue = new RequestQueue(5, 200);

// All requests automatically queued
const responses = await Promise.all([
  queue.fetch('/api/user/1'),
  queue.fetch('/api/user/2'),
  queue.fetch('/api/user/3'),
  // ... 100 more requests
]);
```

#### Priority Queue

```javascript
class PriorityRequestQueue {
  constructor(concurrency = 3) {
    this.concurrency = concurrency;
    this.running = 0;
    this.queue = [];
  }
  
  async add(fn, priority = 0) {
    return new Promise((resolve, reject) => {
      this.queue.push({ fn, resolve, reject, priority });
      this.queue.sort((a, b) => b.priority - a.priority);
      this.process();
    });
  }
  
  async process() {
    if (this.running >= this.concurrency || this.queue.length === 0) {
      return;
    }
    
    this.running++;
    const { fn, resolve, reject } = this.queue.shift();
    
    try {
      const result = await fn();
      resolve(result);
    } catch (error) {
      reject(error);
    } finally {
      this.running--;
      this.process();
    }
  }
  
  async fetch(url, options, priority = 0) {
    return this.add(() => fetch(url, options), priority);
  }
}

const queue = new PriorityRequestQueue(3);

// High priority requests processed first
await queue.fetch('/api/critical', {}, 10);
await queue.fetch('/api/normal', {}, 0);
await queue.fetch('/api/low', {}, -5);
```

### Adaptive Rate Limiting

#### Response-Based Adjustment

```javascript
class AdaptiveRateLimiter {
  constructor(initialRate = 10, minRate = 1, maxRate = 100) {
    this.currentRate = initialRate;
    this.minRate = minRate;
    this.maxRate = maxRate;
    this.queue = [];
    this.processing = false;
    this.successCount = 0;
    this.errorCount = 0;
  }
  
  adjustRate(success) {
    if (success) {
      this.successCount++;
      this.errorCount = Math.max(0, this.errorCount - 1);
      
      // Gradually increase rate on success
      if (this.successCount > 10) {
        this.currentRate = Math.min(this.maxRate, this.currentRate * 1.1);
        this.successCount = 0;
      }
    } else {
      this.errorCount++;
      this.successCount = 0;
      
      // Decrease rate on errors
      this.currentRate = Math.max(this.minRate, this.currentRate * 0.5);
    }
  }
  
  async fetch(url, options) {
    return new Promise((resolve, reject) => {
      this.queue.push({ url, options, resolve, reject });
      this.processQueue();
    });
  }
  
  async processQueue() {
    if (this.processing || this.queue.length === 0) {
      return;
    }
    
    this.processing = true;
    
    while (this.queue.length > 0) {
      const { url, options, resolve, reject } = this.queue.shift();
      const delayMs = 1000 / this.currentRate;
      
      try {
        const response = await fetch(url, options);
        
        if (response.status === 429) {
          // Rate limited by server
          this.adjustRate(false);
          
          const retryAfter = response.headers.get('Retry-After');
          if (retryAfter) {
            await new Promise(r => setTimeout(r, parseInt(retryAfter) * 1000));
          }
          
          // Re-queue the request
          this.queue.unshift({ url, options, resolve, reject });
          continue;
        }
        
        this.adjustRate(response.ok);
        resolve(response);
      } catch (error) {
        this.adjustRate(false);
        reject(error);
      }
      
      if (this.queue.length > 0) {
        await new Promise(r => setTimeout(r, delayMs));
      }
    }
    
    this.processing = false;
  }
}

const limiter = new AdaptiveRateLimiter(10, 1, 50);

async function smartFetch(url, options) {
  return limiter.fetch(url, options);
}
```

#### Server Header Respect

```javascript
class HeaderBasedRateLimiter {
  constructor() {
    this.limits = new Map();
  }
  
  parseRateLimitHeaders(response, key) {
    const limit = parseInt(response.headers.get('X-RateLimit-Limit') || '0');
    const remaining = parseInt(response.headers.get('X-RateLimit-Remaining') || '0');
    const reset = parseInt(response.headers.get('X-RateLimit-Reset') || '0');
    
    if (limit && reset) {
      this.limits.set(key, {
        limit,
        remaining,
        reset: reset * 1000, // Convert to milliseconds
        lastUpdate: Date.now()
      });
    }
  }
  
  async waitIfNeeded(key) {
    const limitInfo = this.limits.get(key);
    
    if (!limitInfo) {
      return;
    }
    
    const now = Date.now();
    
    if (limitInfo.remaining <= 0 && limitInfo.reset > now) {
      const waitTime = limitInfo.reset - now;
      await new Promise(resolve => setTimeout(resolve, waitTime));
      
      // Reset the limit after waiting
      this.limits.delete(key);
    }
  }
  
  async fetch(url, options = {}) {
    const urlObj = new URL(url);
    const key = `${urlObj.hostname}${urlObj.pathname}`;
    
    await this.waitIfNeeded(key);
    
    const response = await fetch(url, options);
    this.parseRateLimitHeaders(response, key);
    
    if (response.status === 429) {
      const retryAfter = response.headers.get('Retry-After');
      
      if (retryAfter) {
        const waitMs = retryAfter.includes(':') 
          ? new Date(retryAfter).getTime() - Date.now()
          : parseInt(retryAfter) * 1000;
        
        await new Promise(resolve => setTimeout(resolve, waitMs));
        return this.fetch(url, options);
      }
    }
    
    return response;
  }
}

const limiter = new HeaderBasedRateLimiter();

async function respectedFetch(url, options) {
  return limiter.fetch(url, options);
}
```

### Per-Domain Rate Limiting

#### Multi-Domain Manager

```javascript
class MultiDomainRateLimiter {
  constructor(defaultConfig = { maxRequests: 10, windowMs: 1000 }) {
    this.defaultConfig = defaultConfig;
    this.limiters = new Map();
    this.domainConfigs = new Map();
  }
  
  setDomainConfig(domain, config) {
    this.domainConfigs.set(domain, config);
  }
  
  getLimiter(domain) {
    if (!this.limiters.has(domain)) {
      const config = this.domainConfigs.get(domain) || this.defaultConfig;
      this.limiters.set(domain, new SlidingWindowRateLimiter(
        config.maxRequests,
        config.windowMs
      ));
    }
    return this.limiters.get(domain);
  }
  
  async fetch(url, options) {
    const urlObj = new URL(url);
    const domain = urlObj.hostname;
    const limiter = this.getLimiter(domain);
    
    await limiter.throttle();
    return fetch(url, options);
  }
}

const multiLimiter = new MultiDomainRateLimiter();

// Configure specific domains
multiLimiter.setDomainConfig('api.github.com', {
  maxRequests: 60,
  windowMs: 60000
});

multiLimiter.setDomainConfig('api.twitter.com', {
  maxRequests: 15,
  windowMs: 900000
});

// Automatically applies correct limits per domain
await multiLimiter.fetch('https://api.github.com/user');
await multiLimiter.fetch('https://api.twitter.com/tweets');
```

### Exponential Backoff

#### Basic Exponential Backoff

```javascript
class ExponentialBackoff {
  constructor(initialDelay = 1000, maxDelay = 32000, maxRetries = 5) {
    this.initialDelay = initialDelay;
    this.maxDelay = maxDelay;
    this.maxRetries = maxRetries;
  }
  
  calculateDelay(attempt) {
    const exponentialDelay = this.initialDelay * Math.pow(2, attempt);
    const jitter = Math.random() * 0.3 * exponentialDelay;
    return Math.min(exponentialDelay + jitter, this.maxDelay);
  }
  
  async fetch(url, options = {}) {
    let lastError;
    
    for (let attempt = 0; attempt <= this.maxRetries; attempt++) {
      try {
        const response = await fetch(url, options);
        
        if (response.ok) {
          return response;
        }
        
        // Retry on 429 or 5xx errors
        if (response.status === 429 || response.status >= 500) {
          if (attempt < this.maxRetries) {
            const delay = this.calculateDelay(attempt);
            await new Promise(resolve => setTimeout(resolve, delay));
            continue;
          }
        }
        
        return response;
      } catch (error) {
        lastError = error;
        
        if (attempt < this.maxRetries) {
          const delay = this.calculateDelay(attempt);
          await new Promise(resolve => setTimeout(resolve, delay));
        }
      }
    }
    
    throw lastError || new Error('Max retries exceeded');
  }
}

const backoff = new ExponentialBackoff(1000, 32000, 5);

async function resilientFetch(url, options) {
  return backoff.fetch(url, options);
}
```

#### Decorrelated Jitter

```javascript
class DecorrelatedJitter {
  constructor(baseDelay = 100, maxDelay = 20000) {
    this.baseDelay = baseDelay;
    this.maxDelay = maxDelay;
    this.previousDelay = baseDelay;
  }
  
  calculateDelay() {
    const delay = Math.random() * (this.previousDelay * 3 - this.baseDelay) + this.baseDelay;
    this.previousDelay = Math.min(delay, this.maxDelay);
    return this.previousDelay;
  }
  
  async fetch(url, options = {}, maxRetries = 5) {
    let attempt = 0;
    
    while (attempt <= maxRetries) {
      try {
        const response = await fetch(url, options);
        
        if (response.ok || (response.status !== 429 && response.status < 500)) {
          this.previousDelay = this.baseDelay; // Reset on success
          return response;
        }
        
        if (attempt < maxRetries) {
          const delay = this.calculateDelay();
          await new Promise(resolve => setTimeout(resolve, delay));
          attempt++;
        } else {
          return response;
        }
      } catch (error) {
        if (attempt < maxRetries) {
          const delay = this.calculateDelay();
          await new Promise(resolve => setTimeout(resolve, delay));
          attempt++;
        } else {
          throw error;
        }
      }
    }
  }
}
```

### Circuit Breaker Pattern

#### Request Circuit Breaker

```javascript
class CircuitBreaker {
  constructor(failureThreshold = 5, resetTimeout = 60000) {
    this.failureThreshold = failureThreshold;
    this.resetTimeout = resetTimeout;
    this.state = 'CLOSED'; // CLOSED, OPEN, HALF_OPEN
    this.failureCount = 0;
    this.nextAttempt = Date.now();
  }
  
  async fetch(url, options) {
    if (this.state === 'OPEN') {
      if (Date.now() < this.nextAttempt) {
        throw new Error('Circuit breaker is OPEN');
      }
      this.state = 'HALF_OPEN';
    }
    
    try {
      const response = await fetch(url, options);
      
      if (response.ok) {
        this.onSuccess();
      } else {
        this.onFailure();
      }
      
      return response;
    } catch (error) {
      this.onFailure();
      throw error;
    }
  }
  
  onSuccess() {
    this.failureCount = 0;
    if (this.state === 'HALF_OPEN') {
      this.state = 'CLOSED';
    }
  }
  
  onFailure() {
    this.failureCount++;
    
    if (this.failureCount >= this.failureThreshold) {
      this.state = 'OPEN';
      this.nextAttempt = Date.now() + this.resetTimeout;
    }
  }
  
  getState() {
    return this.state;
  }
}

const breaker = new CircuitBreaker(5, 30000);

async function protectedFetch(url, options) {
  try {
    return await breaker.fetch(url, options);
  } catch (error) {
    if (error.message === 'Circuit breaker is OPEN') {
      // Return cached data or fallback
      return caches.match(url);
    }
    throw error;
  }
}
```

### Batch Request Optimization

#### Request Batching

```javascript
class RequestBatcher {
  constructor(batchSize = 10, flushInterval = 100) {
    this.batchSize = batchSize;
    this.flushInterval = flushInterval;
    this.batch = [];
    this.flushTimer = null;
  }
  
  async add(request) {
    return new Promise((resolve, reject) => {
      this.batch.push({ request, resolve, reject });
      
      if (this.batch.length >= this.batchSize) {
        this.flush();
      } else if (!this.flushTimer) {
        this.flushTimer = setTimeout(() => this.flush(), this.flushInterval);
      }
    });
  }
  
  async flush() {
    if (this.flushTimer) {
      clearTimeout(this.flushTimer);
      this.flushTimer = null;
    }
    
    if (this.batch.length === 0) {
      return;
    }
    
    const currentBatch = this.batch.splice(0);
    
    // Create batch request payload
    const batchPayload = currentBatch.map(item => item.request);
    
    try {
      const response = await fetch('/api/batch', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ requests: batchPayload })
      });
      
      const results = await response.json();
      
      currentBatch.forEach((item, index) => {
        item.resolve(results[index]);
      });
    } catch (error) {
      currentBatch.forEach(item => {
        item.reject(error);
      });
    }
  }
  
  async fetch(url, options) {
    const request = { url, options };
    return this.add(request);
  }
}

const batcher = new RequestBatcher(10, 100);

// Individual requests automatically batched
const results = await Promise.all([
  batcher.fetch('/api/user/1'),
  batcher.fetch('/api/user/2'),
  batcher.fetch('/api/user/3'),
  // Sent as single batch request
]);
```

### Comprehensive Rate Limiter

#### All-in-One Solution

```javascript
class ComprehensiveRateLimiter {
  constructor(config = {}) {
    this.config = {
      maxConcurrent: config.maxConcurrent || 5,
      maxPerSecond: config.maxPerSecond || 10,
      maxPerMinute: config.maxPerMinute || 100,
      retryAttempts: config.retryAttempts || 3,
      backoffMultiplier: config.backoffMultiplier || 2,
      circuitBreakerThreshold: config.circuitBreakerThreshold || 5,
      circuitBreakerTimeout: config.circuitBreakerTimeout || 60000,
      ...config
    };
    
    this.queue = [];
    this.running = 0;
    this.perSecondLog = [];
    this.perMinuteLog = [];
    this.circuitState = 'CLOSED';
    this.failureCount = 0;
    this.nextCircuitAttempt = Date.now();
  }
  
  async fetch(url, options = {}) {
    return new Promise((resolve, reject) => {
      this.queue.push({ url, options, resolve, reject, attempts: 0 });
      this.processQueue();
    });
  }
  
  async processQueue() {
    if (this.running >= this.config.maxConcurrent || this.queue.length === 0) {
      return;
    }
    
    // Check circuit breaker
    if (this.circuitState === 'OPEN') {
      if (Date.now() < this.nextCircuitAttempt) {
        return;
      }
      this.circuitState = 'HALF_OPEN';
    }
    
    // Check rate limits
    await this.enforceRateLimits();
    
    this.running++;
    const task = this.queue.shift();
    
    try {
      const response = await this.executeWithRetry(task);
      this.onSuccess();
      task.resolve(response);
    } catch (error) {
      this.onFailure();
      task.reject(error);
    } finally {
      this.running--;
      this.processQueue();
    }
  }
  
  async enforceRateLimits() {
    const now = Date.now();
    
    // Per-second limit
    this.perSecondLog = this.perSecondLog.filter(t => t > now - 1000);
    if (this.perSecondLog.length >= this.config.maxPerSecond) {
      const oldestRequest = this.perSecondLog[0];
      const waitTime = 1000 - (now - oldestRequest);
      await new Promise(resolve => setTimeout(resolve, waitTime));
      return this.enforceRateLimits();
    }
    
    // Per-minute limit
    this.perMinuteLog = this.perMinuteLog.filter(t => t > now - 60000);
    if (this.perMinuteLog.length >= this.config.maxPerMinute) {
      const oldestRequest = this.perMinuteLog[0];
      const waitTime = 60000 - (now - oldestRequest);
      await new Promise(resolve => setTimeout(resolve, waitTime));
      return this.enforceRateLimits();
    }
    
    this.perSecondLog.push(now);
    this.perMinuteLog.push(now);
  }
  
  async executeWithRetry(task) {
    const { url, options, attempts } = task;
    
    try {
      const response = await fetch(url, options);
      
      if (response.status === 429 && attempts < this.config.retryAttempts) {
        const retryAfter = response.headers.get('Retry-After');
        const delay = retryAfter 
          ? parseInt(retryAfter) * 1000
          : this.config.backoffMultiplier ** attempts * 1000;
        
        await new Promise(resolve => setTimeout(resolve, delay));
        
        task.attempts++;
        this.queue.unshift(task);
        return this.processQueue();
      }
      
      return response;
    } catch (error) {
      if (attempts < this.config.retryAttempts) {
        const delay = this.config.backoffMultiplier ** attempts * 1000;
        await new Promise(resolve => setTimeout(resolve, delay));
        
        task.attempts++;
        this.queue.unshift(task);
        return this.processQueue();
      }
      
      throw error;
    }
  }
  
  onSuccess() {
    this.failureCount = 0;
    if (this.circuitState === 'HALF_OPEN') {
      this.circuitState = 'CLOSED';
    }
  }
  
  onFailure() {
    this.failureCount++;
    
    if (this.failureCount >= this.config.circuitBreakerThreshold) {
      this.circuitState = 'OPEN';
      this.nextCircuitAttempt = Date.now() + this.config.circuitBreakerTimeout;
    }
  }
  
  getStats() {
    return {
      queueLength: this.queue.length,
      running: this.running,
      circuitState: this.circuitState,
      failureCount: this.failureCount,
      perSecondCount: this.perSecondLog.length,
      perMinuteCount: this.perMinuteLog.length
    };
  }
}

// Usage
const limiter = new ComprehensiveRateLimiter({
  maxConcurrent: 5,
  maxPerSecond: 10,
  maxPerMinute: 100,
  retryAttempts: 3,
  backoffMultiplier: 2,
  circuitBreakerThreshold: 5,
  circuitBreakerTimeout: 60000
});

async function smartFetch(url, options) {
  return limiter.fetch(url, options);
}

// Monitor performance
setInterval(() => {
  console.log('Rate Limiter Stats:', limiter.getStats());
}, 5000);
```

### Service Worker Integration

#### Rate-Limited Service Worker

```javascript
// service-worker.js
class ServiceWorkerRateLimiter {
  constructor() {
    this.limiters = new Map();
  }
  
  getLimiter(domain) {
    if (!this.limiters.has(domain)) {
      this.limiters.set(domain, new SlidingWindowRateLimiter(100, 60000));
    }
    return this.limiters.get(domain);
  }
  
  async fetch(request) {
    const url = new URL(request.url);
    const domain = url.hostname;
    
    // Skip rate limiting for same-origin requests
    if (url.origin === self.location.origin) {
      return fetch(request);
    }
    
    const limiter = this.getLimiter(domain);
    await limiter.throttle();
    
    return fetch(request);
  }
}

const swLimiter = new ServiceWorkerRateLimiter();

self.addEventListener('fetch', (event) => {
  event.respondWith(swLimiter.fetch(event.request));
});
```

---

