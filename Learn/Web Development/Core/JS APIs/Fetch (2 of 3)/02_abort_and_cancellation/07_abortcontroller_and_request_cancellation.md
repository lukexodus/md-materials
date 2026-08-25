## AbortController and Request Cancellation


### Basic Abort Pattern

```javascript
const controller = new AbortController();
const signal = controller.signal;

fetch('https://api.example.com/data', { signal })
  .then(response => response.json())
  .catch(err => {
    if (err.name === 'AbortError') {
      console.log('Fetch aborted');
    }
  });

// Cancel the request
controller.abort();
```

### Timeout Implementation

```javascript
function fetchWithTimeout(url, options = {}, timeout = 5000) {
  const controller = new AbortController();
  const signal = controller.signal;
  
  const timeoutId = setTimeout(() => controller.abort(), timeout);
  
  return fetch(url, { ...options, signal })
    .finally(() => clearTimeout(timeoutId));
}
```

### Multiple Request Cancellation

```javascript
const controller = new AbortController();

Promise.all([
  fetch('/api/users', { signal: controller.signal }),
  fetch('/api/posts', { signal: controller.signal }),
  fetch('/api/comments', { signal: controller.signal })
])
  .then(responses => Promise.all(responses.map(r => r.json())))
  .catch(err => {
    if (err.name === 'AbortError') {
      console.log('All requests aborted');
    }
  });

// Abort all requests simultaneously
controller.abort();
```

