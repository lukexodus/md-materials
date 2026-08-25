## Functions in TypeScript


### Introduction to TypeScript Functions

TypeScript enhances JavaScript functions by adding type annotations, making your code more predictable and easier to debug. TypeScript functions allow you to specify the types of parameters a function accepts and the type of value it returns, enabling better tooling support and compile-time error checking.

### Function Parameter Types

In TypeScript, you can explicitly specify the types of function parameters to enforce type safety.

**Basic Parameter Typing**

```typescript
function greet(name: string) {
  return `Hello, ${name}!`;
}

// Valid
greet("John");

// Error: Argument of type 'number' is not assignable to parameter of type 'string'
greet(42);
```

**Multiple Parameters**

```typescript
function calculateArea(width: number, height: number): number {
  return width * height;
}

calculateArea(10, 20); // 200
```

**Object Parameter Types**

```typescript
function printCoordinates(point: { x: number; y: number }): void {
  console.log(`X: ${point.x}, Y: ${point.y}`);
}

// Valid
printCoordinates({ x: 10, y: 20 });

// Error: Property 'y' is missing
printCoordinates({ x: 10 });
```

**Array Parameter Types**

```typescript
function sumArray(numbers: number[]): number {
  return numbers.reduce((sum, current) => sum + current, 0);
}

sumArray([1, 2, 3, 4]); // 10
```

**Function Parameter Types**

```typescript
function executeOperation(
  a: number, 
  b: number, 
  operation: (x: number, y: number) => number
): number {
  return operation(a, b);
}

const result = executeOperation(5, 3, (x, y) => x + y); // 8
```

### Return Types

TypeScript allows you to specify the return type of a function, making code more predictable and self-documenting.

**Basic Return Types**

```typescript
function multiply(a: number, b: number): number {
  return a * b;
}

function getFullName(firstName: string, lastName: string): string {
  return `${firstName} ${lastName}`;
}
```

**Void Return Type**

```typescript
function logMessage(message: string): void {
  console.log(message);
  // No return statement needed
}
```

**Union Return Types**

```typescript
function processInput(input: string): string | null {
  if (input.trim().length === 0) {
    return null;
  }
  return input.toUpperCase();
}
```

**Never Return Type**

```typescript
function throwError(message: string): never {
  throw new Error(message);
}

function infiniteLoop(): never {
  while (true) {
    // Code that never terminates
  }
}
```

**Inferred Return Types**

TypeScript can also infer return types when they're not explicitly specified:

```typescript
// TypeScript infers return type as number
function add(a: number, b: number) {
  return a + b;
}
```

### Optional and Default Parameters

TypeScript gives you flexibility with parameter requirements through optional and default parameters.

**Optional Parameters**

Optional parameters are marked with a question mark (`?`) and must come after required parameters:

```typescript
function buildAddress(street: string, city: string, state?: string, zipCode?: string): string {
  let address = `${street}, ${city}`;
  
  if (state) {
    address += `, ${state}`;
  }
  
  if (zipCode) {
    address += ` ${zipCode}`;
  }
  
  return address;
}

// All valid calls
buildAddress("123 Main St", "Anytown", "CA", "12345");
buildAddress("123 Main St", "Anytown", "CA");
buildAddress("123 Main St", "Anytown");
```

**Default Parameters**

Default parameters provide a fallback value when an argument isn't provided:

```typescript
function createGreeting(name: string, greeting: string = "Hello"): string {
  return `${greeting}, ${name}!`;
}

createGreeting("Alice"); // "Hello, Alice!"
createGreeting("Bob", "Hi"); // "Hi, Bob!"
```

**Combining Optional and Default Parameters**

```typescript
function configureSettings(
  timeout: number = 1000,
  debug: boolean = false,
  environment?: string
): { timeout: number; debug: boolean; environment: string } {
  return {
    timeout,
    debug,
    environment: environment || "development"
  };
}
```

### Function Overloading

Function overloading allows a function to handle different parameter types and return appropriate results.

**Basic Overloading**

In TypeScript, function overloading is achieved by defining multiple function signatures followed by a single implementation:

```typescript
// Overload signatures
function convert(value: string): number;
function convert(value: number): string;
function convert(value: boolean): string;

// Implementation signature
function convert(value: string | number | boolean): string | number {
  if (typeof value === "string") {
    return parseFloat(value) || 0;
  } else if (typeof value === "number") {
    return value.toString();
  } else {
    return value ? "true" : "false";
  }
}

const numericValue = convert("42"); // type: number
const stringValue = convert(42);    // type: string
const boolValue = convert(true);    // type: string
```

**Overloading with Different Parameter Counts**

```typescript
// Overload signatures
function createElement(tagName: string): HTMLElement;
function createElement(tagName: string, text: string): HTMLElement;
function createElement(tagName: string, options: { text?: string; className?: string }): HTMLElement;

// Implementation signature
function createElement(
  tagName: string,
  textOrOptions?: string | { text?: string; className?: string }
): HTMLElement {
  const element = document.createElement(tagName);
  
  if (textOrOptions === undefined) {
    return element;
  }
  
  if (typeof textOrOptions === "string") {
    element.textContent = textOrOptions;
  } else {
    if (textOrOptions.text) {
      element.textContent = textOrOptions.text;
    }
    if (textOrOptions.className) {
      element.className = textOrOptions.className;
    }
  }
  
  return element;
}
```

**Method Overloading in Classes**

```typescript
class Calculator {
  // Overload signatures
  add(a: number, b: number): number;
  add(a: string, b: string): string;
  
  // Implementation
  add(a: number | string, b: number | string): number | string {
    if (typeof a === "number" && typeof b === "number") {
      return a + b;
    } else if (typeof a === "string" && typeof b === "string") {
      return a.concat(b);
    }
    throw new Error("Parameters must be both numbers or both strings");
  }
}

const calc = new Calculator();
const sum = calc.add(5, 10);         // 15
const concat = calc.add("Hello, ", "World"); // "Hello, World"
```

### Advanced Function Types

**Generic Functions**

```typescript
function identity<T>(arg: T): T {
  return arg;
}

const num = identity<number>(42);    // type: number
const str = identity<string>("text"); // type: string
```

**Rest Parameters**

```typescript
function sum(...numbers: number[]): number {
  return numbers.reduce((total, n) => total + n, 0);
}

sum(1, 2, 3, 4); // 10
```

**Destructured Parameters**

```typescript
function printPerson({name, age}: {name: string; age: number}): void {
  console.log(`${name} is ${age} years old`);
}

printPerson({name: "Alice", age: 30}); // "Alice is 30 years old"
```

**Contextual Typing with Arrow Functions**

```typescript
// The type of 'map' helps TypeScript infer the parameter type
const names = ["Alice", "Bob", "Charlie"];
const lengths = names.map((name) => name.length); // TypeScript knows 'name' is string
```

### Type Guards and Function Typing

```typescript
// User-defined type guard
function isString(value: any): value is string {
  return typeof value === "string";
}

function processValue(value: string | number) {
  if (isString(value)) {
    // TypeScript knows value is a string here
    return value.toUpperCase();
  } else {
    // TypeScript knows value is a number here
    return value.toFixed(2);
  }
}
```

### Callable Interfaces

In TypeScript, **callable interfaces** are interfaces that define a function signature, allowing objects to be called as functions while also potentially having additional properties or methods. They are used to describe types that are callable, such as function objects or classes with a call signature. This concept is particularly useful in scenarios where an object needs to act like a function but also maintain other properties, such as in higher-order functions, decorators, or libraries like Express.

#### 1. **Definition**
A callable interface is an interface that includes a **call signature**, which defines the parameters and return type of the function when the object is invoked. It can also include additional properties, methods, or other signatures (e.g., construct signatures).

- **Syntax**:
  ```typescript
  interface Callable {
    (param1: Type1, param2: Type2): ReturnType; // Call signature
    property?: Type; // Optional additional property
  }
  ```
  - The call signature `(param1: Type1, param2: Type2): ReturnType` specifies how the object can be called as a function.
  - Additional members (e.g., `property`) allow the object to have properties or methods.

