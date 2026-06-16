## Prisma ORM Integration

Prisma is a TypeScript-first ORM for Node.js that consists of three distinct tools: a schema language for defining your data model, a migration system for evolving your database schema, and a generated, type-safe client for querying. In Fastify, Prisma is integrated as a decorated plugin instance, similar to Knex — there is no official `@fastify/prisma` scoped plugin.

---

### What Prisma Provides

| Component | Description |
| --- | --- |
| Prisma Schema | Declarative `.prisma` file defining models, relations, and DB connection |
| Prisma Migrate | Migration engine that generates and applies SQL migration files |
| Prisma Client | Auto-generated, fully typed query client derived from the schema |
| Prisma Studio | GUI for browsing and editing database records (development tool) |
| Prisma Introspect | Generates a schema from an existing database |

**Key Points:**

- Prisma Client is generated at build time from your schema — it is not a generic runtime library but a schema-specific artifact
- The generated client includes TypeScript types for every model, relation, and query result — no manual interface declarations required
- Prisma supports PostgreSQL, MySQL, SQLite, SQL Server, MongoDB, and CockroachDB [Unverified: verify current dialect support against Prisma documentation for your version]

---

### Installation

bash

```bash
npm install prisma --save-dev
npm install @prisma/client
```

Initialize Prisma in the project:

bash

```bash
npx prisma init
```

This creates:

- `prisma/schema.prisma` — the schema file
- `.env` with a `DATABASE_URL` placeholder

---

### The Prisma Schema

The schema file is the single source of truth for your data model. Prisma reads it to generate the client and produce migrations.

prisma

```prisma
// prisma/schema.prisma

generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

model User {
  id        Int       @id @default(autoincrement())
  name      String
  email     String    @unique
  createdAt DateTime  @default(now())
  updatedAt DateTime  @updatedAt
  posts     Post[]
}

model Post {
  id        Int      @id @default(autoincrement())
  title     String
  body      String
  published Boolean  @default(false)
  author    User     @relation(fields: [authorId], references: [id])
  authorId  Int
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt
}
```

**Key Points:**

- `@id` marks the primary key; `@default(autoincrement())` generates sequential integer IDs
- `@unique` enforces a unique constraint at the database level
- `@updatedAt` is managed by Prisma — it automatically sets the field to the current timestamp on every update [Inference: based on Prisma documentation; the mechanism differs by database adapter]
- Relations are declared on both sides: `Post` holds the foreign key (`authorId`), `User` holds the virtual `posts` array
- Field names use camelCase in the schema; Prisma maps these to the database column naming convention automatically [Inference: mapping behavior depends on database and configuration]

---

### Generating Prisma Client

After creating or modifying the schema:

bash

```bash
npx prisma generate
```

This writes the generated client to `node_modules/@prisma/client`. The client is schema-specific — regenerate it whenever the schema changes.

**Key Points:**

- `prisma generate` must be run after every schema change, including in CI/CD pipelines
- The generated client is not checked into source control — it is produced from the schema during build [Inference: this is the conventional approach; some teams differ]
- In Docker builds, `prisma generate` is typically run as part of the image build step

---

### Migrations

Prisma Migrate compares the current schema to the database state and generates SQL migration files.

**Create and apply a migration:**

bash

```bash
npx prisma migrate dev --name create_users_and_posts
```

This:

1. Generates a SQL migration file in `prisma/migrations/`
2. Applies the migration to the development database
3. Runs `prisma generate` automatically

**Apply migrations in production:**

bash

```bash
npx prisma migrate deploy
```

`migrate deploy` applies pending migrations without generating new ones — safe for production use. It does not prompt interactively.

**Key Points:**

- Migration files are SQL and should be committed to version control
- `migrate dev` is for development only — it may reset the database in some conflict scenarios [Inference: behavior depends on migration history and schema divergence]
- `migrate deploy` is idempotent — it tracks applied migrations in the `_prisma_migrations` table
- Never edit generated migration files manually unless you understand the consequences for migration history [Inference]

---

### Integrating Prisma Client as a Fastify Plugin

typescript

```typescript
// plugins/prisma.ts
import fp from 'fastify-plugin'
import { PrismaClient } from '@prisma/client'
import type { FastifyPluginAsync } from 'fastify'

declare module 'fastify' {
  interface FastifyInstance {
    prisma: PrismaClient
  }
}

const prismaPlugin: FastifyPluginAsync = async (fastify) => {
  const prisma = new PrismaClient({
    log: process.env.NODE_ENV === 'development'
      ? ['query', 'info', 'warn', 'error']
      : ['warn', 'error']
  })

  await prisma.$connect()

  fastify.decorate('prisma', prisma)

  fastify.addHook('onClose', async () => {
    await prisma.$disconnect()
  })
}

export default fp(prismaPlugin)
```

