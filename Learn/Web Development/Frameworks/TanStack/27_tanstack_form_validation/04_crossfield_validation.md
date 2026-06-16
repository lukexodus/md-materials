## TanStack Form — Cross-Field Validation

---

### Overview

Cross-field validation refers to rules that depend on the values of more than one field simultaneously — password confirmation matching, date range ordering, conditional requirements, and similar relational constraints. TanStack Form supports this at both the form level (via form-wide validators) and the field level (via `fieldApi` access to sibling field values). Each approach has distinct tradeoffs in scope, trigger timing, and error placement.

---

### Approach 1 — Form-Level Validators

The most explicit approach for cross-field rules is defining validators on `useForm` directly. The validator receives the entire form values object, making all field values available simultaneously.

ts

```ts
const form = useForm({
  defaultValues: {
    password: '',
    confirmPassword: '',
  },
  validators: {
    onChange: ({ value }) => {
      if (value.password && value.confirmPassword) {
        if (value.password !== value.confirmPassword) {
          return 'Passwords do not match'
        }
      }
      return undefined
    },
  },
})
```

**Key Points:**

- `value` here is the full form values object — `value.fieldName` accesses any field.
- Form-level validator errors are stored in `form.state.errors`, not in any individual field's `meta.errors`.
- All three trigger variants are available: `onChange`, `onBlur`, `onSubmit`, and their async counterparts.
- Form-level `onChange` fires whenever any field changes — not scoped to a specific field. This means the cross-field rule re-evaluates on every keystroke across the entire form.

#### Displaying Form-Level Errors

Form-level errors must be rendered separately from field-level errors — they are not automatically associated with any field:

tsx

```tsx
{form.state.errors.length > 0 && (
  <div className="form-error-banner">
    {form.state.errors.map((err, i) => (
      <p key={i}>{err}</p>
    ))}
  </div>
)}
```

Or positioned near the relevant fields:

tsx

```tsx
// Rendered between the two password fields
{form.state.errors.includes('Passwords do not match') && (
  <span className="error">Passwords do not match</span>
)}
```

**Key Points:**