- **Example**:
  ```typescript
  interface Logger {
    (message: string): void; // Callable: takes a string, returns void
    level: string; // Property
  }

  const log: Logger = (message: string) => console.log(`[${log.level}] ${message}`);
  log.level = "INFO";

  log("Hello"); // Calls the function: [INFO] Hello
  console.log(log.level); // INFO
  ```

#### 2. **Key Features**
- **Call Signature**:
  - Defines the function’s parameters and return type.
  - Supports overloads (multiple call signatures for the same interface).
  ```typescript
  interface OverloadedCallable {
    (x: string): string;
    (x: number): number;
  }
  const fn: OverloadedCallable = (x: string | number) => x;
  console.log(fn("test")); // string
  console.log(fn(42)); // number
  ```

- **Additional Members**:
  - Can include properties, methods, or index signatures alongside the call signature.
  ```typescript
  interface Counter {
    (increment: number): number; // Call signature
    reset(): void; // Method
    value: number; // Property
  }

  const counter: Counter = ((increment: number) => {
    counter.value += increment;
    return counter.value;
  }) as Counter;
  counter.value = 0;
  counter.reset = () => (counter.value = 0);

  console.log(counter(5)); // 5
  counter.reset();
  console.log(counter.value); // 0
  ```

- **Construct Signatures** (Optional):
  - Interfaces can also define construct signatures for objects that can be used with `new`.
  ```typescript
  interface Constructable {
    new (value: string): { value: string };
  }
  ```

#### 3. **Comparison to Other Constructs**
- **Vs. Function Types**:
  - A function type (e.g., `type Fn = (x: string) => void`) only describes a function’s signature without additional properties.
  - Callable interfaces allow properties or methods, making them more expressive.
  ```typescript
  type SimpleFn = (x: string) => void;
  interface CallableFn {
    (x: string): void;
    metadata: string;
  }
  ```

- **Vs. Type Aliases with Callable Types**:
  - Type aliases can also define callable types using intersections, but they are less idiomatic for this purpose.
  ```typescript
  type CallableType = ((x: string) => void) & { metadata: string };
  // Equivalent to interface CallableFn above
  ```
  - Interfaces are preferred for callable objects due to declaration merging and readability.

#### 4. **Use Cases**
- **Function Objects with Metadata**:
  - Functions that carry additional data, such as logging utilities or event handlers.
  ```typescript
  interface EventHandler {
    (event: string, data: any): void;
    listeners: string[];
  }
  const handler: EventHandler = (event, data) => console.log(event, data);
  handler.listeners = ["click", "hover"];
  handler("click", { x: 10 }); // click { x: 10 }
  ```

- **Higher-Order Functions**:
  - Functions that return other functions with shared state or configuration.
  ```typescript
  interface Adder {
    (x: number): number;
    reset: () => void;
  }
  function createAdder(): Adder {
    let sum = 0;
    const adder = ((x: number) => (sum += x)) as Adder;
    adder.reset = () => (sum = 0);
    return adder;
  }
  const add = createAdder();
  console.log(add(3)); // 3
  console.log(add(2)); // 5
  add.reset();
  console.log(add(1)); // 1
  ```

- **Library APIs**:
  - Common in libraries like Express, where middleware or route handlers are callable with additional properties.
  ```typescript
  interface Middleware {
    (req: Request, res: Response, next: () => void): void;
    priority: number;
  }
  ```

- **Decorators or Tagged Functions**:
  - Functions that tag or modify behavior while maintaining metadata.
  ```typescript
  interface Tagged {
    (value: string): string;
    tag: string;
  }
  const tagged: Tagged = (value: string) => `[${tagged.tag}] ${value}`;
  tagged.tag = "DEBUG";
  console.log(tagged("test")); // [DEBUG] test
  ```

#### 5. **Next.js Context**
  - In a Next.js project (indicated by the `"next"` plugin), callable interfaces are useful for:
    - Defining React component wrappers with additional props or state.
    - Creating middleware or API route handlers with metadata.
    - Implementing utility functions with attached configuration (e.g., logging or analytics).
  - Example in Next.js:
    ```typescript
    interface ApiHandler {
      (req: NextApiRequest, res: NextApiResponse): Promise<void>;
      route: string;
    }
    const handler: ApiHandler = async (req, res) => {
      res.status(200).json({ route: handler.route });
    };
    handler.route = "/api/user";
    ```

