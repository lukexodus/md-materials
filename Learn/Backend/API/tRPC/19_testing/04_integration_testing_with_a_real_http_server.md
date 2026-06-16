## Integration Testing with a Real HTTP Server

Integration testing in tRPC verifies that your router, procedures, input validation, middleware, and HTTP transport all work together as a cohesive system — not in isolation. Unlike unit tests that call procedures directly, integration tests send real HTTP requests to a running server instance.

---

### Why Integration Test with a Real HTTP Server

Direct caller testing (using `createCaller`) bypasses the HTTP layer entirely. This means it does not exercise:

- HTTP-level error serialization
- Request/response headers
- Cookie handling
- Middleware that inspects the raw request
- The adapter layer (e.g., `@trpc/server/adapters/standalone` or Express integration)

Integration tests against a real server catch regressions that direct caller tests cannot.

---

### Setup Overview

A typical integration test stack for tRPC (Node.js) uses:

- **`@trpc/server`** with the standalone or Express adapter
- **`supertest`** or the native `fetch` API to send HTTP requests
- **`vitest`** or **`jest`** as the test runner
- A helper that starts and stops the HTTP server around each test suite

---

### Installing Dependencies

```bash
npm install --save-dev supertest
npm install --save-dev @types/supertest
```

The rest (`vitest`, `@trpc/server`, etc.) are assumed already present.

---

### Defining the Router Under Test

Keep the router definition in its own module so tests can import it without side effects.

```ts
// src/router.ts
import { initTRPC, TRPCError } from '@trpc/server';
import { z } from 'zod';

const t = initTRPC.create();

export const appRouter = t.router({
  greet: t.procedure
    .input(z.object({ name: z.string() }))
    .query(({ input }) => {
      return { message: `Hello, ${input.name}` };
    }),

  divide: t.procedure
    .input(z.object({ a: z.number(), b: z.number() }))
    .query(({ input }) => {
      if (input.b === 0) {
        throw new TRPCError({ code: 'BAD_REQUEST', message: 'Cannot divide by zero' });
      }
      return { result: input.a / input.b };
    }),
});

export type AppRouter = typeof appRouter;
```

---

### Creating a Test Server Helper

Wrap server startup and teardown in a reusable helper. This avoids port conflicts and ensures clean state between suites.

```ts
// src/test/createTestServer.ts
import { createHTTPServer } from '@trpc/server/adapters/standalone';
import { appRouter } from '../router';

export function createTestServer() {
  const server = createHTTPServer({
    router: appRouter,
    createContext: () => ({}),
  });

  // Port 0 tells the OS to assign a free port automatically
  const httpServer = server.listen(0);

  const port = (httpServer.address() as { port: number }).port;
  const baseUrl = `http://127.0.0.1:${port}`;

  return {
    baseUrl,
    close: () => httpServer.close(),
  };
}
```

**Key Points**

- Binding to port `0` avoids hardcoded ports and eliminates inter-test port conflicts.
- `httpServer.address()` returns the actual assigned port after `listen()` resolves.
- `createContext` here returns an empty object; substitute your real context factory in production tests.

---

### Writing Integration Tests

```ts
// src/test/router.integration.test.ts
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { createTestServer } from './createTestServer';

let baseUrl: string;
let closeServer: () => void;

beforeAll(() => {
  const server = createTestServer();
  baseUrl = server.baseUrl;
  closeServer = server.close;
});

afterAll(() => {
  closeServer();
});

describe('greet query', () => {
  it('returns a greeting for a valid name', async () => {
    const input = encodeURIComponent(JSON.stringify({ name: 'Ada' }));
    const res = await fetch(`${baseUrl}/greet?input=${input}`);
    const body = await res.json();

    expect(res.status).toBe(200);
    expect(body.result.data.message).toBe('Hello, Ada');
  });

  it('returns a 400 error for missing input', async () => {
    const res = await fetch(`${baseUrl}/greet`);
    const body = await res.json();

    expect(res.status).toBe(400);
    expect(body.error).toBeDefined();
  });
});

describe('divide query', () => {
  it('returns the correct quotient', async () => {
    const input = encodeURIComponent(JSON.stringify({ a: 10, b: 2 }));
    const res = await fetch(`${baseUrl}/divide?input=${input}`);
    const body = await res.json();

    expect(res.status).toBe(200);
    expect(body.result.data.result).toBe(5);
  });

  it('returns 400 when dividing by zero', async () => {
    const input = encodeURIComponent(JSON.stringify({ a: 10, b: 0 }));
    const res = await fetch(`${baseUrl}/divide?input=${input}`);
    const body = await res.json();

    expect(res.status).toBe(400);
    expect(body.error.message).toBe('Cannot divide by zero');
  });
});
```

**Key Points**

- tRPC's HTTP GET format encodes `input` as a URL query parameter containing a JSON string. The value must be `encodeURIComponent`-wrapped.
- The response envelope is `{ result: { data: <value> } }` for successes and `{ error: { ... } }` for failures. [Inference: this reflects tRPC v10/v11 HTTP response shape; verify against your exact version.]
- `fetch` is available natively in Node.js 18+. For older runtimes, substitute `node-fetch` or `supertest`.

---

### Using `supertest` Instead of `fetch`

`supertest` integrates with Node.js `http.Server` instances directly and handles connection teardown cleanly:

```ts
import request from 'supertest';
import http from 'http';
import { createHTTPServer } from '@trpc/server/adapters/standalone';
import { appRouter } from '../router';

