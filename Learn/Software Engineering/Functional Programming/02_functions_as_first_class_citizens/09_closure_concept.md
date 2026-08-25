## Closure Concept


Closures are functions that capture and retain access to variables from their enclosing lexical scope, even after that scope has finished executing. A closure "closes over" its environment, bundling the function with references to its surrounding state.

### Formation of Closures

A closure is created when:

1. A function is defined inside another function
2. The inner function references variables from the outer function
3. The inner function is returned or passed elsewhere

The inner function maintains a reference to the outer function's variables, preventing them from being garbage collected.

### Closure Components

A closure consists of:

- **Function code**: The executable logic
- **Environment**: References to variables in the enclosing scope
- **Binding**: The association between variable names and their values

**Key Points:**

- Closures capture variables by reference, not by value
- Multiple closures from the same scope share the same environment
- Closures can modify captured variables if they're mutable
- The captured environment persists as long as the closure exists

**Example:**

```javascript
function createCounter() {
  let count = 0;  // Captured variable
  
  return function() {
    count += 1;
    return count;
  };
}

const counter1 = createCounter();
const counter2 = createCounter();

console.log(counter1()); // 1
console.log(counter1()); // 2
console.log(counter2()); // 1
```

**Output:**

```
1
2
1
```

Each counter maintains its own independent `count` variable from its respective closure.

