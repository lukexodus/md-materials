## Testing TanStack Query with React Testing Library

Testing components that use TanStack Query requires wrapping them in a `QueryClientProvider`, controlling what data queries return, and handling the async nature of data fetching within test assertions. The goal is tests that verify component behavior — what the user sees and does — rather than the internals of Query itself.

---

### Core Setup: Test Query Client

Every test needs a fresh `QueryClient` instance. A shared singleton carries cache state between tests, causing flaky, order-dependent failures.

```ts
// test-utils/createTestQueryClient.ts
import { QueryClient } from '@tanstack/react-query'

export function createTestQueryClient() {
  return new QueryClient({
    defaultOptions: {
      queries: {
        retry: false,       // fail immediately — no retry delays in tests
        gcTime: Infinity,   // prevent garbage collection during test
        staleTime: 0,       // always consider data stale unless overridden per test
      },
      mutations: {
        retry: false,
      },
    },
  })
}
```

**Key Points:**
- `retry: false` is the most important test setting — without it, failed queries retry up to three times, each with a backoff delay, causing slow and timing-dependent tests
- `gcTime: Infinity` prevents cache entries from being cleaned up mid-test during async operations
- A new instance per test (not per file) ensures no cache bleed between individual test cases

---

### Custom `render` Wrapper

Wrapping the standard RTL `render` with `QueryClientProvider` avoids repeating provider setup in every test.

```tsx
// test-utils/renderWithQuery.tsx
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { render, type RenderOptions } from '@testing-library/react'
import { createTestQueryClient } from './createTestQueryClient'

type RenderWithQueryOptions = RenderOptions & {
  queryClient?: QueryClient
}

export function renderWithQuery(
  ui: React.ReactElement,
  { queryClient, ...options }: RenderWithQueryOptions = {},
) {
  const client = queryClient ?? createTestQueryClient()

  function Wrapper({ children }: { children: React.ReactNode }) {
    return (
      <QueryClientProvider client={client}>
        {children}
      </QueryClientProvider>
    )
  }

  return {
    ...render(ui, { wrapper: Wrapper, ...options }),
    queryClient: client,
  }
}
```

**Key Points:**
- Returning `queryClient` from the render result lets tests inspect or manipulate cache state directly after render
- Accepting an optional `queryClient` parameter lets tests that need pre-populated cache pass their own prepared instance
- The `Wrapper` component is defined inside the function so each call gets a fresh closure over `client`

---

### Strategy 1: Mocking `fetch` or Axios

The most direct approach — intercept the network call that `queryFn` makes.

```tsx
// UserProfile.test.tsx
import { screen, waitFor } from '@testing-library/react'
import { renderWithQuery } from './test-utils/renderWithQuery'
import { UserProfile } from './UserProfile'

const mockUser = { id: '1', name: 'Alice', email: 'alice@example.com' }

beforeEach(() => {
  global.fetch = vi.fn()
})

afterEach(() => {
  vi.restoreAllMocks()
})

test('renders user name after fetch', async () => {
  vi.mocked(fetch).mockResolvedValueOnce(
    new Response(JSON.stringify(mockUser), {
      status: 200,
      headers: { 'Content-Type': 'application/json' },
    })
  )

  renderWithQuery(<UserProfile userId="1" />)

  expect(screen.getByText('Loading…')).toBeInTheDocument()

  await waitFor(() => {
    expect(screen.getByText('Alice')).toBeInTheDocument()
  })
})

test('renders error state when fetch fails', async () => {
  vi.mocked(fetch).mockResolvedValueOnce(
    new Response('Not Found', { status: 404 })
  )

  renderWithQuery(<UserProfile userId="1" />)

  await waitFor(() => {
    expect(screen.getByText(/not found/i)).toBeInTheDocument()
  })
})
```

**Key Points:**
- `mockResolvedValueOnce` scopes the mock to a single call — subsequent calls fall through to the next mock or an unhandled rejection
- Constructing a real `Response` object (rather than returning a plain object) is necessary if `queryFn` calls `res.ok`, `res.status`, or `res.json()` on the response
- `waitFor` polls the assertion until it passes or times out — necessary because Query fetches asynchronously after render
- Testing the loading state before `waitFor` is possible only if the loading state renders synchronously on first render — which it does when `staleTime: 0` and no cached data exists

---

### Strategy 2: Pre-populating the Cache with `setQueryData`

