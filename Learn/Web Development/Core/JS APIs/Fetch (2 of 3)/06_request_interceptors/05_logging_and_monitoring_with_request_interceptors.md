## Logging and Monitoring with Request Interceptors


### Native Fetch Interception Approaches

The fetch API does not provide built-in interceptor mechanisms like some HTTP libraries (e.g., Axios). Interception requires wrapping or monkey-patching the global fetch function.

### Basic Fetch Wrapper Pattern

#### Simple Logging Wrapper

```javascript
const originalFetch = window.fetch;

window.fetch = function(...args) {
  const [resource, config] = args;
  
  console.log('Fetch initiated:', {
    url: resource,
    method: config?.method || 'GET',
    headers: config?.headers,
    timestamp: new Date().toISOString()
  });
  
  return originalFetch.apply(this, args);
};
```

This wraps the native fetch to log every request without modifying application code.

#### Request and Response Logging

```javascript
const originalFetch = window.fetch;

window.fetch = async function(...args) {
  const [resource, config] = args;
  const startTime = performance.now();
  
  console.log('→ Request:', {
    url: resource,
    method: config?.method || 'GET',
    timestamp: new Date().toISOString()
  });
  
  try {
    const response = await originalFetch.apply(this, args);
    const duration = performance.now() - startTime;
    
    console.log('← Response:', {
      url: resource,
      status: response.status,
      statusText: response.statusText,
      duration: `${duration.toFixed(2)}ms`,
      timestamp: new Date().toISOString()
    });
    
    return response;
  } catch (error) {
    const duration = performance.now() - startTime;
    
    console.error('✗ Request failed:', {
      url: resource,
      error: error.message,
      duration: `${duration.toFixed(2)}ms`,
      timestamp: new Date().toISOString()
    });
    
    throw error;
  }
};
```

### Advanced Interceptor Implementation

#### Class-Based Interceptor Manager

```javascript
class FetchInterceptor {
  constructor() {
    this.requestInterceptors = [];
    this.responseInterceptors = [];
    this.errorInterceptors = [];
    this.originalFetch = window.fetch;
    this.isAttached = false;
  }
  
  attach() {
    if (this.isAttached) return;
    
    const self = this;
    
    window.fetch = async function(...args) {
      let [resource, config] = args;
      
      // Run request interceptors
      for (const interceptor of self.requestInterceptors) {
        const result = await interceptor(resource, config);
        if (result) {
          resource = result.resource || resource;
          config = result.config || config;
        }
      }
      
      try {
        let response = await self.originalFetch(resource, config);
        
        // Run response interceptors
        for (const interceptor of self.responseInterceptors) {
          const result = await interceptor(response, resource, config);
          if (result) {
            response = result;
          }
        }
        
        return response;
      } catch (error) {
        // Run error interceptors
        for (const interceptor of self.errorInterceptors) {
          await interceptor(error, resource, config);
        }
        throw error;
      }
    };
    
    this.isAttached = true;
  }
  
  detach() {
    if (!this.isAttached) return;
    window.fetch = this.originalFetch;
    this.isAttached = false;
  }
  
  addRequestInterceptor(interceptor) {
    this.requestInterceptors.push(interceptor);
    return () => {
      const index = this.requestInterceptors.indexOf(interceptor);
      if (index > -1) {
        this.requestInterceptors.splice(index, 1);
      }
    };
  }
  
  addResponseInterceptor(interceptor) {
    this.responseInterceptors.push(interceptor);
    return () => {
      const index = this.responseInterceptors.indexOf(interceptor);
      if (index > -1) {
        this.responseInterceptors.splice(index, 1);
      }
    };
  }
  
  addErrorInterceptor(interceptor) {
    this.errorInterceptors.push(interceptor);
    return () => {
      const index = this.errorInterceptors.indexOf(interceptor);
      if (index > -1) {
        this.errorInterceptors.splice(index, 1);
      }
    };
  }
  
  clear() {
    this.requestInterceptors = [];
    this.responseInterceptors = [];
    this.errorInterceptors = [];
  }
}
```

#### Usage Example

```javascript
const interceptor = new FetchInterceptor();
interceptor.attach();

// Add request logging
interceptor.addRequestInterceptor((resource, config) => {
  console.log('Request to:', resource);
  return { resource, config };
});

// Add response logging
interceptor.addResponseInterceptor((response, resource, config) => {
  console.log('Response from:', resource, 'Status:', response.status);
  return response;
});

// Add error handling
interceptor.addErrorInterceptor((error, resource, config) => {
  console.error('Request failed:', resource, error);
});
```

