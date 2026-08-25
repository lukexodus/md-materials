## Component-Based Thinking


### Mental Model Shifts

Component-based thinking requires viewing the DOM not as a static document tree but as a composition of isolated, reusable units. Each component encapsulates its own structure, behavior, and state, operating as a self-contained system that communicates through well-defined interfaces.

The fundamental shift is from imperative DOM manipulation ("find this element, change this attribute") to declarative composition ("this component renders this state"). You stop thinking about individual DOM operations and start thinking about state transitions that trigger rendering.

### Component Anatomy

#### State Management

State represents the component's internal data that determines its rendering. State should be:

- **Minimal**: Derive computed values rather than storing them
- **Normalized**: Avoid nested duplication; store references instead
- **Serializable**: Enable debugging, time-travel, and persistence
- **Immutable**: Replace rather than mutate for predictable change detection

```javascript
// Poor state design
const state = {
  user: { name: 'Alice', age: 30 },
  userName: 'Alice', // duplicated
  isAdult: true // derived, shouldn't be stored
};

// Better state design
const state = {
  user: { name: 'Alice', age: 30 }
};
const isAdult = state.user.age >= 18; // computed on demand
```

#### Props vs State

Props flow downward from parent to child and are immutable from the child's perspective. State is internal and mutable within the component. The distinction determines component boundaries:

- **Props**: Configuration, data passed in, callbacks from parent
- **State**: Internal UI state, user input, derived local data

A component receiving data via props is more reusable; a component managing state is more autonomous. The tradeoff defines component responsibility.

#### Lifecycle Considerations

Component lifecycle in vanilla JS requires manual management:

- **Mount**: Insert into DOM, attach events, initiate subscriptions
- **Update**: Re-render when state/props change, diff DOM efficiently
- **Unmount**: Remove from DOM, detach events, clean subscriptions

Without a framework, you must track these phases explicitly:

```javascript
class Component {
  constructor(props) {
    this.props = props;
    this.state = {};
    this.element = null;
    this.subscriptions = [];
  }

  mount(container) {
    this.element = this.render();
    container.appendChild(this.element);
    this.attachEvents();
    this.subscriptions.push(
      eventBus.subscribe('dataChange', this.handleDataChange)
    );
  }

  update(newProps) {
    this.props = { ...this.props, ...newProps };
    const newElement = this.render();
    this.element.replaceWith(newElement);
    this.element = newElement;
    this.attachEvents();
  }

  unmount() {
    this.subscriptions.forEach(unsub => unsub());
    this.element.remove();
    this.element = null;
  }
}
```

### Rendering Strategies

#### String-Based Rendering

Generate HTML strings and inject via `innerHTML`. Fast for initial renders but requires full re-renders for updates:

```javascript
function render(state) {
  return `
    <div class="counter">
      <button data-action="decrement">-</button>
      <span>${state.count}</span>
      <button data-action="increment">+</button>
    </div>
  `;
}

container.innerHTML = render(state);
```

**Tradeoffs**: Simple, fast initial render, loses event listeners on re-render, no granular updates, vulnerable to XSS if state contains user input.

#### DOM API Rendering

Imperatively create and manipulate elements:

```javascript
function render(state) {
  const div = document.createElement('div');
  div.className = 'counter';
  
  const decBtn = document.createElement('button');
  decBtn.textContent = '-';
  decBtn.onclick = () => dispatch({ type: 'DECREMENT' });
  
  const span = document.createElement('span');
  span.textContent = state.count;
  
  const incBtn = document.createElement('button');
  incBtn.textContent = '+';
  incBtn.onclick = () => dispatch({ type: 'INCREMENT' });
  
  div.append(decBtn, span, incBtn);
  return div;
}
```

**Tradeoffs**: Verbose, safer (no XSS), retains references, enables targeted updates, but requires manual diffing for efficiency.

#### Virtual DOM Diffing

Maintain a lightweight representation of the DOM, diff against previous version, apply minimal changes:

```javascript
function diff(oldVNode, newVNode, parent, index = 0) {
  if (!oldVNode) {
    parent.appendChild(render(newVNode));
  } else if (!newVNode) {
    parent.removeChild(parent.childNodes[index]);
  } else if (changed(oldVNode, newVNode)) {
    parent.replaceChild(render(newVNode), parent.childNodes[index]);
  } else if (newVNode.type) {
    const oldChildren = oldVNode.children || [];
    const newChildren = newVNode.children || [];
    const maxLength = Math.max(oldChildren.length, newChildren.length);
    
    for (let i = 0; i < maxLength; i++) {
      diff(oldChildren[i], newChildren[i], parent.childNodes[index], i);
    }
  }
}
```

**[Inference]**: This approach likely reduces unnecessary DOM operations compared to full re-renders, but the actual performance gain depends on component complexity and update frequency.

### Event Handling Patterns

#### Event Delegation

Attach a single listener to a parent element and route events based on target:

```javascript
class TodoList {
  constructor(element) {
    this.element = element;
    this.element.addEventListener('click', this.handleClick.bind(this));
  }

  handleClick(e) {
    const target = e.target;
    
    if (target.matches('[data-action="toggle"]')) {
      const id = target.closest('[data-todo-id]').dataset.todoId;
      this.toggleTodo(id);
    } else if (target.matches('[data-action="delete"]')) {
      const id = target.closest('[data-todo-id]').dataset.todoId;
      this.deleteTodo(id);
    }
  }
}
```

**Benefits**: Memory efficient (fewer listeners), works with dynamically added elements, centralizes event logic.

#### Synthetic Events

[Inference] Frameworks often normalize browser event differences into a unified interface. In vanilla JS, you manually handle cross-browser quirks:

```javascript
function normalizeWheelDelta(e) {
  if (e.deltaY) return e.deltaY;
  if (e.wheelDelta) return -e.wheelDelta;
  if (e.detail) return e.detail * 40;
  return 0;
}
```

### State Composition Patterns

#### Lifting State Up

When multiple components need shared state, move state to their nearest common ancestor:

```javascript
class Parent {
  constructor() {
    this.state = { selectedId: null };
  }

  render() {
    return `
      ${Sidebar({ 
        selectedId: this.state.selectedId,
        onSelect: id => this.setState({ selectedId: id })
      })}
      ${Content({ 
        selectedId: this.state.selectedId 
      })}
    `;
  }
}
```

#### Derived State

Compute values from existing state rather than storing them:

```javascript
class FilteredList {
  constructor(items) {
    this.state = {
      items,
      filter: '',
      sortBy: 'name'
    };
  }

  // Compute on demand, don't store
  get filteredItems() {
    return this.state.items
      .filter(item => item.name.includes(this.state.filter))
      .sort((a, b) => a[this.state.sortBy].localeCompare(b[this.state.sortBy]));
  }
}
```

#### Reducer Pattern

Consolidate state updates into a single function that processes actions:

```javascript
function reducer(state, action) {
  switch (action.type) {
    case 'ADD_TODO':
      return {
        ...state,
        todos: [...state.todos, { id: Date.now(), text: action.text, done: false }]
      };
    case 'TOGGLE_TODO':
      return {
        ...state,
        todos: state.todos.map(todo =>
          todo.id === action.id ? { ...todo, done: !todo.done } : todo
        )
      };
    case 'DELETE_TODO':
      return {
        ...state,
        todos: state.todos.filter(todo => todo.id !== action.id)
      };
    default:
      return state;
  }
}
```

### Component Communication

#### Props Drilling

Pass data through intermediate components that don't need it:

```javascript
function App() {
  const user = getCurrentUser();
  return Container({ user });
}

function Container({ user }) {
  return Sidebar({ user }); // Container doesn't use user
}

function Sidebar({ user }) {
  return UserProfile({ user }); // Sidebar doesn't use user
}

function UserProfile({ user }) {
  return `<div>${user.name}</div>`; // Finally used here
}
```

