## Subscribing to Store Changes

TanStack Store's subscription system is the low-level mechanism by which external code reacts to state changes. Subscriptions sit beneath the framework adapter layer — `useStore`, `injectStore`, and equivalent hooks all use subscriptions internally. Understanding subscriptions directly is essential for framework-agnostic code, side effects, persistence, logging, and any context where framework adapter hooks are unavailable.

---

### How Subscriptions Work

When `setState` is called and state is committed, TanStack Store notifies all registered listeners synchronously. Each listener is a plain function with no arguments — state is read from `store.state` inside the callback.

```
store.setState(fn)
       │
       ▼
  state committed
       │
       ▼
  all listeners called (synchronously)
       │
       ├── listener 1()
       ├── listener 2()
       └── listener 3()
```

**Key Points:**
- Listeners are called synchronously after state is committed
- Listeners receive no arguments — always read from `store.state` inside the callback
- Multiple listeners can be registered on a single store
- Listener call order [Inference] follows registration order, though this is not part of any documented guarantee — do not rely on ordering between listeners

---

### Registering a Subscription

The `.subscribe()` method registers a listener and returns an unsubscribe function.

```ts
import { Store } from '@tanstack/store'

const store = new Store({ count: 0 })

const unsubscribe = store.subscribe(() => {
  console.log('State changed:', store.state)
})

store.setState((prev) => ({ count: prev.count + 1 }))
// logs: State changed: { count: 1 }

store.setState((prev) => ({ count: prev.count + 1 }))
// logs: State changed: { count: 2 }

// Stop receiving updates
unsubscribe()

store.setState((prev) => ({ count: prev.count + 1 }))
// no log
```

**Key Points:**
- Always store the return value of `.subscribe()` when the subscription needs to be stopped
- Failing to call the unsubscribe function when it is no longer needed will cause the listener to remain registered for the lifetime of the store, which may lead to memory leaks or unintended side effects
- Calling `unsubscribe()` is idempotent — calling it multiple times is safe

---

### Multiple Subscribers

Any number of listeners can be registered on a single store. Each is notified independently on every state update.

```ts
const store = new Store(0)

const unsub1 = store.subscribe(() => {
  console.log('Listener 1:', store.state)
})

const unsub2 = store.subscribe(() => {
  console.log('Listener 2:', store.state)
})

store.setState((prev) => prev + 1)
// logs: Listener 1: 1
// logs: Listener 2: 1

unsub1()

store.setState((prev) => prev + 1)
// logs: Listener 2: 2
```

**Key Points:**
- Each subscriber holds an independent reference — unsubscribing one does not affect others
- All active subscribers see the same committed state value on each update

---

### Subscribing to `Derived` Instances

`Derived` instances expose the same `.subscribe()` interface as regular stores. Listeners fire whenever the derived value recomputes.

```ts
import { Store, Derived } from '@tanstack/store'

const priceStore = new Store(100)
const qtyStore = new Store(2)

const totalDerived = new Derived({
  deps: [priceStore, qtyStore],
  fn: () => priceStore.state * qtyStore.state,
})

totalDerived.mount()

const unsubscribe = totalDerived.subscribe(() => {
  console.log('Total updated:', totalDerived.state)
})

priceStore.setState(() => 150)
// logs: Total updated: 300

qtyStore.setState(() => 3)
// logs: Total updated: 450

unsubscribe()
```

**Key Points:**
- Subscribing to a `Derived` instance is identical in API to subscribing to a plain store
- The listener fires after the derived value has recomputed — `totalDerived.state` reflects the new value inside the callback
- The `Derived` instance must be mounted before subscriptions will fire

---

### The `onSubscribe` Option

The store options object accepts an `onSubscribe` callback that fires each time a new subscriber is added. It receives the listener function and the store instance, and can optionally return a cleanup function that runs when that subscriber unsubscribes.

```ts
const store = new Store(
  { count: 0 },
  {
    onSubscribe: (listener, store) => {
      console.log('New subscriber added. Current state:', store.state)

      // Optional cleanup — runs when this specific subscriber unsubscribes
      return () => {
        console.log('Subscriber removed')
      }
    },
  }
)

const unsub = store.subscribe(() => {
  console.log('Update:', store.state)
})
// logs: New subscriber added. Current state: { count: 0 }

unsub()
// logs: Subscriber removed
```

