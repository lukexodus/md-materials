## Performance Considerations


### Method Complexity

- **`contains()`**: O(depth) - traverses ancestor chain
- **`compareDocumentPosition()`**: O(depth) - may traverse to find common ancestor
- **`isEqualNode()`**: O(n) - deep structural comparison where n is total descendant count
- **`isSameNode()`**: O(1) - simple reference equality

### Optimization Strategies

```javascript
// Cache frequently accessed relationships
const ancestryCache = new WeakMap();

function cachedContains(parent, child) {
    let cache = ancestryCache.get(child);
    if (!cache) {
        cache = new Set();
        ancestryCache.set(child, cache);
    }
    
    if (cache.has(parent)) {
        return true;
    }
    
    const result = parent.contains(child);
    if (result) {
        cache.add(parent);
    }
    
    return result;
}
```

### Batch Comparisons

When comparing many nodes, minimize repeated traversals:

```javascript
function groupByAncestor(nodes, ancestor) {
    const contained = [];
    const external = [];
    
    for (const node of nodes) {
        if (ancestor.contains(node)) {
            contained.push(node);
        } else {
            external.push(node);
        }
    }
    
    return { contained, external };
}
```

