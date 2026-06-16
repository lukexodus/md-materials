## TanStack Form — `useForm` and the Form Instance

`useForm` is the primary hook for initializing a form in TanStack Form (React adapter). It returns a **form instance** — an object that holds all form state and exposes methods for interacting with the form programmatically.

---

### Initializing a Form

`useForm` accepts a configuration object and returns the form instance. The configuration is not reactive in most cases — it is read at initialization time.

ts

```ts
import { useForm } from '@tanstack/react-form';

const form = useForm({
  defaultValues: {
    username: '',
    age: 0,
    agreed: false,
  },
  onSubmit: async ({ value }) => {
    // value is typed as { username: string, age: number, agreed: boolean }
    await submitToServer(value);
  },
});
```

**Key Points:**

- `defaultValues` is required and seeds both the initial form state and TypeScript type inference
- All field types are inferred from `defaultValues` — no separate type annotation is needed in most cases
- `onSubmit` receives an object with `value` (current form values) and `formApi` (the form instance)

---

### Configuration Options

#### `defaultValues`

Sets the initial value of every field. This is the primary source of type information for the form.

ts

```ts
defaultValues: {
  email: '',
  count: 0,
  tags: [] as string[],
}
```

**Key Points:**

- Arrays must be typed explicitly (e.g., `[] as string[]`) or TypeScript infers `never[]`
- Nested objects are supported and their fields are accessed with dot notation in `form.Field`

#### `onSubmit`

Called when the form is submitted and all validation passes.

ts

```ts
onSubmit: async ({ value, formApi }) => {
  await save(value);
  formApi.reset();
}
```

#### `onSubmitInvalid`

Called when submission is attempted but validation fails. Useful for analytics or user feedback.

ts

```ts
onSubmitInvalid: ({ value, formApi }) => {
  console.warn('Submission blocked by validation errors');
}
```

#### `validators`

Form-level validators that run against the entire form value, not a single field. Covered in depth in the validation topic.

ts

```ts
validators: {
  onChange: ({ value }) =>
    value.endDate < value.startDate ? 'End date must be after start date' : undefined,
}
```

#### `defaultState`

Allows overriding specific pieces of initial form meta-state (e.g., marking the form as already submitted). Used in advanced scenarios such as server-side rendered initial state.

> [Inference] `defaultState` structure may vary by version. Verify against your version's type definitions before use.

---

### The Form Instance

The object returned by `useForm` is the form instance. It is the central API surface for everything the form does.

ts

```ts
const form = useForm({ ... });
```

The form instance exposes:

- **State accessors** — read current form state
- **Field components** — render and connect individual fields
- **Imperative methods** — submit, reset, set values programmatically
- **Subscription utilities** — react to form state changes

---

### `form.state` — Reading Form State

`form.state` holds a snapshot of the current form state. Key properties:

| Property | Type | Description |
| --- | --- | --- |
| `values` | `TFormValues` | Current values of all fields |
| `errors` | `FormValidationError[]` | Form-level validation errors |
| `isSubmitting` | `boolean` | True while `onSubmit` is executing |
| `isSubmitted` | `boolean` | True after a successful submission |
| `isDirty` | `boolean` | True if any field value differs from `defaultValues` |
| `isTouched` | `boolean` | True if any field has been touched |
| `isValid` | `boolean` | True when there are no validation errors |
| `isValidating` | `boolean` | True while async validation is running |
| `submissionAttempts` | `number` | Number of times submission has been attempted |

**Example:**

tsx

```tsx
<button disabled={form.state.isSubmitting}>
  {form.state.isSubmitting ? 'Saving...' : 'Submit'}
</button>
```

> [Inference] Accessing `form.state` directly in the render function causes the component to re-render on every state change. For granular subscriptions, `useStore` is preferable. See the subscriptions topic for detail.

---

### `form.Field` — Rendering Fields

`form.Field` is a component on the form instance used to connect a field to the form. It uses a render prop pattern.

tsx

```tsx
<form.Field name="username">
  {(field) => (
    <input
      value={field.state.value}
      onChange={(e) => field.handleChange(e.target.value)}
      onBlur={field.handleBlur}
    />
  )}
</form.Field>
```

**Key Points:**

- `name` is type-safe — TypeScript narrows it to valid keys of `defaultValues`
- Nested fields use dot notation: `name="address.city"`
- Array fields use index notation: `name="tags[0]"`
- The render prop receives a `field` object — the Field API

---

### `form.handleSubmit` — Triggering Submission

`form.handleSubmit` runs validation and, if valid, calls `onSubmit`. It is used as the form's submit handler.

tsx

```tsx
<form
  onSubmit={(e) => {
    e.preventDefault();
    form.handleSubmit();
  }}
>
```

**Key Points:**

