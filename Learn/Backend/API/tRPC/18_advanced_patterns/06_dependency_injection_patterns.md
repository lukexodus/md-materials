## Dependency Injection Patterns

---

### Overview

Dependency injection (DI) is the practice of supplying a component's dependencies from the outside rather than having the component construct them internally. In tRPC, this means procedures and routers receive their dependencies — database clients, external service clients, loggers, caches, email providers — through context or factory parameters rather than importing them directly.

tRPC has no DI container or framework. Dependency injection is achieved through deliberate use of context, procedure factories, and router factories. This is not a limitation — the patterns available are lightweight and type-safe by default.

---

### Why DI Matters in tRPC

Direct imports create tight coupling between procedures and their dependencies:

```ts
// ❌ Tightly coupled — hard to test, hard to substitute
import { db } from '../db';
import { mailer } from '../mailer';

export const userRouter = router({
  register: publicProcedure
    .input(z.object({ email: z.string() }))
    .mutation(async ({ input }) => {
      const user = await db.user.create({ data: { email: input.email } });
      await mailer.sendWelcome(user.email);
      return user;
    }),
});
```

Problems with this approach:

- Tests must mock module imports, which couples tests to implementation details
- Substituting a dependency (e.g., swapping the mailer in staging) requires conditional logic inside the module
- The procedure's dependencies are implicit — not visible in its signature

DI makes dependencies explicit, injectable, and substitutable.

---

### Pattern 1: Context as the Dependency Container

The most idiomatic tRPC DI pattern uses context as the container. Dependencies are instantiated or injected during context creation and made available to all procedures via `ctx`.

```ts
// server/context.ts
import { inferAsyncReturnType } from '@trpc/server';
import type { CreateNextContextOptions } from '@trpc/server/adapters/next';
import { PrismaClient } from '@prisma/client';
import { Mailer } from './services/mailer';
import { Logger } from './services/logger';
import { Cache } from './services/cache';
import { getSession } from './auth';

// Dependencies instantiated once at module level (singletons)
const db = new PrismaClient();
const mailer = new Mailer(process.env.SMTP_URL!);
const logger = new Logger({ level: 'info' });
const cache = new Cache(process.env.REDIS_URL!);

export async function createContext({ req }: CreateNextContextOptions) {
  const session = await getSession(req);

  return {
    session,
    db,
    mailer,
    logger,
    cache,
  };
}

export type Context = inferAsyncReturnType<typeof createContext>;
```

**Procedures access dependencies through `ctx`:**

```ts
// server/routers/user.ts
export const userRouter = router({
  register: publicProcedure
    .input(z.object({ email: z.string().email() }))
    .mutation(async ({ input, ctx }) => {
      const user = await ctx.db.user.create({
        data: { email: input.email },
      });

      await ctx.mailer.sendWelcome(user.email);
      ctx.logger.info('User registered', { userId: user.id });

      return user;
    }),
});
```

**Key Points:**

- Dependencies are explicit in the procedure's context type — visible and auditable
- Singleton instantiation at module level is appropriate for stateless, connection-pooled clients (database, cache)
- Per-request instantiation (inside `createContext`) is appropriate for dependencies that carry request-scoped state (e.g., a logger pre-configured with a request ID)
- This pattern requires no DI framework and is fully type-safe — `ctx.mailer` is typed as `Mailer`

---

### Pattern 2: Interface-Based Context

For testability, dependencies in context should be typed as interfaces rather than concrete classes. This allows tests to substitute lightweight fakes without mocking module imports.

**Define interfaces for each dependency:**

```ts
// server/interfaces/index.ts
export interface IDatabase {
  user: {
    create: (args: { data: { email: string } }) => Promise<{ id: string; email: string }>;
    findUnique: (args: { where: { id: string } }) => Promise<{ id: string; email: string } | null>;
  };
  // ... other models
}

export interface IMailer {
  sendWelcome: (email: string) => Promise<void>;
  sendPasswordReset: (email: string, token: string) => Promise<void>;
}

export interface ILogger {
  info: (message: string, meta?: Record<string, unknown>) => void;
  error: (message: string, meta?: Record<string, unknown>) => void;
  warn: (message: string, meta?: Record<string, unknown>) => void;
}

export interface ICache {
  get: <T>(key: string) => Promise<T | null>;
  set: <T>(key: string, value: T, ttlSeconds?: number) => Promise<void>;
  del: (key: string) => Promise<void>;
}
```

**Type context using interfaces:**

```ts
// server/context.ts
import type { IDatabase, IMailer, ILogger, ICache } from './interfaces';

export interface Context {
  session: Session | null;
  db: IDatabase;
  mailer: IMailer;
  logger: ILogger;
  cache: ICache;
}
```

