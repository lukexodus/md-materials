## Using Prisma with tRPC

Prisma is a type-safe ORM for Node.js and TypeScript. It generates a typed client from your schema, making database access predictable and refactorable. In tRPC applications, Prisma is typically instantiated once, passed through context, and used directly inside procedure handlers — giving you end-to-end type safety from database to client.

---

### Prerequisites and Setup

```bash
npm install prisma @prisma/client
npx prisma init
```

This creates:

- `prisma/schema.prisma` — your schema definition
- `.env` with a `DATABASE_URL` placeholder

---

### Defining a Schema

prisma

```
// prisma/schema.prisma
generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

model User {
  id        String   @id @default(cuid())
  email     String   @unique
  name      String?
  posts     Post[]
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt
}

model Post {
  id        String   @id @default(cuid())
  title     String
  content   String?
  published Boolean  @default(false)
  authorId  String
  author    User     @relation(fields: [authorId], references: [id])
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt
}
```

After editing the schema:

```bash
npx prisma migrate dev --name init
npx prisma generate
```

**Key Points:**

- `prisma generate` regenerates the typed client whenever the schema changes — run it after every schema modification
- `migrate dev` applies migrations and regenerates the client automatically in development

---

### Instantiating PrismaClient

PrismaClient should be instantiated once per application process. In Next.js development mode, hot reloading creates new module instances repeatedly, which can exhaust database connections if not handled.

```ts
// server/db.ts
import { PrismaClient } from '@prisma/client';

const globalForPrisma = globalThis as unknown as {
  prisma: PrismaClient | undefined;
};

export const db =
  globalForPrisma.prisma ??
  new PrismaClient({
    log: process.env.NODE_ENV === 'development'
      ? ['query', 'error', 'warn']
      : ['error'],
  });

if (process.env.NODE_ENV !== 'production') {
  globalForPrisma.prisma = db;
}
```

**Key Points:**

- Storing the instance on `globalThis` bypasses module re-evaluation during hot reload, reusing the existing connection pool [Inference: this is a common pattern in the Next.js + Prisma ecosystem; behavior may vary by runtime]
- Query logging in development helps diagnose N+1 queries and slow operations

---

### Passing PrismaClient Through tRPC Context

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

**Key Points:**

- Passing `db` through context rather than importing it directly in each router makes the client swappable (e.g., for a test mock) and keeps procedures decoupled from the module system

---

### Basic CRUD Procedures

```ts
// server/routers/post.ts
import { router, publicProcedure, protectedProcedure } from '../trpc';
import { z } from 'zod';
import { TRPCError } from '@trpc/server';

export const postRouter = router({
  // Read — list all published posts
  list: publicProcedure
    .input(z.object({
      limit: z.number().min(1).max(100).default(20),
      cursor: z.string().optional(),
    }))
    .query(async ({ ctx, input }) => {
      const posts = await ctx.db.post.findMany({
        where: { published: true },
        take: input.limit + 1,
        cursor: input.cursor ? { id: input.cursor } : undefined,
        orderBy: { createdAt: 'desc' },
        include: { author: { select: { id: true, name: true } } },
      });

      let nextCursor: string | undefined;
      if (posts.length > input.limit) {
        const next = posts.pop();
        nextCursor = next?.id;
      }

      return { posts, nextCursor };
    }),

  // Read — single post by id
  byId: publicProcedure
    .input(z.object({ id: z.string() }))
    .query(async ({ ctx, input }) => {
      const post = await ctx.db.post.findUnique({
        where: { id: input.id },
        include: { author: { select: { id: true, name: true } } },
      });

      if (!post) throw new TRPCError({ code: 'NOT_FOUND' });
      return post;
    }),

  // Create
  create: protectedProcedure
    .input(z.object({
      title: z.string().min(1).max(200),
      content: z.string().optional(),
    }))
    .mutation(async ({ ctx, input }) => {
      return ctx.db.post.create({
        data: {
          title: input.title,
          content: input.content,
          authorId: ctx.user.id,
        },
      });
    }),

  // Update
  update: protectedProcedure
    .input(z.object({
      id: z.string(),
      title: z.string().min(1).max(200).optional(),
      content: z.string().optional(),
      published: z.boolean().optional(),
    }))
    .mutation(async ({ ctx, input }) => {
      const post = await ctx.db.post.findUnique({ where: { id: input.id } });

      if (!post) throw new TRPCError({ code: 'NOT_FOUND' });
      if (post.authorId !== ctx.user.id) throw new TRPCError({ code: 'FORBIDDEN' });

      const { id, ...data } = input;
      return ctx.db.post.update({ where: { id }, data });
    }),

  // Delete
  delete: protectedProcedure
    .input(z.object({ id: z.string() }))
    .mutation(async ({ ctx, input }) => {
      const post = await ctx.db.post.findUnique({ where: { id: input.id } });

      if (!post) throw new TRPCError({ code: 'NOT_FOUND' });
      if (post.authorId !== ctx.user.id) throw new TRPCError({ code: 'FORBIDDEN' });

      return ctx.db.post.delete({ where: { id: input.id } });
    }),
});
```

