## Retry Logic Implementation (Request Interceptor)


### Basic Retry Wrapper

A simple retry wrapper that attempts a fetch request multiple times on failure.

```javascript
async function fetchWithRetry(url, options = {}, retries = 3) {
  for (let attempt = 0; attempt <= retries; attempt++) {
    try {
      const response = await fetch(url, options);
      
      if (response.ok) {
        return response;
      }
      
      // Don't retry client errors (4xx), except specific cases
      if (response.status >= 400 && response.status < 500 && response.status !== 408 && response.status !== 429) {
        return response;
      }
      
      // Last attempt, return response even if failed
      if (attempt === retries) {
        return response;
      }
      
      console.log(`Attempt ${attempt + 1} failed with status ${response.status}, retrying...`);
    } catch (error) {
      // Last attempt, throw error
      if (attempt === retries) {
        throw error;
      }
      
      console.log(`Attempt ${attempt + 1} failed with error: ${error.message}, retrying...`);
    }
  }
}
```

### Exponential Backoff

Exponential backoff increases wait time between retries, reducing server load and improving success rates.

```javascript
async function fetchWithExponentialBackoff(url, options = {}, config = {}) {
  const {
    maxRetries = 3,
    baseDelay = 1000,
    maxDelay = 30000,
    factor = 2
  } = config;
  
  for (let attempt = 0; attempt <= maxRetries; attempt++) {
    try {
      const response = await fetch(url, options);
      
      if (response.ok) {
        return response;
      }
      
      // Don't retry client errors except 408, 429
      if (response.status >= 400 && response.status < 500 && 
          response.status !== 408 && response.status !== 429) {
        return response;
      }
      
      if (attempt === maxRetries) {
        return response;
      }
      
      // Calculate delay with exponential backoff
      const delay = Math.min(baseDelay * Math.pow(factor, attempt), maxDelay);
      console.log(`Retry ${attempt + 1} after ${delay}ms`);
      
      await new Promise(resolve => setTimeout(resolve, delay));
      
    } catch (error) {
      if (attempt === maxRetries) {
        throw error;
      }
      
      const delay = Math.min(baseDelay * Math.pow(factor, attempt), maxDelay);
      console.log(`Network error, retry ${attempt + 1} after ${delay}ms`);
      
      await new Promise(resolve => setTimeout(resolve, delay));
    }
  }
}
```

### Exponential Backoff with Jitter

Adding jitter (randomization) to delays prevents thundering herd problems when multiple clients retry simultaneously.

```javascript
async function fetchWithJitter(url, options = {}, config = {}) {
  const {
    maxRetries = 3,
    baseDelay = 1000,
    maxDelay = 30000,
    factor = 2,
    jitterType = 'full' // 'full', 'equal', 'decorrelated'
  } = config;
  
  let previousDelay = baseDelay;
  
  for (let attempt = 0; attempt <= maxRetries; attempt++) {
    try {
      const response = await fetch(url, options);
      
      if (response.ok) {
        return response;
      }
      
      if (shouldNotRetry(response.status) || attempt === maxRetries) {
        return response;
      }
      
      const delay = calculateDelay(attempt, baseDelay, maxDelay, factor, jitterType, previousDelay);
      previousDelay = delay;
      
      console.log(`Retry ${attempt + 1} after ${delay}ms`);
      await new Promise(resolve => setTimeout(resolve, delay));
      
    } catch (error) {
      if (attempt === maxRetries) {
        throw error;
      }
      
      const delay = calculateDelay(attempt, baseDelay, maxDelay, factor, jitterType, previousDelay);
      previousDelay = delay;
      
      await new Promise(resolve => setTimeout(resolve, delay));
    }
  }
}

function calculateDelay(attempt, baseDelay, maxDelay, factor, jitterType, previousDelay) {
  const exponentialDelay = baseDelay * Math.pow(factor, attempt);
  
  switch (jitterType) {
    case 'full':
      // Random delay between 0 and exponential delay
      return Math.min(Math.random() * exponentialDelay, maxDelay);
      
    case 'equal':
      // Half exponential delay plus random half
      const halfDelay = exponentialDelay / 2;
      return Math.min(halfDelay + Math.random() * halfDelay, maxDelay);
      
    case 'decorrelated':
      // Random between baseDelay and 3x previous delay
      const decorrelated = baseDelay + Math.random() * (previousDelay * 3 - baseDelay);
      return Math.min(decorrelated, maxDelay);
      
    default:
      return Math.min(exponentialDelay, maxDelay);
  }
}

function shouldNotRetry(status) {
  // Don't retry client errors except specific cases
  return status >= 400 && status < 500 && status !== 408 && status !== 429;
}
```

