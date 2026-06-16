## Generating Projects and Plugins

`fastify-cli` provides two scaffolding commands — `fastify generate` and `fastify generate-plugin` — that produce opinionated, ready-to-run project structures. Understanding what is generated, why each file exists, and how to extend the scaffold is essential for working effectively within the Fastify ecosystem.

---

### `fastify generate` — Full Project Scaffold

Creates a complete application project with routing, plugin support, and testing infrastructure.

```bash
fastify generate my-app
cd my-app
npm install
npm start
```

**Available flags:**

| Flag | Value | Description |
|---|---|---|
| `--lang` | `js` \| `ts` | Output language (default: `js`) |
| `--esm` | — | Use ES module syntax (`import`/`export`) |
| `--standardx` | — | Add StandardX linting configuration |

---

### Generated Project Structure (JavaScript)

```
my-app/
├── app.js
├── package.json
├── README.md
├── plugins/
│   ├── sensible.js
│   └── support.js
├── routes/
│   ├── example/
│   │   └── index.js
│   └── root.js
└── test/
    ├── helper.js
    └── routes/
        ├── example.test.js
        └── root.test.js
```

---

### File-by-File Breakdown

#### `app.js` — Root Plugin

The application entry point. Exported as a Fastify plugin function and loaded by `fastify-cli`.

```js
'use strict'

const path = require('path')
const AutoLoad = require('@fastify/autoload')

module.exports = async function (fastify, opts) {
  // Load all plugins in /plugins
  fastify.register(AutoLoad, {
    dir: path.join(__dirname, 'plugins'),
    options: Object.assign({}, opts)
  })

  // Load all routes in /routes
  fastify.register(AutoLoad, {
    dir: path.join(__dirname, 'routes'),
    options: Object.assign({}, opts)
  })
}

module.exports.options = {
  // Default Fastify instance options
}
```

**Key Points:**
- `@fastify/autoload` discovers and registers all files in the specified directories automatically.
- Plugins are registered before routes, making plugin decorators and hooks available to all routes.
- `module.exports.options` is the standard way to pass Fastify instance configuration through `fastify-cli`.

---

#### `plugins/sensible.js` — `@fastify/sensible` Integration

```js
'use strict'

const fp = require('fastify-plugin')
const sensible = require('@fastify/sensible')

module.exports = fp(async function (fastify, opts) {
  fastify.register(sensible)
})
```

`@fastify/sensible` adds useful utilities and HTTP error helpers (e.g., `fastify.httpErrors.notFound()`). Wrapping it with `fastify-plugin` (`fp`) breaks encapsulation so these utilities are available throughout the entire application.

---

#### `plugins/support.js` — Custom Shared Logic

A placeholder for application-level decorators and shared functionality:

```js
'use strict'

const fp = require('fastify-plugin')

module.exports = fp(async function (fastify, opts) {
  // Add shared decorators, hooks, or utilities here
  fastify.decorate('someUtility', () => {})
})
```

Anything registered here with `fp` is accessible to all routes and nested plugins.

---

#### `routes/root.js` — Root Route

```js
'use strict'

module.exports = async function (fastify, opts) {
  fastify.get('/', async function (request, reply) {
    return { root: true }
  })
}
```

Route files do not use `fastify-plugin`. This preserves encapsulation — hooks and decorators added inside a route file are scoped to that file only.

---

#### `routes/example/index.js` — Nested Route Example

Demonstrates `@fastify/autoload`'s directory-based prefix inference:

```js
'use strict'

module.exports = async function (fastify, opts) {
  fastify.get('/', async function (request, reply) {
    return 'this is an example'
  })
}
```

Because this file lives in `routes/example/`, autoload mounts it under `/example` by default. The route responds at `GET /example`.

---

#### `test/helper.js` — Test Helper

Builds a configured Fastify instance for use in tests:

```js
'use strict'

const { build: buildHelper } = require('fastify-cli/helper')
const AppPath = require.resolve('../app')

function config () {
  return {}
}

async function build (t) {
  const app = await buildHelper([AppPath], { ...config() })
  t.teardown(app.close.bind(app))
  return app
}

module.exports = { build, config }
```

**Key Points:**
- Uses `fastify-cli/helper` to instantiate the app the same way `fastify start` does.
- Keeps test setup DRY — all test files import from this helper.
- `t.teardown` registers cleanup so the server closes after each test.

---

#### `test/routes/root.test.js` — Route Test

```js
'use strict'

const { test } = require('node:test')
const { build } = require('../helper')

test('root route', async (t) => {
  const app = await build(t)
  const res = await app.inject({
    method: 'GET',
    url: '/'
  })
  t.assert.deepEqual(JSON.parse(res.payload), { root: true })
})
```

Uses `app.inject()` for in-process HTTP simulation — no network required.

---

### Generated Project Structure (TypeScript)

```bash
fastify generate my-app --lang=ts
```

```
my-app/
├── src/
│   ├── app.ts
│   ├── plugins/
│   │   ├── sensible.ts
│   │   └── support.ts
│   └── routes/
│       ├── example/
│       │   └── index.ts
│       └── root.ts
├── test/
│   ├── helper.ts
│   └── routes/
│       ├── example.test.ts
│       └── root.test.ts
├── tsconfig.json
└── package.json
```

Source files live under `src/`. The `tsconfig.json` targets `dist/` as the output directory.

**`app.ts` entry:**

