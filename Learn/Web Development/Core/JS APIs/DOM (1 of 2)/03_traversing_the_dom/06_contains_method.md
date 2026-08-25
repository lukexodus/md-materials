## contains Method


### Method Signature and Return Value

```javascript
node.contains(otherNode)
```

Returns a boolean: `true` if `otherNode` is a descendant of `node` or is `node` itself, `false` otherwise.

### Self-Comparison Behavior

A node contains itself:

```javascript
const div = document.querySelector('div');
console.log(div.contains(div)); // true
```

### Descendant Detection

Checks the entire descendant tree, not just direct children:

```javascript
<div id="parent">
  <div id="child">
    <span id="grandchild">Text</span>
  </div>
</div>

const parent = document.getElementById('parent');
const grandchild = document.getElementById('grandchild');

console.log(parent.contains(grandchild)); // true (deeply nested)
```

### Null and Undefined Handling

```javascript
const element = document.querySelector('div');

console.log(element.contains(null));      // false
console.log(element.contains(undefined)); // false
```

### Non-Element Nodes

Works with all node types, including text nodes and comment nodes:

```javascript
const div = document.querySelector('div');
const textNode = div.firstChild; // Text node

console.log(div.contains(textNode)); // true

const commentNode = document.createComment('comment');
div.appendChild(commentNode);
console.log(div.contains(commentNode)); // true
```

### Detached Nodes

Returns `false` for nodes not in the same tree:

```javascript
const div1 = document.createElement('div');
const div2 = document.createElement('div');
const span = document.createElement('span');

div1.appendChild(span);

console.log(div1.contains(span)); // true
console.log(div2.contains(span)); // false (different trees)
console.log(document.body.contains(div1)); // false (not in DOM)
```

### Document and DocumentFragment

Works with `document` and `DocumentFragment` nodes:

```javascript
const element = document.querySelector('div');
console.log(document.contains(element)); // true (if in DOM)

const fragment = document.createDocumentFragment();
const span = document.createElement('span');
fragment.appendChild(span);
console.log(fragment.contains(span)); // true
```

### Performance Characteristics

**[Inference]** `contains()` performs a tree traversal operation. For deeply nested structures with many nodes, this could have performance implications if called repeatedly. **[Unverified]** The exact implementation varies by browser, but modern browsers likely optimize this with caching or tree structure metadata.

### Common Use Cases

**Event delegation validation:**

```javascript
const container = document.getElementById('container');

document.addEventListener('click', (e) => {
    if (container.contains(e.target)) {
        console.log('Clicked inside container');
    }
});
```

**Modal/dropdown close detection:**

```javascript
const dropdown = document.querySelector('.dropdown');

document.addEventListener('click', (e) => {
    if (!dropdown.contains(e.target)) {
        dropdown.classList.remove('open');
    }
});
```

**Form validation scope:**

```javascript
const form = document.querySelector('form');
const invalidFields = document.querySelectorAll('.invalid');

invalidFields.forEach(field => {
    if (form.contains(field)) {
        console.log('Invalid field found in form');
    }
});
```

**Drag and drop boundaries:**

```javascript
const dropZone = document.getElementById('drop-zone');

element.addEventListener('dragend', (e) => {
    if (dropZone.contains(e.target)) {
        console.log('Dropped inside zone');
    }
});
```

### Comparison with Alternatives

**vs compareDocumentPosition:**

```javascript
const parent = document.getElementById('parent');
const child = document.getElementById('child');

// Using contains (simpler)
parent.contains(child); // true

// Using compareDocumentPosition (more detailed)
const position = parent.compareDocumentPosition(child);
const isContained = position & Node.DOCUMENT_POSITION_CONTAINED_BY;
```

**[Inference]** `contains()` is simpler for basic containment checks; `compareDocumentPosition()` provides more detailed relationship information (preceding, following, etc.).

**vs closest:**

```javascript
const child = document.querySelector('.child');
const parent = document.querySelector('.parent');

// contains: parent perspective (does parent contain child?)
parent.contains(child); // true

// closest: child perspective (is parent an ancestor of child?)
child.closest('.parent'); // returns parent element or null
```

**vs matches:**

```javascript
const element = document.querySelector('div');

// contains: hierarchical relationship
parent.contains(element);

// matches: CSS selector match
element.matches('.some-class');
```

### Edge Cases

**Shadow DOM boundaries:**

**[Unverified]** Behavior with Shadow DOM encapsulation:

```javascript
const host = document.querySelector('.shadow-host');
const shadowRoot = host.shadowRoot;
const shadowChild = shadowRoot.querySelector('.shadow-child');

// [Inference] Regular contains cannot cross shadow boundaries
console.log(host.contains(shadowChild)); // Likely false

// Must check within shadow root
console.log(shadowRoot.contains(shadowChild)); // true
```

**Iframe boundaries:**

```javascript
const iframe = document.querySelector('iframe');
const iframeContent = iframe.contentDocument.body;

// contains does not cross iframe boundaries
console.log(document.body.contains(iframeContent)); // false
console.log(iframe.contentDocument.contains(iframeContent)); // true
```

**Node removal during check:**

**[Inference]** If a node is removed from the DOM between obtaining a reference and calling `contains()`, the result reflects the current state:

```javascript
const parent = document.querySelector('.parent');
const child = document.querySelector('.child');

const contained = parent.contains(child); // true

child.remove();

const stillContained = parent.contains(child); // false
```

### Browser Compatibility

Supported in all modern browsers and IE9+. Part of the DOM Level 4 specification.

### Type Checking

**[Inference]** Passing non-Node objects may cause errors:

```javascript
const element = document.querySelector('div');

element.contains('string'); // May throw TypeError
element.contains({}); // May throw TypeError
element.contains(123); // May throw TypeError
```

Always ensure the argument is a valid Node object when the source is uncertain.

---

