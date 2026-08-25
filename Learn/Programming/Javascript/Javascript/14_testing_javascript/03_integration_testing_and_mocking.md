## Integration Testing and Mocking


### Understanding Integration Testing

Integration testing validates that different modules or services work together correctly. Unlike unit tests that isolate specific functions, integration tests ensure that component interactions behave as expected across interfaces.

**Key Points**:

- Tests multiple components together
- Validates correct data flow between components
- Identifies interface defects
- Verifies integrated components work as a cohesive system
- More complex than unit tests but provides higher confidence

### Popular JavaScript Integration Testing Frameworks

### Jest

Jest is a complete testing solution developed by Facebook that excels at both unit and integration testing.

```javascript
// Example integration test with Jest
describe('User API integration', () => {
  test('should create and retrieve a user', async () => {
    // Create a user
    const newUser = await createUser({ name: 'John Doe', email: 'john@example.com' });
    
    // Retrieve the created user
    const retrievedUser = await getUserById(newUser.id);
    
    // Assert correct integration between create and retrieve
    expect(retrievedUser).toEqual(newUser);
  });
});
```

### Supertest

Supertest is designed specifically for testing HTTP servers, making it ideal for API integration testing.

```javascript
const request = require('supertest');
const app = require('../app');

describe('User API', () => {
  test('GET /users should return list of users', async () => {
    const response = await request(app)
      .get('/users')
      .expect('Content-Type', /json/)
      .expect(200);
    
    expect(response.body).toHaveProperty('users');
    expect(Array.isArray(response.body.users)).toBeTruthy();
  });
});
```

### Cypress

Cypress provides end-to-end testing with a focus on web applications, but is excellent for integration testing as well.

```javascript
describe('User flow', () => {
  it('should allow user registration and login', () => {
    // Test registration
    cy.visit('/register');
    cy.get('input[name="username"]').type('testuser');
    cy.get('input[name="password"]').type('Password123');
    cy.get('button[type="submit"]').click();
    cy.url().should('include', '/dashboard');
    
    // Test login with created user
    cy.visit('/login');
    cy.get('input[name="username"]').type('testuser');
    cy.get('input[name="password"]').type('Password123');
    cy.get('button[type="submit"]').click();
    cy.url().should('include', '/dashboard');
  });
});
```

### Mocking in JavaScript

### What is Mocking?

Mocking creates simulated objects that mimic the behavior of real components, enabling focused testing without dependencies.

**Key Points**:

- Replaces external dependencies with controlled test doubles
- Isolates the system under test
- Enables testing of hard-to-test scenarios
- Accelerates test execution
- Increases test reliability

### Types of Test Doubles

### Mocks

Objects pre-programmed with expectations about calls they should receive.

```javascript
// Mock example with Jest
test('user service calls the database', () => {
  // Create a mock for the database
  const dbMock = {
    saveUser: jest.fn().mockResolvedValue({ id: 123 })
  };
  
  const userService = new UserService(dbMock);
  
  // Call the method we want to test
  return userService.createUser({ name: 'Test User' }).then(() => {
    // Verify the mock was called correctly
    expect(dbMock.saveUser).toHaveBeenCalledWith({ name: 'Test User' });
  });
});
```

### Stubs

Provide canned answers to calls during tests.

```javascript
test('displays user profile when data is loaded', async () => {
  // Stub the API call
  const userData = { id: 1, name: 'Test User', email: 'test@example.com' };
  apiClient.getUserProfile = jest.fn().mockResolvedValue(userData);
  
  // Render component
  const { getByText } = render(<UserProfile userId={1} />);
  
  // Wait for async operations
  await waitFor(() => {
    expect(getByText('Test User')).toBeInTheDocument();
    expect(getByText('test@example.com')).toBeInTheDocument();
  });
});
```

### Spies

Track calls to functions without changing their implementation.

```javascript
test('logger logs errors correctly', () => {
  // Create a spy on console.error
  jest.spyOn(console, 'error');
  
  const error = new Error('Test error');
  const logger = new Logger();
  
  // Call the method we want to test
  logger.logError(error);
  
  // Verify the spy recorded the correct call
  expect(console.error).toHaveBeenCalledWith('[ERROR]:', error);
});
```

### Popular Mocking Libraries for JavaScript

