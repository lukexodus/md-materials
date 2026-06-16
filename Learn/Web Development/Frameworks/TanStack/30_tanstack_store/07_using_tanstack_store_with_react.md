## Using TanStack Store with React

The `@tanstack/react-store` package provides React bindings for TanStack Store, exposing a `useStore` hook that connects React components to store state through the standard selector pattern. Store state changes drive re-renders only when the selected value changes, giving granular control over rendering behavior.

---

### Installation

```bash
npm install @tanstack/store @tanstack/react-store
```

**Key Points:**
- Both packages are required — `@tanstack/store` provides the core `Store` and `Derived` classes; `@tanstack/react-store` provides the React-specific `useStore` hook
- No React context or provider setup is required — stores are plain module-level instances

---

### Creating a Store

Stores are created outside of components, at module level. This makes them singletons that persist for the lifetime of the application and are accessible from any component or non-component code.

```ts
// store/counter.ts
import { Store } from '@tanstack/store'

export const counterStore = new Store({ count: 0 })

export function increment() {
  counterStore.setState((prev) => ({ count: prev.count + 1 }))
}

export function decrement() {
  counterStore.setState((prev) => ({ count: prev.count - 1 }))
}

export function reset() {
  counterStore.setState(() => ({ count: 0 }))
}
```

**Key Points:**
- Encapsulating update functions alongside the store keeps mutation logic colocated and prevents direct `setState` calls from being scattered across components
- Stores do not need to be created inside React — they have no dependency on the React lifecycle

---

### `useStore` — Reading State Reactively

The `useStore` hook subscribes a component to a store and returns the selected value. The component re-renders when the selected value changes.

```tsx
import { useStore } from '@tanstack/react-store'
import { counterStore, increment, decrement, reset } from './store/counter'

function Counter() {
  const count = useStore(counterStore, (state) => state.count)

  return (
    <div>
      <p>Count: {count}</p>
      <button onClick={decrement}>−</button>
      <button onClick={increment}>+</button>
      <button onClick={reset}>Reset</button>
    </div>
  )
}
```

**Key Points:**
- `useStore(store, selector)` — the selector extracts the value the component cares about
- The component [Inference] only re-renders when the selected value changes by `===` comparison — actual behavior may vary
- Without a selector, the component re-renders on every store update regardless of which property changed
- `useStore` handles subscription and cleanup automatically — no `useEffect` cleanup is needed

---

### `useStore` Signature

```ts
useStore<TState, TSelected>(
  store: Store<TState> | Derived<TState>,
  selector: (state: TState) => TSelected,
  equalityFn?: (prev: TSelected, next: TSelected) => boolean
): TSelected
```

| Argument | Required | Description |
|---|---|---|
| `store` | Yes | A `Store` or `Derived` instance |
| `selector` | Yes | Function that extracts the value to observe |
| `equalityFn` | No | Custom equality function; defaults to `===` |

---

### Selectors and Re-render Control

Selectors are the primary tool for preventing unnecessary re-renders. Each component should select only the state it directly uses.

```tsx
const store = new Store({
  user: { name: 'Alice', role: 'admin' },
  notifications: 12,
  theme: 'dark',
})

// Only re-renders when notifications count changes
function NotificationBadge() {
  const count = useStore(store, (state) => state.notifications)
  return <span>{count}</span>
}

// Only re-renders when theme changes
function ThemeToggle() {
  const theme = useStore(store, (state) => state.theme)
  return <button>{theme === 'dark' ? '☀️' : '🌙'}</button>
}

// Only re-renders when user name changes
function UserGreeting() {
  const name = useStore(store, (state) => state.user.name)
  return <p>Hello, {name}</p>
}
```

**Key Points:**
- Each `useStore` call is an independent subscription — updating `notifications` does not cause `ThemeToggle` or `UserGreeting` to re-render
- Fine-grained selectors are preferable to selecting large objects when components use only a small portion of state

---

### `shallow` for Object and Array Selectors

When a selector returns a new object or array reference on every call, the default `===` equality always fails and the component re-renders on every store update. Use `shallow` to compare by value at one level deep.

```tsx
import { shallow } from '@tanstack/store'
import { useStore } from '@tanstack/react-store'

const store = new Store({
  user: { name: 'Alice', role: 'admin', age: 30 },
  theme: 'dark',
})

// Without shallow — new object reference every render, always re-renders
const user = useStore(store, (state) => ({ ...state.user }))

// With shallow — re-renders only when name, role, or age actually changes
const user = useStore(store, (state) => ({ ...state.user }), shallow)
```

For arrays:

```tsx
const store = new Store({
  items: [{ id: '1', name: 'Alpha' }, { id: '2', name: 'Beta' }],
})

// Re-renders only when the list of names actually changes
const names = useStore(
  store,
  (state) => state.items.map((item) => item.name),
  shallow
)
```

