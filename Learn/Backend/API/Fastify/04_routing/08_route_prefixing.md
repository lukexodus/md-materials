### Route Prefixing

#### Overview

Route prefixing in Fastify is the mechanism by which a path segment is prepended to all routes registered within a plugin scope. It is declared through the `prefix` option passed to `fastify.register`. Prefixes compose across nested scopes, producing the full route path from the concatenation of each level's prefix.

---

#### Declaring a Prefix

The `prefix` option is passed as the second argument to `fastify.register`.

js

```
fastify.register(async function (instance) {
  instance.get('/list', async () => ({ data: [] }));
  instance.post('/create', async () => ({ created: true }));
}, { prefix: '/api' });
```

**Registered routes:**

- `GET /api/list`
- `POST /api/create`

**Key Points:**

- The prefix is prepended to every route path declared on the scoped instance.
- Routes declared on the root instance outside the plugin are not affected.
- The prefix value should begin with `/`.

---

#### Prefix Composition Across Nested Scopes

When plugins are nested, each level's prefix is concatenated with its parent's. There is no separator inserted automatically — the concatenation is direct string joining.

js

```
fastify.register(async function (v1) {

  v1.register(async function (users) {
    users.get('/', async () => ({ resource: 'users' }));
    users.get('/:id', async (req) => ({ id: req.params.id }));
  }, { prefix: '/users' });

  v1.register(async function (orders) {
    orders.get('/', async () => ({ resource: 'orders' }));
  }, { prefix: '/orders' });

}, { prefix: '/v1' });
```

**Registered routes:**

- `GET /v1/users/`
- `GET /v1/users/:id`
- `GET /v1/orders/`

**Key Points:**

- Prefix composition is purely additive. Each nested level appends its segment to the inherited prefix.
- There is no mechanism to override or reset an inherited prefix from within a child scope.

---

#### Prefix and Route Path Joining

Fastify joins the prefix and the route path by direct concatenation. This means the combination of prefix and route path determines whether a slash appears between them.

js

```
fastify.register(async function (instance) {
  instance.get('/items', handler);   // → /api/items
  instance.get('items', handler);    // → /apiitems  ← unintended
}, { prefix: '/api' });
```

**Key Points:**

- Route paths within a prefixed scope should begin with `/` to produce well-formed URLs.
- A missing leading slash on the route path will cause it to be concatenated directly against the prefix without a separator.
- [Inference] This is a common source of subtle routing bugs and is worth enforcing as a convention in codebases with many route files.

---

#### Empty String Routes Within a Prefix

To match the prefix path itself (without a trailing slash), register a route with an empty string path.

js

```
fastify.register(async function (instance) {
  instance.get('', async () => ({ matched: 'exact prefix' }));   // → GET /api
  instance.get('/', async () => ({ matched: 'with slash' }));    // → GET /api/
}, { prefix: '/api' });
```

**Key Points:**

- `GET /api` and `GET /api/` are distinct routes unless `ignoreTrailingSlash` is enabled on the server instance.
- Registering both is valid and can be useful when both forms should be supported explicitly.

---

#### Trailing Slash Behavior

Fastify treats trailing slashes as significant by default. This affects prefixed routes in the same way it affects top-level routes.

js

```
const fastify = Fastify({ ignoreTrailingSlash: true });

fastify.register(async function (instance) {
  instance.get('/items', handler);
}, { prefix: '/api' });
```

With `ignoreTrailingSlash: true`:

- `GET /api/items` and `GET /api/items/` both resolve to the same handler.

Without it (default):

- `GET /api/items/` would return `404` if only `GET /api/items` is registered.

---

#### Prefix in Combination with Route-Level Options

The prefix applies to the route path only. Other route-level options — schemas, hooks, constraints — are not affected by the prefix and must be declared independently per route or via scoped hooks.

js

```
fastify.register(async function (instance) {

  instance.addHook('preHandler', authHook); // applies to all routes in this scope

  instance.get('/profile', {
    schema: {
      response: { 200: { type: 'object', properties: { name: { type: 'string' } } } }
    }
  }, async () => ({ name: 'Ada' }));

}, { prefix: '/user' });
```

**Registered route:** `GET /user/profile`
The `preHandler` hook and schema are scoped independently of the prefix.

---

#### Versioned API Prefixes

A common pattern is to use prefixes to version APIs, with each version isolated in its own plugin scope.

js

```
async function v1Routes(instance) {
  instance.get('/status', async () => ({ version: 1, status: 'ok' }));
}

async function v2Routes(instance) {
  instance.get('/status', async () => ({ version: 2, status: 'ok' }));
}

fastify.register(v1Routes, { prefix: '/v1' });
fastify.register(v2Routes, { prefix: '/v2' });
```

**Registered routes:**

- `GET /v1/status`
- `GET /v2/status`

**Key Points:**

- Each version is fully encapsulated. Hooks, decorators, and error handlers in `/v1` do not affect `/v2` and vice versa.
- This makes it straightforward to deprecate or replace individual versions without affecting others.

---

#### Dynamic Prefix Construction

