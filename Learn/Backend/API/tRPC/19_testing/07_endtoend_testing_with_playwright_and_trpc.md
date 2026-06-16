## End-to-End Testing with Playwright and tRPC

End-to-end (E2E) testing verifies the entire application stack — frontend UI, tRPC client, network transport, server procedures, and backend services — from the perspective of a real user interacting with a real browser. Playwright automates that browser interaction.

---

### What E2E Tests Cover That Other Tests Do Not

| Layer | Unit | Integration | E2E |
| --- | --- | --- | --- |
| Procedure logic | ✓ | ✓ | ✓ |
| HTTP transport | — | ✓ | ✓ |
| tRPC client configuration | — | — | ✓ |
| React Query integration | — | — | ✓ |
| UI rendering of data | — | — | ✓ |
| User interaction flow | — | — | ✓ |
| Browser environment | — | — | ✓ |

---

### Prerequisites

This section assumes:

- A full-stack application using tRPC on both server and client (e.g., Next.js or a separate Express/Fastify server + React frontend)
- Playwright installed and configured
- The application can be started as a local server for testing

---

### Installing Playwright

```bash
npm init playwright@latest
```

This installs `@playwright/test` and scaffolds a `playwright.config.ts`. During setup, choose your target browsers (Chromium is sufficient for most E2E runs).

---

### Configuring Playwright for a Local Dev Server

Playwright can start your application automatically before running tests using the `webServer` option.

```ts
// playwright.config.ts
import { defineConfig } from '@playwright/test';

export default defineConfig({
  testDir: './e2e',
  timeout: 30_000,
  use: {
    baseURL: 'http://localhost:3000',
  },
  webServer: {
    command: 'npm run dev',
    url: 'http://localhost:3000',
    reuseExistingServer: !process.env.CI,
    timeout: 60_000,
  },
});
```

**Key Points**

- `reuseExistingServer: true` speeds up local development by reusing a running dev server instead of restarting it for every test run.
- On CI, set `reuseExistingServer: false` to ensure a clean server start.
- `timeout` on `webServer` gives the server adequate time to compile and start before Playwright begins.

---

### Application Structure Assumed

The examples below assume a Next.js application with:

- A tRPC router at `src/server/router.ts`
- An API route at `/api/trpc/[trpc]`
- A React page that calls tRPC procedures via `@tanstack/react-query`

The E2E tests live in `e2e/` at the project root.

---

### Writing a Basic E2E Test

```ts
// e2e/greet.spec.ts
import { test, expect } from '@playwright/test';

test('displays a greeting fetched via tRPC', async ({ page }) => {
  await page.goto('/');

  // Wait for the tRPC query to resolve and the greeting to render
  const greeting = page.getByTestId('greeting-message');
  await expect(greeting).toHaveText('Hello, World', { timeout: 5000 });
});
```

**Key Points**

- `getByTestId` uses `data-testid` attributes. Adding these to components that display tRPC data makes selectors stable across UI refactors.
- `await expect(greeting).toHaveText(...)` automatically retries until the element contains the expected text or the timeout expires — no manual polling needed.
- The test does not know or care about tRPC internals; it observes the rendered output.

---

### Using `data-testid` in Your Components

tsx

```
// src/components/Greeting.tsx
export function Greeting() {
  const { data, isLoading } = trpc.greet.useQuery({ name: 'World' });

  if (isLoading) return <p data-testid="greeting-loading">Loading...</p>;
  return <p data-testid="greeting-message">{data?.message}</p>;
}
```

---

### Testing a Mutation Flow

E2E tests can simulate a full user interaction — filling a form, submitting it, and asserting that the result appears.

```ts
// e2e/createUser.spec.ts
import { test, expect } from '@playwright/test';

test('creates a user via form submission', async ({ page }) => {
  await page.goto('/users/new');

  await page.getByLabel('Name').fill('Ada Lovelace');
  await page.getByLabel('Email').fill('ada@example.com');
  await page.getByRole('button', { name: 'Create User' }).click();

  // After the mutation resolves, the UI should show a success state
  await expect(page.getByTestId('success-message')).toBeVisible({ timeout: 5000 });
  await expect(page.getByTestId('user-name-display')).toHaveText('Ada Lovelace');
});
```

---

### Intercepting tRPC Network Requests

