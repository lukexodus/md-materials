## replaceChild


### Syntax and Return Value

`replaceChild()` replaces a child node within a parent node with a new node. This method is called on the parent element and returns the replaced (removed) node.

```javascript
let replacedNode = parentNode.replaceChild(newChild, oldChild);
```

**Parameters:**

- `newChild` - The new node to insert
- `oldChild` - The existing child node to be replaced

**Returns:** The replaced node (oldChild)

### Basic Usage

```javascript
<div id="parent">
  <p id="old">Old paragraph</p>
</div>

const parent = document.getElementById('parent');
const oldPara = document.getElementById('old');
const newPara = document.createElement('p');
newPara.textContent = 'New paragraph';

const replaced = parent.replaceChild(newPara, oldPara);
// replaced === oldPara (the removed node)

// DOM now:
// <div id="parent">
//   <p>New paragraph</p>
// </div>
```

### Parent-Child Relationship Requirement

The oldChild **must** be a direct child of the parent node calling `replaceChild`:

```javascript
<div id="parent">
  <div id="wrapper">
    <p id="target">Text</p>
  </div>
</div>

const parent = document.getElementById('parent');
const target = document.getElementById('target');
const newNode = document.createElement('span');

// ❌ WRONG - target is not a direct child of parent
parent.replaceChild(newNode, target); // DOMException: NotFoundError

// ✓ CORRECT - use the direct parent
const wrapper = document.getElementById('wrapper');
wrapper.replaceChild(newNode, target); // Works

// Or access via parentNode
target.parentNode.replaceChild(newNode, target); // Works
```

### Replacing with Existing Nodes

When replacing with a node that already exists in the DOM, that node is **moved**, not cloned:

```javascript
<div id="container1">
  <p id="para1">Paragraph 1</p>
</div>
<div id="container2">
  <p id="para2">Paragraph 2</p>
  <p id="para3">Paragraph 3</p>
</div>

const container2 = document.getElementById('container2');
const para1 = document.getElementById('para1');
const para2 = document.getElementById('para2');

// Move para1 from container1 to container2, replacing para2
container2.replaceChild(para1, para2);

// Result:
// <div id="container1"></div> (empty - para1 moved)
// <div id="container2">
//   <p id="para1">Paragraph 1</p>
//   <p id="para3">Paragraph 3</p>
// </div>
```

To avoid moving, clone first:

```javascript
container2.replaceChild(para1.cloneNode(true), para2);
// para1 remains in container1, copy replaces para2
```

### Replacing with Document Fragments

When replacing with a DocumentFragment, all fragment children are inserted and the fragment becomes empty:

```javascript
<ul id="list">
  <li id="old">Old item</li>
</ul>

const list = document.getElementById('list');
const oldItem = document.getElementById('old');
const fragment = document.createDocumentFragment();

// Add multiple items to fragment
for (let i = 1; i <= 3; i++) {
  const li = document.createElement('li');
  li.textContent = `Item ${i}`;
  fragment.appendChild(li);
}

list.replaceChild(fragment, oldItem);

// Result:
// <ul id="list">
//   <li>Item 1</li>
//   <li>Item 2</li>
//   <li>Item 3</li>
// </ul>

// fragment is now empty
fragment.childNodes.length; // 0
```

### Return Value Usage

The returned node is detached but still fully functional:

```javascript
const parent = document.getElementById('parent');
const oldNode = document.getElementById('old');
const newNode = document.createElement('div');

const removed = parent.replaceChild(newNode, oldNode);

// removed is detached but intact
removed.textContent; // Original content preserved
removed.children; // Child nodes preserved
removed.attributes; // Attributes preserved

// Can be reinserted elsewhere
document.getElementById('other-container').appendChild(removed);

// Can be modified
removed.classList.add('archived');
removed.dataset.replaced = 'true';

// Can be cloned
const copy = removed.cloneNode(true);
```

### Error Conditions

Several conditions throw DOMException:

```javascript
// 1. oldChild not found (NotFoundError)
parent.replaceChild(newNode, nonExistentNode);
// DOMException: Failed to execute 'replaceChild' on 'Node': 
// The node to be replaced is not a child of this node.

// 2. oldChild not a direct child (NotFoundError)
grandparent.replaceChild(newNode, grandchild);
// DOMException: NotFoundError

// 3. Invalid newChild type (HierarchyRequestError)
const textNode = document.createTextNode('text');
element.replaceChild(document, textNode);
// DOMException: The new child element contains the parent.

// 4. Circular hierarchy (HierarchyRequestError)
parent.replaceChild(parent, child);
// DOMException: Cannot replace a node with one of its ancestors
```

### Replacing Different Node Types

Works with various node types:

```javascript
const parent = document.getElementById('parent');
const oldElement = parent.firstChild;

// Replace with element
const newElement = document.createElement('span');
parent.replaceChild(newElement, oldElement);

// Replace with text node
const textNode = document.createTextNode('Plain text');
parent.replaceChild(textNode, newElement);

// Replace with comment
const comment = document.createComment('This is a comment');
parent.replaceChild(comment, textNode);

// Replace with document fragment (multiple nodes)
const fragment = document.createDocumentFragment();
fragment.append('Text 1', document.createElement('br'), 'Text 2');
parent.replaceChild(fragment, comment);
```

### Event Listeners and Data Preservation

Event listeners on the replaced node remain attached:

```javascript
const oldButton = document.getElementById('old-btn');

// Add event listener
oldButton.addEventListener('click', () => {
  console.log('Still works!');
});

// Replace in DOM
const newButton = document.createElement('button');
parent.replaceChild(newButton, oldButton);

// oldButton listener still works if reinserted
someContainer.appendChild(oldButton);
oldButton.click(); // "Still works!"

// Event listeners on ancestors are NOT affected
parent.addEventListener('click', (e) => {
  // Still fires for clicks on newButton
});
```

Custom data/properties also persist:

```javascript
oldNode.customData = { foo: 'bar' };
oldNode.myFunction = () => console.log('test');

const removed = parent.replaceChild(newNode, oldNode);

removed.customData; // { foo: 'bar' }
removed.myFunction(); // "test"
```

### Position-Relative Replacement

Replace nodes based on position:

```javascript
// Replace first child
parent.replaceChild(newNode, parent.firstChild);

// Replace last child
parent.replaceChild(newNode, parent.lastChild);

// Replace nth child
const nthChild = parent.children[2]; // Zero-indexed
parent.replaceChild(newNode, nthChild);

// Replace next sibling of a node
const reference = document.getElementById('reference');
reference.parentNode.replaceChild(newNode, reference.nextSibling);

// Replace based on condition
Array.from(parent.children).forEach(child => {
  if (child.classList.contains('old-style')) {
    const newChild = document.createElement('div');
    newChild.textContent = child.textContent;
    newChild.classList.add('new-style');
    parent.replaceChild(newChild, child);
  }
});
```

### Replacing During Iteration

Be careful when replacing during iteration:

```javascript
const parent = document.getElementById('parent');

// ❌ WRONG - modifying collection while iterating
for (let i = 0; i < parent.children.length; i++) {
  const newNode = document.createElement('div');
  parent.replaceChild(newNode, parent.children[i]);
  // collection changes during iteration, causes issues
}

// ✓ CORRECT - iterate backwards
for (let i = parent.children.length - 1; i >= 0; i--) {
  const newNode = document.createElement('div');
  parent.replaceChild(newNode, parent.children[i]);
}

// ✓ CORRECT - convert to array first
Array.from(parent.children).forEach(child => {
  const newNode = document.createElement('div');
  parent.replaceChild(newNode, child);
});

// ✓ CORRECT - use while loop
while (parent.firstChild) {
  const newNode = document.createElement('div');
  parent.replaceChild(newNode, parent.firstChild);
}
```

### MutationObserver Integration

`replaceChild` triggers mutation observations:

```javascript
const observer = new MutationObserver(mutations => {
  mutations.forEach(mutation => {
    console.log('Type:', mutation.type);
    console.log('Added:', mutation.addedNodes);
    console.log('Removed:', mutation.removedNodes);
  });
});

observer.observe(parent, {
  childList: true,
  subtree: false
});

parent.replaceChild(newNode, oldNode);

// Triggers observer with:
// - mutation.type: "childList"
// - mutation.addedNodes: [newNode]
// - mutation.removedNodes: [oldNode]
```

### Performance Considerations

```javascript
// INEFFICIENT - multiple reflows for each replacement
children.forEach(child => {
  const newNode = createNewNode();
  parent.replaceChild(newNode, child);
}); // Each replacement triggers reflow

// BETTER - batch with DocumentFragment
const fragment = document.createDocumentFragment();
children.forEach(child => {
  const newNode = createNewNode();
  fragment.appendChild(newNode);
});
// Clear and append all at once
parent.textContent = '';
parent.appendChild(fragment);

// BETTER - detach parent first (if possible)
const parentParent = parent.parentNode;
const nextSibling = parent.nextSibling;
parentParent.removeChild(parent);

// Perform all replacements
children.forEach(child => {
  parent.replaceChild(createNewNode(), child);
});

// Reattach
parentParent.insertBefore(parent, nextSibling);
```

### Legacy Pattern Comparison

`replaceChild` is the older DOM API; modern alternatives often exist:

```javascript
// Traditional replaceChild
parent.replaceChild(newNode, oldNode);

// Modern alternative (see replaceWith section)
oldNode.replaceWith(newNode);

// Both achieve same result, but:
// - replaceChild requires parent reference
// - replaceChild returns removed node
// - replaceWith is called on the node itself
// - replaceWith accepts multiple nodes/strings
```

---

