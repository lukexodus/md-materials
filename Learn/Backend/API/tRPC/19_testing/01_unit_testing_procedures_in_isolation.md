## Unit Testing Procedures in Isolation

---

### Overview

Unit testing tRPC procedures in isolation means exercising a procedure's logic — input validation, authorization checks, resolver behavior, error handling — without starting an HTTP server, without real database connections, and without coupling tests to implementation details of dependencies.

tRPC provides first-class support for this through **server-side callers**, which invoke procedures directly as typed async functions. Combined with interface-typed context and injected fake dependencies, procedures can be tested with the same rigor as any other unit of business logic.

---

### The Server-Side Caller

tRPC v11 exposes `createCallerFactory`, which produces a factory that creates a typed caller for any router given a context value. This is the primary mechanism for unit testing procedures.

```ts
// Basic shape
const createCaller = createCallerFactory(appRouter);
const caller = createCaller(context);

// Procedures are called as typed async functions
const result = await caller.user.register({ email: 'test@example.com' });
```

No HTTP, no serialization, no network — the procedure runs as a plain function call with full TypeScript inference on inputs and outputs.

[Inference: `createCallerFactory` is the tRPC v11 API; tRPC v10 used `appRouter.createCaller(context)` directly — verify against your installed version]

---

### Test Context Setup

The foundation of isolated procedure testing is a fabricated context. The test context satisfies the `Context` type using in-memory fakes rather than real infrastructure.

```ts
// tests/helpers/createTestContext.ts
import type { Context } from '../../server/context';

// Minimal no-op logger
export const noopLogger = {
  info: () => {},
  warn: () => {},
  error: () => {},
};

// In-memory fake database
export function makeInMemoryDb() {
  const users: Map<string, any> = new Map();
  const posts: Map<string, any> = new Map();

  return {
    user: {
      create: async ({ data }: any) => {
        const record = { id: `user_${Date.now()}`, ...data };
        users.set(record.id, record);
        return record;
      },
      findUnique: async ({ where }: any) => {
        if (where.id) return users.get(where.id) ?? null;
        if (where.email) {
          return [...users.values()].find(u => u.email === where.email) ?? null;
        }
        return null;
      },
      update: async ({ where, data }: any) => {
        const existing = users.get(where.id);
        if (!existing) throw new Error('Record not found.');
        const updated = { ...existing, ...data };
        users.set(where.id, updated);
        return updated;
      },
      delete: async ({ where }: any) => {
        users.delete(where.id);
      },
      findMany: async () => [...users.values()],
    },
    post: {
      create: async ({ data }: any) => {
        const record = { id: `post_${Date.now()}`, ...data };
        posts.set(record.id, record);
        return record;
      },
      findUnique: async ({ where }: any) => posts.get(where.id) ?? null,
      findMany: async ({ where }: any = {}) => {
        const all = [...posts.values()];
        if (where?.authorId) return all.filter(p => p.authorId === where.authorId);
        return all;
      },
      delete: async ({ where }: any) => { posts.delete(where.id); },
    },
  };
}

// Fake mailer — records calls for assertion
export function makeMailerSpy() {
  const calls: { type: string; email: string }[] = [];
  return {
    calls,
    sendWelcome: async (email: string) => {
      calls.push({ type: 'welcome', email });
    },
    sendPasswordReset: async (email: string) => {
      calls.push({ type: 'passwordReset', email });
    },
  };
}

// Test context factory
export function createTestContext(overrides: Partial<Context> = {}): Context {
  return {
    session: null,
    db: makeInMemoryDb() as any,
    mailer: makeMailerSpy(),
    logger: noopLogger,
    ...overrides,
  };
}

// Authenticated session helper
export function makeSession(overrides: Partial<Session> = {}) {
  return {
    user: {
      id: 'user_test',
      email: 'user@test.com',
      role: 'member' as const,
      ...overrides,
    },
  };
}
```

---

