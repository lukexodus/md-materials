## Migrating from Hapi to Fastify

Hapi and Fastify share more conceptual DNA than Express and Fastify do — both are plugin-first, both have lifecycle hooks, and both treat configuration as first-class. This shared foundation makes the migration more structural than conceptual, but the differences in plugin architecture, validation approach, authentication model, and server lifecycle are significant enough to require careful translation rather than mechanical substitution.

---

### Mental Model Differences

| Concern | Hapi | Fastify |
|---|---|---|
| Plugin system | `server.register()` with `name` + `version` | `fastify.register()` with `fp` for scope escape |
| Lifecycle hooks | Named lifecycle points (`onPreAuth`, `onPostAuth` …) | Named hooks (`onRequest`, `preHandler` …) — fewer, composable |
| Validation | Joi natively integrated | JSON Schema via `ajv` natively; Joi via `@fastify/joi-router` or custom |
| Authentication | `server.auth.scheme()` + `server.auth.strategy()` | `@fastify/jwt`, `@fastify/passport`, or custom `onRequest` hook |
| Route config | `server.route({ method, path, handler, options })` | `fastify.get(path, { schema, preHandler }, handler)` |
| Error model | `Boom` objects — HTTP-aware errors | Plain errors + `setErrorHandler`; or `http-errors` |
| Server state | `server.app` — shared mutable state bag | `fastify.decorate()` — typed, explicit |
| Caching | `catbox` built-in | External — Redis, `@fastify/caching` |
| Response toolkit | `h.response()`, `h.redirect()`, `h.continue` | `reply.send()`, `reply.redirect()`, `return value` |
| TypeScript | Retrofitted — complex generics | First-class decorator augmentation |
| Server start | `await server.start()` | `await fastify.listen()` |

---

### Side-by-Side: Core Primitives

#### Server Bootstrap

```ts
// Hapi
import Hapi from '@hapi/hapi';

const server = Hapi.server({
  port: 3000,
  host: '0.0.0.0',
  routes: {
    validate: {
      failAction: 'error',
    },
  },
});

await server.start();
```

```ts
// Fastify
import Fastify from 'fastify';

const fastify = Fastify({
  logger: true,
});

await fastify.listen({ port: 3000, host: '0.0.0.0' });
```

#### Basic Route

```ts
// Hapi
server.route({
  method: 'GET',
  path: '/users/{id}',
  handler: async (request, h) => {
    return { id: request.params.id };
  },
});
```

```ts
// Fastify
fastify.get('/users/:id', async (request) => {
  return { id: request.params.id };
});
```

**Key Points:**
- Hapi uses `{param}` syntax for path parameters; Fastify uses `:param`
- Hapi handlers receive the response toolkit `h` as the second argument; Fastify uses `reply`
- In Fastify, returning a value from an async handler sends the response — `reply.send()` is optional

#### Route Parameter Syntax: Full Translation Table

| Pattern | Hapi | Fastify |
|---|---|---|
| Named param | `{id}` | `:id` |
| Optional param | `{id?}` | No native optional — use two routes |
| Wildcard | `{path*}` | `*` (wildcard) |
| Multi-segment wildcard | `{path*2}` | `*` (captures all) |

```ts
// Hapi wildcard
server.route({ method: 'GET', path: '/files/{path*}', handler });

// Fastify wildcard
fastify.get('/files/*', handler);
```

---

### Plugin System Migration

Both frameworks use `server.register()` / `fastify.register()`, but the scoping rules differ.

#### Hapi Plugin

```ts
// Hapi plugin
import { Plugin } from '@hapi/hapi';

const usersPlugin: Plugin<{}> = {
  name: 'users',
  version: '1.0.0',
  register: async (server) => {
    server.route({ method: 'GET', path: '/users', handler: getAllUsers });
    server.route({ method: 'POST', path: '/users', handler: createUser });
  },
};

await server.register(usersPlugin);
```

```ts
// Fastify equivalent
import fp from 'fastify-plugin';
import { FastifyPluginAsync } from 'fastify';

const usersPlugin: FastifyPluginAsync = async (fastify) => {
  fastify.get('/users', getAllUsers);
  fastify.post('/users', createUser);
};

export default fp(usersPlugin, { name: 'users' });
```

