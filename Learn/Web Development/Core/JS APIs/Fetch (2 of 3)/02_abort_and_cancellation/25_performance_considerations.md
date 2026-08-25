## Performance Considerations


### Request Cancellation Overhead

AbortController cancellation is lightweight but not zero-cost. The browser still initiates the connection and may transfer partial data before cancellation takes effect. For extremely rapid requests (millisecond intervals), cancellation overhead can accumulate.

### Memory Leaks from Uncancelled Requests

Failing to abort requests or clean up references can cause memory leaks:

```javascript
// Potential leak: response handlers hold references
function leakyFetch(url) {
  fetch(url).then(response => {
    // This closure captures the entire scope
    processLargeData(response);
  });
  // No way to cancel this request
}

// Better: store controller reference for cleanup
class Component {
  constructor() {
    this.controllers = [];
  }
  
  fetch(url) {
    const controller = new AbortController();
    this.controllers.push(controller);
    
    return fetch(url, { signal: controller.signal });
  }
  
  cleanup() {
    this.controllers.forEach(c => c.abort());
    this.controllers = [];
  }
}
```

### Request Queue Depth

Browsers limit concurrent HTTP/1.1 connections per domain (typically 6). For HTTP/2, multiplexing allows more concurrent requests, but excessive parallel requests still impact performance. Consider:

```javascript
class RequestQueue {
  constructor(concurrency = 6) {
    this.concurrency = concurrency;
    this.queue = [];
    this.active = 0;
  }
  
  async add(fetchFn) {
    if (this.active >= this.concurrency) {
      await new Promise(resolve => this.queue.push(resolve));
    }
    
    this.active++;
    try {
      return await fetchFn();
    } finally {
      this.active--;
      if (this.queue.length > 0) {
        const resolve = this.queue.shift();
        resolve();
      }
    }
  }
}
```

