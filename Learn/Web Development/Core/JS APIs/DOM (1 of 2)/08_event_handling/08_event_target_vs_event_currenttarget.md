## Event.target vs Event.currentTarget


### Fundamental Distinction

`Event.target` and `Event.currentTarget` represent different elements in the event flow, which becomes critical when events bubble or capture through nested DOM structures.

**Event.target**: The element that originally triggered the event (where the event actually occurred)

**Event.currentTarget**: The element that the event listener is attached to (where the handler is registered)

```javascript
document.querySelector('.parent').addEventListener('click', (event) => {
  console.log(event.target);        // Element that was clicked
  console.log(event.currentTarget); // Always .parent (the listener's element)
});
```

### Event Flow Context

Understanding these properties requires knowledge of how events propagate through the DOM:

1. **Capture phase**: Event travels down from document root to target
2. **Target phase**: Event reaches the actual target element
3. **Bubble phase**: Event bubbles back up to document root

```html
<div class="grandparent">
  <div class="parent">
    <button class="child">Click me</button>
  </div>
</div>
```

```javascript
const grandparent = document.querySelector('.grandparent');
const parent = document.querySelector('.parent');
const button = document.querySelector('.child');

grandparent.addEventListener('click', (e) => {
  console.log('Grandparent handler');
  console.log('target:', e.target);              // <button>
  console.log('currentTarget:', e.currentTarget); // <div class="grandparent">
});

parent.addEventListener('click', (e) => {
  console.log('Parent handler');
  console.log('target:', e.target);              // <button>
  console.log('currentTarget:', e.currentTarget); // <div class="parent">
});

button.addEventListener('click', (e) => {
  console.log('Button handler');
  console.log('target:', e.target);              // <button>
  console.log('currentTarget:', e.currentTarget); // <button>
});
```

When clicking the button:

- `e.target` is always `<button>` in all three handlers
- `e.currentTarget` changes based on which element's listener is executing

### Behavior When Target Equals CurrentTarget

At the target phase, both properties reference the same element:

```javascript
button.addEventListener('click', (e) => {
  console.log(e.target === e.currentTarget); // true
  console.log(e.eventPhase === Event.AT_TARGET); // true
});
```

For non-bubbling events (like `focus`, `blur`, `load`), `target` and `currentTarget` are always identical since these events don't propagate.

### Practical Use Cases

#### Event Delegation

`Event.target` is essential for event delegation patterns:

```javascript
// Inefficient: Multiple listeners
document.querySelectorAll('.item').forEach(item => {
  item.addEventListener('click', handleClick);
});

// Efficient: Single delegated listener
document.querySelector('.list').addEventListener('click', (e) => {
  // Use target to identify which item was clicked
  if (e.target.matches('.item')) {
    handleItemClick(e.target);
  }
  
  // Or traverse to find the item
  const item = e.target.closest('.item');
  if (item) {
    handleItemClick(item);
  }
});
```

#### Preventing Action on Container

Using `currentTarget` to ensure actions only apply to the direct element:

```javascript
modal.addEventListener('click', (e) => {
  // Close only if clicking the modal background, not its contents
  if (e.target === e.currentTarget) {
    closeModal();
  }
});
```

#### Dynamic Content Handling

```javascript
document.querySelector('.dynamic-container').addEventListener('click', (e) => {
  // target identifies the specific element clicked (even if added dynamically)
  const clickedButton = e.target.closest('button');
  
  if (clickedButton) {
    const action = clickedButton.dataset.action;
    const container = e.currentTarget; // The .dynamic-container
    
    handleAction(action, clickedButton, container);
  }
});
```

#### Form Validation

```javascript
form.addEventListener('input', (e) => {
  const changedField = e.target;           // Specific input that changed
  const form = e.currentTarget;            // Always the form element
  
  validateField(changedField);
  updateFormStatus(form);
});
```

### Target Mutation Scenarios

#### Events from Child Elements

When an event originates from a deeply nested child:

```html
<div class="card">
  <div class="header">
    <h3>Title</h3>
    <span class="icon">×</span>
  </div>
  <div class="content">...</div>
</div>
```

```javascript
card.addEventListener('click', (e) => {
  console.log(e.target);        // Could be .card, .header, h3, span, etc.
  console.log(e.currentTarget); // Always .card
  
  // Finding the semantic element you care about
  if (e.target.matches('.icon') || e.target.closest('.icon')) {
    closeCard();
  }
});
```

#### Text Nodes and Inline Elements

`Event.target` can reference inline elements or even text nodes in some scenarios:

```html
<button>Click <strong>here</strong> now</button>
```

```javascript
button.addEventListener('click', (e) => {
  console.log(e.target);        // Could be <button>, <strong>, or text node
  console.log(e.currentTarget); // Always <button>
  
  // Safe way to work with the button
  const button = e.currentTarget;
  button.disabled = true;
});
```

### Arrow Functions and This Context

`currentTarget` is particularly important when `this` binding is unavailable:

```javascript
// Traditional function: 'this' equals currentTarget
element.addEventListener('click', function(e) {
  console.log(this === e.currentTarget); // true
  this.classList.toggle('active');
});

// Arrow function: 'this' is lexically bound
element.addEventListener('click', (e) => {
  // console.log(this); // Not the element
  e.currentTarget.classList.toggle('active'); // Must use currentTarget
});
```

