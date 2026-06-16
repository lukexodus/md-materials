## Project Scaffolding with fastify-cli

### What fastify-cli Is

`fastify-cli` is the official command-line tool for the Fastify ecosystem. It provides commands for generating project scaffolding, running applications in development and production modes, and integrating with `@fastify/autoload` for filesystem-based plugin and route loading.

It is maintained under the Fastify GitHub organization at `github.com/fastify/fastify-cli`.

### Installing fastify-cli

**Globally:**

```bash
npm install --global fastify-cli
```

**Verify the installation:**

```bash
fastify --version
```

**Without global install using `npx`:**

```bash
npx fastify-cli generate my-app
```

[Inference: `npx` fetches the latest published version at the time of execution; if your project requires a specific version of `fastify-cli`, a global or local install with a pinned version is more predictable]

**As a local dev dependency:**

```bash
npm install --save-dev fastify-cli
```

When installed locally, invoke it through an npm script or `npx`:

```json
{
  "scripts": {
    "generate": "fastify generate"
  }
}
```

### Generating a New Project

```bash
fastify generate my-app
```

This scaffolds a new project in a `my-app/` directory.

**With TypeScript support:**

```bash
fastify generate my-app --lang=ts
```

**Key Points:**
- The `--lang=ts` flag generates TypeScript-configured scaffolding including `tsconfig.json` and TypeScript source files
- Without the flag, the project is scaffolded in plain JavaScript
- The generated project includes `@fastify/autoload` and `@fastify/sensible` as dependencies by default [Inference: default dependencies included by the generator may change across `fastify-cli` versions; verify against generated output]

### Generated Project Structure

After running `fastify generate my-app && cd my-app && npm install`, the directory structure is:

```
my-app/
├── app.js                  ← Root application plugin
├── server.js               ← Entry point — creates and starts the server
├── plugins/
│   ├── README.md
│   ├── sensible.js         ← @fastify/sensible registration
│   └── support.js          ← Example support plugin
├── routes/
│   ├── README.md
│   ├── root.js             ← Handler for GET /
│   └── example/
│       └── index.js        ← Example nested route
├── test/
│   ├── plugins/
│   │   └── support.test.js
│   └── routes/
│       ├── example.test.js
│       └── root.test.js
├── package.json
└── .gitignore
```

[Unverified: exact directory structure may differ across `fastify-cli` versions; the above reflects the general structure at the time of writing]

### Key Generated Files

#### `server.js`

The entry point. Instantiates Fastify and starts the HTTP server.

```js
'use strict'

const app = require('./app')
const port = process.env.PORT || 3000
const host = process.env.HOST || '127.0.0.1'

const start = async () => {
  try {
    await app.listen({ port, host })
  } catch (err) {
    app.log.error(err)
    process.exit(1)
  }
}

start()
```

#### `app.js`

The root application plugin. This is the Fastify instance that is registered with autoload and exported for testing.

```js
'use strict'

const path = require('path')
const AutoLoad = require('@fastify/autoload')

module.exports = async function (fastify, opts) {
  fastify.register(AutoLoad, {
    dir: path.join(__dirname, 'plugins'),
    options: Object.assign({}, opts)
  })

  fastify.register(AutoLoad, {
    dir: path.join(__dirname, 'routes'),
    options: Object.assign({}, opts)
  })
}
```

**Key Points:**
- `app.js` is itself a Fastify plugin — it receives `fastify` and `opts` and registers child plugins
- Exporting the application as a plugin rather than a running server is the pattern that enables `light-my-request`-based testing without starting a live server
- `@fastify/autoload` scans the `plugins/` and `routes/` directories and registers everything it finds automatically

#### A Generated Route File

```js
// routes/root.js
'use strict'

module.exports = async function (fastify, opts) {
  fastify.get('/', async function (request, reply) {
    return { root: true }
  })
}
```

Each file in `routes/` is a self-contained Fastify plugin exporting an async function.

#### A Generated Plugin File

```js
// plugins/support.js
'use strict'

const fp = require('fastify-plugin')

module.exports = fp(async function (fastify, opts) {
  fastify.decorate('someSupport', function () {
    return 'support'
  })
})
```

**Key Points:**
- Route files do **not** use `fastify-plugin` — encapsulation is desired so routes remain scoped
- Plugin files that add decorators or shared functionality **do** use `fastify-plugin` to escape encapsulation and make their additions available application-wide
- This distinction is a core convention of the scaffolded project structure

