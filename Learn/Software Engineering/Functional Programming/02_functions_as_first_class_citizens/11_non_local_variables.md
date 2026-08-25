## Non-Local Variables


Non-local variables are variables that are neither local to the current function nor global. They exist in an enclosing scope and are accessed through lexical scoping mechanisms.

### Categories of Variables

**Local variables**: Declared within the current function scope

**Non-local variables**: Declared in enclosing function scopes (but not global)

**Global variables**: Declared at the top-level scope

### Free Variables

Non-local variables accessed by a function are called **free variables** because they're not bound within the function itself. They're "free" in the function's context but bound in an enclosing scope.

**Key Points:**

- Non-local variables bridge the gap between local and global scope
- They enable closures to maintain state across invocations
- Must be captured by reference for closures to work correctly
- Can create multiple levels of nesting with distinct non-local variables

**Example:**

```javascript
function outermost() {
  const a = 1;  // Non-local for innermost
  
  function middle() {
    const b = 2;  // Local for middle, non-local for innermost
    
    function innermost() {
      const c = 3;  // Local for innermost
      console.log(a + b + c);  // a and b are non-local
    }
    
    return innermost;
  }
  
  return middle;
}

const fn = outermost()();
fn();
```

**Output:**

```
6
```

From `innermost`'s perspective:

- `c` is local
- `b` is non-local (from `middle`)
- `a` is non-local (from `outermost`)

### Lifetime Extension

Non-local variables captured by closures have their lifetime extended beyond the normal scope termination. The variables persist as long as any closure referencing them exists.

```javascript
function makeAccumulator(initial) {
  let sum = initial;  // Non-local for returned function
  
  return function(value) {
    sum += value;  // sum persists across calls
    return sum;
  };
}

const acc = makeAccumulator(0);
console.log(acc(5));   // 5
console.log(acc(10));  // 15
```

