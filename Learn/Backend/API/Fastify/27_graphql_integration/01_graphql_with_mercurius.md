## GraphQL with Mercurius

### What Is Mercurius

Mercurius is the official GraphQL adapter for Fastify. It integrates GraphQL execution directly into Fastify's request lifecycle, exposing GraphQL over HTTP and WebSocket within the same Fastify instance. It is built on `graphql-js` (the reference GraphQL implementation) and `graphql-ws` for subscription transport.

[Unverified — verify current maintenance status, latest version, and Fastify version compatibility before adopting in production.]

---

### Core Concepts Before Installation

Mercurius maps Fastify concepts to GraphQL concepts:

| Fastify | Mercurius / GraphQL |
| --- | --- |
| Plugin (`fastify.register`) | GraphQL endpoint registration |
| Route handler | Resolver function |
| `request` object | GraphQL context |
| Schema validation | GraphQL type system |
| WebSocket support | Subscription transport |

**Key Points:**

- Mercurius registers a POST `/graphql` endpoint for queries and mutations by default
- It optionally registers a GET `/graphql` endpoint for introspection and persisted queries
- Subscriptions require WebSocket transport, handled internally by Mercurius
- The GraphQL schema is defined separately from Fastify routes and passed to the plugin at registration

---

### Installation

bash

```bash
npm install mercurius graphql
```

`graphql` (the `graphql-js` package) is a peer dependency and must be installed explicitly.

For subscriptions:

bash

```bash
npm install mercurius graphql mercurius-subscription
```

[Unverified] Subscription support may be bundled within `mercurius` itself in some versions — verify against the installed version's documentation.

---

### Basic Registration

javascript

```javascript
import Fastify from 'fastify';
import mercurius from 'mercurius';

const fastify = Fastify({ logger: true });

const schema = `
  type Query {
    hello(name: String): String
  }
`;

const resolvers = {
  Query: {
    hello: async (parent, args, context) => {
      return `Hello, ${args.name ?? 'world'}`;
    },
  },
};

await fastify.register(mercurius, {
  schema,
  resolvers,
  graphiql: true, // Enables GraphiQL UI at /graphiql
});

await fastify.listen({ port: 3000 });
```

**Key Points:**

- `schema` accepts a GraphQL SDL string or a `GraphQLSchema` object built with `graphql-js`
- `resolvers` is a plain object mirroring the schema type structure
- `graphiql: true` mounts an interactive GraphiQL playground — [Inference] disable in production to avoid exposing schema introspection
- The plugin registers `/graphql` as both GET and POST by default — [Unverified] exact route behavior depends on the Mercurius version

---

### Schema Definition Language (SDL)

Mercurius accepts schema as SDL strings, which are parsed internally by `graphql-js`:

javascript

```javascript
const schema = `
  type User {
    id: ID!
    name: String!
    email: String!
    role: Role!
  }

  enum Role {
    ADMIN
    EDITOR
    VIEWER
  }

  type Query {
    user(id: ID!): User
    users(role: Role): [User!]!
  }

  type Mutation {
    createUser(name: String!, email: String!, role: Role!): User!
    deleteUser(id: ID!): Boolean!
  }
`;
```

**Key Points:**

- `!` denotes a non-null field — Mercurius enforces this at the GraphQL execution layer, not at the HTTP layer
- SDL types map directly to resolver keys
- Scalars beyond the built-in set (`String`, `Int`, `Float`, `Boolean`, `ID`) require custom scalar definitions

---

### Resolver Structure

Resolvers mirror the schema type hierarchy:

javascript

```javascript
const resolvers = {
  Query: {
    user: async (parent, args, context) => {
      // args.id is validated as non-null by GraphQL type system
      return context.db.users.findById(args.id);
    },
    users: async (parent, args, context) => {
      return context.db.users.findAll({ role: args.role });
    },
  },

  Mutation: {
    createUser: async (parent, args, context) => {
      return context.db.users.create(args);
    },
    deleteUser: async (parent, args, context) => {
      await context.db.users.delete(args.id);
      return true;
    },
  },

  // Field-level resolver for User type (optional — only needed
  // when field name differs from data source key or requires transformation)
  User: {
    email: (parent, args, context) => {
      // parent is the User object returned by the Query resolver
      return parent.email.toLowerCase();
    },
  },
};
```

