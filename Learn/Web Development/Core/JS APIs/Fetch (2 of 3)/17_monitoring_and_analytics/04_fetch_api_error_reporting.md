## Fetch API Error Reporting


### Network vs HTTP Errors

The fetch API distinguishes between network-level failures and HTTP-level failures. A fetch promise only rejects for network errors—such as DNS resolution failures, connection timeouts, or lack of internet connectivity. HTTP error responses (4xx, 5xx) result in a resolved promise with `response.ok` set to `false`.

```javascript
fetch('https://api.example.com/data')
  .then(response => {
    if (!response.ok) {
      throw new Error(`HTTP error: ${response.status}`);
    }
    return response.json();
  })
  .catch(error => {
    // Network error or thrown HTTP error
    console.error('Fetch failed:', error);
  });
```

### Response Status Checking

#### The `ok` Property

The `response.ok` property returns `true` for status codes in the 200-299 range. This provides a convenient way to validate successful responses without manually checking status codes.

```javascript
const response = await fetch('/api/endpoint');
if (!response.ok) {
  throw new Error(`Request failed with status ${response.status}`);
}
```

#### Status Code Inspection

For granular error handling, inspect `response.status` and `response.statusText`:

```javascript
const response = await fetch('/api/resource');

switch (response.status) {
  case 200:
    return await response.json();
  case 404:
    throw new Error('Resource not found');
  case 401:
    throw new Error('Unauthorized access');
  case 500:
    throw new Error('Server error occurred');
  default:
    throw new Error(`Unexpected status: ${response.status}`);
}
```

### Network Error Detection

Network errors reject the fetch promise. These include:

- DNS lookup failures
- Connection refused or timeout
- Network disconnection
- CORS violations
- SSL/TLS certificate issues

```javascript
try {
  const response = await fetch('https://api.example.com/data');
  // Handle response
} catch (error) {
  if (error instanceof TypeError) {
    // Network error occurred
    console.error('Network failure:', error.message);
  } else {
    // Other error type
    console.error('Request error:', error);
  }
}
```

[Inference] TypeError is commonly thrown for network failures, though the specification doesn't guarantee the specific error type.

### Timeout Handling

Fetch doesn't support native timeouts. Implement timeout logic using `AbortController`:

```javascript
const controller = new AbortController();
const timeoutId = setTimeout(() => controller.abort(), 5000);

try {
  const response = await fetch('/api/data', {
    signal: controller.signal
  });
  clearTimeout(timeoutId);
  
  if (!response.ok) {
    throw new Error(`HTTP ${response.status}`);
  }
  
  return await response.json();
} catch (error) {
  clearTimeout(timeoutId);
  
  if (error.name === 'AbortError') {
    throw new Error('Request timeout after 5 seconds');
  }
  throw error;
}
```

### Parsing Errors

JSON parsing failures occur when the response body isn't valid JSON. These throw synchronously:

```javascript
const response = await fetch('/api/data');

if (!response.ok) {
  throw new Error(`HTTP ${response.status}`);
}

try {
  const data = await response.json();
  return data;
} catch (error) {
  if (error instanceof SyntaxError) {
    throw new Error('Invalid JSON response');
  }
  throw error;
}
```

### Error Context Extraction

#### Reading Error Response Bodies

Server error responses often contain detailed error information:

```javascript
const response = await fetch('/api/submit', {
  method: 'POST',
  body: JSON.stringify(data)
});

if (!response.ok) {
  let errorMessage = `HTTP ${response.status}`;
  
  try {
    const errorData = await response.json();
    errorMessage = errorData.message || errorMessage;
  } catch {
    // Response wasn't JSON, use status text
    errorMessage = response.statusText || errorMessage;
  }
  
  throw new Error(errorMessage);
}
```

#### Preserving Response Information

Create custom error objects that retain response details:

```javascript
class FetchError extends Error {
  constructor(message, response) {
    super(message);
    this.name = 'FetchError';
    this.status = response.status;
    this.statusText = response.statusText;
    this.url = response.url;
  }
}

const response = await fetch('/api/endpoint');

if (!response.ok) {
  const body = await response.text();
  throw new FetchError(
    `Request failed: ${body || response.statusText}`,
    response
  );
}
```

### CORS Error Identification

CORS violations manifest as network errors. The browser console shows CORS-specific messages, but JavaScript only receives a generic network failure:

```javascript
try {
  const response = await fetch('https://different-origin.com/api');
  // Process response
} catch (error) {
  // Cannot definitively determine if this is CORS
  // Browser console will show CORS details
  console.error('Request failed (check console for CORS issues):', error);
}
```

[Unverified] There's no programmatic way to distinguish CORS errors from other network failures in the catch block due to security restrictions.

### Retry Logic

Implement exponential backoff for transient failures:

```javascript
async function fetchWithRetry(url, options = {}, maxRetries = 3) {
  for (let attempt = 0; attempt <= maxRetries; attempt++) {
    try {
      const response = await fetch(url, options);
      
      if (response.ok) {
        return response;
      }
      
      // Don't retry client errors (4xx)
      if (response.status >= 400 && response.status < 500) {
        throw new Error(`HTTP ${response.status}: ${response.statusText}`);
      }
      
      // Retry server errors (5xx) and network issues
      if (attempt < maxRetries) {
        const delay = Math.pow(2, attempt) * 1000;
        await new Promise(resolve => setTimeout(resolve, delay));
        continue;
      }
      
      throw new Error(`HTTP ${response.status} after ${maxRetries} retries`);
      
    } catch (error) {
      if (attempt === maxRetries) {
        throw error;
      }
      
      // Exponential backoff
      const delay = Math.pow(2, attempt) * 1000;
      await new Promise(resolve => setTimeout(resolve, delay));
    }
  }
}
```

### Comprehensive Error Handler Pattern

```javascript
async function safeFetch(url, options = {}) {
  const controller = new AbortController();
  const timeout = options.timeout || 10000;
  const timeoutId = setTimeout(() => controller.abort(), timeout);
  
  try {
    const response = await fetch(url, {
      ...options,
      signal: controller.signal
    });
    
    clearTimeout(timeoutId);
    
    // Check HTTP status
    if (!response.ok) {
      let errorBody = null;
      const contentType = response.headers.get('content-type');
      
      if (contentType?.includes('application/json')) {
        try {
          errorBody = await response.json();
        } catch {
          errorBody = await response.text();
        }
      } else {
        errorBody = await response.text();
      }
      
      throw {
        type: 'HTTP_ERROR',
        status: response.status,
        statusText: response.statusText,
        body: errorBody,
        url: response.url
      };
    }
    
    return response;
    
  } catch (error) {
    clearTimeout(timeoutId);
    
    if (error.name === 'AbortError') {
      throw {
        type: 'TIMEOUT',
        message: `Request timeout after ${timeout}ms`,
        url
      };
    }
    
    if (error instanceof TypeError) {
      throw {
        type: 'NETWORK_ERROR',
        message: error.message,
        url
      };
    }
    
    // Re-throw structured errors
    if (error.type) {
      throw error;
    }
    
    // Unknown error
    throw {
      type: 'UNKNOWN',
      message: error.message,
      originalError: error,
      url
    };
  }
}

// Usage
try {
  const response = await safeFetch('/api/data', { timeout: 5000 });
  const data = await response.json();
} catch (error) {
  switch (error.type) {
    case 'HTTP_ERROR':
      console.error(`HTTP ${error.status}:`, error.body);
      break;
    case 'TIMEOUT':
      console.error('Request timed out');
      break;
    case 'NETWORK_ERROR':
      console.error('Network failure:', error.message);
      break;
    default:
      console.error('Unknown error:', error);
  }
}
```

### Logging and Monitoring

Structure error information for observability:

```javascript
function logFetchError(error, context = {}) {
  const errorLog = {
    timestamp: new Date().toISOString(),
    url: context.url,
    method: context.method || 'GET',
    errorType: error.type || 'UNKNOWN',
    message: error.message,
    status: error.status,
    stack: error.stack,
    ...context.metadata
  };
  
  // Send to monitoring service
  console.error('Fetch error:', errorLog);
  
  // Example: Send to external service
  // analytics.track('fetch_error', errorLog);
}

// Usage
try {
  const response = await fetch('/api/endpoint', { method: 'POST' });
  if (!response.ok) throw new Error(`HTTP ${response.status}`);
} catch (error) {
  logFetchError(error, {
    url: '/api/endpoint',
    method: 'POST',
    metadata: { userId: currentUser.id }
  });
}
```

### User-Facing Error Messages

Translate technical errors into user-friendly messages:

```javascript
function getUserErrorMessage(error) {
  if (error.type === 'NETWORK_ERROR') {
    return 'Unable to connect. Please check your internet connection.';
  }
  
  if (error.type === 'TIMEOUT') {
    return 'The request is taking too long. Please try again.';
  }
  
  if (error.type === 'HTTP_ERROR') {
    switch (error.status) {
      case 400:
        return 'Invalid request. Please check your input.';
      case 401:
        return 'Please log in to continue.';
      case 403:
        return 'You don\'t have permission to access this resource.';
      case 404:
        return 'The requested resource was not found.';
      case 429:
        return 'Too many requests. Please wait a moment.';
      case 500:
      case 502:
      case 503:
        return 'Server error. Please try again later.';
      default:
        return 'An unexpected error occurred. Please try again.';
    }
  }
  
  return 'Something went wrong. Please try again.';
}
```

---

