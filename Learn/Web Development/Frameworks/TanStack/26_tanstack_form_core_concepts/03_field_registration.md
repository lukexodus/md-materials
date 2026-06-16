## TanStack Form — Core Concepts — Field Registration

Field registration is the mechanism by which TanStack Form becomes aware of individual form inputs. When you register a field, the form's state management layer begins tracking that field's value, validation state, touched/dirty status, and metadata. Understanding how this works is foundational to using TanStack Form correctly.

---

### What Field Registration Means

In TanStack Form, fields are not implicitly discovered from the DOM. You explicitly declare each field using the `form.Field` component (or the `useField` hook in lower-level usage). This declaration is what "registers" the field with the form instance.

When a field is registered:

- Its initial value is derived from the `defaultValues` provided to `useForm`
- The form allocates reactive state for that field path
- Validators, if any, are associated with the field
- The field becomes addressable by its `name` path

When a field is unregistered (unmounted), TanStack Form can optionally preserve or discard its value depending on configuration. [Inference: this mirrors the behavior seen in similar libraries like React Hook Form, though exact lifecycle defaults should be verified against the current TanStack Form docs.]

---

### The `form.Field` Component

The primary way to register a field is through `form.Field`, which is accessed from the form instance returned by `useForm`.

tsx

```tsx
import { useForm } from '@tanstack/react-form'

function MyForm() {
  const form = useForm({
    defaultValues: {
      username: '',
      age: 0,
    },
  })

  return (
    <form onSubmit={(e) => {
      e.preventDefault()
      form.handleSubmit()
    }}>
      <form.Field name="username">
        {(field) => (
          <input
            value={field.state.value}
            onChange={(e) => field.handleChange(e.target.value)}
            onBlur={field.handleBlur}
          />
        )}
      </form.Field>
    </form>
  )
}
```

**Key Points:**

- `name` is the field path string — it must correspond to a key in `defaultValues`
- The child is a render function receiving a `field` API object
- The field is registered when `form.Field` mounts and unregistered when it unmounts

---

### The `name` Prop and Field Paths

The `name` prop is how TanStack Form identifies a field within the form's state tree. It supports dot-notation and bracket-notation for nested and array fields.

tsx

```tsx
// Top-level field
<form.Field name="email">

// Nested field
<form.Field name="address.city">

// Array item field
<form.Field name="tags[0]">

// Array item nested field
<form.Field name="contacts[1].phone">
```

**Key Points:**

- The path must be valid relative to the shape of `defaultValues`
- TypeScript users benefit from type inference on the field path — invalid paths produce compile-time errors when types are correctly configured
- Deeply nested registration follows the same render-prop pattern regardless of depth

---

### The Field API Object

When a field is registered via the render prop, the `field` object exposes the full API for interacting with that field's state.

tsx

```tsx
<form.Field name="username">
  {(field) => {
    // field.state.value     — current value
    // field.state.meta      — touched, dirty, errors, etc.
    // field.handleChange    — update the value
    // field.handleBlur      — mark as touched
    // field.name            — the resolved field name/path
    // field.form            — reference back to the form instance

    return (
      <div>
        <input
          value={field.state.value}
          onChange={(e) => field.handleChange(e.target.value)}
          onBlur={field.handleBlur}
        />
        {field.state.meta.errors.length > 0 && (
          <span>{field.state.meta.errors[0]}</span>
        )}
      </div>
    )
  }}
</form.Field>
```

**Key Points:**

- `field.state.value` is always the current reactive value for that field
- `field.state.meta` contains touched, dirty, validating, and errors flags
- All field state updates are reactive — the render prop re-renders when the field's state changes

---

### Default Values and Initial State

Field registration initializes state from `defaultValues`. The path in `name` must correspond to an existing key in the `defaultValues` object for correct initialization.

tsx

```tsx
const form = useForm({
  defaultValues: {
    profile: {
      firstName: '',
      lastName: '',
    },
    scores: [0, 0, 0],
  },
})

// These registrations are all valid:
// <form.Field name="profile.firstName" />
// <form.Field name="profile.lastName" />
// <form.Field name="scores[0]" />
```

If a field path does not exist in `defaultValues`, the initial value will be `undefined`. [Inference: this may produce type errors in TypeScript and unpredictable validation behavior — treat it as a usage error unless documentation states otherwise.]

---

### Conditional Field Registration

Fields only participate in form state while mounted. If a field is conditionally rendered, it is registered on mount and unregistered on unmount.

tsx

