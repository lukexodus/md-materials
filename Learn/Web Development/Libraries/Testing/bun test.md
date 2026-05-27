# `bun:test`

Bun's built-in test runner. Fast, Jest-compatible, zero config.

---

## Running Tests

```bash
bun test                        # run all test files
bun test foo                    # filter by filename substring
bun test --watch                # re-run on file change
bun test --coverage             # coverage report
bun test --timeout 5000         # per-test timeout (ms)
bun test --bail                 # stop after first failure
bun test --rerun-each 5         # run each test N times
bun test path/to/file.test.ts   # specific file
```

---

## File Discovery

Bun auto-discovers files matching:

```
**/*.test.{js,ts,jsx,tsx,mjs,cjs}
**/*.spec.{js,ts,jsx,tsx,mjs,cjs}
**/__tests__/**/*.{js,ts,...}
```

---

## Import

```ts
import { test, expect, describe, beforeEach, afterAll } from "bun:test";
```

---

## Basic Test

```ts
import { test, expect } from "bun:test";

test("adds numbers", () => {
  expect(1 + 1).toBe(2);
});

test("async test", async () => {
  const result = await fetch("https://example.com");
  expect(result.ok).toBe(true);
});
```

---

## `describe` Blocks

```ts
describe("math", () => {
  test("addition", () => expect(1 + 1).toBe(2));
  test("subtraction", () => expect(3 - 1).toBe(2));
});

// Nested
describe("outer", () => {
  describe("inner", () => {
    test("works", () => {});
  });
});
```

---

## Lifecycle Hooks

```ts
import { beforeAll, beforeEach, afterEach, afterAll } from "bun:test";

beforeAll(() => { /* runs once before all tests in scope */ });
beforeEach(() => { /* runs before each test */ });
afterEach(() => { /* runs after each test */ });
afterAll(() => { /* runs once after all tests in scope */ });
```

Hooks respect `describe` scope — inner hooks don't affect outer tests.

---

## Skipping & Focusing

```ts
test.skip("not ready", () => {});
test.todo("implement later");
test.only("just this one", () => {});  // only runs this in the file

describe.skip("whole block", () => {});
describe.only("focus block", () => {});
```

> `test.only` only scopes within the current file, not globally across all files.

---

## `expect` Matchers

### Equality

```ts
expect(x).toBe(y)           // ===
expect(x).toEqual(y)        // deep equality
expect(x).toStrictEqual(y)  // deep + type-checked (no extra keys)
```

### Truthiness

```ts
expect(x).toBeTruthy()
expect(x).toBeFalsy()
expect(x).toBeNull()
expect(x).toBeUndefined()
expect(x).toBeDefined()
```

### Numbers

```ts
expect(x).toBeGreaterThan(n)
expect(x).toBeGreaterThanOrEqual(n)
expect(x).toBeLessThan(n)
expect(x).toBeLessThanOrEqual(n)
expect(x).toBeCloseTo(n, precision?)
expect(x).toBeNaN()
expect(x).toBeFinite()
expect(x).toBeInteger()
```

### Strings

```ts
expect(str).toContain("sub")
expect(str).toStartWith("pre")
expect(str).toEndWith("suf")
expect(str).toMatch(/regex/)
expect(str).toHaveLength(n)
```

### Arrays / Iterables

```ts
expect(arr).toContain(item)
expect(arr).toContainEqual({ id: 1 })   // deep match
expect(arr).toHaveLength(n)
expect(arr).toEqual(expect.arrayContaining([1, 2]))
```

### Objects

```ts
expect(obj).toHaveProperty("key")
expect(obj).toHaveProperty("nested.key", value)
expect(obj).toMatchObject({ a: 1 })     // partial match
```

### Errors

```ts
expect(() => throws()).toThrow()
expect(() => throws()).toThrow("message")
expect(() => throws()).toThrow(ErrorClass)

// async
await expect(asyncFn()).rejects.toThrow("oops")
await expect(asyncFn()).resolves.toBe(42)
```

### Negation

```ts
expect(x).not.toBe(y)
expect(x).not.toThrow()
```

---

## Mocks

### `mock()` — function mock

