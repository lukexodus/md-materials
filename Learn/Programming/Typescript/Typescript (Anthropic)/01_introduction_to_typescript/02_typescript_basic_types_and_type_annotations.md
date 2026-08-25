## TypeScript: Basic Types and Type Annotations


### Primitive Types

**Key Points**
* TypeScript supports JavaScript's primitive types: `number`, `string`, and `boolean`
* Type annotations use a colon syntax: `variableName: type`
* TypeScript's static typing helps catch errors before runtime

The foundation of TypeScript's type system begins with primitive types that directly correspond to JavaScript primitives:

```typescript
// Number type - includes integers, floats, Infinity, NaN
let age: number = 30;
let price: number = 99.99;
let infinity: number = Infinity;

// String type - text data
let name: string = "TypeScript";
let template: string = `Hello, ${name}`;

// Boolean type - true/false values
let isCompleted: boolean = false;
let isValid: boolean = true;
```

TypeScript also provides special primitive types not found in JavaScript:

```typescript
// Void - absence of any type, typically for functions with no return value
function logMessage(): void {
  console.log("This function returns nothing");
}

// Null and Undefined - represent null and undefined values
let n: null = null;
let u: undefined = undefined;

// Symbol - unique identifiers
let sym: symbol = Symbol("unique");

// BigInt - for integers larger than Number can represent
let bigNumber: bigint = 100n;
```

### Arrays and Tuples

**Key Points**
* Arrays can be typed using `type[]` or `Array<type>` syntax
* Tuples are fixed-length arrays with pre-defined types for each position
* TypeScript enforces both array types and tuple structures

Arrays in TypeScript can be typed to ensure all elements share the same type:

```typescript
// Array of numbers
let scores: number[] = [85, 90, 92];
// Alternative syntax using generics
let grades: Array<number> = [85, 90, 92];

// Array of strings
let names: string[] = ["Alice", "Bob", "Charlie"];

// Array of mixed types is not allowed with simple typing
// This will cause an error:
// let mixed: number[] = [1, "two", 3]; // Error!

// You can explicitly allow mixed types
let mixed: (number | string)[] = [1, "two", 3];
```

Tuples are a special array type with fixed length and pre-defined types for each position:

```typescript
// Tuple: first element is string, second is number
let person: [string, number] = ["Alice", 30];

// Tuple with more elements
let employee: [string, number, boolean] = ["Bob", 45, true];

// Accessing tuple elements
console.log(person[0]); // Correctly typed as string
console.log(person[1]); // Correctly typed as number

// Error: Type checking prevents incorrect assignments
// person[0] = 100; // Error: Type 'number' is not assignable to type 'string'
```

### Object Types

**Key Points**
* Object types define the shape of JavaScript objects
* Properties can be required, optional, or readonly
* Interface and type aliases provide reusable object type definitions

TypeScript allows defining object shapes with strict property typing:

```typescript
// Inline object type
let user: { name: string; age: number } = { name: "Alice", age: 30 };

// With optional properties (?)
let product: { id: number; name: string; price: number; description?: string } = {
  id: 1,
  name: "Laptop",
  price: 999.99
  // description is optional
};

// With readonly properties
let config: { readonly apiKey: string; readonly timeout: number } = {
  apiKey: "abc123",
  timeout: 3000
};
// config.apiKey = "xyz"; // Error: Cannot assign to 'apiKey' because it is a read-only property
```

For reusable object types, use interfaces or type aliases:

```typescript
// Interface definition
interface User {
  id: number;
  name: string;
  email: string;
  isActive?: boolean; // Optional property
  readonly createdAt: Date; // Read-only property
}

// Using the interface
const newUser: User = {
  id: 1,
  name: "John Doe",
  email: "john@example.com",
  createdAt: new Date()
};

// Type alias definition
type Product = {
  id: number;
  name: string;
  price: number;
  categories: string[];
};

// Using the type alias
const laptop: Product = {
  id: 101,
  name: "MacBook Pro",
  price: 1999,
  categories: ["Electronics", "Computers"]
};
```

### Type Inference

**Key Points**
* TypeScript can automatically infer types based on value assignments
* Inference works for variables, function return types, and more
* Explicit type annotations are still recommended in many cases

