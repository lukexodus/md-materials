## Passing the Database Client Through Context

The tRPC context is the mechanism by which shared, per-request resources — authentication data, database clients, loggers, feature flags — are made available to every procedure without being imported directly. Passing the database client through context is a foundational architectural decision that affects testability, flexibility, and consistency across the entire API surface.

---

### Why Context, Not Direct Import

A database client could be imported directly into each router file. This works, but creates problems:

```ts
// ❌ Direct import — works but creates coupling
import { db } from '../db';

export const postRouter = router({
  list: publicProcedure.query(() => db.post.findMany()),
});
```

Problems with this approach:

- Procedures are coupled to a specific `db` instance — swapping for a test mock requires module-level patching
- Transactions cannot be scoped across procedures unless `db` is threaded manually
- There is no single place to attach per-request concerns (e.g., a tenant-specific database connection)

```ts
// ✅ Via context — decoupled, testable, flexible
export const postRouter = router({
  list: publicProcedure.query(({ ctx }) => ctx.db.post.findMany()),
});
```

**Key Points:**

- Context makes the database client a dependency that is injected per request, not a module-level global
- Procedures become pure functions of their input and context — easier to reason about and test in isolation [Inference]

---

### The Baseline Pattern

The minimum viable pattern: create the client once, return it from `createContext`.

```ts
// server/db.ts
import { PrismaClient } from '@prisma/client';

const globalForPrisma = globalThis as unknown as {
  prisma: PrismaClient | undefined;
};

export const db =
  globalForPrisma.prisma ?? new PrismaClient();

if (process.env.NODE_ENV !== 'production') {
  globalForPrisma.prisma = db;
}
```

```ts
// server/context.ts
import { db } from './db';
import type { CreateNextContextOptions } from '@trpc/server/adapters/next';

export async function createContext({ req, res }: CreateNextContextOptions) {
  return { db };
}

export type Context = Awaited<ReturnType<typeof createContext>>;
```

```ts
// server/trpc.ts
import { initTRPC } from '@trpc/server';
import type { Context } from './context';

const t = initTRPC.context<Context>().create();
export const router = t.router;
export const publicProcedure = t.procedure;
```

This is the foundation everything else builds on.

---

### Combining Database Client with Authentication

In most applications, context carries both the database client and the authenticated user. The two are related: the user is often loaded from the database during context creation.

```ts
// server/context.ts
import { db } from './db';
import { getServerSession } from 'next-auth';
import { authOptions } from './auth';
import type { CreateNextContextOptions } from '@trpc/server/adapters/next';

export async function createContext({ req, res }: CreateNextContextOptions) {
  const session = await getServerSession(req, res, authOptions);

  return {
    db,
    session,
    user: session?.user ?? null,
  };
}

export type Context = Awaited<ReturnType<typeof createContext>>;
```

**Key Points:**

- The session fetch and the database client instantiation are independent — the database client is a singleton; the session is per-request
- Keeping both in context means procedures have everything they need without additional imports or fetches

---

### Typing the Context Precisely

Typing context correctly is important because tRPC's procedure types flow from it. Imprecise context types cause unnecessary null-checks or unsafe assertions inside procedures.

```ts
// server/context.ts
import type { PrismaClient } from '@prisma/client';

// Explicit type for the full context shape
export type Context = {
  db: PrismaClient;
  user: {
    id: string;
    email: string;
    role: 'user' | 'admin';
  } | null;
};
```

Protected procedures narrow `user` from `null` to a concrete type:

```ts
// server/trpc.ts
import { initTRPC, TRPCError } from '@trpc/server';
import type { Context } from './context';

const t = initTRPC.context<Context>().create();

export const protectedProcedure = t.procedure.use(({ ctx, next }) => {
  if (!ctx.user) throw new TRPCError({ code: 'UNAUTHORIZED' });

  return next({
    ctx: {
      ...ctx,
      user: ctx.user, // narrowed: string | null → { id, email, role }
    },
  });
});
```

**Key Points:**

- After the middleware guard, TypeScript treats `ctx.user` as non-null — no optional chaining needed inside protected procedures [Inference: depends on TypeScript strict mode and tRPC version]
- Defining `Context` explicitly (rather than only inferring it) makes the shape a stable contract that other parts of the codebase can import

---

### Using an Abstract Database Interface

