## Plugin Testing Strategies

Testing Fastify plugins requires a different mental model from testing plain functions. A plugin's behavior is expressed through its effect on the Fastify instance — decorators it adds, hooks it registers, routes it mounts, and errors it throws during registration. The primary testing surface is the Fastify instance itself, accessed either through `fastify.inject()` for HTTP-level assertions or through direct decorator and hook inspection for unit-level assertions.

---

### Core Testing Primitives

#### `fastify.inject()`

`fastify.inject()` simulates an HTTP request through Fastify's full request lifecycle without binding to a network socket. It is the primary tool for route-level plugin testing.

```js
const Fastify = require('fastify')
const myPlugin = require('../plugins/my-plugin')

const app = Fastify()
await app.register(myPlugin, { option: 'value' })
await app.ready()

const res = await app.inject({
  method: 'GET',
  url: '/my-route',
  headers: { authorization: 'Bearer token' },
  payload: { key: 'value' },  // for POST/PUT
})

console.log(res.statusCode)   // 200
console.log(res.json())       // parsed response body
```

**Key Points:**
- `inject()` bypasses the network entirely; no port binding, no OS-level socket
- The full hook lifecycle (`onRequest`, `preHandler`, `onSend`, etc.) executes normally
- `res.json()` parses the response body; `res.body` returns the raw string
- `await app.ready()` must be called before `inject()` unless the plugin registers routes synchronously — [Inference] skipping `ready()` may result in routes not yet being registered at injection time

#### `fastify.ready()`

Calling `ready()` triggers the full plugin initialization chain. Tests that assert on decorators or hooks rather than routes still require `ready()`:

```js
await app.ready()
assert.ok(app.hasDecorator('myService'))
```

#### `fastify.close()`

Always call `close()` in teardown. Plugins that register `onClose` hooks (db pools, Redis connections, file watchers) rely on it for cleanup. Skipping it causes test runners to hang.

---

### Test Runner Setup

The examples throughout use Node.js's built-in `node:test` runner with `node:assert`. The same patterns apply to Jest, tap, and Vitest with minor syntax differences.

```js
const { test, beforeEach, afterEach } = require('node:test')
const assert = require('node:assert/strict')
const Fastify = require('fastify')
const myPlugin = require('../index')

let app

beforeEach(async () => {
  app = Fastify({ logger: false })
  await app.register(myPlugin, { secret: 'test-secret' })
  await app.ready()
})

afterEach(async () => {
  await app.close()
})

test('decorates fastify instance', () => {
  assert.ok(app.hasDecorator('myService'))
})
```

**Key Points:**
- Create a fresh `Fastify()` instance per test to prevent state leakage between tests
- `logger: false` suppresses log output during tests; use `logger: { level: 'silent' }` if the logger instance itself must be present
- `beforeEach`/`afterEach` are preferable to shared instance variables for isolation

---

### Unit Testing: Decorator and Hook Assertions

For infrastructure plugins that add decorators rather than routes, test the decorator directly.

#### Decorator Presence and Shape

```js
test('db plugin adds fastify.db decorator', async (t) => {
  const app = Fastify({ logger: false })
  await app.register(require('../plugins/db'), {
    connectionString: 'postgres://localhost/test',
  })
  await app.ready()

  assert.ok(app.hasDecorator('db'), 'fastify.db should exist')
  assert.strictEqual(typeof app.db.query, 'function', 'fastify.db.query should be callable')

  await app.close()
})
```

#### Request Decorator Assertions

```js
test('auth plugin adds request.user decorator', async (t) => {
  const app = Fastify({ logger: false })
  await app.register(require('../plugins/auth'), { secret: 'test' })

  // Register a test route that reads request.user
  app.get('/me', async (request) => ({ user: request.user }))

  await app.ready()

  const res = await app.inject({
    method: 'GET',
    url: '/me',
    headers: { authorization: 'Bearer valid.test.token' },
  })

  assert.strictEqual(res.statusCode, 200)
  assert.ok(res.json().user)

  await app.close()
})
```

**Key Points:**
- Request and reply decorators cannot be asserted via `app.hasRequestDecorator()` alone in all cases — [Inference] behavior of `hasRequestDecorator` may vary by Fastify version; verifying through a live request via `inject()` is more reliable
- Use a minimal test route as the observable surface for request-level decorators

---

### Testing Route Plugins

Route plugins are tested entirely through `inject()`. Test status codes, response shapes, headers, and error cases.

```js
const { test } = require('node:test')
const assert = require('node:assert/strict')
const Fastify = require('fastify')
const userRoutes = require('../routes/users')

async function buildApp(opts = {}) {
  const app = Fastify({ logger: false })
  await app.register(userRoutes, opts)
  await app.ready()
  return app
}

test('GET /users returns array', async (t) => {
  const app = await buildApp()
  t.after(() => app.close())

  const res = await app.inject({ method: 'GET', url: '/users' })

  assert.strictEqual(res.statusCode, 200)
  assert.ok(Array.isArray(res.json()))
})

test('POST /users with invalid body returns 400', async (t) => {
  const app = await buildApp()
  t.after(() => app.close())

  const res = await app.inject({
    method: 'POST',
    url: '/users',
    payload: { invalid: true },
  })

  assert.strictEqual(res.statusCode, 400)
})
```

