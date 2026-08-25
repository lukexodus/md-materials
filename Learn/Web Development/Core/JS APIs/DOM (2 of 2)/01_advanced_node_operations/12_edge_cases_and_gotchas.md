## Edge Cases and Gotchas


### Document Fragments

Nodes in document fragments are disconnected from the main document:

```javascript
const fragment = document.createDocumentFragment();
const div = document.createElement('div');
fragment.appendChild(div);

const body = document.body;
const position = div.compareDocumentPosition(body);
position & Node.DOCUMENT_POSITION_DISCONNECTED; // true
```

### Shadow DOM Boundaries

Comparison methods respect shadow DOM encapsulation:

```javascript
const host = document.getElementById('shadow-host');
const shadow = host.attachShadow({ mode: 'open' });
const shadowChild = document.createElement('div');
shadow.appendChild(shadowChild);

const lightChild = document.createElement('div');
host.appendChild(lightChild);

// shadowChild and lightChild are in different trees
shadowChild.compareDocumentPosition(lightChild) 
    & Node.DOCUMENT_POSITION_DISCONNECTED; // true
```

### Attribute Node Comparisons

[Inference] Attribute nodes have special positioning relative to their owner element. Most modern APIs avoid direct attribute node manipulation.

### Cloned Node Equality

```javascript
const original = document.getElementById('test');
const clone = original.cloneNode(true);

original.isEqualNode(clone); // true - structurally identical
original.isSameNode(clone);  // false - different objects
original === clone;          // false
```

---

