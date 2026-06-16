## Service Layer Patterns in Fastify

The service layer is the stratum of application code that owns business logic. It sits between route handlers (which deal with HTTP concerns) and repositories (which deal with data access). This document covers how to structure, register, and compose service layers in Fastify applications.

---

### What the Service Layer Is Responsible For

Route handlers answer: *how does an HTTP request map to a response?*
Repositories answer: *how is data stored and retrieved?*
Services answer: *what are the rules and operations of the domain?*

**Key Points:**
- Validation of business rules (distinct from schema validation)
- Orchestrating calls across multiple repositories
- Transforming data between domain and persistence shapes
- Centralizing logic that would otherwise be duplicated across routes
- Raising domain-specific errors that routes translate into HTTP responses

Services must not import Fastify types, `request`, or `reply` — they are HTTP-agnostic by design.

---

### Basic Service Structure

```ts
// src/services/user.service.ts

import { UserRepository } from '../repositories/user.repository.interface';
import { User, CreateUserDto, UpdateUserDto } from '../models/user.model';

export class UserService {
  constructor(private readonly userRepo: UserRepository) {}

  async getById(id: string): Promise<User> {
    const user = await this.userRepo.findById(id);
    if (!user) throw new NotFoundError(`User ${id} not found`);
    return user;
  }

  async getAll(): Promise<User[]> {
    return this.userRepo.findAll();
  }

  async create(data: CreateUserDto): Promise<User> {
    return this.userRepo.create(data);
  }

  async update(id: string, data: UpdateUserDto): Promise<User> {
    const user = await this.userRepo.update(id, data);
    if (!user) throw new NotFoundError(`User ${id} not found`);
    return user;
  }

  async remove(id: string): Promise<void> {
    const deleted = await this.userRepo.delete(id);
    if (!deleted) throw new NotFoundError(`User ${id} not found`);
  }
}
```

---

### Domain Error Classes

Services raise typed errors. Route handlers catch them and translate them to HTTP status codes. This keeps HTTP semantics out of the service layer.

```ts
// src/errors/domain.errors.ts

export class NotFoundError extends Error {
  constructor(message: string) {
    super(message);
    this.name = 'NotFoundError';
  }
}

export class ConflictError extends Error {
  constructor(message: string) {
    super(message);
    this.name = 'ConflictError';
  }
}

export class ForbiddenError extends Error {
  constructor(message: string) {
    super(message);
    this.name = 'ForbiddenError';
  }
}

export class ValidationError extends Error {
  constructor(message: string) {
    super(message);
    this.name = 'ValidationError';
  }
}
```

#### Translating Domain Errors in Route Handlers

```ts
// src/routes/users/index.ts

import { NotFoundError, ConflictError } from '../../errors/domain.errors';

fastify.get('/:id', async (request, reply) => {
  try {
    const user = await fastify.services.user.getById(request.params.id);
    return user;
  } catch (err) {
    if (err instanceof NotFoundError) return reply.code(404).send({ message: err.message });
    throw err; // let Fastify's error handler catch unexpected errors
  }
});
```

#### Using a Centralized Error Handler

Instead of try/catch in every route, register a global error handler:

```ts
// src/plugins/error-handler.plugin.ts

import fp from 'fastify-plugin';
import { FastifyPluginAsync } from 'fastify';
import {
  NotFoundError,
  ConflictError,
  ForbiddenError,
  ValidationError,
} from '../errors/domain.errors';

const errorHandlerPlugin: FastifyPluginAsync = async (fastify) => {
  fastify.setErrorHandler((error, request, reply) => {
    if (error instanceof NotFoundError) {
      return reply.code(404).send({ error: error.message });
    }
    if (error instanceof ConflictError) {
      return reply.code(409).send({ error: error.message });
    }
    if (error instanceof ForbiddenError) {
      return reply.code(403).send({ error: error.message });
    }
    if (error instanceof ValidationError) {
      return reply.code(422).send({ error: error.message });
    }

    fastify.log.error(error);
    reply.code(500).send({ error: 'Internal Server Error' });
  });
};

export default fp(errorHandlerPlugin, { name: 'error-handler' });
```

