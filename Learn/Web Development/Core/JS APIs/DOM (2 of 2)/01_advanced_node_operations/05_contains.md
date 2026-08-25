## contains()


The `contains()` method checks whether a node is a descendant of another node, including the node itself.

### Behavior

```javascript
node.contains(otherNode)
```

Returns `true` if:

- `otherNode` is a descendant of `node`
- `otherNode` is `node` itself
- Otherwise returns `false`

### Self-Comparison

```javascript
const element = document.getElementById('test');
element.contains(element); // true - node contains itself
```

### Practical Applications

```javascript
// Event delegation check
document.addEventListener('click', (e) => {
    const menu = document.getElementById('menu');
    if (!menu.contains(e.target)) {
        // Click was outside menu
        closeMenu();
    }
});

// Verify hierarchy before manipulation
function safeAppend(parent, child) {
    if (parent.contains(child)) {
        throw new Error('Cannot append ancestor to descendant');
    }
    parent.appendChild(child);
}
```

### Performance Characteristics

`contains()` is generally faster than `compareDocumentPosition()` for simple ancestry checks because it doesn't compute the full positional relationship.

