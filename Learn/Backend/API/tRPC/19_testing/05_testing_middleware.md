## Testing Middleware

Middleware in tRPC sits between the procedure call and its resolver. Testing middleware thoroughly requires verifying that it correctly modifies context, enforces invariants, and short-circuits with appropriate errors — across both the unit and integration layers.

---

### What Middleware Does in tRPC

tRPC middleware is added via `.use()` on a procedure builder. Each middleware receives the current context, can modify it, and either calls `next()` to continue the chain or throws a `TRPCError` to halt it.

```ts
const t = initTRPC.create<{ ctx: { user: User | null } }>();

const authedProcedure = t.procedure.use(({ ctx, next }) => {
  if (!ctx.user) {
    throw new TRPCError({ code: 'UNAUTHORIZED' });
  }
  return next({ ctx: { ...ctx, user: ctx.user } }); // narrows type
});
```

---

### Testing Approaches

There are three primary approaches to testing middleware, each with different trade-offs:

| Approach | HTTP Layer | Realistic Context | Speed | Isolation |
| --- | --- | --- | --- | --- |
| Direct procedure call via `createCaller` | No | Partial | Fast | High |
| Attaching middleware to a test procedure | No | Full (mocked) | Fast | High |
| Integration test with real HTTP server | Yes | Full | Slower | Lower |

No single approach is sufficient on its own. [Inference: combining at least two approaches — unit-level for logic, integration-level for HTTP behavior — is the most thorough strategy.]

---

### Unit Testing Middleware Logic via `createCaller`

The simplest approach attaches the middleware under test to a minimal test procedure and calls it via `createCaller`. This avoids HTTP entirely but exercises the middleware's logic and context transformation.

```ts
// src/middleware/auth.test.ts
import { describe, expect, it } from 'vitest';
import { initTRPC, TRPCError } from '@trpc/server';

interface Context {
  user: { id: string; role: string } | null;
}

const t = initTRPC.context<Context>().create();

// The middleware under test
const requireAuth = t.middleware(({ ctx, next }) => {
  if (!ctx.user) {
    throw new TRPCError({ code: 'UNAUTHORIZED', message: 'Not authenticated' });
  }
  return next({ ctx: { ...ctx, user: ctx.user } });
});

// A minimal procedure that uses the middleware
const protectedProcedure = t.procedure.use(requireAuth);

const testRouter = t.router({
  secret: protectedProcedure.query(() => ({ value: 'sensitive' })),
});

describe('requireAuth middleware', () => {
  it('allows access when user is present', async () => {
    const caller = testRouter.createCaller({ user: { id: '1', role: 'admin' } });
    const result = await caller.secret();
    expect(result.value).toBe('sensitive');
  });

  it('throws UNAUTHORIZED when user is null', async () => {
    const caller = testRouter.createCaller({ user: null });
    await expect(caller.secret()).rejects.toMatchObject({
      code: 'UNAUTHORIZED',
    });
  });
});
```

**Key Points**

- The middleware is imported and attached in the test file itself — there is no dependency on any production router.
- `createCaller` passes context directly, bypassing HTTP. This is appropriate for testing middleware logic but not HTTP-level behavior.
- `rejects.toMatchObject` matches partial error shapes; tRPC errors expose `code` on the thrown object. [Inference: exact error shape on the thrown instance may vary; verify against your version.]

---

### Testing Context Augmentation

Middleware often enriches context — attaching a database client, a decoded user, or request metadata. Test that the augmented context is correctly passed to the procedure.

