## Multiple Request Cancellation


### AbortController for Multiple Requests

The `AbortController` API enables cancellation of multiple fetch requests simultaneously by sharing a single signal across requests or managing multiple controllers.

```javascript
const controller = new AbortController();
const signal = controller.signal;

// Multiple requests sharing one signal
const requests = [
  fetch('/api/users', { signal }),
  fetch('/api/posts', { signal }),
  fetch('/api/comments', { signal })
];

// Cancel all requests at once
controller.abort();
```

### Managing Multiple Controllers

When requests need independent cancellation alongside group cancellation, maintain separate controllers while providing a mechanism to abort all.

```javascript
const controllers = new Map();

function makeRequest(id, url) {
  const controller = new AbortController();
  controllers.set(id, controller);
  
  return fetch(url, { signal: controller.signal })
    .then(response => response.json())
    .finally(() => controllers.delete(id));
}

// Cancel specific request
function cancelRequest(id) {
  const controller = controllers.get(id);
  if (controller) {
    controller.abort();
    controllers.delete(id);
  }
}

// Cancel all requests
function cancelAllRequests() {
  controllers.forEach(controller => controller.abort());
  controllers.clear();
}
```

### Hierarchical Signal Propagation

Create parent-child relationships between abort signals using `AbortSignal.any()` to cascade cancellation through request hierarchies.

```javascript
// Parent controller for all requests
const parentController = new AbortController();

// Child controllers for specific groups
const userRequestsController = new AbortController();
const postRequestsController = new AbortController();

// Combine signals - abort if either parent OR child signals
const userSignal = AbortSignal.any([
  parentController.signal,
  userRequestsController.signal
]);

const postSignal = AbortSignal.any([
  parentController.signal,
  postRequestsController.signal
]);

// Requests respect both hierarchies
fetch('/api/users', { signal: userSignal });
fetch('/api/posts', { signal: postSignal });

// Cancel all users requests only
userRequestsController.abort();

// Cancel everything
parentController.abort();
```

### Promise.allSettled with Cancellation

Handle multiple requests with cancellation while tracking individual outcomes.

```javascript
async function fetchMultipleWithCancellation(urls, timeout = 5000) {
  const controller = new AbortController();
  const timeoutId = setTimeout(() => controller.abort(), timeout);
  
  const requests = urls.map(url =>
    fetch(url, { signal: controller.signal })
      .then(response => response.json())
      .then(data => ({ status: 'fulfilled', value: data, url }))
      .catch(error => ({ 
        status: 'rejected', 
        reason: error.name === 'AbortError' ? 'Cancelled' : error.message,
        url 
      }))
  );
  
  const results = await Promise.allSettled(requests);
  clearTimeout(timeoutId);
  
  return results;
}
```

### Cancellation with Cleanup

Implement proper cleanup when cancelling multiple requests to prevent memory leaks and ensure resources are released.

```javascript
class RequestManager {
  constructor() {
    this.activeRequests = new Map();
  }
  
  async fetch(id, url, options = {}) {
    // Cancel existing request with same ID
    this.cancel(id);
    
    const controller = new AbortController();
    const signal = options.signal 
      ? AbortSignal.any([controller.signal, options.signal])
      : controller.signal;
    
    const requestData = {
      controller,
      url,
      promise: null
    };
    
    this.activeRequests.set(id, requestData);
    
    try {
      const response = await fetch(url, { ...options, signal });
      const data = await response.json();
      return data;
    } catch (error) {
      if (error.name === 'AbortError') {
        console.log(`Request ${id} cancelled`);
      }
      throw error;
    } finally {
      this.activeRequests.delete(id);
    }
  }
  
  cancel(id) {
    const request = this.activeRequests.get(id);
    if (request) {
      request.controller.abort();
      this.activeRequests.delete(id);
    }
  }
  
  cancelAll() {
    this.activeRequests.forEach((request, id) => {
      request.controller.abort();
    });
    this.activeRequests.clear();
  }
  
  cancelByPattern(pattern) {
    this.activeRequests.forEach((request, id) => {
      if (pattern.test(request.url) || pattern.test(id)) {
        request.controller.abort();
        this.activeRequests.delete(id);
      }
    });
  }
  
  get activeCount() {
    return this.activeRequests.size;
  }
}

// Usage
const manager = new RequestManager();

manager.fetch('user-1', '/api/users/1');
manager.fetch('user-2', '/api/users/2');
manager.fetch('posts', '/api/posts');

// Cancel specific request
manager.cancel('user-1');

// Cancel by pattern
manager.cancelByPattern(/^user-/);

// Cancel all
manager.cancelAll();
```

### Race Conditions and Latest Request Pattern

Cancel previous requests when new ones are initiated, ensuring only the latest request completes.

