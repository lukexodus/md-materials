## The Router and Procedure Model

### What This Section Covers

The router and procedure are the two fundamental building blocks of every tRPC API. Everything else — middleware, context, subscriptions, nested routers — is built on top of these two concepts. This section covers what they are, how they are defined, how they relate to each other, and the full range of their configuration options.

---

### The Mental Model

Before any code, a useful mental model:

- A **procedure** is a single callable unit — analogous to a function endpoint. It has an optional input schema, an optional output schema, and a handler that runs when called.
- A **router** is a named collection of procedures — analogous to a controller or a route group. It organizes procedures into a tree structure that the client navigates.

The client calls procedures. The router is the map that tells the client which procedures exist and where.

---

### Initializing tRPC — `initTRPC`

Before defining any router or procedure, a tRPC instance must be created using `initTRPC`. This is the entry point for the entire server-side API.

```ts
import { initTRPC } from "@trpc/server";

const t = initTRPC.create();
```

`initTRPC.create()` returns an object — conventionally named `t` — that exposes:

- `t.router` — for creating routers
- `t.procedure` — the base procedure builder
- `t.middleware` — for creating middleware

**Why a factory instead of direct imports?**

`initTRPC` allows tRPC to be configured with context types, error formatters, and transformers before any procedures are defined. By creating the instance once and exporting `t.router`, `t.procedure`, and `t.middleware` from a single file, the entire API shares a consistent configuration.

**Conventional file structure:**

```ts
// src/trpc.ts
import { initTRPC } from "@trpc/server";

const t = initTRPC.create();

export const router = t.router;
export const publicProcedure = t.procedure;
export const middleware = t.middleware;
```

All routers and procedures in the project then import from this file, not directly from `@trpc/server`.

---

### Procedures

A procedure is defined using the procedure builder returned by `initTRPC`. The builder uses a fluent chain API — each method returns a new builder with the configuration accumulated so far.

#### The Three Procedure Types

tRPC has three procedure types, each corresponding to a different operation category:

|Type|Method|Semantic meaning|HTTP method (default)|
|---|---|---|---|
|Query|`.query()`|Read data, no side effects|GET|
|Mutation|`.mutation()`|Write data, has side effects|POST|
|Subscription|`.subscription()`|Real-time stream|WebSocket / SSE|

The distinction between query and mutation is semantic, not enforced at the transport level. However, it affects how the client calls the procedure and, with `httpBatchLink`, whether the request uses GET or POST.

---

#### Defining a Query

```ts
import { publicProcedure, router } from "./trpc";
import { z } from "zod";

const appRouter = router({
  getUser: publicProcedure
    .input(z.object({ id: z.number() }))
    .query(({ input }) => {
      return { id: input.id, name: "Alice" };
    }),
});
```

**What each part does:**

- `.input(schema)` — declares and validates the input. The `input` argument inside the handler is typed according to the schema.
- `.query(handler)` — declares this as a query procedure and provides the implementation. The handler receives `{ input, ctx }`.

The return value of the handler becomes the procedure's output type, inferred by TypeScript.

---

#### Defining a Mutation

```ts
const appRouter = router({
  createUser: publicProcedure
    .input(z.object({ name: z.string(), email: z.string().email() }))
    .mutation(async ({ input }) => {
      const user = await db.user.create({ data: input });
      return user;
    }),
});
```

Mutations are defined identically to queries, except `.mutation()` replaces `.query()`. The handler can be async — tRPC awaits the result automatically.

---

#### Defining a Subscription

Subscriptions emit a stream of values over time. They use tRPC's `observable` utility:

```ts
import { observable } from "@trpc/server/observable";

const appRouter = router({
  onMessage: publicProcedure
    .input(z.object({ channelId: z.string() }))
    .subscription(({ input }) => {
      return observable<{ text: string; timestamp: number }>((emit) => {
        const handler = (message: { text: string; timestamp: number }) => {
          emit.next(message);
        };

        messageEmitter.on(input.channelId, handler);

        return () => {
          messageEmitter.off(input.channelId, handler);
        };
      });
    }),
});
```

**Key points:**

- The `observable` callback receives an `emit` object with `.next()`, `.error()`, and `.complete()` methods
- The callback returns a cleanup function — called when the client disconnects
- Subscriptions require a WebSocket or SSE transport — `httpBatchLink` does not support them

> **Disclaimer:** Subscription behavior depends on the adapter and hosting environment. Not all deployment targets support persistent connections. Behavior is not guaranteed across all infrastructure configurations.

---

#### Procedures Without Input

