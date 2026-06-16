## TypeORM Integration

TypeORM is a TypeScript-first ORM for Node.js that supports the Active Record and Data Mapper patterns. It integrates deeply with TypeScript's decorator system — models are defined as decorated classes, and the ORM derives schema structure from those decorators at runtime. In Fastify, TypeORM is integrated via a custom plugin using `fastify-plugin`, following the same decorated-instance pattern used for Knex and Prisma.

---

### What TypeORM Provides

| Component | Description |
| --- | --- |
| Entity classes | TypeScript classes decorated to define table structure |
| DataSource | Central configuration object managing connections and metadata |
| Repository API | Per-entity query interface (`find`, `save`, `delete`, etc.) |
| QueryBuilder | Chainable SQL builder for complex queries |
| Migrations | CLI-driven, version-controlled schema change files |
| Subscribers | Event hooks on entity lifecycle (insert, update, remove) |
| Relations | OneToOne, OneToMany, ManyToOne, ManyToMany with lazy/eager loading |

**Key Points:**

- TypeORM supports PostgreSQL, MySQL, MariaDB, SQLite, MSSQL, Oracle, CockroachDB, and MongoDB [Unverified: verify current adapter support against TypeORM documentation for your version]
- Active Record pattern: entities extend `BaseEntity` and carry query methods on the class itself
- Data Mapper pattern: entities are plain classes; queries go through injected `Repository` or `EntityManager` instances
- The Data Mapper pattern is generally preferred in Fastify because it avoids coupling entity classes to the database connection [Inference]

---

### Installation

bash

```bash
npm install typeorm reflect-metadata pg
npm install --save-dev @types/pg
```

`reflect-metadata` is required by TypeORM's decorator system. It must be imported once, before any TypeORM code runs:

typescript

```typescript
// At the very top of your entry point (e.g., src/index.ts)
import 'reflect-metadata'
```

**TypeScript configuration — required settings in `tsconfig.json`:**

json

```json
{
  "compilerOptions": {
    "experimentalDecorators": true,
    "emitDecoratorMetadata": true,
    "strictPropertyInitialization": false
  }
}
```

**Key Points:**

- `experimentalDecorators` enables the `@Entity`, `@Column`, `@PrimaryGeneratedColumn` decorators
- `emitDecoratorMetadata` emits TypeScript type metadata at runtime so TypeORM can infer column types from TypeScript types [Inference: this is a TypeORM dependency; omitting it causes column type inference to fail]
- `strictPropertyInitialization: false` suppresses TypeScript errors for entity properties that TypeORM populates at runtime rather than in the constructor — this weakens strict null checking on entity classes [Inference]
- `reflect-metadata` must be imported before TypeORM internals are loaded; placing it at the top of the entry file is the standard approach

---

### Defining Entities

Entities are TypeScript classes decorated with `@Entity()`. Each class maps to a database table; each property maps to a column.

typescript

```typescript
// entities/User.ts
import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  OneToMany
} from 'typeorm'
import { Post } from './Post'

@Entity('users')
export class User {
  @PrimaryGeneratedColumn()
  id: number

  @Column({ length: 255 })
  name: string

  @Column({ length: 255, unique: true })
  email: string

  @Column({ nullable: true })
  phone: string | null

  @OneToMany(() => Post, (post) => post.author)
  posts: Post[]

  @CreateDateColumn()
  createdAt: Date

  @UpdateDateColumn()
  updatedAt: Date
}
```

typescript

```typescript
// entities/Post.ts
import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  ManyToOne,
  JoinColumn,
  CreateDateColumn,
  UpdateDateColumn
} from 'typeorm'
import { User } from './User'

@Entity('posts')
export class Post {
  @PrimaryGeneratedColumn()
  id: number

  @Column({ length: 500 })
  title: string

  @Column('text')
  body: string

  @Column({ default: false })
  published: boolean

  @ManyToOne(() => User, (user) => user.posts, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'author_id' })
  author: User

  @Column({ name: 'author_id' })
  authorId: number

  @CreateDateColumn()
  createdAt: Date

  @UpdateDateColumn()
  updatedAt: Date
}
```

**Key Points:**