Playwright's `page.route()` allows intercepting and mocking HTTP requests. This is useful when you want to test UI states (loading, error) without depending on a real backend.

```ts
// e2e/error-state.spec.ts
import { test, expect } from '@playwright/test';

test('displays an error message when the tRPC query fails', async ({ page }) => {
  // Intercept the tRPC request and return a simulated error
  await page.route('**/api/trpc/greet**', async (route) => {
    await route.fulfill({
      status: 500,
      contentType: 'application/json',
      body: JSON.stringify({
        error: {
          message: 'Internal server error',
          code: -32603,
          data: { code: 'INTERNAL_SERVER_ERROR', httpStatus: 500 },
        },
      }),
    });
  });

  await page.goto('/');

  await expect(page.getByTestId('error-message')).toBeVisible({ timeout: 5000 });
  await expect(page.getByTestId('error-message')).toContainText('Something went wrong');
});
```

**Key Points**

- The URL pattern `**/api/trpc/greet**` matches the tRPC endpoint for the `greet` procedure. Adjust the path to match your API route structure.
- The mocked response must conform to the tRPC error envelope shape that your client expects. [Inference: the exact error shape depends on your tRPC version and any custom error formatters. Verify against your configuration.]
- This approach tests your UI's error handling without requiring the server to actually fail.

---

### Intercepting to Assert on Request Payloads

You can also use `page.route()` to assert on what your tRPC client sends — useful for verifying that the correct input reaches the server.

```ts
test('sends the correct input to the createUser mutation', async ({ page }) => {
  let capturedBody: unknown;

  await page.route('**/api/trpc/createUser**', async (route) => {
    const request = route.request();
    capturedBody = JSON.parse(request.postData() ?? '{}');

    // Let the real request continue
    await route.continue();
  });

  await page.goto('/users/new');
  await page.getByLabel('Name').fill('Grace Hopper');
  await page.getByLabel('Email').fill('grace@example.com');
  await page.getByRole('button', { name: 'Create User' }).click();

  await expect(page.getByTestId('success-message')).toBeVisible();

  expect(capturedBody).toMatchObject({
    name: 'Grace Hopper',
    email: 'grace@example.com',
  });
});
```

---

### Testing Loading States

```ts
test('shows a loading indicator while the query is in flight', async ({ page }) => {
  // Delay the response to give the loading state time to appear
  await page.route('**/api/trpc/greet**', async (route) => {
    await new Promise((r) => setTimeout(r, 1000));
    await route.continue();
  });

  await page.goto('/');

  // Loading indicator should appear immediately
  await expect(page.getByTestId('greeting-loading')).toBeVisible();

  // Then resolve to the actual content
  await expect(page.getByTestId('greeting-message')).toBeVisible({ timeout: 5000 });
});
```

---

### Database Seeding and Teardown

E2E tests that interact with real backend procedures need the database in a known state. There are two common approaches:

**Test-specific seed scripts**

```ts
// e2e/fixtures/seed.ts
import { prisma } from '../../src/server/db';

export async function seedTestUser() {
  return prisma.user.create({
    data: { id: 'test-user-1', name: 'Test User', email: 'test@example.com' },
  });
}

export async function cleanupTestUser() {
  await prisma.user.deleteMany({ where: { email: 'test@example.com' } });
}
```

```ts
// e2e/profile.spec.ts
import { test, expect } from '@playwright/test';
import { seedTestUser, cleanupTestUser } from './fixtures/seed';

test.beforeEach(async () => {
  await seedTestUser();
});

test.afterEach(async () => {
  await cleanupTestUser();
});

test('displays the user profile fetched via tRPC', async ({ page }) => {
  await page.goto('/profile/test-user-1');
  await expect(page.getByTestId('profile-name')).toHaveText('Test User');
});
```

**A dedicated test database**

[Inference: running E2E tests against a separate test database (via a different `DATABASE_URL` in the test environment) is a common pattern to avoid contaminating production or development data. The exact setup depends on your ORM and database provider.]

---

### Using Playwright Fixtures for tRPC Setup

Playwright fixtures allow shared setup to be scoped and reused across tests cleanly.

