## Input Validation with Zod

### Overview

tRPC uses Zod as its primary input validation library. Zod schemas passed to `.input()` serve two purposes simultaneously: they validate the incoming data at runtime and infer the TypeScript type of the `input` argument in the resolver — no separate type declaration is needed. Validation runs before the resolver executes; if validation fails, the resolver is never called and tRPC returns a `BAD_REQUEST` error to the client.

tRPC is not exclusively coupled to Zod — it supports any validator that conforms to its validator interface — but Zod is the most widely used and best-supported option.

---

### How Zod Integrates with tRPC

```
Client sends input
       │
       ▼
tRPC receives raw input (unknown)
       │
       ▼
Zod schema parses and validates
       │
       ├── Failure → BAD_REQUEST error returned to client
       │             Resolver does not run
       │
       └── Success → Typed, validated input passed to resolver
                     Resolver executes
```

**Key Points**
- The `input` argument in the resolver is fully typed based on the Zod schema. TypeScript knows its shape without any additional annotation.
- Zod's `.parse()` throws on invalid input. tRPC catches this and converts it to a structured `TRPCError` with code `BAD_REQUEST`.
- Zod also transforms and coerces values during parsing. The `input` received in the resolver reflects the parsed output, not the raw input — defaults are applied, transforms are run.

---

### Basic Schema Types

#### String

```ts
import { z } from 'zod';

getBySlug: publicProcedure
  .input(z.string())
  .query(({ input }) => {
    // input: string
    return { slug: input };
  }),
```

#### Number

```ts
getPage: publicProcedure
  .input(z.number().int().min(1))
  .query(({ input }) => {
    // input: number
    return { page: input };
  }),
```

#### Boolean

```ts
setActive: publicProcedure
  .input(z.boolean())
  .mutation(({ input }) => {
    // input: boolean
    return { active: input };
  }),
```

#### Object

```ts
createUser: publicProcedure
  .input(z.object({
    name: z.string(),
    email: z.string().email(),
    age: z.number().int().min(0),
  }))
  .mutation(({ input }) => {
    // input: { name: string; email: string; age: number }
    return input;
  }),
```

---

### String Refinements

```ts
z.string()                        // any string
z.string().min(1)                 // non-empty
z.string().min(3).max(100)        // length range
z.string().email()                // email format
z.string().url()                  // URL format
z.string().uuid()                 // UUID format
z.string().regex(/^[a-z]+$/)      // custom pattern
z.string().trim()                 // trims whitespace before validation
z.string().toLowerCase()          // transforms to lowercase
z.string().startsWith('prefix_')
z.string().endsWith('.ts')
```

#### Number Refinements

```ts
z.number()                        // any number
z.number().int()                  // integer only
z.number().min(0)                 // lower bound
z.number().max(100)               // upper bound
z.number().positive()             // > 0
z.number().nonnegative()          // >= 0
z.number().multipleOf(5)          // divisible by 5
z.number().finite()               // excludes Infinity
```

---

### Optional, Nullable, and Default

#### Optional fields

```ts
z.object({
  name: z.string(),
  bio: z.string().optional(),     // bio?: string
})
```

`optional()` means the field may be absent. When absent, `input.bio` is `undefined`.

#### Nullable fields

```ts
z.object({
  name: z.string(),
  deletedAt: z.date().nullable(),  // deletedAt: Date | null
})
```

`nullable()` means the field must be present but may be `null`. This is distinct from `optional()`.

#### Optional and nullable

```ts
z.string().optional().nullable()  // string | null | undefined
z.string().nullish()              // equivalent shorthand
```

#### Default values

```ts
z.object({
  page: z.number().int().min(1).default(1),
  limit: z.number().int().min(1).max(100).default(20),
  sortOrder: z.enum(['asc', 'desc']).default('desc'),
})
```

**Key Points**
- `.default()` applies when the field is absent from the input. After parsing, `input.page` is always a `number` — never `undefined`.
- Defaults are applied by Zod during `.parse()`. The resolver receives the defaulted value directly.
- A field with `.default()` becomes optional in the TypeScript input type — the client is not required to send it.

---

### Enums

#### Zod enum (string literal union)

```ts
z.enum(['admin', 'editor', 'viewer'])
// type: 'admin' | 'editor' | 'viewer'
```

#### Native TypeScript enum

```ts
enum Role {
  Admin = 'admin',
  Editor = 'editor',
  Viewer = 'viewer',
}

z.nativeEnum(Role)
// type: Role
```

