## Repository Pattern with Fastify

The repository pattern is a structural design pattern that abstracts the data access layer from business logic. In Fastify applications, it provides a clean separation between how data is stored and retrieved and how it is used by route handlers or services.

---

### What the Repository Pattern Is

A repository acts as an in-memory collection of domain objects, hiding the details of the underlying data source (SQL, NoSQL, file system, external API). Consumers of the repository — route handlers, services, controllers — interact only with plain method calls, not with raw query logic.

**Key Points:**
- Data access logic lives in one place
- Business logic and route handlers remain ignorant of database internals
- Repositories can be swapped (e.g., switching from PostgreSQL to a mock) without changing calling code — [Inference] this typically holds when interfaces are well-defined, but behavior depends on how strictly the abstraction is maintained
- Enables unit testing of business logic by substituting fake repositories

---

### Core Concepts

#### Repository Interface

A repository defines a contract — a set of methods that any concrete implementation must fulfill. In TypeScript this is expressed as an interface.

```ts
// src/repositories/user.repository.interface.ts

export interface UserRepository {
  findById(id: string): Promise<User | null>;
  findAll(): Promise<User[]>;
  create(data: CreateUserDto): Promise<User>;
  update(id: string, data: UpdateUserDto): Promise<User | null>;
  delete(id: string): Promise<boolean>;
}
```

#### Domain Model

```ts
// src/models/user.model.ts

export interface User {
  id: string;
  name: string;
  email: string;
  createdAt: Date;
}

export interface CreateUserDto {
  name: string;
  email: string;
}

export interface UpdateUserDto {
  name?: string;
  email?: string;
}
```

---

### Concrete Repository Implementation (PostgreSQL with `pg`)

```ts
// src/repositories/user.repository.pg.ts

import { Pool } from 'pg';
import { UserRepository } from './user.repository.interface';
import { User, CreateUserDto, UpdateUserDto } from '../models/user.model';

export class PgUserRepository implements UserRepository {
  constructor(private readonly pool: Pool) {}

  async findById(id: string): Promise<User | null> {
    const result = await this.pool.query(
      'SELECT * FROM users WHERE id = $1',
      [id]
    );
    return result.rows[0] ?? null;
  }

  async findAll(): Promise<User[]> {
    const result = await this.pool.query('SELECT * FROM users');
    return result.rows;
  }

  async create(data: CreateUserDto): Promise<User> {
    const result = await this.pool.query(
      'INSERT INTO users (name, email) VALUES ($1, $2) RETURNING *',
      [data.name, data.email]
    );
    return result.rows[0];
  }

  async update(id: string, data: UpdateUserDto): Promise<User | null> {
    const fields: string[] = [];
    const values: unknown[] = [];
    let idx = 1;

    if (data.name !== undefined) {
      fields.push(`name = $${idx++}`);
      values.push(data.name);
    }
    if (data.email !== undefined) {
      fields.push(`email = $${idx++}`);
      values.push(data.email);
    }
    if (fields.length === 0) return null;

    values.push(id);
    const result = await this.pool.query(
      `UPDATE users SET ${fields.join(', ')} WHERE id = $${idx} RETURNING *`,
      values
    );
    return result.rows[0] ?? null;
  }

  async delete(id: string): Promise<boolean> {
    const result = await this.pool.query(
      'DELETE FROM users WHERE id = $1',
      [id]
    );
    return (result.rowCount ?? 0) > 0;
  }
}
```

---

### Registering the Repository via Fastify Decorators

Fastify's decorator system is the standard mechanism for making shared resources available across the application. Repositories are typically registered as decorators on the Fastify instance.

```ts
// src/plugins/repositories.plugin.ts

import fp from 'fastify-plugin';
import { FastifyPluginAsync } from 'fastify';
import { PgUserRepository } from '../repositories/user.repository.pg';

const repositoriesPlugin: FastifyPluginAsync = async (fastify) => {
  // Assumes fastify.pg is already decorated (e.g., via @fastify/postgres)
  const userRepository = new PgUserRepository(fastify.pg.pool);

  fastify.decorate('repositories', {
    user: userRepository,
  });
};

export default fp(repositoriesPlugin, {
  name: 'repositories',
  dependencies: ['postgres'], // name of the postgres plugin
});
```