### Performance Monitoring

#### Timing Metrics Collection

```javascript
class PerformanceMonitor {
  constructor() {
    this.metrics = [];
  }
  
  createInterceptor() {
    return async (resource, config) => {
      const url = typeof resource === 'string' ? resource : resource.url;
      const startTime = performance.now();
      const startMark = `fetch-start-${Date.now()}`;
      const endMark = `fetch-end-${Date.now()}`;
      
      performance.mark(startMark);
      
      const originalFetch = window.fetch;
      
      try {
        const response = await originalFetch(resource, config);
        performance.mark(endMark);
        
        const duration = performance.now() - startTime;
        
        this.metrics.push({
          url,
          method: config?.method || 'GET',
          status: response.status,
          duration,
          startTime: new Date(startTime),
          success: response.ok,
          cached: response.headers.has('Age'),
          size: response.headers.get('Content-Length')
        });
        
        performance.measure(`fetch-${url}`, startMark, endMark);
        
        return response;
      } catch (error) {
        performance.mark(endMark);
        const duration = performance.now() - startTime;
        
        this.metrics.push({
          url,
          method: config?.method || 'GET',
          duration,
          startTime: new Date(startTime),
          success: false,
          error: error.message
        });
        
        throw error;
      }
    };
  }
  
  getMetrics() {
    return this.metrics;
  }
  
  getAverageResponseTime(url) {
    const filtered = url 
      ? this.metrics.filter(m => m.url === url)
      : this.metrics;
    
    if (filtered.length === 0) return 0;
    
    const sum = filtered.reduce((acc, m) => acc + m.duration, 0);
    return sum / filtered.length;
  }
  
  getSuccessRate(url) {
    const filtered = url 
      ? this.metrics.filter(m => m.url === url)
      : this.metrics;
    
    if (filtered.length === 0) return 0;
    
    const successful = filtered.filter(m => m.success).length;
    return (successful / filtered.length) * 100;
  }
  
  getSlowestRequests(count = 10) {
    return [...this.metrics]
      .sort((a, b) => b.duration - a.duration)
      .slice(0, count);
  }
  
  clear() {
    this.metrics = [];
  }
}
```

#### Integration

```javascript
const monitor = new PerformanceMonitor();
const originalFetch = window.fetch;

window.fetch = async function(...args) {
  const interceptor = monitor.createInterceptor();
  return interceptor(...args);
};

// Later, analyze metrics
console.log('Average response time:', monitor.getAverageResponseTime());
console.log('Success rate:', monitor.getSuccessRate(), '%');
console.log('Slowest requests:', monitor.getSlowestRequests(5));
```

### Request Modification Interceptors

#### Adding Authentication Headers

```javascript
interceptor.addRequestInterceptor((resource, config = {}) => {
  const token = localStorage.getItem('authToken');
  
  if (token) {
    config.headers = {
      ...config.headers,
      'Authorization': `Bearer ${token}`
    };
  }
  
  return { resource, config };
});
```

#### Adding Default Headers

```javascript
interceptor.addRequestInterceptor((resource, config = {}) => {
  config.headers = {
    'Content-Type': 'application/json',
    'X-Client-Version': '1.2.3',
    'X-Request-ID': crypto.randomUUID(),
    ...config.headers
  };
  
  return { resource, config };
});
```

#### Request Transformation

```javascript
interceptor.addRequestInterceptor((resource, config = {}) => {
  if (config.body && typeof config.body === 'object') {
    // Transform object to JSON string
    config.body = JSON.stringify(config.body);
    config.headers = {
      'Content-Type': 'application/json',
      ...config.headers
    };
  }
  
  return { resource, config };
});
```

#### URL Modification

```javascript
interceptor.addRequestInterceptor((resource, config) => {
  const baseURL = 'https://api.example.com';
  
  if (typeof resource === 'string' && !resource.startsWith('http')) {
    resource = `${baseURL}${resource.startsWith('/') ? '' : '/'}${resource}`;
  }
  
  return { resource, config };
});
```

### Response Processing Interceptors

#### Response Data Extraction

