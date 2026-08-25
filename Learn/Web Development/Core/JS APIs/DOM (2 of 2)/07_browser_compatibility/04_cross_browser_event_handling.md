## Cross-Browser Event Handling


### Event Model Differences

#### DOM Level 0 vs DOM Level 2 Event Models

**DOM Level 0** uses inline event handlers and direct property assignment (`element.onclick = handler`). This approach supports only one handler per event type and provides limited control over event propagation.

**DOM Level 2** introduces `addEventListener()` and `removeEventListener()`, allowing multiple handlers per event, explicit phase control (capture vs bubble), and standardized event object properties.

#### Internet Explorer's Legacy Model

Internet Explorer 8 and earlier used `attachEvent()` and `detachEvent()` instead of the standard methods. Key differences include:

- Method naming: `attachEvent('onclick', handler)` vs `addEventListener('click', handler)`
- Event name prefix: IE required "on" prefix
- Execution context: `this` referred to `window` instead of the element
- Event object: Accessed via `window.event` rather than as a parameter
- No capture phase support

### Event Registration Patterns

#### Cross-Browser Event Listener Attachment

```javascript
function addEvent(element, eventType, handler) {
  if (element.addEventListener) {
    element.addEventListener(eventType, handler, false);
  } else if (element.attachEvent) {
    element.attachEvent('on' + eventType, function() {
      handler.call(element, window.event);
    });
  } else {
    element['on' + eventType] = handler;
  }
}
```

The wrapper function corrects IE's execution context issue by using `call()` to bind `this` to the target element.

#### Event Removal Considerations

Removing events requires storing references to the exact handler function. Anonymous functions cannot be removed. For IE's `attachEvent`, the wrapper function must be stored:

```javascript
function EventManager() {
  this.handlers = new WeakMap();
}

EventManager.prototype.add = function(element, eventType, handler) {
  if (element.addEventListener) {
    element.addEventListener(eventType, handler, false);
    // Store for removal
  } else if (element.attachEvent) {
    var wrapper = function() {
      handler.call(element, window.event);
    };
    element.attachEvent('on' + eventType, wrapper);
    // Store wrapper for removal
    if (!this.handlers.has(element)) {
      this.handlers.set(element, {});
    }
    this.handlers.get(element)[eventType + handler] = wrapper;
  }
};
```

### Event Object Normalization

#### Property Access Differences

Standard event objects provide properties directly, while IE's `window.event` uses different property names:

- Target element: `event.target` (standard) vs `event.srcElement` (IE)
- Related target (mouseover/out): `event.relatedTarget` vs `event.fromElement`/`event.toElement`
- Mouse button: `event.button` values differ (0/1/2 standard vs 1/4/2 IE)
- Key codes: `event.which` vs `event.keyCode`
- Page coordinates: `event.pageX/pageY` not available in IE (requires calculation)

#### Event Object Wrapper

```javascript
function normalizeEvent(event) {
  event = event || window.event;
  
  if (!event.target) {
    event.target = event.srcElement || document;
  }
  
  if (!event.preventDefault) {
    event.preventDefault = function() {
      event.returnValue = false;
    };
  }
  
  if (!event.stopPropagation) {
    event.stopPropagation = function() {
      event.cancelBubble = true;
    };
  }
  
  if (event.pageX == null && event.clientX != null) {
    var doc = document.documentElement;
    var body = document.body;
    event.pageX = event.clientX + 
      (doc && doc.scrollLeft || body && body.scrollLeft || 0) -
      (doc && doc.clientLeft || body && body.clientLeft || 0);
    event.pageY = event.clientY + 
      (doc && doc.scrollTop || body && body.scrollTop || 0) -
      (doc && doc.clientTop || body && body.clientTop || 0);
  }
  
  if (!event.which && event.button !== undefined) {
    // Convert IE button values to W3C values
    event.which = (event.button & 1 ? 1 : 
                   (event.button & 2 ? 3 : 
                   (event.button & 4 ? 2 : 0)));
  }
  
  return event;
}
```

### Event Propagation Control

#### Capture and Bubble Phase Handling

Modern browsers support both capture (top-down) and bubble (bottom-up) phases. The third parameter in `addEventListener()` controls phase participation:

```javascript
element.addEventListener('click', handler, true);  // capture phase
element.addEventListener('click', handler, false); // bubble phase
```

