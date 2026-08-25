## Fallback Strategies


### Retry Logic

#### Basic Retry Implementation

```javascript
async function fetchWithRetry(url, options = {}, maxRetries = 3) {
  let lastError;
  
  for (let i = 0; i < maxRetries; i++) {
    try {
      const response = await fetch(url, options);
      if (!response.ok) throw new Error(`HTTP ${response.status}`);
      return response;
    } catch (error) {
      lastError = error;
      if (i < maxRetries - 1) {
        await new Promise(resolve => setTimeout(resolve, 1000 * (i + 1)));
      }
    }
  }
  
  throw lastError;
}
```

#### Exponential Backoff

Exponential backoff progressively increases wait times between retries to reduce server load and improve success rates:

```javascript
async function fetchWithExponentialBackoff(url, options = {}, config = {}) {
  const {
    maxRetries = 5,
    baseDelay = 1000,
    maxDelay = 32000,
    backoffFactor = 2,
    jitter = true
  } = config;
  
  let lastError;
  
  for (let attempt = 0; attempt < maxRetries; attempt++) {
    try {
      const response = await fetch(url, options);
      if (!response.ok) throw new Error(`HTTP ${response.status}`);
      return response;
    } catch (error) {
      lastError = error;
      
      if (attempt < maxRetries - 1) {
        let delay = Math.min(baseDelay * Math.pow(backoffFactor, attempt), maxDelay);
        
        if (jitter) {
          delay = delay * (0.5 + Math.random() * 0.5);
        }
        
        await new Promise(resolve => setTimeout(resolve, delay));
      }
    }
  }
  
  throw lastError;
}
```

#### Conditional Retry

Not all errors should trigger retries. Implement selective retry logic based on error types:

```javascript
function isRetriableError(error, response) {
  // Network errors
  if (error.name === 'TypeError' || error.message.includes('Failed to fetch')) {
    return true;
  }
  
  // Timeout errors
  if (error.name === 'AbortError') {
    return true;
  }
  
  // Server errors (5xx)
  if (response && response.status >= 500 && response.status < 600) {
    return true;
  }
  
  // Rate limiting
  if (response && response.status === 429) {
    return true;
  }
  
  // Client errors (4xx) should not retry
  if (response && response.status >= 400 && response.status < 500) {
    return false;
  }
  
  return false;
}

async function fetchWithConditionalRetry(url, options = {}, maxRetries = 3) {
  let lastError;
  let lastResponse;
  
  for (let i = 0; i < maxRetries; i++) {
    try {
      const response = await fetch(url, options);
      lastResponse = response;
      
      if (!response.ok) {
        const error = new Error(`HTTP ${response.status}`);
        if (!isRetriableError(error, response)) {
          throw error;
        }
        lastError = error;
      } else {
        return response;
      }
    } catch (error) {
      if (!isRetriableError(error, lastResponse)) {
        throw error;
      }
      lastError = error;
    }
    
    if (i < maxRetries - 1) {
      await new Promise(resolve => setTimeout(resolve, 1000 * (i + 1)));
    }
  }
  
  throw lastError;
}
```

### Multiple Endpoint Fallback

#### Sequential Fallback

Try multiple endpoints in order until one succeeds:

```javascript
async function fetchWithEndpointFallback(endpoints, options = {}) {
  const errors = [];
  
  for (const endpoint of endpoints) {
    try {
      const response = await fetch(endpoint, options);
      if (!response.ok) throw new Error(`HTTP ${response.status}`);
      return response;
    } catch (error) {
      errors.push({ endpoint, error });
    }
  }
  
  throw new Error(`All endpoints failed: ${errors.map(e => e.endpoint).join(', ')}`);
}

// Usage
const endpoints = [
  'https://api.primary.com/data',
  'https://api.backup.com/data',
  'https://api.fallback.com/data'
];

fetchWithEndpointFallback(endpoints);
```

#### Race Strategy

Request from multiple sources simultaneously and use the first successful response:

```javascript
async function fetchWithRace(urls, options = {}) {
  const promises = urls.map(url => 
    fetch(url, options).then(response => {
      if (!response.ok) throw new Error(`HTTP ${response.status}`);
      return response;
    })
  );
  
  return Promise.race(promises);
}
```

#### Parallel with Priority

Request from multiple endpoints with prioritization:

```javascript
async function fetchWithPriorityFallback(endpoints, options = {}) {
  const priorityGroups = endpoints.reduce((groups, endpoint) => {
    const priority = endpoint.priority || 0;
    if (!groups[priority]) groups[priority] = [];
    groups[priority].push(endpoint.url);
    return groups;
  }, {});
  
  const sortedPriorities = Object.keys(priorityGroups).sort((a, b) => b - a);
  
  for (const priority of sortedPriorities) {
    try {
      return await fetchWithRace(priorityGroups[priority], options);
    } catch (error) {
      continue;
    }
  }
  
  throw new Error('All endpoint groups failed');
}

// Usage
const endpoints = [
  { url: 'https://cdn1.example.com/data', priority: 3 },
  { url: 'https://cdn2.example.com/data', priority: 3 },
  { url: 'https://backup.example.com/data', priority: 2 },
  { url: 'https://archive.example.com/data', priority: 1 }
];
```

### Cache-Based Fallback

#### Cache-First Strategy

Attempt to use cached data before making network requests:

```javascript
async function fetchWithCache(url, options = {}, cacheName = 'api-cache') {
  try {
    const cache = await caches.open(cacheName);
    const cachedResponse = await cache.match(url);
    
    if (cachedResponse) {
      // Optionally revalidate in background
      fetch(url, options).then(response => {
        if (response.ok) {
          cache.put(url, response.clone());
        }
      });
      
      return cachedResponse;
    }
    
    const response = await fetch(url, options);
    if (response.ok) {
      cache.put(url, response.clone());
    }
    return response;
  } catch (error) {
    const cache = await caches.open(cacheName);
    const cachedResponse = await cache.match(url);
    if (cachedResponse) {
      return cachedResponse;
    }
    throw error;
  }
}
```

#### Stale-While-Revalidate

Return cached content immediately while updating cache in background:

```javascript
async function fetchStaleWhileRevalidate(url, options = {}, config = {}) {
  const { cacheName = 'swr-cache', maxAge = 3600000 } = config;
  
  const cache = await caches.open(cacheName);
  const cachedResponse = await cache.match(url);
  
  const fetchAndCache = async () => {
    try {
      const response = await fetch(url, options);
      if (response.ok) {
        const responseToCache = response.clone();
        const headers = new Headers(responseToCache.headers);
        headers.set('sw-cache-timestamp', Date.now().toString());
        
        const cachedResponseWithTimestamp = new Response(
          await responseToCache.blob(),
          {
            status: responseToCache.status,
            statusText: responseToCache.statusText,
            headers: headers
          }
        );
        
        cache.put(url, cachedResponseWithTimestamp);
      }
      return response;
    } catch (error) {
      return null;
    }
  };
  
  if (cachedResponse) {
    const timestamp = cachedResponse.headers.get('sw-cache-timestamp');
    const age = Date.now() - parseInt(timestamp || '0');
    
    if (age < maxAge) {
      fetchAndCache();
      return cachedResponse;
    }
  }
  
  return fetchAndCache() || cachedResponse || Promise.reject(new Error('No cached response available'));
}
```

#### Network-First with Cache Fallback

```javascript
async function fetchNetworkFirstWithCache(url, options = {}, config = {}) {
  const { cacheName = 'network-first-cache', timeout = 5000 } = config;
  
  try {
    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), timeout);
    
    const response = await fetch(url, {
      ...options,
      signal: controller.signal
    });
    
    clearTimeout(timeoutId);
    
    if (response.ok) {
      const cache = await caches.open(cacheName);
      cache.put(url, response.clone());
      return response;
    }
    
    throw new Error(`HTTP ${response.status}`);
  } catch (error) {
    const cache = await caches.open(cacheName);
    const cachedResponse = await cache.match(url);
    
    if (cachedResponse) {
      return cachedResponse;
    }
    
    throw error;
  }
}
```

### Local Storage Fallback

Use localStorage or IndexedDB as a fallback when both network and cache fail:

```javascript
async function fetchWithLocalStorageFallback(url, options = {}, config = {}) {
  const { storageKey = `fetch_${url}`, maxAge = 86400000 } = config;
  
  try {
    const response = await fetch(url, options);
    
    if (response.ok) {
      const data = await response.json();
      localStorage.setItem(storageKey, JSON.stringify({
        data,
        timestamp: Date.now()
      }));
      
      return new Response(JSON.stringify(data), {
        status: 200,
        headers: { 'Content-Type': 'application/json' }
      });
    }
    
    throw new Error(`HTTP ${response.status}`);
  } catch (error) {
    const stored = localStorage.getItem(storageKey);
    
    if (stored) {
      const { data, timestamp } = JSON.parse(stored);
      const age = Date.now() - timestamp;
      
      if (age < maxAge) {
        return new Response(JSON.stringify(data), {
          status: 200,
          headers: { 
            'Content-Type': 'application/json',
            'X-From-Cache': 'localStorage'
          }
        });
      }
    }
    
    throw error;
  }
}
```

