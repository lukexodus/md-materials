## Hexagonal Architecture with tRPC

---

### Overview

Hexagonal architecture — also called Ports and Adapters — is a structural pattern that isolates application business logic from external systems. The core idea is that the application defines **ports** (interfaces expressing what it needs) and external systems connect through **adapters** (implementations of those interfaces). The business logic never depends directly on a database driver, HTTP framework, or third-party SDK.

In the context of tRPC, hexagonal architecture positions tRPC as an **inbound adapter** — one of potentially many ways the application core can be driven. The database, mailer, and cache are **outbound adapters**. The application core contains use cases, domain entities, and domain services that depend on nothing external.

This is a significant architectural commitment. It is appropriate for systems where long-term maintainability, testability, and the ability to swap infrastructure are genuine requirements — not for every tRPC project.

---

### Core Concepts Mapped to tRPC

| Hexagonal Concept | tRPC Equivalent |
| --- | --- |
| Inbound port | Use case interface (e.g., `IRegisterUser`) |
| Inbound adapter | tRPC procedure (drives the use case) |
| Outbound port | Repository / service interface (e.g., `IUserRepository`) |
| Outbound adapter | Prisma repository, SMTP mailer, Redis cache |
| Application core | Use cases + domain entities (no tRPC, no Prisma) |
| Domain entity | Plain TypeScript class or object with business rules |

---

### Directory Structure

A hexagonal tRPC project separates concerns into distinct layers with strict dependency rules:

```
src/
  core/                          ← application core — no framework imports
    domain/
      entities/
        User.ts                  ← domain entity
        Post.ts
      errors/
        DomainError.ts
    ports/
      inbound/
        IRegisterUser.ts         ← inbound port (use case interface)
        ICreatePost.ts
      outbound/
        IUserRepository.ts       ← outbound port (repository interface)
        IPostRepository.ts
        IMailer.ts
    usecases/
      RegisterUser.ts            ← use case implementation
      CreatePost.ts
  adapters/
    inbound/
      trpc/                      ← tRPC as inbound adapter
        routers/
          user.ts
          post.ts
        context.ts
        trpc.ts
    outbound/
      prisma/                    ← Prisma as outbound adapter
        PrismaUserRepository.ts
        PrismaPostRepository.ts
      smtp/
        SmtpMailer.ts
      redis/
        RedisCacheAdapter.ts
  composition/
    container.ts                 ← wires everything together
```

**Dependency rule:** imports must flow inward only. `adapters/` may import from `core/`. `core/` must never import from `adapters/`.

---

### Domain Entities

Domain entities encapsulate business rules. They are plain TypeScript — no ORM decorators, no framework dependencies.

```ts
// src/core/domain/entities/User.ts

export interface UserProps {
  id: string;
  email: string;
  role: 'member' | 'admin' | 'owner';
  active: boolean;
  createdAt: Date;
}

export class User {
  private constructor(private readonly props: UserProps) {}

  static create(props: UserProps): User {
    if (!props.email.includes('@')) {
      throw new Error('Invalid email address.');
    }
    return new User(props);
  }

  get id() { return this.props.id; }
  get email() { return this.props.email; }
  get role() { return this.props.role; }
  get active() { return this.props.active; }

  isAdmin(): boolean {
    return this.props.role === 'admin' || this.props.role === 'owner';
  }

  deactivate(): User {
    return new User({ ...this.props, active: false });
  }

  toObject(): UserProps {
    return { ...this.props };
  }
}
```

**Key Points:**

- The entity enforces its own invariants (email format) at construction time
- `deactivate()` returns a new `User` rather than mutating — immutable value semantics
- No `import` from Prisma, tRPC, or any external library
- `toObject()` provides a plain serializable form for adapters to persist or return

---

### Outbound Ports

Outbound ports are interfaces the application core defines to express what it needs from infrastructure. The core depends on these interfaces — never on their implementations.

```ts
// src/core/ports/outbound/IUserRepository.ts
import type { User } from '../../domain/entities/User';

export interface IUserRepository {
  findById(id: string): Promise<User | null>;
  findByEmail(email: string): Promise<User | null>;
  save(user: User): Promise<void>;
  delete(id: string): Promise<void>;
}
```

