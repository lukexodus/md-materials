## Input Validation with Yup and Valibot

### Overview

tRPC is not coupled exclusively to Zod. Any validator that conforms to the **Standard Schema** specification is supported, as well as validators that expose a compatible parse interface. Yup and Valibot are two alternatives — Yup is a long-established validation library with a fluent API familiar to teams coming from Formik-based projects, while Valibot is a modern, modular validator designed for minimal bundle size.

The integration mechanism differs between the two: Yup requires a thin wrapper because it does not natively implement Standard Schema, while Valibot implements Standard Schema directly and works with tRPC without any adapter.

---

### Standard Schema — Brief Context

Standard Schema is a shared interface specification that validation libraries can implement, allowing frameworks like tRPC to accept any conforming validator without library-specific adapter code. A validator conforming to Standard Schema exposes a `~standard` property with `version`, `vendor`, `validate`, and `types` fields.

**Key Points**
- Zod (v3.24+), Valibot (v0.31+), and ArkType implement Standard Schema. [Inference] Confirm the minimum version for your installed library.
- Yup does not implement Standard Schema as of this writing. [Unverified — verify against current Yup release notes.] A wrapper is required.
- tRPC's support for Standard Schema validators was introduced in tRPC v11. [Inference] For tRPC v10, custom wrappers are required for all non-Zod validators.

---

### Valibot

#### Installation

```bash
npm install valibot
```

No adapter or wrapper is needed. Valibot schemas are passed directly to `.input()`.

#### Basic Usage

```ts
import * as v from 'valibot';
import { router, publicProcedure } from '../trpc';

export const userRouter = router({
  create: publicProcedure
    .input(v.object({
      name: v.pipe(v.string(), v.minLength(1)),
      email: v.pipe(v.string(), v.email()),
      age: v.pipe(v.number(), v.integer(), v.minValue(0)),
    }))
    .mutation(({ input }) => {
      // input: { name: string; email: string; age: number }
      return input;
    }),
});
```

**Key Points**
- Valibot v0.31+ uses a pipe-based API. Refinements are composed via `v.pipe()` rather than chained methods. This is a significant API change from earlier Valibot versions — verify your installed version before using this syntax.
- `v.object()`, `v.string()`, `v.number()`, etc. are imported from `valibot` as named exports.
- TypeScript types are inferred from Valibot schemas exactly as they are from Zod schemas.

#### Common Schema Types

```ts
// String
v.string()
v.pipe(v.string(), v.minLength(1))
v.pipe(v.string(), v.minLength(3), v.maxLength(100))
v.pipe(v.string(), v.email())
v.pipe(v.string(), v.url())
v.pipe(v.string(), v.uuid())
v.pipe(v.string(), v.regex(/^[a-z]+$/))

// Number
v.number()
v.pipe(v.number(), v.integer())
v.pipe(v.number(), v.minValue(0))
v.pipe(v.number(), v.maxValue(100))

// Boolean
v.boolean()

// Enum (literal union)
v.picklist(['admin', 'editor', 'viewer'])
// type: 'admin' | 'editor' | 'viewer'

// Array
v.array(v.string())
v.pipe(v.array(v.string()), v.minLength(1))

// Optional and nullable
v.optional(v.string())              // string | undefined
v.nullable(v.string())              // string | null
v.nullish(v.string())               // string | null | undefined
```

#### Optional Fields and Defaults

```ts
v.object({
  name: v.string(),
  bio: v.optional(v.string()),
  page: v.optional(v.pipe(v.number(), v.integer()), 1),
  // page defaults to 1 when absent
})
```

**Key Points**
- Valibot's `v.optional(schema, default)` accepts a default as the second argument directly — no separate `.default()` chain needed.
- The TypeScript type of a field with a default is still the base type (e.g., `number`), not `number | undefined`, because the default fills the gap.

#### Nested Objects

