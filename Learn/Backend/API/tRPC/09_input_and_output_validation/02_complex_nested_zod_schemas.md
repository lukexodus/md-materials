## Complex Nested Zod Schemas

As tRPC procedures grow in complexity, input schemas must model deeply nested structures, recursive data, conditional shapes, and multi-schema compositions. This topic covers advanced Zod patterns used in real-world tRPC APIs.

---

### Nested Objects

The most direct form of nesting — objects within objects.

```typescript
import { z } from 'zod';

const AddressSchema = z.object({
  street: z.string().min(1),
  city: z.string().min(1),
  state: z.string().length(2),
  postalCode: z.string().regex(/^\d{5}(-\d{4})?$/),
  country: z.string().default('US'),
});

const ContactSchema = z.object({
  name: z.string().min(1).max(100),
  email: z.string().email(),
  phone: z.string().optional(),
  address: AddressSchema,
  billingAddress: AddressSchema.optional(),
});

const CreateOrderSchema = z.object({
  contact: ContactSchema,
  items: z.array(
    z.object({
      productId: z.string().uuid(),
      quantity: z.number().int().positive(),
      unitPrice: z.number().positive(),
    })
  ).min(1),
  notes: z.string().max(500).optional(),
});

type CreateOrderInput = z.infer<typeof CreateOrderSchema>;
```

**Key Points:**

- Named sub-schemas (`AddressSchema`, `ContactSchema`) are reusable across multiple procedures and composable with `.extend()`, `.partial()`, `.merge()`
- Zod validates the full depth of the tree — an invalid `postalCode` inside `contact.address` produces an error at path `['contact', 'address', 'postalCode']`
- Deep nesting is legitimate but deeply nested error paths can be harder to surface to the client; flatten where possible

---

### Arrays of Objects

Arrays of typed objects are the backbone of bulk mutation inputs.

```typescript
const BulkUpsertUsersSchema = z.object({
  users: z
    .array(
      z.object({
        id: z.string().uuid().optional(), // optional for creates
        email: z.string().email(),
        name: z.string().min(1),
        role: z.enum(['admin', 'user', 'moderator']).default('user'),
        metadata: z.record(z.string(), z.unknown()).optional(),
      })
    )
    .min(1)
    .max(500),
  upsertStrategy: z.enum(['merge', 'replace']).default('merge'),
});
```

#### Uniqueness Validation Across Array Items

Zod does not have a built-in unique constraint for arrays. Use `superRefine`:

```typescript
const BulkUpsertUsersSchema = z.object({
  users: z.array(
    z.object({
      email: z.string().email(),
      name: z.string().min(1),
    })
  ).min(1),
}).superRefine(({ users }, ctx) => {
  const emails = users.map((u) => u.email);
  const duplicates = emails.filter((e, i) => emails.indexOf(e) !== i);

  duplicates.forEach((email) => {
    ctx.addIssue({
      code: z.ZodIssueCode.custom,
      path: ['users'],
      message: `Duplicate email in batch: ${email}`,
    });
  });
});
```

---

### Recursive Schemas

Recursive schemas describe tree-like structures where a node may contain children of the same type — common for categories, comments, menus, and permission trees.

Zod requires `z.lazy()` to handle self-referential schemas, because the schema variable is referenced before it is fully defined.

```typescript
type Category = {
  id: string;
  name: string;
  children: Category[];
};

const CategorySchema: z.ZodType<Category> = z.lazy(() =>
  z.object({
    id: z.string().uuid(),
    name: z.string().min(1).max(100),
    children: z.array(CategorySchema).default(() => []),
  })
);
```

**Example in tRPC:**

```typescript
const createCategory = t.procedure
  .input(
    z.object({
      tree: CategorySchema,
    })
  )
  .mutation(async ({ input }) => {
    return persistCategoryTree(input.tree);
  });
```

**Key Points:**

- The explicit `z.ZodType<T>` annotation is required for TypeScript to resolve the circular reference — without it, the type inference loop causes a compile error
- `z.lazy()` defers schema construction until parse time, which allows self-reference
- Recursive schemas carry a risk of stack overflow for deeply nested inputs [Inference: depth limits depend on runtime call stack size]; consider adding a depth guard via `superRefine` for untrusted input

