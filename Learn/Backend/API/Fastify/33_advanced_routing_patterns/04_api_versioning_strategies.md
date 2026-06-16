## API Versioning Strategies

API versioning in Fastify manages the coexistence of multiple API versions within a single server instance, allowing clients to pin to a stable version while new versions evolve. Fastify supports versioning natively through its constraint system, through URL prefix scoping via `register()`, and through header-based negotiation. Each strategy involves different tradeoffs in URL design, client coupling, maintainability, and routing complexity.

---

### Versioning Strategy Comparison

| Strategy | Example | Fastify Mechanism | Client Coupling |
|---|---|---|---|
| URL path prefix | `/v1/users` | `register({ prefix })` | URL structure |
| Accept-Version header | `Accept-Version: 1.0.0` | Built-in version constraint | Request header |
| Custom header | `X-API-Version: 2` | Custom constraint strategy |Request header |
| Content-Type negotiation | `Accept: application/vnd.myapi.v2+json` | Custom constraint strategy | Media type |
| Query parameter | `/users?version=2` | `onRequest` hook dispatch | Query string |
| Hostname | `v2.api.myapp.com` | Host constraint or custom | DNS / subdomain |

---

### URL Prefix Versioning

URL prefix versioning is the most common strategy. Each API version is a separate plugin scope mounted at a versioned prefix.

```js
const app = Fastify({ logger: true })

// v1 routes
app.register(async (instance) => {
  instance.get('/users', async () => [{ id: 1, name: 'Alice' }])
  instance.get('/users/:id', async (req) => ({ id: req.params.id, name: 'Alice' }))
}, { prefix: '/v1' })

// v2 routes — extended response shape
app.register(async (instance) => {
  instance.get('/users', async () => [{ id: 1, name: 'Alice', email: 'alice@example.com' }])
  instance.get('/users/:id', async (req) => ({
    id: req.params.id,
    name: 'Alice',
    email: 'alice@example.com',
    createdAt: '2024-01-01',
  }))
}, { prefix: '/v2' })

await app.listen({ port: 3000 })
```

**Key Points:**
- Each version scope is fully encapsulated — hooks, schemas, and decorators registered inside do not leak to sibling versions
- The simplest strategy to reason about, test, and document
- Version identity is visible in URLs, access logs, and API documentation without any header inspection
- Clients can cache responses reliably since the URL encodes version identity

---

### Shared Logic Across Versions

Most versions share significant logic. Extracting shared handlers, services, and schemas prevents duplication.

#### Handler Sharing

```js
// lib/handlers/users.js
async function listUsers(request) {
  const users = await request.db.query('SELECT * FROM users')
  return users.rows
}

async function getUser(request) {
  const { id } = request.params
  const result = await request.db.query('SELECT * FROM users WHERE id = $1', [id])
  return result.rows[0] ?? null
}

module.exports = { listUsers, getUser }
```

```js
// routes/v1/users.js
const { listUsers, getUser } = require('../../lib/handlers/users')

async function v1UserRoutes(fastify, opts) {
  fastify.get('/users', async (req) => {
    const users = await listUsers(req)
    // v1: return subset of fields
    return users.map(({ id, name }) => ({ id, name }))
  })
}

module.exports = v1UserRoutes
```

```js
// routes/v2/users.js
const { listUsers, getUser } = require('../../lib/handlers/users')

async function v2UserRoutes(fastify, opts) {
  fastify.get('/users', async (req) => {
    const users = await listUsers(req)
    // v2: return full shape
    return users
  })
}

module.exports = v2UserRoutes
```

**Key Points:**
- Handlers are plain async functions — they are independently testable without a Fastify instance
- Response shape transformation is the responsibility of the route layer, not the handler
- [Inference] Sharing handler logic this way means a bug fix in the shared function applies to all versions simultaneously; intentional behavioral divergence should be forked into version-specific handlers

---

### Versioned Route File Structure

```
routes/
├── v1/
│   ├── index.js        ← registers all v1 routes
│   ├── users.js
│   └── products.js
├── v2/
│   ├── index.js
│   ├── users.js        ← modified shape
│   └── products.js     ← unchanged from v1 (re-exports or delegates)
└── shared/
    ├── handlers/
    └── schemas/
```

```js
// routes/v1/index.js
async function v1Routes(fastify, opts) {
  fastify.register(require('./users'))
  fastify.register(require('./products'))
}
module.exports = v1Routes

// routes/v2/index.js
async function v2Routes(fastify, opts) {
  fastify.register(require('./users'))
  fastify.register(require('../v1/products'))  // re-use unchanged v1 product routes
}
module.exports = v2Routes
```

