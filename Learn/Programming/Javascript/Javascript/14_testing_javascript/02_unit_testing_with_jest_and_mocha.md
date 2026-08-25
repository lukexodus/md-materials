## Unit Testing with Jest and Mocha


### Understanding Unit Testing

Unit testing is the process of testing individual components or functions of your application in isolation from the rest of the codebase. It ensures that each unit of code performs as expected before integrating with other parts of the application.

**Key Points:**

- Tests individual functions or components in isolation
- Helps catch bugs early in development
- Serves as living documentation for your code
- Enables safe refactoring with immediate feedback
- Forms the foundation of testing pyramids/strategies

### Jest Overview

Jest is a JavaScript testing framework developed by Facebook. It's designed to be simple to set up and use while providing powerful features for testing JavaScript applications.

#### Core Features of Jest

### Zero Configuration

Jest works out of the box for most JavaScript projects with minimal setup.

```javascript
// package.json
{
  "scripts": {
    "test": "jest"
  },
  "devDependencies": {
    "jest": "^29.7.0"
  }
}
```

### Test Structure

Jest uses a straightforward syntax for defining test suites and cases.

```javascript
// math.test.js
const { sum, subtract } = require('./math');

// Test suite
describe('Math operations', () => {
  // Test case
  test('adds 1 + 2 to equal 3', () => {
    expect(sum(1, 2)).toBe(3);
  });
  
  // Alternative syntax
  it('subtracts 5 - 2 to equal 3', () => {
    expect(subtract(5, 2)).toBe(3);
  });
});
```

### Matchers

Jest provides a rich set of built-in matchers to make assertions.

```javascript
test('common matchers', () => {
  // Exact equality
  expect(2 + 2).toBe(4);
  
  // Object equality (checks contents)
  expect({name: 'John'}).toEqual({name: 'John'});
  
  // Truthiness checks
  expect(null).toBeNull();
  expect(undefined).toBeUndefined();
  expect(true).toBeTruthy();
  expect(false).toBeFalsy();
  
  // Numbers
  expect(10).toBeGreaterThan(5);
  expect(10).toBeLessThanOrEqual(10);
  
  // Strings
  expect('hello').toMatch(/ell/);
  
  // Arrays
  expect([1, 2, 3]).toContain(2);
  
  // Exceptions
  expect(() => { throw new Error('test') }).toThrow('test');
});
```

### Asynchronous Testing

Jest handles different async patterns with ease.

```javascript
// Promises
test('data fetching with promises', () => {
  return fetchData().then(data => {
    expect(data.name).toBe('John');
  });
});

// Async/await
test('data fetching with async/await', async () => {
  const data = await fetchData();
  expect(data.name).toBe('John');
});

// Callbacks with done
test('data fetching with callbacks', done => {
  fetchData(data => {
    try {
      expect(data.name).toBe('John');
      done();
    } catch (error) {
      done(error);
    }
  });
});
```

### Setup and Teardown

Jest provides functions to run code before and after tests.

```javascript
// Per test setup/teardown
beforeEach(() => {
  // Setup code runs before each test
  database.connect();
});

afterEach(() => {
  // Teardown code runs after each test
  database.disconnect();
});

// One-time setup/teardown
beforeAll(() => {
  // Runs once before all tests
  console.log('Starting test suite');
});

afterAll(() => {
  // Runs once after all tests
  console.log('Test suite completed');
});
```

### Mocking

Jest includes a powerful mocking system.

```javascript
// Manual mocks
jest.mock('./database');

// Function mocks
const mockFn = jest.fn();
mockFn.mockReturnValue(42);
// or
mockFn.mockImplementation(value => value * 2);

// Testing mock calls
test('mock function', () => {
  mockFn('a', 'b');
  expect(mockFn).toHaveBeenCalled();
  expect(mockFn).toHaveBeenCalledWith('a', 'b');
  expect(mockFn).toHaveBeenCalledTimes(1);
});

// Spying on object methods
const spy = jest.spyOn(object, 'method');
// Then restore the original implementation
spy.mockRestore();
```

### Snapshot Testing

Jest can save "snapshots" of data structures to compare against future changes.

```javascript
test('renders correctly', () => {
  const tree = renderer.create(<Button>Click me</Button>).toJSON();
  expect(tree).toMatchSnapshot();
});
```

### Coverage Reports

Jest includes built-in code coverage reporting.

```bash
# Run with coverage flag
jest --coverage
```

```javascript
// Or configure in jest.config.js
module.exports = {
  collectCoverage: true,
  coverageReporters: ['text', 'lcov'],
  coverageThreshold: {
    global: {
      branches: 80,
      functions: 80,
      lines: 80,
      statements: 80
    }
  }
};
```

