## Debouncing and Throttling for Fetch API


### Core Concepts

**Debouncing** delays function execution until after a specified time period has passed since the last invocation. Each new call resets the timer. This ensures the function executes only once after activity stops.

**Throttling** limits function execution to once per specified time interval, regardless of how many times it's called. The first call executes immediately, then subsequent calls are ignored until the interval expires.

### Debouncing Implementation

#### Basic Debounce Function

```javascript
function debounce(func, delay) {
  let timeoutId;
  
  return function(...args) {
    clearTimeout(timeoutId);
    timeoutId = setTimeout(() => {
      func.apply(this, args);
    }, delay);
  };
}
```

#### Immediate Execution Variant

```javascript
function debounce(func, delay, immediate = false) {
  let timeoutId;
  
  return function(...args) {
    const callNow = immediate && !timeoutId;
    
    clearTimeout(timeoutId);
    timeoutId = setTimeout(() => {
      timeoutId = null;
      if (!immediate) {
        func.apply(this, args);
      }
    }, delay);
    
    if (callNow) {
      func.apply(this, args);
    }
  };
}
```

#### Cancelable Debounce

```javascript
function debounce(func, delay) {
  let timeoutId;
  
  const debounced = function(...args) {
    clearTimeout(timeoutId);
    timeoutId = setTimeout(() => {
      func.apply(this, args);
    }, delay);
  };
  
  debounced.cancel = function() {
    clearTimeout(timeoutId);
  };
  
  return debounced;
}
```

### Throttling Implementation

#### Basic Throttle Function

```javascript
function throttle(func, limit) {
  let inThrottle;
  
  return function(...args) {
    if (!inThrottle) {
      func.apply(this, args);
      inThrottle = true;
      setTimeout(() => {
        inThrottle = false;
      }, limit);
    }
  };
}
```

#### Leading and Trailing Edge Control

```javascript
function throttle(func, limit, options = {}) {
  let timeoutId;
  let lastRan;
  const { leading = true, trailing = true } = options;
  
  return function(...args) {
    const now = Date.now();
    
    if (!lastRan && !leading) {
      lastRan = now;
    }
    
    const remaining = limit - (now - lastRan);
    
    if (remaining <= 0 || remaining > limit) {
      if (timeoutId) {
        clearTimeout(timeoutId);
        timeoutId = null;
      }
      lastRan = now;
      func.apply(this, args);
    } else if (!timeoutId && trailing) {
      timeoutId = setTimeout(() => {
        lastRan = leading ? Date.now() : 0;
        timeoutId = null;
        func.apply(this, args);
      }, remaining);
    }
  };
}
```

### Fetch API Integration Patterns

#### Debounced Search Request

```javascript
const searchAPI = async (query) => {
  const response = await fetch(`/api/search?q=${encodeURIComponent(query)}`);
  return response.json();
};

const debouncedSearch = debounce(searchAPI, 300);

// Usage
searchInput.addEventListener('input', (e) => {
  debouncedSearch(e.target.value)
    .then(results => displayResults(results))
    .catch(err => console.error(err));
});
```

#### Throttled Infinite Scroll

```javascript
const loadMoreItems = async () => {
  const response = await fetch(`/api/items?page=${currentPage}`);
  const items = await response.json();
  appendItems(items);
  currentPage++;
};

const throttledLoad = throttle(loadMoreItems, 1000);

window.addEventListener('scroll', () => {
  if (window.innerHeight + window.scrollY >= document.body.offsetHeight - 500) {
    throttledLoad();
  }
});
```

#### Debounced Autocomplete

```javascript
const fetchSuggestions = async (input) => {
  if (input.length < 2) return [];
  
  const response = await fetch(`/api/autocomplete?q=${encodeURIComponent(input)}`);
  return response.json();
};

const debouncedFetchSuggestions = debounce(async (input) => {
  try {
    const suggestions = await fetchSuggestions(input);
    updateSuggestionsList(suggestions);
  } catch (error) {
    console.error('Autocomplete error:', error);
  }
}, 250);
```

### AbortController Integration

#### Debounced Fetch with Cancellation

