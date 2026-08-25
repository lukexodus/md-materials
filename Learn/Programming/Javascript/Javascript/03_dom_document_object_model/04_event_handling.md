## **Event Handling**


### Introduction to Event Handling

Event handling is a fundamental concept in web development that enables interactive behavior on websites and applications. It refers to the process of detecting and responding to specific actions or occurrences (events) triggered by users or the browser itself. Through event handling, developers can create dynamic, responsive user interfaces that react to user interactions such as mouse clicks, keyboard inputs, form submissions, or system events like page loading and window resizing.

**Key Points**

- Events are signals that something has happened in the browser
- Event handlers are functions that execute in response to specific events
- The event-driven programming model is central to modern web development
- JavaScript provides a comprehensive API for managing various types of events
- Event handling enables creating responsive, interactive user interfaces

### Event Registration Methods

#### Method 1: HTML Attribute Event Handlers

html

```html
<button onclick="handleClick()">Click Me</button>

<script>
function handleClick() {
  console.log('Button clicked!');
}
</script>
```

#### Method 2: DOM Property Event Handlers

javascript

```javascript
const button = document.getElementById('myButton');
button.onclick = function() {
  console.log('Button clicked!');
};
```

#### Method 3: addEventListener() Method (Recommended)

javascript

```javascript
const button = document.getElementById('myButton');
button.addEventListener('click', function() {
  console.log('Button clicked!');
});
```

**Key Points**

- `addEventListener()` is the preferred modern approach
- Allows attaching multiple handlers to the same event
- Supports event delegation (discussed later)
- Provides more control over event propagation
- Can be removed using `removeEventListener()`

### **Common Event Types**

Here’s an extended list of event types you might encounter in JavaScript:

##### **Mouse Events**

1. `click` – Triggered when an element is clicked.
2. `dblclick` – Triggered when an element is double-clicked.
3. `mousedown` – Triggered when a mouse button is pressed down on an element.
4. `mouseup` – Triggered when a mouse button is released.
5. `mousemove` – Triggered when the mouse pointer is moved over an element.
6. `mouseenter` – Triggered when the mouse pointer enters the element's area (does not bubble).
7. `mouseleave` – Triggered when the mouse pointer leaves the element's area (does not bubble).
8. `mouseover` – Triggered when the mouse pointer moves over an element or its children.
9. `mouseout` – Triggered when the mouse pointer leaves an element or its children.
10. `contextmenu` - Fired when right-clicking to open context menu

---

##### **Keyboard Events**

1. `keydown` – Triggered when a key is pressed down.
2. `keyup` – Triggered when a key is released.
3. `keypress` – Deprecated in modern browsers. Use `keydown` or `keyup` instead.

---

##### **Form Events**

1. `submit` – Triggered when a form is submitted.
2. `reset` – Triggered when a form is reset.
3. `focus` – Triggered when an element gains focus.
4. `blur` – Triggered when an element loses focus.
5. `change` – Triggered when the value of an `<input>`, `<select>`, or `<textarea>` element changes.
6. `input` – Triggered when the value of an `<input>` or `<textarea>` changes (more responsive than `change`).
7. `select` – Triggered when text in an `<input>` or `<textarea>` is selected.
8. `invalid` - Fired when a form element fails validation

---

##### **Drag and Drop Events**

1. `drag` – Triggered continuously while an element is being dragged.
2. `dragstart` – Triggered when dragging starts.
3. `dragend` – Triggered when dragging stops.
4. `dragenter` – Triggered when a draggable element enters a valid drop target.
5. `dragleave` – Triggered when a draggable element leaves a valid drop target.
6. `dragover` – Triggered when a draggable element is dragged over a valid drop target.
7. `drop` – Triggered when a draggable element is dropped on a valid drop target.

---

##### **Touch Events (Mobile Devices)**

1. `touchstart` – Triggered when a finger touches the screen.
2. `touchmove` – Triggered when a finger moves across the screen.
3. `touchend` – Triggered when a finger is removed from the screen.
4. `touchcancel` – Triggered when the touch action is interrupted (e.g., an incoming call).

---

##### **Window Events**

1. `load` – Triggered when the entire page, including images and sub-resources, has loaded.
2. `unload` – Triggered when the page is unloaded (deprecated, use `beforeunload`).
3. `resize` – Triggered when the window is resized.
4. `scroll` – Triggered when the user scrolls the document or an element.
5. `beforeunload` – Triggered before the user leaves the page (useful for warnings).
6. `DOMContentLoaded` - Fired when the HTML document has been fully parsed

---

##### **Clipboard Events**

1. `copy` – Triggered when content is copied to the clipboard.
2. `cut` – Triggered when content is cut to the clipboard.
3. `paste` – Triggered when content is pasted from the clipboard.

---

