## Optional and Partial Inputs

Handling optional and partial inputs correctly is critical for writing flexible tRPC procedures — particularly for query filtering, PATCH-style updates, and procedures with optional feature flags. Zod provides several mechanisms for expressing optionality, and understanding their distinctions prevents subtle runtime and type-level bugs.

---

### The Four Optionality Modifiers

Zod offers four distinct modifiers that all relate to optionality but carry different semantics:

```typescript
import { z } from 'zod';

z.string().optional()   // string | undefined — field may be absent or explicitly undefined
z.string().nullable()   // string | null      — field must be present but may be null
z.string().nullish()    // string | null | undefined — either null or undefined acceptable
z.string().default('x') // string             — undefined input becomes 'x'; output is always string
```

**Key Points:**

- `.optional()` and `.nullable()` are not interchangeable — `null` fails `.optional()`, and `undefined` fails `.nullable()`
- `.nullish()` is shorthand for `.optional().nullable()` and is useful when the data source may produce either `null` or `undefined` [Inference: exact equivalence may vary internally]
- `.default()` removes optionality from the *output* type — `z.infer<>` shows `string`, not `string | undefined`; the field is still technically optional in the input

---

### Optional Object Keys

When `.optional()` is applied inside `z.object()`, the key may be omitted from the input entirely or sent as `undefined`.

```typescript
const FilterSchema = z.object({
  search: z.string().optional(),      // key may be absent
  status: z.enum(['active', 'inactive']).optional(),
  minAge: z.number().int().optional(),
  maxAge: z.number().int().optional(),
});

type FilterInput = z.infer<typeof FilterSchema>;
// {
//   search?: string | undefined;
//   status?: 'active' | 'inactive' | undefined;
//   minAge?: number | undefined;
//   maxAge?: number | undefined;
// }
```

In a procedure, check for presence with a simple truthiness or `!== undefined` guard:

```typescript
const listUsers = t.procedure
  .input(FilterSchema)
  .query(async ({ input }) => {
    return db.user.findMany({
      where: {
        ...(input.search !== undefined && {
          name: { contains: input.search, mode: 'insensitive' },
        }),
        ...(input.status !== undefined && {
          status: input.status,
        }),
        ...(input.minAge !== undefined || input.maxAge !== undefined
          ? {
              age: {
                ...(input.minAge !== undefined && { gte: input.minAge }),
                ...(input.maxAge !== undefined && { lte: input.maxAge }),
              },
            }
          : {}),
      },
    });
  });
```

**Key Points:**

- Use `!== undefined` rather than `if (input.search)` for optional strings — an empty string `''` is falsy but may be a valid value in some contexts
- Spread-with-condition (`...(condition && { key: value })`) is a clean pattern for building optional filter objects

---

### Default Values

`.default()` provides a fallback when the input value is `undefined`. It acts as a transform: it accepts `T | undefined` as input and always outputs `T`.

```typescript
const PaginationSchema = z.object({
  page: z.number().int().positive().default(1),
  limit: z.number().int().min(1).max(100).default(20),
  sortOrder: z.enum(['asc', 'desc']).default('desc'),
});

type PaginationInput = z.infer<typeof PaginationSchema>;
// { page: number; limit: number; sortOrder: 'asc' | 'desc' }
// No undefined — defaults guarantee these are always present
```

#### Default with Factory Function

For reference types (arrays, objects, dates), always use a factory function to avoid shared reference bugs:

```typescript
const Schema = z.object({
  tags: z.array(z.string()).default(() => []),       // ✅ new array per parse
  createdAt: z.date().default(() => new Date()),     // ✅ new Date per parse
  config: z.object({
    retries: z.number().default(3),
  }).default(() => ({ retries: 3 })),               // ✅ new object per parse
});

// ❌ Avoid — same array reference shared across all parses
const BadSchema = z.object({
  tags: z.array(z.string()).default([]),
});
```

**Key Points:**

- Primitive defaults (strings, numbers, booleans, enums) are safe as literals
- Object and array defaults should always use factory functions [Inference: shared reference bugs are subtle and depend on whether the output is mutated]

---

### `.partial()` — Shallow Partial

`.partial()` makes all top-level fields of a `z.object()` optional. It is the Zod equivalent of TypeScript's `Partial<T>`.