**Key Points:**

- Resolver signature is `(parent, args, context, info)`
- `parent` is the resolved value of the parent type — for root Query/Mutation, it is typically `undefined` or `{}`
- `context` is shared across all resolvers in a single request — attach request-scoped dependencies here
- `info` contains AST information about the query — [Inference] rarely needed in application code but useful for advanced use cases like query complexity analysis
- Resolvers may return a value, a Promise, or throw an error — `graphql-js` handles async resolution

---

### Building the Context

The GraphQL context is the mechanism for passing Fastify request data (auth, database connections, services) into resolvers without coupling resolvers to Fastify internals:

javascript

```javascript
await fastify.register(mercurius, {
  schema,
  resolvers,
  context: (request, reply) => {
    // Called once per request before resolution begins
    return {
      user: request.user,         // Populated by auth hook
      db: fastify.db,             // Decorated on the Fastify instance
      logger: request.log,
    };
  },
});
```

**Usage in resolvers:**

javascript

```javascript
const resolvers = {
  Query: {
    user: async (parent, args, context) => {
      context.logger.info({ id: args.id }, 'Fetching user');

      if (!context.user) {
        throw new mercurius.ErrorWithProps('Unauthorized', {}, 401);
      }

      return context.db.users.findById(args.id);
    },
  },
};
```

**Key Points:**

- The `context` function receives the Fastify `request` and `reply` objects — this is where Fastify and GraphQL integration is tightest
- [Inference] Avoid putting mutable shared state into the context — context is per-request but resolvers within a single request share the same context object
- Fastify decorators (e.g., `fastify.db`) are accessible through closure over the `fastify` instance, not through the context directly — pass only what resolvers need

---

### Error Handling

GraphQL errors are returned in the response body under `errors`, not as HTTP error status codes. Mercurius provides `ErrorWithProps` for structured error responses:

javascript

```javascript
import mercurius from 'mercurius';
const { ErrorWithProps } = mercurius;

const resolvers = {
  Query: {
    user: async (parent, args, context) => {
      const user = await context.db.users.findById(args.id);

      if (!user) {
        throw new ErrorWithProps('User not found', {
          code: 'USER_NOT_FOUND',
          id: args.id,
        }, 404);
      }

      return user;
    },
  },
};
```

**Example response for a thrown error:**

json

```json
{
  "data": {
    "user": null
  },
  "errors": [
    {
      "message": "User not found",
      "locations": [{ "line": 2, "column": 3 }],
      "path": ["user"],
      "extensions": {
        "code": "USER_NOT_FOUND",
        "id": "abc123"
      }
    }
  ]
}
```

**Key Points:**

- GraphQL always returns HTTP 200 for application-level errors — HTTP status codes reflect transport errors only
- The third argument to `ErrorWithProps` sets the HTTP status code for the response — [Inference] this is Mercurius-specific behavior and may not apply in other GraphQL servers
- `data` may be partially populated even when `errors` is present — this is standard GraphQL behavior
- Unhandled exceptions in resolvers produce generic error messages — [Inference] Mercurius may mask internal error details in production mode to avoid leaking stack traces; verify this behavior against your version

---

### Loaders (Solving the N+1 Problem)

The N+1 problem occurs when a list query resolves N items, each triggering an individual database call for related data:

```
Query: users (1 DB call)
  → user[0].posts  (1 DB call)
  → user[1].posts  (1 DB call)
  → user[N].posts  (N DB calls)
Total: N+1 calls
```

Mercurius solves this with **loaders**, which batch field resolution across all instances of a type within a single query:

javascript