```javascript
interceptor.addResponseInterceptor(async (response, resource, config) => {
  const clonedResponse = response.clone();
  
  if (response.ok) {
    try {
      const data = await response.json();
      console.log('Response data:', data);
    } catch (e) {
      // Not JSON, ignore
    }
  }
  
  return clonedResponse;
});
```

Note: Response bodies can only be read once, so cloning is necessary for inspection without consuming the original.

#### Status Code Handling

```javascript
interceptor.addResponseInterceptor(async (response, resource, config) => {
  if (response.status === 401) {
    console.warn('Unauthorized request, redirecting to login');
    window.location.href = '/login';
  }
  
  if (response.status === 403) {
    console.error('Forbidden access to:', resource);
  }
  
  if (response.status >= 500) {
    console.error('Server error occurred:', response.status);
  }
  
  return response;
});
```

#### Response Caching

```javascript
const responseCache = new Map();

interceptor.addResponseInterceptor(async (response, resource, config) => {
  if (response.ok && config?.method === 'GET') {
    const cloned = response.clone();
    const data = await cloned.json();
    
    responseCache.set(resource, {
      data,
      timestamp: Date.now(),
      status: response.status,
      headers: Object.fromEntries(response.headers.entries())
    });
  }
  
  return response;
});
```

### Error Handling and Retry Logic

#### Automatic Retry Mechanism

```javascript
async function fetchWithRetry(resource, config = {}, maxRetries = 3) {
  const originalFetch = window.fetch;
  
  for (let attempt = 0; attempt <= maxRetries; attempt++) {
    try {
      const response = await originalFetch(resource, config);
      
      if (response.ok) {
        return response;
      }
      
      // Retry on 5xx errors
      if (response.status >= 500 && attempt < maxRetries) {
        const delay = Math.pow(2, attempt) * 1000; // Exponential backoff
        console.log(`Retrying after ${delay}ms (attempt ${attempt + 1}/${maxRetries})`);
        await new Promise(resolve => setTimeout(resolve, delay));
        continue;
      }
      
      return response;
    } catch (error) {
      if (attempt === maxRetries) {
        throw error;
      }
      
      const delay = Math.pow(2, attempt) * 1000;
      console.log(`Network error, retrying after ${delay}ms (attempt ${attempt + 1}/${maxRetries})`);
      await new Promise(resolve => setTimeout(resolve, delay));
    }
  }
}
```

#### Circuit Breaker Pattern

```javascript
class CircuitBreaker {
  constructor(threshold = 5, timeout = 60000) {
    this.failureCount = 0;
    this.threshold = threshold;
    this.timeout = timeout;
    this.state = 'CLOSED'; // CLOSED, OPEN, HALF_OPEN
    this.nextAttempt = Date.now();
  }
  
  async execute(fn) {
    if (this.state === 'OPEN') {
      if (Date.now() < this.nextAttempt) {
        throw new Error('Circuit breaker is OPEN');
      }
      this.state = 'HALF_OPEN';
    }
    
    try {
      const result = await fn();
      this.onSuccess();
      return result;
    } catch (error) {
      this.onFailure();
      throw error;
    }
  }
  
  onSuccess() {
    this.failureCount = 0;
    this.state = 'CLOSED';
  }
  
  onFailure() {
    this.failureCount++;
    
    if (this.failureCount >= this.threshold) {
      this.state = 'OPEN';
      this.nextAttempt = Date.now() + this.timeout;
      console.warn('Circuit breaker opened due to failures');
    }
  }
  
  reset() {
    this.failureCount = 0;
    this.state = 'CLOSED';
    this.nextAttempt = Date.now();
  }
}

// Usage
const breaker = new CircuitBreaker(5, 30000);

async function protectedFetch(resource, config) {
  return breaker.execute(() => fetch(resource, config));
}
```

### Structured Logging

#### Contextual Logger

