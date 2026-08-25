## Jest and Testing Libraries


### Mocking fetch API

#### Basic Mock Setup

Jest doesn't include a native fetch implementation, requiring manual mocking:

```javascript
// setupTests.js
global.fetch = jest.fn();

beforeEach(() => {
  fetch.mockClear();
});
```

For more robust testing, use dedicated mocking libraries:

```javascript
// Using jest-fetch-mock
import fetchMock from 'jest-fetch-mock';

fetchMock.enableMocks();

beforeEach(() => {
  fetchMock.resetMocks();
});
```

#### Response Mocking Patterns

Mock successful responses:

```javascript
test('fetches user data', async () => {
  fetch.mockResolvedValueOnce({
    ok: true,
    status: 200,
    json: async () => ({ id: 1, name: 'John' })
  });

  const data = await fetchUser(1);
  
  expect(fetch).toHaveBeenCalledWith('/api/users/1');
  expect(data).toEqual({ id: 1, name: 'John' });
});
```

Mock error responses:

```javascript
test('handles fetch errors', async () => {
  fetch.mockResolvedValueOnce({
    ok: false,
    status: 404,
    statusText: 'Not Found',
    json: async () => ({ error: 'User not found' })
  });

  await expect(fetchUser(999)).rejects.toThrow('User not found');
});
```

Mock network failures:

```javascript
test('handles network errors', async () => {
  fetch.mockRejectedValueOnce(new Error('Network error'));

  await expect(fetchUser(1)).rejects.toThrow('Network error');
  expect(fetch).toHaveBeenCalledTimes(1);
});
```

#### Sequential Mock Responses

Test multiple fetch calls with different responses:

```javascript
test('handles pagination', async () => {
  fetch
    .mockResolvedValueOnce({
      ok: true,
      json: async () => ({ items: [1, 2, 3], hasMore: true })
    })
    .mockResolvedValueOnce({
      ok: true,
      json: async () => ({ items: [4, 5, 6], hasMore: false })
    });

  const page1 = await fetchPage(1);
  const page2 = await fetchPage(2);

  expect(page1.items).toHaveLength(3);
  expect(page2.items).toHaveLength(3);
  expect(fetch).toHaveBeenCalledTimes(2);
});
```

### Testing React Components

#### React Testing Library Integration

Test components that fetch data on mount:

```javascript
import { render, screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';

test('displays user profile after loading', async () => {
  fetch.mockResolvedValueOnce({
    ok: true,
    json: async () => ({ name: 'Alice', email: 'alice@example.com' })
  });

  render(<UserProfile userId={1} />);

  // Check loading state
  expect(screen.getByText(/loading/i)).toBeInTheDocument();

  // Wait for data to load
  await waitFor(() => {
    expect(screen.getByText('Alice')).toBeInTheDocument();
  });

  expect(screen.getByText('alice@example.com')).toBeInTheDocument();
  expect(screen.queryByText(/loading/i)).not.toBeInTheDocument();
});
```

Test user-triggered fetches:

```javascript
test('loads data on button click', async () => {
  const user = userEvent.setup();
  
  fetch.mockResolvedValueOnce({
    ok: true,
    json: async () => ({ results: ['Item 1', 'Item 2'] })
  });

  render(<SearchComponent />);

  const button = screen.getByRole('button', { name: /search/i });
  await user.click(button);

  await waitFor(() => {
    expect(screen.getByText('Item 1')).toBeInTheDocument();
  });

  expect(fetch).toHaveBeenCalledWith('/api/search', expect.any(Object));
});
```

#### Testing Error States

Verify error handling in components:

```javascript
test('displays error message on fetch failure', async () => {
  fetch.mockRejectedValueOnce(new Error('API Error'));

  render(<DataComponent />);

  await waitFor(() => {
    expect(screen.getByText(/error/i)).toBeInTheDocument();
  });

  expect(screen.getByText(/api error/i)).toBeInTheDocument();
});

test('allows retry after error', async () => {
  const user = userEvent.setup();
  
  fetch
    .mockRejectedValueOnce(new Error('Failed'))
    .mockResolvedValueOnce({
      ok: true,
      json: async () => ({ data: 'Success' })
    });

  render(<DataComponent />);

  await waitFor(() => {
    expect(screen.getByText(/error/i)).toBeInTheDocument();
  });

  const retryButton = screen.getByRole('button', { name: /retry/i });
  await user.click(retryButton);

  await waitFor(() => {
    expect(screen.getByText('Success')).toBeInTheDocument();
  });

  expect(fetch).toHaveBeenCalledTimes(2);
});
```

