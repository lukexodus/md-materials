## Derived State and Selectors

TanStack Store provides two distinct mechanisms for computing or extracting values from store state: **`Derived`** — a reactive computation that depends on one or more stores and produces its own observable state — and **selectors** — functions passed to framework adapter hooks that extract a slice of state and control when reactive updates fire. Understanding the difference between these two tools and when to use each is central to building efficient, maintainable state logic with TanStack Store.

---

### Conceptual Distinction

| Concept | What It Is | Where It Lives | When It Recomputes |
|---|---|---|---|
| `Derived` | A reactive store computed from other stores | Outside components, at module level | When any dep store changes |
| Selector | A function passed to `useStore` / `injectStore` | At the read site (component or hook) | On every store update; equality check determines if output changed |

- Use `Derived` when the computed value is shared across multiple components or needs to exist independently of any component lifecycle
- Use selectors when extracting or transforming state for a specific component's needs

---

### `Derived` — Reactive Computed Stores

The `Derived` class creates a read-only store whose value is computed from one or more source stores. It recomputes whenever any of its dependencies change.

#### Basic Usage

```ts
import { Store, Derived } from '@tanstack/store'

const priceStore = new Store(50)
const quantityStore = new Store(3)

const totalDerived = new Derived({
  deps: [priceStore, quantityStore],
  fn: () => priceStore.state * quantityStore.state,
})

totalDerived.mount()

console.log(totalDerived.state) // 150

quantityStore.setState(() => 5)

console.log(totalDerived.state) // 250
```

**Key Points:**
- `deps` is an array of store instances (or other `Derived` instances) this computation depends on
- `fn` is the computation function — it reads from deps via their `.state` property directly
- `.mount()` activates the derived instance and begins tracking dependency changes
- Before `.mount()` is called, `totalDerived.state` [Inference] may be undefined or stale — always mount before reading
- `Derived` exposes `.state`, `.subscribe()`, and is compatible with framework adapter hooks

---

### `Derived` Constructor Options

```ts
new Derived<TValue>({
  deps: Store[] | Derived[],
  fn: () => TValue,
  onUpdate?: () => void,
  onSubscribe?: (listener, store) => () => void,
})
```

| Option | Type | Description |
|---|---|---|
| `deps` | `(Store \| Derived)[]` | Source stores or derived instances to track |
| `fn` | `() => TValue` | Computation function; returns the derived value |
| `onUpdate` | `() => void` | Called after each recomputation |
| `onSubscribe` | `(listener, store) => () => void` | Called when a subscriber is added |

---

### Mounting and Cleanup

`Derived` instances must be explicitly mounted. The `.mount()` method returns a cleanup function that should be called when the derived instance is no longer needed.

```ts
const cleanup = totalDerived.mount()

// Later, when the derived instance is no longer needed:
cleanup()
```

**Key Points:**
- Calling `cleanup()` unsubscribes the `Derived` instance from all its dep stores
- In component-level usage with framework adapters, the adapter [Inference] handles mounting and cleanup automatically when the component mounts and unmounts — verify with current adapter documentation
- For module-level `Derived` instances that persist for the lifetime of the application, calling `cleanup()` explicitly is typically unnecessary

---

### Chaining `Derived` Instances

A `Derived` instance can itself be a dependency of another `Derived`, enabling multi-level reactive computation chains.

```ts
import { Store, Derived } from '@tanstack/store'

const itemsStore = new Store([
  { id: 1, price: 20, qty: 2 },
  { id: 2, price: 15, qty: 3 },
])

const subtotalDerived = new Derived({
  deps: [itemsStore],
  fn: () =>
    itemsStore.state.reduce((sum, item) => sum + item.price * item.qty, 0),
})

const taxRateStore = new Store(0.08)

const totalWithTaxDerived = new Derived({
  deps: [subtotalDerived, taxRateStore],
  fn: () => subtotalDerived.state * (1 + taxRateStore.state),
})

subtotalDerived.mount()
totalWithTaxDerived.mount()

console.log(subtotalDerived.state)    // 85
console.log(totalWithTaxDerived.state) // 91.8

taxRateStore.setState(() => 0.1)

console.log(totalWithTaxDerived.state) // 93.5
```

**Key Points:**
- Mount order matters when chaining — mount upstream `Derived` instances before downstream ones
- [Inference] Deep chains may introduce recomputation overhead proportional to chain depth; actual performance characteristics depend on update frequency and chain length

---

### Using `Derived` with Framework Adapters

`Derived` instances are compatible with the same `useStore` / `injectStore` hooks used for regular stores, since they expose the same `.state` and `.subscribe()` interface.

#### React

```tsx
import { useStore } from '@tanstack/react-store'

function OrderTotal() {
  const total = useStore(totalWithTaxDerived, (state) => state)
  return <span>Total: ${total.toFixed(2)}</span>
}
```

#### Angular

```ts
import { injectStore } from '@tanstack/angular-store'

export class OrderSummaryComponent {
  total = injectStore(totalWithTaxDerived, (state) => state)
}
```

#### Solid

```tsx
import { useStore } from '@tanstack/solid-store'

function OrderTotal() {
  const total = useStore(totalWithTaxDerived, (state) => state)
  return <span>Total: ${total().toFixed(2)}</span>
}
```

**Key Points:**
- Passing `(state) => state` as the selector returns the entire derived value
- A more specific selector can be used if the derived value is an object and only a portion is needed
- Framework adapters handle subscription to the `Derived` instance the same way they handle regular stores

---

### Selectors

A selector is a function passed as the second argument to `useStore`, `injectStore`, or equivalent framework adapter hooks. It extracts a specific slice or transformation of store state, and the framework adapter uses it to determine whether a reactive update should fire.

