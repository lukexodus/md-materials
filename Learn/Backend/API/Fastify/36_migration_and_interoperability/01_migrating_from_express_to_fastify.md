## Migrating from Express to Fastify

Migrating an existing Express application to Fastify is a structural and conceptual shift, not just a syntax substitution. Express and Fastify share HTTP fundamentals but differ in plugin architecture, middleware model, schema handling, and error propagation. This document covers the full migration path — from mental model differences to route-by-route translation to incremental strategies for production systems.

---

### Mental Model Differences

Before touching code, understanding where the two frameworks diverge prevents architectural mistakes during migration.

| Concern | Express | Fastify |
|---|---|---|
| Middleware | `app.use()` — linear chain | Hooks — lifecycle-aware, scoped |
| Plugin system | None native — manual requires | Encapsulated plugin tree with `fp` |
| Schema validation | Manual or middleware (Joi, Yup) | Native JSON Schema via `ajv` |
| Serialization | `res.json()` — always serializes | Schema-driven serializer — faster, explicit |
| Error handling | `(err, req, res, next)` 4-arg middleware | `setErrorHandler` per scope |
| TypeScript | Retrofitted via `@types/express` | First-class, decorator-augmented |
| Async errors | Must be caught and passed to `next(err)` | Native — thrown errors propagate automatically |
| Request body | `express.json()` middleware | Built-in via `Content-Type` parser |

---

### Side-by-Side: Core Primitives

#### Application Bootstrap

```ts
// Express
import express from 'express';
const app = express();
app.use(express.json());
app.listen(3000, () => console.log('listening'));
```

```ts
// Fastify
import Fastify from 'fastify';
const fastify = Fastify({ logger: true });
// JSON body parsing is built in — no middleware needed
await fastify.listen({ port: 3000, host: '0.0.0.0' });
```

#### Basic Route

```ts
// Express
app.get('/users/:id', (req, res) => {
  res.status(200).json({ id: req.params.id });
});
```

```ts
// Fastify
fastify.get('/users/:id', async (request, reply) => {
  return { id: request.params.id };
  // returning a value is equivalent to reply.send()
});
```

#### Async Route Error Handling

```ts
// Express — async errors must be caught manually
app.get('/users/:id', async (req, res, next) => {
  try {
    const user = await userService.getById(req.params.id);
    res.json(user);
  } catch (err) {
    next(err); // must call next(err) or error is swallowed
  }
});
```

```ts
// Fastify — thrown errors propagate automatically
fastify.get('/users/:id', async (request) => {
  return userService.getById(request.params.id);
  // if getById throws, Fastify catches and routes to setErrorHandler
});
```

This is one of the most significant ergonomic improvements. In Express, forgetting `next(err)` inside an async handler silently hangs the request. [Inference] Fastify wraps async route handlers such that rejections are caught automatically, though this behavior depends on the Fastify version — verify against the installed version's changelog.

#### Sending Responses

```ts
// Express
res.status(201).json({ id: user.id });
res.status(404).send('Not found');
res.setHeader('X-Custom', 'value').json(data);
```

```ts
// Fastify
reply.code(201).send({ id: user.id });
reply.code(404).send('Not found');
reply.header('X-Custom', 'value').send(data);

// Or just return the value (200 assumed, Content-Type inferred)
return { id: user.id };
```

---

### Middleware to Hooks Migration

Express middleware is a flat, ordered chain. Fastify hooks are lifecycle events that fire at specific points in the request/response cycle, and they are scoped to the plugin that registers them.

#### Lifecycle Comparison

```
Express:                         Fastify:
─────────────────────────        ────────────────────────────────
app.use(loggerMiddleware)    →    onRequest hook
app.use(authMiddleware)      →    onRequest or preHandler hook
app.use(express.json())      →    addContentTypeParser (built-in)
app.use(validationMiddleware)→    preValidation hook (or schema)
route handler                →    route handler
app.use(errorMiddleware)     →    setErrorHandler
```

#### Common Middleware Translations

**Morgan (HTTP logger):**

```ts
// Express
import morgan from 'morgan';
app.use(morgan('combined'));
```

