## Debouncing and Request Deduplication


### Debounced Fetch

```javascript
function debouncedFetch(url, options = {}, delay = 300) {
  let timeoutId;
  let controller;
  
  return function() {
    // Cancel previous request
    if (controller) {
      controller.abort();
    }
    
    clearTimeout(timeoutId);
    
    return new Promise((resolve, reject) => {
      timeoutId = setTimeout(() => {
        controller = new AbortController();
        
        fetch(url, { ...options, signal: controller.signal })
          .then(resolve)
          .catch(reject);
      }, delay);
    });
  };
}
```

### Request Deduplication

```javascript
class FetchCache {
  constructor() {
    this.pending = new Map();
  }
  
  async fetch(url, options = {}) {
    const key = this.getKey(url, options);
    
    if (this.pending.has(key)) {
      return this.pending.get(key);
    }
    
    const promise = fetch(url, options)
      .then(res => res.json())
      .finally(() => {
        this.pending.delete(key);
      });
    
    this.pending.set(key, promise);
    return promise;
  }
  
  getKey(url, options) {
    return `${url}-${JSON.stringify(options)}`;
  }
  
  clear() {
    this.pending.clear();
  }
}
```

