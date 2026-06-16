## Monorepo Plugin Management

A monorepo consolidates multiple Fastify plugin packages and the applications that consume them into a single version-controlled repository. This structure enables atomic cross-package changes, shared tooling, and consistent dependency management — but introduces its own coordination challenges around workspace linking, build pipelines, versioning, and plugin interdependencies.

---

### Workspace Tooling Overview

The three dominant workspace managers used with Node.js monorepos each handle Fastify plugin packages differently at the linking and hoisting level.

| Tool | Workspace Config | Hoisting Default | Hardlinks |
|---|---|---|---|
| npm workspaces | `package.json` `workspaces` | Yes | No |
| pnpm workspaces | `pnpm-workspace.yaml` | No (isolated) | Yes (content-addressable) |
| Yarn Berry | `package.json` `workspaces` | Configurable (PnP or node-modules) | No |

**Key Points:**
- pnpm's non-hoisting model most closely matches what plugins will see in production (isolated `node_modules`), reducing "works in monorepo, breaks in prod" issues
- npm hoisting can cause a plugin's `require('fastify')` to resolve to the root `node_modules` version rather than the one declared in the plugin's own `package.json` — [Inference] this may mask version mismatches that only appear when the plugin is published and consumed independently

---

### Repository Layout

#### Application + Plugin Packages

```
monorepo-root/
├── package.json                  ← root workspace manifest
├── pnpm-workspace.yaml           ← (pnpm only)
├── turbo.json                    ← (if using Turborepo)
├── packages/
│   ├── plugin-auth/
│   │   ├── index.js
│   │   ├── package.json
│   │   └── test/
│   ├── plugin-db/
│   │   ├── index.js
│   │   ├── package.json
│   │   └── test/
│   ├── plugin-cache/
│   │   ├── index.js
│   │   ├── package.json
│   │   └── test/
│   └── shared-schemas/
│       ├── index.js
│       └── package.json
├── apps/
│   ├── api-gateway/
│   │   ├── app.js
│   │   └── package.json
│   └── admin-service/
│       ├── app.js
│       └── package.json
└── tooling/
    ├── eslint-config/
    └── jest-config/
```

**Key Points:**
- `packages/` holds publishable or shareable plugin units
- `apps/` holds consuming Fastify applications
- `tooling/` holds shared configuration packages (lint, test, build)
- This separation makes it unambiguous which packages are infrastructure vs. runnable services

---

### Workspace Configuration

#### npm workspaces (`package.json`)

```json
{
  "name": "my-monorepo",
  "private": true,
  "workspaces": [
    "packages/*",
    "apps/*",
    "tooling/*"
  ]
}
```

#### pnpm workspaces (`pnpm-workspace.yaml`)

```yaml
packages:
  - 'packages/*'
  - 'apps/*'
  - 'tooling/*'
```

#### Workspace Plugin `package.json`

```json
{
  "name": "@myorg/plugin-db",
  "version": "1.4.0",
  "main": "index.js",
  "private": false,
  "peerDependencies": {
    "fastify": "^4.0.0"
  },
  "devDependencies": {
    "fastify": "^4.26.0"
  },
  "dependencies": {
    "fastify-plugin": "^4.5.0",
    "pg": "^8.11.0"
  }
}
```

**Key Points:**
- `fastify` is a `peerDependency` so consuming apps supply their own version; `devDependencies` provides it for local testing
- `private: false` marks the package as publishable if a private registry is in use; set `private: true` for packages that should never leave the monorepo

---

### Consuming Workspace Packages in Apps

Workspace packages are referenced by their `name` field using the workspace protocol, not by file path.

#### pnpm

```json
{
  "name": "@myorg/api-gateway",
  "dependencies": {
    "@myorg/plugin-db": "workspace:*",
    "@myorg/plugin-auth": "workspace:*",
    "@myorg/plugin-cache": "workspace:*"
  }
}
```

#### npm / Yarn

```json
{
  "dependencies": {
    "@myorg/plugin-db": "*"
  }
}
```

**Key Points:**
- `workspace:*` (pnpm) resolves to the local package and pins to the current workspace version at publish time
- npm workspace linking uses symlinks in `node_modules`; the consuming app `require('@myorg/plugin-db')` resolves to `packages/plugin-db/index.js`
- [Inference] Because workspace linking is symlink-based in npm/Yarn, `require.resolve` paths may differ from what the plugin sees when installed from a registry — test both locally and via a published tarball when correctness of resolution matters

---

### Plugin Package Anatomy in a Monorepo

Each plugin package should be self-contained with its own tests, README, and changelog.