**Key Points:**
- Hapi plugins declare `name` and `version` on the object; Fastify declares `name` in `fp` options
- Hapi has no encapsulation concept — all plugins share the server scope
- Fastify plugins are encapsulated by default; `fp` is required to make decorators and hooks visible outside the plugin
- Hapi's `dependencies` option maps directly to Fastify's `fp` `dependencies` option

#### Plugin Dependencies

```ts
// Hapi
const myPlugin = {
  name: 'myPlugin',
  dependencies: ['otherPlugin'],
  register: async (server) => { /* ... */ },
};
```

```ts
// Fastify
export default fp(myPlugin, {
  name: 'myPlugin',
  dependencies: ['otherPlugin'],
});
```

---

### Validation Migration: Joi → JSON Schema

Hapi integrates Joi natively in route options. Fastify uses JSON Schema with `ajv`. This is the most labor-intensive part of the migration for validation-heavy Hapi applications.

#### Hapi Route Validation

```ts
// Hapi with Joi
import Joi from 'joi';

server.route({
  method: 'POST',
  path: '/users',
  options: {
    validate: {
      payload: Joi.object({
        name: Joi.string().min(1).required(),
        email: Joi.string().email().required(),
        age: Joi.number().integer().min(18).optional(),
      }),
      query: Joi.object({
        notify: Joi.boolean().default(false),
      }),
    },
    response: {
      schema: Joi.object({
        id: Joi.string().required(),
        name: Joi.string().required(),
      }),
    },
  },
  handler: createUser,
});
```

```ts
// Fastify with JSON Schema
fastify.post('/users', {
  schema: {
    body: {
      type: 'object',
      required: ['name', 'email'],
      properties: {
        name: { type: 'string', minLength: 1 },
        email: { type: 'string', format: 'email' },
        age: { type: 'integer', minimum: 18 },
      },
      additionalProperties: false,
    },
    querystring: {
      type: 'object',
      properties: {
        notify: { type: 'boolean', default: false },
      },
    },
    response: {
      201: {
        type: 'object',
        properties: {
          id: { type: 'string' },
          name: { type: 'string' },
        },
      },
    },
  },
}, createUser);
```

#### Keeping Joi During Transition

If the validation surface is large, Joi schemas can be used in Fastify via a `preValidation` hook while JSON Schema is written incrementally:

```ts
// Transitional: Joi validation in preValidation hook
import Joi from 'joi';

const createUserSchema = Joi.object({
  name: Joi.string().min(1).required(),
  email: Joi.string().email().required(),
});

fastify.post('/users', {
  preValidation: async (request, reply) => {
    const { error } = createUserSchema.validate(request.body);
    if (error) {
      return reply.code(400).send({ error: error.message });
    }
  },
}, createUser);
```

[Inference] Running Joi validation in `preValidation` bypasses Fastify's native `ajv`-based validation and its associated performance optimizations. Exact performance impact depends on payload size, Joi schema complexity, and traffic volume.

---

### Authentication Migration

Hapi's authentication model — schemes and strategies — has no direct equivalent in Fastify. The migration maps to a combination of `@fastify/jwt` (or `@fastify/passport`) and scoped `onRequest` hooks.

#### Hapi Auth Scheme and Strategy

```ts
// Hapi — define scheme, register strategy, apply to route
server.auth.scheme('custom-jwt', (server, options) => ({
  authenticate: async (request, h) => {
    const token = request.headers.authorization?.split(' ')[1];
    if (!token) throw Boom.unauthorized('Missing token');
    try {
      const credentials = jwt.verify(token, options.secret);
      return h.authenticated({ credentials });
    } catch {
      throw Boom.unauthorized('Invalid token');
    }
  },
}));

server.auth.strategy('jwt', 'custom-jwt', { secret: JWT_SECRET });
server.auth.default('jwt'); // apply to all routes by default

// Opt out on public routes
server.route({
  method: 'GET',
  path: '/health',
  options: { auth: false },
  handler: () => ({ status: 'ok' }),
});
```

