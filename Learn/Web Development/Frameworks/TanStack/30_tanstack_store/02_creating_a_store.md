## Creating a Store

TanStack Store's `Store` class is the foundational primitive for all reactive state in the TanStack ecosystem. Creating a store involves instantiating it with an initial state value and optionally configuring lifecycle hooks that fire during state updates.

---

### Installation

```bash
npm install @tanstack/store
```

**Key Points:**
- `@tanstack/store` is the framework-agnostic core package
- Framework adapter packages (`@tanstack/react-store`, `@tanstack/angular-store`, etc.) depend on this package and do not need to be installed separately when using a framework adapter
- Install `@tanstack/store` directly when using the store in framework-agnostic contexts or building library code

---

### Basic Store Creation

A store is created by instantiating the `Store` class with an initial state value. The initial state can be any JavaScript value — a primitive, object, or array.

```ts
import { Store } from '@tanstack/store'

// Primitive
const countStore = new Store(0)

// Object
const userStore = new Store({
  name: '',
  email: '',
  age: 0,
})

// Array
const tagsStore = new Store<string[]>([])
```

**Key Points:**
- The type of the store is inferred from the initial value when using TypeScript
- Explicit generic typing (`new Store<string[]>`) is used when the initial value alone is insufficient for inference (e.g., an empty array)

---

### Reading State

The current state of a store is always accessible synchronously via the `.state` property.

```ts
const countStore = new Store(42)

console.log(countStore.state) // 42
```

**Key Points:**
- `.state` is a plain synchronous read — not a signal, observable, or promise
- It reflects the current value at the time of access
- For reactive reads that update UI, framework adapters and `useStore` / `injectStore` are used instead (covered in the framework adapter topics)

---

### Updating State with `setState`

State is updated using the `.setState()` method, which accepts an updater function. The updater receives the previous state and must return the new state.

```ts
const countStore = new Store(0)

// Increment
countStore.setState((prev) => prev + 1)

// Reset
countStore.setState(() => 0)
```

For object state:

```ts
const userStore = new Store({ name: 'Alice', age: 30 })

// Update a single property — spread to preserve other properties
userStore.setState((prev) => ({
  ...prev,
  age: 31,
}))
```

**Key Points:**
- `setState` always uses an updater function — there is no direct value assignment API
- The updater must return a new value; TanStack Store does not perform deep mutation detection
- For objects and arrays, returning a new reference (via spread or array methods) is required to signal a change

---

### Store Initialization Options

The `Store` constructor accepts an optional second argument — a configuration object — with lifecycle hooks.

```ts
import { Store } from '@tanstack/store'

const store = new Store(
  { count: 0 },
  {
    onUpdate: () => {
      console.log('State updated:', store.state)
    },
  }
)
```

#### Available Options

| Option | Type | Description |
|---|---|---|
| `onUpdate` | `() => void` | Called after every state update |
| `onSubscribe` | `(listener, store) => () => void` | Called when a new subscriber is added; return value is an optional cleanup function |

**Key Points:**
- `onUpdate` fires synchronously after state has been committed
- `onSubscribe` allows side effects or cleanup logic when subscriptions change

---

### Subscribing to State Changes

The `.subscribe()` method registers a listener that is called whenever state changes. It returns an unsubscribe function.

```ts
const countStore = new Store(0)

const unsubscribe = countStore.subscribe(() => {
  console.log('New state:', countStore.state)
})

countStore.setState((prev) => prev + 1) // logs: New state: 1
countStore.setState((prev) => prev + 1) // logs: New state: 2

// Stop listening
unsubscribe()

countStore.setState((prev) => prev + 1) // no log
```

**Key Points:**
- The listener receives no arguments — state is read from `store.state` inside the callback
- `subscribe` returns an unsubscribe function; always call it during cleanup to avoid memory leaks
- Multiple listeners can be registered on a single store

---

### TypeScript Typing

TanStack Store is fully typed. The state type is inferred from the initial value or can be explicitly provided.

