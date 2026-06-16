## Testing with Tap

Tap (Test Anything Protocol) is a mature Node.js testing framework with first-class support for async tests, subtests, and built-in coverage. Fastify's own test suite historically used Tap, making it a natural fit for Fastify projects.

---

### What Tap Provides

- Built-in test runner, assertion library, and coverage (via `c8`)
- Subtest support with nested `t.test()` calls
- Automatic async/promise handling
- TAP protocol output, compatible with many CI reporters
- No global test registration — tests are plain Node.js scripts

**Key Points**

- The current major version is `tap` v18+ (ESM and CJS supported) [Unverified — verify the current published version before installing]
- Tap uses `c8` under the hood for coverage when `--coverage` is passed
- Each test file is run as an independent child process by default

---

### Installation

bash

```bash
npm install --save-dev tap
```

Add a test script to `package.json`:

json

```json
{
  "scripts": {
    "test": "tap",
    "test:coverage": "tap --coverage"
  }
}
```

By default, `tap` discovers test files matching `test/**/*.{js,mjs,cjs}`, `test.js`, and similar patterns. This is configurable.

---

### `.taprc` Configuration File

yaml

```yaml
# .taprc
files:
  - test/**/*.test.js
coverage: true
coverage-report:
  - text
  - html
branches: 80
lines: 90
functions: 90
statements: 90
reporter: spec
timeout: 30
```

**Key Points**

- `.taprc` is YAML; a `.taprc.js` or `package.json#tap` key are also supported [Inference — verify config format against your installed version]
- `timeout` is per test file in seconds; long-running integration tests may need this raised
- `reporter: spec` gives human-readable output; `reporter: tap` gives raw TAP output

---

### Setting Up a Testable Fastify App

js

```js
// src/app.js
import Fastify from 'fastify'

export function buildApp(opts = {}) {
  const app = Fastify(opts)

  app.post('/users', {
    schema: {
      body: {
        type: 'object',
        required: ['username', 'email'],
        properties: {
          username: { type: 'string', minLength: 3 },
          email: { type: 'string', format: 'email' }
        },
        additionalProperties: false
      }
    }
  }, async (request, reply) => {
    reply.code(201)
    return { created: true, user: request.body }
  })

  app.get('/users/:id', {
    schema: {
      params: {
        type: 'object',
        properties: {
          id: { type: 'integer' }
        },
        required: ['id']
      }
    }
  }, async (request, reply) => {
    const { id } = request.params
    if (id === 0) {
      reply.code(404)
      return { error: 'Not Found' }
    }
    return { id, username: 'alice' }
  })

  return app
}
```

**Key Points**

- `buildApp()` factory pattern — each test file creates its own isolated instance
- Accepts `opts` so tests can pass `{ logger: false }` or other Fastify options
- No `app.listen()` call — `inject()` does not need the server to bind a port

---

### Basic Test Structure

js

```js
// test/users.test.js
import tap from 'tap'
import { buildApp } from '../src/app.js'

tap.test('POST /users', async (t) => {
  const app = buildApp({ logger: false })
  await app.ready()
  t.teardown(() => app.close())

  t.test('creates a user with valid payload', async (t) => {
    const res = await app.inject({
      method: 'POST',
      url: '/users',
      payload: {
        username: 'alice',
        email: 'alice@example.com'
      }
    })

    t.equal(res.statusCode, 201)
    t.match(res.json(), { created: true })
  })

  t.test('returns 400 for invalid email', async (t) => {
    const res = await app.inject({
      method: 'POST',
      url: '/users',
      payload: {
        username: 'alice',
        email: 'not-an-email'
      }
    })

    t.equal(res.statusCode, 400)
    t.match(res.json(), { error: 'Bad Request' })
  })
})
```

**Key Points**

- `t.teardown()` runs after all subtests in the current block complete — even if assertions fail
- `t.match()` does a deep partial match: the response body only needs to contain the specified keys with matching values; extra keys are ignored
- `await app.ready()` ensures all plugins are registered before tests run

---

### Tap Assertion Reference

| Assertion | Description |
| --- | --- |
| `t.equal(a, b)` | Strict equality (`===`) |
| `t.not(a, b)` | Strict inequality |
| `t.same(a, b)` | Deep equality (like `assert.deepStrictEqual`) |
| `t.notSame(a, b)` | Deep inequality |
| `t.match(obj, pattern)` | Partial deep match |
| `t.notMatch(obj, pattern)` | Partial deep non-match |
| `t.ok(val)` | Truthy check |
| `t.notOk(val)` | Falsy check |
| `t.type(val, Type)` | `instanceof` or `typeof` check |
| `t.throws(fn)` | Function throws synchronously |
| `t.rejects(promise)` | Promise rejects |
| `t.resolves(promise)` | Promise resolves |
| `t.has(obj, subset)` | Object contains subset of keys |
| `t.hasProp(obj, key)` | Object has own property |
| `t.fail(msg)` | Unconditional failure |
| `t.pass(msg)` | Unconditional pass |
| `t.plan(n)` | Expect exactly n assertions |

