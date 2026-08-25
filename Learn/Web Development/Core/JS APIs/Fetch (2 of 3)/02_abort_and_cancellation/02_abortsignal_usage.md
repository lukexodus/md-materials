## AbortSignal Usage


### Core Integration

The `AbortSignal` integrates with fetch through the `signal` option in the request configuration. When the associated `AbortController` calls `abort()`, the fetch request terminates immediately and rejects with an `AbortError`.

```javascript
const controller = new AbortController();
const signal = controller.signal;

fetch('https://api.example.com/data', { signal })
  .then(response => response.json())
  .catch(err => {
    if (err.name === 'AbortError') {
      console.log('Request aborted');
    }
  });

// Abort the request
controller.abort();
```

### Timeout Implementation

`AbortSignal.timeout()` creates a signal that automatically aborts after a specified duration in milliseconds.

```javascript
// Aborts after 5 seconds
fetch('https://api.example.com/data', {
  signal: AbortSignal.timeout(5000)
})
.catch(err => {
  if (err.name === 'TimeoutError') {
    console.log('Request timed out');
  }
});
```

### Signal Composition with AbortSignal.any()

`AbortSignal.any()` combines multiple signals, aborting when any of the input signals aborts. This enables complex cancellation scenarios.

```javascript
const userController = new AbortController();
const timeoutSignal = AbortSignal.timeout(10000);

const combinedSignal = AbortSignal.any([
  userController.signal,
  timeoutSignal
]);

fetch('https://api.example.com/data', { signal: combinedSignal })
  .catch(err => {
    if (err.name === 'AbortError') {
      console.log('Aborted by user');
    } else if (err.name === 'TimeoutError') {
      console.log('Request timeout');
    }
  });

// User can still manually abort
userController.abort();
```

### Event Handling

The `abort` event fires when a signal is aborted, allowing cleanup operations or state updates.

```javascript
const controller = new AbortController();
const signal = controller.signal;

signal.addEventListener('abort', () => {
  console.log('Signal aborted');
  console.log('Abort reason:', signal.reason);
});

fetch('https://api.example.com/data', { signal });

controller.abort('User cancelled operation');
```

### Abort Reasons

Custom abort reasons provide context about why cancellation occurred.

```javascript
const controller = new AbortController();

fetch('https://api.example.com/data', { signal: controller.signal })
  .catch(err => {
    console.log(err.message); // Custom reason
  });

controller.abort(new Error('Network switch detected'));
```

### Signal Reuse Patterns

Signals cannot be reused after abortion. Each new request sequence requires a fresh `AbortController`.

```javascript
// Incorrect - reusing aborted signal
const controller = new AbortController();
controller.abort();

fetch('https://api.example.com/data', { signal: controller.signal });
// This immediately fails with AbortError

// Correct - new controller per request
function makeRequest() {
  const controller = new AbortController();
  
  fetch('https://api.example.com/data', { 
    signal: controller.signal 
  });
  
  return controller;
}
```

### Race Condition Handling

Check `signal.aborted` before initiating expensive operations that follow fetch.

```javascript
const controller = new AbortController();
const signal = controller.signal;

fetch('https://api.example.com/data', { signal })
  .then(response => response.json())
  .then(data => {
    // Check if aborted before processing
    if (signal.aborted) {
      return;
    }
    
    // Expensive processing
    processLargeDataset(data);
  });
```

### Cleanup in Async Functions

Proper cleanup ensures resources release even when requests abort mid-flight.

```javascript
async function fetchWithCleanup(url, signal) {
  let stream;
  
  try {
    const response = await fetch(url, { signal });
    stream = response.body;
    
    const reader = stream.getReader();
    
    while (true) {
      const { done, value } = await reader.read();
      
      if (done || signal.aborted) break;
      
      processChunk(value);
    }
  } catch (err) {
    if (err.name === 'AbortError') {
      console.log('Streaming aborted');
    }
    throw err;
  } finally {
    if (stream) {
      await stream.cancel();
    }
  }
}
```

### Debounced Request Pattern

Cancel previous requests when new ones are initiated rapidly, common in search-as-you-type scenarios.

```javascript
let currentController = null;

async function searchAPI(query) {
  // Abort previous request
  if (currentController) {
    currentController.abort();
  }
  
  currentController = new AbortController();
  
  try {
    const response = await fetch(
      `https://api.example.com/search?q=${query}`,
      { signal: currentController.signal }
    );
    
    const results = await response.json();
    displayResults(results);
  } catch (err) {
    if (err.name !== 'AbortError') {
      console.error('Search failed:', err);
    }
  }
}
```

### Multiple Concurrent Requests

Manage multiple requests with individual or grouped cancellation capabilities.

```javascript
class RequestManager {
  constructor() {
    this.controllers = new Map();
  }
  
  async fetch(id, url, options = {}) {
    const controller = new AbortController();
    this.controllers.set(id, controller);
    
    try {
      const response = await fetch(url, {
        ...options,
        signal: controller.signal
      });
      return await response.json();
    } finally {
      this.controllers.delete(id);
    }
  }
  
