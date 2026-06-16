## Setting Up Jest with Fastify

### Overview

Jest is a widely used JavaScript test runner that works with Fastify through its standard async test API. Because Fastify's lifecycle is promise-based and its primary test primitive — `fastify.inject()` — returns a Promise, Jest's `async/await` support integrates cleanly. The main configuration concerns are TypeScript compilation, ESM compatibility, open handle detection, and module resolution.

---

### Installation

#### Dependencies

```bash
# Jest core and CLI
npm install --save-dev jest

# TypeScript support
npm install --save-dev ts-jest @types/jest

# Type definitions for Node.js (required for Fastify projects)
npm install --save-dev @types/node
```

`ts-jest` is a Jest transformer that compiles TypeScript files before Jest executes them. It does not require a separate build step.

[Unverified: specific version compatibility between `ts-jest`, `jest`, and TypeScript changes across major releases. Verify that the installed versions are compatible using the `ts-jest` compatibility table in its documentation.]

---

### jest.config.ts

The recommended configuration file format for TypeScript projects is `jest.config.ts`:

```typescript
import type { Config } from 'jest'

const config: Config = {
  preset: 'ts-jest',
  testEnvironment: 'node',
  roots: ['<rootDir>/tests'],
  testMatch: ['**/*.test.ts', '**/*.spec.ts'],
  moduleFileExtensions: ['ts', 'tsx', 'js', 'json'],
  clearMocks: true,
  collectCoverageFrom: [
    'src/**/*.ts',
    '!src/server.ts',       // entrypoint — not tested directly
    '!src/**/*.d.ts',
  ],
  coverageDirectory: 'coverage',
  coverageReporters: ['text', 'lcov'],
}

export default config
```

**Key Points:**
- `testEnvironment: 'node'` is required. The default (`jsdom`) is browser-oriented and incompatible with Fastify's Node.js APIs.
- `clearMocks: true` resets mock state between each test automatically, reducing inter-test contamination.
- `roots` restricts Jest's file discovery to `tests/` — prevents it from scanning `node_modules` or `dist`.
- `src/server.ts` (the entrypoint that calls `fastify.listen()`) is excluded from coverage because it is not exercised through `inject()`.

---

### tsconfig for Tests

If your project `tsconfig.json` targets ESM or has settings incompatible with `ts-jest`, create a separate `tsconfig.test.json` that extends the base and overrides only what is necessary:

```json
{
  "extends": "./tsconfig.json",
  "compilerOptions": {
    "module": "CommonJS",
    "moduleResolution": "node",
    "esModuleInterop": true,
    "outDir": undefined
  },
  "include": ["src/**/*", "tests/**/*"]
}
```

Reference it in `jest.config.ts`:

```typescript
const config: Config = {
  preset: 'ts-jest',
  testEnvironment: 'node',
  globals: {
    'ts-jest': {
      tsconfig: './tsconfig.test.json',
    },
  },
}
```

[Inference: this separation is commonly needed when the main `tsconfig.json` targets `"module": "ESNext"` or `"module": "NodeNext"`, which `ts-jest` does not handle natively without additional ESM configuration.]

---

### ESM Compatibility

Fastify itself ships as CommonJS. Some Fastify plugins and ecosystem packages ship as pure ESM (no CommonJS build). This can cause `SyntaxError: Cannot use import statement in a module` errors in Jest, because Jest runs in CommonJS mode by default.

#### Option 1 — Stay in CommonJS (simplest)

Configure `tsconfig.test.json` with `"module": "CommonJS"` as shown above. Dynamic imports in application code (`await import(...)`) are transformed to `require()` by `ts-jest`. This works for most Fastify projects.

#### Option 2 — Enable Jest's Experimental ESM Mode

If dependencies require native ESM:

```json
// package.json
{
  "scripts": {
    "test": "NODE_OPTIONS=--experimental-vm-modules jest"
  }
}
```

```typescript
// jest.config.ts
const config: Config = {
  extensionsToTreatAsEsm: ['.ts'],
  moduleNameMapper: {
    '^(\\.{1,2}/.*)\\.js$': '$1',
  },
  transform: {
    '^.+\\.tsx?$': [
      'ts-jest',
      { useESM: true },
    ],
  },
}
```