```ts
// Fastify — pino is the built-in logger; no separate HTTP logger needed
const fastify = Fastify({ logger: { level: 'info' } });
// request/response logging is automatic when logger is enabled
```

**CORS:**

```ts
// Express
import cors from 'cors';
app.use(cors({ origin: 'https://example.com' }));
```

```ts
// Fastify
import fastifyCors from '@fastify/cors';
await fastify.register(fastifyCors, { origin: 'https://example.com' });
```

**Helmet (security headers):**

```ts
// Express
import helmet from 'helmet';
app.use(helmet());
```

```ts
// Fastify
import fastifyHelmet from '@fastify/helmet';
await fastify.register(fastifyHelmet);
```

**Rate limiting:**

```ts
// Express
import rateLimit from 'express-rate-limit';
app.use(rateLimit({ windowMs: 60_000, max: 100 }));
```

```ts
// Fastify
import fastifyRateLimit from '@fastify/rate-limit';
await fastify.register(fastifyRateLimit, { max: 100, timeWindow: '1 minute' });
```

**Authentication (JWT):**

```ts
// Express — manual middleware
app.use('/protected', (req, res, next) => {
  const token = req.headers.authorization?.split(' ')[1];
  if (!token) return res.status(401).json({ error: 'Unauthorized' });
  try {
    req.user = jwt.verify(token, SECRET);
    next();
  } catch {
    res.status(401).json({ error: 'Invalid token' });
  }
});
```

```ts
// Fastify — @fastify/jwt + preHandler hook or onRequest hook
import fastifyJwt from '@fastify/jwt';

await fastify.register(fastifyJwt, { secret: config.auth.jwtSecret });

fastify.addHook('onRequest', async (request, reply) => {
  try {
    await request.jwtVerify();
  } catch {
    reply.code(401).send({ error: 'Unauthorized' });
  }
});
```

Scope the hook to only protected routes by registering it inside a scoped plugin:

```ts
// src/plugins/auth-scope.plugin.ts
const authScopePlugin: FastifyPluginAsync = async (fastify) => {
  fastify.addHook('onRequest', async (request, reply) => {
    try {
      await request.jwtVerify();
    } catch {
      reply.code(401).send({ error: 'Unauthorized' });
    }
  });

  // All routes registered inside this plugin are protected
  await fastify.register(import('../routes/users'), { prefix: '/users' });
  await fastify.register(import('../routes/orders'), { prefix: '/orders' });
};
```

Public routes are registered outside this plugin and are unaffected.

---

### Error Handling Migration

```ts
// Express — 4-argument error middleware
app.use((err, req, res, next) => {
  if (err.name === 'ValidationError') {
    return res.status(422).json({ error: err.message });
  }
  res.status(500).json({ error: 'Internal Server Error' });
});
```

```ts
// Fastify — setErrorHandler
fastify.setErrorHandler((error, request, reply) => {
  if (error.name === 'ValidationError') {
    return reply.code(422).send({ error: error.message });
  }
  fastify.log.error(error);
  reply.code(500).send({ error: 'Internal Server Error' });
});
```

**Key Points:**
- `setErrorHandler` is scoped — plugins can define their own error handlers
- Fastify's built-in schema validation errors arrive here with `statusCode: 400` already set; they can be intercepted and reformatted
- The global `setErrorHandler` is the catch-all for errors not handled by a scoped handler

---

### Request and Response Object Differences

```ts
// Express
req.params.id        // route parameter
req.query.page       // query string
req.body.name        // parsed body
req.headers['x-api-key']
res.locals.user      // per-request state

// Fastify
request.params.id
request.query.page
request.body.name
request.headers['x-api-key']
request.user         // via decorator augmentation (no res.locals equivalent)
```

Express's `res.locals` has no direct Fastify equivalent. Per-request state is instead attached to the `request` object via TypeScript augmentation:

```ts
// src/@types/fastify/index.d.ts
declare module 'fastify' {
  interface FastifyRequest {
    user?: AuthenticatedUser;
    requestStartTime?: number;
  }
}
```

Set values in hooks:

```ts
fastify.addHook('onRequest', async (request) => {
  request.requestStartTime = Date.now();
});
```

---

### Router Migration

Express routers map directly to Fastify plugins.

