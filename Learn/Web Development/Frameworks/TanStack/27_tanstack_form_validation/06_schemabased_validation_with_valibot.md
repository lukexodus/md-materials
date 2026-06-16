## Schema-based Validation with Valibot

TanStack Form supports Valibot as a first-class schema validation alternative to Zod, provided through `@tanstack/valibot-form-adapter`. Valibot differs from Zod architecturally: it is modular and tree-shakeable by design, with each schema and validation method imported as a discrete function rather than chained from a class instance.

---

### Why Valibot

**Key Points**

- Valibot schemas are composed from imported functions, not class methods — unused validators are eliminated by bundlers
- Bundle size is significantly smaller than Zod for partial usage [Inference — dependent on which validators are actually imported; not a guaranteed fixed reduction]
- The API surface maps closely to Zod concepts (strings, objects, refinements) but uses a pipe-based composition model
- The TanStack Form adapter for Valibot follows the same interface contract as the Zod adapter, so migration between the two is largely mechanical

---

### Installation

bash

```bash
npm install valibot @tanstack/valibot-form-adapter
```

**Key Points**

- `valibot` and `@tanstack/valibot-form-adapter` are separate peer dependencies
- Valibot has had breaking API changes across minor versions; confirm adapter compatibility with your installed Valibot version before use [Unverified — check the adapter's `peerDependencies` in `package.json` for the supported range]

---

### Registering the Adapter

Pass `valibotValidator()` from the adapter package to `validatorAdapter` on the form instance.

ts

```ts
import { useForm } from '@tanstack/react-form'
import { valibotValidator } from '@tanstack/valibot-form-adapter'

const form = useForm({
  defaultValues: {
    email: '',
    age: 0,
  },
  validatorAdapter: valibotValidator(),
})
```

Once registered, Valibot schemas can be passed directly to `validators` on fields and the form without wrapping them in a function.

---

### Valibot Schema Basics

Before field integration, it helps to understand Valibot's composition model. Schemas are built by piping a base type through validation actions.

ts

```ts
import * as v from 'valibot'

// Simple string schema
const nameSchema = v.string()

// String with validations via pipe
const emailSchema = v.pipe(
  v.string(),
  v.email('Must be a valid email address')
)

// Number with range
const ageSchema = v.pipe(
  v.number(),
  v.minValue(18, 'Must be at least 18'),
  v.maxValue(120, 'Must be 120 or under')
)

// Object schema
const addressSchema = v.object({
  street: v.pipe(v.string(), v.minLength(1, 'Street is required')),
  city: v.pipe(v.string(), v.minLength(1, 'City is required')),
  zip: v.pipe(v.string(), v.regex(/^\d{5}$/, 'ZIP must be 5 digits')),
})
```

**Key Points**

- `v.pipe()` is the primary composition mechanism; validators are stacked inside it in order
- Each validation action (e.g., `v.email()`, `v.minLength()`) accepts an optional error message string as its last argument
- The base type (`v.string()`, `v.number()`, etc.) must always be the first argument to `v.pipe()`

---

### Field-level Validation

Pass a Valibot schema to `validators.onChange`, `validators.onBlur`, or `validators.onSubmit` on a field.

tsx

```tsx
<form.Field
  name="email"
  validators={{
    onChange: v.pipe(
      v.string(),
      v.email('Must be a valid email address')
    ),
    onBlur: v.pipe(
      v.string(),
      v.minLength(1, 'Email is required')
    ),
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

- `onChange` and `onBlur` can carry independent schemas with different rules
- Errors surface in `field.state.meta.errors` as strings
- The adapter calls Valibot's `safeParseAsync` or `safeParse` internally and extracts issue messages [Inference — based on standard adapter contract; exact extraction behavior may vary by adapter version]

---

### Object-shaped Fields

For fields whose value is an object, use `v.object()` as the schema.

tsx

```tsx
<form.Field
  name="address"
  validators={{
    onChange: v.object({
      street: v.pipe(v.string(), v.minLength(1, 'Required')),
      city: v.pipe(v.string(), v.minLength(1, 'Required')),
      zip: v.pipe(v.string(), v.regex(/^\d{5}$/, 'Invalid ZIP')),
    }),
  }}
  children={(field) => (
    <div>...</div>
  )}
/>
```

**Key Points**

- Valibot validates all object properties and collects issues per key
- The adapter's flattening of nested object issues into `field.state.meta.errors` should be verified at runtime [Unverified — inspect error shape in your specific adapter version]

---

### Form-level Validation and Cross-field Rules

Cross-field validation rules that reference multiple fields are best expressed as a top-level object schema on the form's `validators`.

ts

```ts
import * as v from 'valibot'

const registrationSchema = v.pipe(
  v.object({
    password: v.pipe(v.string(), v.minLength(8, 'At least 8 characters')),
    confirmPassword: v.string(),
  }),
  v.check(
    (data) => data.password === data.confirmPassword,
    'Passwords do not match'
  )
)

const form = useForm({
  defaultValues: {
    password: '',
    confirmPassword: '',
  },
  validatorAdapter: valibotValidator(),
  validators: {
    onSubmit: registrationSchema,
  },
})
```

**Key Points**

- `v.check()` is Valibot's equivalent of Zod's `.refine()` — it accepts a predicate and an error message
- Unlike Zod's `refine`, `v.check()` at the pipe level attaches the error to the root object, not a specific field path [Inference — field-path targeting behavior differs from Zod; verify how errors surface in `field.state.meta.errors` vs form-level errors in your version]
- For field-targeted cross-field errors, a manual validator may offer more control than a top-level schema

---

### Async Validation

Valibot supports async validation through `v.checkAsync()` and async custom validators. TanStack Form surfaces these through the `onChangeAsync`, `onBlurAsync`, and `onSubmitAsync` keys.

tsx

```tsx
<form.Field
  name="username"
  validators={{
    onChangeAsync: v.pipeAsync(
      v.string(),
      v.minLength(3, 'At least 3 characters'),
      v.checkAsync(
        async (val) => {
          const taken = await checkUsernameAvailability(val)
          return !taken
        },
        'Username is already taken'
      )
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

- `v.pipeAsync()` is required when any action in the pipeline is async; `v.pipe()` is synchronous only
- `v.checkAsync()` accepts an async predicate returning a boolean
- `onChangeAsyncDebounceMs` is a TanStack Form field option, not part of the Valibot schema
- `field.state.meta.isValidating` reflects in-flight async state

---

### Reusing Schemas

Valibot schemas are plain values and can be exported and imported like any module.

ts

```ts
// schemas/user.ts
import * as v from 'valibot'

export const emailSchema = v.pipe(
  v.string(),
  v.email('Invalid email address')
)

export const passwordSchema = v.pipe(
  v.string(),
  v.minLength(8, 'At least 8 characters'),
  v.regex(/[A-Z]/, 'Must contain an uppercase letter'),
  v.regex(/[0-9]/, 'Must contain a number')
)

export const registrationSchema = v.pipe(
  v.object({
    email: emailSchema,
    password: passwordSchema,
    confirmPassword: v.string(),
  }),
  v.check(
    (d) => d.password === d.confirmPassword,
    'Passwords do not match'
  )
)
```

tsx

```tsx
import { emailSchema, registrationSchema } from './schemas/user'

// Field-level
<form.Field name="email" validators={{ onChange: emailSchema }} ... />

// Form-level
const form = useForm({
  validators: { onSubmit: registrationSchema },
  validatorAdapter: valibotValidator(),
})
```

---

### TypeScript Integration

Valibot provides `v.InferOutput<typeof schema>` (and `v.InferInput<typeof schema>` for pre-transform types) to extract TypeScript types from schemas.

ts

```ts
import * as v from 'valibot'

const userSchema = v.object({
  email: v.pipe(v.string(), v.email()),
  age: v.pipe(v.number(), v.minValue(0)),
})

type UserValues = v.InferOutput<typeof userSchema>
// { email: string; age: number }

const form = useForm<UserValues>({
  defaultValues: {
    email: '',
    age: 0,
  },
  validatorAdapter: valibotValidator(),
  validators: {
    onSubmit: userSchema,
  },
})
```

**Key Points**

- `v.InferOutput` reflects the type after any transformations; use `v.InferInput` if the form values are pre-transform
- Typing the form with the inferred schema type catches `defaultValues` shape mismatches at compile time

---

### Manual `safeParse` for Full Issue Control

If you need access to all Valibot issues rather than just the first, bypass the adapter and write a manual validator.

ts

```ts
import * as v from 'valibot'

const schema = v.pipe(
  v.string(),
  v.minLength(8, 'Too short'),
  v.regex(/[A-Z]/, 'Needs uppercase'),
  v.regex(/[0-9]/, 'Needs a number')
)

validators={{
  onChange: ({ value }) => {
    const result = v.safeParse(schema, value)
    if (!result.success) {
      return result.issues.map((i) => i.message).join('; ')
    }
    return undefined
  },
}}
```

**Key Points**

- `v.safeParse(schema, value)` returns `{ success: boolean; issues?: BaseIssue[] }`
- Manual validators return `string | undefined`; `undefined` signals valid
- Manual and adapter-based validators can coexist on different fields in the same form

---

### Valibot vs Zod in TanStack Form

| Aspect | Valibot | Zod |
| --- | --- | --- |
| Composition model | `v.pipe(base, ...actions)` | `z.string().method().method()` |
| Async support | `v.pipeAsync()` + `v.checkAsync()` | `.refine(async fn)` |
| Cross-field errors | `v.check()` at pipe root; path targeting limited [Inference] | `.refine()` with `path` option |
| Tree-shaking | Per-function imports; unused validators excluded | Monolithic namespace; less granular |
| Type inference | `v.InferOutput<typeof schema>` | `z.infer<typeof schema>` |
| Adapter package | `@tanstack/valibot-form-adapter` | `@tanstack/zod-form-adapter` |

---

### Common Pitfalls

**Pitfall: Using `v.pipe()` with async actions**

`v.pipe()` is synchronous. Using an async action inside it results in a type error or silent failure. Always use `v.pipeAsync()` when any step in the pipeline is async. [Inference — based on Valibot's type system design; behavior may vary]

**Pitfall: Version mismatches**

Valibot has introduced breaking API changes across minor versions (e.g., the rename of `v.custom()` to `v.check()` in some releases). If adapter errors appear, verify that your Valibot version matches the adapter's `peerDependencies`. [Unverified — check `package.json` of the installed adapter]

**Pitfall: Cross-field error path targeting**

Unlike Zod's `refine({ path: ['field'] })`, Valibot's `v.check()` at the object pipe level attaches errors to the root, not a named field. Errors may not automatically appear in a specific field's `meta.errors`. Inspect and handle form-level errors separately if needed. [Inference — verify actual error routing in your adapter version]

**Pitfall: Forgetting `validatorAdapter`**

As with Zod, omitting `validatorAdapter: valibotValidator()` causes schema objects to be misinterpreted as validator functions, throwing at runtime. [Inference — same failure mode as the Zod adapter]

---

**Related Topics**

- Comparing Valibot and Zod adapters for bundle size impact in production builds
- Writing custom validators that combine `v.safeParse` with manual error aggregation
- Cross-field validation strategies when `v.check()` path targeting is insufficient
- Async validation debouncing and cancellation in TanStack Form
- ArkType adapter as an additional schema validation alternative
- Sharing Valibot schemas between TanStack Form and tRPC/Hono input validators
- Form-level vs field-level validation timing trade-offs