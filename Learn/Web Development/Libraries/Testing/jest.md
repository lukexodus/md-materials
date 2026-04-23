# Comprehensive Guide to Jest

---

## What is Jest?

Jest is a JavaScript testing framework developed and maintained by Meta (formerly Facebook). It is designed to work with minimal configuration and supports projects using Babel, TypeScript, Node.js, React, Angular, Vue, and more.

Key characteristics:

- **Zero-config** for most JavaScript projects
- **Isolated test environments** using Node.js `vm` module per test file
- **Built-in mocking**, assertion, and coverage tooling
- **Watch mode** for re-running tests on file changes
- **Snapshot testing** for UI components and serializable values

---

## Installation and Setup

### Basic Installation

```bash
npm install --save-dev jest
```

### With Babel (for ESModules / JSX)

```bash
npm install --save-dev jest babel-jest @babel/core @babel/preset-env
```

Create a `babel.config.js`:

```js
module.exports = {
  presets: [['@babel/preset-env', { targets: { node: 'current' } }]],
};
```

### With TypeScript

```bash
npm install --save-dev jest ts-jest @types/jest typescript
```

Initialize `ts-jest` config:

```bash
npx ts-jest config:init
```

### With React (using Create React App)

CRA includes Jest preconfigured. No additional setup is required for basic use.

### Add a Test Script

In `package.json`:

```json
{
  "scripts": {
    "test": "jest",
    "test:watch": "jest --watch",
    "test:coverage": "jest --coverage"
  }
}
```

---

## Project Configuration

Jest can be configured via `jest.config.js`, `jest.config.ts`, or the `"jest"` key in `package.json`.

### jest.config.js (Common Options)

```js
/** @type {import('jest').Config} */
module.exports = {
  // Test environment
  testEnvironment: 'node', // or 'jsdom' for browser-like environments

  // File patterns Jest will look for
  testMatch: ['**/__tests__/**/*.[jt]s?(x)', '**/?(*.)+(spec|test).[jt]s?(x)'],

  // Transform files before running
  transform: {
    '^.+\\.tsx?$': 'ts-jest',
  },

  // Module name mapper (e.g. for path aliases or static assets)
  moduleNameMapper: {
    '^@/(.*)$': '<rootDir>/src/$1',
    '\\.(css|scss)$': '<rootDir>/__mocks__/fileMock.js',
  },

  // Collect coverage from these files
  collectCoverageFrom: ['src/**/*.{js,ts,jsx,tsx}', '!src/**/*.d.ts'],

  // Setup files run before the test framework is installed
  setupFiles: ['<rootDir>/jest.setup.js'],

  // Setup files run after the test framework is installed
  setupFilesAfterFramework: ['<rootDir>/jest.setupAfterFramework.js'],

  // Coverage thresholds
  coverageThreshold: {
    global: {
      branches: 80,
      functions: 80,
      lines: 80,
      statements: 80,
    },
  },

  // Roots for module resolution
  roots: ['<rootDir>/src'],
};
```

### testEnvironment Options

|Value|Use Case|
|---|---|
|`node`|Server-side code, APIs (default)|
|`jsdom`|Browser-like DOM testing (React, Vue, etc.)|

---

## Writing Tests

### Test File Naming Conventions

Jest picks up files matching:

- `*.test.js` / `*.test.ts`
- `*.spec.js` / `*.spec.ts`
- Files inside `__tests__/` directories

### Basic Structure

```js
// math.js
function add(a, b) {
  return a + b;
}
module.exports = { add };
```

```js
// math.test.js
const { add } = require('./math');

describe('add()', () => {
  test('adds two positive numbers', () => {
    expect(add(2, 3)).toBe(5);
  });

  test('returns a negative number when sum is negative', () => {
    expect(add(-2, -3)).toBe(-5);
  });
});
```

### `test` vs `it`

`test` and `it` are aliases. Both are valid; use whichever reads more naturally:

```js
test('returns 5 for add(2, 3)', () => { ... });
it('returns 5 for add(2, 3)', () => { ... });
```

