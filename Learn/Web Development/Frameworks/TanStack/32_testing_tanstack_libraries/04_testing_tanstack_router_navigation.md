## Testing TanStack Router Navigation

Testing navigation in TanStack Router requires rendering routes in a controlled environment, triggering navigation events, and asserting that the correct route renders, URL state updates, and route-level logic (loaders, guards, redirects) behaves as expected.

---

### Testing Environment Options

TanStack Router provides two primary history/memory strategies for testing:

| Strategy | Use Case |
|---|---|
| `createMemoryHistory` | Unit and integration tests — no real browser URL |
| `createBrowserHistory` | E2E tests in a real browser environment (Playwright, Cypress) |

For unit and integration tests, `createMemoryHistory` is the correct choice. It behaves identically to browser history internally but does not interact with `window.location`.

---

### Minimal Router Setup for Tests

```ts
import {
  createRouter,
  createRootRoute,
  createRoute,
  createMemoryHistory,
  RouterProvider,
} from '@tanstack/react-router';
import { render } from '@testing-library/react';

const rootRoute = createRootRoute();

const indexRoute = createRoute({
  getParentRoute: () => rootRoute,
  path: '/',
  component: () => <div>Home</div>,
});

const aboutRoute = createRoute({
  getParentRoute: () => rootRoute,
  path: '/about',
  component: () => <div>About</div>,
});

const routeTree = rootRoute.addChildren([indexRoute, aboutRoute]);

function createTestRouter(initialPath = '/') {
  const memoryHistory = createMemoryHistory({ initialEntries: [initialPath] });
  return createRouter({ routeTree, history: memoryHistory });
}
```

Each test gets a fresh router instance to prevent state contamination.

---

### Rendering and Asserting Initial Route

```ts
import { RouterProvider } from '@tanstack/react-router';
import { render, screen } from '@testing-library/react';

test('renders home route at /', async () => {
  const router = createTestRouter('/');
  render(<RouterProvider router={router} />);

  expect(await screen.findByText('Home')).toBeInTheDocument();
});

test('renders about route at /about', async () => {
  const router = createTestRouter('/about');
  render(<RouterProvider router={router} />);

  expect(await screen.findByText('About')).toBeInTheDocument();
});
```

Use `findBy*` (async) rather than `getBy*` (synchronous) because TanStack Router resolves routes asynchronously, including running loaders before rendering.

> [Inference] Synchronous `getBy*` assertions on route components may fail intermittently if the router has not yet committed the route. Use `findBy*` or wrap in `waitFor`.

---

### Testing Link Navigation

Test that clicking a `<Link>` component transitions to the correct route:

```tsx
const navRoute = createRoute({
  getParentRoute: () => rootRoute,
  path: '/',
  component: () => (
    <nav>
      <Link to="/about">Go to About</Link>
    </nav>
  ),
});
```

```ts
test('navigates to /about on link click', async () => {
  const router = createTestRouter('/');
  render(<RouterProvider router={router} />);

  const link = await screen.findByRole('link', { name: /go to about/i });
  fireEvent.click(link);

  expect(await screen.findByText('About')).toBeInTheDocument();
});
```

---

### Testing Programmatic Navigation

When components call `router.navigate(...)` or `useNavigate()` programmatically:

```tsx
function RedirectButton() {
  const navigate = useNavigate();
  return (
    <button onClick={() => navigate({ to: '/about' })}>
      Go to About
    </button>
  );
}
```

```ts
test('navigates programmatically on button click', async () => {
  const router = createTestRouter('/');
  render(<RouterProvider router={router} />);

  const button = await screen.findByRole('button', { name: /go to about/i });
  fireEvent.click(button);

  await waitFor(() => {
    expect(router.state.location.pathname).toBe('/about');
  });

  expect(await screen.findByText('About')).toBeInTheDocument();
});
```

Asserting `router.state.location.pathname` directly validates URL state independent of rendered output.

---

### Testing Route Parameters

Define a route with a path parameter:

```ts
const userRoute = createRoute({
  getParentRoute: () => rootRoute,
  path: '/users/$userId',
  component: function UserPage() {
    const { userId } = useParams({ from: '/users/$userId' });
    return <div>User: {userId}</div>;
  },
});
```

Test that the correct parameter is extracted and rendered:

```ts
test('renders correct userId from route params', async () => {
  const router = createTestRouter('/users/42');
  render(<RouterProvider router={router} />);

  expect(await screen.findByText('User: 42')).toBeInTheDocument();
});
```

---

### Testing Search Parameters

```ts
const searchRoute = createRoute({
  getParentRoute: () => rootRoute,
  path: '/search',
  validateSearch: (search) => ({
    query: search.query as string ?? '',
  }),
  component: function SearchPage() {
    const { query } = useSearch({ from: '/search' });
    return <div>Query: {query}</div>;
  },
});
```

```ts
test('reads search param from URL', async () => {
  const router = createTestRouter('/search?query=tanstack');
  render(<RouterProvider router={router} />);

  expect(await screen.findByText('Query: tanstack')).toBeInTheDocument();
});
```

---

### Testing Route Loaders

Route loaders run before the component renders. Test that loader data is available in the component:

```ts
const postsRoute = createRoute({
  getParentRoute: () => rootRoute,
  path: '/posts',
  loader: async () => {
    return { posts: [{ id: '1', title: 'Hello' }] };
  },
  component: function PostsPage() {
    const { posts } = useLoaderData({ from: '/posts' });
    return <ul>{posts.map(p => <li key={p.id}>{p.title}</li>)}</ul>;
  },
});
```

