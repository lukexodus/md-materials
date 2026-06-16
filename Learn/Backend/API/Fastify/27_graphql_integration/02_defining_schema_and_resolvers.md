## Defining Schema and Resolvers

### The Relationship Between Schema and Resolvers

In Mercurius, the schema and resolvers are defined separately and connected at registration. The schema is the contract — it defines types, fields, and operations. The resolvers are the implementation — they define how each field is populated at runtime.

A field with no resolver falls back to a default resolver, which attempts to read a property of the same name from the parent object. A field whose resolver returns the wrong type produces a GraphQL execution error, not a runtime exception.

**Key Points:**

- Schema and resolvers must be structurally consistent — every resolver key must correspond to a type and field defined in the schema
- Extra resolver keys with no matching schema field are silently ignored — [Inference] this is a common source of confusion when a resolver appears to do nothing
- The schema enforces the shape of inputs and outputs; resolvers enforce the business logic

---

### SDL Fundamentals

The Schema Definition Language is a human-readable syntax for describing a GraphQL schema. Mercurius accepts SDL as a string or template literal:

javascript

```javascript
const schema = `
  type Query {
    ping: String!
  }
`;
```

Every valid GraphQL schema must define a `Query` type. `Mutation` and `Subscription` are optional.

---

### Scalar Types

GraphQL ships five built-in scalars:

| Scalar | JavaScript equivalent | Notes |
| --- | --- | --- |
| `String` | `string` | UTF-8 text |
| `Int` | `number` (32-bit integer) | Values outside ±2³¹ produce errors |
| `Float` | `number` (double) |  |
| `Boolean` | `boolean` |  |
| `ID` | `string` or `number` | Serialized as string; represents a unique identifier |

Non-null is expressed with `!`. Lists are expressed with `[]`:

graphql

```graphql
id: ID!          # non-null ID
tags: [String!]! # non-null list of non-null strings
score: Float     # nullable float
```

**Key Points:**

- `[String!]!` means the list itself cannot be null and no element can be null
- `[String]` means the list may be null and elements may be null
- [Inference] The distinction matters at the resolver level — a resolver returning `null` for a `String!` field produces a GraphQL error that propagates upward through the response tree

---

### Custom Scalars

When built-in scalars are insufficient, custom scalars define serialization, parsing, and validation:

javascript

```javascript
import { GraphQLScalarType, Kind } from 'graphql';

const DateTimeScalar = new GraphQLScalarType({
  name: 'DateTime',
  description: 'ISO 8601 UTC datetime string',

  // Serialize: called when sending data to the client
  serialize(value) {
    if (value instanceof Date) return value.toISOString();
    if (typeof value === 'string') return value;
    throw new Error('DateTime must be a Date or ISO string');
  },

  // ParseValue: called when receiving variable input
  parseValue(value) {
    if (typeof value !== 'string') throw new Error('DateTime must be a string');
    const date = new Date(value);
    if (isNaN(date.getTime())) throw new Error('Invalid DateTime');
    return date;
  },

  // ParseLiteral: called when receiving inline literal input
  parseLiteral(ast) {
    if (ast.kind !== Kind.STRING) throw new Error('DateTime must be a string literal');
    return new Date(ast.value);
  },
});
```

**Registration in Mercurius:**

javascript

```javascript
const schema = `
  scalar DateTime

  type Event {
    id: ID!
    name: String!
    startsAt: DateTime!
  }

  type Query {
    event(id: ID!): Event
  }
`;

await fastify.register(mercurius, {
  schema,
  resolvers: {
    Query: {
      event: async (parent, args, context) =>
        context.db.events.findById(args.id),
    },
  },
  // Pass custom scalar implementations
  schemaTransforms: [],       // [Unverified] verify exact API for custom scalars
});
```

[Unverified] The mechanism for registering custom scalar implementations in Mercurius varies by version — some versions accept a `buildFederationSchema` override or require building a `GraphQLSchema` object directly with `graphql-js` and passing it instead of an SDL string. Verify against your installed version.

**Alternative — build schema programmatically and inject scalar:**

javascript

```javascript
import { buildSchema, addResolversToSchema } from 'graphql-tools'; // or graphql-js directly

// Pass a GraphQLSchema object instead of SDL string
await fastify.register(mercurius, {
  schema: builtSchema, // GraphQLSchema instance with custom scalars attached
  resolvers,
});
```

