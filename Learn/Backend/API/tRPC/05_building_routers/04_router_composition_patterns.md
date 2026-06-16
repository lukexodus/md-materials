## Router Composition Patterns

Router composition is the practice of structuring and combining tRPC routers deliberately to meet organizational, architectural, and maintainability goals. Beyond the mechanics of nesting and merging, there are established patterns that address real-world concerns: feature boundaries, shared behavior, access control, and scalability.

---

### Pattern 1 — Feature-Based Decomposition

The most common pattern. Each feature domain owns a dedicated router file. The root router assembles them.

```
src/server/routers/
  _app.ts        ← root router
  user.ts
  post.ts
  comment.ts
  notification.ts
```

```ts
// src/server/routers/_app.ts
import { router } from '../../trpc';
import { userRouter } from './user';
import { postRouter } from './post';
import { commentRouter } from './comment';
import { notificationRouter } from './notification';

export const appRouter = router({
  user: userRouter,
  post: postRouter,
  comment: commentRouter,
  notification: notificationRouter,
});

export type AppRouter = typeof appRouter;
```

**Key Points**

- Each feature router is independently maintainable and testable in isolation.
- Adding a new feature requires creating one file and one import at the root — no existing routers are modified.
- The namespace on the client directly communicates the feature domain.

---

### Pattern 2 — Access-Tier Separation

Procedures are grouped by who is permitted to call them. Each tier uses a different base procedure that enforces the appropriate middleware.

```ts
// src/trpc.ts
const t = initTRPC.context<Context>().create();

export const publicProcedure = t.procedure;
export const protectedProcedure = t.procedure.use(requireAuth);
export const adminProcedure = t.procedure.use(requireAuth).use(requireAdmin);
```

```ts
// src/server/routers/user.ts
export const userRouter = router({
  getPublicProfile: publicProcedure
    .input(z.object({ id: z.string() }))
    .query(({ input }) => { /* ... */ }),

  updateProfile: protectedProcedure
    .input(z.object({ bio: z.string() }))
    .mutation(({ input, ctx }) => { /* ... */ }),
});
```

```ts
// src/server/routers/admin.ts
export const adminRouter = router({
  banUser: adminProcedure
    .input(z.object({ userId: z.string() }))
    .mutation(({ input }) => { /* ... */ }),
});
```

```ts
// _app.ts
export const appRouter = router({
  user: userRouter,
  admin: adminRouter,
});
```

**Key Points**

- Access control lives in the procedure definition, not in the router structure.
- A single router can contain procedures of mixed access tiers.
- The `admin` namespace communicates intent, but the actual enforcement is the middleware on `adminProcedure`. Namespace alone does not enforce access. [Inference] Relying solely on namespace naming for access control without middleware enforcement would not produce actual security guarantees. *Always attach enforcement middleware to the procedure itself.*

---

### Pattern 3 — Domain Router with Internal Sub-Routers

A domain router is itself composed of sub-routers that represent logical sub-divisions of that domain.

```ts
// src/server/routers/post/index.ts
import { postCrudRouter } from './crud';
import { postSearchRouter } from './search';
import { postModerationRouter } from './moderation';

export const postRouter = router({
  crud: postCrudRouter,
  search: postSearchRouter,
  moderation: postModerationRouter,
});
```

Client access:

```ts
await trpc.post.crud.create.mutate({ title: 'Hello' });
await trpc.post.search.byTag.query({ tag: 'tRPC' });
await trpc.post.moderation.flag.mutate({ postId: '1' });
```

**Key Points**

- Useful when a single domain grows large enough to warrant internal organization.
- Each sub-router can be maintained by a different team member or module.
- The access path becomes longer — weigh clarity against verbosity.

---

### Pattern 4 — Shared Base Router via `mergeRouters`

Cross-cutting procedures that belong at the top level (health checks, version info, session utilities) are extracted into a base router and merged into the root.

```ts
// src/server/routers/base.ts
export const baseRouter = router({
  healthCheck: publicProcedure.query(() => ({ status: 'ok' })),
  version: publicProcedure.query(() => ({ version: '2.1.0' })),
});
```

```ts
// _app.ts
import { mergeRouters } from '@trpc/server';

export const appRouter = mergeRouters(
  baseRouter,
  router({
    user: userRouter,
    post: postRouter,
  }),
);
```

Client access:

```ts
await trpc.healthCheck.query();   // from baseRouter, no namespace
await trpc.user.getById.query({ id: '1' });
```

**Key Points**

