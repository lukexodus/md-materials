## Input Events


### The `input` Event

#### Firing Behavior

The `input` event fires synchronously whenever the value of an `<input>`, `<textarea>`, or `<select>` element changes through user interaction. This event fires immediately with each modification, making it the primary event for real-time value tracking.

For text inputs, `input` fires on every character addition or deletion, including typing, pasting, cutting, dragging text, voice input, and IME composition. For `<select>` elements, it fires when the selection changes. For checkboxes and radio buttons, it fires when the checked state changes.

#### Key Characteristic: User-Initiated Only

The `input` event **only** fires for changes initiated by user interaction. Programmatic value changes via JavaScript (`element.value = "new value"`) do **not** trigger `input` events. This is intentional behavior to prevent infinite loops and distinguish between user actions and script modifications.

```javascript
const textInput = document.querySelector('input[type="text"]');

textInput.addEventListener('input', (e) => {
  console.log('Current value:', e.target.value);
  // Fires on every keystroke, paste, etc.
});

// This does NOT trigger the input event
textInput.value = "programmatic change";
```

#### Event Properties

The `InputEvent` interface extends the base `Event` with specific properties:

**`data`** - Contains the inserted text for insertion operations. For deletions, this is `null`. For non-text input (like selecting from a dropdown), this may also be `null`.

**`dataTransfer`** - A `DataTransfer` object for operations involving rich content (paste, drag-drop). Contains information about transferred data formats.

**`inputType`** - A string describing the type of input action. This provides granular detail about what caused the input:

- `"insertText"` - Typing characters
- `"insertFromPaste"` - Pasting content
- `"insertFromDrop"` - Dropping content
- `"deleteContentBackward"` - Backspace key
- `"deleteContentForward"` - Delete key
- `"deleteByCut"` - Cut operation
- `"insertLineBreak"` - Enter key in textarea
- `"insertParagraph"` - Enter key creating new paragraph
- `"historyUndo"` - Undo operation (Ctrl+Z)
- `"historyRedo"` - Redo operation (Ctrl+Y)

Additional `inputType` values exist for formatting operations in `contenteditable` elements (bold, italic, indent, etc.).

**`isComposing`** - Boolean indicating whether the event is part of a composition session (IME input for languages like Chinese, Japanese, Korean). When `true`, the text is still being composed and not finalized.

#### Bubbles and Cancelable

The `input` event **bubbles**, allowing delegation from parent elements. However, it is **not cancelable** - calling `preventDefault()` has no effect. The input has already occurred by the time the event fires. To prevent input, use the `beforeinput` event instead.

#### Relationship with Composition Events

During IME composition, the `input` event interacts with composition events:

1. `compositionstart` fires when composition begins
2. Multiple `input` events fire with `isComposing: true` as the composition updates
3. `compositionend` fires when composition finalizes
4. A final `input` event fires with `isComposing: false` containing the finalized text

```javascript
textInput.addEventListener('input', (e) => {
  if (e.isComposing) {
    console.log('Still composing:', e.data);
    return; // Often want to wait for final input
  }
  console.log('Finalized input:', e.target.value);
});
```

#### Use Cases

Real-time validation, character counters, search-as-you-type, auto-saving, live preview, and any scenario requiring immediate response to value changes. The `input` event is preferred over `keydown`/`keyup` because it captures all input methods uniformly, including mobile keyboards, voice input, clipboard operations, and IME composition.

#### Performance Considerations

Because `input` fires on every character change, intensive operations (network requests, heavy computations) should be debounced or throttled:

```javascript
let timeoutId;
textInput.addEventListener('input', (e) => {
  clearTimeout(timeoutId);
  timeoutId = setTimeout(() => {
    performExpensiveOperation(e.target.value);
  }, 300);
});
```

### The `beforeinput` Event

#### Timing and Cancelability

The `beforeinput` event fires **before** the DOM is modified and **before** the `input` event. Critically, `beforeinput` is **cancelable** - calling `preventDefault()` prevents the input action entirely. This makes it the appropriate event for preventing unwanted input.