**Registration:**

typescript

```typescript
// app.ts
import Fastify from 'fastify'
import prismaPlugin from './plugins/prisma'

const fastify = Fastify({ logger: true })

await fastify.register(prismaPlugin)
await fastify.listen({ port: 3000 })
```

**Key Points:**

- `prisma.$connect()` on startup establishes the connection pool eagerly — if the database is unreachable, startup fails immediately rather than on the first query [Inference: Prisma may lazily connect on first query if `$connect()` is omitted; verify against current Prisma version]
- `prisma.$disconnect()` in `onClose` drains the connection pool on Fastify shutdown
- `fp()` breaks encapsulation so `fastify.prisma` is accessible in all routes and child plugins
- The `log` option controls Prisma's internal query logging; `'query'` logs all generated SQL — useful in development, avoid in production due to volume

---

### Basic CRUD Operations

#### Find Many

typescript

```typescript
fastify.get('/users', async () => {
  return fastify.prisma.user.findMany({
    select: {
      id: true,
      name: true,
      email: true,
      createdAt: true
    },
    orderBy: { createdAt: 'desc' }
  })
})
```

#### Find One

typescript

```typescript
fastify.get('/users/:id', async (request, reply) => {
  const { id } = request.params as { id: string }

  const user = await fastify.prisma.user.findUnique({
    where: { id: parseInt(id, 10) }
  })

  if (!user) return reply.code(404).send({ error: 'Not found' })
  return user
})
```

**Key Points:**

- `findUnique` queries by a unique field (`@id` or `@unique`) — it returns `null` if not found, never throws
- `findFirst` finds the first match by any condition; `findMany` returns all matches as an array
- `select` limits which fields are returned — unlisted fields are excluded from the result type as well as the SQL projection [Inference: TypeScript type narrows to selected fields; verify behavior for nested relations]

#### Create

typescript

```typescript
fastify.post('/users', async (request, reply) => {
  const { name, email } = request.body as { name: string; email: string }

  const user = await fastify.prisma.user.create({
    data: { name, email }
  })

  return reply.code(201).send(user)
})
```

#### Update

typescript

```typescript
fastify.put('/users/:id', async (request, reply) => {
  const { id } = request.params as { id: string }
  const { name, email } = request.body as { name: string; email: string }

  try {
    const user = await fastify.prisma.user.update({
      where: { id: parseInt(id, 10) },
      data: { name, email }
    })
    return user
  } catch (err: any) {
    if (err.code === 'P2025') {
      return reply.code(404).send({ error: 'Not found' })
    }
    throw err
  }
})
```

**Key Points:**

- `update` throws a `PrismaClientKnownRequestError` with code `P2025` when the record does not exist — unlike `findUnique`, it does not return `null`
- Always handle `P2025` on `update` and `delete` operations to avoid unhandled 500 errors reaching the client

#### Delete

typescript

```typescript
fastify.delete('/users/:id', async (request, reply) => {
  const { id } = request.params as { id: string }

  try {
    await fastify.prisma.user.delete({
      where: { id: parseInt(id, 10) }
    })
    return reply.code(204).send()
  } catch (err: any) {
    if (err.code === 'P2025') {
      return reply.code(404).send({ error: 'Not found' })
    }
    throw err
  }
})
```

---

### Relations and Nested Queries

Prisma's relation API is one of its primary differentiators from query builders. Related data is included or created in the same query.

#### Include Related Records

typescript

```typescript
fastify.get('/users/:id', async (request, reply) => {
  const { id } = request.params as { id: string }

  const user = await fastify.prisma.user.findUnique({
    where: { id: parseInt(id, 10) },
    include: {
      posts: {
        where: { published: true },
        orderBy: { createdAt: 'desc' },
        take: 10
      }
    }
  })

  if (!user) return reply.code(404).send({ error: 'Not found' })
  return user
})
```

**Key Points:**

