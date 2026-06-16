## Mocking QueryClient in Tests

Testing components and hooks that depend on TanStack Query requires a properly configured `QueryClient` to be available in the component tree. Mocking or isolating the `QueryClient` in tests is foundational to writing reliable, fast, and side-effect-free tests.

---

### Why QueryClient Must Be Present in Tests

TanStack Query's hooks (`useQuery`, `useMutation`, etc.) consume context provided by `QueryClientProvider`. Without it, any component using these hooks will throw an error at render time.

Additionally, a default `QueryClient` configured for production (with retries, caching, background refetching) will cause tests to be slow, flaky, or difficult to reason about. A test-specific `QueryClient` instance is required.

---

### Creating a Test QueryClient

The standard pattern is to create a fresh `QueryClient` per test (or per test suite) with behavior tuned for testing:

```ts
import { QueryClient } from '@tanstack/react-query';

function createTestQueryClient() {
  return new QueryClient({
    defaultOptions: {
      queries: {
        retry: false,         // Prevent retries from masking failures
        gcTime: Infinity,     // Prevent garbage collection during tests
        staleTime: Infinity,  // Prevent background refetches
      },
      mutations: {
        retry: false,
      },
    },
  });
}
```

**Key Points:**
- `retry: false` — avoids test runner timeouts caused by query retries on simulated errors
- `gcTime: Infinity` — prevents cached data from being removed mid-assertion
- `staleTime: Infinity` — prevents automatic refetching, which complicates test isolation
- A new instance per test avoids cross-test cache contamination

> [Inference] These defaults are commonly recommended but behavior may vary depending on library version and test environment configuration.

---

### Wrapping Components with QueryClientProvider

In React Testing Library, you typically create a custom `render` wrapper:

```tsx
import { render } from '@testing-library/react';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';

function renderWithClient(ui: React.ReactElement) {
  const testQueryClient = createTestQueryClient();
  return {
    ...render(
      <QueryClientProvider client={testQueryClient}>
        {ui}
      </QueryClientProvider>
    ),
    testQueryClient,
  };
}
```

**Example usage:**

```tsx
test('renders user name', async () => {
  const { getByText } = renderWithClient(<UserProfile userId="1" />);
  expect(await getByText(/loading/i)).toBeInTheDocument();
});
```

Returning `testQueryClient` from the helper allows direct cache inspection or mutation within tests.

---

### Scoping: Per-Test vs Per-Suite

**Per-test (recommended):**

```ts
let queryClient: QueryClient;

beforeEach(() => {
  queryClient = createTestQueryClient();
});

afterEach(() => {
  queryClient.clear();
});
```

**Per-suite (acceptable for read-only scenarios):**

```ts
const queryClient = createTestQueryClient();

afterAll(() => {
  queryClient.clear();
});
```

**Key Points:**
- Per-test isolation is safer and avoids cache bleed-through between tests
- Per-suite is lower overhead but risks state contamination if any test mutates the cache
- `queryClient.clear()` removes all queries and mutations from the cache

---

### Directly Seeding the Cache (Bypassing Fetch)

Instead of mocking `fetch` or your HTTP client, you can seed the `QueryClient` cache directly before rendering. This is fast, deterministic, and avoids network layer complexity:

```ts
queryClient.setQueryData(['user', '1'], {
  id: '1',
  name: 'Luke',
  email: 'luke@example.com',
});
```

When the component calls `useQuery({ queryKey: ['user', '1'] })`, TanStack Query finds the pre-seeded data and does not trigger a network request.

**Example:**

```tsx
test('displays seeded user data', async () => {
  queryClient.setQueryData(['user', '1'], { id: '1', name: 'Luke' });

  const { getByText } = renderWithClient(<UserProfile userId="1" />);
  expect(getByText('Luke')).toBeInTheDocument();
});
```

> [Inference] Cache seeding bypasses the `queryFn` entirely. Tests relying on this approach do not validate network/fetching logic; they test rendering behavior only.

---

### Reading Cache State After Actions

The returned `testQueryClient` can be used to assert cache state after user interactions or mutations:

```ts
test('mutation updates cache', async () => {
  const { getByRole, testQueryClient } = renderWithClient(<UpdateUserForm userId="1" />);

  fireEvent.click(getByRole('button', { name: /save/i }));
  await waitFor(() => {
    const data = testQueryClient.getQueryData(['user', '1']);
    expect(data).toMatchObject({ name: 'Updated' });
  });
});
```

---

### Using a Wrapper Factory for Reuse

For larger projects, a shared wrapper factory avoids duplication:

```tsx
// test-utils.tsx
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { render, RenderOptions } from '@testing-library/react';

export function createWrapper() {
  const queryClient = createTestQueryClient();
  const Wrapper = ({ children }: { children: React.ReactNode }) => (
    <QueryClientProvider client={queryClient}>{children}</QueryClientProvider>
  );
  return { Wrapper, queryClient };
}

export function renderWithQuery(ui: React.ReactElement, options?: RenderOptions) {
  const { Wrapper, queryClient } = createWrapper();
  return { ...render(ui, { wrapper: Wrapper, ...options }), queryClient };
}
```

This pattern is particularly useful when combining with other providers (router, theme, auth context).

---

### Testing Hooks Directly with renderHook

When testing custom hooks built on TanStack Query, use `renderHook` with a wrapper:

```ts
import { renderHook, waitFor } from '@testing-library/react';

test('useUserQuery returns user data', async () => {
  const { Wrapper, queryClient } = createWrapper();
  queryClient.setQueryData(['user', '1'], { id: '1', name: 'Luke' });

  const { result } = renderHook(() => useUserQuery('1'), { wrapper: Wrapper });

  await waitFor(() => {
    expect(result.current.data).toEqual({ id: '1', name: 'Luke' });
  });
});
```

---

### Combining with MSW (Mock Service Worker)

When you do want to test the full fetch path (i.e., validate that `queryFn` fires and data is fetched), combine `QueryClient` with MSW:

```ts
import { setupServer } from 'msw/node';
import { rest } from 'msw';

const server = setupServer(
  rest.get('/api/users/1', (req, res, ctx) => {
    return res(ctx.json({ id: '1', name: 'Luke' }));
  })
);

beforeAll(() => server.listen());
afterEach(() => server.resetHandlers());
afterAll(() => server.close());
```

With MSW handling the network layer and a test `QueryClient` configured with `retry: false`, tests exercise the full data-fetching path without actual network calls.

> [Inference] MSW + test `QueryClient` is the most complete integration testing approach. Whether this combination is appropriate depends on what behavior is under test.

---

### Disabling the Logger / Suppressing Console Errors

By default, TanStack Query logs query errors to the console. In tests expecting error states, this produces noise. It can be suppressed:

```ts
import { QueryCache } from '@tanstack/react-query';

const queryClient = new QueryClient({
  queryCache: new QueryCache({
    onError: () => {}, // suppress error logging
  }),
  defaultOptions: { queries: { retry: false } },
});
```

Or globally in the test setup file:

```ts
import { setLogger } from '@tanstack/react-query'; // v4 only

setLogger({
  log: () => {},
  warn: () => {},
  error: () => {},
});
```

> [Unverified] `setLogger` was available in v4 but was removed in v5. In v5, suppression is done via `QueryCache` `onError` or jest's `console.error` spy. Confirm against your installed version.

---

### Summary of Test QueryClient Patterns

| Technique | Use Case |
|---|---|
| `retry: false` | Prevent retry delays on expected errors |
| `staleTime: Infinity` | Prevent automatic background refetches |
| `gcTime: Infinity` | Preserve cache during assertions |
| `setQueryData(...)` | Seed cache directly, skip network |
| `getQueryData(...)` | Assert cache state after mutations |
| `queryClient.clear()` | Tear down between tests |
| MSW integration | Test full fetch path without real network |
| `renderHook` + wrapper | Unit test custom query hooks |

---

**Related Topics:**
- Testing loading, error, and success states with React Testing Library
- Using `waitFor` and `act` with async query transitions
- Testing `useMutation` side effects and `onSuccess`/`onError` callbacks
- Testing query invalidation and refetch behavior
- Testing with `useInfiniteQuery`
- Integrating MSW v2 with TanStack Query v5
- Testing Suspense-mode queries (`suspense: true`)
- Testing optimistic updates and rollback