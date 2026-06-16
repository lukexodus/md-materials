## Comparing TanStack Store to Other State Managers

TanStack Store occupies a specific niche in the state management landscape: a minimal, framework-agnostic reactive primitive that prioritizes portability and simplicity over feature breadth. Comparing it against widely-used alternatives clarifies where it fits well and where other tools may be more appropriate.

---

### Libraries Covered

- **Zustand** — lightweight React-first store with hook-based API
- **Jotai** — atomic, bottom-up state model for React
- **Recoil** — Facebook's atomic state library for React
- **Pinia** — Vue's official state management library
- **NgRx** — Angular's Redux-inspired state management
- **Redux Toolkit** — the modern, opinionated Redux experience
- **MobX** — observable-based reactive state with automatic dependency tracking
- **Valtio** — proxy-based mutable state for React

---

### High-Level Positioning

| Library | Primary Target | Model | Bundle Size (approx) |
|---|---|---|---|
| TanStack Store | Framework-agnostic | Immutable, subscription-based | ~1–2 KB |
| Zustand | React | Immutable, hook-based | ~1 KB |
| Jotai | React | Atomic, bottom-up | ~3–4 KB |
| Recoil | React | Atomic, graph-based | ~20 KB+ |
| Pinia | Vue | Module-based, mutable | ~2–3 KB |
| NgRx | Angular | Redux/flux, action-based | ~30–50 KB |
| Redux Toolkit | React (and others) | Redux, action-based | ~15–20 KB |
| MobX | Framework-agnostic | Observable, mutable | ~16 KB |
| Valtio | React | Proxy-based, mutable | ~3 KB |

> [Unverified] Bundle sizes are approximate and vary by version, tree-shaking, and build configuration. Always verify with current package data (e.g., bundlephobia.com) for accurate figures.

---

### TanStack Store vs. Zustand

Zustand and TanStack Store are the closest conceptual relatives — both are minimal, immutable, and subscription-based. The primary difference is framework scope.

#### API Comparison

```ts
// Zustand
import { create } from 'zustand'

const useCounterStore = create<{ count: number; increment: () => void }>((set) => ({
  count: 0,
  increment: () => set((state) => ({ count: state.count + 1 })),
}))

// In a React component
const count = useCounterStore((state) => state.count)
```

```ts
// TanStack Store
import { Store } from '@tanstack/store'
import { useStore } from '@tanstack/react-store'

const counterStore = new Store({ count: 0 })

export function increment() {
  counterStore.setState((prev) => ({ count: prev.count + 1 }))
}

// In a React component
const count = useStore(counterStore, (state) => state.count)
```

#### Key Differences

| Aspect | Zustand | TanStack Store |
|---|---|---|
| Framework support | React-first; community adapters for others | Official adapters for React, Solid, Vue, Angular, Svelte |
| Update functions | Colocated inside `create` via `set` | Defined externally; `setState` called directly |
| Middleware | Built-in (`devtools`, `persist`, `immer`) | No built-in middleware; compose manually |
| DevTools | Built-in Zustand devtools middleware | No built-in DevTools integration |
| `Derived` / computed | Via selectors or `zustand/middleware` | First-class `Derived` class |
| Async actions | Defined inside `create` | Plain async functions calling `setState` |

**Key Points:**
- Zustand's `create` colocates state and actions, which some find more ergonomic for React-only projects
- TanStack Store's external update function pattern is more portable — the same functions work in any framework without modification
- Zustand has a richer middleware ecosystem out of the box; TanStack Store requires manual composition for persistence, devtools, and immer integration

---

### TanStack Store vs. Jotai

Jotai takes a fundamentally different approach — state is broken into atoms (small units), and components subscribe only to the atoms they use. There is no single store object.

```ts
// Jotai
import { atom, useAtom } from 'jotai'

const countAtom = atom(0)
const doubledAtom = atom((get) => get(countAtom) * 2)

// In a React component
const [count, setCount] = useAtom(countAtom)
const doubled = useAtomValue(doubledAtom)
```

```ts
// TanStack Store equivalent pattern
const countStore = new Store(0)
const doubledDerived = new Derived({
  deps: [countStore],
  fn: () => countStore.state * 2,
})
doubledDerived.mount()
```

#### Key Differences

