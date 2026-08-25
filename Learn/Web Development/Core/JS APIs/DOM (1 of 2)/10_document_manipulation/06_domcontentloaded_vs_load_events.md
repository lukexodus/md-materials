## DOMContentLoaded vs load Events


### DOMContentLoaded Event

Fires when the HTML document has been completely parsed and the DOM tree is fully constructed, without waiting for stylesheets, images, or subframes to finish loading.

**Basic Characteristics**

```javascript
document.addEventListener('DOMContentLoaded', (event) => {
  // DOM is ready, safe to manipulate
  console.log('DOM fully parsed');
});

// Properties
event.bubbles;           // false
event.cancelable;        // false
event.composed;          // false
event.target;            // document
```

**Timing**

```javascript
// Fires after:
// - HTML parsing complete
// - DOM tree constructed
// - Synchronous scripts executed
// - Deferred scripts executed

// Fires before:
// - Images loaded
// - Stylesheets loaded (with exception, see below)
// - Iframes loaded
// - window.onload
```

**Script Blocking Behavior**

```javascript
// Synchronous scripts block DOMContentLoaded
<script src="sync.js"></script>
// DOMContentLoaded waits for sync.js to download and execute

// Async scripts do NOT block
<script async src="async.js"></script>
// DOMContentLoaded can fire before async.js completes

// Defer scripts DO block
<script defer src="defer.js"></script>
// DOMContentLoaded waits for all deferred scripts

// Module scripts behave like defer
<script type="module" src="module.js"></script>
// DOMContentLoaded waits for module execution
```

**Stylesheet Interaction**

Stylesheets block DOMContentLoaded only if there are scripts after them:

```html
<!-- Case 1: Stylesheet does NOT block DOMContentLoaded -->
<link rel="stylesheet" href="styles.css">
<!-- No scripts after, DOMContentLoaded can fire before CSS loads -->

<!-- Case 2: Stylesheet DOES block DOMContentLoaded -->
<link rel="stylesheet" href="styles.css">
<script src="script.js"></script>
<!-- Script waits for stylesheet, DOMContentLoaded waits for script -->

<!-- Case 3: Stylesheet does NOT block -->
<link rel="stylesheet" href="styles.css">
<script async src="script.js"></script>
<!-- Async script doesn't block, so stylesheet doesn't block -->
```

**Registration After Event Fires**

```javascript
// If DOMContentLoaded already fired, listener never executes
document.addEventListener('DOMContentLoaded', () => {
  console.log('This may never run if added too late');
});

// Safe alternative: check readyState
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', initFunction);
} else {
  // DOM already loaded, run immediately
  initFunction();
}

// Or more concise
function ready(fn) {
  if (document.readyState !== 'loading') {
    fn();
  } else {
    document.addEventListener('DOMContentLoaded', fn);
  }
}

ready(() => {
  console.log('DOM ready');
});
```

**Event Target**

```javascript
// Only fires on document
document.addEventListener('DOMContentLoaded', handler);

// Does NOT bubble to window
window.addEventListener('DOMContentLoaded', handler); // Won't fire

// Use capturing on window if needed
window.addEventListener('DOMContentLoaded', handler, true); // Works
```

**Common Use Cases**

```javascript
// 1. Safe DOM manipulation
document.addEventListener('DOMContentLoaded', () => {
  const button = document.getElementById('myButton');
  button.addEventListener('click', handleClick);
});

// 2. Initialize libraries
document.addEventListener('DOMContentLoaded', () => {
  initializeTooltips();
  setupFormValidation();
});

// 3. Read layout information
document.addEventListener('DOMContentLoaded', () => {
  const height = element.offsetHeight; // Safe to read
});
```

### load Event

Fires when the entire page and all dependent resources (stylesheets, images, iframes, scripts) have finished loading.

**Basic Characteristics**

```javascript
window.addEventListener('load', (event) => {
  // Everything loaded
  console.log('Page fully loaded');
});

// Properties
event.bubbles;           // false
event.cancelable;        // false
event.target;            // window, document, or specific element
```

**Timing**

