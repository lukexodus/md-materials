### Nested and Grouped Routes

#### Overview

Fastify provides a first-class mechanism for organizing routes into logical groups through its plugin system. Rather than registering every route at the top level, related routes are enclosed in plugin functions and registered under a shared prefix. This is the idiomatic Fastify approach to route grouping and nesting.

---

#### Basic Route Grouping with `fastify.register`

The `fastify.register` method accepts a plugin function and an options object. The `prefix` option prepends a path segment to every route defined inside the plugin.

js

```
fastify.register(async function (instance) {
  instance.get('/', async () => ({ resource: 'users' }));
  instance.get('/:id', async (request) => ({ id: request.params.id }));
}, { prefix: '/users' });
```

**Registered routes:**

- `GET /users/`
- `GET /users/:id`

**Key Points:**

- Routes defined inside the plugin function inherit the prefix automatically.
- The `instance` argument is a scoped child instance of Fastify — not the root instance.
- Prefix values should begin with `/`.

---

#### Nesting Plugins for Deeper Paths

Plugins can be nested inside other plugins to build multi-level route hierarchies. Each level of nesting compounds the prefix.

js

```
fastify.register(async function (instance) {

  instance.register(async function (inner) {
    inner.get('/', async () => ({ resource: 'posts' }));
    inner.get('/:postId', async (request) => ({
      postId: request.params.postId
    }));
  }, { prefix: '/posts' });

  instance.register(async function (inner) {
    inner.get('/', async () => ({ resource: 'settings' }));
  }, { prefix: '/settings' });

}, { prefix: '/admin' });
```

**Registered routes:**

- `GET /admin/posts/`
- `GET /admin/posts/:postId`
- `GET /admin/settings/`

---

#### Encapsulation

Every plugin registered via `fastify.register` runs in an encapsulated scope. Decorators, hooks, and plugins added inside a child instance are not visible to the parent or sibling instances unless explicitly exposed.

js

```
fastify.register(async function (instance) {
  // This hook applies only to routes in this scope
  instance.addHook('onRequest', async (request) => {
    request.log.info('scoped hook fired');
  });

  instance.get('/protected', async () => ({ status: 'ok' }));
});

// Routes registered here are NOT affected by the hook above
fastify.get('/public', async () => ({ status: 'public' }));
```

**Key Points:**

- Encapsulation is a deliberate design feature, not a side effect.
- It allows plugins to be self-contained: their hooks, decorators, and error handlers do not leak outward.
- To share behavior across scopes, register it on the root instance or use `fastify-plugin`.

---

#### Breaking Encapsulation with `fastify-plugin`

When a plugin wraps shared infrastructure (authentication, database connections, shared decorators) that must be visible across sibling scopes, `fastify-plugin` removes the encapsulation boundary.

js

```
import fp from 'fastify-plugin';

async function sharedDecorator(instance) {
  instance.decorate('config', { apiVersion: 'v1' });
}

fastify.register(fp(sharedDecorator));

// config decorator is now available on all sibling and child scopes
fastify.register(async function (instance) {
  instance.get('/version', async () => instance.config);
}, { prefix: '/api' });
```

**Key Points:**

- `fastify-plugin` is a separate package (`fastify-plugin` on npm) and must be installed explicitly.
- It should be used for infrastructure plugins, not for route plugins. Route plugins should remain encapsulated.
- [Inference] Overusing `fastify-plugin` on route-level plugins reduces the isolation guarantees that encapsulation provides.

---

#### Splitting Routes Across Files

In real applications, route groups are typically placed in separate files and loaded via `fastify.register`.

**File: `routes/users.js`**

js

```
export default async function usersRoutes(fastify) {
  fastify.get('/', async () => ({ users: [] }));
  fastify.post('/', async (request) => ({ created: request.body }));
  fastify.get('/:id', async (request) => ({ id: request.params.id }));
}
```

**File: `app.js`**

js

```
import Fastify from 'fastify';
import usersRoutes from './routes/users.js';

const fastify = Fastify();

fastify.register(usersRoutes, { prefix: '/users' });

await fastify.listen({ port: 3000 });
```