```javascript
class RequestLogger {
  constructor(context = {}) {
    this.context = context;
    this.logs = [];
  }
  
  log(level, message, data = {}) {
    const entry = {
      level,
      message,
      timestamp: new Date().toISOString(),
      context: this.context,
      ...data
    };
    
    this.logs.push(entry);
    
    const method = level === 'error' ? 'error' : 
                   level === 'warn' ? 'warn' : 'log';
    console[method](`[${level.toUpperCase()}]`, message, entry);
  }
  
  info(message, data) {
    this.log('info', message, data);
  }
  
  warn(message, data) {
    this.log('warn', message, data);
  }
  
  error(message, data) {
    this.log('error', message, data);
  }
  
  createRequestLogger() {
    return (resource, config) => {
      const requestId = crypto.randomUUID();
      const url = typeof resource === 'string' ? resource : resource.url;
      
      this.info('Request initiated', {
        requestId,
        url,
        method: config?.method || 'GET',
        headers: config?.headers
      });
      
      return { resource, config: { ...config, requestId } };
    };
  }
  
  createResponseLogger() {
    return (response, resource, config) => {
      const url = typeof resource === 'string' ? resource : resource.url;
      
      this.info('Response received', {
        requestId: config?.requestId,
        url,
        status: response.status,
        statusText: response.statusText,
        headers: Object.fromEntries(response.headers.entries())
      });
      
      return response;
    };
  }
  
  createErrorLogger() {
    return (error, resource, config) => {
      const url = typeof resource === 'string' ? resource : resource.url;
      
      this.error('Request failed', {
        requestId: config?.requestId,
        url,
        method: config?.method || 'GET',
        error: error.message,
        stack: error.stack
      });
    };
  }
  
  getLogs(filter = {}) {
    let filtered = this.logs;
    
    if (filter.level) {
      filtered = filtered.filter(log => log.level === filter.level);
    }
    
    if (filter.since) {
      filtered = filtered.filter(log => new Date(log.timestamp) >= filter.since);
    }
    
    return filtered;
  }
  
  exportLogs() {
    return JSON.stringify(this.logs, null, 2);
  }
  
  clear() {
    this.logs = [];
  }
}
```

#### Usage with Interceptor

```javascript
const logger = new RequestLogger({ service: 'frontend', version: '1.0.0' });
const interceptor = new FetchInterceptor();

interceptor.addRequestInterceptor(logger.createRequestLogger());
interceptor.addResponseInterceptor(logger.createResponseLogger());
interceptor.addErrorInterceptor(logger.createErrorLogger());

interceptor.attach();
```

### Request Deduplication

#### Preventing Duplicate Concurrent Requests

```javascript
class RequestDeduplicator {
  constructor() {
    this.pendingRequests = new Map();
  }
  
  createInterceptor() {
    return async (resource, config = {}) => {
      const key = this.generateKey(resource, config);
      
      if (this.pendingRequests.has(key)) {
        console.log('Deduplicating request:', key);
        return this.pendingRequests.get(key);
      }
      
      const promise = fetch(resource, config)
        .finally(() => {
          this.pendingRequests.delete(key);
        });
      
      this.pendingRequests.set(key, promise);
      return promise;
    };
  }
  
  generateKey(resource, config) {
    const url = typeof resource === 'string' ? resource : resource.url;
    const method = config.method || 'GET';
    const body = config.body ? JSON.stringify(config.body) : '';
    
    return `${method}:${url}:${body}`;
  }
  
  clear() {
    this.pendingRequests.clear();
  }
}
```

### Request Queuing and Rate Limiting

#### Rate Limiter

```javascript
class RateLimiter {
  constructor(maxRequests = 10, timeWindow = 1000) {
    this.maxRequests = maxRequests;
    this.timeWindow = timeWindow;
    this.requests = [];
  }
  
  async waitForSlot() {
    const now = Date.now();
    this.requests = this.requests.filter(time => now - time < this.timeWindow);
    
    if (this.requests.length >= this.maxRequests) {
      const oldestRequest = Math.min(...this.requests);
      const waitTime = this.timeWindow - (now - oldestRequest);
      
      console.log(`Rate limit reached, waiting ${waitTime}ms`);
      await new Promise(resolve => setTimeout(resolve, waitTime + 10));
      return this.waitForSlot();
    }
    
    this.requests.push(now);
  }
  
  createInterceptor() {
    return async (resource, config) => {
      await this.waitForSlot();
      return { resource, config };
    };
  }
}

// Usage
const rateLimiter = new RateLimiter(5, 1000); // 5 requests per second
interceptor.addRequestInterceptor(rateLimiter.createInterceptor());
```

#### Request Queue

