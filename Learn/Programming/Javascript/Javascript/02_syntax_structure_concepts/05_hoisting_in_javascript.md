## Hoisting in JavaScript


### What is Hoisting?

Hoisting is a JavaScript behavior where variable and function declarations are moved to the top of their containing scope during the compilation phase, before code execution. This means that regardless of where declarations appear in your code, they are conceptually "hoisted" to the top of their scope.

### How Hoisting Works

JavaScript's engine operates in two phases: compilation and execution. During compilation, all declarations are processed and allocated memory, making them available in their scope even before execution reaches their actual position in the code.

**Key Points**

- Only declarations are hoisted, not initializations
- Function declarations are completely hoisted with their definitions
- Variables declared with `var` are hoisted and initialized with `undefined`
- Variables declared with `let` and `const` are hoisted but not initialized (remaining in the Temporal Dead Zone)

### Hoisting with Function Declarations

Function declarations are fully hoisted, meaning both the declaration and the function body are moved to the top of the scope.

```javascript
// This works because the function declaration is hoisted
console.log(sum(5, 10)); // Outputs: 15

function sum(a, b) {
  return a + b;
}
```

### Hoisting with Function Expressions

Function expressions are not hoisted in the same way as function declarations. The variable declaration might be hoisted, but the function assignment is not.

```javascript
// This results in an error
console.log(subtract(10, 5)); // Error: subtract is not a function

var subtract = function(a, b) {
  return a - b;
};
```

### Hoisting with Arrow Functions

Arrow functions, like function expressions, are not hoisted.

```javascript
// This results in an error
console.log(multiply(3, 4)); // Error: Cannot access 'multiply' before initialization

const multiply = (a, b) => a * b;
```

### Variable Hoisting with `var`

Variables declared with `var` are hoisted and automatically initialized with `undefined`.

```javascript
console.log(name); // Outputs: undefined
var name = "JavaScript";
```

The above code is interpreted as:

```javascript
var name; // Hoisted declaration, initialized as undefined
console.log(name); // Outputs: undefined
name = "JavaScript"; // Assignment happens at execution
```

### Temporal Dead Zone

#### What is the Temporal Dead Zone?

The Temporal Dead Zone (TDZ) is a behavior specific to variables declared with `let` and `const`. It refers to the period between entering a scope where a variable is declared and the actual declaration being reached during code execution.

#### TDZ Behavior

Variables in the TDZ cannot be accessed in any way before their declaration is reached in the code. Any attempt to access them will result in a `ReferenceError`.

**Key Points**

- Variables declared with `let` and `const` are hoisted but remain uninitialized
- Accessing a variable during the TDZ throws a `ReferenceError`
- The TDZ ends when the variable's declaration is reached
- TDZ provides better error detection for accessing variables before declaration

#### Examples of TDZ

```javascript
// TDZ begins for 'color'
console.log(color); // ReferenceError: Cannot access 'color' before initialization
let color = "blue"; // TDZ ends for 'color'

// Same applies to const
console.log(PI); // ReferenceError: Cannot access 'PI' before initialization
const PI = 3.14;
```

#### Comparing `var` vs `let`/`const`

```javascript
console.log(a); // undefined - no error because 'var' initializes to undefined during hoisting
console.log(b); // ReferenceError - because 'let' is in TDZ
console.log(c); // ReferenceError - because 'const' is in TDZ

var a = 1;
let b = 2; 
const c = 3;
```

#### TDZ with Function Parameters

Default parameters are also subject to the TDZ and are evaluated from left to right:

```javascript
function example(a = b, b = 2) {
  return [a, b];
}

example(); // ReferenceError: Cannot access 'b' before initialization
```

The parameter `a` tries to access `b` which is still in the TDZ.

#### Block Scoping and TDZ

TDZ applies to block-scoped declarations even within the same block:

```javascript
{
  // TDZ for x begins
  const y = x + 1; // ReferenceError: Cannot access 'x' before initialization
  const x = 1; // TDZ for x ends
}
```

#### TDZ in Loops

Variables declared in the initialization part of a loop have a separate TDZ for each iteration:

```javascript
for (let i = 0; i < 3; i++) {
  // A new 'i' binding is created for each iteration
  console.log(i); // 0, 1, 2
}
```

### Practical Implications

#### Best Practices for Avoiding Hoisting Issues

1. Always declare variables at the top of their scope
2. Use `let` and `const` instead of `var` for better scoping and error detection
3. Declare functions before calling them
4. Be aware of the TDZ when organizing your code

#### Common Mistakes and Debugging

The most common hoisting-related bugs involve:

- Accessing variables before initialization
- Relying on function hoisting in complex code
- Assuming function expressions are hoisted like function declarations
- Forgetting that `let` and `const` declarations have TDZ

**Example**

```javascript
function buggyFunction() {
  if (false) {
    var result = "never assigned";
  }
  console.log(result); // undefined, not ReferenceError
}

function fixedFunction() {
  if (false) {
    let result = "never assigned";
  }
  console.log(result); // ReferenceError: result is not defined
}
```

#### Performance Considerations

While hoisting is a fundamental JavaScript behavior, understanding it helps write more efficient code:

- Reducing variable lookups by proper scoping
- Avoiding unnecessary closure creation
- Minimizing scope chain traversal

#### Engine Implementation Details

Modern JavaScript engines like V8 (Chrome, Node.js) and SpiderMonkey (Firefox) optimize hoisting behavior:

- Using compilation phases to detect declarations
- Creating lexical environments for proper scoping
- Implementing specialized handling for TDZ checks

### Related Concepts

#### Scope and Closures

Hoisting is deeply connected to JavaScript's scoping rules and closure mechanism:

- Function scope vs. block scope
- Closure formation and variable capture
- Lexical environment chains

#### Variables in Global Scope

Variables declared in the global scope become properties of the global object (window in browsers, global in Node.js):

```javascript
var globalVar = "I'm global";
console.log(window.globalVar); // "I'm global" in browsers

let globalLet = "I'm global but not on window";
console.log(window.globalLet); // undefined
```

#### `this` Binding and Hoisting

Hoisting does not affect `this` binding in functions. The value of `this` is determined at call time, not during hoisting:

```javascript
function showThis() {
  console.log(this);
}

showThis(); // window or global object
const obj = { method: showThis };
obj.method(); // obj
```

---

