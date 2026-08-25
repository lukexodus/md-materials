## insertBefore, insertAdjacentElement


### insertBefore

#### Method Signature and Behavior

```javascript
parentNode.insertBefore(newNode, referenceNode)
```

Inserts `newNode` before `referenceNode` as a child of `parentNode`. Returns the inserted node.

**Parameters:**

- `newNode`: The node to insert
- `referenceNode`: The node before which `newNode` is inserted. If `null`, `newNode` is inserted at the end (equivalent to `appendChild`)

**Return value:** The inserted `newNode`

```javascript
const parent = document.getElementById('parent');
const newElement = document.createElement('div');
const referenceElement = document.getElementById('reference');

// Insert newElement before referenceElement
parent.insertBefore(newElement, referenceElement);

// Returns the inserted node
const inserted = parent.insertBefore(newElement, referenceElement);
console.log(inserted === newElement); // true
```

#### Null Reference Node Behavior

When `referenceNode` is `null`, the node is appended to the end:

```javascript
const parent = document.getElementById('parent');
const newElement = document.createElement('div');

// These are equivalent
parent.insertBefore(newElement, null);
parent.appendChild(newElement);
```

This behavior is useful for conditional insertion logic:

```javascript
function insertAtPosition(parent, newNode, insertAtEnd) {
  const reference = insertAtEnd ? null : parent.firstChild;
  parent.insertBefore(newNode, reference);
}
```

#### Moving Existing Nodes

If `newNode` is already in the DOM, `insertBefore` **moves** it rather than cloning:

```javascript
const parent = document.getElementById('parent');
const existingNode = document.getElementById('existing');
const reference = document.getElementById('reference');

// Moves existingNode from its current location
parent.insertBefore(existingNode, reference);

// Original location is now empty
// No need to remove from old location first
```

**Important:** The node is automatically removed from its previous parent:

```javascript
const div1 = document.getElementById('div1');
const div2 = document.getElementById('div2');
const element = document.getElementById('element');

// element is child of div1
console.log(element.parentNode === div1); // true

// Move to div2
div2.insertBefore(element, div2.firstChild);

// Now child of div2, automatically removed from div1
console.log(element.parentNode === div2); // true
```

#### Reference Node Must Be Child of Parent

The `referenceNode` must be a direct child of `parentNode`, or an error is thrown:

```javascript
const parent = document.getElementById('parent');
const grandchild = parent.firstChild.firstChild;
const newNode = document.createElement('div');

// ERROR: grandchild is not a direct child of parent
try {
  parent.insertBefore(newNode, grandchild);
} catch (e) {
  console.log(e); // NotFoundError
}

// Correct: use the direct child
const directChild = parent.firstChild;
parent.insertBefore(newNode, directChild);
```

#### Common Use Cases

**Insert at beginning:**

```javascript
const parent = document.getElementById('list');
const newItem = document.createElement('li');

// Insert at the start
parent.insertBefore(newItem, parent.firstChild);
```

**Insert at specific position:**

```javascript
function insertAtIndex(parent, newNode, index) {
  const children = parent.children;
  
  if (index >= children.length) {
    parent.appendChild(newNode);
  } else {
    parent.insertBefore(newNode, children[index]);
  }
}

// Insert as third child (index 2)
insertAtIndex(parent, newElement, 2);
```

**Insert before matching element:**

```javascript
const parent = document.getElementById('list');
const newItem = document.createElement('li');
newItem.textContent = 'New Item';

// Find first item with data-priority > 5 and insert before it
const children = Array.from(parent.children);
const reference = children.find(child => 
  parseInt(child.dataset.priority) > 5
);

parent.insertBefore(newItem, reference || null);
```

**Sorting/reordering elements:**

