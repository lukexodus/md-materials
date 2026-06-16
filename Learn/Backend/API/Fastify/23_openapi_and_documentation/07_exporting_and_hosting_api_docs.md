## Exporting and Hosting API Docs

### Overview

Fastify's OpenAPI integration — typically provided by `@fastify/swagger` and `@fastify/swagger-ui` — supports multiple strategies for exporting the generated specification and serving interactive documentation to consumers. This document covers the full lifecycle: generating the spec at build time, serving it at runtime, hosting it externally, and securing access.

---

### How the Spec Is Generated

`@fastify/swagger` collects route schemas registered across the Fastify instance and compiles them into either an OpenAPI 3.x or Swagger 2.0 document. The spec is assembled lazily — it is not finalized until after all routes are registered and the server has been initialized.

**Key Points:**
- The spec is available only after `fastify.ready()` or `fastify.listen()` resolves.
- Route schemas use JSON Schema syntax, which `@fastify/swagger` converts to OpenAPI-compatible schema objects. [Inference: the conversion is not always lossless — some JSON Schema keywords have no OpenAPI equivalent and may be dropped or transformed.]
- The plugin exposes the compiled document via `fastify.swagger()`.

---

### Accessing the Spec Programmatically

After the server is ready, the full specification object is accessible in memory:

```typescript
import Fastify from 'fastify'
import swagger from '@fastify/swagger'

const fastify = Fastify()

await fastify.register(swagger, {
  openapi: {
    info: {
      title: 'My API',
      version: '1.0.0',
    },
  },
})

// Register your routes here...

await fastify.ready()

const spec = fastify.swagger()
console.log(JSON.stringify(spec, null, 2))
```

`fastify.swagger()` returns the spec as a plain JavaScript object. Passing `{ yaml: true }` returns a YAML string instead:

```typescript
const yamlSpec = fastify.swagger({ yaml: true })
```

---

### Exporting the Spec to a File

A common CI/contract-testing pattern is to generate the spec file at build time from a dedicated script, without starting a full HTTP server.

```typescript
// scripts/export-spec.ts
import Fastify from 'fastify'
import swagger from '@fastify/swagger'
import { writeFileSync } from 'fs'
import { registerRoutes } from '../src/routes'

async function exportSpec() {
  const fastify = Fastify()

  await fastify.register(swagger, {
    openapi: {
      info: { title: 'My API', version: '1.0.0' },
    },
  })

  await registerRoutes(fastify)
  await fastify.ready()

  const spec = fastify.swagger()
  writeFileSync('./openapi.json', JSON.stringify(spec, null, 2))

  const yamlSpec = fastify.swagger({ yaml: true })
  writeFileSync('./openapi.yaml', yamlSpec)

  await fastify.close()
  console.log('Spec exported.')
}

exportSpec()
```

**Key Points:**
- `fastify.close()` should be called after export to cleanly shut down any plugin connections (database pools, etc.).
- This script can be run as a `package.json` script: `"export:spec": "ts-node scripts/export-spec.ts"`.
- The exported file can be committed to version control for contract diffing between releases. [Inference: this approach is common in API-first teams but is not enforced by the framework.]

---

### Serving the Spec at Runtime

`@fastify/swagger` automatically exposes the spec at two default endpoints when registered:

| Format | Default Route |
|--------|--------------|
| JSON   | `GET /documentation/json` |
| YAML   | `GET /documentation/yaml` |

These routes can be customized via the `routePrefix` option:

```typescript
await fastify.register(swagger, {
  routePrefix: '/api-spec',
  openapi: { info: { title: 'My API', version: '1.0.0' } },
})
// Now available at: /api-spec/json and /api-spec/yaml
```

---

### Serving Interactive UI with @fastify/swagger-ui

`@fastify/swagger-ui` mounts Swagger UI as a static bundle served directly from your Fastify process. It reads the spec exposed by `@fastify/swagger`.

```typescript
import swaggerUi from '@fastify/swagger-ui'

await fastify.register(swaggerUi, {
  routePrefix: '/docs',
  uiConfig: {
    docExpansion: 'list',
    deepLinking: true,
  },
  staticCSP: true,
})
```

After registration, the UI is available at `/docs`. The UI fetches the JSON spec from the sibling `/docs/json` endpoint at runtime.

**Key Points:**
- `staticCSP: true` adds a `Content-Security-Policy` header tuned for Swagger UI's inline scripts. [Inference: CSP requirements may vary if you customize the UI with additional scripts.]
- `@fastify/swagger` must be registered before `@fastify/swagger-ui`.

---

### Restricting Access to the Spec and UI

In production environments it is common to restrict documentation endpoints to internal networks or authenticated users.

#### Option 1 — Prefix-level authentication hook

```typescript
fastify.addHook('onRequest', async (request, reply) => {
  const path = request.url
  if (path.startsWith('/docs')) {
    const token = request.headers['x-internal-token']
    if (token !== process.env.INTERNAL_TOKEN) {
      reply.code(401).send({ error: 'Unauthorized' })
    }
  }
})
```

#### Option 2 — Encapsulated plugin scope

Register the swagger plugins inside a scoped plugin and apply authentication only there:

```typescript
await fastify.register(async (scope) => {
  scope.addHook('onRequest', async (request, reply) => {
    if (!isInternalRequest(request)) {
      reply.code(403).send({ error: 'Forbidden' })
    }
  })

  await scope.register(swagger, { openapi: { info: { title: 'My API', version: '1.0.0' } } })
  await scope.register(swaggerUi, { routePrefix: '/docs' })
}, { prefix: '/internal' })
```

