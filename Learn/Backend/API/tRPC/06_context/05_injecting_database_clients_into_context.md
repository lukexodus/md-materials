## Injecting Database Clients into Context

Injecting a database client into tRPC context makes it available to all procedures through `ctx`, avoiding the need to import or instantiate the client inside individual handlers.

---

### Why Inject via Context?

Importing a database client directly into each procedure file works, but injecting through context offers structural advantages:

- Procedures do not need to know where the client comes from.
- The client can be swapped or mocked at the context level without touching procedure code.
- Type safety is maintained end-to-end through the context type.

[Inference] This pattern is especially useful during testing, where a mock or in-memory client can be substituted at the context layer. Actual testability depends on your setup.

---

### Basic Injection: Prisma

Prisma is a common choice in tRPC projects. The client is typically instantiated as a singleton and attached to context.

#### Singleton Setup

```typescript
// lib/prisma.ts
import { PrismaClient } from '@prisma/client';

const globalForPrisma = globalThis as unknown as {
  prisma: PrismaClient | undefined;
};

export const prisma =
  globalForPrisma.prisma ?? new PrismaClient();

if (process.env.NODE_ENV !== 'production') {
  globalForPrisma.prisma = prisma;
}
```

**Key Points**
- The `globalThis` trick prevents multiple `PrismaClient` instances from being created during hot-reloads in development.
- [Inference] In production, the module cache typically prevents re-instantiation, but this is runtime-dependent.

#### Attaching to Context

```typescript
// server/context.ts
import { prisma } from '../lib/prisma';
import { type CreateNextContextOptions } from '@trpc/server/adapters/next';

export async function createContext({ req, res }: CreateNextContextOptions) {
  return {
    prisma,
    req,
    res,
  };
}

export type Context = Awaited<ReturnType<typeof createContext>>;
```

#### Using in a Procedure

```typescript
export const appRouter = router({
  getUsers: publicProcedure.query(async ({ ctx }) => {
    return await ctx.prisma.user.findMany();
  }),
});
```

**Output**
```json
[
  { "id": 1, "email": "alice@example.com" },
  { "id": 2, "email": "bob@example.com" }
]
```

---

### Basic Injection: Drizzle ORM

Drizzle uses a database connection object rather than a class instance.

#### Setup

```typescript
// lib/db.ts
import { drizzle } from 'drizzle-orm/node-postgres';
import { Pool } from 'pg';
import * as schema from './schema';

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
});

export const db = drizzle(pool, { schema });
```

#### Attaching to Context

```typescript
// server/context.ts
import { db } from '../lib/db';
import { type CreateNextContextOptions } from '@trpc/server/adapters/next';

export async function createContext({ req, res }: CreateNextContextOptions) {
  return {
    db,
    req,
    res,
  };
}

export type Context = Awaited<ReturnType<typeof createContext>>;
```

#### Using in a Procedure

```typescript
import { users } from '../lib/schema';

export const appRouter = router({
  getUsers: publicProcedure.query(async ({ ctx }) => {
    return await ctx.db.select().from(users);
  }),
});
```

---

### Multiple Clients in Context

There is no restriction on attaching more than one client. A project may use a relational database alongside a cache or search index.

```typescript
// server/context.ts
import { prisma } from '../lib/prisma';
import { redis } from '../lib/redis';
import { searchClient } from '../lib/search';
import { type CreateNextContextOptions } from '@trpc/server/adapters/next';

export async function createContext({ req, res }: CreateNextContextOptions) {
  return {
    prisma,
    redis,
    searchClient,
    req,
    res,
  };
}
```

Procedures then access whichever client they need:

```typescript
getCachedUser: publicProcedure
  .input(z.object({ id: z.string() }))
  .query(async ({ input, ctx }) => {
    const cached = await ctx.redis.get(`user:${input.id}`);
    if (cached) return JSON.parse(cached);

    const user = await ctx.prisma.user.findUnique({
      where: { id: input.id },
    });

    if (user) {
      await ctx.redis.set(`user:${input.id}`, JSON.stringify(user), 'EX', 300);
    }

    return user;
  }),
```

---

### Typing Context with initTRPC

The context type must be passed to `initTRPC` for procedures to have typed access to injected clients.

```typescript
// server/trpc.ts
import { initTRPC } from '@trpc/server';
import { type Context } from './context';

const t = initTRPC.context<Context>().create();

export const router = t.router;
export const publicProcedure = t.procedure;
```

Without this, `ctx.prisma` (or any other injected client) will not be recognized by TypeScript.

---

### Lazy Initialization

In some cases, you may want to defer client initialization until it is actually needed, rather than creating it on every request.

```typescript
// server/context.ts
import { type CreateNextContextOptions } from '@trpc/server/adapters/next';
import { PrismaClient } from '@prisma/client';

export async function createContext({ req, res }: CreateNextContextOptions) {
  let _prisma: PrismaClient | null = null;

  return {
    get prisma() {
      if (!_prisma) _prisma = new PrismaClient();
      return _prisma;
    },
    req,
    res,
  };
}
```

**Key Points**
- The client is only instantiated if a procedure actually accesses `ctx.prisma`.
- [Inference] This may reduce overhead for procedures that do not touch the database, but the actual performance impact depends on the runtime and how often the client is reused across requests.
- [Inference] This pattern does not use a singleton, so it may create multiple instances across requests unless combined with a module-level cache. Behavior may vary.

---

### Mocking the Client in Tests

Because the client enters procedures through `ctx`, it can be replaced with a mock at test time using the inner context pattern.

```typescript
// server/context.ts
export async function createInnerContext({
  prisma,
}: {
  prisma: PrismaClient;
}) {
  return { prisma };
}

export async function createContext({ req, res }: CreateNextContextOptions) {
  return {
    ...(await createInnerContext({ prisma })),
    req,
    res,
  };
}
```

In a test:

```typescript
import { createInnerContext } from '../server/context';
import { appRouter } from '../server/routers/_app';
import { mockDeep } from 'jest-mock-extended';
import { type PrismaClient } from '@prisma/client';

test('getUsers returns users', async () => {
  const mockPrisma = mockDeep<PrismaClient>();
  mockPrisma.user.findMany.mockResolvedValue([
    { id: '1', email: 'alice@example.com' },
  ]);

  const ctx = await createInnerContext({ prisma: mockPrisma });
  const caller = appRouter.createCaller(ctx);

  const result = await caller.getUsers();
  expect(result).toHaveLength(1);
});
```

[Inference] `jest-mock-extended` is one approach for deep-mocking typed clients. Other mocking libraries may be used depending on your test framework. Behavior of mocks is not guaranteed to match the real client.

---

### Connection Lifecycle Considerations

Database clients often manage connection pools. A few points to be aware of:

- **Prisma** manages its own connection pool internally. [Inference] Reconnection and pooling behavior is handled by the Prisma engine, not tRPC.
- **Drizzle with `pg`** uses a `Pool` — the pool persists for the lifetime of the module, not per request.
- **Serverless environments** (e.g., Vercel, AWS Lambda) may spin up new instances frequently, making connection reuse across requests less predictable.

[Inference] In serverless environments, connection pool exhaustion is a known concern with traditional clients. Tools like `@prisma/adapter-neon` or PgBouncer are sometimes used to address this, but their effectiveness depends on the deployment context. Behavior is not guaranteed.