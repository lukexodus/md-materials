## compareDocumentPosition()


The `compareDocumentPosition()` method returns a bitmask indicating the relative position of a node compared to another node.

### Bitmask Values

```javascript
Node.DOCUMENT_POSITION_DISCONNECTED = 1           // 0x01
Node.DOCUMENT_POSITION_PRECEDING = 2              // 0x02
Node.DOCUMENT_POSITION_FOLLOWING = 4              // 0x04
Node.DOCUMENT_POSITION_CONTAINS = 8               // 0x08
Node.DOCUMENT_POSITION_CONTAINED_BY = 16          // 0x10
Node.DOCUMENT_POSITION_IMPLEMENTATION_SPECIFIC = 32 // 0x20
```

### Return Value Interpretation

The method returns a number that is the sum of applicable flags:

- **1 (DISCONNECTED)**: Nodes are in different documents or one is detached
- **2 (PRECEDING)**: The compared node comes before the reference node in document order
- **4 (FOLLOWING)**: The compared node comes after the reference node
- **8 (CONTAINS)**: The compared node contains the reference node
- **16 (CONTAINED_BY)**: The compared node is contained by the reference node
- **32 (IMPLEMENTATION_SPECIFIC)**: For private use in specific implementations

### Usage Patterns

```javascript
const parent = document.getElementById('parent');
const child = document.getElementById('child');
const sibling = document.getElementById('sibling');

// Check if child is contained by parent
const position = child.compareDocumentPosition(parent);
if (position & Node.DOCUMENT_POSITION_CONTAINS) {
    // parent contains child
}

// Check document order
if (position & Node.DOCUMENT_POSITION_PRECEDING) {
    // parent comes before child
}

// Check if nodes are in same document
if (position & Node.DOCUMENT_POSITION_DISCONNECTED) {
    // nodes are in different documents
}
```

### Multiple Flags

Multiple flags can be set simultaneously. Common combinations:

- **10 (2 + 8)**: Node precedes AND contains
- **20 (4 + 16)**: Node follows AND is contained by

```javascript
const outer = document.querySelector('.outer');
const inner = document.querySelector('.inner');

// If inner is inside outer and comes after in source
const pos = outer.compareDocumentPosition(inner);
// pos might be 20 (FOLLOWING + CONTAINED_BY)
```

