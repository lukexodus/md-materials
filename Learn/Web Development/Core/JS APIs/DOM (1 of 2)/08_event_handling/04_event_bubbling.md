## Event Bubbling


### Propagation Mechanism

Event bubbling describes the upward propagation of events through the DOM tree. When an event fires on an element, it first runs handlers on that element, then on its parent, then on its grandparent, continuing upward until reaching the document root. This occurs during the bubbling phase of event propagation.

The event travels from the target element where it originated, moving up through each ancestor element in the DOM hierarchy. Each ancestor's event listeners for that event type execute in sequence as the event bubbles upward.

### Three Phases of Event Propagation

Event propagation consists of three distinct phases:

**Capturing Phase**: The event travels down from the window through ancestors to the target element. Listeners registered with `capture: true` or `useCapture: true` execute during this phase.

**Target Phase**: The event reaches the target element itself. Listeners on the target execute regardless of their capture setting.

**Bubbling Phase**: The event travels back up from the target through ancestors to the window. This is the default phase for event listeners.

### Event Object Properties

`event.target` references the element where the event originally occurred and remains constant throughout propagation.

`event.currentTarget` references the element whose listener is currently executing, changing as the event bubbles through each ancestor.

`event.eventPhase` returns a number indicating the current phase: 1 (capturing), 2 (target), or 3 (bubbling).

### Stopping Propagation

`event.stopPropagation()` prevents the event from bubbling to ancestor elements. Handlers on the current element still execute, but no ancestor handlers receive the event.

`event.stopImmediatePropagation()` stops propagation and prevents other handlers on the same element from executing. If multiple listeners exist on one element, this prevents subsequent listeners from running.

### Events That Bubble

Most events bubble by default, including:

- Mouse events: `click`, `dblclick`, `mousedown`, `mouseup`, `mousemove`, `mouseover`, `mouseout`
- Keyboard events: `keydown`, `keyup`, `keypress`
- Form events: `submit`, `change`, `input`
- UI events: `scroll` (document/window level), `select`

### Events That Do Not Bubble

Certain events do not bubble through the DOM:

- `focus` and `blur` (though `focusin` and `focusout` are bubbling alternatives)
- `load` and `unload`
- `mouseenter` and `mouseleave` (though `mouseover` and `mouseout` do bubble)
- Media events: `play`, `pause`, `playing`
- `error` (in most contexts)

The `bubbles` property on the event object returns `true` or `false` to indicate whether an event type bubbles.

### Event Delegation Pattern

Event delegation leverages bubbling by attaching a single listener to a parent element rather than individual listeners to many children. The listener examines `event.target` to determine which child triggered the event and responds accordingly.

Benefits include reduced memory usage (fewer listeners), automatic handling of dynamically added elements, and simplified code maintenance. The parent listener handles events for all current and future children without requiring listener registration on each child element.

```javascript
document.getElementById('parent').addEventListener('click', function(event) {
  if (event.target.matches('.child-class')) {
    // Handle click on any .child-class element
  }
});
```

### Bubbling with Event Listeners

Event listeners register for the bubbling phase by default. The third parameter in `addEventListener` controls this:

```javascript
element.addEventListener('click', handler); // Bubbling phase (default)
element.addEventListener('click', handler, false); // Bubbling phase (explicit)
element.addEventListener('click', handler, true); // Capturing phase
element.addEventListener('click', handler, { capture: true }); // Capturing phase
```

### Preventing Default Behavior vs Stopping Propagation

`event.preventDefault()` and `event.stopPropagation()` serve different purposes and are independent:

`preventDefault()` cancels the browser's default action for an event (following a link, submitting a form) but does not affect propagation.

`stopPropagation()` halts event propagation but does not prevent default browser behavior.

These can be used together or separately depending on requirements.

### Bubbling in Form Events

Form events exhibit specific bubbling behavior. The `submit` event bubbles, allowing delegation on form containers. The `change` event bubbles, enabling centralized handling of input changes. The `input` event also bubbles, providing real-time value change detection through delegation.

`focus` and `blur` do not bubble, but `focusin` and `focusout` were introduced as bubbling alternatives for focus-related delegation.

### Practical Considerations

**Performance**: Delegation through bubbling reduces the number of event listeners, improving memory efficiency and initialization time for pages with many interactive elements.

**Dynamic Content**: Bubbling handles dynamically added content automatically. A delegated listener continues working for elements added to the DOM after page load.

**Event Order**: Multiple listeners on the same element execute in registration order during the same phase. Listeners registered first execute first.

**Memory Leaks**: Fewer event listeners reduce the risk of memory leaks from orphaned listener references, particularly relevant when removing DOM elements.

### Bubbling with Custom Events

Custom events created via `new Event()` or `new CustomEvent()` accept a `bubbles` option:

```javascript
const event = new CustomEvent('myEvent', { 
  bubbles: true,  // Enable bubbling
  cancelable: true,
  detail: { /* custom data */ }
});
element.dispatchEvent(event);
```

Without `bubbles: true`, custom events do not bubble by default.

### Browser Differences

[Inference] Modern browsers implement event bubbling consistently according to DOM Level 3 Events specification. Historical differences in Internet Explorer's event model (using `srcElement` instead of `target`, `cancelBubble` instead of `stopPropagation()`) are no longer relevant for current development targeting modern browsers.

### Interaction with Shadow DOM

[Inference] Event bubbling interacts with Shadow DOM encapsulation. Events originating inside a shadow root can bubble up through the shadow boundary, but `event.target` gets retargeted to the shadow host when accessed from outside the shadow tree. The `event.composedPath()` method provides the full propagation path including shadow DOM elements for events with `composed: true`.

---