Input is optional. A procedure without `.input()` receives no input argument:

```ts
const appRouter = router({
  healthCheck: publicProcedure.query(() => {
    return { status: "ok" };
  }),
});
```

The client calls it without arguments:

```ts
const result = await trpc.healthCheck.query();
```

---

#### Procedures With Output Validation

`.output()` adds an explicit output schema. The return value is validated against it at runtime, and the client's inferred type comes from the schema rather than the return value's inferred type:

```ts
const appRouter = router({
  getUser: publicProcedure
    .input(z.object({ id: z.number() }))
    .output(z.object({ id: z.number(), name: z.string() }))
    .query(({ input }) => {
      return { id: input.id, name: "Alice" };
    }),
});
```

**When to use `.output()`:**

- When the return value's inferred type is wider than the intended contract
- When runtime output validation is a requirement
- When the procedure returns data from an external source whose type cannot be fully trusted at compile time

> **Disclaimer:** `.output()` validates what the procedure returns before it reaches the client. It does not validate data from external sources before the procedure processes it. Runtime behavior depends on correct implementation.

---

### The Handler Arguments

Every procedure handler receives a single object argument. Its shape depends on the procedure configuration:

```ts
.query(({ input, ctx, rawInput, path, type }) => { ... })
```

|Property|Type|Description|
|---|---|---|
|`input`|Inferred from `.input()` schema|The validated, typed input|
|`ctx`|Inferred from context|The request context (auth, db, etc.)|
|`rawInput`|`unknown`|The input before validation|
|`path`|`string`|The procedure path (e.g. `"user.getUser"`)|
|`type`|`"query" \| "mutation" \| "subscription"`|The procedure type|

`input` and `ctx` are the most commonly used. `rawInput`, `path`, and `type` are primarily useful in middleware.

---

### Routers

A router is created by passing a record of procedures — or nested routers — to `t.router()`:

```ts
const appRouter = router({
  getUser: publicProcedure.query(() => ({ name: "Alice" })),
  createUser: publicProcedure.mutation(() => ({ success: true })),
});
```

The keys become the procedure names that the client uses to call them.

---

#### Nested Routers

Routers can be nested to organize procedures into logical groups:

```ts
const userRouter = router({
  get: publicProcedure
    .input(z.object({ id: z.number() }))
    .query(({ input }) => ({ id: input.id, name: "Alice" })),

  create: publicProcedure
    .input(z.object({ name: z.string() }))
    .mutation(({ input }) => ({ id: 1, name: input.name })),

  delete: publicProcedure
    .input(z.object({ id: z.number() }))
    .mutation(({ input }) => ({ deleted: input.id })),
});

const postRouter = router({
  list: publicProcedure.query(() => [{ id: 1, title: "Hello" }]),
  create: publicProcedure
    .input(z.object({ title: z.string() }))
    .mutation(({ input }) => ({ id: 2, title: input.title })),
});

const appRouter = router({
  user: userRouter,
  post: postRouter,
});
```

The client mirrors this structure:

```ts
const user = await trpc.user.get.query({ id: 1 });
const posts = await trpc.post.list.query();
await trpc.user.create.mutate({ name: "Bob" });
```

Nesting depth is not artificially limited, but very deep nesting can affect TypeScript's type instantiation performance. [Inference]

---

#### Merging Routers

In older tRPC versions, `mergeRouters` was used to combine flat routers. In v10+, nesting via `t.router({ sub: subRouter })` is the standard approach. `mergeRouters` still exists for merging routers at the same level without nesting:

```ts
import { mergeRouters } from "@trpc/server";

const combinedRouter = mergeRouters(userRouter, postRouter);
```

This flattens the procedures of both routers into a single router without namespace nesting. Useful when splitting a large flat router across multiple files without introducing nesting.

> **Disclaimer:** `mergeRouters` behavior and availability may vary by tRPC version. Verify against your installed version's documentation.

---

### The Procedure Builder Is Immutable

Each call on the procedure builder returns a new builder — it does not mutate the existing one. This makes it safe to create base procedures and extend them:

```ts
// Base procedure shared across the project
export const publicProcedure = t.procedure;

// Extended procedure with additional middleware
export const protectedProcedure = t.procedure.use(authMiddleware);

// Both can be used independently — neither affects the other
```

This is how tRPC supports different "tiers" of procedures (public, authenticated, admin) within the same router.

---

### Reusable Base Procedures

A common pattern is to define several base procedures with different middleware applied, then export them for use across route files:

```ts
// src/trpc.ts
import { initTRPC, TRPCError } from "@trpc/server";
import type { Context } from "./context";

const t = initTRPC.context<Context>().create();

export const router = t.router;

// No middleware — open to all callers
export const publicProcedure = t.procedure;

// Requires authenticated session in context
export const protectedProcedure = t.procedure.use(({ ctx, next }) => {
  if (!ctx.session?.user) {
    throw new TRPCError({ code: "UNAUTHORIZED" });
  }
  return next({ ctx: { ...ctx, user: ctx.session.user } });
});

// Requires admin role
export const adminProcedure = protectedProcedure.use(({ ctx, next }) => {
  if (ctx.user.role !== "admin") {
    throw new TRPCError({ code: "FORBIDDEN" });
  }
  return next({ ctx });
});
```

Procedures in route files then import the appropriate base:

```ts
// src/routers/user.ts
import { publicProcedure, protectedProcedure, router } from "../trpc";

export const userRouter = router({
  getPublicProfile: publicProcedure
    .input(z.object({ id: z.number() }))
    .query(({ input }) => ({ id: input.id, name: "Alice" })),

  getPrivateData: protectedProcedure
    .input(z.object({ id: z.number() }))
    .query(({ input, ctx }) => ({
      id: input.id,
      email: ctx.user.email,
    })),
});
```

---

### Procedure Paths

Every procedure has a path — a dot-separated string derived from its position in the router tree. This path is used internally by tRPC for routing, logging, and error reporting.

```ts
const appRouter = router({
  user: router({
    get: publicProcedure.query(() => {}),
  }),
  post: router({
    list: publicProcedure.query(() => {}),
  }),
});
```

|Procedure|Path|
|---|---|
|`user.get`|`"user.get"`|
|`post.list`|`"post.list"`|

The path is accessible inside the handler as `ctx` is, via the handler argument:

```ts
.query(({ path, type }) => {
  console.log(path);  // "user.get"
  console.log(type);  // "query"
})
```

---

### Router and Procedure Relationship Diagram

```
initTRPC.create()
        │
        ├── t.router(procedures) ──────────────────────────┐
        │                                                   │
        └── t.procedure                                     │
              │                                             │
              ├── .input(schema)                            │
              ├── .output(schema)                           │
              ├── .use(middleware)                          │
              └── .query() / .mutation() / .subscription()  │
                        │                                   │
                        └── Procedure ──────────────────────┤
                                                            │
                                          appRouter ◄───────┘
                                              │
                                    typeof appRouter
                                              │
                                          AppRouter
                                    (pure TypeScript type)
```

---

### Common Mistakes

#### Calling `t.router()` or `t.procedure` before `initTRPC.create()`

There is no global tRPC state. All routers and procedures must descend from the same `initTRPC` instance. Using `t.procedure` from one `initTRPC` instance inside a router created by another instance produces type errors and potentially runtime failures. [Inference]

#### Defining procedures outside a router

A procedure definition (the result of `.query()` or `.mutation()`) is not a callable handler by itself. It must be placed inside a router to be reachable by the client.

#### Mutating the procedure builder

The builder is immutable — each chain call returns a new builder. Storing an intermediate builder and calling different methods on it from different call sites is safe and intentional (this is how base procedures work). There is no shared mutable state.

---

### Summary of the Model

|Concept|Role|Defined with|
|---|---|---|
|`initTRPC`|Configuration entry point|`initTRPC.create()`|
|`t.procedure`|Base procedure builder|Returned by `initTRPC`|
|`.input()`|Adds input validation and type|Zod schema or compatible validator|
|`.output()`|Adds output validation and type|Zod schema or compatible validator|
|`.use()`|Adds middleware to the procedure|`t.middleware()`|
|`.query()`|Finalizes as a read procedure|Handler function|
|`.mutation()`|Finalizes as a write procedure|Handler function|
|`.subscription()`|Finalizes as a stream procedure|Handler returning `observable`|
|`t.router()`|Groups procedures into a tree|Record of procedures or sub-routers|
|`typeof appRouter`|Extracts the complete type contract|TypeScript `typeof` operator|

---

**Conclusion**

The router and procedure model is deliberately minimal. `initTRPC` establishes the configuration context. Procedures are built by chaining input, output, middleware, and a handler. Routers organize procedures into a named tree. The entire type contract flows from these definitions through `typeof appRouter` without any additional steps. This minimalism is what makes tRPC fast to write and easy to reason about — the structure of the API is the structure of the code.

**Next Steps**

The next topic covers context — how per-request data such as authentication sessions and database connections is created and made available to procedures.