  abort(id) {
    const controller = this.controllers.get(id);
    if (controller) {
      controller.abort();
    }
  }
  
  abortAll() {
    for (const controller of this.controllers.values()) {
      controller.abort();
    }
    this.controllers.clear();
  }
}
```

### Navigation-Based Cancellation

Cancel requests when users navigate away from pages or components.

```javascript
// React example
useEffect(() => {
  const controller = new AbortController();
  
  fetch('https://api.example.com/data', {
    signal: controller.signal
  })
    .then(response => response.json())
    .then(data => setState(data))
    .catch(err => {
      if (err.name !== 'AbortError') {
        console.error(err);
      }
    });
  
  // Cleanup on unmount
  return () => controller.abort();
}, []);
```

### Priority-Based Cancellation

Abort lower-priority requests when higher-priority ones are initiated.

```javascript
class PriorityRequestQueue {
  constructor() {
    this.currentRequest = null;
    this.currentPriority = 0;
  }
  
  async fetch(url, priority = 0) {
    // Cancel if lower priority request exists
    if (this.currentRequest && priority > this.currentPriority) {
      this.currentRequest.abort();
    }
    
    const controller = new AbortController();
    this.currentRequest = controller;
    this.currentPriority = priority;
    
    try {
      const response = await fetch(url, { 
        signal: controller.signal 
      });
      return await response.json();
    } finally {
      if (this.currentRequest === controller) {
        this.currentRequest = null;
      }
    }
  }
}
```

### Signal Propagation in Request Chains

Propagate abort signals through multiple dependent requests.

```javascript
async function fetchUserWithPosts(userId, signal) {
  // First request - fetch user
  const userResponse = await fetch(
    `https://api.example.com/users/${userId}`,
    { signal }
  );
  const user = await userResponse.json();
  
  // Check if aborted between requests
  if (signal.aborted) {
    throw new DOMException('Aborted', 'AbortError');
  }
  
  // Second request - fetch posts, using same signal
  const postsResponse = await fetch(
    `https://api.example.com/users/${userId}/posts`,
    { signal }
  );
  const posts = await postsResponse.json();
  
  return { user, posts };
}
```

### ThrowIfAborted Pattern

The `signal.throwIfAborted()` method throws an `AbortError` if the signal is already aborted, useful for early exit checks.

```javascript
async function complexOperation(signal) {
  // Check at start
  signal.throwIfAborted();
  
  await step1();
  
  // Check between steps
  signal.throwIfAborted();
  
  await step2();
  
  signal.throwIfAborted();
  
  await step3();
}
```

### Custom Abort Controllers

Extend `AbortController` for specialized cancellation logic.

```javascript
class RetryableController extends AbortController {
  constructor(maxRetries = 3) {
    super();
    this.maxRetries = maxRetries;
    this.attempt = 0;
  }
  
  async fetchWithRetry(url, options = {}) {
    while (this.attempt < this.maxRetries) {
      try {
        this.attempt++;
        
        const response = await fetch(url, {
          ...options,
          signal: this.signal
        });
        
        if (!response.ok && this.attempt < this.maxRetries) {
          await new Promise(resolve => 
            setTimeout(resolve, 1000 * this.attempt)
          );
          continue;
        }
        
        return response;
      } catch (err) {
        if (err.name === 'AbortError' || 
            this.attempt >= this.maxRetries) {
          throw err;
        }
      }
    }
  }
}
```

### Memory Leak Prevention

Ensure controllers and event listeners are properly cleaned up to prevent memory leaks.

```javascript
class RequestHandler {
  constructor() {
    this.activeControllers = new Set();
  }
  
  async fetch(url, options = {}) {
    const controller = new AbortController();
    this.activeControllers.add(controller);
    
    const cleanup = () => {
      this.activeControllers.delete(controller);
    };
    
    controller.signal.addEventListener('abort', cleanup);
    
    try {
      const response = await fetch(url, {
        ...options,
        signal: controller.signal
      });
      return await response.json();
    } finally {
      cleanup();
    }
  }
  
  destroy() {
    // Abort all active requests
    for (const controller of this.activeControllers) {
      controller.abort();
    }
    this.activeControllers.clear();
  }
}
```

### Conditional Abort Logic

Implement abort conditions based on response characteristics or runtime state.

```javascript
async function fetchWithSizeLimit(url, maxBytes) {
  const controller = new AbortController();
  let bytesReceived = 0;
  
  const response = await fetch(url, { 
    signal: controller.signal 
  });
  
  const reader = response.body.getReader();
  const chunks = [];
  
  while (true) {
    const { done, value } = await reader.read();
    
    if (done) break;
    
    bytesReceived += value.length;
    
    if (bytesReceived > maxBytes) {
      controller.abort('Size limit exceeded');
      break;
    }
    
    chunks.push(value);
  }
  
  return chunks;
}
```

---

