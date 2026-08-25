## Testing Strategies


### Unit Testing Resolvers

Unit testing GraphQL resolvers involves testing individual resolver functions in isolation, ensuring they correctly process inputs and return expected outputs. This approach focuses on testing the business logic within resolvers without external dependencies.

**Basic Resolver Unit Testing:**

```javascript
const { resolvers } = require('./resolvers');

describe('User Resolvers', () => {
  test('should resolve user by ID', async () => {
    const mockUser = { id: '1', name: 'John Doe', email: 'john@example.com' };
    const mockContext = {
      userLoader: {
        load: jest.fn().mockResolvedValue(mockUser)
      }
    };

    const result = await resolvers.Query.user(
      null,
      { id: '1' },
      mockContext
    );

    expect(result).toEqual(mockUser);
    expect(mockContext.userLoader.load).toHaveBeenCalledWith('1');
  });

  test('should handle user not found', async () => {
    const mockContext = {
      userLoader: {
        load: jest.fn().mockResolvedValue(null)
      }
    };

    const result = await resolvers.Query.user(
      null,
      { id: 'nonexistent' },
      mockContext
    );

    expect(result).toBeNull();
  });
});
```

**Testing Resolver Arguments and Context:**

```javascript
describe('Post Resolvers', () => {
  test('should create post with authenticated user', async () => {
    const mockPost = { id: '1', title: 'Test Post', content: 'Test content' };
    const mockContext = {
      user: { id: '1', name: 'John Doe' },
      db: {
        posts: {
          create: jest.fn().mockResolvedValue(mockPost)
        }
      }
    };

    const result = await resolvers.Mutation.createPost(
      null,
      { input: { title: 'Test Post', content: 'Test content' } },
      mockContext
    );

    expect(result).toEqual(mockPost);
    expect(mockContext.db.posts.create).toHaveBeenCalledWith({
      data: {
        title: 'Test Post',
        content: 'Test content',
        authorId: '1'
      }
    });
  });

  test('should throw error for unauthenticated user', async () => {
    const mockContext = {
      user: null,
      db: { posts: { create: jest.fn() } }
    };

    await expect(
      resolvers.Mutation.createPost(
        null,
        { input: { title: 'Test Post', content: 'Test content' } },
        mockContext
      )
    ).rejects.toThrow('Authentication required');
  });
});
```

**Testing Complex Resolvers with Dependencies:**

```javascript
describe('Complex Resolver Testing', () => {
  test('should resolve nested user posts with pagination', async () => {
    const mockUser = { id: '1', name: 'John Doe' };
    const mockPosts = [
      { id: '1', title: 'Post 1', userId: '1' },
      { id: '2', title: 'Post 2', userId: '1' }
    ];

    const mockContext = {
      postsByUserLoader: {
        load: jest.fn().mockResolvedValue(mockPosts)
      }
    };

    const result = await resolvers.User.posts(
      mockUser,
      { first: 10, after: null },
      mockContext
    );

    expect(result).toHaveLength(2);
    expect(mockContext.postsByUserLoader.load).toHaveBeenCalledWith('1');
  });

  test('should handle resolver errors gracefully', async () => {
    const mockUser = { id: '1', name: 'John Doe' };
    const mockContext = {
      postsByUserLoader: {
        load: jest.fn().mockRejectedValue(new Error('Database error'))
      }
    };

    await expect(
      resolvers.User.posts(mockUser, {}, mockContext)
    ).rejects.toThrow('Database error');
  });
});
```

### Integration Testing

Integration testing for GraphQL focuses on testing the complete flow from GraphQL query execution to database interaction, ensuring all components work together correctly.

**GraphQL Server Integration Testing:**