#### Testing Loading States

Verify loading indicators appear correctly:

```javascript
test('shows loading spinner during fetch', async () => {
  let resolvePromise;
  const promise = new Promise(resolve => {
    resolvePromise = resolve;
  });

  fetch.mockReturnValueOnce(promise);

  render(<AsyncComponent />);

  // Loading state should be visible
  expect(screen.getByTestId('loading-spinner')).toBeInTheDocument();

  // Resolve the fetch
  resolvePromise({
    ok: true,
    json: async () => ({ data: 'Loaded' })
  });

  await waitFor(() => {
    expect(screen.queryByTestId('loading-spinner')).not.toBeInTheDocument();
  });

  expect(screen.getByText('Loaded')).toBeInTheDocument();
});
```

### Advanced Mock Strategies

#### Request Interception

Inspect request details:

```javascript
test('sends correct headers and body', async () => {
  fetch.mockResolvedValueOnce({
    ok: true,
    json: async () => ({ success: true })
  });

  await createUser({ name: 'Bob', role: 'admin' });

  expect(fetch).toHaveBeenCalledWith(
    '/api/users',
    expect.objectContaining({
      method: 'POST',
      headers: expect.objectContaining({
        'Content-Type': 'application/json',
        'Authorization': expect.stringMatching(/^Bearer /)
      }),
      body: JSON.stringify({ name: 'Bob', role: 'admin' })
    })
  );
});
```

Validate request URLs with query parameters:

```javascript
test('includes query parameters', async () => {
  fetch.mockResolvedValueOnce({
    ok: true,
    json: async () => ({ items: [] })
  });

  await searchItems({ query: 'test', page: 2, limit: 20 });

  const [url] = fetch.mock.calls[0];
  const urlObj = new URL(url, 'http://localhost');

  expect(urlObj.pathname).toBe('/api/search');
  expect(urlObj.searchParams.get('query')).toBe('test');
  expect(urlObj.searchParams.get('page')).toBe('2');
  expect(urlObj.searchParams.get('limit')).toBe('20');
});
```

#### Conditional Mocking

Create dynamic mock responses based on request:

```javascript
test('returns user-specific data', async () => {
  fetch.mockImplementation((url) => {
    const userId = url.split('/').pop();
    
    const users = {
      '1': { id: 1, name: 'Alice' },
      '2': { id: 2, name: 'Bob' }
    };

    return Promise.resolve({
      ok: true,
      json: async () => users[userId] || { error: 'Not found' }
    });
  });

  const alice = await fetchUser(1);
  const bob = await fetchUser(2);

  expect(alice.name).toBe('Alice');
  expect(bob.name).toBe('Bob');
});
```

Mock based on request method:

```javascript
test('handles different HTTP methods', async () => {
  fetch.mockImplementation((url, options) => {
    const method = options?.method || 'GET';

    if (method === 'GET') {
      return Promise.resolve({
        ok: true,
        json: async () => ({ items: [1, 2, 3] })
      });
    }

    if (method === 'POST') {
      return Promise.resolve({
        ok: true,
        status: 201,
        json: async () => ({ id: 4, created: true })
      });
    }

    return Promise.resolve({ ok: false, status: 405 });
  });

  const getResult = await getData();
  const postResult = await createData({ value: 'new' });

  expect(getResult.items).toHaveLength(3);
  expect(postResult.created).toBe(true);
});
```

#### Mock Response Builders

Create reusable mock response factories:

```javascript
const mockResponse = (data, options = {}) => ({
  ok: options.ok ?? true,
  status: options.status ?? 200,
  statusText: options.statusText ?? 'OK',
  headers: new Headers(options.headers || {}),
  json: async () => data,
  text: async () => JSON.stringify(data),
  blob: async () => new Blob([JSON.stringify(data)]),
  arrayBuffer: async () => new ArrayBuffer(8),
  ...options
});

test('uses response builder', async () => {
  fetch.mockResolvedValueOnce(
    mockResponse({ id: 1, name: 'Test' })
  );

  const data = await fetchData();
  expect(data.id).toBe(1);
});

test('mocks error response', async () => {
  fetch.mockResolvedValueOnce(
    mockResponse(
      { error: 'Unauthorized' },
      { ok: false, status: 401 }
    )
  );

  await expect(fetchData()).rejects.toThrow();
});
```

### MSW (Mock Service Worker)

#### Setup and Configuration

Install and configure MSW for browser-like mocking:

```javascript
// src/mocks/handlers.js
import { http, HttpResponse } from 'msw';

export const handlers = [
  http.get('/api/users/:id', ({ params }) => {
    const { id } = params;
    return HttpResponse.json({
      id: Number(id),
      name: `User ${id}`
    });
  }),

  http.post('/api/users', async ({ request }) => {
    const body = await request.json();
    return HttpResponse.json(
      { id: 123, ...body },
      { status: 201 }
    );
  }),

  http.delete('/api/users/:id', () => {
    return new HttpResponse(null, { status: 204 });
  })
];
```

Setup for Jest tests:

```javascript
// src/mocks/server.js
import { setupServer } from 'msw/node';
import { handlers } from './handlers';

export const server = setupServer(...handlers);

// setupTests.js
import { server } from './mocks/server';

beforeAll(() => server.listen());
afterEach(() => server.resetHandlers());
afterAll(() => server.close());
```

#### Dynamic Response Handling

Override handlers per test:

```javascript
import { http, HttpResponse } from 'msw';
import { server } from './mocks/server';

test('handles server error', async () => {
  server.use(
    http.get('/api/users/:id', () => {
      return new HttpResponse(null, { status: 500 });
    })
  );

  await expect(fetchUser(1)).rejects.toThrow();
});

test('handles network error', async () => {
  server.use(
    http.get('/api/users/:id', () => {
      return HttpResponse.error();
    })
  );

  await expect(fetchUser(1)).rejects.toThrow('Network error');
});
```

Delay responses to simulate latency:

```javascript
import { delay, http, HttpResponse } from 'msw';

test('shows loading state during slow request', async () => {
  server.use(
    http.get('/api/data', async () => {
      await delay(100);
      return HttpResponse.json({ data: 'slow' });
    })
  );

  render(<AsyncComponent />);

  expect(screen.getByText(/loading/i)).toBeInTheDocument();

  await waitFor(() => {
    expect(screen.getByText('slow')).toBeInTheDocument();
  }, { timeout: 200 });
});
```

#### Request Validation

Verify request details with MSW:

```javascript
test('sends authentication token', async () => {
  let capturedHeaders;

  server.use(
    http.get('/api/protected', ({ request }) => {
      capturedHeaders = Object.fromEntries(request.headers.entries());
      return HttpResponse.json({ data: 'protected' });
    })
  );

  await fetchProtectedData('token123');

  expect(capturedHeaders.authorization).toBe('Bearer token123');
});

test('validates request body', async () => {
  let capturedBody;

  server.use(
    http.post('/api/items', async ({ request }) => {
      capturedBody = await request.json();
      return HttpResponse.json({ success: true });
    })
  );

  await createItem({ name: 'New Item', quantity: 5 });

  expect(capturedBody).toEqual({
    name: 'New Item',
    quantity: 5
  });
});
```

#### GraphQL Support

Mock GraphQL endpoints:

```javascript
import { graphql, HttpResponse } from 'msw';

const handlers = [
  graphql.query('GetUser', ({ variables }) => {
    return HttpResponse.json({
      data: {
        user: {
          id: variables.id,
          name: 'GraphQL User'
        }
      }
    });
  }),

  graphql.mutation('CreateUser', ({ variables }) => {
    return HttpResponse.json({
      data: {
        createUser: {
          id: '123',
          name: variables.name
        }
      }
    });
  })
];

test('fetches user via GraphQL', async () => {
  const user = await fetchUserGraphQL('1');
  expect(user.name).toBe('GraphQL User');
});
```

### Testing Async Patterns

#### Polling and Intervals

Test functions that poll repeatedly:

```javascript
jest.useFakeTimers();

test('polls until condition met', async () => {
  let callCount = 0;

  fetch.mockImplementation(() => {
    callCount++;
    return Promise.resolve({
      ok: true,
      json: async () => ({
        status: callCount >= 3 ? 'complete' : 'pending'
      })
    });
  });

  const promise = pollUntilComplete('/api/job/123');

  // Fast-forward through polling intervals
  await jest.advanceTimersByTimeAsync(5000);

  const result = await promise;

  expect(result.status).toBe('complete');
  expect(fetch).toHaveBeenCalledTimes(3);
});

jest.useRealTimers();
```

Test timeout handling:

```javascript
jest.useFakeTimers();

test('times out after max attempts', async () => {
  fetch.mockResolvedValue({
    ok: true,
    json: async () => ({ status: 'pending' })
  });

  const promise = pollUntilComplete('/api/job/123', {
    timeout: 3000,
    interval: 1000
  });

  await jest.advanceTimersByTimeAsync(3000);

  await expect(promise).rejects.toThrow('Timeout');
});

jest.useRealTimers();
```

