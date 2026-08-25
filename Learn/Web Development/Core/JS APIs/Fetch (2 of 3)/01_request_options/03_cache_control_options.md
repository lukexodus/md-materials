## Cache Control Options


The `cache` option in the Fetch API controls how the request interacts with the browser's HTTP cache, determining whether to use cached responses, when to validate them, and how to store new responses.

### `default` Mode

Standard browser caching behavior following HTTP cache semantics.

**Behavior:**

- Checks HTTP cache first for valid cached response
- If fresh cache entry exists (within `max-age` or not expired), returns it immediately without network request
- If stale cache entry exists, performs conditional request (with `If-None-Match` or `If-Modified-Since`)
- If no cache entry, performs normal network request
- Stores response according to cache headers (`Cache-Control`, `Expires`, `ETag`, etc.)

**Cache decision logic:**

```
1. Check cache for entry
2. If found and fresh → Return cached response
3. If found and stale → Send conditional request (304 possible)
4. If not found → Send normal request
5. Store response if cacheable
```

**Use cases:**

- Standard web requests where normal caching is desired
- Performance optimization through standard HTTP caching
- Most API calls where caching semantics are appropriate
- Default behavior for most applications

**Example:**

```javascript
fetch('/api/data', {
  cache: 'default'
})
// Respects Cache-Control: max-age=3600
// Will use cached response if less than 1 hour old
```

**Server header interaction:**

```javascript
// Server response:
// Cache-Control: max-age=300
// ETag: "abc123"

// First request - cache miss
fetch('/api/profile', {cache: 'default'}) // Network request

// Second request within 5 minutes - cache hit
fetch('/api/profile', {cache: 'default'}) // Returns cached, no network

// Third request after 5 minutes - conditional
fetch('/api/profile', {cache: 'default'}) 
// Sends: If-None-Match: "abc123"
// Gets: 304 Not Modified (or 200 with new content)
```

### `no-store` Mode

Completely bypasses cache for both reading and writing.

**Behavior:**

- Never checks cache for existing entries
- Always performs network request
- Never stores response in cache
- Behaves as if cache doesn't exist
- Most aggressive "always fresh" option

**Use cases:**

- Highly sensitive data that should never be cached (passwords, tokens, PII)
- Real-time data where even brief caching is unacceptable
- One-time use responses (password reset tokens, nonces)
- Financial transactions or time-sensitive operations
- Compliance requirements against caching

**Example:**

```javascript
fetch('/api/account/balance', {
  cache: 'no-store'
})
// Always hits network
// Response never stored in cache
// No trace in cache after request
```

**Security-critical usage:**

```javascript
async function loginUser(credentials) {
  return fetch('/auth/login', {
    method: 'POST',
    cache: 'no-store', // Never cache credentials or tokens
    headers: {'Content-Type': 'application/json'},
    body: JSON.stringify(credentials)
  });
}

async function getAccountDetails() {
  return fetch('/api/account/sensitive', {
    cache: 'no-store', // Fresh data always, no caching
    headers: {'Authorization': `Bearer ${token}`}
  });
}
```

**Comparison with server headers:**

- `cache: 'no-store'` in fetch → Client-side enforcement
- `Cache-Control: no-store` from server → Server instruction
- Using both provides defense in depth

### `reload` Mode

Bypasses cache on read but allows writing to cache.

**Behavior:**

- Ignores any cached entries, always performs network request
- Does not send conditional headers (`If-None-Match`, `If-Modified-Since`)
- Unconditional network request (cannot receive 304)
- Stores response in cache according to cache headers
- Similar to "hard refresh" or Ctrl+Shift+R in browsers

**Use cases:**

- Force refresh of potentially stale data
- User-initiated refresh actions
- Cache invalidation scenarios
- Ensuring absolutely latest version is retrieved
- Debugging cache issues

**Example:**

```javascript
fetch('/api/news', {
  cache: 'reload'
})
// Ignores cached response (even if fresh)
// Performs unconditional GET
// Server must send full response (no 304)
// New response stored in cache
```

**User-initiated refresh:**

```javascript
document.getElementById('refreshButton').addEventListener('click', async () => {
  const data = await fetch('/api/dashboard', {
    cache: 'reload' // Force fresh data
  }).then(r => r.json());
  
  updateUI(data);
});
```

