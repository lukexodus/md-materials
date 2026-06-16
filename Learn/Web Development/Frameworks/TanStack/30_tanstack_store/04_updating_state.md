## Updating State

TanStack Store provides a single, consistent mechanism for updating state: the `setState` method. All state mutations flow through this method, which accepts an updater function and notifies subscribers after the update is committed. Additional tools — `batch` and store options — provide control over when and how notifications fire.

---

### `setState` — The Only Update Mechanism

State in TanStack Store is never mutated directly. All updates go through `.setState()`, which receives an updater function. The updater takes the previous state and returns the new state.

```ts
import { Store } from '@tanstack/store'

const store = new Store({ count: 0 })

store.setState((prev) => ({ ...prev, count: prev.count + 1 }))

console.log(store.state.count) // 1
```

**Key Points:**
- There is no `.set(value)` API — the updater function pattern is the only interface
- The updater must return a new value; TanStack Store does not diff or patch — it replaces
- For objects and arrays, always return a new reference rather than mutating the existing value

---

### Updater Function Signature

```ts
store.setState(updater: (prevState: TState) => TState): void
```

The updater receives the most recently committed state as `prev` and must return the complete new state.

```ts
const userStore = new Store({
  name: 'Alice',
  role: 'user',
  loginCount: 0,
})

// Update one property — spread to preserve others
userStore.setState((prev) => ({
  ...prev,
  loginCount: prev.loginCount + 1,
}))

// Replace the entire state
userStore.setState(() => ({
  name: 'Bob',
  role: 'admin',
  loginCount: 0,
}))
```

**Key Points:**
- Always spread (`...prev`) when updating a single property of an object state to avoid unintentionally dropping other properties
- Replacing the entire state is valid — pass a new object without spreading when a full reset is intended
- The updater return value is the complete next state, not a patch or partial update

---

### Primitive State Updates

For stores holding primitive values, the updater simply returns the new primitive.

```ts
const countStore = new Store(0)
const labelStore = new Store('hello')
const flagStore = new Store(false)

countStore.setState((prev) => prev + 1)
countStore.setState((prev) => prev * 2)
countStore.setState(() => 0)             // reset

labelStore.setState((prev) => prev.toUpperCase())
labelStore.setState(() => 'reset label')

flagStore.setState((prev) => !prev)
```

---

### Object State Updates

Object state updates require returning a new object. The spread operator is the standard approach for partial updates.

```ts
const profileStore = new Store({
  firstName: 'Jane',
  lastName: 'Doe',
  age: 28,
  preferences: {
    theme: 'light',
    language: 'en',
  },
})

// Shallow update — one top-level property
profileStore.setState((prev) => ({
  ...prev,
  age: 29,
}))

// Nested update — must spread at every level
profileStore.setState((prev) => ({
  ...prev,
  preferences: {
    ...prev.preferences,
    theme: 'dark',
  },
}))
```

**Key Points:**
- TanStack Store does not perform deep merging — nested objects must be explicitly spread when partially updating them
- Forgetting to spread a nested object replaces it entirely with only the properties included in the return value
- [Inference] Structural sharing (reusing unchanged nested references) is not automatically performed; libraries like Immer can be combined with `setState` to handle deep updates more ergonomically if needed

---

### Array State Updates

Array state follows the same immutable pattern — always return a new array rather than mutating the existing one.

```ts
const listStore = new Store<string[]>(['apple', 'banana'])

// Add an item
listStore.setState((prev) => [...prev, 'cherry'])

// Remove an item by value
listStore.setState((prev) => prev.filter((item) => item !== 'banana'))

// Remove an item by index
listStore.setState((prev) => prev.filter((_, i) => i !== 0))

// Update an item at index
listStore.setState((prev) =>
  prev.map((item, i) => (i === 1 ? 'blueberry' : item))
)

// Sort (must copy first — sort mutates in place)
listStore.setState((prev) => [...prev].sort())

// Clear
listStore.setState(() => [])
```

**Key Points:**
- `Array.prototype.sort()` and `Array.prototype.reverse()` mutate in place — always copy the array first with `[...prev]` before calling them
- `push`, `pop`, `splice`, and `shift` also mutate in place and must not be called on `prev` directly

---

### Using Immer for Complex Updates

For deeply nested state, TanStack Store can be combined with Immer's `produce` to write mutations in a more readable imperative style while still producing a new immutable reference.

```ts
import { Store } from '@tanstack/store'
import { produce } from 'immer'

const store = new Store({
  users: [
    { id: 1, name: 'Alice', settings: { notifications: true } },
    { id: 2, name: 'Bob', settings: { notifications: false } },
  ],
})

// Without Immer — verbose spreading at every level
store.setState((prev) => ({
  ...prev,
  users: prev.users.map((u) =>
    u.id === 1
      ? { ...u, settings: { ...u.settings, notifications: false } }
      : u
  ),
}))

// With Immer — write mutations directly
store.setState((prev) =>
  produce(prev, (draft) => {
    const user = draft.users.find((u) => u.id === 1)
    if (user) user.settings.notifications = false
  })
)
```

