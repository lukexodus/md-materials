## IntersectionObserverEntry Properties


Each entry object contains:

### Intersection Geometry

```javascript
entry.boundingClientRect    // Target's bounding rectangle
entry.intersectionRect      // Visible portion of target
entry.rootBounds           // Root's bounding rectangle
```

All rectangles are `DOMRectReadOnly` objects with properties: `x`, `y`, `width`, `height`, `top`, `right`, `bottom`, `left`.

### Intersection Data

```javascript
entry.intersectionRatio    // 0.0 to 1.0, visible ratio
entry.isIntersecting      // Boolean, target intersects root
entry.target              // The observed DOM element
entry.time                // DOMHighResTimeStamp when change occurred
```

**intersectionRatio**: Ratio of `intersectionRect` area to `boundingClientRect` area. Equals 0 when not visible, 1.0 when fully visible.

**isIntersecting**: `true` when target element intersects with root. More reliable than checking `intersectionRatio > 0` because it handles edge cases consistently.

**time**: Timestamp relative to the time origin, measured in milliseconds.

