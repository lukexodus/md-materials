## Testing TypeScript Code


### Understanding TypeScript Testing Fundamentals

TypeScript brings static type checking to JavaScript, but ensuring your code works as expected still requires thorough testing. Testing TypeScript code combines traditional JavaScript testing approaches with additional considerations for type safety and integration.

### Setting Up Your Testing Environment

#### Prerequisites

Before writing tests for TypeScript code, you need to set up your development environment properly:

- TypeScript compiler (`tsc`)
- A testing framework compatible with TypeScript
- Types for your testing libraries
- TypeScript configuration (`tsconfig.json`) with proper test settings

#### Basic Configuration

A typical `tsconfig.json` for testing might include:

```json
{
  "compilerOptions": {
    "target": "es2016",
    "module": "commonjs",
    "esModuleInterop": true,
    "forceConsistentCasingInFileNames": true,
    "strict": true,
    "skipLibCheck": true,
    "outDir": "./dist",
    "rootDir": "./src",
    "types": ["jest", "node"]
  },
  "include": ["src/**/*", "tests/**/*"],
  "exclude": ["node_modules"]
}
```

### Unit Testing with Jest

Jest is one of the most popular testing frameworks for TypeScript projects due to its simplicity and powerful features.

#### Setting Up Jest for TypeScript

To set up Jest with TypeScript:

1. Install required packages:

```bash
npm install --save-dev jest @types/jest ts-jest
```

2. Create a Jest configuration file (`jest.config.js`):

```javascript
module.exports = {
  preset: 'ts-jest',
  testEnvironment: 'node',
  roots: ['<rootDir>/src/', '<rootDir>/tests/'],
  testMatch: ['**/__tests__/**/*.ts?(x)', '**/?(*.)+(spec|test).ts?(x)'],
  transform: {
    '^.+\\.tsx?$': 'ts-jest',
  },
};
```

#### Writing Your First Jest Test

Here's an example of a simple TypeScript function and its test:

```typescript
// src/math.ts
export function add(a: number, b: number): number {
  return a + b;
}
```

```typescript
// tests/math.test.ts
import { add } from '../src/math';

describe('Math functions', () => {
  it('should add two numbers correctly', () => {
    expect(add(1, 2)).toBe(3);
    expect(add(-1, 1)).toBe(0);
    expect(add(5, 5)).toBe(10);
  });
});
```

#### Jest Best Practices for TypeScript

- Group related tests using `describe` blocks
- Use specific test names that describe the expected behavior
- Test edge cases and error conditions
- Use beforeEach/afterEach for setup and teardown
- Leverage type information in your test assertions

### Using Mocha with TypeScript

Mocha is another popular testing framework that works well with TypeScript.

#### Setting Up Mocha

1. Install required packages:

```bash
npm install --save-dev mocha @types/mocha ts-node chai @types/chai
```

2. Add a test script to your `package.json`:

```json
{
  "scripts": {
    "test": "mocha -r ts-node/register 'tests/**/*.ts'"
  }
}
```

#### Writing Mocha Tests

```typescript
// tests/example.test.ts
import { expect } from 'chai';
import { add } from '../src/math';

describe('Math functions', function() {
  it('should add two numbers correctly', function() {
    expect(add(1, 2)).to.equal(3);
    expect(add(-1, 1)).to.equal(0);
    expect(add(5, 5)).to.equal(10);
  });
});
```

### Type Testing Libraries

Type testing in TypeScript ensures that your types work as expected, which is an additional layer of verification unique to statically typed languages.

#### Using ts-expect

The `ts-expect` library enables type assertions in your tests:

```bash
npm install --save-dev ts-expect
```

```typescript
import { expectType } from 'ts-expect';
import { add } from '../src/math';

describe('Type checking', () => {
  it('should verify function return types', () => {
    expectType<number>(add(1, 2));
  });
});
```

#### TypeScript-specific Testing with dtslint

For library authors, `dtslint` tests the accuracy of your TypeScript declaration files:

