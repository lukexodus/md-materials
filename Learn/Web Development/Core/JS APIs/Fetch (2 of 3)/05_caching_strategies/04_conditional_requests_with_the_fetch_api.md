## Conditional Requests with the Fetch API


### Overview of Conditional Requests

Conditional requests allow clients to ask servers to process requests only if certain conditions are met. This mechanism reduces bandwidth, improves performance, and enables efficient caching by avoiding unnecessary data transfers when content hasn't changed.

### HTTP Headers for Conditional Requests

Conditional requests rely on specific HTTP headers that carry validation tokens or timestamps:

**Validation Headers (sent by server):**

- `ETag`: Entity tag, typically a hash or version identifier of the resource
- `Last-Modified`: Timestamp when the resource was last modified

**Conditional Request Headers (sent by client):**

- `If-None-Match`: Matches against `ETag` values
- `If-Match`: Matches against `ETag` values (requires match to proceed)
- `If-Modified-Since`: Matches against `Last-Modified` timestamp
- `If-Unmodified-Since`: Matches against `Last-Modified` timestamp (requires no modification to proceed)
- `If-Range`: Used with `Range` header for partial content requests

### Basic If-None-Match Request

The `If-None-Match` header is used with cached `ETag` values to check if a resource has changed.

```javascript
// Initial request - server returns ETag
const response1 = await fetch('/api/data');
const etag = response1.headers.get('ETag');
const data = await response1.json();

// Store etag with cached data
localStorage.setItem('data-etag', etag);
localStorage.setItem('data', JSON.stringify(data));

// Subsequent request with If-None-Match
const cachedEtag = localStorage.getItem('data-etag');

const response2 = await fetch('/api/data', {
  headers: {
    'If-None-Match': cachedEtag
  }
});

if (response2.status === 304) {
  // Not Modified - use cached data
  const cachedData = JSON.parse(localStorage.getItem('data'));
  console.log('Using cached data:', cachedData);
} else if (response2.ok) {
  // Resource changed - update cache
  const newEtag = response2.headers.get('ETag');
  const newData = await response2.json();
  
  localStorage.setItem('data-etag', newEtag);
  localStorage.setItem('data', JSON.stringify(newData));
  console.log('Using fresh data:', newData);
}
```

### If-Modified-Since Request

The `If-Modified-Since` header uses timestamps to determine if content has changed.

```javascript
// Initial request
const response1 = await fetch('/api/article/123');
const lastModified = response1.headers.get('Last-Modified');
const content = await response1.text();

// Save timestamp
localStorage.setItem('article-modified', lastModified);

// Later request
const cachedModified = localStorage.getItem('article-modified');

const response2 = await fetch('/api/article/123', {
  headers: {
    'If-Modified-Since': cachedModified
  }
});

if (response2.status === 304) {
  console.log('Article unchanged, using cached version');
} else {
  const newContent = await response2.text();
  const newModified = response2.headers.get('Last-Modified');
  localStorage.setItem('article-modified', newModified);
  console.log('Article updated:', newContent);
}
```

### Combining If-None-Match and If-Modified-Since

Both headers can be used together, with `If-None-Match` taking precedence when both are present.

```javascript
const response = await fetch('/api/resource', {
  headers: {
    'If-None-Match': cachedEtag,
    'If-Modified-Since': cachedLastModified
  }
});

// Server evaluates If-None-Match first
// If ETag matches, returns 304 without checking Last-Modified
// If no ETag, falls back to If-Modified-Since comparison
```

### If-Match for Optimistic Locking

The `If-Match` header enforces that a resource hasn't changed before allowing an update, preventing lost updates in concurrent editing scenarios.