#### 6. **Practical Implications**
- **When to Use Callable Interfaces**:
  - When an object needs to be callable (like a function) but also requires properties or methods.
  - For type-safe function objects in libraries, frameworks, or complex applications.
  - When declaration merging is needed to extend the interface later.
- **Implementation Tips**:
  - Use type assertions (`as`) when creating callable objects, as TypeScript may need help aligning the function with additional properties.
  ```typescript
  const fn: Callable = ((x: string) => console.log(x)) as Callable;
  fn.property = "value";
  ```
  - Ensure `"strict": true` is respected by annotating all parameters and return types.
- **Limitations**:
  - Callable interfaces cannot be implemented by classes directly (use regular interfaces with methods for class contracts).
  - Overloading call signatures can complicate type inference; test thoroughly.
- **Alternatives**:
  - Use type aliases with intersections for simple callable types.
  - Use plain function types if no additional properties are needed.

#### 7. **Example in Next.js**
```typescript
import type { NextApiRequest, NextApiResponse } from "next";

interface AuthenticatedHandler {
  (req: NextApiRequest, res: NextApiResponse): Promise<void>;
  requiresAuth: boolean;
  role: string;
}

const userHandler: AuthenticatedHandler = async (req, res) => {
  if (userHandler.requiresAuth && !req.headers.authorization) {
    return res.status(401).json({ error: "Unauthorized" });
  }
  res.status(200).json({ message: `Role: ${userHandler.role}` });
};
userHandler.requiresAuth = true;
userHandler.role = "admin";

// Usage in Next.js API route
export default userHandler;
```

**Conclusion**
Callable interfaces in TypeScript allow objects to be called as functions while supporting additional properties or methods, making them ideal for function objects with metadata, middleware, or utility functions. They are defined with a call signature and optional members, offering flexibility for complex type scenarios. In the provided `tsconfig.json` with `"strict": true`, callable interfaces ensure type safety, aligning with Next.js’s needs for API handlers or component utilities. Use them when you need callable objects with state or configuration, and pair with `"esnext"` and `"bundler"` settings for modern JavaScript compatibility.

### Best Practices for TypeScript Functions

1. Always specify parameter and return types for public functions
2. Use void for functions that don't return a value
3. Leverage TypeScript's type inference when appropriate
4. Place required parameters before optional ones
5. Use function overloads to provide type safety for functions with multiple signatures
6. Consider using generic functions for reusable code that works with multiple types
7. Use type guards to narrow types within conditional blocks

### Common Function Patterns

#### **Builder Pattern**

```typescript
interface UserBuilder {
  setName(name: string): UserBuilder;
  setAge(age: number): UserBuilder;
  setEmail(email: string): UserBuilder;
  build(): User;
}

class User {
  name: string = "";
  age: number = 0;
  email: string = "";
}

class UserBuilderImpl implements UserBuilder {
  private user: User = new User();
  
  setName(name: string): UserBuilder {
    this.user.name = name;
    return this;
  }
  
  setAge(age: number): UserBuilder {
    this.user.age = age;
    return this;
  }
  
  setEmail(email: string): UserBuilder {
    this.user.email = email;
    return this;
  }
  
  build(): User {
    return this.user;
  }
}
```

#### **Curried Functions**

In TypeScript (and JavaScript), **curried functions** are functions that transform a function with multiple arguments into a sequence of functions, each taking a single argument. This technique, rooted in functional programming, allows partial application of arguments, enabling more flexible and reusable code. Below is a clear explanation of curried functions, their syntax, benefits, use cases, and implementation in TypeScript, adhering to your preference for a formal tone and precise language.

##### 1. **Definition**
A curried function is a function that, instead of taking all its arguments at once, takes them one at a time, returning a new function for each argument until all arguments are provided, at which point it computes the final result.

- **Standard Function**:
  ```typescript
  function add(a: number, b: number): number {
    return a + b;
  }
  console.log(add(2, 3)); // 5
  ```

