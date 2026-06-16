## Role-Based Access Control in tRPC

Role-based access control (RBAC) is a pattern where access to procedures is governed by the role assigned to the authenticated user. In tRPC, RBAC is typically implemented through middleware that inspects the user's role before allowing a procedure to execute.

---

### What RBAC Means in tRPC Context

In tRPC, there is no built-in RBAC system. You construct it using:

- **Session/context data** that carries the user's role
- **Middleware** that checks roles before a procedure runs
- **Protected routers** that group procedures behind role checks

[Inference] This is the most common pattern seen in tRPC codebases, but implementation details vary per project. Behavior depends on your specific setup.

---

### Setting Up the Context with Roles

The foundation of RBAC is having role information available in the tRPC context.

**Example — context with role:**

```ts
// server/context.ts
import { inferAsyncReturnType } from '@trpc/server';
import { getSession } from './auth'; // your auth utility

export async function createContext({ req }: { req: Request }) {
  const session = await getSession(req);

  return {
    user: session?.user ?? null,
    // Role stored on the user object, e.g. 'admin' | 'editor' | 'viewer'
  };
}

export type Context = inferAsyncReturnType<typeof createContext>;
```

The role is typically sourced from a database, a JWT claim, or a session store. tRPC itself does not dictate where it comes from.

---

### Defining Role Types

It is good practice to define your roles explicitly to get type safety.

```ts
// types/roles.ts
export type Role = 'admin' | 'editor' | 'viewer';

export type UserWithRole = {
  id: string;
  email: string;
  role: Role;
};
```

---

### Building Role-Checking Middleware

Middleware is the primary mechanism for enforcing roles in tRPC.

```ts
// server/trpc.ts
import { initTRPC, TRPCError } from '@trpc/server';
import type { Context } from './context';
import type { Role } from '../types/roles';

const t = initTRPC.context<Context>().create();

export const router = t.router;
export const publicProcedure = t.procedure;

// Reusable middleware factory that accepts one or more allowed roles
const requireRole = (...allowedRoles: Role[]) =>
  t.middleware(({ ctx, next }) => {
    if (!ctx.user) {
      throw new TRPCError({
        code: 'UNAUTHORIZED',
        message: 'You must be logged in.',
      });
    }

    if (!allowedRoles.includes(ctx.user.role)) {
      throw new TRPCError({
        code: 'FORBIDDEN',
        message: `Access restricted to: ${allowedRoles.join(', ')}`,
      });
    }

    return next({
      ctx: {
        ...ctx,
        user: ctx.user, // narrowed: guaranteed non-null past this point
      },
    });
  });

// Pre-built procedure helpers for common roles
export const adminProcedure = t.procedure.use(requireRole('admin'));
export const editorProcedure = t.procedure.use(requireRole('admin', 'editor'));
export const viewerProcedure = t.procedure.use(requireRole('admin', 'editor', 'viewer'));
```

**Key Points:**
- `requireRole` is a factory — call it with any combination of roles.
- Throwing `TRPCError` with `FORBIDDEN` signals a role violation specifically, distinct from `UNAUTHORIZED` (not logged in).
- The `next()` call passes a narrowed context downstream, so procedures know the user is present.

> [Disclaimer] The type narrowing in `next()` aids TypeScript inference but does not replace runtime checks. Behavior depends on your TypeScript configuration and tRPC version.

---

### Using Role-Protected Procedures

```ts
// server/routers/content.ts
import { router, adminProcedure, editorProcedure, viewerProcedure } from '../trpc';
import { z } from 'zod';

export const contentRouter = router({
  // Any authenticated user with at least 'viewer' role
  list: viewerProcedure.query(async ({ ctx }) => {
    return await db.content.findMany();
  }),

  // 'editor' or 'admin' only
  create: editorProcedure
    .input(z.object({ title: z.string(), body: z.string() }))
    .mutation(async ({ input, ctx }) => {
      return await db.content.create({
        data: { ...input, authorId: ctx.user.id },
      });
    }),

  // 'admin' only
  delete: adminProcedure
    .input(z.object({ id: z.string() }))
    .mutation(async ({ input }) => {
      return await db.content.delete({ where: { id: input.id } });
    }),
});
```

---

### Visualizing the RBAC Flow

