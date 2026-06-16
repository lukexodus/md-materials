## TanStack Form — Validation on Change, Blur, and Submit

---

### Overview

TanStack Form ties validation execution to three distinct user interaction events: value change, field blur, and form submission. Each trigger serves a different UX purpose — immediate feedback, exit confirmation, and final gate. Understanding when each fires, how errors accumulate across triggers, and how to compose them deliberately is central to building validation that feels appropriate rather than intrusive.

---

### The Three Trigger Points

#### `onChange`

Fires every time the field's value changes — on every keystroke for text inputs, on every selection for dropdowns, and so on.

tsx

```tsx
validators={{
  onChange: ({ value }) =>
    value.trim() === '' ? 'This field is required' : undefined,
}}
```

**Key Points:**

- Provides the most immediate feedback possible.
- Can feel aggressive if errors appear before the user has finished typing.
- Best suited for constraints where early feedback is genuinely helpful — e.g., character limits, format masks, or disallowed characters.
- Pairs well with an `isTouched` display guard to soften the experience (covered below).

#### `onBlur`

Fires once when the field loses focus — when the user tabs away or clicks elsewhere.

tsx

```tsx
validators={{
  onBlur: ({ value }) =>
    value.length < 8 ? 'Must be at least 8 characters' : undefined,
}}
```

**Key Points:**

- A widely accepted UX pattern: validate after the user has finished with a field, not during entry.
- Fires once per focus loss, not continuously — makes it appropriate for more expensive checks that do not need debouncing.
- Does not re-run on subsequent changes unless the field is blurred again — if `onChange` is not also defined, errors from `onBlur` will persist until the next blur event even if the user corrects the value. [Inference: this is the expected behavior given independent trigger evaluation; confirm against your version.]

#### `onSubmit`

Fires when the form's submit handler is invoked, regardless of prior interaction with the field.

tsx

```tsx
validators={{
  onSubmit: ({ value }) =>
    !value ? 'Required before submitting' : undefined,
}}
```

**Key Points:**

- Runs on every field, including fields the user never touched.
- Acts as the final validation gate — catches anything missed by `onChange` and `onBlur`.
- Does not fire on change or blur, so it does not produce inline feedback during normal form interaction.
- Particularly useful for required fields in sparse forms where users may skip sections.

---

### Using All Three Together

The triggers are independent and composable. Each can carry a different rule or the same rule at different points in the interaction lifecycle:

tsx

```tsx
<form.Field
  name="email"
  validators={{
    onChange: ({ value }) =>
      value.includes('@') ? undefined : 'Enter a valid email address',
    onBlur: ({ value }) =>
      value.trim() === '' ? 'Email is required' : undefined,
    onSubmit: ({ value }) =>
      !value ? 'Email must be provided' : undefined,
  }}
  children={(field) => (
    <div>
      <input
        type="email"
        value={field.state.value}
        onChange={(e) => field.handleChange(e.target.value)}
        onBlur={field.handleBlur}
      />
      {field.state.meta.isTouched && field.state.meta.errors.length > 0 && (
        <span>{field.state.meta.errors[0]}</span>
      )}
    </div>
  )}
/>
```

**Key Points:**

- `field.handleBlur` must be wired to the input's `onBlur` event for `onBlur` and `onBlurAsync` validators to fire. It is not automatic.
- Errors from all triggers accumulate in `field.state.meta.errors`. The array may contain entries from multiple triggers simultaneously.
- `field.state.meta.errorMap` provides per-trigger access if different triggers need to be displayed differently.

---

### `errorMap` — Per-Trigger Error Access

When different triggers should surface errors in different ways — e.g., inline on blur, summary on submit — `errorMap` exposes them by key:

tsx

```tsx
const { errorMap } = field.state.meta

return (
  <div>
    <input
      value={field.state.value}
      onChange={(e) => field.handleChange(e.target.value)}
      onBlur={field.handleBlur}
    />
    {errorMap.onChange && (
      <span className="error-inline">{errorMap.onChange}</span>
    )}
    {errorMap.onBlur && (
      <span className="error-blur">{errorMap.onBlur}</span>
    )}
    {errorMap.onSubmit && (
      <span className="error-submit">{errorMap.onSubmit}</span>
    )}
  </div>
)
```

**Key Points:**

- `errorMap` keys correspond directly to validator keys: `onChange`, `onBlur`, `onSubmit`, and their async counterparts.
- A key is `undefined` when its validator has not run or last returned `undefined`.
- [Unverified: exact `errorMap` key names for async validators — e.g., whether the key is `onChangeAsync` or merged into `onChange`. Verify against current API docs.]

---

### Display Timing — Gating Error Visibility

The raw presence of an error in `field.state.meta.errors` does not determine whether it should be shown. Display timing is a UI concern controlled by checking field meta flags.

#### Common Gating Patterns

**Gate on `isTouched` — show errors only after first interaction:**

tsx

```tsx
{field.state.meta.isTouched && field.state.meta.errors.length > 0 && (
  <span>{field.state.meta.errors[0]}</span>
)}
```

**Gate on `isBlurred` — show errors only after the user has left the field:**

tsx

```tsx
{field.state.meta.isBlurred && field.state.meta.errors.length > 0 && (
  <span>{field.state.meta.errors[0]}</span>
)}
```

**Gate on form submission — show all errors only after first submit attempt:**

tsx

```tsx
{form.state.isSubmitted && field.state.meta.errors.length > 0 && (
  <span>{field.state.meta.errors[0]}</span>
)}
```

**Key Points:**

