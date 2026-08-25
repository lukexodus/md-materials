## AbortSignal & Request Cancellation


### Basic Abort Pattern

```javascript
const controller = new AbortController();
const signal = controller.signal;

fetch('https://api.example.com/data', { signal })
  .then(response => response.json())
  .then(data => console.log(data))
  .catch(error => {
    if (error.name === 'AbortError') {
      console.log('Fetch aborted');
    } else {
      console.error('Fetch error:', error);
    }
  });

// Abort the request
controller.abort();
```

### Timeout Implementation

```javascript
// Simple timeout
function fetchWithTimeout(url, options = {}, timeout = 5000) {
  const controller = new AbortController();
  const timeoutId = setTimeout(() => controller.abort(), timeout);

  return fetch(url, {
    ...options,
    signal: controller.signal
  }).finally(() => {
    clearTimeout(timeoutId);
  });
}

// Usage
try {
  const response = await fetchWithTimeout('https://api.example.com/data', {}, 3000);
  const data = await response.json();
} catch (error) {
  if (error.name === 'AbortError') {
    console.error('Request timed out');
  }
}
```

### AbortSignal.timeout() Method

```javascript
// Modern approach (Node 18+, modern browsers)
try {
  const response = await fetch('https://api.example.com/data', {
    signal: AbortSignal.timeout(5000) // 5 second timeout
  });
  const data = await response.json();
} catch (error) {
  if (error.name === 'TimeoutError' || error.name === 'AbortError') {
    console.error('Request timed out');
  }
}
```

### Combining Multiple Signals

```javascript
// Combine multiple abort signals
function combineSignals(...signals) {
  const controller = new AbortController();

  for (const signal of signals) {
    if (signal.aborted) {
      controller.abort();
      return controller.signal;
    }

    signal.addEventListener('abort', () => controller.abort(), { once: true });
  }

  return controller.signal;
}

// Usage
const userController = new AbortController();
const timeoutSignal = AbortSignal.timeout(10000);

const combinedSignal = combineSignals(
  userController.signal,
  timeoutSignal
);

fetch('https://api.example.com/data', { signal: combinedSignal });

// Can abort from either source
userController.abort(); // User cancellation
// or timeout will trigger automatically
```

### AbortSignal.any() Method

```javascript
// Modern approach (newer browsers/Node.js)
const userController = new AbortController();

const response = await fetch('https://api.example.com/data', {
  signal: AbortSignal.any([
    userController.signal,
    AbortSignal.timeout(5000)
  ])
});

// Aborts if either user cancels OR timeout occurs
```

### Component Lifecycle Integration (React)

```javascript
// React useEffect cleanup
function DataComponent() {
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const controller = new AbortController();

    fetch('https://api.example.com/data', {
      signal: controller.signal
    })
      .then(response => response.json())
      .then(data => {
        setData(data);
        setLoading(false);
      })
      .catch(error => {
        if (error.name !== 'AbortError') {
          console.error('Fetch error:', error);
        }
        setLoading(false);
      });

    // Cleanup: abort on unmount
    return () => controller.abort();
  }, []);

  return loading ? <div>Loading...</div> : <div>{JSON.stringify(data)}</div>;
}
```

### Search Input Debouncing with Abort

```javascript
class SearchHandler {
  constructor() {
    this.controller = null;
  }

  async search(query) {
    // Abort previous request if still pending
    if (this.controller) {
      this.controller.abort();
    }

    // Create new controller for this request
    this.controller = new AbortController();

    try {
      const response = await fetch(
        `https://api.example.com/search?q=${encodeURIComponent(query)}`,
        { signal: this.controller.signal }
      );
      return await response.json();
    } catch (error) {
      if (error.name === 'AbortError') {
        console.log('Search cancelled');
        return null;
      }
      throw error;
    }
  }
}

// Usage
const searchHandler = new SearchHandler();

searchInput.addEventListener('input', async (e) => {
  const results = await searchHandler.search(e.target.value);
  if (results) {
    displayResults(results);
  }
});
```

### Abort Event Listener

```javascript
const controller = new AbortController();
const signal = controller.signal;

// Listen for abort event
signal.addEventListener('abort', () => {
  console.log('Request was aborted');
  console.log('Abort reason:', signal.reason);
});