```
packages/plugin-auth/
├── index.js
├── lib/
│   ├── verify-token.js
│   └── extract-claims.js
├── test/
│   └── auth.test.js
├── CHANGELOG.md
├── README.md
└── package.json
```

```js
// packages/plugin-auth/index.js
'use strict'

const fp = require('fastify-plugin')

async function authPlugin(fastify, opts) {
  const { secret, issuer = 'myorg' } = opts

  if (!secret) throw new Error('[@myorg/plugin-auth] secret is required')

  fastify.decorate('authenticate', async function (request, reply) {
    try {
      await request.jwtVerify()
    } catch (err) {
      reply.send(err)
    }
  })
}

module.exports = fp(authPlugin, {
  name: '@myorg/plugin-auth',
  fastify: '4.x',
  dependencies: ['@fastify/jwt'],
})
```

**Key Points:**
- Use the full scoped package name as the `fp` `name` field — this makes dependency declarations across packages unambiguous
- Keep business logic in `lib/` subdirectories, keeping `index.js` as a thin registration wrapper

---

### Inter-Plugin Dependencies Within the Monorepo

When one workspace plugin depends on another, declare it explicitly in both `package.json` and `fp` metadata.

```json
// packages/plugin-auth/package.json
{
  "name": "@myorg/plugin-auth",
  "dependencies": {
    "@myorg/plugin-db": "workspace:*",
    "fastify-plugin": "^4.5.0"
  }
}
```

```js
// packages/plugin-auth/index.js
module.exports = fp(authPlugin, {
  name: '@myorg/plugin-auth',
  fastify: '4.x',
  dependencies: ['@myorg/plugin-db'],
})
```

```mermaid
graph LR
  A[@myorg/plugin-db] --> B[@myorg/plugin-auth]
  A --> C[@myorg/plugin-cache]
  B --> D[api-gateway app]
  C --> D
  A --> D
```

**Key Points:**
- The `package.json` dependency ensures the workspace linker resolves the package
- The `fp` `dependencies` array ensures Fastify's runtime loader enforces registration order
- Both declarations are necessary; one handles module resolution, the other handles plugin boot order

---

### Shared Utilities and Non-Plugin Packages

Not all monorepo packages need to be Fastify plugins. Utility packages can be plain Node.js modules:

```
packages/shared-errors/
├── index.js        ← exports custom error classes
└── package.json

packages/shared-schemas/
├── index.js        ← exports raw JSON Schema objects
└── package.json
```

```js
// packages/shared-schemas/index.js
'use strict'

module.exports = {
  paginationSchema: require('./schemas/pagination.json'),
  errorSchema: require('./schemas/error.json'),
  userSchema: require('./schemas/user.json'),
}
```

Consumed in a plugin:

```js
const { paginationSchema } = require('@myorg/shared-schemas')

async function plugin(fastify, opts) {
  fastify.addSchema({ $id: 'pagination', ...paginationSchema })
}
```

**Key Points:**
- Separating raw schema objects from their Fastify registration logic allows schemas to be reused in non-Fastify contexts (validation scripts, documentation generators)
- Utility packages should have no `fastify` peer dependency

---

### Build Pipeline with Turborepo

For monorepos where plugins require a build step (TypeScript compilation, bundling), Turborepo provides task orchestration with caching.

```json
// turbo.json
{
  "$schema": "https://turbo.build/schema.json",
  "pipeline": {
    "build": {
      "dependsOn": ["^build"],
      "outputs": ["dist/**"]
    },
    "test": {
      "dependsOn": ["^build"],
      "outputs": []
    },
    "lint": {
      "outputs": []
    }
  }
}
```

**Key Points:**
- `"dependsOn": ["^build"]` means a package's build task waits for all its dependency packages' build tasks to complete first
- This mirrors the Fastify plugin dependency graph at the build level
- Turborepo caches task outputs; unchanged packages skip re-execution on subsequent runs
- [Inference] Build caching is based on file hashing; tasks that have side effects outside tracked outputs may produce stale cache hits — review `outputs` declarations carefully

#### Task Execution

```bash
# Build all packages in dependency order
pnpm turbo build

# Test only packages affected by recent changes
pnpm turbo test --filter=...[HEAD^1]

# Run tests for a specific package and its dependents
pnpm turbo test --filter=@myorg/plugin-db...
```

---

### Versioning Strategies

#### Fixed / Lockstep Versioning

All packages share the same version number, bumped together on every release.

```
@myorg/plugin-db@2.1.0
@myorg/plugin-auth@2.1.0
@myorg/plugin-cache@2.1.0
```

- Simpler to reason about; consumers always use matching versions
- Every package is published even if only one changed

#### Independent Versioning

Each package is versioned independently based on its own change history.