```bash
npm install --save-dev dtslint
```

Create test files in a `types` directory with assertions like:

```typescript
// $ExpectType number
add(1, 2);

// $ExpectError
add('1', 2);
```

#### Using tsd for Type Assertions

The `tsd` package provides utilities for testing TypeScript types:

```bash
npm install --save-dev tsd
```

```typescript
import { expectType, expectError } from 'tsd';

// Verify return type
expectType<number>(add(1, 2));

// Verify compile-time errors
expectError(add('1', 2));
```

### Test-Driven Development with TypeScript

Test-Driven Development (TDD) with TypeScript follows the same principles as traditional TDD but with an added focus on types.

#### The TDD Cycle for TypeScript

1. Write a failing test that defines the expected behavior and types
2. Implement the minimal code to make the test pass
3. Refactor while keeping tests passing
4. Repeat

#### TDD Example in TypeScript

Let's implement a simple user authentication function using TDD:

1. Write the test first:

```typescript
// tests/auth.test.ts
import { expect } from 'chai';
import { authenticateUser } from '../src/auth';
import { User } from '../src/types';

describe('User Authentication', () => {
  it('should authenticate valid users', async () => {
    const result = await authenticateUser('user@example.com', 'correct-password');
    expect(result.success).to.be.true;
    expect(result.user).to.have.property('email', 'user@example.com');
  });

  it('should reject invalid credentials', async () => {
    const result = await authenticateUser('user@example.com', 'wrong-password');
    expect(result.success).to.be.false;
    expect(result.user).to.be.null;
    expect(result.error).to.equal('Invalid credentials');
  });
});
```

2. Define types:

```typescript
// src/types.ts
export interface User {
  id: string;
  email: string;
  name: string;
}

export interface AuthResult {
  success: boolean;
  user: User | null;
  error?: string;
}
```

3. Implement the function:

```typescript
// src/auth.ts
import { User, AuthResult } from './types';

export async function authenticateUser(
  email: string, 
  password: string
): Promise<AuthResult> {
  // In a real app, this would verify against a database
  if (email === 'user@example.com' && password === 'correct-password') {
    return {
      success: true,
      user: {
        id: '123',
        email: 'user@example.com',
        name: 'Test User'
      }
    };
  }
  
  return {
    success: false,
    user: null,
    error: 'Invalid credentials'
  };
}
```

#### Benefits of TDD with TypeScript

- Designs the API and type interfaces before implementation
- Catches type errors during development
- Creates living documentation of expected behavior
- Provides confidence when refactoring

### Integration Tests

Integration tests verify that different components of your application work correctly together.

#### Testing TypeScript Applications

For a typical web application, integration tests might include:

- API endpoint testing
- Database interaction testing
- Service integration testing
- External dependency testing

#### Using Supertest for API Testing

For testing HTTP endpoints:

```bash
npm install --save-dev supertest @types/supertest
```

```typescript
// tests/api.test.ts
import request from 'supertest';
import { app } from '../src/app';

describe('User API', () => {
  it('should return user information', async () => {
    const response = await request(app)
      .get('/api/users/123')
      .expect('Content-Type', /json/)
      .expect(200);
    
    expect(response.body).to.have.property('id', '123');
    expect(response.body).to.have.property('email');
  });
});
```

#### Testing Database Interactions

For database integration testing:

```typescript
import { expect } from 'chai';
import { UserRepository } from '../src/repositories/userRepository';
import { DatabaseConnection } from '../src/database';

describe('User Repository', () => {
  let db: DatabaseConnection;
  let repository: UserRepository;
  
  before(async () => {
    db = await DatabaseConnection.create('test-database');
    repository = new UserRepository(db);
  });
  
  afterEach(async () => {
    await db.collection('users').deleteMany({});
  });
  
  after(async () => {
    await db.close();
  });
  
  it('should create and retrieve a user', async () => {
    const user = {
      email: 'test@example.com',
      name: 'Test User'
    };
    
    const id = await repository.createUser(user);
    const retrieved = await repository.getUserById(id);
    
    expect(retrieved).to.not.be.null;
    expect(retrieved?.email).to.equal(user.email);
    expect(retrieved?.name).to.equal(user.name);
  });
});
```