```javascript
textInput.addEventListener('beforeinput', (e) => {
  // Only allow digits
  if (e.inputType === 'insertText' && !/^\d$/.test(e.data)) {
    e.preventDefault(); // Block non-digit input
  }
});
```

#### Event Properties

`beforeinput` uses the same `InputEvent` interface as `input`, providing `data`, `dataTransfer`, `inputType`, and `isComposing` properties. The difference is timing: these properties describe the **proposed** change that hasn't occurred yet.

#### Browser Support Limitations

Browser support for `beforeinput` is incomplete. Safari and Chrome have full support, but Firefox implementation has been incomplete or inconsistent [Unverified - browser support status changes frequently]. When `beforeinput` is unavailable, input restriction typically requires combining `keydown` event filtering with `input` event correction.

#### Target Ranges

The `getTargetRanges()` method (when supported) returns the DOM ranges that would be affected by the input. This is primarily useful for `contenteditable` elements where you need to know which portions of the content are being modified.

### The `change` Event

#### Firing Conditions by Element Type

The `change` event firing behavior differs significantly based on element type:

**Text inputs (`<input type="text">`, `<textarea>`, `<input type="email">`, etc.):** Fires only when the element **loses focus** (blur) **and** the value has changed since focus was gained. This means typing multiple characters fires only one `change` event when you tab away or click elsewhere.

```javascript
textInput.addEventListener('change', (e) => {
  console.log('Final value after blur:', e.target.value);
  // Fires once when user leaves the field
});
```

**Checkboxes and radio buttons:** Fires **immediately** when the checked state changes via user interaction. No blur required.

```javascript
checkbox.addEventListener('change', (e) => {
  console.log('Checked:', e.target.checked);
  // Fires immediately on click
});
```

**Select dropdowns:** Fires **immediately** when a different option is selected. No blur required.

```javascript
selectElement.addEventListener('change', (e) => {
  console.log('Selected value:', e.target.value);
  // Fires immediately on selection change
});
```

**Range inputs (`<input type="range">`):** Firing behavior varies by browser [Unverified]. Some browsers fire continuously during dragging, others only on release. For consistent behavior during dragging, use `input` event instead.

**File inputs (`<input type="file">`):** Fires when file selection is confirmed (dialog is closed with a selection made).

**Date/time inputs:** Typically fire when the picker is closed with a new value, though exact timing can vary by browser and input type [Inference].

#### Event Properties

The `change` event uses the base `Event` interface, not `InputEvent`. It does not include `data` or `inputType` properties. Access the changed value via `e.target.value` or `e.target.checked`.

#### Bubbles and Cancelable

The `change` event **bubbles**, enabling event delegation. It is **not cancelable** - the change has already occurred. To prevent changes, you must use validation and potentially revert the value programmatically.

#### Programmatic Changes

Like `input`, the `change` event does **not** fire for programmatic value changes via JavaScript:

```javascript
// Does NOT trigger change event
textInput.value = "new value";
selectElement.selectedIndex = 2;
checkbox.checked = true;
```

To manually dispatch a `change` event after programmatic modification:

```javascript
textInput.value = "new value";
textInput.dispatchEvent(new Event('change', { bubbles: true }));
```

#### Use Cases

Form validation on field completion, saving data when user finishes editing, triggering dependent field updates (cascading dropdowns), and any scenario where you want to respond to finalized changes rather than every keystroke. For text inputs, `change` is more efficient than `input` when real-time updates aren't necessary.

#### Input vs Change Decision

Use `input` when you need immediate, real-time response to every modification. Use `change` when you only care about the final value after user completes their edit (for text) or when state actually changes (for checkboxes, selects).

### The `focus` Event

#### Focus Acquisition

The `focus` event fires when an element receives keyboard focus. Focus can be acquired through:

- Mouse/touch click on a focusable element
- Tab key navigation
- Programmatic `element.focus()` call
- Access key activation (Alt+key)
- Automatic focus on page load (autofocus attribute)

#### Focusable Elements

Not all elements are focusable by default. Naturally focusable elements include:

- Form controls: `<input>`, `<textarea>`, `<select>`, `<button>`
- Links: `<a>` with `href` attribute
- Media: `<audio>`, `<video>` with `controls` attribute
- Interactive: `<iframe>`, `<details>`, `<summary>`

Make non-focusable elements focusable by setting `tabindex`:

- `tabindex="0"` - Adds element to natural tab order
- `tabindex="-1"` - Makes programmatically focusable but removes from tab order
- `tabindex="1+"` - Defines explicit tab order (generally discouraged [Inference - based on accessibility best practices])

```javascript
const div = document.querySelector('div');
div.tabindex = 0; // Now focusable

div.addEventListener('focus', () => {
  console.log('Div received focus');
});
```

#### Event Properties

The `FocusEvent` interface extends `UIEvent` and includes:

**`relatedTarget`** - The element that previously had focus (when focusing) or will receive focus (when blurring). This is `null` when:

- Focus moves from outside the document
- Focus moves to outside the document
- The related element is in a different document/window
- Privacy/security restrictions prevent access

```javascript
input.addEventListener('focus', (e) => {
  console.log('Gained focus from:', e.relatedTarget);
  // Useful for tracking focus flow
});
```

#### Does Not Bubble

The `focus` event **does not bubble**. This means event listeners on parent elements do not receive `focus` events from child elements:

```javascript
form.addEventListener('focus', () => {
  // This will NOT fire when inputs inside the form gain focus
});
```

For bubbling focus detection, use `focusin` instead (covered below).

#### Not Cancelable

The `focus` event is **not cancelable**. You cannot prevent an element from receiving focus by calling `preventDefault()` on the focus event. Focus has already been transferred by the time the event fires.

To prevent focus programmatically, you must call `element.blur()` immediately in the focus handler (though this creates accessibility issues [Inference]):

```javascript
input.addEventListener('focus', (e) => {
  e.target.blur(); // Immediately remove focus (not recommended)
});
```

A better approach is preventing the action that would cause focus (intercept clicks, prevent tab navigation via `keydown`).

#### Use Cases

Visual feedback (highlighting focused field), displaying contextual help, triggering autocomplete suggestions, form field initialization, accessibility announcements, and focus trap implementation for modal dialogs.

#### Focus Management Best Practices

Avoid removing focus from elements that users are trying to interact with - this causes significant accessibility and usability problems. When implementing custom focus behavior, ensure keyboard users and screen reader users can navigate naturally.

### The `focusin` Event

#### Bubbling Alternative to Focus

The `focusin` event fires when an element is about to receive focus, similar to `focus`, but with one critical difference: **`focusin` bubbles**. This enables event delegation for focus events:

```javascript
form.addEventListener('focusin', (e) => {
  console.log('Something inside the form gained focus:', e.target);
  // This WILL fire when any input inside gains focus
});
```

#### Timing Relative to Focus

`focusin` fires **before** the `focus` event on the same element:

1. `focusin` fires (bubbles up through ancestors)
2. `focus` fires (only on target element)

Both events fire for the same focus action, so you typically only need to listen to one or the other, not both.

#### Event Properties

Uses the same `FocusEvent` interface as `focus`, including the `relatedTarget` property.

#### Use Cases

Event delegation for focus tracking across multiple form fields, monitoring focus within a container, implementing focus-within polyfills, and any scenario where you need focus events to bubble.

### The `blur` Event

#### Focus Loss

The `blur` event fires when an element loses keyboard focus. This occurs when:

- User clicks/taps a different focusable element
- User tabs to a different element
- Programmatic `element.blur()` call
- Programmatic `otherElement.focus()` call shifts focus
- Window/document loses focus (though exact behavior varies [Inference])

#### Relationship with Change Event

For text inputs, the blur timing is significant because it triggers the `change` event if the value was modified. The event order is:

1. `blur` fires on the element losing focus
2. `change` fires on the element losing focus (if value changed)
3. `focus` fires on the element gaining focus

This ordering means `change` handlers run before the next element's `focus` handlers.

