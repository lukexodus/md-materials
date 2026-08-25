## Root Margin Behavior


### Expanding the Root

```javascript
const observer = new IntersectionObserver(callback, {
    rootMargin: '50px'  // Trigger 50px before entering viewport
});
```

Positive margins expand the intersection area. Useful for preloading content before it becomes visible.

### Shrinking the Root

```javascript
const observer = new IntersectionObserver(callback, {
    rootMargin: '-20px'  // Trigger only when 20px inside viewport
});
```

Negative margins shrink the intersection area. Ensures elements are fully visible before triggering.

### Asymmetric Margins

```javascript
const observer = new IntersectionObserver(callback, {
    rootMargin: '0px 0px -100px 0px'  // Top Right Bottom Left
});
```

Delays triggering until element is 100px into viewport from bottom.

### Percentage-Based Margins

```javascript
const observer = new IntersectionObserver(callback, {
    rootMargin: '10%'  // 10% of root dimensions
});
```

[Inference] Percentage values are calculated relative to the root element's dimensions (width for horizontal, height for vertical).

