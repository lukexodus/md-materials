## Higher-Order Routers

---

### Overview

A higher-order router is a function that accepts a router (or router configuration) as input and returns a new, augmented router. The term borrows from the functional programming concept of higher-order functions — functions that operate on other functions.

In tRPC, routers are plain objects produced by `t.router()`. Because they are values, they can be passed to functions, wrapped, merged, and transformed. This makes higher-order router patterns possible without any special framework support.

Higher-order routers are distinct from procedure factories: factories operate at the **procedure level**, producing reusable builders. Higher-order routers operate at the **router level**, transforming or composing entire groups of procedures.

---

### Motivation

Consider these recurring needs in larger tRPC applications:

- Every procedure in an admin router must require the `admin` role
- Every procedure in a versioned router must be prefixed or tagged
- Audit logging must wrap every mutation in a billing router
- A feature-flagged router should be conditionally exposed

Solving these at the procedure level means touching every procedure. Higher-order routers solve them once, at the router boundary.

---

### Basic Pattern: Router Wrapper Function

The simplest higher-order router is a function that accepts a record of procedure definitions and passes them through `t.router()` after applying some transformation.

```ts
// server/lib/withAdminGuard.ts
import { TRPCError } from '@trpc/server';
import { router, adminProcedure } from '../trpc';
import type { AnyRouter } from '@trpc/server';

// Accepts a router factory function, returns a guarded router
export function withAdminGuard<T extends AnyRouter>(
  routerFactory: () => T
): T {
  // This pattern wraps via middleware at the procedure factory level.
  // For true router-level interception, see the middleware composition
  // approach below.
  return routerFactory();
}
```

**Key Points:**

- Pure router wrapping in tRPC is limited by the fact that `t.router()` finalizes procedure definitions — you cannot add middleware to an already-constructed router [Inference: based on tRPC v10/v11 architecture; behavior may differ in future versions]
- The practical higher-order router pattern in tRPC works by wrapping the **input to** `t.router()`, not the router object itself
- For true cross-cutting behavior, the pattern is to pass a **procedure builder** into a factory function that builds the router using that builder

---

### Pattern: Procedure-Builder Injection

The most idiomatic higher-order router pattern in tRPC passes a base procedure into a router factory. This allows the caller to control what middleware all procedures in the router inherit.

```ts
// server/routers/factories/createCrudRouter.ts
import { z } from 'zod';
import { router } from '../trpc';
import type { ProcedureBuilder } from '@trpc/server';

interface CrudRouterOptions<TItem> {
  procedure: any; // base procedure builder
  findMany: () => Promise<TItem[]>;
  findOne: (id: string) => Promise<TItem | null>;
  create: (data: unknown) => Promise<TItem>;
  remove: (id: string) => Promise<void>;
}

export function createCrudRouter<TItem>({
  procedure,
  findMany,
  findOne,
  create,
  remove,
}: CrudRouterOptions<TItem>) {
  return router({
    list: procedure.query(() => findMany()),

    get: procedure
      .input(z.object({ id: z.string() }))
      .query(({ input }) => findOne(input.id)),

    create: procedure
      .input(z.object({ data: z.unknown() }))
      .mutation(({ input }) => create(input.data)),

    delete: procedure
      .input(z.object({ id: z.string() }))
      .mutation(({ input }) => remove(input.id)),
  });
}
```

**Usage — different access levels for different resources:**

```ts
// server/routers/index.ts
import { createCrudRouter } from './factories/createCrudRouter';
import { publicProcedure, protectedProcedure, adminProcedure } from '../trpc';
import { db } from '../db';

const tagRouter = createCrudRouter({
  procedure: publicProcedure,       // tags are publicly readable/writable
  findMany: () => db.tag.findMany(),
  findOne: (id) => db.tag.findUnique({ where: { id } }),
  create: (data) => db.tag.create({ data: data as any }),
  remove: (id) => db.tag.delete({ where: { id } }),
});

const invoiceRouter = createCrudRouter({
  procedure: protectedProcedure,    // invoices require auth
  findMany: () => db.invoice.findMany(),
  findOne: (id) => db.invoice.findUnique({ where: { id } }),
  create: (data) => db.invoice.create({ data: data as any }),
  remove: (id) => db.invoice.delete({ where: { id } }),
});

const userAdminRouter = createCrudRouter({
  procedure: adminProcedure,        // user admin requires admin role
  findMany: () => db.user.findMany(),
  findOne: (id) => db.user.findUnique({ where: { id } }),
  create: (data) => db.user.create({ data: data as any }),
  remove: (id) => db.user.delete({ where: { id } }),
});
```

**Key Points:**

- The factory encapsulates the procedure shape; the caller controls the trust level
- The same CRUD contract is reused across three different authorization contexts
- Typing `procedure` as `any` is a known limitation when working with generic procedure builders in tRPC — stricter typing is possible but requires more complex generics [Inference: exact type constraints depend on tRPC version and TypeScript version in use]

---

### Pattern: Feature-Flagged Router

A higher-order router can conditionally expose procedures based on runtime configuration.

