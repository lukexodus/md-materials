## Input Sanitization in tRPC

---

### What Input Sanitization Means in This Context

Input sanitization refers to the practice of validating, cleaning, and rejecting untrusted data before it is used in application logic. In tRPC, all procedure inputs pass through a schema validation step, which is the primary mechanism for enforcing input constraints.

**Key Points:**
- tRPC does not sanitize input automatically — it delegates to whichever validation library is used in the schema
- Validation rejects malformed input; sanitization transforms or strips unsafe content
- Both are necessary and serve different purposes; tRPC supports both through its schema layer

---

### The Role of Zod as the Sanitization Layer

Zod is the most commonly used schema library with tRPC. Beyond type checking, Zod provides transformation, coercion, and constraint enforcement that together constitute sanitization.

```typescript
import { z } from 'zod';

const inputSchema = z.object({
  username: z.string().trim().min(3).max(32),
  email: z.string().email().toLowerCase(),
  age: z.number().int().min(0).max(120),
});
```

**Key Points:**
- `.trim()` removes leading and trailing whitespace
- `.toLowerCase()` normalizes email casing
- `.min()` / `.max()` enforce length and value bounds
- These transformations occur before procedure logic runs

**Output** (after parse):
```typescript
{
  username: "alice",       // whitespace stripped
  email: "alice@example.com",  // lowercased
  age: 30
}
```

---

### Rejecting vs. Transforming Input

Zod supports two distinct approaches: rejection (throw an error on invalid input) and transformation (coerce or clean the input silently). Both are useful in different contexts.

**Rejection — strict validation:**
```typescript
const schema = z.object({
  status: z.enum(['active', 'inactive']),
  count: z.number().int().positive(),
});
```
Any input not matching these constraints causes tRPC to return a `BAD_INPUT` error before the procedure body executes.

**Transformation — clean and normalize:**
```typescript
const schema = z.object({
  tags: z
    .array(z.string().trim().toLowerCase())
    .transform((tags) => [...new Set(tags)]), // deduplicate
  bio: z.string().trim().max(500).optional(),
});
```

**Key Points:**
- Prefer rejection for structured or enumerable values where unexpected input should be surfaced
- Prefer transformation for user-supplied freeform text where normalization is expected
- [Inference] Mixing both approaches in the same schema is common and generally workable, though the resulting behavior should be documented so procedure authors know what shape the input will be in

---

### Preventing Oversized Payloads

Without size constraints, a procedure accepting a string or array has no upper bound on what a caller can send. Zod constraints address this at the schema level.

```typescript
const schema = z.object({
  title: z.string().max(200),
  body: z.string().max(10_000),
  attachmentIds: z.array(z.string().uuid()).max(10),
});
```

**Key Points:**
- `.max()` on strings limits character count
- `.max()` on arrays limits element count
- These limits are enforced before any database or service call is made
- [Inference] Schema-level limits do not replace HTTP-level body size limits (e.g., `express.json({ limit: '1mb' })`); both layers are advisable

---

### HTTP Body Size Limits at the Server Level

Schema validation occurs after the request body has already been parsed. To prevent excessively large payloads from reaching the application layer at all, body size limits should be configured at the HTTP server level.

```typescript
// Express
app.use(express.json({ limit: '256kb' }));

app.use(
  '/trpc',
  trpcExpress.createExpressMiddleware({
    router: appRouter,
    createContext,
  })
);
```

**Key Points:**
- The body size limit is enforced by the HTTP framework, not by tRPC
- This limit should be set before the tRPC middleware is mounted
- [Inference] The appropriate limit depends on the largest legitimate payload your procedures accept; there is no universally correct value

---

### Sanitizing Free-Form Text for HTML Contexts

If procedure output is rendered as HTML in a client, free-form text fields accepted as input may need HTML sanitization. tRPC does not perform this automatically.

For server-side sanitization before storage:

```typescript
import DOMPurify from 'isomorphic-dompurify';

const schema = z.object({
  content: z.string().transform((val) => DOMPurify.sanitize(val)),
});
```

