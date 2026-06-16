## Middleware in tRPC

### What Is Middleware

Middleware in tRPC is a function that runs **before** a procedure's resolver executes. It sits in the call chain between the incoming request and the final handler, allowing you to intercept, inspect, transform, or reject the request at that point.

Middleware is attached to a procedure using `.use()` on a router builder instance (typically created via `t.procedure` or a derived base procedure).

**Key Points:**
- Middleware receives the request context and can modify it before passing it downstream
- It must explicitly call `next()` to continue the chain; omitting it halts execution
- The return value of `next()` carries the result of the downstream procedure
- Multiple middleware can be chained on a single procedure; they execute in the order they are attached

---

### The Middleware Call Chain

Each middleware in tRPC follows this pattern:

```
Request → Middleware 1 → Middleware 2 → ... → Resolver
                                                  ↓
Response ← Middleware 1 ← Middleware 2 ← ... ← Result
```

This means middleware wraps the resolver symmetrically — code before `next()` runs on the way in, and code after `next()` runs on the way out (useful for logging, timing, cleanup).

---

### Basic Syntax

```ts
import { initTRPC } from '@trpc/server';

const t = initTRPC.context<{ userId?: string }>().create();

const loggerMiddleware = t.middleware(async ({ path, type, next }) => {
  console.log(`[${type}] /${path} — called`);

  const result = await next();

  console.log(`[${type}] /${path} — completed`);

  return result;
});
```

The middleware function receives a single object with the following properties:

| Property | Description |
|---|---|
| `ctx` | The current request context |
| `next` | Function to call the next middleware or resolver |
| `path` | The procedure path string (e.g., `"user.getById"`) |
| `type` | Procedure type: `"query"`, `"mutation"`, or `"subscription"` |
| `input` | The parsed input passed to the procedure |
| `rawInput` | The raw, unparsed input before validation |
| `meta` | Optional procedure metadata (if configured) |

---

### Attaching Middleware to a Procedure

Middleware is attached via `.use()` on a procedure builder:

```ts
const publicProcedure = t.procedure;

const loggedProcedure = t.procedure.use(loggerMiddleware);

const router = t.router({
  hello: loggedProcedure.query(() => {
    return { message: 'Hello, world!' };
  }),
});
```

Any procedure built from `loggedProcedure` will run `loggerMiddleware` before its resolver.

---

### Modifying Context in Middleware

One of the most important uses of middleware is **extending the context** — adding verified data (such as an authenticated user) so downstream procedures can rely on it.

To extend context, pass a new `ctx` object into `next()`:

```ts
const authMiddleware = t.middleware(async ({ ctx, next }) => {
  const user = await getUserFromSession(ctx.sessionToken);

  if (!user) {
    throw new TRPCError({ code: 'UNAUTHORIZED' });
  }

  // Pass extended context downstream
  return next({
    ctx: {
      ...ctx,
      user, // now typed as non-nullable downstream
    },
  });
});

const protectedProcedure = t.procedure.use(authMiddleware);
```

**Key Points:**
- The extended `ctx` is only available to middleware and resolvers further down the chain
- tRPC infers the updated context type, so downstream procedures get full type safety on the enriched context
- The original context is not mutated; a new object is passed to `next()`

---

### Chaining Multiple Middleware

Multiple `.use()` calls stack middleware in declaration order:

```ts
const protectedLoggedProcedure = t.procedure
  .use(loggerMiddleware)   // runs first
  .use(authMiddleware);    // runs second
```

**Execution order:**

```
loggerMiddleware (before next)
  → authMiddleware (before next)
      → resolver
  ← authMiddleware (after next)
← loggerMiddleware (after next)
```

---

### Reusable Base Procedures

A common pattern is to define **named base procedures** that encapsulate middleware, then use them as the foundation for groups of routes:

```ts
export const publicProcedure    = t.procedure;
export const protectedProcedure = t.procedure.use(authMiddleware);
export const adminProcedure     = t.procedure.use(authMiddleware).use(requireAdminMiddleware);
```

This avoids repeating `.use()` calls across every procedure definition and keeps access control centralized.

---

### Error Handling in Middleware

Middleware can throw `TRPCError` to short-circuit the chain and return an error to the caller:

```ts
import { TRPCError } from '@trpc/server';

const rateLimitMiddleware = t.middleware(async ({ ctx, next }) => {
  const allowed = await checkRateLimit(ctx.ip);

  if (!allowed) {
    throw new TRPCError({
      code: 'TOO_MANY_REQUESTS',
      message: 'Rate limit exceeded.',
    });
  }

  return next();
});
```

Throwing inside middleware prevents `next()` from being called, so the resolver never runs.

---

### Timing Example

Because middleware wraps the resolver, it can measure execution duration:

```ts
const timingMiddleware = t.middleware(async ({ path, next }) => {
  const start = Date.now();

  const result = await next();

  const duration = Date.now() - start;
  console.log(`/${path} took ${duration}ms`);

  return result;
});
```

**Output** (in server logs):
```
/user.getById took 42ms
```

---

### What Middleware Cannot Do

- Middleware **cannot** modify the procedure's input schema or output type directly
- Middleware **cannot** be applied globally to all routers automatically without a shared base procedure or a dedicated server integration hook — [Inference: this constraint exists because middleware is attached per-procedure-builder, not per-router; actual behavior may vary by tRPC version]
- Middleware **does not** replace HTTP-level middleware (e.g., Express `app.use()`) — both layers can coexist

---

### Summary

| Concept | Detail |
|---|---|
| Attachment point | `.use()` on a procedure builder |
| Execution trigger | Before the resolver runs |
| Context extension | Pass new `ctx` into `next()` |
| Chain control | Must call `next()` to proceed; omitting it halts the chain |
| Error short-circuit | Throw `TRPCError` to abort without calling `next()` |
| Reuse pattern | Define named base procedures (e.g., `protectedProcedure`) |