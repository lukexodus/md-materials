## Immutability and Concurrency


Immutability eliminates entire classes of concurrency bugs by ensuring data cannot be modified after creation. When all data structures are immutable, multiple threads can safely read the same data simultaneously without locks, and race conditions become impossible.

**Why Immutability Enables Concurrency**

Mutable state requires synchronization mechanisms (locks, mutexes, semaphores) to prevent race conditions. With immutable data:

- Multiple readers never conflict
- No write-after-read or read-after-write hazards
- Thread-safe by default without explicit synchronization
- Values can be shared freely between threads

**Persistent Data Structures**

Persistent data structures share structure between versions, making copies efficient:

```javascript
// Naive copying is expensive
const addToArrayMutable = (arr, value) => {
  arr.push(value); // Mutates original
  return arr;
};

// Full copying is also expensive
const addToArrayCopy = (arr, value) => {
  return [...arr, value]; // O(n) copy
};

// Persistent structure shares data
class PersistentList {
  constructor(head, tail = null) {
    this.head = head;
    this.tail = tail;
    this.length = tail ? tail.length + 1 : 1;
  }

  prepend(value) {
    return new PersistentList(value, this); // O(1), shares tail
  }

  get(index) {
    if (index === 0) return this.head;
    if (!this.tail) throw new Error('Index out of bounds');
    return this.tail.get(index - 1);
  }
}

// Both versions coexist, sharing structure
const list1 = new PersistentList(3, new PersistentList(2, new PersistentList(1)));
const list2 = list1.prepend(4); // Shares nodes with list1
```

**Structural Sharing in Trees**

Trees enable efficient immutable updates through path copying:

```javascript
class TreeNode {
  constructor(value, left = null, right = null) {
    this.value = value;
    this.left = left;
    this.right = right;
  }

  insert(value) {
    if (value < this.value) {
      return new TreeNode(
        this.value,
        this.left ? this.left.insert(value) : new TreeNode(value),
        this.right // Shared, not copied
      );
    } else {
      return new TreeNode(
        this.value,
        this.left, // Shared, not copied
        this.right ? this.right.insert(value) : new TreeNode(value)
      );
    }
  }
}

// Only the path from root to new node is copied
// Logarithmic complexity instead of linear
```

**Copy-on-Write Semantics**

Implement efficient updates by deferring copies until mutation is needed:

```javascript
class CopyOnWrite {
  constructor(data, version = 0) {
    this.data = data;
    this.version = version;
    this.dirty = false;
  }

  read() {
    return this.data;
  }

  update(fn) {
    const newData = fn(this.data);
    return new CopyOnWrite(newData, this.version + 1);
  }
}

// Multiple readers share the same data
const original = new CopyOnWrite({ count: 0 });
const updated = original.update(d => ({ count: d.count + 1 }));
// Both versions exist independently
```

**Parallel Map-Reduce with Immutability**

Process collections in parallel without locks:

```javascript
const parallelMap = async (array, fn, chunkSize = 1000) => {
  const chunks = [];
  for (let i = 0; i < array.length; i += chunkSize) {
    chunks.push(array.slice(i, i + chunkSize));
  }

  const results = await Promise.all(
    chunks.map(chunk => 
      // Each worker processes immutable chunk
      Promise.resolve(chunk.map(fn))
    )
  );

  return results.flat();
};

// Safe to run concurrently - no shared mutable state
const doubled = await parallelMap([1, 2, 3, 4, 5, 6, 7, 8], x => x * 2);
```

**Immutable State Machines**

Model state transitions without mutation:

```javascript
const createStateMachine = (initialState, transitions) => {
  const transition = (state, event) => {
    const handler = transitions[state]?.[event];
    if (!handler) return state;
    return handler(state);
  };

  return {
    currentState: initialState,
    send: function(event) {
      const newState = transition(this.currentState, event);
      return createStateMachine(newState, transitions);
    }
  };
};

const doorTransitions = {
  closed: {
    OPEN: () => 'open'
  },
  open: {
    CLOSE: () => 'closed'
  }
};

let door = createStateMachine('closed', doorTransitions);
door = door.send('OPEN'); // Returns new machine in 'open' state
```

**Snapshot Isolation**

Create consistent snapshots for concurrent reads:

```javascript
class VersionedStore {
  constructor() {
    this.versions = [{ data: new Map(), timestamp: Date.now() }];
  }

  snapshot() {
    const latest = this.versions[this.versions.length - 1];
    return {
      data: latest.data,
      timestamp: latest.timestamp
    };
  }

  write(key, value) {
    const latest = this.versions[this.versions.length - 1];
    const newData = new Map(latest.data);
    newData.set(key, value);
    
    this.versions.push({
      data: newData,
      timestamp: Date.now()
    });
  }

  readAtVersion(timestamp) {
    return this.versions
      .filter(v => v.timestamp <= timestamp)
      .slice(-1)[0]?.data;
  }
}

// Multiple readers can snapshot independently
const store = new VersionedStore();
const snapshot1 = store.snapshot();
store.write('key', 'value');
const snapshot2 = store.snapshot();
// snapshot1 and snapshot2 are independent and consistent
```

**Transactional Updates**

Compose multiple updates atomically:

```javascript
const transaction = (state, ...updates) => {
  return updates.reduce((acc, update) => update(acc), state);
};

const increment = (state) => ({ ...state, count: state.count + 1 });
const setFlag = (state) => ({ ...state, flag: true });
const addItem = (item) => (state) => ({
  ...state,
  items: [...state.items, item]
});

const initialState = { count: 0, flag: false, items: [] };
const newState = transaction(
  initialState,
  increment,
  increment,
  setFlag,
  addItem('x')
);
// All updates applied atomically, no intermediate states visible
```

**Lock-Free Data Sharing**

Share immutable data across threads without synchronization:

```javascript
// Web Worker example
// main.js
const data = Object.freeze({
  values: [1, 2, 3, 4, 5],
  config: { multiplier: 2 }
});

const worker = new Worker('worker.js');
worker.postMessage(data); // Safe - data is immutable

worker.onmessage = (e) => {
  // Receive new immutable result
  const result = e.data;
};

// worker.js
self.onmessage = (e) => {
  const data = e.data;
  // Safe to read concurrently
  const result = data.values.map(v => v * data.config.multiplier);
  self.postMessage(Object.freeze({ result }));
};
```

**Key Points**

- Immutable data eliminates race conditions and data corruption
- Persistent data structures enable efficient copying through structural sharing
- Multiple readers can access immutable data simultaneously without locks
- Copy-on-write defers expensive copies until necessary
- Snapshots provide consistent views for long-running operations
- Transactions compose multiple updates into atomic operations
- Lock-free sharing becomes trivial with immutability

