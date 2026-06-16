### Creating the Context Function

The `createContext` function is the entry point for all request-scoped data in tRPC. It runs once per incoming request and its return value becomes the `ctx` object available in every procedure. Defining it correctly — with the right adapter types, async handling, and exported type — is foundational to everything that builds on top of it.

---

#### Basic Shape

At minimum, `createContext` is a function that returns a plain object:

```ts
export function createContext() {
  return {};
}

export type Context = Awaited<ReturnType<typeof createContext>>;
```

Even an empty context is valid. The `Context` type export is not optional in practice — it is consumed by `initTRPC.context<Context>()` to propagate type information across all procedures.

---

#### Adapter-Specific Arguments

The arguments passed to `createContext` depend on which tRPC adapter your server uses. Each adapter provides its own type for the options parameter.

##### Next.js Pages Router

```ts
import type { CreateNextContextOptions } from '@trpc/server/adapters/next';

export function createContext({ req, res }: CreateNextContextOptions) {
  return { req, res };
}
```

##### Express

```ts
import type { CreateExpressContextOptions } from '@trpc/server/adapters/express';

export function createContext({ req, res }: CreateExpressContextOptions) {
  return { req, res };
}
```

##### Fetch API (SvelteKit, Cloudflare Workers, Next.js App Router)

```ts
import type { FetchCreateContextFnOptions } from '@trpc/server/adapters/fetch';

export function createContext({ req }: FetchCreateContextFnOptions) {
  return { req };
}
```

**Key Points**

- Always import the options type from the correct adapter path
- The `req` and `res` objects are adapter-specific — their types differ across adapters
- Not all adapters provide a `res` object (e.g., the Fetch adapter does not)

---

#### Async Context Creation

`createContext` fully supports `async`/`await`. This is necessary when context depends on values that must be resolved before procedures run — such as sessions, tokens, or database connections.

```ts
import type { CreateNextContextOptions } from '@trpc/server/adapters/next';
import { getSession } from 'next-auth/react';

export async function createContext({ req, res }: CreateNextContextOptions) {
  const session = await getSession({ req });

  return {
    req,
    res,
    session,
  };
}

export type Context = Awaited<ReturnType<typeof createContext>>;
```

The `Awaited<ReturnType<typeof createContext>>` pattern correctly unwraps the `Promise` so the `Context` type reflects the resolved object, not the promise itself.

---

#### Including a Database Client

Database clients are a common context attachment. Since most database clients (Prisma, Drizzle, Kysely, etc.) are instantiated once and reused across requests, they are typically imported from a shared module rather than created per-request:

```ts
// server/db.ts
import { PrismaClient } from '@prisma/client';

export const db = new PrismaClient();
```

```ts
// server/context.ts
import type { CreateNextContextOptions } from '@trpc/server/adapters/next';
import { db } from './db';

export async function createContext({ req, res }: CreateNextContextOptions) {
  return {
    req,
    res,
    db,
  };
}

export type Context = Awaited<ReturnType<typeof createContext>>;
```

> [Inference] Instantiating a new database client inside `createContext` on every request is likely to exhaust connection pools under load. Sharing a single instance across requests is the conventional approach. Actual behavior depends on the client library and runtime environment.

---

#### Partial Authentication Pattern

A common pattern is to attempt authentication inside `createContext` but not enforce it there — that responsibility is delegated to middleware. Context makes the user available; middleware decides whether to reject the request.

```ts
import type { CreateNextContextOptions } from '@trpc/server/adapters/next';
import { getUserFromToken } from './auth';

export async function createContext({ req, res }: CreateNextContextOptions) {
  const token = req.headers.authorization?.split(' ')[1] ?? null;
  const user = token ? await getUserFromToken(token) : null;

  return {
    req,
    res,
    user, // null if unauthenticated
  };
}

export type Context = Awaited<ReturnType<typeof createContext>>;
```

Public procedures receive a context where `user` may be `null`. Protected procedures use middleware to verify `user` is non-null before the resolver runs.

---

#### Wiring createContext to the Router

Once defined, `createContext` is passed to the adapter handler — not to `initTRPC`. The initialization step only receives the `Context` type:

```ts
// server/trpc.ts
import { initTRPC } from '@trpc/server';
import type { Context } from './context';

const t = initTRPC.context<Context>().create();

export const router = t.router;
export const publicProcedure = t.procedure;
```

```ts
// pages/api/trpc/[trpc].ts  (Next.js Pages Router example)
import { createNextApiHandler } from '@trpc/server/adapters/next';
import { createContext } from '../../../server/context';
import { appRouter } from '../../../server/router';

export default createNextApiHandler({
  router: appRouter,
  createContext,
});
```

**Key Points**

- `createContext` is provided at the adapter/handler level
- `initTRPC` receives only the `Context` type, not the function itself
- The two wiring steps are separate and both are required for full type inference

---

#### Inner and Outer Context Pattern

For scenarios where part of the context is expensive or varies per procedure (e.g., decoding a JWT on every request), tRPC documentation describes an inner/outer context split:

```ts
// The cheap, always-available part
export function createContextInner() {
  return {
    db,
  };
}

// The full context, built on top of the inner context
export async function createContext({ req, res }: CreateNextContextOptions) {
  const inner = createContextInner();
  const user = await getUserFromRequest(req);

  return {
    ...inner,
    req,
    res,
    user,
  };
}

export type Context = Awaited<ReturnType<typeof createContext>>;
export type InnerContext = ReturnType<typeof createContextInner>;
```

**Key Points**

- `createContextInner` is synchronous and testable in isolation
- Procedures can be unit-tested by calling `createContextInner()` directly, bypassing HTTP concerns
- [Inference] This pattern may reduce friction in test setups where mocking HTTP request objects is undesirable. Actual testability depends on your testing setup.

---

#### Type Export Checklist

| Export | Purpose |
| --- | --- |
| `createContext` (function) | Passed to the adapter handler |
| `Context` (type) | Passed to `initTRPC.context<Context>()` |
| `InnerContext` (type, optional) | Used for unit testing procedures directly |

---

#### Common Mistakes

**Forgetting to export the `Context` type**
Without it, `initTRPC.context()` cannot infer the shape of `ctx`, resulting in `ctx` being typed as `object` or `unknown` in procedures.

**Using `ReturnType` without `Awaited` on an async function**

```ts
// Incorrect — resolves to Promise<{ user: User | null }>
export type Context = ReturnType<typeof createContext>;

// Correct — resolves to { user: User | null }
export type Context = Awaited<ReturnType<typeof createContext>>;
```

**Creating heavy resources per-request inside `createContext`**

> [Inference] Constructing a new database connection or performing a full auth round-trip on every request — even for procedures that do not need it — may introduce unnecessary latency. Behavior and impact depend on the specific service, infrastructure, and load profile.

---

#### Conclusion

The `createContext` function is the designated place to gather raw request-scoped values and make them available throughout your procedure tree. Defining it with the correct adapter types, handling async correctly, exporting the `Context` type, and keeping it lean in scope are the core practices that make everything downstream — middleware, protected procedures, and testing — easier to reason about.