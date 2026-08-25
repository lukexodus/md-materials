## ETags and Validation with Fetch API


### ETag Response Header

ETags are identifier strings returned by servers in the `ETag` response header that represent a specific version of a resource. The server generates these identifiers based on resource content.

```javascript
const response = await fetch('/api/data');
const etag = response.headers.get('ETag');
// Example: "33a64df551425fcc55e4d42a148795d9f25f89d4"
// Example: W/"0815" (weak ETag)
```

**ETag Format Types:**

- **Strong ETags**: `"686897696a7c876b7e"` - Byte-for-byte identical resources
- **Weak ETags**: `W/"686897696a7c876b7e"` - Semantically equivalent resources

### Conditional Requests with If-None-Match

The `If-None-Match` request header sends stored ETags to the server for validation.

```javascript
// Initial request
const response1 = await fetch('/api/data');
const etag = response1.headers.get('ETag');
const data = await response1.json();

// Store etag with data
localStorage.setItem('data', JSON.stringify(data));
localStorage.setItem('data-etag', etag);

// Subsequent request with validation
const storedEtag = localStorage.getItem('data-etag');
const response2 = await fetch('/api/data', {
  headers: {
    'If-None-Match': storedEtag
  }
});

if (response2.status === 304) {
  // Not Modified - use cached data
  const cachedData = JSON.parse(localStorage.getItem('data'));
  console.log('Using cached data');
} else {
  // Resource changed - update cache
  const newEtag = response2.headers.get('ETag');
  const newData = await response2.json();
  localStorage.setItem('data', JSON.stringify(newData));
  localStorage.setItem('data-etag', newEtag);
}
```

### 304 Not Modified Response

When ETags match, the server returns status 304 with no response body, saving bandwidth.

```javascript
const response = await fetch('/api/data', {
  headers: {
    'If-None-Match': '"abc123"'
  }
});

console.log(response.status); // 304
console.log(response.statusText); // "Not Modified"
console.log(response.ok); // false (status not in 200-299 range)

// response.body is null for 304 responses
const body = await response.text(); // Empty string
```

### Multiple ETag Validation

The `If-None-Match` header accepts multiple ETags separated by commas.

```javascript
const etags = [
  '"686897696a7c876b7e"',
  '"1234567890abcdef"',
  'W/"weak-etag"'
];

const response = await fetch('/api/data', {
  headers: {
    'If-None-Match': etags.join(', ')
  }
});

// Server returns 304 if resource matches ANY provided ETag
```

### Wildcard Validation

The `*` wildcard matches any existing resource version.

```javascript
const response = await fetch('/api/data', {
  headers: {
    'If-None-Match': '*'
  }
});

// Returns 304 if resource exists, regardless of version
// Useful for "create only if not exists" scenarios
```

### If-Match for Safe Updates

The `If-Match` header ensures updates only occur if the resource hasn't changed.

```javascript
// Read current resource
const getResponse = await fetch('/api/user/123');
const currentEtag = getResponse.headers.get('ETag');
const userData = await getResponse.json();

// Modify data
userData.email = 'newemail@example.com';

// Update with conditional request
const updateResponse = await fetch('/api/user/123', {
  method: 'PUT',
  headers: {
    'Content-Type': 'application/json',
    'If-Match': currentEtag
  },
  body: JSON.stringify(userData)
});

if (updateResponse.status === 412) {
  // Precondition Failed - resource was modified by another client
  console.error('Resource was modified by another user');
} else if (updateResponse.ok) {
  // Update succeeded
  const newEtag = updateResponse.headers.get('ETag');
  console.log('Updated successfully');
}
```

### 412 Precondition Failed

When `If-Match` validation fails, the server returns status 412.

```javascript
const response = await fetch('/api/document/5', {
  method: 'PUT',
  headers: {
    'If-Match': '"old-etag"',
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({ content: 'Updated content' })
});

if (response.status === 412) {
  // Resource changed since last read
  // Typical resolution: refetch and retry
  const freshResponse = await fetch('/api/document/5');
  const freshEtag = freshResponse.headers.get('ETag');
  const freshData = await freshResponse.json();
  
  // Resolve conflicts, then retry with fresh ETag
}
```

### Range Requests with ETags

ETags validate partial content requests using `If-Range`.

```javascript
const etag = '"abc123"';

// Request partial content only if ETag matches
const response = await fetch('/large-file.bin', {
  headers: {
    'Range': 'bytes=0-1023',
    'If-Range': etag
  }
});

if (response.status === 206) {
  // Partial Content - ETag matched
  const chunk = await response.arrayBuffer();
} else if (response.status === 200) {
  // Full content - ETag didn't match, resource changed
  const fullContent = await response.arrayBuffer();
}
```

### Combining If-Match and If-None-Match

