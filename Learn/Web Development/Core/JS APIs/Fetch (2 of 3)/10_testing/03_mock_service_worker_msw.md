## Mock Service Worker (MSW)


### Architecture

MSW intercepts network requests at the network level using Service Workers in browsers and native Node.js modules in Node environments. This approach allows mocking without modifying application code or HTTP clients.

**Browser**: Requests are intercepted by a Service Worker registered by MSW, which matches them against defined handlers and returns mock responses.

**Node.js**: MSW patches native HTTP/HTTPS modules to intercept requests before they reach the network layer.

### Installation and Setup

#### Installation

```bash
npm install msw --save-dev
# or
yarn add msw --dev
# or
pnpm add -D msw
```

#### Browser Setup

```bash
# Generate service worker file in public directory
npx msw init public/ --save
```

This creates `mockServiceWorker.js` in your public directory and adds it to `.gitignore`.

#### Basic Configuration

```javascript
// src/mocks/handlers.js
import { http, HttpResponse } from 'msw';

export const handlers = [
  http.get('/api/user', () => {
    return HttpResponse.json({
      id: 1,
      name: 'John Doe',
      email: 'john@example.com'
    });
  }),
  
  http.post('/api/login', async ({ request }) => {
    const { username, password } = await request.json();
    
    if (username === 'admin' && password === 'password') {
      return HttpResponse.json({
        token: 'mock-jwt-token',
        user: { username: 'admin' }
      });
    }
    
    return HttpResponse.json(
      { error: 'Invalid credentials' },
      { status: 401 }
    );
  })
];
```

```javascript
// src/mocks/browser.js
import { setupWorker } from 'msw/browser';
import { handlers } from './handlers';

export const worker = setupWorker(...handlers);
```

```javascript
// src/main.jsx (or entry point)
import React from 'react';
import ReactDOM from 'react-dom/client';
import App from './App';

async function enableMocking() {
  if (process.env.NODE_ENV !== 'development') {
    return;
  }
  
  const { worker } = await import('./mocks/browser');
  return worker.start();
}

enableMocking().then(() => {
  ReactDOM.createRoot(document.getElementById('root')).render(
    <React.StrictMode>
      <App />
    </React.StrictMode>
  );
});
```

#### Node.js Setup

```javascript
// src/mocks/node.js
import { setupServer } from 'msw/node';
import { handlers } from './handlers';

export const server = setupServer(...handlers);
```

```javascript
// tests/setup.js
import { beforeAll, afterEach, afterAll } from 'vitest';
import { server } from '../src/mocks/node';

beforeAll(() => server.listen());
afterEach(() => server.resetHandlers());
afterAll(() => server.close());
```

### Request Handlers

#### HTTP Methods

```javascript
import { http, HttpResponse } from 'msw';

export const handlers = [
  // GET request
  http.get('/api/products', () => {
    return HttpResponse.json([
      { id: 1, name: 'Product 1' },
      { id: 2, name: 'Product 2' }
    ]);
  }),
  
  // POST request
  http.post('/api/products', async ({ request }) => {
    const product = await request.json();
    return HttpResponse.json(
      { ...product, id: Date.now() },
      { status: 201 }
    );
  }),
  
  // PUT request
  http.put('/api/products/:id', async ({ params, request }) => {
    const { id } = params;
    const updates = await request.json();
    return HttpResponse.json({ id, ...updates });
  }),
  
  // PATCH request
  http.patch('/api/products/:id', async ({ params, request }) => {
    const { id } = params;
    const updates = await request.json();
    return HttpResponse.json({ id, ...updates });
  }),
  
  // DELETE request
  http.delete('/api/products/:id', ({ params }) => {
    return new HttpResponse(null, { status: 204 });
  }),
  
  // HEAD request
  http.head('/api/health', () => {
    return new HttpResponse(null, {
      status: 200,
      headers: {
        'X-Service-Status': 'healthy'
      }
    });
  }),
  
  // OPTIONS request
  http.options('/api/*', () => {
    return new HttpResponse(null, {
      status: 200,
      headers: {
        'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE',
        'Access-Control-Allow-Headers': 'Content-Type, Authorization'
      }
    });
  })
];
```

#### Path Parameters

```javascript
http.get('/api/users/:userId', ({ params }) => {
  const { userId } = params;
  
  return HttpResponse.json({
    id: userId,
    name: `User ${userId}`
  });
}),

http.get('/api/users/:userId/posts/:postId', ({ params }) => {
  const { userId, postId } = params;
  
  return HttpResponse.json({
    id: postId,
    userId: userId,
    title: 'Post title'
  });
}),

// Wildcard matching
http.get('/api/files/*', ({ params }) => {
  const filepath = params[0]; // captures everything after /files/
  
  return HttpResponse.json({
    path: filepath
  });
})
```