#### Depth Guard for Recursive Input

```typescript
function validateDepth(node: Category, maxDepth: number, current = 0): boolean {
  if (current > maxDepth) return false;
  return node.children.every((child) =>
    validateDepth(child, maxDepth, current + 1)
  );
}

const SafeCategorySchema = z.object({ tree: CategorySchema }).superRefine(
  ({ tree }, ctx) => {
    if (!validateDepth(tree, 10)) {
      ctx.addIssue({
        code: z.ZodIssueCode.custom,
        path: ['tree'],
        message: 'Category tree exceeds maximum depth of 10.',
      });
    }
  }
);
```

---

### Discriminated Unions for Polymorphic Input

When a procedure must accept one of several structurally distinct input shapes, discriminated unions provide both runtime validation and precise TypeScript narrowing.

```typescript
const CreateNotificationSchema = z.discriminatedUnion('channel', [
  z.object({
    channel: z.literal('email'),
    to: z.string().email(),
    subject: z.string().min(1),
    body: z.string().min(1),
    replyTo: z.string().email().optional(),
  }),
  z.object({
    channel: z.literal('sms'),
    to: z.string().regex(/^\+[1-9]\d{1,14}$/),
    body: z.string().max(160),
  }),
  z.object({
    channel: z.literal('push'),
    deviceToken: z.string().min(1),
    title: z.string().max(65),
    body: z.string().max(240),
    data: z.record(z.string()).optional(),
  }),
]);

const sendNotification = t.procedure
  .input(CreateNotificationSchema)
  .mutation(async ({ input }) => {
    // TypeScript narrows input based on input.channel
    switch (input.channel) {
      case 'email':
        return emailService.send(input);    // input.to, input.subject available
      case 'sms':
        return smsService.send(input);      // input.to, input.body available
      case 'push':
        return pushService.send(input);     // input.deviceToken available
    }
  });
```

**Key Points:**

- The discriminant key (`channel`) must be a `z.literal()` in each branch
- TypeScript narrows `input` inside each `case` — accessing `input.subject` in the `sms` branch is a compile error
- Discriminated union error messages specify which branches were attempted and why each failed, making debugging easier than plain `z.union()`

---

### Nested Discriminated Unions

Discriminated unions can be nested within objects, arrays, or other unions to model complex event-driven or command-pattern inputs.

```typescript
const ActionSchema = z.discriminatedUnion('type', [
  z.object({
    type: z.literal('user.create'),
    payload: z.object({
      email: z.string().email(),
      role: z.enum(['admin', 'user']),
    }),
  }),
  z.object({
    type: z.literal('user.delete'),
    payload: z.object({
      userId: z.string().uuid(),
      hardDelete: z.boolean().default(false),
    }),
  }),
  z.object({
    type: z.literal('post.publish'),
    payload: z.object({
      postId: z.string().uuid(),
      publishAt: z.coerce.date().optional(),
    }),
  }),
]);

const BatchActionsSchema = z.object({
  actions: z.array(ActionSchema).min(1).max(50),
  transactional: z.boolean().default(true),
});
```

---

### Conditional Schemas with `z.union` and `.superRefine`

When fields are conditionally required based on the value of another field — and a discriminated union is not a clean fit — use `superRefine` to express the conditional logic.