[Inference] Both headers can appear in the same request, though this is uncommon. The server evaluates `If-Match` first.

```javascript
const response = await fetch('/api/resource', {
  method: 'PUT',
  headers: {
    'If-Match': '"current-version"',
    'If-None-Match': '"conflicting-version"',
    'Content-Type': 'application/json'
  },
  body: JSON.stringify(data)
});
```

### Weak vs Strong Comparison

Strong ETags require byte-for-byte identical content. Weak ETags allow semantic equivalence.

```javascript
// Strong ETag comparison (If-Match, If-None-Match with strong ETags)
const response1 = await fetch('/api/data', {
  headers: {
    'If-None-Match': '"abc123"' // Must match exactly
  }
});

// Weak ETag comparison (If-None-Match accepts weak ETags)
const response2 = await fetch('/api/data', {
  headers: {
    'If-None-Match': 'W/"abc123"' // Semantic equivalence
  }
});

// If-Range requires strong comparison
const response3 = await fetch('/file.bin', {
  headers: {
    'Range': 'bytes=0-1023',
    'If-Range': 'W/"weak"' // Server treats as non-matching
  }
});
```

### Cache Integration

ETags integrate with browser HTTP cache for automatic validation.

```javascript
// First request - server returns ETag
const response1 = await fetch('/api/data', {
  cache: 'default' // Use HTTP cache
});
// Response headers: ETag: "abc123", Cache-Control: max-age=3600

// Request within max-age - served from cache, no network request

// Request after max-age - browser automatically sends If-None-Match
const response2 = await fetch('/api/data', {
  cache: 'default'
});
// Browser sends: If-None-Match: "abc123"
// Server returns 304 if unchanged
```

### Cache Control Directives

Different cache directives affect ETag validation behavior.

```javascript
// Force revalidation even within max-age
const response = await fetch('/api/data', {
  cache: 'no-cache' // Always revalidate with If-None-Match
});

// Skip cache entirely
const response2 = await fetch('/api/data', {
  cache: 'reload' // Bypass cache, no If-None-Match sent
});

// Use cache without revalidation
const response3 = await fetch('/api/data', {
  cache: 'force-cache' // Use cached response without validation
});
```

### Manual Cache Management

Building a cache layer that uses ETags for validation.

```javascript
class ETagCache {
  constructor() {
    this.cache = new Map();
  }
  
  async fetch(url, options = {}) {
    const cacheKey = this.getCacheKey(url, options);
    const cached = this.cache.get(cacheKey);
    
    const headers = { ...options.headers };
    
    if (cached?.etag) {
      headers['If-None-Match'] = cached.etag;
    }
    
    const response = await fetch(url, { ...options, headers });
    
    if (response.status === 304 && cached) {
      // Return cached data
      return {
        ...cached.response,
        fromCache: true
      };
    }
    
    if (response.ok) {
      const etag = response.headers.get('ETag');
      const clonedResponse = response.clone();
      
      if (etag) {
        const data = await clonedResponse.json();
        this.cache.set(cacheKey, {
          etag,
          response: {
            status: response.status,
            headers: Object.fromEntries(response.headers.entries()),
            data
          }
        });
      }
    }
    
    return response;
  }
  
  getCacheKey(url, options) {
    return `${url}:${options.method || 'GET'}`;
  }
  
  clear() {
    this.cache.clear();
  }
}

// Usage
const cache = new ETagCache();
const response = await cache.fetch('/api/data');
```

### Optimistic Locking Pattern

Using ETags to implement optimistic concurrency control.

```javascript
async function updateWithOptimisticLock(url, updateFn, maxRetries = 3) {
  let retries = 0;
  
  while (retries < maxRetries) {
    // Fetch current version
    const getResponse = await fetch(url);
    
    if (!getResponse.ok) {
      throw new Error(`Failed to fetch: ${getResponse.status}`);
    }
    
    const etag = getResponse.headers.get('ETag');
    const currentData = await getResponse.json();
    
    // Apply updates
    const updatedData = updateFn(currentData);
    
    // Attempt conditional update
    const putResponse = await fetch(url, {
      method: 'PUT',
      headers: {
        'Content-Type': 'application/json',
        'If-Match': etag
      },
      body: JSON.stringify(updatedData)
    });
    
    if (putResponse.ok) {
      return await putResponse.json();
    }
    
    if (putResponse.status === 412) {
      // Conflict - retry
      retries++;
      console.log(`Conflict detected, retry ${retries}/${maxRetries}`);
      continue;
    }
    
    throw new Error(`Update failed: ${putResponse.status}`);
  }
  
  throw new Error('Max retries exceeded');
}

// Usage
const result = await updateWithOptimisticLock(
  '/api/counter',
  (data) => ({ ...data, count: data.count + 1 })
);
```

