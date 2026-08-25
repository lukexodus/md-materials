## Middleware Patterns for Fetch API


### Core Middleware Concepts

Middleware in the context of Fetch API refers to composable functions that intercept, modify, or enhance HTTP requests and responses. These patterns enable separation of concerns by extracting cross-cutting functionality like authentication, logging, error handling, and request transformation into reusable layers.

### Basic Middleware Structure

#### Function Composition Pattern

```javascript
function createFetchMiddleware(middlewares) {
  return async (url, options = {}) => {
    let modifiedOptions = { ...options };
    let modifiedUrl = url;
    
    // Request phase - execute middlewares in order
    for (const middleware of middlewares) {
      if (middleware.request) {
        const result = await middleware.request(modifiedUrl, modifiedOptions);
        modifiedUrl = result.url || modifiedUrl;
        modifiedOptions = result.options || modifiedOptions;
      }
    }
    
    // Execute fetch
    let response = await fetch(modifiedUrl, modifiedOptions);
    
    // Response phase - execute middlewares in reverse order
    for (const middleware of [...middlewares].reverse()) {
      if (middleware.response) {
        response = await middleware.response(response, modifiedUrl, modifiedOptions);
      }
    }
    
    return response;
  };
}

// Usage
const enhancedFetch = createFetchMiddleware([
  authMiddleware,
  loggingMiddleware,
  errorHandlingMiddleware
]);

const response = await enhancedFetch('/api/data');
```

#### Chain of Responsibility Pattern

```javascript
class FetchMiddleware {
  constructor() {
    this.middlewares = [];
  }
  
  use(middleware) {
    this.middlewares.push(middleware);
    return this;
  }
  
  async fetch(url, options = {}) {
    const chain = [...this.middlewares];
    
    const dispatch = async (index, url, options) => {
      if (index >= chain.length) {
        return fetch(url, options);
      }
      
      const middleware = chain[index];
      return middleware(url, options, (nextUrl, nextOptions) => {
        return dispatch(index + 1, nextUrl || url, nextOptions || options);
      });
    };
    
    return dispatch(0, url, options);
  }
}

// Middleware function signature
function loggingMiddleware(url, options, next) {
  console.log(`Request: ${options.method || 'GET'} ${url}`);
  const startTime = Date.now();
  
  return next(url, options).then(response => {
    console.log(`Response: ${response.status} (${Date.now() - startTime}ms)`);
    return response;
  });
}

// Usage
const client = new FetchMiddleware();
client
  .use(loggingMiddleware)
  .use(authMiddleware)
  .use(retryMiddleware);

const response = await client.fetch('/api/users');
```

### Authentication Middleware

#### Bearer Token Injection

```javascript
function createAuthMiddleware(getToken) {
  return {
    request: async (url, options) => {
      const token = await getToken();
      
      if (!token) {
        return { url, options };
      }
      
      const headers = new Headers(options.headers);
      headers.set('Authorization', `Bearer ${token}`);
      
      return {
        url,
        options: {
          ...options,
          headers
        }
      };
    }
  };
}

// Usage
const authMiddleware = createAuthMiddleware(async () => {
  return localStorage.getItem('access_token');
});
```

#### Token Refresh Middleware

```javascript
function createTokenRefreshMiddleware(tokenManager) {
  return {
    request: async (url, options) => {
      const token = await tokenManager.getValidToken();
      const headers = new Headers(options.headers);
      headers.set('Authorization', `Bearer ${token}`);
      
      return {
        url,
        options: { ...options, headers }
      };
    },
    
    response: async (response, url, options) => {
      if (response.status === 401) {
        // Token expired, refresh and retry
        const refreshed = await tokenManager.refresh();
        
        if (refreshed) {
          const newToken = await tokenManager.getValidToken();
          const headers = new Headers(options.headers);
          headers.set('Authorization', `Bearer ${newToken}`);
          
          // Retry the request
          return fetch(url, {
            ...options,
            headers
          });
        }
      }
      
      return response;
    }
  };
}

class TokenManager {
  constructor() {
    this.accessToken = null;
    this.refreshToken = null;
    this.expiresAt = null;
  }
  
  async getValidToken() {
    if (this.accessToken && Date.now() < this.expiresAt) {
      return this.accessToken;
    }
    
    await this.refresh();
    return this.accessToken;
  }
  
  async refresh() {
    try {
      const response = await fetch('/auth/refresh', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ refreshToken: this.refreshToken })
      });
      
      if (!response.ok) {
        return false;
      }
      
      const data = await response.json();
      this.accessToken = data.accessToken;
      this.expiresAt = Date.now() + (data.expiresIn * 1000);
      
      return true;
    } catch (error) {
      return false;
    }
  }
}
```

