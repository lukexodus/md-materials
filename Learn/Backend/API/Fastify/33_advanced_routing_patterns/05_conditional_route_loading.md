## Conditional Route Loading

Conditional route loading refers to patterns where routes are selectively registered based on conditions evaluated at boot time — environment variables, feature flags, configuration values, runtime capability detection, or deployment context. Because Fastify seals its router after `ready()`, all conditional logic must resolve during the plugin initialization phase. The result is a server whose route surface is fixed for the lifetime of the process, shaped by conditions that were true at startup.

---

### The Registration Window Constraint

All conditional logic operates within the same registration window constraint as dynamic route loading. Conditions are evaluated once, during boot, and the resulting route set is immutable for the process lifetime.

```mermaid
graph LR
  A[Process Start] --> B[Plugin Init Phase<br/>Conditions evaluated here]
  B --> C[fastify.ready resolves<br/>Router sealed]
  C --> D[Request handling<br/>Route set fixed]
  D --> E[fastify.close]
```

**Key Points:**
- Runtime toggling of routes without a process restart is not supported by Fastify's router model
- [Inference] Patterns that simulate runtime toggling (e.g., a catch-all route that checks a flag per request) are possible but shift the conditional logic into the request path, adding per-request overhead — this is a deliberate architectural tradeoff, not a Fastify limitation
- The immutability of the registered route set after `ready()` is a feature from a correctness standpoint: the router is compiled once and lookup is fast

---

### Environment Variable–Based Loading

The simplest and most common form. Environment variables are read synchronously at boot and used to gate registration.

```js
async function conditionalRoutes(fastify, opts) {
  // Always register core routes
  await fastify.register(require('./routes/core'))

  // Register admin routes only in non-production or when explicitly enabled
  if (process.env.ENABLE_ADMIN_ROUTES === 'true') {
    await fastify.register(require('./routes/admin'), { prefix: '/admin' })
  }

  // Register debug routes in development only
  if (process.env.NODE_ENV === 'development') {
    await fastify.register(require('./routes/debug'), { prefix: '/_debug' })
  }

  // Register internal tooling routes when not exposed to the public internet
  if (process.env.DEPLOYMENT_TIER === 'internal') {
    await fastify.register(require('./routes/internal'), { prefix: '/internal' })
  }
}
```

**Key Points:**
- `process.env` reads are synchronous and zero-cost — no async resolution is needed
- Coerce string environment variables explicitly (`=== 'true'`) rather than relying on truthiness, since all env vars are strings
- Centralizing environment variable reads in a single plugin makes the conditional surface auditable in one place

---

### Configuration Object–Based Loading

For applications with a structured configuration system (file-based config, config service, parsed CLI arguments), route registration conditions derive from a config object rather than raw environment variables.

```js
const fp = require('fastify-plugin')

async function featureRoutesPlugin(fastify, opts) {
  const { features } = opts

  const conditionalModules = [
    { flag: 'payments',    module: './routes/payments',    prefix: '/payments' },
    { flag: 'analytics',   module: './routes/analytics',   prefix: '/analytics' },
    { flag: 'webhooks',    module: './routes/webhooks',    prefix: '/webhooks' },
    { flag: 'publicApi',   module: './routes/public-api',  prefix: '/api' },
  ]

  for (const { flag, module: mod, prefix } of conditionalModules) {
    if (features[flag]) {
      await fastify.register(require(mod), { prefix })
    }
  }
}

module.exports = fp(featureRoutesPlugin, {
  name: 'feature-routes',
  fastify: '4.x',
})
```

```js
// app.js
const config = await loadConfig()  // reads file, env, CLI args

app.register(featureRoutesPlugin, { features: config.features })
```

**Key Points:**
- The configuration array makes the complete set of conditionally loadable routes visible in one place — easier to audit than scattered `if` statements across multiple files
- Passing `features` as plugin options rather than reading from a global makes the plugin independently testable with different flag combinations
- [Inference] `require(mod)` inside a loop is synchronous and cached by Node.js's module system after the first load — the module is not re-evaluated on subsequent calls, only the registration runs

---