#### Query Parameters

```javascript
http.get('/api/search', ({ request }) => {
  const url = new URL(request.url);
  const query = url.searchParams.get('q');
  const page = url.searchParams.get('page') || '1';
  const limit = url.searchParams.get('limit') || '10';
  
  return HttpResponse.json({
    query,
    page: parseInt(page),
    limit: parseInt(limit),
    results: []
  });
}),

// Multiple values for same parameter
http.get('/api/products', ({ request }) => {
  const url = new URL(request.url);
  const categories = url.searchParams.getAll('category');
  
  return HttpResponse.json({
    categories,
    products: []
  });
})
```

#### Request Headers

```javascript
http.get('/api/protected', ({ request }) => {
  const authHeader = request.headers.get('Authorization');
  
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return HttpResponse.json(
      { error: 'Unauthorized' },
      { status: 401 }
    );
  }
  
  const token = authHeader.substring(7);
  
  // Validate token logic here
  
  return HttpResponse.json({ data: 'protected content' });
}),

http.post('/api/data', ({ request }) => {
  const contentType = request.headers.get('Content-Type');
  
  if (contentType !== 'application/json') {
    return HttpResponse.json(
      { error: 'Content-Type must be application/json' },
      { status: 415 }
    );
  }
  
  return HttpResponse.json({ success: true });
})
```

#### Request Body

```javascript
// JSON body
http.post('/api/users', async ({ request }) => {
  const user = await request.json();
  
  return HttpResponse.json({
    id: Date.now(),
    ...user,
    createdAt: new Date().toISOString()
  });
}),

// Text body
http.post('/api/logs', async ({ request }) => {
  const logMessage = await request.text();
  
  console.log('Log received:', logMessage);
  
  return new HttpResponse(null, { status: 204 });
}),

// FormData
http.post('/api/upload', async ({ request }) => {
  const formData = await request.formData();
  const file = formData.get('file');
  const description = formData.get('description');
  
  return HttpResponse.json({
    filename: file.name,
    size: file.size,
    description
  });
}),

// ArrayBuffer
http.post('/api/binary', async ({ request }) => {
  const buffer = await request.arrayBuffer();
  
  return HttpResponse.json({
    byteLength: buffer.byteLength
  });
})
```

#### Request Cookies

```javascript
http.get('/api/profile', ({ cookies }) => {
  const sessionId = cookies.sessionId;
  
  if (!sessionId) {
    return HttpResponse.json(
      { error: 'No session' },
      { status: 401 }
    );
  }
  
  return HttpResponse.json({
    user: 'John Doe',
    sessionId
  });
})
```

### Response Types

#### JSON Response

```javascript
http.get('/api/data', () => {
  return HttpResponse.json(
    { message: 'Success' },
    {
      status: 200,
      headers: {
        'X-Custom-Header': 'value'
      }
    }
  );
})
```

#### Text Response

```javascript
http.get('/api/text', () => {
  return HttpResponse.text('Plain text response');
}),

http.get('/api/html', () => {
  return HttpResponse.html('<h1>Hello World</h1>');
}),

http.get('/api/xml', () => {
  return HttpResponse.xml('<?xml version="1.0"?><root></root>');
})
```

#### Binary Response

```javascript
http.get('/api/image', () => {
  const buffer = new ArrayBuffer(8);
  
  return HttpResponse.arrayBuffer(buffer, {
    headers: {
      'Content-Type': 'image/png'
    }
  });
}),

http.get('/api/download', () => {
  const blob = new Blob(['file content'], { type: 'text/plain' });
  
  return new HttpResponse(blob, {
    headers: {
      'Content-Disposition': 'attachment; filename="file.txt"'
    }
  });
})
```

#### Streaming Response

```javascript
http.get('/api/stream', () => {
  const stream = new ReadableStream({
    start(controller) {
      controller.enqueue('chunk 1\n');
      
      setTimeout(() => {
        controller.enqueue('chunk 2\n');
      }, 1000);
      
      setTimeout(() => {
        controller.enqueue('chunk 3\n');
        controller.close();
      }, 2000);
    }
  });
  
  return new HttpResponse(stream, {
    headers: {
      'Content-Type': 'text/plain',
      'Transfer-Encoding': 'chunked'
    }
  });
})
```

