## Shadow DOM Basics


### Encapsulation Mechanism

Shadow DOM creates an isolated DOM subtree attached to an element, separated from the main document tree. The shadow root serves as the boundary between the shadow tree and the light DOM (regular document DOM). This encapsulation prevents styles and scripts from leaking in or out, though certain properties like inherited CSS properties do cross the boundary.

### Creating Shadow Roots

Attach a shadow root using `element.attachShadow({mode: 'open'})` or `{mode: 'closed'}`. Open mode allows external JavaScript to access the shadow root via `element.shadowRoot`. Closed mode returns `null` for this property, though this provides limited security since references can still be captured during creation.

```javascript
const host = document.querySelector('#my-element');
const shadowRoot = host.attachShadow({mode: 'open'});
shadowRoot.innerHTML = '<p>Shadow content</p>';
```

Not all elements can host shadow DOM. Valid hosts include custom elements, `<article>`, `<aside>`, `<blockquote>`, `<body>`, `<div>`, `<footer>`, `<h1>`-`<h6>`, `<header>`, `<main>`, `<nav>`, `<p>`, `<section>`, `<span>`.

### Shadow Tree Structure

The shadow tree consists of:

- **Shadow host**: The regular DOM element hosting the shadow root
- **Shadow root**: The root node of the shadow tree
- **Shadow tree**: The internal DOM structure
- **Shadow boundary**: The conceptual barrier between shadow and light DOM

### Style Encapsulation

Styles defined inside shadow DOM don't affect the outer document, and external styles (mostly) don't affect shadow content. Style encapsulation works through:

**Internal styles**: Defined within the shadow root using `<style>` tags or constructed stylesheets.

```javascript
shadowRoot.innerHTML = `
  <style>
    p { color: blue; }
  </style>
  <p>This is blue only in shadow DOM</p>
`;
```

**:host selector**: Targets the shadow host from inside the shadow DOM.

```css
:host {
  display: block;
  border: 1px solid black;
}

:host(.special) {
  border-color: red;
}

:host-context(.dark-theme) {
  background: black;
}
```

**Inheritance**: Properties like `color`, `font`, and other inherited CSS properties do cross the shadow boundary from host to shadow tree.

### Slots and Composition

Slots enable content projection from light DOM into shadow DOM, creating composition points.

**Named slots**: Use the `name` attribute to create specific insertion points.

```javascript
// Shadow DOM
shadowRoot.innerHTML = `
  <div class="card">
    <slot name="header"></slot>
    <slot></slot>
    <slot name="footer"></slot>
  </div>
`;

// Light DOM usage
<my-card>
  <h2 slot="header">Title</h2>
  <p>Default slot content</p>
  <button slot="footer">OK</button>
</my-card>
```

**Default slot**: An unnamed `<slot>` receives all light DOM children not assigned to named slots.

**Slot fallback**: Content inside `<slot>` tags displays when no light DOM content is slotted.

```javascript
shadowRoot.innerHTML = `<slot>Default fallback text</slot>`;
```

### Event Retargeting

Events that originate in shadow DOM get retargeted when they cross the shadow boundary. The `event.target` property changes to reference the shadow host rather than the actual element inside shadow DOM. This maintains encapsulation by hiding internal implementation details.

```javascript
shadowRoot.innerHTML = '<button>Click me</button>';

host.addEventListener('click', (e) => {
  console.log(e.target); // Logs the host, not the button
  console.log(e.composedPath()); // Shows full path including shadow internals
});
```

**Composed events**: Some events have `composed: true` and bubble through shadow boundaries (like `click`, `input`, `focus`). Others stay contained (like `load`, `error` on some elements).

### Parts and Themes

The `::part()` pseudo-element allows styling specific shadow DOM elements from outside, creating controlled style extension points.

```javascript
// Inside shadow DOM
shadowRoot.innerHTML = `
  <div part="container">
    <button part="button">Click</button>
  </div>
`;

// External CSS can style these
my-element::part(container) {
  padding: 20px;
}

my-element::part(button) {
  background: blue;
}
```

### Declarative Shadow DOM

Declarative Shadow DOM allows defining shadow roots in HTML without JavaScript, useful for server-side rendering.

```html
<my-element>
  <template shadowrootmode="open">
    <style>p { color: red; }</style>
    <p>Shadow content</p>
  </template>
</my-element>
```

The browser automatically attaches the template content as a shadow root. This feature has limited browser support and requires polyfills for older browsers.

### CSS Shadow Parts Forwarding

Shadow DOM can forward parts to outer contexts using the `exportparts` attribute, enabling multi-level component styling.

```javascript
// Inner component
innerShadow.innerHTML = '<button part="btn">Click</button>';

// Outer component forwards the part
outerShadow.innerHTML = `
  <inner-component exportparts="btn: inner-btn"></inner-component>
`;

// Now external CSS can style it
outer-component::part(inner-btn) {
  color: green;
}
```

### Constructable Stylesheets

Constructable stylesheets provide a performance-optimized way to share styles across multiple shadow roots.

```javascript
const sheet = new CSSStyleSheet();
sheet.replaceSync('p { color: blue; }');

shadowRoot.adoptedStyleSheets = [sheet];
// The same sheet instance can be reused across multiple shadow roots
```

This avoids parsing the same CSS multiple times and reduces memory usage when creating many similar components.

---