<svg viewBox="0 0 720 420" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="13">
  <!-- Background -->
  <rect width="720" height="420" fill="#0f1117" rx="12"/>

  <!-- Title -->
  <text x="360" y="36" fill="#e2e8f0" font-size="15" font-weight="bold" text-anchor="middle">tRPC RBAC Middleware Flow</text>

  <!-- Client box -->
  <rect x="30" y="60" width="120" height="48" rx="8" fill="#1e293b" stroke="#334155" stroke-width="1.5"/>
  <text x="90" y="80" fill="#94a3b8" text-anchor="middle" font-size="12">Client</text>
  <text x="90" y="97" fill="#7dd3fc" text-anchor="middle" font-size="11">Calls procedure</text>

  <!-- Arrow 1 -->
  <line x1="152" y1="84" x2="198" y2="84" stroke="#475569" stroke-width="1.5" marker-end="url(#arrow)"/>

  <!-- Auth Middleware -->
  <rect x="200" y="60" width="140" height="48" rx="8" fill="#1e293b" stroke="#334155" stroke-width="1.5"/>
  <text x="270" y="80" fill="#94a3b8" text-anchor="middle" font-size="12">Auth Middleware</text>
  <text x="270" y="97" fill="#fbbf24" text-anchor="middle" font-size="11">Is user logged in?</text>

  <!-- Arrow 2 -->
  <line x1="342" y1="84" x2="388" y2="84" stroke="#475569" stroke-width="1.5" marker-end="url(#arrow)"/>

  <!-- Role Middleware -->
  <rect x="390" y="60" width="140" height="48" rx="8" fill="#1e293b" stroke="#334155" stroke-width="1.5"/>
  <text x="460" y="80" fill="#94a3b8" text-anchor="middle" font-size="12">Role Middleware</text>
  <text x="460" y="97" fill="#fbbf24" text-anchor="middle" font-size="11">Has required role?</text>

  <!-- Arrow 3 -->
  <line x1="532" y1="84" x2="578" y2="84" stroke="#475569" stroke-width="1.5" marker-end="url(#arrow)"/>

  <!-- Procedure -->
  <rect x="580" y="60" width="110" height="48" rx="8" fill="#14532d" stroke="#16a34a" stroke-width="1.5"/>
  <text x="635" y="80" fill="#86efac" text-anchor="middle" font-size="12">Procedure</text>
  <text x="635" y="97" fill="#4ade80" text-anchor="middle" font-size="11">Executes ✓</text>

  <!-- Auth fail path -->
  <line x1="270" y1="108" x2="270" y2="175" stroke="#ef4444" stroke-width="1.5" stroke-dasharray="5,3" marker-end="url(#arrowRed)"/>
  <rect x="190" y="178" width="160" height="44" rx="8" fill="#450a0a" stroke="#ef4444" stroke-width="1.5"/>
  <text x="270" y="196" fill="#fca5a5" text-anchor="middle" font-size="12">UNAUTHORIZED</text>
  <text x="270" y="212" fill="#f87171" text-anchor="middle" font-size="11">401 — Not logged in</text>

  <!-- Role fail path -->
  <line x1="460" y1="108" x2="460" y2="175" stroke="#f97316" stroke-width="1.5" stroke-dasharray="5,3" marker-end="url(#arrowOrange)"/>
  <rect x="378" y="178" width="164" height="44" rx="8" fill="#431407" stroke="#f97316" stroke-width="1.5"/>
  <text x="460" y="196" fill="#fdba74" text-anchor="middle" font-size="12">FORBIDDEN</text>
  <text x="460" y="212" fill="#fb923c" text-anchor="middle" font-size="11">403 — Wrong role</text>

  <!-- Role ladder section -->
  <text x="360" y="268" fill="#64748b" font-size="12" text-anchor="middle">── Role Hierarchy Example ──</text>

  <!-- Viewer -->
  <rect x="50" y="285" width="180" height="100" rx="8" fill="#1e293b" stroke="#334155" stroke-width="1.5"/>
  <text x="140" y="305" fill="#94a3b8" font-size="12" text-anchor="middle" font-weight="bold">viewer</text>
  <text x="140" y="323" fill="#64748b" font-size="11" text-anchor="middle">• list</text>
  <text x="140" y="340" fill="#64748b" font-size="11" text-anchor="middle">• read</text>

  <!-- Editor -->
  <rect x="270" y="285" width="180" height="100" rx="8" fill="#1e293b" stroke="#3b82f6" stroke-width="1.5"/>
  <text x="360" y="305" fill="#93c5fd" font-size="12" text-anchor="middle" font-weight="bold">editor</text>
  <text x="360" y="323" fill="#64748b" font-size="11" text-anchor="middle">• list, read</text>
  <text x="360" y="340" fill="#64748b" font-size="11" text-anchor="middle">• create, update</text>

  <!-- Admin -->
  <rect x="490" y="285" width="180" height="100" rx="8" fill="#1e293b" stroke="#a855f7" stroke-width="1.5"/>
  <text x="580" y="305" fill="#d8b4fe" font-size="12" text-anchor="middle" font-weight="bold">admin</text>
  <text x="580" y="323" fill="#64748b" font-size="11" text-anchor="middle">• list, read</text>
  <text x="580" y="340" fill="#64748b" font-size="11" text-anchor="middle">• create, update</text>
  <text x="580" y="357" fill="#64748b" font-size="11" text-anchor="middle">• delete, manage</text>

  <!-- Arrowhead markers -->
  <defs>
    <marker id="arrow" markerWidth="8" markerHeight="8" refX="6" refY="3" orient="auto">
      <path d="M0,0 L0,6 L8,3 z" fill="#475569"/>
    </marker>
    <marker id="arrowRed" markerWidth="8" markerHeight="8" refX="6" refY="3" orient="auto">
      <path d="M0,0 L0,6 L8,3 z" fill="#ef4444"/>
    </marker>
    <marker id="arrowOrange" markerWidth="8" markerHeight="8" refX="6" refY="3" orient="auto">
      <path d="M0,0 L0,6 L8,3 z" fill="#f97316"/>
    </marker>
  </defs>
