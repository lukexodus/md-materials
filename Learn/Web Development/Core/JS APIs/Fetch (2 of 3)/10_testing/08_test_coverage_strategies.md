## Test Coverage Strategies


### Fundamentals of Test Coverage

Test coverage measures the degree to which source code is executed during testing. It provides quantitative metrics indicating which parts of the codebase have been tested and, equally importantly, which parts remain untested. Coverage serves as both a quality indicator and a tool for identifying gaps in test suites.

Coverage analysis operates by instrumenting code to track execution paths during test runs. The instrumentation records which statements, branches, functions, or conditions execute, then generates reports showing tested versus untested code. Modern coverage tools integrate seamlessly with testing frameworks, build pipelines, and continuous integration systems.

**Purpose and Limitations**

Coverage metrics serve several purposes:

- Identifying untested code paths requiring attention
- Preventing regression by ensuring critical paths remain tested
- Guiding test development toward neglected areas
- Providing objective quality metrics for teams and stakeholders
- Establishing baseline quality standards for contributions

However, coverage has significant limitations:

- High coverage does not guarantee absence of bugs
- Tests may execute code without meaningful assertions
- Coverage metrics can be gamed through superficial tests
- 100% coverage is often impractical or unnecessary
- Coverage says nothing about test quality or correctness

### Coverage Types and Metrics

#### Statement Coverage

Statement coverage measures the percentage of executable statements executed during testing. It represents the most basic coverage metric, tracking whether each line of code runs at least once.

**Calculation**:

```
Statement Coverage = (Executed Statements / Total Statements) × 100%
```

**Example**:

```javascript
function calculateDiscount(price, isPremium) {
  let discount = 0;                    // Statement 1
  
  if (isPremium) {                     // Statement 2
    discount = price * 0.2;            // Statement 3
  } else {                             // Statement 4
    discount = price * 0.1;            // Statement 5
  }
  
  return price - discount;             // Statement 6
}

// Test covering only premium path
test('premium discount', () => {
  expect(calculateDiscount(100, true)).toBe(80);
});

// Coverage: 5/6 statements = 83.3%
// Statement 5 not executed
```

**Achieving Full Statement Coverage**:

```javascript
test('premium discount', () => {
  expect(calculateDiscount(100, true)).toBe(80);
});

test('standard discount', () => {
  expect(calculateDiscount(100, false)).toBe(90);
});

// Coverage: 6/6 statements = 100%
```

**Strengths**:

- Simple to understand and implement
- Provides baseline coverage metric
- Quickly identifies completely untested code
- Low computational overhead

**Weaknesses**:

- Doesn't verify all logical branches
- Misses decision outcomes
- Can show high coverage with inadequate testing
- Doesn't detect missing error handling

#### Branch Coverage

Branch coverage measures whether each possible branch from decision points executes. Every conditional statement creates at least two branches (true and false), and branch coverage ensures both execute during testing.

**Example**:

```javascript
function processOrder(order, inventory) {
  if (order.quantity <= inventory.available) {    // Branch point 1
    inventory.available -= order.quantity;
    return { success: true, message: 'Order processed' };
  }
  
  if (inventory.restockDate) {                    // Branch point 2
    return { success: false, message: `Available ${inventory.restockDate}` };
  }
  
  return { success: false, message: 'Out of stock' };
}

// Insufficient tests - only covers happy path
test('processes valid order', () => {
  const result = processOrder(
    { quantity: 5 },
    { available: 10 }
  );
  expect(result.success).toBe(true);
});

// Branch coverage: 1/4 branches = 25%
// Branches covered: quantity <= available (true)
// Branches not covered: 
//   - quantity > available (false)
//   - restockDate exists (true)
//   - restockDate doesn't exist (false)
```

**Comprehensive Branch Coverage**:

```javascript
describe('processOrder', () => {
  test('processes valid order', () => {
    const result = processOrder(
      { quantity: 5 },
      { available: 10 }
    );
    expect(result.success).toBe(true);
  });
  
  test('rejects insufficient inventory with restock date', () => {
    const result = processOrder(
      { quantity: 15 },
      { available: 10, restockDate: '2025-01-15' }
    );
    expect(result.success).toBe(false);
    expect(result.message).toContain('2025-01-15');
  });
  
  test('rejects insufficient inventory without restock date', () => {
    const result = processOrder(
      { quantity: 15 },
      { available: 10 }
    );
    expect(result.success).toBe(false);
    expect(result.message).toBe('Out of stock');
  });
});

// Branch coverage: 4/4 branches = 100%
```

**Complex Branch Scenarios**:

```javascript
function validateUser(user) {
  // Multiple conditions create multiple branches
  if (user && user.age >= 18 && user.verified) {
    return { valid: true };
  }
  return { valid: false };
}

// Branch possibilities:
// 1. user is falsy
// 2. user exists, age < 18
// 3. user exists, age >= 18, not verified
// 4. user exists, age >= 18, verified

// Full branch coverage requires all scenarios
describe('validateUser', () => {
  test('null user', () => {
    expect(validateUser(null).valid).toBe(false);
  });
  
  test('underage user', () => {
    expect(validateUser({ age: 16, verified: true }).valid).toBe(false);
  });
  
  test('unverified adult', () => {
    expect(validateUser({ age: 25, verified: false }).valid).toBe(false);
  });
  
  test('verified adult', () => {
    expect(validateUser({ age: 25, verified: true }).valid).toBe(true);
  });
});
```

#### Function Coverage

Function coverage tracks whether each function in the codebase executes at least once during testing. It provides a high-level view of which functions remain completely untested.

**Example**:

```javascript
// utils.js
export function add(a, b) {
  return a + b;
}

export function subtract(a, b) {
  return a - b;
}

export function multiply(a, b) {
  return a * b;
}

export function divide(a, b) {
  if (b === 0) throw new Error('Division by zero');
  return a / b;
}

// Partial test coverage
describe('Math utilities', () => {
  test('addition', () => {
    expect(add(2, 3)).toBe(5);
  });
  
  test('multiplication', () => {
    expect(multiply(4, 5)).toBe(20);
  });
});

// Function coverage: 2/4 = 50%
// Tested: add, multiply
// Untested: subtract, divide
```

**Function Coverage Patterns**:

```javascript
class UserService {
  constructor(database) {
    this.db = database;
  }
  
  async createUser(userData) {          // Function 1
    return await this.db.insert(userData);
  }
  
  async getUser(id) {                   // Function 2
    return await this.db.findById(id);
  }
  
  async updateUser(id, updates) {       // Function 3
    return await this.db.update(id, updates);
  }
  
  async deleteUser(id) {                // Function 4
    return await this.db.delete(id);
  }
  
  async listUsers(filters) {            // Function 5
    return await this.db.find(filters);
  }
}

// Minimal function coverage test suite
describe('UserService', () => {
  let service;
  let mockDb;
  
  beforeEach(() => {
    mockDb = {
      insert: jest.fn(),
      findById: jest.fn(),
      update: jest.fn(),
      delete: jest.fn(),
      find: jest.fn()
    };
    service = new UserService(mockDb);
  });
  
  test('createUser calls database', async () => {
    await service.createUser({ name: 'John' });
    expect(mockDb.insert).toHaveBeenCalled();
  });
  
  test('getUser calls database', async () => {
    await service.getUser(1);
    expect(mockDb.findById).toHaveBeenCalled();
  });
  
  test('updateUser calls database', async () => {
    await service.updateUser(1, { name: 'Jane' });
    expect(mockDb.update).toHaveBeenCalled();
  });
  
  test('deleteUser calls database', async () => {
    await service.deleteUser(1);
    expect(mockDb.delete).toHaveBeenCalled();
  });
  
  test('listUsers calls database', async () => {
    await service.listUsers({ active: true });
    expect(mockDb.find).toHaveBeenCalled();
  });
});

// Function coverage: 5/5 = 100%
// Note: High function coverage but minimal assertion quality
```

#### Condition Coverage

Condition coverage examines individual boolean sub-expressions within decision statements. It ensures each boolean condition evaluates to both true and false independently.

**Example**:

```javascript
function canPurchase(user, product) {
  // Compound condition with two sub-expressions
  if (user.balance >= product.price && user.verified) {
    return true;
  }
  return false;
}

// Branch coverage achieved but not condition coverage
test('verified user with sufficient balance', () => {
  expect(canPurchase(
    { balance: 100, verified: true },
    { price: 50 }
  )).toBe(true);
});

// This test achieves:
// - Branch coverage: true branch covered
// - Condition coverage: incomplete
//   - balance >= price: true (covered), false (not covered)
//   - verified: true (covered), false (not covered)
```

**Full Condition Coverage**:

```javascript
describe('canPurchase', () => {
  // Test 1: Both conditions true
  test('verified user with sufficient balance', () => {
    expect(canPurchase(
      { balance: 100, verified: true },
      { price: 50 }
    )).toBe(true);
  });
  
  // Test 2: First condition false, second true
  test('verified user with insufficient balance', () => {
    expect(canPurchase(
      { balance: 30, verified: true },
      { price: 50 }
    )).toBe(false);
  });
  
  // Test 3: First condition true, second false
  test('unverified user with sufficient balance', () => {
    expect(canPurchase(
      { balance: 100, verified: false },
      { price: 50 }
    )).toBe(false);
  });
  
  // Test 4: Both conditions false
  test('unverified user with insufficient balance', () => {
    expect(canPurchase(
      { balance: 30, verified: false },
      { price: 50 }
    )).toBe(false);
  });
});

// Full condition coverage achieved
// Each sub-expression evaluated to both true and false
```

**Modified Condition/Decision Coverage (MC/DC)**:

MC/DC is a stricter criterion requiring that each condition independently affects the decision outcome:

```javascript
function isEligible(age, citizenship, criminalRecord) {
  return age >= 18 && citizenship === 'US' && !criminalRecord;
}

// MC/DC test cases
describe('isEligible MC/DC', () => {
  // Base case: all conditions true
  test('eligible candidate', () => {
    expect(isEligible(25, 'US', false)).toBe(true);
  });
  
  // Toggle age while keeping others constant
  test('age affects outcome', () => {
    expect(isEligible(16, 'US', false)).toBe(false);
  });
  
  // Toggle citizenship while keeping others constant
  test('citizenship affects outcome', () => {
    expect(isEligible(25, 'CA', false)).toBe(false);
  });
  
  // Toggle criminal record while keeping others constant
  test('criminal record affects outcome', () => {
    expect(isEligible(25, 'US', true)).toBe(false);
  });
});

// Each condition independently shown to affect the outcome
```

#### Path Coverage

Path coverage ensures every possible execution path through the code executes at least once. This is the most comprehensive coverage metric but also the most difficult to achieve, as the number of paths grows exponentially with code complexity.

**Example**:

```javascript
function processPayment(amount, paymentMethod, loyaltyPoints) {
  let finalAmount = amount;
  
  // Path 1-2: Loyalty points discount
  if (loyaltyPoints > 100) {
    finalAmount = amount * 0.9;  // 10% discount
  }
  
  // Path 3-6: Payment method processing
  if (paymentMethod === 'credit') {
    finalAmount += 2.50;  // Processing fee
  } else if (paymentMethod === 'debit') {
    finalAmount += 1.00;  // Lower fee
  }
  
  return finalAmount;
}

// Possible paths:
// 1. loyaltyPoints <= 100, paymentMethod === 'credit'
// 2. loyaltyPoints <= 100, paymentMethod === 'debit'
// 3. loyaltyPoints <= 100, paymentMethod === other
// 4. loyaltyPoints > 100, paymentMethod === 'credit'
// 5. loyaltyPoints > 100, paymentMethod === 'debit'
// 6. loyaltyPoints > 100, paymentMethod === other

describe('processPayment paths', () => {
  test('path 1: no discount, credit card', () => {
    expect(processPayment(100, 'credit', 50)).toBe(102.50);
  });
  
  test('path 2: no discount, debit card', () => {
    expect(processPayment(100, 'debit', 50)).toBe(101.00);
  });
  
  test('path 3: no discount, cash', () => {
    expect(processPayment(100, 'cash', 50)).toBe(100);
  });
  
  test('path 4: with discount, credit card', () => {
    expect(processPayment(100, 'credit', 150)).toBe(92.50);
  });
  
  test('path 5: with discount, debit card', () => {
    expect(processPayment(100, 'debit', 150)).toBe(91.00);
  });
  
  test('path 6: with discount, cash', () => {
    expect(processPayment(100, 'cash', 150)).toBe(90);
  });
});

// Full path coverage: 6/6 paths
```

**Cyclomatic Complexity and Path Explosion**:

```javascript
function complexRouting(a, b, c, d) {
  let result = 0;
  
  if (a > 0) result += 1;      // 2 branches
  if (b > 0) result += 2;      // 2 branches
  if (c > 0) result += 4;      // 2 branches
  if (d > 0) result += 8;      // 2 branches
  
  return result;
}

// Total possible paths: 2^4 = 16 paths
// Path coverage requires 16 distinct test cases

// This demonstrates why 100% path coverage is often impractical
// for complex functions with high cyclomatic complexity
```

#### Line Coverage

Line coverage measures the percentage of code lines executed during testing. It's similar to statement coverage but counts physical lines rather than logical statements.

**Distinction from Statement Coverage**:

```javascript
// Multiple statements per line
function compact(x, y, z) { return x || y || z; }

// Single statement across multiple lines
function verbose(x, y, z) {
  return x ||
         y ||
         z;
}

// Line coverage vs statement coverage may differ
```

