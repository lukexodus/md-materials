## Dynamic Route Registration

Dynamic route registration refers to patterns where routes are not statically declared at startup but are instead computed, loaded, or modified based on runtime data — configuration files, database records, external APIs, feature flags, or filesystem discovery. Fastify supports this through its plugin system and the fact that `fastify.register()` accepts async functions, enabling route sets to be constructed programmatically before the server calls `listen()`.

---

### Registration Window

Fastify enforces a strict registration window. Routes and plugins must be registered before `fastify.listen()` or `fastify.ready()` is awaited. After that point, the plugin graph is sealed and new routes cannot be added.

```js
const app = Fastify()

// ✓ Valid — registered before ready()
app.register(async (instance) => {
  instance.get('/hello', async () => ({ hello: 'world' }))
})

await app.ready()

// ✗ Invalid — registration window is closed
app.get('/late', async () => ({}))
// → Error: Cannot add route after server is closed/ready
```

**Key Points:**
- All dynamic route generation must complete within the async plugin lifecycle, before `ready()` resolves
- [Inference] Attempting to register routes after `ready()` throws synchronously in Fastify 4.x; exact error wording may vary by version
- This constraint shapes every dynamic registration pattern: the dynamism happens at boot time, not at request time

---

### Async Plugin Bodies for Dynamic Routes

The most direct pattern: an async plugin body performs async work (DB query, file read, config fetch) and registers routes based on the result.

```js
const fp = require('fastify-plugin')

async function dynamicRoutes(fastify, opts) {
  const { db } = fastify

  // Fetch route definitions from the database at boot time
  const routeConfigs = await db.query('SELECT method, path, handler_key FROM routes WHERE active = true')

  for (const { method, path, handler_key } of routeConfigs.rows) {
    const handler = resolveHandler(handler_key)

    fastify.route({
      method: method.toUpperCase(),
      url: path,
      handler,
    })
  }
}

module.exports = fp(dynamicRoutes, {
  name: 'dynamic-routes',
  fastify: '4.x',
  dependencies: ['internal-db-plugin'],
})
```

**Key Points:**
- `fastify.route()` is the programmatic equivalent of `fastify.get()`, `fastify.post()`, etc., and accepts the full route options object
- The `dependencies` declaration ensures `fastify.db` is available before this plugin body runs
- [Inference] The number of routes registered this way is bounded only by the data source; very large route sets may increase boot time and Fastify's internal router lookup cost — behavior under extreme route counts is not guaranteed

---

### `fastify.route()` — Programmatic Route Declaration

`fastify.route()` is the low-level API underlying all shorthand methods. It accepts a unified options object and is the appropriate tool for dynamic registration.

```js
fastify.route({
  method: 'GET',                    // or ['GET', 'HEAD'] for multiple methods
  url: '/resources/:id',
  schema: {
    params: {
      type: 'object',
      properties: { id: { type: 'string' } },
      required: ['id'],
    },
    response: {
      200: {
        type: 'object',
        properties: {
          id: { type: 'string' },
          name: { type: 'string' },
        },
      },
    },
  },
  preHandler: [fastify.authenticate],
  handler: async (request, reply) => {
    return { id: request.params.id, name: 'Example' }
  },
})
```

**Key Points:**
- `method` accepts a string or an array of strings
- Schema, hooks, and lifecycle options are all available on `fastify.route()` — it is not a reduced API
- Dynamic schemas can be assembled programmatically and passed in the same object

---

### Filesystem-Based Route Discovery

A common pattern loads route files from a directory tree and registers them automatically. `@fastify/autoload` implements this, but the underlying logic can be replicated manually for full control.

#### Manual Filesystem Discovery

```js
const path = require('path')
const fs = require('fs/promises')

async function loadRoutesFromDir(fastify, dir) {
  const entries = await fs.readdir(dir, { withFileTypes: true })

  for (const entry of entries) {
    const fullPath = path.join(dir, entry.name)

    if (entry.isDirectory()) {
      // Recurse into subdirectories
      await fastify.register(
        async (instance) => loadRoutesFromDir(instance, fullPath),
        { prefix: `/${entry.name}` }
      )
    } else if (entry.isFile() && entry.name.endsWith('.js') && entry.name !== 'index.js') {
      const routeModule = require(fullPath)
      await fastify.register(routeModule)
    }
  }
}

// Usage
fastify.register(async (instance) => {
  await loadRoutesFromDir(instance, path.join(__dirname, 'routes'))
})
```

**Output** (for a `routes/` tree):
```
routes/
├── users.js         → registers under /
├── admin/
│   └── reports.js   → registers under /admin
└── v2/
    └── users.js     → registers under /v2
```

#### `@fastify/autoload`

```js
const autoload = require('@fastify/autoload')
const path = require('path')

fastify.register(autoload, {
  dir: path.join(__dirname, 'routes'),
  options: { prefix: '/api' },
  matchFilter: /\.route\.js$/,  // only load files matching the pattern
})
```

