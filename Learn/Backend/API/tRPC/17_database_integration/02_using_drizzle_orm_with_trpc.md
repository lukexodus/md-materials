## Using Drizzle ORM with tRPC

Drizzle is a TypeScript-first ORM that stays close to SQL. Rather than abstracting queries behind a proprietary API, it lets you write queries that map directly to SQL constructs while retaining full type inference. In tRPC applications, Drizzle fits the same role as Prisma — instantiated once, passed through context, used inside procedure handlers — but with a different philosophy: schema as code, queries as typed SQL builders.

---

### Prerequisites and Setup

```bash
npm install drizzle-orm @trpc/server @trpc/client @trpc/next zod
```

Install the appropriate database driver:

```bash
 PostgreSQL
npm install postgres
npm install -D drizzle-kit

 MySQL
npm install mysql2

 SQLite
npm install better-sqlite3
npm install -D @types/better-sqlite3
```

---

### Defining the Schema

Drizzle schemas are TypeScript files — there is no separate `.prisma` file. The schema is the source of truth for both the database structure and the TypeScript types.

```ts
// server/db/schema.ts
import {
  pgTable,
  text,
  timestamp,
  boolean,
  uuid,
} from 'drizzle-orm/pg-core';
import { relations } from 'drizzle-orm';

export const users = pgTable('users', {
  id:        uuid('id').primaryKey().defaultRandom(),
  email:     text('email').notNull().unique(),
  name:      text('name'),
  role:      text('role', { enum: ['user', 'admin'] }).notNull().default('user'),
  createdAt: timestamp('created_at').defaultNow().notNull(),
  updatedAt: timestamp('updated_at').defaultNow().notNull(),
});

export const posts = pgTable('posts', {
  id:        uuid('id').primaryKey().defaultRandom(),
  title:     text('title').notNull(),
  content:   text('content'),
  published: boolean('published').default(false).notNull(),
  authorId:  uuid('author_id').notNull().references(() => users.id),
  createdAt: timestamp('created_at').defaultNow().notNull(),
  updatedAt: timestamp('updated_at').defaultNow().notNull(),
});

// Relation declarations (used for relational query API)
export const usersRelations = relations(users, ({ many }) => ({
  posts: many(posts),
}));

export const postsRelations = relations(posts, ({ one }) => ({
  author: one(users, {
    fields: [posts.authorId],
    references: [users.id],
  }),
}));
```

**Key Points:**

- Column definitions like `uuid().primaryKey().defaultRandom()` and `text().notNull()` are TypeScript expressions — types are inferred directly from them
- `relations()` declarations do not affect the SQL schema; they are used only by Drizzle's relational query API (`db.query.*`)
- For SQLite, use `sqliteTable`, `integer`, `text` from `drizzle-orm/sqlite-core`; for MySQL, use `mysqlTable` from `drizzle-orm/mysql-core`

---

### Drizzle Config and Migrations

```ts
// drizzle.config.ts
import type { Config } from 'drizzle-kit';

export default {
  schema: './server/db/schema.ts',
  out: './drizzle',
  driver: 'pg',
  dbCredentials: {
    connectionString: process.env.DATABASE_URL!,
  },
} satisfies Config;
```

```bash
 Generate migration files
npx drizzle-kit generate:pg

 Apply migrations
npx drizzle-kit push:pg    development (no migration files)
 or
npx drizzle-kit migrate    production (applies generated files)
```

**Key Points:**

- `push` applies schema changes directly without generating migration files — suitable for development iteration [Inference]
- `generate` + `migrate` produces versioned SQL migration files — preferred for production deployments [Inference]

---

### Instantiating the Drizzle Client

```ts
// server/db/index.ts
import { drizzle } from 'drizzle-orm/postgres-js';
import postgres from 'postgres';
import * as schema from './schema';

const globalForDb = globalThis as unknown as {
  connection: postgres.Sql | undefined;
};

const connection =
  globalForDb.connection ??
  postgres(process.env.DATABASE_URL!, { max: 10 });

if (process.env.NODE_ENV !== 'production') {
  globalForDb.connection = connection;
}

export const db = drizzle(connection, { schema, logger: process.env.NODE_ENV === 'development' });
```

