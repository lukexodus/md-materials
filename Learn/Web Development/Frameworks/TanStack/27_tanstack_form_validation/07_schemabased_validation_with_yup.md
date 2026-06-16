## Schema-based Validation with Yup

TanStack Form supports Yup through `@tanstack/yup-form-adapter`, an official adapter that bridges Yup's schema validation API with TanStack Form's validation lifecycle. Yup predates both Zod and Valibot and remains widely used, particularly in codebases that already use it alongside Formik or similar libraries.

---

### Why Yup

**Key Points**

- Yup has a long-established ecosystem and is familiar to developers migrating from Formik
- Schemas are built through a fluent chained API similar in style to Zod
- Yup supports async validation natively through `.test()` with async predicates
- Yup's error model (`ValidationError`) is distinct from Zod's and Valibot's and has implications for how errors are extracted by the adapter

---

### Installation

bash

```bash
npm install yup @tanstack/yup-form-adapter
```

**Key Points**

- `yup` and `@tanstack/yup-form-adapter` are separate peer dependencies
- Verify adapter compatibility with your installed Yup version via the adapter's `peerDependencies` field [Unverified — check npm for current support range]

---

### Registering the Adapter

Pass `yupValidator()` from the adapter package to `validatorAdapter` on the form instance.

ts

```ts
import { useForm } from '@tanstack/react-form'
import { yupValidator } from '@tanstack/yup-form-adapter'

const form = useForm({
  defaultValues: {
    email: '',
    age: 0,
  },
  validatorAdapter: yupValidator(),
})
```

Once registered, Yup schemas can be passed directly to `validators` on fields and the form without wrapping them in a function.

---

### Yup Schema Basics

Yup schemas are constructed by calling type methods and chaining validation rules.

ts

```ts
import * as yup from 'yup'

// Simple string schema
const nameSchema = yup.string()

// String with validations
const emailSchema = yup
  .string()
  .email('Must be a valid email address')
  .required('Email is required')

// Number with range
const ageSchema = yup
  .number()
  .min(18, 'Must be at least 18')
  .max(120, 'Must be 120 or under')
  .required('Age is required')

// Object schema
const addressSchema = yup.object({
  street: yup.string().required('Street is required'),
  city: yup.string().required('City is required'),
  zip: yup.string().matches(/^\d{5}$/, 'ZIP must be 5 digits').required(),
})
```

**Key Points**

- Yup's chained API is imperative; all rules attach to a base type call
- `.required()` is a distinct method in Yup — unlike Zod, fields are optional by default unless `.required()` is explicitly chained
- `.nullable()` and `.optional()` have specific and distinct meanings in Yup's type system; confusing them is a common source of type mismatches [Inference — based on documented Yup behavior]

---

### Field-level Validation

Pass a Yup schema to `validators.onChange`, `validators.onBlur`, or `validators.onSubmit` on a field.

tsx

```tsx
<form.Field
  name="email"
  validators={{
    onChange: yup
      .string()
      .email('Must be a valid email address')
      .required('Email is required'),
    onBlur: yup.string().required('Email is required'),
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

- `onChange` and `onBlur` accept independent schemas with independent rule sets
- The adapter calls Yup's `validate` or `validateSync` internally and extracts the `ValidationError.message` [Inference — exact extraction strategy is adapter-internal; behavior may vary by version]
- Errors surface in `field.state.meta.errors` as strings
- Yup throws a `ValidationError` on failure rather than returning a result object as Zod and Valibot do; the adapter handles this difference transparently

---

### Object-shaped Fields

For fields whose value is an object, use `yup.object()` as the schema.

tsx

```tsx
<form.Field
  name="address"
  validators={{
    onChange: yup.object({
      street: yup.string().required('Required'),
      city: yup.string().required('Required'),
      zip: yup
        .string()
        .matches(/^\d{5}$/, 'Invalid ZIP')
        .required('Required'),
    }),
  }}
  children={(field) => (
    <div>...</div>
  )}