// Check if already aborted
if (signal.aborted) {
  console.log('Signal already aborted');
}

fetch('https://api.example.com/data', { signal });

// Abort with custom reason
controller.abort(new Error('User cancelled the operation'));
```

### Multiple Concurrent Requests with Individual Control

```javascript
class RequestManager {
  constructor() {
    this.requests = new Map();
  }

  async fetch(id, url, options = {}) {
    // Create controller for this request
    const controller = new AbortController();
    this.requests.set(id, controller);

    try {
      const response = await fetch(url, {
        ...options,
        signal: controller.signal
      });
      return await response.json();
    } finally {
      this.requests.delete(id);
    }
  }

  abort(id) {
    const controller = this.requests.get(id);
    if (controller) {
      controller.abort();
      this.requests.delete(id);
    }
  }

  abortAll() {
    for (const [id, controller] of this.requests) {
      controller.abort();
    }
    this.requests.clear();
  }

  isActive(id) {
    return this.requests.has(id);
  }

  getActiveCount() {
    return this.requests.size;
  }
}

// Usage
const manager = new RequestManager();

// Start multiple requests
manager.fetch('users', 'https://api.example.com/users');
manager.fetch('posts', 'https://api.example.com/posts');
manager.fetch('comments', 'https://api.example.com/comments');

// Abort specific request
manager.abort('posts');

// Abort all requests
manager.abortAll();
```

### Retry with Abort

```javascript
async function fetchWithRetry(url, options = {}, maxRetries = 3) {
  const controller = new AbortController();
  let lastError;

  for (let i = 0; i < maxRetries; i++) {
    try {
      const response = await fetch(url, {
        ...options,
        signal: controller.signal
      });

      if (!response.ok) {
        throw new Error(`HTTP ${response.status}`);
      }

      return response;
    } catch (error) {
      lastError = error;

      // Don't retry if aborted
      if (error.name === 'AbortError') {
        throw error;
      }

      // Wait before retry (exponential backoff)
      if (i < maxRetries - 1) {
        await new Promise(resolve => setTimeout(resolve, 1000 * Math.pow(2, i)));
      }
    }
  }

  throw lastError;
}

// Usage with external abort control
const controller = new AbortController();

fetchWithRetry('https://api.example.com/data', {
  signal: controller.signal
});

// Can abort retry loop
controller.abort();
```

### Priority Queue with Abort

```javascript
class PriorityRequestQueue {
  constructor(maxConcurrent = 3) {
    this.maxConcurrent = maxConcurrent;
    this.active = 0;
    this.queue = [];
  }

  async fetch(url, options = {}, priority = 0) {
    return new Promise((resolve, reject) => {
      const controller = new AbortController();
      
      const request = {
        url,
        options: { ...options, signal: controller.signal },
        priority,
        resolve,
        reject,
        controller
      };

      // Insert by priority
      const index = this.queue.findIndex(r => r.priority < priority);
      if (index === -1) {
        this.queue.push(request);
      } else {
        this.queue.splice(index, 0, request);
      }

      this.process();

      // Return abort function
      return controller;
    });
  }

  async process() {
    if (this.active >= this.maxConcurrent || this.queue.length === 0) {
      return;
    }

    this.active++;
    const request = this.queue.shift();

    try {
      const response = await fetch(request.url, request.options);
      const data = await response.json();
      request.resolve(data);
    } catch (error) {
      request.reject(error);
    } finally {
      this.active--;
      this.process();
    }
  }

  abortAll() {
    for (const request of this.queue) {
      request.controller.abort();
      request.reject(new Error('Request aborted'));
    }
    this.queue = [];
  }
}

// Usage
const queue = new PriorityRequestQueue(3);

// High priority request
queue.fetch('https://api.example.com/critical', {}, 10);

// Normal priority
queue.fetch('https://api.example.com/normal', {}, 5);

// Low priority
queue.fetch('https://api.example.com/background', {}, 1);

// Abort all pending
queue.abortAll();
```

### Abort on Navigation

```javascript
// Vanilla JS
class FetchManager {
  constructor() {
    this.activeRequests = new Set();
    
    // Abort all on page unload
    window.addEventListener('beforeunload', () => {
      this.abortAll();
    });
  }

