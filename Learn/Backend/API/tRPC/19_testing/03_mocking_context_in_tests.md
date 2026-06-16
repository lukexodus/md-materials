## Mocking Context in Tests

---

### Overview

Context is the primary dependency surface in tRPC. Every procedure receives `ctx` as its execution environment — session state, database clients, service instances, feature flags, tenant data. Mocking context in tests means constructing a controlled substitute for that environment: one that is fast, deterministic, and inspectable without touching real infrastructure.

This topic covers the full range of context mocking strategies — from simple object literals to typed fake implementations — and addresses how to handle the specific context shapes produced by middleware narrowing.

---

### What Context Mocking Replaces

In production, context is created by `createContext`, which may:

- Resolve a session from a signed cookie or JWT
- Connect to or reuse a database connection pool
- Initialize an SDK client (email provider, feature flag service, analytics)
- Perform a tenant lookup against the database

None of this should run in a unit test. Context mocking replaces all of it with synchronous or trivially async substitutes that return controlled values.

---

### The Simplest Case: Inline Object Literal

For procedures with minimal context requirements, an inline object literal is sufficient:

```ts
import { createCallerFactory } from '@trpc/server';
import { greetingRouter } from '../../server/routers/greeting';

const createCaller = createCallerFactory(greetingRouter);

it('greets the user by name', async () => {
  const caller = createCaller({
    session: { user: { id: 'u1', name: 'Alice', role: 'member' } },
    db: null as any,    // procedure does not use db — safe to omit
  });

  const result = await caller.hello({ name: 'Alice' });
  expect(result).toBe('Hello, Alice!');
});
```

**Key Points:**

- Inline literals are appropriate when the procedure under test uses only a small, known subset of context
- `null as any` is a pragmatic escape hatch for context fields the procedure does not access — it is not safe if the procedure actually reaches for that field
- As context grows more complex, inline literals become verbose and fragile — a shared factory is preferable

---

### A Typed Context Factory

A shared `createTestContext` factory ensures every test starts from a valid, type-safe baseline and overrides only what it needs.

```ts
// tests/helpers/createTestContext.ts
import type { Context } from '../../server/context';

// --- Fake implementations ---

export const noopLogger = {
  info: (_msg: string, _meta?: unknown) => {},
  warn: (_msg: string, _meta?: unknown) => {},
  error: (_msg: string, _meta?: unknown) => {},
};

export function makeInMemoryDb() {
  const store: Record<string, Map<string, any>> = {
    user: new Map(),
    post: new Map(),
    comment: new Map(),
  };

  function table(name: string) {
    if (!store[name]) store[name] = new Map();
    return store[name];
  }

  function makeModel(modelName: string) {
    return {
      create: async ({ data }: any) => {
        const record = { id: `${modelName}_${Date.now()}`, ...data };
        table(modelName).set(record.id, record);
        return record;
      },
      findUnique: async ({ where }: any) => {
        const t = table(modelName);
        if (where.id) return t.get(where.id) ?? null;
        // Support single-field unique lookups
        const [field, value] = Object.entries(where)[0];
        return [...t.values()].find(r => r[field] === value) ?? null;
      },
      findMany: async ({ where }: any = {}) => {
        const all = [...table(modelName).values()];
        if (!where) return all;
        return all.filter(record =>
          Object.entries(where).every(([k, v]) => record[k] === v)
        );
      },
      update: async ({ where, data }: any) => {
        const existing = await makeModel(modelName).findUnique({ where });
        if (!existing) throw new Error(`${modelName} not found`);
        const updated = { ...existing, ...data };
        table(modelName).set(existing.id, updated);
        return updated;
      },
      delete: async ({ where }: any) => {
        const existing = await makeModel(modelName).findUnique({ where });
        if (existing) table(modelName).delete(existing.id);
      },
      count: async ({ where }: any = {}) => {
        const records = await makeModel(modelName).findMany({ where });
        return records.length;
      },
      upsert: async ({ where, create, update }: any) => {
        const existing = await makeModel(modelName).findUnique({ where });
        if (existing) {
          return makeModel(modelName).update({ where, data: update });
        }
        return makeModel(modelName).create({ data: create });
      },
    };
  }

  return {
    user: makeModel('user'),
    post: makeModel('post'),
    comment: makeModel('comment'),
  };
}

export function makeMailerSpy() {
  const calls: Array<{ method: string; args: unknown[] }> = [];

  const spy = (method: string) =>
    async (...args: unknown[]) => {
      calls.push({ method, args });
    };

  return {
    calls,
    reset: () => calls.splice(0),
    sentTo: (email: string) => calls.some(c => c.args.includes(email)),
    sentMethod: (method: string) => calls.filter(c => c.method === method),
    sendWelcome: spy('sendWelcome'),
    sendPasswordReset: spy('sendPasswordReset'),
    sendInvite: spy('sendInvite'),
  };
}

// --- Context factory ---

export function createTestContext(overrides: Partial<Context> = {}): Context {
  return {
    session: null,
    db: makeInMemoryDb() as any,
    mailer: makeMailerSpy(),
    logger: noopLogger,
    flags: {
      enableBetaApi: false,
      enableAiFeatures: false,
    },
    ...overrides,
  };
}
```