```javascript
let currentController = null;

async function fetchLatest(url) {
  // Cancel previous request
  if (currentController) {
    currentController.abort();
  }
  
  currentController = new AbortController();
  const signal = currentController.signal;
  
  try {
    const response = await fetch(url, { signal });
    const data = await response.json();
    
    // Only process if this is still the current request
    if (signal.aborted) return null;
    
    return data;
  } catch (error) {
    if (error.name === 'AbortError') {
      return null; // Silent cancellation
    }
    throw error;
  }
}

// Debounced search with cancellation
function createDebouncedSearch(delay = 300) {
  let timeoutId;
  let controller;
  
  return async function(query) {
    clearTimeout(timeoutId);
    
    if (controller) {
      controller.abort();
    }
    
    return new Promise((resolve, reject) => {
      timeoutId = setTimeout(async () => {
        controller = new AbortController();
        
        try {
          const response = await fetch(`/api/search?q=${query}`, {
            signal: controller.signal
          });
          const data = await response.json();
          resolve(data);
        } catch (error) {
          if (error.name !== 'AbortError') {
            reject(error);
          }
        }
      }, delay);
    });
  };
}
```

### Batch Cancellation with Priorities

Implement priority-based cancellation where low-priority requests are cancelled when high-priority requests are initiated.

```javascript
class PriorityRequestManager {
  constructor() {
    this.requests = new Map();
    this.priorities = { LOW: 1, MEDIUM: 2, HIGH: 3 };
  }
  
  async fetch(id, url, priority = this.priorities.MEDIUM, options = {}) {
    const controller = new AbortController();
    
    const requestData = {
      controller,
      priority,
      url,
      timestamp: Date.now()
    };
    
    this.requests.set(id, requestData);
    
    // Cancel lower priority requests if we're at capacity
    this.enforceLimits(priority);
    
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
  
  enforceLimits(newRequestPriority, maxConcurrent = 5) {
    if (this.requests.size < maxConcurrent) return;
    
    // Cancel lowest priority requests
    const sortedRequests = Array.from(this.requests.entries())
      .sort(([, a], [, b]) => {
        if (a.priority !== b.priority) {
          return a.priority - b.priority;
        }
        return a.timestamp - b.timestamp;
      });
    
    for (const [id, request] of sortedRequests) {
      if (request.priority < newRequestPriority) {
        this.cancel(id);
        if (this.requests.size < maxConcurrent) break;
      }
    }
  }
  
  cancel(id) {
    const request = this.requests.get(id);
    if (request) {
      request.controller.abort();
      this.requests.delete(id);
    }
  }
  
  cancelByPriority(priority) {
    this.requests.forEach((request, id) => {
      if (request.priority === priority) {
        request.controller.abort();
        this.requests.delete(id);
      }
    });
  }
}
```

### Timeout-Based Group Cancellation

Apply timeouts to groups of requests with differential timeout policies.

```javascript
class TimeoutRequestGroup {
  constructor(defaultTimeout = 5000) {
    this.defaultTimeout = defaultTimeout;
    this.groups = new Map();
  }
  
  async fetchGroup(groupId, requests, timeout = this.defaultTimeout) {
    const controller = new AbortController();
    
    const timeoutId = setTimeout(() => {
      controller.abort();
    }, timeout);
    
    const groupData = {
      controller,
      timeoutId,
      requests: new Set()
    };
    
    this.groups.set(groupId, groupData);
    
    try {
      const promises = requests.map(({ url, options = {} }) => {
        const requestPromise = fetch(url, {
          ...options,
          signal: controller.signal
        }).then(r => r.json());
        
        groupData.requests.add(requestPromise);
        return requestPromise;
      });
      
      const results = await Promise.allSettled(promises);
      return results;
    } finally {
      clearTimeout(timeoutId);
      this.groups.delete(groupId);
    }
  }
  
  cancelGroup(groupId) {
    const group = this.groups.get(groupId);
    if (group) {
      clearTimeout(group.timeoutId);
      group.controller.abort();
      this.groups.delete(groupId);
    }
  }
  
  cancelAllGroups() {
    this.groups.forEach((group, groupId) => {
      this.cancelGroup(groupId);
    });
  }
}

// Usage
const groupManager = new TimeoutRequestGroup();

groupManager.fetchGroup('user-data', [
  { url: '/api/user/profile' },
  { url: '/api/user/settings' },
  { url: '/api/user/preferences' }
], 3000);

groupManager.fetchGroup('dashboard-data', [
  { url: '/api/dashboard/stats' },
  { url: '/api/dashboard/activity' }
], 5000);

// Cancel specific group
groupManager.cancelGroup('user-data');
```

### Event-Driven Cancellation

Implement cancellation triggered by application events or state changes.

