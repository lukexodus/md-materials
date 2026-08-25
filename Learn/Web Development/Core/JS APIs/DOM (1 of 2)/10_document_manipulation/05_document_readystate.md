## document.readyState


### Core Property Definition

`document.readyState` is a read-only property that returns a string describing the loading state of the document. It has exactly three possible values:

- `"loading"` - document is still loading
- `"interactive"` - document has finished loading and been parsed, but sub-resources are still loading
- `"complete"` - document and all sub-resources have finished loading

### State Transition Sequence

The property transitions through states in a strict, unidirectional sequence:

```
loading → interactive → complete
```

This sequence **never reverses** and **never skips states**. Once a state is reached, the document never returns to a previous state, even if new content is dynamically added.

### Timing in Document Lifecycle

#### loading State

- Present from initial document parse
- Exists when script tags in `<head>` execute (unless deferred/async)
- DOM is being constructed
- Parser is actively processing HTML

#### interactive State

- DOM construction complete (`DOMContentLoaded` about to fire or firing)
- Document parsed and ready for DOM manipulation
- Images, stylesheets, iframes still loading
- Synchronous scripts have executed
- Deferred scripts are executing or about to execute

Transition to `interactive` happens **immediately before** the `DOMContentLoaded` event fires:

```javascript
// This sequence is guaranteed:
// 1. readyState becomes 'interactive'
// 2. readystatechange event fires with 'interactive'
// 3. DOMContentLoaded event fires
```

#### complete State

- All resources loaded: images, stylesheets, scripts, iframes
- `window.load` event about to fire or firing
- All async operations initiated by the HTML have finished

Transition to `complete` happens **immediately before** the `load` event fires.

### readystatechange Event

The `readystatechange` event fires on `document` whenever `readyState` changes:

```javascript
document.addEventListener('readystatechange', () => {
  console.log(document.readyState);
});

// Logs (depending on when listener is added):
// "loading" (if added early enough)
// "interactive"
// "complete"
```

#### Event Timing Guarantees

Critical timing relationships:

```javascript
// Guaranteed order:
// 1. readyState = 'interactive'
// 2. readystatechange event (interactive)
// 3. DOMContentLoaded event
// 4. readyState = 'complete'
// 5. readystatechange event (complete)
// 6. window load event
```

The `readystatechange` event fires **synchronously** when the state changes, meaning:

```javascript
console.log(document.readyState); // "loading"
// State changes to interactive...
// readystatechange fires synchronously here
console.log(document.readyState); // "interactive"
```

### Practical Usage Patterns

#### Conditional Initialization

Execute code immediately if DOM ready, otherwise wait:

```javascript
function init() {
  // Initialization code
}

if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', init);
} else {
  // DOM already ready (interactive or complete)
  init();
}
```

More comprehensive pattern:

```javascript
function runWhenReady(callback) {
  if (document.readyState !== 'loading') {
    callback();
  } else {
    document.addEventListener('DOMContentLoaded', callback);
  }
}
```

#### Detecting Full Load

Wait for all resources including images:

```javascript
function runWhenComplete(callback) {
  if (document.readyState === 'complete') {
    callback();
  } else {
    window.addEventListener('load', callback);
  }
}
```

#### State-Specific Logic

Different actions based on current state:

```javascript
switch(document.readyState) {
  case 'loading':
    // DOM not ready, can't manipulate
    document.addEventListener('DOMContentLoaded', setupDOM);
    break;
  case 'interactive':
    // DOM ready, but images/resources loading
    setupDOM();
    window.addEventListener('load', setupResources);
    break;
  case 'complete':
    // Everything loaded
    setupDOM();
    setupResources();
    break;
}
```

### Script Execution Context

The value of `readyState` when a script executes depends on script placement and attributes:

#### Inline Scripts in Head

```html
<head>
  <script>
    console.log(document.readyState); // "loading"
  </script>
</head>
```

The DOM below hasn't been parsed yet.

#### Inline Scripts in Body

```html
<body>
  <!-- content -->
  <script>
    console.log(document.readyState); // "loading"
    // But DOM up to this point is accessible
  </script>
</body>
```