```javascript
// Fires after:
// - DOMContentLoaded
// - All stylesheets loaded
// - All images loaded
// - All iframes loaded
// - All synchronous, async, and deferred scripts loaded
// - All other subresources loaded

// Order of events
document.addEventListener('DOMContentLoaded', () => {
  console.log('1. DOM ready');
});

window.addEventListener('load', () => {
  console.log('2. Everything loaded');
});
```

**Event Targets**

```javascript
// window.onload - entire page
window.addEventListener('load', () => {
  console.log('Page loaded');
});

// document.onload - not standard, avoid
document.addEventListener('load', () => {
  // This is unreliable, use window or DOMContentLoaded
});

// Element-specific load events
const img = document.querySelector('img');
img.addEventListener('load', () => {
  console.log('Image loaded:', img.width, img.height);
});

const iframe = document.querySelector('iframe');
iframe.addEventListener('load', () => {
  console.log('Iframe content loaded');
});

const script = document.createElement('script');
script.addEventListener('load', () => {
  console.log('Script loaded and executed');
});
script.src = 'external.js';
document.head.appendChild(script);

const link = document.createElement('link');
link.addEventListener('load', () => {
  console.log('Stylesheet loaded');
});
link.rel = 'stylesheet';
link.href = 'styles.css';
document.head.appendChild(link);
```

**Registration After Event Fires**

```javascript
// Similar issue as DOMContentLoaded
if (document.readyState === 'complete') {
  // Already loaded
  initFunction();
} else {
  window.addEventListener('load', initFunction);
}
```

**Common Use Cases**

```javascript
// 1. Work with image dimensions
window.addEventListener('load', () => {
  const img = document.querySelector('img');
  console.log('Image size:', img.naturalWidth, img.naturalHeight);
});

// 2. Initialize features requiring full layout
window.addEventListener('load', () => {
  createFullScreenCanvas();
  calculateComplexLayout();
});

// 3. Analytics and performance monitoring
window.addEventListener('load', () => {
  const loadTime = performance.now();
  sendAnalytics({ pageLoadTime: loadTime });
});

// 4. Lazy load additional content
window.addEventListener('load', () => {
  loadNonCriticalResources();
});
```

### document.readyState

Property that tracks document loading state, provides alternative to events:

```javascript
document.readyState; // "loading", "interactive", or "complete"

// "loading" - document still loading
// "interactive" - DOM ready, resources still loading (DOMContentLoaded about to fire)
// "complete" - everything loaded (load event about to fire)

// readystatechange event
document.addEventListener('readystatechange', () => {
  console.log(document.readyState);
  
  if (document.readyState === 'interactive') {
    // Same timing as DOMContentLoaded
    initDOM();
  }
  
  if (document.readyState === 'complete') {
    // Same timing as window.onload
    initFull();
  }
});
```

**Timing Correlation**

```javascript
// State transitions:
// 1. "loading" - initial state
// 2. "interactive" - triggers immediately before DOMContentLoaded
// 3. "complete" - triggers immediately before window.load

// Typical sequence:
document.addEventListener('readystatechange', () => {
  console.log('State:', document.readyState);
});

document.addEventListener('DOMContentLoaded', () => {
  console.log('DOMContentLoaded');
  // document.readyState is "interactive"
});

window.addEventListener('load', () => {
  console.log('load');
  // document.readyState is "complete"
});

// Output order:
// State: loading (initial)
// State: interactive
// DOMContentLoaded
// State: complete
// load
```

### Comparison Table

|Aspect|DOMContentLoaded|load|
|---|---|---|
|Event target|`document`|`window` (also element-specific)|
|Bubbles|No|No|
|Waits for HTML parsing|Yes|Yes|
|Waits for DOM construction|Yes|Yes|
|Waits for sync scripts|Yes|Yes|
|Waits for deferred scripts|Yes|Yes|
|Waits for async scripts|No|Yes|
|Waits for stylesheets|Conditional|Yes|
|Waits for images|No|Yes|
|Waits for iframes|No|Yes|
|Waits for fonts|No|Yes|
|Associated readyState|"interactive"|"complete"|
|Can be canceled|No|No|
|Typical use|DOM manipulation|Resource-dependent initialization|