**Key Points:**
- The `buildApp` factory pattern centralizes instance creation and makes per-test configuration straightforward
- `t.after(() => app.close())` scopes teardown to the individual test when using `node:test`'s test context
- Test HTTP error cases explicitly — schema validation rejections, missing auth, not-found routes

---

### Testing Hook Behavior

Hooks registered by plugins (e.g., `onRequest`, `preHandler`, `onSend`) are tested by observing their side effects through route responses rather than by inspecting the hook registry directly.

#### Testing an `onRequest` Authentication Hook

```js
test('unauthenticated request returns 401', async (t) => {
  const app = Fastify({ logger: false })
  await app.register(require('../plugins/auth'), { secret: 'test' })
  app.get('/protected', async () => ({ ok: true }))
  await app.ready()
  t.after(() => app.close())

  const res = await app.inject({ method: 'GET', url: '/protected' })

  assert.strictEqual(res.statusCode, 401)
})

test('authenticated request passes through', async (t) => {
  const app = Fastify({ logger: false })
  await app.register(require('../plugins/auth'), { secret: 'test' })
  app.get('/protected', async () => ({ ok: true }))
  await app.ready()
  t.after(() => app.close())

  const res = await app.inject({
    method: 'GET',
    url: '/protected',
    headers: { authorization: 'Bearer valid-token' },
  })

  assert.strictEqual(res.statusCode, 200)
})
```

#### Testing an `onSend` Response Transformation Hook

```js
test('onSend hook adds x-request-id header', async (t) => {
  const app = Fastify({ logger: false })
  await app.register(require('../plugins/request-id'))
  app.get('/ping', async () => ({ pong: true }))
  await app.ready()
  t.after(() => app.close())

  const res = await app.inject({ method: 'GET', url: '/ping' })

  assert.ok(res.headers['x-request-id'], 'response should include x-request-id')
})
```

---

### Testing Registration Errors

Plugins that validate options or assert preconditions should throw during registration. Test this with `assert.rejects`.

```js
test('throws if connectionString is missing', async (t) => {
  const app = Fastify({ logger: false })
  app.register(require('../plugins/db'), {})

  await assert.rejects(
    () => app.ready(),
    (err) => {
      assert.match(err.message, /connectionString is required/)
      return true
    }
  )

  await app.close()
})
```

**Key Points:**
- Registration errors surface when `app.ready()` is awaited, not at `app.register()` call time
- `assert.rejects` accepts a validation function as its second argument for inspecting the thrown error
- Always call `app.close()` even when `ready()` rejects — some partial initialization may have allocated resources

---

### Mocking Dependencies in Plugin Tests

Infrastructure plugins (db, cache, external APIs) should be tested with mocked dependencies to avoid requiring live services in unit tests.

#### Decorator Stub Pattern

Replace a real dependency with a stub before registering the plugin under test:

```js
test('user route uses fastify.db', async (t) => {
  const app = Fastify({ logger: false })

  // Stub the db decorator before registering the route plugin
  app.decorate('db', {
    query: async (sql) => {
      return { rows: [{ id: 1, name: 'Alice' }] }
    },
  })

  await app.register(require('../routes/users'))
  await app.ready()
  t.after(() => app.close())

  const res = await app.inject({ method: 'GET', url: '/users' })

  assert.strictEqual(res.statusCode, 200)
  assert.deepStrictEqual(res.json(), [{ id: 1, name: 'Alice' }])
})
```

#### Module-Level Mocking

For plugins that `require()` external modules internally, use a mocking library or `node:test`'s mock utilities:

```js
const { mock } = require('node:test')

test('cache plugin calls redis.set on write', async (t) => {
  const redisMock = {
    set: mock.fn(async () => 'OK'),
    get: mock.fn(async () => null),
    quit: mock.fn(async () => {}),
  }

  // Inject mock via plugin options
  const app = Fastify({ logger: false })
  await app.register(require('../plugins/cache'), { client: redisMock })
  await app.ready()

  app.get('/data', async (request, reply) => {
    await app.cache.set('key', 'value')
    return { ok: true }
  })

  await app.inject({ method: 'GET', url: '/data' })

  assert.strictEqual(redisMock.set.mock.calls.length, 1)
  assert.deepStrictEqual(redisMock.set.mock.calls[0].arguments, ['key', 'value'])

  await app.close()
})
```

**Key Points:**
- Accepting an optional `client` option in plugins is a deliberate design choice that makes them testable without module mocking
- [Inference] Module-level mocking (`require` interception) is more fragile and couples tests to implementation details; preferring dependency injection via options is more maintainable
- `mock.fn()` in `node:test` tracks call counts and arguments without external libraries

