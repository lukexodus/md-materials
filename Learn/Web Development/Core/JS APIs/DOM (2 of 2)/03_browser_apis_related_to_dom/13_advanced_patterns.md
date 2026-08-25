## Advanced Patterns


### Debounced Actions

While IntersectionObserver doesn't need throttling, you may want to debounce actions:

```javascript
const timers = new WeakMap();

const observer = new IntersectionObserver(entries => {
    entries.forEach(entry => {
        clearTimeout(timers.get(entry.target));
        
        const timer = setTimeout(() => {
            if (entry.isIntersecting) {
                performExpensiveOperation(entry.target);
            }
        }, 300);
        
        timers.set(entry.target, timer);
    });
});
```

### Progressive Enhancement

Provide fallback for browsers without support:

```javascript
if ('IntersectionObserver' in window) {
    const observer = new IntersectionObserver(callback);
    observer.observe(element);
} else {
    // Fallback: load immediately or use scroll events
    element.src = element.dataset.src;
}
```

### Multiple Observers with Different Configurations

Different elements may need different observation strategies:

```javascript
const eagerObserver = new IntersectionObserver(callback, {
    rootMargin: '200px'
});

const lazyObserver = new IntersectionObserver(callback, {
    rootMargin: '0px'
});

document.querySelectorAll('.eager-load').forEach(el => {
    eagerObserver.observe(el);
});

document.querySelectorAll('.lazy-load').forEach(el => {
    lazyObserver.observe(el);
});
```

### Bidirectional Infinite Scroll

```javascript
const topSentinel = document.getElementById('top-sentinel');
const bottomSentinel = document.getElementById('bottom-sentinel');

const observer = new IntersectionObserver(entries => {
    entries.forEach(entry => {
        if (!entry.isIntersecting) return;
        
        if (entry.target === topSentinel) {
            loadPreviousContent();
        } else if (entry.target === bottomSentinel) {
            loadNextContent();
        }
    });
});

observer.observe(topSentinel);
observer.observe(bottomSentinel);
```

### Intersection Ratio Progression

Track smooth transitions through visibility ranges:

```javascript
const observer = new IntersectionObserver(entries => {
    entries.forEach(entry => {
        const ratio = entry.intersectionRatio;
        const opacity = Math.min(ratio * 2, 1);  // Fade in faster
        entry.target.style.opacity = opacity;
    });
}, {
    threshold: Array.from({ length: 101 }, (_, i) => i / 100)
});
```

### Memory Management

Proper cleanup prevents memory leaks:

```javascript
class LazyLoader {
    constructor() {
        this.observer = new IntersectionObserver(
            this.handleIntersection.bind(this)
        );
        this.elements = new Set();
    }
    
    observe(element) {
        this.elements.add(element);
        this.observer.observe(element);
    }
    
    handleIntersection(entries) {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                this.load(entry.target);
                this.elements.delete(entry.target);
                this.observer.unobserve(entry.target);
            }
        });
    }
    
    destroy() {
        this.observer.disconnect();
        this.elements.clear();
    }
}
```

