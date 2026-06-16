## TanStack Form — Core Concepts — Form State: Values, Errors, Touched, Dirty

---

### Overview of Form State

TanStack Form maintains a centralized state object for the entire form. This state is not stored in React component state directly — it lives in TanStack Form's internal store, and components subscribe to slices of it reactively.

The four primary state categories are:

- **values** — the current data of all registered fields
- **errors** — validation messages associated with fields or the form
- **touched** — which fields the user has interacted with
- **dirty** — which fields have values that differ from their initial state

Each category exists at both the **field level** (per-field) and the **form level** (aggregated across all fields).

---

### Accessing State: Two Entry Points

**1. Inside a `form.Field` render prop — field-level state:**

tsx

```tsx
<form.Field name="email">
  {(field) => {
    const value   = field.state.value
    const errors  = field.state.meta.errors
    const touched = field.state.meta.isTouched
    const dirty   = field.state.meta.isDirty
    // ...
  }}
</form.Field>
```

**2. Via `form.Subscribe` — form-level or cross-field state:**

tsx

```tsx
<form.Subscribe selector={(state) => state}>
  {(state) => {
    const values     = state.values
    const errors     = state.errors       // [Unverified: exact shape — see note below]
    const isValid    = state.isValid
    const isDirty    = state.isDirty
    const isTouched  = state.isTouched    // [Unverified: verify in current docs]
    // ...
  }}
</form.Subscribe>
```

**Key Points:**

- Field-level state is the most granular and most commonly used
- Form-level state is useful for submit buttons, progress indicators, and cross-field logic
- `form.Subscribe` accepts a `selector` to limit re-renders to only the slice of state you care about

---

### Values

#### What Values Are

`values` is the current snapshot of all field data in the form, shaped identically to `defaultValues`.

tsx

```tsx
const form = useForm({
  defaultValues: {
    username: '',
    age: 0,
    address: {
      city: '',
    },
  },
})

// form-level values shape:
// {
//   username: string,
//   age: number,
//   address: { city: string }
// }
```

#### Field-Level Value

tsx

```tsx
<form.Field name="username">
  {(field) => <span>Current value: {field.state.value}</span>}
</form.Field>
```

#### Form-Level Values

tsx

```tsx
<form.Subscribe selector={(state) => state.values}>
  {(values) => (
    <pre>{JSON.stringify(values, null, 2)}</pre>
  )}
</form.Subscribe>
```

#### Programmatic Value Access

Outside of render, you can read the current values synchronously from the form instance:

tsx

```tsx
const currentValues = form.state.values
```

**Key Points:**

- `form.state` is a synchronous snapshot — safe to read in event handlers and submit callbacks
- `values` always reflects the last `handleChange` call for each field — not the DOM value, if they are out of sync
- Nested and array values are fully reflected in the `values` tree

---

### Errors

#### What Errors Are

Errors are validation messages produced by field validators or form-level validators. They are stored per-field and surface through `field.state.meta.errors`.

#### Field-Level Errors

tsx

```tsx
<form.Field
  name="email"
  validators={{
    onChange: ({ value }) =>
      !value.includes('@') ? 'Must be a valid email' : undefined,
  }}
>
  {(field) => (
    <div>
      <input
        value={field.state.value}
        onChange={(e) => field.handleChange(e.target.value)}
        onBlur={field.handleBlur}
      />
      {field.state.meta.isTouched && field.state.meta.errors.length > 0 && (
        <p>{field.state.meta.errors[0]}</p>
      )}
    </div>
  )}
</form.Field>
```

**Key Points:**

- `field.state.meta.errors` is an array — multiple validators can each contribute an error
- A validator returns `undefined` (no error) or a string (error message)
- Errors are only populated after the relevant validator event fires (`onChange`, `onBlur`, `onSubmit`, etc.)
- Displaying errors only when `isTouched` is true is a common UX pattern — avoids showing errors before the user has engaged

#### Error Array Shape

Each entry in `errors` corresponds to a validator that returned a message. If both `onChange` and `onBlur` validators fail simultaneously, both messages may be present. [Inference: exact deduplication and ordering behavior should be verified against current TanStack Form docs.]

tsx

```tsx
// Multiple errors possible:
field.state.meta.errors.map((error, i) => <p key={i}>{error}</p>)
```

#### `errorMap` — Errors by Validator Event

TanStack Form also exposes `field.state.meta.errorMap`, which maps errors to the event that triggered them:

tsx

```tsx
field.state.meta.errorMap
// { onChange: 'Must be a valid email', onBlur: undefined, onSubmit: undefined }
```

This lets you display different errors depending on interaction stage.

tsx

```tsx
{field.state.meta.errorMap.onChange && (
  <p className="inline-error">{field.state.meta.errorMap.onChange}</p>
)}
{field.state.meta.errorMap.onBlur && (
  <p className="blur-error">{field.state.meta.errorMap.onBlur}</p>
)}
```

#### Form-Level `isValid`

tsx

```tsx
<form.Subscribe selector={(state) => state.isValid}>
  {(isValid) => (
    <button type="submit" disabled={!isValid}>
      Submit
    </button>
  )}
</form.Subscribe>
```

**Key Points:**

- `isValid` is `true` when no field currently has errors in the store
- `isValid` does not account for fields whose validators have not yet fired — a pristine form with no user interaction may report `isValid: true` before any validation has run [Inference: this is the expected behavior of reactive validators — verify for your specific validation setup]
- For submit-time validation, `onSubmit` validators on fields provide a reliable final gate

---

### Touched

#### What Touched Means

A field is **touched** when the user has focused and then left it (blurred), or when `field.handleBlur` has been called. It does not require that the value changed — merely that the user visited the field.