```ts
// e2e/fixtures/index.ts
import { test as base } from '@playwright/test';
import { seedTestUser, cleanupTestUser } from './seed';

type Fixtures = {
  seededUser: { id: string; name: string; email: string };
};

export const test = base.extend<Fixtures>({
  seededUser: async ({}, use) => {
    const user = await seedTestUser();
    await use(user);
    await cleanupTestUser();
  },
});

export { expect } from '@playwright/test';
```

```ts
// e2e/profile.spec.ts
import { test, expect } from './fixtures';

test('shows the seeded user profile', async ({ page, seededUser }) => {
  await page.goto(`/profile/${seededUser.id}`);
  await expect(page.getByTestId('profile-name')).toHaveText(seededUser.name);
});
```

**Key Points**

- The fixture handles setup and teardown automatically. The test body only receives the ready-to-use artifact.
- Fixtures compose — you can build on `seededUser` to create further fixtures (e.g., `authenticatedPage`).

---

### Authenticating in E2E Tests

Most applications require authentication. Playwright provides `storageState` to save and restore browser session state (cookies, localStorage) across tests.

#### Saving Authentication State

```ts
// e2e/auth.setup.ts
import { test as setup } from '@playwright/test';

setup('authenticate', async ({ page }) => {
  await page.goto('/login');
  await page.getByLabel('Email').fill('test@example.com');
  await page.getByLabel('Password').fill('test-password');
  await page.getByRole('button', { name: 'Sign In' }).click();

  await page.waitForURL('/dashboard');

  // Save session state to disk
  await page.context().storageState({ path: 'e2e/.auth/user.json' });
});
```

#### Reusing Authentication State

```ts
// playwright.config.ts
export default defineConfig({
  projects: [
    {
      name: 'setup',
      testMatch: /auth\.setup\.ts/,
    },
    {
      name: 'authenticated',
      testDir: './e2e',
      dependencies: ['setup'],
      use: {
        storageState: 'e2e/.auth/user.json',
      },
    },
  ],
});
```

Now all tests in the `authenticated` project start with a pre-authenticated session — including any tRPC procedures that read authentication from cookies or session tokens.

---

### E2E Test Flow Diagram

DatabasetRPC API RouteNext.js / FrontendBrowserPlaywrightDatabasetRPC API RouteNext.js / FrontendBrowserPlaywrightLaunch + navigate to URLHTTP GET /pageHTML + JS bundletRPC query (fetch/WS)QueryResultJSON responseRender data into DOMAssert on DOM elementPass / Fail

---

### Distinguishing E2E from Integration Tests

Integration Testfetch / supertestReal HTTP requestReal server + proceduresMock or real databaseE2E Test (Playwright)Real browserReal frontend bundleReal tRPC clientReal HTTP requestReal server + proceduresReal or seeded database

The E2E test adds the browser, the frontend bundle, and the tRPC client configuration to what an integration test already covers.

---

### Common Pitfalls

**Not waiting for tRPC queries to resolve** — Asserting on DOM content immediately after navigation may find a loading state. Always use `await expect(...).toHaveText(...)` or `toBeVisible()` with an appropriate timeout rather than asserting synchronously.

**Hardcoded ports** — If your dev server and test server share a port, parallel test runs conflict. Use environment variables to configure ports.

**Intercepting the wrong URL pattern** — tRPC batches multiple procedures into a single request when batching is enabled. Your `page.route()` pattern must account for this. [Inference: with batching enabled, the URL may contain multiple procedure names separated by commas, e.g., `/api/trpc/greet,getUser`. Verify your batching configuration before writing route intercepts.]

**Leaking database state between tests** — Always clean up seeded data in `afterEach` or use transactions that roll back. Shared state causes order-dependent test failures.

**Treating E2E as a replacement for unit tests** — E2E tests are slow and fragile relative to unit tests. They complement, not replace, the lower testing layers.

**Not committing `storageState` to `.gitignore`** — Auth state files may contain session tokens. Add `e2e/.auth/` to `.gitignore`.

---

### Summary

E2E testing with Playwright and tRPC exercises the full application stack from a real browser through to the database. Playwright's `webServer` configuration starts the application automatically; `page.route()` intercepts tRPC HTTP requests for mocking or inspection; fixtures and `storageState` handle database seeding and authentication across tests. Because E2E tests are the most expensive to run and maintain, they are most valuable for critical user flows — authentication, form submission, data display — rather than exhaustive procedure coverage, which belongs at the unit and integration layers.