#### API Key Middleware

```javascript
function createApiKeyMiddleware(apiKey, headerName = 'X-API-Key') {
  return {
    request: (url, options) => {
      const headers = new Headers(options.headers);
      headers.set(headerName, apiKey);
      
      return {
        url,
        options: { ...options, headers }
      };
    }
  };
}
```

### Logging and Monitoring Middleware

#### Request/Response Logger

```javascript
function createLoggingMiddleware(logger = console) {
  return {
    request: async (url, options) => {
      const requestId = crypto.randomUUID();
      
      logger.log({
        type: 'request',
        requestId,
        timestamp: new Date().toISOString(),
        method: options.method || 'GET',
        url,
        headers: Object.fromEntries(new Headers(options.headers || {})),
        body: options.body
      });
      
      // Attach requestId to options for response correlation
      return {
        url,
        options: {
          ...options,
          __requestId: requestId
        }
      };
    },
    
    response: async (response, url, options) => {
      const clonedResponse = response.clone();
      
      try {
        const body = await clonedResponse.text();
        
        logger.log({
          type: 'response',
          requestId: options.__requestId,
          timestamp: new Date().toISOString(),
          status: response.status,
          statusText: response.statusText,
          headers: Object.fromEntries(response.headers),
          body: body.substring(0, 1000) // Truncate for logging
        });
      } catch (error) {
        logger.error('Failed to log response body:', error);
      }
      
      return response;
    }
  };
}
```

#### Performance Monitoring

```javascript
function createPerformanceMiddleware(onMetric) {
  return {
    request: (url, options) => {
      const startTime = performance.now();
      
      return {
        url,
        options: {
          ...options,
          __startTime: startTime,
          __performanceUrl: url
        }
      };
    },
    
    response: async (response, url, options) => {
      const duration = performance.now() - options.__startTime;
      
      onMetric({
        url: options.__performanceUrl,
        method: options.method || 'GET',
        status: response.status,
        duration,
        timestamp: Date.now()
      });
      
      return response;
    }
  };
}

// Usage with aggregation
class MetricsCollector {
  constructor() {
    this.metrics = [];
  }
  
  record(metric) {
    this.metrics.push(metric);
    
    if (this.metrics.length >= 100) {
      this.flush();
    }
  }
  
  flush() {
    if (this.metrics.length === 0) return;
    
    // Send to analytics service
    fetch('/analytics/metrics', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(this.metrics)
    }).catch(console.error);
    
    this.metrics = [];
  }
  
  getStats() {
    const durations = this.metrics.map(m => m.duration);
    return {
      count: durations.length,
      avg: durations.reduce((a, b) => a + b, 0) / durations.length,
      min: Math.min(...durations),
      max: Math.max(...durations)
    };
  }
}

const collector = new MetricsCollector();
const performanceMiddleware = createPerformanceMiddleware(
  (metric) => collector.record(metric)
);
```

### Error Handling Middleware

#### Global Error Handler

```javascript
function createErrorHandlingMiddleware(errorHandler) {
  return {
    response: async (response, url, options) => {
      if (!response.ok) {
        const error = new FetchError(
          `HTTP ${response.status}: ${response.statusText}`,
          response.status,
          response
        );
        
        try {
          error.body = await response.clone().json();
        } catch {
          error.body = await response.clone().text();
        }
        
        const handled = await errorHandler(error, url, options);
        
        if (handled) {
          return handled;
        }
        
        throw error;
      }
      
      return response;
    }
  };
}

class FetchError extends Error {
  constructor(message, status, response) {
    super(message);
    this.name = 'FetchError';
    this.status = status;
    this.response = response;
    this.body = null;
  }
}

// Usage
const errorMiddleware = createErrorHandlingMiddleware(async (error, url, options) => {
  if (error.status === 429) {
    // Rate limited - wait and retry
    const retryAfter = parseInt(error.response.headers.get('Retry-After') || '5');
    await new Promise(resolve => setTimeout(resolve, retryAfter * 1000));
    return fetch(url, options);
  }
  
  if (error.status >= 500) {
    // Server error - log to monitoring service
    await fetch('/api/errors', {
      method: 'POST',
      body: JSON.stringify({
        url,
        status: error.status,
        message: error.message,
        body: error.body
      })
    });
  }
  
  return null; // Let error propagate
});
```

