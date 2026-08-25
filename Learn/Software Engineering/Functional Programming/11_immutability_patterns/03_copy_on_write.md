## Copy-on-Write


Copy-on-write (COW) is an optimization strategy that delays copying until a write operation occurs. Multiple references can share the same data structure until one attempts modification, at which point a copy is created.

**Basic Concept**

The principle is lazy copying: share data until mutation is necessary, then copy only what's needed. This provides the safety of immutability with better performance characteristics.

```javascript
class COWArray {
  constructor(data = [], shared = false) {
    this._data = data;
    this._shared = shared;
  }
  
  // Read operations don't copy
  get(index) {
    return this._data[index];
  }
  
  // Write operations trigger copy if shared
  set(index, value) {
    if (this._shared) {
      this._data = [...this._data];
      this._shared = false;
    }
    const newData = [...this._data];
    newData[index] = value;
    return new COWArray(newData, false);
  }
  
  // Clone marks as shared for both references
  clone() {
    this._shared = true;
    return new COWArray(this._data, true);
  }
}
```

**Operating System Analogy**

Operating systems use COW for process forking. When a process forks, the parent and child initially share memory pages. Only when either process writes to a page is that page copied. This makes forking extremely efficient.

**Implementation Strategies**

**Reference Counting**: Track how many references exist to a structure. When count is 1, mutations can happen in-place. When count > 1, copy before mutating.

```javascript
class COWString {
  constructor(chars, refCount = { count: 1 }) {
    this._chars = chars;
    this._refCount = refCount;
  }
  
  clone() {
    this._refCount.count++;
    return new COWString(this._chars, this._refCount);
  }
  
  set(index, char) {
    if (this._refCount.count > 1) {
      // Multiple references exist, must copy
      this._refCount.count--;
      this._chars = [...this._chars];
      this._refCount = { count: 1 };
    }
    // Now safe to mutate
    this._chars[index] = char;
    return this;
  }
}
```

**Versioning**: Associate each structure with a version number. Operations check versions to determine if copying is needed.

```javascript
let globalVersion = 0;

class VersionedArray {
  constructor(data, version = globalVersion++) {
    this._data = data;
    this._version = version;
  }
  
  modify(fn) {
    // If versions match, we have exclusive access
    if (this._version === globalVersion - 1) {
      fn(this._data); // mutate in place
      return this;
    }
    // Otherwise, copy first
    const newData = [...this._data];
    fn(newData);
    return new VersionedArray(newData);
  }
}
```

**Persistent Data Structures**

Persistent data structures inherently use COW principles through structural sharing. Trees like Red-Black trees or Hash Array Mapped Tries (HAMTs) copy only the spine from root to modified leaf, sharing all other subtrees.

```javascript
// Conceptual HAMT node
class HAMTNode {
  constructor(children, isShared = false) {
    this.children = children;
    this.isShared = isShared;
  }
  
  update(key, value) {
    if (this.isShared) {
      // Copy this node and path upward
      const newChildren = { ...this.children };
      return new HAMTNode(newChildren, false).updateInternal(key, value);
    }
    return this.updateInternal(key, value);
  }
  
  updateInternal(key, value) {
    // Actual update logic
    this.children[key] = value;
    return this;
  }
  
  markShared() {
    this.isShared = true;
    return this;
  }
}
```

**Benefits**

- Reduced memory allocation when structures are frequently read but infrequently modified
- Better cache locality when data isn't copied unnecessarily
- Enables efficient snapshots or time-travel debugging
- Balances immutability benefits with performance

**Trade-offs**

- Added complexity in tracking sharing state
- Reference counting overhead or version tracking
- May delay detection of bugs that would surface immediately with eager copying
- Thread synchronization complexity in concurrent environments

**Practical Usage**

Modern libraries leverage COW extensively. Immer.js uses proxies to track access and applies COW automatically:

```javascript
import produce from 'immer';

const original = { users: [{ name: 'Alice' }] };

const updated = produce(original, draft => {
  // draft appears mutable but COW happens behind the scenes
  draft.users.push({ name: 'Bob' });
  draft.users[0].name = 'Alicia';
});

// original unchanged, updated contains modifications
// Only modified paths were copied
```