```javascript
const { createTestClient } = require('apollo-server-testing');
const { ApolloServer } = require('apollo-server');
const { typeDefs, resolvers } = require('./schema');

describe('GraphQL Integration Tests', () => {
  let server;
  let query, mutate;

  beforeAll(() => {
    server = new ApolloServer({
      typeDefs,
      resolvers,
      context: ({ req }) => ({
        user: req.user,
        db: mockDatabase
      })
    });

    const testClient = createTestClient(server);
    query = testClient.query;
    mutate = testClient.mutate;
  });

  test('should execute user query successfully', async () => {
    const GET_USER = `
      query GetUser($id: ID!) {
        user(id: $id) {
          id
          name
          email
          posts {
            id
            title
          }
        }
      }
    `;

    const { data, errors } = await query({
      query: GET_USER,
      variables: { id: '1' }
    });

    expect(errors).toBeUndefined();
    expect(data.user).toBeDefined();
    expect(data.user.id).toBe('1');
    expect(data.user.posts).toBeInstanceOf(Array);
  });

  test('should handle mutation with validation errors', async () => {
    const CREATE_POST = `
      mutation CreatePost($input: PostInput!) {
        createPost(input: $input) {
          id
          title
          content
        }
      }
    `;

    const { data, errors } = await mutate({
      mutation: CREATE_POST,
      variables: {
        input: { title: '', content: 'Test content' } // Invalid title
      }
    });

    expect(errors).toBeDefined();
    expect(errors[0].message).toContain('Title is required');
  });
});
```

**Database Integration Testing:**

```javascript
const { setupTestDB, teardownTestDB } = require('./test-utils');

describe('Database Integration Tests', () => {
  let db;

  beforeAll(async () => {
    db = await setupTestDB();
  });

  afterAll(async () => {
    await teardownTestDB(db);
  });

  beforeEach(async () => {
    await db.users.deleteMany({});
    await db.posts.deleteMany({});
  });

  test('should create and retrieve user with posts', async () => {
    // Create test data
    const user = await db.users.create({
      data: { name: 'Test User', email: 'test@example.com' }
    });

    await db.posts.create({
      data: { title: 'Test Post', content: 'Content', userId: user.id }
    });

    const GET_USER_WITH_POSTS = `
      query GetUserWithPosts($id: ID!) {
        user(id: $id) {
          id
          name
          posts {
            id
            title
          }
        }
      }
    `;

    const { data } = await query({
      query: GET_USER_WITH_POSTS,
      variables: { id: user.id }
    });

    expect(data.user.name).toBe('Test User');
    expect(data.user.posts).toHaveLength(1);
    expect(data.user.posts[0].title).toBe('Test Post');
  });
});
```

**Testing GraphQL Subscriptions:**

```javascript
const { createTestClient } = require('apollo-server-testing');
const { WebSocketLink } = require('@apollo/client/link/ws');
const { SubscriptionClient } = require('subscriptions-transport-ws');

describe('Subscription Integration Tests', () => {
  let subscriptionClient;
  let wsLink;

  beforeAll(() => {
    subscriptionClient = new SubscriptionClient(
      'ws://localhost:4000/graphql',
      { reconnect: true }
    );
    wsLink = new WebSocketLink(subscriptionClient);
  });

  afterAll(() => {
    subscriptionClient.close();
  });

  test('should receive real-time updates', async () => {
    const POST_CREATED_SUBSCRIPTION = `
      subscription PostCreated {
        postCreated {
          id
          title
          author {
            name
          }
        }
      }
    `;

    const subscription = wsLink.request({
      query: POST_CREATED_SUBSCRIPTION
    });

    const receivedData = [];
    subscription.subscribe({
      next: (data) => receivedData.push(data)
    });

    // Trigger post creation
    await mutate({
      mutation: CREATE_POST,
      variables: { input: { title: 'New Post', content: 'Content' } }
    });

    // Wait for subscription update
    await new Promise(resolve => setTimeout(resolve, 100));

    expect(receivedData).toHaveLength(1);
    expect(receivedData[0].data.postCreated.title).toBe('New Post');
  });
});
```

### End-to-End Testing

End-to-end testing validates the complete GraphQL application flow, including client-server communication, authentication, and real database interactions.

**Full Application E2E Testing:**

