## Using Kysely with tRPC

Kysely is a type-safe SQL query builder for TypeScript. Unlike Prisma or Drizzle, it does not generate a schema from a definition file or provide an ORM abstraction layer — it builds SQL queries directly, with types derived from a database interface you define manually or generate from an existing database. In tRPC applications, Kysely occupies the same position as other data layers: instantiated once, passed through context, used inside procedures.

---

### Prerequisites and Setup

```bash
npm install kysely @trpc/server @trpc/client @trpc/next zod
```

Install the appropriate dialect driver:

```bash
 PostgreSQL
npm install pg
npm install -D @types/pg

 MySQL
npm install mysql2

 SQLite
npm install better-sqlite3
npm install -D @types/better-sqlite3
```

---

### Defining the Database Interface

Kysely requires a TypeScript interface that maps table names to their row types. This is the sole source of type information — Kysely derives all query types from it.

```ts
// server/db/types.ts
import type { Generated, Insertable, Selectable, Updateable } from 'kysely';

export interface UserTable {
  id:         Generated<string>;
  email:      string;
  name:       string | null;
  role:       'user' | 'admin';
  created_at: Generated<Date>;
  updated_at: Generated<Date>;
}

export interface PostTable {
  id:         Generated<string>;
  title:      string;
  content:    string | null;
  published:  Generated<boolean>;
  author_id:  string;
  created_at: Generated<Date>;
  updated_at: Generated<Date>;
}

// Root database interface — table name maps to row type
export interface Database {
  users: UserTable;
  posts: PostTable;
}

// Convenience types for each table
export type User       = Selectable<UserTable>;
export type NewUser    = Insertable<UserTable>;
export type UserUpdate = Updateable<UserTable>;

export type Post       = Selectable<PostTable>;
export type NewPost    = Insertable<PostTable>;
export type PostUpdate = Updateable<PostTable>;
```

**Key Points:**

- `Generated<T>` marks columns that the database populates automatically (primary keys, defaults, timestamps) — they become optional on insert
- `Selectable<T>` removes `Generated` wrappers; `Insertable<T>` makes generated columns optional; `Updateable<T>` makes all columns optional
- The `Database` interface is the single argument to `Kysely<Database>` — all type inference flows from it
- These types must be kept in sync with the actual database schema manually, or generated using a tool (see below)

---

### Generating Types from an Existing Database

Rather than writing types manually, `kysely-codegen` can introspect a live database and generate the interface.

```bash
npm install -D kysely-codegen

 Generate from a PostgreSQL database
npx kysely-codegen --dialect=postgres --url=$DATABASE_URL --out-file=server/db/types.ts
```

**Key Points:**

- `kysely-codegen` reflects the actual database state, not a schema file — useful when the database already exists [Inference]
- Re-run after every migration to keep types current
- Generated output may need manual adjustment for enums or custom types [Inference]

---

### Instantiating Kysely

```ts
// server/db/index.ts
import { Kysely, PostgresDialect } from 'kysely';
import { Pool } from 'pg';
import type { Database } from './types';

const globalForDb = globalThis as unknown as {
  db: Kysely<Database> | undefined;
};

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  max: 10,
});

export const db: Kysely<Database> =
  globalForDb.db ?? new Kysely<Database>({
    dialect: new PostgresDialect({ pool }),
    log: process.env.NODE_ENV === 'development'
      ? ['query', 'error']
      : ['error'],
  });

if (process.env.NODE_ENV !== 'production') {
  globalForDb.db = db;
}
```

For SQLite:

```ts
// server/db/index.ts (SQLite)
import { Kysely, SqliteDialect } from 'kysely';
import Database from 'better-sqlite3';
import type { Database as DB } from './types';

const sqlite = new Database('local.db');

export const db = new Kysely<DB>({
  dialect: new SqliteDialect({ database: sqlite }),
});
```

For MySQL:

```ts
// server/db/index.ts (MySQL)
import { Kysely, MysqlDialect } from 'kysely';
import { createPool } from 'mysql2';
import type { Database } from './types';

const pool = createPool({ uri: process.env.DATABASE_URL });

export const db = new Kysely<Database>({
  dialect: new MysqlDialect({ pool }),
});
```

