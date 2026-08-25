## createElement


### Basic Syntax

```javascript
document.createElement(tagName, [options])
```

**Parameters:**

- `tagName` (string): The type of element to create (e.g., "div", "span", "a")
- `options` (object, optional): An options object with an `is` property for custom built-in elements

**Returns:** A new Element node with `nodeType === 1`

### Standard Element Creation

```javascript
const div = document.createElement('div');
console.log(div.nodeType); // 1 (ELEMENT_NODE)
console.log(div.tagName); // "DIV"
console.log(div.nodeName); // "DIV"
console.log(div.parentNode); // null (not yet inserted)
console.log(div.ownerDocument === document); // true
```

**Case Insensitivity in HTML:**

```javascript
// All create the same element in HTML documents
document.createElement('div');
document.createElement('DIV');
document.createElement('DiV');

// All have tagName "DIV"
```

**Case Sensitivity in XML:** In XML documents (including XHTML served with XML MIME type), tag names are case-sensitive:

```javascript
// In XML document
const xmlDoc = document.implementation.createDocument(null, 'root', null);
const lower = xmlDoc.createElement('div'); // Creates <div>
const upper = xmlDoc.createElement('DIV'); // Creates <DIV> (different element)
```

### Element Properties After Creation

**Initial State:**

```javascript
const element = document.createElement('div');

// Node properties
element.nodeType; // 1
element.nodeName; // "DIV"
element.nodeValue; // null
element.textContent; // ""
element.innerHTML; // ""

// Parent/child relationships
element.parentNode; // null
element.parentElement; // null
element.childNodes.length; // 0
element.children.length; // 0

// Attributes
element.attributes.length; // 0
element.id; // ""
element.className; // ""

// State
element.isConnected; // false (not in document)
```

The created element exists in memory but is not part of any document tree until explicitly inserted.

### Setting Attributes and Properties

**Method 1: Direct Property Assignment**

```javascript
const div = document.createElement('div');
div.id = 'myDiv';
div.className = 'container active';
div.textContent = 'Hello World';
div.title = 'Tooltip text';

// Boolean attributes
const input = document.createElement('input');
input.disabled = true;
input.checked = true;
input.required = true;
```

**Method 2: setAttribute()**

```javascript
const div = document.createElement('div');
div.setAttribute('id', 'myDiv');
div.setAttribute('class', 'container');
div.setAttribute('data-value', '123');
div.setAttribute('aria-label', 'Description');

// Custom attributes
div.setAttribute('my-custom-attr', 'value');
```

**Method 3: Object.assign() Pattern**

```javascript
const button = Object.assign(document.createElement('button'), {
  textContent: 'Click Me',
  className: 'btn btn-primary',
  type: 'button',
  onclick: () => console.log('Clicked')
});
```

**Method 4: Chaining Helper**

```javascript
function create(tag, props = {}) {
  const element = document.createElement(tag);
  Object.entries(props).forEach(([key, value]) => {
    if (key === 'textContent' || key === 'innerHTML') {
      element[key] = value;
    } else if (key === 'style' && typeof value === 'object') {
      Object.assign(element.style, value);
    } else if (key.startsWith('on')) {
      element[key] = value;
    } else {
      element.setAttribute(key, value);
    }
  });
  return element;
}

const div = create('div', {
  id: 'container',
  class: 'wrapper',
  textContent: 'Content',
  style: { color: 'red', padding: '10px' },
  onclick: () => console.log('Clicked')
});
```

### Adding Content

**Text Content:**

```javascript
const div = document.createElement('div');

// Method 1: textContent
div.textContent = 'Plain text'; // Escapes HTML

// Method 2: innerHTML
div.innerHTML = '<strong>Bold</strong>'; // Parses HTML

// Method 3: createTextNode + appendChild
const textNode = document.createTextNode('Text content');
div.appendChild(textNode);
```

**Child Elements:**

