## Custom Elements (Web Components)


### Defining Custom Elements

Custom elements are defined using `window.customElements.define()`, which registers a new element with the browser. The element name must contain a hyphen to distinguish it from standard HTML elements and avoid naming conflicts.

```javascript
class MyElement extends HTMLElement {
  constructor() {
    super();
    // Initialization logic
  }
}

customElements.define('my-element', MyElement);
```

The class must extend `HTMLElement` or a subclass of it (like `HTMLButtonElement` for customized built-in elements). The constructor must call `super()` first before accessing `this`.

### Lifecycle Callbacks

Custom elements provide four lifecycle callbacks that hook into different stages of the element's existence:

**connectedCallback()** - Invoked when the element is inserted into the DOM. This is where you typically set up event listeners, fetch data, or start timers. Called each time the element is moved or reinserted.

**disconnectedCallback()** - Invoked when the element is removed from the DOM. Use this for cleanup: removing event listeners, canceling timers, or releasing resources. Not called when the page unloads.

**adoptedCallback()** - Invoked when the element is moved to a new document via `document.adoptNode()`. Rarely used outside of advanced scenarios involving iframes or document fragments.

**attributeChangedCallback(name, oldValue, newValue)** - Invoked when an observed attribute changes. Only attributes listed in the static `observedAttributes` getter trigger this callback.

```javascript
class ObservableElement extends HTMLElement {
  static get observedAttributes() {
    return ['data-value', 'disabled'];
  }

  attributeChangedCallback(name, oldValue, newValue) {
    if (name === 'data-value') {
      this.updateDisplay(newValue);
    }
  }
}
```

### Autonomous vs Customized Built-in Elements

**Autonomous custom elements** inherit from `HTMLElement` and are used as standalone tags. They define entirely new elements with custom behavior.

```javascript
class FancyButton extends HTMLElement {
  connectedCallback() {
    this.innerHTML = '<button>Click me</button>';
  }
}
customElements.define('fancy-button', FancyButton);
// Usage: <fancy-button></fancy-button>
```

**Customized built-in elements** extend existing HTML elements, inheriting their semantics and accessibility features. They require the `is` attribute for usage.

```javascript
class FancyButton extends HTMLButtonElement {
  connectedCallback() {
    this.classList.add('fancy');
  }
}
customElements.define('fancy-button', FancyButton, { extends: 'button' });
// Usage: <button is="fancy-button">Click me</button>
```

[Inference] Customized built-in elements maintain better accessibility and form participation because they inherit native element behavior, though browser support (particularly Safari) has been inconsistent historically.

### Shadow DOM Integration

Custom elements commonly use Shadow DOM to encapsulate styles and markup. The shadow root is typically attached in the constructor:

```javascript
class ShadowElement extends HTMLElement {
  constructor() {
    super();
    this.attachShadow({ mode: 'open' });
    this.shadowRoot.innerHTML = `
      <style>
        :host {
          display: block;
          padding: 1rem;
        }
      </style>
      <slot></slot>
    `;
  }
}
```

The `mode` can be `'open'` (accessible via `element.shadowRoot`) or `'closed'` (not accessible externally, though this provides limited security). The `delegatesFocus` option can be set to `true` to automatically focus the first focusable element when the host receives focus.

### Element Upgrade Process

Elements can be used in markup before their definition is registered. These elements exist in an "undefined" state until `customElements.define()` is called, at which point they're upgraded.

```javascript
// HTML parsed first
// <my-element>Content</my-element>

// Later, definition registered
customElements.define('my-element', MyElement);
// Element is now upgraded, constructor and connectedCallback run
```

You can wait for element definitions using `customElements.whenDefined()`:

```javascript
await customElements.whenDefined('my-element');
// Now safe to interact with the element's custom API
```

The upgrade process runs synchronously when `define()` is called, potentially causing performance issues if many elements need upgrading simultaneously.

### Constructor Restrictions

The constructor has specific restrictions to ensure elements can be created in various contexts:

- Must call `super()` before accessing `this`
- Cannot return a different object (except `this`)
- Cannot use `document.write()` or `document.open()`
- Cannot inspect parent or sibling elements (not yet in DOM tree)
- Cannot add attributes or children (should be done in `connectedCallback`)

```javascript
// Valid constructor
constructor() {
  super();
  this._data = [];
  this._setupInternalState();
}

// Invalid - adds attributes
constructor() {
  super();
  this.setAttribute('initialized', ''); // Don't do this
}
```

### Extending Custom Elements

Custom elements can be extended to create element hierarchies:

```javascript
class BaseElement extends HTMLElement {
  connectedCallback() {
    this.classList.add('base');
  }
}

class ExtendedElement extends BaseElement {
  connectedCallback() {
    super.connectedCallback(); // Call parent behavior
    this.classList.add('extended');
  }
}

customElements.define('base-element', BaseElement);
customElements.define('extended-element', ExtendedElement);
```

The subclass must call `super.connectedCallback()` and other lifecycle methods if it wants to preserve parent behavior.

### Form Association

Custom elements can participate in forms using the `ElementInternals` API:

```javascript
class FormInput extends HTMLElement {
  static formAssociated = true;

  constructor() {
    super();
    this._internals = this.attachInternals();
  }

  connectedCallback() {
    this.addEventListener('input', (e) => {
      this._internals.setFormValue(e.target.value);
    });
  }

  // Form lifecycle callbacks
  formResetCallback() {
    this._internals.setFormValue('');
  }

  formDisabledCallback(disabled) {
    this.toggleAttribute('disabled', disabled);
  }
}
```

The `ElementInternals` interface provides:

- `setFormValue()` - sets the element's value for form submission
- `setValidity()` - sets custom validation state
- `form` - reference to the associated form
- `validity` - ValidityState object
- `willValidate` - whether element participates in validation

Form-associated custom elements also receive `formResetCallback()`, `formDisabledCallback()`, `formStateRestoreCallback()`, and `formAssociatedCallback()` lifecycle methods.

### Custom Pseudo-classes and States

Using `ElementInternals`, custom elements can expose custom states that can be styled with CSS:

```javascript
class ToggleSwitch extends HTMLElement {
  static formAssociated = true;

  constructor() {
    super();
    this._internals = this.attachInternals();
  }

  set checked(value) {
    if (value) {
      this._internals.states.add('checked');
    } else {
      this._internals.states.delete('checked');
    }
  }
}

customElements.define('toggle-switch', ToggleSwitch);
```

```css
toggle-switch:state(checked) {
  background: green;
}
```

[Unverified] The `:state()` pseudo-class has limited browser support and may require prefixes or polyfills in some environments.

### Slot Change Detection

When using Shadow DOM with slots, you can detect when slotted content changes:

```javascript
class ContainerElement extends HTMLElement {
  constructor() {
    super();
    this.attachShadow({ mode: 'open' });
    this.shadowRoot.innerHTML = `
      <slot name="header"></slot>
      <slot></slot>
    `;
    
    this.shadowRoot.querySelector('slot[name="header"]')
      .addEventListener('slotchange', (e) => {
        const nodes = e.target.assignedNodes();
        this.handleHeaderChange(nodes);
      });
  }
}
```

The `slotchange` event fires when the slot's assigned nodes change. Use `assignedNodes()` to get text nodes and elements, or `assignedElements()` to get only elements. Both accept an optional `{ flatten: true }` parameter to get nodes from nested slots.

### Reflection and Attributes

Custom elements commonly reflect JavaScript properties to HTML attributes and vice versa:

```javascript
class ReflectiveElement extends HTMLElement {
  static get observedAttributes() {
    return ['value'];
  }

  get value() {
    return this.getAttribute('value') || '';
  }

  set value(val) {
    this.setAttribute('value', val);
  }

  attributeChangedCallback(name, oldValue, newValue) {
    if (name === 'value' && oldValue !== newValue) {
      this.dispatchEvent(new CustomEvent('valuechange', {
        detail: { value: newValue }
      }));
    }
  }
}
```