```js
// app.js
app.register(require('./routes/v1'), { prefix: '/v1' })
app.register(require('./routes/v2'), { prefix: '/v2' })
```

**Key Points:**
- Unchanged resources can be re-registered from the previous version's module without duplication
- The `index.js` per version acts as the version's manifest — easy to audit what changed between versions
- [Inference] Re-registering a v1 module under `/v2` means the handler executes in the v2 scope, inheriting v2's hooks and decorators — verify that v1 handlers do not assume v1-specific hook behavior when reused this way

---

### Accept-Version Header Constraint (Built-in)

Fastify has native support for `Accept-Version` header–based routing using semver matching. The same URL can be registered multiple times with different version constraints.

```js
// v1 handler — registered first
app.get('/users', {
  constraints: { version: '1.0.0' },
  handler: async () => [{ id: 1, name: 'Alice' }],
})

// v2 handler — extended shape
app.get('/users', {
  constraints: { version: '2.0.0' },
  handler: async () => [{ id: 1, name: 'Alice', email: 'alice@example.com' }],
})
```

Client request:
```
GET /users HTTP/1.1
Accept-Version: 2.x
```

Fastify resolves `2.x` to the `2.0.0` handler using semver range matching.

**Key Points:**
- Semver range strings are supported: `1.x`, `^1.0.0`, `>=1.0.0 <2.0.0`
- If no handler matches the requested version, Fastify returns `404`
- If `Accept-Version` is omitted, Fastify returns `404` unless a route without a version constraint is also registered at the same URL
- URL structure stays clean and version-agnostic from the client's perspective

#### Providing a Default Version Fallback

```js
// Versioned handlers
app.get('/users', { constraints: { version: '2.0.0' }, handler: v2Handler })
app.get('/users', { constraints: { version: '1.0.0' }, handler: v1Handler })

// Default — no constraint — catches requests without Accept-Version
app.get('/users', { handler: v2Handler })
```

**Key Points:**
- The unconstrained route acts as a fallback for clients that do not send `Accept-Version`
- [Inference] The precedence between constrained and unconstrained routes for the same URL depends on find-my-way's internal resolution order — test this behavior explicitly in your Fastify version before relying on it in production

---

### Custom Version Constraint Strategy

For organizations using a non-semver versioning scheme (integer versions, date-based versions, custom headers), a custom constraint strategy replaces the built-in version constraint.

```js
// Integer version constraint via X-API-Version header
const intVersionStrategy = {
  name: 'apiVersion',
  storage() {
    const handlers = {}
    return {
      get(version) { return handlers[version] ?? null },
      set(version, store) { handlers[version] = store },
      del(version) { delete handlers[version] },
      empty() { Object.keys(handlers).forEach(k => delete handlers[k]) },
    }
  },
  deriveConstraint(request) {
    const raw = request.headers['x-api-version']
    return raw ? parseInt(raw, 10) : null
  },
  mustMatchWhenDerived: false,  // allow requests without the header to fall through
  validate(value) {
    if (!Number.isInteger(value)) {
      throw new Error('X-API-Version must be an integer')
    }
  },
}

const app = Fastify({ constraints: { apiVersion: intVersionStrategy } })

app.get('/users', {
  constraints: { apiVersion: 1 },
  handler: async () => [{ id: 1, name: 'Alice' }],
})

app.get('/users', {
  constraints: { apiVersion: 2 },
  handler: async () => [{ id: 1, name: 'Alice', email: 'alice@example.com' }],
})
```

**Key Points:**
- Custom constraint strategies are registered at `Fastify()` instantiation via the `constraints` option
- `deriveConstraint` runs on every request at the router level — return `null` when the header is absent rather than throwing
- `mustMatchWhenDerived: false` allows requests that do not send the header to match unconstrained routes
- [Inference] Integer version constraints do not support range matching — an exact integer match is required; range semantics must be implemented manually in `deriveConstraint` if needed

---

### Content Negotiation Versioning

Some APIs use `Accept` media type headers for versioning, following the vendor media type convention.

```
Accept: application/vnd.myapi.v2+json
```