- Keeps infrastructure-level procedures at the root without cluttering the root router definition.
- The merged base router remains independently testable and reusable across projects or services.

---

### Pattern 5 — Lazy / Modular Registration

In larger monorepos or modular architectures, routers from different packages or modules are assembled at the application entry point rather than being hardcoded in a central `_app.ts`.

```ts
// packages/user-module/src/router.ts
export const userRouter = router({ /* ... */ });

// packages/post-module/src/router.ts
export const postRouter = router({ /* ... */ });
```

```ts
// apps/api/src/routers/_app.ts
import { userRouter } from '@myorg/user-module';
import { postRouter } from '@myorg/post-module';

export const appRouter = router({
  user: userRouter,
  post: postRouter,
});
```

**Key Points**

- The application-level `_app.ts` acts purely as an assembly point — it contains no business logic.
- Each module is independently versioned, tested, and deployable (within monorepo tooling constraints).
- [Inference] All module routers must be built against the same tRPC instance or at minimum a compatible context type for composition to work without type errors. *Behavior may vary depending on how context types are shared across packages.*

---

### Pattern 6 — Router Factory for Reusable Procedure Sets

When the same set of procedures needs to be instantiated multiple times with different configurations (e.g., a generic CRUD router parameterized by a resource type), a factory function produces the router.

```ts
// src/server/routers/factories/crudFactory.ts
import { z } from 'zod';
import { router, publicProcedure } from '../../trpc';

export function createCrudRouter<T>(
  resourceName: string,
  getAll: () => T[],
  getById: (id: string) => T | undefined,
) {
  return router({
    getAll: publicProcedure.query(() => getAll()),
    getById: publicProcedure
      .input(z.object({ id: z.string() }))
      .query(({ input }) => getById(input.id)),
  });
}
```

```ts
// Usage
export const categoryRouter = createCrudRouter(
  'category',
  () => db.categories.findAll(),
  (id) => db.categories.findById(id),
);
```

**Key Points**

- Useful for resource-oriented APIs where multiple entities share the same procedure shape.
- The factory is a plain function — no special tRPC API is involved.
- [Inference] Complex generic typing in factory functions can increase TypeScript compilation complexity. *Monitor type inference performance in large codebases.*

---

### Composition Pattern Comparison

| Pattern | Namespace Impact | Best Suited For |
|---|---|---|
| Feature decomposition | One namespace per feature | Most applications |
| Access-tier separation | Mixed within namespaces | Auth-sensitive APIs |
| Domain sub-routers | Deeper namespace hierarchy | Large domains |
| Shared base via merge | Flat root-level procedures | Cross-cutting utilities |
| Modular / monorepo | Assembly at app boundary | Monorepos, modular teams |
| Router factory | Varies by usage | Repetitive resource patterns |

---

### Visualizing a Composed Root Router

