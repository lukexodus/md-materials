## Form-level Subscribers in TanStack Form

Form-level subscribers observe the state of the entire form store rather than a single field. They are the broadest subscription scope available and serve as the foundation for features like submit-button gating, dirty-state indicators, global error banners, and external state synchronization.

---

### The Form Store

TanStack Form manages all state in a single reactive store exposed as `form.store`. This store holds field values, field metadata, form-level metadata, and submission state. Every subscription — whether field-level or form-level — reads from this same store.

```
form.store
├── values              — current values of all fields
├── fieldMeta           — per-field metadata (errors, touched, validating…)
├── isSubmitting        — true while submission is in progress
├── isSubmitted         — true after a successful submission
├── isDirty             — true if any field value differs from default
├── isTouched           — true if any field has been touched
├── isValid             — true if no field has active errors
└── submissionAttempts  — number of times submit has been called
```

> [Inference] The exact shape of the store object may vary across minor versions. Behavior is not guaranteed. Always verify against the version in use.

---

### `form.useStore`

`form.useStore` is the primary React hook for subscribing to form state. Called without a selector, it returns the entire form state and re-renders on every change.

```tsx
const formState = form.useStore()
```

Called with a selector, it returns only the selected slice and re-renders only when that slice changes:

```tsx
const isSubmitting = form.useStore((state) => state.isSubmitting)
```

This is the recommended pattern. Subscribing to the full state object without a selector causes the consuming component to re-render on any state change anywhere in the form.

---

### Subscribing to Submission State

A common form-level subscription is gating the submit button on validity and submission progress:

```tsx
function SubmitButton() {
  const canSubmit = form.useStore((state) => state.canSubmit)
  const isSubmitting = form.useStore((state) => state.isSubmitting)

  return (
    <button type="submit" disabled={!canSubmit || isSubmitting}>
      {isSubmitting ? 'Submitting…' : 'Submit'}
    </button>
  )
}
```

**Key Points**
- `canSubmit` is a derived boolean in the form store that combines validity, pristine state, and submission-in-progress checks [Inference — exact derivation logic may vary by version]
- Isolating this into its own component means only `SubmitButton` re-renders when these values change, not the entire form tree

---

### Subscribing to Dirty State

```tsx
function DirtyIndicator() {
  const isDirty = form.useStore((state) => state.isDirty)

  return isDirty ? <p>You have unsaved changes.</p> : null
}
```

`isDirty` becomes true when any field value differs from its default value. This is a form-level computed flag — not the same as checking individual field `isTouched` values.

---

### Subscribing to Form-level Errors

Form-level errors (set via `form.setErrorMap`) are distinct from field-level errors. They are stored in `errorMap` on the form state:

```tsx
function FormErrorBanner() {
  const errorMap = form.useStore((state) => state.errorMap)

  const onSubmitError = errorMap?.onSubmit

  if (!onSubmitError) return null

  return (
    <div role="alert">
      {String(onSubmitError)}
    </div>
  )
}
```

**Key Points**
- `errorMap` is keyed by validation event (`onSubmit`, `onChange`, `onBlur`, etc.)
- Form-level errors coexist with field-level errors and must be displayed separately
- `form.setErrorMap` is the imperative API for writing to this map

---

### Subscribing to All Field Values

To observe the complete current values of all fields — for example, to serialize form state or drive a live preview — select `values` from the store:

```tsx
function LivePreview() {
  const values = form.useStore((state) => state.values)

  return (
    <pre>{JSON.stringify(values, null, 2)}</pre>
  )
}
```

> [Inference] Because `values` is an object, this component re-renders on every keystroke across all fields. For performance-sensitive scenarios, select only the specific values needed or debounce the preview externally.

---

### Subscribing to Validation State

To show a global "form is validating" indicator during async validation across any field:

```tsx
function ValidationSpinner() {
  const isValidating = form.useStore(
    (state) =>
      Object.values(state.fieldMeta).some((meta) => meta.isValidating)
  )

  return isValidating ? <span>Validating…</span> : null
}
```