```javascript
const parent = document.createElement('div');
const child1 = document.createElement('span');
const child2 = document.createElement('span');

child1.textContent = 'First';
child2.textContent = 'Second';

parent.appendChild(child1);
parent.appendChild(child2);

// Result: <div><span>First</span><span>Second</span></div>
```

**Multiple Children Efficiently:**

```javascript
const container = document.createElement('div');
const fragment = document.createDocumentFragment();

for (let i = 0; i < 100; i++) {
  const item = document.createElement('div');
  item.textContent = `Item ${i}`;
  fragment.appendChild(item);
}

container.appendChild(fragment); // Single operation
```

### Inserting Into Document

**appendChild():**

```javascript
const div = document.createElement('div');
div.textContent = 'New content';

document.body.appendChild(div); // Adds to end of body
```

**insertBefore():**

```javascript
const newDiv = document.createElement('div');
const referenceNode = document.querySelector('#reference');

referenceNode.parentNode.insertBefore(newDiv, referenceNode);
// Inserts newDiv before referenceNode
```

**Modern Insertion Methods:**

```javascript
const div = document.createElement('div');
const target = document.querySelector('#target');

// Insert relative to target
target.before(div); // Before target
target.after(div); // After target
target.prepend(div); // First child of target
target.append(div); // Last child of target

// Replace target
target.replaceWith(div);
```

**Multiple Elements:**

```javascript
const container = document.querySelector('#container');

container.append(
  document.createElement('div'),
  document.createElement('span'),
  'Text node', // String automatically becomes text node
  document.createElement('p')
);
```

### HTML Element Types

Different tag names create different HTMLElement subclasses:

```javascript
const div = document.createElement('div');
console.log(div instanceof HTMLDivElement); // true
console.log(div instanceof HTMLElement); // true

const anchor = document.createElement('a');
console.log(anchor instanceof HTMLAnchorElement); // true
anchor.href = 'https://example.com';
anchor.target = '_blank';

const input = document.createElement('input');
console.log(input instanceof HTMLInputElement); // true
input.type = 'text';
input.value = 'default';

const img = document.createElement('img');
console.log(img instanceof HTMLImageElement); // true
img.src = 'image.jpg';
img.alt = 'Description';

const canvas = document.createElement('canvas');
console.log(canvas instanceof HTMLCanvasElement); // true
const ctx = canvas.getContext('2d');
```

### Special Element Types

**Table Elements:**

```javascript
const table = document.createElement('table');
const thead = document.createElement('thead');
const tbody = document.createElement('tbody');
const tr = document.createElement('tr');
const th = document.createElement('th');
const td = document.createElement('td');

// Table-specific methods available
const row = table.insertRow();
const cell = row.insertCell();
```

**Form Elements:**

```javascript
const form = document.createElement('form');
const input = document.createElement('input');
const select = document.createElement('select');
const option = document.createElement('option');
const textarea = document.createElement('textarea');

form.method = 'POST';
form.action = '/submit';

input.type = 'email';
input.name = 'userEmail';
input.required = true;

option.value = 'value1';
option.textContent = 'Option 1';
select.appendChild(option);
```

**Media Elements:**

```javascript
const video = document.createElement('video');
video.src = 'video.mp4';
video.controls = true;
video.autoplay = false;

const audio = document.createElement('audio');
audio.src = 'audio.mp3';
audio.loop = true;

const source = document.createElement('source');
source.src = 'video.webm';
source.type = 'video/webm';
video.appendChild(source);
```

### Self-Closing Elements (Void Elements)

Certain HTML elements cannot have children:

```javascript
const img = document.createElement('img');
const br = document.createElement('br');
const hr = document.createElement('hr');
const input = document.createElement('input');
const meta = document.createElement('meta');
const link = document.createElement('link');

// These cannot have children
img.appendChild(document.createElement('div')); // Works but invalid HTML
// innerHTML for these is always ""
img.innerHTML = '<span>text</span>'; // Ignored
```