```javascript
class RequestQueue {
  constructor(concurrency = 3) {
    this.concurrency = concurrency;
    this.queue = [];
    this.active = 0;
  }
  
  async enqueue(fn) {
    while (this.active >= this.concurrency) {
      await new Promise(resolve => {
        this.queue.push(resolve);
      });
    }
    
    this.active++;
    
    try {
      return await fn();
    } finally {
      this.active--;
      const next = this.queue.shift();
      if (next) next();
    }
  }
  
  createInterceptor() {
    return async (resource, config) => {
      const result = await this.enqueue(async () => {
        return { resource, config };
      });
      return result;
    };
  }
}
```

### Analytics and Metrics Export

#### Metrics Aggregator

```javascript
class MetricsAggregator {
  constructor() {
    this.metrics = {
      totalRequests: 0,
      successfulRequests: 0,
      failedRequests: 0,
      totalDuration: 0,
      byEndpoint: new Map(),
      byStatusCode: new Map(),
      byMethod: new Map()
    };
  }
  
  record(data) {
    this.metrics.totalRequests++;
    
    if (data.success) {
      this.metrics.successfulRequests++;
    } else {
      this.metrics.failedRequests++;
    }
    
    this.metrics.totalDuration += data.duration;
    
    // By endpoint
    const endpointStats = this.metrics.byEndpoint.get(data.url) || {
      count: 0,
      totalDuration: 0,
      successes: 0,
      failures: 0
    };
    endpointStats.count++;
    endpointStats.totalDuration += data.duration;
    if (data.success) endpointStats.successes++;
    else endpointStats.failures++;
    this.metrics.byEndpoint.set(data.url, endpointStats);
    
    // By status code
    if (data.status) {
      const statusCount = this.metrics.byStatusCode.get(data.status) || 0;
      this.metrics.byStatusCode.set(data.status, statusCount + 1);
    }
    
    // By method
    const methodCount = this.metrics.byMethod.get(data.method) || 0;
    this.metrics.byMethod.set(data.method, methodCount + 1);
  }
  
  getReport() {
    return {
      summary: {
        totalRequests: this.metrics.totalRequests,
        successRate: (this.metrics.successfulRequests / this.metrics.totalRequests * 100).toFixed(2) + '%',
        averageDuration: (this.metrics.totalDuration / this.metrics.totalRequests).toFixed(2) + 'ms'
      },
      byEndpoint: Object.fromEntries(
        Array.from(this.metrics.byEndpoint.entries()).map(([url, stats]) => [
          url,
          {
            ...stats,
            averageDuration: (stats.totalDuration / stats.count).toFixed(2) + 'ms',
            successRate: (stats.successes / stats.count * 100).toFixed(2) + '%'
          }
        ])
      ),
      byStatusCode: Object.fromEntries(this.metrics.byStatusCode),
      byMethod: Object.fromEntries(this.metrics.byMethod)
    };
  }
  
  sendToAnalytics() {
    const report = this.getReport();
    
    // Send to analytics service
    fetch('https://analytics.example.com/metrics', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(report)
    }).catch(err => console.error('Failed to send metrics:', err));
  }
  
  reset() {
    this.metrics = {
      totalRequests: 0,
      successfulRequests: 0,
      failedRequests: 0,
      totalDuration: 0,
      byEndpoint: new Map(),
      byStatusCode: new Map(),
      byMethod: new Map()
    };
  }
}
```

### Development vs Production Interceptors

#### Environment-Aware Configuration

