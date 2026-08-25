## removeChild, remove


### Method Signatures and Basic Usage

#### removeChild

```javascript
// Signature: parentNode.removeChild(childNode)
const parent = document.getElementById('container');
const child = document.getElementById('item');
const removedNode = parent.removeChild(child);

// Returns the removed node
console.log(removedNode === child); // true
```

#### remove

```javascript
// Signature: element.remove()
const element = document.getElementById('item');
element.remove();

// Returns undefined
```

### Key Differences

#### Invocation Context

```javascript
// removeChild: called on parent
parent.removeChild(child);

// remove: called on element itself
child.remove();
```

#### Return Values

```javascript
// removeChild: returns removed node
const removed = parent.removeChild(child);
parent.appendChild(removed); // Can re-append immediately

// remove: returns undefined
const result = child.remove();
console.log(result); // undefined
// Must maintain reference separately to re-append
parent.appendChild(child);
```

#### Parent Reference Requirement

```javascript
// removeChild: requires parent reference
const child = document.querySelector('.item');
const parent = child.parentNode;
if (parent) {
  parent.removeChild(child);
}

// remove: works without parent reference
const child = document.querySelector('.item');
child.remove(); // Works regardless of parent
```

### removeChild Detailed Behavior

#### Error Conditions

```javascript
// NotFoundError: child not a child of parent
const parent = document.getElementById('container');
const notChild = document.getElementById('other');

try {
  parent.removeChild(notChild);
} catch (e) {
  console.log(e.name); // 'NotFoundError'
  console.log(e.message); // "Failed to execute 'removeChild' on 'Node': The node to be removed is not a child of this node."
}

// TypeError: null or undefined
try {
  parent.removeChild(null);
} catch (e) {
  console.log(e.name); // 'TypeError'
}
```

#### Removing from DocumentFragment

```javascript
const fragment = document.createDocumentFragment();
const div = document.createElement('div');
fragment.appendChild(div);

const removed = fragment.removeChild(div);
console.log(fragment.children.length); // 0
console.log(removed === div); // true
```

#### Text Node Removal

```javascript
const parent = document.createElement('div');
parent.innerHTML = 'Hello <span>World</span>!';

// Text nodes are also children
const textNode = parent.firstChild; // "Hello "
parent.removeChild(textNode);
console.log(parent.textContent); // "World!"
```

#### Comment Node Removal

```javascript
const parent = document.createElement('div');
parent.innerHTML = '<!-- comment --><div>Content</div>';

const comment = parent.firstChild;
parent.removeChild(comment);
// Comment removed, only div remains
```

### remove Detailed Behavior

#### No-op When Not in DOM

```javascript
const element = document.createElement('div');
element.remove(); // No error, just does nothing

// Element never added to DOM
console.log(element.parentNode); // null
```

#### Removing from Different Parent Types

```javascript
// From document.body
const bodyChild = document.body.firstElementChild;
bodyChild.remove(); // Removed from body

// From DocumentFragment
const fragment = document.createDocumentFragment();
const fragChild = document.createElement('div');
fragment.appendChild(fragChild);
fragChild.remove(); // Removed from fragment

// From custom element shadow root
const shadowRoot = customElement.shadowRoot;
const shadowChild = shadowRoot.firstElementChild;
shadowChild.remove(); // Removed from shadow DOM
```

#### Multiple Calls

```javascript
const element = document.getElementById('item');
element.remove(); // Removed from DOM
element.remove(); // No error, no-op
element.remove(); // Still no error
```

### Performance Characteristics

#### Single Element Removal

[Inference] Both methods have similar performance for single element removal. The overhead difference is negligible:

```javascript
// removeChild: requires parent lookup if not cached
const child = document.querySelector('.item');
child.parentNode.removeChild(child); // Two property accesses

// remove: direct operation
child.remove(); // One method call
```

#### Batch Removal Patterns

```javascript
// Inefficient: removing children in forward iteration
const parent = document.getElementById('container');
for (let i = 0; i < parent.children.length; i++) {
  parent.removeChild(parent.children[i]); // Length changes during iteration
}

// Efficient: removing in reverse
for (let i = parent.children.length - 1; i >= 0; i--) {
  parent.removeChild(parent.children[i]);
}

// Efficient: while loop
while (parent.firstChild) {
  parent.removeChild(parent.firstChild);
}

// Efficient: using remove()
[...parent.children].forEach(child => child.remove());

// Most efficient for complete clearing: innerHTML
parent.innerHTML = ''; // Faster than iterative removal
```