```ts
const store = new Store({
  user: { name: 'Alice', role: 'admin' },
  theme: 'dark',
  notifications: 42,
})

// Only re-renders when notifications count changes
const count = useStore(store, (state) => state.notifications)

// Only re-renders when user name changes
const name = useStore(store, (state) => state.user.name)
```

**Key Points:**
- Selectors run on every store update
- After the selector runs, the result is compared to the previous result using an equality function (default: `===`)
- If the equality check passes (values are equal), the component or signal does not update
- If it fails (values differ), the component re-renders or the signal updates

---

### Selector Equality — Default Behavior

By default, TanStack Store uses strict reference equality (`===`) to compare selector output between updates.

```ts
const store = new Store({ items: ['a', 'b', 'c'], count: 3 })

// Primitive — === works correctly
const count = useStore(store, (state) => state.count)
// Updates only when count changes numerically

// Existing object reference — === works correctly
const items = useStore(store, (state) => state.items)
// Updates only when items array reference is replaced

// Derived object — === always fails (new reference every call)
const summary = useStore(store, (state) => ({
  total: state.items.length,
  first: state.items[0],
}))
// Updates on every store change regardless of actual value change
```

**Key Points:**
- Primitive selectors work correctly with default equality
- Selectors that return existing references from state work correctly with default equality
- Selectors that construct new objects or arrays on every call always fail the `===` check and cause unnecessary updates — use `shallow` or a custom equality function for these

---

### `shallow` Equality

`shallow` performs a one-level key-by-key comparison for objects or index-by-index comparison for arrays. It is imported from `@tanstack/store` and passed as the third argument to framework adapter hooks.

```ts
import { shallow } from '@tanstack/store'
import { useStore } from '@tanstack/react-store'

const store = new Store({
  user: { name: 'Alice', role: 'admin' },
  theme: 'dark',
})

// Without shallow — new object every render triggers update always
const user = useStore(store, (state) => ({ ...state.user }))

// With shallow — updates only when name or role actually changes
const user = useStore(store, (state) => ({ ...state.user }), shallow)
```

#### How `shallow` Works

```ts
// Object comparison — checks each key at one level
shallow({ a: 1, b: 2 }, { a: 1, b: 2 }) // true — equal
shallow({ a: 1, b: 2 }, { a: 1, b: 3 }) // false — b differs
shallow({ a: { x: 1 } }, { a: { x: 1 } }) // false — nested object is new reference

// Array comparison — checks each index at one level
shallow([1, 2, 3], [1, 2, 3]) // true — equal
shallow([1, 2, 3], [1, 2, 4]) // false — index 2 differs
shallow([[1]], [[1]])           // false — nested array is new reference
```

**Key Points:**
- `shallow` only compares one level deep — nested objects and arrays are still compared by reference
- For deeply nested structures, a custom equality function is required
- `shallow` is most effective when selecting flat object slices or flat arrays of primitives

---

### Custom Equality Functions

For cases where `shallow` is insufficient, a fully custom equality function can be passed as the third argument.

```ts
import { useStore } from '@tanstack/react-store'

interface Item { id: string; name: string }

const store = new Store({
  items: [
    { id: '1', name: 'Alpha' },
    { id: '2', name: 'Beta' },
  ],
})

// Select only the IDs — update only when the set of IDs changes
const itemIds = useStore(
  store,
  (state) => state.items.map((item) => item.id),
  (a, b) => a.length === b.length && a.every((id, i) => id === b[i])
)
```

**Key Points:**
- The equality function receives `(prevSelected, nextSelected)` and returns `true` if they are considered equal (no update)
- The equality function should be a stable reference — define it outside the component or use `useCallback` / `useMemo` in React to avoid creating a new reference on every render
- Custom equality functions can encode any domain-specific comparison logic

---

### Combining `Derived` and Selectors

`Derived` and selectors can be used together — a selector on a `Derived` instance extracts a specific portion of the derived value.

```ts
const orderDerived = new Derived({
  deps: [itemsStore, taxRateStore],
  fn: () => ({
    subtotal: itemsStore.state.reduce((s, i) => s + i.price * i.qty, 0),
    tax: itemsStore.state.reduce((s, i) => s + i.price * i.qty, 0) * taxRateStore.state,
    itemCount: itemsStore.state.length,
  }),
})

orderDerived.mount()

// Component only re-renders when itemCount changes
const itemCount = useStore(orderDerived, (state) => state.itemCount)

// Component only re-renders when subtotal changes
const subtotal = useStore(orderDerived, (state) => state.subtotal)
```

**Key Points:**
- `Derived` computes the full value; selectors further narrow which part of it triggers updates
- This combination avoids recomputing the same derived logic in multiple places while still giving each consumer fine-grained update control

---

### Decision Guide

```
Need a computed value?
│
├── Shared across components or lives outside component lifecycle?
│       └── Use Derived
│
└── Needed only inside one component or hook?
        └── Use a selector in useStore / injectStore
                │
                ├── Selector returns a primitive?
                │       └── Default equality (no extra arg needed)
                │
                ├── Selector returns an existing object reference?
                │       └── Default equality (no extra arg needed)
                │
                ├── Selector constructs a new flat object or array?
                │       └── Use shallow
                │
                └── Selector constructs a deeply nested value?
                        └── Use a custom equality function
```

---

**Related Topics:**
- TanStack Store — Reading state and `useStore` in depth
- TanStack Store — Subscriptions and cleanup patterns
- TanStack Store — Performance optimization with selectors
- TanStack Store — Using `Derived` in Angular with `injectStore`
- TanStack Store — Framework adapter hooks (React, Solid, Vue, Angular, Svelte)
- TanStack Store — Combining with TanStack Form's `form.useStore`