```javascript
const { chromium } = require('playwright');
const { startServer, stopServer } = require('./test-server');

describe('E2E GraphQL Application Tests', () => {
  let browser;
  let page;
  let server;

  beforeAll(async () => {
    server = await startServer();
    browser = await chromium.launch();
    page = await browser.newPage();
  });

  afterAll(async () => {
    await browser.close();
    await stopServer(server);
  });

  test('should complete user registration and login flow', async () => {
    // Navigate to registration page
    await page.goto('http://localhost:3000/register');

    // Fill registration form
    await page.fill('[data-testid="name-input"]', 'Test User');
    await page.fill('[data-testid="email-input"]', 'test@example.com');
    await page.fill('[data-testid="password-input"]', 'password123');
    await page.click('[data-testid="register-button"]');

    // Verify registration success
    await page.waitForSelector('[data-testid="success-message"]');
    expect(await page.textContent('[data-testid="success-message"]'))
      .toContain('Registration successful');

    // Login with new account
    await page.goto('http://localhost:3000/login');
    await page.fill('[data-testid="email-input"]', 'test@example.com');
    await page.fill('[data-testid="password-input"]', 'password123');
    await page.click('[data-testid="login-button"]');

    // Verify login success and redirect
    await page.waitForURL('http://localhost:3000/dashboard');
    expect(await page.textContent('[data-testid="user-name"]'))
      .toBe('Test User');
  });

  test('should handle GraphQL query errors gracefully', async () => {
    // Mock network error
    await page.route('**/graphql', route => {
      route.fulfill({
        status: 500,
        body: JSON.stringify({ errors: [{ message: 'Server error' }] })
      });
    });

    await page.goto('http://localhost:3000/posts');

    // Verify error handling
    await page.waitForSelector('[data-testid="error-message"]');
    expect(await page.textContent('[data-testid="error-message"]'))
      .toContain('Failed to load posts');
  });
});
```

**API Testing with Real Database:**

```javascript
const request = require('supertest');
const app = require('./app');
const { setupTestDB, teardownTestDB } = require('./test-utils');

describe('E2E API Tests', () => {
  let db;

  beforeAll(async () => {
    db = await setupTestDB();
  });

  afterAll(async () => {
    await teardownTestDB(db);
  });

  test('should handle complete post creation workflow', async () => {
    // Create user
    const userResponse = await request(app)
      .post('/graphql')
      .send({
        query: `
          mutation RegisterUser($input: RegisterInput!) {
            register(input: $input) {
              token
              user {
                id
                name
              }
            }
          }
        `,
        variables: {
          input: {
            name: 'Test User',
            email: 'test@example.com',
            password: 'password123'
          }
        }
      });

    expect(userResponse.status).toBe(200);
    expect(userResponse.body.data.register.token).toBeDefined();

    const token = userResponse.body.data.register.token;

    // Create post with authentication
    const postResponse = await request(app)
      .post('/graphql')
      .set('Authorization', `Bearer ${token}`)
      .send({
        query: `
          mutation CreatePost($input: PostInput!) {
            createPost(input: $input) {
              id
              title
              content
              author {
                name
              }
            }
          }
        `,
        variables: {
          input: {
            title: 'Test Post',
            content: 'This is a test post'
          }
        }
      });

    expect(postResponse.status).toBe(200);
    expect(postResponse.body.data.createPost.title).toBe('Test Post');
    expect(postResponse.body.data.createPost.author.name).toBe('Test User');
  });
});
```

### Mocking GraphQL Operations

Mocking GraphQL operations allows testing client-side code without running a real GraphQL server, enabling faster and more reliable tests.

**Apollo Client Mocking:**

```javascript
const { MockedProvider } = require('@apollo/client/testing');
const { render, screen, waitFor } = require('@testing-library/react');
const { GET_POSTS } = require('./queries');
const PostList = require('./PostList');

const mocks = [
  {
    request: {
      query: GET_POSTS,
      variables: { first: 10 }
    },
    result: {
      data: {
        posts: [
          { id: '1', title: 'Post 1', content: 'Content 1' },
          { id: '2', title: 'Post 2', content: 'Content 2' }
        ]
      }
    }
  }
];

describe('PostList Component', () => {
  test('should render posts from GraphQL query', async () => {
    render(
      <MockedProvider mocks={mocks} addTypename={false}>
        <PostList />
      </MockedProvider>
    );

    await waitFor(() => {
      expect(screen.getByText('Post 1')).toBeInTheDocument();
      expect(screen.getByText('Post 2')).toBeInTheDocument();
    });
  });

  test('should handle GraphQL errors', async () => {
    const errorMocks = [
      {
        request: {
          query: GET_POSTS,
          variables: { first: 10 }
        },
        error: new Error('Network error')
      }
    ];

    render(
      <MockedProvider mocks={errorMocks} addTypename={false}>
        <PostList />
      </MockedProvider>
    );

    await waitFor(() => {
      expect(screen.getByText('Error loading posts')).toBeInTheDocument();
    });
  });
});
```

