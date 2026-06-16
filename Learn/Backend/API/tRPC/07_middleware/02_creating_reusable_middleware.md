## Creating Reusable Middleware in tRPC

### What "Reusable" Means in This Context

Reusable middleware refers to middleware functions that are **defined once** and applied across multiple procedures or routers — rather than inlining logic directly into individual procedure definitions. The goal is to centralize cross-cutting concerns (authentication, logging, rate limiting, etc.) and avoid duplication.

---

### The Core Pattern: Base Procedures

The primary mechanism for reusability in tRPC is the **base procedure** — a procedure builder that has middleware pre-attached, exported and shared across your router files.

```ts
// server/trpc.ts
import { initTRPC, TRPCError } from '@trpc/server';

interface Context {
  sessionToken?: string;
}

const t = initTRPC.context<Context>().create();

export const router         = t.router;
export const publicProcedure = t.procedure;

export const protectedProcedure = t.procedure.use(async ({ ctx, next }) => {
  if (!ctx.sessionToken) {
    throw new TRPCError({ code: 'UNAUTHORIZED' });
  }
  return next({ ctx: { ...ctx, sessionToken: ctx.sessionToken } });
});
```

Any router file that imports `protectedProcedure` automatically inherits the middleware without re-declaring it.

---

### Defining Middleware as a Standalone Unit

Rather than writing middleware inline inside `.use()`, define it as a named constant using `t.middleware()`. This makes it independently testable, composable, and importable.

```ts
// server/middleware/logger.ts
import { t } from '../trpc';

export const loggerMiddleware = t.middleware(async ({ path, type, next }) => {
  const start = Date.now();
  const result = await next();
  console.log(`[${type.toUpperCase()}] ${path} — ${Date.now() - start}ms`);
  return result;
});
```

```ts
// server/middleware/auth.ts
import { t } from '../trpc';
import { TRPCError } from '@trpc/server';
import { getUserFromToken } from '../lib/auth';

export const authMiddleware = t.middleware(async ({ ctx, next }) => {
  const user = await getUserFromToken(ctx.sessionToken);

  if (!user) {
    throw new TRPCError({ code: 'UNAUTHORIZED' });
  }

  return next({
    ctx: { ...ctx, user },
  });
});
```

**Key Points:**

- `t.middleware()` returns a typed middleware object that carries context type information through the chain
- Separating middleware into individual files makes each concern independently maintainable
- Each middleware file only needs to import `t` (the tRPC instance), not the full router

---

### Composing Middleware into Base Procedures

Once middleware is defined as standalone units, compose them into named base procedures in a central file:

```ts
// server/trpc.ts
import { loggerMiddleware } from './middleware/logger';
import { authMiddleware }   from './middleware/auth';
import { rateLimitMiddleware } from './middleware/rateLimit';

export const publicProcedure = t.procedure
  .use(loggerMiddleware);

export const protectedProcedure = t.procedure
  .use(loggerMiddleware)
  .use(authMiddleware);

export const adminProcedure = t.procedure
  .use(loggerMiddleware)
  .use(authMiddleware)
  .use(requireRoleMiddleware('admin'));
```

**Key Points:**

- Middleware executes in the order `.use()` is called — top to bottom
- Each base procedure is an independent builder; they do not share state between calls
- Adding middleware to a base procedure does not affect already-defined procedures built from it

---

### Parameterized Middleware

Middleware can be made configurable by wrapping it in a factory function that accepts parameters and returns a middleware instance:

```ts
// server/middleware/requireRole.ts
import { t } from '../trpc';
import { TRPCError } from '@trpc/server';

type Role = 'admin' | 'editor' | 'viewer';

export const requireRoleMiddleware = (requiredRole: Role) =>
  t.middleware(async ({ ctx, next }) => {
    if (!ctx.user) {
      throw new TRPCError({ code: 'UNAUTHORIZED' });
    }

    if (ctx.user.role !== requiredRole) {
      throw new TRPCError({
        code: 'FORBIDDEN',
        message: `Required role: ${requiredRole}. Your role: ${ctx.user.role}`,
      });
    }

    return next();
  });
```