#### Empty Response

```javascript
http.delete('/api/resource/:id', () => {
  return new HttpResponse(null, { status: 204 });
})
```

### Response Modifiers

#### Status Codes

```javascript
http.post('/api/create', () => {
  return HttpResponse.json(
    { id: 1, created: true },
    { status: 201 }
  );
}),

http.get('/api/not-found', () => {
  return HttpResponse.json(
    { error: 'Not found' },
    { status: 404 }
  );
}),

http.post('/api/error', () => {
  return HttpResponse.json(
    { error: 'Internal server error' },
    { status: 500 }
  );
})
```

#### Headers

```javascript
http.get('/api/data', () => {
  return HttpResponse.json(
    { data: 'value' },
    {
      headers: {
        'Cache-Control': 'no-cache',
        'X-RateLimit-Remaining': '99',
        'X-Request-ID': crypto.randomUUID()
      }
    }
  );
})
```

#### Cookies

```javascript
http.post('/api/login', () => {
  return HttpResponse.json(
    { success: true },
    {
      headers: {
        'Set-Cookie': 'sessionId=abc123; HttpOnly; Secure; SameSite=Strict'
      }
    }
  );
}),

// Multiple cookies
http.post('/api/auth', () => {
  return HttpResponse.json(
    { success: true },
    {
      headers: [
        ['Set-Cookie', 'sessionId=abc123; HttpOnly'],
        ['Set-Cookie', 'userId=user123; Path=/']
      ]
    }
  );
})
```

### Delays and Network Conditions

#### Response Delay

```javascript
import { http, HttpResponse, delay } from 'msw';

http.get('/api/slow', async () => {
  await delay(2000); // 2 second delay
  
  return HttpResponse.json({ message: 'Slow response' });
}),

// Random delay
http.get('/api/variable', async () => {
  await delay(Math.random() * 1000); // 0-1 second
  
  return HttpResponse.json({ data: 'value' });
}),

// Realistic network delay
http.get('/api/realistic', async () => {
  await delay('real'); // Simulates realistic network delay
  
  return HttpResponse.json({ data: 'value' });
})
```

#### Network Errors

```javascript
http.get('/api/network-error', () => {
  return HttpResponse.error();
}),

http.get('/api/timeout', async () => {
  await delay(30000); // Simulate timeout
  return HttpResponse.json({ data: 'too late' });
})
```

### Conditional Responses

#### Based on Request Data

```javascript
http.get('/api/users/:id', ({ params }) => {
  const { id } = params;
  
  if (id === '404') {
    return HttpResponse.json(
      { error: 'User not found' },
      { status: 404 }
    );
  }
  
  return HttpResponse.json({
    id,
    name: `User ${id}`
  });
}),

http.post('/api/validate', async ({ request }) => {
  const { email } = await request.json();
  
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  
  if (!emailRegex.test(email)) {
    return HttpResponse.json(
      { error: 'Invalid email format' },
      { status: 400 }
    );
  }
  
  return HttpResponse.json({ valid: true });
})
```

#### Based on Headers

```javascript
http.get('/api/content', ({ request }) => {
  const acceptLanguage = request.headers.get('Accept-Language');
  
  if (acceptLanguage?.includes('es')) {
    return HttpResponse.json({ message: 'Hola' });
  }
  
  return HttpResponse.json({ message: 'Hello' });
}),

http.get('/api/versioned', ({ request }) => {
  const apiVersion = request.headers.get('X-API-Version');
  
  if (apiVersion === '2') {
    return HttpResponse.json({ version: 2, data: [] });
  }
  
  return HttpResponse.json({ version: 1, items: [] });
})
```

#### Based on Environment

```javascript
http.get('/api/config', () => {
  const isProduction = process.env.NODE_ENV === 'production';
  
  return HttpResponse.json({
    debug: !isProduction,
    apiUrl: isProduction ? 'https://api.prod.com' : 'http://localhost:3000'
  });
})
```

### Stateful Handlers

#### In-Memory Database

