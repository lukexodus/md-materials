## Setting Up a Monorepo vs Single-Repo Structure

### Why the Project Structure Decision Matters for tRPC

tRPC's type safety depends on the `AppRouter` type being accessible to the client. How you make that type available is largely a structural decision. The two primary approaches — a single repository containing both server and client, or a monorepo with separate packages — each have different tradeoffs in complexity, scalability, and maintainability.

---

### The Core Constraint

Regardless of structure, this must be true:

> The client must be able to import the `AppRouter` type from the server without importing server implementation code.

Everything else — file layout, tooling, build steps — is in service of satisfying this constraint cleanly.

---

### Single-Repo Structure

In a single repository, the server and client live in the same project. This is the simplest setup and is natural for full-stack frameworks like Next.js, where the API and frontend are co-located by design.

**When it fits well**

- A Next.js project where the API routes and React frontend are in the same codebase
- Small to medium projects where splitting into packages adds unnecessary overhead
- Teams where the same developers work on both client and server

**Typical layout — Next.js**

```
my-app/
├── src/
│   ├── server/
│   │   ├── trpc.ts          ← initTRPC and base procedure
│   │   ├── routers/
│   │   │   ├── user.ts
│   │   │   └── post.ts
│   │   └── root.ts          ← AppRouter assembled here
│   ├── utils/
│   │   └── trpc.ts          ← client setup, imports AppRouter type
│   ├── pages/
│   │   ├── api/
│   │   │   └── trpc/
│   │   │       └── [trpc].ts ← API route handler
│   │   └── index.tsx
│   └── components/
├── tsconfig.json
└── package.json
```

**How the type flows**

```ts
// src/server/root.ts
export type AppRouter = typeof appRouter;

// src/utils/trpc.ts
import type { AppRouter } from '../server/root';

export const trpc = createTRPCReactClient<AppRouter>({ ... });
```

Because the server and client are in the same TypeScript project, the `import type` resolves directly. No build step, no publishing, no package boundary.

**Key Point:** The `import type` keyword is critical here. It imports only the type and is erased at compile time. No server code reaches the client bundle.

---

### Monorepo Structure

A monorepo houses multiple packages in one repository, each with its own `package.json`. The tRPC server lives in one package, the client app in another, and the shared `AppRouter` type in a third.

**When it fits well**

- Projects with a separately deployable backend and frontend (e.g., an Express API and a React SPA, or a React Native app alongside a web app)
- Teams where backend and frontend are developed somewhat independently
- Projects that may add additional consumers of the API over time (mobile app, CLI, etc.)
- Organizations already using monorepo tooling

**Typical layout — pnpm workspaces**

```
my-monorepo/
├── packages/
│   └── api/                 ← shared tRPC router types
│       ├── src/
│       │   ├── trpc.ts
│       │   ├── routers/
│       │   │   ├── user.ts
│       │   │   └── post.ts
│       │   └── root.ts      ← AppRouter defined and exported
│       ├── package.json
│       └── tsconfig.json
├── apps/
│   ├── server/              ← Express or standalone HTTP server
│   │   ├── src/
│   │   │   └── index.ts     ← mounts tRPC adapter
│   │   ├── package.json
│   │   └── tsconfig.json
│   └── web/                 ← React frontend
│       ├── src/
│       │   ├── utils/
│       │   │   └── trpc.ts  ← client setup
│       │   └── App.tsx
│       ├── package.json
│       └── tsconfig.json
├── pnpm-workspace.yaml
├── turbo.json               ← if using Turborepo
└── package.json
```

**pnpm-workspace.yaml**

```yaml
packages:
  - 'apps/*'
  - 'packages/*'
```

**packages/api/package.json**

```json
{
  "name": "@my-org/api",
  "version": "0.1.0",
  "exports": {
    ".": "./src/root.ts"
  },
  "dependencies": {
    "@trpc/server": "11.x.x",
    "zod": "^3.x.x"
  }
}
```

**apps/web/package.json**

```json
{
  "name": "@my-org/web",
  "dependencies": {
    "@my-org/api": "workspace:*",
    "@trpc/client": "11.x.x",
    "@trpc/react-query": "11.x.x",
    "@tanstack/react-query": "^5.x.x"
  }
}
```

**How the type flows**

