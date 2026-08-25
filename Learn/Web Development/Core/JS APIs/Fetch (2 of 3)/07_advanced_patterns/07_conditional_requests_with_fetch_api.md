## Conditional Requests with Fetch API


### Understanding Conditional Request Mechanics

Conditional requests allow clients to request resources only when specific conditions are met, reducing bandwidth usage and improving performance. The server evaluates request headers and returns either the full resource (200) or indicates the cached version is still valid (304 Not Modified).

### ETag-Based Conditional Requests

#### Basic ETag Usage

ETags (Entity Tags) are identifiers assigned by servers to specific versions of resources. Clients include these in conditional requests to validate cached content.

```javascript
// Initial request - server returns ETag
const initialResponse = await fetch('/api/data');
const etag = initialResponse.headers.get('ETag');
// Example ETag: "33a64df551425fcc55e4d42a148795d9f25f89d4"

// Store data and ETag
const data = await initialResponse.json();
localStorage.setItem('data', JSON.stringify(data));
localStorage.setItem('data-etag', etag);
```

#### If-None-Match Header

The `If-None-Match` header sends the ETag to the server, which responds with 304 if the resource hasn't changed.

```javascript
async function fetchWithETag(url, cachedETag) {
  const headers = {};
  
  if (cachedETag) {
    headers['If-None-Match'] = cachedETag;
  }
  
  const response = await fetch(url, { headers });
  
  if (response.status === 304) {
    // Resource hasn't changed, use cached version
    const cachedData = localStorage.getItem('data');
    return {
      fromCache: true,
      data: JSON.parse(cachedData)
    };
  }
  
  // Resource changed, update cache
  const newETag = response.headers.get('ETag');
  const data = await response.json();
  
  localStorage.setItem('data', JSON.stringify(data));
  localStorage.setItem('data-etag', newETag);
  
  return {
    fromCache: false,
    data
  };
}

// Usage
const cachedETag = localStorage.getItem('data-etag');
const result = await fetchWithETag('/api/data', cachedETag);
```

#### Weak vs Strong ETags

```javascript
// Strong ETag - byte-for-byte identical
// "33a64df551425fcc55e4d42a148795d9f25f89d4"

// Weak ETag - semantically equivalent but may differ in bytes
// W/"33a64df551425fcc55e4d42a148795d9f25f89d4"

function parseETag(etagHeader) {
  if (!etagHeader) return null;
  
  const isWeak = etagHeader.startsWith('W/');
  const value = etagHeader.replace(/^W\//, '').replace(/"/g, '');
  
  return {
    isWeak,
    value,
    original: etagHeader
  };
}

// Server behavior consideration
async function fetchWithETagValidation(url, cachedETag) {
  const etag = parseETag(cachedETag);
  
  const response = await fetch(url, {
    headers: {
      'If-None-Match': etag.original
    }
  });
  
  return {
    status: response.status,
    modified: response.status !== 304,
    etag: response.headers.get('ETag')
  };
}
```

#### Multiple ETags in If-None-Match

```javascript
async function fetchWithMultipleETags(url, etagList) {
  // Server matches against any ETag in the list
  const etagHeader = etagList.join(', ');
  
  const response = await fetch(url, {
    headers: {
      'If-None-Match': etagHeader
    }
  });
  
  return response;
}

// Usage: Check against multiple cached versions
const etags = [
  '"v1-abc123"',
  '"v2-def456"',
  'W/"v3-ghi789"'
];

const response = await fetchWithMultipleETags('/api/resource', etags);
```

### Last-Modified Based Conditional Requests

#### If-Modified-Since Header

The `If-Modified-Since` header uses timestamps to validate cached resources.

```javascript
async function fetchIfModifiedSince(url, lastModified) {
  const headers = {};
  
  if (lastModified) {
    headers['If-Modified-Since'] = lastModified;
  }
  
  const response = await fetch(url, { headers });
  
  if (response.status === 304) {
    console.log('Resource not modified since', lastModified);
    return null; // Use cached version
  }
  
  // Resource was modified
  const newLastModified = response.headers.get('Last-Modified');
  const data = await response.json();
  
  // Store for future requests
  localStorage.setItem('data', JSON.stringify(data));
  localStorage.setItem('data-last-modified', newLastModified);
  
  return data;
}

// Usage
const lastModified = localStorage.getItem('data-last-modified');
// Example: "Wed, 21 Oct 2015 07:28:00 GMT"
const data = await fetchIfModifiedSince('/api/data', lastModified);
```