#### Race Conditions

Test concurrent fetch handling:

```javascript
test('handles concurrent requests', async () => {
  fetch
    .mockResolvedValueOnce({
      ok: true,
      json: async () => ({ id: 1, data: 'first' })
    })
    .mockResolvedValueOnce({
      ok: true,
      json: async () => ({ id: 2, data: 'second' })
    });

  const [first, second] = await Promise.all([
    fetchData(1),
    fetchData(2)
  ]);

  expect(first.data).toBe('first');
  expect(second.data).toBe('second');
  expect(fetch).toHaveBeenCalledTimes(2);
});
```

Test request deduplication:

```javascript
test('deduplicates simultaneous requests', async () => {
  let resolvePromise;
  const mockPromise = new Promise(resolve => {
    resolvePromise = resolve;
  });

  fetch.mockReturnValueOnce(mockPromise);

  // Start multiple requests simultaneously
  const promise1 = fetchWithCache('/api/data');
  const promise2 = fetchWithCache('/api/data');
  const promise3 = fetchWithCache('/api/data');

  // Resolve after all requests started
  resolvePromise({
    ok: true,
    json: async () => ({ value: 42 })
  });

  const [result1, result2, result3] = await Promise.all([
    promise1,
    promise2,
    promise3
  ]);

  expect(result1).toEqual({ value: 42 });
  expect(result1).toBe(result2); // Same reference
  expect(result2).toBe(result3);
  expect(fetch).toHaveBeenCalledTimes(1); // Only one actual fetch
});
```

#### Retry Logic

Test exponential backoff:

```javascript
jest.useFakeTimers();

test('retries with exponential backoff', async () => {
  fetch
    .mockRejectedValueOnce(new Error('Fail 1'))
    .mockRejectedValueOnce(new Error('Fail 2'))
    .mockResolvedValueOnce({
      ok: true,
      json: async () => ({ success: true })
    });

  const promise = fetchWithRetry('/api/data', { maxRetries: 3 });

  // First retry after 1s
  await jest.advanceTimersByTimeAsync(1000);

  // Second retry after 2s
  await jest.advanceTimersByTimeAsync(2000);

  const result = await promise;

  expect(result.success).toBe(true);
  expect(fetch).toHaveBeenCalledTimes(3);
});

jest.useRealTimers();
```

Test max retry limit:

```javascript
test('stops after max retries', async () => {
  fetch.mockRejectedValue(new Error('Persistent error'));

  await expect(
    fetchWithRetry('/api/data', { maxRetries: 3 })
  ).rejects.toThrow('Persistent error');

  expect(fetch).toHaveBeenCalledTimes(3);
});
```

### Integration Testing

#### End-to-End Flows

Test complete user workflows:

```javascript
test('complete checkout flow', async () => {
  const user = userEvent.setup();

  // Mock cart fetch
  fetch.mockResolvedValueOnce({
    ok: true,
    json: async () => ({
      items: [
        { id: 1, name: 'Product A', price: 10 }
      ]
    })
  });

  render(<CheckoutPage />);

  await waitFor(() => {
    expect(screen.getByText('Product A')).toBeInTheDocument();
  });

  // Fill shipping info
  const nameInput = screen.getByLabelText(/name/i);
  await user.type(nameInput, 'John Doe');

  // Mock checkout submission
  fetch.mockResolvedValueOnce({
    ok: true,
    json: async () => ({
      orderId: 'ORD-123',
      status: 'confirmed'
    })
  });

  const submitButton = screen.getByRole('button', { name: /submit/i });
  await user.click(submitButton);

  await waitFor(() => {
    expect(screen.getByText(/order confirmed/i)).toBeInTheDocument();
    expect(screen.getByText('ORD-123')).toBeInTheDocument();
  });

  // Verify checkout request
  expect(fetch).toHaveBeenLastCalledWith(
    '/api/checkout',
    expect.objectContaining({
      method: 'POST',
      body: expect.stringContaining('John Doe')
    })
  );
});
```

#### API Contract Testing

Verify request/response structure:

```javascript
const userSchema = {
  id: expect.any(Number),
  name: expect.any(String),
  email: expect.stringMatching(/^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$/),
  createdAt: expect.any(String)
};

test('API returns valid user structure', async () => {
  fetch.mockResolvedValueOnce({
    ok: true,
    json: async () => ({
      id: 1,
      name: 'Alice',
      email: 'alice@example.com',
      createdAt: '2024-01-01T00:00:00Z'
    })
  });

  const user = await fetchUser(1);

  expect(user).toMatchObject(userSchema);
});

test('validates error response structure', async () => {
  fetch.mockResolvedValueOnce({
    ok: false,
    status: 400,
    json: async () => ({
      error: 'Validation failed',
      details: [
        { field: 'email', message: 'Invalid format' }
      ]
    })
  });

  try {
    await createUser({ email: 'invalid' });
  } catch (err) {
    expect(err.details).toEqual([
      expect.objectContaining({
        field: expect.any(String),
        message: expect.any(String)
      })
    ]);
  }
});
```

### Snapshot Testing

#### Response Snapshots

Capture and verify API response structures:

```javascript
test('matches user response snapshot', async () => {
  fetch.mockResolvedValueOnce({
    ok: true,
    json: async () => ({
      id: 1,
      name: 'Test User',
      profile: {
        avatar: 'https://example.com/avatar.jpg',
        bio: 'Test bio'
      },
      settings: {
        notifications: true,
        theme: 'dark'
      }
    })
  });

  const user = await fetchUser(1);

  expect(user).toMatchSnapshot();
});
```

#### Component Snapshots

Test rendered output with fetched data:

```javascript
test('renders user profile correctly', async () => {
  fetch.mockResolvedValueOnce({
    ok: true,
    json: async () => ({
      name: 'Alice',
      email: 'alice@example.com',
      role: 'admin'
    })
  });

  const { container } = render(<UserProfile userId={1} />);

  await waitFor(() => {
    expect(screen.getByText('Alice')).toBeInTheDocument();
  });

  expect(container).toMatchSnapshot();
});
```

### Performance Testing

#### Request Timing

Measure fetch performance:

```javascript
test('completes within performance budget', async () => {
  fetch.mockResolvedValueOnce({
    ok: true,
    json: async () => ({ data: 'test' })
  });

  const start = performance.now();
  await fetchData();
  const duration = performance.now() - start;

  expect(duration).toBeLessThan(100);
});
```

#### Memory Leak Detection

Test for proper cleanup:

```javascript
test('cleans up pending requests on unmount', async () => {
  let rejectRequest;
  const promise = new Promise((_, reject) => {
    rejectRequest = reject;
  });

  fetch.mockReturnValueOnce(promise);

  const { unmount } = render(<DataComponent />);

  // Unmount before request completes
  unmount();

  // Reject the pending request
  rejectRequest(new Error('Cancelled'));

  // Should not cause warnings or errors
  await new Promise(resolve => setTimeout(resolve, 0));
});
```

### Custom Test Utilities

#### Fetch Mock Helpers

Create reusable testing utilities:

```javascript
// test-utils.js
export const mockFetchSuccess = (data) => {
  fetch.mockResolvedValueOnce({
    ok: true,
    status: 200,
    json: async () => data
  });
};

export const mockFetchError = (status, message) => {
  fetch.mockResolvedValueOnce({
    ok: false,
    status,
    json: async () => ({ error: message })
  });
};

export const mockFetchSequence = (...responses) => {
  responses.forEach(response => {
    if (response.error) {
      fetch.mockRejectedValueOnce(new Error(response.error));
    } else {
      fetch.mockResolvedValueOnce({
        ok: true,
        json: async () => response.data
      });
    }
  });
};

// Usage
test('uses mock helpers', async () => {
  mockFetchSuccess({ id: 1, name: 'Test' });

  const data = await fetchData();
  expect(data.id).toBe(1);
});

test('tests error sequence', async () => {
  mockFetchSequence(
    { error: 'First attempt failed' },
    { error: 'Second attempt failed' },
    { data: { success: true } }
  );

  const result = await fetchWithRetry();
  expect(result.success).toBe(true);
});
```

#### Component Test Wrappers

Create wrapper functions for common test scenarios:

```javascript
// test-utils.js
export const renderWithFetch = (
  Component,
  mockData,
  renderOptions = {}
) => {
  fetch.mockResolvedValueOnce({
    ok: true,
    json: async () => mockData
  });

  return render(Component, renderOptions);
};

export const waitForFetchComplete = async () => {
  await waitFor(() => {
    expect(fetch).toHaveBeenCalled();
  });
  
  // Wait for state updates
  await screen.findByTestId('loaded-content', {}, { timeout: 2000 });
};

// Usage
test('renders with fetched data', async () => {
  renderWithFetch(
    <UserList />,
    { users: [{ id: 1, name: 'Alice' }] }
  );

  await waitForFetchComplete();

  expect(screen.getByText('Alice')).toBeInTheDocument();
});
```

---

