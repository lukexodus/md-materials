## TanStack Form with Solid

TanStack Form provides a first-class adapter for SolidJS, leveraging Solid's fine-grained reactivity model to deliver highly performant, granular form state updates without unnecessary re-renders.

---

### Overview

SolidJS differs fundamentally from React in its reactivity model — instead of a virtual DOM and component re-renders, Solid uses compiled reactive primitives (`createSignal`, `createMemo`, etc.) that update only the specific DOM nodes that depend on changed values. TanStack Form's Solid adapter is designed to work in harmony with this model.

The Solid adapter exposes a `createForm` function and field components/accessors that integrate directly with Solid's reactive graph.

---

### Installation

```bash
npm install @tanstack/solid-form
```

**Key Points:**
- Requires SolidJS as a peer dependency
- No separate core package installation is needed; `@tanstack/solid-form` bundles the necessary core internally

---

### Basic Setup and `createForm`

The entry point for TanStack Form in Solid is `createForm`, which replaces the `useForm` hook used in the React adapter.

```tsx
import { createForm } from '@tanstack/solid-form'

function MyForm() {
  const form = createForm(() => ({
    defaultValues: {
      username: '',
      email: '',
    },
    onSubmit: async ({ value }) => {
      console.log('Submitted:', value)
    },
  }))

  return (
    <form
      onSubmit={(e) => {
        e.preventDefault()
        e.stopPropagation()
        form.handleSubmit()
      }}
    >
      {/* fields go here */}
      <button type="submit">Submit</button>
    </form>
  )
}
```

**Key Points:**
- `createForm` accepts a function that returns the config object — this is idiomatic Solid style and allows the config to participate in the reactive graph if needed
- `form.handleSubmit()` is called imperatively; it does not require the event object

---

### Registering Fields with `form.Field`

TanStack Form's Solid adapter exposes `form.Field` as a component. This follows the same render-prop (children-as-function) pattern seen in other adapters, but Solid handles it through its own component model.

```tsx
<form.Field name="username">
  {(field) => (
    <div>
      <label>Username</label>
      <input
        value={field().state.value}
        onBlur={field().handleBlur}
        onInput={(e) => field().handleChange(e.currentTarget.value)}
      />
    </div>
  )}
</form.Field>
```

**Key Points:**
- In the Solid adapter, `field` inside the render function is a **signal accessor** — you must call it as `field()` to read its current value
- This is a critical distinction from the React adapter, where `field` is a plain object
- `field().state.value` reads the current field value reactively
- `field().handleChange(...)` updates the field value
- `field().handleBlur()` marks the field as touched

---

### Why `field` Is an Accessor

In SolidJS, reactive values are accessed via functions (signals). TanStack Form's Solid adapter wraps field state in a signal so that only the DOM nodes that read from `field()` update when that field's state changes — not the entire form component.

```tsx
// Correct — reactive, updates granularly
<input value={field().state.value} />

// Incorrect — reads the value once, non-reactive
const f = field
<input value={f.state.value} />
```

This pattern is consistent with SolidJS idioms and is the primary behavioral difference from the React adapter.

> [Inference] Because Solid's reactivity is compile-time and signal-based, accessing `field()` inside JSX should [Unverified: behavior may vary] cause only the relevant DOM node to update, not the parent component. Actual behavior depends on Solid's compiler and runtime version.

---

### Validation

Validation in the Solid adapter follows the same schema as other TanStack Form adapters. Validators can be defined at the field level or form level.

#### Synchronous Field Validation

```tsx
<form.Field
  name="email"
  validators={{
    onChange: ({ value }) => {
      if (!value.includes('@')) return 'Must be a valid email'
      return undefined
    },
  }}
>
  {(field) => (
    <div>
      <input
        value={field().state.value}
        onInput={(e) => field().handleChange(e.currentTarget.value)}
        onBlur={field().handleBlur}
      />
      {field().state.meta.errors.length > 0 && (
        <span>{field().state.meta.errors[0]}</span>
      )}
    </div>
  )}
</form.Field>
```

#### Async Field Validation

```tsx
<form.Field
  name="username"
  validators={{
    onChangeAsync: async ({ value }) => {
      await new Promise((r) => setTimeout(r, 300))
      if (value === 'taken') return 'Username is already taken'
      return undefined
    },
    onChangeAsyncDebounceMs: 400,
  }}
>
  {(field) => (
    <div>
      <input
        value={field().state.value}
        onInput={(e) => field().handleChange(e.currentTarget.value)}
      />
      {field().state.meta.isValidating && <span>Checking...</span>}
      {field().state.meta.errors[0] && (
        <span>{field().state.meta.errors[0]}</span>
      )}
    </div>
  )}
</form.Field>
```