```
@myorg/plugin-db@3.0.0
@myorg/plugin-auth@1.4.2
@myorg/plugin-cache@2.0.1
```

- More precise; consumers only update what changed
- Requires tracking compatibility between interdependent packages

#### Changesets (Recommended for Independent Versioning)

`@changesets/cli` is the standard tool for managing independent versioning in monorepos.

```bash
# Install
pnpm add -DW @changesets/cli
pnpm changeset init

# Developer adds a changeset when making a change
pnpm changeset
# → prompts: which packages changed? major/minor/patch? summary?

# CI/release pipeline applies changesets and bumps versions
pnpm changeset version

# Publish all changed packages
pnpm changeset publish
```

A changeset file (auto-generated in `.changesets/`):

```md
---
"@myorg/plugin-db": minor
"@myorg/plugin-auth": patch
---

plugin-db: add support for `poolSize` option
plugin-auth: fix token expiry edge case
```

**Key Points:**
- Changesets decouple the act of describing a change (at PR time) from the act of releasing (at merge/CI time)
- The `version` command aggregates all pending changesets into `CHANGELOG.md` updates and `package.json` version bumps
- The `publish` command runs `npm publish` (or equivalent) for all packages whose version changed

---

### Testing Across the Monorepo

#### Per-Package Tests

Each plugin package runs its own tests in isolation:

```bash
pnpm --filter @myorg/plugin-db test
```

#### Integration Tests in the App

The consuming application tests end-to-end behavior with all plugins composed:

```js
// apps/api-gateway/test/integration.test.js
const { test } = require('node:test')
const assert = require('node:assert')
const buildApp = require('../app')

test('GET /users returns 200 with db and auth plugins loaded', async (t) => {
  const app = await buildApp({
    db: { connectionString: process.env.TEST_DB_URL },
    auth: { secret: 'test-secret' },
  })

  const res = await app.inject({
    method: 'GET',
    url: '/users',
    headers: { authorization: 'Bearer test-token' },
  })

  assert.strictEqual(res.statusCode, 200)
  await app.close()
})
```

#### Cross-Package Test Filtering with Turborepo

```bash
# Run all tests, but only re-run packages affected since last commit
pnpm turbo test --filter=...[HEAD^1]
```

---

### Publishing to a Private Registry

For organizations that want plugins installable via npm without exposing them publicly:

#### Verdaccio (self-hosted)

```bash
# .npmrc in monorepo root
@myorg:registry=https://verdaccio.internal.myorg.com
```

```bash
pnpm changeset publish
# → publishes @myorg/* to the private registry
```

#### GitHub Packages

```json
// package.json
{
  "publishConfig": {
    "registry": "https://npm.pkg.github.com"
  }
}
```

```bash
# .npmrc
@myorg:registry=https://npm.pkg.github.com
//npm.pkg.github.com/:_authToken=${GITHUB_TOKEN}
```

**Key Points:**
- Scoped packages (`@myorg/`) make registry routing straightforward — only `@myorg/` packages resolve to the private registry
- Consuming services outside the monorepo install plugins as normal npm dependencies once a registry is configured
- [Inference] Registry authentication tokens should be injected via environment variables in CI, never committed to `.npmrc` files in version control

---

### Common Pitfalls

**Fastify version divergence:** If `apps/api-gateway` uses Fastify `4.26.0` and a plugin declares `fastify: '>=4.28.0'`, registration will fail. Enforce a consistent Fastify version at the root using a `resolutions` or `overrides` field:

```json
// root package.json (pnpm)
{
  "pnpm": {
    "overrides": {
      "fastify": "4.26.2"
    }
  }
}
```

**Symlink-related `instanceof` failures:** When a plugin and app resolve `fastify` from different `node_modules` locations (e.g., due to hoisting differences), Fastify internals that use `instanceof` checks [Inference] may fail. Forcing a single resolved version via overrides addresses this.

**Missing `onClose` in test teardown:** In monorepo integration tests, leaked connections across test files can cause the test runner to hang indefinitely. Always `await app.close()` in teardown.

**Changeset discipline breakdown:** If developers forget to add changesets, version bumps accumulate without changelogs. [Inference] Enforcing changeset presence via a CI status check on PRs mitigates this — behavior depends on CI configuration.

---

**Related Topics:**
- Building internal plugin libraries — structure, barrel exports, options validation
- Plugin versioning and compatibility — `fp` metadata, semver enforcement
- `@fastify/autoload` — filesystem-based plugin discovery within an app
- TypeScript configuration in monorepos — `tsconfig` project references for plugin packages
- CI/CD pipeline design for monorepos — affected package detection, publish gates
- Turborepo remote caching — sharing build/test cache across CI runners