**Usage:**

```ts
export const adminProcedure  = t.procedure.use(authMiddleware).use(requireRoleMiddleware('admin'));
export const editorProcedure = t.procedure.use(authMiddleware).use(requireRoleMiddleware('editor'));
```

**Key Points:**

- Each call to `requireRoleMiddleware(role)` returns a new middleware instance configured with that role
- The factory pattern keeps the middleware logic generic while allowing call-site customization
- [Inference] TypeScript will infer the parameter type from the factory signature, providing call-site safety — actual inference behavior may vary depending on TypeScript version and configuration

---

### Extending Context Through a Chain

When multiple middleware each extend `ctx`, the types accumulate across the chain. Each `next({ ctx })` call merges the new context with the previous one as far as TypeScript is concerned:

```ts
// Middleware A: adds `requestId`
const requestIdMiddleware = t.middleware(async ({ ctx, next }) => {
  return next({
    ctx: { ...ctx, requestId: crypto.randomUUID() },
  });
});

// Middleware B: adds `user` — assumes ctx may or may not have requestId
const authMiddleware = t.middleware(async ({ ctx, next }) => {
  const user = await getUserFromToken(ctx.sessionToken);
  if (!user) throw new TRPCError({ code: 'UNAUTHORIZED' });
  return next({
    ctx: { ...ctx, user },
  });
});

// Composed procedure: ctx has both `requestId` and `user` in the resolver
export const trackedProtectedProcedure = t.procedure
  .use(requestIdMiddleware)
  .use(authMiddleware);
```

The resolver of any procedure built on `trackedProtectedProcedure` will have `ctx.requestId` and `ctx.user` both available and typed.

---

### Recommended File Structure

A practical structure for organizing reusable middleware in a tRPC project:

```
server/
├── trpc.ts                  ← t instance, all base procedure exports
├── middleware/
│   ├── auth.ts              ← authMiddleware
│   ├── logger.ts            ← loggerMiddleware
│   ├── rateLimit.ts         ← rateLimitMiddleware
│   └── requireRole.ts       ← requireRoleMiddleware (factory)
└── routers/
    ├── user.ts              ← imports protectedProcedure
    ├── post.ts              ← imports protectedProcedure
    └── admin.ts             ← imports adminProcedure
```

**Key Points:**

- `trpc.ts` is the single source of truth for all base procedures
- Router files never define their own middleware — they only import from `trpc.ts`
- Middleware files only depend on `t`, keeping them decoupled from router logic

---

### Anti-Patterns to Avoid

**Inlining middleware logic per-procedure:**

```ts
// ❌ Repeated logic — hard to maintain
const userRouter = router({
  getProfile: t.procedure
    .use(async ({ ctx, next }) => {
      if (!ctx.sessionToken) throw new TRPCError({ code: 'UNAUTHORIZED' });
      return next();
    })
    .query(() => { /* ... */ }),
});
```

**Preferred:**

```ts
// ✅ Centralized via base procedure
const userRouter = router({
  getProfile: protectedProcedure.query(() => { /* ... */ }),
});
```

---

**Redefining `t` in middleware files:**

```ts
// ❌ Creates a separate tRPC instance — type chain breaks
const t2 = initTRPC.create();
export const myMiddleware = t2.middleware(/* ... */);
```

Middleware must be created from the **same `t` instance** used by the procedures that consume it. Creating multiple `t` instances breaks the type chain and may cause runtime errors. [Inference: this is expected behavior based on how tRPC's type system threads context through a single instance; runtime behavior may vary]

---

### Summary

|Pattern|Purpose|
|---|---|
|`t.middleware()` standalone|Defines a reusable, importable middleware unit|
|Base procedure (`.use()`)|Composes middleware into a shared procedure builder|
|Factory function|Parameterizes middleware for configurable behavior|
|`next({ ctx })` merging|Accumulates and types context extensions across the chain|
|Centralized `trpc.ts`|Single source of truth for all base procedures|
