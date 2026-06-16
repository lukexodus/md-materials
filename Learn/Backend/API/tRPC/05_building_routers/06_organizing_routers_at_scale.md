## Organizing Routers at Scale

When a tRPC application grows beyond a handful of procedures, ad-hoc file organization produces maintenance problems: unclear ownership, difficult navigation, inconsistent access patterns, and brittle imports. Deliberate organizational strategy applied early prevents these problems from compounding.

---

### The Core Problem at Scale

A single flat router file does not scale. The issues that emerge as procedure count grows:

**Key Points**

- Merge conflicts become frequent when multiple developers edit the same router file.
- Procedure discoverability degrades — finding the right procedure requires reading through an increasingly large file.
- Testing becomes harder when unrelated procedures share a single module boundary.
- Access control becomes inconsistent when middleware is applied procedure-by-procedure without a structural convention.
- The root router file accumulates imports and becomes a coordination bottleneck.

---

### Foundational Principle: The Root Router as Assembly Point

At scale, the root router should contain no procedures directly. Its sole responsibility is importing and composing feature routers.

```ts
// src/server/routers/_app.ts
import { router } from '../../trpc';
import { userRouter } from './user';
import { postRouter } from './post';
import { commentRouter } from './comment';
import { adminRouter } from './admin/_admin';
import { billingRouter } from './billing';

export const appRouter = router({
  user: userRouter,
  post: postRouter,
  comment: commentRouter,
  admin: adminRouter,
  billing: billingRouter,
});

export type AppRouter = typeof appRouter;
```

**Key Points**

- No business logic lives here.
- The file serves as an index of the API's top-level namespaces.
- Adding a new feature requires one new import and one new key — nothing else changes.

---

### Directory Structure Patterns

#### Flat Feature Structure

Suitable for small to medium applications where each feature is self-contained in a single file.

```
src/server/routers/
  _app.ts
  user.ts
  post.ts
  comment.ts
  billing.ts
  admin.ts
```

#### Nested Feature Structure

Suitable when features grow large enough to warrant internal decomposition.

```
src/server/routers/
  _app.ts
  user/
    index.ts          ← exports userRouter
    profile.ts
    preferences.ts
    auth.ts
  post/
    index.ts          ← exports postRouter
    crud.ts
    search.ts
    moderation.ts
  admin/
    index.ts          ← exports adminRouter
    users.ts
    analytics.ts
  billing/
    index.ts
    subscriptions.ts
    invoices.ts
```

Each feature directory exposes a single `index.ts` that assembles and exports its router. Internal files are implementation details — nothing outside the feature directory imports them directly.

```ts
// src/server/routers/post/index.ts
import { router } from '../../../trpc';
import { postCrudRouter } from './crud';
import { postSearchRouter } from './search';
import { postModerationRouter } from './moderation';

export const postRouter = router({
  crud: postCrudRouter,
  search: postSearchRouter,
  moderation: postModerationRouter,
});
```

---

### Co-locating Related Concerns

At scale, a router file that only contains procedure definitions tends to grow unwieldy. Splitting concerns into sibling files within the feature directory improves readability.

```
src/server/routers/user/
  index.ts            ← router definition
  user.service.ts     ← business logic called by resolvers
  user.schema.ts      ← Zod schemas for input/output
  user.test.ts        ← procedure tests
```

```ts
// user.schema.ts
import { z } from 'zod';

export const getUserByIdInput = z.object({ id: z.string() });
export const updateUserInput = z.object({
  bio: z.string().max(300).optional(),
  displayName: z.string().min(1).max(50).optional(),
});
```

```ts
// user.service.ts
export async function getUserById(id: string, db: DB) {
  return db.user.findUnique({ where: { id } });
}
```

```ts
// index.ts
import { router, protectedProcedure, publicProcedure } from '../../../trpc';
import { getUserByIdInput, updateUserInput } from './user.schema';
import { getUserById } from './user.service';

export const userRouter = router({
  getById: publicProcedure
    .input(getUserByIdInput)
    .query(({ input, ctx }) => getUserById(input.id, ctx.db)),

  update: protectedProcedure
    .input(updateUserInput)
    .mutation(({ input, ctx }) => { /* ... */ }),
});
```

**Key Points**

- Resolvers become thin — they validate input, call a service function, and return.
- Service functions are independently testable without tRPC context.
- Schema files can be shared between input validation and output validation without circular dependencies.

---

### Procedure Base Hierarchy

At scale, middleware composition needs its own organizational layer. A dedicated procedures file exports all base procedure variants.

```ts
// src/server/trpc/procedures.ts
import { t } from './instance';
import { requireAuth } from './middleware/requireAuth';
import { requireAdmin } from './middleware/requireAdmin';
import { requireSubscription } from './middleware/requireSubscription';

export const publicProcedure = t.procedure;

export const protectedProcedure = t.procedure
  .use(requireAuth);

export const adminProcedure = t.procedure
  .use(requireAuth)
  .use(requireAdmin);

export const subscriberProcedure = t.procedure
  .use(requireAuth)
  .use(requireSubscription);
```

All feature routers import from this file rather than from the tRPC instance directly.