### `describe` Blocks

`describe` groups related tests and can be nested:

```js
describe('Calculator', () => {
  describe('add()', () => {
    test('adds positive numbers', () => { ... });
    test('adds negative numbers', () => { ... });
  });

  describe('subtract()', () => {
    test('subtracts numbers', () => { ... });
  });
});
```

### Skipping and Isolating Tests

```js
test.skip('this test is skipped', () => { ... });
test.only('only this test runs in this file', () => { ... });

describe.skip('skip this group', () => { ... });
describe.only('only run this group', () => { ... });
```

---

## Matchers

Matchers are methods on the `expect()` object used to assert values.

### Equality

```js
expect(value).toBe(4);           // Strict equality (===)
expect(value).toEqual({ a: 1 }); // Deep equality (objects/arrays)
expect(value).not.toBe(5);       // Negation
```

### Truthiness

```js
expect(value).toBeTruthy();
expect(value).toBeFalsy();
expect(value).toBeNull();
expect(value).toBeUndefined();
expect(value).toBeDefined();
```

### Numbers

```js
expect(value).toBeGreaterThan(3);
expect(value).toBeGreaterThanOrEqual(3);
expect(value).toBeLessThan(5);
expect(value).toBeLessThanOrEqual(5);
expect(0.1 + 0.2).toBeCloseTo(0.3, 5); // Floating point precision
```

### Strings

```js
expect('hello world').toMatch(/world/);
expect('hello world').toMatch('world');
expect('hello world').toContain('hello');
```

### Arrays and Iterables

```js
expect([1, 2, 3]).toContain(2);
expect([{ a: 1 }]).toContainEqual({ a: 1 }); // Deep match inside array
expect([1, 2, 3]).toHaveLength(3);
```

### Objects

```js
expect({ a: 1, b: 2 }).toMatchObject({ a: 1 }); // Partial match
expect({ a: 1 }).toHaveProperty('a');
expect({ a: 1 }).toHaveProperty('a', 1);
```

### Errors

```js
function badFn() {
  throw new Error('oops');
}

expect(badFn).toThrow();
expect(badFn).toThrow('oops');
expect(badFn).toThrow(/oops/);
expect(badFn).toThrow(Error);
```

### Custom Matchers with `expect.extend`

```js
expect.extend({
  toBeWithinRange(received, floor, ceiling) {
    const pass = received >= floor && received <= ceiling;
    return {
      pass,
      message: () =>
        `expected ${received} ${pass ? 'not ' : ''}to be within range ${floor}–${ceiling}`,
    };
  },
});

test('custom matcher', () => {
  expect(7).toBeWithinRange(5, 10);
});
```

---

## Asynchronous Testing

### Callbacks

Use the `done` parameter to signal test completion:

```js
test('async with callback', (done) => {
  fetchData((data) => {
    expect(data).toBe('peanut butter');
    done();
  });
});
```

### Promises

Return the promise from the test:

```js
test('async with promise', () => {
  return fetchData().then((data) => {
    expect(data).toBe('peanut butter');
  });
});
```

Or use `.resolves` / `.rejects` matchers:

```js
test('resolves to peanut butter', () => {
  return expect(fetchData()).resolves.toBe('peanut butter');
});

test('rejects with error', () => {
  return expect(fetchData()).rejects.toThrow('error');
});
```

### Async/Await

```js
test('async/await success', async () => {
  const data = await fetchData();
  expect(data).toBe('peanut butter');
});

test('async/await error', async () => {
  await expect(fetchData()).rejects.toThrow('error');
});
```

---

## Mock Functions

Mock functions let you spy on calls, replace implementations, and control return values.

### Creating a Mock

```js
const mockFn = jest.fn();

mockFn('hello');

expect(mockFn).toHaveBeenCalled();
expect(mockFn).toHaveBeenCalledTimes(1);
expect(mockFn).toHaveBeenCalledWith('hello');
```

### Return Values

