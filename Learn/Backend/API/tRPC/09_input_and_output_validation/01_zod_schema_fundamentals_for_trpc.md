## Zod Schema Fundamentals for tRPC

Zod is the most common schema validation library used with tRPC. It serves as the primary mechanism for defining, validating, and inferring types for procedure inputs and outputs. Understanding Zod's core primitives is prerequisite to writing well-typed, safe tRPC procedures.

---

### Why Zod with tRPC

tRPC does not require Zod — it supports any schema library that implements the `Parser` interface (Yup, Valibot, ArkType, etc.) — but Zod is the de facto standard because:

- It produces TypeScript types from schema definitions, eliminating duplication
- tRPC's `input()` and `output()` methods accept Zod schemas directly
- Validation errors from Zod are automatically caught and converted to `BAD_REQUEST`
- `errorFormatter` has first-class support for `ZodError` structure

---

### Installation

```bash
npm install zod
```

Zod requires TypeScript 4.5+ and `strict: true` in `tsconfig.json`. Without strict mode, type inference may behave unexpectedly [Inference].

---

### Primitive Types

```typescript
import { z } from 'zod';

z.string()   // string
z.number()   // number
z.boolean()  // boolean
z.bigint()   // bigint
z.date()     // Date object
z.symbol()   // symbol
z.undefined()
z.null()
z.void()
z.any()
z.unknown()
z.never()
```

**Key Points:**

- `z.any()` disables validation entirely — avoid in tRPC inputs as it accepts anything without checking
- `z.unknown()` is safer than `z.any()`: it requires explicit narrowing before use
- `z.date()` expects a JavaScript `Date` object; over HTTP, dates arrive as strings and require coercion (covered below)

---

### String Refinements

```typescript
z.string().min(1)
z.string().max(255)
z.string().length(10)
z.string().email()
z.string().url()
z.string().uuid()
z.string().cuid()
z.string().regex(/^[a-z]+$/)
z.string().startsWith('prefix_')
z.string().endsWith('.com')
z.string().trim()           // transforms: trims whitespace before validation
z.string().toLowerCase()    // transforms: lowercases before validation
z.string().toUpperCase()
z.string().nonempty()       // shorthand for .min(1)
```

**Example:**

```typescript
const emailSchema = z.string().email().toLowerCase().trim();

// In a procedure
const subscribe = t.procedure
  .input(z.object({ email: z.string().email().trim() }))
  .mutation(async ({ input }) => {
    // input.email is guaranteed to be a valid email, trimmed
    return db.subscription.create({ data: { email: input.email } });
  });
```

---

### Number Refinements

```typescript
z.number().min(0)
z.number().max(100)
z.number().positive()       // > 0
z.number().nonnegative()    // >= 0
z.number().negative()       // < 0
z.number().nonpositive()    // <= 0
z.number().int()            // must be integer
z.number().finite()         // disallows Infinity, -Infinity
z.number().safe()           // within Number.MIN_SAFE_INTEGER and MAX_SAFE_INTEGER
z.number().multipleOf(5)
```

---

### Objects

Objects are the most common schema type in tRPC inputs.

```typescript
const UserSchema = z.object({
  id: z.string().uuid(),
  name: z.string().min(1).max(100),
  email: z.string().email(),
  age: z.number().int().nonnegative().optional(),
  role: z.enum(['admin', 'user', 'moderator']),
});
```

#### Modifiers

```typescript
// Strip unknown keys (default behavior)
UserSchema.strip();

// Allow unknown keys through
UserSchema.passthrough();

// Reject unknown keys — throws if extra keys are present
UserSchema.strict();

// Pick specific keys
UserSchema.pick({ id: true, email: true });

// Omit specific keys
UserSchema.omit({ age: true });

// Make all fields optional
UserSchema.partial();

// Make all fields required
UserSchema.required();

// Extend with new fields
UserSchema.extend({ createdAt: z.date() });

// Merge two object schemas
const Extended = UserSchema.merge(z.object({ verified: z.boolean() }));
```

**Key Points:**

- By default, Zod strips unknown keys — extra fields sent by the client are silently removed before your procedure receives `input`
- `.strict()` is useful in internal APIs where unexpected fields indicate a programming error
- `.passthrough()` is rarely appropriate in tRPC inputs as it weakens type safety [Inference]

---

### Optional, Nullable, and Default

```typescript
// Optional: value may be undefined
z.string().optional()        // string | undefined

// Nullable: value may be null
z.string().nullable()        // string | null

// Nullish: value may be null or undefined
z.string().nullish()         // string | null | undefined

// Default: provides a fallback if value is undefined
z.string().default('guest')  // always returns string; undefined input becomes 'guest'

// Default with factory function
z.array(z.string()).default(() => [])
```