### Retry with Status Code Filtering

Different status codes require different retry strategies.

```javascript
async function fetchWithStatusHandling(url, options = {}, config = {}) {
  const {
    maxRetries = 3,
    baseDelay = 1000,
    retryableStatusCodes = [408, 429, 500, 502, 503, 504],
    retryableErrors = ['NetworkError', 'TypeError']
  } = config;
  
  for (let attempt = 0; attempt <= maxRetries; attempt++) {
    try {
      const response = await fetch(url, options);
      
      if (response.ok) {
        return response;
      }
      
      // Check if status code is retryable
      if (!retryableStatusCodes.includes(response.status)) {
        return response;
      }
      
      if (attempt === maxRetries) {
        return response;
      }
      
      const delay = baseDelay * Math.pow(2, attempt);
      console.log(`Status ${response.status} is retryable, waiting ${delay}ms`);
      
      await new Promise(resolve => setTimeout(resolve, delay));
      
    } catch (error) {
      // Check if error type is retryable
      const isRetryableError = retryableErrors.some(type => 
        error.name === type || error.constructor.name === type
      );
      
      if (!isRetryableError || attempt === maxRetries) {
        throw error;
      }
      
      const delay = baseDelay * Math.pow(2, attempt);
      await new Promise(resolve => setTimeout(resolve, delay));
    }
  }
}
```

### Retry-After Header Support

Respect the `Retry-After` header when servers indicate when to retry.

```javascript
async function fetchWithRetryAfter(url, options = {}, maxRetries = 3) {
  for (let attempt = 0; attempt <= maxRetries; attempt++) {
    try {
      const response = await fetch(url, options);
      
      if (response.ok) {
        return response;
      }
      
      if (attempt === maxRetries) {
        return response;
      }
      
      // Check for Retry-After header
      if (response.status === 429 || response.status === 503) {
        const retryAfter = response.headers.get('Retry-After');
        
        if (retryAfter) {
          let delay;
          
          // Retry-After can be seconds or HTTP date
          if (/^\d+$/.test(retryAfter)) {
            // Seconds
            delay = parseInt(retryAfter, 10) * 1000;
          } else {
            // HTTP date
            const retryDate = new Date(retryAfter);
            delay = retryDate.getTime() - Date.now();
          }
          
          // Cap delay at 60 seconds for safety
          delay = Math.min(Math.max(delay, 0), 60000);
          
          console.log(`Server requested retry after ${delay}ms`);
          await new Promise(resolve => setTimeout(resolve, delay));
          continue;
        }
      }
      
      // Fallback to exponential backoff
      const delay = 1000 * Math.pow(2, attempt);
      await new Promise(resolve => setTimeout(resolve, delay));
      
    } catch (error) {
      if (attempt === maxRetries) {
        throw error;
      }
      
      const delay = 1000 * Math.pow(2, attempt);
      await new Promise(resolve => setTimeout(resolve, delay));
    }
  }
}
```

### Request Interceptor Class

A comprehensive request interceptor that wraps fetch with retry logic and hooks.