- `@PrimaryGeneratedColumn()` creates an auto-incrementing integer primary key; `@PrimaryGeneratedColumn('uuid')` creates a UUID primary key
- `@CreateDateColumn()` and `@UpdateDateColumn()` are managed by TypeORM — the ORM sets and updates them automatically [Inference: behavior depends on TypeORM version and database adapter]
- `@JoinColumn({ name: 'author_id' })` controls the foreign key column name in the database
- Exposing `authorId` as a plain `@Column` alongside the `@ManyToOne` relation allows querying by foreign key without loading the full relation

---

### DataSource Configuration

`DataSource` is TypeORM's central connection manager. It holds configuration, manages the connection pool, and stores entity metadata.

typescript

```typescript
// db/dataSource.ts
import 'reflect-metadata'
import { DataSource } from 'typeorm'
import { User } from '../entities/User'
import { Post } from '../entities/Post'

export const AppDataSource = new DataSource({
  type: 'postgres',
  url: process.env.DATABASE_URL,
  entities: [User, Post],
  migrations: ['src/migrations/*.ts'],
  synchronize: false,       // Never use true in production
  logging: process.env.NODE_ENV === 'development' ? ['query', 'error'] : ['error'],
  ssl: process.env.NODE_ENV === 'production'
    ? { rejectUnauthorized: false }
    : false,
  extra: {
    max: 20,                // pg pool max connections
    idleTimeoutMillis: 30_000,
    connectionTimeoutMillis: 2_000
  }
})
```

**Key Points:**

- `synchronize: true` automatically alters the database schema to match entity definitions on every startup — this is dangerous in production as it may drop columns or tables [Inference: TypeORM documentation explicitly warns against this; risk depends on schema changes between deployments]
- `entities` accepts class references or glob patterns; class references are preferred in TypeScript projects to avoid glob resolution issues [Inference]
- `extra` passes options directly to the underlying `pg` pool
- `migrations` points to the directory where generated migration files are stored
- `DataSource` is instantiated but not yet connected — `initialize()` must be called before use

---

### Integrating DataSource as a Fastify Plugin

typescript

```typescript
// plugins/typeorm.ts
import fp from 'fastify-plugin'
import type { FastifyPluginAsync } from 'fastify'
import { DataSource, EntityManager } from 'typeorm'
import { AppDataSource } from '../db/dataSource'

declare module 'fastify' {
  interface FastifyInstance {
    orm: DataSource
  }
}

const typeormPlugin: FastifyPluginAsync = async (fastify) => {
  const dataSource = await AppDataSource.initialize()

  fastify.decorate('orm', dataSource)

  fastify.addHook('onClose', async () => {
    await dataSource.destroy()
  })
}

export default fp(typeormPlugin)
```

**Registration:**

typescript

```typescript
// app.ts
import 'reflect-metadata'
import Fastify from 'fastify'
import typeormPlugin from './plugins/typeorm'

const fastify = Fastify({ logger: true })

await fastify.register(typeormPlugin)
await fastify.listen({ port: 3000 })
```

**Key Points:**

- `AppDataSource.initialize()` connects to the database and runs internal TypeORM setup — it throws if the connection fails, preventing startup with a broken database [Inference]
- `dataSource.destroy()` in `onClose` closes all pool connections gracefully
- `fp()` ensures `fastify.orm` is accessible across all scopes without re-registration
- `reflect-metadata` is imported in `app.ts` before any TypeORM imports — this order matters

---

### Repository API

TypeORM's Repository provides per-entity query methods. Obtain a repository from the `DataSource` via `getRepository()`.

typescript

```typescript
// Convenience helper — avoids repeating getRepository() everywhere
function repo<T>(entity: new () => T) {
  return fastify.orm.getRepository(entity)
}
```

#### Find Many

typescript

```typescript
fastify.get('/users', async () => {
  return fastify.orm.getRepository(User).find({
    select: {
      id: true,
      name: true,
      email: true,
      createdAt: true
    },
    order: { createdAt: 'DESC' },
    take: 20
  })
})
```

#### Find One

typescript

