## Resource Management Patterns


### Pooled Resource Cleanup

```javascript
class ResourcePool {
  constructor(maxSize = 10) {
    this.pool = [];
    this.maxSize = maxSize;
    this.controllers = new Set();
  }
  
  async acquire() {
    if (this.pool.length > 0) {
      return this.pool.pop();
    }
    
    const controller = new AbortController();
    this.controllers.add(controller);
    
    return controller;
  }
  
  release(controller) {
    if (this.pool.length < this.maxSize) {
      this.pool.push(controller);
    } else {
      this.controllers.delete(controller);
    }
  }
  
  cleanup() {
    this.controllers.forEach(c => c.abort());
    this.controllers.clear();
    this.pool = [];
  }
}
```

### Automatic Cleanup with Proxies

```javascript
function createAutoCleanupFetch(timeoutMs = 30000) {
  const activeControllers = new WeakMap();
  
  return new Proxy(fetch, {
    apply(target, thisArg, args) {
      const [url, options = {}] = args;
      const controller = new AbortController();
      
      const timeoutId = setTimeout(() => {
        controller.abort();
      }, timeoutMs);
      
      const enhancedOptions = {
        ...options,
        signal: controller.signal
      };
      
      return Reflect.apply(target, thisArg, [url, enhancedOptions])
        .finally(() => clearTimeout(timeoutId));
    }
  });
}

const autoFetch = createAutoCleanupFetch();
```

---

