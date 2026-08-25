## isEqualNode()


Checks if two nodes are equivalent in structure and content, performing deep comparison.

### Comparison Criteria

Two nodes are equal if they have:

- Same node type
- Same node name (tag name for elements)
- Same local name, namespace URI, and prefix
- Same number of child nodes
- Equivalent attributes (same name-value pairs, order irrelevant)
- Equal child nodes (recursive comparison)

### Usage

```javascript
const div1 = document.createElement('div');
div1.className = 'test';
div1.textContent = 'Hello';

const div2 = document.createElement('div');
div2.className = 'test';
div2.textContent = 'Hello';

div1.isEqualNode(div2); // true - structurally identical

div2.textContent = 'World';
div1.isEqualNode(div2); // false - content differs
```

### Attribute Order Independence

```javascript
const el1 = document.createElement('input');
el1.setAttribute('type', 'text');
el1.setAttribute('name', 'username');

const el2 = document.createElement('input');
el2.setAttribute('name', 'username');
el2.setAttribute('type', 'text');

el1.isEqualNode(el2); // true - attribute order doesn't matter
```

### Deep Comparison Behavior

```javascript
const parent1 = document.createElement('div');
const child1 = document.createElement('span');
child1.textContent = 'test';
parent1.appendChild(child1);

const parent2 = document.createElement('div');
const child2 = document.createElement('span');
child2.textContent = 'test';
parent2.appendChild(child2);

parent1.isEqualNode(parent2); // true - deep equality
```