```typescript
const UserSchema = z.object({
  name: z.string().min(1),
  email: z.string().email(),
  role: z.enum(['admin', 'user']),
  bio: z.string().max(500),
});

const UpdateUserBodySchema = UserSchema.partial();
// All fields become optional:
// { name?: string; email?: string; role?: 'admin' | 'user'; bio?: string }

// Combine with a required ID
const UpdateUserSchema = z.object({
  id: z.string().uuid(),
}).merge(UserSchema.partial());
```

**Example in tRPC:**

```typescript
const updateUser = t.procedure
  .input(UpdateUserSchema)
  .mutation(async ({ input }) => {
    const { id, ...patch } = input;

    // Remove undefined keys before passing to DB
    const data = Object.fromEntries(
      Object.entries(patch).filter(([, v]) => v !== undefined)
    );

    if (Object.keys(data).length === 0) {
      throw new TRPCError({
        code: 'BAD_REQUEST',
        message: 'At least one field must be provided to update.',
      });
    }

    return db.user.update({ where: { id }, data });
  });
```

**Key Points:**

- `.partial()` only operates on the top level — nested object fields remain required unless separately partialed
- After spreading, `patch` may have `undefined` values for unset fields — strip them before passing to ORM methods that interpret `undefined` as "set to null" [Inference: behavior depends on the ORM]
- Validate that at least one field is provided if a completely empty update is nonsensical

---

### `.partial()` with Field Selection

You can partial only specific fields rather than all of them:

```typescript
const UserSchema = z.object({
  name: z.string().min(1),
  email: z.string().email(),
  role: z.enum(['admin', 'user']),
  bio: z.string().max(500),
});

// Only name and bio become optional; email and role stay required
const Schema = UserSchema.partial({ name: true, bio: true });
// { name?: string; email: string; role: 'admin' | 'user'; bio?: string }
```

This is useful for create-or-update patterns where some fields are required on create but optional on update.

---

### `.deepPartial()` — Deep Partial

`.deepPartial()` recursively applies `.partial()` at every level of nested objects.

```typescript
const AddressSchema = z.object({
  street: z.string(),
  city: z.string(),
  postalCode: z.string(),
});

const ProfileSchema = z.object({
  name: z.string(),
  address: AddressSchema,
  preferences: z.object({
    theme: z.enum(['light', 'dark']),
    notifications: z.boolean(),
  }),
});

const PatchProfileSchema = ProfileSchema.deepPartial();
// {
//   name?: string;
//   address?: { street?: string; city?: string; postalCode?: string };
//   preferences?: { theme?: 'light' | 'dark'; notifications?: boolean };
// }
```

**Key Points:**

- `.deepPartial()` is marked experimental in some Zod versions — verify behavior against your installed version before using in production [Unverified]
- Deep partial is appropriate when the client sends only the nested keys it wishes to change, and the server merges them with existing data
- Deep partial does not apply to `z.array()` elements — array items are not made partial [Inference]

---

### Distinguishing Absent vs Explicitly `undefined` vs `null`

In HTTP APIs, these three states often conflate. Over JSON:

- A key absent from the body and a key set to `undefined` are indistinguishable — JSON serialization omits both
- A key explicitly set to `null` survives serialization and arrives as `null`

This has practical consequences for PATCH semantics:

```typescript
// Three-state field: absent (no change), null (clear the value), string (set value)
const UpdateBioSchema = z.object({
  id: z.string().uuid(),
  bio: z.string().max(500).nullable().optional(),
  //   ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  //   string | null | undefined
  //   - undefined → not provided, skip update
  //   - null      → client explicitly cleared the bio
  //   - string    → client set a new bio
});

const updateBio = t.procedure
  .input(UpdateBioSchema)
  .mutation(async ({ input }) => {
    if (input.bio === undefined) {
      // Field not included — do nothing
      return db.user.findUnique({ where: { id: input.id } });
    }

    return db.user.update({
      where: { id: input.id },
      data: { bio: input.bio }, // null clears the field; string sets it
    });
  });
```

**Key Points:**

- This three-state pattern requires the client to be explicit: omit the key to skip, send `null` to clear, send a value to set
- tRPC's default serializer (JSON) does not distinguish absent from `undefined` — if you need to detect a key was explicitly sent as `undefined`, a custom transformer like SuperJSON is required [Inference]
- Document this convention clearly in your API — consumers need to know that `null` has a distinct meaning from omission