```javascript
class FetchInterceptor {
  constructor(config = {}) {
    this.config = {
      maxRetries: 3,
      baseDelay: 1000,
      maxDelay: 30000,
      factor: 2,
      retryableStatusCodes: [408, 429, 500, 502, 503, 504],
      retryableErrors: ['NetworkError', 'TypeError'],
      ...config
    };
    
    this.beforeRequestHooks = [];
    this.afterResponseHooks = [];
    this.onRetryHooks = [];
    this.onErrorHooks = [];
  }
  
  beforeRequest(hook) {
    this.beforeRequestHooks.push(hook);
    return this;
  }
  
  afterResponse(hook) {
    this.afterResponseHooks.push(hook);
    return this;
  }
  
  onRetry(hook) {
    this.onRetryHooks.push(hook);
    return this;
  }
  
  onError(hook) {
    this.onErrorHooks.push(hook);
    return this;
  }
  
  async fetch(url, options = {}) {
    // Execute before request hooks
    let modifiedOptions = { ...options };
    
    for (const hook of this.beforeRequestHooks) {
      modifiedOptions = await hook(url, modifiedOptions) || modifiedOptions;
    }
    
    // Perform request with retry logic
    return await this._fetchWithRetry(url, modifiedOptions);
  }
  
  async _fetchWithRetry(url, options) {
    const { maxRetries, baseDelay, maxDelay, factor, retryableStatusCodes, retryableErrors } = this.config;
    
    for (let attempt = 0; attempt <= maxRetries; attempt++) {
      try {
        const response = await fetch(url, options);
        
        // Execute after response hooks
        for (const hook of this.afterResponseHooks) {
          await hook(response.clone(), attempt);
        }
        
        if (response.ok) {
          return response;
        }
        
        // Check if should retry
        if (!retryableStatusCodes.includes(response.status) || attempt === maxRetries) {
          return response;
        }
        
        // Calculate delay
        const delay = this._calculateDelay(attempt, response);
        
        // Execute retry hooks
        for (const hook of this.onRetryHooks) {
          await hook(attempt + 1, delay, response.status);
        }
        
        console.log(`Retrying request (${attempt + 1}/${maxRetries}) after ${delay}ms`);
        await new Promise(resolve => setTimeout(resolve, delay));
        
      } catch (error) {
        // Execute error hooks
        for (const hook of this.onErrorHooks) {
          await hook(error, attempt);
        }
        
        const isRetryableError = retryableErrors.some(type => 
          error.name === type || error.constructor.name === type
        );
        
        if (!isRetryableError || attempt === maxRetries) {
          throw error;
        }
        
        const delay = Math.min(baseDelay * Math.pow(factor, attempt), maxDelay);
        
        for (const hook of this.onRetryHooks) {
          await hook(attempt + 1, delay, error.message);
        }
        
        await new Promise(resolve => setTimeout(resolve, delay));
      }
    }
  }
  
  _calculateDelay(attempt, response) {
    const { baseDelay, maxDelay, factor } = this.config;
    
    // Check for Retry-After header
    if (response && (response.status === 429 || response.status === 503)) {
      const retryAfter = response.headers.get('Retry-After');
      
      if (retryAfter) {
        if (/^\d+$/.test(retryAfter)) {
          return Math.min(parseInt(retryAfter, 10) * 1000, maxDelay);
        } else {
          const retryDate = new Date(retryAfter);
          return Math.min(Math.max(retryDate.getTime() - Date.now(), 0), maxDelay);
        }
      }
    }
    
    // Exponential backoff with jitter
    const exponentialDelay = baseDelay * Math.pow(factor, attempt);
    const jitter = Math.random() * exponentialDelay;
    
    return Math.min(jitter, maxDelay);
  }
}

// Usage
const interceptor = new FetchInterceptor({
  maxRetries: 5,
  baseDelay: 1000,
  retryableStatusCodes: [408, 429, 500, 502, 503, 504]
});

interceptor.beforeRequest((url, options) => {
  console.log('Making request to:', url);
  options.headers = {
    ...options.headers,
    'X-Request-ID': crypto.randomUUID()
  };
  return options;
});

interceptor.afterResponse((response, attempt) => {
  console.log('Response received:', response.status, 'on attempt', attempt + 1);
});

interceptor.onRetry((attempt, delay, statusOrError) => {
  console.log(`Retry attempt ${attempt} after ${delay}ms due to: ${statusOrError}`);
});

interceptor.onError((error, attempt) => {
  console.error(`Error on attempt ${attempt + 1}:`, error.message);
});

const response = await interceptor.fetch('/api/data', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({ data: 'example' })
});
```

### Idempotency Key Support

For non-idempotent operations, use idempotency keys to safely retry without duplicate side effects.