```ts
// Fastify equivalent — @fastify/jwt + scoped plugin
import fastifyJwt from '@fastify/jwt';
import fp from 'fastify-plugin';

// Register JWT plugin globally
await fastify.register(fastifyJwt, { secret: config.auth.jwtSecret });

// Public routes — no auth hook
fastify.get('/health', async () => ({ status: 'ok' }));

// Protected scope — auth hook applied inside
const protectedPlugin: FastifyPluginAsync = async (fastify) => {
  fastify.addHook('onRequest', async (request, reply) => {
    try {
      await request.jwtVerify();
    } catch {
      reply.code(401).send({ error: 'Unauthorized' });
    }
  });

  await fastify.register(import('./routes/users'), { prefix: '/users' });
  await fastify.register(import('./routes/orders'), { prefix: '/orders' });
};

await fastify.register(protectedPlugin);
```

#### Hapi `auth: { scope }` → Fastify `preHandler`

Hapi supports role/scope checks in route auth config. In Fastify this is a `preHandler` hook or a dedicated authorization function.

```ts
// Hapi scope check
server.route({
  method: 'DELETE',
  path: '/users/{id}',
  options: {
    auth: { strategy: 'jwt', scope: ['admin'] },
  },
  handler: deleteUser,
});
```

```ts
// Fastify preHandler scope check
const requireAdmin = async (request: FastifyRequest, reply: FastifyReply) => {
  if (request.user?.role !== 'admin') {
    return reply.code(403).send({ error: 'Forbidden' });
  }
};

fastify.delete('/users/:id', {
  preHandler: [requireAdmin],
}, deleteUser);
```

---

### Lifecycle Hook Translation

Hapi has a detailed 14-point request lifecycle. Fastify's lifecycle is shorter but covers the same ground.

| Hapi Lifecycle Point | Fastify Equivalent |
|---|---|
| `onPreAuth` | `onRequest` |
| `onCredentials` | `onRequest` (after jwtVerify) |
| `onPostAuth` | `preHandler` |
| `onPreHandler` | `preHandler` |
| `onPostHandler` | `onSend` |
| `onPreResponse` | `onSend` |
| `onPreStart` | code before `fastify.listen()` |
| `onPostStart` | code after `await fastify.listen()` |
| `onPreStop` | `onClose` hook |
| `onPostStop` | code after `await fastify.close()` |

#### Hapi Extension → Fastify Hook

```ts
// Hapi server extension
server.ext('onPreResponse', (request, h) => {
  const response = request.response;
  if (response instanceof Error) {
    // transform error response
  }
  return h.continue;
});
```

```ts
// Fastify equivalent
fastify.setErrorHandler((error, request, reply) => {
  // transform error response
  reply.code(error.statusCode ?? 500).send({ error: error.message });
});

// Or for non-error response transformation:
fastify.addHook('onSend', async (request, reply, payload) => {
  // inspect or modify payload before sending
  return payload;
});
```

---

### Boom Error Translation

Hapi applications commonly use `@hapi/boom` for HTTP-aware errors. Fastify has no built-in equivalent, but the pattern is replicated with domain error classes and `setErrorHandler`, or with the `http-errors` package.

#### Option A: Domain Error Classes (recommended — covered in service layer topic)

```ts
// Already covered: NotFoundError, ConflictError, ForbiddenError
// setErrorHandler maps them to status codes
```

#### Option B: `http-errors` as a Boom Analog

```bash
npm install http-errors
npm install --save-dev @types/http-errors
```

```ts
import createError from 'http-errors';

// In a route or service
throw createError(404, 'User not found');
throw createError(409, 'Email already in use');
throw createError(403, 'Insufficient permissions');
```

```ts
// setErrorHandler handles http-errors
import { isHttpError } from 'http-errors';

fastify.setErrorHandler((error, request, reply) => {
  if (isHttpError(error)) {
    return reply.code(error.statusCode).send({ error: error.message });
  }
  fastify.log.error(error);
  reply.code(500).send({ error: 'Internal Server Error' });
});
```

#### Boom → http-errors Reference

| Boom | http-errors |
|---|---|
| `Boom.notFound()` | `createError(404)` |
| `Boom.unauthorized()` | `createError(401)` |
| `Boom.forbidden()` | `createError(403)` |
| `Boom.conflict()` | `createError(409)` |
| `Boom.badRequest()` | `createError(400)` |
| `Boom.internal()` | `createError(500)` |
| `Boom.tooManyRequests()` | `createError(429)` |

