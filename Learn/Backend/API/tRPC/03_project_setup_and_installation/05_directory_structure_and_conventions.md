### Directory Structure and Conventions

#### Overview

tRPC does not enforce a specific directory structure, but conventions have emerged from community usage and official examples that promote maintainability and scalability. The structure you adopt affects how routers, procedures, and context are organized and imported across your codebase.

---

#### Minimal Project Layout

For small projects or prototypes, a flat structure is common:

```
my-app/
├── src/
│   ├── server/
│   │   ├── trpc.ts          # tRPC instance, context, middleware
│   │   └── router.ts        # Root router (all procedures here)
│   ├── client/
│   │   └── trpc.ts          # Client-side tRPC setup
│   └── pages/               # (if using Next.js)
│       └── api/
│           └── trpc/
│               └── [trpc].ts  # API handler
├── package.json
└── tsconfig.json
```

This layout is practical when the number of procedures is small and team size is limited.

---

#### Recommended Modular Layout

As applications grow, splitting routers by domain is the standard approach:

```
src/
├── server/
│   ├── trpc.ts                  # t object: initTRPC, context type, base procedures
│   ├── context.ts               # createContext function
│   ├── router/
│   │   ├── index.ts             # Root router: merges all sub-routers
│   │   ├── user.router.ts       # User-domain procedures
│   │   ├── post.router.ts       # Post-domain procedures
│   │   └── auth.router.ts       # Auth-domain procedures
│   └── middleware/
│       └── isAuthed.ts          # Reusable middleware definitions
├── client/
│   └── trpc.ts                  # createTRPCReact or vanilla client setup
├── types/
│   └── index.ts                 # Shared types (AppRouter export lives in server/router/index.ts)
└── pages/api/trpc/[trpc].ts     # Next.js: HTTP handler (or equivalent for other frameworks)
```

---

#### File-by-File Responsibilities

##### `server/trpc.ts` — The tRPC Instance

This file initializes tRPC and exports the building blocks used everywhere else. It should be the only place `initTRPC` is called.

```ts
// server/trpc.ts
import { initTRPC } from '@trpc/server';
import type { Context } from './context';

const t = initTRPC.context<Context>().create();

export const router = t.router;
export const publicProcedure = t.procedure;
export const middleware = t.middleware;
```

**Key Points**

- `initTRPC` must be called once per application.
- Exporting named aliases (`publicProcedure`, `router`) keeps consumer files readable and decoupled from the `t` object directly.
- Protected procedures (e.g., `authedProcedure`) are also defined and exported here after composing middleware.

---

##### `server/context.ts` — Context Factory

Defines the shape of the context object passed to every procedure.

```ts
// server/context.ts
import type { CreateNextContextOptions } from '@trpc/server/adapters/next';

export async function createContext({ req, res }: CreateNextContextOptions) {
  return {
    req,
    res,
    user: null, // populated after auth check
  };
}

export type Context = Awaited<ReturnType<typeof createContext>>;
```

**Key Points**

- The `Context` type is inferred from the return value of `createContext`, so the type stays in sync automatically.
- Do not import `Context` back into `trpc.ts` as a value — only as a type, to avoid circular dependencies.

---

##### `server/router/index.ts` — Root Router

Merges all domain routers into a single `appRouter`. This is the export consumed by both the HTTP handler and the client-side type import.

```ts
// server/router/index.ts
import { router } from '../trpc';
import { userRouter } from './user.router';
import { postRouter } from './post.router';
import { authRouter } from './auth.router';

export const appRouter = router({
  user: userRouter,
  post: postRouter,
  auth: authRouter,
});

export type AppRouter = typeof appRouter;
```

**Key Points**

- `AppRouter` is a type-only export. No runtime data crosses the client/server boundary through this export.
- The namespace key used here (e.g., `user`, `post`) becomes part of the procedure call path on the client: `trpc.user.getById.useQuery(...)`.

---

##### `server/router/user.router.ts` — Domain Router

Each domain router is a self-contained module.

```ts
// server/router/user.router.ts
import { z } from 'zod';
import { router, publicProcedure } from '../trpc';

export const userRouter = router({
  getById: publicProcedure
    .input(z.object({ id: z.string() }))
    .query(async ({ input }) => {
      // fetch user by input.id
      return { id: input.id, name: 'Alice' };
    }),
});
```

---

##### `client/trpc.ts` — Client Setup

```ts
// client/trpc.ts
import { createTRPCReact } from '@trpc/react-query';
import type { AppRouter } from '../server/router/index';

export const trpc = createTRPCReact<AppRouter>();
```

**Key Points**

- Only the `AppRouter` *type* is imported. No server code is bundled into the client.
- This file is the single source of the typed client hook object used throughout UI components.

---

#### Naming Conventions

| Artifact | Convention | Example |
| --- | --- | --- |
| Router files | `<domain>.router.ts` | `post.router.ts` |
| tRPC instance file | `trpc.ts` | `server/trpc.ts` |
| Context file | `context.ts` | `server/context.ts` |
| Root router export | `appRouter` | `export const appRouter` |
| Type export | `AppRouter` | `export type AppRouter` |
| Procedure aliases | descriptive noun | `publicProcedure`, `authedProcedure` |

These are community conventions, not enforced by the library. [Inference] Deviating from them in larger teams may increase onboarding friction, though behavior of tRPC itself is unaffected by file naming.

---

#### Circular Dependency Risks

A common structural mistake is creating circular imports between `trpc.ts` and `context.ts`.

```
# Problematic cycle:
trpc.ts  →  imports Context from context.ts
context.ts  →  imports something from trpc.ts  ← breaks the cycle
```

**Key Points**

- `context.ts` should have no imports from `trpc.ts`.
- `trpc.ts` imports only the `Context` type (not the value) from `context.ts`.
- Domain routers import from `trpc.ts` only, never from each other directly.

---

#### Monorepo Considerations

In monorepo setups (e.g., Turborepo, Nx), a common convention is to isolate the tRPC server into a dedicated package:

```
packages/
├── api/                     # tRPC server package
│   ├── src/
│   │   ├── trpc.ts
│   │   ├── context.ts
│   │   └── router/
│   │       └── index.ts
│   └── package.json
├── web/                     # Frontend consuming the API package
│   └── src/
│       └── utils/trpc.ts
└── package.json
```

**Key Points**

- The `api` package exports `AppRouter` as a type.
- The `web` package adds `api` as a dev dependency (type-only in production builds). [Inference] This pattern is common in official Turborepo + tRPC example repositories, though exact configurations vary by template version.

---

#### Next.js App Router Note

With Next.js App Router, the handler location shifts:

```
app/
└── api/
    └── trpc/
        └── [trpc]/
            └── route.ts     # Uses fetchRequestHandler instead of createNextApiHandler
```

[Inference] This distinction matters because App Router uses the Fetch API (`Request`/`Response`) rather than Node.js `req`/`res` objects, requiring a different tRPC adapter. Consult the tRPC documentation for the version-specific adapter name, as these have changed across releases.