## Procedure Factories and Reusable Builders

---

### Overview

As tRPC applications grow, repeating middleware chains, input validation logic, and output transforms across procedures becomes a maintenance liability. Procedure factories and reusable builders address this by allowing you to define a partially configured procedure once and derive multiple concrete procedures from it.

This pattern is built into tRPC's API. Every call to `.input()`, `.use()`, `.meta()`, or `.output()` on a procedure builder returns a **new, immutable builder instance**. This makes builders composable by design.

---

### How tRPC Procedure Builders Work

When you call `t.procedure`, you receive a base `ProcedurBuilder` instance. Every chained method returns a new builder — the original is not mutated.

```ts
// This is a builder, not a procedure
const base = t.procedure;

// Each of these is a new builder derived from base
const withAuth = base.use(authMiddleware);
const withAuthAndInput = withAuth.input(z.object({ id: z.string() }));
```

[Inference: immutability of builder instances is the documented design intent of tRPC v10+; actual runtime behavior should be verified against your installed version]

This immutability is what makes factories safe — a shared base builder can be extended in multiple directions without affecting other derivations.

---

### Defining a Base Procedure

The most common pattern is defining role-scoped base procedures in your tRPC initialization file:

```ts
// server/trpc.ts
import { initTRPC, TRPCError } from '@trpc/server';
import { z } from 'zod';
import type { Context } from './context';

const t = initTRPC.context<Context>().create();

export const router = t.router;
export const middleware = t.middleware;

// Public — no auth required
export const publicProcedure = t.procedure;

// Authenticated — requires valid session
export const protectedProcedure = t.procedure.use(({ ctx, next }) => {
  if (!ctx.session?.user) {
    throw new TRPCError({ code: 'UNAUTHORIZED' });
  }
  return next({
    ctx: {
      ...ctx,
      session: ctx.session, // session is now non-nullable in derived ctx
    },
  });
});

// Admin — requires authenticated user with admin role
export const adminProcedure = protectedProcedure.use(({ ctx, next }) => {
  if (ctx.session.user.role !== 'admin') {
    throw new TRPCError({ code: 'FORBIDDEN' });
  }
  return next({ ctx });
});
```

**Key Points:**

- `publicProcedure`, `protectedProcedure`, and `adminProcedure` are all builders, not finalized procedures
- Each is derived from the previous, forming a chain of narrowing trust
- Routers import and use these builders directly

---

### Using Base Procedures in Routers

```ts
// server/routers/user.ts
import { z } from 'zod';
import { router, publicProcedure, protectedProcedure, adminProcedure } from '../trpc';

export const userRouter = router({
  // Publicly accessible
  getProfile: publicProcedure
    .input(z.object({ username: z.string() }))
    .query(({ input }) => {
      return db.user.findUnique({ where: { username: input.username } });
    }),

  // Requires authentication
  updateBio: protectedProcedure
    .input(z.object({ bio: z.string().max(300) }))
    .mutation(({ input, ctx }) => {
      return db.user.update({
        where: { id: ctx.session.user.id },
        data: { bio: input.bio },
      });
    }),

  // Requires admin role
  deleteUser: adminProcedure
    .input(z.object({ userId: z.string() }))
    .mutation(({ input }) => {
      return db.user.delete({ where: { id: input.userId } });
    }),
});
```

---

### Procedure Factories with Parameters

A procedure factory is a function that accepts configuration and returns a configured builder. This is useful when the middleware or validation logic needs to be parameterized.

#### Rate-Limited Procedure Factory

```ts
// server/factories/rateLimited.ts
import { middleware, publicProcedure } from '../trpc';
import { TRPCError } from '@trpc/server';

export function rateLimitedProcedure(maxRequests: number, windowMs: number) {
  const rateLimitMiddleware = middleware(async ({ ctx, next }) => {
    const key = ctx.ip ?? 'anonymous';
    const allowed = await checkRateLimit(key, maxRequests, windowMs);

    if (!allowed) {
      throw new TRPCError({
        code: 'TOO_MANY_REQUESTS',
        message: 'Rate limit exceeded.',
      });
    }

    return next({ ctx });
  });

  return publicProcedure.use(rateLimitMiddleware);
}
```

**Usage:**

```ts
export const authRouter = router({
  login: rateLimitedProcedure(5, 60_000) // 5 requests per minute
    .input(z.object({ email: z.string().email(), password: z.string() }))
    .mutation(({ input }) => {
      // login logic
    }),
});
```

#### Role-Scoped Procedure Factory

```ts
// server/factories/withRole.ts
import { protectedProcedure, middleware } from '../trpc';
import { TRPCError } from '@trpc/server';

type Role = 'admin' | 'editor' | 'viewer';

export function withRole(role: Role) {
  return protectedProcedure.use(({ ctx, next }) => {
    if (ctx.session.user.role !== role) {
      throw new TRPCError({ code: 'FORBIDDEN' });
    }
    return next({ ctx });
  });
}
```

**Usage:**