```ts
interface UserProfile {
  name: string
  email: string
  role: 'admin' | 'user'
}

const profileStore = new Store<UserProfile>({
  name: '',
  email: '',
  role: 'user',
})

// TypeScript enforces the shape in setState
profileStore.setState((prev) => ({
  ...prev,
  role: 'admin', // valid
}))

profileStore.setState((prev) => ({
  ...prev,
  role: 'superuser', // TypeScript error — not assignable to 'admin' | 'user'
}))
```

---

### Derived Values with `Derived`

TanStack Store provides a `Derived` class for computing values that depend on one or more stores. A `Derived` instance recomputes its value when any of its source stores change.

```ts
import { Store, Derived } from '@tanstack/store'

const firstNameStore = new Store('Jane')
const lastNameStore = new Store('Doe')

const fullNameDerived = new Derived({
  deps: [firstNameStore, lastNameStore],
  fn: () => `${firstNameStore.state} ${lastNameStore.state}`,
})

fullNameDerived.mount()

console.log(fullNameDerived.state) // 'Jane Doe'

firstNameStore.setState(() => 'John')

console.log(fullNameDerived.state) // 'John Doe'
```

**Key Points:**
- `deps` lists the stores this derived value depends on
- `fn` is the computation function — it reads from the dep stores directly via `.state`
- `.mount()` must be called to activate the derived computation and begin tracking changes
- `Derived` instances also expose `.subscribe()` and `.state` like regular stores
- [Inference] Unmounting or cleanup behavior for `Derived` may vary; consult current documentation for disposal patterns

---

### Using `batch` for Multiple Updates

When multiple `setState` calls should be treated as a single update (to avoid intermediate notifications), TanStack Store provides a `batch` utility.

```ts
import { Store, batch } from '@tanstack/store'

const store = new Store({ x: 0, y: 0 })

store.subscribe(() => {
  console.log('Updated:', store.state)
})

// Without batch — fires subscriber twice
store.setState((prev) => ({ ...prev, x: 1 }))
store.setState((prev) => ({ ...prev, y: 1 }))

// With batch — fires subscriber once
batch(() => {
  store.setState((prev) => ({ ...prev, x: 2 }))
  store.setState((prev) => ({ ...prev, y: 2 }))
})
// logs: Updated: { x: 2, y: 2 }
```

**Key Points:**
- `batch` defers subscriber notifications until all updates within the callback have been applied
- [Inference] This can reduce unnecessary intermediate renders or side effects when multiple related state changes are made together; actual behavior may vary

---

### Practical Pattern — Encapsulated Store Module

A common pattern is to encapsulate a store and its update logic in a module, exposing only the store instance and named update functions.

```ts
import { Store } from '@tanstack/store'

interface CartState {
  items: { id: string; qty: number }[]
  coupon: string | null
}

const cartStore = new Store<CartState>({
  items: [],
  coupon: null,
})

export function addItem(id: string, qty: number) {
  cartStore.setState((prev) => ({
    ...prev,
    items: [...prev.items, { id, qty }],
  }))
}

export function removeItem(id: string) {
  cartStore.setState((prev) => ({
    ...prev,
    items: prev.items.filter((item) => item.id !== id),
  }))
}

export function applyCoupon(code: string) {
  cartStore.setState((prev) => ({ ...prev, coupon: code }))
}

export function clearCart() {
  cartStore.setState(() => ({ items: [], coupon: null }))
}

export { cartStore }
```

**Key Points:**
- The store state is never mutated directly from outside the module
- Named update functions serve as the only public API for state changes
- This pattern works identically regardless of which framework adapter consumes `cartStore`

---

### Store Lifecycle Summary

```
new Store(initialState, options?)
        │
        ▼
   store.state          ← synchronous read at any time
        │
        ▼
   store.setState(fn)   ← triggers update
        │
        ├──▶ options.onUpdate()     ← fires after commit
        │
        └──▶ subscribers notified   ← all registered listeners called
```

---

**Related Topics:**
- TanStack Store — Framework Adapters (React, Solid, Vue, Angular, Svelte)
- TanStack Store — `Derived` and computed state in depth
- TanStack Store — Selectors and `shallow` equality
- TanStack Store — Using stores in framework-agnostic library code
- TanStack Store — Integration with TanStack Form internals
- TanStack Store — Integration with TanStack Router state