Defining the database dependency as an interface rather than a concrete class allows the client to be replaced without changing procedure code — useful for testing with mocks or supporting multiple backends.

```ts
// server/db/interface.ts
export interface PostRepository {
  findById(id: string): Promise<Post | null>;
  findMany(opts: { limit: number; cursor?: string }): Promise<Post[]>;
  create(data: NewPost): Promise<Post>;
  update(id: string, data: Partial<Post>): Promise<Post>;
  delete(id: string): Promise<void>;
}

export interface DatabaseClient {
  post: PostRepository;
  user: UserRepository;
  $transaction<T>(fn: (tx: DatabaseClient) => Promise<T>): Promise<T>;
}
```

```ts
// server/context.ts
import type { DatabaseClient } from './db/interface';
import { prismaClient } from './db/prisma';

export async function createContext(): Promise<{ db: DatabaseClient }> {
  return { db: prismaClient };
}
```

**Key Points:**

- This pattern is more common in large codebases where the ORM layer is explicitly separated from the application layer [Inference]
- For most tRPC projects, passing `PrismaClient` or `Kysely<Database>` directly is sufficient and more practical [Inference]

---

### Lazy Context: Deferring Expensive Operations

If not every procedure needs the database, you can defer the client instantiation using a lazy getter — the connection is only established when first accessed.

```ts
// server/context.ts
import { db } from './db';
import type { CreateNextContextOptions } from '@trpc/server/adapters/next';

export async function createContext({ req, res }: CreateNextContextOptions) {
  let _db: typeof db | undefined;

  return {
    get db() {
      if (!_db) _db = db;
      return _db;
    },
  };
}
```

A more practical variant defers the session fetch only for routes that need it:

```ts
export async function createContext({ req, res }: CreateNextContextOptions) {
  return {
    db,
    // Session is fetched only once, on first access
    getSession: () => getServerSession(req, res, authOptions),
  };
}
```

```ts
// In middleware — only fetches when the procedure actually uses it
export const protectedProcedure = t.procedure.use(async ({ ctx, next }) => {
  const session = await ctx.getSession();
  if (!session) throw new TRPCError({ code: 'UNAUTHORIZED' });
  return next({ ctx: { ...ctx, session, user: session.user } });
});
```

**Key Points:**

- Lazy context is most useful when a significant proportion of requests are public and do not require a session [Inference]
- The singleton `db` instance itself is never re-created — only the reference inside context changes, which has no practical cost

---

### Transaction Scoping Through Context

When a single tRPC mutation needs to span multiple repository operations atomically, the transaction client must be threaded through context.

```ts
// server/routers/order.ts
import { protectedProcedure, router } from '../trpc';
import { z } from 'zod';
import { TRPCError } from '@trpc/server';

export const orderRouter = router({
  place: protectedProcedure
    .input(z.object({
      productId: z.string(),
      quantity:  z.number().int().positive(),
    }))
    .mutation(async ({ ctx, input }) => {
      return ctx.db.$transaction(async (tx) => {
        const product = await tx.product.findUnique({
          where: { id: input.productId },
        });

        if (!product) throw new TRPCError({ code: 'NOT_FOUND' });

        if (product.stock < input.quantity) {
          throw new TRPCError({
            code: 'BAD_REQUEST',
            message: 'Insufficient stock.',
          });
        }

        await tx.product.update({
          where: { id: input.productId },
          data: { stock: { decrement: input.quantity } },
        });

        return tx.order.create({
          data: {
            productId: input.productId,
            userId:    ctx.user.id,
            quantity:  input.quantity,
          },
        });
      });
    }),
});
```

**Key Points:**

- The transaction client `tx` is used entirely within the procedure — it does not need to be placed in context unless the transaction spans multiple helper functions
- If helper functions need to participate in the same transaction, pass `tx` as a function argument rather than replacing `ctx.db`

---

### Replacing the DB Client in Tests

Because the database client comes from context, tests can inject a mock without touching the module system.

```ts
// tests/helpers/mockContext.ts
import { mockDeep } from 'jest-mock-extended';
import type { PrismaClient } from '@prisma/client';
import type { Context } from '../../server/context';

export function mockContext(overrides: Partial<Context> = {}): Context {
  return {
    db: mockDeep<PrismaClient>(),
    user: null,
    session: null,
    ...overrides,
  };
}
```