```ts
// src/core/ports/outbound/IMailer.ts
export interface IMailer {
  sendWelcome(email: string): Promise<void>;
  sendPasswordReset(email: string, token: string): Promise<void>;
}
```

---

### Inbound Ports

Inbound ports define use case contracts — what the application core can do. Inbound adapters (tRPC procedures) call these.

```ts
// src/core/ports/inbound/IRegisterUser.ts
export interface RegisterUserInput {
  email: string;
}

export interface RegisterUserOutput {
  userId: string;
  email: string;
}

export interface IRegisterUser {
  execute(input: RegisterUserInput): Promise<RegisterUserOutput>;
}
```

```ts
// src/core/ports/inbound/IDeactivateUser.ts
export interface DeactivateUserInput {
  userId: string;
  requestingUserId: string;
}

export interface IDeactivateUser {
  execute(input: DeactivateUserInput): Promise<void>;
}
```

---

### Use Cases

Use cases implement inbound ports. They orchestrate domain entities and call outbound ports. They contain all application business logic.

```ts
// src/core/usecases/RegisterUser.ts
import { User } from '../domain/entities/User';
import type { IRegisterUser, RegisterUserInput, RegisterUserOutput } from '../ports/inbound/IRegisterUser';
import type { IUserRepository } from '../ports/outbound/IUserRepository';
import type { IMailer } from '../ports/outbound/IMailer';
import { randomUUID } from 'crypto';

export class RegisterUser implements IRegisterUser {
  constructor(
    private readonly userRepository: IUserRepository,
    private readonly mailer: IMailer
  ) {}

  async execute(input: RegisterUserInput): Promise<RegisterUserOutput> {
    const existing = await this.userRepository.findByEmail(input.email);

    if (existing) {
      throw new Error('Email already registered.');
    }

    const user = User.create({
      id: randomUUID(),
      email: input.email,
      role: 'member',
      active: true,
      createdAt: new Date(),
    });

    await this.userRepository.save(user);
    await this.mailer.sendWelcome(user.email);

    return { userId: user.id, email: user.email };
  }
}
```

```ts
// src/core/usecases/DeactivateUser.ts
import type { IDeactivateUser, DeactivateUserInput } from '../ports/inbound/IDeactivateUser';
import type { IUserRepository } from '../ports/outbound/IUserRepository';

export class DeactivateUser implements IDeactivateUser {
  constructor(private readonly userRepository: IUserRepository) {}

  async execute({ userId, requestingUserId }: DeactivateUserInput): Promise<void> {
    const requestor = await this.userRepository.findById(requestingUserId);

    if (!requestor?.isAdmin()) {
      throw new Error('Only admins may deactivate users.');
    }

    const target = await this.userRepository.findById(userId);

    if (!target) {
      throw new Error('User not found.');
    }

    await this.userRepository.save(target.deactivate());
  }
}
```

**Key Points:**

- No imports from Prisma, tRPC, Express, or any external system
- Dependencies (`IUserRepository`, `IMailer`) are constructor-injected as interfaces
- Business rules live here — authorization, uniqueness, state transitions
- Use cases are independently testable: construct with fakes, call `execute()`, assert on results

---

### Outbound Adapters

Outbound adapters implement the outbound ports using concrete infrastructure. They translate between domain entities and infrastructure-specific types.

```ts
// src/adapters/outbound/prisma/PrismaUserRepository.ts
import type { PrismaClient } from '@prisma/client';
import { User } from '../../../core/domain/entities/User';
import type { IUserRepository } from '../../../core/ports/outbound/IUserRepository';

export class PrismaUserRepository implements IUserRepository {
  constructor(private readonly db: PrismaClient) {}

  async findById(id: string): Promise<User | null> {
    const record = await this.db.user.findUnique({ where: { id } });
    if (!record) return null;
    return User.create(record); // map DB record → domain entity
  }

  async findByEmail(email: string): Promise<User | null> {
    const record = await this.db.user.findUnique({ where: { email } });
    if (!record) return null;
    return User.create(record);
  }

  async save(user: User): Promise<void> {
    const data = user.toObject();
    await this.db.user.upsert({
      where: { id: data.id },
      create: data,
      update: data,
    });
  }

  async delete(id: string): Promise<void> {
    await this.db.user.delete({ where: { id } });
  }
}
```