### Coverage Tools and Configuration

#### JavaScript/TypeScript Coverage Tools

**Istanbul/NYC**

Istanbul is the most widely-used JavaScript coverage tool, with NYC as its command-line interface:

```bash
# Installation
npm install --save-dev nyc

# Basic usage
nyc npm test

# With specific reporters
nyc --reporter=html --reporter=text npm test

# Configuration in package.json
```

```json
{
  "nyc": {
    "reporter": ["text", "html", "lcov"],
    "include": ["src/**/*.js"],
    "exclude": [
      "**/*.test.js",
      "**/*.spec.js",
      "**/node_modules/**",
      "**/test/**"
    ],
    "all": true,
    "check-coverage": true,
    "lines": 80,
    "functions": 80,
    "branches": 75,
    "statements": 80
  }
}
```

**Jest Built-in Coverage**

Jest includes integrated coverage reporting:

```javascript
// jest.config.js
module.exports = {
  collectCoverage: true,
  collectCoverageFrom: [
    'src/**/*.{js,jsx,ts,tsx}',
    '!src/**/*.test.{js,jsx,ts,tsx}',
    '!src/**/*.spec.{js,jsx,ts,tsx}',
    '!src/index.{js,ts}',
    '!**/node_modules/**',
    '!**/vendor/**'
  ],
  coverageDirectory: 'coverage',
  coverageReporters: ['text', 'html', 'lcov', 'json'],
  coverageThresholds: {
    global: {
      branches: 75,
      functions: 80,
      lines: 80,
      statements: 80
    },
    './src/core/': {
      branches: 90,
      functions: 95,
      lines: 95,
      statements: 95
    }
  }
};
```

```bash
# Run tests with coverage
npm test -- --coverage

# Coverage for specific files
npm test -- --coverage --collectCoverageFrom="src/utils/**/*.js"

# Watch mode with coverage
npm test -- --coverage --watchAll
```

**Coverage Report Formats**:

```javascript
// jest.config.js
module.exports = {
  coverageReporters: [
    'text',           // Console output
    'text-summary',   // Brief console summary
    'html',           // Interactive HTML report
    'lcov',           // LCOV format for CI tools
    'json',           // JSON format for custom processing
    'json-summary',   // Summary in JSON
    'cobertura',      // Cobertura XML (for Jenkins, etc.)
    'clover'          // Clover XML format
  ]
};
```

**Vitest Coverage**

```javascript
// vitest.config.js
import { defineConfig } from 'vitest/config';

export default defineConfig({
  test: {
    coverage: {
      provider: 'v8', // or 'istanbul'
      reporter: ['text', 'json', 'html'],
      include: ['src/**/*.{js,ts}'],
      exclude: [
        'node_modules/',
        'src/**/*.test.{js,ts}',
        'src/**/*.spec.{js,ts}'
      ],
      thresholds: {
        lines: 80,
        functions: 80,
        branches: 75,
        statements: 80
      },
      all: true
    }
  }
});
```

#### Python Coverage Tools

**Coverage.py**

```bash
# Installation
pip install coverage

# Run tests with coverage
coverage run -m pytest

# Generate report
coverage report

# Generate HTML report
coverage html

# Configuration in .coveragerc or pyproject.toml
```

```ini
# .coveragerc
[run]
source = src
omit =
    */tests/*
    */test_*.py
    */__pycache__/*
    */site-packages/*

[report]
precision = 2
show_missing = True
skip_covered = False

exclude_lines =
    pragma: no cover
    def __repr__
    raise AssertionError
    raise NotImplementedError
    if __name__ == .__main__.:
    if TYPE_CHECKING:
    @abstractmethod

[html]
directory = htmlcov
```

```toml
# pyproject.toml
[tool.coverage.run]
source = ["src"]
omit = ["*/tests/*", "*/test_*.py"]

[tool.coverage.report]
precision = 2
show_missing = true
fail_under = 80

[tool.coverage.html]
directory = "htmlcov"
```

**Pytest-cov Plugin**

```bash
# Installation
pip install pytest-cov

# Run with coverage
pytest --cov=src --cov-report=html --cov-report=term

# With branch coverage
pytest --cov=src --cov-branch --cov-report=term-missing
```

```ini
# pytest.ini or setup.cfg
[tool:pytest]
addopts =
    --cov=src
    --cov-branch
    --cov-report=html
    --cov-report=term-missing
    --cov-fail-under=80
```

#### Java Coverage Tools

**JaCoCo**

```xml
<!-- Maven pom.xml -->
<plugin>
    <groupId>org.jacoco</groupId>
    <artifactId>jacoco-maven-plugin</artifactId>
    <version>0.8.11</version>
    <executions>
        <execution>
            <id>prepare-agent</id>
            <goals>
                <goal>prepare-agent</goal>
            </goals>
        </execution>
        <execution>
            <id>report</id>
            <phase>test</phase>
            <goals>
                <goal>report</goal>
            </goals>
        </execution>
        <execution>
            <id>check</id>
            <goals>
                <goal>check</goal>
            </goals>
            <configuration>
                <rules>
                    <rule>
                        <element>PACKAGE</element>
                        <limits>
                            <limit>
                                <counter>LINE</counter>
                                <value>COVEREDRATIO</value>
                                <minimum>0.80</minimum>
                            </limit>
                            <limit>
                                <counter>BRANCH</counter>
                                <value>COVEREDRATIO</value>
                                <minimum>0.75</minimum>
                            </limit>
                        </limits>
                    </rule>
                </rules>
            </configuration>
        </execution>
    </executions>
</plugin>
```

```gradle
// Gradle build.gradle
plugins {
    id 'jacoco'
}

jacoco {
    toolVersion = "0.8.11"
}

jacocoTestReport {
    reports {
        xml.required = true
        html.required = true
        csv.required = false
    }
}

jacocoTestCoverageVerification {
    violationRules {
        rule {
            limit {
                minimum = 0.80
            }
        }
        rule {
            element = 'CLASS'
            limit {
                counter = 'BRANCH'
                value = 'COVEREDRATIO'
                minimum = 0.75
            }
        }
    }
}

test {
    finalizedBy jacocoTestReport
}

check {
    dependsOn jacocoTestCoverageVerification
}
```

### Strategic Coverage Approaches

#### Risk-Based Coverage Prioritization

Not all code requires equal coverage. Risk-based prioritization focuses testing efforts where they provide maximum value:

**High-Priority Areas (90-100% coverage)**:

- Security-critical code (authentication, authorization, cryptography)
- Financial calculations and transactions
- Data persistence and integrity operations
- Public APIs and interfaces
- Core business logic
- Error handling and recovery mechanisms

**Medium-Priority Areas (75-90% coverage)**:

- User input validation
- Data transformations
- Integration points
- Configuration management
- Utility functions
- Common workflows

**Lower-Priority Areas (50-75% coverage)**:

- UI presentation logic (covered by E2E tests)
- Simple getters/setters
- Configuration files
- Generated code
- Deprecated features

**Example Configuration**:

```javascript
// jest.config.js with differentiated thresholds
module.exports = {
  coverageThresholds: {
    // Global minimum
    global: {
      branches: 70,
      functions: 75,
      lines: 75,
      statements: 75
    },
    // Critical authentication module
    './src/auth/': {
      branches: 95,
      functions: 100,
      lines: 95,
      statements: 95
    },
    // Payment processing
    './src/payment/': {
      branches: 90,
      functions: 95,
      lines: 90,
      statements: 90
    },
    // Core business logic
    './src/core/': {
      branches: 85,
      functions: 90,
      lines: 85,
      statements: 85
    },
    // UI components (lower threshold)
    './src/components/': {
      branches: 60,
      functions: 65,
      lines: 65,
      statements: 65
    }
  }
};
```

#### Mutation Testing

Mutation testing evaluates test suite effectiveness by introducing deliberate bugs (mutations) and verifying tests catch them:

**Stryker Mutation Testing**:

```bash
# Installation
npm install --save-dev @stryker-mutator/core @stryker-mutator/jest-runner

# Initialize configuration
npx stryker init

# Run mutation testing
npx stryker run
```

```javascript
// stryker.conf.json
{
  "mutator": "javascript",
  "packageManager": "npm",
  "reporters": ["html", "clear-text", "progress", "dashboard"],
  "testRunner": "jest",
  "coverageAnalysis": "perTest",
  "mutate": [
    "src/**/*.js",
    "!src/**/*.test.js",
    "!src/**/*.spec.js"
  ],
  "thresholds": {
    "high": 80,
    "low": 60,
    "break": 50
  }
}
```

**Example Mutations**:

```javascript
// Original code
function isAdult(age) {
  return age >= 18;
}

// Mutation 1: Change operator
function isAdult(age) {
  return age > 18;  // >= changed to >
}

// Mutation 2: Change constant
function isAdult(age) {
  return age >= 19;  // 18 changed to 19
}

// Mutation 3: Negate condition
function isAdult(age) {
  return age < 18;  // >= changed to 
}

// If tests don't catch these mutations, they're insufficient
```

**Mutation Score Interpretation**:

```javascript
// Strong test suite
test('isAdult boundary cases', () => {
  expect(isAdult(17)).toBe(false);  // Catches boundary mutations
  expect(isAdult(18)).toBe(true);   // Catches constant mutations
  expect(isAdult(19)).toBe(true);   // Catches operator mutations
});

// Mutation Score: 100% (all mutations detected)
```

#### Differential Coverage

Differential coverage focuses on changes rather than absolute coverage, useful for large legacy codebases:

**Git-Based Differential Coverage**:

```javascript
// coverage-diff.js
const { execSync } = require('child_process');
const fs = require('fs');

function getModifiedFiles() {
  const output = execSync('git diff --name-only HEAD~1').toString();
  return output.split('\n').filter(f => f.endsWith('.js'));
}

function getCoverageForFiles(files) {
  const coverageData = JSON.parse(
    fs.readFileSync('./coverage/coverage-summary.json')
  );
  
  const results = {};
  files.forEach(file => {
    const fullPath = `./${file}`;
    if (coverageData[fullPath]) {
      results[file] = coverageData[fullPath];
    }
  });
  
  return results;
}

function checkDifferentialCoverage() {
  const modifiedFiles = getModifiedFiles();
  const coverage = getCoverageForFiles(modifiedFiles);
  
  let passed = true;
  Object.entries(coverage).forEach(([file, metrics]) => {
    console.log(`\n${file}:`);
    console.log(`  Lines: ${metrics.lines.pct}%`);
    console.log(`  Branches: ${metrics.branches.pct}%`);
    
    if (metrics.lines.pct < 80 || metrics.branches.pct < 75) {
      console.log(`  ❌ Below threshold`);
      passed = false;
    } else {
      console.log(`  ✓ Meets threshold`);
    }
  });
  
  if (!passed) {
    process.exit(1);
  }
}

checkDifferentialCoverage();
```

**CI Integration**:

```yaml
# .github/workflows/test.yml
name: Test with Differential Coverage

on: [pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
        with:
          fetch-depth: 2
      
      - name: Install dependencies
        run: npm install
      
      - name: Run tests with coverage
        run: npm test -- --coverage
      
      - name: Check differential coverage
        run: node scripts/coverage-diff.js
      
      - name: Comment PR with coverage
        uses: romeovs/lcov-reporter-action@v0.3.1
        with:
          lcov-file: ./coverage/lcov.info
          github-token: ${{ secrets.GITHUB_TOKEN }}
```

#### Incremental Coverage Improvement

Strategies for improving coverage in existing codebases:

**Baseline and Ratcheting**:

```javascript
// coverage-ratchet.js
const fs = require('fs');

function readBaseline() {
  if (fs.existsSync('./coverage-baseline.json')) {
    return JSON.parse(fs.readFileSync('./coverage-baseline.json'));
  }
  return { lines: 0, branches: 0, functions: 0, statements: 0 };
}

function getCurrentCoverage() {
  const summary = JSON.parse(
    fs.readFileSync('./coverage/coverage-summary.json')
  );
  return summary.total;
}

function updateBaseline(current) {
  const baseline = readBaseline();
  
  const updated = {
    lines: Math.max(baseline.lines, current.lines.pct),
    branches: Math.max(baseline.branches, current.branches.pct),
    functions: Math.max(baseline.functions, current.functions.pct),
    statements: Math.max(baseline.statements, current.statements.pct)
  };
  
  fs.writeFileSync(
    './coverage-baseline.json',
    JSON.stringify(updated, null, 2)
  );
  
  return updated;
}

function checkRatchet() {
  const baseline = readBaseline();
  const current = getCurrentCoverage();
  
  console.log('Coverage Ratchet Check:');
  console.log(`Lines: ${current.lines.pct}% (baseline: ${baseline.lines}%)`);
  console.log(`Branches: ${current.branches.pct}% (baseline: ${baseline.branches}%)`);
  console.log(`Functions: ${current.functions.pct}% (baseline: ${baseline.functions}%)`);
  console.log(`Statements: ${current.statements.pct}% (baseline: ${baseline.statements}%)`);
  
  const passed = 
    current.lines.pct >= baseline.lines &&
    current.branches.pct >= baseline.branches &&
    current.functions.pct >= baseline.functions &&
    current.statements.pct >= baseline.statements;
  
  if (passed) {
    updateBaseline(current);
    console.log('\n✓ Coverage maintained or improved. Baseline updated.');
    process.exit(0);
  } else {
    console.log('\n✗ Coverage decreased below baseline.');
    process.exit(1);
  }
}

checkRatchet();
```