---

### Cursor-Based Pagination

The `list` procedure above implements cursor pagination — a pattern well-suited to Prisma's `take`/`cursor`/`skip` API.

```
Request:  limit=20, cursor=undefined     → first page
Response: posts[0..19], nextCursor=posts[19].id

Request:  limit=20, cursor="<id>"        → next page
Response: posts[20..39], nextCursor=posts[39].id
```

**Key Points:**

- Fetching `limit + 1` items and popping the last is a standard technique to determine whether a next page exists without a separate `count` query
- Cursor pagination preserves consistency when new records are inserted between pages, unlike offset pagination [Inference: depends on sort order and index stability]

---

### Transactions

Prisma supports interactive transactions for operations that must succeed or fail together.

```ts
transfer: protectedProcedure
  .input(z.object({
    fromAccountId: z.string(),
    toAccountId: z.string(),
    amount: z.number().positive(),
  }))
  .mutation(async ({ ctx, input }) => {
    return ctx.db.$transaction(async (tx) => {
      const from = await tx.account.findUnique({
        where: { id: input.fromAccountId },
      });

      if (!from || from.balance < input.amount) {
        throw new TRPCError({
          code: 'BAD_REQUEST',
          message: 'Insufficient balance.',
        });
      }

      await tx.account.update({
        where: { id: input.fromAccountId },
        data: { balance: { decrement: input.amount } },
      });

      await tx.account.update({
        where: { id: input.toAccountId },
        data: { balance: { increment: input.amount } },
      });

      return { success: true };
    });
  }),
```

**Key Points:**

- The `tx` argument inside `$transaction` is a scoped Prisma client — all operations on it participate in the same transaction
- Throwing inside `$transaction` rolls back all operations within that callback [Inference: standard database transaction semantics; verify with your database provider]
- `TRPCError` thrown inside `$transaction` will propagate correctly to the tRPC error handler

---

### Reusable Select Shapes

Defining reusable `select` objects avoids repeating field lists and keeps return shapes consistent across procedures.

```ts
// server/lib/selects.ts
import { Prisma } from '@prisma/client';

export const postSummary = {
  id: true,
  title: true,
  published: true,
  createdAt: true,
  author: {
    select: { id: true, name: true },
  },
} satisfies Prisma.PostSelect;

export const postDetail = {
  ...postSummary,
  content: true,
  updatedAt: true,
} satisfies Prisma.PostSelect;
```

```ts
// In procedures
const posts = await ctx.db.post.findMany({
  where: { published: true },
  select: postSummary,
});

const post = await ctx.db.post.findUnique({
  where: { id: input.id },
  select: postDetail,
});
```

**Key Points:**

- `satisfies Prisma.PostSelect` provides compile-time checking that field names are valid without losing the inferred type [Inference: requires TypeScript 4.9+]
- Centralizing select shapes makes it easier to add or remove fields globally without touching each procedure

---

### Inferring Return Types from Prisma

Prisma's generated types can be used to type procedure outputs explicitly or to derive types for use elsewhere in the application.

```ts
import { Prisma } from '@prisma/client';
import { postDetail } from '../lib/selects';

// Derive the return type of a specific query shape
type PostDetail = Prisma.PostGetPayload<{ select: typeof postDetail }>;

// Use in a utility function signature
function formatPost(post: PostDetail) {
  return {
    ...post,
    formattedDate: post.createdAt.toLocaleDateString(),
  };
}
```

**Key Points:**

- `Prisma.PostGetPayload<...>` gives you the exact TypeScript type for a given `select` or `include` shape — no manual interface duplication needed
- This type flows through tRPC's inference automatically when used as the return value of a query or mutation

---

### Using Zod with Prisma for Input Validation

Zod schemas for inputs can be derived from Prisma types using `zod-prisma-types` or written manually. Manual schemas are more flexible and explicit.

```ts
// Manually aligned with Prisma schema
const createPostInput = z.object({
  title: z.string().min(1).max(200),
  content: z.string().max(10000).optional(),
});

// If using zod-prisma-types (generated)
import { PostCreateInputSchema } from '../prisma/generated/zod';
```