#### Retry with Exponential Backoff

```javascript
function createRetryMiddleware(options = {}) {
  const {
    maxRetries = 3,
    retryDelay = 1000,
    retryStatusCodes = [408, 429, 500, 502, 503, 504],
    shouldRetry = (response) => retryStatusCodes.includes(response.status)
  } = options;
  
  return async (url, fetchOptions, next) => {
    let lastError;
    
    for (let attempt = 0; attempt <= maxRetries; attempt++) {
      try {
        const response = await next(url, fetchOptions);
        
        if (response.ok || !shouldRetry(response)) {
          return response;
        }
        
        lastError = new Error(`HTTP ${response.status}`);
        
        if (attempt < maxRetries) {
          const delay = retryDelay * Math.pow(2, attempt);
          await new Promise(resolve => setTimeout(resolve, delay));
        }
        
      } catch (error) {
        lastError = error;
        
        if (attempt < maxRetries) {
          const delay = retryDelay * Math.pow(2, attempt);
          await new Promise(resolve => setTimeout(resolve, delay));
        }
      }
    }
    
    throw lastError;
  };
}
```

### Request Transformation Middleware

#### Content Type Handler

```javascript
function createContentTypeMiddleware() {
  return {
    request: (url, options) => {
      if (!options.body) {
        return { url, options };
      }
      
      const headers = new Headers(options.headers);
      
      // Auto-detect and set Content-Type
      if (typeof options.body === 'string') {
        try {
          JSON.parse(options.body);
          if (!headers.has('Content-Type')) {
            headers.set('Content-Type', 'application/json');
          }
        } catch {
          if (!headers.has('Content-Type')) {
            headers.set('Content-Type', 'text/plain');
          }
        }
      } else if (options.body instanceof FormData) {
        // Browser sets multipart/form-data automatically
        headers.delete('Content-Type');
      } else if (options.body instanceof URLSearchParams) {
        headers.set('Content-Type', 'application/x-www-form-urlencoded');
      } else if (typeof options.body === 'object') {
        // Auto-stringify objects
        options.body = JSON.stringify(options.body);
        headers.set('Content-Type', 'application/json');
      }
      
      return {
        url,
        options: { ...options, headers }
      };
    }
  };
}
```

#### Request Body Compression

```javascript
function createCompressionMiddleware(minSize = 1024) {
  return {
    request: async (url, options) => {
      if (!options.body || typeof options.body !== 'string') {
        return { url, options };
      }
      
      if (options.body.length < minSize) {
        return { url, options };
      }
      
      // Check if CompressionStream is available
      if (!window.CompressionStream) {
        return { url, options };
      }
      
      const blob = new Blob([options.body]);
      const stream = blob.stream();
      const compressedStream = stream.pipeThrough(
        new CompressionStream('gzip')
      );
      
      const compressedBlob = await new Response(compressedStream).blob();
      
      const headers = new Headers(options.headers);
      headers.set('Content-Encoding', 'gzip');
      
      return {
        url,
        options: {
          ...options,
          body: compressedBlob,
          headers
        }
      };
    }
  };
}
```

#### Query Parameter Serialization

```javascript
function createQueryParamsMiddleware() {
  return {
    request: (url, options) => {
      if (!options.params) {
        return { url, options };
      }
      
      const urlObj = new URL(url, window.location.origin);
      
      Object.entries(options.params).forEach(([key, value]) => {
        if (value !== null && value !== undefined) {
          if (Array.isArray(value)) {
            value.forEach(v => urlObj.searchParams.append(key, v));
          } else {
            urlObj.searchParams.set(key, value);
          }
        }
      });
      
      const { params, ...restOptions } = options;
      
      return {
        url: urlObj.toString(),
        options: restOptions
      };
    }
  };
}

// Usage
const response = await enhancedFetch('/api/users', {
  params: {
    page: 1,
    limit: 10,
    tags: ['javascript', 'fetch']
  }
});
// Requests: /api/users?page=1&limit=10&tags=javascript&tags=fetch
```

