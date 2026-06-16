## Writing Tests for All Layers

Testing a tRPC application requires covering multiple distinct layers — each with different concerns, different tools, and different failure modes. A test strategy that only covers one layer produces false confidence: unit tests alone miss integration failures; end-to-end tests alone are too slow and brittle for fast feedback loops. This topic covers a complete, layered testing approach for tRPC applications.

---

### Testing Layer Overview

```mermaid
graph TD
  E2E["End-to-End Tests\n(Playwright / Cypress)\nFull stack, browser, real DB"]
  Integration["Integration Tests\n(Vitest / Jest + real DB or test DB)\nRouter → DB round-trips"]
  Router["Router / Procedure Tests\n(Vitest / Jest + createCaller)\nMiddleware, validation, business logic"]
  Unit["Unit Tests\n(Vitest / Jest)\nValidators, utilities, service functions"]

  E2E --> Integration --> Router --> Unit
```

| Layer | Speed | Confidence | Isolation |
|---|---|---|---|
| Unit | Very fast | Low — no integration | High |
| Router / Procedure | Fast | High — full middleware chain | Medium |
| Integration | Medium | Very high — real DB | Low |
| End-to-End | Slow | Highest — real browser | None |

**Key Points**

- The pyramid shape is intentional — many unit tests, fewer integration tests, fewer still E2E tests
- Router/procedure tests using `createCaller` are the highest-value layer for tRPC specifically — they exercise the full middleware chain without HTTP overhead
- [Inference] Skipping the router/procedure layer and testing only via HTTP increases test latency and couples tests to transport concerns irrelevant to business logic

---

### Test Infrastructure Setup

#### Choosing a Test Runner

Vitest is the recommended test runner for tRPC projects, particularly those using Vite-based frameworks. Jest remains viable for non-Vite setups.

```bash
# Vitest
npm install -D vitest @vitest/coverage-v8

# Jest (for non-Vite projects)
npm install -D jest ts-jest @types/jest
```

```ts
// vitest.config.ts
import { defineConfig } from 'vitest/config';

export default defineConfig({
  test: {
    environment: 'node',
    globals: true,
    setupFiles: ['./test/setup.ts'],
    coverage: {
      provider: 'v8',
      include: ['src/server/**/*.ts'],
      exclude: ['src/server/routers/_app.ts'], // composition-only file
    },
  },
});
```

---

#### Test Database Setup

Integration and router tests that touch the database require a controlled database environment.

**Option 1 — Dedicated test database (recommended)**

```ts
// test/setup.ts
import { execSync } from 'child_process';
import { PrismaClient } from '@prisma/client';

const TEST_DATABASE_URL =
  process.env.TEST_DATABASE_URL ??
  'postgresql://postgres:postgres@localhost:5432/myapp_test';

process.env.DATABASE_URL = TEST_DATABASE_URL;

// Run migrations before the test suite
beforeAll(async () => {
  execSync('npx prisma migrate deploy', {
    env: { ...process.env, DATABASE_URL: TEST_DATABASE_URL },
  });
});
```

**Option 2 — Per-test transaction rollback**

Each test runs inside a transaction that is rolled back on completion, leaving the database clean without truncation:

```ts
// test/helpers/db.ts
import { PrismaClient } from '@prisma/client';

let prisma: PrismaClient;

export function getTestDb() {
  if (!prisma) {
    prisma = new PrismaClient({
      datasources: { db: { url: process.env.TEST_DATABASE_URL } },
    });
  }
  return prisma;
}

// Per-test isolation using $transaction + rollback
export async function withTestDb<T>(
  fn: (db: PrismaClient) => Promise<T>
): Promise<T> {
  const db = getTestDb();
  let result: T;

  // Note: Prisma does not natively support manual transaction rollback
  // for test isolation — use a dedicated truncation helper or
  // a library like prisma-test-environment for this pattern
  result = await fn(db);
  await truncateAllTables(db);
  return result;
}

async function truncateAllTables(db: PrismaClient) {
  const tables = await db.$queryRaw<{ tablename: string }[]>`
    SELECT tablename FROM pg_tables WHERE schemaname = 'public'
  `;
  for (const { tablename } of tables) {
    await db.$executeRawUnsafe(`TRUNCATE TABLE "${tablename}" CASCADE`);
  }
}
```

