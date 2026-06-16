## Code Coverage Setup in Fastify

Code coverage measures which lines, branches, functions, and statements in your source code are exercised by your tests. Setting it up correctly in a Fastify project helps identify untested paths — including unexercised route handlers, error branches, and plugin logic.

---

### Coverage Concepts

| Term | Meaning |
| --- | --- |
| **Line coverage** | Which lines were executed |
| **Branch coverage** | Which conditional branches (if/else, ternary) were taken |
| **Function coverage** | Which functions were called |
| **Statement coverage** | Which individual statements were executed |

**Key Points**

- Line coverage is the most common metric reported
- Branch coverage is more rigorous — a line can be "covered" while one branch of an `if` is never reached
- 100% coverage does not mean your tests are correct — it means every line ran, not that every outcome was asserted

---

### Coverage Tools Available

Three tools are commonly used in Node.js/Fastify projects:

| Tool | Mechanism | Native? |
| --- | --- | --- |
| `node:test` + `--experimental-test-coverage` | V8 built-in | Yes (Node 20+) |
| `c8` | V8 coverage via CLI wrapper | No, npm install |
| `nyc` | Istanbul instrumentation | No, npm install |
| Vitest built-in coverage | V8 or Istanbul via `@vitest/coverage-v8` / `@vitest/coverage-istanbul` | Via plugin |

**Key Points**

- V8-based tools (`c8`, native `node:test`) require no code instrumentation — they use the engine's own coverage data
- Istanbul-based tools (`nyc`, `@vitest/coverage-istanbul`) instrument source code at the AST level — slower but historically more accurate for branch coverage
- [Inference] V8 coverage accuracy for branch coverage has improved significantly in Node 18+ but may still differ from Istanbul in edge cases — verify against your Node version

---

### Project Structure Assumed

```
project/
├── src/
│   ├── app.js
│   ├── routes/
│   │   └── users.js
│   └── plugins/
│       └── db.js
├── test/
│   └── users.test.js
├── package.json
```

---

### Option 1 — Native Node.js Coverage (`node:test` + `--experimental-test-coverage`)

Available from Node.js 20. No additional packages required.

#### Running coverage

bash

```bash
node --experimental-test-coverage --test test/**/*.test.js
```

**Output** (terminal summary):

```
▶ POST /users — validation errors
  ✔ returns 400 when email is invalid (3.21ms)
  ✔ returns 200 for valid payload (1.04ms)

ℹ start of coverage report
ℹ ---------------------------------------------------------
ℹ file              | line % | branch % | funcs % | uncovered lines
ℹ ---------------------------------------------------------
ℹ src/app.js        |  94.44 |    87.50 |  100.00 | 22
ℹ src/routes/users.js |  100.00 |  100.00 |  100.00 |
ℹ ---------------------------------------------------------
ℹ all files         |  95.83 |    90.00 |  100.00 |
ℹ ---------------------------------------------------------
```

**Key Points**

- `--experimental-test-coverage` is the flag name as of Node 20; it may be stabilized under a different flag in later versions [Unverified — verify against your Node version]
- No config file required for basic usage
- Coverage is printed inline in the test output

#### Adding a `package.json` script

json

```json
{
  "scripts": {
    "test": "node --test test/**/*.test.js",
    "test:coverage": "node --experimental-test-coverage --test test/**/*.test.js"
  }
}
```

---

### Option 2 — `c8`

`c8` wraps any Node.js process and collects V8 coverage. It works with any test runner.

#### Installation

bash

```bash
npm install --save-dev c8
```

#### Running coverage

bash

```bash
npx c8 node --test test/**/*.test.js
```

Or with Tap:

bash

```bash
npx c8 npx tap test/**/*.test.js
```

#### `package.json` scripts

json

```json
{
  "scripts": {
    "test": "node --test test/**/*.test.js",
    "test:coverage": "c8 node --test test/**/*.test.js",
    "coverage:report": "c8 report --reporter=html"
  }
}
```

#### `.c8rc` configuration file

json

```json
{
  "include": ["src/**/*.js"],
  "exclude": ["test/**", "node_modules/**"],
  "reporter": ["text", "lcov", "html"],
  "all": true,
  "branches": 80,
  "lines": 90,
  "functions": 90,
  "statements": 90
}
```

**Key Points**

- `all: true` — includes files that are never imported by tests (so they appear as 0% rather than being silently absent)
- `branches`, `lines`, `functions`, `statements` — threshold values; `c8` exits with a non-zero code if any threshold is not met, failing CI
- `reporter: ["lcov"]` generates `coverage/lcov.info`, consumed by tools like Codecov and Coveralls
- `include` / `exclude` use glob patterns relative to the project root

#### HTML Report

After running `c8`, open the HTML report:

bash

```bash
npx c8 report --reporter=html
open coverage/index.html
```

The HTML report shows line-by-line highlighting — green for covered, red for uncovered, yellow for partially-covered branches.

---

### Option 3 — `nyc` (Istanbul)

`nyc` is the CLI for Istanbul. It instruments source code before execution.

