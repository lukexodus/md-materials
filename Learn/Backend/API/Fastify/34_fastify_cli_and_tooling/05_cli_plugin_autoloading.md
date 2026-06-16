## CLI Plugin Auto-Loading

`@fastify/autoload` is the mechanism by which `fastify-cli`-generated projects automatically discover and register plugins and routes from the filesystem without explicit `fastify.register()` calls per file. Understanding how autoload resolves files, infers prefixes, controls load order, and handles edge cases is essential for working effectively within the generated project structure — and for extending it safely.

---

### What Auto-Loading Does

Without autoload, every plugin and route must be manually registered:

```js
// Without autoload — explicit registration
fastify.register(require('./plugins/env'))
fastify.register(require('./plugins/db'))
fastify.register(require('./routes/users'))
fastify.register(require('./routes/admin'))
```

With autoload, an entire directory is registered in one call:

```js
const AutoLoad = require('@fastify/autoload')
const path = require('path')

fastify.register(AutoLoad, {
  dir: path.join(__dirname, 'plugins')
})

fastify.register(AutoLoad, {
  dir: path.join(__dirname, 'routes')
})
```

Every eligible file in the directory is discovered, required, and registered as a Fastify plugin automatically.

---

### Installation

`@fastify/autoload` is included in projects scaffolded by `fastify generate`. For manual installation:

```bash
npm install @fastify/autoload
```

---

### Basic Configuration Options

```js
fastify.register(AutoLoad, {
  dir: path.join(__dirname, 'routes'),  // Required: directory to scan
  options: { prefix: '/api' },          // Passed as opts to every loaded plugin
  ignorePattern: /\.test\.js$/,         // Regex: skip matching filenames
  matchFilter: /\.route\.js$/,          // Regex or fn: only load matching files
  maxDepth: 2,                          // Limit recursive directory depth
  dirNameRoutePrefix: true,             // Use directory names as route prefixes
  autoHooksPattern: /^_hooks\.(js|ts)$/, // Pattern for auto-hook files
  forceESM: false,                      // Force ES module loading
  indexPattern: /^index\.(js|ts)$/      // Pattern identifying index files
})
```

> [Unverified] Option availability and default values may differ across `@fastify/autoload` versions. Verify with your installed version's documentation.

---

### File Discovery and Eligibility

Autoload performs a recursive scan of the target directory. A file is loaded if:

- It ends in `.js`, `.ts`, `.mjs`, `.cjs` (exact extensions may vary by version)
- It is not excluded by `ignorePattern`
- It matches `matchFilter` if that option is set
- It exports a valid Fastify plugin function

Files and directories beginning with `-` are ignored by convention. [Inference] This is a `@fastify/autoload`-specific convention, not a Node.js or filesystem convention.

**Skipping a file explicitly:**

Prefix the filename with `-` to prevent autoload from loading it:

```
routes/
├── users.js          ← loaded
├── -helpers.js       ← skipped
└── admin/
    └── index.js      ← loaded
```

---

### Directory Structure and Prefix Inference

When loading routes, autoload infers URL prefixes from the directory hierarchy. The root directory passed to autoload maps to `/`.

```
routes/
├── root.js              → /
├── users.js             → /users
├── products/
│   ├── index.js         → /products
│   └── reviews.js       → /products/reviews
└── admin/
    ├── index.js         → /admin
    └── reports/
        └── index.js     → /admin/reports
```

This behavior is controlled by the `dirNameRoutePrefix` option (defaults to `true`). When `false`, directory names do not contribute to the prefix and all files are mounted without path offset.

---

### `index.js` Files

A file matching `indexPattern` (default: `index.js` or `index.ts`) inside a directory is treated as the handler for that directory's prefix, not a sub-route named `index`:

```
routes/
└── users/
    ├── index.js     → /users       (not /users/index)
    └── profile.js   → /users/profile
```

This mirrors conventional web server behavior.

---

### Per-File Prefix Override with `autoPrefix`

Override the inferred prefix for a specific route file by exporting `autoPrefix`:

```js
// routes/legacy/index.js
async function routes (fastify, opts) {
  fastify.get('/old-endpoint', async () => ({ legacy: true }))
}

module.exports = routes
module.exports.autoPrefix = '/v0'   // Mounted at /v0, not /legacy
```

---

### Disabling Prefix for a Specific File

Set `autoPrefix` to an empty string to mount a route file at the root regardless of its directory position:

```js
module.exports = routes
module.exports.autoPrefix = ''
```

> [Inference] This may cause route conflicts if other files also mount at `/`. Use with care and verify with `fastify print-routes`.

---