---

### Object Types

Object types define the shape of entities returned by the API:

javascript

```javascript
const schema = `
  type Author {
    id: ID!
    name: String!
    bio: String
    posts: [Post!]!
  }

  type Post {
    id: ID!
    title: String!
    body: String!
    publishedAt: String
    author: Author!
  }

  type Query {
    post(id: ID!): Post
    posts(authorId: ID): [Post!]!
  }
`;
```

**Resolvers:**

javascript

```javascript
const resolvers = {
  Query: {
    post: async (parent, args, context) =>
      context.db.posts.findById(args.id),

    posts: async (parent, args, context) =>
      context.db.posts.findAll({ authorId: args.authorId }),
  },

  Post: {
    // Field resolver — called for each Post object resolved by Query
    author: async (parent, args, context) => {
      // parent is the Post object; parent.authorId is the FK
      return context.db.authors.findById(parent.authorId);
    },

    // If the DB column is 'published_at' but schema field is 'publishedAt'
    publishedAt: (parent) => parent.published_at ?? null,
  },
};
```

**Key Points:**

- Field resolvers on object types are optional when the property name matches the field name exactly
- [Inference] Default field resolvers use `parent[fieldName]` — if the data source uses snake_case keys and the schema uses camelCase, explicit field resolvers are required for every mismatched field
- Field resolvers receive the full parent object — avoid re-fetching the parent from the database inside a field resolver; use the parent value directly

---

### Input Types

Input types define the shape of complex mutation arguments. They are distinct from output types and cannot contain fields that resolve to output object types:

javascript

```javascript
const schema = `
  input CreatePostInput {
    title: String!
    body: String!
    authorId: ID!
    tags: [String!]
  }

  input UpdatePostInput {
    title: String
    body: String
    tags: [String!]
  }

  type Mutation {
    createPost(input: CreatePostInput!): Post!
    updatePost(id: ID!, input: UpdatePostInput!): Post
  }
`;
```

**Resolver:**

javascript

```javascript
const resolvers = {
  Mutation: {
    createPost: async (parent, args, context) => {
      // args.input is typed and validated by graphql-js
      const { title, body, authorId, tags } = args.input;
      return context.db.posts.create({ title, body, authorId, tags });
    },

    updatePost: async (parent, args, context) => {
      const existing = await context.db.posts.findById(args.id);
      if (!existing) return null;
      return context.db.posts.update(args.id, args.input);
    },
  },
};
```

**Key Points:**

- Input type fields use the same scalar and non-null rules as output types
- Input types cannot be reused as output types — they are a separate category in the GraphQL type system
- [Inference] Using a single input wrapper (`input: CreatePostInput!`) rather than many positional arguments is conventional and makes schema evolution easier — adding optional fields to an input type is non-breaking

---

### Enums

Enums restrict a field or argument to a fixed set of values:

javascript

```javascript
const schema = `
  enum PostStatus {
    DRAFT
    PUBLISHED
    ARCHIVED
  }

  type Post {
    id: ID!
    title: String!
    status: PostStatus!
  }

  input PostFilterInput {
    status: PostStatus
  }

  type Query {
    posts(filter: PostFilterInput): [Post!]!
  }
`;
```

**Resolver:**

javascript

```javascript
const resolvers = {
  Query: {
    posts: async (parent, args, context) => {
      return context.db.posts.findAll({ status: args.filter?.status });
    },
  },
};
```

**Key Points:**

- Enum values are transmitted as strings over the wire
- In resolvers, enum values arrive as plain strings matching the SDL-defined names (`'DRAFT'`, `'PUBLISHED'`, etc.)
- [Inference] If the database stores different values (e.g., integers or lowercase strings), mapping must be done in the resolver or context layer — GraphQL does not perform this mapping automatically

---

### Interfaces

Interfaces define a shared field contract that multiple types must implement:

javascript

```javascript
const schema = `
  interface Node {
    id: ID!
  }

  interface Timestamped {
    createdAt: String!
    updatedAt: String!
  }

  type Article implements Node & Timestamped {
    id: ID!
    createdAt: String!
    updatedAt: String!
    title: String!
    content: String!
  }

  type Comment implements Node & Timestamped {
    id: ID!
    createdAt: String!
    updatedAt: String!
    body: String!
    postId: ID!
  }

  type Query {
    node(id: ID!): Node
  }