For boolean attributes, follow the HTML convention:

```javascript
get disabled() {
  return this.hasAttribute('disabled');
}

set disabled(val) {
  if (val) {
    this.setAttribute('disabled', '');
  } else {
    this.removeAttribute('disabled');
  }
}
```

### Preventing Duplicate Definitions

Attempting to register the same tag name twice throws a `DOMException`. Check if an element is already defined:

```javascript
if (!customElements.get('my-element')) {
  customElements.define('my-element', MyElement);
}
```

This pattern is useful in module systems where the same definition might be imported multiple times, or when loading components conditionally.

### Memory Management and Cleanup

Proper cleanup in `disconnectedCallback` prevents memory leaks:

```javascript
class TimerElement extends HTMLElement {
  connectedCallback() {
    this._interval = setInterval(() => {
      this.textContent = new Date().toISOString();
    }, 1000);
    
    this._handleClick = () => console.log('clicked');
    document.addEventListener('click', this._handleClick);
  }

  disconnectedCallback() {
    clearInterval(this._interval);
    document.removeEventListener('click', this._handleClick);
  }
}
```

Store references to intervals, timeouts, and bound event handlers so they can be cleaned up. Be especially careful with event listeners on `window`, `document`, or parent elements, as these will keep the element alive even after removal from the DOM.

### Accessing Light DOM vs Shadow DOM

Custom elements have access to both light DOM (their children) and shadow DOM (encapsulated content):

```javascript
class DualAccessElement extends HTMLElement {
  constructor() {
    super();
    this.attachShadow({ mode: 'open' });
  }

  connectedCallback() {
    // Light DOM - direct children
    const lightChildren = Array.from(this.children);
    
    // Shadow DOM - encapsulated content
    this.shadowRoot.innerHTML = '<slot></slot>';
    const shadowContent = this.shadowRoot.querySelector('slot');
    
    // Slotted nodes - light DOM children assigned to slots
    const slotted = shadowContent.assignedElements();
  }
}
```

The shadow root creates a boundary: CSS selectors from the outside don't reach in, and selectors from inside don't reach out. The `<slot>` element projects light DOM content into the shadow tree.

### Custom Element Naming Conventions

Valid custom element names must:

- Contain at least one hyphen (-)
- Start with a lowercase ASCII letter
- Not contain uppercase ASCII letters
- Not be one of the reserved names

Reserved names include: `annotation-xml`, `color-profile`, `font-face`, `font-face-src`, `font-face-uri`, `font-face-format`, `font-face-name`, and `missing-glyph`.

```javascript
// Valid names
customElements.define('my-button', MyButton);
customElements.define('x-component-v2', ComponentV2);
customElements.define('my-app', MyApp);

// Invalid names - will throw
customElements.define('mybutton', MyButton); // No hyphen
customElements.define('My-Button', MyButton); // Uppercase
```

### Performance Considerations

**[Inference]** Custom elements introduce performance overhead in several areas:

**Upgrade cost** - When `define()` is called, all matching undefined elements in the DOM upgrade synchronously. For large DOMs, defer registration until needed or use lazy loading.

**Constructor execution** - Runs for every element instance. Keep constructors lightweight; defer expensive operations to `connectedCallback`.

**Attribute observation** - Each observed attribute that changes triggers `attributeChangedCallback`. Minimize the `observedAttributes` array and batch attribute changes.

**Shadow DOM overhead** - Each shadow root adds memory and rendering cost. For simple components, consider using light DOM only.

```javascript
// Defer expensive work
class OptimizedElement extends HTMLElement {
  connectedCallback() {
    // Fast: just flag for later
    this._needsSetup = true;
    requestIdleCallback(() => this._expensiveSetup());
  }

  _expensiveSetup() {
    if (!this._needsSetup) return;
    this._needsSetup = false;
    // Expensive operations here
  }
}
```

### Event Handling Patterns

Custom elements should follow standard event patterns, dispatching events that bubble and can be canceled:

```javascript
class InteractiveElement extends HTMLElement {
  _handleAction() {
    const event = new CustomEvent('action', {
      bubbles: true,
      cancelable: true,
      composed: true, // Cross shadow boundary
      detail: { timestamp: Date.now() }
    });

    const allowed = this.dispatchEvent(event);
    if (allowed) {
      this._performAction();
    }
  }
}
```

The `composed: true` flag allows the event to cross shadow DOM boundaries, making it visible to listeners on ancestor elements outside the shadow tree.

For form-related events, dispatch events that match native element behavior:

```javascript
class CustomInput extends HTMLElement {
  _handleInput(value) {
    // Dispatch standard events
    this.dispatchEvent(new Event('input', { bubbles: true }));
    this.dispatchEvent(new Event('change', { bubbles: true }));
  }
}
```

### CSS Custom Properties (CSS Variables) and Theming

Shadow DOM CSS is isolated, but CSS custom properties pierce the shadow boundary, enabling theming:

```javascript
class ThemedElement extends HTMLElement {
  constructor() {
    super();
    this.attachShadow({ mode: 'open' });
    this.shadowRoot.innerHTML = `
      <style>
        :host {
          background: var(--element-bg, white);
          color: var(--element-color, black);
          border: 1px solid var(--element-border, gray);
        }
      </style>
      <slot></slot>
    `;
  }
}
```

```css
/* External stylesheet can theme the element */
themed-element {
  --element-bg: #f0f0f0;
  --element-color: #333;
  --element-border: #ccc;
}
```

The `:host` selector targets the custom element itself from within the shadow DOM. `:host()` accepts a selector to conditionally style the host, and `:host-context()` styles based on ancestors (though browser support varies).

### Part and Exportparts

The `part` attribute exposes shadow DOM elements for external styling:

```javascript
this.shadowRoot.innerHTML = `
  <style>
    .header { font-weight: bold; }
  </style>
  <div part="header" class="header">
    <slot name="title"></slot>
  </div>
  <div part="body">
    <slot></slot>
  </div>
`;
```

```css
/* External stylesheet can style parts */
my-element::part(header) {
  color: blue;
  background: yellow;
}
```

Nested custom elements can export their parts upward:

```html
<parent-element>
  <child-element exportparts="header: child-header"></child-element>
</parent-element>
```

```css
parent-element::part(child-header) {
  /* Styles child's header part through parent */
}
```

### Accessibility Considerations

Custom elements must implement proper accessibility:

```javascript
class AccessibleButton extends HTMLElement {
  connectedCallback() {
    // Add ARIA role if not natively semantic
    if (!this.hasAttribute('role')) {
      this.setAttribute('role', 'button');
    }

    // Make focusable
    if (!this.hasAttribute('tabindex')) {
      this.setAttribute('tabindex', '0');
    }

    // Handle keyboard interaction
    this.addEventListener('keydown', (e) => {
      if (e.key === 'Enter' || e.key === ' ') {
        e.preventDefault();
        this.click();
      }
    });
  }
}
```

**[Inference]** For complex widgets, using customized built-in elements often provides better accessibility "for free" since native elements include proper roles, keyboard handling, and screen reader support. However, this requires weighing browser support tradeoffs.

Ensure shadow DOM content is accessible:

```javascript
this.shadowRoot.innerHTML = `
  <button part="button" aria-label="${this.getAttribute('label')}">
    <slot></slot>
  </button>
`;
```

### Template Cloning and Efficiency

Using `<template>` elements improves performance when creating multiple instances:

```javascript
const template = document.createElement('template');
template.innerHTML = `
  <style>
    :host { display: block; }
  </style>
  <div class="container">
    <slot></slot>
  </div>
`;

class TemplatedElement extends HTMLElement {
  constructor() {
    super();
    this.attachShadow({ mode: 'open' });
    // Clone template content (faster than innerHTML)
    this.shadowRoot.appendChild(template.content.cloneNode(true));
  }
}
```