```ts
// tests/post.test.ts
import { createCaller } from '../../server/routers/_app';
import { mockContext } from '../helpers/mockContext';

test('list returns published posts', async () => {
  const ctx = mockContext({
    user: { id: 'u1', email: 'a@b.com', role: 'user' },
  });

  ctx.db.post.findMany.mockResolvedValue([
    {
      id: 'p1',
      title: 'Hello',
      published: true,
      authorId: 'u1',
      content: null,
      createdAt: new Date(),
      updatedAt: new Date(),
    },
  ]);

  const caller = createCaller(ctx);
  const result = await caller.post.list({ limit: 10 });

  expect(result.posts).toHaveLength(1);
  expect(result.posts[0].title).toBe('Hello');
});
```

**Key Points:**

- `mockDeep<PrismaClient>()` creates a fully typed mock — TypeScript will complain if you mock a method that does not exist on `PrismaClient`
- `createCaller(ctx)` bypasses HTTP entirely — procedure logic runs directly, making tests fast and deterministic [Inference: behavior depends on tRPC version]

---

### Multi-Tenancy: Per-Request Database Connections

In multi-tenant applications, each request may need a connection scoped to a specific tenant — different schema, different database URL, or different connection pool.

```ts
// server/context.ts
import { getTenantDb } from './db/tenants';
import type { CreateNextContextOptions } from '@trpc/server/adapters/next';

export async function createContext({ req, res }: CreateNextContextOptions) {
  const tenantId = req.headers['x-tenant-id'] as string | undefined;

  if (!tenantId) {
    throw new TRPCError({ code: 'BAD_REQUEST', message: 'Missing tenant.' });
  }

  // Returns a PrismaClient or Kysely instance scoped to this tenant
  const db = await getTenantDb(tenantId);

  return { db, tenantId };
}
```

```ts
// server/db/tenants.ts
import { PrismaClient } from '@prisma/client';

const tenantClients = new Map<string, PrismaClient>();

export async function getTenantDb(tenantId: string): Promise<PrismaClient> {
  if (tenantClients.has(tenantId)) {
    return tenantClients.get(tenantId)!;
  }

  const url = await resolveTenantDatabaseUrl(tenantId); // your lookup logic
  const client = new PrismaClient({ datasources: { db: { url } } });

  tenantClients.set(tenantId, client);
  return client;
}
```

**Key Points:**

- Caching tenant clients in a `Map` avoids creating a new connection pool per request [Inference]
- The cache is unbounded in the example above — a production implementation should use an LRU cache or connection pool manager to cap open connections [Inference]
- Tenant ID sourced from a header should be validated against an authenticated session to prevent spoofing [Inference]

---

### Context Shape Reference

```
createContext()
└── returns Context
    ├── db             — database client (Prisma / Drizzle / Kysely)
    ├── user           — authenticated user or null
    ├── session        — raw session object or null
    ├── tenantId       — (multi-tenant) tenant identifier
    └── [other]        — logger, feature flags, request metadata
```

---

### Flow Diagram