```javascript
class IdempotentFetchInterceptor {
  constructor(config = {}) {
    this.config = {
      maxRetries: 3,
      baseDelay: 1000,
      idempotencyHeader: 'Idempotency-Key',
      ...config
    };
  }
  
  async fetch(url, options = {}) {
    const method = (options.method || 'GET').toUpperCase();
    const needsIdempotency = ['POST', 'PUT', 'PATCH', 'DELETE'].includes(method);
    
    // Generate idempotency key for non-idempotent operations
    if (needsIdempotency) {
      const idempotencyKey = this._generateIdempotencyKey(url, options);
      
      options.headers = {
        ...options.headers,
        [this.config.idempotencyHeader]: idempotencyKey
      };
    }
    
    return await this._retryFetch(url, options);
  }
  
  _generateIdempotencyKey(url, options) {
    // Generate unique key based on request details
    const key = `${url}-${options.method}-${Date.now()}-${Math.random()}`;
    
    // Use crypto API if available
    if (typeof crypto !== 'undefined' && crypto.randomUUID) {
      return crypto.randomUUID();
    }
    
    // Fallback to simple hash
    return btoa(key).substring(0, 32);
  }
  
  async _retryFetch(url, options) {
    const { maxRetries, baseDelay } = this.config;
    
    for (let attempt = 0; attempt <= maxRetries; attempt++) {
      try {
        const response = await fetch(url, options);
        
        if (response.ok) {
          return response;
        }
        
        // Don't retry if server says request was processed
        if (response.status === 409) {
          // Conflict - idempotency key indicates duplicate
          return response;
        }
        
        if (attempt === maxRetries) {
          return response;
        }
        
        const delay = baseDelay * Math.pow(2, attempt);
        await new Promise(resolve => setTimeout(resolve, delay));
        
      } catch (error) {
        if (attempt === maxRetries) {
          throw error;
        }
        
        const delay = baseDelay * Math.pow(2, attempt);
        await new Promise(resolve => setTimeout(resolve, delay));
      }
    }
  }
}
```

### Timeout with Retry

Combining timeout logic with retry attempts using AbortController.

```javascript
async function fetchWithTimeoutAndRetry(url, options = {}, config = {}) {
  const {
    maxRetries = 3,
    timeout = 5000,
    baseDelay = 1000
  } = config;
  
  for (let attempt = 0; attempt <= maxRetries; attempt++) {
    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), timeout);
    
    try {
      const response = await fetch(url, {
        ...options,
        signal: controller.signal
      });
      
      clearTimeout(timeoutId);
      
      if (response.ok) {
        return response;
      }
      
      if (attempt === maxRetries) {
        return response;
      }
      
      const delay = baseDelay * Math.pow(2, attempt);
      await new Promise(resolve => setTimeout(resolve, delay));
      
    } catch (error) {
      clearTimeout(timeoutId);
      
      if (error.name === 'AbortError') {
        console.log(`Request timeout on attempt ${attempt + 1}`);
      }
      
      if (attempt === maxRetries) {
        throw error;
      }
      
      const delay = baseDelay * Math.pow(2, attempt);
      await new Promise(resolve => setTimeout(resolve, delay));
    }
  }
}
```

### Circuit Breaker Pattern

Prevent overwhelming failing services by opening the circuit after consecutive failures.