```ts
// src/server/routers/billing/subscriptions.ts
import { protectedProcedure, subscriberProcedure, router } from '../../../trpc/procedures';
```

**Key Points**

- Adding a new access tier requires one change in one file.
- Procedure names communicate access requirements clearly at the point of use.
- The middleware chain is visible and auditable from a single location.

---

### Monorepo Structure

In a monorepo, server and client are separate packages. The API package exposes only its type surface.

```
packages/
  api/
    src/
      routers/
        _app.ts
        user/
        post/
      trpc/
        instance.ts
        procedures.ts
        context.ts
      index.ts          ← public API surface
    package.json
  web/
    src/
      trpc/
        client.ts       ← imports AppRouter type from @myorg/api
    package.json
  mobile/
    src/
      trpc/
        client.ts
```

```ts
// packages/api/src/index.ts
export type { AppRouter } from './routers/_app';
export type { Context } from './trpc/context';
// No value exports — runtime server code stays private
```

```ts
// packages/web/src/trpc/client.ts
import type { AppRouter } from '@myorg/api';
import { createTRPCClient, httpBatchLink } from '@trpc/client';

export const trpc = createTRPCClient<AppRouter>({
  links: [httpBatchLink({ url: '/api/trpc' })],
});
```

---

### Avoiding Circular Dependencies

At scale, circular imports between routers are the most structurally damaging problem. The dependency graph must remain a directed acyclic graph (DAG).

```
_app.ts
  └── user/index.ts
  └── post/index.ts
        └── post/crud.ts
        └── post/search.ts
```

**Rules that prevent cycles:**

**Key Points**

- Feature routers never import from other feature routers. If shared logic is needed, it belongs in a service layer or shared utility, not in another router.
- Sub-routers within a feature import from siblings only via the service layer — never by importing the sibling router itself.
- The root router is always a leaf in the import direction (nothing imports it except tests and the server adapter entry point).

---

### Visualizing a Scaled Router Architecture