```javascript
const parent = document.getElementById('list');
const items = Array.from(parent.children);

// Sort by data attribute
items.sort((a, b) => 
  parseInt(a.dataset.order) - parseInt(b.dataset.order)
);

// Reinsert in sorted order
items.forEach(item => parent.appendChild(item));

// Or using insertBefore to be explicit
items.forEach((item, index) => {
  if (index === 0) {
    parent.insertBefore(item, parent.firstChild);
  } else {
    parent.insertBefore(item, items[index - 1].nextSibling);
  }
});
```

#### DocumentFragment Optimization

When inserting multiple nodes, use `DocumentFragment` to minimize reflows:

```javascript
// Inefficient: causes multiple reflows
for (let i = 0; i < 100; i++) {
  const li = document.createElement('li');
  li.textContent = `Item ${i}`;
  list.insertBefore(li, list.firstChild);
}

// Efficient: single reflow
const fragment = document.createDocumentFragment();
const items = [];

for (let i = 0; i < 100; i++) {
  const li = document.createElement('li');
  li.textContent = `Item ${i}`;
  items.push(li);
}

// Add in reverse to maintain order when inserting at start
items.reverse().forEach(item => fragment.appendChild(item));
list.insertBefore(fragment, list.firstChild);
```

#### Error Conditions

**HierarchyRequestError:**

```javascript
const parent = document.createElement('div');
const child = document.createElement('span');

// ERROR: Can't insert parent into its own descendant
try {
  child.insertBefore(parent, null);
  parent.appendChild(child); // Now child contains parent
  parent.insertBefore(child, null); // Would create cycle
} catch (e) {
  console.log(e.name); // HierarchyRequestError
}
```

**NotFoundError:**

```javascript
const parent1 = document.createElement('div');
const parent2 = document.createElement('div');
const reference = document.createElement('span');
const newNode = document.createElement('p');

parent2.appendChild(reference);

// ERROR: reference is not a child of parent1
try {
  parent1.insertBefore(newNode, reference);
} catch (e) {
  console.log(e.name); // NotFoundError
}
```

#### Text Nodes and Comments

`insertBefore` works with all node types, not just elements:

```javascript
const parent = document.getElementById('parent');
const reference = parent.firstChild;

// Insert text node
const textNode = document.createTextNode('Hello ');
parent.insertBefore(textNode, reference);

// Insert comment node
const comment = document.createComment('This is a comment');
parent.insertBefore(comment, reference);

// Insert document fragment
const fragment = document.createDocumentFragment();
fragment.appendChild(document.createElement('span'));
parent.insertBefore(fragment, reference);
```

### insertAdjacentElement

#### Method Signature and Behavior

```javascript
element.insertAdjacentElement(position, newElement)
```

Inserts `newElement` at the specified position relative to `element`. Returns the inserted element, or `null` if insertion failed.

**Parameters:**

- `position`: String specifying where to insert (see below)
- `newElement`: The element to insert

**Return value:** The inserted element, or `null` on failure

#### Position Values

Four possible position values:

```javascript
const target = document.getElementById('target');
const newElement = document.createElement('div');

// 'beforebegin': Before the target element itself
target.insertAdjacentElement('beforebegin', newElement);
// <div></div><target>...</target>

// 'afterbegin': Inside target, before its first child
target.insertAdjacentElement('afterbegin', newElement);
// <target><div></div>...existing children...</target>

// 'beforeend': Inside target, after its last child
target.insertAdjacentElement('beforeend', newElement);
// <target>...existing children...<div></div></target>

// 'afterend': After the target element itself
target.insertAdjacentElement('afterend', newElement);
// <target>...</target><div></div>
```

**Visual representation:**

```
<!-- beforebegin -->
<target>
  <!-- afterbegin -->
  existing content
  <!-- beforeend -->
</target>
<!-- afterend -->
```

#### Position Values: Case Sensitivity

[Unverified] The position string is case-insensitive in most modern browsers, but using lowercase is the standard convention and recommended for compatibility:

```javascript
// Standard (recommended)
element.insertAdjacentElement('beforebegin', newEl);

// May work but non-standard
element.insertAdjacentElement('BeforeBegin', newEl);
element.insertAdjacentElement('BEFOREBEGIN', newEl);
```

#### Return Value and Failure Cases

Returns the inserted element on success, `null` on failure:

```javascript
const target = document.getElementById('target');
const newElement = document.createElement('div');

// Success
const result = target.insertAdjacentElement('beforeend', newElement);
console.log(result === newElement); // true

// Failure: invalid position
const failed = target.insertAdjacentElement('invalid', newElement);
console.log(failed); // null

// Failure: 'beforebegin' or 'afterend' on element without parent
const orphan = document.createElement('div');
const result2 = orphan.insertAdjacentElement('beforebegin', newElement);
console.log(result2); // null
```

#### Parent Requirement for beforebegin/afterend

`'beforebegin'` and `'afterend'` require the target element to have a parent:

```javascript
const orphan = document.createElement('div');
const newElement = document.createElement('span');

// Returns null - orphan has no parent
const result1 = orphan.insertAdjacentElement('beforebegin', newElement);
console.log(result1); // null

const result2 = orphan.insertAdjacentElement('afterend', newElement);
console.log(result2); // null

// These work fine - they insert inside the element
const result3 = orphan.insertAdjacentElement('afterbegin', newElement);
console.log(result3 === newElement); // true
```

**Document root limitations:**

```javascript
const html = document.documentElement;
const newElement = document.createElement('div');

// May fail or have unexpected behavior
const result = html.insertAdjacentElement('beforebegin', newElement);
// Can't insert before <html> in valid document structure
```

#### Moving Existing Elements

Like `insertBefore`, if the element already exists in the DOM, it is moved:

```javascript
const container1 = document.getElementById('container1');
const container2 = document.getElementById('container2');
const element = document.getElementById('movable');

// Currently in container1
console.log(element.parentNode === container1); // true

// Move to container2
container2.insertAdjacentElement('beforeend', element);

// Now in container2, removed from container1
console.log(element.parentNode === container2); // true
```

#### Comparison with insertBefore

`insertAdjacentElement` provides more intuitive positioning in some cases:

```javascript
const target = document.getElementById('target');
const newElement = document.createElement('div');

// Using insertAdjacentElement
target.insertAdjacentElement('afterend', newElement);

// Equivalent with insertBefore (more complex)
if (target.nextSibling) {
  target.parentNode.insertBefore(newElement, target.nextSibling);
} else {
  target.parentNode.appendChild(newElement);
}

// Using insertAdjacentElement
target.insertAdjacentElement('beforebegin', newElement);

// Equivalent with insertBefore
target.parentNode.insertBefore(newElement, target);
```

#### Common Use Cases

**Insert sibling elements:**

```javascript
const listItem = document.querySelector('li.active');
const newItem = document.createElement('li');
newItem.textContent = 'New Item';

// Insert right after the active item
listItem.insertAdjacentElement('afterend', newItem);
```

**Wrap element with new parent:**

```javascript
function wrapElement(element, wrapper) {
  element.insertAdjacentElement('beforebegin', wrapper);
  wrapper.appendChild(element);
}

const paragraph = document.querySelector('p');
const div = document.createElement('div');
div.className = 'wrapper';

wrapElement(paragraph, div);
// <div class="wrapper"><p>...</p></div>
```

**Insert at start vs end of container:**

```javascript
const container = document.getElementById('container');
const first = document.createElement('div');
const last = document.createElement('div');

// Add to beginning
container.insertAdjacentElement('afterbegin', first);

// Add to end
container.insertAdjacentElement('beforeend', last);
```

**Build toolbar around element:**

```javascript
const editor = document.getElementById('editor');
const toolbar = document.createElement('div');
const footer = document.createElement('div');

toolbar.className = 'toolbar';
footer.className = 'footer';

// Add toolbar above
editor.insertAdjacentElement('beforebegin', toolbar);

// Add footer below
editor.insertAdjacentElement('afterend', footer);
```

