## Custom Elements and Web Components


### Custom Element Basics

Custom elements represent one of the core technologies in the Web Components specification, allowing developers to create their own HTML elements with custom functionality. These elements extend the standard HTML vocabulary and can be used alongside native HTML elements.

**Key points:**

- Custom elements must have a hyphen in their name (e.g., `my-button`, `user-profile`)
- They inherit from `HTMLElement` or other built-in HTML elements
- Custom elements have a well-defined lifecycle with specific callback methods
- They can be defined using `customElements.define()`

#### Defining Custom Elements

The `customElements.define()` method registers a new custom element with the browser. The method takes the element name and a class that defines the element's behavior.

```javascript
class MyCustomElement extends HTMLElement {
  constructor() {
    super();
    // Element initialization
  }
}

customElements.define('my-custom-element', MyCustomElement);
```

#### Lifecycle Callbacks

Custom elements provide several lifecycle callbacks that execute at different stages of the element's existence:

- `connectedCallback()`: Called when the element is inserted into the DOM
- `disconnectedCallback()`: Called when the element is removed from the DOM
- `attributeChangedCallback(name, oldValue, newValue)`: Called when observed attributes change
- `adoptedCallback()`: Called when the element is moved to a new document

**Example:**

```javascript
class LifecycleElement extends HTMLElement {
  static get observedAttributes() {
    return ['status', 'value'];
  }
  
  connectedCallback() {
    console.log('Element added to page');
    this.render();
  }
  
  disconnectedCallback() {
    console.log('Element removed from page');
  }
  
  attributeChangedCallback(name, oldValue, newValue) {
    console.log(`Attribute ${name} changed from ${oldValue} to ${newValue}`);
    this.render();
  }
  
  render() {
    this.innerHTML = `<p>Status: ${this.getAttribute('status')}</p>`;
  }
}
```

#### Types of Custom Elements

There are two types of custom elements:

**Autonomous Custom Elements:** Standalone elements that extend `HTMLElement`

```javascript
class StandaloneButton extends HTMLElement {
  constructor() {
    super();
    this.addEventListener('click', this.handleClick);
  }
  
  handleClick() {
    alert('Custom button clicked!');
  }
}

customElements.define('standalone-button', StandaloneButton);
```

**Customized Built-in Elements:** Extend existing HTML elements

```javascript
class EnhancedButton extends HTMLButtonElement {
  constructor() {
    super();
    this.style.backgroundColor = 'blue';
  }
}

customElements.define('enhanced-button', EnhancedButton, { extends: 'button' });
```

### Shadow DOM Concepts

Shadow DOM provides encapsulation for custom elements by creating a separate DOM tree that's isolated from the main document. This encapsulation prevents CSS and JavaScript from the main document from interfering with the component's internal structure.

**Key points:**

- Shadow DOM creates an isolated DOM subtree
- Styles defined within shadow DOM don't affect the main document
- Shadow roots can be open (accessible) or closed (encapsulated)
- CSS selectors from the main document cannot reach into shadow DOM

#### Creating Shadow DOM

Shadow DOM is created using the `attachShadow()` method on an element:

```javascript
class ShadowElement extends HTMLElement {
  constructor() {
    super();
    
    // Create shadow root
    this.attachShadow({ mode: 'open' });
    
    // Add content to shadow root
    this.shadowRoot.innerHTML = `
      <style>
        p { color: red; }
      </style>
      <p>This text is red and encapsulated</p>
    `;
  }
}

customElements.define('shadow-element', ShadowElement);
```

#### Shadow DOM Modes

**Open Mode:** The shadow root is accessible via the element's `shadowRoot` property

```javascript
const element = document.querySelector('my-element');
console.log(element.shadowRoot); // Returns the shadow root
```

**Closed Mode:** The shadow root is not accessible from outside the element

```javascript
this.attachShadow({ mode: 'closed' });
// element.shadowRoot returns null
```

#### CSS Encapsulation

Shadow DOM provides CSS encapsulation, meaning styles defined within the shadow tree don't leak out, and external styles don't leak in:

```javascript
class EncapsulatedElement extends HTMLElement {
  constructor() {
    super();
    this.attachShadow({ mode: 'open' });
    
    this.shadowRoot.innerHTML = `
      <style>
        /* This style only affects content within this shadow DOM */
        .container {
          background: yellow;
          padding: 20px;
        }
        
        /* Host selector targets the custom element itself */
        :host {
          display: block;
          border: 2px solid black;
        }
        
        /* Host with class selector */
        :host(.highlighted) {
          border-color: red;
        }
      </style>
      <div class="container">
        <slot></slot>
      </div>
    `;
  }
}
```

#### Slots and Content Projection

Slots allow custom elements to accept and display content from their light DOM:

```javascript
class SlottedElement extends HTMLElement {
  constructor() {
    super();
    this.attachShadow({ mode: 'open' });
    
    this.shadowRoot.innerHTML = `
      <style>
        .header { font-weight: bold; }
        .content { margin: 10px 0; }
      </style>
      <div class="header">
        <slot name="title">Default Title</slot>
      </div>
      <div class="content">
        <slot>Default content</slot>
      </div>
    `;
  }
}

customElements.define('slotted-element', SlottedElement);
```