Template cloning is significantly faster than setting `innerHTML` repeatedly because the browser parses the content once and reuses the parsed structure.

### Declarative Shadow DOM

**[Unverified browser support status]** Declarative Shadow DOM allows server-side rendering of shadow roots:

```html
<my-element>
  <template shadowrootmode="open">
    <style>
      :host { display: block; }
    </style>
    <slot></slot>
  </template>
  Light DOM content
</my-element>
```

The browser automatically attaches the shadow root from the template. The custom element can detect and use this existing shadow root:

```javascript
class SSRElement extends HTMLElement {
  constructor() {
    super();
    // Shadow root may already exist from declarative SD
    if (!this.shadowRoot) {
      this.attachShadow({ mode: 'open' });
      // Setup content
    }
  }
}
```

This enables progressive enhancement where the element works before JavaScript loads.

### Dynamic Module Loading

Custom elements can be loaded dynamically to reduce initial bundle size:

```javascript
// Lazy registration
class LazyElement extends HTMLElement {
  connectedCallback() {
    if (!this._initialized) {
      this._initialized = true;
      this.textContent = 'Loading...';
      import('./heavy-component.js').then(module => {
        customElements.define('heavy-component', module.HeavyComponent);
      });
    }
  }
}

customElements.define('lazy-element', LazyElement);
```

Or use Intersection Observer to register when elements enter viewport:

```javascript
const observer = new IntersectionObserver((entries) => {
  entries.forEach(entry => {
    if (entry.isIntersecting) {
      import('./component.js').then(module => {
        customElements.define('lazy-component', module.Component);
      });
      observer.disconnect();
    }
  });
});

document.querySelectorAll('lazy-component').forEach(el => {
  observer.observe(el);
});
```

### Custom Built-in Element Considerations

**[Unverified]** WebKit/Safari has historically resisted implementing customized built-in elements, requiring fallback strategies:

```javascript
// Feature detection
if ('customElements' in window && customElements.define.length > 2) {
  // Supports customized built-ins
  customElements.define('fancy-button', FancyButton, { extends: 'button' });
} else {
  // Fallback to autonomous element
  class FancyButtonAutonomous extends HTMLElement {
    constructor() {
      super();
      const button = document.createElement('button');
      button.textContent = this.textContent;
      this.appendChild(button);
    }
  }
  customElements.define('fancy-button', FancyButtonAutonomous);
}
```

### State Management Patterns

Custom elements can implement various state management approaches:

**Internal state:**

```javascript
class StatefulElement extends HTMLElement {
  #state = { count: 0 };

  get state() {
    return { ...this.#state };
  }

  setState(updates) {
    this.#state = { ...this.#state, ...updates };
    this.render();
  }

  render() {
    this.shadowRoot.querySelector('#count').textContent = this.#state.count;
  }
}
```

**Observable pattern:**

```javascript
class ObservableElement extends HTMLElement {
  constructor() {
    super();
    this._listeners = new Set();
  }

  subscribe(callback) {
    this._listeners.add(callback);
    return () => this._listeners.delete(callback);
  }

  _notify() {
    this._listeners.forEach(cb => cb(this.state));
  }

  updateState(changes) {
    Object.assign(this._state, changes);
    this._notify();
  }
}
```

### Testing Strategies

Custom elements require specific testing approaches:

```javascript
// Test element registration
describe('MyElement', () => {
  it('should be defined', () => {
    expect(customElements.get('my-element')).toBeDefined();
  });

  it('should create instance', () => {
    const el = document.createElement('my-element');
    expect(el).toBeInstanceOf(MyElement);
  });

  it('should render content when connected', async () => {
    const el = document.createElement('my-element');
    document.body.appendChild(el);
    
    // Wait for lifecycle to complete
    await customElements.whenDefined('my-element');
    await new Promise(resolve => setTimeout(resolve, 0));
    
    expect(el.shadowRoot.textContent).toContain('Expected content');
    
    el.remove();
  });
});
```

Always clean up by removing test elements from the DOM to prevent interference between tests.

---

