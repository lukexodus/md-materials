## Reactive Updates in DOM/JavaScript


### Core Reactivity Mechanisms

#### Signal-Based Reactivity

Signals represent the fundamental unit of reactive state, consisting of three primitives: signals (state containers), computeds (derived state), and effects (side effects). When a signal's value changes, all dependent computeds and effects automatically re-execute.

```javascript
// Basic signal implementation
function createSignal(initialValue) {
  let value = initialValue;
  const subscribers = new Set();
  
  const read = () => {
    if (currentEffect) subscribers.add(currentEffect);
    return value;
  };
  
  const write = (newValue) => {
    value = newValue;
    subscribers.forEach(effect => effect());
  };
  
  return [read, write];
}

let currentEffect = null;

function createEffect(fn) {
  currentEffect = fn;
  fn();
  currentEffect = null;
}
```

The dependency tracking occurs automatically during the read operation. When an effect executes, it becomes the "current effect" and any signals read during execution register it as a subscriber. This eliminates manual dependency declaration.

#### Observable Pattern

Observables use explicit subscription mechanisms where observers register callbacks that fire on state changes. Unlike signals, observables don't automatically track dependencies—subscriptions must be manually managed.

```javascript
class Observable {
  constructor(value) {
    this._value = value;
    this._observers = [];
  }
  
  get value() {
    return this._value;
  }
  
  set value(newValue) {
    if (this._value !== newValue) {
      this._value = newValue;
      this._notify();
    }
  }
  
  subscribe(callback) {
    this._observers.push(callback);
    return () => {
      this._observers = this._observers.filter(obs => obs !== callback);
    };
  }
  
  _notify() {
    this._observers.forEach(callback => callback(this._value));
  }
}
```

#### Proxy-Based Reactivity

Proxies intercept property access and mutations on objects, enabling fine-grained reactivity without explicit wrappers. Vue 3's reactivity system exemplifies this approach.

```javascript
function reactive(target) {
  const handler = {
    get(target, property, receiver) {
      track(target, property);
      const value = Reflect.get(target, property, receiver);
      return typeof value === 'object' ? reactive(value) : value;
    },
    
    set(target, property, value, receiver) {
      const result = Reflect.set(target, property, value, receiver);
      trigger(target, property);
      return result;
    }
  };
  
  return new Proxy(target, handler);
}

const targetMap = new WeakMap();
let activeEffect = null;

function track(target, property) {
  if (!activeEffect) return;
  
  let depsMap = targetMap.get(target);
  if (!depsMap) {
    targetMap.set(target, (depsMap = new Map()));
  }
  
  let dep = depsMap.get(property);
  if (!dep) {
    depsMap.set(property, (dep = new Set()));
  }
  
  dep.add(activeEffect);
}

function trigger(target, property) {
  const depsMap = targetMap.get(target);
  if (!depsMap) return;
  
  const dep = depsMap.get(property);
  if (dep) {
    dep.forEach(effect => effect());
  }
}
```

### Scheduling and Batching

#### Microtask Scheduling

Updates scheduled as microtasks execute after the current synchronous code completes but before the next rendering frame. This consolidates multiple synchronous updates into a single DOM update.

```javascript
class Scheduler {
  constructor() {
    this.queue = new Set();
    this.flushing = false;
  }
  
  schedule(effect) {
    this.queue.add(effect);
    if (!this.flushing) {
      this.flushing = true;
      queueMicrotask(() => this.flush());
    }
  }
  
  flush() {
    const effects = Array.from(this.queue);
    this.queue.clear();
    this.flushing = false;
    effects.forEach(effect => effect());
  }
}
```

#### Transaction-Based Batching

Transactions group multiple state changes, deferring all effects until the transaction commits. This prevents intermediate states from triggering updates.

```javascript
let batchDepth = 0;
const pendingEffects = new Set();

function batch(fn) {
  batchDepth++;
  try {
    fn();
  } finally {
    batchDepth--;
    if (batchDepth === 0) {
      const effects = Array.from(pendingEffects);
      pendingEffects.clear();
      effects.forEach(effect => effect());
    }
  }
}

function scheduleEffect(effect) {
  if (batchDepth > 0) {
    pendingEffects.add(effect);
  } else {
    effect();
  }
}
```

#### Priority-Based Scheduling

Different updates carry different priorities—user interactions demand immediate response while background updates can defer. React's concurrent mode implements this with lanes.

```javascript
const Priority = {
  IMMEDIATE: 0,
  USER_BLOCKING: 1,
  NORMAL: 2,
  LOW: 3,
  IDLE: 4
};

class PriorityScheduler {
  constructor() {
    this.queues = new Map();
    Priority.forEach((_, priority) => {
      this.queues.set(priority, []);
    });
  }
  
  schedule(effect, priority = Priority.NORMAL) {
    this.queues.get(priority).push(effect);
    this.flush(priority);
  }
  
  flush(maxPriority) {
    for (let p = Priority.IMMEDIATE; p <= maxPriority; p++) {
      const queue = this.queues.get(p);
      while (queue.length > 0) {
        const effect = queue.shift();
        effect();
      }
    }
  }
}
```

