## Multi-Tenant Routing Patterns

---

### Overview

Multi-tenancy is an architecture where a single application instance serves multiple independent tenants — organizations, workspaces, or accounts — whose data and access must be isolated from one another. In tRPC, multi-tenancy is not a built-in feature. It is implemented through a combination of context construction, middleware, and routing conventions.

The core challenge is: every procedure that touches tenant-scoped data must know **which tenant** the request belongs to and must **enforce that the requesting user belongs to that tenant** before accessing or mutating any data.

---

### Tenant Identification Strategies

Before any routing or middleware can enforce tenancy, the server must determine which tenant a request belongs to. The three common identification strategies are:

#### Subdomain-Based

The tenant is identified from the request's `Host` header.

```
acme.yourapp.com     → tenantSlug: "acme"
globex.yourapp.com   → tenantSlug: "globex"
```

#### Path-Based

The tenant identifier is embedded in the URL path, often as a route segment.

```
yourapp.com/t/acme/api/trpc/...
yourapp.com/t/globex/api/trpc/...
```

#### Header or Token-Based

The tenant is specified via a custom request header or encoded inside the authentication token (e.g., a JWT claim).

```
X-Tenant-ID: acme
```

Or decoded from a JWT:

```json
{
  "sub": "user_123",
  "tenantId": "acme",
  "role": "admin"
}
```

**Key Points:**

- Subdomain-based is common in SaaS products with white-labeling requirements
- Path-based is simpler to implement and works without DNS wildcard configuration
- Token-based is well-suited when tenancy is tightly coupled to authentication

---

### Context Construction for Multi-Tenancy

Tenant resolution belongs in context creation — before any procedure runs. This centralizes the logic and makes `ctx.tenant` available to all middleware and resolvers.

```ts
// server/context.ts
import { inferAsyncReturnType } from '@trpc/server';
import type { CreateNextContextOptions } from '@trpc/server/adapters/next';
import { db } from './db';
import { getSession } from './auth';

export async function createContext({ req }: CreateNextContextOptions) {
  const session = await getSession(req);

  // Strategy 1: resolve from subdomain
  const host = req.headers.host ?? '';
  const subdomain = host.split('.')[0];

  // Strategy 2: resolve from custom header
  const tenantHeader = req.headers['x-tenant-id'] as string | undefined;

  // Strategy 3: resolve from session/JWT claim
  const tenantFromSession = session?.user?.tenantId;

  // Prefer session claim; fall back to header; fall back to subdomain
  const tenantSlug = tenantFromSession ?? tenantHeader ?? subdomain;

  const tenant = tenantSlug
    ? await db.tenant.findUnique({ where: { slug: tenantSlug } })
    : null;

  return {
    req,
    session,
    tenant,      // null if unresolved
    db,
  };
}

export type Context = inferAsyncReturnType<typeof createContext>;
```

**Key Points:**

- The context resolves the tenant once per request — not once per procedure
- `ctx.tenant` is nullable at this stage; middleware enforces that it is present before tenant-scoped procedures run
- Caching the tenant lookup result in context avoids redundant database queries across multiple procedures in a single batch request [Inference: tRPC batch requests share a single context instance; verify this holds for your adapter and version]

---

### Tenant Guard Middleware

A dedicated middleware validates that the resolved tenant exists and that the authenticated user belongs to it.

```ts
// server/middleware/tenantGuard.ts
import { middleware, t } from '../trpc';
import { TRPCError } from '@trpc/server';
import { db } from '../db';

export const tenantGuard = middleware(async ({ ctx, next }) => {
  if (!ctx.session?.user) {
    throw new TRPCError({ code: 'UNAUTHORIZED' });
  }

  if (!ctx.tenant) {
    throw new TRPCError({
      code: 'NOT_FOUND',
      message: 'Tenant not found.',
    });
  }

  // Verify the authenticated user belongs to this tenant
  const membership = await db.tenantMembership.findUnique({
    where: {
      userId_tenantId: {
        userId: ctx.session.user.id,
        tenantId: ctx.tenant.id,
      },
    },
  });

  if (!membership) {
    throw new TRPCError({
      code: 'FORBIDDEN',
      message: 'You do not have access to this tenant.',
    });
  }

  return next({
    ctx: {
      ...ctx,
      tenant: ctx.tenant,           // narrowed — non-nullable
      session: ctx.session,         // narrowed — non-nullable
      membership,                   // available to downstream procedures
    },
  });
});
```