**Key Points:**
- `fp` (fastify-plugin) removes Fastify's plugin encapsulation, making the decorator visible across the entire app
- `dependencies` declares that the postgres plugin must be registered first
- The decorator name (`repositories`) is a convention; teams may choose any name

#### TypeScript Augmentation

```ts
// src/@types/fastify/index.d.ts

import { UserRepository } from '../../repositories/user.repository.interface';

declare module 'fastify' {
  interface FastifyInstance {
    repositories: {
      user: UserRepository;
    };
  }
}
```

---

### Using the Repository in Route Handlers

```ts
// src/routes/users/index.ts

import { FastifyPluginAsync } from 'fastify';

const usersRoute: FastifyPluginAsync = async (fastify) => {
  fastify.get('/:id', async (request, reply) => {
    const { id } = request.params as { id: string };
    const user = await fastify.repositories.user.findById(id);

    if (!user) {
      return reply.code(404).send({ message: 'User not found' });
    }

    return user;
  });

  fastify.post('/', async (request, reply) => {
    const body = request.body as { name: string; email: string };
    const user = await fastify.repositories.user.create(body);
    return reply.code(201).send(user);
  });
};

export default usersRoute;
```

Route handlers reference `fastify.repositories.user` — they are never aware of the underlying SQL or database driver.

---

### Repository Pattern with a Service Layer

For larger applications, a service layer sits between route handlers and repositories. Services coordinate business logic that may span multiple repositories.

```
Route Handler → Service → Repository → Database
```

```ts
// src/services/user.service.ts

import { UserRepository } from '../repositories/user.repository.interface';
import { User, CreateUserDto } from '../models/user.model';

export class UserService {
  constructor(private readonly userRepo: UserRepository) {}

  async getUser(id: string): Promise<User> {
    const user = await this.userRepo.findById(id);
    if (!user) throw new Error(`User ${id} not found`);
    return user;
  }

  async registerUser(data: CreateUserDto): Promise<User> {
    // Business rule: enforce unique email [Inference] — actual enforcement
    // depends on a DB constraint or an explicit pre-check query
    return this.userRepo.create(data);
  }
}
```

```ts
// src/plugins/services.plugin.ts

import fp from 'fastify-plugin';
import { FastifyPluginAsync } from 'fastify';
import { UserService } from '../services/user.service';

const servicesPlugin: FastifyPluginAsync = async (fastify) => {
  fastify.decorate('services', {
    user: new UserService(fastify.repositories.user),
  });
};

export default fp(servicesPlugin, {
  name: 'services',
  dependencies: ['repositories'],
});
```

```ts
// src/@types/fastify/index.d.ts (augmented)

import { UserService } from '../../services/user.service';

declare module 'fastify' {
  interface FastifyInstance {
    services: {
      user: UserService;
    };
  }
}
```

---

### In-Memory Repository for Testing

```ts
// src/repositories/user.repository.memory.ts

import { UserRepository } from './user.repository.interface';
import { User, CreateUserDto, UpdateUserDto } from '../models/user.model';
import { randomUUID } from 'crypto';

export class InMemoryUserRepository implements UserRepository {
  private store = new Map<string, User>();

  async findById(id: string): Promise<User | null> {
    return this.store.get(id) ?? null;
  }

  async findAll(): Promise<User[]> {
    return Array.from(this.store.values());
  }

  async create(data: CreateUserDto): Promise<User> {
    const user: User = {
      id: randomUUID(),
      ...data,
      createdAt: new Date(),
    };
    this.store.set(user.id, user);
    return user;
  }

  async update(id: string, data: UpdateUserDto): Promise<User | null> {
    const existing = this.store.get(id);
    if (!existing) return null;
    const updated = { ...existing, ...data };
    this.store.set(id, updated);
    return updated;
  }

  async delete(id: string): Promise<boolean> {
    return this.store.delete(id);
  }
}
```

