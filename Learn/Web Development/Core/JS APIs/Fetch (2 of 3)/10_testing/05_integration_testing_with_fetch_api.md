## Integration Testing with Fetch API


### Test Environment Setup

Integration tests for fetch require simulating network requests and responses. The standard approach uses mock servers or request interceptors.

**MSW (Mock Service Worker)**:

```javascript
import { setupServer } from 'msw/node';
import { rest } from 'msw';

const server = setupServer(
  rest.get('/api/users', (req, res, ctx) => {
    return res(
      ctx.status(200),
      ctx.json({ users: [{ id: 1, name: 'Alice' }] })
    );
  })
);

beforeAll(() => server.listen());
afterEach(() => server.resetHandlers());
afterAll(() => server.close());
```

**fetch-mock**:

```javascript
import fetchMock from 'fetch-mock';

beforeEach(() => {
  fetchMock.reset();
});

test('fetches user data', async () => {
  fetchMock.get('/api/users', {
    status: 200,
    body: { users: [] }
  });
  
  const response = await fetch('/api/users');
  const data = await response.json();
  
  expect(data.users).toEqual([]);
});
```

### Request Verification

Test that requests contain correct data, headers, and configuration:

```javascript
test('sends authentication header', async () => {
  fetchMock.post('/api/data', 200);
  
  await fetch('/api/data', {
    method: 'POST',
    headers: {
      'Authorization': 'Bearer token123',
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({ value: 42 })
  });
  
  const [url, options] = fetchMock.lastCall();
  expect(options.headers['Authorization']).toBe('Bearer token123');
  expect(JSON.parse(options.body)).toEqual({ value: 42 });
});
```

### Response Handling Tests

Verify correct processing of various response types and statuses:

```javascript
describe('response handling', () => {
  test('processes JSON responses', async () => {
    server.use(
      rest.get('/api/data', (req, res, ctx) => {
        return res(ctx.json({ message: 'success' }));
      })
    );
    
    const response = await fetch('/api/data');
    const data = await response.json();
    
    expect(data.message).toBe('success');
  });
  
  test('handles text responses', async () => {
    server.use(
      rest.get('/api/text', (req, res, ctx) => {
        return res(ctx.text('plain text content'));
      })
    );
    
    const response = await fetch('/api/text');
    const text = await response.text();
    
    expect(text).toBe('plain text content');
  });
  
  test('processes blob responses', async () => {
    const imageBuffer = new ArrayBuffer(8);
    
    server.use(
      rest.get('/api/image', (req, res, ctx) => {
        return res(
          ctx.set('Content-Type', 'image/png'),
          ctx.body(imageBuffer)
        );
      })
    );
    
    const response = await fetch('/api/image');
    const blob = await response.blob();
    
    expect(blob.type).toBe('image/png');
  });
});
```

### Error Scenario Testing

Test network failures, timeouts, and error responses:

```javascript
test('handles network errors', async () => {
  fetchMock.get('/api/data', {
    throws: new Error('Network error')
  });
  
  await expect(fetch('/api/data')).rejects.toThrow('Network error');
});

test('handles HTTP error statuses', async () => {
  server.use(
    rest.get('/api/resource', (req, res, ctx) => {
      return res(
        ctx.status(404),
        ctx.json({ error: 'Not found' })
      );
    })
  );
  
  const response = await fetch('/api/resource');
  
  expect(response.ok).toBe(false);
  expect(response.status).toBe(404);
  
  const data = await response.json();
  expect(data.error).toBe('Not found');
});

test('handles timeout scenarios', async () => {
  server.use(
    rest.get('/api/slow', (req, res, ctx) => {
      return res(ctx.delay(5000));
    })
  );
  
  const controller = new AbortController();
  setTimeout(() => controller.abort(), 1000);
  
  await expect(
    fetch('/api/slow', { signal: controller.signal })
  ).rejects.toThrow('aborted');
});
```

### Query Parameter Testing

Verify correct URL construction and parameter encoding:

```javascript
test('constructs URLs with query parameters', async () => {
  fetchMock.get('begin:/api/search', 200);
  
  const params = new URLSearchParams({
    q: 'test query',
    filter: 'active',
    page: '2'
  });
  
  await fetch(`/api/search?${params}`);
  
  const calledUrl = fetchMock.lastUrl();
  expect(calledUrl).toContain('q=test+query');
  expect(calledUrl).toContain('filter=active');
  expect(calledUrl).toContain('page=2');
});

test('encodes special characters in parameters', async () => {
  fetchMock.get('begin:/api/search', 200);
  
  const searchTerm = 'test & special <chars>';
  const params = new URLSearchParams({ q: searchTerm });
  
  await fetch(`/api/search?${params}`);
  
  const calledUrl = fetchMock.lastUrl();
  expect(calledUrl).toContain(encodeURIComponent(searchTerm));
});
```

