## Copying Data Structures


Copying data structures is fundamental to maintaining immutability. When you need to modify data, you create a new version rather than mutating the original. This ensures that existing references remain unchanged and prevents unintended side effects.

**Basic Copying Approaches**

The simplest approach is creating a new structure with modified values. For arrays, methods like `slice()`, `concat()`, or the spread operator create copies. For objects, `Object.assign()` or the spread operator serve this purpose.

```javascript
// Array copying
const original = [1, 2, 3];
const copy = [...original, 4]; // [1, 2, 3, 4]
// original remains [1, 2, 3]

// Object copying
const person = { name: 'Alice', age: 30 };
const updated = { ...person, age: 31 };
// person remains { name: 'Alice', age: 30 }
```

**Structural Sharing**

Efficient immutable data structures use structural sharing, where unchanged portions of a structure are shared between old and new versions. This reduces memory overhead and improves performance. Persistent data structures like those in Clojure or implemented by libraries like Immutable.js use tree-based structures where only the path from root to the modified node is copied.

```javascript
// Conceptual example of structural sharing
// When updating tree[2][1], only nodes on path are copied
const tree = [[1, 2], [3, 4], [5, 6]];
const newTree = [
  tree[0],           // shared reference
  tree[1],           // shared reference
  [...tree[2]]       // new copy with changes
];
```

**Builder Patterns**

For complex structures requiring multiple updates, builder patterns accumulate changes in a mutable working copy, then produce an immutable result. This avoids creating intermediate immutable versions for each change.

```javascript
class ImmutableListBuilder {
  constructor(list = []) {
    this._working = [...list];
  }
  
  add(item) {
    this._working.push(item);
    return this;
  }
  
  build() {
    return Object.freeze([...this._working]);
  }
}

const list = new ImmutableListBuilder()
  .add(1)
  .add(2)
  .add(3)
  .build();
```

