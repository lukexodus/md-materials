## Error Cleanup Patterns


### Retry with Abort

```javascript
async function fetchWithRetry(url, options = {}, maxRetries = 3) {
  let controller;
  
  for (let i = 0; i < maxRetries; i++) {
    controller = new AbortController();
    
    try {
      const response = await fetch(url, {
        ...options,
        signal: controller.signal
      });
      
      if (response.ok) return response;
      
      // Don't retry client errors
      if (response.status >= 400 && response.status < 500) {
        throw new Error(`Client error: ${response.status}`);
      }
    } catch (err) {
      if (err.name === 'AbortError' || i === maxRetries - 1) {
        throw err;
      }
      
      await new Promise(resolve => 
        setTimeout(resolve, Math.pow(2, i) * 1000)
      );
    }
  }
}

// Usage with cleanup
const controller = new AbortController();
fetchWithRetry('/api/data', { signal: controller.signal })
  .catch(err => console.error(err));

// Can still abort all retry attempts
controller.abort();
```

### Graceful Degradation Pattern

```javascript
async function fetchWithFallback(urls, options = {}) {
  const controller = new AbortController();
  const errors = [];
  
  for (const url of urls) {
    try {
      const response = await fetch(url, {
        ...options,
        signal: controller.signal
      });
      
      if (response.ok) {
        return response;
      }
      
      errors.push({ url, status: response.status });
    } catch (err) {
      if (err.name === 'AbortError') throw err;
      errors.push({ url, error: err.message });
    }
  }
  
  throw new Error(`All endpoints failed: ${JSON.stringify(errors)}`);
}
```