```javascript
class CircuitBreaker {
  constructor(config = {}) {
    this.config = {
      failureThreshold: 5,
      resetTimeout: 60000,
      monitoringPeriod: 10000,
      ...config
    };
    
    this.state = 'CLOSED'; // CLOSED, OPEN, HALF_OPEN
    this.failureCount = 0;
    this.lastFailureTime = null;
    this.successCount = 0;
  }
  
  async fetch(url, options = {}, retryConfig = {}) {
    // Check circuit state
    if (this.state === 'OPEN') {
      if (Date.now() - this.lastFailureTime >= this.config.resetTimeout) {
        console.log('Circuit transitioning to HALF_OPEN');
        this.state = 'HALF_OPEN';
        this.successCount = 0;
      } else {
        throw new Error('Circuit breaker is OPEN - request blocked');
      }
    }
    
    try {
      const response = await this._fetchWithRetry(url, options, retryConfig);
      
      if (response.ok) {
        this._recordSuccess();
        return response;
      }
      
      // Server errors count as failures
      if (response.status >= 500) {
        this._recordFailure();
      }
      
      return response;
      
    } catch (error) {
      this._recordFailure();
      throw error;
    }
  }
  
  async _fetchWithRetry(url, options, config) {
    const { maxRetries = 3, baseDelay = 1000 } = config;
    
    for (let attempt = 0; attempt <= maxRetries; attempt++) {
      try {
        const response = await fetch(url, options);
        
        if (response.ok || response.status < 500) {
          return response;
        }
        
        if (attempt === maxRetries) {
          return response;
        }
        
        const delay = baseDelay * Math.pow(2, attempt);
        await new Promise(resolve => setTimeout(resolve, delay));
        
      } catch (error) {
        if (attempt === maxRetries) {
          throw error;
        }
        
        const delay = baseDelay * Math.pow(2, attempt);
        await new Promise(resolve => setTimeout(resolve, delay));
      }
    }
  }
  
  _recordSuccess() {
    this.failureCount = 0;
    
    if (this.state === 'HALF_OPEN') {
      this.successCount++;
      
      // After some successes in HALF_OPEN, close circuit
      if (this.successCount >= 2) {
        console.log('Circuit closing after successful requests');
        this.state = 'CLOSED';
        this.successCount = 0;
      }
    }
  }
  
  _recordFailure() {
    this.failureCount++;
    this.lastFailureTime = Date.now();
    
    if (this.failureCount >= this.config.failureThreshold) {
      console.log('Circuit opening due to consecutive failures');
      this.state = 'OPEN';
    }
  }
  
  reset() {
    this.state = 'CLOSED';
    this.failureCount = 0;
    this.lastFailureTime = null;
    this.successCount = 0;
  }
  
  getState() {
    return {
      state: this.state,
      failureCount: this.failureCount,
      lastFailureTime: this.lastFailureTime
    };
  }
}

// Usage
const breaker = new CircuitBreaker({
  failureThreshold: 3,
  resetTimeout: 30000
});

try {
  const response = await breaker.fetch('/api/unstable-endpoint', {
    method: 'GET'
  }, {
    maxRetries: 2,
    baseDelay: 500
  });
  
  const data = await response.json();
  console.log(data);
} catch (error) {
  console.error('Request failed:', error.message);
  console.log('Circuit state:', breaker.getState());
}
```

### Request Queue with Retry

Queue requests with retry logic to prevent overwhelming the client or server.

```javascript
class RequestQueue {
  constructor(config = {}) {
    this.config = {
      concurrency: 3,
      maxRetries: 3,
      baseDelay: 1000,
      ...config
    };
    
    this.queue = [];
    this.active = 0;
  }
  
  async fetch(url, options = {}) {
    return new Promise((resolve, reject) => {
      this.queue.push({ url, options, resolve, reject });
      this._process();
    });
  }
  
  async _process() {
    if (this.active >= this.config.concurrency || this.queue.length === 0) {
      return;
    }
    
    this.active++;
    const { url, options, resolve, reject } = this.queue.shift();
    
    try {
      const response = await this._fetchWithRetry(url, options);
      resolve(response);
    } catch (error) {
      reject(error);
    } finally {
      this.active--;
      this._process();
    }
  }
  
  async _fetchWithRetry(url, options) {
    const { maxRetries, baseDelay } = this.config;
    
    for (let attempt = 0; attempt <= maxRetries; attempt++) {
      try {
        const response = await fetch(url, options);
        
        if (response.ok || response.status < 500) {
          return response;
        }
        
        if (attempt === maxRetries) {
          return response;
        }
        
        const delay = baseDelay * Math.pow(2, attempt);
        await new Promise(resolve => setTimeout(resolve, delay));
        
      } catch (error) {
        if (attempt === maxRetries) {
          throw error;
        }
        
        const delay = baseDelay * Math.pow(2, attempt);
        await new Promise(resolve => setTimeout(resolve, delay));
      }
    }
  }
  
  getStats() {
    return {
      queued: this.queue.length,
      active: this.active
    };
  }
}

// Usage
const queue = new RequestQueue({ concurrency: 2, maxRetries: 3 });

const urls = ['/api/data1', '/api/data2', '/api/data3', '/api/data4'];

const promises = urls.map(url => queue.fetch(url));

const results = await Promise.allSettled(promises);
results.forEach((result, index) => {
  if (result.status === 'fulfilled') {
    console.log(`Request ${index + 1} succeeded`);
  } else {
    console.error(`Request ${index + 1} failed:`, result.reason);
  }
});
```

### Adaptive Retry Strategy

Adjust retry behavior based on response patterns and success rates.

