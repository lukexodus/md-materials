# Zustand: A Comprehensive Guide

Zustand (German for "state") is a small, fast, and scalable state management library for React. It is built on top of React hooks and makes no assumptions about your architecture. This guide covers everything from first principles to advanced patterns.

---

## What Zustand Is

Zustand is a minimal state management library created by Jotai and React Spring author Daishi Kato, maintained under the `pmndrs` (Poimandres) open-source collective. It provides a global store outside of React's component tree, exposed through hooks. Compared to Redux, it requires no boilerplate; compared to React Context, it does not cause all consumers to re-render when unrelated state changes.

Key characteristics:

- No providers required (though optional provider-based stores exist)
- Subscriptions are selector-based: components only re-render when the slice they select changes
- Works outside React (vanilla JS subscriptions)
- Supports middleware (devtools, persist, immer, subscribeWithSelector, and more)
- TypeScript-first in practice, though not written in TypeScript itself
- Very small bundle size (around 1 KB gzipped at its core)

---

## Installation

```bash
npm install zustand
# or
yarn add zustand
# or
pnpm add zustand
```

No peer dependencies beyond React 16.8+ are required for basic usage.

---

## Core Concepts

### The Store

A store in Zustand is a custom hook created with `create`. It holds state and the functions (actions) that mutate it. You do not need to wrap your app in a provider to use it.

```ts
import { create } from 'zustand'

interface BearState {
  bears: number
  increase: () => void
  reset: () => void
}

const useBearStore = create<BearState>((set) => ({
  bears: 0,
  increase: () => set((state) => ({ bears: state.bears + 1 })),
  reset: () => set({ bears: 0 }),
}))
```

### Reading State in Components

Call the store hook with a selector function. The component only re-renders when the selected value changes (by reference equality, by default).

```tsx
function BearCounter() {
  const bears = useBearStore((state) => state.bears)
  return <h1>{bears} bears</h1>
}

function Controls() {
  const increase = useBearStore((state) => state.increase)
  return <button onClick={increase}>Add bear</button>
}
```

Because `increase` is a function defined once during store creation, its reference is stable. `Controls` will not re-render when `bears` changes.

### The `set` Function

`set` merges state shallowly by default, similar to `setState` in class components.

```ts
set({ bears: 5 })             // merges: { bears: 5, ...rest }
set((state) => ({ bears: state.bears + 1 }))  // functional update
set({ bears: 5 }, true)       // second arg `true` = replace, not merge
```

Use the replace flag (`true`) when you want to wipe the entire store state — useful in testing or logout flows.

### The `get` Function

The initializer callback also receives `get`, which reads the current state without subscribing.

```ts
const useStore = create<State>((set, get) => ({
  count: 0,
  doubled: () => get().count * 2,
  increment: () => set({ count: get().count + 1 }),
}))
```

---

## Selectors and Re-renders

### Why Selectors Matter

Without a selector, calling `useStore()` with no argument returns the entire state object. This causes the component to re-render on any state change.

```tsx
// Bad: re-renders on any store change
const state = useStore()

// Good: re-renders only when `bears` changes
const bears = useStore((state) => state.bears)
```

### Selecting Multiple Values

To select multiple values at once, return an object or array from the selector. Because a new object is created on every call, you must provide a custom equality function, or use `useShallow`.

```tsx
import { useShallow } from 'zustand/react/shallow'

// Object selector with useShallow
const { bears, fish } = useStore(
  useShallow((state) => ({ bears: state.bears, fish: state.fish }))
)

// Array selector with useShallow
const [bears, fish] = useStore(
  useShallow((state) => [state.bears, state.fish])
)
```

`useShallow` performs a shallow equality check over the selected value's keys (for objects) or indices (for arrays). It was introduced in Zustand v4.4.

### Custom Equality Functions

For finer control, pass your own comparator as the second argument.