**Complete list of void elements:** area, base, br, col, embed, hr, img, input, link, meta, param, source, track, wbr

### Unknown/Custom Elements

Creating elements with unrecognized tag names:

```javascript
const unknown = document.createElement('mycustomtag');
console.log(unknown instanceof HTMLUnknownElement); // true
console.log(unknown.constructor.name); // "HTMLUnknownElement"

// Still works as a generic element
unknown.textContent = 'Content';
document.body.appendChild(unknown);
```

**Custom Elements (Web Components):**

```javascript
// Must contain hyphen in tag name
const custom = document.createElement('my-component');

// Before definition: HTMLElement (in modern browsers)
console.log(custom instanceof HTMLElement); // true

// After definition
class MyComponent extends HTMLElement {
  constructor() {
    super();
    this.attachShadow({ mode: 'open' });
  }
  
  connectedCallback() {
    this.shadowRoot.innerHTML = '<p>Custom content</p>';
  }
}

customElements.define('my-component', MyComponent);

// New instances use custom class
const custom2 = document.createElement('my-component');
console.log(custom2 instanceof MyComponent); // true
```

### Customized Built-in Elements

Extending native elements with custom behavior:

```javascript
class FancyButton extends HTMLButtonElement {
  constructor() {
    super();
    this.addEventListener('click', () => {
      this.style.transform = 'scale(0.95)';
      setTimeout(() => this.style.transform = '', 100);
    });
  }
}

customElements.define('fancy-button', FancyButton, { extends: 'button' });

// Creating customized built-in element
const fancyBtn = document.createElement('button', { is: 'fancy-button' });
console.log(fancyBtn instanceof FancyButton); // true
console.log(fancyBtn instanceof HTMLButtonElement); // true
```

### Namespace and XML Elements

**SVG Elements:**

```javascript
// Wrong - creates HTMLUnknownElement
const wrongSvg = document.createElement('svg');

// Correct - creates SVGSVGElement
const svg = document.createElementNS('http://www.w3.org/2000/svg', 'svg');
console.log(svg instanceof SVGSVGElement); // true

svg.setAttribute('width', '100');
svg.setAttribute('height', '100');

const circle = document.createElementNS('http://www.w3.org/2000/svg', 'circle');
circle.setAttribute('cx', '50');
circle.setAttribute('cy', '50');
circle.setAttribute('r', '40');
circle.setAttribute('fill', 'blue');

svg.appendChild(circle);
document.body.appendChild(svg);
```

**MathML Elements:**

```javascript
const math = document.createElementNS('http://www.w3.org/1998/Math/MathML', 'math');
const mfrac = document.createElementNS('http://www.w3.org/1998/Math/MathML', 'mfrac');
const mn1 = document.createElementNS('http://www.w3.org/1998/Math/MathML', 'mn');
const mn2 = document.createElementNS('http://www.w3.org/1998/Math/MathML', 'mn');

mn1.textContent = '1';
mn2.textContent = '2';

mfrac.appendChild(mn1);
mfrac.appendChild(mn2);
math.appendChild(mfrac);
```

### Performance Considerations

**Document vs Template:**

```javascript
// Inefficient - creates and parses HTML string
function createManyElements1(count) {
  const container = document.createElement('div');
  let html = '';
  for (let i = 0; i < count; i++) {
    html += `<div class="item">${i}</div>`;
  }
  container.innerHTML = html;
  return container;
}

// More efficient - direct createElement
function createManyElements2(count) {
  const container = document.createElement('div');
  const fragment = document.createDocumentFragment();
  
  for (let i = 0; i < count; i++) {
    const div = document.createElement('div');
    div.className = 'item';
    div.textContent = i;
    fragment.appendChild(div);
  }
  
  container.appendChild(fragment);
  return container;
}
```

[Inference: Based on typical browser optimization patterns] Modern browsers optimize `createElement` heavily, but for very large numbers of elements (1000+), `innerHTML` can be faster due to the optimized HTML parser. For moderate numbers with complex structures, `createElement` with DocumentFragment is often more performant.