---

### Server State: `server.app` → Decorators

Hapi uses `server.app` as a mutable shared state bag. Fastify uses explicit decorators.

```ts
// Hapi
server.app.dbPool = new Pool({ connectionString: DATABASE_URL });

// In a handler
const pool = request.server.app.dbPool;
```

```ts
// Fastify
fastify.decorate('pg', { pool: new Pool({ connectionString: config.database.url }) });

// In a handler — TypeScript-typed
const pool = fastify.pg.pool;
// or via request
request.server.pg.pool;
```

---

### Response Toolkit → `reply`

```ts
// Hapi response toolkit
return h.response({ id: user.id }).code(201);
return h.response().code(204);
return h.redirect('/new-path').code(301);
return h.continue; // pass to next lifecycle step
```

```ts
// Fastify reply
return reply.code(201).send({ id: user.id });
return reply.code(204).send();
return reply.redirect('/new-path', 301);
// No h.continue equivalent — hooks return implicitly
```

---

### Caching Migration

Hapi has built-in server-side caching via `catbox`. Fastify has no equivalent built-in. Caching is handled externally.

```ts
// Hapi — server method with catbox caching
server.method('getUser', async (id) => {
  return db.query('SELECT * FROM users WHERE id = $1', [id]);
}, {
  cache: {
    expiresIn: 60_000,
    generateTimeout: 5_000,
  },
});
```

```ts
// Fastify — manual caching via Redis or @fastify/caching
import fastifyRedis from '@fastify/redis';

await fastify.register(fastifyRedis, { url: config.redis.url });

fastify.get('/users/:id', async (request) => {
  const { id } = request.params;
  const cached = await fastify.redis.get(`user:${id}`);
  if (cached) return JSON.parse(cached);

  const user = await fastify.repositories.user.findById(id);
  await fastify.redis.set(`user:${id}`, JSON.stringify(user), 'EX', 60);
  return user;
});
```

---

### Plugin Ecosystem Mapping

| Hapi Plugin | Fastify Equivalent |
|---|---|
| `@hapi/joi` (validation) | JSON Schema + `ajv` (native) |
| `@hapi/boom` | `http-errors` or domain error classes |
| `@hapi/inert` (static files) | `@fastify/static` |
| `@hapi/vision` (templates) | `@fastify/view` |
| `@hapi/cookie` | `@fastify/cookie` |
| `hapi-auth-jwt2` | `@fastify/jwt` |
| `@hapi/basic` auth | `@fastify/basic-auth` |
| `hapi-swagger` | `@fastify/swagger` + `@fastify/swagger-ui` |
| `hapi-rate-limiter` | `@fastify/rate-limit` |
| `hapi-pino` | Built-in pino logger |
| `catbox` (caching) | `@fastify/redis` + manual or `@fastify/caching` |
| `@hapi/wreck` (HTTP client) | `undici`, `got`, or `axios` |

---

### Incremental Migration Strategy

Because both Hapi and Fastify are plugin-first, routes can be migrated plugin by plugin behind a reverse proxy.

```
Phase 1 — Infrastructure
  [ ] Set up Fastify entry point alongside Hapi server
  [ ] Migrate config loading to env-schema or Zod
  [ ] Migrate database/Redis plugin registration
  [ ] Migrate decorator equivalents of server.app state

Phase 2 — Authentication
  [ ] Replace auth scheme/strategy with @fastify/jwt
  [ ] Implement scoped protected plugin
  [ ] Translate auth scope checks to preHandler hooks

Phase 3 — Validation
  [ ] Write JSON Schema equivalents for Joi schemas
  [ ] Start with the lowest-complexity routes
  [ ] Use Joi in preValidation as a transitional shim

Phase 4 — Routes (domain by domain)
  [ ] Translate {param} → :param in all paths
  [ ] Replace h.response() → reply.send() or return value
  [ ] Replace Boom → http-errors or domain errors

Phase 5 — Error Handling
  [ ] Implement setErrorHandler to replace onPreResponse error logic
  [ ] Remove all Boom imports

Phase 6 — Caching
  [ ] Replace catbox server methods with Redis-backed manual caching
  [ ] Or defer — caching can remain in Hapi longer than routes

Phase 7 — Decommission Hapi
  [ ] Remove @hapi/* dependencies
  [ ] Remove reverse proxy routing split
  [ ] Consolidate to Fastify-only entry point
```

