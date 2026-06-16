## Throwing Errors in Procedures

### Overview

Throwing errors in tRPC procedures is the primary way to communicate failure conditions from the server to the client in a structured, typed manner. Errors can be thrown at any point inside a query, mutation, or subscription procedure body. tRPC intercepts these throws and serializes them into its error response format before they reach the client.

---

### Basic Error Throw

The minimal form requires only a `code`.

```ts
import { TRPCError } from '@trpc/server';

const appRouter = router({
  ping: publicProcedure.query(() => {
    throw new TRPCError({ code: 'INTERNAL_SERVER_ERROR' });
  }),
});
```

---

### Throwing After Input Validation

The most common pattern is throwing after a database lookup or business logic check fails, following successful input validation by Zod (or another parser).

**Example**

```ts
const appRouter = router({
  getPost: publicProcedure
    .input(z.object({ id: z.string().uuid() }))
    .query(async ({ input }) => {
      const post = await db.post.findUnique({ where: { id: input.id } });

      if (!post) {
        throw new TRPCError({
          code: 'NOT_FOUND',
          message: `Post "${input.id}" does not exist.`,
        });
      }

      return post;
    }),
});
```

**Key Points**
- Input validation errors from Zod are automatically converted to `BAD_REQUEST` by tRPC — you do not need to throw these manually
- Manual throws handle business logic failures that Zod cannot express

---

### Throwing in Mutations

Mutations follow the same pattern. Throws are appropriate for conflict detection, authorization checks, or downstream failures.

**Example**

```ts
const appRouter = router({
  createUser: publicProcedure
    .input(z.object({ email: z.string().email() }))
    .mutation(async ({ input }) => {
      const existing = await db.user.findUnique({
        where: { email: input.email },
      });

      if (existing) {
        throw new TRPCError({
          code: 'CONFLICT',
          message: 'A user with this email already exists.',
        });
      }

      return db.user.create({ data: { email: input.email } });
    }),
});
```

---

### Throwing Conditionally Based on Context

Procedures have access to `ctx`, making it straightforward to throw based on the authenticated user's state or role.

**Example**

```ts
const appRouter = router({
  deletePost: publicProcedure
    .input(z.object({ id: z.string() }))
    .mutation(async ({ input, ctx }) => {
      if (!ctx.user) {
        throw new TRPCError({
          code: 'UNAUTHORIZED',
          message: 'Authentication required.',
        });
      }

      const post = await db.post.findUnique({ where: { id: input.id } });

      if (!post) {
        throw new TRPCError({ code: 'NOT_FOUND' });
      }

      if (post.authorId !== ctx.user.id) {
        throw new TRPCError({
          code: 'FORBIDDEN',
          message: 'You do not own this post.',
        });
      }

      return db.post.delete({ where: { id: input.id } });
    }),
});
```

**Key Points**
- `UNAUTHORIZED` — no session or token present
- `FORBIDDEN` — session exists but lacks permission
- These are semantically distinct and should not be used interchangeably

---

### Wrapping External Errors

When calling third-party services or databases, wrap caught errors in a `TRPCError` to control what the client receives.

**Example**

```ts
const appRouter = router({
  sendEmail: publicProcedure
    .input(z.object({ to: z.string().email() }))
    .mutation(async ({ input }) => {
      try {
        await emailService.send({ to: input.to });
      } catch (err) {
        throw new TRPCError({
          code: 'INTERNAL_SERVER_ERROR',
          message: 'Failed to send email. Please try again.',
          cause: err,
        });
      }
    }),
});
```

**Key Points**
- The raw `err` from the email service is attached as `cause` and is accessible in server-side error formatters
- The client receives only the controlled `message` and `code`
- [Inference] Without wrapping, the raw error would surface as an unformatted `INTERNAL_SERVER_ERROR` with no meaningful message. Behavior may vary depending on your error formatter.

---

### Throwing in Async Procedures