  async fetch(url, options = {}) {
    const controller = new AbortController();
    this.activeRequests.add(controller);

    try {
      const response = await fetch(url, {
        ...options,
        signal: controller.signal
      });
      return response;
    } finally {
      this.activeRequests.delete(controller);
    }
  }

  abortAll() {
    for (const controller of this.activeRequests) {
      controller.abort();
    }
    this.activeRequests.clear();
  }
}

const fetchManager = new FetchManager();
```

### Progressive Timeout

```javascript
// Start with short timeout, increase if needed
async function fetchWithProgressiveTimeout(url, options = {}) {
  const timeouts = [2000, 5000, 10000]; // Progressive timeouts
  let lastError;

  for (const timeout of timeouts) {
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
        console.log(`Timeout after ${timeout}ms, retrying with longer timeout`);
        lastError = error;
        continue;
      }
      
      throw error;
    }
  }

  throw new Error('All attempts timed out');
}
```

### Abort with Race Conditions

```javascript
// Race multiple endpoints, abort losers
async function fetchRace(urls, options = {}) {
  const controllers = urls.map(() => new AbortController());

  const requests = urls.map((url, index) =>
    fetch(url, {
      ...options,
      signal: controllers[index].signal
    }).then(response => ({
      response,
      index,
      url
    }))
  );

  try {
    const winner = await Promise.race(requests);
    
    // Abort all other requests
    controllers.forEach((controller, index) => {
      if (index !== winner.index) {
        controller.abort();
      }
    });

    return winner.response;
  } catch (error) {
    // Abort all on error
    controllers.forEach(controller => controller.abort());
    throw error;
  }
}

// Usage
const response = await fetchRace([
  'https://api1.example.com/data',
  'https://api2.example.com/data',
  'https://api3.example.com/data'
]);
```

### Chained Requests with Abort

```javascript
async function fetchChain(urls, options = {}) {
  const controller = new AbortController();
  const results = [];

  try {
    for (const url of urls) {
      // Check if aborted before each request
      if (controller.signal.aborted) {
        throw new Error('Chain aborted');
      }

      const response = await fetch(url, {
        ...options,
        signal: controller.signal
      });

      const data = await response.json();
      results.push(data);

      // Use data from previous request in next request
      // options.body = JSON.stringify({ previousData: data });
    }

    return results;
  } catch (error) {
    if (error.name === 'AbortError') {
      console.log('Chain aborted at request', results.length + 1);
    }
    throw error;
  }
}

// Abort entire chain
const controller = new AbortController();

fetchChain(
  ['/api/step1', '/api/step2', '/api/step3'],
  { signal: controller.signal }
);

// Abort after 5 seconds
setTimeout(() => controller.abort(), 5000);
```

### Abort with Promise.allSettled

```javascript
async function fetchAllWithAbort(requests, timeout = 10000) {
  const controller = new AbortController();
  const timeoutId = setTimeout(() => controller.abort(), timeout);

  const promises = requests.map(({ url, options = {} }) =>
    fetch(url, {
      ...options,
      signal: controller.signal
    })
      .then(response => response.json())
      .then(data => ({ status: 'fulfilled', value: data, url }))
      .catch(error => ({ status: 'rejected', reason: error, url }))
  );

  const results = await Promise.allSettled(promises);
  clearTimeout(timeoutId);

  return results.map((result, index) => ({
    url: requests[index].url,
    ...result
  }));
}

// Usage
const results = await fetchAllWithAbort([
  { url: 'https://api.example.com/users' },
  { url: 'https://api.example.com/posts' },
  { url: 'https://api.example.com/comments' }
], 5000);

results.forEach(result => {
  if (result.status === 'fulfilled') {
    console.log(`${result.url}: Success`, result.value);
  } else {
    console.log(`${result.url}: Failed`, result.reason);
  }
});
```

### Abort Signal Forwarding

```javascript
// Pass signal through multiple layers
async function apiLayer1(signal) {
  return apiLayer2(signal);
}

async function apiLayer2(signal) {
  return apiLayer3(signal);
}

async function apiLayer3(signal) {
  return fetch('https://api.example.com/data', { signal });
}

