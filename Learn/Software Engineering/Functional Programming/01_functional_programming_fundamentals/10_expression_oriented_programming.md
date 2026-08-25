## Expression-Oriented Programming


Expression-oriented programming treats code as expressions that evaluate to values, rather than statements that perform actions. Every construct returns a value, enabling more composable and functional code structures.

### Expressions vs Statements

Expressions produce values; statements perform actions. Functional programming maximizes expression usage because expressions can be composed, assigned, and passed as arguments.

**Example:**

```javascript
// Statement (no return value)
let result;
if (condition) {
  result = "yes";
} else {
  result = "no";
}

// Expression (returns value)
const result = condition ? "yes" : "no";
```

### Everything Returns a Value

In expression-oriented languages, constructs like conditionals, loops, and pattern matching return values, eliminating the need for temporary variables and state mutations.

**Example:**

```javascript
// Statement-based
let grade;
if (score >= 90) {
  grade = 'A';
} else if (score >= 80) {
  grade = 'B';
} else {
  grade = 'C';
}

// Expression-based
const grade = 
  score >= 90 ? 'A' :
  score >= 80 ? 'B' : 'C';
```

### Function Bodies as Expressions

Function bodies consisting of single expressions don't require explicit `return` statements, promoting concise and readable code.

**Example:**

```javascript
// Statement-based
const double = (x) => {
  return x * 2;
};

// Expression-based
const double = (x) => x * 2;

// Complex expression
const processUser = (user) => ({
  ...user,
  fullName: `${user.firstName} ${user.lastName}`,
  isAdult: user.age >= 18
});
```

### Block Expressions

Some languages allow blocks to act as expressions, where the last evaluated expression becomes the block's value.

**Example (Rust-like syntax):**

```rust
let result = {
  let x = compute();
  let y = transform(x);
  y * 2  // Last expression is returned
};
```

### Eliminating Intermediate State

Expression-oriented programming reduces reliance on intermediate variables by allowing direct composition and nesting of operations.

**Example:**

```javascript
// Multiple statements with intermediate state
const data = fetchData();
const filtered = data.filter(isValid);
const transformed = filtered.map(normalize);
const result = transformed.reduce(aggregate, initial);

// Single expression chain
const result = fetchData()
  .filter(isValid)
  .map(normalize)
  .reduce(aggregate, initial);
```

### Pattern Matching as Expressions

Pattern matching constructs evaluate to values based on matched patterns, replacing verbose conditional chains.

**Example (conceptual):**

```javascript
const getShippingCost = (order) => 
  match(order) {
    { total > 100 } => 0,
    { total > 50 } => 5,
    { weight > 10 } => 15,
    _ => 10
  };
```

### Comprehensions

List/array comprehensions are expressions that generate collections through declarative transformations rather than imperative loops.

**Example:**

```python
# Python comprehension (expression)
squares = [x**2 for x in range(10) if x % 2 == 0]

# Imperative equivalent (statements)
squares = []
for x in range(10):
    if x % 2 == 0:
        squares.append(x**2)
```

**Key Points:**

- Expressions produce values; statements perform actions
- Expression-oriented code maximizes composability
- Eliminates intermediate variables and mutations
- Conditional expressions replace statement-based branching
- Single-expression functions are more concise
- Pattern matching provides declarative control flow