- **Curried Function**:
  ```typescript
  function curriedAdd(a: number): (b: number) => number {
    return (b: number) => a + b;
  }
  console.log(curriedAdd(2)(3)); // 5
  ```

In the curried version, `curriedAdd(2)` returns a function that “remembers” `a = 2` and waits for `b`. When called with `curriedAdd(2)(3)`, it computes `2 + 3`.

##### 2. **Syntax and Structure**
- **Manual Currying**:
  A curried function is written as a nested function where each level handles one argument.
  ```typescript
  function multiply(x: number): (y: number) => number {
    return (y: number): number => x * y;
  }
  const double = multiply(2); // (y: number) => 2 * y
  console.log(double(5)); // 10
  ```

- **General Form**:
  For a function with `n` arguments, currying produces a chain of `n` single-argument functions:
  ```typescript
  // Non-curried: (a, b, c) => result
  // Curried: a => b => c => result
  function sumThree(a: number): (b: number) => (c: number) => number {
    return (b: number): (c: number) => number => {
      return (c: number): number => a + b + c;
    };
  }
  console.log(sumThree(1)(2)(3)); // 6
  ```

- **Arrow Function Syntax**:
  Curried functions can be concise with arrow functions:
  ```typescript
  const divide = (x: number) => (y: number): number => x / y;
  console.log(divide(10)(2)); // 5
  ```

##### 3. **Type Signatures in TypeScript**
TypeScript’s type system ensures type safety for curried functions. The return type of each function is another function until the final result is reached.

- **Example**:
  ```typescript
  interface CurriedAdd {
    (a: number): (b: number) => number;
  }
  const curriedAdd: CurriedAdd = (a: number) => (b: number): number => a + b;
  ```

- **Generic Curried Functions**:
  Generics can make curried functions flexible for different types.
  ```typescript
  function curriedMap<T, U>(fn: (x: T) => U): (arr: T[]) => U[] {
    return (arr: T[]): U[] => arr.map(fn);
  }
  const toString = curriedMap((n: number) => n.toString());
  console.log(toString([1, 2, 3])); // ["1", "2", "3"]
  ```

##### 4. **Automatic Currying**
Manually writing curried functions can be verbose. Libraries like Lodash or Ramda provide utilities to curry functions, or you can create a curry helper in TypeScript.

- **Curry Helper**:
  ```typescript
  function curry2<T, U, V>(fn: (a: T, b: U) => V): (a: T) => (b: U) => V {
    return (a: T) => (b: U): V => fn(a, b);
  }

  const add = curry2((a: number, b: number) => a + b);
  const add5 = add(5);
  console.log(add5(3)); // 8
  ```

- **Generic Curry for Arbitrary Arity**:
  For functions with more arguments, currying becomes complex, but libraries handle this. A basic three-argument curry:
  ```typescript
  function curry3<T, U, V, W>(
    fn: (a: T, b: U, c: V) => W
  ): (a: T) => (b: U) => (c: V) => W {
    return (a: T) => (b: U) => (c: V): W => fn(a, b, c);
  }
  ```

##### 5. **Benefits of Curried Functions**
- **Partial Application**:
  - Currying allows creating specialized functions by fixing some arguments.
  ```typescript
  const increment = curriedAdd(1);
  console.log(increment(10)); // 11
  ```

- **Reusability**:
  - Curried functions are composable, making them ideal for functional programming pipelines.
  ```typescript
  const mapStrings = curriedMap((s: string) => s.toUpperCase());
  console.log(mapStrings(["a", "b"])); // ["A", "B"]
  ```

- **Improved Readability**:
  - Breaking a function into single-argument steps can clarify intent in certain contexts, especially in functional libraries.

- **Flexibility**:
  - Curried functions can be passed to higher-order functions or used in point-free style.
  ```typescript
  const filter = curry2((fn: (x: number) => boolean, arr: number[]) => arr.filter(fn));
  const positives = filter((x: number) => x > 0);
  console.log(positives([-1, 0, 1])); // [1]
  ```