- Always call `e.preventDefault()` separately — `handleSubmit` does not do this automatically
- It returns a `Promise` — you can `await` it if you need to act after submission completes
- If validation fails, `onSubmit` is not called and `onSubmitInvalid` fires instead

---

### `form.reset` — Resetting Form State

Resets all field values to `defaultValues` and clears all meta-state (touched, dirty, errors).

ts

```ts
form.reset();
```

An optional argument allows resetting to a different set of values:

ts

```ts
form.reset({ username: 'prefilled', age: 25, agreed: false });
```

> [Inference] Whether `reset` accepts a partial or full values object may depend on the version. Verify the method signature in your version's type definitions.

---

### `form.setFieldValue` — Programmatic Value Setting

Sets the value of a specific field imperatively, outside of a field's `handleChange`.

ts

```ts
form.setFieldValue('username', 'alice');
```

Useful for:

- Populating fields from external data (e.g., autofill, selection from a lookup)
- Cross-field value updates triggered by a change in another field

**Key Points:**

- This bypasses field-level `onChange` validators unless you explicitly trigger validation afterward
- Combine with `form.validateField` if validation must run after a programmatic set [Inference — method availability and name may vary by version]

---

### `form.setFieldMeta` — Programmatic Meta Setting

Allows setting field meta-state (touched, dirty, errors) programmatically.

ts

```ts
form.setFieldMeta('email', (prev) => ({ ...prev, isTouched: true }));
```

Useful for marking fields as touched before submission to reveal errors.

---

### `form.getFieldValue` — Reading a Single Field Value

Returns the current value of a specific field without subscribing to its changes.

ts

```ts
const current = form.getFieldValue('username');
```

---

### `form.validate` — Manually Triggering Validation

Runs all validators for all fields and returns a promise resolving to the validation result.

ts

```ts
const result = await form.validate('submit'); // or 'change', 'blur'
```

The argument specifies which validation cause to trigger.

---

### Full Initialization Example

tsx

```tsx
import { useForm } from '@tanstack/react-form';

function RegistrationForm() {
  const form = useForm({
    defaultValues: {
      username: '',
      email: '',
      age: 18,
    },
    onSubmit: async ({ value }) => {
      await registerUser(value);
    },
    onSubmitInvalid: () => {
      alert('Please fix the errors before submitting.');
    },
  });

  return (
    <form onSubmit={(e) => { e.preventDefault(); form.handleSubmit(); }}>
      <form.Field name="username">
        {(field) => (
          <>
            <label>Username</label>
            <input
              value={field.state.value}
              onChange={(e) => field.handleChange(e.target.value)}
              onBlur={field.handleBlur}
            />
            {field.state.meta.errors.length > 0 && (
              <span>{field.state.meta.errors.join(', ')}</span>
            )}
          </>
        )}
      </form.Field>

      <form.Field name="age">
        {(field) => (
          <input
            type="number"
            value={field.state.value}
            onChange={(e) => field.handleChange(Number(e.target.value))}
            onBlur={field.handleBlur}
          />
        )}
      </form.Field>

      <button type="submit" disabled={form.state.isSubmitting}>
        Register
      </button>

      {form.state.isSubmitted && <p>Registration successful.</p>}
    </form>
  );
}
```

---

### Form Instance at a Glance

useForm configform instanceform.stateform.Fieldform.handleSubmitform.resetform.setFieldValueform.validateform.getFieldValuevalues, errors,isSubmittingisDirty, isValid,isSubmittedfield.state.valuefield.state.metafield.handleChangefield.handleBlur

---

### Common Mistakes

**1. Mutating `form.state.values` directly**

`form.state` is a read-only snapshot. Mutating it directly has no effect and may cause subtle bugs. Use `form.setFieldValue` or field-level `handleChange` instead.

**2. Omitting `e.preventDefault()` from the form's `onSubmit`**

`form.handleSubmit` does not prevent the native form submission. Always call `e.preventDefault()` explicitly.

**3. Using untyped arrays in `defaultValues`**

ts

```ts
// Inferred as never[] — causes type errors on field access
tags: []

// Correct
tags: [] as string[]
```

**4. Expecting `defaultValues` changes to reset the form**

`defaultValues` is read once at initialization. Changing the object passed to `useForm` after mount does not update the form. Use `form.reset(newValues)` to apply new defaults programmatically.

---

**Related Topics:**

- `form.Field` and the Field API — `field.state`, `field.handleChange`, `field.handleBlur`
- Validation — per-field validators, form-level validators, async validation
- `useStore` and granular form state subscriptions
- `defaultState` — advanced initial state configuration
- Array fields — dynamic field lists with `pushValue` and `removeValue`
- `form.setFieldValue` cross-field update patterns
- TanStack Form with TanStack Query — async submission coordination