**Key Points:**
- `@fastify/autoload` maps directory structure to URL prefixes automatically
- `matchFilter` restricts which files are treated as route modules
- [Inference] Files that export a function not wrapped in `fp` are treated as encapsulated route plugins by autoload; files wrapped in `fp` propagate decorators upward — verify with your autoload version's documentation

---

### Route Generation from Configuration Objects

Routes can be generated from a configuration array — useful for API gateways, proxy layers, or resource-oriented APIs where routes share a common structure.

```js
const RESOURCE_CONFIGS = [
  { resource: 'users',    model: UserModel,    prefix: '/v1' },
  { resource: 'products', model: ProductModel, prefix: '/v1' },
  { resource: 'orders',   model: OrderModel,   prefix: '/v2' },
]

async function resourceRouter(fastify, opts) {
  for (const { resource, model, prefix } of RESOURCE_CONFIGS) {
    fastify.register(
      async (instance) => {
        instance.get(`/${resource}`, async () => model.findAll())
        instance.get(`/${resource}/:id`, async (req) => model.findById(req.params.id))
        instance.post(`/${resource}`, async (req) => model.create(req.body))
        instance.put(`/${resource}/:id`, async (req) => model.update(req.params.id, req.body))
        instance.delete(`/${resource}/:id`, async (req) => model.delete(req.params.id))
      },
      { prefix }
    )
  }
}
```

**Key Points:**
- Each resource gets its own encapsulated plugin scope via `register()`, keeping hooks and middleware isolated
- The `prefix` option in `register()` applies the version prefix without repeating it in every route URL
- [Inference] Model methods used here are illustrative; actual implementations vary — error handling and schema validation should be added per route in production use

---

### Dynamic URL Parameters and Wildcard Routes

Fastify's router (find-my-way) supports parameterized and wildcard segments that can be combined with dynamic registration.

```js
async function buildParameterizedRoutes(fastify, opts) {
  const { tenants } = opts  // e.g. ['acme', 'globex', 'initech']

  // Option A: single parameterized route handles all tenants
  fastify.get('/tenants/:tenantId/data', async (request, reply) => {
    const { tenantId } = request.params
    if (!tenants.includes(tenantId)) {
      return reply.code(404).send({ error: 'Tenant not found' })
    }
    return fetchTenantData(tenantId)
  })

  // Option B: discrete routes per tenant (rarely preferable)
  for (const tenant of tenants) {
    fastify.get(`/tenants/${tenant}/data`, async () => fetchTenantData(tenant))
  }
}
```

**Key Points:**
- Option A (single parameterized route) is almost always preferable; Option B generates O(n) routes and increases router tree size
- [Inference] find-my-way's router is a radix tree; a large number of static routes with common prefixes is less efficient than a single parameterized route — actual performance impact depends on route count and traffic patterns
- Wildcard routes (`/files/*`) can capture arbitrary path suffixes via `request.params['*']`

---

### Feature-Flag-Driven Route Registration

Routes can be conditionally registered based on feature flags, environment variables, or runtime configuration.

```js
async function featureFlaggedRoutes(fastify, opts) {
  const flags = await fetchFeatureFlags()  // returns { betaApi: true, legacyEndpoints: false }

  if (flags.betaApi) {
    fastify.register(require('./routes/beta'), { prefix: '/beta' })
  }

  if (flags.legacyEndpoints) {
    fastify.register(require('./routes/legacy'), { prefix: '/v0' })
  }

  // Always register stable routes
  fastify.register(require('./routes/v1'), { prefix: '/v1' })
}
```

**Key Points:**
- Feature flag evaluation happens once at boot; this is not a runtime toggle mechanism
- [Inference] If flags need to change without a restart, a different pattern is required — such as a single route that reads flag state per-request — but this introduces per-request overhead and complexity
- Environment variable flags are the simpler variant: `if (process.env.BETA_API === 'true')`

---

### Versioned Route Registration

API versioning can be implemented through dynamic registration of versioned route sets under prefixed scopes.

```js
const versions = {
  v1: require('./routes/v1'),
  v2: require('./routes/v2'),
}

async function versionedApi(fastify, opts) {
  const { enabledVersions = ['v1', 'v2'] } = opts

  for (const version of enabledVersions) {
    if (versions[version]) {
      await fastify.register(versions[version], { prefix: `/${version}` })
    }
  }
}
```

#### Versioning via `constraints`

Fastify's constraint system routes requests based on headers or other request properties, enabling version routing without URL prefixes.

```js
fastify.get(
  '/users',
  {
    constraints: { version: '2.0.0' },
  },
  async () => ({ version: 2, users: [] })
)

fastify.get(
  '/users',
  {
    constraints: { version: '1.0.0' },
  },
  async () => ({ version: 1, users: [] })
)
```

Client sends: `Accept-Version: 2.0.0` → routes to the v2 handler.

