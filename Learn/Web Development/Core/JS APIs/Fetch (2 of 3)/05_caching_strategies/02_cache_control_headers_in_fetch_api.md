## Cache-Control Headers in Fetch API


### Understanding Cache Directives

Cache-Control headers control how HTTP responses are cached by browsers, CDNs, and intermediate proxies. When using the fetch API, these headers determine whether responses are stored, for how long, and under what conditions they can be reused.

The Cache-Control header contains one or more directives separated by commas. Each directive modifies caching behavior for the request or response.

### Response Directives

#### max-age

Specifies the maximum time in seconds a response remains fresh. After this period, the cached response becomes stale.

```javascript
// Response with max-age
fetch('https://api.example.com/data')
  .then(response => {
    console.log(response.headers.get('Cache-Control')); // "max-age=3600"
  });
```

A `max-age=3600` means the response can be cached for one hour without revalidation.

#### s-maxage

Overrides max-age for shared caches (CDNs, proxy servers) but not private browser caches. Ignored by private caches.

```
Cache-Control: max-age=600, s-maxage=3600
```

Private caches use 600 seconds, shared caches use 3600 seconds.

#### no-cache

Forces caches to revalidate with the origin server before using cached responses. The response can still be cached, but must be validated each time.

```
Cache-Control: no-cache
```

With conditional requests:

```javascript
fetch('https://api.example.com/data', {
  headers: {
    'If-None-Match': etag // ETag from previous response
  }
});
```

#### no-store

Prevents any caching of the request or response. Use for sensitive data.

```
Cache-Control: no-store
```

The browser stores nothing about the request or response in any cache.

#### must-revalidate

Once a response becomes stale, caches must revalidate with the origin server before using it. Without this, some caches might serve stale content under certain conditions.

```
Cache-Control: max-age=3600, must-revalidate
```

#### proxy-revalidate

Similar to must-revalidate but only applies to shared caches, not private browser caches.

#### public

Indicates the response may be cached by any cache, including CDNs and proxies, even if the response would normally be non-cacheable (e.g., authenticated requests).

```
Cache-Control: public, max-age=86400
```

#### private

Restricts caching to the user's browser only. Shared caches must not store the response.

```
Cache-Control: private, max-age=3600
```

Commonly used for user-specific data.

#### immutable

Indicates the response body will never change during its freshness lifetime. Browsers can skip revalidation even when users perform a manual refresh.

```
Cache-Control: max-age=31536000, immutable
```

Ideal for versioned static assets (e.g., `app.v123.js`).

#### stale-while-revalidate

Allows serving stale content while asynchronously revalidating in the background.

```
Cache-Control: max-age=600, stale-while-revalidate=1800
```

Fresh for 10 minutes, then serves stale content for up to 30 more minutes while fetching fresh data.

#### stale-if-error

Permits serving stale content if revalidation fails or the origin server is unavailable.

```
Cache-Control: max-age=600, stale-if-error=86400
```

Serves stale content for up to 24 hours if errors occur during revalidation.

### Request Directives

#### no-cache (request)

Forces intermediate caches to revalidate with the origin server.

```javascript
fetch('https://api.example.com/data', {
  headers: {
    'Cache-Control': 'no-cache'
  }
});
```

#### no-store (request)

Requests that caches not store anything about this request or response.

#### max-age (request)

Client specifies the maximum age of a cached response it will accept.

```javascript
fetch('https://api.example.com/data', {
  headers: {
    'Cache-Control': 'max-age=0'
  }
});
```

`max-age=0` forces revalidation.

#### max-stale

Client indicates willingness to accept stale responses.

```javascript
fetch('https://api.example.com/data', {
  headers: {
    'Cache-Control': 'max-stale=600'
  }
});
```

Accepts responses up to 10 minutes past their expiration.

#### min-fresh

Client wants responses that will remain fresh for at least the specified number of seconds.

```javascript
fetch('https://api.example.com/data', {
  headers: {
    'Cache-Control': 'min-fresh=300'
  }
});
```

#### only-if-cached

Client wants only cached responses. If no cached response exists, returns a 504 Gateway Timeout.

```javascript
fetch('https://api.example.com/data', {
  headers: {
    'Cache-Control': 'only-if-cached'
  }
});
```

### Fetch API Cache Modes

The fetch API provides the `cache` option to control request caching behavior independent of headers:

#### default

Standard caching behavior following HTTP semantics.

```javascript
fetch(url, { cache: 'default' });
```

#### no-store

Bypasses cache entirely for both request and response.

```javascript
fetch(url, { cache: 'no-store' });
```

#### reload

Ignores cache for request but updates cache with response.

```javascript
fetch(url, { cache: 'reload' });
```

Equivalent to setting `Cache-Control: no-cache` on the request.

#### no-cache

Checks cache for matching entry, validates with server using conditional requests, then uses cached response if valid.

```javascript
fetch(url, { cache: 'no-cache' });
```

#### force-cache

Uses cached response regardless of staleness. Only fetches from network if no cached response exists.

```javascript
fetch(url, { cache: 'force-cache' });
```

#### only-if-cached