---

### Using `t.plan()` for Assertion Counting

`t.plan()` declares how many assertions the test expects. If the count does not match at the end of the test, Tap fails it — catching cases where assertions inside callbacks or conditionals are silently skipped.

js

```js
t.test('plan example', async (t) => {
  t.plan(3)

  const res = await app.inject({
    method: 'GET',
    url: '/users/1'
  })

  t.equal(res.statusCode, 200)
  t.ok(res.json().id)
  t.equal(res.json().username, 'alice')
})
```

**Key Points**

- `t.plan()` is especially useful in tests with conditional branches where an assertion might not be reached
- In fully `async`/`await` tests, `t.plan()` is less critical since the test will always reach all assertions linearly — but it remains a useful safety net [Inference]

---

### Nested Subtests

Subtests organize related assertions into named groups. Each subtest receives its own `t` instance with its own assertion count and teardown queue.

js

```js
tap.test('GET /users/:id', async (t) => {
  const app = buildApp({ logger: false })
  await app.ready()
  t.teardown(() => app.close())

  t.test('returns user for valid id', async (t) => {
    const res = await app.inject({
      method: 'GET',
      url: '/users/42'
    })

    t.equal(res.statusCode, 200)
    t.equal(res.json().id, 42)
  })

  t.test('returns 404 for id 0', async (t) => {
    const res = await app.inject({
      method: 'GET',
      url: '/users/0'
    })

    t.equal(res.statusCode, 404)
    t.match(res.json(), { error: 'Not Found' })
  })

  t.test('returns 400 for non-integer id', async (t) => {
    const res = await app.inject({
      method: 'GET',
      url: '/users/abc'
    })

    t.equal(res.statusCode, 400)
  })
})
```

---

### Shared App Instance vs Per-Test Instances

**Shared instance** — one `buildApp()` call per `tap.test` block, reused across subtests:

js

```js
tap.test('users routes', async (t) => {
  const app = buildApp({ logger: false })
  await app.ready()
  t.teardown(() => app.close())

  t.test('GET /users/1', async (t) => { /* uses shared app */ })
  t.test('POST /users', async (t) => { /* uses shared app */ })
})
```

**Per-test instance** — a new app per subtest, full isolation:

js

```js
tap.test('users routes', async (t) => {
  t.test('GET /users/1', async (t) => {
    const app = buildApp({ logger: false })
    await app.ready()
    t.teardown(() => app.close())

    const res = await app.inject({ method: 'GET', url: '/users/1' })
    t.equal(res.statusCode, 200)
  })
})
```

**Key Points**

- Shared instances are faster — Fastify startup and plugin registration happen once
- Per-test instances give full state isolation — important when plugins or decorators accumulate state between requests [Inference]
- For stateless routes with no side effects, a shared instance is generally sufficient [Inference]

---

### Testing Hooks

js

```js
// src/app.js (extended)
app.addHook('onRequest', async (request, reply) => {
  if (!request.headers['x-api-key']) {
    reply.code(401).send({ error: 'Unauthorized' })
  }
})
```

js

```js
tap.test('onRequest hook — API key guard', async (t) => {
  const app = buildApp({ logger: false })
  await app.ready()
  t.teardown(() => app.close())

  t.test('rejects request without API key', async (t) => {
    const res = await app.inject({
      method: 'GET',
      url: '/users/1'
    })

    t.equal(res.statusCode, 401)
    t.match(res.json(), { error: 'Unauthorized' })
  })

  t.test('allows request with API key', async (t) => {
    const res = await app.inject({
      method: 'GET',
      url: '/users/1',
      headers: { 'x-api-key': 'secret' }
    })

    t.equal(res.statusCode, 200)
  })
})
```

---

### Testing Plugins

js

```js
// src/plugins/config.js
import fp from 'fastify-plugin'

async function configPlugin(app, opts) {
  app.decorate('config', {
    dbUrl: process.env.DATABASE_URL || 'sqlite::memory:'
  })
}

export default fp(configPlugin)
```

js

```js
// test/plugins/config.test.js
import tap from 'tap'
import Fastify from 'fastify'
import configPlugin from '../../src/plugins/config.js'

tap.test('config plugin', async (t) => {
  const app = Fastify({ logger: false })
  app.register(configPlugin)
  await app.ready()
  t.teardown(() => app.close())

  t.ok(app.config, 'config decorator exists')
  t.type(app.config.dbUrl, 'string')
})
```