```ts
import { join } from 'path'
import AutoLoad, { AutoloadPluginOptions } from '@fastify/autoload'
import { FastifyPluginAsync } from 'fastify'

const app: FastifyPluginAsync = async (fastify, opts): Promise<void> => {
  fastify.register(AutoLoad, {
    dir: join(__dirname, 'plugins'),
    options: opts as AutoloadPluginOptions
  })

  fastify.register(AutoLoad, {
    dir: join(__dirname, 'routes'),
    options: opts as AutoloadPluginOptions
  })
}

export default app
export { app }
```

**Build and run:**

```bash
npm run build       # tsc → dist/
npm start           # fastify start dist/app.js
```

---

### ES Module Scaffold

```bash
fastify generate my-app --esm
```

Produces files using `import`/`export` syntax:

```js
// app.js
import { join, dirname } from 'path'
import { fileURLToPath } from 'url'
import AutoLoad from '@fastify/autoload'

const __filename = fileURLToPath(import.meta.url)
const __dirname = dirname(__filename)

export default async function (fastify, opts) {
  fastify.register(AutoLoad, {
    dir: join(__dirname, 'plugins'),
    options: Object.assign({}, opts)
  })

  fastify.register(AutoLoad, {
    dir: join(__dirname, 'routes'),
    options: Object.assign({}, opts)
  })
}
```

`package.json` will include `"type": "module"` to enable native ESM resolution.

> [Inference] ESM interoperability with CommonJS plugins may require attention — not all third-party Fastify plugins publish ESM-compatible builds. Verify compatibility before adopting ESM scaffolding.

---

### `fastify generate-plugin` — Standalone Plugin Scaffold

Scaffolds a reusable plugin package, suitable for npm publication or monorepo sharing.

```bash
fastify generate-plugin my-plugin
cd my-plugin
npm install
```

**Generated structure:**

```
my-plugin/
├── index.js
├── package.json
├── README.md
└── test/
    └── index.test.js
```

---

#### `index.js` — Plugin Entry

```js
'use strict'

const fp = require('fastify-plugin')

async function myPlugin (fastify, options) {
  // Register decorators, hooks, or sub-plugins here
  fastify.decorate('myPlugin', () => 'hello from myPlugin')
}

module.exports = fp(myPlugin, {
  fastify: '4.x',          // Peer version constraint
  name: 'my-plugin'        // Plugin identity for dependency checks
})
```

**Key Points:**
- Wrapping with `fp` is the standard for distributable plugins — it breaks encapsulation so consumers receive the plugin's decorators and hooks in their scope.
- The `fastify` version constraint in `fp(fn, meta)` causes Fastify to throw at registration time if the version is incompatible — a useful safeguard.
- The `name` field enables `fastify-plugin`'s dependency graph checks.

---

#### `test/index.test.js` — Plugin Test

```js
'use strict'

const { test } = require('node:test')
const Fastify = require('fastify')
const myPlugin = require('../index')

test('myPlugin registers decorator', async (t) => {
  const app = Fastify()
  app.register(myPlugin)
  await app.ready()

  t.assert.ok(app.myPlugin)
  t.assert.equal(app.myPlugin(), 'hello from myPlugin')
})
```

The test instantiates a bare Fastify instance, registers the plugin, calls `app.ready()` to await initialization, then asserts on behavior.

---

### Extending the Generated Scaffold

#### Adding a New Route File

Create a file inside `routes/`. `@fastify/autoload` picks it up automatically on restart:

```js
// routes/users.js
'use strict'

module.exports = async function (fastify, opts) {
  fastify.get('/', async (req, reply) => {
    return { users: [] }
  })

  fastify.post('/', async (req, reply) => {
    return reply.code(201).send({ created: true })
  })
}
```

This registers `GET /users` and `POST /users`.

#### Adding a Shared Plugin

Create a file inside `plugins/` and wrap it with `fp`:

```js
// plugins/db.js
'use strict'

const fp = require('fastify-plugin')

module.exports = fp(async function (fastify, opts) {
  // Simulate DB connection
  const db = { query: async (sql) => [] }
  fastify.decorate('db', db)
  fastify.addHook('onClose', async () => {
    // teardown logic
  })
}, { name: 'db-plugin' })
```

All route handlers can now access `fastify.db`.

---

### `@fastify/autoload` Route Prefix Inference

Autoload derives URL prefixes from directory structure:

```
routes/
├── root.js          → /
├── users.js         → /users
├── users/
│   └── index.js     → /users
├── admin/
│   ├── index.js     → /admin
│   └── reports.js   → /admin/reports
```

> [Inference] When both `users.js` and `users/index.js` exist, load order and conflict behavior depends on `@fastify/autoload` version. Avoid ambiguous structures and verify with `fastify print-routes`.

You can override the inferred prefix with autoload's `dirNameRoutePrefix` or per-file `autoPrefix` options:

```js
// routes/legacy/index.js
module.exports = async function (fastify, opts) {
  fastify.get('/old-path', async () => ({ legacy: true }))
}
module.exports.autoPrefix = '/v0'  // Override inferred prefix
```

---

### `package.json` Scripts in Generated Projects

```json
{
  "scripts": {
    "test": "node --test test/**/*.test.js",
    "start": "fastify start -l info app.js",
    "dev": "fastify start -l info -w -P app.js",
    "build": "tsc"
  }
}
```

> [Inference] The exact scripts generated may differ across `fastify-cli` versions. Review the generated `package.json` directly after scaffolding.

---

**Related Topics:**
- `@fastify/autoload` — configuration options, prefix inference, and `ignorePattern`
- `fastify-plugin` (`fp`) — encapsulation mechanics and plugin metadata
- `@fastify/sensible` — available HTTP error helpers and utilities
- Fastify plugin system and encapsulation model
- Testing Fastify applications with `node:test` and `app.inject()`
- Monorepo plugin sharing patterns
- Migrating from generated scaffold to a custom project structure