---

### Optional Inputs in Queries vs Mutations

Optional fields behave the same in queries and mutations, but their practical patterns differ.

#### Queries — Optional Filters

Optional fields in query inputs are typically filter parameters. The pattern is additive — only apply filters that are present.

```typescript
const ListPostsSchema = z.object({
  authorId: z.string().uuid().optional(),
  tag: z.string().optional(),
  published: z.boolean().optional(),
  cursor: z.string().optional(),            // pagination cursor
  limit: z.number().int().min(1).max(50).default(20),
});

const listPosts = t.procedure
  .input(ListPostsSchema)
  .query(async ({ input }) => {
    return db.post.findMany({
      where: {
        ...(input.authorId !== undefined && { authorId: input.authorId }),
        ...(input.tag !== undefined && { tags: { has: input.tag } }),
        ...(input.published !== undefined && { published: input.published }),
      },
      take: input.limit + 1, // fetch one extra to determine hasNextPage
      ...(input.cursor !== undefined && {
        cursor: { id: input.cursor },
        skip: 1,
      }),
    });
  });
```

#### Mutations — Optional Patch Fields

Optional fields in mutation inputs are typically patch fields. The pattern is selective update — only persist fields that were provided.

```typescript
const UpdatePostSchema = z.object({
  id: z.string().uuid(),
  title: z.string().min(1).max(200).optional(),
  body: z.string().min(1).optional(),
  tags: z.array(z.string()).optional(),
  published: z.boolean().optional(),
});
```

---

### Cross-Field Validation on Optional Fields

When multiple optional fields have a dependency — e.g., both must be provided together or neither — use `superRefine`.

```typescript
const DateRangeSchema = z.object({
  startDate: z.coerce.date().optional(),
  endDate: z.coerce.date().optional(),
}).superRefine(({ startDate, endDate }, ctx) => {
  // Both or neither
  if ((startDate === undefined) !== (endDate === undefined)) {
    ctx.addIssue({
      code: z.ZodIssueCode.custom,
      path: [startDate === undefined ? 'startDate' : 'endDate'],
      message: 'Both startDate and endDate must be provided together.',
    });
  }

  // startDate must precede endDate
  if (startDate !== undefined && endDate !== undefined && startDate >= endDate) {
    ctx.addIssue({
      code: z.ZodIssueCode.custom,
      path: ['endDate'],
      message: 'endDate must be after startDate.',
    });
  }
});
```

---

### Composing Optional Schemas Cleanly

For large procedures with many optional fields, break the schema into logical groups:

```typescript
const RequiredFields = z.object({
  id: z.string().uuid(),
});

const ScalarUpdates = z.object({
  name: z.string().min(1).max(100),
  bio: z.string().max(500).nullable(),
  website: z.string().url().nullable(),
}).partial();

const PreferenceUpdates = z.object({
  theme: z.enum(['light', 'dark', 'system']),
  emailNotifications: z.boolean(),
  language: z.string().length(2),
}).partial();

const UpdateProfileSchema = RequiredFields
  .merge(ScalarUpdates)
  .merge(z.object({ preferences: PreferenceUpdates.optional() }));
```

---

### Diagram: Optionality Modifier Behavior