---

### Architecture Diagram

<svg viewBox="0 0 740 490" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="12">
  <defs>
    <marker id="arr" markerWidth="8" markerHeight="8" refX="6" refY="3" orient="auto">
      <path d="M0,0 L0,6 L8,3 z" fill="#4a90d9"/>
    </marker>
    <marker id="arrG" markerWidth="8" markerHeight="8" refX="6" refY="3" orient="auto">
      <path d="M0,0 L0,6 L8,3 z" fill="#4caf77"/>
    </marker>
    <marker id="arrO" markerWidth="8" markerHeight="8" refX="6" refY="3" orient="auto">
      <path d="M0,0 L0,6 L8,3 z" fill="#f0a020"/>
    </marker>
    <marker id="arrR" markerWidth="8" markerHeight="8" refX="6" refY="3" orient="auto">
      <path d="M0,0 L0,6 L8,3 z" fill="#e05050"/>
    </marker>
  </defs>

  <!-- Title row: concepts -->
  <text x="185" y="22" text-anchor="middle" fill="#e05050" font-size="11">Hapi Concept</text>
  <text x="555" y="22" text-anchor="middle" fill="#4caf77" font-size="11">Fastify Equivalent</text>

  <!-- Row 1: Plugin -->
  <rect x="20" y="35" width="330" height="44" rx="6" fill="#3a1a1a" stroke="#e05050" stroke-width="1.2"/>
  <text x="90" y="55" text-anchor="middle" fill="#f08080">Plugin</text>
  <text x="235" y="55" text-anchor="middle" fill="#c06060" font-size="10">{ name, version, register }</text>
  <text x="235" y="70" text-anchor="middle" fill="#c06060" font-size="10">all plugins share server scope</text>

  <line x1="350" y1="57" x2="390" y2="57" stroke="#f0a020" stroke-width="1.5" marker-end="url(#arrO)"/>

  <rect x="390" y="35" width="330" height="44" rx="6" fill="#0d2213" stroke="#4caf77" stroke-width="1.2"/>
  <text x="460" y="55" text-anchor="middle" fill="#b8f0cc">Plugin + fp()</text>
  <text x="590" y="55" text-anchor="middle" fill="#80c8a0" font-size="10">FastifyPluginAsync + fastify-plugin</text>
  <text x="590" y="70" text-anchor="middle" fill="#80c8a0" font-size="10">encapsulated by default; fp escapes scope</text>

  <!-- Row 2: Auth -->
  <rect x="20" y="95" width="330" height="44" rx="6" fill="#3a1a1a" stroke="#e05050" stroke-width="1.2"/>
  <text x="90" y="115" text-anchor="middle" fill="#f08080">Auth</text>
  <text x="235" y="115" text-anchor="middle" fill="#c06060" font-size="10">server.auth.scheme() + .strategy()</text>
  <text x="235" y="130" text-anchor="middle" fill="#c06060" font-size="10">server.auth.default() / route auth: false</text>

  <line x1="350" y1="117" x2="390" y2="117" stroke="#f0a020" stroke-width="1.5" marker-end="url(#arrO)"/>

  <rect x="390" y="95" width="330" height="44" rx="6" fill="#0d2213" stroke="#4caf77" stroke-width="1.2"/>
  <text x="460" y="115" text-anchor="middle" fill="#b8f0cc">Auth</text>
  <text x="590" y="115" text-anchor="middle" fill="#80c8a0" font-size="10">@fastify/jwt + onRequest hook</text>
  <text x="590" y="130" text-anchor="middle" fill="#80c8a0" font-size="10">scoped plugin for protected routes</text>

  <!-- Row 3: Validation -->
  <rect x="20" y="155" width="330" height="44" rx="6" fill="#3a1a1a" stroke="#e05050" stroke-width="1.2"/>
  <text x="90" y="175" text-anchor="middle" fill="#f08080">Validation</text>
  <text x="235" y="175" text-anchor="middle" fill="#c06060" font-size="10">Joi — options.validate.payload/query</text>
  <text x="235" y="190" text-anchor="middle" fill="#c06060" font-size="10">options.response.schema</text>

  <line x1="350" y1="177" x2="390" y2="177" stroke="#f0a020" stroke-width="1.5" marker-end="url(#arrO)"/>

  <rect x="390" y="155" width="330" height="44" rx="6" fill="#0d2213" stroke="#4caf77" stroke-width="1.2"/>
  <text x="460" y="175" text-anchor="middle" fill="#b8f0cc">Validation</text>
  <text x="590" y="175" text-anchor="middle" fill="#80c8a0" font-size="10">JSON Schema — schema.body/querystring</text>
  <text x="590" y="190" text-anchor="middle" fill="#80c8a0" font-size="10">schema.response — drives serialization</text>

  <!-- Row 4: Errors -->
  <rect x="20" y="215" width="330" height="44" rx="6" fill="#3a1a1a" stroke="#e05050" stroke-width="1.2"/>
  <text x="90" y="235" text-anchor="middle" fill="#f08080">Errors</text>
  <text x="235" y="235" text-anchor="middle" fill="#c06060" font-size="10">Boom.notFound() / Boom.forbidden()</text>
  <text x="235" y="250" text-anchor="middle" fill="#c06060" font-size="10">onPreResponse extension</text>

  <line x1="350" y1="237" x2="390" y2="237" stroke="#f0a020" stroke-width="1.5" marker-end="url(#arrO)"/>

  <rect x="390" y="215" width="330" height="44" rx="6" fill="#0d2213" stroke="#4caf77" stroke-width="1.2"/>
  <text x="460" y="235" text-anchor="middle" fill="#b8f0cc">Errors</text>
  <text x="590" y="235" text-anchor="middle" fill="#80c8a0" font-size="10">http-errors or domain error classes</text>
  <text x="590" y="250" text-anchor="middle" fill="#80c8a0" font-size="10">setErrorHandler — scoped or global</text>

  <!-- Row 5: State -->
  <rect x="20" y="275" width="330" height="44" rx="6" fill="#3a1a1a" stroke="#e05050" stroke-width="1.2"/>
  <text x="90" y="295" text-anchor="middle" fill="#f08080">Server State</text>
  <text x="235" y="295" text-anchor="middle" fill="#c06060" font-size="10">server.app.myValue = x</text>
  <text x="235" y="310" text-anchor="middle" fill="#c06060" font-size="10">untyped mutable bag</text>

  <line x1="350" y1="297" x2="390" y2="297" stroke="#f0a020" stroke-width="1.5" marker-end="url(#arrO)"/>

  <rect x="390" y="275" width="330" height="44" rx="6" fill="#0d2213" stroke="#4caf77" stroke-width="1.2"/>
  <text x="460" y="295" text-anchor="middle" fill="#b8f0cc">Decorators</text>
  <text x="590" y="295" text-anchor="middle" fill="#80c8a0" font-size="10">fastify.decorate('myValue', x)</text>
  <text x="590" y="310" text-anchor="middle" fill="#80c8a0" font-size="10">TypeScript-augmented FastifyInstance</text>

  <!-- Row 6: Caching -->
  <rect x="20" y="335" width="330" height="44" rx="6" fill="#3a1a1a" stroke="#e05050" stroke-width="1.2"/>
  <text x="90" y="355" text-anchor="middle" fill="#f08080">Caching</text>
  <text x="235" y="355" text-anchor="middle" fill="#c06060" font-size="10">catbox — server.method() + cache config</text>
  <text x="235" y="370" text-anchor="middle" fill="#c06060" font-size="10">built-in, strategy-based</text>

  <line x1="350" y1="357" x2="390" y2="357" stroke="#f0a020" stroke-width="1.5" marker-end="url(#arrO)"/>

  <rect x="390" y="335" width="330" height="44" rx="6" fill="#0d2213" stroke="#4caf77" stroke-width="1.2"/>
  <text x="460" y="355" text-anchor="middle" fill="#b8f0cc">External Cache</text>
  <text x="590" y="355" text-anchor="middle" fill="#80c8a0" font-size="10">@fastify/redis — manual get/set</text>
  <text x="590" y="370" text-anchor="middle" fill="#80c8a0" font-size="10">or @fastify/caching</text>

  <!-- Row 7: Response -->
  <rect x="20" y="395" width="330" height="44" rx="6" fill="#3a1a1a" stroke="#e05050" stroke-width="1.2"/>
  <text x="90" y="415" text-anchor="middle" fill="#f08080">Response</text>
  <text x="235" y="415" text-anchor="middle" fill="#c06060" font-size="10">h.response(data).code(201)</text>
  <text x="235" y="430" text-anchor="middle" fill="#c06060" font-size="10">h.redirect() / h.continue</text>

  <line x1="350" y1="417" x2="390" y2="417" stroke="#f0a020" stroke-width="1.5" marker-end="url(#arrO)"/>

  <rect x="390" y="395" width="330" height="44" rx="6" fill="#0d2213" stroke="#4caf77" stroke-width="1.2"/>
  <text x="460" y="415" text-anchor="middle" fill="#b8f0cc">reply</text>
  <text x="590" y="415" text-anchor="middle" fill="#80c8a0" font-size="10">reply.code(201).send(data)</text>
  <text x="590" y="430" text-anchor="middle" fill="#80c8a0" font-size="10">reply.redirect() / return value</text>

  <!-- Legend -->
  <line x1="260" y1="460" x2="310" y2="460" stroke="#f0a020" stroke-width="1.5" marker-end="url(#arrO)"/>
  <text x="325" y="464" fill="#f0a020" font-size="10">maps to</text>