| Aspect | Jotai | TanStack Store |
|---|---|---|
| State model | Bottom-up atoms | Top-down store objects |
| Granularity | Per-atom subscriptions naturally | Per-selector subscriptions via `useStore` |
| Derived state | `atom((get) => ...)` inline | `Derived` class, explicit deps array |
| Framework support | React only | React, Solid, Vue, Angular, Svelte |
| Provider | Optional `Provider` for scoping | No provider needed |
| DevTools | Jotai DevTools available | No built-in DevTools |
| Async state | `atomWithQuery`, async read atoms | Plain async functions |

**Key Points:**
- Jotai's atomic model naturally produces highly granular subscriptions without explicit selectors — each atom is its own subscription unit
- TanStack Store requires explicit selectors to achieve the same granularity
- Jotai is React-only; TanStack Store targets multiple frameworks
- [Inference] For large React apps with many small, interdependent state units, Jotai's atomic model may reduce subscription boilerplate compared to TanStack Store's selector approach

---

### TanStack Store vs. Recoil

Recoil is Facebook's atomic state library, with a graph-based dependency model similar in concept to Jotai but with a significantly larger footprint and more built-in features.

```ts
// Recoil
import { atom, selector, useRecoilValue } from 'recoil'

const countState = atom({ key: 'count', default: 0 })
const doubledState = selector({
  key: 'doubled',
  get: ({ get }) => get(countState) * 2,
})

// In a React component (must be inside RecoilRoot)
const count = useRecoilValue(countState)
const doubled = useRecoilValue(doubledState)
```

#### Key Differences

| Aspect | Recoil | TanStack Store |
|---|---|---|
| Framework support | React only | Multi-framework |
| Provider required | Yes — `RecoilRoot` wraps the app | No |
| Bundle size | ~20 KB+ | ~1–2 KB |
| Atom keys | Required string keys (must be unique) | No key system |
| Async selectors | Built-in `Suspense`-compatible async selectors | Plain async functions |
| DevTools | Recoil DevTools available | No built-in DevTools |
| Maintenance status | [Unverified] Reduced activity as of 2024–2025 | Actively maintained |

**Key Points:**
- Recoil's required string keys add boilerplate and create a potential source of key collision bugs in large applications
- TanStack Store has no provider requirement — stores are plain module-level instances
- Recoil's bundle size is significantly larger than TanStack Store for comparable basic use cases

---

### TanStack Store vs. Pinia

Pinia is Vue's official state management library, succeeding Vuex. It is designed specifically for Vue and integrates deeply with Vue's Composition API and DevTools.

```ts
// Pinia
import { defineStore } from 'pinia'

export const useCounterStore = defineStore('counter', {
  state: () => ({ count: 0 }),
  getters: {
    doubled: (state) => state.count * 2,
  },
  actions: {
    increment() { this.count++ },
  },
})

// In a Vue component
const store = useCounterStore()
store.count       // reactive
store.doubled     // reactive getter
store.increment() // action
```

```ts
// TanStack Store in Vue
import { useStore } from '@tanstack/vue-store'
const count = useStore(counterStore, (s) => s.count)
// count is a computed ref
```

#### Key Differences

| Aspect | Pinia | TanStack Store |
|---|---|---|
| Framework support | Vue only | Multi-framework |
| Mutation style | Direct mutation in actions (`this.count++`) | Immutable via `setState` |
| Getters | Declared inside `defineStore` | `Derived` class |
| DevTools | Deep Vue DevTools integration (time-travel, patch events) | No built-in DevTools |
| SSR support | Built-in SSR hydration helpers | Manual |
| Stores as composables | Yes — `useCounterStore()` returns reactive proxy | No — store is a plain class instance |

**Key Points:**
- Pinia's direct mutation in actions is more ergonomic within the Vue ecosystem but ties the state library to Vue
- Pinia's Vue DevTools integration provides time-travel debugging and state inspection that TanStack Store does not offer out of the box
- TanStack Store's Vue adapter (`@tanstack/vue-store`) is appropriate for Vue projects that share state logic with other frameworks or need framework-portability

---

### TanStack Store vs. NgRx

NgRx is Angular's dominant state management solution, inspired by Redux with actions, reducers, effects, and selectors as first-class concepts.