**Usage:**

```html
<slotted-element>
  <span slot="title">Custom Title</span>
  <p>This content goes in the default slot</p>
</slotted-element>
```

### Template Elements

The `<template>` element provides a way to declare fragments of HTML that are not rendered when the page loads but can be cloned and inserted into the document using JavaScript. Templates are particularly useful for creating reusable content structures in web components.

**Key points:**

- Template content is inert until activated
- Templates can contain any valid HTML, including scripts and styles
- Template content exists in a document fragment
- Templates are cloned, not moved, when used

#### Basic Template Usage

```html
<template id="user-card-template">
  <style>
    .card {
      border: 1px solid #ccc;
      border-radius: 8px;
      padding: 16px;
      margin: 8px;
    }
    .avatar {
      width: 50px;
      height: 50px;
      border-radius: 50%;
    }
  </style>
  <div class="card">
    <img class="avatar" src="" alt="User avatar">
    <h3 class="name"></h3>
    <p class="email"></p>
  </div>
</template>
```

#### Using Templates in Custom Elements

Templates work exceptionally well with custom elements and shadow DOM:

```javascript
class UserCard extends HTMLElement {
  constructor() {
    super();
    this.attachShadow({ mode: 'open' });
    
    // Get template
    const template = document.getElementById('user-card-template');
    
    // Clone template content
    const templateContent = template.content.cloneNode(true);
    
    // Append to shadow root
    this.shadowRoot.appendChild(templateContent);
  }
  
  connectedCallback() {
    this.updateCard();
  }
  
  updateCard() {
    const name = this.getAttribute('name') || 'Unknown User';
    const email = this.getAttribute('email') || 'no-email@example.com';
    const avatar = this.getAttribute('avatar') || 'default-avatar.png';
    
    this.shadowRoot.querySelector('.name').textContent = name;
    this.shadowRoot.querySelector('.email').textContent = email;
    this.shadowRoot.querySelector('.avatar').src = avatar;
  }
  
  static get observedAttributes() {
    return ['name', 'email', 'avatar'];
  }
  
  attributeChangedCallback() {
    this.updateCard();
  }
}

customElements.define('user-card', UserCard);
```

#### Template with Slots

Templates can include slot elements for more flexible content projection:

```html
<template id="flexible-card-template">
  <style>
    .card {
      border: 1px solid #ddd;
      border-radius: 4px;
      padding: 20px;
    }
    .header {
      border-bottom: 1px solid #eee;
      padding-bottom: 10px;
      margin-bottom: 10px;
    }
  </style>
  <div class="card">
    <div class="header">
      <slot name="header">Default Header</slot>
    </div>
    <div class="content">
      <slot>Default content goes here</slot>
    </div>
    <div class="footer">
      <slot name="footer"></slot>
    </div>
  </div>
</template>
```

#### Advanced Template Techniques

**Template Instantiation with Data Binding:**

```javascript
class DataBoundElement extends HTMLElement {
  constructor() {
    super();
    this.attachShadow({ mode: 'open' });
    this.data = {};
  }
  
  setData(data) {
    this.data = data;
    this.render();
  }
  
  render() {
    const template = document.getElementById('data-template');
    const clone = template.content.cloneNode(true);
    
    // Replace placeholders with actual data
    clone.querySelectorAll('[data-bind]').forEach(element => {
      const property = element.getAttribute('data-bind');
      if (this.data[property]) {
        if (element.tagName === 'IMG') {
          element.src = this.data[property];
        } else {
          element.textContent = this.data[property];
        }
      }
    });
    
    // Clear previous content and append new
    this.shadowRoot.innerHTML = '';
    this.shadowRoot.appendChild(clone);
  }
}
```

**Template with Event Handling:**

```javascript
class InteractiveTemplate extends HTMLElement {
  constructor() {
    super();
    this.attachShadow({ mode: 'open' });
    
    const template = document.getElementById('interactive-template');
    const clone = template.content.cloneNode(true);
    
    // Add event listeners to cloned content
    clone.querySelector('.button').addEventListener('click', this.handleClick.bind(this));
    
    this.shadowRoot.appendChild(clone);
  }
  
  handleClick(event) {
    this.dispatchEvent(new CustomEvent('card-clicked', {
      detail: { message: 'Card was clicked!' },
      bubbles: true
    }));
  }
}
```

**Key benefits of using templates:**

- Performance: Template content is parsed once and cloned efficiently
- Reusability: Same template can be used multiple times
- Separation of concerns: HTML structure separated from JavaScript logic
- Security: Template content is inert until explicitly activated

**Best practices:**

- Keep templates focused and single-purpose
- Use meaningful IDs for template elements
- Consider template inheritance for complex component hierarchies
- Combine templates with CSS custom properties for theming
- Use templates with module systems for better organization

The combination of custom elements, shadow DOM, and templates creates a powerful foundation for building encapsulated, reusable web components that can be used across different projects and frameworks.

---

