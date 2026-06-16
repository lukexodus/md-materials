## Swagger UI with @fastify/swagger-ui

`@fastify/swagger-ui` is the official plugin that serves Swagger UI as a set of static routes within your Fastify application. It depends on `@fastify/swagger` being registered first — it reads the generated OpenAPI document and serves the browser interface that renders it. The two plugins are separate by design, allowing the raw OpenAPI document to be used independently of the UI.

---

### How It Works

`@fastify/swagger-ui` registers a set of routes under a configurable prefix. When a browser hits that prefix, it receives an HTML page that loads the Swagger UI JavaScript bundle and points it at the `/json` or `/yaml` endpoint served by `@fastify/swagger`.

```
GET /docs          → Swagger UI HTML page
GET /docs/json     → OpenAPI document (JSON)
GET /docs/yaml     → OpenAPI document (YAML)
GET /docs/static/* → Swagger UI static assets (JS, CSS)
```

[Inference] The static assets are bundled with the plugin package itself and served from memory — no CDN dependency is required.

---

### Minimal Setup

```typescript
import Fastify from 'fastify';
import fastifySwagger from '@fastify/swagger';
import fastifySwaggerUi from '@fastify/swagger-ui';

const app = Fastify();

await app.register(fastifySwagger, {
  openapi: {
    info: { title: 'My API', version: '1.0.0' },
  },
});

await app.register(fastifySwaggerUi, {
  routePrefix: '/docs',
});

await app.listen({ port: 3000 });
```

`routePrefix` is the only required option. All other options have defaults.

---

### Full Options Reference

```typescript
await app.register(fastifySwaggerUi, {
  routePrefix: '/docs',

  // Swagger UI behavioral configuration
  uiConfig: {
    docExpansion: 'list',           // 'full' | 'list' | 'none'
    deepLinking: true,              // enables anchor links per operation
    displayRequestDuration: true,   // shows response time in ms
    defaultModelsExpandDepth: 2,    // depth to expand schemas in Models section
    defaultModelExpandDepth: 2,     // depth to expand individual model
    defaultModelRendering: 'model', // 'example' | 'model'
    filter: true,                   // shows search/filter bar
    showExtensions: true,           // shows x- extension fields
    showCommonExtensions: true,
    supportedSubmitMethods: ['get', 'post', 'put', 'patch', 'delete'],
    validatorUrl: null,             // disables external schema validation
    persistAuthorization: true,     // retains auth tokens across page reloads
  },

  // Lifecycle hooks applied only to the /docs routes
  uiHooks: {
    onRequest: async (request, reply) => {},
    preHandler: async (request, reply) => {},
  },

  // Content-Security-Policy handling
  staticCSP: true,
  transformStaticCSP: (header) => header,

  // Logo customization
  logo: {
    type: 'image/png',
    content: Buffer.from('...base64...', 'base64'),
  },

  // Theme customization (CSS override)
  theme: {
    title: 'My API Docs',
    css: [
      { filename: 'theme.css', content: '.swagger-ui .topbar { display: none; }' },
    ],
    js: [],
    favicon: [],
  },
});
```

---

### `uiConfig` Options in Detail

#### `docExpansion`

Controls the initial expansion state of operations in the UI.

| Value | Effect |
|---|---|
| `'list'` | Shows all tags and operation summaries collapsed (default) |
| `'full'` | Expands all operations on load |
| `'none'` | Collapses everything; only tag names are visible |

For APIs with many routes, `'none'` reduces initial render time and visual noise.

#### `persistAuthorization`

When `true`, authorization tokens entered in the UI are stored in `localStorage` and restored on page reload. Convenient for development; [Speculation] may be a concern if the docs are accessible to untrusted users on a shared machine.

#### `filter`

Adds a search input at the top of the UI that filters operations by path, summary, or tag as you type.

#### `validatorUrl`

By default, Swagger UI contacts an external validator service to check the OpenAPI document. Setting `validatorUrl: null` disables this, which is recommended for internal APIs or offline environments.

#### `supportedSubmitMethods`

Restricts which HTTP methods have the "Try it out" button enabled. To make the UI read-only (documentation only, no live requests):