```javascript
const resolvers = {
  Query: {
    users: async (parent, args, context) => {
      return context.db.users.findAll();
    },
  },
};

const loaders = {
  User: {
    async posts(queries, context) {
      // queries = [{ obj: user1, params: {} }, { obj: user2, params: {} }, ...]
      // All users needing posts are batched into a single call
      const userIds = queries.map(({ obj }) => obj.id);
      const allPosts = await context.db.posts.findByUserIds(userIds);

      // Return results in the same order as queries
      return queries.map(({ obj }) =>
        allPosts.filter(post => post.userId === obj.id)
      );
    },
  },
};

await fastify.register(mercurius, {
  schema,
  resolvers,
  loaders,
  context: (request) => ({ db: fastify.db }),
});
```

**Key Points:**

- `loaders` is a Mercurius-specific concept — it is not part of the GraphQL spec
- [Inference] Loaders function similarly to the `DataLoader` library pattern but are built into Mercurius without requiring a separate dependency
- The return array from a loader must match the length and order of the input `queries` array — mismatches produce incorrect field resolution
- [Inference] Loaders are called once per field per query, regardless of how many parent objects need that field — this is the batching guarantee

---

### Subscriptions

Mercurius supports GraphQL subscriptions over WebSocket. Subscriptions require a pub/sub mechanism — Mercurius provides a built-in in-memory pub/sub, or an external one can be supplied.

#### Schema with Subscription Type

javascript

```javascript
const schema = `
  type Query {
    _empty: String
  }

  type Mutation {
    addMessage(content: String!): Message!
  }

  type Message {
    id: ID!
    content: String!
    createdAt: String!
  }

  type Subscription {
    messageSent: Message!
  }
`;
```

#### Registration with Subscriptions

javascript

```javascript
import mercurius from 'mercurius';

await fastify.register(mercurius, {
  schema,
  resolvers,
  subscription: true, // Enables WebSocket subscription support
});
```

#### Subscription Resolvers

javascript

```javascript
const TOPIC = 'MESSAGE_SENT';

const resolvers = {
  Mutation: {
    addMessage: async (parent, args, context) => {
      const message = {
        id: String(Date.now()),
        content: args.content,
        createdAt: new Date().toISOString(),
      };

      // Publish to the subscription topic
      await fastify.graphql.pubsub.publish({
        topic: TOPIC,
        payload: { messageSent: message },
      });

      return message;
    },
  },

  Subscription: {
    messageSent: {
      // subscribe defines the async iterable the client listens on
      subscribe: async (parent, args, context) => {
        return await context.pubsub.subscribe(TOPIC);
      },
    },
  },
};
```

**Key Points:**

- `fastify.graphql.pubsub` is the built-in in-memory pub/sub — [Inference] it does not persist events or fan out across multiple server instances
- For multi-instance deployments, replace the built-in pub/sub with a Redis-backed implementation — [Unverified] verify available adapters for your Mercurius version
- Subscriptions use WebSocket transport — clients must connect via `ws://` or `wss://`, not HTTP
- [Inference] The built-in pub/sub is suitable for development and single-instance deployments; production multi-node deployments require an external pub/sub

---

### Federation (Schema Stitching)

Mercurius supports Apollo Federation for composing multiple GraphQL services into a unified graph:

javascript

```javascript
await fastify.register(mercurius, {
  schema,
  resolvers,
  federationMetadata: true, // Exposes _service and _entities fields
});
```

[Inference] Federation configuration is a substantial topic beyond basic Mercurius setup. The above enables the federation metadata fields required by a federation gateway — full federation setup requires configuring the gateway separately.

[Unverified] Compatibility between Mercurius federation and Apollo Gateway versions varies — verify before use.

---

### Plugin Architecture and `fastify.graphql`

After registration, Mercurius decorates the Fastify instance with `fastify.graphql`, exposing the GraphQL executor for programmatic use:

javascript