### DELETE with If-Match

Conditional deletion prevents accidental removal of updated resources.

```javascript
const response = await fetch('/api/resource/123', {
  method: 'DELETE',
  headers: {
    'If-Match': storedEtag
  }
});

if (response.status === 412) {
  console.error('Resource was modified, cannot delete');
} else if (response.status === 204 || response.ok) {
  console.log('Deleted successfully');
}
```

### POST with If-None-Match

Using `If-None-Match: *` to prevent duplicate resource creation.

```javascript
const response = await fetch('/api/resources', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'If-None-Match': '*'
  },
  body: JSON.stringify({
    id: 'unique-id-123',
    data: 'value'
  })
});

if (response.status === 412) {
  // Resource already exists
  console.log('Resource already created');
} else if (response.status === 201) {
  // Created successfully
  const newEtag = response.headers.get('ETag');
}
```

### Vary Header Interaction

The `Vary` header affects ETag validation for content negotiation.

```javascript
// Request with Accept-Language
const response1 = await fetch('/api/content', {
  headers: {
    'Accept-Language': 'en-US',
    'If-None-Match': '"abc123"'
  }
});
// Response headers: Vary: Accept-Language

// Same ETag, different language - may return 200 instead of 304
const response2 = await fetch('/api/content', {
  headers: {
    'Accept-Language': 'es-ES',
    'If-None-Match': '"abc123"'
  }
});
```

### ETag Generation Strategies

[Inference] While ETag generation happens server-side, understanding common strategies helps predict behavior:

**Content-based (Strong):**

- MD5/SHA hash of response body
- Guarantees byte-for-byte equality

**Metadata-based (Weak):**

- Last-Modified timestamp
- Version number
- Database row version

```javascript
// Client perspective: both appear the same
const etag1 = response.headers.get('ETag');
// Could be: "5d41402abc4b2a76b9719d911017c592" (MD5)
// Could be: "v7" (version)
// Could be: W/"1638360000" (timestamp)
```

### Response Header Extraction

Complete ETag-related header extraction pattern.

```javascript
async function fetchWithValidation(url, options = {}) {
  const response = await fetch(url, options);
  
  const validationInfo = {
    etag: response.headers.get('ETag'),
    lastModified: response.headers.get('Last-Modified'),
    cacheControl: response.headers.get('Cache-Control'),
    vary: response.headers.get('Vary'),
    age: response.headers.get('Age'),
    expires: response.headers.get('Expires')
  };
  
  return {
    response,
    validationInfo
  };
}
```

### Handling Missing ETags

Not all servers provide ETags. Fallback strategies for validation.

```javascript
async function fetchWithFallbackValidation(url, cachedData) {
  const headers = {};
  
  // Prefer ETag if available
  if (cachedData.etag) {
    headers['If-None-Match'] = cachedData.etag;
  } 
  // Fallback to Last-Modified
  else if (cachedData.lastModified) {
    headers['If-Modified-Since'] = cachedData.lastModified;
  }
  
  const response = await fetch(url, { headers });
  
  if (response.status === 304) {
    return cachedData.content;
  }
  
  const newEtag = response.headers.get('ETag');
  const newLastModified = response.headers.get('Last-Modified');
  const content = await response.json();
  
  return {
    content,
    etag: newEtag,
    lastModified: newLastModified
  };
}
```

### GraphQL Integration

ETags with GraphQL require custom implementation as GraphQL typically uses POST.

```javascript
async function graphqlFetchWithETag(query, variables, cachedEtag) {
  // Generate deterministic cache key
  const cacheKey = JSON.stringify({ query, variables });
  const cacheKeyHash = await hashString(cacheKey);
  
  const response = await fetch('/graphql', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'X-GraphQL-Cache-Key': cacheKeyHash,
      ...(cachedEtag && { 'If-None-Match': cachedEtag })
    },
    body: JSON.stringify({ query, variables })
  });
  
  // Server can return 304 based on cache key and ETag
  if (response.status === 304) {
    return getCachedResult(cacheKeyHash);
  }
  
  const etag = response.headers.get('ETag');
  const data = await response.json();
  
  if (etag) {
    cacheResult(cacheKeyHash, data, etag);
  }
  
  return data;
}
```

### SPA Navigation Caching

Using ETags for efficient single-page application data caching.

```javascript
class SPACache {
  constructor() {
    this.routeCache = new Map();
  }
  
  async fetchRoute(url) {
    const cached = this.routeCache.get(url);
    
    const response = await fetch(url, {
      headers: {
        'Accept': 'application/json',
        ...(cached?.etag && { 'If-None-Match': cached.etag })
      }
    });
    
    if (response.status === 304) {
      console.log('Using cached route data');
      return cached.data;
    }
    
    const etag = response.headers.get('ETag');
    const data = await response.json();
    
    if (etag) {
      this.routeCache.set(url, { etag, data, timestamp: Date.now() });
    }
    
    return data;
  }
  
  invalidate(url) {
    this.routeCache.delete(url);
  }
  
  invalidatePattern(pattern) {
    for (const [url] of this.routeCache) {
      if (url.includes(pattern)) {
        this.routeCache.delete(url);
      }
    }
  }
}
```

