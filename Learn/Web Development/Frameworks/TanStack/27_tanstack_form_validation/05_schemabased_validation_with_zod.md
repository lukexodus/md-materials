## Schema-based Validation with Zod

TanStack Form integrates with Zod through an official adapter, allowing you to define field and form-level validation rules using Zod schemas rather than writing manual validator functions. The adapter bridges Zod's parse/safeParse API with TanStack Form's validation lifecycle.

---

### The Zod Adapter

TanStack Form does not bundle Zod directly. Validation is wired in through `@tanstack/zod-form-adapter`, which provides a `zodValidator` factory function.

**Installation**

bash

```bash
npm install zod @tanstack/zod-form-adapter
```

**Key Points**

- `zod` and `@tanstack/zod-form-adapter` are separate peer dependencies
- The adapter works with both field-level and form-level schemas
- Compatible with Zod v3.x; Zod v4 compatibility should be verified against the adapter's current release notes [Unverified — check npm for latest support status]

---

### Wiring the Validator to the Form

The `zodValidator` function is passed to `useForm` via the `validatorAdapter` option. This registers Zod as the validation engine for the entire form instance.

ts

```ts
import { useForm } from '@tanstack/react-form'
import { zodValidator } from '@tanstack/zod-form-adapter'
import { z } from 'zod'

const form = useForm({
  defaultValues: {
    email: '',
    age: 0,
  },
  validatorAdapter: zodValidator(),
})
```

Once the adapter is registered, you can pass Zod schemas directly to the `validators` option on `useField` or `form.Field` without wrapping them in a function.

---

### Field-level Validation with Zod Schemas

The most common usage is per-field schema validation. You pass a Zod schema to `validators.onChange`, `validators.onBlur`, or `validators.onSubmit`.

tsx

```tsx
<form.Field
  name="email"
  validators={{
    onChange: z.string().email('Must be a valid email address'),
    onBlur: z.string().min(1, 'Email is required'),
  }}
  children={(field) => (
    <div>
      <input
        value={field.state.value}
        onChange={(e) => field.handleChange(e.target.value)}
        onBlur={field.handleBlur}
      />
      {field.state.meta.errors.map((err) => (
        <span key={err}>{err}</span>
      ))}
    </div>
  )}
/>
```

**Key Points**

- Each validator key (`onChange`, `onBlur`, `onSubmit`) accepts an independent Zod schema
- The adapter calls `schema.safeParse(value)` internally; on failure, it extracts and surfaces the first `ZodError` message [Inference — based on standard adapter behavior; exact error mapping behavior may vary]
- Multiple validator keys can be combined on a single field
- Errors appear in `field.state.meta.errors` as strings

---

### Validating Object-shaped Fields

For fields whose value is an object (e.g., an address sub-form), you can use `z.object(...)` as the schema.

tsx

```tsx
<form.Field
  name="address"
  validators={{
    onChange: z.object({
      street: z.string().min(1, 'Street is required'),
      city: z.string().min(1, 'City is required'),
      zip: z.string().regex(/^\d{5}$/, 'ZIP must be 5 digits'),
    }),
  }}
  children={(field) => (
    // nested field rendering
    <div>...</div>
  )}
/>
```

**Key Points**

- Object schemas validate the entire field value as a unit
- Individual property errors from Zod are flattened by the adapter; the exact flattening strategy depends on the adapter version [Unverified — inspect `field.state.meta.errors` at runtime to confirm shape]

---

### Form-level Schema Validation

You can validate the entire form's values against a single top-level Zod schema using `validators` on the form itself. This is useful for cross-field rules that cannot be expressed at the field level.

ts

```ts
const formSchema = z.object({
  password: z.string().min(8, 'Password must be at least 8 characters'),
  confirmPassword: z.string(),
}).refine(
  (data) => data.password === data.confirmPassword,
  {
    message: 'Passwords do not match',
    path: ['confirmPassword'],
  }
)

const form = useForm({
  defaultValues: {
    password: '',
    confirmPassword: '',
  },
  validatorAdapter: zodValidator(),
  validators: {
    onSubmit: formSchema,
  },
})
```

**Key Points**

- The `path` property in `refine` directs the error to a specific field's error state
- Form-level validators fire at the timing specified (`onChange`, `onBlur`, `onSubmit`)
- Cross-field rules like confirmation matching or conditional requirements are better expressed here than duplicated across fields

---

### Async Validation with Zod

Zod's `.refine()` and `.superRefine()` support async predicates. TanStack Form handles async validators through the `onChangeAsync` / `onBlurAsync` / `onSubmitAsync` keys.

tsx