```ts
// NgRx
// action
export const increment = createAction('[Counter] Increment')

// reducer
export const counterReducer = createReducer(
  { count: 0 },
  on(increment, (state) => ({ count: state.count + 1 }))
)

// selector
export const selectCount = createSelector(
  selectCounterState,
  (state) => state.count
)

// In a component
count$ = this.store.select(selectCount)
```

```ts
// TanStack Store in Angular
count = injectStore(counterStore, (s) => s.count)
// count is an Angular Signal
```

#### Key Differences

| Aspect | NgRx | TanStack Store |
|---|---|---|
| Framework support | Angular only | Multi-framework |
| Architecture | Flux/Redux — actions, reducers, effects | Direct `setState` — no actions or reducers |
| Boilerplate | High — actions, reducers, effects, selectors each require declaration | Low — store + update functions |
| Effects | `@ngrx/effects` for async side effects | Plain async functions |
| DevTools | Redux DevTools integration | No built-in DevTools |
| Bundle size | ~30–50 KB | ~1–2 KB |
| Learning curve | Steep | Shallow |
| Enforced patterns | Strong — unidirectional data flow enforced | Minimal |

**Key Points:**
- NgRx enforces strict unidirectional data flow and a clear separation of concerns — beneficial for large teams where consistency is critical
- TanStack Store's Angular adapter (`@tanstack/angular-store`) is a practical alternative for Angular projects that do not need NgRx's full architectural constraints or have simpler state requirements
- NgRx's action log and time-travel debugging via Redux DevTools has no equivalent in TanStack Store

---

### TanStack Store vs. Redux Toolkit

Redux Toolkit (RTK) is the modern, opinionated wrapper around Redux that reduces boilerplate while retaining Redux's action-based architecture.

```ts
// Redux Toolkit
import { createSlice, configureStore } from '@reduxjs/toolkit'

const counterSlice = createSlice({
  name: 'counter',
  initialState: { count: 0 },
  reducers: {
    increment: (state) => { state.count++ }, // Immer under the hood
    decrement: (state) => { state.count-- },
  },
})

const store = configureStore({ reducer: { counter: counterSlice.reducer } })
```

```ts
// TanStack Store equivalent
const counterStore = new Store({ count: 0 })

export function increment() {
  counterStore.setState((prev) => ({ count: prev.count + 1 }))
}
```

#### Key Differences

| Aspect | Redux Toolkit | TanStack Store |
|---|---|---|
| Framework support | React-first; framework-agnostic core | Multi-framework with official adapters |
| Update style | Actions dispatched to reducers (Immer built in) | Direct `setState` updater functions |
| Async | `createAsyncThunk`, RTK Query | Plain async functions |
| DevTools | Full Redux DevTools (time-travel, action log) | No built-in DevTools |
| API data fetching | RTK Query (full-featured) | Out of scope — use TanStack Query |
| Bundle size | ~15–20 KB | ~1–2 KB |
| Boilerplate | Moderate (reduced from plain Redux) | Minimal |

**Key Points:**
- RTK's Immer integration allows mutative syntax in reducers while producing immutable updates — TanStack Store requires explicit spread or Immer usage
- RTK Query is a full server-state solution built into Redux Toolkit; TanStack Store has no equivalent — TanStack Query fills this role in the TanStack ecosystem
- Redux Toolkit's action log makes it easier to audit what changed and why — TanStack Store provides no equivalent audit trail by default

---

### TanStack Store vs. MobX

MobX uses an observable-based reactive model where state mutations are tracked automatically through a dependency graph — no explicit `setState` or selectors required.

```ts
// MobX
import { makeAutoObservable } from 'mobx'

class CounterStore {
  count = 0

  constructor() { makeAutoObservable(this) }

  increment() { this.count++ }
  get doubled() { return this.count * 2 }
}

const counter = new CounterStore()

// In a React component (with mobx-react-lite)
const CounterView = observer(() => (
  <p>{counter.count} / {counter.doubled}</p>
))
```

#### Key Differences

| Aspect | MobX | TanStack Store |
|---|---|---|
| Mutation style | Direct mutation — `this.count++` | Immutable — `setState((prev) => ...)` |
| Reactivity | Automatic dependency tracking | Explicit selectors |
| Derived values | `computed` via getter + `makeAutoObservable` | `Derived` class with explicit `deps` |
| Framework support | React, Vue, Angular (community) | React, Solid, Vue, Angular, Svelte (official) |
| DevTools | MobX DevTools | No built-in DevTools |
| Mental model | Observable graph — implicit | Subscription/selector — explicit |