```javascript
// Execute a GraphQL query from within a Fastify route or hook
fastify.get('/internal/user/:id', async (request, reply) => {
  const result = await fastify.graphql(
    `query GetUser($id: ID!) {
       user(id: $id) { id name email }
     }`,
    {},                          // root value
    { user: request.user },      // context
    { id: request.params.id }    // variables
  );

  return result;
});
```

**Key Points:**

- `fastify.graphql` executes queries against the registered schema without going through HTTP
- [Inference] This is useful for server-side data fetching within REST routes or for testing resolvers directly
- The context argument here is manually constructed — it does not automatically use the `context` function registered with the plugin

---

### Request Lifecycle Integration

<svg viewBox="0 0 740 480" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="12">
<rect width="740" height="480" fill="#0f1117" rx="12"/>
<text x="370" y="28" text-anchor="middle" fill="#e2e8f0" font-size="14" font-weight="bold">Mercurius Request Lifecycle in Fastify</text>
<!-- HTTP Request -->
<rect x="30" y="50" width="140" height="40" rx="6" fill="#1e293b" stroke="#7dd3fc" stroke-width="1.5"/>
<text x="100" y="66" text-anchor="middle" fill="#7dd3fc" font-size="11">HTTP Request</text>
<text x="100" y="82" text-anchor="middle" fill="#94a3b8" font-size="10">POST /graphql</text>
<line x1="170" y1="70" x2="205" y2="70" stroke="#475569" stroke-width="1.5" marker-end="url(#ma)"/>
<!-- Fastify lifecycle -->
<rect x="205" y="50" width="140" height="40" rx="6" fill="#1e293b" stroke="#86efac" stroke-width="1.5"/>
<text x="275" y="66" text-anchor="middle" fill="#86efac" font-size="11">Fastify Hooks</text>
<text x="275" y="82" text-anchor="middle" fill="#94a3b8" font-size="10">onRequest · preHandler</text>
<line x1="345" y1="70" x2="380" y2="70" stroke="#475569" stroke-width="1.5" marker-end="url(#ma)"/>
<!-- Context build -->
<rect x="380" y="50" width="140" height="40" rx="6" fill="#1e293b" stroke="#a78bfa" stroke-width="1.5"/>
<text x="450" y="66" text-anchor="middle" fill="#a78bfa" font-size="11">context(req, reply)</text>
<text x="450" y="82" text-anchor="middle" fill="#94a3b8" font-size="10">Build resolver context</text>
<line x1="520" y1="70" x2="555" y2="70" stroke="#475569" stroke-width="1.5" marker-end="url(#ma)"/>
<!-- GraphQL parse -->
<rect x="555" y="50" width="140" height="40" rx="6" fill="#1e293b" stroke="#fbbf24" stroke-width="1.5"/>
<text x="625" y="66" text-anchor="middle" fill="#fbbf24" font-size="11">Parse + Validate</text>
<text x="625" y="82" text-anchor="middle" fill="#94a3b8" font-size="10">graphql-js</text>
<!-- Down from parse -->
<line x1="625" y1="90" x2="625" y2="130" stroke="#475569" stroke-width="1.5" marker-end="url(#ma)"/>
<!-- Execute -->
<rect x="555" y="130" width="140" height="40" rx="6" fill="#1e293b" stroke="#fbbf24" stroke-width="1.5"/>
<text x="625" y="146" text-anchor="middle" fill="#fbbf24" font-size="11">Execute</text>
<text x="625" y="162" text-anchor="middle" fill="#94a3b8" font-size="10">Invoke resolvers</text>
<!-- Resolvers box -->
<line x1="555" y1="150" x2="490" y2="150" stroke="#475569" stroke-width="1.5" marker-end="url(#ma)"/>
<rect x="350" y="130" width="140" height="40" rx="6" fill="#1e293b" stroke="#f9a8d4" stroke-width="1.5"/>
<text x="420" y="146" text-anchor="middle" fill="#f9a8d4" font-size="11">Resolvers</text>
<text x="420" y="162" text-anchor="middle" fill="#94a3b8" font-size="10">Query · Mutation · Field</text>
<!-- Loaders box -->
<line x1="350" y1="150" x2="280" y2="150" stroke="#475569" stroke-width="1.5" marker-end="url(#ma)"/>
<rect x="140" y="130" width="140" height="40" rx="6" fill="#1e293b" stroke="#f9a8d4" stroke-width="1"/>
<text x="210" y="146" text-anchor="middle" fill="#f9a8d4" font-size="11">Loaders</text>
<text x="210" y="162" text-anchor="middle" fill="#94a3b8" font-size="10">Batched field resolution</text>
<!-- Data sources -->
<line x1="210" y1="170" x2="210" y2="210" stroke="#475569" stroke-width="1.5" marker-end="url(#ma)"/>
<rect x="140" y="210" width="140" height="40" rx="6" fill="#1e293b" stroke="#94a3b8" stroke-width="1"/>
<text x="210" y="226" text-anchor="middle" fill="#94a3b8" font-size="11">Data Sources</text>
<text x="210" y="242" text-anchor="middle" fill="#94a3b8" font-size="10">DB · API · Cache</text>
<!-- Response assembly -->
<line x1="625" y1="170" x2="625" y2="210" stroke="#475569" stroke-width="1.5" marker-end="url(#ma)"/>
<rect x="555" y="210" width="140" height="40" rx="6" fill="#1e293b" stroke="#86efac" stroke-width="1.5"/>
<text x="625" y="226" text-anchor="middle" fill="#86efac" font-size="11">Assemble Response</text>
<text x="625" y="242" text-anchor="middle" fill="#94a3b8" font-size="10">{ data, errors }</text>
<!-- HTTP Response -->
<line x1="625" y1="250" x2="625" y2="290" stroke="#475569" stroke-width="1.5" marker-end="url(#ma)"/>
<rect x="555" y="290" width="140" height="40" rx="6" fill="#1e293b" stroke="#7dd3fc" stroke-width="1.5"/>
<text x="625" y="306" text-anchor="middle" fill="#7dd3fc" font-size="11">HTTP Response</text>
<text x="625" y="322" text-anchor="middle" fill="#94a3b8" font-size="10">200 OK · JSON body</text>
<!-- Subscription branch -->
<rect x="30" y="370" width="660" height="90" rx="8" fill="#0f172a" stroke="#334155" stroke-width="1"/>
<text x="360" y="392" text-anchor="middle" fill="#a78bfa" font-size="12" font-weight="bold">Subscription Path (WebSocket)</text>
<rect x="50" y="405" width="130" height="40" rx="6" fill="#1e293b" stroke="#a78bfa" stroke-width="1"/>
<text x="115" y="421" text-anchor="middle" fill="#a78bfa" font-size="10">WS Handshake</text>
<text x="115" y="437" text-anchor="middle" fill="#94a3b8" font-size="9">graphql-ws protocol</text>
<line x1="180" y1="425" x2="210" y2="425" stroke="#475569" stroke-width="1" marker-end="url(#ma)"/>
<rect x="210" y="405" width="130" height="40" rx="6" fill="#1e293b" stroke="#a78bfa" stroke-width="1"/>
<text x="275" y="421" text-anchor="middle" fill="#a78bfa" font-size="10">subscribe resolver</text>
<text x="275" y="437" text-anchor="middle" fill="#94a3b8" font-size="9">returns async iterable</text>
<line x1="340" y1="425" x2="370" y2="425" stroke="#475569" stroke-width="1" marker-end="url(#ma)"/>
<rect x="370" y="405" width="130" height="40" rx="6" fill="#1e293b" stroke="#a78bfa" stroke-width="1"/>
<text x="435" y="421" text-anchor="middle" fill="#a78bfa" font-size="10">pubsub.publish()</text>
<text x="435" y="437" text-anchor="middle" fill="#94a3b8" font-size="9">from Mutation resolver</text>
<line x1="500" y1="425" x2="530" y2="425" stroke="#475569" stroke-width="1" marker-end="url(#ma)"/>
<rect x="530" y="405" width="140" height="40" rx="6" fill="#1e293b" stroke="#a78bfa" stroke-width="1"/>
<text x="600" y="421" text-anchor="middle" fill="#a78bfa" font-size="10">WS frame pushed</text>
<text x="600" y="437" text-anchor="middle" fill="#94a3b8" font-size="9">to subscribed clients</text>
<defs>
<marker id="ma" markerWidth="7" markerHeight="7" refX="5" refY="3" orient="auto">
<path d="M0,0 L0,6 L7,3 z" fill="#475569"/>
</marker>
</defs>
</svg>

