## cloneNode Method


### Core Functionality

The `cloneNode()` method creates a duplicate copy of a DOM node, returning a new node object that is not attached to the document tree. The method accepts a single boolean parameter controlling the depth of the copy.

```javascript
const clone = node.cloneNode(deep);
```

- `deep = true`: Clones the node and all its descendants (deep copy)
- `deep = false` or omitted: Clones only the node itself (shallow copy)

### Deep vs Shallow Cloning

**Shallow clone** (`cloneNode(false)`):

```javascript
<div id="parent" class="container">
  <p>Child paragraph</p>
  <span>Child span</span>
</div>

const parent = document.querySelector('#parent');
const shallowClone = parent.cloneNode(false);
// Result: <div id="parent" class="container"></div>
// Children are NOT copied
```

**Deep clone** (`cloneNode(true)`):

```javascript
const deepClone = parent.cloneNode(true);
// Result: <div id="parent" class="container">
//           <p>Child paragraph</p>
//           <span>Child span</span>
//         </div>
// Entire subtree is copied
```

### What Gets Cloned

The cloned node receives copies of:

- **Element attributes**: `id`, `class`, `data-*`, `style`, etc.
- **Text content**: Text nodes and their content
- **Node type**: Element, text, comment nodes maintain their type
- **Inline styles**: The `style` attribute with all inline CSS
- **All descendants** (if `deep = true`)

### What Does NOT Get Cloned

**Event listeners** do not copy to the clone:

```javascript
const button = document.querySelector('button');
button.addEventListener('click', handler);

const clone = button.cloneNode(true);
// Clone has NO event listeners
// Must reattach: clone.addEventListener('click', handler);
```

**JavaScript properties** set directly on the node object are not copied:

```javascript
const element = document.querySelector('.item');
element.customData = { value: 42 };
element.isActive = true;

const clone = element.cloneNode(true);
console.log(clone.customData); // undefined
console.log(clone.isActive);   // undefined
```

**User input state** in form elements:

```javascript
const input = document.querySelector('input');
input.value = 'User typed this';

const clone = input.cloneNode(true);
console.log(clone.value); // Empty string (default value)
// The HTML value attribute is cloned, but runtime .value property is not
```

**Computed styles** from CSS stylesheets do not transfer as properties (though the element maintains classes that will apply styles once inserted):

```javascript
const element = document.querySelector('.styled');
// element has CSS styles from stylesheet

const clone = element.cloneNode(true);
// clone has same classes but is not in DOM
// getComputedStyle(clone) returns default values until inserted
```

### Cloned Node State

The returned node exists in memory but is **not attached** to any document:

```javascript
const original = document.querySelector('.item');
const clone = original.cloneNode(true);

console.log(clone.parentNode);        // null
console.log(clone.isConnected);       // false
console.log(document.contains(clone)); // false
```

To use the clone, you must explicitly insert it:

```javascript
document.body.appendChild(clone);
// or
original.parentNode.appendChild(clone);
// or
original.after(clone);
```

### ID Attribute Duplication

`cloneNode()` copies the `id` attribute, potentially creating duplicate IDs in the document:

```javascript
<div id="unique">Original</div>

const original = document.querySelector('#unique');
const clone = original.cloneNode(true);
document.body.appendChild(clone);

// DOM now has TWO elements with id="unique" (invalid HTML)
```

This violates HTML specifications where IDs must be unique. Best practices:

```javascript
const clone = original.cloneNode(true);
clone.removeAttribute('id');
// or
clone.id = 'unique-' + Date.now();
// or
clone.id = crypto.randomUUID();
```

### Text Node Cloning

Text nodes can be cloned independently:

```javascript
const textNode = document.createTextNode('Hello');
const clone = textNode.cloneNode(); // deep parameter ignored for text nodes
console.log(clone.textContent); // "Hello"
```

For text nodes, the `deep` parameter has no effect since text nodes have no children.

### Comment and Document Fragment Cloning

**Comment nodes:**

```javascript
const comment = document.createComment('This is a comment');
const clone = comment.cloneNode();
console.log(clone.nodeValue); // "This is a comment"
```

**Document fragments:**

```javascript
const fragment = document.createDocumentFragment();
fragment.appendChild(document.createElement('div'));
fragment.appendChild(document.createElement('p'));

const clone = fragment.cloneNode(true);
console.log(clone.childNodes.length); // 2
```

### Performance Considerations

**[Inference]** Deep cloning large subtrees involves recursive copying of all descendants, which can be expensive for deeply nested or large DOM structures. Shallow cloning is significantly faster when descendants are not needed.

**[Unverified]** Modern browsers optimize cloning operations, but exact performance characteristics vary by implementation and DOM complexity.

Creating multiple clones in loops:

```javascript
// Less efficient for many clones:
for (let i = 0; i < 1000; i++) {
  const clone = template.cloneNode(true);
  container.appendChild(clone);
}

// More efficient - batch with DocumentFragment:
const fragment = document.createDocumentFragment();
for (let i = 0; i < 1000; i++) {
  const clone = template.cloneNode(true);
  fragment.appendChild(clone);
}
container.appendChild(fragment); // Single reflow
```