IE's `attachEvent` only supports bubbling. To simulate capture behavior in cross-browser code, handlers must be attached to parent elements and filter events based on `target` inspection.

#### Stopping Propagation

```javascript
function stopPropagation(event) {
  if (event.stopPropagation) {
    event.stopPropagation();
  } else {
    event.cancelBubble = true;
  }
}

function stopImmediatePropagation(event) {
  if (event.stopImmediatePropagation) {
    event.stopImmediatePropagation();
  } else {
    event.cancelBubble = true;
    // [Inference: IE doesn't have true immediate propagation stop]
    event.isImmediatePropagationStopped = true;
  }
}
```

`stopImmediatePropagation()` prevents other handlers on the same element from executing, while `stopPropagation()` only prevents propagation to ancestors.

#### Preventing Default Actions

```javascript
function preventDefault(event) {
  if (event.preventDefault) {
    event.preventDefault();
  } else {
    event.returnValue = false;
  }
}
```

Return values also affect default behavior: returning `false` from a DOM Level 0 handler prevents default action, but this doesn't work reliably with `addEventListener`. Explicit `preventDefault()` calls are preferred.

### Event Delegation Strategies

#### Target Element Resolution

Event delegation attaches handlers to ancestor elements and uses the event target to determine which descendant triggered the event:

```javascript
document.getElementById('list').addEventListener('click', function(event) {
  event = normalizeEvent(event);
  var target = event.target;
  
  // Walk up to find actual clickable element
  while (target && target !== this) {
    if (target.nodeName === 'LI') {
      handleListItemClick(target);
      break;
    }
    target = target.parentNode;
  }
});
```

#### Text Node Handling

In some browsers, clicking on text returns the text node as `event.target` rather than the element. The `nodeType` check handles this:

```javascript
var target = event.target;
if (target.nodeType === 3) { // TEXT_NODE
  target = target.parentNode;
}
```

#### Selector Matching for Delegation

Modern delegation libraries match targets against CSS selectors:

```javascript
function matches(element, selector) {
  var matches = element.matches ||
                element.matchesSelector ||
                element.msMatchesSelector ||
                element.mozMatchesSelector ||
                element.webkitMatchesSelector ||
                element.oMatchesSelector;
  
  if (matches) {
    return matches.call(element, selector);
  }
  
  // Fallback [Inference: uses querySelectorAll for matching]
  var parent = element.parentNode;
  var nodes = parent.querySelectorAll(selector);
  for (var i = 0; i < nodes.length; i++) {
    if (nodes[i] === element) return true;
  }
  return false;
}
```

### Mouse Event Peculiarities

#### Button Value Translation

Mouse button values differ significantly across browsers:

|Button|W3C Standard|IE 8-|Middle Button Complications|
|---|---|---|---|
|Left|0|1|Safari 2 reported as 1|
|Middle|1|4|Not supported in IE <9|
|Right|2|2|Context menu interference|

Complete normalization:

```javascript
function getButton(event) {
  if (event.which != null) {
    return event.which;
  }
  
  // IE button bitmask
  var button = event.button;
  if (button !== undefined) {
    return (button & 1 ? 1 : (button & 2 ? 3 : (button & 4 ? 2 : 0)));
  }
  
  return 0;
}
```

#### Mouse Position Coordinates

Different coordinate systems exist:

- `clientX/Y`: relative to viewport
- `pageX/Y`: relative to document (including scroll)
- `screenX/Y`: relative to screen
- `offsetX/Y`: relative to target element (non-standard)

`pageX/Y` requires calculation in older IE:

```javascript
function getPageCoordinates(event) {
  if (event.pageX != null) {
    return { x: event.pageX, y: event.pageY };
  }
  
  var doc = document.documentElement;
  var body = document.body;
  
  return {
    x: event.clientX + (doc.scrollLeft || body.scrollLeft || 0) - 
       (doc.clientLeft || body.clientLeft || 0),
    y: event.clientY + (doc.scrollTop || body.scrollTop || 0) - 
       (doc.clientTop || body.clientTop || 0)
  };
}
```

#### MouseEnter/MouseLeave vs MouseOver/MouseOut

`mouseenter` and `mouseleave` don't bubble, while `mouseover` and `mouseout` do. This affects delegation strategies:

```javascript
// mouseover bubbles, so checking relatedTarget is necessary
element.addEventListener('mouseover', function(event) {
  var target = event.target;
  var relatedTarget = event.relatedTarget;
  
  // Only trigger if coming from outside this element
  if (!relatedTarget || !target.contains(relatedTarget)) {
    handleEnter(target);
  }
});
```