```javascript
// User loads document for editing
const getResponse = await fetch('/api/document/456');
const etag = getResponse.headers.get('ETag');
const document = await getResponse.json();

// User edits document...
document.content = 'Updated content';

// Submit changes only if document hasn't changed
const updateResponse = await fetch('/api/document/456', {
  method: 'PUT',
  headers: {
    'Content-Type': 'application/json',
    'If-Match': etag
  },
  body: JSON.stringify(document)
});

if (updateResponse.status === 412) {
  // Precondition Failed - document was modified by someone else
  console.error('Document was modified by another user');
  
  // Fetch latest version
  const latestResponse = await fetch('/api/document/456');
  const latestDoc = await latestResponse.json();
  
  // Handle conflict (merge, notify user, etc.)
} else if (updateResponse.ok) {
  console.log('Document updated successfully');
}
```

### If-Unmodified-Since for Safe Updates

The `If-Unmodified-Since` header allows updates only if the resource hasn't been modified since a specific timestamp.

```javascript
const lastModified = response.headers.get('Last-Modified');

// Later, attempt update
const updateResponse = await fetch('/api/resource', {
  method: 'PUT',
  headers: {
    'Content-Type': 'application/json',
    'If-Unmodified-Since': lastModified
  },
  body: JSON.stringify(updatedData)
});

if (updateResponse.status === 412) {
  console.error('Resource was modified since last fetch');
} else if (updateResponse.ok) {
  console.log('Update successful');
}
```

### Wildcard ETag Matching

The asterisk (`*`) wildcard can be used with `If-Match` or `If-None-Match` for special behaviors.

```javascript
// If-Match: * succeeds only if resource exists
const response = await fetch('/api/resource', {
  method: 'PUT',
  headers: {
    'If-Match': '*',
    'Content-Type': 'application/json'
  },
  body: JSON.stringify(data)
});

// 412 Precondition Failed if resource doesn't exist
// Useful for "update only" operations

// If-None-Match: * succeeds only if resource doesn't exist
const createResponse = await fetch('/api/resource', {
  method: 'PUT',
  headers: {
    'If-None-Match': '*',
    'Content-Type': 'application/json'
  },
  body: JSON.stringify(data)
});

// 412 if resource already exists
// Useful for "create only" operations
```

### Multiple ETag Values

`If-None-Match` can accept multiple ETags as a comma-separated list.

```javascript
const response = await fetch('/api/data', {
  headers: {
    'If-None-Match': '"etag1", "etag2", "etag3"'
  }
});

// Returns 304 if current ETag matches any of the provided values
```

### If-Range for Resumable Downloads

The `If-Range` header enables conditional range requests, useful for resuming interrupted downloads.

```javascript
// Initial partial download
const response1 = await fetch('/large-file.zip', {
  headers: {
    'Range': 'bytes=0-1048575' // First 1MB
  }
});

const etag = response1.headers.get('ETag');
const partialData = await response1.arrayBuffer();

// Save partial data and etag
// Later, resume download

const response2 = await fetch('/large-file.zip', {
  headers: {
    'Range': 'bytes=1048576-', // From 1MB onwards
    'If-Range': etag
  }
});

if (response2.status === 206) {
  // Partial Content - file unchanged, resume successful
  const remainingData = await response2.arrayBuffer();
  
  // Combine partial downloads
  const combined = new Uint8Array(partialData.byteLength + remainingData.byteLength);
  combined.set(new Uint8Array(partialData), 0);
  combined.set(new Uint8Array(remainingData), partialData.byteLength);
} else if (response2.status === 200) {
  // File changed - server sent complete file instead
  const completeData = await response2.arrayBuffer();
}
```

### Caching Helper Class