### DOM Update Strategies

#### Virtual DOM Diffing

Virtual DOM maintains a lightweight representation of the actual DOM. Updates compute differences between old and new virtual trees, then apply minimal changes to the real DOM.

```javascript
function diff(oldVNode, newVNode) {
  const patches = [];
  
  // Different types - replace
  if (oldVNode.type !== newVNode.type) {
    return [{ type: 'REPLACE', newVNode }];
  }
  
  // Text nodes
  if (typeof oldVNode === 'string') {
    if (oldVNode !== newVNode) {
      return [{ type: 'TEXT', text: newVNode }];
    }
    return patches;
  }
  
  // Props
  const propPatches = diffProps(oldVNode.props, newVNode.props);
  if (propPatches) {
    patches.push({ type: 'PROPS', props: propPatches });
  }
  
  // Children
  const childPatches = diffChildren(oldVNode.children, newVNode.children);
  patches.push(...childPatches);
  
  return patches;
}

function diffChildren(oldChildren, newChildren) {
  const patches = [];
  const maxLength = Math.max(oldChildren.length, newChildren.length);
  
  for (let i = 0; i < maxLength; i++) {
    if (!oldChildren[i]) {
      patches.push({ type: 'INSERT', index: i, vnode: newChildren[i] });
    } else if (!newChildren[i]) {
      patches.push({ type: 'REMOVE', index: i });
    } else {
      const childPatches = diff(oldChildren[i], newChildren[i]);
      if (childPatches.length > 0) {
        patches.push({ type: 'PATCH', index: i, patches: childPatches });
      }
    }
  }
  
  return patches;
}
```

#### Keyed Reconciliation

Keys enable efficient reordering and identification of elements across renders. The algorithm uses a longest-increasing-subsequence approach to minimize DOM moves.

```javascript
function reconcileChildren(oldChildren, newChildren, container) {
  const oldKeyToIndex = new Map();
  const newKeyToIndex = new Map();
  
  oldChildren.forEach((child, i) => {
    if (child.key != null) oldKeyToIndex.set(child.key, i);
  });
  
  newChildren.forEach((child, i) => {
    if (child.key != null) newKeyToIndex.set(child.key, i);
  });
  
  const toMove = [];
  const toRemove = [];
  const toCreate = [];
  
  // Find moves and removes
  for (let i = 0; i < oldChildren.length; i++) {
    const oldChild = oldChildren[i];
    if (oldChild.key != null) {
      const newIndex = newKeyToIndex.get(oldChild.key);
      if (newIndex == null) {
        toRemove.push(i);
      } else if (newIndex !== i) {
        toMove.push({ from: i, to: newIndex, child: oldChild });
      }
    }
  }
  
  // Find creates
  for (let i = 0; i < newChildren.length; i++) {
    const newChild = newChildren[i];
    if (newChild.key != null && !oldKeyToIndex.has(newChild.key)) {
      toCreate.push({ index: i, child: newChild });
    }
  }
  
  // Apply operations
  toRemove.forEach(index => {
    container.removeChild(container.children[index]);
  });
  
  toMove.forEach(({ from, to }) => {
    const node = container.children[from];
    container.insertBefore(node, container.children[to]);
  });
  
  toCreate.forEach(({ index, child }) => {
    const node = createElement(child);
    container.insertBefore(node, container.children[index]);
  });
}
```

#### Fine-Grained Reactive DOM Updates

Instead of diffing, fine-grained reactivity directly binds reactive primitives to specific DOM nodes. Only the affected nodes update when dependencies change.

```javascript
function createTextBinding(element, compute) {
  createEffect(() => {
    element.textContent = compute();
  });
}

function createAttrBinding(element, attr, compute) {
  createEffect(() => {
    const value = compute();
    if (value == null) {
      element.removeAttribute(attr);
    } else {
      element.setAttribute(attr, value);
    }
  });
}

function createClassBinding(element, classes) {
  Object.entries(classes).forEach(([className, compute]) => {
    createEffect(() => {
      element.classList.toggle(className, compute());
    });
  });
}

// Usage
const [count, setCount] = createSignal(0);
const doubled = () => count() * 2;

const span = document.createElement('span');
createTextBinding(span, () => `Count: ${count()}, Doubled: ${doubled()}`);
```

### Dependency Tracking Patterns

#### Automatic Dependency Collection

During effect execution, all accessed reactive values automatically register as dependencies. This eliminates explicit dependency arrays but requires careful handling of conditional logic.