Some older browsers don't support `mouseenter/mouseleave`, requiring `mouseover/mouseout` with `relatedTarget` checks for cross-browser compatibility.

### Keyboard Event Handling

#### Key Code Standardization

Key identification differs between `keydown/keyup` and `keypress` events:

- `keydown/keyup`: `event.keyCode` represents physical key
- `keypress`: `event.keyCode` or `event.which` represents character code

```javascript
function getCharCode(event) {
  if (event.which != null) {
    return event.which;
  }
  return event.keyCode;
}

function getKeyCode(event) {
  return event.keyCode || event.which;
}
```

Character extraction from keypress:

```javascript
function getChar(event) {
  var code = getCharCode(event);
  if (code < 32) return null; // Control character
  return String.fromCharCode(code);
}
```

#### Modifier Key Detection

Modifier keys (`Ctrl`, `Alt`, `Shift`, `Meta`) use boolean properties:

```javascript
function getModifiers(event) {
  return {
    ctrl: event.ctrlKey,
    alt: event.altKey,
    shift: event.shiftKey,
    meta: event.metaKey // Command on Mac, Windows key on PC
  };
}
```

Cross-platform Ctrl/Command handling:

```javascript
function isPlatformCtrlKey(event) {
  // Mac uses Cmd, others use Ctrl
  var isMac = /Mac|iPod|iPhone|iPad/.test(navigator.platform);
  return isMac ? event.metaKey : event.ctrlKey;
}
```

#### KeyboardEvent.key vs keyCode

Modern browsers support `event.key` which provides readable key names ('Enter', 'ArrowUp', 'a') instead of numeric codes. Fallback required:

```javascript
function getKeyIdentifier(event) {
  // Modern standard
  if (event.key) {
    return event.key;
  }
  
  // Older WebKit
  if (event.keyIdentifier) {
    return event.keyIdentifier;
  }
  
  // Fallback to keyCode [Inference: requires manual mapping]
  var keyMap = {
    13: 'Enter',
    27: 'Escape',
    37: 'ArrowLeft',
    38: 'ArrowUp',
    39: 'ArrowRight',
    40: 'ArrowDown'
    // ... extensive mapping required
  };
  
  return keyMap[event.keyCode] || String.fromCharCode(event.keyCode);
}
```

### Touch and Pointer Events

#### Touch Event Normalization

Touch events (`touchstart`, `touchmove`, `touchend`) aren't supported in desktop browsers and older mobile browsers. Mouse events serve as fallback:

```javascript
var touchEvents = {
  start: 'touchstart',
  move: 'touchmove',
  end: 'touchend'
};

var mouseEvents = {
  start: 'mousedown',
  move: 'mousemove',
  end: 'mouseup'
};

var isTouch = 'ontouchstart' in window;
var events = isTouch ? touchEvents : mouseEvents;

element.addEventListener(events.start, handleStart);
```

Touch coordinates come from `touches`, `targetTouches`, or `changedTouches` arrays:

```javascript
function getEventCoordinates(event) {
  if (event.touches && event.touches.length) {
    return {
      x: event.touches[0].pageX,
      y: event.touches[0].pageY
    };
  }
  
  if (event.changedTouches && event.changedTouches.length) {
    return {
      x: event.changedTouches[0].pageX,
      y: event.changedTouches[0].pageY
    };
  }
  
  return getPageCoordinates(event); // Mouse event fallback
}
```

#### Pointer Events Unification

Pointer Events API unifies mouse, touch, and pen input:

```javascript
function supportsPointerEvents() {
  return window.PointerEvent !== undefined;
}

function addUnifiedPointerHandler(element, handler) {
  if (supportsPointerEvents()) {
    element.addEventListener('pointerdown', handler);
  } else if (window.TouchEvent) {
    element.addEventListener('touchstart', handler);
  } else {
    element.addEventListener('mousedown', handler);
  }
}
```

Pointer event properties include `pointerType` ('mouse', 'touch', 'pen') and pressure sensitivity.

#### Touch Action and Scroll Prevention

Preventing default touch behavior:

```javascript
element.addEventListener('touchstart', function(event) {
  event.preventDefault(); // Prevents scrolling, zooming
  handleTouch(event);
}, { passive: false }); // passive: false required for preventDefault
```