```ts
interface BaseContext {
  db: { findUser: (id: string) => Promise<{ id: string; name: string } | null> };
  userId: string | null;
}

interface EnrichedContext extends BaseContext {
  user: { id: string; name: string };
}

const t = initTRPC.context<BaseContext>().create();

const loadUser = t.middleware(async ({ ctx, next }) => {
  if (!ctx.userId) {
    throw new TRPCError({ code: 'UNAUTHORIZED' });
  }
  const user = await ctx.db.findUser(ctx.userId);
  if (!user) {
    throw new TRPCError({ code: 'NOT_FOUND', message: 'User not found' });
  }
  return next({ ctx: { ...ctx, user } });
});

const userProcedure = t.procedure.use(loadUser);

const testRouter = t.router({
  profile: (userProcedure as typeof t.procedure.use<typeof loadUser>)
    .query(({ ctx }) => ({ name: (ctx as unknown as EnrichedContext).user.name })),
});

describe('loadUser middleware', () => {
  const mockDb = {
    findUser: async (id: string) =>
      id === 'user-1' ? { id: 'user-1', name: 'Ada' } : null,
  };

  it('attaches user to context when userId is valid', async () => {
    const caller = testRouter.createCaller({ db: mockDb, userId: 'user-1' });
    const result = await caller.profile();
    expect(result.name).toBe('Ada');
  });

  it('throws NOT_FOUND when user does not exist in db', async () => {
    const caller = testRouter.createCaller({ db: mockDb, userId: 'ghost-99' });
    await expect(caller.profile()).rejects.toMatchObject({ code: 'NOT_FOUND' });
  });

  it('throws UNAUTHORIZED when userId is null', async () => {
    const caller = testRouter.createCaller({ db: mockDb, userId: null });
    await expect(caller.profile()).rejects.toMatchObject({ code: 'UNAUTHORIZED' });
  });
});
```

---

### Testing Middleware Chaining

When multiple middleware functions compose, test each in isolation first, then test the composed chain.

```ts
const requireAuth = t.middleware(({ ctx, next }) => {
  if (!ctx.user) throw new TRPCError({ code: 'UNAUTHORIZED' });
  return next();
});

const requireAdmin = t.middleware(({ ctx, next }) => {
  if (ctx.user?.role !== 'admin') throw new TRPCError({ code: 'FORBIDDEN' });
  return next();
});

const adminProcedure = t.procedure.use(requireAuth).use(requireAdmin);

const testRouter = t.router({
  adminOnly: adminProcedure.query(() => ({ ok: true })),
});

describe('chained auth + admin middleware', () => {
  it('allows admin users', async () => {
    const caller = testRouter.createCaller({ user: { id: '1', role: 'admin' } });
    await expect(caller.adminOnly()).resolves.toEqual({ ok: true });
  });

  it('blocks authenticated non-admin users with FORBIDDEN', async () => {
    const caller = testRouter.createCaller({ user: { id: '2', role: 'user' } });
    await expect(caller.adminOnly()).rejects.toMatchObject({ code: 'FORBIDDEN' });
  });

  it('blocks unauthenticated users with UNAUTHORIZED before reaching admin check', async () => {
    const caller = testRouter.createCaller({ user: null });
    await expect(caller.adminOnly()).rejects.toMatchObject({ code: 'UNAUTHORIZED' });
  });
});
```

**Key Points**

- The ordering of middleware matters. The test for `UNAUTHORIZED` verifies that `requireAuth` runs before `requireAdmin`, halting the chain early.
- Test each error code independently to confirm which middleware in the chain is responsible.

---

### Middleware Chaining Diagram

user is nulluser presentrole != adminrole = adminIncoming RequestrequireAuthThrow UNAUTHORIZEDrequireAdminThrow FORBIDDENProcedure ResolverResponse

---

### Testing Logging and Side-Effect Middleware

Some middleware performs side effects — logging, metrics, or tracing — without modifying context. Test that the side effect fires correctly by injecting a mock.

```ts
describe('logging middleware', () => {
  it('calls the logger with the procedure path', async () => {
    const mockLogger = { info: vi.fn() };

    const t = initTRPC.context<{ logger: typeof mockLogger }>().create();

    const loggingMiddleware = t.middleware(async ({ ctx, path, next }) => {
      ctx.logger.info(`Calling: ${path}`);
      return next();
    });

    const testRouter = t.router({
      ping: t.procedure.use(loggingMiddleware).query(() => 'pong'),
    });

    const caller = testRouter.createCaller({ logger: mockLogger });
    await caller.ping();

    expect(mockLogger.info).toHaveBeenCalledWith('Calling: ping');
  });
});
```

---

### Testing Timing and Performance Middleware

Middleware that measures duration wraps `next()` and reads timing before and after. Test that it records a non-negative duration without asserting on exact millisecond values, which are non-deterministic.