- `isTouched` becomes `true` on the first change event.
- `isBlurred` becomes `true` on the first blur event. [Unverified: `isBlurred` as a distinct meta flag — verify availability in your version; some versions may use only `isTouched`.]
- `isSubmitted` at the form level becomes `true` after the first submit attempt, regardless of whether validation passed.
- These flags are not mutually exclusive — they can be combined to express compound display conditions.

---

### Recommended UX Patterns by Form Type

| Form Type | Recommended Trigger Strategy |
| --- | --- |
| Login / short form | `onSubmit` only — minimize interruption |
| Registration / long form | `onBlur` for most fields, `onSubmit` as final gate |
| Real-time constrained input | `onChange` with `isTouched` guard |
| Username / email uniqueness | `onBlurAsync` or `onChangeAsync` with debounce |
| Multi-step wizard | Per-step `onSubmit` validators on step advance |

---

### How Validators Interact Across Triggers

Validators for different triggers run independently. They do not share state or short-circuit each other by default. The error array reflects the union of currently active errors across all triggers.

User typesonChange validator runsUser blurs fieldonBlur validator runsUser submits formonSubmit validator runserrorMap.onChangeupdatederrorMap.onBlur updatederrorMap.onSubmitupdatederrors array = union ofactive errorMap valuesComponent renderscurrent errors

**Key Points:**

- Correcting a value clears the `onChange` error (if the new value passes), but the `onBlur` error persists until the next blur event re-runs its validator and passes.
- This can result in an error persisting after the user has corrected the value, if that error came from `onBlur` and the field has not been blurred again. This is an inherent property of trigger-scoped validation, not a bug.
- Defining the same rule in both `onChange` and `onBlur` avoids this stale-error situation for critical constraints:

tsx

```tsx
validators={{
  onChange: ({ value }) => !value ? 'Required' : undefined,
  onBlur: ({ value }) => !value ? 'Required' : undefined,
}}
```

---

### Wiring `handleBlur` Correctly

`onBlur` and `onBlurAsync` validators only fire if `field.handleBlur` is connected to the input element. This is a required manual step — TanStack Form does not inject it automatically.

tsx

```tsx
// Correct — handleBlur wired
<input
  value={field.state.value}
  onChange={(e) => field.handleChange(e.target.value)}
  onBlur={field.handleBlur}
/>

// Incorrect — onBlur validators will never fire
<input
  value={field.state.value}
  onChange={(e) => field.handleChange(e.target.value)}
/>
```

For custom components that expose an `onBlur` prop under a different name, forward it manually:

tsx

```tsx
<CustomInput
  value={field.state.value}
  onValueChange={field.handleChange}
  onFocusLost={field.handleBlur}
/>
```

---

### `onSubmit` Validation and Form Blocking

When any field's `onSubmit` validator returns an error, TanStack Form blocks the form's `onSubmit` handler from completing. `form.state.canSubmit` reflects this:

tsx

```tsx
<button type="submit" disabled={!form.state.canSubmit}>
  Submit
</button>
```

**Key Points:**

- `canSubmit` accounts for both sync and async validator state.
- If async validators are pending (`form.state.isValidating === true`), `canSubmit` is typically `false`. [Inference: confirm against your version — behavior is not guaranteed.]
- After a failed submit, `isSubmitted` is `true` and all `onSubmit` validator errors are visible, even for untouched fields.

---

### Full Composed Example

tsx

```tsx
function RegistrationField() {
  const form = useForm({
    defaultValues: { password: '' },
    onSubmit: async ({ value }) => {
      await registerUser(value)
    },
  })

  return (
    <form
      onSubmit={(e) => {
        e.preventDefault()
        form.handleSubmit()
      }}
    >
      <form.Field
        name="password"
        validators={{
          onChange: ({ value }) =>
            value.length > 0 && value.length < 8
              ? 'Password too short'
              : undefined,
          onBlur: ({ value }) =>
            value.trim() === '' ? 'Password is required' : undefined,
          onSubmit: ({ value }) =>
            !/[A-Z]/.test(value)
              ? 'Must contain an uppercase letter'
              : undefined,
        }}
        children={(field) => (
          <div>
            <input
              type="password"
              value={field.state.value}
              onChange={(e) => field.handleChange(e.target.value)}
              onBlur={field.handleBlur}
            />
            {field.state.meta.isTouched &&
              field.state.meta.errors.map((err, i) => (
                <span key={i} className="error">{err}</span>
              ))}
          </div>
        )}
      />
      <button type="submit" disabled={!form.state.canSubmit}>
        Register
      </button>
    </form>
  )
}
```

---

### Summary

| Trigger | Fires On | Best For |
| --- | --- | --- |
| `onChange` | Every value change | Format checks, character limits |
| `onBlur` | Field loses focus | Completeness checks after exit |
| `onSubmit` | Form submission | Final gate, untouched field checks |
| All combined | Per respective event | Layered, progressive validation |

| Display Gate | Shows Errors When |
| --- | --- |
| `isTouched` | After first interaction |
| `isBlurred` | After first focus loss |
| `isSubmitted` | After first submit attempt |
| Ungated | Immediately (use sparingly) |

---

**Related Topics:**

- `errorMap` — per-trigger error rendering in complex layouts
- Async validators on blur and submit — debounce and abort patterns
- `canSubmit` and `isValidating` — gating submission on validation state
- Multi-step form validation — scoping submit validators per step
- Custom input components — forwarding `handleBlur` through component boundaries
- Conditional validators — skipping rules based on other field values