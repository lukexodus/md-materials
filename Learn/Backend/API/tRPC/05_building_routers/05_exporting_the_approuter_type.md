## Exporting the AppRouter Type

The `AppRouter` type is the single artifact that connects a tRPC server to its clients at the type level. Exporting it correctly — and importing it correctly on the client — is what enables end-to-end type safety without code generation or a shared runtime dependency on server code.

---

### What `AppRouter` Is

`AppRouter` is a TypeScript type derived from the root router value using `typeof`. It encodes the complete shape of the API: every procedure name, its input type, its output type, and whether it is a query, mutation, or subscription.

```ts
export const appRouter = router({
  user: userRouter,
  post: postRouter,
});

export type AppRouter = typeof appRouter;
```

**Key Points**

- `AppRouter` is a pure TypeScript type. It has no runtime representation and contributes zero bytes to any compiled output.
- The `typeof` operator applied to `appRouter` captures the full inferred type of the router, including all nested procedure signatures.
- The type and the value are separate exports and serve different consumers: the value is consumed by the server adapter, the type is consumed by the client.

---

### Why a Separate Type Export Is Needed

tRPC's client packages accept a type parameter that describes the server's API shape. Without exporting `AppRouter`, the client has no way to know what procedures exist or what their signatures are.

```ts
// Without AppRouter export, this is impossible to type correctly
const trpc = createTRPCClient<???>();
```

The type export is the mechanism that replaces what would otherwise require a code generation step (as in GraphQL or OpenAPI toolchains).

---

### The Canonical Export Pattern

```ts
// src/server/routers/_app.ts
import { router } from '../../trpc';
import { userRouter } from './user';
import { postRouter } from './post';

export const appRouter = router({
  user: userRouter,
  post: postRouter,
});

// Value export — used by the server adapter
// Type export — used by the client
export type AppRouter = typeof appRouter;
```

Both exports live in the same file. This is the pattern used in official tRPC documentation and examples.

---

### Importing on the Client

On the client, `AppRouter` must be imported as a type — never as a value. Using a type-only import enforces this at the TypeScript level and prevents any server-side code from being bundled into the client.

```ts
// src/client.ts
import type { AppRouter } from './server/routers/_app';
import { createTRPCClient, httpBatchLink } from '@trpc/client';

const trpc = createTRPCClient<AppRouter>({
  links: [
    httpBatchLink({ url: '/trpc' }),
  ],
});
```

**Key Points**

- `import type` is a TypeScript 3.8+ feature. It guarantees the import is erased at compile time and never appears in the emitted JavaScript.
- Using `import { AppRouter }` without `type` would still work in many setups if tree-shaking removes the unused value, but it is not reliable and creates a potential for accidental server code leakage. `import type` is the correct form.
- In a monorepo where server and client are in separate packages, the import path changes but the pattern is identical.

---

### In a Monorepo Setup

When server and client are separate packages, `AppRouter` is typically exported from the server package's public API surface.

```ts
// packages/api/src/index.ts  ← server package public entry
export type { AppRouter } from './routers/_app';

// The value appRouter is NOT exported here — it is internal to the server package
```

```ts
// apps/web/src/trpc.ts  ← client in a separate package
import type { AppRouter } from '@myorg/api';
import { createTRPCClient, httpBatchLink } from '@trpc/client';

const trpc = createTRPCClient<AppRouter>({
  links: [httpBatchLink({ url: '/api/trpc' })],
});
```

**Key Points**

- Only the type is part of the server package's public API. The router value, database clients, and server-side utilities remain private to the server package.
- `export type { AppRouter }` (re-exporting as a type) at the package boundary reinforces that only type information crosses the boundary.
- [Inference] In bundlers that do not perform tree-shaking or that process packages as CommonJS, accidentally importing the value rather than the type could pull server-side modules into the client bundle. *Behavior depends on your bundler and module format configuration.*

---

### What the Type Contains

The `AppRouter` type encodes the full recursive structure of the router. For a router defined as:

```ts
export const appRouter = router({
  user: router({
    getById: publicProcedure
      .input(z.object({ id: z.string() }))
      .query(({ input }) => ({ id: input.id, name: 'Alice' })),
  }),
});
```

The inferred type carries:

- The namespace `user`
- The procedure `getById` under `user`
- The input type `{ id: string }`
- The output type `{ id: string; name: string }`
- The procedure type: query

All of this is available to the client purely through the type import, with no runtime communication required to discover the API shape.

---

### What the Type Does Not Contain

**Key Points**

- Middleware logic is not encoded in `AppRouter`. The type reflects input and output shapes, not what runs before the resolver.
- Context type is not directly surfaced in `AppRouter` in a way that is useful to clients. Context is a server-side concern.
- Resolver implementation details are not present. The type captures what a procedure accepts and returns, not how it computes the result.

---

### Common Mistakes

**Importing the value instead of the type**

```ts
// Incorrect — imports the runtime value
import { AppRouter } from './server/routers/_app';

// Correct — imports only the type
import type { AppRouter } from './server/routers/_app';
```

**Exporting `AppRouter` from a file that also exports server-side singletons**

If the file exporting `AppRouter` also exports database clients, environment variables, or other server-only values, a careless import on the client could pull those in. Keep the router file lean or use a dedicated re-export file at the package boundary.

**Forgetting to update `AppRouter` after adding procedures**

Because `AppRouter` is derived with `typeof appRouter`, it automatically reflects any changes to `appRouter`. There is no manual update step. [Inference] If the client type appears stale, the most likely cause is a TypeScript server cache issue or a build step that has not re-run, not a problem with the export itself. *Restart your TypeScript language server if type updates are not reflected.*

---

### Type-Only Export at a Glance

```ts
// Server — _app.ts
export const appRouter = router({ ... });   // runtime value → server adapter
export type AppRouter = typeof appRouter;   // type only → client

// Client
import type { AppRouter } from '...';       // zero runtime cost
const trpc = createTRPCClient<AppRouter>(); // full type inference
```

---

**Conclusion**

Exporting `AppRouter` is a small but load-bearing step in a tRPC setup. It is the mechanism by which the server's complete API shape is made available to clients without runtime coupling, code generation, or schema files. The pattern is consistent regardless of application size: derive the type with `typeof`, export it alongside the router value, and import it on the client with `import type`. Getting this boundary right is what makes tRPC's end-to-end type safety possible.