### Async Feature Flag Resolution

Feature flags sourced from a remote service (LaunchDarkly, Unleash, a config database) must be resolved before the registration loop runs. This is handled naturally inside an async plugin body.

```js
const fp = require('fastify-plugin')

async function remoteFeatureFlagRoutes(fastify, opts) {
  const { flagClient } = opts

  // Resolve all relevant flags in a single async call before registering
  const [paymentsEnabled, betaEnabled, legacyEnabled] = await Promise.all([
    flagClient.isEnabled('payments-api'),
    flagClient.isEnabled('beta-features'),
    flagClient.isEnabled('legacy-endpoints'),
  ])

  if (paymentsEnabled) {
    await fastify.register(require('./routes/payments'), { prefix: '/payments' })
  }

  if (betaEnabled) {
    await fastify.register(require('./routes/beta'), { prefix: '/beta' })
  }

  if (legacyEnabled) {
    await fastify.register(require('./routes/legacy'), { prefix: '/v0' })
    fastify.log.warn('Legacy endpoints are enabled — schedule deprecation review')
  }
}

module.exports = fp(remoteFeatureFlagRoutes, {
  name: 'remote-feature-routes',
  fastify: '4.x',
})
```

**Key Points:**
- `Promise.all()` parallelizes flag resolution — individual sequential `await` calls for each flag add latency unnecessarily
- Flag state is snapshotted at boot; if flags change in the remote service after startup, the running process is unaffected until restart
- [Inference] Remote flag resolution at boot introduces a startup dependency on the flag service — if the service is unavailable, boot fails unless fallback defaults are handled; design accordingly

---

### Capability Detection–Based Loading

Some routes should only be registered when a required capability (database connection, external service, hardware feature) is available and verified.

```js
async function capabilityConditionalRoutes(fastify, opts) {
  // Probe database availability
  try {
    await fastify.db.query('SELECT 1')
    await fastify.register(require('./routes/users'))
    await fastify.register(require('./routes/orders'))
  } catch (err) {
    fastify.log.error({ err }, 'Database unavailable — skipping data routes')
    // Register a fallback that explains the degraded state
    fastify.get('/users', async (req, reply) => {
      return reply.code(503).send({ error: 'Service temporarily unavailable' })
    })
  }

  // Probe Redis availability
  try {
    await fastify.redis.ping()
    await fastify.register(require('./routes/sessions'))
  } catch (err) {
    fastify.log.warn({ err }, 'Redis unavailable — session routes not registered')
  }

  // Check for optional hardware/OS capability
  if (process.platform === 'linux') {
    await fastify.register(require('./routes/system-metrics'))
  }
}
```

**Key Points:**
- Capability detection at boot provides graceful degradation rather than a hard crash when optional dependencies are unavailable
- The fallback `503` route preserves the URL contract for clients while signaling degraded state
- [Inference] Probing services at boot does not guarantee they remain available during request handling — circuit breakers or health check hooks are needed for ongoing availability assurance; capability detection here is only a boot-time gate

---

### Deployment Context–Based Loading

In systems where the same codebase serves multiple deployment roles (API server, worker, admin panel, public gateway), conditional loading selects the appropriate route surface.

```js
async function deploymentContextRoutes(fastify, opts) {
  const role = process.env.SERVICE_ROLE  // 'api' | 'admin' | 'worker' | 'gateway'

  const roleModules = {
    api: [
      { module: './routes/v1', prefix: '/v1' },
      { module: './routes/v2', prefix: '/v2' },
      { module: './routes/health', prefix: '' },
    ],
    admin: [
      { module: './routes/admin', prefix: '/admin' },
      { module: './routes/health', prefix: '' },
    ],
    gateway: [
      { module: './routes/proxy', prefix: '' },
      { module: './routes/health', prefix: '' },
    ],
  }

  const modules = roleModules[role]

  if (!modules) {
    throw new Error(`Unknown SERVICE_ROLE: '${role}'. Expected one of: ${Object.keys(roleModules).join(', ')}`)
  }

  for (const { module: mod, prefix } of modules) {
    await fastify.register(require(mod), prefix ? { prefix } : {})
  }
}
```