**Key Points:**

- `.optional()` does not mean the key can be omitted from the object — when used inside `z.object()`, it means the key may be present with value `undefined` or absent entirely
- `.default()` is a transform — it changes the output type and should be used when you want tRPC to receive a guaranteed value regardless of client input
- Do not confuse `.nullable()` with `.optional()`: a nullable field still must be explicitly provided, just as `null`

---

### Arrays and Tuples

```typescript
// Array of strings
z.array(z.string())
z.string().array()           // equivalent shorthand

// With constraints
z.array(z.string()).min(1)
z.array(z.string()).max(10)
z.array(z.string()).length(3)
z.array(z.string()).nonempty()

// Tuple: fixed-length array with typed positions
z.tuple([z.string(), z.number(), z.boolean()])

// Tuple with rest elements
z.tuple([z.string()]).rest(z.number())  // [string, ...number[]]
```

---

### Enums

```typescript
// Zod native enum
const RoleSchema = z.enum(['admin', 'user', 'moderator']);
type Role = z.infer<typeof RoleSchema>; // 'admin' | 'user' | 'moderator'

// Access enum values
RoleSchema.options; // ['admin', 'user', 'moderator']

// Native TypeScript enum
enum Direction {
  Up = 'UP',
  Down = 'DOWN',
}
const DirectionSchema = z.nativeEnum(Direction);
```

**Key Points:**

- Prefer `z.enum()` over `z.nativeEnum()` for string unions — it produces cleaner inferred types
- `z.nativeEnum()` is required when you need to use a TypeScript `enum` value at runtime (e.g., when Prisma generates enums)

---

### Unions and Discriminated Unions

```typescript
// Union: one of several types
const StringOrNumber = z.union([z.string(), z.number()]);

// Shorthand
const StringOrNumber2 = z.string().or(z.number());

// Discriminated union: more efficient for object unions
const EventSchema = z.discriminatedUnion('type', [
  z.object({ type: z.literal('created'), userId: z.string() }),
  z.object({ type: z.literal('deleted'), userId: z.string(), reason: z.string() }),
  z.object({ type: z.literal('updated'), userId: z.string(), changes: z.record(z.unknown()) }),
]);
```

**Key Points:**

- `z.discriminatedUnion()` requires a shared literal discriminant key (here `type`) and is significantly faster than `z.union()` for object unions — it avoids trying every branch [Inference: exact performance characteristics may vary]
- Use discriminated unions for event/action shapes in mutations to get precise TypeScript narrowing on `input.type`

---

### Intersections and Extending Schemas

```typescript
// Intersection: value must satisfy both schemas
const AdminUser = z.intersection(
  z.object({ id: z.string() }),
  z.object({ permissions: z.array(z.string()) })
);

// Prefer .merge() for objects — it's more ergonomic
const AdminUser2 = z.object({ id: z.string() }).merge(
  z.object({ permissions: z.array(z.string()) })
);
```

---

### Records and Maps

```typescript
// Record: object with dynamic string keys
z.record(z.string())               // Record<string, string>
z.record(z.string(), z.number())   // Record<string, number>

// Map
z.map(z.string(), z.number())      // Map<string, number>

// Set
z.set(z.string())                  // Set<string>
```

**Key Points:**

- `z.record()` is useful for metadata objects, tag maps, or config objects where keys are not known ahead of time
- Over HTTP, `Map` and `Set` are not natively serializable — tRPC serializes them as plain objects/arrays by default [Inference: behavior may depend on transformer configuration]; prefer `z.record()` and `z.array()` unless using a custom transformer like SuperJSON

---

### Transforms

Transforms mutate the parsed value, producing a potentially different output type. The input type and output type can differ.

```typescript
// Parse a numeric string into a number
const NumericString = z.string().transform((val) => parseInt(val, 10));
// Input: string, Output: number

// Parse a date string into a Date object
const DateString = z.string().transform((val) => new Date(val));

// Use z.coerce for simple type coercion
const CoercedNumber = z.coerce.number(); // coerces string '42' → 42
const CoercedDate = z.coerce.date();     // coerces string → Date
```

**Example in tRPC:**

```typescript
const listItems = t.procedure
  .input(
    z.object({
      page: z.coerce.number().int().positive().default(1),
      limit: z.coerce.number().int().min(1).max(100).default(20),
    })
  )
  .query(async ({ input }) => {
    // input.page and input.limit are always numbers,
    // even if the client sent query string values as strings
    return db.item.findMany({
      skip: (input.page - 1) * input.limit,
      take: input.limit,
    });
  });
```

**Key Points:**