**Problems**: Tight coupling, maintenance burden, intermediate components become dependent on data they don't use.

#### Event Bus Pattern

Decouple components via publish-subscribe:

```javascript
class EventBus {
  constructor() {
    this.events = {};
  }

  subscribe(event, callback) {
    if (!this.events[event]) this.events[event] = [];
    this.events[event].push(callback);
    return () => this.unsubscribe(event, callback);
  }

  unsubscribe(event, callback) {
    if (!this.events[event]) return;
    this.events[event] = this.events[event].filter(cb => cb !== callback);
  }

  emit(event, data) {
    if (!this.events[event]) return;
    this.events[event].forEach(callback => callback(data));
  }
}

const bus = new EventBus();

// Component A
bus.emit('userLoggedIn', { id: 123, name: 'Alice' });

// Component B (anywhere in the tree)
bus.subscribe('userLoggedIn', user => {
  console.log(`Welcome ${user.name}`);
});
```

**Tradeoffs**: Loose coupling, but harder to trace data flow, can lead to callback hell, memory leaks if unsubscribe is forgotten.

#### Context/Provider Pattern

Make data available to subtree without explicit passing:

```javascript
class Context {
  constructor(defaultValue) {
    this.value = defaultValue;
    this.subscribers = new Set();
  }

  provide(value) {
    this.value = value;
    this.subscribers.forEach(callback => callback(value));
  }

  consume(callback) {
    callback(this.value);
    this.subscribers.add(callback);
    return () => this.subscribers.delete(callback);
  }
}

const UserContext = new Context(null);

// Provider component
function App() {
  const user = getCurrentUser();
  UserContext.provide(user);
  return Container();
}

// Consumer component (deep in tree)
function Avatar() {
  let user;
  UserContext.consume(u => user = u);
  return `<img src="${user.avatar}" />`;
}
```

### Composition Techniques

#### Higher-Order Components

Functions that take a component and return an enhanced component:

```javascript
function withLogging(Component) {
  return class extends Component {
    componentDidUpdate(prevProps) {
      console.log('Props changed:', prevProps, '->', this.props);
      super.componentDidUpdate?.(prevProps);
    }
  };
}

function withAuth(Component) {
  return function AuthWrapped(props) {
    const user = getCurrentUser();
    if (!user) return LoginPrompt();
    return Component({ ...props, user });
  };
}

const EnhancedProfile = withAuth(withLogging(UserProfile));
```

#### Render Props

Pass rendering logic as a function prop:

```javascript
class Mouse {
  constructor(element) {
    this.state = { x: 0, y: 0 };
    this.element = element;
    
    element.addEventListener('mousemove', e => {
      this.state = { x: e.clientX, y: e.clientY };
      this.update();
    });
  }

  update() {
    this.element.innerHTML = this.props.render(this.state);
  }
}

// Usage
new Mouse(document.body, {
  render: ({ x, y }) => `
    <div>Mouse position: ${x}, ${y}</div>
  `
});
```

#### Slot Pattern

Define injection points in component template:

```javascript
class Card {
  constructor({ header, body, footer }) {
    this.slots = { header, body, footer };
  }

  render() {
    return `
      <div class="card">
        <div class="card-header">${this.slots.header || ''}</div>
        <div class="card-body">${this.slots.body}</div>
        <div class="card-footer">${this.slots.footer || ''}</div>
      </div>
    `;
  }
}

// Usage
const card = new Card({
  header: '<h3>Title</h3>',
  body: '<p>Content goes here</p>',
  footer: '<button>Action</button>'
});
```

### Performance Optimization

#### Memoization

Cache component output for same inputs:

```javascript
class MemoizedComponent {
  constructor() {
    this.cache = new Map();
  }

  render(props) {
    const key = JSON.stringify(props);
    
    if (this.cache.has(key)) {
      return this.cache.get(key);
    }

    const output = this.computeRender(props);
    this.cache.set(key, output);
    
    // Limit cache size
    if (this.cache.size > 100) {
      const firstKey = this.cache.keys().next().value;
      this.cache.delete(firstKey);
    }
    
    return output;
  }

  computeRender(props) {
    // Expensive rendering logic
    return `<div>${props.data.map(item => `<span>${item}</span>`).join('')}</div>`;
  }
}
```

**[Inference]**: Memoization trades memory for CPU time. Effectiveness depends on render cost vs. serialization cost and prop change frequency.

#### Lazy Initialization

Defer expensive operations until needed:

```javascript
class LazyComponent {
  constructor(props) {
    this.props = props;
    this._expensiveData = null;
  }

  get expensiveData() {
    if (!this._expensiveData) {
      this._expensiveData = this.computeExpensiveData();
    }
    return this._expensiveData;
  }

  computeExpensiveData() {
    // Heavy computation
    return this.props.data.reduce((acc, item) => {
      // Complex processing
      return acc;
    }, {});
  }
}
```

#### Virtualization

Render only visible items in large lists:

```javascript
class VirtualList {
  constructor(container, items, itemHeight) {
    this.container = container;
    this.items = items;
    this.itemHeight = itemHeight;
    this.scrollTop = 0;
    
    container.addEventListener('scroll', () => {
      this.scrollTop = container.scrollTop;
      this.render();
    });
  }

  render() {
    const containerHeight = this.container.clientHeight;
    const startIndex = Math.floor(this.scrollTop / this.itemHeight);
    const endIndex = Math.ceil((this.scrollTop + containerHeight) / this.itemHeight);
    const visibleItems = this.items.slice(startIndex, endIndex);
    
    this.container.innerHTML = `
      <div style="height: ${this.items.length * this.itemHeight}px; position: relative;">
        ${visibleItems.map((item, i) => `
          <div style="position: absolute; top: ${(startIndex + i) * this.itemHeight}px; height: ${this.itemHeight}px;">
            ${item.content}
          </div>
        `).join('')}
      </div>
    `;
  }
}
```

#### Debouncing and Throttling

Control update frequency for expensive operations:

```javascript
function debounce(fn, delay) {
  let timeoutId;
  return function(...args) {
    clearTimeout(timeoutId);
    timeoutId = setTimeout(() => fn.apply(this, args), delay);
  };
}

function throttle(fn, limit) {
  let inThrottle;
  return function(...args) {
    if (!inThrottle) {
      fn.apply(this, args);
      inThrottle = true;
      setTimeout(() => inThrottle = false, limit);
    }
  };
}

class SearchInput {
  constructor(element) {
    this.element = element;
    this.element.addEventListener('input', 
      debounce(e => this.handleSearch(e.target.value), 300)
    );
  }

  handleSearch(query) {
    // Expensive search operation
    fetch(`/api/search?q=${query}`);
  }
}
```

### Component Patterns

#### Container/Presenter Pattern

Separate data management (container) from presentation (presenter):

```javascript
// Container - handles logic and state
class TodoListContainer {
  constructor() {
    this.state = {
      todos: [],
      loading: true
    };
    this.fetchTodos();
  }

  async fetchTodos() {
    const todos = await fetch('/api/todos').then(r => r.json());
    this.state = { todos, loading: false };
    this.render();
  }

  handleToggle(id) {
    this.state.todos = this.state.todos.map(todo =>
      todo.id === id ? { ...todo, done: !todo.done } : todo
    );
    this.render();
  }

  render() {
    return TodoListPresenter({
      todos: this.state.todos,
      loading: this.state.loading,
      onToggle: id => this.handleToggle(id)
    });
  }
}

// Presenter - pure function, only renders
function TodoListPresenter({ todos, loading, onToggle }) {
  if (loading) return '<div>Loading...</div>';
  
  return `
    <ul>
      ${todos.map(todo => `
        <li>
          <input 
            type="checkbox" 
            ${todo.done ? 'checked' : ''}
            data-id="${todo.id}"
            onchange="onToggle(${todo.id})"
          />
          ${todo.text}
        </li>
      `).join('')}
    </ul>
  `;
}
```