```javascript
class DependencyTracker {
  constructor() {
    this.activeEffect = null;
    this.dependencies = new WeakMap();
    this.subscribers = new WeakMap();
  }
  
  track(target, key) {
    if (!this.activeEffect) return;
    
    let depsMap = this.dependencies.get(target);
    if (!depsMap) {
      this.dependencies.set(target, (depsMap = new Map()));
    }
    
    let deps = depsMap.get(key);
    if (!deps) {
      depsMap.set(key, (deps = new Set()));
    }
    
    deps.add(this.activeEffect);
    
    // Store reverse mapping
    let effectDeps = this.subscribers.get(this.activeEffect);
    if (!effectDeps) {
      this.subscribers.set(this.activeEffect, (effectDeps = new Set()));
    }
    effectDeps.add(deps);
  }
  
  trigger(target, key) {
    const depsMap = this.dependencies.get(target);
    if (!depsMap) return;
    
    const deps = depsMap.get(key);
    if (!deps) return;
    
    deps.forEach(effect => {
      if (effect !== this.activeEffect) {
        effect();
      }
    });
  }
  
  effect(fn) {
    const effect = () => {
      this.cleanup(effect);
      this.activeEffect = effect;
      try {
        fn();
      } finally {
        this.activeEffect = null;
      }
    };
    
    effect();
    return effect;
  }
  
  cleanup(effect) {
    const deps = this.subscribers.get(effect);
    if (deps) {
      deps.forEach(dep => dep.delete(effect));
      deps.clear();
    }
  }
}
```

#### Derived State and Memoization

Computed values cache results and only recompute when dependencies change. This prevents unnecessary recalculations in derived state chains.

```javascript
function createComputed(compute) {
  let value;
  let dirty = true;
  let observers = new Set();
  
  const computed = () => {
    if (currentEffect) {
      observers.add(currentEffect);
    }
    
    if (dirty) {
      const oldEffect = currentEffect;
      currentEffect = () => {
        dirty = true;
        observers.forEach(obs => obs());
      };
      value = compute();
      currentEffect = oldEffect;
      dirty = false;
    }
    
    return value;
  };
  
  return computed;
}

// Usage
const [a, setA] = createSignal(1);
const [b, setB] = createSignal(2);

const sum = createComputed(() => {
  console.log('computing sum');
  return a() + b();
});

const doubled = createComputed(() => {
  console.log('computing doubled');
  return sum() * 2;
});

createEffect(() => {
  console.log('doubled:', doubled()); // Only logs once
});

setA(5); // Logs: computing sum, computing doubled, doubled: 14
```

#### Conditional Dependencies

When effects contain conditional logic, dependencies change based on execution paths. The tracking system must handle dynamic dependency graphs.

```javascript
const [show, setShow] = createSignal(true);
const [name, setName] = createSignal('Alice');
const [age, setAge] = createSignal(25);

createEffect(() => {
  if (show()) {
    console.log(`Name: ${name()}`);
  } else {
    console.log(`Age: ${age()}`);
  }
});

// Initially depends on: show, name
setName('Bob'); // Triggers effect

setShow(false); // Switches branch
// Now depends on: show, age (name no longer tracked)

setName('Charlie'); // Does NOT trigger effect
setAge(30); // Triggers effect
```

### Change Detection Strategies

#### Push-Based Detection

Changes propagate immediately from source to dependents. Each mutation triggers synchronous or scheduled updates through the dependency graph.

```javascript
class PushReactive {
  constructor(value) {
    this._value = value;
    this._dependents = new Set();
  }
  
  get() {
    if (currentComputation) {
      this._dependents.add(currentComputation);
      currentComputation.dependencies.add(this);
    }
    return this._value;
  }
  
  set(newValue) {
    if (this._value !== newValue) {
      this._value = newValue;
      this._notify();
    }
  }
  
  _notify() {
    this._dependents.forEach(dep => dep.recompute());
  }
}

class Computation {
  constructor(fn) {
    this.fn = fn;
    this.dependencies = new Set();
    this.recompute();
  }
  
  recompute() {
    // Clear old dependencies
    this.dependencies.forEach(dep => {
      dep._dependents.delete(this);
    });
    this.dependencies.clear();
    
    // Run computation and collect new dependencies
    const oldComputation = currentComputation;
    currentComputation = this;
    this.value = this.fn();
    currentComputation = oldComputation;
  }
}
```

#### Pull-Based Detection

Updates occur lazily when values are accessed. Dirty flags mark stale computations, which recompute only upon read.

