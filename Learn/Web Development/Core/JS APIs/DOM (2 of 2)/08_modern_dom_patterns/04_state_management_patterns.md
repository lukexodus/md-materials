## State Management Patterns


### Primitive State Patterns

#### Direct DOM Manipulation

The most basic pattern involves storing state directly in DOM properties and attributes. State reads occur through property access (`element.value`, `element.checked`) and writes through direct assignment. This creates tight coupling between state and view, making state difficult to track across the application.

```javascript
// State lives in DOM
input.value = 'current state';
const state = input.value;
```

The pattern breaks down when multiple views depend on the same state or when state changes need to propagate to disconnected parts of the interface. No central source of truth exists.

#### Global Variable State

State stored in global or module-scoped variables provides a single source of truth but lacks structure for managing updates or notifying dependent views.

```javascript
let appState = { count: 0, user: null };

function increment() {
  appState.count++;
  updateView(); // Manual synchronization required
}
```

The primary issue is manual synchronization—every state mutation requires explicit view update calls. Missing an update call creates inconsistency between state and UI. Tracking which components depend on which state becomes implicit and error-prone.

### Observer Pattern (Pub/Sub)

The observer pattern decouples state mutations from view updates through a subscription mechanism. Components subscribe to state changes and receive notifications when mutations occur.

```javascript
class Observable {
  constructor(initialState) {
    this.state = initialState;
    this.listeners = [];
  }
  
  subscribe(listener) {
    this.listeners.push(listener);
    return () => {
      this.listeners = this.listeners.filter(l => l !== listener);
    };
  }
  
  setState(newState) {
    this.state = { ...this.state, ...newState };
    this.listeners.forEach(listener => listener(this.state));
  }
  
  getState() {
    return this.state;
  }
}
```

This pattern enables one-to-many relationships where a single state change notifies all subscribers. Subscribers don't need knowledge of other subscribers, reducing coupling.

**Granular subscriptions** improve performance by allowing components to subscribe to specific state slices:

```javascript
class StateManager {
  constructor(initialState) {
    this.state = initialState;
    this.listeners = new Map(); // key -> Set of listeners
  }
  
  subscribe(key, listener) {
    if (!this.listeners.has(key)) {
      this.listeners.set(key, new Set());
    }
    this.listeners.get(key).add(listener);
    
    return () => this.listeners.get(key).delete(listener);
  }
  
  setState(key, value) {
    this.state[key] = value;
    if (this.listeners.has(key)) {
      this.listeners.get(key).forEach(fn => fn(value));
    }
  }
}
```

### Reactive State (Proxy-Based)

Modern JavaScript Proxies enable automatic dependency tracking and reactive updates without explicit subscription calls. The proxy intercepts property access and mutations.

```javascript
function createReactive(target, onChange) {
  return new Proxy(target, {
    get(obj, prop) {
      // Track which properties are accessed
      return obj[prop];
    },
    set(obj, prop, value) {
      obj[prop] = value;
      onChange(prop, value);
      return true;
    }
  });
}

const state = createReactive({ count: 0 }, (prop, value) => {
  console.log(`${prop} changed to ${value}`);
  updateView();
});

state.count++; // Automatically triggers onChange
```

**Nested reactivity** requires recursive proxy wrapping:

```javascript
function deepReactive(target, onChange) {
  const handler = {
    get(obj, prop) {
      const value = obj[prop];
      if (typeof value === 'object' && value !== null) {
        return new Proxy(value, handler);
      }
      return value;
    },
    set(obj, prop, value) {
      obj[prop] = value;
      onChange([prop], value); // Path tracking needed for nested updates
      return true;
    }
  };
  
  return new Proxy(target, handler);
}
```

Proxy-based reactivity eliminates boilerplate subscription code but adds overhead to every property access. Performance degrades with deeply nested objects accessed frequently.

### Unidirectional Data Flow (Flux Pattern)

Flux architecture enforces a single direction for data flow: Actions → Dispatcher → Store → View. This eliminates circular dependencies and makes state changes predictable.