```tsx
const user = useStore(
  (state) => state.user,
  (a, b) => a.id === b.id  // only re-render if user ID changes
)
```

---

## Organizing State and Actions

### Co-locating Actions with State

The recommended pattern is to define actions inside `create` alongside the state they modify.

```ts
interface TaskState {
  tasks: Task[]
  addTask: (task: Task) => void
  removeTask: (id: string) => void
  toggleTask: (id: string) => void
}

const useTaskStore = create<TaskState>((set) => ({
  tasks: [],
  addTask: (task) =>
    set((state) => ({ tasks: [...state.tasks, task] })),
  removeTask: (id) =>
    set((state) => ({ tasks: state.tasks.filter((t) => t.id !== id) })),
  toggleTask: (id) =>
    set((state) => ({
      tasks: state.tasks.map((t) =>
        t.id === id ? { ...t, done: !t.done } : t
      ),
    })),
}))
```

### Slices Pattern

For large stores, split into slices and merge them with `create`.

```ts
// bearSlice.ts
interface BearSlice {
  bears: number
  addBear: () => void
}

const createBearSlice = (set: SetState<BoundState>): BearSlice => ({
  bears: 0,
  addBear: () => set((state) => ({ bears: state.bears + 1 })),
})

// fishSlice.ts
interface FishSlice {
  fish: number
  addFish: () => void
}

const createFishSlice = (set: SetState<BoundState>): FishSlice => ({
  fish: 0,
  addFish: () => set((state) => ({ fish: state.fish + 1 })),
})

// store.ts
type BoundState = BearSlice & FishSlice

const useBoundStore = create<BoundState>((...args) => ({
  ...createBearSlice(...args),
  ...createFishSlice(...args),
}))
```

The `...args` pattern passes `set`, `get`, and the store instance through to each slice creator.

### Computed Values (Derived State)

Derived state is best computed outside the store as a selector, not stored as state.

```ts
// Avoid storing derived state:
// totalDone: state.tasks.filter(t => t.done).length  // don't do this

// Prefer a selector:
const totalDone = useTaskStore((state) => state.tasks.filter((t) => t.done).length)
```

If the computation is expensive, memoize it externally with `useMemo` or a library like `reselect`.

---

## TypeScript Usage

### Typing the Store

The type parameter passed to `create<T>` types both the state and the return of the initializer.

```ts
interface State {
  count: number
  increment: () => void
}

const useStore = create<State>((set) => ({
  count: 0,
  increment: () => set((s) => ({ count: s.count + 1 })),
}))
```

### Typing with Middleware

When using middleware such as `persist` or `devtools`, you need to compose the types. The `StateCreator` utility type helps.

```ts
import { create, StateCreator } from 'zustand'
import { persist, devtools } from 'zustand/middleware'

interface State {
  count: number
  increment: () => void
}

const useStore = create<State>()(
  devtools(
    persist(
      (set) => ({
        count: 0,
        increment: () => set((s) => ({ count: s.count + 1 })),
      }),
      { name: 'count-storage' }
    )
  )
)
```

Note the `create<State>()()` curried call pattern — this is required when using middleware to correctly infer types.

### Typing Slices

```ts
import { StateCreator } from 'zustand'

type BoundState = BearSlice & FishSlice

interface BearSlice {
  bears: number
  addBear: () => void
}

const createBearSlice: StateCreator<BoundState, [], [], BearSlice> = (set) => ({
  bears: 0,
  addBear: () => set((s) => ({ bears: s.bears + 1 })),
})
```

The four type parameters of `StateCreator` are: the full store type, mutators on the store (e.g., from `immer`), mutators on this slice, and this slice's type.

---

## Middleware

Middleware wraps the `set` function (and sometimes `get` and the store), adding behavior before or after state updates.

### devtools

Integrates with Redux DevTools browser extension for time-travel debugging.