#### Related Methods: insertAdjacentHTML and insertAdjacentText

**insertAdjacentHTML** - Parses HTML string and inserts:

```javascript
const target = document.getElementById('target');

// Insert HTML (parses string as HTML)
target.insertAdjacentHTML('beforeend', '<p>New paragraph</p>');

// More flexible but XSS risk with user input
const userInput = '<script>alert("XSS")</script>';
target.insertAdjacentHTML('beforeend', userInput); // Dangerous!
```

**insertAdjacentText** - Inserts text (safe for user input):

```javascript
const target = document.getElementById('target');

// Insert text safely (no HTML parsing)
target.insertAdjacentText('beforeend', '<script>Not executed</script>');
// Displays literally: <script>Not executed</script>

// Safe for user input
const userInput = '<img src=x onerror="alert()">';
target.insertAdjacentText('beforeend', userInput); // Safe - treated as text
```

**Comparison:**

```javascript
const container = document.getElementById('container');
const element = document.createElement('span');
element.textContent = 'Element';

// insertAdjacentElement - inserts DOM element
container.insertAdjacentElement('beforeend', element);

// insertAdjacentHTML - parses and inserts HTML
container.insertAdjacentHTML('beforeend', '<span>HTML</span>');

// insertAdjacentText - inserts text node
container.insertAdjacentText('beforeend', 'Text');
```

#### Performance Considerations

[Inference] `insertAdjacentElement` is generally faster than `insertAdjacentHTML` when working with pre-created elements, as it avoids HTML parsing overhead:

```javascript
// Faster - no parsing
const div = document.createElement('div');
div.className = 'item';
container.insertAdjacentElement('beforeend', div);

// Slower - invokes HTML parser
container.insertAdjacentHTML('beforeend', '<div class="item"></div>');
```

**Batch insertions:**

```javascript
// Poor: multiple DOM mutations
for (let i = 0; i < 100; i++) {
  const div = document.createElement('div');
  container.insertAdjacentElement('beforeend', div);
}

// Better: use DocumentFragment
const fragment = document.createDocumentFragment();
for (let i = 0; i < 100; i++) {
  const div = document.createElement('div');
  fragment.appendChild(div);
}
container.insertAdjacentElement('beforeend', fragment);
```

### Comparison: insertBefore vs insertAdjacentElement

|Feature|insertBefore|insertAdjacentElement|
|---|---|---|
|Called on|Parent node|Target element|
|Position control|Before reference child|4 position options|
|Sibling insertion|Requires parent reference|Direct on target|
|Inside insertion|Possible with proper reference|Intuitive (afterbegin/beforeend)|
|Return value|Inserted node|Inserted element or null|
|null reference behavior|Appends to end|N/A|
|Parent requirement|Always|Only for beforebegin/afterend|
|API age|DOM Level 1 (oldest)|DOM Level 4 (newer)|
|Browser support|Universal (IE5+)|Modern (IE11+ partial, full in Edge+)|

### Decision Guide: When to Use Each

**Use insertBefore when:**

- You have a specific reference node to insert before
- You need maximum browser compatibility
- You're working with non-element nodes (text, comments)
- You need null-reference-appends behavior
- You're implementing low-level DOM manipulation libraries

**Use insertAdjacentElement when:**

- You want to insert relative to an element (not necessarily as its child)
- You need to insert siblings without accessing parent
- Position strings ('afterend', 'beforebegin') are more readable for your use case
- You only work with element nodes
- Modern browser support is sufficient

### Common Patterns and Idioms

**Insert before first matching child:**