Prefixes are static strings declared at registration time. They cannot be computed dynamically at request time — they are part of the route registration process, which occurs at startup.

js

```
// Valid — prefix known at startup
fastify.register(routePlugin, { prefix: '/api/v1' });

// Not possible — prefix cannot vary per request
// Parameterized prefixes are not supported at the register level
```

**Key Points:**

- If path segments need to vary at request time, those segments should be declared as route parameters within the route path, not as prefixes.
- [Inference] Attempting to construct prefixes from runtime values (environment config, database lookups) is only viable if those values are resolved before `fastify.listen` or `fastify.ready` is called, since route registration is finalized during startup.

---

#### Visual: Prefix Concatenation at Each Scope Level

<svg viewBox="0 0 660 260" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="12">
<defs>
<marker id="arr" markerWidth="8" markerHeight="8" refX="6" refY="3" orient="auto">
<path d="M0,0 L0,6 L8,3 z" fill="#888"/>
</marker>
</defs>
<!-- Level 0: Root -->
<rect x="240" y="10" width="180" height="38" rx="6" fill="#4A90D9"/>
<text x="330" y="26" text-anchor="middle" fill="white" font-weight="bold">Root</text>
<text x="330" y="42" text-anchor="middle" fill="white">prefix: ""</text>
<!-- Root → /v1 -->
<line x1="330" y1="48" x2="330" y2="80" stroke="#888" stroke-width="1.5" marker-end="url(#arr)"/>
<text x="348" y="70" fill="#555">+ /v1</text>
<!-- Level 1 -->
<rect x="240" y="80" width="180" height="38" rx="6" fill="#7B68EE"/>
<text x="330" y="96" text-anchor="middle" fill="white" font-weight="bold">Scope</text>
<text x="330" y="112" text-anchor="middle" fill="white">prefix: /v1</text>
<!-- /v1 → /users -->
<line x1="290" y1="118" x2="160" y2="155" stroke="#888" stroke-width="1.5" marker-end="url(#arr)"/>
<text x="195" y="143" text-anchor="middle" fill="#555">+ /users</text>
<!-- /v1 → /orders -->
<line x1="370" y1="118" x2="490" y2="155" stroke="#888" stroke-width="1.5" marker-end="url(#arr)"/>
<text x="460" y="143" text-anchor="middle" fill="#555">+ /orders</text>
<!-- Level 2 left -->
<rect x="70" y="155" width="190" height="38" rx="6" fill="#7B68EE"/>
<text x="165" y="171" text-anchor="middle" fill="white" font-weight="bold">Scope</text>
<text x="165" y="187" text-anchor="middle" fill="white">prefix: /v1/users</text>
<!-- Level 2 right -->
<rect x="400" y="155" width="200" height="38" rx="6" fill="#7B68EE"/>
<text x="500" y="171" text-anchor="middle" fill="white" font-weight="bold">Scope</text>
<text x="500" y="187" text-anchor="middle" fill="white">prefix: /v1/orders</text>
<!-- Routes left -->
<line x1="130" y1="193" x2="90" y2="225" stroke="#888" stroke-width="1.5" marker-end="url(#arr)"/>
<line x1="200" y1="193" x2="230" y2="225" stroke="#888" stroke-width="1.5" marker-end="url(#arr)"/>
<rect x="10" y="225" width="150" height="28" rx="5" fill="#5CB85C"/>
<text x="85" y="244" text-anchor="middle" fill="white">GET /v1/users/</text>
<rect x="170" y="225" width="160" height="28" rx="5" fill="#5CB85C"/>
<text x="250" y="244" text-anchor="middle" fill="white">GET /v1/users/:id</text>
<!-- Routes right -->
<line x1="500" y1="193" x2="500" y2="225" stroke="#888" stroke-width="1.5" marker-end="url(#arr)"/>
<rect x="400" y="225" width="200" height="28" rx="5" fill="#5CB85C"/>
<text x="500" y="244" text-anchor="middle" fill="white">GET /v1/orders/</text>
</svg>

---

#### Common Mistakes

**Missing leading slash on route path:**

js

```
fastify.register(async function (instance) {
  instance.get('list', handler);  // → /apilist, not /api/list
}, { prefix: '/api' });
```

**Registering on the root instance inside a plugin:**

js

```
fastify.register(async function (instance) {
  fastify.get('/list', handler);  // prefix NOT applied — registers on root
  instance.get('/list', handler); // correct
}, { prefix: '/api' });
```

**Assuming the prefix applies to absolute URLs in responses:**

js

```
// The prefix affects routing only — it has no effect on
// URLs constructed manually in response bodies or redirects
reply.redirect('/api/other'); // must be written explicitly
```

---

**Conclusion**

Route prefixing in Fastify is a registration-time operation applied through the `prefix` option on `fastify.register`. Prefixes compose additively across nested scopes, making them well-suited for API versioning and resource grouping. Because prefixing is purely a path-joining operation, attention to leading slashes and the distinction between empty string and `/` routes is important. Prefixes do not affect hooks, schemas, or any other route-level configuration — those are managed independently within each scope.

**Next Steps:** `fastify-plugin` and cross-scope sharing.