```javascript
class Store {
  constructor(reducer, initialState) {
    this.state = initialState;
    this.reducer = reducer;
    this.listeners = [];
  }
  
  dispatch(action) {
    this.state = this.reducer(this.state, action);
    this.listeners.forEach(listener => listener(this.state));
  }
  
  subscribe(listener) {
    this.listeners.push(listener);
    return () => {
      this.listeners = this.listeners.filter(l => l !== listener);
    };
  }
  
  getState() {
    return this.state;
  }
}

function reducer(state, action) {
  switch (action.type) {
    case 'INCREMENT':
      return { ...state, count: state.count + 1 };
    case 'SET_USER':
      return { ...state, user: action.payload };
    default:
      return state;
  }
}

const store = new Store(reducer, { count: 0, user: null });
```

**Action creators** encapsulate action construction:

```javascript
const actions = {
  increment: () => ({ type: 'INCREMENT' }),
  setUser: (user) => ({ type: 'SET_USER', payload: user })
};

store.dispatch(actions.increment());
```

The pattern enforces immutability—reducers must return new state objects rather than mutating existing state. This enables time-travel debugging and simplifies change detection through reference equality checks.

**Middleware** intercepts actions between dispatch and reducer:

```javascript
function createStore(reducer, initialState, middleware = []) {
  let state = initialState;
  const listeners = [];
  
  let dispatch = (action) => {
    state = reducer(state, action);
    listeners.forEach(l => l(state));
  };
  
  // Wrap dispatch with middleware
  middleware.forEach(mw => {
    dispatch = mw({ getState, dispatch })(dispatch);
  });
  
  function getState() { return state; }
  function subscribe(listener) {
    listeners.push(listener);
    return () => listeners.splice(listeners.indexOf(listener), 1);
  }
  
  return { dispatch, getState, subscribe };
}

// Logger middleware
const logger = store => next => action => {
  console.log('dispatching', action);
  const result = next(action);
  console.log('next state', store.getState());
  return result;
};
```

### Selector Pattern

Selectors are functions that extract and compute derived state from the store. They encapsulate state shape knowledge and enable memoization.

```javascript
const selectors = {
  getCount: state => state.count,
  getUser: state => state.user,
  getUserName: state => state.user?.name ?? 'Guest',
  getDoubleCount: state => state.count * 2
};

const count = selectors.getCount(store.getState());
```

**Memoized selectors** cache computed values and only recalculate when dependencies change:

```javascript
function createSelector(dependencies, computeFn) {
  let lastArgs = [];
  let lastResult;
  
  return (state) => {
    const args = dependencies.map(dep => dep(state));
    
    // Shallow equality check on dependencies
    if (args.length === lastArgs.length &&
        args.every((arg, i) => arg === lastArgs[i])) {
      return lastResult;
    }
    
    lastArgs = args;
    lastResult = computeFn(...args);
    return lastResult;
  };
}

const getExpensiveData = createSelector(
  [state => state.items, state => state.filter],
  (items, filter) => {
    console.log('Computing filtered items');
    return items.filter(item => item.type === filter);
  }
);
```

Memoization prevents unnecessary recomputation when unrelated state changes. [Inference: Most selector libraries use similar dependency tracking mechanisms.]

### Component-Local State

Component-local state isolates state to a specific component tree, preventing unnecessary global pollution.

```javascript
class Component {
  constructor(element) {
    this.element = element;
    this.state = {};
    this.render();
  }
  
  setState(partial) {
    this.state = { ...this.state, ...partial };
    this.render();
  }
  
  render() {
    // Override in subclass
  }
}

class Counter extends Component {
  constructor(element) {
    super(element);
    this.state = { count: 0 };
  }
  
  render() {
    this.element.innerHTML = `
      <div>Count: ${this.state.count}</div>
      <button>Increment</button>
    `;
    
    this.element.querySelector('button').onclick = () => {
      this.setState({ count: this.state.count + 1 });
    };
  }
}
```

**State lifting** moves state up the component tree when multiple components need access:

```javascript
class Parent extends Component {
  constructor(element) {
    super(element);
    this.state = { sharedData: 0 };
  }
  
  updateShared = (value) => {
    this.setState({ sharedData: value });
  }
  
  render() {
    const child1 = new Child(this.state.sharedData, this.updateShared);
    const child2 = new Child(this.state.sharedData, this.updateShared);
    // Render children
  }
}
```

### Immutable Update Patterns

Immutability enables efficient change detection through reference equality and prevents accidental mutations.

**Object spread for shallow updates:**

```javascript
const newState = {
  ...state,
  count: state.count + 1
};
```

**Nested updates require spreading at each level:**

