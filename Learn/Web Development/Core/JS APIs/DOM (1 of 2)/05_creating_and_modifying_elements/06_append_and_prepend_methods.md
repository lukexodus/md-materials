## append and prepend Methods


### Method Signatures and Return Value

```javascript
parentNode.append(...nodesOrStrings)
parentNode.prepend(...nodesOrStrings)
```

Both methods return `undefined`. They add nodes or text to a parent element.

### Basic Behavior

**append** adds content at the end (as last children):

```javascript
const div = document.querySelector('div');
div.append('Text'); // Adds text node at the end
```

**prepend** adds content at the beginning (as first children):

```javascript
const div = document.querySelector('div');
div.prepend('Text'); // Adds text node at the beginning
```

### Multiple Arguments

Both methods accept multiple arguments in a single call:

```javascript
const div = document.querySelector('div');
const span1 = document.createElement('span');
const span2 = document.createElement('span');

div.append(span1, 'Some text', span2);
// Adds all three in order: span1, text node, span2

div.prepend('First', span1, 'Second');
// Adds all three at the beginning in order
```

### String Handling

Strings are automatically converted to text nodes:

```javascript
const div = document.createElement('div');

div.append('Hello'); // Creates text node with "Hello"
div.append('<span>HTML</span>'); // Creates text node, NOT parsed as HTML

console.log(div.innerHTML); // "Hello<span>HTML</span>" (literal text)
```

### Node vs String Distinction

```javascript
const div = document.querySelector('div');

// String becomes text node
div.append('Text content');

// Element node is inserted
const span = document.createElement('span');
span.textContent = 'Text content';
div.append(span);

// These produce different results:
// First: plain text
// Second: <span>Text content</span>
```

### Node Relocation