**Cache invalidation pattern:**

```javascript
async function updateAndRefresh() {
  // 1. Update data on server
  await fetch('/api/data', {
    method: 'PUT',
    body: JSON.stringify(newData)
  });
  
  // 2. Force reload to get updated version
  const fresh = await fetch('/api/data', {
    cache: 'reload' // Bypass stale cache
  }).then(r => r.json());
  
  return fresh;
}
```

### `no-cache` Mode

Validates cached entries before using them.

**Behavior:**

- Checks cache for entries
- If entry exists, performs conditional request with validation headers
- Sends `If-None-Match` (with ETag) or `If-Modified-Since` (with Last-Modified)
- Can receive 304 Not Modified if content unchanged
- Always contacts server but may save bandwidth with 304
- Stores response according to cache headers

**Difference from `reload`:**

- `no-cache`: Always validates, but can use cached content if server confirms freshness (304)
- `reload`: Never validates, always gets full response

**Use cases:**

- Ensuring data freshness while allowing bandwidth optimization
- Situations where validation is required but 304 responses are acceptable
- Balance between freshness and performance
- APIs with good ETag support

**Example:**

```javascript
fetch('/api/content', {
  cache: 'no-cache'
})
// Has cached entry with ETag: "xyz789"
// Sends: If-None-Match: "xyz789"
// Receives: 304 Not Modified → Uses cached response
// OR: 200 OK with new content → Uses and caches new response
```

**Conditional request flow:**

```javascript
// Cached response metadata:
// ETag: "v1.2.3"
// Last-Modified: Wed, 21 Oct 2024 07:28:00 GMT

fetch('/api/resource', {
  cache: 'no-cache'
})
// Request includes:
// If-None-Match: "v1.2.3"
// If-Modified-Since: Wed, 21 Oct 2024 07:28:00 GMT

// Server response A (unchanged):
// 304 Not Modified
// → Browser uses cached response body

// Server response B (changed):
// 200 OK
// ETag: "v1.2.4"
// → Browser uses new response and updates cache
```

**Practical comparison:**

```javascript
// Scenario: Cached entry exists, content unchanged on server

// With 'no-cache': 
// - Small request with validation headers
// - 304 response (no body)
// - Uses cached response
// - Bandwidth: ~1-2 KB

// With 'reload':
// - Full request
// - 200 response with complete body
// - Replaces cached response with identical content
// - Bandwidth: Full response size (could be MBs)
```

### `force-cache` Mode

Prefers cached entries regardless of staleness.

**Behavior:**

- Checks cache for any entry (fresh or stale)
- If any cached entry exists, uses it immediately without validation
- Ignores cache expiration (`max-age`, `Expires`)
- Only performs network request if no cache entry exists
- Does not send conditional headers
- Stores new responses according to cache headers

**Use cases:**

- Performance-critical scenarios where staleness is acceptable
- Offline-first applications
- Reducing server load when approximate data is sufficient
- Resource-constrained environments (limited bandwidth)
- Non-critical or slow-changing data

**Example:**

```javascript
fetch('/api/config', {
  cache: 'force-cache'
})
// Cached entry expired 2 hours ago → Still uses it
// No network request unless cache is completely empty
```

**Offline-first pattern:**

```javascript
async function getDataOfflineFirst(url) {
  try {
    // Try cache first, even if stale
    const response = await fetch(url, {
      cache: 'force-cache'
    });
    return await response.json();
  } catch (error) {
    // If cache miss and network fails
    throw new Error('No cached data and network unavailable');
  }
}
```

**Performance optimization:**

```javascript
// Load non-critical resources from cache
async function loadStaticAssets() {
  const assets = [
    '/static/logo.png',
    '/static/footer-content.json',
    '/static/translations.json'
  ];
  
  return Promise.all(
    assets.map(url => 
      fetch(url, {cache: 'force-cache'}) // Use stale cache if available
    )
  );
}
```

**Staleness trade-off:**

```javascript
// User profile that changes infrequently
fetch('/api/user/preferences', {
  cache: 'force-cache' // Acceptable if stale
})

// vs.

// Stock price that must be current
fetch('/api/stocks/current-price', {
  cache: 'no-store' // Staleness unacceptable
})
```

