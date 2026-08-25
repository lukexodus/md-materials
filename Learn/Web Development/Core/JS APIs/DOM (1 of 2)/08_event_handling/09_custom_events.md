## Custom Events


### CustomEvent Constructor

The `CustomEvent` interface creates custom events that can carry arbitrary data and be dispatched through the DOM event system. It extends the base `Event` interface with the ability to attach custom data via the `detail` property.

**Syntax:**

```javascript
new CustomEvent(typeArg, options)
```

**Parameters:**

`typeArg` (string, required): The name of the event. This is case-sensitive and serves as the event identifier that listeners will register for.

`options` (object, optional): An object with the following properties:

- `detail`: Any value to be passed as custom data with the event (default: `null`)
- `bubbles`: Boolean indicating whether the event bubbles up through the DOM (default: `false`)
- `cancelable`: Boolean indicating whether the event can be canceled (default: `false`)
- `composed`: Boolean indicating whether the event will trigger listeners outside of a shadow DOM (default: `false`)

### Creating Custom Events

```javascript
// Simple custom event
const simpleEvent = new CustomEvent('userLogin');

// Custom event with data
const dataEvent = new CustomEvent('userLogin', {
  detail: {
    username: 'alice',
    timestamp: Date.now(),
    sessionId: 'abc123'
  }
});

// Custom event with full options
const complexEvent = new CustomEvent('dataUpdate', {
  detail: { items: [1, 2, 3], total: 3 },
  bubbles: true,
  cancelable: true,
  composed: true
});
```

### The detail Property

The `detail` property is the primary mechanism for passing custom data with events. It can contain any JavaScript value: primitives, objects, arrays, functions, or any other data type.

```javascript
// Various detail types
const numberEvent = new CustomEvent('score', { detail: 42 });
const arrayEvent = new CustomEvent('items', { detail: [1, 2, 3] });
const objectEvent = new CustomEvent('user', { 
  detail: { name: 'Bob', age: 30 } 
});
const functionEvent = new CustomEvent('callback', { 
  detail: () => console.log('Called') 
});
```

Accessing the detail property in event listeners:

```javascript
element.addEventListener('customEvent', (event) => {
  console.log(event.detail); // Access custom data
  console.log(event.detail.username); // Access nested properties
});
```

### dispatchEvent Method

The `dispatchEvent()` method fires an event on a specified event target, triggering any registered listeners for that event type. It returns `false` if the event is cancelable and any listener called `preventDefault()`, otherwise returns `true`.

**Syntax:**

```javascript
target.dispatchEvent(event)
```

**Parameters:**

`event`: An `Event` or `CustomEvent` object to be dispatched.

**Return value:**

`false` if the event is cancelable and at least one event handler called `event.preventDefault()`, otherwise `true`.

### Dispatching Custom Events

```javascript
const element = document.getElementById('myElement');

// Create and dispatch in separate steps
const event = new CustomEvent('myEvent', { detail: { data: 'value' } });
element.dispatchEvent(event);

// Create and dispatch inline
element.dispatchEvent(new CustomEvent('myEvent', {
  detail: { data: 'value' },
  bubbles: true
}));
```

### Event Bubbling and Propagation

**Bubbling:** When `bubbles: true`, the event propagates up through the DOM tree from the target element to its ancestors.

```javascript
const childElement = document.getElementById('child');
const parentElement = document.getElementById('parent');

// Listener on parent
parentElement.addEventListener('customEvent', (event) => {
  console.log('Caught at parent:', event.target.id);
});

// Dispatch from child with bubbling
childElement.dispatchEvent(new CustomEvent('customEvent', {
  detail: { message: 'bubbles up' },
  bubbles: true
}));
// Output: "Caught at parent: child"
```

**Capture phase:** Event listeners can be registered for the capture phase using the `capture` option:

```javascript
parentElement.addEventListener('customEvent', (event) => {
  console.log('Capture phase');
}, { capture: true });

childElement.addEventListener('customEvent', (event) => {
  console.log('Target phase');
});

parentElement.addEventListener('customEvent', (event) => {
  console.log('Bubble phase');
});
```

### Stopping Propagation

**stopPropagation():** Prevents the event from continuing to propagate through the DOM tree but allows other listeners on the current target to execute.

**stopImmediatePropagation():** Prevents the event from reaching other listeners on the current target and all subsequent targets.

