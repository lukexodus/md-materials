## Debugging Strategies


### Logging Intersection Data

```javascript
const observer = new IntersectionObserver(entries => {
    entries.forEach(entry => {
        console.log({
            target: entry.target.id,
            isIntersecting: entry.isIntersecting,
            intersectionRatio: entry.intersectionRatio,
            boundingClientRect: entry.boundingClientRect,
            intersectionRect: entry.intersectionRect,
            time: entry.time
        });
    });
});
```

### Visual Debugging

Add visual indicators to observed elements:

```javascript
const observer = new IntersectionObserver(entries => {
    entries.forEach(entry => {
        if (entry.isIntersecting) {
            entry.target.style.outline = '3px solid green';
        } else {
            entry.target.style.outline = '3px solid red';
        }
    });
});
```

### Tracking Observation State

```javascript
const observedElements = new WeakMap();

function observeElement(element) {
    observer.observe(element);
    observedElements.set(element, {
        observedAt: Date.now(),
        intersectionCount: 0
    });
}

const observer = new IntersectionObserver(entries => {
    entries.forEach(entry => {
        const state = observedElements.get(entry.target);
        if (state) {
            state.intersectionCount++;
            state.lastIntersection = Date.now();
        }
    });
});
```

---