<svg viewBox="0 0 720 460" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="12">

  <!-- Root -->
  <rect x="280" y="20" width="160" height="38" rx="6" fill="#4f46e5"/>
  <text x="360" y="44" text-anchor="middle" fill="white" font-weight="bold" font-size="13">appRouter</text>

  <!-- Root connectors -->
  <line x1="360" y1="58" x2="100" y2="120" stroke="#94a3b8" stroke-width="1.5"/>
  <line x1="360" y1="58" x2="260" y2="120" stroke="#94a3b8" stroke-width="1.5"/>
  <line x1="360" y1="58" x2="460" y2="120" stroke="#94a3b8" stroke-width="1.5"/>
  <line x1="360" y1="58" x2="620" y2="120" stroke="#94a3b8" stroke-width="1.5"/>

  <!-- Level 1 nodes -->
  <rect x="30" y="120" width="140" height="34" rx="6" fill="#0f766e"/>
  <text x="100" y="142" text-anchor="middle" fill="white">base (merged)</text>

  <rect x="195" y="120" width="130" height="34" rx="6" fill="#0f766e"/>
  <text x="260" y="142" text-anchor="middle" fill="white">user</text>

  <rect x="395" y="120" width="130" height="34" rx="6" fill="#0f766e"/>
  <text x="460" y="142" text-anchor="middle" fill="white">post</text>

  <rect x="555" y="120" width="130" height="34" rx="6" fill="#b45309"/>
  <text x="620" y="142" text-anchor="middle" fill="white">admin</text>

  <!-- base children -->
  <line x1="100" y1="154" x2="60" y2="210" stroke="#94a3b8" stroke-width="1.5"/>
  <line x1="100" y1="154" x2="140" y2="210" stroke="#94a3b8" stroke-width="1.5"/>
  <rect x="20" y="210" width="80" height="28" rx="4" fill="#334155"/>
  <text x="60" y="229" text-anchor="middle" fill="#cbd5e1">healthCheck</text>
  <rect x="108" y="210" width="64" height="28" rx="4" fill="#334155"/>
  <text x="140" y="229" text-anchor="middle" fill="#cbd5e1">version</text>

  <!-- user children -->
  <line x1="260" y1="154" x2="220" y2="210" stroke="#94a3b8" stroke-width="1.5"/>
  <line x1="260" y1="154" x2="300" y2="210" stroke="#94a3b8" stroke-width="1.5"/>
  <rect x="180" y="210" width="76" height="28" rx="4" fill="#334155"/>
  <text x="218" y="229" text-anchor="middle" fill="#cbd5e1">getById</text>
  <rect x="264" y="210" width="72" height="28" rx="4" fill="#334155"/>
  <text x="300" y="229" text-anchor="middle" fill="#cbd5e1">update</text>

  <!-- post children -->
  <line x1="460" y1="154" x2="420" y2="210" stroke="#94a3b8" stroke-width="1.5"/>
  <line x1="460" y1="154" x2="500" y2="210" stroke="#94a3b8" stroke-width="1.5"/>

  <!-- post sub-routers -->
  <rect x="378" y="210" width="76" height="28" rx="4" fill="#0f766e"/>
  <text x="416" y="229" text-anchor="middle" fill="white">crud</text>
  <rect x="462" y="210" width="76" height="28" rx="4" fill="#0f766e"/>
  <text x="500" y="229" text-anchor="middle" fill="white">search</text>

  <!-- post.crud children -->
  <line x1="416" y1="238" x2="400" y2="286" stroke="#94a3b8" stroke-width="1.5"/>
  <line x1="416" y1="238" x2="435" y2="286" stroke="#94a3b8" stroke-width="1.5"/>
  <rect x="368" y="286" width="52" height="26" rx="4" fill="#334155"/>
  <text x="394" y="303" text-anchor="middle" fill="#cbd5e1">create</text>
  <rect x="424" y="286" width="52" height="26" rx="4" fill="#334155"/>
  <text x="450" y="303" text-anchor="middle" fill="#cbd5e1">delete</text>

  <!-- post.search children -->
  <line x1="500" y1="238" x2="500" y2="286" stroke="#94a3b8" stroke-width="1.5"/>
  <rect x="468" y="286" width="64" height="26" rx="4" fill="#334155"/>
  <text x="500" y="303" text-anchor="middle" fill="#cbd5e1">byTag</text>

  <!-- admin children -->
  <line x1="620" y1="154" x2="580" y2="210" stroke="#94a3b8" stroke-width="1.5"/>
  <line x1="620" y1="154" x2="650" y2="210" stroke="#94a3b8" stroke-width="1.5"/>
  <rect x="544" y="210" width="68" height="28" rx="4" fill="#334155"/>
  <text x="578" y="229" text-anchor="middle" fill="#cbd5e1">banUser</text>
  <rect x="618" y="210" width="68" height="28" rx="4" fill="#334155"/>
  <text x="652" y="229" text-anchor="middle" fill="#cbd5e1">getStats</text>

</svg>

---

### What to Avoid

**Key Points**

- **Circular router imports** — Router A importing Router B which imports Router A will cause runtime errors and TypeScript failures. Keep the dependency graph strictly hierarchical: leaf routers have no dependencies on other routers; the root router depends on all others.
- **Logic in the root router** — The root router should be a pure assembly point. Business logic belongs in feature routers or service layers called by resolvers.
- **Overusing `mergeRouters` for organization** — Merging is appropriate for flattening; if you are merging just to avoid choosing a namespace, consider whether a namespace would actually improve clarity.
- **Deeply inconsistent naming** — If some namespaces use nouns (`user`), others use verbs (`fetchUser`), and others use adjectives (`userRelated`), the client API becomes unpredictable. [Inference] Consistent naming conventions across routers reduce onboarding friction and make the client type easier to navigate. *This is a convention recommendation, not a library constraint.*

---

**Conclusion**

Router composition patterns in tRPC are architectural decisions as much as technical ones. Feature decomposition is the baseline pattern for most applications. Access-tier separation, domain sub-routers, shared base merging, modular registration, and router factories each address specific needs that arise as applications grow. The common thread is that tRPC's composition model — plain object assignment and `mergeRouters` — is intentionally simple, placing the burden of structure entirely on the developer rather than enforcing any particular convention.