**Focused Coverage Campaigns**:

```javascript
// coverage-gap-analysis.js
const fs = require('fs');
const path = require('path');

function analyzeCoverageGaps() {
  const coverageData = JSON.parse(
    fs.readFileSync('./coverage/coverage-final.json')
  );
  
  const gaps = [];
  
  for (const [filePath, fileData] of Object.entries(coverageData)) {
    const coverage = fileData.s; // statement coverage
    const uncoveredLines = Object.entries(coverage)
      .filter(([_, count]) => count === 0)
      .map(([line]) => parseInt(line));
    
    if (uncoveredLines.length > 0) {
      gaps.push({
        file: filePath,
        uncoveredLines: uncoveredLines.length,
        totalLines: Object.keys(coverage).length,
        percentage: (uncoveredLines.length / Object.keys(coverage).length) * 100,
        lines: uncoveredLines
      });
    }
  }
  
  // Prioritize by business impact
  gaps.sort((a, b) => {
    const criticalPaths = ['auth', 'payment', 'security'];
    const aIsCritical = criticalPaths.some(p => a.file.includes(p));
    const bIsCritical = criticalPaths.some(p => b.file.includes(p));
    
    if (aIsCritical && !bIsCritical) return -1;
    if (!aIsCritical && bIsCritical) return 1;
    return b.percentage - a.percentage;
  });
  
  return gaps;
}

function generateCoverageReport() {
  const gaps = analyzeCoverageGaps();
  
  console.log('Coverage Gap Analysis\n');
  console.log('Priority Files to Test:\n');
  
  gaps.slice(0, 10).forEach((gap, index) => {
    console.log(`${index + 1}. ${gap.file}`);
    console.log(`   Uncovered: ${gap.uncoveredLines} lines (${gap.percentage.toFixed(1)}%)`);
    console.log(`   Lines: ${gap.lines.join(', ')}\n`);
  });
  
  // Generate focused test file template
  const topGap = gaps[0];
  if (topGap) {
    const testTemplate = generateTestTemplate(topGap);
    console.log('\nSuggested Test Template:\n');
    console.log(testTemplate);
  }
}

function generateTestTemplate(gap) {
  const fileName = path.basename(gap.file, '.js');
  return `
// ${fileName}.test.js
describe('${fileName}', () => {
  // Focus on uncovered lines: ${gap.lines.join(', ')}
  
  describe('Edge cases', () => {
    it('should handle error conditions', () => {
      // Test error paths
    });
    
    it('should handle boundary conditions', () => {
      // Test edge cases
    });
  });
  
  describe('Integration scenarios', () => {
    it('should work in production-like scenarios', () => {
      // Test realistic use cases
    });
  });
});
`;
}

generateCoverageReport();
```

**Legacy Code Coverage Strategy**:

```javascript
// characterization-test.js
const fs = require('fs');

class CharacterizationTestGenerator {
  constructor(targetFile) {
    this.targetFile = targetFile;
    this.observations = [];
  }
  
  observe(input, output, description) {
    this.observations.push({ input, output, description });
  }
  
  generateTests() {
    const testCode = `
// Characterization tests for ${this.targetFile}
// These tests document current behavior before refactoring

const { ${this.getFunctionNames()} } = require('${this.targetFile}');

describe('Characterization Tests - ${this.targetFile}', () => {
  // WARNING: These tests document CURRENT behavior, not CORRECT behavior
  // Review and update assertions if behavior should change
  
${this.observations.map(obs => `
  it('${obs.description}', () => {
    const result = ${this.generateFunctionCall(obs.input)};
    expect(result).toEqual(${JSON.stringify(obs.output)});
  });
`).join('\n')}
  
  describe('Boundary conditions', () => {
    it('should handle null input', () => {
      // Add test after observing behavior
    });
    
    it('should handle undefined input', () => {
      // Add test after observing behavior
    });
    
    it('should handle empty input', () => {
      // Add test after observing behavior
    });
  });
  
  describe('Error conditions', () => {
    it('should handle invalid data types', () => {
      // Add test after observing behavior
    });
    
    it('should handle out-of-range values', () => {
      // Add test after observing behavior
    });
  });
});
`;
    return testCode;
  }
  
  getFunctionNames() {
    // [Inference] Simplified extraction
    return 'legacyFunction';
  }
  
  generateFunctionCall(input) {
    return `legacyFunction(${JSON.stringify(input)})`;
  }
}

// Usage example
const generator = new CharacterizationTestGenerator('./legacy-module.js');

// Observe current behavior
generator.observe({ id: 1 }, { result: 'success' }, 'handles valid ID');
generator.observe({ id: -1 }, { error: 'invalid' }, 'rejects negative ID');
generator.observe({}, null, 'returns null for empty object');

console.log(generator.generateTests());
```

#### Coverage for Different Code Types

**API Endpoint Coverage**:

```javascript
// api-coverage-test.js
const request = require('supertest');
const app = require('../app');

describe('API Coverage Tests', () => {
  describe('GET /api/users/:id', () => {
    it('should cover success path (200)', async () => {
      const response = await request(app)
        .get('/api/users/1')
        .expect(200);
      
      expect(response.body).toHaveProperty('id');
      expect(response.body).toHaveProperty('name');
    });
    
    it('should cover not found path (404)', async () => {
      await request(app)
        .get('/api/users/999999')
        .expect(404);
    });
    
    it('should cover invalid ID path (400)', async () => {
      await request(app)
        .get('/api/users/invalid')
        .expect(400);
    });
    
    it('should cover authentication failure (401)', async () => {
      await request(app)
        .get('/api/users/1')
        .set('Authorization', 'Bearer invalid-token')
        .expect(401);
    });
    
    it('should cover authorization failure (403)', async () => {
      await request(app)
        .get('/api/users/1')
        .set('Authorization', 'Bearer valid-but-insufficient-token')
        .expect(403);
    });
    
    it('should cover server error path (500)', async () => {
      // Mock database failure
      jest.spyOn(db, 'query').mockRejectedValue(new Error('DB Error'));
      
      await request(app)
        .get('/api/users/1')
        .expect(500);
    });
    
    it('should cover rate limiting (429)', async () => {
      // Make multiple requests to trigger rate limit
      for (let i = 0; i < 100; i++) {
        await request(app).get('/api/users/1');
      }
      
      await request(app)
        .get('/api/users/1')
        .expect(429);
    });
  });
  
  describe('POST /api/users', () => {
    it('should cover valid creation (201)', async () => {
      const newUser = {
        name: 'Test User',
        email: 'test@example.com',
        age: 25
      };
      
      const response = await request(app)
        .post('/api/users')
        .send(newUser)
        .expect(201);
      
      expect(response.body).toHaveProperty('id');
    });
    
    it('should cover validation errors (400)', async () => {
      const invalidUser = {
        name: '', // Empty name
        email: 'not-an-email', // Invalid email
        age: -5 // Invalid age
      };
      
      const response = await request(app)
        .post('/api/users')
        .send(invalidUser)
        .expect(400);
      
      expect(response.body).toHaveProperty('errors');
      expect(response.body.errors).toHaveLength(3);
    });
    
    it('should cover duplicate entry (409)', async () => {
      const user = {
        name: 'Existing User',
        email: 'existing@example.com'
      };
      
      await request(app).post('/api/users').send(user);
      
      await request(app)
        .post('/api/users')
        .send(user)
        .expect(409);
    });
    
    it('should cover malformed JSON (400)', async () => {
      await request(app)
        .post('/api/users')
        .set('Content-Type', 'application/json')
        .send('{ invalid json }')
        .expect(400);
    });
  });
});
```