`;
```

**Resolvers — `__resolveType` is required for abstract types:**

javascript

```javascript
const resolvers = {
  Node: {
    __resolveType(obj) {
      // obj is the raw value returned by a resolver returning the Node interface
      // Must return the type name as a string
      if (obj.title !== undefined) return 'Article';
      if (obj.body !== undefined) return 'Comment';
      return null; // null causes a GraphQL execution error
    },
  },

  Query: {
    node: async (parent, args, context) => {
      return context.db.nodes.findById(args.id);
    },
  },
};
```

**Key Points:**

- `__resolveType` is mandatory for interfaces and unions — without it, Mercurius cannot determine which concrete type to use for serialization
- `__resolveType` receives the raw parent value and must return a type name string matching a type defined in the schema
- [Inference] A common pattern is to include a `__typename` or `type` field on the raw data object and return it from `__resolveType` — this avoids field-inspection heuristics

---

### Unions

Unions group multiple types under a single field without requiring shared fields:

javascript

```javascript
const schema = `
  type ImageResult {
    url: String!
    width: Int!
    height: Int!
  }

  type VideoResult {
    url: String!
    durationSeconds: Int!
  }

  union SearchResult = ImageResult | VideoResult

  type Query {
    search(query: String!): [SearchResult!]!
  }
`;

const resolvers = {
  SearchResult: {
    __resolveType(obj) {
      if (obj.width !== undefined) return 'ImageResult';
      if (obj.durationSeconds !== undefined) return 'VideoResult';
      return null;
    },
  },

  Query: {
    search: async (parent, args, context) =>
      context.db.media.search(args.query),
  },
};
```

**Client query using inline fragments:**

graphql

```graphql
query {
  search(query: "fastify") {
    ... on ImageResult {
      url
      width
    }
    ... on VideoResult {
      url
      durationSeconds
    }
  }
}
```

---

### Schema Composition with `makeExecutableSchema`

For large schemas, splitting SDL across multiple files and merging them is cleaner than one large string. `@graphql-tools/schema` provides `makeExecutableSchema`:

bash

```bash
npm install @graphql-tools/schema
```

javascript

```javascript
// schema/user.js
export const userTypeDefs = `
  type User {
    id: ID!
    name: String!
  }

  type Query {
    user(id: ID!): User
  }
`;

export const userResolvers = {
  Query: {
    user: async (parent, args, context) =>
      context.db.users.findById(args.id),
  },
};
```

javascript

```javascript
// schema/post.js
export const postTypeDefs = `
  type Post {
    id: ID!
    title: String!
  }

  extend type Query {
    post(id: ID!): Post
  }
`;

export const postResolvers = {
  Query: {
    post: async (parent, args, context) =>
      context.db.posts.findById(args.id),
  },
};
```

javascript

```javascript
// schema/index.js
import { makeExecutableSchema } from '@graphql-tools/schema';
import { userTypeDefs, userResolvers } from './user.js';
import { postTypeDefs, postResolvers } from './post.js';

export const schema = makeExecutableSchema({
  typeDefs: [userTypeDefs, postTypeDefs],
  resolvers: [userResolvers, postResolvers],
});
```

javascript

```javascript
// server.js
import { schema } from './schema/index.js';

await fastify.register(mercurius, { schema });
```

**Key Points:**

- `extend type Query` adds fields to an already-defined type — this allows each module to contribute its own query fields without a central definition
- `makeExecutableSchema` merges type definitions and resolver maps — duplicate type names without `extend` produce an error
- [Inference] This pattern scales to large schemas — each domain module owns its types, resolvers, and loaders independently
- `@graphql-tools/schema` is a separate package from `graphql-js` — [Unverified] verify version compatibility with your installed `graphql` package

---

### Resolver Execution Model

Understanding when and how resolvers are called prevents common mistakes:

```
Query: { post, author }   ← root resolvers called first (parallel)
  Post.author             ← field resolver called after Post resolved
  Post.comments           ← field resolver called after Post resolved
    Comment.author        ← field resolver called after each Comment resolved
```