**Key Points:**

- Each route file exports an async function that receives a scoped Fastify instance.
- The prefix is applied at the point of registration, keeping route files prefix-agnostic.
- This pattern scales to arbitrarily many route files without coupling them to their mount point.

---

#### `@fastify/autoload`

For larger applications, `@fastify/autoload` can automatically discover and register route files from a directory, inferring prefixes from the file system structure.

js

```
import autoload from '@fastify/autoload';
import { fileURLToPath } from 'url';
import path from 'path';

const __dirname = path.dirname(fileURLToPath(import.meta.url));

fastify.register(autoload, {
  dir: path.join(__dirname, 'routes')
});
```

**Directory structure:**

```
routes/
  users/
    index.js     → GET /users/
    _id/
      index.js   → GET /users/:id
  admin/
    index.js     → GET /admin/
```

**Key Points:**

- `@fastify/autoload` is a separate package and must be installed.
- Directory and file naming conventions affect the inferred route paths. The exact conventions should be verified against the current `@fastify/autoload` documentation.
- [Inference] This approach reduces boilerplate for large route trees but introduces an implicit contract between the file system layout and the resulting route structure.

---

#### Visual: Scope and Prefix Hierarchy

<svg viewBox="0 0 660 370" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="12">
<defs>
<marker id="arr" markerWidth="8" markerHeight="8" refX="6" refY="3" orient="auto">
<path d="M0,0 L0,6 L8,3 z" fill="#888"/>
</marker>
</defs>
<!-- Root -->
<rect x="230" y="10" width="200" height="44" rx="8" fill="#4A90D9"/>
<text x="330" y="30" text-anchor="middle" fill="white" font-weight="bold">Root Instance</text>
<text x="330" y="48" text-anchor="middle" fill="white">fastify</text>
<!-- Root to /users -->
<line x1="280" y1="54" x2="140" y2="110" stroke="#888" stroke-width="1.5" marker-end="url(#arr)"/>
<text x="185" y="90" text-anchor="middle" fill="#555">prefix: /users</text>
<!-- Root to /admin -->
<line x1="380" y1="54" x2="520" y2="110" stroke="#888" stroke-width="1.5" marker-end="url(#arr)"/>
<text x="475" y="90" text-anchor="middle" fill="#555">prefix: /admin</text>
<!-- /users scope -->
<rect x="50" y="110" width="180" height="44" rx="8" fill="#7B68EE"/>
<text x="140" y="130" text-anchor="middle" fill="white" font-weight="bold">Scoped Instance</text>
<text x="140" y="148" text-anchor="middle" fill="white">prefix: /users</text>
<!-- /admin scope -->
<rect x="430" y="110" width="180" height="44" rx="8" fill="#7B68EE"/>
<text x="520" y="130" text-anchor="middle" fill="white" font-weight="bold">Scoped Instance</text>
<text x="520" y="148" text-anchor="middle" fill="white">prefix: /admin</text>
<!-- users routes -->
<line x1="100" y1="154" x2="75" y2="210" stroke="#888" stroke-width="1.5" marker-end="url(#arr)"/>
<line x1="140" y1="154" x2="140" y2="210" stroke="#888" stroke-width="1.5" marker-end="url(#arr)"/>
<line x1="180" y1="154" x2="205" y2="210" stroke="#888" stroke-width="1.5" marker-end="url(#arr)"/>
<rect x="10" y="210" width="120" height="34" rx="6" fill="#5CB85C"/>
<text x="70" y="232" text-anchor="middle" fill="white">GET /users/</text>
<rect x="80" y="210" width="120" height="34" rx="6" fill="#5CB85C"/>
<text x="140" y="232" text-anchor="middle" fill="white">POST /users/</text>
<rect x="150" y="210" width="120" height="34" rx="6" fill="#5CB85C"/>
<text x="210" y="232" text-anchor="middle" fill="white">GET /users/:id</text>
<!-- admin to /posts -->
<line x1="490" y1="154" x2="430" y2="210" stroke="#888" stroke-width="1.5" marker-end="url(#arr)"/>
<text x="440" y="192" text-anchor="middle" fill="#555">/posts</text>
<!-- admin to /settings -->
<line x1="550" y1="154" x2="590" y2="210" stroke="#888" stroke-width="1.5" marker-end="url(#arr)"/>
<text x="597" y="192" text-anchor="middle" fill="#555">/settings</text>
<!-- /posts scope -->
<rect x="360" y="210" width="140" height="34" rx="8" fill="#7B68EE"/>
<text x="430" y="232" text-anchor="middle" fill="white">prefix: /admin/posts</text>
<!-- /settings scope -->
<rect x="520" y="210" width="130" height="34" rx="8" fill="#7B68EE"/>
<text x="585" y="232" text-anchor="middle" fill="white">prefix: /admin/settings</text>
<!-- posts routes -->
<line x1="400" y1="244" x2="380" y2="295" stroke="#888" stroke-width="1.5" marker-end="url(#arr)"/>
<line x1="460" y1="244" x2="480" y2="295" stroke="#888" stroke-width="1.5" marker-end="url(#arr)"/>
<rect x="320" y="295" width="120" height="34" rx="6" fill="#5CB85C"/>
<text x="380" y="317" text-anchor="middle" fill="white">GET /admin/posts/</text>
<rect x="450" y="295" width="150" height="34" rx="6" fill="#5CB85C"/>
<text x="525" y="317" text-anchor="middle" fill="white">GET /admin/posts/:id</text>
<!-- settings route -->
<line x1="585" y1="244" x2="585" y2="295" stroke="#888" stroke-width="1.5" marker-end="url(#arr)"/>
<rect x="615" y="295" width="40" height="34" rx="6" fill="#5CB85C"/>
<text x="635" y="310" text-anchor="middle" fill="white" font-size="10">GET</text>
<text x="635" y="323" text-anchor="middle" fill="white" font-size="10">/admin</text>
</svg>