### Jest Mocks

Jest has comprehensive built-in mocking capabilities.

```javascript
// Mocking a module
jest.mock('axios');

test('fetches users', async () => {
  const users = [{ name: 'Bob' }];
  axios.get.mockResolvedValue({ data: users });

  const result = await fetchUsers();
  expect(result).toEqual(users);
  expect(axios.get).toHaveBeenCalledWith('/users');
});

// Manual mocks
jest.mock('./database', () => ({
  connect: jest.fn(),
  query: jest.fn().mockResolvedValue([{ id: 1, name: 'Test' }])
}));
```

### Sinon.JS

Standalone test spies, stubs, and mocks for JavaScript.

```javascript
const sinon = require('sinon');

describe('UserService', () => {
  it('should send welcome email when user is created', async () => {
    // Create a stub for the email service
    const emailStub = sinon.stub(emailService, 'sendEmail').resolves(true);
    
    // Create a user
    const userService = new UserService(emailService);
    await userService.createUser({ name: 'Test', email: 'test@example.com' });
    
    // Verify the stub was called with correct arguments
    sinon.assert.calledWith(emailStub, 'test@example.com', 'Welcome!', sinon.match.string);
    
    // Restore the stub
    emailStub.restore();
  });
});
```

### Nock

HTTP server mocking and expectations library.

```javascript
const nock = require('nock');

describe('API client', () => {
  afterEach(() => {
    nock.cleanAll();
  });

  it('fetches todos from API', async () => {
    const todos = [{ id: 1, title: 'Learn Testing' }];
    
    // Mock the HTTP request
    nock('https://api.example.com')
      .get('/todos')
      .reply(200, todos);
    
    // Call the client that will use the HTTP request
    const apiClient = new ApiClient('https://api.example.com');
    const result = await apiClient.getTodos();
    
    // Verify the result
    expect(result).toEqual(todos);
  });
});
```

### MSW (Mock Service Worker)

Modern API mocking library that uses service workers.

```javascript
import { rest } from 'msw';
import { setupServer } from 'msw/node';

// Define request handlers
const server = setupServer(
  rest.get('https://api.example.com/users', (req, res, ctx) => {
    return res(
      ctx.status(200),
      ctx.json([
        { id: 1, name: 'Test User' },
        { id: 2, name: 'Another User' }
      ])
    );
  })
);

// Start server before tests
beforeAll(() => server.listen());
afterEach(() => server.resetHandlers());
afterAll(() => server.close());

test('fetches users from API', async () => {
  const users = await fetchUsers();
  expect(users).toHaveLength(2);
  expect(users[0].name).toBe('Test User');
});
```

### Integration Testing Best Practices

### Focus on Critical Paths

Test business-critical user flows rather than every possible scenario.

```javascript
// Testing a critical user registration and checkout flow
test('User can register and complete checkout', async () => {
  // Registration steps
  await userService.register({
    username: 'testuser',
    email: 'test@example.com',
    password: 'Password123'
  });
  
  // Add items to cart
  await cartService.addItem('testuser', { productId: 123, quantity: 2 });
  
  // Complete checkout
  const order = await checkoutService.processOrder('testuser', {
    paymentMethod: 'credit',
    shippingAddress: '123 Test St'
  });
  
  // Verify the integrated services worked correctly
  expect(order.status).toBe('confirmed');
  expect(order.items).toHaveLength(1);
  expect(order.total).toBe(59.98);
});
```

### Set Up Isolated Test Environments

Use Docker or similar tools to create consistent, isolated environments.

```javascript
// docker-compose.test.yml
version: '3'
services:
  app:
    build: .
    depends_on:
      - mongodb
      - redis
  mongodb:
    image: mongo:4
    ports:
      - "27017:27017"
  redis:
    image: redis:alpine
    ports:
      - "6379:6379"
```

### Use Test Databases

Create test databases that mirror production schemas.

```javascript
// Database setup for tests
beforeAll(async () => {
  // Connect to test database
  connection = await mongoose.connect('mongodb://localhost:27017/test_db');
  
  // Clear database before tests
  await mongoose.connection.db.dropDatabase();
  
  // Seed with test data
  await User.create([
    { username: 'user1', email: 'user1@example.com' },
    { username: 'user2', email: 'user2@example.com' }
  ]);
});

afterAll(async () => {
  // Disconnect after tests
  await mongoose.connection.close();
});
```