For testing components in isolation from the network, pre-populate the cache before rendering. The component sees data immediately — no async waiting.

```tsx
// PostList.test.tsx
import { screen } from '@testing-library/react'
import { createTestQueryClient } from './test-utils/createTestQueryClient'
import { renderWithQuery } from './test-utils/renderWithQuery'
import { PostList } from './PostList'

const mockPosts = [
  { id: 1, title: 'First Post' },
  { id: 2, title: 'Second Post' },
]

test('renders list of posts from cache', () => {
  const queryClient = createTestQueryClient()
  queryClient.setQueryData(['posts'], mockPosts)

  renderWithQuery(<PostList />, { queryClient })

  expect(screen.getByText('First Post')).toBeInTheDocument()
  expect(screen.getByText('Second Post')).toBeInTheDocument()
})
```

**Key Points:**
- `setQueryData` populates the cache synchronously before render — the component finds data immediately and renders without async transitions
- No `waitFor` needed when data is pre-populated — the component renders the data state on its first paint
- The query key passed to `setQueryData` must exactly match what the component's `useQuery` uses — a mismatch means the component fetches instead of reading from cache
- This strategy is best for testing rendering logic and user interaction; it bypasses `queryFn` entirely

---

### Strategy 3: Using MSW (Mock Service Worker)

MSW intercepts requests at the network level — `queryFn` runs normally, `fetch` is called normally, but requests are intercepted before leaving the browser or Node environment. This produces the most realistic tests.

```ts
// mocks/handlers.ts
import { http, HttpResponse } from 'msw'

export const handlers = [
  http.get('/api/users/:id', ({ params }) => {
    return HttpResponse.json({
      id: params.id,
      name: 'Alice',
      email: 'alice@example.com',
    })
  }),

  http.get('/api/posts', () => {
    return HttpResponse.json([
      { id: 1, title: 'First Post' },
      { id: 2, title: 'Second Post' },
    ])
  }),
]
```

```ts
// mocks/server.ts
import { setupServer } from 'msw/node'
import { handlers } from './handlers'

export const server = setupServer(...handlers)
```

```ts
// vitest.setup.ts (or jest.setup.ts)
import { server } from './mocks/server'

beforeAll(() => server.listen({ onUnhandledRequest: 'error' }))
afterEach(() => server.resetHandlers())
afterAll(() => server.close())
```

```tsx
// UserProfile.test.tsx with MSW
import { screen, waitFor } from '@testing-library/react'
import { renderWithQuery } from './test-utils/renderWithQuery'
import { UserProfile } from './UserProfile'
import { server } from './mocks/server'
import { http, HttpResponse } from 'msw'

test('renders user profile', async () => {
  renderWithQuery(<UserProfile userId="1" />)

  await waitFor(() => {
    expect(screen.getByText('Alice')).toBeInTheDocument()
  })
})

test('renders error when user not found', async () => {
  server.use(
    http.get('/api/users/:id', () => HttpResponse.json(null, { status: 404 }))
  )

  renderWithQuery(<UserProfile userId="999" />)

  await waitFor(() => {
    expect(screen.getByRole('alert')).toBeInTheDocument()
  })
})
```

**Key Points:**
- `server.resetHandlers()` in `afterEach` removes per-test overrides — baseline handlers from `handlers.ts` are restored between tests
- `onUnhandledRequest: 'error'` causes unmatched requests to throw — prevents silent test failures from unmocked endpoints
- Per-test overrides via `server.use(...)` layer on top of the default handlers without permanently replacing them
- MSW works in both browser and Node environments — the same handlers can be shared between unit tests and browser-based end-to-end tests [Unverified — verify MSW version compatibility with your test environment]

---

### Testing Loading States

Loading state is visible only before the first successful fetch. Testing it requires asserting synchronously after render, before any async resolution.

```tsx
test('shows loading indicator while fetching', async () => {
  // Delay the mock response so loading state persists long enough to assert
  vi.mocked(fetch).mockImplementationOnce(
    () => new Promise(resolve =>
      setTimeout(() =>
        resolve(new Response(JSON.stringify(mockUser), { status: 200 })),
        100
      )
    )
  )

  renderWithQuery(<UserProfile userId="1" />)

  // Assert loading state synchronously — before fetch resolves
  expect(screen.getByTestId('loading-spinner')).toBeInTheDocument()

  // Wait for data state
  await waitFor(() => {
    expect(screen.queryByTestId('loading-spinner')).not.toBeInTheDocument()
  })
})
```

