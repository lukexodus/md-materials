## Testing Route Loaders and Guards

Route loaders and guards (`beforeLoad`) are the primary mechanisms for data fetching and access control in TanStack Router. Testing them in isolation — separate from component rendering — and in integration with the full router pipeline are both valid and complementary approaches.

---

### Conceptual Separation

Before writing tests, distinguish what is under test:

| Target | What to Test |
|---|---|
| Loader function (unit) | Return value, error throwing, argument shape |
| Guard / `beforeLoad` (unit) | Redirect throwing, context mutation, conditional logic |
| Loader + component (integration) | Data availability in rendered output |
| Guard + router (integration) | Redirect destination, route access control |

Unit tests run faster and are more precise. Integration tests catch wiring errors between the router configuration and the functions.

---

### Unit Testing a Loader Function

A loader is a plain async function. Test it directly without involving the router:

```ts
// loaders/postsLoader.ts
export async function postsLoader() {
  const res = await fetch('/api/posts');
  if (!res.ok) throw new Error('Failed to fetch posts');
  return res.json();
}
```

```ts
import { postsLoader } from './loaders/postsLoader';

test('returns post data on success', async () => {
  vi.stubGlobal('fetch', vi.fn().mockResolvedValue({
    ok: true,
    json: async () => [{ id: '1', title: 'Hello' }],
  }));

  const result = await postsLoader();
  expect(result).toEqual([{ id: '1', title: 'Hello' }]);
});

test('throws on non-ok response', async () => {
  vi.stubGlobal('fetch', vi.fn().mockResolvedValue({ ok: false }));

  await expect(postsLoader()).rejects.toThrow('Failed to fetch posts');
});
```

> [Inference] `vi.stubGlobal` is Vitest-specific. In Jest, use `global.fetch = vi.fn(...)` or `jest.spyOn(global, 'fetch')`. Behavior may vary across test runner versions.

---

### Loader Arguments: `params`, `context`, `deps`

TanStack Router passes a structured argument object to each loader. Test that loaders use these arguments correctly:

```ts
// loaders/userLoader.ts
export async function userLoader({
  params,
  context,
}: {
  params: { userId: string };
  context: { apiClient: { getUser: (id: string) => Promise<unknown> } };
}) {
  return context.apiClient.getUser(params.userId);
}
```

```ts
test('calls apiClient with correct userId', async () => {
  const mockGetUser = vi.fn().mockResolvedValue({ id: '42', name: 'Luke' });

  const result = await userLoader({
    params: { userId: '42' },
    context: { apiClient: { getUser: mockGetUser } },
  });

  expect(mockGetUser).toHaveBeenCalledWith('42');
  expect(result).toEqual({ id: '42', name: 'Luke' });
});
```

This approach tests loader logic in complete isolation from the router.

---

### Unit Testing beforeLoad (Guard Logic)

`beforeLoad` is also a plain async function that receives a context argument. Test it by calling it directly with a mock context:

```ts
// routes/dashboard.ts
import { redirect } from '@tanstack/react-router';

export async function dashboardBeforeLoad({
  context,
}: {
  context: { auth: { isAuthenticated: boolean } };
}) {
  if (!context.auth.isAuthenticated) {
    throw redirect({ to: '/login' });
  }
}
```

```ts
import { redirect } from '@tanstack/react-router';
import { dashboardBeforeLoad } from './routes/dashboard';

test('throws redirect when unauthenticated', async () => {
  await expect(
    dashboardBeforeLoad({ context: { auth: { isAuthenticated: false } } })
  ).rejects.toMatchObject({
    to: '/login',
  });
});

test('does not throw when authenticated', async () => {
  await expect(
    dashboardBeforeLoad({ context: { auth: { isAuthenticated: true } } })
  ).resolves.toBeUndefined();
});
```

> [Inference] TanStack Router's `redirect()` throws an object rather than a standard `Error`. The shape of the thrown object may vary across versions — verify with `console.log` or check the source if assertions fail unexpectedly.

---

### Asserting Redirect Shape

The redirect object thrown by `redirect()` can be inspected directly to assert destination, search params, and replace behavior:

```ts
test('redirect targets /login with replace', async () => {
  let thrown: unknown;

  try {
    await dashboardBeforeLoad({ context: { auth: { isAuthenticated: false } } });
  } catch (e) {
    thrown = e;
  }

  expect(thrown).toMatchObject({
    to: '/login',
  });
});
```

For redirects with search params or state:

```ts
throw redirect({
  to: '/login',
  search: { returnTo: '/dashboard' },
  replace: true,
});
```

```ts
expect(thrown).toMatchObject({
  to: '/login',
  search: { returnTo: '/dashboard' },
});
```

---

### Testing beforeLoad Context Mutation

`beforeLoad` can augment context passed to child routes. Test that it returns the correct extended context:

```ts
export async function rootBeforeLoad({ context }) {
  const user = await context.authService.getCurrentUser();
  return { ...context, user };
}
```