```javascript
function createDebouncedFetch(delay) {
  let timeoutId;
  let controller;
  
  return function(url, options = {}) {
    clearTimeout(timeoutId);
    
    if (controller) {
      controller.abort();
    }
    
    controller = new AbortController();
    
    return new Promise((resolve, reject) => {
      timeoutId = setTimeout(async () => {
        try {
          const response = await fetch(url, {
            ...options,
            signal: controller.signal
          });
          resolve(response);
        } catch (error) {
          if (error.name === 'AbortError') {
            reject(new Error('Request cancelled'));
          } else {
            reject(error);
          }
        }
      }, delay);
    });
  };
}

// Usage
const debouncedFetch = createDebouncedFetch(300);

searchInput.addEventListener('input', async (e) => {
  try {
    const response = await debouncedFetch(`/api/search?q=${e.target.value}`);
    const data = await response.json();
    displayResults(data);
  } catch (error) {
    if (error.message !== 'Request cancelled') {
      console.error(error);
    }
  }
});
```

#### Throttled Fetch with Request Queuing

```javascript
function createThrottledFetch(limit) {
  let lastRequest = 0;
  let pendingRequest = null;
  
  return async function(url, options = {}) {
    const now = Date.now();
    const timeSinceLastRequest = now - lastRequest;
    
    if (timeSinceLastRequest >= limit) {
      lastRequest = now;
      return fetch(url, options);
    }
    
    if (pendingRequest) {
      return pendingRequest;
    }
    
    pendingRequest = new Promise((resolve) => {
      setTimeout(() => {
        lastRequest = Date.now();
        pendingRequest = null;
        resolve(fetch(url, options));
      }, limit - timeSinceLastRequest);
    });
    
    return pendingRequest;
  };
}
```

### Advanced Patterns

#### Promise-Aware Debounce

```javascript
function debounceAsync(func, delay) {
  let timeoutId;
  let latestResolve;
  let latestReject;
  
  return function(...args) {
    clearTimeout(timeoutId);
    
    return new Promise((resolve, reject) => {
      latestResolve = resolve;
      latestReject = reject;
      
      timeoutId = setTimeout(async () => {
        try {
          const result = await func.apply(this, args);
          latestResolve(result);
        } catch (error) {
          latestReject(error);
        }
      }, delay);
    });
  };
}

// Usage
const searchAPI = debounceAsync(async (query) => {
  const response = await fetch(`/api/search?q=${query}`);
  return response.json();
}, 300);

// All rapid calls share the same promise result
searchAPI('test').then(data => console.log('Result:', data));
```

#### Rate Limiting with Token Bucket

```javascript
class RateLimitedFetch {
  constructor(tokensPerInterval, interval) {
    this.tokens = tokensPerInterval;
    this.maxTokens = tokensPerInterval;
    this.interval = interval;
    this.queue = [];
    this.refillInterval = setInterval(() => this.refill(), interval);
  }
  
  refill() {
    this.tokens = this.maxTokens;
    this.processQueue();
  }
  
  async fetch(url, options = {}) {
    if (this.tokens > 0) {
      this.tokens--;
      return fetch(url, options);
    }
    
    return new Promise((resolve, reject) => {
      this.queue.push({ url, options, resolve, reject });
    });
  }
  
  processQueue() {
    while (this.tokens > 0 && this.queue.length > 0) {
      this.tokens--;
      const { url, options, resolve, reject } = this.queue.shift();
      fetch(url, options)
        .then(resolve)
        .catch(reject);
    }
  }
  
  destroy() {
    clearInterval(this.refillInterval);
  }
}

// Usage: 5 requests per second
const rateLimitedFetch = new RateLimitedFetch(5, 1000);
```

#### Adaptive Throttling

```javascript
class AdaptiveThrottle {
  constructor(initialDelay, minDelay, maxDelay) {
    this.delay = initialDelay;
    this.minDelay = minDelay;
    this.maxDelay = maxDelay;
    this.successCount = 0;
    this.errorCount = 0;
    this.lastCall = 0;
  }
  
  async fetch(url, options = {}) {
    const now = Date.now();
    const timeSinceLastCall = now - this.lastCall;
    
    if (timeSinceLastCall < this.delay) {
      await new Promise(resolve => 
        setTimeout(resolve, this.delay - timeSinceLastCall)
      );
    }
    
    this.lastCall = Date.now();
    
    try {
      const response = await fetch(url, options);
      
      if (response.ok) {
        this.onSuccess();
      } else if (response.status === 429) {
        this.onRateLimit();
      } else {
        this.onError();
      }
      
      return response;
    } catch (error) {
      this.onError();
      throw error;
    }
  }
  
  onSuccess() {
    this.successCount++;
    this.errorCount = 0;
    
    if (this.successCount >= 10) {
      this.delay = Math.max(this.minDelay, this.delay * 0.9);
      this.successCount = 0;
    }
  }
  
  onError() {
    this.errorCount++;
    this.successCount = 0;
    
    if (this.errorCount >= 3) {
      this.delay = Math.min(this.maxDelay, this.delay * 1.5);
      this.errorCount = 0;
    }
  }
  
  onRateLimit() {
    this.delay = Math.min(this.maxDelay, this.delay * 2);
    this.errorCount = 0;
    this.successCount = 0;
  }
}
```