**Key Points:**
- `onSubscribe` fires once per subscriber registration, not once per update
- The returned cleanup function is scoped to the specific subscriber that triggered `onSubscribe` — it runs when that subscriber's unsubscribe function is called
- `onSubscribe` is useful for tracking active subscriber counts, starting or stopping external data sources based on interest, or logging subscription lifecycle events

---

### Subscription Use Cases

#### Logging and Debugging

```ts
const store = new Store({ user: null, token: null })

if (process.env.NODE_ENV === 'development') {
  store.subscribe(() => {
    console.debug('[AuthStore]', JSON.stringify(store.state, null, 2))
  })
}
```

#### Persisting State to `localStorage`

```ts
const store = new Store(
  JSON.parse(localStorage.getItem('app-settings') ?? '{}') ?? {
    theme: 'light',
    language: 'en',
  }
)

store.subscribe(() => {
  localStorage.setItem('app-settings', JSON.stringify(store.state))
})
```

**Key Points:**
- This pattern hydrates from `localStorage` on store creation and persists on every update
- [Inference] For high-frequency updates, debouncing the write inside the subscriber may reduce unnecessary I/O — actual performance impact depends on update frequency and storage write cost

#### Syncing Across Browser Tabs with `BroadcastChannel`

```ts
const channel = new BroadcastChannel('settings-sync')

const store = new Store({ theme: 'light' })

// Send updates to other tabs
store.subscribe(() => {
  channel.postMessage(store.state)
})

// Receive updates from other tabs
channel.onmessage = (event) => {
  store.setState(() => event.data)
}
```

> [Inference] Without a guard, this creates a broadcast loop — each tab's incoming message triggers a `setState`, which triggers a broadcast, and so on. A loop guard (e.g., a flag or message source identifier) should be added in production use.

#### Triggering Side Effects

```ts
const cartStore = new Store<{ items: CartItem[] }>({ items: [] })

cartStore.subscribe(() => {
  const count = cartStore.state.items.length
  document.title = count > 0 ? `Cart (${count})` : 'Shop'
})
```

#### Sending Analytics Events

```ts
let previousState = store.state

store.subscribe(() => {
  const next = store.state

  if (next.currentPage !== previousState.currentPage) {
    analytics.track('page_view', { page: next.currentPage })
  }

  previousState = next
})
```

**Key Points:**
- Capturing `previousState` outside the subscriber and updating it inside enables diffing between updates
- This pattern is necessary because the subscriber receives no previous state argument — only `store.state` (the new state) is available inside the callback

---

### Tracking Previous State in Subscribers

Since subscriber callbacks receive no arguments, tracking previous state requires capturing it in the closure.

```ts
const store = new Store({ score: 0 })

let prev = store.state

store.subscribe(() => {
  const next = store.state

  if (next.score > prev.score) {
    console.log(`Score increased by ${next.score - prev.score}`)
  } else if (next.score < prev.score) {
    console.log(`Score decreased by ${prev.score - next.score}`)
  }

  prev = next
})

store.setState((s) => ({ score: s.score + 5 }))
// logs: Score increased by 5

store.setState((s) => ({ score: s.score - 2 }))
// logs: Score decreased by 2
```

---

### Subscriptions and `batch`

When multiple `setState` calls are wrapped in `batch`, subscribers are notified once after all updates in the batch are committed — not once per `setState` call.

```ts
import { Store, batch } from '@tanstack/store'

const store = new Store({ x: 0, y: 0 })

store.subscribe(() => {
  console.log('Notified:', store.state)
})

batch(() => {
  store.setState((prev) => ({ ...prev, x: 1 }))
  store.setState((prev) => ({ ...prev, y: 1 }))
})
// logs: Notified: { x: 1, y: 1 }  (once, not twice)
```

**Key Points:**
- Inside a `batch`, intermediate states are not observable by subscribers
- Subscribers always see the final state after all batched updates have been applied
- `batch` applies across multiple stores — if two stores are updated in one `batch`, each store's subscribers are notified once after the batch completes