**Key Points:**
- Without a delayed response, the fetch may resolve before the test can assert on the loading state — introduce a deliberate delay when loading state needs to be verified
- `screen.queryByTestId` (not `getByTestId`) is used to assert absence — `queryBy` returns `null` rather than throwing when not found
- [Inference] In many test suites, loading state tests are lower priority than data and error state tests — loading states are often brief and the component logic is minimal

---

### Testing Mutations

Testing `useMutation` requires firing a user event, waiting for the mutation to complete, and asserting on the resulting UI state and cache.

```tsx
// CreatePost.test.tsx
import { screen, waitFor } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { createTestQueryClient } from './test-utils/createTestQueryClient'
import { renderWithQuery } from './test-utils/renderWithQuery'
import { CreatePost } from './CreatePost'

test('submits form and invalidates posts cache', async () => {
  const user = userEvent.setup()
  const queryClient = createTestQueryClient()

  // Pre-populate cache to verify invalidation
  queryClient.setQueryData(['posts'], [{ id: 1, title: 'Existing Post' }])

  vi.mocked(fetch).mockResolvedValueOnce(
    new Response(JSON.stringify({ id: 2, title: 'New Post' }), { status: 201 })
  )

  renderWithQuery(<CreatePost />, { queryClient })

  await user.type(screen.getByLabelText('Title'), 'New Post')
  await user.click(screen.getByRole('button', { name: /create/i }))

  await waitFor(() => {
    expect(screen.getByText(/post created/i)).toBeInTheDocument()
  })

  // Cache for ['posts'] should be invalidated — no longer present or marked stale
  const postsData = queryClient.getQueryData(['posts'])
  // After invalidation without an active observer, cache entry may be stale
  // Verify by checking query state
  const queryState = queryClient.getQueryState(['posts'])
  expect(queryState?.isInvalidated).toBe(true)
})
```

**Key Points:**
- `userEvent.setup()` is the recommended pattern in `@testing-library/user-event` v14+ — creates a user-event instance with proper event simulation [Unverified — verify against installed version]
- After `invalidateQueries`, cache entries with no active observer are marked stale but not removed — `getQueryState(['posts'])?.isInvalidated` checks the invalidation flag
- `getQueryData` returns the data currently in cache — if a refetch is triggered and completes during the test, it reflects the new data

---

### Testing Query Cache State Directly

Sometimes the assertion is on the cache state itself, not on rendered output — useful for testing custom hooks.

```ts
// usePostsQuery.test.ts
import { renderHook, waitFor } from '@testing-library/react'
import { QueryClientProvider } from '@tanstack/react-query'
import { createTestQueryClient } from './test-utils/createTestQueryClient'
import { usePostsQuery } from './usePostsQuery'

test('fetches and caches posts', async () => {
  const queryClient = createTestQueryClient()

  vi.mocked(fetch).mockResolvedValueOnce(
    new Response(JSON.stringify([{ id: 1, title: 'Post' }]), { status: 200 })
  )

  const wrapper = ({ children }: { children: React.ReactNode }) => (
    <QueryClientProvider client={queryClient}>{children}</QueryClientProvider>
  )

  const { result } = renderHook(() => usePostsQuery(), { wrapper })

  await waitFor(() => {
    expect(result.current.isSuccess).toBe(true)
  })

  expect(result.current.data).toEqual([{ id: 1, title: 'Post' }])
  expect(queryClient.getQueryData(['posts'])).toEqual([{ id: 1, title: 'Post' }])
})
```

**Key Points:**
- `renderHook` from `@testing-library/react` (not a separate package in RTL v13+) renders a hook in a minimal component
- `waitFor(() => expect(result.current.isSuccess).toBe(true))` waits until the hook's return value reflects success state
- Asserting on both `result.current.data` and `queryClient.getQueryData` verifies the hook and the cache independently

---

### Testing with TanStack Router

When components use Router hooks (`useParams`, `useSearch`, `useNavigate`), a router wrapper is needed alongside the Query wrapper.

