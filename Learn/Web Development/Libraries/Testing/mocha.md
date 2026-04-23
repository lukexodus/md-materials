# Comprehensive Guide to Mocha

---

## What is Mocha?

Mocha is a feature-rich JavaScript test framework that runs on Node.js and in the browser. Unlike Jest, Mocha is intentionally minimal — it provides test structure, lifecycle hooks, and reporting, but leaves assertions, mocking, and coverage to separate libraries of your choice.

Key characteristics:

- **Flexible**: works with any assertion library (Node's built-in `assert`, Chai, Should.js, etc.)
- **Extensible**: mocking and coverage handled by separate tools (Sinon, Istanbul/nyc)
- **Mature**: one of the longest-standing JavaScript test frameworks
- **Browser support**: can run tests directly in a browser environment
- **Serial by default**: tests run serially in the order they are defined

### Mocha vs Jest

|Feature|Mocha|Jest|
|---|---|---|
|Assertions|External (e.g. Chai)|Built-in|
|Mocking|External (e.g. Sinon)|Built-in|
|Coverage|External (nyc)|Built-in|
|Config overhead|Moderate|Low (zero-config)|
|Flexibility|High|Moderate|
|Browser support|Native|Via jsdom|

---

## Installation and Setup

### Install Mocha

```bash
npm install --save-dev mocha
```

### Add a Test Script

```json
{
  "scripts": {
    "test": "mocha",
    "test:watch": "mocha --watch"
  }
}
```

### Typical Companion Libraries

```bash
# Assertions
npm install --save-dev chai

# Mocking and spies
npm install --save-dev sinon

# Coverage
npm install --save-dev nyc

# TypeScript support
npm install --save-dev ts-node @types/mocha

# TypeScript + Chai types
npm install --save-dev @types/chai @types/sinon
```

---

## Project Configuration

Mocha looks for a configuration file at `.mocharc.js`, `.mocharc.cjs`, `.mocharc.yaml`, `.mocharc.yml`, `.mocharc.json`, or `.mocharc.jsonc`, as well as a `"mocha"` key in `package.json`.

### .mocharc.js

```js
module.exports = {
  // Test file pattern
  spec: 'test/**/*.spec.js',

  // Reporter
  reporter: 'spec',

  // Timeout per test in milliseconds
  timeout: 2000,

  // Run tests serially (default)
  parallel: false,

  // Require files before tests run
  require: ['./test/setup.js'],

  // Enable recursive directory search
  recursive: true,

  // Exit after tests complete (useful if async code keeps process alive)
  exit: true,
};
```

### .mocharc.yml

```yaml
spec: test/**/*.spec.js
reporter: spec
timeout: 2000
require:
  - ./test/setup.js
recursive: true
exit: true
```

### package.json

```json
{
  "mocha": {
    "spec": "test/**/*.spec.js",
    "timeout": 2000,
    "reporter": "spec",
    "require": ["./test/setup.js"]
  }
}
```

---

## Writing Tests

### Test File Naming Conventions

By default, Mocha looks for files matching `./test/*.{js,mjs,cjs}`. Override with `spec` in config or `--spec` on the CLI.

Common conventions:

- `test/unit/math.spec.js`
- `test/integration/api.test.js`
- `src/utils/__tests__/math.js`

### Basic Structure

```js
// math.js
function add(a, b) {
  return a + b;
}
module.exports = { add };
```

```js
// test/math.spec.js
const assert = require('assert');
const { add } = require('../math');

describe('add()', function () {
  it('adds two positive numbers', function () {
    assert.strictEqual(add(2, 3), 5);
  });

  it('returns a negative number when sum is negative', function () {
    assert.strictEqual(add(-2, -3), -5);
  });
});
```

### `describe` and `it`

`describe` groups related tests. `it` (or its alias `test`) defines an individual test case:

```js
describe('outer group', function () {
  describe('inner group', function () {
    it('does something', function () {
      // assertion here
    });
  });
});
```

### Arrow Functions and `this`

Mocha binds a context object (`this`) to each test and hook. Using arrow functions disables access to this context:

```js
// Avoid arrow functions if you need Mocha's context (e.g. this.timeout())
describe('suite', function () {
  it('sets custom timeout', function () {
    this.timeout(5000); // works
  });
});

// Arrow function — this.timeout() will not work
it('broken timeout', () => {
  this.timeout(5000); // does NOT work
});
```

If you do not need `this`, arrow functions are fine.

---

## Hooks

Hooks run setup and teardown code around your tests.

### Available Hooks

```js
describe('suite', function () {
  before(function () {
    // Runs once before all tests in this describe block
  });

  after(function () {
    // Runs once after all tests in this describe block
  });

  beforeEach(function () {
    // Runs before each test in this describe block
  });

  afterEach(function () {
    // Runs after each test in this describe block
  });

  it('test one', function () { ... });
  it('test two', function () { ... });
});
```

### Root-Level Hooks

Hooks defined outside any `describe` apply to all tests in the file. To share hooks across multiple files, use a root hooks plugin (see below).

```js
// Applies to every test in this file
beforeEach(function () {
  db.reset();
});
```

### Root Hooks Plugin (Mocha >= 8)

To run hooks globally across all test files, create a plugin file and require it:

```js
// test/hooks.js
exports.mochaHooks = {
  beforeAll() {
    // Runs once before all tests across all files
  },
  afterAll() {
    // Runs once after all tests across all files
  },
  beforeEach() {
    // Runs before each test across all files
  },
  afterEach() {
    // Runs after each test across all files
  },
};
```

```js
// .mocharc.js
module.exports = {
  require: ['./test/hooks.js'],
};
```

### Async Hooks

Hooks support the same async patterns as tests (callbacks, promises, async/await):

```js
before(async function () {
  await db.connect();
});

after(async function () {
  await db.disconnect();
});
```

### Hook Naming (Optional)

You can label hooks for clearer error output:

```js
beforeEach('reset state', function () {
  state = {};
});
```

---

## Assertions

Mocha ships with no built-in assertion library. You choose your own.

### Node.js Built-in `assert`

```js
const assert = require('assert');

assert.strictEqual(1 + 1, 2);
assert.deepStrictEqual({ a: 1 }, { a: 1 });
assert.throws(() => { throw new Error('oops'); }, /oops/);
assert.ok(true);
assert.notStrictEqual(1, 2);
```

### Chai — Assert Style

```js
const { assert } = require('chai');

assert.equal(add(2, 3), 5);
assert.deepEqual({ a: 1 }, { a: 1 });
assert.isTrue(result);
assert.isNull(value);
assert.include([1, 2, 3], 2);
assert.throws(() => badFn(), Error);
```

### Chai — Expect Style

```js
const { expect } = require('chai');

expect(add(2, 3)).to.equal(5);
expect({ a: 1, b: 2 }).to.deep.equal({ a: 1, b: 2 });
expect('hello world').to.include('world');
expect([1, 2, 3]).to.have.lengthOf(3);
expect(null).to.be.null;
expect(true).to.be.true;
expect(badFn).to.throw('oops');
expect(promise).to.eventually.equal('value'); // with chai-as-promised
```

### Chai — Should Style

```js
const chai = require('chai');
chai.should(); // Extends Object.prototype

(5).should.equal(5);
'hello'.should.include('ell');
[1, 2, 3].should.have.lengthOf(3);
```

Note: `should` does not work on `null` or `undefined` values since they have no prototype.

### chai-as-promised (Async Assertions)

```bash
npm install --save-dev chai-as-promised
```

```js
const chai = require('chai');
const chaiAsPromised = require('chai-as-promised');
chai.use(chaiAsPromised);

const { expect } = chai;

it('resolves correctly', async function () {
  await expect(fetchData()).to.eventually.equal('peanut butter');
});

it('rejects with error', async function () {
  await expect(fetchData()).to.be.rejectedWith('network error');
});
```

---

## Asynchronous Testing

### Callbacks (`done`)

Pass `done` as a parameter. Call it when the async operation completes. Call `done(err)` to fail the test.

```js
it('fetches data with callback', function (done) {
  fetchData(function (err, data) {
    if (err) return done(err);
    assert.strictEqual(data, 'peanut butter');
    done();
  });
});
```

### Promises

Return the promise from the test. Mocha detects it and waits for resolution or rejection.

```js
it('fetches data with promise', function () {
  return fetchData().then(function (data) {
    assert.strictEqual(data, 'peanut butter');
  });
});
```

### Async/Await

```js
it('fetches data with async/await', async function () {
  const data = await fetchData();
  assert.strictEqual(data, 'peanut butter');
});

it('handles rejection', async function () {
  try {
    await fetchData();
    assert.fail('Expected error was not thrown');
  } catch (err) {
    assert.match(err.message, /network error/);
  }
});
```

### Timeouts

Default timeout is 2000ms. Override globally in config or per-test:

```js
it('slow operation', function () {
  this.timeout(5000); // 5 seconds for this test only
  return slowOperation();
});
```

Disable timeout:

```js
this.timeout(0); // No timeout
```

---

## Pending Tests

A test with no callback is pending. Pending tests are reported separately and do not fail the suite.

```js
it('is not yet implemented');

it('will be written soon', function () {
  // Empty body — also pending if no assertion
});
```

Use pending tests to document planned behavior.

---

## Skipping and Isolating Tests

### Skipping

```js
describe.skip('entire suite is skipped', function () {
  it('this will not run', function () { ... });
});

it.skip('this test is skipped', function () { ... });
```

### Exclusive Tests (`only`)

```js
describe.only('only this suite runs', function () {
  it('runs', function () { ... });
});

it.only('only this test runs', function () { ... });
```

`.only` is scoped: `it.only` within a `describe` runs only that test within the suite; `describe.only` runs only that suite.

Mocha will warn if `.only` is present when running in CI (`--forbid-only` flag).

### `--forbid-only` and `--forbid-pending`

Useful in CI to prevent accidentally committed `.only` or pending tests from passing silently:

```bash
mocha --forbid-only --forbid-pending
```

---

## Reporters

Reporters control how test results are displayed.

### Built-in Reporters

|Reporter|Description|
|---|---|
|`spec`|Default; hierarchical output with pass/fail indicators|
|`dot`|Minimal dot-matrix output|
|`min`|Shows only failures and a summary|
|`tap`|TAP-compatible output|
|`json`|JSON output to stdout|
|`json-stream`|Newline-delimited JSON events|
|`landing`|Animated landing strip (fun)|
|`list`|Flat list of test titles|
|`markdown`|Markdown output|
|`xunit`|JUnit-compatible XML (useful for CI)|
|`nyan`|Nyan cat progress bar|

### Using a Reporter

```bash
mocha --reporter spec
mocha --reporter dot
mocha --reporter xunit > results.xml
```

Or in `.mocharc.js`:

```js
module.exports = {
  reporter: 'spec',
};
```

### Third-Party Reporters

```bash
npm install --save-dev mochawesome
mocha --reporter mochawesome
```

`mochawesome` generates a styled HTML report in `mochawesome-report/`.

### Multiple Reporters

Use `mocha-multi-reporters` to output multiple formats simultaneously:

```bash
npm install --save-dev mocha-multi-reporters
```

```json
{
  "reporterOptions": {
    "reporterEnabled": "spec, xunit",
    "xunitReporterOptions": {
      "output": "test-results.xml"
    }
  }
}
```

---

## Running Tests

### Common CLI Commands

```bash
# Run all tests (uses .mocharc config)
mocha

# Run a specific file
mocha test/math.spec.js

# Run files matching a glob
mocha 'test/**/*.spec.js'

# Recursive search
mocha --recursive

# Set timeout
mocha --timeout 5000

# Use a specific reporter
mocha --reporter dot

# Require a setup file
mocha --require ./test/setup.js

# Fail fast (stop on first failure)
mocha --bail

# Run parallel (Mocha >= 8)
mocha --parallel

# Exit after tests complete
mocha --exit

# Forbid .only in CI
mocha --forbid-only

# Grep tests by title pattern
mocha --grep "adds two"

# Invert grep (run tests NOT matching pattern)
mocha --grep "adds two" --invert
```

### Parallel Mode

Mocha 8+ supports running test files in parallel using worker threads:

```bash
mocha --parallel
```

Notes on parallel mode:

- Root hooks do not apply across workers in parallel mode; use root hooks plugins instead
- `--file` (ordered require) is not compatible with parallel mode
- Shared state between test files will cause issues

---

## Watch Mode

```bash
mocha --watch
```

Mocha re-runs tests when source files change. By default it watches files in `./test` and `./lib`. Configure watched files:

```js
// .mocharc.js
module.exports = {
  watch: true,
  watchFiles: ['src/**/*.js', 'test/**/*.spec.js'],
  watchIgnore: ['node_modules', '.git'],
};
```

---

## Mocking and Spying

Mocha does not include mocking utilities. The standard choice is **Sinon.js**.

### Sinon Spies

A spy records calls without replacing the original implementation:

```js
const sinon = require('sinon');

it('calls the callback', function () {
  const callback = sinon.spy();
  doWork(callback);

  sinon.assert.calledOnce(callback);
  sinon.assert.calledWith(callback, 'expected-arg');
});
```

### Sinon Stubs

A stub replaces the function implementation:

```js
const sinon = require('sinon');
const userService = require('../userService');

it('returns mocked user', async function () {
  const stub = sinon.stub(userService, 'getUser').resolves({ id: 1, name: 'Alice' });

  const user = await userService.getUser(1);
  assert.strictEqual(user.name, 'Alice');

  stub.restore(); // Always restore stubs
});
```

### Sinon Mocks

Mocks combine stubs with pre-defined expectations:

```js
it('sends email once', function () {
  const mock = sinon.mock(emailService);
  mock.expects('send').once().withArgs('user@example.com');

  sendWelcomeEmail('user@example.com');

  mock.verify();
  mock.restore();
});
```

### Sinon Fake Timers

```js
it('fires callback after delay', function () {
  const clock = sinon.useFakeTimers();
  const callback = sinon.spy();

  setTimeout(callback, 1000);
  clock.tick(1000);

  sinon.assert.calledOnce(callback);
  clock.restore();
});
```

### Cleaning Up with Sandboxes

A sandbox automatically restores all stubs, spies, and mocks after each test:

```js
const sinon = require('sinon');

describe('with sandbox', function () {
  let sandbox;

  beforeEach(function () {
    sandbox = sinon.createSandbox();
  });

  afterEach(function () {
    sandbox.restore();
  });

  it('stubs inside sandbox', function () {
    sandbox.stub(myModule, 'fetchData').resolves({ ok: true });
    // No manual restore needed — sandbox.restore() handles it
  });
});
```

---

## Code Coverage

Mocha does not include coverage tooling. The standard choice is **nyc** (Istanbul's command-line interface).

### Installation

```bash
npm install --save-dev nyc
```

### Usage

```json
{
  "scripts": {
    "test": "nyc mocha"
  }
}
```

### nyc Configuration

In `.nycrc` or `package.json` under `"nyc"`:

```json
{
  "nyc": {
    "include": ["src/**/*.js"],
    "exclude": ["**/*.spec.js", "node_modules"],
    "reporter": ["text", "lcov", "html"],
    "branches": 80,
    "lines": 80,
    "functions": 80,
    "statements": 80,
    "check-coverage": true
  }
}
```

### Generating a Report

```bash
nyc mocha              # Run tests with coverage
nyc report             # Re-generate report from last run
nyc report --reporter=html  # HTML report in coverage/
```

### With TypeScript

```bash
npm install --save-dev @istanbuljs/nyc-config-typescript source-map-support
```

```json
{
  "nyc": {
    "extends": "@istanbuljs/nyc-config-typescript",
    "include": ["src/**/*.ts"],
    "reporter": ["text", "lcov"]
  }
}
```

---

## TypeScript Support

### Setup

```bash
npm install --save-dev ts-node @types/mocha typescript
```

### .mocharc.js

```js
module.exports = {
  require: ['ts-node/register'],
  spec: 'test/**/*.spec.ts',
  extensions: ['ts'],
};
```

### tsconfig.json

```json
{
  "compilerOptions": {
    "target": "ES2019",
    "module": "commonjs",
    "strict": true,
    "esModuleInterop": true,
    "outDir": "dist",
    "rootDir": "src"
  },
  "include": ["src", "test"]
}
```

### Example TypeScript Test

```ts
import { strict as assert } from 'assert';
import { add } from '../src/math';

describe('add()', function () {
  it('adds two numbers', function () {
    assert.strictEqual(add(2, 3), 5);
  });
});
```

### ESM TypeScript

For native ESM with TypeScript, use `ts-node/esm` loader and `"module": "ESNext"` in tsconfig. This setup is more complex and requires `--experimental-vm-modules` in newer Node versions.

---

## Testing with the Browser

Mocha can run tests directly in a browser using its browser build.

### Setup

```html
<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8" />
    <title>Mocha Tests</title>
    <link rel="stylesheet" href="node_modules/mocha/mocha.css" />
  </head>
  <body>
    <div id="mocha"></div>

    <!-- Mocha -->
    <script src="node_modules/mocha/mocha.js"></script>

    <!-- Chai (optional) -->
    <script src="node_modules/chai/chai.js"></script>

    <!-- Setup -->
    <script>
      mocha.setup('bdd');
      var expect = chai.expect;
    </script>

    <!-- Test files -->
    <script src="test/math.spec.js"></script>

    <!-- Run -->
    <script>
      mocha.run();
    </script>
  </body>
</html>
```

Open the HTML file in a browser to see results in the Mocha UI.

### Headless Browser Testing

For CI, use Playwright or Puppeteer to drive the browser:

```bash
npm install --save-dev playwright
```

---

## Best Practices

### Structure

- Use `describe` to group by unit under test, not by behavior type
- Name `it` blocks as complete sentences: `it('returns null when input is empty')`
- Mirror source directory structure in your test directory
- Keep test files close to the code they test, or use a top-level `test/` directory consistently

### Test Isolation

- Each test should be self-contained and not depend on the execution order of other tests
- Use `beforeEach`/`afterEach` for setup and teardown rather than sharing mutable state
- Always restore stubs and spies — use a Sinon sandbox to simplify cleanup

### Async Tests

- Always return a promise or use `async/await`; never fire-and-forget async code in a test
- If using `done`, always call `done(err)` on error paths — an uncaught exception without `done(err)` can cause misleading timeouts
- Set `this.timeout()` explicitly for tests that depend on I/O or network calls

### Avoiding `.only`

- Never commit `.only` to version control; use `--forbid-only` in CI to catch it
- Use `--grep` for temporary test isolation during development instead

### Assertions

- Use Chai's `expect` or `assert` style consistently within a project — do not mix styles
- Use `assert.fail('message')` to fail a test explicitly if an expected error was not thrown
- For async error assertions with Chai, use `chai-as-promised` rather than try/catch boilerplate

### CI Configuration

```bash
mocha --exit --forbid-only --forbid-pending --reporter xunit > results.xml
```

```json
{
  "scripts": {
    "test:ci": "nyc mocha --exit --forbid-only --reporter xunit"
  }
}
```

---

## Quick Reference

### CLI Flags

|Flag|Purpose|
|---|---|
|`--spec <glob>`|Test file pattern|
|`--recursive`|Search directories recursively|
|`--reporter <name>`|Output reporter|
|`--timeout <ms>`|Default test timeout|
|`--bail`|Stop on first failure|
|`--parallel`|Run files in parallel|
|`--require <path>`|Require file before tests|
|`--exit`|Force exit after tests|
|`--watch`|Watch mode|
|`--grep <pattern>`|Run tests matching pattern|
|`--invert`|Invert grep pattern|
|`--forbid-only`|Fail if `.only` is present|
|`--forbid-pending`|Fail if pending tests exist|

### Hooks Summary

|Hook|Scope|
|---|---|
|`before(fn)`|Once before all tests in block|
|`after(fn)`|Once after all tests in block|
|`beforeEach(fn)`|Before each test in block|
|`afterEach(fn)`|After each test in block|

### Chai Expect Cheat Sheet

|Assertion|Checks|
|---|---|
|`.equal(x)`|Strict equality|
|`.deep.equal(x)`|Deep equality|
|`.include(x)`|Array or string contains|
|`.have.lengthOf(n)`|Length|
|`.be.true / .be.false`|Boolean value|
|`.be.null / .be.undefined`|Null/undefined|
|`.be.a('string')`|Type check|
|`.throw()`|Function throws|
|`.eventually.equal(x)`|Resolved promise value|
|`.be.rejectedWith(x)`|Rejected promise|

### Sinon Summary

|API|Purpose|
|---|---|
|`sinon.spy()`|Record calls, preserve original|
|`sinon.stub(obj, method)`|Replace with controllable fn|
|`sinon.mock(obj)`|Expectations + stub|
|`sinon.useFakeTimers()`|Replace global timers|
|`sinon.createSandbox()`|Group and auto-restore all fakes|
|`.restore()`|Restore original implementation|
|`sinon.assert.calledOnce(spy)`|Assert call count|
|`sinon.assert.calledWith(spy, arg)`|Assert call arguments|