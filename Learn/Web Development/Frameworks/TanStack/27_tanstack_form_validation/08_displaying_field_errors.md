## Displaying Field Errors

TanStack Form does not render error messages automatically. Error display is entirely the responsibility of the consuming component. The form exposes error state through each field's `meta` object, and you are responsible for reading from it and rendering markup. This design gives complete control over error presentation with no assumptions about styling or DOM structure.

---

### Where Errors Live

Every field exposes a `field.state.meta` object containing validation-related state.

ts

```ts
field.state.meta.errors        // string[] — current error messages
field.state.meta.errorMap      // Record<ValidationCause, string[]> — errors keyed by trigger
field.state.meta.isTouched     // boolean — field has been interacted with
field.state.meta.isDirty       // boolean — value differs from defaultValue
field.state.meta.isValidating  // boolean — async validation is in flight
```

**Key Points**

- `errors` is a flat array of all current error strings across all active validators
- `errorMap` preserves which validator trigger (`onChange`, `onBlur`, `onSubmit`) produced each error
- Both `errors` and `errorMap` are populated by the adapter or manual validators; they do not self-populate
- `isValidating` is only `true` during in-flight async validation; it is `false` for synchronous validators [Inference — based on TanStack Form's async handling design]

---

### Basic Error Rendering

The minimal pattern maps over `field.state.meta.errors` and renders each message.

tsx

```tsx
<form.Field
  name="email"
  validators={{
    onChange: ({ value }) =>
      !value.includes('@') ? 'Must be a valid email address' : undefined,
  }}
  children={(field) => (
    <div>
      <label htmlFor={field.name}>Email</label>
      <input
        id={field.name}
        value={field.state.value}
        onChange={(e) => field.handleChange(e.target.value)}
        onBlur={field.handleBlur}
      />
      {field.state.meta.errors.length > 0 && (
        <ul>
          {field.state.meta.errors.map((error) => (
            <li key={error}>{error}</li>
          ))}
        </ul>
      )}
    </div>
  )}
/>
```

**Key Points**

- Checking `.length > 0` before rendering avoids empty containers in the DOM
- Using `error` as the `key` is acceptable when messages are unique per field; add an index fallback if duplicate messages are possible
- There is no built-in error component — the markup is entirely yours

---

### Showing Errors Only After Interaction

Displaying errors immediately on page load before the user has touched a field is generally poor UX. Gate error rendering on `isTouched` or `isDirty`.

tsx

```tsx
{field.state.meta.isTouched && field.state.meta.errors.length > 0 && (
  <p className="field-error">
    {field.state.meta.errors[0]}
  </p>
)}
```

**Common gating strategies:**

- `isTouched` — field has received and lost focus at least once
- `isDirty` — value has changed from its default
- `isTouched || isDirty` — show after any interaction
- No gate — show immediately; useful for submission-triggered validation passes

**Key Points**

- `isTouched` becomes `true` after `field.handleBlur()` is called [Inference — verify with your version; behavior may vary]
- On form submission, TanStack Form marks all fields as touched by default, which causes gated errors to appear for untouched fields after a failed submit [Inference — verify actual touch-setting behavior on submit in your version]
- Choose one gating strategy consistently across the form

---

### Using `errorMap` for Trigger-specific Errors

`field.state.meta.errorMap` maps each validation cause to its errors, allowing you to display different messages depending on when validation fired.

tsx

```tsx
<form.Field
  name="username"
  validators={{
    onChange: ({ value }) =>
      value.length < 3 ? 'At least 3 characters' : undefined,
    onBlur: ({ value }) =>
      value.length === 0 ? 'Username is required' : undefined,
  }}
  children={(field) => (
    <div>
      <input
        value={field.state.value}
        onChange={(e) => field.handleChange(e.target.value)}
        onBlur={field.handleBlur}
      />
      {field.state.meta.errorMap.onChange && (
        <p className="inline-error">
          {field.state.meta.errorMap.onChange}
        </p>
      )}
      {field.state.meta.errorMap.onBlur && (
        <p className="blur-error">
          {field.state.meta.errorMap.onBlur}
        </p>
      )}
    </div>
  )}
/>
```

**Key Points**

- `errorMap` keys are the same strings as validator keys: `'onChange'`, `'onBlur'`, `'onSubmit'`, `'onChangeAsync'`, etc.
- `errorMap` values may be strings or string arrays depending on the adapter and validator configuration [Unverified — inspect the actual shape in your version before assuming a type]
- This approach is useful when inline (typing) feedback and blur feedback carry different semantics

---

### Async Validation State

When async validators are running, `field.state.meta.isValidating` is `true`. Use this to show a loading indicator in place of or alongside the error area.

tsx

```tsx
<form.Field
  name="username"
  validators={{
    onChangeAsync: async ({ value }) => {
      const taken = await checkUsernameAvailability(value)
      return taken ? 'Username is already taken' : undefined
    },
    onChangeAsyncDebounceMs: 400,
  }}
  children={(field) => (
    <div>
      <input
        value={field.state.value}
        onChange={(e) => field.handleChange(e.target.value)}
      />
      {field.state.meta.isValidating && (
        <span className="validating">Checking availability…</span>
      )}
      {!field.state.meta.isValidating &&
        field.state.meta.errors.length > 0 && (
          <p className="field-error">{field.state.meta.errors[0]}</p>
        )}
    </div>
  )}
/>
```

**Key Points**

- Hiding errors while `isValidating` is `true` prevents a previous error from flickering during a new async check
- The loading indicator and error message are mutually exclusive in this pattern
- `isValidating` resets to `false` once the async validator resolves or rejects [Inference — based on standard async state lifecycle]

---

### Reusable Field Error Component

Extracting error display into a shared component reduces repetition across large forms.

tsx

```tsx
// components/FieldError.tsx
interface FieldErrorProps {
  errors: string[]
  touched?: boolean
}

export function FieldError({ errors, touched = true }: FieldErrorProps) {
  if (!touched || errors.length === 0) return null
  return (
    <ul className="field-errors" role="alert" aria-live="polite">
      {errors.map((error) => (
        <li key={error} className="field-error">
          {error}
        </li>
      ))}
    </ul>
  )
}
```

tsx

```tsx
// Usage in a field
<form.Field
  name="email"
  validators={{ onChange: emailSchema }}
  children={(field) => (
    <div>
      <input ... />
      <FieldError
        errors={field.state.meta.errors}
        touched={field.state.meta.isTouched}
      />
    </div>
  )}
/>
```

**Key Points**

- `role="alert"` and `aria-live="polite"` cause screen readers to announce errors when they appear — important for accessibility
- Keeping the component stateless (pure props) makes it straightforward to test in isolation
- The `touched` prop gate can be omitted for submission-only error display

---

### Accessibility Considerations

Error messages must be associated with their input for screen readers and assistive technologies.

tsx

```tsx
<form.Field
  name="email"
  children={(field) => {
    const errorId = `${field.name}-error`
    const hasError = field.state.meta.isTouched &&
      field.state.meta.errors.length > 0

    return (
      <div>
        <label htmlFor={field.name}>Email</label>
        <input
          id={field.name}
          value={field.state.value}
          onChange={(e) => field.handleChange(e.target.value)}
          onBlur={field.handleBlur}
          aria-describedby={hasError ? errorId : undefined}
          aria-invalid={hasError ? 'true' : undefined}
        />
        {hasError && (
          <p id={errorId} role="alert">
            {field.state.meta.errors[0]}
          </p>
        )}
      </div>
    )
  }}
/>
```

**Key Points**

- `aria-describedby` links the input to its error message by ID; screen readers read the error when the input receives focus
- `aria-invalid="true"` signals to assistive technologies that the field is in an error state
- Only set `aria-describedby` when an error is actually present; a stale reference to a non-rendered element does not cause errors but is unnecessary
- `role="alert"` on the error paragraph causes immediate announcement when it appears in the DOM

---

### Form-level Error Summary

For long or multi-section forms, displaying a summary of all errors at the top after a failed submit improves usability.

tsx

```tsx
function FormErrorSummary({ form }: { form: ReturnType<typeof useForm> }) {
  const errors = form.state.errors

  if (!form.state.isSubmitted || errors.length === 0) return null

  return (
    <div role="alert" aria-live="assertive" className="error-summary">
      <p>Please fix the following errors before submitting:</p>
      <ul>
        {errors.map((error) => (
          <li key={String(error)}>{String(error)}</li>
        ))}
      </ul>
    </div>
  )
}
```

**Key Points**

- `form.state.errors` aggregates errors across all fields [Inference — verify the exact shape; it may differ from individual `field.state.meta.errors` arrays]
- `form.state.isSubmitted` gates the summary to post-submission only
- `aria-live="assertive"` is appropriate for a summary that appears after a user action like submission, where immediate announcement is expected
- Individual field errors and a summary can coexist; the summary acts as navigation context while inline errors provide specific field-level feedback

---

### Styling Error States on the Input

Beyond rendering text, it is common to visually style the input itself when invalid.

tsx

```tsx
<input
  id={field.name}
  value={field.state.value}
  onChange={(e) => field.handleChange(e.target.value)}
  onBlur={field.handleBlur}
  className={
    field.state.meta.isTouched && field.state.meta.errors.length > 0
      ? 'input input--error'
      : 'input'
  }
  aria-invalid={
    field.state.meta.isTouched && field.state.meta.errors.length > 0
      ? 'true'
      : undefined
  }
/>
```

Or with a utility-class approach:

tsx

```tsx
className={[
  'border rounded px-3 py-2',
  field.state.meta.isTouched && field.state.meta.errors.length > 0
    ? 'border-red-500 bg-red-50'
    : 'border-gray-300',
].join(' ')}
```

**Key Points**

- Error styling should complement, not replace, the text error message — color alone is insufficient for accessibility
- Avoid removing error styling before the user has corrected the field; re-validate on `onChange` to clear errors as the user types

---

### Complete Single-field Example

tsx

```tsx
import { useForm } from '@tanstack/react-form'
import { zodValidator } from '@tanstack/zod-form-adapter'
import { z } from 'zod'

function EmailField() {
  const form = useForm({
    defaultValues: { email: '' },
    validatorAdapter: zodValidator(),
  })

  return (
    <form
      onSubmit={(e) => {
        e.preventDefault()
        form.handleSubmit()
      }}
    >
      <form.Field
        name="email"
        validators={{
          onChange: z.string().email('Must be a valid email address'),
          onBlur: z.string().min(1, 'Email is required'),
        }}
        children={(field) => {
          const errorId = `${field.name}-error`
          const showError =
            field.state.meta.isTouched &&
            field.state.meta.errors.length > 0

          return (
            <div className="field">
              <label htmlFor={field.name}>Email</label>
              <input
                id={field.name}
                type="email"
                value={field.state.value}
                onChange={(e) => field.handleChange(e.target.value)}
                onBlur={field.handleBlur}
                aria-describedby={showError ? errorId : undefined}
                aria-invalid={showError ? 'true' : undefined}
                className={showError ? 'input input--error' : 'input'}
              />
              {field.state.meta.isValidating && (
                <span className="validating">Validating…</span>
              )}
              {showError && (
                <p id={errorId} role="alert" className="field-error">
                  {field.state.meta.errors[0]}
                </p>
              )}
            </div>
          )
        }}
      />
      <button type="submit">Submit</button>
    </form>
  )
}
```

---

**Related Topics**

- Controlling validation timing: `onChange` vs `onBlur` vs `onSubmit` strategies
- Building a reusable field wrapper component that encapsulates label, input, and error display
- Integrating TanStack Form error state with component libraries (shadcn/ui, Radix, MUI)
- Form submission state: `isSubmitting`, `isSubmitted`, `canSubmit`
- Scroll-to-error behavior on failed form submission
- Internationalizing error messages in multi-locale applications
- Resetting field errors programmatically