```ts
test('augments context with current user', async () => {
  const mockUser = { id: '1', role: 'admin' };
  const context = {
    authService: {
      getCurrentUser: vi.fn().mockResolvedValue(mockUser),
    },
  };

  const result = await rootBeforeLoad({ context });

  expect(result.user).toEqual(mockUser);
  expect(result.authService).toBe(context.authService);
});
```

---

### Integration Testing: Loader Data in Component

Test that loader data flows through the router and is available to the component:

```ts
import {
  createRootRoute,
  createRoute,
  createRouter,
  createMemoryHistory,
  RouterProvider,
  useLoaderData,
} from '@tanstack/react-router';
import { render, screen } from '@testing-library/react';

const rootRoute = createRootRoute();

const postsRoute = createRoute({
  getParentRoute: () => rootRoute,
  path: '/posts',
  loader: () => [{ id: '1', title: 'Integration Post' }],
  component: function PostsPage() {
    const posts = useLoaderData({ from: '/posts' });
    return <ul>{posts.map(p => <li key={p.id}>{p.title}</li>)}</ul>;
  },
});

const routeTree = rootRoute.addChildren([postsRoute]);

test('loader data renders in component', async () => {
  const router = createRouter({
    routeTree,
    history: createMemoryHistory({ initialEntries: ['/posts'] }),
  });

  render(<RouterProvider router={router} />);

  expect(await screen.findByText('Integration Post')).toBeInTheDocument();
});
```

---

### Integration Testing: Loader with Mocked External Dependency

When the loader calls an external service, mock the service rather than the loader:

```ts
// api/posts.ts
export async function fetchPosts() {
  const res = await fetch('/api/posts');
  return res.json();
}
```

```ts
import * as postsApi from './api/posts';

vi.mock('./api/posts');

test('renders posts from mocked API', async () => {
  vi.mocked(postsApi.fetchPosts).mockResolvedValue([
    { id: '1', title: 'Mocked Post' },
  ]);

  const postsRoute = createRoute({
    getParentRoute: () => rootRoute,
    path: '/posts',
    loader: () => postsApi.fetchPosts(),
    component: function PostsPage() {
      const posts = useLoaderData({ from: '/posts' });
      return <ul>{posts.map(p => <li key={p.id}>{p.title}</li>)}</ul>;
    },
  });

  const router = createRouter({
    routeTree: rootRoute.addChildren([postsRoute]),
    history: createMemoryHistory({ initialEntries: ['/posts'] }),
  });

  render(<RouterProvider router={router} />);

  expect(await screen.findByText('Mocked Post')).toBeInTheDocument();
});
```

---

### Integration Testing: Guard Redirect

Test that a guarded route redirects to the correct destination when the guard throws:

```ts
const loginRoute = createRoute({
  getParentRoute: () => rootRoute,
  path: '/login',
  component: () => <div>Login Page</div>,
});

const dashboardRoute = createRoute({
  getParentRoute: () => rootRoute,
  path: '/dashboard',
  beforeLoad: ({ context }) => {
    if (!context.auth?.isAuthenticated) {
      throw redirect({ to: '/login' });
    }
  },
  component: () => <div>Dashboard</div>,
});

const routeTree = rootRoute.addChildren([loginRoute, dashboardRoute]);

test('redirects to /login when unauthenticated', async () => {
  const router = createRouter({
    routeTree,
    history: createMemoryHistory({ initialEntries: ['/dashboard'] }),
    context: { auth: { isAuthenticated: false } },
  });

  render(<RouterProvider router={router} />);

  expect(await screen.findByText('Login Page')).toBeInTheDocument();
  expect(router.state.location.pathname).toBe('/login');
});

test('renders dashboard when authenticated', async () => {
  const router = createRouter({
    routeTree,
    history: createMemoryHistory({ initialEntries: ['/dashboard'] }),
    context: { auth: { isAuthenticated: true } },
  });

  render(<RouterProvider router={router} />);

  expect(await screen.findByText('Dashboard')).toBeInTheDocument();
});
```

---

### Testing Role-Based Guards

```ts
export async function adminBeforeLoad({ context }) {
  if (!context.auth.isAuthenticated) {
    throw redirect({ to: '/login' });
  }
  if (context.auth.user.role !== 'admin') {
    throw redirect({ to: '/forbidden' });
  }
}
```

```ts
const cases = [
  {
    label: 'unauthenticated',
    context: { auth: { isAuthenticated: false } },
    expectedRedirect: '/login',
  },
  {
    label: 'authenticated non-admin',
    context: { auth: { isAuthenticated: true, user: { role: 'user' } } },
    expectedRedirect: '/forbidden',
  },
];

test.each(cases)('redirects $label user correctly', async ({ context, expectedRedirect }) => {
  let thrown: unknown;
  try {
    await adminBeforeLoad({ context });
  } catch (e) {
    thrown = e;
  }
  expect(thrown).toMatchObject({ to: expectedRedirect });
});

test('allows admin user through', async () => {
  const context = { auth: { isAuthenticated: true, user: { role: 'admin' } } };
  await expect(adminBeforeLoad({ context })).resolves.toBeUndefined();
});
```