**Key Points:**
- HTML sanitization is only necessary if the value will be rendered as HTML
- If values are stored as plain text and escaped at render time by the frontend framework (e.g., React's default behavior), server-side HTML sanitization may not be required
- [Inference] Where sanitization occurs (server vs. client vs. both) depends on the rendering pipeline; there is no single correct answer applicable to all projects
- Behavior of third-party sanitization libraries is not guaranteed to cover all edge cases; consult the library's documentation and security advisories

---

### Guarding Against Mass Assignment

Mass assignment occurs when a caller supplies more fields than intended, and the application uses the entire input object without restriction. Zod's `.strict()` modifier rejects any keys not defined in the schema.

```typescript
const updateUserSchema = z.object({
  displayName: z.string().max(100),
  bio: z.string().max(500).optional(),
}).strict(); // rejects unknown keys
```

**Example** — if a caller sends:
```json
{ "displayName": "Alice", "bio": "Hi", "role": "admin" }
```

The `role` field is rejected and a `BAD_INPUT` error is returned before the procedure runs.

**Key Points:**
- Without `.strict()`, Zod silently strips unknown keys by default (`.strip()` behavior)
- `.strip()` is safer than passing raw input to a database, but `.strict()` makes the rejection explicit and auditable
- [Inference] `.strict()` is advisable for mutation procedures where unexpected fields could affect downstream logic, though it may require more maintenance as schemas evolve

---

### Sanitizing Nested and Recursive Inputs

Schemas that accept nested objects or arrays should apply sanitization at every level, not just the top level.

```typescript
const commentSchema = z.object({
  text: z.string().trim().max(1000),
  metadata: z.object({
    source: z.enum(['web', 'mobile', 'api']),
    tags: z.array(z.string().trim().toLowerCase()).max(5),
  }).strict(),
});
```

**Key Points:**
- Constraints must be declared at each level of nesting explicitly
- A top-level `.strict()` does not propagate to nested objects
- [Inference] Deeply nested schemas with inconsistent validation at inner levels are a common source of gaps; reviewing schemas at all levels is advisable

---

### Using `.superRefine()` for Custom Validation Logic

Zod's `.superRefine()` allows custom validation rules that go beyond type and constraint checks.

```typescript
const passwordSchema = z.object({
  password: z.string().min(8).max(128),
  confirmPassword: z.string(),
}).superRefine((data, ctx) => {
  if (data.password !== data.confirmPassword) {
    ctx.addIssue({
      code: z.ZodIssueCode.custom,
      message: 'Passwords do not match',
      path: ['confirmPassword'],
    });
  }
});
```

**Key Points:**
- `.superRefine()` runs after all field-level validations pass
- Errors are attached to specific paths, which tRPC surfaces in its error response
- Custom rules can encode business constraints (e.g., no profanity, no reserved usernames) in the schema layer rather than in procedure logic

---

### Sanitization in Middleware vs. Schema

Sanitization logic can live in the Zod schema, in tRPC middleware, or in the procedure body. Each placement has trade-offs.

| Location | Pros | Cons |
|---|---|---|
| Zod schema | Colocated with type definition; runs automatically | Limited to what Zod supports natively |
| tRPC middleware | Applies across multiple procedures | Input type at this stage is `unknown`; harder to type-safely transform |
| Procedure body | Full access to context and services | Duplicated across procedures; runs after input is already accepted |

**Key Points:**
- Schema-level sanitization is preferred for structural and format concerns
- Middleware-level sanitization is appropriate for cross-cutting concerns (e.g., rate limiting, logging sanitization)
- Procedure-body sanitization is a last resort and should be minimized
- [Inference] Splitting sanitization across all three layers without documentation increases the chance of gaps or duplicate processing

---

### What tRPC Does Not Handle

**Key Points:**
- tRPC does not escape SQL — use parameterized queries or an ORM
- tRPC does not sanitize file uploads — file handling is outside its scope
- tRPC does not enforce rate limits natively — these must be added via middleware or infrastructure
- tRPC does not validate input on the client side on behalf of the server — client-side Zod validation is a convenience only; server-side validation is always required

---

**Conclusion**

Input sanitization in tRPC is primarily handled through the schema validation layer, most commonly Zod. Rejection enforces structural correctness; transformation normalizes freeform input. HTTP-level body size limits complement schema-level constraints by preventing oversized payloads from reaching application code. Mass assignment is addressed with `.strict()`. Free-form text destined for HTML rendering requires a dedicated sanitization library. No single layer is sufficient on its own — effective sanitization combines server-level, schema-level, and application-level controls.