```javascript
const newState = {
  ...state,
  user: {
    ...state.user,
    profile: {
      ...state.user.profile,
      name: 'New Name'
    }
  }
};
```

**Array operations:**

```javascript
// Add item
const newArray = [...state.items, newItem];

// Remove item
const newArray = state.items.filter(item => item.id !== removeId);

// Update item
const newArray = state.items.map(item =>
  item.id === updateId ? { ...item, ...updates } : item
);

// Insert at index
const newArray = [
  ...state.items.slice(0, index),
  newItem,
  ...state.items.slice(index)
];
```

**Immer-style patterns** use a draft object that tracks mutations and produces an immutable result:

```javascript
function produce(baseState, recipe) {
  const draft = JSON.parse(JSON.stringify(baseState)); // Deep clone
  recipe(draft);
  return draft;
}

const newState = produce(state, draft => {
  draft.user.profile.name = 'New Name';
  draft.items.push(newItem);
});
```

[Inference: The actual Immer library uses Proxies for more efficient change tracking than JSON cloning.]

### Context/Dependency Injection Pattern

Context provides state to deeply nested components without prop drilling.

```javascript
class Context {
  constructor(defaultValue) {
    this.value = defaultValue;
    this.listeners = [];
  }
  
  provide(value) {
    this.value = value;
    this.listeners.forEach(listener => listener(value));
  }
  
  consume(callback) {
    callback(this.value);
    this.listeners.push(callback);
    
    return () => {
      this.listeners = this.listeners.filter(l => l !== callback);
    };
  }
}

const ThemeContext = new Context('light');

// Provider component
function App() {
  ThemeContext.provide('dark');
  // Render children
}

// Consumer component (deeply nested)
function Button() {
  ThemeContext.consume(theme => {
    element.className = theme === 'dark' ? 'btn-dark' : 'btn-light';
  });
}
```

**Multiple contexts** enable different concerns:

```javascript
const contexts = {
  theme: new Context('light'),
  user: new Context(null),
  language: new Context('en')
};
```

### State Machine Pattern

State machines model state as discrete modes with defined transitions, preventing invalid states.

```javascript
class StateMachine {
  constructor(config) {
    this.config = config;
    this.state = config.initial;
    this.listeners = [];
  }
  
  transition(event) {
    const currentState = this.config.states[this.state];
    const transition = currentState.on?.[event];
    
    if (!transition) {
      console.warn(`No transition for ${event} in ${this.state}`);
      return;
    }
    
    this.state = transition;
    this.listeners.forEach(listener => listener(this.state));
  }
  
  subscribe(listener) {
    this.listeners.push(listener);
    return () => {
      this.listeners = this.listeners.filter(l => l !== listener);
    };
  }
  
  getState() {
    return this.state;
  }
}

const fetchMachine = new StateMachine({
  initial: 'idle',
  states: {
    idle: {
      on: { FETCH: 'loading' }
    },
    loading: {
      on: {
        SUCCESS: 'success',
        ERROR: 'error'
      }
    },
    success: {
      on: { FETCH: 'loading' }
    },
    error: {
      on: { RETRY: 'loading' }
    }
  }
});
```

**Extended state** (context) holds data alongside the state:

```javascript
class StateMachineWithContext {
  constructor(config) {
    this.config = config;
    this.state = config.initial;
    this.context = config.context || {};
    this.listeners = [];
  }
  
  transition(event, payload) {
    const currentState = this.config.states[this.state];
    const transition = currentState.on?.[event];
    
    if (!transition) return;
    
    // Execute action if defined
    if (transition.action) {
      this.context = transition.action(this.context, payload);
    }
    
    this.state = transition.target;
    this.listeners.forEach(listener => listener({
      state: this.state,
      context: this.context
    }));
  }
}

const fetchMachine = new StateMachineWithContext({
  initial: 'idle',
  context: { data: null, error: null },
  states: {
    idle: {
      on: {
        FETCH: {
          target: 'loading',
          action: (ctx) => ({ ...ctx, error: null })
        }
      }
    },
    loading: {
      on: {
        SUCCESS: {
          target: 'success',
          action: (ctx, payload) => ({ ...ctx, data: payload })
        },
        ERROR: {
          target: 'error',
          action: (ctx, payload) => ({ ...ctx, error: payload })
        }
      }
    }
  }
});
```

### Atomic State Pattern

