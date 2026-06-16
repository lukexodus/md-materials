## Typed Form Values and Validation Schemas

TanStack Form provides a fully type-safe form management system where form values, field types, and validation schemas are all inferred and enforced at the TypeScript level. This means field access, validation logic, and submission handlers all carry accurate types without manual annotation in most cases.

---

### Core Type Inference in TanStack Form

TanStack Form derives its type system from the initial values object passed to `useForm`. The shape of that object becomes the canonical type for the entire form.

```ts
import { useForm } from '@tanstack/react-form'

const form = useForm({
  defaultValues: {
    username: '',
    age: 0,
    isAdmin: false,
  },
})
```

From this point, `form.state.values` is typed as:

```ts
{
  username: string
  age: number
  isAdmin: boolean
}
```

No explicit type parameter is required. [Inference] TypeScript infers the form value type from `defaultValues` via generic constraints in `useForm`.

---

### Explicit Typing with `FormOptions`

For cases where the inferred type is insufficient — such as when values can be `null`, `undefined`, or a union — you can pass a type parameter explicitly.

```ts
type RegistrationForm = {
  email: string
  role: 'admin' | 'editor' | 'viewer'
  bio: string | null
}

const form = useForm<RegistrationForm>({
  defaultValues: {
    email: '',
    role: 'viewer',
    bio: null,
  },
})
```

This constrains all field names and values to the declared type, producing compile errors for mismatched field names or incompatible value assignments.

---

### Field-Level Type Safety

When using `form.Field`, the `name` prop is typed as a keyof the form values type. Providing an invalid field name is a compile-time error.

```tsx
<form.Field name="email">
  {(field) => (
    <input
      value={field.state.value}   // typed as string
      onChange={(e) => field.handleChange(e.target.value)}
    />
  )}
</form.Field>
```

The `field.state.value` type is narrowed to the type of that specific field — `string` for `email`, `number` for `age`, etc.

**Key Points:**
- `name` is `keyof TFormValues` — invalid names fail at compile time
- `field.state.value` is typed per-field, not generically as `unknown`
- `field.handleChange` only accepts values matching the field's type

---

### Nested and Array Field Types

TanStack Form supports dot-notation and bracket-notation paths for nested objects and arrays. These paths are also type-checked.

```ts
type OrderForm = {
  customer: {
    name: string
    address: {
      city: string
    }
  }
  items: Array<{ sku: string; qty: number }>
}

const form = useForm<OrderForm>({ defaultValues: { ... } })
```

```tsx
<form.Field name="customer.address.city">
  {(field) => <input value={field.state.value} />}
  {/* field.state.value: string */}
</form.Field>

<form.Field name="items[0].qty">
  {(field) => <input type="number" value={field.state.value} />}
  {/* field.state.value: number */}
</form.Field>
```

[Inference] Path typing for deeply nested structures is resolved through recursive conditional types in TanStack Form's type utilities. Behavior on very deep or cyclically nested types may vary across TypeScript versions.

---

### Validation Schema Integration

TanStack Form does not ship a built-in schema validator. Instead, it integrates with external libraries via adapters. The primary supported adapters are:

- `@tanstack/zod-form-adapter`
- `@tanstack/valibot-form-adapter`
- `@tanstack/yup-form-adapter`

Each adapter bridges the library's schema type system to TanStack Form's validator interface.

---

### Zod Integration

```bash
npm install zod @tanstack/zod-form-adapter
```

```ts
import { useForm } from '@tanstack/react-form'
import { zodValidator } from '@tanstack/zod-form-adapter'
import { z } from 'zod'

const schema = z.object({
  email: z.string().email('Invalid email'),
  age: z.number().min(18, 'Must be 18 or older'),
})

type FormValues = z.infer<typeof schema>

const form = useForm<FormValues>({
  defaultValues: { email: '', age: 0 },
  validatorAdapter: zodValidator(),
})
```

With `validatorAdapter` set, field-level and form-level validators can reference Zod schemas directly.

**Field-level Zod validation:**

```tsx
<form.Field
  name="email"
  validators={{
    onChange: z.string().email('Invalid email'),
  }}
>
  {(field) => (
    <>
      <input value={field.state.value} onChange={(e) => field.handleChange(e.target.value)} />
      {field.state.meta.errors.map((err) => (
        <span key={err}>{err}</span>
      ))}
    </>
  )}
</form.Field>
```

The Zod schema passed to `validators.onChange` is validated against the current field value on each change. `field.state.meta.errors` contains any resulting error messages.

**Form-level Zod validation:**

```ts
const form = useForm<FormValues>({
  defaultValues: { email: '', age: 0 },
  validatorAdapter: zodValidator(),
  validators: {
    onChange: schema,
  },
})
```

Here the entire schema is run against the full form value on change.

---

### Valibot Integration

```bash
npm install valibot @tanstack/valibot-form-adapter
```

```ts
import { valibotValidator } from '@tanstack/valibot-form-adapter'
import * as v from 'valibot'

const schema = v.object({
  username: v.pipe(v.string(), v.minLength(3, 'Too short')),
  email: v.pipe(v.string(), v.email('Invalid email')),
})

type FormValues = v.InferOutput<typeof schema>

const form = useForm<FormValues>({
  defaultValues: { username: '', email: '' },
  validatorAdapter: valibotValidator(),
  validators: {
    onChange: schema,
  },
})
```

Valibot's `v.InferOutput` extracts the TypeScript type from the schema, making it the single source of truth for both runtime validation and static types.

---

### Yup Integration

```bash
npm install yup @tanstack/yup-form-adapter
```

