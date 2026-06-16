## TanStack Form — Synchronous Field Validation

---

### Overview

TanStack Form provides a flexible, field-centric validation model. Synchronous validators run immediately — on change, on blur, or on submit — and return either an error message string or `undefined`/`null` to indicate passing. Validation is colocated with the field definition, keeping logic close to the UI it governs.

---

### Where Validators Are Defined

Validators are passed to the `<form.Field>` component (or `useField`) via the `validators` prop. Each validator is scoped to a specific event trigger.

tsx

```tsx
<form.Field
  name="username"
  validators={{
    onChange: ({ value }) => {
      if (!value) return 'Username is required'
      if (value.length < 3) return 'Must be at least 3 characters'
      return undefined
    },
  }}
  children={(field) => (
    <input
      value={field.state.value}
      onChange={(e) => field.handleChange(e.target.value)}
      onBlur={field.handleBlur}
    />
  )}
/>
```

**Key Points:**

- Returning a string signals a validation error — the string becomes the error message.
- Returning `undefined`, `null`, or `false` signals the field is valid. [Unverified: exact falsy return values accepted may vary by version — confirm against current docs.]
- The validator receives an object `{ value, fieldApi }` — `value` is the current field value; `fieldApi` exposes the full field API for cross-field access. [Unverified: `fieldApi` availability in sync validators — verify for your version.]

---

### Validator Trigger Events

Three synchronous trigger points are available:

| Validator Key | Fires When |
| --- | --- |
| `onChange` | Every time the field value changes |
| `onBlur` | When the field loses focus |
| `onSubmit` | When the form's submit handler is invoked |

Each is independent and can be defined simultaneously:

tsx

```tsx
validators={{
  onChange: ({ value }) =>
    value.trim() === '' ? 'Required' : undefined,
  onBlur: ({ value }) =>
    value.length < 3 ? 'Too short' : undefined,
  onSubmit: ({ value }) =>
    !isValidEmail(value) ? 'Invalid email format' : undefined,
}}
```

**Key Points:**

- Multiple validator keys on the same field run independently. Their errors do not automatically merge — the most recently triggered validator's result is what appears, based on when each event fires. [Inference: error state per trigger may overwrite independently; verify exact error aggregation behavior for your version.]
- `onSubmit` validators run even if the field has not been touched.

---

### Accessing and Displaying Errors

Validation errors are stored in `field.state.meta.errors` — an array of error values.

tsx

```tsx
<form.Field
  name="email"
  validators={{
    onChange: ({ value }) =>
      value.includes('@') ? undefined : 'Must be a valid email',
  }}
  children={(field) => (
    <div>
      <input
        value={field.state.value}
        onChange={(e) => field.handleChange(e.target.value)}
      />
      {field.state.meta.errors.length > 0 && (
        <span>{field.state.meta.errors[0]}</span>
      )}
    </div>
  )}
/>
```

**Key Points:**

- `errors` is an array because multiple validators (across triggers) can contribute errors simultaneously.
- Rendering `errors[0]` shows the first active error. Rendering all is also valid depending on UX requirements.
- `field.state.meta.errorMap` provides a trigger-keyed map of errors (`onChange`, `onBlur`, `onSubmit`) for more granular rendering control.

#### Using `errorMap` for Trigger-Specific Display

tsx

```tsx
const { errorMap } = field.state.meta

return (
  <div>
    {errorMap.onChange && <span className="inline-error">{errorMap.onChange}</span>}
    {errorMap.onBlur && <span className="blur-error">{errorMap.onBlur}</span>}
  </div>
)
```

---

### Controlling When Errors Are Shown

By default, errors from `onChange` validators appear immediately on the first keystroke, which can feel aggressive. A common pattern is to gate error display behind `isTouched`:

tsx

```tsx
{field.state.meta.isTouched && field.state.meta.errors.length > 0 && (
  <span>{field.state.meta.errors[0]}</span>
)}
```

This delays error visibility until the user has interacted with the field at least once.

A related pattern uses `onBlur` as the primary validator instead of `onChange`, so errors only surface after the user leaves the field:

tsx

```tsx
validators={{
  onBlur: ({ value }) =>
    value.trim() === '' ? 'This field is required' : undefined,
}}
```