- `z.coerce` is particularly useful for query parameters, which arrive as strings over HTTP
- Transforms run after validation — the input must pass the base schema before the transform applies
- If a transform throws, Zod wraps the error as a `ZodError` and tRPC returns `BAD_REQUEST`

---

### Refinements and `superRefine`

Refinements add custom validation logic beyond what built-in methods provide.

```typescript
// Simple refinement
const Password = z.string().refine(
  (val) => val.length >= 8 && /[A-Z]/.test(val),
  { message: 'Password must be 8+ characters and contain an uppercase letter.' }
);

// Async refinement (e.g., checking uniqueness in DB)
const UniqueEmail = z.string().email().refine(
  async (email) => {
    const exists = await db.user.findUnique({ where: { email } });
    return !exists;
  },
  { message: 'Email is already registered.' }
);

// superRefine: multiple issues, fine-grained control
const PasswordConfirm = z
  .object({
    password: z.string().min(8),
    confirm: z.string(),
  })
  .superRefine(({ password, confirm }, ctx) => {
    if (password !== confirm) {
      ctx.addIssue({
        code: z.ZodIssueCode.custom,
        path: ['confirm'],
        message: 'Passwords do not match.',
      });
    }
  });
```

**Key Points:**

- Async refinements require the schema to be parsed with `.parseAsync()` — tRPC uses `.parseAsync()` internally, so async refinements work in procedure inputs
- `superRefine` allows attaching issues to specific field paths, producing field-level errors in `ZodError.flatten()`
- Async refinements that hit the database add latency to every validated request — use with caution on high-frequency procedures [Inference]

---

### Type Inference

The most important Zod feature for tRPC is `z.infer<>`, which extracts the TypeScript type from a schema.

```typescript
const CreatePostSchema = z.object({
  title: z.string().min(1).max(200),
  body: z.string().min(1),
  tags: z.array(z.string()).max(10).default(() => []),
  published: z.boolean().default(false),
});

type CreatePostInput = z.infer<typeof CreatePostSchema>;
// {
//   title: string;
//   body: string;
//   tags: string[];
//   published: boolean;
// }
```

**Key Points:**

- `z.infer<>` reflects the *output* type — after transforms and defaults are applied
- Use `z.input<>` to get the type *before* transforms and defaults (i.e., what the caller must provide)
- Exporting inferred types alongside schemas keeps your API surface consistent across server and client

```typescript
export const CreatePostSchema = z.object({ ... });
export type CreatePostInput = z.infer<typeof CreatePostSchema>;
export type CreatePostRawInput = z.input<typeof CreatePostSchema>;
```

---

### Composing Schemas for Reuse

In a tRPC router, composing schemas from smaller building blocks reduces duplication.

```typescript
// Shared primitives
const IdSchema = z.string().uuid();
const PaginationSchema = z.object({
  page: z.coerce.number().int().positive().default(1),
  limit: z.coerce.number().int().min(1).max(100).default(20),
});
const SortOrderSchema = z.enum(['asc', 'desc']).default('desc');

// Composed schema
const ListUsersSchema = PaginationSchema.extend({
  sortBy: z.enum(['name', 'createdAt', 'email']).default('createdAt'),
  sortOrder: SortOrderSchema,
  search: z.string().trim().optional(),
});

// Procedure
const listUsers = t.procedure
  .input(ListUsersSchema)
  .query(async ({ input }) => {
    // input is fully typed and validated
  });
```

---

### Diagram: Zod Parse Pipeline in tRPC

