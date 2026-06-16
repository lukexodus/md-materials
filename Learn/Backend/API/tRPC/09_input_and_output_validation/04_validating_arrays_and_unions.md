## Validating Arrays and Unions

Arrays and unions are the two most structurally complex input types in tRPC procedures. Arrays carry constraints at both the collection and element level. Unions require tRPC to determine which of several schemas applies to a given input. Together they cover bulk operations, polymorphic payloads, and flexible filter inputs.

---

### Array Fundamentals

```typescript
import { z } from 'zod';

// Basic array
z.array(z.string())

// Shorthand — equivalent
z.string().array()

// Array of objects
z.array(z.object({ id: z.string(), value: z.number() }))

// Readonly array
z.array(z.string()).readonly()
```

---

### Array-Level Constraints

Constraints applied to the array itself, not its elements:

```typescript
z.array(z.string()).min(1)          // at least 1 element
z.array(z.string()).max(100)        // at most 100 elements
z.array(z.string()).length(5)       // exactly 5 elements
z.array(z.string()).nonempty()      // shorthand for .min(1); output type is [string, ...string[]]
```

**Key Points:**

- `.nonempty()` narrows the output type to a non-empty tuple `[T, ...T[]]` — this gives TypeScript the guarantee that `arr[0]` is always defined, unlike `.min(1)` which still types the array as `T[]`
- `.length()` is useful for fixed-size inputs like coordinate pairs or RGB values
- Constraints are checked after element parsing — if an element fails, the array constraint error may not appear [Inference: exact error ordering depends on Zod version]

---

### Element-Level Constraints

Constraints on each individual element:

```typescript
// Array of non-empty strings
z.array(z.string().min(1).max(200))

// Array of positive integers
z.array(z.number().int().positive())

// Array of UUIDs
z.array(z.string().uuid())

// Array of objects with validation
z.array(
  z.object({
    key: z.string().regex(/^[a-zA-Z_][a-zA-Z0-9_]*$/),
    value: z.unknown(),
  })
)
```

**Key Points:**

- Element errors are reported with the array index as part of the path — `issues[0].path` will be `[0, 'key']` for an element object field failure
- All elements are validated — Zod does not short-circuit on the first element failure by default; the full error set is collected

---

### Combining Array and Element Constraints

```typescript
const TagsSchema = z
  .array(z.string().trim().toLowerCase().min(1).max(50))
  .min(1)
  .max(20);

const BatchCreateSchema = z.object({
  items: z
    .array(
      z.object({
        name: z.string().min(1).max(100),
        price: z.number().positive(),
        sku: z.string().regex(/^[A-Z0-9-]{4,20}$/),
      })
    )
    .min(1)
    .max(500),
});
```

---

### Uniqueness Validation

Zod has no built-in uniqueness constraint. Use `.superRefine()` for this.

#### Unique Primitive Array

```typescript
const UniqueTagsSchema = z
  .array(z.string().min(1))
  .superRefine((tags, ctx) => {
    const seen = new Set<string>();
    tags.forEach((tag, index) => {
      if (seen.has(tag)) {
        ctx.addIssue({
          code: z.ZodIssueCode.custom,
          path: [index],
          message: `Duplicate tag: "${tag}"`,
        });
      }
      seen.add(tag);
    });
  });
```

#### Unique by Object Field

```typescript
const UniqueUsersSchema = z
  .array(
    z.object({
      email: z.string().email(),
      name: z.string(),
    })
  )
  .superRefine((users, ctx) => {
    const emails = new Set<string>();
    users.forEach(({ email }, index) => {
      if (emails.has(email)) {
        ctx.addIssue({
          code: z.ZodIssueCode.custom,
          path: [index, 'email'],
          message: `Duplicate email: "${email}"`,
        });
      }
      emails.add(email);
    });
  });
```

**Key Points:**

- Attaching the issue to `[index, 'field']` produces a precise path — `users[2].email` — which maps directly to a form field on the client
- Using a `Set` is O(n) and appropriate for typical batch sizes; for very large arrays, behavior may vary [Inference]
- `superRefine` runs after all element schemas pass — if an element fails its own schema, the uniqueness check may not run for that element [Inference]

---

### Transforming Arrays

