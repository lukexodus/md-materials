## Event Listeners in JavaScript


### Core Mechanics

`addEventListener()` and `removeEventListener()` manage event handling through the DOM's event system. They attach and detach event handlers to DOM nodes, allowing multiple handlers per event type on a single element.

**Syntax:**

```javascript
target.addEventListener(type, listener, options)
target.removeEventListener(type, listener, options)
```

### Parameters Deep Dive

#### type (string)

Case-sensitive event type string. Common types include `"click"`, `"mouseenter"`, `"keydown"`, `"load"`, `"DOMContentLoaded"`. Custom events use arbitrary strings.

#### listener (function | object)

The callback invoked when the event fires. Can be:

- Function reference
- Object with `handleEvent()` method

**Function signature:**

```javascript
function(event) {
  // event is the Event object
}
```

#### options (object | boolean)

**As boolean (legacy):** `useCapture` - if `true`, uses capture phase; if `false`, uses bubble phase (default).

**As object:**

- `capture` (boolean): Use capture phase. Default: `false`
- `once` (boolean): Remove listener automatically after first invocation. Default: `false`
- `passive` (boolean): Listener will never call `preventDefault()`. Improves scroll performance. Default: `false` (except for `touchstart`, `touchmove`, `wheel`, `mousewheel` where browsers may default to `true`)
- `signal` (AbortSignal): Allows removal via AbortController

### Event Phases

Events propagate through three phases:

1. **Capture phase**: From `window` down to target's parent
2. **Target phase**: On the target element itself
3. **Bubble phase**: From target's parent back up to `window`

Listeners with `capture: true` fire during capture phase. Others fire during target and bubble phases.

```javascript
parent.addEventListener('click', handler, { capture: true }); // Fires first
child.addEventListener('click', handler); // Fires second
parent.addEventListener('click', handler); // Fires third
```

### Listener Identity and Removal

`removeEventListener()` requires **exact** reference matching:

**Critical matching requirements:**

- Same `type` string
- Same function reference (not just identical code)
- Same `capture` value

```javascript
// ✗ This fails - different function references
element.addEventListener('click', () => console.log('hi'));
element.removeEventListener('click', () => console.log('hi'));

// ✓ This works - same reference
const handler = () => console.log('hi');
element.addEventListener('click', handler);
element.removeEventListener('click', handler);
```

**Anonymous functions cannot be removed** without storing the reference.

### Options Object Behavior

#### once

```javascript
button.addEventListener('click', handler, { once: true });
// handler automatically removed after first click
```

Equivalent to:

```javascript
function handlerOnce(event) {
  handler(event);
  button.removeEventListener('click', handlerOnce);
}
button.addEventListener('click', handlerOnce);
```

#### passive

```javascript
element.addEventListener('touchstart', handler, { passive: true });
// Cannot call event.preventDefault() - throws error in strict mode
```

Benefits:

- Browser can optimize scrolling by not waiting for handler completion
- Particularly important for touch/wheel events on mobile
- Scroll jank reduction

**[Inference]** Passive listeners signal to the browser that scroll-blocking operations won't occur, allowing the browser to immediately process the scroll.

#### signal

```javascript
const controller = new AbortController();

element.addEventListener('click', handler, { 
  signal: controller.signal 
});

// Remove listener via abort
controller.abort();
```

Advantages over manual removal:

- Remove multiple listeners simultaneously
- Tie listener lifetime to async operations
- Cleaner cleanup in complex scenarios

### Multiple Listeners

Multiple listeners on the same element/type execute in **registration order**:

```javascript
element.addEventListener('click', () => console.log('First'));
element.addEventListener('click', () => console.log('Second'));
element.addEventListener('click', () => console.log('Third'));
// Click order: First, Second, Third
```

**Duplicate registration prevention:** Adding the exact same listener (same function reference, same options) multiple times only registers it once.

```javascript
element.addEventListener('click', handler);
element.addEventListener('click', handler); // Ignored - already registered
```

### Event Object

The listener receives an Event object (or subclass) with properties:

**Universal properties:**

- `type`: Event type string
- `target`: Element that triggered the event
- `currentTarget`: Element with the listener attached
- `eventPhase`: 1 (capture), 2 (target), 3 (bubble)
- `bubbles`: Whether event bubbles
- `cancelable`: Whether `preventDefault()` works
- `defaultPrevented`: Whether `preventDefault()` was called
- `timeStamp`: High-resolution timestamp

**Methods:**

- `preventDefault()`: Cancel default browser action
- `stopPropagation()`: Stop bubbling/capturing to other elements
- `stopImmediatePropagation()`: Stop other listeners on same element

**Event-specific subclasses** add properties:

- `MouseEvent`: `clientX`, `clientY`, `button`, `buttons`, `altKey`, etc.
- `KeyboardEvent`: `key`, `code`, `keyCode`, `altKey`, `ctrlKey`, etc.
- `TouchEvent`: `touches`, `targetTouches`, `changedTouches`
- `WheelEvent`: `deltaX`, `deltaY`, `deltaZ`, `deltaMode`

### this Binding

Inside non-arrow function listeners, `this` refers to `currentTarget`:

```javascript
element.addEventListener('click', function(event) {
  console.log(this === element); // true
  console.log(this === event.currentTarget); // true
});
```

**Arrow functions don't bind `this`** - they inherit from surrounding scope:

```javascript
const obj = {
  name: 'MyObject',
  init() {
    element.addEventListener('click', (event) => {
      console.log(this === obj); // true
      console.log(this === element); // false
    });
  }
};
```

### handleEvent Interface

Objects with `handleEvent()` method can serve as listeners:

```javascript
const listener = {
  handleEvent(event) {
    if (event.type === 'click') this.handleClick(event);
    if (event.type === 'mouseover') this.handleMouseOver(event);
  },
  handleClick(event) { /* ... */ },
  handleMouseOver(event) { /* ... */ }
};

element.addEventListener('click', listener);
element.addEventListener('mouseover', listener);
```

`this` inside `handleEvent()` refers to the listener object, not the element.

### Memory Management and Leaks

**Common leak patterns:**

1. **Unreachable elements with listeners:**

```javascript
let element = document.getElementById('temp');
element.addEventListener('click', handler);
element.remove(); // Element removed from DOM
element = null; // Element reference cleared
// Listener still exists in memory if handler closes over variables
```

2. **Closure capturing:**

```javascript
function attachListener() {
  const largeData = new Array(1000000);
  button.addEventListener('click', () => {
    console.log(largeData.length); // Captures largeData
  });
}
```

**Prevention strategies:**

- Remove listeners before removing elements
- Use `once: true` for one-time handlers
- Use AbortSignal for lifecycle management
- Avoid capturing large objects in closures
- Use WeakMap for element-associated data

### Delegation Pattern

Rather than attaching listeners to many elements, attach one to a common ancestor:

```javascript
// Instead of this:
items.forEach(item => {
  item.addEventListener('click', handleClick);
});

// Do this:
container.addEventListener('click', (event) => {
  if (event.target.matches('.item')) {
    handleClick(event);
  }
});
```

**Benefits:**

- Fewer listeners in memory
- Handles dynamically added elements
- Better performance for large lists

**Caveats:**

- Event must bubble
- Need to check `event.target` identity
- May need `event.target.closest('.selector')` for nested elements

### Performance Considerations

**Passive listeners for scroll performance:**

```javascript
// Non-passive blocks scroll until handler completes
element.addEventListener('wheel', handler); // ✗ Can cause jank

// Passive allows immediate scrolling
element.addEventListener('wheel', handler, { passive: true }); // ✓
```

**Debouncing and throttling:** For high-frequency events (`scroll`, `resize`, `mousemove`):

```javascript
let timeout;
window.addEventListener('resize', () => {
  clearTimeout(timeout);
  timeout = setTimeout(actualHandler, 250);
});
```

**[Inference]** Debouncing reduces handler executions, lowering CPU usage during rapid event firing.

### Edge Cases and Gotchas

#### 1. Capture vs bubble confusion

```javascript
// These are different listeners
element.addEventListener('click', handler, { capture: true });
element.addEventListener('click', handler, { capture: false });
// Both fire on the same click
```

#### 2. Options object vs boolean

```javascript
// Modern
element.addEventListener('click', handler, { capture: true });

// Legacy (still works)
element.addEventListener('click', handler, true);

// But removal must match
element.removeEventListener('click', handler, true); // Works
element.removeEventListener('click', handler, { capture: true }); // Works
```

#### 3. Inline handlers vs addEventListener

```html
<button onclick="handler()">Click</button>
```

- Inline handlers execute in global scope
- Can only have one per event type
- Not removed via `removeEventListener()`
- Generally considered poor practice

#### 4. preventDefault() limitations

Only works when `event.cancelable === true`. Some events cannot be canceled:

- `scroll` (already happened)
- `focus`/`blur` in some contexts
- Touch events with `passive: true`

#### 5. Event timing with dynamic content

```javascript
// ✗ Element doesn't exist yet
document.getElementById('future').addEventListener('click', handler);

// ✓ Use delegation or defer
document.addEventListener('DOMContentLoaded', () => {
  document.getElementById('future').addEventListener('click', handler);
});
```

### Browser Compatibility

Modern features:

- `options` object: Supported since Chrome 49, Firefox 49, Safari 10
- `once`: Chrome 55, Firefox 50, Safari 10
- `passive`: Chrome 51, Firefox 49, Safari 10
- `signal`: Chrome 90, Firefox 87, Safari 15

**Feature detection:**

```javascript
let supportsPassive = false;
try {
  const opts = Object.defineProperty({}, 'passive', {
    get() { supportsPassive = true; }
  });
  window.addEventListener('test', null, opts);
  window.removeEventListener('test', null, opts);
} catch (e) {}
```

### AbortSignal Advanced Usage

**Cleanup multiple listeners:**

```javascript
const controller = new AbortController();
const { signal } = controller;

element1.addEventListener('click', handler1, { signal });
element2.addEventListener('click', handler2, { signal });
element3.addEventListener('click', handler3, { signal });

// Remove all at once
controller.abort();
```

**Tie to component lifecycle:**

```javascript
class Component {
  constructor() {
    this.controller = new AbortController();
  }
  
  mount() {
    document.addEventListener('click', this.handleClick, {
      signal: this.controller.signal
    });
  }
  
  unmount() {
    this.controller.abort(); // Cleanup all listeners
  }
  
  handleClick = (event) => { /* ... */ }
}
```

**Timeout-based removal:**

```javascript
const controller = new AbortController();
setTimeout(() => controller.abort(), 5000);

element.addEventListener('click', handler, { 
  signal: controller.signal 
}); // Auto-removes after 5 seconds
```

### Custom Events

`addEventListener()` works with custom events via `CustomEvent`:

```javascript
element.addEventListener('myEvent', (event) => {
  console.log(event.detail); // Custom data
});

const event = new CustomEvent('myEvent', {
  detail: { key: 'value' },
  bubbles: true,
  cancelable: true
});

element.dispatchEvent(event);
```

### Return Values

- `addEventListener()`: `undefined` (void)
- `removeEventListener()`: `undefined` (void)

**[Unverified]** Neither method indicates success/failure. Removal of non-existent listeners fails silently.

---