---

### Subscription Cleanup Patterns by Framework

Subscriptions must be cleaned up when a component or service is destroyed. Each framework has its own idiomatic cleanup location.

#### React

```tsx
import { useEffect } from 'react'
import { Store } from '@tanstack/store'

const store = new Store({ count: 0 })

function MyComponent() {
  useEffect(() => {
    const unsubscribe = store.subscribe(() => {
      console.log('count:', store.state.count)
    })

    return unsubscribe // React calls this on unmount
  }, [])

  return <div />
}
```

#### Angular

```ts
import { Component, OnDestroy } from '@angular/core'

@Component({ selector: 'app-example', template: '' })
export class ExampleComponent implements OnDestroy {
  private unsubscribe: () => void

  constructor() {
    this.unsubscribe = store.subscribe(() => {
      console.log('Updated:', store.state)
    })
  }

  ngOnDestroy() {
    this.unsubscribe()
  }
}
```

#### Solid

```tsx
import { onCleanup } from 'solid-js'

function MyComponent() {
  const unsubscribe = store.subscribe(() => {
    console.log('Updated:', store.state)
  })

  onCleanup(unsubscribe)

  return <div />
}
```

#### Vue

```ts
import { onUnmounted } from 'vue'

export default {
  setup() {
    const unsubscribe = store.subscribe(() => {
      console.log('Updated:', store.state)
    })

    onUnmounted(unsubscribe)
  },
}
```

#### Svelte

```svelte
<script>
  import { onDestroy } from 'svelte'

  const unsubscribe = store.subscribe(() => {
    console.log('Updated:', store.state)
  })

  onDestroy(unsubscribe)
</script>
```

---

### Framework Adapter Hooks vs. Manual Subscriptions

| Concern | Framework Adapter Hook | Manual Subscription |
|---|---|---|
| UI reactivity | Yes — triggers re-render or signal update | No — does not interact with framework rendering |
| Selector support | Yes — built-in | Manual — implement in subscriber body |
| Cleanup | Handled automatically | Must be handled explicitly |
| Use outside components | No | Yes |
| Side effects (logging, persistence) | Not intended for this | Correct tool |
| SSR compatibility | Depends on adapter | Manual management required |

**Key Points:**
- Framework adapter hooks (`useStore`, `injectStore`) are the correct tool for driving UI updates
- Manual subscriptions are the correct tool for side effects, persistence, cross-tab sync, analytics, and any logic that runs outside a component
- Mixing both on the same store is valid and common — framework adapters and manual subscribers coexist independently

---

### Common Pitfalls

**1. Not unsubscribing on cleanup**

```ts
// Wrong — subscriber lives forever even after component unmounts
store.subscribe(() => { ... })

// Correct — capture and call the unsubscribe function
const unsubscribe = store.subscribe(() => { ... })
// call unsubscribe() in cleanup
```

**2. Reading stale state via closure**

```ts
// Risky — 'value' captured at subscription time, not at update time
const value = store.state.count
store.subscribe(() => {
  console.log(value) // always logs the initial value
})

// Correct — read from store.state inside the callback
store.subscribe(() => {
  console.log(store.state.count) // always current
})
```

**3. Triggering `setState` inside a subscriber without a guard**

```ts
// Dangerous — may cause infinite update loop
store.subscribe(() => {
  store.setState((prev) => ({ ...prev, lastUpdated: Date.now() }))
})
```

> [Inference] Whether this causes an infinite loop depends on TanStack Store's internal cycle detection, which is not publicly documented as a guaranteed safeguard. Avoid calling `setState` unconditionally inside a subscriber. Use a condition or external flag to guard against infinite loops.

---

**Related Topics:**
- TanStack Store — Reading state and selectors
- TanStack Store — Updating state with `setState` and `batch`
- TanStack Store — `Derived` subscriptions and mount lifecycle
- TanStack Store — `onUpdate` and `onSubscribe` store options
- TanStack Store — Framework adapter hooks vs. manual subscriptions
- TanStack Store — Persistence patterns with `localStorage` and `IndexedDB`