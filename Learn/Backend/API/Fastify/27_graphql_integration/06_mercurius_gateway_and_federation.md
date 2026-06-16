## Mercurius Gateway and Federation

### What is GraphQL Federation

GraphQL Federation is an architectural pattern for composing a single unified GraphQL API from multiple independently deployed **subgraph** services. Each subgraph owns a slice of the overall schema and can be developed, deployed, and scaled independently. A **gateway** service stitches the subgraph schemas together and routes incoming queries to the appropriate services.

Mercurius implements federation natively without requiring Apollo Server, making it a Fastify-native option for both subgraphs and the gateway layer.

**Key Points**

- Federation solves schema ownership at organizational scale — different teams own different subgraphs
- The gateway is the single entry point clients interact with; subgraphs are internal services
- Mercurius federation follows the Apollo Federation v1 specification — compatibility with Apollo Gateway is [Inference] likely but not guaranteed across all features
- Each subgraph is a fully functional standalone GraphQL server

---

### Core Federation Concepts

| Concept | Description |
| --- | --- |
| **Subgraph** | An independent GraphQL service exposing a partial schema |
| **Gateway** | The composition layer that merges subgraph schemas and routes queries |
| **Entity** | A type shared across subgraphs, identified by a primary key |
| **`@key` directive** | Marks the field(s) that uniquely identify an entity |
| **`@external`** | Marks a field defined in another subgraph but referenced here |
| **`@requires`** | Declares fields from another subgraph needed to resolve a local field |
| **`@provides`** | Declares fields a subgraph can resolve for an entity it returns |
| **`_entities` query** | Auto-generated query the gateway uses to fetch entities from subgraphs |
| **`_service` query** | Auto-generated query that returns the subgraph's SDL for schema composition |

---

### Installing Dependencies

bash

```bash
# On each subgraph and the gateway
npm install fastify mercurius

# Gateway additionally needs
npm install @mercuriusjs/gateway

# Or using the mercurius ecosystem package
npm install mercurius-gateway
```

[Unverified] Package names and availability may differ between mercurius versions. Verify against the installed version's changelog and npm registry.

---

### Defining a Subgraph: Users Service

A subgraph that owns the `User` type:

js

```js
// services/users/index.js
import Fastify from 'fastify'
import mercurius from 'mercurius'

const app = Fastify({ logger: true })

const schema = `
  # Federation directives must be declared
  type Query {
    me: User
    userById(id: ID!): User
  }

  type User @key(fields: "id") {
    id: ID!
    name: String!
    email: String!
    role: String!
  }
`

const resolvers = {
  Query: {
    me: async (_, __, { user }) => {
      return db.getUserById(user?.id)
    },
    userById: async (_, { id }) => {
      return db.getUserById(id)
    }
  },
  User: {
    // __resolveReference is called by the gateway when it needs to
    // resolve a User entity by its @key field(s)
    __resolveReference: async (reference) => {
      // reference: { __typename: 'User', id: '...' }
      return db.getUserById(reference.id)
    }
  }
}

await app.register(mercurius, {
  schema,
  resolvers,
  federationMetadata: true   // Enables _service and _entities queries
})

await app.listen({ port: 4001 })
```

**Key Points**

- `federationMetadata: true` is required on every subgraph — it exposes `_service` (SDL introspection) and `_entities` (entity resolution) to the gateway
- `__resolveReference` is a special resolver called only by the gateway, not by external clients
- The `@key` directive tells the gateway which field(s) form the entity's primary key

---

### Defining a Subgraph: Posts Service

A subgraph that owns the `Post` type and extends `User`:

js

```js
// services/posts/index.js
import Fastify from 'fastify'
import mercurius from 'mercurius'

const app = Fastify({ logger: true })

const schema = `
  type Query {
    post(id: ID!): Post
    postsByUser(userId: ID!): [Post!]!
  }

  # Extend User from the Users subgraph — reference only, no ownership
  extend type User @key(fields: "id") {
    id: ID! @external
    posts: [Post!]!
  }

  type Post @key(fields: "id") {
    id: ID!
    title: String!
    body: String!
    authorId: ID!
    author: User!
  }
