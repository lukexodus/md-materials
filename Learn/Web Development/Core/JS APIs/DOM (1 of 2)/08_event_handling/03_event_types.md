## Event Types


### Mouse Events

#### Click Events

**`click`** fires when a pointing device button is pressed and released on an element. The event fires after `mousedown` and `mouseup` complete on the same element. The event includes coordinates, button information, and modifier key states in the event object.

**`dblclick`** triggers on double-click actions. The timing threshold for what constitutes a double-click is system-dependent. This event fires after two `click` events.

**`contextmenu`** fires when the context menu should be displayed, typically via right-click or Shift+F10. Calling `preventDefault()` suppresses the default context menu.

#### Button State Events

**`mousedown`** fires when a pointing device button is pressed on an element. This occurs before `click` and captures which button was pressed via the `button` property (0 = primary/left, 1 = auxiliary/middle, 2 = secondary/right, 3 = fourth/back, 4 = fifth/forward).

**`mouseup`** fires when a pointing device button is released. Combined with `mousedown`, these enable drag operations and custom click behavior.

#### Movement Events

**`mousemove`** fires repeatedly as the pointer moves over an element. The frequency depends on the browser and hardware but can fire very rapidly (potentially hundreds of times per second). Event throttling or debouncing is often necessary for performance.

**`mouseenter`** fires when the pointer enters an element's boundaries. This event does not bubble and ignores entering child elements once inside the parent.

**`mouseleave`** fires when the pointer exits an element's boundaries. Like `mouseenter`, this does not bubble.

**`mouseover`** fires when the pointer enters an element or one of its children. This event bubbles, so it fires repeatedly as you move between child elements.

**`mouseout`** fires when the pointer leaves an element or enters a child element. This bubbles and is the counterpart to `mouseover`.

#### Wheel Events

**`wheel`** fires when a wheel button (typically a mouse wheel) is rotated. The `deltaX`, `deltaY`, and `deltaZ` properties indicate scroll amounts. The `deltaMode` property indicates units (pixels, lines, or pages). This replaced the deprecated `mousewheel` and `DOMMouseScroll` events.

### Keyboard Events

#### Key Actions

**`keydown`** fires when a key is pressed. For keys that produce character values, this fires before the character is inserted. Holding a key causes this event to fire repeatedly at a rate determined by system settings. The `key` property contains the string value of the key, while `code` contains the physical key identifier.

**`keyup`** fires when a key is released. This fires exactly once per key release, regardless of how long the key was held.

**`keypress`** is deprecated and should not be used. It was inconsistently implemented across browsers and has been removed from specifications.

#### Event Properties

The `key` property provides the semantic value ("a", "Enter", "ArrowLeft"). For printable characters, this reflects the actual character including shift state. For special keys, it provides semantic names.

The `code` property provides the physical key location ("KeyA", "Enter", "ArrowLeft"). This is layout-independent and represents the physical keyboard position.

The `keyCode` and `charCode` properties are deprecated legacy properties with inconsistent behavior across browsers.

Modifier key states are available via boolean properties: `ctrlKey`, `shiftKey`, `altKey`, and `metaKey` (Command on Mac, Windows key on Windows).

The `repeat` property indicates if the event is firing due to key repetition (holding the key down).

#### Input Method Editor Events

**`compositionstart`** fires when a composition session begins (e.g., entering Chinese characters via IME).

**`compositionupdate`** fires repeatedly as composition text changes.

**`compositionend`** fires when composition completes and text is committed.

These events are critical for properly handling Asian language input and other complex input methods.

### Form Events

#### Input Events

**`input`** fires synchronously when the value of an `<input>`, `<select>`, or `<textarea>` element changes. This fires for every modification, including typing, pasting, cutting, or programmatic changes via user interaction. This does not fire for programmatic value changes via JavaScript (`element.value = "..."`).

**`change`** fires when a form element's value changes and the element loses focus (for text inputs) or when the selection changes (for select, checkbox, radio). The timing differs by element type. For text inputs, this only fires on blur after modification. For checkboxes and radio buttons, it fires immediately on change.

