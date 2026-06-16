## Testing Mutations

Testing `useMutation` requires validating not just the mutation function itself, but the full lifecycle: pending state, success and error callbacks, side effects like cache invalidation, and UI feedback. Mutations are inherently side-effectful, making isolation and control critical.

---

### What to Test in a Mutation

Before writing tests, identify the behaviors under test:

- The mutation function is called with correct arguments
- Pending/loading state renders correctly
- Success state renders correctly and triggers expected side effects
- Error state renders correctly
- `onSuccess`, `onError`, `onSettled` callbacks fire
- Cache invalidation or `setQueryData` occurs after success
- Optimistic updates apply and roll back on error

---

### Basic Setup

Use the same test `QueryClient` pattern established for query tests:

```ts
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { render, fireEvent, waitFor } from '@testing-library/react';

function createTestQueryClient() {
  return new QueryClient({
    defaultOptions: {
      queries: { retry: false },
      mutations: { retry: false },
    },
  });
}

function renderWithClient(ui: React.ReactElement) {
  const queryClient = createTestQueryClient();
  return {
    ...render(
      <QueryClientProvider client={queryClient}>{ui}</QueryClientProvider>
    ),
    queryClient,
  };
}
```

---

### Testing a Basic Mutation Component

Given a component:

```tsx
function CreatePostForm() {
  const mutation = useMutation({
    mutationFn: (title: string) =>
      fetch('/api/posts', {
        method: 'POST',
        body: JSON.stringify({ title }),
      }).then(res => res.json()),
  });

  return (
    <div>
      <button onClick={() => mutation.mutate('New Post')}>
        Create Post
      </button>
      {mutation.isPending && <p>Creating...</p>}
      {mutation.isSuccess && <p>Post created!</p>}
      {mutation.isError && <p>Error: {mutation.error.message}</p>}
    </div>
  );
}
```

**Testing success path:**

```ts
import { http, HttpResponse } from 'msw';
import { setupServer } from 'msw/node';

const server = setupServer(
  http.post('/api/posts', () =>
    HttpResponse.json({ id: '1', title: 'New Post' })
  )
);

beforeAll(() => server.listen());
afterEach(() => server.resetHandlers());
afterAll(() => server.close());

test('shows success message after mutation', async () => {
  const { getByRole, getByText } = renderWithClient(<CreatePostForm />);

  fireEvent.click(getByRole('button', { name: /create post/i }));

  expect(getByText(/creating/i)).toBeInTheDocument();

  await waitFor(() => {
    expect(getByText(/post created/i)).toBeInTheDocument();
  });
});
```

**Testing error path:**

```ts
test('shows error message on failure', async () => {
  server.use(
    http.post('/api/posts', () =>
      HttpResponse.json({ message: 'Server error' }, { status: 500 })
    )
  );

  const { getByRole, getByText } = renderWithClient(<CreatePostForm />);

  fireEvent.click(getByRole('button', { name: /create post/i }));

  await waitFor(() => {
    expect(getByText(/error/i)).toBeInTheDocument();
  });
});
```

> [Inference] MSW v2 syntax (`http`, `HttpResponse`) is used here. MSW v1 uses `rest.*`. Confirm against your installed MSW version.

---

### Testing with a Mocked mutationFn

When you want to test mutation behavior without MSW, mock the `mutationFn` directly:

```ts
test('calls mutationFn with correct arguments', async () => {
  const mockFn = vi.fn().mockResolvedValue({ id: '1' });

  function TestComponent() {
    const mutation = useMutation({ mutationFn: mockFn });
    return (
      <button onClick={() => mutation.mutate('hello')}>Go</button>
    );
  }

  const { getByRole } = renderWithClient(<TestComponent />);
  fireEvent.click(getByRole('button', { name: /go/i }));

  await waitFor(() => {
    expect(mockFn).toHaveBeenCalledWith('hello');
  });
});
```

This approach decouples the test from network behavior and focuses on argument passing and callback triggering.

---

### Testing onSuccess and onError Callbacks

Callbacks passed to `useMutation` are common extension points. Test that they fire with the correct arguments:

```ts
test('onSuccess receives mutation result', async () => {
  const onSuccess = vi.fn();
  const mockFn = vi.fn().mockResolvedValue({ id: '42', title: 'Test' });

  function TestComponent() {
    const mutation = useMutation({
      mutationFn: mockFn,
      onSuccess,
    });
    return <button onClick={() => mutation.mutate('Test')}>Submit</button>;
  }

  const { getByRole } = renderWithClient(<TestComponent />);
  fireEvent.click(getByRole('button', { name: /submit/i }));

  await waitFor(() => {
    expect(onSuccess).toHaveBeenCalledWith(
      { id: '42', title: 'Test' },
      'Test',
      undefined
    );
  });
});
```

`onSuccess` signature is `(data, variables, context)` — the third argument is the optimistic update context, `undefined` when not used.

```ts
test('onError receives error object', async () => {
  const onError = vi.fn();
  const mockFn = vi.fn().mockRejectedValue(new Error('Failed'));

  function TestComponent() {
    const mutation = useMutation({ mutationFn: mockFn, onError });
    return <button onClick={() => mutation.mutate('x')}>Submit</button>;
  }

  const { getByRole } = renderWithClient(<TestComponent />);
  fireEvent.click(getByRole('button', { name: /submit/i }));

  await waitFor(() => {
    expect(onError).toHaveBeenCalledWith(
      expect.objectContaining({ message: 'Failed' }),
      'x',
      undefined
    );
  });
});
```

---

### Testing Cache Invalidation After Mutation

A common pattern is to invalidate related queries after a mutation succeeds. Test that the correct query keys are invalidated:

```ts
test('invalidates posts query on success', async () => {
  const mockFn = vi.fn().mockResolvedValue({ id: '1' });

  function TestComponent() {
    const queryClient = useQueryClient();
    const mutation = useMutation({
      mutationFn: mockFn,
      onSuccess: () => {
        queryClient.invalidateQueries({ queryKey: ['posts'] });
      },
    });
    return <button onClick={() => mutation.mutate('New')}>Submit</button>;
  }

  const { getByRole, queryClient } = renderWithClient(<TestComponent />);

  // Seed a query so invalidation has something to act on
  queryClient.setQueryData(['posts'], [{ id: '0', title: 'Existing' }]);

  const invalidateSpy = vi.spyOn(queryClient, 'invalidateQueries');

  fireEvent.click(getByRole('button', { name: /submit/i }));

  await waitFor(() => {
    expect(invalidateSpy).toHaveBeenCalledWith(
      expect.objectContaining({ queryKey: ['posts'] })
    );
  });
});
```

> [Inference] Spying on `invalidateQueries` tests that the call was made with correct arguments. It does not verify that downstream queries actually refetched — that requires additional query state assertions.

---

### Testing setQueryData After Mutation

When mutations update the cache directly instead of invalidating:

```ts
test('updates cache directly on success', async () => {
  const newPost = { id: '99', title: 'Direct Update' };
  const mockFn = vi.fn().mockResolvedValue(newPost);

  function TestComponent() {
    const queryClient = useQueryClient();
    const mutation = useMutation({
      mutationFn: mockFn,
      onSuccess: (data) => {
        queryClient.setQueryData(['posts', data.id], data);
      },
    });
    return <button onClick={() => mutation.mutate('Direct Update')}>Submit</button>;
  }

  const { getByRole, queryClient } = renderWithClient(<TestComponent />);
  fireEvent.click(getByRole('button', { name: /submit/i }));

  await waitFor(() => {
    expect(queryClient.getQueryData(['posts', '99'])).toEqual(newPost);
  });
});
```

---

### Testing Optimistic Updates

Optimistic updates modify the cache before the mutation resolves and roll back on error. This requires testing three states: optimistic applied, confirmed, and rolled back.

Given a mutation with optimistic update:

```ts
const mutation = useMutation({
  mutationFn: updatePost,
  onMutate: async (updated) => {
    await queryClient.cancelQueries({ queryKey: ['posts'] });
    const previous = queryClient.getQueryData(['posts']);
    queryClient.setQueryData(['posts'], (old: Post[]) =>
      old.map(p => p.id === updated.id ? { ...p, ...updated } : p)
    );
    return { previous };
  },
  onError: (err, variables, context) => {
    queryClient.setQueryData(['posts'], context?.previous);
  },
  onSettled: () => {
    queryClient.invalidateQueries({ queryKey: ['posts'] });
  },
});
```

**Testing optimistic apply:**

```ts
test('applies optimistic update before mutation resolves', async () => {
  const { queryClient } = renderWithClient(<PostList />);

  queryClient.setQueryData(['posts'], [
    { id: '1', title: 'Original' },
  ]);

  // Delay resolution to observe intermediate state
  const mockFn = vi.fn().mockImplementation(
    () => new Promise(resolve => setTimeout(() => resolve({}), 500))
  );

  // ... trigger mutation and assert intermediate cache state
});
```