`

const resolvers = {
  Query: {
    post: async (_, { id }) => db.getPost(id),
    postsByUser: async (_, { userId }) => db.getPostsByUser(userId)
  },
  Post: {
    __resolveReference: async (ref) => db.getPost(ref.id),
    author: async (post) => ({ __typename: 'User', id: post.authorId })
  },
  User: {
    posts: async (user) => db.getPostsByUser(user.id)
  }
}

await app.register(mercurius, {
  schema,
  resolvers,
  federationMetadata: true
})

await app.listen({ port: 4002 })
```

**Key Points**

- `extend type User` declares that this subgraph extends a type owned elsewhere — it does not redefine the full type
- `@external` marks `id` as a field owned by the Users subgraph, required here only as a reference key
- Returning `{ __typename: 'User', id: post.authorId }` from `author` gives the gateway enough to fetch the full `User` entity from the Users subgraph
- `posts` on the extended `User` is owned by Posts — the gateway routes `User.posts` resolution here

---

### Setting Up the Gateway

js

```js
// gateway/index.js
import Fastify from 'fastify'
import mercuriusGateway from '@mercuriusjs/gateway'

const app = Fastify({ logger: true })

await app.register(mercuriusGateway, {
  gateway: {
    services: [
      {
        name: 'users',
        url: 'http://localhost:4001/graphql'
      },
      {
        name: 'posts',
        url: 'http://localhost:4002/graphql'
      }
    ]
  }
})

await app.listen({ port: 4000 })
```

At startup, the gateway:

1. Fetches each subgraph's SDL via the `_service` query
2. Composes the schemas into a single unified schema
3. Begins routing incoming queries to the appropriate subgraphs

---

### Schema Composition at the Gateway

The gateway merges subgraph schemas automatically. Given the Users and Posts subgraphs above, the composed schema exposed to clients is:

graphql

```graphql
type Query {
  me: User
  userById(id: ID!): User
  post(id: ID!): Post
  postsByUser(userId: ID!): [Post!]!
}

type User {
  id: ID!
  name: String!
  email: String!
  role: String!
  posts: [Post!]!         # contributed by Posts subgraph
}

type Post {
  id: ID!
  title: String!
  body: String!
  authorId: ID!
  author: User!
}
```

Clients see a single coherent schema. The federation machinery is invisible to them.

---

### Query Planning and Execution

When the gateway receives a query, it constructs a **query plan**: a dependency graph of subgraph requests needed to fulfill the operation.

**Example client query:**

graphql

```graphql
query {
  userById(id: "1") {
    name
    posts {
      title
      author {
        email
      }
    }
  }
}
```

**Gateway query plan (conceptual):**

```
1. Fetch User { name } from Users subgraph
   → userById(id: "1")

2. Fetch Post[] { title, authorId } from Posts subgraph
   → User.posts resolver with { __typename: "User", id: "1" }

3. Fetch User { email } from Users subgraph for each post's authorId
   → _entities query with [{ __typename: "User", id: ... }, ...]
```

**Key Points**

- The gateway uses `_entities` to batch-fetch entity references across subgraph boundaries — this is DataLoader-like batching at the federation layer
- Query planning adds latency; the gateway makes multiple subgraph requests for deeply nested cross-service fields
- [Inference] Query plan complexity grows with the depth of cross-service relationships; schema design has a direct impact on gateway performance

---

### Gateway Configuration Options

js

```js
await app.register(mercuriusGateway, {
  gateway: {
    services: [
      {
        name: 'users',
        url: 'http://users-service/graphql',

        // Custom headers forwarded to the subgraph on every request
        setResponseHeaders: (reply) => {
          // [Unverified] — API shape may differ; verify with installed version
        },

        // Mandatory fields: used when schema polling fails
        // [Inference] likely used as a fallback schema
        // rewriteHeaders: (headers) => ({ ...headers, 'x-service': 'users' })
      },
      {
        name: 'posts',
        url: 'http://posts-service/graphql'
      }
    ],

    // Poll subgraphs for schema changes at this interval (ms)
    pollingInterval: 2000
  },

  // Standard mercurius options still apply at the gateway
  graphiql: true,
  jit: 1
})
```