Still `"loading"` because parsing isn't complete.

#### Deferred Scripts

```html
<script defer src="app.js"></script>
```

Inside `app.js`:

```javascript
// readyState is "interactive"
// DOM fully parsed, but resources still loading
console.log(document.readyState); // "interactive"
```

Deferred scripts execute **after** DOM parsing but **before** `DOMContentLoaded`.

#### Async Scripts

```html
<script async src="analytics.js"></script>
```

Inside `analytics.js`:

```javascript
// readyState is unpredictable - could be any state
// Depends on when script finishes downloading
console.log(document.readyState); // "loading", "interactive", or "complete"
```

Async scripts execute whenever they finish downloading.

#### Module Scripts

```html
<script type="module" src="app.js"></script>
```

Module scripts behave like `defer` by default:

```javascript
// readyState is "interactive" or later
console.log(document.readyState);
```

### Dynamic Content and readyState

Adding content dynamically **does not** change `readyState`:

```javascript
// readyState is "complete"
document.body.innerHTML += '<img src="large-image.jpg">';
console.log(document.readyState); // Still "complete"

// New image loads, but readyState stays "complete"
```

Once `complete` is reached, it remains `complete` regardless of subsequent resource loading. The `readyState` reflects the **initial page load** lifecycle only.

### XMLHttpRequest and Fetch Relationship

The document's `readyState` is **independent** from XHR's `readyState`:

```javascript
const xhr = new XMLHttpRequest();
console.log(xhr.readyState); // XHR state (0-4)
console.log(document.readyState); // Document state ("loading", etc.)

// These are completely separate properties with different semantics
```

Similarly, `fetch()` has no relation to `document.readyState`.

### iframe Considerations

Each iframe has its own `document` with its own `readyState`:

```javascript
const iframe = document.querySelector('iframe');

console.log(document.readyState); // Parent document state
console.log(iframe.contentDocument.readyState); // iframe document state

// These progress independently
```

#### Monitoring iframe Load

```javascript
iframe.addEventListener('load', () => {
  // iframe's readyState is now "complete"
  console.log(iframe.contentDocument.readyState); // "complete"
});

// Or monitor the iframe document directly
iframe.contentDocument.addEventListener('readystatechange', () => {
  console.log('iframe state:', iframe.contentDocument.readyState);
});
```

### History Navigation Impact

When navigating back/forward using browser history:

- `readyState` goes through the full cycle again
- Transitions from `loading` → `interactive` → `complete`
- Cached pages may transition faster, but still follow the sequence
- `pageshow` event indicates page displayed (may be from cache)

#### BFCache (Back-Forward Cache)

Pages restored from BFCache:

```javascript
window.addEventListener('pageshow', (event) => {
  if (event.persisted) {
    // Page restored from BFCache
    console.log(document.readyState); // "complete"
    // readyState is already complete, no transitions occur
  }
});
```

### Service Worker Interaction

Service Workers can intercept requests but don't affect `readyState` transitions:

```javascript
// In service worker
self.addEventListener('fetch', (event) => {
  event.respondWith(
    caches.match(event.request)
      .then(response => response || fetch(event.request))
  );
});

// In page: readyState transitions normally
// Even if all resources served from cache via SW
```

The browser still considers resources "loaded" when SW responds, progressing `readyState` appropriately.

### Performance API Correlation

`readyState` transitions correlate with Performance API timings:

```javascript
window.addEventListener('load', () => {
  const perfData = performance.timing;
  
  // readyState: loading → interactive happened at:
  console.log(perfData.domInteractive);
  
  // readyState: interactive → complete happened at:
  console.log(perfData.domComplete);
  
  // load event fired at:
  console.log(perfData.loadEventStart);
});
```

More modern API:

```javascript
const observer = new PerformanceObserver((list) => {
  for (const entry of list.getEntries()) {
    console.log(entry.name, entry.startTime);
  }
});

observer.observe({ entryTypes: ['navigation'] });

// Provides domInteractive, domComplete timestamps
```

### Security and Cross-Origin

Accessing `readyState` of cross-origin iframes throws a security error:

```javascript
const iframe = document.querySelector('iframe'); // cross-origin
try {
  console.log(iframe.contentDocument.readyState);
} catch (e) {
  // SecurityError: Blocked a frame with origin...
}
```

Same-origin policy applies strictly to iframe document access.

### Testing and Debugging Strategies

#### Simulating Different States

Force execution at specific states for testing:

```javascript
// Test loading state - put at top of head
if (document.readyState === 'loading') {
  // Test code that needs loading state
}

// Test interactive state - use DOMContentLoaded
document.addEventListener('DOMContentLoaded', () => {
  console.log(document.readyState); // "interactive"
  // Test interactive-specific code
});

// Test complete state - use load
window.addEventListener('load', () => {
  console.log(document.readyState); // "complete"
  // Test complete-specific code
});
```

#### DevTools Monitoring

Monitor state changes in console:

```javascript
const originalState = document.readyState;
console.log('Initial state:', originalState);

document.addEventListener('readystatechange', () => {
  console.log('State changed to:', document.readyState);
});

document.addEventListener('DOMContentLoaded', () => {
  console.log('DOMContentLoaded - state:', document.readyState);
});

window.addEventListener('load', () => {
  console.log('load - state:', document.readyState);
});
```

#### Slow Network Testing

Use DevTools network throttling to observe states:

- Fast 3G: Clear state transitions visible
- Slow 3G: Long `loading` and `interactive` periods
- Offline: Stuck in `loading` for network resources

### Edge Cases and Quirks

#### document.write After Load

Calling `document.write()` after `complete` reopens the document:

```javascript
window.addEventListener('load', () => {
  console.log(document.readyState); // "complete"
  
  document.write('<h1>New content</h1>');
  
  // Document reopened and cleared
  console.log(document.readyState); // "complete" (remains, but doc cleared)
});
```

The `readyState` stays `complete` but the document is replaced.

#### Long-Running Requests

Resources that take extremely long to load:

```javascript
// Image never finishes loading due to server stalling
const img = new Image();
img.src = 'https://example.com/stalling-image.jpg';
document.body.appendChild(img);

// readyState will still reach "complete" after a timeout
// Browser has internal timeout for resource loading
```

Browsers implement timeouts to prevent indefinite `loading`/`interactive` states.

#### Programmatic Navigation

When using `location.href` or `history.pushState`:

```javascript
// pushState - no reload
history.pushState({}, '', '/new-url');
console.log(document.readyState); // "complete" (unchanged)

// location.href - full reload
location.href = '/new-page';
// readyState cycles through loading → interactive → complete again
```

### Polyfill Considerations

`document.readyState` is well-supported (IE9+), but for ancient browsers:

```javascript
// IE8 and below workaround
if (document.readyState === undefined) {
  document.readyState = 'loading';
  
  document.addEventListener('DOMContentLoaded', () => {
    document.readyState = 'interactive';
  });
  
  window.addEventListener('load', () => {
    document.readyState = 'complete';
  });
}
```

Modern development rarely needs this.

### Framework Integration

#### React

React typically doesn't need `readyState` checks since it mounts after DOM ready:

```javascript
// React 18
import { createRoot } from 'react-dom/client';

const root = createRoot(document.getElementById('root'));
root.render(<App />);

// This script is usually defer/module, so readyState is already "interactive"
```

#### Vue

Vue's mounting behavior:

```javascript
import { createApp } from 'vue';

// If script is defer/module, DOM is ready
createApp(App).mount('#app');

// If not sure, wrap:
if (document.readyState !== 'loading') {
  createApp(App).mount('#app');
} else {
  document.addEventListener('DOMContentLoaded', () => {
    createApp(App).mount('#app');
  });
}
```

### Best Practices Summary

1. **Prefer specific events over polling**: Use `DOMContentLoaded` and `load` rather than repeatedly checking `readyState`
    
2. **Check state before adding listeners**: Avoid missed events by checking current state first
    
3. **Use for progressive enhancement**: Check state to add features as they become available
    
4. **Don't rely on state after dynamic changes**: `readyState` only reflects initial page load
    
5. **Combine with Performance API**: Use `readyState` for logic, Performance API for metrics

---