#### Date Format Handling

```javascript
function formatHTTPDate(date) {
  // HTTP dates must be in GMT/UTC
  return date.toUTCString();
}

function parseHTTPDate(dateString) {
  return new Date(dateString);
}

// Example usage
const cacheDate = new Date('2024-01-15T10:30:00Z');
const httpDate = formatHTTPDate(cacheDate);
// "Mon, 15 Jan 2024 10:30:00 GMT"

const response = await fetch('/api/data', {
  headers: {
    'If-Modified-Since': httpDate
  }
});
```

#### Combining ETag and Last-Modified

```javascript
async function fetchWithBothValidators(url, validators) {
  const headers = {};
  
  if (validators.etag) {
    headers['If-None-Match'] = validators.etag;
  }
  
  if (validators.lastModified) {
    headers['If-Modified-Since'] = validators.lastModified;
  }
  
  const response = await fetch(url, { headers });
  
  // Server evaluates both; typically ETag takes precedence
  if (response.status === 304) {
    return {
      modified: false,
      cached: true
    };
  }
  
  return {
    modified: true,
    cached: false,
    etag: response.headers.get('ETag'),
    lastModified: response.headers.get('Last-Modified'),
    data: await response.json()
  };
}

// Usage
const result = await fetchWithBothValidators('/api/data', {
  etag: '"abc123"',
  lastModified: 'Mon, 15 Jan 2024 10:30:00 GMT'
});
```

### Conditional PUT and POST Requests

#### If-Match for Safe Updates

The `If-Match` header ensures updates only occur if the resource hasn't changed, preventing lost updates.

```javascript
async function conditionalUpdate(url, data, currentETag) {
  const response = await fetch(url, {
    method: 'PUT',
    headers: {
      'Content-Type': 'application/json',
      'If-Match': currentETag
    },
    body: JSON.stringify(data)
  });
  
  if (response.status === 412) {
    // Precondition Failed - resource was modified
    throw new Error('Resource was modified by another client');
  }
  
  if (response.status === 428) {
    // Precondition Required - server requires If-Match
    throw new Error('ETag required for this operation');
  }
  
  return response;
}

// Usage with optimistic locking
try {
  const etag = localStorage.getItem('resource-etag');
  await conditionalUpdate('/api/resource/123', updatedData, etag);
  console.log('Update successful');
} catch (error) {
  // Fetch latest version and retry
  const latest = await fetch('/api/resource/123');
  const latestETag = latest.headers.get('ETag');
  
  // Prompt user to merge changes or retry
  console.log('Conflict detected, manual intervention needed');
}
```

#### If-Unmodified-Since for Updates

```javascript
async function updateIfUnmodified(url, data, lastModified) {
  const response = await fetch(url, {
    method: 'PUT',
    headers: {
      'Content-Type': 'application/json',
      'If-Unmodified-Since': lastModified
    },
    body: JSON.stringify(data)
  });
  
  if (response.status === 412) {
    return {
      success: false,
      reason: 'modified',
      message: 'Resource was modified after ' + lastModified
    };
  }
  
  return {
    success: true,
    newLastModified: response.headers.get('Last-Modified')
  };
}
```

#### Atomic Update Pattern

```javascript
async function atomicUpdate(url, updateFn, maxRetries = 3) {
  let attempts = 0;
  
  while (attempts < maxRetries) {
    // Fetch current version
    const current = await fetch(url);
    const etag = current.headers.get('ETag');
    const data = await current.json();
    
    // Apply update function
    const updated = updateFn(data);
    
    // Attempt conditional update
    const response = await fetch(url, {
      method: 'PUT',
      headers: {
        'Content-Type': 'application/json',
        'If-Match': etag
      },
      body: JSON.stringify(updated)
    });
    
    if (response.ok) {
      return {
        success: true,
        attempts: attempts + 1,
        data: await response.json()
      };
    }
    
    if (response.status === 412) {
      attempts++;
      // Retry with fresh data
      continue;
    }
    
    throw new Error(`Update failed with status ${response.status}`);
  }
  
  throw new Error(`Failed after ${maxRetries} attempts due to conflicts`);
}

// Usage: Increment counter atomically
const result = await atomicUpdate('/api/counter', data => ({
  ...data,
  value: data.value + 1
}));
```

### Range Requests with Conditional Headers

#### Conditional Range Requests