<svg viewBox="0 0 740 520" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="12"> <!-- Server Adapter --> <rect x="270" y="14" width="200" height="34" rx="6" fill="#1e293b" stroke="#475569" stroke-width="1.5"/> <text x="370" y="36" text-anchor="middle" fill="#94a3b8">Server Adapter</text> <!-- Arrow down to appRouter --> <line x1="370" y1="48" x2="370" y2="80" stroke="#475569" stroke-width="1.5" stroke-dasharray="4,3"/> <!-- appRouter --> <rect x="270" y="80" width="200" height="36" rx="6" fill="#4f46e5"/> <text x="370" y="103" text-anchor="middle" fill="white" font-weight="bold">appRouter (_app.ts)</text> <!-- Connectors from appRouter --> <line x1="370" y1="116" x2="100" y2="180" stroke="#94a3b8" stroke-width="1.5"/> <line x1="370" y1="116" x2="260" y2="180" stroke="#94a3b8" stroke-width="1.5"/> <line x1="370" y1="116" x2="480" y2="180" stroke="#94a3b8" stroke-width="1.5"/> <line x1="370" y1="116" x2="630" y2="180" stroke="#94a3b8" stroke-width="1.5"/> <!-- Feature routers --> <rect x="30" y="180" width="140" height="34" rx="6" fill="#0f766e"/> <text x="100" y="202" text-anchor="middle" fill="white">user/index.ts</text> <rect x="190" y="180" width="140" height="34" rx="6" fill="#0f766e"/> <text x="260" y="202" text-anchor="middle" fill="white">post/index.ts</text> <rect x="410" y="180" width="140" height="34" rx="6" fill="#b45309"/> <text x="480" y="202" text-anchor="middle" fill="white">admin/index.ts</text> <rect x="560" y="180" width="140" height="34" rx="6" fill="#0f766e"/> <text x="630" y="202" text-anchor="middle" fill="white">billing/index.ts</text> <!-- user children --> <line x1="100" y1="214" x2="60" y2="268" stroke="#94a3b8" stroke-width="1.5"/> <line x1="100" y1="214" x2="120" y2="268" stroke="#94a3b8" stroke-width="1.5"/> <rect x="20" y="268" width="72" height="26" rx="4" fill="#334155"/> <text x="56" y="285" text-anchor="middle" fill="#cbd5e1">profile.ts</text> <rect x="98" y="268" width="72" height="26" rx="4" fill="#334155"/> <text x="134" y="285" text-anchor="middle" fill="#cbd5e1">prefs.ts</text> <!-- post children --> <line x1="260" y1="214" x2="220" y2="268" stroke="#94a3b8" stroke-width="1.5"/> <line x1="260" y1="214" x2="260" y2="268" stroke="#94a3b8" stroke-width="1.5"/> <line x1="260" y1="214" x2="300" y2="268" stroke="#94a3b8" stroke-width="1.5"/> <rect x="184" y="268" width="64" height="26" rx="4" fill="#334155"/> <text x="216" y="285" text-anchor="middle" fill="#cbd5e1">crud.ts</text> <rect x="252" y="268" width="64" height="26" rx="4" fill="#334155"/> <text x="284" y="285" text-anchor="middle" fill="#cbd5e1">search.ts</text> <rect x="320" y="268" width="64" height="26" rx="4" fill="#334155"/> <text x="352" y="285" text-anchor="middle" fill="#cbd5e1">mod.ts</text> <!-- admin children --> <line x1="480" y1="214" x2="450" y2="268" stroke="#94a3b8" stroke-width="1.5"/> <line x1="480" y1="214" x2="510" y2="268" stroke="#94a3b8" stroke-width="1.5"/> <rect x="414" y="268" width="72" height="26" rx="4" fill="#334155"/> <text x="450" y="285" text-anchor="middle" fill="#cbd5e1">users.ts</text> <rect x="490" y="268" width="72" height="26" rx="4" fill="#334155"/> <text x="526" y="285" text-anchor="middle" fill="#cbd5e1">analytics.ts</text> <!-- billing children --> <line x1="630" y1="214" x2="600" y2="268" stroke="#94a3b8" stroke-width="1.5"/> <line x1="630" y1="214" x2="650" y2="268" stroke="#94a3b8" stroke-width="1.5"/> <rect x="560" y="268" width="76" height="26" rx="4" fill="#334155"/> <text x="598" y="285" text-anchor="middle" fill="#cbd5e1">subs.ts</text> <rect x="640" y="268" width="76" height="26" rx="4" fill="#334155"/> <text x="678" y="285" text-anchor="middle" fill="#cbd5e1">invoices.ts</text> <!-- Shared layer --> <rect x="160" y="360" width="420" height="34" rx="6" fill="#1e293b" stroke="#475569" stroke-width="1.5"/> <text x="370" y="382" text-anchor="middle" fill="#94a3b8">Shared Service / Schema Layer</text> <!-- Dashed arrows from sub-routers to shared layer --> <line x1="100" y1="300" x2="280" y2="358" stroke="#475569" stroke-width="1" stroke-dasharray="4,3"/> <line x1="260" y1="300" x2="320" y2="358" stroke="#475569" stroke-width="1" stroke-dasharray="4,3"/> <line x1="480" y1="300" x2="420" y2="358" stroke="#475569" stroke-width="1" stroke-dasharray="4,3"/> <line x1="630" y1="300" x2="500" y2="358" stroke="#475569" stroke-width="1" stroke-dasharray="4,3"/> <!-- Procedures layer --> <rect x="160" y="430" width="420" height="34" rx="6" fill="#1e293b" stroke="#475569" stroke-width="1.5"/> <text x="370" y="452" text-anchor="middle" fill="#94a3b8">Procedure Base Layer (procedures.ts)</text> <!-- Arrow from procedures to shared --> <line x1="370" y1="430" x2="370" y2="396" stroke="#475569" stroke-width="1" stroke-dasharray="4,3"/> <!-- Legend --> <rect x="30" y="460" width="14" height="14" rx="2" fill="#4f46e5"/> <text x="50" y="472" fill="#94a3b8">Root router</text> <rect x="140" y="460" width="14" height="14" rx="2" fill="#0f766e"/> <text x="160" y="472" fill="#94a3b8">Feature router</text> <rect x="270" y="460" width="14" height="14" rx="2" fill="#b45309"/> <text x="290" y="472" fill="#94a3b8">Protected router</text> <rect x="420" y="460" width="14" height="14" rx="2" fill="#334155"/> <text x="440" y="472" fill="#94a3b8">Sub-router / file</text> </svg>

---

### Scaling Checklist

|Concern|Strategy|
|---|---|
|Root router bloat|Assembly only — no direct procedures|
|Feature boundary clarity|One directory per feature with `index.ts`|
|Shared schemas|Dedicated `*.schema.ts` per feature|
|Business logic in resolvers|Extract to `*.service.ts` files|
|Middleware consistency|Centralized `procedures.ts` with named base procedures|
|Cross-feature shared logic|Shared service layer, never cross-router imports|
|Monorepo boundary|Type-only export from server package|
|Circular imports|Strict DAG — feature routers never import each other|

---

### When to Restructure

**Key Points**

- When a single router file exceeds a manageable size and reviewing it requires excessive scrolling, splitting into sub-files is warranted.
- When a feature's procedures share schemas or service calls that are duplicated elsewhere, extracting a shared service layer is warranted.
- When middleware is applied inconsistently across procedures in an ad-hoc manner, introducing a named base procedure hierarchy is warranted.
- [Inference] Restructuring router files does not affect the client API as long as the namespace keys in the root router remain unchanged. _Renaming a namespace key is a breaking change for all callers of that namespace._

---

**Conclusion**

Organizing tRPC routers at scale is fundamentally an exercise in establishing and maintaining clear boundaries: between features, between access tiers, between the server's type surface and its runtime implementation, and between the root assembly point and the feature-level detail. The patterns described here — feature decomposition, co-located concerns, a centralized procedure base, and a strict import DAG — are not tRPC-specific conventions. They apply the same modular design principles that keep any large codebase navigable. tRPC's composition model, being plain TypeScript, imposes no structure of its own, which means the structure must come from deliberate convention.