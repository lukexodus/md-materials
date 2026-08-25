## Mocking Fetch Requests


### Manual Mock Implementation

Replace global fetch with a custom function:

```javascript
// Store original fetch
const originalFetch = window.fetch;

// Create mock
window.fetch = function(url, options) {
  if (url === '/api/users') {
    return Promise.resolve({
      ok: true,
      status: 200,
      json: async () => ({ users: ['Alice', 'Bob'] }),
      text: async () => JSON.stringify({ users: ['Alice', 'Bob'] }),
      headers: new Headers({
        'content-type': 'application/json'
      })
    });
  }
  
  // Fall back to original for unmocked URLs
  return originalFetch(url, options);
};

// Restore after tests
window.fetch = originalFetch;
```

**Complete Response object mock:**

```javascript
function createMockResponse(body, init = {}) {
  const {
    status = 200,
    statusText = 'OK',
    headers = {},
    url = ''
  } = init;
  
  return {
    ok: status >= 200 && status < 300,
    status,
    statusText,
    url,
    headers: new Headers(headers),
    redirected: false,
    type: 'basic',
    
    // Body methods
    json: async () => JSON.parse(body),
    text: async () => body,
    blob: async () => new Blob([body]),
    arrayBuffer: async () => new TextEncoder().encode(body).buffer,
    formData: async () => {
      const fd = new FormData();
      // Parse body as needed
      return fd;
    },
    
    // Body can only be read once
    bodyUsed: false,
    
    // Clone method
    clone: function() {
      return createMockResponse(body, init);
    }
  };
}

// Usage
window.fetch = async function(url) {
  if (url === '/api/data') {
    return createMockResponse(
      JSON.stringify({ data: 'test' }),
      { status: 200, headers: { 'content-type': 'application/json' } }
    );
  }
};
```

### Spy Pattern

Track fetch calls while optionally passing through:

```javascript
class FetchSpy {
  constructor() {
    this.calls = [];
    this.originalFetch = window.fetch;
    this.mockResponses = new Map();
  }
  
  install() {
    window.fetch = async (url, options) => {
      this.calls.push({ url, options, timestamp: Date.now() });
      
      // Check for mock response
      const mockKey = this.getMockKey(url, options);
      if (this.mockResponses.has(mockKey)) {
        return this.mockResponses.get(mockKey);
      }
      
      // Pass through to real fetch
      return this.originalFetch(url, options);
    };
  }
  
  uninstall() {
    window.fetch = this.originalFetch;
  }
  
  reset() {
    this.calls = [];
    this.mockResponses.clear();
  }
  
  getMockKey(url, options = {}) {
    return `${options.method || 'GET'}:${url}`;
  }
  
  mockResponse(url, response, options = {}) {
    const key = this.getMockKey(url, options);
    this.mockResponses.set(key, response);
  }
  
  getCalls(url) {
    if (!url) return this.calls;
    return this.calls.filter(call => call.url === url);
  }
  
  wasCalledWith(url, options = {}) {
    return this.calls.some(call => {
      if (call.url !== url) return false;
      if (options.method && call.options?.method !== options.method) return false;
      return true;
    });
  }
}

// Usage
const spy = new FetchSpy();
spy.install();

spy.mockResponse('/api/users', createMockResponse(
  JSON.stringify({ users: [] })
));

await fetch('/api/users'); // Uses mock
await fetch('/api/other'); // Passes through

console.log(spy.getCalls()); // All calls
console.log(spy.wasCalledWith('/api/users')); // true

spy.uninstall();
```

### Conditional Mocking

Mock based on request properties:

```javascript
function createConditionalMock() {
  const originalFetch = window.fetch;
  const matchers = [];
  
  window.fetch = async function(url, options = {}) {
    for (const matcher of matchers) {
      if (matcher.condition(url, options)) {
        return matcher.response(url, options);
      }
    }
    return originalFetch(url, options);
  };
  
  return {
    when: (condition) => ({
      thenReturn: (response) => {
        matchers.push({ condition, response });
      }
    }),
    reset: () => {
      window.fetch = originalFetch;
      matchers.length = 0;
    }
  };
}

// Usage
const mock = createConditionalMock();

// Mock all POST requests
mock.when((url, options) => options.method === 'POST')
  .thenReturn(async () => createMockResponse(JSON.stringify({ success: true })));

// Mock specific URL pattern
mock.when((url) => url.includes('/api/users/'))
  .thenReturn(async (url) => {
    const id = url.split('/').pop();
    return createMockResponse(JSON.stringify({ id, name: 'User ' + id }));
  });

// Mock with delay
mock.when((url) => url === '/api/slow')
  .thenReturn(async () => {
    await new Promise(resolve => setTimeout(resolve, 2000));
    return createMockResponse(JSON.stringify({ data: 'delayed' }));
  });
```