### Capture Phase Considerations

Both properties work identically during capture phase:

```javascript
parent.addEventListener('click', (e) => {
  console.log('Bubble phase');
  console.log(e.target);        // <button>
  console.log(e.currentTarget); // <div class="parent">
}, false); // false = bubble phase (default)

parent.addEventListener('click', (e) => {
  console.log('Capture phase');
  console.log(e.target);        // <button>
  console.log(e.currentTarget); // <div class="parent">
}, true); // true = capture phase
```

The distinction between `target` and `currentTarget` remains the same regardless of event phase.

### Stopping Propagation Effects

When `stopPropagation()` or `stopImmediatePropagation()` is called, it affects which handlers execute but doesn't change `target` or `currentTarget` values:

```javascript
child.addEventListener('click', (e) => {
  console.log(e.target);        // <button>
  console.log(e.currentTarget); // <button>
  e.stopPropagation();
});

parent.addEventListener('click', (e) => {
  // This handler never executes due to stopPropagation()
  console.log('This will not run');
});
```

### Null CurrentTarget After Event Completion

After the event finishes propagating, `currentTarget` is set to `null` for garbage collection:

```javascript
let savedEvent;

button.addEventListener('click', (e) => {
  console.log(e.currentTarget); // <button>
  savedEvent = e;
  
  setTimeout(() => {
    console.log(savedEvent.target);        // Still <button>
    console.log(savedEvent.currentTarget); // null
  }, 0);
});
```

This is by design to prevent memory leaks from retained event references. `target` remains accessible because it's a direct DOM reference.

### Synthetic Events and Frameworks

React and other frameworks create synthetic event wrappers, but the `target` vs `currentTarget` distinction remains:

```jsx
// React example
<div onClick={handleClick}>
  <button>Click me</button>
</div>

function handleClick(e) {
  console.log(e.target);        // Native DOM button element
  console.log(e.currentTarget); // Native DOM div element
  
  // React's synthetic event
  console.log(e.nativeEvent.target);
  console.log(e.nativeEvent.currentTarget);
}
```

React's synthetic events maintain the same semantic distinction between these properties.

### Common Patterns and Anti-Patterns

#### Pattern: Safe Element Reference

```javascript
// Good: Using currentTarget for reliable element reference
container.addEventListener('click', (e) => {
  const container = e.currentTarget;
  container.classList.add('clicked');
});

// Risky: Using target assumes it's always the container
container.addEventListener('click', (e) => {
  e.target.classList.add('clicked'); // Might be a child element
});
```

#### Pattern: Conditional Logic Based on Target

```javascript
menu.addEventListener('click', (e) => {
  const menuItem = e.target.closest('.menu-item');
  const menu = e.currentTarget;
  
  if (menuItem && menu.contains(menuItem)) {
    handleMenuItemClick(menuItem);
  }
});
```

#### Anti-Pattern: Confusing Target with CurrentTarget

```javascript
// Problematic: Assumes target is the listened element
parent.addEventListener('click', (e) => {
  e.target.dataset.clicks++; // Might increment child's dataset, not parent's
});

// Correct: Use currentTarget for the listened element
parent.addEventListener('click', (e) => {
  e.currentTarget.dataset.clicks++;
});
```

### Performance Implications

Using `currentTarget` instead of querying the DOM provides performance benefits:

```javascript
// Less efficient: Re-querying DOM
document.querySelector('.container').addEventListener('click', (e) => {
  const container = document.querySelector('.container');
  updateContainer(container);
});

// More efficient: Using currentTarget
document.querySelector('.container').addEventListener('click', (e) => {
  updateContainer(e.currentTarget);
});
```

The event object already maintains the reference, avoiding additional DOM traversal.

### Debugging and Logging

When debugging event handlers, logging both properties reveals event flow:

```javascript
element.addEventListener('click', (e) => {
  console.log({
    target: e.target,
    currentTarget: e.currentTarget,
    phase: e.eventPhase,
    bubbles: e.bubbles,
    targetIsCurrentTarget: e.target === e.currentTarget
  });
});
```

This output clarifies whether the handler is executing due to bubbling or direct invocation.

### Edge Cases

#### Shadow DOM Boundaries

In Shadow DOM, `target` gets retargeted to maintain encapsulation:

```javascript
// Outside shadow root
customElement.addEventListener('click', (e) => {
  console.log(e.target);        // The custom element (retargeted)
  console.log(e.currentTarget); // The custom element
});

// Inside shadow root
shadowRoot.querySelector('button').addEventListener('click', (e) => {
  console.log(e.target);        // The actual button
  console.log(e.currentTarget); // The actual button
});
```

[Inference] Retargeting ensures internal shadow DOM structure remains hidden from outside listeners.

#### Detached Elements

If an element is removed from the DOM during event handling:

```javascript
element.addEventListener('click', (e) => {
  console.log(e.target);        // Still references the element
  console.log(e.currentTarget); // Still references the element
  
  e.currentTarget.remove();
  
  // Both references still work after removal
  console.log(e.target.textContent);
  console.log(e.currentTarget.textContent);
});
```

Both properties maintain references to elements even after DOM removal during the event.

---

