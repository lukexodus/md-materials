## Callback Timing and Execution


### Initial Observation

The callback fires immediately (asynchronously) when `observe()` is called:

```javascript
const observer = new IntersectionObserver(entries => {
    console.log('Callback fired');
});

observer.observe(element);
// Callback fires shortly after, reporting initial state
```

This initial callback reports the current intersection state, even if threshold is not met.

### Asynchronous Execution

Callbacks execute asynchronously but are queued:

```javascript
console.log('1. Before observe');
observer.observe(element);
console.log('2. After observe');
// '3. Callback fired' appears after both

const observer = new IntersectionObserver(entries => {
    console.log('3. Callback fired');
});
```

### Callback Execution Context

The callback runs in the main thread but is scheduled by the browser's intersection observer task queue. [Inference] This means it doesn't block rendering but still executes synchronously once invoked.

