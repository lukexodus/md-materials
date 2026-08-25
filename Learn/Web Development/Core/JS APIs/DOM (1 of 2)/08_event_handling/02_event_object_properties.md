## Event Object Properties


Event objects are fundamental structures in JavaScript that provide information about events that occur in the browser or runtime environment. When an event is triggered, an event object is automatically created and passed to event handler functions.

### Core Event Properties

**`type`**  
A string indicating the type of event that occurred (e.g., "click", "keydown", "submit"). This property is read-only and identifies which event was triggered.

**`target`**  
References the element that originally triggered the event. This is the element where the event actually occurred, not necessarily the element that has the event listener attached.

**`currentTarget`**  
References the element to which the event listener is attached. This differs from `target` during event bubbling or capturing, as the event may have originated from a child element.

**`eventPhase`**  
A number indicating the current phase of event propagation:
- `0` = NONE (no event currently being processed)
- `1` = CAPTURING_PHASE
- `2` = AT_TARGET
- `3` = BUBBLING_PHASE

**`bubbles`**  
A boolean indicating whether the event bubbles up through the DOM tree. Not all events bubble (e.g., focus and blur do not).

**`cancelable`**  
A boolean indicating whether the event's default action can be prevented using `preventDefault()`.

**`timeStamp`**  
A number representing the time (in milliseconds) at which the event was created, relative to the time origin.

**`isTrusted`**  
A boolean indicating whether the event was initiated by the browser (true) or by a script (false).

### Event Control Methods

**`preventDefault()`**  
Prevents the default action associated with the event from occurring. For example, preventing form submission or link navigation.

**`stopPropagation()`**  
Stops the event from propagating (bubbling or capturing) to parent or child elements.

**`stopImmediatePropagation()`**  
Stops the event from propagating and also prevents other listeners on the same element from being called.

### Mouse Event Properties

**`clientX` / `clientY`**  
The X and Y coordinates of the mouse pointer relative to the viewport.

**`pageX` / `pageY`**  
The X and Y coordinates of the mouse pointer relative to the entire document.

**`screenX` / `screenY`**  
The X and Y coordinates of the mouse pointer relative to the screen.

**`offsetX` / `offsetY`**  
The X and Y coordinates of the mouse pointer relative to the target element's padding edge.

**`button`**  
A number indicating which mouse button was pressed:
- `0` = left button
- `1` = middle button
- `2` = right button

**`buttons`**  
A bitmask indicating which mouse buttons are currently pressed.

**`relatedTarget`**  
References the secondary target for the event (e.g., the element the mouse is leaving in a mouseover event).

**`altKey`, `ctrlKey`, `shiftKey`, `metaKey`**  
Boolean values indicating whether these modifier keys were pressed during the event.

### Keyboard Event Properties

**`key`**  
A string representing the key value of the key pressed (e.g., "a", "Enter", "ArrowUp").

**`code`**  
A string representing the physical key on the keyboard (e.g., "KeyA", "Enter", "ArrowUp").

**`keyCode`** (deprecated)  
A numeric code representing the key pressed. This property is deprecated in favor of `key` and `code`.

**`charCode`** (deprecated)  
The Unicode value of the character key pressed. This property is deprecated.

**`altKey`, `ctrlKey`, `shiftKey`, `metaKey`**  
Boolean values indicating whether these modifier keys were pressed during the event.

**`repeat`**  
A boolean indicating whether the key is being held down and auto-repeating.

### Form Event Properties

**`data`**  
For input events, contains the inserted string.

**`inputType`**  
For input events, describes the type of change (e.g., "insertText", "deleteContentBackward").

### Touch Event Properties

**`touches`**  
A list of all touch points currently on the screen.

**`targetTouches`**  
A list of touch points that started on the target element.

**`changedTouches`**  
A list of touch points that have changed since the last event.

Each touch object contains properties like `clientX`, `clientY`, `pageX`, `pageY`, `screenX`, `screenY`, `identifier`, and `target`.

### Drag Event Properties

**`dataTransfer`**  
An object containing data being dragged and methods to manipulate it. This object has properties like `dropEffect`, `effectAllowed`, `files`, `items`, and `types`.

### Focus Event Properties

**`relatedTarget`**  
The element that is losing focus (for focusin) or gaining focus (for focusout).

### Composition Event Properties

**`data`**  
The string being composed or the result of the composition.

### Wheel Event Properties

**`deltaX`, `deltaY`, `deltaZ`**  
Numbers indicating the amount of scrolling in each direction.

**`deltaMode`**  
Indicates the unit of the delta values (pixels, lines, or pages).

### Animation and Transition Event Properties

**`animationName`**  
The name of the CSS animation.

**`elapsedTime`**  
The amount of time the animation or transition has been running (in seconds).

**`pseudoElement`**  
The name of the pseudo-element on which the animation or transition runs.

### Custom Event Properties

**`detail`**  
For CustomEvent objects, this can contain any custom data passed when the event was created.

---

