## Nested Routers and Namespacing

As a tRPC application grows, placing all procedures in a single flat router becomes difficult to maintain. tRPC supports composing routers hierarchically — sub-routers are nested under keys in a parent router, and those keys become namespaces on both the server and the client.

---

### What Nesting Means in tRPC

Nesting a router means assigning it as a value under a key in another router's definition object. The key becomes the namespace through which all of that sub-router's procedures are accessed.

```ts
export const appRouter = router({
  user: userRouter,   // namespace: "user"
  post: postRouter,   // namespace: "post"
});
```

There is no special API for nesting — it is plain object composition. The `router()` function accepts both procedures and other routers as values in the same definition object.

---

### Creating and Nesting a Sub-Router

**Example**

```ts
// src/server/routers/post.ts
import { router, publicProcedure } from '../../trpc';
import { z } from 'zod';

export const postRouter = router({
  getById: publicProcedure
    .input(z.object({ id: z.string() }))
    .query(({ input }) => {
      return { id: input.id, title: 'Hello tRPC' };
    }),

  create: publicProcedure
    .input(z.object({ title: z.string() }))
    .mutation(({ input }) => {
      return { id: 'new-id', title: input.title };
    }),
});
```

```ts
// src/server/routers/_app.ts
import { router } from '../../trpc';
import { postRouter } from './post';

export const appRouter = router({
  post: postRouter,
});

export type AppRouter = typeof appRouter;
```

On the client, procedures are accessed through the namespace:

```ts
const post = await trpc.post.getById.query({ id: '1' });
await trpc.post.create.mutate({ title: 'New Post' });
```

---

### How Namespacing Affects the Client

The client type is derived entirely from `AppRouter`. Nesting routers produces a nested type structure that mirrors the server's composition exactly.

Given:

```ts
export const appRouter = router({
  user: userRouter,
  post: postRouter,
});
```

The inferred client type reflects:

```
trpc.user.getById.query(...)
trpc.user.create.mutate(...)
trpc.post.getById.query(...)
trpc.post.create.mutate(...)
```

**Key Points**

- Namespace keys on the client are the exact strings used as keys in the router definition.
- Renaming a key in the router definition renames the namespace on the client — this is a breaking change for any existing callers.
- There is no aliasing mechanism — a sub-router can only be mounted under one key per parent router.

---

### Arbitrary Nesting Depth

Sub-routers can themselves contain sub-routers, enabling multi-level namespacing.

```ts
// src/server/routers/admin/user.ts
export const adminUserRouter = router({
  ban: adminProcedure
    .input(z.object({ userId: z.string() }))
    .mutation(({ input }) => {
      return { banned: true, userId: input.userId };
    }),
});
```

```ts
// src/server/routers/admin/_admin.ts
import { adminUserRouter } from './user';

export const adminRouter = router({
  user: adminUserRouter,
});
```

```ts
// src/server/routers/_app.ts
export const appRouter = router({
  admin: adminRouter,
});
```

Client access becomes:

```ts
await trpc.admin.user.ban.mutate({ userId: '42' });
```

**Key Points**

- Each level of nesting adds one segment to the access path.
- There is no documented hard limit on nesting depth, though deeply nested structures may become difficult to navigate. [Inference] Extremely deep nesting could affect TypeScript's type inference performance in large codebases, though this is not confirmed behavior. *Results may vary.*

---

### Visualizing the Namespace Tree

Given the following composition:

```ts
export const appRouter = router({
  user: router({
    getById: ...,
    create: ...,
  }),
  admin: router({
    user: router({
      ban: ...,
    }),
  }),
  post: router({
    getById: ...,
  }),
});
```

The namespace tree looks like this:

<svg viewBox="0 0 640 380" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="13">
  <!-- Root -->
  <rect x="260" y="20" width="120" height="36" rx="6" fill="#4f46e5" />
  <text x="320" y="43" text-anchor="middle" fill="white" font-weight="bold">appRouter</text>

  <!-- Level 1 connectors -->
  <line x1="320" y1="56" x2="100" y2="110" stroke="#94a3b8" stroke-width="1.5"/>
  <line x1="320" y1="56" x2="320" y2="110" stroke="#94a3b8" stroke-width="1.5"/>
  <line x1="320" y1="56" x2="540" y2="110" stroke="#94a3b8" stroke-width="1.5"/>

  <!-- Level 1 nodes -->
  <rect x="40" y="110" width="120" height="36" rx="6" fill="#0f766e" />
  <text x="100" y="133" text-anchor="middle" fill="white">user</text>

  <rect x="260" y="110" width="120" height="36" rx="6" fill="#b45309" />
  <text x="320" y="133" text-anchor="middle" fill="white">admin</text>

  <rect x="480" y="110" width="120" height="36" rx="6" fill="#0f766e" />
  <text x="540" y="133" text-anchor="middle" fill="white">post</text>

  <!-- user children connectors -->
  <line x1="100" y1="146" x2="60" y2="200" stroke="#94a3b8" stroke-width="1.5"/>
  <line x1="100" y1="146" x2="140" y2="200" stroke="#94a3b8" stroke-width="1.5"/>

  <!-- user children -->
  <rect x="20" y="200" width="80" height="32" rx="5" fill="#334155" />
  <text x="60" y="221" text-anchor="middle" fill="#cbd5e1" font-size="12">getById</text>

  <rect x="110" y="200" width="60" height="32" rx="5" fill="#334155" />
  <text x="140" y="221" text-anchor="middle" fill="#cbd5e1" font-size="12">create</text>

  <!-- admin children connectors -->
  <line x1="320" y1="146" x2="320" y2="200" stroke="#94a3b8" stroke-width="1.5"/>

  <!-- admin > user -->
  <rect x="260" y="200" width="120" height="36" rx="6" fill="#0f766e" />
  <text x="320" y="223" text-anchor="middle" fill="white">user</text>

  <!-- admin > user > ban connector -->
  <line x1="320" y1="236" x2="320" y2="286" stroke="#94a3b8" stroke-width="1.5"/>

  <!-- admin > user > ban -->
  <rect x="280" y="286" width="80" height="32" rx="5" fill="#334155" />
  <text x="320" y="307" text-anchor="middle" fill="#cbd5e1" font-size="12">ban</text>

  <!-- post children connectors -->
  <line x1="540" y1="146" x2="540" y2="200" stroke="#94a3b8" stroke-width="1.5"/>

  <!-- post children -->
  <rect x="500" y="200" width="80" height="32" rx="5" fill="#334155" />
  <text x="540" y="221" text-anchor="middle" fill="#cbd5e1" font-size="12">getById</text>
</svg>

---

### Sharing Context and Middleware Across Nested Routers

Context is defined once at the tRPC instance level and is available to all procedures regardless of which router they belong to or how deeply nested they are. Middleware attached to a base procedure is also inherited by any procedure built from it, across all routers.

**Key Points**

- Nesting does not affect context availability — all procedures share the same context shape.
- Middleware is attached at the procedure level, not the router level. A sub-router does not automatically inherit middleware from its parent router. [Inference] To apply middleware consistently across a sub-router's procedures, a shared base procedure with that middleware applied is the typical pattern. *Behavior is subject to how your procedures are defined.*

---

### Merging vs. Nesting

tRPC v10 and later removed the `mergeRouters` approach used in earlier versions in favor of plain object composition. Nesting is the current idiomatic pattern.

| Approach | Version | Status |
|---|---|---|
| `mergeRouters()` utility | v9 and earlier | Removed / deprecated |
| Plain object composition | v10+ | Current idiomatic approach |

**[Inference]** If you encounter documentation or examples referencing `mergeRouters`, they likely target the v9 API. *Verify against the version you are using.*

---

### Common Structural Pattern

A typical file structure that mirrors the namespace hierarchy:

```
src/
  trpc.ts                     ← tRPC instance
  server/
    routers/
      _app.ts                 ← root router + AppRouter type
      user.ts                 ← userRouter
      post.ts                 ← postRouter
      admin/
        _admin.ts             ← adminRouter
        user.ts               ← adminUserRouter
```

Each file exports one router. The root router imports and composes them. The directory structure mirrors the namespace tree, making it straightforward to locate the source of any procedure by its client-side access path.

---

**Conclusion**

Nested routers in tRPC are created through plain object composition — sub-routers are assigned to keys in a parent router, and those keys become namespaces. The client type mirrors this hierarchy exactly, providing fully typed access at every level. Nesting is the idiomatic way to organize procedures in any tRPC application beyond trivial size, and the resulting namespace structure is a direct reflection of how routers are composed at definition time.