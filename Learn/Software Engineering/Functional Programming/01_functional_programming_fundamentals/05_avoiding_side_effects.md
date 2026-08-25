## Avoiding Side Effects


Avoiding side effects means designing functions to be pure: producing output solely from input parameters without modifying external state or interacting with the outside world.

### Strategies for Elimination

**Return new values instead of modifying** - Instead of mutating data, create and return new versions with the desired changes.

**Pass all dependencies as parameters** - Make all inputs explicit rather than relying on external variables or global state.

**Use dependency injection** - For unavoidable side effects like I/O, pass interfaces or functions as parameters to maintain testability.

**Separate pure logic from effects** - Isolate side-effecting operations at the boundaries of your application, keeping core logic pure.

**Example:**

```javascript
// Avoiding side effects - before
let users = [];
function addUser(name) {
  users.push({name, id: users.length});  // Mutates external array
}

// Avoiding side effects - after
function addUser(users, name) {
  return [...users, {name, id: users.length}];  // Returns new array
}
```

### Managing Unavoidable Side Effects

**Push effects to boundaries** - Keep I/O and state changes at application edges (API handlers, event listeners, main functions) while keeping business logic pure.

**Make effects explicit** - Use type systems or naming conventions to indicate which functions have side effects (e.g., IO types in Haskell, async functions in JavaScript).

**Use effect management systems** - Frameworks like Redux, Elm Architecture, or effect systems provide structured ways to handle side effects while maintaining functional principles.

**Wrap effects in abstractions** - Use monads (like IO, Effect, or Task) to encapsulate side effects while allowing pure composition of effectful operations.

### Lazy Evaluation for Effects

Separate effect description from execution by returning data structures that describe operations rather than performing them immediately.

```javascript
// Effect as data
const readFile = (path) => ({type: 'READ_FILE', path});
const writeFile = (path, content) => ({type: 'WRITE_FILE', path, content});

// Interpreter executes effects
function runEffect(effect) {
  switch(effect.type) {
    case 'READ_FILE': return fs.readFileSync(effect.path);
    case 'WRITE_FILE': return fs.writeFileSync(effect.path, effect.content);
  }
}
```

### Testing Without Side Effects

**Pure functions need no mocking** - Test by providing inputs and asserting outputs without complex setup or teardown.

**Effect descriptions are testable** - When effects are represented as data, test that the correct effect descriptions are produced without executing them.

**Dependency injection enables substitution** - Pass test implementations of effectful dependencies to verify logic without triggering real effects.