```js
const mockFn = jest.fn();

mockFn.mockReturnValue(42);
mockFn.mockReturnValueOnce(100); // Only for the next call

const mockAsync = jest.fn();
mockAsync.mockResolvedValue({ data: 'ok' });
mockAsync.mockRejectedValue(new Error('fail'));
```

### Mock Implementations

```js
const mockFn = jest.fn((x) => x * 2);

// Or:
mockFn.mockImplementation((x) => x * 2);
mockFn.mockImplementationOnce((x) => x * 3); // Only for next call
```

### Spying on Existing Functions

```js
const obj = { greet: () => 'hello' };
const spy = jest.spyOn(obj, 'greet');

obj.greet();

expect(spy).toHaveBeenCalled();

spy.mockRestore(); // Restores the original implementation
```

### Clearing and Resetting Mocks

```js
mockFn.mockClear();   // Clears call history only
mockFn.mockReset();   // Clears call history and implementation
mockFn.mockRestore(); // Restores original (only works with spyOn)
```

You can automate this in config:

```js
// jest.config.js
module.exports = {
  clearMocks: true,   // Clears mocks between tests
  resetMocks: true,   // Resets mocks between tests
  restoreMocks: true, // Restores mocks between tests
};
```

---

## Mocking Modules

### Auto-mocking

```js
jest.mock('./myModule');
// All exports become jest.fn() automatically
```

### Manual Mock with Factory

```js
jest.mock('./myModule', () => ({
  fetchUser: jest.fn(() => Promise.resolve({ id: 1, name: 'Alice' })),
}));
```

### Manual Mocks (`__mocks__` Directory)

Place a file at `__mocks__/myModule.js` adjacent to the module, then call `jest.mock('./myModule')` in your test and Jest will use the manual mock automatically.

For node_modules, place the file at `<rootDir>/__mocks__/moduleName.js` — Jest uses it without an explicit `jest.mock()` call.

### Mocking ES Modules

With Babel or `ts-jest`, standard `jest.mock()` works. For native ESM support, Jest's ESM mode is required (currently experimental as of Jest 29).

### Partial Mocking

```js
jest.mock('./utils', () => {
  const originalModule = jest.requireActual('./utils');
  return {
    ...originalModule,
    onlyThisFunction: jest.fn(() => 'mocked'),
  };
});
```

### Mocking Timers

```js
jest.useFakeTimers();

test('delays with setTimeout', () => {
  const callback = jest.fn();
  setTimeout(callback, 1000);

  jest.runAllTimers(); // Fast-forwards all timers
  expect(callback).toHaveBeenCalledTimes(1);
});

afterEach(() => {
  jest.useRealTimers();
});
```

---

## Setup and Teardown

### Scoped to a File

```js
beforeAll(() => {
  // Runs once before all tests in this file
});

afterAll(() => {
  // Runs once after all tests in this file
});

beforeEach(() => {
  // Runs before each test in this file
});

afterEach(() => {
  // Runs after each test in this file
});
```

### Scoped to a `describe` Block

Lifecycle hooks inside `describe` only apply to tests within that block:

```js
describe('Database tests', () => {
  beforeEach(() => {
    db.connect();
  });

  afterEach(() => {
    db.disconnect();
  });

  test('reads data', () => { ... });
});
```

### Global Setup and Teardown

For expensive operations shared across all test files (e.g. starting a server), use `globalSetup` and `globalTeardown` in your config:

```js
// jest.config.js
module.exports = {
  globalSetup: '<rootDir>/jest.globalSetup.js',
  globalTeardown: '<rootDir>/jest.globalTeardown.js',
};
```

```js
// jest.globalSetup.js
module.exports = async () => {
  global.__SERVER__ = await startServer();
};
```

---

## Snapshot Testing

Snapshots capture a serialized value and compare it on subsequent runs. If the output changes unexpectedly, the test fails.

### Basic Snapshot

```js
test('renders correctly', () => {
  const tree = renderer.create(<Button label="Click me" />).toJSON();
  expect(tree).toMatchSnapshot();
});
```