**Key Points:**

- The `globalThis` singleton prevents connection pool exhaustion during Next.js hot reload [Inference: same rationale as Prisma and Drizzle patterns]
- `log: ['query', 'error']` in development prints generated SQL — useful for inspecting query shape

---

### Passing Kysely Through tRPC Context

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

### Query Syntax Overview

Kysely maps closely to SQL. Every clause has a corresponding method.

```ts
import { sql } from 'kysely';

// SELECT with WHERE, JOIN, ORDER BY, LIMIT
const posts = await ctx.db
  .selectFrom('posts')
  .innerJoin('users', 'users.id', 'posts.author_id')
  .select([
    'posts.id',
    'posts.title',
    'posts.created_at',
    'users.name as author_name',
  ])
  .where('posts.published', '=', true)
  .orderBy('posts.created_at', 'desc')
  .limit(20)
  .execute();

// INSERT
const inserted = await ctx.db
  .insertInto('posts')
  .values({
    title:     'Hello',
    content:   'World',
    author_id: ctx.user.id,
    published: false,
  })
  .returningAll()  // PostgreSQL / SQLite
  .executeTakeFirstOrThrow();

// UPDATE
const updated = await ctx.db
  .updateTable('posts')
  .set({ title: 'Updated', updated_at: new Date() })
  .where('id', '=', input.id)
  .returningAll()
  .executeTakeFirstOrThrow();

// DELETE
await ctx.db
  .deleteFrom('posts')
  .where('id', '=', input.id)
  .execute();
```

**Key Points:**

- `.execute()` returns an array; `.executeTakeFirst()` returns the first row or `undefined`; `.executeTakeFirstOrThrow()` throws if no row is found
- `.returningAll()` is PostgreSQL and SQLite only — MySQL does not support `RETURNING` [Inference: verify against your database and Kysely version]
- Column names in Kysely follow your database schema naming convention (typically `snake_case`) rather than JavaScript conventions

---

### Basic CRUD Procedures

```ts
// server/routers/post.ts
import { router, publicProcedure, protectedProcedure } from '../trpc';
import { z } from 'zod';
import { TRPCError } from '@trpc/server';

export const postRouter = router({
  // List
  list: publicProcedure
    .input(z.object({
      limit:  z.number().min(1).max(100).default(20),
      cursor: z.string().uuid().optional(),
    }))
    .query(async ({ ctx, input }) => {
      let query = ctx.db
        .selectFrom('posts')
        .innerJoin('users', 'users.id', 'posts.author_id')
        .select([
          'posts.id',
          'posts.title',
          'posts.created_at',
          'users.id as author_id',
          'users.name as author_name',
        ])
        .where('posts.published', '=', true)
        .orderBy('posts.created_at', 'desc')
        .limit(input.limit + 1);

      if (input.cursor) {
        query = query.where('posts.id', '<', input.cursor);
      }

      const rows = await query.execute();

      let nextCursor: string | undefined;
      if (rows.length > input.limit) {
        nextCursor = rows.pop()?.id;
      }

      return { posts: rows, nextCursor };
    }),

  // Single
  byId: publicProcedure
    .input(z.object({ id: z.string().uuid() }))
    .query(async ({ ctx, input }) => {
      const post = await ctx.db
        .selectFrom('posts')
        .innerJoin('users', 'users.id', 'posts.author_id')
        .select([
          'posts.id',
          'posts.title',
          'posts.content',
          'posts.published',
          'posts.created_at',
          'users.id as author_id',
          'users.name as author_name',
        ])
        .where('posts.id', '=', input.id)
        .executeTakeFirst();

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
      return ctx.db
        .insertInto('posts')
        .values({
          title:     input.title,
          content:   input.content ?? null,
          author_id: ctx.user.id,
        })
        .returningAll()
        .executeTakeFirstOrThrow();
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
      const existing = await ctx.db
        .selectFrom('posts')
        .select(['id', 'author_id'])
        .where('id', '=', input.id)
        .executeTakeFirst();

      if (!existing) throw new TRPCError({ code: 'NOT_FOUND' });
      if (existing.author_id !== ctx.user.id) throw new TRPCError({ code: 'FORBIDDEN' });

      const { id, ...data } = input;

      return ctx.db
        .updateTable('posts')
        .set({ ...data, updated_at: new Date() })
        .where('id', '=', id)
        .returningAll()
        .executeTakeFirstOrThrow();
    }),

  // Delete
  delete: protectedProcedure
    .input(z.object({ id: z.string().uuid() }))
    .mutation(async ({ ctx, input }) => {
      const existing = await ctx.db
        .selectFrom('posts')
        .select(['id', 'author_id'])
        .where('id', '=', input.id)
        .executeTakeFirst();

      if (!existing) throw new TRPCError({ code: 'NOT_FOUND' });
      if (existing.author_id !== ctx.user.id) throw new TRPCError({ code: 'FORBIDDEN' });

      await ctx.db
        .deleteFrom('posts')
        .where('id', '=', input.id)
        .execute();

      return { success: true };
    }),
});
```