```javascript
// Mock database
const db = {
  users: [
    { id: 1, name: 'Alice', email: 'alice@example.com' },
    { id: 2, name: 'Bob', email: 'bob@example.com' }
  ],
  nextId: 3
};

export const handlers = [
  http.get('/api/users', () => {
    return HttpResponse.json(db.users);
  }),
  
  http.get('/api/users/:id', ({ params }) => {
    const user = db.users.find(u => u.id === parseInt(params.id));
    
    if (!user) {
      return HttpResponse.json(
        { error: 'User not found' },
        { status: 404 }
      );
    }
    
    return HttpResponse.json(user);
  }),
  
  http.post('/api/users', async ({ request }) => {
    const newUser = await request.json();
    const user = {
      id: db.nextId++,
      ...newUser
    };
    
    db.users.push(user);
    
    return HttpResponse.json(user, { status: 201 });
  }),
  
  http.put('/api/users/:id', async ({ params, request }) => {
    const id = parseInt(params.id);
    const updates = await request.json();
    const index = db.users.findIndex(u => u.id === id);
    
    if (index === -1) {
      return HttpResponse.json(
        { error: 'User not found' },
        { status: 404 }
      );
    }
    
    db.users[index] = { ...db.users[index], ...updates };
    
    return HttpResponse.json(db.users[index]);
  }),
  
  http.delete('/api/users/:id', ({ params }) => {
    const id = parseInt(params.id);
    const index = db.users.findIndex(u => u.id === id);
    
    if (index === -1) {
      return HttpResponse.json(
        { error: 'User not found' },
        { status: 404 }
      );
    }
    
    db.users.splice(index, 1);
    
    return new HttpResponse(null, { status: 204 });
  })
];
```

#### Session Management

```javascript
const sessions = new Map();

http.post('/api/login', async ({ request }) => {
  const { username, password } = await request.json();
  
  if (username === 'admin' && password === 'password') {
    const sessionId = crypto.randomUUID();
    
    sessions.set(sessionId, {
      username,
      createdAt: Date.now()
    });
    
    return HttpResponse.json(
      { success: true },
      {
        headers: {
          'Set-Cookie': `sessionId=${sessionId}; HttpOnly; Path=/`
        }
      }
    );
  }
  
  return HttpResponse.json(
    { error: 'Invalid credentials' },
    { status: 401 }
  );
}),

http.get('/api/profile', ({ cookies }) => {
  const sessionId = cookies.sessionId;
  const session = sessions.get(sessionId);
  
  if (!session) {
    return HttpResponse.json(
      { error: 'Unauthorized' },
      { status: 401 }
    );
  }
  
  return HttpResponse.json({
    username: session.username
  });
}),

http.post('/api/logout', ({ cookies }) => {
  const sessionId = cookies.sessionId;
  sessions.delete(sessionId);
  
  return HttpResponse.json(
    { success: true },
    {
      headers: {
        'Set-Cookie': 'sessionId=; Max-Age=0; Path=/'
      }
    }
  );
})
```

### Runtime Handler Manipulation

#### Adding Handlers

```javascript
import { worker } from './mocks/browser';
import { http, HttpResponse } from 'msw';

// Add handler at runtime
worker.use(
  http.get('/api/new-endpoint', () => {
    return HttpResponse.json({ message: 'New endpoint' });
  })
);
```

#### Overriding Handlers

```javascript
// Override existing handler
worker.use(
  http.get('/api/users', () => {
    return HttpResponse.json(
      { error: 'Service unavailable' },
      { status: 503 }
    );
  })
);
```

#### Resetting Handlers

```javascript
// Reset to original handlers
worker.resetHandlers();

// Reset with new handlers
worker.resetHandlers(
  http.get('/api/users', () => {
    return HttpResponse.json([]);
  })
);
```

#### One-Time Handlers

```javascript
worker.use(
  http.get('/api/special', () => {
    return HttpResponse.json({ special: true });
  }, { once: true })
);

// After first call, this handler is removed
```

### Testing Patterns

#### Basic Test Setup

```javascript
import { describe, it, expect, beforeAll, afterEach, afterAll } from 'vitest';
import { server } from '../mocks/node';
import { http, HttpResponse } from 'msw';

describe('API Tests', () => {
  beforeAll(() => server.listen());
  afterEach(() => server.resetHandlers());
  afterAll(() => server.close());
  
  it('fetches user data', async () => {
    const response = await fetch('/api/user');
    const data = await response.json();
    
    expect(data).toEqual({
      id: 1,
      name: 'John Doe',
      email: 'john@example.com'
    });
  });
  
  it('handles authentication failure', async () => {
    server.use(
      http.post('/api/login', () => {
        return HttpResponse.json(
          { error: 'Invalid credentials' },
          { status: 401 }
        );
      })
    );
    
    const response = await fetch('/api/login', {
      method: 'POST',
      body: JSON.stringify({ username: 'wrong', password: 'wrong' })
    });
    
    expect(response.status).toBe(401);
  });
});
```

#### Testing Error States

