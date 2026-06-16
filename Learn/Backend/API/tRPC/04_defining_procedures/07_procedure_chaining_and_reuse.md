## Procedure Chaining and Reuse

### Overview

tRPC procedures are built through a chainable builder API. Each call to `.input()`, `.use()`, `.output()`, or `.meta()` returns a new procedure builder with the accumulated configuration applied — the original builder is not mutated. This composability makes it possible to define base procedures that encapsulate shared behavior — authentication checks, logging, role enforcement — and derive multiple specialized procedures from them without duplicating logic.

---

### The Procedure Builder Chain

Every procedure starts from `t.procedure` and is extended through method chaining:

```
t.procedure
    │
    ├── .use(middleware)       → adds middleware, narrows ctx
    ├── .input(schema)         → adds input validation, types input
    ├── .output(schema)        → adds output validation
    ├── .meta(object)          → attaches metadata
    │
    └── .query() / .mutation() / .subscription()   → terminal: defines the resolver
```

Each intermediate step returns a new `ProcedureBuilder` instance. Only the terminal call (`.query()`, `.mutation()`, `.subscription()`) produces a finalized procedure that can be placed in a router.

**Key Points**
- Intermediate builders are reusable. Storing an intermediate builder in a variable and calling `.query()` or `.mutation()` on it multiple times creates independent procedures that each inherit the accumulated configuration.
- The chain is immutable — each step produces a new builder. Modifying a derived builder does not affect its parent.

---

### Defining Base Procedures

The most common use of chaining is defining base procedures in `trpc.ts` that encode shared middleware or constraints:

```ts
// server/trpc.ts
import { initTRPC, TRPCError } from '@trpc/server';
import type { Context } from './context';

const t = initTRPC.context<Context>().create();

export const router = t.router;
export const middleware = t.middleware;

// Base: no restrictions
export const publicProcedure = t.procedure;

// Base: requires authenticated user
export const authedProcedure = t.procedure.use(({ ctx, next }) => {
  if (!ctx.user) {
    throw new TRPCError({ code: 'UNAUTHORIZED' });
  }
  return next({
    ctx: {
      ...ctx,
      user: ctx.user, // narrows ctx.user from User | null to User
    },
  });
});

// Base: requires admin role
export const adminProcedure = authedProcedure.use(({ ctx, next }) => {
  if (ctx.user.role !== 'admin') {
    throw new TRPCError({ code: 'FORBIDDEN' });
  }
  return next({ ctx });
});
```

**Key Points**
- `authedProcedure` is derived from `t.procedure` by appending one middleware.
- `adminProcedure` is derived from `authedProcedure` — it inherits the auth check and adds a role check. Middleware stacks accumulate through derivation.
- After the auth middleware calls `next({ ctx: { ...ctx, user: ctx.user } })`, TypeScript narrows `ctx.user` in all downstream procedures to `User` (non-nullable). Resolvers on `authedProcedure` or `adminProcedure` can access `ctx.user` without null checks.

---

### Context Narrowing Through Middleware

Middleware can augment or narrow the context type by passing a modified `ctx` to `next()`. This is how type-safe context enrichment works.

```ts
// Context type from createContext:
// { req: Request; user: User | null; db: PrismaClient }

const authedProcedure = t.procedure.use(({ ctx, next }) => {
  if (!ctx.user) {
    throw new TRPCError({ code: 'UNAUTHORIZED' });
  }

  return next({
    ctx: {
      ...ctx,
      user: ctx.user, // User (non-nullable)
    },
  });
});

// In a resolver using authedProcedure:
authedProcedure.query(({ ctx }) => {
  ctx.user.id;    // ✓ TypeScript knows ctx.user is User, not User | null
  ctx.user.name;  // ✓ No null check needed
});
```

**Key Points**
- The `ctx` passed to `next()` becomes the context type seen by downstream middleware and the resolver. TypeScript tracks the narrowed type through the chain.
- The spread `...ctx` preserves all existing context fields. Only fields explicitly overridden in the `next()` call are replaced.
- Context narrowing is purely a TypeScript-level effect. At runtime, `ctx` is just an object — the narrowing reflects the invariant enforced by the middleware guard.

---

### Composing Multiple Middleware Layers

Middleware layers compose in the order they are chained. Each `.use()` call appends a layer:

```ts
const loggedProcedure = t.procedure.use(loggingMiddleware);
const authedLoggedProcedure = loggedProcedure.use(authMiddleware);
const rateLimitedAuthedProcedure = authedLoggedProcedure.use(rateLimitMiddleware);
```

Execution order for a procedure derived from `rateLimitedAuthedProcedure`:

```
Request
   │
   ▼
loggingMiddleware     (outermost — runs first)
   │
   ▼
authMiddleware
   │
   ▼
rateLimitMiddleware
   │
   ▼
resolver              (innermost — runs last)
   │
   ▼ (return)
rateLimitMiddleware   (cleanup / after next())
   │
   ▼
authMiddleware
   │
   ▼
loggingMiddleware     (cleanup / after next())
   │
   ▼
Response
```

**Key Points**
- Middleware execution follows the same onion model as Express or Koa middleware. Code before `next()` runs on the way in; code after `next()` runs on the way out.
- If any middleware throws or does not call `next()`, subsequent middleware and the resolver do not execute.
- [Inference] The order in which middleware is chained matters. An auth middleware that throws before a logging middleware calls `next()` may cause the logging middleware to miss the response phase. Design middleware order with this in mind.

---

### Adding Input to a Base Procedure

Base procedures can have `.input()` added at the point of use. Each procedure derived from a base can specify its own input schema independently:

```ts
export const userRouter = router({
  getProfile: authedProcedure
    .input(z.object({ userId: z.string() }))
    .query(({ input, ctx }) => {
      // input: { userId: string }
      // ctx.user: User (narrowed by authedProcedure middleware)
      return db.user.findUnique({ where: { id: input.userId } });
    }),

  updateProfile: authedProcedure
    .input(z.object({
      name: z.string().min(1),
      bio: z.string().optional(),
    }))
    .mutation(({ input, ctx }) => {
      return db.user.update({
        where: { id: ctx.user.id },
        data: input,
      });
    }),
});
```

**Key Points**
- Both procedures share the authentication enforcement from `authedProcedure` but have entirely independent input schemas.
- `authedProcedure` does not define `.input()` itself — input is always added per-procedure. [Inference] Adding `.input()` to a base procedure is possible but limits flexibility for derived procedures that need different inputs.

---

### Chaining `.input()` Multiple Times

`.input()` can be called more than once on the same chain. Each call merges with the previous via Zod's `.and()` semantics, producing a combined input schema.

```ts
const basePaginatedProcedure = publicProcedure.input(
  z.object({
    page: z.number().int().min(1).default(1),
    limit: z.number().int().min(1).max(100).default(20),
  })
);

export const postRouter = router({
  search: basePaginatedProcedure
    .input(z.object({
      query: z.string().min(1),
      tag: z.string().optional(),
    }))
    .query(({ input }) => {
      // input: { page: number; limit: number; query: string; tag?: string }
      return db.post.findMany({ /* ... */ });
    }),
});
```

**Key Points**
- The merged input type is the intersection of both schemas. The client must provide all fields from both schemas (minus fields with defaults).
- [Inference] Chaining `.input()` multiple times may produce unexpected behavior with overlapping field names. If both schemas define the same field with different types, the resulting type is the intersection of those types, which may be `never`. Avoid overlapping field names across chained `.input()` calls.
- This pattern is most useful for attaching standard pagination, filtering, or cursor fields to a base procedure used across many list endpoints.

---

### Reusable Procedure Factories

For more dynamic reuse, a function can produce a configured procedure builder:

```ts
// Produces a procedure that validates ownership of a resource
function ownedResourceProcedure(resourceType: 'post' | 'comment') {
  return authedProcedure
    .input(z.object({ resourceId: z.string().uuid() }))
    .use(async ({ ctx, input, next }) => {
      const resource = await db[resourceType].findUnique({
        where: { id: input.resourceId },
      });

      if (!resource) {
        throw new TRPCError({ code: 'NOT_FOUND' });
      }

      if (resource.authorId !== ctx.user.id) {
        throw new TRPCError({ code: 'FORBIDDEN' });
      }

      return next({ ctx: { ...ctx, resource } });
    });
}

export const postRouter = router({
  delete: ownedResourceProcedure('post')
    .mutation(({ ctx }) => {
      return db.post.delete({ where: { id: ctx.resource.id } });
    }),
});
```

**Key Points**
- [Inference] This pattern is more complex than simple base procedures. Use it when the shared behavior is genuinely parameterized and the added complexity is justified by the elimination of duplication.
- The factory function returns a `ProcedureBuilder` — the caller can still chain additional `.input()`, `.use()`, or `.output()` calls on the returned builder.
- TypeScript will attempt to infer `ctx.resource`'s type from what the middleware passes to `next()`. Precise typing may require explicit generic annotations depending on how the database client types its results. [Inference]

---

### Sharing Middleware Definitions

Middleware can be defined independently of procedures and composed at the point of use:

```ts
// server/middleware/logging.ts
import { middleware } from '../trpc';

export const loggingMiddleware = middleware(async ({ path, type, next }) => {
  const start = Date.now();
  const result = await next();
  const duration = Date.now() - start;
  console.log(`[${type}] ${path} — ${duration}ms`);
  return result;
});
```