### Basic Procedure Test

```ts
// tests/routers/user.test.ts
import { createCallerFactory } from '@trpc/server';
import { appRouter } from '../../server/routers';
import { createTestContext, makeSession, makeMailerSpy } from '../helpers/createTestContext';

const createCaller = createCallerFactory(appRouter);

describe('user.register', () => {
  it('returns the created user', async () => {
    const ctx = createTestContext();
    const caller = createCaller(ctx);

    const result = await caller.user.register({ email: 'new@example.com' });

    expect(result.email).toBe('new@example.com');
    expect(result.id).toBeDefined();
  });

  it('sends a welcome email on registration', async () => {
    const mailer = makeMailerSpy();
    const ctx = createTestContext({ mailer });
    const caller = createCaller(ctx);

    await caller.user.register({ email: 'welcome@example.com' });

    expect(mailer.calls).toContainEqual({
      type: 'welcome',
      email: 'welcome@example.com',
    });
  });

  it('rejects duplicate email addresses', async () => {
    const ctx = createTestContext();
    const caller = createCaller(ctx);

    await caller.user.register({ email: 'dupe@example.com' });

    await expect(
      caller.user.register({ email: 'dupe@example.com' })
    ).rejects.toMatchObject({ code: 'CONFLICT' });
  });
});
```

---

### Testing Input Validation

Zod validation errors surface as `TRPCError` with code `BAD_REQUEST` when procedures are called via the caller. Input validation is testable without any resolver logic running.

```ts
describe('user.register — input validation', () => {
  it('rejects an invalid email format', async () => {
    const ctx = createTestContext();
    const caller = createCaller(ctx);

    await expect(
      caller.user.register({ email: 'not-an-email' })
    ).rejects.toMatchObject({ code: 'BAD_REQUEST' });
  });

  it('rejects an empty email string', async () => {
    const ctx = createTestContext();
    const caller = createCaller(ctx);

    await expect(
      caller.user.register({ email: '' })
    ).rejects.toMatchObject({ code: 'BAD_REQUEST' });
  });
});
```

**Key Points:**

- Input validation errors are thrown before the resolver function runs — testing them does not require any fake dependency setup
- The error shape from the server-side caller matches `TRPCError` — assertions on `.code` and `.message` are reliable [Inference: exact error shape may vary depending on tRPC version and error formatter configuration]

---

### Testing Authorization

Authorization middleware is part of the procedure and runs when the caller invokes it. Testing it requires constructing contexts with and without valid sessions.

```ts
// server/routers/post.ts (example procedure under test)
export const postRouter = router({
  delete: protectedProcedure   // requires authentication
    .input(z.object({ id: z.string() }))
    .mutation(async ({ input, ctx }) => {
      const post = await ctx.db.post.findUnique({ where: { id: input.id } });

      if (!post) throw new TRPCError({ code: 'NOT_FOUND' });

      if (post.authorId !== ctx.session.user.id) {
        throw new TRPCError({ code: 'FORBIDDEN' });
      }

      await ctx.db.post.delete({ where: { id: input.id } });
      return { deleted: true };
    }),
});
```

```ts
// tests/routers/post.test.ts
describe('post.delete', () => {
  it('throws UNAUTHORIZED when session is absent', async () => {
    const ctx = createTestContext({ session: null });
    const caller = createCaller(ctx);

    await expect(
      caller.post.delete({ id: 'post_1' })
    ).rejects.toMatchObject({ code: 'UNAUTHORIZED' });
  });

  it('throws FORBIDDEN when user does not own the post', async () => {
    const db = makeInMemoryDb();
    await db.post.create({ data: { id: 'post_1', authorId: 'other_user' } });

    const ctx = createTestContext({
      session: makeSession({ id: 'current_user' }),
      db: db as any,
    });
    const caller = createCaller(ctx);

    await expect(
      caller.post.delete({ id: 'post_1' })
    ).rejects.toMatchObject({ code: 'FORBIDDEN' });
  });

  it('deletes the post when the user is the author', async () => {
    const db = makeInMemoryDb();
    await db.post.create({ data: { id: 'post_1', authorId: 'current_user' } });

    const ctx = createTestContext({
      session: makeSession({ id: 'current_user' }),
      db: db as any,
    });
    const caller = createCaller(ctx);

    const result = await caller.post.delete({ id: 'post_1' });
    expect(result.deleted).toBe(true);
  });
});
```