```tsx
<form.Field
  name="username"
  validators={{
    onChangeAsync: z.string().refine(
      async (val) => {
        const taken = await checkUsernameAvailability(val)
        return !taken
      },
      { message: 'Username is already taken' }
    ),
    onChangeAsyncDebounceMs: 400,
  }}
  children={(field) => (
    <div>
      <input
        value={field.state.value}
        onChange={(e) => field.handleChange(e.target.value)}
      />
      {field.state.meta.isValidating && <span>Checking...</span>}
      {field.state.meta.errors.map((err) => (
        <span key={err}>{err}</span>
      ))}
    </div>
  )}
/>
```

**Key Points**

- `onChangeAsyncDebounceMs` is set on the field alongside the async validator, not inside the schema
- `field.state.meta.isValidating` reflects in-flight async validation state
- Async Zod refinements behave like any other async validator from TanStack Form's perspective [Inference — the adapter wraps async schemas uniformly]

---

### Error Message Extraction

The adapter surfaces errors as strings in `field.state.meta.errors`. When a Zod schema fails, the adapter extracts the message from the first `ZodIssue` by default. [Inference — exact extraction logic is adapter-internal; behavior may vary across versions]

For richer error handling (e.g., displaying all Zod issues, not just the first), you can bypass the adapter and write a manual validator that calls `schema.safeParse` directly:

ts

```ts
validators={{
  onChange: ({ value }) => {
    const result = mySchema.safeParse(value)
    if (!result.success) {
      return result.error.issues.map((i) => i.message).join(', ')
    }
    return undefined
  },
}}
```

**Key Points**

- Manual validators return `string | undefined`; returning `undefined` signals valid
- This approach gives full control over Zod's `ZodError` structure
- Manual validators and adapter-based validators can coexist on different fields in the same form

---

### Reusing Schemas Across Fields and Forms

Zod schemas are plain objects and can be defined once and imported wherever needed.

ts

```ts
// schemas/user.ts
import { z } from 'zod'

export const emailSchema = z.string().email('Invalid email')
export const passwordSchema = z.string()
  .min(8, 'At least 8 characters')
  .regex(/[A-Z]/, 'Must contain an uppercase letter')
  .regex(/[0-9]/, 'Must contain a number')

export const registrationSchema = z.object({
  email: emailSchema,
  password: passwordSchema,
  confirmPassword: z.string(),
}).refine(
  (d) => d.password === d.confirmPassword,
  { message: 'Passwords do not match', path: ['confirmPassword'] }
)
```

tsx

```tsx
// In form component
import { emailSchema, passwordSchema, registrationSchema } from './schemas/user'

// Field-level
<form.Field name="email" validators={{ onChange: emailSchema }} ... />

// Form-level
const form = useForm({
  validators: { onSubmit: registrationSchema },
  validatorAdapter: zodValidator(),
  ...
})
```

**Key Points**

- Schema reuse promotes consistency between form validation and API/backend validation if the same schemas are shared
- Colocating schemas in a `schemas/` directory is a common [Inference] organizational pattern

---

### TypeScript Integration

Zod schemas produce inferred types via `z.infer<typeof schema>`. You can use these to type `defaultValues` and ensure the form's value shape matches the schema at compile time.

ts

```ts
const registrationSchema = z.object({
  email: z.string(),
  password: z.string(),
  age: z.number(),
})

type RegistrationValues = z.infer<typeof registrationSchema>

const form = useForm<RegistrationValues>({
  defaultValues: {
    email: '',
    password: '',
    age: 0,
  },
  validatorAdapter: zodValidator(),
  validators: {
    onSubmit: registrationSchema,
  },
})
```

**Key Points**

- Type inference catches mismatches between schema shape and `defaultValues` at compile time
- TanStack Form's generic parameter `TFormData` aligns with `z.infer` output when typed this way

---

### Common Pitfalls

**Pitfall: Forgetting `validatorAdapter`**

Passing a Zod schema to `validators` without registering `validatorAdapter: zodValidator()` causes the schema object to be treated as a function, which will throw at runtime. [Inference — based on how TanStack Form processes validator values; verify in your runtime environment]

**Pitfall: Schema type mismatch**

If a field's value is a number but the schema expects `z.string()`, Zod will fail even if the value looks correct. Ensure the schema type matches the actual runtime value type.

**Pitfall: `onSubmit` vs `onChange` timing**

A schema on `onSubmit` only validates when the form is submitted. Users receive no inline feedback while typing unless `onChange` or `onBlur` validators are also present.

**Pitfall: Error shape assumptions**

Do not assume `field.state.meta.errors` is always a flat array of strings without testing. Some adapter versions or configurations may produce different shapes. [Unverified — inspect at runtime]

---

**Related Topics**

- Custom validator functions (non-schema validation)
- Combining Zod schemas with manual validators on the same field
- `onBlur` vs `onChange` vs `onSubmit` validation timing strategies
- Async validation debouncing and cancellation
- Displaying and styling field errors in React
- Valibot adapter as an alternative schema validation approach
- Sharing Zod schemas between TanStack Form and tRPC input validators
- Form-level `onSubmit` error handling and submission state