Appending an existing node moves it (doesn't clone):

```javascript
<div id="a"><span id="item">Item</span></div>
<div id="b"></div>

const item = document.getElementById('item');
const divB = document.getElementById('b');

divB.append(item); // Moves item from div#a to div#b
```

After execution:

```html
<div id="a"></div>
<div id="b"><span id="item">Item</span></div>
```

### DocumentFragment Handling

Appending a DocumentFragment inserts its children and empties the fragment:

```javascript
const fragment = document.createDocumentFragment();
fragment.append(
    document.createElement('div'),
    document.createElement('span')
);

const container = document.querySelector('.container');
container.append(fragment);

console.log(fragment.children.length); // 0 (fragment is now empty)
console.log(container.children.length); // 2 (children were moved)
```

### Prepend Ordering

Multiple prepend calls add in reverse visual order:

```javascript
const div = document.querySelector('div');

div.prepend('First');
div.prepend('Second');
div.prepend('Third');

console.log(div.textContent); // "ThirdSecondFirst"
```

**[Inference]** Each prepend adds before all existing content, so the last prepend appears first.

Single prepend with multiple arguments maintains argument order:

```javascript
const div = document.querySelector('div');

div.prepend('First', 'Second', 'Third');

console.log(div.textContent); // "FirstSecondThird"
```

### Return Value Implications

Both methods return `undefined`, cannot be chained directly:

```javascript
const div = document.createElement('div');

// This doesn't work as expected:
div.append('Text').append('More'); // Error: cannot read append of undefined

// Must chain the element:
div.append('Text');
div.append('More');

// Or use method chaining on other operations:
document.body.append(
    Object.assign(document.createElement('div'), {
        textContent: 'Content'
    })
);
```

### Comparison with appendChild

**append vs appendChild:**

```javascript
const parent = document.querySelector('div');

// appendChild: single node only, returns the node
const child = document.createElement('span');
const returned = parent.appendChild(child);
console.log(returned === child); // true

// append: multiple nodes/strings, returns undefined
parent.append(child, 'text', document.createElement('div'));
```

Key differences:

- `appendChild` accepts one Node argument; `append` accepts multiple nodes/strings
- `appendChild` returns the appended node; `append` returns `undefined`
- `appendChild` doesn't handle strings; `append` converts strings to text nodes

### Comparison with insertAdjacentElement

```javascript
const reference = document.querySelector('.reference');

// Using append/prepend (parent perspective)
reference.parentElement.append(newElement);

// Using insertAdjacentElement (sibling perspective)
reference.insertAdjacentElement('afterend', newElement);

// prepend equivalent
reference.parentElement.prepend(newElement);
// vs
reference.insertAdjacentElement('afterbegin', newElement);
```

### Common Use Cases

**Building element structures:**

```javascript
const card = document.createElement('div');
card.className = 'card';

const title = document.createElement('h3');
title.textContent = 'Card Title';

const content = document.createElement('p');
content.textContent = 'Card content';

card.append(title, content);
document.body.append(card);
```

**Dynamic list construction:**

```javascript
const list = document.querySelector('ul');
const items = ['Apple', 'Banana', 'Cherry'];

items.forEach(item => {
    const li = document.createElement('li');
    li.textContent = item;
    list.append(li);
});
```

**Prepending notifications:**

```javascript
const notifications = document.querySelector('.notifications');

function addNotification(message) {
    const notification = document.createElement('div');
    notification.className = 'notification';
    notification.textContent = message;
    
    // New notifications appear at top
    notifications.prepend(notification);
}
```

**Bulk element insertion:**

```javascript
const container = document.querySelector('.container');
const fragment = document.createDocumentFragment();

// Build multiple elements
for (let i = 0; i < 100; i++) {
    const item = document.createElement('div');
    item.textContent = `Item ${i}`;
    fragment.append(item);
}

// Single reflow
container.append(fragment);
```

**Mixed content insertion:**

```javascript
const message = document.querySelector('.message');
const icon = document.createElement('i');
icon.className = 'icon-warning';

message.prepend(icon, ' Warning: ', document.createElement('strong'));
```

### Performance Considerations

**[Inference]** Using DocumentFragment with `append` for multiple elements reduces reflows:

```javascript
// Multiple reflows (less efficient)
for (let i = 0; i < 1000; i++) {
    const div = document.createElement('div');
    container.append(div);
}

// Single reflow (more efficient)
const fragment = document.createDocumentFragment();
for (let i = 0; i < 1000; i++) {
    const div = document.createElement('div');
    fragment.append(div);
}
container.append(fragment);
```

### Edge Cases

**Empty arguments:**

```javascript
const div = document.querySelector('div');

div.append(); // Does nothing
div.prepend(); // Does nothing
```

**Null and undefined:**

```javascript
const div = document.querySelector('div');

div.append(null); // Adds text node "null"
div.append(undefined); // Adds text node "undefined"
```

**Numbers and other primitives:**

```javascript
const div = document.querySelector('div');

div.append(123); // Adds text node "123"
div.append(true); // Adds text node "true"
div.append({}); // Adds text node "[object Object]"
```

**Circular references:**

```javascript
const parent = document.createElement('div');
const child = document.createElement('div');

parent.append(child);

// Cannot create circular structure
// child.append(parent); // Would throw HierarchyRequestError
```

### Browser Compatibility

Supported in all modern browsers. IE11 and older do not support these methods.

Polyfill for older browsers:

```javascript
// [Inference] Simplified polyfill concept
if (!Element.prototype.append) {
    Element.prototype.append = function(...nodes) {
        nodes.forEach(node => {
            if (typeof node === 'string') {
                this.appendChild(document.createTextNode(node));
            } else {
                this.appendChild(node);
            }
        });
    };
}
```

### Alternative Patterns

**Template literals with innerHTML (use cautiously):**

```javascript
// append/prepend (safe, no XSS risk with controlled data)
div.append(document.createElement('span'));

// innerHTML (potential XSS risk with user data)
div.innerHTML += '<span></span>'; // Also destroys event listeners
```

**Using insertBefore for prepend simulation:**

```javascript
// Modern prepend
parent.prepend(child);

// Legacy equivalent
parent.insertBefore(child, parent.firstChild);
```

---

