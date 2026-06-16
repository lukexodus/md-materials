## Setting Up Node Test Runner

### Overview

Node.js ships a built-in test runner — `node:test` — available from Node.js 18 and stabilized in Node.js 20. It requires no additional dependencies, supports `async/await`, provides TAP-compatible output, and integrates naturally with Fastify's promise-based lifecycle. For Fastify projects that want minimal tooling overhead, it is a viable alternative to Jest or Vitest.

---

### Version Requirements

| Feature | Minimum Node.js Version |
|---|---|
| `node:test` available | 18.0.0 |
| `node:test` stable API | 20.0.0 |
| `--test` CLI flag | 18.0.0 |
| `test.mock` (built-in mocking) | 20.6.0 |
| Coverage via `--experimental-test-coverage` | 20.1.0 |
| `--test-reporter` flag | 19.6.0 / 20.0.0 |

[Unverified: specific minor version availability varies. Verify against the Node.js changelog for the exact version in use. API surface changed significantly between 18 and 20 — Node 20 LTS is the recommended minimum for production use of `node:test`.]

---

### No Installation Required

`node:test` is part of the Node.js standard library:

```typescript
import { test, describe, before, after, beforeEach, afterEach } from 'node:test'
import assert from 'node:assert/strict'
```

The only additional dependency needed for a TypeScript Fastify project is a TypeScript compiler or loader.

---

### TypeScript Execution

`node:test` runs JavaScript. TypeScript source must be compiled or stripped before execution. Three common approaches:

#### Option 1 — tsx (recommended)

`tsx` is a fast TypeScript runner built on esbuild. It handles TypeScript stripping with no configuration:

```bash
npm install --save-dev tsx
```

```bash
node --import tsx/esm --test tests/**/*.test.ts
```

Or for CommonJS:

```bash
node --require tsx/cjs --test tests/**/*.test.ts
```

#### Option 2 — ts-node

```bash
npm install --save-dev ts-node
```

```bash
node --loader ts-node/esm --test tests/**/*.test.ts
```

[Inference: `tsx` is generally faster than `ts-node` because it uses esbuild rather than the TypeScript compiler. For large test suites, startup time difference may be noticeable.]

#### Option 3 — Compile First, Then Run

```bash
tsc --project tsconfig.json
node --test dist/tests/**/*.test.js
```

This approach uses the full TypeScript compiler and produces accurate type errors, but requires a build step before each test run.

---

### tsconfig for Tests

```json
{
  "extends": "./tsconfig.json",
  "compilerOptions": {
    "module": "NodeNext",
    "moduleResolution": "NodeNext",
    "target": "ES2022",
    "outDir": "./dist"
  },
  "include": ["src/**/*", "tests/**/*"]
}
```