### Retry Logic with Exponential Backoff

```javascript
async function fetchWithRetry(url, options = {}, retries = 3) {
  let lastError;
  
  for (let i = 0; i < retries; i++) {
    try {
      const response = await fetch(url, options);
      
      if (response.ok || response.status === 404) {
        return response;
      }
      
      if (response.status === 429) {
        const retryAfter = response.headers.get('Retry-After');
        const delay = retryAfter ? parseInt(retryAfter) * 1000 : Math.pow(2, i) * 1000;
        await new Promise(resolve => setTimeout(resolve, delay));
        continue;
      }
      
      throw new Error(`HTTP ${response.status}: ${response.statusText}`);
    } catch (error) {
      lastError = error;
      
      if (i < retries - 1) {
        const delay = Math.pow(2, i) * 1000;
        await new Promise(resolve => setTimeout(resolve, delay));
      }
    }
  }
  
  throw lastError;
}

const debouncedFetchWithRetry = debounce(
  (query) => fetchWithRetry(`/api/search?q=${query}`),
  300
);
```

### Handling Concurrent Requests

#### Request Deduplication

```javascript
class RequestDeduplicator {
  constructor() {
    this.pendingRequests = new Map();
  }
  
  async fetch(url, options = {}) {
    const key = this.getKey(url, options);
    
    if (this.pendingRequests.has(key)) {
      return this.pendingRequests.get(key);
    }
    
    const promise = fetch(url, options)
      .then(response => {
        this.pendingRequests.delete(key);
        return response;
      })
      .catch(error => {
        this.pendingRequests.delete(key);
        throw error;
      });
    
    this.pendingRequests.set(key, promise);
    return promise;
  }
  
  getKey(url, options) {
    return `${options.method || 'GET'}:${url}:${JSON.stringify(options.body || '')}`;
  }
}

const deduplicator = new RequestDeduplicator();
const debouncedFetch = debounce((query) => {
  return deduplicator.fetch(`/api/search?q=${query}`);
}, 300);
```

#### Batching Requests

```javascript
class RequestBatcher {
  constructor(batchFn, delay) {
    this.batchFn = batchFn;
    this.delay = delay;
    this.queue = [];
    this.timeoutId = null;
  }
  
  add(item) {
    return new Promise((resolve, reject) => {
      this.queue.push({ item, resolve, reject });
      
      if (!this.timeoutId) {
        this.timeoutId = setTimeout(() => this.flush(), this.delay);
      }
    });
  }
  
  async flush() {
    if (this.queue.length === 0) return;
    
    const batch = this.queue.splice(0);
    this.timeoutId = null;
    
    try {
      const results = await this.batchFn(batch.map(b => b.item));
      
      batch.forEach((b, index) => {
        b.resolve(results[index]);
      });
    } catch (error) {
      batch.forEach(b => b.reject(error));
    }
  }
}

// Usage
const userBatcher = new RequestBatcher(async (ids) => {
  const response = await fetch('/api/users', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ ids })
  });
  return response.json();
}, 50);

// Multiple calls get batched together
const user1Promise = userBatcher.add(1);
const user2Promise = userBatcher.add(2);
const user3Promise = userBatcher.add(3);
```

### Testing Considerations

#### Mocking Time-Dependent Functions

```javascript
// Using Jest fake timers
jest.useFakeTimers();

test('debounce delays execution', () => {
  const mockFn = jest.fn();
  const debounced = debounce(mockFn, 1000);
  
  debounced('test1');
  debounced('test2');
  debounced('test3');
  
  expect(mockFn).not.toHaveBeenCalled();
  
  jest.advanceTimersByTime(1000);
  
  expect(mockFn).toHaveBeenCalledTimes(1);
  expect(mockFn).toHaveBeenCalledWith('test3');
});

test('throttle limits execution rate', () => {
  const mockFn = jest.fn();
  const throttled = throttle(mockFn, 1000);
  
  throttled('call1');
  throttled('call2');
  throttled('call3');
  
  expect(mockFn).toHaveBeenCalledTimes(1);
  expect(mockFn).toHaveBeenCalledWith('call1');
  
  jest.advanceTimersByTime(1000);
  
  throttled('call4');
  expect(mockFn).toHaveBeenCalledTimes(2);
  expect(mockFn).toHaveBeenCalledWith('call4');
});
```

