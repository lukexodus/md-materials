## Sibling Nodes


### Node vs Element Sibling Properties

The DOM provides two pairs of sibling navigation properties: node-level properties that traverse all node types, and element-level properties that skip non-element nodes like text and comments.

**Node-level properties:**

- `node.nextSibling` - returns the next sibling node of any type
- `node.previousSibling` - returns the previous sibling node of any type

**Element-level properties:**

- `element.nextElementSibling` - returns the next sibling that is an Element
- `element.previousElementSibling` - returns the previous sibling that is an Element

All properties return `null` when no sibling exists in the specified direction.

### nextSibling and previousSibling

`node.nextSibling` returns the node immediately following the specified node in its parent's `childNodes` list. `node.previousSibling` returns the node immediately preceding it.

These properties traverse all node types including:

- Element nodes (nodeType 1)
- Text nodes (nodeType 3)
- Comment nodes (nodeType 8)
- Processing instruction nodes (nodeType 7)
- CDATA section nodes (nodeType 4)

The most common source of unexpected behavior is whitespace text nodes. HTML formatting creates text nodes containing only whitespace characters:

```html
<div>
  <span>First</span>
  <span>Second</span>
</div>
```

Between the two `<span>` elements exists a text node containing newline and spaces. `firstSpan.nextSibling` returns this text node, not the second span element.

When a node is the last child of its parent, `nextSibling` returns `null`. When a node is the first child, `previousSibling` returns `null`.

These properties are read-only and cannot be assigned to directly. Modifying sibling relationships requires DOM manipulation methods like `insertBefore()`, `appendChild()`, `removeChild()`, or `replaceChild()`.

### nextElementSibling and previousElementSibling

`element.nextElementSibling` returns the next sibling that is an Element node, automatically skipping text nodes, comment nodes, and other non-element nodes. `element.previousElementSibling` works identically in the reverse direction.

These properties only exist on Element nodes. Attempting to access them on non-element nodes (like text or comment nodes) results in `undefined`, as these properties don't exist on the base Node interface.

When no element sibling exists in the specified direction, these properties return `null`. This occurs when:

- The element is the last/first element child of its parent
- All remaining siblings in that direction are non-element nodes

These properties were introduced in the Element Traversal Specification to provide more intuitive sibling navigation without needing to manually filter node types. They're supported in all modern browsers (IE9+).

### Practical Usage Patterns

**Iterating through element siblings:**

```javascript
let element = firstElement;
while (element) {
  // Process element
  element = element.nextElementSibling;
}
```

**Iterating through all node siblings:**

```javascript
let node = firstNode;
while (node) {
  // Process node
  node = node.nextSibling;
}
```

**Counting element siblings:**

```javascript
let count = 0;
let sibling = element.nextElementSibling;
while (sibling) {
  count++;
  sibling = sibling.nextElementSibling;
}
```

**Finding specific sibling by condition:**

```javascript
let sibling = element.nextElementSibling;
while (sibling) {
  if (sibling.classList.contains('target')) {
    break;
  }
  sibling = sibling.nextElementSibling;
}
```

### Bidirectional Navigation

These properties enable bidirectional traversal of sibling lists. Combined with `parentNode`/`parentElement`, they form the fundamental tree navigation API:

- `node.parentNode` - move up
- `node.firstChild` / `node.lastChild` - move down to first/last child
- `node.nextSibling` / `node.previousSibling` - move horizontally through all nodes
- `element.firstElementChild` / `element.lastElementChild` - move down to first/last element child
- `element.nextElementSibling` / `element.previousElementSibling` - move horizontally through elements

### Performance Characteristics

[Inference] Sibling property access is typically O(1) as browsers maintain bidirectional linked lists for DOM nodes. The properties return direct references without traversal overhead.

Iterating through all siblings is O(n) where n is the number of siblings. Element sibling iteration may skip nodes but still has O(n) complexity relative to total nodes, not just element count.

Repeatedly accessing these properties in tight loops is generally efficient, but caching results when iterating multiple times over the same sibling list can reduce redundant property access.

### Whitespace Handling Strategies

When using `nextSibling`/`previousSibling`, several strategies handle whitespace text nodes:

**Strategy 1: Use element sibling properties instead**

```javascript
// Preferred for element-only navigation
const next = element.nextElementSibling;
```

**Strategy 2: Filter by nodeType**

```javascript
let node = element.nextSibling;
while (node && node.nodeType !== 1) {
  node = node.nextSibling;
}
// node is now null or next element sibling
```

**Strategy 3: Remove whitespace from source**

```html
<div><span>First</span><span>Second</span></div>
```

**Strategy 4: Normalize whitespace**

```javascript
parent.normalize(); // Merges adjacent text nodes
```

The `normalize()` method doesn't remove whitespace-only text nodes; it only merges adjacent text nodes. For element-only traversal, `nextElementSibling`/`previousElementSibling` provide the cleanest solution.

### Relationship to childNodes and children

Sibling properties navigate the same structures accessible via parent collection properties:

`element.childNodes` is a live NodeList containing all child nodes. Sibling properties link these nodes:

- `parent.childNodes[0]` is the first child
- `parent.childNodes[0].nextSibling === parent.childNodes[1]`
- `parent.childNodes[1].previousSibling === parent.childNodes[0]`