##### **Media Events**

1. `play` – Triggered when media playback starts.
2. `pause` – Triggered when media playback is paused.
3. `ended` – Triggered when media playback ends.
4. `volumechange` – Triggered when the volume is changed.
5. `timeupdate` – Triggered when the playback position changes.

---

##### **Other Events**

1. `contextmenu` – Triggered when the right-click context menu is opened.
2. `error` – Triggered when an error occurs (e.g., image fails to load).
3. `animationstart`, `animationend`, `animationiteration` – Triggered during CSS animations.
4. `transitionend` – Triggered when a CSS transition finishes.
5. `hashchange` – Triggered when the URL hash changes.
6. `popstate` – Triggered when the browser's history state changes.

---

### **Event Object**

When an event occurs, the browser creates an event object containing information about the event. This object is automatically passed to event handler functions.

The `Event` object in JavaScript has a variety of attributes that provide information about an event's type, target, and other related data. Here’s a breakdown of attributes, grouped by commonality and relevance to various types of events:

```javascript
document.getElementById('myButton').addEventListener('click', function(event) {
  console.log('Event type:', event.type);                // "click"
  console.log('Target element:', event.target);          // The button element
  console.log('Current target:', event.currentTarget);   // Also the button in this case
  console.log('Mouse position:', event.clientX, event.clientY);
});
```

---

### Event Propagation

Event propagation describes how events travel through the DOM tree. There are three phases:

1. **Capturing Phase**: Event travels from the window to the target element
2. **Target Phase**: Event reaches the target element
3. **Bubbling Phase**: Event bubbles up from the target to the window

html

```html
<div id="outer">
  <div id="inner">
    <button id="button">Click Me</button>
  </div>
</div>

<script>
  document.getElementById('outer').addEventListener('click', function(e) {
    console.log('Outer div clicked');
  });
  
  document.getElementById('inner').addEventListener('click', function(e) {
    console.log('Inner div clicked');
  });
  
  document.getElementById('button').addEventListener('click', function(e) {
    console.log('Button clicked');
  });
  
  // Output when button is clicked:
  // "Button clicked"
  // "Inner div clicked"
  // "Outer div clicked"
</script>
```


There are three main phases of event propagation:

---

#### **Capturing Phase (Trickling Phase)**

In this phase, the event starts from the outermost ancestor (usually `document`) and "trickles down" to the target element. This is the first phase of propagation.

- **Capturing** occurs before the event reaches the target element.
- To handle events in this phase, the listener must be set to capture events (by setting `capture` to `true` in `addEventListener`).

Example:

```javascript
document.querySelector("div").addEventListener("click", () => {
  console.log("Capturing phase");
}, true); // Setting true for capturing
```

**Purpose:**

- The capturing phase allows **ancestor elements to detect events before they reach the target element**. This can be useful for scenarios where you want to handle an event early in its propagation and perhaps even prevent it from reaching its target.

**Rationale:**

- **Early interception**: Allows outer elements (like containers or the `document`) to monitor or intercept events before they reach deeply nested child elements.
- **Specific use cases**:
    - Preventing certain actions from occurring by stopping propagation early (e.g., disabling clicks within a modal or dropdown menu).
    - Efficient handling of high-level actions (e.g., logging or analytics tracking) without needing to know which specific child element triggered the event.

##### Event Capturing

To capture events during the capturing phase, set the third parameter of `addEventListener()` to `true`:

```javascript
document.getElementById('outer').addEventListener('click', function(e) {
  console.log('Outer div - capturing phase');
}, true);

// This handler will fire BEFORE the button's handler
```

Event propagation refers to the way events are handled in the DOM (Document Object Model) when an event occurs. By default, when an event happens on an element, it doesn't just affect that element but may also affect its ancestors or child elements, depending on the type of event propagation used.

---

#### **Target Phase**

This is when the event actually reaches the target element, i.e., the element that directly triggered the event (such as a button being clicked).

- The event is now on the target element, and event listeners attached directly to this element are invoked.
- This phase occurs between the capturing and bubbling phases.

**Purpose:**

- The target phase ensures that the **event is handled directly by the target element**, which is where the event originated.

**Rationale:**

- **Direct interaction**: This phase gives the element that initiated the event a chance to respond to it first.
- **Clarity of responsibility**: The target element's handlers are designed to deal specifically with its own functionality, such as reacting to a button click or form input.
- Without this phase, it would be difficult to distinguish between capturing or bubbling handlers and the element’s own behavior.

---

#### **Bubbling Phase**

After the event reaches the target element, it starts bubbling up through the DOM hierarchy, from the target element back to the root of the document. This phase is called "bubbling" because the event "bubbles" up through the ancestors of the target element.

- Bubbling is the default phase for most events.

**Purpose:**