```ts
import { mock } from "bun:test";

const fn = mock(() => 42);

fn();
fn();

expect(fn).toHaveBeenCalled();
expect(fn).toHaveBeenCalledTimes(2);
expect(fn).toHaveBeenCalledWith(/* args */);
expect(fn).toHaveReturnedWith(42);

fn.mockClear();     // reset call history
fn.mockReset();     // reset + remove implementation
fn.mockRestore();   // restore original (for spies)
```

### `mock()` with implementation variants

```ts
const fn = mock()
  .mockReturnValue(1)
  .mockReturnValueOnce(99)   // first call returns 99, then 1

const asyncFn = mock().mockResolvedValue("ok");
const failFn  = mock().mockRejectedValue(new Error("no"));
```

### `spyOn()`

```ts
import { spyOn } from "bun:test";

const obj = { greet: () => "hello" };
const spy = spyOn(obj, "greet").mockReturnValue("hi");

obj.greet();
expect(spy).toHaveBeenCalled();
spy.mockRestore();
```

### Module mocking

```ts
import { mock } from "bun:test";

mock.module("./db", () => ({
  query: mock(() => [{ id: 1 }]),
}));
```

> Module mocks must be set up before importing the module under test. [Inference: hoisting behavior mirrors Jest's `jest.mock()`, but verify against current Bun docs for exact semantics.]

---

## Snapshot Testing

```ts
test("snapshot", () => {
  expect({ a: 1, b: [2, 3] }).toMatchSnapshot();
});
```

```bash
bun test --update-snapshots   # write/update .snap files
```

Snapshots are stored in `__snapshots__/`.

---

## `expect.extend` — Custom Matchers

```ts
expect.extend({
  toBeEven(received: number) {
    return {
      pass: received % 2 === 0,
      message: () => `expected ${received} to be even`,
    };
  },
});

expect(4).toBeEven();
```

---

## TypeScript Support

Works out of the box — no `ts-jest`, no `babel`, no config. Bun transpiles `.ts` natively.

---

## Coverage

```bash
bun test --coverage
```

Outputs a summary table. To configure thresholds or reporters, add to `bunfig.toml`:

```toml
[test]
coverageThreshold = { line = 80, function = 80, statement = 80 }
coverageReporter = ["text", "lcov"]
coverageDir = "./coverage"
```

---

## `bunfig.toml` Test Config

```toml
[test]
timeout = 5000           # default per-test timeout (ms)
preload = ["./setup.ts"] # run before test files
smol = false             # reduce memory (slower)
```

---

## `preload` / Setup Files

```toml
# bunfig.toml
[test]
preload = ["./tests/setup.ts"]
```

```ts
// tests/setup.ts
import { beforeAll } from "bun:test";

beforeAll(() => {
  // global setup
});
```

---

## Differences from Jest

|Feature|Jest|`bun:test`|
|---|---|---|
|Speed|Slower (Node + transform)|Significantly faster|
|Config needed|Yes (usually)|No|
|`jest.fn()`|✓|`mock()`|
|`jest.mock()`|✓|`mock.module()`|
|`jest.spyOn()`|✓|`spyOn()`|
|Fake timers|Full support|Partial [Unverified: check current docs]|
|`expect.assertions()`|✓|✓|
|Custom environment|jsdom, node|Node-like (no jsdom built-in)|

> **[Unverified]** Feature parity evolves rapidly. Always check [bun.sh/docs/test](https://bun.sh/docs/test) for the current state. Behavior claims about mock internals are not guaranteed.

---

## Patterns

### Test each (parameterized)

```ts
const cases = [
  [1, 2, 3],
  [0, 0, 0],
  [-1, 1, 0],
];

test.each(cases)("adds %i + %i = %i", (a, b, expected) => {
  expect(a + b).toBe(expected);
});
```

### Async timeout

```ts
test("slow op", async () => {
  const result = await slowOp();
  expect(result).toBeDefined();
}, 10_000); // 10s timeout for this test
```

### Isolating state with `beforeEach`

```ts
let db: Database;

beforeEach(() => {
  db = new Database(":memory:");
});

afterEach(() => {
  db.close();
});
```

---

# Real-World Usage of Mocks

Mocks are mainly used in tests to **replace real dependencies with controlled fake versions**, so you can test your code in isolation.

In real projects, they show up everywhere you don’t want side effects like network calls, database access, file I/O, or time-based behavior.

---

## 1. API / HTTP Requests

### Problem

Real requests are:

* slow
* flaky
* expensive (rate limits)
* dependent on external services

### Solution: mock the API client

```ts id="api1"
const fetchUser = mock().mockResolvedValue({
  id: 1,
  name: "Alice",
});
```

```ts id="api2"
test("loads user", async () => {
  const user = await fetchUser();

  expect(user.name).toBe("Alice");
});
```

### Real-world idea

Instead of calling:

* real REST API
* GraphQL endpoint

You simulate responses.

---

## 2. Database Access

### Problem

Databases introduce:

* setup complexity
* slow tests
* shared state issues

### Solution

```ts id="db1"
const db = {
  findUser: mock().mockResolvedValue({ id: 1, name: "Bob" }),
};
```

```ts id="db2"
test("service gets user from db", async () => {
  const user = await db.findUser(1);

  expect(db.findUser).toHaveBeenCalledWith(1);
});
```

### Real-world use

Used heavily in:

* service layer tests
* repository pattern testing

---

## 3. External Services (Payments, Emails, SMS)

### Example: email sending

```ts id="email1"
const sendEmail = mock().mockResolvedValue(true);
```

```ts id="email2"
await sendEmail("user@mail.com", "Welcome");

expect(sendEmail).toHaveBeenCalledWith(
  "user@mail.com",
  "Welcome"
);
```

### Why mock this?

You don’t want:

* real emails sent during tests
* Stripe payments triggered
* SMS messages sent

---

## 4. Time-dependent code

### Problem

Code using time is hard to test:

* `Date.now()`
* timers
* expiration logic

### Solution

```ts id="time1"
const now = mock().mockReturnValue(1700000000000);
```

```ts id="time2"
expect(now()).toBe(1700000000000);
```

### Real-world use

* token expiration
* caching logic
* scheduling systems

---

## 5. Error handling scenarios

### Example: API failure

```ts id="err1"
const fetchData = mock().mockRejectedValue(new Error("Network down"));
```

```ts id="err2"
await expect(fetchData()).rejects.toThrow("Network down");
```

### Why this matters

You can test:

* retries
* fallback UI
* error boundaries

without breaking anything real.

---

## 6. File system / OS interactions

Instead of reading real files:

```ts id="fs1"
const readFile = mock().mockResolvedValue("file content");
```

### Real-world use

* config loaders
* log readers
* upload pipelines

---

## 7. Function collaboration (interaction testing)

Mocks are especially useful to test **how functions talk to each other**.

```ts id="collab1"
const logger = mock();

function process(data, log) {
  log("processing started");
  return data * 2;
}

process(5, logger);

expect(logger).toHaveBeenCalledWith("processing started");
```

### Key idea

You’re not testing the logger — only that your code used it correctly.

---

## 8. Dependency injection testing

Instead of hardcoding dependencies:

```ts id="di1"
function createUserService(db, mailer) {
  return {
    register: async (user) => {
      await db.save(user);
      await mailer.send(user.email);
    },
  };
}
```

Test with mocks:

```ts id="di2"
const db = { save: mock().mockResolvedValue(true) };
const mailer = { send: mock().mockResolvedValue(true) };

const service = createUserService(db, mailer);

await service.register({ email: "a@b.com" });

expect(db.save).toHaveBeenCalled();
expect(mailer.send).toHaveBeenCalled();
```

---

## When mocks are used (big picture)

Mocks are used whenever you want:

* isolation (no real dependencies)
* deterministic behavior
* fast tests
* control over edge cases

---

## When NOT to overuse mocks

Avoid mocking:

* your own simple logic
* everything in integration tests
* things you actually want to verify end-to-end

Too many mocks → tests that pass but don’t reflect reality.

---

## Mental model

A mock is:

> “Replace the real world with a controllable simulation so you can test your code’s decisions.”

---

If you want, I can show a real production-style test setup (service + repository + API) where mocks are combined properly in a layered architecture.