### Mocha Overview

Mocha is a flexible JavaScript test framework that gives developers more choices about which libraries to use with it for assertions, mocking, etc.

#### Core Features of Mocha

### Test Structure

Mocha uses a similar syntax to Jest for defining test suites and cases.

```javascript
// test.js
const assert = require('assert');
const { sum } = require('./math');

// Test suite
describe('Math operations', function() {
  // Test case
  it('adds 1 + 2 to equal 3', function() {
    assert.strictEqual(sum(1, 2), 3);
  });
});
```

### Assertion Libraries

Mocha works with different assertion libraries, with Chai being the most popular.

```javascript
// With Node's assert
const assert = require('assert');
assert.strictEqual(sum(1, 2), 3);

// With Chai
const { expect } = require('chai');
expect(sum(1, 2)).to.equal(3);
expect({name: 'John'}).to.deep.equal({name: 'John'});
expect([1, 2, 3]).to.include(2);
```

### Asynchronous Testing

Mocha provides various ways to test asynchronous code.

```javascript
// Callbacks with done
it('fetches data (callback)', function(done) {
  fetchData(function(err, data) {
    if (err) return done(err);
    expect(data.name).to.equal('John');
    done();
  });
});

// Promises
it('fetches data (promise)', function() {
  return fetchData().then(function(data) {
    expect(data.name).to.equal('John');
  });
});

// Async/await
it('fetches data (async/await)', async function() {
  const data = await fetchData();
  expect(data.name).to.equal('John');
});
```

### Setup and Teardown

Mocha provides hooks similar to Jest.

```javascript
// Per test setup/teardown
beforeEach(function() {
  // Setup code runs before each test
  database.connect();
});

afterEach(function() {
  // Teardown code runs after each test
  database.disconnect();
});

// One-time setup/teardown
before(function() {
  // Runs once before all tests
  console.log('Starting test suite');
});

after(function() {
  // Runs once after all tests
  console.log('Test suite completed');
});
```

### Test Organization

Mocha allows flexible test organization with nested describe blocks.

```javascript
describe('User module', function() {
  describe('registration', function() {
    it('creates new users', function() {
      // test registration
    });
    
    it('validates email format', function() {
      // test email validation
    });
  });
  
  describe('authentication', function() {
    it('validates correct passwords', function() {
      // test password validation
    });
  });
});
```

### Mocking with Sinon

Sinon.js is commonly used with Mocha for mocks, stubs, and spies.

```javascript
const sinon = require('sinon');

describe('Database operations', function() {
  it('saves user data', function() {
    // Create a spy
    const saveSpy = sinon.spy(database, 'save');
    
    userService.createUser('John');
    
    // Assert the spy was called correctly
    sinon.assert.calledOnce(saveSpy);
    sinon.assert.calledWith(saveSpy, { name: 'John' });
    
    // Restore the original method
    saveSpy.restore();
  });
  
  it('handles database errors', function() {
    // Create a stub
    const saveStub = sinon.stub(database, 'save');
    saveStub.throws(new Error('Connection failed'));
    
    // Test error handling
    expect(() => userService.createUser('John')).to.throw('Connection failed');
    
    // Restore the original method
    saveStub.restore();
  });
});
```

### Comparing Jest and Mocha

### Out-of-the-Box Experience

Jest provides an all-in-one solution while Mocha requires additional setup.

```javascript
// Jest setup
// package.json
{
  "scripts": {
    "test": "jest"
  },
  "devDependencies": {
    "jest": "^29.7.0"
  }
}

// Mocha setup
// package.json
{
  "scripts": {
    "test": "mocha"
  },
  "devDependencies": {
    "mocha": "^10.2.0",
    "chai": "^4.3.7",
    "sinon": "^17.0.0"
  }
}
```

### Assertion Style

Jest's expect style vs. Chai's various styles.

```javascript
// Jest
expect(value).toBe(3);
expect(value).toEqual({a: 1});

// Chai - expect style
expect(value).to.equal(3);
expect(value).to.deep.equal({a: 1});

// Chai - should style
value.should.equal(3);
value.should.deep.equal({a: 1});

// Chai - assert style
assert.equal(value, 3);
assert.deepEqual(value, {a: 1});
```

### Mocking Approach

Jest's automatic mocking vs. Sinon's explicit approach.

```javascript
// Jest - automatic mock
jest.mock('./database');
// All exports from database.js are now mock functions

// Jest - manual mock
jest.mock('./database', () => ({
  save: jest.fn(),
  find: jest.fn()
}));

// Sinon - explicit mocks
const sinon = require('sinon');
const database = require('./database');
const saveMock = sinon.stub(database, 'save');
```

