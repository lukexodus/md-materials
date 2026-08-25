## Edge Cases and Limitations


### Zero-Size Elements

Elements with no dimensions (0x0) are never considered intersecting:

```javascript
const zeroSizeEl = document.createElement('div');
// width and height are 0
observer.observe(zeroSizeEl);
// isIntersecting will always be false
```

### Display: none Elements

Hidden elements don't trigger intersections:

```javascript
const hidden = document.querySelector('.hidden');
// CSS: .hidden { display: none; }
observer.observe(hidden);
// No intersection until display changes
```

### Iframe Boundaries

IntersectionObserver observes within the same browsing context. Cross-origin iframes require separate observers:

```javascript
// In parent window
const parentObserver = new IntersectionObserver(callback);
parentObserver.observe(iframe);  // Observes iframe element

// Inside iframe (separate observer needed)
const iframeObserver = new IntersectionObserver(callback);
iframeObserver.observe(iframeElement);
```

### Transform and Position Changes

CSS transforms don't trigger intersection recalculations by default:

```javascript
element.style.transform = 'translateY(100px)';
// May not immediately trigger intersection callback
```

[Inference] Browsers optimize by not recalculating on every transform. Layout changes (scrolling, resizing) trigger recalculation.

### Threshold Precision

Intersection ratios are floating-point numbers subject to precision limits:

```javascript
// Don't use exact equality
if (entry.intersectionRatio === 0.5) { }  // ❌ May miss due to precision

// Use ranges
if (Math.abs(entry.intersectionRatio - 0.5) < 0.01) { }  // ✓ Better
```

### Root Null vs Document Element

```javascript
// These are similar but not identical
const observer1 = new IntersectionObserver(callback, { root: null });
const observer2 = new IntersectionObserver(callback, { 
    root: document.documentElement 
});
```

`root: null` uses the viewport, which may differ from `document.documentElement` in terms of coordinate space and behavior with browser UI elements (address bar, etc.).