**Key Points:**
- Immer's `produce` receives the previous state as a draft and returns a new immutable object after mutations are applied
- This pattern is entirely opt-in — TanStack Store has no built-in dependency on Immer
- [Inference] Immer adds bundle size overhead; it is most worthwhile for deeply nested or frequently updated state shapes

---

### `batch` — Deferring Notifications

By default, each `setState` call immediately notifies all subscribers. The `batch` utility defers all notifications until the batch callback completes, coalescing multiple updates into a single notification cycle.

```ts
import { Store, batch } from '@tanstack/store'

const store = new Store({ x: 0, y: 0, z: 0 })

let notifyCount = 0
store.subscribe(() => notifyCount++)

// Without batch — three separate notifications
store.setState((prev) => ({ ...prev, x: 1 }))
store.setState((prev) => ({ ...prev, y: 1 }))
store.setState((prev) => ({ ...prev, z: 1 }))
console.log(notifyCount) // 3

notifyCount = 0

// With batch — single notification after all updates
batch(() => {
  store.setState((prev) => ({ ...prev, x: 2 }))
  store.setState((prev) => ({ ...prev, y: 2 }))
  store.setState((prev) => ({ ...prev, z: 2 }))
})
console.log(notifyCount) // 1
```

**Key Points:**
- `batch` is useful when several interdependent state changes should be treated as a single atomic update
- Subscribers still see the final committed state — no intermediate states are observable from outside
- [Inference] In framework adapter contexts, `batch` may reduce unnecessary intermediate re-renders or signal updates; actual behavior depends on the framework adapter and its integration with the framework's rendering scheduler

#### `batch` Across Multiple Stores

`batch` coordinates notifications across multiple store instances within the same callback.

```ts
import { Store, batch } from '@tanstack/store'

const storeA = new Store(0)
const storeB = new Store(0)

batch(() => {
  storeA.setState(() => 1)
  storeB.setState(() => 1)
})
// Subscribers of both storeA and storeB are notified once each,
// after the batch completes
```

---

### `onUpdate` Hook

The store options object accepts an `onUpdate` callback that fires after every committed state update, including batched updates.

```ts
const store = new Store(
  { count: 0 },
  {
    onUpdate: () => {
      console.log('Store updated. New state:', store.state)
    },
  }
)

store.setState((prev) => ({ count: prev.count + 1 }))
// logs: Store updated. New state: { count: 1 }
```

**Key Points:**
- `onUpdate` is called after state is committed and before subscribers are notified [Inference: ordering may vary — verify with current documentation]
- It is defined once at store creation and cannot be changed after instantiation
- Useful for logging, persistence side effects, or debugging

---

### Resetting State

TanStack Store has no built-in reset method, but a reset can be implemented by capturing the initial state and restoring it via `setState`.

```ts
const initialState = { count: 0, label: 'default' }

const store = new Store(initialState)

function resetStore() {
  store.setState(() => ({ ...initialState }))
}

store.setState((prev) => ({ ...prev, count: 5 }))
console.log(store.state.count) // 5

resetStore()
console.log(store.state.count) // 0
```

**Key Points:**
- Spreading `initialState` in the reset function (`{ ...initialState }`) produces a new reference, ensuring subscribers are notified
- For stores with nested objects, a deep clone of `initialState` may be needed to prevent shared references between the reset state and the original constant

---

### Conditional Updates

Returning the previous state unchanged from `setState` does not prevent subscribers from being notified — TanStack Store does not perform equality checks on the returned value before notifying.

```ts
// This will still notify subscribers even if value has not changed
store.setState((prev) => {
  if (prev.count >= 10) return prev // same reference returned
  return { ...prev, count: prev.count + 1 }
})
```

> [Inference] Returning `prev` unchanged may or may not suppress subscriber notifications depending on the TanStack Store version and any future optimizations. Do not rely on this behavior for performance optimization; use selectors with equality functions at the read layer instead. Actual behavior is not guaranteed.

---

### Update Patterns Summary

| Scenario | Pattern |
|---|---|
| Primitive increment/toggle | `setState((prev) => prev + 1)` |
| Single object property | `setState((prev) => ({ ...prev, key: value }))` |
| Nested object property | `setState((prev) => ({ ...prev, nested: { ...prev.nested, key: value } }))` |
| Deep nested update | `setState((prev) => produce(prev, draft => { ... }))` with Immer |
| Array append | `setState((prev) => [...prev, newItem])` |
| Array remove | `setState((prev) => prev.filter(...))` |
| Array update at index | `setState((prev) => prev.map((item, i) => i === idx ? newItem : item))` |
| Full reset | `setState(() => ({ ...initialState }))` |
| Multiple coordinated updates | Wrap in `batch(() => { ... })` |

---

**Related Topics:**
- TanStack Store — Reading state and selectors
- TanStack Store — `Derived` and computed state
- TanStack Store — `shallow` and custom equality for read optimization
- TanStack Store — Subscriptions and cleanup patterns
- TanStack Store — Integrating Immer for immutable deep updates
- TanStack Store — Framework adapter update patterns (React, Angular, Solid, Vue)