## Immutable Objects


Immutable objects are data structures whose state cannot be modified after creation. Any operation that appears to modify the object actually returns a new object with the updated values, leaving the original unchanged. This guarantees referential transparency and eliminates an entire class of bugs related to shared mutable state.

The core principle is that once an object is constructed, all its properties remain constant throughout its lifetime. Modifications are expressed as transformations that produce new objects rather than mutations that alter existing ones.

**Key Points:**

- Eliminates side effects from state changes, making code more predictable
- Enables safe sharing of data between functions without defensive copying
- Simplifies reasoning about program behavior—values never change unexpectedly
- Facilitates concurrent programming by removing race conditions on shared data
- Enables structural sharing optimizations in persistent data structures

**Example:**

```javascript
// Mutable approach (avoid)
class MutablePoint {
  constructor(x, y) {
    this.x = x;
    this.y = y;
  }
  
  move(dx, dy) {
    this.x += dx;
    this.y += dy;
    return this;
  }
}

const p1 = new MutablePoint(0, 0);
const p2 = p1;
p1.move(5, 5);
console.log(p2); // { x: 5, y: 5 } - unexpected mutation!

// Immutable approach
class ImmutablePoint {
  constructor(x, y) {
    this._x = x;
    this._y = y;
    Object.freeze(this);
  }
  
  get x() { return this._x; }
  get y() { return this._y; }
  
  move(dx, dy) {
    return new ImmutablePoint(this._x + dx, this._y + dy);
  }
  
  distance(other) {
    const dx = this._x - other.x;
    const dy = this._y - other.y;
    return Math.sqrt(dx * dx + dy * dy);
  }
}

const p1 = new ImmutablePoint(0, 0);
const p2 = p1.move(5, 5);
console.log(p1); // { x: 0, y: 0 } - unchanged
console.log(p2); // { x: 5, y: 5 } - new object
```

**Implementing immutability with nested objects:**

```javascript
class ImmutableUser {
  constructor(name, address, preferences) {
    this._name = name;
    this._address = Object.freeze({ ...address });
    this._preferences = Object.freeze({ ...preferences });
    Object.freeze(this);
  }
  
  get name() { return this._name; }
  get address() { return this._address; }
  get preferences() { return this._preferences; }
  
  withName(newName) {
    return new ImmutableUser(newName, this._address, this._preferences);
  }
  
  withAddress(newAddress) {
    return new ImmutableUser(this._name, newAddress, this._preferences);
  }
  
  updatePreference(key, value) {
    return new ImmutableUser(
      this._name,
      this._address,
      { ...this._preferences, [key]: value }
    );
  }
}

const user = new ImmutableUser(
  'Alice',
  { city: 'NYC', zip: '10001' },
  { theme: 'dark', notifications: true }
);

const updated = user.updatePreference('theme', 'light');
console.log(user.preferences.theme); // 'dark'
console.log(updated.preferences.theme); // 'light'
```

**Builder pattern for complex immutable objects:**

```javascript
class ImmutableConfig {
  constructor(props) {
    Object.entries(props).forEach(([key, value]) => {
      this[`_${key}`] = value;
      Object.defineProperty(this, key, {
        get() { return this[`_${key}`]; },
        enumerable: true
      });
    });
    Object.freeze(this);
  }
  
  static builder() {
    return new ConfigBuilder();
  }
}

class ConfigBuilder {
  constructor(base = {}) {
    this._props = { ...base };
  }
  
  timeout(value) {
    return new ConfigBuilder({ ...this._props, timeout: value });
  }
  
  retries(value) {
    return new ConfigBuilder({ ...this._props, retries: value });
  }
  
  endpoint(value) {
    return new ConfigBuilder({ ...this._props, endpoint: value });
  }
  
  build() {
    return new ImmutableConfig(this._props);
  }
}

const config = ImmutableConfig.builder()
  .timeout(5000)
  .retries(3)
  .endpoint('https://api.example.com')
  .build();
```

**Lens pattern for deep updates:**

```javascript
// Helper for immutable deep updates
const setIn = (obj, path, value) => {
  if (path.length === 0) return value;
  
  const [head, ...rest] = path;
  const oldValue = obj[head];
  
  return {
    ...obj,
    [head]: setIn(oldValue || {}, rest, value)
  };
};

const updateIn = (obj, path, fn) => {
  if (path.length === 0) return fn(obj);
  
  const [head, ...rest] = path;
  
  return {
    ...obj,
    [head]: updateIn(obj[head] || {}, rest, fn)
  };
};

const state = {
  user: {
    profile: {
      name: 'Alice',
      settings: {
        theme: 'dark'
      }
    }
  }
};

const newState = setIn(state, ['user', 'profile', 'settings', 'theme'], 'light');
const incremented = updateIn(state, ['user', 'profile', 'loginCount'], (n = 0) => n + 1);
```

**Considerations:**

- Creates new objects for each modification, which has memory allocation overhead
- [Inference] Performance cost is typically negligible for small objects but can matter for large structures or high-frequency updates
- Requires discipline to maintain—mixing mutable and immutable patterns causes confusion
- Deep freezing nested objects requires recursive freezing
- [Unverified] Some persistent data structure libraries use structural sharing to optimize memory usage