**Key Points:**

- The adapter knows about both Prisma and the domain entity — it bridges them
- Domain entities are reconstructed from database records via `User.create()`
- The application core never sees a Prisma record type — it only ever handles `User` instances
- Swapping to a different ORM means writing a new adapter class, not touching any use case

---

### Inbound Adapter: tRPC Router

tRPC procedures are the inbound adapters. They validate input, call use cases via inbound port interfaces, and return serializable output.

```ts
// src/adapters/inbound/trpc/routers/user.ts
import { z } from 'zod';
import { router, publicProcedure, adminProcedure } from '../trpc';
import { TRPCError } from '@trpc/server';

export const userRouter = router({
  register: publicProcedure
    .input(z.object({ email: z.string().email() }))
    .mutation(async ({ input, ctx }) => {
      try {
        return await ctx.usecases.registerUser.execute(input);
      } catch (error) {
        if (error instanceof Error && error.message === 'Email already registered.') {
          throw new TRPCError({ code: 'CONFLICT', message: error.message });
        }
        throw new TRPCError({ code: 'INTERNAL_SERVER_ERROR' });
      }
    }),

  deactivate: adminProcedure
    .input(z.object({ userId: z.string() }))
    .mutation(async ({ input, ctx }) => {
      try {
        await ctx.usecases.deactivateUser.execute({
          userId: input.userId,
          requestingUserId: ctx.session.user.id,
        });
        return { success: true };
      } catch (error) {
        if (error instanceof Error) {
          throw new TRPCError({ code: 'FORBIDDEN', message: error.message });
        }
        throw new TRPCError({ code: 'INTERNAL_SERVER_ERROR' });
      }
    }),
});
```

**Key Points:**

- The procedure's only responsibilities are input validation, use case invocation, and error translation
- Application errors (domain exceptions) are caught and translated to `TRPCError` codes here — not inside use cases
- Use cases are accessed via `ctx.usecases` — injected through context, typed as inbound port interfaces
- The procedure has no knowledge of the database, mailer, or any outbound adapter

---

### Composition Root

The composition root wires all ports and adapters together. This is the only place that knows about concrete implementations.

```ts
// src/composition/container.ts
import { PrismaClient } from '@prisma/client';
import { PrismaUserRepository } from '../adapters/outbound/prisma/PrismaUserRepository';
import { SmtpMailer } from '../adapters/outbound/smtp/SmtpMailer';
import { RegisterUser } from '../core/usecases/RegisterUser';
import { DeactivateUser } from '../core/usecases/DeactivateUser';

const db = new PrismaClient();
const userRepository = new PrismaUserRepository(db);
const mailer = new SmtpMailer(process.env.SMTP_URL!);

export const usecases = {
  registerUser: new RegisterUser(userRepository, mailer),
  deactivateUser: new DeactivateUser(userRepository),
};

export type Usecases = typeof usecases;
```

```ts
// src/adapters/inbound/trpc/context.ts
import { inferAsyncReturnType } from '@trpc/server';
import type { CreateNextContextOptions } from '@trpc/server/adapters/next';
import { usecases } from '../../../composition/container';
import { getSession } from './auth';

export async function createContext({ req }: CreateNextContextOptions) {
  return {
    session: await getSession(req),
    usecases,
  };
}

export type Context = inferAsyncReturnType<typeof createContext>;
```

---

### Visualizing the Architecture

Outbound AdaptersApplication CoreInbound Adapterscallscallscallscallsimplemented byimplemented byimplemented bytRPC ProceduresREST Handler - optionalCLI Script - optionalInbound PortsIRegisterUser,IDeactivateUserUse CasesRegisterUser,DeactivateUserDomain EntitiesUser, PostOutbound PortsIUserRepository, IMailerPrismaUserRepositorySmtpMailerRedisCacheAdapter

---

### Testing at Each Layer

The hexagonal structure enables isolated testing at every layer.

#### Use Case Tests (no tRPC, no database)

