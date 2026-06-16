## Creating a Root Router

The root router is the top-level object that aggregates all procedures and sub-routers in a tRPC application. It serves as the single entry point through which the server exposes its API and through which the client derives its types.

---

### What the Root Router Is

In tRPC, a router is created using the `router()` function exposed by your tRPC instance. The root router is simply the router at the top of the composition hierarchy — the one that is ultimately passed to the server adapter and exported for client-side type inference.

**Key Points**

- There is nothing structurally special about the root router relative to any other router — it is distinguished by its position in the composition, not by a different API.
- All type inference on the client flows from the exported type of the root router.
- A tRPC application has exactly one root router.

---

### Setting Up the tRPC Instance First

Before creating a router, you need an initialized tRPC instance. The `router()` and `publicProcedure` (or any base procedure) are derived from that instance.

```ts
// src/trpc.ts
import { initTRPC } from '@trpc/server';

const t = initTRPC.create();

export const router = t.router;
export const publicProcedure = t.procedure;
```

This file is typically created once and its exports are reused throughout the codebase.

---

### Defining the Root Router

The root router is defined by calling `router()` with an object whose keys are procedure names or nested routers.

```ts
// src/server/routers/_app.ts
import { router, publicProcedure } from '../trpc';

export const appRouter = router({
  hello: publicProcedure.query(() => {
    return { message: 'Hello, world!' };
  }),
});

// Export the type — used by the client
export type AppRouter = typeof appRouter;
```

**Key Points**

- The `appRouter` variable holds the runtime router object.
- `AppRouter` is the TypeScript type exported for use in the client. It carries no runtime weight — it is erased at compile time.
- These two exports serve different purposes and both are typically needed.

---

### The Role of `AppRouter` in Type Inference

The exported `AppRouter` type is the bridge between server and client. On the client side, it is passed as a type parameter to `createTRPCClient` or `createTRPCReact`, enabling full end-to-end type inference without any code generation step.

```ts
// src/client.ts
import { createTRPCClient, httpBatchLink } from '@trpc/client';
import type { AppRouter } from './server/routers/_app';

const trpc = createTRPCClient<AppRouter>({
  links: [
    httpBatchLink({ url: 'http://localhost:3000/trpc' }),
  ],
});
```

**Key Points**

- Only the `type` import is used — no server code reaches the client bundle.
- Removing `type` from the import (i.e., importing the value) would pull server-side code into the client, which is incorrect and potentially unsafe.

---

### File Naming and Location Conventions

tRPC does not enforce a specific file structure. The following is a common convention observed in the ecosystem:

| File | Purpose |
|---|---|
| `src/trpc.ts` | Initializes tRPC, exports `router` and base procedures |
| `src/server/routers/_app.ts` | Defines and exports the root router and `AppRouter` type |
| `src/server/routers/*.ts` | Individual feature routers merged into the root |

**[Inference]** This convention reflects patterns commonly seen in official tRPC examples and community projects, but it is not mandated by the library. *Your structure may differ without affecting behavior.*

---

### Composing Sub-Routers into the Root

As an application grows, procedures are typically organized into feature-specific sub-routers and merged at the root level.

```ts
// src/server/routers/user.ts
import { router, publicProcedure } from '../../trpc';

export const userRouter = router({
  getById: publicProcedure
    .input(z.object({ id: z.string() }))
    .query(({ input }) => {
      return { id: input.id, name: 'Alice' };
    }),
});
```

```ts
// src/server/routers/_app.ts
import { router } from '../../trpc';
import { userRouter } from './user';

export const appRouter = router({
  user: userRouter,
});

export type AppRouter = typeof appRouter;
```

On the client, procedures are accessed via the nested namespace:

```ts
const user = await trpc.user.getById.query({ id: '1' });
```

---

### What the Root Router Cannot Do

**Key Points**

- The root router cannot be modified after creation — routers in tRPC are immutable once defined.
- Procedures cannot be added to a router dynamically at runtime. All composition happens at definition time.
- Two separate root routers cannot be merged at runtime. Merging must happen at the point of definition by composing sub-routers.

---

### Passing the Root Router to a Server Adapter

The runtime `appRouter` value — not the type — is what gets handed to a server adapter.

```ts
// Example with Express adapter
import { createExpressMiddleware } from '@trpc/server/adapters/express';
import { appRouter } from './routers/_app';
import express from 'express';

const app = express();

app.use(
  '/trpc',
  createExpressMiddleware({ router: appRouter }),
);

app.listen(3000);
```

The adapter uses the router to route incoming requests to the correct procedure handler.

---

**Conclusion**

The root router is the structural backbone of a tRPC API. It is created with the `router()` function from your tRPC instance, composed of procedures and sub-routers, and exported both as a value (for the server adapter) and as a type (for client-side inference). All type safety in a tRPC application ultimately traces back to this single exported type.