**Production context uses concrete implementations:**

```ts
export async function createContext({ req }: CreateNextContextOptions): Promise<Context> {
  return {
    session: await getSession(req),
    db: prismaClient,          // satisfies IDatabase
    mailer: smtpMailer,        // satisfies IMailer
    logger: winstonLogger,     // satisfies ILogger
    cache: redisCache,         // satisfies ICache
  };
}
```

**Test context uses fakes:**

```ts
// tests/helpers/createTestContext.ts
import type { Context } from '../../server/context';

export function createTestContext(overrides: Partial<Context> = {}): Context {
  return {
    session: null,
    db: fakeDb,          // in-memory implementation
    mailer: fakeMailer,  // records sent emails for assertions
    logger: noopLogger,  // silent in tests
    cache: fakeCache,    // in-memory map
    ...overrides,
  };
}
```

**Key Points:**

- Procedures never know whether they are running against a real or fake implementation
- Tests can override only the dependencies they care about — `createTestContext({ session: adminSession })` — and rely on safe defaults for the rest
- TypeScript enforces that fakes satisfy the interface, catching mismatches at compile time

---

### Pattern 3: Router Factory with Injected Dependencies

When a router's dependencies should be configurable at construction time — particularly for library authors or shared modules — a factory function accepting dependencies directly is cleaner than relying on context alone.

```ts
// server/routers/factories/createNotificationRouter.ts
import { z } from 'zod';
import { router, protectedProcedure } from '../trpc';
import type { IMailer, ILogger } from '../interfaces';

interface NotificationRouterDeps {
  mailer: IMailer;
  logger: ILogger;
}

export function createNotificationRouter({ mailer, logger }: NotificationRouterDeps) {
  return router({
    sendInvite: protectedProcedure
      .input(z.object({ email: z.string().email(), role: z.string() }))
      .mutation(async ({ input, ctx }) => {
        await mailer.sendInvite(input.email, {
          invitedBy: ctx.session.user.email,
          role: input.role,
        });

        logger.info('Invite sent', {
          to: input.email,
          by: ctx.session.user.id,
        });

        return { sent: true };
      }),
  });
}
```

**Usage — inject different implementations per environment:**

```ts
// server/routers/index.ts
import { createNotificationRouter } from './factories/createNotificationRouter';
import { smtpMailer, sesMailer } from '../services/mailer';
import { logger } from '../services/logger';

const notificationRouter = createNotificationRouter({
  mailer: process.env.NODE_ENV === 'production' ? sesMailer : smtpMailer,
  logger,
});
```

**Key Points:**

- Dependencies are explicit in the factory's parameter type — the factory cannot be called without them
- Environment-specific substitution happens at construction time, not inside the procedure
- This pattern composes with context-based DI: the factory-injected `mailer` and `logger` here are module-level singletons, while request-scoped data (session, tenant) still comes from `ctx`

---

### Pattern 4: Service Layer Injection

For complex business logic, procedures often delegate to a service layer. DI applies here too — services receive their dependencies at construction time and are injected into context or router factories.

**Define a service with injected dependencies:**

```ts
// server/services/UserService.ts
import type { IDatabase, IMailer, ILogger } from '../interfaces';

export class UserService {
  constructor(
    private db: IDatabase,
    private mailer: IMailer,
    private logger: ILogger
  ) {}

  async register(email: string) {
    const existing = await this.db.user.findUnique({ where: { email } });

    if (existing) {
      throw new Error('Email already registered.');
    }

    const user = await this.db.user.create({ data: { email } });
    await this.mailer.sendWelcome(user.email);
    this.logger.info('User registered', { userId: user.id });

    return user;
  }

  async deactivate(userId: string) {
    const user = await this.db.user.findUnique({ where: { id: userId } });

    if (!user) {
      throw new Error('User not found.');
    }

    await this.db.user.update({ where: { id: userId }, data: { active: false } });
    this.logger.info('User deactivated', { userId });
  }
}
```

**Inject the service through context:**

```ts
// server/context.ts
import { UserService } from './services/UserService';

const userService = new UserService(prismaClient, smtpMailer, winstonLogger);

export async function createContext({ req }: CreateNextContextOptions) {
  return {
    session: await getSession(req),
    services: {
      user: userService,
    },
  };
}
```

**Procedure delegates to the service:**

```ts
export const userRouter = router({
  register: publicProcedure
    .input(z.object({ email: z.string().email() }))
    .mutation(async ({ input, ctx }) => {
      return ctx.services.user.register(input.email);
    }),

  deactivate: adminProcedure
    .input(z.object({ userId: z.string() }))
    .mutation(async ({ input, ctx }) => {
      return ctx.services.user.deactivate(input.userId);
    }),
});
```