### Mocking in TypeScript Tests

Mocking is essential for isolating the code under test from its dependencies.

#### Using Jest Mocks

```typescript
import { UserService } from '../src/services/userService';
import { UserRepository } from '../src/repositories/userRepository';

jest.mock('../src/repositories/userRepository');

describe('UserService', () => {
  beforeEach(() => {
    jest.resetAllMocks();
  });

  it('should get user by id', async () => {
    const mockUser = { id: '123', name: 'Test User', email: 'test@example.com' };
    (UserRepository.prototype.getUserById as jest.Mock).mockResolvedValue(mockUser);
    
    const service = new UserService(new UserRepository());
    const user = await service.getUserById('123');
    
    expect(user).toEqual(mockUser);
    expect(UserRepository.prototype.getUserById).toHaveBeenCalledWith('123');
  });
});
```

#### Type-Safe Mocking with ts-mockito

For more type-safe mocking:

```bash
npm install --save-dev ts-mockito
```

```typescript
import { instance, mock, verify, when } from 'ts-mockito';
import { UserService } from '../src/services/userService';
import { UserRepository } from '../src/repositories/userRepository';

describe('UserService with ts-mockito', () => {
  it('should get user by id', async () => {
    // Create a mock with type safety
    const mockedRepo = mock(UserRepository);
    const mockUser = { id: '123', name: 'Test User', email: 'test@example.com' };
    
    // Configure the mock
    when(mockedRepo.getUserById('123')).thenResolve(mockUser);
    
    // Create an instance from the mock
    const service = new UserService(instance(mockedRepo));
    const user = await service.getUserById('123');
    
    expect(user).toEqual(mockUser);
    verify(mockedRepo.getUserById('123')).once();
  });
});
```

### Testing Asynchronous Code

TypeScript projects often involve asynchronous operations that require special testing approaches.

#### Testing Promises

```typescript
it('should resolve with user data', async () => {
  const user = await userService.fetchUserData(123);
  expect(user.id).to.equal(123);
});

it('should reject with an error for invalid users', async () => {
  try {
    await userService.fetchUserData(-1);
    expect.fail('Should have thrown an error');
  } catch (error) {
    expect(error.message).to.include('Invalid user ID');
  }
});
```

#### Testing with Async/Await

```typescript
it('handles async operations correctly', async () => {
  const result = await asyncFunction();
  expect(result).to.equal('expected value');
});
```

### Code Coverage for TypeScript

Measuring test coverage helps identify untested code paths.

#### Setting Up Coverage with Jest

```javascript
// jest.config.js
module.exports = {
  preset: 'ts-jest',
  testEnvironment: 'node',
  collectCoverage: true,
  coverageDirectory: 'coverage',
  coverageReporters: ['text', 'lcov', 'html'],
  collectCoverageFrom: [
    'src/**/*.ts',
    '!src/**/*.d.ts',
    '!src/index.ts',
    '!**/node_modules/**',
  ],
  coverageThreshold: {
    global: {
      branches: 80,
      functions: 80,
      lines: 80,
      statements: 80,
    },
  },
};
```

#### Interpreting Coverage Reports

- Look for uncovered branches and functions
- Focus on complex logic and error-handling paths
- Set coverage thresholds in CI to prevent regressions

### Testing TypeScript React Components

For frontend applications, testing TypeScript React components requires additional setup.

#### Setting Up React Testing Library

```bash
npm install --save-dev @testing-library/react @testing-library/jest-dom
```