**Key Points:**

- The middleware narrows `ctx.tenant` and `ctx.session` from nullable to non-nullable for all downstream procedures
- The membership check is the critical isolation boundary — without it, a user could pass a valid tenant slug that they do not belong to
- This middleware should be applied to every procedure that accesses tenant-scoped data, without exception

---

### Tenant-Scoped Base Procedure

The guard middleware is composed into a base procedure, following the same factory pattern used for authentication:

```ts
// server/trpc.ts
import { tenantGuard } from './middleware/tenantGuard';

export const publicProcedure = t.procedure;
export const protectedProcedure = t.procedure.use(authGuard);
export const tenantProcedure = protectedProcedure.use(tenantGuard);
```

All tenant-scoped routers use `tenantProcedure` as their base:

```ts
// server/routers/project.ts
import { z } from 'zod';
import { router, tenantProcedure } from '../trpc';

export const projectRouter = router({
  list: tenantProcedure
    .query(({ ctx }) => {
      return ctx.db.project.findMany({
        where: { tenantId: ctx.tenant.id },  // always scoped to tenant
      });
    }),

  create: tenantProcedure
    .input(z.object({ name: z.string().min(1) }))
    .mutation(({ input, ctx }) => {
      return ctx.db.project.create({
        data: {
          name: input.name,
          tenantId: ctx.tenant.id,  // tenant ID sourced from context, not input
        },
      });
    }),

  delete: tenantProcedure
    .input(z.object({ id: z.string() }))
    .mutation(async ({ input, ctx }) => {
      // Verify the record belongs to this tenant before deleting
      const project = await ctx.db.project.findUnique({
        where: { id: input.id },
      });

      if (!project || project.tenantId !== ctx.tenant.id) {
        throw new TRPCError({
          code: 'NOT_FOUND',
          message: 'Project not found.',
        });
      }

      return ctx.db.project.delete({ where: { id: input.id } });
    }),
});
```

**Key Points:**

- `tenantId` is always sourced from `ctx.tenant.id` — never from user-supplied input — for write operations
- The `delete` procedure performs an explicit ownership check before acting, guarding against **insecure direct object reference (IDOR)**: a user supplying a valid ID for a record in a different tenant [Inference: IDOR is a class of vulnerability; whether this pattern fully mitigates it depends on the completeness of ownership checks across all procedures]
- Read operations scope queries with `where: { tenantId: ctx.tenant.id }` at the database level

---

### Role-Based Access Within a Tenant

Tenants typically have their own role hierarchy — a user may be an `owner`, `admin`, or `member` within a specific tenant, independent of any global role.

```ts
// server/middleware/tenantRole.ts
import { middleware } from '../trpc';
import { TRPCError } from '@trpc/server';

type TenantRole = 'owner' | 'admin' | 'member';

export function requireTenantRole(role: TenantRole) {
  return middleware(({ ctx, next }: any) => {
    const roleHierarchy: TenantRole[] = ['member', 'admin', 'owner'];
    const userRoleIndex = roleHierarchy.indexOf(ctx.membership.role);
    const requiredRoleIndex = roleHierarchy.indexOf(role);

    if (userRoleIndex < requiredRoleIndex) {
      throw new TRPCError({
        code: 'FORBIDDEN',
        message: `Requires ${role} role within this tenant.`,
      });
    }

    return next({ ctx });
  });
}
```

**Usage:**

```ts
// tenantProcedure already enforces membership
export const tenantAdminProcedure = tenantProcedure.use(requireTenantRole('admin'));
export const tenantOwnerProcedure = tenantProcedure.use(requireTenantRole('owner'));
```

```ts
export const settingsRouter = router({
  get: tenantProcedure          // any member can read settings
    .query(({ ctx }) =>
      ctx.db.tenantSettings.findUnique({ where: { tenantId: ctx.tenant.id } })
    ),

  update: tenantAdminProcedure  // only admin or owner can update
    .input(z.object({ allowSignups: z.boolean() }))
    .mutation(({ input, ctx }) =>
      ctx.db.tenantSettings.update({
        where: { tenantId: ctx.tenant.id },
        data: input,
      })
    ),

  delete: tenantOwnerProcedure  // only owner can delete the tenant
    .mutation(({ ctx }) =>
      ctx.db.tenant.delete({ where: { id: ctx.tenant.id } })
    ),
});
```