```typescript
fastify.get('/users/:id', async (request, reply) => {
  const { id } = request.params as { id: string }

  const user = await fastify.orm.getRepository(User).findOne({
    where: { id: parseInt(id, 10) }
  })

  if (!user) return reply.code(404).send({ error: 'Not found' })
  return user
})
```

#### Save (Insert or Update)

typescript

```typescript
fastify.post('/users', async (request, reply) => {
  const { name, email } = request.body as { name: string; email: string }

  const userRepo = fastify.orm.getRepository(User)

  const user = userRepo.create({ name, email })
  const saved = await userRepo.save(user)

  return reply.code(201).send(saved)
})
```

**Key Points:**

- `repo.create()` constructs an entity instance without persisting it — use `save()` to write to the database
- `save()` performs an upsert: if the entity has a primary key that exists in the database, it issues an `UPDATE`; otherwise it issues an `INSERT` [Inference: exact SQL behavior depends on TypeORM version and dialect]
- `save()` returns the persisted entity including database-generated values (`id`, `createdAt`, etc.)

#### Update

typescript

```typescript
fastify.put('/users/:id', async (request, reply) => {
  const { id } = request.params as { id: string }
  const { name, email } = request.body as { name: string; email: string }

  const userRepo = fastify.orm.getRepository(User)

  const result = await userRepo.update(
    { id: parseInt(id, 10) },
    { name, email }
  )

  if (result.affected === 0) {
    return reply.code(404).send({ error: 'Not found' })
  }

  return userRepo.findOne({ where: { id: parseInt(id, 10) } })
})
```

**Key Points:**

- `repo.update()` issues a direct `UPDATE` without loading the entity first — more efficient than `find` + `save` for simple updates
- `result.affected` indicates how many rows were updated; `0` means the target row did not exist
- `update()` does not return the updated entity — a subsequent `findOne` is required if the updated data is needed in the response [Inference: behavior may differ by TypeORM version]

#### Delete

typescript

```typescript
fastify.delete('/users/:id', async (request, reply) => {
  const { id } = request.params as { id: string }

  const result = await fastify.orm.getRepository(User).delete({
    id: parseInt(id, 10)
  })

  if (result.affected === 0) {
    return reply.code(404).send({ error: 'Not found' })
  }

  return reply.code(204).send()
})
```

---

### Relations and Eager Loading

typescript

```typescript
// Find user with posts included
fastify.get('/users/:id/posts', async (request, reply) => {
  const { id } = request.params as { id: string }

  const user = await fastify.orm.getRepository(User).findOne({
    where: { id: parseInt(id, 10) },
    relations: { posts: true }
  })

  if (!user) return reply.code(404).send({ error: 'Not found' })
  return user
})
```

**Key Points:**

- `relations` performs a JOIN and populates the relation property on the returned entity
- Omitting `relations` returns the entity with relation properties as `undefined` — they are not loaded unless explicitly requested (lazy loading requires additional configuration) [Inference]
- Deep relations can be included: `relations: { posts: { comments: true } }` [Inference: syntax may differ by TypeORM version]

---

### QueryBuilder

For queries that exceed the repository API's expressiveness, TypeORM provides a chainable QueryBuilder.

typescript