**Key Points**
- `z.enum()` is preferred over `z.nativeEnum()` in most cases — it avoids the runtime overhead of TypeScript enums and produces a cleaner inferred type.
- The array passed to `z.enum()` must be a const tuple or literal array. Use `as const` if defining the values separately:

```ts
const ROLES = ['admin', 'editor', 'viewer'] as const;
z.enum(ROLES);
```

---

### Arrays and Tuples

#### Array

```ts
z.array(z.string())               // string[]
z.array(z.string()).min(1)        // at least one element
z.array(z.string()).max(10)       // at most ten elements
z.array(z.string()).length(3)     // exactly three elements
z.array(z.string()).nonempty()    // at least one element (alias for .min(1))
```

#### Tuple

```ts
z.tuple([z.string(), z.number(), z.boolean()])
// type: [string, number, boolean]
```

---

### Union and Discriminated Union

#### Union

```ts
z.union([z.string(), z.number()])
// type: string | number
```

#### Discriminated union

Preferred over `z.union` when objects share a common discriminant field:

```ts
z.discriminatedUnion('type', [
  z.object({ type: z.literal('email'), email: z.string().email() }),
  z.object({ type: z.literal('phone'), phone: z.string() }),
])
// type: { type: 'email'; email: string } | { type: 'phone'; phone: string }
```

**Key Points**
- Discriminated unions are more performant than plain unions for object schemas because Zod checks the discriminant field first and only attempts to parse the matching branch. [Inference]
- Both `z.union` and `z.discriminatedUnion` produce a union TypeScript type. The difference is in runtime validation strategy.

---

### Nested Objects

```ts
const AddressSchema = z.object({
  street: z.string(),
  city: z.string(),
  country: z.string().length(2), // ISO 3166-1 alpha-2
  postalCode: z.string(),
});

const CreateOrderSchema = z.object({
  customerId: z.string().uuid(),
  shippingAddress: AddressSchema,
  billingAddress: AddressSchema.optional(),
  items: z.array(
    z.object({
      productId: z.string().uuid(),
      quantity: z.number().int().min(1),
    })
  ).nonempty(),
});

createOrder: publicProcedure
  .input(CreateOrderSchema)
  .mutation(({ input }) => {
    // input is fully typed including nested objects
    return input;
  }),
```

**Key Points**
- Schemas defined outside `.input()` can be reused across multiple procedures and on the client for form validation.
- Extracting schemas into separate files (`schemas/order.schema.ts`) and sharing them across client and server is a common pattern in tRPC projects.

---

### Transformations

Zod can transform values during parsing. The `input` in the resolver receives the transformed value.

```ts
getByDate: publicProcedure
  .input(z.object({
    date: z.string().transform((val) => new Date(val)),
    // input.date: Date (not string)
  }))
  .query(({ input }) => {
    return { date: input.date.toISOString() };
  }),
```

#### Combining validation and transformation with `.refine` + `.transform`

```ts
z.string()
  .trim()
  .toLowerCase()
  .transform((val) => val.replace(/\s+/g, '-'))  // slugify
```

**Key Points**
- `.transform()` changes the output type. The TypeScript type of `input` reflects the transformed type, not the raw input type.
- Transforms run after validation. If validation fails, the transform is not applied.
- Client-side Zod schemas used for form validation may not include transforms that are only meaningful server-side. [Inference] Sharing a schema with server-side transforms to the client can cause confusion — consider splitting schemas at the transform boundary.

---

### Custom Validation with `.refine`

`.refine()` adds custom validation logic beyond what built-in Zod methods provide.

```ts
const PasswordSchema = z.object({
  password: z.string().min(8),
  confirmPassword: z.string(),
}).refine(
  (data) => data.password === data.confirmPassword,
  {
    message: 'Passwords do not match',
    path: ['confirmPassword'],  // attach error to this field
  }
);

register: publicProcedure
  .input(PasswordSchema)
  .mutation(({ input }) => {
    return { registered: true };
  }),
```

#### `.superRefine` for multiple errors

```ts
const Schema = z.object({
  username: z.string(),
  age: z.number(),
}).superRefine((data, ctx) => {
  if (data.username.length < 3) {
    ctx.addIssue({
      code: z.ZodIssueCode.too_small,
      minimum: 3,
      type: 'string',
      inclusive: true,
      message: 'Username must be at least 3 characters',
      path: ['username'],
    });
  }
  if (data.age < 18) {
    ctx.addIssue({
      code: z.ZodIssueCode.custom,
      message: 'Must be 18 or older',
      path: ['age'],
    });
  }
});
```

