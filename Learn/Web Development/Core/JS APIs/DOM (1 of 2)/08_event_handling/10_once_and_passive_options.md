## once and passive Options


### EventListener Options Object

The `addEventListener` method accepts an optional third parameter that can be either a boolean (for capture phase) or an options object with specific properties. The `once` and `passive` options are part of this options object:

```javascript
element.addEventListener('click', handler, {
  once: true,
  passive: true,
  capture: false
});
```

### once Option

#### Behavior Mechanics

When `once: true` is specified, the event listener automatically removes itself after being invoked **exactly one time**. This is functionally equivalent to calling `removeEventListener` inside the handler, but more efficient and less error-prone.

```javascript
button.addEventListener('click', function handler(e) {
  console.log('Clicked!');
  // Listener is automatically removed after this executes
}, { once: true });

// Subsequent clicks do nothing - handler already removed
```

#### Internal Implementation

The browser maintains the listener registration with a flag indicating it should be removed after first invocation. The removal happens **after** the handler completes execution, meaning:

- The handler runs to completion
- Return values are processed
- Any synchronous code in the handler finishes
- Then the listener is removed from the internal registry

#### Memory Management Benefits

Using `once` prevents common memory leaks where developers forget to clean up listeners:

```javascript
// Without once - easy to forget cleanup
function loadData() {
  element.addEventListener('load', handler);
  // If this code path executes multiple times, handlers accumulate
}

// With once - automatic cleanup
function loadData() {
  element.addEventListener('load', handler, { once: true });
  // No accumulation possible
}
```

#### Multiple Registration Handling

If the same handler is registered multiple times with `once: true`, each registration is independent:

```javascript
element.addEventListener('click', handler, { once: true });
element.addEventListener('click', handler, { once: true });

// First click: handler runs TWICE (both registrations fire)
// Second click: nothing happens (both registrations removed)
```

This differs from normal listeners where duplicate registrations are ignored if the handler function reference is identical.

#### Capture Phase Interaction

The `once` option works identically in both capture and bubble phases:

```javascript
parent.addEventListener('click', handler, { 
  once: true, 
  capture: true 
});

child.addEventListener('click', handler, { 
  once: true, 
  capture: false 
});

// Click on child:
// 1. Parent's capture handler fires, then removes itself
// 2. Child's bubble handler fires, then removes itself
```

#### Removal Timing with stopPropagation

If `stopPropagation()` or `stopImmediatePropagation()` is called, the `once` listener still removes itself even though propagation was stopped:

```javascript
element.addEventListener('click', (e) => {
  e.stopImmediatePropagation();
  console.log('First handler');
}, { once: true });

element.addEventListener('click', () => {
  console.log('Second handler'); // Never runs
}, { once: true });

// After first click:
// - First handler runs and removes itself
// - Second handler never runs but is NOT removed
// - Second click will run second handler
```

### passive Option

#### Core Purpose and Performance

The `passive: true` option is a **performance optimization** that tells the browser the event handler will **not call `preventDefault()`**. This allows the browser to start scrolling or other default actions immediately without waiting for the JavaScript handler to complete.

The primary use case is touch and wheel events where scroll performance is critical:

```javascript
element.addEventListener('touchstart', handler, { passive: true });
// Browser can start scrolling immediately
// Does not need to wait for handler to check preventDefault()
```

#### preventDefault Behavior

When `passive: true` is set, calling `preventDefault()` inside the handler **does nothing** and generates a console warning:

```javascript
element.addEventListener('touchmove', (e) => {
  e.preventDefault(); // No effect!
  // Console warning: "Unable to preventDefault inside passive event listener"
}, { passive: true });
```

The `preventDefault()` call is silently ignored - it doesn't throw an error, but the default action proceeds regardless.

#### Default passive Values

Browsers set default `passive: true` for certain event types to improve performance:

**Chrome/Edge (since Chrome 56)**:

- `touchstart`
- `touchmove`
- `wheel`
- `mousewheel`

**Firefox**:

- Similar defaults for touch and wheel events

This means:

```javascript
// These are passive by default in modern browsers
element.addEventListener('touchstart', handler);
// Equivalent to: { passive: true }

// Must explicitly set passive: false to use preventDefault
element.addEventListener('touchstart', handler, { passive: false });
```

#### Checking Event.defaultPrevented

The `passive` option doesn't affect `event.defaultPrevented` - it will remain `false` even if `preventDefault()` was called in a passive listener:

```javascript
element.addEventListener('wheel', (e) => {
  e.preventDefault(); // Ignored
  console.log(e.defaultPrevented); // false
}, { passive: true });
```

#### Performance Impact Quantification

Without `passive`:

1. Touch/wheel event fires
2. Browser waits for all JavaScript handlers to complete
3. Browser checks if any handler called `preventDefault()`
4. Browser starts scroll (potentially 16-100ms later)