#### DocumentFragment Optimization

```javascript
// Inefficient: multiple reflows
list.querySelectorAll('.item').forEach(item => item.remove());

// More efficient: move to fragment first (preserves nodes)
const fragment = document.createDocumentFragment();
list.querySelectorAll('.item').forEach(item => {
  fragment.appendChild(item); // Removes from DOM, adds to fragment
});
// Process fragment, potentially re-add later
```

### Memory and Garbage Collection

#### Reference Retention After Removal

```javascript
// removeChild: explicit reference retained
const child = document.getElementById('item');
const removed = parent.removeChild(child);
// 'removed' and 'child' both reference the node
// Node won't be garbage collected while references exist

// remove: must maintain separate reference
const element = document.getElementById('item');
element.remove();
// 'element' still references the node
// Node won't be garbage collected while reference exists
```

#### Event Listener Memory Leaks

```javascript
// Listeners remain attached after removal
const button = document.querySelector('button');
button.addEventListener('click', expensiveHandler);

button.remove(); // Removed from DOM
// If 'button' reference maintained, listeners still in memory

// Manual cleanup before removal
button.removeEventListener('click', expensiveHandler);
button.remove();

// Or let reference go out of scope
function temporaryElement() {
  const temp = document.createElement('div');
  temp.addEventListener('click', () => {});
  document.body.appendChild(temp);
  temp.remove();
  // No external reference, can be garbage collected
}
```

#### Circular Reference Concerns

```javascript
// Potential memory leak pattern
const element = document.getElementById('item');
element.myData = {
  element: element, // Circular reference
  info: 'data'
};

element.remove();
// Circular reference may prevent garbage collection in older browsers
// [Unverified] Modern browsers handle this correctly with mark-and-sweep GC

// Safer pattern: WeakMap
const elementData = new WeakMap();
elementData.set(element, { info: 'data' });
element.remove();
// WeakMap allows garbage collection when element reference is gone
```

### Event Handling During Removal

#### Events Don't Fire on Removal

```javascript
const element = document.getElementById('item');

element.addEventListener('DOMNodeRemoved', () => {
  console.log('Removed'); // Deprecated event, avoid using
});

element.remove(); // No standardized removal event fires
```

#### MutationObserver for Removal Detection

```javascript
const observer = new MutationObserver(mutations => {
  mutations.forEach(mutation => {
    mutation.removedNodes.forEach(node => {
      console.log('Node removed:', node);
    });
  });
});

observer.observe(document.body, {
  childList: true,
  subtree: true
});

// Later
const element = document.getElementById('item');
element.remove(); // Observer detects removal
```

#### Event Delegation After Removal

```javascript
// Event delegation continues working
document.body.addEventListener('click', e => {
  if (e.target.matches('.item')) {
    console.log('Item clicked');
  }
});

// Remove element
const item = document.querySelector('.item');
item.remove();

// Clicks on body no longer match removed element
// No handler cleanup needed for delegation
```

### Child Relationship Edge Cases

#### removeChild with Text Nodes

```javascript
const parent = document.createElement('div');
parent.textContent = 'Hello World';

// textContent creates a single text node
const textNode = parent.firstChild;
console.log(textNode.nodeType); // 3 (TEXT_NODE)

parent.removeChild(textNode);
console.log(parent.textContent); // ''
```

#### Removing while Iterating

```javascript
const parent = document.getElementById('list');

// WRONG: length changes during iteration
for (let i = 0; i < parent.children.length; i++) {
  parent.removeChild(parent.children[i]);
  // Skips every other child
}

// CORRECT: iterate backwards
for (let i = parent.children.length - 1; i >= 0; i--) {
  parent.removeChild(parent.children[i]);
}

// CORRECT: convert to array first
[...parent.children].forEach(child => {
  parent.removeChild(child);
});

// CORRECT: use while loop
while (parent.firstChild) {
  parent.removeChild(parent.firstChild);
}
```

#### Removing SVG Elements

```javascript
// SVG elements work the same way
const svg = document.querySelector('svg');
const circle = svg.querySelector('circle');

// Both work
svg.removeChild(circle);
circle.remove();

// Namespace doesn't affect removal
```

#### Removing from Shadow DOM

