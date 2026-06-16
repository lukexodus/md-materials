## Creating a Caller for Server-Side Testing

---

### Overview

A tRPC caller is a typed object that invokes procedures directly as async functions, bypassing HTTP transport entirely. In server-side testing, callers replace the client-side `trpc.*` calls used in application code with direct procedure invocations that run in the same process, against a controlled context.

This topic covers how callers are created, how they relate to context, how they behave with middleware, and the patterns needed to use them effectively across different testing scenarios.

---

### The Two Caller APIs

tRPC has two caller APIs depending on version. Understanding which one applies to your installation matters because they differ in how context is supplied.

#### tRPC v11: `createCallerFactory`

```ts
import { createCallerFactory } from '@trpc/server';
import { appRouter } from '../server/routers';

// Step 1 — create the factory once (outside tests, at module level)
const createCaller = createCallerFactory(appRouter);

// Step 2 — create a caller per test by supplying a context
const caller = createCaller(context);

// Step 3 — invoke procedures
const result = await caller.user.register({ email: 'test@example.com' });
```

`createCallerFactory` separates factory creation from context injection. The factory is created once and reused; the context is injected per test.

#### tRPC v10: `router.createCaller`

```ts
// v10 — factory and context supplied together
const caller = appRouter.createCaller(context);
const result = await caller.user.register({ email: 'test@example.com' });
```