**Key Points**

- Transaction rollback per test is the cleanest isolation strategy — truncation is an acceptable alternative
- [Inference] Prisma does not expose a native mechanism for rolling back test transactions in the same way Ecto (Elixir) or Rails do — truncation after each test is the most common pattern in Prisma-based projects
- Using a separate `TEST_DATABASE_URL` is critical — tests must never run against a development or production database

---

#### Mock Context Factory

A mock context factory is the foundational test utility for tRPC procedure tests:

```ts
// test/helpers/context.ts
import { type Context } from '~/server/context';
import { getTestDb } from './db';

type MockUser = {
  id: string;
  email: string;
  name: string;
  role: 'ADMIN' | 'MEMBER' | 'VIEWER';
};

const defaultUser: MockUser = {
  id: 'user_test_01',
  email: 'test@example.com',
  name: 'Test User',
  role: 'MEMBER',
};

export function createMockContext(overrides: Partial<Context> = {}): Context {
  return {
    db: getTestDb(),
    user: null,
    session: null,
    ...overrides,
  };
}

export function createAuthedContext(
  userOverrides: Partial<MockUser> = {}
): Context {
  const user = { ...defaultUser, ...userOverrides };
  return createMockContext({
    user,
    session: {
      user,
      expires: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString(),
    },
  });
}

export function createAdminContext(): Context {
  return createAuthedContext({ role: 'ADMIN' });
}
```

---

### Unit Tests — Validators and Utilities

Unit tests cover pure functions: Zod schemas, utility functions, and service methods with mocked dependencies.

#### Testing Zod Schemas

```ts
// test/validators/task.test.ts
import { describe, it, expect } from 'vitest';
import { taskCreateSchema, taskUpdateSchema } from '~/lib/validators/task';

describe('taskCreateSchema', () => {
  it('accepts valid input', () => {
    const result = taskCreateSchema.safeParse({
      title: 'Fix bug #123',
      projectId: 'clh1234567890abcdef',
      priority: 'HIGH',
    });
    expect(result.success).toBe(true);
  });

  it('rejects empty title', () => {
    const result = taskCreateSchema.safeParse({
      title: '',
      projectId: 'clh1234567890abcdef',
    });
    expect(result.success).toBe(false);
    expect(result.error?.flatten().fieldErrors.title).toContain(
      'String must contain at least 1 character(s)'
    );
  });

  it('rejects title exceeding max length', () => {
    const result = taskCreateSchema.safeParse({
      title: 'a'.repeat(257),
      projectId: 'clh1234567890abcdef',
    });
    expect(result.success).toBe(false);
  });

  it('trims whitespace from title', () => {
    const result = taskCreateSchema.safeParse({
      title: '  Valid Title  ',
      projectId: 'clh1234567890abcdef',
    });
    expect(result.success).toBe(true);
    if (result.success) {
      expect(result.data.title).toBe('Valid Title');
    }
  });

  it('applies default priority', () => {
    const result = taskCreateSchema.safeParse({
      title: 'Task',
      projectId: 'clh1234567890abcdef',
    });
    expect(result.success).toBe(true);
    if (result.success) {
      expect(result.data.priority).toBe('MEDIUM');
    }
  });

  it('coerces date strings', () => {
    const result = taskCreateSchema.safeParse({
      title: 'Task',
      projectId: 'clh1234567890abcdef',
      dueDate: '2025-12-31',
    });
    expect(result.success).toBe(true);
    if (result.success) {
      expect(result.data.dueDate).toBeInstanceOf(Date);
    }
  });
});

describe('taskUpdateSchema', () => {
  it('requires id', () => {
    const result = taskUpdateSchema.safeParse({ title: 'Updated' });
    expect(result.success).toBe(false);
  });

  it('rejects update with only id and no other fields', () => {
    const result = taskUpdateSchema.safeParse({ id: 'clh1234567890abcdef' });
    expect(result.success).toBe(false);
  });

  it('accepts partial update', () => {
    const result = taskUpdateSchema.safeParse({
      id: 'clh1234567890abcdef',
      title: 'New Title',
    });
    expect(result.success).toBe(true);
  });
});
```

---

#### Testing Service Functions