```javascript
class LazyComputed {
  constructor(compute) {
    this.compute = compute;
    this.value = undefined;
    this.dirty = true;
    this.dependencies = new Set();
  }
  
  get() {
    if (this.dirty) {
      // Clear old dependencies
      this.dependencies.forEach(dep => {
        dep.observers.delete(this);
      });
      this.dependencies.clear();
      
      // Recompute
      currentComputation = this;
      this.value = this.compute();
      currentComputation = null;
      this.dirty = false;
    }
    
    if (currentComputation) {
      this.observers.add(currentComputation);
      currentComputation.dependencies.add(this);
    }
    
    return this.value;
  }
  
  markDirty() {
    if (!this.dirty) {
      this.dirty = true;
      this.observers.forEach(obs => obs.markDirty());
    }
  }
}
```

#### Zone-Based Detection

Zones (popularized by Angular) intercept asynchronous operations and trigger change detection when async tasks complete. This catches changes from event handlers, timers, and promises without explicit reactivity.

```javascript
class Zone {
  constructor(parent = null) {
    this.parent = parent;
    this.onLeave = [];
  }
  
  run(fn) {
    const prevZone = Zone.current;
    Zone.current = this;
    
    try {
      return fn();
    } finally {
      Zone.current = prevZone;
      this.onLeave.forEach(callback => callback());
    }
  }
  
  fork(config) {
    const child = new Zone(this);
    if (config.onLeave) {
      child.onLeave.push(config.onLeave);
    }
    return child;
  }
  
  static wrap(fn) {
    const zone = Zone.current;
    return function(...args) {
      return zone.run(() => fn.apply(this, args));
    };
  }
}

Zone.current = new Zone();

// Monkey-patch async APIs
const originalSetTimeout = window.setTimeout;
window.setTimeout = function(fn, delay, ...args) {
  return originalSetTimeout(Zone.wrap(fn), delay, ...args);
};

// Usage with change detection
const appZone = Zone.current.fork({
  onLeave: () => {
    detectChanges(); // Run change detection after async work
  }
});

appZone.run(() => {
  setTimeout(() => {
    state.value = 'updated';
    // detectChanges() automatically called when timeout completes
  }, 1000);
});
```

### Granularity Trade-offs

#### Component-Level Reactivity

Each component tracks its own dependencies and re-renders entirely when any dependency changes. Simpler to implement but less efficient for large component trees.

```javascript
class Component {
  constructor(props) {
    this.props = props;
    this.state = this.createState();
    this.element = null;
    this.effect = null;
  }
  
  createState() {
    return {};
  }
  
  setState(updates) {
    Object.assign(this.state, updates);
    this.scheduleUpdate();
  }
  
  scheduleUpdate() {
    if (!this.updateScheduled) {
      this.updateScheduled = true;
      queueMicrotask(() => {
        this.updateScheduled = false;
        this.update();
      });
    }
  }
  
  update() {
    const newElement = this.render();
    if (this.element) {
      patch(this.element, newElement);
    } else {
      this.element = newElement;
    }
  }
  
  mount(container) {
    this.effect = createEffect(() => {
      this.update();
      if (!this.element.parentNode) {
        container.appendChild(this.element);
      }
    });
  }
  
  render() {
    // Override in subclass
    throw new Error('render() must be implemented');
  }
}
```

#### Property-Level Reactivity

Individual properties within components track dependencies. Only the specific DOM nodes bound to changed properties update.

```javascript
function createReactiveComponent(setup) {
  return (props) => {
    const state = {};
    const computeds = {};
    
    // Create reactive state
    const setState = (key, value) => {
      const [get, set] = createSignal(value);
      state[key] = get;
      return set;
    };
    
    // Create computed properties
    const computed = (key, fn) => {
      computeds[key] = createComputed(fn);
      return computeds[key];
    };
    
    // Run setup
    const { template } = setup({ props, setState, computed });
    
    // Create template with fine-grained bindings
    return template();
  };
}

// Usage
const Counter = createReactiveComponent(({ setState, computed }) => {
  const setCount = setState('count', 0);
  const doubledCount = computed('doubled', () => state.count() * 2);
  
  return {
    template: () => {
      const div = document.createElement('div');
      
      const countSpan = document.createElement('span');
      createEffect(() => {
        countSpan.textContent = `Count: ${state.count()}`;
      });
      
      const doubledSpan = document.createElement('span');
      createEffect(() => {
        doubledSpan.textContent = `Doubled: ${doubledCount()}`;
      });
      
      const button = document.createElement('button');
      button.textContent = 'Increment';
      button.onclick = () => setCount(state.count() + 1);
      
      div.append(countSpan, doubledSpan, button);
      return div;
    }
  };
});
```

#### Node-Level Reactivity

The finest granularity—each reactive expression binds to a specific text node or attribute. Maximizes efficiency but increases memory overhead from numerous subscriptions.

