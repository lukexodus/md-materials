## Merging Routers

As tRPC applications scale, there is sometimes a need to combine routers in ways beyond simple nesting under a named key. tRPC provides a `mergeRouters` utility for this purpose — it produces a flat, combined router from two or more source routers without introducing an additional namespace level.

---

### Nesting vs. Merging

These are two distinct composition strategies:

| Strategy | API | Result |
|---|---|---|
| Nesting | Plain object key in `router({})` | Adds a namespace level |
| Merging | `mergeRouters(a, b)` | Flattens procedures into one router |

**Example — Nesting (adds namespace)**

```ts
export const appRouter = router({
  user: userRouter, // accessed as trpc.user.getById
});
```

**Example — Merging (no new namespace)**

```ts
import { mergeRouters } from '@trpc/server';

export const appRouter = mergeRouters(baseRouter, userRouter);
// procedures from both are accessed at the top level
// trpc.getById, trpc.ping, etc.
```

---

### `mergeRouters` API

`mergeRouters` is exported directly from `@trpc/server`. It accepts two or more routers and returns a new router whose procedure set is the union of all input routers.

```ts
import { mergeRouters } from '@trpc/server';
import { t } from '../trpc';

const routerA = t.router({
  hello: t.procedure.query(() => 'hello'),
});

const routerB = t.router({
  world: t.procedure.query(() => 'world'),
});

export const appRouter = mergeRouters(routerA, routerB);

export type AppRouter = typeof appRouter;
```

The resulting `appRouter` exposes both `hello` and `world` at the same level:

```ts
await trpc.hello.query();
await trpc.world.query();
```

---

### Key Behavioral Properties

**Key Points**

- Procedures from all merged routers are flattened into a single namespace.
- If two routers define a procedure with the same key, the later router's procedure overwrites the earlier one. [Inference] TypeScript may not always surface this as a type error depending on how the conflict manifests. *Behavior may vary — avoid key collisions deliberately.*
- `mergeRouters` does not require all input routers to share the same context type, but [Inference] mismatched context types may produce TypeScript errors at the merge site. *Verify against your specific setup.*
- The returned router is a standard tRPC router and can itself be nested, merged further, or passed to a server adapter.

---

### When to Use `mergeRouters`

`mergeRouters` is suited to specific scenarios:

**Splitting a large flat router for organization without adding namespaces**

If you want to break a large root-level router into multiple files but keep all procedures at the top level of the API, `mergeRouters` achieves this without nesting.

```ts
// src/server/routers/health.ts
export const healthRouter = t.router({
  ping: t.procedure.query(() => ({ status: 'ok' })),
});

// src/server/routers/version.ts
export const versionRouter = t.router({
  getVersion: t.procedure.query(() => ({ version: '1.0.0' })),
});

// src/server/routers/_app.ts
export const appRouter = mergeRouters(healthRouter, versionRouter);
// trpc.ping, trpc.getVersion — no namespace
```

**Composing a base router with feature routers**

A shared base router containing cross-cutting procedures (health checks, metadata endpoints) can be merged with feature routers.

```ts
export const appRouter = mergeRouters(baseRouter, featureRouter);
```

---

### Combining `mergeRouters` with Nesting

`mergeRouters` and nesting are not mutually exclusive. A merged router can be nested under a key, and a nested router can be built from merged components.

```ts
const userRouter = mergeRouters(userCoreRouter, userPreferencesRouter);

export const appRouter = router({
  user: userRouter,   // merged router, nested under "user"
  post: postRouter,
});
```

Client access:

```ts
// procedures from both userCoreRouter and userPreferencesRouter
// are accessible under the "user" namespace
await trpc.user.getById.query({ id: '1' });
await trpc.user.updatePreferences.mutate({ theme: 'dark' });
```

---

### Version Availability

`mergeRouters` was introduced in tRPC v10. It is not available in v9, which used a different (now removed) `mergeRouters` pattern.

**[Inference]** The v9 `mergeRouters` and the v10 `mergeRouters` share a name but differ in API and behavior. If you encounter references to either, verify which version is being targeted before applying the pattern. *Do not assume compatibility across versions.*

---

### Structural Comparison

Given two routers merged vs. nested:

```ts
// Merged
export const appRouter = mergeRouters(
  router({ ping: ..., status: ... }),
  router({ getUser: ..., createUser: ... }),
);
// Result: trpc.ping, trpc.status, trpc.getUser, trpc.createUser
```

```ts
// Nested
export const appRouter = router({
  system: router({ ping: ..., status: ... }),
  user: router({ getUser: ..., createUser: ... }),
});
// Result: trpc.system.ping, trpc.system.status, trpc.user.getUser, trpc.user.createUser
```

**Key Points**

- Merging is appropriate when a flat API surface is intentional.
- Nesting is appropriate when namespace separation is desirable for clarity or API organization.
- Most applications use nesting as the primary strategy and reserve merging for specific structural needs.

---

**Conclusion**

`mergeRouters` provides a mechanism to combine multiple routers into a single flat router without introducing additional namespace levels. It complements — rather than replaces — nesting, and is most useful when a flat API surface is desired or when a large router needs to be split across files without changing its public shape. Key collision behavior is a practical concern when merging, and deliberate naming discipline across merged routers helps avoid it.