**Example** test using `InMemoryUserRepository`:

```ts
import { UserService } from '../src/services/user.service';
import { InMemoryUserRepository } from '../src/repositories/user.repository.memory';

test('registerUser creates a user', async () => {
  const repo = new InMemoryUserRepository();
  const service = new UserService(repo);

  const user = await service.registerUser({ name: 'Luke', email: 'luke@example.com' });

  expect(user.id).toBeDefined();
  expect(user.name).toBe('Luke');
});
```

No database connection or Fastify instance is needed for this test. [Inference] This pattern typically reduces test setup complexity, though actual test performance depends on the test runner and environment configuration.

---

### Application Wiring Order

The order of plugin registration matters. Fastify resolves dependencies serially.

```
app.ts
  └── register(postgresPlugin)       // decorates fastify.pg
  └── register(repositoriesPlugin)   // decorates fastify.repositories
  └── register(servicesPlugin)       // decorates fastify.services
  └── register(routes)               // uses fastify.services or fastify.repositories
```

```ts
// src/app.ts

import Fastify from 'fastify';
import postgresPlugin from './plugins/postgres.plugin';
import repositoriesPlugin from './plugins/repositories.plugin';
import servicesPlugin from './plugins/services.plugin';
import usersRoute from './routes/users';

const build = async () => {
  const fastify = Fastify({ logger: true });

  await fastify.register(postgresPlugin);
  await fastify.register(repositoriesPlugin);
  await fastify.register(servicesPlugin);
  await fastify.register(usersRoute, { prefix: '/users' });

  return fastify;
};

export default build;
```

---

### Architecture Diagram

<svg viewBox="0 0 720 400" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="13">
  <!-- Route Handler -->
  <rect x="20" y="160" width="150" height="60" rx="8" fill="#1e3a5f" stroke="#4a90d9" stroke-width="1.5"/>
  <text x="95" y="185" text-anchor="middle" fill="#e0f0ff" font-weight="bold">Route Handler</text>
  <text x="95" y="203" text-anchor="middle" fill="#a0c8f0" font-size="11">GET /users/:id</text>

  <!-- Arrow 1 -->
  <line x1="170" y1="190" x2="210" y2="190" stroke="#4a90d9" stroke-width="1.5" marker-end="url(#arrow)"/>

  <!-- Service -->
  <rect x="210" y="160" width="140" height="60" rx="8" fill="#1e3a5f" stroke="#4a90d9" stroke-width="1.5"/>
  <text x="280" y="185" text-anchor="middle" fill="#e0f0ff" font-weight="bold">Service</text>
  <text x="280" y="203" text-anchor="middle" fill="#a0c8f0" font-size="11">UserService</text>

  <!-- Arrow 2 -->
  <line x1="350" y1="190" x2="390" y2="190" stroke="#4a90d9" stroke-width="1.5" marker-end="url(#arrow)"/>

  <!-- Repository Interface -->
  <rect x="390" y="140" width="150" height="40" rx="8" fill="#2a2a2a" stroke="#aaa" stroke-width="1" stroke-dasharray="5,3"/>
  <text x="465" y="165" text-anchor="middle" fill="#ccc" font-size="11">«interface»</text>

  <!-- Concrete Repo -->
  <rect x="390" y="195" width="150" height="60" rx="8" fill="#1e3a5f" stroke="#4a90d9" stroke-width="1.5"/>
  <text x="465" y="220" text-anchor="middle" fill="#e0f0ff" font-weight="bold">Repository</text>
  <text x="465" y="238" text-anchor="middle" fill="#a0c8f0" font-size="11">PgUserRepository</text>

  <!-- Dashed implements line -->
  <line x1="465" y1="180" x2="465" y2="195" stroke="#aaa" stroke-width="1" stroke-dasharray="4,3"/>

  <!-- Arrow 3 -->
  <line x1="540" y1="225" x2="580" y2="225" stroke="#4a90d9" stroke-width="1.5" marker-end="url(#arrow)"/>

  <!-- Database -->
  <rect x="580" y="195" width="120" height="60" rx="8" fill="#1a3320" stroke="#4caf77" stroke-width="1.5"/>
  <text x="640" y="220" text-anchor="middle" fill="#b8f0cc" font-weight="bold">Database</text>
  <text x="640" y="238" text-anchor="middle" fill="#80c8a0" font-size="11">PostgreSQL</text>

  <!-- Test swap note -->
  <rect x="390" y="295" width="150" height="55" rx="8" fill="#3a2a00" stroke="#f0a020" stroke-width="1" stroke-dasharray="5,3"/>
  <text x="465" y="318" text-anchor="middle" fill="#ffd070" font-size="11">«test substitute»</text>
  <text x="465" y="335" text-anchor="middle" fill="#ffd070" font-size="11">InMemoryUserRepo</text>

  <!-- Swap arrow -->
  <line x1="465" y1="255" x2="465" y2="295" stroke="#f0a020" stroke-width="1" stroke-dasharray="4,3" marker-end="url(#arrowOrange)"/>

  <!-- Arrow marker -->
  <defs>
    <marker id="arrow" markerWidth="8" markerHeight="8" refX="6" refY="3" orient="auto">
      <path d="M0,0 L0,6 L8,3 z" fill="#4a90d9"/>
    </marker>
    <marker id="arrowOrange" markerWidth="8" markerHeight="8" refX="6" refY="3" orient="auto">
      <path d="M0,0 L0,6 L8,3 z" fill="#f0a020"/>
    </marker>
  </defs>

  <!-- Labels -->
  <text x="95" y="145" text-anchor="middle" fill="#888" font-size="11">fastify.services.user</text>
  <text x="280" y="145" text-anchor="middle" fill="#888" font-size="11">injected via constructor</text>