---

### Session Mocking

Session state is the most frequently varied context field across tests. Dedicated session builders reduce repetition.

```ts
// tests/helpers/sessions.ts
import type { Session } from '../../server/context';

type UserRole = 'member' | 'admin' | 'owner';

export function makeSession(overrides: {
  id?: string;
  email?: string;
  role?: UserRole;
  tenantId?: string;
} = {}): Session {
  return {
    user: {
      id: overrides.id ?? 'user_test',
      email: overrides.email ?? 'user@test.com',
      role: overrides.role ?? 'member',
      tenantId: overrides.tenantId ?? 'tenant_test',
    },
  };
}

export const memberSession = makeSession();
export const adminSession = makeSession({ id: 'admin_test', role: 'admin' });
export const ownerSession = makeSession({ id: 'owner_test', role: 'owner' });
```

**Usage:**

```ts
import { memberSession, adminSession } from '../helpers/sessions';

it('allows admin to delete a user', async () => {
  const caller = createCaller(createTestContext({ session: adminSession }));
  // ...
});

it('rejects member from deleting a user', async () => {
  const caller = createCaller(createTestContext({ session: memberSession }));
  // ...
});
```

---

### Mocking Middleware-Narrowed Context

Middleware often narrows context — changing a nullable `session` to a non-nullable `session`, adding a `membership` field, or replacing `db` with a tenant-scoped variant. When testing procedures that depend on this narrowed context, the mock must reflect the post-middleware shape.

Consider a procedure using `tenantProcedure`, which narrows context to include:

```ts
// After tenantGuard middleware, ctx is narrowed to:
interface TenantContext extends Context {
  session: NonNullable<Context['session']>;   // non-nullable
  tenant: Tenant;                             // non-nullable
  membership: TenantMembership;              // added by middleware
}
```

The test context must satisfy this narrowed shape:

```ts
export function createTenantTestContext(
  overrides: Partial<TenantContext> = {}
): TenantContext {
  return {
    ...createTestContext(),
    session: makeSession(),                   // non-nullable
    tenant: {
      id: 'tenant_test',
      slug: 'test-org',
      name: 'Test Organisation',
    },
    membership: {
      userId: 'user_test',
      tenantId: 'tenant_test',
      role: 'member',
    },
    ...overrides,
  };
}
```

**Key Points:**

- When the caller runs a procedure that uses `tenantProcedure`, the middleware itself will execute and may re-validate tenancy. If your middleware re-queries the database, the test context's `db` fake must include the relevant membership record
- Alternatively, test only the resolver logic by bypassing the full middleware chain using a sub-router with a lighter base procedure — a valid trade-off when the middleware is tested separately [Inference]

---

### Mocking at Different Granularities

Context mocking can operate at different levels of fidelity depending on what the test needs to verify.

#### Full Fake (default)

The in-memory db, mailer spy, and noop logger cover the full context. Appropriate for most tests.

```ts
const ctx = createTestContext();
```

#### Partial Override

Override only the fields relevant to the test case. The factory provides safe defaults for everything else.

```ts
const ctx = createTestContext({
  session: adminSession,
  flags: { enableAiFeatures: true, enableBetaApi: false },
});
```

#### Targeted Spy

When a test needs to assert on specific method calls, replace only the relevant fake with a more capable spy:

```ts
const mailer = makeMailerSpy();
const ctx = createTestContext({ mailer });

await caller.auth.register({ email: 'test@example.com' });

expect(mailer.sentMethod('sendWelcome')).toHaveLength(1);
expect(mailer.calls[0].args[0]).toBe('test@example.com');
```

#### Controlled Failure

To test error handling when a dependency fails, replace a fake method with one that throws:

```ts
const db = makeInMemoryDb();
db.user.create = async () => {
  throw new Error('Database connection lost.');
};

const ctx = createTestContext({ db: db as any });
const caller = createCaller(ctx);

await expect(
  caller.user.register({ email: 'a@b.com' })
).rejects.toMatchObject({ code: 'INTERNAL_SERVER_ERROR' });
```

---

### Mocking Feature Flags

Feature flags in context control procedure behavior. Tests should explicitly set flag values rather than relying on defaults:

```ts
it('includes AI summary when flag is enabled', async () => {
  const ctx = createTestContext({
    session: memberSession,
    flags: { enableAiFeatures: true, enableBetaApi: false },
  });
  const caller = createCaller(ctx);

  const result = await caller.post.get({ id: 'p1' });
  expect(result.summary).toBeDefined();
});

it('omits AI summary when flag is disabled', async () => {
  const ctx = createTestContext({
    flags: { enableAiFeatures: false, enableBetaApi: false },
  });
  const caller = createCaller(ctx);

  const result = await caller.post.get({ id: 'p1' });
  expect(result.summary).toBeNull();
});
```

---

