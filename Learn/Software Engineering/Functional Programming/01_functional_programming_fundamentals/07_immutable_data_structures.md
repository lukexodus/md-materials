## Immutable Data Structures


Immutable data structures are specialized implementations that efficiently support operations on immutable data through structural sharing and persistent data structure techniques.

### Persistent Data Structures

Persistent data structures preserve previous versions when modified, creating new versions that share most structure with the old version. This achieves O(log n) or better performance for most operations while maintaining immutability.

**Path copying** - Only the path from the root to the modified element is copied; unchanged subtrees are shared between versions.

**Structural sharing** - Multiple versions share the majority of their structure, making copies space-efficient.

**Performance characteristics** - Most operations run in O(log n) time rather than O(1) for mutable structures, but with practical constant factors that make them competitive.

### Common Immutable Data Structures

**Persistent vectors** - Array-like structures implemented as trees with high branching factors (typically 32), providing near-constant time access and updates.

```javascript
// Conceptual example using Immutable.js
const v1 = List([1, 2, 3]);
const v2 = v1.push(4);  // v1 unchanged, v2 shares structure
```

**Persistent hash maps** - Hash tables implemented as trees (hash array mapped tries) allowing efficient lookup, insertion, and deletion while preserving immutability.

**Persistent sets** - Similar to hash maps but storing only keys, supporting efficient membership testing and set operations.

**Persistent queues** - Efficient immutable queues using two lists (front and rear) to achieve amortized O(1) operations.

**Finger trees** - Versatile structures supporting efficient access at both ends and concatenation, useful for sequences, priority queues, and interval trees.

### Implementation Techniques

**Bit-partitioned hash trees** - Hash values are split into chunks to determine tree paths, providing balanced O(log n) performance regardless of key distribution.

**Relaxed radix balanced trees** - Generalization of persistent vectors allowing efficient concatenation and slicing operations.

**Copy-on-write** - Nodes are shared until modification, at which point only the modified node and its ancestors are copied.

### Libraries and Tools

**Immutable.js** - Comprehensive immutable collections library for JavaScript with List, Map, Set, and Record types.

**Immer** - Allows working with immutable state using mutable-style code through proxy-based copy-on-write.

**Mori** - ClojureScript persistent data structures compiled to JavaScript.

**Ramda** - Functional programming library with utilities for working with immutable data.

**TypeScript ReadOnly** - Type system features like `Readonly<T>` and `ReadonlyArray<T>` enforce immutability at compile time.

### Use Cases

**State management** - Redux, MobX, and similar libraries use immutable state to enable time-travel debugging, efficient change detection, and predictable updates.

**Undo/redo functionality** - Persistent data structures naturally support undo by maintaining references to previous versions.

**Concurrent programming** - Immutable structures eliminate race conditions and enable lock-free algorithms.

**Functional algorithms** - Many functional algorithms (like persistent queues for breadth-first search) rely on efficient immutable structures.

### Performance Optimization

**Transients** - Temporary mutable versions for batch operations that are converted back to immutable structures, providing O(1) operations during construction.

```javascript
// Conceptual example
const transient = vector.asTransient();
for (let i = 0; i < 1000; i++) {
  transient.push(i);  // O(1) mutable operation
}
const result = transient.toPersistent();  // Convert back
```

**Batch operations** - Group multiple changes into single operations to minimize structural copying overhead.

**Specialized structures** - Choose data structures based on access patterns (vectors for indexed access, maps for key-value, sets for membership).

**Key Points:**

- Persistent data structures achieve immutability without copying entire structures
- Structural sharing makes immutable operations practical for production use
- Most operations run in O(log n) time with small constant factors
- Libraries provide battle-tested implementations across many languages
- Transients and batch operations optimize performance-critical code paths