- The bubbling phase allows **ancestor elements to handle events after they’ve been processed by the target element**. This phase is the default for most events because it allows for higher-level abstraction and delegation of event handling.

**Rationale:**

- **Event delegation**: Bubbling supports the delegation of event handling to ancestor elements. For example, instead of attaching click listeners to every button in a list, you can attach a single listener to the parent element that listens for clicks on its children.
    - This improves **performance** and **maintainability** in large DOM structures.
- **Post-processing**: Ancestors can respond to an event after the target has already handled it. For example:
    - A button click handler (on the button) might update some data.
    - A parent container might listen to the bubbling event to log the click or trigger additional UI changes.
- **Flexibility**: Provides a "last chance" to process the event at higher levels if it wasn’t already handled by the target or during capturing.


**Why Have Both Capturing and Bubbling?**

The **combination of capturing and bubbling** gives developers a choice:

- Capturing lets you intercept events early and possibly stop them from reaching the target.
- Bubbling lets you handle events late, potentially reacting after the target's behavior is complete.

By providing these phases, the DOM event model ensures that developers can fine-tune how events are processed depending on the needs of their application, whether it's for **interception, direct response, or delegation**.

---

**Analogy**:

Think of a **family hierarchy**:

1. **Capturing Phase**: The grandparents are aware of something happening (e.g., a child breaking a rule) as it "trickles down" the family chain.
2. **Target Phase**: The child who caused the event (broke the rule) is directly confronted.
3. **Bubbling Phase**: After dealing with the child, the parents or grandparents can still respond (e.g., setting family rules or consequences).

This layered approach mirrors how real-world events are often managed in a hierarchical or structured way.

---

### Stopping Propagation

To prevent an event from bubbling up to parent elements:

```javascript
document.getElementById('button').addEventListener('click', function(e) {
  console.log('Button clicked');
  e.stopPropagation(); // Stops the event from bubbling up
});

// When button is clicked, only "Button clicked" will be logged
```

### Preventing Default Behavior

To prevent the browser's default action for an event:

```javascript
document.getElementById('myForm').addEventListener('submit', function(e) {
  e.preventDefault(); // Prevents form submission
  console.log('Form submission prevented');
  // Custom form handling code
});

document.getElementById('myLink').addEventListener('click', function(e) {
  e.preventDefault(); // Prevents navigating to the href URL
  console.log('Link click prevented');
});
```

### Event Delegation

Event delegation is a technique that leverages event bubbling to handle events for multiple elements with a single event listener on a common ancestor.

html

```html
<ul id="taskList">
  <li>Task 1</li>
  <li>Task 2</li>
  <li>Task 3</li>
  <!-- More items can be added dynamically -->
</ul>

<script>
  // Instead of adding listeners to each li
  document.getElementById('taskList').addEventListener('click', function(e) {
    // Check if clicked element is an li
    if (e.target.tagName === 'LI') {
      console.log('Task clicked:', e.target.textContent);
      e.target.classList.toggle('completed');
    }
  });
</script>
```

**Key Points**

- More efficient for many similar elements
- Works for dynamically added elements
- Reduces memory usage by using fewer event handlers
- Simplifies code maintenance

---

### **Common Attributes (Applicable to All Events)**

1. **`type`**
    
    - The type of the event (e.g., `"click"`, `"keydown"`).
    
    ```javascript
    console.log(event.type); // "click"
    ```
    
2. **`target`**
    
    - The element that triggered the event.
    
    ```javascript
    console.log(event.target); // <button>
    ```
    
3. **`currentTarget`**
    
    - The element to which the event handler is attached.
    
    ```javascript
    console.log(event.currentTarget); // <div>
    ```
    
4. **`bubbles`**
    
    - Indicates whether the event bubbles up through the DOM (`true` or `false`).
    
    ```javascript
    console.log(event.bubbles); // true
    ```
    
5. **`cancelable`**
    
    - Indicates whether the event can be canceled.
    
    ```javascript
    console.log(event.cancelable); // true
    ```
    
6. **`defaultPrevented`**
    
    - Indicates whether `preventDefault()` has been called on the event.
    
    ```javascript
    console.log(event.defaultPrevented); // true or false
    ```
    
7. **`eventPhase`**
    
    - Indicates the current phase of the event flow:
        - 0 = None
        - 1 = Capturing
        - 2 = Target
        - 3 = Bubbling
    
    ```javascript
    console.log(event.eventPhase); // 2
    ```
    
8. **`isTrusted`**
    
    - `true` if the event was generated by a user action, `false` if created programmatically.
    
    ```javascript
    console.log(event.isTrusted); // true
    ```
    
9. **`timeStamp`**
    
    - The time, in milliseconds, when the event was created.
    
    ```javascript
    console.log(event.timeStamp);
    ```
    

---