### Stale-While-Revalidate Pattern

Serving stale content while revalidating in the background.

```javascript
async function fetchWithStaleWhileRevalidate(url, cachedData) {
  // Return cached data immediately if available
  const returnCached = cachedData?.data 
    ? Promise.resolve(cachedData.data)
    : null;
  
  // Start revalidation in background
  const revalidatePromise = (async () => {
    const response = await fetch(url, {
      headers: {
        ...(cachedData?.etag && { 'If-None-Match': cachedData.etag })
      }
    });
    
    if (response.status === 304) {
      // Still fresh
      return { fresh: true, data: cachedData.data };
    }
    
    const etag = response.headers.get('ETag');
    const data = await response.json();
    
    // Update cache
    updateCache(url, { etag, data });
    
    return { fresh: false, data };
  })();
  
  if (returnCached) {
    // Return cached immediately, revalidate in background
    revalidatePromise.catch(console.error);
    return cachedData.data;
  }
  
  // No cache, wait for network
  const result = await revalidatePromise;
  return result.data;
}
```

### Batch Validation Requests

Validating multiple resources with a single request.

```javascript
async function batchValidate(resources) {
  // Construct If-None-Match with all ETags
  const etags = resources
    .map(r => r.etag)
    .filter(Boolean)
    .join(', ');
  
  const response = await fetch('/api/batch-validate', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'If-None-Match': etags
    },
    body: JSON.stringify({
      resources: resources.map(r => ({
        url: r.url,
        etag: r.etag
      }))
    })
  });
  
  // Server returns which resources have changed
  const validationResults = await response.json();
  // { changed: ['/api/user/1'], unchanged: ['/api/user/2', '/api/user/3'] }
  
  return validationResults;
}
```

### ETag with Server-Sent Events

[Inference] Using ETags to resume SSE streams after disconnection.

```javascript
let lastEventETag = null;

async function connectSSE(url) {
  const headers = {
    'Accept': 'text/event-stream'
  };
  
  if (lastEventETag) {
    headers['If-None-Match'] = lastEventETag;
  }
  
  const response = await fetch(url, { headers });
  
  if (response.status === 304) {
    // No new events, can reconnect with same state
    console.log('No new events since last connection');
    return;
  }
  
  // Server may include ETag in response headers
  const etag = response.headers.get('ETag');
  
  const reader = response.body.getReader();
  const decoder = new TextDecoder();
  
  while (true) {
    const { done, value } = await reader.read();
    if (done) break;
    
    const text = decoder.decode(value);
    // Process SSE events
    
    // Update ETag as events are consumed
    if (etag) lastEventETag = etag;
  }
}
```

### CORS Preflight with Conditional Headers

Conditional headers may trigger CORS preflight requests.

```javascript
// Simple request - no preflight
const response1 = await fetch('https://api.example.com/data', {
  headers: {
    'If-None-Match': '"abc123"' // Safe header
  }
});

// Preflight required - If-Match not in CORS-safelisted headers
const response2 = await fetch('https://api.example.com/data', {
  method: 'PUT',
  headers: {
    'Content-Type': 'application/json',
    'If-Match': '"abc123"' // Triggers preflight
  },
  body: JSON.stringify(data)
});

// Server must include in preflight response:
// Access-Control-Allow-Headers: If-Match, Content-Type
```

### Error Boundary Integration

Handling ETag validation errors within application error boundaries.

```javascript
class ETagFetchError extends Error {
  constructor(message, status, etag) {
    super(message);
    this.name = 'ETagFetchError';
    this.status = status;
    this.etag = etag;
  }
}

async function safeFetchWithETag(url, etag) {
  try {
    const response = await fetch(url, {
      headers: {
        ...(etag && { 'If-None-Match': etag })
      }
    });
    
    if (response.status === 304) {
      return { status: 'not-modified', etag };
    }
    
    if (!response.ok) {
      throw new ETagFetchError(
        `HTTP ${response.status}`,
        response.status,
        response.headers.get('ETag')
      );
    }
    
    const newEtag = response.headers.get('ETag');
    const data = await response.json();
    
    return { status: 'success', data, etag: newEtag };
    
  } catch (error) {
    if (error instanceof ETagFetchError) {
      // Handle ETag-specific errors
      console.error('ETag validation failed:', error);
    }
    throw error;
  }
}
```

---