### Practical Jest Examples

### Testing Utility Functions

```javascript
// utils.js
function formatCurrency(amount, currency = 'USD') {
  return new Intl.NumberFormat('en-US', {
    style: 'currency',
    currency
  }).format(amount);
}

module.exports = { formatCurrency };

// utils.test.js
const { formatCurrency } = require('./utils');

describe('formatCurrency', () => {
  test('formats USD correctly', () => {
    expect(formatCurrency(1234.56)).toBe('$1,234.56');
  });
  
  test('formats EUR correctly', () => {
    expect(formatCurrency(1234.56, 'EUR')).toBe('€1,234.56');
  });
  
  test('handles zero values', () => {
    expect(formatCurrency(0)).toBe('$0.00');
  });
  
  test('handles negative values', () => {
    expect(formatCurrency(-99.99)).toBe('-$99.99');
  });
});
```

### Testing API Clients

```javascript
// api-client.js
const axios = require('axios');

class UserAPI {
  constructor(baseURL) {
    this.baseURL = baseURL;
  }
  
  async getUser(id) {
    try {
      const response = await axios.get(`${this.baseURL}/users/${id}`);
      return response.data;
    } catch (error) {
      if (error.response && error.response.status === 404) {
        return null;
      }
      throw error;
    }
  }
}

module.exports = UserAPI;

// api-client.test.js
const UserAPI = require('./api-client');
const axios = require('axios');

// Mock axios module
jest.mock('axios');

describe('UserAPI', () => {
  const api = new UserAPI('https://api.example.com');
  
  afterEach(() => {
    jest.resetAllMocks();
  });
  
  test('returns user data on successful response', async () => {
    // Mock successful response
    const userData = { id: 1, name: 'John Doe' };
    axios.get.mockResolvedValue({ data: userData });
    
    // Call the method
    const result = await api.getUser(1);
    
    // Assertions
    expect(axios.get).toHaveBeenCalledWith('https://api.example.com/users/1');
    expect(result).toEqual(userData);
  });
  
  test('returns null when user not found', async () => {
    // Mock 404 response
    axios.get.mockRejectedValue({
      response: { status: 404 }
    });
    
    // Call the method
    const result = await api.getUser(999);
    
    // Assertions
    expect(result).toBeNull();
  });
  
  test('throws other errors', async () => {
    // Mock server error
    const error = new Error('Network error');
    axios.get.mockRejectedValue(error);
    
    // Call and expect exception
    await expect(api.getUser(1)).rejects.toThrow('Network error');
  });
});
```

### Testing React Components with Jest

```javascript
// Button.js
import React from 'react';

export default function Button({ onClick, children }) {
  return (
    <button 
      className="primary-button"
      onClick={onClick}
    >
      {children}
    </button>
  );
}

// Button.test.js
import React from 'react';
import { render, fireEvent } from '@testing-library/react';
import Button from './Button';

describe('Button component', () => {
  test('renders correctly', () => {
    const { getByText } = render(<Button>Click me</Button>);
    const buttonElement = getByText('Click me');
    
    expect(buttonElement).toBeInTheDocument();
    expect(buttonElement).toHaveClass('primary-button');
  });
  
  test('calls onClick handler when clicked', () => {
    const handleClick = jest.fn();
    const { getByText } = render(
      <Button onClick={handleClick}>Click me</Button>
    );
    
    fireEvent.click(getByText('Click me'));
    
    expect(handleClick).toHaveBeenCalledTimes(1);
  });
});
```

### Practical Mocha Examples

### Testing Utility Functions

```javascript
// utils.js
function formatCurrency(amount, currency = 'USD') {
  return new Intl.NumberFormat('en-US', {
    style: 'currency',
    currency
  }).format(amount);
}

module.exports = { formatCurrency };

// utils.test.js
const { expect } = require('chai');
const { formatCurrency } = require('./utils');

describe('formatCurrency', function() {
  it('formats USD correctly', function() {
    expect(formatCurrency(1234.56)).to.equal('$1,234.56');
  });
  
  it('formats EUR correctly', function() {
    expect(formatCurrency(1234.56, 'EUR')).to.equal('€1,234.56');
  });
  
  it('handles zero values', function() {
    expect(formatCurrency(0)).to.equal('$0.00');
  });
  
  it('handles negative values', function() {
    expect(formatCurrency(-99.99)).to.equal('-$99.99');
  });
});
```

### Testing API Clients