```typescript
fastify.get('/posts', async (request) => {
  const { search, published, page = '1', limit = '20' } = request.query as {
    search?: string
    published?: string
    page?: string
    limit?: string
  }

  const pageNum = Math.max(1, parseInt(page, 10))
  const limitNum = Math.min(100, parseInt(limit, 10))

  const qb = fastify.orm
    .getRepository(Post)
    .createQueryBuilder('post')
    .leftJoinAndSelect('post.author', 'author')
    .select([
      'post.id',
      'post.title',
      'post.published',
      'post.createdAt',
      'author.id',
      'author.name'
    ])
    .orderBy('post.createdAt', 'DESC')
    .skip((pageNum - 1) * limitNum)
    .take(limitNum)

  if (published !== undefined) {
    qb.andWhere('post.published = :published', { published: published === 'true' })
  }

  if (search) {
    qb.andWhere(
      '(post.title ILIKE :search OR post.body ILIKE :search)',
      { search: `%${search}%` }
    )
  }

  const [posts, total] = await qb.getManyAndCount()

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

- `getManyAndCount()` executes two queries — one for the data, one for the total count — and returns them as a tuple
- Parameters in `.where()` and `.andWhere()` use named placeholders (`:name`) — TypeORM parameterizes these automatically
- `ILIKE` is PostgreSQL-specific; use `LIKE` for case-sensitive or non-PostgreSQL dialects
- `.select()` on QueryBuilder controls which columns are fetched; unlisted columns are excluded from the SQL projection and returned as `undefined` on the entity

---

### Transactions

#### EntityManager Transaction (Callback Form)

typescript

```typescript
fastify.post('/transfer', async (request, reply) => {
  const { fromId, toId, amount } = request.body as {
    fromId: number
    toId: number
    amount: number
  }

  await fastify.orm.transaction(async (manager) => {
    const accountRepo = manager.getRepository(Account)

    const from = await accountRepo.findOne({ where: { id: fromId } })
    if (!from || from.balance < amount) {
      throw new Error('Insufficient funds')
    }

    await accountRepo.decrement({ id: fromId }, 'balance', amount)
    await accountRepo.increment({ id: toId }, 'balance', amount)

    await manager.getRepository(TransactionLog).save({
      fromId,
      toId,
      amount
    })
  })

  return { success: true }
})
```

**Key Points:**

- `fastify.orm.transaction(async (manager) => { ... })` wraps the callback in a database transaction — any thrown error triggers automatic rollback [Inference: based on TypeORM documentation]
- All queries inside the callback must use the transaction-scoped `manager` — queries via `fastify.orm.getRepository()` outside the callback are not part of the transaction
- `manager.getRepository(Entity)` returns a transaction-scoped repository

#### QueryRunner (Manual Control)

typescript

```typescript
const queryRunner = fastify.orm.createQueryRunner()
await queryRunner.connect()
await queryRunner.startTransaction()

try {
  await queryRunner.manager.save(User, newUser)
  await queryRunner.manager.save(Post, newPost)
  await queryRunner.commitTransaction()
} catch (err) {
  await queryRunner.rollbackTransaction()
  throw err
} finally {
  await queryRunner.release()
}
```

**Key Points:**

- `QueryRunner` gives explicit control over transaction lifecycle — necessary when transaction boundaries span multiple function calls
- `release()` in `finally` returns the connection to the pool regardless of outcome — omitting it leaks the connection [Inference]
- The callback form (`orm.transaction()`) is preferred for self-contained transactions; `QueryRunner` is for cases where the transaction must be passed across function boundaries

---

### Mermaid: TypeORM Integration Architecture

Fastify Apptypeorm PluginDataSource.initializefastify.decorate ormRoute Handlersorm.getRepository EntityRepository APIQueryBuilderConnection PoolPostgreSQLonClose:dataSource.destroy

---

### Migrations

TypeORM's migration CLI generates SQL migration files from the difference between current entities and the last migration state.

**`data-source.ts` for CLI use:**

The CLI needs a compiled or ts-node-accessible DataSource export:

typescript

```typescript
// src/data-source.ts (re-exports AppDataSource for CLI)
export { AppDataSource as default } from './db/dataSource'
```

**`package.json` scripts:**

json

```json
{
  "scripts": {
    "migration:generate": "typeorm-ts-node-commonjs migration:generate src/migrations/migration -d src/data-source.ts",
    "migration:run":      "typeorm-ts-node-commonjs migration:run -d src/data-source.ts",
    "migration:revert":   "typeorm-ts-node-commonjs migration:revert -d src/data-source.ts",
    "migration:create":   "typeorm-ts-node-commonjs migration:create src/migrations/migration"
  }
}
```

**A generated migration file:**

typescript

```typescript
// src/migrations/1717200000000-CreateUsersAndPosts.ts
import { MigrationInterface, QueryRunner } from 'typeorm'