<svg viewBox="0 0 700 260" xmlns="http://www.w3.org/2000/svg" font-family="monospace, sans-serif" font-size="12">
  <rect width="700" height="260" fill="#0f1117" rx="12"/>

  <!-- Header row -->
  <text x="30" y="36" fill="#64748b" font-size="11" font-weight="bold">Modifier</text>
  <text x="210" y="36" fill="#64748b" font-size="11" font-weight="bold">Accepts</text>
  <text x="380" y="36" fill="#64748b" font-size="11" font-weight="bold">Rejects</text>
  <text x="530" y="36" fill="#64748b" font-size="11" font-weight="bold">Output Type</text>

  <!-- Divider -->
  <line x1="20" y1="44" x2="680" y2="44" stroke="#1e293b" stroke-width="1"/>

  <!-- Row 1: optional -->
  <rect x="20" y="52" width="660" height="40" rx="5" fill="#1e293b" fill-opacity="0.4"/>
  <text x="30" y="72" fill="#93c5fd" font-family="monospace">.optional()</text>
  <text x="210" y="66" fill="#86efac" font-size="11">string ✓</text>
  <text x="210" y="82" fill="#86efac" font-size="11">undefined ✓</text>
  <text x="380" y="72" fill="#f87171" font-size="11">null ✗</text>
  <text x="530" y="72" fill="#e2e8f0" font-family="monospace" font-size="11">string | undefined</text>

  <!-- Row 2: nullable -->
  <rect x="20" y="97" width="660" height="40" rx="5" fill="#1e293b" fill-opacity="0.2"/>
  <text x="30" y="117" fill="#93c5fd" font-family="monospace">.nullable()</text>
  <text x="210" y="111" fill="#86efac" font-size="11">string ✓</text>
  <text x="210" y="127" fill="#86efac" font-size="11">null ✓</text>
  <text x="380" y="117" fill="#f87171" font-size="11">undefined ✗</text>
  <text x="530" y="117" fill="#e2e8f0" font-family="monospace" font-size="11">string | null</text>

  <!-- Row 3: nullish -->
  <rect x="20" y="142" width="660" height="40" rx="5" fill="#1e293b" fill-opacity="0.4"/>
  <text x="30" y="162" fill="#93c5fd" font-family="monospace">.nullish()</text>
  <text x="210" y="156" fill="#86efac" font-size="11">string ✓  null ✓</text>
  <text x="210" y="172" fill="#86efac" font-size="11">undefined ✓</text>
  <text x="380" y="162" fill="#64748b" font-size="11">—</text>
  <text x="530" y="162" fill="#e2e8f0" font-family="monospace" font-size="11">string | null | undefined</text>

  <!-- Row 4: default -->
  <rect x="20" y="187" width="660" height="40" rx="5" fill="#1e293b" fill-opacity="0.2"/>
  <text x="30" y="207" fill="#93c5fd" font-family="monospace">.default('x')</text>
  <text x="210" y="201" fill="#86efac" font-size="11">string ✓</text>
  <text x="210" y="217" fill="#86efac" font-size="11">undefined ✓ → 'x'</text>
  <text x="380" y="207" fill="#f87171" font-size="11">null ✗</text>
  <text x="530" y="207" fill="#e2e8f0" font-family="monospace" font-size="11">string</text>

  <!-- Column dividers -->
  <line x1="200" y1="44" x2="200" y2="236" stroke="#1e293b" stroke-width="1"/>
  <line x1="370" y1="44" x2="370" y2="236" stroke="#1e293b" stroke-width="1"/>
  <line x1="520" y1="44" x2="520" y2="236" stroke="#1e293b" stroke-width="1"/>

  <!-- Bottom note -->
  <text x="30" y="252" fill="#475569" font-size="10">Input type = what the caller may send. Output type = what z.infer&lt;&gt; and the procedure receive.</text>
</svg>

---

### Summary

| Concern                              | Recommended Approach                                         |
|--------------------------------------|--------------------------------------------------------------|
| Field may be omitted                 | `.optional()`                                                |
| Field may be `null`                  | `.nullable()`                                                |
| Field may be `null` or omitted       | `.nullish()`                                                 |
| Field has a fallback value           | `.default()` with factory fn for objects/arrays              |
| All fields optional (PATCH update)   | `.partial()` merged with required ID field                   |
| Nested fields optional               | `.deepPartial()` (verify version support)                    |
| Selective partial                    | `.partial({ field: true })`                                  |
| Three-state field (skip/clear/set)   | `.nullable().optional()` with explicit `undefined` guard     |
| Cross-field optional dependencies    | `.superRefine()` with `ctx.addIssue()`                       |
| Optional filter fields in queries    | `!== undefined` guards before applying to where clause       |

**Conclusion**

Optional and partial inputs in tRPC require precision: `.optional()`, `.nullable()`, `.nullish()`, and `.default()` each carry distinct semantics that affect both runtime validation and inferred TypeScript types. The most common mistake is conflating `null` and `undefined` — particularly in PATCH mutations where their distinction encodes meaningful intent. Composing `.partial()` with named required fields and validating cross-field constraints with `superRefine` produces update schemas that are both safe and self-documenting.