### Performance Implications

```javascript
// DOMContentLoaded - Earlier, better for UX
document.addEventListener('DOMContentLoaded', () => {
  // Runs sooner, allows faster interactivity
  initializeUI();
  attachEventListeners();
  // User can start interacting while images still load
});

// load - Later, ensures everything available
window.addEventListener('load', () => {
  // Runs after all resources loaded
  // May delay interactivity unnecessarily
  initializeUI(); // Could have run earlier with DOMContentLoaded
});

// Measure timing difference
let domTime, loadTime;

document.addEventListener('DOMContentLoaded', () => {
  domTime = performance.now();
});

window.addEventListener('load', () => {
  loadTime = performance.now();
  console.log(`DOMContentLoaded: ${domTime}ms`);
  console.log(`load: ${loadTime}ms`);
  console.log(`Difference: ${loadTime - domTime}ms`);
});
```

**Performance Monitoring**

```javascript
// Navigation Timing API provides precise measurements
window.addEventListener('load', () => {
  const perfData = performance.timing;
  const pageLoadTime = perfData.loadEventEnd - perfData.navigationStart;
  const domReadyTime = perfData.domContentLoadedEventEnd - perfData.navigationStart;
  const resourceLoadTime = perfData.loadEventEnd - perfData.domContentLoadedEventEnd;
  
  console.log('DOM Ready:', domReadyTime, 'ms');
  console.log('Full Load:', pageLoadTime, 'ms');
  console.log('Resources:', resourceLoadTime, 'ms');
});

// Modern Performance API
window.addEventListener('load', () => {
  const [navEntry] = performance.getEntriesByType('navigation');
  console.log('DOM Content Loaded:', navEntry.domContentLoadedEventEnd);
  console.log('Load Complete:', navEntry.loadEventEnd);
  console.log('DOM Interactive:', navEntry.domInteractive);
});
```

### Script Loading Strategies Impact

```javascript
// Strategy 1: Traditional blocking script (slowest)
<script src="app.js"></script>
// - Blocks HTML parsing
// - Blocks DOMContentLoaded
// - Loads and executes immediately

// Strategy 2: Defer (recommended for order-dependent scripts)
<script defer src="app.js"></script>
// - Doesn't block HTML parsing
// - Blocks DOMContentLoaded
// - Executes in order before DOMContentLoaded

// Strategy 3: Async (fastest, order-independent)
<script async src="analytics.js"></script>
// - Doesn't block HTML parsing
// - Doesn't block DOMContentLoaded
// - Executes whenever ready, no guaranteed order

// Strategy 4: Module scripts (modern approach)
<script type="module" src="app.js"></script>
// - Behaves like defer by default
// - Doesn't block HTML parsing
// - Blocks DOMContentLoaded
// - Supports ES6 imports
```

**Practical Example**

```html
<!DOCTYPE html>
<html>
<head>
  <!-- CSS loads (blocks scripts after it) -->
  <link rel="stylesheet" href="styles.css">
  
  <!-- Defer script waits for CSS, runs before DOMContentLoaded -->
  <script defer src="main.js"></script>
  
  <!-- Async script runs whenever ready -->
  <script async src="analytics.js"></script>
</head>
<body>
  <img src="large-image.jpg">
  
  <script>
    // Inline script blocks DOMContentLoaded
    console.log('Inline script executed');
    
    document.addEventListener('DOMContentLoaded', () => {
      console.log('DOM ready');
      // defer scripts have executed
      // async scripts may or may not have executed
      // CSS loaded
      // Image may not be loaded yet
    });
    
    window.addEventListener('load', () => {
      console.log('Everything loaded');
      // All scripts executed
      // All resources loaded including image
    });
  </script>
</body>
</html>
```

### Edge Cases and Gotchas

**Empty Documents**

```javascript
// Empty or minimal documents
<!DOCTYPE html><html><head></head><body></body></html>

// DOMContentLoaded fires almost immediately
// load also fires quickly (no resources to load)
```