For SQLite (e.g., for local development or edge deployments):

```ts
// server/db/index.ts (SQLite)
import { drizzle } from 'drizzle-orm/better-sqlite3';
import Database from 'better-sqlite3';
import * as schema from './schema';

const sqlite = new Database('local.db');
export const db = drizzle(sqlite, { schema });
```

**Key Points:**

- The `globalThis` singleton pattern mirrors the Prisma pattern — it avoids connection pool exhaustion during Next.js hot reload
- Passing `schema` to `drizzle()` enables the relational query API (`db.query.posts.findMany(...)`)
- `logger: true` in development prints generated SQL to the console — useful for debugging query shape

---

### Passing Drizzle Through tRPC Context

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
import { initTRPC, TRPCError } from '@trpc/server';
import type { Context } from './context';

const t = initTRPC.context<Context>().create();

export const router = t.router;
export const publicProcedure = t.procedure;

export const protectedProcedure = t.procedure.use(({ ctx, next }) => {
  if (!ctx.user) throw new TRPCError({ code: 'UNAUTHORIZED' });
  return next({ ctx: { ...ctx, user: ctx.user } });
});
```

---

### Query API vs SQL Builder API

Drizzle provides two query styles. Both are valid inside tRPC procedures.

**Relational Query API** — declarative, relation-aware:

```ts
// Requires schema passed to drizzle() and relations() defined
const posts = await ctx.db.query.posts.findMany({
  where: (posts, { eq }) => eq(posts.published, true),
  with: {
    author: { columns: { id: true, name: true } },
  },
  orderBy: (posts, { desc }) => [desc(posts.createdAt)],
  limit: 20,
});
```

**SQL Builder API** — explicit, composable:

```ts
import { eq, desc, and } from 'drizzle-orm';
import { posts, users } from '../db/schema';

const result = await ctx.db
  .select({
    id:        posts.id,
    title:     posts.title,
    createdAt: posts.createdAt,
    authorName: users.name,
  })
  .from(posts)
  .leftJoin(users, eq(posts.authorId, users.id))
  .where(eq(posts.published, true))
  .orderBy(desc(posts.createdAt))
  .limit(20);
```

**Key Points:**

- The relational API is more ergonomic for nested data; the SQL builder is more explicit and maps closely to what SQL will be generated [Inference]
- Both produce fully typed results — column selections are reflected in the return type
- The SQL builder API does not require `schema` to be passed to `drizzle()`, making it usable in setups where the relational API is not needed

---

### Basic CRUD Procedures

```ts
// server/routers/post.ts
import { router, publicProcedure, protectedProcedure } from '../trpc';
import { z } from 'zod';
import { TRPCError } from '@trpc/server';
import { eq, desc, and } from 'drizzle-orm';
import { posts } from '../db/schema';