**Key Points:**
- Constraint-based versioning uses semver range matching; `Accept-Version: 2.x` matches the `2.0.0` constraint
- URL prefix versioning and constraint versioning can be combined or used independently
- [Inference] Constraint versioning requires clients to send the `Accept-Version` header; omitting it results in a 404 unless a default route is also registered — verify behavior against your Fastify version

---

### Dynamic Schema Assembly

Schemas attached to dynamically registered routes can themselves be constructed programmatically.

```js
function buildRouteSchema(fields) {
  return {
    body: {
      type: 'object',
      required: fields.filter(f => f.required).map(f => f.name),
      properties: Object.fromEntries(
        fields.map(f => [f.name, { type: f.type }])
      ),
      additionalProperties: false,
    },
    response: {
      200: {
        type: 'object',
        properties: {
          id: { type: 'string' },
          ...Object.fromEntries(fields.map(f => [f.name, { type: f.type }])),
        },
      },
    },
  }
}

async function dynamicSchemaRoutes(fastify, opts) {
  const entityDefs = await fastify.db.query('SELECT * FROM entity_definitions')

  for (const entity of entityDefs.rows) {
    const schema = buildRouteSchema(entity.fields)

    fastify.route({
      method: 'POST',
      url: `/${entity.slug}`,
      schema,
      handler: async (request) => createEntity(entity.id, request.body),
    })
  }
}
```

**Key Points:**
- Fastify compiles schemas via `fast-json-stringify` and `ajv` at route registration time, not per-request — schemas built dynamically still benefit from this compilation
- [Inference] If the same schema shape is reused across many routes, registering it once via `fastify.addSchema()` with a `$ref` is more efficient than embedding identical schema objects per route — actual compilation behavior depends on Fastify internals

---

### Plugin-Based Route Factories

A route factory is a function that returns a configured plugin, parameterized by options. This is the cleanest composable pattern for generating families of similar routes.

```js
// lib/crud-factory.js
function crudFactory(resource, model, schema) {
  async function crudPlugin(fastify, opts) {
    fastify.get('/', async () => model.findAll())

    fastify.get('/:id', {
      schema: { params: schema.params },
      handler: async (req) => model.findById(req.params.id),
    })

    fastify.post('/', {
      schema: { body: schema.body, response: schema.response },
      handler: async (req) => model.create(req.body),
    })

    fastify.put('/:id', {
      schema: { params: schema.params, body: schema.body },
      handler: async (req) => model.update(req.params.id, req.body),
    })

    fastify.delete('/:id', {
      schema: { params: schema.params },
      handler: async (req) => {
        await model.delete(req.params.id)
        return { deleted: true }
      },
    })
  }

  // Return the plugin — do NOT wrap in fp (routes stay encapsulated)
  return crudPlugin
}

module.exports = crudFactory
```

```js
// app.js
const crudFactory = require('./lib/crud-factory')

fastify.register(crudFactory('users', UserModel, userSchema), { prefix: '/users' })
fastify.register(crudFactory('products', ProductModel, productSchema), { prefix: '/products' })
```

```mermaid
graph TD
  A[Root Instance] --> B[/users scope]
  A --> C[/products scope]
  B --> B1[GET /users/]
  B --> B2[GET /users/:id]
  B --> B3[POST /users/]
  B --> B4[PUT /users/:id]
  B --> B5[DELETE /users/:id]
  C --> C1[GET /products/]
  C --> C2[GET /products/:id]
```

---

### Avoiding Common Pitfalls

**Registering after `ready()`:** Route registration after `ready()` or `listen()` throws. All async data fetching for dynamic routes must happen inside plugin bodies.

**Synchronous loops with `register()`:** Using `for...of` with `await` inside plugin bodies is correct. Using `forEach` with async callbacks is not — `forEach` does not await its callback.

```js
// ✓ Correct
for (const config of configs) {
  await fastify.register(buildPlugin(config))
}

// ✗ Incorrect — forEach does not await
configs.forEach(async (config) => {
  await fastify.register(buildPlugin(config))  // not awaited by forEach
})
```

**Route conflicts:** Registering two routes with the same method and URL throws. [Inference] Dynamic registration from external data sources (database, config files) should deduplicate route definitions before registration — duplicate handling is not automatic.

**URL parameter naming conflicts:** In `find-my-way`, two routes with overlapping dynamic segments at the same position (e.g., `/:userId` and `/:productId` at the same URL depth) are treated as the same route with different parameter names. [Inference] The behavior when both are registered may result in one silently overriding the other — verify with your Fastify version.

---

**Related Topics:**
- `@fastify/autoload` — configuration options, ignore patterns, directory indexing
- Fastify constraints — custom constraint strategies beyond version and host
- find-my-way router internals — radix tree structure, wildcard and parametric node precedence
- Route-level hooks vs. plugin-scope hooks — precedence when mixing dynamic and static registration
- Schema compilation and `fast-json-stringify` — performance implications of large dynamic schema sets
- Hot reloading routes in development — patterns and limitations within Fastify's registration model