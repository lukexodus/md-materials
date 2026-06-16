## Using TanStack Store with Other Frameworks

TanStack Store provides first-class framework adapters for Solid, Vue, Angular, and Svelte. Each adapter wraps the same core `Store` and `Derived` primitives in framework-native reactive constructs — signals, computed refs, Angular Signals, and Svelte stores respectively. The store creation and update API is identical across all frameworks; only the consumption layer differs.

---

### Installation by Framework

```bash
# Solid
npm install @tanstack/store @tanstack/solid-store

# Vue
npm install @tanstack/store @tanstack/vue-store

# Angular
npm install @tanstack/store @tanstack/angular-store

# Svelte
npm install @tanstack/store @tanstack/svelte-store
```

**Key Points:**
- `@tanstack/store` is always required alongside the framework adapter package
- Stores and update logic defined with `@tanstack/store` are fully portable — the same store module can be consumed by any framework adapter without modification

---

### Shared Store Module

Because stores are framework-agnostic, a single store module can serve any adapter. This pattern is used throughout all examples below.

```ts
// store/counter.ts
import { Store, Derived } from '@tanstack/store'

export const counterStore = new Store({ count: 0, label: 'Counter' })

export const doubledDerived = new Derived({
  deps: [counterStore],
  fn: () => counterStore.state.count * 2,
})

doubledDerived.mount()

export function increment() {
  counterStore.setState((prev) => ({ ...prev, count: prev.count + 1 }))
}

export function decrement() {
  counterStore.setState((prev) => ({ ...prev, count: prev.count - 1 }))
}

export function reset() {
  counterStore.setState((prev) => ({ ...prev, count: 0 }))
}
```

---

## Solid

### `useStore` in Solid

The Solid adapter's `useStore` returns a **signal accessor** — a function that must be called with `()` to read the current value reactively inside JSX or reactive computations.

```tsx
import { useStore } from '@tanstack/solid-store'
import { counterStore, doubledDerived, increment, decrement, reset } from './store/counter'

function Counter() {
  const count = useStore(counterStore, (state) => state.count)
  const doubled = useStore(doubledDerived, (state) => state)

  return (
    <div>
      <p>Count: {count()}</p>
      <p>Doubled: {doubled()}</p>
      <button onClick={decrement}>−</button>
      <button onClick={increment}>+</button>
      <button onClick={reset}>Reset</button>
    </div>
  )
}
```

**Key Points:**
- `count` is a signal accessor — reading it as `count` (without `()`) gives a non-reactive snapshot; always use `count()` inside JSX and reactive contexts
- [Inference] Only the DOM nodes that read from `count()` update when the signal changes — not the entire component — consistent with Solid's fine-grained reactivity model; actual behavior depends on Solid's compiler
- `useStore` handles subscription and cleanup automatically within Solid's reactive ownership system

### `shallow` in Solid

```tsx
import { useStore } from '@tanstack/solid-store'
import { shallow } from '@tanstack/store'

const store = new Store({ user: { name: 'Alice', role: 'admin' } })

function UserBadge() {
  const user = useStore(store, (s) => ({ ...s.user }), shallow)
  return <span>{user().name} — {user().role}</span>
}
```

### Subscribing Outside Components in Solid

```ts
import { createEffect } from 'solid-js'

// Outside reactive context — use store.subscribe directly
counterStore.subscribe(() => {
  console.log('Count changed:', counterStore.state.count)
})
```

---

## Vue

### `useStore` in Vue

The Vue adapter's `useStore` returns a **`computed` ref** — a Vue reactive reference. In the `<script setup>` block, the value is accessed with `.value`; in templates, the ref is unwrapped automatically.

```vue
<!-- Counter.vue -->
<script setup lang="ts">
import { useStore } from '@tanstack/vue-store'
import { shallow } from '@tanstack/store'
import { counterStore, doubledDerived, increment, decrement, reset } from './store/counter'

const count = useStore(counterStore, (state) => state.count)
const doubled = useStore(doubledDerived, (state) => state)
</script>

<template>
  <div>
    <p>Count: {{ count }}</p>
    <p>Doubled: {{ doubled }}</p>
    <button @click="decrement">−</button>
    <button @click="increment">+</button>
    <button @click="reset">Reset</button>
  </div>
</template>
```

**Key Points:**
- In templates, Vue automatically unwraps the `computed` ref — use `count` not `count.value`
- In `<script setup>`, use `count.value` when reading or comparing outside the template
- `useStore` registers the component as a subscriber and cleans up automatically when the component is unmounted via Vue's `onUnmounted` lifecycle [Inference: verify with current adapter documentation]