```typescript
uiConfig: {
  supportedSubmitMethods: [],
}
```

---

### Protecting the Documentation Route

In production, exposing `/docs` without authentication reveals API structure, parameter names, and security scheme details. Use `uiHooks` to guard the documentation routes.

#### Bearer token check

```typescript
await app.register(fastifySwaggerUi, {
  routePrefix: '/docs',
  uiHooks: {
    onRequest: async (request, reply) => {
      const auth = request.headers.authorization;
      if (!auth || auth !== `Bearer ${process.env.DOCS_TOKEN}`) {
        reply.status(401).send({ error: 'Unauthorized' });
      }
    },
  },
});
```

#### Basic auth check

```typescript
await app.register(fastifySwaggerUi, {
  routePrefix: '/docs',
  uiHooks: {
    onRequest: async (request, reply) => {
      const auth = request.headers.authorization ?? '';
      const [scheme, encoded] = auth.split(' ');

      if (scheme !== 'Basic' || !encoded) {
        reply
          .status(401)
          .header('WWW-Authenticate', 'Basic realm="API Docs"')
          .send('Unauthorized');
        return;
      }

      const decoded = Buffer.from(encoded, 'base64').toString('utf8');
      const [user, pass] = decoded.split(':');

      if (user !== process.env.DOCS_USER || pass !== process.env.DOCS_PASS) {
        reply.status(401).send('Unauthorized');
      }
    },
  },
});
```

**Key Points:**
- `uiHooks` apply to all routes under `routePrefix`, including `/docs/json`, `/docs/yaml`, and `/docs/static/*`
- [Inference] Hooks applied here do not affect the application's other routes — they are scoped to the documentation prefix
- Conditional registration (only in non-production environments) is a simpler alternative to auth-guarding:

```typescript
if (process.env.NODE_ENV !== 'production') {
  await app.register(fastifySwaggerUi, { routePrefix: '/docs' });
}
```

---

### Content Security Policy

Swagger UI loads inline scripts and styles, which conflict with strict CSP headers. `@fastify/swagger-ui` provides two options.

#### `staticCSP: true`

Adds a pre-computed CSP header to the documentation routes that permits Swagger UI's assets:

```typescript
await app.register(fastifySwaggerUi, {
  routePrefix: '/docs',
  staticCSP: true,
});
```

#### `transformStaticCSP`

Receives the pre-computed CSP string and returns a modified version. Use this when you need to merge the Swagger UI CSP with your own directives:

```typescript
await app.register(fastifySwaggerUi, {
  routePrefix: '/docs',
  staticCSP: true,
  transformStaticCSP: (header) => {
    // Append a report-uri directive
    return `${header}; report-uri /csp-violations`;
  },
});
```

**Key Points:**
- If your application sets a global CSP header (e.g., via `@fastify/helmet`), it may block Swagger UI assets even if `staticCSP` is set — [Inference] the two headers may conflict depending on how your helmet configuration is ordered
- Setting `staticCSP: true` only affects the `/docs` routes, not the rest of the application

---

### Logo Customization

A custom logo replaces the default Swagger UI topbar logo.

```typescript
import { readFileSync } from 'fs';

await app.register(fastifySwaggerUi, {
  routePrefix: '/docs',
  logo: {
    type: 'image/svg+xml',
    content: readFileSync('./assets/logo.svg'),
  },
});
```

`content` accepts a `Buffer`. `type` is the MIME type of the image.

---

### Theme Customization

The `theme` option allows injecting custom CSS and JavaScript into the Swagger UI page, and overriding the browser tab title and favicon.

#### Hiding the topbar

```typescript
await app.register(fastifySwaggerUi, {
  routePrefix: '/docs',
  theme: {
    title: 'Inventory API',
    css: [
      {
        filename: 'hide-topbar.css',
        content: '.swagger-ui .topbar { display: none; }',
      },
    ],
  },
});
```

#### Custom favicon