#### Option 3 — Disable at runtime via environment variable

```typescript
if (process.env.NODE_ENV !== 'production') {
  await fastify.register(swaggerUi, { routePrefix: '/docs' })
}
```

[Inference: disabling via environment variable is a blunt approach and does not prevent spec leakage if the JSON endpoint is registered separately. Explicit auth is more reliable.]

---

### Hosting the Spec Externally

Once exported to a static file, the spec can be hosted on any platform that serves static files or understands OpenAPI documents.

#### GitHub Pages / Static Hosting

Commit `openapi.json` to a repository and host it via GitHub Pages. Any client capable of fetching a raw URL can consume it. Tools like Redoc can render it client-side:

```html
<!DOCTYPE html>
<html>
  <body>
    <redoc spec-url='https://yourorg.github.io/your-repo/openapi.json'></redoc>
    <script src="https://cdn.jsdelivr.net/npm/redoc/bundles/redoc.standalone.js"></script>
  </body>
</html>
```

#### Dedicated API Documentation Platforms

Exported specs can be uploaded to third-party documentation platforms. [Unverified: specific platform behaviors and import flows change frequently — consult each platform's current documentation.]

Common platforms include:
- **Scalar** — accepts an OpenAPI file or URL; renders with its own UI
- **Redocly** — CI/CD integration for linting and hosting
- **Stoplight** — collaborative API design and hosting
- **Bump.sh** — changelog-aware doc hosting with diff support

#### Serving Redoc Inside Fastify

Redoc can also be self-hosted as a static HTML endpoint inside Fastify, pointing to the internal spec URL:

```typescript
fastify.get('/redoc', async (request, reply) => {
  reply.type('text/html').send(`
    <!DOCTYPE html>
    <html>
      <head><title>API Docs</title></head>
      <body>
        <redoc spec-url='/documentation/json'></redoc>
        <script src="https://cdn.jsdelivr.net/npm/redoc/bundles/redoc.standalone.js"></script>
      </body>
    </html>
  `)
})
```

---

### Spec Versioning Strategies

| Strategy | Description |
|----------|-------------|
| URL prefix versioning | `/v1/documentation/json`, `/v2/documentation/json` — each version is a separate Fastify scope with its own swagger registration |
| Git-based diffing | Export `openapi.json` on every release and diff using tools like `openapi-diff` or `oasdiff` |
| Changelog generation | Tools such as `bump.sh` or `Redocly` can auto-generate human-readable changelogs from spec diffs |

[Inference: URL prefix versioning requires running separate Fastify plugin scopes per API version, which increases registration complexity but keeps specs cleanly isolated.]

---

### Multiple Spec Instances

If your application exposes multiple distinct API surfaces (e.g., a public API and an admin API), you can register `@fastify/swagger` multiple times in separate encapsulated scopes:

```typescript
// Public API scope
await fastify.register(async (publicScope) => {
  await publicScope.register(swagger, {
    routePrefix: '/public/spec',
    openapi: { info: { title: 'Public API', version: '1.0.0' } },
  })
  await publicScope.register(swaggerUi, { routePrefix: '/public/docs' })
  // register public routes...
}, { prefix: '/public' })

// Admin API scope
await fastify.register(async (adminScope) => {
  await adminScope.register(swagger, {
    routePrefix: '/admin/spec',
    openapi: { info: { title: 'Admin API', version: '1.0.0' } },
  })
  await adminScope.register(swaggerUi, { routePrefix: '/admin/docs' })
  // register admin routes...
}, { prefix: '/admin' })
```

Each scope generates its own isolated spec containing only the routes registered within it.

---

### Architecture: Spec Lifecycle

```mermaid
flowchart TD
    A[Register @fastify/swagger] --> B[Register Routes with Schemas]
    B --> C[fastify.ready()]
    C --> D{Usage}
    D --> E[Runtime: /documentation/json]
    D --> F[Runtime: /docs via swagger-ui]
    D --> G[Build-time: fastify.swagger() to file]
    G --> H[openapi.json / openapi.yaml]
    H --> I[Version Control / CI Diffing]
    H --> J[External Hosting Platform]
    H --> K[Self-hosted Redoc endpoint]
```

---

### Common Issues

**Spec is empty or missing routes**

Routes registered after `fastify.ready()` is called will not appear in the spec. All route registration must complete before the instance is marked ready.

**YAML endpoint returns 404**

`@fastify/swagger` v8+ exposes both JSON and YAML by default. Older versions may require explicit configuration. [Unverified: verify against the specific installed version's changelog.]

**Swagger UI fails to load in production due to CSP**

Set `staticCSP: true` in the `@fastify/swagger-ui` options, or configure your reverse proxy's `Content-Security-Policy` header to permit the inline scripts Swagger UI requires.

**`fastify.swagger is not a function`**

This occurs when `@fastify/swagger` has not been registered before calling `fastify.swagger()`, or when the plugin has not finished loading (i.e., `await fastify.ready()` was not awaited).

---

**Related Topics**
- OpenAPI schema reuse with `$ref` and shared component definitions
- Validating the exported spec with `openapi-schema-validator` or `Redocly CLI`
- Generating TypeScript client SDKs from the exported spec (`openapi-typescript`, `orval`)
- Integrating spec export into CI pipelines for breaking-change detection
- Customizing Swagger UI theme, branding, and layout options
- Using `@fastify/swagger` with Fastify v5 changes and migration notes