**Cloning vs Creating:**

```javascript
// Template pattern - create once, clone many
const template = document.createElement('div');
template.className = 'item';
template.innerHTML = '<span class="icon"></span><span class="text"></span>';

function createFromTemplate(text) {
  const clone = template.cloneNode(true);
  clone.querySelector('.text').textContent = text;
  return clone;
}

// Faster than creating from scratch each time for complex structures
for (let i = 0; i < 1000; i++) {
  container.appendChild(createFromTemplate(`Item ${i}`));
}
```

### Memory Management

**Detached Elements:**

```javascript
const div = document.createElement('div');
// Element exists in memory but not in document
// Will be garbage collected when no references remain

let element = document.createElement('div');
document.body.appendChild(element);
element.remove();
element = null; // Allow garbage collection
```

**Event Listener Memory:**

```javascript
function createElementWithListener() {
  const button = document.createElement('button');
  
  // This creates a memory leak if button is removed but reference kept
  button.addEventListener('click', function() {
    console.log('Clicked');
  });
  
  return button;
}

// Better - use weak references or remove listeners
function createElementSafely() {
  const button = document.createElement('button');
  const handler = () => console.log('Clicked');
  
  button.addEventListener('click', handler);
  
  // Store reference to remove later
  button._handler = handler;
  
  return button;
}

// Clean up
const btn = createElementSafely();
btn.removeEventListener('click', btn._handler);
```

### Template Element Special Case

The `<template>` element has special behavior:

```javascript
const template = document.createElement('template');
template.innerHTML = '<div class="item">Content</div>';

console.log(template.content); // DocumentFragment
console.log(template.childNodes.length); // 0 (content is in fragment)
console.log(template.content.childNodes.length); // 1

// Cloning template content
const clone = template.content.cloneNode(true);
document.body.appendChild(clone);
```

### Script Element Execution

Script elements created with `createElement` don't execute by default:

```javascript
const script = document.createElement('script');
script.textContent = 'console.log("This runs")';
document.body.appendChild(script); // ✓ Executes

const script2 = document.createElement('script');
script2.src = 'external.js';
document.head.appendChild(script2); // ✓ Executes

const script3 = document.createElement('script');
script3.innerHTML = 'console.log("test")'; // Using innerHTML
document.body.appendChild(script3); // ✓ Still executes
```

Scripts execute when inserted into the document, but:

```javascript
const div = document.createElement('div');
div.innerHTML = '<script>console.log("This does NOT run")</script>';
document.body.appendChild(div); // Script tag exists but doesn't execute
```

Scripts created through `innerHTML` assignment don't execute for security reasons.

### Style Element

```javascript
const style = document.createElement('style');
style.textContent = `
  .my-class {
    color: red;
    font-size: 16px;
  }
`;

document.head.appendChild(style);
// Styles are now active
```

### Link Element for Stylesheets

```javascript
const link = document.createElement('link');
link.rel = 'stylesheet';
link.href = 'styles.css';
link.type = 'text/css';

// Optional: wait for load
link.onload = () => console.log('Stylesheet loaded');
link.onerror = () => console.error('Failed to load stylesheet');

document.head.appendChild(link);
```

### Meta Elements

```javascript
const viewport = document.createElement('meta');
viewport.name = 'viewport';
viewport.content = 'width=device-width, initial-scale=1.0';
document.head.appendChild(viewport);

const charset = document.createElement('meta');
charset.setAttribute('charset', 'UTF-8');
document.head.appendChild(charset);

const ogTitle = document.createElement('meta');
ogTitle.setAttribute('property', 'og:title');
ogTitle.content = 'Page Title';
document.head.appendChild(ogTitle);
```

### Canvas Context Initialization

```javascript
const canvas = document.createElement('canvas');
canvas.width = 800;
canvas.height = 600;

// Get context before or after appending - both work
const ctx = canvas.getContext('2d');

document.body.appendChild(canvas);

// Now can draw
ctx.fillStyle = 'blue';
ctx.fillRect(0, 0, 100, 100);
```