export const postRouter = router({
  // List published posts
  list: publicProcedure
    .input(z.object({
      limit:  z.number().min(1).max(100).default(20),
      cursor: z.string().uuid().optional(),
    }))
    .query(async ({ ctx, input }) => {
      const rows = await ctx.db.query.posts.findMany({
        where: (p, { eq, and, lt }) => and(
          eq(p.published, true),
          input.cursor ? lt(p.createdAt, ctx.db
            .select({ createdAt: posts.createdAt })
            .from(posts)
            .where(eq(posts.id, input.cursor))
            .limit(1)
          ) : undefined
        ),
        with: { author: { columns: { id: true, name: true } } },
        orderBy: (p, { desc }) => [desc(p.createdAt)],
        limit: input.limit + 1,
      });

      let nextCursor: string | undefined;
      if (rows.length > input.limit) {
        nextCursor = rows.pop()?.id;
      }

      return { posts: rows, nextCursor };
    }),

  // Single post
  byId: publicProcedure
    .input(z.object({ id: z.string().uuid() }))
    .query(async ({ ctx, input }) => {
      const post = await ctx.db.query.posts.findFirst({
        where: (p, { eq }) => eq(p.id, input.id),
        with: { author: { columns: { id: true, name: true } } },
      });

      if (!post) throw new TRPCError({ code: 'NOT_FOUND' });
      return post;
    }),

  // Create
  create: protectedProcedure
    .input(z.object({
      title:   z.string().min(1).max(200),
      content: z.string().optional(),
    }))
    .mutation(async ({ ctx, input }) => {
      const [post] = await ctx.db
        .insert(posts)
        .values({
          title:    input.title,
          content:  input.content,
          authorId: ctx.user.id,
        })
        .returning();

      return post;
    }),

  // Update
  update: protectedProcedure
    .input(z.object({
      id:        z.string().uuid(),
      title:     z.string().min(1).max(200).optional(),
      content:   z.string().optional(),
      published: z.boolean().optional(),
    }))
    .mutation(async ({ ctx, input }) => {
      const existing = await ctx.db.query.posts.findFirst({
        where: (p, { eq }) => eq(p.id, input.id),
      });

      if (!existing) throw new TRPCError({ code: 'NOT_FOUND' });
      if (existing.authorId !== ctx.user.id) throw new TRPCError({ code: 'FORBIDDEN' });

      const { id, ...data } = input;

      const [updated] = await ctx.db
        .update(posts)
        .set({ ...data, updatedAt: new Date() })
        .where(eq(posts.id, id))
        .returning();

      return updated;
    }),

  // Delete
  delete: protectedProcedure
    .input(z.object({ id: z.string().uuid() }))
    .mutation(async ({ ctx, input }) => {
      const existing = await ctx.db.query.posts.findFirst({
        where: (p, { eq }) => eq(p.id, input.id),
      });

      if (!existing) throw new TRPCError({ code: 'NOT_FOUND' });
      if (existing.authorId !== ctx.user.id) throw new TRPCError({ code: 'FORBIDDEN' });

      await ctx.db.delete(posts).where(eq(posts.id, input.id));
      return { success: true };
    }),
});
```

**Key Points:**

- `.returning()` retrieves the inserted or updated row — available in PostgreSQL and SQLite; not supported in MySQL as of this writing [Unverified: verify against your Drizzle and database versions]
- For updates, always set `updatedAt: new Date()` manually — Drizzle does not handle `@updatedAt` automatically the way Prisma does

---

### Transactions

```ts
import { db } from '../db';

transfer: protectedProcedure
  .input(z.object({
    fromId: z.string().uuid(),
    toId:   z.string().uuid(),
    amount: z.number().positive(),
  }))
  .mutation(async ({ ctx, input }) => {
    return ctx.db.transaction(async (tx) => {
      const [from] = await tx
        .select()
        .from(accounts)
        .where(eq(accounts.id, input.fromId));

      if (!from || from.balance < input.amount) {
        throw new TRPCError({
          code: 'BAD_REQUEST',
          message: 'Insufficient balance.',
        });
      }

      await tx
        .update(accounts)
        .set({ balance: from.balance - input.amount })
        .where(eq(accounts.id, input.fromId));

      await tx
        .update(accounts)
        .set({ balance: sql`${accounts.balance} + ${input.amount}` })
        .where(eq(accounts.id, input.toId));

      return { success: true };
    });
  }),
```

**Key Points:**

- `tx` inside `db.transaction()` is a scoped client — use it for all operations within the transaction
- Throwing inside the transaction callback triggers a rollback [Inference: standard transaction semantics; behavior may vary by database driver]
- `sql` tagged template literal allows raw SQL expressions inside otherwise typed queries

---

### Composable Where Conditions

Drizzle's `and`, `or`, `eq`, `like`, `between`, and other operators are composable functions, making dynamic filtering straightforward.

```ts
import { and, eq, ilike, gte, lte } from 'drizzle-orm';
import { posts } from '../db/schema';