### Response Transformation Middleware

#### Auto-Parse Response

```javascript
function createResponseParserMiddleware() {
  return {
    response: async (response, url, options) => {
      const contentType = response.headers.get('Content-Type');
      
      if (!contentType) {
        return response;
      }
      
      const cloned = response.clone();
      
      try {
        if (contentType.includes('application/json')) {
          const data = await cloned.json();
          response.data = data;
        } else if (contentType.includes('text/')) {
          const text = await cloned.text();
          response.data = text;
        } else if (contentType.includes('application/octet-stream')) {
          const blob = await cloned.blob();
          response.data = blob;
        }
      } catch (error) {
        // Failed to parse, leave response as-is
      }
      
      return response;
    }
  };
}

// Usage
const response = await enhancedFetch('/api/users');
console.log(response.data); // Pre-parsed JSON
```

#### Response Caching Middleware

```javascript
function createCacheMiddleware(cacheConfig = {}) {
  const cache = new Map();
  const {
    ttl = 60000, // 1 minute default
    methods = ['GET'],
    shouldCache = (url, options) => methods.includes(options.method || 'GET')
  } = cacheConfig;
  
  return {
    request: async (url, options) => {
      if (!shouldCache(url, options)) {
        return { url, options };
      }
      
      const cacheKey = `${options.method || 'GET'}:${url}`;
      const cached = cache.get(cacheKey);
      
      if (cached && Date.now() - cached.timestamp < ttl) {
        // Return cached response
        options.__cached = true;
        options.__cachedResponse = cached.response.clone();
      }
      
      return { url, options };
    },
    
    response: async (response, url, options) => {
      if (options.__cached) {
        return options.__cachedResponse;
      }
      
      if (shouldCache(url, options) && response.ok) {
        const cacheKey = `${options.method || 'GET'}:${url}`;
        cache.set(cacheKey, {
          response: response.clone(),
          timestamp: Date.now()
        });
        
        // Clean up expired entries
        for (const [key, value] of cache.entries()) {
          if (Date.now() - value.timestamp > ttl) {
            cache.delete(key);
          }
        }
      }
      
      return response;
    }
  };
}
```

### Timeout Middleware

#### Request Timeout Handler

```javascript
function createTimeoutMiddleware(timeoutMs = 30000) {
  return async (url, options, next) => {
    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), timeoutMs);
    
    try {
      const response = await next(url, {
        ...options,
        signal: controller.signal
      });
      
      clearTimeout(timeoutId);
      return response;
      
    } catch (error) {
      clearTimeout(timeoutId);
      
      if (error.name === 'AbortError') {
        throw new Error(`Request timeout after ${timeoutMs}ms`);
      }
      
      throw error;
    }
  };
}
```

#### Adaptive Timeout

```javascript
function createAdaptiveTimeoutMiddleware() {
  const metrics = new Map();
  
  return async (url, options, next) => {
    const key = `${options.method || 'GET'}:${url}`;
    const history = metrics.get(key) || [];
    
    // Calculate adaptive timeout based on historical performance
    const avgDuration = history.length > 0
      ? history.reduce((a, b) => a + b, 0) / history.length
      : 5000;
    
    const timeout = Math.min(Math.max(avgDuration * 2, 3000), 30000);
    
    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), timeout);
    
    const startTime = performance.now();
    
    try {
      const response = await next(url, {
        ...options,
        signal: controller.signal
      });
      
      clearTimeout(timeoutId);
      
      // Record duration
      const duration = performance.now() - startTime;
      history.push(duration);
      
      // Keep last 10 measurements
      if (history.length > 10) {
        history.shift();
      }
      
      metrics.set(key, history);
      
      return response;
      
    } catch (error) {
      clearTimeout(timeoutId);
      throw error;
    }
  };
}
```

### Rate Limiting Middleware

#### Token Bucket Implementation