#### Compound Components

Components that work together, sharing implicit state:

```javascript
class Tabs {
  constructor() {
    this.state = { activeTab: 0 };
    this.children = [];
  }

  addTab(label, content) {
    this.children.push({ label, content });
  }

  render() {
    return `
      <div class="tabs">
        <div class="tab-list">
          ${this.children.map((tab, i) => `
            <button 
              class="${i === this.state.activeTab ? 'active' : ''}"
              onclick="this.setActiveTab(${i})"
            >
              ${tab.label}
            </button>
          `).join('')}
        </div>
        <div class="tab-panel">
          ${this.children[this.state.activeTab].content}
        </div>
      </div>
    `;
  }

  setActiveTab(index) {
    this.state.activeTab = index;
    this.update();
  }
}

// Usage
const tabs = new Tabs();
tabs.addTab('Overview', '<p>Overview content</p>');
tabs.addTab('Details', '<p>Details content</p>');
tabs.addTab('Settings', '<p>Settings content</p>');
```

#### Controlled vs Uncontrolled

**Controlled**: Component state is managed by parent

```javascript
class ControlledInput {
  constructor({ value, onChange }) {
    this.value = value;
    this.onChange = onChange;
  }

  render() {
    return `
      <input 
        type="text" 
        value="${this.value}"
        oninput="this.onChange(event.target.value)"
      />
    `;
  }
}

// Parent controls the state
class Form {
  constructor() {
    this.state = { name: '' };
  }

  render() {
    return ControlledInput({
      value: this.state.name,
      onChange: name => {
        this.state.name = name;
        this.update();
      }
    });
  }
}
```

**Uncontrolled**: Component manages its own state

```javascript
class UncontrolledInput {
  constructor({ defaultValue }) {
    this.element = document.createElement('input');
    this.element.type = 'text';
    this.element.value = defaultValue || '';
  }

  getValue() {
    return this.element.value;
  }

  render() {
    return this.element;
  }
}

// Parent accesses value via ref
class Form {
  constructor() {
    this.inputRef = new UncontrolledInput({ defaultValue: '' });
  }

  handleSubmit() {
    const name = this.inputRef.getValue();
    console.log('Submitted:', name);
  }
}
```

### State Management Architectures

#### Flux Pattern

Unidirectional data flow: Action → Dispatcher → Store → View

```javascript
class Dispatcher {
  constructor() {
    this.callbacks = [];
  }

  register(callback) {
    this.callbacks.push(callback);
  }

  dispatch(action) {
    this.callbacks.forEach(callback => callback(action));
  }
}

class Store {
  constructor(dispatcher) {
    this.state = {};
    this.listeners = [];
    dispatcher.register(action => this.handleAction(action));
  }

  handleAction(action) {
    switch (action.type) {
      case 'ADD_ITEM':
        this.state.items.push(action.item);
        break;
      case 'REMOVE_ITEM':
        this.state.items = this.state.items.filter(i => i.id !== action.id);
        break;
    }
    this.emitChange();
  }

  subscribe(listener) {
    this.listeners.push(listener);
    return () => {
      this.listeners = this.listeners.filter(l => l !== listener);
    };
  }

  emitChange() {
    this.listeners.forEach(listener => listener(this.state));
  }

  getState() {
    return this.state;
  }
}

const dispatcher = new Dispatcher();
const store = new Store(dispatcher);

// Component
class ListView {
  constructor() {
    store.subscribe(state => this.render(state));
  }

  addItem(item) {
    dispatcher.dispatch({ type: 'ADD_ITEM', item });
  }
}
```

#### Observable Pattern

State changes trigger reactive updates:

```javascript
class Observable {
  constructor(value) {
    this._value = value;
    this.subscribers = new Set();
  }

  get value() {
    return this._value;
  }

  set value(newValue) {
    if (this._value !== newValue) {
      this._value = newValue;
      this.notify();
    }
  }

  subscribe(callback) {
    this.subscribers.add(callback);
    callback(this._value);
    return () => this.subscribers.delete(callback);
  }

  notify() {
    this.subscribers.forEach(callback => callback(this._value));
  }
}

// Usage
const count = new Observable(0);

class Counter {
  constructor() {
    count.subscribe(value => {
      this.render(value);
    });
  }

  increment() {
    count.value++;
  }

  render(value) {
    this.element.innerHTML = `
      <div>Count: ${value}</div>
      <button onclick="this.increment()">+</button>
    `;
  }
}
```

#### Atomic State Updates

Treat state as immutable, create new references for changes:

```javascript
class ImmutableStore {
  constructor(initialState) {
    this.state = initialState;
    this.listeners = [];
  }

  setState(updater) {
    const prevState = this.state;
    this.state = typeof updater === 'function' 
      ? updater(prevState)
      : { ...prevState, ...updater };
    
    if (this.state !== prevState) {
      this.listeners.forEach(listener => listener(this.state, prevState));
    }
  }

  subscribe(listener) {
    this.listeners.push(listener);
    return () => {
      this.listeners = this.listeners.filter(l => l !== listener);
    };
  }
}

const store = new ImmutableStore({ count: 0, items: [] });

store.setState(state => ({
  ...state,
  count: state.count + 1
}));

// Array updates - always create new array
store.setState(state => ({
  ...state,
  items: [...state.items, newItem]
}));

// Nested updates - spread each level
store.setState(state => ({
  ...state,
  user: {
    ...state.user,
    profile: {
      ...state.user.profile,
      name: 'New Name'
    }
  }
}));
```

### Custom Element Pattern

Encapsulate components as native web components:

```javascript
class TodoItem extends HTMLElement {
  constructor() {
    super();
    this.attachShadow({ mode: 'open' });
  }

  static get observedAttributes() {
    return ['text', 'done'];
  }

  connectedCallback() {
    this.render();
    this.shadowRoot.querySelector('input').addEventListener('change', () => {
      this.dispatchEvent(new CustomEvent('toggle', {
        detail: { id: this.getAttribute('id') }
      }));
    });
  }

  attributeChangedCallback(name, oldValue, newValue) {
    if (oldValue !== newValue) {
      this.render();
    }
  }

  render() {
    const text = this.getAttribute('text');
    const done = this.hasAttribute('done');

    this.shadowRoot.innerHTML = `
      <style>
        :host { display: block; padding: 8px; }
        .done { text-decoration: line-through; }
      </style>
      <label>
        <input type="checkbox" ${done ? 'checked' : ''} />
        <span class="${done ? 'done' : ''}">${text}</span>
      </label>
    `;
  }
}

customElements.define('todo-item', TodoItem);

// Usage in HTML
// <todo-item text="Buy milk" done></todo-item>
```

### Dependency Injection

Pass dependencies explicitly rather than importing globally:

```javascript
class UserService {
  constructor(httpClient, cache) {
    this.http = httpClient;
    this.cache = cache;
  }

  async getUser(id) {
    const cached = this.cache.get(`user:${id}`);
    if (cached) return cached;

    const user = await this.http.get(`/api/users/${id}`);
    this.cache.set(`user:${id}`, user);
    return user;
  }
}

class UserProfile {
  constructor(userService) {
    this.userService = userService;
  }

  async render(userId) {
    const user = await this.userService.getUser(userId);
    return `<div>${user.name}</div>`;
  }
}

// Wire dependencies
const httpClient = new HttpClient();
const cache = new Cache();
const userService = new UserService(httpClient, cache);
const userProfile = new UserProfile(userService);
```

This approach enables testing, swapping implementations, and clearer component boundaries.

---

