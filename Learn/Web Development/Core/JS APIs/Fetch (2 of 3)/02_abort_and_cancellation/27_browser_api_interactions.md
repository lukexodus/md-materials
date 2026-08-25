## Browser API Interactions


### Service Workers and Race Conditions

Service workers intercept fetch requests and can introduce additional race conditions:

```javascript
// Service worker cache race
self.addEventListener('fetch', (event) => {
  event.respondWith(
    Promise.race([
      caches.match(event.request),
      fetch(event.request)
    ]).then(response => {
      // First response wins, but may be stale cache
      return response || fetch(event.request);
    })
  );
});
```

Cache-first, network-first, or stale-while-revalidate strategies each have different race characteristics.

### Intersection with Browser Back/Forward Cache

Pages in back/forward cache may have pending requests that resume when restored, potentially racing with new requests initiated on page restoration.

```javascript
// Handle page visibility changes
document.addEventListener('visibilitychange', () => {
  if (document.hidden) {
    // Page going into bfcache, cancel requests
    abortAllRequests();
  }
});
```

### Request Priority and Browser Scheduling

[Inference] Browsers schedule requests based on resource type (HTML, CSS, JS, images) and priority hints. Fetch requests default to medium priority but can race with higher-priority resource loading, affecting completion order.

```javascript
fetch(url, {
  priority: 'high' // or 'low', 'auto'
});
```

Priority hints influence browser scheduling but don't eliminate race conditions.

---