```ts
// server/lib/withFeatureFlag.ts
import { router } from '../trpc';
import { TRPCError } from '@trpc/server';
import type { AnyRouter } from '@trpc/server';

export function withFeatureFlag<T extends Record<string, any>>(
  flag: boolean,
  routerDefinition: T
): AnyRouter {
  if (!flag) {
    // Return an empty router — all routes in this subtree are absent
    return router({});
  }

  return router(routerDefinition);
}
```

**Usage:**

```ts
const betaRouter = withFeatureFlag(
  process.env.ENABLE_BETA === 'true',
  {
    newFeature: protectedProcedure.query(() => ({ enabled: true })),
  }
);

export const appRouter = router({
  user: userRouter,
  beta: betaRouter,
});
```

**Key Points:**

- When the flag is `false`, the subtree is an empty router — calling any procedure under `beta.*` results in a not-found error
- This is a coarse-grained mechanism. Per-procedure flags are better handled inside individual resolvers or middleware [Inference]
- Flag evaluation at module load time means changes require a server restart unless the flag source is re-evaluated per request

---

### Pattern: Versioned Router

Higher-order routers can produce versioned API namespaces from a shared procedure set.

```ts
// server/lib/createVersionedRouter.ts
import { router } from '../trpc';

interface VersionedRouterConfig {
  v1: Record<string, any>;
  v2: Record<string, any>;
}

export function createVersionedRouter({ v1, v2 }: VersionedRouterConfig) {
  return router({
    v1: router(v1),
    v2: router(v2),
  });
}
```

**Usage:**

```ts
export const postRouter = createVersionedRouter({
  v1: {
    list: publicProcedure.query(() => db.post.findMany()),
  },
  v2: {
    list: publicProcedure
      .input(z.object({ cursor: z.string().optional() }))
      .query(({ input }) => getCursorPage(input.cursor)),
  },
});

// Client accesses: trpc.post.v1.list or trpc.post.v2.list
```

---

### Pattern: Audit-Wrapped Router

A factory can wrap every procedure in a router with audit logging by intercepting the procedure builders before the router is finalized.

```ts
// server/lib/withAudit.ts
import { protectedProcedure, router } from '../trpc';
import { logAuditEvent } from '../audit';

type ProcedureMap = Record<string, any>;

export function withAudit(procedures: ProcedureMap) {
  const audited: ProcedureMap = {};

  for (const [key, procedure] of Object.entries(procedures)) {
    audited[key] = procedure.use(async ({ ctx, next, path }: any) => {
      const result = await next({ ctx });
      await logAuditEvent({
        userId: ctx.session?.user?.id ?? 'anonymous',
        procedure: path,
        success: result.ok,
        timestamp: new Date(),
      });
      return result;
    });
  }

  return router(audited);
}
```

**Usage:**

```ts
export const billingRouter = withAudit({
  charge: protectedProcedure
    .input(z.object({ amount: z.number() }))
    .mutation(({ input }) => processCharge(input.amount)),

  refund: protectedProcedure
    .input(z.object({ chargeId: z.string() }))
    .mutation(({ input }) => processRefund(input.chargeId)),
});
```

**Key Points:**

- This approach adds middleware dynamically to each procedure definition before passing them to `router()`
- It relies on the procedures still being builders (not yet finalized) at the point of wrapping
- [Inference: this pattern depends on tRPC's internal builder API remaining stable; test against your specific version]

---

### Visualizing Higher-Order Router Composition

publicprotectedadminpublicProcedurecreateCrudRouterprotectedProcedureadminProceduretagRouterlist / get / create / deleteinvoiceRouterlist / get / create / deleteuserAdminRouterlist / get / create / deleteappRouterwithAuditbillingRoutercharge / refundwithFeatureFlagbetaRouternewFeature or empty

---

### Limitations and Caveats

**Post-construction immutability:**
Once `t.router()` is called, the resulting router object cannot be augmented with new middleware. Higher-order patterns must operate before `t.router()` is called — on procedure builders, not on finalized routers. [Inference: based on tRPC v10/v11 design; verify for your version]

**Type inference complexity:**
Generic factory functions that accept procedure builders can produce complex TypeScript types. In practice, using `any` for the procedure parameter and relying on the router's inferred type at the call site is a common trade-off. Strict typing requires careful use of tRPC's internal builder types, which are not part of the stable public API. [Inference]

**No runtime router introspection:**
tRPC does not expose a runtime API for enumerating or modifying procedures after a router is built. Patterns that require inspecting procedure metadata (e.g., for OpenAPI generation) must rely on tRPC's type system or third-party plugins like `trpc-openapi`. [Unverified: verify current plugin compatibility with your tRPC version]

---

**Conclusion**

Higher-order routers in tRPC are best understood as functions that operate on procedure builders or procedure maps before those are passed to `t.router()`. The two most productive patterns are procedure-builder injection — where the caller controls the trust level of an entire router — and procedure-map wrapping, where cross-cutting behavior like audit logging is applied uniformly. These patterns reduce duplication at the router level and complement the procedure factory patterns that operate at the individual procedure level.