**Key Points:**

- Procedures become thin — they validate input, call services, and return results
- Business logic is isolated in service classes that are independently testable without tRPC
- Services can be tested by constructing them with fake dependencies directly, without the tRPC request lifecycle [Inference: this is a standard benefit of constructor injection; actual testability depends on how stateful the service is]

---

### Pattern 5: Lazy Initialization

Some dependencies are expensive to initialize — database connections, third-party SDK clients with handshake overhead. Lazy initialization defers construction until first use.

```ts
// server/services/lazy.ts
export function lazy<T>(factory: () => T): { instance: T } {
  let value: T | undefined;

  return {
    get instance() {
      if (!value) {
        value = factory();
      }
      return value;
    },
  };
}
```

```ts
// server/context.ts
import { lazy } from './services/lazy';
import { HeavyAnalyticsClient } from './services/analytics';

const analyticsClient = lazy(() => new HeavyAnalyticsClient(process.env.ANALYTICS_KEY!));

export async function createContext({ req }: CreateNextContextOptions) {
  return {
    session: await getSession(req),
    db: prismaClient,
    get analytics() {
      return analyticsClient.instance; // initialized on first access
    },
  };
}
```

**Key Points:**

- The analytics client is not constructed until the first procedure that accesses `ctx.analytics` runs
- Subsequent accesses return the same instance
- [Inference: lazy initialization is not thread-safe in shared-memory environments; in typical Node.js single-threaded execution this is generally not a concern, but verify for your runtime]

---

### Visualizing Dependency Flow

satisfied bysatisfied byEnvironment / ConfigConcrete ImplementationsPrismaClient,SMTPMailer, RediscreateContextctx.servicesUserService,BillingServicectx.db / ctx.mailer /ctx.loggerregister.mutationdeactivate.mutationpost.create.mutationtag.list.queryInterfacesIDatabase, IMailer,ILoggerTest FakesfakeDb, fakeMailercreateTestContextUnit / Integration Tests

---

### Testing with Injected Dependencies

The primary payoff of DI is testability. With interface-typed context, procedures can be tested by calling the underlying router with a fabricated context.

```ts
// tests/routers/user.test.ts
import { createCallerFactory } from '@trpc/server';
import { appRouter } from '../../server/routers';
import { createTestContext } from '../helpers/createTestContext';

const createCaller = createCallerFactory(appRouter);

describe('user.register', () => {
  it('creates a user and sends a welcome email', async () => {
    const sentEmails: string[] = [];

    const ctx = createTestContext({
      db: {
        user: {
          create: async ({ data }) => ({ id: 'user_1', email: data.email }),
          findUnique: async () => null,
        },
      },
      mailer: {
        sendWelcome: async (email) => { sentEmails.push(email); },
        sendPasswordReset: async () => {},
      },
    });

    const caller = createCaller(ctx);
    const result = await caller.user.register({ email: 'test@example.com' });

    expect(result.id).toBe('user_1');
    expect(sentEmails).toContain('test@example.com');
  });
});
```

**Key Points:**

- `createCallerFactory` is the tRPC v11 API for server-side procedure calls in tests [Inference: verify the exact API against your installed tRPC version — earlier versions used `createCaller` directly]
- No HTTP server, no module mocking — the test exercises the actual procedure logic with controlled dependencies
- Each test constructs a fresh context — no shared state between tests

---

### Common Pitfalls

**Pitfall 1 — Singleton state leaking between tests:**
If a singleton dependency (e.g., an in-memory fake database) retains state between tests, test order affects results. Reset or recreate fake dependencies per test or per test suite.

**Pitfall 2 — Over-injecting through context:**
Context should carry dependencies that are genuinely shared across many procedures. One-off dependencies used by a single procedure may be better imported directly — not every dependency needs to be injectable.

**Pitfall 3 — Concrete types in context:**
Typing `ctx.db` as `PrismaClient` rather than an interface makes it impossible to substitute a fake in tests without mocking the entire Prisma module. Prefer interface types in the `Context` definition.

**Pitfall 4 — Constructing services inside resolvers:**
Instantiating a service or client inside a resolver function means a new instance is created on every request. This is wasteful for stateless clients and may exhaust connection pools for database clients. Construct and inject at the module or context level.

---

**Conclusion**

Dependency injection in tRPC is built from context, interfaces, and factory functions rather than a DI container. The core patterns — context as container, interface-typed dependencies, router factories with injected deps, and service layer injection — work together and can be mixed as needed. The central design principle is that procedures should receive their dependencies rather than import them, making the dependency graph explicit, type-safe, and substitutable — particularly for testing.