```javascript
class AdaptiveRetryInterceptor {
  constructor(config = {}) {
    this.config = {
      initialMaxRetries: 3,
      minRetries: 1,
      maxRetries: 10,
      baseDelay: 1000,
      successThreshold: 0.8,
      evaluationWindow: 100,
      ...config
    };
    
    this.maxRetries = this.config.initialMaxRetries;
    this.requestHistory = [];
  }
  
  async fetch(url, options = {}) {
    const startTime = Date.now();
    
    try {
      const response = await this._fetchWithRetry(url, options);
      
      this._recordRequest(true, Date.now() - startTime);
      this._adjustStrategy();
      
      return response;
      
    } catch (error) {
      this._recordRequest(false, Date.now() - startTime);
      this._adjustStrategy();
      
      throw error;
    }
  }
  
  async _fetchWithRetry(url, options) {
    const { baseDelay } = this.config;
    
    for (let attempt = 0; attempt <= this.maxRetries; attempt++) {
      try {
        const response = await fetch(url, options);
        
        if (response.ok) {
          return response;
        }
        
        if (response.status < 500 || attempt === this.maxRetries) {
          return response;
        }
        
        const delay = baseDelay * Math.pow(2, attempt);
        await new Promise(resolve => setTimeout(resolve, delay));
        
      } catch (error) {
        if (attempt === this.maxRetries) {
          throw error;
        }
        
        const delay = baseDelay * Math.pow(2, attempt);
        await new Promise(resolve => setTimeout(resolve, delay));
      }
    }
  }
  
  _recordRequest(success, duration) {
    this.requestHistory.push({ success, duration, timestamp: Date.now() });
    
    // Keep only recent history
    if (this.requestHistory.length > this.config.evaluationWindow) {
      this.requestHistory.shift();
    }
  }
  
  _adjustStrategy() {
    if (this.requestHistory.length < 20) {
      return; // Not enough data
    }
    
    const recentRequests = this.requestHistory.slice(-20);
    const successRate = recentRequests.filter(r => r.success).length / recentRequests.length;
    
    if (successRate >= this.config.successThreshold) {
      // High success rate - reduce retries
      this.maxRetries = Math.max(this.maxRetries - 1, this.config.minRetries);
      console.log(`Success rate high (${(successRate * 100).toFixed(1)}%), reducing retries to ${this.maxRetries}`);
    } else if (successRate < 0.5) {
      // Low success rate - increase retries
      this.maxRetries = Math.min(this.maxRetries + 1, this.config.maxRetries);
      console.log(`Success rate low (${(successRate * 100).toFixed(1)}%), increasing retries to ${this.maxRetries}`);
    }
  }
  
  getStats() {
    if (this.requestHistory.length === 0) {
      return { successRate: 0, averageDuration: 0, currentMaxRetries: this.maxRetries };
    }
    
    const successful = this.requestHistory.filter(r => r.success).length;
    const successRate = successful / this.requestHistory.length;
    const averageDuration = this.requestHistory.reduce((sum, r) => sum + r.duration, 0) / this.requestHistory.length;
    
    return {
      successRate: (successRate * 100).toFixed(2) + '%',
      averageDuration: Math.round(averageDuration) + 'ms',
      currentMaxRetries: this.maxRetries,
      totalRequests: this.requestHistory.length
    };
  }
}
```

### Retry with Request Deduplication

Prevent duplicate requests by deduplicating identical pending requests.