```ts
// test/services/task.service.test.ts
import { describe, it, expect, vi, beforeEach } from 'vitest';
import { TaskService } from '~/server/services/task.service';

// Mock the database client
const mockDb = {
  task: {
    create: vi.fn(),
    findUnique: vi.fn(),
  },
  project: {
    findUnique: vi.fn(),
  },
  projectMember: {
    findUnique: vi.fn(),
  },
};

describe('TaskService', () => {
  let service: TaskService;

  beforeEach(() => {
    vi.clearAllMocks();
    service = new TaskService(mockDb as any);
  });

  describe('createTask', () => {
    it('throws when project does not exist', async () => {
      mockDb.project.findUnique.mockResolvedValue(null);

      await expect(
        service.createTask(
          { title: 'Task', projectId: 'proj_123', priority: 'MEDIUM' },
          'user_123'
        )
      ).rejects.toThrow('Project not found');
    });

    it('throws when user is not a project member', async () => {
      mockDb.project.findUnique.mockResolvedValue({ id: 'proj_123' });
      mockDb.projectMember.findUnique.mockResolvedValue(null);

      await expect(
        service.createTask(
          { title: 'Task', projectId: 'proj_123', priority: 'MEDIUM' },
          'user_123'
        )
      ).rejects.toThrow('Not a project member');
    });

    it('creates task for valid member', async () => {
      const mockTask = { id: 'task_123', title: 'Task' };
      mockDb.project.findUnique.mockResolvedValue({ id: 'proj_123' });
      mockDb.projectMember.findUnique.mockResolvedValue({ userId: 'user_123' });
      mockDb.task.create.mockResolvedValue(mockTask);

      const result = await service.createTask(
        { title: 'Task', projectId: 'proj_123', priority: 'MEDIUM' },
        'user_123'
      );

      expect(result).toEqual(mockTask);
      expect(mockDb.task.create).toHaveBeenCalledWith(
        expect.objectContaining({
          data: expect.objectContaining({
            title: 'Task',
            createdById: 'user_123',
          }),
        })
      );
    });
  });
});
```

**Key Points**

- `vi.fn()` (Vitest) or `jest.fn()` creates mock implementations — verify both call arguments and return values
- `vi.clearAllMocks()` in `beforeEach` prevents state leakage between tests
- Service tests with mocked DB are fast and isolate business logic from persistence — they do not verify that queries are correct SQL

---

### Router / Procedure Tests

This is the highest-value test layer for tRPC. `createCaller` exercises the full procedure chain — middleware, validation, business logic — without HTTP.

#### Testing Authentication Middleware

```ts
// test/routers/auth.test.ts
import { describe, it, expect } from 'vitest';
import { createCaller } from '~/server/routers/_app';
import { createMockContext, createAuthedContext } from '../helpers/context';

describe('authentication enforcement', () => {
  it('throws UNAUTHORIZED on protected procedure when unauthenticated', async () => {
    const caller = createCaller(createMockContext());

    await expect(
      caller.task.list({ projectId: 'proj_123' })
    ).rejects.toMatchObject({
      code: 'UNAUTHORIZED',
    });
  });

  it('allows access to public procedures when unauthenticated', async () => {
    const caller = createCaller(createMockContext());

    // Should not throw — publicProcedure requires no auth
    await expect(
      caller.health.ping()
    ).resolves.toBeDefined();
  });

  it('throws FORBIDDEN when role is insufficient', async () => {
    const caller = createCaller(createAuthedContext({ role: 'VIEWER' }));

    await expect(
      caller.task.purge({ projectId: 'proj_123' })
    ).rejects.toMatchObject({
      code: 'FORBIDDEN',
    });
  });

  it('allows admin to access admin-only procedures', async () => {
    const caller = createCaller(createAuthedContext({ role: 'ADMIN' }));

    await expect(
      caller.task.purge({ projectId: 'proj_123' })
    ).resolves.toBeDefined();
  });
});
```

---

#### Testing Input Validation at the Procedure Level