<svg viewBox="0 0 720 380" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="12">
<rect width="720" height="380" fill="#0f1117" rx="12"/>
<text x="360" y="28" text-anchor="middle" fill="#e2e8f0" font-size="14" font-weight="bold">Resolver Execution Tree</text>
<!-- Root -->
<rect x="290" y="50" width="140" height="38" rx="6" fill="#1e293b" stroke="#7dd3fc" stroke-width="1.5"/>
<text x="360" y="65" text-anchor="middle" fill="#7dd3fc" font-size="11">Query.post(id)</text>
<text x="360" y="81" text-anchor="middle" fill="#94a3b8" font-size="10">root resolver</text>
<!-- Down to Post -->
<line x1="360" y1="88" x2="360" y2="118" stroke="#475569" stroke-width="1.5" marker-end="url(#ra)"/>
<!-- Post object -->
<rect x="270" y="118" width="180" height="38" rx="6" fill="#1e293b" stroke="#86efac" stroke-width="1.5"/>
<text x="360" y="133" text-anchor="middle" fill="#86efac" font-size="11">Post { id, title, ... }</text>
<text x="360" y="149" text-anchor="middle" fill="#94a3b8" font-size="10">parent object for field resolvers</text>
<!-- Left branch: author -->
<line x1="300" y1="156" x2="180" y2="196" stroke="#475569" stroke-width="1.5" marker-end="url(#ra)"/>
<rect x="80" y="196" width="180" height="38" rx="6" fill="#1e293b" stroke="#a78bfa" stroke-width="1"/>
<text x="170" y="211" text-anchor="middle" fill="#a78bfa" font-size="11">Post.author resolver</text>
<text x="170" y="227" text-anchor="middle" fill="#94a3b8" font-size="10">parent.authorId → DB</text>
<!-- author result -->
<line x1="170" y1="234" x2="170" y2="264" stroke="#475569" stroke-width="1.5" marker-end="url(#ra)"/>
<rect x="80" y="264" width="180" height="38" rx="6" fill="#1e293b" stroke="#a78bfa" stroke-width="1"/>
<text x="170" y="280" text-anchor="middle" fill="#a78bfa" font-size="11">Author { id, name }</text>
<text x="170" y="296" text-anchor="middle" fill="#94a3b8" font-size="10">default field resolvers</text>
<!-- Right branch: comments -->
<line x1="420" y1="156" x2="540" y2="196" stroke="#475569" stroke-width="1.5" marker-end="url(#ra)"/>
<rect x="450" y="196" width="200" height="38" rx="6" fill="#1e293b" stroke="#f9a8d4" stroke-width="1"/>
<text x="550" y="211" text-anchor="middle" fill="#f9a8d4" font-size="11">Post.comments resolver</text>
<text x="550" y="227" text-anchor="middle" fill="#94a3b8" font-size="10">parent.id → DB (N+1 risk)</text>
<!-- comments result -->
<line x1="550" y1="234" x2="550" y2="264" stroke="#475569" stroke-width="1.5" marker-end="url(#ra)"/>
<rect x="450" y="264" width="200" height="38" rx="6" fill="#1e293b" stroke="#f9a8d4" stroke-width="1"/>
<text x="550" y="280" text-anchor="middle" fill="#f9a8d4" font-size="11">[Comment, Comment, ...]</text>
<text x="550" y="296" text-anchor="middle" fill="#94a3b8" font-size="10">→ use Loader to batch</text>
<!-- Legend -->
<rect x="270" y="330" width="180" height="34" rx="5" fill="#0f172a" stroke="#334155" stroke-width="1"/>
<text x="360" y="345" text-anchor="middle" fill="#94a3b8" font-size="10">Field resolvers at same depth</text>
<text x="360" y="359" text-anchor="middle" fill="#94a3b8" font-size="10">resolve concurrently by default</text>
<defs>
<marker id="ra" markerWidth="7" markerHeight="7" refX="5" refY="3" orient="auto">
<path d="M0,0 L0,6 L7,3 z" fill="#475569"/>
</marker>
</defs>
</svg>

**Key Points:**

- Root resolvers (`Query.*`, `Mutation.*`) are called first
- Field resolvers on object types are called only when the query requests those fields — unrequested fields are never resolved
- [Inference] Field resolvers at the same level of the tree are executed concurrently by `graphql-js` when they return Promises — the exact concurrency behavior depends on the `graphql-js` version
- Mutations are an exception: root mutation fields execute serially, in order — this is guaranteed by the GraphQL specification