### Timeout Handling

#### Basic Timeout

```javascript
async function fetchWithTimeout(url, options = {}, timeout = 5000) {
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
      throw new Error(`Request timeout after ${timeout}ms`);
    }
    throw error;
  }
}
```

#### Progressive Timeout

Increase timeout on retries:

```javascript
async function fetchWithProgressiveTimeout(url, options = {}, config = {}) {
  const { 
    maxRetries = 3, 
    initialTimeout = 3000,
    timeoutMultiplier = 1.5 
  } = config;
  
  let lastError;
  
  for (let i = 0; i < maxRetries; i++) {
    const timeout = initialTimeout * Math.pow(timeoutMultiplier, i);
    
    try {
      return await fetchWithTimeout(url, options, timeout);
    } catch (error) {
      lastError = error;
      if (i < maxRetries - 1) {
        await new Promise(resolve => setTimeout(resolve, 1000));
      }
    }
  }
  
  throw lastError;
}
```

### Degraded Mode

Provide reduced functionality when primary service fails:

```javascript
async function fetchWithDegradedMode(url, options = {}, config = {}) {
  const { degradedEndpoint, degradedTransform } = config;
  
  try {
    const response = await fetch(url, options);
    if (!response.ok) throw new Error(`HTTP ${response.status}`);
    return response;
  } catch (error) {
    if (degradedEndpoint) {
      try {
        const degradedResponse = await fetch(degradedEndpoint, options);
        
        if (degradedResponse.ok && degradedTransform) {
          const data = await degradedResponse.json();
          const transformedData = degradedTransform(data);
          
          return new Response(JSON.stringify(transformedData), {
            status: 200,
            headers: { 
              'Content-Type': 'application/json',
              'X-Degraded-Mode': 'true'
            }
          });
        }
        
        return degradedResponse;
      } catch (degradedError) {
        throw error;
      }
    }
    throw error;
  }
}

// Usage
fetchWithDegradedMode('https://api.example.com/full-data', {}, {
  degradedEndpoint: 'https://api.example.com/minimal-data',
  degradedTransform: (minimalData) => ({
    ...minimalData,
    limited: true,
    message: 'Operating in reduced functionality mode'
  })
});
```

### Circuit Breaker Pattern

Temporarily stop requests to failing services:

```javascript
class CircuitBreaker {
  constructor(config = {}) {
    this.failureThreshold = config.failureThreshold || 5;
    this.resetTimeout = config.resetTimeout || 60000;
    this.monitoringPeriod = config.monitoringPeriod || 10000;
    
    this.state = 'CLOSED'; // CLOSED, OPEN, HALF_OPEN
    this.failures = 0;
    this.successes = 0;
    this.nextAttempt = Date.now();
    this.failureTimestamps = [];
  }
  
  async execute(url, options = {}) {
    if (this.state === 'OPEN') {
      if (Date.now() < this.nextAttempt) {
        throw new Error('Circuit breaker is OPEN');
      }
      this.state = 'HALF_OPEN';
    }
    
    try {
      const response = await fetch(url, options);
      
      if (!response.ok) {
        throw new Error(`HTTP ${response.status}`);
      }
      
      this.onSuccess();
      return response;
    } catch (error) {
      this.onFailure();
      throw error;
    }
  }
  
  onSuccess() {
    this.failures = 0;
    this.failureTimestamps = [];
    
    if (this.state === 'HALF_OPEN') {
      this.successes++;
      if (this.successes >= 2) {
        this.state = 'CLOSED';
        this.successes = 0;
      }
    }
  }
  
  onFailure() {
    const now = Date.now();
    this.failures++;
    this.failureTimestamps.push(now);
    
    // Remove old timestamps outside monitoring period
    this.failureTimestamps = this.failureTimestamps.filter(
      timestamp => now - timestamp < this.monitoringPeriod
    );
    
    if (this.failureTimestamps.length >= this.failureThreshold) {
      this.state = 'OPEN';
      this.nextAttempt = now + this.resetTimeout;
      this.successes = 0;
    } else if (this.state === 'HALF_OPEN') {
      this.state = 'OPEN';
      this.nextAttempt = now + this.resetTimeout;
      this.successes = 0;
    }
  }
  
  getState() {
    return {
      state: this.state,
      failures: this.failures,
      failureTimestamps: this.failureTimestamps.length,
      nextAttempt: this.state === 'OPEN' ? new Date(this.nextAttempt) : null
    };
  }
}

// Usage
const breaker = new CircuitBreaker({
  failureThreshold: 5,
  resetTimeout: 30000,
  monitoringPeriod: 10000
});

async function fetchWithCircuitBreaker(url, options = {}) {
  try {
    return await breaker.execute(url, options);
  } catch (error) {
    if (error.message === 'Circuit breaker is OPEN') {
      // Use cached data or show error message
      return getCachedData(url);
    }
    throw error;
  }
}
```