- `include` performs a JOIN (or separate query, depending on the relation type and adapter) and nests the result [Inference: Prisma's query strategy varies by relation cardinality and database; inspect generated SQL when performance is a concern]
- `include` and `select` cannot be used at the top level simultaneously — use `select` with nested `select`/`include` for fine-grained control

#### Nested Create

typescript

```typescript
fastify.post('/users', async (request, reply) => {
  const { name, email, posts } = request.body as {
    name: string
    email: string
    posts?: { title: string; body: string }[]
  }

  const user = await fastify.prisma.user.create({
    data: {
      name,
      email,
      posts: {
        create: posts ?? []
      }
    },
    include: { posts: true }
  })

  return reply.code(201).send(user)
})
```

**Key Points:**

- Nested `create` within a parent `create` runs within the same transaction — either both succeed or neither does [Inference: based on Prisma documentation; verify transactional guarantees for your database adapter]
- The returned object includes the created posts because `include: { posts: true }` is specified

---

### Transactions

#### Sequential Operations (`$transaction` array form)

typescript

```typescript
fastify.post('/transfer', async (request) => {
  const { fromId, toId, amount } = request.body as {
    fromId: number
    toId: number
    amount: number
  }

  const [debit, credit] = await fastify.prisma.$transaction([
    fastify.prisma.account.update({
      where: { id: fromId },
      data: { balance: { decrement: amount } }
    }),
    fastify.prisma.account.update({
      where: { id: toId },
      data: { balance: { increment: amount } }
    })
  ])

  return { debit, credit }
})
```

#### Interactive Transactions (Callback Form)

For transactions where later queries depend on earlier results:

typescript

```typescript
fastify.post('/transfer', async (request, reply) => {
  const { fromId, toId, amount } = request.body as {
    fromId: number
    toId: number
    amount: number
  }

  const result = await fastify.prisma.$transaction(async (trx) => {
    const from = await trx.account.findUnique({ where: { id: fromId } })

    if (!from || from.balance < amount) {
      throw new Error('Insufficient funds')
    }

    const debit = await trx.account.update({
      where: { id: fromId },
      data: { balance: { decrement: amount } }
    })

    const credit = await trx.account.update({
      where: { id: toId },
      data: { balance: { increment: amount } }
    })

    return { debit, credit }
  })

  return result
})
```

**Key Points:**

- In the array form, all operations are submitted together — no interleaving is possible
- In the callback form, `trx` is a transaction-scoped Prisma client — all operations inside use the same database transaction
- Throwing inside the callback triggers automatic rollback [Inference: based on Prisma documentation; behavior may vary in edge cases such as unhandled promise rejections]
- Interactive transactions hold a database connection for their duration — long-running transactions reduce pool availability [Inference]

---

### Mermaid: Prisma Request Flow in Fastify

DatabaseQueryEnginePrismaClientFastifyClientDatabaseQueryEnginePrismaClientFastifyClientHTTP Requestprisma.user.findUnique(...)DMMF query planParameterized SQLRaw result rowsTyped result objectUser | nullJSON Response

---

### Filtering, Pagination, and Sorting

typescript

```typescript
fastify.get('/posts', async (request) => {
  const {
    search,
    published,
    page = '1',
    limit = '20',
    sortBy = 'createdAt',
    order = 'desc'
  } = request.query as {
    search?: string
    published?: string
    page?: string
    limit?: string
    sortBy?: string
    order?: 'asc' | 'desc'
  }

  const pageNum = Math.max(1, parseInt(page, 10))
  const limitNum = Math.min(100, parseInt(limit, 10))

  const [posts, total] = await fastify.prisma.$transaction([
    fastify.prisma.post.findMany({
      where: {
        ...(published !== undefined && { published: published === 'true' }),
        ...(search && {
          OR: [
            { title: { contains: search, mode: 'insensitive' } },
            { body:  { contains: search, mode: 'insensitive' } }
          ]
        })
      },
      orderBy: { [sortBy]: order },
      skip: (pageNum - 1) * limitNum,
      take: limitNum,
      include: { author: { select: { id: true, name: true } } }
    }),
    fastify.prisma.post.count({
      where: {
        ...(published !== undefined && { published: published === 'true' })
      }
    })
  ])

  return {
    data: posts,
    pagination: {
      page: pageNum,
      limit: limitNum,
      total,
      pages: Math.ceil(total / limitNum)
    }
  }
})
```

**Key Points:**

- `mode: 'insensitive'` on `contains` generates a case-insensitive query; this is PostgreSQL-specific [Inference: verify support for your database adapter]
- Running `findMany` and `count` in a `$transaction` array executes them in the same transaction, avoiding a TOCTOU inconsistency between the list and total count [Inference]
- `skip` and `take` map to SQL `OFFSET` and `LIMIT`

---

### Common Prisma Error Codes

| Code | Meaning | Common Cause |
| --- | --- | --- |
| `P2002` | Unique constraint violation | Duplicate email, username, etc. |
| `P2003` | Foreign key constraint violation | Referencing non-existent related record |
| `P2025` | Record not found | `update` or `delete` on missing row |
| `P2014` | Relation violation | Required relation not satisfied |
| `P1001` | Cannot reach database | Connection failure |
| `P1008` | Operation timed out | Slow query or pool exhaustion |

**Centralised error handling:**

typescript

```typescript
fastify.setErrorHandler((err, request, reply) => {
  if (err.code === 'P2002') {
    return reply.code(409).send({
      error: 'Conflict',
      message: 'A record with this value already exists'
    })
  }
  if (err.code === 'P2025') {
    return reply.code(404).send({
      error: 'Not Found',
      message: 'Record does not exist'
    })
  }

  fastify.log.error(err)
  return reply.code(500).send({ error: 'Internal Server Error' })
})
```

---

### Upsert

typescript

```typescript
fastify.put('/users/:email', async (request, reply) => {
  const { email } = request.params as { email: string }
  const { name } = request.body as { name: string }

  const user = await fastify.prisma.user.upsert({
    where: { email },
    update: { name },
    create: { name, email }
  })

  return user
})
```

**Key Points:**

- `upsert` performs an `INSERT ... ON CONFLICT DO UPDATE` in PostgreSQL [Inference: exact SQL depends on Prisma version and database adapter]
- `where` must use a unique field — Prisma uses it to determine whether to insert or update
- The `update` and `create` data objects can differ — `create` typically includes more fields than `update`

---

### Raw Queries

When Prisma's query builder is insufficient:

typescript

```typescript
// Typed raw query
const users = await fastify.prisma.$queryRaw<User[]>`
  SELECT id, name, email
  FROM users
  WHERE created_at > ${new Date('2024-01-01')}
  ORDER BY created_at DESC
`

// Untyped raw execute (for DDL or non-SELECT)
await fastify.prisma.$executeRaw`
  UPDATE users SET last_seen = NOW() WHERE id = ${userId}
`
```

**Key Points:**

- `$queryRaw` uses tagged template literals — interpolated values are automatically parameterized by Prisma [Inference: this is the documented safe usage; using `$queryRawUnsafe` with string interpolation bypasses parameterization and is vulnerable to SQL injection]
- Never use `$queryRawUnsafe` with user-supplied values
- `$queryRaw` returns `unknown[]` by default — provide a generic type for typed results, though this is not validated at runtime [Inference]

---

### Prisma vs Knex vs Raw `pg`

| Concern | Raw `pg` | Knex | Prisma |
| --- | --- | --- | --- |
| Type safety | Manual interfaces | Partial generics | Full, generated types |
| Query style | Raw SQL | Builder API | Method API + relations |
| Migrations | External tool | Built-in CLI | Built-in CLI |
| Relations | Manual JOINs | Manual JOINs | Declarative, nested |
| Schema source of truth | DB or manual | `knexfile` + migrations | `schema.prisma` |
| Generated code | None | None | `PrismaClient` |
| Learning curve | Low | Medium | Medium–High |
| Flexibility | Highest | High | Medium |
| Abstraction overhead | None | Minimal | Moderate [Inference] |

---

### Seeding the Database

typescript

```typescript
// prisma/seed.ts
import { PrismaClient } from '@prisma/client'

const prisma = new PrismaClient()

async function main() {
  await prisma.user.upsert({
    where: { email: 'alice@example.com' },
    update: {},
    create: { name: 'Alice', email: 'alice@example.com' }
  })
}

main()
  .catch(console.error)
  .finally(() => prisma.$disconnect())
```

**Register the seed script in `package.json`:**

json

```json
{
  "prisma": {
    "seed": "ts-node prisma/seed.ts"
  }
}
```

bash

```bash
npx prisma db seed
```

**Key Points:**

- `upsert` in seeds is idempotent — re-running the seed does not create duplicate records
- `prisma migrate dev` runs the seed automatically after applying migrations in development [Inference: verify this behavior against current Prisma CLI version]

---

**Related Topics:**

- Prisma middleware for soft deletes and audit logging
- Cursor-based pagination with Prisma (`cursor`, `take`, `skip`)
- Prisma with connection pooling via PgBouncer or Prisma Accelerate
- Field-level encryption with Prisma middleware
- Multi-tenancy patterns with Prisma (schema-per-tenant vs row-level)
- Prisma in serverless environments: connection limits and `$connect` behavior
- Integration testing with Prisma using isolated test databases
- Replacing Prisma Client with `kysely` for stricter query-level TypeScript control
- Prisma Studio for development data inspection