```typescript
// tests/Button.test.tsx
import React from 'react';
import { render, fireEvent, screen } from '@testing-library/react';
import '@testing-library/jest-dom';
import { Button } from '../src/components/Button';

describe('Button Component', () => {
  it('renders with correct text', () => {
    render(<Button text="Click me" onClick={() => {}} />);
    expect(screen.getByText('Click me')).toBeInTheDocument();
  });

  it('calls onClick handler when clicked', () => {
    const handleClick = jest.fn();
    render(<Button text="Click me" onClick={handleClick} />);
    fireEvent.click(screen.getByText('Click me'));
    expect(handleClick).toHaveBeenCalledTimes(1);
  });
});
```

### Advanced Testing Patterns

#### Snapshot Testing

Snapshot testing is useful for UI components or complex objects:

```typescript
it('should match the previous snapshot', () => {
  const user = userService.createUser('John', 'Doe');
  expect(user).toMatchSnapshot();
});
```

#### Parameterized Tests

Using Jest's `test.each` for data-driven tests:

```typescript
test.each([
  [1, 1, 2],
  [2, 2, 4],
  [0, 5, 5],
])('add(%i, %i) = %i', (a, b, expected) => {
  expect(add(a, b)).toBe(expected);
});
```

#### Property-Based Testing

Using `fast-check` for property-based testing:

```bash
npm install --save-dev fast-check
```

```typescript
import * as fc from 'fast-check';

it('should always return a string that includes the input', () => {
  fc.assert(
    fc.property(fc.string(), (input) => {
      const result = formatText(input);
      return result.includes(input);
    })
  );
});
```

### Testing Performance

#### Benchmarking with benchmark.js

```bash
npm install --save-dev benchmark @types/benchmark
```

```typescript
import Benchmark from 'benchmark';

const suite = new Benchmark.Suite;

suite
  .add('Method A', () => {
    methodA();
  })
  .add('Method B', () => {
    methodB();
  })
  .on('cycle', (event: Benchmark.Event) => {
    console.log(String(event.target));
  })
  .on('complete', function(this: Benchmark.Suite) {
    console.log('Fastest is ' + this.filter('fastest').map('name'));
  })
  .run({ 'async': true });
```

### Continuous Integration for TypeScript Tests

Integrating tests into CI pipelines ensures code quality across the team.

#### GitHub Actions Example

```yaml
# .github/workflows/test.yml
name: Run Tests

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Node.js
      uses: actions/setup-node@v3
      with:
        node-version: '16'
        cache: 'npm'
    
    - name: Install dependencies
      run: npm ci
    
    - name: Run tests
      run: npm test
    
    - name: Upload coverage reports
      uses: codecov/codecov-action@v3
      with:
        file: ./coverage/lcov.info
```

### Testing Best Practices for TypeScript

**Key Points:**

- Write tests that verify both behavior and types
- Follow the AAA pattern: Arrange, Act, Assert
- Test edge cases and error handling paths
- Separate unit tests from integration tests
- Use descriptive test names that explain behavior
- Avoid testing implementation details
- Mock external dependencies
- Maintain high test coverage, especially for complex logic
- Make tests deterministic and repeatable
- Keep tests fast for quick feedback

### Debugging TypeScript Tests

#### Using VS Code for Debugging Tests

Create a `.vscode/launch.json` file:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "type": "node",
      "request": "launch",
      "name": "Debug Jest Tests",
      "program": "${workspaceFolder}/node_modules/.bin/jest",
      "args": [
        "--runInBand",
        "--testMatch",
        "**/tests/**/*.test.ts"
      ],
      "console": "integratedTerminal",
      "internalConsoleOptions": "neverOpen",
      "disableOptimisticBPs": true
    }
  ]
}
```

#### Troubleshooting Common Issues

- Type mismatches between tests and implementation
- Missing type definitions for testing libraries
- Configuration issues with tsconfig or jest config
- Mocking modules that are imported as types

### Recommended Related Topics

- End-to-End Testing with Cypress and TypeScript
- Visual Regression Testing for TypeScript Applications
- Advanced Type Testing Techniques
- Testing GraphQL APIs with TypeScript
- Performance Testing Strategies for TypeScript Applications

---