```javascript
class CustomElement extends HTMLElement {
  constructor() {
    super();
    this.attachShadow({ mode: 'open' });
    this.shadowRoot.innerHTML = '<div>Shadow content</div>';
  }
  
  removeShadowChild() {
    const div = this.shadowRoot.querySelector('div');
    
    // Both work in shadow DOM
    this.shadowRoot.removeChild(div);
    div.remove();
  }
}
```

### Common Patterns and Use Cases

#### Conditional Removal

```javascript
// Remove if condition met
const element = document.getElementById('item');
if (element.dataset.temporary === 'true') {
  element.remove();
}

// Remove all matching elements
document.querySelectorAll('.removable').forEach(el => el.remove());
```

#### Replacement Pattern

```javascript
// Replace element using removeChild
const parent = document.getElementById('container');
const oldChild = document.getElementById('old');
const newChild = document.createElement('div');

parent.removeChild(oldChild);
parent.appendChild(newChild);

// Or use replaceChild instead
parent.replaceChild(newChild, oldChild);
```

#### Temporary Removal and Reinsertion

```javascript
// Remove, modify, reinsert
const element = document.getElementById('item');
const parent = element.parentNode;
const nextSibling = element.nextSibling;

const removed = parent.removeChild(element);

// Modify while detached (avoids reflows)
removed.innerHTML = /* expensive operations */;
removed.classList.add('updated');

// Reinsert at same position
parent.insertBefore(removed, nextSibling);
```

#### Clearing Container Contents

```javascript
const container = document.getElementById('container');

// Method 1: innerHTML (fastest for complete clearing)
container.innerHTML = '';

// Method 2: removeChild loop (preserves node references)
while (container.firstChild) {
  container.removeChild(container.firstChild);
}

// Method 3: remove() on each child
[...container.children].forEach(child => child.remove());

// Method 4: replaceChildren (modern)
container.replaceChildren(); // Removes all children
```

#### Removing with Animation

```javascript
async function animateAndRemove(element) {
  // Add animation class
  element.classList.add('fade-out');
  
  // Wait for animation
  await new Promise(resolve => {
    element.addEventListener('animationend', resolve, { once: true });
  });
  
  // Remove after animation
  element.remove();
}

// CSS: .fade-out { animation: fadeOut 0.3s; }
```

#### Form Field Removal

```javascript
// Remove form field and update FormData
const form = document.getElementById('myForm');
const field = form.querySelector('[name="optional"]');

// Remove from DOM
field.remove();

// FormData automatically excludes removed fields
const formData = new FormData(form);
console.log(formData.has('optional')); // false
```

### Browser Compatibility and Polyfills

#### remove() Polyfill

[Unverified] The `remove()` method was added in DOM4 and may not be available in older browsers (IE11 and below):

```javascript
// Polyfill for Element.prototype.remove()
if (!Element.prototype.remove) {
  Element.prototype.remove = function() {
    if (this.parentNode) {
      this.parentNode.removeChild(this);
    }
  };
}

// Also polyfill for other node types
if (!CharacterData.prototype.remove) {
  CharacterData.prototype.remove = function() {
    if (this.parentNode) {
      this.parentNode.removeChild(this);
    }
  };
}

if (!DocumentType.prototype.remove) {
  DocumentType.prototype.remove = function() {
    if (this.parentNode) {
      this.parentNode.removeChild(this);
    }
  };
}
```

#### removeChild Compatibility

`removeChild` has been supported since the earliest DOM implementations (IE5+, all modern browsers). No polyfill needed.

### Security Considerations

#### XSS Prevention During Removal

```javascript
// Removal itself doesn't introduce XSS
// But be careful with removed content
const userContent = document.getElementById('user-generated');
const removed = parent.removeChild(userContent);

// Don't directly insert removed content elsewhere without sanitization
// If content came from untrusted source
otherParent.appendChild(removed); // May contain malicious scripts

// Sanitize if needed
removed.innerHTML = DOMPurify.sanitize(removed.innerHTML);
otherParent.appendChild(removed);
```

#### Removing Sensitive Data

```javascript
// Remove elements containing sensitive data
const sensitiveFields = document.querySelectorAll('[data-sensitive]');
sensitiveFields.forEach(field => {
  // Clear content before removal
  field.textContent = '';
  field.value = '';
  field.remove();
});
```

### Error Handling Patterns

#### Safe removeChild with Validation

```javascript
function safeRemoveChild(parent, child) {
  if (!parent || !child) {
    console.warn('Parent or child is null');
    return null;
  }
  
  if (child.parentNode !== parent) {
    console.warn('Child is not a direct child of parent');
    return null;
  }
  
  try {
    return parent.removeChild(child);
  } catch (e) {
    console.error('Failed to remove child:', e);
    return null;
  }
}
```

