## Field-level Subscribers in TanStack Form

Field-level subscribers allow you to observe and react to the state of individual fields without triggering re-renders across the entire form. This is a core performance optimization mechanism in TanStack Form, enabling granular reactivity at the field level rather than at the form level.

---

### What Are Field-level Subscribers

In TanStack Form, the `form.subscribe` and `field.subscribe` APIs let components or logic react to specific slices of state. Field-level subscribers narrow this scope to a single field, watching only the state properties you explicitly select.

Without field-level subscribers, any state change anywhere in the form could trigger unnecessary re-renders in unrelated fields or components. Field-level subscribers solve this by letting each field declare exactly what it cares about.

---

### The `field.subscribe` API

Every field instance exposes a `subscribe` method. It accepts a selector function and a listener callback.

```ts
const unsubscribe = form.getFieldMeta('email')
```

More commonly, you use the `form.subscribe` API scoped to a field:

```ts
const unsubscribe = form.subscribe(
  (state) => state.fieldMeta['email'],
  (emailMeta) => {
    console.log('email field meta changed:', emailMeta)
  }
)
```

The first argument is the **selector** — it extracts the slice of state you care about. The second is the **listener** — it fires only when the selected slice changes (by reference equality). Call the returned `unsubscribe` function to clean up.

---

### Using `useField` with `listeners`

In React, TanStack Form exposes field-level subscription through the `listeners` option on `useField` or `form.Field`. Listeners are side-effect callbacks that run in response to field lifecycle events.

```tsx
<form.Field
  name="username"
  listeners={{
    onChange: ({ value }) => {
      console.log('username changed to:', value)
    },
    onBlur: ({ value }) => {
      console.log('username blurred with:', value)
    },
  }}
>
  {(field) => (
    <input
      value={field.state.value}
      onChange={(e) => field.handleChange(e.target.value)}
      onBlur={field.handleBlur}
    />
  )}
</form.Field>
```

`listeners.onChange` fires after the field value changes. `listeners.onBlur` fires after blur. These are not the same as validation — they are observation hooks.

---

### The `selector` Pattern for Targeted Re-renders

The most direct performance mechanism is providing a `selector` to `form.Field` or `useField`. This controls which slice of field state the component subscribes to and re-renders for.

```tsx
<form.Field
  name="email"
  selector={(state) => ({
    value: state.value,
    errors: state.meta.errors,
  })}
>
  {(field) => (
    <>
      <input value={field.state.value} onChange={(e) => field.handleChange(e.target.value)} />
      {field.state.meta.errors.map((e) => <p key={e}>{e}</p>)}
    </>
  )}
</form.Field>
```

When a `selector` is provided, the field component only re-renders when the selected slice changes. If `isTouched` or `isValidating` changes but your selector only watches `value` and `errors`, no re-render occurs for this component.

**Key Points**
- The selector receives the full field state object
- Return only what the component needs
- TanStack Form uses shallow equality to detect changes in the selected slice [Inference — behavior may vary across versions]

---

### `form.useStore` Scoped to a Field

Outside of JSX field components, you can use `form.useStore` with a selector to subscribe a component to a specific field's state:

```tsx
function EmailError() {
  const errors = form.useStore((state) => state.fieldMeta['email']?.errors ?? [])

  if (errors.length === 0) return null
  return <ul>{errors.map((e) => <li key={e}>{e}</li>)}</ul>
}
```

This component re-renders only when the `errors` array for the `email` field changes. It has no dependency on any other field or form-level state.

**Key Points**
- `form.useStore` is a React hook wrapping the store's `subscribe`
- The selector is memoized on function identity — define it outside the component or use `useCallback` to avoid excessive re-subscriptions [Inference]
- Returns a synchronously derived value, not a promise

---

### Subscribing to Multiple Fields Independently

When you need to observe multiple fields without coupling their re-render cycles, subscribe to each field independently:

```tsx
function PasswordMatchIndicator() {
  const password = form.useStore((state) => state.fieldMeta['password']?.value)
  const confirm = form.useStore((state) => state.fieldMeta['confirmPassword']?.value)

  return <p>{password === confirm ? '✓ Match' : '✗ No match'}</p>
}
```

Each `useStore` call is an independent subscription. If only `password` changes, only the subscription for `password` fires and triggers re-evaluation.

> [Inference] Both subscriptions triggering for a single update that changes only one field is possible depending on React's batching behavior. Behavior is not guaranteed and may vary.