```javascript
class ConditionalCache {
  constructor(storage = localStorage) {
    this.storage = storage;
  }
  
  getCacheKey(url, prefix = 'cache') {
    return `${prefix}:${url}`;
  }
  
  async fetch(url, options = {}) {
    const cacheKey = this.getCacheKey(url);
    const cached = this.storage.getItem(cacheKey);
    
    if (cached) {
      const { etag, lastModified, data } = JSON.parse(cached);
      
      // Add conditional headers
      const headers = new Headers(options.headers || {});
      
      if (etag) {
        headers.set('If-None-Match', etag);
      }
      
      if (lastModified) {
        headers.set('If-Modified-Since', lastModified);
      }
      
      const response = await fetch(url, {
        ...options,
        headers
      });
      
      if (response.status === 304) {
        // Return cached data with synthetic response
        return {
          ok: true,
          status: 304,
          cached: true,
          json: async () => data,
          text: async () => JSON.stringify(data)
        };
      }
      
      if (response.ok) {
        // Update cache with new data
        const newData = await response.json();
        
        this.storage.setItem(cacheKey, JSON.stringify({
          etag: response.headers.get('ETag'),
          lastModified: response.headers.get('Last-Modified'),
          data: newData
        }));
        
        return {
          ok: true,
          status: response.status,
          cached: false,
          json: async () => newData
        };
      }
      
      return response;
    }
    
    // No cache - normal fetch
    const response = await fetch(url, options);
    
    if (response.ok) {
      const data = await response.json();
      
      this.storage.setItem(cacheKey, JSON.stringify({
        etag: response.headers.get('ETag'),
        lastModified: response.headers.get('Last-Modified'),
        data
      }));
      
      return {
        ok: true,
        status: response.status,
        cached: false,
        json: async () => data
      };
    }
    
    return response;
  }
  
  clear(url) {
    if (url) {
      this.storage.removeItem(this.getCacheKey(url));
    } else {
      // Clear all cached items
      const keys = Object.keys(this.storage);
      keys.forEach(key => {
        if (key.startsWith('cache:')) {
          this.storage.removeItem(key);
        }
      });
    }
  }
}

// Usage
const cache = new ConditionalCache();

const response = await cache.fetch('/api/data');
console.log('From cache:', response.cached);
const data = await response.json();
```

### Handling 304 Not Modified Responses

When a server returns 304, the response body is empty, requiring the client to use cached data.

```javascript
async function fetchWithCache(url, cacheKey) {
  const cached = sessionStorage.getItem(cacheKey);
  const cachedMeta = sessionStorage.getItem(`${cacheKey}:meta`);
  
  let headers = {};
  
  if (cachedMeta) {
    const meta = JSON.parse(cachedMeta);
    if (meta.etag) headers['If-None-Match'] = meta.etag;
    if (meta.lastModified) headers['If-Modified-Since'] = meta.lastModified;
  }
  
  const response = await fetch(url, { headers });
  
  if (response.status === 304) {
    // Parse cached data
    return JSON.parse(cached);
  }
  
  if (response.ok) {
    const data = await response.json();
    
    // Cache response and metadata
    sessionStorage.setItem(cacheKey, JSON.stringify(data));
    sessionStorage.setItem(`${cacheKey}:meta`, JSON.stringify({
      etag: response.headers.get('ETag'),
      lastModified: response.headers.get('Last-Modified'),
      timestamp: Date.now()
    }));
    
    return data;
  }
  
  throw new Error(`HTTP ${response.status}`);
}
```

### Weak vs Strong ETags

ETags can be weak or strong. Weak ETags are prefixed with `W/` and indicate semantic equivalence rather than byte-for-byte identity.

```javascript
// Strong ETag - byte-for-byte identical
// ETag: "686897696a7c876b7e"

// Weak ETag - semantically equivalent
// ETag: W/"686897696a7c876b7e"

const response = await fetch('/api/data', {
  headers: {
    'If-None-Match': 'W/"686897696a7c876b7e"'
  }
});

// Weak ETags can be used with If-None-Match
// Strong validators required for If-Range
```

### Conditional Requests for API Versioning

ETags can encode version information for API resources.

```javascript
async function updateResource(id, data, currentVersion) {
  const response = await fetch(`/api/resource/${id}`, {
    method: 'PATCH',
    headers: {
      'Content-Type': 'application/json',
      'If-Match': `"v${currentVersion}"`
    },
    body: JSON.stringify(data)
  });
  
  if (response.status === 412) {
    // Version conflict
    const latest = await fetch(`/api/resource/${id}`);
    const latestData = await latest.json();
    const latestVersion = latest.headers.get('ETag').match(/v(\d+)/)[1];
    
    return {
      conflict: true,
      currentVersion: latestVersion,
      currentData: latestData
    };
  }
  
  return await response.json();
}
```