### `only-if-cached` Mode

Only succeeds if valid cache entry exists.

**Behavior:**

- Only checks cache, never performs network request
- Returns cached entry if it exists and is valid (not expired)
- Fails with network error if no valid cache entry
- Must be used with `mode: 'same-origin'`
- Designed for offline scenarios

**Restriction:** Can only be used with `mode: 'same-origin'`. Using it with other modes causes TypeError.

**Use cases:**

- Checking if resource is available offline
- Guaranteed offline-only operations
- Performance-critical scenarios where network latency is unacceptable
- Testing cache state
- Progressive web apps in offline mode

**Example:**

```javascript
fetch('/api/data', {
  cache: 'only-if-cached',
  mode: 'same-origin'
})
.then(response => {
  // Cache hit - data available offline
  return response.json();
})
.catch(error => {
  // Cache miss - no network attempted
  console.log('Not available offline');
});
```

**Offline availability check:**

```javascript
async function isAvailableOffline(url) {
  try {
    await fetch(url, {
      cache: 'only-if-cached',
      mode: 'same-origin'
    });
    return true; // Cache hit
  } catch {
    return false; // Cache miss
  }
}

// Usage
if (await isAvailableOffline('/api/data')) {
  console.log('Can work offline');
} else {
  console.log('Requires network connection');
}
```

**PWA offline mode:**

```javascript
async function getDataOfflineOnly(url) {
  try {
    const response = await fetch(url, {
      cache: 'only-if-cached',
      mode: 'same-origin'
    });
    
    if (!response.ok) {
      throw new Error('Cached response not OK');
    }
    
    return await response.json();
  } catch (error) {
    throw new Error('Data not available offline');
  }
}
```

**Invalid usage [Unverified - exact error message may vary]:**

```javascript
// This will throw TypeError
fetch('https://api.example.com/data', {
  cache: 'only-if-cached',
  mode: 'cors' // Invalid combination
})
// TypeError: Failed to fetch
```

### Cache Mode Comparison Table

|Mode|Checks Cache|Uses Stale|Validates|Network if No Cache|Writes Cache|
|---|---|---|---|---|---|
|`default`|Yes|No|If stale|Yes|Yes|
|`no-store`|No|N/A|No|Always|No|
|`reload`|No|N/A|No|Always|Yes|
|`no-cache`|Yes|No|Always|Yes|Yes|
|`force-cache`|Yes|Yes|No|Yes|Yes|
|`only-if-cached`|Yes|No|No|Never|No|

### Cache Mode Selection Decision Tree

**Need guaranteed fresh data?**

- Critical freshness (sensitive/real-time) → `no-store`
- Important freshness (willing to validate) → `no-cache`
- Standard freshness (trust HTTP semantics) → `default`

**Performance priority over freshness?**

- Acceptable to use stale → `force-cache`
- Must be offline-capable → `only-if-cached` + `same-origin`

**User-initiated action?**

- Hard refresh / force reload → `reload`

**Never cache this data?**

- Security/privacy/compliance → `no-store`

### Interaction with HTTP Cache Headers

**Server `Cache-Control` headers affecting fetch `cache` option:**

```javascript
// Server sends: Cache-Control: no-store
fetch('/api/data', {cache: 'default'})
// Browser respects server directive, won't cache even though 'default'

// Server sends: Cache-Control: max-age=3600
fetch('/api/data', {cache: 'default'})
// Cached for 1 hour

fetch('/api/data', {cache: 'force-cache'})
// Uses cache even after 1 hour expires

fetch('/api/data', {cache: 'no-cache'})
// Ignores max-age, always validates
```

**Client `cache` option overriding server headers [Inference - browser-side control]:**

```javascript
// Server says: Cache-Control: max-age=86400 (cache for 1 day)

fetch('/api/data', {cache: 'no-store'})
// Client overrides, doesn't cache despite server instruction

fetch('/api/data', {cache: 'reload'})
// Client overrides, bypasses existing cache despite fresh entry
```

### Common Patterns and Best Practices

**API data freshness levels:**