`element.children` is a live HTMLCollection containing element children. Element sibling properties link these:

- `parent.children[0]` is the first element child
- `parent.children[0].nextElementSibling === parent.children[1]`
- `parent.children[1].previousElementSibling === parent.children[0]`

### Null Checks and Safety

Since these properties return `null` when no sibling exists, conditional checks prevent errors:

```javascript
// Safe pattern
if (element.nextElementSibling) {
  element.nextElementSibling.classList.add('highlight');
}

// Optional chaining (modern JavaScript)
element.nextElementSibling?.classList.add('highlight');

// Chain traversal
const secondNext = element.nextElementSibling?.nextElementSibling;
```

Attempting to access properties on `null` results in TypeError. Always verify sibling existence before accessing nested properties.

### Dynamic DOM Modifications

Sibling properties reflect live DOM state. Adding, removing, or rearranging nodes immediately updates sibling relationships:

```javascript
const next = element.nextElementSibling;
element.parentNode.removeChild(element);
// next.previousElementSibling may now point to different element
```

When iterating through siblings while modifying the DOM, store references carefully:

```javascript
// Unsafe: removing nodes during iteration
let node = parent.firstChild;
while (node) {
  parent.removeChild(node); // Breaks iteration
  node = node.nextSibling; // node is now null
}

// Safe: store next reference before modification
let node = parent.firstChild;
while (node) {
  const next = node.nextSibling;
  parent.removeChild(node);
  node = next;
}
```

### DocumentFragment Behavior

Nodes within a DocumentFragment have sibling relationships before insertion into the main document:

```javascript
const fragment = document.createDocumentFragment();
const div1 = document.createElement('div');
const div2 = document.createElement('div');
fragment.appendChild(div1);
fragment.appendChild(div2);

div1.nextElementSibling === div2; // true
div2.previousElementSibling === div1; // true

// After insertion
document.body.appendChild(fragment);
// Sibling relationships now relative to document.body
```

The fragment itself doesn't participate in sibling relationships—only nodes within it do until insertion.

### Shadow DOM Boundaries

Sibling properties don't cross shadow DOM boundaries. Elements inside shadow roots only see siblings within the same shadow tree:

```javascript
const host = document.createElement('div');
const shadow = host.attachShadow({mode: 'open'});
const span1 = document.createElement('span');
const span2 = document.createElement('span');
shadow.appendChild(span1);
shadow.appendChild(span2);

span1.nextElementSibling === span2; // true

// Shadow content doesn't appear as siblings to light DOM
document.body.appendChild(host);
const outsideDiv = document.createElement('div');
document.body.appendChild(outsideDiv);

host.nextElementSibling === outsideDiv; // true
// span1 and span2 remain isolated inside shadow root
```

### Slotted Content

[Inference] When using slots in shadow DOM, slotted elements maintain their sibling relationships in the light DOM tree structure. The `assignedNodes()` and `assignedElements()` methods on HTMLSlotElement provide access to slotted content, but these aren't connected via sibling properties.

### Text Node Sibling Navigation

Text nodes support `nextSibling` and `previousSibling` but not element-specific properties:

```javascript
const textNode = document.createTextNode('Hello');
textNode.nextElementSibling; // undefined (property doesn't exist)
textNode.nextSibling; // Returns next sibling node if exists
```

Only Element nodes have `nextElementSibling` and `previousElementSibling` properties. The Node interface only defines `nextSibling` and `previousSibling`.

### Comparison with Node Iterators

TreeWalker and NodeIterator provide alternative traversal mechanisms with filtering capabilities:

```javascript
const walker = document.createTreeWalker(
  parent,
  NodeFilter.SHOW_ELEMENT,
  null
);

walker.currentNode = element;
const next = walker.nextSibling(); // Similar to nextElementSibling
```

TreeWalker offers more complex filtering options but involves more overhead than direct property access. For simple sibling navigation, direct properties are more efficient.

### Common Pitfalls

**Assuming contiguous elements:** Whitespace creates unexpected text nodes between elements in formatted HTML.

**Infinite loops:** Forgetting null checks when iterating leads to infinite loops when reaching sibling list ends.

**Stale references during modification:** Removing or moving nodes invalidates sibling references cached before the modification.

**Type confusion:** Mixing node-level and element-level properties creates logic errors when non-element nodes appear unexpectedly.

**Cross-boundary expectations:** [Inference] Attempting to traverse siblings across shadow DOM boundaries or document fragments without understanding their isolation models.

### Integration with Query Methods

Sibling properties complement but differ from query methods:

```javascript
// Sibling property: O(1), returns immediate sibling only
const next = element.nextElementSibling;

// Query method: O(n), searches descendants matching selector
const next = element.querySelector('.next');

// Finding next sibling matching selector requires manual iteration
let sibling = element.nextElementSibling;
while (sibling && !sibling.matches('.target')) {
  sibling = sibling.nextElementSibling;
}
```

No built-in method directly queries siblings. Combining sibling properties with `matches()` or other tests provides selector-based sibling finding.

### Readonly Nature and Immutability

All sibling properties are readonly attributes. Assignment attempts either fail silently (in non-strict mode) or throw TypeError (in strict mode):

```javascript
'use strict';
element.nextElementSibling = otherElement; // TypeError
```

Modifying sibling relationships requires DOM manipulation methods that explicitly restructure the tree.

---