**Async/Promise Coverage**:


```javascript
// async-coverage-test.js

describe('Async Operation Coverage', () => {
  describe('Promise-based operations', () => {
    it('should cover successful resolution', async () => {
      const result = await fetchData('valid-id');
      expect(result).toBeDefined();
    });
    
    it('should cover rejection', async () => {
      await expect(fetchData('invalid-id')).rejects.toThrow('Not found');
    });
    
    it('should cover timeout', async () => {
      jest.setTimeout(1000);
      await expect(fetchData('slow-id')).rejects.toThrow('Timeout');
    });
    
    it('should cover pending state handling', () => {
      const promise = fetchData('test-id');
      expect(promise).toBeInstanceOf(Promise);
      // Don't await - testing pending state
    });
  });
  
  describe('Callback-based operations', () => {
    it('should cover success callback', (done) => {
      fetchDataCallback('valid-id', (err, data) => {
        expect(err).toBeNull();
        expect(data).toBeDefined();
        done();
      });
    });
    
    it('should cover error callback', (done) => {
      fetchDataCallback('invalid-id', (err, data) => {
        expect(err).toBeDefined();
        expect(data).toBeUndefined();
        done();
      });
    });
  });
  
  describe('Async/await error handling', () => {
    it('should cover try-catch blocks', async () => {
      try {
        await fetchData('invalid-id');
        fail('Should have thrown');
      } catch (error) {
        expect(error.message).toBe('Not found');
      }
    });
    
    it('should cover finally blocks', async () => {
      const cleanup = jest.fn();
      try {
        await fetchData('valid-id');
      } finally {
        cleanup();
      }
      expect(cleanup).toHaveBeenCalled();
    });
    
    it('should cover nested async operations', async () => {
      const result1 = await fetchData('id-1');
      const result2 = await fetchData(result1.nextId);
      expect(result2).toBeDefined();
    });
  });
  
  describe('Concurrent async operations', () => {
    it('should cover Promise.all success', async () => {
      const results = await Promise.all([
        fetchData('id-1'),
        fetchData('id-2'),
        fetchData('id-3')
      ]);
      expect(results).toHaveLength(3);
    });
    
    it('should cover Promise.all failure', async () => {
      await expect(
        Promise.all([
          fetchData('id-1'),
          fetchData('invalid-id'),
          fetchData('id-3')
        ])
      ).rejects.toThrow();
    });
    
    it('should cover Promise.allSettled', async () => {
      const results = await Promise.allSettled([
        fetchData('id-1'),
        fetchData('invalid-id'),
        fetchData('id-3')
      ]);
      expect(results[0].status).toBe('fulfilled');
      expect(results[1].status).toBe('rejected');
      expect(results[2].status).toBe('fulfilled');
    });
    
    it('should cover Promise.race', async () => {
      const result = await Promise.race([
        fetchData('fast-id'),
        fetchData('slow-id')
      ]);
      expect(result).toBeDefined();
    });
  });
  
  describe('Async generator coverage', () => {
    it('should cover async iteration', async () => {
      const results = [];
      for await (const item of fetchDataStream()) {
        results.push(item);
      }
      expect(results.length).toBeGreaterThan(0);
    });
    
    it('should cover early break in async iteration', async () => {
      const results = [];
      for await (const item of fetchDataStream()) {
        results.push(item);
        if (results.length === 2) break;
      }
      expect(results).toHaveLength(2);
    });
  });
});
```

#### Error Boundary Coverage

```javascript
// error-boundary-coverage-test.js
describe('Error Boundary Coverage', () => {
  describe('Network errors', () => {
    it('should cover network timeout', async () => {
      fetchMock.mockAbortOnce();
      await expect(fetchWithTimeout('/api/data', 1000))
        .rejects.toThrow('Request timeout');
    });
    
    it('should cover network failure', async () => {
      fetchMock.mockRejectOnce(new Error('Network error'));
      await expect(fetchData('/api/data'))
        .rejects.toThrow('Network error');
    });
    
    it('should cover DNS resolution failure', async () => {
      fetchMock.mockRejectOnce(new TypeError('Failed to fetch'));
      await expect(fetchData('http://invalid.domain'))
        .rejects.toThrow('Failed to fetch');
    });
  });
  
  describe('HTTP error responses', () => {
    it('should cover 4xx client errors', async () => {
      fetchMock.mockResponseOnce('', { status: 400 });
      await expect(fetchData('/api/data'))
        .rejects.toThrow('Bad Request');
      
      fetchMock.mockResponseOnce('', { status: 401 });
      await expect(fetchData('/api/data'))
        .rejects.toThrow('Unauthorized');
      
      fetchMock.mockResponseOnce('', { status: 404 });
      await expect(fetchData('/api/data'))
        .rejects.toThrow('Not Found');
    });
    
    it('should cover 5xx server errors', async () => {
      fetchMock.mockResponseOnce('', { status: 500 });
      await expect(fetchData('/api/data'))
        .rejects.toThrow('Internal Server Error');
      
      fetchMock.mockResponseOnce('', { status: 503 });
      await expect(fetchData('/api/data'))
        .rejects.toThrow('Service Unavailable');
    });
  });
  
  describe('Response parsing errors', () => {
    it('should cover JSON parse errors', async () => {
      fetchMock.mockResponseOnce('invalid json');
      await expect(fetchData('/api/data'))
        .rejects.toThrow('Invalid JSON');
    });
    
    it('should cover empty response', async () => {
      fetchMock.mockResponseOnce('');
      const result = await fetchData('/api/data');
      expect(result).toBeNull();
    });
    
    it('should cover malformed content-type', async () => {
      fetchMock.mockResponseOnce('data', {
        headers: { 'content-type': 'invalid' }
      });
      await expect(fetchData('/api/data'))
        .rejects.toThrow('Unsupported content type');
    });
  });
  
  describe('Retry logic coverage', () => {
    it('should cover successful retry', async () => {
      fetchMock
        .mockRejectOnce(new Error('Network error'))
        .mockRejectOnce(new Error('Network error'))
        .mockResponseOnce(JSON.stringify({ data: 'success' }));
      
      const result = await fetchWithRetry('/api/data', { maxRetries: 3 });
      expect(result.data).toBe('success');
      expect(fetchMock).toHaveBeenCalledTimes(3);
    });
    
    it('should cover retry exhaustion', async () => {
      fetchMock
        .mockReject(new Error('Network error'));
      
      await expect(fetchWithRetry('/api/data', { maxRetries: 3 }))
        .rejects.toThrow('Max retries exceeded');
      expect(fetchMock).toHaveBeenCalledTimes(3);
    });
    
    it('should cover exponential backoff', async () => {
      const delays = [];
      const mockDelay = jest.spyOn(global, 'setTimeout')
        .mockImplementation((cb, delay) => {
          delays.push(delay);
          cb();
          return 0;
        });
      
      fetchMock
        .mockRejectOnce(new Error('Error'))
        .mockRejectOnce(new Error('Error'))
        .mockResponseOnce(JSON.stringify({ data: 'success' }));
      
      await fetchWithRetry('/api/data', { 
        maxRetries: 3,
        backoff: 'exponential'
      });
      
      expect(delays[0]).toBe(1000);
      expect(delays[1]).toBe(2000);
      mockDelay.mockRestore();
    });
  });
  
  describe('Abort signal coverage', () => {
    it('should cover manual abort', async () => {
      const controller = new AbortController();
      const promise = fetchData('/api/data', { 
        signal: controller.signal 
      });
      
      controller.abort();
      
      await expect(promise).rejects.toThrow('The operation was aborted');
    });
    
    it('should cover timeout abort', async () => {
      fetchMock.mockResponseOnce(
        () => new Promise(resolve => setTimeout(resolve, 2000))
      );
      
      await expect(
        fetchWithTimeout('/api/data', 1000)
      ).rejects.toThrow('Request timeout');
    });
  });
});
```

