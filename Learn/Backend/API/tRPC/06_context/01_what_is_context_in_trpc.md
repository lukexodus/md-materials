## What is Context in tRPC

Context in tRPC is a shared object that is created once per request and passed through to every procedure that handles that request. It serves as the primary mechanism for making request-scoped data — such as authenticated user information, database connections, session data, or HTTP headers — available to your procedures without manually threading those values through every function call.

---

### The Role of Context

When a client makes a request to a tRPC server, tRPC calls a `createContext` function you define. The object returned by that function becomes the `ctx` parameter available inside every procedure (query, mutation, or subscription) that runs during that request lifecycle.

This means context is the bridge between the raw HTTP layer (or any transport layer) and your tRPC procedure logic.

---

### Defining Context

Context is defined by exporting a `createContext` function, typically in a dedicated file such as `context.ts` or `trpc.ts`.

```ts
// server/context.ts
import type { CreateNextContextOptions } from '@trpc/server/adapters/next';

export async function createContext({ req, res }: CreateNextContextOptions) {
  return {
    req,
    res,
    user: null, // populated after auth check, for example
  };
}

export type Context = Awaited<ReturnType<typeof createContext>>;
```

The `Context` type export is important — it is used when initializing tRPC so that all procedures are aware of the context shape.

---

### Connecting Context to tRPC Initialization

When initializing tRPC on the server, you pass the `Context` type as a generic parameter:

```ts
// server/trpc.ts
import { initTRPC } from '@trpc/server';
import type { Context } from './context';

const t = initTRPC.context<Context>().create();

export const router = t.router;
export const publicProcedure = t.procedure;
```

This wires the context type into the procedure chain, giving you full type inference on `ctx` inside procedures.

---

### Accessing Context in a Procedure

Once connected, `ctx` is available as a typed parameter in the procedure resolver:

```ts
export const appRouter = router({
  whoAmI: publicProcedure.query(({ ctx }) => {
    // ctx is fully typed based on your createContext return value
    return ctx.user ?? 'Anonymous';
  }),
});
```

**Key Points**
- `ctx` is read-only by convention; mutating it inside a resolver is possible but generally discouraged
- The shape of `ctx` is consistent for all procedures unless modified by middleware
- Type inference flows automatically from `createContext` through to every resolver — no manual typing needed per procedure

---

### Async Context Creation

`createContext` can be `async`, which makes it suitable for operations like database lookups or session validation that need to resolve before the procedure runs:

```ts
export async function createContext({ req }: CreateNextContextOptions) {
  const session = await getSessionFromRequest(req);

  return {
    session,
    db: prismaClient,
  };
}
```

> [Inference] Performing expensive operations in `createContext` will add latency to every request regardless of whether the procedure uses the data. This suggests keeping context creation lean and deferring heavy work to middleware or the procedure itself where possible. Behavior may vary depending on your runtime and adapter.

---

### Context vs. Middleware

Context and middleware serve related but distinct roles:

| Concern | Context | Middleware |
|---|---|---|
| Created by | `createContext` function | `t.middleware()` |
| Runs | Once per request, before any procedure | Per procedure, in defined order |
| Purpose | Provide raw request-scoped values | Transform, augment, or gate access to `ctx` |
| Can modify `ctx`? | N/A — it *is* the initial `ctx` | Yes, via `next({ ctx: newCtx })` |

Middleware builds on top of context — it receives the context created by `createContext` and can extend or restrict it before the procedure resolver runs. This pattern is commonly used to attach authenticated user objects to `ctx` only for protected procedures.

---

### Context Across Adapters

tRPC supports multiple adapters (Next.js, Express, Fastify, Fetch API, etc.). The shape of the arguments passed to `createContext` differs per adapter, but the contract — return an object that becomes `ctx` — remains consistent.

**Example** using the Fetch adapter (used in environments like Cloudflare Workers or SvelteKit):

```ts
import { fetchRequestHandler } from '@trpc/server/adapters/fetch';

fetchRequestHandler({
  endpoint: '/api/trpc',
  req,
  router: appRouter,
  createContext: ({ req }) => ({
    authHeader: req.headers.get('authorization'),
  }),
});
```

---

### Summary

**Conclusion**

Context is the foundational request-scoped data layer in tRPC. It is created once per request via `createContext`, typed through `initTRPC`, and made available as `ctx` in every procedure resolver. It enables clean separation between transport-level concerns (headers, sessions, HTTP objects) and application logic, and it forms the base that middleware builds upon to enable patterns like authentication and authorization.