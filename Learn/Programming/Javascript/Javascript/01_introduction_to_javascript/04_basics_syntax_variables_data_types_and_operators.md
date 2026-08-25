## Basics: Syntax, Variables, Data Types, and Operators


### Basic Syntax

JavaScript statements end with a semicolon (optional but recommended):

```javascript
console.log("Hello, World!");  // Output a message
// This is a single-line comment

/* This is 
   a multi-line
   comment */
```

### Variables

JavaScript has three ways to declare variables:

```javascript
// var - function scoped (older style)
var oldVariable = "I'm function scoped";

// let - block scoped (preferred for variables that change)
let count = 5;
count = 6;  // Can be reassigned

// const - block scoped constant (preferred when value won't change)
const PI = 3.14159;
// PI = 3; // Error! Cannot reassign const
```

### Data Types

JavaScript has 8 basic data types:

```javascript
// 1. Number - for both integers and floating point
let integer = 42;
let float = 3.14;
let infinity = Infinity;
let notANumber = NaN;  // Result of invalid calculations

// 2. BigInt - for integers of arbitrary length
let bigNumber = 9007199254740991n;

// 3. String - for text
let singleQuotes = 'Hello';
let doubleQuotes = "World";
let backticks = `Template literal: ${singleQuotes}`;  // Supports interpolation

// 4. Boolean - true/false
let isActive = true;
let isComplete = false;

// 5. null - represents "nothing" or "empty"
let empty = null;

// 6. undefined - unassigned variables
let notDefined;
console.log(notDefined);  // undefined

// 7. Symbol - unique identifiers
let id = Symbol("id");

// 8. Object - collections of properties
let person = {
  name: "John",
  age: 30,
  isStudent: false
};

// Special object types
let array = [1, 2, 3, 4];
let date = new Date();
let regex = /pattern/;
let func = function() { return "I'm a function"; };
```

### Type Checking

```javascript
// Using typeof operator
typeof 42;         // "number"
typeof "hello";    // "string"
typeof true;       // "boolean"
typeof undefined;  // "undefined"
typeof null;       // "object" (historical bug in JavaScript)
typeof {};         // "object"
typeof [];         // "object" (arrays are objects in JavaScript)
typeof function(){}; // "function"

// Better array checking
Array.isArray([]);  // true
Array.isArray({});  // false
```

### Operators

#### Arithmetic Operators

```javascript
let a = 10, b = 3;

// Basic math
console.log(a + b);   // 13 (Addition)
console.log(a - b);   // 7 (Subtraction)
console.log(a * b);   // 30 (Multiplication)
console.log(a / b);   // 3.3333... (Division)
console.log(a % b);   // 1 (Modulus - remainder)
console.log(a ** b);  // 1000 (Exponentiation)

// Increment/Decrement
let c = 5;
console.log(c++);     // 5 (returns c then adds 1)
console.log(++c);     // 7 (adds 1 then returns c)
console.log(c--);     // 7 (returns c then subtracts 1)
console.log(--c);     // 5 (subtracts 1 then returns c)
```

#### Assignment Operators

```javascript
let x = 10;  // Basic assignment

// Compound assignment
x += 5;      // x = x + 5
x -= 3;      // x = x - 3
x *= 2;      // x = x * 2
x /= 4;      // x = x / 4
x %= 3;      // x = x % 3
x **= 2;     // x = x ** 2
```

#### Comparison Operators

```javascript
// Equality
console.log(5 == "5");    // true (coerces types)
console.log(5 === "5");   // false (strict equality, checks type)
console.log(5 != "5");    // false (coerces types)
console.log(5 !== "5");   // true (strict inequality)

// Relational
console.log(10 > 5);      // true (greater than)
console.log(10 >= 10);    // true (greater than or equal)
console.log(10 < 20);     // true (less than)
console.log(10 <= 5);     // false (less than or equal)
```

#### Logical Operators

```javascript
// AND, OR, NOT
console.log(true && false);  // false (AND)
console.log(true || false);  // true (OR)
console.log(!true);          // false (NOT)

// Short-circuit evaluation
let defaultValue = null;
let userValue = "Hello";
let result = userValue || defaultValue;  // "Hello" (uses first truthy value)

let hasPermission = true;
let isLoggedIn = true;
isLoggedIn && hasPermission && console.log("Welcome!");  // Only runs if both are true
```

#### Other Operators