```ts
// test/routers/task.test.ts
describe('task.create — input validation', () => {
  it('throws BAD_REQUEST for empty title', async () => {
    const caller = createCaller(createAuthedContext());

    await expect(
      caller.task.create({ title: '', projectId: 'clh1234567890abcdef' })
    ).rejects.toMatchObject({ code: 'BAD_REQUEST' });
  });

  it('throws BAD_REQUEST for invalid projectId format', async () => {
    const caller = createCaller(createAuthedContext());

    await expect(
      caller.task.create({ title: 'Valid', projectId: 'not-a-cuid' })
    ).rejects.toMatchObject({ code: 'BAD_REQUEST' });
  });

  it('throws BAD_REQUEST for invalid priority enum value', async () => {
    const caller = createCaller(createAuthedContext());

    await expect(
      caller.task.create({
        title: 'Valid',
        projectId: 'clh1234567890abcdef',
        priority: 'URGENT' as any,
      })
    ).rejects.toMatchObject({ code: 'BAD_REQUEST' });
  });
});
```

---

#### Testing Business Logic with Real Database

```ts
// test/routers/task.integration.test.ts
import { describe, it, expect, beforeEach } from 'vitest';
import { createCaller } from '~/server/routers/_app';
import { createAuthedContext, createAdminContext } from '../helpers/context';
import { getTestDb, truncateAllTables } from '../helpers/db';

const db = getTestDb();

beforeEach(async () => {
  await truncateAllTables(db);
});

describe('task.create', () => {
  it('creates a task and returns it with relations', async () => {
    // Arrange — seed required data
    const user = await db.user.create({
      data: { id: 'user_test_01', email: 'test@example.com', name: 'Test' },
    });
    const workspace = await db.workspace.create({
      data: { name: 'WS', slug: 'ws', ownerId: user.id },
    });
    const project = await db.project.create({
      data: { name: 'Project', workspaceId: workspace.id },
    });
    await db.projectMember.create({
      data: { projectId: project.id, userId: user.id, role: 'MEMBER' },
    });

    const caller = createCaller(createAuthedContext({ id: user.id }));

    // Act
    const task = await caller.task.create({
      title: 'New Task',
      projectId: project.id,
      priority: 'HIGH',
    });

    // Assert
    expect(task).toMatchObject({
      title: 'New Task',
      priority: 'HIGH',
      createdById: user.id,
      projectId: project.id,
    });
    expect(task.id).toBeDefined();
  });

  it('throws NOT_FOUND when project does not exist', async () => {
    const caller = createCaller(createAuthedContext());

    await expect(
      caller.task.create({
        title: 'Task',
        projectId: 'clhnonexistent1234',
      })
    ).rejects.toMatchObject({ code: 'NOT_FOUND' });
  });

  it('throws FORBIDDEN when user is not a project member', async () => {
    const project = await db.project.create({ /* seed */ });
    const caller = createCaller(createAuthedContext({ id: 'other_user' }));

    await expect(
      caller.task.create({ title: 'Task', projectId: project.id })
    ).rejects.toMatchObject({ code: 'FORBIDDEN' });
  });
});

describe('task.list — pagination', () => {
  it('returns correct page with cursor', async () => {
    // Seed 25 tasks
    const tasks = await db.task.createMany({ data: Array.from({ length: 25 }, (_, i) => ({
      title: `Task ${i + 1}`,
      projectId: 'proj_123',
      createdById: 'user_test_01',
    }))});

    const caller = createCaller(createAuthedContext());

    const page1 = await caller.task.list({ projectId: 'proj_123', limit: 10 });
    expect(page1.items).toHaveLength(10);
    expect(page1.nextCursor).toBeDefined();

    const page2 = await caller.task.list({
      projectId: 'proj_123',
      limit: 10,
      cursor: page1.nextCursor,
    });
    expect(page2.items).toHaveLength(10);

    const page3 = await caller.task.list({
      projectId: 'proj_123',
      limit: 10,
      cursor: page2.nextCursor,
    });
    expect(page3.items).toHaveLength(5);
    expect(page3.nextCursor).toBeUndefined();
  });
});
```

---

#### Testing Error Shapes

```ts
describe('error shape', () => {
  it('exposes flattened Zod errors in error.data.zodError', async () => {
    const caller = createCaller(createAuthedContext());

    try {
      await caller.task.create({ title: '', projectId: 'invalid' });
      expect.fail('Should have thrown');
    } catch (err: any) {
      expect(err.data?.zodError?.fieldErrors).toMatchObject({
        title: expect.any(Array),
        projectId: expect.any(Array),
      });
    }
  });
});
```