### Mocking Services (Service Layer Pattern)

When context carries service instances rather than raw clients, mock the service interface:

```ts
// Context shape with service layer
export interface Context {
  session: Session | null;
  services: {
    user: IUserService;
    billing: IBillingService;
  };
}
```

```ts
// tests/helpers/createTestContext.ts
export function makeUserServiceFake(): IUserService & { registered: string[] } {
  const registered: string[] = [];

  return {
    registered,
    register: async ({ email }) => {
      registered.push(email);
      return { userId: `u_${Date.now()}`, email };
    },
    deactivate: async () => {},
    findById: async (id) => null,
  };
}

export function createTestContext(overrides: Partial<Context> = {}): Context {
  return {
    session: null,
    services: {
      user: makeUserServiceFake(),
      billing: makeBillingServiceFake(),
    },
    ...overrides,
  };
}
```

**Usage:**

```ts
it('delegates registration to the user service', async () => {
  const userService = makeUserServiceFake();
  const ctx = createTestContext({
    services: { user: userService, billing: makeBillingServiceFake() },
  });
  const caller = createCaller(ctx);

  await caller.user.register({ email: 'delegate@test.com' });

  expect(userService.registered).toContain('delegate@test.com');
});
```

---

### Avoiding Common Mocking Mistakes

#### Mistake 1 — Mutating a shared context object

```ts
// ❌ Shared mutable fake — tests interfere with each other
const sharedCtx = createTestContext();

it('test A', async () => {
  await sharedCtx.db.user.create({ data: { email: 'a@test.com' } });
  // ...
});

it('test B', async () => {
  const users = await sharedCtx.db.user.findMany();
  // users now contains the record created in test A
});
```

```ts
// ✅ Fresh context per test
let ctx: Context;

beforeEach(() => {
  ctx = createTestContext();
});
```

#### Mistake 2 — Typing context as `any` throughout

```ts
// ❌ Loses all type safety — silent mismatches
const ctx: any = { session: { user: { id: 'u1' } } };
```

```ts
// ✅ Type-safe — TypeScript catches missing or mistyped fields
const ctx: Context = createTestContext({ session: makeSession() });
```

#### Mistake 3 — Over-specifying irrelevant context fields

```ts
// ❌ Test is brittle — changing context shape breaks unrelated tests
const ctx = createTestContext({
  session: makeSession(),
  tenant: { id: 't1', slug: 'acme', name: 'Acme', createdAt: new Date(), plan: 'pro' },
  membership: { userId: 'u1', tenantId: 't1', role: 'member', joinedAt: new Date() },
  flags: { enableBetaApi: false, enableAiFeatures: false },
  mailer: makeMailerSpy(),
  logger: noopLogger,
  // ... more fields the test does not use
});
```

Provide only the fields the procedure under test actually accesses. The factory supplies safe defaults for everything else.

#### Mistake 4 — Not resetting spy state between tests

```ts
// ❌ Call records from test A bleed into test B
const mailer = makeMailerSpy();

it('test A', async () => {
  const ctx = createTestContext({ mailer });
  // mailer.calls gets populated
});

it('test B', async () => {
  const ctx = createTestContext({ mailer });  // same spy instance
  // mailer.calls still contains records from test A
});
```

```ts
// ✅ Reset or recreate per test
beforeEach(() => {
  mailer = makeMailerSpy();  // fresh spy each time
});
```

---

### Visualizing Context Substitution

TestsProductionsame Context typesame IDatabase interfacesame IMailer interfacesame FeatureFlags typecreateContext - reqJWT / CookieSessionPrismaClientconnection poolSMTP ClientRemote Flag SDKcreateTestContext -overridesmakeSessionplain objectmakeInMemoryDbMap-backedmakeMailerSpyrecords callsStatic flag objectcreateCaller - ctxProcedure executeswith fake context

---

### Context Mocking Across Test Types

Different test types require different mocking depths:

| Test type | Context source | DB | External services |
| --- | --- | --- | --- |
| Unit (procedure) | `createTestContext` | In-memory fake | Spy / noop |
| Unit (middleware) | Inline object | Not needed | Not needed |
| Integration | `createTestContext` with real DB | Test database | Spy or sandbox |
| End-to-end | `createContext` (real) | Real database | Real or sandbox |

For integration tests that use a real test database, context mocking still applies to everything except `db` — sessions, mailers, flags, and loggers remain faked:

```ts
// Integration test — real DB, fake everything else
const ctx = createTestContext({
  db: realTestDb,      // actual Prisma client pointing at test DB
  session: makeSession(),
});
```

---

**Conclusion**

Mocking context in tRPC tests is the act of substituting the production dependency graph — sessions, databases, external services — with fast, controlled, inspectable fakes. A typed `createTestContext` factory anchored to the real `Context` type is the central tool: it provides safe defaults, accepts targeted overrides, and maintains type safety throughout. Session builders, in-memory database fakes, and mailer spies cover the majority of context needs. Middleware-narrowed context shapes require special attention — test context must match what the procedure actually receives, not just the base context shape.