### Mocking Best Practices

### Only Mock External Dependencies

Focus on mocking external services, not the code you're testing.

```javascript
// Good practice: Mock API calls and databases
test('user service creates user profile', async () => {
  // Mock the database
  const dbMock = {
    saveUser: jest.fn().mockResolvedValue({ id: 123 }),
  };
  
  // Mock external email service
  const emailServiceMock = {
    sendWelcomeEmail: jest.fn().mockResolvedValue(true)
  };
  
  const userService = new UserService(dbMock, emailServiceMock);
  const result = await userService.createUser({ name: 'Test User' });
  
  expect(result.id).toBe(123);
  expect(dbMock.saveUser).toHaveBeenCalled();
  expect(emailServiceMock.sendWelcomeEmail).toHaveBeenCalled();
});
```

### Use Realistic Mock Data

Create mocks that resemble real-world data.

```javascript
// Create realistic mock user data
const mockUserData = {
  id: '60d21b4667d0d8992e610c85',
  name: 'John Doe',
  email: 'john@example.com',
  createdAt: new Date('2021-06-22T10:00:00Z').toISOString(),
  address: {
    street: '123 Main St',
    city: 'Testville',
    zip: '12345'
  },
  orders: [
    { id: 'ord-001', amount: 59.99, date: '2021-06-23T14:00:00Z' },
    { id: 'ord-002', amount: 29.99, date: '2021-07-01T09:30:00Z' }
  ]
};
```

### Balance Mocking and Real Implementation

Not everything should be mocked - some real implementations provide better test coverage.

```javascript
describe('Order processing', () => {
  test('complete flow with minimal mocking', async () => {
    // Only mock external payment processor
    const paymentProcessorMock = {
      processPayment: jest.fn().mockResolvedValue({ success: true, id: 'payment-123' })
    };
    
    // Use real implementations of internal services
    const orderService = new OrderService(
      new InventoryService(), // Real implementation
      new UserService(),      // Real implementation
      paymentProcessorMock    // Mocked external dependency
    );
    
    const result = await orderService.createOrder({
      userId: 'user-123',
      items: [{ productId: 'prod-456', quantity: 2 }]
    });
    
    expect(result.status).toBe('success');
    expect(paymentProcessorMock.processPayment).toHaveBeenCalled();
  });
});
```

### Combining Integration Tests and Mocks

### API Testing with Selective Mocking

Test API endpoints while mocking external services.

```javascript
const request = require('supertest');
const app = require('../app');

// Mock external dependencies
jest.mock('../services/payment', () => ({
  processPayment: jest.fn().mockResolvedValue({ success: true, id: 'pay-123' })
}));

describe('Order API', () => {
  test('POST /orders creates a new order', async () => {
    const response = await request(app)
      .post('/api/orders')
      .send({
        items: [{ productId: 1, quantity: 2 }],
        paymentDetails: { cardNumber: '4242424242424242', expiry: '12/25' }
      })
      .set('Authorization', 'Bearer test-token')
      .expect('Content-Type', /json/)
      .expect(201);
    
    expect(response.body).toHaveProperty('orderId');
    expect(response.body.status).toBe('confirmed');
  });
});
```

### Component Integration with Mock Services

Test UI components that integrate with backend services.

```javascript
import { render, screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { rest } from 'msw';
import { setupServer } from 'msw/node';
import CheckoutForm from '../CheckoutForm';

// Set up mock server
const server = setupServer(
  rest.post('/api/orders', (req, res, ctx) => {
    return res(
      ctx.status(201),
      ctx.json({ orderId: 'order-123', status: 'confirmed' })
    );
  })
);

beforeAll(() => server.listen());
afterEach(() => server.resetHandlers());
afterAll(() => server.close());

test('checkout form submits order and shows confirmation', async () => {
  render(<CheckoutForm />);
  
  // Fill out the form
  userEvent.type(screen.getByLabelText(/name/i), 'John Doe');
  userEvent.type(screen.getByLabelText(/address/i), '123 Test St');
  userEvent.type(screen.getByLabelText(/credit card/i), '4242424242424242');
  
  // Submit the form
  userEvent.click(screen.getByRole('button', { name: /place order/i }));
  
  // Wait for and verify confirmation
  await waitFor(() => {
    expect(screen.getByText(/order confirmed/i)).toBeInTheDocument();
    expect(screen.getByText(/order-123/i)).toBeInTheDocument();
  });
});
```