```javascript
function h(tag, props, ...children) {
  return { tag, props, children };
}

function mount(vnode) {
  if (typeof vnode === 'string') {
    return document.createTextNode(vnode);
  }
  
  if (typeof vnode === 'function') {
    const textNode = document.createTextNode('');
    createEffect(() => {
      textNode.textContent = vnode();
    });
    return textNode;
  }
  
  const element = document.createElement(vnode.tag);
  
  // Mount props
  if (vnode.props) {
    Object.entries(vnode.props).forEach(([key, value]) => {
      if (key.startsWith('on')) {
        const event = key.slice(2).toLowerCase();
        element.addEventListener(event, value);
      } else if (typeof value === 'function') {
        createEffect(() => {
          element.setAttribute(key, value());
        });
      } else {
        element.setAttribute(key, value);
      }
    });
  }
  
  // Mount children
  vnode.children.forEach(child => {
    element.appendChild(mount(child));
  });
  
  return element;
}

// Usage - only the specific text node updates
const [count, setCount] = createSignal(0);
const [name, setName] = createSignal('Alice');

const app = h('div', null,
  h('span', null, () => `Count: ${count()}`), // Own text node
  h('span', null, () => `Name: ${name()}`),   // Own text node
  h('button', { onClick: () => setCount(count() + 1) }, 'Increment')
);

document.body.appendChild(mount(app));
```

### Memory Management

#### Subscription Cleanup

Effects must clean up subscriptions when unmounted or when dependencies change to prevent memory leaks.

```javascript
class EffectScope {
  constructor() {
    this.effects = new Set();
    this.cleanups = new Set();
  }
  
  run(fn) {
    const prevScope = currentScope;
    currentScope = this;
    try {
      return fn();
    } finally {
      currentScope = prevScope;
    }
  }
  
  registerEffect(effect) {
    this.effects.add(effect);
  }
  
  registerCleanup(cleanup) {
    this.cleanups.add(cleanup);
  }
  
  stop() {
    this.effects.forEach(effect => {
      if (effect.cleanup) effect.cleanup();
    });
    this.cleanups.forEach(cleanup => cleanup());
    this.effects.clear();
    this.cleanups.clear();
  }
}

let currentScope = null;

function createEffect(fn, options = {}) {
  const effect = {
    fn,
    cleanup: null,
    dependencies: new Set(),
    
    run() {
      if (this.cleanup) {
        this.cleanup();
        this.cleanup = null;
      }
      
      this.dependencies.forEach(dep => dep.delete(this));
      this.dependencies.clear();
      
      currentEffect = this;
      try {
        const cleanup = fn();
        if (typeof cleanup === 'function') {
          this.cleanup = cleanup;
        }
      } finally {
        currentEffect = null;
      }
    },
    
    stop() {
      if (this.cleanup) {
        this.cleanup();
      }
      this.dependencies.forEach(dep => dep.delete(this));
    }
  };
  
  if (currentScope) {
    currentScope.registerEffect(effect);
  }
  
  if (!options.lazy) {
    effect.run();
  }
  
  return effect;
}

// Usage
const scope = new EffectScope();
scope.run(() => {
  const [count, setCount] = createSignal(0);
  
  createEffect(() => {
    console.log(count());
    return () => console.log('cleanup');
  });
  
  createEffect(() => {
    const timer = setInterval(() => setCount(count() + 1), 1000);
    return () => clearInterval(timer);
  });
});

// Later - cleanup all effects
scope.stop();
```

#### WeakMap-Based Tracking

WeakMaps allow dependency tracking without preventing garbage collection of reactive objects when no external references remain.

```javascript
const targetMap = new WeakMap();

function track(target, key) {
  if (!activeEffect) return;
  
  let depsMap = targetMap.get(target);
  if (!depsMap) {
    targetMap.set(target, (depsMap = new Map()));
  }
  
  let dep = depsMap.get(key);
  if (!dep) {
    depsMap.set(key, (dep = new Set()));
  }
  
  dep.add(activeEffect);
}

function trigger(target, key) {
  const depsMap = targetMap.get(target);
  if (!depsMap) return;
  
  const dep = depsMap.get(key);
  if (dep) {
    dep.forEach(effect => effect());
  }
}

// When 'obj' is garbage collected, its entry in targetMap
// is automatically removed
let obj = reactive({ count: 0 });
createEffect(() => console.log(obj.count));

obj = null; // No more references - will be GC'd
```

#### Detached Node References

DOM nodes removed from the tree but still referenced by effects leak memory. Mutation observers or explicit cleanup prevent this.

