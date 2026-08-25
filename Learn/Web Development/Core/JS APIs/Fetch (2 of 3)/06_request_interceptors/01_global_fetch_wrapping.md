## Global Fetch Wrapping


### Basic Fetch Wrapper Implementation

A global fetch wrapper intercepts all fetch calls to add common functionality like authentication, logging, error handling, and request/response transformation.

```javascript
const originalFetch = window.fetch;

window.fetch = function(...args) {
  console.log('Fetch intercepted:', args[0]);
  
  // Call original fetch
  return originalFetch.apply(this, args)
    .then(response => {
      console.log('Response received:', response.status);
      return response;
    });
};
```

### Comprehensive Fetch Wrapper Class

```javascript
class FetchWrapper {
  constructor(config = {}) {
    this.config = {
      baseURL: config.baseURL || '',
      headers: config.headers || {},
      timeout: config.timeout || 30000,
      retries: config.retries || 0,
      retryDelay: config.retryDelay || 1000,
      interceptors: {
        request: config.interceptors?.request || [],
        response: config.interceptors?.response || []
      }
    };
    
    this.originalFetch = window.fetch;
  }
  
  install() {
    const self = this;
    
    window.fetch = function(url, options = {}) {
      return self.fetch(url, options);
    };
  }
  
  uninstall() {
    window.fetch = this.originalFetch;
  }
  
  async fetch(url, options = {}) {
    // Build full URL
    const fullURL = this.buildURL(url);
    
    // Merge options
    const mergedOptions = this.mergeOptions(options);
    
    // Apply request interceptors
    let requestConfig = { url: fullURL, options: mergedOptions };
    for (const interceptor of this.config.interceptors.request) {
      requestConfig = await interceptor(requestConfig);
    }
    
    // Execute fetch with retry logic
    let lastError;
    for (let attempt = 0; attempt <= this.config.retries; attempt++) {
      try {
        const response = await this.executeWithTimeout(
          requestConfig.url,
          requestConfig.options
        );
        
        // Apply response interceptors
        let finalResponse = response;
        for (const interceptor of this.config.interceptors.response) {
          finalResponse = await interceptor(finalResponse, requestConfig);
        }
        
        return finalResponse;
      } catch (error) {
        lastError = error;
        
        if (attempt < this.config.retries) {
          await this.delay(this.config.retryDelay * Math.pow(2, attempt));
        }
      }
    }
    
    throw lastError;
  }
  
  buildURL(url) {
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }
    
    const base = this.config.baseURL.replace(/\/$/, '');
    const path = url.startsWith('/') ? url : `/${url}`;
    return `${base}${path}`;
  }
  
  mergeOptions(options) {
    return {
      ...options,
      headers: {
        ...this.config.headers,
        ...options.headers
      }
    };
  }
  
  async executeWithTimeout(url, options) {
    const controller = new AbortController();
    const timeoutId = setTimeout(
      () => controller.abort(),
      this.config.timeout
    );
    
    try {
      const response = await this.originalFetch(url, {
        ...options,
        signal: controller.signal
      });
      
      return response;
    } finally {
      clearTimeout(timeoutId);
    }
  }
  
  delay(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
  }
}

// Usage
const wrapper = new FetchWrapper({
  baseURL: 'https://api.example.com',
  headers: {
    'Content-Type': 'application/json'
  },
  timeout: 10000,
  retries: 3
});

wrapper.install();
```

### Request Interceptors

```javascript
// Add authentication token
wrapper.config.interceptors.request.push(async (config) => {
  const token = localStorage.getItem('authToken');
  
  if (token) {
    config.options.headers = {
      ...config.options.headers,
      'Authorization': `Bearer ${token}`
    };
  }
  
  return config;
});

// Add request ID for tracking
wrapper.config.interceptors.request.push(async (config) => {
  const requestId = `req_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
  
  config.options.headers = {
    ...config.options.headers,
    'X-Request-ID': requestId
  };
  
  config.requestId = requestId;
  return config;
});

// Log requests
wrapper.config.interceptors.request.push(async (config) => {
  console.log('Request:', {
    url: config.url,
    method: config.options.method || 'GET',
    headers: config.options.headers
  });
  
  return config;
});

