## Timeout Implementation for Fetch API


### Native AbortController Approach

The `AbortController` interface provides the standard mechanism for implementing timeouts with fetch requests. This approach integrates directly with the fetch API's abort signal system.

```javascript
const controller = new AbortController();
const timeoutId = setTimeout(() => controller.abort(), 5000);

try {
  const response = await fetch('https://api.example.com/data', {
    signal: controller.signal
  });
  clearTimeout(timeoutId);
  const data = await response.json();
} catch (error) {
  if (error.name === 'AbortError') {
    console.error('Request timed out');
  }
  throw error;
}
```

### Timeout Wrapper Function

Encapsulating timeout logic in a reusable wrapper function improves code organization and maintainability.

```javascript
function fetchWithTimeout(url, options = {}, timeout = 5000) {
  const controller = new AbortController();
  const timeoutId = setTimeout(() => controller.abort(), timeout);
  
  return fetch(url, {
    ...options,
    signal: controller.signal
  }).finally(() => clearTimeout(timeoutId));
}

// Usage
const response = await fetchWithTimeout('https://api.example.com/data', {}, 8000);
```

### Promise.race Pattern

Using `Promise.race` allows explicit timeout promise construction, providing more control over timeout behavior and error messages.

```javascript
function createTimeout(ms) {
  return new Promise((_, reject) => {
    setTimeout(() => reject(new Error(`Request timeout after ${ms}ms`)), ms);
  });
}

try {
  const response = await Promise.race([
    fetch('https://api.example.com/data'),
    createTimeout(5000)
  ]);
} catch (error) {
  console.error(error.message);
}
```

### Combining AbortController with Promise.race

This pattern provides both proper request cancellation and custom timeout errors.

```javascript
async function fetchWithTimeout(url, options = {}, timeout = 5000) {
  const controller = new AbortController();
  
  const timeoutPromise = new Promise((_, reject) => {
    setTimeout(() => {
      controller.abort();
      reject(new Error(`Timeout: Request exceeded ${timeout}ms`));
    }, timeout);
  });
  
  try {
    return await Promise.race([
      fetch(url, { ...options, signal: controller.signal }),
      timeoutPromise
    ]);
  } catch (error) {
    if (error.name === 'AbortError') {
      throw new Error(`Request aborted due to timeout (${timeout}ms)`);
    }
    throw error;
  }
}
```

### Timeout with Retry Logic

Implementing retry mechanisms with timeouts handles transient network issues gracefully.

```javascript
async function fetchWithRetry(url, options = {}, timeout = 5000, maxRetries = 3) {
  let lastError;
  
  for (let attempt = 0; attempt < maxRetries; attempt++) {
    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), timeout);
    
    try {
      const response = await fetch(url, {
        ...options,
        signal: controller.signal
      });
      clearTimeout(timeoutId);
      return response;
    } catch (error) {
      clearTimeout(timeoutId);
      lastError = error;
      
      if (error.name === 'AbortError') {
        console.warn(`Attempt ${attempt + 1} timed out`);
      }
      
      if (attempt < maxRetries - 1) {
        await new Promise(resolve => setTimeout(resolve, 1000 * (attempt + 1)));
      }
    }
  }
  
  throw lastError;
}
```

### Separate Read/Connection Timeouts

Distinguishing between connection establishment and data transfer timeouts provides finer control over network operations.

```javascript
async function fetchWithDualTimeout(url, options = {}, connectTimeout = 5000, readTimeout = 30000) {
  const connectController = new AbortController();
  const readController = new AbortController();
  
  const connectTimeoutId = setTimeout(() => connectController.abort(), connectTimeout);
  
  try {
    const response = await fetch(url, {
      ...options,
      signal: connectController.signal
    });
    
    clearTimeout(connectTimeoutId);
    
    const readTimeoutId = setTimeout(() => readController.abort(), readTimeout);
    
    const reader = response.body.getReader();
    const chunks = [];
    
    try {
      while (true) {
        const { done, value } = await reader.read();
        if (done) break;
        chunks.push(value);
        
        if (readController.signal.aborted) {
          throw new Error('Read timeout exceeded');
        }
      }
      clearTimeout(readTimeoutId);
      
      const blob = new Blob(chunks);
      return new Response(blob, {
        status: response.status,
        statusText: response.statusText,
        headers: response.headers
      });
    } catch (error) {
      clearTimeout(readTimeoutId);
      throw error;
    }
  } catch (error) {
    clearTimeout(connectTimeoutId);
    if (error.name === 'AbortError') {
      throw new Error('Connection timeout exceeded');
    }
    throw error;
  }
}
```