---

### Testing Middleware in Isolation

Middleware can be tested independently of any specific procedure by constructing a minimal procedure that uses it and calling it via a test caller.

```ts
// tests/middleware/tenantGuard.test.ts
import { initTRPC, TRPCError } from '@trpc/server';
import { createCallerFactory } from '@trpc/server';
import { tenantGuard } from '../../server/middleware/tenantGuard';
import { createTestContext } from '../helpers/createTestContext';

// Minimal tRPC instance for middleware testing
const t = initTRPC.context<Context>().create();

const testRouter = t.router({
  ping: t.procedure
    .use(tenantGuard)
    .query(() => ({ pong: true })),
});

const createCaller = createCallerFactory(testRouter);

describe('tenantGuard middleware', () => {
  it('allows requests with valid membership', async () => {
    const ctx = createTestContext({
      session: makeSession(),
      tenant: { id: 'tenant_1', slug: 'acme' },
      membership: { role: 'member' },
    });
    const caller = createCaller(ctx);

    await expect(caller.ping()).resolves.toEqual({ pong: true });
  });

  it('throws NOT_FOUND when tenant is absent', async () => {
    const ctx = createTestContext({
      session: makeSession(),
      tenant: null,
    });
    const caller = createCaller(ctx);

    await expect(caller.ping()).rejects.toMatchObject({ code: 'NOT_FOUND' });
  });

  it('throws FORBIDDEN when user has no membership', async () => {
    const ctx = createTestContext({
      session: makeSession(),
      tenant: { id: 'tenant_1', slug: 'acme' },
      membership: null,
    });
    const caller = createCaller(ctx);

    await expect(caller.ping()).rejects.toMatchObject({ code: 'FORBIDDEN' });
  });
});
```

**Key Points:**

- A test router with a single `ping` procedure isolates the middleware from all application logic
- This approach tests the middleware contract directly — not as a side effect of testing another procedure
- The same pattern applies to any custom middleware: rate limiters, feature flag guards, audit loggers

---

### Testing Output Shape

When procedures declare `.output()` schemas, verifying the response shape is straightforward:

```ts
describe('post.list — output shape', () => {
  it('returns items and nextCursor', async () => {
    const db = makeInMemoryDb();
    await db.post.create({ data: { id: 'p1', title: 'First', authorId: 'u1' } });
    await db.post.create({ data: { id: 'p2', title: 'Second', authorId: 'u1' } });

    const ctx = createTestContext({ db: db as any });
    const caller = createCaller(ctx);

    const result = await caller.post.list({ limit: 1 });

    expect(result).toMatchObject({
      items: expect.arrayContaining([
        expect.objectContaining({ id: expect.any(String) }),
      ]),
      nextCursor: expect.any(String),
    });
  });

  it('returns no nextCursor on the last page', async () => {
    const db = makeInMemoryDb();
    await db.post.create({ data: { id: 'p1', title: 'Only', authorId: 'u1' } });

    const ctx = createTestContext({ db: db as any });
    const caller = createCaller(ctx);

    const result = await caller.post.list({ limit: 10 });

    expect(result.nextCursor).toBeUndefined();
  });
});
```

---

### Structuring Test Files

Consistent structure reduces cognitive overhead when navigating tests across a large project.

