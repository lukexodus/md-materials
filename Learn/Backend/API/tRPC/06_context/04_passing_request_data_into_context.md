## Passing Request Data into Context

Context in tRPC is a mechanism for making shared data — such as authentication info, database clients, or parsed headers — available to all procedures without passing it manually through each call.

---

### What Is Context?

Context is an object created once per request and injected into every procedure handler. It is defined via a `createContext` function that receives the raw request and response objects from the underlying HTTP adapter.

**Key Points**
- Context is created server-side, per request.
- It is passed automatically to all procedures via `opts.ctx`.
- It is typed — procedures can rely on TypeScript to know what is available in `ctx`.

---

### Defining the Context Function

The `createContext` function is where request data is extracted and shaped into the context object.

```typescript
// server/context.ts
import { type CreateNextContextOptions } from '@trpc/server/adapters/next';

export async function createContext({ req, res }: CreateNextContextOptions) {
  return {
    req,
    res,
  };
}

export type Context = Awaited<ReturnType<typeof createContext>>;
```

The returned object becomes `ctx` inside every procedure.

---

### Extracting Common Request Data

#### Auth Tokens from Headers

```typescript
import { type CreateNextContextOptions } from '@trpc/server/adapters/next';

export async function createContext({ req, res }: CreateNextContextOptions) {
  const token = req.headers.authorization?.split(' ')[1] ?? null;

  return {
    token,
    req,
    res,
  };
}
```

#### Parsed Session (e.g., from a cookie-based session library)

```typescript
import { getSession } from 'next-auth/react';
import { type CreateNextContextOptions } from '@trpc/server/adapters/next';

export async function createContext({ req, res }: CreateNextContextOptions) {
  const session = await getSession({ req });

  return {
    session,
    req,
    res,
  };
}
```

**Note:** `session` may be `null` if the user is unauthenticated. Procedures should handle this explicitly.

#### Database Client

```typescript
import { prisma } from '../lib/prisma';
import { type CreateNextContextOptions } from '@trpc/server/adapters/next';

export async function createContext({ req, res }: CreateNextContextOptions) {
  return {
    prisma,
    req,
    res,
  };
}
```

[Inference] Attaching a shared client instance (rather than instantiating per request) is a common pattern, but behavior of the client under concurrent load depends on the library used. Behavior may vary.

---

### Registering Context with the Router

The `createContext` function is passed to the adapter when mounting the tRPC router.

#### Next.js API Route

```typescript
// pages/api/trpc/[trpc].ts
import { createNextApiHandler } from '@trpc/server/adapters/next';
import { appRouter } from '../../../server/routers/_app';
import { createContext } from '../../../server/context';

export default createNextApiHandler({
  router: appRouter,
  createContext,
});
```

---

### Using Context Inside Procedures

Once defined, `ctx` is available in every procedure's handler via `opts`.

```typescript
import { router, publicProcedure } from './trpc';

export const appRouter = router({
  whoAmI: publicProcedure.query(({ ctx }) => {
    return {
      token: ctx.token,
    };
  }),
});
```

If the context type is properly exported and wired through `initTRPC`, TypeScript will infer the shape of `ctx` automatically.

---

### Initializing tRPC with the Context Type

To get full type inference on `ctx` inside procedures, pass the context type to `initTRPC`.

```typescript
// server/trpc.ts
import { initTRPC } from '@trpc/server';
import { type Context } from './context';

const t = initTRPC.context<Context>().create();

export const router = t.router;
export const publicProcedure = t.procedure;
```

**Key Points**
- `initTRPC.context<Context>()` binds the context type to all procedures created from `t`.
- Without this, `ctx` will be typed as `object` and field access will not be type-safe.

---

### Async Context Creation

`createContext` can be async, which is useful for operations like session lookups or database calls that require awaiting.

```typescript
export async function createContext({ req, res }: CreateNextContextOptions) {
  const user = await getUserFromToken(req.headers.authorization);

  return {
    user,
    req,
    res,
  };
}
```

[Inference] If `createContext` throws, the request will likely fail before reaching any procedure. Error handling behavior at this layer may vary depending on the adapter used.

---

### Context Shape Across Adapters

Different adapters expose different raw objects to `createContext`. The shape of the arguments differs per adapter.

| Adapter | Context Args Type |
|---|---|
| Next.js (Pages) | `CreateNextContextOptions` |
| Express | `CreateExpressContextOptions` |
| Fastify | `CreateFastifyContextOptions` |
| Fetch (e.g., Remix, Edge) | `FetchCreateContextFnOptions` |

The returned context object shape is your own design — the adapter only dictates what raw inputs you receive.

---

### Inner and Outer Context Pattern

For cases where some context data is expensive to compute and only needed conditionally, tRPC supports splitting context into outer (cheap, always-run) and inner (expensive, conditionally used) parts.

```typescript
// Inner context — pure data, no request dependency
async function createInnerContext({ user }: { user: User | null }) {
  return {
    user,
    prisma,
  };
}

// Outer context — receives request, extracts data, calls inner
export async function createContext({ req, res }: CreateNextContextOptions) {
  const user = await getUserFromRequest(req);

  return {
    ...(await createInnerContext({ user })),
    req,
    res,
  };
}
```

**Key Points**
- The inner context function is independently testable without a live HTTP request.
- [Inference] This pattern is particularly useful when writing unit tests for procedures, as `createInnerContext` can be called directly with mock data. Testing behavior depends on your test setup.

---

### What Not to Put in Context

Not everything belongs in context. Consider these guidelines:

- **Do include:** auth state, database clients, logger instances, request metadata.
- **Avoid:** large payloads, per-procedure business logic, mutable shared state that could bleed across requests.

[Inference] Mutable shared state in context could cause data to leak between requests in server environments that reuse handler instances. The actual behavior depends on the runtime and framework.