```javascript
class DeduplicatingInterceptor {
  constructor(config = {}) {
    this.config = {
      maxRetries: 3,
      baseDelay: 1000,
      ...config
    };

    this.pendingRequests = new Map();
  }

  async fetch(url, options = {}) {
    const requestKey = this._getRequestKey(url, options);

    // Check if identical request is pending
    if (this.pendingRequests.has(requestKey)) {
      console.log('Deduplicating request to:', url);
      return this.pendingRequests.get(requestKey);
    }

    // Create new request promise
    const requestPromise = this._fetchWithRetry(url, options)
      .finally(() => {
        // Clean up after request completes
        this.pendingRequests.delete(requestKey);
      });

    this.pendingRequests.set(requestKey, requestPromise);

    return requestPromise;
  }

  _getRequestKey(url, options) {
    const method = options.method || 'GET';
    const body = options.body || '';

    return `${method}:${url}:${body}`;
  }

  async _fetchWithRetry(url, options) {
    const { maxRetries, baseDelay } = this.config;

    for (let attempt = 0; attempt <= maxRetries; attempt++) {
      try {
        const response = await fetch(url, options);

        if (response.ok || response.status < 500) {
          return response;
        }

        if (attempt === maxRetries) {
          return response;
        }

        const delay = baseDelay * Math.pow(2, attempt);
        await new Promise(resolve => setTimeout(resolve, delay));

      } catch (error) {
        if (attempt === maxRetries) {
          throw error;
        }

        const delay = baseDelay * Math.pow(2, attempt);
        await new Promise(resolve => setTimeout(resolve, delay));
      }
    }
  }

  clearPending() {
    this.pendingRequests.clear();
  }
}
````

### Retry with Metrics Collection

Track detailed metrics about retry behavior for monitoring and optimization.

```javascript
class MetricsCollectingInterceptor {
  constructor(config = {}) {
    this.config = {
      maxRetries: 3,
      baseDelay: 1000,
      ...config
    };
    
    this.metrics = {
      totalRequests: 0,
      successfulRequests: 0,
      failedRequests: 0,
      retriedRequests: 0,
      totalRetries: 0,
      statusCodes: {},
      errors: {},
      latencies: []
    };
  }
  
  async fetch(url, options = {}) {
    const startTime = Date.now();
    this.metrics.totalRequests++;
    
    let retryCount = 0;
    
    try {
      const response = await this._fetchWithRetry(url, options, (attempt) => {
        retryCount = attempt;
        this.metrics.totalRetries++;
      });
      
      const latency = Date.now() - startTime;
      this.metrics.latencies.push(latency);
      
      if (retryCount > 0) {
        this.metrics.retriedRequests++;
      }
      
      if (response.ok) {
        this.metrics.successfulRequests++;
      } else {
        this.metrics.failedRequests++;
      }
      
      // Track status codes
      const status = response.status;
      this.metrics.statusCodes[status] = (this.metrics.statusCodes[status] || 0) + 1;
      
      return response;
      
    } catch (error) {
      this.metrics.failedRequests++;
      
      if (retryCount > 0) {
        this.metrics.retriedRequests++;
      }
      
      // Track errors
      const errorType = error.name || 'Unknown';
      this.metrics.errors[errorType] = (this.metrics.errors[errorType] || 0) + 1;
      
      throw error;
    }
  }
  
  async _fetchWithRetry(url, options, onRetry) {
    const { maxRetries, baseDelay } = this.config;
    
    for (let attempt = 0; attempt <= maxRetries; attempt++) {
      try {
        const response = await fetch(url, options);
        
        if (response.ok || response.status < 500) {
          return response;
        }
        
        if (attempt === maxRetries) {
          return response;
        }
        
        onRetry(attempt + 1);
        
        const delay = baseDelay * Math.pow(2, attempt);
        await new Promise(resolve => setTimeout(resolve, delay));
        
      } catch (error) {
        if (attempt === maxRetries) {
          throw error;
        }
        
        onRetry(attempt + 1);
        
        const delay = baseDelay * Math.pow(2, attempt);
        await new Promise(resolve => setTimeout(resolve, delay));
      }
    }
  }
  
  getMetrics() {
    const avgLatency = this.metrics.latencies.length > 0
      ? this.metrics.latencies.reduce((a, b) => a + b, 0) / this.metrics.latencies.length
      : 0;
    
    const successRate = this.metrics.totalRequests > 0
      ? (this.metrics.successfulRequests / this.metrics.totalRequests) * 100
      : 0;
    
    return {
      totalRequests: this.metrics.totalRequests,
      successfulRequests: this.metrics.successfulRequests,
      failedRequests: this.metrics.failedRequests,
      successRate: successRate.toFixed(2) + '%',
      retriedRequests: this.metrics.retriedRequests,
      totalRetries: this.metrics.totalRetries,
      averageLatency: Math.round(avgLatency) + 'ms',
      statusCodes: this.metrics.statusCodes,
      errors: this.metrics.errors
    };
  }
  
  resetMetrics() {
    this.metrics = {
      totalRequests: 0,
      successfulRequests: 0,
      failedRequests: 0,
      retriedRequests: 0,
      totalRetries: 0,
      statusCodes: {},
      errors: {},
      latencies: []
    };
  }
}
````

---