```
tests/
  helpers/
    createTestContext.ts     ← shared context factory and fakes
    factories/
      user.factory.ts        ← creates test User records
      post.factory.ts
  routers/
    user.test.ts
    post.test.ts
    admin.test.ts
  middleware/
    tenantGuard.test.ts
    requireFlag.test.ts
    rateLimitGuard.test.ts
```

**Test factory helpers** reduce duplication in test setup:

```ts
// tests/helpers/factories/post.factory.ts
import { makeInMemoryDb } from '../createTestContext';

type PostDb = ReturnType<typeof makeInMemoryDb>;

export async function createPost(
  db: PostDb,
  overrides: Partial<{ id: string; title: string; authorId: string }> = {}
) {
  return db.post.create({
    data: {
      id: `post_${Math.random().toString(36).slice(2)}`,
      title: 'Default Title',
      authorId: 'default_author',
      ...overrides,
    },
  });
}
```

Usage in tests:

```ts
const db = makeInMemoryDb();
const post = await createPost(db, { authorId: 'current_user' });
```

---

### Asserting on Error Details

`TRPCError` instances thrown from procedures carry a `code`, `message`, and optionally `cause`. Test assertions can target any of these:

```ts
it('includes a descriptive message on conflict', async () => {
  const ctx = createTestContext();
  const caller = createCaller(ctx);

  await caller.user.register({ email: 'taken@example.com' });

  const error = await caller.user
    .register({ email: 'taken@example.com' })
    .catch((e) => e);

  expect(error.code).toBe('CONFLICT');
  expect(error.message).toMatch(/already registered/i);
});
```

**Key Points:**

- Catching the error and asserting on it directly is more expressive than `rejects.toMatchObject` when multiple properties need to be verified
- `toMatch(/pattern/i)` provides resilient message assertions that do not break on minor wording changes

---

### Visualizing the Test Isolation Model

FakestRPC ProcedureTestinvokereads / writessendscreateTestContextsession + fakeDb +mailerSpycreateCaller - ctxAssertionsInput ValidationZodMiddleware Chainauth / tenant / flagResolver FunctionIn-Memory DBMailer SpyNoop Logger

---

### Common Pitfalls

**Pitfall 1 — Sharing mutable fake state between tests:**
If a single `makeInMemoryDb()` instance is shared across tests in a `describe` block without reset, earlier tests contaminate later ones. Create a fresh fake per test or implement a `reset()` method.

```ts
// Per-test instantiation — preferred
beforeEach(() => {
  db = makeInMemoryDb();
  ctx = createTestContext({ db: db as any });
  caller = createCaller(ctx);
});
```

**Pitfall 2 — Asserting on HTTP status codes:**
The server-side caller does not go through HTTP. Error codes are tRPC codes (`UNAUTHORIZED`, `NOT_FOUND`) — not HTTP status codes (401, 404). Assert on `.code`, not `.status`.

**Pitfall 3 — Testing the wrong layer:**
Testing that Prisma correctly queries the database is an integration test concern, not a unit test concern. Unit tests for procedures should use fakes and trust that the real adapter works — verified separately in adapter-level tests.

**Pitfall 4 — Over-mocking:**
Replacing every dependency with a mock that asserts on call counts and argument shapes ties tests to implementation details. Prefer fakes that behave correctly (an in-memory map that actually stores and retrieves) over mocks that only verify interaction patterns.

**Pitfall 5 — Omitting the unhappy path:**
Input validation, authorization failures, and not-found cases are often more important to test than the happy path — they represent the boundaries of the procedure's contract. Every meaningful error branch should have at least one test.

---

**Conclusion**

Unit testing tRPC procedures in isolation requires three things: a server-side caller (`createCallerFactory`), a fabricated context (`createTestContext`), and interface-compatible fakes for each dependency. With these in place, procedures are tested as ordinary async functions — input validation, middleware, resolver logic, and error handling all execute in full, with no HTTP server, no real database, and no module mocking required. Middleware can be further isolated by attaching it to a minimal test router and calling it through a dedicated test caller.