```javascript
// Real-time critical data
const stockPrice = await fetch('/api/stock-price', {
  cache: 'no-store'
});

// Important but validates OK
const userProfile = await fetch('/api/profile', {
  cache: 'no-cache'
});

// Standard resources
const config = await fetch('/api/config', {
  cache: 'default'
});

// Static/slow-changing
const translations = await fetch('/i18n/en.json', {
  cache: 'force-cache'
});
```

**User-triggered refresh:**

```javascript
let lastFetchMode = 'default';

async function fetchData(userTriggered = false) {
  const mode = userTriggered ? 'reload' : 'default';
  lastFetchMode = mode;
  
  return fetch('/api/data', {
    cache: mode
  }).then(r => r.json());
}

// Auto-refresh
setInterval(() => fetchData(false), 60000); // Uses cache if fresh

// Manual refresh button
refreshBtn.onclick = () => fetchData(true); // Forces new data
```

**Offline-first with fallback:**

```javascript
async function fetchWithOfflineFallback(url) {
  try {
    // Try network first (default caching)
    return await fetch(url, {
      cache: 'default'
    });
  } catch (networkError) {
    // Network failed, try cache only
    try {
      return await fetch(url, {
        cache: 'only-if-cached',
        mode: 'same-origin'
      });
    } catch (cacheError) {
      throw new Error('Unavailable online and offline');
    }
  }
}
```

**Cache invalidation after mutation:**

```javascript
async function updateResource(id, data) {
  // 1. Send update
  await fetch(`/api/resource/${id}`, {
    method: 'PUT',
    cache: 'no-store', // Don't cache mutation
    body: JSON.stringify(data)
  });
  
  // 2. Fetch updated version, bypassing stale cache
  return fetch(`/api/resource/${id}`, {
    cache: 'reload' // Force fresh data
  }).then(r => r.json());
}
```

**Conditional caching based on network:**

```javascript
async function smartFetch(url) {
  const connection = navigator.connection;
  
  // On slow connection, prefer cache
  if (connection && connection.effectiveType === '2g') {
    return fetch(url, {cache: 'force-cache'});
  }
  
  // On fast connection, validate
  if (connection && connection.effectiveType === '4g') {
    return fetch(url, {cache: 'no-cache'});
  }
  
  // Default behavior
  return fetch(url, {cache: 'default'});
}
```

**Privacy-sensitive requests:**

```javascript
async function handleSensitiveData() {
  // Never cache auth tokens
  const authResponse = await fetch('/auth/token', {
    cache: 'no-store'
  });
  
  // Never cache PII
  const userData = await fetch('/api/user/private-data', {
    cache: 'no-store',
    credentials: 'include'
  });
  
  // Never cache payment info
  const paymentData = await fetch('/api/payment-methods', {
    cache: 'no-store'
  });
  
  return {authResponse, userData, paymentData};
}
```

### Cache Behavior with Different Request Methods

**GET requests:** All cache modes fully applicable. GET is the only method that typically interacts meaningfully with HTTP cache.

**POST/PUT/DELETE requests:**

```javascript
// POST with cache option
fetch('/api/data', {
  method: 'POST',
  cache: 'no-store', // Common for mutations
  body: JSON.stringify(data)
})
// Cache modes apply to response, but mutations rarely cached by browsers
```

[Inference] Most browsers don't cache POST/PUT/DELETE responses by default regardless of cache headers, though `no-store` provides explicit guarantee.

### Service Worker Cache vs Fetch Cache Option

These are separate caching layers:

**Fetch `cache` option:**

- Controls browser's HTTP cache
- Automatic based on HTTP headers
- Shared across tabs/windows
- Cleared by browser cache clearing

**Service Worker caches:**

```javascript
// Service Worker Cache API (separate from fetch cache option)
self.addEventListener('fetch', event => {
  event.respondWith(
    caches.match(event.request).then(cached => {
      return cached || fetch(event.request, {
        cache: 'default' // Still uses HTTP cache
      }).then(response => {
        return caches.open('v1').then(cache => {
          cache.put(event.request, response.clone());
          return response;
        });
      });
    })
  );
});
```

**Both can be used together:**

- Service Worker intercepts first
- Can check Service Worker cache
- Falls back to fetch with cache option
- Fetch uses HTTP cache
- Response can be stored in both caches

---

