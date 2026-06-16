## Preventing Over-Fetching and Over-Posting

---

### Definitions in the tRPC Context

**Over-fetching** occurs when a procedure returns more data than the caller needs. The client receives fields it does not use, wasting bandwidth, increasing payload size, and potentially exposing data that should not leave the server.

**Over-posting** occurs when a caller sends more data than a procedure should accept. The server receives fields beyond what the operation requires, which may silently affect stored records, bypass intended constraints, or widen the attack surface.

**Key Points:**
- Both problems are about boundary discipline — controlling exactly what crosses the client-server boundary
- tRPC does not prevent either automatically; both require deliberate schema and procedure design
- The type system provides compile-time visibility but does not enforce runtime output shape unless an output schema is explicitly defined

---

### Over-Posting: Accepting Only What Is Needed

The most direct cause of over-posting is an input schema that is too permissive or absent. Every mutation procedure should define an input schema that contains only the fields the operation legitimately requires.

**Problematic pattern — accepting a full entity object:**
```typescript
const updateUserSchema = z.object({
  id: z.string().uuid(),
  name: z.string(),
  email: z.string().email(),
  role: z.string(),         // should not be user-supplied
  createdAt: z.string(),    // should not be user-supplied
  passwordHash: z.string(), // should never be user-supplied
});
```

**Corrected pattern — accepting only mutable, user-owned fields:**
```typescript
const updateUserSchema = z.object({
  name: z.string().trim().max(100),
  email: z.string().email().toLowerCase(),
}).strict(); // reject any keys not listed above
```

**Key Points:**
- Fields like `role`, `createdAt`, and `passwordHash` are derived or privileged — they must not appear in user-facing input schemas
- `.strict()` rejects unknown keys explicitly rather than silently stripping them
- The `id` of the resource being modified is typically sourced from the authenticated session context, not from the request body

---

### Sourcing Identity From Context, Not Input

A common over-posting vector is accepting a caller-supplied user ID to identify whose record to modify. If a caller can supply any ID, they may be able to modify records they do not own.

**Problematic pattern:**
```typescript
updateProfile: t.procedure
  .input(z.object({
    userId: z.string(), // caller controls whose record is updated
    bio: z.string().max(500),
  }))
  .mutation(async ({ input, ctx }) => {
    await db.user.update({ where: { id: input.userId }, data: { bio: input.bio } });
  }),
```

**Corrected pattern:**
```typescript
updateProfile: t.procedure
  .input(z.object({
    bio: z.string().trim().max(500),
  }))
  .mutation(async ({ input, ctx }) => {
    // identity comes from authenticated session, not input
    await db.user.update({ where: { id: ctx.user.id }, data: { bio: input.bio } });
  }),
```

**Key Points:**
- The authenticated user's identity should come from `ctx`, not from `input`
- [Inference] This pattern reduces the risk of insecure direct object reference (IDOR) vulnerabilities, though complete protection depends on how `ctx` is constructed and validated
- Behavior depends on correct implementation of the `createContext` function; this is not enforced by tRPC itself

---

### Separate Input Schemas for Create vs. Update

Using a single schema for both create and update operations often forces the schema to be more permissive than either operation requires individually.

```typescript
// Create — all required fields supplied by the caller
const createPostSchema = z.object({
  title: z.string().trim().min(1).max(200),
  body: z.string().trim().min(1).max(10_000),
  categoryId: z.string().uuid(),
});

// Update — only fields the caller may change; partial to allow selective updates
const updatePostSchema = z.object({
  title: z.string().trim().min(1).max(200).optional(),
  body: z.string().trim().min(1).max(10_000).optional(),
}).strict();

// The post ID for update comes from a separate input field or context
const updatePostInput = z.object({
  postId: z.string().uuid(),
  data: updatePostSchema,
});
```

**Key Points:**
- The update schema deliberately excludes `categoryId` if recategorization is not a permitted operation
- Separate schemas make permitted operations explicit and auditable
- [Inference] Sharing a base schema with `.pick()` or `.omit()` is a common pattern to reduce repetition, though each derived schema should still be reviewed independently for what it permits

---

### Over-Fetching: Controlling What Procedures Return

tRPC does not enforce an output schema by default. Without one, the procedure can return any shape, including sensitive fields that happen to be present on a database model.

**Problematic pattern — returning the full database record:**
```typescript
getUser: t.procedure
  .input(z.object({ id: z.string().uuid() }))
  .query(async ({ input }) => {
    return await db.user.findUnique({ where: { id: input.id } });
    // returns: id, name, email, passwordHash, twoFactorSecret, internalNotes, ...
  }),
```

**Key Points:**
- The full ORM model includes fields that should not be sent to clients
- TypeScript types reflecting the full model offer no runtime protection

---

### Approach 1: Explicit Field Selection at the Query Level

The most direct approach is to select only the required fields at the database query level, so sensitive fields are never loaded into memory.

```typescript
getUser: t.procedure
  .input(z.object({ id: z.string().uuid() }))
  .query(async ({ input }) => {
    return await db.user.findUnique({
      where: { id: input.id },
      select: {
        id: true,
        name: true,
        email: true,
        createdAt: true,
        // passwordHash, twoFactorSecret, internalNotes — not selected
      },
    });
  }),
```