```javascript
it('handles network errors', async () => {
  server.use(
    http.get('/api/data', () => {
      return HttpResponse.error();
    })
  );
  
  await expect(fetch('/api/data')).rejects.toThrow();
});

it('handles timeout', async () => {
  server.use(
    http.get('/api/slow', async () => {
      await delay(10000);
      return HttpResponse.json({ data: 'too slow' });
    })
  );
  
  const controller = new AbortController();
  setTimeout(() => controller.abort(), 1000);
  
  await expect(
    fetch('/api/slow', { signal: controller.signal })
  ).rejects.toThrow('aborted');
});
```

#### Testing with React Testing Library

```javascript
import { render, screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { server } from '../mocks/node';
import { http, HttpResponse } from 'msw';
import UserProfile from './UserProfile';

describe('UserProfile', () => {
  it('displays user data', async () => {
    render(<UserProfile userId={1} />);
    
    await waitFor(() => {
      expect(screen.getByText('John Doe')).toBeInTheDocument();
    });
  });
  
  it('displays error message on failure', async () => {
    server.use(
      http.get('/api/users/:id', () => {
        return HttpResponse.json(
          { error: 'User not found' },
          { status: 404 }
        );
      })
    );
    
    render(<UserProfile userId={999} />);
    
    await waitFor(() => {
      expect(screen.getByText(/not found/i)).toBeInTheDocument();
    });
  });
});
```

#### Asserting Request Details

```javascript
it('sends correct request body', async () => {
  let receivedData = null;
  
  server.use(
    http.post('/api/users', async ({ request }) => {
      receivedData = await request.json();
      return HttpResponse.json({ success: true });
    })
  );
  
  await fetch('/api/users', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ name: 'Test User' })
  });
  
  expect(receivedData).toEqual({ name: 'Test User' });
});

it('sends authorization header', async () => {
  let authHeader = null;
  
  server.use(
    http.get('/api/protected', ({ request }) => {
      authHeader = request.headers.get('Authorization');
      return HttpResponse.json({ data: 'protected' });
    })
  );
  
  await fetch('/api/protected', {
    headers: { 'Authorization': 'Bearer token123' }
  });
  
  expect(authHeader).toBe('Bearer token123');
});
```

### GraphQL Support

#### Basic GraphQL Handler

```javascript
import { graphql, HttpResponse } from 'msw';

export const handlers = [
  graphql.query('GetUser', ({ query, variables }) => {
    return HttpResponse.json({
      data: {
        user: {
          id: variables.id,
          name: 'John Doe',
          email: 'john@example.com'
        }
      }
    });
  }),
  
  graphql.mutation('CreateUser', ({ query, variables }) => {
    return HttpResponse.json({
      data: {
        createUser: {
          id: Date.now(),
          name: variables.name,
          email: variables.email
        }
      }
    });
  })
];
```

#### GraphQL with Multiple Operations

```javascript
graphql.query('GetUserAndPosts', ({ variables }) => {
  return HttpResponse.json({
    data: {
      user: {
        id: variables.userId,
        name: 'John Doe',
        posts: [
          { id: 1, title: 'First Post' },
          { id: 2, title: 'Second Post' }
        ]
      }
    }
  });
}),

graphql.mutation('UpdateUser', ({ variables }) => {
  return HttpResponse.json({
    data: {
      updateUser: {
        id: variables.id,
        ...variables.input
      }
    }
  });
})
```

#### GraphQL Error Responses

```javascript
graphql.query('GetUser', ({ variables }) => {
  if (variables.id === '404') {
    return HttpResponse.json({
      errors: [
        {
          message: 'User not found',
          extensions: {
            code: 'USER_NOT_FOUND'
          }
        }
      ]
    });
  }
  
  return HttpResponse.json({
    data: {
      user: { id: variables.id, name: 'User' }
    }
  });
})
```

### Advanced Patterns

#### Request Interception Logging

```javascript
import { http, HttpResponse, passthrough } from 'msw';

http.get('/api/*', ({ request }) => {
  console.log('Request intercepted:', {
    method: request.method,
    url: request.url,
    headers: Object.fromEntries(request.headers.entries())
  });
  
  return passthrough(); // Let request go through to real server
})
```

#### Passthrough for Specific URLs

```javascript
http.get('/api/external/*', () => {
  return passthrough();
}),

// Conditional passthrough
http.get('/api/users/:id', ({ params }) => {
  if (params.id === 'real') {
    return passthrough();
  }
  
  return HttpResponse.json({ id: params.id, mocked: true });
})
```