**`beforeinput`** fires before the `input` event and before the DOM is modified. This is cancelable via `preventDefault()`, allowing you to prevent the input. The `inputType` property describes the type of input action. The `data` property contains the text being inserted (for insertable content).

#### Form Submission

**`submit`** fires when a form is submitted, either via a submit button, pressing Enter in a text field, or calling `form.submit()` programmatically (though direct `submit()` calls do not trigger this event). This is cancelable, allowing validation before submission.

**`reset`** fires when a form is reset via a reset button or `form.reset()` method call (though direct `reset()` calls do not trigger this event in all browsers [Inference]). This is cancelable.

**`formdata`** fires after the form's entry list is constructed during form submission. This allows modification of the FormData object before submission.

#### Invalid Input

**`invalid`** fires when a form control fails constraint validation. This fires during form submission when inputs have validation attributes (`required`, `pattern`, `min`, `max`, etc.) and the constraints are not met. This event does not bubble but is cancelable.

#### Selection Events

**`select`** fires when text is selected in an `<input>` or `<textarea>`. This doesn't fire on selection in regular content (use Selection API for that).

**`selectionchange`** fires on the `document` when the text selection changes anywhere in the document. This is not cancelable and does not bubble (since it fires on document).

### Focus Events

#### Focus Acquisition

**`focus`** fires when an element receives focus. This does not bubble. Focus can be given via mouse click, tab navigation, or programmatic `element.focus()` calls.

**`focusin`** fires when an element is about to receive focus. This bubbles, unlike `focus`. This fires before `focus`.

#### Focus Loss

**`blur`** fires when an element loses focus. This does not bubble.

**`focusout`** fires when an element is about to lose focus. This bubbles, unlike `blur`. This fires before `blur`.

#### Related Target

The `relatedTarget` property on focus events indicates the element that lost focus (for `focus`/`focusin`) or gained focus (for `blur`/`focusout`). This can be `null` if focus moved outside the document.

### Window and Document Events

#### Page Lifecycle

**`DOMContentLoaded`** fires on the `document` when the HTML is completely parsed and the DOM tree is built, but before all subresources (images, stylesheets, iframes) finish loading. This is often the earliest point where DOM manipulation is safe.

**`load`** fires on the `window` when the entire page and all resources (images, scripts, stylesheets) have finished loading.

**`beforeunload`** fires when the window, document, or resources are about to be unloaded. Setting the `returnValue` property or returning a string (legacy) triggers a confirmation dialog asking if the user wants to leave. Modern browsers ignore custom messages and show generic text.

**`unload`** fires when the document or resource is being unloaded. This fires after `beforeunload`. Reliability is limited on mobile browsers and in some scenarios.

**`pagehide`** fires when a session history entry is being traversed away from. This is more reliable than `unload` and includes a `persisted` property indicating if the page is entering the back-forward cache.

**`pageshow`** fires when a session history entry is being traversed to. The `persisted` property indicates if the page was restored from the back-forward cache.

#### Visibility

**`visibilitychange`** fires on the `document` when the page becomes visible or hidden (e.g., switching tabs, minimizing browser). Check `document.hidden` or `document.visibilityState` to determine current state.

#### Hash Changes