---

### Integration Testing with Real Dependencies

Unit tests with stubs are fast but may miss integration failures. A secondary test layer uses real databases or services, typically in CI with Docker.

#### Docker Compose for Test Dependencies

```yaml
# docker-compose.test.yml
services:
  postgres:
    image: postgres:15-alpine
    environment:
      POSTGRES_DB: test_db
      POSTGRES_USER: test
      POSTGRES_PASSWORD: test
    ports:
      - '5432:5432'

  redis:
    image: redis:7-alpine
    ports:
      - '6379:6379'
```

```bash
docker compose -f docker-compose.test.yml up -d
TEST_DB_URL=postgres://test:test@localhost/test_db pnpm test:integration
docker compose -f docker-compose.test.yml down
```

#### Integration Test Structure

```js
// test/integration/db.test.js
const { test } = require('node:test')
const assert = require('node:assert/strict')
const Fastify = require('fastify')
const dbPlugin = require('../../plugins/db')

test('db plugin executes real query', async (t) => {
  const app = Fastify({ logger: false })
  await app.register(dbPlugin, {
    connectionString: process.env.TEST_DB_URL,
  })
  await app.ready()
  t.after(() => app.close())

  const result = await app.db.query('SELECT 1 + 1 AS sum')
  assert.strictEqual(result.rows[0].sum, 2)
})
```

---

### Testing Plugin Encapsulation Boundaries

A plugin wrapped in `fp` should expose its decorators to the parent scope. A raw plugin should not. Test both:

```js
test('fp-wrapped plugin exposes decorator to parent', async (t) => {
  const app = Fastify({ logger: false })

  await app.register(async (instance, opts) => {
    await instance.register(require('../plugins/db'), {
      connectionString: 'postgres://localhost/test',
    })
  })

  await app.ready()
  t.after(() => app.close())

  // fp-wrapped plugin: decorator visible on parent
  assert.ok(app.hasDecorator('db'))
})

test('raw plugin does not leak decorator to parent', async (t) => {
  const app = Fastify({ logger: false })

  await app.register(async (instance, opts) => {
    instance.decorate('scopedThing', true)
  })

  await app.ready()
  t.after(() => app.close())

  // Raw plugin: decorator NOT visible on parent
  assert.strictEqual(app.hasDecorator('scopedThing'), false)
})
```

---

### Testing Error Handler Plugins

Plugins that register custom error handlers are tested by triggering errors through routes and asserting the response shape.

```js
test('custom error handler formats 404 correctly', async (t) => {
  const app = Fastify({ logger: false })
  await app.register(require('../plugins/error-handler'))
  await app.ready()
  t.after(() => app.close())

  const res = await app.inject({ method: 'GET', url: '/nonexistent' })

  assert.strictEqual(res.statusCode, 404)
  assert.deepStrictEqual(res.json(), {
    statusCode: 404,
    error: 'Not Found',
    message: 'Route GET:/nonexistent not found',
  })
})
```

---

### Test Coverage Checklist

For any plugin, the following cases should be covered:

| Scenario | Test Method |
|---|---|
| Decorator added to instance | `hasDecorator()` after `ready()` |
| Decorator value / shape | Direct property assertion |
| Route responds correctly | `inject()` + status + body |
| Hook fires on request | `inject()` + observe side effect |
| Plugin throws on bad options | `assert.rejects()` on `ready()` |
| `onClose` teardown runs | Mock the resource, assert `.quit()` or `.end()` called |
| Encapsulation respected | Assert decorator presence/absence on parent scope |
| Dependency missing | Register without dependency, assert error |
| Schema registered | `app.getSchema('$id')` after `ready()` |

---

### Snapshot Testing for Response Shapes

For plugins that produce complex, stable response structures, snapshot testing reduces assertion verbosity.

```js
// Using @tapjs/snapshot or jest's toMatchSnapshot equivalent
test('user response matches snapshot', async (t) => {
  const res = await app.inject({ method: 'GET', url: '/users/1' })
  // With node:test — manual snapshot comparison against fixture file
  const fixture = JSON.parse(
    require('fs').readFileSync('./test/fixtures/user-response.json', 'utf8')
  )
  assert.deepStrictEqual(res.json(), fixture)
})
```

**Key Points:**
- Snapshot tests are brittle for frequently changing response shapes; use them for stable, well-defined contracts
- [Inference] `node:test` does not include built-in snapshot support as of Node.js 22; external tooling or manual fixture comparison is required — verify against current Node.js release notes for your version

---

**Related Topics:**
- Building internal plugin libraries — factory patterns and test utilities
- `fastify.inject()` advanced usage — multipart, cookies, piped streams
- Testing with TypeScript — typed `inject()` responses and decorator type augmentation
- Test containers — programmatic Docker management for integration tests (`testcontainers-node`)
- Code coverage in plugin monorepos — `c8` / `istanbul` with workspace-aware reporting
- Mocking `@fastify/jwt` and `@fastify/session` in auth plugin tests