**Key Points**

- Testing plugins in isolation avoids pulling in the full app stack
- `fastify-plugin` (`fp`) unwraps encapsulation — decorators added inside it are visible on the root instance
- Without `fp`, decorators added inside a plugin are scoped and not visible on the parent instance [Inference — depends on Fastify's encapsulation model; verify with your plugin structure]

---

### Mocking with Tap

Tap does not ship a built-in mock/stub library. Common approaches:

#### Using `sinon`

bash

```bash
npm install --save-dev sinon
```

js

```js
import tap from 'tap'
import sinon from 'sinon'
import { buildApp } from '../src/app.js'
import * as db from '../src/db.js'

tap.test('mocking db.findUser', async (t) => {
  const stub = sinon.stub(db, 'findUser').resolves({ id: 1, username: 'alice' })
  t.teardown(() => stub.restore())

  const app = buildApp({ logger: false })
  await app.ready()
  t.teardown(() => app.close())

  const res = await app.inject({ method: 'GET', url: '/users/1' })
  t.equal(res.statusCode, 200)
  t.ok(stub.calledOnce)
})
```

#### Using Node.js `--import` mocking (Node 22+)

Node 22 introduced `MockModuleContext` via `node:test`. This is not directly available in Tap's execution context without additional wiring. [Unverified — verify compatibility between Tap's child process runner and Node mock module APIs]

---

### Running Specific Tests

bash

```bash
# Run a single file
npx tap test/users.test.js

# Run with verbose output
npx tap --reporter=spec test/users.test.js

# Run with grep filter (Tap 16+)
npx tap --grep "returns 400" test/users.test.js
```

**Key Points**

- `--grep` filters by test name substring [Unverified — verify flag availability in your installed Tap version]
- Running a single file bypasses the `.taprc` file discovery — specify any needed flags explicitly

---

### Coverage with Tap

bash

```bash
npx tap --coverage
```

Tap uses `c8` internally. The same `.taprc` threshold keys apply:

yaml

```yaml
coverage: true
branches: 80
lines: 90
functions: 90
statements: 90
coverage-report:
  - text
  - lcov
  - html
```

To view the HTML report:

bash

```bash
open coverage/index.html
```

**Key Points**

- Coverage is collected across all test files in the run, not per-file
- `lcov` output lands at `coverage/lcov.info` for upload to Codecov or similar

---

### TAP Output Format

Tap emits raw TAP protocol output, which looks like:

```
TAP version 14
# Subtest: POST /users
    # Subtest: creates a user with valid payload
    ok 1 - statusCode === 201
    ok 2 - match { created: true }
    1..2
ok 1 - creates a user with valid payload
    # Subtest: returns 400 for invalid email
    ok 3 - statusCode === 400
    ok 4 - match { error: 'Bad Request' }
    1..2
ok 2 - returns 400 for invalid email
1..2
ok 1 - POST /users
1..1
# tests 4
# pass  4
# fail  0
```

This format is machine-readable and consumed by TAP-compatible reporters and CI tools.

---

### Test Lifecycle Flow

NoYesYesNotap CLI invokedDiscover test filesSpawn child process perfileExecute tap.test top-levelblockawait app.readyRun subtests sequentiallyt.teardown callbacks runapp.close calledTAP output collectedAll files done?Aggregate results +coverageThresholds met?Exit 0Exit 1

---

### Common Pitfalls

**Not awaiting `app.ready()`**
Schema compilation and plugin registration are async. Skipping `await app.ready()` can result in routes or decorators not being available when `inject()` is called. [Inference]

**Not registering a `t.teardown()` for `app.close()`**
Tap detects open handles. An unclosed Fastify server will cause Tap to warn or hang after tests complete.

**Using `tap.test` for subtests instead of `t.test`**
`tap.test` registers a top-level test. Inside a test block, always use `t.test` (the subtest's own `t`) to keep the hierarchy correct.

**Relying on test execution order across files**
Each file runs in its own child process. Do not assume one file's state is visible to another.

**Asserting on exact Ajv error message strings**
Ajv message wording can change between versions. Use `t.match(res.json().message, /keyword/)` rather than strict equality.

---

**Related Topics**

- Tap snapshots (`t.matchSnapshot`) for response body regression testing
- Parallel test execution with `--jobs` in Tap
- Tap with TypeScript (via `ts-node` or `tsx`)
- Integrating Tap output with GitHub Actions test summaries
- Testing Fastify decorators in isolation
- Using `sinon` timers for testing hook timeouts
- Combining Tap coverage with Codecov upload in CI