// Transform request body
wrapper.config.interceptors.request.push(async (config) => {
  if (config.options.body && typeof config.options.body === 'object') {
    // Only transform if not FormData or other special types
    if (!(config.options.body instanceof FormData)) {
      config.options.body = JSON.stringify(config.options.body);
      config.options.headers = {
        ...config.options.headers,
        'Content-Type': 'application/json'
      };
    }
  }
  
  return config;
});
```

### Response Interceptors

```javascript
// Handle HTTP errors
wrapper.config.interceptors.response.push(async (response, requestConfig) => {
  if (!response.ok) {
    const error = new Error(`HTTP ${response.status}: ${response.statusText}`);
    error.response = response;
    error.status = response.status;
    
    // Try to parse error body
    try {
      const contentType = response.headers.get('content-type');
      if (contentType?.includes('application/json')) {
        error.data = await response.clone().json();
      } else {
        error.data = await response.clone().text();
      }
    } catch (e) {
      // Ignore parse errors
    }
    
    throw error;
  }
  
  return response;
});

// Auto-parse JSON responses
wrapper.config.interceptors.response.push(async (response) => {
  const contentType = response.headers.get('content-type');
  
  if (contentType?.includes('application/json')) {
    const clonedResponse = response.clone();
    const data = await clonedResponse.json();
    
    // Attach parsed data to response object
    response.data = data;
  }
  
  return response;
});

// Log responses
wrapper.config.interceptors.response.push(async (response, requestConfig) => {
  console.log('Response:', {
    requestId: requestConfig.requestId,
    status: response.status,
    url: requestConfig.url
  });
  
  return response;
});

// Handle token refresh
wrapper.config.interceptors.response.push(async (response, requestConfig) => {
  if (response.status === 401) {
    const refreshToken = localStorage.getItem('refreshToken');
    
    if (refreshToken) {
      try {
        // Refresh token
        const refreshResponse = await originalFetch('/auth/refresh', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ refreshToken })
        });
        
        const { token } = await refreshResponse.json();
        localStorage.setItem('authToken', token);
        
        // Retry original request with new token
        requestConfig.options.headers.Authorization = `Bearer ${token}`;
        return await originalFetch(requestConfig.url, requestConfig.options);
      } catch (error) {
        // Refresh failed, logout user
        localStorage.removeItem('authToken');
        localStorage.removeItem('refreshToken');
        window.location.href = '/login';
      }
    }
  }
  
  return response;
});
```

### Advanced Wrapper with Middleware Pattern

```javascript
class EnhancedFetchWrapper {
  constructor() {
    this.middlewares = [];
    this.originalFetch = window.fetch;
  }
  
  use(middleware) {
    this.middlewares.push(middleware);
    return this;
  }
  
  install() {
    const self = this;
    
    window.fetch = async function(url, options = {}) {
      return self.executeMiddlewareChain(url, options);
    };
  }
  
  async executeMiddlewareChain(url, options) {
    let index = 0;
    
    const next = async () => {
      if (index >= this.middlewares.length) {
        return this.originalFetch(url, options);
      }
      
      const middleware = this.middlewares[index++];
      return middleware({ url, options }, next);
    };
    
    return next();
  }
  
  uninstall() {
    window.fetch = this.originalFetch;
  }
}

// Usage with middlewares
const wrapper = new EnhancedFetchWrapper();

// Logging middleware
wrapper.use(async (context, next) => {
  console.log('→', context.options.method || 'GET', context.url);
  const startTime = Date.now();
  
  const response = await next();
  
  console.log('←', response.status, `${Date.now() - startTime}ms`);
  return response;
});

// Authentication middleware
wrapper.use(async (context, next) => {
  const token = localStorage.getItem('authToken');
  
  if (token) {
    context.options.headers = {
      ...context.options.headers,
      'Authorization': `Bearer ${token}`
    };
  }
  
  return next();
});

// Error handling middleware
wrapper.use(async (context, next) => {
  try {
    const response = await next();
    
    if (!response.ok) {
      throw new Error(`HTTP ${response.status}`);
    }
    
    return response;
  } catch (error) {
    console.error('Fetch error:', error);
    throw error;
  }
});

wrapper.install();
```

### Caching Wrapper

```javascript
class CachingFetchWrapper {
  constructor(config = {}) {
    this.cache = new Map();
    this.config = {
      ttl: config.ttl || 60000, // 1 minute default
      maxSize: config.maxSize || 100
    };
    this.originalFetch = window.fetch;
  }
  
  getCacheKey(url, options) {
    const method = options.method || 'GET';
    const body = options.body || '';
    return `${method}:${url}:${body}`;
  }
  
