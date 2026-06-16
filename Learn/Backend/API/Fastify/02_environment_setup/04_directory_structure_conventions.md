## Directory Structure Conventions

A Fastify project does not enforce a single directory layout, but the community has converged on several conventions that reflect Fastify's plugin-based architecture. The structures described here represent common patterns; your actual layout may differ based on team preference, project size, or framework tooling used on top of Fastify.

---

### Why Structure Matters in Fastify

Fastify's core design is built around plugins and encapsulation. Directory structure in a Fastify project typically mirrors that plugin tree. Files are not just organizational — they often correspond directly to encapsulation boundaries, route scopes, and lifecycle hooks.

[Inference] Because Fastify encourages composing applications from plugins, a well-organized directory tends to produce a more maintainable encapsulation hierarchy. Behavior depends on implementation.

---

### Minimal Single-File Layout

For small projects, proofs of concept, or isolated services, a flat single-file structure is common:

```
project/
├── package.json
├── package-lock.json
├── .env
└── server.js
```

`server.js` (or `app.js`) contains the Fastify instance creation, plugin registration, and `listen()` call. This is sufficient for simple use cases but does not scale well as route count and complexity grow.

---

### Standard Multi-File Layout

A commonly used structure for small-to-medium projects:

```
project/
├── package.json
├── package-lock.json
├── .env
├── app.js
├── server.js
└── routes/
│   ├── index.js
│   └── users.js
└── plugins/
│   ├── db.js
│   └── auth.js
└── hooks/
│   └── onRequest.js
└── schemas/
│   └── user.js
└── test/
    └── routes/
        └── users.test.js
```

**Key Points**

- `server.js` — entry point; creates the Fastify instance and calls `listen()`
- `app.js` — builds and exports the application without starting the server; enables testing without binding a port
- `routes/` — each file is an autoloaded or manually registered plugin exporting route definitions
- `plugins/` — decorators, third-party integrations (databases, auth), and shared utilities registered as plugins
- `hooks/` — lifecycle hooks that may be extracted for clarity, though they are often co-located inside route or plugin files
- `schemas/` — JSON Schema objects for request/response validation, kept separate for reuse

---

### The `app.js` / `server.js` Split

This is one of the most consistent conventions in the Fastify ecosystem. Separating application construction from server startup allows the application to be imported in tests without side effects from `listen()`.

**Example** — `app.js`:

```js
const fastify = require('fastify')

async function buildApp(opts = {}) {
  const app = fastify(opts)

  await app.register(require('./plugins/db'))
  await app.register(require('./routes/users'), { prefix: '/users' })

  return app
}

module.exports = buildApp
```

**Example** — `server.js`:

```js
const buildApp = require('./app')

const start = async () => {
  const app = await buildApp({ logger: true })
  await app.listen({ port: 3000, host: '0.0.0.0' })
}

start()
```

This pattern is broadly used and recommended in official Fastify documentation.

---

### Fastify-CLI and `fastify-plugin` Conventions

When using `fastify-cli`, the expected layout differs slightly. The CLI expects a specific entry point shape:

```
project/
├── package.json
├── app.js            ← must export an async plugin function
├── plugins/
│   ├── sensible.js
│   └── support.js
├── routes/
│   ├── root.js
│   └── users/
│       └── index.js
└── test/
    ├── plugins/
    │   └── support.test.js
    └── routes/
        └── root.test.js
```

**Key Points**

- `app.js` exports a plugin function (not a factory), which `fastify-cli` wraps automatically
- Route files under `routes/` are autoloaded by `@fastify/autoload`
- Directory nesting under `routes/` maps to URL path prefixes [Inference — actual prefix behavior depends on autoload configuration]

---

### `@fastify/autoload` Directory Convention

`@fastify/autoload` is an official Fastify plugin that automatically loads all plugins found in a directory. When using it, file placement determines registration order and scope.

**Example**:

```js
const autoload = require('@fastify/autoload')
const path = require('path')

app.register(autoload, {
  dir: path.join(__dirname, 'plugins')
})

app.register(autoload, {
  dir: path.join(__dirname, 'routes'),
  options: { prefix: '/api' }
})
```

[Inference] Files in subdirectories under `routes/` are treated as nested route scopes when `routeParams` or `prefix` options are configured. Consult `@fastify/autoload` documentation for exact behavior, as it may vary by version.

---

### Schema Organization

Schemas are JSON Schema objects used for request validation and response serialization. They are commonly placed in one of three locations depending on project complexity:

| Pattern | Location | When to Use |
|---|---|---|
| Inline | Inside route file | Small projects, one-off schemas |
| Centralized | `schemas/` directory | Shared across multiple routes |
| Split by domain | `schemas/users.js`, `schemas/orders.js` | Larger projects with distinct domains |

Schemas extracted to a `schemas/` directory must be explicitly imported and registered or passed directly to route options. Fastify does not auto-discover schema files.

---

### Hooks Placement Convention

Hooks (`onRequest`, `preHandler`, `onSend`, etc.) can be:

- Registered globally on the root instance (in `app.js`)
- Registered within a plugin or route scope (in individual plugin or route files)
- Extracted to a `hooks/` directory and imported explicitly

[Inference] There is no universal community standard for a `hooks/` directory; it is a project-level choice. Co-locating hooks with the plugin or route they apply to is common in practice.

---

### Large-Scale Domain-Based Layout

For larger applications, a domain-driven structure groups all concerns (routes, schemas, hooks, services) by feature rather than by technical type:

```
project/
├── app.js
├── server.js
├── plugins/
│   ├── db.js
│   └── auth.js
├── modules/
│   ├── users/
│   │   ├── index.js       ← registers user routes as a plugin
│   │   ├── routes.js
│   │   ├── schema.js
│   │   └── service.js
│   └── orders/
│       ├── index.js
│       ├── routes.js
│       ├── schema.js
│       └── service.js
└── test/
    └── modules/
        └── users/
            └── users.test.js
```

**Key Points**

- Each module folder is self-contained and registered as a plugin via `index.js`
- `service.js` holds business logic, keeping route handlers thin
- Schemas and routes stay within the domain they belong to
- Global plugins (database connections, authentication) remain in a top-level `plugins/` directory

---

### Test Directory Conventions

Tests in Fastify projects mirror the source directory structure. The `app.js` / `server.js` split is particularly valuable here — tests import `buildApp()` and call `app.inject()` without starting an actual HTTP server.

```
test/
├── routes/
│   └── users.test.js
└── plugins/
    └── db.test.js
```

**Example** — route test using `inject`:

```js
const buildApp = require('../app')

test('GET /users returns 200', async (t) => {
  const app = await buildApp()
  const res = await app.inject({ method: 'GET', url: '/users' })
  t.equal(res.statusCode, 200)
  await app.close()
})
```

---

### Summary of Common Files and Their Roles

| File / Directory | Role |
|---|---|
| `server.js` | Entry point; starts the HTTP server |
| `app.js` | Builds and exports the Fastify application |
| `plugins/` | Decorators, integrations, shared utilities |
| `routes/` | Route definitions, grouped by resource or domain |
| `schemas/` | Shared JSON Schema objects |
| `hooks/` | Extracted lifecycle hooks (optional) |
| `modules/` | Domain-based grouping of routes, schemas, services |
| `test/` | Tests mirroring source structure |

---

**Conclusion**

No single directory layout is enforced by Fastify. The conventions above reflect community practice and the natural shape of Fastify's plugin architecture. The most consistent patterns are the `app.js`/`server.js` split, grouping routes and plugins into dedicated directories, and — in larger projects — organizing by domain rather than by technical layer. [Inference] Following these patterns is likely to improve maintainability and testability, but outcomes depend on consistent application across the codebase.