---

### Schema-Based Validation with Valibot or Zod

TanStack Form's adapter-agnostic validator adapters work with the Solid integration as well.

```tsx
import { createForm } from '@tanstack/solid-form'
import { zodValidator } from '@tanstack/zod-form-adapter'
import { z } from 'zod'

const schema = z.object({
  email: z.string().email('Invalid email'),
  password: z.string().min(8, 'At least 8 characters'),
})

const form = createForm(() => ({
  defaultValues: { email: '', password: '' },
  validatorAdapter: zodValidator(),
  validators: {
    onChange: schema,
  },
  onSubmit: async ({ value }) => {
    console.log(value)
  },
}))
```

**Key Points:**
- `zodValidator()` and `valibotValidator()` are framework-agnostic and work identically in Solid
- Schema is passed to `validators.onChange` (or `onSubmit`, `onBlur`) at the form level

---

### Accessing Form State Reactively

To read form-level state (e.g., submission status, form-wide errors, or dirty state), TanStack Form provides `form.useStore`.

```tsx
import { createForm } from '@tanstack/solid-form'

function MyForm() {
  const form = createForm(() => ({
    defaultValues: { name: '' },
    onSubmit: async ({ value }) => console.log(value),
  }))

  const isSubmitting = form.useStore((state) => state.isSubmitting)
  const canSubmit = form.useStore((state) => state.canSubmit)

  return (
    <form onSubmit={(e) => { e.preventDefault(); form.handleSubmit() }}>
      <form.Field name="name">
        {(field) => (
          <input
            value={field().state.value}
            onInput={(e) => field().handleChange(e.currentTarget.value)}
          />
        )}
      </form.Field>
      <button type="submit" disabled={!canSubmit()}>
        {isSubmitting() ? 'Submitting...' : 'Submit'}
      </button>
    </form>
  )
}
```

**Key Points:**
- `form.useStore(selector)` returns a **signal accessor** in the Solid adapter — call it as `isSubmitting()` to read reactively
- Only the selected slice of form state is tracked, limiting reactive updates to where they are needed

---

### Array Fields

TanStack Form supports dynamic array fields in Solid using `form.Field` with array default values and `field().pushValue` / `field().removeValue`.

```tsx
const form = createForm(() => ({
  defaultValues: {
    tags: [''],
  },
  onSubmit: async ({ value }) => console.log(value),
}))

// Render
<form.Field name="tags" mode="array">
  {(field) => (
    <div>
      {field().state.value.map((_, i) => (
        <form.Field name={`tags[${i}]`}>
          {(subField) => (
            <input
              value={subField().state.value}
              onInput={(e) => subField().handleChange(e.currentTarget.value)}
            />
          )}
        </form.Field>
      ))}
      <button type="button" onClick={() => field().pushValue('')}>
        Add Tag
      </button>
    </div>
  )}
</form.Field>
```

**Key Points:**
- `mode="array"` instructs TanStack Form to treat the field as a list
- `field().pushValue(value)` appends a new entry
- `field().removeValue(index)` removes an entry at a given index
- Each array item is registered as a nested `form.Field` using bracket notation

---

### Nested Object Fields

Fields can be nested using dot notation in the `name` prop, allowing you to manage structured form data.

```tsx
const form = createForm(() => ({
  defaultValues: {
    address: {
      street: '',
      city: '',
    },
  },
  onSubmit: async ({ value }) => console.log(value),
}))

// In JSX:
<form.Field name="address.street">
  {(field) => (
    <input
      value={field().state.value}
      onInput={(e) => field().handleChange(e.currentTarget.value)}
    />
  )}
</form.Field>

<form.Field name="address.city">
  {(field) => (
    <input
      value={field().state.value}
      onInput={(e) => field().handleChange(e.currentTarget.value)}
    />
  )}
</form.Field>
```

---

### Field Meta and Touched/Dirty State

Each field exposes a `meta` object within its state, providing information about interaction and validation status.

```tsx
<form.Field name="username">
  {(field) => (
    <div>
      <input
        value={field().state.value}
        onBlur={field().handleBlur}
        onInput={(e) => field().handleChange(e.currentTarget.value)}
      />
      {field().state.meta.isTouched && field().state.meta.errors.length > 0 && (
        <span style={{ color: 'red' }}>{field().state.meta.errors[0]}</span>
      )}
      {field().state.meta.isDirty && (
        <small>Field has been modified</small>
      )}
    </div>
  )}
</form.Field>
```

