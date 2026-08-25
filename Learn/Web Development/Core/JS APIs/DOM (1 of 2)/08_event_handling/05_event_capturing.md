## Event Capturing


### Capture Phase Mechanics

Event capturing represents the first phase of DOM event propagation, where events travel from the outermost ancestor element down through the DOM tree to the target element. During this phase, the event traverses from `window` → `document` → `html` → `body` and continues through each nested parent until reaching the actual target.

The capture phase occurs before the target phase and the bubbling phase, completing the full propagation cycle. Handlers registered with `capture: true` execute during this downward journey, enabling parent elements to intercept and process events before their children receive them.

### Registration Syntax

```javascript
element.addEventListener(eventType, handler, true);
// or
element.addEventListener(eventType, handler, { capture: true });
```

The third parameter controls capture behavior. When `true` or `{ capture: true }`, the handler executes during the capture phase. When `false`, `undefined`, or `{ capture: false }`, it executes during bubbling.

### Execution Order

For a nested structure like `<div id="outer"><div id="middle"><div id="inner"></div></div></div>`, clicking the inner div triggers handlers in this sequence:

1. **Capture phase**: outer (capture) → middle (capture) → inner (capture)
2. **Target phase**: inner (target handlers, in registration order)
3. **Bubble phase**: inner (bubble) → middle (bubble) → outer (bubble)

Handlers on the target element itself execute in registration order during the target phase, regardless of their capture setting.

### Practical Applications

#### Early Event Interception

Capture handlers intercept events before they reach deeply nested components, useful for:

- Global keyboard shortcuts that should override local handlers
- Implementing custom drag-and-drop that prevents default behaviors early
- Security boundaries that block events from propagating to untrusted content
- Performance monitoring that tracks all interactions from a high level

```javascript
document.addEventListener('click', (e) => {
  // Log all clicks before any component handles them
  analytics.track('click', e.target);
}, true);
```

#### Event Delegation at Scale

While bubbling is more common for delegation, capture enables top-down control patterns:

```javascript
container.addEventListener('focus', (e) => {
  // Handle focus for any descendant during capture
  // Useful since focus doesn't bubble
  if (e.target.matches('input[type="text"]')) {
    e.target.select(); // Auto-select text
  }
}, true);
```

#### Preventing Propagation Early

Stopping propagation during capture prevents the event from reaching the target entirely:

```javascript
blocker.addEventListener('click', (e) => {
  if (shouldBlock(e.target)) {
    e.stopPropagation(); // Event never reaches target
  }
}, true);
```

### stopPropagation vs stopImmediatePropagation

- `stopPropagation()`: Prevents further propagation but allows other handlers on the current element to execute
- `stopImmediatePropagation()`: Stops propagation AND prevents remaining handlers on the current element from executing

```javascript
element.addEventListener('click', (e) => {
  console.log('First capture handler');
  e.stopImmediatePropagation();
}, true);

element.addEventListener('click', (e) => {
  console.log('Never executes');
}, true);
```

### Events That Don't Propagate

Several events never propagate through capture or bubble phases:

- `focus`, `blur` (use `focusin`, `focusout` for bubbling equivalents)
- `load`, `unload`, `error` on resources
- `mouseenter`, `mouseleave` (use `mouseover`, `mouseout` for bubbling)
- Media events: `play`, `pause`, `ended`
- Form-specific: `reset`, `invalid`

For these events, capture handlers on ancestors never execute since the event doesn't traverse the tree.

### Performance Considerations

Capture handlers execute for every matching event on every descendant element, creating potential performance costs:

- Avoid expensive operations in capture handlers on high-frequency events (scroll, mousemove)
- Use event delegation patterns to minimize the number of capture listeners
- Consider whether bubbling accomplishes the same goal with less overhead

**[Inference]**: Capture handlers may have slightly higher overhead than bubbling handlers due to executing earlier in the propagation chain, potentially before browser optimizations apply.

### Framework-Specific Behavior

#### React Synthetic Events

React's synthetic event system historically handled events at the document root using delegation, but React 17+ attaches to the root container. React primarily uses bubbling phase handlers, with capture specified via naming:

```javascript
<div 
  onClick={handleBubble}           // Bubbling phase
  onClickCapture={handleCapture}   // Capture phase
/>
```

React's event system abstracts away direct DOM manipulation, so capture behavior differs from native addEventListener.

#### Vue and Other Frameworks

Vue uses native DOM events with modifiers:

```javascript
<div @click.capture="handler">  // Capture phase
```

Angular similarly provides mechanisms for capture through native DOM access or framework-specific APIs.

### Debugging Capture Events

Chrome DevTools event listener breakpoints don't distinguish between capture and bubble phases by default. To debug:

1. Set breakpoints on specific event types
2. Inspect `event.eventPhase` property:
    - `1` = CAPTURING_PHASE
    - `2` = AT_TARGET
    - `3` = BUBBLING_PHASE

```javascript
element.addEventListener('click', (e) => {
  console.log('Phase:', e.eventPhase);
  // 1 = capture, 2 = target, 3 = bubble
}, true);
```

### Memory Management

Capture listeners must be removed with the same capture setting:

```javascript
const handler = (e) => { /* ... */ };

// Add with capture
element.addEventListener('click', handler, true);

// Must remove with capture
element.removeEventListener('click', handler, true);

// This won't remove the capture listener:
element.removeEventListener('click', handler, false);
```

### Advanced Patterns

#### Capture-Based Event Router

```javascript
class EventRouter {
  constructor(root) {
    this.routes = new Map();
    root.addEventListener('click', (e) => {
      for (const [selector, handler] of this.routes) {
        if (e.target.matches(selector)) {
          handler(e);
          break;
        }
      }
    }, true); // Capture ensures routing before component handlers
  }
  
  register(selector, handler) {
    this.routes.set(selector, handler);
  }
}
```

#### Permission Boundaries

```javascript
function createSandbox(element, allowedSelectors) {
  element.addEventListener('click', (e) => {
    const allowed = allowedSelectors.some(sel => 
      e.target.matches(sel)
    );
    if (!allowed) {
      e.stopPropagation();
      e.preventDefault();
    }
  }, true);
}
```

### Browser Compatibility

Event capturing has universal support across all modern browsers and IE9+. The options object syntax (`{ capture: true }`) is supported in all modern browsers, with IE11 requiring the boolean form.

Passive event listeners (`{ passive: true }`) can combine with capture (`{ capture: true, passive: true }`), though this is a separate concern related to scroll performance optimization.

---