<svg viewBox="0 0 740 180" xmlns="http://www.w3.org/2000/svg" font-family="monospace, sans-serif" font-size="12">
  <rect width="740" height="180" fill="#0f1117" rx="12"/>

  <!-- Boxes -->
  <rect x="20" y="65" width="110" height="44" rx="7" fill="#1e293b" stroke="#334155" stroke-width="1.4"/>
  <text x="75" y="84" text-anchor="middle" fill="#94a3b8">Raw Input</text>
  <text x="75" y="100" text-anchor="middle" fill="#64748b" font-size="10">(unknown)</text>

  <rect x="175" y="65" width="120" height="44" rx="7" fill="#1e293b" stroke="#334155" stroke-width="1.4"/>
  <text x="235" y="84" text-anchor="middle" fill="#94a3b8">Type Check</text>
  <text x="235" y="100" text-anchor="middle" fill="#64748b" font-size="10">z.string() etc.</text>

  <rect x="345" y="65" width="120" height="44" rx="7" fill="#1e293b" stroke="#334155" stroke-width="1.4"/>
  <text x="405" y="84" text-anchor="middle" fill="#94a3b8">Refinements</text>
  <text x="405" y="100" text-anchor="middle" fill="#64748b" font-size="10">.refine() etc.</text>

  <rect x="515" y="65" width="120" height="44" rx="7" fill="#1e293b" stroke="#334155" stroke-width="1.4"/>
  <text x="575" y="84" text-anchor="middle" fill="#94a3b8">Transforms</text>
  <text x="575" y="100" text-anchor="middle" fill="#64748b" font-size="10">.transform() etc.</text>

  <!-- Fail paths -->
  <rect x="175" y="148" width="120" height="22" rx="5" fill="#1c0f0f" stroke="#ef4444" stroke-width="1.2"/>
  <text x="235" y="163" text-anchor="middle" fill="#f87171" font-size="11">BAD_REQUEST</text>

  <rect x="345" y="148" width="120" height="22" rx="5" fill="#1c0f0f" stroke="#ef4444" stroke-width="1.2"/>
  <text x="405" y="163" text-anchor="middle" fill="#f87171" font-size="11">BAD_REQUEST</text>

  <!-- Arrows between boxes -->
  <line x1="130" y1="87" x2="174" y2="87" stroke="#475569" stroke-width="1.4" marker-end="url(#a1)"/>
  <line x1="295" y1="87" x2="344" y2="87" stroke="#475569" stroke-width="1.4" marker-end="url(#a1)"/>
  <line x1="465" y1="87" x2="514" y2="87" stroke="#475569" stroke-width="1.4" marker-end="url(#a1)"/>

  <!-- Fail arrows -->
  <line x1="235" y1="109" x2="235" y2="147" stroke="#ef4444" stroke-width="1.2" stroke-dasharray="4,3" marker-end="url(#a2)"/>
  <line x1="405" y1="109" x2="405" y2="147" stroke="#ef4444" stroke-width="1.2" stroke-dasharray="4,3" marker-end="url(#a2)"/>

  <!-- Output arrow -->
  <line x1="635" y1="87" x2="700" y2="87" stroke="#22c55e" stroke-width="1.4" marker-end="url(#a3)"/>
  <text x="700" y="84" fill="#86efac" font-size="11">input</text>
  <text x="700" y="98" fill="#4ade80" font-size="10">(typed)</text>

  <!-- Stage labels -->
  <text x="75" y="145" text-anchor="middle" fill="#475569" font-size="10">1. receive</text>
  <text x="235" y="145" text-anchor="middle" fill="#475569" font-size="10">2. validate type</text>
  <text x="405" y="145" text-anchor="middle" fill="#475569" font-size="10">3. refine</text>
  <text x="575" y="145" text-anchor="middle" fill="#475569" font-size="10">4. transform</text>

  <defs>
    <marker id="a1" markerWidth="7" markerHeight="7" refX="5" refY="3" orient="auto">
      <path d="M0,0 L0,6 L7,3 z" fill="#475569"/>
    </marker>
    <marker id="a2" markerWidth="7" markerHeight="7" refX="5" refY="3" orient="auto">
      <path d="M0,0 L0,6 L7,3 z" fill="#ef4444"/>
    </marker>
    <marker id="a3" markerWidth="7" markerHeight="7" refX="5" refY="3" orient="auto">
      <path d="M0,0 L0,6 L7,3 z" fill="#22c55e"/>
    </marker>
  </defs>
</svg>

---

### Summary

| Concept             | Method / Pattern                          | tRPC Relevance                                      |
|---------------------|-------------------------------------------|-----------------------------------------------------|
| Primitive types     | `z.string()`, `z.number()`, etc.          | Foundation of all input schemas                     |
| Object schemas      | `z.object()`, `.extend()`, `.merge()`     | Most common input shape                             |
| Optional / default  | `.optional()`, `.default()`               | Controls required vs optional fields                |
| Enums               | `z.enum()`, `z.nativeEnum()`              | Constrained string inputs, matches Prisma enums     |
| Transforms          | `.transform()`, `z.coerce`                | Coerce query strings, parse dates                   |
| Refinements         | `.refine()`, `.superRefine()`             | Custom validation, cross-field rules, async checks  |
| Type inference      | `z.infer<>`, `z.input<>`                  | Eliminates type duplication between schema and code |
| Composition         | Shared schemas, `.extend()`, `.partial()` | Reusable building blocks across procedures          |

**Conclusion**

Zod schemas in tRPC are simultaneously the validation layer, the documentation layer, and the type source. Mastering Zod's primitive types, object modifiers, transforms, and refinements lets you express precise input contracts that tRPC enforces automatically — converting any violation into a correctly classified `BAD_REQUEST` before your procedure logic ever runs. The inferred TypeScript types eliminate the need to manually declare input types, keeping the schema as the single source of truth.