### Header Validation Tests

Test request and response header handling:

```javascript
test('sends custom headers', async () => {
  server.use(
    rest.post('/api/data', (req, res, ctx) => {
      expect(req.headers.get('X-Custom-Header')).toBe('custom-value');
      expect(req.headers.get('Content-Type')).toBe('application/json');
      return res(ctx.json({ received: true }));
    })
  );
  
  await fetch('/api/data', {
    method: 'POST',
    headers: {
      'X-Custom-Header': 'custom-value',
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({ test: true })
  });
});

test('reads response headers', async () => {
  server.use(
    rest.get('/api/data', (req, res, ctx) => {
      return res(
        ctx.set('X-Rate-Limit', '100'),
        ctx.set('X-Rate-Remaining', '95'),
        ctx.json({ data: 'value' })
      );
    })
  );
  
  const response = await fetch('/api/data');
  
  expect(response.headers.get('X-Rate-Limit')).toBe('100');
  expect(response.headers.get('X-Rate-Remaining')).toBe('95');
});
```

### Request Body Validation

Test different body types and serialization:

```javascript
describe('request body handling', () => {
  test('sends JSON body', async () => {
    server.use(
      rest.post('/api/users', async (req, res, ctx) => {
        const body = await req.json();
        expect(body.name).toBe('Alice');
        expect(body.age).toBe(30);
        return res(ctx.json({ id: 1, ...body }));
      })
    );
    
    const response = await fetch('/api/users', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ name: 'Alice', age: 30 })
    });
    
    const data = await response.json();
    expect(data.id).toBe(1);
  });
  
  test('sends FormData', async () => {
    server.use(
      rest.post('/api/upload', async (req, res, ctx) => {
        const formData = await req.formData();
        expect(formData.get('username')).toBe('testuser');
        return res(ctx.json({ success: true }));
      })
    );
    
    const formData = new FormData();
    formData.append('username', 'testuser');
    formData.append('file', new Blob(['content']), 'test.txt');
    
    await fetch('/api/upload', {
      method: 'POST',
      body: formData
    });
  });
  
  test('sends URLSearchParams', async () => {
    server.use(
      rest.post('/api/form', async (req, res, ctx) => {
        const text = await req.text();
        expect(text).toContain('field1=value1');
        expect(text).toContain('field2=value2');
        return res(ctx.json({ received: true }));
      })
    );
    
    const params = new URLSearchParams({
      field1: 'value1',
      field2: 'value2'
    });
    
    await fetch('/api/form', {
      method: 'POST',
      body: params
    });
  });
});
```

### Retry Logic Testing

Test retry mechanisms and exponential backoff:

```javascript
test('retries failed requests', async () => {
  let attemptCount = 0;
  
  server.use(
    rest.get('/api/unstable', (req, res, ctx) => {
      attemptCount++;
      if (attemptCount < 3) {
        return res(ctx.status(503));
      }
      return res(ctx.json({ success: true }));
    })
  );
  
  async function fetchWithRetry(url, maxRetries = 3) {
    for (let i = 0; i < maxRetries; i++) {
      const response = await fetch(url);
      if (response.ok) return response;
      if (i < maxRetries - 1) await new Promise(r => setTimeout(r, 100));
    }
    throw new Error('Max retries exceeded');
  }
  
  const response = await fetchWithRetry('/api/unstable');
  const data = await response.json();
  
  expect(attemptCount).toBe(3);
  expect(data.success).toBe(true);
});
```

### Concurrent Request Testing

Test parallel request handling:

```javascript
test('handles concurrent requests', async () => {
  server.use(
    rest.get('/api/resource/:id', (req, res, ctx) => {
      const { id } = req.params;
      return res(
        ctx.delay(Math.random() * 100),
        ctx.json({ id, data: `Resource ${id}` })
      );
    })
  );
  
  const ids = [1, 2, 3, 4, 5];
  const promises = ids.map(id => 
    fetch(`/api/resource/${id}`).then(r => r.json())
  );
  
  const results = await Promise.all(promises);
  
  expect(results).toHaveLength(5);
  results.forEach((result, index) => {
    expect(result.id).toBe(String(ids[index]));
  });
});

test('limits concurrent requests', async () => {
  let activeRequests = 0;
  let maxConcurrent = 0;
  
  server.use(
    rest.get('/api/item/:id', async (req, res, ctx) => {
      activeRequests++;
      maxConcurrent = Math.max(maxConcurrent, activeRequests);
      await new Promise(resolve => setTimeout(resolve, 50));
      activeRequests--;
      return res(ctx.json({ id: req.params.id }));
    })
  );
  
  async function fetchWithLimit(urls, limit) {
    const results = [];
    const executing = [];
    
    for (const url of urls) {
      const promise = fetch(url).then(r => r.json());
      results.push(promise);
      
      if (limit <= urls.length) {
        const e = promise.then(() => {
          executing.splice(executing.indexOf(e), 1);
        });
        executing.push(e);
        
        if (executing.length >= limit) {
          await Promise.race(executing);
        }
      }
    }
    
    return Promise.all(results);
  }
  
  const urls = Array.from({ length: 10 }, (_, i) => `/api/item/${i}`);
  await fetchWithLimit(urls, 3);
  
  expect(maxConcurrent).toBeLessThanOrEqual(3);
});
```

### Cache Control Testing

Test cache behavior and headers:

```javascript
test('respects cache headers', async () => {
  let callCount = 0;
  
  server.use(
    rest.get('/api/cached', (req, res, ctx) => {
      callCount++;
      return res(
        ctx.set('Cache-Control', 'max-age=3600'),
        ctx.json({ timestamp: Date.now() })
      );
    })
  );
  
  const response1 = await fetch('/api/cached');
  const data1 = await response1.json();
  
  const response2 = await fetch('/api/cached', { cache: 'force-cache' });
  const data2 = await response2.json();
  
  // [Inference]: Actual cache behavior depends on browser/environment
  expect(response1.headers.get('Cache-Control')).toBe('max-age=3600');
});

test('bypasses cache when requested', async () => {
  fetchMock.get('/api/data', { value: 1 });
  
  await fetch('/api/data', { cache: 'no-store' });
  
  const options = fetchMock.lastOptions();
  expect(options.cache).toBe('no-store');
});
```

### Authentication Flow Testing

Test authentication token handling and refresh:

```javascript
describe('authentication flows', () => {
  test('includes auth token in requests', async () => {
    const token = 'test-token-123';
    
    server.use(
      rest.get('/api/protected', (req, res, ctx) => {
        const auth = req.headers.get('Authorization');
        expect(auth).toBe(`Bearer ${token}`);
        return res(ctx.json({ data: 'protected content' }));
      })
    );
    
    await fetch('/api/protected', {
      headers: {
        'Authorization': `Bearer ${token}`
      }
    });
  });
  
  test('handles token refresh flow', async () => {
    let accessToken = 'expired-token';
    const refreshToken = 'refresh-token';
    
    server.use(
      rest.get('/api/data', (req, res, ctx) => {
        const auth = req.headers.get('Authorization');
        if (auth === 'Bearer expired-token') {
          return res(ctx.status(401), ctx.json({ error: 'Token expired' }));
        }
        return res(ctx.json({ data: 'success' }));
      }),
      rest.post('/api/refresh', (req, res, ctx) => {
        return res(ctx.json({ accessToken: 'new-token' }));
      })
    );
    
    async function fetchWithAuth(url) {
      let response = await fetch(url, {
        headers: { 'Authorization': `Bearer ${accessToken}` }
      });
      
      if (response.status === 401) {
        const refreshResponse = await fetch('/api/refresh', {
          method: 'POST',
          headers: { 'Authorization': `Bearer ${refreshToken}` }
        });
        const { accessToken: newToken } = await refreshResponse.json();
        accessToken = newToken;
        
        response = await fetch(url, {
          headers: { 'Authorization': `Bearer ${accessToken}` }
        });
      }
      
      return response;
    }
    
    const response = await fetchWithAuth('/api/data');
    const data = await response.json();
    
    expect(data.data).toBe('success');
    expect(accessToken).toBe('new-token');
  });
});
```

### CORS Testing

Test cross-origin request handling:

```javascript
test('handles CORS preflight', async () => {
  server.use(
    rest.options('/api/data', (req, res, ctx) => {
      return res(
        ctx.set('Access-Control-Allow-Origin', '*'),
        ctx.set('Access-Control-Allow-Methods', 'GET, POST, PUT'),
        ctx.set('Access-Control-Allow-Headers', 'Content-Type, Authorization'),
        ctx.status(204)
      );
    }),
    rest.post('/api/data', (req, res, ctx) => {
      return res(
        ctx.set('Access-Control-Allow-Origin', '*'),
        ctx.json({ success: true })
      );
    })
  );
  
  const response = await fetch('http://localhost:3000/api/data', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer token'
    },
    body: JSON.stringify({ data: 'test' })
  });
  
  expect(response.headers.get('Access-Control-Allow-Origin')).toBe('*');
});
```