```ts
import { devtools } from 'zustand/middleware'

const useStore = create<State>()(
  devtools(
    (set) => ({
      count: 0,
      increment: () => set((s) => ({ count: s.count + 1 }), false, 'increment'),
    }),
    { name: 'MyStore', enabled: process.env.NODE_ENV !== 'production' }
  )
)
```

The third argument to `set` is an action name that appears in DevTools. `enabled: false` in production is advisable.

### persist

Persists store state to `localStorage`, `sessionStorage`, or any custom storage engine.

```ts
import { persist, createJSONStorage } from 'zustand/middleware'

const useStore = create<State>()(
  persist(
    (set) => ({
      theme: 'light',
      setTheme: (theme) => set({ theme }),
    }),
    {
      name: 'theme-storage',           // localStorage key
      storage: createJSONStorage(() => sessionStorage), // optional
      partialize: (state) => ({ theme: state.theme }), // only persist `theme`
      version: 1,                      // for migrations
      migrate: (persisted, version) => {
        if (version === 0) {
          // migrate from v0 to v1
        }
        return persisted as State
      },
    }
  )
)
```

The `partialize` option lets you exclude actions (functions) or sensitive fields from storage.

#### Persist with Custom Storage

```ts
import { StateStorage } from 'zustand/middleware'

const asyncStorage: StateStorage = {
  getItem: async (name) => {
    return await AsyncStorage.getItem(name) // React Native example
  },
  setItem: async (name, value) => {
    await AsyncStorage.setItem(name, value)
  },
  removeItem: async (name) => {
    await AsyncStorage.removeItem(name)
  },
}
```

### immer