**Key Points:**
- A single codebase with role-based route loading avoids maintaining separate entry points per deployment role
- Throwing on unknown roles at boot is the correct behavior — a misconfigured deployment should fail loudly rather than serve an empty or partial route set
- This pattern pairs naturally with container orchestration where `SERVICE_ROLE` is set via environment injection

---

### Conditional Hook Registration

Conditions apply not only to routes but to hooks. Conditionally registered hooks affect the behavior of all routes in their scope.

```js
async function environmentalHooks(fastify, opts) {
  // Request logging middleware — skip in test environment to reduce noise
  if (process.env.NODE_ENV !== 'test') {
    fastify.addHook('onRequest', async (request) => {
      request.log.info({ url: request.url, method: request.method }, 'incoming request')
    })
  }

  // Rate limiting — only in production
  if (process.env.NODE_ENV === 'production') {
    await fastify.register(require('@fastify/rate-limit'), {
      max: 100,
      timeWindow: '1 minute',
    })
  }

  // Request ID propagation — always, but with different header names per environment
  const requestIdHeader = process.env.NODE_ENV === 'production'
    ? 'x-request-id'
    : 'x-debug-request-id'

  fastify.addHook('onRequest', async (request) => {
    request.requestId = request.headers[requestIdHeader] ?? request.id
  })
}
```

**Key Points:**
- Conditional hook registration keeps test environments clean without cluttering handler code with environment checks
- [Inference] Disabling rate limiting outside production is a common pattern but should be validated against your security requirements — some testing and staging environments should mirror production behavior for accurate load testing

---

### Conditional Schema Registration

Schemas used only by conditionally loaded routes should themselves be conditionally registered to avoid polluting the schema namespace.

```js
async function conditionalSchemasAndRoutes(fastify, opts) {
  const { enablePayments } = opts

  if (enablePayments) {
    fastify.addSchema({
      $id: 'PaymentIntent',
      type: 'object',
      required: ['amount', 'currency'],
      properties: {
        amount: { type: 'integer', minimum: 1 },
        currency: { type: 'string', enum: ['usd', 'eur', 'gbp'] },
      },
    })

    await fastify.register(require('./routes/payments'))
  }
}
```

**Key Points:**
- Schemas registered with `addSchema` are globally scoped on the instance by default — registering unused schemas is harmless but creates noise in `fastify.getSchemas()` output and in generated API documentation
- Scoping schema registration to the same conditional block as the routes that use them keeps the schema namespace clean

---

### Testing Conditional Routes

Tests should cover both the enabled and disabled states of each conditional.

```js
const { test } = require('node:test')
const assert = require('node:assert/strict')
const Fastify = require('fastify')
const featureRoutesPlugin = require('../plugins/feature-routes')

async function buildApp(features = {}) {
  const app = Fastify({ logger: false })
  await app.register(featureRoutesPlugin, { features })
  await app.ready()
  return app
}

test('payments routes registered when flag enabled', async (t) => {
  const app = await buildApp({ payments: true })
  t.after(() => app.close())

  const res = await app.inject({ method: 'GET', url: '/payments' })
  assert.notStrictEqual(res.statusCode, 404)
})

test('payments routes absent when flag disabled', async (t) => {
  const app = await buildApp({ payments: false })
  t.after(() => app.close())

  const res = await app.inject({ method: 'GET', url: '/payments' })
  assert.strictEqual(res.statusCode, 404)
})

test('throws on unknown SERVICE_ROLE', async (t) => {
  const app = Fastify({ logger: false })
  app.register(require('../plugins/deployment-context-routes'))

  const originalRole = process.env.SERVICE_ROLE
  process.env.SERVICE_ROLE = 'unknown-role'
  t.after(() => {
    process.env.SERVICE_ROLE = originalRole
    app.close()
  })

  await assert.rejects(
    () => app.ready(),
    /Unknown SERVICE_ROLE/
  )
})
```