```javascript
element.addEventListener('customEvent', (event) => {
  event.stopPropagation(); // Event won't bubble to parent
  console.log('First listener');
});

element.addEventListener('customEvent', (event) => {
  console.log('Second listener'); // This still executes
});

// With stopImmediatePropagation
element.addEventListener('customEvent', (event) => {
  event.stopImmediatePropagation();
  console.log('First listener');
});

element.addEventListener('customEvent', (event) => {
  console.log('Second listener'); // This won't execute
});
```

### Cancelable Events

When `cancelable: true`, event handlers can call `preventDefault()` to signal that the default action should not be performed. The dispatcher can check the return value of `dispatchEvent()` or examine the `defaultPrevented` property.

```javascript
const event = new CustomEvent('beforeSave', {
  detail: { data: 'important' },
  cancelable: true
});

element.addEventListener('beforeSave', (event) => {
  if (event.detail.data === 'invalid') {
    event.preventDefault(); // Cancel the action
  }
});

const shouldProceed = element.dispatchEvent(event);

if (shouldProceed) {
  console.log('Event not prevented, proceed with save');
} else {
  console.log('Event was prevented, cancel save');
}

// Alternative check
if (event.defaultPrevented) {
  console.log('Action was canceled');
}
```

### Composed Events and Shadow DOM

The `composed` property controls whether events can cross shadow DOM boundaries. When `composed: true`, the event can propagate through shadow DOM boundaries into the regular DOM.

```javascript
class MyComponent extends HTMLElement {
  constructor() {
    super();
    this.attachShadow({ mode: 'open' });
    
    const button = document.createElement('button');
    button.textContent = 'Click me';
    
    button.addEventListener('click', () => {
      // Event that crosses shadow boundary
      this.dispatchEvent(new CustomEvent('componentAction', {
        detail: { action: 'clicked' },
        bubbles: true,
        composed: true // Allows event to escape shadow DOM
      }));
    });
    
    this.shadowRoot.appendChild(button);
  }
}

customElements.define('my-component', MyComponent);

// Listener outside shadow DOM
document.addEventListener('componentAction', (event) => {
  console.log('Caught outside shadow DOM:', event.detail);
});
```

### Event Target and currentTarget

**event.target:** The element that originally dispatched the event (remains constant during propagation).

**event.currentTarget:** The element whose listener is currently processing the event (changes during propagation).

```javascript
parentElement.addEventListener('customEvent', (event) => {
  console.log('Target:', event.target.id); // 'child'
  console.log('Current target:', event.currentTarget.id); // 'parent'
});

childElement.dispatchEvent(new CustomEvent('customEvent', {
  bubbles: true
}));
```

### Synchronous vs Asynchronous Dispatch

`dispatchEvent()` is synchronous by default. All event listeners execute immediately before `dispatchEvent()` returns.

```javascript
console.log('Before dispatch');

element.addEventListener('customEvent', () => {
  console.log('During dispatch');
});

element.dispatchEvent(new CustomEvent('customEvent'));

console.log('After dispatch');

// Output:
// "Before dispatch"
// "During dispatch"
// "After dispatch"
```

To dispatch asynchronously:

```javascript
setTimeout(() => {
  element.dispatchEvent(new CustomEvent('customEvent'));
}, 0);

// Or with promises
Promise.resolve().then(() => {
  element.dispatchEvent(new CustomEvent('customEvent'));
});

// Or with queueMicrotask
queueMicrotask(() => {
  element.dispatchEvent(new CustomEvent('customEvent'));
});
```

### Common Use Cases

**Component communication:** Custom events enable decoupled communication between components without direct dependencies.

```javascript
// Publisher component
class DataProvider extends HTMLElement {
  updateData(newData) {
    this.dispatchEvent(new CustomEvent('dataChanged', {
      detail: { data: newData },
      bubbles: true
    }));
  }
}

// Subscriber component
document.addEventListener('dataChanged', (event) => {
  console.log('New data:', event.detail.data);
});
```

**State management:** Custom events can propagate state changes throughout an application.

```javascript
class StateManager {
  constructor() {
    this.state = {};
    this.target = document.createElement('div');
  }
  
  setState(newState) {
    this.state = { ...this.state, ...newState };
    this.target.dispatchEvent(new CustomEvent('stateChange', {
      detail: { state: this.state }
    }));
  }
  
  subscribe(callback) {
    this.target.addEventListener('stateChange', callback);
  }
}
```

**Form validation:** Custom events can coordinate complex validation workflows.