##### 6. **Use Cases**
- **Functional Programming**:
  - Currying is common in libraries like Ramda or fp-ts, enabling function composition and point-free programming.
  ```typescript
  const greet = curry2((greeting: string, name: string) => `${greeting}, ${name}!`);
  const hello = greet("Hello");
  console.log(hello("Alice")); // Hello, Alice!
  ```

- **Event Handlers**:
  - Create reusable handlers with preconfigured arguments.
  ```typescript
  const logEvent = curry2((event: string, data: any) => console.log(event, data));
  const logClick = logEvent("click");
  logClick({ x: 10 }); // click { x: 10 }
  ```

- **Configuration**:
  - Fix configuration parameters for reusable utilities.
  ```typescript
  const formatDate = curry2((format: string, date: Date) => {
    // Simplified example
    return `${format}: ${date.toISOString()}`;
  });
  const isoFormat = formatDate("ISO");
  console.log(isoFormat(new Date())); // ISO: 2025-05-17T...
  ```

- **API Utilities**:
  - Simplify API calls by currying endpoints or options.
  ```typescript
  const fetchFrom = curry2((baseUrl: string, endpoint: string) =>
    fetch(`${baseUrl}${endpoint}`)
  );
  const apiFetch = fetchFrom("https://api.example.com");
  apiFetch("/users"); // Fetch from https://api.example.com/users
  ```

##### 7. **Limitations and Considerations**
- **Verbosity**:
  - Manually curried functions require nested function definitions, which can be cumbersome for functions with many arguments.
  - Solution: Use a currying utility or library.

- **Type Complexity**:
  - TypeScript types for curried functions can become complex, especially for generics or overloads.
  - Ensure clear type annotations to maintain readability.
  ```typescript
  const bad: (x: number) => (y: number) => number = x => y => x + y; // Verbose
  const good: CurriedAdd = x => y => x + y; // Using interface
  ```

- **Performance**:
  - Currying creates multiple function closures, which have negligible overhead in most cases but could accumulate in performance-critical code.
  - Profile if used extensively in hot paths.

- **Learning Curve**:
  - Currying may be unfamiliar to developers not versed in functional programming, requiring team alignment.

##### 8. **TypeScript-Specific Notes**
- **Strict Mode**:
  - With `"strict": true` (as in a typical TypeScript setup), TypeScript enforces explicit parameter and return type annotations, ensuring curried functions are type-safe.
  ```typescript
  const unsafe = x => y => x + y; // Error: Parameter 'x' implicitly has an 'any' type
  const safe = (x: number) => (y: number): number => x + y; // OK
  ```

- **Inference**:
  - TypeScript infers return types for curried functions correctly in most cases, but complex currying may require explicit types.
  ```typescript
  const map = <T, U>(fn: (x: T) => U) => (arr: T[]): U[] => arr.map(fn);
  ```

- **Interfaces for Clarity**:
  - Use interfaces to define curried function signatures for better readability and reuse.
  ```typescript
  interface CurriedFilter {
    <T>(fn: (x: T) => boolean): (arr: T[]) => T[];
  }
  const filter: CurriedFilter = fn => arr => arr.filter(fn);
  ```

##### 9. **Example: Practical Curried Function**
```typescript
// Curried function to create a string formatter
interface StringFormatter {
  (prefix: string): (value: string) => string;
}
const format: StringFormatter = (prefix: string) => (value: string): string =>
  `${prefix}${value}`;

// Partial application
const error = format("ERROR: ");
const warning = format("WARNING: ");

console.log(error("Invalid input")); // ERROR: Invalid input
console.log(warning("Low battery")); // WARNING: Low battery
```

**Conclusion**
Curried functions in TypeScript transform multi-argument functions into a chain of single-argument functions, enabling partial application, reusability, and functional composition. They are defined with nested functions or utilities, supported by TypeScript’s type system for safety and clarity. Benefits include flexibility and modularity, though they require careful type management and may increase verbosity. Use curried functions for functional programming, event handling, or configuration-driven utilities, ensuring type annotations align with strict TypeScript settings for robust code.

**Recommended Related Topics**

- TypeScript Interfaces vs. Types
- Generic Types in TypeScript
- TypeScript Class Methods and Properties
- Advanced TypeScript Type Manipulation
- Functional Programming Patterns in TypeScript

---

