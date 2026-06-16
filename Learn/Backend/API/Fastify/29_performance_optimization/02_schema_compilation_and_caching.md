## Schema Compilation and Caching

Fastify's performance advantage over generic Node.js frameworks comes largely from compiling validation and serialization logic once at startup rather than interpreting schemas on every request. Understanding how this compilation pipeline works — and how to control it — is essential for building efficient, correct Fastify applications.

---

### Why Compilation Matters

Without schema compilation, validating a request body requires walking the schema tree and checking each rule against each value at runtime. Serializing a response requires inspecting every value's type before encoding it. Both operations are inherently dynamic and allocate intermediate objects.

Fastify avoids this by transforming schemas into native JavaScript functions at startup:

- **Validation**: Ajv compiles a JSON Schema into a `validate(data)` function with inlined conditionals and type checks
- **Serialization**: `fast-json-stringify` compiles a JSON Schema into a `serialize(obj)` function with a fixed code path per field

Once compiled, these functions execute without schema interpretation overhead on every subsequent request.

---

### When Compilation Happens

Schema compilation is triggered during Fastify's initialization phase — specifically when routes are registered and the application is readied.

```ts
const fastify = Fastify();

// Schema compilation is queued here (route registration)
fastify.post('/users', {
  schema: {
    body: { type: 'object', properties: { name: { type: 'string' } } },
    response: { 200: { type: 'object', properties: { id: { type: 'string' } } } },
  },
  handler: async (request) => ({ id: '1' }),
});

// Compilation actually executes here
await fastify.ready();

// By this point, all validators and serializers are compiled and cached
await fastify.listen({ port: 3000 });
```

**Key Points:**
- Compilation does not happen at route definition time — it happens during `fastify.ready()` or `fastify.listen()`
- Any schema error (invalid JSON Schema syntax, unresolved `$ref`) surfaces at startup, not at request time
- If `fastify.ready()` is never called explicitly, `fastify.listen()` calls it internally

---

### Ajv: Validator Compilation

Fastify instantiates Ajv internally and uses it to compile validators for `body`, `querystring`, `params`, and `headers` schemas.

#### Default Ajv Configuration

Fastify's default Ajv instance is configured with:

```ts
{
  coerceTypes: 'array',   // coerce query strings and params to declared types
  useDefaults: true,      // apply default values from schema
  removeAdditional: false // do not strip undeclared properties by default
}
```