**`hashchange`** fires on the `window` when the URL fragment identifier (the part after #) changes. The event object includes `oldURL` and `newURL` properties.

#### History Navigation

**`popstate`** fires when the active history entry changes via browser back/forward buttons or `history.back()`/`history.forward()` calls. The `state` property contains the state object associated with the history entry. This does not fire for `history.pushState()` or `history.replaceState()`.

### Clipboard Events

**`copy`** fires when the user initiates a copy action (Ctrl+C, right-click copy, etc.). Access clipboard data via `event.clipboardData`. Calling `preventDefault()` prevents the default copy behavior, allowing custom clipboard data.

**`cut`** fires when the user initiates a cut action. Similar to `copy` but also removes the selection.

**`paste`** fires when the user initiates a paste action. The `event.clipboardData` provides access to the clipboard contents. Calling `preventDefault()` prevents the default paste behavior.

The `clipboardData` property is a `DataTransfer` object with methods like `getData(type)`, `setData(type, data)`, and `types` property listing available formats.

### Drag and Drop Events

#### On the Dragged Element

**`dragstart`** fires when drag operation begins. Set `event.dataTransfer.effectAllowed` to specify allowed operations. Call `setData()` to add data to the transfer.

**`drag`** fires repeatedly while the element is being dragged (similar to `mousemove` frequency).

**`dragend`** fires when drag operation completes (via drop or cancellation). The `dropEffect` property indicates what operation occurred.

#### On Drop Targets

**`dragenter`** fires when dragged content enters a valid drop target. This bubbles.

**`dragover`** fires repeatedly while dragged content is over a drop target. Must call `preventDefault()` to indicate the element is a valid drop target. Set `event.dataTransfer.dropEffect` to specify visual feedback.

**`dragleave`** fires when dragged content leaves a drop target.

**`drop`** fires when content is dropped on a valid drop target. Only fires if `dragover` called `preventDefault()`. Access dropped data via `event.dataTransfer.getData()`.

The `dataTransfer` object includes `files` property for file drops, `effectAllowed` and `dropEffect` for operation types, and methods for managing drag data.

### Touch Events

**`touchstart`** fires when one or more touch points are placed on the touch surface.

**`touchmove`** fires when touch points move along the surface. Fires repeatedly at high frequency.

**`touchend`** fires when touch points are removed from the surface.

**`touchcancel`** fires when touch points are interrupted (e.g., too many touch points, system interruption, alert dialog).

#### Touch Event Properties

The `touches` property contains all current touch points on the screen, regardless of target element.

The `targetTouches` property contains touch points that started on the current target element.

The `changedTouches` property contains touch points that changed in this event (added for `touchstart`, moved for `touchmove`, removed for `touchend`).

Each touch object includes `identifier` (unique ID), `screenX`/`screenY`, `clientX`/`clientY`, `pageX`/`pageY`, `radiusX`/`radiusY` (contact area), and `target` (element where touch started).

### Pointer Events

Pointer events unify mouse, touch, and pen input into a single event model.

**`pointerdown`** fires when a pointer becomes active (mouse press, touch contact, pen contact).

**`pointermove`** fires when pointer coordinates change.

**`pointerup`** fires when pointer is no longer active (mouse release, touch lift, pen lift).

**`pointercancel`** fires when pointer events are interrupted.

**`pointerenter`** fires when pointer enters element boundaries (does not bubble).

**`pointerleave`** fires when pointer exits element boundaries (does not bubble).

**`pointerover`** fires when pointer enters element or child (bubbles).

**`pointerout`** fires when pointer leaves element or enters child (bubbles).

**`gotpointercapture`** fires when an element receives pointer capture.

**`lostpointercapture`** fires when pointer capture is released.

#### Pointer Event Properties

The `pointerId` uniquely identifies each pointer (distinct for each finger, stylus, etc.).

The `pointerType` indicates device type: "mouse", "pen", "touch", or empty string for unknown.

The `isPrimary` boolean indicates if this is the primary pointer of its type.

Pressure, tilt, width, height, and other properties provide detailed input data for stylus and touch.

Call `element.setPointerCapture(pointerId)` to capture all future pointer events to that element until release. Call `element.releasePointerCapture(pointerId)` to release capture.

### Media Events

#### Loading States

**`loadstart`** fires when media begins loading.

**`progress`** fires periodically while media is loading. The `buffered` property indicates loaded time ranges.

**`canplay`** fires when enough data is available to begin playback, but buffering may still be needed.

**`canplaythrough`** fires when enough data is loaded that playback can proceed without buffering interruptions (estimated by browser).

**`loadedmetadata`** fires when media metadata (duration, dimensions) is loaded.

**`loadeddata`** fires when data for the current frame is loaded.

#### Playback Events

**`play`** fires when playback begins (via `play()` call or autoplay).

**`playing`** fires when playback starts after being paused or delayed due to buffering.

**`pause`** fires when playback is paused.

**`ended`** fires when playback reaches the end of the media.

**`seeking`** fires when seek operation begins.

**`seeked`** fires when seek operation completes.

**`timeupdate`** fires when the `currentTime` property changes. This typically fires at ~4Hz during playback but frequency varies by browser.

**`waiting`** fires when playback stops due to buffering.

**`stalled`** fires when loading data has stalled unexpectedly.

**`suspend`** fires when media loading is deliberately suspended.

**`emptied`** fires when media becomes empty (e.g., loading new source).

**`durationchange`** fires when the `duration` property changes.

**`ratechange`** fires when playback rate changes.

**`volumechange`** fires when volume or muted state changes.

**`error`** fires when an error occurs loading or playing media. Check the `error` property for details.

### Transition and Animation Events

#### CSS Transitions

**`transitionrun`** fires when a transition is created (including delay).

**`transitionstart`** fires when transition actually begins (after delay).

**`transitionend`** fires when transition completes.

**`transitioncancel`** fires when transition is cancelled.

The `propertyName` property indicates which CSS property transitioned. The `elapsedTime` property indicates transition duration (excluding delay for `transitionend`).

#### CSS Animations

**`animationstart`** fires when animation begins (after delay).

**`animationend`** fires when animation completes.

**`animationiteration`** fires at the end of each animation iteration (except the last).

**`animationcancel`** fires when animation is cancelled.

The `animationName` property contains the animation's name. The `elapsedTime` property indicates time since animation started.

### Scroll Events

**`scroll`** fires when an element's scroll position changes. This can fire at high frequency during scrolling. The event does not bubble on most elements except `document` [Inference]. Use passive event listeners for performance when not calling `preventDefault()`.

**`scrollend`** fires when scrolling completes and the scroll position has stabilized. Browser support is recent and limited [Inference - based on specification timing].

Scroll events do not provide delta information directly. Access scroll position via `scrollTop`, `scrollLeft`, `scrollX`, or `scrollY` properties.

### Resize Events

**`resize`** fires on the `window` when the viewport is resized. This can fire at high frequency during manual resizing. Debouncing or throttling is typically necessary.

ResizeObserver API provides more granular element-specific resize detection without the limitations of `resize` events.

### Print Events

**`beforeprint`** fires before the print dialog opens or print operation begins.

**`afterprint`** fires after the print dialog closes or print operation completes (regardless of whether printing occurred).

These events fire on the `window` object and allow for print-specific styling or content modification.

### Error and Promise Events

**`error`** fires on the `window` when a JavaScript error occurs and is uncaught. The event object includes `message`, `filename`, `lineno`, `colno`, and `error` (the Error object) properties. This also fires on elements for resource loading failures (images, scripts).

**`unhandledrejection`** fires on the `window` when a Promise is rejected without a rejection handler. The event object includes `promise` (the rejected Promise) and `reason` (the rejection value).

**`rejectionhandled`** fires when a Promise rejection is handled after previously firing `unhandledrejection`.

### Storage Events

**`storage`** fires on the `window` when localStorage or sessionStorage is modified in another document from the same origin. This does not fire in the document that made the change. The event object includes `key`, `oldValue`, `newValue`, `url`, and `storageArea` properties.

### Online/Offline Events

**`online`** fires on the `window` when the browser gains network connectivity.

**`offline`** fires when the browser loses network connectivity.

These events reflect the browser's perception of connectivity, which may not reflect actual internet access [Inference]. Check `navigator.onLine` for current state.

### Message Events

**`message`** fires when a message is received from another context via:

- `postMessage()` from another window/iframe
- Web Workers
- Service Workers
- Broadcast Channel API
- Server-Sent Events

The event object includes `data` (the message), `origin` (source origin), `source` (source window), and `ports` (MessagePort array for transferable objects).

**`messageerror`** fires when a message is received but cannot be deserialized.

---