```tsx
function ConditionalForm() {
  const form = useForm({
    defaultValues: {
      hasMiddleName: false,
      middleName: '',
    },
  })

  return (
    <form>
      <form.Field name="hasMiddleName">
        {(field) => (
          <input
            type="checkbox"
            checked={field.state.value}
            onChange={(e) => field.handleChange(e.target.checked)}
          />
        )}
      </form.Field>

      <form.Subscribe selector={(state) => state.values.hasMiddleName}>
        {(hasMiddleName) =>
          hasMiddleName && (
            <form.Field name="middleName">
              {(field) => (
                <input
                  value={field.state.value}
                  onChange={(e) => field.handleChange(e.target.value)}
                />
              )}
            </form.Field>
          )
        }
      </form.Subscribe>
    </form>
  )
}
```

**Key Points:**

- The `middleName` field is only registered when `hasMiddleName` is true
- Upon unmount, the field's value behavior (preserved vs. reset) depends on TanStack Form configuration and version — verify in current docs before relying on a specific behavior [Unverified: exact default unmount behavior may differ across versions]

---

### Registering Multiple Fields

Each `form.Field` instance is independent. Multiple fields can be registered in any component tree structure, including across child components, as long as they share the same `form` instance.

tsx

```tsx
function NameSection({ form }) {
  return (
    <>
      <form.Field name="firstName">
        {(field) => (
          <input
            value={field.state.value}
            onChange={(e) => field.handleChange(e.target.value)}
          />
        )}
      </form.Field>

      <form.Field name="lastName">
        {(field) => (
          <input
            value={field.state.value}
            onChange={(e) => field.handleChange(e.target.value)}
          />
        )}
      </form.Field>
    </>
  )
}
```

Passing `form` as a prop is valid. TanStack Form also supports a `FormContext` pattern for avoiding prop drilling. [Inference: consult current TanStack Form docs for `formOptions` and context-based access patterns, as API surface for this has evolved.]

---

### Array Fields and Dynamic Registration

For dynamic lists of fields, `form.Field` can be used alongside array manipulation utilities. Each array item field is registered by its indexed path.

tsx

```tsx
const form = useForm({
  defaultValues: {
    emails: [''],
  },
})

// In render:
<form.Field name="emails" mode="array">
  {(emailsField) => (
    <div>
      {emailsField.state.value.map((_, index) => (
        <form.Field key={index} name={`emails[${index}]`}>
          {(field) => (
            <input
              value={field.state.value}
              onChange={(e) => field.handleChange(e.target.value)}
            />
          )}
        </form.Field>
      ))}
      <button
        type="button"
        onClick={() => emailsField.pushValue('')}
      >
        Add Email
      </button>
    </div>
  )}
</form.Field>
```

**Key Points:**

- `mode="array"` on the parent field unlocks array manipulation methods like `pushValue`, `removeValue`, and `swapValues`
- Each indexed child field (`emails[0]`, `emails[1]`, etc.) is individually registered
- Using `index` as `key` is simple but can cause state issues on reorder — use a stable ID when order can change [Inference]

---

### TypeScript and Field Name Type Safety

TanStack Form is designed with strong TypeScript support. When `defaultValues` are typed, the `name` prop on `form.Field` is narrowed to valid paths only.

tsx

```tsx
const form = useForm({
  defaultValues: {
    username: '',
    age: 0,
  },
})

// Valid:
<form.Field name="username" />
<form.Field name="age" />

// TypeScript error — 'email' does not exist in defaultValues:
<form.Field name="email" />
```

This type narrowing extends to the `field.state.value` type — it will reflect the type of the value at that path in `defaultValues`. Behavior of type inference on deeply nested or dynamic paths may vary depending on TypeScript version and TanStack Form version. [Inference: verify against current type definitions for complex nested cases.]

---

### Registration Lifecycle Summary

```
form.Field mounts
       │
       ▼
Field path registered in form state
       │
       ▼
Initial value set from defaultValues[path]
       │
       ▼
Validators (if any) attached to field
       │
       ▼
Render prop receives field API
       │
       ▼
User interacts → handleChange / handleBlur called
       │
       ▼
form.Field unmounts
       │
       ▼
Field unregistered (value preservation depends on config)
```

---

**Related Topics:**

- `useField` hook — lower-level field registration outside of render-prop pattern
- Field validation — attaching validators at registration time (`validators` prop)
- Array field manipulation — `pushValue`, `removeValue`, `swapValues`, `moveValue`
- `form.Subscribe` — subscribing to form or field state without registering a field
- `FormContext` and `useFormContext` — accessing the form instance without prop drilling
- Controlled vs. uncontrolled field patterns in TanStack Form
- Field-level vs. form-level validation scoping
- `defaultValues` typing and deep path inference in TypeScript