### Microservice Integration Testing

Test interactions between microservices using mocks.

```javascript
// Testing User Service and Order Service integration
describe('Microservice Integration', () => {
  // Mock the inter-service communication
  const userServiceMock = nock('http://user-service')
    .get('/api/users/123')
    .reply(200, {
      id: '123',
      name: 'Test User',
      email: 'test@example.com',
      premium: true
    });
  
  test('order service can retrieve user data for order processing', async () => {
    const orderService = new OrderService({
      userServiceBaseUrl: 'http://user-service'
    });
    
    const orderResult = await orderService.createOrder({
      userId: '123',
      items: [{ productId: 'premium-item', quantity: 1 }]
    });
    
    // Verify the order was created with premium user benefits
    expect(orderResult.discountApplied).toBe(true);
    expect(orderResult.premiumShipping).toBe(true);
    
    // Verify the mock was called
    expect(userServiceMock.isDone()).toBe(true);
  });
});
```

### Advanced Integration Testing Scenarios

### Testing Asynchronous Processes

Test workflows with background processing, queues, or webhooks.

```javascript
test('order processing with background jobs', async () => {
  // Mock job queue
  const queueMock = {
    add: jest.fn().mockResolvedValue({ id: 'job-123' }),
    getJob: jest.fn().mockResolvedValue({
      id: 'job-123',
      data: { orderId: 'order-456' },
      progress: 100,
      finished: true,
      returnvalue: { success: true }
    })
  };
  
  const orderProcessor = new OrderProcessor(queueMock);
  
  // Start async processing
  const jobId = await orderProcessor.processOrderAsync('order-456');
  
  // Verify job was added to queue
  expect(queueMock.add).toHaveBeenCalledWith('process-order', { orderId: 'order-456' });
  
  // Check job status
  const result = await orderProcessor.getOrderProcessingResult(jobId);
  expect(result.success).toBe(true);
});
```

### Testing Data Consistency Across Services

Verify that data remains consistent across multiple services.

```javascript
test('user data is consistent across services', async () => {
  // Create test user
  const userData = { name: 'Test User', email: 'test@example.com' };
  const user = await userService.createUser(userData);
  
  // Allow propagation time in real environment
  await new Promise(resolve => setTimeout(resolve, 1000));
  
  // Verify user data in dependent services
  const profileData = await profileService.getUserProfile(user.id);
  expect(profileData.name).toBe(userData.name);
  
  const authData = await authService.getUserById(user.id);
  expect(authData.email).toBe(userData.email);
  
  // Verify analytics tracking
  const analyticsUser = await analyticsService.getUser(user.id);
  expect(analyticsUser).not.toBeNull();
  expect(analyticsUser.signupDate).toBeInstanceOf(Date);
});
```

### Continuous Integration with Integration Tests

Configure CI/CD pipelines for integration tests.

```yaml
# .github/workflows/integration-tests.yml
name: Integration Tests

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]

jobs:
  test:
    runs-on: ubuntu-latest
    
    services:
      mongodb:
        image: mongo:4
        ports:
          - 27017:27017
      redis:
        image: redis:alpine
        ports:
          - 6379:6379
      
    steps:
      - uses: actions/checkout@v2
      - name: Use Node.js
        uses: actions/setup-node@v2
        with:
          node-version: '16.x'
      - name: Install dependencies
        run: npm ci
      - name: Run integration tests
        run: npm run test:integration
        env:
          NODE_ENV: test
          MONGODB_URI: mongodb://localhost:27017/test_db
          REDIS_URL: redis://localhost:6379
```

**Conclusion**: Integration testing and mocking are essential practices in JavaScript development that ensure components work correctly together while maintaining test control and efficiency. By strategically combining real implementations with thoughtful mocks, developers can create robust test suites that provide confidence in system behavior without sacrificing speed or reliability. The key is finding the right balance: mock external dependencies that are difficult to control, but use real implementations when possible to ensure your tests reflect actual system behavior.

---