```typescript
const PaymentSchema = z
  .object({
    method: z.enum(['card', 'bank_transfer', 'crypto']),
    // card fields
    cardNumber: z.string().optional(),
    cardExpiry: z.string().optional(),
    cardCvv: z.string().optional(),
    // bank fields
    accountNumber: z.string().optional(),
    routingNumber: z.string().optional(),
    // crypto fields
    walletAddress: z.string().optional(),
    network: z.enum(['ethereum', 'bitcoin', 'solana']).optional(),
  })
  .superRefine((data, ctx) => {
    if (data.method === 'card') {
      if (!data.cardNumber) {
        ctx.addIssue({
          code: z.ZodIssueCode.custom,
          path: ['cardNumber'],
          message: 'Card number is required for card payments.',
        });
      }
      if (!data.cardExpiry) {
        ctx.addIssue({
          code: z.ZodIssueCode.custom,
          path: ['cardExpiry'],
          message: 'Card expiry is required for card payments.',
        });
      }
    }

    if (data.method === 'bank_transfer') {
      if (!data.accountNumber) {
        ctx.addIssue({
          code: z.ZodIssueCode.custom,
          path: ['accountNumber'],
          message: 'Account number is required for bank transfers.',
        });
      }
    }

    if (data.method === 'crypto') {
      if (!data.walletAddress) {
        ctx.addIssue({
          code: z.ZodIssueCode.custom,
          path: ['walletAddress'],
          message: 'Wallet address is required for crypto payments.',
        });
      }
      if (!data.network) {
        ctx.addIssue({
          code: z.ZodIssueCode.custom,
          path: ['network'],
          message: 'Network is required for crypto payments.',
        });
      }
    }
  });
```

**Key Points:**

- This pattern is a pragmatic alternative to discriminated unions when the type system would become unwieldy [Inference]
- All issues collected by `ctx.addIssue()` are batched into a single `ZodError`, so the client receives all missing field errors at once — not just the first one
- Prefer discriminated unions when the shapes are sufficiently distinct; use `superRefine` when shapes share many optional fields

---

### Partial and Deep Partial for Update Mutations

Update (PATCH-style) mutations typically require only a subset of fields. Zod's `.partial()` and `.deepPartial()` make this ergonomic.

```typescript
const UserSchema = z.object({
  name: z.string().min(1),
  email: z.string().email(),
  address: z.object({
    street: z.string(),
    city: z.string(),
    postalCode: z.string(),
  }),
  role: z.enum(['admin', 'user']),
});

// Shallow partial: top-level fields become optional
const UpdateUserSchema = z.object({
  id: z.string().uuid(),
}).merge(UserSchema.partial());
// id is required; name, email, address, role are all optional

// Deep partial: all fields at all levels become optional
const DeepUpdateUserSchema = z.object({
  id: z.string().uuid(),
}).merge(UserSchema.deepPartial());
// address.street, address.city etc. are also optional
```

**Example in tRPC:**

```typescript
const updateUser = t.procedure
  .input(
    z.object({ id: z.string().uuid() }).merge(UserSchema.partial())
  )
  .mutation(async ({ input }) => {
    const { id, ...data } = input;

    // Only provided fields are present in `data`
    return db.user.update({
      where: { id },
      data,
    });
  });
```

**Key Points:**

- `.partial()` makes fields `T | undefined`, not optional object keys, in some TypeScript contexts — behavior is consistent in practice but worth verifying with `z.infer<>` [Inference]
- `.deepPartial()` is marked as experimental in some Zod versions — verify behavior in your version [Unverified]
- Always keep the identifier (e.g., `id`) required in update schemas; partial only applies to the mutable fields

---

### Schema Composition Patterns

#### The Base + Variant Pattern

```typescript
// Base schema with fields common to all variants
const BaseEventSchema = z.object({
  id: z.string().uuid().default(() => crypto.randomUUID()),
  occurredAt: z.coerce.date().default(() => new Date()),
  correlationId: z.string().uuid().optional(),
});

// Domain-specific variants extend the base
const UserCreatedEventSchema = BaseEventSchema.extend({
  type: z.literal('user.created'),
  userId: z.string().uuid(),
  email: z.string().email(),
});

const OrderPlacedEventSchema = BaseEventSchema.extend({
  type: z.literal('order.placed'),
  orderId: z.string().uuid(),
  totalAmount: z.number().positive(),
  currency: z.string().length(3),
});

// Combined union for an event ingestion procedure
const IngestEventSchema = z.discriminatedUnion('type', [
  UserCreatedEventSchema,
  OrderPlacedEventSchema,
]);
```

#### The Input / Output Split Pattern

For procedures where the internal representation differs from what the client sends:

```typescript
// What the client sends
const CreatePostInputSchema = z.object({
  title: z.string().min(1).max(200),
  body: z.string().min(1),
  tags: z.array(z.string().toLowerCase().trim()).max(10).default(() => []),
  publishAt: z.coerce.date().optional(),
});

// What gets stored (extended with server-generated fields)
const PostRecordSchema = CreatePostInputSchema.extend({
  id: z.string().uuid(),
  authorId: z.string().uuid(),
  createdAt: z.date(),
  updatedAt: z.date(),
  slug: z.string(),
});

type CreatePostInput = z.infer<typeof CreatePostInputSchema>;
type PostRecord = z.infer<typeof PostRecordSchema>;
```

---

### Extracting Sub-Schemas

For deeply nested schemas, you can extract a sub-schema for reuse using `._def` internals or by simply exporting named schemas. The cleaner approach is named exports:

```typescript
// Define and export each layer
export const ItemSchema = z.object({
  productId: z.string().uuid(),
  quantity: z.number().int().positive(),
  price: z.number().positive(),
});

export const OrderSchema = z.object({
  items: z.array(ItemSchema).min(1),
  couponCode: z.string().optional(),
});

export type Item = z.infer<typeof ItemSchema>;
export type Order = z.infer<typeof OrderSchema>;

// Reuse ItemSchema in a separate procedure
const updateItem = t.procedure
  .input(z.object({ orderId: z.string().uuid(), item: ItemSchema }))
  .mutation(async ({ input }) => { /* ... */ });
```

---

### Error Path Mapping for Nested Schemas

When a nested schema fails, `ZodError` records the full path. This is particularly useful when surfacing field-level errors on the client.

```typescript
// Server: formatError with nested path support
const t = initTRPC.context<Context>().create({
  errorFormatter({ shape, error }) {
    return {
      ...shape,
      data: {
        ...shape.data,
        zodError:
          error.cause instanceof ZodError
            ? error.cause.flatten()
            : null,
        zodFieldErrors:
          error.cause instanceof ZodError
            ? error.cause.issues.map((issue) => ({
                path: issue.path.join('.'),  // e.g. "contact.address.postalCode"
                message: issue.message,
              }))
            : null,
      },
    };
  },
});

// Client: accessing nested error paths
try {
  await trpc.createOrder.mutate(payload);
} catch (err) {
  if (err instanceof TRPCClientError && err.data?.zodFieldErrors) {
    err.data.zodFieldErrors.forEach(({ path, message }) => {
      setFieldError(path, message); // e.g. react-hook-form setError
    });
  }
}
```

---

### Diagram: Nested Schema Validation Tree