export class CreateUsersAndPosts1717200000000 implements MigrationInterface {
  name = 'CreateUsersAndPosts1717200000000'

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`
      CREATE TABLE "users" (
        "id"         SERIAL PRIMARY KEY,
        "name"       character varying(255) NOT NULL,
        "email"      character varying(255) NOT NULL,
        "created_at" TIMESTAMP NOT NULL DEFAULT now(),
        "updated_at" TIMESTAMP NOT NULL DEFAULT now(),
        CONSTRAINT "UQ_users_email" UNIQUE ("email")
      )
    `)
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`DROP TABLE "users"`)
  }
}
```

**Key Points:**

- `migration:generate` compares entity metadata to the current database state and generates the SQL diff — review generated files before applying, as TypeORM may generate destructive changes [Inference]
- `migration:run` applies all pending migrations; TypeORM tracks applied migrations in a `migrations` table
- `migration:revert` rolls back the most recently applied migration by calling `down()`
- `synchronize: false` must be set in the DataSource used by the CLI — running `generate` against a DataSource with `synchronize: true` may produce unexpected diffs [Inference]

---

### Raw Queries

typescript

```typescript
// Parameterized raw query
const users = await fastify.orm.query(
  'SELECT id, name, email FROM users WHERE created_at > $1',
  [new Date('2024-01-01')]
)

// Via QueryBuilder
const result = await fastify.orm
  .getRepository(User)
  .createQueryBuilder('user')
  .where('user.createdAt > :date', { date: new Date('2024-01-01') })
  .getRawMany()
```

**Key Points:**

- `orm.query()` accepts a SQL string and a parameters array — use `$1`, `$2` placeholders for PostgreSQL
- `getRawMany()` on QueryBuilder returns raw database rows rather than mapped entity instances — useful when the result shape does not match an entity

---

### TypeORM vs Prisma vs Knex

| Concern | Knex | Prisma | TypeORM |
| --- | --- | --- | --- |
| Schema definition | Migration files | `schema.prisma` | Decorated entity classes |
| Type safety | Partial generics | Full, generated | Decorator-derived |
| Query style | Builder API | Method API | Repository + QueryBuilder |
| Relations | Manual JOINs | Declarative nested | Decorator-declared |
| Migrations | Built-in CLI | Built-in CLI | Built-in CLI |
| Active Record support | No | No | Yes |
| Runtime schema inference | No | No | Yes (via decorators + reflect-metadata) |
| `synchronize` risk | N/A | N/A | High if enabled in production |
| Decorator dependency | No | No | Yes (`reflect-metadata`) |

---

### Subscribers: Entity Lifecycle Hooks

TypeORM subscribers listen to entity events across the application.

typescript

```typescript
// subscribers/UserSubscriber.ts
import {
  EventSubscriber,
  EntitySubscriberInterface,
  InsertEvent,
  UpdateEvent
} from 'typeorm'
import { User } from '../entities/User'

@EventSubscriber()
export class UserSubscriber implements EntitySubscriberInterface<User> {
  listenTo() {
    return User
  }

  async afterInsert(event: InsertEvent<User>): Promise<void> {
    console.log(`User created: ${event.entity.email}`)
    // e.g., send welcome email, emit event
  }

  async afterUpdate(event: UpdateEvent<User>): Promise<void> {
    console.log(`User updated: ${event.entity?.email}`)
  }
}
```

**Register in DataSource:**

typescript

```typescript
export const AppDataSource = new DataSource({
  // ...
  subscribers: [UserSubscriber]
})
```

**Key Points:**

- Subscribers apply globally to all operations on the listened entity, regardless of which repository or manager performs them [Inference]
- Async operations in subscribers (e.g., sending emails) that throw do not automatically rollback the originating transaction — error handling inside subscribers must be explicit [Inference]
- Subscribers are appropriate for cross-cutting concerns like audit logging, event emission, and cache invalidation

---

**Related Topics:**

- Soft deletes with TypeORM (`@DeleteDateColumn` and `softDelete()`)
- TypeORM with UUID primary keys and `@PrimaryGeneratedColumn('uuid')`
- Lazy loading relations with TypeORM Promises
- TypeORM connection pooling tuning for high-concurrency Fastify applications
- Testing TypeORM entities with an in-memory SQLite DataSource
- Multi-tenancy with TypeORM: schema-per-tenant using `QueryRunner.changeSchema()`
- TypeORM with `class-validator` and `class-transformer` for entity-level validation
- Replacing `synchronize` with a safe migration-only workflow in CI/CD
- Combining TypeORM with Fastify's `setErrorHandler` for unified database error responses