```javascript
class TokenBucket {
  constructor(capacity, refillRate) {
    this.capacity = capacity;
    this.tokens = capacity;
    this.refillRate = refillRate;
    this.lastRefill = Date.now();
  }
  
  async consume(tokens = 1) {
    this.refill();
    
    if (this.tokens >= tokens) {
      this.tokens -= tokens;
      return true;
    }
    
    // Wait until tokens available
    const waitTime = ((tokens - this.tokens) / this.refillRate) * 1000;
    await new Promise(resolve => setTimeout(resolve, waitTime));
    
    this.refill();
    this.tokens -= tokens;
    return true;
  }
  
  refill() {
    const now = Date.now();
    const elapsed = (now - this.lastRefill) / 1000;
    const tokensToAdd = elapsed * this.refillRate;
    
    this.tokens = Math.min(this.capacity, this.tokens + tokensToAdd);
    this.lastRefill = now;
  }
}

function createRateLimitMiddleware(requestsPerSecond = 10) {
  const bucket = new TokenBucket(requestsPerSecond, requestsPerSecond);
  
  return async (url, options, next) => {
    await bucket.consume(1);
    return next(url, options);
  };
}
```

#### Per-Endpoint Rate Limiting

```javascript
function createPerEndpointRateLimiter(config = {}) {
  const buckets = new Map();
  
  const getOrCreateBucket = (endpoint) => {
    if (!buckets.has(endpoint)) {
      const endpointConfig = config[endpoint] || config.default || { rps: 10 };
      buckets.set(endpoint, new TokenBucket(endpointConfig.rps, endpointConfig.rps));
    }
    return buckets.get(endpoint);
  };
  
  return async (url, options, next) => {
    const urlObj = new URL(url, window.location.origin);
    const endpoint = urlObj.pathname;
    
    const bucket = getOrCreateBucket(endpoint);
    await bucket.consume(1);
    
    return next(url, options);
  };
}

// Usage
const rateLimiter = createPerEndpointRateLimiter({
  '/api/search': { rps: 5 },
  '/api/upload': { rps: 2 },
  default: { rps: 10 }
});
```

### CSRF Protection Middleware

#### Token Injection

```javascript
function createCsrfMiddleware(options = {}) {
  const {
    tokenName = 'csrf_token',
    headerName = 'X-CSRF-Token',
    getToken = () => {
      const meta = document.querySelector(`meta[name="${tokenName}"]`);
      return meta ? meta.content : null;
    },
    methods = ['POST', 'PUT', 'PATCH', 'DELETE']
  } = options;
  
  return {
    request: (url, fetchOptions) => {
      const method = fetchOptions.method?.toUpperCase() || 'GET';
      
      if (!methods.includes(method)) {
        return { url, options: fetchOptions };
      }
      
      const token = getToken();
      
      if (!token) {
        console.warn('CSRF token not found');
        return { url, options: fetchOptions };
      }
      
      const headers = new Headers(fetchOptions.headers);
      headers.set(headerName, token);
      
      return {
        url,
        options: {
          ...fetchOptions,
          headers
        }
      };
    }
  };
}
```

### Base URL Middleware

#### URL Prefix Handler

```javascript
function createBaseUrlMiddleware(baseUrl) {
  return {
    request: (url, options) => {
      // Skip if URL is already absolute
      if (url.startsWith('http://') || url.startsWith('https://')) {
        return { url, options };
      }
      
      // Remove leading slash from relative URL if base URL has trailing slash
      const normalizedUrl = url.startsWith('/') ? url.slice(1) : url;
      const normalizedBase = baseUrl.endsWith('/') ? baseUrl : `${baseUrl}/`;
      
      return {
        url: `${normalizedBase}${normalizedUrl}`,
        options
      };
    }
  };
}

// Usage
const apiClient = createFetchMiddleware([
  createBaseUrlMiddleware('https://api.example.com/v1'),
  authMiddleware,
  loggingMiddleware
]);

const response = await apiClient('users'); // Requests https://api.example.com/v1/users
```

### Request Deduplication Middleware

#### Identical Request Coalescing

```javascript
function createDeduplicationMiddleware() {
  const pending = new Map();
  
  const getCacheKey = (url, options) => {
    const method = options.method || 'GET';
    const body = options.body || '';
    return `${method}:${url}:${body}`;
  };
  
  return async (url, options, next) => {
    const key = getCacheKey(url, options);
    
    // Check if identical request is already in flight
    if (pending.has(key)) {
      return pending.get(key);
    }
    
    // Execute request and store promise
    const promise = next(url, options)
      .then(response => {
        pending.delete(key);
        return response.clone();
      })
      .catch(error => {
        pending.delete(key);
        throw error;
      });
    
    pending.set(key, promise);
    return promise;
  };
}
```

### Circuit Breaker Middleware