### `@fastify/autoload` Behavior

`@fastify/autoload` is what makes the filesystem-based structure work. It recursively loads all `.js` (or `.ts`) files from a specified directory and registers each as a Fastify plugin.

**Key Points:**
- Files are loaded in alphabetical order within each directory level [Inference: load order behavior should be verified against `@fastify/autoload` documentation if order-dependent registration is required]
- Subdirectories become route prefixes — a file at `routes/users/index.js` registers its routes under `/users`
- The `ignorePattern` option can exclude files from autoloading

**Example — subdirectory-based prefixing:**

```
routes/
├── root.js          → registers at /
└── users/
    └── index.js     → registers at /users
```

```js
// routes/users/index.js
module.exports = async function (fastify, opts) {
  fastify.get('/', async (request, reply) => {
    return { users: [] }
  })

  fastify.get('/:id', async (request, reply) => {
    return { id: request.params.id }
  })
}
```

This produces routes at `GET /users` and `GET /users/:id`.

### Running the Application

The generated `package.json` includes standard npm scripts:

```json
{
  "scripts": {
    "start": "fastify start app.js",
    "dev": "fastify start -w -l info -P app.js",
    "test": "node --test test/**/*.test.js"
  }
}
```

```bash
# Production start
npm start

# Development with watch mode
npm run dev
```

**`fastify start` flags used in the generated scripts:**

| Flag | Meaning |
|---|---|
| `-w` | Watch mode — restarts on file changes |
| `-l info` | Sets log level to `info` |
| `-P` | Pretty-prints log output (uses `pino-pretty`) |

[Inference: `pino-pretty` must be installed for the `-P` flag to work; the generator may include it as a dev dependency, but verify in the generated `package.json`]

### Testing the Scaffolded Application

Generated tests use Node.js's built-in `node:test` module and `light-my-request` via `fastify.inject()`:

```js
// test/routes/root.test.js
'use strict'

const { test } = require('node:test')
const { build } = require('../helper')

test('root route returns 200', async (t) => {
  const app = await build(t)

  const res = await app.inject({
    method: 'GET',
    url: '/'
  })

  t.assert.deepEqual(JSON.parse(res.payload), { root: true })
  t.assert.equal(res.statusCode, 200)
})
```

[Unverified: the exact test helper structure and assertion API may differ across `fastify-cli` versions; verify against generated test files]

### TypeScript Scaffolding

Running `fastify generate my-app --lang=ts` produces TypeScript equivalents of all generated files.

**Example generated TypeScript route:**

```ts
// routes/root.ts
import { FastifyPluginAsync } from 'fastify'

const root: FastifyPluginAsync = async (fastify, opts) => {
  fastify.get('/', async function (request, reply) {
    return { root: true }
  })
}

export default root
```

**Generated `tsconfig.json` (illustrative):**

```json
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "commonjs",
    "strict": true,
    "outDir": "dist"
  }
}
```

[Unverified: exact `tsconfig.json` contents vary across generator versions; review the generated file directly]

### Adding Routes and Plugins After Scaffolding

Because `@fastify/autoload` scans directories automatically, adding new routes and plugins requires only creating new files — no manual registration needed.

**Adding a new route:**

```bash
touch routes/items.js
```

```js
// routes/items.js
'use strict'

module.exports = async function (fastify, opts) {
  fastify.get('/', async (request, reply) => {
    return { items: [] }
  })
}
```

On next application start, `GET /items` is available automatically.

**Adding a new plugin:**

```bash
touch plugins/db.js
```

```js
// plugins/db.js
'use strict'

const fp = require('fastify-plugin')

module.exports = fp(async function (fastify, opts) {
  fastify.decorate('db', {
    query: async (sql) => { /* ... */ }
  })
})
```

### Practical Guidance

- Use `fastify generate` as the starting point for new projects rather than building the directory structure manually — the conventions it establishes (autoload, plugin/route separation, testable `app.js`) are well-aligned with Fastify's design
- Keep route files free of `fastify-plugin` — encapsulation of routes is intentional and prevents route leakage between scopes
- Keep shared decorators and hooks in `plugins/` wrapped with `fastify-plugin` so they are accessible throughout the application
- Commit the generated `.gitignore` — it excludes `node_modules` and other generated artifacts by default
- Verify the Node.js version and `fastify-cli` version compatibility before generating, as the scaffold output evolves alongside both