### Template Pattern

`cloneNode()` is essential for the `<template>` element pattern:

```html
<template id="item-template">
  <div class="item">
    <h3 class="title"></h3>
    <p class="description"></p>
  </div>
</template>
```

```javascript
const template = document.querySelector('#item-template');

function createItem(title, description) {
  const clone = template.content.cloneNode(true);
  clone.querySelector('.title').textContent = title;
  clone.querySelector('.description').textContent = description;
  return clone;
}

container.appendChild(createItem('Title', 'Description'));
```

Template content is a DocumentFragment, and cloning it provides a fresh instance for each use.

### Cloning with Data Attributes

Data attributes (`data-*`) clone along with the element:

```javascript
<div data-id="123" data-type="user" data-active="true">Content</div>

const element = document.querySelector('div');
const clone = element.cloneNode(true);

console.log(clone.dataset.id);     // "123"
console.log(clone.dataset.type);   // "user"
console.log(clone.dataset.active); // "true"
```

This makes cloning useful for duplicating elements with configuration stored in data attributes.

### Shadow DOM Cloning

When cloning an element with a shadow root, the shadow root itself does **not** clone:

```javascript
const host = document.createElement('div');
const shadow = host.attachShadow({ mode: 'open' });
shadow.innerHTML = '<p>Shadow content</p>';

const clone = host.cloneNode(true);
console.log(clone.shadowRoot); // null
```

**[Inference]** This behavior exists because shadow DOM represents encapsulated component state that typically shouldn't duplicate with the host element. Manual shadow DOM reconstruction is required if needed.

### Script Element Cloning

Cloning `<script>` elements creates copies, but cloned scripts do **not** execute automatically:

```javascript
<script id="original">console.log('Executed');</script>

const script = document.querySelector('#original');
const clone = script.cloneNode(true);
document.body.appendChild(clone);
// "Executed" does NOT log again
```

**[Inference]** Browsers prevent cloned scripts from executing to avoid unintended side effects and security issues. To execute a cloned script's code, create a new script element and copy the text content.

### Cloning Across Documents

`cloneNode()` creates a clone in the same document as the original. To clone across documents (e.g., from one iframe to another), use `importNode()`:

```javascript
// Wrong approach:
const clone = iframe.contentDocument.body.cloneNode(true);
document.body.appendChild(clone); // DOMException: ownership error

// Correct approach:
const imported = document.importNode(iframe.contentDocument.body, true);
document.body.appendChild(imported);
```

### Common Use Cases

**Duplicating list items:**

```javascript
const listItem = document.querySelector('.list-item');
const clone = listItem.cloneNode(true);
clone.querySelector('.title').textContent = 'New item';
listItem.parentNode.appendChild(clone);
```

**Creating reusable components:**

```javascript
const cardTemplate = document.querySelector('.card-template');

function createCard(data) {
  const card = cardTemplate.cloneNode(true);
  card.classList.remove('card-template');
  card.querySelector('.name').textContent = data.name;
  card.querySelector('.price').textContent = data.price;
  return card;
}
```

**Backup before modification:**

```javascript
const backup = element.cloneNode(true);
// Modify original
element.textContent = 'Modified';
// Restore if needed
element.replaceWith(backup);
```

**Animation or transition duplication:**

```javascript
// Create animated copy that fades out
const clone = element.cloneNode(true);
clone.style.position = 'absolute';
clone.style.transition = 'opacity 1s';
document.body.appendChild(clone);
setTimeout(() => clone.style.opacity = '0', 0);
```

### Memory Management

Cloned nodes are regular JavaScript objects subject to garbage collection:

```javascript
function createTemporaryClone() {
  const clone = element.cloneNode(true);
  // Process clone
  return clone;
} // clone is garbage collected if not returned/referenced
```

Holding references to many clones without inserting them into the document can consume memory. Unreferenced clones are eligible for garbage collection.

### Cloning with Web Components

Custom elements clone as standard elements, but their internal state behavior depends on implementation:

```javascript
class MyElement extends HTMLElement {
  constructor() {
    super();
    this.data = { value: 42 };
  }
}
customElements.define('my-element', MyElement);

const original = document.createElement('my-element');
const clone = original.cloneNode(true);
console.log(clone.data); // undefined (constructor runs, but instance property doesn't copy)
```

**[Inference]** Custom element constructors run for clones when inserted into the document, initializing fresh component state rather than copying the original's state.

### Attribute Node Cloning

All attributes clone to the new element:

```javascript
<div class="foo bar" id="test" data-value="123" style="color: red;">

const element = document.querySelector('div');
const clone = element.cloneNode(false);

console.log(clone.className);      // "foo bar"
console.log(clone.id);             // "test"
console.log(clone.dataset.value);  // "123"
console.log(clone.style.color);    // "red"
```

Attributes exist on the clone even before document insertion, unlike computed styles which require document context.

---