Route handlers can then simply throw, with no try/catch needed:

```ts
fastify.get('/:id', async (request) => {
  return fastify.services.user.getById(request.params.id);
  // NotFoundError propagates to setErrorHandler automatically
});
```

---

### Registering Services as Fastify Decorators

```ts
// src/plugins/services.plugin.ts

import fp from 'fastify-plugin';
import { FastifyPluginAsync } from 'fastify';
import { UserService } from '../services/user.service';
import { OrderService } from '../services/order.service';

const servicesPlugin: FastifyPluginAsync = async (fastify) => {
  fastify.decorate('services', {
    user: new UserService(fastify.repositories.user),
    order: new OrderService(
      fastify.repositories.order,
      fastify.repositories.user
    ),
  });
};

export default fp(servicesPlugin, {
  name: 'services',
  dependencies: ['repositories'],
});
```

#### TypeScript Augmentation

```ts
// src/@types/fastify/index.d.ts

import { UserService } from '../../services/user.service';
import { OrderService } from '../../services/order.service';

declare module 'fastify' {
  interface FastifyInstance {
    services: {
      user: UserService;
      order: OrderService;
    };
  }
}
```

---

### Multi-Repository Orchestration

A service that coordinates more than one repository is one of the primary justifications for the service layer. Without it, this logic would leak into route handlers or be duplicated.

```ts
// src/services/order.service.ts

import { OrderRepository } from '../repositories/order.repository.interface';
import { UserRepository } from '../repositories/user.repository.interface';
import { Order, CreateOrderDto } from '../models/order.model';
import { NotFoundError, ForbiddenError } from '../errors/domain.errors';

export class OrderService {
  constructor(
    private readonly orderRepo: OrderRepository,
    private readonly userRepo: UserRepository
  ) {}

  async placeOrder(userId: string, data: CreateOrderDto): Promise<Order> {
    const user = await this.userRepo.findById(userId);
    if (!user) throw new NotFoundError(`User ${userId} not found`);

    if (!user.isActive) {
      throw new ForbiddenError(`User ${userId} account is inactive`);
    }

    return this.orderRepo.create({ ...data, userId });
  }

  async cancelOrder(userId: string, orderId: string): Promise<void> {
    const order = await this.orderRepo.findById(orderId);
    if (!order) throw new NotFoundError(`Order ${orderId} not found`);

    if (order.userId !== userId) {
      throw new ForbiddenError('Cannot cancel another user\'s order');
    }

    await this.orderRepo.updateStatus(orderId, 'cancelled');
  }
}
```

---

### Service-to-Service Calls

Services may depend on other services when the logic genuinely crosses domains. Construct them with explicit constructor injection rather than importing a singleton.

```ts
// src/services/notification.service.ts

export class NotificationService {
  async sendWelcomeEmail(email: string, name: string): Promise<void> {
    // delegates to an external mailer, queue, etc.
  }
}
```

```ts
// src/services/user.service.ts (extended)

export class UserService {
  constructor(
    private readonly userRepo: UserRepository,
    private readonly notificationService: NotificationService
  ) {}

  async create(data: CreateUserDto): Promise<User> {
    const existing = await this.userRepo.findByEmail(data.email);
    if (existing) throw new ConflictError(`Email ${data.email} already in use`);

    const user = await this.userRepo.create(data);
    await this.notificationService.sendWelcomeEmail(user.email, user.name);
    return user;
  }
}
```

```ts
// src/plugins/services.plugin.ts (updated wiring)

const servicesPlugin: FastifyPluginAsync = async (fastify) => {
  const notification = new NotificationService();
  const user = new UserService(fastify.repositories.user, notification);

  fastify.decorate('services', { user, notification });
};
```

[Inference] Circular service dependencies (A depends on B, B depends on A) are a sign the domain boundary is misdrawn. Resolving them typically requires extracting a third service or restructuring responsibilities. Behavior under circular injection depends on how the container or manual wiring is structured.