  install() {
    const self = this;
    
    window.fetch = async function(url, options = {}) {
      // Only cache GET requests
      if ((options.method || 'GET').toUpperCase() !== 'GET') {
        return self.originalFetch(url, options);
      }
      
      const cacheKey = self.getCacheKey(url, options);
      const cached = self.cache.get(cacheKey);
      
      if (cached && Date.now() - cached.timestamp < self.config.ttl) {
        console.log('Cache hit:', url);
        // Return cloned response
        return new Response(cached.body, {
          status: cached.status,
          statusText: cached.statusText,
          headers: cached.headers
        });
      }
      
      console.log('Cache miss:', url);
      const response = await self.originalFetch(url, options);
      
      // Clone and cache successful responses
      if (response.ok) {
        const cloned = response.clone();
        const body = await cloned.blob();
        
        self.cache.set(cacheKey, {
          body,
          status: response.status,
          statusText: response.statusText,
          headers: new Headers(response.headers),
          timestamp: Date.now()
        });
        
        // Enforce cache size limit
        if (self.cache.size > self.config.maxSize) {
          const firstKey = self.cache.keys().next().value;
          self.cache.delete(firstKey);
        }
      }
      
      return response;
    };
  }
  
  clearCache() {
    this.cache.clear();
  }
  
  invalidate(pattern) {
    for (const key of this.cache.keys()) {
      if (key.includes(pattern)) {
        this.cache.delete(key);
      }
    }
  }
  
  uninstall() {
    window.fetch = this.originalFetch;
  }
}

// Usage
const cachingWrapper = new CachingFetchWrapper({
  ttl: 300000, // 5 minutes
  maxSize: 50
});

cachingWrapper.install();

// Clear specific cache entries
cachingWrapper.invalidate('/api/users');
```

### Request Queue and Rate Limiting

```javascript
class RateLimitedFetchWrapper {
  constructor(config = {}) {
    this.config = {
      maxConcurrent: config.maxConcurrent || 6,
      requestsPerSecond: config.requestsPerSecond || 10
    };
    
    this.queue = [];
    this.activeRequests = 0;
    this.requestTimestamps = [];
    this.originalFetch = window.fetch;
  }
  
  install() {
    const self = this;
    
    window.fetch = function(url, options = {}) {
      return self.enqueue(url, options);
    };
  }
  
  enqueue(url, options) {
    return new Promise((resolve, reject) => {
      this.queue.push({ url, options, resolve, reject });
      this.processQueue();
    });
  }
  
  async processQueue() {
    if (this.activeRequests >= this.config.maxConcurrent) {
      return;
    }
    
    if (this.queue.length === 0) {
      return;
    }
    
    // Check rate limit
    const now = Date.now();
    this.requestTimestamps = this.requestTimestamps.filter(
      ts => now - ts < 1000
    );
    
    if (this.requestTimestamps.length >= this.config.requestsPerSecond) {
      // Wait before processing next request
      const oldestTimestamp = this.requestTimestamps[0];
      const delay = 1000 - (now - oldestTimestamp);
      
      setTimeout(() => this.processQueue(), delay);
      return;
    }
    
    const item = this.queue.shift();
    this.activeRequests++;
    this.requestTimestamps.push(now);
    
    try {
      const response = await this.originalFetch(item.url, item.options);
      item.resolve(response);
    } catch (error) {
      item.reject(error);
    } finally {
      this.activeRequests--;
      this.processQueue();
    }
  }
  
  uninstall() {
    window.fetch = this.originalFetch;
  }
}

// Usage
const rateLimitedWrapper = new RateLimitedFetchWrapper({
  maxConcurrent: 3,
  requestsPerSecond: 5
});

rateLimitedWrapper.install();
```

### Mock/Stub Wrapper for Testing

```javascript
class MockFetchWrapper {
  constructor() {
    this.mocks = new Map();
    this.originalFetch = window.fetch;
  }
  
  mock(pattern, handler) {
    this.mocks.set(pattern, handler);
  }
  
  mockOnce(pattern, handler) {
    const wrappedHandler = async (...args) => {
      this.mocks.delete(pattern);
      return handler(...args);
    };
    
    this.mocks.set(pattern, wrappedHandler);
  }
  