search: publicProcedure
  .input(z.object({
    query:     z.string().optional(),
    authorId:  z.string().uuid().optional(),
    published: z.boolean().optional(),
    from:      z.string().datetime().optional(),
    to:        z.string().datetime().optional(),
  }))
  .query(async ({ ctx, input }) => {
    const conditions = [
      input.query     ? ilike(posts.title, `%${input.query}%`) : undefined,
      input.authorId  ? eq(posts.authorId, input.authorId)     : undefined,
      input.published !== undefined
                      ? eq(posts.published, input.published)   : undefined,
      input.from      ? gte(posts.createdAt, new Date(input.from)) : undefined,
      input.to        ? lte(posts.createdAt, new Date(input.to))   : undefined,
    ].filter(Boolean);

    return ctx.db
      .select()
      .from(posts)
      .where(conditions.length ? and(...conditions) : undefined)
      .orderBy(desc(posts.createdAt));
  }),
```

**Key Points:**

- Filtering `undefined` values before passing to `and()` cleanly handles optional filters without nested conditionals
- `ilike` is case-insensitive LIKE — PostgreSQL only; use `like` for SQLite and MySQL [Inference: verify against your database]

---

### Type Inference from Schema

Drizzle exports `InferSelectModel` and `InferInsertModel` to derive TypeScript types from table definitions.

```ts
import type { InferSelectModel, InferInsertModel } from 'drizzle-orm';
import { posts, users } from './schema';

