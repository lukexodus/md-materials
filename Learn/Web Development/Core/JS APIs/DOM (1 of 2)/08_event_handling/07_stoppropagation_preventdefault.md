## stopPropagation, preventDefault


### Core Mechanics

**stopPropagation()** halts event progression through the DOM tree. Once called, the event stops traveling to subsequent nodes in the propagation path.

**preventDefault()** cancels the browser's default action for that event. The event continues propagating, but the native behavior (link navigation, form submission, text selection, etc.) is blocked.

These are independent operations—calling one doesn't affect the other's behavior.

```javascript
element.addEventListener('click', (e) => {
  e.stopPropagation(); // Event won't bubble to parent
  e.preventDefault();   // Link won't navigate (if on <a>)
});
```

### Event Propagation Phases

Events traverse three phases:

1. **Capture phase**: Root → target (downward)
2. **Target phase**: Handlers on the target element itself
3. **Bubble phase**: Target → root (upward)

**stopPropagation() behavior per phase:**

```javascript
// Capture phase listener
parent.addEventListener('click', (e) => {
  e.stopPropagation(); // Stops before reaching child
}, true); // Third parameter = capture phase

// Bubble phase listener (default)
child.addEventListener('click', (e) => {
  e.stopPropagation(); // Stops before reaching parent
});
```

When called during capture, the event never reaches the target. When called during bubble, the event doesn't propagate upward.

### Target Phase Behavior

[Inference: Based on event dispatch ordering]

During the target phase, **all listeners on the target element execute** regardless of when stopPropagation() is called:

```javascript
target.addEventListener('click', (e) => {
  console.log('First'); // Executes
  e.stopPropagation();
});

target.addEventListener('click', (e) => {
  console.log('Second'); // Still executes
});

// Both log, then propagation stops
```

stopPropagation() only prevents reaching **different elements**, not other listeners on the same element.

### stopImmediatePropagation()

Halts propagation **and** prevents subsequent listeners on the current element:

```javascript
target.addEventListener('click', (e) => {
  console.log('First'); // Executes
  e.stopImmediatePropagation();
});

target.addEventListener('click', (e) => {
  console.log('Second'); // Never executes
});
```

Listener execution order follows registration order. stopImmediatePropagation() creates a hard stop at the current listener.

### Cancelable vs Non-Cancelable Events

preventDefault() only works if `event.cancelable === true`:

**Cancelable events** (partial list):

- `click`, `mousedown`, `mouseup`
- `keydown`, `keypress` (keyup is not cancelable [Unverified])
- `submit`, `contextmenu`
- `touchstart`, `touchmove`
- `wheel`, `beforeunput`

**Non-cancelable events**:

- `scroll` (already occurred)
- `focus`, `blur`
- `load`, `unload`
- `mouseenter`, `mouseleave`
- Most custom events unless explicitly set

```javascript
element.addEventListener('scroll', (e) => {
  e.preventDefault(); // No effect, scroll already happened
});

element.addEventListener('click', (e) => {
  console.log(e.cancelable); // true
  e.preventDefault(); // Works
});
```

### Default Actions by Event Type

**click on `<a>`:**

- Default: Navigate to href
- preventDefault(): Cancels navigation
- Common use: SPA routing, confirmation dialogs

**submit on `<form>`:**

- Default: HTTP submission, page reload
- preventDefault(): Stops submission
- Common use: AJAX form handling

**contextmenu:**

- Default: Shows browser context menu
- preventDefault(): Suppresses native menu
- Common use: Custom right-click menus

**keydown:**

- Default: Character insertion, shortcuts
- preventDefault(): Blocks key action
- Common use: Custom keyboard handling

```javascript
// Disable specific key
input.addEventListener('keydown', (e) => {
  if (e.key === 'Enter') {
    e.preventDefault(); // Prevents form submission or newline
  }
});
```

**dragstart:**

- Default: Initiates drag operation
- preventDefault(): Cancels drag
- Common use: Disable dragging on images/links

### defaultPrevented Property

Read-only boolean indicating if preventDefault() was called:

```javascript
child.addEventListener('click', (e) => {
  e.preventDefault();
});

parent.addEventListener('click', (e) => {
  console.log(e.defaultPrevented); // true
  // Parent can check if child cancelled default action
});
```

Useful for conditional logic in parent handlers that need to know if a descendant already cancelled the default.

### returnValue Property (Legacy)

Setting `event.returnValue = false` is the legacy IE equivalent of preventDefault():

```javascript
// Modern
e.preventDefault();

// Legacy (still works, but deprecated)
e.returnValue = false;
```

Modern code should use preventDefault(). returnValue exists for backwards compatibility [Inference: based on its deprecated status in specifications].

### Passive Event Listeners

Passive listeners **cannot call preventDefault()**:

```javascript
// Throws error if preventDefault() is called
element.addEventListener('touchstart', (e) => {
  e.preventDefault(); // Error in console
}, { passive: true });

// Passive default for touch/wheel in some browsers [Unverified]
element.addEventListener('wheel', handler); // May be passive by default
```

