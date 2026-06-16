## Reading State

TanStack Store provides several mechanisms for reading state depending on context: synchronous direct access via `.state`, reactive subscriptions via `.subscribe()`, selector-based access via framework adapter hooks, and derived computations via `Derived`. Choosing the correct mechanism depends on whether the read needs to be reactive, framework-bound, or computed.

---

### Direct Synchronous Access via `.state`

The simplest way to read state is the `.state` property on any store instance. It always returns the current state value synchronously.

```ts
import { Store } from '@tanstack/store'

const store = new Store({ count: 0, label: 'hello' })

console.log(store.state)         // { count: 0, label: 'hello' }
console.log(store.state.count)   // 0
```

**Key Points:**
- `.state` is a plain property read — no function call, no subscription
- It reflects the value at the exact moment of access
- It does not trigger any reactivity or notify any subscribers
- Suitable for one-time reads, imperative logic, and non-UI code

---

### Reading State Inside `setState`

The updater function passed to `setState` receives the previous state as its argument, which is the correct way to read state when the new state depends on the old state.

```ts
const counterStore = new Store(0)

counterStore.setState((prev) => {
  console.log('Previous:', prev) // 0
  return prev + 1
})
```

**Key Points:**
- Always use the `prev` argument inside `setState` rather than reading `store.state` directly, to avoid stale closure issues
- The `prev` value passed to the updater is guaranteed to be the most recent committed state at the time `setState` executes

---

### Reading State in Subscriptions

The `.subscribe()` callback fires after every state update. Inside the callback, state is read from `store.state`.

```ts
const store = new Store({ name: 'Alice' })

store.subscribe(() => {
  // Read current state after update
  console.log('Name is now:', store.state.name)
})

store.setState((prev) => ({ ...prev, name: 'Bob' }))
// logs: Name is now: Bob
```

**Key Points:**
- The subscriber callback receives no arguments — state must be read from `store.state` explicitly
- The subscriber fires after state has been committed, so `store.state` is always up to date inside it
- Multiple subscribers on the same store all receive notification of the same update

---

### Selective Reading with Selectors

A selector is a function that extracts a specific slice of state from a store. Selectors are used with framework adapter hooks (`useStore`, `injectStore`) to limit reactive updates to only the parts of state a component actually needs.

```ts
// Selector — extracts only the count property
const selectCount = (state: { count: number; label: string }) => state.count
```

In framework adapters, the selector is passed as the second argument:

```ts
// React
const count = useStore(store, (state) => state.count)

// Angular
const count = injectStore(store, (state) => state.count)
```

**Key Points:**
- When a selector is provided, the framework adapter [Inference] only triggers a re-render or signal update when the selected value changes, not on every store update — actual behavior may vary by adapter and version
- Without a selector, the component [Inference] re-renders or updates on every state change regardless of which property changed
- Selectors should be pure functions with no side effects
- Selectors are not memoized by default — if the selector itself creates a new object or array on every call, equality checks will always fail

---

### Selector Equality and `shallow`

By default, TanStack Store uses strict reference equality (`===`) to determine whether a selected value has changed. For selectors that return objects or arrays, this means a new object returned from the selector is always treated as a change even if its contents are identical.

TanStack Store provides a `shallow` equality helper to handle this case.

```ts
import { Store } from '@tanstack/store'
import { useStore } from '@tanstack/react-store'
import { shallow } from '@tanstack/store'

const store = new Store({
  user: { name: 'Alice', role: 'admin' },
  theme: 'dark',
})

// Without shallow — new object reference triggers update every time
const user = useStore(store, (state) => ({ ...state.user }))

// With shallow — only updates when name or role actually changes
const user = useStore(store, (state) => ({ ...state.user }), shallow)
```

**Key Points:**
- `shallow` performs a one-level key-by-key equality check on objects and index-by-index check on arrays
- It does not perform deep equality — nested objects are still compared by reference
- Pass `shallow` as the third argument to `useStore` / `injectStore` / equivalent adapter hooks
- [Inference] Using `shallow` where appropriate may reduce unnecessary re-renders when selecting object slices; actual impact depends on the framework adapter and rendering strategy

#### When to Use `shallow`

| Selector Return Type | Equality Strategy | Rationale |
|---|---|---|
| Primitive (`number`, `string`, `boolean`) | Default (`===`) | Primitives compare by value natively |
| Existing object reference (`state.user`) | Default (`===`) | Same reference unless object was replaced |
| Derived object (`{ ...state.user }`) | `shallow` | New reference created every call |
| Derived array (`state.items.filter(...)`) | `shallow` | New array reference created every call |
| Deeply nested structure | Custom equality fn | `shallow` only checks one level |

---

### Custom Equality Functions

