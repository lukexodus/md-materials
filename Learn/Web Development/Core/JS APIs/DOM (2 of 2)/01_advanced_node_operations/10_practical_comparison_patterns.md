## Practical Comparison Patterns


### Sorting Nodes by Document Order

```javascript
function sortNodesByDocumentOrder(nodes) {
    return Array.from(nodes).sort((a, b) => {
        const position = a.compareDocumentPosition(b);
        if (position & Node.DOCUMENT_POSITION_FOLLOWING) {
            return -1;
        }
        if (position & Node.DOCUMENT_POSITION_PRECEDING) {
            return 1;
        }
        return 0;
    });
}
```

### Checking Overlap Between Selections

```javascript
function rangesOverlap(range1, range2) {
    // Check if start of range2 is before end of range1
    const startComparison = range1.compareBoundaryPoints(
        Range.END_TO_START, 
        range2
    );
    
    // Check if end of range2 is after start of range1
    const endComparison = range1.compareBoundaryPoints(
        Range.START_TO_END,
        range2
    );
    
    return startComparison >= 0 && endComparison <= 0;
}
```

### Finding Node Relationships

```javascript
function getNodeRelationship(node1, node2) {
    const position = node1.compareDocumentPosition(node2);
    
    if (position & Node.DOCUMENT_POSITION_DISCONNECTED) {
        return 'disconnected';
    }
    if (position & Node.DOCUMENT_POSITION_CONTAINS) {
        return 'contains';
    }
    if (position & Node.DOCUMENT_POSITION_CONTAINED_BY) {
        return 'contained-by';
    }
    if (position & Node.DOCUMENT_POSITION_PRECEDING) {
        return 'precedes';
    }
    if (position & Node.DOCUMENT_POSITION_FOLLOWING) {
        return 'follows';
    }
    
    return 'same';
}
```