---

### Custom Equality Functions

For cases beyond `shallow`, a fully custom equality function can be passed as the third argument.

```tsx
import { useStore } from '@tanstack/react-store'

const store = new Store({
  items: [{ id: '1' }, { id: '2' }, { id: '3' }],
})

const compareIds = (a: string[], b: string[]) =>
  a.length === b.length && a.every((id, i) => id === b[i])

function ItemList() {
  const ids = useStore(
    store,
    (state) => state.items.map((item) => item.id),
    compareIds
  )

  return (
    <ul>
      {ids.map((id) => (
        <li key={id}>{id}</li>
      ))}
    </ul>
  )
}
```

**Key Points:**
- The equality function receives `(prevSelected, nextSelected)` and returns `true` if they are considered equal — no update
- Define equality functions outside the component or wrap in `useCallback` to maintain a stable reference and avoid unnecessary re-subscriptions

---

### Using `Derived` with `useStore`

`Derived` instances are compatible with `useStore` since they expose the same `.state` and `.subscribe()` interface as plain stores.

```ts
// store/order.ts
import { Store, Derived } from '@tanstack/store'

export const itemsStore = new Store([
  { id: '1', price: 20, qty: 2 },
  { id: '2', price: 15, qty: 3 },
])

export const taxRateStore = new Store(0.08)

export const subtotalDerived = new Derived({
  deps: [itemsStore],
  fn: () =>
    itemsStore.state.reduce((sum, item) => sum + item.price * item.qty, 0),
})

export const totalDerived = new Derived({
  deps: [subtotalDerived, taxRateStore],
  fn: () => subtotalDerived.state * (1 + taxRateStore.state),
})

subtotalDerived.mount()
totalDerived.mount()
```

```tsx
import { useStore } from '@tanstack/react-store'
import { subtotalDerived, totalDerived } from './store/order'

function OrderSummary() {
  const subtotal = useStore(subtotalDerived, (state) => state)
  const total = useStore(totalDerived, (state) => state)

  return (
    <div>
      <p>Subtotal: ${subtotal.toFixed(2)}</p>
      <p>Total (with tax): ${total.toFixed(2)}</p>
    </div>
  )
}
```

---

### Multiple Stores in One Component

A component can subscribe to multiple stores independently using multiple `useStore` calls.

```tsx
const userStore = new Store({ name: 'Alice', role: 'admin' })
const themeStore = new Store({ mode: 'dark', accent: 'blue' })
const notifStore = new Store({ unread: 5 })

function Dashboard() {
  const userName = useStore(userStore, (state) => state.name)
  const themeMode = useStore(themeStore, (state) => state.mode)
  const unread = useStore(notifStore, (state) => state.unread)

  return (
    <div data-theme={themeMode}>
      <h1>Welcome, {userName}</h1>
      <span>Unread: {unread}</span>
    </div>
  )
}
```

**Key Points:**
- Each `useStore` call is an independent subscription
- The component re-renders when any selected value from any of its subscriptions changes
- Splitting concerns across multiple focused stores rather than one large store can improve selector granularity

---

### Custom Hook Pattern

Encapsulating store subscriptions into custom hooks keeps components clean and makes the store binding reusable.

```ts
// hooks/useCounter.ts
import { useStore } from '@tanstack/react-store'
import { counterStore, increment, decrement, reset } from '../store/counter'

export function useCounter() {
  const count = useStore(counterStore, (state) => state.count)
  return { count, increment, decrement, reset }
}
```

```tsx
function Counter() {
  const { count, increment, decrement } = useCounter()
  return (
    <div>
      <p>{count}</p>
      <button onClick={decrement}>−</button>
      <button onClick={increment}>+</button>
    </div>
  )
}
```

**Key Points:**
- Custom hooks abstract the store and selector from the component, making it easier to change the underlying store without touching every consumer
- Update functions do not need to be returned from `useStore` — they are plain functions and can be imported or returned from the custom hook directly

---

### Subscribing to Store Changes Outside React

For side effects, persistence, or logging that should run independently of the React lifecycle, use `.subscribe()` directly on the store — not `useStore`.

```ts
// Runs outside React — no component lifecycle involved
counterStore.subscribe(() => {
  sessionStorage.setItem('count', String(counterStore.state.count))
})
```

**Key Points:**
- `.subscribe()` outside React is appropriate for persistence, analytics, logging, and cross-store synchronization
- `useStore` is only for driving React UI updates — it is not intended for side effects
- Manual subscriptions outside React do not need cleanup unless the subscription should stop at some point

---

### Full Working Example