### Request Matching

Match requests by various criteria:

```javascript
class RequestMatcher {
  constructor() {
    this.expectations = [];
  }
  
  expect(pattern) {
    const expectation = {
      pattern,
      responses: [],
      calls: [],
      times: null
    };
    this.expectations.push(expectation);
    
    return {
      times: (n) => {
        expectation.times = n;
        return this;
      },
      toReturn: (...responses) => {
        expectation.responses = responses;
        return this;
      },
      toReturnOnce: (response) => {
        expectation.responses = [response];
        expectation.times = 1;
        return this;
      }
    };
  }
  
  match(url, options) {
    for (const exp of this.expectations) {
      if (this.isMatch(url, options, exp.pattern)) {
        exp.calls.push({ url, options, timestamp: Date.now() });
        
        if (exp.times !== null && exp.calls.length > exp.times) {
          throw new Error(`Expected ${exp.times} calls but got ${exp.calls.length}`);
        }
        
        const responseIndex = Math.min(
          exp.calls.length - 1,
          exp.responses.length - 1
        );
        return exp.responses[responseIndex];
      }
    }
    return null;
  }
  
  isMatch(url, options, pattern) {
    if (typeof pattern === 'string') {
      return url === pattern;
    }
    if (pattern instanceof RegExp) {
      return pattern.test(url);
    }
    if (typeof pattern === 'function') {
      return pattern(url, options);
    }
    if (typeof pattern === 'object') {
      return this.matchObject(url, options, pattern);
    }
    return false;
  }
  
  matchObject(url, options, pattern) {
    if (pattern.url) {
      if (typeof pattern.url === 'string' && url !== pattern.url) return false;
      if (pattern.url instanceof RegExp && !pattern.url.test(url)) return false;
    }
    if (pattern.method && options?.method !== pattern.method) return false;
    if (pattern.headers) {
      for (const [key, value] of Object.entries(pattern.headers)) {
        if (options?.headers?.[key] !== value) return false;
      }
    }
    return true;
  }
  
  verify() {
    const failures = [];
    for (const exp of this.expectations) {
      if (exp.times !== null && exp.calls.length !== exp.times) {
        failures.push(
          `Expected ${exp.times} calls to ${JSON.stringify(exp.pattern)} ` +
          `but got ${exp.calls.length}`
        );
      }
    }
    if (failures.length > 0) {
      throw new Error('Mock verification failed:\n' + failures.join('\n'));
    }
  }
}

// Usage
const matcher = new RequestMatcher();

matcher.expect('/api/users')
  .times(2)
  .toReturn(
    createMockResponse(JSON.stringify({ users: ['Alice'] })),
    createMockResponse(JSON.stringify({ users: ['Alice', 'Bob'] }))
  );

matcher.expect({ url: /\/api\/posts\/\d+/, method: 'GET' })
  .toReturn(createMockResponse(JSON.stringify({ post: 'content' })));

// Install mock
const originalFetch = window.fetch;
window.fetch = async (url, options) => {
  const response = matcher.match(url, options);
  if (response) return response;
  return originalFetch(url, options);
};

// After tests
matcher.verify(); // Throws if expectations not met
```

### Network Error Simulation

Mock network failures and errors:

```javascript
function createErrorMock() {
  const mocks = new Map();
  
  const errorTypes = {
    network: () => Promise.reject(new TypeError('Failed to fetch')),
    timeout: () => new Promise((_, reject) => 
      setTimeout(() => reject(new TypeError('Network timeout')), 100)
    ),
    abort: () => Promise.reject(new DOMException('Aborted', 'AbortError')),
    serverError: (status = 500) => Promise.resolve(
      createMockResponse('Internal Server Error', { 
        status, 
        statusText: 'Internal Server Error' 
      })
    ),
    clientError: (status = 400) => Promise.resolve(
      createMockResponse('Bad Request', { 
        status, 
        statusText: 'Bad Request' 
      })
    ),
    malformedJSON: () => Promise.resolve({
      ok: true,
      status: 200,
      json: async () => { throw new SyntaxError('Unexpected token'); },
      text: async () => 'not valid json {',
      headers: new Headers({ 'content-type': 'application/json' })
    })
  };
  
  return {
    mockNetworkError: (url) => {
      mocks.set(url, errorTypes.network);
    },
    mockTimeout: (url) => {
      mocks.set(url, errorTypes.timeout);
    },
    mockAbort: (url) => {
      mocks.set(url, errorTypes.abort);
    },
    mockServerError: (url, status) => {
      mocks.set(url, () => errorTypes.serverError(status));
    },
    mockClientError: (url, status) => {
      mocks.set(url, () => errorTypes.clientError(status));
    },
    mockMalformedJSON: (url) => {
      mocks.set(url, errorTypes.malformedJSON);
    },
    install: () => {
      const original = window.fetch;
      window.fetch = async (url, options) => {
        if (mocks.has(url)) {
          return mocks.get(url)();
        }
        return original(url, options);
      };
      return () => { window.fetch = original; };
    }
  };
}

// Usage
const errorMock = createErrorMock();

errorMock.mockNetworkError('/api/unreachable');
errorMock.mockTimeout('/api/slow');
errorMock.mockServerError('/api/broken', 503);
errorMock.mockMalformedJSON('/api/bad-json');

const restore = errorMock.install();

// Test error handling
try {
  await fetch('/api/unreachable');
} catch (error) {
  console.log(error.message); // 'Failed to fetch'
}

restore();
```

### Streaming Response Mocking

Mock streamed responses:

```javascript
function createStreamMock(chunks, delay = 100) {
  const stream = new ReadableStream({
    async start(controller) {
      for (const chunk of chunks) {
        await new Promise(resolve => setTimeout(resolve, delay));
        controller.enqueue(new TextEncoder().encode(chunk));
      }
      controller.close();
    }
  });
  
  return {
    ok: true,
    status: 200,
    headers: new Headers({ 'content-type': 'text/plain' }),
    body: stream,
    bodyUsed: false
  };
}

// Usage
window.fetch = async function(url) {
  if (url === '/api/stream') {
    return createStreamMock([
      'chunk 1\n',
      'chunk 2\n',
      'chunk 3\n'
    ], 500);
  }
};

// Consume stream
const response = await fetch('/api/stream');
const reader = response.body.getReader();
const decoder = new TextDecoder();

while (true) {
  const { done, value } = await reader.read();
  if (done) break;
  console.log(decoder.decode(value));
}
```

**Server-Sent Events (SSE) mock:**

```javascript
function createSSEMock(events, delay = 1000) {
  const chunks = events.map(event => 
    `data: ${JSON.stringify(event)}\n\n`
  );
  
  return createStreamMock(chunks, delay);
}

// Usage
window.fetch = async function(url) {
  if (url === '/api/events') {
    return createSSEMock([
      { type: 'message', data: 'Hello' },
      { type: 'message', data: 'World' },
      { type: 'close', data: null }
    ]);
  }
};
```

### Testing Framework Integration

#### Jest

```javascript
// Using jest.fn()
global.fetch = jest.fn();

// Mock single response
fetch.mockResolvedValueOnce({
  ok: true,
  json: async () => ({ data: 'test' })
});

// Mock multiple responses
fetch
  .mockResolvedValueOnce({ ok: true, json: async () => ({ page: 1 }) })
  .mockResolvedValueOnce({ ok: true, json: async () => ({ page: 2 }) })
  .mockRejectedValueOnce(new Error('Network error'));

// Verify calls
expect(fetch).toHaveBeenCalledTimes(1);
expect(fetch).toHaveBeenCalledWith('/api/users', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({ name: 'Alice' })
});

// Mock implementation
fetch.mockImplementation(async (url) => {
  if (url.includes('/users/')) {
    const id = url.split('/').pop();
    return {
      ok: true,
      json: async () => ({ id, name: `User ${id}` })
    };
  }
  throw new Error('Not found');
});
```

