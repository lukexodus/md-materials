## Dependency Injection Approaches in Fastify

Dependency injection (DI) is the practice of supplying a component's dependencies from outside rather than having the component construct them itself. In Fastify applications, several approaches exist — from manual constructor injection to full DI containers — each with distinct tradeoffs.

---

### Why DI Matters in Fastify Applications

Without DI, components instantiate their own dependencies:

```ts
// Without DI — tightly coupled
export class UserService {
  private readonly userRepo = new PgUserRepository(new Pool(config.db));
  private readonly mailer = new NodemailerService(config.smtp);
}
```

This makes testing difficult, swapping implementations impossible without code changes, and initialization order opaque.

With DI, dependencies are declared and supplied externally:

```ts
// With DI — loosely coupled
export class UserService {
  constructor(
    private readonly userRepo: UserRepository,
    private readonly mailer: MailerService
  ) {}
}
```

---

### Approach 1: Manual Constructor Injection

The simplest form. Dependencies are instantiated once and passed explicitly through constructors during application startup.

```ts
// src/app.ts

import Fastify from 'fastify';
import { Pool } from 'pg';
import { PgUserRepository } from './repositories/user.repository.pg';
import { NodemailerService } from './services/mailer.service';
import { UserService } from './services/user.service';
import { OrderService } from './services/order.service';

const build = async () => {
  const fastify = Fastify({ logger: true });

  // Infrastructure
  const pool = new Pool({ connectionString: process.env.DATABASE_URL });
  const mailer = new NodemailerService(process.env.SMTP_URL!);

  // Repositories
  const userRepo = new PgUserRepository(pool);
  const orderRepo = new PgOrderRepository(pool);

  // Services
  const userService = new UserService(userRepo, mailer);
  const orderService = new OrderService(orderRepo, userRepo);

  // Decorate Fastify
  fastify.decorate('services', { user: userService, order: orderService });

  await fastify.register(import('./routes/users'), { prefix: '/users' });
  await fastify.register(import('./routes/orders'), { prefix: '/orders' });

  return fastify;
};
```

**Key Points:**
- Zero dependencies beyond your own code
- Wiring is explicit and traceable
- Scales poorly as the number of services grows — adding one dependency requires updating every instantiation site that transitively uses it
- No lifecycle management beyond what you implement manually

---

### Approach 2: Fastify Decorator-Based DI

Fastify's native plugin and decorator system acts as a lightweight DI container. Plugins register shared resources; other plugins declare their dependencies via the `dependencies` option.

```ts
// src/plugins/infrastructure.plugin.ts

import fp from 'fastify-plugin';
import { FastifyPluginAsync } from 'fastify';
import { Pool } from 'pg';

const infrastructurePlugin: FastifyPluginAsync = async (fastify) => {
  const pool = new Pool({ connectionString: process.env.DATABASE_URL });

  fastify.decorate('pg', { pool });

  fastify.addHook('onClose', async () => {
    await pool.end();
  });
};

export default fp(infrastructurePlugin, { name: 'infrastructure' });
```

```ts
// src/plugins/repositories.plugin.ts

import fp from 'fastify-plugin';
import { FastifyPluginAsync } from 'fastify';
import { PgUserRepository } from '../repositories/user.repository.pg';

const repositoriesPlugin: FastifyPluginAsync = async (fastify) => {
  fastify.decorate('repositories', {
    user: new PgUserRepository(fastify.pg.pool),
  });
};

export default fp(repositoriesPlugin, {
  name: 'repositories',
  dependencies: ['infrastructure'],
});
```

```ts
// src/plugins/services.plugin.ts

import fp from 'fastify-plugin';
import { FastifyPluginAsync } from 'fastify';
import { UserService } from '../services/user.service';

const servicesPlugin: FastifyPluginAsync = async (fastify) => {
  fastify.decorate('services', {
    user: new UserService(
      fastify.repositories.user,
      fastify.mailer           // another decorated dependency
    ),
  });
};

export default fp(servicesPlugin, {
  name: 'services',
  dependencies: ['repositories', 'mailer'],
});
```

