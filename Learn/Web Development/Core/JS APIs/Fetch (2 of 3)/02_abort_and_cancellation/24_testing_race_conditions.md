## Testing Race Conditions


### Simulating Delayed Responses

Introduce artificial delays to expose race conditions:

```javascript
async function fetchWithDelay(url, delay) {
  const response = await fetch(url);
  await new Promise(resolve => setTimeout(resolve, delay));
  return response.json();
}

// Test: later request completes first
await Promise.all([
  fetchWithDelay('/api/data?v=1', 200),
  fetchWithDelay('/api/data?v=2', 50)
]);
```

Variable delays help identify order-dependent bugs.

### Parallel Request Testing

Fire multiple requests simultaneously to verify handling:

```javascript
async function testRaceCondition() {
  const requests = Array.from({ length: 10 }, (_, i) => 
    fetch(`/api/data?id=${i}`)
  );
  
  const responses = await Promise.all(requests);
  const results = await Promise.all(
    responses.map(r => r.json())
  );
  
  // Verify consistency
  verifyResults(results);
}
```

### Network Condition Simulation

Use browser DevTools or libraries to simulate slow/unreliable networks:

```javascript
// Using service worker for network simulation
self.addEventListener('fetch', (event) => {
  const delay = Math.random() * 2000; // Random 0-2s delay
  
  event.respondWith(
    new Promise(resolve => {
      setTimeout(() => {
        resolve(fetch(event.request));
      }, delay);
    })
  );
});
```