### `shallow` in Vue

```vue
<script setup lang="ts">
import { useStore } from '@tanstack/vue-store'
import { shallow } from '@tanstack/store'

const store = new Store({ user: { name: 'Alice', role: 'admin' } })

const user = useStore(store, (s) => ({ ...s.user }), shallow)
</script>

<template>
  <span>{{ user.name }} — {{ user.role }}</span>
</template>
```

### Accessing Store State in Vue Composables

Store subscriptions can be placed in composable functions for reuse across components.

```ts
// composables/useCounter.ts
import { useStore } from '@tanstack/vue-store'
import { counterStore, increment, decrement, reset } from '../store/counter'

export function useCounter() {
  const count = useStore(counterStore, (state) => state.count)
  return { count, increment, decrement, reset }
}
```

```vue
<script setup lang="ts">
import { useCounter } from '../composables/useCounter'
const { count, increment, decrement } = useCounter()
</script>

<template>
  <div>
    <p>{{ count }}</p>
    <button @click="decrement">−</button>
    <button @click="increment">+</button>
  </div>
</template>
```

### Subscribing Outside Components in Vue

```ts
// In a plain TS module or Pinia-style service
counterStore.subscribe(() => {
  localStorage.setItem('count', String(counterStore.state.count))
})
```

---

## Angular

### `injectStore` in Angular

The Angular adapter exposes `injectStore` instead of `useStore`. It must be called within an Angular injection context (component class field initializer or `inject`-compatible factory). It returns an **Angular Signal** — accessed with `()` in templates.

```ts
import { Component, ChangeDetectionStrategy } from '@angular/core'
import { injectStore } from '@tanstack/angular-store'
import { counterStore, doubledDerived, increment, decrement, reset } from './store/counter'

@Component({
  selector: 'app-counter',
  standalone: true,
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    <div>
      <p>Count: {{ count() }}</p>
      <p>Doubled: {{ doubled() }}</p>
      <button (click)="decrement()">−</button>
      <button (click)="increment()">+</button>
      <button (click)="reset()">Reset</button>
    </div>
  `,
})
export class CounterComponent {
  count = injectStore(counterStore, (state) => state.count)
  doubled = injectStore(doubledDerived, (state) => state)

  increment = increment
  decrement = decrement
  reset = reset
}
```

**Key Points:**
- `injectStore` must be called as a class field initializer or inside a constructor — not in lifecycle hooks
- The returned Signal is called with `()` in templates: `{{ count() }}`
- `ChangeDetectionStrategy.OnPush` is [Inference] compatible with Angular Signals and may improve performance by limiting change detection cycles — actual behavior depends on Angular version
- `injectStore` manages subscription cleanup automatically when the component is destroyed

### `shallow` in Angular

```ts
import { injectStore } from '@tanstack/angular-store'
import { shallow } from '@tanstack/store'

export class UserComponent {
  user = injectStore(store, (s) => ({ ...s.user }), shallow)
}
```

```html
<span>{{ user().name }} — {{ user().role }}</span>
```

### Using `injectStore` in Angular Services

```ts
import { Injectable } from '@angular/core'
import { injectStore } from '@tanstack/angular-store'
import { counterStore } from './store/counter'

@Injectable({ providedIn: 'root' })
export class CounterService {
  count = injectStore(counterStore, (state) => state.count)

  getDoubled(): number {
    return counterStore.state.count * 2
  }
}
```

**Key Points:**
- `injectStore` works inside Angular services provided in root or component scope, as long as it is called in an injection context
- For one-off reads in service methods, `store.state` is accessed directly without `injectStore`

### Subscribing Outside Components in Angular

```ts
import { Injectable, OnDestroy } from '@angular/core'
import { counterStore } from './store/counter'

@Injectable({ providedIn: 'root' })
export class CounterPersistenceService implements OnDestroy {
  private unsubscribe: () => void

  constructor() {
    this.unsubscribe = counterStore.subscribe(() => {
      localStorage.setItem('count', String(counterStore.state.count))
    })
  }

  ngOnDestroy() {
    this.unsubscribe()
  }
}
```

---

## Svelte

### `useStore` in Svelte

The Svelte adapter's `useStore` returns a **Svelte readable store** — a value compatible with Svelte's `$` auto-subscription syntax in templates.

```svelte
<!-- Counter.svelte -->
<script lang="ts">
  import { useStore } from '@tanstack/svelte-store'
  import { counterStore, doubledDerived, increment, decrement, reset } from './store/counter'

  const count = useStore(counterStore, (state) => state.count)
  const doubled = useStore(doubledDerived, (state) => state)