### Polling with Conditional Requests

Conditional requests optimize polling scenarios by reducing data transfer when content hasn't changed.

```javascript
class ConditionalPoller {
  constructor(url, interval = 5000) {
    this.url = url;
    this.interval = interval;
    this.etag = null;
    this.lastModified = null;
    this.timerId = null;
    this.listeners = [];
  }
  
  async poll() {
    const headers = {};
    
    if (this.etag) {
      headers['If-None-Match'] = this.etag;
    }
    
    if (this.lastModified) {
      headers['If-Modified-Since'] = this.lastModified;
    }
    
    try {
      const response = await fetch(this.url, { headers });
      
      if (response.status === 304) {
        // No change
        console.log('No updates');
        return null;
      }
      
      if (response.ok) {
        this.etag = response.headers.get('ETag');
        this.lastModified = response.headers.get('Last-Modified');
        
        const data = await response.json();
        this.notifyListeners(data);
        return data;
      }
    } catch (error) {
      console.error('Poll failed:', error);
    }
    
    return null;
  }
  
  start() {
    this.poll(); // Initial poll
    this.timerId = setInterval(() => this.poll(), this.interval);
  }
  
  stop() {
    if (this.timerId) {
      clearInterval(this.timerId);
      this.timerId = null;
    }
  }
  
  onChange(callback) {
    this.listeners.push(callback);
  }
  
  notifyListeners(data) {
    this.listeners.forEach(callback => callback(data));
  }
}

// Usage
const poller = new ConditionalPoller('/api/notifications', 10000);

poller.onChange((data) => {
  console.log('New notifications:', data);
  updateUI(data);
});

poller.start();
```

### Conditional DELETE Requests

Conditional headers can prevent accidental deletion of modified resources.

```javascript
async function safeDelete(url, etag) {
  const response = await fetch(url, {
    method: 'DELETE',
    headers: {
      'If-Match': etag
    }
  });
  
  if (response.status === 412) {
    console.error('Resource was modified, cannot delete');
    return { success: false, reason: 'modified' };
  }
  
  if (response.status === 404) {
    console.error('Resource not found');
    return { success: false, reason: 'not_found' };
  }
  
  if (response.ok || response.status === 204) {
    return { success: true };
  }
  
  return { success: false, reason: 'unknown' };
}
```

### Browser Cache Integration

The fetch API respects HTTP caching directives, and conditional requests work with the browser's cache.

```javascript
// cache: 'default' uses standard HTTP cache with conditional requests
const response = await fetch('/api/data', {
  cache: 'default' // Browser may send If-None-Match/If-Modified-Since automatically
});

// cache: 'no-cache' forces validation with conditional requests
const freshResponse = await fetch('/api/data', {
  cache: 'no-cache' // Always validates with origin, using conditional requests
});

// cache: 'reload' bypasses cache entirely
const completelyFreshResponse = await fetch('/api/data', {
  cache: 'reload' // No conditional requests, ignores cache
});

// cache: 'force-cache' uses cache without validation
const cachedResponse = await fetch('/api/data', {
  cache: 'force-cache' // No conditional requests, uses stale cache if available
});
```

### Handling Precondition Failures

```javascript
async function handleConditionalUpdate(url, data, etag, maxRetries = 3) {
  for (let attempt = 0; attempt < maxRetries; attempt++) {
    const response = await fetch(url, {
      method: 'PUT',
      headers: {
        'Content-Type': 'application/json',
        'If-Match': etag
      },
      body: JSON.stringify(data)
    });
    
    if (response.ok) {
      return { success: true, data: await response.json() };
    }
    
    if (response.status === 412) {
      // Precondition failed - fetch latest version
      const latestResponse = await fetch(url);
      
      if (!latestResponse.ok) {
        return { success: false, error: 'fetch_failed' };
      }
      
      etag = latestResponse.headers.get('ETag');
      const latestData = await latestResponse.json();
      
      // Attempt to merge changes
      const merged = mergeData(latestData, data);
      data = merged;
      
      // Retry with new ETag
      continue;
    }
    
    return { success: false, error: `http_${response.status}` };
  }
  
  return { success: false, error: 'max_retries_exceeded' };
}

function mergeData(base, changes) {
  // Application-specific merge logic
  return { ...base, ...changes };
}
```