Atoms represent individual pieces of state that can be independently subscribed to and updated.

```javascript
function atom(initialValue) {
  let value = initialValue;
  const listeners = new Set();
  
  return {
    get() {
      return value;
    },
    set(newValue) {
      value = typeof newValue === 'function' ? newValue(value) : newValue;
      listeners.forEach(listener => listener(value));
    },
    subscribe(listener) {
      listeners.add(listener);
      return () => listeners.delete(listener);
    }
  };
}

const countAtom = atom(0);
const userAtom = atom(null);

countAtom.subscribe(count => {
  document.getElementById('count').textContent = count;
});

countAtom.set(count => count + 1);
```

**Derived atoms** compute values from other atoms:

```javascript
function derived(dependencies, computeFn) {
  const result = atom(computeFn(...dependencies.map(d => d.get())));
  
  dependencies.forEach(dep => {
    dep.subscribe(() => {
      result.set(computeFn(...dependencies.map(d => d.get())));
    });
  });
  
  return {
    get: result.get,
    subscribe: result.subscribe
  };
}

const doubleCountAtom = derived([countAtom], count => count * 2);
```

### Signal Pattern

Signals combine reactive values with automatic dependency tracking during computation.

```javascript
let currentListener = null;

function signal(initialValue) {
  let value = initialValue;
  const listeners = new Set();
  
  return {
    get value() {
      if (currentListener) {
        listeners.add(currentListener);
      }
      return value;
    },
    set value(newValue) {
      value = newValue;
      listeners.forEach(listener => listener());
    }
  };
}

function computed(fn) {
  const sig = signal(undefined);
  
  function recompute() {
    const prevListener = currentListener;
    currentListener = recompute;
    sig.value = fn();
    currentListener = prevListener;
  }
  
  recompute();
  
  return {
    get value() {
      return sig.value;
    }
  };
}

const count = signal(0);
const double = computed(() => count.value * 2);

console.log(double.value); // 0
count.value = 5;
console.log(double.value); // 10 (automatically updated)
```

**Effect functions** run side effects when dependencies change:

```javascript
function effect(fn) {
  const execute = () => {
    const prevListener = currentListener;
    currentListener = execute;
    fn();
    currentListener = prevListener;
  };
  
  execute();
}

effect(() => {
  document.getElementById('count').textContent = count.value;
  // Automatically re-runs when count changes
});
```

### Command Pattern for State Changes

Commands encapsulate state mutations as objects that can be executed, undone, and logged.

```javascript
class Command {
  execute() {}
  undo() {}
}

class IncrementCommand extends Command {
  constructor(state) {
    super();
    this.state = state;
  }
  
  execute() {
    this.state.count++;
  }
  
  undo() {
    this.state.count--;
  }
}

class CommandManager {
  constructor() {
    this.history = [];
    this.currentIndex = -1;
  }
  
  execute(command) {
    // Remove any commands after current position
    this.history = this.history.slice(0, this.currentIndex + 1);
    
    command.execute();
    this.history.push(command);
    this.currentIndex++;
  }
  
  undo() {
    if (this.currentIndex < 0) return;
    
    this.history[this.currentIndex].undo();
    this.currentIndex--;
  }
  
  redo() {
    if (this.currentIndex >= this.history.length - 1) return;
    
    this.currentIndex++;
    this.history[this.currentIndex].execute();
  }
}
```

### Transactional State Updates

Transactions batch multiple state changes into a single atomic operation, preventing intermediate states from triggering updates.

```javascript
class TransactionalStore {
  constructor(initialState) {
    this.state = initialState;
    this.listeners = [];
    this.inTransaction = false;
    this.pendingChanges = {};
  }
  
  beginTransaction() {
    this.inTransaction = true;
    this.pendingChanges = {};
  }
  
  commit() {
    if (!this.inTransaction) return;
    
    this.state = { ...this.state, ...this.pendingChanges };
    this.inTransaction = false;
    this.pendingChanges = {};
    this.notify();
  }
  
  rollback() {
    this.inTransaction = false;
    this.pendingChanges = {};
  }
  
  setState(key, value) {
    if (this.inTransaction) {
      this.pendingChanges[key] = value;
    } else {
      this.state[key] = value;
      this.notify();
    }
  }
  
  notify() {
    this.listeners.forEach(listener => listener(this.state));
  }
}

const store = new TransactionalStore({ x: 0, y: 0 });

store.beginTransaction();
store.setState('x', 10);
store.setState('y', 20);
store.commit(); // Single notification with both changes
```