---

### Testing Middleware

Middleware is best tested indirectly through procedures that use it. For complex middleware, direct unit testing is also valuable.

```ts
// test/middleware/rateLimit.test.ts
import { describe, it, expect, vi, beforeEach } from 'vitest';
import { createCaller } from '~/server/routers/_app';
import { createAuthedContext } from '../helpers/context';

describe('rate limiting middleware', () => {
  it('throws TOO_MANY_REQUESTS after limit is exceeded', async () => {
    const caller = createCaller(createAuthedContext());

    // Exhaust the rate limit
    const requests = Array.from({ length: 101 }, () =>
      caller.task.list({ projectId: 'proj_123' })
    );

    const results = await Promise.allSettled(requests);
    const rejected = results.filter((r) => r.status === 'rejected');

    expect(rejected.length).toBeGreaterThan(0);
    expect((rejected[0] as PromiseRejectedResult).reason).toMatchObject({
      code: 'TOO_MANY_REQUESTS',
    });
  });
});
```

---

### Testing Subscriptions

Subscription testing requires working with observables directly, using fake timers or a test event emitter.

```ts
// test/routers/subscription.test.ts
import { describe, it, expect, vi } from 'vitest';
import { observable } from '@trpc/server/observable';
import { createCaller } from '~/server/routers/_app';
import { createAuthedContext } from '../helpers/context';
import { ee } from '~/server/lib/emitter';

describe('task.onCreate subscription', () => {
  it('emits when a task is created in the subscribed project', async () => {
    const received: unknown[] = [];

    const ctx = createAuthedContext();

    // Directly invoke the subscription and collect emissions
    await new Promise<void>((resolve) => {
      const sub = (createCaller(ctx) as any)._def.router._def.procedures[
        'task.onCreate'
      ]
        ._def.resolver({
          ctx,
          input: { projectId: 'proj_123' },
          type: 'subscription',
          path: 'task.onCreate',
          getRawInput: async () => ({ projectId: 'proj_123' }),
        });

      // A cleaner approach — test the observable factory directly
      const obs = sub as ReturnType<typeof observable>;
      const subscription = obs.subscribe({
        next(data) {
          received.push(data);
          resolve();
        },
        error: console.error,
      });

      // Trigger the event
      ee.emit('task.created', {
        id: 'task_123',
        title: 'New Task',
        projectId: 'proj_123',
        createdById: ctx.user!.id,
      });

      // Cleanup after resolve
      setTimeout(() => subscription.unsubscribe(), 100);
    });

    expect(received).toHaveLength(1);
    expect(received[0]).toMatchObject({ id: 'task_123', projectId: 'proj_123' });
  });
});
```

**Key Points**

- Subscription testing is inherently more complex than query/mutation testing due to the async push nature of observables
- Testing the event emitter directly (emitting events and asserting what the observable receives) is more reliable than end-to-end WebSocket tests for unit-level concerns
- [Inference] Full WebSocket subscription testing (connecting a real client to a real server) is better suited to the integration or E2E layer — the approach above tests observable logic only

---

### HTTP Integration Tests

Testing tRPC over the actual HTTP transport catches serialization, link, and adapter issues not visible in `createCaller` tests.

```ts
// test/integration/http.test.ts
import { describe, it, expect, beforeAll, afterAll } from 'vitest';
import { createHTTPServer } from '@trpc/server/adapters/standalone';
import { appRouter } from '~/server/routers/_app';
import { createContext } from '~/server/context';
import { createTRPCClient, httpBatchLink } from '@trpc/client';
import superjson from 'superjson';
import type { AppRouter } from '~/server/routers/_app';

let server: ReturnType<typeof createHTTPServer>;
let client: ReturnType<typeof createTRPCClient<AppRouter>>;
let baseUrl: string;

beforeAll(async () => {
  server = createHTTPServer({
    router: appRouter,
    createContext,
  });

  await new Promise<void>((resolve) => {
    server.listen(0, () => { // port 0 = OS assigns available port
      const address = server.server.address() as { port: number };
      baseUrl = `http://localhost:${address.port}`;
      resolve();
    });
  });

  client = createTRPCClient<AppRouter>({
    links: [
      httpBatchLink({
        url: baseUrl,
        transformer: superjson,
        headers: {
          // Inject a test session token
          authorization: `Bearer ${TEST_JWT}`,
        },
      }),
    ],
  });
});