```typescript
import { readFileSync } from 'fs';

await app.register(fastifySwaggerUi, {
  routePrefix: '/docs',
  theme: {
    favicon: [
      {
        filename: 'favicon.png',
        rel: 'icon',
        type: 'image/png',
        content: readFileSync('./assets/favicon.png'),
      },
    ],
  },
});
```

---

### Accessing the OpenAPI Document Directly

The JSON and YAML endpoints served by `@fastify/swagger-ui` are useful for non-browser consumers.

```bash
# Fetch the OpenAPI JSON document
curl http://localhost:3000/docs/json | jq .

# Fetch the OpenAPI YAML document
curl http://localhost:3000/docs/yaml
```

These endpoints are served by `@fastify/swagger` but are routed under the `routePrefix` set in `@fastify/swagger-ui`. [Inference] If `@fastify/swagger-ui` is not registered, the JSON and YAML endpoints are still available but at a different path determined by `@fastify/swagger`'s own configuration — check `@fastify/swagger` options if using it standalone.

---

### Multiple API Documents

If your application exposes multiple distinct APIs (e.g., a public API and an admin API), you can register multiple swagger+swagger-ui pairs under different prefixes using Fastify's plugin scoping.

```typescript
// Public API docs
await app.register(async (publicScope) => {
  await publicScope.register(fastifySwagger, {
    openapi: { info: { title: 'Public API', version: '1.0.0' } },
  });
  await publicScope.register(fastifySwaggerUi, { routePrefix: '/docs/public' });

  publicScope.get('/status', { schema: { tags: ['public'] } }, async () => ({ ok: true }));
});

// Admin API docs
await app.register(async (adminScope) => {
  await adminScope.register(fastifySwagger, {
    openapi: { info: { title: 'Admin API', version: '1.0.0' } },
  });
  await adminScope.register(fastifySwaggerUi, { routePrefix: '/docs/admin' });

  adminScope.get('/users', { schema: { tags: ['admin'] } }, async () => []);
});
```

**Key Points:**
- Each scope produces an independent OpenAPI document containing only routes registered within that scope
- Plugin encapsulation boundaries determine which routes appear in which document
- [Inference] Routes registered outside a scoped block appear in neither document unless the scope is set up to include them

---

### Diagram: Request Flow for Documentation Routes

```mermaid
flowchart TD
    A[Browser: GET /docs] --> B[@fastify/swagger-ui\nroute handler]
    B --> C[Serve HTML page\nwith UI bundle]
    C --> D[Browser loads\nSwagger UI JS]
    D --> E[UI fetches GET /docs/json]
    E --> F[@fastify/swagger\ndocument endpoint]
    F --> G[Collect route schemas\nAssemble OpenAPI object]
    G --> H[Return JSON document]
    H --> I[Swagger UI renders\nroutes and schemas]

    J[Browser: GET /docs/static/swagger-ui.css] --> K[Serve bundled\nstatic asset]
```

---

### Common Mistakes

| Mistake | Effect |
|---|---|
| Registering `@fastify/swagger-ui` before `@fastify/swagger` | [Inference] Plugin will fail or produce an empty document — registration order is required |
| No `uiHooks` in production | Documentation routes are publicly accessible |
| Global CSP via `@fastify/helmet` conflicting with `staticCSP` | Swagger UI assets blocked; UI fails to load in browser |
| Setting `supportedSubmitMethods` to all methods in production | Allows anyone with doc access to make live requests to your API |
| Calling `app.swagger()` before `app.ready()` then serving it statically | Captures an incomplete document missing late-registered routes |
| Using `persistAuthorization: true` in a shared environment | Auth tokens stored in `localStorage` are accessible to any JS on that origin |

---

**Related Topics:**
- `@fastify/helmet` and CSP coexistence — configuring security headers without breaking Swagger UI
- OpenAPI document export for CI — writing the spec to disk after `app.ready()` for contract testing
- Redoc as an alternative renderer — using the OpenAPI JSON output with Redoc instead of Swagger UI
- Route tagging strategies — organizing large APIs into logical groups in the Swagger UI sidebar
- `@fastify/swagger` `transform` API — custom schema transformation before the document is assembled
- Versioned API documentation — managing separate OpenAPI specs for v1 and v2 API surfaces