The first run creates a `.snap` file in `__snapshots__/`. Subsequent runs compare against it.

### Updating Snapshots

```bash
jest --updateSnapshot
# or
jest -u
```

Only update snapshots after intentionally changing the output.

### Inline Snapshots

```js
expect({ name: 'Alice' }).toMatchInlineSnapshot(`
  Object {
    "name": "Alice",
  }
`);
```

The snapshot is written directly into the test file.

### When to Use Snapshots

Snapshots are well-suited for: component render output, serialized data structures, and CLI output. They are less suitable for frequently changing output or large objects where diffs are hard to review.

---

## Code Coverage

### Running Coverage

```bash
jest --coverage
```

Jest uses Istanbul (v8 or Babel plugin) under the hood.

### Coverage Report Output

By default, coverage is reported in the terminal and as HTML in `coverage/`. Open `coverage/lcov-report/index.html` in a browser for a detailed view.

### Coverage Providers

```js
// jest.config.js
module.exports = {
  coverageProvider: 'v8',   // Default; faster
  // coverageProvider: 'babel', // More accurate for transformed code
};
```

### Coverage Thresholds

Fail the test run if coverage drops below a defined threshold:

```js
coverageThreshold: {
  global: {
    branches: 80,
    functions: 80,
    lines: 80,
    statements: 80,
  },
  './src/critical.js': {
    lines: 100,
  },
},
```

### Coverage Reporters

```js
coverageReporters: ['text', 'lcov', 'json-summary'],
```

---

## Testing React Components

### With React Testing Library (Recommended)

```bash
npm install --save-dev @testing-library/react @testing-library/jest-dom
```

Add to `setupFilesAfterFramework`:

```js
// jest.setup.js
import '@testing-library/jest-dom';
```

```jsx
// Button.test.jsx
import { render, screen, fireEvent } from '@testing-library/react';
import Button from './Button';

test('renders with label and handles click', () => {
  const handleClick = jest.fn();
  render(<Button label="Submit" onClick={handleClick} />);

  const btn = screen.getByRole('button', { name: /submit/i });
  expect(btn).toBeInTheDocument();

  fireEvent.click(btn);
  expect(handleClick).toHaveBeenCalledTimes(1);
});
```

### Common RTL Queries

|Query|Use Case|
|---|---|
|`getByRole`|Preferred; queries by ARIA role|
|`getByText`|Queries by visible text|
|`getByLabelText`|Form inputs associated with a label|
|`getByPlaceholderText`|Input placeholder|
|`getByTestId`|Fallback using `data-testid`|

Variants: `getBy*` (throws if not found), `queryBy*` (returns null), `findBy*` (async, returns promise).

### Async Component Testing

```jsx
test('loads and displays data', async () => {
  render(<UserProfile userId={1} />);

  expect(screen.getByText(/loading/i)).toBeInTheDocument();

  const name = await screen.findByText('Alice');
  expect(name).toBeInTheDocument();
});
```

### With Enzyme (Alternative, Less Common)

Enzyme is less commonly used in new projects and has lagged behind React version support. React Testing Library is the more widely recommended choice for new projects as of 2024.

---

## Running Tests

### Common CLI Commands

```bash
# Run all tests
jest

# Run tests matching a pattern
jest user

# Run a specific file
jest src/utils/math.test.js

# Watch mode (re-runs on change)
jest --watch

# Watch all files
jest --watchAll

# Run with coverage
jest --coverage

# Run in band (serially, useful for debugging)
jest --runInBand

# Show verbose output
jest --verbose

# Update snapshots
jest --updateSnapshot

# Run only tests that failed last time
jest --onlyFailures

# Pass additional config inline
jest --testEnvironment jsdom
```

### Filtering by Test Name

```bash
jest -t "adds two numbers"
```

---

## Debugging Tests

### Using `--runInBand`

Running tests serially prevents interference from parallelism:

```bash
jest --runInBand
```