[Inference: the v10 API remains functional in many v11 installations for backward compatibility, but `createCallerFactory` is the recommended v11 pattern — verify against your installed version's changelog]

---

### What the Caller Executes

When a procedure is called via a caller, the full procedure stack runs:

1. Input parsing and Zod validation
2. All middleware in the chain (auth guards, tenant guards, feature flags)
3. The resolver function
4. Output validation (if `.output()` is declared)

The caller does **not** execute:

- HTTP request parsing
- tRPC wire serialization / deserialization
- Error formatting configured in `createTRPCRouter` (error shape may differ slightly from HTTP responses) [Inference: verify error shape behavior for your formatter]

This means the caller is not a simulation of an HTTP call — it is a direct execution of procedure logic. Tests written against it test the procedure contract, not the transport layer.

---

### Minimal Working Example

```ts
// server/routers/greeting.ts
import { z } from 'zod';
import { router, publicProcedure } from '../trpc';

export const greetingRouter = router({
  hello: publicProcedure
    .input(z.object({ name: z.string() }))
    .query(({ input }) => `Hello, ${input.name}!`),
});
```

```ts
// tests/routers/greeting.test.ts
import { createCallerFactory } from '@trpc/server';
import { greetingRouter } from '../../server/routers/greeting';

const createCaller = createCallerFactory(greetingRouter);

it('returns a greeting', async () => {
  const caller = createCaller({});  // empty context — procedure requires none
  const result = await caller.hello({ name: 'World' });
  expect(result).toBe('Hello, World!');
});
```

---

### Caller with a Typed Context

For routers that require context — sessions, database clients, services — the context passed to the caller must satisfy the `Context` type.

```ts
// server/context.ts
export interface Context {
  session: { user: { id: string; role: string } } | null;
  db: IDatabase;
  mailer: IMailer;
}
```

```ts
// tests/routers/user.test.ts
import { createCallerFactory } from '@trpc/server';
import { appRouter } from '../../server/routers';
import { createTestContext } from '../helpers/createTestContext';

const createCaller = createCallerFactory(appRouter);

it('creates a user', async () => {
  const ctx = createTestContext();           // returns a Context with fakes
  const caller = createCaller(ctx);
  const result = await caller.user.register({ email: 'a@b.com' });
  expect(result.email).toBe('a@b.com');
});
```

**Key Points:**

- `createCaller` is typed — TypeScript will reject a context that does not satisfy `Context`
- Each `createCaller(ctx)` call produces an independent caller instance — there is no shared state between callers
- The caller inherits no state from previous calls — it is stateless between invocations

---

### Creating a Caller Factory Helper

Repeating `createCallerFactory(appRouter)` and context construction in every test file is verbose. A shared helper centralizes this:

```ts
// tests/helpers/caller.ts
import { createCallerFactory } from '@trpc/server';
import { appRouter } from '../../server/routers';
import { createTestContext } from './createTestContext';
import type { Context } from '../../server/context';

const createCaller = createCallerFactory(appRouter);

// Returns a caller with default test context
export function getCaller(contextOverrides: Partial<Context> = {}) {
  const ctx = createTestContext(contextOverrides);
  return createCaller(ctx);
}

// Returns a caller with an authenticated session
export function getAuthCaller(sessionOverrides = {}) {
  return getCaller({
    session: {
      user: {
        id: 'user_test',
        email: 'user@test.com',
        role: 'member',
        ...sessionOverrides,
      },
    },
  });
}

// Returns a caller with admin session
export function getAdminCaller() {
  return getAuthCaller({ role: 'admin' });
}
```

**Usage in tests:**

```ts
import { getCaller, getAuthCaller, getAdminCaller } from '../helpers/caller';

it('rejects unauthenticated request', async () => {
  const caller = getCaller();  // no session
  await expect(caller.post.create({ title: 'Test' }))
    .rejects.toMatchObject({ code: 'UNAUTHORIZED' });
});

it('creates a post when authenticated', async () => {
  const caller = getAuthCaller();
  const result = await caller.post.create({ title: 'Test' });
  expect(result.title).toBe('Test');
});

it('deletes any post when admin', async () => {
  const caller = getAdminCaller();
  // ...
});
```

---

### Caller with Async Context

When context creation is async — session resolution, database lookup, flag evaluation — the caller factory accepts a context value or a function returning a promise:

```ts
// Passing a context value directly
const ctx = await createRealContext(mockReq);
const caller = createCaller(ctx);
```

```ts
// Passing an async factory function (if your createCallerFactory supports it)
const caller = createCaller(async () => {
  const session = await resolveTestSession();
  return createTestContext({ session });
});
```

[Inference: whether `createCallerFactory` accepts a factory function depends on the tRPC version — the direct value form is universally supported; verify async factory support against your version]

For test environments, constructing the context before passing it to `createCaller` is simpler and less ambiguous:

```ts
const ctx = createTestContext({ session: await makeAsyncSession() });
const caller = createCaller(ctx);
```

---

### Caller Scope: Per-Test vs. Per-Suite

**Per-test (recommended for most cases):**

Each test creates a fresh caller with its own context and fake dependencies. No shared state — tests are fully independent.

```ts
describe('post.delete', () => {
  let caller: ReturnType<typeof createCaller>;
  let db: ReturnType<typeof makeInMemoryDb>;

  beforeEach(() => {
    db = makeInMemoryDb();
    caller = createCaller(createTestContext({
      session: makeSession(),
      db: db as any,
    }));
  });

  it('deletes an owned post', async () => {
    await db.post.create({ data: { id: 'p1', authorId: 'user_test' } });
    const result = await caller.post.delete({ id: 'p1' });
    expect(result.deleted).toBe(true);
  });

  it('throws NOT_FOUND for missing post', async () => {
    await expect(caller.post.delete({ id: 'nonexistent' }))
      .rejects.toMatchObject({ code: 'NOT_FOUND' });
  });
});
```

**Per-suite (appropriate for read-only or stateless procedures):**

If procedures do not mutate shared fake state, a single caller per describe block reduces setup verbosity.

```ts
describe('greeting.hello', () => {
  const caller = createCaller({});  // stateless — safe to share

  it('greets by name', async () => {
    expect(await caller.hello({ name: 'Alice' })).toBe('Hello, Alice!');
  });

  it('greets another name', async () => {
    expect(await caller.hello({ name: 'Bob' })).toBe('Hello, Bob!');
  });
});
```

---

### Caller for a Sub-Router

`createCallerFactory` accepts any router — not just the root `appRouter`. For testing a specific router in isolation without mounting it in the full app:

```ts
// tests/routers/post.test.ts
import { createCallerFactory } from '@trpc/server';
import { postRouter } from '../../server/routers/post';
import { createTestContext } from '../helpers/createTestContext';

// Caller scoped to postRouter — only post.* procedures available
const createCaller = createCallerFactory(postRouter);

it('lists posts', async () => {
  const db = makeInMemoryDb();
  await db.post.create({ data: { id: 'p1', title: 'First' } });

  const caller = createCaller(createTestContext({ db: db as any }));
  const result = await caller.list({});

  expect(result.items).toHaveLength(1);
});
```

**Key Points:**

- Testing a sub-router in isolation avoids loading the full application router
- TypeScript constrains the caller to only the procedures in the supplied router
- This is useful when the application router is large or has expensive initialization at module level

---

### Calling Nested Procedures

When the app router contains nested namespaces, the caller mirrors that structure:

```ts
export const appRouter = router({
  user: userRouter,          // user.*
  post: postRouter,          // post.*
  admin: router({
    user: adminUserRouter,   // admin.user.*
    billing: adminBillingRouter,
  }),
});
```

```ts
const caller = createCaller(ctx);

await caller.user.register({ email: 'a@b.com' });
await caller.post.list({ limit: 10 });
await caller.admin.user.deactivate({ userId: 'u1' });
await caller.admin.billing.refund({ invoiceId: 'inv_1' });
```

TypeScript infers the full nested type — calling a nonexistent path is a compile-time error.

---

### Capturing Side Effects

A caller invokes the full procedure, including side effects. Fake dependencies act as spies to assert on side effects without real infrastructure:

```ts
it('sends a password reset email', async () => {
  const mailer = makeMailerSpy();
  const db = makeInMemoryDb();

  // Seed an existing user
  await db.user.create({ data: { id: 'u1', email: 'user@test.com' } });

  const caller = createCaller(
    createTestContext({ db: db as any, mailer })
  );

  await caller.auth.requestPasswordReset({ email: 'user@test.com' });

  expect(mailer.calls).toContainEqual({
    type: 'passwordReset',
    email: 'user@test.com',
  });
});
```

---

### Testing Batched Calls

The server-side caller does not replicate HTTP batching behavior — each call is an independent invocation. To test that multiple procedures produce consistent results, call them sequentially within a single test:

```ts
it('create and immediately retrieve a post', async () => {
  const db = makeInMemoryDb();
  const caller = createCaller(
    createTestContext({ session: makeSession(), db: db as any })
  );

  const created = await caller.post.create({ title: 'Test Post' });
  const fetched = await caller.post.get({ id: created.id });

  expect(fetched.title).toBe('Test Post');
});
```

---

### Visualizing Caller Execution

FakeDepResolverMiddlewareCallerCallerFactoryTestFakeDepResolverMiddlewareCallerCallerFactoryTestcreateCallerFactory(router)createCaller functioncreateCaller(ctx)caller instancecaller.post.create({ title })run middleware chain with ctxctx narrowed (session confirmed)execute with { input, ctx }ctx.db.post.create(...)created recordresulttyped result

---

### Common Pitfalls

**Pitfall 1 — Calling `createCallerFactory` inside `beforeEach`:**
`createCallerFactory(appRouter)` should be called once at module level. It is stateless and safe to share. Only `createCaller(ctx)` needs to run per-test.

```ts
// ❌ Wasteful — factory recreated on every test
beforeEach(() => {
  const createCaller = createCallerFactory(appRouter); // unnecessary
  caller = createCaller(ctx);
});

// ✅ Factory at module level
const createCaller = createCallerFactory(appRouter);

beforeEach(() => {
  caller = createCaller(createTestContext());
});
```

**Pitfall 2 — Reusing a caller across tests that mutate state:**
A caller holds a reference to its context. If the context contains mutable fake state shared between tests, earlier tests affect later ones. Create a fresh context and caller per test when mutations are involved.

**Pitfall 3 — Expecting HTTP error shapes:**
The caller throws `TRPCError` instances — not HTTP responses. Do not assert on `.status` (HTTP) when you mean `.code` (tRPC). The `code` field uses tRPC error codes: `'UNAUTHORIZED'`, `'NOT_FOUND'`, `'BAD_REQUEST'`, etc.

**Pitfall 4 — Forgetting middleware runs:**
A caller is not a direct call to the resolver function. All middleware executes. If a test passes a null session and the procedure uses `protectedProcedure`, the middleware throws `UNAUTHORIZED` before the resolver runs. This is correct behavior — test for it explicitly.

**Pitfall 5 — Using `appRouter` when a sub-router suffices:**
Importing and initializing `appRouter` in every test file loads all routers, all their imports, and all module-level side effects. Sub-router callers are faster to initialize and have smaller import footprints.

---

**Conclusion**

The server-side caller — produced by `createCallerFactory` in tRPC v11 — is the definitive tool for testing procedures without HTTP infrastructure. A factory created once at module level generates per-test caller instances, each bound to a fabricated context. The caller executes the complete procedure stack: input validation, middleware, resolver, and output validation. Centralizing caller creation in a shared helper with role-specific variants (`getCaller`, `getAuthCaller`, `getAdminCaller`) reduces per-test boilerplate while keeping each test's context explicit and controlled.