```javascript
async function conditionalRangeRequest(url, range, etag) {
  const headers = {
    'Range': `bytes=${range.start}-${range.end}`
  };
  
  if (etag) {
    headers['If-Range'] = etag;
  }
  
  const response = await fetch(url, { headers });
  
  if (response.status === 206) {
    // Partial content returned
    const contentRange = response.headers.get('Content-Range');
    // Example: "bytes 0-1023/4096"
    
    return {
      partial: true,
      data: await response.arrayBuffer(),
      range: contentRange
    };
  }
  
  if (response.status === 200) {
    // Full content returned (ETag didn't match or no If-Range sent)
    return {
      partial: false,
      data: await response.arrayBuffer()
    };
  }
  
  throw new Error(`Unexpected status: ${response.status}`);
}

// Usage: Resume download
const etag = localStorage.getItem('download-etag');
const bytesDownloaded = parseInt(localStorage.getItem('bytes-downloaded') || '0');

const result = await conditionalRangeRequest('/large-file.zip', {
  start: bytesDownloaded,
  end: bytesDownloaded + 1024 * 1024 // Download 1MB chunk
}, etag);
```

#### If-Range with Last-Modified

```javascript
async function resumeDownload(url, lastModified, startByte) {
  const response = await fetch(url, {
    headers: {
      'Range': `bytes=${startByte}-`,
      'If-Range': lastModified // Can be ETag or Last-Modified date
    }
  });
  
  if (response.status === 206) {
    // Resource unchanged, partial content received
    return {
      resumed: true,
      data: await response.blob()
    };
  }
  
  if (response.status === 200) {
    // Resource changed, full content received (start over)
    return {
      resumed: false,
      restartRequired: true,
      data: await response.blob()
    };
  }
  
  throw new Error('Range request failed');
}
```

### Cache Validation Strategies

#### Validation with Cache API

```javascript
async function fetchWithCacheValidation(request) {
  const cache = await caches.open('validated-cache-v1');
  const cached = await cache.match(request);
  
  if (!cached) {
    // Not in cache, fetch normally
    const response = await fetch(request);
    await cache.put(request, response.clone());
    return response;
  }
  
  // Extract validators from cached response
  const cachedETag = cached.headers.get('ETag');
  const cachedLastModified = cached.headers.get('Last-Modified');
  
  // Create conditional request
  const headers = new Headers(request.headers);
  if (cachedETag) {
    headers.set('If-None-Match', cachedETag);
  }
  if (cachedLastModified) {
    headers.set('If-Modified-Since', cachedLastModified);
  }
  
  const validationRequest = new Request(request, { headers });
  const response = await fetch(validationRequest);
  
  if (response.status === 304) {
    // Not modified, return cached version
    return cached;
  }
  
  // Modified, update cache
  await cache.put(request, response.clone());
  return response;
}

// Usage in service worker
self.addEventListener('fetch', event => {
  event.respondWith(fetchWithCacheValidation(event.request));
});
```

#### Stale-While-Revalidate with Conditionals

```javascript
async function staleWhileRevalidateConditional(request) {
  const cache = await caches.open('swr-cache-v1');
  const cached = await cache.match(request);
  
  // Return stale content immediately
  const responsePromise = cached 
    ? Promise.resolve(cached.clone())
    : fetch(request);
  
  // Revalidate in background
  const revalidate = async () => {
    if (!cached) {
      const fresh = await fetch(request);
      await cache.put(request, fresh.clone());
      return;
    }
    
    const validators = {
      etag: cached.headers.get('ETag'),
      lastModified: cached.headers.get('Last-Modified')
    };
    
    const headers = new Headers(request.headers);
    if (validators.etag) {
      headers.set('If-None-Match', validators.etag);
    }
    if (validators.lastModified) {
      headers.set('If-Modified-Since', validators.lastModified);
    }
    
    const validationRequest = new Request(request, { headers });
    const response = await fetch(validationRequest);
    
    if (response.status !== 304) {
      // Update cache with fresh content
      await cache.put(request, response.clone());
    }
  };
  
  // Don't await revalidation
  revalidate().catch(err => console.error('Revalidation failed:', err));
  
  return responsePromise;
}
```

### Conditional DELETE Operations

#### Safe Resource Deletion