// Single abort point controls entire chain
const controller = new AbortController();
apiLayer1(controller.signal);
controller.abort(); // Aborts at any level
```

### Conditional Abort Based on Response

```javascript
async function fetchWithResponseCheck(url, options = {}) {
  const controller = new AbortController();
  
  const response = await fetch(url, {
    ...options,
    signal: controller.signal
  });

  // Check response before reading body
  if (!response.ok) {
    controller.abort(); // Abort reading body
    throw new Error(`HTTP ${response.status}`);
  }

  // Read body only if response is ok
  const data = await response.json();

  // Conditional abort based on data
  if (data.error || data.status === 'invalid') {
    controller.abort();
    throw new Error('Invalid data received');
  }

  return data;
}
```

### Abort with Streaming Response

```javascript
async function fetchStreamWithAbort(url, onChunk, timeout = 30000) {
  const controller = new AbortController();
  const timeoutId = setTimeout(() => controller.abort(), timeout);

  try {
    const response = await fetch(url, {
      signal: controller.signal
    });

    const reader = response.body.getReader();
    const decoder = new TextDecoder();

    while (true) {
      // Check if aborted
      if (controller.signal.aborted) {
        reader.cancel();
        break;
      }

      const { done, value } = await reader.read();
      
      if (done) break;

      const chunk = decoder.decode(value, { stream: true });
      onChunk(chunk);

      // Can abort based on chunk content
      if (chunk.includes('ERROR')) {
        controller.abort();
        break;
      }
    }
  } finally {
    clearTimeout(timeoutId);
  }
}

// Usage
fetchStreamWithAbort(
  'https://api.example.com/stream',
  (chunk) => console.log('Received:', chunk)
);
```

### AbortSignal State Management

```javascript
class AbortSignalManager {
  constructor() {
    this.controllers = new Map();
    this.signals = new Map();
  }

  create(id) {
    const controller = new AbortController();
    this.controllers.set(id, controller);
    this.signals.set(id, controller.signal);

    // Auto-cleanup on abort
    controller.signal.addEventListener('abort', () => {
      this.controllers.delete(id);
      this.signals.delete(id);
    }, { once: true });

    return controller.signal;
  }

  abort(id, reason) {
    const controller = this.controllers.get(id);
    if (controller) {
      controller.abort(reason);
    }
  }

  abortAll(reason) {
    for (const [id, controller] of this.controllers) {
      controller.abort(reason);
    }
    this.controllers.clear();
    this.signals.clear();
  }

  isAborted(id) {
    const signal = this.signals.get(id);
    return signal ? signal.aborted : true;
  }

  getActiveCount() {
    return this.controllers.size;
  }

  async fetchWithSignal(id, url, options = {}) {
    const signal = this.create(id);
    
    try {
      const response = await fetch(url, {
        ...options,
        signal
      });
      return await response.json();
    } finally {
      this.controllers.delete(id);
      this.signals.delete(id);
    }
  }
}

// Usage
const manager = new AbortSignalManager();

manager.fetchWithSignal('request-1', 'https://api.example.com/data');
manager.fetchWithSignal('request-2', 'https://api.example.com/users');

// Abort specific request
manager.abort('request-1', 'User cancelled');

// Abort all
manager.abortAll('Component unmounted');
```

### Custom AbortSignal Wrapper

```javascript
class SmartAbortController {
  constructor() {
    this.controller = new AbortController();
    this.abortCallbacks = [];
    this.aborted = false;
    this.reason = null;
  }

  get signal() {
    return this.controller.signal;
  }

  abort(reason) {
    if (this.aborted) return;

    this.aborted = true;
    this.reason = reason;
    this.controller.abort(reason);

    // Execute callbacks
    for (const callback of this.abortCallbacks) {
      callback(reason);
    }
  }

  onAbort(callback) {
    if (this.aborted) {
      callback(this.reason);
    } else {
      this.abortCallbacks.push(callback);
    }

    // Return unsubscribe function
    return () => {
      const index = this.abortCallbacks.indexOf(callback);
      if (index > -1) {
        this.abortCallbacks.splice(index, 1);
      }
    };
  }

  isAborted() {
    return this.aborted;
  }

  getAbortReason() {
    return this.reason;
  }
}

// Usage
const controller = new SmartAbortController();

const unsubscribe = controller.onAbort((reason) => {
  console.log('Aborted because:', reason);
});

fetch('https://api.example.com/data', {
  signal: controller.signal
});

controller.abort('User navigated away');
```

---