  install() {
    const self = this;
    
    window.fetch = async function(url, options = {}) {
      // Check for matching mock
      for (const [pattern, handler] of self.mocks) {
        const matches = typeof pattern === 'string' 
          ? url.includes(pattern)
          : pattern.test(url);
        
        if (matches) {
          console.log('Mock matched:', pattern);
          return handler(url, options);
        }
      }
      
      // No mock found, use original fetch
      return self.originalFetch(url, options);
    };
  }
  
  clearMocks() {
    this.mocks.clear();
  }
  
  uninstall() {
    window.fetch = this.originalFetch;
  }
}

// Usage
const mockWrapper = new MockFetchWrapper();

// Mock successful response
mockWrapper.mock('/api/users', async (url, options) => {
  return new Response(JSON.stringify([
    { id: 1, name: 'John' },
    { id: 2, name: 'Jane' }
  ]), {
    status: 200,
    headers: { 'Content-Type': 'application/json' }
  });
});

// Mock error response
mockWrapper.mock('/api/error', async () => {
  return new Response(JSON.stringify({ error: 'Not found' }), {
    status: 404,
    headers: { 'Content-Type': 'application/json' }
  });
});

// Mock with regex pattern
mockWrapper.mock(/\/api\/users\/\d+/, async (url) => {
  const id = url.match(/\/api\/users\/(\d+)/)[1];
  return new Response(JSON.stringify({ id, name: `User ${id}` }), {
    status: 200,
    headers: { 'Content-Type': 'application/json' }
  });
});

mockWrapper.install();
```

### Analytics and Monitoring Wrapper

```javascript
class AnalyticsFetchWrapper {
  constructor() {
    this.metrics = {
      totalRequests: 0,
      successfulRequests: 0,
      failedRequests: 0,
      requestsByEndpoint: new Map(),
      averageResponseTime: 0,
      slowRequests: []
    };
    
    this.originalFetch = window.fetch;
  }
  
  install() {
    const self = this;
    
    window.fetch = async function(url, options = {}) {
      const startTime = performance.now();
      const endpoint = self.getEndpoint(url);
      
      self.metrics.totalRequests++;
      
      // Track endpoint usage
      const endpointCount = self.metrics.requestsByEndpoint.get(endpoint) || 0;
      self.metrics.requestsByEndpoint.set(endpoint, endpointCount + 1);
      
      try {
        const response = await self.originalFetch(url, options);
        const duration = performance.now() - startTime;
        
        if (response.ok) {
          self.metrics.successfulRequests++;
        } else {
          self.metrics.failedRequests++;
        }
        
        // Track slow requests
        if (duration > 3000) {
          self.metrics.slowRequests.push({
            url,
            duration,
            timestamp: Date.now()
          });
          
          // Keep only last 50 slow requests
          if (self.metrics.slowRequests.length > 50) {
            self.metrics.slowRequests.shift();
          }
        }
        
        // Update average response time
        self.updateAverageResponseTime(duration);
        
        // Send analytics
        self.sendAnalytics({
          url,
          method: options.method || 'GET',
          status: response.status,
          duration
        });
        
        return response;
      } catch (error) {
        self.metrics.failedRequests++;
        
        self.sendAnalytics({
          url,
          method: options.method || 'GET',
          error: error.message,
          duration: performance.now() - startTime
        });
        
        throw error;
      }
    };
  }
  
  getEndpoint(url) {
    try {
      const urlObj = new URL(url, window.location.origin);
      return urlObj.pathname;
    } catch (e) {
      return url;
    }
  }
  
  updateAverageResponseTime(duration) {
    const total = this.metrics.totalRequests;
    const current = this.metrics.averageResponseTime;
    
    this.metrics.averageResponseTime = 
      (current * (total - 1) + duration) / total;
  }
  
  sendAnalytics(data) {
    // Send to analytics service
    console.log('Analytics:', data);
    
    // Example: Send to external service
    // navigator.sendBeacon('/analytics', JSON.stringify(data));
  }
  
  getMetrics() {
    return {
      ...this.metrics,
      successRate: this.metrics.totalRequests > 0
        ? (this.metrics.successfulRequests / this.metrics.totalRequests) * 100
        : 0,
      requestsByEndpoint: Object.fromEntries(this.metrics.requestsByEndpoint)
    };
  }
  
  resetMetrics() {
    this.metrics = {
      totalRequests: 0,
      successfulRequests: 0,
      failedRequests: 0,
      requestsByEndpoint: new Map(),
      averageResponseTime: 0,
      slowRequests: []
    };
  }
  