```tsx
// store/todos.ts
import { Store, Derived } from '@tanstack/store'

export interface Todo {
  id: string
  text: string
  done: boolean
}

export const todosStore = new Store<Todo[]>([])

export const statsD = new Derived({
  deps: [todosStore],
  fn: () => ({
    total: todosStore.state.length,
    done: todosStore.state.filter((t) => t.done).length,
    pending: todosStore.state.filter((t) => !t.done).length,
  }),
})

statsD.mount()

export function addTodo(text: string) {
  todosStore.setState((prev) => [
    ...prev,
    { id: crypto.randomUUID(), text, done: false },
  ])
}

export function toggleTodo(id: string) {
  todosStore.setState((prev) =>
    prev.map((t) => (t.id === id ? { ...t, done: !t.done } : t))
  )
}

export function removeTodo(id: string) {
  todosStore.setState((prev) => prev.filter((t) => t.id !== id))
}
```

```tsx
// components/TodoApp.tsx
import { useState } from 'react'
import { useStore } from '@tanstack/react-store'
import { todosStore, statsD, addTodo, toggleTodo, removeTodo } from '../store/todos'
import { shallow } from '@tanstack/store'

function TodoStats() {
  const stats = useStore(statsD, (s) => s, shallow)
  return (
    <p>
      {stats.total} total — {stats.done} done — {stats.pending} pending
    </p>
  )
}

function TodoItem({ id }: { id: string }) {
  const todo = useStore(
    todosStore,
    (state) => state.find((t) => t.id === id)!,
    shallow
  )

  return (
    <li style={{ textDecoration: todo.done ? 'line-through' : 'none' }}>
      <input
        type="checkbox"
        checked={todo.done}
        onChange={() => toggleTodo(id)}
      />
      {todo.text}
      <button onClick={() => removeTodo(id)}>✕</button>
    </li>
  )
}

function TodoList() {
  const ids = useStore(
    todosStore,
    (state) => state.map((t) => t.id),
    shallow
  )

  return (
    <ul>
      {ids.map((id) => (
        <TodoItem key={id} id={id} />
      ))}
    </ul>
  )
}

export function TodoApp() {
  const [input, setInput] = useState('')

  const handleAdd = () => {
    if (input.trim()) {
      addTodo(input.trim())
      setInput('')
    }
  }

  return (
    <div>
      <h2>Todos</h2>
      <TodoStats />
      <input
        value={input}
        onChange={(e) => setInput(e.target.value)}
        onKeyDown={(e) => e.key === 'Enter' && handleAdd()}
        placeholder="Add a todo..."
      />
      <button onClick={handleAdd}>Add</button>
      <TodoList />
    </div>
  )
}
```

**Key Points:**
- `TodoList` selects only IDs — it re-renders only when the list of IDs changes, not when individual todo properties change
- `TodoItem` selects a single todo by ID — only the affected item re-renders when toggled or removed
- `TodoStats` uses `shallow` to avoid re-rendering when the stats object reference changes but values are the same
- `Derived` is used for stats computation so the reduction logic is not duplicated across components

---

### Common Pitfalls

**1. Selecting the entire state without a selector**

```tsx
// Re-renders on every state change — even unrelated properties
const state = useStore(store, (s) => s)

// Better — select only what this component needs
const count = useStore(store, (s) => s.count)
```

**2. Defining the selector inline when it returns a new object**

```tsx
// New object reference on every render — always triggers re-render
const user = useStore(store, (s) => ({ name: s.user.name, role: s.user.role }))

// Correct — add shallow as the third argument
const user = useStore(store, (s) => ({ name: s.user.name, role: s.user.role }), shallow)
```

**3. Placing `setState` calls directly inside the render body**

```tsx
// Wrong — causes an update loop
function MyComponent() {
  const count = useStore(counterStore, (s) => s.count)
  counterStore.setState((prev) => ({ count: prev.count + 1 })) // fires on every render
  return <span>{count}</span>
}
```

**4. Creating stores inside components**

```tsx
// Wrong — new store created on every render, state is lost on unmount
function MyComponent() {
  const store = new Store({ count: 0 }) // recreated every render
  const count = useStore(store, (s) => s.count)
  return <span>{count}</span>
}

// Correct — store created at module level, outside the component
const store = new Store({ count: 0 })
```

---

**Related Topics:**
- TanStack Store — Using with Angular (`injectStore`)
- TanStack Store — Using with Solid (`useStore` signal pattern)
- TanStack Store — Using with Vue (`useStore` computed ref pattern)
- TanStack Store — `Derived` and computed state
- TanStack Store — `shallow` and custom equality in depth
- TanStack Store — Subscriptions and side effects outside React
- TanStack Store — Persistence patterns with `localStorage` and `IndexedDB`