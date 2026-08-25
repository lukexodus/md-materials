## ResizeObserver


### Core Mechanics

`ResizeObserver` monitors changes to element dimensions and reports them asynchronously. Unlike listening for window resize events, ResizeObserver tracks individual elements regardless of what causes their size to change—CSS modifications, content updates, layout shifts, or viewport changes.

```javascript
const observer = new ResizeObserver((entries) => {
  entries.forEach(entry => {
    console.log('Element:', entry.target);
    console.log('New size:', entry.contentRect);
  });
});

observer.observe(element);
```

The callback executes after layout but before paint, giving you opportunity to make DOM changes without triggering additional reflows **[Inference]** in many cases, though complex changes may still cause subsequent layout recalculations.

### Entry Properties

Each `ResizeObserverEntry` provides multiple size measurements:

```javascript
const observer = new ResizeObserver((entries) => {
  entries.forEach(entry => {
    // Legacy property - content box dimensions
    const { width, height } = entry.contentRect;
    
    // Detailed box sizing information
    const contentBoxSize = entry.contentBoxSize[0];
    const borderBoxSize = entry.borderBoxSize[0];
    const devicePixelContentBoxSize = entry.devicePixelContentBoxSize[0];
    
    console.log('Content box:', contentBoxSize.inlineSize, contentBoxSize.blockSize);
    console.log('Border box:', borderBoxSize.inlineSize, borderBoxSize.blockSize);
  });
});
```

**Box Model Distinctions**:

- `contentRect`: Content area only (excludes padding, border, scrollbar)
- `contentBoxSize`: Content area with logical dimensions (inline/block)
- `borderBoxSize`: Includes padding and border
- `devicePixelContentBoxSize`: Physical pixel dimensions for canvas/WebGL rendering

The `*BoxSize` arrays contain objects with `inlineSize` and `blockSize` properties, which respect writing modes (horizontal/vertical text flow).

### Box Sizing Options

Specify which box model to observe:

```javascript
observer.observe(element, { box: 'content-box' }); // Default
observer.observe(element, { box: 'border-box' });
observer.observe(element, { box: 'device-pixel-content-box' });
```

**`content-box`**: Excludes padding and border—useful for tracking actual content space.

**`border-box`**: Includes padding and border—matches `box-sizing: border-box` CSS and `offsetWidth`/`offsetHeight`.

**`device-pixel-content-box`**: Physical pixels for high-DPI displays—critical for canvas rendering where CSS pixels don't match device pixels.

```javascript
// Canvas resolution matching
const observer = new ResizeObserver((entries) => {
  const entry = entries[0];
  const dpr = window.devicePixelRatio || 1;
  
  if (entry.devicePixelContentBoxSize) {
    // Use actual device pixels
    const { inlineSize, blockSize } = entry.devicePixelContentBoxSize[0];
    canvas.width = inlineSize;
    canvas.height = blockSize;
  } else {
    // Fallback calculation
    canvas.width = entry.contentRect.width * dpr;
    canvas.height = entry.contentRect.height * dpr;
  }
});

observer.observe(canvas, { box: 'device-pixel-content-box' });
```

### Observation Lifecycle

**Initial Notification**

The callback fires immediately after observation begins, even if size hasn't changed:

```javascript
const observer = new ResizeObserver((entries) => {
  console.log('Fired'); // Logs immediately
});

observer.observe(element); // Triggers callback synchronously on next frame
```

**[Inference]** This initial firing enables you to establish baseline dimensions without separate measurement code.

**Disconnection and Cleanup**

```javascript
// Stop observing specific element
observer.unobserve(element);

// Stop all observations
observer.disconnect();

// Resume observing
observer.observe(element);
```

Always disconnect observers when components unmount or elements are removed:

```javascript
// React example pattern
useEffect(() => {
  const observer = new ResizeObserver(callback);
  observer.observe(elementRef.current);
  
  return () => observer.disconnect(); // Cleanup
}, []);
```

### Performance Considerations

**Callback Frequency**

ResizeObserver uses requestAnimationFrame timing internally **[Inference]** based on typical browser implementation patterns. Callbacks execute at most once per frame, batching multiple size changes.

```javascript
// All three changes trigger single callback
element.style.width = '100px';
element.style.padding = '20px';
element.style.border = '5px solid black';

// Callback receives final dimensions after all changes
```

**Debouncing Not Required**

Unlike window resize events, ResizeObserver already batches changes efficiently. Additional debouncing adds latency without benefit **[Inference]** for most use cases:

```javascript
// Unnecessary pattern
const observer = new ResizeObserver(
  debounce((entries) => {
    // Already batched by browser
  }, 100)
);
```

Reserve explicit debouncing for expensive operations triggered by resize:

```javascript
const observer = new ResizeObserver((entries) => {
  // Immediate lightweight updates
  updateDimensions(entries);
  
  // Debounce heavy recalculation
  debouncedExpensiveOperation();
});
```

**Recursive Resize Prevention**

Modifying observed element dimensions within the callback can trigger observation loops:

```javascript
// Dangerous pattern
const observer = new ResizeObserver((entries) => {
  entries.forEach(entry => {
    // Modifying observed element creates loop
    entry.target.style.height = entry.contentRect.width + 'px';
  });
});
```

Browsers detect and prevent infinite loops, logging errors after threshold exceeded:

```
ResizeObserver loop completed with undelivered notifications
```

**[Inference]** This error typically indicates you're modifying observed elements in ways that create feedback cycles. Solutions:

- Modify different (unobserved) elements
- Use flags to prevent recursive updates
- Observe parent instead of element you're modifying

```javascript
// Safe pattern - modify child, observe parent
const observer = new ResizeObserver((entries) => {
  const parent = entries[0].target;
  const child = parent.querySelector('.child');
  
  // Modify child based on parent size
  child.style.height = parent.clientWidth * 0.5 + 'px';
});

observer.observe(parent);
```

### Multi-Element Observation

Single observer can track multiple elements efficiently:

```javascript
const observer = new ResizeObserver((entries) => {
  entries.forEach(entry => {
    // Identify which element changed
    if (entry.target.matches('.sidebar')) {
      handleSidebarResize(entry);
    } else if (entry.target.matches('.content')) {
      handleContentResize(entry);
    }
  });
});

document.querySelectorAll('.sidebar, .content').forEach(el => {
  observer.observe(el);
});
```

This approach reduces observer overhead compared to creating separate observers per element **[Inference]**.

### Container Queries Relationship

ResizeObserver provides programmatic access to information CSS Container Queries use declaratively:

```javascript
// JavaScript approach
const observer = new ResizeObserver((entries) => {
  entries.forEach(entry => {
    if (entry.contentRect.width < 400) {
      entry.target.classList.add('narrow');
    } else {
      entry.target.classList.remove('narrow');
    }
  });
});

observer.observe(container);
```

```css
/* CSS approach (modern browsers) */
@container (max-width: 400px) {
  .element {
    /* Styles for narrow container */
  }
}
```

**[Inference]** Prefer CSS Container Queries for style-only responsive behavior. Use ResizeObserver when you need:

- Programmatic logic beyond style application
- Dynamic calculations based on dimensions
- Canvas/WebGL rendering updates
- Third-party component integration
- Browser compatibility with older environments

### Common Patterns

**Responsive Typography**

```javascript
const observer = new ResizeObserver((entries) => {
  const width = entries[0].contentRect.width;
  const fontSize = Math.max(16, width / 30);
  
  entries[0].target.style.fontSize = fontSize + 'px';
});

observer.observe(textContainer);
```

**Viewport-Aware Components**

```javascript
// Detect when element becomes visible/hidden
const observer = new ResizeObserver((entries) => {
  entries.forEach(entry => {
    const isVisible = entry.contentRect.width > 0 && entry.contentRect.height > 0;
    
    if (isVisible) {
      initializeComponent(entry.target);
    } else {
      cleanupComponent(entry.target);
    }
  });
});
```

**Aspect Ratio Maintenance**

```javascript
const observer = new ResizeObserver((entries) => {
  const { width } = entries[0].contentRect;
  const targetRatio = 16 / 9;
  
  entries[0].target.style.height = (width / targetRatio) + 'px';
});

observer.observe(videoContainer);
```

Note: CSS `aspect-ratio` property handles this declaratively in modern browsers, making ResizeObserver unnecessary for simple aspect ratio constraints.

**Chart/Visualization Updates**

```javascript
const observer = new ResizeObserver((entries) => {
  const { width, height } = entries[0].contentRect;
  
  chart.resize({
    width: width,
    height: height
  });
  
  chart.render();
});

observer.observe(chartContainer);
```

### Error Handling

ResizeObserver callbacks can throw errors without disrupting observation:

```javascript
const observer = new ResizeObserver((entries) => {
  try {
    entries.forEach(entry => {
      riskyOperation(entry);
    });
  } catch (error) {
    console.error('Resize handler error:', error);
    // Observer continues functioning
  }
});
```

Uncaught errors in callbacks log to console but don't stop the observer **[Inference]** based on typical browser error handling for observer APIs.

### Intersection with Other APIs

**Combined with IntersectionObserver**

```javascript
const resizeObserver = new ResizeObserver((entries) => {
  updateDimensions(entries);
});

const intersectionObserver = new IntersectionObserver((entries) => {
  entries.forEach(entry => {
    if (entry.isIntersecting) {
      // Only observe size when visible
      resizeObserver.observe(entry.target);
    } else {
      resizeObserver.unobserve(entry.target);
    }
  });
});

intersectionObserver.observe(element);
```

This pattern optimizes performance by only tracking sizes of visible elements.

**MutationObserver Coordination**

```javascript
// Watch for element additions
const mutationObserver = new MutationObserver((mutations) => {
  mutations.forEach(mutation => {
    mutation.addedNodes.forEach(node => {
      if (node.nodeType === 1 && node.matches('.observable')) {
        resizeObserver.observe(node);
      }
    });
  });
});

mutationObserver.observe(container, { childList: true, subtree: true });
```

### Browser Compatibility

ResizeObserver is widely supported in modern browsers (Chrome 64+, Firefox 69+, Safari 13.1+, Edge 79+). For older environments, polyfills exist but have limitations:

- May use polling instead of native observation
- Higher performance overhead
- Less accurate timing
- Missing `devicePixelContentBoxSize` support

**[Unverified]** Polyfill behavior and performance characteristics vary by implementation.

### Memory Leak Prevention

Observers maintain strong references to observed elements:

```javascript
// Memory leak - observer prevents garbage collection
const elements = document.querySelectorAll('.dynamic');
const observer = new ResizeObserver(callback);

elements.forEach(el => observer.observe(el));

// Elements removed from DOM but still referenced by observer
elements.forEach(el => el.remove());

// Proper cleanup
observer.disconnect(); // Releases all references
```

In long-running applications, always disconnect observers when elements are no longer needed.

---