let server: http.Server;

beforeAll((done) => {
  const app = createHTTPServer({
    router: appRouter,
    createContext: () => ({}),
  });
  server = app.listen(0, done);
});

afterAll((done) => {
  server.close(done);
});

it('greets correctly via supertest', async () => {
  const input = encodeURIComponent(JSON.stringify({ name: 'Turing' }));

  await request(server)
    .get(`/greet?input=${input}`)
    .expect(200)
    .expect((res) => {
      expect(res.body.result.data.message).toBe('Hello, Turing');
    });
});
```

---

### Testing Mutations (POST Requests)

Mutations use HTTP POST. The input is sent as a JSON body.

```ts
it('creates a record via mutation', async () => {
  const res = await fetch(`${baseUrl}/createUser`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ name: 'Grace', email: 'grace@example.com' }),
  });

  const body = await res.json();
  expect(res.status).toBe(200);
  expect(body.result.data.id).toBeDefined();
});
```

**Key Points**

- The body is the raw input object — not wrapped in an `input` key at the HTTP level for standalone adapter POST requests. [Inference: confirm this against your adapter version, as envelope format may differ.]
- Always set `Content-Type: application/json`.

---

### Testing Context and Authentication

To test procedures that depend on context (e.g., authenticated user), supply a `createContext` function in your test server that injects a mock context:

```ts
const authedServer = createHTTPServer({
  router: appRouter,
  createContext: ({ req }) => {
    const token = req.headers['authorization'] ?? '';
    const user = token === 'Bearer valid-token'
      ? { id: 'user-1', role: 'admin' }
      : null;
    return { user };
  },
});
```

Then in tests:

```ts
it('returns 401 for unauthenticated request', async () => {
  const input = encodeURIComponent(JSON.stringify({}));
  const res = await fetch(`${baseUrl}/protectedRoute?input=${input}`);
  expect(res.status).toBe(401);
});

it('succeeds with a valid token', async () => {
  const input = encodeURIComponent(JSON.stringify({}));
  const res = await fetch(`${baseUrl}/protectedRoute?input=${input}`, {
    headers: { Authorization: 'Bearer valid-token' },
  });
  expect(res.status).toBe(200);
});
```

This exercises the full context creation path, including middleware that reads from the real HTTP request object.

---

### Testing Middleware Effects

If your middleware attaches data to context or short-circuits with an error, integration tests are the appropriate place to verify this — because `createCaller` does not invoke the HTTP middleware chain.

```ts
it('rejects requests without a required header', async () => {
  const input = encodeURIComponent(JSON.stringify({ id: '123' }));
  // Omit the X-API-Key header that middleware requires
  const res = await fetch(`${baseUrl}/sensitiveData?input=${input}`);
  expect(res.status).toBe(403);
});
```

---

### Error Shape Verification

Integration tests are the right place to assert on the exact HTTP error shape that clients receive:

```ts
it('returns a well-formed tRPC error envelope', async () => {
  const res = await fetch(`${baseUrl}/greet`); // missing required input
  const body = await res.json();

  expect(body).toMatchObject({
    error: {
      message: expect.any(String),
      code: expect.any(Number),
      data: {
        code: expect.any(String),
        httpStatus: expect.any(Number),
      },
    },
  });
});
```

[Inference: the exact error shape depends on tRPC version and any custom error formatters. Verify against your configuration.]

---

### Diagram: Integration Test Flow

createContextRouter / ProceduretRPC AdapterHTTP ServerTest SuitecreateContextRouter / ProceduretRPC AdapterHTTP ServerTest SuiteHTTP GET /greet?input=...Incoming requestcreateContext(req, res)ctx objectRoute to procedureResult or TRPCErrorSerialized JSON responseHTTP 200 / 4xx + body

---

### Isolation Strategies

| Strategy | Description |
| --- | --- |
| Port `0` binding | OS assigns a free port; no conflicts between parallel test files |
| `beforeAll` / `afterAll` | Server starts once per suite; avoids repeated startup overhead |
| Per-test server | Start a new server per test for maximum isolation; slower but safer for stateful routers |
| Mock context factory | Inject fake DB, auth, or services via `createContext` to avoid real I/O |

---

### Common Pitfalls

**Port conflicts** — Hardcoding a port number causes failures when tests run in parallel. Always use port `0`.

**Not closing the server** — Leaving the server open causes Jest/Vitest to hang after tests complete. Always call `server.close()` in `afterAll`.

**Incorrect input encoding** — Forgetting `encodeURIComponent` around the JSON string produces malformed query strings and unexpected 400 errors.

**Asserting on internal structure** — tRPC's response envelope shape (`result.data`) is an implementation detail that may change across versions. Pin your assertions to the version you are testing against.

**Using `createCaller` and calling it an integration test** — `createCaller` does not go through HTTP. If you label it an integration test but bypass the adapter, you may miss real failure modes.

---

### Summary

Integration testing with a real HTTP server in tRPC requires starting an actual server (typically via the standalone adapter), sending HTTP requests with correctly encoded inputs, and asserting on the full HTTP response — including status codes and the JSON envelope. This layer of testing complements unit and direct-caller tests by covering the adapter, context creation, middleware, and error serialization paths that purely in-process tests cannot reach.