## Performance Characteristics


### Efficiency Advantages

The IntersectionObserver API is optimized at the browser level:

- **No polling**: Callbacks fire only when intersection state changes
- **No forced reflow**: Browsers batch geometry calculations
- **Passive observation**: Doesn't block the main thread
- **Optimized for multiple targets**: Single observer can watch many elements efficiently

### Comparison with Scroll Events

Traditional approach problems:

```javascript
// ❌ Inefficient
window.addEventListener('scroll', () => {
    elements.forEach(el => {
        const rect = el.getBoundingClientRect();  // Forces reflow
        if (rect.top < window.innerHeight) {
            // Handle visibility
        }
    });
});
```

IntersectionObserver benefits:

- No need for `getBoundingClientRect()` calls
- No throttling/debouncing required
- Browser handles optimization automatically
- Works across frame boundaries

### Batching Behavior

[Inference] The browser batches intersection changes and delivers them asynchronously. Multiple changes may be reported in a single callback invocation:

```javascript
const observer = new IntersectionObserver(entries => {
    console.log(`Processing ${entries.length} changes`);
    // May receive multiple entries at once
});
```

