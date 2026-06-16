## Test Utilities and Helpers

As a tRPC test suite grows, repeated setup code — creating routers, building callers, starting servers, mocking context — accumulates across files. Extracting this into shared utilities keeps tests concise, consistent, and easier to maintain.

---

### Why Build Test Utilities

Without shared utilities, each test file independently repeats:

- `initTRPC.create()` and router construction
- `createCaller` setup with mocked context
- HTTP server startup and teardown
- WebSocket server configuration
- Context factory construction

This leads to inconsistency, copy-paste drift, and high maintenance cost when tRPC APIs or project conventions change. Centralizing these into a `test/` utilities directory means a single update propagates everywhere.

---

### Recommended Directory Structure

```
src/
  server/
    router.ts
    context.ts
  test/
    helpers/
      createTestCaller.ts
      createTestServer.ts
      createTestContext.ts
      createTestRouter.ts
      mockContext.ts
    fixtures/
      users.ts
      posts.ts
    setup.ts
```

---

### `createTestContext` — Building a Reusable Mock Context

The context factory is the most commonly varied element across tests. Centralizing it with sensible defaults and override support reduces boilerplate.

```ts
// src/test/helpers/createTestContext.ts
import { vi } from 'vitest';

export interface MockDb {
  user: {
    findUnique: ReturnType<typeof vi.fn>;
    create: ReturnType<typeof vi.fn>;
    delete: ReturnType<typeof vi.fn>;
  };
}

export interface TestContext {
  user: { id: string; role: string } | null;
  db: MockDb;
  logger: { info: ReturnType<typeof vi.fn>; error: ReturnType<typeof vi.fn> };
}

export function createMockDb(): MockDb {
  return {
    user: {
      findUnique: vi.fn(),
      create: vi.fn(),
      delete: vi.fn(),
    },
  };
}

export function createTestContext(overrides: Partial<TestContext> = {}): TestContext {
  return {
    user: null,
    db: createMockDb(),
    logger: {
      info: vi.fn(),
      error: vi.fn(),
    },
    ...overrides,
  };
}
```

**Usage in tests:**

```ts
import { createTestContext } from '../helpers/createTestContext';

const ctx = createTestContext({ user: { id: 'u1', role: 'admin' } });
const caller = appRouter.createCaller(ctx);
```

**Key Points**

- `overrides` uses `Partial<TestContext>` so callers only specify what differs from the default.
- Each mock function is a fresh `vi.fn()` per call, preventing state leakage between tests.
- The `MockDb` mirrors your real database client's interface so procedures under test behave identically to production, modulo actual I/O.

---

### `createTestCaller` — A Typed Caller Factory

Wrapping `createCaller` in a helper makes it ergonomic to call procedures with varying context without repeating router imports.

```ts
// src/test/helpers/createTestCaller.ts
import { appRouter } from '../../server/router';
import { createTestContext, TestContext } from './createTestContext';

export function createTestCaller(overrides: Partial<TestContext> = {}) {
  const ctx = createTestContext(overrides);
  const caller = appRouter.createCaller(ctx);
  return { caller, ctx };
}
```

**Usage:**

```ts
import { createTestCaller } from '../helpers/createTestCaller';

it('returns the user profile', async () => {
  const { caller, ctx } = createTestCaller({
    user: { id: 'u1', role: 'user' },
  });

  ctx.db.user.findUnique.mockResolvedValue({ id: 'u1', name: 'Ada' });

  const result = await caller.user.getProfile({ id: 'u1' });
  expect(result.name).toBe('Ada');
});
```

**Key Points**

- Returning both `caller` and `ctx` lets tests both call procedures and inspect mock call arguments on `ctx.db`.
- The helper is the single place to update if `appRouter` or `TestContext` changes.

---

### `createTestRouter` — Isolated Routers for Middleware Tests

When testing middleware in isolation, avoid importing the production router. Instead, build a minimal router on demand.

```ts
// src/test/helpers/createTestRouter.ts
import { initTRPC } from '@trpc/server';
import { TestContext } from './createTestContext';

export function createTestRouter<TContext extends object = TestContext>() {
  const t = initTRPC.context<TContext>().create();
  return { t, router: t.router, procedure: t.procedure, middleware: t.middleware };
}
```

**Usage:**

```ts
import { createTestRouter } from '../helpers/createTestRouter';
import { createTestContext } from '../helpers/createTestContext';

it('middleware attaches a userId to context', async () => {
  const { t } = createTestRouter();

  const withUserId = t.middleware(({ ctx, next }) => {
    return next({ ctx: { ...ctx, userId: (ctx as any).user?.id ?? null } });
  });

  const testProcedure = t.procedure.use(withUserId);
  const router = t.router({
    check: testProcedure.query(({ ctx }) => (ctx as any).userId),
  });

  const caller = router.createCaller(
    createTestContext({ user: { id: 'u1', role: 'user' } })
  );

  const result = await caller.check();
  expect(result).toBe('u1');
});
```