```javascript
// api-client.js
const axios = require('axios');

class UserAPI {
  constructor(baseURL) {
    this.baseURL = baseURL;
  }
  
  async getUser(id) {
    try {
      const response = await axios.get(`${this.baseURL}/users/${id}`);
      return response.data;
    } catch (error) {
      if (error.response && error.response.status === 404) {
        return null;
      }
      throw error;
    }
  }
}

module.exports = UserAPI;

// api-client.test.js
const { expect } = require('chai');
const sinon = require('sinon');
const UserAPI = require('./api-client');
const axios = require('axios');

describe('UserAPI', function() {
  const api = new UserAPI('https://api.example.com');
  let axiosStub;
  
  beforeEach(function() {
    // Create stub for axios.get
    axiosStub = sinon.stub(axios, 'get');
  });
  
  afterEach(function() {
    // Restore original method
    axiosStub.restore();
  });
  
  it('returns user data on successful response', async function() {
    // Set up stub response
    const userData = { id: 1, name: 'John Doe' };
    axiosStub.resolves({ data: userData });
    
    // Call the method
    const result = await api.getUser(1);
    
    // Assertions
    expect(axiosStub.calledWith('https://api.example.com/users/1')).to.be.true;
    expect(result).to.deep.equal(userData);
  });
  
  it('returns null when user not found', async function() {
    // Set up stub to simulate 404
    const error = new Error('Not Found');
    error.response = { status: 404 };
    axiosStub.rejects(error);
    
    // Call the method
    const result = await api.getUser(999);
    
    // Assertions
    expect(result).to.be.null;
  });
  
  it('throws other errors', async function() {
    // Set up stub to simulate network error
    const error = new Error('Network error');
    axiosStub.rejects(error);
    
    // Call and expect exception
    try {
      await api.getUser(1);
      // If we get here, fail the test
      expect.fail('Should have thrown an error');
    } catch (e) {
      expect(e.message).to.equal('Network error');
    }
  });
});
```

### Advanced Testing Techniques

### Testing with Custom Matchers

```javascript
// Jest custom matcher
expect.extend({
  toBeWithinRange(received, floor, ceiling) {
    const pass = received >= floor && received <= ceiling;
    if (pass) {
      return {
        message: () => `expected ${received} not to be within range ${floor} - ${ceiling}`,
        pass: true
      };
    } else {
      return {
        message: () => `expected ${received} to be within range ${floor} - ${ceiling}`,
        pass: false
      };
    }
  }
});

test('numeric ranges', () => {
  expect(100).toBeWithinRange(90, 110);
  expect(101).not.toBeWithinRange(0, 100);
});
```

### Parameterized Tests

```javascript
// Jest - using test.each
const calculate = (a, b, operation) => {
  switch (operation) {
    case 'add': return a + b;
    case 'subtract': return a - b;
    case 'multiply': return a * b;
    case 'divide': return a / b;
    default: throw new Error('Unknown operation');
  }
};

test.each([
  [1, 1, 'add', 2],
  [2, 1, 'subtract', 1],
  [2, 3, 'multiply', 6],
  [6, 2, 'divide', 3]
])('calculate(%i, %i, %s) => %i', (a, b, operation, expected) => {
  expect(calculate(a, b, operation)).toBe(expected);
});

// Mocha - with dynamic tests
const operations = [
  { a: 1, b: 1, op: 'add', expected: 2 },
  { a: 2, b: 1, op: 'subtract', expected: 1 },
  { a: 2, b: 3, op: 'multiply', expected: 6 },
  { a: 6, b: 2, op: 'divide', expected: 3 }
];

describe('Calculator', function() {
  operations.forEach(({ a, b, op, expected }) => {
    it(`${op}(${a}, ${b}) should equal ${expected}`, function() {
      expect(calculate(a, b, op)).to.equal(expected);
    });
  });
});
```

### Testing File Operations

```javascript
// Jest - with mock file system
const fs = require('fs');
const { readConfig } = require('./config');

jest.mock('fs');

test('reads configuration file', () => {
  // Setup mock implementation
  fs.readFileSync.mockReturnValue(JSON.stringify({
    apiUrl: 'https://api.example.com',
    timeout: 5000
  }));
  
  const config = readConfig('config.json');
  
  expect(fs.readFileSync).toHaveBeenCalledWith('config.json', 'utf8');
  expect(config).toEqual({
    apiUrl: 'https://api.example.com',
    timeout: 5000
  });
});
```

### Best Practices for Unit Testing

### Write Pure Tests

Write tests that are deterministic and don't depend on external state.