### IFrame Creation

```javascript
const iframe = document.createElement('iframe');
iframe.src = 'https://example.com';
iframe.width = '600';
iframe.height = '400';
iframe.sandbox = 'allow-scripts allow-same-origin';

iframe.onload = () => {
  // Access iframe document (if same-origin)
  try {
    const iframeDoc = iframe.contentDocument;
    console.log(iframeDoc.title);
  } catch (e) {
    console.log('Cross-origin iframe');
  }
};

document.body.appendChild(iframe);
```

### Common Patterns and Best Practices

**Factory Functions:**

```javascript
function createButton({ text, className, onClick }) {
  const button = document.createElement('button');
  button.textContent = text;
  button.className = className || '';
  if (onClick) button.onclick = onClick;
  return button;
}

const btn = createButton({
  text: 'Submit',
  className: 'btn-primary',
  onClick: () => console.log('Clicked')
});
```

**Builder Pattern:**

```javascript
class ElementBuilder {
  constructor(tagName) {
    this.element = document.createElement(tagName);
  }
  
  attr(name, value) {
    this.element.setAttribute(name, value);
    return this;
  }
  
  text(content) {
    this.element.textContent = content;
    return this;
  }
  
  child(childElement) {
    this.element.appendChild(childElement);
    return this;
  }
  
  on(event, handler) {
    this.element.addEventListener(event, handler);
    return this;
  }
  
  build() {
    return this.element;
  }
}

const div = new ElementBuilder('div')
  .attr('id', 'container')
  .attr('class', 'wrapper')
  .text('Content')
  .on('click', () => console.log('Clicked'))
  .build();
```

**JSX-like Helper:**

```javascript
function h(tag, props = {}, ...children) {
  const element = document.createElement(tag);
  
  Object.entries(props).forEach(([key, value]) => {
    if (key.startsWith('on')) {
      element.addEventListener(key.slice(2).toLowerCase(), value);
    } else if (key === 'className') {
      element.className = value;
    } else if (key === 'style' && typeof value === 'object') {
      Object.assign(element.style, value);
    } else {
      element.setAttribute(key, value);
    }
  });
  
  children.forEach(child => {
    if (typeof child === 'string') {
      element.appendChild(document.createTextNode(child));
    } else if (child instanceof Node) {
      element.appendChild(child);
    }
  });
  
  return element;
}

// Usage
const component = h('div', { className: 'container' },
  h('h1', {}, 'Title'),
  h('p', {}, 'Paragraph text'),
  h('button', { onClick: () => alert('Clicked') }, 'Click me')
);
```

### Sanitization Considerations

When creating elements with user-provided content:

```javascript
// Safe - textContent automatically escapes
function createSafeDiv(userInput) {
  const div = document.createElement('div');
  div.textContent = userInput; // <script> tags become literal text
  return div;
}

// Unsafe - innerHTML can execute scripts
function createUnsafeDiv(userInput) {
  const div = document.createElement('div');
  div.innerHTML = userInput; // Dangerous if userInput contains <script>
  return div;
}

// If innerHTML needed, sanitize first
function createSanitizedDiv(userInput) {
  const div = document.createElement('div');
  // Use DOMPurify or similar library
  div.innerHTML = DOMPurify.sanitize(userInput);
  return div;
}
```

### Cross-Browser Compatibility

`createElement` has excellent cross-browser support going back to IE5. Modern features to watch:

```javascript
// Customized built-in elements - limited support
const fancy = document.createElement('button', { is: 'fancy-button' });
// Not supported in Safari as of 2024

// Modern insertion methods - widely supported now
element.before();
element.after();
element.append();
element.prepend();
element.replaceWith();
// Supported in all modern browsers

// Custom elements - good support
customElements.define('my-element', MyElement);
// Supported in all modern browsers
```

---

