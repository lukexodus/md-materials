## Mongoose and MongoDB Integration

Mongoose is an ODM (Object Document Mapper) for MongoDB in Node.js. Where SQL ORMs map classes to tables and rows, Mongoose maps classes to collections and documents. It adds schema validation, type casting, middleware hooks, and a query API on top of the native MongoDB driver. In Fastify, Mongoose is integrated via the community plugin `@fastify/mongoose` or a custom plugin wrapping the Mongoose connection directly.

---

### What Mongoose Provides

| Component | Description |
| --- | --- |
| Schema | Defines document structure, types, validators, and defaults |
| Model | Compiled schema bound to a MongoDB collection |
| Document | A single instance of a Model; represents one MongoDB document |
| Query API | Chainable `.find()`, `.findOne()`, `.updateOne()`, etc. |
| Middleware (hooks) | Pre/post hooks on document and query operations |
| Virtuals | Computed properties not stored in MongoDB |
| Plugins | Reusable schema extensions |
| Population | Reference resolution across collections (analogous to JOINs) |

**Key Points:**

- Mongoose operates on top of the native `mongodb` driver — it is an abstraction layer, not a replacement
- MongoDB is schemaless at the database level; Mongoose enforces schema at the application level
- Schema validation in Mongoose runs at the application layer — it does not prevent direct writes to MongoDB that bypass Mongoose from violating the schema [Inference: based on MongoDB's architecture; enforcement is application-side only]

---

### Installation

bash

```bash
npm install mongoose
```

TypeScript types are bundled with Mongoose as of version 6+ — no separate `@types/mongoose` is required. [Unverified: verify against your installed Mongoose version]

bash

```bash
npm install @fastify/mongoose   # Optional: official community plugin
```

---

### Defining a Schema and Model

Mongoose schemas define the shape, types, validators, and defaults of documents in a collection.

typescript

```typescript
// models/User.ts
import mongoose, { Schema, Document, Model } from 'mongoose'

export interface IUser {
  name: string
  email: string
  passwordHash: string
  role: 'admin' | 'user' | 'moderator'
  active: boolean
  createdAt: Date
  updatedAt: Date
}

export interface IUserDocument extends IUser, Document {}

const UserSchema = new Schema<IUserDocument>(
  {
    name: {
      type: String,
      required: [true, 'Name is required'],
      trim: true,
      maxlength: [255, 'Name must not exceed 255 characters']
    },
    email: {
      type: String,
      required: [true, 'Email is required'],
      unique: true,
      lowercase: true,
      trim: true,
      match: [/^\S+@\S+\.\S+$/, 'Invalid email format']
    },
    passwordHash: {
      type: String,
      required: true,
      select: false   // Excluded from query results by default
    },
    role: {
      type: String,
      enum: ['admin', 'user', 'moderator'],
      default: 'user'
    },
    active: {
      type: Boolean,
      default: true
    }
  },
  {
    timestamps: true,       // Adds createdAt and updatedAt automatically
    versionKey: false       // Disables __v field
  }
)

// Index declarations
UserSchema.index({ email: 1 }, { unique: true })
UserSchema.index({ createdAt: -1 })

export const User: Model<IUserDocument> =
  mongoose.model<IUserDocument>('User', UserSchema)
```

**Key Points:**

- `timestamps: true` in schema options adds `createdAt` and `updatedAt` fields managed by Mongoose — no manual population required
- `versionKey: false` removes the `__v` field Mongoose adds by default for optimistic concurrency control — remove this option if you rely on `__v` [Inference]
- `select: false` on a field excludes it from all query results unless explicitly re-included with `.select('+passwordHash')` — useful for sensitive fields
- `unique: true` on a path creates a MongoDB index, but uniqueness is enforced by MongoDB at the index level, not by Mongoose validation [Inference: Mongoose does not pre-check uniqueness; duplicate key errors surface as MongoDB driver errors with code `11000`]
- Schema-level `match`, `maxlength`, `enum`, and `required` validators run on `save()` and `validate()` — they do not run on `updateOne()`, `findOneAndUpdate()`, or similar update operations unless `runValidators: true` is passed [Inference: this is a well-known Mongoose behavior; verify against your version]

---

### Embedding vs Referencing Documents

MongoDB supports two primary data modeling strategies: embedding related data within a document, or storing references to documents in other collections.

typescript

```typescript
// models/Post.ts

// Embedded comment sub-document schema
const CommentSchema = new Schema({
  body: { type: String, required: true },
  author: { type: Schema.Types.ObjectId, ref: 'User', required: true },
  createdAt: { type: Date, default: Date.now }
}, { _id: true })

const PostSchema = new Schema<IPostDocument>(
  {
    title: { type: String, required: true, maxlength: 500 },
    body:  { type: String, required: true },
    published: { type: Boolean, default: false },

    // Reference to User collection
    author: {
      type: Schema.Types.ObjectId,
      ref: 'User',
      required: true
    },

    // Embedded array of sub-documents
    comments: [CommentSchema],

    // Array of references
    tags: [{ type: String, lowercase: true, trim: true }]
  },
  { timestamps: true, versionKey: false }
)

PostSchema.index({ author: 1, createdAt: -1 })
PostSchema.index({ tags: 1 })
PostSchema.index(
  { title: 'text', body: 'text' },
  { weights: { title: 2, body: 1 } }
)

export interface IPost {
  title: string
  body: string
  published: boolean
  author: mongoose.Types.ObjectId
  comments: IComment[]
  tags: string[]
}

export interface IPostDocument extends IPost, Document {}
export const Post = mongoose.model<IPostDocument>('Post', PostSchema)
```

**Key Points:**

- Embedding (sub-documents) is appropriate when related data is always accessed with the parent and has bounded size — e.g., comments on a post [Inference: based on MongoDB data modeling guidelines]
- Referencing (`Schema.Types.ObjectId` with `ref`) is appropriate when related data is large, frequently updated independently, or accessed on its own
- The `ref` string must match the model name passed to `mongoose.model()` — Mongoose uses it for `.populate()` resolution
- Text indexes (`'text'`) enable MongoDB's full-text search; `weights` control relevance scoring [Inference: behavior depends on MongoDB version]

---

### Integrating Mongoose as a Fastify Plugin

#### Option 1: Custom Plugin (Recommended for full control)

typescript

```typescript
// plugins/mongoose.ts
import fp from 'fastify-plugin'
import mongoose from 'mongoose'
import type { FastifyPluginAsync } from 'fastify'

declare module 'fastify' {
  interface FastifyInstance {
    mongoose: typeof mongoose
  }
}

const mongoosePlugin: FastifyPluginAsync = async (fastify) => {
  const uri = process.env.MONGODB_URI

  if (!uri) throw new Error('MONGODB_URI environment variable is not set')

  await mongoose.connect(uri, {
    maxPoolSize: 10,
    serverSelectionTimeoutMS: 5_000,
    socketTimeoutMS: 45_000
  })

  fastify.log.info('MongoDB connected')

  fastify.decorate('mongoose', mongoose)

  fastify.addHook('onClose', async () => {
    await mongoose.connection.close()
    fastify.log.info('MongoDB connection closed')
  })
}

export default fp(mongoosePlugin)
```

**Registration:**

typescript

```typescript
// app.ts
import Fastify from 'fastify'
import mongoosePlugin from './plugins/mongoose'

const fastify = Fastify({ logger: true })

await fastify.register(mongoosePlugin)
await fastify.listen({ port: 3000 })
```

#### Option 2: `@fastify/mongoose`

typescript

```typescript
import fastifyMongoose from '@fastify/mongoose'

await fastify.register(fastifyMongoose, {
  uri: process.env.MONGODB_URI
})
// Decorates fastify.mongoose
```

**[Unverified]:** `@fastify/mongoose` API and options may differ from the above. Verify against current plugin documentation before use.

**Key Points:**

- `maxPoolSize` controls the maximum number of connections in the Mongoose connection pool [Inference: option name may differ by Mongoose version; verify against current docs]
- `serverSelectionTimeoutMS` sets how long Mongoose waits to find an available MongoDB server before throwing — prevents indefinite startup hangs
- Because models are registered on the global `mongoose` instance, they are accessible directly via `import { User } from '../models/User'` in route files — the `fastify.mongoose` decoration is optional but useful for testing and encapsulation

---

### Basic CRUD Operations

#### Create

typescript

```typescript
fastify.post('/users', async (request, reply) => {
  const { name, email } = request.body as { name: string; email: string }

  try {
    const user = await User.create({ name, email })
    return reply.code(201).send(user)
  } catch (err: any) {
    if (err.code === 11000) {
      return reply.code(409).send({ error: 'Email already exists' })
    }
    throw err
  }
})
```

**Key Points:**

- `Model.create()` instantiates a document and calls `save()` — schema validation runs before the insert
- MongoDB duplicate key errors surface with `err.code === 11000` — these must be caught explicitly as Mongoose does not translate them into validation errors

#### Find Many

typescript

```typescript
fastify.get('/users', async (request) => {
  const { page = '1', limit = '20', active } = request.query as {
    page?: string
    limit?: string
    active?: string
  }

  const pageNum = Math.max(1, parseInt(page, 10))
  const limitNum = Math.min(100, parseInt(limit, 10))
  const filter: Record<string, unknown> = {}

  if (active !== undefined) filter.active = active === 'true'

  const [users, total] = await Promise.all([
    User.find(filter)
      .select('name email role active createdAt')
      .sort({ createdAt: -1 })
      .skip((pageNum - 1) * limitNum)
      .limit(limitNum)
      .lean(),
    User.countDocuments(filter)
  ])

  return {
    data: users,
    pagination: { page: pageNum, limit: limitNum, total, pages: Math.ceil(total / limitNum) }
  }
})
```

**Key Points:**

- `.lean()` returns plain JavaScript objects instead of full Mongoose Document instances — significantly faster for read-only responses as it skips document hydration [Inference: performance difference depends on document complexity and volume]
- `.select('name email')` is equivalent to a SQL projection — unlisted fields are excluded from the result
- `.sort({ createdAt: -1 })` sorts descending; `1` is ascending
- `Promise.all` runs the data query and count query concurrently

#### Find One

typescript

```typescript
fastify.get('/users/:id', async (request, reply) => {
  const { id } = request.params as { id: string }

  if (!mongoose.isValidObjectId(id)) {
    return reply.code(400).send({ error: 'Invalid ID format' })
  }

  const user = await User.findById(id).lean()

  if (!user) return reply.code(404).send({ error: 'Not found' })
  return user
})
```

**Key Points:**

- Always validate ObjectId format before querying — an invalid ObjectId string causes a CastError from Mongoose, which surfaces as an unhandled 500 error if not caught [Inference]
- `mongoose.isValidObjectId(id)` checks format validity without a database round-trip
- `findById(id)` is shorthand for `findOne({ _id: id })`

#### Update

typescript

```typescript
fastify.put('/users/:id', async (request, reply) => {
  const { id } = request.params as { id: string }
  const { name, email } = request.body as { name: string; email: string }

  if (!mongoose.isValidObjectId(id)) {
    return reply.code(400).send({ error: 'Invalid ID format' })
  }

  const user = await User.findByIdAndUpdate(
    id,
    { $set: { name, email } },
    { new: true, runValidators: true }
  ).lean()

  if (!user) return reply.code(404).send({ error: 'Not found' })
  return user
})
```

**Key Points:**

- `{ new: true }` returns the document after the update rather than before — omitting it returns the pre-update document [Inference]
- `{ runValidators: true }` applies schema validators to the update operation — without this, `match`, `maxlength`, and `enum` constraints are not enforced on updates [Inference: well-known Mongoose behavior]
- `$set` updates only the specified fields — omitting `$set` and passing the object directly replaces the entire document [Inference]

#### Delete

typescript

```typescript
fastify.delete('/users/:id', async (request, reply) => {
  const { id } = request.params as { id: string }

  if (!mongoose.isValidObjectId(id)) {
    return reply.code(400).send({ error: 'Invalid ID format' })
  }

  const user = await User.findByIdAndDelete(id)

  if (!user) return reply.code(404).send({ error: 'Not found' })
  return reply.code(204).send()
})
```

---

### Population (Cross-Collection References)

`.populate()` resolves `ObjectId` references by fetching the referenced documents from their collections.

typescript

```typescript
fastify.get('/posts/:id', async (request, reply) => {
  const { id } = request.params as { id: string }

  if (!mongoose.isValidObjectId(id)) {
    return reply.code(400).send({ error: 'Invalid ID format' })
  }

  const post = await Post.findById(id)
    .populate('author', 'name email')      // Only name and email from User
    .populate('comments.author', 'name')   // Nested population
    .lean()

  if (!post) return reply.code(404).send({ error: 'Not found' })
  return post
})
```

**Key Points:**

- `.populate()` executes additional queries — one per populated path — not a SQL JOIN [Inference: Mongoose uses `$in` queries to batch reference resolution; exact strategy may vary by version]
- The second argument to `.populate()` is a field selection string — limits which fields are returned from the referenced collection
- Chaining multiple `.populate()` calls populates multiple paths
- `.lean()` can be used with `.populate()` — the populated fields are plain objects, not Document instances [Inference]
- Deep population (nested references) increases the number of database round-trips; consider data model design if population chains are long [Inference]

---

### Mermaid: Mongoose Request Flow in Fastify

MongoDBMongoDriverMongooseModelFastifyClientMongoDBMongoDriverMongooseModelFastifyClientHTTP RequestUser.find(filter).lean()Schema validation / castingdb.collection('users').find(...)Wire protocol queryBSON documentsRaw JS objectsHydrated Documents / lean objectsJSON Response

---

### Middleware (Pre/Post Hooks)

Mongoose middleware intercepts operations at the document or query level.

typescript

```typescript
import bcrypt from 'bcrypt'

// Document middleware — runs on save()
UserSchema.pre('save', async function (next) {
  // 'this' refers to the document being saved
  if (!this.isModified('passwordHash')) return next()

  this.passwordHash = await bcrypt.hash(this.passwordHash, 12)
  next()
})

// Query middleware — runs on find operations
UserSchema.pre(/^find/, function (next) {
  // 'this' refers to the Query object
  (this as mongoose.Query<any, any>).where({ active: true })
  next()
})

// Post middleware — runs after the operation
UserSchema.post('save', function (doc) {
  console.log(`User saved: ${doc.email}`)
})

// Error handling middleware
UserSchema.post('save', function (err: any, doc: any, next: any) {
  if (err.code === 11000) {
    next(new Error('Email already registered'))
  } else {
    next(err)
  }
})
```

**Key Points:**

- `pre('save')` runs before `document.save()` and `Model.create()` — it does not run before `updateOne()`, `findOneAndUpdate()`, etc. [Inference: this is a documented Mongoose behavior distinction between document and query middleware]
- `this.isModified('field')` inside `pre('save')` checks whether the field has changed since the document was last fetched — prevents re-hashing an already-hashed value
- Query middleware uses a regex (`/^find/`) to match multiple query methods simultaneously
- The four-argument post hook signature (`err, doc, next`) is Mongoose's error handling middleware pattern

---

### Virtuals

Virtuals are computed properties that are not stored in MongoDB but are present on document instances.

typescript

```typescript
UserSchema.virtual('fullProfile').get(function () {
  return `${this.name} <${this.email}>`
})

// Include virtuals in JSON serialization
UserSchema.set('toJSON', { virtuals: true })
UserSchema.set('toObject', { virtuals: true })
```

**Key Points:**

- Virtuals are not included in `.lean()` results — they require full document hydration [Inference]
- `toJSON: { virtuals: true }` is necessary for virtuals to appear when Fastify serializes the response, as Fastify calls `JSON.stringify()` internally
- Virtuals cannot be queried or indexed — they exist only in application memory [Inference]

---

### Transactions (Multi-Document)

MongoDB supports multi-document ACID transactions on replica sets and sharded clusters. Standalone instances do not support transactions. [Unverified: verify transaction support requirements against your MongoDB deployment version and topology]

typescript

```typescript
fastify.post('/orders', async (request, reply) => {
  const { userId, items } = request.body as {
    userId: string
    items: { productId: string; quantity: number }[]
  }

  const session = await mongoose.startSession()

  try {
    const result = await session.withTransaction(async () => {
      // All operations must pass the session
      const order = await Order.create([{ userId, items }], { session })

      for (const item of items) {
        const updated = await Product.findOneAndUpdate(
          {
            _id: item.productId,
            stock: { $gte: item.quantity }
          },
          { $inc: { stock: -item.quantity } },
          { session, new: true }
        )

        if (!updated) {
          throw new Error(`Insufficient stock for product ${item.productId}`)
        }
      }

      return order[0]
    })

    return reply.code(201).send(result)
  } finally {
    await session.endSession()
  }
})
```

**Key Points:**

- `session.withTransaction()` handles commit and retry logic automatically — it retries on transient transaction errors (e.g., write conflicts) [Inference: based on MongoDB driver documentation; retry behavior depends on driver version]
- Every operation inside a transaction must receive `{ session }` — operations without the session do not participate in the transaction
- `Model.create()` with a session requires an array form — `create([doc], { session })` — not the single-document form [Inference: verify against current Mongoose version]
- `session.endSession()` must always be called — `finally` enforces this
- Throwing inside `withTransaction` triggers rollback

---

### Schema Plugins

Plugins extend multiple schemas with shared functionality.

typescript

```typescript
// plugins/softDelete.ts
import { Schema } from 'mongoose'

export function softDeletePlugin(schema: Schema) {
  schema.add({
    deletedAt: { type: Date, default: null }
  })

  schema.methods.softDelete = async function () {
    this.deletedAt = new Date()
    return this.save()
  }

  schema.methods.restore = async function () {
    this.deletedAt = null
    return this.save()
  }

  // Automatically exclude soft-deleted documents from find queries
  schema.pre(/^find/, function (next) {
    (this as mongoose.Query<any, any>).where({ deletedAt: null })
    next()
  })
}

// Apply to a schema
UserSchema.plugin(softDeletePlugin)
PostSchema.plugin(softDeletePlugin)
```

**Key Points:**

- `schema.add()` inside a plugin extends the schema with additional fields
- `schema.methods` adds instance methods to documents created by models using this schema
- The `pre(/^find/)` hook in the plugin filters soft-deleted documents from all find-based queries automatically [Inference: does not affect `countDocuments`, `aggregate`, or direct collection access; verify coverage for your use case]

---

### Aggregation Pipeline

For analytics and complex data transformations, use MongoDB's aggregation pipeline.

typescript

```typescript
fastify.get('/stats/posts-by-author', async () => {
  return Post.aggregate([
    { $match: { published: true } },
    {
      $group: {
        _id: '$author',
        postCount: { $sum: 1 },
        latestPost: { $max: '$createdAt' }
      }
    },
    {
      $lookup: {
        from: 'users',
        localField: '_id',
        foreignField: '_id',
        as: 'authorDetails'
      }
    },
    { $unwind: '$authorDetails' },
    {
      $project: {
        _id: 0,
        authorId: '$_id',
        authorName: '$authorDetails.name',
        postCount: 1,
        latestPost: 1
      }
    },
    { $sort: { postCount: -1 } }
  ])
})
```

**Key Points:**

- Aggregation pipelines run entirely in MongoDB — they are not processed in application memory
- `$lookup` is MongoDB's equivalent of a JOIN — it resolves references across collections within the pipeline
- `$unwind` deconstructs the array produced by `$lookup` when each document has exactly one match; documents with no match are dropped unless `preserveNullAndEmptyArrays: true` is set [Inference]
- Aggregation bypasses Mongoose middleware and schema validation — it operates directly on the collection [Inference]

---

### Mongoose vs Relational ORM Patterns

| Concern | Mongoose (MongoDB) | TypeORM / Prisma (SQL) |
| --- | --- | --- |
| Schema enforcement | Application-level only | Database + application level |
| Relations | Manual refs + `.populate()` | Foreign keys + JOINs |
| Transactions | Replica set required | Always available |
| Flexible schema | Native (mixed types) | Requires migrations |
| Query language | MongoDB query operators | SQL via builder/method API |
| Aggregations | Pipeline API | SQL GROUP BY / window functions |
| Indexing | Declared on schema | Declared in migrations |

---

### Connection Events and Monitoring

typescript

```typescript
mongoose.connection.on('connected', () => {
  fastify.log.info('Mongoose connected to MongoDB')
})

mongoose.connection.on('error', (err) => {
  fastify.log.error(err, 'Mongoose connection error')
})

mongoose.connection.on('disconnected', () => {
  fastify.log.warn('Mongoose disconnected from MongoDB')
})

// Reconnection is handled automatically by Mongoose [Inference]
```

**Key Points:**

- Mongoose handles reconnection automatically after transient disconnections — the retry behavior is configurable [Inference: verify reconnection options against current Mongoose and MongoDB driver versions]
- Logging connection events aids in diagnosing network instability in production
- `mongoose.connection.readyState` returns `0` (disconnected), `1` (connected), `2` (connecting), or `3` (disconnecting) — useful for health checks

**Health check route:**

typescript

```typescript
fastify.get('/health', async (request, reply) => {
  const state = mongoose.connection.readyState

  if (state !== 1) {
    return reply.code(503).send({
      status: 'error',
      database: 'disconnected',
      readyState: state
    })
  }

  return { status: 'ok', database: 'connected' }
})
```

---

**Related Topics:**

- Mongoose discriminators for polymorphic collections
- Change streams with Mongoose for real-time event processing
- Cursor-based pagination with Mongoose (`_id`-based cursors)
- Full-text search with MongoDB text indexes and Mongoose
- GridFS for storing large files via Mongoose
- Mongoose with `zod` or `class-validator` for request body validation separate from schema validation
- Indexing strategies for MongoDB: compound indexes, partial indexes, TTL indexes
- Multi-tenancy with Mongoose: dynamic model registration per tenant
- Testing Mongoose models with `mongodb-memory-server`