/>
```

**Key Points**

- Yup's `abortEarly` option controls whether validation stops at the first error or collects all errors; the adapter's default behavior for this option should be verified at runtime [Unverified — inspect `field.state.meta.errors` shape in your adapter version]
- Nested object issue flattening into `field.state.meta.errors` depends on adapter internals

---

### Form-level Validation and Cross-field Rules

Cross-field validation is expressed using Yup's `.test()` method or `yup.ref()` for field references, applied at the object schema level.

ts

```ts
import * as yup from 'yup'

const registrationSchema = yup.object({
  password: yup
    .string()
    .min(8, 'At least 8 characters')
    .required('Password is required'),
  confirmPassword: yup
    .string()
    .oneOf([yup.ref('password')], 'Passwords do not match')
    .required('Please confirm your password'),
})

const form = useForm({
  defaultValues: {
    password: '',
    confirmPassword: '',
  },
  validatorAdapter: yupValidator(),
  validators: {
    onSubmit: registrationSchema,
  },
})
```

**Key Points**

- `yup.ref('fieldName')` creates a reference to a sibling field's value within the same object schema
- `.oneOf([yup.ref('password')], message)` is Yup's idiomatic cross-field equality check
- This is one area where Yup's API is more ergonomic than Valibot's `v.check()` for field-targeted cross-field errors [Inference — based on API comparison; subjective]
- The `path` of the error is determined by which field the `.oneOf()` is chained on, so it surfaces in `confirmPassword`'s error state

---

### Async Validation with `.test()`

Yup's `.test()` method supports async predicates and is the primary mechanism for async custom validation.

tsx

```tsx
<form.Field
  name="username"
  validators={{
    onChangeAsync: yup
      .string()
      .min(3, 'At least 3 characters')
      .test(
        'username-available',
        'Username is already taken',
        async (value) => {
          if (!value) return true
          const taken = await checkUsernameAvailability(value)
          return !taken
        }
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

- `.test(name, message, predicate)` — the first argument is an internal test name used by Yup for deduplication, not displayed to users
- Returning `true` from the predicate signals valid; `false` triggers the message; throwing a `yup.ValidationError` allows a custom message from within the predicate
- `onChangeAsyncDebounceMs` is a TanStack Form field option, not part of the Yup schema
- If `value` is `undefined` or empty, guard against it explicitly in the predicate to avoid unexpected async calls

---

### Reusing Schemas

Yup schemas are plain objects and can be exported and imported as modules.

ts

```ts
// schemas/user.ts
import * as yup from 'yup'

export const emailSchema = yup
  .string()
  .email('Invalid email address')
  .required('Email is required')

export const passwordSchema = yup
  .string()
  .min(8, 'At least 8 characters')
  .matches(/[A-Z]/, 'Must contain an uppercase letter')
  .matches(/[0-9]/, 'Must contain a number')
  .required('Password is required')

export const registrationSchema = yup.object({
  email: emailSchema,
  password: passwordSchema,
  confirmPassword: yup
    .string()
    .oneOf([yup.ref('password')], 'Passwords do not match')
    .required('Please confirm your password'),
})
```

tsx

```tsx
import { emailSchema, registrationSchema } from './schemas/user'

// Field-level
<form.Field name="email" validators={{ onChange: emailSchema }} ... />

// Form-level
const form = useForm({
  validators: { onSubmit: registrationSchema },
  validatorAdapter: yupValidator(),
})
```

---

### TypeScript Integration

Yup provides `yup.InferType<typeof schema>` to extract a TypeScript type from a schema.

ts

```ts
import * as yup from 'yup'

const userSchema = yup.object({
  email: yup.string().email().required(),
  age: yup.number().min(0).required(),
})

type UserValues = yup.InferType<typeof userSchema>
// { email: string; age: number }

const form = useForm<UserValues>({
  defaultValues: {
    email: '',
    age: 0,
  },
  validatorAdapter: yupValidator(),
  validators: {
    onSubmit: userSchema,
  },
})
```

**Key Points**

- `yup.InferType` reflects the output type after Yup's casting and transforms
- Yup's type inference for optional and nullable fields can produce `string | undefined` or `string | null` depending on how `.optional()` and `.nullable()` are combined — inspect the inferred type and align `defaultValues` accordingly [Inference — Yup's type inference behavior is well-documented but has known edge cases]

---

### Manual `validate` for Full Error Control

If you need all Yup issues rather than just the first, bypass the adapter and call Yup's `validate` directly with `abortEarly: false`.

ts

```ts
import * as yup from 'yup'

const schema = yup
  .string()
  .min(8, 'Too short')
  .matches(/[A-Z]/, 'Needs uppercase')
  .matches(/[0-9]/, 'Needs a number')

validators={{
  onChange: async ({ value }) => {
    try {
      await schema.validate(value, { abortEarly: false })
      return undefined
    } catch (err) {
      if (err instanceof yup.ValidationError) {
        return err.errors.join('; ')
      }
      return 'Validation failed'
    }
  },
}}
```

**Key Points**

- `abortEarly: false` instructs Yup to collect all errors rather than stopping at the first
- `ValidationError.errors` is an array of all error message strings when `abortEarly: false`
- Manual validators return `string | undefined`; `undefined` signals valid
- Unlike Zod and Valibot, Yup's `validate` throws rather than returning a result object — always wrap in try/catch

---

### Yup vs Zod vs Valibot in TanStack Form

| Aspect | Yup | Zod | Valibot |
| --- | --- | --- | --- |
| Composition model | Fluent chain on type instance | Fluent chain on type instance | `pipe(base, ...actions)` |
| Error model | Throws `ValidationError` | Returns `SafeParseReturnType` | Returns `SafeParseResult` |
| Cross-field refs | `yup.ref('field')` built-in | `.refine()` with `path` option | `v.check()` at root [Inference] |
| `abortEarly` control | Explicit option on `validate()` | Collects all issues by default | Collects all issues by default |
| Async support | `.test(name, msg, asyncFn)` | `.refine(asyncFn)` | `v.checkAsync()` |
| Tree-shaking | Limited — mostly monolithic | Limited — mostly monolithic | Per-function; highly tree-shakeable |
| Type inference | `yup.InferType<typeof schema>` | `z.infer<typeof schema>` | `v.InferOutput<typeof schema>` |
| Adapter package | `@tanstack/yup-form-adapter` | `@tanstack/zod-form-adapter` | `@tanstack/valibot-form-adapter` |

---

### Common Pitfalls

**Pitfall: Fields are optional by default**

Unlike Zod where `.string()` requires a non-undefined value, Yup fields are optional unless `.required()` is explicitly chained. Omitting `.required()` silently passes validation for empty fields. [Inference — based on Yup's documented default behavior]

**Pitfall: `abortEarly` defaults to `true`**

Yup stops at the first error by default. Without `abortEarly: false`, users only see one validation message at a time even when multiple rules fail. The adapter may not set this option by default [Unverified — verify adapter behavior and use manual validators if all errors are needed simultaneously]

**Pitfall: Throwing vs returning**

Yup throws `ValidationError` on failure. If writing manual validators, forgetting the try/catch causes unhandled exceptions rather than form error states.

**Pitfall: `.nullable()` vs `.optional()` type confusion**

`.nullable()` allows `null`; `.optional()` allows `undefined`. Combining them produces `string | null | undefined`. The inferred TypeScript type must align with what `defaultValues` provides or TypeScript will surface errors. [Inference — based on Yup's documented behavior; verify with your specific schema]

**Pitfall: Forgetting `validatorAdapter`**

Omitting `validatorAdapter: yupValidator()` causes schema objects to be treated as validator functions, throwing at runtime. [Inference — same failure mode as other adapters]

---

**Related Topics**

- Migrating Formik + Yup validation logic to TanStack Form
- Using `abortEarly: false` to surface multiple simultaneous Yup errors
- `yup.ref()` for advanced cross-field dependency patterns beyond `.oneOf()`
- Combining Yup schema validation with manual `onChange` validators on the same field
- Async `.test()` patterns including context passing via `yup.setLocale()`
- Choosing between Yup, Zod, and Valibot for new TanStack Form projects
- Sharing Yup schemas between TanStack Form and Express/Hapi request validation