---

### Built-in Validator Adapters

TanStack Form supports schema-based validation via adapters (e.g., Zod, Valibot, ArkType). Even when using an adapter, the sync vs. async distinction still applies — schema validators that are purely synchronous resolve immediately.

ts

```ts
import { zodValidator } from '@tanstack/zod-form-adapter'
import { z } from 'zod'

<form.Field
  name="age"
  validatorAdapter={zodValidator()}
  validators={{
    onChange: z.number().min(18, 'Must be 18 or older'),
  }}
/>
```

**Key Points:**

- The adapter translates the schema's parse result into TanStack Form's error format.
- When using adapters, the validator value is the schema itself rather than a function. [Unverified: exact adapter API signature — verify against the adapter package's current docs.]
- Zod schemas with purely synchronous refinements still run synchronously through the adapter. [Inference]

---

### Form-Level vs. Field-Level Validators

Validators can also be defined at the form level via `useForm`'s `validators` option. Form-level validators receive the entire form values object.

ts

```ts
const form = useForm({
  defaultValues: { password: '', confirmPassword: '' },
  validators: {
    onChange: ({ value }) => {
      if (value.password !== value.confirmPassword) {
        return 'Passwords do not match'
      }
      return undefined
    },
  },
})
```

**Key Points:**

- Form-level errors are accessible via `form.state.errors`.
- Cross-field validation (e.g., password confirmation) belongs at the form level since it requires access to multiple field values simultaneously.
- Field-level validators are preferred for single-field constraints; form-level validators for relational constraints.

---

### Validation Execution Flow

changeblursubmitYesNoUser interacts with fieldWhich event?onChange validator runsonBlur validator runsonSubmit validator runsReturns string?Error stored infield.state.meta.errorsError cleared for thattriggererrorMap updated bytrigger keyComponent re-renderswith current error state

---

### Validator Composition — Multiple Rules

For fields with several rules, composing validators explicitly keeps logic readable:

ts

```ts
const validatePassword = ({ value }: { value: string }) => {
  if (!value) return 'Password is required'
  if (value.length < 8) return 'Must be at least 8 characters'
  if (!/[A-Z]/.test(value)) return 'Must contain an uppercase letter'
  if (!/[0-9]/.test(value)) return 'Must contain a number'
  return undefined
}

// In the field:
validators={{ onChange: validatePassword }}
```

**Key Points:**

- Only the first matched condition returns — subsequent rules do not run once a string is returned. This is standard early-return guard-clause behavior in JavaScript.
- To surface multiple errors simultaneously, return an array or a formatted multi-line string. [Unverified: array return support — verify for your version. Behavior is not guaranteed.]

---

### `onChangeAsyncDebounceMs` vs. Sync

Synchronous validators on `onChange` fire on every keystroke with no debounce. If a validator is computationally light (string checks, regex, length), this is appropriate. For anything heavier, use the async validator API with debouncing instead — this is covered under async validation.

ts

```ts
validators={{
  onChange: ({ value }) => value.length > 100 ? 'Too long' : undefined, // sync: fine
  onChangeAsync: async ({ value }) => await checkUsernameAvailable(value), // async: debounce
  onChangeAsyncDebounceMs: 400,
}}
```

---

### Summary

| Concern | Mechanism |
| --- | --- |
| Define sync validator | `validators.onChange / onBlur / onSubmit` on `<form.Field>` |
| Signal error | Return a string |
| Signal valid | Return `undefined` |
| Access errors | `field.state.meta.errors` (array) |
| Per-trigger errors | `field.state.meta.errorMap` |
| Gate display | Check `isTouched` before rendering |
| Cross-field validation | Form-level `validators` on `useForm` |
| Schema-based sync validation | Adapter (Zod, Valibot) with sync schema |

---

**Related Topics:**

- Asynchronous field validation and debouncing
- Validator adapters — Zod, Valibot, ArkType integration
- `onSubmit`-only validation patterns
- Form-level validation and cross-field rules
- Displaying multiple errors per field
- Conditional validation — validators that depend on other field values
- `isValid`, `canSubmit` — derived form state from validation results