</svg>

---

### Common Mistakes During Migration

#### Using `{param}` Syntax in Fastify Routes

```ts
// Wrong — Hapi syntax, not recognized by Fastify
fastify.get('/users/{id}', handler);
```

```ts
// Correct
fastify.get('/users/:id', handler);
```

Fastify silently treats `{id}` as a literal path segment, not a parameter. The route will not match `/users/123`. [Inference] No compile-time error is produced — this surfaces as a runtime 404, which can be difficult to trace if many routes are migrated at once.

#### Expecting All Plugins to Share Scope

Hapi plugins all operate on the same server instance. In Fastify, a plugin registered without `fp` is encapsulated — its decorators, hooks, and routes are not visible outside its scope.

```ts
// Hapi mental model carried over — wrong
const dbPlugin: FastifyPluginAsync = async (fastify) => {
  fastify.decorate('db', pool);
};
fastify.register(dbPlugin);
fastify.register(routesPlugin); // routesPlugin cannot see fastify.db
```

```ts
// Correct — use fp to escape encapsulation
export default fp(dbPlugin, { name: 'db' });
```

#### Returning `h.continue` in Fastify Hooks

Hapi lifecycle extensions return `h.continue` to pass control to the next step. Fastify hooks return implicitly — returning from a hook (or doing nothing) allows the lifecycle to proceed.