afterAll(() => {
  server.server.close();
});

describe('HTTP transport', () => {
  it('resolves a query over HTTP', async () => {
    const result = await client.health.ping.query();
    expect(result).toBe('pong');
  });

  it('returns 401 shape for unauthenticated requests', async () => {
    const unauthClient = createTRPCClient<AppRouter>({
      links: [httpBatchLink({ url: baseUrl, transformer: superjson })],
    });

    await expect(
      unauthClient.task.list.query({ projectId: 'proj_123' })
    ).rejects.toMatchObject({ data: { code: 'UNAUTHORIZED' } });
  });

  it('handles batch requests', async () => {
    // Both queries are batched in a single HTTP request
    const [health, user] = await Promise.all([
      client.health.ping.query(),
      client.user.me.query(),
    ]);

    expect(health).toBe('pong');
    expect(user).toBeDefined();
  });
});
```

---

### End-to-End Tests

E2E tests drive the full stack through a real browser. They verify that the frontend, tRPC client, server, and database work together.

```ts
// e2e/tasks.spec.ts (Playwright)
import { test, expect } from '@playwright/test';

test.describe('Task management', () => {
  test.beforeEach(async ({ page }) => {
    // Sign in via UI or set auth cookie directly
    await page.goto('/sign-in');
    await page.fill('[name=email]', 'test@example.com');
    await page.fill('[name=password]', 'testpassword');
    await page.click('button[type=submit]');
    await page.waitForURL('/dashboard');
  });

  test('creates a task and shows it in the list', async ({ page }) => {
    await page.goto('/projects/proj-test/tasks');

    await page.click('[data-testid=new-task-button]');
    await page.fill('[name=title]', 'E2E Test Task');
    await page.selectOption('[name=priority]', 'HIGH');
    await page.click('[data-testid=submit-task]');

    await expect(
      page.locator('[data-testid=task-list]')
    ).toContainText('E2E Test Task');
  });

  test('shows validation error for empty title', async ({ page }) => {
    await page.goto('/projects/proj-test/tasks');
    await page.click('[data-testid=new-task-button]');
    await page.click('[data-testid=submit-task]');

    await expect(
      page.locator('[data-testid=title-error]')
    ).toContainText('Title is required');
  });

  test('redirects to sign-in when session expires', async ({ page, context }) => {
    // Clear auth cookies to simulate session expiry
    await context.clearCookies();
    await page.goto('/projects/proj-test/tasks');

    await expect(page).toHaveURL(/sign-in/);
  });
});
```

---

### Testing React Components with tRPC

Component tests mock the tRPC client to isolate UI logic from the network layer.

```tsx
// test/components/TaskList.test.tsx
import { render, screen, waitFor } from '@testing-library/react';
import { describe, it, expect, vi } from 'vitest';
import { TaskList } from '~/components/TaskList';
import { createTRPCMsw } from 'msw-trpc'; // community package
import { setupServer } from 'msw/node';
import { appRouter } from '~/server/routers/_app';

const trpcMsw = createTRPCMsw(appRouter);

const server = setupServer(
  trpcMsw.task.list.query((req, res, ctx) => {
    return res(
      ctx.status(200),
      ctx.data({
        items: [
          { id: 'task_1', title: 'Mocked Task', priority: 'MEDIUM' },
        ],
        nextCursor: undefined,
      })
    );
  })
);

beforeAll(() => server.listen());
afterEach(() => server.resetHandlers());
afterAll(() => server.close());