> [Inference] This selector runs on every store update and iterates all field metadata. For forms with many fields under rapid change, consider memoizing or debouncing.

---

### Imperative Subscription with `form.store.subscribe`

Outside of React — in effects, event handlers, or framework-agnostic code — use the store's `subscribe` method directly:

```ts
const unsubscribe = form.store.subscribe(() => {
  const state = form.store.state
  console.log('Form state updated:', state.values)
})

// Later:
unsubscribe()
```

Unlike `form.useStore`, this fires on every store update without selector filtering. Apply your own diffing logic if selective reaction is needed:

```ts
let previousValues = form.store.state.values

const unsubscribe = form.store.subscribe(() => {
  const nextValues = form.store.state.values
  if (nextValues !== previousValues) {
    previousValues = nextValues
    syncToExternalStore(nextValues)
  }
})
```

**Key Points**
- `form.store.state` gives synchronous access to the current state snapshot at any point
- The subscribe callback receives no arguments — read `form.store.state` inside the callback
- Always call the returned unsubscribe function when the subscription is no longer needed

---

### Combining Multiple Form-level Selectors

When a component needs several form-level values, combine them in a single selector to avoid multiple hook calls:

```tsx
function FormStatusBar() {
  const { isDirty, isSubmitting, submissionAttempts } = form.useStore((state) => ({
    isDirty: state.isDirty,
    isSubmitting: state.isSubmitting,
    submissionAttempts: state.submissionAttempts,
  }))

  return (
    <div>
      {isDirty && <span>Unsaved</span>}
      {isSubmitting && <span>Saving…</span>}
      <span>Attempts: {submissionAttempts}</span>
    </div>
  )
}
```

> [Inference] When the selector returns a new object on every call, TanStack Form uses shallow equality to determine if a re-render is needed. If all selected values are primitive, this works correctly. If any selected value is an object or array, shallow equality may not catch deep changes — or may trigger unnecessary re-renders if the reference changes. Behavior is not guaranteed.

---

### Using `form.subscribe` (Framework-agnostic API)

TanStack Form's core exposes `form.subscribe` as a lower-level API available across all adapters:

```ts
const unsubscribe = form.subscribe(
  (state) => state.isSubmitting,
  (isSubmitting) => {
    if (isSubmitting) disableNavigationGuard()
    else enableNavigationGuard()
  }
)
```

The first argument is the selector. The second is the listener, called only when the selected value changes. This is the pattern to prefer in non-React contexts or in logic outside the component tree.

---

### Reacting to Submission Lifecycle

```tsx
useEffect(() => {
  return form.subscribe(
    (state) => state.isSubmitted,
    (isSubmitted) => {
      if (isSubmitted) {
        router.push('/success')
      }
    }
  )
}, [form])
```

**Key Points**
- `isSubmitted` is set to `true` after a successful `onSubmit` handler resolves
- This pattern keeps navigation side effects out of the submit handler and decoupled from render logic
- The `useEffect` cleanup calls the returned unsubscribe function

---

### Architecture: Scope Comparison

```
Subscription Scope        API                       Re-renders When
─────────────────────────────────────────────────────────────────────
Entire form state         form.useStore()           Any state change
Selected form slice       form.useStore(selector)   Selected slice changes
Single field meta         form.useStore(s=>s.fieldMeta[name])
                                                    That field's meta changes
Single field value        form.useStore(s=>s.values[name])
                                                    That field's value changes
Imperative (any)          form.store.subscribe()    Every store update
Filtered imperative       form.subscribe(sel, fn)   Selected slice changes
```