### Snapshot Pattern

Snapshots capture state at a point in time for undo/redo or debugging.

```javascript
class SnapshotManager {
  constructor(initialState) {
    this.snapshots = [JSON.parse(JSON.stringify(initialState))];
    this.currentIndex = 0;
  }
  
  takeSnapshot(state) {
    // Remove any snapshots after current position
    this.snapshots = this.snapshots.slice(0, this.currentIndex + 1);
    this.snapshots.push(JSON.parse(JSON.stringify(state)));
    this.currentIndex++;
  }
  
  undo() {
    if (this.currentIndex > 0) {
      this.currentIndex--;
      return this.snapshots[this.currentIndex];
    }
    return null;
  }
  
  redo() {
    if (this.currentIndex < this.snapshots.length - 1) {
      this.currentIndex++;
      return this.snapshots[this.currentIndex];
    }
    return null;
  }
  
  getCurrentSnapshot() {
    return this.snapshots[this.currentIndex];
  }
}
```

**Structural sharing** reduces memory overhead by sharing unchanged portions:

```javascript
// [Inference: Libraries like Immutable.js use persistent data structures]
// that reuse unchanged subtrees between versions

function createVersionedState(initialState) {
  const versions = [initialState];
  let current = 0;
  
  return {
    update(path, value) {
      // Only clone affected path
      const newState = updatePath(versions[current], path, value);
      versions.push(newState);
      current++;
      return newState;
    },
    undo() {
      if (current > 0) current--;
      return versions[current];
    }
  };
}
```

### Event Sourcing Pattern

Instead of storing current state, store the sequence of events that led to that state. Current state is derived by replaying events.

```javascript
class EventStore {
  constructor() {
    this.events = [];
    this.currentState = {};
    this.handlers = {};
  }
  
  registerHandler(eventType, handler) {
    this.handlers[eventType] = handler;
  }
  
  dispatch(event) {
    this.events.push({
      ...event,
      timestamp: Date.now()
    });
    
    const handler = this.handlers[event.type];
    if (handler) {
      this.currentState = handler(this.currentState, event);
    }
  }
  
  replayEvents(events = this.events) {
    let state = {};
    events.forEach(event => {
      const handler = this.handlers[event.type];
      if (handler) {
        state = handler(state, event);
      }
    });
    return state;
  }
  
  getState() {
    return this.currentState;
  }
  
  getEventHistory() {
    return this.events;
  }
}

const store = new EventStore();

store.registerHandler('USER_CREATED', (state, event) => ({
  ...state,
  users: [...(state.users || []), event.payload]
}));

store.registerHandler('USER_UPDATED', (state, event) => ({
  ...state,
  users: state.users.map(u => 
    u.id === event.payload.id ? { ...u, ...event.payload } : u
  )
}));
```

Event sourcing enables time-travel debugging, audit logs, and replaying state at any point.

### Optimistic Updates Pattern

Optimistic updates apply changes immediately to the UI while the actual operation executes asynchronously. If the operation fails, the state reverts.

```javascript
class OptimisticStore {
  constructor(initialState) {
    this.committedState = initialState;
    this.optimisticState = initialState;
    this.pendingOps = [];
    this.listeners = [];
  }
  
  async update(key, value, asyncOperation) {
    const operationId = Math.random();
    
    // Apply optimistically
    this.optimisticState = {
      ...this.optimisticState,
      [key]: value
    };
    
    this.pendingOps.push(operationId);
    this.notify();
    
    try {
      await asyncOperation();
      
      // Commit
      this.committedState = {
        ...this.committedState,
        [key]: value
      };
    } catch (error) {
      // Revert optimistic update
      this.optimisticState = { ...this.committedState };
    } finally {
      this.pendingOps = this.pendingOps.filter(id => id !== operationId);
      this.notify();
    }
  }
  
  getState() {
    return this.optimisticState;
  }
  
  isPending() {
    return this.pendingOps.length > 0;
  }
  
  notify() {
    this.listeners.forEach(l => l(this.optimisticState));
  }
}
```

### Normalization Pattern

Normalized state stores entities by ID in flat structures, preventing duplication and simplifying updates.