CSS `touch-action` property provides declarative control:

```css
.draggable {
  touch-action: none; /* Disable browser handling */
}
```

Passive event listeners improve scroll performance but disable `preventDefault()`:

```javascript
element.addEventListener('touchmove', handler, { passive: true });
// event.preventDefault() will be ignored
```

### Form Event Differences

#### Input, Change, and Property Change

`input` event fires on each value change (typing, pasting), while `change` fires on blur or commit. IE 8 doesn't support `input`:

```javascript
function addInputHandler(element, handler) {
  if ('oninput' in element) {
    element.addEventListener('input', handler);
  } else {
    // IE 8 fallback
    element.attachEvent('onpropertychange', function(event) {
      if (event.propertyName === 'value') {
        handler.call(element, event);
      }
    });
  }
}
```

#### Submit Event and Form Validation

Submit event handling varies in when validation occurs:

```javascript
form.addEventListener('submit', function(event) {
  event = normalizeEvent(event);
  
  if (!validateForm(this)) {
    event.preventDefault();
    return false; // Additional safety for older browsers
  }
});
```

`checkValidity()` and HTML5 validation aren't universally supported:

```javascript
function isValidForm(form) {
  if (form.checkValidity) {
    return form.checkValidity();
  }
  
  // Manual validation fallback [Inference: requires custom validation logic]
  return customValidation(form);
}
```

### Focus and Blur Events

#### Focus Event Bubbling

`focus` and `blur` don't bubble in most browsers, but `focusin` and `focusout` do:

```javascript
function addFocusHandler(element, handler, useCapture) {
  if (element.addEventListener) {
    if (useCapture) {
      // Use capture phase for delegation with focus/blur
      element.addEventListener('focus', handler, true);
    } else if ('onfocusin' in element) {
      // IE and modern browsers support focusin (bubbles)
      element.addEventListener('focusin', handler, false);
    } else {
      element.addEventListener('focus', handler, false);
    }
  }
}
```

#### Active Element Tracking

`document.activeElement` provides currently focused element, but IE 8 has quirks:

```javascript
function getActiveElement() {
  try {
    return document.activeElement;
  } catch (e) {
    // IE can throw if activeElement is removed from DOM
    return document.body;
  }
}
```

### Custom Events

#### Creating and Dispatching

Modern browsers use `CustomEvent` constructor:

```javascript
var event = new CustomEvent('myevent', {
  detail: { data: 'payload' },
  bubbles: true,
  cancelable: true
});

element.dispatchEvent(event);
```

IE 9-11 requires `createEvent`:

```javascript
function createCustomEvent(type, detail, bubbles, cancelable) {
  var event;
  
  if (typeof CustomEvent === 'function') {
    event = new CustomEvent(type, {
      detail: detail,
      bubbles: bubbles,
      cancelable: cancelable
    });
  } else {
    event = document.createEvent('CustomEvent');
    event.initCustomEvent(type, bubbles, cancelable, detail);
  }
  
  return event;
}

function dispatchEvent(element, event) {
  if (element.dispatchEvent) {
    element.dispatchEvent(event);
  } else if (element.fireEvent) {
    element.fireEvent('on' + event.type, event);
  }
}
```

#### Event Data Transfer

Custom data passes through `detail` property:

```javascript
element.addEventListener('myevent', function(event) {
  var data = event.detail;
  console.log(data.message);
});

var evt = createCustomEvent('myevent', { message: 'Hello' }, true, true);
dispatchEvent(element, evt);
```

### Memory Leak Prevention

#### Circular Reference Cleanup

IE 8 and earlier had memory leaks when DOM elements and JavaScript objects held circular references through event handlers:

```javascript
function leakyAttach(element) {
  // BAD: Creates circular reference in old IE
  element.onclick = function() {
    doSomething(element); // Handler references element
  };
}
```

Solutions include removing handlers before page unload:

```javascript
window.addEventListener('unload', function() {
  // Remove all event handlers
  var elements = document.getElementsByTagName('*');
  for (var i = 0; i < elements.length; i++) {
    var element = elements[i];
    for (var prop in element) {
      if (prop.indexOf('on') === 0 && typeof element[prop] === 'function') {
        element[prop] = null;
      }
    }
  }
});
```

Modern browsers with garbage collection improvements don't require this, but libraries still implement cleanup for broad compatibility.