##### **Mouse Event Attributes (e.g., `click`, `mousedown`, `mousemove`)**

1. **`button`**
    
    - Indicates which mouse button was pressed (0 = left, 1 = middle, 2 = right).
    
    ```javascript
    console.log(event.button); // 0
    ```
    
2. **`buttons`**
    
    - Bitmask of all mouse buttons currently pressed.
    
    ```javascript
    console.log(event.buttons); // 1
    ```
    
3. **`clientX` and `clientY`**
    
    - Coordinates of the mouse pointer relative to the viewport.
    
    ```javascript
    console.log(event.clientX, event.clientY);
    ```
    
4. **`screenX` and `screenY`**
    
    - Coordinates of the mouse pointer relative to the screen.
    
    ```javascript
    console.log(event.screenX, event.screenY);
    ```
    
5. **`pageX` and `pageY`**
    
    - Coordinates of the mouse pointer relative to the document.
    
    ```javascript
    console.log(event.pageX, event.pageY);
    ```
    
6. **`relatedTarget`**
    
    - The secondary target for some events (e.g., the element the pointer moved out of in a `mouseout` event).
    
    ```javascript
    console.log(event.relatedTarget);
    ```
    

---

##### **Keyboard Event Attributes (e.g., `keydown`, `keyup`)**

1. **`key`**
    
    - The value of the key pressed (e.g., `"Enter"`, `"a"`).
    
    ```javascript
    console.log(event.key); // "Enter"
    ```
    
2. **`code`**
    
    - The physical key on the keyboard (e.g., `"KeyA"`).
    
    ```javascript
    console.log(event.code); // "KeyA"
    ```
    
3. **`keyCode`** _(Deprecated)_
    
    - The numeric code of the key.
    
    ```javascript
    console.log(event.keyCode); // 65
    ```
    
4. **`altKey`, `ctrlKey`, `metaKey`, `shiftKey`**
    
    - Booleans indicating whether these modifier keys were pressed.
    
    ```javascript
    console.log(event.altKey, event.ctrlKey);
    ```
    
5. **`repeat`**
    
    - `true` if the key is held down for a continuous event.
    
    ```javascript
    console.log(event.repeat); // false
    ```
    

---

##### **Input and Focus Event Attributes (e.g., `input`, `change`, `focus`)**

1. **`data`**
    
    - The data entered in input events.
    
    ```javascript
    console.log(event.data); // "a"
    ```
    
2. **`inputType`**
    
    - The type of change (e.g., `"insertText"`, `"deleteContentBackward"`).
    
    ```javascript
    console.log(event.inputType); // "insertText"
    ```
    
3. **`relatedTarget`**
    
    - The element losing focus in a `focus` or `blur` event.
    
    ```javascript
    console.log(event.relatedTarget);
    ```
    

---

##### **Drag and Drop Event Attributes (e.g., `dragstart`, `dragover`, `drop`)**

1. **`dataTransfer`**
    
    - Provides access to the data being dragged.
    
    ```javascript
    console.log(event.dataTransfer);
    ```
    

---

##### **Touch Event Attributes (e.g., `touchstart`, `touchmove`)**

1. **`touches`**
    
    - List of all active touch points.
    
    ```javascript
    console.log(event.touches);
    ```
    
2. **`targetTouches`**
    
    - List of touch points on the target element.
    
    ```javascript
    console.log(event.targetTouches);
    ```
    
3. **`changedTouches`**
    
    - List of touch points involved in the event.
    
    ```javascript
    console.log(event.changedTouches);
    ```
    

---

##### **Pointer Event Attributes (e.g., `pointerdown`, `pointermove`)**

1. **`pointerId`**
    
    - A unique ID for the pointer.
    
    ```javascript
    console.log(event.pointerId);
    ```
    
2. **`pointerType`**
    
    - Indicates the pointer type (`"mouse"`, `"pen"`, `"touch"`).
    
    ```javascript
    console.log(event.pointerType); // "mouse"
    ```
    
3. **`pressure`**
    
    - Pressure of the input (0 = no pressure, 1 = full pressure).
    
    ```javascript
    console.log(event.pressure); // 0.5
    ```
    

---

##### **Other Attributes**

1. **`detail`**
    
    - Additional information about the event (e.g., click count).
    
    ```javascript
    console.log(event.detail); // 2 (double-click)
    ```
    
2. **`view`**
    
    - The `window` object where the event occurred.
    
    ```javascript
    console.log(event.view);
    ```
    

##### **Custom Events Attributes (e.g., `CustomEvent`)**

1. **`detail`**
    
    - A custom property that contains any additional data passed during the event's initialization.
    
    ```javascript
    const customEvent = new CustomEvent('myEvent', { detail: { message: 'Hello!' } });
    console.log(customEvent.detail); // { message: 'Hello!' }
    ```
    