Passive listeners improve scroll performance by telling the browser the listener won't cancel scrolling. Chrome/Firefox default touch/wheel listeners to passive [Unverified: exact default behavior varies by browser version].

**Explicitly non-passive:**

```javascript
element.addEventListener('touchstart', handler, { passive: false });
```

### Event Delegation Patterns

stopPropagation() can break delegation:

```javascript
// Parent delegator
document.addEventListener('click', (e) => {
  if (e.target.matches('.button')) {
    console.log('Button clicked'); // Won't fire if propagation stopped
  }
});

// Child that stops propagation
button.addEventListener('click', (e) => {
  e.stopPropagation(); // Breaks parent's delegation
  // Handle locally
});
```

**Delegation-safe alternative** using capture phase:

```javascript
// Capture phase catches before child handlers
document.addEventListener('click', (e) => {
  if (e.target.matches('.button')) {
    console.log('Caught in capture'); // Fires even if child stops propagation
  }
}, true);
```

### Composed Events and Shadow DOM

[Unverified: Shadow DOM event behavior specifics]

Events have a `composed` property determining if they cross shadow boundaries:

**Composed events** (cross shadow boundaries):

- `click`, `mousedown`, `mouseup`
- `keydown`, `keypress`, `keyup`
- `focus`, `blur` (with relatedTarget retargeting)

**Non-composed events** (contained within shadow root):

- `mouseenter`, `mouseleave`
- Custom events (unless `composed: true`)

```javascript
// Inside shadow DOM
shadowElement.addEventListener('click', (e) => {
  e.stopPropagation(); // Stops within shadow tree first
  // If composed=true, can still propagate to light DOM
});
```

stopPropagation() respects shadow boundaries—it stops in the current tree (shadow or light) and at the boundary decision point [Inference].

### Synchronous vs Asynchronous Effects

Both methods operate **synchronously** during event dispatch:

```javascript
link.addEventListener('click', (e) => {
  e.preventDefault();
  console.log('After preventDefault'); // Executes immediately
  // Navigation is already cancelled at this point
});
```

The cancellation/stopping occurs immediately, not after the handler completes.

### preventDefault() on Custom Events

Custom events are non-cancelable by default:

```javascript
// Non-cancelable (default)
const event1 = new CustomEvent('myevent');
element.dispatchEvent(event1);
// preventDefault() would have no effect

// Cancelable
const event2 = new CustomEvent('myevent', { 
  cancelable: true 
});
element.dispatchEvent(event2);
// preventDefault() works, can check defaultPrevented
```

Check `event.cancelable` before attempting to prevent default on custom events.

### Multiple preventDefault() Calls

Calling preventDefault() multiple times is safe but redundant:

```javascript
element.addEventListener('click', (e) => {
  e.preventDefault();
  e.preventDefault(); // No additional effect
  e.preventDefault(); // Safe, just redundant
});
```

Once cancelled, the default action cannot be "uncancelled" within the same event dispatch.

### Form Submission Edge Cases

preventDefault() on submit event stops submission, but doesn't prevent validation:

```javascript
form.addEventListener('submit', (e) => {
  e.preventDefault();
  // HTML5 validation still runs before this fires
  // Invalid inputs prevent event from firing at all
});
```

[Inference: Validation occurs before submit event dispatch]

To bypass validation:

```javascript
form.noValidate = true; // Disables HTML5 validation
// or
submitButton.formNoValidate = true; // Per-button override
```

### Checkbox/Radio Input Behavior

preventDefault() on click affects input state:

```javascript
checkbox.addEventListener('click', (e) => {
  e.preventDefault();
  // Checkbox doesn't toggle
  // checked property remains unchanged
});
```

The click's default action includes toggling the checked state. Preventing default keeps the state unchanged.

### Text Selection Prevention

**mousedown** preventDefault() blocks text selection:

```javascript
element.addEventListener('mousedown', (e) => {
  e.preventDefault(); // Prevents text selection drag
  // Useful for custom drag operations
});
```

**selectstart** is the specific event for selection initiation:

```javascript
element.addEventListener('selectstart', (e) => {
  e.preventDefault(); // Also prevents selection
});
```

### Wheel Event Scrolling

preventDefault() on wheel blocks scroll:

```javascript
element.addEventListener('wheel', (e) => {
  e.preventDefault(); // Prevents scroll
  // Custom zoom or horizontal scroll implementation
}, { passive: false }); // Must be non-passive
```

[Unverified: Default passive behavior for wheel events varies by browser]

Without `passive: false`, the listener may be treated as passive and preventDefault() may fail silently in some browsers.

### Touch Event Sequences

Touch events fire in sequence: touchstart → touchmove → touchend → click

```javascript
element.addEventListener('touchstart', (e) => {
  e.preventDefault();
  // Prevents:
  // - touchmove events
  // - touchend event
  // - subsequent click event
  // - default touch behaviors (scroll, zoom)
});
```

Preventing touchstart cancels the entire touch interaction sequence. For fine-grained control, preventDefault() on specific touch phases.

### Keyboard Modifier Keys

preventDefault() applies to the combined key action:

```javascript
input.addEventListener('keydown', (e) => {
  if (e.ctrlKey && e.key === 's') {
    e.preventDefault(); // Blocks Ctrl+S (save dialog)
    // Custom save logic
  }
});
```

Modifier keys alone (pressing Ctrl without another key) typically have no default action to prevent.

### Return False Pattern

Returning `false` from an inline handler calls both methods:

```javascript
// Inline HTML handler
<a href="#" onclick="return false"> // Equivalent to both methods

// jQuery (not vanilla JS)
$('#element').on('click', () => {
  return false; // jQuery interprets this as both methods
});

// Vanilla JS - return value ignored
element.addEventListener('click', () => {
  return false; // Does nothing in modern listeners
});
```

[Inference: Inline handler behavior is specified in HTML standard]

In modern addEventListener, return values are ignored. Explicitly call preventDefault() and/or stopPropagation().

### Event.eventPhase Property

Indicates current propagation phase:

- `Event.CAPTURING_PHASE` (1): Capture phase
- `Event.AT_TARGET` (2): Target phase
- `Event.BUBBLING_PHASE` (3): Bubble phase

```javascript
element.addEventListener('click', (e) => {
  console.log(e.eventPhase); // 2 (at target)
  if (e.eventPhase === Event.BUBBLING_PHASE) {
    e.stopPropagation();
  }
});
```

Useful for conditional propagation control based on phase.

### Propagation Path Access

`event.composedPath()` returns the full propagation path:

```javascript
child.addEventListener('click', (e) => {
  const path = e.composedPath();
  // [child, parent, grandparent, document, Window]
  
  e.stopPropagation();
  // Path still shows full route, but traversal stops here
});
```

The path is determined at event creation. stopPropagation() doesn't alter the path array, just halts traversal [Inference].

### Once Option Interaction

The `once` option removes the listener after first invocation, independent of propagation:

```javascript
element.addEventListener('click', (e) => {
  e.stopPropagation(); // Stops propagation
  // Listener auto-removes after this regardless
}, { once: true });
```

`once` operates at the listener level. stopPropagation/preventDefault operate at the event level.

### Propagation in Capture vs Bubble

Stopping in capture prevents both target and bubble phases:

```javascript
parent.addEventListener('click', (e) => {
  e.stopPropagation(); // Child never receives event
}, true); // Capture

child.addEventListener('click', () => {
  console.log('Never fires'); // Prevented by parent's capture stop
});
```

Stopping in bubble only affects remaining bubble path:

```javascript
child.addEventListener('click', (e) => {
  e.stopPropagation(); // Parent won't receive event
});

parent.addEventListener('click', () => {
  console.log('Never fires'); // Child stopped bubbling
});
```

### Link Navigation with Hash

preventDefault() on hash links (`#section`) blocks both navigation and scroll:

```javascript
<a href="#section">Jump</a>

link.addEventListener('click', (e) => {
  e.preventDefault();
  // Neither URL change nor scroll occurs
  // Custom smooth scroll implementation possible
});
```

Without preventDefault(), clicking triggers:

1. URL hash update
2. Scroll to element with matching id
3. `:target` pseudo-class activation [Inference]

### Focus Event Cancellation

Focus/blur events are **not cancelable**:

```javascript
input.addEventListener('focus', (e) => {
  e.preventDefault(); // No effect
  console.log(e.cancelable); // false
  // Focus still occurs
});
```

To prevent focus, use `element.blur()` immediately after, or prevent the user action that triggers focus (e.g., preventDefault on mousedown).

### Drag and Drop Default Behaviors

Each drag event has specific defaults:

```javascript
// Prevent default on dragover to allow drop
dropzone.addEventListener('dragover', (e) => {
  e.preventDefault(); // Required for drop to work
});

// Prevent default on drop to handle custom drop logic
dropzone.addEventListener('drop', (e) => {
  e.preventDefault(); // Prevents browser's default drop action
  // Custom drop handling
});
```

[Inference: dragover must preventDefault() for the drop event to fire]

Without preventDefault() on dragover, the drop event won't fire on that element.

### Input Event Prevention

The `input` event is **not cancelable**:

```javascript
input.addEventListener('input', (e) => {
  e.preventDefault(); // No effect
  console.log(e.cancelable); // false
  // Input value change already occurred
});
```

To prevent input changes, use `beforeinput` (cancelable):

```javascript
input.addEventListener('beforeinput', (e) => {
  e.preventDefault(); // Blocks the input change
  console.log(e.cancelable); // true
});
```

[Unverified: beforeinput support varies, older browsers may not support it]

### Performance Implications

[Inference: Based on browser rendering optimization patterns]

**stopPropagation() performance:**

- Minimal impact—stops iteration through listener array
- Reduces handler invocations, potentially improving performance
- Can break expected behavior if delegation patterns depend on bubbling

**preventDefault() performance:**

- Minimal direct cost
- May have indirect benefits (e.g., preventing scroll allows custom handling)
- Passive listeners optimize by guaranteeing preventDefault() won't be called

Neither method has significant inherent performance cost. The impact comes from what happens (or doesn't happen) as a result.

---

