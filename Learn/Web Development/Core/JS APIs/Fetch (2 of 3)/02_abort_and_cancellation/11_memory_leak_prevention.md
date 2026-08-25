## Memory Leak Prevention


### Avoid Holding Response References

```javascript
// Bad - holds entire response in memory
const responses = [];
for (const url of urls) {
  const response = await fetch(url);
  responses.push(response);
}

// Good - process and discard
for (const url of urls) {
  const response = await fetch(url);
  const data = await response.json();
  processData(data);
  // response is now eligible for garbage collection
}
```

### Response Body Consumption

```javascript
// Always consume the response body
const response = await fetch('/api/data');

// If you don't need the data, still consume it
if (!response.ok) {
  await response.text(); // Consume and discard
  throw new Error(`HTTP ${response.status}`);
}

// Or explicitly ignore
if (response.status === 204) {
  // No content, nothing to consume
} else {
  await response.json();
}
```

### EventSource Alternative Pattern

```javascript
// For long-lived connections, consider cleanup
const eventSource = new EventSource('/events');

eventSource.onmessage = (event) => {
  console.log(event.data);
};

// Cleanup
const cleanup = () => {
  eventSource.close();
};

// In React
useEffect(() => {
  const es = new EventSource('/events');
  es.onmessage = handleMessage;
  
  return () => es.close();
}, []);
```