```javascript
// Using insertBefore
function insertBeforeMatching(parent, newNode, selector) {
  const reference = parent.querySelector(selector);
  parent.insertBefore(newNode, reference);
}

// Using insertAdjacentElement
function insertBeforeMatching(target, newElement) {
  const reference = target.querySelector('.reference');
  if (reference) {
    reference.insertAdjacentElement('beforebegin', newElement);
  }
}
```

**Prepend multiple elements efficiently:**

```javascript
// Using insertBefore with fragment
const fragment = document.createDocumentFragment();
elements.forEach(el => fragment.appendChild(el));
parent.insertBefore(fragment, parent.firstChild);

// Using insertAdjacentElement (one at a time, less efficient)
elements.reverse().forEach(el => {
  parent.insertAdjacentElement('afterbegin', el);
});
```

**Insert sorted into list:**

```javascript
function insertSorted(parent, newElement, compareFn) {
  const children = Array.from(parent.children);
  const insertIndex = children.findIndex(child => 
    compareFn(newElement, child) < 0
  );
  
  if (insertIndex === -1) {
    parent.appendChild(newElement);
  } else {
    parent.insertBefore(newElement, children[insertIndex]);
  }
}

// Usage
insertSorted(list, newItem, (a, b) => 
  parseInt(a.dataset.value) - parseInt(b.dataset.value)
);
```

### Common Pitfalls

**Reference node must be direct child:**

```javascript
const parent = document.getElementById('parent');
const grandchild = parent.querySelector('.deep-nested');
const newNode = document.createElement('div');

// ERROR if grandchild is not a direct child
parent.insertBefore(newNode, grandchild); // NotFoundError
```

**Orphaned element with beforebegin/afterend:**

```javascript
const orphan = document.createElement('div');
const newElement = document.createElement('span');

// Returns null, silently fails
orphan.insertAdjacentElement('beforebegin', newElement);

// Always check return value when using beforebegin/afterend
const result = orphan.insertAdjacentElement('afterend', newElement);
if (!result) {
  console.log('Insertion failed - element has no parent');
}
```

**Forgetting that elements move, not clone:**

```javascript
const element = document.getElementById('movable');
const container1 = document.getElementById('container1');
const container2 = document.getElementById('container2');

// Move to container1
container1.appendChild(element);

// Move to container2 (removes from container1!)
container2.insertAdjacentElement('beforeend', element);

// If you need to clone, use cloneNode
const clone = element.cloneNode(true);
container2.insertAdjacentElement('beforeend', clone);
```

**Position string typos:**

```javascript
// Returns null silently
const result = element.insertAdjacentElement('beforeEnd', newEl); // Wrong case
const result2 = element.insertAdjacentElement('before-end', newEl); // Wrong format

// Always check return value or use constants
const POSITIONS = {
  BEFORE_BEGIN: 'beforebegin',
  AFTER_BEGIN: 'afterbegin',
  BEFORE_END: 'beforeend',
  AFTER_END: 'afterend'
};

element.insertAdjacentElement(POSITIONS.BEFORE_END, newEl);
```

### Browser Compatibility Notes

**insertBefore:** Universal support since DOM Level 1 (IE5+, all modern browsers)

**insertAdjacentElement:**

- Fully supported in modern browsers (Chrome 54+, Firefox 48+, Safari 10+, Edge 17+)
- Partial support in IE11 (some edge cases may differ)
- No support in IE10 and below

For maximum compatibility with older browsers when using position-based insertion:

```javascript
// Polyfill for older browsers
if (!Element.prototype.insertAdjacentElement) {
  Element.prototype.insertAdjacentElement = function(position, element) {
    switch(position.toLowerCase()) {
      case 'beforebegin':
        this.parentNode && this.parentNode.insertBefore(element, this);
        break;
      case 'afterbegin':
        this.insertBefore(element, this.firstChild);
        break;
      case 'beforeend':
        this.appendChild(element);
        break;
      case 'afterend':
        this.parentNode && this.parentNode.insertBefore(element, this.nextSibling);
        break;
    }
    return element;
  };
}
```

---