---

### Using `onChangeAsyncDebounceMs` with Subscribers

Field-level subscribers compose with async validation. When a listener or subscriber watches a field undergoing async validation, it can observe the `isValidating` flag during the debounce window:

```tsx
<form.Field
  name="username"
  asyncDebounceMs={400}
  validators={{
    onChangeAsync: async ({ value }) => {
      const taken = await checkUsernameTaken(value)
      return taken ? 'Username is taken' : undefined
    },
  }}
  selector={(state) => ({
    value: state.value,
    isValidating: state.meta.isValidating,
    errors: state.meta.errors,
  })}
>
  {(field) => (
    <div>
      <input value={field.state.value} onChange={(e) => field.handleChange(e.target.value)} />
      {field.state.meta.isValidating && <span>Checking availability…</span>}
      {field.state.meta.errors.map((e) => <p key={e}>{e}</p>)}
    </div>
  )}
</form.Field>
```

The component subscribes to `isValidating` and will re-render when async validation starts and ends, but not for unrelated form changes.

---

### Cross-field Reactivity via Subscribers

A common advanced pattern is having one field react to changes in another. This is done by attaching a listener or subscriber to the source field and imperatively updating the target field.

```tsx
<form.Field
  name="country"
  listeners={{
    onChange: ({ value }) => {
      // Reset the region field when country changes
      form.setFieldValue('region', '')
      form.setFieldMeta('region', (prev) => ({ ...prev, isTouched: false }))
    },
  }}
>
  {(field) => (
    <select value={field.state.value} onChange={(e) => field.handleChange(e.target.value)}>
      <option value="us">United States</option>
      <option value="ca">Canada</option>
    </select>
  )}
</form.Field>
```

**Key Points**
- `form.setFieldValue` and `form.setFieldMeta` are the imperative APIs for cross-field effects
- Listeners run after the field state update has been committed
- Circular listener dependencies (A listens to B, B listens to A) can cause infinite update loops — design cross-field logic carefully

---

### Unsubscribing and Cleanup

When using the imperative `form.subscribe` or `form.store.subscribe` outside of React, always clean up:

```ts
useEffect(() => {
  const unsubscribe = form.store.subscribe(() => {
    const meta = form.getFieldMeta('email')
    if (meta?.errors.length) {
      trackError('email', meta.errors)
    }
  })

  return () => unsubscribe()
}, [form])
```

In React, hooks like `useStore` handle cleanup automatically. For manual subscriptions — such as in `useEffect` blocks or imperative logic — failure to unsubscribe results in stale listeners holding references.

---

### Performance Summary

```
Without selectors:
  Any form state change → all Field components re-render

With field-level selectors:
  Field A state changes → only Field A's component re-renders

With cross-field useStore selectors:
  Only the selected slice changes → only that consumer re-renders
```