```javascript
async function conditionalDelete(url, etag) {
  const response = await fetch(url, {
    method: 'DELETE',
    headers: {
      'If-Match': etag
    }
  });
  
  if (response.status === 412) {
    return {
      deleted: false,
      reason: 'modified',
      message: 'Resource was modified, cannot delete'
    };
  }
  
  if (response.status === 404) {
    return {
      deleted: false,
      reason: 'not-found',
      message: 'Resource already deleted or never existed'
    };
  }
  
  if (response.status === 204 || response.status === 200) {
    return {
      deleted: true
    };
  }
  
  throw new Error(`Unexpected status: ${response.status}`);
}

// Usage: Prevent accidental deletion
const etag = localStorage.getItem('document-etag');
const result = await conditionalDelete('/api/documents/123', etag);

if (!result.deleted) {
  alert(`Cannot delete: ${result.message}`);
}
```

### Conditional Request with Custom Logic

#### Application-Level Versioning

```javascript
async function fetchWithVersionCheck(url, localVersion) {
  const response = await fetch(url, {
    headers: {
      'X-Client-Version': localVersion.toString()
    }
  });
  
  const serverVersion = parseInt(response.headers.get('X-Server-Version') || '0');
  
  if (serverVersion > localVersion) {
    // Server has newer version
    const data = await response.json();
    
    return {
      updated: true,
      version: serverVersion,
      data
    };
  }
  
  return {
    updated: false,
    version: localVersion
  };
}
```

#### Custom Conditional Headers

```javascript
async function fetchWithCustomCondition(url, conditions) {
  const headers = {};
  
  // Custom business logic conditions
  if (conditions.contentHash) {
    headers['X-Content-Hash'] = conditions.contentHash;
  }
  
  if (conditions.schemaVersion) {
    headers['X-Schema-Version'] = conditions.schemaVersion.toString();
  }
  
  if (conditions.clientTimestamp) {
    headers['X-Client-Timestamp'] = conditions.clientTimestamp;
  }
  
  const response = await fetch(url, { headers });
  
  // Custom status codes for different conditions
  if (response.status === 499) { // Custom: content hash matches
    return { useCache: true };
  }
  
  if (response.status === 498) { // Custom: schema mismatch
    return { 
      useCache: false, 
      requiresUpdate: true,
      newSchema: await response.json()
    };
  }
  
  return {
    useCache: false,
    data: await response.json()
  };
}
```

### Optimization Patterns

#### Batch Conditional Requests

```javascript
async function batchConditionalFetch(requests) {
  // Group requests by domain for efficiency
  const grouped = requests.reduce((acc, req) => {
    const domain = new URL(req.url).origin;
    if (!acc[domain]) acc[domain] = [];
    acc[domain].push(req);
    return acc;
  }, {});
  
  const results = [];
  
  for (const [domain, reqs] of Object.entries(grouped)) {
    const batchResults = await Promise.all(
      reqs.map(async req => {
        const cache = await caches.open('batch-cache');
        const cached = await cache.match(req.url);
        
        if (!cached) {
          const response = await fetch(req.url);
          await cache.put(req.url, response.clone());
          return { url: req.url, fromCache: false, response };
        }
        
        const etag = cached.headers.get('ETag');
        const validationResponse = await fetch(req.url, {
          headers: etag ? { 'If-None-Match': etag } : {}
        });
        
        if (validationResponse.status === 304) {
          return { url: req.url, fromCache: true, response: cached };
        }
        
        await cache.put(req.url, validationResponse.clone());
        return { url: req.url, fromCache: false, response: validationResponse };
      })
    );
    
    results.push(...batchResults);
  }
  
  return results;
}

// Usage
const urls = [
  '/api/users',
  '/api/posts',
  '/api/comments'
].map(url => new Request(url));

const results = await batchConditionalFetch(urls);
const cacheHits = results.filter(r => r.fromCache).length;
console.log(`Cache hit rate: ${(cacheHits / results.length * 100).toFixed(1)}%`);
```

#### Predictive Revalidation

