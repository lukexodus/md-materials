## Immutability


Immutability means data cannot be modified after creation. Instead of changing existing values, operations produce new values with the desired modifications. This principle eliminates entire categories of bugs related to unexpected state changes.

### Core Concept

When data is immutable, any "modification" creates a new version while leaving the original unchanged. Variables can be reassigned to point to new values, but the values themselves never change.

```javascript
// Mutable approach
const user = {name: 'Alice', age: 30};
user.age = 31;  // Original object modified

// Immutable approach
const user = {name: 'Alice', age: 30};
const updatedUser = {...user, age: 31};  // New object created
```

### Benefits

**Predictability** - Once created, a value never changes, eliminating an entire class of bugs where data is unexpectedly modified elsewhere in the codebase.

**Thread safety** - Immutable data can be safely shared across threads without synchronization because no thread can modify it.

**Time-travel debugging** - Since previous states are preserved, you can replay operations and examine state at any point in execution history.

**Referential transparency** - Functions operating on immutable data are easier to reason about because values always mean the same thing throughout their lifetime.

**Memoization and caching** - Immutable data can be safely cached and reused because it's guaranteed not to change.

**Change detection** - Comparing immutable objects is trivial (reference equality) rather than requiring deep comparisons of mutable structures.

### Implementation Patterns

**Object spreading** - Create new objects by copying existing ones with modifications.

```javascript
const original = {a: 1, b: 2};
const modified = {...original, b: 3};
```

**Array methods that return new arrays** - Use `map`, `filter`, `concat`, `slice` instead of `push`, `pop`, `splice`.

```javascript
const numbers = [1, 2, 3];
const doubled = numbers.map(n => n * 2);  // New array
```

**Nested updates** - For deep updates, manually create new objects at each level or use helper libraries.

```javascript
const state = {user: {profile: {name: 'Alice'}}};
const updated = {
  ...state,
  user: {
    ...state.user,
    profile: {...state.user.profile, name: 'Bob'}
  }
};
```

**Freezing objects** - Use `Object.freeze()` to prevent modifications and catch accidental mutations during development.

```javascript
const config = Object.freeze({apiUrl: 'https://api.example.com'});
config.apiUrl = 'other';  // Fails in strict mode
```

### Language Support

**JavaScript** - No built-in immutability but achieves it through conventions (`const`, spread operators, immutability libraries).

**Clojure** - All data structures immutable by default with persistent data structures for efficient updates.

**Haskell** - Variables are immutable by default; mutability requires special monadic contexts.

**Scala** - Provides both mutable and immutable collections; functional code prefers immutable ones.

**Rust** - Variables immutable by default unless marked with `mut` keyword.

### Performance Considerations

**Structural sharing** - Immutable data structures share unchanged portions between versions, making copies efficient in both time and space.

**Avoiding defensive copying** - Since data cannot be modified, no need to create copies when passing data between functions or modules.

**Trade-offs** - Some operations (like frequent updates to large structures) may be less efficient than mutable approaches, requiring specialized persistent data structures.