</svg>

---

### Common Mistakes

#### Leaking Query Logic into Route Handlers

```ts
// Bad — raw SQL in route handler
fastify.get('/:id', async (request, reply) => {
  const result = await fastify.pg.query('SELECT * FROM users WHERE id = $1', [request.params.id]);
  return result.rows[0];
});
```

```ts
// Correct — delegate to repository
fastify.get('/:id', async (request, reply) => {
  return fastify.repositories.user.findById(request.params.id);
});
```

#### Forgetting `fastify-plugin` on Repository Registration

Without `fp`, the decorator is scoped to the plugin's encapsulation context and will not be visible to sibling or parent scopes. Route handlers registered outside that scope will throw a `fastify.repositories is not a function` or similar error at runtime.

#### Tight Coupling to a Specific ORM

Importing Prisma or TypeORM types directly into your service layer ties the service to the ORM. Define interfaces using your own domain types and keep ORM types inside the repository implementation only.

---

### Folder Structure Recommendation

```
src/
├── models/
│   └── user.model.ts
├── repositories/
│   ├── user.repository.interface.ts
│   ├── user.repository.pg.ts
│   └── user.repository.memory.ts
├── services/
│   └── user.service.ts
├── plugins/
│   ├── postgres.plugin.ts
│   ├── repositories.plugin.ts
│   └── services.plugin.ts
├── routes/
│   └── users/
│       └── index.ts
├── @types/
│   └── fastify/
│       └── index.d.ts
└── app.ts
```

---

**Related Topics:**
- Service layer pattern in Fastify — structuring business logic between routes and repositories
- Unit testing Fastify with fake/mock repositories using Vitest or Jest
- Dependency injection containers (e.g., `awilix`) with Fastify
- Using Prisma or Drizzle ORM as repository implementations
- Multi-repository transactions — coordinating writes across repositories
- CQRS (Command Query Responsibility Segregation) as an extension of the repository pattern
- Integration testing Fastify routes with a real database using test containers