### Composite Strategy

Combine multiple fallback strategies:

```javascript
async function fetchWithCompositeFallback(url, options = {}, config = {}) {
  const {
    maxRetries = 3,
    timeout = 5000,
    fallbackEndpoints = [],
    cacheName = 'composite-cache',
    useCircuitBreaker = true,
    circuitBreaker = null
  } = config;
  
  const allEndpoints = [url, ...fallbackEndpoints];
  
  for (const endpoint of allEndpoints) {
    // Try with retries and timeout
    for (let attempt = 0; attempt < maxRetries; attempt++) {
      try {
        let response;
        
        if (useCircuitBreaker && circuitBreaker) {
          response = await circuitBreaker.execute(endpoint, options);
        } else {
          response = await fetchWithTimeout(endpoint, options, timeout);
        }
        
        if (response.ok) {
          // Cache successful response
          const cache = await caches.open(cacheName);
          cache.put(url, response.clone());
          return response;
        }
      } catch (error) {
        if (attempt === maxRetries - 1) {
          continue; // Try next endpoint
        }
        await new Promise(resolve => 
          setTimeout(resolve, 1000 * Math.pow(2, attempt))
        );
      }
    }
  }
  
  // All endpoints failed, try cache
  try {
    const cache = await caches.open(cacheName);
    const cachedResponse = await cache.match(url);
    if (cachedResponse) {
      return cachedResponse;
    }
  } catch (cacheError) {
    // Cache also failed
  }
  
  // Try localStorage as last resort
  const storageKey = `fetch_${url}`;
  const stored = localStorage.getItem(storageKey);
  if (stored) {
    const { data } = JSON.parse(stored);
    return new Response(JSON.stringify(data), {
      status: 200,
      headers: { 
        'Content-Type': 'application/json',
        'X-From-Storage': 'localStorage'
      }
    });
  }
  
  throw new Error('All fallback strategies exhausted');
}
```

### Error Recovery Queue

Queue failed requests for later retry:

```javascript
class FetchQueue {
  constructor() {
    this.queue = [];
    this.processing = false;
    this.retryInterval = 30000;
  }
  
  async add(url, options = {}) {
    const id = Date.now() + Math.random();
    this.queue.push({ id, url, options, attempts: 0 });
    
    if (!this.processing) {
      this.processQueue();
    }
    
    return id;
  }
  
  async processQueue() {
    this.processing = true;
    
    while (this.queue.length > 0) {
      const item = this.queue[0];
      
      try {
        const response = await fetch(item.url, item.options);
        
        if (response.ok) {
          this.queue.shift();
          continue;
        }
      } catch (error) {
        item.attempts++;
      }
      
      if (item.attempts >= 5) {
        this.queue.shift();
      } else {
        await new Promise(resolve => setTimeout(resolve, this.retryInterval));
      }
    }
    
    this.processing = false;
  }
  
  remove(id) {
    this.queue = this.queue.filter(item => item.id !== id);
  }
  
  getStatus() {
    return {
      queueLength: this.queue.length,
      processing: this.processing,
      items: this.queue.map(({ id, url, attempts }) => ({ id, url, attempts }))
    };
  }
}

const fetchQueue = new FetchQueue();

async function fetchWithQueue(url, options = {}) {
  try {
    const response = await fetch(url, options);
    if (!response.ok) throw new Error(`HTTP ${response.status}`);
    return response;
  } catch (error) {
    // Add to queue for later retry
    await fetchQueue.add(url, options);
    throw error;
  }
}
```

---