```ts
it('records a non-negative duration', async () => {
  const durations: number[] = [];

  const timingMiddleware = t.middleware(async ({ next }) => {
    const start = Date.now();
    const result = await next();
    durations.push(Date.now() - start);
    return result;
  });

  const testRouter = t.router({
    slow: t.procedure.use(timingMiddleware).query(async () => {
      await new Promise((r) => setTimeout(r, 10));
      return 'done';
    }),
  });

  const caller = testRouter.createCaller({});
  await caller.slow();

  expect(durations).toHaveLength(1);
  expect(durations[0]).toBeGreaterThanOrEqual(0);
});
```

---

### Integration Testing Middleware via HTTP

For middleware that reads from raw HTTP requests — such as extracting a JWT from `Authorization` headers or reading cookies — use an integration test with a real HTTP server.

```ts
// src/test/authMiddleware.integration.test.ts
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { createHTTPServer } from '@trpc/server/adapters/standalone';
import { initTRPC, TRPCError } from '@trpc/server';
import { IncomingMessage, ServerResponse } from 'http';

interface Context {
  user: { id: string } | null;
}

const t = initTRPC.context<Context>().create();

const requireAuth = t.middleware(({ ctx, next }) => {
  if (!ctx.user) throw new TRPCError({ code: 'UNAUTHORIZED' });
  return next();
});

const router = t.router({
  me: t.procedure.use(requireAuth).query(({ ctx }) => ctx.user),
});

function createContext({ req }: { req: IncomingMessage; res: ServerResponse }): Context {
  const token = req.headers['authorization'] ?? '';
  return {
    user: token === 'Bearer valid' ? { id: 'user-1' } : null,
  };
}

let baseUrl: string;
let close: () => void;

beforeAll(() => {
  const server = createHTTPServer({ router, createContext });
  const httpServer = server.listen(0);
  const port = (httpServer.address() as { port: number }).port;
  baseUrl = `http://127.0.0.1:${port}`;
  close = () => httpServer.close();
});

afterAll(() => close());

describe('requireAuth over HTTP', () => {
  it('returns 401 with no Authorization header', async () => {
    const res = await fetch(`${baseUrl}/me`);
    expect(res.status).toBe(401);
  });

  it('returns 200 with a valid token', async () => {
    const res = await fetch(`${baseUrl}/me`, {
      headers: { Authorization: 'Bearer valid' },
    });
    expect(res.status).toBe(200);
    const body = await res.json();
    expect(body.result.data.id).toBe('user-1');
  });
});
```

**Key Points**

- `createContext` here reads from the real `IncomingMessage` object, which is only available via HTTP. This path cannot be exercised by `createCaller`.
- The integration test complements the unit test: the unit test checks middleware logic; the integration test checks that the context factory correctly extracts credentials from the HTTP request.

---

### What Each Layer Covers

Integration Test (HTTP)Header/cookie extractionHTTP status codesError envelope shapeFull context factory pathUnit Test (createCaller)Middleware logicContext augmentationChain orderingSide effects / mocks

---

### Common Pitfalls

**Testing only the happy path** — Middleware is most valuable at the boundary. Always write tests for the rejection path (missing credentials, wrong role, malformed input).

**Asserting on exact error messages** — Error messages are easier to change than codes. Prefer asserting on `code` over `message` for stability.

**Mocking too much** — If your test mocks the middleware itself, you are not testing it. Only mock the middleware's dependencies (db, logger), not the middleware function.

**Assuming `createCaller` covers HTTP behavior** — Context factories that read `req.headers` or `req.cookies` require an integration test. `createCaller` accepts context directly and never calls `createContext`.

**Not testing chain order** — If middleware A must run before middleware B, add a test that verifies A's error is thrown when A's condition fails, even when B's condition would also fail.

---

### Summary

Testing tRPC middleware involves two complementary layers. Unit tests using `createCaller` with a minimal test router verify the middleware's logic, context augmentation, chain ordering, and side effects in isolation. Integration tests using a real HTTP server verify that the `createContext` factory correctly extracts information from HTTP requests and that middleware failures produce the expected HTTP status codes and error envelopes. Both layers are necessary for confidence in production middleware behavior.