**Key Points:**

- Generated Zod schemas from `zod-prisma-types` match Prisma's input types exactly, reducing drift between validation and schema [Inference: depends on generator configuration]
- Manual schemas give finer control over user-facing validation messages and constraints that Prisma's types do not express (e.g., max length on a string field)

---

### Avoiding N+1 Queries

Fetching related data in a loop is a common performance mistake. Prefer `include` or nested `select` over sequential queries.

```ts
// ❌ N+1: one query per post to fetch its author
const posts = await ctx.db.post.findMany();
const postsWithAuthors = await Promise.all(
  posts.map(async (post) => ({
    ...post,
    author: await ctx.db.user.findUnique({ where: { id: post.authorId } }),
  }))
);

// ✅ Single query with include
const posts = await ctx.db.post.findMany({
  include: { author: { select: { id: true, name: true } } },
});
```

**Key Points:**

- Prisma does not automatically batch relational queries the way some ORMs do — N+1 patterns result in real extra round-trips to the database [Inference: based on Prisma's documented query behavior; verify against your version]
- Enable query logging in development to detect N+1 patterns early

---

### Data Layer Diagram

<svg viewBox="0 0 700 440" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="12">
<rect width="700" height="440" fill="#0f1117" rx="12"/>
<text x="350" y="34" text-anchor="middle" fill="#e2e8f0" font-size="15" font-weight="bold">Prisma + tRPC Data Layer</text>
<!-- Client -->
<rect x="30" y="70" width="120" height="44" rx="8" fill="#1e293b" stroke="#334155" stroke-width="1.5"/>
<text x="90" y="97" text-anchor="middle" fill="#94a3b8">React Client</text>
<!-- Arrow -->
<line x1="150" y1="92" x2="210" y2="92" stroke="#475569" stroke-width="1.5" marker-end="url(#a1)"/>
<!-- tRPC Router -->
<rect x="210" y="70" width="140" height="44" rx="8" fill="#1e293b" stroke="#334155" stroke-width="1.5"/>
<text x="280" y="92" text-anchor="middle" fill="#94a3b8">tRPC Router</text>
<text x="280" y="107" text-anchor="middle" fill="#64748b" font-size="10">postRouter, userRouter…</text>
<!-- Arrow down -->
<line x1="280" y1="114" x2="280" y2="150" stroke="#475569" stroke-width="1.5" marker-end="url(#a1)"/>
<!-- Context -->
<rect x="200" y="150" width="160" height="44" rx="8" fill="#1e293b" stroke="#334155" stroke-width="1.5"/>
<text x="280" y="170" text-anchor="middle" fill="#94a3b8">ctx.db</text>
<text x="280" y="186" text-anchor="middle" fill="#64748b" font-size="10">PrismaClient instance</text>
<!-- Arrow down -->
<line x1="280" y1="194" x2="280" y2="230" stroke="#475569" stroke-width="1.5" marker-end="url(#a1)"/>
<!-- Prisma Client -->
<rect x="185" y="230" width="190" height="54" rx="8" fill="#1a2744" stroke="#3b82f6" stroke-width="1.5"/>
<text x="280" y="252" text-anchor="middle" fill="#93c5fd">Prisma Client</text>
<text x="280" y="270" text-anchor="middle" fill="#64748b" font-size="10">findMany · create · update · $transaction</text>
<!-- Arrow to Query Engine -->
<line x1="280" y1="284" x2="280" y2="320" stroke="#3b82f6" stroke-width="1.5" marker-end="url(#ablue)"/>
<!-- Query Engine -->
<rect x="185" y="320" width="190" height="44" rx="8" fill="#1a2744" stroke="#3b82f6" stroke-width="1.5"/>
<text x="280" y="340" text-anchor="middle" fill="#93c5fd">Prisma Query Engine</text>
<text x="280" y="356" text-anchor="middle" fill="#64748b" font-size="10">generates SQL</text>
<!-- Arrow to DB -->
<line x1="375" y1="342" x2="460" y2="342" stroke="#475569" stroke-width="1.5" marker-end="url(#a1)"/>
<!-- Database -->
<rect x="460" y="310" width="180" height="110" rx="8" fill="#1e293b" stroke="#334155" stroke-width="1.5"/>
<text x="550" y="340" text-anchor="middle" fill="#94a3b8">PostgreSQL / MySQL</text>
<text x="550" y="360" text-anchor="middle" fill="#64748b" font-size="10">SQLite / MongoDB…</text>
<!-- Tables -->
<rect x="480" y="374" width="70" height="30" rx="4" fill="#0f172a" stroke="#334155"/>
<text x="515" y="394" text-anchor="middle" fill="#64748b" font-size="10">users</text>
<rect x="570" y="374" width="60" height="30" rx="4" fill="#0f172a" stroke="#334155"/>
<text x="600" y="394" text-anchor="middle" fill="#64748b" font-size="10">posts</text>
<!-- Return arrow from DB -->
<line x1="460" y1="358" x2="375" y2="358" stroke="#22c55e" stroke-width="1.5" marker-end="url(#agreen)"/>
<text x="417" y="374" text-anchor="middle" fill="#86efac" font-size="10">typed rows</text>
<!-- select/include label -->

<text x="420" y="330" text-anchor="middle" fill="`#64748b`" font-size="10">SQL query</text>

<!-- Schema -->
<rect x="30" y="230" width="140" height="54" rx="8" fill="#1e293b" stroke="#334155" stroke-width="1.5"/>
<text x="100" y="252" text-anchor="middle" fill="#94a3b8">schema.prisma</text>
<text x="100" y="270" text-anchor="middle" fill="#64748b" font-size="10">models · relations</text>
<!-- Arrow schema to prisma -->
<line x1="170" y1="257" x2="185" y2="257" stroke="#475569" stroke-width="1.5" marker-end="url(#a1)"/>
<text x="100" y="300" text-anchor="middle" fill="#64748b" font-size="10">prisma generate ↑</text>
<!-- Return to client -->
<line x1="210" y1="92" x2="150" y2="92" stroke="#22c55e" stroke-width="1.5" marker-end="url(#agreen)"/>
<text x="90" y="130" text-anchor="middle" fill="#86efac" font-size="10">typed response</text>
<defs>
<marker id="a1" markerWidth="8" markerHeight="8" refX="4" refY="4" orient="auto">
<path d="M0,0 L8,4 L0,8 Z" fill="#475569"/>
</marker>
<marker id="ablue" markerWidth="8" markerHeight="8" refX="4" refY="4" orient="auto">
<path d="M0,0 L8,4 L0,8 Z" fill="#3b82f6"/>
</marker>
<marker id="agreen" markerWidth="8" markerHeight="8" refX="4" refY="4" orient="auto">
<path d="M0,0 L8,4 L0,8 Z" fill="#22c55e"/>
</marker>
</defs>
</svg>

---

### Testing Procedures with a Mocked Prisma Client

Because `db` comes through context, it can be replaced with a mock in tests.

```ts
// tests/post.test.ts
import { createCaller } from '../server/routers/_app';
import { mockDeep } from 'jest-mock-extended';
import type { PrismaClient } from '@prisma/client';

const mockDb = mockDeep<PrismaClient>();

const ctx = {
  db: mockDb,
  user: { id: 'user-1', role: 'user' },
  session: {} as any,
};

const caller = createCaller(ctx);

test('byId returns post when found', async () => {
  mockDb.post.findUnique.mockResolvedValue({
    id: 'post-1',
    title: 'Test Post',
    content: null,
    published: true,
    authorId: 'user-1',
    createdAt: new Date(),
    updatedAt: new Date(),
    author: { id: 'user-1', name: 'Luke' },
  } as any);

  const post = await caller.post.byId({ id: 'post-1' });
  expect(post.title).toBe('Test Post');
});

test('byId throws NOT_FOUND when post is missing', async () => {
  mockDb.post.findUnique.mockResolvedValue(null);

  await expect(caller.post.byId({ id: 'missing' }))
    .rejects.toMatchObject({ code: 'NOT_FOUND' });
});
```

**Key Points:**

- `jest-mock-extended`'s `mockDeep` creates a fully typed mock of `PrismaClient` without needing a real database connection
- `createCaller(ctx)` bypasses HTTP, calling procedures directly — suitable for unit tests [Inference: behavior depends on tRPC version; verify `createCaller` API for your version]

---

### Common Mistakes

| Mistake | Problem | Fix |
| --- | --- | --- |
| `new PrismaClient()` in every request | Connection pool exhaustion | Singleton pattern via `globalThis` |
| `include` on every field by default | Over-fetching data | Use `select` to fetch only needed fields |
| Sequential queries in a loop | N+1 problem | Use `include` or batch with `findMany` + `in` filter |
| No transaction on multi-step writes | Partial failure leaves inconsistent state | Wrap with `$transaction` |
| Trusting client input as DB IDs without validation | Potential injection or traversal | Validate all IDs with Zod before querying |

---

**Next Steps:** Using Drizzle ORM with tRPC — a lighter-weight, SQL-first alternative to Prisma with comparable type safety.