---

### Visualizing the Multi-Tenant Middleware Stack

NoYesNoYesNoYesNoYesNoYesIncoming RequestcreateContextTenant resolved?NOT_FOUNDauthGuard middlewareUser authenticated?UNAUTHORIZEDtenantGuard middlewareUser is member?FORBIDDENRole check required?Procedure ResolverRole sufficient?FORBIDDENDB query scoped totenantIdResponse

---

### Cross-Tenant Procedures

Some procedures legitimately operate across tenants — super-admin dashboards, platform-level billing, system health endpoints. These require a separate base procedure that explicitly opts out of tenant scoping.

```ts
// server/trpc.ts
export const superAdminProcedure = protectedProcedure.use(({ ctx, next }) => {
  if (!ctx.session.user.isSuperAdmin) {
    throw new TRPCError({ code: 'FORBIDDEN' });
  }
  return next({ ctx });
});
```

```ts
// server/routers/platform.ts
export const platformRouter = router({
  listTenants: superAdminProcedure
    .query(() => ctx.db.tenant.findMany()),

  impersonate: superAdminProcedure
    .input(z.object({ tenantId: z.string() }))
    .mutation(({ input }) => {
      // platform-level impersonation logic
    }),
});
```

**Key Points:**

- `superAdminProcedure` deliberately does not use `tenantProcedure` — it bypasses tenant scoping by design
- These procedures should be in a clearly separated router namespace (`platform.*`) to make the bypass explicit and auditable
- Impersonation and cross-tenant access should be logged with particular care [Inference]

---

### Tenant Isolation at the Database Level

Middleware-level isolation is necessary but not the only defense. For high-security requirements, database-level row isolation provides a secondary enforcement layer.

**Using Prisma with a tenant-scoped client extension:**

```ts
// server/db.ts
import { PrismaClient } from '@prisma/client';

export function getTenantDb(tenantId: string) {
  return new PrismaClient().$extends({
    query: {
      $allModels: {
        async findMany({ args, query }) {
          args.where = { ...args.where, tenantId };
          return query(args);
        },
        async findUnique({ args, query }) {
          args.where = { ...args.where, tenantId } as any;
          return query(args);
        },
      },
    },
  });
}
```

This automatically injects `tenantId` into every query, reducing the risk of a procedure accidentally omitting the scope. [Inference: Prisma client extensions are available from Prisma v4.7.0+; behavior and API may differ across versions — verify against your installed version]

**Usage in context:**

```ts
export async function createContext({ req }: CreateNextContextOptions) {
  // ... tenant resolution ...

  return {
    session,
    tenant,
    db: tenant ? getTenantDb(tenant.id) : db, // scoped client when tenant is known
  };
}
```

---

### Common Pitfalls

**Pitfall 1 — Trusting tenant ID from user input:**
Never accept `tenantId` as a procedure input and use it directly for data access. Always derive it from the verified context. A user could supply any tenant ID and access data they do not own.

**Pitfall 2 — Forgetting ownership checks on mutations:**
Scoping `findMany` queries with `tenantId` is straightforward. Mutations that operate on a specific record by ID must also verify the record belongs to the tenant — fetching by `id` alone is insufficient.

**Pitfall 3 — Skipping tenant guard on related-entity procedures:**
A procedure that operates on a `Comment` rather than a `Project` may seem lower-risk, but if the comment belongs to a project that belongs to a tenant, the same isolation rules apply through the full ownership chain.

**Pitfall 4 — Inconsistent context between batch and single requests:**
In tRPC batch requests, multiple procedures share a single context. Tenant resolution in context is therefore evaluated once. If procedures in a batch belong to different tenants — an unusual but possible scenario — this context model does not accommodate it. [Inference: standard tRPC batching assumes a single tenant per batch]

---

**Conclusion**

Multi-tenant routing in tRPC is built from three cooperating layers: tenant resolution in context construction, membership enforcement in middleware, and scoped database queries in resolvers. The tenant-scoped base procedure — derived from a chain of auth and tenant guard middleware — is the central abstraction that keeps isolation consistent across an entire router tree. Defense-in-depth, combining middleware checks with database-level scoping, reduces the risk that any single omission exposes cross-tenant data.