<svg viewBox="0 0 660 340" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="12">
  <rect width="660" height="340" fill="#0f1117"/>

  <!-- Form Store box -->
  <rect x="220" y="16" width="220" height="52" rx="6" fill="#1e2030" stroke="#4f6ef7" stroke-width="1.5"/>
  <text x="330" y="38" text-anchor="middle" fill="#4f6ef7" font-size="13">form.store</text>
  <text x="330" y="58" text-anchor="middle" fill="#6b7280" font-size="10">values · fieldMeta · isSubmitting · isDirty…</text>

  <!-- Vertical trunk -->
  <line x1="330" y1="68" x2="330" y2="100" stroke="#4f6ef7" stroke-width="1" stroke-dasharray="4,3"/>

  <!-- Branch lines -->
  <line x1="330" y1="100" x2="80" y2="130" stroke="#4f6ef7" stroke-width="1" stroke-dasharray="4,3"/>
  <line x1="330" y1="100" x2="210" y2="130" stroke="#4f6ef7" stroke-width="1" stroke-dasharray="4,3"/>
  <line x1="330" y1="100" x2="330" y2="130" stroke="#4f6ef7" stroke-width="1" stroke-dasharray="4,3"/>
  <line x1="330" y1="100" x2="460" y2="130" stroke="#4f6ef7" stroke-width="1" stroke-dasharray="4,3"/>
  <line x1="330" y1="100" x2="580" y2="130" stroke="#4f6ef7" stroke-width="1" stroke-dasharray="4,3"/>

  <!-- Subscriber boxes -->
  <!-- SubmitButton -->
  <rect x="14" y="130" width="132" height="50" rx="5" fill="#1a1f35" stroke="#22c55e" stroke-width="1.2"/>
  <text x="80" y="150" text-anchor="middle" fill="#22c55e" font-size="11">SubmitButton</text>
  <text x="80" y="165" text-anchor="middle" fill="#6b7280" font-size="10">canSubmit</text>
  <text x="80" y="177" text-anchor="middle" fill="#6b7280" font-size="10">isSubmitting</text>

  <!-- DirtyIndicator -->
  <rect x="152" y="130" width="112" height="50" rx="5" fill="#1a1f35" stroke="#22c55e" stroke-width="1.2"/>
  <text x="208" y="150" text-anchor="middle" fill="#22c55e" font-size="11">DirtyIndicator</text>
  <text x="208" y="165" text-anchor="middle" fill="#6b7280" font-size="10">isDirty</text>

  <!-- FormErrorBanner -->
  <rect x="270" y="130" width="120" height="50" rx="5" fill="#1a1f35" stroke="#f87171" stroke-width="1.2"/>
  <text x="330" y="150" text-anchor="middle" fill="#f87171" font-size="11">ErrorBanner</text>
  <text x="330" y="165" text-anchor="middle" fill="#6b7280" font-size="10">errorMap</text>
  <text x="330" y="177" text-anchor="middle" fill="#6b7280" font-size="10">onSubmit errors</text>

  <!-- LivePreview -->
  <rect x="398" y="130" width="124" height="50" rx="5" fill="#1a1f35" stroke="#f59e0b" stroke-width="1.2"/>
  <text x="460" y="150" text-anchor="middle" fill="#f59e0b" font-size="11">LivePreview</text>
  <text x="460" y="165" text-anchor="middle" fill="#6b7280" font-size="10">values (all)</text>
  <text x="460" y="177" text-anchor="middle" fill="#f59e0b" font-size="9">⚠ re-renders often</text>

  <!-- Imperative -->
  <rect x="528" y="130" width="118" height="50" rx="5" fill="#1a1f35" stroke="#a78bfa" stroke-width="1.2"/>
  <text x="587" y="150" text-anchor="middle" fill="#a78bfa" font-size="11">Imperative</text>
  <text x="587" y="165" text-anchor="middle" fill="#6b7280" font-size="10">store.subscribe()</text>
  <text x="587" y="177" text-anchor="middle" fill="#6b7280" font-size="10">no selector</text>

  <!-- Down arrows to API labels -->
  <line x1="80" y1="180" x2="80" y2="210" stroke="#22c55e" stroke-width="1"/>
  <line x1="208" y1="180" x2="208" y2="210" stroke="#22c55e" stroke-width="1"/>
  <line x1="330" y1="180" x2="330" y2="210" stroke="#f87171" stroke-width="1"/>
  <line x1="460" y1="180" x2="460" y2="210" stroke="#f59e0b" stroke-width="1"/>
  <line x1="587" y1="180" x2="587" y2="210" stroke="#a78bfa" stroke-width="1"/>

  <!-- API label boxes -->
  <rect x="24" y="210" width="112" height="26" rx="4" fill="#111827" stroke="#22c55e" stroke-width="1"/>
  <text x="80" y="227" text-anchor="middle" fill="#22c55e" font-size="10">form.useStore(sel)</text>

  <rect x="152" y="210" width="112" height="26" rx="4" fill="#111827" stroke="#22c55e" stroke-width="1"/>
  <text x="208" y="227" text-anchor="middle" fill="#22c55e" font-size="10">form.useStore(sel)</text>

  <rect x="270" y="210" width="120" height="26" rx="4" fill="#111827" stroke="#f87171" stroke-width="1"/>
  <text x="330" y="227" text-anchor="middle" fill="#f87171" font-size="10">form.useStore(sel)</text>

  <rect x="398" y="210" width="124" height="26" rx="4" fill="#111827" stroke="#f59e0b" stroke-width="1"/>
  <text x="460" y="227" text-anchor="middle" fill="#f59e0b" font-size="10">form.useStore()</text>

  <rect x="526" y="210" width="120" height="26" rx="4" fill="#111827" stroke="#a78bfa" stroke-width="1"/>
  <text x="586" y="227" text-anchor="middle" fill="#a78bfa" font-size="10">form.store.subscribe()</text>

  <!-- Legend -->
  <rect x="14" y="262" width="10" height="10" rx="2" fill="#22c55e"/>
  <text x="30" y="272" fill="#9ca3af" font-size="10">Selector-filtered (efficient)</text>
  <rect x="170" y="262" width="10" height="10" rx="2" fill="#f59e0b"/>
  <text x="186" y="272" fill="#9ca3af" font-size="10">Unfiltered React hook</text>
  <rect x="330" y="262" width="10" height="10" rx="2" fill="#a78bfa"/>
  <text x="346" y="272" fill="#9ca3af" font-size="10">Imperative / framework-agnostic</text>

  <text x="330" y="310" text-anchor="middle" fill="#374151" font-size="10">Each subscriber re-renders or fires only on its selected state slice</text>