### Performance Optimization

#### Memory Management

```javascript
function debounce(func, delay) {
  let timeoutId;
  
  const debounced = function(...args) {
    clearTimeout(timeoutId);
    timeoutId = setTimeout(() => {
      timeoutId = null; // Allow garbage collection
      func.apply(this, args);
    }, delay);
  };
  
  debounced.cancel = function() {
    clearTimeout(timeoutId);
    timeoutId = null;
  };
  
  debounced.flush = function() {
    if (timeoutId) {
      clearTimeout(timeoutId);
      timeoutId = null;
      func.apply(this, arguments);
    }
  };
  
  return debounced;
}
```

#### WeakMap for Instance Methods

```javascript
const debounceMap = new WeakMap();

function debounceMethod(delay) {
  return function(target, propertyKey, descriptor) {
    const originalMethod = descriptor.value;
    
    descriptor.value = function(...args) {
      if (!debounceMap.has(this)) {
        debounceMap.set(this, new Map());
      }
      
      const instanceMap = debounceMap.get(this);
      
      if (!instanceMap.has(propertyKey)) {
        instanceMap.set(propertyKey, debounce(originalMethod.bind(this), delay));
      }
      
      const debouncedFn = instanceMap.get(propertyKey);
      return debouncedFn(...args);
    };
    
    return descriptor;
  };
}

// Usage
class SearchComponent {
  @debounceMethod(300)
  async search(query) {
    const response = await fetch(`/api/search?q=${query}`);
    return response.json();
  }
}
```

### Common Pitfalls

#### Loss of Context

```javascript
// Incorrect: loses 'this' context
class Component {
  constructor() {
    this.name = 'MyComponent';
    this.search = debounce(this.search, 300); // Wrong
  }
  
  search(query) {
    console.log(this.name); // 'this' may be undefined
  }
}

// Correct: preserves 'this' context
class Component {
  constructor() {
    this.name = 'MyComponent';
    this.search = debounce(this.search.bind(this), 300);
  }
  
  search(query) {
    console.log(this.name); // Works correctly
  }
}
```

#### Race Conditions

```javascript
// Problematic: can display stale results
const debouncedSearch = debounce(async (query) => {
  const response = await fetch(`/api/search?q=${query}`);
  const data = await response.json();
  displayResults(data); // May display results out of order
}, 300);

// Better: use abort controller
let currentController = null;

const debouncedSearch = debounce(async (query) => {
  if (currentController) {
    currentController.abort();
  }
  
  currentController = new AbortController();
  
  try {
    const response = await fetch(`/api/search?q=${query}`, {
      signal: currentController.signal
    });
    const data = await response.json();
    displayResults(data);
  } catch (error) {
    if (error.name !== 'AbortError') {
      console.error(error);
    }
  }
}, 300);
```

### Library Integration

#### Using Lodash

```javascript
import { debounce, throttle } from 'lodash';

const debouncedFetch = debounce(async (query) => {
  const response = await fetch(`/api/search?q=${query}`);
  return response.json();
}, 300, {
  leading: false,
  trailing: true,
  maxWait: 1000
});

const throttledScroll = throttle(() => {
  loadMoreItems();
}, 1000, {
  leading: true,
  trailing: false
});
```

#### Custom Hook for React

```javascript
function useDebouncedFetch(url, delay) {
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);
  
  const debouncedFetch = useMemo(
    () => debounce(async (fetchUrl) => {
      setLoading(true);
      setError(null);
      
      try {
        const response = await fetch(fetchUrl);
        const result = await response.json();
        setData(result);
      } catch (err) {
        setError(err);
      } finally {
        setLoading(false);
      }
    }, delay),
    [delay]
  );
  
  useEffect(() => {
    if (url) {
      debouncedFetch(url);
    }
    
    return () => {
      debouncedFetch.cancel();
    };
  }, [url, debouncedFetch]);
  
  return { data, loading, error };
}
```

---