```javascript
// Bad - depends on current date
test('formats today's date', () => {
  const formatter = new DateFormatter();
  expect(formatter.formatToday()).toBe('2024-05-01');
});

// Good - mock date to make test deterministic
test('formats today's date', () => {
  // Mock Date to return fixed value
  const realDate = Date;
  global.Date = class extends Date {
    constructor() {
      super();
      return new realDate('2024-05-01');
    }
  };
  
  const formatter = new DateFormatter();
  expect(formatter.formatToday()).toBe('2024-05-01');
  
  // Restore original Date
  global.Date = realDate;
});
```

### Test Coverage

Aim for high but practical test coverage.

```javascript
// Jest coverage configuration
// jest.config.js
module.exports = {
  collectCoverage: true,
  coverageReporters: ['text', 'lcov', 'html'],
  coverageThreshold: {
    global: {
      branches: 80,
      functions: 85,
      lines: 90,
      statements: 90
    }
  }
};
```

### Focus on Behavior, Not Implementation

Test what code does, not how it does it.

```javascript
// Bad - tests implementation details
test('_processData is called during save', () => {
  const spy = jest.spyOn(user, '_processData');
  user.save();
  expect(spy).toHaveBeenCalled();
});

// Good - tests observable behavior
test('data is saved in correct format', () => {
  const db = mockDatabase();
  user.save();
  expect(db.lastInsertedData).toEqual({
    name: 'John',
    createdAt: expect.any(Date)
  });
});
```

### Organize Tests by Feature

Structure tests to match application architecture.

```
src/
  features/
    auth/
      auth.js
      auth.test.js
    users/
      users.js
      users.test.js
```

### Isolate Testing Environment

Reset state between tests to avoid interference.

```javascript
// Good test isolation
describe('ShoppingCart', () => {
  let cart;
  
  beforeEach(() => {
    // Fresh instance for each test
    cart = new ShoppingCart();
  });
  
  test('adds items', () => {
    cart.add({ id: 1, price: 10 });
    expect(cart.getItemCount()).toBe(1);
  });
  
  test('calculates total', () => {
    cart.add({ id: 1, price: 10 });
    cart.add({ id: 2, price: 20 });
    expect(cart.getTotal()).toBe(30);
  });
});
```

### Real-world Test Setups

### Jest Setup for Node.js Project

```
// Directory structure
project/
  src/
    utils/
      math.js
      string.js
    models/
      user.js
  tests/
    utils/
      math.test.js
      string.test.js
    models/
      user.test.js
  jest.config.js
  package.json
```

```javascript
// jest.config.js
module.exports = {
  testEnvironment: 'node',
  testMatch: ['**/tests/**/*.test.js'],
  collectCoverage: true,
  coverageDirectory: 'coverage',
  verbose: true
};

// package.json
{
  "scripts": {
    "test": "jest",
    "test:watch": "jest --watch",
    "test:coverage": "jest --coverage"
  }
}
```

### Mocha Setup for Node.js Project

```
// Directory structure
project/
  src/
    utils/
      math.js
      string.js
    models/
      user.js
  test/
    utils/
      math.test.js
      string.test.js
    models/
      user.test.js
    mocha.opts
  .mocharc.js
  package.json
```

```javascript
// .mocharc.js
module.exports = {
  spec: 'test/**/*.test.js',
  recursive: true,
  require: ['chai/register-expect']
};

// package.json
{
  "scripts": {
    "test": "mocha",
    "test:watch": "mocha --watch",
    "test:coverage": "nyc mocha"
  }
}
```

### Jest Setup for React Application

```javascript
// jest.config.js for React
module.exports = {
  testEnvironment: 'jsdom',
  setupFilesAfterEnv: ['<rootDir>/setupTests.js'],
  moduleNameMapper: {
    '\\.(css|less|scss)$': 'identity-obj-proxy',
    '\\.(jpg|jpeg|png|gif)$': '<rootDir>/__mocks__/fileMock.js'
  },
  transform: {
    '^.+\\.(js|jsx|ts|tsx)$': 'babel-jest'
  }
};

// setupTests.js
import '@testing-library/jest-dom';
```

**Conclusion:** Jest and Mocha are both powerful frameworks for unit testing JavaScript applications. Jest offers an all-in-one solution with built-in assertion, mocking, and coverage reporting, making it ideal for beginners and React projects. Mocha provides more flexibility with interchangeable libraries, which appeals to developers who want more control over their testing stack. Regardless of which framework you choose, following best practices like test isolation, behavior-focused testing, and aiming for high coverage will lead to more maintainable and robust applications.

Important related topics to consider:

- Integration testing strategies to complement unit tests
- End-to-end testing with tools like Cypress or Playwright
- Testing TypeScript applications with Jest and Mocha
- Continuous integration strategies for automated testing

---

