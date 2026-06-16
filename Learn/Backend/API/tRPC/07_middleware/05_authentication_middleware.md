## Authentication Middleware in tRPC

Authentication middleware in tRPC is the standard mechanism for verifying the identity of a caller before allowing access to protected procedures. It intercepts the request pipeline, validates credentials (typically from the context), and either passes execution forward or throws an error.

---

### How It Fits into the Middleware Pipeline

tRPC middleware runs in a chain before the procedure resolver. Each middleware receives `next`, which it must call to continue the chain. Authentication middleware typically sits at the beginning of this chain for protected procedures.

```
Request → Middleware (auth check) → Procedure Resolver → Response
```

If authentication fails, the middleware throws before calling `next`, and the resolver is never reached.

---

### The Base Concept: Context as the Auth Source

tRPC authentication middleware does not extract credentials itself — that is the responsibility of the **context function** (`createContext`). The middleware then reads from that already-populated context.

**Example context setup (Express adapter):**

```ts
import { inferAsyncReturnType } from '@trpc/server';
import { CreateExpressContextOptions } from '@trpc/server/adapters/express';
import { verifyToken } from './auth'; // your own token utility

export async function createContext({ req }: CreateExpressContextOptions) {
  const token = req.headers.authorization?.split(' ')[1];

  const user = token ? await verifyToken(token) : null;

  return { user };
}

export type Context = inferAsyncReturnType<typeof createContext>;
```

**Key Points:**
- The context function runs on every request
- `user` will be `null` for unauthenticated requests — not an error yet
- The middleware decides what to do with that `null`

---

### Writing the Authentication Middleware

```ts
import { TRPCError } from '@trpc/server';
import { t } from './trpc'; // your initialized tRPC instance

const isAuthenticated = t.middleware(({ ctx, next }) => {
  if (!ctx.user) {
    throw new TRPCError({
      code: 'UNAUTHORIZED',
      message: 'You must be logged in to access this resource.',
    });
  }

  // Pass a narrowed context downstream — user is now non-null
  return next({
    ctx: {
      ...ctx,
      user: ctx.user, // TypeScript now knows this is defined
    },
  });
});
```

**Key Points:**
- `TRPCError` with `code: 'UNAUTHORIZED'` maps to HTTP 401 when using HTTP adapters
- Passing `ctx` with the narrowed `user` field is important — it lets TypeScript infer that `ctx.user` is non-null in all procedures that use this middleware
- [Inference] The spread `...ctx` pattern preserves other context fields; omitting it may cause downstream procedures to lose access to them

---

### Creating a Protected Procedure

Once the middleware is defined, you create a reusable **protected procedure** by attaching it:

```ts
export const protectedProcedure = t.procedure.use(isAuthenticated);
```

This procedure variant can now be used across your router wherever authentication is required.

```ts
export const userRouter = t.router({
  getProfile: protectedProcedure.query(({ ctx }) => {
    // ctx.user is guaranteed non-null here by TypeScript
    return getUserById(ctx.user.id);
  }),

  updateEmail: protectedProcedure
    .input(z.object({ email: z.string().email() }))
    .mutation(({ ctx, input }) => {
      return updateUserEmail(ctx.user.id, input.email);
    }),
});
```

**Key Points:**
- `protectedProcedure` is a drop-in replacement for `t.procedure`
- Any procedure using it automatically inherits the auth check
- The TypeScript narrowing from the middleware propagates into resolvers

---

### Context Narrowing in Detail

One of the most practical aspects of tRPC middleware is **typed context narrowing**. Without it, `ctx.user` would remain `User | null` even inside protected procedures, requiring null checks that are logically unnecessary.

**Before narrowing (in resolver):**
```ts
// ctx.user is User | null — TypeScript complains
return getUserById(ctx.user.id); // Error: ctx.user is possibly null
```

**After narrowing (via middleware):**
```ts
// In the middleware:
return next({
  ctx: {
    ...ctx,
    user: ctx.user, // ctx.user here is already checked to be non-null
  },
});

// In the resolver:
return getUserById(ctx.user.id); // No TypeScript error
```

The narrowing works because TypeScript performs control flow analysis — after the `if (!ctx.user)` throw, it knows `ctx.user` is non-null for the rest of the middleware function.

> [Inference] The exact TypeScript behavior depends on your `tsconfig` settings and tRPC version. Behavior may vary across environments.

---

### Role-Based Authorization as an Extension

Authentication confirms *who* the user is. Authorization confirms *what* they can do. You can stack middleware for both:

```ts
const isAdmin = t.middleware(({ ctx, next }) => {
  if (!ctx.user) {
    throw new TRPCError({ code: 'UNAUTHORIZED' });
  }

  if (ctx.user.role !== 'admin') {
    throw new TRPCError({
      code: 'FORBIDDEN',
      message: 'Admin access required.',
    });
  }

  return next({
    ctx: {
      ...ctx,
      user: ctx.user,
    },
  });
});

export const adminProcedure = t.procedure.use(isAdmin);
```

**Key Points:**
- `FORBIDDEN` maps to HTTP 403 — distinct from `UNAUTHORIZED` (401)
- You can define as many role-specific procedures as needed (`editorProcedure`, `moderatorProcedure`, etc.)
- [Inference] Stacking `isAuthenticated` and a separate `isAdmin` middleware (rather than combining them) may improve reusability but both approaches are functionally equivalent

---

### Composing Multiple Middleware

tRPC supports chaining middleware via `.use()`:

```ts
const loggingMiddleware = t.middleware(({ next, path }) => {
  console.log(`[tRPC] ${path} called`);
  return next();
});

export const protectedProcedure = t.procedure
  .use(loggingMiddleware)
  .use(isAuthenticated);
```

Middleware executes in the order it is chained.

> [Inference] The order matters — if `isAuthenticated` is placed before `loggingMiddleware`, unauthenticated requests may not be logged. Behavior depends on your implementation intent.

---

### Error Codes Reference

| Scenario | `TRPCError` code | HTTP equivalent |
|---|---|---|
| No credentials | `UNAUTHORIZED` | 401 |
| Valid user, wrong role | `FORBIDDEN` | 403 |
| Malformed token | `BAD_REQUEST` | 400 |
| Token verification failure | `UNAUTHORIZED` | 401 |

---

### Common Mistakes

**1. Checking auth in the resolver instead of middleware**

```ts
// Avoid — duplicates logic across procedures
getProfile: t.procedure.query(({ ctx }) => {
  if (!ctx.user) throw new TRPCError({ code: 'UNAUTHORIZED' });
  return getUser(ctx.user.id);
}),
```

Prefer the middleware approach to keep resolvers clean and prevent auth logic drift.

**2. Forgetting to pass the narrowed context**

```ts
// Missing ctx override — user remains User | null downstream
return next(); // ← no ctx passed
```

Always pass `ctx` explicitly when you want narrowing in resolvers.

**3. Doing credential extraction in middleware**

Extracting tokens or decoding JWTs inside middleware rather than in `createContext` makes the middleware harder to test and couples it to the transport layer.

---

**Conclusion**

Authentication middleware in tRPC is built around three cooperating parts: the context function (which extracts credentials), the middleware (which validates them and narrows the type), and the protected procedure (which makes the pattern reusable). This separation keeps auth logic centralized, avoids repetition in resolvers, and gives TypeScript enough information to enforce correctness at compile time.

**Next Steps:** Middleware — Authorization and role-based access control patterns