```ts
// Express router
// src/routes/users.router.ts
import { Router } from 'express';
const router = Router();

router.get('/', getAllUsers);
router.get('/:id', getUserById);
router.post('/', createUser);
router.put('/:id', updateUser);
router.delete('/:id', deleteUser);

export default router;
```

```ts
// app.ts
app.use('/users', usersRouter);
```

```ts
// Fastify plugin equivalent
// src/routes/users/index.ts
import { FastifyPluginAsync } from 'fastify';

const usersPlugin: FastifyPluginAsync = async (fastify) => {
  fastify.get('/', getAllUsersHandler);
  fastify.get('/:id', getUserByIdHandler);
  fastify.post('/', createUserHandler);
  fastify.put('/:id', updateUserHandler);
  fastify.delete('/:id', deleteUserHandler);
};

export default usersPlugin;
```

```ts
// app.ts
await fastify.register(usersPlugin, { prefix: '/users' });
```

---

### Adding Schema Validation

This is additive during migration. Express routes without validation continue to work in Fastify without schemas. Add schemas incrementally.

```ts
// Express — no native validation; typically Joi or manual checks
app.post('/users', (req, res) => {
  const { name, email } = req.body;
  if (!name || !email) return res.status(400).json({ error: 'name and email required' });
  // ...
});
```

```ts
// Fastify — schema-driven validation
const createUserSchema = {
  body: {
    type: 'object',
    required: ['name', 'email'],
    properties: {
      name: { type: 'string', minLength: 1 },
      email: { type: 'string', format: 'email' },
    },
    additionalProperties: false,
  },
  response: {
    201: {
      type: 'object',
      properties: {
        id: { type: 'string' },
        name: { type: 'string' },
        email: { type: 'string' },
      },
    },
  },
} as const;

fastify.post('/users', { schema: createUserSchema }, async (request, reply) => {
  const user = await fastify.services.user.create(request.body);
  return reply.code(201).send(user);
});
```

---

### Using Express Middleware in Fastify During Migration

For middleware that has no Fastify equivalent yet, `@fastify/express` allows using Express middleware inside Fastify during a transitional period.

```bash
npm install @fastify/express
```

```ts
import fastifyExpress from '@fastify/express';

await fastify.register(fastifyExpress);

// Now Express middleware can be used temporarily
fastify.use(someExpressMiddleware());
```

**Key Points:**
- `@fastify/express` adds overhead — it is a compatibility shim, not a long-term architecture
- [Inference] Performance characteristics of middleware run through `@fastify/express` will differ from native Fastify hooks; exact overhead depends on the middleware and traffic patterns
- Remove it as each middleware is replaced by a native Fastify equivalent

---

### Incremental Migration Strategy

For production systems, a full cutover is high risk. An incremental approach routes traffic progressively.

#### Phase 1: Run Express and Fastify Side by Side

A reverse proxy (Nginx, Caddy) routes requests by path prefix. New routes are built in Fastify; existing routes remain in Express until migrated.

```
Client
  │
  ▼
Nginx
  ├── /api/v2/*  →  Fastify (new routes)
  └── /api/v1/*  →  Express (existing routes)
```

#### Phase 2: Migrate Route Groups

Migrate one router or domain at a time. Start with low-risk, low-traffic routes. Validate in staging before production cutover.

```
Migration order (example):
  1. /api/v1/health         → trivial, no business logic
  2. /api/v1/products       → read-heavy, low complexity
  3. /api/v1/users          → moderate complexity
  4. /api/v1/orders         → complex, transaction-heavy — migrate last
```

#### Phase 3: Migrate Middleware

For each Express middleware, identify the Fastify equivalent:

```
express.json()         → built-in
morgan                 → pino (built-in logger)
helmet                 → @fastify/helmet
cors                   → @fastify/cors
express-rate-limit     → @fastify/rate-limit
passport               → @fastify/passport
express-session        → @fastify/session
multer                 → @fastify/multipart
serve-static           → @fastify/static
compression            → @fastify/compress
```

#### Phase 4: Add Schemas

Once routes are migrated and stable, add JSON Schema validation and serialization schemas to each route. This is the highest-leverage performance and correctness improvement.

#### Phase 5: Decommission Express