#### Installation

bash

```bash
npm install --save-dev nyc
```

#### Running coverage

bash

```bash
npx nyc node --test test/**/*.test.js
```

#### `.nycrc` configuration

json

```json
{
  "include": ["src/**/*.js"],
  "exclude": ["test/**"],
  "reporter": ["text", "html", "lcov"],
  "all": true,
  "branches": 80,
  "lines": 90,
  "functions": 90,
  "statements": 90,
  "check-coverage": true
}
```

**Key Points**

- `check-coverage: true` makes `nyc` exit with code 1 if thresholds are not met
- `nyc` works well with CommonJS; ESM support requires additional configuration [Inference — see ESM note below]

#### ESM Caveat with `nyc`

`nyc` was designed primarily for CommonJS. For ESM projects, `c8` or the native Node.js coverage flag is the more straightforward path. [Inference — ESM support in `nyc` varies by version; verify against your setup]

---

### Option 4 — Vitest Coverage

If your project uses Vitest as the test runner:

#### Installation

bash

```bash
# V8-based (recommended for most projects)
npm install --save-dev @vitest/coverage-v8

# or Istanbul-based
npm install --save-dev @vitest/coverage-istanbul
```

#### `vitest.config.js`

js

```js
import { defineConfig } from 'vitest/config'

export default defineConfig({
  test: {
    coverage: {
      provider: 'v8',              // or 'istanbul'
      reporter: ['text', 'html', 'lcov'],
      include: ['src/**/*.js'],
      exclude: ['test/**', 'node_modules/**'],
      all: true,
      thresholds: {
        lines: 90,
        branches: 80,
        functions: 90,
        statements: 90
      }
    }
  }
})
```

#### Running

bash

```bash
npx vitest run --coverage
```

**Output** includes the same text table format as `c8`, plus an HTML report under `coverage/`.

---

### Excluding Code from Coverage

Some code should legitimately be excluded — bootstrapping logic, platform-specific branches, generated files.

#### Inline ignore comments

js

```js
/* c8 ignore next */
if (process.env.NODE_ENV === 'production') {
  connectToProductionDB()
}

/* c8 ignore start */
function debugOnlyHelper() {
  // ...
}
/* c8 ignore end */
```

For Istanbul/`nyc`:

js

```js
/* istanbul ignore next */
if (process.platform === 'win32') {
  // Windows-specific path
}
```

**Key Points**

- Ignore comments suppress coverage counting for the annotated lines
- Overuse defeats the purpose of coverage — reserve for genuinely untestable branches [Inference]

---

### Coverage in CI (GitHub Actions Example)

yaml

```yaml
# .github/workflows/test.yml
name: Test

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'

      - name: Install dependencies
        run: npm ci

      - name: Run tests with coverage
        run: npm run test:coverage

      - name: Upload coverage to Codecov
        uses: codecov/codecov-action@v4
        with:
          files: ./coverage/lcov.info
```

**Key Points**

- `lcov.info` is the standard interchange format consumed by Codecov, Coveralls, and SonarQube
- The `codecov/codecov-action` requires an account and repository token for private repos [Unverified — verify current Codecov requirements]
- Coverage upload is a separate step from the threshold check — `c8` or `nyc` can fail the build locally via thresholds before the upload step is reached

---

### Coverage Thresholds and What to Target

There is no universally correct threshold. Common conventions:

| Context | Suggested Minimum |
| --- | --- |
| Library / shared module | 90–100% line, 80%+ branch |
| API route handlers | 85–95% line |
| Utility functions | 90–100% |
| Bootstrap / server entry | Often excluded |

**Key Points**

- Setting thresholds too high early in a project creates friction without value
- Branch coverage thresholds catch more real defects than line coverage alone [Inference]
- Thresholds are most useful as ratchets — set them at current coverage, then raise them as coverage improves

---

### What Fastify-Specific Code to Prioritize Covering

```
✔ Route handlers (success and error paths)
✔ Custom error handlers (setErrorHandler)
✔ Hook callbacks (onRequest, preHandler, onSend, onError)
✔ Plugin registration logic
✔ Schema validation branches (valid + invalid inputs)
✔ Reply serialization (response schema paths)
✘ Server startup / listen() calls (typically excluded)
✘ Graceful shutdown handlers (difficult to test in unit context)
```

---

### Coverage Flow

c8 / nativenycYesYesNoNoRun test suiteCoverage toolV8 engine collectscoverage dataIstanbul instrumentssource firstCoverage reportgeneratedThresholds configured?Thresholds met?Exit 0 — CI passesExit 1 — CI failslcov.info / HTML reportUpload to Codecov /Coveralls

---

**Related Topics**

- Writing testable Fastify plugins (avoiding coverage gaps from encapsulation)
- Branch coverage for async error paths in hooks
- Mocking external dependencies for isolated unit coverage
- Coverage-driven refactoring of route handlers
- Combining coverage from multiple test suites (`c8 merge`)
- Snapshot testing in Fastify route responses
- Mutation testing as a complement to coverage metrics