```ts
import { yupValidator } from '@tanstack/yup-form-adapter'
import * as yup from 'yup'

const schema = yup.object({
  name: yup.string().required('Name is required'),
  age: yup.number().min(0).required(),
})

type FormValues = yup.InferType<typeof schema>

const form = useForm<FormValues>({
  defaultValues: { name: '', age: 0 },
  validatorAdapter: yupValidator(),
  validators: {
    onChange: schema,
  },
})
```

[Inference] Yup's type inference via `yup.InferType` is less precise than Zod or Valibot for complex union or conditional schemas. The runtime validation is unaffected, but the TypeScript types may be overly broad in those cases.

---

### Validator Timing Options

TanStack Form supports multiple validation trigger points, all accessible via the `validators` object on both `useForm` and `form.Field`.

| Key | Trigger |
|---|---|
| `onChange` | Every change event |
| `onBlur` | When field loses focus |
| `onMount` | On initial render |
| `onSubmit` | At form submission |
| `onChangeAsync` | Async version of `onChange` |
| `onBlurAsync` | Async version of `onBlur` |

```tsx
<form.Field
  name="username"
  validators={{
    onChange: z.string().min(3),
    onBlur: z.string().min(3, 'Username must be at least 3 characters'),
    onChangeAsync: async ({ value }) => {
      const taken = await checkUsernameAvailability(value)
      return taken ? 'Username already taken' : undefined
    },
    onChangeAsyncDebounceMs: 500,
  }}
>
  {(field) => <input value={field.state.value} onChange={(e) => field.handleChange(e.target.value)} />}
</form.Field>
```

`onChangeAsync` receives a context object with `value` (the current field value) and optionally `signal` (an `AbortSignal` for cancellation). It returns a `string` error message or `undefined`.

---

### Custom Validator Functions

Schema adapters are optional. Raw validator functions are also supported and are fully typed.

```tsx
<form.Field
  name="age"
  validators={{
    onChange: ({ value }) => {
      // value: number (inferred from field type)
      if (value < 0) return 'Age cannot be negative'
      if (value > 120) return 'Enter a realistic age'
      return undefined
    },
  }}
>
  {(field) => <input type="number" value={field.state.value} />}
</form.Field>
```

The `value` parameter is typed to match the field's value type. Returning `undefined` signals no error; returning a `string` sets the error.

---

### Accessing Typed Values at Submission

The `onSubmit` handler receives a typed `values` object matching the form's value type.

```ts
const form = useForm<FormValues>({
  defaultValues: { email: '', age: 0 },
  onSubmit: async ({ value }) => {
    // value: FormValues — fully typed
    await submitToAPI(value)
  },
})
```

No casting is needed. `value.email` is `string`, `value.age` is `number`, matching the declared type.

---

### Using Schema as Single Source of Truth

A common pattern is to derive both the TypeScript type and the default values from the schema, reducing redundancy.

```ts
import { z } from 'zod'

const profileSchema = z.object({
  displayName: z.string().min(1),
  website: z.string().url().optional(),
  notifications: z.boolean(),
})

type ProfileForm = z.infer<typeof profileSchema>

const defaultValues: ProfileForm = {
  displayName: '',
  website: undefined,
  notifications: true,
}

const form = useForm<ProfileForm>({
  defaultValues,
  validatorAdapter: zodValidator(),
  validators: { onChange: profileSchema },
})
```

**Key Points:**
- The schema is the authoritative definition for shape, constraints, and types
- `defaultValues` is typed against `ProfileForm`, so missing or wrong-typed fields are compile errors
- The same schema is reused for runtime validation, eliminating duplication

---

### Error Type Shape

`field.state.meta.errors` is typed as `string[]` by default. When using schema adapters, error messages are extracted and normalized into this array automatically.

`field.state.meta.errorMap` provides a more granular map:

```ts
{
  onChange?: string
  onBlur?: string
  onSubmit?: string
  onMount?: string
  onServer?: string
}
```

This allows rendering different error messages depending on which validation event produced them.

```tsx
{field.state.meta.errorMap.onBlur && (
  <span>{field.state.meta.errorMap.onBlur}</span>
)}
```

---

### Form-Level vs. Field-Level Validation

Both levels can coexist. Form-level validators run against the entire value object, while field-level validators run against individual field values.

```ts
const form = useForm<FormValues>({
  defaultValues: { password: '', confirmPassword: '' },
  validatorAdapter: zodValidator(),
  validators: {
    onChange: z.object({
      password: z.string().min(8),
      confirmPassword: z.string(),
    }).refine(
      (val) => val.password === val.confirmPassword,
      { message: 'Passwords do not match', path: ['confirmPassword'] }
    ),
  },
})
```

Cross-field validation (like password confirmation) is more naturally expressed at the form level where the full value object is available.

---

### Type Safety Boundaries and Limitations

- [Inference] Path string typing for arrays (`items[0].name`) depends on template literal and recursive conditional types, which may be slow or produce `any` in older TypeScript versions (below 4.7).
- [Inference] Optional fields typed as `T | undefined` from Zod's `.optional()` are accurately reflected in `field.state.value`, but downstream code must handle `undefined` explicitly.
- [Unverified] Behavior of adapters with schema libraries' non-stable or experimental APIs (e.g., Zod v4 betas) has not been confirmed and may differ. Always verify against the adapter's documented compatibility.

---

**Related Topics:**
- Form submission and `onSubmit` handler patterns
- Async validation and debounce strategies
- `useField` for headless field logic
- Field arrays and dynamic form structures
- Integrating TanStack Form with server-side validation errors
- `FormApi` and programmatic form control
- Cross-field dependent validation patterns
- TanStack Form with React Hook Form migration comparison