```javascript
class DOMEffectManager {
  constructor() {
    this.nodeToEffects = new WeakMap();
    this.observer = new MutationObserver(mutations => {
      mutations.forEach(mutation => {
        mutation.removedNodes.forEach(node => {
          this.cleanupNode(node);
        });
      });
    });
    
    this.observer.observe(document.body, {
      childList: true,
      subtree: true
    });
  }
  
  registerEffect(node, effect) {
    let effects = this.nodeToEffects.get(node);
    if (!effects) {
      this.nodeToEffects.set(node, (effects = new Set()));
    }
    effects.add(effect);
  }
  
  cleanupNode(node) {
    const effects = this.nodeToEffects.get(node);
    if (effects) {
      effects.forEach(effect => effect.stop());
      this.nodeToEffects.delete(node);
    }
    
    // Cleanup descendants
    node.querySelectorAll('*').forEach(child => {
      this.cleanupNode(child);
    });
  }
}

const effectManager = new DOMEffectManager();

function createDOMEffect(element, fn) {
  const effect = createEffect(fn);
  effectManager.registerEffect(element, effect);
  return effect;
}
```

### Performance Optimization Techniques

#### Debouncing and Throttling Updates

Limit update frequency for high-frequency events like scroll or resize using debounce or throttle wrappers.

```javascript
function createDebouncedSignal(initialValue, delay = 300) {
  const [signal, setSignal] = createSignal(initialValue);
  let timeoutId = null;
  
  const setDebounced = (value) => {
    if (timeoutId !== null) {
      clearTimeout(timeoutId);
    }
    
    timeoutId = setTimeout(() => {
      setSignal(value);
      timeoutId = null;
    }, delay);
  };
  
  return [signal, setDebounced];
}

function createThrottledSignal(initialValue, delay = 300) {
  const [signal, setSignal] = createSignal(initialValue);
  let lastCall = 0;
  let timeoutId = null;
  
  const setThrottled = (value) => {
    const now = Date.now();
    
    if (now - lastCall >= delay) {
      setSignal(value);
      lastCall = now;
    } else {
      if (timeoutId !== null) {
        clearTimeout(timeoutId);
      }
      
      timeoutId = setTimeout(() => {
        setSignal(value);
        lastCall = Date.now();
        timeoutId = null;
      }, delay - (now - lastCall));
    }
  };
  
  return [signal, setThrottled];
}

// Usage
const [searchQuery, setSearchQuery] = createDebouncedSignal('', 500);

input.addEventListener('input', (e) => {
  setSearchQuery(e.target.value);
});

createEffect(() => {
  // Only runs 500ms after user stops typing
  performSearch(searchQuery());
});
```

#### Batched Reads and Writes

Separate read and write phases prevent layout thrashing from interleaved reads and writes.

```javascript
class BatchedScheduler {
  constructor() {
    this.readQueue = [];
    this.writeQueue = [];
    this.scheduled = false;
  }
  
  read(fn) {
    this.readQueue.push(fn);
    this.schedule();
  }
  
  write(fn) {
    this.writeQueue.push(fn);
    this.schedule();
  }
  
  schedule() {
    if (!this.scheduled) {
      this.scheduled = true;
      requestAnimationFrame(() => this.flush());
    }
  }
  
	flush() {
	    // Execute all reads first
	    while (this.readQueue.length > 0) {
	        const read = this.readQueue.shift();
	        read();
	    }
	
	    // Then execute all writes
	    while (this.writeQueue.length > 0) {
	        const write = this.writeQueue.shift();
	        write();
	    }
	
	    this.scheduled = false;
	}
}

const scheduler = new BatchedScheduler();

// Prevents layout thrashing
elements.forEach(el => {
    scheduler.read(() => {
        const height = el.offsetHeight; // Read
        scheduler.write(() => {
            el.style.height = `${height * 2}px`; // Write
        });
    });
});
````

#### Memoization of Expensive Computations

Cache computed results based on input dependencies to avoid redundant calculations.

```javascript
function createMemo(compute, options = {}) {
  const { equals = Object.is } = options;
  let value;
  let prevDeps = [];
  let initialized = false;
  
  return (...deps) => {
    const depsChanged = !initialized || 
      deps.length !== prevDeps.length ||
      deps.some((dep, i) => !equals(dep, prevDeps[i]));
    
    if (depsChanged) {
      value = compute(...deps);
      prevDeps = deps;
      initialized = true;
    }
    
    return value;
  };
}

// Usage
const expensiveComputation = createMemo((list, filter) => {
  console.log('Computing...');
  return list
    .filter(item => item.includes(filter))
    .map(item => item.toUpperCase())
    .sort();
});

const [list, setList] = createSignal(['apple', 'banana', 'cherry']);
const [filter, setFilter] = createSignal('a');

createEffect(() => {
  const result = expensiveComputation(list(), filter());
  console.log(result); // Only recomputes when list or filter changes
});

setFilter('a'); // No recomputation - deps unchanged
setFilter('b'); // Recomputes
````

#### Virtualization for Large Lists

Only render visible items in large lists, dramatically reducing DOM nodes and improving performance.