When all routes, middleware, and error handling are migrated, remove the Express dependency, `@fastify/express`, and the Nginx routing split.

---

### Migration Checklist

```
[ ] Install Fastify and create app entry point
[ ] Register @fastify/env or env-schema for config
[ ] Migrate infrastructure plugins (DB pool, Redis)
[ ] Replace express.json() — no action needed
[ ] Register @fastify/cors, @fastify/helmet, @fastify/rate-limit
[ ] Migrate error middleware → setErrorHandler
[ ] Migrate routers → scoped Fastify plugins
[ ] Replace res.locals → request decorator augmentation
[ ] Migrate auth middleware → onRequest or preHandler hook
[ ] Add JSON Schema to each route (additive, can be phased)
[ ] Replace manual async try/catch/next(err) → plain throws
[ ] Remove @fastify/express shim
[ ] Remove express dependency
[ ] Update TypeScript types (@types/express → Fastify augmentation)
[ ] Run integration tests against migrated routes
[ ] Load test migrated routes vs Express baseline
```

---

### Architecture Diagram

<svg viewBox="0 0 740 520" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="12">
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
  </defs>

  <!-- Phase label -->
  <text x="370" y="22" text-anchor="middle" fill="#888" font-size="11">Incremental Migration — Traffic Split</text>

  <!-- Client -->
  <rect x="300" y="35" width="140" height="44" rx="8" fill="#1e3a5f" stroke="#4a90d9" stroke-width="1.5"/>
  <text x="370" y="62" text-anchor="middle" fill="#c8e0ff">Client / Load Balancer</text>
  <line x1="370" y1="79" x2="370" y2="110" stroke="#4a90d9" stroke-width="1.4" marker-end="url(#arr)"/>

  <!-- Proxy -->
  <rect x="270" y="110" width="200" height="44" rx="8" fill="#2a1a3a" stroke="#9060d0" stroke-width="1.5"/>
  <text x="370" y="137" text-anchor="middle" fill="#c090f0">Nginx / Reverse Proxy</text>

  <!-- Split arrows -->
  <line x1="270" y1="132" x2="170" y2="200" stroke="#f0a020" stroke-width="1.4" marker-end="url(#arrO)"/>
  <line x1="470" y1="132" x2="570" y2="200" stroke="#4caf77" stroke-width="1.4" marker-end="url(#arrG)"/>

  <!-- Express box -->
  <rect x="50" y="200" width="220" height="100" rx="8" fill="#3a1a1a" stroke="#e05050" stroke-width="1.5"/>
  <text x="160" y="222" text-anchor="middle" fill="#f08080">Express (legacy)</text>
  <text x="160" y="242" text-anchor="middle" fill="#c06060" font-size="10">/api/v1/* (being migrated)</text>
  <text x="160" y="260" text-anchor="middle" fill="#c06060" font-size="10">app.use() middleware chain</text>
  <text x="160" y="278" text-anchor="middle" fill="#c06060" font-size="10">manual async error handling</text>

  <!-- Fastify box -->
  <rect x="470" y="200" width="220" height="100" rx="8" fill="#0d2213" stroke="#4caf77" stroke-width="1.5"/>
  <text x="580" y="222" text-anchor="middle" fill="#b8f0cc">Fastify (target)</text>
  <text x="580" y="242" text-anchor="middle" fill="#80c8a0" font-size="10">/api/v2/* (new routes)</text>
  <text x="580" y="260" text-anchor="middle" fill="#80c8a0" font-size="10">plugin tree + hooks</text>
  <text x="580" y="278" text-anchor="middle" fill="#80c8a0" font-size="10">schema validation + pino</text>

  <!-- Shared DB -->
  <rect x="270" y="360" width="200" height="50" rx="8" fill="#1a1a0d" stroke="#8a8a3a" stroke-width="1.5"/>
  <text x="370" y="383" text-anchor="middle" fill="#e0e090">Shared Database</text>
  <text x="370" y="400" text-anchor="middle" fill="#a0a060" font-size="10">PostgreSQL / Redis / etc.</text>

  <line x1="160" y1="300" x2="310" y2="360" stroke="#e05050" stroke-width="1.2" stroke-dasharray="4,3" marker-end="url(#arr)"/>
  <line x1="580" y1="300" x2="430" y2="360" stroke="#4caf77" stroke-width="1.2" stroke-dasharray="4,3" marker-end="url(#arr)"/>

  <!-- Migration arrow -->
  <line x1="270" y1="250" x2="470" y2="250" stroke="#f0a020" stroke-width="2" stroke-dasharray="6,4" marker-end="url(#arrO)"/>
  <text x="370" y="242" text-anchor="middle" fill="#f0a020" font-size="10">migrating route by route</text>

  <!-- Phase boxes -->
  <rect x="50" y="430" width="150" height="70" rx="6" fill="#1a1a2a" stroke="#5050a0" stroke-width="1"/>
  <text x="125" y="450" text-anchor="middle" fill="#a0a0e0" font-size="10">Phase 1–2</text>
  <text x="125" y="467" text-anchor="middle" fill="#7070c0" font-size="10">Side-by-side</text>
  <text x="125" y="484" text-anchor="middle" fill="#7070c0" font-size="10">route migration</text>

  <rect x="220" y="430" width="150" height="70" rx="6" fill="#1a1a2a" stroke="#5050a0" stroke-width="1"/>
  <text x="295" y="450" text-anchor="middle" fill="#a0a0e0" font-size="10">Phase 3</text>
  <text x="295" y="467" text-anchor="middle" fill="#7070c0" font-size="10">Middleware →</text>
  <text x="295" y="484" text-anchor="middle" fill="#7070c0" font-size="10">Hooks + plugins</text>

  <rect x="390" y="430" width="150" height="70" rx="6" fill="#1a1a2a" stroke="#5050a0" stroke-width="1"/>
  <text x="465" y="450" text-anchor="middle" fill="#a0a0e0" font-size="10">Phase 4</text>
  <text x="465" y="467" text-anchor="middle" fill="#7070c0" font-size="10">Add JSON Schema</text>
  <text x="465" y="484" text-anchor="middle" fill="#7070c0" font-size="10">validation</text>

  <rect x="560" y="430" width="150" height="70" rx="6" fill="#0d2213" stroke="#4caf77" stroke-width="1"/>
  <text x="635" y="450" text-anchor="middle" fill="#b8f0cc" font-size="10">Phase 5</text>
  <text x="635" y="467" text-anchor="middle" fill="#80c8a0" font-size="10">Decommission</text>
  <text x="635" y="484" text-anchor="middle" fill="#80c8a0" font-size="10">Express</text>
</svg>

---

### Common Mistakes During Migration

#### Forgetting That Returning a Value Sends the Response

```ts
// Express habit carried over — works but redundant
fastify.get('/ping', async (request, reply) => {
  reply.send({ pong: true });
  return; // unnecessary
});
```

```ts
// Fastify idiomatic
fastify.get('/ping', async () => ({ pong: true }));
```

#### Using `reply.send()` After Returning

```ts
// Bug — double send
fastify.get('/ping', async (request, reply) => {
  reply.send({ pong: true });
  return { pong: true }; // sends again — Fastify will log a warning
});
```

Pick one: either `return value` or `reply.send(value)`, never both.

#### Treating Plugins as Express Middleware

```ts
// Wrong mental model — registering a plugin expecting it to behave like app.use()
fastify.register(somePlugin); // encapsulated by default
fastify.get('/route', handler); // handler may not see somePlugin's decorators
```

Without `fp`, plugins are encapsulated. Use `fp` for shared resources, or register routes inside the plugin that provides their dependencies.

#### Not Wrapping Shared Plugins with `fastify-plugin`

Any plugin that adds a decorator intended for the whole application must be wrapped with `fp`. Without it, the decorator is invisible outside the plugin's scope.

---

**Related Topics:**
- Plugin encapsulation and `fastify-plugin` in depth
- Hook lifecycle — `onRequest`, `preHandler`, `onSend`, `onResponse` execution order
- `@fastify/passport` for migrating Passport.js authentication strategies
- `@fastify/session` and `@fastify/secure-session` for session migration
- `@fastify/multipart` for migrating Multer file upload handling
- Performance benchmarking — comparing Express vs Fastify under load after migration
- TypeScript augmentation patterns for `FastifyRequest` and `FastifyInstance`