<svg viewBox="0 0 640 300" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="13">
  <rect width="640" height="300" fill="#0f1117"/>
  <!-- Form Store -->
  <rect x="240" y="20" width="160" height="44" rx="6" fill="#1e2030" stroke="#4f6ef7" stroke-width="1.5"/>
  <text x="320" y="47" text-anchor="middle" fill="#4f6ef7" font-size="13">Form Store</text>
  <!-- Arrows down -->
  <line x1="320" y1="64" x2="320" y2="90" stroke="#4f6ef7" stroke-width="1" stroke-dasharray="4,3"/>
  <line x1="320" y1="90" x2="120" y2="120" stroke="#4f6ef7" stroke-width="1" stroke-dasharray="4,3"/>
  <line x1="320" y1="90" x2="320" y2="120" stroke="#4f6ef7" stroke-width="1" stroke-dasharray="4,3"/>
  <line x1="320" y1="90" x2="520" y2="120" stroke="#4f6ef7" stroke-width="1" stroke-dasharray="4,3"/>
  <!-- Field A -->
  <rect x="40" y="120" width="160" height="44" rx="6" fill="#1e2030" stroke="#22c55e" stroke-width="1.5"/>
  <text x="120" y="140" text-anchor="middle" fill="#22c55e" font-size="12">Field: email</text>
  <text x="120" y="156" text-anchor="middle" fill="#6b7280" font-size="11">selector: value, errors</text>
  <!-- Field B -->
  <rect x="240" y="120" width="160" height="44" rx="6" fill="#1e2030" stroke="#22c55e" stroke-width="1.5"/>
  <text x="320" y="140" text-anchor="middle" fill="#22c55e" font-size="12">Field: username</text>
  <text x="320" y="156" text-anchor="middle" fill="#6b7280" font-size="11">selector: value, isValidating</text>
  <!-- Field C -->
  <rect x="440" y="120" width="160" height="44" rx="6" fill="#1e2030" stroke="#22c55e" stroke-width="1.5"/>
  <text x="520" y="140" text-anchor="middle" fill="#22c55e" font-size="12">Field: country</text>
  <text x="520" y="156" text-anchor="middle" fill="#6b7280" font-size="11">listener: onChange</text>
  <!-- Arrows down to render blocks -->
  <line x1="120" y1="164" x2="120" y2="196" stroke="#22c55e" stroke-width="1"/>
  <line x1="320" y1="164" x2="320" y2="196" stroke="#22c55e" stroke-width="1"/>
  <line x1="520" y1="164" x2="520" y2="196" stroke="#22c55e" stroke-width="1"/>
  <!-- Render indicators -->
  <rect x="60" y="196" width="120" height="32" rx="4" fill="#14291d" stroke="#22c55e" stroke-width="1"/>
  <text x="120" y="216" text-anchor="middle" fill="#22c55e" font-size="11">re-renders on</text>
  <text x="120" y="228" text-anchor="middle" fill="#22c55e" font-size="10">value or errors Δ</text>
  <rect x="260" y="196" width="120" height="32" rx="4" fill="#14291d" stroke="#22c55e" stroke-width="1"/>
  <text x="320" y="216" text-anchor="middle" fill="#22c55e" font-size="11">re-renders on</text>
  <text x="320" y="228" text-anchor="middle" fill="#22c55e" font-size="10">value or validating Δ</text>
  <rect x="460" y="196" width="120" height="32" rx="4" fill="#14291d" stroke="#f59e0b" stroke-width="1"/>
  <text x="520" y="216" text-anchor="middle" fill="#f59e0b" font-size="11">side effect on</text>
  <text x="520" y="228" text-anchor="middle" fill="#f59e0b" font-size="10">value change only</text>
  <!-- Cross-field arrow -->
  <line x1="440" y1="230" x2="200" y2="230" stroke="#f59e0b" stroke-width="1" stroke-dasharray="5,3" marker-end="url(#arr)"/>
  <defs>
    <marker id="arr" markerWidth="8" markerHeight="8" refX="4" refY="3" orient="auto">
      <path d="M0,0 L0,6 L8,3 z" fill="#f59e0b"/>
    </marker>
  </defs>
  <text x="320" y="248" text-anchor="middle" fill="#f59e0b" font-size="10">setFieldValue('region', '')</text>
  <!-- Title -->
  <text x="320" y="285" text-anchor="middle" fill="#4b5563" font-size="11">Field-level subscriber isolation — each field re-renders independently</text>
</svg>

---

### Common Mistakes

**Defining selectors inline without memoization**

```tsx
// Problematic — new function reference on every render causes constant re-subscription [Inference]
<form.Field
  name="email"
  selector={(s) => s.value}
>

// Better — stable reference
const emailValueSelector = (s) => s.value

<form.Field name="email" selector={emailValueSelector}>
```

**Watching the entire field state**

```tsx
// Subscribes to everything — defeats the purpose
const fieldState = form.useStore((s) => s.fieldMeta['email'])

// Specific and minimal
const emailErrors = form.useStore((s) => s.fieldMeta['email']?.errors ?? [])
```

**Forgetting unsubscribe in effects**

```tsx
// Missing cleanup — stale listener after unmount
useEffect(() => {
  form.store.subscribe(() => { /* ... */ })
}, [])

// Correct
useEffect(() => {
  return form.store.subscribe(() => { /* ... */ })
}, [])
```

---

### Summary

Field-level subscribers in TanStack Form provide a fine-grained reactivity model. By using selectors on `form.Field`, `form.useStore`, and `listeners`, you control exactly which state changes trigger re-renders or side effects. This is the primary tool for building performant forms with many fields or complex interdependencies.

**Related Topics**
- `form.useStore` vs `form.subscribe` — API comparison and use cases
- Form-level subscribers and whole-form state observation
- Cross-field validation with `onChangeListenTo`
- Derived state and computed values from field subscriptions
- Subscription patterns in array fields and nested field groups
- Integration with external state managers via store observers