---

##### **Wheel Event Attributes (e.g., `wheel`, `mousewheel`)**

1. **`deltaX`, `deltaY`, `deltaZ`**
    
    - The amount of scrolling (in pixels, lines, or pages) along the X, Y, and Z axes.
    
    ```javascript
    console.log(event.deltaX, event.deltaY, event.deltaZ);
    ```
    
2. **`deltaMode`**
    
    - Indicates the unit of measurement for `deltaX`, `deltaY`, and `deltaZ`:
        - 0 = pixels
        - 1 = lines
        - 2 = pages
    
    ```javascript
    console.log(event.deltaMode); // 0 (pixels)
    ```
    

---

##### **Animation Event Attributes (e.g., `animationstart`, `animationend`, `animationiteration`)**

1. **`animationName`**
    
    - The name of the animation as defined in CSS.
    
    ```javascript
    console.log(event.animationName); // "slideIn"
    ```
    
2. **`elapsedTime`**
    
    - The time in seconds since the animation started.
    
    ```javascript
    console.log(event.elapsedTime); // 2.3
    ```
    
3. **`pseudoElement`**
    
    - Indicates the pseudo-element (if any) where the animation occurred (e.g., `::before`).
    
    ```javascript
    console.log(event.pseudoElement); // "::before"
    ```
    

---

##### **Transition Event Attributes (e.g., `transitionstart`, `transitionend`)**

1. **`propertyName`**
    
    - The name of the CSS property being transitioned.
    
    ```javascript
    console.log(event.propertyName); // "width"
    ```
    
2. **`elapsedTime`**
    
    - The time in seconds since the transition started.
    
    ```javascript
    console.log(event.elapsedTime); // 0.5
    ```
    
3. **`pseudoElement`**
    
    - Indicates the pseudo-element (if any) where the transition occurred.
    
    ```javascript
    console.log(event.pseudoElement); // "::after"
    ```
    

---

##### **Clipboard Event Attributes (e.g., `copy`, `cut`, `paste`)**

1. **`clipboardData`**
    
    - Provides access to the data on the system clipboard.
    
    ```javascript
    console.log(event.clipboardData.getData('text')); // Clipboard text
    ```
    

---

##### **Focus Event Attributes (e.g., `focus`, `blur`)**

1. **`relatedTarget`**
    
    - The element losing focus or gaining focus in the context of focus/blur events.
    
    ```javascript
    console.log(event.relatedTarget); // <input>
    ```
    

---

##### **Resize Event Attributes (e.g., `resize`)**

1. **`target`**
    
    - Often refers to the `window` or an element being resized.
    
    ```javascript
    console.log(event.target); // window or resized element
    ```
    

---

##### **Media Event Attributes (e.g., `play`, `pause`, `timeupdate`)**

1. **`currentTarget`**
    
    - Refers to the media element triggering the event (e.g., `<video>`, `<audio>`).
    
    ```javascript
    console.log(event.currentTarget); // <video>
    ```
    
2. **Media-specific properties from the DOM API (not strictly event attributes)**:
    
    - `currentTime`, `duration`, `paused`, `volume`, etc., which can be accessed from the media element itself.
    
    ```javascript
    console.log(event.target.currentTime); // 12.4
    ```
    

---

##### **Submit Event Attributes (e.g., `submit`)**

1. **`target`**
    
    - Refers to the form element being submitted.
    
    ```javascript
    console.log(event.target); // <form>
    ```
    
2. **`preventDefault()`**
    
    - Commonly used in submit events to prevent the default form submission behavior.
    
    ```javascript
    event.preventDefault();
    ```
    

---

##### **Form Input Event Attributes (e.g., `input`, `change`)**

1. **`value`** _(Indirectly accessed via `event.target`)_
    
    - Represents the current value of the input.
    
    ```javascript
    console.log(event.target.value); // User input
    ```
    
2. **`checked`** _(For checkboxes and radio buttons)_
    
    - Indicates whether the input is selected.
    
    ```javascript
    console.log(event.target.checked); // true or false
    ```
    

---

##### **Error Event Attributes (e.g., `error`)**

1. **`message`**
    
    - The error message string.
    
    ```javascript
    console.log(event.message); // "Script error"
    ```
    
2. **`filename`**
    
    - The name of the file in which the error occurred.
    
    ```javascript
    console.log(event.filename); // "script.js"
    ```
    
3. **`lineno`** and **`colno`**
    
    - The line and column numbers where the error occurred.
    
    ```javascript
    console.log(event.lineno, event.colno); // 42, 5
    ```
    
4. **`error`**
    
    - The error object associated with the event (if available).
    
    ```javascript
    console.log(event.error); // ReferenceError
    ```
    

---

##### **Storage Event Attributes (e.g., `storage`)**