TypeScript's intelligent type inference often means you don't need explicit annotations:

```typescript
// Type inference with initialization
let message = "Hello"; // TypeScript infers message as string
let count = 10;        // TypeScript infers count as number
let active = true;     // TypeScript infers active as boolean

// Type inference for arrays
let numbers = [1, 2, 3]; // TypeScript infers number[]

// Type inference for objects
let person = {
  name: "Alice",
  age: 30
}; // TypeScript infers { name: string; age: number }

// Function return type inference
function add(a: number, b: number) {
  return a + b;  // Return type inferred as number
}

// Function parameter types are NOT inferred and should be annotated
function greet(name) { // Parameter implicitly has 'any' type
  return `Hello, ${name}`;
}
```

Best practices for type inference:

1. Let TypeScript infer types when the initialization clearly indicates the type
2. Add explicit type annotations for function parameters and return types in public APIs
3. Use explicit types when initializing variables with complex or ambiguous types
4. Consider explicit types for empty arrays and objects

### Type Annotations

**Key Points**
* Type annotations explicitly specify types using the colon syntax
* Annotations can be applied to variables, parameters, and function returns
* Good annotations improve code documentation and IDE support

Type annotations provide explicit typing for better clarity and tooling:

```typescript
// Variable annotations
let age: number = 30;
let name: string = "Alice";
let isActive: boolean = true;

// Function parameter and return type annotations
function calculateTax(income: number): number {
  return income * 0.2;
}

// Function with multiple parameters
function createGreeting(name: string, age: number): string {
  return `Hello, my name is ${name} and I am ${age} years old.`;
}

// Arrow function with type annotations
const multiply = (a: number, b: number): number => a * b;

// Object parameter with inline annotation
function printUser(user: { name: string; age: number }): void {
  console.log(`${user.name}, ${user.age}`);
}

// Array annotations
let scores: number[] = [85, 92, 78];
let names: Array<string> = ["Alice", "Bob", "Charlie"];

// Union types (variables that can be multiple types)
let id: string | number = "abc123";
id = 456; // This is also valid
```

When to use explicit annotations:

1. Function parameters (always recommended)
2. Function return types (recommended for public APIs)
3. When initializing variables without a value
4. When TypeScript's inference might be too broad
5. When working with union types or more complex type structures

### The 'any' Type and When To Avoid It

**Key Points**
* The `any` type bypasses TypeScript's type checking
* Using `any` eliminates many benefits of TypeScript
* Better alternatives include `unknown`, union types, and proper typing

The `any` type effectively opts out of type checking:

```typescript
// Variables with any type
let data: any = 42;
data = "Hello"; // No error
data = { id: 1 }; // No error
data = [1, 2, 3]; // No error

// Functions with any
function process(input: any): any {
  return input.someProperty; // No type checking, might fail at runtime
}

// Implicit any
function implicitAny(value) { // Parameter implicitly has 'any' type
  return value * 2;
}
```

Reasons to avoid `any`:

1. Defeats TypeScript's main purpose of static type checking
2. Prevents IDE intellisense and autocompletion
3. Hides potential bugs until runtime
4. Makes refactoring more difficult and error-prone

Better alternatives to `any`:

```typescript
// Instead of any, use unknown for type-safe unknown values
function safeProcess(input: unknown): string {
  if (typeof input === "string") {
    return input.toUpperCase(); // Safe - we've checked the type
  }
  return String(input);
}

// Use union types instead of any when you know the possible types
function formatValue(value: string | number): string {
  if (typeof value === "string") {
    return value.trim();
  }
  return value.toFixed(2);
}

// Use generics instead of any for flexible, type-safe functions
function identity<T>(arg: T): T {
  return arg;
}
```

**Conclusion**

TypeScript's type system starts with these fundamental building blocks: primitive types, arrays, tuples, and objects. The type annotation syntax provides a way to explicitly state your intended types, while type inference often reduces the need for verbose annotations. Understanding when to use each typing feature, along with avoiding the `any` type except when absolutely necessary, creates a foundation for writing type-safe, maintainable TypeScript code.

TypeScript's static typing helps catch common errors during development rather than at runtime, improving code quality and developer experience through better tooling support, autocomplete, and documentation.

---