---

### Pattern: Thin Service, Fat Repository

For simple CRUD domains with minimal business rules, services may be intentionally thin — they add error translation and nothing more. This is a valid pattern, not an anti-pattern.

```ts
export class TagService {
  constructor(private readonly tagRepo: TagRepository) {}

  async getById(id: string): Promise<Tag> {
    const tag = await this.tagRepo.findById(id);
    if (!tag) throw new NotFoundError(`Tag ${id} not found`);
    return tag;
  }

  async create(data: CreateTagDto): Promise<Tag> {
    return this.tagRepo.create(data);
  }
}
```

Reserve complex orchestration for services that actually need it.

---

### Pattern: Command and Query Separation within a Service

For services that grow large, separate read and write operations into distinct methods or even distinct classes. This is a lightweight CQRS approach without requiring full event sourcing.

```ts
// src/services/user.queries.ts

export class UserQueryService {
  constructor(private readonly userRepo: UserRepository) {}

  async getById(id: string): Promise<User> {
    const user = await this.userRepo.findById(id);
    if (!user) throw new NotFoundError(`User ${id} not found`);
    return user;
  }

  async search(query: string): Promise<User[]> {
    return this.userRepo.search(query);
  }
}
```

```ts
// src/services/user.commands.ts

export class UserCommandService {
  constructor(
    private readonly userRepo: UserRepository,
    private readonly notifications: NotificationService
  ) {}

  async create(data: CreateUserDto): Promise<User> {
    const user = await this.userRepo.create(data);
    await this.notifications.sendWelcomeEmail(user.email, user.name);
    return user;
  }

  async deactivate(id: string): Promise<void> {
    const updated = await this.userRepo.update(id, { isActive: false });
    if (!updated) throw new NotFoundError(`User ${id} not found`);
  }
}
```

Register both under a grouped namespace if desired:

```ts
fastify.decorate('services', {
  user: {
    queries: new UserQueryService(fastify.repositories.user),
    commands: new UserCommandService(
      fastify.repositories.user,
      new NotificationService()
    ),
  },
});
```

---

### Pattern: Transaction-Aware Services

When multiple repository writes must be atomic, the service layer is where the transaction boundary is defined. The exact mechanism depends on the database driver. [Inference] The pattern below reflects common approaches with `pg`; behavior with other drivers or ORMs will differ.

```ts
// src/services/transfer.service.ts

import { Pool, PoolClient } from 'pg';

export class TransferService {
  constructor(
    private readonly pool: Pool,
    private readonly accountRepo: AccountRepository
  ) {}

  async transfer(fromId: string, toId: string, amount: number): Promise<void> {
    const client: PoolClient = await this.pool.connect();

    try {
      await client.query('BEGIN');

      const from = await this.accountRepo.findById(fromId, client);
      const to = await this.accountRepo.findById(toId, client);

      if (!from || !to) throw new NotFoundError('Account not found');
      if (from.balance < amount) throw new ValidationError('Insufficient funds');

      await this.accountRepo.debit(fromId, amount, client);
      await this.accountRepo.credit(toId, amount, client);

      await client.query('COMMIT');
    } catch (err) {
      await client.query('ROLLBACK');
      throw err;
    } finally {
      client.release();
    }
  }
}
```

The repository methods accept an optional `client` parameter to participate in the caller's transaction. This is one common convention; Prisma, Drizzle, and other ORMs expose different transaction APIs.

---

### Architecture Flow Diagram