</script>

<div>
  <p>Count: {$count}</p>
  <p>Doubled: {$doubled}</p>
  <button on:click={decrement}>−</button>
  <button on:click={increment}>+</button>
  <button on:click={reset}>Reset</button>
</div>
```

**Key Points:**
- The `$` prefix auto-subscribes and auto-unsubscribes in Svelte templates — no manual cleanup needed
- In `<script>` blocks, access the current value with `$count` (Svelte's reactive statement) or `.subscribe()` manually
- `useStore` returns a standard Svelte `Readable`, so it is compatible with Svelte's `derived`, `get`, and other store utilities

### `shallow` in Svelte

```svelte
<script lang="ts">
  import { useStore } from '@tanstack/svelte-store'
  import { shallow } from '@tanstack/store'

  const store = new Store({ user: { name: 'Alice', role: 'admin' } })
  const user = useStore(store, (s) => ({ ...s.user }), shallow)
</script>

<span>{$user.name} — {$user.role}</span>
```

### Using with Svelte's `derived`

Because `useStore` returns a Svelte readable, it can be composed with Svelte's own `derived` utility for additional transformations in the template layer.

```svelte
<script lang="ts">
  import { derived } from 'svelte/store'
  import { useStore } from '@tanstack/svelte-store'
  import { counterStore } from './store/counter'

  const count = useStore(counterStore, (s) => s.count)

  // Further Svelte-layer derivation
  const message = derived(count, ($count) =>
    $count === 0 ? 'Nothing yet' : `Count is ${$count}`
  )
</script>

<p>{$message}</p>
```

**Key Points:**
- Combining TanStack Store's `Derived` (for shared business logic) with Svelte's `derived` (for component-level display logic) is valid and idiomatic
- TanStack Store's `Derived` is preferred for logic shared across components; Svelte's `derived` is appropriate for view-specific transformations

### Subscribing Outside Components in Svelte

```ts
// In a plain TS module
import { counterStore } from './store/counter'

counterStore.subscribe(() => {
  sessionStorage.setItem('count', String(counterStore.state.count))
})
```

---

### Cross-Framework Comparison

| Feature | Solid | Vue | Angular | Svelte |
|---|---|---|---|---|
| Hook / function | `useStore` | `useStore` | `injectStore` | `useStore` |
| Return type | Signal accessor | `computed` ref | Angular Signal | Svelte `Readable` |
| Read in template | `count()` | `{{ count }}` | `{{ count() }}` | `{$count}` |
| Read in script | `count()` | `count.value` | `count()` | `$count` or `.subscribe()` |
| Auto cleanup | Yes (Solid ownership) | Yes (onUnmounted) | Yes (component destroy) | Yes (`$` syntax) |
| `shallow` support | Yes | Yes | Yes | Yes |
| Custom equality | Yes | Yes | Yes | Yes |
| Works with `Derived` | Yes | Yes | Yes | Yes |
| Injection context required | No | No | Yes (`injectStore`) | No |

---

### Common Pitfalls by Framework

#### Solid — Forgetting to call the signal accessor

```tsx
// Wrong — non-reactive snapshot
<p>Count: {count}</p>

// Correct
<p>Count: {count()}</p>
```

#### Vue — Using `.value` in templates

```vue
<!-- Wrong — Vue unwraps refs in templates automatically -->
<p>{{ count.value }}</p>

<!-- Correct -->
<p>{{ count }}</p>
```

#### Angular — Calling `injectStore` outside injection context

```ts
// Wrong — called in lifecycle hook
ngOnInit() {
  this.count = injectStore(counterStore, (s) => s.count) // throws
}

// Correct — called as class field initializer
count = injectStore(counterStore, (s) => s.count)
```

#### Svelte — Forgetting the `$` prefix in templates

```svelte
<!-- Wrong — count is a Readable object, not the value -->
<p>{count}</p>

<!-- Correct -->
<p>{$count}</p>
```

---

**Related Topics:**
- TanStack Store — Using with React (`useStore` hook)
- TanStack Store — `Derived` and computed state
- TanStack Store — `shallow` and custom equality in depth
- TanStack Store — Subscriptions and cleanup patterns
- TanStack Store — Persistence patterns across frameworks
- TanStack Store — Framework-agnostic store module organization