### `prefixOverride` Option

Apply a single prefix to all files loaded from a directory, overriding directory-derived prefixes entirely:

```js
fastify.register(AutoLoad, {
  dir: path.join(__dirname, 'routes'),
  prefixOverride: '/api/v2'
})
```

All routes in the directory are mounted under `/api/v2`, regardless of their subdirectory structure.

---

### Load Order

Within a single directory, autoload loads files in **alphabetical order** by filename. Subdirectories are processed after files at the same level.

> [Inference] Exact traversal order may vary across operating systems (e.g., case sensitivity differences on Linux vs. macOS) and `@fastify/autoload` versions. Treat alphabetical order as the general expectation but verify when order is critical.

**Controlling load order with filename prefixes:**

```
plugins/
├── 00-env.js       ← loads first
├── 01-db.js        ← loads second, can access fastify.config
├── 02-auth.js      ← loads third, can access fastify.db
└── support.js      ← loads after numeric-prefixed files
```

This is a common pattern for plugins with inter-dependencies. Numeric prefixes sort reliably because `0` precedes letters in ASCII order.

---

### Plugin vs. Route Directory Conventions

The generated project uses two separate autoload calls — one for `plugins/` and one for `routes/`. The distinction is semantic and enforced by convention:

| Directory | Uses `fastify-plugin` (`fp`)? | Encapsulation | Purpose |
|---|---|---|---|
| `plugins/` | Yes | Broken — scope leaks upward | Shared decorators, hooks, connections |
| `routes/` | No | Preserved — scope is local | Route handlers |

Autoload does not enforce this distinction mechanically — it simply loads whatever is in each directory. The convention is maintained by the developer.

---

### Passing Options to All Loaded Plugins

The `options` key in the autoload config is passed as the `opts` argument to every plugin loaded from that directory:

```js
fastify.register(AutoLoad, {
  dir: path.join(__dirname, 'routes'),
  options: {
    prefix: '/api',
    logLevel: 'warn'
  }
})
```

Each route plugin receives these as its second argument:

```js
// routes/users.js
async function routes (fastify, opts) {
  console.log(opts.prefix)    // '/api'
  console.log(opts.logLevel)  // 'warn'

  fastify.get('/users', async () => [])
}
module.exports = routes
```

> **Note:** The `prefix` key in `options` is additive to the directory-derived prefix when `dirNameRoutePrefix` is `true`. [Inference] This can result in double-prefixing if not accounted for — verify the combined prefix with `fastify print-routes`.

---

### `ignorePattern` — Excluding Files

Use a regular expression to skip files matching a pattern:

```js
fastify.register(AutoLoad, {
  dir: path.join(__dirname, 'routes'),
  ignorePattern: /\.(test|spec)\.(js|ts)$/
})
```

Skips any file ending in `.test.js`, `.spec.js`, `.test.ts`, or `.spec.ts`.

Common patterns:

```js
// Skip test files
ignorePattern: /\.(test|spec)\.(js|ts)$/

// Skip TypeScript declaration files
ignorePattern: /\.d\.ts$/

// Skip files with underscore prefix
ignorePattern: /^_/
```

---

### `matchFilter` — Allowlist Loading

The inverse of `ignorePattern` — only load files matching the filter:

```js
fastify.register(AutoLoad, {
  dir: path.join(__dirname, 'routes'),
  matchFilter: /\.route\.(js|ts)$/
})
```

Only files named `*.route.js` or `*.route.ts` are loaded. All other files are ignored.

`matchFilter` also accepts a function:

```js
matchFilter: (path) => {
  return path.includes('/v2/') || path.endsWith('.route.js')
}
```

---

### `maxDepth` — Limiting Recursion

Restrict how many directory levels autoload traverses:

```js
fastify.register(AutoLoad, {
  dir: path.join(__dirname, 'routes'),
  maxDepth: 1   // Only load files directly in routes/, not subdirectories
})
```

`maxDepth: 1` loads only the top level. `maxDepth: 2` includes one level of subdirectories. Default is unlimited recursion.

---

### Auto-Hooks with `autoHooks`

`@fastify/autoload` supports automatic hook files — files placed in a directory that register hooks scoped to that directory and its children.

Enable with:

```js
fastify.register(AutoLoad, {
  dir: path.join(__dirname, 'routes'),
  autoHooks: true,
  autoHooksPattern: /^_hooks\.(js|ts)$/  // Default pattern
})
```

**Structure:**

```
routes/
├── _hooks.js          ← hooks apply to all routes/ plugins
├── users/
│   ├── _hooks.js      ← hooks apply only to users/ plugins
│   └── index.js
└── admin/
    ├── _hooks.js      ← hooks apply only to admin/ plugins
    └── index.js
```