```tsx
// test-utils/renderWithProviders.tsx
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { createMemoryHistory, createRouter, RouterProvider } from '@tanstack/react-router'
import { render } from '@testing-library/react'
import { routeTree } from '../routeTree.gen'
import { createTestQueryClient } from './createTestQueryClient'

export function renderWithProviders(
  initialPath: string = '/',
  queryClient?: QueryClient,
) {
  const client = queryClient ?? createTestQueryClient()

  const router = createRouter({
    routeTree,
    history: createMemoryHistory({ initialEntries: [initialPath] }),
    context: { queryClient: client },
  })

  return {
    ...render(
      <QueryClientProvider client={client}>
        <RouterProvider router={router} />
      </QueryClientProvider>
    ),
    router,
    queryClient: client,
  }
}
```

```tsx
// PostDetail.test.tsx
test('loads post detail for route /posts/1', async () => {
  const queryClient = createTestQueryClient()
  queryClient.setQueryData(['posts', '1'], { id: '1', title: 'Hello World' })

  renderWithProviders('/posts/1', queryClient)

  await waitFor(() => {
    expect(screen.getByText('Hello World')).toBeInTheDocument()
  })
})
```

**Key Points:**
- `createMemoryHistory` provides a history implementation that does not depend on `window.location` — safe in Node/jsdom test environments
- Pre-populating cache before render means route loaders using `ensureQueryData` find fresh data and resolve immediately
- `context: { queryClient: client }` injects the same client used by `QueryClientProvider` into route loaders
- [Inference] For tests focused on component rendering rather than routing logic, the simpler `renderWithQuery` wrapper is preferable — add Router only when the component under test uses Router hooks

---

### Asserting on Error States

Error states require the `queryFn` to throw and Query to exhaust retries. With `retry: false`, failure is immediate.

```tsx
test('shows error message when fetch fails', async () => {
  vi.mocked(fetch).mockResolvedValueOnce(
    new Response('Server Error', { status: 500 })
  )

  renderWithQuery(<UserProfile userId="1" />)

  await waitFor(() => {
    expect(screen.getByRole('alert')).toBeInTheDocument()
    expect(screen.getByText(/server error/i)).toBeInTheDocument()
  })
})
```

**Key Points:**
- With `retry: false` in the test `QueryClient`, the error state is reached after one failed attempt — no delays
- The component must render an accessible error indicator — `role="alert"` is both semantically correct and easily queryable
- If the component uses `throwOnError: true`, an error boundary must wrap the component in the test render; otherwise the test throws an uncaught error

---

### Common Pitfalls

**Pitfall: Shared `QueryClient` across tests**

Cache state from a passing test contaminates a later test — the later test finds stale data and never fetches, producing a false pass or a confusing failure. Create a new `QueryClient` in each test or `beforeEach`.

**Pitfall: Missing `retry: false`**

Without this, a single failed `queryFn` causes Query to retry three times with exponential backoff. Tests become slow (several seconds per failure) and can time out. Always set `retry: false` in the test client.

**Pitfall: Query key mismatch between `setQueryData` and `useQuery`**

If `setQueryData(['posts'])` is called but the component uses `useQuery({ queryKey: ['posts', { page: 1 }] })`, the cache miss causes a real fetch. Query keys must match exactly — use shared `queryOptions` factories to keep keys consistent.

**Pitfall: Asserting on data state without `waitFor`**

Query fetches asynchronously. Asserting on rendered data immediately after `render(...)` checks the loading state, not the data state. Wrap data assertions in `waitFor`.

**Pitfall: Not resetting `fetch` mock between tests**

If `global.fetch` is mocked and not reset, mock responses from one test bleed into the next. Use `vi.restoreAllMocks()` or `jest.restoreAllMocks()` in `afterEach`, or prefer MSW which handles request isolation automatically.

**Pitfall: Testing Query internals instead of component behavior**

Asserting that `useQuery` was called with specific arguments couples tests to implementation. Test what the user sees — rendered text, accessible elements, visible state changes — not which hooks were invoked.

---

**Related Topics:**
- Testing optimistic updates — asserting on intermediate cache state during mutation
- Integration testing with MSW and a full router tree
- Testing `useInfiniteQuery` — triggering load-more and asserting on accumulated pages
- Snapshot testing with Query-powered components — stability concerns
- Testing custom hooks that compose multiple `useQuery` calls
- Mocking `queryClient.invalidateQueries` to assert invalidation without triggering refetches
- End-to-end testing with Playwright and MSW for consistent data across browser tests