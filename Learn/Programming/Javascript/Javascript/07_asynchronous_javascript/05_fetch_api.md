## Fetch API


The Fetch API is a modern JavaScript interface for making HTTP requests, replacing the older XMLHttpRequest. Here's a comprehensive guide to working with it:

### Basic Usage

```javascript
// Simple GET request
fetch('https://api.example.com/data')
  .then(response => response.json())
  .then(data => console.log(data))
  .catch(error => console.error('Error:', error));
```

### Request Options

```javascript
// POST request with JSON body
fetch('https://api.example.com/data', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({
    name: 'John Doe',
    email: 'john@example.com'
  })
})
  .then(response => response.json())
  .then(data => console.log(data))
  .catch(error => console.error('Error:', error));
```

### Common Request Methods

```javascript
// GET (default)
fetch('https://api.example.com/data');

// POST
fetch('https://api.example.com/data', { method: 'POST', body: data });

// PUT
fetch('https://api.example.com/data/1', { method: 'PUT', body: data });

// DELETE
fetch('https://api.example.com/data/1', { method: 'DELETE' });

// PATCH
fetch('https://api.example.com/data/1', { method: 'PATCH', body: partialData });
```

### Request Headers

```javascript
fetch('https://api.example.com/data', {
  headers: {
    'Authorization': 'Bearer your_token_here',
    'Content-Type': 'application/json',
    'Accept': 'application/json'
  }
});
```

### Response Handling

```javascript
fetch('https://api.example.com/data')
  .then(response => {
    // Check if the response was successful
    if (!response.ok) {
      throw new Error(`HTTP error! Status: ${response.status}`);
    }
    
    // Check content type
    const contentType = response.headers.get('content-type');
    if (contentType && contentType.includes('application/json')) {
      return response.json();
    } else if (contentType && contentType.includes('text/')) {
      return response.text();
    } else if (contentType && contentType.includes('image/')) {
      return response.blob();
    } else {
      return response.arrayBuffer();
    }
  })
  .then(data => console.log(data))
  .catch(error => console.error('Error:', error));
```

### Response Properties and Methods

```javascript
fetch('https://api.example.com/data')
  .then(response => {
    console.log('Status:', response.status); // 200, 404, etc.
    console.log('Status text:', response.statusText); // OK, Not Found, etc.
    console.log('Response type:', response.type); // basic, cors, error, etc.
    console.log('Headers:', response.headers);
    console.log('Content type:', response.headers.get('content-type'));
    console.log('URL:', response.url);
    console.log('Is ok:', response.ok); // true if status is 200-299
    console.log('Is redirected:', response.redirected);
    
    // Methods to parse response body (can only be used once)
    // response.json() - Parse as JSON
    // response.text() - Parse as text
    // response.blob() - Parse as Blob
    // response.arrayBuffer() - Parse as ArrayBuffer
    // response.formData() - Parse as FormData
    
    return response.json();
  });
```

### Async/Await Syntax

```javascript
async function fetchData() {
  try {
    const response = await fetch('https://api.example.com/data');
    if (!response.ok) {
      throw new Error(`HTTP error! Status: ${response.status}`);
    }
    const data = await response.json();
    console.log(data);
  } catch (error) {
    console.error('Error:', error);
  }
}

fetchData();
```

### Working with FormData

```javascript
const formData = new FormData();
formData.append('username', 'john_doe');
formData.append('avatar', fileInput.files[0]);

fetch('https://api.example.com/upload', {
  method: 'POST',
  body: formData
  // No need to set Content-Type header - it's automatically set
})
  .then(response => response.json())
  .then(data => console.log(data))
  .catch(error => console.error('Error:', error));
```

### Request Timeout

```javascript
// Fetch doesn't have a built-in timeout, but we can implement it
const fetchWithTimeout = (url, options = {}, timeout = 5000) => {
  return Promise.race([
    fetch(url, options),
    new Promise((_, reject) => 
      setTimeout(() => reject(new Error('Request timed out')), timeout)
    )
  ]);
};

fetchWithTimeout('https://api.example.com/data', {}, 3000)
  .then(response => response.json())
  .then(data => console.log(data))
  .catch(error => console.error('Error:', error));
```

### Aborting Requests

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
      console.error('Error:', error);
    }
  });

// Abort the request after 3 seconds
setTimeout(() => controller.abort(), 3000);
```

### Fetch Credentials

```javascript
// Don't send credentials (default)
fetch('https://api.example.com/data', { credentials: 'omit' });

// Send credentials only for same-origin requests
fetch('https://api.example.com/data', { credentials: 'same-origin' });

// Always send credentials (cookies, HTTP auth)
fetch('https://api.example.com/data', { credentials: 'include' });
```

### CORS and Mode

```javascript
// Default
fetch('https://api.example.com/data', { mode: 'cors' });

// Only same-origin requests
fetch('https://api.example.com/data', { mode: 'same-origin' });

// Allow cross-origin without CORS headers
fetch('https://api.example.com/data', { mode: 'no-cors' });
```

### Cache Control

```javascript
// Default
fetch('https://api.example.com/data', { cache: 'default' });

// No cache
fetch('https://api.example.com/data', { cache: 'no-cache' });

// Force cache
fetch('https://api.example.com/data', { cache: 'force-cache' });

// Only if cached
fetch('https://api.example.com/data', { cache: 'only-if-cached' });
```

### Redirect Handling

```javascript
// Default (follow redirects)
fetch('https://api.example.com/data', { redirect: 'follow' });

// Return error on redirect
fetch('https://api.example.com/data', { redirect: 'error' });

// Return opaque filtered response on redirect
fetch('https://api.example.com/data', { redirect: 'manual' });
```

Browser support for the Fetch API is excellent in modern browsers, but may require a polyfill for older browsers like Internet Explorer.

---