```javascript
formElement.addEventListener('beforeSubmit', (event) => {
  if (!validateForm()) {
    event.preventDefault();
    event.target.dispatchEvent(new CustomEvent('validationFailed', {
      detail: { errors: getValidationErrors() }
    }));
  }
});
```

**Analytics and tracking:** Custom events can trigger analytics without coupling business logic to tracking code.

```javascript
button.addEventListener('click', () => {
  // Business logic
  performAction();
  
  // Trigger tracking event
  document.dispatchEvent(new CustomEvent('analytics:action', {
    detail: {
      category: 'button',
      action: 'click',
      label: button.id
    }
  }));
});
```

### Event Constructor vs CustomEvent

The base `Event` constructor can also create events but lacks the `detail` property:

```javascript
// Using Event (no detail property)
const basicEvent = new Event('myEvent', {
  bubbles: true,
  cancelable: true
});

// Using CustomEvent (with detail)
const customEvent = new CustomEvent('myEvent', {
  detail: { data: 'value' },
  bubbles: true,
  cancelable: true
});
```

For events requiring custom data, `CustomEvent` is preferred. For simple notifications without data, either constructor is acceptable.

### Timing and Event Loop

Custom events dispatched synchronously execute within the current call stack. This affects timing-sensitive operations:

```javascript
let counter = 0;

element.addEventListener('increment', () => {
  counter++;
  console.log('Listener:', counter);
});

element.dispatchEvent(new CustomEvent('increment'));
console.log('After dispatch:', counter);

// Output:
// "Listener: 1"
// "After dispatch: 1"
```

### Memory Considerations

Event listeners attached to elements can create memory leaks if not properly removed, especially in long-lived applications:

```javascript
// Adding a listener
const handler = (event) => {
  console.log(event.detail);
};

element.addEventListener('customEvent', handler);

// Removing when done
element.removeEventListener('customEvent', handler);

// Using AbortController for cleanup
const controller = new AbortController();

element.addEventListener('customEvent', handler, {
  signal: controller.signal
});

// Later: remove all listeners added with this signal
controller.abort();
```

### Event Retargeting

When events cross shadow DOM boundaries, the `target` property is retargeted to prevent leaking implementation details:

```javascript
class MyElement extends HTMLElement {
  constructor() {
    super();
    const shadow = this.attachShadow({ mode: 'open' });
    const button = document.createElement('button');
    shadow.appendChild(button);
    
    button.addEventListener('click', (e) => {
      console.log('Inside shadow:', e.target); // <button>
    });
  }
}

document.addEventListener('click', (e) => {
  // If composed: true was set, target is retargeted
  console.log('Outside shadow:', e.target); // <my-element>
});
```

### Best Practices

**Event naming:** Use namespaced names to avoid collisions (e.g., `app:userLogin` instead of `login`).

**Detail structure:** Keep detail objects consistent and well-documented for each event type.

**Bubbling strategy:** Enable bubbling (`bubbles: true`) for events that represent actions or state changes that parent elements might need to handle.

**Cancelability:** Make events cancelable (`cancelable: true`) only when there's a meaningful default action that can be prevented.

**Composed events:** Set `composed: true` only when events should intentionally cross shadow DOM boundaries.

**Documentation:** Document custom events as part of component APIs, including event names, detail structures, and bubbling behavior.

### Performance Considerations

Dispatching events and executing listeners is generally fast, but excessive event dispatching in tight loops can impact performance:

```javascript
// Potentially problematic
for (let i = 0; i < 10000; i++) {
  element.dispatchEvent(new CustomEvent('update', {
    detail: { index: i }
  }));
}

// Better: batch updates
const updates = [];
for (let i = 0; i < 10000; i++) {
  updates.push(i);
}
element.dispatchEvent(new CustomEvent('batchUpdate', {
  detail: { updates }
}));
```

### Browser Compatibility

`CustomEvent` and `dispatchEvent` are supported in all modern browsers including Chrome, Firefox, Safari, Edge, and Internet Explorer 9+. The `composed` option requires support for shadow DOM (not available in IE).

### Debugging Custom Events

Browser developer tools can monitor custom events:

```javascript
// Log all events on an element
const originalDispatch = element.dispatchEvent.bind(element);
element.dispatchEvent = function(event) {
  console.log('Dispatching:', event.type, event.detail);
  return originalDispatch(event);
};

// Monitor using monitorEvents (Chrome DevTools)
// monitorEvents(element, 'customEvent');
```

---