---

### `createTestServer` — Reusable HTTP Server Factory

Centralizing HTTP server setup ensures consistent adapter configuration and avoids port conflicts.

```ts
// src/test/helpers/createTestServer.ts
import { createHTTPServer } from '@trpc/server/adapters/standalone';
import { AnyRouter } from '@trpc/server';
import { IncomingMessage, ServerResponse, Server } from 'http';

interface TestServerOptions<TRouter extends AnyRouter> {
  router: TRouter;
  createContext?: (opts: {
    req: IncomingMessage;
    res: ServerResponse;
  }) => object;
}

interface TestServer {
  baseUrl: string;
  close: () => void;
}

export function createTestServer<TRouter extends AnyRouter>(
  options: TestServerOptions<TRouter>
): TestServer {
  const server = createHTTPServer({
    router: options.router,
    createContext: options.createContext ?? (() => ({})),
  });

  const httpServer: Server = server.listen(0);
  const port = (httpServer.address() as { port: number }).port;

  return {
    baseUrl: `http://127.0.0.1:${port}`,
    close: () => httpServer.close(),
  };
}
```

**Usage across test files:**

```ts
import { createTestServer } from '../helpers/createTestServer';
import { appRouter } from '../../server/router';

let baseUrl: string;
let close: () => void;

beforeAll(() => {
  const server = createTestServer({ router: appRouter });
  baseUrl = server.baseUrl;
  close = server.close;
});

afterAll(() => close());
```

---

### Vitest Global Setup — Shared Across All Tests

Use Vitest's `globalSetup` for one-time operations that should run once before the entire test suite — such as starting a shared database container or compiling assets.

```ts
// src/test/setup.ts (referenced in vitest.config.ts)
import { beforeEach, vi } from 'vitest';

beforeEach(() => {
  vi.clearAllMocks();
});
```

```ts
// vitest.config.ts
import { defineConfig } from 'vitest/config';

export default defineConfig({
  test: {
    setupFiles: ['./src/test/setup.ts'],
    globals: true,
  },
});
```

**Key Points**

- `vi.clearAllMocks()` in `beforeEach` resets mock call counts and return values between tests without recreating the mock functions.
- `setupFiles` runs once per worker file, not once globally. For truly global one-time setup, use `globalSetup` instead.

---

### Fixtures — Reusable Test Data

Centralizing fixture data prevents magic values from scattering across test files.

```ts
// src/test/fixtures/users.ts
export const fixtures = {
  adminUser: { id: 'user-admin', role: 'admin', name: 'Admin User', email: 'admin@example.com' },
  regularUser: { id: 'user-basic', role: 'user', name: 'Basic User', email: 'basic@example.com' },
  deletedUser: { id: 'user-deleted', role: 'user', name: 'Deleted', email: 'deleted@example.com', deletedAt: new Date() },
} as const;
```

**Usage:**

```ts
import { fixtures } from '../fixtures/users';

ctx.db.user.findUnique.mockResolvedValue(fixtures.adminUser);
```

**Key Points**

- `as const` preserves literal types so TypeScript can narrow fixture values precisely.
- Fixtures should be plain data objects, not class instances, to remain serializable and composable.
- Keep fixture values realistic but clearly synthetic (e.g., `example.com` emails, non-sequential IDs).

---

### `expectTRPCError` — Custom Assertion Helper

Asserting on tRPC errors repeatedly involves the same `rejects.toMatchObject` pattern. A helper makes this more readable.

```ts
// src/test/helpers/expectTRPCError.ts
import { expect } from 'vitest';
import { TRPCError } from '@trpc/server';

export async function expectTRPCError(
  promise: Promise<unknown>,
  code: TRPCError['code'],
  messageFragment?: string
): Promise<void> {
  await expect(promise).rejects.toMatchObject(
    messageFragment
      ? { code, message: expect.stringContaining(messageFragment) }
      : { code }
  );
}
```

**Usage:**

```ts
import { expectTRPCError } from '../helpers/expectTRPCError';

it('throws UNAUTHORIZED for unauthenticated access', async () => {
  const { caller } = createTestCaller({ user: null });
  await expectTRPCError(caller.user.getProfile({ id: 'u1' }), 'UNAUTHORIZED');
});

it('throws NOT_FOUND with a descriptive message', async () => {
  const { caller, ctx } = createTestCaller({ user: fixtures.adminUser });
  ctx.db.user.findUnique.mockResolvedValue(null);
  await expectTRPCError(caller.user.getProfile({ id: 'ghost' }), 'NOT_FOUND', 'not found');
});
```

---

### `withMockContext` — Fluent Context Builder

For tests that need multiple context variants, a fluent builder reduces verbosity.

```ts
// src/test/helpers/withMockContext.ts
import { createTestContext, TestContext } from './createTestContext';
import { appRouter } from '../../server/router';
import { fixtures } from '../fixtures/users';