**Custom matcher:**

```javascript
expect.extend({
  toHaveBeenFetchedWith(received, url, options) {
    const calls = received.mock.calls;
    const match = calls.find(call => {
      const [callUrl, callOptions] = call;
      return callUrl === url && 
        (!options || JSON.stringify(callOptions) === JSON.stringify(options));
    });
    
    return {
      pass: !!match,
      message: () => 
        match
          ? `Expected fetch not to be called with ${url}`
          : `Expected fetch to be called with ${url}, but it wasn't`
    };
  }
});

// Usage
expect(fetch).toHaveBeenFetchedWith('/api/users', { method: 'GET' });
```

#### Vitest

```javascript
import { vi } from 'vitest';

// Mock fetch
global.fetch = vi.fn();

// Mock resolved value
fetch.mockResolvedValue({
  ok: true,
  json: async () => ({ data: 'test' })
});

// Spy on fetch
const fetchSpy = vi.spyOn(global, 'fetch');
fetchSpy.mockResolvedValue({
  ok: true,
  json: async () => ({ data: 'test' })
});

// Restore
fetchSpy.mockRestore();
```

#### Mocha/Chai with Sinon

```javascript
import sinon from 'sinon';

// Stub fetch
const fetchStub = sinon.stub(global, 'fetch');

// Configure stub
fetchStub.withArgs('/api/users').resolves({
  ok: true,
  json: async () => ({ users: [] })
});

fetchStub.withArgs('/api/posts').rejects(new Error('Not found'));

// Verify
sinon.assert.calledOnce(fetchStub);
sinon.assert.calledWith(fetchStub, '/api/users');

// Restore
fetchStub.restore();
```

### Mock Service Worker (MSW)

Setup request handlers:

```javascript
import { setupWorker, rest } from 'msw';

const worker = setupWorker(
  // GET request
  rest.get('/api/users', (req, res, ctx) => {
    return res(
      ctx.status(200),
      ctx.json({ users: ['Alice', 'Bob'] })
    );
  }),
  
  // POST request with body access
  rest.post('/api/users', async (req, res, ctx) => {
    const body = await req.json();
    return res(
      ctx.status(201),
      ctx.json({ id: '123', ...body })
    );
  }),
  
  // Query parameters
  rest.get('/api/search', (req, res, ctx) => {
    const query = req.url.searchParams.get('q');
    return res(
      ctx.json({ results: [`Result for ${query}`] })
    );
  }),
  
  // Headers
  rest.get('/api/protected', (req, res, ctx) => {
    const auth = req.headers.get('Authorization');
    if (!auth) {
      return res(ctx.status(401));
    }
    return res(ctx.json({ data: 'protected' }));
  }),
  
  // Delay response
  rest.get('/api/slow', (req, res, ctx) => {
    return res(
      ctx.delay(2000),
      ctx.json({ data: 'delayed' })
    );
  }),
  
  // Network error
  rest.get('/api/error', (req, res) => {
    return res.networkError('Failed to connect');
  })
);

// Start worker
worker.start();

// Stop worker
worker.stop();
```

**Request matching patterns:**

```javascript
// Exact path
rest.get('/api/users', handler);

// Path parameters
rest.get('/api/users/:id', (req, res, ctx) => {
  const { id } = req.params;
  return res(ctx.json({ id, name: 'User' }));
});

// Wildcard
rest.get('/api/*', handler);

// RegExp
rest.get(/\/api\/posts\/\d+/, handler);

// Multiple methods
rest.all('/api/resource', handler);
```

**Context utilities:**

```javascript
rest.get('/api/data', (req, res, ctx) => {
  return res(
    ctx.status(200),
    ctx.set('X-Custom-Header', 'value'),
    ctx.cookie('session', 'abc123'),
    ctx.delay(100),
    ctx.json({ data: 'test' })
  );
});
```

**One-time override:**

```javascript
// Temporary handler for single request
worker.use(
  rest.get('/api/users', (req, res, ctx) => {
    return res.once(
      ctx.json({ users: ['Override'] })
    );
  })
);
```

**Runtime handlers:**

```javascript
// Add handler at runtime
worker.use(
  rest.post('/api/dynamic', (req, res, ctx) => {
    return res(ctx.json({ dynamic: true }));
  })
);