Transforms on array elements run per-element after validation:

```typescript
// Deduplicate and sort after validation
const ProcessedTagsSchema = z
  .array(z.string().trim().toLowerCase())
  .transform((tags) => [...new Set(tags)].sort());

// Parse a comma-separated string into an array
const CsvToArray = z
  .string()
  .transform((val) => val.split(',').map((s) => s.trim()).filter(Boolean))
  .pipe(z.array(z.string().min(1)));
```

#### The `.pipe()` Pattern

`.pipe()` chains schemas — the output of one becomes the input of the next. This is useful for transforming raw input (e.g., a comma-delimited string) before validating the resulting array.

```typescript
const IdsFromCsv = z
  .string()
  .transform((val) => val.split(',').map((s) => s.trim()))
  .pipe(z.array(z.string().uuid()).min(1).max(50));

// Input:  "uuid1, uuid2, uuid3"
// Output: ['uuid1', 'uuid2', 'uuid3'] — validated as UUIDs
```

**Key Points:**

- `.pipe()` separates the transformation step from the validation step, keeping each schema single-purpose
- If the transform produces an empty array, the `.min(1)` on the pipe target catches it with a clear error

---

### Tuples

Tuples are fixed-length arrays where each position has a distinct type:

```typescript
// Coordinate pair
const PointSchema = z.tuple([z.number(), z.number()]);
// [number, number]

// Typed command/args pair
const CommandSchema = z.tuple([
  z.enum(['create', 'update', 'delete']),
  z.string().uuid(),
  z.record(z.unknown()).optional(),
]);
// ['create' | 'update' | 'delete', string, Record<string, unknown> | undefined]

// Tuple with variadic rest
const AtLeastOneNumberSchema = z.tuple([z.number()]).rest(z.number());
// [number, ...number[]]
```

**Key Points:**

- Tuples give TypeScript positional type information — `schema.parse([...])[0]` is typed as the first element's type
- Tuples are less common in tRPC inputs than objects (objects have named keys, which are more self-documenting) but are useful for RPC-style commands and coordinate data

---

### Union Fundamentals

A union schema accepts a value that satisfies any one of its member schemas.

```typescript
// Primitive union
z.union([z.string(), z.number()])
z.string().or(z.number())           // shorthand

// Object union
z.union([
  z.object({ type: z.literal('a'), value: z.string() }),
  z.object({ type: z.literal('b'), count: z.number() }),
])
```

**Key Points:**

- `z.union()` tries each member schema in order and accepts the first that succeeds
- For object unions without a discriminant, Zod tries every branch — this is slower and produces more confusing error messages than discriminated unions
- Member schemas should be meaningfully distinct; ambiguous unions (e.g., two object schemas with all-optional fields) can produce unexpected parsing results [Inference]

---

### Discriminated Unions

`z.discriminatedUnion()` requires a shared literal key that uniquely identifies which branch to use. It skips non-matching branches entirely, making parsing faster and errors clearer.

```typescript
const NotificationSchema = z.discriminatedUnion('type', [
  z.object({
    type: z.literal('email'),
    to: z.string().email(),
    subject: z.string().min(1),
    body: z.string().min(1),
  }),
  z.object({
    type: z.literal('sms'),
    to: z.string().regex(/^\+[1-9]\d{1,14}$/),
    body: z.string().max(160),
  }),
  z.object({
    type: z.literal('webhook'),
    url: z.string().url(),
    payload: z.record(z.unknown()),
    secret: z.string().optional(),
  }),
]);

const sendNotification = t.procedure
  .input(NotificationSchema)
  .mutation(async ({ input }) => {
    switch (input.type) {
      case 'email':
        // input.subject and input.body are available; input.url is not
        return emailService.send(input);
      case 'sms':
        return smsService.send(input);
      case 'webhook':
        return webhookService.dispatch(input);
    }
  });
```

**Key Points:**

- The discriminant key must be a `z.literal()` in every branch — a plain `z.string()` is not accepted
- If the discriminant value does not match any branch, Zod reports a single clear error listing valid options
- TypeScript narrows the type inside each `switch` case — accessing a field from the wrong branch is a compile error

---

### Discriminated Unions vs Plain Unions

