## Document Order Algorithms


### Determining Document Position

Document order follows these rules:

1. **Document node** comes first
2. **Element nodes** are ordered by their position in the tree (depth-first traversal)
3. **Attribute nodes** come after the element they belong to
4. **Text nodes** and other children follow their element
5. **Descendants** come before following siblings

### Tree Walking for Position

```javascript
function isNodeBefore(node1, node2) {
    const position = node1.compareDocumentPosition(node2);
    return (position & Node.DOCUMENT_POSITION_FOLLOWING) !== 0;
}

function getCommonAncestor(node1, node2) {
    const position = node1.compareDocumentPosition(node2);
    
    if (position & Node.DOCUMENT_POSITION_DISCONNECTED) {
        return null; // No common ancestor
    }
    
    if (position & Node.DOCUMENT_POSITION_CONTAINS) {
        return node1;
    }
    
    if (position & Node.DOCUMENT_POSITION_CONTAINED_BY) {
        return node2;
    }
    
    // Find common ancestor by traversing up
    let parent = node1.parentNode;
    while (parent) {
        if (parent.contains(node2)) {
            return parent;
        }
        parent = parent.parentNode;
    }
    
    return null;
}
```