---

### Schema Polling and Hot Reload

In production, subgraph schemas may change independently as services are redeployed. Mercurius gateway supports polling subgraphs to detect schema changes:

js

```js
await app.register(mercuriusGateway, {
  gateway: {
    services: [...],
    pollingInterval: 5000  // Check every 5 seconds
  }
})

// Listen for schema refresh events
app.graphql.gateway.on('schemaUpdated', (schema) => {
  app.log.info('Gateway schema recomposed after subgraph update')
})
```

**Key Points**

- Polling adds a small overhead per interval — balance interval duration against acceptable schema staleness
- Schema recomposition is non-disruptive to in-flight requests [Inference] — in-progress queries use the prior schema until completion; this behavior may vary
- In Kubernetes environments, polling may be replaced with event-driven recomposition triggered by deployment webhooks [Speculation]

---

### Forwarding Headers from Gateway to Subgraphs

Authentication context (e.g., JWT) must be forwarded from the gateway to subgraphs so they can perform their own authorization:

js

```js
await app.register(mercuriusGateway, {
  gateway: {
    services: [
      {
        name: 'users',
        url: 'http://users-service/graphql',
        rewriteHeaders: (headers, context) => {
          // Forward the original Authorization header to the subgraph
          return {
            authorization: headers.authorization,
            'x-request-id': context.requestId
          }
        }
      }
    ]
  },
  context: async (request, reply) => ({
    requestId: request.id,
    user: await verifyToken(request)
  })
})
```

On each subgraph, reconstruct auth context from the forwarded headers:

js

```js
// users subgraph context function
context: async (request, reply) => {
  const user = await verifyToken(request)  // reads forwarded Authorization header
  return { user }
}
```

**Key Points**

- Subgraphs are internal services — they should still verify tokens, not blindly trust headers
- Passing a machine-to-machine service token between internal services is an alternative pattern where the gateway verifies the client token and issues its own service token to subgraphs [Inference]
- `rewriteHeaders` can selectively forward, transform, or add headers per subgraph

---

### Entity References and `__resolveReference`

When the gateway needs a field from a subgraph that it did not originally fetch from, it sends an `_entities` query with entity references:

graphql

```graphql
# Gateway sends to Users subgraph
query {
  _entities(representations: [
    { __typename: "User", id: "10" },
    { __typename: "User", id: "20" }
  ]) {
    ... on User { email }
  }
}
```

The Users subgraph handles this via `__resolveReference`:

js

```js
User: {
  __resolveReference: async ({ id }) => {
    // Called once per entity reference
    // DataLoader batching applies here for N+1 mitigation
    return userLoader.load(id)
  }
}
```

**Key Points**

- The gateway batches multiple entity references into a single `_entities` call
- Within a subgraph, `__resolveReference` may still be called multiple times per `_entities` request — DataLoader inside `__resolveReference` mitigates N+1 at the subgraph level
- `__resolveReference` must return the full entity object (or a subset sufficient for the requested fields), not just the key

---

### Using `@requires` and `@provides`

#### `@requires` — Declaring Cross-Subgraph Field Dependencies

graphql

```graphql
# Reviews subgraph — needs User.email to compute something
extend type User @key(fields: "id") {
  id: ID! @external
  email: String! @external
  reviewSummary: String! @requires(fields: "email")
}
```

js

```js
User: {
  reviewSummary: async (user) => {
    // user.email is populated by the gateway from the Users subgraph
    return generateSummary(user.email)
  }
}
```

**Key Points**

- `@requires` tells the gateway to fetch `email` from the Users subgraph before calling the Reviews subgraph resolver
- This creates an explicit data dependency and adds a gateway round-trip [Inference]
- Overusing `@requires` increases query plan depth; prefer denormalizing data into subgraph-local fields where feasible

#### `@provides` — Optimizing by Declaring Locally Available Fields

graphql

```graphql
type Post @key(fields: "id") {
  id: ID!
  title: String!
  author: User! @provides(fields: "name")
}

extend type User @key(fields: "id") {
  id: ID! @external
  name: String! @external
}
```

js

