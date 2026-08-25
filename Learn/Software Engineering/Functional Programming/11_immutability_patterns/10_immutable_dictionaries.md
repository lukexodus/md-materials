## Immutable Dictionaries


Immutable dictionaries are key-value mappings that cannot be modified after creation. Operations that appear to add, remove, or update entries return new dictionary instances with the changes applied, leaving the original unchanged. These structures preserve lookup performance while providing immutability guarantees.

Many functional languages provide persistent data structures that use structural sharing to make immutable dictionaries efficient, copying only the modified portions while sharing unchanged parts between versions.

**Key Points:**

- All modification operations return new dictionaries
- Enables safe sharing between functions and threads
- Supports efficient implementation through persistent data structures and structural sharing
- Useful for configuration objects, caches, and state management
- Can be used as hash keys when deeply immutable

**Python example:**

```python
from types import MappingProxyType
from typing import Dict, Any

# Using MappingProxyType for read-only view
mutable_dict = {'a': 1, 'b': 2, 'c': 3}
immutable_dict = MappingProxyType(mutable_dict)

print(immutable_dict['a'])  # 1
# immutable_dict['a'] = 10  # TypeError

# Creating truly immutable dictionaries
class ImmutableDict:
    def __init__(self, data=None):
        self._data = dict(data) if data else {}
        self._hash = None
    
    def get(self, key, default=None):
        return self._data.get(key, default)
    
    def __getitem__(self, key):
        return self._data[key]
    
    def set(self, key, value):
        new_data = {**self._data, key: value}
        return ImmutableDict(new_data)
    
    def remove(self, key):
        new_data = {k: v for k, v in self._data.items() if k != key}
        return ImmutableDict(new_data)
    
    def update(self, other):
        new_data = {**self._data, **other}
        return ImmutableDict(new_data)
    
    def keys(self):
        return self._data.keys()
    
    def values(self):
        return self._data.values()
    
    def items(self):
        return self._data.items()
    
    def __len__(self):
        return len(self._data)
    
    def __contains__(self, key):
        return key in self._data
    
    def __repr__(self):
        return f"ImmutableDict({self._data})"
    
    def __hash__(self):
        if self._hash is None:
            self._hash = hash(tuple(sorted(self._data.items())))
        return self._hash

# Usage
config = ImmutableDict({'timeout': 5000, 'retries': 3})
updated = config.set('timeout', 10000)
with_more = updated.update({'endpoint': 'https://api.example.com', 'debug': True})

print(config)      # ImmutableDict({'timeout': 5000, 'retries': 3})
print(updated)     # ImmutableDict({'timeout': 10000, 'retries': 3})
print(with_more)   # ImmutableDict({'timeout': 10000, 'retries': 3, 'endpoint': '...', 'debug': True})
```

**JavaScript/TypeScript frozen objects:**

```javascript
// Shallow freeze
const config = Object.freeze({
    timeout: 5000,
    retries: 3,
    endpoint: 'https://api.example.com'
});

// config.timeout = 10000;  // Fails silently in non-strict mode, throws in strict mode

// Deep freeze helper
function deepFreeze(obj) {
    Object.freeze(obj);
    Object.getOwnPropertyNames(obj).forEach(prop => {
        if (obj[prop] !== null
            && (typeof obj[prop] === "object" || typeof obj[prop] === "function")
            && !Object.isFrozen(obj[prop])) {
            deepFreeze(obj[prop]);
        }
    });
    return obj;
}

const nestedConfig = deepFreeze({
    database: {
        host: 'localhost',
        port: 5432,
        credentials: {
            user: 'admin',
            password: 'secret'
        }
    }
});

// Immutable update helpers
const setIn = (obj, path, value) => {
    if (path.length === 0) return value;
    const [key, ...rest] = path;
    return {
        ...obj,
        [key]: setIn(obj[key] || {}, rest, value)
    };
};

const updateIn = (obj, path, fn) => {
    if (path.length === 0) return fn(obj);
    const [key, ...rest] = path;
    return {
        ...obj,
        [key]: updateIn(obj[key] || {}, rest, fn)
    };
};

const removeKey = (obj, key) => {
    const { [key]: removed, ...rest } = obj;
    return rest;
};

// Usage
const state = {
    users: {
        1: { name: 'Alice', score: 100 },
        2: { name: 'Bob', score: 85 }
    },
    settings: {
        theme: 'dark'
    }
};

const updated = setIn(state, ['users', 1, 'score'], 150);
const incremented = updateIn(state, ['users', 2, 'score'], s => s + 10);
const removed = updateIn(state, ['users'], users => removeKey(users, 2));

console.log(state.users[1].score);      // 100
console.log(updated.users[1].score);    // 150
console.log(incremented.users[2].score); // 95
```