---

#### Prefix Trailing Slash Behavior

Fastify's prefix handling has a specific behavior around trailing slashes that is worth understanding explicitly.

js

```
fastify.register(async function (instance) {
  instance.get('/', handler);   // matches GET /api/
  instance.get('', handler);    // matches GET /api
}, { prefix: '/api' });
```

**Key Points:**

- `GET /api` and `GET /api/` are treated as distinct routes by default.
- Whether both are needed depends on the application's URL design.
- The `ignoreTrailingSlash` server option, if enabled, treats them as equivalent across all routes.

---

#### Common Mistakes

**Registering routes on the root instance instead of the scoped instance:**

js

```
fastify.register(async function (instance) {
  // Wrong — registers on root, prefix not applied
  fastify.get('/list', handler);

  // Correct — registers on scoped instance, prefix applied
  instance.get('/list', handler);
});
```

**Expecting parent hooks to apply inside child scopes:**

js

```
// This hook fires for all routes on the root instance and its descendants
fastify.addHook('onRequest', rootHook);

fastify.register(async function (instance) {
  // rootHook DOES apply here — child scopes inherit from parent
  instance.get('/data', handler);

  // But hooks added here do NOT propagate back to the parent
  instance.addHook('onRequest', scopedHook);
});
```

**Using `fastify-plugin` on route plugins:**

js

```
// Avoid — breaks encapsulation for routes, which should be isolated
fastify.register(fp(routePlugin), { prefix: '/users' });
```

---

**Conclusion**

Fastify's plugin system is the native mechanism for grouping and nesting routes. Prefixes are applied at registration time, keeping individual route files free of mount-point knowledge. Encapsulation isolates hooks and decorators to their declared scope, with `fastify-plugin` available for intentional cross-scope sharing. For large applications, `@fastify/autoload` can automate file-based route discovery, though it introduces conventions that should be reviewed against current documentation.

**Next Steps:** Fastify's plugin system and encapsulation in depth.