export type Post   = InferSelectModel<typeof posts>;
export type NewPost = InferInsertModel<typeof posts>;
export type User   = InferSelectModel<typeof users>;
```

```ts
// Use in helper functions
function formatPost(post: Post) {
  return {
    ...post,
    excerpt: post.content?.slice(0, 160) ?? '',
  };
}
```

**Key Points:**

- `InferSelectModel` reflects the full row type including nullability from column definitions
- `InferInsertModel` reflects the insert shape — optional columns (those with defaults) become optional in the type

---

### Drizzle vs Prisma in tRPC Context

| Concern | Drizzle | Prisma |
| --- | --- | --- |
| Schema location | TypeScript file | `.prisma` file |
| Query style | SQL builder + relational API | Prisma query API |
| Type inference | From column definitions | From generated client |
| Migrations | `drizzle-kit generate` / `push` | `prisma migrate dev` |
| Bundle size | Smaller — no query engine binary | Larger — includes Rust query engine |
| `.returning()` MySQL support | Not supported [Unverified] | Handled internally |
| Relational queries | Requires `schema` passed to `drizzle()` | Always available |
| `updatedAt` auto-update | Manual | `@updatedAt` directive |

---

### Diagram: Schema to Query Flow

<svg viewBox="0 0 700 430" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="12">
<rect width="700" height="430" fill="#0f1117" rx="12"/>
<text x="350" y="34" text-anchor="middle" fill="#e2e8f0" font-size="15" font-weight="bold">Drizzle + tRPC Schema to Query Flow</text>
<!-- schema.ts -->
<rect x="30" y="70" width="150" height="54" rx="8" fill="#1e293b" stroke="#334155" stroke-width="1.5"/>
<text x="105" y="93" text-anchor="middle" fill="#94a3b8">schema.ts</text>
<text x="105" y="111" text-anchor="middle" fill="#64748b" font-size="10">pgTable · relations</text>
<!-- Arrow: schema to drizzle() -->
<line x1="180" y1="97" x2="240" y2="97" stroke="#475569" stroke-width="1.5" marker-end="url(#a1)"/>
<text x="210" y="89" text-anchor="middle" fill="#64748b" font-size="10">passed in</text>
<!-- drizzle() -->
<rect x="240" y="70" width="150" height="54" rx="8" fill="#1a2744" stroke="#3b82f6" stroke-width="1.5"/>
<text x="315" y="93" text-anchor="middle" fill="#93c5fd">drizzle(conn, schema)</text>
<text x="315" y="111" text-anchor="middle" fill="#64748b" font-size="10">typed db instance</text>
<!-- Arrow: drizzle to ctx -->
<line x1="315" y1="124" x2="315" y2="160" stroke="#475569" stroke-width="1.5" marker-end="url(#a1)"/>
<!-- ctx.db -->
<rect x="230" y="160" width="170" height="44" rx="8" fill="#1e293b" stroke="#334155" stroke-width="1.5"/>
<text x="315" y="180" text-anchor="middle" fill="#94a3b8">ctx.db</text>
<text x="315" y="196" text-anchor="middle" fill="#64748b" font-size="10">available in all procedures</text>
<!-- Arrow down -->
<line x1="315" y1="204" x2="315" y2="240" stroke="#475569" stroke-width="1.5" marker-end="url(#a1)"/>
<!-- Two branches -->
<!-- SQL Builder -->
<line x1="315" y1="240" x2="180" y2="270" stroke="#475569" stroke-width="1.5" marker-end="url(#a1)"/>
<!-- Relational API -->
<line x1="315" y1="240" x2="450" y2="270" stroke="#475569" stroke-width="1.5" marker-end="url(#a1)"/>
<!-- SQL Builder box -->
<rect x="60" y="270" width="160" height="54" rx="8" fill="#1a2744" stroke="#3b82f6" stroke-width="1.5"/>
<text x="140" y="293" text-anchor="middle" fill="#93c5fd">SQL Builder</text>
<text x="140" y="311" text-anchor="middle" fill="#64748b" font-size="10">.select().from().where()</text>
<!-- Relational API box -->
<rect x="380" y="270" width="180" height="54" rx="8" fill="#1a2744" stroke="#3b82f6" stroke-width="1.5"/>
<text x="470" y="293" text-anchor="middle" fill="#93c5fd">Relational API</text>
<text x="470" y="311" text-anchor="middle" fill="#64748b" font-size="10">db.query.posts.findMany()</text>
<!-- Both to SQL generation -->
<line x1="140" y1="324" x2="270" y2="370" stroke="#3b82f6" stroke-width="1.5" marker-end="url(#ablue)"/>
<line x1="470" y1="324" x2="360" y2="370" stroke="#3b82f6" stroke-width="1.5" marker-end="url(#ablue)"/>
<!-- SQL Generation -->
<rect x="220" y="370" width="180" height="44" rx="8" fill="#14532d" stroke="#22c55e" stroke-width="1.5"/>
<text x="310" y="390" text-anchor="middle" fill="#86efac">SQL Generation</text>
<text x="310" y="408" text-anchor="middle" fill="#86efac" font-size="10">→ typed result rows</text>
<!-- drizzle-kit -->
<rect x="460" y="70" width="180" height="54" rx="8" fill="#1e293b" stroke="#334155" stroke-width="1.5"/>
<text x="550" y="93" text-anchor="middle" fill="#94a3b8">drizzle-kit</text>
<text x="550" y="111" text-anchor="middle" fill="#64748b" font-size="10">generate · push · migrate</text>
<!-- Arrow schema to drizzle-kit -->
<line x1="180" y1="110" x2="460" y2="110" stroke="#334155" stroke-width="1.2" stroke-dasharray="4,3"/>
<text x="320" y="128" text-anchor="middle" fill="#475569" font-size="10">reads schema for migrations</text>
<defs>
<marker id="a1" markerWidth="8" markerHeight="8" refX="4" refY="4" orient="auto">
<path d="M0,0 L8,4 L0,8 Z" fill="#475569"/>
</marker>
<marker id="ablue" markerWidth="8" markerHeight="8" refX="4" refY="4" orient="auto">
<path d="M0,0 L8,4 L0,8 Z" fill="#3b82f6"/>
</marker>
</defs>
</svg>

---

### Common Mistakes

| Mistake | Problem | Fix |
| --- | --- | --- |
| Forgetting `schema` in `drizzle()` | `db.query.*` is undefined at runtime | Pass `schema` as second argument to `drizzle()` |
| Using `db.query.*` without `relations()` | Relations not resolved | Define `relations()` in schema and pass schema to `drizzle()` |
| Omitting `.returning()` after insert | Result is empty array | Chain `.returning()` for PostgreSQL/SQLite; query separately for MySQL |
| Not setting `updatedAt` on update | Stale timestamp | Set `updatedAt: new Date()` explicitly in `.set()` |
| Raw string interpolation in `sql` tag | SQL injection risk | Always use parameterized values via the `sql` tag, never string concatenation |

---

**Next Steps:** Handling file uploads in tRPC — patterns for multipart form data, presigned URL generation, and integrating with storage providers.