- `form.state.errors` is an array — multiple form-level validators can contribute errors simultaneously.
- [Unverified: `form.state.errorMap` with per-trigger keys at the form level — verify availability and exact shape against your version's API docs.]

---

### Approach 2 — Field-Level Validators with `fieldApi`

Cross-field rules can also live inside a field's own validator by accessing sibling field values through `fieldApi`. The validator for `confirmPassword` can read the current value of `password` directly:

tsx

```tsx
<form.Field
  name="confirmPassword"
  validators={{
    onChange: ({ value, fieldApi }) => {
      const password = fieldApi.form.getFieldValue('password')
      if (value !== password) return 'Passwords do not match'
      return undefined
    },
  }}
  children={(field) => (
    <div>
      <input
        type="password"
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

- `fieldApi.form` exposes the form instance from within a field validator.
- `fieldApi.form.getFieldValue(name)` retrieves the current value of another field by name. [Unverified: exact method name — `getFieldValue` vs. `getFieldState` or similar — verify against current API docs. Behavior is not guaranteed across versions.]
- The error is stored in `confirmPassword`'s own `meta.errors`, allowing it to render inline beneath that field — closer to the relevant UI element than a form-level error.
- This validator only re-runs when `confirmPassword` changes — not when `password` changes. This is a key limitation (addressed below).

---

### The Re-validation Problem

The fundamental challenge with cross-field validation at the field level is trigger asymmetry. If the rule lives on `confirmPassword`, it re-runs when `confirmPassword` changes — but not when `password` changes. The user may correct `password` after filling `confirmPassword`, leaving a stale error on `confirmPassword`.

ConfirmFieldPasswordFieldUserConfirmFieldPasswordFieldUservalidator does NOT re-run — error persiststypes "abc123"types "abc124" → validator runs → error showncorrects to "abc124"must re-touch to clear stale error

#### Solution — `onChangeListenTo`

TanStack Form provides `onChangeListenTo` (and `onBlurListenTo`) to subscribe a field's validator to changes in other fields. When a listed field changes, the subscribing field's validator re-runs automatically:

tsx

```tsx
<form.Field
  name="confirmPassword"
  validators={{
    onChange: ({ value, fieldApi }) => {
      const password = fieldApi.form.getFieldValue('password')
      return value !== password ? 'Passwords do not match' : undefined
    },
  }}
  onChangeListenTo={['password']}
  children={(field) => (
    <div>
      <input
        type="password"
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

- `onChangeListenTo` accepts an array of field names. When any listed field changes, the subscribing field's `onChange` validator re-runs.
- `onBlurListenTo` exists for the same purpose scoped to blur events. [Unverified: confirm both props exist in your installed version — verify against changelog.]
- This resolves the stale-error problem: correcting `password` will immediately re-trigger validation on `confirmPassword`.
- [Inference] The re-run uses the subscribing field's current value — it does not simulate a user event on that field. Touched/blur state of the subscribing field is not altered by a listen-triggered re-run.

---

### Cross-Field Validation Flow with `onChangeListenTo`

YesNoNoYesUser changes 'password'password onChange firesAny field listens to'password'?confirmPasswordonChange validatorre-runsNo further propagationconfirmPasswordmatches password?Error in confirmPasswordmeta.errorsError clearedconfirmPasswordre-renders

---

### Approach 3 — `onSubmit` as the Cross-Field Gate

For cases where immediate feedback is not required, placing cross-field rules exclusively in `onSubmit` validators (at field or form level) avoids the re-validation complexity entirely. The rule runs once on submission, covering all fields in their final state.

ts

```ts
const form = useForm({
  defaultValues: {
    startDate: '',
    endDate: '',
  },
  validators: {
    onSubmit: ({ value }) => {
      if (new Date(value.endDate) <= new Date(value.startDate)) {
        return 'End date must be after start date'
      }
      return undefined
    },
  },
})
```

**Key Points:**

- Appropriate for constraints that are only meaningful at the point of submission — date ranges, mutually exclusive selections, dependent required fields.
- Eliminates stale-error concerns entirely since the validator only runs once.
- The tradeoff is that the user receives no feedback until they attempt to submit.

---

### Conditional Requirements — One Field Requiring Another

A common cross-field pattern is conditional requirement: field B is required only if field A has a certain value.

tsx

```tsx
<form.Field
  name="otherReason"
  validators={{
    onChange: ({ value, fieldApi }) => {
      const reason = fieldApi.form.getFieldValue('reason')
      if (reason === 'other' && !value.trim()) {
        return 'Please specify your reason'
      }
      return undefined
    },
  }}
  onChangeListenTo={['reason']}
  children={(field) => (
    <div>
      <textarea
        value={field.state.value}
        onChange={(e) => field.handleChange(e.target.value)}
        onBlur={field.handleBlur}
        disabled={field.form.getFieldValue('reason') !== 'other'}
      />
      {field.state.meta.errors.length > 0 && (
        <span>{field.state.meta.errors[0]}</span>
      )}
    </div>
  )}
/>
```

**Key Points:**

- `onChangeListenTo={['reason']}` causes `otherReason`'s validator to re-run when `reason` changes — the disabled state and the validation rule stay synchronized.
- [Unverified: accessing `field.form.getFieldValue` directly in JSX (outside the validator) — confirm this is supported vs. using a stored form reference. Behavior may vary.]

---

### Choosing Between Form-Level and Field-Level Cross-Field Validation

| Concern | Form-Level | Field-Level + `onChangeListenTo` |
| --- | --- | --- |
| Error placement | `form.state.errors` — rendered separately | Field's own `meta.errors` — inline |
| Trigger scope | Fires when any field changes | Fires on own change + listened fields |
| Stale error risk | None — always sees full current state | Managed by `onChangeListenTo` |
| Setup complexity | Lower | Higher — requires listen wiring |
| Best for | Global constraints, submit gates | Inline UX near the dependent field |

---

### Schema-Based Cross-Field Validation

When using a validator adapter (e.g., Zod), cross-field rules are expressed at the schema level using `.superRefine` or `.refine` on the object schema, then passed as a form-level validator:

ts

```ts
import { zodValidator } from '@tanstack/zod-form-adapter'
import { z } from 'zod'

const schema = z.object({
  password: z.string().min(8),
  confirmPassword: z.string(),
}).superRefine((data, ctx) => {
  if (data.password !== data.confirmPassword) {
    ctx.addIssue({
      code: z.ZodIssueCode.custom,
      message: 'Passwords do not match',
      path: ['confirmPassword'],
    })
  }
})

const form = useForm({
  validatorAdapter: zodValidator(),
  validators: {
    onChange: schema,
  },
})
```

**Key Points:**

- `path` in `ctx.addIssue` determines which field the error is attributed to. When the adapter maps Zod issues to TanStack Form errors, this path [Inference] routes the error to the appropriate field's `meta.errors` rather than the form-level `errors` array. Verify this routing behavior against your adapter version — it is not guaranteed.
- `superRefine` supports multiple `addIssue` calls, allowing multiple cross-field errors from a single schema evaluation.
- [Unverified: whether path-routed Zod errors appear in field-level `meta.errors` or remain in `form.state.errors` — this depends on the adapter implementation. Confirm with the `@tanstack/zod-form-adapter` source or docs.]

---

### Summary

| Approach | Error Location | Stale Error Risk | Re-validation |
| --- | --- | --- | --- |
| `useForm` validators | `form.state.errors` | None | On every form change |
| Field validator + `fieldApi` | Field `meta.errors` | Yes, without listen | Manual re-touch |
| Field validator + `onChangeListenTo` | Field `meta.errors` | Mitigated | Automatic on listened field change |
| `onSubmit` only | Form or field errors | None | On submit |
| Zod `superRefine` via adapter | Field or form errors (version-dependent) | None at schema level | Per adapter trigger |

---

**Related Topics:**

- `onChangeListenTo` and `onBlurListenTo` — full API reference
- Zod `superRefine` and `refine` — schema-level cross-field rules
- Conditional field rendering — showing/hiding fields based on other values
- Array field cross-item validation — validating relationships between array entries
- Form-level `errorMap` — per-trigger form errors
- Dependent field patterns in multi-step wizards