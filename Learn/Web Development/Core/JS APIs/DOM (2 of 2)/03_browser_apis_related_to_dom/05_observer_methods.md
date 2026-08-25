## Observer Methods


### observe()

Start observing a target element:

```javascript
observer.observe(targetElement);
```

Can observe multiple elements with the same observer:

```javascript
const elements = document.querySelectorAll('.observe-me');
elements.forEach(el => observer.observe(el));
```

### unobserve()

Stop observing a specific target:

```javascript
observer.unobserve(targetElement);
```

Commonly used for cleanup or when element no longer needs observation:

```javascript
entries.forEach(entry => {
    if (entry.isIntersecting) {
        // Handle intersection
        observer.unobserve(entry.target); // Stop observing
    }
});
```

### disconnect()

Stop observing all targets:

```javascript
observer.disconnect();
```

Typically called during cleanup:

```javascript
// Component cleanup
componentWillUnmount() {
    this.observer.disconnect();
}
```

### takeRecords()

Returns array of all queued `IntersectionObserverEntry` objects and clears the queue:

```javascript
const records = observer.takeRecords();
```

Useful for synchronous processing before disconnecting:

```javascript
const pending = observer.takeRecords();
pending.forEach(entry => processEntry(entry));
observer.disconnect();
```