```typescript
// ❌ Plain union — tries both branches; error messages combine both
z.union([
  z.object({ type: z.literal('email'), to: z.string().email() }),
  z.object({ type: z.literal('sms'),   to: z.string() }),
])

// ✅ Discriminated union — jumps directly to the 'email' branch
z.discriminatedUnion('type', [
  z.object({ type: z.literal('email'), to: z.string().email() }),
  z.object({ type: z.literal('sms'),   to: z.string() }),
])
```

Use plain `z.union()` when:
- Member schemas are primitives or non-object types
- There is no natural discriminant key
- The union has only two members and the schemas are clearly distinct

Use `z.discriminatedUnion()` when:
- All members are objects
- A shared literal key distinguishes each branch
- The union has three or more members

---

### Arrays of Unions

Combining arrays with unions allows heterogeneous collections:

```typescript
const BlockSchema = z.discriminatedUnion('kind', [
  z.object({
    kind: z.literal('text'),
    content: z.string().min(1),
    align: z.enum(['left', 'center', 'right']).default('left'),
  }),
  z.object({
    kind: z.literal('image'),
    url: z.string().url(),
    alt: z.string().optional(),
    width: z.number().int().positive().optional(),
  }),
  z.object({
    kind: z.literal('divider'),
    thickness: z.number().int().min(1).max(10).default(1),
  }),
]);

const CreatePageSchema = z.object({
  title: z.string().min(1).max(200),
  blocks: z.array(BlockSchema).min(1).max(100),
  published: z.boolean().default(false),
});

type Block = z.infer<typeof BlockSchema>;
// { kind: 'text'; content: string; align: 'left' | 'center' | 'right' }
// | { kind: 'image'; url: string; alt?: string; width?: number }
// | { kind: 'divider'; thickness: number }
```

In the procedure, narrow each block by its `kind`:

```typescript
const createPage = t.procedure
  .input(CreatePageSchema)
  .mutation(async ({ input }) => {
    const renderedBlocks = input.blocks.map((block) => {
      switch (block.kind) {
        case 'text':    return renderText(block);
        case 'image':   return renderImage(block);
        case 'divider': return renderDivider(block);
      }
    });

    return db.page.create({
      data: { title: input.title, blocks: renderedBlocks, published: input.published },
    });
  });
```

---

### Unions with Shared Fields

When union branches share fields, extract the common shape into a base and use `.extend()`:

```typescript
const BaseBlockSchema = z.object({
  id: z.string().uuid().default(() => crypto.randomUUID()),
  order: z.number().int().nonnegative(),
  visible: z.boolean().default(true),
});

const TextBlockSchema = BaseBlockSchema.extend({
  kind: z.literal('text'),
  content: z.string().min(1),
});

const ImageBlockSchema = BaseBlockSchema.extend({
  kind: z.literal('image'),
  url: z.string().url(),
  alt: z.string().optional(),
});

const BlockSchema = z.discriminatedUnion('kind', [
  TextBlockSchema,
  ImageBlockSchema,
]);
```

**Key Points:**

- `.extend()` on the base schema produces a new schema that inherits all base fields — changes to `BaseBlockSchema` propagate to all variants
- This pattern is preferable to duplicating `id`, `order`, and `visible` in every branch

---

### Optional Arrays and Empty Array Handling

```typescript
// Optional array — field may be omitted entirely
z.array(z.string()).optional()

// Default to empty array if omitted
z.array(z.string()).default(() => [])

// Distinguish empty array from omitted
z.object({
  tags: z.array(z.string()).optional(),
  // undefined → not provided (no change in a PATCH)
  // []        → explicitly cleared
})
```

**Key Points:**

- An empty array `[]` is a valid value for `z.array()`; `.min(1)` is required if you need to reject it
- The distinction between `undefined` (field absent) and `[]` (field present but empty) is meaningful in update mutations — treat them differently if the semantic differs

---

### Union Fallback with `z.catch()`

`z.catch()` provides a fallback value when parsing fails. It is useful when a union field should degrade gracefully rather than reject:

```typescript
const ThemeSchema = z
  .enum(['light', 'dark', 'system'])
  .catch('system');  // unknown theme values fall back to 'system'

const UserPrefsSchema = z.object({
  theme: ThemeSchema,
  language: z.string().length(2).catch('en'),
});
```