// Reset to original handlers
worker.resetHandlers();

// Replace all handlers
worker.resetHandlers(
  rest.get('/api/new', (req, res, ctx) => {
    return res(ctx.json({ replaced: true }));
  })
);
```

### Node.js Environment Mocking

Mock in Node.js tests where global fetch may not exist:

```javascript
// Using node-fetch or undici
import fetch from 'node-fetch';

// Mock with jest
jest.mock('node-fetch');
const { Response } = jest.requireActual('node-fetch');

fetch.mockResolvedValue(
  new Response(JSON.stringify({ data: 'test' }), {
    status: 200,
    headers: { 'Content-Type': 'application/json' }
  })
);
```

**Polyfill for testing:**

```javascript
// Make fetch available globally in Node
import fetch from 'node-fetch';
global.fetch = fetch;

// Now your code can use fetch
const response = await fetch('/api/data');
```

**Using MSW in Node:**

```javascript
import { setupServer } from 'msw/node';
import { rest } from 'msw';

const server = setupServer(
  rest.get('/api/users', (req, res, ctx) => {
    return res(ctx.json({ users: [] }));
  })
);

// Enable before tests
beforeAll(() => server.listen());

// Reset handlers after each test
afterEach(() => server.resetHandlers());

// Cleanup after tests
afterAll(() => server.close());
```

### Interceptor Libraries

#### fetch-mock

```javascript
import fetchMock from 'fetch-mock';

// Mock specific URL
fetchMock.get('/api/users', { users: ['Alice'] });

// Mock with matcher function
fetchMock.get((url) => url.includes('/api/'), { data: 'matched' });

// Mock with delay
fetchMock.get('/api/slow', { data: 'test' }, { delay: 1000 });

// Mock POST with body matching
fetchMock.post('/api/users', 
  { success: true },
  { body: { name: 'Alice' } }
);

// Spy mode (pass through + log)
fetchMock.spy();

// Restore
fetchMock.restore();

// Get call history
console.log(fetchMock.calls('/api/users'));
console.log(fetchMock.lastCall('/api/users'));
```

**Advanced matching:**

```javascript
// Match by headers
fetchMock.get('/api/data', { data: 'test' }, {
  headers: { 'Authorization': 'Bearer token' }
});

// Match by query string
fetchMock.get('express:/api/search?query=:term', 
  (url, opts) => ({ results: [url.query.term] })
);

// Conditional response
fetchMock.get('/api/data', (url, opts) => {
  if (opts.headers.Auth) {
    return { status: 200, body: { data: 'authorized' } };
  }
  return { status: 401 };
});

// Multiple responses
fetchMock
  .getOnce('/api/data', { page: 1 })
  .getOnce('/api/data', { page: 2 })
  .get('/api/data', { page: 3 }); // All subsequent calls
```

#### nock (for Node.js)

```javascript
import nock from 'nock';

// Intercept HTTP requests
const scope = nock('https://api.example.com')
  .get('/users')
  .reply(200, { users: ['Alice'] });

// Multiple requests
nock('https://api.example.com')
  .get('/users/1')
  .reply(200, { id: 1, name: 'Alice' })
  .get('/users/2')
  .reply(200, { id: 2, name: 'Bob' });

// Request body matching
nock('https://api.example.com')
  .post('/users', { name: 'Charlie' })
  .reply(201, { id: 3, name: 'Charlie' });

// Delay
nock('https://api.example.com')
  .get('/slow')
  .delay(2000)
  .reply(200, { data: 'slow' });

// Network error
nock('https://api.example.com')
  .get('/error')
  .replyWithError('Network failure');

// Clean up
nock.cleanAll();
```

### Isolating Fetch in Code

Dependency injection pattern:

```javascript
// Instead of direct fetch usage
async function getUsers() {
  const response = await fetch('/api/users');
  return response.json();
}

// Inject fetch dependency
async function getUsers(fetcher = fetch) {
  const response = await fetcher('/api/users');
  return response.json();
}

// Test with mock
const mockFetch = async () => ({
  ok: true,
  json: async () => ({ users: ['Alice'] })
});