Returns cached response or fails. Must be used with `mode: 'same-origin'`.

```javascript
fetch(url, { 
  cache: 'only-if-cached',
  mode: 'same-origin'
});
```

### Conditional Requests and Revalidation

Cache revalidation uses conditional request headers:

#### ETag and If-None-Match

```javascript
// Initial request
const response = await fetch('https://api.example.com/data');
const etag = response.headers.get('ETag');

// Subsequent request with revalidation
const revalidated = await fetch('https://api.example.com/data', {
  headers: {
    'If-None-Match': etag
  }
});

if (revalidated.status === 304) {
  // Use cached response
} else {
  // New content available
}
```

#### Last-Modified and If-Modified-Since

```javascript
// Initial request
const response = await fetch('https://api.example.com/data');
const lastModified = response.headers.get('Last-Modified');

// Subsequent request
const revalidated = await fetch('https://api.example.com/data', {
  headers: {
    'If-Modified-Since': lastModified
  }
});
```

### Cache Busting Strategies

#### Query Parameters

```javascript
fetch(`https://api.example.com/data?t=${Date.now()}`);
```

Each request gets a unique URL, bypassing cache.

#### Versioned URLs

```javascript
const version = 'v2.1.0';
fetch(`https://api.example.com/data?version=${version}`);
```

#### Cache Control Headers

```javascript
fetch('https://api.example.com/data', {
  cache: 'reload',
  headers: {
    'Cache-Control': 'no-cache'
  }
});
```

### Interaction with Service Workers

Service workers intercept fetch requests and can implement custom caching strategies:

```javascript
self.addEventListener('fetch', event => {
  event.respondWith(
    caches.match(event.request).then(cachedResponse => {
      if (cachedResponse) {
        // Return cached response
        return cachedResponse;
      }
      
      return fetch(event.request).then(response => {
        // Cache new response
        return caches.open('v1').then(cache => {
          cache.put(event.request, response.clone());
          return response;
        });
      });
    })
  );
});
```

Service workers can override Cache-Control headers from the server.

### Common Patterns

#### API Responses with Short-Term Caching

```
Cache-Control: private, max-age=300
```

Caches user-specific data for 5 minutes in browser only.

#### Static Assets with Long-Term Caching

```
Cache-Control: public, max-age=31536000, immutable
```

Caches versioned assets for one year with immutability guarantee.

#### Dynamic Content with Revalidation

```
Cache-Control: no-cache, must-revalidate
```

Always validates before serving, ensures freshness.

#### CDN-Optimized Responses

```
Cache-Control: public, max-age=300, s-maxage=3600
```

Browser caches for 5 minutes, CDN caches for 1 hour.

#### Offline-First with Stale Content

```
Cache-Control: max-age=600, stale-while-revalidate=86400
```

Serves stale content while revalidating, enabling offline access.

### Debugging Cache Behavior

#### Inspecting Response Headers

```javascript
fetch('https://api.example.com/data')
  .then(response => {
    const cacheControl = response.headers.get('Cache-Control');
    const age = response.headers.get('Age');
    const expires = response.headers.get('Expires');
    
    console.log('Cache-Control:', cacheControl);
    console.log('Age:', age);
    console.log('Expires:', expires);
  });
```

#### Chrome DevTools

Network tab shows:

- Request headers (including `Cache-Control`)
- Response headers
- Cache status (from disk cache, from memory cache)
- Size (actual size or "from cache")

#### Testing Cache Behavior

```javascript
// First request - should hit network
await fetch('https://api.example.com/data');

// Second request - may use cache depending on directives
await fetch('https://api.example.com/data');

// Force fresh request
await fetch('https://api.example.com/data', { cache: 'reload' });
```

### Security Considerations

#### Sensitive Data

Always use `no-store` for sensitive information:

```
Cache-Control: no-store, no-cache, must-revalidate, private
```

#### Authenticated Requests

Use `private` to prevent shared cache storage:

```
Cache-Control: private, max-age=300
```

#### CORS and Caching

Cached responses must match CORS requirements. Vary header ensures proper cache separation:

```
Cache-Control: public, max-age=3600
Vary: Origin
```

### Limitations and Browser Differences

Different browsers may implement caching heuristics differently when no explicit Cache-Control is provided. Some browsers apply heuristic caching based on Last-Modified dates.

The `cache` option in fetch may not work identically across all browsers. The `only-if-cached` mode has restricted usage and browser-specific behavior.

Service worker caches operate independently of HTTP cache and have their own storage quotas and eviction policies.

### Performance Optimization

#### Minimize Cache Misses

Use consistent URLs and avoid unnecessary query parameters that create unique cache entries.

#### Balance Freshness and Performance

```
Cache-Control: max-age=3600, stale-while-revalidate=86400
```

Provides good performance while maintaining reasonable freshness.

#### Leverage CDN Caching

```
Cache-Control: public, s-maxage=604800, max-age=300
```

CDN caches for 7 days, browser caches for 5 minutes.

#### Use Immutable for Static Assets

```
Cache-Control: public, max-age=31536000, immutable
```

Eliminates unnecessary revalidation for versioned assets during page reloads.

---