**Key Points:**
- Fields not selected are never fetched from the database, reducing both exposure and query cost
- This approach is specific to ORMs with field selection support (e.g., Prisma)
- [Inference] Selecting fields at query level is generally preferable to fetching and then stripping, as it avoids loading sensitive data into the process at all

---

### Approach 2: Output Schema Validation

tRPC supports an `.output()` schema that validates and strips the procedure's return value at runtime. Fields not present in the output schema are removed from the response.

```typescript
const publicUserSchema = z.object({
  id: z.string().uuid(),
  name: z.string(),
  email: z.string().email(),
  createdAt: z.date(),
});

getUser: t.procedure
  .input(z.object({ id: z.string().uuid() }))
  .output(publicUserSchema)
  .query(async ({ input }) => {
    return await db.user.findUnique({ where: { id: input.id } });
    // passwordHash and other fields are stripped by the output schema
  }),
```

**Key Points:**
- The output schema acts as a contract — the response shape is enforced at runtime
- Fields present in the returned object but absent from the output schema are stripped before the response is sent
- The output schema also drives TypeScript inference on the client side
- [Inference] Output schemas add a validation pass on every response; the performance impact is generally negligible but depends on payload size and schema complexity — behavior may vary

---

### Approach 3: Manual Projection in the Procedure Body

When neither field selection nor an output schema is used, fields can be manually projected before returning.

```typescript
getUser: t.procedure
  .input(z.object({ id: z.string().uuid() }))
  .query(async ({ input }) => {
    const user = await db.user.findUnique({ where: { id: input.id } });
    if (!user) throw new TRPCError({ code: 'NOT_FOUND' });

    const { passwordHash, twoFactorSecret, ...publicFields } = user;
    return publicFields;
  }),
```

**Key Points:**
- Destructuring with rest spread is a common pattern for exclusion
- This approach is fragile — adding a new sensitive field to the model requires remembering to also exclude it here
- [Inference] Manual projection is the least reliable of the three approaches because it depends on the developer updating the exclusion list as the model evolves; output schemas or field selection are generally more maintainable

---

### Caller-Driven Field Selection

Some APIs allow callers to specify which fields they want returned, similar to GraphQL's selection sets. This can reduce over-fetching for clients with varying needs.

```typescript
const getUserInput = z.object({
  id: z.string().uuid(),
  fields: z.array(z.enum(['name', 'email', 'createdAt', 'bio'])).optional(),
});

getUser: t.procedure
  .input(getUserInput)
  .query(async ({ input }) => {
    const select = input.fields
      ? Object.fromEntries(input.fields.map((f) => [f, true]))
      : { name: true, email: true, createdAt: true, bio: true };

    return await db.user.findUnique({
      where: { id: input.id },
      select: { id: true, ...select },
    });
  }),
```

**Key Points:**
- The permitted field list is an enum — callers cannot request arbitrary fields
- Sensitive fields are excluded from the enum by construction
- [Inference] This pattern adds complexity and may not be necessary unless clients have genuinely divergent field requirements; it is not a common pattern in tRPC-first codebases

---

### Combining Input and Output Schemas

The most explicit and auditable approach combines strict input schemas (preventing over-posting) with output schemas (preventing over-fetching) on the same procedure.

```typescript
updateProfile: t.procedure
  .input(z.object({
    bio: z.string().trim().max(500),
    displayName: z.string().trim().max(100),
  }).strict())
  .output(z.object({
    id: z.string().uuid(),
    bio: z.string(),
    displayName: z.string(),
    updatedAt: z.date(),
  }))
  .mutation(async ({ input, ctx }) => {
    return await db.user.update({
      where: { id: ctx.user.id },
      data: input,
    });
  }),
```

**Key Points:**
- The input schema constrains what can be written
- The output schema constrains what is returned
- Together, they form a complete and auditable boundary definition for the procedure
- [Inference] This pattern increases schema maintenance burden but improves long-term auditability, particularly in regulated or security-sensitive applications

---

### Summary of Strategies

| Concern | Strategy | Where Applied |
|---|---|---|
| Over-posting — extra fields | `.strict()` on input schema | Input schema |
| Over-posting — privileged fields | Exclude from input schema entirely | Input schema |
| Over-posting — identity spoofing | Source ID from `ctx`, not `input` | Procedure body |
| Over-fetching — sensitive fields | Field selection in ORM query | Database query |
| Over-fetching — structural enforcement | `.output()` schema | Procedure definition |
| Over-fetching — ad hoc exclusion | Manual destructuring | Procedure body |

---

**Conclusion**

Over-fetching and over-posting are boundary discipline problems. tRPC provides the mechanisms to address both — strict input schemas, output schemas, and context-sourced identity — but none of these are applied automatically. Effective prevention requires deliberate schema design: input schemas that permit only what each operation legitimately requires, output schemas or field selection that limit what is returned, and identity derived from authenticated context rather than caller-supplied input. The combination of `.strict()` input schemas and explicit `.output()` schemas provides the most auditable and maintainable boundary definition.