Allows writing mutations in actions directly (via Immer's draft proxy), instead of manually spreading objects.

```ts
import { immer } from 'zustand/middleware/immer'

interface State {
  users: { id: string; name: string }[]
  updateName: (id: string, name: string) => void
}

const useStore = create<State>()(
  immer((set) => ({
    users: [],
    updateName: (id, name) =>
      set((state) => {
        const user = state.users.find((u) => u.id === id)
        if (user) user.name = name  // direct mutation is safe in Immer draft
      }),
  }))
)
```

### subscribeWithSelector

Enables granular subscriptions outside of React with optional change detection.

```ts
import { subscribeWithSelector } from 'zustand/middleware'

const useStore = create<State>()(
  subscribeWithSelector((set) => ({
    count: 0,
    increment: () => set((s) => ({ count: s.count + 1 })),
  }))
)

// Subscribe to only `count`
const unsubscribe = useStore.subscribe(
  (state) => state.count,
  (count, prevCount) => {
    console.log(`count changed from ${prevCount} to ${count}`)
  }
)

// Cleanup
unsubscribe()
```

### Combining Multiple Middlewares

Middlewares compose by nesting. Order matters: the outermost wrapper runs first.

```ts
const useStore = create<State>()(
  devtools(
    persist(
      immer((set) => ({
        // ...
      })),
      { name: 'my-storage' }
    ),
    { name: 'MyStore' }
  )
)
```

---

## Reading and Writing Outside React

Zustand stores expose their state and methods directly on the hook object, making them usable outside of components.

```ts
// Read current state
const state = useStore.getState()

// Write state
useStore.setState({ count: 10 })
useStore.setState((s) => ({ count: s.count + 1 }))

// Subscribe (no React required)
const unsubscribe = useStore.subscribe((state) => {
  console.log('state changed:', state)
})
unsubscribe() // call to stop listening
```

This is useful for integrating with non-React code, WebSockets, analytics, or testing utilities.

---

## Scoped Stores with Context (Provider Pattern)

The default `create` gives you a singleton store — one instance for the whole app. If you need multiple instances (e.g., per-widget or per-route), use `createStore` with React Context.

```tsx
import { createStore, useStore } from 'zustand'
import { createContext, useContext, useRef } from 'react'

interface CountState {
  count: number
  increment: () => void
}

type CountStore = ReturnType<typeof createCountStore>

const createCountStore = (initialCount = 0) =>
  createStore<CountState>((set) => ({
    count: initialCount,
    increment: () => set((s) => ({ count: s.count + 1 })),
  }))

const CountContext = createContext<CountStore | null>(null)

export function CountProvider({
  children,
  initialCount,
}: {
  children: React.ReactNode
  initialCount?: number
}) {
  const storeRef = useRef<CountStore>()
  if (!storeRef.current) {
    storeRef.current = createCountStore(initialCount)
  }
  return (
    <CountContext.Provider value={storeRef.current}>
      {children}
    </CountContext.Provider>
  )
}

export function useCountStore<T>(selector: (state: CountState) => T) {
  const store = useContext(CountContext)
  if (!store) throw new Error('Missing CountProvider')
  return useStore(store, selector)
}
```

Usage:

```tsx
<CountProvider initialCount={5}>
  <Counter />
</CountProvider>

<CountProvider initialCount={100}>
  <Counter />   {/* independent store instance */}
</CountProvider>
```

---

## Async Actions

Zustand places no restrictions on async actions. Just call `set` inside the promise or async function.

```ts
interface UserState {
  user: User | null
  loading: boolean
  error: string | null
  fetchUser: (id: string) => Promise<void>
}

const useUserStore = create<UserState>((set) => ({
  user: null,
  loading: false,
  error: null,
  fetchUser: async (id) => {
    set({ loading: true, error: null })
    try {
      const user = await api.getUser(id)
      set({ user, loading: false })
    } catch (e) {
      set({ error: (e as Error).message, loading: false })
    }
  },
}))
```

There is no special async middleware needed. The store simply holds loading and error state like any other field.

---

## Resetting State

### Full Reset

```ts
const initialState = {
  count: 0,
  name: '',
}

const useStore = create<typeof initialState & { reset: () => void }>((set) => ({
  ...initialState,
  reset: () => set(initialState),
}))
```

### Resetting All Stores

A common pattern for testing or logout flows: maintain a set of reset functions.

```ts
const resetFunctions = new Set<() => void>()

function create<T>(initializer: StateCreator<T>) {
  const store = createZustand(initializer)
  const initialState = store.getState()
  resetFunctions.add(() => store.setState(initialState, true))
  return store
}

export function resetAllStores() {
  resetFunctions.forEach((reset) => reset())
}
```

---

## Subscriptions and Side Effects

### Inside Components

Use `useEffect` with a Zustand subscription for side effects triggered by state changes.

```tsx
useEffect(() => {
  const unsubscribe = useStore.subscribe(
    (state) => state.count,
    (count) => {
      document.title = `Count: ${count}`
    }
  )
  return unsubscribe
}, [])
```

The `subscribeWithSelector` middleware is required for selector-based subscriptions on the raw store API.

### Outside Components (Event Listeners, Sockets)

```ts
// In a WebSocket handler
socket.on('update', (data) => {
  useStore.setState({ serverData: data })
})
```

---

## Testing

### Unit Testing Stores

Because stores are plain objects with `getState`/`setState`, they are straightforward to test without React.

```ts
import { useCountStore } from './countStore'

describe('count store', () => {
  beforeEach(() => {
    useCountStore.setState({ count: 0 }) // reset before each test
  })

  it('increments count', () => {
    useCountStore.getState().increment()
    expect(useCountStore.getState().count).toBe(1)
  })
})
```

### Testing Components with Zustand

When testing components, you can set store state before rendering.

```tsx
import { render, screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'

it('shows incremented count', async () => {
  useCountStore.setState({ count: 5 })
  render(<Counter />)
  expect(screen.getByText('5')).toBeInTheDocument()
  await userEvent.click(screen.getByRole('button', { name: /increment/i }))
  expect(screen.getByText('6')).toBeInTheDocument()
})
```

### Mocking Zustand in Tests

To avoid cross-test contamination, reset stores or mock them per test file.

```ts
// vitest / jest setup
import { afterEach } from 'vitest'
import { resetAllStores } from './storeUtils'

afterEach(() => {
  resetAllStores()
})
```

---

## Performance Patterns

### Avoid Selecting the Whole Store

Always use selectors. Selecting the entire state object is the most common performance mistake.

```tsx
// Bad
const everything = useStore()

// Good
const count = useStore((s) => s.count)
```

### Stable Selector References

Selectors defined inline are re-created every render. For complex selectors, define them outside the component or memoize them.

```tsx
// Fine for simple primitive selectors (same reference on stable output)
const count = useStore((s) => s.count)

// For complex object selectors, define outside component
const selectFilteredTasks = (state: TaskState) =>
  state.tasks.filter((t) => !t.done)

function TaskList() {
  const tasks = useTaskStore(selectFilteredTasks)
  // ...
}
```

### Splitting Components by Subscription

Keep components small so each subscribes to a minimal slice. A component that selects only `count` won't re-render when `name` changes, even if they're in the same store.

### Transient Updates (useRef Pattern)

For values that update at very high frequency (e.g., mouse position) and don't need to trigger renders, store them in a `useRef` and update the store only when necessary.

```ts
const mousePosRef = useRef({ x: 0, y: 0 })

useEffect(() => {
  const handler = (e: MouseEvent) => {
    mousePosRef.current = { x: e.clientX, y: e.clientY }
    // Only update store on click, not on every move
  }
  window.addEventListener('mousemove', handler)
  return () => window.removeEventListener('mousemove', handler)
}, [])
```

---

## Patterns and Recipes

### Toggling Feature Flags

```ts
interface FeatureState {
  flags: Record<string, boolean>
  toggle: (flag: string) => void
  isEnabled: (flag: string) => boolean
}

const useFeatureStore = create<FeatureState>((set, get) => ({
  flags: { darkMode: false, betaNav: false },
  toggle: (flag) =>
    set((s) => ({ flags: { ...s.flags, [flag]: !s.flags[flag] } })),
  isEnabled: (flag) => get().flags[flag] ?? false,
}))
```

### Undo / Redo with a History Stack

```ts
interface HistoryState<T> {
  past: T[]
  present: T
  future: T[]
  push: (next: T) => void
  undo: () => void
  redo: () => void
}

const createHistoryStore = <T>(initial: T) =>
  create<HistoryState<T>>((set) => ({
    past: [],
    present: initial,
    future: [],
    push: (next) =>
      set((s) => ({
        past: [...s.past, s.present],
        present: next,
        future: [],
      })),
    undo: () =>
      set((s) => {
        if (!s.past.length) return s
        const previous = s.past[s.past.length - 1]
        return {
          past: s.past.slice(0, -1),
          present: previous,
          future: [s.present, ...s.future],
        }
      }),
    redo: () =>
      set((s) => {
        if (!s.future.length) return s
        const next = s.future[0]
        return {
          past: [...s.past, s.present],
          present: next,
          future: s.future.slice(1),
        }
      }),
  }))
```

### Global Modal / Dialog State

```ts
type ModalType = 'confirm' | 'alert' | 'form' | null

interface ModalState {
  type: ModalType
  props: Record<string, unknown>
  open: (type: NonNullable<ModalType>, props?: Record<string, unknown>) => void
  close: () => void
}

const useModalStore = create<ModalState>((set) => ({
  type: null,
  props: {},
  open: (type, props = {}) => set({ type, props }),
  close: () => set({ type: null, props: {} }),
}))
```

### Optimistic Updates

```ts
addItem: async (item) => {
  // Optimistically add
  set((s) => ({ items: [...s.items, item] }))
  try {
    await api.createItem(item)
  } catch {
    // Rollback on failure
    set((s) => ({ items: s.items.filter((i) => i.id !== item.id) }))
  }
}
```

---

## Integrations

### Zustand with React Query / SWR

Zustand and React Query serve different purposes and complement each other well. React Query manages server state (caching, fetching, revalidation); Zustand manages client/UI state (selections, filters, modals).

```ts
// Zustand holds the selected filter
const useFilterStore = create<FilterState>((set) => ({
  status: 'all',
  setStatus: (status) => set({ status }),
}))

// React Query fetches based on that filter
function useFilteredTasks() {
  const status = useFilterStore((s) => s.status)
  return useQuery({
    queryKey: ['tasks', status],
    queryFn: () => api.getTasks(status),
  })
}
```

### Zustand with Immer (Nested State)

Without Immer, updating nested objects requires spreading at every level.

```ts
// Without Immer
set((s) => ({
  user: {
    ...s.user,
    address: {
      ...s.user.address,
      city: 'Tokyo',
    },
  },
}))

// With Immer middleware
set((s) => {
  s.user.address.city = 'Tokyo'
})
```

### Zustand with Next.js

When using Next.js with SSR, be careful with singleton stores — they can leak data between server requests. Use the provider pattern for SSR-safe stores.

```tsx
// app/providers.tsx
'use client'

import { CountProvider } from '@/stores/countStore'

export function Providers({ children }: { children: React.ReactNode }) {
  return <CountProvider>{children}</CountProvider>
}
```

For purely client-side state (UI state, modals, filters), the default singleton is fine since it never renders on the server.

### Zustand with Zustand DevTools (Standalone)

Beyond the middleware, you can use `zustand/devtools` directly via the Redux DevTools Extension. Action names appear in the DevTools timeline when passed as the third argument to `set`.

```ts
increment: () => set(
  (s) => ({ count: s.count + 1 }),
  false,       // replace = false
  'increment'  // action label
)
```

---

## Vanilla (Non-React) Usage

Zustand can be used without React using `createStore` from `zustand/vanilla`.

```ts
import { createStore } from 'zustand/vanilla'

const store = createStore<{ count: number; increment: () => void }>((set) => ({
  count: 0,
  increment: () => set((s) => ({ count: s.count + 1 })),
}))

store.getState().increment()
console.log(store.getState().count) // 1

const unsubscribe = store.subscribe((state) => {
  console.log('New state:', state)
})
```

---

## Migration Guide (v3 → v4)

Zustand v4 introduced several breaking changes:

- `create` is now a named export, not a default export. Change `import create from 'zustand'` to `import { create } from 'zustand'`.
- Middleware imports moved: `import { persist } from 'zustand/middleware'` (was `zustand/middleware/persist` in some configurations).
- `StateCreator` type signature changed — the four-parameter form is now standard for typed slices.
- `combine` middleware was removed in favor of the slices pattern.
- The context API moved to `zustand/context` (now `createStore` + `useStore` from `zustand`).

---

## Common Mistakes

### Storing Derived State

Storing values that can be computed from existing state leads to synchronization bugs. Use selectors instead.

### Mutating State Directly Without Immer

Without the `immer` middleware, direct mutation does not trigger re-renders.

```ts
// Wrong — mutates state object directly
set((s) => { s.count++ })

// Correct without Immer
set((s) => ({ count: s.count + 1 }))

// Correct with Immer middleware
set((s) => { s.count++ })  // safe inside immer's draft
```

### Forgetting to Clean Up Subscriptions

Raw `.subscribe()` calls outside of React do not auto-clean. Always store and call the unsubscribe function.

```ts
const unsub = useStore.subscribe(handler)
// later...
unsub()
```

### Using `set` Replace Flag Carelessly

The second argument `true` to `set` replaces the entire state, wiping all fields including actions.

```ts
// Dangerous: wipes actions too
set({ count: 0 }, true)

// Safer reset: merge from a known initial state
set({ ...initialState })
```

### Calling Hooks Outside Components Without the Store API

If you need state outside a React component, use `useStore.getState()` directly — do not try to call the hook outside of a component or hook.

---

## API Reference Summary

### `create<T>(initializer)`

Creates a React hook backed by a Zustand store. The initializer receives `set`, `get`, and the store reference.

### `createStore<T>(initializer)`

Creates a Zustand store without a React hook. Useful for vanilla usage or provider-based patterns.

### `useStore(store, selector)`

Subscribes a component to a `createStore` store with a selector. Used in the provider pattern.

### `useShallow(selector)`

Wraps a selector to use shallow equality on the selected value, preventing unnecessary re-renders when an object or array is returned.

### `set(partial | updater, replace?, actionName?)`

Updates store state. Merges by default; replaces entirely if second argument is `true`.

### `get()`

Returns current store state synchronously inside the initializer. Does not subscribe.

### `store.subscribe(listener)`

Raw subscription to all state changes. Returns an unsubscribe function.

### `store.subscribe(selector, listener, options?)`

Selector-based subscription, requires `subscribeWithSelector` middleware. Options include `equalityFn` and `fireImmediately`.

### `store.getState()`

Returns current state outside React.

### `store.setState(partial | updater, replace?)`

Updates state outside React.

### `store.destroy()`

Clears all subscriptions. Primarily for cleanup in tests.

---

## Middleware API Reference

### `devtools(config, options?)`

Options: `name` (store name in DevTools), `enabled` (boolean), `anonymousActionType` (default label for unlabeled actions).

### `persist(config, options?)`

Options: `name` (storage key, required), `storage`, `partialize`, `version`, `migrate`, `merge`, `skipHydration`.

The `skipHydration` option is useful for SSR: call `useStore.persist.rehydrate()` manually on the client.

### `immer(config)`

No extra options. Wraps `set` with Immer's `produce`.

### `subscribeWithSelector(config)`

Enhances `subscribe` to accept a selector and equality function.

### `combine(initialState, additionalCreator)`

Deprecated in v4. Replaced by the slices pattern.

---

## Ecosystem and Related Libraries

- **zustand-middleware-yjs**: Syncs Zustand state with Yjs CRDTs for real-time collaborative apps.
- **zundo**: Undo/redo middleware for Zustand.
- **zustand-persist**: Alternative persistence solutions.
- **jotai**: A related library by the same author, taking an atomic rather than store-based approach.
- **valtio**: Another pmndrs library using Proxy-based state.

---

## Comparison with Alternatives

### vs Redux Toolkit

Redux Toolkit requires actions, reducers, and typically a provider. Zustand requires none of these. Redux has a more opinionated structure, which can be an advantage in larger teams. Redux DevTools integration is more mature. Zustand is generally less boilerplate for small-to-medium applications.

### vs React Context + useReducer

Context re-renders all consumers when any part of context value changes unless you split contexts aggressively. Zustand's selector model makes per-field subscriptions trivial. Context does not require an extra dependency.

### vs Jotai

Jotai is atom-based: state is split into small atoms that components subscribe to individually. Zustand is store-based: all related state lives in one object. Jotai tends to be more granular; Zustand is easier to reason about as a whole. Both are from the same author.

### vs MobX

MobX uses observables and reactions with implicit tracking. Zustand uses explicit selectors and subscriptions. MobX is more automatic; Zustand is more predictable. MobX has a larger footprint.

---

## Checklist for Production Use

- Use selectors for every `useStore` call — never subscribe to the whole store
- Use `useShallow` when selecting multiple fields as an object or array
- Set `enabled: process.env.NODE_ENV !== 'production'` in devtools options
- Use `partialize` in `persist` to exclude functions and sensitive data from storage
- Define action names (third arg to `set`) for DevTools clarity
- Reset stores between test cases
- Use the provider pattern for SSR (Next.js App Router) or multi-instance stores
- Avoid storing derived state — compute it in selectors
- Clean up raw `.subscribe()` calls to prevent memory leaks