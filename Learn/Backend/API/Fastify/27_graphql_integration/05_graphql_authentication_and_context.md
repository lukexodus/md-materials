## GraphQL Authentication and Context in Fastify

### Overview

Authentication in a Fastify + GraphQL server involves verifying identity at the HTTP layer (via Fastify hooks or middleware) and making authenticated user data available to resolvers through the GraphQL **context** object. Authorization — determining what an authenticated user may access — is typically enforced inside resolvers or through schema directives.

This topic covers the full pipeline: token verification, context construction, resolver-level enforcement, and common patterns for both mercurius and fastify-graphql setups.

---

### Authentication vs. Authorization

These terms are frequently conflated but represent distinct concerns:

| Concept | Question | Where Enforced |
| --- | --- | --- |
| **Authentication** | Who is this user? | Fastify hooks, context function |
| **Authorization** | What can this user do? | Resolvers, directives, middleware |

**Key Points**

- Authentication happens before GraphQL parsing — at the HTTP request level
- Authorization happens during resolver execution — after the schema is traversed
- GraphQL has no built-in mechanism for either; both are application concerns

---

### Context as the Authentication Carrier

The GraphQL `context` object is passed to every resolver in the execution tree. It is the standard mechanism for carrying authenticated user state.

In mercurius, `context` is a per-request factory function:

js

```js
app.register(mercurius, {
  schema,
  resolvers,
  context: async (request, reply) => {
    // Runs once per request, before any resolver executes
    return {
      user: null, // populated below
      db,
      loaders: createLoaders(db)
    }
  }
})
```

The context function receives the raw Fastify `request` and `reply` objects, giving full access to headers, cookies, session data, and anything attached by prior hooks.

---

### JWT Authentication Pattern

JWT (JSON Web Token) is the most common stateless authentication mechanism for GraphQL APIs.

#### Installing Dependencies

bash

```bash
npm install @fastify/jwt
```

#### Registering the JWT Plugin

js

```js
import Fastify from 'fastify'
import fastifyJwt from '@fastify/jwt'

const app = Fastify({ logger: true })

await app.register(fastifyJwt, {
  secret: process.env.JWT_SECRET
})
```

#### Verifying the Token in Context

js

```js
app.register(mercurius, {
  schema,
  resolvers,
  context: async (request, reply) => {
    let user = null

    const authHeader = request.headers.authorization
    if (authHeader?.startsWith('Bearer ')) {
      try {
        // request.jwtVerify() is added by @fastify/jwt
        await request.jwtVerify()
        user = request.user // decoded JWT payload
      } catch (err) {
        // Token is invalid or expired — user remains null
        // Do not throw here; let resolvers decide what requires auth
        request.log.warn({ err }, 'JWT verification failed')
      }
    }

    return { user, db, loaders: createLoaders(db) }
  }
})
```

**Key Points**

- Verification failures are caught and logged rather than thrown — unauthenticated requests still reach resolvers
- Resolvers then decide whether `user === null` is acceptable for a given field
- This approach supports mixed schemas with both public and protected fields
- [Inference] Throwing from the context function likely returns an HTTP-level error before GraphQL executes; actual behavior may vary by mercurius version

---

### Cookie-Based Authentication Pattern

For browser clients using HTTP-only cookies:

js

```js
import fastifyCookie from '@fastify/cookie'
import fastifySession from '@fastify/session'

await app.register(fastifyCookie)
await app.register(fastifySession, {
  secret: process.env.SESSION_SECRET,
  cookie: { secure: process.env.NODE_ENV === 'production' }
})

app.register(mercurius, {
  schema,
  resolvers,
  context: async (request, reply) => {
    const sessionUser = request.session?.user ?? null
    return { user: sessionUser, db }
  }
})
```

**Key Points**

- `@fastify/session` must be registered before mercurius so the session is populated on `request` before context runs
- Session stores (memory, Redis, PostgreSQL) are configured on `@fastify/session`; the context function only reads from the already-populated session

---

### API Key Authentication Pattern

For machine-to-machine clients where JWTs are unnecessary:

js

```js
context: async (request, reply) => {
  let user = null
  const apiKey = request.headers['x-api-key']

  if (apiKey) {
    // Look up key in database — hash comparison recommended over plaintext
    const keyRecord = await db.query(
      'SELECT * FROM api_keys WHERE key_hash = $1 AND revoked = false',
      [hashApiKey(apiKey)]
    )
    if (keyRecord.rows[0]) {
      user = { id: keyRecord.rows[0].owner_id, role: 'api_client' }
    }
  }

  return { user, db }
}
```