#### Request Timing Analysis

```javascript
http.get('/api/analytics', async ({ request }) => {
  const startTime = Date.now();
  
  // Simulate processing
  await delay(100);
  
  const duration = Date.now() - startTime;
  
  return HttpResponse.json(
    { data: 'result' },
    {
      headers: {
        'X-Response-Time': `${duration}ms`
      }
    }
  );
})
```

#### Rate Limiting Simulation

```javascript
const requestCounts = new Map();

http.get('/api/limited', ({ request }) => {
  const clientId = request.headers.get('X-Client-ID') || 'anonymous';
  const count = requestCounts.get(clientId) || 0;
  
  if (count >= 10) {
    return HttpResponse.json(
      { error: 'Rate limit exceeded' },
      {
        status: 429,
        headers: {
          'X-RateLimit-Remaining': '0',
          'Retry-After': '60'
        }
      }
    );
  }
  
  requestCounts.set(clientId, count + 1);
  
  // Reset after 60 seconds
  setTimeout(() => {
    requestCounts.delete(clientId);
  }, 60000);
  
  return HttpResponse.json(
    { data: 'success' },
    {
      headers: {
        'X-RateLimit-Remaining': String(10 - count - 1)
      }
    }
  );
})
```

#### Pagination Support

```javascript
const allItems = Array.from({ length: 100 }, (_, i) => ({
  id: i + 1,
  name: `Item ${i + 1}`
}));

http.get('/api/items', ({ request }) => {
  const url = new URL(request.url);
  const page = parseInt(url.searchParams.get('page') || '1');
  const limit = parseInt(url.searchParams.get('limit') || '10');
  
  const start = (page - 1) * limit;
  const end = start + limit;
  const items = allItems.slice(start, end);
  
  return HttpResponse.json({
    items,
    pagination: {
      page,
      limit,
      total: allItems.length,
      totalPages: Math.ceil(allItems.length / limit)
    }
  });
})
```

#### File Upload Simulation

```javascript
http.post('/api/upload', async ({ request }) => {
  const formData = await request.formData();
  const file = formData.get('file');
  
  if (!file) {
    return HttpResponse.json(
      { error: 'No file provided' },
      { status: 400 }
    );
  }
  
  // Simulate upload progress
  await delay(1000);
  
  return HttpResponse.json({
    id: crypto.randomUUID(),
    filename: file.name,
    size: file.size,
    type: file.type,
    url: `/uploads/${file.name}`
  });
})
```

### Performance Optimization

#### Handler Organization

```javascript
// handlers/users.js
export const userHandlers = [
  http.get('/api/users', () => { /* ... */ }),
  http.post('/api/users', () => { /* ... */ })
];

// handlers/products.js
export const productHandlers = [
  http.get('/api/products', () => { /* ... */ }),
  http.post('/api/products', () => { /* ... */ })
];

// handlers/index.js
import { userHandlers } from './users';
import { productHandlers } from './products';

export const handlers = [
  ...userHandlers,
  ...productHandlers
];
```

#### Lazy Loading Handlers

```javascript
// main.jsx
async function enableMocking() {
  if (process.env.NODE_ENV !== 'development') {
    return;
  }
  
  const { worker } = await import('./mocks/browser');
  
  // Only load specific handlers based on feature flags
  const { handlers } = await import('./mocks/handlers');
  
  if (import.meta.env.VITE_FEATURE_PRODUCTS) {
    const { productHandlers } = await import('./mocks/handlers/products');
    worker.use(...productHandlers);
  }
  
  return worker.start();
}
```

#### Response Caching

```javascript
const cache = new Map();

http.get('/api/expensive', async ({ request }) => {
  const url = request.url;
  
  if (cache.has(url)) {
    return HttpResponse.json(cache.get(url));
  }
  
  // Simulate expensive operation
  await delay(2000);
  
  const data = {
    timestamp: Date.now(),
    result: 'expensive computation'
  };
  
  cache.set(url, data);
  
  // Clear cache after 5 minutes
  setTimeout(() => cache.delete(url), 300000);
  
  return HttpResponse.json(data);
})
```

### Browser DevTools Integration

#### Logging Intercepted Requests

