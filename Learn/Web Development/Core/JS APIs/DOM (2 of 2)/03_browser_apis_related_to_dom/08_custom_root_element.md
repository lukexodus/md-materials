## Custom Root Element


### Scrollable Container

```javascript
const container = document.getElementById('scrollable-container');

const observer = new IntersectionObserver(callback, {
    root: container,
    threshold: 0.5
});

const items = container.querySelectorAll('.item');
items.forEach(item => observer.observe(item));
```

The root must be an ancestor of all observed targets. Useful for:

- Infinite scroll within modals
- Nested scrollable regions
- Custom viewport implementations

### Root Requirements

The root element must have:

- Overflow clipping (e.g., `overflow: auto`, `overflow: hidden`, `overflow: scroll`)
- Be an ancestor of the observed targets

```javascript
// Valid root
const validRoot = document.querySelector('.scroll-container');
validRoot.style.overflow = 'auto';

// Invalid - will fall back to viewport
const invalidRoot = document.createElement('div');
// Not in DOM or not an ancestor
```