<svg viewBox="0 0 700 340" xmlns="http://www.w3.org/2000/svg" font-family="monospace, sans-serif" font-size="12">
  <rect width="700" height="340" fill="#0f1117" rx="12"/>

  <!-- Root -->
  <rect x="270" y="16" width="160" height="38" rx="7" fill="#1e293b" stroke="#3b82f6" stroke-width="1.5"/>
  <text x="350" y="32" text-anchor="middle" fill="#93c5fd" font-weight="bold">CreateOrderSchema</text>
  <text x="350" y="47" text-anchor="middle" fill="#64748b" font-size="10">z.object()</text>

  <!-- Level 1 nodes -->
  <rect x="60" y="100" width="130" height="38" rx="7" fill="#1e293b" stroke="#334155" stroke-width="1.3"/>
  <text x="125" y="116" text-anchor="middle" fill="#94a3b8">contact</text>
  <text x="125" y="131" text-anchor="middle" fill="#64748b" font-size="10">ContactSchema</text>

  <rect x="270" y="100" width="160" height="38" rx="7" fill="#1e293b" stroke="#334155" stroke-width="1.3"/>
  <text x="350" y="116" text-anchor="middle" fill="#94a3b8">items</text>
  <text x="350" y="131" text-anchor="middle" fill="#64748b" font-size="10">z.array(ItemSchema)</text>

  <rect x="510" y="100" width="130" height="38" rx="7" fill="#1e293b" stroke="#334155" stroke-width="1.3"/>
  <text x="575" y="116" text-anchor="middle" fill="#94a3b8">notes</text>
  <text x="575" y="131" text-anchor="middle" fill="#64748b" font-size="10">z.string().optional()</text>

  <!-- Level 2 from contact -->
  <rect x="16" y="200" width="130" height="38" rx="7" fill="#1e293b" stroke="#334155" stroke-width="1.1"/>
  <text x="81" y="216" text-anchor="middle" fill="#94a3b8">address</text>
  <text x="81" y="231" text-anchor="middle" fill="#64748b" font-size="10">AddressSchema</text>

  <rect x="160" y="200" width="130" height="38" rx="7" fill="#1e293b" stroke="#334155" stroke-width="1.1"/>
  <text x="225" y="216" text-anchor="middle" fill="#94a3b8">email, name…</text>
  <text x="225" y="231" text-anchor="middle" fill="#64748b" font-size="10">z.string() etc.</text>

  <!-- Level 2 from items -->
  <rect x="310" y="200" width="130" height="38" rx="7" fill="#1e293b" stroke="#334155" stroke-width="1.1"/>
  <text x="375" y="216" text-anchor="middle" fill="#94a3b8">productId</text>
  <text x="375" y="231" text-anchor="middle" fill="#64748b" font-size="10">z.string().uuid()</text>

  <!-- Level 3 from address -->
  <rect x="60" y="290" width="130" height="34" rx="7" fill="#1e293b" stroke="#334155" stroke-width="1"/>
  <text x="125" y="306" text-anchor="middle" fill="#94a3b8">street, city…</text>
  <text x="125" y="320" text-anchor="middle" fill="#64748b" font-size="10">z.string() primitives</text>

  <!-- Connector lines -->
  <!-- root to contact -->
  <line x1="320" y1="54" x2="175" y2="100" stroke="#334155" stroke-width="1.2"/>
  <!-- root to items -->
  <line x1="350" y1="54" x2="350" y2="100" stroke="#334155" stroke-width="1.2"/>
  <!-- root to notes -->
  <line x1="380" y1="54" x2="525" y2="100" stroke="#334155" stroke-width="1.2"/>
  <!-- contact to address -->
  <line x1="100" y1="138" x2="81" y2="200" stroke="#334155" stroke-width="1.1"/>
  <!-- contact to email/name -->
  <line x1="150" y1="138" x2="225" y2="200" stroke="#334155" stroke-width="1.1"/>
  <!-- items to productId -->
  <line x1="350" y1="138" x2="375" y2="200" stroke="#334155" stroke-width="1.1"/>
  <!-- address to primitives -->
  <line x1="81" y1="238" x2="125" y2="290" stroke="#334155" stroke-width="1"/>

  <!-- Error path annotation -->
  <text x="16" y="274" fill="#f59e0b" font-size="10">[contact.address.postalCode]</text>
</svg>

---

### Summary

| Pattern                      | Zod Mechanism                               | Use Case                                              |
|------------------------------|---------------------------------------------|-------------------------------------------------------|
| Nested objects               | `z.object()` inside `z.object()`            | Structured inputs with sub-entities                   |
| Arrays of objects            | `z.array(z.object({}))`                     | Bulk mutations, line items                            |
| Uniqueness across array      | `.superRefine()` with set check             | Batch upserts, deduplication                          |
| Recursive structures         | `z.lazy()` + `z.ZodType<T>` annotation      | Trees, categories, nested comments                    |
| Polymorphic input            | `z.discriminatedUnion()`                    | Multi-channel actions, command patterns               |
| Conditional required fields  | `.superRefine()` with `ctx.addIssue()`      | Payment methods, feature-flagged fields               |
| Partial updates              | `.partial()`, `.deepPartial()`              | PATCH-style mutations                                 |
| Base + variant composition   | `.extend()`, `.merge()`                     | Shared fields across related schemas                  |
| Error path surfacing         | `ZodError.issues[].path`, `.flatten()`      | Field-level client error display                      |

**Conclusion**

Complex nested Zod schemas in tRPC are built by composing primitives into named, reusable schema units and linking them with `z.object()`, `z.array()`, `z.lazy()`, and discriminated unions. The key discipline is naming and exporting sub-schemas rather than inlining everything — this enables reuse across procedures, keeps `z.infer<>` types readable, and makes error path mapping tractable. Behavior of `.deepPartial()` and recursive schemas under edge conditions may vary by Zod version and should be verified in context.