</svg>

---

### Composing Multiple Role Middlewares

You can layer middleware for finer-grained control — for example, checking resource ownership on top of role.

```ts
const isOwnerOrAdmin = t.middleware(async ({ ctx, next, rawInput }) => {
  if (!ctx.user) throw new TRPCError({ code: 'UNAUTHORIZED' });

  const input = rawInput as { id: string };
  const resource = await db.content.findUnique({ where: { id: input.id } });

  const isAdmin = ctx.user.role === 'admin';
  const isOwner = resource?.authorId === ctx.user.id;

  if (!isAdmin && !isOwner) {
    throw new TRPCError({
      code: 'FORBIDDEN',
      message: 'You do not own this resource.',
    });
  }

  return next({ ctx });
});

export const ownerOrAdminProcedure = t.procedure.use(isOwnerOrAdmin);
```

**Key Points:**
- Middleware chains are composable — each `.use()` call appends to the chain.
- The order matters: authentication checks should run before role checks.
- Resource-level checks (ownership) are separate from role-level checks and add a second layer.

> [Disclaimer] Middleware composition behavior depends on tRPC version. Always test chained middleware in your target version.

---

### Scoping RBAC to Entire Routers

Rather than applying middleware per-procedure, you can apply it at the router level for blanket protection.

```ts
// server/routers/admin.ts
import { router, adminProcedure } from '../trpc';
import { z } from 'zod';

// Every procedure here inherits the admin requirement
export const adminRouter = router({
  listUsers: adminProcedure.query(async () => {
    return await db.user.findMany();
  }),

  updateRole: adminProcedure
    .input(z.object({ userId: z.string(), role: z.enum(['admin', 'editor', 'viewer']) }))
    .mutation(async ({ input }) => {
      return await db.user.update({
        where: { id: input.userId },
        data: { role: input.role },
      });
    }),
});
```

This pattern reduces repetition and makes access intent explicit at the router boundary.

---

### Testing Role Enforcement

[Inference] The following testing pattern is typical; adjust to your test framework. Behavior of test utilities varies.

```ts
// __tests__/rbac.test.ts
import { createCallerFactory } from '@trpc/server';
import { appRouter } from '../server/routers/_app';

const createCaller = createCallerFactory(appRouter);

test('viewer cannot delete content', async () => {
  const caller = createCaller({
    user: { id: 'u1', email: 'v@test.com', role: 'viewer' },
  });

  await expect(caller.content.delete({ id: 'c1' })).rejects.toMatchObject({
    code: 'FORBIDDEN',
  });
});

test('admin can delete content', async () => {
  const caller = createCaller({
    user: { id: 'u2', email: 'a@test.com', role: 'admin' },
  });

  // Assumes test DB or mock is set up
  await expect(caller.content.delete({ id: 'c1' })).resolves.toBeDefined();
});
```

---

### Common Pitfalls

| Pitfall | Issue | Mitigation |
|---|---|---|
| Trusting client-sent roles | Client could forge role claims | Always derive roles server-side from session/DB |
| Skipping auth check before role check | Null user access on `ctx.user.role` | Always check `ctx.user` exists first |
| Hardcoding role strings | Typos cause silent failures | Use a `Role` type or enum |
| Over-permissive fallback | Default role grants too much access | Default to least-privilege (e.g. `viewer` or no role) |
| No ownership checks | Role alone may not be sufficient | Combine role + resource ownership where needed |

---

### Summary

**Conclusion:** RBAC in tRPC is implemented manually using middleware, typed context, and procedure factories. There is no built-in RBAC system — the pattern relies on composing tRPC's primitives intentionally. The core building blocks are: a context that carries role data, a middleware factory that validates roles, and role-scoped procedure helpers that are reused across routers.

**Next Steps:**
- Input validation and Zod schemas
- Error handling patterns and custom error formatting
- Procedure-level rate limiting