---

### Testing Loader Errors

Test that loaders throw in expected error conditions and that route error boundaries catch them:

```ts
const errorRoute = createRoute({
  getParentRoute: () => rootRoute,
  path: '/fail',
  loader: async () => {
    throw new Error('Loader failed');
  },
  errorComponent: ({ error }) => <div>Error: {error.message}</div>,
  component: () => <div>Should not render</div>,
});

test('renders errorComponent when loader throws', async () => {
  const router = createRouter({
    routeTree: rootRoute.addChildren([errorRoute]),
    history: createMemoryHistory({ initialEntries: ['/fail'] }),
  });

  render(<RouterProvider router={router} />);

  expect(await screen.findByText('Error: Loader failed')).toBeInTheDocument();
});
```

> [Inference] TanStack Router catches loader errors and passes them to `errorComponent` if defined on the route. If no `errorComponent` is defined, the error propagates to the nearest parent error boundary. Behavior may vary based on router version and configuration.

---

### Testing Loader with Pending / Suspense UI

If a `pendingComponent` is defined, test that it renders during loader resolution:

```ts
const slowRoute = createRoute({
  getParentRoute: () => rootRoute,
  path: '/slow',
  pendingComponent: () => <div>Loading...</div>,
  loader: () =>
    new Promise(resolve => setTimeout(() => resolve({ data: 'done' }), 200)),
  component: () => <div>Loaded</div>,
});

test('shows pendingComponent during loader', async () => {
  const router = createRouter({
    routeTree: rootRoute.addChildren([slowRoute]),
    history: createMemoryHistory({ initialEntries: ['/slow'] }),
  });

  render(<RouterProvider router={router} />);

  expect(await screen.findByText('Loading...')).toBeInTheDocument();
  expect(await screen.findByText('Loaded')).toBeInTheDocument();
});
```

> [Inference] Whether `pendingComponent` renders depends on `pendingMs` threshold configuration. If the loader resolves faster than `pendingMs` (default 1000ms), the pending component may not appear. Adjust `pendingMs` in the route or loader timing in tests accordingly.

---

### Testing Loader Dependencies (`loaderDeps`)

When a loader depends on search params via `loaderDeps`, test that loader re-runs when deps change:

```ts
const searchRoute = createRoute({
  getParentRoute: () => rootRoute,
  path: '/search',
  validateSearch: (s) => ({ q: s.q as string ?? '' }),
  loaderDeps: ({ search }) => ({ q: search.q }),
  loader: ({ deps }) => fetchResults(deps.q),
  component: function SearchPage() {
    const results = useLoaderData({ from: '/search' });
    return <div>{results.label}</div>;
  },
});
```

```ts
test('loader receives correct dep from search param', async () => {
  const mockFetch = vi.fn().mockResolvedValue({ label: 'Results for tanstack' });
  vi.mocked(fetchResults).mockImplementation(mockFetch);

  const router = createRouter({
    routeTree: rootRoute.addChildren([searchRoute]),
    history: createMemoryHistory({ initialEntries: ['/search?q=tanstack'] }),
  });

  render(<RouterProvider router={router} />);

  await waitFor(() => {
    expect(mockFetch).toHaveBeenCalledWith('tanstack');
  });
});
```

---

### Reusable Test Helpers

```ts
// test-utils/router.ts
export function buildRouter(
  routes: AnyRoute[],
  initialPath = '/',
  context: Record<string, unknown> = {}
) {
  const rootRoute = createRootRoute();
  return createRouter({
    routeTree: rootRoute.addChildren(routes),
    history: createMemoryHistory({ initialEntries: [initialPath] }),
    context,
  });
}

export function renderRoute(
  routes: AnyRoute[],
  initialPath = '/',
  context = {}
) {
  const router = buildRouter(routes, initialPath, context);
  return { ...render(<RouterProvider router={router} />), router };
}
```

---

### Common Pitfalls

| Pitfall | Problem | Fix |
|---|---|---|
| Not passing `context` to router | `beforeLoad` context access throws at runtime | Always pass required context via `createRouter({ context })` |
| Testing loader via `getBy*` | Loader is async; component not yet rendered | Use `findBy*` or `waitFor` |
| Reusing route definitions across tests | Route tree state may be shared | Reconstruct routes or route tree per test if stateful |
| Asserting redirect before router settles | `pathname` not yet updated | Wrap in `waitFor` |
| Ignoring `pendingMs` in pending component tests | Pending component may never render if loader is too fast | Set `pendingMs: 0` on the route for test predictability |
| Assuming `redirect()` throws a standard `Error` | `rejects.toThrow()` may not match | Use `rejects.toMatchObject({ to: '...' })` instead |

---

**Related Topics:**
- Testing `notFound()` thrown from loaders
- Testing loader data with TanStack Query (`routerWithQueryClient`)
- Testing nested route loader composition
- Testing `staleTime` and loader caching behavior
- Testing `shouldReload` and loader invalidation
- End-to-end guard testing with Playwright
- Testing `onEnter` / `onLeave` route lifecycle events