### Timeout Class Implementation

Object-oriented approach for managing complex timeout scenarios with multiple requests.

```javascript
class FetchTimeout {
  constructor(defaultTimeout = 5000) {
    this.defaultTimeout = defaultTimeout;
    this.activeRequests = new Map();
  }
  
  async fetch(url, options = {}, timeout = this.defaultTimeout) {
    const controller = new AbortController();
    const requestId = Symbol();
    
    const timeoutId = setTimeout(() => {
      controller.abort();
      this.activeRequests.delete(requestId);
    }, timeout);
    
    this.activeRequests.set(requestId, { controller, timeoutId, url });
    
    try {
      const response = await fetch(url, {
        ...options,
        signal: controller.signal
      });
      
      clearTimeout(timeoutId);
      this.activeRequests.delete(requestId);
      
      return response;
    } catch (error) {
      clearTimeout(timeoutId);
      this.activeRequests.delete(requestId);
      throw error;
    }
  }
  
  abortAll() {
    for (const [requestId, { controller, timeoutId }] of this.activeRequests) {
      controller.abort();
      clearTimeout(timeoutId);
    }
    this.activeRequests.clear();
  }
  
  getActiveCount() {
    return this.activeRequests.size;
  }
}

// Usage
const fetcher = new FetchTimeout(8000);
const response = await fetcher.fetch('https://api.example.com/data');
```

### Progressive Timeout Strategy

Implementing increasing timeouts for retry attempts accommodates varying network conditions.

```javascript
async function fetchWithProgressiveTimeout(url, options = {}, baseTimeout = 3000, maxAttempts = 3) {
  for (let attempt = 0; attempt < maxAttempts; attempt++) {
    const timeout = baseTimeout * Math.pow(2, attempt);
    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), timeout);
    
    try {
      const response = await fetch(url, {
        ...options,
        signal: controller.signal
      });
      clearTimeout(timeoutId);
      return response;
    } catch (error) {
      clearTimeout(timeoutId);
      
      if (error.name === 'AbortError' && attempt < maxAttempts - 1) {
        console.warn(`Timeout at ${timeout}ms, retrying with longer timeout`);
        continue;
      }
      throw error;
    }
  }
}
```

### Timeout with Progress Tracking

For large file downloads or uploads, tracking progress while maintaining timeout enforcement.

```javascript
async function fetchWithTimeoutAndProgress(url, options = {}, timeout = 30000, onProgress) {
  const controller = new AbortController();
  let lastActivity = Date.now();
  
  const activityCheck = setInterval(() => {
    if (Date.now() - lastActivity > timeout) {
      controller.abort();
      clearInterval(activityCheck);
    }
  }, 1000);
  
  try {
    const response = await fetch(url, {
      ...options,
      signal: controller.signal
    });
    
    const contentLength = response.headers.get('content-length');
    const total = parseInt(contentLength, 10);
    let loaded = 0;
    
    const reader = response.body.getReader();
    const chunks = [];
    
    while (true) {
      const { done, value } = await reader.read();
      
      if (done) break;
      
      chunks.push(value);
      loaded += value.length;
      lastActivity = Date.now();
      
      if (onProgress) {
        onProgress({ loaded, total });
      }
    }
    
    clearInterval(activityCheck);
    
    const blob = new Blob(chunks);
    return new Response(blob, {
      status: response.status,
      statusText: response.statusText,
      headers: response.headers
    });
  } catch (error) {
    clearInterval(activityCheck);
    throw error;
  }
}
```

### Idle Timeout vs Absolute Timeout

Differentiating between inactivity timeout and maximum duration timeout.