  uninstall() {
    window.fetch = this.originalFetch;
  }
}

// Usage
const analyticsWrapper = new AnalyticsFetchWrapper();
analyticsWrapper.install();

// Get metrics
console.log(analyticsWrapper.getMetrics());
```

### Composable Wrapper System

```javascript
class FetchWrapperComposer {
  constructor() {
    this.wrappers = [];
    this.originalFetch = window.fetch;
  }
  
  addWrapper(wrapper) {
    this.wrappers.push(wrapper);
    return this;
  }
  
  install() {
    let currentFetch = this.originalFetch;
    
    // Apply wrappers in reverse order so first added is outermost
    for (let i = this.wrappers.length - 1; i >= 0; i--) {
      const wrapper = this.wrappers[i];
      const previousFetch = currentFetch;
      
      currentFetch = function(url, options) {
        return wrapper(url, options, previousFetch);
      };
    }
    
    window.fetch = currentFetch;
  }
  
  uninstall() {
    window.fetch = this.originalFetch;
  }
}

// Define individual wrapper functions
function loggingWrapper(url, options, next) {
  console.log('→', options.method || 'GET', url);
  return next(url, options).then(response => {
    console.log('←', response.status);
    return response;
  });
}

function authWrapper(url, options, next) {
  const token = localStorage.getItem('authToken');
  
  if (token) {
    options = {
      ...options,
      headers: {
        ...options.headers,
        'Authorization': `Bearer ${token}`
      }
    };
  }
  
  return next(url, options);
}

function errorHandlingWrapper(url, options, next) {
  return next(url, options).then(response => {
    if (!response.ok) {
      throw new Error(`HTTP ${response.status}: ${response.statusText}`);
    }
    return response;
  });
}

// Compose wrappers
const composer = new FetchWrapperComposer();
composer
  .addWrapper(loggingWrapper)
  .addWrapper(authWrapper)
  .addWrapper(errorHandlingWrapper)
  .install();
```

### Typed Wrapper with TypeScript Support

```javascript
class TypedFetchWrapper {
  constructor() {
    this.originalFetch = window.fetch;
  }
  
  install() {
    const self = this;
    
    window.fetch = function(url, options = {}) {
      return self.typedFetch(url, options);
    };
  }
  
  async typedFetch(url, options) {
    const response = await this.originalFetch(url, options);
    
    // Add type-safe methods
    response.json = async function() {
      const data = await Response.prototype.json.call(this);
      return data;
    };
    
    response.typedJson = async function(validator) {
      const data = await Response.prototype.json.call(this);
      
      if (validator && !validator(data)) {
        throw new Error('Response data validation failed');
      }
      
      return data;
    };
    
    return response;
  }
  
  uninstall() {
    window.fetch = this.originalFetch;
  }
}

// Usage
const typedWrapper = new TypedFetchWrapper();
typedWrapper.install();

// With validation
const response = await fetch('/api/user/1');
const user = await response.typedJson((data) => {
  return data && typeof data.id === 'number' && typeof data.name === 'string';
});
```

### Environment-Aware Wrapper

```javascript
class EnvironmentFetchWrapper {
  constructor(config = {}) {
    this.environments = config.environments || {
      development: 'http://localhost:3000',
      staging: 'https://staging.example.com',
      production: 'https://api.example.com'
    };
    
    this.currentEnv = config.currentEnv || 'production';
    this.originalFetch = window.fetch;
  }
  
  install() {
    const self = this;
    
    window.fetch = function(url, options = {}) {
      const fullURL = self.resolveURL(url);
      return self.originalFetch(fullURL, options);
    };
  }
  
  resolveURL(url) {
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }
    
    const baseURL = this.environments[this.currentEnv];
    const path = url.startsWith('/') ? url : `/${url}`;
    
    return `${baseURL}${path}`;
  }
  
  setEnvironment(env) {
    if (this.environments[env]) {
      this.currentEnv = env;
    }
  }
  
  uninstall() {
    window.fetch = this.originalFetch;
  }
}

// Usage
const envWrapper = new EnvironmentFetchWrapper({
  environments: {
    development: 'http://localhost:3000',
    staging: 'https://staging-api.example.com',
    production: 'https://api.example.com'
  },
  currentEnv: process.env.NODE_ENV || 'production'
});

envWrapper.install();

// Switch environment
envWrapper.setEnvironment('development');
```

---