</svg>

---

### Common Mistakes

**Subscribing to the full state in a frequently-rendered component**

```tsx
// Re-renders on every keystroke in any field
const state = form.useStore()

// Targeted — re-renders only when isSubmitting changes
const isSubmitting = form.useStore((s) => s.isSubmitting)
```

**Reading stale state inside a plain subscribe callback**

```ts
// Stale — captures state at subscription time, not update time
const snapshot = form.store.state

form.store.subscribe(() => {
  console.log(snapshot.values) // Always the initial snapshot
})

// Correct — read from store inside the callback
form.store.subscribe(() => {
  console.log(form.store.state.values)
})
```

**Using `form.subscribe` without cleanup in React**

```tsx
// Missing unsubscribe — listener persists after component unmounts
useEffect(() => {
  form.subscribe((s) => s.isSubmitted, handleSubmitted)
}, [])

// Correct
useEffect(() => {
  return form.subscribe((s) => s.isSubmitted, handleSubmitted)
}, [])
```

---

### Summary

Form-level subscribers give visibility into the holistic state of the form — submission lifecycle, dirty tracking, global error state, and full value snapshots. The `form.useStore` hook is the idiomatic React API, with selectors as the primary performance lever. For imperative or framework-agnostic contexts, `form.store.subscribe` and `form.subscribe` provide equivalent control with manual cleanup requirements.

**Related Topics**
- Field-level subscribers and per-field selector patterns
- `form.setErrorMap` — writing form-level errors imperatively
- `form.reset` and observing reset events via subscribers
- `submissionAttempts` for progressive disclosure of validation errors
- Synchronizing form state with external stores (Redux, Zustand, Jotai)
- Framework-agnostic usage of `form.store` outside React