#### Request/Response Coverage

```javascript
// request-response-coverage-test.js
describe('Request/Response Coverage', () => {
  describe('Request methods', () => {
    it('should cover GET requests', async () => {
      fetchMock.mockResponseOnce(JSON.stringify({ data: 'test' }));
      
      const response = await fetch('/api/data');
      const data = await response.json();
      
      expect(fetchMock).toHaveBeenCalledWith('/api/data', {
        method: 'GET'
      });
      expect(data).toEqual({ data: 'test' });
    });

    it('should cover POST requests with body', async () => {
      fetchMock.mockResponseOnce(JSON.stringify({ id: 1 }));
      
      const payload = { name: 'test' };
      const response = await fetch('/api/users', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload)
      });
      
      expect(fetchMock).toHaveBeenCalledWith('/api/users', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload)
      });
    });

    it('should cover PUT requests', async () => {
      fetchMock.mockResponseOnce(JSON.stringify({ updated: true }));
      
      await fetch('/api/users/1', {
        method: 'PUT',
        body: JSON.stringify({ name: 'updated' })
      });
      
      expect(fetchMock).toHaveBeenCalledWith(
        expect.stringContaining('/api/users/1'),
        expect.objectContaining({ method: 'PUT' })
      );
    });

    it('should cover DELETE requests', async () => {
      fetchMock.mockResponseOnce('', { status: 204 });
      
      const response = await fetch('/api/users/1', {
        method: 'DELETE'
      });
      
      expect(response.status).toBe(204);
      expect(fetchMock).toHaveBeenCalledWith(
        '/api/users/1',
        expect.objectContaining({ method: 'DELETE' })
      );
    });

    it('should cover PATCH requests', async () => {
      fetchMock.mockResponseOnce(JSON.stringify({ patched: true }));
      
      await fetch('/api/users/1', {
        method: 'PATCH',
        body: JSON.stringify({ email: 'new@example.com' })
      });
      
      expect(fetchMock).toHaveBeenCalledWith(
        '/api/users/1',
        expect.objectContaining({ method: 'PATCH' })
      );
    });
  });

  describe('Request headers', () => {
    it('should cover various header combinations', async () => {
      fetchMock.mockResponseOnce(JSON.stringify({}));
      
      await fetch('/api/data', {
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer token123',
          'X-Custom-Header': 'custom-value',
          'Accept': 'application/json'
        }
      });
      
      const [, options] = fetchMock.mock.calls[0];
      expect(options.headers).toEqual({
        'Content-Type': 'application/json',
        'Authorization': 'Bearer token123',
        'X-Custom-Header': 'custom-value',
        'Accept': 'application/json'
      });
    });

    it('should cover Headers object usage', async () => {
      fetchMock.mockResponseOnce(JSON.stringify({}));
      
      const headers = new Headers();
      headers.append('Content-Type', 'application/json');
      headers.append('Authorization', 'Bearer token');
      
      await fetch('/api/data', { headers });
      
      const [, options] = fetchMock.mock.calls[0];
      expect(options.headers).toBeInstanceOf(Headers);
    });

    it('should cover missing headers', async () => {
      fetchMock.mockResponseOnce(JSON.stringify({}));
      
      await fetch('/api/data'); // No headers
      
      const [, options] = fetchMock.mock.calls[0];
      expect(options?.headers).toBeUndefined();
    });
  });

  describe('Request body types', () => {
    it('should cover JSON body', async () => {
      fetchMock.mockResponseOnce(JSON.stringify({}));
      
      const body = { key: 'value', nested: { data: 'test' } };
      await fetch('/api/data', {
        method: 'POST',
        body: JSON.stringify(body)
      });
      
      const [, options] = fetchMock.mock.calls[0];
      expect(JSON.parse(options.body)).toEqual(body);
    });

    it('should cover FormData body', async () => {
      fetchMock.mockResponseOnce(JSON.stringify({}));
      
      const formData = new FormData();
      formData.append('file', new Blob(['content']), 'test.txt');
      formData.append('name', 'test');
      
      await fetch('/api/upload', {
        method: 'POST',
        body: formData
      });
      
      const [, options] = fetchMock.mock.calls[0];
      expect(options.body).toBeInstanceOf(FormData);
    });

    it('should cover URLSearchParams body', async () => {
      fetchMock.mockResponseOnce(JSON.stringify({}));
      
      const params = new URLSearchParams();
      params.append('key1', 'value1');
      params.append('key2', 'value2');
      
      await fetch('/api/data', {
        method: 'POST',
        body: params
      });
      
      const [, options] = fetchMock.mock.calls[0];
      expect(options.body).toBeInstanceOf(URLSearchParams);
    });

    it('should cover Blob body', async () => {
      fetchMock.mockResponseOnce(JSON.stringify({}));
      
      const blob = new Blob(['binary data'], { type: 'application/octet-stream' });
      await fetch('/api/upload', {
        method: 'POST',
        body: blob
      });
      
      const [, options] = fetchMock.mock.calls[0];
      expect(options.body).toBeInstanceOf(Blob);
    });

    it('should cover ArrayBuffer body', async () => {
      fetchMock.mockResponseOnce(JSON.stringify({}));
      
      const buffer = new ArrayBuffer(8);
      await fetch('/api/binary', {
        method: 'POST',
        body: buffer
      });
      
      const [, options] = fetchMock.mock.calls[0];
      expect(options.body).toBeInstanceOf(ArrayBuffer);
    });

    it('should cover plain text body', async () => {
      fetchMock.mockResponseOnce(JSON.stringify({}));
      
      await fetch('/api/data', {
        method: 'POST',
        body: 'plain text content'
      });
      
      const [, options] = fetchMock.mock.calls[0];
      expect(options.body).toBe('plain text content');
    });
  });

  describe('Response status codes', () => {
    it('should cover 2xx success responses', async () => {
      const successCodes = [200, 201, 202, 203, 204, 205, 206];
      
      for (const code of successCodes) {
        fetchMock.mockResponseOnce('', { status: code });
        const response = await fetch('/api/data');
        expect(response.status).toBe(code);
        expect(response.ok).toBe(true);
      }
    });

    it('should cover 3xx redirection responses', async () => {
      const redirectCodes = [300, 301, 302, 303, 304, 307, 308];
      
      for (const code of redirectCodes) {
        fetchMock.mockResponseOnce('', { 
          status: code,
          headers: { 'Location': '/new-location' }
        });
        const response = await fetch('/api/data');
        expect(response.status).toBe(code);
        expect(response.ok).toBe(false);
      }
    });

    it('should cover 4xx client error responses', async () => {
      const clientErrors = [400, 401, 403, 404, 405, 406, 408, 409, 410, 415, 422, 429];
      
      for (const code of clientErrors) {
        fetchMock.mockResponseOnce(JSON.stringify({ error: 'Client error' }), { 
          status: code 
        });
        const response = await fetch('/api/data');
        expect(response.status).toBe(code);
        expect(response.ok).toBe(false);
      }
    });

    it('should cover 5xx server error responses', async () => {
      const serverErrors = [500, 501, 502, 503, 504, 505];
      
      for (const code of serverErrors) {
        fetchMock.mockResponseOnce(JSON.stringify({ error: 'Server error' }), { 
          status: code 
        });
        const response = await fetch('/api/data');
        expect(response.status).toBe(code);
        expect(response.ok).toBe(false);
      }
    });

    it('should cover edge case status codes', async () => {
      const edgeCases = [
        { code: 100, description: 'Continue' },
        { code: 101, description: 'Switching Protocols' },
        { code: 418, description: "I'm a teapot" },
        { code: 451, description: 'Unavailable For Legal Reasons' },
        { code: 511, description: 'Network Authentication Required' }
      ];
      
      for (const { code } of edgeCases) {
        fetchMock.mockResponseOnce('', { status: code });
        const response = await fetch('/api/data');
        expect(response.status).toBe(code);
      }
    });
  });

  describe('Response headers', () => {
    it('should cover standard response headers', async () => {
      fetchMock.mockResponseOnce(JSON.stringify({}), {
        headers: {
          'Content-Type': 'application/json',
          'Cache-Control': 'no-cache',
          'ETag': '"abc123"',
          'Last-Modified': 'Wed, 21 Oct 2015 07:28:00 GMT',
          'Content-Length': '1234',
          'Content-Encoding': 'gzip',
          'X-RateLimit-Limit': '100',
          'X-RateLimit-Remaining': '99'
        }
      });
      
      const response = await fetch('/api/data');
      expect(response.headers.get('Content-Type')).toBe('application/json');
      expect(response.headers.get('Cache-Control')).toBe('no-cache');
      expect(response.headers.get('ETag')).toBe('"abc123"');
      expect(response.headers.get('X-RateLimit-Limit')).toBe('100');
    });

    it('should cover CORS headers', async () => {
      fetchMock.mockResponseOnce(JSON.stringify({}), {
        headers: {
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE',
          'Access-Control-Allow-Headers': 'Content-Type, Authorization',
          'Access-Control-Max-Age': '86400',
          'Access-Control-Expose-Headers': 'X-Custom-Header'
        }
      });
      
      const response = await fetch('/api/data');
      expect(response.headers.get('Access-Control-Allow-Origin')).toBe('*');
      expect(response.headers.get('Access-Control-Allow-Methods')).toContain('POST');
    });

    it('should cover security headers', async () => {
      fetchMock.mockResponseOnce(JSON.stringify({}), {
        headers: {
          'Strict-Transport-Security': 'max-age=31536000; includeSubDomains',
          'X-Content-Type-Options': 'nosniff',
          'X-Frame-Options': 'DENY',
          'X-XSS-Protection': '1; mode=block',
          'Content-Security-Policy': "default-src 'self'"
        }
      });
      
      const response = await fetch('/api/data');
      expect(response.headers.get('Strict-Transport-Security')).toContain('max-age');
      expect(response.headers.get('X-Content-Type-Options')).toBe('nosniff');
    });

    it('should cover custom headers', async () => {
      fetchMock.mockResponseOnce(JSON.stringify({}), {
        headers: {
          'X-Request-ID': 'req-123456',
          'X-Server-Version': '1.0.0',
          'X-Processing-Time': '123ms',
          'X-Custom-Data': 'custom-value'
        }
      });
      
      const response = await fetch('/api/data');
      expect(response.headers.get('X-Request-ID')).toBe('req-123456');
      expect(response.headers.get('X-Server-Version')).toBe('1.0.0');
    });

    it('should cover headers iteration', async () => {
      fetchMock.mockResponseOnce(JSON.stringify({}), {
        headers: {
          'X-A': '1',
          'X-B': '2'
        }
      });
      
      const response = await fetch('/api/data');
      const entries = [];
      for (const [name, value] of response.headers.entries()) {
        entries.push([name, value]);
      }
      
      expect(entries).toContainEqual(['x-a', '1']);
      expect(entries).toContainEqual(['x-b', '2']);
    });
  });

  describe('Error handling and edge cases', () => {
    it('should cover network failures (TypeError)', async () => {
      fetchMock.mockReject(new TypeError('Failed to fetch'));
      
      await expect(fetch('/api/data')).rejects.toThrow(TypeError);
    });

    it('should cover AbortController signaling', async () => {
      const controller = new AbortController();
      fetchMock.mockAbort();
      
      const fetchPromise = fetch('/api/data', { signal: controller.signal });
      controller.abort();
      
      await expect(fetchPromise).rejects.toThrow();
    });

    it('should cover timeout simulations', async () => {
      fetchMock.mockResponseOnce(
        () => new Promise(resolve => setTimeout(() => resolve({ body: 'ok' }), 100))
      );
      
      const response = await fetch('/api/data');
      expect(await response.text()).toBe('ok');
    });
  });
});
```

