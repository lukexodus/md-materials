## isSameNode()


Checks if two references point to the exact same node object.

### Behavior

```javascript
const node1 = document.getElementById('test');
const node2 = document.getElementById('test');
const node3 = document.createElement('div');

node1.isSameNode(node2); // true - same DOM reference
node1.isSameNode(node3); // false - different nodes
```

### Deprecation Note

`isSameNode()` is largely redundant because strict equality (`===`) achieves the same result:

```javascript
node1.isSameNode(node2) === (node1 === node2) // always true
```

Modern code typically uses direct comparison:

```javascript
if (node1 === node2) {
    // Same node
}
```