| Meta Property | Type | Description |
|---|---|---|
| `isTouched` | `boolean` | True after the field has been blurred |
| `isDirty` | `boolean` | True if value differs from default |
| `isValidating` | `boolean` | True during async validation |
| `errors` | `string[]` | Active validation error messages |
| `errorMap` | `object` | Errors keyed by validation event |

---

### Full Working Example

```tsx
import { createForm } from '@tanstack/solid-form'

function RegistrationForm() {
  const form = createForm(() => ({
    defaultValues: {
      username: '',
      email: '',
      age: 0,
    },
    onSubmit: async ({ value }) => {
      alert(JSON.stringify(value, null, 2))
    },
  }))

  const canSubmit = form.useStore((s) => s.canSubmit)
  const isSubmitting = form.useStore((s) => s.isSubmitting)

  return (
    <form
      onSubmit={(e) => {
        e.preventDefault()
        e.stopPropagation()
        form.handleSubmit()
      }}
    >
      <form.Field
        name="username"
        validators={{
          onChange: ({ value }) =>
            value.length < 3 ? 'At least 3 characters' : undefined,
        }}
      >
        {(field) => (
          <div>
            <label>Username</label>
            <input
              value={field().state.value}
              onBlur={field().handleBlur}
              onInput={(e) => field().handleChange(e.currentTarget.value)}
            />
            {field().state.meta.errors[0] && (
              <span>{field().state.meta.errors[0]}</span>
            )}
          </div>
        )}
      </form.Field>

      <form.Field
        name="email"
        validators={{
          onChange: ({ value }) =>
            !value.includes('@') ? 'Invalid email' : undefined,
        }}
      >
        {(field) => (
          <div>
            <label>Email</label>
            <input
              type="email"
              value={field().state.value}
              onBlur={field().handleBlur}
              onInput={(e) => field().handleChange(e.currentTarget.value)}
            />
            {field().state.meta.errors[0] && (
              <span>{field().state.meta.errors[0]}</span>
            )}
          </div>
        )}
      </form.Field>

      <form.Field name="age">
        {(field) => (
          <div>
            <label>Age</label>
            <input
              type="number"
              value={field().state.value}
              onInput={(e) =>
                field().handleChange(Number(e.currentTarget.value))
              }
            />
          </div>
        )}
      </form.Field>

      <button type="submit" disabled={!canSubmit()}>
        {isSubmitting() ? 'Submitting...' : 'Register'}
      </button>
    </form>
  )
}
```

---

### Key Differences from the React Adapter

| Feature | React Adapter | Solid Adapter |
|---|---|---|
| Form initializer | `useForm(config)` | `createForm(() => config)` |
| Field accessor | `field` (plain object) | `field()` (signal accessor) |
| Store subscription | `form.useStore(selector)` returns value | `form.useStore(selector)` returns accessor |
| Re-render model | Component re-renders | Fine-grained DOM node updates |
| Config reactivity | Static object | Function allows reactive config |

---

### Common Pitfalls

**1. Forgetting to call `field()` as a function**

```tsx
// Wrong — field is not called, reads stale/undefined
<input value={field.state.value} />

// Correct
<input value={field().state.value} />
```

**2. Destructuring `field()` outside JSX**

```tsx
// Risky — breaks reactivity if done outside reactive context
const { state, handleChange } = field()

// Preferred — read inside JSX or effects
<input value={field().state.value} />
```

> [Inference] Destructuring a signal's return value outside a reactive context may cause the UI to not update when the signal changes. This is a general SolidJS pattern concern, not specific to TanStack Form. Actual behavior may vary.

**3. Not wrapping config in a function**

```tsx
// Less idiomatic for Solid
const form = createForm({ defaultValues: { name: '' } })

// Idiomatic — config as a function
const form = createForm(() => ({ defaultValues: { name: '' } }))
```

---

**Related Topics:**
- TanStack Form with Vue — adapter differences and `useForm` in Vue's Composition API
- TanStack Form with Angular — signal-based integration in Angular 17+
- Custom field components in Solid — abstracting `form.Field` into reusable components
- Controlled vs. uncontrolled patterns in Solid forms
- Using `createStore` alongside TanStack Form for complex external state
- TanStack Form with SolidStart — SSR considerations and form actions