### Conditional Requests with Service Workers

Service workers can implement conditional request caching strategies.

```javascript
// In service worker
self.addEventListener('fetch', (event) => {
  if (event.request.method !== 'GET') return;
  
  event.respondWith(
    caches.open('conditional-cache').then(async (cache) => {
      const cached = await cache.match(event.request);
      
      if (cached) {
        const etag = cached.headers.get('ETag');
        const lastModified = cached.headers.get('Last-Modified');
        
        // Create new request with conditional headers
        const headers = new Headers(event.request.headers);
        if (etag) headers.set('If-None-Match', etag);
        if (lastModified) headers.set('If-Modified-Since', lastModified);
        
        const conditionalRequest = new Request(event.request.url, {
          method: event.request.method,
          headers: headers
        });
        
        const response = await fetch(conditionalRequest);
        
        if (response.status === 304) {
          // Return cached response
          return cached;
        }
        
        if (response.ok) {
          // Update cache
          cache.put(event.request, response.clone());
          return response;
        }
      }
      
      // No cache or error - normal fetch
      const response = await fetch(event.request);
      
      if (response.ok) {
        cache.put(event.request, response.clone());
      }
      
      return response;
    })
  );
});
```

### Time-Based Cache Invalidation

Combining conditional requests with time-based cache invalidation provides a balance between freshness and efficiency.

```javascript
class TimedConditionalCache {
  constructor(maxAge = 300000) { // 5 minutes default
    this.maxAge = maxAge;
    this.cache = new Map();
  }
  
  async fetch(url, options = {}) {
    const cached = this.cache.get(url);
    const now = Date.now();
    
    // Check if cache is fresh enough
    if (cached && (now - cached.timestamp) < this.maxAge) {
      return cached.data;
    }
    
    // Cache expired or doesn't exist - use conditional request
    const headers = new Headers(options.headers || {});
    
    if (cached) {
      if (cached.etag) headers.set('If-None-Match', cached.etag);
      if (cached.lastModified) headers.set('If-Modified-Since', cached.lastModified);
    }
    
    const response = await fetch(url, { ...options, headers });
    
    if (response.status === 304 && cached) {
      // Update timestamp but keep data
      cached.timestamp = now;
      return cached.data;
    }
    
    if (response.ok) {
      const data = await response.json();
      
      this.cache.set(url, {
        data,
        etag: response.headers.get('ETag'),
        lastModified: response.headers.get('Last-Modified'),
        timestamp: now
      });
      
      return data;
    }
    
    throw new Error(`HTTP ${response.status}`);
  }
  
  invalidate(url) {
    if (url) {
      this.cache.delete(url);
    } else {
      this.cache.clear();
    }
  }
}
```

### GraphQL with Conditional Requests

[Inference] GraphQL APIs can leverage ETags for query result caching, though this depends on server implementation.

```javascript
async function graphqlWithCache(query, variables = {}) {
  const cacheKey = `graphql:${btoa(JSON.stringify({ query, variables }))}`;
  const cached = localStorage.getItem(cacheKey);
  
  let headers = {
    'Content-Type': 'application/json'
  };
  
  if (cached) {
    const { etag } = JSON.parse(cached);
    if (etag) {
      headers['If-None-Match'] = etag;
    }
  }
  
  const response = await fetch('/graphql', {
    method: 'POST',
    headers,
    body: JSON.stringify({ query, variables })
  });
  
  if (response.status === 304) {
    const { data } = JSON.parse(cached);
    return data;
  }
  
  if (response.ok) {
    const result = await response.json();
    const etag = response.headers.get('ETag');
    
    if (etag) {
      localStorage.setItem(cacheKey, JSON.stringify({
        data: result.data,
        etag
      }));
    }
    
    return result.data;
  }
  
  throw new Error(`GraphQL request failed: ${response.status}`);
}
```

---