#### Event Properties

Uses the `FocusEvent` interface. The `relatedTarget` property indicates which element is **gaining** focus (opposite of focus event):

```javascript
input.addEventListener('blur', (e) => {
  console.log('Lost focus to:', e.relatedTarget);
});
```

#### Does Not Bubble

Like `focus`, the `blur` event **does not bubble**. Use `focusout` for bubbling blur detection.

#### Not Cancelable

The `blur` event is **not cancelable**. Focus has already moved by the time the event fires. To prevent blur, you must intercept the action that would cause focus to move (not generally recommended for accessibility).

#### Use Cases

Validation when user finishes editing a field, hiding autocomplete dropdowns, saving field data, removing focus styling, cleaning up temporary UI elements, and triggering dependent calculations.

#### Common Pitfall: Blur During Interaction

A common issue occurs when clicking a button that appears on focus (like an autocomplete suggestion). The blur event fires when clicking outside the input, potentially hiding the button before the click registers:

```javascript
// Problematic pattern
input.addEventListener('focus', () => {
  button.style.display = 'block';
});

input.addEventListener('blur', () => {
  button.style.display = 'none'; // Hides before click registers
});

// Solution: Delay hiding or use mousedown instead of click
input.addEventListener('blur', () => {
  setTimeout(() => {
    button.style.display = 'none';
  }, 200);
});
```

Better solutions involve `focusout` with `relatedTarget` checking or `mousedown`/`pointerdown` events which fire before blur.

### The `focusout` Event

#### Bubbling Alternative to Blur

The `focusout` event fires when an element is about to lose focus, similar to `blur`, but **bubbles** up the DOM tree:

```javascript
form.addEventListener('focusout', (e) => {
  console.log('Something inside the form lost focus:', e.target);
  console.log('Focus moving to:', e.relatedTarget);
});
```

#### Timing Relative to Blur

`focusout` fires **before** the `blur` event:

1. `focusout` fires (bubbles up through ancestors)
2. `blur` fires (only on target element)
3. `change` fires (if applicable for text inputs)

#### relatedTarget for Click Detection

The `relatedTarget` property in `focusout` enables sophisticated focus tracking. When clicking elements that should not trigger blur-related hiding:

```javascript
container.addEventListener('focusout', (e) => {
  // Check if focus moved to something inside the container
  if (container.contains(e.relatedTarget)) {
    console.log('Focus stayed within container');
    return; // Don't hide dropdown
  }
  
  console.log('Focus left container');
  hideDropdown();
});
```

#### Use Cases

Event delegation for blur handling, focus trap implementations, dropdown/popup management, form section validation, and any scenario where you need to respond to focus leaving a container.

### Event Delegation Patterns

#### Monitoring Form Activity

Using bubbling focus/input events for centralized form handling:

```javascript
form.addEventListener('focusin', (e) => {
  if (e.target.matches('input, textarea, select')) {
    e.target.classList.add('focused-field');
    showContextualHelp(e.target);
  }
});

form.addEventListener('focusout', (e) => {
  if (e.target.matches('input, textarea, select')) {
    e.target.classList.remove('focused-field');
    hideContextualHelp();
  }
});

form.addEventListener('input', (e) => {
  if (e.target.matches('input, textarea, select')) {
    validateField(e.target);
    updateCharacterCount(e.target);
  }
});

form.addEventListener('change', (e) => {
  if (e.target.matches('input, textarea, select')) {
    saveFieldData(e.target);
  }
});
```

#### Dynamic Content Handling

Event delegation automatically handles dynamically added elements:

```javascript
// Works for elements added after listener registration
document.addEventListener('input', (e) => {
  if (e.target.matches('.autocomplete-input')) {
    fetchSuggestions(e.target.value);
  }
});
```

### Focus Trap Implementation

Implementing accessible modal focus trapping requires coordinating focus and keyboard events:

```javascript
const modal = document.querySelector('.modal');
const focusableElements = modal.querySelectorAll(
  'button, [href], input, select, textarea, [tabindex]:not([tabindex="-1"])'
);
const firstFocusable = focusableElements[0];
const lastFocusable = focusableElements[focusableElements.length - 1];

modal.addEventListener('keydown', (e) => {
  if (e.key !== 'Tab') return;
  
  if (e.shiftKey) { // Shift + Tab
    if (document.activeElement === firstFocusable) {
      e.preventDefault();
      lastFocusable.focus();
    }
  } else { // Tab
    if (document.activeElement === lastFocusable) {
      e.preventDefault();
      firstFocusable.focus();
    }
  }
});

// Return focus when closing
let previousFocus;
modal.addEventListener('focusin', (e) => {
  if (!previousFocus && !modal.contains(e.relatedTarget)) {
    previousFocus = e.relatedTarget;
  }
});

function closeModal() {
  modal.hidden = true;
  if (previousFocus) {
    previousFocus.focus();
  }
}
```

### Input Validation Patterns

#### Real-Time Validation with Input

```javascript
emailInput.addEventListener('input', (e) => {
  const value = e.target.value;
  const isValid = /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(value);
  
  e.target.classList.toggle('invalid', !isValid && value.length > 0);
  updateErrorMessage(e.target, isValid);
});
```

#### Final Validation with Change

```javascript
emailInput.addEventListener('change', (e) => {
  const value = e.target.value;
  const isValid = validateEmail(value);
  
  if (!isValid) {
    e.target.setCustomValidity('Invalid email address');
    e.target.reportValidity();
  } else {
    e.target.setCustomValidity('');
  }
});
```

#### Input Restriction with beforeinput

```javascript
numericInput.addEventListener('beforeinput', (e) => {
  // Allow only digits, backspace, delete
  if (e.inputType === 'insertText') {
    if (!/^\d$/.test(e.data)) {
      e.preventDefault();
    }
  }
  // Allow other input types (delete, paste might need additional handling)
});
```

### Composition Handling for International Input

Proper handling of IME composition prevents premature actions:

```javascript
let isComposing = false;

input.addEventListener('compositionstart', () => {
  isComposing = true;
});

input.addEventListener('compositionend', () => {
  isComposing = false;
  handleFinalInput(input.value);
});

input.addEventListener('input', (e) => {
  if (isComposing) {
    return; // Wait for composition to complete
  }
  handleFinalInput(e.target.value);
});
```

Alternatively, check `e.isComposing` directly in the `input` handler:

```javascript
input.addEventListener('input', (e) => {
  if (e.isComposing) return;
  handleFinalInput(e.target.value);
});
```

### Browser Inconsistencies

#### Input Event Timing

Some browsers may fire `input` events at slightly different times for the same user action [Unverified]. Range inputs and contenteditable elements show the most variation. Testing across browsers is necessary for precise timing requirements.

#### Focus During Page Load

The timing of focus events during initial page load, especially with autofocus attributes, can vary across browsers [Inference]. Scripts that depend on focus state immediately on load may need to check `document.activeElement` directly rather than relying solely on focus events.

#### Blur/Focusout on Window Blur

When the browser window or tab loses focus, whether blur events fire on the currently focused element varies by browser [Unverified]. Some fire blur immediately, some delay until focus returns and moves to a different element.

### Performance Optimization

#### Debouncing Input Events

For expensive operations on input:

```javascript
let debounceTimer;
input.addEventListener('input', (e) => {
  clearTimeout(debounceTimer);
  debounceTimer = setTimeout(() => {
    expensiveOperation(e.target.value);
  }, 300);
});
```

#### Throttling Input Events

For operations that should run periodically during input:

```javascript
let lastRun = 0;
const throttleMs = 200;

input.addEventListener('input', (e) => {
  const now = Date.now();
  if (now - lastRun >= throttleMs) {
    periodicOperation(e.target.value);
    lastRun = now;
  }
});
```

#### Passive Event Listeners

For focus/blur event listeners that don't call `preventDefault()` (which has no effect anyway), consider passive listeners for potential performance gains [Inference]:

```javascript
element.addEventListener('focus', handler, { passive: true });
```

---