If `shallow` is insufficient, a fully custom equality function can be passed as the third argument to framework adapter hooks.

```ts
import { useStore } from '@tanstack/react-store'

const selectIds = (state: { items: { id: string }[] }) =>
  state.items.map((item) => item.id)

const idsEqual = (a: string[], b: string[]) =>
  a.length === b.length && a.every((id, i) => id === b[i])

// Only re-renders when the list of IDs actually changes
const ids = useStore(store, selectIds, idsEqual)
```

**Key Points:**
- The custom equality function receives `(previousSelected, nextSelected)` and returns `true` if they are considered equal (no update needed)
- Custom equality functions should be stable references (defined outside the component or memoized) to avoid unnecessary re-evaluations

---

### Reading Derived State with `Derived`

`Derived` computes a value from one or more stores and exposes it via its own `.state` property and `.subscribe()` method. It behaves as a read-only store.

```ts
import { Store, Derived } from '@tanstack/store'

const priceStore = new Store(100)
const taxRateStore = new Store(0.1)

const totalDerived = new Derived({
  deps: [priceStore, taxRateStore],
  fn: () => priceStore.state * (1 + taxRateStore.state),
})

totalDerived.mount()

console.log(totalDerived.state) // 110

priceStore.setState(() => 200)

console.log(totalDerived.state) // 220
```

**Key Points:**
- `totalDerived.state` is read the same way as a regular store's `.state`
- The `fn` function recomputes whenever any dep store changes
- `.mount()` must be called before the derived state is active
- `Derived` instances can themselves be used as deps for other `Derived` instances, enabling derived chains
- [Inference] Derived chains may introduce additional recomputation overhead for deep dependency trees; actual performance characteristics depend on the number of deps and update frequency

---

### Reading State in Framework Adapters

Each framework adapter exposes a hook or injection function that reads store state reactively. The selected value is kept in sync with the store automatically.

#### React

```tsx
import { useStore } from '@tanstack/react-store'

function Counter() {
  const count = useStore(counterStore, (state) => state.count)
  return <span>{count}</span>
}
```

#### Solid

```tsx
import { useStore } from '@tanstack/solid-store'

function Counter() {
  const count = useStore(counterStore, (state) => state.count)
  return <span>{count()}</span> // count is a signal accessor
}
```

#### Vue

```ts
import { useStore } from '@tanstack/vue-store'

const count = useStore(counterStore, (state) => state.count)
// count is a computed ref — use count.value in script, count in template
```

#### Angular

```ts
import { injectStore } from '@tanstack/angular-store'

export class CounterComponent {
  count = injectStore(counterStore, (state) => state.count)
  // count is an Angular Signal — use count() in template
}
```

#### Svelte

```ts
import { useStore } from '@tanstack/svelte-store'

const count = useStore(counterStore, (state) => state.count)
// count is a Svelte readable store — use $count in template
```

**Key Points:**
- All framework adapters follow the same selector pattern but return framework-native reactive primitives
- In Solid, the return value is a signal accessor; always call it with `()`
- In Angular, the return value is an Angular Signal; call it with `()` in templates
- In Vue, the return value is a `computed` ref; use `.value` in script context, bare name in templates
- In Svelte, the return value is a Svelte readable; prefix with `$` in templates

---

### Reading State Outside Components

For imperative or non-UI code (utilities, services, event handlers), `.state` is always directly available without a framework adapter.

```ts
// In a utility function
function logCartTotal(cartStore: Store<CartState>) {
  const total = cartStore.state.items.reduce(
    (sum, item) => sum + item.price * item.qty,
    0
  )
  console.log('Cart total:', total)
}

// In an Angular service
@Injectable({ providedIn: 'root' })
export class CartService {
  getTotal(): number {
    return cartStore.state.items.reduce(
      (sum, item) => sum + item.price * item.qty,
      0
    )
  }
}
```

---

### Summary — Choosing a Read Mechanism

| Scenario | Mechanism |
|---|---|
| One-time read in logic or utilities | `store.state` |
| Read previous value during update | `setState((prev) => ...)` |
| React to every state change | `store.subscribe()` |
| Reactive read in a UI component | Framework adapter (`useStore`, `injectStore`) |
| Reactive read of a computed value | `Derived` + `.state` or framework adapter |
| Reactive read of an object slice | Framework adapter + `shallow` |
| Reactive read with custom equality | Framework adapter + custom equality fn |

---

**Related Topics:**
- TanStack Store — Updating state (`setState`, `batch`)
- TanStack Store — `Derived` and computed state in depth
- TanStack Store — `shallow` and custom equality functions
- TanStack Store — Framework adapter hooks in depth (React, Solid, Vue, Angular, Svelte)
- TanStack Store — Subscriptions and cleanup patterns
- TanStack Store — Selectors and performance optimization