#### Failure Threshold Pattern

```javascript
class CircuitBreaker {
  constructor(threshold = 5, timeout = 60000) {
    this.threshold = threshold;
    this.timeout = timeout;
    this.failures = 0;
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
    this.failures = 0;
    this.state = 'CLOSED';
  }
  
  onFailure() {
    this.failures++;
    
    if (this.failures >= this.threshold) {
      this.state = 'OPEN';
      this.nextAttempt = Date.now() + this.timeout;
    }
  }
}

function createCircuitBreakerMiddleware(options = {}) {
  const breakers = new Map();
  
  const getBreaker = (url) => {
    const urlObj = new URL(url, window.location.origin);
    const key = `${urlObj.protocol}//${urlObj.host}`;
    
    if (!breakers.has(key)) {
      breakers.set(key, new CircuitBreaker(
        options.threshold,
        options.timeout
      ));
    }
    
    return breakers.get(key);
  };
  
  return async (url, fetchOptions, next) => {
    const breaker = getBreaker(url);
    
    return breaker.execute(() => next(url, fetchOptions));
  };
}
```

### Header Injection Middleware

#### Custom Headers

```javascript
function createHeadersMiddleware(headers = {}) {
  return {
    request: (url, options) => {
      const mergedHeaders = new Headers(options.headers);
      
      Object.entries(headers).forEach(([key, value]) => {
        if (typeof value === 'function') {
          const computed = value(url, options);
          if (computed) {
            mergedHeaders.set(key, computed);
          }
        } else if (value) {
          mergedHeaders.set(key, value);
        }
      });
      
      return {
        url,
        options: {
          ...options,
          headers: mergedHeaders
        }
      };
    }
  };
}

// Usage
const headersMiddleware = createHeadersMiddleware({
  'X-Client-Version': '1.0.0',
  'X-Request-ID': () => crypto.randomUUID(),
  'X-User-Agent': () => navigator.userAgent
});
```

### Conditional Request Middleware

#### ETag and Last-Modified Support

```javascript
function createConditionalRequestMiddleware() {
  const cache = new Map();
  
  return {
    request: (url, options) => {
      const method = options.method || 'GET';
      
      if (method !== 'GET') {
        return { url, options };
      }
      
      const cached = cache.get(url);
      
      if (!cached) {
        return { url, options };
      }
      
      const headers = new Headers(options.headers);
      
      if (cached.etag) {
        headers.set('If-None-Match', cached.etag);
      }
      
      if (cached.lastModified) {
        headers.set('If-Modified-Since', cached.lastModified);
      }
      
      return {
        url,
        options: { ...options, headers }
      };
    },
    
    response: async (response, url, options) => {
      if (response.status === 304) {
        // Not modified - return cached response
        const cached = cache.get(url);
        return cached.response.clone();
      }
      
      if (response.ok) {
        const etag = response.headers.get('ETag');
        const lastModified = response.headers.get('Last-Modified');
        
        if (etag || lastModified) {
          cache.set(url, {
            response: response.clone(),
            etag,
            lastModified
          });
        }
      }
      
      return response;
    }
  };
}
```

### Middleware Composition Utilities

#### Middleware Pipeline Builder

```javascript
class FetchPipeline {
  constructor() {
    this.middlewares = [];
  }
  
  use(middleware) {
    this.middlewares.push(middleware);
    return this;
  }
  
	group(builder) {
	  const subPipeline = new FetchPipeline();
	  builder(subPipeline);
	  this.middlewares.push(...subPipeline.middlewares);
	  return this;
	}
	
	when(condition, middleware) {
	  this.middlewares.push(
	    async (url, options, next) => {
	      if (condition(url, options)) {
	        return middleware(url, options, next);
	      }
	      return next(url, options);
	    }
	  );
	  return this;
	}
	
	build() {
	  return createFetchMiddleware(this.middlewares);
	}
}

// Usage
const client = new FetchPipeline()
  .use(createBaseUrlMiddleware('https://api.example.com'))
  .use(createHeadersMiddleware({ 'X-Client': 'web' }))
  .group(pipeline => {
    pipeline
      .use(authMiddleware)
      .use(createCsrfMiddleware());
  })
  .when(
    url => url.includes('/api/'),
    createRateLimitMiddleware(10)
  )
  .use(createLoggingMiddleware())
  .build();

```

---