**Example hook file:**

```js
// routes/admin/_hooks.js
async function adminHooks (fastify, opts) {
  fastify.addHook('preHandler', async (req, reply) => {
    if (!req.user?.isAdmin) {
      return reply.code(403).send({ error: 'Forbidden' })
    }
  })
}

module.exports = adminHooks
```

> [Inference] Auto-hooks are scoped to the encapsulation context of their directory. Because route files do not use `fp`, hooks registered in `_hooks.js` apply within that scope and do not leak to parent contexts — though this behavior should be verified in your version.

---

### ES Module Support

For ESM projects (`"type": "module"` in `package.json`):

```js
// app.js (ESM)
import AutoLoad from '@fastify/autoload'
import { fileURLToPath } from 'url'
import { dirname, join } from 'path'

const __filename = fileURLToPath(import.meta.url)
const __dirname = dirname(__filename)

export default async function app (fastify, opts) {
  fastify.register(AutoLoad, {
    dir: join(__dirname, 'plugins'),
    forceESM: true
  })

  fastify.register(AutoLoad, {
    dir: join(__dirname, 'routes'),
    forceESM: true
  })
}
```

Route and plugin files use named or default exports:

```js
// routes/users.js (ESM)
export default async function routes (fastify, opts) {
  fastify.get('/users', async () => [])
}
```

> [Inference] ESM interoperability with CommonJS plugins may require care. Not all Fastify ecosystem packages publish dual CJS/ESM builds. Verify each dependency before adopting `forceESM`.

---

### TypeScript with Autoload

In TypeScript projects, autoload targets compiled output in `dist/`. The source structure mirrors the output:

```
src/
└── routes/
    └── users.ts        ← TypeScript source

dist/
└── routes/
    └── users.js        ← Compiled output, loaded by autoload
```

Autoload is configured against `dist/`:

```ts
// src/app.ts
import AutoLoad from '@fastify/autoload'
import { join } from 'path'

export default async function app (fastify: any, opts: any) {
  fastify.register(AutoLoad, {
    dir: join(__dirname, 'plugins')   // __dirname resolves to dist/
  })
  fastify.register(AutoLoad, {
    dir: join(__dirname, 'routes')
  })
}
```

---

### Diagnosing Autoload Issues

#### Verify Loaded Routes

```bash
fastify print-routes app.js
```

Shows all registered routes and their full paths. Use this to confirm prefix inference is working as expected.

#### Verify Plugin Tree

```bash
fastify print-plugins app.js
```

Shows the plugin registration tree, including the order in which autoload discovered and registered files.

#### Common Issues

| Symptom | Likely Cause |
|---|---|
| Route not found (404) | File not eligible, excluded by `ignorePattern`, or wrong prefix |
| Double prefix (e.g., `/users/users`) | `prefix` in `options` combined with `dirNameRoutePrefix` |
| Plugin decorator not available in route | Plugin not wrapped with `fp`, or loaded after the route |
| Wrong load order causing missing decorator | Alphabetical order not matching dependency order — use numeric filename prefixes |
| `index.js` route mounting at `/index` | `indexPattern` mismatch — verify the pattern matches your filename |

---

### Complete Example

```
my-app/
├── app.js
├── plugins/
│   ├── 00-env.js
│   ├── 01-db.js
│   └── 02-auth.js
└── routes/
    ├── _hooks.js          ← global request logging hook
    ├── root.js            → GET /
    ├── users/
    │   ├── _hooks.js      ← auth check for /users
    │   └── index.js       → GET /users, POST /users
    └── admin/
        ├── _hooks.js      ← admin role check
        └── reports/
            └── index.js   → GET /admin/reports
```

```js
// app.js
const path = require('path')
const AutoLoad = require('@fastify/autoload')

module.exports = async function (fastify, opts) {
  fastify.register(AutoLoad, {
    dir: path.join(__dirname, 'plugins'),
    options: opts
  })

  fastify.register(AutoLoad, {
    dir: path.join(__dirname, 'routes'),
    options: opts,
    autoHooks: true,
    ignorePattern: /\.(test|spec)\.(js|ts)$/
  })
}
```

---

**Related Topics:**
- `@fastify/autoload` full API reference and version changelog
- Fastify encapsulation model and plugin scoping
- `fastify-plugin` (`fp`) and when to break encapsulation
- `fastify print-routes` and `fastify print-plugins` for diagnostics
- Auto-hooks patterns for authentication and authorization
- Load order management in multi-plugin applications
- Migrating from manual `fastify.register` to autoload