**Key Points:**

- `z.catch()` silently swallows validation errors — use only for non-critical fields where a default is acceptable
- It is inappropriate for input fields where rejection is the correct response; prefer `.default()` for absence and `z.catch()` only for genuine graceful degradation

---

### Error Path Anatomy for Arrays and Unions

```typescript
// Schema
const Schema = z.object({
  users: z.array(
    z.object({
      email: z.string().email(),
      role: z.enum(['admin', 'user']),
    })
  ),
});

// Input with errors
Schema.safeParse({
  users: [
    { email: 'valid@example.com', role: 'admin' },
    { email: 'not-an-email',      role: 'superuser' },  // two errors
  ],
});

// ZodError issues:
// [
//   { path: ['users', 1, 'email'], message: 'Invalid email' },
//   { path: ['users', 1, 'role'],  message: "Invalid enum value. Expected 'admin' | 'user'" }
// ]
```

Mapping this to dot-notation for client display:

```typescript
const fieldErrors = error.issues.map((issue) => ({
  path: issue.path.join('.'),   // 'users.1.email', 'users.1.role'
  message: issue.message,
}));
```

---

### Diagram: Union Branch Resolution

<svg viewBox="0 0 700 310" xmlns="http://www.w3.org/2000/svg" font-family="monospace, sans-serif" font-size="12">
  <rect width="700" height="310" fill="#0f1117" rx="12"/>

  <!-- Title labels -->
  <text x="140" y="28" text-anchor="middle" fill="#64748b" font-size="11" font-weight="bold">z.union() — tries all branches</text>
  <text x="530" y="28" text-anchor="middle" fill="#64748b" font-size="11" font-weight="bold">z.discriminatedUnion() — jumps to match</text>

  <!-- Divider -->
  <line x1="350" y1="16" x2="350" y2="300" stroke="#1e293b" stroke-width="1.5" stroke-dasharray="6,4"/>

  <!-- LEFT SIDE: plain union -->
  <!-- Input -->
  <rect x="80" y="46" width="120" height="34" rx="6" fill="#1e293b" stroke="#334155" stroke-width="1.3"/>
  <text x="140" y="60" text-anchor="middle" fill="#94a3b8">Input</text>
  <text x="140" y="74" text-anchor="middle" fill="#64748b" font-size="10">{ type: 'sms', ... }</text>

  <!-- Branch A -->
  <rect x="30" y="130" width="110" height="34" rx="6" fill="#1e293b" stroke="#f59e0b" stroke-width="1.2"/>
  <text x="85" y="144" text-anchor="middle" fill="#fbbf24" font-size="11">Branch A</text>
  <text x="85" y="158" text-anchor="middle" fill="#92400e" font-size="10">type: 'email' ✗</text>

  <!-- Branch B -->
  <rect x="155" y="130" width="110" height="34" rx="6" fill="#1e293b" stroke="#22c55e" stroke-width="1.2"/>
  <text x="210" y="144" text-anchor="middle" fill="#86efac" font-size="11">Branch B</text>
  <text x="210" y="158" text-anchor="middle" fill="#166534" font-size="10">type: 'sms' ✓</text>

  <!-- Arrows from input to branches -->
  <line x1="120" y1="80" x2="85"  y2="130" stroke="#475569" stroke-width="1.2" marker-end="url(#arr)"/>
  <line x1="160" y1="80" x2="210" y2="130" stroke="#475569" stroke-width="1.2" marker-end="url(#arr)"/>

  <!-- Note: tries all -->
  <text x="140" y="108" text-anchor="middle" fill="#475569" font-size="10">tries every branch</text>

  <!-- Merged errors box -->
  <rect x="48" y="210" width="185" height="40" rx="6" fill="#1c1409" stroke="#d97706" stroke-width="1.2"/>
  <text x="140" y="226" text-anchor="middle" fill="#d97706" font-size="11">Combined error output</text>
  <text x="140" y="241" text-anchor="middle" fill="#92400e" font-size="10">all branch failures merged</text>
  <line x1="85"  y1="164" x2="105" y2="210" stroke="#f59e0b" stroke-width="1" stroke-dasharray="4,3"/>
  <line x1="210" y1="164" x2="190" y2="210" stroke="#22c55e" stroke-width="1" stroke-dasharray="4,3"/>

  <!-- RIGHT SIDE: discriminated union -->
  <!-- Input -->
  <rect x="460" y="46" width="140" height="34" rx="6" fill="#1e293b" stroke="#334155" stroke-width="1.3"/>
  <text x="530" y="60" text-anchor="middle" fill="#94a3b8">Input</text>
  <text x="530" y="74" text-anchor="middle" fill="#64748b" font-size="10">{ type: 'sms', ... }</text>

  <!-- Discriminant lookup -->
  <rect x="462" y="118" width="136" height="30" rx="6" fill="#1e293b" stroke="#3b82f6" stroke-width="1.2"/>
  <text x="530" y="133" text-anchor="middle" fill="#93c5fd" font-size="11">read type → 'sms'</text>
  <text x="530" y="145" text-anchor="middle" fill="#1d4ed8" font-size="9">lookup branch map</text>
  <line x1="530" y1="80" x2="530" y2="118" stroke="#475569" stroke-width="1.2" marker-end="url(#arr)"/>

  <!-- Direct branch -->
  <rect x="462" y="196" width="136" height="34" rx="6" fill="#1e293b" stroke="#22c55e" stroke-width="1.2"/>
  <text x="530" y="210" text-anchor="middle" fill="#86efac" font-size="11">Branch: 'sms'</text>
  <text x="530" y="224" text-anchor="middle" fill="#166534" font-size="10">validate directly ✓</text>
  <line x1="530" y1="148" x2="530" y2="196" stroke="#22c55e" stroke-width="1.2" marker-end="url(#arr2)"/>

  <!-- Skip note -->
  <text x="420" y="160" fill="#374151" font-size="10">skip 'email'</text>
  <text x="420" y="172" fill="#374151" font-size="10">skip 'webhook'</text>

  <!-- Bottom caption -->
  <text x="140" y="290" text-anchor="middle" fill="#475569" font-size="10">Slower · complex errors</text>
  <text x="530" y="290" text-anchor="middle" fill="#475569" font-size="10">Faster · precise errors</text>

  <defs>
    <marker id="arr" markerWidth="7" markerHeight="7" refX="5" refY="3" orient="auto">
      <path d="M0,0 L0,6 L7,3 z" fill="#475569"/>
    </marker>
    <marker id="arr2" markerWidth="7" markerHeight="7" refX="5" refY="3" orient="auto">
      <path d="M0,0 L0,6 L7,3 z" fill="#22c55e"/>
    </marker>
  </defs>