[Inference: `NodeNext` module mode aligns well with `node:test`'s native ESM execution model. If using `tsx`, module mode matters less because `tsx` handles the transformation.]

---

### package.json Scripts

```json
{
  "scripts": {
    "test": "node --import tsx/esm --test 'tests/**/*.test.ts'",
    "test:watch": "node --import tsx/esm --test --watch 'tests/**/*.test.ts'",
    "test:coverage": "node --import tsx/esm --experimental-test-coverage --test 'tests/**/*.test.ts'",
    "test:reporter": "node --import tsx/esm --test --test-reporter spec 'tests/**/*.test.ts'"
  }
}
```

**Key Points:**
- Glob patterns in `--test` must be quoted on Unix shells to prevent shell expansion before Node receives them.
- `--watch` mode re-runs tests when files change. It is available from Node 20.13.0+. [Unverified: exact version availability — verify against your Node.js release.]
- `--experimental-test-coverage` is prefixed experimental and its output format or availability may change across Node versions.

---

### Project Structure

```
project/
├── src/
│   ├── app.ts
│   ├── server.ts
│   ├── plugins/
│   └── routes/
├── tests/
│   ├── helpers/
│   │   └── build-app.ts
│   ├── routes/
│   │   ├── users.test.ts
│   │   └── products.test.ts
│   └── plugins/
│       └── auth.test.ts
├── package.json
└── tsconfig.json
```

---

### Core API

`node:test` provides a familiar describe/test structure:

```typescript
import { test, describe, before, after, beforeEach, afterEach } from 'node:test'
import assert from 'node:assert/strict'
```

| Function | Purpose |
|---|---|
| `test(name, fn)` | Defines a single test case |
| `describe(name, fn)` | Groups related tests |
| `before(fn)` | Runs once before all tests in the current scope |
| `after(fn)` | Runs once after all tests in the current scope |
| `beforeEach(fn)` | Runs before each test in the current scope |
| `afterEach(fn)` | Runs after each test in the current scope |
| `test.skip(name, fn)` | Skips a test |
| `test.todo(name)` | Marks a test as not yet implemented |
| `test.only(name, fn)` | Runs only this test (requires `--test-only` flag) |

---

### Assertions with node:assert

`node:test` does not include its own assertion library. The standard `node:assert/strict` module is used:

```typescript
import assert from 'node:assert/strict'

assert.equal(actual, expected)           // strict equality (===)
assert.deepEqual(actual, expected)       // deep structural equality
assert.ok(value)                         // asserts value is truthy
assert.throws(() => fn())                // asserts function throws
assert.rejects(async () => fn())         // asserts async function rejects
assert.match(string, /regex/)           // asserts string matches regex
assert.doesNotMatch(string, /regex/)    // asserts string does not match regex
```

[Inference: `node:assert/strict` is less ergonomic than Jest's `expect` API for complex assertions like partial object matching. There is no built-in equivalent to `toMatchObject`. Deep partial matching requires manual property checking or a third-party helper.]

---

### The Test App Factory

The same factory pattern used with Jest applies here:

```typescript
// tests/helpers/build-app.ts
import Fastify, { FastifyInstance, FastifyServerOptions } from 'fastify'
import { buildApp } from '../../src/app.js'

export async function buildTestApp(
  opts: FastifyServerOptions = {}
): Promise<FastifyInstance> {
  const app = await buildApp({
    logger: false,
    ...opts,
  })
  await app.ready()
  return app
}
```

---

### Writing a Test File

```typescript
// tests/routes/users.test.ts
import { describe, test, before, after } from 'node:test'
import assert from 'node:assert/strict'
import { buildTestApp } from '../helpers/build-app.js'
import type { FastifyInstance } from 'fastify'

describe('GET /users', () => {
  let app: FastifyInstance

  before(async () => {
    app = await buildTestApp()
  })

  after(async () => {
    await app.close()
  })

  test('returns 200', async () => {
    const response = await app.inject({ method: 'GET', url: '/users' })
    assert.equal(response.statusCode, 200)
  })

  test('returns JSON content-type', async () => {
    const response = await app.inject({ method: 'GET', url: '/users' })
    assert.match(response.headers['content-type'], /application\/json/)
  })

  test('returns an array in body', async () => {
    const response = await app.inject({ method: 'GET', url: '/users' })
    const body = response.json<{ users: unknown[] }>()
    assert.ok(Array.isArray(body.users))
  })
})

describe('POST /users', () => {
  let app: FastifyInstance

  before(async () => {
    app = await buildTestApp()
  })

  after(async () => {
    await app.close()
  })

  test('returns 201 with valid payload', async () => {
    const response = await app.inject({
      method: 'POST',
      url: '/users',
      payload: { name: 'Luke', email: 'luke@example.com' },
    })
    assert.equal(response.statusCode, 201)
  })

  test('returns 400 when email is missing', async () => {
    const response = await app.inject({
      method: 'POST',
      url: '/users',
      payload: { name: 'Luke' },
    })
    assert.equal(response.statusCode, 400)
  })
})
```

---

### Lifecycle Scoping Behavior

Unlike Jest, `before` and `after` in `node:test` are scoped to the `describe` block they are defined in. Each `describe` block manages its own lifecycle independently.

```typescript
describe('Suite A', () => {
  let app: FastifyInstance

  before(async () => {
    app = await buildTestApp()   // runs once for Suite A only
  })

  after(async () => {
    await app.close()            // runs once after Suite A only
  })

  test('...', async () => { /* uses app from Suite A */ })
})

describe('Suite B', () => {
  let app: FastifyInstance

  before(async () => {
    app = await buildTestApp()   // separate instance for Suite B
  })

  after(async () => {
    await app.close()
  })

  test('...', async () => { /* uses app from Suite B */ })
})
```

**Key Points:**
- Top-level `before` / `after` calls (outside any `describe`) apply to the entire file.
- Each `describe` with its own `before` / `after` creates an independently managed Fastify instance — clean isolation with no shared state.

---

### Test Isolation with beforeEach and afterEach

For tests that mutate state (e.g., database records), `beforeEach` and `afterEach` provide per-test setup:

```typescript
describe('POST /users', () => {
  let app: FastifyInstance

  before(async () => {
    app = await buildTestApp()
  })

  after(async () => {
    await app.close()
  })

  beforeEach(async () => {
    await app.db.query('DELETE FROM users')  // reset table before each test
  })

  test('creates a user', async () => {
    const response = await app.inject({
      method: 'POST',
      url: '/users',
      payload: { name: 'Luke', email: 'luke@example.com' },
    })
    assert.equal(response.statusCode, 201)
  })
})
```

[Inference: database reset in `beforeEach` is one approach to test isolation. Transaction rollback per test is another. The right choice depends on whether the ORM or database driver supports transaction wrapping in the test context.]

---

### Built-in Mocking

From Node.js 20.6.0, `node:test` includes a `mock` API for replacing functions and methods:

```typescript
import { test, mock } from 'node:test'
import assert from 'node:assert/strict'

test('mocks an external service call', async (t) => {
  const mockFetch = t.mock.fn(async () => ({
    ok: true,
    json: async () => ({ status: 'charged' }),
  }))

  // Replace global fetch for this test
  globalThis.fetch = mockFetch as typeof fetch

  const response = await app.inject({
    method: 'POST',
    url: '/checkout',
    payload: { amount: 5000 },
  })

  assert.equal(response.statusCode, 200)
  assert.equal(mockFetch.mock.calls.length, 1)
})
```

**Key Points:**
- `t.mock.fn()` creates a mock function scoped to the test. Mocks created on `t` are automatically restored after the test completes.
- `mock.method(object, 'methodName', replacement)` replaces a method on an object for the duration of the test.
- The built-in mocking API does not support ES module mocking at the import level. [Inference: for intercepting module-level imports, a network-level interceptor like `nock` or `undici`'s `MockAgent` is more appropriate.]

---

### Reporters

`node:test` outputs TAP format by default. Alternative reporters are available via `--test-reporter`:

```bash
# Default TAP output
node --test tests/**/*.test.ts

# Spec format (human-readable, colored output)
node --test --test-reporter spec tests/**/*.test.ts

# JUnit XML (for CI systems)
node --test --test-reporter junit --test-reporter-destination report.xml tests/**/*.test.ts

# Multiple reporters simultaneously
node --test \
  --test-reporter spec --test-reporter-destination stdout \
  --test-reporter junit --test-reporter-destination report.xml \
  tests/**/*.test.ts
```

**Key Points:**
- `spec` reporter produces colored, hierarchical output similar to Jest's default reporter.
- `junit` is consumed by CI platforms (Jenkins, GitHub Actions test summary, GitLab CI).
- Multiple `--test-reporter` and `--test-reporter-destination` pairs can be combined — each pair specifies a reporter and its output destination.

[Unverified: reporter availability varies by Node.js version. Confirm available reporters against your target Node version's documentation.]

---

### Coverage

```bash
node --import tsx/esm --experimental-test-coverage --test 'tests/**/*.test.ts'
```

Coverage output is printed to stdout after the test run. As of Node 20, it covers line, branch, and function coverage.

To exclude files from coverage:

```bash
node --import tsx/esm \
  --experimental-test-coverage \
  --test-coverage-exclude 'src/server.ts' \
  --test-coverage-exclude 'src/**/*.d.ts' \
  --test 'tests/**/*.test.ts'
```

[Unverified: `--test-coverage-exclude` flag availability and syntax — verify against your target Node.js version. The coverage implementation is labeled experimental and its behavior may change.]

---

### Filtering and Running Specific Tests

```bash
# Run only tests whose name matches a pattern
node --import tsx/esm --test --test-name-pattern 'GET /users' 'tests/**/*.test.ts'

# Run a single file
node --import tsx/esm --test tests/routes/users.test.ts

# Run only tests marked with test.only (requires --test-only)
node --import tsx/esm --test --test-only 'tests/**/*.test.ts'
```

---

### Parallel Execution

By default, `node:test` runs top-level test files in parallel and tests within a file sequentially. This matches Jest's default behavior per file.

To run tests within a file concurrently:

```typescript
test('concurrent test A', { concurrency: true }, async () => {
  // ...
})

test('concurrent test B', { concurrency: true }, async () => {
  // ...
})
```

Or at the `describe` level:

```typescript
describe('parallel suite', { concurrency: true }, () => {
  test('A', async () => { /* ... */ })
  test('B', async () => { /* ... */ })
})
```

[Inference: concurrent tests within a file share the same process and any module-level state. Fastify app instances should still be scoped per `describe` block to avoid interference when running concurrently.]

---

### Comparison with Jest

| Concern | `node:test` | Jest |
|---|---|---|
| Installation | None | `jest`, `ts-jest`, `@types/jest` |
| TypeScript | Requires `tsx` or `ts-node` | `ts-jest` transformer |
| Assertion API | `node:assert/strict` | `expect()` with rich matchers |
| Partial object matching | Not built-in | `toMatchObject()` |
| Mocking | Built-in from Node 20.6 | `jest.mock()`, `jest.fn()` |
| Module-level mocking | Not supported | `jest.mock('module')` |
| Coverage | `--experimental-test-coverage` | `--coverage` (stable) |
| Watch mode | `--watch` (Node 20.13+) | `--watch` (stable) |
| Reporter options | TAP, spec, junit, dot | Multiple built-in + ecosystem |
| Snapshot testing | Not built-in | `toMatchSnapshot()` |
| CI integration | JUnit reporter | Native + ecosystem |
| Ecosystem maturity | Newer, evolving | Mature, stable |

[Inference: Jest remains more feature-complete for complex test scenarios. `node:test` is most appropriate for projects that prioritize minimal dependencies and are comfortable with a less mature ecosystem.]

---

### CI Integration

```yaml
# .github/workflows/test.yml
name: Test

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'

      - run: npm ci

      - name: Run tests
        run: |
          node --import tsx/esm \
            --test \
            --test-reporter spec --test-reporter-destination stdout \
            --test-reporter junit --test-reporter-destination report.xml \
            'tests/**/*.test.ts'

      - name: Publish test results
        uses: mikepenz/action-junit-report@v4
        if: always()
        with:
          report_paths: 'report.xml'
```

---

### Common Issues

**`ERR_UNKNOWN_FILE_EXTENSION` for `.ts` files**

Node does not understand TypeScript natively. Ensure `--import tsx/esm` or `--loader ts-node/esm` is present in the command.

**`Cannot find module` with `.js` extension imports**

TypeScript projects targeting ESM often use `.js` extensions in imports (`import { x } from './module.js'`). This is correct for ESM but can trip up some loaders. Confirm your tsconfig `moduleResolution` is set to `NodeNext` or `Bundler`.

**Tests hang after completion**

A Fastify instance was not closed. Ensure every `before` that creates an app has a corresponding `after` that calls `app.close()`. Unlike Jest, `node:test` does not have a `--forceExit` flag. [Unverified: behavior of hanging processes in `node:test` may vary by version.]

**`before is not defined`**

`before` and `after` must be imported explicitly from `node:test`. They are not globals:

```typescript
import { test, describe, before, after } from 'node:test'
```

**Glob pattern not expanding**

On some shells, unquoted glob patterns are expanded by the shell before Node receives them. Quote the pattern:

```bash
node --test 'tests/**/*.test.ts'   # correct
node --test tests/**/*.test.ts     # may expand incorrectly on some shells
```

---

**Related Topics**
- Comparing `node:test` and Vitest for Fastify projects
- Using `undici` `MockAgent` for HTTP interception in `node:test`
- Database test isolation with `node:test` — transactions vs. truncation
- Structuring monorepo test runs with `node:test --test` across workspaces
- Generating TAP reports and integrating with TAP-compatible CI reporters
- Type-safe assertion helpers to supplement `node:assert/strict`