<svg viewBox="0 0 700 460" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="12">
<rect width="700" height="460" fill="#0f1117" rx="12"/>
<text x="350" y="34" text-anchor="middle" fill="#e2e8f0" font-size="15" font-weight="bold">Database Client Through Context</text>
<!-- Singleton DB -->
<rect x="30" y="70" width="160" height="54" rx="8" fill="#1e293b" stroke="#334155" stroke-width="1.5"/>
<text x="110" y="93" text-anchor="middle" fill="#94a3b8">DB Singleton</text>
<text x="110" y="111" text-anchor="middle" fill="#64748b" font-size="10">globalThis · one connection pool</text>
<!-- Arrow -->
<line x1="190" y1="97" x2="250" y2="97" stroke="#475569" stroke-width="1.5" marker-end="url(#a1)"/>
<text x="220" y="88" text-anchor="middle" fill="#64748b" font-size="10">imported</text>
<!-- createContext -->
<rect x="250" y="70" width="190" height="54" rx="8" fill="#1e293b" stroke="#334155" stroke-width="1.5"/>
<text x="345" y="93" text-anchor="middle" fill="#94a3b8">createContext(req, res)</text>
<text x="345" y="111" text-anchor="middle" fill="#64748b" font-size="10">per-request · runs on every call</text>
<!-- Arrow down -->
<line x1="345" y1="124" x2="345" y2="160" stroke="#475569" stroke-width="1.5" marker-end="url(#a1)"/>
<!-- Context object -->
<rect x="230" y="160" width="230" height="74" rx="8" fill="#1e293b" stroke="#334155" stroke-width="1.5"/>
<text x="345" y="183" text-anchor="middle" fill="#94a3b8">Context</text>
<text x="345" y="200" text-anchor="middle" fill="#64748b" font-size="10">db · user · session</text>
<text x="345" y="217" text-anchor="middle" fill="#64748b" font-size="10">tenantId · logger · …</text>
<!-- Arrow down to middleware -->
<line x1="345" y1="234" x2="345" y2="270" stroke="#475569" stroke-width="1.5" marker-end="url(#a1)"/>
<!-- Middleware -->
<rect x="225" y="270" width="240" height="44" rx="8" fill="#1e1a3a" stroke="#7c3aed" stroke-width="1.5"/>
<text x="345" y="290" text-anchor="middle" fill="#c4b5fd">Auth Middleware</text>
<text x="345" y="306" text-anchor="middle" fill="#a78bfa" font-size="10">narrows ctx.user to non-null</text>
<!-- Arrow down to procedures -->
<line x1="345" y1="314" x2="345" y2="350" stroke="#475569" stroke-width="1.5" marker-end="url(#a1)"/>
<!-- Procedures -->
<rect x="130" y="350" width="160" height="54" rx="8" fill="#14532d" stroke="#22c55e" stroke-width="1.5"/>
<text x="210" y="373" text-anchor="middle" fill="#86efac">publicProcedure</text>
<text x="210" y="389" text-anchor="middle" fill="#86efac" font-size="10">ctx.db available</text>
<rect x="370" y="350" width="160" height="54" rx="8" fill="#14532d" stroke="#22c55e" stroke-width="1.5"/>
<text x="450" y="373" text-anchor="middle" fill="#86efac">protectedProcedure</text>
<text x="450" y="389" text-anchor="middle" fill="#86efac" font-size="10">ctx.db + ctx.user</text>
<line x1="300" y1="377" x2="370" y2="377" stroke="#22c55e" stroke-width="1" stroke-dasharray="3,3"/>
<!-- Test path -->
<rect x="510" y="160" width="160" height="54" rx="8" fill="#1e293b" stroke="#334155" stroke-width="1.5"/>
<text x="590" y="183" text-anchor="middle" fill="#94a3b8">Test Mock Context</text>
<text x="590" y="201" text-anchor="middle" fill="#64748b" font-size="10">mockDeep&lt;PrismaClient&gt;()</text>
<!-- Arrow: mock to middleware -->
<line x1="510" y1="187" x2="465" y2="280" stroke="#334155" stroke-width="1.2" stroke-dasharray="4,3" marker-end="url(#adash)"/>
<text x="510" y="240" text-anchor="middle" fill="#475569" font-size="10">injected in tests</text>
<defs>
<marker id="a1" markerWidth="8" markerHeight="8" refX="4" refY="4" orient="auto">
<path d="M0,0 L8,4 L0,8 Z" fill="#475569"/>
</marker>
<marker id="adash" markerWidth="8" markerHeight="8" refX="4" refY="4" orient="auto">
<path d="M0,0 L8,4 L0,8 Z" fill="#334155"/>
</marker>
<marker id="agreen" markerWidth="8" markerHeight="8" refX="4" refY="4" orient="auto">
<path d="M0,0 L8,4 L0,8 Z" fill="#22c55e"/>
</marker>
</defs>
</svg>

---

### Common Mistakes

| Mistake | Problem | Fix |
| --- | --- | --- |
| Importing `db` directly in routers | Tight coupling, untestable | Access via `ctx.db` |
| Creating `new PrismaClient()` inside `createContext` | New connection pool per request — exhausts database connections rapidly | Singleton via `globalThis` |
| Putting transaction client in context | Leaks transaction scope beyond the originating procedure | Pass `tx` as a function argument instead |
| Returning `db` without typing `Context` | Type inference becomes `any` or overly broad | Export explicit `Context` type from `context.ts` |
| Fetching session unconditionally in context | Unnecessary work for public routes | Use lazy getter or move session fetch to middleware |

---

**Next Steps:** Structuring routers in large tRPC applications — organizing procedures across multiple files, nested routers, and shared middleware composition.