describe('TaskList', () => {
  it('renders tasks from the API', async () => {
    render(
      <TestWrapper> {/* wraps with TRPCProvider + QueryClientProvider */}
        <TaskList projectId="proj_123" />
      </TestWrapper>
    );

    await waitFor(() => {
      expect(screen.getByText('Mocked Task')).toBeInTheDocument();
    });
  });

  it('renders empty state when no tasks', async () => {
    server.use(
      trpcMsw.task.list.query((req, res, ctx) =>
        res(ctx.data({ items: [], nextCursor: undefined }))
      )
    );

    render(
      <TestWrapper>
        <TaskList projectId="proj_123" />
      </TestWrapper>
    );

    await waitFor(() => {
      expect(screen.getByText('No tasks yet')).toBeInTheDocument();
    });
  });

  it('renders error state on API failure', async () => {
    server.use(
      trpcMsw.task.list.query((req, res, ctx) =>
        res(ctx.status(500))
      )
    );

    render(
      <TestWrapper>
        <TaskList projectId="proj_123" />
      </TestWrapper>
    );

    await waitFor(() => {
      expect(screen.getByText('Something went wrong')).toBeInTheDocument();
    });
  });
});
```

**Key Points**

- `msw-trpc` is a community package — verify compatibility with the tRPC and MSW versions in use
- MSW intercepts fetch requests at the network boundary — the tRPC client, links, and serialization all run as normal
- Alternatively, mock `trpc.task.list.useQuery` directly with `vi.mock` — this is simpler but skips the tRPC client path entirely

---

### Test Coverage Strategy

```mermaid
graph LR
  subgraph "Must Test"
    Auth["Auth middleware\n(every protected procedure)"]
    Validation["Input validation\n(boundary values)"]
    NotFound["NOT_FOUND handling"]
    Ownership["Ownership / FORBIDDEN checks"]
  end

  subgraph "Should Test"
    Pagination["Pagination edge cases\n(empty, last page, cursor)"]
    Transactions["Transaction rollback\non partial failure"]
    ErrorShapes["Error shapes and\nzodError format"]
  end

  subgraph "Good to Have"
    Performance["Query count assertions\n(N+1 detection)"]
    E2EFlows["Critical user journeys\n(E2E)"]
    Subscriptions["Observable emissions\n(subscription procedures)"]
  end
```

---

### Snapshot Testing for Router Types

tRPC's type safety can be verified at the type level using `expectTypeOf` (Vitest) or `tsd`.

```ts
// test/types/router.test-d.ts
import { describe, it, expectTypeOf } from 'vitest';
import { createCaller } from '~/server/routers/_app';
import { createAuthedContext } from '../helpers/context';

describe('router type inference', () => {
  it('infers correct return type for task.byId', async () => {
    const caller = createCaller(createAuthedContext());
    const result = await caller.task.byId({ id: 'task_123' });

    expectTypeOf(result).toMatchTypeOf<{
      id: string;
      title: string;
      priority: 'LOW' | 'MEDIUM' | 'HIGH';
    }>();
  });

  it('infers input type for task.create', () => {
    type CreateInput = Parameters
      ReturnType<typeof createCaller>['task']['create']
    >[0];

    expectTypeOf<CreateInput>().toMatchTypeOf<{
      title: string;
      projectId: string;
    }>();
  });
});
```

---

### CI Configuration

```yaml
# .github/workflows/test.yml
name: Test

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest

    services:
      postgres:
        image: postgres:16
        env:
          POSTGRES_USER: postgres
          POSTGRES_PASSWORD: postgres
          POSTGRES_DB: myapp_test
        ports: ['5432:5432']
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5

    env:
      TEST_DATABASE_URL: postgresql://postgres:postgres@localhost:5432/myapp_test

    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'

      - run: npm ci
      - run: npx prisma migrate deploy
        env:
          DATABASE_URL: ${{ env.TEST_DATABASE_URL }}

      - run: npm run test -- --coverage
      - run: npm run test:e2e  # Playwright, separate job recommended

      - uses: codecov/codecov-action@v4
```

---

**Related Topics**

- Vitest vs Jest for tRPC projects — configuration trade-offs and migration path
- `msw-trpc` deep dive — mocking tRPC endpoints with MSW for component tests
- Database seeding strategies — factories, fixtures, and seed scripts for test data
- Testing tRPC with Drizzle ORM — in-memory SQLite for fast integration tests
- Type-level testing with `tsd` and `expectTypeOf` — verifying inference correctness
- Contract testing — using tRPC router types to generate and validate API contracts
- Playwright component testing — mounting tRPC-connected components in isolation
- Continuous integration for tRPC — parallelizing test layers and caching strategies