1. **`key`**
    
    - The name of the key that changed.
    
    ```javascript
    console.log(event.key); // "theme"
    ```
    
2. **`oldValue`**
    
    - The previous value of the key.
    
    ```javascript
    console.log(event.oldValue); // "light"
    ```
    
3. **`newValue`**
    
    - The new value of the key.
    
    ```javascript
    console.log(event.newValue); // "dark"
    ```
    
4. **`storageArea`**
    
    - The storage object affected (`localStorage` or `sessionStorage`).
    
    ```javascript
    console.log(event.storageArea); // localStorage
    ```
    
5. **`url`**
    
    - The URL of the document where the change occurred.
    
    ```javascript
    console.log(event.url); // "http://example.com"
    ```
    


---

**Practical Example**

```javascript
const button = document.querySelector("button");

button.addEventListener("click", (event) => {
  console.log("Event type:", event.type);
  console.log("Triggered by:", event.target);
  console.log("Coordinates: ", event.clientX, event.clientY);

  event.preventDefault(); // Prevent default action, if any
});
```

This example logs event details and prevents the default action associated with a button click.

##### `target` vs `currentTarget`

Both `target` and `currentTarget` are properties of the `Event` object, but they serve different purposes in the event flow.

---

**`target`**

- **Definition**: Refers to the actual element that triggered the event.
- **Behavior**: It remains constant throughout the event flow (capturing, target, and bubbling phases).
- **Use Case**: Use `target` to identify the element that initiated the event, regardless of where it is being handled.

**Example**:

```javascript
document.querySelector("#container").addEventListener("click", (event) => {
  console.log("target:", event.target); // The element that was clicked
});
```

If you click a child element inside `#container`, `event.target` will point to the child element.

---

**`currentTarget`**

- **Definition**: Refers to the element on which the event listener is currently attached.
- **Behavior**: It changes as the event propagates through the DOM during capturing and bubbling phases.
- **Use Case**: Use `currentTarget` when you need to refer to the element the event handler is attached to.

**Example**:

```javascript
document.querySelector("#container").addEventListener("click", (event) => {
  console.log("currentTarget:", event.currentTarget); // Always #container
});
```

Even if you click on a child element, `event.currentTarget` will always refer to `#container` since the handler is attached there.

| **Property**                  | **target**                           | **currentTarget**                         |
| ----------------------------- | ------------------------------------ | ----------------------------------------- |
| **What it refers to**         | The element that triggered the event | The element where the handler is attached |
| **Changes during event flow** | No                                   | Yes                                       |
| **Common Use**                | To identify the origin of the event  | To reference the listener’s context       |

---

**Practical Example: Difference in Use**

Suppose you have a parent element with several child elements, and you want to handle events differently based on which child element was clicked.

**HTML**:

```html
<div id="container">
  <button id="btn1">Button 1</button>
  <button id="btn2">Button 2</button>
</div>
```

**JavaScript**:

```javascript
document.querySelector("#container").addEventListener("click", (event) => {
  console.log("target:", event.target);       // Element clicked (e.g., #btn1 or #btn2)
  console.log("currentTarget:", event.currentTarget); // Always #container
});
```

If you click `Button 1`:

- `event.target`: Points to `#btn1`.
- `event.currentTarget`: Points to `#container`.

This distinction is useful for **delegating event handling** on a parent element while still detecting specific child elements.

### Custom Events

JavaScript allows creating and dispatching custom events:

javascript

```javascript
// Create a custom event
const productAddedEvent = new CustomEvent('productAdded', {
  detail: {
    productId: '12345',
    productName: 'Wireless Headphones',
    price: 49.99
  },
  bubbles: true,
  cancelable: true
});

// Dispatch the custom event
document.getElementById('addToCartButton').addEventListener('click', function() {
  // Add product logic here
  
  // Dispatch custom event
  document.dispatchEvent(productAddedEvent);
});

// Listen for the custom event
document.addEventListener('productAdded', function(e) {
  console.log('Product added:', e.detail.productName);
  updateCart(e.detail);
});
```

### Event Handling in Different Frameworks

#### Vanilla JavaScript

javascript

```javascript
document.getElementById('button').addEventListener('click', function(e) {
  console.log('Button clicked!');
});
```

#### React

jsx

```jsx
function Button() {
  const handleClick = (e) => {
    console.log('Button clicked!');
  };
  
  return <button onClick={handleClick}>Click Me</button>;
}
```

#### Vue

html

```html
<template>
  <button @click="handleClick">Click Me</button>
</template>

<script>
export default {
  methods: {
    handleClick(e) {
      console.log('Button clicked!');
    }
  }
};
</script>
```

#### Angular

html

```html
<button (click)="handleClick($event)">Click Me</button>
```

typescript