```javascript
class ConditionalFetchManager {
  constructor(revalidationInterval = 60000) {
    this.cache = new Map();
    this.revalidationInterval = revalidationInterval;
    this.revalidationTimers = new Map();
  }
  
  async fetch(url, options = {}) {
    const cached = this.cache.get(url);
    
    if (cached) {
      // Return cached immediately
      this.scheduleRevalidation(url);
      return cached.response.clone();
    }
    
    const response = await fetch(url, options);
    
    this.cache.set(url, {
      response: response.clone(),
      etag: response.headers.get('ETag'),
      lastModified: response.headers.get('Last-Modified'),
      timestamp: Date.now()
    });
    
    this.scheduleRevalidation(url);
    
    return response;
  }
  
  scheduleRevalidation(url) {
    // Clear existing timer
    if (this.revalidationTimers.has(url)) {
      clearTimeout(this.revalidationTimers.get(url));
    }
    
    // Schedule new revalidation
    const timer = setTimeout(() => {
      this.revalidate(url);
    }, this.revalidationInterval);
    
    this.revalidationTimers.set(url, timer);
  }
  
  async revalidate(url) {
    const cached = this.cache.get(url);
    if (!cached) return;
    
    const headers = {};
    if (cached.etag) {
      headers['If-None-Match'] = cached.etag;
    }
    if (cached.lastModified) {
      headers['If-Modified-Since'] = cached.lastModified;
    }
    
    try {
      const response = await fetch(url, { headers });
      
      if (response.status !== 304) {
        // Update cache
        this.cache.set(url, {
          response: response.clone(),
          etag: response.headers.get('ETag'),
          lastModified: response.headers.get('Last-Modified'),
          timestamp: Date.now()
        });
      }
      
      // Schedule next revalidation
      this.scheduleRevalidation(url);
    } catch (error) {
      console.error('Revalidation failed:', error);
      // Retry later
      this.scheduleRevalidation(url);
    }
  }
  
  clear() {
    this.revalidationTimers.forEach(timer => clearTimeout(timer));
    this.revalidationTimers.clear();
    this.cache.clear();
  }
}

// Usage
const manager = new ConditionalFetchManager(30000); // Revalidate every 30s

const response1 = await manager.fetch('/api/data');
const response2 = await manager.fetch('/api/data'); // Instant from cache
// Automatically revalidates in background
```

### Error Handling in Conditional Requests

#### Handling Validation Failures

```javascript
async function robustConditionalFetch(url, validators, fallback) {
  const headers = {};
  
  if (validators.etag) {
    headers['If-None-Match'] = validators.etag;
  }
  if (validators.lastModified) {
    headers['If-Modified-Since'] = validators.lastModified;
  }
  
  try {
    const response = await fetch(url, { headers });
    
    if (response.status === 304) {
      // Valid cache, use fallback
      return {
        cached: true,
        data: fallback
      };
    }
    
    if (response.ok) {
      return {
        cached: false,
        data: await response.json()
      };
    }
    
    throw new Error(`HTTP ${response.status}`);
  } catch (error) {
    // Network error or server error
    if (fallback) {
      console.warn('Using fallback due to error:', error);
      return {
        cached: true,
        error: true,
        data: fallback
      };
    }
    
    throw error;
  }
}
```

#### Retry Strategy for Precondition Failures

```javascript
async function retryConditionalUpdate(url, updateFn, options = {}) {
  const {
    maxRetries = 3,
    backoffMs = 1000,
    onConflict = null
  } = options;
  
  for (let attempt = 0; attempt < maxRetries; attempt++) {
    try {
      // Fetch current state
      const current = await fetch(url);
      if (!current.ok) {
        throw new Error(`Fetch failed: ${current.status}`);
      }
      
      const etag = current.headers.get('ETag');
      const data = await current.json();
      
      // Apply update
      const updated = updateFn(data);
      
      // Conditional update
      const response = await fetch(url, {
        method: 'PUT',
        headers: {
          'Content-Type': 'application/json',
          'If-Match': etag
        },
        body: JSON.stringify(updated)
      });
      
      if (response.ok) {
        return {
          success: true,
          attempts: attempt + 1,
          data: await response.json()
        };
      }
      
      if (response.status === 412) {
        // Conflict, retry
        if (onConflict) {
          await onConflict(attempt, data, updated);
        }
        
        // Exponential backoff
        await new Promise(resolve => 
          setTimeout(resolve, backoffMs * Math.pow(2, attempt))
        );
        
        continue;
      }
      
      throw new Error(`Update failed: ${response.status}`);
    } catch (error) {
      if (attempt === maxRetries - 1) {
        throw error;
      }
    }
  }
  
  throw new Error(`Failed after ${maxRetries} attempts`);
}

// Usage
const result = await retryConditionalUpdate(
  '/api/counter',
  data => ({ ...data, count: data.count + 1 }),
  {
    maxRetries: 5,
    backoffMs: 500,
    onConflict: (attempt, current, intended) => {
      console.log(`Conflict on attempt ${attempt + 1}`);
      console.log('Current:', current);
      console.log('Intended:', intended);
    }
  }
);
```

---