**Using Immutable.js library:**

```javascript
import { Map, fromJS } from 'immutable';

// Creating immutable maps
const map1 = Map({ a: 1, b: 2, c: 3 });
const map2 = map1.set('b', 50);

console.log(map1.get('b'));  // 2
console.log(map2.get('b'));  // 50

// Nested structures
const nested = fromJS({
    users: {
        1: { name: 'Alice', score: 100 },
        2: { name: 'Bob', score: 85 }
    }
});

const updated = nested.setIn(['users', '1', 'score'], 150);
const incremented = nested.updateIn(['users', '2', 'score'], score => score + 10);

console.log(nested.getIn(['users', '1', 'score']));    // 100
console.log(updated.getIn(['users', '1', 'score']));   // 150

// Batch updates
const map3 = map1.withMutations(mutable => {
    mutable.set('a', 10);
    mutable.set('b', 20);
    mutable.set('c', 30);
});

// Merging
const merged = map1.merge({ d: 4, e: 5 });
const deepMerged = nested.mergeDeep({
    users: {
        1: { score: 110 },
        3: { name: 'Charlie', score: 95 }
    }
});
```

**Scala immutable maps:**

```scala
val map1 = Map("a" -> 1, "b" -> 2, "c" -> 3)
val map2 = map1 + ("d" -> 4)
val map3 = map2 - "a"
val map4 = map1.updated("b", 20)

println(map1)  // Map(a -> 1, b -> 2, c -> 3)
println(map2)  // Map(a -> 1, b -> 2, c -> 3, d -> 4)
println(map3)  // Map(b -> 2, c -> 3, d -> 4)
println(map4)  // Map(a -> 1, b -> 20, c -> 3)

// Nested updates
case class User(name: String, score: Int)

val users = Map(
  1 -> User("Alice", 100),
  2 -> User("Bob", 85)
)

val updated = users.updated(1, users(1).copy(score = 150))
```

**Persistent data structures for efficiency:**

```javascript
// Conceptual example of structural sharing
// Original: { a: 1, b: { c: 2, d: 3 }, e: 4 }
// Updated:  { a: 1, b: { c: 2, d: 5 }, e: 4 }
// Only the path to 'd' is copied, 'a' and 'e' are shared

class PersistentMap {
    constructor(root = null) {
        this._root = root;
        this._size = root ? root.size : 0;
    }
    
    get(key) {
        return this._root ? this._root.get(key) : undefined;
    }
    
    set(key, value) {
        const newRoot = this._root 
            ? this._root.set(key, value)
            : new Node(key, value);
        return new PersistentMap(newRoot);
    }
    
    // Implementation would use hash array mapped tries (HAMT)
    // or similar persistent data structure for efficiency
}
```

**Configuration management example:**

```python
class Config(ImmutableDict):
    def with_timeout(self, timeout):
        return self.set('timeout', timeout)
    
    def with_retries(self, retries):
        return self.set('retries', retries)
    
    def with_debug(self, debug=True):
        return self.set('debug', debug)

# Building configuration
base_config = Config({'timeout': 5000, 'retries': 3})
dev_config = base_config.with_debug(True).with_timeout(30000)
prod_config = base_config.with_retries(5)

# Each configuration is independent
print(base_config)  # Config({'timeout': 5000, 'retries': 3})
print(dev_config)   # Config({'timeout': 30000, 'retries': 3, 'debug': True})
print(prod_config)  # Config({'timeout': 5000, 'retries': 5})
```

**Considerations:**

- [Inference] Naive implementations create full copies on each update, which is inefficient for large dictionaries
- Persistent data structures with structural sharing provide O(log n) updates while sharing most data
- [Unverified] Libraries like Immutable.js and Pyrsistent use hash array mapped tries (HAMTs) for efficiency
- Deep freezing in JavaScript requires recursive traversal
- [Inference] Immutable dictionaries work well as configuration objects but may have overhead for high-frequency updates
- Can be used as dictionary keys or set elements when deeply immutable and hashable

---