---

### Default Field Resolvers

When no explicit field resolver is defined, `graphql-js` uses the default resolver:

javascript

```javascript
// Default resolver (internal to graphql-js — shown for illustration)
function defaultFieldResolver(source, args, context, info) {
  const fieldName = info.fieldName;
  const value = source[fieldName];
  if (typeof value === 'function') {
    return source[fieldName](args, context, info);
  }
  return value;
}
```

**Key Points:**

- Default resolvers cover the common case where the parent object has a property matching the field name exactly
- [Inference] If the data source returns objects with property names differing from schema field names, all mismatched fields require explicit resolvers — there is no automatic camelCase conversion
- A field returning `undefined` from the default resolver does not produce an error for nullable fields — it resolves to `null`

---

### Argument Validation

GraphQL validates argument types before resolvers are called. Additional business-level validation belongs in the resolver:

javascript

```javascript
const schema = `
  type Query {
    posts(limit: Int, offset: Int): [Post!]!
  }
`;

const resolvers = {
  Query: {
    posts: async (parent, args, context) => {
      const limit = Math.min(args.limit ?? 20, 100); // Cap at 100
      const offset = Math.max(args.offset ?? 0, 0);  // Floor at 0

      if (limit < 1) {
        throw new mercurius.ErrorWithProps(
          'limit must be at least 1',
          { code: 'INVALID_ARGUMENT' },
          400
        );
      }

      return context.db.posts.findAll({ limit, offset });
    },
  },
};
```

**Key Points:**

- GraphQL type validation (e.g., `Int` vs `String`) is handled before the resolver is invoked — the resolver will not be called with a type mismatch
- Range validation, business rules, and cross-field constraints are always the resolver's responsibility
- [Inference] Throwing `ErrorWithProps` inside a resolver produces a structured entry in the `errors` array — it does not prevent other independent fields in the query from resolving

---

### Putting It Together — Full Example

javascript

```javascript
import Fastify from 'fastify';
import mercurius from 'mercurius';

const fastify = Fastify({ logger: true });

const schema = `
  enum Status {
    ACTIVE
    INACTIVE
  }

  type User {
    id: ID!
    name: String!
    status: Status!
    posts: [Post!]!
  }

  type Post {
    id: ID!
    title: String!
    author: User!
  }

  input CreateUserInput {
    name: String!
  }

  type Query {
    user(id: ID!): User
    users(status: Status): [User!]!
  }

  type Mutation {
    createUser(input: CreateUserInput!): User!
  }
`;

// In-memory store for illustration
const store = {
  users: [
    { id: '1', name: 'Luke', status: 'ACTIVE' },
    { id: '2', name: 'Ada', status: 'INACTIVE' },
  ],
  posts: [
    { id: '101', title: 'Fastify Basics', authorId: '1' },
    { id: '102', title: 'GraphQL Patterns', authorId: '1' },
  ],
};

const resolvers = {
  Query: {
    user: async (_, args) =>
      store.users.find(u => u.id === args.id) ?? null,

    users: async (_, args) =>
      args.status
        ? store.users.filter(u => u.status === args.status)
        : store.users,
  },

  Mutation: {
    createUser: async (_, args) => {
      const user = {
        id: String(store.users.length + 1),
        name: args.input.name,
        status: 'ACTIVE',
      };
      store.users.push(user);
      return user;
    },
  },

  User: {
    posts: (parent) =>
      store.posts.filter(p => p.authorId === parent.id),
  },

  Post: {
    author: (parent) =>
      store.users.find(u => u.id === parent.authorId) ?? null,
  },
};

await fastify.register(mercurius, {
  schema,
  resolvers,
  graphiql: true,
});

await fastify.listen({ port: 3000 });
```

---

**Related Topics:**

- Mercurius loaders (batching and N+1 prevention in depth)
- Custom scalars with `graphql-scalars` library
- Code-first schema generation with TypeScript (vs SDL-first)
- Schema directives and custom directive implementation in Mercurius
- Input validation libraries with GraphQL (e.g., `zod` in resolvers)
- Schema evolution and versioning strategies (deprecation, additive changes)
- Splitting and merging schemas across modules with `@graphql-tools/merge`
- Abstract types in depth: interfaces vs unions decision framework
- Testing individual resolvers in isolation