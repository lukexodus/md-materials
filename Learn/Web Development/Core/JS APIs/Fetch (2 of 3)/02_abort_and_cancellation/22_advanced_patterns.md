## Advanced Patterns


### Request Coalescing Window

Batch multiple requests within a time window:

```javascript
class RequestCoalescer {
  constructor(delay = 50) {
    this.delay = delay;
    this.pending = [];
    this.timeoutId = null;
  }
  
  add(request) {
    return new Promise((resolve, reject) => {
      this.pending.push({ request, resolve, reject });
      
      if (!this.timeoutId) {
        this.timeoutId = setTimeout(() => {
          this.flush();
        }, this.delay);
      }
    });
  }
  
  async flush() {
    const batch = this.pending;
    this.pending = [];
    this.timeoutId = null;
    
    // Process batch as single request
    const ids = batch.map(b => b.request.id);
    const response = await fetch('/api/batch', {
      method: 'POST',
      body: JSON.stringify({ ids })
    });
    const results = await response.json();
    
    // Resolve individual promises
    batch.forEach((item, index) => {
      item.resolve(results[index]);
    });
  }
}
```

This reduces server load by combining rapid requests into fewer network calls.

### Version-Based Conflict Resolution

Use version numbers or ETags to detect and handle conflicts:

```javascript
async function fetchWithVersion(url, expectedVersion) {
  const response = await fetch(url, {
    headers: {
      'If-Match': expectedVersion
    }
  });
  
  if (response.status === 412) { // Precondition Failed
    // Version conflict detected
    const latestResponse = await fetch(url);
    const latestData = await latestResponse.json();
    
    // Handle conflict (merge, prompt user, etc.)
    return handleConflict(latestData);
  }
  
  return response.json();
}
```

The server validates the version, preventing updates based on stale data.

### State Machine for Request Lifecycle

Manage request states explicitly to prevent invalid transitions:

```javascript
class RequestStateMachine {
  constructor() {
    this.state = 'idle';
    this.controller = null;
  }
  
  async fetch(url) {
    if (this.state === 'loading') {
      // Cancel in-progress request
      this.controller.abort();
    }
    
    this.state = 'loading';
    this.controller = new AbortController();
    
    try {
      const response = await fetch(url, {
        signal: this.controller.signal
      });
      const data = await response.json();
      
      this.state = 'success';
      return data;
    } catch (error) {
      if (error.name === 'AbortError') {
        this.state = 'cancelled';
      } else {
        this.state = 'error';
      }
      throw error;
    }
  }
}
```

Explicit state tracking prevents processing responses in invalid states.