[Inference: exact defaults may vary across Fastify versions; verify against the installed version's source or documentation]

#### Customizing Ajv

Pass a custom Ajv configuration via `ajv` option at Fastify instantiation:

```ts
import Fastify from 'fastify';
import Ajv from 'ajv';
import addFormats from 'ajv-formats';

const fastify = Fastify({
  ajv: {
    customOptions: {
      removeAdditional: true,    // strip properties not in schema
      coerceTypes: true,
      useDefaults: true,
      allErrors: false,          // stop at first error (faster)
    },
    plugins: [
      [addFormats, { mode: 'fast' }],  // adds format validators (email, uuid, etc.)
    ],
  },
});
```

**Key Points:**
- `removeAdditional: true` mutates the incoming object, stripping undeclared fields before the handler runs — useful as a defense-in-depth measure but changes request data in place
- `allErrors: false` (default) stops validation at the first failure, which is faster than collecting all errors
- `ajv-formats` is not bundled — `format` keywords like `'uuid'` or `'email'` require explicit plugin registration [Unverified: behavior without `ajv-formats` may silently skip format validation rather than throw; verify with your Ajv version]

---

### fast-json-stringify: Serializer Compilation

For each route with a `response` schema, Fastify compiles a dedicated serializer using `fast-json-stringify`.

```ts
fastify.get('/products/:id', {
  schema: {
    response: {
      200: {
        type: 'object',
        properties: {
          id: { type: 'string' },
          name: { type: 'string' },
          price: { type: 'number' },
          inStock: { type: 'boolean' },
        },
        required: ['id', 'name', 'price'],
      },
    },
  },
  handler: async (request) => {
    return { id: '42', name: 'Widget', price: 9.99, inStock: true, _secret: 'stripped' };
  },
});
```

The compiled serializer for this route produces a function roughly equivalent to:

```ts
function serialize(obj) {
  let json = '{"id":';
  json += JSON.stringify(obj.id);
  json += ',"name":';
  json += JSON.stringify(obj.name);
  json += ',"price":';
  json += obj.price;
  json += ',"inStock":';
  json += obj.inStock;
  json += '}';
  return json;
}
```

This avoids all runtime type inspection. Fields not in the schema (`_secret`) are simply not referenced.

---

### Schema Registration with addSchema

Schemas can be registered globally and referenced by `$id` across multiple routes. This avoids duplicate compilation of shared schema shapes.

```ts
// Register reusable schemas at startup
fastify.addSchema({
  $id: 'UserResponse',
  type: 'object',
  properties: {
    id: { type: 'string', format: 'uuid' },
    name: { type: 'string' },
    email: { type: 'string', format: 'email' },
  },
  required: ['id', 'name', 'email'],
});

fastify.addSchema({
  $id: 'ErrorResponse',
  type: 'object',
  properties: {
    statusCode: { type: 'integer' },
    error: { type: 'string' },
    message: { type: 'string' },
  },
});
```

#### Referencing with $ref

```ts
fastify.get('/users/:id', {
  schema: {
    response: {
      200: { $ref: 'UserResponse#' },
      404: { $ref: 'ErrorResponse#' },
    },
  },
  handler: async (request) => {
    return fastify.db.users.findById(request.params.id);
  },
});

fastify.get('/me', {
  schema: {
    response: {
      200: { $ref: 'UserResponse#' },
    },
  },
  handler: async (request) => {
    return fastify.db.users.findById(request.user.id);
  },
});
```

**Key Points:**
- `addSchema` must be called before the route that references it is registered
- The `$ref` string uses the format `'SchemaId#'` (with the `#` suffix indicating the root of the referenced schema)
- A single Ajv compilation of `UserResponse` is reused across all referencing routes [Inference: Fastify and Ajv cache compiled schemas by `$id`; exact caching behavior is implementation-dependent]

---

### Schema Compilation Pipeline Diagram

<svg viewBox="0 0 680 380" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="12">
  <defs>
    <marker id="arr" markerWidth="8" markerHeight="8" refX="6" refY="3" orient="auto">
      <path d="M0,0 L0,6 L8,3 z" fill="#64748b"/>
    </marker>
  </defs>

  <!-- Route Definition -->
  <rect x="20" y="20" width="180" height="55" rx="7" fill="#1e293b" stroke="#38bdf8" stroke-width="1.5"/>
  <text x="110" y="44" text-anchor="middle" fill="#38bdf8" font-weight="bold">Route Definition</text>
  <text x="110" y="62" text-anchor="middle" fill="#94a3b8">schema: { body, response }</text>

  <!-- addSchema -->
  <rect x="20" y="110" width="180" height="55" rx="7" fill="#1e293b" stroke="#38bdf8" stroke-width="1.5"/>
  <text x="110" y="134" text-anchor="middle" fill="#38bdf8" font-weight="bold">addSchema()</text>
  <text x="110" y="152" text-anchor="middle" fill="#94a3b8">$id references</text>

  <!-- Arrow to ready() -->
  <line x1="200" y1="47" x2="280" y2="100" stroke="#64748b" stroke-width="1" marker-end="url(#arr)"/>
  <line x1="200" y1="137" x2="280" y2="120" stroke="#64748b" stroke-width="1" marker-end="url(#arr)"/>

  <!-- fastify.ready() -->
  <rect x="280" y="80" width="140" height="55" rx="7" fill="#1e293b" stroke="#f472b6" stroke-width="1.5"/>
  <text x="350" y="104" text-anchor="middle" fill="#f472b6" font-weight="bold">fastify.ready()</text>
  <text x="350" y="122" text-anchor="middle" fill="#94a3b8">triggers compilation</text>

  <!-- Arrow to Ajv -->
  <line x1="350" y1="135" x2="230" y2="210" stroke="#64748b" stroke-width="1" marker-end="url(#arr)"/>
  <!-- Arrow to fjs -->
  <line x1="350" y1="135" x2="470" y2="210" stroke="#64748b" stroke-width="1" marker-end="url(#arr)"/>

  <!-- Ajv -->
  <rect x="130" y="210" width="160" height="55" rx="7" fill="#1e293b" stroke="#fbbf24" stroke-width="1.5"/>
  <text x="210" y="234" text-anchor="middle" fill="#fbbf24" font-weight="bold">Ajv Compile</text>
  <text x="210" y="252" text-anchor="middle" fill="#94a3b8">validate() fn</text>

  <!-- fast-json-stringify -->
  <rect x="370" y="210" width="180" height="55" rx="7" fill="#1e293b" stroke="#fbbf24" stroke-width="1.5"/>
  <text x="460" y="234" text-anchor="middle" fill="#fbbf24" font-weight="bold">fast-json-stringify</text>
  <text x="460" y="252" text-anchor="middle" fill="#94a3b8">serialize() fn</text>

  <!-- Arrow to cache -->
  <line x1="210" y1="265" x2="280" y2="315" stroke="#64748b" stroke-width="1" marker-end="url(#arr)"/>
  <line x1="460" y1="265" x2="400" y2="315" stroke="#64748b" stroke-width="1" marker-end="url(#arr)"/>

  <!-- Cache -->
  <rect x="220" y="315" width="240" height="50" rx="7" fill="#1e293b" stroke="#4ade80" stroke-width="1.5"/>
  <text x="340" y="338" text-anchor="middle" fill="#4ade80" font-weight="bold">Route Schema Cache</text>
  <text x="340" y="356" text-anchor="middle" fill="#94a3b8">used on every request</text>
</svg>

---

### Schema Caching Internals

Fastify maintains an internal schema cache keyed by route. When a request arrives, the router resolves the route and retrieves the pre-compiled validator and serializer functions from the route context — no schema lookup or compilation occurs in the hot path.

```
Request arrives
    │
    ▼
find-my-way resolves route → retrieves RouteContext
    │
    ▼
RouteContext.validatorCompiled(request.body)   ← pre-compiled Ajv fn
    │
    ▼
RouteContext.serializerCompiled(reply.payload) ← pre-compiled fjs fn
```

The route context object is allocated once and reused across all requests to that route.

---

### Custom Schema Compilers

Fastify exposes `setValidatorCompiler` and `setSerializerCompiler` to replace the default Ajv and `fast-json-stringify` instances entirely.

#### Custom Validator Compiler

Useful when you need a different validation library (e.g., Zod, Typebox with custom config) or a shared Ajv instance with pre-loaded schemas.

```ts
import Ajv from 'ajv';
import addFormats from 'ajv-formats';

const ajv = new Ajv({ allErrors: true, coerceTypes: true });
addFormats(ajv);

// Pre-load shared schemas
ajv.addSchema({ $id: 'UUID', type: 'string', format: 'uuid' });

fastify.setValidatorCompiler(({ schema, method, url, httpPart }) => {
  return ajv.compile(schema);
});
```

`httpPart` indicates which part of the request is being validated (`'body'`, `'querystring'`, `'params'`, `'headers'`) — useful for applying different coercion rules per part.

#### Custom Serializer Compiler

```ts
import fastJson from 'fast-json-stringify';

fastify.setSerializerCompiler(({ schema, method, url, httpStatus }) => {
  return fastJson(schema);
});
```

A custom serializer compiler is useful when you need to pass additional `fast-json-stringify` options (e.g., `ajv` options for schema resolution within fjs) or substitute an entirely different serializer.

---

### Scoped Compiler Overrides

`setValidatorCompiler` and `setSerializerCompiler` can be scoped to a plugin, affecting only routes within that plugin's context.

```ts
fastify.register(async (instance) => {
  // This custom compiler applies only to routes in this plugin
  instance.setValidatorCompiler(({ schema }) => customAjv.compile(schema));

  instance.post('/special', {
    schema: { body: specialSchema },
    handler: specialHandler,
  });
});

// Routes outside the plugin use the default compiler
fastify.get('/normal', { schema: normalSchema, handler: normalHandler });
```

---

### Typebox Integration

`@sinclair/typebox` generates JSON Schema from TypeScript types, providing end-to-end type safety while still using Ajv for compilation.

```ts
import { Type, Static } from '@sinclair/typebox';
import { TypeBoxValidatorCompiler } from '@fastify/type-provider-typebox';

const fastify = Fastify().withTypeProvider<TypeBoxTypeProvider>();
fastify.setValidatorCompiler(TypeBoxValidatorCompiler);

const UserBody = Type.Object({
  name: Type.String({ minLength: 1 }),
  email: Type.String({ format: 'email' }),
  age: Type.Integer({ minimum: 0 }),
});

fastify.post('/users', {
  schema: { body: UserBody },
  handler: async (request) => {
    // request.body is typed as Static<typeof UserBody>
    const { name, email, age } = request.body;
    return { name, email, age };
  },
});
```

**Key Points:**
- Typebox schemas are plain JSON Schema objects — Ajv compiles them identically to hand-written schemas
- The TypeScript types are erased at runtime; only the JSON Schema object participates in compilation
- This pattern eliminates schema/type duplication without introducing a new compilation mechanism

---

### Avoiding Compilation Mistakes

#### Registering Schemas Inside Handlers

```ts
// Incorrect — recompiles on every request
fastify.post('/items', async (request) => {
  const validate = new Ajv().compile({ type: 'object' }); // never do this
  if (!validate(request.body)) throw new Error('invalid');
});

// Correct — compiled once at startup
fastify.post('/items', {
  schema: { body: { type: 'object' } },
  handler: async (request) => {
    // validation already ran before handler was called
  },
});
```

#### Referencing Unregistered Schemas

```ts
// Incorrect — $ref to unregistered schema causes startup error
fastify.get('/users', {
  schema: {
    response: { 200: { $ref: 'UserResponse#' } }, // not yet added
  },
  handler: userHandler,
});

// Correct — addSchema before the route that references it
fastify.addSchema({ $id: 'UserResponse', type: 'object', ... });
fastify.get('/users', {
  schema: { response: { 200: { $ref: 'UserResponse#' } } },
  handler: userHandler,
});
```

#### Missing Response Schema

```ts
// No response schema — falls back to JSON.stringify, no field stripping
fastify.get('/users', {
  handler: async () => fetchUsers(),
});

// With response schema — compiled serializer, fields stripped to schema
fastify.get('/users', {
  schema: {
    response: {
      200: {
        type: 'array',
        items: { $ref: 'UserResponse#' },
      },
    },
  },
  handler: async () => fetchUsers(),
});
```

---

### Schema Compilation and Testing

During testing, `fastify.ready()` must be called before sending requests to trigger compilation.

```ts
import { test } from 'node:test';
import buildApp from '../src/app.js';

test('POST /users validates body', async (t) => {
  const app = buildApp();
  await app.ready(); // compilation happens here

  const response = await app.inject({
    method: 'POST',
    url: '/users',
    payload: { name: '' }, // missing required email
  });

  t.assert.strictEqual(response.statusCode, 400);
  await app.close();
});
```

`fastify.inject()` calls `ready()` automatically if not already called. [Inference: based on Fastify's documented inject behavior; verify with your version]

---

### Performance Impact Summary

| Operation | Without schema | With compiled schema |
|---|---|---|
| Body validation | Manual, per-request | Compiled Ajv fn, O(1) per field |
| Response serialization | `JSON.stringify` | Compiled fjs fn, no type inspection |
| Field filtering | Manual or none | Automatic via schema shape |
| Type coercion | Manual | Automatic via Ajv `coerceTypes` |
| Error surfacing | Runtime, per-request | Startup, deterministic |

---

**Related Topics:**
- JSON Schema `$ref` resolution and cross-plugin schema visibility
- Ajv custom keywords and formats for domain-specific validation
- Typebox vs Zod vs raw JSON Schema tradeoffs in Fastify
- `fast-json-stringify` options: `ajv`, `rounding`, `largeArrayMechanism`
- Schema versioning strategies across API versions
- Validating response bodies in tests against registered schemas
- Using `fluent-json-schema` as a builder API for JSON Schema
- Serializer compiler caching behavior under plugin encapsulation