---

### Transactions

```ts
transfer: protectedProcedure
  .input(z.object({
    fromId: z.string().uuid(),
    toId:   z.string().uuid(),
    amount: z.number().positive(),
  }))
  .mutation(async ({ ctx, input }) => {
    return ctx.db.transaction().execute(async (trx) => {
      const from = await trx
        .selectFrom('accounts')
        .select(['id', 'balance'])
        .where('id', '=', input.fromId)
        .executeTakeFirst();

      if (!from || from.balance < input.amount) {
        throw new TRPCError({
          code: 'BAD_REQUEST',
          message: 'Insufficient balance.',
        });
      }

      await trx
        .updateTable('accounts')
        .set({ balance: from.balance - input.amount })
        .where('id', '=', input.fromId)
        .execute();

      await trx
        .updateTable('accounts')
        .set((eb) => ({
          balance: eb('balance', '+', input.amount),
        }))
        .where('id', '=', input.toId)
        .execute();

      return { success: true };
    });
  }),
```

**Key Points:**

- `ctx.db.transaction().execute(async (trx) => { ... })` wraps the callback in a transaction — `trx` is the scoped client
- Throwing inside the callback rolls back the transaction [Inference: standard database transaction semantics]
- `eb('balance', '+', input.amount)` uses Kysely's expression builder for atomic arithmetic — avoids a read-modify-write race condition compared to computing the value in JavaScript

---

### Dynamic Filtering with Expression Builder

Kysely's expression builder (`eb`) enables composable, type-safe dynamic conditions.

```ts
search: publicProcedure
  .input(z.object({
    query:     z.string().optional(),
    authorId:  z.string().uuid().optional(),
    published: z.boolean().optional(),
    from:      z.string().datetime().optional(),
    to:        z.string().datetime().optional(),
  }))
  .query(async ({ ctx, input }) => {
    return ctx.db
      .selectFrom('posts')
      .selectAll()
      .where((eb) => {
        const conditions = [
          input.query
            ? eb('title', 'ilike', `%${input.query}%`)
            : null,
          input.authorId
            ? eb('author_id', '=', input.authorId)
            : null,
          input.published !== undefined
            ? eb('published', '=', input.published)
            : null,
          input.from
            ? eb('created_at', '>=', new Date(input.from))
            : null,
          input.to
            ? eb('created_at', '<=', new Date(input.to))
            : null,
        ].filter((c): c is NonNullable<typeof c> => c !== null);

        return conditions.length
          ? eb.and(conditions)
          : eb.val(true);
      })
      .orderBy('created_at', 'desc')
      .execute();
  }),
```

**Key Points:**

- `eb.and(conditions)` combines conditions with `AND`; `eb.or(conditions)` with `OR`
- `eb.val(true)` is a safe no-op condition when no filters are active — it avoids an empty `WHERE` clause [Inference: verify behavior with your Kysely version]
- The type predicate `(c): c is NonNullable<typeof c>` removes `null` from the array type, allowing TypeScript to accept `conditions` without widening to include null

---

### Raw SQL with the `sql` Tag

For database-specific expressions or functions not covered by the builder API:

```ts
import { sql } from 'kysely';

// Full-text search (PostgreSQL)
const results = await ctx.db
  .selectFrom('posts')
  .selectAll()
  .where(
    sql<boolean>`to_tsvector('english', title) @@ plainto_tsquery('english', ${input.query})`
  )
  .execute();

// JSON column access
const rows = await ctx.db
  .selectFrom('events')
  .select([
    'id',
    sql<string>`metadata->>'type'`.as('event_type'),
  ])
  .execute();
```

**Key Points:**

- The `sql` tag is parameterized — interpolated values are passed as query parameters, not interpolated as raw strings, so they are safe from SQL injection [Inference: based on Kysely's documented parameterization behavior; verify]
- The generic type argument on `sql<T>` tells TypeScript what type to assign to the expression's result — it is not validated at runtime

---

### Reusable Query Fragments

Repeated query segments can be extracted into functions to reduce duplication.

```ts
// server/db/queries.ts
import type { Kysely } from 'kysely';
import type { Database } from './types';

export function selectPublishedPostsWithAuthor(db: Kysely<Database>) {
  return db
    .selectFrom('posts')
    .innerJoin('users', 'users.id', 'posts.author_id')
    .select([
      'posts.id',
      'posts.title',
      'posts.created_at',
      'users.name as author_name',
    ])
    .where('posts.published', '=', true);
}
```

```ts
// In procedures — extend the base query
const posts = await selectPublishedPostsWithAuthor(ctx.db)
  .orderBy('posts.created_at', 'desc')
  .limit(20)
  .execute();
```

**Key Points:**

- Kysely queries are composable — you can chain additional clauses onto a base query returned from a function [Inference: depends on Kysely's query builder immutability guarantees; verify]
- Passing `db` as an argument (rather than importing it directly) allows the fragment to work inside transactions by passing `trx` instead

---

### Kysely vs Drizzle vs Prisma in tRPC Context

| Concern | Kysely | Drizzle | Prisma |
| --- | --- | --- | --- |
| Type source | Manual interface or codegen | TypeScript schema file | `.prisma` schema file |
| Query style | SQL builder only | SQL builder + relational API | Proprietary query API |
| Schema management | External (migrations handled separately) | `drizzle-kit` | `prisma migrate` |
| Relational queries | Manual joins | `db.query.*` with `with:` | `include:` / `select:` |
| Raw SQL | `sql` tag | `sql` tag | `$queryRaw` |
| Bundle size | Small — no runtime binary | Small | Larger — Rust query engine |
| `.returning()` MySQL | Not supported [Unverified] | Not supported [Unverified] | Handled internally |
| Type drift risk | High — manual interface | Low — schema is types | None — generated client |

---

### Diagram: Kysely Query Flow

<svg viewBox="0 0 700 420" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="12">
<rect width="700" height="420" fill="#0f1117" rx="12"/>
<text x="350" y="34" text-anchor="middle" fill="#e2e8f0" font-size="15" font-weight="bold">Kysely + tRPC Query Flow</text>
<!-- Database Interface -->
<rect x="30" y="70" width="170" height="54" rx="8" fill="#1e293b" stroke="#334155" stroke-width="1.5"/>
<text x="115" y="93" text-anchor="middle" fill="#94a3b8">Database Interface</text>
<text x="115" y="111" text-anchor="middle" fill="#64748b" font-size="10">{ users: UserTable, posts: … }</text>
<!-- Arrow to Kysely -->
<line x1="200" y1="97" x2="260" y2="97" stroke="#475569" stroke-width="1.5" marker-end="url(#a1)"/>
<text x="230" y="88" text-anchor="middle" fill="#64748b" font-size="10">generic arg</text>
<!-- Kysely<Database> -->
<rect x="260" y="70" width="170" height="54" rx="8" fill="#1a2744" stroke="#3b82f6" stroke-width="1.5"/>
<text x="345" y="93" text-anchor="middle" fill="#93c5fd">Kysely&lt;Database&gt;</text>
<text x="345" y="111" text-anchor="middle" fill="#64748b" font-size="10">dialect + pool + logger</text>
<!-- Arrow to ctx -->
<line x1="345" y1="124" x2="345" y2="160" stroke="#475569" stroke-width="1.5" marker-end="url(#a1)"/>
<!-- ctx.db -->
<rect x="260" y="160" width="170" height="44" rx="8" fill="#1e293b" stroke="#334155" stroke-width="1.5"/>
<text x="345" y="180" text-anchor="middle" fill="#94a3b8">ctx.db</text>
<text x="345" y="196" text-anchor="middle" fill="#64748b" font-size="10">passed via createContext()</text>
<!-- Arrow down to builder -->
<line x1="345" y1="204" x2="345" y2="240" stroke="#475569" stroke-width="1.5" marker-end="url(#a1)"/>
<!-- Query Builder -->
<rect x="235" y="240" width="220" height="64" rx="8" fill="#1a2744" stroke="#3b82f6" stroke-width="1.5"/>
<text x="345" y="263" text-anchor="middle" fill="#93c5fd">Query Builder</text>
<text x="345" y="280" text-anchor="middle" fill="#64748b" font-size="10">.selectFrom().where().orderBy()</text>
<text x="345" y="296" text-anchor="middle" fill="#64748b" font-size="10">.execute() / .executeTakeFirst()</text>
<!-- Arrow to SQL -->
<line x1="345" y1="304" x2="345" y2="340" stroke="#3b82f6" stroke-width="1.5" marker-end="url(#ablue)"/>
<!-- SQL Output -->
<rect x="245" y="340" width="200" height="44" rx="8" fill="#14532d" stroke="#22c55e" stroke-width="1.5"/>
<text x="345" y="360" text-anchor="middle" fill="#86efac">Parameterized SQL</text>
<text x="345" y="376" text-anchor="middle" fill="#86efac" font-size="10">→ typed result rows</text>
<!-- Arrow to DB -->
<line x1="445" y1="362" x2="520" y2="362" stroke="#22c55e" stroke-width="1.5" marker-end="url(#agreen)"/>
<!-- Database -->
<rect x="520" y="330" width="150" height="80" rx="8" fill="#1e293b" stroke="#334155" stroke-width="1.5"/>
<text x="595" y="358" text-anchor="middle" fill="#94a3b8">Database</text>
<text x="595" y="376" text-anchor="middle" fill="#64748b" font-size="10">pg / mysql2</text>
<text x="595" y="392" text-anchor="middle" fill="#64748b" font-size="10">better-sqlite3</text>
<!-- codegen -->
<rect x="460" y="70" width="180" height="54" rx="8" fill="#1e293b" stroke="#334155" stroke-width="1.5"/>
<text x="550" y="93" text-anchor="middle" fill="#94a3b8">kysely-codegen</text>
<text x="550" y="111" text-anchor="middle" fill="#64748b" font-size="10">introspects DB → generates types</text>
<!-- Arrow codegen to interface -->
<line x1="460" y1="97" x2="200" y2="97" stroke="#334155" stroke-width="1.2" stroke-dasharray="4,3"/>
<text x="340" y="130" text-anchor="middle" fill="#475569" font-size="10">optional: generates Database interface</text>
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

### Common Mistakes

| Mistake | Problem | Fix |
| --- | --- | --- |
| Manually typing query results | Types drift from actual rows | Use `Selectable<T>`, let Kysely infer return types |
| Using `.execute()` expecting one row | Returns array; first element may be undefined | Use `.executeTakeFirst()` or `.executeTakeFirstOrThrow()` |
| String interpolation inside `sql` tag | SQL injection risk | Always interpolate values as template expressions — never concatenate strings |
| Forgetting `updated_at` on updates | Stale timestamp | Set `updated_at: new Date()` explicitly in `.set()` |
| Not re-running codegen after migration | Type interface drifts from schema | Run `kysely-codegen` as part of the migration step |
| Passing `db` instead of `trx` in transactions | Queries execute outside the transaction | Always use the `trx` argument inside `transaction().execute()` |

---

**Next Steps:** Handling file uploads in tRPC — patterns for multipart form data, presigned URL generation, and integrating with cloud storage providers.