**Key Points:**
- The `buildApp` factory accepts a `features` object directly, avoiding the need to manipulate `process.env` in most tests
- Tests that do manipulate `process.env` should restore the original value in teardown — `t.after()` is the correct place
- Both the enabled and disabled states are first-class test cases; only testing the enabled path leaves the disabled path unvalidated

---

### Conditional Loading with `@fastify/autoload`

`@fastify/autoload` supports conditional loading via `ignorePattern` and `matchFilter` options, enabling filesystem-based filtering.

```js
const autoload = require('@fastify/autoload')
const path = require('path')

fastify.register(autoload, {
  dir: path.join(__dirname, 'routes'),

  // Skip files with .disabled.js extension
  ignorePattern: /.*\.disabled\.js$/,

  // Only load files matching the environment-specific pattern
  matchFilter: (path) => {
    if (process.env.NODE_ENV === 'production') {
      return !path.includes('debug') && !path.includes('dev-only')
    }
    return true
  },

  options: { prefix: '/api' },
})
```

**Key Points:**
- `ignorePattern` is a regex tested against file paths — useful for a naming convention that marks routes as inactive
- `matchFilter` is a function giving full control over which files are loaded — it receives the full path string
- [Inference] `@fastify/autoload` options and filter signatures may vary across versions — consult the version installed in your project rather than relying on this description as authoritative

---

### Conditional Loading Anti-Patterns

**Per-request flag checks in handlers:** Checking a feature flag on every request inside a handler is not conditional route loading — it is conditional route behavior. This adds per-request overhead and obscures the route surface.

```js
// ✗ Anti-pattern: per-request flag check
fastify.get('/new-feature', async (request, reply) => {
  if (!featureFlags.isEnabled('new-feature')) {
    return reply.code(404).send()
  }
  return doNewFeature()
})

// ✓ Correct: conditional registration at boot
if (featureFlags.isEnabled('new-feature')) {
  fastify.get('/new-feature', async () => doNewFeature())
}
```

**Swallowing registration errors silently:** Catching errors from `fastify.register()` without logging or re-throwing can leave the server in an undefined partial state.

```js
// ✗ Anti-pattern: silent failure
try {
  await fastify.register(require('./routes/critical'))
} catch (err) {
  // swallowed
}

// ✓ Log and decide explicitly whether to continue or abort
try {
  await fastify.register(require('./routes/critical'))
} catch (err) {
  fastify.log.error({ err }, 'Critical route registration failed')
  throw err  // or handle degraded state explicitly
}
```

**Conditions that depend on request state:** Conditions must be evaluable at boot time. Anything that depends on the first request, a session, or a database record that does not exist at startup cannot drive conditional route registration.

---

### Startup Validation Hook

An `onReady` hook can assert that the conditionally loaded route set satisfies invariants before the server begins accepting traffic.

```js
fastify.addHook('onReady', async () => {
  // Assert health endpoint is always present regardless of feature flags
  if (!fastify.hasRoute({ method: 'GET', url: '/health' })) {
    throw new Error('Health check route must always be registered')
  }

  // Assert at least one versioned API route is present
  const hasApiRoutes =
    fastify.hasRoute({ method: 'GET', url: '/v1/users' }) ||
    fastify.hasRoute({ method: 'GET', url: '/v2/users' })

  if (!hasApiRoutes) {
    throw new Error('No API routes registered — check feature flag configuration')
  }
})
```

**Key Points:**
- `onReady` fires after all plugins have initialized but before `ready()` resolves to the caller — throwing here aborts startup cleanly
- Invariant checks in `onReady` catch misconfiguration (wrong environment variables, missing flags) before traffic is served
- [Inference] `hasRoute()` checks exact URL patterns including parameter placeholders — dynamic route URLs must be checked with the placeholder syntax (`:id`), not with real values

---

**Related Topics:**
- Dynamic route registration — runtime-computed route sets from databases and config files
- `@fastify/autoload` — filesystem-based route discovery with filter options
- Feature flag service integration — LaunchDarkly, Unleash, and custom flag clients
- `onReady` hook — post-initialization invariant validation
- Plugin encapsulation — scoping conditional hooks to version or feature contexts
- Deployment role patterns — monorepo services sharing a codebase with divergent route surfaces