Touched state is used primarily to gate error display: showing errors only after the user has had a chance to fill in the field.

#### Field-Level Touched

tsx

```tsx
<form.Field name="username">
  {(field) => (
    <div>
      <input
        value={field.state.value}
        onChange={(e) => field.handleChange(e.target.value)}
        onBlur={field.handleBlur}
      />
      {field.state.meta.isTouched && (
        <span>Field has been visited</span>
      )}
    </div>
  )}
</form.Field>
```

#### How Touched Is Set

| Action | Sets `isTouched` |
| --- | --- |
| `field.handleBlur()` called | Yes |
| `field.handleChange()` called | [Unverified: may depend on version and config — verify in current docs] |
| Form submitted | [Unverified: some libraries touch all fields on submit; confirm for TanStack Form] |
| `form.reset()` called | Resets to `false` |

#### Programmatic Touch

You can mark a field as touched without user interaction:

tsx

```tsx
form.setFieldMeta('email', (meta) => ({ ...meta, isTouched: true }))
```

[Unverified: exact API method name for setting field meta programmatically — verify against current TanStack Form API reference.]

#### Common Pattern: Touch-Gated Error Display

tsx

```tsx
{field.state.meta.isTouched && field.state.meta.errors.length > 0 && (
  <p className="error">{field.state.meta.errors[0]}</p>
)}
```

This is the most widely used touched pattern — errors are hidden until the user has engaged with the field.

---

### Dirty

#### What Dirty Means

A field is **dirty** when its current value differs from its initial value (the value it had when the form was mounted, from `defaultValues`).

Dirty state is used to:

- Warn users about unsaved changes before navigating away
- Enable/disable save buttons only when something has changed
- Identify which fields were actually modified before submitting

#### Field-Level Dirty

tsx

```tsx
<form.Field name="bio">
  {(field) => (
    <div>
      <textarea
        value={field.state.value}
        onChange={(e) => field.handleChange(e.target.value)}
      />
      {field.state.meta.isDirty && (
        <span>Unsaved changes</span>
      )}
    </div>
  )}
</form.Field>
```

#### Form-Level Dirty

tsx

```tsx
<form.Subscribe selector={(state) => state.isDirty}>
  {(isDirty) => (
    isDirty && <p>You have unsaved changes.</p>
  )}
</form.Subscribe>
```

#### Dirty vs. Touched — Key Distinction

|  | `isTouched` | `isDirty` |
| --- | --- | --- |
| Set by | Blur / focus-out | Value differs from initial |
| Requires value change | No | Yes |
| Resets on `form.reset()` | Yes | Yes |
| Use case | Gate error display | Detect actual modifications |

A field can be touched but not dirty (user visited it, did not change the value) and dirty but not touched (value changed programmatically, user never focused the field).

---

### `isSubmitting`, `isSubmitted`, `submitCount`

Beyond the four primary categories, form-level state includes submit lifecycle flags:

tsx

```tsx
<form.Subscribe
  selector={(state) => ({
    isSubmitting: state.isSubmitting,
    isSubmitted:  state.isSubmitted,
    submitCount:  state.submitCount,
  })}
>
  {({ isSubmitting, isSubmitted, submitCount }) => (
    <div>
      <button type="submit" disabled={isSubmitting}>
        {isSubmitting ? 'Submitting…' : 'Submit'}
      </button>
      {isSubmitted && <p>Form submitted {submitCount} time(s).</p>}
    </div>
  )}
</form.Subscribe>
```

**Key Points:**

- `isSubmitting` is `true` while the async `onSubmit` handler is running
- `isSubmitted` becomes `true` after the first successful submission
- `submitCount` increments on every submission attempt, including failed ones [Inference: verify exact increment conditions in current docs]

---

### Complete State Shape Reference

```
form.state
├── values                  — current field values (mirrors defaultValues shape)
├── errors                  — form-level error map [Unverified: exact shape]
├── isValid                 — true if no field has active errors
├── isDirty                 — true if any field value differs from initial
├── isTouched               — true if any field has been touched [Unverified: verify in docs]
├── isSubmitting            — true while onSubmit handler is pending
├── isSubmitted             — true after first successful submit
├── submitCount             — number of submit attempts
└── (per field via field.state)
    ├── value               — current field value
    └── meta
        ├── errors          — array of error messages
        ├── errorMap        — errors keyed by validator event
        ├── isTouched       — whether field has been blurred
        ├── isDirty         — whether value differs from initial
        ├── isValidating    — true while async validation is running
        └── isPristine      — inverse of isDirty [Unverified: confirm field availability]
```

---

### Resetting State

`form.reset()` restores the entire form to its initial state — values back to `defaultValues`, all errors cleared, touched and dirty reset to `false`.

tsx

```tsx
<button type="button" onClick={() => form.reset()}>
  Reset
</button>
```

You can also reset to a different set of values:

tsx

```tsx
form.reset({ username: 'prefilled', age: 25 })
```

[Unverified: the exact signature of `form.reset` with arguments — verify against current TanStack Form API docs, as this API may differ across versions.]

---

**Related Topics:**

- Validation modes — `onChange`, `onBlur`, `onSubmit`, `onMount` and when each populates errors
- Async validation — `onChangeAsync`, `onBlurAsync` and the `isValidating` flag
- `form.Subscribe` — selective state subscriptions for performance
- Cross-field validation — form-level validators accessing multiple field values
- Submit handling — `onSubmit`, `onSubmitInvalid`, and submit lifecycle
- `setFieldValue` and `setFieldMeta` — programmatic state manipulation
- Unsaved changes guard — using `isDirty` with router navigation prompts
- `isPristine` vs `isDirty` — confirm available meta flags in current docs