```javascript
class VirtualList {
  constructor(container, options) {
    this.container = container;
    this.items = options.items || [];
    this.itemHeight = options.itemHeight;
    this.renderItem = options.renderItem;
    this.overscan = options.overscan || 3;
    
    this.scrollTop = 0;
    this.visibleNodes = new Map();
    
    this.setupContainer();
    this.setupScrollListener();
    this.render();
  }
  
  setupContainer() {
    this.viewport = document.createElement('div');
    this.viewport.style.overflow = 'auto';
    this.viewport.style.height = '100%';
    
    this.spacer = document.createElement('div');
    this.spacer.style.height = `${this.items.length * this.itemHeight}px`;
    
    this.content = document.createElement('div');
    this.spacer.appendChild(this.content);
    this.viewport.appendChild(this.spacer);
    this.container.appendChild(this.viewport);
  }
  
  setupScrollListener() {
    this.viewport.addEventListener('scroll', () => {
      this.scrollTop = this.viewport.scrollTop;
      this.render();
    });
  }
  
  getVisibleRange() {
    const viewportHeight = this.viewport.clientHeight;
    const start = Math.floor(this.scrollTop / this.itemHeight);
    const end = Math.ceil((this.scrollTop + viewportHeight) / this.itemHeight);
    
    return {
      start: Math.max(0, start - this.overscan),
      end: Math.min(this.items.length, end + this.overscan)
    };
  }
  
  render() {
    const { start, end } = this.getVisibleRange();
    const newNodes = new Map();
    
    // Render visible items
    for (let i = start; i < end; i++) {
      let node = this.visibleNodes.get(i);
      
      if (!node) {
        node = this.renderItem(this.items[i], i);
        node.style.position = 'absolute';
        node.style.top = `${i * this.itemHeight}px`;
        node.style.height = `${this.itemHeight}px`;
        this.content.appendChild(node);
      }
      
      newNodes.set(i, node);
    }
    
    // Remove nodes outside visible range
    this.visibleNodes.forEach((node, index) => {
      if (!newNodes.has(index)) {
        this.content.removeChild(node);
      }
    });
    
    this.visibleNodes = newNodes;
  }
  
  updateItems(items) {
    this.items = items;
    this.spacer.style.height = `${items.length * this.itemHeight}px`;
    this.visibleNodes.clear();
    this.content.innerHTML = '';
    this.render();
  }
}

// Usage
const list = new VirtualList(container, {
  items: Array.from({ length: 10000 }, (_, i) => `Item ${i}`),
  itemHeight: 40,
  renderItem: (item, index) => {
    const div = document.createElement('div');
    div.textContent = item;
    return div;
  }
});
```

### Advanced Patterns

#### Transient Updates

Some state changes shouldn't trigger reactivity—transient updates modify state without notifying observers until explicitly committed.

```javascript
class TransactionalSignal {
  constructor(initialValue) {
    this._value = initialValue;
    this._transientValue = initialValue;
    this._inTransaction = false;
    this._subscribers = new Set();
  }
  
  get value() {
    if (currentEffect) {
      this._subscribers.add(currentEffect);
    }
    return this._inTransaction ? this._transientValue : this._value;
  }
  
  set value(newValue) {
    if (this._inTransaction) {
      this._transientValue = newValue;
    } else {
      this._value = newValue;
      this._notify();
    }
  }
  
  beginTransaction() {
    this._inTransaction = true;
    this._transientValue = this._value;
  }
  
  commit() {
    if (this._inTransaction) {
      this._value = this._transientValue;
      this._inTransaction = false;
      this._notify();
    }
  }
  
  rollback() {
    if (this._inTransaction) {
      this._transientValue = this._value;
      this._inTransaction = false;
    }
  }
  
  _notify() {
    this._subscribers.forEach(effect => effect());
  }
}

// Usage
const count = new TransactionalSignal(0);

createEffect(() => {
  console.log('Count:', count.value);
});

count.beginTransaction();
count.value = 1; // No effect triggered
count.value = 2; // Still no effect
count.value = 3; // Still no effect
count.commit(); // Effect runs once with value 3
```

#### Reactive Contexts

Context provides reactive values through component trees without prop drilling, automatically tracking consumption for efficient updates.