#### Handler Reference Management

WeakMaps store handler references without preventing garbage collection:

```javascript
var handlerRegistry = new WeakMap();

function addEventWithCleanup(element, type, handler) {
  var cleanupHandler = function(event) {
    handler.call(element, normalizeEvent(event));
  };
  
  if (!handlerRegistry.has(element)) {
    handlerRegistry.set(element, {});
  }
  
  var handlers = handlerRegistry.get(element);
  handlers[type] = handlers[type] || [];
  handlers[type].push({ original: handler, wrapped: cleanupHandler });
  
  addEvent(element, type, cleanupHandler);
}
```

### Feature Detection Patterns

#### Capability Testing

Test for feature existence rather than browser detection:

```javascript
var eventSupport = {
  addEventListener: !!window.addEventListener,
  attachEvent: !!window.attachEvent,
  customEvent: typeof CustomEvent === 'function',
  pointerEvents: window.PointerEvent !== undefined,
  touchEvents: 'ontouchstart' in window,
  inputEvent: 'oninput' in document.createElement('input'),
  focusinEvent: 'onfocusin' in window,
  passiveEvents: (function() {
    var passive = false;
    try {
      var opts = Object.defineProperty({}, 'passive', {
        get: function() { passive = true; }
      });
      window.addEventListener('test', null, opts);
    } catch (e) {}
    return passive;
  })()
};
```

#### Event Support Testing

Test if specific events are supported:

```javascript
function isEventSupported(eventName, element) {
  element = element || document.createElement('div');
  var eventAttribute = 'on' + eventName;
  var isSupported = (eventAttribute in element);
  
  if (!isSupported) {
    element.setAttribute(eventAttribute, 'return;');
    isSupported = typeof element[eventAttribute] === 'function';
  }
  
  return isSupported;
}
```

### Event Performance Optimization

#### Throttling and Debouncing

High-frequency events (scroll, resize, mousemove) benefit from rate limiting:

```javascript
function throttle(func, limit) {
  var inThrottle;
  return function() {
    var args = arguments;
    var context = this;
    if (!inThrottle) {
      func.apply(context, args);
      inThrottle = true;
      setTimeout(function() { inThrottle = false; }, limit);
    }
  };
}

function debounce(func, wait) {
  var timeout;
  return function() {
    var context = this;
    var args = arguments;
    clearTimeout(timeout);
    timeout = setTimeout(function() {
      func.apply(context, args);
    }, wait);
  };
}

window.addEventListener('scroll', throttle(function(event) {
  // Executes at most once per 100ms
}, 100));

window.addEventListener('resize', debounce(function(event) {
  // Executes once after resize stops for 250ms
}, 250));
```

#### Passive Event Listeners

Passive listeners improve scroll performance by declaring handlers won't call `preventDefault()`:

```javascript
function addPassiveEventListener(element, type, handler) {
  if (eventSupport.passiveEvents) {
    element.addEventListener(type, handler, { passive: true });
  } else {
    element.addEventListener(type, handler, false);
  }
}

addPassiveEventListener(window, 'scroll', handleScroll);
```

#### Event Delegation Performance

Delegating to fewer ancestors reduces handler count:

```javascript
// INEFFICIENT: 1000 handlers
var items = document.querySelectorAll('.item');
for (var i = 0; i < items.length; i++) {
  items[i].addEventListener('click', handleClick);
}

// EFFICIENT: 1 handler
document.getElementById('container').addEventListener('click', function(event) {
  var target = event.target;
  while (target && target !== this) {
    if (target.classList.contains('item')) {
      handleClick.call(target, event);
      break;
    }
    target = target.parentNode;
  }
});
```

### Browser-Specific Workarounds

#### Safari's Click Event Peculiarities

Safari doesn't fire click events on non-interactive elements by default:

```css
/* Make divs clickable in Safari */
.clickable {
  cursor: pointer;
}
```

Or use JavaScript:

```javascript
function makeClickable(element) {
  if (/Safari/.test(navigator.userAgent) && 
      !/Chrome/.test(navigator.userAgent)) {
    element.style.cursor = 'pointer';
  }
}
```

#### Firefox's MouseEvent.which Inconsistency

[Inference: Some Firefox versions had inconsistent `which` values for mouse buttons in certain contexts]