**Key Points**
- `.refine()` can only add one error. `.superRefine()` allows multiple issues to be added in a single pass.
- The `path` array in the issue locates the error to a specific field, which is useful for surfacing field-level errors in form UIs.
- `.refine()` on an object runs after all field-level validation passes. If any field fails, the refine is not executed. [Inference]

---

### Reusing Schemas Across Client and Server

A key advantage of Zod in tRPC projects is that the same schema can validate both server input and client-side form input.

```ts
// shared/schemas/user.schema.ts
import { z } from 'zod';

export const CreateUserSchema = z.object({
  name: z.string().min(1, 'Name is required'),
  email: z.string().email('Invalid email address'),
  age: z.number().int().min(18, 'Must be 18 or older'),
});

export type CreateUserInput = z.infer<typeof CreateUserSchema>;
```

**Server:**

```ts
import { CreateUserSchema } from '../../shared/schemas/user.schema';

createUser: publicProcedure
  .input(CreateUserSchema)
  .mutation(({ input }) => {
    return input;
  }),
```

**Client (with React Hook Form):**

```tsx
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { CreateUserSchema, type CreateUserInput } from '../../shared/schemas/user.schema';

function CreateUserForm() {
  const { register, handleSubmit, formState: { errors } } =
    useForm<CreateUserInput>({
      resolver: zodResolver(CreateUserSchema),
    });

  const createUser = trpc.user.create.useMutation();

  return (
    <form onSubmit={handleSubmit((data) => createUser.mutate(data))}>
      <input {...register('name')} />
      {errors.name && <p>{errors.name.message}</p>}

      <input {...register('email')} />
      {errors.email && <p>{errors.email.message}</p>}

      <button type="submit">Create</button>
    </form>
  );
}
```

**Key Points**
- `z.infer<typeof Schema>` extracts the TypeScript type from the Zod schema. This type can be used for form state, function parameters, and API response shaping without duplication.
- `@hookform/resolvers/zod` must be installed separately: `npm install @hookform/resolvers`.
- Validation runs on the client before the mutation is called, and again on the server when tRPC receives the request. Both layers use the same schema.

---

### Extracting Input Types

```ts
import type { inferProcedureInput } from '@trpc/server';
import type { AppRouter } from '../server/router';

type CreateUserInput = inferProcedureInput<AppRouter['user']['create']>;
// equivalent to z.infer<typeof CreateUserSchema>
```

**Key Points**
- `inferProcedureInput` extracts the input type directly from the router type, useful when you do not have direct access to the Zod schema but do have access to `AppRouter`.
- This is a type-only utility — it produces no runtime output.

---

### Alternative Validators

tRPC supports validators other than Zod that conform to its validator interface. The input must expose a `~standard` property following the Standard Schema specification, or provide a `_input` / `_output` interface compatible with tRPC's expectations. [Inference] Compatibility varies by tRPC version — consult the tRPC documentation for your version.

| Validator | Notes |
|---|---|
| Zod | First-class support, most community examples |
| Yup | Supported via adapter |
| Valibot | Supported, smaller bundle size than Zod |
| ArkType | Supported in recent tRPC versions [Inference] |
| Custom | Possible if the validator conforms to the expected interface |

---

### Common Validation Errors and Resolutions

| Scenario | Schema | Resolution |
|---|---|---|
| Field required but absent | `z.string()` | Client must send the field |
| Field present but wrong type | `z.number()` receives `"5"` | Use `z.coerce.number()` to accept string-encoded numbers |
| String too short | `z.string().min(8)` | Enforce minimum length on client before sending |
| Invalid email format | `z.string().email()` | Validate email format on client with same schema |
| Value not in enum | `z.enum([...])` | Ensure client only sends allowed values |
| Cross-field validation fails | `.refine()` | Check field combination logic matches client expectation |

#### `z.coerce` for type coercion

Query string parameters arrive as strings. `z.coerce` parses the string into the target type:

```ts
getPage: publicProcedure
  .input(z.object({
    page: z.coerce.number().int().min(1).default(1),
    limit: z.coerce.number().int().min(1).max(100).default(20),
  }))
  .query(({ input }) => {
    return { page: input.page, limit: input.limit };
  }),
```

**Key Points**
- `z.coerce.number()` calls `Number()` on the value before validation. `"5"` becomes `5`.
- Coercion is lossy — `Number("abc")` is `NaN`, which Zod rejects as not a number. Coercion does not mean arbitrary string-to-number guessing.
- The tRPC client serializes input correctly, so coercion is typically only needed when receiving input from sources outside the tRPC client, such as URL query parameters parsed by the framework.