With `passive`:

1. Touch/wheel event fires
2. Browser starts scroll **immediately**
3. JavaScript handlers execute in parallel
4. Scroll feels instantaneous (no jank)

The delay can be 1-2 frames (16-33ms at 60fps), which is perceptible as jank during scrolling.

#### Touch Action CSS Alternative

For preventing default touch behaviors, `touch-action` CSS property is often better than non-passive listeners:

```css
.element {
  touch-action: none; /* Prevents all touch behaviors */
  touch-action: pan-y; /* Allow vertical panning only */
  touch-action: manipulation; /* Allow pan and zoom, prevent double-tap */
}
```

This is declarative, performs better, and doesn't require JavaScript.

#### Combining once and passive

Both options can be used together:

```javascript
element.addEventListener('touchstart', handler, {
  once: true,
  passive: true
});

// Handler runs once, cannot preventDefault, optimizes scroll
```

Common pattern for one-time gesture detection without blocking scroll:

```javascript
document.addEventListener('touchstart', () => {
  // Detect first touch interaction
  startApp();
}, { once: true, passive: true });
```

#### Feature Detection

Check if options are supported (mainly for older browsers):

```javascript
let passiveSupported = false;

try {
  const options = {
    get passive() {
      passiveSupported = true;
      return false;
    }
  };
  
  window.addEventListener('test', null, options);
  window.removeEventListener('test', null, options);
} catch (err) {
  passiveSupported = false;
}

// Use the feature
element.addEventListener('wheel', handler, 
  passiveSupported ? { passive: true } : false
);
```

#### Passive with Scroll Event

The `scroll` event **cannot be prevented** (it fires after scrolling already happened), making `passive` redundant but harmless:

```javascript
element.addEventListener('scroll', handler, { passive: true });
// passive has no effect - scroll is always passive-like
```

#### Wheel Event Specifics

Wheel events are particularly important for `passive` because they're used for scrolling:

```javascript
// Bad: blocks scroll performance
element.addEventListener('wheel', (e) => {
  if (shouldPrevent) {
    e.preventDefault(); // Forces browser to wait
  }
}, { passive: false });

// Good: if you don't need preventDefault
element.addEventListener('wheel', handler, { passive: true });
```

For custom scroll behavior, use `transform` instead of preventing wheel:

```javascript
element.addEventListener('wheel', (e) => {
  // Don't preventDefault, just transform
  customScrollPosition += e.deltaY;
  element.style.transform = `translateY(${-customScrollPosition}px)`;
}, { passive: true });
```

#### Passive and stopPropagation

The `passive` option only affects `preventDefault()`, not event propagation:

```javascript
element.addEventListener('touchmove', (e) => {
  e.stopPropagation(); // This still works!
  e.preventDefault(); // This is ignored
}, { passive: true });
```

#### Mobile Safari Considerations

Mobile Safari has aggressive passive defaults. To enable `preventDefault()` for touch events:

```javascript
element.addEventListener('touchstart', (e) => {
  e.preventDefault(); // Will work
}, { passive: false }); // Must explicitly set false
```

Without `passive: false`, pull-to-refresh and other gestures cannot be prevented.

#### Debugging Passive Issues

Common mistake - forgetting browser defaults:

```javascript
// This won't prevent scroll in modern browsers!
element.addEventListener('touchmove', (e) => {
  e.preventDefault(); // No effect - passive by default
});

// Must explicitly override:
element.addEventListener('touchmove', (e) => {
  e.preventDefault(); // Now works
}, { passive: false });
```

Check console for warnings about ignored `preventDefault()` calls.

#### Performance Monitoring

Measure scroll jank with passive vs non-passive:

```javascript
// Non-passive (potential jank)
let start = performance.now();
element.addEventListener('wheel', () => {
  // Heavy computation
  expensiveOperation();
}, { passive: false });

// Passive (no jank)
element.addEventListener('wheel', () => {
  // Heavy computation doesn't block scroll
  expensiveOperation();
}, { passive: true });
```

Use Chrome DevTools Performance tab to visualize frame drops.

#### Signal Option Relationship

The `signal` option (for AbortController) works alongside `once` and `passive`:

```javascript
const controller = new AbortController();

element.addEventListener('touchstart', handler, {
  once: true,
  passive: true,
  signal: controller.signal
});

// Aborts even though once: true hasn't fired yet
controller.abort();
```

Priority: `signal.abort()` > `once` auto-removal > manual `removeEventListener()`.

#### Worker Thread Considerations

Event listener options work identically in Worker contexts:

```javascript
// Inside a Worker
self.addEventListener('message', handler, {
  once: true,
  passive: true // Less relevant without DOM events
});
```

However, `passive` is mostly meaningless in Workers since there are no default actions like scrolling.

---

