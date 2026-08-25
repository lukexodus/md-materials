## Declarative vs Imperative


Declarative programming describes _what_ you want to achieve, while imperative programming specifies _how_ to achieve it through explicit step-by-step instructions. Functional programming strongly favors the declarative style.

### Imperative Style

Imperative code focuses on control flow—loops, conditionals, and state mutations that describe the algorithm's execution sequence.

**Example:**

```javascript
// Imperative: How to filter and transform
const numbers = [1, 2, 3, 4, 5];
const result = [];

for (let i = 0; i < numbers.length; i++) {
  if (numbers[i] % 2 === 0) {
    result.push(numbers[i] * 2);
  }
}
```

### Declarative Style

Declarative code expresses the desired outcome using higher-order functions and composition, abstracting away implementation details.

**Example:**

```javascript
// Declarative: What to achieve
const numbers = [1, 2, 3, 4, 5];
const result = numbers
  .filter(n => n % 2 === 0)
  .map(n => n * 2);
```

### Abstraction Levels

Declarative programming operates at higher abstraction levels. Functions like `map`, `filter`, and `reduce` encapsulate common patterns, letting you focus on business logic rather than iteration mechanics.

**Example:**

```javascript
// Imperative: Manual summation
let sum = 0;
for (let i = 0; i < numbers.length; i++) {
  sum += numbers[i];
}

// Declarative: Express intent
const sum = numbers.reduce((acc, n) => acc + n, 0);
```

### Readability and Intent

Declarative code often reads closer to natural language, making intent clearer. The "what" is immediately visible without parsing through implementation details.

**Example:**

```javascript
// Imperative
const adults = [];
for (let i = 0; i < users.length; i++) {
  if (users[i].age >= 18) {
    adults.push(users[i]);
  }
}

// Declarative
const adults = users.filter(user => user.age >= 18);
```

### Composability

Declarative functions compose more naturally. You can chain operations to build complex transformations from simple, reusable pieces.

**Example:**

```javascript
const processData = (data) => data
  .filter(isValid)
  .map(normalize)
  .sort(byPriority)
  .slice(0, 10);
```

**Key Points:**

- Imperative: explicit control flow and state management
- Declarative: express desired outcomes, not implementation
- Higher abstraction improves readability and maintainability
- Declarative style enables better composition
- Focus shifts from "how" to "what"

---