</svg>

---

### Summary

| Concern                             | Mechanism                                              |
|-------------------------------------|--------------------------------------------------------|
| Array length constraints            | `.min()`, `.max()`, `.length()`, `.nonempty()`         |
| Non-empty typed array               | `.nonempty()` — narrows to `[T, ...T[]]`               |
| Element constraints                 | Applied to the inner schema                            |
| Uniqueness across elements          | `.superRefine()` with `Set`                            |
| Transform input then validate array | `.transform().pipe(z.array(...))`                      |
| Fixed-position typed array          | `z.tuple()`                                            |
| Union of primitives or 2 types      | `z.union()`                                            |
| Union of objects with discriminant  | `z.discriminatedUnion()`                               |
| Heterogeneous array                 | `z.array(z.discriminatedUnion(...))`                   |
| Shared fields across union branches | Base schema + `.extend()` per branch                   |
| Graceful fallback on invalid value  | `z.catch()`                                            |
| Error path for nested array item    | `issue.path` → `[arrayKey, index, fieldKey]`           |

**Conclusion**

Array and union validation in tRPC covers two of the most structurally expressive input shapes. Arrays require attention at both the collection and element level — particularly for uniqueness, ordering, and transform chaining. Unions require choosing between the broad-but-slower `z.union()` and the precise-and-fast `z.discriminatedUnion()` based on whether a shared discriminant key is available. Combined as arrays of discriminated unions, they model complex document-style and event-driven inputs cleanly while preserving end-to-end TypeScript narrowing through to the procedure body.