---

### Security Considerations

#### Introspection

GraphQL introspection exposes the full schema structure. Disable in production:

javascript

```javascript
await fastify.register(mercurius, {
  schema,
  resolvers,
  graphiql: false,
  allowedQueries: undefined, // Or use persisted queries to restrict
});
```

[Unverified] Mercurius may not have a direct `disableIntrospection` flag — verify the current API. An alternative is to reject introspection queries in a `preExecution` hook.

#### Query Depth and Complexity

Deeply nested or highly complex queries can exhaust server resources. Mercurius supports hooks for adding depth and complexity limits:

javascript

```javascript
await fastify.register(mercurius, {
  schema,
  resolvers,
  validationRules: [
    // Add custom validation rules here
    // e.g., graphql-depth-limit or graphql-query-complexity
  ],
});
```

[Inference] `graphql-depth-limit` and `graphql-query-complexity` are separate packages that produce `graphql-js`-compatible validation rules — [Unverified] verify compatibility with your Mercurius and `graphql-js` versions.

#### Authorization

Authorization belongs in resolvers or context, not in schema type definitions:

javascript

```javascript
context: (request) => ({
  user: request.user ?? null,
}),

// In resolver:
user: async (parent, args, context) => {
  if (!context.user) {
    throw new ErrorWithProps('Unauthorized', { code: 'UNAUTHORIZED' }, 401);
  }
  if (context.user.role !== 'ADMIN') {
    throw new ErrorWithProps('Forbidden', { code: 'FORBIDDEN' }, 403);
  }
  return context.db.users.findById(args.id);
},
```