### Using Node Inspector

```bash
node --inspect-brk node_modules/.bin/jest --runInBand
```

Then open `chrome://inspect` in Chrome and attach the debugger.

### VS Code Debug Configuration

Add to `.vscode/launch.json`:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "type": "node",
      "request": "launch",
      "name": "Jest: Current File",
      "program": "${workspaceFolder}/node_modules/.bin/jest",
      "args": ["${relativeFile}", "--runInBand"],
      "console": "integratedTerminal",
      "internalConsoleOptions": "neverOpen"
    }
  ]
}
```

### Using `console.log`

Standard `console.log` works inside tests. Output appears in the terminal when `--verbose` is off and always in verbose mode.

### Printing to the Jest Reporter

```js
test('debug this', () => {
  const result = myFn();
  console.log(JSON.stringify(result, null, 2));
  expect(result).toBeDefined();
});
```

---

## Best Practices

### Structure

- Co-locate test files with source files or use a `__tests__` directory consistently
- Mirror the source directory structure in your test directory
- Use `describe` to group related assertions; keep test names descriptive

### Test Isolation

- Each test should be independent and not rely on the state set by another test
- Use `beforeEach`/`afterEach` to reset state rather than `beforeAll`/`afterAll` where practical
- Avoid sharing mutable variables across tests without resetting them

### What to Test

- Test behavior, not implementation details
- Prefer testing public interfaces over private methods
- Avoid testing third-party library internals

### Mocking

- Mock at the boundary of your code (network calls, file system, timers)
- Avoid over-mocking; too many mocks can produce tests that pass even when real behavior is broken
- Restore mocks after tests with `mockRestore()` or `restoreMocks: true` in config

### Assertions

- Each test should ideally have a single focused assertion or a small set of closely related ones
- Always assert on something; a test with no `expect()` call passes vacuously
- Use `expect.assertions(n)` in async tests to confirm the expected number of assertions ran

```js
test('async error handling', async () => {
  expect.assertions(1);
  try {
    await fetchData();
  } catch (e) {
    expect(e.message).toBe('network error');
  }
});
```

### Performance

- Use `--testPathPattern` or `--testNamePattern` during development to run only relevant tests
- Use `--maxWorkers` to tune parallelism for your machine
- Avoid `setTimeout` in tests; use `jest.useFakeTimers()` instead

### CI Integration

```bash
# Recommended CI flags
jest --ci --coverage --runInBand
```

`--ci` disables interactive mode, fails on new unreviewed snapshots, and is suitable for automated pipelines.

---

## Quick Reference

### Commonly Used APIs

|API|Purpose|
|---|---|
|`test(name, fn)`|Define a test|
|`describe(name, fn)`|Group tests|
|`expect(value)`|Create an assertion|
|`jest.fn()`|Create a mock function|
|`jest.spyOn(obj, method)`|Spy on a method|
|`jest.mock(modulePath)`|Mock a module|
|`jest.useFakeTimers()`|Replace timer globals|
|`jest.runAllTimers()`|Flush all timers|
|`beforeEach / afterEach`|Per-test lifecycle hooks|
|`beforeAll / afterAll`|Per-suite lifecycle hooks|

### Common Matcher Cheat Sheet

|Matcher|Checks|
|---|---|
|`toBe(x)`|Strict equality|
|`toEqual(x)`|Deep equality|
|`toBeTruthy()`|Truthy value|
|`toBeFalsy()`|Falsy value|
|`toBeNull()`|`null`|
|`toBeUndefined()`|`undefined`|
|`toContain(x)`|Array/string contains|
|`toHaveLength(n)`|Length property|
|`toMatch(regex)`|String regex match|
|`toThrow()`|Function throws|
|`toHaveBeenCalled()`|Mock was called|
|`toHaveBeenCalledWith(...)`|Mock called with args|
|`toMatchSnapshot()`|Snapshot match|
|`resolves.toBe(x)`|Resolved promise value|
|`rejects.toThrow(x)`|Rejected promise error|