```javascript
// Denormalized (nested)
const state = {
  posts: [
    {
      id: 1,
      title: 'Post 1',
      author: { id: 1, name: 'Alice' },
      comments: [
        { id: 1, text: 'Comment 1', author: { id: 2, name: 'Bob' } }
      ]
    }
  ]
};

// Normalized (flat)
const normalizedState = {
  entities: {
    posts: {
      '1': { id: 1, title: 'Post 1', author: 1, comments: [1] }
    },
    users: {
      '1': { id: 1, name: 'Alice' },
      '2': { id: 2, name: 'Bob' }
    },
    comments: {
      '1': { id: 1, text: 'Comment 1', author: 2 }
    }
  },
  result: [1]
};

// Update user once, affects all references
function updateUser(state, userId, updates) {
  return {
    ...state,
    entities: {
      ...state.entities,
      users: {
        ...state.entities.users,
        [userId]: { ...state.entities.users[userId], ...updates }
      }
    }
  };
}
```

**Selectors denormalize for consumption:**

```javascript
function getPostWithAuthor(state, postId) {
  const post = state.entities.posts[postId];
  const author = state.entities.users[post.author];
  
  return {
    ...post,
    author
  };
}
```

### Middleware Patterns

Middleware intercepts actions to add cross-cutting concerns like logging, analytics, persistence, or async handling.

**Async middleware** handles promises:

```javascript
const asyncMiddleware = store => next => action => {
  if (typeof action.payload === 'object' && action.payload.then) {
    action.payload
      .then(result => next({ ...action, payload: result }))
      .catch(error => next({ type: action.type + '_ERROR', payload: error }));
    return;
  }
  
  return next(action);
};
```

**Persistence middleware** saves state to localStorage:

```javascript
const persistenceMiddleware = store => next => action => {
  const result = next(action);
  localStorage.setItem('appState', JSON.stringify(store.getState()));
  return result;
};
```

**Batching middleware** collects multiple synchronous dispatches:

```javascript
const batchMiddleware = store => {
  let queue = [];
  let scheduled = false;
  
  return next => action => {
    queue.push(action);
    
    if (!scheduled) {
      scheduled = true;
      queueMicrotask(() => {
        const actions = queue;
        queue = [];
        scheduled = false;
        
        actions.forEach(a => next(a));
      });
    }
  };
};
```

### Computed/Derived State

Derived state is calculated from source state rather than stored redundantly.

```javascript
class Store {
  constructor(initialState) {
    this.state = initialState;
    this.computedCache = new Map();
    this.listeners = [];
  }
  
  computed(key, computeFn, dependencies) {
    const getDependencyValues = () => 
      dependencies.map(dep => this.state[dep]);
    
    // Initial computation
    let lastDeps = getDependencyValues();
    this.computedCache.set(key, computeFn(...lastDeps));
    
    // Recompute when dependencies change
    this.subscribe(() => {
      const currentDeps = getDependencyValues();
      const changed = currentDeps.some((val, i) => val !== lastDeps[i]);
      
      if (changed) {
        lastDeps = currentDeps;
        this.computedCache.set(key, computeFn(...currentDeps));
      }
    });
    
    return () => this.computedCache.get(key);
  }
}

const store = new Store({ items: [], filter: 'all' });

const getFilteredItems = store.computed(
  'filteredItems',
  (items, filter) => items.filter(item => 
    filter === 'all' || item.category === filter
  ),
  ['items', 'filter']
);
```

### Comparison: Pattern Selection Criteria

**Use direct DOM manipulation** for simple forms with isolated state needs.

**Use global variables** for genuinely application-wide singleton state like theme or auth status where no complex updates occur.

**Use Observer pattern** when multiple disconnected components need to react to the same state changes.

**Use Proxy-based reactivity** when automatic dependency tracking significantly reduces boilerplate compared to manual subscriptions.

**Use Flux/Redux** for complex applications requiring predictable state updates, time-travel debugging, or middleware integration. [Inference: Most commonly adopted in large-scale applications.]

**Use State Machines** for UI with distinct modes (loading/success/error) or complex workflows with defined transitions.

**Use Atoms/Signals** for fine-grained reactivity where different components subscribe to different slices of state independently.

**Use Event Sourcing** when audit trails, undo/redo, or debugging history are critical requirements.

**Use Optimistic Updates** for perceived performance in applications with network latency.

**Use Normalization** when the same entities appear in multiple places and need consistent updates.

---

