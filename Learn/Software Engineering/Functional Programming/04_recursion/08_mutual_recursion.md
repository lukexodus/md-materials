## Mutual Recursion


Mutual recursion occurs when two or more functions call each other recursively. This pattern naturally expresses certain algorithms like state machines, grammar parsing, and even/odd determination.

### Basic Pattern

**Example:**

```javascript
function isEven(n) {
  if (n === 0) return true;
  return isOdd(n - 1);
}

function isOdd(n) {
  if (n === 0) return false;
  return isEven(n - 1);
}
```

### Use Cases

**State machines** - Each state is a function that transitions to other state functions based on input.

**Grammar parsing** - Mutually recursive descent parsers where each non-terminal is a function.

**Expression evaluation** - Evaluating expressions with multiple syntactic categories (terms, factors, atoms).

**Tree traversal** - Processing trees with different node types that require different handling.

**Game logic** - Alternating between player turns or game states.

### Challenges

**Stack overflow** - Mutual recursion suffers from stack depth limits like regular recursion, but TCO may not apply because calls aren't necessarily in tail position.

**Complexity** - Multiple interconnected functions increase cognitive load and make debugging harder.

**Forward references** - Some languages require forward declarations or careful ordering when functions reference each other.

**Testing** - Testing mutually recursive functions requires considering multiple execution paths across function boundaries.

### Tail Call Optimization with Mutual Recursion

[Inference] TCO can optimize mutually recursive functions if each recursive call is in tail position, but language support varies.

**Example:**

```javascript
function evenTail(n, result = true) {
  if (n === 0) return result;
  return oddTail(n - 1, !result);  // Tail call to other function
}

function oddTail(n, result = false) {
  if (n === 0) return result;
  return evenTail(n - 1, !result);  // Tail call to other function
}
```

### Trampolining Mutual Recursion

Trampolining works particularly well with mutual recursion because it eliminates stack concerns entirely.

**Example:**

```javascript
function evenTramp(n) {
  if (n === 0) return true;
  return () => oddTramp(n - 1);  // Return thunk
}

function oddTramp(n) {
  if (n === 0) return false;
  return () => evenTramp(n - 1);  // Return thunk
}

// Usage
trampoline(() => evenTramp(10000));  // Stack safe
```

### Practical Example: Expression Parser

```javascript
function parseExpression(tokens) {
  // expression = term (('+' | '-') term)*
  let result = parseTerm(tokens);
  while (tokens[0] === '+' || tokens[0] === '-') {
    const op = tokens.shift();
    const right = parseTerm(tokens);
    result = {op, left: result, right};
  }
  return result;
}

function parseTerm(tokens) {
  // term = factor (('*' | '/') factor)*
  let result = parseFactor(tokens);
  while (tokens[0] === '*' || tokens[0] === '/') {
    const op = tokens.shift();
    const right = parseFactor(tokens);
    result = {op, left: result, right};
  }
  return result;
}

function parseFactor(tokens) {
  // factor = number | '(' expression ')'
  if (tokens[0] === '(') {
    tokens.shift();
    const result = parseExpression(tokens);  // Mutual recursion
    tokens.shift();  // consume ')'
    return result;
  }
  return {type: 'number', value: tokens.shift()};
}
```

### Conversion to Single Recursion

Sometimes mutual recursion can be refactored into single recursion by combining functions or using data structures to represent states.

**Before (mutual recursion):**

```javascript
function processA(data) {
  if (conditionA(data)) return resultA(data);
  return processB(transformA(data));
}

function processB(data) {
  if (conditionB(data)) return resultB(data);
  return processA(transformB(data));
}
```

**After (single recursion with state):**

```javascript
function process(data, state = 'A') {
  if (state === 'A') {
    if (conditionA(data)) return resultA(data);
    return process(transformA(data), 'B');
  } else {
    if (conditionB(data)) return resultB(data);
    return process(transformB(data), 'A');
  }
}
```

### Debugging Strategies

**Trace execution** - Add logging to track which function is called with what arguments.

**Visualize call graph** - Draw the call sequence to understand how functions interact.

**Limit recursion depth** - Add depth counters to catch infinite mutual recursion during development.

**Unit test individually** - Test each function in isolation with mocked versions of mutually recursive partners.

**Key Points:**

- Mutual recursion naturally expresses certain algorithms like parsers and state machines
- Stack overflow risk exists without TCO or trampolining
- Trampolining is particularly effective for mutual recursion
- Can sometimes be refactored to single recursion using state parameters
- Testing and debugging require careful consideration of multiple execution paths

