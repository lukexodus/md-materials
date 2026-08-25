## Lexical Scoping


Lexical scoping (also called static scoping) is a scoping mechanism where variable resolution is determined by the physical structure of the code at write-time, not at runtime. The scope of a variable is defined by its position in the source code.

### Scope Chain Resolution

When a variable is referenced, the lookup proceeds:

1. Current function scope
2. Enclosing function scope
3. Next outer scope
4. Continue until global scope
5. Error if not found

### Characteristics

**Static determination**: Variable bindings are resolved based on where functions are defined, not where they're called.

**Nested scopes**: Inner functions have access to variables in all containing scopes.

**Shadowing**: Inner scope variables can shadow outer scope variables with the same name.

**Key Points:**

- Resolution happens at compile/parse time based on code structure
- Function scope is determined by definition location, not invocation location
- Enables predictable variable access patterns
- Foundation for closure behavior

**Example:**

```javascript
const x = 10;

function outer() {
  const x = 20;
  
  function inner() {
    const x = 30;
    console.log(x);  // Uses innermost x
  }
  
  function sibling() {
    console.log(x);  // Uses outer's x
  }
  
  inner();
  sibling();
}

outer();
```

**Output:**

```
30
20
```

The `inner` function accesses its own `x`, while `sibling` accesses `outer`'s `x`, demonstrating lexical scope resolution.

### Lexical vs Dynamic Scoping

**Lexical scoping**: Variable resolution based on code structure

- Predictable and analyzable
- Used by most modern languages

**Dynamic scoping**: Variable resolution based on call stack

- Resolution happens at runtime
- Rarely used (some Lisp dialects, Bash)