```javascript
class EventDrivenRequestManager extends EventTarget {
  constructor() {
    super();
    this.requests = new Map();
  }
  
  async fetch(id, url, options = {}) {
    const controller = new AbortController();
    
    // Cancel on specific events
    const cancelOnEvents = options.cancelOn || [];
    const eventHandlers = [];
    
    cancelOnEvents.forEach(eventName => {
      const handler = () => controller.abort();
      this.addEventListener(eventName, handler);
      eventHandlers.push({ eventName, handler });
    });
    
    this.requests.set(id, {
      controller,
      eventHandlers,
      url
    });
    
    try {
      const response = await fetch(url, {
        ...options,
        signal: controller.signal
      });
      return await response.json();
    } catch (error) {
      if (error.name === 'AbortError') {
        console.log(`Request ${id} cancelled by event`);
      }
      throw error;
    } finally {
      // Cleanup event listeners
      eventHandlers.forEach(({ eventName, handler }) => {
        this.removeEventListener(eventName, handler);
      });
      this.requests.delete(id);
    }
  }
  
  cancel(id) {
    const request = this.requests.get(id);
    if (request) {
      request.controller.abort();
    }
  }
  
  triggerCancellation(eventName) {
    this.dispatchEvent(new Event(eventName));
  }
}

// Usage
const manager = new EventDrivenRequestManager();

// These requests will cancel on logout
manager.fetch('data-1', '/api/data/1', { 
  cancelOn: ['logout', 'page-change'] 
});
manager.fetch('data-2', '/api/data/2', { 
  cancelOn: ['logout'] 
});

// Trigger cancellation
manager.triggerCancellation('logout');
```

### Memory-Efficient Cancellation Tracking

Track cancelled requests efficiently without memory leaks in long-running applications.

```javascript
class EfficientRequestTracker {
  constructor(maxHistory = 100) {
    this.active = new Map();
    this.cancelled = new Map();
    this.maxHistory = maxHistory;
  }
  
  async fetch(id, url, options = {}) {
    const controller = new AbortController();
    const startTime = Date.now();
    
    this.active.set(id, {
      controller,
      url,
      startTime
    });
    
    try {
      const response = await fetch(url, {
        ...options,
        signal: controller.signal
      });
      const data = await response.json();
      this.active.delete(id);
      return data;
    } catch (error) {
      this.active.delete(id);
      
      if (error.name === 'AbortError') {
        this.recordCancellation(id, Date.now() - startTime);
      }
      throw error;
    }
  }
  
  cancel(id) {
    const request = this.active.get(id);
    if (request) {
      request.controller.abort();
    }
  }
  
  cancelAll() {
    this.active.forEach((request) => {
      request.controller.abort();
    });
  }
  
  recordCancellation(id, duration) {
    this.cancelled.set(id, {
      timestamp: Date.now(),
      duration
    });
    
    // Prevent memory growth
    if (this.cancelled.size > this.maxHistory) {
      const oldest = Array.from(this.cancelled.keys())[0];
      this.cancelled.delete(oldest);
    }
  }
  
  getStats() {
    return {
      active: this.active.size,
      totalCancelled: this.cancelled.size,
      cancelled: Array.from(this.cancelled.entries())
    };
  }
}
```

### Composite Signal Patterns

Create complex cancellation conditions by combining multiple abort signals.

```javascript
// Cancel on any condition
function createCompositeSignal(...conditions) {
  const controllers = [];
  const signals = [];
  
  conditions.forEach(condition => {
    if (condition.signal) {
      signals.push(condition.signal);
    } else if (condition.timeout) {
      const controller = new AbortController();
      setTimeout(() => controller.abort(), condition.timeout);
      controllers.push(controller);
      signals.push(controller.signal);
    } else if (condition.event) {
      const controller = new AbortController();
      const handler = () => controller.abort();
      condition.target.addEventListener(condition.event, handler, { once: true });
      controllers.push(controller);
      signals.push(controller.signal);
    }
  });
  
  return AbortSignal.any(signals);
}

// Usage
const button = document.querySelector('#cancel-btn');

const signal = createCompositeSignal(
  { timeout: 5000 },
  { target: button, event: 'click' },
  { signal: parentController.signal }
);

fetch('/api/data', { signal });
```

### Cancellation with Retry Logic

Implement cancellation that respects retry attempts and backoff strategies.

```javascript
async function fetchWithRetry(url, options = {}, maxRetries = 3) {
  const {
    signal: externalSignal,
    retryDelay = 1000,
    backoffMultiplier = 2,
    ...fetchOptions
  } = options;
  
  for (let attempt = 0; attempt <= maxRetries; attempt++) {
    const controller = new AbortController();
    const signal = externalSignal
      ? AbortSignal.any([controller.signal, externalSignal])
      : controller.signal;
    
    try {
      const response = await fetch(url, { ...fetchOptions, signal });
      
      if (!response.ok && attempt < maxRetries) {
        const delay = retryDelay * Math.pow(backoffMultiplier, attempt);
        await new Promise(resolve => setTimeout(resolve, delay));
        continue;
      }
      
      return await response.json();
    } catch (error) {
      if (error.name === 'AbortError') {
        throw error; // Don't retry on cancellation
      }
      
      if (attempt === maxRetries) {
        throw error;
      }
      
      const delay = retryDelay * Math.pow(backoffMultiplier, attempt);
      await new Promise(resolve => setTimeout(resolve, delay));
    }
  }
}

// Multiple retrying requests with shared cancellation
const globalController = new AbortController();

Promise.all([
  fetchWithRetry('/api/data/1', { signal: globalController.signal }),
  fetchWithRetry('/api/data/2', { signal: globalController.signal }),
  fetchWithRetry('/api/data/3', { signal: globalController.signal })
]);

// Cancel all retrying requests
globalController.abort();
```

---