**Key Points:**
- Fastify enforces plugin registration order via `dependencies`
- `onClose` hooks enable proper teardown of database pools, connections, and other resources
- The `fastify` instance itself acts as the service locator; plugins pull what they need from it
- TypeScript augmentation on `FastifyInstance` provides full type safety

#### Lifecycle Hook Integration

```ts
// Registering teardown for any decorated resource
fastify.addHook('onClose', async (instance) => {
  await instance.pg.pool.end();
  await instance.mailer.close();
});
```

[Inference] Fastify calls `onClose` hooks in reverse registration order, which typically aligns with correct teardown ordering, though this depends on plugin structure and has not been formally guaranteed in all Fastify versions. Verify against your Fastify version's documentation.

---

### Approach 3: Awilix DI Container

[`awilix`](https://github.com/jeffijoe/awilix) is a dedicated DI container for Node.js. It manages registration, resolution, and lifetime scoping of dependencies automatically.

```bash
npm install awilix
```

#### Registering a Container

```ts
// src/container.ts

import {
  createContainer,
  asClass,
  asValue,
  InjectionMode,
  Lifetime,
} from 'awilix';
import { Pool } from 'pg';
import { PgUserRepository } from './repositories/user.repository.pg';
import { UserService } from './services/user.service';
import { NodemailerService } from './services/mailer.service';

export const buildContainer = () => {
  const container = createContainer({
    injectionMode: InjectionMode.CLASSIC, // constructor parameter order
  });

  const pool = new Pool({ connectionString: process.env.DATABASE_URL });

  container.register({
    // Infrastructure
    pool: asValue(pool),

    // Repositories
    userRepo: asClass(PgUserRepository, { lifetime: Lifetime.SINGLETON }),

    // Services
    mailerService: asClass(NodemailerService, { lifetime: Lifetime.SINGLETON }),
    userService: asClass(UserService, { lifetime: Lifetime.SINGLETON }),
  });

  return container;
};
```

#### `CLASSIC` vs `PROXY` Injection Mode

`InjectionMode.CLASSIC` resolves dependencies by constructor parameter name — the parameter name must match the registered token exactly.

```ts
// CLASSIC mode — parameter names must match container registration tokens
export class UserService {
  constructor(
    private readonly userRepo: UserRepository,    // matches token 'userRepo'
    private readonly mailerService: MailerService // matches token 'mailerService'
  ) {}
}
```

`InjectionMode.PROXY` passes a cradle proxy as the single constructor argument. All dependencies are destructured from it.

```ts
// PROXY mode — destructure from the cradle
export class UserService {
  private readonly userRepo: UserRepository;
  private readonly mailerService: MailerService;

  constructor({ userRepo, mailerService }: { userRepo: UserRepository; mailerService: MailerService }) {
    this.userRepo = userRepo;
    this.mailerService = mailerService;
  }
}
```

[Inference] `PROXY` mode tends to be more explicit and resilient to minification, since it does not rely on parameter name preservation. Behavior under minification with `CLASSIC` mode depends on the bundler and its configuration.

#### Integrating the Container with Fastify

```ts
// src/plugins/container.plugin.ts

import fp from 'fastify-plugin';
import { FastifyPluginAsync } from 'fastify';
import { buildContainer } from '../container';

const containerPlugin: FastifyPluginAsync = async (fastify) => {
  const container = buildContainer();

  fastify.decorate('container', container);
  fastify.decorate('services', {
    user: container.resolve('userService'),
  });

  fastify.addHook('onClose', async () => {
    await container.dispose();
  });
};

export default fp(containerPlugin, { name: 'container' });
```

#### Resolving in Route Handlers

```ts
fastify.get('/:id', async (request) => {
  return fastify.services.user.getById(request.params.id);
});
```

Route handlers remain identical regardless of which DI approach is used underneath. The abstraction holds.

---

### Approach 4: Request-Scoped DI with Awilix

Some dependencies must be per-request rather than singletons — for example, a scoped database transaction, the authenticated user context, or a request-specific logger.

```ts
// src/plugins/scoped-container.plugin.ts

import fp from 'fastify-plugin';
import { FastifyPluginAsync } from 'fastify';
import { asValue } from 'awilix';

const scopedContainerPlugin: FastifyPluginAsync = async (fastify) => {
  fastify.addHook('onRequest', async (request) => {
    const scope = fastify.container.createScope();

    // Inject request-specific values into the scoped container
    scope.register({
      requestId: asValue(request.id),
      currentUser: asValue(request.user ?? null),
      logger: asValue(request.log),
    });

    request.scope = scope;
  });

  fastify.addHook('onResponse', async (request) => {
    await request.scope.dispose();
  });
};

export default fp(scopedContainerPlugin, {
  name: 'scoped-container',
  dependencies: ['container'],
});
```

```ts
// src/@types/fastify/index.d.ts

import { AwilixContainer } from 'awilix';

declare module 'fastify' {
  interface FastifyRequest {
    scope: AwilixContainer;
  }
}
```

```ts
// In a route handler
fastify.get('/me', async (request) => {
  const userService = request.scope.resolve<UserService>('userService');
  return userService.getById(request.user.id);
});
```

**Key Points:**
- Scoped containers inherit all singleton registrations from the parent container
- Per-request values override or extend the parent registrations only within the scope
- Disposing the scope on `onResponse` releases scoped resources without affecting singletons

---

### Approach 5: Interface-Based Injection with Factory Functions

A lightweight alternative to a full container — factory functions produce fully wired service graphs without a framework.

```ts
// src/factories/services.factory.ts

import { Pool } from 'pg';
import { PgUserRepository } from '../repositories/user.repository.pg';
import { UserService } from '../services/user.service';
import { NodemailerService } from '../services/mailer.service';

export interface AppServices {
  user: UserService;
}

export const buildServices = (pool: Pool): AppServices => {
  const userRepo = new PgUserRepository(pool);
  const mailer = new NodemailerService(process.env.SMTP_URL!);

  return {
    user: new UserService(userRepo, mailer),
  };
};
```

```ts
// src/app.ts

const pool = new Pool({ connectionString: process.env.DATABASE_URL });
const services = buildServices(pool);

fastify.decorate('services', services);
```

**Key Points:**
- No external DI library required
- The factory is a pure function — easy to call in tests with different implementations
- Lifetime management (singletons vs. transients) is the caller's responsibility
- Does not scale as cleanly as a container for large graphs with many optional overrides

---

### Testing with DI: Substituting Implementations

The primary payoff of DI is testability. Any approach above allows test code to substitute real implementations with fakes.

#### Manual Substitution in Tests

```ts
// tests/helpers/build-test-app.ts

import Fastify from 'fastify';
import { InMemoryUserRepository } from '../../src/repositories/user.repository.memory';
import { FakeMailerService } from '../../src/services/mailer.fake';
import { UserService } from '../../src/services/user.service';

export const buildTestApp = async () => {
  const fastify = Fastify();

  fastify.decorate('services', {
    user: new UserService(
      new InMemoryUserRepository(),
      new FakeMailerService()
    ),
  });

  await fastify.register(import('../../src/routes/users'), { prefix: '/users' });
  await fastify.ready();
  return fastify;
};
```

```ts
// tests/routes/users.test.ts

import { buildTestApp } from '../helpers/build-test-app';

test('GET /users/:id returns 404 for unknown user', async () => {
  const app = await buildTestApp();
  const response = await app.inject({ method: 'GET', url: '/users/nonexistent' });
  expect(response.statusCode).toBe(404);
});
```

No real database, no real SMTP server. [Inference] This pattern typically produces faster, more deterministic tests than integration tests, though actual behavior depends on how faithfully the fake implementations mirror production behavior.

---

### Comparing DI Approaches

| Approach | Complexity | Scalability | Test Ergonomics | External Deps |
|---|---|---|---|---|
| Manual constructor injection | Low | Low | Good | None |
| Fastify decorator-based | Low–Medium | Medium | Good | `fastify-plugin` |
| Awilix singleton container | Medium | High | Excellent | `awilix` |
| Awilix request-scoped | Medium–High | High | Excellent | `awilix` |
| Factory functions | Low | Medium | Good | None |

---

### Architecture Diagram

<svg viewBox="0 0 740 480" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="12">
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

  <!-- Startup phase -->
  <rect x="20" y="20" width="700" height="110" rx="8" fill="#0d1a2a" stroke="#2a4a6a" stroke-width="1"/>
  <text x="370" y="40" text-anchor="middle" fill="#6aa0cc" font-size="11">Application Startup — DI Wiring</text>

  <rect x="40" y="50" width="140" height="68" rx="6" fill="#1e3a5f" stroke="#4a90d9" stroke-width="1.2"/>
  <text x="110" y="72" text-anchor="middle" fill="#c8e0ff">Infrastructure</text>
  <text x="110" y="90" text-anchor="middle" fill="#80b0e0" font-size="10">Pool, SMTP</text>
  <text x="110" y="106" text-anchor="middle" fill="#80b0e0" font-size="10">config values</text>

  <line x1="180" y1="84" x2="220" y2="84" stroke="#4a90d9" stroke-width="1.4" marker-end="url(#arr)"/>

  <rect x="220" y="50" width="140" height="68" rx="6" fill="#1e3a5f" stroke="#4a90d9" stroke-width="1.2"/>
  <text x="290" y="72" text-anchor="middle" fill="#c8e0ff">Repositories</text>
  <text x="290" y="90" text-anchor="middle" fill="#80b0e0" font-size="10">PgUserRepo</text>
  <text x="290" y="106" text-anchor="middle" fill="#80b0e0" font-size="10">PgOrderRepo</text>

  <line x1="360" y1="84" x2="400" y2="84" stroke="#4a90d9" stroke-width="1.4" marker-end="url(#arr)"/>

  <rect x="400" y="50" width="140" height="68" rx="6" fill="#1a3a28" stroke="#4caf77" stroke-width="1.2"/>
  <text x="470" y="72" text-anchor="middle" fill="#b8f0cc">Services</text>
  <text x="470" y="90" text-anchor="middle" fill="#80c8a0" font-size="10">UserService</text>
  <text x="470" y="106" text-anchor="middle" fill="#80c8a0" font-size="10">OrderService</text>

  <line x1="540" y1="84" x2="580" y2="84" stroke="#4a90d9" stroke-width="1.4" marker-end="url(#arr)"/>

  <rect x="580" y="50" width="120" height="68" rx="6" fill="#1e3a5f" stroke="#4a90d9" stroke-width="1.2"/>
  <text x="640" y="72" text-anchor="middle" fill="#c8e0ff">fastify</text>
  <text x="640" y="90" text-anchor="middle" fill="#80b0e0" font-size="10">.decorate()</text>
  <text x="640" y="106" text-anchor="middle" fill="#80b0e0" font-size="10">service locator</text>

  <!-- Container box (optional) -->
  <rect x="390" y="150" width="160" height="50" rx="6" fill="#2a1a3a" stroke="#9060d0" stroke-width="1" stroke-dasharray="5,3"/>
  <text x="470" y="172" text-anchor="middle" fill="#c090f0" font-size="11">Awilix Container</text>
  <text x="470" y="190" text-anchor="middle" fill="#9060c0" font-size="10">optional — manages graph</text>
  <line x1="470" y1="150" x2="470" y2="118" stroke="#9060d0" stroke-width="1" stroke-dasharray="4,3" marker-end="url(#arrO)"/>

  <!-- Request phase -->
  <rect x="20" y="230" width="700" height="110" rx="8" fill="#0d2213" stroke="#2a5a3a" stroke-width="1"/>
  <text x="370" y="250" text-anchor="middle" fill="#5aac7a" font-size="11">Request Phase</text>

  <rect x="40" y="260" width="150" height="65" rx="6" fill="#1a3a28" stroke="#4caf77" stroke-width="1.2"/>
  <text x="115" y="282" text-anchor="middle" fill="#b8f0cc">Route Handler</text>
  <text x="115" y="300" text-anchor="middle" fill="#80c8a0" font-size="10">fastify.services.user</text>
  <text x="115" y="315" text-anchor="middle" fill="#80c8a0" font-size="10">.getById(id)</text>

  <line x1="190" y1="292" x2="230" y2="292" stroke="#4caf77" stroke-width="1.4" marker-end="url(#arrG)"/>

  <rect x="230" y="260" width="150" height="65" rx="6" fill="#1a3a28" stroke="#4caf77" stroke-width="1.2"/>
  <text x="305" y="282" text-anchor="middle" fill="#b8f0cc">UserService</text>
  <text x="305" y="300" text-anchor="middle" fill="#80c8a0" font-size="10">business logic</text>
  <text x="305" y="315" text-anchor="middle" fill="#80c8a0" font-size="10">injected repo</text>

  <line x1="380" y1="292" x2="420" y2="292" stroke="#4caf77" stroke-width="1.4" marker-end="url(#arrG)"/>

  <rect x="420" y="260" width="150" height="65" rx="6" fill="#1e3a5f" stroke="#4a90d9" stroke-width="1.2"/>
  <text x="495" y="282" text-anchor="middle" fill="#c8e0ff">UserRepository</text>
  <text x="495" y="300" text-anchor="middle" fill="#80b0e0" font-size="10">data access</text>
  <text x="495" y="315" text-anchor="middle" fill="#80b0e0" font-size="10">injected pool</text>

  <line x1="570" y1="292" x2="610" y2="292" stroke="#4a90d9" stroke-width="1.4" marker-end="url(#arr)"/>

  <rect x="610" y="260" width="100" height="65" rx="6" fill="#0d0d1f" stroke="#3a3a6a" stroke-width="1.2"/>
  <text x="660" y="282" text-anchor="middle" fill="#8080cc">Database</text>
  <text x="660" y="300" text-anchor="middle" fill="#5050a0" font-size="10">pg Pool</text>

  <!-- Scoped label -->
  <rect x="40" y="360" width="260" height="40" rx="6" fill="#1a1a00" stroke="#f0a020" stroke-width="1" stroke-dasharray="4,3"/>
  <text x="170" y="378" text-anchor="middle" fill="#f0c040" font-size="11">Optional: request.scope (Awilix)</text>
  <text x="170" y="394" text-anchor="middle" fill="#c09030" font-size="10">per-request DI — currentUser, requestId, logger</text>

  <!-- Test swap -->
  <rect x="420" y="360" width="280" height="40" rx="6" fill="#3a1a1a" stroke="#e05050" stroke-width="1" stroke-dasharray="4,3"/>
  <text x="560" y="378" text-anchor="middle" fill="#f08080" font-size="11">Tests: swap PgUserRepo</text>
  <text x="560" y="394" text-anchor="middle" fill="#c06060" font-size="10">→ InMemoryUserRepository (no DB needed)</text>
</svg>

---

### Common Mistakes

#### Using `new` Inside Services

```ts
// Bad — UserService owns the creation of its dependency
export class UserService {
  private readonly repo = new PgUserRepository(new Pool());
}
```

```ts
// Correct — dependency supplied from outside
export class UserService {
  constructor(private readonly repo: UserRepository) {}
}
```

#### Resolving From the Container in Route Handlers

```ts
// Avoid — spreads container knowledge into route handlers
fastify.get('/:id', async (request) => {
  const service = fastify.container.resolve('userService');
  return service.getById(request.params.id);
});
```

```ts
// Prefer — container details hidden behind decorator
fastify.get('/:id', async (request) => {
  return fastify.services.user.getById(request.params.id);
});
```

Resolving directly from the container in every handler reintroduces service-locator coupling. Reserve container resolution for the plugin layer.

#### Forgetting `fastify-plugin` on Decorator Plugins

Without `fp`, decorators added inside a plugin are scoped to that plugin's encapsulation context and not visible outside it. Every plugin that registers decorators intended for the whole application must be wrapped with `fp`.

---

**Related Topics:**
- Awilix lifetime scopes — `SINGLETON`, `TRANSIENT`, `SCOPED` in depth
- Testing Fastify with dependency substitution — `inject()` and fake implementations
- Environment-based composition roots — swapping implementations per environment
- TypeScript generic interfaces for repository and service abstractions
- Hexagonal architecture (ports and adapters) as a DI-native architectural style
- Managing async initialization in DI (e.g., database connection pools that must await before use)
- Plugin load order guarantees and the `dependencies` option in Fastify