### Abort Signal Testing

Test request cancellation:

```javascript
test('cancels request with abort signal', async () => {
  server.use(
    rest.get('/api/slow', (req, res, ctx) => {
      return res(ctx.delay(5000), ctx.json({ data: 'slow' }));
    })
  );
  
  const controller = new AbortController();
  
  const fetchPromise = fetch('/api/slow', {
    signal: controller.signal
  });
  
  setTimeout(() => controller.abort(), 100);
  
  await expect(fetchPromise).rejects.toThrow();
});

test('handles multiple requests with shared abort signal', async () => {
  server.use(
    rest.get('/api/endpoint1', (req, res, ctx) => {
      return res(ctx.delay(1000), ctx.json({ id: 1 }));
    }),
    rest.get('/api/endpoint2', (req, res, ctx) => {
      return res(ctx.delay(1000), ctx.json({ id: 2 }));
    })
  );
  
  const controller = new AbortController();
  
  const promise1 = fetch('/api/endpoint1', { signal: controller.signal });
  const promise2 = fetch('/api/endpoint2', { signal: controller.signal });
  
  setTimeout(() => controller.abort(), 100);
  
  await expect(Promise.all([promise1, promise2])).rejects.toThrow();
});
```

### Stream Processing Testing

Test response stream handling:

```javascript
test('processes response stream', async () => {
  const chunks = ['chunk1', 'chunk2', 'chunk3'];
  let chunkIndex = 0;
  
  server.use(
    rest.get('/api/stream', (req, res, ctx) => {
      const stream = new ReadableStream({
        start(controller) {
          chunks.forEach(chunk => {
            controller.enqueue(new TextEncoder().encode(chunk));
          });
          controller.close();
        }
      });
      
      return res(ctx.body(stream));
    })
  );
  
  const response = await fetch('/api/stream');
  const reader = response.body.getReader();
  const decoder = new TextDecoder();
  const received = [];
  
  while (true) {
    const { done, value } = await reader.read();
    if (done) break;
    received.push(decoder.decode(value));
  }
  
  expect(received).toEqual(chunks);
});
```

### Response Validation Testing

Test response data validation and schema checking:

```javascript
test('validates response schema', async () => {
  server.use(
    rest.get('/api/user', (req, res, ctx) => {
      return res(ctx.json({
        id: 1,
        name: 'Alice',
        email: 'alice@example.com',
        age: 30
      }));
    })
  );
  
  const response = await fetch('/api/user');
  const user = await response.json();
  
  expect(user).toHaveProperty('id');
  expect(user).toHaveProperty('name');
  expect(user).toHaveProperty('email');
  expect(typeof user.id).toBe('number');
  expect(typeof user.name).toBe('string');
  expect(user.email).toMatch(/^[^\s@]+@[^\s@]+\.[^\s@]+$/);
});
```

### Integration with Application State

Test fetch integration with state management:

```javascript
// Redux integration example
test('dispatches actions on fetch success', async () => {
  const mockDispatch = jest.fn();
  
  server.use(
    rest.get('/api/users', (req, res, ctx) => {
      return res(ctx.json({ users: [{ id: 1, name: 'Alice' }] }));
    })
  );
  
  async function fetchUsers(dispatch) {
    dispatch({ type: 'FETCH_USERS_REQUEST' });
    
    try {
      const response = await fetch('/api/users');
      const data = await response.json();
      dispatch({ type: 'FETCH_USERS_SUCCESS', payload: data.users });
    } catch (error) {
      dispatch({ type: 'FETCH_USERS_FAILURE', error: error.message });
    }
  }
  
  await fetchUsers(mockDispatch);
  
  expect(mockDispatch).toHaveBeenCalledWith({ type: 'FETCH_USERS_REQUEST' });
  expect(mockDispatch).toHaveBeenCalledWith({
    type: 'FETCH_USERS_SUCCESS',
    payload: [{ id: 1, name: 'Alice' }]
  });
});
```

### Performance Testing

Test request timing and performance characteristics:

```javascript
test('measures request duration', async () => {
  server.use(
    rest.get('/api/data', (req, res, ctx) => {
      return res(ctx.delay(200), ctx.json({ value: 42 }));
    })
  );
  
  const start = performance.now();
  const response = await fetch('/api/data');
  await response.json();
  const duration = performance.now() - start;
  
  expect(duration).toBeGreaterThan(200);
  expect(duration).toBeLessThan(300);
});
```

---