**Infinite Loading**

```javascript
// If a resource never finishes loading
<img src="http://never-responds.example.com/image.jpg">

// DOMContentLoaded fires normally (doesn't wait for images)
// window.load may never fire (waits for all resources)

// [Inference] Browser timeout mechanisms may eventually trigger load event
// after extended period, but this behavior is not guaranteed
```

**Dynamic Content Loading**

```javascript
document.addEventListener('DOMContentLoaded', () => {
  // Add image after DOMContentLoaded
  const img = document.createElement('img');
  img.src = 'dynamic.jpg';
  document.body.appendChild(img);
  
  // This image load won't prevent window.load if added after DOMContentLoaded
  // but will delay it if added before
});

window.addEventListener('load', () => {
  // May or may not include dynamically added image
  // depending on timing
});
```

**Multiple Registrations**

```javascript
// Both handlers execute
document.addEventListener('DOMContentLoaded', handler1);
document.addEventListener('DOMContentLoaded', handler2);

// Execution order is registration order
// handler1 runs, then handler2
```

**Removing Listeners**

```javascript
function handler() {
  console.log('DOM ready');
}

document.addEventListener('DOMContentLoaded', handler);
document.removeEventListener('DOMContentLoaded', handler);
// Handler won't execute even if removed before event fires
```

### jQuery's $(document).ready() Equivalent

For context, jQuery's popular pattern:

```javascript
// jQuery (for reference)
$(document).ready(function() {
  // DOM ready
});

// Vanilla JavaScript equivalent
document.addEventListener('DOMContentLoaded', function() {
  // DOM ready
});

// Or with the safety check
function ready(fn) {
  if (document.readyState !== 'loading') {
    fn();
  } else {
    document.addEventListener('DOMContentLoaded', fn);
  }
}

ready(function() {
  // DOM ready, works even if called after DOMContentLoaded
});
```

### Modern Best Practices

```javascript
// 1. Use defer for scripts (most common)
<script defer src="app.js"></script>
// No need for DOMContentLoaded, script runs when DOM ready

// 2. Use type="module" for modern code
<script type="module" src="app.js"></script>
// Automatically deferred, supports ES6 imports

// 3. Only use window.load when necessary
window.addEventListener('load', () => {
  // Only for truly resource-dependent code
  analyzeImageDimensions();
  measureLayoutMetrics();
});

// 4. Avoid inline scripts at bottom of body
// (Legacy pattern, defer is better)
<body>
  <!-- content -->
  <script src="app.js"></script> // Old way
</body>

// Better:
<head>
  <script defer src="app.js"></script> // Modern way
</head>

// 5. Lazy load non-critical resources
document.addEventListener('DOMContentLoaded', () => {
  // Critical initialization
  initCore();
  
  // Defer non-critical work
  requestIdleCallback(() => {
    initNonCritical();
  });
});
```

### Debugging Event Timing

```javascript
// Comprehensive timing debug
const events = [];

['readystatechange', 'DOMContentLoaded'].forEach(eventType => {
  document.addEventListener(eventType, () => {
    events.push({
      type: eventType,
      time: performance.now(),
      readyState: document.readyState
    });
  });
});

['load'].forEach(eventType => {
  window.addEventListener(eventType, () => {
    events.push({
      type: eventType,
      time: performance.now(),
      readyState: document.readyState
    });
    
    console.table(events);
  });
});

// Check current state at any time
function checkLoadingState() {
  return {
    readyState: document.readyState,
    domReady: document.readyState !== 'loading',
    fullyLoaded: document.readyState === 'complete'
  };
}
```

### Cross-Browser Considerations

**[Inference]** Historical browser differences:

**Old IE (8 and below)**

- Used different event model
- Required `attachEvent` instead of `addEventListener`
- `DOMContentLoaded` not supported (used readyState workarounds)

**Modern Browsers**

- All modern browsers consistently support both events
- Timing is largely standardized
- Minor variations in exact millisecond timing but event order is consistent

**Mobile Browsers**

- Same event model as desktop
- May have different performance characteristics
- `load` event can be significantly delayed on slow connections

---