```typescript
handleClick(event: MouseEvent) {
  console.log('Button clicked!');
}
```

### Event Handling Best Practices

#### Debouncing and Throttling

For events that fire rapidly (like resize, scroll, mousemove), implement debounce or throttle mechanisms:

javascript

```javascript
// Debounce: Execute function only after a specified delay since the last call
function debounce(fn, delay) {
  let timeoutId;
  return function(...args) {
    clearTimeout(timeoutId);
    timeoutId = setTimeout(() => fn.apply(this, args), delay);
  };
}

// Throttle: Execute function at most once per specified period
function throttle(fn, delay) {
  let lastCall = 0;
  return function(...args) {
    const now = new Date().getTime();
    if (now - lastCall < delay) return;
    lastCall = now;
    return fn.apply(this, args);
  };
}

// Usage
window.addEventListener('resize', debounce(function() {
  console.log('Window resized!');
  updateLayout();
}, 250));

window.addEventListener('scroll', throttle(function() {
  console.log('Window scrolled!');
  updateScrollEffects();
}, 100));
```

#### Memory Management

Remove event listeners when they're no longer needed to prevent memory leaks:

javascript

```javascript
function setupEventListeners() {
  const button = document.getElementById('button');
  button.addEventListener('click', handleClick);
  
  return function cleanup() {
    button.removeEventListener('click', handleClick);
  };
}

// When component is destroyed
const cleanup = setupEventListeners();
// Later when no longer needed
cleanup();
```

#### Using Event Delegation Effectively

javascript

```javascript
// Bad: Adding handlers to each button
document.querySelectorAll('.delete-btn').forEach(button => {
  button.addEventListener('click', handleDelete);
});

// Good: Using event delegation
document.getElementById('items-container').addEventListener('click', e => {
  if (e.target.matches('.delete-btn')) {
    handleDelete(e);
  }
});
```

### Event-driven Architecture

Event-driven architecture is a design pattern where the flow of the application is determined by events such as user actions, sensor outputs, or messages from other programs.

javascript

```javascript
// Simple event emitter
class EventEmitter {
  constructor() {
    this.events = {};
  }
  
  on(event, listener) {
    if (!this.events[event]) {
      this.events[event] = [];
    }
    this.events[event].push(listener);
    return this;
  }
  
  emit(event, ...args) {
    if (!this.events[event]) return false;
    this.events[event].forEach(listener => listener(...args));
    return true;
  }
  
  off(event, listener) {
    if (!this.events[event]) return this;
    this.events[event] = this.events[event].filter(l => l !== listener);
    return this;
  }
}

// Usage
const shoppingCart = new EventEmitter();

shoppingCart.on('itemAdded', (item) => {
  console.log(`${item.name} added to cart`);
  updateCartUI();
});

shoppingCart.on('itemRemoved', (item) => {
  console.log(`${item.name} removed from cart`);
  updateCartUI();
});

function addToCart(item) {
  // Add item logic
  shoppingCart.emit('itemAdded', item);
}

function removeFromCart(item) {
  // Remove item logic
  shoppingCart.emit('itemRemoved', item);
}
```

### Advanced Event Handling Techniques

#### Once Handler (Execute Only Once)

javascript

```javascript
element.addEventListener('click', function handleClick(e) {
  console.log('This will only run once');
  e.currentTarget.removeEventListener('click', handleClick);
});

// Alternatively, use the once option (modern browsers)
element.addEventListener('click', function() {
  console.log('This will only run once');
}, { once: true });
```

#### Passive Event Listeners

Improve scrolling performance by using passive event listeners:

javascript

```javascript
document.addEventListener('scroll', function() {
  console.log('Scrolling');
}, { passive: true });
```

#### Event Capture with Stop Propagation

Capture events at a high level and prevent them from reaching other elements:

javascript

```javascript
document.body.addEventListener('click', function(e) {
  if (e.target.matches('.modal-backdrop')) {
    console.log('Clicked outside modal, closing it');
    closeModal();
    e.stopPropagation();
  }
}, true); // Capture phase
```

#### Synthetic Events

Create and dispatch synthetic events to simulate user interaction:

javascript

```javascript
function simulateClick(element) {
  const event = new MouseEvent('click', {
    view: window,
    bubbles: true,
    cancelable: true
  });
  element.dispatchEvent(event);
}

// Usage
const button = document.getElementById('myButton');
simulateClick(button);
```

### Cross-browser Event Handling

#### Feature Detection

javascript

```javascript
if (typeof element.addEventListener === 'function') {
  // Modern browsers
  element.addEventListener('click', handleClick);
} else if (typeof element.attachEvent === 'function') {
  // IE < 9
  element.attachEvent('onclick', handleClick);
} else {
  // Really old browsers
  element.onclick = handleClick;
}
```