```ts
// apps/web/src/utils/trpc.ts
import type { AppRouter } from '@my-org/api';
import { createTRPCReactClient } from '@trpc/react-query';

export const trpc = createTRPCReactClient<AppRouter>({ ... });
```

The `workspace:*` protocol tells pnpm to resolve `@my-org/api` from the local monorepo rather than the npm registry. TypeScript follows the `exports` field in the package's `package.json` to find the types.

---

### TypeScript Project References in a Monorepo

For TypeScript to resolve types correctly across packages without a build step, you can use **project references**. This allows TypeScript to understand the dependency graph between packages and provide accurate type checking incrementally.

**packages/api/tsconfig.json**

```json
{
  "compilerOptions": {
    "strict": true,
    "composite": true,
    "outDir": "./dist",
    "rootDir": "./src",
    "declaration": true
  }
}
```

**apps/web/tsconfig.json**

```json
{
  "compilerOptions": {
    "strict": true,
    "paths": {
      "@my-org/api": ["../../packages/api/src/root.ts"]
    }
  },
  "references": [
    { "path": "../../packages/api" }
  ]
}
```

[Inference] Using `paths` to point directly at the source TypeScript file (rather than compiled output) avoids needing to run a build step during development. This is a common pattern in tRPC monorepos but relies on your bundler or dev server understanding TypeScript paths, which varies by tooling.

---

### Monorepo Tooling Options

Monorepo tooling handles task orchestration — running builds, tests, and dev servers across packages in the right order.

| Tool | Notes |
|---|---|
| **Turborepo** | Task graph caching; commonly shown in tRPC official examples |
| **Nx** | More opinionated; built-in code generators |
| **pnpm workspaces alone** | Sufficient for simpler setups without caching |
| **Yarn workspaces** | Similar to pnpm workspaces; less common in tRPC examples |

None of these are required by tRPC. They solve build orchestration, not the type-sharing problem. [Inference] For small monorepos with few packages, workspace support from the package manager alone may be sufficient without adding a task runner.

---

### Structure Comparison

| Concern | Single-Repo | Monorepo |
|---|---|---|
| Initial setup complexity | Low | Medium to high |
| Type sharing mechanism | Direct `import type` | Package + workspace resolution |
| Build step required to share types | No | Optional (paths or compiled output) |
| Independent deployment of server/client | Harder | Natural |
| Multiple clients sharing one API | Awkward | Clean |
| Tooling overhead | Minimal | Package manager + optional task runner |
| Suitable for Next.js full-stack | Yes — idiomatic | Possible but adds complexity |
| Suitable for separate backend/frontend | Possible but strained | Yes — idiomatic |

---

### Common Mistakes

**Importing server implementation on the client**

In both structures, you must use `import type` — not a regular `import` — when bringing the `AppRouter` type into the client. A regular import pulls in the implementation, which may include server-only dependencies and will fail or bloat the client bundle.

```ts
// Correct
import type { AppRouter } from '../server/root';

// Incorrect — imports implementation code
import { AppRouter } from '../server/root';
```

**Mismatched `@trpc/*` versions across packages**

In a monorepo, `@trpc/server` in `packages/api` and `@trpc/client` in `apps/web` must be on the same major version. If they resolve to different versions, the types will not align.

[Inference] Hoisting all `@trpc/*` packages to the root `package.json` of the monorepo is one way to enforce a single resolved version, though this depends on how your package manager handles hoisting.

**Circular dependencies between packages**

If `apps/server` depends on `packages/api`, and `packages/api` inadvertently imports from `apps/server`, TypeScript will either error or silently produce incorrect types. Keep the dependency graph unidirectional: `apps/*` depend on `packages/*`, never the reverse.

---

### Choosing a Structure

A single-repo is the right starting point if you are building a Next.js full-stack application. The co-location of API and frontend is a core part of the Next.js model, and adding monorepo tooling on top of it is rarely worth the overhead unless you have a concrete need.

A monorepo becomes the better fit when any of these is true:

- Your server and client are deployed independently
- You have or anticipate multiple clients (web, mobile, CLI)
- Your team has a meaningful split between backend and frontend work
- You are integrating tRPC into an existing monorepo

[Inference] Starting with a single-repo and migrating to a monorepo later is a realistic path. The type-sharing contract in tRPC is the same in both cases — only the mechanism for satisfying it changes.