export class MockContextBuilder {
  private overrides: Partial<TestContext> = {};

  asAdmin() {
    this.overrides.user = { ...fixtures.adminUser };
    return this;
  }

  asUser() {
    this.overrides.user = { ...fixtures.regularUser };
    return this;
  }

  asGuest() {
    this.overrides.user = null;
    return this;
  }

  withDb(db: Partial<TestContext['db']>) {
    this.overrides.db = { ...createTestContext().db, ...db };
    return this;
  }

  build() {
    const ctx = createTestContext(this.overrides);
    return { ctx, caller: appRouter.createCaller(ctx) };
  }
}

export function mockContext() {
  return new MockContextBuilder();
}
```

**Usage:**

```ts
import { mockContext } from '../helpers/withMockContext';

it('admin can delete a user', async () => {
  const { caller, ctx } = mockContext().asAdmin().build();
  ctx.db.user.delete.mockResolvedValue({ id: 'u1' });

  const result = await caller.user.delete({ id: 'u1' });
  expect(result.id).toBe('u1');
});

it('guest cannot delete a user', async () => {
  const { caller } = mockContext().asGuest().build();
  await expectTRPCError(caller.user.delete({ id: 'u1' }), 'UNAUTHORIZED');
});
```

---

### Composing Utilities: Full Test Example

```ts
// src/test/user.test.ts
import { describe, it, beforeEach, vi } from 'vitest';
import { mockContext } from './helpers/withMockContext';
import { expectTRPCError } from './helpers/expectTRPCError';
import { fixtures } from './fixtures/users';

describe('user.getProfile', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it('returns profile for authenticated user', async () => {
    const { caller, ctx } = mockContext().asUser().build();
    ctx.db.user.findUnique.mockResolvedValue(fixtures.regularUser);

    const result = await caller.user.getProfile({ id: fixtures.regularUser.id });
    expect(result.name).toBe(fixtures.regularUser.name);
    expect(ctx.db.user.findUnique).toHaveBeenCalledWith({
      where: { id: fixtures.regularUser.id },
    });
  });

  it('throws UNAUTHORIZED for guest', async () => {
    const { caller } = mockContext().asGuest().build();
    await expectTRPCError(caller.user.getProfile({ id: 'u1' }), 'UNAUTHORIZED');
  });

  it('throws NOT_FOUND when user does not exist', async () => {
    const { caller, ctx } = mockContext().asUser().build();
    ctx.db.user.findUnique.mockResolvedValue(null);
    await expectTRPCError(
      caller.user.getProfile({ id: 'ghost' }),
      'NOT_FOUND',
      'not found'
    );
  });
});
```

---

### Utility Dependency Map

fixtures/users.tsmockContext /withMockContextcreateTestContext.tscreateTestCaller.tscreateTestRouter.tsMiddleware testscreateTestServer.tsIntegration testsUnit testsexpectTRPCError.ts

---

### When to Extract a Utility

Not every repeated line warrants a helper. Extract when:

- The same setup appears in **three or more test files**
- The setup is **non-trivial** (more than two or three lines)
- The setup is **likely to change** (e.g., context shape, adapter version)
- The duplication **obscures test intent** rather than aiding readability

Do not extract when a single test has unique setup that would not generalize — inline clarity is preferable to premature abstraction.

---

### Common Pitfalls

**Shared mutable state in utilities** — If a utility returns a singleton mock (e.g., a shared `vi.fn()` instance), call history leaks between tests. Always create fresh mock instances per call.

**Over-abstracting too early** — Building an elaborate helper system before the test suite stabilizes couples maintenance to the helper, not the tests. Start inline; extract when patterns are clear.

**Helpers that hide test intent** — A helper should reduce noise, not bury the signal. If reading a test requires mentally expanding two layers of helpers to understand what is being tested, the abstraction is too deep.

**Not typing helpers precisely** — Loose types (e.g., `context: any`) in helpers defeat TypeScript's ability to catch mismatches between test context and production context shape.

**Forgetting to clear mocks** — Without `vi.clearAllMocks()` in `beforeEach` (or the equivalent in Jest), mock call counts accumulate across tests in the same file, producing false positives or negatives on `toHaveBeenCalledWith` assertions.

---

### Summary

A well-organized set of test utilities — context factories, caller builders, server helpers, fixtures, and custom assertions — dramatically reduces the cost of writing and maintaining tRPC tests. The key principle is that utilities should reduce noise without hiding intent: each test should remain readable on its own, with helpers handling only the repetitive scaffolding. Extract incrementally as patterns emerge, type everything precisely, and ensure every utility produces fresh state per invocation to prevent test pollution.