```ts
// tests/core/usecases/RegisterUser.test.ts
import { RegisterUser } from '../../../src/core/usecases/RegisterUser';
import type { IUserRepository } from '../../../src/core/ports/outbound/IUserRepository';
import type { IMailer } from '../../../src/core/ports/outbound/IMailer';

const makeRepo = (overrides: Partial<IUserRepository> = {}): IUserRepository => ({
  findById: async () => null,
  findByEmail: async () => null,
  save: async () => {},
  delete: async () => {},
  ...overrides,
});

const makeMailer = (): IMailer & { sent: string[] } => {
  const sent: string[] = [];
  return {
    sent,
    sendWelcome: async (email) => { sent.push(email); },
    sendPasswordReset: async () => {},
  };
};

describe('RegisterUser', () => {
  it('creates and saves a new user', async () => {
    const saved: any[] = [];
    const repo = makeRepo({ save: async (user) => { saved.push(user); } });
    const mailer = makeMailer();

    const usecase = new RegisterUser(repo, mailer);
    const result = await usecase.execute({ email: 'test@example.com' });

    expect(result.email).toBe('test@example.com');
    expect(saved).toHaveLength(1);
    expect(mailer.sent).toContain('test@example.com');
  });

  it('rejects duplicate emails', async () => {
    const existingUser = { id: 'u1', email: 'test@example.com' } as any;
    const repo = makeRepo({ findByEmail: async () => existingUser });
    const mailer = makeMailer();

    const usecase = new RegisterUser(repo, mailer);

    await expect(
      usecase.execute({ email: 'test@example.com' })
    ).rejects.toThrow('Email already registered.');
  });
});
```

#### Adapter Tests (isolated from use cases)

```ts
// tests/adapters/outbound/PrismaUserRepository.test.ts
// Uses a test database or an in-memory SQLite instance via Prisma
import { PrismaClient } from '@prisma/client';
import { PrismaUserRepository } from '../../../src/adapters/outbound/prisma/PrismaUserRepository';
import { User } from '../../../src/core/domain/entities/User';

const db = new PrismaClient({ datasourceUrl: process.env.TEST_DATABASE_URL });
const repo = new PrismaUserRepository(db);

it('saves and retrieves a user', async () => {
  const user = User.create({
    id: 'test-id',
    email: 'adapter@test.com',
    role: 'member',
    active: true,
    createdAt: new Date(),
  });

  await repo.save(user);
  const found = await repo.findByEmail('adapter@test.com');

  expect(found?.id).toBe('test-id');
});
```

---

### Trade-offs

**Benefits:**

- The application core is fully testable without any infrastructure
- Adapters are independently replaceable — swap Prisma for Drizzle by writing a new repository class
- tRPC is not load-bearing for business logic — the same use cases can be driven by a REST handler, a CLI script, or a queue worker
- Domain logic is co-located and visible, not scattered across router files

**Costs:**

- Significantly more files and indirection than a direct tRPC + Prisma setup
- Domain errors must be explicitly caught and translated at the adapter boundary — this is repetitive
- TypeScript generics across port interfaces and entity mappings can become verbose
- The pattern is most valuable under active, long-term development — for short-lived or low-complexity projects, the overhead may not be warranted [Inference]

---

### When to Apply

Apply hexagonal architecture with tRPC when:

- The domain has meaningful business rules that benefit from isolation and explicit modeling
- The project will be maintained over years with multiple contributors
- Infrastructure changes (ORM migration, cloud provider swap) are anticipated
- The same application core must be accessible through multiple inbound adapters (tRPC API, background workers, CLI tools)

Consider simpler patterns when:

- The application is primarily CRUD with minimal business logic
- The team is small and the project has a short or uncertain lifespan
- Delivery speed is the primary constraint

---

**Conclusion**

Hexagonal architecture positions tRPC as one inbound adapter among potentially many, rather than the backbone of the application. The application core — use cases, domain entities, and port interfaces — depends on nothing external. tRPC procedures handle input validation and error translation; Prisma repositories handle persistence; the composition root wires everything together. The architecture's primary payoff is testability and replaceability at every layer, at the cost of structural complexity that is only justified when the domain and maintenance horizon warrant it.