```javascript
// src/mocks/browser.js
import { setupWorker } from 'msw/browser';
import { handlers } from './handlers';

export const worker = setupWorker(...handlers);

worker.events.on('request:start', ({ request }) => {
  console.log('[MSW] Request:', request.method, request.url);
});

worker.events.on('request:match', ({ request }) => {
  console.log('[MSW] Matched:', request.method, request.url);
});

worker.events.on('request:unhandled', ({ request }) => {
  console.log('[MSW] Unhandled:', request.method, request.url);
});

worker.events.on('response:mocked', ({ request, response }) => {
  console.log('[MSW] Mocked response:', request.method, request.url, response.status);
});
```

#### Start Options

```javascript
// Quiet mode - no console warnings
worker.start({
  quiet: true
});

// Custom service worker URL
worker.start({
  serviceWorker: {
    url: '/custom-sw.js'
  }
});

// Only warn about specific unhandled requests
worker.start({
  onUnhandledRequest: 'warn' // 'warn' | 'error' | 'bypass'
});

// Custom unhandled request handler
worker.start({
  onUnhandledRequest(request, print) {
    if (request.url.includes('/analytics')) {
      return; // Ignore analytics requests
    }
    print.warning();
  }
});
```

### TypeScript Integration

#### Typed Handlers

```typescript
import { http, HttpResponse } from 'msw';

interface User {
  id: number;
  name: string;
  email: string;
}

interface CreateUserRequest {
  name: string;
  email: string;
}

export const handlers = [
  http.get<never, never, User>('/api/user', () => {
    return HttpResponse.json<User>({
      id: 1,
      name: 'John Doe',
      email: 'john@example.com'
    });
  }),
  
  http.post<never, CreateUserRequest, User>('/api/users', async ({ request }) => {
    const body = await request.json();
    
    return HttpResponse.json<User>({
      id: Date.now(),
      name: body.name,
      email: body.email
    });
  })
];
```

#### Typed Path Parameters

```typescript
interface UserParams {
  userId: string;
}

http.get<UserParams>('/api/users/:userId', ({ params }) => {
  const { userId } = params; // userId is typed as string
  
  return HttpResponse.json({
    id: parseInt(userId),
    name: 'User'
  });
})
```

#### Generic Response Helper

```typescript
function createJsonResponse<T>(data: T, status = 200) {
  return HttpResponse.json<T>(data, { status });
}

http.get('/api/users', () => {
  return createJsonResponse<User[]>([
    { id: 1, name: 'Alice', email: 'alice@example.com' }
  ]);
})
```

### Environment-Specific Configuration

#### Feature Flags

```javascript
// config/features.js
export const features = {
  enableMocking: import.meta.env.DEV,
  enableNetworkDelay: import.meta.env.VITE_SLOW_NETWORK === 'true',
  enableErrors: import.meta.env.VITE_TEST_ERRORS === 'true'
};

// handlers/index.js
import { features } from '../config/features';
import { delay } from 'msw';

http.get('/api/data', async () => {
  if (features.enableNetworkDelay) {
    await delay(2000);
  }
  
  if (features.enableErrors && Math.random() < 0.3) {
    return HttpResponse.error();
  }
  
  return HttpResponse.json({ data: 'value' });
})
```

#### Multiple Environments

```javascript
// mocks/scenarios/success.js
export const successHandlers = [
  http.get('/api/users', () => {
    return HttpResponse.json([{ id: 1, name: 'User' }]);
  })
];

// mocks/scenarios/error.js
export const errorHandlers = [
  http.get('/api/users', () => {
    return HttpResponse.json(
      { error: 'Server error' },
      { status: 500 }
    );
  })
];

// mocks/browser.js
import { successHandlers } from './scenarios/success';
import { errorHandlers } from './scenarios/error';

const scenario = new URLSearchParams(window.location.search).get('scenario');

const handlers = scenario === 'error' ? errorHandlers : successHandlers;

export const worker = setupWorker(...handlers);
```

### Common Patterns and Recipes

#### Authentication Flow

```javascript
let currentToken = null;

http.post('/api/login', async ({ request }) => {
  const { username, password } = await request.json();
  
  if (username === 'admin' && password === 'password') {
    currentToken = `token-${Date.now()}`;
    
    return HttpResponse.json({
      token: currentToken,
      user: { username }
    });
  }
  
  return HttpResponse.json(
    { error: 'Invalid credentials' },
    { status: 401 }
  );
}),

http.get('/api/profile', ({ request }) => {
  const authHeader = request.headers.get('Authorization');
  const token = authHeader?.replace('Bearer ', '');
  
  if (token !== currentToken) {
    return HttpResponse.json(
      { error: 'Unauthorized' },
      { status: 401 }
    );
  }
  
  return HttpResponse.json({
    username: 'admin',
    email: 'admin@example.com'
  });
}),

http.post('/api/logout', ({ request }) => {
  const authHeader = request.headers.get('Authorization');
  const token = authHeader?.replace('Bearer ', '');
  
  if (token === currentToken) {
    currentToken = null;
  }
  
  return HttpResponse.json({ success: true });
})
```