[Inference] Field-level authorization logic repeated across many resolvers benefits from an abstraction layer (e.g., a shield middleware or a custom directive) — these are application-level patterns not built into Mercurius.

---

### Testing GraphQL Routes

Mercurius registers standard HTTP routes, so `fastify.inject()` works for queries and mutations:

javascript

```javascript
import { test } from 'node:test';
import assert from 'node:assert/strict';

test('hello query', async (t) => {
  const response = await fastify.inject({
    method: 'POST',
    url: '/graphql',
    headers: { 'content-type': 'application/json' },
    payload: JSON.stringify({
      query: `query { hello(name: "Luke") }`,
    }),
  });

  const body = JSON.parse(response.body);
  assert.equal(body.data.hello, 'Hello, Luke');
});
```

**Key Points:**

- `fastify.inject()` works for queries and mutations — both use HTTP POST
- Subscription testing requires a real WebSocket connection — `fastify.inject()` does not support WebSocket upgrade
- [Inference] For subscription integration tests, start the Fastify server on a real port and use a WebSocket client library

---

**Related Topics:**

- Mercurius loaders and DataLoader pattern in depth
- GraphQL subscriptions with Redis pub/sub in Mercurius
- Apollo Federation with Mercurius (schema composition)
- Query complexity and depth limiting in Mercurius
- Field-level authorization with GraphQL Shield or custom directives
- Persisted queries in Mercurius (security and performance)
- Mercurius with TypeScript and code-first schema generation
- Testing GraphQL subscriptions in Fastify integration tests
- Comparing Mercurius with Apollo Server in a Fastify context