```ts
// Hapi habit — wrong in Fastify
fastify.addHook('onRequest', async (request, reply) => {
  request.startTime = Date.now();
  return reply.continue; // undefined in Fastify — causes an error
});
```

```ts
// Correct — just return or do nothing
fastify.addHook('onRequest', async (request) => {
  request.startTime = Date.now();
  // implicit return — lifecycle continues
});
```

#### Throwing Boom in Fastify

```ts
// Wrong — Boom errors are not HTTP-aware in Fastify's setErrorHandler
throw Boom.notFound('User not found');
// setErrorHandler receives a generic Error; statusCode is not read
```

```ts
// Correct — use http-errors or domain error classes
import createError from 'http-errors';
throw createError(404, 'User not found');
```

---

**Related Topics:**
- `@fastify/swagger` — migrating hapi-swagger OpenAPI documentation
- `@fastify/passport` — migrating hapi-auth-bearer-token or complex multi-strategy auth
- Scoped plugin encapsulation and `fastify-plugin` in depth
- `@fastify/view` — migrating `@hapi/vision` template rendering
- `@fastify/cookie` and `@fastify/session` — migrating `@hapi/cookie`
- Fastify hook execution order — full lifecycle reference
- Integration testing Fastify with `fastify.inject()` replacing Hapi's `server.inject()`