```javascript
function getMouseButton(event) {
  // Normalize across all browsers
  if (event.which != null) {
    return event.which;
  }
  if (event.button != null) {
    // IE button to standard conversion
    var button = event.button;
    return button & 1 ? 1 : (button & 2 ? 3 : (button & 4 ? 2 : 0));
  }
  return 0;
}
```

#### Mobile Safari's Touch Delay

300ms tap delay on mobile Safari for double-tap zoom detection:

```javascript
function removeTapDelay() {
  if ('ontouchstart' in window) {
    // Modern approach: touch-action CSS
    document.documentElement.style.touchAction = 'manipulation';
    
    // Fallback: FastClick pattern
    var lastTouchTime = 0;
    document.addEventListener('touchstart', function(event) {
      var now = Date.now();
      if (now - lastTouchTime < 500) {
        event.preventDefault();
      }
      lastTouchTime = now;
    }, true);
  }
}
```

### Event Polyfills and Shims

#### Polyfilling addEventListener

Complete cross-browser event system:

```javascript
(function() {
  if (!window.addEventListener) {
    (function() {
      window.addEventListener = function(type, listener) {
        window.attachEvent('on' + type, function() {
          listener.call(window, window.event);
        });
      };
      
      Element.prototype.addEventListener = function(type, listener) {
        var self = this;
        this.attachEvent('on' + type, function(event) {
          listener.call(self, event);
        });
      };
    })();
  }
  
  if (!Event.prototype.preventDefault) {
    Event.prototype.preventDefault = function() {
      this.returnValue = false;
    };
  }
  
  if (!Event.prototype.stopPropagation) {
    Event.prototype.stopPropagation = function() {
      this.cancelBubble = true;
    };
  }
})();
```

#### CustomEvent Polyfill

```javascript
(function() {
  if (typeof window.CustomEvent === 'function') return;
  
  function CustomEvent(event, params) {
    params = params || { bubbles: false, cancelable: false, detail: null };
    var evt = document.createEvent('CustomEvent');
    evt.initCustomEvent(event, params.bubbles, params.cancelable, params.detail);
    return evt;
  }
  
  CustomEvent.prototype = window.Event.prototype;
  window.CustomEvent = CustomEvent;
})();
```

### Testing Event Handlers

#### Triggering Synthetic Events

Programmatically fire events for testing:

```javascript
function triggerEvent(element, eventType, options) {
  options = options || {};
  var event;
  
  if (document.createEvent) {
    if (eventType.indexOf('mouse') !== -1) {
      event = document.createEvent('MouseEvents');
      event.initMouseEvent(
        eventType,
        options.bubbles !== false,
        options.cancelable !== false,
        window,
        options.detail || 1,
        options.screenX || 0,
        options.screenY || 0,
        options.clientX || 0,
        options.clientY || 0,
        options.ctrlKey || false,
        options.altKey || false,
        options.shiftKey || false,
        options.metaKey || false,
        options.button || 0,
        options.relatedTarget || null
      );
    } else if (eventType.indexOf('key') !== -1) {
      event = document.createEvent('KeyboardEvent');
      var initMethod = event.initKeyboardEvent ? 'initKeyboardEvent' : 'initKeyEvent';
      event[initMethod](
        eventType,
        options.bubbles !== false,
        options.cancelable !== false,
        window,
        options.ctrlKey || false,
        options.altKey || false,
        options.shiftKey || false,
        options.metaKey || false,
        options.keyCode || 0,
        options.charCode || 0
      );
    } else {
      event = document.createEvent('HTMLEvents');
      event.initEvent(eventType, options.bubbles !== false, options.cancelable !== false);
    }
    
    element.dispatchEvent(event);
  } else if (document.createEventObject) {
    // IE 8
    event = document.createEventObject();
    for (var prop in options) {
      event[prop] = options[prop];
    }
    element.fireEvent('on' + eventType, event);
  }
}
```

#### Mocking Event Objects

Create mock event objects for unit testing:

```javascript
function createMockEvent(type, properties) {
  var event = {
    type: type,
    target: null,
    currentTarget: null,
    bubbles: true,
    cancelable: true,
    defaultPrevented: false,
    preventDefault: function() {
      this.defaultPrevented = true;
    },
    stopPropagation: function() {
      this.propagationStopped = true;
    },
    stopImmediatePropagation: function() {
      this.immediatePropagationStopped = true;
    }
  };
  
  for (var prop in properties) {
    event[prop] = properties[prop];
  }
  
  return event;
}
```

---