<svg viewBox="0 0 740 460" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="12">
  <defs>
    <marker id="arr" markerWidth="8" markerHeight="8" refX="6" refY="3" orient="auto">
      <path d="M0,0 L0,6 L8,3 z" fill="#4a90d9"/>
    </marker>
    <marker id="arrErr" markerWidth="8" markerHeight="8" refX="6" refY="3" orient="auto">
      <path d="M0,0 L0,6 L8,3 z" fill="#e05050"/>
    </marker>
  </defs>

  <!-- HTTP Layer -->
  <rect x="20" y="20" width="700" height="70" rx="8" fill="#0d1f33" stroke="#2a4a6a" stroke-width="1"/>
  <text x="370" y="42" text-anchor="middle" fill="#6aa0cc" font-size="11">HTTP Layer</text>
  <rect x="40" y="48" width="180" height="32" rx="6" fill="#1e3a5f" stroke="#4a90d9" stroke-width="1.2"/>
  <text x="130" y="69" text-anchor="middle" fill="#c8e0ff">Route Handler</text>
  <rect x="260" y="48" width="180" height="32" rx="6" fill="#1e3a5f" stroke="#4a90d9" stroke-width="1.2"/>
  <text x="350" y="69" text-anchor="middle" fill="#c8e0ff">setErrorHandler</text>
  <rect x="480" y="48" width="220" height="32" rx="6" fill="#1e3a5f" stroke="#4a90d9" stroke-width="1.2"/>
  <text x="590" y="69" text-anchor="middle" fill="#c8e0ff">Schema Validation (JSON)</text>

  <!-- Arrow: Route → Service -->
  <line x1="130" y1="120" x2="130" y2="160" stroke="#4a90d9" stroke-width="1.5" marker-end="url(#arr)"/>

  <!-- Service Layer -->
  <rect x="20" y="160" width="700" height="100" rx="8" fill="#0d2213" stroke="#2a5a3a" stroke-width="1"/>
  <text x="370" y="180" text-anchor="middle" fill="#5aac7a" font-size="11">Service Layer — Business Logic</text>
  <rect x="40" y="188" width="160" height="60" rx="6" fill="#1a3a28" stroke="#4caf77" stroke-width="1.2"/>
  <text x="120" y="210" text-anchor="middle" fill="#b8f0cc">UserService</text>
  <text x="120" y="228" text-anchor="middle" fill="#80c8a0" font-size="10">domain rules</text>
  <text x="120" y="243" text-anchor="middle" fill="#80c8a0" font-size="10">multi-repo calls</text>

  <rect x="220" y="188" width="160" height="60" rx="6" fill="#1a3a28" stroke="#4caf77" stroke-width="1.2"/>
  <text x="300" y="210" text-anchor="middle" fill="#b8f0cc">OrderService</text>
  <text x="300" y="228" text-anchor="middle" fill="#80c8a0" font-size="10">orchestration</text>
  <text x="300" y="243" text-anchor="middle" fill="#80c8a0" font-size="10">transactions</text>

  <rect x="400" y="188" width="160" height="60" rx="6" fill="#1a3a28" stroke="#4caf77" stroke-width="1.2"/>
  <text x="480" y="210" text-anchor="middle" fill="#b8f0cc">NotificationService</text>
  <text x="480" y="228" text-anchor="middle" fill="#80c8a0" font-size="10">side effects</text>
  <text x="480" y="243" text-anchor="middle" fill="#80c8a0" font-size="10">external calls</text>

  <!-- Domain Errors bubble -->
  <rect x="580" y="188" width="130" height="60" rx="6" fill="#3a1a1a" stroke="#e05050" stroke-width="1" stroke-dasharray="5,3"/>
  <text x="645" y="210" text-anchor="middle" fill="#f08080" font-size="11">Domain Errors</text>
  <text x="645" y="228" text-anchor="middle" fill="#c06060" font-size="10">NotFoundError</text>
  <text x="645" y="243" text-anchor="middle" fill="#c06060" font-size="10">ConflictError …</text>

  <!-- Arrow: Service → Repo -->
  <line x1="120" y1="260" x2="120" y2="310" stroke="#4a90d9" stroke-width="1.5" marker-end="url(#arr)"/>
  <line x1="300" y1="260" x2="300" y2="310" stroke="#4a90d9" stroke-width="1.5" marker-end="url(#arr)"/>

  <!-- Arrow: Domain Errors → setErrorHandler -->
  <line x1="645" y1="188" x2="430" y2="88" stroke="#e05050" stroke-width="1.2" stroke-dasharray="5,3" marker-end="url(#arrErr)"/>

  <!-- Repository Layer -->
  <rect x="20" y="310" width="700" height="70" rx="8" fill="#1a1a0d" stroke="#5a5a2a" stroke-width="1"/>
  <text x="370" y="330" text-anchor="middle" fill="#aaaa5a" font-size="11">Repository Layer — Data Access</text>
  <rect x="40" y="338" width="180" height="32" rx="6" fill="#2a2a1a" stroke="#8a8a3a" stroke-width="1.2"/>
  <text x="130" y="359" text-anchor="middle" fill="#e0e090">UserRepository</text>
  <rect x="260" y="338" width="180" height="32" rx="6" fill="#2a2a1a" stroke="#8a8a3a" stroke-width="1.2"/>
  <text x="350" y="359" text-anchor="middle" fill="#e0e090">OrderRepository</text>

  <!-- DB Layer -->
  <rect x="20" y="410" width="420" height="40" rx="8" fill="#0d0d1f" stroke="#3a3a6a" stroke-width="1"/>
  <text x="230" y="435" text-anchor="middle" fill="#8080cc">Database (PostgreSQL / other)</text>
  <line x1="130" y1="380" x2="130" y2="410" stroke="#4a90d9" stroke-width="1.2" marker-end="url(#arr)"/>
  <line x1="350" y1="380" x2="350" y2="410" stroke="#4a90d9" stroke-width="1.2" marker-end="url(#arr)"/>