```javascript
class ReactiveContext {
  constructor(defaultValue) {
    this.stack = [defaultValue];
  }
  
  provide(value, fn) {
    this.stack.push(value);
    try {
      return fn();
    } finally {
      this.stack.pop();
    }
  }
  
  consume() {
    return this.stack[this.stack.length - 1];
  }
}

function createContext(defaultValue) {
  const context = new ReactiveContext(defaultValue);
  
  return {
    Provider: (props) => {
      return context.provide(props.value, () => props.children);
    },
    
    Consumer: (fn) => {
      return fn(context.consume());
    },
    
    use: () => context.consume()
  };
}

// Usage
const ThemeContext = createContext({ color: 'blue', mode: 'light' });

const App = () => {
  const [theme, setTheme] = createSignal({ color: 'blue', mode: 'light' });
  
  return ThemeContext.Provider({
    value: theme(),
    children: ThemedComponent()
  });
};

const ThemedComponent = () => {
  return ThemeContext.Consumer(theme => {
    const div = document.createElement('div');
    createEffect(() => {
      div.style.color = theme.color;
      div.style.background = theme.mode === 'dark' ? '#000' : '#fff';
    });
    return div;
  });
};
```

#### Reactive Collections

Collections (arrays, sets, maps) require special handling to track granular changes like additions, removals, and reordering.

```javascript
function createReactiveArray(initial = []) {
  const array = [...initial];
  const subscribers = new Set();
  const indexMap = new Map(); // index -> Set of effects
  
  const notify = (type, index, value) => {
    subscribers.forEach(sub => sub({ type, index, value }));
    
    if (type === 'set' || type === 'delete') {
      const effects = indexMap.get(index);
      if (effects) effects.forEach(effect => effect());
    }
  };
  
  const handler = {
    get(target, prop) {
      if (prop === 'length') {
        if (currentEffect) subscribers.add(currentEffect);
        return target.length;
      }
      
      const index = Number(prop);
      if (Number.isInteger(index) && index >= 0) {
        if (currentEffect) {
          if (!indexMap.has(index)) {
            indexMap.set(index, new Set());
          }
          indexMap.get(index).add(currentEffect);
        }
      }
      
      const value = Reflect.get(target, prop);
      return typeof value === 'function' ? value.bind(proxy) : value;
    },
    
    set(target, prop, value) {
      const index = Number(prop);
      const oldLength = target.length;
      const result = Reflect.set(target, prop, value);
      
      if (Number.isInteger(index)) {
        notify('set', index, value);
        
        if (index >= oldLength) {
          notify('length', target.length, target.length);
        }
      }
      
      return result;
    },
    
    deleteProperty(target, prop) {
      const index = Number(prop);
      if (Number.isInteger(index)) {
        notify('delete', index, undefined);
      }
      return Reflect.deleteProperty(target, prop);
    }
  };
  
  const proxy = new Proxy(array, handler);
  
  // Enhance mutating methods
  ['push', 'pop', 'shift', 'unshift', 'splice'].forEach(method => {
    const original = array[method];
    proxy[method] = function(...args) {
      const result = original.apply(array, args);
      notify('method', -1, { method, args, result });
      subscribers.forEach(sub => sub({ type: method, args, result }));
      return result;
    };
  });
  
  return proxy;
}

// Usage
const [todos, setTodos] = createSignal(createReactiveArray([
  { id: 1, text: 'Learn reactivity', done: false }
]));

createEffect(() => {
  console.log('First todo:', todos()[0]); // Only tracks index 0
});

createEffect(() => {
  console.log('Todo count:', todos().length); // Only tracks length
});

todos().push({ id: 2, text: 'Build app', done: false }); // Triggers length effect
todos()[0] = { ...todos()[0], done: true }; // Triggers first todo effect
```

#### Error Boundaries for Effects

Isolate effect errors to prevent cascading failures through the reactive graph.

```javascript
class ErrorBoundary {
  constructor() {
    this.errors = new Map();
    this.onError = null;
  }
  
  wrap(effect, errorHandler) {
    const wrappedEffect = (...args) => {
      try {
        return effect(...args);
      } catch (error) {
        this.handleError(effect, error);
        if (errorHandler) {
          return errorHandler(error);
        }
      }
    };
    
    return wrappedEffect;
  }
  
  handleError(effect, error) {
    this.errors.set(effect, error);
    if (this.onError) {
      this.onError(error, effect);
    }
    console.error('Effect error:', error);
  }
  
  clearError(effect) {
    this.errors.delete(effect);
  }
  
  hasError(effect) {
    return this.errors.has(effect);
  }
}

const boundary = new ErrorBoundary();

boundary.onError = (error, effect) => {
  // Log to error tracking service
  console.error('Reactive error:', error);
};

function createSafeEffect(fn, fallback) {
  const wrappedFn = boundary.wrap(fn, fallback);
  return createEffect(wrappedFn);
}

// Usage
const [data, setData] = createSignal(null);

createSafeEffect(
  () => {
    console.log(data().property); // Might throw if data is null
  },
  (error) => {
    console.log('Fallback: No data available');
  }
);
```

This comprehensive overview covers the fundamental mechanisms, scheduling strategies, DOM update techniques, dependency tracking patterns, change detection approaches, granularity considerations, memory management, optimization techniques, and advanced patterns that constitute reactive DOM/JavaScript systems.

---