```js
Post: {
  author: async (post) => ({
    __typename: 'User',
    id: post.authorId,
    name: post.authorName  // already fetched with the post row
  })
}
```

**Key Points**

- `@provides(fields: "name")` tells the gateway that when resolving `Post.author`, the `name` field is already available — no additional Users subgraph request needed
- This is a performance optimization: it trades data denormalization for fewer subgraph round-trips
- The provided fields must actually be returned by the resolver — the gateway trusts `@provides` declarations

---

### Subscription Support in Federation

[Unverified] Mercurius gateway support for federated subscriptions is limited or unavailable in some versions. Verify with the specific installed version before relying on this.

For subscriptions in federated architectures, common patterns include:

- Handling subscriptions directly at individual subgraphs (bypassing the gateway)
- Using a dedicated subscription service that clients connect to separately [Inference]
- Schema stitching with `graphql-ws` at the gateway layer [Speculation]

---

### Diagram: Federation Request Flow

Posts Subgraph (:4002)Users Subgraph (:4001)Gateway (:4000)ClientPosts Subgraph (:4002)Users Subgraph (:4001)Gateway (:4000)Clientquery { userById(id:"1") { name posts { title author { email } } } }query { userById(id:"1") { name } }{ id: "1", name: "Alice" }_entities([{ __typename:"User", id:"1" }]) { posts { title authorId } }{ posts: [{ title: "...", authorId: "2" }] }_entities([{ __typename:"User", id:"2" }]) { email }{ email: "bob@example.com" }Composed response

---

### Subgraph Service Health and Resilience

js

```js
await app.register(mercuriusGateway, {
  gateway: {
    services: [
      {
        name: 'users',
        url: 'http://users-service/graphql',

        // [Unverified] — timeout and retry options: verify with installed version
        // timeout: 5000,
        // retries: 2
      }
    ],
    pollingInterval: 3000
  }
})

// Handle subgraph unavailability
app.graphql.gateway.on('serviceUnavailable', ({ name, error }) => {
  app.log.error({ service: name, err: error }, 'Subgraph unavailable')
  // Alert or fallback logic here
})
```

**Key Points**

- A single unavailable subgraph can cause partial query failures — only fields owned by that subgraph are affected [Inference]
- Circuit breaker patterns at the HTTP client level reduce cascading failures between gateway and subgraphs [Inference]
- Subgraph readiness probes (Fastify `/health` routes) should be part of the deployment configuration

---

### Introspection and GraphiQL at the Gateway

The gateway exposes the composed schema for introspection by default. In production:

js

```js
await app.register(mercuriusGateway, {
  gateway: { services: [...] },
  graphiql: process.env.NODE_ENV !== 'production',
})

// Disable introspection via preValidation hook if needed
app.addHook('preValidation', async (request, reply) => {
  if (process.env.NODE_ENV === 'production') {
    const body = request.body
    if (typeof body?.query === 'string' && body.query.includes('__schema')) {
      reply.code(403).send({ error: 'Introspection disabled in production' })
    }
  }
})
```

---

### Local Development Setup

Running all services locally with minimal tooling:

js

```js
// dev/start-all.js
import { spawn } from 'child_process'

const services = [
  { name: 'users',   script: 'services/users/index.js',   port: 4001 },
  { name: 'posts',   script: 'services/posts/index.js',   port: 4002 },
  { name: 'gateway', script: 'gateway/index.js',          port: 4000 },
]

for (const svc of services) {
  const proc = spawn('node', [svc.script], {
    env: { ...process.env, PORT: svc.port },
    stdio: 'inherit'
  })
  proc.on('error', (err) => console.error(`${svc.name} failed:`, err))
}
```

For local development with hot reload, `nodemon` or Fastify's `--watch` flag (Node.js 18+) applies per-service independently.

---

**Related Topics**

- Apollo Federation v2 compatibility with Mercurius gateway
- Schema composition validation with `@apollo/composition` or `graphql-inspector`
- Distributed tracing across subgraphs with OpenTelemetry
- Federated subscriptions: patterns and limitations
- Authorization at the gateway vs. subgraph level: tradeoffs
- Managed federation with Apollo GraphOS as the schema registry
- Schema stitching as an alternative to federation with Mercurius