</svg>

---

### Unit Testing Services in Isolation

Because services receive their dependencies via constructor injection, they can be tested without Fastify, without a database, and without HTTP.

```ts
// tests/user.service.test.ts

import { UserService } from '../src/services/user.service';
import { InMemoryUserRepository } from '../src/repositories/user.repository.memory';
import { NotFoundError, ConflictError } from '../src/errors/domain.errors';

describe('UserService', () => {
  let service: UserService;

  beforeEach(() => {
    service = new UserService(new InMemoryUserRepository());
  });

  it('throws NotFoundError when user does not exist', async () => {
    await expect(service.getById('nonexistent')).rejects.toThrow(NotFoundError);
  });

  it('creates and retrieves a user', async () => {
    const user = await service.create({ name: 'Luke', email: 'luke@example.com' });
    const found = await service.getById(user.id);
    expect(found.email).toBe('luke@example.com');
  });
});
```

[Inference] Test isolation at the service layer typically produces faster tests than integration tests that involve a real database, though actual timing depends on the runtime, test runner, and hardware.

---

### What Services Must Not Do

| Concern | Belongs In |
|---|---|
| Parsing `request.body` | Route handler |
| Setting `reply.code()` | Route handler |
| Importing `FastifyRequest` | Route handler |
| Raw SQL queries | Repository |
| ORM model imports | Repository |
| HTTP status knowledge | Route handler / error handler |
| Business rule enforcement | Service |
| Cross-entity orchestration | Service |

---

### Folder Structure

```
src/
├── errors/
│   └── domain.errors.ts
├── services/
│   ├── user.service.ts
│   ├── user.queries.ts        # optional CQRS split
│   ├── user.commands.ts
│   ├── order.service.ts
│   └── notification.service.ts
├── plugins/
│   ├── error-handler.plugin.ts
│   └── services.plugin.ts
└── routes/
    └── users/
        └── index.ts
```

---

**Related Topics:**
- Dependency injection containers (`awilix`) for automating service wiring
- Event-driven services — decoupling side effects using an event emitter or message queue
- Full CQRS with event sourcing in Fastify
- Service layer testing strategies — mocking vs. in-memory repositories vs. test containers
- Authorization in the service layer vs. route hooks
- Saga pattern for distributed multi-service transactions
- Layered architecture vs. hexagonal (ports and adapters) architecture in Fastify