```javascript
// Ternary operator (condition ? ifTrue : ifFalse)
let age = 20;
let status = age >= 18 ? "Adult" : "Minor";

// Nullish coalescing (??) - returns right side only if left is null/undefined
let username = null;
let displayName = username ?? "Anonymous";  // "Anonymous"

// Optional chaining (?.) - safely access nested properties
let user = {};  // No address property
let zipCode = user.address?.zipCode;  // undefined (no error)

// typeof operator
typeof "hello";  // "string"

// instanceof operator (checks prototype chain)
[] instanceof Array;  // true

// delete operator
let obj = {prop: "value"};
delete obj.prop;  // removes the property
```

### Type Conversion

```javascript
// Explicit conversion
String(123);        // "123"
Number("123");      // 123
Boolean(1);         // true
Boolean(0);         // false
parseInt("123.45"); // 123
parseFloat("123.45"); // 123.45

// Implicit conversion (coercion)
"5" + 3;            // "53" (string concatenation)
"5" - 3;            // 2 (numeric operation forces conversion)
"5" * "3";          // 15 (converted to numbers)
10 + true;          // 11 (true converts to 1)
10 + false;         // 10 (false converts to 0)
```

These fundamentals form the building blocks of JavaScript programming. Understanding these concepts will help you build a solid foundation for more advanced JavaScript development.

---
        
### **Output Methods**

- `console.log`: Logs to the console.
	```javascript
	console.log("This is a message");
	```
	
- `alert`: Displays a pop-up alert box.
	
	```javascript
	alert("Hello, User!");
	```
	
- `document.write`: Writes directly into the HTML document.
	
	```javascript
	document.write("Welcome to JavaScript!");
	```

### **`var` vs `let` vs `const` in JavaScript**

In JavaScript, `var`, `let`, and `const` are used to declare variables, but they differ in scope, reassignability, and behavior. Here's a detailed comparison:

---

**1. `var`**

- **Introduced**: In the earliest versions of JavaScript (ES3 and earlier).
- **Scope**:
    - Function-scoped (limited to the function it’s declared in).
    - NOT block-scoped (it ignores curly braces `{}` outside of functions).
- **Re-declaration**: Allowed.
- **Hoisting**: Variables declared with `var` are **hoisted**, meaning they are moved to the top of their scope but initialized with `undefined`.
- **Use Case**: Avoid using `var` in modern JavaScript unless you're working with older code.

**Example**:

```javascript
function exampleVar() {
  if (true) {
    var message = "Hello!";
  }
  console.log(message); // Accessible because it's function-scoped
}
exampleVar();
```

---

**2. `let`**

- **Introduced**: In ES6 (2015).
- **Scope**: Block-scoped (limited to the block `{}` it’s declared in).
- **Re-declaration**: Not allowed in the same scope.
- **Hoisting**: Hoisted, but not initialized (accessing before declaration results in a `ReferenceError`).
- **Use Case**: Use `let` for variables that will change during program execution.

**Example**:

```javascript
function exampleLet() {
  if (true) {
    let message = "Hello!";
    console.log(message); // Accessible inside the block
  }
  // console.log(message); // Error: message is not defined (block-scoped)
}
exampleLet();
```

---

**3. `const`**

- **Introduced**: In ES6 (2015).
- **Scope**: Block-scoped (like `let`).
- **Re-declaration**: Not allowed in the same scope.
- **Hoisting**: Hoisted, but not initialized (accessing before declaration results in a `ReferenceError`).
- **Reassignment**: Not allowed; the variable’s value is **read-only** after its initial assignment.
    - **Note**: If the value is an object or array, its properties or elements can still be modified (but the reference itself cannot change).
- **Use Case**: Use `const` for variables whose value should not change.

**Example**:

```javascript
const PI = 3.14;
console.log(PI); // 3.14

// PI = 3.14159; // Error: Assignment to constant variable

const arr = [1, 2, 3];
arr.push(4); // Allowed: Modifying the array
console.log(arr); // [1, 2, 3, 4]
```

---

**Key Differences**

|Feature|`var`|`let`|`const`|
|---|---|---|---|
|**Scope**|Function-scoped|Block-scoped|Block-scoped|
|**Re-declaration**|Allowed|Not allowed|Not allowed|
|**Hoisting**|Hoisted and initialized to `undefined`|Hoisted but not initialized|Hoisted but not initialized|
|**Reassignment**|Allowed|Allowed|Not allowed|