---

### Enforcing Authentication in Resolvers

Once `user` is on context, resolvers check it before executing:

js

```js
// helpers/auth.js
export function requireAuth(context) {
  if (!context.user) {
    const err = new Error('Unauthorized')
    err.extensions = { code: 'UNAUTHORIZED' }
    throw err
  }
  return context.user
}

export function requireRole(context, role) {
  const user = requireAuth(context)
  if (user.role !== role) {
    const err = new Error('Forbidden')
    err.extensions = { code: 'FORBIDDEN' }
    throw err
  }
  return user
}
```

js

```js
// resolvers.js
export const resolvers = {
  Query: {
    me: async (_, __, context) => {
      const user = requireAuth(context)
      return db.query('SELECT * FROM users WHERE id = $1', [user.id])
        .then(r => r.rows[0])
    },

    adminDashboard: async (_, __, context) => {
      requireRole(context, 'admin')
      return getAdminData()
    },

    publicPosts: async () => {
      // No auth check — public field
      return db.query('SELECT * FROM posts WHERE published = true').then(r => r.rows)
    }
  }
}
```

**Key Points**

- Throwing an `Error` with `extensions.code` surfaces a structured GraphQL error to the client
- Separating auth helpers from resolver logic keeps resolvers readable and helpers testable
- [Inference] GraphQL clients that parse `extensions.code` can distinguish auth failures from other errors; behavior depends on the client library

---

### GraphQL Error Formatting for Auth Failures

Mercurius allows customizing how errors are returned to the client:

js

```js
app.register(mercurius, {
  schema,
  resolvers,
  errorFormatter: (result, context) => {
    const errors = result.errors?.map(err => {
      const code = err.extensions?.code

      // Do not leak stack traces or internal details
      if (code === 'UNAUTHORIZED' || code === 'FORBIDDEN') {
        return {
          message: err.message,
          extensions: { code }
        }
      }

      // Generic fallback — hide internal error details in production
      return {
        message: process.env.NODE_ENV === 'production'
          ? 'Internal server error'
          : err.message,
        extensions: { code: code ?? 'INTERNAL_ERROR' }
      }
    })

    return {
      statusCode: result.errors?.[0]?.extensions?.code === 'UNAUTHORIZED' ? 401 : 200,
      response: { ...result, errors }
    }
  }
})
```

**Key Points**

- GraphQL conventionally returns HTTP 200 even for errors; returning 401 for auth errors is a deliberate deviation that some clients expect
- Stack traces must never be sent to clients in production
- `errorFormatter` in mercurius receives the full result and context, enabling fine-grained control

---

### Schema Directives for Authorization

Schema directives encode authorization rules declaratively in the SDL rather than imperatively in every resolver.

#### Defining the Directive

graphql

```graphql
directive @auth on FIELD_DEFINITION
directive @hasRole(role: String!) on FIELD_DEFINITION

type Query {
  me: User @auth
  adminDashboard: AdminData @hasRole(role: "admin")
  publicPosts: [Post!]!
}
```

#### Implementing with mercurius-auth

bash

```bash
npm install mercurius-auth
```

js

```js
import mercuriusAuth from 'mercurius-auth'

await app.register(mercurius, { schema, resolvers, context })

await app.register(mercuriusAuth, {
  authContext: async (context) => {
    // Return auth data to attach to context for directive use
    return { user: context.user }
  },
  async applyPolicy(authDirectiveAST, parent, args, context, info) {
    const directiveName = authDirectiveAST.name.value

    if (directiveName === 'auth') {
      if (!context.auth?.user) {
        throw new Error('Unauthorized')
      }
      return true
    }

    if (directiveName === 'hasRole') {
      const requiredRole = authDirectiveAST.arguments
        .find(a => a.name.value === 'role')?.value?.value

      if (context.auth?.user?.role !== requiredRole) {
        throw new Error('Forbidden')
      }
      return true
    }

    return true
  }
})
```

**Key Points**

- `mercurius-auth` must be registered **after** mercurius — plugin registration order matters
- `applyPolicy` is called before the resolver for each field annotated with a covered directive
- Directive-based authorization centralizes access rules in the schema, reducing resolver boilerplate
- [Inference] Complex authorization rules (e.g., ownership checks requiring DB queries) may be harder to express cleanly as directives; resolver-level checks may be more appropriate in those cases

---

### Prevalidation Hook for Early Rejection

