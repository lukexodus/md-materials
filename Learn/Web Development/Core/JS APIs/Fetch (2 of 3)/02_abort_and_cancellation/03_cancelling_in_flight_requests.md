## Cancelling In-Flight Requests


### AbortController and AbortSignal

The `AbortController` interface provides the standard mechanism for cancelling fetch requests. It works through a signal-based pattern where an `AbortController` generates an `AbortSignal` that can be passed to fetch operations.

```javascript
const controller = new AbortController();
const signal = controller.signal;

fetch('https://api.example.com/data', { signal })
  .then(response => response.json())
  .then(data => console.log(data))
  .catch(error => {
    if (error.name === 'AbortError') {
      console.log('Request was cancelled');
    }
  });

// Abort the request
controller.abort();
```

### AbortController Mechanics

#### Creating and Using Controllers

Each `AbortController` instance is single-use. Once `abort()` is called, the controller cannot be reset or reused. The associated signal's `aborted` property becomes `true` and remains so permanently.

```javascript
const controller = new AbortController();
console.log(controller.signal.aborted); // false

controller.abort();
console.log(controller.signal.aborted); // true

// This controller is now permanently aborted
// Create a new one for subsequent requests
```

#### Signal Propagation

The signal is passed as an option to fetch. Once the controller aborts, any associated fetch request that hasn't completed will be cancelled immediately.

```javascript
const controller = new AbortController();

fetch('/api/slow-endpoint', {
  signal: controller.signal,
  method: 'POST',
  body: JSON.stringify({ data: 'value' })
});

// Abort after 5 seconds
setTimeout(() => controller.abort(), 5000);
```

### Timeout Implementation

Implementing request timeouts using `AbortController`:

```javascript
function fetchWithTimeout(url, options = {}, timeout = 5000) {
  const controller = new AbortController();
  const signal = controller.signal;
  
  const timeoutId = setTimeout(() => controller.abort(), timeout);
  
  return fetch(url, { ...options, signal })
    .finally(() => clearTimeout(timeoutId));
}

// Usage
fetchWithTimeout('/api/data', {}, 3000)
  .then(response => response.json())
  .catch(error => {
    if (error.name === 'AbortError') {
      console.log('Request timed out');
    }
  });
```

### Abort Reasons

The `abort()` method accepts an optional reason parameter that becomes the rejection value:

```javascript
const controller = new AbortController();

fetch('/api/data', { signal: controller.signal })
  .catch(error => {
    console.log(error); // DOMException or custom error
    console.log(error.message); // "User cancelled the request"
  });

controller.abort(new Error('User cancelled the request'));
```

Without a reason, the default `DOMException` with name `'AbortError'` is used.

### Multiple Requests with One Controller

A single `AbortController` can cancel multiple simultaneous requests:

```javascript
const controller = new AbortController();
const signal = controller.signal;

const requests = [
  fetch('/api/users', { signal }),
  fetch('/api/posts', { signal }),
  fetch('/api/comments', { signal })
];

Promise.all(requests)
  .then(responses => Promise.all(responses.map(r => r.json())))
  .then(data => console.log(data))
  .catch(error => {
    if (error.name === 'AbortError') {
      console.log('All requests cancelled');
    }
  });

// Cancel all three requests at once
controller.abort();
```

### Signal Event Listeners

The `AbortSignal` is an `EventTarget` and emits an `abort` event when cancelled:

```javascript
const controller = new AbortController();
const signal = controller.signal;

signal.addEventListener('abort', () => {
  console.log('Request was aborted');
  console.log('Abort reason:', signal.reason);
});

fetch('/api/data', { signal });

controller.abort('User navigated away');
```

The `signal.reason` property contains the abort reason passed to `controller.abort()`.

### AbortSignal.timeout()

Modern browsers support `AbortSignal.timeout()` as a convenience method for timeout-based cancellation:

```javascript
// Automatically abort after 5 seconds
fetch('/api/data', {
  signal: AbortSignal.timeout(5000)
})
.catch(error => {
  if (error.name === 'TimeoutError') {
    console.log('Request timed out');
  }
});
```

This creates a signal that automatically aborts after the specified milliseconds, throwing a `TimeoutError` rather than an `AbortError`.

### AbortSignal.any()

Combine multiple signals to abort when any of them triggers:

```javascript
const userController = new AbortController();
const timeoutSignal = AbortSignal.timeout(10000);

const combinedSignal = AbortSignal.any([
  userController.signal,
  timeoutSignal
]);

fetch('/api/data', { signal: combinedSignal })
  .catch(error => {
    if (error.name === 'AbortError') {
      console.log('Cancelled by user');
    } else if (error.name === 'TimeoutError') {
      console.log('Request timed out');
    }
  });

// User can cancel early
document.getElementById('cancel').onclick = () => {
  userController.abort();
};
```

### Race Conditions and Stale Requests

When requests can be cancelled and reissued rapidly (such as in search-as-you-type), managing controllers prevents stale data:

```javascript
let currentController = null;

function searchUsers(query) {
  // Cancel previous request if still in flight
  if (currentController) {
    currentController.abort();
  }
  
  currentController = new AbortController();
  const signal = currentController.signal;
  
  return fetch(`/api/search?q=${query}`, { signal })
    .then(response => response.json())
    .then(results => {
      // Only process if this request wasn't aborted
      if (!signal.aborted) {
        displayResults(results);
      }
    })
    .catch(error => {
      if (error.name !== 'AbortError') {
        console.error('Search failed:', error);
      }
    });
}

// Rapid user input
searchInput.addEventListener('input', (e) => {
  searchUsers(e.target.value);
});
```

### Request Cleanup Patterns

Proper cleanup ensures resources are released:

```javascript
class RequestManager {
  constructor() {
    this.controllers = new Map();
  }
  
  fetch(id, url, options = {}) {
    // Cancel existing request with same ID
    this.cancel(id);
    
    const controller = new AbortController();
    this.controllers.set(id, controller);
    
    return fetch(url, { ...options, signal: controller.signal })
      .finally(() => {
        // Clean up after completion or cancellation
        this.controllers.delete(id);
      });
  }
  
  cancel(id) {
    const controller = this.controllers.get(id);
    if (controller) {
      controller.abort();
      this.controllers.delete(id);
    }
  }
  
  cancelAll() {
    this.controllers.forEach(controller => controller.abort());
    this.controllers.clear();
  }
}

// Usage
const manager = new RequestManager();

manager.fetch('userData', '/api/user/123');
manager.fetch('userPosts', '/api/user/123/posts');

// Cancel specific request
manager.cancel('userData');

// Cancel all requests (e.g., on component unmount)
manager.cancelAll();
```

### React Integration Pattern

Cancelling requests on component unmount:

```javascript
function UserProfile({ userId }) {
  const [user, setUser] = useState(null);
  
  useEffect(() => {
    const controller = new AbortController();
    
    fetch(`/api/users/${userId}`, {
      signal: controller.signal
    })
      .then(response => response.json())
      .then(data => setUser(data))
      .catch(error => {
        if (error.name !== 'AbortError') {
          console.error('Failed to fetch user:', error);
        }
      });
    
    // Cleanup function cancels request on unmount
    return () => controller.abort();
  }, [userId]);
  
  return user ? <div>{user.name}</div> : <div>Loading...</div>;
}
```

### Network State Considerations

[Inference] When `abort()` is called, the browser attempts to cancel the network request. However, the actual network behavior depends on timing:

- If the request hasn't been sent yet, it won't be sent
- If the request is in-flight, the browser closes the connection
- If the response headers have been received but the body is still downloading, the download is stopped
- If the response is complete, abortion has no network effect but the promise still rejects

### Error Handling Patterns

Distinguishing between abortion and other errors:

```javascript
async function fetchData(url, signal) {
  try {
    const response = await fetch(url, { signal });
    
    if (!response.ok) {
      throw new Error(`HTTP ${response.status}`);
    }
    
    return await response.json();
  } catch (error) {
    if (error.name === 'AbortError') {
      console.log('Request cancelled');
      return null; // Or handle cancellation-specific logic
    }
    
    if (error.name === 'TimeoutError') {
      console.log('Request timed out');
      throw error; // Re-throw or handle differently
    }
    
    // Other network or parsing errors
    console.error('Request failed:', error);
    throw error;
  }
}
```

### Polling with Cancellation

Implementing cancellable polling:

```javascript
class Poller {
  constructor(url, interval = 5000) {
    this.url = url;
    this.interval = interval;
    this.controller = null;
    this.timeoutId = null;
  }
  
  start(callback) {
    this.stop(); // Stop any existing polling
    this.controller = new AbortController();
    
    const poll = async () => {
      try {
        const response = await fetch(this.url, {
          signal: this.controller.signal
        });
        const data = await response.json();
        callback(data);
        
        // Schedule next poll
        this.timeoutId = setTimeout(poll, this.interval);
      } catch (error) {
        if (error.name !== 'AbortError') {
          console.error('Polling error:', error);
          // Retry after interval
          this.timeoutId = setTimeout(poll, this.interval);
        }
      }
    };
    
    poll();
  }
  
  stop() {
    if (this.controller) {
      this.controller.abort();
      this.controller = null;
    }
    if (this.timeoutId) {
      clearTimeout(this.timeoutId);
      this.timeoutId = null;
    }
  }
}

// Usage
const poller = new Poller('/api/status', 3000);
poller.start(data => console.log('Status:', data));

// Stop polling
poller.stop();
```

### Progressive Loading with Cancellation

Cancelling while reading streaming responses:

```javascript
async function fetchWithProgress(url, onProgress) {
  const controller = new AbortController();
  const signal = controller.signal;
  
  try {
    const response = await fetch(url, { signal });
    const reader = response.body.getReader();
    const contentLength = +response.headers.get('Content-Length');
    
    let receivedLength = 0;
    const chunks = [];
    
    while (true) {
      const { done, value } = await reader.read();
      
      if (done) break;
      
      chunks.push(value);
      receivedLength += value.length;
      
      onProgress(receivedLength, contentLength);
      
      // Check if aborted during streaming
      if (signal.aborted) {
        reader.cancel();
        throw new DOMException('Aborted', 'AbortError');
      }
    }
    
    return new Blob(chunks);
  } catch (error) {
    if (error.name === 'AbortError') {
      console.log('Download cancelled');
    }
    throw error;
  }
  
  // Return controller for external cancellation
  return { controller };
}
```

### Debounced Requests

Combining debouncing with automatic cancellation:

```javascript
function debounceWithAbort(func, delay) {
  let timeoutId;
  let controller;
  
  return function(...args) {
    // Cancel previous request
    if (controller) {
      controller.abort();
    }
    
    // Clear previous timeout
    clearTimeout(timeoutId);
    
    // Create new controller for this request
    controller = new AbortController();
    
    // Set new timeout
    timeoutId = setTimeout(() => {
      func.apply(this, [...args, controller.signal]);
    }, delay);
    
    // Return controller for manual cancellation if needed
    return controller;
  };
}

// Usage
const debouncedSearch = debounceWithAbort((query, signal) => {
  fetch(`/api/search?q=${query}`, { signal })
    .then(response => response.json())
    .then(results => displayResults(results))
    .catch(error => {
      if (error.name !== 'AbortError') {
        console.error('Search failed:', error);
      }
    });
}, 300);

searchInput.addEventListener('input', (e) => {
  debouncedSearch(e.target.value);
});
```

### Browser Compatibility Notes

`AbortController` and `AbortSignal` are supported in all modern browsers. `AbortSignal.timeout()` and `AbortSignal.any()` are newer additions with more limited support. For older browsers, polyfills exist or manual timeout implementations can be used as shown in earlier examples.

---