const users = await getUsers(mockFetch);
```

**Factory pattern:**

```javascript
function createAPIClient(fetcher = fetch) {
  return {
    async getUsers() {
      const response = await fetcher('/api/users');
      return response.json();
    },
    async createUser(data) {
      const response = await fetcher('/api/users', {
        method: 'POST',
        body: JSON.stringify(data)
      });
      return response.json();
    }
  };
}

// Production
const api = createAPIClient();

// Testing
const mockFetcher = jest.fn().mockResolvedValue({
  ok: true,
  json: async () => ({ success: true })
});
const testAPI = createAPIClient(mockFetcher);
```

### Assertion Helpers

Create reusable assertions:

```javascript
function assertFetchCall(fetchMock, index, expected) {
  const call = fetchMock.mock.calls[index];
  if (!call) {
    throw new Error(`No fetch call at index ${index}`);
  }
  
  const [url, options] = call;
  
  if (expected.url && url !== expected.url) {
    throw new Error(`Expected URL ${expected.url} but got ${url}`);
  }
  
  if (expected.method) {
    const method = options?.method || 'GET';
    if (method !== expected.method) {
      throw new Error(`Expected method ${expected.method} but got ${method}`);
    }
  }
  
  if (expected.body) {
    const body = options?.body;
    const expectedBody = JSON.stringify(expected.body);
    if (body !== expectedBody) {
      throw new Error(`Expected body ${expectedBody} but got ${body}`);
    }
  }
  
  if (expected.headers) {
    for (const [key, value] of Object.entries(expected.headers)) {
      const actualValue = options?.headers?.[key];
      if (actualValue !== value) {
        throw new Error(
          `Expected header ${key}: ${value} but got ${actualValue}`
        );
      }
    }
  }
}

// Usage
assertFetchCall(fetch, 0, {
  url: '/api/users',
  method: 'POST',
  body: { name: 'Alice' },
  headers: { 'Content-Type': 'application/json' }
});
```

**Async assertion helper:**

```javascript
async function waitForFetch(fetchMock, url, timeout = 5000) {
  const start = Date.now();
  
  while (Date.now() - start < timeout) {
    const calls = fetchMock.mock.calls;
    if (calls.some(call => call[0] === url)) {
      return true;
    }
    await new Promise(resolve => setTimeout(resolve, 50));
  }
  
  throw new Error(`Fetch to ${url} was not called within ${timeout}ms`);
}

// Usage in tests
await waitForFetch(fetch, '/api/users');
expect(fetch).toHaveBeenCalledWith('/api/users');
```

### Best Practices

**Reset between tests:**

```javascript
beforeEach(() => {
  // Clear mock calls and responses
  jest.clearAllMocks();
  
  // Or reset completely
  jest.resetAllMocks();
  
  // Restore original implementation
  jest.restoreAllMocks();
});
```

**Avoid over-mocking:**

```javascript
// Bad: Mock too granularly
fetch.mockImplementation((url) => {
  if (url === '/api/users/1') return { json: () => ({ id: 1 }) };
  if (url === '/api/users/2') return { json: () => ({ id: 2 }) };
  // ... dozens more
});

// Better: Use patterns or real API in integration tests
fetch.mockImplementation((url) => {
  const match = url.match(/\/api\/users\/(\d+)/);
  if (match) {
    return { 
      ok: true,
      json: async () => ({ id: match[1] }) 
    };
  }
});
```

**Mock at the right level:**

```javascript
// Unit test: Mock fetch
test('getUsers calls fetch', async () => {
  fetch.mockResolvedValue({ json: async () => ({ users: [] }) });
  await getUsers();
  expect(fetch).toHaveBeenCalledWith('/api/users');
});

// Integration test: Use MSW or real backend
test('user flow', async () => {
  // MSW intercepts at network level
  // Tests entire request/response cycle
});
```

**Type safety with TypeScript:**

```typescript
import { rest } from 'msw';

interface User {
  id: string;
  name: string;
}

rest.get<never, never, User[]>('/api/users', (req, res, ctx) => {
  return res(
    ctx.json([
      { id: '1', name: 'Alice' },
      { id: '2', name: 'Bob' }
    ])
  );
});
```

---