```js
const contentNegotiationStrategy = {
  name: 'mediaVersion',
  storage() {
    const handlers = {}
    return {
      get: (v) => handlers[v] ?? null,
      set: (v, s) => { handlers[v] = s },
      del: (v) => { delete handlers[v] },
      empty: () => { Object.keys(handlers).forEach(k => delete handlers[k]) },
    }
  },
  deriveConstraint(request) {
    const accept = request.headers['accept'] ?? ''
    const match = accept.match(/application\/vnd\.myapi\.v(\d+)\+json/)
    return match ? parseInt(match[1], 10) : null
  },
  mustMatchWhenDerived: false,
}

const app = Fastify({ constraints: { mediaVersion: contentNegotiationStrategy } })

app.get('/users', {
  constraints: { mediaVersion: 1 },
  handler: async (req, reply) => {
    reply.header('Content-Type', 'application/vnd.myapi.v1+json')
    return [{ id: 1, name: 'Alice' }]
  },
})

app.get('/users', {
  constraints: { mediaVersion: 2 },
  handler: async (req, reply) => {
    reply.header('Content-Type', 'application/vnd.myapi.v2+json')
    return [{ id: 1, name: 'Alice', email: 'alice@example.com' }]
  },
})
```

**Key Points:**
- The response `Content-Type` should reflect the negotiated version to complete the content negotiation contract
- [Inference] Proxy servers and CDNs may not vary caches on `Accept` header by default; a `Vary: Accept` response header is required for correct cache behavior — verify this with your infrastructure

---

### Combining URL Prefix and Constraint Versioning

URL prefixes and constraints can be combined for more complex versioning topologies — for example, major version in the URL and minor version via header.

```js
app.register(async (instance) => {
  instance.get('/users', {
    constraints: { version: '1.1.0' },
    handler: async () => [{ id: 1, name: 'Alice', role: 'admin' }],
  })

  instance.get('/users', {
    constraints: { version: '1.0.0' },
    handler: async () => [{ id: 1, name: 'Alice' }],
  })
}, { prefix: '/v1' })

app.register(async (instance) => {
  instance.get('/users', async () => [{ id: 1, name: 'Alice', email: 'alice@example.com' }])
}, { prefix: '/v2' })
```

**Key Points:**
- This topology supports breaking changes at the URL major version level and non-breaking additions at the header minor version level
- [Inference] This combination increases client complexity significantly — clients must track both URL version and header version; use only when the versioning semantics genuinely require it

---

### Version Deprecation and Sunset

Deprecated API versions should signal their status through response headers, giving clients time to migrate.

```js
const fp = require('fastify-plugin')

async function deprecationPlugin(fastify, opts) {
  const { deprecatedVersions = {} } = opts
  // deprecatedVersions: { '/v1': { sunset: '2025-06-01', successor: '/v2' } }

  fastify.addHook('onSend', async (request, reply, payload) => {
    const prefix = Object.keys(deprecatedVersions).find(p =>
      request.url.startsWith(p)
    )

    if (prefix) {
      const { sunset, successor } = deprecatedVersions[prefix]
      reply.header('Deprecation', 'true')
      reply.header('Sunset', sunset)
      if (successor) {
        reply.header('Link', `<${successor}>; rel="successor-version"`)
      }
    }

    return payload
  })
}

module.exports = fp(deprecationPlugin, { name: 'deprecation', fastify: '4.x' })
```

```js
app.register(deprecationPlugin, {
  deprecatedVersions: {
    '/v1': { sunset: '2025-06-01', successor: '/v2' },
  },
})
```

Response headers on a `/v1/*` request:
```
Deprecation: true
Sunset: 2025-06-01
Link: </v2>; rel="successor-version"
```

**Key Points:**
- `Deprecation` and `Sunset` are IETF draft standard headers (RFC 8594 for Sunset); using them improves tooling compatibility
- The `Link` header with `rel="successor-version"` follows the convention for indicating migration targets
- [Inference] Some API client libraries can be configured to warn on `Deprecation: true` headers automatically — actual client behavior depends on the library

---

### Version Routing Architecture

```mermaid
graph TD
  A[Incoming Request] --> B{Routing Strategy}
  B -->|URL Prefix| C[find-my-way<br/>prefix match]
  B -->|Accept-Version| D[find-my-way<br/>semver constraint]
  B -->|Custom Header| E[Custom constraint<br/>strategy]

  C --> F[/v1 scope]
  C --> G[/v2 scope]
  D --> H[version 1.0.0 handler]
  D --> I[version 2.0.0 handler]
  E --> J[apiVersion: 1 handler]
  E --> K[apiVersion: 2 handler]

  F --> L[v1 hooks → v1 handler]
  G --> M[v2 hooks → v2 handler]
```

---

### Schema Versioning