**Mock Service Worker for GraphQL:**

```javascript
const { setupServer } = require('msw/node');
const { graphql } = require('msw');

const server = setupServer(
  graphql.query('GetPosts', (req, res, ctx) => {
    return res(
      ctx.data({
        posts: [
          { id: '1', title: 'Mocked Post 1', content: 'Mocked content 1' },
          { id: '2', title: 'Mocked Post 2', content: 'Mocked content 2' }
        ]
      })
    );
  }),

  graphql.mutation('CreatePost', (req, res, ctx) => {
    const { input } = req.variables;
    return res(
      ctx.data({
        createPost: {
          id: '3',
          title: input.title,
          content: input.content,
          author: { name: 'Test User' }
        }
      })
    );
  })
);

beforeAll(() => server.listen());
afterEach(() => server.resetHandlers());
afterAll(() => server.close());

test('should create post with mocked GraphQL', async () => {
  const response = await fetch('/graphql', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      query: `
        mutation CreatePost($input: PostInput!) {
          createPost(input: $input) {
            id
            title
            content
          }
        }
      `,
      variables: {
        input: { title: 'New Post', content: 'New content' }
      }
    })
  });

  const data = await response.json();
  expect(data.data.createPost.title).toBe('New Post');
});
```

**Custom GraphQL Mock Factory:**

```javascript
const createGraphQLMock = (schema) => {
  const mocks = {};

  const addMock = (operationName, result) => {
    mocks[operationName] = result;
  };

  const addMockWithVariables = (operationName, variablesMatcher, result) => {
    mocks[operationName] = (variables) => {
      if (variablesMatcher(variables)) {
        return result;
      }
      throw new Error(`Variables don't match for ${operationName}`);
    };
  };

  const execute = async (query, variables = {}) => {
    const operationName = extractOperationName(query);
    const mock = mocks[operationName];

    if (!mock) {
      throw new Error(`No mock found for operation: ${operationName}`);
    }

    if (typeof mock === 'function') {
      return { data: mock(variables) };
    }

    return { data: mock };
  };

  return { addMock, addMockWithVariables, execute };
};

// Usage
const mockClient = createGraphQLMock(schema);

mockClient.addMock('GetUser', {
  user: { id: '1', name: 'Test User' }
});

mockClient.addMockWithVariables(
  'GetPostsByUser',
  (variables) => variables.userId === '1',
  { posts: [{ id: '1', title: 'User Post' }] }
);
```

**Key Points:**

- Unit tests focus on individual resolver functions with mocked dependencies
- Integration tests verify complete GraphQL operation flows with real database connections
- End-to-end tests validate the entire application stack including client-server communication
- Mocking enables fast, reliable testing without external dependencies
- Use MockedProvider for Apollo Client testing and MSW for comprehensive API mocking
- Test error scenarios and edge cases alongside happy paths
- Maintain test data consistency across different testing levels

**Example** of a comprehensive test suite structure:

```javascript
// Test pyramid implementation
describe('GraphQL Test Suite', () => {
  // Unit tests (70% of tests)
  describe('Unit Tests', () => {
    // Resolver unit tests
    // Utility function tests
    // Schema validation tests
  });

  // Integration tests (20% of tests)
  describe('Integration Tests', () => {
    // GraphQL server integration
    // Database integration
    // Authentication integration
  });

  // E2E tests (10% of tests)
  describe('E2E Tests', () => {
    // Full application workflows
    // Critical user journeys
    // Cross-browser compatibility
  });
});
```

This comprehensive testing approach ensures GraphQL applications are robust, maintainable, and deliver consistent user experiences across all scenarios.

---