```ts
export const contentRouter = router({
  publish: withRole('editor')
    .input(z.object({ postId: z.string() }))
    .mutation(({ input }) => { /* ... */ }),

  moderate: withRole('admin')
    .input(z.object({ commentId: z.string() }))
    .mutation(({ input }) => { /* ... */ }),
});
```

---

### Composing Input Schemas with Factories

Factories can also encapsulate shared input schema fragments, ensuring consistent validation across related procedures.

```ts
// server/factories/withPagination.ts
import { z } from 'zod';
import { publicProcedure } from '../trpc';

export const paginationSchema = z.object({
  cursor: z.string().optional(),
  limit: z.number().int().min(1).max(100).default(10),
});

export const paginatedProcedure = publicProcedure.input(paginationSchema);
```

**Usage:**

```ts
export const feedRouter = router({
  posts: paginatedProcedure
    .input(
      z.object({ tag: z.string().optional() }) // merged with paginationSchema
    )
    .query(({ input }) => {
      // input.cursor, input.limit, input.tag are all typed
    }),
});
```

**Key Points:**

- When you call `.input()` on a builder that already has an input schema, tRPC **merges** the schemas [Inference: merging behavior applies when both schemas are `ZodObject`; union or other Zod types may behave differently — verify against your tRPC version]
- This allows factory-provided base schemas to be extended per procedure without duplication

---

### Visualizing Builder Derivation

```
graph TD
    A[t.procedure] --> B[publicProcedure]
    A --> C[protectedProcedure<br/>+ authMiddleware]
    C --> D[adminProcedure<br/>+ roleMiddleware]
    C --> E[withRole('editor')<br/>+ roleMiddleware]
    B --> F[rateLimitedProcedure(5, 60000)<br/>+ rateLimitMiddleware]
    B --> G[paginatedProcedure<br/>+ paginationSchema]

    D --> H[deleteUser.mutation]
    E --> I[publish.mutation]
    F --> J[login.mutation]
    G --> K[posts.query]
```

---

### Output Validation in Factories

Factories can also attach `.output()` schemas, enforcing response shape at the builder level:

```ts
// server/factories/withAuditLog.ts
import { z } from 'zod';
import { protectedProcedure } from '../trpc';

const auditableOutputSchema = z.object({
  success: z.boolean(),
  affectedId: z.string(),
});

export const auditedMutationProcedure = protectedProcedure
  .output(auditableOutputSchema)
  .use(async ({ ctx, next }) => {
    const result = await next({ ctx });
    // result.ok indicates whether the procedure succeeded
    await logAudit(ctx.session.user.id, result.ok);
    return result;
  });
```

**Key Points:**

- `.output()` causes tRPC to validate the return value of the resolver against the schema at runtime [Inference: this adds overhead; the trade-off is stricter type safety and earlier detection of resolver bugs]
- If the resolver returns data that does not match the output schema, tRPC throws an internal server error before the response is sent

---

### Organizing Factories

For non-trivial applications, grouping factories into a dedicated module aids discoverability:

```
server/
  trpc.ts              ← t.procedure, router, middleware exports
  context.ts
  factories/
    index.ts           ← re-exports all factories
    withRole.ts
    withRateLimit.ts
    withPagination.ts
    withAuditLog.ts
  routers/
    user.ts
    post.ts
    admin.ts
```

```ts
// server/factories/index.ts
export { withRole } from './withRole';
export { rateLimitedProcedure } from './withRateLimit';
export { paginatedProcedure, paginationSchema } from './withPagination';
export { auditedMutationProcedure } from './withAuditLog';
```

Routers then import from a single location:

```ts
import { withRole, paginatedProcedure } from '../factories';
```

---

### Anti-Patterns to Avoid

**Anti-pattern 1 — Rebuilding middleware inline per procedure:**

```ts
// ❌ Duplicated auth check in every procedure
export const userRouter = router({
  update: t.procedure.use(({ ctx, next }) => {
    if (!ctx.session) throw new TRPCError({ code: 'UNAUTHORIZED' });
    return next({ ctx });
  }).mutation(/* ... */),

  delete: t.procedure.use(({ ctx, next }) => {
    if (!ctx.session) throw new TRPCError({ code: 'UNAUTHORIZED' });
    return next({ ctx });
  }).mutation(/* ... */),
});
```

```ts
// ✅ Use a shared base procedure
export const userRouter = router({
  update: protectedProcedure.mutation(/* ... */),
  delete: protectedProcedure.mutation(/* ... */),
});
```

**Anti-pattern 2 — Mutating a shared builder:**

tRPC builders are immutable by design. Attempting to reassign or mutate a shared builder reference is ineffective and misleading. Always assign derived builders to new variables.

```ts
// ❌ Misleading — does not modify base
let base = t.procedure;
base.use(someMiddleware); // return value is discarded

// ✅ Assign the derived builder
const withSomething = t.procedure.use(someMiddleware);
```

---

**Conclusion**

Procedure factories and reusable builders are the primary mechanism for enforcing consistent authorization, validation, and cross-cutting behavior across a tRPC API. The immutable builder design makes derivation safe — a shared base can be extended in multiple directions without side effects. Factories that accept parameters further extend this by allowing runtime-configured middleware to be attached declaratively at the router level.