**Key Points:**
- MobX's automatic dependency tracking reduces boilerplate but can make reactivity harder to reason about in large applications — it is not always obvious which observers re-run when state changes
- TanStack Store's explicit selector model requires more deliberate subscription setup but makes reactivity boundaries clear and predictable
- [Inference] MobX's automatic tracking may introduce subtle performance issues in large reactive graphs if dependency boundaries are not carefully managed — actual behavior depends on usage patterns

---

### TanStack Store vs. Valtio

Valtio uses JavaScript `Proxy` to intercept mutations and drive reactivity, allowing direct mutable syntax while producing reactive updates.

```ts
// Valtio
import { proxy, useSnapshot } from 'valtio'

const state = proxy({ count: 0 })

function increment() {
  state.count++ // direct mutation
}

// In a React component
function Counter() {
  const snap = useSnapshot(state)
  return <p>{snap.count}</p>
}
```

#### Key Differences

| Aspect | Valtio | TanStack Store |
|---|---|---|
| Mutation style | Direct mutation via Proxy | Immutable via `setState` |
| Framework support | React-first; Vue community adapter | Multi-framework official adapters |
| Reactivity model | Proxy-based, auto-tracked | Subscription + selector |
| Derived state | `derive` utility | `Derived` class |
| DevTools | No built-in | No built-in |
| Mental model | Mutable, imperative | Immutable, functional |

**Key Points:**
- Valtio's proxy model is ergonomic for developers who prefer mutable syntax, but [Inference] the proxy indirection can make debugging more opaque compared to explicit `setState` calls — actual developer experience varies
- TanStack Store's immutable model provides a clearer audit trail — every state change is an explicit function call
- Valtio is primarily React-focused; TanStack Store has broader official multi-framework support

---

### Feature Matrix Summary

| Feature | TanStack Store | Zustand | Jotai | Pinia | NgRx | Redux Toolkit | MobX | Valtio |
|---|---|---|---|---|---|---|---|---|
| Multi-framework | ✅ | Partial | ❌ | ❌ | ❌ | Partial | Partial | ❌ |
| No provider needed | ✅ | ✅ | ✅ | ✅ | ❌ | ❌ | ✅ | ✅ |
| Immutable updates | ✅ | ✅ | ✅ | ❌ | ✅ | ✅ (Immer) | ❌ | ❌ |
| Built-in DevTools | ❌ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ |
| First-class derived | ✅ | Partial | ✅ | ✅ | ✅ | Partial | ✅ | ✅ |
| Middleware system | ❌ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ |
| SSR helpers | ❌ | Partial | ✅ | ✅ | ✅ | ✅ | Partial | Partial |
| Bundle size | Minimal | Minimal | Small | Small | Large | Medium | Medium | Small |
| Learning curve | Low | Low | Low | Low | High | Medium | Medium | Low |

> [Unverified] Feature presence and partial support status reflect general library capabilities as of the knowledge cutoff and may not reflect recent releases. Verify with current documentation for each library.

---

### When to Choose TanStack Store

TanStack Store is a strong fit when:

- The project spans multiple frameworks or a framework-agnostic library is being built
- State logic needs to be shared with or extracted from TanStack Form or TanStack Router internals
- A minimal, low-overhead reactive primitive is preferred over a full state management framework
- The team wants explicit, auditable state updates without action/reducer ceremony
- Bundle size is a priority

TanStack Store may not be the best fit when:

- Deep DevTools integration (time-travel, action logs) is required — consider Redux Toolkit or NgRx
- Rich middleware (persist, devtools, immer out of the box) is needed — consider Zustand or Pinia
- Atomic, bottom-up state granularity is preferred — consider Jotai
- The project is an Angular enterprise app with strict architectural conventions — consider NgRx
- Server state management is the primary concern — consider TanStack Query regardless of which client state tool is chosen

---

**Related Topics:**
- TanStack Store — Core concepts and `Store` class
- TanStack Store — `Derived` and computed state
- TanStack Store — Framework adapters (React, Solid, Vue, Angular, Svelte)
- TanStack Query — Server state management in the TanStack ecosystem
- TanStack Form — Internal use of TanStack Store for form state
- Combining TanStack Store with TanStack Query for full client + server state