```javascript
async function fetchWithIdleTimeout(url, options = {}, idleTimeout = 5000, absoluteTimeout = 60000) {
  const controller = new AbortController();
  let idleTimeoutId;
  let absoluteTimeoutId;
  
  const resetIdleTimeout = () => {
    clearTimeout(idleTimeoutId);
    idleTimeoutId = setTimeout(() => controller.abort(), idleTimeout);
  };
  
  absoluteTimeoutId = setTimeout(() => controller.abort(), absoluteTimeout);
  resetIdleTimeout();
  
  try {
    const response = await fetch(url, {
      ...options,
      signal: controller.signal
    });
    
    resetIdleTimeout();
    
    const reader = response.body.getReader();
    const chunks = [];
    
    while (true) {
      const { done, value } = await reader.read();
      if (done) break;
      
      chunks.push(value);
      resetIdleTimeout();
    }
    
    clearTimeout(idleTimeoutId);
    clearTimeout(absoluteTimeoutId);
    
    const blob = new Blob(chunks);
    return new Response(blob, {
      status: response.status,
      statusText: response.statusText,
      headers: response.headers
    });
  } catch (error) {
    clearTimeout(idleTimeoutId);
    clearTimeout(absoluteTimeoutId);
    throw error;
  }
}
```

### Custom TimeoutError Class

Creating specific error types improves error handling and debugging.

```javascript
class TimeoutError extends Error {
  constructor(message, duration, url) {
    super(message);
    this.name = 'TimeoutError';
    this.duration = duration;
    this.url = url;
    this.timestamp = new Date();
  }
}

async function fetchWithCustomError(url, options = {}, timeout = 5000) {
  const controller = new AbortController();
  const timeoutId = setTimeout(() => controller.abort(), timeout);
  
  try {
    const response = await fetch(url, {
      ...options,
      signal: controller.signal
    });
    clearTimeout(timeoutId);
    return response;
  } catch (error) {
    clearTimeout(timeoutId);
    if (error.name === 'AbortError') {
      throw new TimeoutError(
        `Request to ${url} exceeded timeout of ${timeout}ms`,
        timeout,
        url
      );
    }
    throw error;
  }
}
```

### Timeout with Request Queuing

Managing multiple requests with individual timeouts while respecting concurrency limits.

```javascript
class TimeoutQueue {
  constructor(concurrency = 5, defaultTimeout = 5000) {
    this.concurrency = concurrency;
    this.defaultTimeout = defaultTimeout;
    this.queue = [];
    this.active = 0;
  }
  
  async fetch(url, options = {}, timeout = this.defaultTimeout) {
    return new Promise((resolve, reject) => {
      this.queue.push({ url, options, timeout, resolve, reject });
      this.processQueue();
    });
  }
  
  async processQueue() {
    if (this.active >= this.concurrency || this.queue.length === 0) {
      return;
    }
    
    this.active++;
    const { url, options, timeout, resolve, reject } = this.queue.shift();
    
    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), timeout);
    
    try {
      const response = await fetch(url, {
        ...options,
        signal: controller.signal
      });
      clearTimeout(timeoutId);
      resolve(response);
    } catch (error) {
      clearTimeout(timeoutId);
      reject(error);
    } finally {
      this.active--;
      this.processQueue();
    }
  }
}
```

### Timeout Metrics Collection

Tracking timeout occurrences and durations for monitoring and optimization.

```javascript
class FetchWithMetrics {
  constructor(defaultTimeout = 5000) {
    this.defaultTimeout = defaultTimeout;
    this.metrics = {
      totalRequests: 0,
      timeouts: 0,
      successfulRequests: 0,
      averageResponseTime: 0,
      timeoutsByUrl: new Map()
    };
  }
  
  async fetch(url, options = {}, timeout = this.defaultTimeout) {
    const startTime = Date.now();
    this.metrics.totalRequests++;
    
    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), timeout);
    
    try {
      const response = await fetch(url, {
        ...options,
        signal: controller.signal
      });
      
      clearTimeout(timeoutId);
      
      const duration = Date.now() - startTime;
      this.metrics.successfulRequests++;
      this.updateAverageResponseTime(duration);
      
      return response;
    } catch (error) {
      clearTimeout(timeoutId);
      
      if (error.name === 'AbortError') {
        this.metrics.timeouts++;
        const urlTimeouts = this.metrics.timeoutsByUrl.get(url) || 0;
        this.metrics.timeoutsByUrl.set(url, urlTimeouts + 1);
      }
      
      throw error;
    }
  }
  
  updateAverageResponseTime(duration) {
    const total = this.metrics.averageResponseTime * (this.metrics.successfulRequests - 1);
    this.metrics.averageResponseTime = (total + duration) / this.metrics.successfulRequests;
  }
  
  getMetrics() {
    return { ...this.metrics };
  }
}
```

---