For fields or operations where you want to reject unauthenticated requests before GraphQL parsing (e.g., introspection protection):

js

```js
app.addHook('preValidation', async (request, reply) => {
  const isGraphQL = request.url === '/graphql'
  if (!isGraphQL) return

  const body = request.body
  const isIntrospection = typeof body?.query === 'string' &&
    body.query.includes('__schema')

  if (isIntrospection && process.env.NODE_ENV === 'production') {
    reply.code(403).send({ error: 'Introspection disabled' })
  }
})
```

Alternatively, mercurius exposes a `persistedQueries` option and allows disabling introspection directly:

js

```js
app.register(mercurius, {
  schema,
  resolvers,
  graphiql: false,                  // Disable GraphiQL in production
  // introspection: false           // [Unverified] — check mercurius version for this option
})
```

---

### Attaching Fastify Decorators to Context

Any value attached to the Fastify instance via `app.decorate` or to `request` via `app.decorateRequest` is accessible in the context function:

js

```js
// Decorate request with a helper
app.decorateRequest('getCurrentUser', async function () {
  try {
    await this.jwtVerify()
    return this.user
  } catch {
    return null
  }
})

app.register(mercurius, {
  schema,
  resolvers,
  context: async (request, reply) => {
    const user = await request.getCurrentUser()
    return { user, db, loaders: createLoaders(db) }
  }
})
```

This keeps context construction clean and reusable across different routes and plugins.

---

### Full Context Shape Example

A well-typed context object for a production Fastify + GraphQL application:

js

```js
// context.js
export async function buildContext(request, reply, db) {
  let user = null

  try {
    await request.jwtVerify()
    user = request.user ?? null
  } catch {
    // Unauthenticated request — resolvers handle access control
  }

  return {
    // Auth
    user,                         // null | { id, role, email, ... }
    isAuthenticated: user !== null,

    // Data access
    db,
    loaders: createLoaders(db),

    // Request metadata
    requestId: request.id,
    log: request.log,

    // Reply (for setting cookies or headers from resolvers)
    reply
  }
}
```

js

```js
app.register(mercurius, {
  schema,
  resolvers,
  context: (request, reply) => buildContext(request, reply, db)
})
```

**Key Points**

- Including `log` on context lets resolvers emit structured logs tied to the request ID
- Including `reply` on context enables resolvers to set cookies or response headers (use sparingly — this couples resolvers to HTTP)
- `isAuthenticated` is a convenience boolean to avoid `user !== null` checks in every resolver

---

### Subscription Authentication

GraphQL subscriptions use WebSocket connections, which require a separate authentication check:

js

```js
app.register(mercurius, {
  schema,
  resolvers,
  subscription: {
    context: async (connection, request) => {
      // connection: WebSocket connection object
      // request: the initial HTTP upgrade request
      let user = null

      const token = request.headers['sec-websocket-protocol'] ||
        new URL(request.url, 'http://localhost').searchParams.get('token')

      if (token) {
        try {
          // Manual JWT verification — request.jwtVerify() may not be available here
          user = app.jwt.verify(token)
        } catch {
          // Invalid token — subscription context has no user
        }
      }

      return { user, db }
    }
  }
})
```

**Key Points**

- WebSocket connections do not send `Authorization` headers in the same way HTTP requests do — tokens are typically passed as query parameters or via the subprotocol header
- [Inference] The exact API for `subscription.context` may differ between mercurius versions; consult the installed version's documentation
- Unauthenticated WebSocket connections can be terminated at the connection level or allowed to proceed with `user: null`

---

### Diagram: Authentication Flow

ResolverContext BuilderHooks (preHandler)FastifyClientResolverContext BuilderHooks (preHandler)FastifyClientalt[Valid token][Invalid token]POST /graphql { Authorization: Bearer <token> }Run lifecycle hooksHooks pass (no early rejection)context(request, reply)request.jwtVerify(){ user: { id, role }, db, loaders }{ user: null, db, loaders }requireAuth(context) or allowGraphQL response

---

**Related Topics**

- Role-based access control (RBAC) vs. attribute-based access control (ABAC) in GraphQL
- Field-level authorization with schema directives and `mercurius-auth`
- Refresh token rotation with `@fastify/jwt`
- GraphQL persisted queries for additional security
- Protecting introspection in production environments
- Authentication in federated GraphQL (Apollo Federation + Fastify gateway)
- Rate limiting authenticated vs. unauthenticated GraphQL requests with `@fastify/rate-limit`