#### Optimistic Updates

```javascript
const posts = [
  { id: 1, title: 'Post 1', likes: 0 },
  { id: 2, title: 'Post 2', likes: 0 }
];

http.post('/api/posts/:id/like', async ({ params }) => {
  const post = posts.find(p => p.id === parseInt(params.id));
  
  if (!post) {
    return HttpResponse.json(
      { error: 'Post not found' },
      { status: 404 }
    );
  }
  
  // Simulate network delay
  await delay(500);
  
  post.likes++;
  
  return HttpResponse.json(post);
})
```

#### Filtering and Sorting

```javascript
const products = [
  { id: 1, name: 'Product A', category: 'electronics', price: 100 },
  { id: 2, name: 'Product B', category: 'books', price: 20 },
  { id: 3, name: 'Product C', category: 'electronics', price: 200 }
];

http.get('/api/products', ({ request }) => {
  const url = new URL(request.url);
  const category = url.searchParams.get('category');
  const sortBy = url.searchParams.get('sort');
  const order = url.searchParams.get('order') || 'asc';
  
  let filtered = [...products];
  
  if (category) {
    filtered = filtered.filter(p => p.category === category);
  }
  
  if (sortBy) {
    filtered.sort((a, b) => {
      const aVal = a[sortBy];
      const bVal = b[sortBy];
      
      if (order === 'desc') {
        return bVal > aVal ? 1 : -1;
      }
      return aVal > bVal ? 1 : -1;
    });
  }
  
  return HttpResponse.json(filtered);
})
```

#### WebSocket Simulation

[Inference] MSW does not natively support WebSocket mocking in the same way it handles HTTP requests. For WebSocket testing, alternative approaches or libraries would typically be used.

### Debugging Tips

#### Handler Not Matching

```javascript
// Add catch-all handler to debug
http.all('*', ({ request }) => {
  console.log('Unhandled request:', request.method, request.url);
  return passthrough();
})
```

#### Request Body Not Parsing

```javascript
http.post('/api/data', async ({ request }) => {
  try {
    const body = await request.json();
    return HttpResponse.json({ received: body });
  } catch (error) {
    console.error('Failed to parse body:', error);
    return HttpResponse.json(
      { error: 'Invalid JSON' },
      { status: 400 }
    );
  }
})
```

#### Handler Execution Order

```javascript
// Specific handlers should come before generic ones
export const handlers = [
  http.get('/api/users/me', () => {
    return HttpResponse.json({ username: 'current-user' });
  }),
  
  http.get('/api/users/:id', ({ params }) => {
    return HttpResponse.json({ id: params.id });
  }),
  
  // Catch-all should be last
  http.get('/api/*', () => {
    return HttpResponse.json({ fallback: true });
  })
];
```

### Migration from Other Tools

#### From fetch-mock

```javascript
// fetch-mock
fetchMock.get('/api/users', { body: [{ id: 1 }] });

// MSW equivalent
http.get('/api/users', () => {
  return HttpResponse.json([{ id: 1 }]);
})
```

#### From nock

```javascript
// nock
nock('https://api.example.com')
  .get('/users')
  .reply(200, { id: 1 });

// MSW equivalent
http.get('https://api.example.com/users', () => {
  return HttpResponse.json({ id: 1 });
})
```

#### From mirage.js

```javascript
// Mirage
this.get('/api/users', () => {
  return { users: [{ id: 1 }] };
});

// MSW equivalent
http.get('/api/users', () => {
  return HttpResponse.json({
    users: [{ id: 1 }]
  });
})
```

### Best Practices

**Handler Organization**: Group handlers by domain or feature. Keep handlers focused and single-purpose.

**Response Realism**: Match production API responses including status codes, headers, and error formats.

**State Management**: Use in-memory databases for stateful scenarios. Reset state between tests.

**Error Scenarios**: Test both success and failure paths. Include network errors, timeouts, and edge cases.

**Type Safety**: Use TypeScript for type-safe request/response contracts.

**Performance**: Avoid expensive operations in handlers. Cache computed responses when appropriate.

**Testing**: Reset handlers after each test. Use test-specific handlers to avoid affecting other tests.

**Documentation**: Document handler behavior, especially for complex scenarios or stateful operations.

---