[Inference: Jest's ESM support is marked experimental in many versions and has known edge cases with certain module patterns. Evaluate whether native ESM is necessary before adopting this path. Behavior may vary across Node.js versions.]

---

### Project Structure

A conventional layout for a Fastify project with Jest:

```
project/
├── src/
│   ├── app.ts              # buildApp factory
│   ├── server.ts           # entrypoint — calls listen()
│   ├── plugins/
│   │   ├── database.ts
│   │   └── auth.ts
│   └── routes/
│       ├── users.ts
│       └── products.ts
├── tests/
│   ├── helpers/
│   │   └── build-app.ts    # shared test factory
│   ├── routes/
│   │   ├── users.test.ts
│   │   └── products.test.ts
│   └── plugins/
│       └── auth.test.ts
├── jest.config.ts
├── tsconfig.json
└── tsconfig.test.json
```

---

### The Test App Factory

Centralizing app construction in a test helper prevents duplication and makes it easy to apply test-specific overrides:

```typescript
// tests/helpers/build-app.ts
import Fastify, { FastifyInstance, FastifyServerOptions } from 'fastify'
import { buildApp } from '../../src/app'

export async function buildTestApp(
  opts: FastifyServerOptions = {}
): Promise<FastifyInstance> {
  const app = await buildApp({
    logger: false,   // suppress log output in test runs
    ...opts,
  })
  await app.ready()
  return app
}
```

```typescript
// src/app.ts
import Fastify, { FastifyInstance, FastifyServerOptions } from 'fastify'
import databasePlugin from './plugins/database'
import authPlugin from './plugins/auth'
import userRoutes from './routes/users'

export async function buildApp(
  opts: FastifyServerOptions = {}
): Promise<FastifyInstance> {
  const fastify = Fastify(opts)

  await fastify.register(databasePlugin)
  await fastify.register(authPlugin)
  await fastify.register(userRoutes)

  return fastify
}
```

---

### Writing a Test File

```typescript
// tests/routes/users.test.ts
import { buildTestApp } from '../helpers/build-app'
import type { FastifyInstance } from 'fastify'

let app: FastifyInstance

beforeAll(async () => {
  app = await buildTestApp()
})

afterAll(async () => {
  await app.close()
})

describe('GET /users', () => {
  test('returns 200', async () => {
    const response = await app.inject({ method: 'GET', url: '/users' })
    expect(response.statusCode).toBe(200)
  })

  test('returns an array of users', async () => {
    const response = await app.inject({ method: 'GET', url: '/users' })
    const body = response.json<{ users: unknown[] }>()
    expect(Array.isArray(body.users)).toBe(true)
  })
})

describe('POST /users', () => {
  test('returns 201 with valid payload', async () => {
    const response = await app.inject({
      method: 'POST',
      url: '/users',
      payload: { name: 'Luke', email: 'luke@example.com' },
    })
    expect(response.statusCode).toBe(201)
  })

  test('returns 400 when email is missing', async () => {
    const response = await app.inject({
      method: 'POST',
      url: '/users',
      payload: { name: 'Luke' },
    })
    expect(response.statusCode).toBe(400)
  })
})
```

---

### Handling Open Handles

Jest detects asynchronous resources (timers, database connections, server listeners) that remain open after all tests complete. This produces the warning:

```
Jest did not exit one second after the test run has completed.
```

The most common cause in Fastify projects is a missing `app.close()` in `afterAll`.

#### Correct teardown

```typescript
afterAll(async () => {
  await app.close()
})
```

#### Using --detectOpenHandles

During development, run Jest with `--detectOpenHandles` to identify which resources are still open:

```bash
npx jest --detectOpenHandles
```

#### Using --forceExit (last resort)

`--forceExit` causes Jest to terminate the process after all tests complete regardless of open handles. It masks the underlying problem rather than resolving it and should not be used as a permanent fix. [Inference: relying on `--forceExit` in CI can hide resource leaks that accumulate over time.]

```json
// package.json — avoid using this permanently
{
  "scripts": {
    "test": "jest --forceExit"
  }
}
```

---

### package.json Scripts

```json
{
  "scripts": {
    "test": "jest",
    "test:watch": "jest --watch",
    "test:coverage": "jest --coverage",
    "test:verbose": "jest --verbose"
  }
}
```

**Key Points:**
- `--watch` requires either Git or a file watcher and re-runs tests on file changes. Useful during active development.
- `--coverage` generates a coverage report using the `collectCoverageFrom` paths configured in `jest.config.ts`.
- `--verbose` prints each individual test name and result, not just suite summaries.

---

### Global Setup and Teardown

For test infrastructure that must be initialized once before the entire test suite — such as starting a test database container — Jest provides `globalSetup` and `globalTeardown`:

```typescript
// jest.config.ts
const config: Config = {
  globalSetup: './tests/global-setup.ts',
  globalTeardown: './tests/global-teardown.ts',
}
```

```typescript
// tests/global-setup.ts
export default async function globalSetup() {
  // Start a test database, set environment variables, etc.
  process.env.DATABASE_URL = 'postgres://localhost:5432/test_db'
}
```

```typescript
// tests/global-teardown.ts
export default async function globalTeardown() {
  // Stop test infrastructure
}
```

**Key Points:**
- `globalSetup` and `globalTeardown` run in a separate Node.js context from the test files. Fastify app instances created here are not accessible in tests.
- They are suited for process-level infrastructure (containers, env vars), not for Fastify instance setup. Fastify instances belong in `beforeAll`/`afterAll` within test files.

---

### Jest Setup Files

For code that should run inside the Jest test environment before each test file — such as custom matchers or global mocks — use `setupFilesAfterFramework`:

```typescript
// jest.config.ts
const config: Config = {
  setupFilesAfterFramework: ['./tests/setup.ts'],
}
```

```typescript
// tests/setup.ts
import { expect } from '@jest/globals'

// Example: custom matcher for Fastify responses
expect.extend({
  toHaveStatusCode(response: { statusCode: number }, expected: number) {
    const pass = response.statusCode === expected
    return {
      pass,
      message: () =>
        `Expected status ${expected}, received ${response.statusCode}`,
    }
  },
})
```

---

### Coverage Configuration

```typescript
// jest.config.ts
const config: Config = {
  collectCoverage: false,    // only collect when --coverage flag is passed
  collectCoverageFrom: [
    'src/**/*.ts',
    '!src/server.ts',
    '!src/**/*.d.ts',
    '!src/**/index.ts',      // barrel files — typically no logic to cover
  ],
  coverageThresholds: {
    global: {
      lines: 80,
      functions: 80,
      branches: 70,
      statements: 80,
    },
  },
  coverageReporters: ['text', 'lcov', 'html'],
}
```

**Key Points:**
- `coverageThresholds` causes Jest to exit with a non-zero code if coverage falls below the specified percentages. Useful for enforcing minimum coverage in CI.
- `lcov` output is consumed by tools like Codecov, Coveralls, and SonarQube.
- `html` generates a browsable coverage report in the `coverage/` directory.
- [Inference: branch coverage is typically harder to achieve than line coverage in Fastify route handlers due to error branches. Setting branch thresholds lower than line thresholds is common.]

---

### Running Tests in CI

A minimal GitHub Actions workflow for a Fastify + Jest project:

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

      - run: npm test

      - run: npm run test:coverage
```

[Inference: if tests require a database, a Redis instance, or other services, add `services` to the workflow definition using Docker containers. Verify specific service configuration against the GitHub Actions documentation for your target versions.]

---

### Common Configuration Errors

**`Cannot find module 'fastify'`**

Occurs when `moduleFileExtensions` does not include `js` or when `tsconfig.test.json` paths are misconfigured. Confirm `moduleFileExtensions: ['ts', 'js', 'json']` is set.

**`SyntaxError: Cannot use import statement`**

A pure-ESM dependency is being processed by Jest's CommonJS transform. Either configure ESM mode or find a CommonJS-compatible version of the dependency.

**`Your test suite must contain at least one test`**

Jest found a file matching `testMatch` that contains no `test()` or `it()` calls. Common cause: a test helper file placed in the `tests/` directory without being excluded from `testMatch`.

**`TypeError: app.inject is not a function`**

`@fastify/swagger` or another plugin failed to register, leaving the app instance in a broken state. Check for errors thrown during `app.ready()` — wrap in try/catch during debugging.

**ts-jest version mismatch warning**

```
ts-jest[config] (WARN) Message: Version X of jest is not supported...
```

Upgrade `ts-jest` and `jest` together. [Unverified: consult the `ts-jest` support table for the current compatibility matrix.]

---

**Related Topics**
- Setting up Vitest as a Jest alternative for Fastify projects
- Structuring the `buildApp` factory for dependency injection in tests
- Using Jest `--projects` for monorepo Fastify setups
- Mocking Fastify decorators and plugins with `jest.mock()`
- Database test isolation strategies — transactions and test containers
- Generating and enforcing OpenAPI contract tests in CI with Jest