#### Safe remove with Existence Check

```javascript
function safeRemove(element) {
  if (!element) {
    return false;
  }
  
  if (!element.parentNode) {
    console.warn('Element already removed or never added');
    return false;
  }
  
  element.remove();
  return true;
}
```

#### Batch Removal with Error Handling

```javascript
function removeElements(selector) {
  const elements = document.querySelectorAll(selector);
  const removed = [];
  const failed = [];
  
  elements.forEach(el => {
    try {
      el.remove();
      removed.push(el);
    } catch (e) {
      failed.push({ element: el, error: e });
    }
  });
  
  return { removed, failed };
}
```

### Alternatives and Modern Approaches

#### replaceChildren

```javascript
// Modern method to remove all children
const parent = document.getElementById('container');

// Old way
while (parent.firstChild) {
  parent.removeChild(parent.firstChild);
}

// New way
parent.replaceChildren(); // Removes all

// Or replace with new children in one operation
parent.replaceChildren(newChild1, newChild2, newChild3);
```

#### replaceWith

```javascript
// Remove and replace in one operation
const oldElement = document.getElementById('old');
const newElement = document.createElement('div');

// Old way
oldElement.parentNode.replaceChild(newElement, oldElement);

// New way
oldElement.replaceWith(newElement);

// Can replace with multiple nodes
oldElement.replaceWith(node1, node2, 'text node');
```

#### Detaching vs Removing

```javascript
// Detach for potential reuse (using removeChild)
const detached = parent.removeChild(child);
// Can reattach later: parent.appendChild(detached);

// Remove permanently (using remove)
child.remove();
// Can still reattach if reference maintained: parent.appendChild(child);

// Both preserve the node in memory if referenced
```

### Framework Integration Patterns

#### React Reconciliation

```javascript
// React handles removal automatically
function Component({ items }) {
  return (
    <ul>
      {items.map(item => (
        <li key={item.id}>{item.name}</li>
      ))}
    </ul>
  );
}

// When items array changes, React calls removeChild internally
// Don't manually remove React-managed elements
```

#### Vue Removal

```javascript
// Vue also manages DOM removal
<template>
  <div>
    <div v-for="item in items" :key="item.id">
      {{ item.name }}
    </div>
  </div>
</template>

// Don't mix manual removeChild with Vue's virtual DOM
```

#### Manual DOM Management in Frameworks

```javascript
// If you must manually manage DOM in framework
class Component {
  componentDidMount() {
    this.externalLibrary = new Library(this.containerRef);
  }
  
  componentWillUnmount() {
    // Clean up manually managed DOM
    const container = this.containerRef;
    while (container.firstChild) {
      container.removeChild(container.firstChild);
    }
    this.externalLibrary.destroy();
  }
}
```

### Performance Optimization Strategies

#### Batch DOM Operations

```javascript
// Inefficient: causes multiple reflows
items.forEach(item => {
  const el = document.getElementById(item.id);
  el.remove();
});

// Better: batch using DocumentFragment
const fragment = document.createDocumentFragment();
const parent = document.getElementById('container');

// Move elements to fragment (removes from parent)
items.forEach(item => {
  const el = document.getElementById(item.id);
  fragment.appendChild(el);
});

// Can manipulate fragment or discard
fragment.textContent = ''; // Clear all
```

#### Minimize Reflow with Detachment

```javascript
// Expensive: causes reflow on each removal
for (let i = 0; i < 1000; i++) {
  parent.children[0].remove();
}

// Better: detach parent first
const grandParent = parent.parentNode;
const nextSibling = parent.nextSibling;
const removedParent = grandParent.removeChild(parent);

// Modify detached tree (no reflows)
while (removedParent.firstChild) {
  removedParent.removeChild(removedParent.firstChild);
}

// Reattach if needed
grandParent.insertBefore(removedParent, nextSibling);
```

#### CSS Display None Before Removal

[Inference] Setting `display: none` before removing many children may reduce visual reflow impact, though the browser still processes the removals:

```javascript
// For large removal operations
const container = document.getElementById('large-container');
container.style.display = 'none';

// Remove children
while (container.firstChild) {
  container.removeChild(container.firstChild);
}

// Show empty container or remove it
container.style.display = '';
// or
container.remove();
```

---