Route schemas evolve alongside handler logic. Shared base schemas reduce duplication while version-specific schemas extend them.

```js
// shared schema — registered on root instance
fastify.addSchema({
  $id: 'UserBase',
  type: 'object',
  properties: {
    id: { type: 'string' },
    name: { type: 'string' },
  },
  required: ['id', 'name'],
})

// v1 response schema — references shared base
const v1UserSchema = {
  $id: 'UserV1',
  allOf: [{ $ref: 'UserBase#' }],
}

// v2 response schema — extends with additional fields
const v2UserSchema = {
  $id: 'UserV2',
  allOf: [
    { $ref: 'UserBase#' },
    {
      type: 'object',
      properties: {
        email: { type: 'string', format: 'email' },
        createdAt: { type: 'string', format: 'date-time' },
      },
    },
  ],
}
```

**Key Points:**
- `allOf` with `$ref` to a shared base schema avoids duplicating common field definitions
- Version-specific schemas are registered within their version scope or on the root instance if reused across versions
- [Inference] `fast-json-stringify` compiles response schemas at registration time; `allOf` resolution behavior may differ slightly from standard JSON Schema — test serialization output for complex `allOf` schemas against your Fastify version

---

### Testing Versioned Routes

```js
const { test } = require('node:test')
const assert = require('node:assert/strict')
const Fastify = require('fastify')

async function buildApp() {
  const app = Fastify({ logger: false })
  app.register(require('./routes/v1'), { prefix: '/v1' })
  app.register(require('./routes/v2'), { prefix: '/v2' })
  await app.ready()
  return app
}

test('v1 GET /users returns name only', async (t) => {
  const app = await buildApp()
  t.after(() => app.close())

  const res = await app.inject({ method: 'GET', url: '/v1/users' })
  assert.strictEqual(res.statusCode, 200)
  const users = res.json()
  assert.ok(users.every(u => 'name' in u && !('email' in u)))
})

test('v2 GET /users returns name and email', async (t) => {
  const app = await buildApp()
  t.after(() => app.close())

  const res = await app.inject({ method: 'GET', url: '/v2/users' })
  assert.strictEqual(res.statusCode, 200)
  const users = res.json()
  assert.ok(users.every(u => 'email' in u))
})

// Constraint-based versioning test
test('Accept-Version 2.0.0 routes to v2 handler', async (t) => {
  const app = Fastify({ logger: false })
  app.get('/users', { constraints: { version: '1.0.0' }, handler: async () => [{ v: 1 }] })
  app.get('/users', { constraints: { version: '2.0.0' }, handler: async () => [{ v: 2 }] })
  await app.ready()
  t.after(() => app.close())

  const res = await app.inject({
    method: 'GET',
    url: '/users',
    headers: { 'accept-version': '2.x' },
  })

  assert.strictEqual(res.statusCode, 200)
  assert.strictEqual(res.json()[0].v, 2)
})
```

---

### Common Pitfalls

**Version scope hook leakage:** Hooks registered outside a version scope apply to all versions. Authentication hooks, rate limiters, and logging hooks should be scoped deliberately.

```js
// ✓ Hook scoped to v2 only
app.register(async (instance) => {
  instance.addHook('preHandler', newRateLimiter)
  instance.register(require('./routes/v2/users'))
}, { prefix: '/v2' })
```

**Forgetting `Accept-Version` fallback:** Routes registered with only version constraints return `404` to clients that omit the header. Always decide explicitly whether a default version fallback is needed.

**Schema `$id` collisions across versions:** Registering two schemas with the same `$id` on the same scope throws. Use version-namespaced `$id` values (`UserV1`, `UserV2`) or register schemas within their version scope.

**Re-registering v1 modules in v2 without hook auditing:** A v1 route module reused in v2 executes in the v2 hook context. If v2 adds a breaking `preHandler` hook, the re-used v1 module is affected. [Inference] Always audit hook inheritance when re-registering modules across versions.

**Sunset dates without enforcement:** Advertising a sunset date via headers without actually removing the endpoint creates maintenance debt indefinitely. Plan the removal step at the same time as the deprecation announcement.

---

**Related Topics:**
- Custom constraint strategies — storage, derivation, and validation API
- URL prefix scoping and hook inheritance — version scope isolation mechanics
- `@fastify/swagger` versioning — generating separate OpenAPI specs per version
- Breaking change detection — schema diffing tools for API versioning governance
- Route deprecation and migration guides — consumer communication patterns
- Semantic versioning conventions for HTTP APIs — when to increment major vs. minor