```ts
const AddressSchema = v.object({
  street: v.string(),
  city: v.string(),
  country: v.pipe(v.string(), v.length(2)),
});

const CreateOrderSchema = v.object({
  customerId: v.pipe(v.string(), v.uuid()),
  shippingAddress: AddressSchema,
  billingAddress: v.optional(AddressSchema),
  items: v.pipe(
    v.array(v.object({
      productId: v.pipe(v.string(), v.uuid()),
      quantity: v.pipe(v.number(), v.integer(), v.minValue(1)),
    })),
    v.minLength(1),
  ),
});

createOrder: publicProcedure
  .input(CreateOrderSchema)
  .mutation(({ input }) => {
    return input;
  }),
```

#### Extracting Types

```ts
import * as v from 'valibot';

const CreateUserSchema = v.object({
  name: v.pipe(v.string(), v.minLength(1)),
  email: v.pipe(v.string(), v.email()),
});

type CreateUserInput = v.InferInput<typeof CreateUserSchema>;
// { name: string; email: string }
```

**Key Points**
- `v.InferInput` extracts the input type (before transforms). `v.InferOutput` extracts the output type (after transforms). For schemas without transforms, these are identical.

#### Custom Validation

```ts
v.pipe(
  v.object({
    password: v.pipe(v.string(), v.minLength(8)),
    confirmPassword: v.string(),
  }),
  v.check(
    (data) => data.password === data.confirmPassword,
    'Passwords do not match',
  ),
)
```

#### Bundle Size Advantage

Valibot's modular design means only the validators you import are included in the bundle. This is relevant for client-side schema sharing.

**Example** — approximate bundle size comparison for a simple object schema: [Unverified — exact sizes vary by version, bundler, and tree-shaking configuration]

| Library | Approach | Bundle impact |
|---|---|---|
| Zod | Monolithic | Entire library included |
| Valibot | Modular, tree-shakeable | Only imported validators included |

[Inference] The size advantage is most meaningful in browser environments where bundle size directly affects load time. On the server, bundle size is typically not a constraint.

---

### Yup

#### Installation

```bash
npm install yup
```

Because Yup does not implement Standard Schema, a wrapper is required to adapt it to the interface tRPC expects.

#### The Wrapper

tRPC expects a schema object to expose a `~standard` property or a compatible `_input` / `_output` with a `parse` or `parseAsync` method. A minimal wrapper for Yup:

```ts
// lib/yupAdapter.ts
import type { ObjectSchema, AnyObject, InferType } from 'yup';

export function yupInput<T extends AnyObject>(schema: ObjectSchema<T>) {
  return {
    _type: undefined as unknown as InferType<typeof schema>,
    async _parse(input: unknown) {
      try {
        const result = await schema.validate(input, { abortEarly: false, stripUnknown: true });
        return { success: true as const, data: result };
      } catch (err: any) {
        return { success: false as const, error: err };
      }
    },
  };
}
```

**Key Points**
- This wrapper is not an official tRPC adapter. It is a minimal compatibility shim. [Unverified — community wrappers vary in completeness; verify behavior against your tRPC and Yup versions.]
- `abortEarly: false` collects all validation errors instead of stopping at the first. This produces more useful error messages.
- `stripUnknown: true` removes fields not defined in the schema, similar to Zod's default strip behavior.

#### Using the Wrapper with tRPC

Depending on the tRPC version, the approach for custom validators may differ. An alternative approach that works with tRPC's custom parser interface:

```ts
// Directly conforming to tRPC's custom validator shape
import * as yup from 'yup';

function yupSchema<T>(schema: yup.Schema<T>) {
  return {
    parseAsync: async (input: unknown): Promise<T> => {
      return schema.validate(input, { abortEarly: false, stripUnknown: true });
    },
    _input: undefined as unknown as T,
    _output: undefined as unknown as T,
  };
}
```

```ts
import * as yup from 'yup';
import { router, publicProcedure } from '../trpc';

const CreateUserSchema = yup.object({
  name: yup.string().required().min(1),
  email: yup.string().email().required(),
  age: yup.number().integer().min(0).required(),
});

export const userRouter = router({
  create: publicProcedure
    .input(yupSchema(CreateUserSchema))
    .mutation(({ input }) => {
      return input;
    }),
});
```