```ts
test('renders posts from loader', async () => {
  const router = createTestRouter('/posts');
  render(<RouterProvider router={router} />);

  expect(await screen.findByText('Hello')).toBeInTheDocument();
});
```

To test with a mocked async loader:

```ts
const postsRoute = createRoute({
  getParentRoute: () => rootRoute,
  path: '/posts',
  loader: () => fetchPosts(), // external function — mockable
  component: PostsPage,
});
```

```ts
vi.mock('./api', () => ({
  fetchPosts: vi.fn().mockResolvedValue([{ id: '1', title: 'Mocked' }]),
}));

test('renders mocked loader data', async () => {
  const router = createTestRouter('/posts');
  render(<RouterProvider router={router} />);

  expect(await screen.findByText('Mocked')).toBeInTheDocument();
});
```

---

### Testing Redirects

Test that navigation to a guarded route redirects to the expected path:

```ts
import { redirect } from '@tanstack/react-router';

const protectedRoute = createRoute({
  getParentRoute: () => rootRoute,
  path: '/dashboard',
  beforeLoad: ({ context }) => {
    if (!context.auth.isAuthenticated) {
      throw redirect({ to: '/login' });
    }
  },
  component: () => <div>Dashboard</div>,
});
```

Pass auth context through the router:

```ts
function createTestRouter(initialPath: string, authState = { isAuthenticated: false }) {
  const memoryHistory = createMemoryHistory({ initialEntries: [initialPath] });
  return createRouter({
    routeTree,
    history: memoryHistory,
    context: { auth: authState },
  });
}
```

```ts
test('redirects unauthenticated user from /dashboard to /login', async () => {
  const router = createTestRouter('/dashboard', { isAuthenticated: false });
  render(<RouterProvider router={router} />);

  expect(await screen.findByText('Login')).toBeInTheDocument();
  expect(router.state.location.pathname).toBe('/login');
});

test('allows authenticated user to access /dashboard', async () => {
  const router = createTestRouter('/dashboard', { isAuthenticated: true });
  render(<RouterProvider router={router} />);

  expect(await screen.findByText('Dashboard')).toBeInTheDocument();
});
```

---

### Testing 404 / notFound Behavior

```ts
const rootRoute = createRootRoute({
  notFoundComponent: () => <div>404 Not Found</div>,
});
```

```ts
test('renders 404 for unknown route', async () => {
  const router = createTestRouter('/does-not-exist');
  render(<RouterProvider router={router} />);

  expect(await screen.findByText('404 Not Found')).toBeInTheDocument();
});
```

---

### Asserting Router State Directly

Beyond rendered output, `router.state` exposes navigable state for assertions:

```ts
router.state.location.pathname     // current path
router.state.location.search       // raw search string
router.state.location.hash         // hash fragment
router.state.matches               // active route matches
router.state.status                // 'idle' | 'pending'
```

```ts
await waitFor(() => {
  expect(router.state.status).toBe('idle');
  expect(router.state.location.pathname).toBe('/about');
});
```

> [Inference] `router.state` reflects the committed navigation state. During a pending navigation (loader in progress), `status` will be `'pending'`. Assertions on `pathname` should be wrapped in `waitFor` to wait for navigation to settle.

---

### Testing Back/Forward Navigation

`createMemoryHistory` supports `back()` and `forward()`:

```ts
test('navigates back to previous route', async () => {
  const history = createMemoryHistory({ initialEntries: ['/', '/about'] });
  const router = createRouter({ routeTree, history });

  render(<RouterProvider router={router} />);
  expect(await screen.findByText('About')).toBeInTheDocument();

  act(() => history.back());

  expect(await screen.findByText('Home')).toBeInTheDocument();
});
```

---

### Reusable Test Router Factory

For larger test suites, centralize router creation:

```ts
// test-utils/router.tsx
import { createMemoryHistory, createRouter, RouterProvider } from '@tanstack/react-router';
import { routeTree } from '../routes';

export function createTestRouter(
  initialPath = '/',
  context: Record<string, unknown> = {}
) {
  return createRouter({
    routeTree,
    history: createMemoryHistory({ initialEntries: [initialPath] }),
    context,
  });
}

export function renderRouter(initialPath = '/', context = {}) {
  const router = createTestRouter(initialPath, context);
  const result = render(<RouterProvider router={router} />);
  return { ...result, router };
}
```

---

### Common Pitfalls

| Pitfall | Problem | Fix |
|---|---|---|
| Reusing router instances across tests | Route state bleeds between tests | Create a fresh router per test |
| Using `getBy*` for route components | Route resolution is async | Use `findBy*` or `waitFor` |
| Not passing `context` to test router | `beforeLoad` context access throws | Pass required context via `createRouter({ context })` |
| Asserting `pathname` before navigation settles | Assertion runs before loader resolves | Wrap in `waitFor` |
| Using `createBrowserHistory` in jsdom | Interacts with real `window.location` | Use `createMemoryHistory` for all non-E2E tests |

---

**Related Topics:**
- Testing `beforeLoad` and route guards in isolation
- Testing nested and layout route rendering
- Testing route context and `useRouteContext`
- Testing `useNavigate` in custom hooks with `renderHook`
- Testing scroll restoration behavior
- Testing route-level error boundaries
- End-to-end navigation testing with Playwright and TanStack Router
- Testing deferred/streamed loader data in routes