```ts
// server/middleware/auth.ts
import { middleware } from '../trpc';
import { TRPCError } from '@trpc/server';

export const authMiddleware = middleware(({ ctx, next }) => {
  if (!ctx.user) {
    throw new TRPCError({ code: 'UNAUTHORIZED' });
  }
  return next({ ctx: { ...ctx, user: ctx.user } });
});
```

```ts
// server/trpc.ts
import { loggingMiddleware } from './middleware/logging';
import { authMiddleware } from './middleware/auth';

export const publicProcedure = t.procedure.use(loggingMiddleware);
export const authedProcedure = publicProcedure.use(authMiddleware);
```

**Key Points**
- `middleware()` from `initTRPC` provides full TypeScript context typing, including the context shape from `initTRPC.context<Context>()`. Middleware defined this way is aware of the application's context type.
- Separating middleware into dedicated files keeps `trpc.ts` focused on composition rather than implementation.
- Middleware defined outside of `trpc.ts` can be imported and composed in any order. This supports feature-based middleware organization in larger codebases.

---

### Procedure Reuse Across Routers

A base procedure defined in `trpc.ts` is available to all routers that import from it. This is the primary mechanism for cross-router consistency:

```ts
// All routers import from the same trpc.ts
import { authedProcedure, router } from '../trpc';

// user.router.ts
export const userRouter = router({
  getMe: authedProcedure.query(({ ctx }) => ctx.user),
});

// post.router.ts
export const postRouter = router({
  create: authedProcedure
    .input(z.object({ title: z.string() }))
    .mutation(({ input, ctx }) => {
      return db.post.create({ data: { ...input, authorId: ctx.user.id } });
    }),
});
```

**Key Points**
- Both routers share the same authentication enforcement without duplicating middleware logic.
- If the authentication logic changes (e.g., adding a session expiry check), updating `authedProcedure` in `trpc.ts` propagates the change to all derived procedures across all routers automatically.

---

### Procedure Inheritance Diagram

```
t.procedure
├── publicProcedure          (+ loggingMiddleware)
│   ├── post.getAll          (.query)
│   └── user.getById         (.query)
│
└── authedProcedure          (+ authMiddleware)
    ├── user.getMe           (.query)
    ├── post.create          (.mutation)
    │
    └── adminProcedure       (+ roleCheckMiddleware)
        ├── user.delete      (.mutation)
        └── post.unpublish   (.mutation)
```

Each level inherits all middleware from its parent. Procedures at each level add their own `.input()`, `.output()`, and resolver.

---

### Anti-Patterns

#### Duplicating middleware in resolvers

```ts
// ✗ Auth check inline in each resolver
getProfile: publicProcedure.query(({ ctx }) => {
  if (!ctx.user) throw new TRPCError({ code: 'UNAUTHORIZED' });
  return ctx.user;
}),

updateProfile: publicProcedure.mutation(({ ctx }) => {
  if (!ctx.user) throw new TRPCError({ code: 'UNAUTHORIZED' });
  // ...
}),
```

```ts
// ✓ Auth check in base procedure, resolvers stay clean
getProfile: authedProcedure.query(({ ctx }) => ctx.user),
updateProfile: authedProcedure.mutation(({ ctx }) => { /* ... */ }),
```

---

#### Calling `initTRPC` more than once

```ts
// ✗ Each router file initializes its own tRPC instance
// router/user.router.ts
const t = initTRPC.context<Context>().create();
const authedProcedure = t.procedure.use(authMiddleware);
```

```ts
// ✓ Single initTRPC call in trpc.ts, exported for all routers to import
import { authedProcedure } from '../trpc';
```

**Key Points**
- Multiple `initTRPC` instances produce incompatible procedure types. Routers built from different instances cannot be merged. [Inference]
- `initTRPC` must be called exactly once per application, in a single file (`trpc.ts`), and all procedures must be derived from the exported builders.

---

#### Mutating context instead of passing through `next()`

```ts
// ✗ Mutating ctx directly (unreliable, bypasses TypeScript narrowing)
const badMiddleware = middleware(({ ctx, next }) => {
  (ctx as any).user = getUser();
  return next();
});

// ✓ Passing narrowed ctx through next()
const goodMiddleware = middleware(({ ctx, next }) => {
  const user = getUser();
  return next({ ctx: { ...ctx, user } });
});
```

**Key Points**
- Mutating `ctx` directly bypasses TypeScript's context narrowing and may produce unreliable behavior depending on how tRPC handles the context object internally. [Inference]
- Passing the updated context through `next({ ctx })` is the documented approach and ensures TypeScript tracks the narrowed type through the chain.