Throws inside `async` procedure bodies work the same as synchronous throws. tRPC awaits the procedure and catches rejections.

**Example**

```ts
const appRouter = router({
  fetchData: publicProcedure.query(async () => {
    const result = await someAsyncOperation();

    if (!result.ok) {
      throw new TRPCError({
        code: 'BAD_GATEWAY',
        message: 'Upstream service returned an error.',
      });
    }

    return result.data;
  }),
});
```

---

### Multiple Throw Points in One Procedure

A single procedure may have several throw points, each representing a distinct failure mode. Each throw short-circuits execution — no further code in the procedure runs after a throw.

**Example**

```ts
const appRouter = router({
  transferFunds: publicProcedure
    .input(z.object({ fromId: z.string(), toId: z.string(), amount: z.number().positive() }))
    .mutation(async ({ input, ctx }) => {
      if (!ctx.user) {
        throw new TRPCError({ code: 'UNAUTHORIZED' });
      }

      const source = await db.account.findUnique({ where: { id: input.fromId } });
      if (!source) {
        throw new TRPCError({ code: 'NOT_FOUND', message: 'Source account not found.' });
      }

      if (source.ownerId !== ctx.user.id) {
        throw new TRPCError({ code: 'FORBIDDEN', message: 'Access denied.' });
      }

      if (source.balance < input.amount) {
        throw new TRPCError({
          code: 'BAD_REQUEST',
          message: 'Insufficient balance.',
        });
      }

      return db.transfer(input.fromId, input.toId, input.amount);
    }),
});
```

---

### What Happens When You Do Not Throw TRPCError

| Scenario | Client Receives |
|---|---|
| `throw new TRPCError({ code: 'NOT_FOUND' })` | `NOT_FOUND` with your message |
| `throw new Error('oops')` | `INTERNAL_SERVER_ERROR`, generic message |
| `return undefined` (no throw) | Successful response with `undefined` data |
| Unhandled promise rejection | `INTERNAL_SERVER_ERROR` |

[Inference] tRPC catches unhandled rejections within the procedure's execution scope. Whether rejections outside that scope (e.g., in detached async chains) are caught depends on the runtime and adapter. Behavior is not guaranteed.

---

### Zod Validation Errors vs Manual Throws

tRPC automatically converts Zod `ZodError` instances to `BAD_REQUEST` responses. This means input shape failures do not require manual throws.

**Example — automatic**

```ts
// Zod rejects this automatically if input.id is not a string
.input(z.object({ id: z.string() }))
```

**Example — manual (semantic validation Zod cannot express)**

```ts
if (input.startDate >= input.endDate) {
  throw new TRPCError({
    code: 'BAD_REQUEST',
    message: 'Start date must be before end date.',
  });
}
```

**Key Points**
- Structural and type validation → Zod handles automatically
- Business rule validation → throw manually with appropriate code
- Both produce `BAD_REQUEST` on the client; the distinction is server-side responsibility

---

### Throw Placement Summary

```
procedure body
│
├── ctx check          → UNAUTHORIZED / FORBIDDEN
├── input.fetch()      → NOT_FOUND
├── conflict check     → CONFLICT
├── business rule      → BAD_REQUEST / PRECONDITION_FAILED / UNPROCESSABLE_CONTENT
├── external call      → BAD_GATEWAY / SERVICE_UNAVAILABLE / TIMEOUT
└── unknown            → INTERNAL_SERVER_ERROR (let tRPC handle or wrap explicitly)
```

---

**Conclusion**

Throwing `TRPCError` inside procedures is the correct and complete mechanism for structured error communication in tRPC. Each throw point should correspond to a distinct, intentional failure condition with the most semantically appropriate error code. Unhandled or wrapped native errors default to `INTERNAL_SERVER_ERROR`. Keeping throw logic explicit and contextually placed makes error handling on the client predictable and type-safe.

**Next Steps** — Custom error formatters and shaping the error payload sent to the client.