**Testing rollback:**

```ts
test('rolls back optimistic update on error', async () => {
  const original = [{ id: '1', title: 'Original' }];
  const mockFn = vi.fn().mockRejectedValue(new Error('Failed'));

  // ... render, seed cache with original, trigger mutation
  // assert cache returns to original after rejection

  await waitFor(() => {
    expect(queryClient.getQueryData(['posts'])).toEqual(original);
  });
});
```

> [Inference] Testing timing-sensitive optimistic states may require controlled promise resolution (e.g., deferred promises). Behavior depends on test runner timing and React rendering cycle. Results may vary.

---

### Testing mutateAsync

`mutateAsync` returns a promise, making it testable without relying on callback spies:

```ts
test('mutateAsync resolves with returned data', async () => {
  const mockFn = vi.fn().mockResolvedValue({ id: '1', title: 'Created' });

  function TestComponent() {
    const mutation = useMutation({ mutationFn: mockFn });
    return (
      <button
        onClick={async () => {
          const result = await mutation.mutateAsync('Created');
          console.log('result', result);
        }}
      >
        Submit
      </button>
    );
  }

  const { getByRole } = renderWithClient(<TestComponent />);
  fireEvent.click(getByRole('button', { name: /submit/i }));

  await waitFor(() => {
    expect(mockFn).toHaveBeenCalledWith('Created');
  });
});
```

> [Inference] `mutateAsync` propagates errors — tests calling it should account for unhandled rejections if error handling is not present in the component.

---

### Testing renderHook with useMutation

For testing custom mutation hooks directly:

```ts
import { renderHook, act } from '@testing-library/react';

test('useCreatePost hook calls mutationFn', async () => {
  const mockFn = vi.fn().mockResolvedValue({ id: '1' });
  const { Wrapper } = createWrapper();

  const { result } = renderHook(() =>
    useMutation({ mutationFn: mockFn }),
    { wrapper: Wrapper }
  );

  act(() => {
    result.current.mutate('My Post');
  });

  await waitFor(() => {
    expect(result.current.isSuccess).toBe(true);
    expect(mockFn).toHaveBeenCalledWith('My Post');
  });
});
```

---

### Asserting Mutation State Transitions

Test that the component moves through `idle → pending → success` (or `error`) correctly:

```ts
test('transitions through pending to success', async () => {
  let resolvePromise!: (value: unknown) => void;
  const mockFn = vi.fn().mockImplementation(
    () => new Promise(resolve => { resolvePromise = resolve; })
  );

  function TestComponent() {
    const mutation = useMutation({ mutationFn: mockFn });
    return (
      <>
        <button onClick={() => mutation.mutate('x')}>Submit</button>
        <p data-testid="status">{mutation.status}</p>
      </>
    );
  }

  const { getByRole, getByTestId } = renderWithClient(<TestComponent />);

  expect(getByTestId('status').textContent).toBe('idle');

  fireEvent.click(getByRole('button', { name: /submit/i }));
  expect(getByTestId('status').textContent).toBe('pending');

  act(() => resolvePromise({ ok: true }));

  await waitFor(() => {
    expect(getByTestId('status').textContent).toBe('success');
  });
});
```

---

### Common Pitfalls

| Pitfall | Problem | Fix |
|---|---|---|
| No `retry: false` on mutations | Retries cause timeout failures in error tests | Set `mutations: { retry: false }` in test client |
| Asserting before `waitFor` | Async state not yet settled | Wrap assertions in `waitFor` |
| Shared `QueryClient` across tests | Cache state bleeds between tests | Create a new instance per test |
| Not wrapping `mutate` calls in `act` with `renderHook` | React state update warning | Use `act(() => result.current.mutate(...))` |
| Unhandled rejection from `mutateAsync` | Test fails with uncaught error | Add `.catch()` or use `try/catch` in the component |

---

**Related Topics:**
- Testing optimistic updates with controlled promise timing
- Testing `onSettled` and cleanup behavior
- Testing mutation state with `useIsMutating`
- Testing multiple concurrent mutations
- Combining mutation tests with form library integration (React Hook Form + TanStack Query)
- Testing mutation side effects across component boundaries
- Testing cache invalidation cascades