```javascript
class InterceptorConfig {
  constructor(environment = 'development') {
    this.environment = environment;
    this.interceptor = new FetchInterceptor();
  }
  
  setup() {
    if (this.environment === 'development') {
      this.setupDevelopment();
    } else {
      this.setupProduction();
    }
    
    this.interceptor.attach();
  }
  
  setupDevelopment() {
    // Verbose logging
    this.interceptor.addRequestInterceptor((resource, config) => {
      console.group('🚀 Request');
      console.log('URL:', resource);
      console.log('Method:', config?.method || 'GET');
      console.log('Headers:', config?.headers);
      console.log('Body:', config?.body);
      console.groupEnd();
      return { resource, config };
    });
    
    this.interceptor.addResponseInterceptor(async (response, resource) => {
      const cloned = response.clone();
      console.group('✅ Response');
      console.log('URL:', resource);
      console.log('Status:', response.status);
      console.log('Headers:', Object.fromEntries(response.headers.entries()));
      try {
        const data = await cloned.json();
        console.log('Data:', data);
      } catch (e) {
        // Not JSON
      }
      console.groupEnd();
      return response;
    });
    
    // Mock slow network
    this.interceptor.addRequestInterceptor(async (resource, config) => {
      await new Promise(resolve => setTimeout(resolve, 500));
      return { resource, config };
    });
  }
  
  setupProduction() {
    // Error tracking only
    const metrics = new MetricsAggregator();
    
    this.interceptor.addErrorInterceptor((error, resource, config) => {
      metrics.record({
        url: resource,
        method: config?.method || 'GET',
        success: false,
        error: error.message,
        duration: 0
      });
      
      // Send to error tracking service
      fetch('https://errors.example.com/track', {
        method: 'POST',
        body: JSON.stringify({
          error: error.message,
          url: resource,
          timestamp: Date.now()
        })
      }).catch(() => {}); // Silent fail
    });
    
    // Periodic metrics reporting
    setInterval(() => {
      metrics.sendToAnalytics();
      metrics.reset();
    }, 60000); // Every minute
  }
}

// Usage
const config = new InterceptorConfig(process.env.NODE_ENV);
config.setup();
```

### Request/Response Transformation Pipeline

#### Composable Transformers

```javascript
class TransformPipeline {
  constructor() {
    this.requestTransformers = [];
    this.responseTransformers = [];
  }
  
  addRequestTransformer(transformer) {
    this.requestTransformers.push(transformer);
  }
  
  addResponseTransformer(transformer) {
    this.responseTransformers.push(transformer);
  }
  
  async transformRequest(resource, config) {
    let result = { resource, config };
    
    for (const transformer of this.requestTransformers) {
      result = await transformer(result.resource, result.config);
    }
    
    return result;
  }
  
  async transformResponse(response) {
    let result = response;
    
    for (const transformer of this.responseTransformers) {
      result = await transformer(result);
    }
    
    return result;
  }
  
  createInterceptor() {
    return {
      request: async (resource, config) => {
        return this.transformRequest(resource, config);
      },
      response: async (response) => {
        return this.transformResponse(response);
      }
    };
  }
}

// Example transformers
const jsonTransformer = (resource, config) => {
  if (config?.body && typeof config.body === 'object') {
    config.body = JSON.stringify(config.body);
    config.headers = {
      'Content-Type': 'application/json',
      ...config.headers
    };
  }
  return { resource, config };
};

const authTransformer = (resource, config = {}) => {
  const token = getAuthToken();
  if (token) {
    config.headers = {
      ...config.headers,
      'Authorization': `Bearer ${token}`
    };
  }
  return { resource, config };
};

const responseDataTransformer = async (response) => {
  if (response.ok && response.headers.get('Content-Type')?.includes('json')) {
    const data = await response.json();
    // Add transformed data to response object
    response.data = data;
  }
  return response;
};

// Usage
const pipeline = new TransformPipeline();
pipeline.addRequestTransformer(jsonTransformer);
pipeline.addRequestTransformer(authTransformer);
pipeline.addResponseTransformer(responseDataTransformer);
```

### Memory Management Considerations

Interceptors that store data (logs, metrics, cached responses) can accumulate memory over time. Implement cleanup strategies:

```javascript
class ManagedInterceptor {
  constructor(maxLogSize = 1000, maxCacheSize = 100) {
    this.logs = [];
    this.cache = new Map();
    this.maxLogSize = maxLogSize;
    this.maxCacheSize = maxCacheSize;
  }
  
  addLog(entry) {
    this.logs.push(entry);
    
    if (this.logs.length > this.maxLogSize) {
      this.logs = this.logs.slice(-this.maxLogSize);
    }
  }
  
  addToCache(key, value) {
    if (this.cache.size >= this.maxCacheSize) {
      const firstKey = this.cache.keys().next().value;
      this.cache.delete(firstKey);
    }
    
    this.cache.set(key, value);
  }
  
  clearOldLogs(maxAge = 3600000) { // 1 hour default
    const now = Date.now();
    this.logs = this.logs.filter(log => 
      now - new Date(log.timestamp).getTime() < maxAge
    );
  }
  
  clearStaleCache(maxAge = 600000) { // 10 minutes default
    const now = Date.now();
    for (const [key, value] of this.cache.entries()) {
      if (now - value.timestamp > maxAge) {
        this.cache.delete(key);
      }
    }
  }
}
```

---