**Key Points**
- [Inference] tRPC calls `parseAsync` on the schema object when processing input. The exact interface tRPC expects for custom validators has changed across versions — consult the tRPC source or documentation for your version to confirm the required shape.
- Yup's `.validate()` throws a `ValidationError` on failure. The wrapper must catch this and convert it to a format tRPC can process, or allow tRPC's error handling to catch the thrown error.
- Type inference from Yup schemas into `input` is less precise than Zod or Valibot without explicit generic annotation. [Inference]

#### Common Yup Schema Types

```ts
import * as yup from 'yup';

// String
yup.string()
yup.string().required()
yup.string().min(3).max(100)
yup.string().email()
yup.string().url()
yup.string().uuid()
yup.string().matches(/^[a-z]+$/)
yup.string().trim()
yup.string().lowercase()

// Number
yup.number()
yup.number().required()
yup.number().integer()
yup.number().min(0)
yup.number().max(100)
yup.number().positive()

// Boolean
yup.boolean()

// Date
yup.date()

// Array
yup.array().of(yup.string())
yup.array().of(yup.string()).min(1)

// Object
yup.object({ name: yup.string().required() })

// Optional and nullable
yup.string().optional()           // field may be absent
yup.string().nullable()           // field may be null
yup.string().nullable().optional() // field may be null or absent
```

#### Nested Objects

```ts
const AddressSchema = yup.object({
  street: yup.string().required(),
  city: yup.string().required(),
  country: yup.string().length(2).required(),
});

const CreateOrderSchema = yup.object({
  customerId: yup.string().uuid().required(),
  shippingAddress: AddressSchema.required(),
  billingAddress: AddressSchema.optional(),
  items: yup.array().of(
    yup.object({
      productId: yup.string().uuid().required(),
      quantity: yup.number().integer().min(1).required(),
    })
  ).min(1).required(),
});
```

#### Extracting Types

```ts
import * as yup from 'yup';

const CreateUserSchema = yup.object({
  name: yup.string().required(),
  email: yup.string().email().required(),
});

type CreateUserInput = yup.InferType<typeof CreateUserSchema>;
// { name: string; email: string }
```

#### Cross-Field Validation

```ts
const PasswordSchema = yup.object({
  password: yup.string().min(8).required(),
  confirmPassword: yup.string()
    .oneOf([yup.ref('password')], 'Passwords do not match')
    .required(),
});
```

**Key Points**
- `yup.ref('password')` creates a reference to the `password` field in the same object. This enables cross-field comparisons without custom functions.
- `.oneOf([yup.ref('password')])` validates that `confirmPassword` equals whatever `password` resolved to.

---

### Side-by-Side Comparison

| Feature | Zod | Valibot | Yup |
|---|---|---|---|
| Standard Schema | Yes (v3.24+) | Yes (v0.31+) | No |
| tRPC integration | Native | Native | Requires wrapper |
| API style | Chained methods | Pipe composition | Chained methods |
| Bundle size | Monolithic | Tree-shakeable | Monolithic |
| Type inference | Excellent | Excellent | Good |
| Async validation | Yes | Yes | Yes |
| Cross-field validation | `.refine()` | `v.check()` in pipe | `yup.ref()` |
| Transform support | `.transform()` | `v.transform()` in pipe | `.transform()` |
| Community prevalence in tRPC projects | Very high | Growing | Low |

---

### Choosing Between Validators

**Choose Zod** when starting a new tRPC project or working with a team already familiar with it. The ecosystem of tRPC examples, documentation, and community resources overwhelmingly uses Zod.

**Choose Valibot** when bundle size is a constraint — particularly for shared schemas used in browser environments — and you are on tRPC v11+.

**Choose Yup** when migrating an existing codebase that already uses Yup extensively, or when the team has strong existing familiarity with it and the overhead of a wrapper is acceptable.

[Inference] Mixing validators across procedures in the same router is technically possible but increases complexity without clear benefit. Standardizing on one validator per project is advisable.