#### Normalizing Event Objects

javascript

```javascript
function normalizeEvent(e) {
  e = e || window.event;
  
  // Target
  e.target = e.target || e.srcElement;
  
  // Prevent default
  e.preventDefault = e.preventDefault || function() {
    this.returnValue = false;
  };
  
  // Stop propagation
  e.stopPropagation = e.stopPropagation || function() {
    this.cancelBubble = true;
  };
  
  return e;
}

// Usage
element.onclick = function(e) {
  e = normalizeEvent(e);
  // Now use e.target, e.preventDefault(), etc. safely
};
```

### Event Handling in Mobile Development

#### Touch vs. Mouse Events

javascript

```javascript
// Detect touch support
const isTouchDevice = 'ontouchstart' in window || 
                      navigator.maxTouchPoints > 0 ||
                      navigator.msMaxTouchPoints > 0;

// Apply appropriate event listeners
if (isTouchDevice) {
  element.addEventListener('touchstart', handleInteraction);
  element.addEventListener('touchend', finishInteraction);
} else {
  element.addEventListener('mousedown', handleInteraction);
  element.addEventListener('mouseup', finishInteraction);
}
```

#### Handling Touch and Mouse Events Together

javascript

```javascript
// Universal event handling
function addMultiEventListener(element, events, handler) {
  events.forEach(event => {
    element.addEventListener(event, handler);
  });
}

// Usage
addMultiEventListener(
  button, 
  ['click', 'touchend'], 
  function(e) {
    // Prevent double firing if both events trigger
    e.preventDefault();
    
    // Handle only once if multiple events fire
    if (e.handled) return;
    e.handled = true;
    
    // Your handler code
    console.log('Button activated');
  }
);
```

### Testing Event Handlers

#### Manual Event Triggering for Testing

javascript

```javascript
// In your test file
function triggerEvent(element, eventType, options = {}) {
  let event;
  
  switch (eventType) {
    case 'click':
    case 'mousedown':
    case 'mouseup':
      event = new MouseEvent(eventType, {
        bubbles: true,
        cancelable: true,
        view: window,
        ...options
      });
      break;
    case 'keydown':
    case 'keyup':
      event = new KeyboardEvent(eventType, {
        bubbles: true,
        cancelable: true,
        key: options.key || '',
        ...options
      });
      break;
    default:
      event = new Event(eventType, {
        bubbles: true,
        cancelable: true,
        ...options
      });
  }
  
  element.dispatchEvent(event);
  return event;
}

// Usage in test
test('Button click handler works', () => {
  const button = document.getElementById('testButton');
  let clicked = false;
  
  button.addEventListener('click', () => {
    clicked = true;
  });
  
  triggerEvent(button, 'click');
  
  expect(clicked).toBe(true);
});
```

### Event Handling for Accessibility

#### Keyboard Accessibility

javascript

```javascript
// Make elements keyboard accessible
const button = document.createElement('div');
button.setAttribute('role', 'button');
button.setAttribute('tabindex', '0');

// Handle both click and keyboard events
button.addEventListener('click', handleActivation);
button.addEventListener('keydown', function(e) {
  // Activate on Enter or Space key
  if (e.key === 'Enter' || e.key === ' ') {
    e.preventDefault();
    handleActivation(e);
  }
});
```

#### Screen Reader Notifications

javascript

```javascript
function notifyScreenReaders(message) {
  const notification = document.createElement('div');
  notification.setAttribute('aria-live', 'assertive');
  notification.setAttribute('role', 'status');
  notification.classList.add('sr-only'); // Visually hidden
  
  document.body.appendChild(notification);
  
  // Set text content after element is in the DOM
  setTimeout(() => {
    notification.textContent = message;
    
    // Remove after announcement
    setTimeout(() => {
      notification.remove();
    }, 3000);
  }, 100);
}

// Usage
document.getElementById('addToCart').addEventListener('click', function() {
  // Add product to cart
  notifyScreenReaders('Product added to cart');
});
```

**Conclusion**

Event handling is a cornerstone of modern web development that enables creating responsive, interactive user interfaces. The event-driven programming model allows applications to react to user actions and system events in real-time, creating seamless user experiences. From basic click handlers to complex event delegation patterns and custom event systems, mastering event handling techniques is essential for any front-end developer.

Understanding event propagation, knowing when to prevent default behaviors, implementing proper cleanup to avoid memory leaks, and ensuring accessibility are all critical aspects of robust event handling. As web applications continue to become more complex and interactive, applying these best practices becomes increasingly important for creating maintainable, performant, and accessible web experiences.

While the specific syntax and patterns may vary across frameworks and libraries, the core principles of event handling remain consistent. By following the techniques and patterns outlined in this comprehensive guide, developers can build more responsive, efficient, and user-friendly web applications.

---

