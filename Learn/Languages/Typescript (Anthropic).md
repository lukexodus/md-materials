# Syllabus

## Course Overview

This comprehensive syllabus guides you through learning TypeScript from fundamentals to advanced topics. Each module builds on previous knowledge, with practical exercises and projects to reinforce learning.

## Prerequisites

- Basic understanding of JavaScript
- Familiarity with programming concepts
- Development environment (code editor like VS Code recommended)
- Node.js installed

## Module 1: TypeScript Fundamentals (2 weeks)

### Week 1: Introduction to TypeScript

- **Day 1-2: Setting Up Your Environment**
    - Installing TypeScript
    - Configuring tsconfig.json
    - TypeScript with VS Code
    - First TypeScript program
- **Day 3-5: Basic Types and Type Annotations**
    - Primitive types (number, string, boolean)
    - Arrays and tuples
    - Object types
    - Type inference
    - Type annotations
    - The 'any' type and when to avoid it
- **Day 6-7: Functions in TypeScript**
    - Function parameter types
    - Return types
    - Optional and default parameters
    - Function overloading

### Week 2: TypeScript Core Concepts

- **Day 1-2: Interfaces**
    - Creating interfaces
    - Optional properties
    - Readonly properties
    - Extending interfaces
    - Interfaces vs. type aliases
- **Day 3-4: Classes**
    - Class syntax
    - Access modifiers (public, private, protected)
    - Abstract classes
    - Implementing interfaces
    - Method modifiers
- **Day 5-7: Enums, Unions, and Literal Types**
    - Enum types
    - Union types
    - Intersection types
    - Literal types
    - Type narrowing

**Project 1:** Build a simple task management console application using basic TypeScript features.

## Module 2: Intermediate TypeScript (3 weeks)

### Week 3: Advanced Types

- **Day 1-2: Generics**
    - Generic functions
    - Generic interfaces
    - Generic classes
    - Generic constraints
- **Day 3-4: Advanced Type Features**
    - Type assertions
    - Type guards
    - Discriminated unions
    - Index types
    - Mapped types
- **Day 5-7: Utility Types**
    - Partial, Required, Readonly
    - Record, Pick, Omit
    - Extract, Exclude
    - ReturnType, Parameters
    - Creating custom utility types

### Week 4: Modules and Namespaces

- **Day 1-3: TypeScript Modules**
    - Import and export syntax
    - Default and named exports
    - Module resolution strategies
    - Path mapping
- **Day 4-5: Namespaces**
    - Creating namespaces
    - Nested namespaces
    - Namespace imports
    - When to use modules vs. namespaces
- **Day 6-7: Declaration Files**
    - Understanding .d.ts files
    - Writing declaration files
    - Using DefinitelyTyped
    - Declaration merging

### Week 5: Error Handling and Debugging

- **Day 1-2: Error Handling in TypeScript**
    - Error types
    - Try/catch blocks
    - Custom error types
    - Error propagation patterns
- **Day 3-4: Debugging TypeScript**
    - Source maps
    - Debugging in VS Code
    - Chrome DevTools with TypeScript
    - Logging strategies
- **Day 5-7: Testing TypeScript Code**
    - Unit testing with Jest/Mocha
    - Type testing libraries
    - Test-driven development
    - Integration tests

**Project 2:** Create a library management system with advanced type features and proper error handling.

## Module 3: Advanced TypeScript (4 weeks)

### Week 6: Advanced Object-Oriented Programming

- **Day 1-2: Design Patterns in TypeScript**
    - Implementing common design patterns
    - Singleton, Factory, Observer
    - Adapter and Decorator patterns
- **Day 3-4: Mixins and Composition**
    - Creating mixins
    - Composition over inheritance
    - Applying mixins to classes
- **Day 5-7: Advanced Class Features**
    - Static members
    - Protected constructors
    - Method decorators
    - Property decorators

### Week 7: Asynchronous TypeScript

- **Day 1-2: Promises in TypeScript**
    - Promise types
    - Creating typed promises
    - Promise chaining
- **Day 3-5: Async/Await**
    - Typing async functions
    - Error handling with async/await
    - Parallel execution
    - Sequential vs concurrent operations
- **Day 6-7: Advanced Asynchronous Patterns**
    - Generators
    - Iterators
    - Observable pattern
    - Managing asynchronous state

### Week 8: TypeScript Compiler API and Transformation

- **Day 1-3: TypeScript Compiler API**
    - AST (Abstract Syntax Tree)
    - Creating program instances
    - Working with source files
- **Day 4-7: Custom Transformations**
    - Writing custom transformers
    - Code generation
    - Visitors pattern
    - Source code manipulation

### Week 9: TypeScript with Frameworks and Libraries

- **Day 1-2: TypeScript with React**
    - React component types
    - Props and state typing
    - Hooks with TypeScript
    - Context API typing
- **Day 3-4: TypeScript with Node.js**
    - Express with TypeScript
    - Type definitions for Node.js
    - Creating typed APIs
- **Day 5-7: TypeScript with other frameworks**
    - Angular with TypeScript
    - Vue with TypeScript
    - Next.js with TypeScript

**Project 3:** Develop a full-stack application using TypeScript both on the frontend (React/Angular/Vue) and backend (Node.js).

## Module 4: TypeScript in Production (3 weeks)

### Week 10: Performance Optimization

- **Day 1-3: Build Performance**
    - Project references
    - Incremental compilation
    - Optimizing tsconfig
- **Day 4-7: Runtime Performance**
    - Memory management
    - Reducing bundle size
    - Code splitting
    - Tree shaking with TypeScript

### Week 11: Advanced Configuration and Tools

- **Day 1-2: Advanced tsconfig Options**
    - Strict mode options
    - Module resolution options
    - Advanced compiler flags
- **Day 3-4: Linting and Code Quality**
    - ESLint with TypeScript
    - TSLint (legacy)
    - Custom lint rules
- **Day 5-7: Integration and Automation**
    - Continuous Integration
    - GitHub Actions with TypeScript
    - Automated testing
    - Deployment strategies

### Week 12: TypeScript Ecosystem and Best Practices

- **Day 1-2: Type-Safe Libraries**
    - fp-ts (functional programming)
    - io-ts (runtime type validation)
    - typesafe-actions (Redux)
- **Day 3-4: Monorepos with TypeScript**
    - Setting up monorepos
    - Sharing types across packages
    - Managing dependencies
- **Day 5-7: Emerging Patterns and Best Practices**
    - Branded types
    - Nominal typing techniques
    - Dependency injection patterns
    - State management patterns

**Final Project:** Create a production-ready application with TypeScript showcasing advanced patterns, optimizations, and best practices.

## Learning Resources

### Books

- "Programming TypeScript" by Boris Cherny
- "Effective TypeScript" by Dan Vanderkam
- "TypeScript in 50 Lessons" by Stefan Baumgartner
- "TypeScript Deep Dive" by Basarat Ali Syed (free online)

### Online Resources

- [TypeScript Official Documentation](https://www.typescriptlang.org/docs/)
- [TypeScript GitHub Repository](https://github.com/microsoft/TypeScript)
- [TypeScript Playground](https://www.typescriptlang.org/play)
- [TypeScript Weekly Newsletter](https://www.typescript-weekly.com/)
- [Definitely Typed Repository](https://github.com/DefinitelyTyped/DefinitelyTyped)

### Video Courses

- "Understanding TypeScript" by Maximilian Schwarzmüller (Udemy)
- "TypeScript: The Complete Developer's Guide" by Stephen Grider (Udemy)
- "Programming with TypeScript" by Dylan Israel (LinkedIn Learning)
- "Advanced TypeScript" by Egghead.io

### Communities

- [TypeScript Discord](https://discord.com/invite/typescript)
- [TypeScript GitHub Discussions](https://github.com/microsoft/TypeScript/discussions)
- [Stack Overflow - TypeScript tag](https://stackoverflow.com/questions/tagged/typescript)

## Assessment and Progression

### Progress Tracking

- Complete coding exercises for each topic
- Weekly quizzes to test understanding
- Code reviews of project work
- GitHub portfolio of completed projects

### Milestones

1. **Beginner:** Complete Module 1 and Project 1
2. **Intermediate:** Complete Modules 1-2 and Projects 1-2
3. **Advanced:** Complete Modules 1-3 and Projects 1-3
4. **Expert:** Complete all modules and final project

### Continued Learning Path

- Contribute to open-source TypeScript projects
- Create TypeScript type definitions for untyped libraries
- Explore TypeScript compiler internals
- Specialize in framework-specific TypeScript implementations

## Appendix: TypeScript Cheat Sheets

- Basic types reference
- Utility types quick reference
- tsconfig options guide
- Common error messages and solutions

---

# Introduction to TypeScript

## Setting Up Your Environment

### Installing TypeScript

TypeScript can be installed globally or locally in your project. The recommended approach is to install it locally to ensure version consistency across team members.

**Global installation:**

```bash
npm install -g typescript
```

**Local installation (recommended):**

```bash
# Initialize a new npm project if you haven't already
npm init -y
# Install TypeScript as a dev dependency
npm install typescript --save-dev
```

After installation, you can verify it by checking the version:

```bash
# For global installation
tsc --version
# For local installation
npx tsc --version
```

**Key points:**

- Local installation helps maintain consistent TypeScript versions across projects
- TypeScript is available through the Node.js package manager (npm)
- The TypeScript compiler is invoked using the `tsc` command

### Configuring tsconfig.json

The `tsconfig.json` file is central to TypeScript projects. It specifies compiler options and project settings.

To generate a basic configuration file:

```bash
npx tsc --init
```

This creates a well-documented `tsconfig.json` with common options. Here's a typical configuration:

```json
{
  "compilerOptions": {
    "target": "es2016",             /* JavaScript version for output */
    "module": "commonjs",           /* Module system for output JavaScript */
    "rootDir": "./src",             /* Source file directory */
    "outDir": "./dist",             /* Output directory */
    "esModuleInterop": true,        /* Enables import default from non-ES modules */
    "forceConsistentCasingInFileNames": true, /* Ensures consistent file naming */
    "strict": true,                 /* Enable all strict type-checking options */
    "skipLibCheck": true            /* Skip type checking of declaration files */
  },
  "include": ["src/**/*"],          /* Files to include */
  "exclude": ["node_modules"]       /* Files to exclude */
}
```

**Key points:**

- `target`: Specifies the ECMAScript version for output (ES6, ES2020, etc.)
- `module`: Defines the module system (CommonJS, ESNext, etc.)
- `rootDir`/`outDir`: Define source and output directories
- `strict`: Enables comprehensive type checking
- `include`/`exclude`: Control which files are processed

Common configurations:

```json
/* For modern web applications */
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "ESNext",
    "lib": ["DOM", "DOM.Iterable", "ESNext"],
    "jsx": "react-jsx",
    "sourceMap": true
  }
}

/* For Node.js applications */
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "NodeNext",
    "moduleResolution": "NodeNext",
    "outDir": "./dist"
  }
}
```

### TypeScript with VS Code

Visual Studio Code provides excellent TypeScript support out of the box as it's built with TypeScript.

**Recommended setup:**

1. **Install VS Code Extensions:**
    
    - TypeScript Hero: Organizes imports
    - ESLint: Code quality
    - Prettier: Code formatting
2. **Configure VS Code settings.json**:
    
    ```json
    {
      "typescript.updateImportsOnFileMove.enabled": "always",
      "typescript.preferences.importModuleSpecifier": "relative",
      "typescript.suggest.completeFunctionCalls": true,
      "editor.codeActionsOnSave": {
        "source.organizeImports": true
      },
      "[typescript]": {
        "editor.defaultFormatter": "esbenp.prettier-vscode",
        "editor.formatOnSave": true
      }
    }
    ```
    
3. **IntelliSense features:**
    
    - Code completion
    - Type information on hover
    - Parameter hints
    - Go to definition
    - Find all references
4. **Debugging TypeScript:**
    
    - Set breakpoints directly in TypeScript files
    - Use the built-in debugger with proper source maps

**Key points:**

- VS Code provides native TypeScript language services
- Extensions can enhance the TypeScript development experience
- Automatic type checking happens in real-time
- Integrated debugging works with source maps

### First TypeScript Program

Let's create a simple TypeScript program to verify our setup.

1. **Create project structure:**
    
    ```
    my-typescript-project/
    ├── src/
    │   └── index.ts
    ├── package.json
    └── tsconfig.json
    ```
    
2. **Add basic TypeScript code in `src/index.ts`:**
    
    ```typescript
    // Define a simple interface
    interface User {
      id: number;
      name: string;
      email: string;
      isActive: boolean;
    }
    
    // Function with typed parameters and return type
    function createUser(name: string, email: string): User {
      const id = Math.floor(Math.random() * 1000);
      return {
        id,
        name,
        email,
        isActive: true
      };
    }
    
    // Use the function with proper types
    const newUser = createUser("John Doe", "john@example.com");
    console.log(`Created user: ${newUser.name} (ID: ${newUser.id})`);
    
    // Intentional type error (uncomment to see error)
    // const invalidUser = createUser(123, "invalid@example.com");
    ```
    
3. **Add scripts to package.json:**
    
    ```json
    {
      "scripts": {
        "build": "tsc",
        "start": "node dist/index.js",
        "dev": "tsc --watch"
      }
    }
    ```
    
4. **Compile and run:**
    
    ```bash
    npm run build   # Compiles TypeScript to JavaScript
    npm start       # Runs the compiled JavaScript
    ```
    

**Example:** Enhanced version with more TypeScript features

```typescript
// Using type aliases and union types
type UserRole = "admin" | "editor" | "viewer";

// Extended interface
interface User {
  id: number;
  name: string;
  email: string;
  isActive: boolean;
  role: UserRole;
  metadata?: Record<string, unknown>; // Optional property with index signature
}

// Class implementation
class UserManager {
  private users: User[] = [];
  
  constructor(initialUsers: User[] = []) {
    this.users = initialUsers;
  }
  
  createUser(name: string, email: string, role: UserRole = "viewer"): User {
    const id = Math.floor(Math.random() * 1000);
    const newUser: User = {
      id,
      name,
      email,
      isActive: true,
      role
    };
    
    this.users.push(newUser);
    return newUser;
  }
  
  getUserById(id: number): User | undefined {
    return this.users.find(user => user.id === id);
  }
  
  getAllUsers(): readonly User[] {
    return [...this.users]; // Return a copy to prevent mutation
  }
}

// Using the class
const userManager = new UserManager();
const admin = userManager.createUser("Admin User", "admin@example.com", "admin");
const editor = userManager.createUser("Editor User", "editor@example.com", "editor");

console.log("Created users:");
console.log(userManager.getAllUsers());
```

**Output:**

```
Created users:
[
  {
    id: 123,
    name: 'Admin User',
    email: 'admin@example.com',
    isActive: true,
    role: 'admin'
  },
  {
    id: 456,
    name: 'Editor User',
    email: 'editor@example.com',
    isActive: true,
    role: 'editor'
  }
]
```

**Conclusion:** Setting up a TypeScript development environment involves installing the TypeScript compiler, configuring your project with tsconfig.json, leveraging IDE features in VS Code, and creating your first program. This foundation allows you to take advantage of TypeScript's static typing, improved tooling, and enhanced developer experience.

### Recommended Next Steps

- Learn TypeScript basic types and type annotations
- Explore TypeScript interfaces and classes
- Understand TypeScript modules and namespaces
- Investigate advanced type features like generics and utility types

---

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

# TypeScript Core Concepts

## Interfaces

### Creating Interfaces

Interfaces in TypeScript define contracts for object shapes, providing strong type checking for object structures. They establish a clear agreement about what properties and methods an object must have.

```typescript
interface Person {
  firstName: string;
  lastName: string;
  age: number;
  sayHello(): string;
}

// Implementing the interface
const john: Person = {
  firstName: "John",
  lastName: "Doe",
  age: 30,
  sayHello() {
    return `Hello, my name is ${this.firstName} ${this.lastName}`;
  }
};
```

Interfaces can also describe function types:

```typescript
interface CalculateTotal {
  (price: number, quantity: number, taxRate: number): number;
}

const calculateOrder: CalculateTotal = (price, quantity, taxRate) => {
  return price * quantity * (1 + taxRate);
};
```

And indexable types:

```typescript
interface StringDictionary {
  [key: string]: string;
}

const colors: StringDictionary = {
  primary: "#0070f3",
  secondary: "#ff4081",
  warning: "#ffeb3b"
};
```

**Key points:**

- Interfaces are pure TypeScript constructs with no JavaScript output
- They provide compile-time type-checking only
- Interface names conventionally start with capital letters
- Excess property checking occurs when object literals are directly assigned

### Optional Properties

Optional properties in interfaces are marked with the `?` modifier, indicating that the property may or may not exist on objects implementing the interface.

```typescript
interface Product {
  id: string;
  name: string;
  price: number;
  description?: string;  // Optional property
  discount?: number;     // Optional property
  category?: string;     // Optional property
}

// Valid implementations
const product1: Product = {
  id: "p1",
  name: "Smartphone",
  price: 699
};

const product2: Product = {
  id: "p2",
  name: "Laptop",
  price: 1299,
  description: "Powerful laptop with 16GB RAM",
  discount: 10,
  category: "Electronics"
};
```

You can check for optional properties before using them:

```typescript
function getDiscountedPrice(product: Product): number {
  if (product.discount) {
    return product.price * (1 - product.discount / 100);
  }
  return product.price;
}
```

Optional properties are especially useful for:

- Configuration objects
- API response types
- Form data validation

**Example:** Configuration interface with optional properties

```typescript
interface RequestConfig {
  url: string;
  method: 'GET' | 'POST' | 'PUT' | 'DELETE';
  headers?: {[key: string]: string};
  params?: {[key: string]: string | number};
  data?: any;
  timeout?: number;
  withCredentials?: boolean;
}

function fetchData(config: RequestConfig) {
  // Implementation
}

// Minimal usage
fetchData({
  url: 'https://api.example.com/data',
  method: 'GET'
});

// Full usage
fetchData({
  url: 'https://api.example.com/data',
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer token123'
  },
  data: { name: 'New Item' },
  timeout: 5000,
  withCredentials: true
});
```

**Key points:**

- Optional properties help create flexible interfaces
- Use optional parameters for properties that might not always be needed
- TypeScript performs strict null checking on optional properties
- The `?.` (optional chaining) operator works well with optional properties

### Readonly Properties

Readonly properties can only be set during object creation. Any attempt to modify them later results in a compile-time error.

```typescript
interface Point {
  readonly x: number;
  readonly y: number;
}

const origin: Point = { x: 0, y: 0 };
// Error: Cannot assign to 'x' because it is a read-only property
// origin.x = 10; 
```

Readonly is particularly useful for:

- Enforcing immutability
- Constants and configuration values
- Preventing accidental modifications

You can also make arrays and tuples readonly:

```typescript
interface Settings {
  readonly homeUrl: string;
  readonly apiKeys: readonly string[];
  readonly version: readonly [number, number, number]; // Semantic versioning
}

const appSettings: Settings = {
  homeUrl: "https://example.com",
  apiKeys: ["key1", "key2"],
  version: [1, 2, 3]  // [major, minor, patch]
};

// These would be compile errors:
// appSettings.homeUrl = "https://new-url.com";
// appSettings.apiKeys.push("key3");
// appSettings.version[0] = 2;
```

**Example:** Readonly state object in application

```typescript
interface AppState {
  readonly user: {
    readonly id: string;
    readonly name: string;
    readonly permissions: readonly string[];
  };
  readonly config: {
    readonly theme: string;
    readonly language: string;
  };
  isLoading: boolean; // Not readonly, can change
}

function createAppState(userId: string, userName: string): AppState {
  return {
    user: {
      id: userId,
      name: userName,
      permissions: ["read", "write"]
    },
    config: {
      theme: "light",
      language: "en"
    },
    isLoading: false
  };
}

const state = createAppState("u123", "John Doe");
// This works
state.isLoading = true;

// These would fail:
// state.user.name = "Jane Doe";
// state.config.theme = "dark";
// state.user.permissions.push("admin");
```

**Key points:**

- Readonly modifiers are compile-time only with no runtime checks
- `readonly` is different from JavaScript's `const` (which prevents reassignment of variables)
- TypeScript provides utility types like `Readonly<T>` to make all properties readonly
- For deep immutability, use `readonly` at all levels

#### `readyonly` vs `const`

In TypeScript, `readonly` and `const` are mechanisms to enforce immutability, but they serve different purposes and operate at different levels of the language. Below is a clear explanation of their differences, purposes, and practical implications, presented in a formal tone with precise language, as requested.

1. **Definition**
- **Readonly**:
  - A TypeScript modifier applied to properties in interfaces, types, or classes to indicate that the property cannot be reassigned after initialization.
  - Operates at the **type level**, enforcing immutability in the type system during compilation.
  - Syntax:
    ```typescript
    interface Point {
      readonly x: number;
      readonly y: number;
    }
    ```

- **Const**:
  - A JavaScript (and TypeScript) keyword used to declare variables that cannot be reassigned after their initial assignment.
  - Operates at the **runtime level**, enforced by the JavaScript engine.
  - Syntax:
    ```typescript
    const x: number = 42;
    ```

2. **Scope and Application**
- **Readonly**:
  - Applies to **object properties** (in interfaces, types, or classes).
  - Prevents reassignment of specific properties within an object, but the object itself can still be reassigned unless the variable is also `const`.
  - Example:
    ```typescript
    interface User {
      readonly id: number;
      name: string;
    }
    const user: User = { id: 1, name: "Alice" };
    user.name = "Bob"; // OK
    user.id = 2; // Error: Cannot assign to 'id' because it is a read-only property
    ```
  - Can be used in classes:
    ```typescript
    class Point {
      readonly x: number;
      constructor(x: number) {
        this.x = x; // OK during initialization
      }
    }
    const p = new Point(10);
    p.x = 20; // Error: Cannot assign to 'x' because it is a read-only property
    ```

- **Const**:
  - Applies to **variables** at the point of declaration.
  - Prevents reassignment of the variable itself, but does not prevent mutation of object properties if the variable holds an object.
  - Example:
    ```typescript
    const x: number = 42;
    x = 100; // Error: Cannot assign to 'x' because it is a constant
    const obj = { id: 1, name: "Alice" };
    obj.name = "Bob"; // OK, object properties are mutable
    obj = { id: 2, name: "Charlie" }; // Error: Cannot assign to 'obj' because it is a constant
    ```

3. **Immutability**
- **Readonly**:
  - Provides **shallow immutability** for the specific property it is applied to.
  - Does not prevent mutation of nested objects or arrays within a `readonly` property.
  - Example:
    ```typescript
    interface Config {
      readonly settings: { key: string };
    }
    const config: Config = { settings: { key: "value" } };
    config.settings = { key: "new" }; // Error: Cannot assign to 'settings' because it is a read-only property
    config.settings.key = "modified"; // OK, nested object is mutable
    ```
  - To enforce deep immutability, use `Readonly<T>` utility type or libraries like `deep-freeze`.
    ```typescript
    type DeepReadonly<T> = { readonly [K in keyof T]: DeepReadonly<T[K]> };
    ```

- **Const**:
  - Ensures the **variable binding** is immutable, but does not affect the mutability of the value’s contents if it’s an object or array.
  -',
  - Example:
    ```typescript
    const arr: number[] = [1, 2, 3];
    arr.push(4); // OK, array contents can be modified
    arr = [5, 6]; // Error: Cannot assign to 'arr' because it is a constant
    ```
  - For deep immutability, combine `const` with `Object.freeze`:
    ```typescript
    const obj = Object.freeze({ id: 1 });
    obj.id = 2; // Runtime error or ignored in strict mode
    ```

4. **Type System vs. Runtime**
- **Readonly**:
  - Enforced by TypeScript’s type system during compilation.
  - Errors are caught at compile time, not runtime.
  - Example:
    ```typescript
    interface Point {
      readonly x: number;
    }
    const p: Point = { x: 10 };
    p.x = 20; // Compile-time error
    ```
  - Does not affect JavaScript output; `readonly` is erased during compilation.

- **Const**:
  - Enforced by the JavaScript engine at runtime.
  - Errors occur when attempting to reassign a `const` variable during execution.
  - Example:
    ```typescript
    const x = 42;
    x = 100; // Runtime error: Assignment to constant variable
    ```

5. **Use Cases**
- **Readonly**:
  - Defining immutable object properties, such as IDs, configuration settings, or immutable data structures.
  - Ensuring properties of an object (e.g., in React props or state) are not modified after initialization.
  - Example:
    ```typescript
    interface Product {
      readonly id: string;
      name: string;
    }
    const product: Product = { id: "p1", name: "Widget" };
    product.name = "Gadget"; // OK
    product.id = "p2"; // Error
    ```

- **Const**:
  - Declaring variables that should not be reassigned, such as constants, configuration values, or fixed references.
  - Preventing accidental reassignment of variables in a function or module.
  - Example:
    ```typescript
    const PI: number = 3.14159;
    const API_URL: string = "https://api.example.com";
    PI = 3.14; // Error
    ```

6. **Combining `readonly` and `const`**
- Use `const` to prevent variable reassignment and `readonly` to prevent property mutation for maximum immutability.
- Example:
  ```typescript
  interface Config {
    readonly url: string;
  }
  const config: Config = { url: "https://api.example.com" };
  config = { url: "new" }; // Error: Cannot assign to 'config'
  config.url = "new"; // Error: Cannot assign to 'url'
  ```
- For nested immutability, combine with `Readonly<T>` or `Object.freeze`:
  ```typescript
  const config: Readonly<{ url: string }> = { url: "https://api.example.com" };
  ```

7. **Limitations**
- **Readonly**:
  - Only shallow; nested objects or arrays remain mutable unless explicitly made immutable.
  - Not enforced at runtime; relies on TypeScript’s type checking.
  - Cannot be applied to variables, only to object properties.

- **Const**:
  - Does not prevent mutation of object or array contents.
  - Limited to variable bindings, not properties.
  - Cannot be used for object properties directly.

8. **Key Differences Summary**

| Feature                  | `readonly`                            | `const`                              |
|--------------------------|---------------------------------------|--------------------------------------|
| **Scope**                | Object properties                    | Variables                           |
| **Level**                | Type system (compile-time)           | Runtime (JavaScript engine)         |
| **Immutability**         | Property value                       | Variable binding                    |
| **Mutates Contents**     | Yes (nested objects/arrays)          | Yes (object/array contents)         |
| **Use Case**             | Immutable object properties          | Immutable variable references       |
| **Enforcement**          | TypeScript type checker              | JavaScript runtime                  |

10. **Practical Recommendations**
- **Use `readonly`**:
  - For object properties that should not change after initialization, such as IDs, configuration settings, or immutable data.
  - In interfaces or classes to enforce structural immutability.
  - When defining types for libraries or APIs to prevent unintended modifications.
- **Use `const`**:
  - For variables that hold constant values, such as mathematical constants, URLs, or fixed configurations.
  - To prevent accidental reassignment in functions or modules.
  - When you need runtime immutability for variable references.
- **Combine for Robustness**:
  - Use `const` with `readonly` or `Readonly<T>` for objects requiring both variable and property immutability.
  - Use `Object.freeze` for runtime deep immutability when necessary.
- **Deep Immutability**:
  - For complex objects, consider utility types like `Readonly<T>` or libraries like `immer` for immutable updates.

10. **Example**
```typescript
// Using readonly
interface Point {
  readonly x: number;
  readonly y: number;
}
const point: Point = { x: 10, y: 20 };
point.x = 30; // Error: Cannot assign to 'x'

// Using const
const maxRetries: number = 3;
maxRetries = 5; // Error: Cannot assign to 'maxRetries'

// Combined
const fixedPoint: Readonly<Point> = { x: 10, y: 20 };
fixedPoint.x = 30; // Error: Cannot assign to 'x'
fixedPoint = { x: 40, y: 50 }; // Error: Cannot assign to 'fixedPoint'
```

### Extending Interfaces

Interfaces can extend other interfaces, inheriting their properties and methods while adding new ones.

```typescript
interface Person {
  name: string;
  age: number;
}

interface Employee extends Person {
  employeeId: string;
  department: string;
  salary: number;
}

// Must implement all properties from Person and Employee
const employee: Employee = {
  name: "Jane Smith",
  age: 32,
  employeeId: "E12345",
  department: "Engineering",
  salary: 75000
};
```

**Left-to-Right (LTR) Rule**: When an interface extends multiple interfaces, TypeScript merges the members of the base interfaces in the order they are listed. If multiple base interfaces define a member with the same name, the member from the rightmost interface in the extends clause overrides or takes precedence over earlier ones.

Interfaces can extend multiple other interfaces:

```typescript
interface Named {
  name: string;
}

interface Aged {
  age: number;
}

interface ContactInfo {
  email: string;
  phone?: string;
}

interface Customer extends Named, Aged, ContactInfo {
  customerId: string;
  loyaltyPoints: number;
}

const customer: Customer = {
  name: "Alice Johnson",
  age: 28,
  email: "alice@example.com",
  phone: "+1-555-123-4567",
  customerId: "C789",
  loyaltyPoints: 350
};
```

Interface extension can be used to create specialized versions of general interfaces:

```typescript
interface Shape {
  color: string;
  calculateArea(): number;
}

interface TwoDimensionalShape extends Shape {
  x: number;
  y: number;
}

interface Circle extends TwoDimensionalShape {
  radius: number;
}

interface Rectangle extends TwoDimensionalShape {
  width: number;
  height: number;
}

const myCircle: Circle = {
  color: "blue",
  x: 10,
  y: 20,
  radius: 5,
  calculateArea(): number {
    return Math.PI * this.radius * this.radius;
  }
};
```

**Example:** Building a complex application structure with interface extension

```typescript
// Base entity interface
interface Entity {
  id: string;
  createdAt: Date;
  updatedAt: Date;
}

// Interfaces for different entity types
interface User extends Entity {
  username: string;
  email: string;
  isActive: boolean;
}

interface Post extends Entity {
  title: string;
  content: string;
  authorId: string;
}

interface Comment extends Entity {
  postId: string;
  userId: string;
  text: string;
}

// Service interfaces
interface DataService<T extends Entity> {
  getById(id: string): Promise<T>;
  getAll(): Promise<T[]>;
  create(data: Omit<T, 'id' | 'createdAt' | 'updatedAt'>): Promise<T>;
  update(id: string, data: Partial<T>): Promise<T>;
  delete(id: string): Promise<boolean>;
}

// Implementation example
class UserService implements DataService<User> {
  async getById(id: string): Promise<User> {
    // Implementation
    return {
      id,
      username: "testuser",
      email: "test@example.com",
      isActive: true,
      createdAt: new Date(),
      updatedAt: new Date()
    };
  }
  
  // Other method implementations
  async getAll(): Promise<User[]> { return []; }
  async create(data: Omit<User, 'id' | 'createdAt' | 'updatedAt'>): Promise<User> { 
    return { ...data, id: "new-id", createdAt: new Date(), updatedAt: new Date() }; 
  }
  async update(id: string, data: Partial<User>): Promise<User> { 
    return { id, ...data } as User; 
  }
  async delete(id: string): Promise<boolean> { return true; }
}
```

**Key points:**

- Interface extension promotes code reuse and hierarchical type structures
- A class can implement multiple interfaces
- An interface can extend multiple interfaces
- TypeScript enforces that objects satisfy all requirements of extended interfaces
- You can override properties in derived interfaces to be more specific

### Interfaces vs. Type Aliases

TypeScript provides both interfaces and type aliases for defining custom types. Although they're similar, they have important differences.

**Syntax:**

```typescript
// Interface
interface User {
  id: string;
  name: string;
}

// Type alias
type User = {
  id: string;
  name: string;
};
```

**Extending/Intersection:**

```typescript
// Interface extending interface
interface Animal {
  name: string;
}

interface Dog extends Animal {
  breed: string;
}

// Type alias with intersection
type Animal = {
  name: string;
};

type Dog = Animal & {
  breed: string;
};
```

**Declaration merging:**

Only interfaces can merge multiple declarations:

```typescript
// These declarations merge
interface Window {
  title: string;
}

interface Window {
  ts: TypeScriptAPI;
}

// Window now has both title and ts properties

// This would be an error with type aliases:
// type Window = { title: string };
// type Window = { ts: TypeScriptAPI };
```

**Features comparison:**

|Feature|Interface|Type Alias|
|---|---|---|
|Declaration merging|✅ Yes|❌ No|
|Extends/implements clauses|✅ Yes|❌ No (directly)|
|Union types|❌ No|✅ Yes|
|Computed properties|❌ No|✅ Yes|
|Tuples and arrays|Possible but verbose|More concise|
|Primitives, unions, tuples|Not directly|✅ Yes|

**When to use interfaces:**

- Defining object shapes that will be implemented by classes
- When you want to take advantage of declaration merging
- For public API definitions where you expect extension
- For object-oriented designs

**When to use type aliases:**

- Working with unions, primitives, tuples, or function types
- Needing mapped or conditional types
- When the type won't be augmented or extended later
- When you want to create more complex type transformations

**Example:** Real-world comparison

```typescript
// Using interfaces for OOP-style code
interface Repository<T> {
  getAll(): Promise<T[]>;
  getById(id: string): Promise<T>;
  create(item: Omit<T, "id">): Promise<T>;
  update(id: string, item: Partial<T>): Promise<T>;
  delete(id: string): Promise<boolean>;
}

class UserRepository implements Repository<User> {
  // Implementation
}

// Using type aliases for functional programming style
type UserData = {
  id: string;
  name: string;
  email: string;
};

type UserId = string;
type UserWithoutId = Omit<UserData, "id">;
type UserPartial = Partial<UserData>;

type CrudOperations<T, ID> = {
  getAll: () => Promise<T[]>;
  getById: (id: ID) => Promise<T>;
  create: (item: Omit<T, "id">) => Promise<T>;
  update: (id: ID, item: Partial<T>) => Promise<T>;
  delete: (id: ID) => Promise<boolean>;
};

type UserCrudOperations = CrudOperations<UserData, UserId>;

// Using the type alias
const userOperations: UserCrudOperations = {
  getAll: async () => [],
  getById: async (id) => ({ id, name: "", email: "" }),
  create: async (user) => ({ ...user, id: "new-id" }),
  update: async (id, user) => ({ ...user, id } as UserData),
  delete: async (id) => true
};
```

**Key points:**

- Interfaces are more extensible (declaration merging)
- Type aliases are more flexible (unions, primitives, etc.)
- Interfaces result in better error messages in some cases
- Type aliases can leverage utility types more easily
- In most cases, they're interchangeable for simple object types
- Team consistency is important - pick one approach for similar use cases

### Best Practices for Interfaces

- Follow naming conventions (PascalCase)
- Keep interfaces focused with a single responsibility
- Use readonly for immutable properties
- Be explicit about optional properties
- Document interfaces with JSDoc comments
- Consider the consumer's perspective when designing interfaces
- Prefer interfaces for public APIs and library definitions
- Use declaration merging thoughtfully (usually for extending third-party types)

### Advanced Interface Techniques

#### Method overloading:

```typescript
interface Calculator {
  add(a: number, b: number): number;
  add(a: string, b: string): string;
  add(a: Date, b: number): Date;
}

// Implementation must handle all overloads
const calculator: Calculator = {
  add(a: any, b: any): any {
    if (typeof a === "number" && typeof b === "number") {
      return a + b;
    }
    if (typeof a === "string" && typeof b === "string") {
      return a.concat(b);
    }
    if (a instanceof Date && typeof b === "number") {
      const date = new Date(a);
      date.setDate(date.getDate() + b);
      return date;
    }
    throw new Error("Invalid arguments");
  }
};
```

#### Generic interfaces:

```typescript
interface Result<T> {
  data: T;
  success: boolean;
  message?: string;
}

function fetchUsers(): Promise<Result<User[]>> {
  return Promise.resolve({
    data: [],
    success: true
  });
}

function updateUser(id: string, data: Partial<User>): Promise<Result<User>> {
  return Promise.resolve({
    data: { id, ...data } as User,
    success: true,
    message: "User updated successfully"
  });
}
```

#### Recursive interfaces:

```typescript
interface TreeNode<T> {
  value: T;
  children?: TreeNode<T>[];
}

const fileSystem: TreeNode<string> = {
  value: "root",
  children: [
    {
      value: "src",
      children: [
        { value: "index.ts" },
        { value: "app.ts" }
      ]
    },
    {
      value: "package.json"
    }
  ]
};
```

**Conclusion:** Interfaces are one of TypeScript's most powerful features for defining types. They provide a flexible way to define contracts for object shapes, allowing for optional and readonly properties, and can be extended to create complex type hierarchies. Understanding when to use interfaces versus type aliases helps write more maintainable TypeScript code. Interfaces serve as a cornerstone for creating robust, type-safe applications, especially in object-oriented designs.

### Related Topics

- Classes and interface implementation
- Generic interfaces and type constraints
- Declaration merging with modules
- Structural typing vs. nominal typing
- Advanced mapped types with interfaces

---

## TypeScript Classes

### Class Syntax

TypeScript enhances JavaScript's class system with static type checking and additional features. The basic syntax for defining a class in TypeScript involves the `class` keyword followed by the class name and implementation.

**Key Points**

- Classes in TypeScript are blueprints for creating objects
- They encapsulate data and behavior through properties and methods
- TypeScript adds type annotations to JavaScript's class syntax
- Class members can be typed for better development experience

```typescript
class Person {
  name: string;
  age: number;

  constructor(name: string, age: number) {
    this.name = name;
    this.age = age;
  }

  greet(): void {
    console.log(`Hello, my name is ${this.name} and I'm ${this.age} years old.`);
  }
}

const person = new Person("Alice", 30);
person.greet(); // "Hello, my name is Alice and I'm 30 years old."
```

### Access Modifiers

TypeScript introduces access modifiers to control the visibility and accessibility of class members.

**Key Points**

- `public` - Members are accessible from anywhere (default if unspecified)
- `private` - Members are only accessible within the class
- `protected` - Members are accessible within the class and its subclasses
- Access modifiers enhance encapsulation and help prevent unintended modifications

```typescript
class Employee {
  public name: string;
  private salary: number;
  protected department: string;

  constructor(name: string, salary: number, department: string) {
    this.name = name;
    this.salary = salary;
    this.department = department;
  }

  public displayInfo(): void {
    console.log(`Name: ${this.name}, Department: ${this.department}`);
    this.calculateBonus(); // Can access private method
  }

  private calculateBonus(): number {
    return this.salary * 0.1; // Only accessible within Employee class
  }
}

const employee = new Employee("Bob", 50000, "Engineering");
console.log(employee.name); // OK: "Bob"
// console.log(employee.salary); // Error: 'salary' is private
// console.log(employee.department); // Error: 'department' is protected
```

### Parameter Properties

TypeScript provides a concise way to define and initialize class members directly in the constructor parameters.

**Key Points**

- Parameter properties combine declaration and initialization
- They reduce boilerplate code for class member initialization
- Created by prefixing constructor parameters with an access modifier

```typescript
class User {
  // No need for separate property declarations
  constructor(
    public username: string,
    private password: string,
    protected email: string,
    readonly id: number
  ) {}

  updatePassword(newPassword: string): void {
    this.password = newPassword;
  }
}

const user = new User("johndoe", "secret123", "john@example.com", 1);
console.log(user.username); // "johndoe"
console.log(user.id); // 1 (readonly but accessible)
// console.log(user.password); // Error: 'password' is private
```

### Inheritance

Classes in TypeScript can inherit properties and methods from other classes using the `extends` keyword.

**Key Points**

- Subclasses inherit accessible members from parent classes
- The `super` keyword is used to call the parent class constructor and methods
- Method overriding allows subclasses to provide specific implementations

```typescript
class Animal {
  constructor(protected name: string) {}

  move(distance: number = 0): void {
    console.log(`${this.name} moved ${distance} meters.`);
  }
}

class Dog extends Animal {
  constructor(name: string, private breed: string) {
    super(name); // Call parent constructor
  }

  bark(): void {
    console.log("Woof! Woof!");
  }

  // Method overriding
  move(distance: number = 5): void {
    console.log(`${this.name} is running...`);
    super.move(distance); // Call parent method
  }

  getInfo(): string {
    return `${this.name} is a ${this.breed}`;
  }
}

const dog = new Dog("Rex", "German Shepherd");
dog.move(); // "Rex is running..." followed by "Rex moved 5 meters."
dog.bark(); // "Woof! Woof!"
```

### Abstract Classes

Abstract classes serve as base classes that cannot be instantiated directly but can be extended by other classes.

**Key Points**

- Abstract classes are defined using the `abstract` keyword
- They can contain abstract methods that must be implemented by subclasses
- They can also contain concrete methods with implementations
- Abstract classes provide a way to define common behavior while enforcing implementation of specific methods

```typescript
abstract class Shape {
  constructor(protected color: string) {}

  // Abstract method - no implementation
  abstract calculateArea(): number;

  // Concrete method
  displayColor(): void {
    console.log(`This shape is ${this.color}.`);
  }
}

class Circle extends Shape {
  constructor(color: string, private radius: number) {
    super(color);
  }

  // Must implement the abstract method
  calculateArea(): number {
    return Math.PI * this.radius * this.radius;
  }
}

// const shape = new Shape("red"); // Error: Cannot instantiate abstract class
const circle = new Circle("blue", 5);
console.log(circle.calculateArea()); // 78.54...
circle.displayColor(); // "This shape is blue."
```

### Implementing Interfaces

Classes can implement interfaces to ensure they adhere to a specific contract.

**Key Points**

- Use the `implements` keyword to specify that a class implements an interface
- Classes must implement all properties and methods defined in the interface
- A class can implement multiple interfaces
- Interfaces define the structure but not the implementation

```typescript
interface Printable {
  print(): void;
}

interface Loggable {
  log(message: string): void;
}

class Document implements Printable, Loggable {
  constructor(private content: string) {}

  print(): void {
    console.log(`Printing: ${this.content}`);
  }

  log(message: string): void {
    console.log(`Log: ${message}`);
  }
}

const doc = new Document("TypeScript Interface Example");
doc.print(); // "Printing: TypeScript Interface Example"
doc.log("Document processed"); // "Log: Document processed"
```

### Method Modifiers

TypeScript provides additional method modifiers to control how methods can be used.

**Key Points**

- `static` - Methods belong to the class itself, not instances
- `readonly` - Properties that cannot be modified after initialization
- `abstract` - Methods that must be implemented by subclasses
- `get`/`set` - Accessor methods for controlled property access

```typescript
class MathUtility {
  // Static property: constant for PI
  static readonly PI: number = 3.14159;

  // Private static backing field for precision
  private static _precision: number = 2; // Default precision (decimal places)

  // Static getter for precision
  static get precision(): number {
    return this._precision;
  }

  // Static setter for precision with validation
  static set precision(value: number) {
    if (value < 0 || value > 10) {
      throw new Error("Precision must be between 0 and 10");
    }
    this._precision = value;
  }

  // Static method: addition
  static add(x: number, y: number): number {
    return Number((x + y).toFixed(this._precision));
  }

  // Static method: multiplication
  static multiply(x: number, y: number): number {
    return Number((x * y).toFixed(this._precision));
  }

  // Static method: calculate circle area
  static circleArea(radius: number): number {
    return Number((this.PI * radius * radius).toFixed(this._precision));
  }

  // Static method: round to current precision
  static round(value: number): number {
    return Number(value.toFixed(this._precision));
  }
}

// Usage examples
console.log(MathUtility.PI); // 3.14159
console.log(MathUtility.add(5.555, 3.333)); // 8.89 (default precision: 2)
console.log(MathUtility.multiply(4.444, 2)); // 8.89
console.log(MathUtility.circleArea(5)); // 78.54

// Access and modify precision using getter and setter
console.log(MathUtility.precision); // 2 (default)
MathUtility.precision = 4; // Set new precision
console.log(MathUtility.precision); // 4
console.log(MathUtility.add(5.55555, 3.33333)); // 8.8889 (new precision: 4)
console.log(MathUtility.circleArea(5)); // 78.5398

// Error handling
try {
  MathUtility.precision = 15; // Throws error
} catch (error) {
  console.error(error.message); // Precision must be between 0 and 10
}

// Rounding example
console.log(MathUtility.round(3.1415926535)); // 3.1416 (precision: 4)
```

### Getters and Setters

TypeScript supports getter and setter methods for controlled access to class properties.

**Key Points**

- Getters retrieve property values, potentially with additional logic
- Setters modify property values, potentially with validation
- They appear as properties rather than methods when used

```typescript
class BankAccount {
  private _balance: number = 0;

  // Getter
  get balance(): number {
    return this._balance;
  }

  // Setter with validation
  set balance(value: number) {
    if (value < 0) {
      throw new Error("Balance cannot be negative");
    }
    this._balance = value;
  }

  deposit(amount: number): void {
    if (amount <= 0) {
      throw new Error("Deposit amount must be positive");
    }
    this._balance += amount;
  }
}

const account = new BankAccount();
account.deposit(100);
console.log(account.balance); // 100 (calls the getter)
account.balance = 200; // Calls the setter
// account.balance = -50; // Error: Balance cannot be negative
```

### Static Members

Static members belong to the class itself rather than to instances of the class.

**Key Points**

- Static properties are shared across all instances
- Static methods can be called without creating an instance
- Static members are accessed using the class name
- Static members cannot directly access instance members without an instance reference

```typescript
class Counter {
  private static count: number = 0;
  public id: number;

  constructor() {
    Counter.count++;
    this.id = Counter.count;
  }

  static getCount(): number {
    return Counter.count;
  }

  static resetCount(): void {
    Counter.count = 0;
  }
}

const counter1 = new Counter();
console.log(counter1.id); // 1
const counter2 = new Counter();
console.log(counter2.id); // 2
console.log(Counter.getCount()); // 2
```

### Method Decorators

TypeScript supports decorators, which can be used to modify the behavior of classes and their members.

**Key Points**

- Decorators are a stage 2 ECMAScript proposal
- Enable metaprogramming features
- Can be applied to classes, methods, properties, or parameters
- Used extensively in frameworks like Angular

```typescript
// Method decorator example
function logger(target: any, propertyKey: string, descriptor: PropertyDescriptor) {
  const originalMethod = descriptor.value;
  
  descriptor.value = function(...args: any[]) {
    console.log(`Calling ${propertyKey} with arguments: ${JSON.stringify(args)}`);
    const result = originalMethod.apply(this, args);
    console.log(`Result: ${result}`);
    return result;
  };
  
  return descriptor;
}

class Calculator {
  @logger
  multiply(a: number, b: number): number {
    return a * b;
  }
}

const calc = new Calculator();
calc.multiply(2, 3);
// Outputs:
// "Calling multiply with arguments: [2,3]"
// "Result: 6"
```

### Class Expressions

Similar to function expressions, TypeScript supports class expressions for creating anonymous classes.

**Key Points**

- Can be used to create classes without naming them
- Useful for creating one-off classes or closures
- Can be assigned to variables or passed as arguments

```typescript
const Greeter = class {
  greeting: string;

  constructor(message: string) {
    this.greeting = message;
  }

  greet() {
    return `Hello, ${this.greeting}`;
  }
};

const greeter = new Greeter("world");
console.log(greeter.greet()); // "Hello, world"
```

### Mixins

TypeScript supports mixins, a pattern for composing classes from multiple source classes.

**Key Points**

- Mixins allow for code reuse without deep inheritance hierarchies
- Implemented using functions and interfaces
- Provide a form of multiple inheritance

```typescript
// Mixin constructor type
type Constructor<T = {}> = new (...args: any[]) => T;

// Mixins
function Timestamped<TBase extends Constructor>(Base: TBase) {
  return class extends Base {
    timestamp = new Date();
    
    getTimestamp() {
      return this.timestamp;
    }
  };
}

function Activatable<TBase extends Constructor>(Base: TBase) {
  return class extends Base {
    isActive = false;
    
    activate() {
      this.isActive = true;
    }
    
    deactivate() {
      this.isActive = false;
    }
  };
}

// Base class
class User {
  constructor(public name: string) {}
}

// Apply mixins
const TimestampedUser = Timestamped(User);
const TimestampedActivatableUser = Activatable(TimestampedUser);

// Create an instance
const user = new TimestampedActivatableUser("John");
console.log(user.name); // "John"
console.log(user.getTimestamp()); // Current date
user.activate();
console.log(user.isActive); // true
```

#### **Defining the Constructor Type**

- **What’s Happening**:
    - This defines a generic type alias `Constructor<T>` to represent a class constructor.
    - The `new` keyword indicates it’s a constructor function, callable with `new` to create instances.
    - `(...args: any[])` allows the constructor to accept any number of arguments of any type.
    - `=> T` specifies that the constructor returns an instance of type `T`.
    - The default `T = {}` means `T` is an empty object type if no type is provided, ensuring flexibility.
- **Purpose**:
    - Provides a reusable type for mixins to accept any base class constructor, enabling type-safe extension.
    - The generic `T` ensures the mixin’s return type aligns with the base class’s instance type.
- **Origin**:
    - This is a TypeScript convention for mixins, not tied to any specific class or mixin yet.
- **Output**:
    - A type definition, used later by mixins to constrain the `TBase` parameter.

### Generic Classes

TypeScript allows creating generic classes that work with different types.

**Key Points**

- Generic classes provide type safety with flexibility
- Type parameters are specified in angle brackets
- Enables creation of reusable components that work with various types

```typescript
class Queue<T> {
  private items: T[] = [];
  
  enqueue(item: T): void {
    this.items.push(item);
  }
  
  dequeue(): T | undefined {
    return this.items.shift();
  }
  
  peek(): T | undefined {
    return this.items[0];
  }
  
  size(): number {
    return this.items.length;
  }
}

const numberQueue = new Queue<number>();
numberQueue.enqueue(1);
numberQueue.enqueue(2);
console.log(numberQueue.dequeue()); // 1

const stringQueue = new Queue<string>();
stringQueue.enqueue("hello");
stringQueue.enqueue("world");
console.log(stringQueue.peek()); // "hello"
```

### Class Property Initialization

TypeScript provides several ways to initialize class properties.

**Key Points**

- Properties can be initialized at declaration
- Properties can be initialized in the constructor
- TypeScript 2.0+ introduced non-nullable types and the definite assignment assertion
- The `!` operator tells TypeScript that a property will be initialized

```typescript
class Product {
  // Initialized at declaration
  id: number = 0;
  
  // Will be initialized in constructor
  name: string;
  
  // Definite assignment assertion
  price!: number;
  
  // Optional property
  description?: string;
  
  constructor(name: string) {
    this.name = name;
    // Note: price is not initialized here
  }
  
  initialize(price: number, description?: string): void {
    this.price = price;
    this.description = description;
  }
}

const product = new Product("Laptop");
product.initialize(999.99);
console.log(product.name); // "Laptop"
console.log(product.price); // 999.99
```

### Type Checking with Classes

TypeScript uses structural typing for classes, which means compatibility is determined by the structure, not by explicit inheritance.

**Key Points**

- Two classes with the same structure are compatible
- Private and protected members affect compatibility
- Classes can be used as interfaces

```typescript
class Point2D {
  constructor(public x: number, public y: number) {}
}

class Point3D {
  constructor(public x: number, public y: number, public z: number) {}
}

class Circle {
  constructor(public x: number, public y: number, public radius: number) {}
}

// Structural compatibility
let p2d: Point2D = new Point2D(1, 2);
let p3d: Point3D = new Point3D(1, 2, 3);

// p2d = p3d; // OK: p3d has all required properties of Point2D
// p3d = p2d; // Error: p2d is missing the z property

// c and p2d have compatible structures
let c: Circle = new Circle(0, 0, 10);
p2d = c; // OK: c has x and y properties
```

### Design Patterns with Classes

TypeScript classes are well-suited for implementing common design patterns.

**Key Points**

- TypeScript's static typing makes patterns more robust
- Abstract classes and interfaces help enforce pattern contracts
- Access modifiers enable proper encapsulation

**Example**

```typescript
// Singleton pattern
class Singleton {
  private static instance: Singleton;
  
  private constructor() {}
  
  public static getInstance(): Singleton {
    if (!Singleton.instance) {
      Singleton.instance = new Singleton();
    }
    return Singleton.instance;
  }
  
  public someMethod(): void {
    console.log("Method called on singleton");
  }
}

const instance1 = Singleton.getInstance();
const instance2 = Singleton.getInstance();
console.log(instance1 === instance2); // true
```

### Class Declaration Merging

In TypeScript, classes can be merged with interfaces of the same name.

**Key Points**

- Classes and interfaces with the same name are merged
- The interface defines additional contract requirements
- Useful for adding static members or enforcing implementation

```typescript
// Interface declaration
interface Vehicle {
  start(): void;
  stop(): void;
}

// Class declaration with the same name
class Vehicle {
  constructor(public name: string) {}
  
  static categories: string[] = ["Land", "Sea", "Air"];
  
  // Must implement the interface methods
  start(): void {
    console.log(`${this.name} starting...`);
  }
  
  stop(): void {
    console.log(`${this.name} stopping...`);
  }
}

const car = new Vehicle("Car");
car.start(); // "Car starting..."
console.log(Vehicle.categories); // ["Land", "Sea", "Air"]
```

---

## Enums, Unions, and Literal Types

### Enum Types

**Key Points**

- Enums create named constants with descriptive labels
- Numeric enums auto-increment by default, starting at 0
- String enums require explicit values for each member
- Const enums are completely removed during compilation for performance

Enums in TypeScript define a set of named constants, providing a way to document intent and create a set of distinct cases:

```typescript
// Numeric enum (values auto-increment starting from 0)
enum Direction {
  North,  // 0
  East,   // 1
  South,  // 2
  West    // 3
}

let myDirection: Direction = Direction.North;
console.log(myDirection);  // 0

// Numeric enum with custom starting value
enum HttpStatus {
  OK = 200,
  Created = 201,
  BadRequest = 400,
  Unauthorized = 401,
  NotFound = 404,
  ServerError = 500
}

function handleResponse(status: HttpStatus) {
  if (status === HttpStatus.OK) {
    console.log("Request succeeded");
  }
}
```

String enums provide more meaningful values when debugging:

```typescript
// String enum (requires explicit values)
enum Color {
  Red = "RED",
  Green = "GREEN",
  Blue = "BLUE"
}

let favoriteColor: Color = Color.Blue;
console.log(favoriteColor);  // "BLUE"

// Heterogeneous enum (mixed string and numeric values)
enum BooleanLike {
  No = 0,
  Yes = "YES"
}
```

Const enums are optimized away during compilation:

```typescript
// Const enum (inlined during compilation)
const enum Planet {
  Mercury = 1,
  Venus,
  Earth,
  Mars
}

let homePlanet = Planet.Earth;
// Compiles to: let homePlanet = 3;
```

Enum best practices:

1. Use PascalCase for enum names and members
2. Use const enums for better performance when possible
3. Consider string enums for better debugging experience
4. For simple cases, consider using union of literal types instead

### Union Types

**Key Points**

- Union types allow a value to be one of several types
- Denoted with the pipe symbol (`|`)
- Only operations valid for all possible types are allowed without narrowing
- Useful for function parameters that accept different types

Union types allow a variable to have more than one possible type:

```typescript
// Simple union type
let id: string | number;
id = 123;     // Valid
id = "abc";   // Valid
// id = true; // Error: Type 'boolean' is not assignable to type 'string | number'

// Union type with function parameters
function formatValue(value: string | number): string {
  if (typeof value === "string") {
    return value.toUpperCase();
  }
  return value.toFixed(2);
}

formatValue("hello");  // "HELLO"
formatValue(42.325);   // "42.33"

// Union with null for optional values
let username: string | null = null;
username = "john_doe";

// Array of union types
let mixed: (string | number)[] = ["hello", 42, "world", 100];
```

Union types restrict access to properties and methods to only those common to all possible types:

```typescript
// Only operations valid on ALL potential types are allowed without narrowing
function printId(id: string | number) {
  console.log(id.toString());  // OK: both string and number have toString()
  
  // Error: Property 'toUpperCase' doesn't exist on type 'number'
  // console.log(id.toUpperCase());
  
  // With type narrowing, we can access type-specific methods
  if (typeof id === "string") {
    console.log(id.toUpperCase());  // Now OK
  } else {
    console.log(id.toFixed(2));     // Now OK
  }
}
```

### Intersection Types

**Key Points**

- Intersection types combine multiple types into one
- Denoted with the ampersand symbol (`&`)
- The resulting type has all properties from all constituent types
- Often used with object types to merge their properties

Intersection types combine multiple types into one:

```typescript
// Basic intersection of object types
type Employee = {
  id: number;
  name: string;
};

type Manager = {
  managerId: number;
  team: string[];
};

// Combined type has all properties from both types
type TeamManager = Employee & Manager;

const engineering: TeamManager = {
  id: 1,
  name: "Alice Smith",
  managerId: 101,
  team: ["Bob", "Charlie", "Dave"]
};

// Missing any property would cause an error
// const incomplete: TeamManager = { 
//   id: 2,
//   name: "John Doe",
//   managerId: 102
//   // Error: Property 'team' is missing
// };
```

Intersection types can combine interfaces as well:

```typescript
interface Printable {
  print(): void;
}

interface Loggable {
  log(): void;
}

// Create a type that can both print and log
type PrintableLogger = Printable & Loggable;

class Report implements PrintableLogger {
  print() {
    console.log("Printing report...");
  }
  
  log() {
    console.log("Logging report activity...");
  }
}
```

Combining incompatible types creates a never type:

```typescript
// Intersection of incompatible primitives results in never
type ImpossibleType = string & number;
// No value can ever be both a string and a number

// But this works fine for object types that don't conflict
type HasName = { name: string };
type HasAge = { age: number };
type Person = HasName & HasAge;  // { name: string; age: number }
```

### Literal Types

**Key Points**

- Literal types are exact values, not just types
- String, number, and boolean literals are supported
- They work well with union types to create type-safe enumerations
- More flexible than enums in some cases

Literal types represent exact values, not just the broader type:

```typescript
// String literal types
type Direction = "north" | "east" | "south" | "west";
let heading: Direction = "north";  // Valid
// heading = "northeast";  // Error: Type '"northeast"' is not assignable to type 'Direction'

// Number literal types
type DiceRoll = 1 | 2 | 3 | 4 | 5 | 6;
let roll: DiceRoll = 6;  // Valid
// let invalidRoll: DiceRoll = 7;  // Error

// Boolean literal type (rarely used alone)
type True = true;
let isEnabled: True = true;
// isEnabled = false;  // Error

// Combining literal types with other types
type Status = "pending" | "processing" | "success" | "error" | number;
let orderStatus: Status = "processing";  // Valid
orderStatus = 404;  // Also valid
// orderStatus = true;  // Error
```

Literal types are especially useful for function parameters that accept specific values:

```typescript
// Function accepting specific string literals
function setAlignment(align: "left" | "center" | "right"): void {
  // Implementation
}

setAlignment("left");    // Valid
// setAlignment("top");  // Error

// Object with literal properties
type Options = {
  method: "GET" | "POST" | "PUT" | "DELETE";
  timeout: 1000 | 2000 | 5000;
};

const request: Options = {
  method: "POST",
  timeout: 1000
};
```

Literal types can create powerful type-safe APIs:

```typescript
// Configuration object with specific allowed values
type Config = {
  theme: "light" | "dark" | "system";
  notifications: "all" | "important" | "none";
  fontSize: 12 | 14 | 16 | 18 | 20;
};

// Function that validates configuration
function updateConfig(settings: Partial<Config>) {
  // Implementation
}

updateConfig({ theme: "dark", fontSize: 16 });  // Valid
// updateConfig({ theme: "blue" });  // Error
```

### Type Narrowing

**Key Points**

- Type narrowing refines types from broader to more specific
- Common narrowing techniques include type guards, equality checks, and truthiness checks
- The `in` operator and instanceof checks work for objects
- Type predicates allow for custom type guards

Type narrowing is the process of refining types to more specific versions within conditional blocks:

```typescript
// Basic typeof type guard
function process(value: string | number) {
  if (typeof value === "string") {
    // In this block, TypeScript treats value as string
    return value.toUpperCase();
  } else {
    // In this block, TypeScript treats value as number
    return value.toFixed(2);
  }
}

// Equality narrowing
function example(x: string | number, y: string | boolean) {
  if (x === y) {
    // Here, x and y must both be strings
    console.log(x.toUpperCase());
    console.log(y.toLowerCase());
  } else {
    // x is string | number
    // y is string | boolean
  }
}
```

Truthiness checks can narrow types too:

```typescript
// Truthiness narrowing
function printValue(value: string | number | null | undefined) {
  // Removes null and undefined from the type
  if (value) {
    // Here, value is string | number
    console.log("Value:", value);
  } else {
    // Here, value might be empty string, 0, null, or undefined
    console.log("No value");
  }
}

// Specific null check
function greet(name: string | null) {
  if (name !== null) {
    // Here name is just string
    console.log(`Hello, ${name.toUpperCase()}`);
  }
}
```

For objects, use the `in` operator, instanceof, and property existence checks:

```typescript
// in operator narrowing
type Fish = { swim: () => void };
type Bird = { fly: () => void };

function move(animal: Fish | Bird) {
  if ("swim" in animal) {
    // Here, animal is Fish
    animal.swim();
  } else {
    // Here, animal is Bird
    animal.fly();
  }
}

// instanceof narrowing
class Car {
  drive() { console.log("Driving car..."); }
}

class Motorcycle {
  ride() { console.log("Riding motorcycle..."); }
}

function useVehicle(vehicle: Car | Motorcycle) {
  if (vehicle instanceof Car) {
    vehicle.drive();
  } else {
    vehicle.ride();
  }
}
```

Custom type guards with type predicates provide reusable type narrowing:

```typescript
// Type predicate (custom type guard)
interface Student {
  name: string;
  studentId: string;
}

interface Employee {
  name: string;
  employeeId: string;
  department: string;
}

// Type predicate function
function isStudent(person: Student | Employee): person is Student {
  return "studentId" in person;
}

function processSchoolMember(person: Student | Employee) {
  if (isStudent(person)) {
    // TypeScript knows person is Student here
    console.log(`Student: ${person.studentId}`);
  } else {
    // TypeScript knows person is Employee here
    console.log(`Employee: ${person.employeeId}, Dept: ${person.department}`);
  }
}
```

Discriminated unions provide another powerful way to narrow types:

```typescript
// Discriminated union with a "kind" property
type Shape = 
  | { kind: "circle"; radius: number }
  | { kind: "square"; sideLength: number }
  | { kind: "rectangle"; width: number; height: number };

function calculateArea(shape: Shape): number {
  switch (shape.kind) {
    case "circle":
      // TypeScript knows shape is the circle variant
      return Math.PI * shape.radius ** 2;
    case "square":
      // TypeScript knows shape is the square variant
      return shape.sideLength ** 2;
    case "rectangle":
      // TypeScript knows shape is the rectangle variant
      return shape.width * shape.height;
  }
}
```

**Conclusion**

TypeScript's enums, unions, intersections, and literal types provide powerful tools for modeling data and ensuring type safety. Enums offer named constants, union types allow variables to have multiple potential types, intersection types combine types, and literal types create precise restrictions to specific values.

Type narrowing is essential when working with these advanced types, allowing TypeScript to understand the specific type of a variable within conditional blocks. The various narrowing techniques—type guards, equality checks, truthiness checks, and custom type predicates—empower developers to write type-safe code with complex data structures.

These features are the building blocks for creating expressive, maintainable TypeScript code that prevents bugs through compile-time type checking while supporting complex type relationships and constraints.

---

# Advanced Types

## Generics in TypeScript

### Introduction to Generics

Generics are one of TypeScript's most powerful features, allowing you to create reusable components that work with a variety of types while maintaining type safety. Rather than using `any` and losing type information, generics let you capture the type provided at the time of use, preserving important type relationships throughout your code.

### Generic Functions

Generic functions allow you to write functions that can operate on a variety of types while preserving type information.

**Basic Generic Function**

```typescript
function identity<T>(arg: T): T {
  return arg;
}

// Explicit type parameter
const output1 = identity<string>("hello"); // type: string

// Type inference (TypeScript infers T as number)
const output2 = identity(42); // type: number
```

**Multiple Type Parameters**

```typescript
function pair<T, U>(first: T, second: U): [T, U] {
  return [first, second];
}

const pairResult = pair<string, number>("age", 30); // type: [string, number]
const inferredPair = pair(true, "value"); // type: [boolean, string]
```

**Generic Arrow Functions**

```typescript
const getProperty = <T, K extends keyof T>(obj: T, key: K): T[K] => {
  return obj[key];
};

const user = { name: "Alice", age: 30 };
const userName = getProperty(user, "name"); // type: string
```

**Generic Function with Array Type**

```typescript
function firstElement<T>(arr: T[]): T | undefined {
  return arr.length > 0 ? arr[0] : undefined;
}

const firstNumber = firstElement([1, 2, 3]); // type: number | undefined
const firstString = firstElement(["a", "b", "c"]); // type: string | undefined
```

**Function with Generic Return Type**

```typescript
function wrapInArray<T>(value: T): T[] {
  return [value];
}

const numberArray = wrapInArray(42); // type: number[]
const stringArray = wrapInArray("hello"); // type: string[]
```

**Generic Rest Parameters**

```typescript
function merge<T>(...objects: T[]): T {
  return Object.assign({}, ...objects);
}

const merged = merge({name: "John"}, {age: 30}, {city: "New York"});
```

### Generic Interfaces

Generic interfaces allow you to define reusable, type-safe contract shapes that can work with different types.

**Basic Generic Interface**

```typescript
interface Box<T> {
  value: T;
}

const stringBox: Box<string> = { value: "hello" };
const numberBox: Box<number> = { value: 42 };
```

**Generic Interface with Multiple Type Parameters**

```typescript
interface Dictionary<K extends string | number | symbol, V> {
  [key: K]: V;
}

interface PhoneBook {
  [name: string]: number;
}

const phoneBook: PhoneBook = {
  "John": 1234567890,
  "Jane": 9876543210
};
```

**Generic Interface for Functions**

```typescript
interface Parser<T> {
  (input: string): T;
}

const numberParser: Parser<number> = (input) => parseFloat(input);
const boolParser: Parser<boolean> = (input) => input === "true";

const parsedNumber = numberParser("42"); // type: number
const parsedBool = boolParser("true");   // type: boolean
```

**Extending Generic Interfaces**

```typescript
interface Response<T> {
  data: T;
  status: number;
  ok: boolean;
}

interface PaginatedResponse<T> extends Response<T[]> {
  total: number;
  page: number;
  pageSize: number;
}

const usersResponse: PaginatedResponse<User> = {
  data: [{ id: 1, name: "Alice" }, { id: 2, name: "Bob" }],
  status: 200,
  ok: true,
  total: 100,
  page: 1,
  pageSize: 10
};
```

**Generic Interface with Index Type**

```typescript
interface Record<K extends keyof any, T> {
  [P in K]: T;
}

// Creates an object type with properties from K of type T
const nameAgeMap: Record<string, number> = {
  "Alice": 30,
  "Bob": 25
};
```

### Generic Classes

Generic classes enable you to build reusable class structures that work with different types.

**Basic Generic Class**

```typescript
class Queue<T> {
  private items: T[] = [];

  enqueue(item: T): void {
    this.items.push(item);
  }

  dequeue(): T | undefined {
    return this.items.shift();
  }

  peek(): T | undefined {
    return this.items[0];
  }
}

const numberQueue = new Queue<number>();
numberQueue.enqueue(1);
numberQueue.enqueue(2);
const firstItem = numberQueue.dequeue(); // type: number | undefined

const stringQueue = new Queue<string>();
stringQueue.enqueue("hello");
```

**Generic Class with Constructor**

```typescript
class Container<T> {
  constructor(private value: T) {}

  getValue(): T {
    return this.value;
  }

  setValue(value: T): void {
    this.value = value;
  }
}

const stringContainer = new Container<string>("initial value");
const value = stringContainer.getValue(); // type: string
stringContainer.setValue("new value");
```

**Generic Class with Multiple Type Parameters**

```typescript
class KeyValuePair<K, V> {
  constructor(public key: K, public value: V) {}
}

const pair1 = new KeyValuePair<string, number>("age", 30);
const pair2 = new KeyValuePair<number, string>(1, "first");
```

**Generic Class with Static Methods**

```typescript
class StaticGeneric<T> {
  static createEmpty<U>(): U[] {
    return [];
  }

  instanceMethod(value: T): T {
    return value;
  }
}

// Note: Static methods require their own type parameter
const emptyNumbers = StaticGeneric.createEmpty<number>();
const instance = new StaticGeneric<string>();
const result = instance.instanceMethod("hello"); // type: string
```

**Generic Class Implementing Generic Interface**

```typescript
interface Collection<T> {
  add(item: T): void;
  remove(item: T): boolean;
  contains(item: T): boolean;
}

class List<T> implements Collection<T> {
  private items: T[] = [];

  add(item: T): void {
    this.items.push(item);
  }

  remove(item: T): boolean {
    const index = this.items.indexOf(item);
    if (index > -1) {
      this.items.splice(index, 1);
      return true;
    }
    return false;
  }

  contains(item: T): boolean {
    return this.items.includes(item);
  }
}

const stringList = new List<string>();
stringList.add("hello");
const hasHello = stringList.contains("hello"); // true
```

### Generic Constraints

Generic constraints allow you to restrict the types that can be used with your generics, ensuring specific capabilities.

**Using extends Keyword**

```typescript
interface HasLength {
  length: number;
}

// T must have a length property
function logLength<T extends HasLength>(arg: T): T {
  console.log(arg.length);
  return arg;
}

logLength("hello"); // Valid: string has length
logLength([1, 2, 3]); // Valid: array has length
logLength({length: 10, value: 3}); // Valid: object has length
// logLength(10); // Error: number does not have length
```

**Constraining with Object Types**

```typescript
function getProperty<T extends object, K extends keyof T>(obj: T, key: K): T[K] {
  return obj[key];
}

const person = { name: "John", age: 30 };
const name = getProperty(person, "name"); // type: string
const age = getProperty(person, "age");   // type: number
// getProperty(person, "height"); // Error: 'height' is not a key of person
```

**Multiple Constraints with Intersection Types**

```typescript
interface Printable {
  print(): void;
}

interface Loggable {
  log(): void;
}

function processObject<T extends Printable & Loggable>(obj: T): void {
  obj.print();
  obj.log();
}

class PrintableLoggable implements Printable, Loggable {
  print() { console.log("Printing..."); }
  log() { console.log("Logging..."); }
}

processObject(new PrintableLoggable()); // Valid
// processObject({ print() {} }); // Error: missing log method
```

**Using Type Parameters as Constraints**

```typescript
function copyFields<T extends U, U>(target: T, source: U): T {
  for (const id in source) {
    target[id] = source[id];
  }
  return target;
}

const sourceObj = { a: 1, b: 2, c: 3 };
const targetObj = { a: 100, b: 200, c: 300, d: 400 };
const result = copyFields(targetObj, sourceObj);
```

**Generic Constraints with Classes**

```typescript
class Animal {
  move() { console.log("Moving..."); }
}

class Dog extends Animal {
  bark() { console.log("Woof!"); }
}

function createInstance<T extends Animal>(c: new () => T): T {
  return new c();
}

const animal = createInstance(Animal); // type: Animal
const dog = createInstance(Dog);       // type: Dog
dog.bark(); // Valid
```

**Default Type Parameters**

```typescript
interface Response<T = any> {
  data: T;
  status: number;
}

// No type argument needed, defaults to any
const response: Response = { data: "hello", status: 200 };

// Explicit type argument
const typedResponse: Response<number> = { data: 42, status: 200 };
```

### Advanced Generic Patterns

**Conditional Types**

```typescript
type IsArray<T> = T extends any[] ? true : false;

type StringOrNot = IsArray<string>;  // type: false
type NumberArrayOrNot = IsArray<number[]>; // type: true
```

**Mapped Types with Generics**

```typescript
type Readonly<T> = {
  readonly [P in keyof T]: T[P];
};

interface User {
  name: string;
  age: number;
}

const readonlyUser: Readonly<User> = { name: "John", age: 30 };
// readonlyUser.name = "Jane"; // Error: Cannot assign to 'name' because it is a read-only property
```

**Generic Type Guards**

```typescript
function isOfType<T>(obj: any, prop: keyof T): obj is T {
  return obj && typeof obj === 'object' && prop in obj;
}

interface User {
  name: string;
  email: string;
}

function processEntity(entity: any) {
  if (isOfType<User>(entity, 'email')) {
    // TypeScript knows entity is User
    console.log(entity.name);
  }
}
```

**Generic Factory Pattern**

```typescript
interface Widget {
  id: string;
  render(): void;
}

class Button implements Widget {
  id: string = "button";
  render() { console.log("Rendering button"); }
}

class TextField implements Widget {
  id: string = "textfield";
  render() { console.log("Rendering text field"); }
}

function createWidget<T extends Widget>(type: new () => T): T {
  return new type();
}

const button = createWidget(Button);
const textField = createWidget(TextField);
```

### Generic Type Inference

TypeScript can often infer the types for generics based on the arguments provided.

**Function Return Type Inference**

```typescript
function map<T, U>(array: T[], fn: (item: T) => U): U[] {
  return array.map(fn);
}

// TypeScript infers T as number and U as string
const lengths = map([1, 2, 3], n => n.toString());
```

**Context-Based Type Inference**

```typescript
// TypeScript can infer the type from expected context
function createPair<S, T>(v1: S, v2: T): [S, T] {
  return [v1, v2];
}

// Function type parameter inference
const pair: [string, number] = createPair("hello", 42);
```

### Best Practices for Generics

1. **Use descriptive type parameter names**: `T` is conventional for a generic type, but for multiple parameters, use descriptive names like `TKey`, `TValue` or domain-specific names like `TUser`, `TResponse`.
    
2. **Limit the number of type parameters**: Too many type parameters make code hard to understand. Consider refactoring if you need more than 2-3.
    
3. **Use constraints to ensure required functionality**: With constraints, you get better error messages and editor support.
    
4. **Prefer interfaces for constraint shapes**: Use interface constraints for better readability and reuse.
    
5. **Use type inference when possible**: Let TypeScript infer types where it can to reduce verbosity.
    
6. **Consider default type parameters**: Default type parameters help make generics more usable.
    

**Common Generics Mistakes**

```typescript
// AVOID: Using any when generic would preserve type information
function badExample(value: any): any {
  return value;
}

// BETTER: Using generics to preserve type information
function goodExample<T>(value: T): T {
  return value;
}

// AVOID: Unnecessary type constraints
function restrictiveFunction<T extends string>(value: T): T {
  return value;
}

// BETTER: Only use constraints when necessary
function flexibleFunction<T>(value: T): T {
  return value;
}
```

### Built-in Generic Types

TypeScript provides several built-in generic types:

**Array\<T>**

```typescript
const numbers: Array<number> = [1, 2, 3];
const strings: Array<string> = ["a", "b", "c"];
```

**Promise\<T>**

```typescript
const promise: Promise<string> = new Promise((resolve) => {
  setTimeout(() => resolve("Hello"), 1000);
});

async function fetchData(): Promise<User[]> {
  const response = await fetch('/api/users');
  return response.json();
}
```

**ReadonlyArray\<T>**

```typescript
function displayData(data: ReadonlyArray<string>): void {
  console.log(data.join(", "));
  // data.push("new item"); // Error: Property 'push' does not exist on type 'readonly string[]'
}
```

**Record<K, T>**

```typescript
const employees: Record<string, number> = {
  "Alice": 100000,
  "Bob": 120000,
  "Charlie": 110000
};
```

**Partial\<T>**

```typescript
interface User {
  name: string;
  age: number;
  email: string;
}

function updateUser(user: User, updates: Partial<User>): User {
  return { ...user, ...updates };
}

const user: User = {
  name: "John",
  age: 30,
  email: "john@example.com"
};

const updatedUser = updateUser(user, { age: 31 });
```

**Required\<T>**

```typescript
interface Config {
  host?: string;
  port?: number;
  protocol?: string;
}

// Makes all properties required
const serverConfig: Required<Config> = {
  host: "localhost",
  port: 8080,
  protocol: "https"
};
```

**Pick\<T, K>**

```typescript
interface Article {
  id: number;
  title: string;
  content: string;
  tags: string[];
  publishDate: Date;
}

// Only include specified properties
type ArticleSummary = Pick<Article, "id" | "title" | "publishDate">;

const summary: ArticleSummary = {
  id: 1,
  title: "Understanding TypeScript Generics",
  publishDate: new Date()
};
```

**Omit\<T, K>**

```typescript
interface User {
  id: number;
  name: string;
  password: string;
  email: string;
}

// Exclude specified properties
type PublicUser = Omit<User, "password">;

const publicUserInfo: PublicUser = {
  id: 1,
  name: "Alice",
  email: "alice@example.com"
};
```

**Recommended Related Topics**

- Advanced Type Manipulation in TypeScript
- Higher-Order Types and Type Operators
- Type Guards and Type Narrowing
- TypeScript Utility Types
- Pattern Matching with TypeScript

---

## Advanced Type Features

### Type Assertions

Type assertions in TypeScript allow you to tell the compiler to treat a value as a specific type that you know it to be, even when TypeScript cannot verify it directly. Unlike type casting in other languages, assertions perform no runtime conversion.

**Basic syntax:**

```typescript
// Angle bracket syntax (not used in TSX files)
let someValue: any = "This is a string";
let strLength: number = (<string>someValue).length;

// as syntax (preferred and works in TSX files)
let someValue: any = "This is a string";
let strLength: number = (someValue as string).length;
```

**Practical use cases:**

1. Working with DOM elements:

```typescript
// Type assertion for DOM access
const input = document.getElementById('username') as HTMLInputElement;
// Now we can access .value property safely
const username = input.value;

// Without assertion, this would error:
// const username = document.getElementById('username').value;
```

2. Working with API responses:

```typescript
interface User {
  id: number;
  name: string;
  email: string;
}

async function fetchUser(id: number) {
  const response = await fetch(`/api/users/${id}`);
  const data = await response.json();
  // Assert the response shape
  return data as User;
}

// Now TypeScript knows the return includes all User properties
fetchUser(1).then(user => console.log(user.name));
```

3. Forcing type conversion when migrating JavaScript:

```typescript
interface Product {
  id: string;
  title: string;
  price: number;
}

// Legacy untyped data from an external source
const legacyData: any = {
  id: "prod-123",
  title: "Smartphone",
  price: "599.99" // Note: price is a string here
};

// Convert and fix types during assignment
const product: Product = {
  ...legacyData,
  price: parseFloat(legacyData.price as string)
};
```

**Type assertion constraints:**

In TypeScript 3.2+, type assertions are limited to either:

1. Asserting to `any` or `unknown`
2. Asserting to a supertype or subtype of the original type

```typescript
// This works - number is assignable to string | number
let value: string | number = "hello";
let numeric = value as number;

// This fails - boolean is neither a supertype nor a subtype of string | number
// let bool = value as boolean; // Error

// Two-step assertion through any (avoid when possible)
let bool = value as any as boolean; // Works but bypasses type safety
```

**The `unknown` type and assertions:**

`unknown` is the type-safe counterpart of `any`. Values of type `unknown` can't be used directly and require type assertions or narrowing:

```typescript
function processValue(val: unknown) {
  // Error: Object is of type 'unknown'
  // val.toFixed(2); 

  // After assertion, we can use number methods
  if (typeof val === 'number') {
    return val.toFixed(2);
  }
  
  // Or with assertion
  return (val as number).toFixed(2); // Unsafe if val is not a number
}
```

**Non-null assertion operator:**

The `!` postfix operator is a special assertion that removes `null` and `undefined` from a type:

```typescript
function processElement(id: string) {
  // The ! tells TypeScript that getElementById will not return null
  const element = document.getElementById(id)!;
  
  // Without !, we would need to check:
  // const element = document.getElementById(id);
  // if (element === null) throw new Error(`Element with id ${id} not found`);
  
  return element.textContent;
}
```

**Key points:**

- Type assertions don't change runtime values, only how TypeScript interprets them
- Use assertions sparingly as they bypass TypeScript's type checking
- Prefer type guards and proper typing over assertions when possible
- Always ensure the assertion is valid, as incorrect assertions can lead to runtime errors

### Type Guards

Type guards allow you to narrow down the type of an object within a conditional block. They create a scope where TypeScript knows that a variable has a more specific type.

**Built-in type guards:**

1. `typeof` type guard:

```typescript
function printValue(value: string | number) {
  if (typeof value === 'string') {
    // In this block, TypeScript knows 'value' is a string
    console.log(value.toUpperCase());
  } else {
    // In this block, TypeScript knows 'value' is a number
    console.log(value.toFixed(2));
  }
}
```

2. `instanceof` type guard:

```typescript
class Customer {
  name: string;
  email: string;
  constructor(name: string, email: string) {
    this.name = name;
    this.email = email;
  }
  
  sendEmail() {
    console.log(`Sending email to ${this.email}`);
  }
}

class Employee {
  name: string;
  department: string;
  constructor(name: string, department: string) {
    this.name = name;
    this.department = department;
  }
  
  assignTask(task: string) {
    console.log(`Assigning ${task} to ${this.name} in ${this.department}`);
  }
}

function processEntity(entity: Customer | Employee) {
  console.log(entity.name); // Common property, safe to access
  
  if (entity instanceof Customer) {
    // TypeScript knows entity is Customer here
    entity.sendEmail();
  } else {
    // TypeScript knows entity is Employee here
    entity.assignTask("Complete report");
  }
}
```

**Custom type guards:**

User-defined type predicates allow you to define your own type guard functions:

```typescript
interface Car {
  make: string;
  model: string;
  year: number;
}

interface Boat {
  manufacturer: string;
  type: string;
  year: number;
}

// Type predicate: returns boolean but tells TypeScript about type
function isCar(vehicle: Car | Boat): vehicle is Car {
  return 'make' in vehicle && 'model' in vehicle;
}

function getVehicleInfo(vehicle: Car | Boat) {
  if (isCar(vehicle)) {
    // TypeScript knows vehicle is Car here
    return `${vehicle.make} ${vehicle.model} (${vehicle.year})`;
  } else {
    // TypeScript knows vehicle is Boat here
    return `${vehicle.manufacturer} ${vehicle.type} (${vehicle.year})`;
  }
}
```

**Exhaustiveness checking:**

Type guards can be combined with never type for exhaustiveness checking:

```typescript
type Shape = Circle | Square | Triangle;

interface Circle {
  kind: 'circle';
  radius: number;
}

interface Square {
  kind: 'square';
  sideLength: number;
}

interface Triangle {
  kind: 'triangle';
  base: number;
  height: number;
}

function getArea(shape: Shape): number {
  switch (shape.kind) {
    case 'circle':
      return Math.PI * shape.radius ** 2;
    case 'square':
      return shape.sideLength ** 2;
    case 'triangle':
      return (shape.base * shape.height) / 2;
    default:
      // If someone adds a new shape without handling it,
      // this will cause a compile-time error
      const exhaustiveCheck: never = shape;
      return exhaustiveCheck;
  }
}
```

**Combining type guards:**

```typescript
type StringOrArray = string | any[];

function isNonEmptyStringOrArray(value: StringOrArray): boolean {
  if (typeof value === 'string') {
    return value.length > 0;
  } else if (Array.isArray(value)) {
    return value.length > 0;
  }
  return false;
}

function processNonEmpty(value: StringOrArray) {
  if (isNonEmptyStringOrArray(value)) {
    // Unfortunately, TypeScript still sees value as StringOrArray here,
    // because the function returns boolean, not a type predicate
    
    // To fix, we need a type predicate:
    if (typeof value === 'string') {
      console.log('Processing string:', value.toUpperCase());
    } else {
      console.log('Processing array with', value.length, 'items');
    }
  } else {
    console.log('Empty value, nothing to process');
  }
}
```

**Key points:**

- Type guards create a scope where TypeScript knows a value has a more specific type
- Built-in guards include `typeof`, `instanceof`, and `in`
- Custom type guards use type predicates with the `is` keyword
- Type guards are essential for safely working with union types
- They enable more precise type information without excessive type assertions

### Discriminated Unions

Discriminated unions (or tagged unions) are a pattern that combines singleton types, union types, and type guards to achieve complete type safety. They rely on a common property—the "discriminant"—to distinguish between union members.

**Basic structure:**

```typescript
// Each interface has a common 'type' property with different literal types
interface Square {
  type: 'square';
  sideLength: number;
}

interface Rectangle {
  type: 'rectangle';
  width: number;
  height: number;
}

interface Circle {
  type: 'circle';
  radius: number;
}

// Union of all shapes
type Shape = Square | Rectangle | Circle;

// Function that uses the discriminant to handle each type
function calculateArea(shape: Shape): number {
  switch (shape.type) {
    case 'square':
      // TypeScript knows shape is Square here
      return shape.sideLength ** 2;
    case 'rectangle':
      // TypeScript knows shape is Rectangle here
      return shape.width * shape.height;
    case 'circle':
      // TypeScript knows shape is Circle here
      return Math.PI * shape.radius ** 2;
  }
}
```

**Real-world example: Application state transitions**

```typescript
// Authentication states with discriminated union
interface NotAuthenticated {
  status: 'not-authenticated';
}

interface Authenticating {
  status: 'authenticating';
  message: string;
}

interface Authenticated {
  status: 'authenticated';
  user: {
    id: string;
    name: string;
    email: string;
  };
  token: string;
}

interface AuthenticationFailed {
  status: 'failed';
  error: string;
  retryCount: number;
}

type AuthState = NotAuthenticated | Authenticating | Authenticated | AuthenticationFailed;

// State handler function
function renderAuthUI(state: AuthState) {
  switch (state.status) {
    case 'not-authenticated':
      return renderLoginForm();
    case 'authenticating':
      return renderLoadingSpinner(state.message);
    case 'authenticated':
      return renderUserDashboard(state.user, state.token);
    case 'failed':
      return renderError(state.error, state.retryCount);
  }
}

// State transition function
function authReducer(state: AuthState, action: AuthAction): AuthState {
  switch (action.type) {
    case 'LOGIN_REQUEST':
      return { status: 'authenticating', message: 'Signing in...' };
    case 'LOGIN_SUCCESS':
      return { 
        status: 'authenticated', 
        user: action.payload.user, 
        token: action.payload.token 
      };
    case 'LOGIN_FAILURE':
      return { 
        status: 'failed', 
        error: action.payload.error, 
        retryCount: (state.status === 'failed' ? state.retryCount + 1 : 1)
      };
    case 'LOGOUT':
      return { status: 'not-authenticated' };
    default:
      return state;
  }
}

// Types for actions that trigger state transitions
type AuthAction = 
  | { type: 'LOGIN_REQUEST' }
  | { type: 'LOGIN_SUCCESS', payload: { user: Authenticated['user'], token: string } }
  | { type: 'LOGIN_FAILURE', payload: { error: string } }
  | { type: 'LOGOUT' };
```

**Nested discriminated unions:**

```typescript
// API response types using discriminated unions
interface SuccessResponse<T> {
  status: 'success';
  data: T;
}

interface ErrorResponse {
  status: 'error';
  error: {
    code: number;
    message: string;
    details?: unknown;
  };
}

interface LoadingResponse {
  status: 'loading';
}

type ApiResponse<T> = SuccessResponse<T> | ErrorResponse | LoadingResponse;

// Nested discriminated unions for user data
interface AdminUser {
  kind: 'admin';
  id: string;
  name: string;
  permissions: string[];
  accessLevel: number;
}

interface RegularUser {
  kind: 'regular';
  id: string;
  name: string;
  subscriptionTier: string;
}

interface GuestUser {
  kind: 'guest';
  sessionId: string;
  createdAt: Date;
}

type User = AdminUser | RegularUser | GuestUser;

// Processing nested discriminated unions
function handleUserResponse(response: ApiResponse<User>) {
  switch (response.status) {
    case 'loading':
      return showLoadingIndicator();
    
    case 'error':
      return showError(response.error.message, response.error.code);
    
    case 'success':
      // Now we can switch on the user type
      const user = response.data;
      switch (user.kind) {
        case 'admin':
          return renderAdminDashboard(user.id, user.permissions, user.accessLevel);
        
        case 'regular':
          return renderUserDashboard(user.id, user.subscriptionTier);
        
        case 'guest':
          return renderLimitedDashboard(user.sessionId);
      }
  }
}
```

**Discriminated unions with classes:**

```typescript
abstract class Payment {
  abstract readonly method: string;
  amount: number;
  
  constructor(amount: number) {
    this.amount = amount;
  }
  
  abstract process(): Promise<boolean>;
}

class CreditCardPayment extends Payment {
  readonly method = 'credit-card';
  cardNumber: string;
  expiryDate: string;
  
  constructor(amount: number, cardNumber: string, expiryDate: string) {
    super(amount);
    this.cardNumber = cardNumber;
    this.expiryDate = expiryDate;
  }
  
  async process(): Promise<boolean> {
    console.log(`Processing ${this.amount} via credit card ${this.cardNumber}`);
    return true;
  }
}

class PayPalPayment extends Payment {
  readonly method = 'paypal';
  email: string;
  
  constructor(amount: number, email: string) {
    super(amount);
    this.email = email;
  }
  
  async process(): Promise<boolean> {
    console.log(`Processing ${this.amount} via PayPal to ${this.email}`);
    return true;
  }
}

class BankTransferPayment extends Payment {
  readonly method = 'bank-transfer';
  accountNumber: string;
  bankCode: string;
  
  constructor(amount: number, accountNumber: string, bankCode: string) {
    super(amount);
    this.accountNumber = accountNumber;
    this.bankCode = bankCode;
  }
  
  async process(): Promise<boolean> {
    console.log(`Processing ${this.amount} via bank transfer to ${this.accountNumber}`);
    return true;
  }
}

// Using the discriminated union
function processPayment(payment: Payment) {
  switch (payment.method) {
    case 'credit-card':
      // TypeScript knows this is CreditCardPayment
      console.log(`Using credit card ending with ${(payment as CreditCardPayment).cardNumber.slice(-4)}`);
      break;
    case 'paypal':
      // TypeScript knows this is PayPalPayment
      console.log(`Using PayPal account: ${(payment as PayPalPayment).email}`);
      break;
    case 'bank-transfer':
      // TypeScript knows this is BankTransferPayment
      console.log(`Using bank account: ${(payment as BankTransferPayment).accountNumber}`);
      break;
  }
  
  return payment.process();
}
```

**Key points:**

- Discriminated unions provide compile-time safety for handling different object types
- The discriminant property should be a literal type (string, number, boolean)
- They enable exhaustiveness checking to ensure all cases are handled
- They work well with switch statements for pattern matching
- They're particularly useful for state management, API responses, and domain modeling

### Index Types

Index types allow you to work with the properties of an object in a type-safe way. They provide mechanisms for describing objects with dynamic property names while maintaining type safety.

**Index signatures:**

Index signatures define the types of properties that can be accessed with a bracket notation:

```typescript
// Object can have any number of string keys with string values
interface StringDictionary {
  [key: string]: string;
}

const colors: StringDictionary = {
  primary: "#0070f3",
  secondary: "#ff4081",
  warning: "#ffeb3b"
};

// This works
colors.primary = "#0077ff";
colors["custom"] = "#00ff00";

// This would error - value must be string
// colors.error = 123;
```

You can combine index signatures with specific properties:

```typescript
interface EmployeeMap {
  [id: string]: {
    name: string;
    department: string;
  };
  // You can add specific known properties:
  adminId: string; // This is a required property
}

const employees: EmployeeMap = {
  adminId: "admin-007",
  "emp-123": { name: "Alice", department: "Engineering" },
  "emp-456": { name: "Bob", department: "Marketing" }
};
```

**Keyof operator:**

The `keyof` operator creates a union type of all property names in a type:

```typescript
interface User {
  id: number;
  name: string;
  email: string;
  role: 'admin' | 'user';
}

// Keys will be "id" | "name" | "email" | "role"
type UserKeys = keyof User;

// Function that can access any property of User
function getProperty(user: User, key: keyof User) {
  return user[key];
}

const user: User = { 
  id: 1, 
  name: "John Doe", 
  email: "john@example.com", 
  role: "admin" 
};

// Type-safe property access
const name = getProperty(user, "name");  // string
const id = getProperty(user, "id");      // number
// This would error - "age" is not a property of User
// const age = getProperty(user, "age");
```

**Generic keyof with index types:**

We can make the previous example more generic and type-safe:

```typescript
function getProperty<T, K extends keyof T>(obj: T, key: K): T[K] {
  return obj[key];
}

// Now TypeScript knows the exact return type for each key
const name = getProperty(user, "name");  // TypeScript knows it's string
const id = getProperty(user, "id");      // TypeScript knows it's number
const role = getProperty(user, "role");  // TypeScript knows it's 'admin' | 'user'
```

**Index types for object transformation:**

```typescript
interface Product {
  id: string;
  name: string;
  price: number;
  category: string;
}

// Convert all properties to optional
type PartialProduct = { [K in keyof Product]?: Product[K] };

// Create a type with only specified properties
type ProductSummary = { [K in 'id' | 'name']: Product[K] };

// Create a type with read-only properties
type ReadonlyProduct = { readonly [K in keyof Product]: Product[K] };

// Creating a function that transforms objects
function transformObject<T, U>(
  obj: T,
  transformer: <K extends keyof T>(key: K, value: T[K]) => U
): { [K in keyof T]: U } {
  const result = {} as { [K in keyof T]: U };
  
  for (const key in obj) {
    if (Object.prototype.hasOwnProperty.call(obj, key)) {
      result[key] = transformer(key as keyof T, obj[key as keyof T]);
    }
  }
  
  return result;
}

// Example transformer - convert all numbers to strings and double string length
const product: Product = {
  id: "p123",
  name: "Laptop",
  price: 1299,
  category: "Electronics"
};

const transformed = transformObject(product, (key, value) => {
  if (typeof value === 'number') {
    return String(value);
  } else if (typeof value === 'string') {
    return value + value;
  }
  return value;
});

// transformed has all properties as strings
// { id: "p123p123", name: "LaptopLaptop", price: "1299", category: "ElectronicsElectronics" }
```

**Record utility type:**

TypeScript provides a `Record<K, T>` utility type that creates a type with keys of type `K` and values of type `T`:

```typescript
// Create a type with string keys and value of type User
type UserDirectory = Record<string, User>;

// Create a type with specific keys and values
type RolePermissions = Record<'admin' | 'user' | 'guest', string[]>;

// Implement the permissions lookup
const permissions: RolePermissions = {
  admin: ['read', 'write', 'delete', 'manage-users'],
  user: ['read', 'write'],
  guest: ['read']
};
```

**Key points:**

- Index signatures allow objects with dynamic property names
- The `keyof` operator creates a union of property names as literal types
- Indexed access types (`T[K]`) retrieve the type of a property
- These features enable highly generic, reusable functions with proper type safety
- They're essential for type-safe manipulation and transformation of objects

### Mapped Types

Mapped types allow you to create new types based on existing ones by transforming properties. They're a powerful way to derive related types without duplicating type definitions.

**Basic syntax:**

```typescript
type Mapped<T> = {
  [P in keyof T]: T[P];
};
```

**Making properties optional:**

```typescript
// Make all properties optional
type Partial<T> = {
  [P in keyof T]?: T[P];
};

interface Product {
  id: string;
  name: string;
  price: number;
  inStock: boolean;
}

// ProductUpdate has all properties optional
type ProductUpdate = Partial<Product>;

function updateProduct(id: string, updates: ProductUpdate) {
  // Implementation
}

// Valid call - can update just some properties
updateProduct("prod-123", { price: 129.99 });
```

**Making properties readonly:**

```typescript
// Make all properties readonly
type Readonly<T> = {
  readonly [P in keyof T]: T[P];
};

// ReadonlyProduct has all properties readonly
type ReadonlyProduct = Readonly<Product>;

const product: ReadonlyProduct = {
  id: "prod-123",
  name: "Smartphone",
  price: 599,
  inStock: true
};

// This would error - can't modify readonly properties
// product.price = 499;
```

**Changing property types:**

```typescript
// Convert all properties to string type
type StringifyProps<T> = {
  [P in keyof T]: string;
};

// All properties are now string type
type ProductStrings = StringifyProps<Product>;

// For debugging or display purposes
function getDisplayObject(product: Product): ProductStrings {
  return {
    id: product.id,
    name: product.name,
    price: `$${product.price.toFixed(2)}`,
    inStock: product.inStock ? "Yes" : "No"
  };
}
```

**Filtering properties by type:**

```typescript
// Pick only properties of certain type
type PickByType<T, ValueType> = {
  [P in keyof T as T[P] extends ValueType ? P : never]: T[P]
};

// Only includes numeric properties
type NumericProps = PickByType<Product, number>;
// Equivalent to: { price: number }

// Only includes string properties
type StringProps = PickByType<Product, string>;
// Equivalent to: { id: string, name: string }
```

**Removing properties:**

```typescript
// Omit properties from a type
type Omit<T, K extends keyof T> = {
  [P in keyof T as P extends K ? never : P]: T[P]
};

// Product without id and price
type ProductSummary = Omit<Product, 'id' | 'price'>;
// Equivalent to: { name: string, inStock: boolean }
```

**Conditional property mapping:**

```typescript
// Make properties of type T nullable
type Nullable<T> = {
  [P in keyof T]: T[P] | null;
};

// Add validation flags to an interface
type WithValidation<T> = {
  [P in keyof T]: {
    value: T[P];
    isValid: boolean;
    errorMessage?: string;
  };
};

// Form state with validation
type ProductForm = WithValidation<Product>;

const formState: ProductForm = {
  id: { value: "prod-123", isValid: true },
  name: { value: "", isValid: false, errorMessage: "Name is required" },
  price: { value: 0, isValid: false, errorMessage: "Price must be greater than 0" },
  inStock: { value: true, isValid: true }
};
```

**Combining with template literal types:**

```typescript
// Create getters for all properties
type Getters<T> = {
  [P in keyof T as `get${Capitalize<string & P>}`]: () => T[P]
};

// Create setters for all properties
type Setters<T> = {
  [P in keyof T as `set${Capitalize<string & P>}`]: (value: T[P]) => void
};

// Combine both getters and setters
type Accessors<T> = Getters<T> & Setters<T>;

// Usage
interface Person {
  name: string;
  age: number;
  isActive: boolean;
}

// PersonAccessors will have getName, setName, getAge, setAge, etc.
type PersonAccessors = Accessors<Person>;

class PersonImpl implements Person {
  name: string;
  age: number;
  isActive: boolean;
  
  constructor(name: string, age: number, isActive: boolean = true) {
    this.name = name;
    this.age = age;
    this.isActive = isActive;
  }
  
  // Implement accessors
  getName(): string {
    return this.name;
  }
  
  setName(value: string): void {
    this.name = value;
  }
  
  getAge(): number {
    return this.age;
  }
  
  setAge(value: number): void {
    this.age = value;
  }
  
  getIsActive(): boolean {
    return this.isActive;
  }
  
  setIsActive(value: boolean): void {
    this.isActive = value;
  }
}
```

**Real-world example: API state management:**

```typescript
// API state types
type ApiState<T> = {
  data: T | null;
  loading: boolean;
  error: string | null;
};

// Create API states for all entity types
interface Entities {
  user: User;
  product: Product;
  order: Order;
}

// Create API states for each entity
type ApiStates = {
  [K in keyof Entities as `${string & K}State`]: ApiState<Entities[K]>
};

// Equivalent to:
// {
//   userState: ApiState<User>;
//   productState: ApiState<Product>;
//   orderState: ApiState<Order>;
// }

// Function to create initial state
function createInitialState<T>(): ApiState<T> {
  return {
    data: null,
    loading: false,
    error: null
  };
}

// Usage:
const appState: ApiStates = {
  userState: createInitialState<User>(),
  productState: createInitialState<Product>(),
  orderState: createInitialState<Order>()
};

// Update state function with mapped type
function updateState<K extends keyof ApiStates>(
  state: ApiStates,
  key: K,
  updates: Partial<ApiStates[K]>
): ApiStates {
  return {
    ...state,
    [key]: {
      ...state[key],
      ...updates
    }
  };
}

// Usage
const newState = updateState(appState, 'userState', { 
  loading: true,
  error: null
});
```

**Built-in mapped types:**

TypeScript provides several built-in mapped types:

1. `Partial<T>` - Makes all properties optional
2. `Required<T>` - Makes all properties required
3. `Readonly<T>` - Makes all properties readonly
4. `Record<K, T>` - Creates type with keys from K and values of type T
5. `Pick<T, K>` - Takes only specified properties from T
6. `Omit<T, K>` - Removes specified properties from T
7. `Exclude<T, U>` - Excludes types from T that are assignable to U
8. `Extract<T, U>` - Extracts types from T that are assignable to U
9. `NonNullable<T>` - Removes null and undefined from T
10. `Parameters<T>` - Extracts parameter types from function type T
11. `ReturnType<T>` - Extracts return type from function type T
12. `InstanceType<T>` - Extracts instance type from constructor function type T

```typescript
// Examples of built-in mapped types

// Partial - all properties optional
type PartialProduct = Partial<Product>;
// { id?: string, name?: string, price?: number, inStock?: boolean }

// Required - makes all properties required
interface ConfigOptions {
  theme?: string;
  timeout?: number;
  retries?: number;
}
type RequiredConfig = Required<ConfigOptions>;
// { theme: string, timeout: number, retries: number }

// Pick - takes only specific properties
type ProductPreview = Pick<Product, 'name' | 'price'>;
// { name: string, price: number }

// Record - creates type with specific keys and values
type CategoryProducts = Record<'electronics' | 'clothing' | 'books', Product[]>;
// { electronics: Product[], clothing: Product[], books: Product[] }

// ReturnType - extracts function return type
function createUser(name: string, email: string) {
  return { id: Date.now(), name, email, createdAt: new Date() };
}
type User = ReturnType<typeof createUser>;
// { id: number, name: string, email: string, createdAt: Date }
```

**Key points:**

- Mapped types create new types by transforming existing ones
- They're powerful for creating related types (partial, readonly, etc.)
- The `as` clause allows renaming properties
- Combine with conditional types for complex transformations
- Mapped types often use keyof, indexed access types, and conditional types
- Built-in mapped types handle common transformations

### Practical Advanced Type Examples

**Type-safe event system:**

```typescript
// Event definitions
interface EventMap {
  'user:login': { userId: string; timestamp: number };
  'user:logout': { userId: string; timestamp: number };
  'item:added': { itemId: string; quantity: number };
  'payment:completed': { orderId: string; amount: number };
}

// Type-safe event emitter
class EventEmitter<Events extends Record<string, any>> {
  private listeners: {
    [E in keyof Events]?: Array<(data: Events[E]) => void>;
  } = {};
  
  public on<E
```

---

## Utility Types

### Partial, Required, Readonly

**Key Points**

- `Partial<T>` makes all properties of type T optional
- `Required<T>` makes all properties of type T required
- `Readonly<T>` makes all properties of type T read-only
- These utilities are non-destructive transformations of existing types

TypeScript's built-in utility types help transform existing types in common ways without manually redefining them:

```typescript
// Original interface
interface User {
  id: number;
  name: string;
  email: string;
  age: number;
  isActive: boolean;
}

// Partial<T> - Makes all properties optional
type PartialUser = Partial<User>;
// Equivalent to:
// {
//   id?: number;
//   name?: string;
//   email?: string;
//   age?: number;
//   isActive?: boolean;
// }

// Perfect for update functions where only some fields might change
function updateUser(userId: number, updates: Partial<User>) {
  // Implementation that updates only the provided fields
}

// Usage with only fields that need updating
updateUser(123, { name: "New Name", isActive: false });
```

The `Required<T>` utility makes all properties non-optional:

```typescript
// Starting with a type that has optional properties
interface ConfigOptions {
  endpoint?: string;
  timeout?: number;
  retries?: number;
  headers?: Record<string, string>;
}

// Required<T> - Makes all properties required
type StrictConfig = Required<ConfigOptions>;
// Equivalent to:
// {
//   endpoint: string;
//   timeout: number;
//   retries: number;
//   headers: Record<string, string>;
// }

// This would cause an error if any properties are missing
const fullConfig: StrictConfig = {
  endpoint: "https://api.example.com",
  timeout: 3000,
  retries: 3,
  headers: { "Content-Type": "application/json" }
};
```

The `Readonly<T>` utility prevents properties from being changed after initialization:

```typescript
// Readonly<T> - Makes all properties read-only
type ReadonlyUser = Readonly<User>;
// Equivalent to:
// {
//   readonly id: number;
//   readonly name: string;
//   readonly email: string;
//   readonly age: number;
//   readonly isActive: boolean;
// }

const user: ReadonlyUser = {
  id: 1,
  name: "John",
  email: "john@example.com",
  age: 30,
  isActive: true
};

// These would all cause compilation errors:
// user.name = "Jane"; // Error: Cannot assign to 'name' because it is a read-only property
// user.age = 31;      // Error: Cannot assign to 'age' because it is a read-only property

// For creating truly immutable objects, use Readonly on nested objects too
interface NestedObject {
  info: {
    data: number[];
  };
}

type DeepReadonly<T> = {
  readonly [K in keyof T]: T[K] extends object ? DeepReadonly<T[K]> : T[K];
};

const immutable: DeepReadonly<NestedObject> = {
  info: {
    data: [1, 2, 3]
  }
};

// These would all cause errors:
// immutable.info = { data: [] };       // Error
// immutable.info.data = [];            // Error
// immutable.info.data.push(4);         // Error
```

### Record, Pick, Omit

**Key Points**

- `Record<K, T>` creates an object type with keys of type K and values of type T
- `Pick<T, K>` creates a type by picking a set of properties K from type T
- `Omit<T, K>` creates a type by omitting a set of properties K from type T
- These utilities help create new types based on existing ones

The `Record<K, T>` utility creates an object type with specified keys and value types:

```typescript
// Record<K, T> - Object type with keys of type K and values of type T
type StringMap = Record<string, string>;
// Equivalent to: { [key: string]: string }

const headers: StringMap = {
  "Content-Type": "application/json",
  "Authorization": "Bearer token123"
};

// With literal types for keys
type UserRoles = Record<"admin" | "editor" | "viewer", boolean>;
// Equivalent to: { admin: boolean; editor: boolean; viewer: boolean; }

const permissions: UserRoles = {
  admin: true,
  editor: false,
  viewer: true
};

// With numeric keys
type YearData = Record<number, { events: string[] }>;
// Equivalent to: { [key: number]: { events: string[] } }

const historicalEvents: YearData = {
  2020: { events: ["Pandemic", "Elections"] },
  2021: { events: ["Vaccine Rollout"] }
};
```

The `Pick<T, K>` utility creates a new type by selecting specific properties:

```typescript
interface Article {
  id: number;
  title: string;
  content: string;
  author: string;
  comments: Comment[];
  createdAt: Date;
  updatedAt: Date;
  tags: string[];
  isPublished: boolean;
}

// Pick<T, K> - Select only certain properties
type ArticlePreview = Pick<Article, "id" | "title" | "author" | "tags">;
// Equivalent to:
// {
//   id: number;
//   title: string;
//   author: string;
//   tags: string[];
// }

// Useful for creating summarized versions of larger types
const preview: ArticlePreview = {
  id: 123,
  title: "Understanding TypeScript Utility Types",
  author: "TypeScript Expert",
  tags: ["typescript", "programming", "utility-types"]
};

// Great for function parameters when you only need certain properties
function renderArticleList(articles: Pick<Article, "id" | "title" | "author">[]) {
  // Implementation that only uses these properties
}
```

The `Omit<T, K>` utility creates a new type by excluding specific properties:

```typescript
// Omit<T, K> - Create a type excluding certain properties
type ArticleContent = Omit<Article, "comments" | "createdAt" | "updatedAt">;
// Includes all Article properties EXCEPT comments, createdAt, and updatedAt

// Useful for creating new types without unwanted properties
type UserWithoutSensitiveInfo = Omit<User, "password" | "securityQuestions">;

// Creating a new type based on an existing one with different property types
interface BaseEntity {
  id: number;
  createdAt: Date;
  updatedAt: Date;
}

// Extending a type but replacing some properties
type Product = Omit<BaseEntity, "id"> & {
  id: string;  // Replace number id with string id
  name: string;
  price: number;
};

const product: Product = {
  id: "PROD-123",
  name: "Laptop",
  price: 999.99,
  createdAt: new Date(),
  updatedAt: new Date()
};
```

### Extract, Exclude

**Key Points**

- `Extract<T, U>` extracts from T types that are assignable to U
- `Exclude<T, U>` excludes from T types that are assignable to U
- Both operate on union types rather than object properties
- Useful for filtering union types

The `Extract<T, U>` utility extracts types from a union that are assignable to another type:

```typescript
// Union type with various types
type ResponseTypes = string | number | boolean | null | undefined | object;

// Extract<T, U> - Extract types from T that are assignable to U
type PrimitiveResponses = Extract<ResponseTypes, string | number | boolean>;
// Result: string | number | boolean

// With literal types
type Status = "pending" | "processing" | "success" | "error" | 404 | 500;
type StringStatus = Extract<Status, string>;
// Result: "pending" | "processing" | "success" | "error"
type NumberStatus = Extract<Status, number>;
// Result: 404 | 500

// With more complex types
type Shape = 
  | { kind: "circle"; radius: number }
  | { kind: "square"; size: number }
  | { kind: "rectangle"; width: number; height: number };

type RoundedShape = Extract<Shape, { kind: "circle" }>;
// Result: { kind: "circle"; radius: number }
```

The `Exclude<T, U>` utility removes types from a union:

```typescript
// Exclude<T, U> - Remove types from T that are assignable to U
type NonPrimitiveResponses = Exclude<ResponseTypes, string | number | boolean>;
// Result: null | undefined | object

// With literal types
type NonErrorStatus = Exclude<Status, "error" | 404 | 500>;
// Result: "pending" | "processing" | "success"

// Creating a type without certain variants
type NonCircleShapes = Exclude<Shape, { kind: "circle" }>;
// Result: { kind: "square"; size: number } | { kind: "rectangle"; width: number; height: number }

// Common use case: Removing null and undefined
type NonNullableResponses = Exclude<ResponseTypes, null | undefined>;
// Result: string | number | boolean | object

// This is so common that TypeScript provides a built-in utility for it:
type NonNullable<T> = Exclude<T, null | undefined>;
```

Practical examples combining Extract and Exclude:

```typescript
// HTTP methods as a union type
type HttpMethod = "GET" | "POST" | "PUT" | "PATCH" | "DELETE" | "HEAD" | "OPTIONS";

// Safe methods that don't modify data
type SafeHttpMethod = Extract<HttpMethod, "GET" | "HEAD" | "OPTIONS">;
// Result: "GET" | "HEAD" | "OPTIONS"

// Methods that can modify data
type ModifyingHttpMethod = Exclude<HttpMethod, SafeHttpMethod>;
// Result: "POST" | "PUT" | "PATCH" | "DELETE"

// Another example with API endpoints
type ApiEndpoint = 
  | { path: "/users"; method: "GET" }
  | { path: "/users"; method: "POST" }
  | { path: "/users/:id"; method: "GET" }
  | { path: "/users/:id"; method: "PUT" }
  | { path: "/users/:id"; method: "DELETE" };

// Extracting only endpoints that operate on a specific user
type SingleUserEndpoints = Extract<ApiEndpoint, { path: "/users/:id" }>;
// Result: The three endpoints with path "/users/:id"
```

### ReturnType, Parameters

**Key Points**

- `ReturnType<T>` extracts the return type of a function type
- `Parameters<T>` extracts the parameter types of a function type as a tuple
- These utilities help when working with functions as types
- Useful for type-safe callbacks and function compositions

The `ReturnType<T>` utility extracts the return type of a function:

```typescript
// Basic function
function createUser(name: string, age: number) {
  return { id: Date.now(), name, age, createdAt: new Date() };
}

// ReturnType<T> - Extract the return type of a function
type User = ReturnType<typeof createUser>;
// Equivalent to:
// {
//   id: number;
//   name: string;
//   age: number;
//   createdAt: Date;
// }

// Works with function type definitions
type FetchUserFn = (id: number) => Promise<User>;
type FetchResult = ReturnType<FetchUserFn>;
// Result: Promise<User>

// Unwrapping async function return types
type AsyncReturnType<T extends (...args: any) => Promise<any>> = 
  T extends (...args: any) => Promise<infer R> ? R : any;

type UserData = AsyncReturnType<FetchUserFn>;
// Result: User (unwrapped from Promise)

// With generic function types
function identity<T>(value: T): T {
  return value;
}

// Not very useful with generic functions unless you specify the type parameters
type IdentityReturnType = ReturnType<typeof identity>;  // unknown
```

The `Parameters<T>` utility extracts parameter types as a tuple:

```typescript
// Parameters<T> - Extract parameter types as a tuple
type CreateUserParams = Parameters<typeof createUser>;
// Result: [string, number]

// Accessing specific parameter types by index
type NameParamType = CreateUserParams[0];  // string
type AgeParamType = CreateUserParams[1];   // number

// Practical use case: creating type-safe mock functions
function mockFunction<T extends (...args: any[]) => any>(
  implementation: (...args: Parameters<T>) => ReturnType<T>
): T {
  return implementation as T;
}

// Function with complex parameters
function processConfig(
  options: { debug: boolean; timeout: number },
  callback: (error: Error | null, result?: any) => void
) {
  // Implementation
}

// Extract complex parameter types
type ConfigOptions = Parameters<typeof processConfig>[0];
// Result: { debug: boolean; timeout: number }

type CallbackType = Parameters<typeof processConfig>[1];
// Result: (error: Error | null, result?: any) => void
```

Combining these utilities for advanced type manipulations:

```typescript
// Using ReturnType and Parameters together
function createHandler<T extends (...args: any[]) => any>(
  handler: T,
  beforeEach: (...args: Parameters<T>) => void,
  afterEach: (result: ReturnType<T>) => void
) {
  return (...args: Parameters<T>): ReturnType<T> => {
    beforeEach(...args);
    const result = handler(...args);
    afterEach(result);
    return result;
  };
}

// Function constructor parameter types
type ConstructorParameters<T extends new (...args: any[]) => any> = 
  T extends new (...args: infer P) => any ? P : never;

class User {
  constructor(public name: string, public age: number) {}
}

type UserConstructorParams = ConstructorParameters<typeof User>;
// Result: [string, number]
```

### Creating Custom Utility Types

**Key Points**

- Custom utility types use TypeScript's built-in type operators
- Mapped types modify properties of existing types
- Conditional types create type logic with the `extends` keyword
- Template literal types transform string types

TypeScript enables creating custom utility types for project-specific needs:

```typescript
// Basic NonNullable custom implementation
type MyNonNullable<T> = T extends null | undefined ? never : T;

// DeepPartial - makes all properties and nested properties optional
type DeepPartial<T> = T extends object
  ? { [P in keyof T]?: DeepPartial<T[P]> }
  : T;

interface NestedConfig {
  server: {
    port: number;
    host: string;
    ssl: {
      enabled: boolean;
      cert: string;
      key: string;
    };
  };
  database: {
    url: string;
    credentials: {
      username: string;
      password: string;
    };
  };
}

// With DeepPartial, all nested properties become optional
const partialConfig: DeepPartial<NestedConfig> = {
  server: {
    port: 8080,
    // host is optional
    ssl: {
      // All SSL properties are optional
      enabled: true
    }
  }
  // database is optional
};
```

Creating a Nullable utility type:

```typescript
// Nullable - makes all properties nullable
type Nullable<T> = { [P in keyof T]: T[P] | null };

interface User {
  id: number;
  name: string;
  email: string;
}

// All properties can be null
const partialLoadedUser: Nullable<User> = {
  id: 1,
  name: null,  // Still loading
  email: "user@example.com"
};
```

A utility to create a discriminated union from object types:

```typescript
// WithKind - adds a 'kind' discriminator to an object type
type WithKind<K extends string, T> = T & { kind: K };

interface Circle {
  radius: number;
}

interface Square {
  size: number;
}

// Create discriminated union with the WithKind utility
type Shape = 
  | WithKind<"circle", Circle>
  | WithKind<"square", Square>;

// Usage:
const circle: Shape = {
  kind: "circle",
  radius: 10
};
```

Utilities for function types:

```typescript
// Awaited - unwraps Promise types (simplified version of built-in)
type MyAwaited<T> = T extends Promise<infer R>
  ? R extends Promise<any> ? MyAwaited<R> : R
  : T;

// Function type that adds logging before and after execution
type WithLogging<T extends Function> = 
  T extends (...args: infer P) => infer R
    ? (...args: P) => R
    : never;

function addLogging<T extends Function>(fn: T): WithLogging<T> {
  return ((...args: any[]) => {
    console.log(`Calling with args:`, args);
    const result = fn(...args);
    console.log(`Result:`, result);
    return result;
  }) as WithLogging<T>;
}
```

Property selection utilities:

```typescript
// FilterProperties - select properties of a specific type
type FilterProperties<T, U> = {
  [K in keyof T as T[K] extends U ? K : never]: T[K]
};

interface Form {
  name: string;
  email: string;
  age: number;
  isSubscribed: boolean;
  submit: () => void;
  reset: () => void;
}

// Extract only string properties
type StringProps = FilterProperties<Form, string>;
// Result: { name: string; email: string; }

// Extract only function properties
type Methods = FilterProperties<Form, Function>;
// Result: { submit: () => void; reset: () => void; }

// RenameProperty - rename a single property
type RenameProperty<T, K extends keyof T, N extends string> = 
  Omit<T, K> & { [P in N]: T[K] };

// Usage:
type UserWithHandle = RenameProperty<User, "name", "handle">;
// Result: { id: number; handle: string; email: string; }
```

Template literal types for advanced string manipulation:

```typescript
// Prefix all properties with a string
type Prefixed<P extends string, T> = {
  [K in keyof T as `${P}${string & K}`]: T[K]
};

// Usage:
type PrefixedUser = Prefixed<"user", User>;
// Result: { userId: number; userName: string; userEmail: string; }

// Create event handler property names
type EventHandlers<T extends string> = {
  [K in T as `on${Capitalize<K>}`]: (event: any) => void
};

// Usage:
type UIEvents = EventHandlers<"click" | "hover" | "focus">;
// Result: { onClick: (event: any) => void; onHover: (event: any) => void; onFocus: (event: any) => void; }
```

Combining multiple utilities for complex transformations:

```typescript
// MakeOptionalProperties - make specific properties optional
type MakeOptional<T, K extends keyof T> = 
  Omit<T, K> & Partial<Pick<T, K>>;

// Usage:
type UserWithOptionalEmail = MakeOptional<User, "email">;
// Result: { id: number; name: string; email?: string; }

// ReadonlyDeep - make all properties readonly recursively
type ReadonlyDeep<T> = {
  readonly [P in keyof T]: T[P] extends object
    ? ReadonlyDeep<T[P]>
    : T[P]
};

// Usage:
const frozenConfig: ReadonlyDeep<NestedConfig> = {
  // All properties and nested properties are readonly
};
```

**Conclusion**

TypeScript's utility types provide powerful ways to transform and manipulate existing types without duplicating type definitions. The built-in utilities like `Partial<T>`, `Required<T>`, `Readonly<T>`, `Record<K, T>`, `Pick<T, K>`, `Omit<T, K>`, `Extract<T, U>`, `Exclude<T, U>`, `ReturnType<T>`, and `Parameters<T>` cover the most common type transformations.

Creating custom utility types extends TypeScript's type system even further, enabling project-specific type manipulations through mapped types, conditional types, and template literal types. These utilities help maintain type safety while reducing code duplication and increasing the expressiveness of your type definitions.

When used effectively, utility types make TypeScript code more maintainable, eliminate common sources of bugs, and provide better developer experiences through enhanced type checking and IDE support. They form an essential part of advanced TypeScript development, allowing for precisely tailored types that evolve with your application needs.

---

# Modules and Namespaces

## TypeScript Modules

### Introduction to TypeScript Modules

TypeScript modules provide a way to organize code by splitting it into separate files, each exporting declarations that can be imported by other modules. TypeScript fully supports the ES Modules standard, while also maintaining compatibility with CommonJS and other module systems. This modular approach helps manage complex applications by promoting code reusability, encapsulation, and maintainability.

### Import and Export Syntax

TypeScript offers a variety of ways to import and export code between modules, giving you flexibility in how you structure your application.

**Basic Exports**

```typescript
// math.ts
export const PI = 3.14159;

export function add(a: number, b: number): number {
  return a + b;
}

export function subtract(a: number, b: number): number {
  return a - b;
}

export class Calculator {
  multiply(a: number, b: number): number {
    return a * b;
  }
}
```

**Basic Imports**

```typescript
// app.ts
import { PI, add, subtract, Calculator } from './math';

console.log(PI);  // 3.14159
console.log(add(1, 2));  // 3

const calc = new Calculator();
console.log(calc.multiply(2, 3));  // 6
```

**Namespace Imports**

```typescript
// app.ts
import * as Math from './math';

console.log(Math.PI);  // 3.14159
console.log(Math.add(1, 2));  // 3

const calc = new Math.Calculator();
console.log(calc.multiply(2, 3));  // 6
```

**Re-exports**

```typescript
// index.ts
export { add, subtract } from './math';
export { default as Logger } from './logger';

// This makes the index.ts file act as a "barrel" export
```

**Export Statements**

```typescript
// user.ts
function validateEmail(email: string): boolean {
  const re = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return re.test(email);
}

class User {
  constructor(public name: string, public email: string) {}
  
  isValidEmail(): boolean {
    return validateEmail(this.email);
  }
}

// Export list
export { User, validateEmail };
```

**Export with Renaming**

```typescript
// utils.ts
function formatDate(date: Date): string {
  return date.toISOString().split('T')[0];
}

// Export with a different name
export { formatDate as formatDateISOString };

// Import with a different name
import { formatDateISOString as formatDate } from './utils';
```

### Default and Named Exports

TypeScript supports both default exports and named exports, giving you options for how modules expose their functionality.

**Default Exports**

Each module can have one default export, which is often used for the main class, function, or object that the module provides:

```typescript
// logger.ts
export default class Logger {
  log(message: string): void {
    console.log(`[LOG]: ${message}`);
  }
  
  error(message: string): void {
    console.error(`[ERROR]: ${message}`);
  }
}

// Alternatively, declare first then export
class Logger {
  // ... same as above
}

export default Logger;
```

**Importing Default Exports**

```typescript
// app.ts
import Logger from './logger';

const logger = new Logger();
logger.log('Application started');
```

**Combining Default and Named Exports**

```typescript
// api.ts
export const API_URL = 'https://api.example.com';

export function get(endpoint: string): Promise<any> {
  return fetch(`${API_URL}/${endpoint}`).then(res => res.json());
}

// Default export
export default class ApiClient {
  baseUrl: string;
  
  constructor(baseUrl: string = API_URL) {
    this.baseUrl = baseUrl;
  }
  
  async request(endpoint: string): Promise<any> {
    return fetch(`${this.baseUrl}/${endpoint}`).then(res => res.json());
  }
}
```

**Importing Both Default and Named Exports**

```typescript
// app.ts
import ApiClient, { API_URL, get } from './api';

console.log(API_URL);  // https://api.example.com
get('users').then(users => console.log(users));

const client = new ApiClient();
client.request('posts').then(posts => console.log(posts));
```

**Type-Only Imports and Exports**

TypeScript 3.8+ allows you to import and export types explicitly, which helps with tree-shaking and avoiding runtime dependencies:

```typescript
// types.ts
export interface User {
  id: number;
  name: string;
  email: string;
}

export type UserRole = 'admin' | 'user' | 'guest';

// app.ts
import type { User, UserRole } from './types';

const currentUser: User = {
  id: 1,
  name: 'John',
  email: 'john@example.com'
};

const role: UserRole = 'admin';
```

### Module Resolution Strategies

TypeScript offers multiple strategies for resolving module imports, which determine how the compiler looks for imported modules.

**Classic Resolution**

The original TypeScript resolution strategy that mimics how Node.js resolves modules:

```json
// tsconfig.json
{
  "compilerOptions": {
    "moduleResolution": "Classic"
  }
}
```

**Node Resolution**

The recommended strategy that replicates Node.js module resolution behavior:

```json
// tsconfig.json
{
  "compilerOptions": {
    "moduleResolution": "Node"
  }
}
```

With Node resolution, TypeScript will search for modules in the following order:

1. Look for a `.ts`, `.tsx`, or `.d.ts` file with the exact name
2. Look for an `index.ts`, `index.tsx`, or `index.d.ts` in a directory with the name
3. Look for a `package.json` with a `types` or `typings` field
4. Look for a `package.json` with a `main` field

**Node16/NodeNext Resolution**

For projects using Node.js's ESM support:

```json
// tsconfig.json
{
  "compilerOptions": {
    "module": "NodeNext",
    "moduleResolution": "NodeNext"
  }
}
```

This mode adds support for:

- Package exports and imports
- Import assertions
- Detection of whether `.js` files are CommonJS or ESM based on package.json

**Bundler Resolution**

Introduced in TypeScript 5.0 for bundlers like Webpack, Vite, esbuild, etc.:

```json
// tsconfig.json
{
  "compilerOptions": {
    "moduleResolution": "Bundler"
  }
}
```

This strategy helps TypeScript understand bundler-specific behaviors and optimizations.

**Module Resolution Examples**

Consider this import statement:

```typescript
import { something } from './utils';
```

With Node resolution, TypeScript will look for:

1. `./utils.ts`
2. `./utils.tsx`
3. `./utils.d.ts`
4. `./utils/index.ts`
5. `./utils/index.tsx`
6. `./utils/index.d.ts`
7. `./utils/package.json` (`types` or `main` field)

**Non-Relative Imports**

For non-relative imports like:

```typescript
import { useState } from 'react';
```

TypeScript will search in:

1. `node_modules/react` looking for types
2. `@types/react` for declaration files
3. Up the directory tree if not found in the current `node_modules`

### Path Mapping

Path mapping allows you to configure custom module paths in your TypeScript project, enabling shorter imports and more flexible project structures.

**Basic Path Mapping**

```json
// tsconfig.json
{
  "compilerOptions": {
    "baseUrl": ".",
    "paths": {
      "@app/*": ["src/app/*"],
      "@core/*": ["src/core/*"],
      "@shared/*": ["src/shared/*"],
      "@environment": ["src/environments/environment"]
    }
  }
}
```

With these path mappings, you can import like this:

```typescript
// Instead of relative paths like "../../../../shared/models/user"
import { User } from '@shared/models/user';
import { environment } from '@environment';
import { AuthService } from '@core/services/auth.service';
```

**Base URL Configuration**

The `baseUrl` option changes the base directory for resolving non-relative module names:

```json
// tsconfig.json
{
  "compilerOptions": {
    "baseUrl": "./src"
  }
}
```

This allows you to import from the `src` directory without relative paths:

```typescript
// Instead of "../../../models/user"
import { User } from 'models/user';
```

**Mapping for Libraries and Type Definitions**

```json
// tsconfig.json
{
  "compilerOptions": {
    "baseUrl": ".",
    "paths": {
      "lodash/*": ["node_modules/lodash-es/*"],
      "jquery": ["node_modules/jquery/dist/jquery"]
    }
  }
}
```

**Advanced Path Mapping Patterns**

```json
// tsconfig.json
{
  "compilerOptions": {
    "baseUrl": ".",
    "paths": {
      // Map exact module name
      "crypto": ["src/crypto/index.ts"],
      
      // Map all files under a directory
      "lib/*": ["src/lib/*"],
      
      // Fallback paths (try first path, then second)
      "utils/*": ["src/utils/modern/*", "src/utils/legacy/*"],
      
      // Map a module name to multiple files
      "jquery": [
        "node_modules/jquery/dist/jquery.slim.min.js",
        "node_modules/jquery/dist/jquery.min.js"
      ]
    }
  }
}
```

**Path Mapping with Barrel Files**

A common pattern is to use "barrel" files (index.ts) that re-export components from a directory:

```typescript
// src/components/index.ts
export * from './Button';
export * from './Input';
export * from './Card';
export * from './Modal';

// Usage with path mapping
// tsconfig.json: "@components": ["src/components"]
import { Button, Input, Card } from '@components';
```

### Working with Different Module Systems

TypeScript can emit code for different module systems based on your project needs.

**Module Configuration**

```json
// tsconfig.json
{
  "compilerOptions": {
    "module": "ESNext", // Options: CommonJS, AMD, UMD, ESNext, etc.
    "esModuleInterop": true,
    "allowSyntheticDefaultImports": true
  }
}
```

**CommonJS Interoperability**

The `esModuleInterop` flag helps with CommonJS modules that don't properly conform to ES module specifications:

```typescript
// Without esModuleInterop
import * as React from 'react';

// With esModuleInterop
import React from 'react';
```

### Dynamic Imports

TypeScript supports dynamic imports for code splitting and lazy loading:

```typescript
// Normal static import
import { UserService } from './services/user.service';

// Dynamic import (returns a promise)
async function loadAdminModule() {
  const adminModule = await import('./admin/admin.module');
  return new adminModule.AdminModule();
}

// Type-safe dynamic imports
type AdminModuleType = typeof import('./admin/admin.module');
let modulePromise: Promise<AdminModuleType>;

function loadAdminFeatures() {
  if (!modulePromise) {
    modulePromise = import('./admin/admin.module');
  }
  return modulePromise.then(m => new m.AdminModule());
}
```

### Ambient Modules

Ambient modules declare the types for modules that may not have TypeScript declarations.

**Creating Declaration Files**

```typescript
// types/untyped-module/index.d.ts
declare module 'untyped-module' {
  export function doSomething(value: string): number;
  export const VERSION: string;
  export default class MainClass {
    constructor(options: { debug: boolean });
    process(data: any): void;
  }
}

// Now you can import it with type safety
import MainClass, { doSomething, VERSION } from 'untyped-module';
```

**Wildcard Module Declarations**

```typescript
// types/image-modules.d.ts
declare module '*.png' {
  const content: string;
  export default content;
}

declare module '*.json' {
  const content: any;
  export default content;
}

// Usage
import logoUrl from './assets/logo.png';
import configData from './config.json';
```

### Module Augmentation

TypeScript allows you to extend existing modules with new functionality:

```typescript
// original-module.ts
export interface User {
  id: number;
  name: string;
}

// augmentation.ts
import { User } from './original-module';

// Augment the original module
declare module './original-module' {
  interface User {
    email: string;
    role: string;
  }
  
  export function validateUser(user: User): boolean;
}

// Implementation of the augmented function
export function validateUser(user: User): boolean {
  return !!user.email && !!user.role;
}

// usage.ts
import { User } from './original-module';
import './augmentation'; // Important: must import the augmentation

const user: User = {
  id: 1,
  name: 'John',
  email: 'john@example.com', // Now valid because of augmentation
  role: 'admin'              // Now valid because of augmentation
};
```

### Best Practices for TypeScript Modules

**Organize by Feature**

Structure modules around features or domains rather than technical concerns:

```
/src
  /users
    /components
      user-list.component.ts
      user-detail.component.ts
    /services
      user.service.ts
    /models
      user.model.ts
    users.module.ts
  /products
    ...
```

**Use Barrel Files Strategically**

Barrel files simplify imports but can cause circular dependencies if overused:

```typescript
// features/user/index.ts
export * from './user.model';
export * from './user.service';
export * from './user-list.component';

// Import everything from one location
import { User, UserService, UserListComponent } from './features/user';
```

**Avoid Side Effects in Module Imports**

Keep module imports free from side effects:

```typescript
// BAD: Side effects during import
import './polyfills'; // runs code immediately

// GOOD: Explicit side effect execution
import { setupPolyfills } from './polyfills';
setupPolyfills();
```

**Use Type-Only Imports When Possible**

```typescript
// Only import types, not implementation
import type { User, UserRole } from './models';

// Instead of
import { User, UserRole } from './models';
```

**Use Consistent Naming Conventions**

```typescript
// model.ts for interfaces, types
export interface User {...}
export type UserRole = 'admin' | 'user';

// service.ts for services
export class UserService {...}

// utils.ts for utility functions
export function formatDate(date: Date): string {...}
```

**Module Resolution Configuration Check**

Verify your module resolution settings match your project's needs:

```json
// tsconfig.json for modern web app
{
  "compilerOptions": {
    "module": "ESNext",
    "moduleResolution": "Bundler",
    "esModuleInterop": true,
    "allowSyntheticDefaultImports": true,
    "baseUrl": "src",
    "paths": {
      "@app/*": ["app/*"],
      "@core/*": ["core/*"],
      "@shared/*": ["shared/*"]
    }
  }
}
```

### Common Module Patterns

**API Module Pattern**

```typescript
// api/users.api.ts
import { httpClient } from '@core/http';
import type { User, CreateUserDto } from '@app/models';

export const usersApi = {
  getAll: (): Promise<User[]> => 
    httpClient.get('/users'),
  
  getById: (id: number): Promise<User> => 
    httpClient.get(`/users/${id}`),
  
  create: (user: CreateUserDto): Promise<User> => 
    httpClient.post('/users', user)
};

// Usage
import { usersApi } from '@app/api/users.api';
const users = await usersApi.getAll();
```

**Services Pattern**

```typescript
// services/auth.service.ts
import { User } from '@app/models';
import { usersApi } from '@app/api';

export class AuthService {
  private currentUser: User | null = null;
  
  async login(username: string, password: string): Promise<User> {
    // Implementation
    return {} as User;
  }
  
  logout(): void {
    this.currentUser = null;
  }
  
  getCurrentUser(): User | null {
    return this.currentUser;
  }
}

export const authService = new AuthService();

// Usage
import { authService } from '@app/services';
await authService.login('user', 'pass');
```

**Feature Module Pattern**

```typescript
// feature-module.ts
export interface FeatureConfig {
  enabled: boolean;
  apiEndpoint: string;
}

export class FeatureModule {
  constructor(private config: FeatureConfig) {}
  
  initialize(): void {
    // Setup code
  }
  
  // Feature specific methods
}

// Re-export from index.ts
export * from './feature-module';
export * from './feature-components';
export * from './feature-services';
```

**Recommended Related Topics**

- TypeScript Project Configuration
- TypeScript Declaration Files (.d.ts)
- Webpack and TypeScript Integration
- ESLint Configuration for TypeScript Projects
- TypeScript in Monorepo Architectures

---

## TypeScript Namespaces

### Creating Namespaces

Namespaces in TypeScript provide a way to logically group related code, preventing name collisions and organizing your code structure. They create a scope for identifiers, helping avoid global namespace pollution.

**Key Points**

- Namespaces are declared using the `namespace` keyword
- They can contain classes, interfaces, functions, variables, and other namespaces
- Elements inside namespaces need to be explicitly exported to be accessible outside
- Namespaces generate JavaScript objects that contain the exported members

```typescript
namespace Validation {
  // Export makes this interface available outside the namespace
  export interface StringValidator {
    isValid(s: string): boolean;
  }
  
  // Not exported - only accessible within the namespace
  const lettersRegexp = /^[A-Za-z]+$/;
  
  // Exported class implementation
  export class LettersValidator implements StringValidator {
    isValid(s: string): boolean {
      return lettersRegexp.test(s);
    }
  }
  
  // Another exported class
  export class ZipCodeValidator implements StringValidator {
    isValid(s: string): boolean {
      return /^\d{5}(-\d{4})?$/.test(s);
    }
  }
}

// Using the namespace members
let validator: Validation.StringValidator = new Validation.LettersValidator();
console.log(validator.isValid("Hello")); // true
```

### Compiled JavaScript Output

When TypeScript namespaces are compiled to JavaScript, they become JavaScript objects or functions with properties.

**Key Points**

- The namespace becomes an IIFE (Immediately Invoked Function Expression) in JavaScript
- Exported members become properties of the namespace object
- Non-exported members remain private

**Example**

```typescript
// TypeScript namespace
namespace Geometry {
  export interface Point {
    x: number;
    y: number;
  }
  
  export class Circle {
    constructor(public center: Point, public radius: number) {}
    
    area(): number {
      return Math.PI * this.radius * this.radius;
    }
  }
}

// Compiled JavaScript (simplified)
var Geometry;
(function (Geometry) {
  var Circle = /** @class */ (function () {
    function Circle(center, radius) {
      this.center = center;
      this.radius = radius;
    }
    Circle.prototype.area = function () {
      return Math.PI * this.radius * this.radius;
    };
    return Circle;
  }());
  Geometry.Circle = Circle;
})(Geometry || (Geometry = {}));
```

### Nested Namespaces

TypeScript allows nesting namespaces within other namespaces, creating hierarchical organizations for complex applications.

**Key Points**

- Namespaces can be nested to any depth
- Each level needs its own export to be accessible
- Nested namespaces help organize related functionality into logical groups
- Accessing deeply nested elements requires dot notation through the hierarchy

```typescript
namespace Application {
  export namespace UI {
    export namespace Components {
      export class Button {
        constructor(public text: string, public action: () => void) {}
        
        render(): string {
          return `<button>${this.text}</button>`;
        }
      }
      
      export class Input {
        constructor(public placeholder: string) {}
        
        render(): string {
          return `<input placeholder="${this.placeholder}" />`;
        }
      }
    }
    
    export namespace Utilities {
      export function createElement(tag: string, content: string): string {
        return `<${tag}>${content}</${tag}>`;
      }
    }
  }
  
  export namespace Services {
    export class DataService {
      getData(): any {
        return { message: "Data loaded" };
      }
    }
  }
}

// Using nested namespace members
const button = new Application.UI.Components.Button("Click me", () => console.log("Clicked"));
console.log(button.render()); // "<button>Click me</button>"

const element = Application.UI.Utilities.createElement("div", "Hello, world!");
console.log(element); // "<div>Hello, world!</div>"
```

### Namespace Aliases

To simplify working with long namespace paths, TypeScript provides import aliases for namespaces.

**Key Points**

- Use the `import` keyword to create namespace aliases
- Aliases make code more readable and maintainable
- They don't create new objects, just alternative names

```typescript
namespace Shapes {
  export namespace TwoDimensional {
    export class Circle {
      constructor(public radius: number) {}
      
      area(): number {
        return Math.PI * this.radius * this.radius;
      }
    }
    
    export class Rectangle {
      constructor(public width: number, public height: number) {}
      
      area(): number {
        return this.width * this.height;
      }
    }
  }
}

// Without alias - long namespace path
const circle1 = new Shapes.TwoDimensional.Circle(5);

// With alias - shorter, more readable
import Circle = Shapes.TwoDimensional.Circle;
import Rectangle = Shapes.TwoDimensional.Rectangle;

const circle2 = new Circle(5);
const rectangle = new Rectangle(10, 20);

console.log(circle2.area()); // 78.54...
console.log(rectangle.area()); // 200
```

### Multi-File Namespaces

Namespaces can span multiple files, allowing modular development while maintaining logical grouping.

**Key Points**

- Declaration merging combines namespaces with the same name
- Use reference tags or module bundling to ensure all parts are included
- Compilation order matters for correct output

File: `validators.ts`

```typescript
namespace Validation {
  export interface StringValidator {
    isValid(s: string): boolean;
  }
}
```

File: `letters-validator.ts`

```typescript
/// <reference path="validators.ts" />
namespace Validation {
  const lettersRegexp = /^[A-Za-z]+$/;
  
  export class LettersValidator implements StringValidator {
    isValid(s: string): boolean {
      return lettersRegexp.test(s);
    }
  }
}
```

File: `zipcode-validator.ts`

```typescript
/// <reference path="validators.ts" />
namespace Validation {
  const zipCodeRegexp = /^\d{5}(-\d{4})?$/;
  
  export class ZipCodeValidator implements StringValidator {
    isValid(s: string): boolean {
      return zipCodeRegexp.test(s);
    }
  }
}
```

File: `app.ts`

```typescript
/// <reference path="validators.ts" />
/// <reference path="letters-validator.ts" />
/// <reference path="zipcode-validator.ts" />

// Some samples to validate
let strings = ["Hello", "98052", "101"];

// Validators to use
let validators: { [s: string]: Validation.StringValidator } = {};
validators["Letters"] = new Validation.LettersValidator();
validators["ZIP"] = new Validation.ZipCodeValidator();

// Show validation results
strings.forEach(s => {
  for (let name in validators) {
    console.log(`"${s}" - ${validators[name].isValid(s) ? "Matches" : "Does not match"} ${name}`);
  }
});
```

### Namespace Imports

TypeScript allows importing entire namespaces using the `import` syntax, providing an alternative to reference tags.

**Key Points**

- `import` can load an entire namespace from a module
- This is different from ES module imports
- Useful for legacy code integration

```typescript
// In Node.js environment with CommonJS
import * as Validation from "./validation";

let validators: { [s: string]: Validation.StringValidator } = {};
validators["Letters"] = new Validation.LettersValidator();
validators["ZIP"] = new Validation.ZipCodeValidator();
```

### Ambient Namespaces

Ambient namespaces declare the shape of libraries or modules without providing implementations.

**Key Points**

- Used in declaration files (.d.ts)
- Describe the structure of existing JavaScript code
- Typically used for third-party libraries without TypeScript definitions

```typescript
// In a .d.ts file
declare namespace JQuery {
  function ajax(settings: JQueryAjaxSettings): JQueryXHR;
  
  interface JQueryAjaxSettings {
    url?: string;
    method?: string;
    data?: any;
    dataType?: string;
  }
  
  interface JQueryXHR {
    statusText: string;
    responseText: string;
    done(callback: Function): JQueryXHR;
    fail(callback: Function): JQueryXHR;
  }
}

// Usage in TypeScript file
JQuery.ajax({
  url: "https://api.example.com/data",
  method: "GET",
  dataType: "json"
}).done(function(data) {
  console.log("Success:", data);
});
```

### Re-exporting Namespace Members

Namespaces can re-export members from other namespaces to create customized public APIs.

**Key Points**

- Useful for creating facade patterns
- Helps control what is exposed to consumers
- Simplifies interface for complex namespaces

```typescript
namespace Utilities {
  export namespace Math {
    export function add(x: number, y: number): number { return x + y; }
    export function subtract(x: number, y: number): number { return x - y; }
    export function multiply(x: number, y: number): number { return x * y; }
    export function divide(x: number, y: number): number { return x / y; }
  }
  
  export namespace Strings {
    export function capitalize(s: string): string {
      return s.charAt(0).toUpperCase() + s.slice(1);
    }
    
    export function reverse(s: string): string {
      return s.split("").reverse().join("");
    }
  }
}

// Re-export specific members to create a simplified API
namespace App {
  // Re-export only specific functions
  export import add = Utilities.Math.add;
  export import capitalize = Utilities.Strings.capitalize;
  
  // Add app-specific functions
  export function formatName(firstName: string, lastName: string): string {
    return `${capitalize(firstName)} ${lastName.toUpperCase()}`;
  }
}

// Usage
console.log(App.add(10, 20)); // 30
console.log(App.capitalize("hello")); // "Hello"
console.log(App.formatName("john", "doe")); // "John DOE"
```

### When to Use Modules vs. Namespaces

TypeScript offers both namespaces and ES modules, each with different use cases and benefits.

**Key Points**

- Modules (ES modules) are the preferred approach for modern TypeScript applications
- Namespaces are primarily for legacy code and specific organizational needs

#### Use Modules When:

- Building applications for modern JavaScript environments
- Working with bundlers like Webpack, Rollup, or Parcel
- Need for true encapsulation and dependency management
- Working on larger projects with complex dependencies
- Using modern frameworks like React, Angular, or Vue
- Tree-shaking (dead code elimination) is important
- Targeting ECMAScript 2015 (ES6) or higher

```typescript
// math.ts - ES Module
export function add(x: number, y: number): number {
  return x + y;
}

export function subtract(x: number, y: number): number {
  return x - y;
}

// app.ts - ES Module import
import { add, subtract } from './math';

console.log(add(10, 5)); // 15
```

#### Use Namespaces When:

- Working with legacy TypeScript code
- Organizing a script-based application (no module bundler)
- Creating a library that needs to work in non-module environments
- Adding type declarations to existing JavaScript
- Developing for environments that don't support ES modules
- Need to merge declarations across multiple files

```typescript
// Using namespaces for script-based approach
namespace MathUtils {
  export function add(x: number, y: number): number {
    return x + y;
  }
  
  export function subtract(x: number, y: number): number {
    return x - y;
  }
}

// Usage directly in global scope
console.log(MathUtils.add(10, 5)); // 15
```

### Namespace Patterns and Best Practices

Regardless of whether you choose namespaces or modules, certain patterns help improve code organization.

**Key Points**

- Avoid deeply nested namespaces (more than 2-3 levels)
- Export only what's necessary
- Use consistent naming conventions
- Consider barrels for simplified imports

#### Barrel Pattern with Namespaces

```typescript
// components/button.ts
namespace UI.Components {
  export class Button {
    // Implementation
  }
}

// components/input.ts
namespace UI.Components {
  export class Input {
    // Implementation
  }
}

// components/index.ts (barrel)
/// <reference path="button.ts" />
/// <reference path="input.ts" />

namespace UI {
  // Re-export everything from Components
  export import Components = UI.Components;
}

// Usage
/// <reference path="components/index.ts" />
let button = new UI.Components.Button();
```

### Converting Between Namespaces and Modules

As projects evolve, you may need to convert between namespaces and modules.

**Key Points**

- Namespaces can be converted to modules by changing syntax and file structure
- Move namespace members to dedicated files as ES modules
- Update import/export syntax

#### From Namespace:

```typescript
// Before: app.ts with namespace
namespace Validation {
  export interface StringValidator {
    isValid(s: string): boolean;
  }
  
  export class LettersValidator implements StringValidator {
    isValid(s: string): boolean {
      return /^[A-Za-z]+$/.test(s);
    }
  }
}
```

#### To Modules:

```typescript
// After: types.ts
export interface StringValidator {
  isValid(s: string): boolean;
}

// After: letters-validator.ts
import { StringValidator } from './types';

export class LettersValidator implements StringValidator {
  isValid(s: string): boolean {
    return /^[A-Za-z]+$/.test(s);
  }
}
```

### Combining Namespaces and Modules

In some cases, you might need to use both namespaces and modules together during migration or when integrating with different code styles.

**Key Points**

- Export namespaces from modules for a hybrid approach
- Useful during incremental migration
- Can help when interfacing with legacy code

```typescript
// validators.ts - Module that exports a namespace
export namespace Validators {
  export interface StringValidator {
    isValid(s: string): boolean;
  }
  
  export class LettersValidator implements StringValidator {
    isValid(s: string): boolean {
      return /^[A-Za-z]+$/.test(s);
    }
  }
  
  export class ZipCodeValidator implements StringValidator {
    isValid(s: string): boolean {
      return /^\d{5}(-\d{4})?$/.test(s);
    }
  }
}

// app.ts
import { Validators } from './validators';

let letterValidator = new Validators.LettersValidator();
console.log(letterValidator.isValid("Hello")); // true
```

### Global Augmentation with Namespaces

TypeScript allows augmenting the global scope using namespaces, which can be useful for adding declarations to built-in objects.

**Key Points**

- Use `declare global` inside a module
- Useful for adding methods to built-in types
- Should be used sparingly to avoid polluting global scope

```typescript
// extensions.ts - Module file
export {};  // Ensure this is treated as a module

declare global {
  interface String {
    capitalize(): string;
    reverse(): string;
  }
  
  interface Array<T> {
    first(): T | undefined;
    last(): T | undefined;
  }
}

// Implement the extensions
String.prototype.capitalize = function(): string {
  return this.charAt(0).toUpperCase() + this.slice(1);
};

String.prototype.reverse = function(): string {
  return this.split("").reverse().join("");
};

Array.prototype.first = function<T>(): T | undefined {
  return this.length > 0 ? this[0] : undefined;
};

Array.prototype.last = function<T>(): T | undefined {
  return this.length > 0 ? this[this.length - 1] : undefined;
};

// Usage in another file
import './extensions';

console.log("hello".capitalize()); // "Hello"
console.log([1, 2, 3].last()); // 3
```

---

## Declaration Files

### Understanding .d.ts Files

**Key Points**

- Declaration files (.d.ts) contain type information without implementation
- They define types for JavaScript libraries and external code
- Declaration files use a special syntax with `declare` keywords
- They allow TypeScript to understand code written in JavaScript

Declaration files (with the .d.ts extension) provide type information to TypeScript without including implementation details. These files are central to TypeScript's ability to work with existing JavaScript libraries:

```typescript
// Example of what might be in a declaration file
// No implementation, just type declarations
declare function calculateDistance(x1: number, y1: number, x2: number, y2: number): number;

declare const PI: number;

declare class Point {
  x: number;
  y: number;
  constructor(x: number, y: number);
  distanceTo(other: Point): number;
}

declare namespace Geometry {
  interface Rectangle {
    width: number;
    height: number;
    area(): number;
  }
  
  function createRectangle(width: number, height: number): Rectangle;
}
```

Declaration files can be generated automatically or written manually:

1. **Automatically Generated**
    
    - When compiling TypeScript with `declaration: true` in tsconfig.json
    - When using tools like `dts-gen` or `tsc --declaration`
2. **Manually Written**
    
    - For third-party libraries without existing type definitions
    - For global variables, functions, or objects

Common locations for declaration files:

```
├── node_modules/
│   └── @types/            // DefinitelyTyped declarations
│       └── lodash/
│           └── index.d.ts
├── src/
│   ├── types/             // Project-specific declarations
│   │   └── custom.d.ts
│   └── global.d.ts        // Global declarations for the project
└── tsconfig.json
```

TypeScript looks for declaration files in several places:

1. Alongside JavaScript files (same name with .d.ts extension)
2. In the `@types` directory in node_modules
3. In paths configured in the `typeRoots` and `types` options in tsconfig.json
4. In locations specified by the `/// <reference path="..." />` directive

The three main types of declaration files:

1. **Global declarations** - Add types to the global scope
    
    ```typescript
    // global.d.ts
    declare const API_KEY: string;
    declare function logError(message: string): void;
    ```
    
2. **Module declarations** - Declare types for imported modules
    
    ```typescript
    // jquery.d.ts
    declare module 'jquery' {
      function $(selector: string): any;
      // ... other jQuery definitions
      export = $;
    }
    ```
    
3. **Ambient module declarations** - Declare the existence of modules without specifying details
    
    ```typescript
    // modules.d.ts
    declare module 'some-untyped-module';
    ```
    

### Writing Declaration Files

**Key Points**

- Use `declare` keywords for ambient declarations
- Namespaces help organize related declarations
- Export statements define module exports
- Interface merging allows extending existing types

When writing declaration files, there are several important patterns to understand:

#### Global Variables and Functions:

```typescript
// For global variables
declare const VERSION: string;
declare let debugMode: boolean;

// For global functions
declare function log(message: string): void;
declare function ajax(url: string, options: AjaxOptions): Promise<any>;

// For global classes
declare class User {
  id: number;
  name: string;
  constructor(id: number, name: string);
  getFullName(): string;
}

// For global interfaces
interface AjaxOptions {
  method?: 'GET' | 'POST' | 'PUT' | 'DELETE';
  headers?: Record<string, string>;
  data?: any;
  timeout?: number;
}
```

#### Namespaces (used for organizing):

```typescript
// Use namespaces to group related declarations
declare namespace API {
  function get(url: string): Promise<any>;
  function post(url: string, data: any): Promise<any>;
  
  interface Response<T> {
    data: T;
    status: number;
    headers: Record<string, string>;
  }
  
  namespace Auth {
    function login(username: string, password: string): Promise<string>;
    function logout(): Promise<void>;
  }
}

// Usage in TypeScript files:
// API.get('/users');
// API.Auth.login('user', 'pass');
```

#### Module Declarations:

```typescript
// For npm packages or ES modules
declare module 'my-library' {
  export function doSomething(): void;
  export class Helper {
    process(data: any): any;
  }
  export interface Options {
    debug?: boolean;
    timeout?: number;
  }
  
  // Default export
  export default function main(): void;
}

// Usage:
// import main, { doSomething, Helper } from 'my-library';
```

#### Module Augmentation:

```typescript
// Extending an existing module
declare module 'express' {
  interface Request {
    user?: {
      id: string;
      name: string;
      roles: string[];
    };
  }
}

// This allows you to use req.user safely when working with Express
```

#### Special Declarations:

```typescript
// For CSS/SCSS/Less modules
declare module '*.css' {
  const content: { [className: string]: string };
  export default content;
}

declare module '*.scss' {
  const content: { [className: string]: string };
  export default content;
}

// For images or other assets
declare module '*.png' {
  const value: string;
  export default value;
}

declare module '*.svg' {
  const content: React.FC<React.SVGProps<SVGSVGElement>>;
  export default content;
}

// For JSON files
declare module '*.json' {
  const value: any;
  export default value;
}
```

#### Declaration File for a Complex Library:

```typescript
// jquery.d.ts
declare namespace $ {
  function ajax(settings: JQueryAjaxSettings): JQueryXHR;
  
  interface JQueryAjaxSettings {
    url?: string;
    method?: 'GET' | 'POST' | 'PUT' | 'DELETE';
    data?: any;
    dataType?: string;
    success?: (data: any, textStatus: string, jqXHR: JQueryXHR) => void;
    error?: (jqXHR: JQueryXHR, textStatus: string, errorThrown: string) => void;
  }
  
  interface JQueryXHR extends XMLHttpRequest {
    responseJSON?: any;
  }
  
  function get(url: string, success?: (data: any) => void): JQueryXHR;
  function post(url: string, data?: any, success?: (data: any) => void): JQueryXHR;
}

// Support both global variable and module
declare const jQuery: typeof $;
declare module 'jquery' {
  export = jQuery;
}
```

### Using DefinitelyTyped

**Key Points**

- DefinitelyTyped (@types) is a repository of declaration files for thousands of JavaScript libraries
- Most popular libraries have type definitions available via npm/@types
- Installation is simple with npm/yarn
- It's community-maintained with regular updates

DefinitelyTyped is a centralized repository that hosts TypeScript declaration files for thousands of JavaScript libraries. These declarations are published to npm under the `@types` scope:

#### Installing Type Definitions:

```bash
# Basic syntax
npm install --save-dev @types/library-name

# Examples
npm install --save-dev @types/react
npm install --save-dev @types/lodash
npm install --save-dev @types/express
```

Once installed, TypeScript automatically finds and uses these type definitions. No import is needed for the type definitions themselves (just import the library normally).

#### Finding Available Type Definitions:

1. Search the npm registry: [https://www.npmjs.com/search?q=%40types](https://www.npmjs.com/search?q=%40types)
2. Browse the DefinitelyTyped GitHub repository: [https://github.com/DefinitelyTyped/DefinitelyTyped](https://github.com/DefinitelyTyped/DefinitelyTyped)
3. Use the TypeSearch tool: [https://microsoft.github.io/TypeSearch/](https://microsoft.github.io/TypeSearch/)

#### Understanding Type Versions:

Type packages often have versioning that corresponds to the library version they support:

```bash
# For React 16.x
npm install --save-dev @types/react@16

# For a specific version
npm install --save-dev @types/react@16.9.34
```

#### Configuration in tsconfig.json:

```json
{
  "compilerOptions": {
    // Include all @types packages from node_modules/@types
    "typeRoots": ["./node_modules/@types", "./src/types"],
    
    // Only include specific @types packages
    "types": ["node", "jest", "express"]
  }
}
```

- `typeRoots`: Specifies directories where TypeScript looks for type definitions
- `types`: Limits which packages from `@types` are included

#### Contributing to DefinitelyTyped:

If you find a library without type definitions or discover issues with existing definitions:

1. Fork the DefinitelyTyped repository
2. Add or fix type definitions following the contribution guidelines
3. Submit a pull request

The basic structure for a new DefinitelyTyped package:

```
types/library-name/
├── index.d.ts            // Main declaration file
├── library-name-tests.ts // Test file showing usage
├── tsconfig.json         // Configuration for this specific package
├── tslint.json           // Linting rules
└── v1/                   // Optional directory for older versions
    └── index.d.ts
```

### Declaration Merging

**Key Points**

- Declaration merging combines multiple declarations with the same name
- Interfaces automatically merge when declared multiple times
- Namespaces can be merged to add new members
- Modules can be augmented to add new exports
- Classes can be merged with namespaces for static members

TypeScript's declaration merging allows multiple separate declarations with the same name to be combined into a single definition. This is one of TypeScript's most powerful features:

#### Interface Merging:

```typescript
// Original interface in a library
interface User {
  id: number;
  name: string;
}

// In your code, extend the interface
interface User {
  email: string;
  isActive: boolean;
}

// TypeScript merges these into:
// interface User {
//   id: number;
//   name: string;
//   email: string;
//   isActive: boolean;
// }

// Usage with all properties available
const user: User = {
  id: 1,
  name: "John",
  email: "john@example.com",
  isActive: true
};
```

When merging interfaces, later interfaces with the same property name must have a compatible type:

```typescript
interface Box {
  height: number;
  width: number;
}

interface Box {
  scale: number;
  // height: string; // Error: Subsequent property declarations must have the same type
}
```

Function overloads in interfaces are merged in declaration order:

```typescript
interface Document {
  createElement(tagName: string): Element;
}

interface Document {
  createElement(tagName: 'div'): HTMLDivElement;
  createElement(tagName: 'span'): HTMLSpanElement;
  createElement(tagName: 'canvas'): HTMLCanvasElement;
}

// Merged in order (specific overloads come before general ones)
```

#### Namespace Merging:

```typescript
// Original namespace
namespace Validation {
  export interface StringValidator {
    isValid(s: string): boolean;
  }
}

// Extended namespace
namespace Validation {
  export class RegexValidator implements StringValidator {
    constructor(private regex: RegExp) {}
    
    isValid(s: string): boolean {
      return this.regex.test(s);
    }
  }
}

// Additional extension
namespace Validation {
  export const emailRegex = /^[^@]+@[^@]+\.[^@]+$/;
  export const phoneRegex = /^\d{10}$/;
}

// Usage with all merged members
const emailValidator = new Validation.RegexValidator(Validation.emailRegex);
const isValid = emailValidator.isValid("user@example.com");
```

Non-exported members remain private to each namespace declaration.

#### Merging Namespaces with Classes:

```typescript
// Define a class
class Album {
  label: Album.AlbumLabel;
  
  constructor(public title: string, label: string) {
    this.label = new Album.AlbumLabel(label);
  }
}

// Augment with a namespace for static members/nested types
namespace Album {
  export class AlbumLabel {
    constructor(public label: string) {}
  }
  
  export function create(title: string, label: string): Album {
    return new Album(title, label);
  }
}

// Usage
const album = Album.create("Blue Train", "Blue Note");
console.log(album.label.label); // "Blue Note"
```

This pattern is often used to add static members to classes.

#### Merging Namespaces with Functions:

```typescript
// Define a function
function formatDate(date: Date): string {
  return date.toISOString();
}

// Augment with a namespace
namespace formatDate {
  export const defaultFormat = "YYYY-MM-DD";
  
  export function format(date: Date, format: string): string {
    // Implementation
    return "formatted date";
  }
}

// Usage
formatDate(new Date()); // Call the function
formatDate.format(new Date(), formatDate.defaultFormat); // Access namespace members
```

This pattern is used in many libraries like jQuery, where `$` is both a function and contains properties/methods.

#### Merging Namespaces with Enums:

```typescript
// Define an enum
enum Color {
  Red = "#FF0000",
  Green = "#00FF00",
  Blue = "#0000FF"
}

// Augment with a namespace
namespace Color {
  export function mix(c1: Color, c2: Color): Color {
    // Implementation
    return Color.Red;
  }
  
  export function isLight(color: Color): boolean {
    // Implementation
    return true;
  }
}

// Usage
const mixedColor = Color.mix(Color.Red, Color.Blue);
const isLight = Color.isLight(Color.Green);
```

#### Module Augmentation:

```typescript
// Original library export (e.g., in node_modules/some-lib/index.d.ts)
declare module "some-lib" {
  export function method1(): void;
  export interface Options {
    debug: boolean;
  }
}

// Augmenting in your code
declare module "some-lib" {
  // Add new function export
  export function method2(): void;
  
  // Extend existing interface
  export interface Options {
    timeout: number;
  }
}

// Usage
import { method1, method2, Options } from "some-lib";

const options: Options = {
  debug: true,
  timeout: 3000
};
```

This is commonly used to add types to third-party modules or extend existing ones.

#### Global Augmentation:

```typescript
// Original global declarations
interface Window {
  title: string;
}

// Augmenting the global scope
declare global {
  interface Window {
    analytics: {
      track(event: string, properties?: object): void;
      identify(userId: string, traits?: object): void;
    };
  }
  
  interface Array<T> {
    toCSV(): string;
  }
}

// Usage
window.analytics.track("Page View");

const items = [1, 2, 3];
const csv = items.toCSV();
```

Global augmentation must be inside a module (file with imports/exports).

**Conclusion**

TypeScript declaration files are essential for working with JavaScript libraries in a type-safe manner. They provide the bridge between untyped JavaScript code and TypeScript's static type system. Understanding how to read, write, and work with declaration files unlocks TypeScript's full potential in various scenarios:

1. **Using existing libraries**: By leveraging DefinitelyTyped and its extensive collection of type definitions, you can use thousands of JavaScript libraries with full TypeScript support.
    
2. **Extending types**: Through declaration merging, you can extend or customize existing type definitions to better match your usage patterns or add missing functionality.
    
3. **Creating custom libraries**: When developing libraries meant to be consumed by others, declaration files ensure that users get proper type information and IDE support.
    
4. **Working with untyped code**: For legacy code or libraries without types, writing your own declaration files enables gradual adoption of TypeScript without rewriting everything.
    

The flexibility of declaration files—from global definitions to module augmentation—makes TypeScript adaptable to virtually any JavaScript ecosystem. Whether you're working with modern ES modules, CommonJS libraries, or global browser scripts, declaration files provide the type safety and tooling support that make TypeScript development productive and robust.

---

# Error Handling and Debugging

## Error Handling in TypeScript

### Error Types

TypeScript provides several built-in error types that extend from the base `Error` class, enabling developers to manage different error scenarios with type safety.

**Key Points**

- All error types extend the base `Error` class
- Built-in error types include `Error`, `SyntaxError`, `TypeError`, `ReferenceError`, and more
- The `Error` class includes `name`, `message`, and `stack` properties
- TypeScript errors are fully compatible with JavaScript's error handling system

```typescript
// Basic Error usage
const error = new Error("Something went wrong");
console.log(error.message); // "Something went wrong"
console.log(error.name);    // "Error"
console.log(error.stack);   // Stack trace

// Built-in error types
const syntaxError = new SyntaxError("Invalid syntax");
const typeError = new TypeError("Invalid type");
const rangeError = new RangeError("Value out of range");
const referenceError = new ReferenceError("Variable not defined");
const uriError = new URIError("Invalid URI");
const evalError = new EvalError("Error in eval() function");
```

### Type-Safe Error Handling

TypeScript enhances error handling with static typing, allowing for more precise error identification and handling.

**Key Points**

- Type checking helps catch potential errors at compile time
- TypeScript can narrow down error types using type guards
- Type assertions can be used when you're certain about an error's type

```typescript
function processValue(value: unknown): number {
  if (typeof value !== "number") {
    throw new TypeError("Expected a number");
  }
  
  if (value < 0 || value > 100) {
    throw new RangeError("Value must be between 0 and 100");
  }
  
  return value * 2;
}

try {
  const result = processValue("not a number");
  console.log(result);
} catch (error) {
  if (error instanceof TypeError) {
    console.error("Type Error:", error.message);
  } else if (error instanceof RangeError) {
    console.error("Range Error:", error.message);
  } else {
    console.error("Unknown Error:", error);
  }
}
```

### Try/Catch Blocks

The try/catch mechanism is the primary way to handle exceptions in TypeScript, with TypeScript adding type safety to the caught errors.

**Key Points**

- Use `try/catch` to handle exceptions that might occur
- The catch block variable is typed as `unknown` in TypeScript 4.0+
- Type narrowing with `instanceof` helps handle different error types
- The optional `finally` block executes regardless of whether an exception was thrown

```typescript
function divide(a: number, b: number): number {
  if (b === 0) {
    throw new Error("Division by zero");
  }
  return a / b;
}

try {
  // Code that might throw an exception
  const result = divide(10, 0);
  console.log(result);
} catch (error) {
  // Handle the error
  if (error instanceof Error) {
    console.error("An error occurred:", error.message);
  } else {
    console.error("An unknown error occurred:", error);
  }
} finally {
  // Clean up resources, always executes
  console.log("Execution completed");
}
```

### Type Guards for Errors

TypeScript allows using type guards to narrow down the type of caught errors, improving type safety in error handling.

**Key Points**

- Type guards help determine the specific error type
- Common type guards include `instanceof` and custom type predicates
- Type guards enable type-specific error handling

```typescript
// Custom type guard function
function isTypeError(error: unknown): error is TypeError {
  return error instanceof TypeError;
}

try {
  // Some operation that might throw
  const obj = null;
  obj.property = "value"; // This will throw TypeError
} catch (error: unknown) {
  // Using instanceof type guard
  if (error instanceof TypeError) {
    console.error("Type error occurred:", error.message);
  }
  // Using custom type guard function
  else if (isTypeError(error)) {
    console.error("Another type error:");
  }
  // Using type assertion when you're certain
  else if ((error as Error).message.includes("network")) {
    console.error("Network-related error");
  }
  // Fallback
  else {
    console.error("Unknown error:", error);
  }
}
```

### Custom Error Types

TypeScript allows creating custom error classes that extend the base `Error` class, enabling application-specific error hierarchies.

**Key Points**

- Custom errors help categorize domain-specific exceptions
- Extend the base `Error` class or specific error subclasses
- Include additional properties relevant to your application
- Proper `super()` call preserves the error stack trace

```typescript
// Base custom error class
class ApplicationError extends Error {
  constructor(message: string) {
    super(message);
    this.name = "ApplicationError";
    
    // This line is necessary for proper stack trace in TypeScript
    Object.setPrototypeOf(this, ApplicationError.prototype);
  }
}

// Domain-specific errors
class ValidationError extends ApplicationError {
  constructor(
    message: string,
    public field?: string
  ) {
    super(message);
    this.name = "ValidationError";
    
    Object.setPrototypeOf(this, ValidationError.prototype);
  }
}

class DatabaseError extends ApplicationError {
  constructor(
    message: string,
    public code?: string
  ) {
    super(message);
    this.name = "DatabaseError";
    
    Object.setPrototypeOf(this, DatabaseError.prototype);
  }
}

// Using custom errors
function validateUser(user: any): void {
  if (!user.name) {
    throw new ValidationError("Name is required", "name");
  }
  
  if (!user.email) {
    throw new ValidationError("Email is required", "email");
  }
}

try {
  validateUser({ name: "John" });
} catch (error) {
  if (error instanceof ValidationError) {
    console.error(`Validation error in field '${error.field}':`, error.message);
  } else if (error instanceof ApplicationError) {
    console.error("Application error:", error.message);
  } else {
    console.error("Unknown error:", error);
  }
}
```

### Type-Safe Error Factory

Creating factory functions for errors can help maintain consistency and improve error handling in larger applications.

**Key Points**

- Error factories create consistently structured errors
- They can include additional context and metadata
- Factories can be type-safe with generics

```typescript
// Error codes enum
enum ErrorCode {
  VALIDATION = "VAL_ERROR",
  NETWORK = "NET_ERROR",
  AUTHENTICATION = "AUTH_ERROR",
  UNKNOWN = "UNKNOWN_ERROR"
}

// Error interface
interface AppError {
  code: ErrorCode;
  message: string;
  timestamp: Date;
  details?: Record<string, unknown>;
}

// Error factory function
function createError(
  code: ErrorCode, 
  message: string, 
  details?: Record<string, unknown>
): Error & AppError {
  const error = new Error(message) as Error & AppError;
  error.code = code;
  error.timestamp = new Date();
  error.details = details;
  return error;
}

// Usage
try {
  const userInput = "";
  if (!userInput) {
    throw createError(
      ErrorCode.VALIDATION,
      "User input cannot be empty",
      { field: "username", value: userInput }
    );
  }
} catch (err) {
  const error = err as AppError;
  console.error(`[${error.code}] ${error.message}`);
  
  if (error.details) {
    console.error("Details:", error.details);
  }
}
```

### Error Propagation Patterns

Several patterns exist for propagating and handling errors in TypeScript applications, each with its own use cases and benefits.

**Key Points**

- Choose propagation patterns based on your application's needs
- Consider errors as values for synchronous operations
- Use exceptions (throw/catch) for truly exceptional conditions
- Promises and async/await simplify asynchronous error handling

#### Bubbling Up Errors

```typescript
function validateEmail(email: string): void {
  if (!email.includes("@")) {
    throw new ValidationError("Invalid email format", "email");
  }
}

function validateUser(user: any): void {
  try {
    validateEmail(user.email);
  } catch (error) {
    // Add more context and rethrow
    if (error instanceof ValidationError) {
      throw new ValidationError(
        `User validation failed: ${error.message}`,
        error.field
      );
    }
    throw error; // Rethrow other errors unchanged
  }
}

// Higher level function
function createUser(userData: any): void {
  try {
    validateUser(userData);
    // Save user to database...
    console.log("User created successfully");
  } catch (error) {
    if (error instanceof ValidationError) {
      console.error(`Validation failed: ${error.message} (${error.field})`);
    } else {
      console.error("Failed to create user:", error);
    }
  }
}
```

### Errors as Return Values (Result Type Pattern)

Sometimes, especially for non-exceptional errors, returning error states as values can be preferable to throwing exceptions.

**Key Points**

- Makes error handling explicit and visible
- Avoids the performance cost of exceptions
- Works well with functional programming approaches
- Requires discipline to check error states

```typescript
// Result type for operations that might fail
interface Result<T, E> {
  success: boolean;
  value?: T;
  error?: E;
}

// Helper functions to create results
function success<T, E>(value: T): Result<T, E> {
  return { success: true, value };
}

function failure<T, E>(error: E): Result<T, E> {
  return { success: false, error };
}

// Using Result pattern
function divide(a: number, b: number): Result<number, string> {
  if (b === 0) {
    return failure("Division by zero");
  }
  return success(a / b);
}

// Pattern matching style consumption
function calculateAndPrint(a: number, b: number): void {
  const result = divide(a, b);
  
  if (result.success) {
    console.log(`Result: ${result.value}`);
  } else {
    console.error(`Error: ${result.error}`);
  }
}

// Using with map-like operations
function displayResult<T, E>(result: Result<T, E>): void {
  if (result.success && result.value !== undefined) {
    console.log("Success:", result.value);
  } else {
    console.error("Error:", result.error);
  }
}

// Chain of operations with results
function processValue(input: string): Result<number, string> {
  // Try to parse
  const parsedResult = parseInput(input);
  if (!parsedResult.success) {
    return parsedResult; // Forward the error
  }
  
  // Try to process if parsing succeeded
  const processedResult = processNumber(parsedResult.value!);
  if (!processedResult.success) {
    return processedResult; // Forward the error
  }
  
  // Final calculation
  return success(processedResult.value! * 2);
}

function parseInput(input: string): Result<number, string> {
  const num = Number(input);
  return isNaN(num) ? failure("Invalid number") : success(num);
}

function processNumber(num: number): Result<number, string> {
  return num > 0 ? success(num) : failure("Must be positive");
}
```

### Async Error Handling

TypeScript works seamlessly with Promises and async/await for asynchronous error handling.

**Key Points**

- Promises have built-in error handling via `.catch()`
- `async/await` makes asynchronous error handling look synchronous with try/catch
- TypeScript provides type safety for Promise rejections

```typescript
// Promise-based error handling
function fetchUserData(userId: string): Promise<any> {
  return fetch(`/api/users/${userId}`)
    .then(response => {
      if (!response.ok) {
        throw new Error(`HTTP error: ${response.status}`);
      }
      return response.json();
    });
}

// Using Promises with error handling
fetchUserData("123")
  .then(user => {
    console.log("User data:", user);
  })
  .catch(error => {
    console.error("Failed to fetch user:", error);
  })
  .finally(() => {
    console.log("Fetch operation complete");
  });

// Using async/await with try/catch
async function getUserDetails(userId: string): Promise<void> {
  try {
    const user = await fetchUserData(userId);
    console.log("User details:", user);
  } catch (error) {
    if (error instanceof TypeError) {
      console.error("Network error:", error.message);
    } else if (error instanceof Error) {
      console.error("Error fetching user:", error.message);
    } else {
      console.error("Unknown error:", error);
    }
  }
}
```

### Error Boundaries for Async Operations

Creating error boundaries helps contain and manage errors in asynchronous operations.

**Key Points**

- Higher-order functions can create error handling wrappers
- Centralized error handling simplifies error management
- Type-safe error boundaries improve reliability

```typescript
// Higher-order function for error boundary
function withErrorHandling<T, Args extends any[]>(
  fn: (...args: Args) => Promise<T>
): (...args: Args) => Promise<T> {
  return async (...args: Args): Promise<T> => {
    try {
      return await fn(...args);
    } catch (error) {
      // Centralized error logging/handling
      if (error instanceof NetworkError) {
        console.error(`Network error: ${error.message}`);
        // Maybe retry the operation
      } else if (error instanceof AuthError) {
        console.error(`Auth error: ${error.message}`);
        // Maybe redirect to login page
      } else {
        console.error("Operation failed:", error);
      }
      throw error; // Rethrow after handling
    }
  };
}

// Using the error boundary
const safeGetUser = withErrorHandling(async (userId: string) => {
  const response = await fetch(`/api/users/${userId}`);
  if (!response.ok) {
    if (response.status === 401) {
      throw new AuthError("Not authenticated");
    }
    throw new Error(`Failed to get user: ${response.statusText}`);
  }
  return response.json();
});

// Usage
async function displayUserProfile(userId: string): Promise<void> {
  try {
    const user = await safeGetUser(userId);
    console.log("User:", user);
  } catch {
    // Minimal error handling here as most is done in the boundary
    console.log("Could not display user profile");
  }
}
```

### Error Aggregation

Sometimes it's useful to collect multiple errors before reporting them, especially in validation scenarios.

**Key Points**

- Collect errors instead of failing fast
- Report all issues at once for better user experience
- Useful for form validation and data processing

```typescript
class ValidationErrors extends Error {
  constructor(public errors: Record<string, string[]>) {
    super("Validation failed");
    this.name = "ValidationErrors";
    Object.setPrototypeOf(this, ValidationErrors.prototype);
  }

  hasErrors(): boolean {
    return Object.keys(this.errors).length > 0;
  }
  
  addError(field: string, message: string): void {
    if (!this.errors[field]) {
      this.errors[field] = [];
    }
    this.errors[field].push(message);
  }
  
  toString(): string {
    return Object.entries(this.errors)
      .map(([field, messages]) => `${field}: ${messages.join(", ")}`)
      .join("\n");
  }
}

function validateForm(form: Record<string, any>): void {
  const errors = new ValidationErrors({});
  
  // Validate name
  if (!form.name) {
    errors.addError("name", "Name is required");
  } else if (form.name.length < 2) {
    errors.addError("name", "Name must be at least 2 characters");
  }
  
  // Validate email
  if (!form.email) {
    errors.addError("email", "Email is required");
  } else if (!form.email.includes("@")) {
    errors.addError("email", "Email must be valid");
  }
  
  // Validate age
  if (form.age !== undefined) {
    const age = Number(form.age);
    if (isNaN(age)) {
      errors.addError("age", "Age must be a number");
    } else if (age < 18) {
      errors.addError("age", "Must be at least 18 years old");
    }
  }
  
  // Throw if any errors exist
  if (errors.hasErrors()) {
    throw errors;
  }
}

// Usage
try {
  validateForm({
    name: "J",
    email: "not-an-email",
    age: "fifteen"
  });
  console.log("Form is valid");
} catch (error) {
  if (error instanceof ValidationErrors) {
    console.error("Form validation failed:");
    console.error(error.toString());
    // Could return errors to display in UI
  } else {
    console.error("Unexpected error:", error);
  }
}
```

### Error Handling with Functional Programming

Functional programming patterns like monads can provide elegant error handling in TypeScript.

**Key Points**

- Option/Maybe types handle the absence of values
- Either/Result types separate success and failure paths
- These patterns reduce null checks and try/catch blocks
- Libraries like fp-ts provide these abstractions

```typescript
// Simple Either implementation
type Either<L, R> = Left<L> | Right<R>;

class Left<L> {
  readonly tag: 'left' = 'left';
  constructor(readonly value: L) {}
  
  isLeft(): this is Left<L> {
    return true;
  }
  
  isRight(): this is never {
    return false;
  }
  
  map<R2>(_fn: (r: never) => R2): Either<L, R2> {
    return this as unknown as Left<L>;
  }
  
  chain<L2, R2>(_fn: (r: never) => Either<L2, R2>): Either<L | L2, R2> {
    return this as unknown as Left<L>;
  }
}

class Right<R> {
  readonly tag: 'right' = 'right';
  constructor(readonly value: R) {}
  
  isLeft(): this is never {
    return false;
  }
  
  isRight(): this is Right<R> {
    return true;
  }
  
  map<R2>(fn: (r: R) => R2): Either<never, R2> {
    return new Right(fn(this.value));
  }
  
  chain<L2, R2>(fn: (r: R) => Either<L2, R2>): Either<L2, R2> {
    return fn(this.value);
  }
}

const left = <L, R = never>(l: L): Either<L, R> => new Left(l);
const right = <R, L = never>(r: R): Either<L, R> => new Right(r);

// Using Either for error handling
function divide(a: number, b: number): Either<string, number> {
  if (b === 0) {
    return left('Division by zero');
  }
  return right(a / b);
}

function safeParse(s: string): Either<string, number> {
  const n = Number(s);
  return isNaN(n) ? left('Not a number') : right(n);
}

// Chain operations with proper error handling
function calculateAverage(values: string[]): Either<string, number> {
  if (values.length === 0) {
    return left('Cannot calculate average of empty array');
  }
  
  // Parse all values
  const numbers: number[] = [];
  for (const value of values) {
    const result = safeParse(value);
    if (result.isLeft()) {
      return result;
    }
    numbers.push(result.value);
  }
  
  // Calculate sum
  const sum = numbers.reduce((a, b) => a + b, 0);
  
  // Calculate average
  return right(sum / numbers.length);
}

// Usage
const result = calculateAverage(['1', '2', '3', '4']);

if (result.isRight()) {
  console.log('Average:', result.value);
} else {
  console.error('Error:', result.value);
}

// Error case
const badResult = calculateAverage(['1', 'two', '3']);

if (badResult.isRight()) {
  console.log('Average:', badResult.value);
} else {
  console.error('Error:', badResult.value); // "Not a number"
}
```

### Error Handling Best Practices in TypeScript

Adopting consistent error handling patterns across your application ensures robustness and maintainability.

**Key Points**

- Be specific about error types and messages
- Document error cases in function signatures and comments
- Handle errors at the appropriate level
- Log errors with sufficient context
- Avoid suppressing errors without handling them

```typescript
/**
 * Fetches user data by ID
 * @param userId - The user ID to fetch
 * @returns Promise resolving to user data
 * @throws {NotFoundError} When user doesn't exist
 * @throws {AuthError} When not authenticated
 * @throws {ApiError} For other API errors
 */
async function fetchUser(userId: string): Promise<User> {
  try {
    const response = await fetch(`/api/users/${userId}`);
    
    if (response.status === 404) {
      throw new NotFoundError(`User with ID ${userId} not found`);
    }
    
    if (response.status === 401) {
      throw new AuthError("Not authenticated");
    }
    
    if (!response.ok) {
      throw new ApiError(`API error: ${response.statusText}`, response.status);
    }
    
    return await response.json();
  } catch (error) {
    // Add context to the error
    if (error instanceof Error && !(error instanceof NotFoundError) && 
        !(error instanceof AuthError) && !(error instanceof ApiError)) {
      throw new ApiError(`Error fetching user ${userId}: ${error.message}`);
    }
    throw error; // Re-throw known errors
  }
}

// Usage with proper error handling
async function displayUserProfile(userId: string): Promise<void> {
  try {
    const user = await fetchUser(userId);
    renderUserProfile(user);
  } catch (error) {
    if (error instanceof NotFoundError) {
      showNotFoundPage();
    } else if (error instanceof AuthError) {
      redirectToLogin();
    } else {
      showErrorMessage("Failed to load user profile");
      // Log detailed error for debugging
      logError("Profile load failed", { userId, error });
    }
  }
}
```

### Error Monitoring and Reporting

In production applications, properly catching, logging, and reporting errors is crucial.

**Key Points**

- Centralize error logging and reporting
- Include context information with errors
- Consider using error monitoring services
- Filter sensitive information before logging

```typescript
// Error reporting service abstraction
class ErrorReporter {
  private static instance: ErrorReporter;
  
  private constructor() {
    // Initialize error reporting service
  }
  
  static getInstance(): ErrorReporter {
    if (!ErrorReporter.instance) {
      ErrorReporter.instance = new ErrorReporter();
    }
    return ErrorReporter.instance;
  }
  
  captureException(error: unknown, context?: Record<string, unknown>): void {
    if (error instanceof Error) {
      this.sendToService(error, this.sanitizeContext(context));
    } else {
      this.sendToService(new Error(String(error)), this.sanitizeContext(context));
    }
  }
  
  private sendToService(error: Error, context?: Record<string, unknown>): void {
    // In a real app, send to Sentry, LogRocket, etc.
    console.error("Error captured:", error);
    if (context) {
      console.error("Context:", context);
    }
  }
  
  private sanitizeContext(context?: Record<string, unknown>): Record<string, unknown> | undefined {
    if (!context) return undefined;
    
    // Deep clone and sanitize sensitive data
    const sanitized = JSON.parse(JSON.stringify(context));
    
    // Remove sensitive fields
    if (sanitized.password) sanitized.password = "***";
    if (sanitized.creditCard) sanitized.creditCard = "***";
    
    return sanitized;
  }
}

// Global error handler for uncaught exceptions
function setupGlobalErrorHandlers(): void {
  const reporter = ErrorReporter.getInstance();
  
  // Uncaught exceptions
  window.addEventListener('error', (event) => {
    reporter.captureException(event.error, {
      message: event.message,
      source: event.filename,
      lineNumber: event.lineno,
      columnNumber: event.colno
    });
  });
  
  // Unhandled promise rejections
  window.addEventListener('unhandledrejection', (event) => {
    reporter.captureException(event.reason, {
      type: 'unhandled_promise_rejection'
    });
  });
}

// Usage
try {
  const result = riskyOperation();
  processResult(result);
} catch (error) {
  ErrorReporter.getInstance().captureException(error, {
    operation: 'riskyOperation',
    user: currentUser.id
  });
  
  // Show user-friendly message
  showErrorToUser("Something went wrong. Our team has been notified.");
}
```

---

## Debugging TypeScript

### Introduction to TypeScript Debugging

Debugging TypeScript applications requires understanding both the TypeScript compilation process and the runtime behavior of the resulting JavaScript. TypeScript's static type system helps prevent many bugs during development, but runtime debugging is still essential for resolving complex issues, understanding application flow, and optimizing performance. Effective debugging tools and strategies can significantly speed up development and improve code quality.

### Source Maps

Source maps are files that map compiled JavaScript code back to the original TypeScript source, enabling you to debug TypeScript directly even though the browser or Node.js is running JavaScript.

**How Source Maps Work**

Source maps create a relationship between:

1. The compiled JavaScript files that run in the browser/Node.js
2. The original TypeScript source files you wrote

This mapping allows debuggers to show you the TypeScript code instead of the transpiled JavaScript, making debugging much more intuitive.

**Generating Source Maps**

Enable source maps in your `tsconfig.json`:

```json
{
  "compilerOptions": {
    "sourceMap": true,
    // For better debugging experience with inline source maps:
    // "inlineSourceMap": true,
    "inlineSources": true
  }
}
```

For production, you might want to disable source maps or use a different configuration:

```json
{
  "compilerOptions": {
    "sourceMap": false,
    // Or for production builds with protected but debuggable source:
    // "sourceMap": true,
    // "inlineSources": false
  }
}
```

**Source Map Configuration Options**

- `sourceMap`: Generates separate `.js.map` files
- `inlineSourceMap`: Embeds source map information in the JavaScript files
- `inlineSources`: Includes the original TypeScript code within the source map
- `mapRoot`: Specifies the location where debuggers should find map files
- `sourceRoot`: Specifies the location where debuggers should find the TypeScript files

**Webpack Source Map Configuration**

If you're using Webpack, you can configure the quality and type of source maps:

```javascript
// webpack.config.js
module.exports = {
  mode: 'development',
  devtool: 'source-map', // or 'cheap-module-source-map' for faster builds
  // For production:
  // devtool: 'hidden-source-map', // creates source maps but doesn't reference them
};
```

Common `devtool` options for TypeScript projects:

- `source-map`: Full source maps (separate files)
- `eval-source-map`: Faster rebuilds, good for development
- `cheap-module-source-map`: Faster builds, less detailed
- `hidden-source-map`: Generates source maps but doesn't reference them in the bundle (good for error reporting in production)

**Verifying Source Maps**

To verify source maps are working:

1. Open your browser developer tools
2. Navigate to the Sources panel (Chrome) or Debugger panel (Firefox)
3. Look for a "webpack://" or similar section containing your TypeScript files
4. Set a breakpoint in a TypeScript file and confirm it works when that code executes

**Common Source Map Issues**

1. **404 Errors for map files**: Check file paths and ensure your server is configured to serve `.map` files
2. **Incorrect source locations**: Verify your `sourceRoot` and `mapRoot` settings
3. **Seeing JavaScript instead of TypeScript**: Make sure source maps are enabled in the browser devtools
4. **Source maps not updated**: Clear browser cache or use cache-busting techniques

**Protecting Source Maps in Production**

For production environments, consider:

1. **Not publishing source maps publicly**: Configure your server to restrict access
2. **Using hidden source maps**: Generate them but don't reference them in your JS files
3. **Generating source maps only for error tracking**: Use tools like Sentry that can process source maps securely

### Debugging in VS Code

Visual Studio Code offers excellent integrated debugging support for TypeScript in both browser and Node.js environments.

**Setting Up VS Code for TypeScript Debugging**

1. Install the necessary extensions:
    
    - JavaScript Debugger (built into VS Code)
    - Debugger for Chrome (for browser debugging)
2. Create a `launch.json` configuration file:
    
    - Click the Debug icon in the sidebar
    - Click "create a launch.json file"
    - Select the environment (Node.js or Chrome)

**Debugging Node.js TypeScript Applications**

Basic `launch.json` configuration for Node.js:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "type": "node",
      "request": "launch",
      "name": "Debug TypeScript",
      "program": "${workspaceFolder}/src/index.ts",
      "preLaunchTask": "tsc: build - tsconfig.json",
      "outFiles": ["${workspaceFolder}/dist/**/*.js"],
      "sourceMaps": true,
      "resolveSourceMapLocations": [
        "${workspaceFolder}/**",
        "!**/node_modules/**"
      ],
      "smartStep": true,
      "internalConsoleOptions": "openOnSessionStart"
    }
  ]
}
```

**For ts-node users**:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "type": "node",
      "request": "launch",
      "name": "Debug with ts-node",
      "runtimeArgs": ["-r", "ts-node/register"],
      "args": ["${workspaceFolder}/src/index.ts"],
      "sourceMaps": true
    }
  ]
}
```

**Debugging TypeScript in the Browser**

Configuration for Chrome:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "type": "chrome",
      "request": "launch",
      "name": "Launch Chrome",
      "url": "http://localhost:3000",
      "webRoot": "${workspaceFolder}",
      "sourceMaps": true,
      "sourceMapPathOverrides": {
        "webpack:///./*": "${webRoot}/*",
        "webpack:///src/*": "${webRoot}/src/*"
      }
    }
  ]
}
```

**For React applications with Create React App**:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "type": "chrome",
      "request": "launch",
      "name": "Debug React",
      "url": "http://localhost:3000",
      "webRoot": "${workspaceFolder}",
      "sourceMapPathOverrides": {
        "webpack:///src/*": "${webRoot}/src/*"
      }
    }
  ]
}
```

**Advanced VS Code Debugging Features**

1. **Conditional Breakpoints**:
    
    - Right-click on a breakpoint
    - Select "Edit Breakpoint"
    - Enter a condition like `count > 5`
2. **Logpoints** (non-pausing breakpoints that log information):
    
    - Right-click on the gutter (where breakpoints appear)
    - Select "Add Logpoint"
    - Enter a message like `Count is {count}` (variables in curly braces)
3. **Data Inspection**:
    
    - Hover over variables to see values
    - Use the Debug Console to evaluate expressions
    - Add watches for variables you want to monitor
4. **Debug Console**:
    
    - Access the Debug Console during a debug session
    - Evaluate expressions and call functions
    - Access variables in current scope

**VS Code Debugging Keyboard Shortcuts**

- `F5`: Start debugging
- `Shift+F5`: Stop debugging
- `F9`: Toggle breakpoint
- `F10`: Step over
- `F11`: Step into
- `Shift+F11`: Step out
- `Ctrl+F5` (Windows/Linux) or `Cmd+F5` (Mac): Run without debugging

**Debugging with Jest in VS Code**

For Jest test debugging:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "type": "node",
      "request": "launch",
      "name": "Debug Jest Tests",
      "program": "${workspaceFolder}/node_modules/.bin/jest",
      "args": ["--runInBand"],
      "console": "integratedTerminal",
      "internalConsoleOptions": "neverOpen",
      "disableOptimisticBPs": true,
      "windows": {
        "program": "${workspaceFolder}/node_modules/jest/bin/jest"
      }
    }
  ]
}
```

### Chrome DevTools with TypeScript

Chrome DevTools offers powerful debugging capabilities that work well with TypeScript when source maps are properly configured.

**Setting Up Chrome DevTools for TypeScript**

1. Open DevTools (`F12` or `Ctrl+Shift+I` / `Cmd+Option+I`)
2. Go to Settings (gear icon) > Preferences
3. Under Sources, enable "Enable JavaScript source maps"
4. Optional: Enable "Enable CSS source maps"

**Loading TypeScript Files in DevTools**

With source maps enabled, you should see your TypeScript files under:

- Sources tab > Page > webpack:// (for webpack projects)
- Sources tab > Page > [your domain] (for simpler setups)

If your TypeScript files don't appear, check:

1. Source maps are correctly generated
2. The server is serving the `.map` files
3. The paths in the source maps match your project structure

**Chrome DevTools Debugging Features**

**Breakpoints**:

- Click on the line number to set a breakpoint
- Right-click on the line number for advanced breakpoint options:
    - Conditional breakpoints
    - Logpoints (Console messages without stopping)

**Breakpoint Types**:

- **Line breakpoints**: Break at specific lines
- **DOM breakpoints**: Break when DOM elements change
- **XHR/Fetch breakpoints**: Break when requests are made
- **Event listener breakpoints**: Break when specific events fire
- **Exception breakpoints**: Break on thrown exceptions

**Debugging Controls**:

- Resume script execution: Continue until next breakpoint
- Step over: Execute current line and move to next line
- Step into: Enter function calls
- Step out: Complete current function and return to caller
- Deactivate breakpoints: Run with breakpoints temporarily disabled

**Watch Expressions**:

- Add expressions to monitor in the Watch panel
- Watches are evaluated at each step

**Call Stack**:

- View the function call hierarchy
- Click on stack frames to navigate between different points in execution

**Debugging Asynchronous Code**:

For promises and async/await:

1. Enable "Async" in the call stack panel to see async call chains
2. Use the "Async" option when setting breakpoints for better async debugging

**Performance Profiling**:

1. Go to the Performance tab
2. Click Record
3. Perform actions in your app
4. Stop recording to see a breakdown of execution time

The source maps will help you see TypeScript code in the profiles rather than compiled JavaScript.

**Memory Analysis**:

1. Go to the Memory tab
2. Take a heap snapshot
3. Analyze memory usage
4. Look for memory leaks through comparison snapshots

**TypeScript-specific DevTools Tricks**:

1. **Type checking in Console**: TypeScript's types are erased at runtime, but you can check types during debugging:
    
    ```typescript
    // In your code
    console.log('Variable type check:', { myVar });
    ```
    
2. **Logpoints for non-invasive debugging**:
    
    - Right-click line number > Add logpoint
    - Use `{variableName}` syntax to output values
    - Doesn't require code changes
3. **Blackboxing transpiled code**:
    
    - Go to DevTools Settings > Blackboxing
    - Add patterns for generated code (e.g., `/node_modules/`, `/dist/`)
    - This keeps the debugger focused on your source code

### Logging Strategies

Effective logging is a complementary approach to interactive debugging that helps track application behavior over time.

**Basic TypeScript Logging**

Simple console logging:

```typescript
function processOrder(order: Order): void {
  console.log('Processing order:', order.id);
  try {
    // Order processing logic
    console.log('Order processed successfully');
  } catch (error) {
    console.error('Failed to process order:', error);
  }
}
```

**Creating a Simple Logger**

Basic TypeScript logger with levels:

```typescript
enum LogLevel {
  DEBUG,
  INFO,
  WARN,
  ERROR
}

class Logger {
  constructor(private name: string, private level: LogLevel = LogLevel.INFO) {}

  debug(message: string, ...data: any[]): void {
    if (this.level <= LogLevel.DEBUG) {
      console.debug(`[${this.name}] DEBUG:`, message, ...data);
    }
  }

  info(message: string, ...data: any[]): void {
    if (this.level <= LogLevel.INFO) {
      console.info(`[${this.name}] INFO:`, message, ...data);
    }
  }

  warn(message: string, ...data: any[]): void {
    if (this.level <= LogLevel.WARN) {
      console.warn(`[${this.name}] WARN:`, message, ...data);
    }
  }

  error(message: string, ...data: any[]): void {
    if (this.level <= LogLevel.ERROR) {
      console.error(`[${this.name}] ERROR:`, message, ...data);
    }
  }
}

// Usage
const userLogger = new Logger('UserService', LogLevel.DEBUG);
userLogger.debug('User login attempt', { userId: '123' });
```

**Using Structured Logging**

Structured logging makes logs searchable and analyzable:

```typescript
interface LogEntry {
  timestamp: string;
  level: string;
  component: string;
  message: string;
  data?: Record<string, any>;
  error?: {
    message: string;
    stack?: string;
  };
}

class StructuredLogger {
  constructor(private component: string) {}

  private log(level: string, message: string, data?: any, error?: Error): void {
    const entry: LogEntry = {
      timestamp: new Date().toISOString(),
      level,
      component: this.component,
      message
    };

    if (data !== undefined) {
      entry.data = data;
    }

    if (error) {
      entry.error = {
        message: error.message,
        stack: error.stack
      };
    }

    // In production, you might want to send this to a logging service
    console.log(JSON.stringify(entry));
  }

  debug(message: string, data?: any): void {
    this.log('DEBUG', message, data);
  }

  info(message: string, data?: any): void {
    this.log('INFO', message, data);
  }

  warn(message: string, data?: any): void {
    this.log('WARN', message, data);
  }

  error(message: string, error?: Error, data?: any): void {
    this.log('ERROR', message, data, error);
  }
}
```

**Popular Logging Libraries**

Several excellent logging libraries exist for TypeScript projects:

1. **Winston**:

```typescript
import winston from 'winston';

const logger = winston.createLogger({
  level: 'info',
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.json()
  ),
  transports: [
    new winston.transports.File({ filename: 'error.log', level: 'error' }),
    new winston.transports.File({ filename: 'combined.log' })
  ]
});

// In development, also log to console
if (process.env.NODE_ENV !== 'production') {
  logger.add(new winston.transports.Console({
    format: winston.format.combine(
      winston.format.colorize(),
      winston.format.simple()
    )
  }));
}

// Usage
logger.info('User logged in', { userId: '123' });
```

2. **Pino**:

```typescript
import pino from 'pino';

const logger = pino({
  level: process.env.LOG_LEVEL || 'info',
  serializers: {
    err: pino.stdSerializers.err
  }
});

// Usage
logger.info({ userId: '123' }, 'User logged in');
logger.error({ err: new Error('Failed'), userId: '123' }, 'Login failed');
```

3. **debug**:

```typescript
import debug from 'debug';

// Create namespaced debuggers
const debugAuth = debug('app:auth');
const debugApi = debug('app:api');
const debugDb = debug('app:db');

// Usage
debugAuth('User %s logged in', userId);
debugApi('API request received: %O', request);
debugDb('Database query: %s', query);

// Enable via DEBUG=app:* environment variable
```

**Context-Preserving Logging**

For async operations, preserve context in logs:

```typescript
class ContextLogger {
  private requestId: string;
  
  constructor(requestId: string) {
    this.requestId = requestId;
  }
  
  info(message: string, data?: any): void {
    console.log(JSON.stringify({
      timestamp: new Date().toISOString(),
      level: 'INFO',
      requestId: this.requestId,
      message,
      data
    }));
  }
  
  // Other log levels...
}

// Usage in an Express middleware
import { v4 as uuidv4 } from 'uuid';

app.use((req, res, next) => {
  const requestId = uuidv4();
  res.locals.logger = new ContextLogger(requestId);
  res.locals.logger.info('Request started', { 
    path: req.path,
    method: req.method
  });
  next();
});
```

**Logging Decorators with TypeScript**

Decorators provide a clean way to add logging:

```typescript
// Method decorator for logging
function Log(level: 'debug' | 'info' | 'warn' | 'error' = 'info') {
  return function (
    target: any,
    propertyKey: string,
    descriptor: PropertyDescriptor
  ) {
    const originalMethod = descriptor.value;
    
    descriptor.value = function (...args: any[]) {
      const className = target.constructor.name;
      console[level](`${level.toUpperCase()} [${className}.${propertyKey}] Called with:`, args);
      
      try {
        const result = originalMethod.apply(this, args);
        
        // Handle promises
        if (result instanceof Promise) {
          return result
            .then(value => {
              console[level](`${level.toUpperCase()} [${className}.${propertyKey}] Resolved:`, value);
              return value;
            })
            .catch(error => {
              console.error(`ERROR [${className}.${propertyKey}] Error:`, error);
              throw error;
            });
        }
        
        console[level](`${level.toUpperCase()} [${className}.${propertyKey}] Returned:`, result);
        return result;
      } catch (error) {
        console.error(`ERROR [${className}.${propertyKey}] Error:`, error);
        throw error;
      }
    };
    
    return descriptor;
  };
}

// Usage
class UserService {
  @Log('info')
  async getUserById(id: string): Promise<User> {
    // Implementation...
    return user;
  }
}
```

**Advanced Logging Patterns**

1. **Sampling Logs** - Reduce volume by sampling frequent events:

```typescript
class SampledLogger {
  private samplingRates: Record<string, number> = {};
  
  constructor(samplingRates: Record<string, number>) {
    this.samplingRates = samplingRates;
  }
  
  log(category: string, message: string, data?: any): void {
    const rate = this.samplingRates[category] || 1.0;
    
    if (Math.random() <= rate) {
      console.log({
        timestamp: new Date().toISOString(),
        category,
        message,
        data,
        sampled: rate < 1.0
      });
    }
  }
}

// Sample 10% of db queries, 100% of errors
const logger = new SampledLogger({
  'db.query': 0.1,
  'error': 1.0
});
```

2. **Circuit Breaker for Error Logs** - Prevent log flooding:

```typescript
class CircuitBreakerLogger {
  private errorCounts: Record<string, number> = {};
  private lastReported: Record<string, number> = {};
  private threshold: number;
  private windowMs: number;
  
  constructor(threshold: number = 5, windowMs: number = 60000) {
    this.threshold = threshold;
    this.windowMs = windowMs;
  }
  
  error(category: string, message: string, error?: Error): void {
    const now = Date.now();
    
    if (!this.errorCounts[category]) {
      this.errorCounts[category] = 0;
      this.lastReported[category] = 0;
    }
    
    this.errorCounts[category]++;
    
    if (this.errorCounts[category] <= this.threshold ||
        now - this.lastReported[category] >= this.windowMs) {
      
      console.error({
        timestamp: new Date().toISOString(),
        category,
        message,
        error: error ? { message: error.message, stack: error.stack } : undefined,
        count: this.errorCounts[category]
      });
      
      this.lastReported[category] = now;
      
      if (this.errorCounts[category] === this.threshold) {
        console.warn(`Suppressing further logs of type ${category} for ${this.windowMs}ms`);
      }
    }
    
    // Reset counter after window
    setTimeout(() => {
      this.errorCounts[category] = 0;
    }, this.windowMs);
  }
}
```

### Integration Testing with TypeScript

TypeScript can be used effectively in debug-oriented testing strategies.

**Jest with TypeScript**

Configure Jest for TypeScript debugging:

```javascript
// jest.config.js
module.exports = {
  preset: 'ts-jest',
  testEnvironment: 'node',
  roots: ['<rootDir>/src'],
  transform: {
    '^.+\\.tsx?$': 'ts-jest'
  },
  collectCoverage: true,
  coverageDirectory: 'coverage',
  collectCoverageFrom: [
    'src/**/*.{ts,tsx}',
    '!src/**/*.d.ts'
  ]
};
```

Writing debuggable tests:

```typescript
import { UserService } from '../services/user.service';

describe('UserService', () => {
  let userService: UserService;
  
  beforeEach(() => {
    userService = new UserService();
    // Add debug information in beforeEach
    console.log('Test setup complete', { service: userService });
  });
  
  test('should create a user', async () => {
    const userData = { name: 'Test User', email: 'test@example.com' };
    
    // Add debug point
    console.log('Creating user with data:', userData);
    
    const user = await userService.createUser(userData);
    
    // Debug verification
    console.log('Created user:', user);
    
    expect(user).toHaveProperty('id');
    expect(user.name).toBe(userData.name);
  });
});
```

**Debugging specific Jest tests**:

```bash
# Run only specific test file with NODE_OPTIONS for debugging
NODE_OPTIONS=--inspect-brk jest --runInBand path/to/test.spec.ts
```

### Best Practices for TypeScript Debugging

1. **Organize Code for Debuggability**:
    
    - Keep functions small and focused
    - Use meaningful variable names
    - Use type annotations to help identify issues
2. **Use TypeScript's Strict Mode**:
    
    ```json
    {
      "compilerOptions": {
        "strict": true
      }
    }
    ```
    
3. **Enable Additional Type Checking**:
    
    ```json
    {
      "compilerOptions": {
        "noImplicitAny": true,
        "strictNullChecks": true,
        "strictFunctionTypes": true,
        "strictBindCallApply": true,
        "strictPropertyInitialization": true,
        "noImplicitThis": true,
        "alwaysStrict": true,
        "noUnusedLocals": true,
        "noUnusedParameters": true,
        "noImplicitReturns": true,
        "noFallthroughCasesInSwitch": true
      }
    }
    ```
    
4. **Handle Errors Properly**:
    
    ```typescript
    try {
      const result = await riskyOperation();
      return result;
    } catch (error) {
      // Enhance error with context
      if (error instanceof Error) {
        console.error('Operation failed:', {
          operation: 'riskyOperation',
          error: {
            message: error.message,
            stack: error.stack
          },
          context: { /* relevant context */ }
        });
      }
      throw error;
    }
    ```
    
5. **Create Debug-Friendly Objects**:
    
    ```typescript
    class DebugFriendly {
      [Symbol.for('nodejs.util.inspect.custom')]() {
        // Return a simplified representation for console.log
        return {
          id: this.id,
          name: this.name,
          // Include important properties, exclude verbose ones
        };
      }
      
      toString() {
        return `${this.constructor.name}(${this.id})`;
      }
    }
    ```
    
6. **Use Custom Type Guards**:
    
    ```typescript
    // Type guard to narrow down error types
    function isApiError(error: unknown): error is ApiError {
      return typeof error === 'object' && 
             error !== null && 
             'statusCode' in error &&
             'apiMessage' in error;
    }
    
    try {
      await apiCall();
    } catch (error) {
      if (isApiError(error)) {
        // TypeScript knows this is an ApiError
        console.error(`API Error ${error.statusCode}: ${error.apiMessage}`);
      } else if (error instanceof Error) {
        console.error('Standard error:', error.message);
      } else {
        console.error('Unknown error:', error);
      }
    }
    ```
    
7. **Debug Configuration Templates**:
    
    Create a `.vscode/launch.json.template` with commented options:
    
    ```json
    {
      "version": "0.2.0",
      "configurations": [
        {
          "name": "Debug Current Test File",
          "type": "node",
          "request": "launch",
          "program": "${workspaceFolder}/node_modules/.bin/jest",
          "args": ["${relativeFile}", "--coverage=false"],
          "console": "integratedTerminal",
          "internalConsoleOptions": "neverOpen"
        },
        // More configurations with explanatory comments...
      ]
    }
    ```
    
8. **Document Debugging Process**:
    
    Add a `DEBUGGING.md` file to your project:
    
    ```markdown
    # Debugging Guide
    
    ## Common Issues and Solutions
    
    ### "Cannot find module" errors
    - Check if the module is installed
    - Verify import path is correct
    - Run `npm install` to ensure dependencies are updated
    
    ## Debugging Tools
    
    ### VS Code Debugging
    1. Open the file you want to debug
    2. Set breakpoints
    3. Press F5 or select the debug configuration
    
    ### Remote Debugging
    4. Start the application with `--inspect` flag
    5. Connect with Chrome DevTools or VS Code
    ```
    

**Recommended Related Topics**

- TypeScript Error Handling Patterns
- Performance Profiling TypeScript Applications
- Testing TypeScript Applications
- Continuous Integration for TypeScript Projects
- Memory Leak Detection in TypeScript

---

## Testing TypeScript Code

### Understanding TypeScript Testing Fundamentals

TypeScript brings static type checking to JavaScript, but ensuring your code works as expected still requires thorough testing. Testing TypeScript code combines traditional JavaScript testing approaches with additional considerations for type safety and integration.

### Setting Up Your Testing Environment

#### Prerequisites

Before writing tests for TypeScript code, you need to set up your development environment properly:

- TypeScript compiler (`tsc`)
- A testing framework compatible with TypeScript
- Types for your testing libraries
- TypeScript configuration (`tsconfig.json`) with proper test settings

#### Basic Configuration

A typical `tsconfig.json` for testing might include:

```json
{
  "compilerOptions": {
    "target": "es2016",
    "module": "commonjs",
    "esModuleInterop": true,
    "forceConsistentCasingInFileNames": true,
    "strict": true,
    "skipLibCheck": true,
    "outDir": "./dist",
    "rootDir": "./src",
    "types": ["jest", "node"]
  },
  "include": ["src/**/*", "tests/**/*"],
  "exclude": ["node_modules"]
}
```

### Unit Testing with Jest

Jest is one of the most popular testing frameworks for TypeScript projects due to its simplicity and powerful features.

#### Setting Up Jest for TypeScript

To set up Jest with TypeScript:

1. Install required packages:

```bash
npm install --save-dev jest @types/jest ts-jest
```

2. Create a Jest configuration file (`jest.config.js`):

```javascript
module.exports = {
  preset: 'ts-jest',
  testEnvironment: 'node',
  roots: ['<rootDir>/src/', '<rootDir>/tests/'],
  testMatch: ['**/__tests__/**/*.ts?(x)', '**/?(*.)+(spec|test).ts?(x)'],
  transform: {
    '^.+\\.tsx?$': 'ts-jest',
  },
};
```

#### Writing Your First Jest Test

Here's an example of a simple TypeScript function and its test:

```typescript
// src/math.ts
export function add(a: number, b: number): number {
  return a + b;
}
```

```typescript
// tests/math.test.ts
import { add } from '../src/math';

describe('Math functions', () => {
  it('should add two numbers correctly', () => {
    expect(add(1, 2)).toBe(3);
    expect(add(-1, 1)).toBe(0);
    expect(add(5, 5)).toBe(10);
  });
});
```

#### Jest Best Practices for TypeScript

- Group related tests using `describe` blocks
- Use specific test names that describe the expected behavior
- Test edge cases and error conditions
- Use beforeEach/afterEach for setup and teardown
- Leverage type information in your test assertions

### Using Mocha with TypeScript

Mocha is another popular testing framework that works well with TypeScript.

#### Setting Up Mocha

1. Install required packages:

```bash
npm install --save-dev mocha @types/mocha ts-node chai @types/chai
```

2. Add a test script to your `package.json`:

```json
{
  "scripts": {
    "test": "mocha -r ts-node/register 'tests/**/*.ts'"
  }
}
```

#### Writing Mocha Tests

```typescript
// tests/example.test.ts
import { expect } from 'chai';
import { add } from '../src/math';

describe('Math functions', function() {
  it('should add two numbers correctly', function() {
    expect(add(1, 2)).to.equal(3);
    expect(add(-1, 1)).to.equal(0);
    expect(add(5, 5)).to.equal(10);
  });
});
```

### Type Testing Libraries

Type testing in TypeScript ensures that your types work as expected, which is an additional layer of verification unique to statically typed languages.

#### Using ts-expect

The `ts-expect` library enables type assertions in your tests:

```bash
npm install --save-dev ts-expect
```

```typescript
import { expectType } from 'ts-expect';
import { add } from '../src/math';

describe('Type checking', () => {
  it('should verify function return types', () => {
    expectType<number>(add(1, 2));
  });
});
```

#### TypeScript-specific Testing with dtslint

For library authors, `dtslint` tests the accuracy of your TypeScript declaration files:

```bash
npm install --save-dev dtslint
```

Create test files in a `types` directory with assertions like:

```typescript
// $ExpectType number
add(1, 2);

// $ExpectError
add('1', 2);
```

#### Using tsd for Type Assertions

The `tsd` package provides utilities for testing TypeScript types:

```bash
npm install --save-dev tsd
```

```typescript
import { expectType, expectError } from 'tsd';

// Verify return type
expectType<number>(add(1, 2));

// Verify compile-time errors
expectError(add('1', 2));
```

### Test-Driven Development with TypeScript

Test-Driven Development (TDD) with TypeScript follows the same principles as traditional TDD but with an added focus on types.

#### The TDD Cycle for TypeScript

1. Write a failing test that defines the expected behavior and types
2. Implement the minimal code to make the test pass
3. Refactor while keeping tests passing
4. Repeat

#### TDD Example in TypeScript

Let's implement a simple user authentication function using TDD:

1. Write the test first:

```typescript
// tests/auth.test.ts
import { expect } from 'chai';
import { authenticateUser } from '../src/auth';
import { User } from '../src/types';

describe('User Authentication', () => {
  it('should authenticate valid users', async () => {
    const result = await authenticateUser('user@example.com', 'correct-password');
    expect(result.success).to.be.true;
    expect(result.user).to.have.property('email', 'user@example.com');
  });

  it('should reject invalid credentials', async () => {
    const result = await authenticateUser('user@example.com', 'wrong-password');
    expect(result.success).to.be.false;
    expect(result.user).to.be.null;
    expect(result.error).to.equal('Invalid credentials');
  });
});
```

2. Define types:

```typescript
// src/types.ts
export interface User {
  id: string;
  email: string;
  name: string;
}

export interface AuthResult {
  success: boolean;
  user: User | null;
  error?: string;
}
```

3. Implement the function:

```typescript
// src/auth.ts
import { User, AuthResult } from './types';

export async function authenticateUser(
  email: string, 
  password: string
): Promise<AuthResult> {
  // In a real app, this would verify against a database
  if (email === 'user@example.com' && password === 'correct-password') {
    return {
      success: true,
      user: {
        id: '123',
        email: 'user@example.com',
        name: 'Test User'
      }
    };
  }
  
  return {
    success: false,
    user: null,
    error: 'Invalid credentials'
  };
}
```

#### Benefits of TDD with TypeScript

- Designs the API and type interfaces before implementation
- Catches type errors during development
- Creates living documentation of expected behavior
- Provides confidence when refactoring

### Integration Tests

Integration tests verify that different components of your application work correctly together.

#### Testing TypeScript Applications

For a typical web application, integration tests might include:

- API endpoint testing
- Database interaction testing
- Service integration testing
- External dependency testing

#### Using Supertest for API Testing

For testing HTTP endpoints:

```bash
npm install --save-dev supertest @types/supertest
```

```typescript
// tests/api.test.ts
import request from 'supertest';
import { app } from '../src/app';

describe('User API', () => {
  it('should return user information', async () => {
    const response = await request(app)
      .get('/api/users/123')
      .expect('Content-Type', /json/)
      .expect(200);
    
    expect(response.body).to.have.property('id', '123');
    expect(response.body).to.have.property('email');
  });
});
```

#### Testing Database Interactions

For database integration testing:

```typescript
import { expect } from 'chai';
import { UserRepository } from '../src/repositories/userRepository';
import { DatabaseConnection } from '../src/database';

describe('User Repository', () => {
  let db: DatabaseConnection;
  let repository: UserRepository;
  
  before(async () => {
    db = await DatabaseConnection.create('test-database');
    repository = new UserRepository(db);
  });
  
  afterEach(async () => {
    await db.collection('users').deleteMany({});
  });
  
  after(async () => {
    await db.close();
  });
  
  it('should create and retrieve a user', async () => {
    const user = {
      email: 'test@example.com',
      name: 'Test User'
    };
    
    const id = await repository.createUser(user);
    const retrieved = await repository.getUserById(id);
    
    expect(retrieved).to.not.be.null;
    expect(retrieved?.email).to.equal(user.email);
    expect(retrieved?.name).to.equal(user.name);
  });
});
```

### Mocking in TypeScript Tests

Mocking is essential for isolating the code under test from its dependencies.

#### Using Jest Mocks

```typescript
import { UserService } from '../src/services/userService';
import { UserRepository } from '../src/repositories/userRepository';

jest.mock('../src/repositories/userRepository');

describe('UserService', () => {
  beforeEach(() => {
    jest.resetAllMocks();
  });

  it('should get user by id', async () => {
    const mockUser = { id: '123', name: 'Test User', email: 'test@example.com' };
    (UserRepository.prototype.getUserById as jest.Mock).mockResolvedValue(mockUser);
    
    const service = new UserService(new UserRepository());
    const user = await service.getUserById('123');
    
    expect(user).toEqual(mockUser);
    expect(UserRepository.prototype.getUserById).toHaveBeenCalledWith('123');
  });
});
```

#### Type-Safe Mocking with ts-mockito

For more type-safe mocking:

```bash
npm install --save-dev ts-mockito
```

```typescript
import { instance, mock, verify, when } from 'ts-mockito';
import { UserService } from '../src/services/userService';
import { UserRepository } from '../src/repositories/userRepository';

describe('UserService with ts-mockito', () => {
  it('should get user by id', async () => {
    // Create a mock with type safety
    const mockedRepo = mock(UserRepository);
    const mockUser = { id: '123', name: 'Test User', email: 'test@example.com' };
    
    // Configure the mock
    when(mockedRepo.getUserById('123')).thenResolve(mockUser);
    
    // Create an instance from the mock
    const service = new UserService(instance(mockedRepo));
    const user = await service.getUserById('123');
    
    expect(user).toEqual(mockUser);
    verify(mockedRepo.getUserById('123')).once();
  });
});
```

### Testing Asynchronous Code

TypeScript projects often involve asynchronous operations that require special testing approaches.

#### Testing Promises

```typescript
it('should resolve with user data', async () => {
  const user = await userService.fetchUserData(123);
  expect(user.id).to.equal(123);
});

it('should reject with an error for invalid users', async () => {
  try {
    await userService.fetchUserData(-1);
    expect.fail('Should have thrown an error');
  } catch (error) {
    expect(error.message).to.include('Invalid user ID');
  }
});
```

#### Testing with Async/Await

```typescript
it('handles async operations correctly', async () => {
  const result = await asyncFunction();
  expect(result).to.equal('expected value');
});
```

### Code Coverage for TypeScript

Measuring test coverage helps identify untested code paths.

#### Setting Up Coverage with Jest

```javascript
// jest.config.js
module.exports = {
  preset: 'ts-jest',
  testEnvironment: 'node',
  collectCoverage: true,
  coverageDirectory: 'coverage',
  coverageReporters: ['text', 'lcov', 'html'],
  collectCoverageFrom: [
    'src/**/*.ts',
    '!src/**/*.d.ts',
    '!src/index.ts',
    '!**/node_modules/**',
  ],
  coverageThreshold: {
    global: {
      branches: 80,
      functions: 80,
      lines: 80,
      statements: 80,
    },
  },
};
```

#### Interpreting Coverage Reports

- Look for uncovered branches and functions
- Focus on complex logic and error-handling paths
- Set coverage thresholds in CI to prevent regressions

### Testing TypeScript React Components

For frontend applications, testing TypeScript React components requires additional setup.

#### Setting Up React Testing Library

```bash
npm install --save-dev @testing-library/react @testing-library/jest-dom
```

```typescript
// tests/Button.test.tsx
import React from 'react';
import { render, fireEvent, screen } from '@testing-library/react';
import '@testing-library/jest-dom';
import { Button } from '../src/components/Button';

describe('Button Component', () => {
  it('renders with correct text', () => {
    render(<Button text="Click me" onClick={() => {}} />);
    expect(screen.getByText('Click me')).toBeInTheDocument();
  });

  it('calls onClick handler when clicked', () => {
    const handleClick = jest.fn();
    render(<Button text="Click me" onClick={handleClick} />);
    fireEvent.click(screen.getByText('Click me'));
    expect(handleClick).toHaveBeenCalledTimes(1);
  });
});
```

### Advanced Testing Patterns

#### Snapshot Testing

Snapshot testing is useful for UI components or complex objects:

```typescript
it('should match the previous snapshot', () => {
  const user = userService.createUser('John', 'Doe');
  expect(user).toMatchSnapshot();
});
```

#### Parameterized Tests

Using Jest's `test.each` for data-driven tests:

```typescript
test.each([
  [1, 1, 2],
  [2, 2, 4],
  [0, 5, 5],
])('add(%i, %i) = %i', (a, b, expected) => {
  expect(add(a, b)).toBe(expected);
});
```

#### Property-Based Testing

Using `fast-check` for property-based testing:

```bash
npm install --save-dev fast-check
```

```typescript
import * as fc from 'fast-check';

it('should always return a string that includes the input', () => {
  fc.assert(
    fc.property(fc.string(), (input) => {
      const result = formatText(input);
      return result.includes(input);
    })
  );
});
```

### Testing Performance

#### Benchmarking with benchmark.js

```bash
npm install --save-dev benchmark @types/benchmark
```

```typescript
import Benchmark from 'benchmark';

const suite = new Benchmark.Suite;

suite
  .add('Method A', () => {
    methodA();
  })
  .add('Method B', () => {
    methodB();
  })
  .on('cycle', (event: Benchmark.Event) => {
    console.log(String(event.target));
  })
  .on('complete', function(this: Benchmark.Suite) {
    console.log('Fastest is ' + this.filter('fastest').map('name'));
  })
  .run({ 'async': true });
```

### Continuous Integration for TypeScript Tests

Integrating tests into CI pipelines ensures code quality across the team.

#### GitHub Actions Example

```yaml
# .github/workflows/test.yml
name: Run Tests

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Node.js
      uses: actions/setup-node@v3
      with:
        node-version: '16'
        cache: 'npm'
    
    - name: Install dependencies
      run: npm ci
    
    - name: Run tests
      run: npm test
    
    - name: Upload coverage reports
      uses: codecov/codecov-action@v3
      with:
        file: ./coverage/lcov.info
```

### Testing Best Practices for TypeScript

**Key Points:**

- Write tests that verify both behavior and types
- Follow the AAA pattern: Arrange, Act, Assert
- Test edge cases and error handling paths
- Separate unit tests from integration tests
- Use descriptive test names that explain behavior
- Avoid testing implementation details
- Mock external dependencies
- Maintain high test coverage, especially for complex logic
- Make tests deterministic and repeatable
- Keep tests fast for quick feedback

### Debugging TypeScript Tests

#### Using VS Code for Debugging Tests

Create a `.vscode/launch.json` file:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "type": "node",
      "request": "launch",
      "name": "Debug Jest Tests",
      "program": "${workspaceFolder}/node_modules/.bin/jest",
      "args": [
        "--runInBand",
        "--testMatch",
        "**/tests/**/*.test.ts"
      ],
      "console": "integratedTerminal",
      "internalConsoleOptions": "neverOpen",
      "disableOptimisticBPs": true
    }
  ]
}
```

#### Troubleshooting Common Issues

- Type mismatches between tests and implementation
- Missing type definitions for testing libraries
- Configuration issues with tsconfig or jest config
- Mocking modules that are imported as types

### Recommended Related Topics

- End-to-End Testing with Cypress and TypeScript
- Visual Regression Testing for TypeScript Applications
- Advanced Type Testing Techniques
- Testing GraphQL APIs with TypeScript
- Performance Testing Strategies for TypeScript Applications

---

# Advanced Object-Oriented Programming

## Design Patterns in TypeScript

### Introduction to Design Patterns

Design patterns represent proven solutions to common software design problems. They provide reusable templates for solving issues that occur repeatedly in software development. In TypeScript, these patterns become even more powerful due to the language's static typing, interfaces, and object-oriented features.

### Creational Patterns

Creational design patterns focus on mechanisms of object creation, trying to create objects in a manner suitable to the situation.

### Singleton Pattern

The Singleton pattern ensures a class has only one instance and provides a global point of access to it.

**Key Points**

- Restricts instantiation of a class to a single instance
- Provides a global access point to that instance
- Particularly useful for database connections, logging, caching

```typescript
class Singleton {
  private static instance: Singleton;
  
  private constructor() {
    // Private constructor prevents direct construction calls
  }
  
  public static getInstance(): Singleton {
    if (!Singleton.instance) {
      Singleton.instance = new Singleton();
    }
    
    return Singleton.instance;
  }
  
  public someBusinessLogic() {
    // Business logic methods
  }
}

// Usage
const instance1 = Singleton.getInstance();
const instance2 = Singleton.getInstance();

console.log(instance1 === instance2); // Output: true
```

### Factory Pattern

The Factory pattern provides an interface for creating objects but allows subclasses to alter the type of objects that will be created.

**Key Points**

- Creates objects without exposing creation logic
- Uses a common interface to refer to created objects
- Allows flexibility to add new types without changing existing code

```typescript
interface Product {
  operation(): string;
}

class ConcreteProduct1 implements Product {
  public operation(): string {
    return 'Result of ConcreteProduct1';
  }
}

class ConcreteProduct2 implements Product {
  public operation(): string {
    return 'Result of ConcreteProduct2';
  }
}

abstract class Creator {
  public abstract factoryMethod(): Product;
  
  public someOperation(): string {
    const product = this.factoryMethod();
    return `Creator: The same creator's code has worked with ${product.operation()}`;
  }
}

class ConcreteCreator1 extends Creator {
  public factoryMethod(): Product {
    return new ConcreteProduct1();
  }
}

class ConcreteCreator2 extends Creator {
  public factoryMethod(): Product {
    return new ConcreteProduct2();
  }
}

// Usage
function clientCode(creator: Creator) {
  console.log(creator.someOperation());
}

clientCode(new ConcreteCreator1());
clientCode(new ConcreteCreator2());
```

### Observer Pattern

The Observer pattern defines a one-to-many dependency between objects so that when one object changes state, all its dependents are notified and updated automatically.

**Key Points**

- Establishes a subscription mechanism
- Notifies multiple objects about events in the observed object
- Promotes loose coupling between objects

```typescript
interface Observer {
  update(subject: Subject): void;
}

interface Subject {
  attach(observer: Observer): void;
  detach(observer: Observer): void;
  notify(): void;
}

class ConcreteSubject implements Subject {
  private observers: Observer[] = [];
  private state: number = 0;
  
  public attach(observer: Observer): void {
    const isExist = this.observers.includes(observer);
    if (isExist) {
      return;
    }
    
    this.observers.push(observer);
  }
  
  public detach(observer: Observer): void {
    const observerIndex = this.observers.indexOf(observer);
    if (observerIndex === -1) {
      return;
    }
    
    this.observers.splice(observerIndex, 1);
  }
  
  public notify(): void {
    for (const observer of this.observers) {
      observer.update(this);
    }
  }
  
  public setState(state: number): void {
    this.state = state;
    this.notify();
  }
  
  public getState(): number {
    return this.state;
  }
}

class ConcreteObserverA implements Observer {
  public update(subject: Subject): void {
    if (subject instanceof ConcreteSubject && subject.getState() < 3) {
      console.log('ConcreteObserverA: Reacted to the event');
    }
  }
}

class ConcreteObserverB implements Observer {
  public update(subject: Subject): void {
    if (subject instanceof ConcreteSubject && (subject.getState() === 0 || subject.getState() >= 2)) {
      console.log('ConcreteObserverB: Reacted to the event');
    }
  }
}

// Usage
const subject = new ConcreteSubject();

const observer1 = new ConcreteObserverA();
subject.attach(observer1);

const observer2 = new ConcreteObserverB();
subject.attach(observer2);

subject.setState(1);
subject.setState(2);

subject.detach(observer2);
subject.setState(3);
```

### Structural Patterns

Structural patterns focus on how classes and objects are composed to form larger structures.

### Adapter Pattern

The Adapter pattern allows objects with incompatible interfaces to collaborate by wrapping an object in an adapter that conforms to another object's interface.

**Key Points**

- Converts one interface to another
- Enables classes to work together that couldn't otherwise
- Often used when integrating legacy code or third-party libraries

```typescript
// Target interface that client expects to work with
interface Target {
  request(): string;
}

// Existing functionality with incompatible interface
class Adaptee {
  public specificRequest(): string {
    return '.eetpadA eht fo roivaheb laicepS';
  }
}

// Adapter makes Adaptee compatible with Target
class Adapter implements Target {
  private adaptee: Adaptee;
  
  constructor(adaptee: Adaptee) {
    this.adaptee = adaptee;
  }
  
  public request(): string {
    const result = this.adaptee.specificRequest().split('').reverse().join('');
    return `Adapter: (TRANSLATED) ${result}`;
  }
}

// Client code
function clientCode(target: Target) {
  console.log(target.request());
}

// Usage
const adaptee = new Adaptee();
console.log('Adaptee:');
console.log(`Adaptee: ${adaptee.specificRequest()}`);

console.log('');

console.log('Client: I can work with the Target objects:');
const adapter = new Adapter(adaptee);
clientCode(adapter);
```

### Decorator Pattern

The Decorator pattern attaches additional responsibilities to objects dynamically, providing a flexible alternative to subclassing for extending functionality.

**Key Points**

- Adds behavior to objects without affecting other objects
- Follows the open/closed principle
- More flexible than inheritance
- Can be stacked to add multiple behaviors

```typescript
interface Component {
  operation(): string;
}

class ConcreteComponent implements Component {
  public operation(): string {
    return 'ConcreteComponent';
  }
}

class Decorator implements Component {
  protected component: Component;
  
  constructor(component: Component) {
    this.component = component;
  }
  
  public operation(): string {
    return this.component.operation();
  }
}

class ConcreteDecoratorA extends Decorator {
  public operation(): string {
    return `ConcreteDecoratorA(${super.operation()})`;
  }
}

class ConcreteDecoratorB extends Decorator {
  public operation(): string {
    return `ConcreteDecoratorB(${super.operation()})`;
  }
  
  public additionalOperation(): void {
    console.log('Additional operation from ConcreteDecoratorB');
  }
}

// Usage
const simple = new ConcreteComponent();
console.log('Client: I\'ve got a simple component:');
console.log(`Result: ${simple.operation()}`);

const decorator1 = new ConcreteDecoratorA(simple);
const decorator2 = new ConcreteDecoratorB(decorator1);
console.log('Client: Now I\'ve got a decorated component:');
console.log(`Result: ${decorator2.operation()}`);
```

### Behavioral Patterns

Behavioral patterns are concerned with algorithms and the assignment of responsibilities between objects.

### Strategy Pattern

The Strategy pattern defines a family of algorithms, encapsulates each one, and makes them interchangeable.

**Key Points**

- Defines algorithms independently from clients that use them
- Allows selecting algorithm at runtime
- Eliminates conditional statements

```typescript
interface Strategy {
  doAlgorithm(data: string[]): string[];
}

class Context {
  private strategy: Strategy;
  
  constructor(strategy: Strategy) {
    this.strategy = strategy;
  }
  
  public setStrategy(strategy: Strategy) {
    this.strategy = strategy;
  }
  
  public doSomeBusinessLogic(): void {
    const data = ['a', 'b', 'c', 'd', 'e'];
    const result = this.strategy.doAlgorithm(data);
    console.log(result.join(','));
  }
}

class ConcreteStrategyA implements Strategy {
  public doAlgorithm(data: string[]): string[] {
    return data.sort();
  }
}

class ConcreteStrategyB implements Strategy {
  public doAlgorithm(data: string[]): string[] {
    return data.reverse();
  }
}

// Usage
const context = new Context(new ConcreteStrategyA());
console.log('Client: Strategy is set to normal sorting.');
context.doSomeBusinessLogic();

console.log('Client: Strategy is set to reverse sorting.');
context.setStrategy(new ConcreteStrategyB());
context.doSomeBusinessLogic();
```

### Command Pattern

The Command pattern encapsulates a request as an object, allowing for parameterization of clients with different requests, queueing of requests, and logging of the operations.

**Key Points**

- Decouples sender from receiver
- Allows queueing of commands
- Supports undo operations
- Enables logging and auditing of operations

```typescript
interface Command {
  execute(): void;
}

class SimpleCommand implements Command {
  private payload: string;
  
  constructor(payload: string) {
    this.payload = payload;
  }
  
  public execute(): void {
    console.log(`SimpleCommand: I can do simple things like printing (${this.payload})`);
  }
}

class ComplexCommand implements Command {
  private receiver: Receiver;
  private a: string;
  private b: string;
  
  constructor(receiver: Receiver, a: string, b: string) {
    this.receiver = receiver;
    this.a = a;
    this.b = b;
  }
  
  public execute(): void {
    console.log('ComplexCommand: Complex stuff should be done by a receiver object.');
    this.receiver.doSomething(this.a);
    this.receiver.doSomethingElse(this.b);
  }
}

class Receiver {
  public doSomething(a: string): void {
    console.log(`Receiver: Working on (${a}.)`);
  }
  
  public doSomethingElse(b: string): void {
    console.log(`Receiver: Also working on (${b}.)`);
  }
}

class Invoker {
  private onStart: Command;
  private onFinish: Command;
  
  public setOnStart(command: Command): void {
    this.onStart = command;
  }
  
  public setOnFinish(command: Command): void {
    this.onFinish = command;
  }
  
  public doSomethingImportant(): void {
    console.log('Invoker: Does anybody want something done before I begin?');
    if (this.onStart) {
      this.onStart.execute();
    }
    
    console.log('Invoker: ...doing something really important...');
    
    console.log('Invoker: Does anybody want something done after I finish?');
    if (this.onFinish) {
      this.onFinish.execute();
    }
  }
}

// Usage
const invoker = new Invoker();
invoker.setOnStart(new SimpleCommand('Say Hi!'));
const receiver = new Receiver();
invoker.setOnFinish(new ComplexCommand(receiver, 'Send email', 'Save report'));
invoker.doSomethingImportant();
```

### TypeScript-Specific Implementation Considerations

TypeScript offers several features that enhance design pattern implementations:

#### Generic Types

Using generic types can make patterns like Factory more flexible:

```typescript
class GenericFactory<T> {
  create(ctor: new () => T): T {
    return new ctor();
  }
}

class Product1 {}
class Product2 {}

const factory = new GenericFactory<Product1 | Product2>();
const p1 = factory.create(Product1);
const p2 = factory.create(Product2);
```

#### Decorators

TypeScript's experimental decorators can simplify the implementation of decorator patterns:

```typescript
function log(target: any, propertyKey: string, descriptor: PropertyDescriptor) {
  const originalMethod = descriptor.value;
  
  descriptor.value = function(...args: any[]) {
    console.log(`Calling ${propertyKey} with arguments: ${JSON.stringify(args)}`);
    const result = originalMethod.apply(this, args);
    console.log(`Method ${propertyKey} returned: ${JSON.stringify(result)}`);
    return result;
  };
  
  return descriptor;
}

class Calculator {
  @log
  add(a: number, b: number): number {
    return a + b;
  }
}

// Usage
const calc = new Calculator();
calc.add(1, 2);
// Output:
// Calling add with arguments: [1,2]
// Method add returned: 3
```

#### Abstract Classes

TypeScript's abstract classes provide a powerful way to define templates for pattern implementations:

```typescript
abstract class AbstractFactory {
  abstract createProductA(): ProductA;
  abstract createProductB(): ProductB;
  
  produceProducts(): void {
    const productA = this.createProductA();
    const productB = this.createProductB();
    console.log(productA.operationA());
    console.log(productB.operationB());
  }
}

interface ProductA {
  operationA(): string;
}

interface ProductB {
  operationB(): string;
}

class ConcreteFactory1 extends AbstractFactory {
  createProductA(): ProductA {
    return new ConcreteProductA1();
  }
  
  createProductB(): ProductB {
    return new ConcreteProductB1();
  }
}

class ConcreteProductA1 implements ProductA {
  operationA(): string {
    return 'Product A1';
  }
}

class ConcreteProductB1 implements ProductB {
  operationB(): string {
    return 'Product B1';
  }
}
```

### Best Practices for Using Design Patterns in TypeScript

#### Pattern Selection Guidelines

**Key Points**

- Choose the simplest pattern that solves your problem
- Don't overengineer solutions by adding unnecessary patterns
- Consider maintenance and team understanding when selecting patterns
- Document pattern usage in your codebase for better maintainability

#### Anti-Patterns to Avoid

**Key Points**

- Singleton overuse - can create hidden dependencies
- God objects - violate single responsibility principle
- Deeply nested decorators - can make debugging difficult
- Premature pattern application - adding complexity before it's needed

#### Testing Design Patterns

**Example**

```typescript
// Testing a Singleton
describe('Singleton', () => {
  it('should return the same instance', () => {
    const instance1 = Singleton.getInstance();
    const instance2 = Singleton.getInstance();
    
    expect(instance1).toBe(instance2);
  });
});

// Testing a Strategy pattern
describe('Strategy Pattern', () => {
  it('should sort in ascending order with strategy A', () => {
    const context = new Context(new ConcreteStrategyA());
    const data = ['e', 'a', 'c', 'b', 'd'];
    const result = context.executeStrategy(data);
    
    expect(result).toEqual(['a', 'b', 'c', 'd', 'e']);
  });
  
  it('should sort in descending order with strategy B', () => {
    const context = new Context(new ConcreteStrategyB());
    const data = ['e', 'a', 'c', 'b', 'd'];
    const result = context.executeStrategy(data);
    
    expect(result).toEqual(['e', 'd', 'c', 'b', 'a']);
  });
});
```

### Real-World Applications

#### UI Component Libraries

Many UI libraries use patterns like Composite for component trees, Observer for state management, and Decorator for component enhancement.

**Example**

```typescript
// Simple React-like Component system using Composite pattern
interface Component {
  render(): string;
}

class Text implements Component {
  private content: string;
  
  constructor(content: string) {
    this.content = content;
  }
  
  render(): string {
    return this.content;
  }
}

class Container implements Component {
  private children: Component[] = [];
  
  add(child: Component): void {
    this.children.push(child);
  }
  
  render(): string {
    return `<div>${this.children.map(child => child.render()).join('')}</div>`;
  }
}

// Usage
const page = new Container();
const header = new Container();
header.add(new Text('Header Text'));
page.add(header);

const content = new Container();
content.add(new Text('Main content goes here'));
page.add(content);

console.log(page.render());
```

#### State Management

The Observer pattern is commonly used in state management libraries.

```typescript
class Store {
  private state: any;
  private listeners: Function[] = [];
  
  constructor(initialState: any) {
    this.state = initialState;
  }
  
  getState(): any {
    return this.state;
  }
  
  setState(newState: any): void {
    this.state = { ...this.state, ...newState };
    this.notify();
  }
  
  subscribe(listener: Function): Function {
    this.listeners.push(listener);
    
    return () => {
      this.listeners = this.listeners.filter(l => l !== listener);
    };
  }
  
  private notify(): void {
    this.listeners.forEach(listener => listener(this.state));
  }
}

// Usage
const store = new Store({ user: null, isLoading: false });

const unsubscribe = store.subscribe((state) => {
  console.log('State changed:', state);
});

store.setState({ isLoading: true });
store.setState({ user: { name: 'John' }, isLoading: false });

unsubscribe();
```

### Advanced Pattern Combinations

Patterns often work best when combined strategically:

**Example**

```typescript
// Combining Factory and Singleton
class ConfigurationManager {
  private static instance: ConfigurationManager;
  private config: Record<string, any> = {};
  
  private constructor() {}
  
  public static getInstance(): ConfigurationManager {
    if (!ConfigurationManager.instance) {
      ConfigurationManager.instance = new ConfigurationManager();
    }
    
    return ConfigurationManager.instance;
  }
  
  public get(key: string): any {
    return this.config[key];
  }
  
  public set(key: string, value: any): void {
    this.config[key] = value;
  }
}

interface ApiService {
  fetchData(): Promise<any>;
}

class MockApiService implements ApiService {
  fetchData(): Promise<any> {
    return Promise.resolve({ mock: true, data: [1, 2, 3] });
  }
}

class ProductionApiService implements ApiService {
  fetchData(): Promise<any> {
    return fetch('https://api.example.com/data').then(res => res.json());
  }
}

class ApiServiceFactory {
  static createApiService(): ApiService {
    const config = ConfigurationManager.getInstance();
    const environment = config.get('environment');
    
    if (environment === 'development') {
      return new MockApiService();
    } else {
      return new ProductionApiService();
    }
  }
}

// Usage
const config = ConfigurationManager.getInstance();
config.set('environment', 'development');

const apiService = ApiServiceFactory.createApiService();
apiService.fetchData().then(data => console.log(data));
```

### Conclusion

Design patterns in TypeScript offer a powerful way to solve common software design problems. By leveraging TypeScript's static typing, interfaces, and object-oriented features, developers can implement these patterns more safely and with better tooling support. Understanding when and how to apply these patterns—whether Singleton, Factory, Observer, Adapter, or Decorator—is a critical skill for writing maintainable, flexible code.

The examples provided demonstrate how TypeScript enhances classic design patterns with type safety and modern language features. As you implement these patterns in your projects, remember to balance pattern usage with simplicity and maintainability, avoiding unnecessary complexity while maximizing the benefits of structured, reusable solutions.

### Related Topics

- Advanced TypeScript Types and Pattern Implementation
- Functional Programming Patterns in TypeScript
- Dependency Injection in TypeScript Applications
- Building Scalable Architecture with TypeScript and Design Patterns
- Testing Design Pattern Implementations with TypeScript Testing Tools

---

## Mixins and Composition in TypeScript

### Understanding Mixins

Mixins are a powerful pattern in TypeScript that enable code reuse through composition rather than inheritance. They allow you to combine behaviors from multiple sources into a single class without creating complex inheritance hierarchies.

**Key Points**

- Mixins inject methods and properties from source objects into target classes
- They solve the "diamond problem" that can occur with multiple inheritance
- TypeScript supports mixins through clever type manipulation
- Mixins provide a flexible alternative to class inheritance

### Creating Mixins

In TypeScript, mixins are typically created as functions that take a constructor and return a new class that extends it with additional functionality.

```typescript
// Type for a constructor function
type Constructor<T = {}> = new (...args: any[]) => T;

// A mixin function that adds a timestamp property
function Timestamped<TBase extends Constructor>(Base: TBase) {
  return class extends Base {
    timestamp = new Date();
    
    getTimestamp() {
      return this.timestamp;
    }
  };
}

// A mixin that adds an ID property
function Identifiable<TBase extends Constructor>(Base: TBase) {
  return class extends Base {
    id = Math.random().toString(36).substring(2, 9);
    
    getId() {
      return this.id;
    }
  };
}

// Base class
class User {
  name: string;
  
  constructor(name: string) {
    this.name = name;
  }
}

// Apply mixins to create a new class
const TimestampedUser = Timestamped(User);
const IdentifiableUser = Identifiable(User);
const EnhancedUser = Identifiable(Timestamped(User));

// Usage
const user = new EnhancedUser("Alice");
console.log(user.getId());         // "xf9zu2e"
console.log(user.getTimestamp());  // Date object
console.log(user.name);            // "Alice"
```

**Example** Let's implement a real-world mixin for a logger functionality:

```typescript
function LoggerMixin<TBase extends Constructor>(Base: TBase) {
  return class extends Base {
    log(message: string) {
      console.log(`[${new Date().toISOString()}] ${message}`);
    }
    
    warn(message: string) {
      console.warn(`[${new Date().toISOString()}] WARNING: ${message}`);
    }
    
    error(message: string) {
      console.error(`[${new Date().toISOString()}] ERROR: ${message}`);
    }
  };
}

// Apply it to any class
class Service {
  constructor(public name: string) {}
  
  execute() {
    return `${this.name} executed`;
  }
}

const LoggableService = LoggerMixin(Service);
const service = new LoggableService("AuthService");

service.log("Service initialized");
const result = service.execute();
service.log(`Result: ${result}`);
```

### Composition over Inheritance

Composition over inheritance is a design principle that suggests that classes should achieve polymorphic behavior and code reuse by containing instances of other classes rather than inheriting from a base class.

**Key Points**

- Inheritance creates tight coupling between parent and child classes
- Composition creates more flexible and maintainable code
- Mixins are a form of composition that TypeScript makes type-safe
- The "has-a" relationship (composition) is often more flexible than the "is-a" relationship (inheritance)

```typescript
// Instead of this inheritance approach:
class Vehicle {
  move() { console.log("Moving"); }
}

class Car extends Vehicle {
  // Car is-a Vehicle
  horn() { console.log("Beep!"); }
}

// Consider this composition approach:
interface Movable {
  move(): void;
}

interface Soundable {
  makeSound(): void;
}

class MovementBehavior implements Movable {
  move() { console.log("Moving"); }
}

class HornBehavior implements Soundable {
  makeSound() { console.log("Beep!"); }
}

class Car {
  // Car has-a movement behavior and has-a sound behavior
  constructor(
    private movement: Movable = new MovementBehavior(),
    private sound: Soundable = new HornBehavior()
  ) {}
  
  move() {
    this.movement.move();
  }
  
  horn() {
    this.sound.makeSound();
  }
}
```

### Applying Mixins to Classes

TypeScript provides a pattern for applying mixins to classes that the TypeScript team recommends.

```typescript
// Create mixin classes (without extending anything)
class Timestamped {
  timestamp = new Date();
  
  getTimestamp() {
    return this.timestamp;
  }
}

class Activatable {
  isActive = false;
  
  activate() {
    this.isActive = true;
  }
  
  deactivate() {
    this.isActive = false;
  }
}

// Create a base class
class User {
  constructor(public name: string) {}
}

// Add the mixin types to the interface
interface User extends Timestamped, Activatable {}

// Apply the mixins using this helper function
function applyMixins(derivedCtor: any, constructors: any[]) {
  constructors.forEach((baseCtor) => {
    Object.getOwnPropertyNames(baseCtor.prototype).forEach((name) => {
      Object.defineProperty(
        derivedCtor.prototype,
        name,
        Object.getOwnPropertyDescriptor(baseCtor.prototype, name) || 
        Object.create(null)
      );
    });
  });
}

// Apply the mixins
applyMixins(User, [Timestamped, Activatable]);

// Use the mixed-in class
const user = new User("Bob");
user.activate();
console.log(user.isActive);  // true
console.log(user.getTimestamp());  // Date object
```

**Example** Building a component system with mixins:

```typescript
// Base component structure
class Component {
  constructor(public element: HTMLElement) {}
  
  render() {
    return this.element;
  }
}

// Mixins
class ClickableMixin {
  onClick(callback: (e: MouseEvent) => void) {
    if (this instanceof Component) {
      this.element.addEventListener("click", callback);
    }
  }
}

class DraggableMixin {
  private isDragging = false;
  private offsetX = 0;
  private offsetY = 0;
  
  makeDraggable() {
    if (this instanceof Component) {
      this.element.style.position = "absolute";
      
      this.element.addEventListener("mousedown", (e) => {
        this.isDragging = true;
        this.offsetX = e.clientX - this.element.getBoundingClientRect().left;
        this.offsetY = e.clientY - this.element.getBoundingClientRect().top;
      });
      
      document.addEventListener("mousemove", (e) => {
        if (this.isDragging) {
          this.element.style.left = `${e.clientX - this.offsetX}px`;
          this.element.style.top = `${e.clientY - this.offsetY}px`;
        }
      });
      
      document.addEventListener("mouseup", () => {
        this.isDragging = false;
      });
    }
  }
}

// Add types to the interface
interface Component extends ClickableMixin, DraggableMixin {}

// Apply mixins
applyMixins(Component, [ClickableMixin, DraggableMixin]);

// Use the mixed-in class
const div = document.createElement("div");
div.textContent = "Drag me!";
document.body.appendChild(div);

const component = new Component(div);
component.onClick(() => console.log("Clicked!"));
component.makeDraggable();
```

### Advanced Mixin Patterns

#### Constrained Mixins

We can create mixins that only work on base classes satisfying certain constraints:

```typescript
// Define a constraint interface
interface HasName {
  name: string;
}

// A mixin that can only be applied to classes with a name property
function NamedLogger<TBase extends Constructor<HasName>>(Base: TBase) {
  return class extends Base {
    logName() {
      console.log(`Name: ${this.name}`);
    }
  };
}

class Person {
  constructor(public name: string) {}
}

class Product {
  id: number;
  // No name property, so this won't work with NamedLogger
}

const LoggablePerson = NamedLogger(Person); // Works
// const LoggableProduct = NamedLogger(Product); // Error: Type 'Product' does not satisfy the constraint 'HasName'
```

#### Stateful Mixins

Mixins can also maintain their own state:

```typescript
function StatefulMixin<TBase extends Constructor>(Base: TBase) {
  return class extends Base {
    private state = new Map<string, any>();
    
    setState(key: string, value: any) {
      this.state.set(key, value);
    }
    
    getState(key: string) {
      return this.state.get(key);
    }
    
    clearState() {
      this.state.clear();
    }
  };
}

class Widget {
  constructor(public id: string) {}
}

const StatefulWidget = StatefulMixin(Widget);
const widget = new StatefulWidget("w1");

widget.setState("position", { x: 10, y: 20 });
console.log(widget.getState("position")); // { x: 10, y: 20 }
```

### Functional Mixins

An alternative approach is to use functional mixins, which are pure functions that add behavior to an object:

```typescript
interface Entity {
  name: string;
}

// Functional mixins
const withLogging = (entity: Entity) => {
  return {
    ...entity,
    log(message: string) {
      console.log(`[${entity.name}] ${message}`);
    }
  };
};

const withTimestamp = (entity: any) => {
  return {
    ...entity,
    timestamp: new Date(),
    getTimestamp() {
      return this.timestamp;
    }
  };
};

// Using functional mixins
const baseEntity = { name: "Entity 1" };
const loggableEntity = withLogging(baseEntity);
const enhancedEntity = withTimestamp(loggableEntity);

enhancedEntity.log("This is a test");
console.log(enhancedEntity.getTimestamp());
```

**Example** Creating a data pipeline with functional mixins:

```typescript
// Base data processor
interface DataProcessor {
  process(data: any[]): any[];
}

// Functional mixins
const withFiltering = (processor: DataProcessor) => {
  return {
    ...processor,
    filter(predicate: (item: any) => boolean) {
      const originalProcess = processor.process;
      return {
        ...processor,
        process(data: any[]) {
          const filtered = data.filter(predicate);
          return originalProcess.call(this, filtered);
        }
      };
    }
  };
};

const withMapping = (processor: DataProcessor) => {
  return {
    ...processor,
    map(mapFn: (item: any) => any) {
      const originalProcess = processor.process;
      return {
        ...processor,
        process(data: any[]) {
          const mapped = data.map(mapFn);
          return originalProcess.call(this, mapped);
        }
      };
    }
  };
};

// Base processor
const baseProcessor: DataProcessor = {
  process(data: any[]) {
    return data;
  }
};

// Create enhanced processor with mixins
const enhancedProcessor = withMapping(withFiltering(baseProcessor));

// Use it
const numbers = [1, 2, 3, 4, 5];
const result = enhancedProcessor
  .filter(n => n % 2 === 0)
  .map(n => n * 10)
  .process(numbers);

console.log(result); // [20, 40]
```

### Performance Considerations

Mixins come with some performance implications you should be aware of:

**Key Points**

- Each mixin application creates a new class that must be JIT-compiled
- Deep mixin chains can impact both memory usage and startup time
- Property lookups may be slower due to the prototype chain
- Consider factory functions for performance-critical code

### Best Practices for Using Mixins

For effective use of mixins in TypeScript:

**Key Points**

- Keep mixins focused on a single responsibility
- Avoid state in mixins when possible to prevent unexpected interactions
- Document mixin dependencies clearly
- Consider using interfaces to define mixin contracts
- Test mixins in isolation before combining them

```typescript
// Example of a well-designed mixin with clear documentation
/**
 * Throttle mixin - adds throttling capability to method calls
 * 
 * @param delay - The minimum time between method calls in milliseconds
 * @requires The base class must have a `this` context
 */
function Throttled<TBase extends Constructor>(Base: TBase, delay: number = 300) {
  return class extends Base {
    private lastCall: Record<string, number> = {};
    
    throttle<T extends (...args: any[]) => any>(
      method: T,
      methodName: string
    ): T {
      return ((...args: any[]) => {
        const now = Date.now();
        if (!this.lastCall[methodName] || (now - this.lastCall[methodName]) >= delay) {
          this.lastCall[methodName] = now;
          return method.apply(this, args);
        }
        return undefined;
      }) as T;
    }
  };
}

// Example usage
class Button {
  click() {
    console.log("Button clicked!");
  }
}

const ThrottledButton = Throttled(Button, 1000);
const button = new ThrottledButton();

// Wrap the method with throttling
const originalClick = button.click;
button.click = button.throttle(originalClick, "click");

// Now clicking repeatedly will only trigger once per second
```

### Comparison with Other Patterns

Mixins are one of several patterns for code reuse in TypeScript:

**Key Points**

- **Inheritance**: Simple but creates tight coupling and rigid hierarchies
- **Mixins**: More flexible than inheritance but can make code harder to follow
- **HOCs (Higher Order Components)**: Popular in React, similar to mixins but with different composition
- **Hooks**: Modern alternative for function components that provides mixin-like benefits
- **Decorators**: Used for annotating and modifying classes and members

### TypeScript Ecosystem Mixin Libraries

Several libraries provide enhanced mixin capabilities for TypeScript:

**Key Points**

- **ts-mixer**: Powerful mixin library with automatic mixin application
- **mixin-decorators**: Uses decorators to apply mixins
- **typescript-mixin-class**: Focuses on class-based mixins with strong typing
- **trait-decorators**: Implements trait-like patterns in TypeScript

### Conclusion

Mixins in TypeScript provide a powerful way to implement composition-based code reuse. Whether using the class-based approach, function mixins, or leveraging external libraries, mixins offer flexibility that traditional inheritance cannot match. Understanding how to create, apply, and combine mixins effectively will help you write more maintainable and modular TypeScript code.

For more advanced TypeScript concepts, consider exploring these related topics:

- Decorators and how they compare to mixins
- Higher-order components in React
- The Proxy pattern in TypeScript
- TypeScript's utility types and conditional types

---

## Advanced Class Features in TypeScript

### Understanding TypeScript Classes Beyond the Basics

TypeScript extends JavaScript's class-based programming with additional features that enhance type safety, encapsulation, and code organization. These advanced features enable more sophisticated design patterns and architectures while maintaining strong type checking.

### Static Members

Static members belong to the class itself rather than instances of the class. They're shared across all instances and can be accessed without creating an object.

#### Static Properties

Static properties store class-level data that remains consistent across all instances:

```typescript
class MathOperations {
  // Static property
  static PI: number = 3.14159;
  
  // Static property with readonly modifier
  static readonly GOLDEN_RATIO: number = 1.618;
  
  // Instance property (for comparison)
  scale: number;
  
  constructor(scale: number) {
    this.scale = scale;
  }
}

// Accessing static properties
console.log(MathOperations.PI); // 3.14159
console.log(MathOperations.GOLDEN_RATIO); // 1.618

// Cannot modify readonly static properties
// MathOperations.GOLDEN_RATIO = 1.62; // Error
```

#### Static Methods

Static methods provide utility functions that operate at the class level:

```typescript
class StringUtils {
  // Static method
  static capitalize(str: string): string {
    return str.charAt(0).toUpperCase() + str.slice(1);
  }
  
  // Static method with parameters
  static format(template: string, ...args: any[]): string {
    return template.replace(/{(\d+)}/g, (match, index) => {
      return typeof args[index] !== 'undefined' ? args[index] : match;
    });
  }
}

// Using static methods
const capitalized = StringUtils.capitalize("hello"); // "Hello"
const formatted = StringUtils.format("Hello, {0}! Today is {1}.", "Alice", "Monday");
// "Hello, Alice! Today is Monday."
```

#### Static Blocks

In TypeScript 4.4+, static blocks allow complex static initialization logic:

```typescript
class ConfigManager {
  static settings: Record<string, any> = {};
  
  // Static initialization block
  static {
    try {
      // Complex initialization logic
      const savedSettings = localStorage.getItem('appSettings');
      if (savedSettings) {
        ConfigManager.settings = JSON.parse(savedSettings);
      } else {
        ConfigManager.settings = { theme: 'light', fontSize: 14 };
      }
      
      // Validate settings
      if (!ConfigManager.settings.theme) {
        ConfigManager.settings.theme = 'light';
      }
    } catch (e) {
      console.error("Failed to initialize settings:", e);
      ConfigManager.settings = { theme: 'light', fontSize: 14 };
    }
  }
  
  static getSetting(key: string): any {
    return ConfigManager.settings[key];
  }
}
```

#### Static Members with Inheritance

Static members can be inherited but maintain their class-specific context:

```typescript
class Base {
  static count: number = 0;
  
  static incrementCount(): void {
    this.count++; // 'this' refers to the class, not an instance
  }
  
  constructor() {
    // Call the static method
    Base.incrementCount();
  }
}

class Derived extends Base {
  static override count: number = 0; // Shadows Base.count
  
  constructor() {
    super(); // Calls Base constructor, which increments Base.count
    Derived.incrementCount(); // Increments Derived.count
  }
}

const b1 = new Base();
const b2 = new Base();
const d1 = new Derived();

console.log(Base.count); // 3 (2 Base instances + 1 Derived through super())
console.log(Derived.count); // 1 (from Derived.incrementCount())
```

#### Practical Use Cases for Static Members

**Key Points:**

- Use static members for utility functions that don't need instance state
- Implement the Singleton pattern with static methods and private constructors
- Create factory methods that control instance creation
- Define constants and configuration values at the class level
- Implement caching or memoization across all instances

**Example:**

```typescript
class Database {
  private static instance: Database | null = null;
  private connections: Map<string, any> = new Map();
  
  private constructor() {
    // Private constructor prevents direct instantiation
  }
  
  // Singleton pattern implementation
  static getInstance(): Database {
    if (!Database.instance) {
      Database.instance = new Database();
    }
    return Database.instance;
  }
  
  // Factory method pattern
  static createConnection(config: DatabaseConfig): Connection {
    return new Connection(config);
  }
  
  // Static cache example
  private static queryCache: Map<string, any> = new Map();
  
  static async queryWithCache(sql: string): Promise<any> {
    if (Database.queryCache.has(sql)) {
      return Database.queryCache.get(sql);
    }
    
    const result = await Database.getInstance().executeQuery(sql);
    Database.queryCache.set(sql, result);
    return result;
  }
  
  private async executeQuery(sql: string): Promise<any> {
    // Implementation
    return { rows: [] };
  }
}
```

### Protected Constructors

Protected constructors limit instantiation of a class while still allowing inheritance, enabling more controlled class hierarchies and abstract base classes.

#### Basic Protected Constructor

```typescript
class Base {
  // Protected constructor
  protected constructor(protected name: string) {}
  
  getName(): string {
    return this.name;
  }
}

class Derived extends Base {
  constructor(name: string, private id: number) {
    super(name);
  }
  
  getInfo(): string {
    return `${this.getName()} (${this.id})`;
  }
}

// Cannot instantiate Base directly
// const base = new Base("test"); // Error: Constructor of class 'Base' is protected

// Can instantiate derived classes
const derived = new Derived("test", 123);
console.log(derived.getInfo()); // "test (123)"
```

#### Abstract Base Classes vs. Protected Constructors

Protected constructors differ from abstract classes:

```typescript
// Abstract class approach
abstract class Shape {
  constructor(protected color: string) {}
  
  abstract calculateArea(): number;
  
  getColor(): string {
    return this.color;
  }
}

class Circle extends Shape {
  constructor(color: string, private radius: number) {
    super(color);
  }
  
  calculateArea(): number {
    return Math.PI * this.radius * this.radius;
  }
}

// Protected constructor approach
class Vehicle {
  protected constructor(protected make: string, protected model: string) {}
  
  getDescription(): string {
    return `${this.make} ${this.model}`;
  }
  
  // Factory method to control instantiation
  static create(type: "car" | "truck", make: string, model: string): Car | Truck {
    if (type === "car") {
      return new Car(make, model);
    } else {
      return new Truck(make, model);
    }
  }
}

class Car extends Vehicle {
  // Making constructor public would allow direct instantiation
  constructor(make: string, model: string) {
    super(make, model);
  }
}

class Truck extends Vehicle {
  constructor(make: string, model: string) {
    super(make, model);
  }
  
  loadCargo(amount: number): void {
    console.log(`Loading ${amount} tons of cargo into ${this.make} ${this.model}`);
  }
}

// Cannot create Vehicle directly
// const v = new Vehicle("Honda", "Civic"); // Error

// Can create via factory method
const car = Vehicle.create("car", "Honda", "Civic");
const truck = Vehicle.create("truck", "Ford", "F-150");

// Or directly if the derived class constructor is public
const anotherCar = new Car("Toyota", "Camry");
```

#### Design Patterns with Protected Constructors

Protected constructors enable several design patterns:

1. **Abstract Factory Pattern**

```typescript
abstract class UIFactory {
  protected constructor() {}
  
  abstract createButton(): Button;
  abstract createInput(): Input;
  
  static getFactory(theme: "light" | "dark"): UIFactory {
    if (theme === "light") {
      return new LightThemeFactory();
    } else {
      return new DarkThemeFactory();
    }
  }
}

class LightThemeFactory extends UIFactory {
  constructor() {
    super();
  }
  
  createButton(): Button {
    return new LightButton();
  }
  
  createInput(): Input {
    return new LightInput();
  }
}

class DarkThemeFactory extends UIFactory {
  constructor() {
    super();
  }
  
  createButton(): Button {
    return new DarkButton();
  }
  
  createInput(): Input {
    return new DarkInput();
  }
}
```

2. **Template Method Pattern**

```typescript
class DataProcessor {
  protected constructor(protected data: any[]) {}
  
  // Template method
  process(): any[] {
    const validated = this.validate(this.data);
    const transformed = this.transform(validated);
    return this.format(transformed);
  }
  
  protected validate(data: any[]): any[] {
    // Default implementation
    return data.filter(item => item !== null && item !== undefined);
  }
  
  protected abstract transform(data: any[]): any[];
  
  protected format(data: any[]): any[] {
    // Default implementation
    return data;
  }
  
  static create(type: "numbers" | "strings", data: any[]): DataProcessor {
    if (type === "numbers") {
      return new NumberProcessor(data);
    } else {
      return new StringProcessor(data);
    }
  }
}

class NumberProcessor extends DataProcessor {
  constructor(data: any[]) {
    super(data);
  }
  
  protected transform(data: any[]): any[] {
    return data.map(item => typeof item === 'number' ? item * 2 : 0);
  }
}

class StringProcessor extends DataProcessor {
  constructor(data: any[]) {
    super(data);
  }
  
  protected transform(data: any[]): any[] {
    return data.map(item => typeof item === 'string' ? item.toUpperCase() : '');
  }
  
  protected override format(data: any[]): any[] {
    return data.map(item => `processed: ${item}`);
  }
}
```

### Method Decorators

Method decorators provide a way to modify, observe, or replace method definitions. They're applied using the `@decorator` syntax and executed when the class is defined.

#### Understanding Decorator Syntax

```typescript
// Basic method decorator
function log(target: any, propertyKey: string, descriptor: PropertyDescriptor) {
  const originalMethod = descriptor.value;
  
  descriptor.value = function(...args: any[]) {
    console.log(`Calling ${propertyKey} with arguments: ${JSON.stringify(args)}`);
    const result = originalMethod.apply(this, args);
    console.log(`Method ${propertyKey} returned: ${JSON.stringify(result)}`);
    return result;
  };
  
  return descriptor;
}

class Calculator {
  @log
  add(a: number, b: number): number {
    return a + b;
  }
}

const calc = new Calculator();
calc.add(2, 3);
// Output:
// Calling add with arguments: [2,3]
// Method add returned: 5
```

**Parameters**:

- `target`: The prototype of the class (for instance methods) or the constructor (for static methods).
- `propertyKey`: The name of the method (as a string).
- `descriptor`: A PropertyDescriptor object containing the method’s definition (e.g., value, writable, enumerable, configurable).

**Creating A Method Decorator**

A method decorator can:

- Modify the method’s implementation by altering the descriptor.value.
- Add side effects (e.g., logging) before or after the method call.
- Return a new PropertyDescriptor to replace the original method.

#### **Enabling Decorators**

To use decorators, ensure the following in tsconfig.json:

```json
{
  "compilerOptions": {
    "experimentalDecorators": true,
    "emitDecoratorMetadata": true
  }
}
```

- `experimentalDecorators`: Enables the decorator syntax.
- `emitDecoratorMetadata`: Adds metadata for reflection (optional, used by some frameworks).

#### Decorator Factories

Decorator factories let you customize decorators with parameters:

```typescript
// Decorator factory
function timeout(milliseconds: number) {
  return function(target: any, propertyKey: string, descriptor: PropertyDescriptor) {
    const originalMethod = descriptor.value;
    
    descriptor.value = function(...args: any[]) {
      console.log(`Setting timeout for ${propertyKey} (${milliseconds}ms)`);
      
      return new Promise<any>((resolve) => {
        setTimeout(() => {
          resolve(originalMethod.apply(this, args));
        }, milliseconds);
      });
    };
    
    return descriptor;
  };
}

class ApiService {
  @timeout(1000)
  async fetchData(endpoint: string): Promise<any> {
    // Simulate fetch operation
    console.log(`Fetching data from ${endpoint}`);
    return { data: "response" };
  }
}

// Usage
const api = new ApiService();
api.fetchData("/users").then(result => {
  console.log("Result:", result);
});
```

#### Common Method Decorator Patterns

1. **Memoization Decorator**

```typescript
function memoize(target: any, propertyKey: string, descriptor: PropertyDescriptor) {
  const originalMethod = descriptor.value;
  const cache = new Map<string, any>();
  
  descriptor.value = function(...args: any[]) {
    const key = JSON.stringify(args);
    
    if (cache.has(key)) {
      console.log(`Cache hit for ${propertyKey}(${key})`);
      return cache.get(key);
    }
    
    console.log(`Cache miss for ${propertyKey}(${key})`);
    const result = originalMethod.apply(this, args);
    cache.set(key, result);
    return result;
  };
  
  return descriptor;
}

class FibonacciCalculator {
  @memoize
  fibonacci(n: number): number {
    if (n <= 1) return n;
    return this.fibonacci(n - 1) + this.fibonacci(n - 2);
  }
}
```

2. **Validation Decorator**

```typescript
function validate(target: any, propertyKey: string, descriptor: PropertyDescriptor) {
  const originalMethod = descriptor.value;
  
  descriptor.value = function(...args: any[]) {
    // Get parameter types from metadata if available
    const paramTypes = Reflect.getMetadata("design:paramtypes", target, propertyKey);
    
    // Simple validation
    args.forEach((arg, index) => {
      if (arg === undefined || arg === null) {
        throw new Error(`Parameter at index ${index} is null or undefined`);
      }
      
      if (paramTypes && typeof arg !== typeof paramTypes[index].prototype) {
        throw new Error(
          `Parameter at index ${index} has incorrect type. ` +
          `Expected ${paramTypes[index].name}, got ${typeof arg}`
        );
      }
    });
    
    return originalMethod.apply(this, args);
  };
  
  return descriptor;
}

class UserService {
  @validate
  createUser(name: string, age: number): User {
    return { name, age };
  }
}
```

3. **Retry Decorator**

```typescript
function retry(attempts: number, delay: number = 500) {
  return function(target: any, propertyKey: string, descriptor: PropertyDescriptor) {
    const originalMethod = descriptor.value;
    
    descriptor.value = async function(...args: any[]) {
      let lastError: Error;
      
      for (let attempt = 1; attempt <= attempts; attempt++) {
        try {
          return await originalMethod.apply(this, args);
        } catch (error) {
          console.log(`Attempt ${attempt} failed for ${propertyKey}. Retrying in ${delay}ms...`);
          lastError = error;
          
          // Wait before next retry
          await new Promise(resolve => setTimeout(resolve, delay));
        }
      }
      
      throw new Error(`All ${attempts} attempts failed for ${propertyKey}: ${lastError.message}`);
    };
    
    return descriptor;
  };
}

class DataService {
  @retry(3, 1000)
  async fetchUserData(userId: string): Promise<UserData> {
    // Simulating unreliable API
    const random = Math.random();
    if (random < 0.7) {
      throw new Error("Connection failed");
    }
    
    return { id: userId, name: "User " + userId };
  }
}
```

4. **Access Control Decorator**

```typescript
// Simple role-based access control
function requireRole(role: string) {
  return function(target: any, propertyKey: string, descriptor: PropertyDescriptor) {
    const originalMethod = descriptor.value;
    
    descriptor.value = function(...args: any[]) {
      // In a real app, we'd get this from a session or token
      const userRole = (this as any).currentUserRole;
      
      if (!userRole || userRole !== role) {
        throw new Error(`Access denied: requires role '${role}'`);
      }
      
      return originalMethod.apply(this, args);
    };
    
    return descriptor;
  };
}

class AdminPanel {
  // Simulating user context
  currentUserRole: string;
  
  constructor(userRole: string) {
    this.currentUserRole = userRole;
  }
  
  @requireRole("admin")
  deleteUser(userId: string): void {
    console.log(`User ${userId} deleted`);
  }
  
  @requireRole("editor")
  editContent(contentId: string, newContent: string): void {
    console.log(`Content ${contentId} updated`);
  }
}
```

5. **Deprecation Decorator**

```typescript
function deprecated(message?: string) {
  return function(target: any, propertyKey: string, descriptor: PropertyDescriptor) {
    const originalMethod = descriptor.value;
    
    descriptor.value = function(...args: any[]) {
      console.warn(
        `[DEPRECATED] ${target.constructor.name}.${propertyKey} is deprecated.` +
        (message ? ` ${message}` : '')
      );
      
      return originalMethod.apply(this, args);
    };
    
    return descriptor;
  };
}

class LegacyAPI {
  @deprecated("Use fetchUsers() instead")
  getUsers(): User[] {
    return [{ name: "User 1" }, { name: "User 2" }];
  }
  
  fetchUsers(): User[] {
    return [{ name: "User 1" }, { name: "User 2" }];
  }
}
```

6. **Performance Monitoring Decorate**

```typescript
function MeasureTime(
  target: any,
  propertyKey: string,
  descriptor: PropertyDescriptor
): PropertyDescriptor {
  const original = descriptor.value;
  descriptor.value = function (...args: any[]): any {
    const start = performance.now();
    const result = original.apply(this, args);
    const duration = performance.now() - start;
    console.log(`${propertyKey} took ${duration.toFixed(2)}ms`);
    return result;
  };
  return descriptor;
}

class Processor {
  @MeasureTime
  compute(data: number[]): number {
    return data.reduce((sum, n) => sum + n, 0);
  }
}

const proc = new Processor();
proc.compute([1, 2, 3, 4, 5]); // compute took 0.12ms (example output)
```

7. **Authorization Decorator**

```typescript
function RestrictAccess(role: string) {
  return function (
    target: any,
    propertyKey: string,
    descriptor: PropertyDescriptor
  ): PropertyDescriptor {
    const original = descriptor.value;
    descriptor.value = function (...args: any[]): any {
      const userRole = args[0]?.role || "guest";
      if (userRole !== role) {
        throw new Error(`Access denied: ${propertyKey} requires ${role} role`);
      }
      return original.apply(this, args);
    };
    return descriptor;
  };
}

class AdminPanel {
  @RestrictAccess("admin")
  deleteUser(user: { role: string; id: number }): string {
    return `User ${user.id} deleted`;
  }
}

const panel = new AdminPanel();
console.log(panel.deleteUser({ role: "admin", id: 1 })); // User 1 deleted
panel.deleteUser({ role: "user", id: 2 }); // Error: Access denied
```

#### **Static Method Decorators**

Decorators can also be applied to static methods, where target is the class constructor.

```typescript
function LogStatic(
  target: any,
  propertyKey: string,
  descriptor: PropertyDescriptor
): PropertyDescriptor {
  const original = descriptor.value;
  descriptor.value = function (...args: any[]): any {
    console.log(`Static ${propertyKey} called with: ${args}`);
    return original.apply(this, args);
  };
  return descriptor;
}

class MathUtility {
  @LogStatic
  static add(x: number, y: number): number {
    return x + y;
  }
}

console.log(MathUtility.add(5, 3)); // Static add called with: 5,3
// Output: 8
```

#### **Multiple Decorators**

Multiple decorators can be applied to a method, executed **bottom-to-top** (last decorator runs first).

##### Example: Combining Decorators

```typescript
class Example {
  @LogMethod
  @MeasureTime
  process(data: number[]): number {
    return data.reduce((sum, n) => sum + n, 0);
  }
}

const ex = new Example();
ex.process([1, 2, 3]);
// Output:
// Calling process with arguments: [[1,2,3]]
// Result: 6
// process took 0.10ms
```

**Order**:
- `@MeasureTime` runs first, wrapping the method.
- `@LogMethod` runs next, wrapping the result of `@MeasureTime`.
- The original method is called last.
#### **TypeScript-Specific Considerations**
- **Type Safety**:
  - Decorators do not alter the method’s type signature, so TypeScript ensures type consistency.
  - Use precise types for arguments and return values to leverage strict checking.
  ```typescript
  function TypeSafeDecorator(
    target: any,
    propertyKey: string,
    descriptor: PropertyDescriptor
  ): PropertyDescriptor {
    const original = descriptor.value;
    descriptor.value = function (x: number): number {
      // TypeScript enforces x: number
      return original.apply(this, [x]);
    };
    return descriptor;
  }
  ```

- **Metadata**:
  - With `emitDecoratorMetadata`, decorators can use the `reflect-metadata` library to access type information.
  ```typescript
  import "reflect-metadata";

  function LogTypes(
    target: any,
    propertyKey: string,
    descriptor: PropertyDescriptor
  ): PropertyDescriptor {
    const types = Reflect.getMetadata("design:paramtypes", target, propertyKey);
    console.log(`${propertyKey} parameter types: ${types.map((t: any) => t.name)}`);
    return descriptor;
  }

  class Example {
    @LogTypes
    method(x: number, y: string): void {}
  }

  new Example(); // method parameter types: Number,String
  ```

- **Limitations**:
  - Decorators are experimental and may change in future ECMAScript standards.
  - They cannot change the method’s type signature (e.g., parameter types).
  - Overuse can make code harder to debug or maintain.

#### **Practical Recommendations**
- **Use Cases**:
  - Apply method decorators for cross-cutting concerns like logging, validation, or authorization.
  - Use in frameworks (e.g., NestJS `@Get`, Angular `@HostListener`) for metadata-driven behavior.
  - Simplify repetitive tasks (e.g., wrapping methods with error handling).

- **Best Practices**:
  - Keep decorators focused on a single responsibility (e.g., logging, not logging + validation).
  - Use factories for configurable decorators.
  - Document decorators clearly, as they can obscure method behavior.
  - Test decorated methods thoroughly, as wrappers may introduce subtle bugs.

- **Avoid Overuse**:
  - Limit decorators to scenarios where they add clear value, as excessive use can reduce code readability.
  - Prefer plain functions or utilities for simple logic.

### Property Decorators

Property decorators modify class properties. They're similar to method decorators but work on class fields rather than methods.

#### Basic Property Decorator

```typescript
function defaultValue(value: any) {
  return function(target: any, propertyKey: string) {
    // Store the default value in class definition
    Object.defineProperty(target, propertyKey, {
      value: value,
      writable: true,
      enumerable: true,
    });
  };
}

class Configuration {
  @defaultValue("development")
  environment: string;
  
  @defaultValue(8080)
  port: number;
  
  @defaultValue(false)
  debug: boolean;
}

const config = new Configuration();
console.log(config.environment); // "development"
console.log(config.port); // 8080
console.log(config.debug); // false

// Values can be changed
config.environment = "production";
console.log(config.environment); // "production"
```

#### Property Validation Decorators

```typescript
// String validation
function minLength(length: number) {
  return function(target: any, propertyKey: string) {
    // Property value storage
    let value: string;
    
    // Create property descriptor
    const descriptor = {
      get: function() {
        return value;
      },
      set: function(newValue: string) {
        if (newValue.length < length) {
          throw new Error(
            `Invalid ${propertyKey}: ${newValue}. ` +
            `Length must be at least ${length} characters.`
          );
        }
        value = newValue;
      },
      enumerable: true,
      configurable: true,
    };
    
    Object.defineProperty(target, propertyKey, descriptor);
  };
}

// Number range validation
function range(min: number, max: number) {
  return function(target: any, propertyKey: string) {
    // Property value storage
    let value: number;
    
    // Create property descriptor
    const descriptor = {
      get: function() {
        return value;
      },
      set: function(newValue: number) {
        if (newValue < min || newValue > max) {
          throw new Error(
            `Invalid ${propertyKey}: ${newValue}. ` +
            `Value must be between ${min} and ${max}.`
          );
        }
        value = newValue;
      },
      enumerable: true,
      configurable: true,
    };
    
    Object.defineProperty(target, propertyKey, descriptor);
  };
}

class User {
  @minLength(3)
  name: string;
  
  @range(0, 120)
  age: number;
  
  constructor(name: string, age: number) {
    this.name = name;
    this.age = age;
  }
}

// Valid user
const user1 = new User("Alice", 30);

// Invalid name
try {
  const user2 = new User("Al", 25); // Throws error
} catch (e) {
  console.error(e.message); // "Invalid name: Al. Length must be at least 3 characters."
}

// Invalid age
try {
  const user3 = new User("Alice", 150); // Throws error
} catch (e) {
  console.error(e.message); // "Invalid age: 150. Value must be between 0 and 120."
}
```

#### Property Metadata and Reflection

TypeScript decorators become even more powerful when combined with metadata reflection:

```typescript
// First, enable metadata in tsconfig.json
// {
//   "compilerOptions": {
//     "experimentalDecorators": true,
//     "emitDecoratorMetadata": true
//   }
// }

import "reflect-metadata";

// Define property types for serialization
const SERIALIZABLE_KEY = "serializable:properties";

function serializable(target: any, propertyKey: string) {
  const properties: string[] = Reflect.getMetadata(SERIALIZABLE_KEY, target) || [];
  
  if (!properties.includes(propertyKey)) {
    properties.push(propertyKey);
    Reflect.defineMetadata(SERIALIZABLE_KEY, properties, target);
  }
}

// Method to serialize an object
function serialize(obj: any): string {
  const target = Object.getPrototypeOf(obj);
  const serializableProps: string[] = Reflect.getMetadata(SERIALIZABLE_KEY, target) || [];
  
  const serialized: Record<string, any> = {};
  
  serializableProps.forEach(prop => {
    serialized[prop] = obj[prop];
  });
  
  return JSON.stringify(serialized);
}

// Method to deserialize an object
function deserialize<T>(json: string, type: new () => T): T {
  const data = JSON.parse(json);
  const instance = new type();
  const target = Object.getPrototypeOf(instance);
  const serializableProps: string[] = Reflect.getMetadata(SERIALIZABLE_KEY, target) || [];
  
  serializableProps.forEach(prop => {
    if (data.hasOwnProperty(prop)) {
      instance[prop] = data[prop];
    }
  });
  
  return instance;
}

class Person {
  @serializable
  name: string;
  
  @serializable
  age: number;
  
  // Not serializable
  private _internalId: string;
  
  constructor(name: string = '', age: number = 0) {
    this.name = name;
    this.age = age;
    this._internalId = Math.random().toString(36).substring(2);
  }
  
  get internalId(): string {
    return this._internalId;
  }
}

const person = new Person("Jane Doe", 32);
const serialized = serialize(person);
console.log(serialized); // {"name":"Jane Doe","age":32}

const deserialized = deserialize(serialized, Person);
console.log(deserialized.name); // "Jane Doe"
console.log(deserialized.age); // 32
console.log(deserialized.internalId); // New random ID, not the same as person.internalId
```

#### Observable Properties

```typescript
function observable(target: any, propertyKey: string) {
  // Property value storage
  const privateKey = Symbol(propertyKey);
  
  // Create property descriptor
  const descriptor = {
    get: function() {
      return this[privateKey];
    },
    set: function(newValue: any) {
      const oldValue = this[privateKey];
      this[privateKey] = newValue;
      
      // Notify observers
      if (this.propertyChanged && typeof this.propertyChanged === 'function') {
        this.propertyChanged(propertyKey, oldValue, newValue);
      }
    },
    enumerable: true,
    configurable: true,
  };
  
  Object.defineProperty(target, propertyKey, descriptor);
}

class ObservableComponent {
  @observable
  title: string;
  
  @observable
  count: number;
  
  constructor() {
    this.title = "Initial Title";
    this.count = 0;
  }
  
  // Observer method
  propertyChanged(property: string, oldValue: any, newValue: any) {
    console.log(`Property '${property}' changed from '${oldValue}' to '${newValue}'`);
    
    // In real apps, this might trigger UI updates, validation, etc.
    if (property === 'count' && newValue > 10) {
      console.log("Warning: Count is getting high!");
    }
  }
}

const component = new ObservableComponent();
component.title = "New Title"; // Property 'title' changed from 'Initial Title' to 'New Title'
component.count = 5; // Property 'count' changed from 0 to 5
component.count = 15; // Property 'count' changed from 5 to 15 + Warning: Count is getting high!
```

#### Combining Multiple Property Decorators

Multiple decorators can be applied to a single property, executing from bottom to top:

```typescript
function uppercase(target: any, propertyKey: string) {
  // Property value storage
  let value: string;
  
  // Create property descriptor
  const descriptor = {
    get: function() {
      return value; 
    },
    set: function(newValue: string) {
      value = newValue.toUpperCase();
    },
    enumerable: true,
    configurable: true,
  };
  
  Object.defineProperty(target, propertyKey, descriptor);
}

function trimmed(target: any, propertyKey: string) {
  // We need to get existing descriptors when chaining
  const originalDescriptor = Object.getOwnPropertyDescriptor(target, propertyKey) || {
    configurable: true,
    enumerable: true
  };
  
  // Keep reference to original setter
  const originalSetter = originalDescriptor.set;
  
  // Create new descriptor with modified setter
  originalDescriptor.set = function(newValue: string) {
    // Trim the string
    const trimmedValue = typeof newValue === 'string' ? newValue.trim() : newValue;
    
    // Call original setter
    if (originalSetter) {
      originalSetter.call(this, trimmedValue);
    } else {
      // If there's no setter yet, store the value directly
      Object.defineProperty(this, propertyKey, {
        value: trimmedValue,
        writable: true,
        configurable: true,
        enumerable: true
      });
    }
  };
  
  Object.defineProperty(target, propertyKey, originalDescriptor);
}

function log(target: any, propertyKey: string) {
  // We need to get existing descriptors when chaining
  const originalDescriptor = Object.getOwnPropertyDescriptor(target, propertyKey) || {
    configurable: true,
    enumerable: true
  };
  
  // Keep reference to original accessors
  const originalGetter = originalDescriptor.get;
  const originalSetter = originalDescriptor.set;
  
  // Create new descriptor with logging
  originalDescriptor.get = function() {
    const result = originalGetter ? originalGetter.call(this) : this[`_${propertyKey}`];
    console.log(`Getting ${propertyKey}: ${result}`);
    return result;
  };
  
  originalDescriptor.set = function(newValue: any) {
    console.log(`Setting ${propertyKey} to: ${newValue}`);
    if (originalSetter) {
      originalSetter.call(this, newValue);
    } else {
      this[`_${propertyKey}`] = newValue;
    }
  };
  
  Object.defineProperty(target, propertyKey, originalDescriptor);
}

class FormField {
  @log
  @uppercase
  @trimmed
  value: string;
  
  constructor(initialValue: string = '') {
    this.value = initialValue;
  }
}

const field = new FormField();
field.value = "  hello world  ";
// Output:
// Setting value to:   hello world  
// Getting value: HELLO WORLD
console.log(field.value);
```

### Combining Advanced Class Features

TypeScript's true power comes from combining multiple advanced class features to create robust, maintainable, and feature-rich class architectures. When used together strategically, these features enable sophisticated design patterns that would be difficult to implement in plain JavaScript.

**Key Points**

- Combining features like decorators, static members, and access modifiers creates powerful abstractions
- These combinations enable implementation of many design patterns
- Strategic use of combined features can improve code organization and type safety
- Careful combination helps balance flexibility with maintainability

Here's how these features can work together:

1. Decorator Composition
    - Multiple decorators can be applied to the same member
    - Decorators are applied in reverse order (bottom-up)
    - Different decorator types can complement each other
2. Static and Instance Member Interactions
    - Static methods can create and manipulate instances
    - Instance methods can access static members
    - Protected static members can be accessed by subclasses
3. Decorator and Inheritance Interplay
    - Decorators can affect inherited behavior
    - Subclasses can override decorated methods
    - Property decorators can ensure consistent behavior across inheritance chains

**Example**

Here's a comprehensive example combining multiple advanced class features:

```typescript
// Method and property decorators
function log(target: any, propertyKey: string, descriptor?: PropertyDescriptor) {
  // For methods
  if (descriptor) {
    const originalMethod = descriptor.value;
    descriptor.value = function(...args: any[]) {
      console.log(`Calling ${propertyKey} with arguments:`, args);
      const result = originalMethod.apply(this, args);
      console.log(`Result of ${propertyKey}:`, result);
      return result;
    };
    return descriptor;
  } 
  // For properties
  else {
    let value: any;
    const getter = function() {
      console.log(`Getting value of ${propertyKey}: ${value}`);
      return value;
    };
    const setter = function(newValue: any) {
      console.log(`Setting value of ${propertyKey} to: ${newValue}`);
      value = newValue;
    };
    Object.defineProperty(target, propertyKey, {
      get: getter,
      set: setter,
      enumerable: true,
      configurable: true
    });
  }
}

// Class decorator
function sealed(constructor: Function) {
  Object.seal(constructor);
  Object.seal(constructor.prototype);
}

// Abstract base class
abstract class DataProcessor {
  protected static readonly VERSION = "1.0.0";
  
  // Protected constructor
  protected constructor(protected readonly name: string) {
    console.log(`Creating ${this.constructor.name} instance`);
  }
  
  // Static factory method
  static create<T extends DataProcessor>(this: new(name: string) => T, name: string): T {
    return new this(name);
  }
  
  @log
  abstract process(data: any): any;
  
  static getVersion(): string {
    return DataProcessor.VERSION;
  }
}

// Concrete implementation with decorators
@sealed
class JSONProcessor extends DataProcessor {
  @log
  private _config: Record<string, any> = {};
  
  get config(): Record<string, any> {
    return { ...this._config };
  }
  
  set config(value: Record<string, any>) {
    this._config = { ...value };
  }
  
  @log
  process(data: any): any {
    return JSON.stringify(data, null, 2);
  }
  
  @log
  static validateJSON(input: string): boolean {
    try {
      JSON.parse(input);
      return true;
    } catch {
      return false;
    }
  }
}

// Usage
const processor = JSONProcessor.create("main-processor");
processor.config = { prettyPrint: true };
const result = processor.process({ name: "Test", value: 42 });
console.log(JSONProcessor.validateJSON(result));
console.log(`Processor version: ${DataProcessor.getVersion()}`);
```

This example demonstrates:

- Abstract class with protected constructor
- Static factory method pattern
- Method and property decorators for logging
- Class decorator to seal the class
- Protected static constants
- Accessor methods with decorators
- Inheritance with abstract methods
- Static utility methods

### Additional Advanced Class Features

Beyond what we've already covered, TypeScript offers several more advanced class features that can be powerful when used appropriately:

### Abstract Properties

Abstract properties define a contract that derived classes must implement, similar to abstract methods.

**Key Points**

- Abstract properties can be instance or static
- They require only a type signature in the abstract class
- Derived classes must provide an implementation
- Can be combined with access modifiers

```typescript
abstract class Shape {
  // Abstract property
  abstract color: string;
  
  // Abstract getter
  abstract get area(): number;
  
  // Abstract static property
  static abstract defaultColor: string;
}

class Circle extends Shape {
  // Implement abstract property
  color: string;
  
  // Static implementation of abstract static property
  static defaultColor = "black";
  
  constructor(public radius: number, color: string) {
    super();
    this.color = color || Circle.defaultColor;
  }
  
  // Implement abstract getter
  get area(): number {
    return Math.PI * this.radius * this.radius;
  }
}
```

### Index Signatures

Class properties can use index signatures to enable dynamic property access with type safety.

**Key Points**

- Index signatures define a pattern for property names and their types
- Enables flexible, dictionary-like behavior within classes
- Can be combined with other property declarations
- Works well with generics for type-safe dynamic data structures

```typescript
class Dictionary<T> {
  // Index signature
  [key: string]: T;
  
  // Regular properties must conform to the index signature type
  count: T;
  
  constructor(initialValue: T) {
    this.count = initialValue;
  }
  
  set(key: string, value: T): void {
    this[key] = value;
  }
  
  get(key: string): T {
    return this[key];
  }
}

const numberDict = new Dictionary<number>(0);
numberDict.set("one", 1);
numberDict.set("two", 2);
console.log(numberDict.get("one")); // 1
```

### Parameter Properties

Parameter properties provide a concise way to define and initialize class members directly in the constructor.

**Key Points**

- Combine parameter declaration and property initialization
- Work with all access modifiers (public, private, protected)
- Can use readonly modifier
- Simplify class definitions by reducing boilerplate

```typescript
class User {
  // Regular constructor approach
  // private id: number;
  // public name: string;
  // readonly email: string;
  //
  // constructor(id: number, name: string, email: string) {
  //   this.id = id;
  //   this.name = name;
  //   this.email = email;
  // }
  
  // Parameter properties approach
  constructor(
    private id: number,
    public name: string,
    readonly email: string
  ) {}
  
  getDetails(): string {
    return `User ${this.id}: ${this.name} (${this.email})`;
  }
}

const user = new User(1, "John Doe", "john@example.com");
console.log(user.name); // "John Doe"
console.log(user.email); // "john@example.com"
// console.log(user.id); // Error: Property 'id' is private
```

### Class Expressions

Similar to function expressions, TypeScript supports class expressions for creating anonymous classes or assigning classes to variables.

**Key Points**

- Create classes without declarations
- Useful for one-off class creation
- Can implement interfaces and extend other classes
- Support for generics, decorators, and other class features

```typescript
interface Runnable {
  run(): void;
}

// Class expression implementing an interface
const Task = class implements Runnable {
  constructor(private name: string) {}
  
  run(): void {
    console.log(`Running task: ${this.name}`);
  }
};

// Generic class expression
const Box = class<T> {
  constructor(private value: T) {}
  
  get(): T {
    return this.value;
  }
};

const numberBox = new Box<number>(42);
console.log(numberBox.get()); // 42

// Immediately Invoked Class Expression (IICE)
const singleton = new (class {
  private static instance: any;
  
  constructor() {
    if (!singleton) {
      singleton = this;
    }
    return singleton;
  }
  
  sayHello(): void {
    console.log("Hello from singleton!");
  }
})();

singleton.sayHello(); // "Hello from singleton!"
```

### Constructor Overloads

TypeScript allows multiple constructor signatures to provide different ways to initialize a class.

**Key Points**

- Define multiple ways to create class instances
- Implementation constructor must be compatible with all overload signatures
- Increases API flexibility
- Improves type checking for class instantiation

```typescript
class Point {
  // Constructor overload signatures
  constructor(x: number, y: number);
  constructor(coords: [number, number]);
  constructor(x: number | [number, number], y?: number) {
    if (Array.isArray(x)) {
      this.x = x[0];
      this.y = x[1];
    } else {
      this.x = x;
      this.y = y!;
    }
  }

  x: number;
  y: number;
  
  toString(): string {
    return `(${this.x}, ${this.y})`;
  }
}

// Both ways work with proper type checking
const p1 = new Point(10, 20);
const p2 = new Point([30, 40]);
console.log(p1.toString()); // "(10, 20)"
console.log(p2.toString()); // "(30, 40)"
```

These advanced class features, when combined thoughtfully, allow TypeScript developers to create elegant, maintainable class hierarchies that leverage the full power of object-oriented programming while maintaining strong type safety.



---

# Asynchronous TypeScript

## Promises in TypeScript

### Understanding TypeScript Promises

TypeScript enhances JavaScript's Promise API by adding static typing to make asynchronous code more predictable and maintainable. A Promise represents an operation that hasn't completed yet but is expected to complete in the future, returning either a resolved value or rejection reason.

**Key Points**

- TypeScript Promises maintain the same runtime behavior as JavaScript Promises
- Type annotations provide compile-time safety for asynchronous operations
- TypeScript's type system ensures that promise chains maintain type consistency

### Promise Types

In TypeScript, a Promise is a generic type that takes a type parameter representing the resolved value:

```typescript
// Basic Promise type syntax
type MyPromise = Promise<T>
```

Common Promise type patterns:

```typescript
// Promise resolving to a string
const stringPromise: Promise<string> = Promise.resolve("Hello");

// Promise resolving to a number
const numberPromise: Promise<number> = Promise.resolve(42);

// Promise resolving to an object
interface User {
  id: number;
  name: string;
}
const userPromise: Promise<User> = Promise.resolve({ id: 1, name: "Alice" });

// Promise resolving to an array
const arrayPromise: Promise<number[]> = Promise.resolve([1, 2, 3]);

// Promise resolving to void (no meaningful value)
const voidPromise: Promise<void> = Promise.resolve();

// Promise resolving to another Promise (automatically flattened)
const nestedPromise: Promise<string> = Promise.resolve(Promise.resolve("Flattened"));

// Promise resolving to null or undefined
const nullablePromise: Promise<string | null> = Promise.resolve(null);
```

### Creating Typed Promises

TypeScript allows for several ways to create typed promises with appropriate type safety:

#### Using Promise Constructor

```typescript
// Creating a Promise with explicit type
const myPromise = new Promise<string>((resolve, reject) => {
  try {
    // Some asynchronous operation
    setTimeout(() => {
      resolve("Operation completed successfully");
    }, 1000);
  } catch (error) {
    reject(new Error("Operation failed"));
  }
});
```

#### Using Promise.resolve() and Promise.reject()

```typescript
// Explicitly typed resolved promise
const resolvedPromise: Promise<number> = Promise.resolve(42);

// Explicitly typed rejected promise
const rejectedPromise: Promise<never> = Promise.reject(new Error("Something went wrong"));
```

#### Creating Promise-Returning Functions

```typescript
// Function returning a typed Promise
function fetchUser(id: number): Promise<User> {
  return new Promise((resolve, reject) => {
    // Simulated API call
    setTimeout(() => {
      if (id > 0) {
        resolve({ id, name: `User ${id}` });
      } else {
        reject(new Error("Invalid user ID"));
      }
    }, 1000);
  });
}
```

#### Using Async/Await with TypeScript

```typescript
// Async function with return type annotation
async function getUserDetails(id: number): Promise<UserDetails> {
  const user = await fetchUser(id);
  const permissions = await fetchPermissions(user.id);
  
  return {
    ...user,
    permissions
  };
}

// TypeScript infers the return type as Promise<UserDetails>
async function processUser(id: number) {
  const user = await getUserDetails(id);
  return user.name.toUpperCase();
}
```

### Promise Chaining

TypeScript enforces type safety throughout promise chains, ensuring that the types align correctly at each step.

#### Basic Promise Chaining

```typescript
// Type-safe promise chain
fetchUser(123)
  .then((user: User) => user.id)      // Returns number
  .then((id: number) => id.toString()) // Returns string
  .then((str: string) => str.length)   // Returns number
  .catch((error: Error) => {
    console.error(error.message);
    return 0;  // Fallback value
  });
```

#### Transforming Types in Promise Chains

```typescript
// Transforming types through a chain
Promise.resolve({ firstName: "John", lastName: "Doe" })
  .then(person => `${person.firstName} ${person.lastName}`) // Returns string
  .then(fullName => fullName.split(" "))                    // Returns string[]
  .then(nameParts => nameParts.length)                      // Returns number
  .then(count => {
    console.log(`Name has ${count} parts`);
    return count > 1;                                       // Returns boolean
  });
```

#### Error Handling in Promise Chains

```typescript
function processData(input: string): Promise<number> {
  return Promise.resolve(input)
    .then(str => {
      if (!str.trim()) {
        throw new Error("Empty input");
      }
      return str.length;
    })
    .then(length => length * 2)
    .catch((error: Error) => {
      console.error("Processing failed:", error.message);
      return 0; // Fallback value with correct type
    });
}
```

### Advanced Promise Patterns

#### Promise.all with Type Safety

```typescript
// Using Promise.all with proper typing
const userPromise: Promise<User> = fetchUser(1);
const postsPromise: Promise<Post[]> = fetchPosts(1);
const settingsPromise: Promise<Settings> = fetchSettings(1);

// TypeScript infers the correct tuple type [User, Post[], Settings]
Promise.all([userPromise, postsPromise, settingsPromise])
  .then(([user, posts, settings]) => {
    // TypeScript knows the exact types of each tuple element
    console.log(user.name);        // User property
    console.log(posts.length);     // Post[] property
    console.log(settings.theme);   // Settings property
    
    return {
      username: user.name,
      postCount: posts.length,
      theme: settings.theme
    };
  });
```

#### Promise.race with Type Union

```typescript
// Promise.race returns a Promise with a union type
const timeoutPromise: Promise<"timeout"> = new Promise(resolve => 
  setTimeout(() => resolve("timeout"), 5000)
);
const dataPromise: Promise<User> = fetchUser(123);

// Result is either "timeout" or User
const result: Promise<"timeout" | User> = Promise.race([timeoutPromise, dataPromise]);

result.then(value => {
  if (value === "timeout") {
    // TypeScript knows value is string "timeout"
    console.log("Operation timed out");
  } else {
    // TypeScript knows value is User
    console.log("User:", value.name);
  }
});
```

#### Conditional Promise Types

```typescript
// Generic function with conditional Promise typing
function fetchResource<T extends "user" | "post" | "comment">(
  resourceType: T
): Promise
  T extends "user" ? User :
  T extends "post" ? Post :
  T extends "comment" ? Comment :
  never
> {
  switch (resourceType) {
    case "user":
      return fetchUser(1) as any;
    case "post":
      return fetchPost(1) as any;
    case "comment":
      return fetchComment(1) as any;
    default:
      return Promise.reject(new Error("Invalid resource type")) as any;
  }
}

// TypeScript infers correct return types
const user = await fetchResource("user");     // user is of type User
const post = await fetchResource("post");     // post is of type Post
const comment = await fetchResource("comment"); // comment is of type Comment
```

### Working with Promise Utilities

#### Custom Promise Timeout

```typescript
// Adding a timeout to any promise
function withTimeout<T>(promise: Promise<T>, timeoutMs: number): Promise<T> {
  const timeoutPromise = new Promise<never>((_, reject) => {
    setTimeout(() => reject(new Error(`Operation timed out after ${timeoutMs}ms`)), timeoutMs);
  });
  
  return Promise.race([promise, timeoutPromise]);
}

// Usage
const userWithTimeout = withTimeout(fetchUser(123), 3000);
userWithTimeout
  .then(user => console.log("User fetched:", user.name))
  .catch(error => console.error("Failed:", error.message));
```

#### Sequential Promise Execution

```typescript
// Process an array of items sequentially with promises
async function processSequentially<T, R>(
  items: T[],
  processor: (item: T, index: number) => Promise<R>
): Promise<R[]> {
  const results: R[] = [];
  
  for (let i = 0; i < items.length; i++) {
    const result = await processor(items[i], i);
    results.push(result);
  }
  
  return results;
}

// Usage
const userIds = [1, 2, 3, 4, 5];
const users = await processSequentially(userIds, async (id) => {
  const user = await fetchUser(id);
  return user;
});
```

### Error Handling Best Practices

#### Typed Error Handling

```typescript
// Custom error classes
class ApiError extends Error {
  statusCode: number;
  
  constructor(message: string, statusCode: number) {
    super(message);
    this.statusCode = statusCode;
    this.name = 'ApiError';
  }
}

class ValidationError extends Error {
  field: string;
  
  constructor(message: string, field: string) {
    super(message);
    this.field = field;
    this.name = 'ValidationError';
  }
}

// Type guard functions
function isApiError(error: unknown): error is ApiError {
  return error instanceof ApiError;
}

function isValidationError(error: unknown): error is ValidationError {
  return error instanceof ValidationError;
}

// Usage in async function
async function fetchUserSafely(id: number): Promise<User | null> {
  try {
    const user = await fetchUser(id);
    return user;
  } catch (error: unknown) {
    if (isApiError(error)) {
      // TypeScript knows error is ApiError
      if (error.statusCode === 404) {
        console.log("User not found");
        return null;
      }
      console.error(`API Error ${error.statusCode}: ${error.message}`);
    } else if (isValidationError(error)) {
      // TypeScript knows error is ValidationError
      console.error(`Validation failed for field "${error.field}": ${error.message}`);
    } else if (error instanceof Error) {
      // TypeScript knows error is Error
      console.error("Unexpected error:", error.message);
    } else {
      console.error("Unknown error occurred");
    }
    
    return null;
  }
}
```

### Integration with TypeScript Async/Await

TypeScript's async/await syntax builds on Promise types to create more readable asynchronous code:

```typescript
// Basic async/await with proper typing
async function loadUserDashboard(userId: number): Promise<Dashboard> {
  try {
    // Each awaited promise maintains its proper return type
    const user: User = await fetchUser(userId);
    const posts: Post[] = await fetchPosts(userId);
    const followers: User[] = await fetchFollowers(userId);
    
    // TypeScript enforces type checking on all return values
    return {
      userInfo: {
        id: user.id,
        name: user.name,
        profileUrl: user.profileUrl
      },
      stats: {
        postCount: posts.length,
        followerCount: followers.length
      },
      recentActivity: posts.slice(0, 3).map(post => ({
        title: post.title,
        date: post.createdAt
      }))
    };
  } catch (error) {
    console.error("Failed to load dashboard:", error);
    throw new Error("Dashboard loading failed");
  }
}
```

### Performance Optimization

#### Concurrent Promises with Promise.all

```typescript
// Load data concurrently when possible
async function loadUserProfile(userId: number): Promise<UserProfile> {
  // Start all requests concurrently
  const userPromise = fetchUser(userId);
  const postsPromise = fetchPosts(userId);
  const followersPromise = fetchFollowers(userId);
  
  // Await all results when needed
  const [user, posts, followers] = await Promise.all([
    userPromise,
    postsPromise,
    followersPromise
  ]);
  
  return {
    user,
    posts,
    followers
  };
}
```

### Testing TypeScript Promises

```typescript
// Jest test example with typed promises
describe('User Service', () => {
  test('fetchUser returns user object for valid ID', async () => {
    // Arrange
    const userId = 1;
    const expectedUser: User = { id: 1, name: 'Test User' };
    
    // Mock implementation
    jest.spyOn(api, 'get').mockResolvedValueOnce({ data: expectedUser });
    
    // Act
    const result = await userService.fetchUser(userId);
    
    // Assert
    expect(result).toEqual(expectedUser);
  });
  
  test('fetchUser throws ApiError for non-existent user', async () => {
    // Arrange
    const userId = 999;
    
    // Mock implementation
    jest.spyOn(api, 'get').mockRejectedValueOnce({
      response: { status: 404, data: { message: 'User not found' } }
    });
    
    // Act & Assert
    await expect(userService.fetchUser(userId))
      .rejects
      .toThrow(ApiError);
  });
});
```

### Real-World Examples

#### API Client with TypeScript Promises

```typescript
// API client with typed responses
class ApiClient {
  private baseUrl: string;
  
  constructor(baseUrl: string) {
    this.baseUrl = baseUrl;
  }
  
  async get<T>(endpoint: string): Promise<T> {
    try {
      const response = await fetch(`${this.baseUrl}${endpoint}`);
      
      if (!response.ok) {
        throw new ApiError(
          `Request failed with status ${response.status}`,
          response.status
        );
      }
      
      return await response.json() as T;
    } catch (error) {
      if (error instanceof ApiError) {
        throw error;
      }
      
      throw new Error(`Network request failed: ${error instanceof Error ? error.message : 'Unknown error'}`);
    }
  }
  
  async post<T, R>(endpoint: string, data: T): Promise<R> {
    try {
      const response = await fetch(`${this.baseUrl}${endpoint}`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify(data)
      });
      
      if (!response.ok) {
        throw new ApiError(
          `Request failed with status ${response.status}`,
          response.status
        );
      }
      
      return await response.json() as R;
    } catch (error) {
      if (error instanceof ApiError) {
        throw error;
      }
      
      throw new Error(`Network request failed: ${error instanceof Error ? error.message : 'Unknown error'}`);
    }
  }
}

// Usage
interface CreateUserDto {
  name: string;
  email: string;
}

interface UserDto {
  id: number;
  name: string;
  email: string;
  createdAt: string;
}

const api = new ApiClient('https://api.example.com');

// TypeScript ensures type safety throughout the Promise chain
async function createAndFetchUser(userData: CreateUserDto): Promise<UserDto> {
  const createdUser = await api.post<CreateUserDto, UserDto>('/users', userData);
  return api.get<UserDto>(`/users/${createdUser.id}`);
}
```

### Common Promise Pitfalls and Solutions

#### Handling Promise Rejection Types

```typescript
// BAD: Losing type information in catch
fetchUser(1)
  .then(user => user)
  .catch(error => {
    // error is just of type unknown or any
    console.log(error.message); // TypeScript may warn about this
    return { id: 0, name: "Default User" }; // Fallback user
  });

// GOOD: Properly typing errors
fetchUser(1)
  .then(user => user)
  .catch((error: unknown) => {
    if (error instanceof Error) {
      console.log(error.message); // TypeScript knows error is Error
    } else {
      console.log("Unknown error occurred");
    }
    return { id: 0, name: "Default User" }; // Fallback user
  });
```

#### Properly Typing Conditional Promise Chains

```typescript
// BAD: Inconsistent return types in then callbacks
fetchUser(1)
  .then(user => {
    if (user.isAdmin) {
      return fetchAdminDashboard(user.id);
    } else {
      return null; // Different type from the first branch
    }
  })
  .then(dashboard => {
    // dashboard could be AdminDashboard | null
    // TypeScript might not catch potential null references
    console.log(dashboard.statistics); // Potential error
  });

// GOOD: Consistent typing with proper null handling
fetchUser(1)
  .then(user => {
    if (user.isAdmin) {
      return fetchAdminDashboard(user.id);
    } else {
      return Promise.resolve(null); 
    }
  })
  .then(dashboard => {
    // TypeScript knows dashboard could be null
    if (dashboard) {
      console.log(dashboard.statistics); // Safe access
    } else {
      console.log("No dashboard available");
    }
  });
```

### Modern TypeScript Promise Patterns

#### Using Promise with Discriminated Unions

```typescript
// Result type pattern
type Result<T, E = Error> = 
  | { success: true; value: T }
  | { success: false; error: E };

// Function that returns a typed Result promise
async function tryFetchUser(id: number): Promise<Result<User, ApiError>> {
  try {
    const user = await fetchUser(id);
    return { success: true, value: user };
  } catch (error) {
    if (error instanceof ApiError) {
      return { success: false, error };
    }
    return { 
      success: false, 
      error: new ApiError('Unknown error', 500) 
    };
  }
}

// Usage
const result = await tryFetchUser(123);
if (result.success) {
  // TypeScript knows we have a User
  console.log(`Found user: ${result.value.name}`);
} else {
  // TypeScript knows we have an ApiError
  console.log(`Error ${result.error.statusCode}: ${result.error.message}`);
}
```

#### Utilizing Promise with Generic Constraints

```typescript
// Generic function with constrained types
async function fetchEntities<T extends { id: number }>(
  ids: number[], 
  fetcher: (id: number) => Promise<T>
): Promise<T[]> {
  return Promise.all(ids.map(id => fetcher(id)));
}

// Usage
interface Product { id: number; name: string; price: number; }
interface Order { id: number; items: string[]; total: number; }

// TypeScript infers correct return types
const products = await fetchEntities<Product>([1, 2, 3], fetchProduct);
const orders = await fetchEntities<Order>([100, 101], fetchOrder);

// Type safety is maintained
products.forEach(product => console.log(product.price)); // Works
orders.forEach(order => console.log(order.total));       // Works
```

**Conclusion** TypeScript's Promise implementation provides robust type safety for asynchronous operations, helping catch potential errors at compile time rather than runtime. By properly typing your promises, you can create more maintainable code with better developer experience through improved IDE support, autocompletion, and static analysis. Understanding the various patterns for working with promises in TypeScript is essential for building reliable and type-safe asynchronous applications.

---

## Async/Await in TypeScript

### Understanding Async/Await

Async/await is a modern JavaScript feature fully supported in TypeScript that provides a cleaner syntax for working with Promises. It allows asynchronous code to be written in a style that appears synchronous, making it more readable and maintainable.

**Key Points**

- `async` and `await` are TypeScript/JavaScript keywords introduced in ES2017
- An `async` function always returns a Promise
- The `await` keyword can only be used inside `async` functions (or in top-level code in modern environments)
- TypeScript provides strong typing for async operations
- Async/await is syntactic sugar over Promises

### Typing Async Functions

TypeScript enhances async/await with static type checking, making your asynchronous code more robust.

```typescript
// Basic async function typing
async function fetchData(): Promise<string> {
  // TypeScript knows this function returns a Promise<string>
  const response = await fetch('https://api.example.com/data');
  const text = await response.text();
  return text; // TypeScript ensures this is a string
}

// Arrow function with async
const getData = async (): Promise<Record<string, any>> => {
  const response = await fetch('https://api.example.com/data');
  const data = await response.json();
  return data; // TypeScript ensures this matches the return type
};

// Async methods in classes
class DataService {
  async fetchUsers(): Promise<User[]> {
    const response = await fetch('https://api.example.com/users');
    const users = await response.json();
    return users as User[]; // Type assertion for the parsed JSON
  }
}

// Interface for async functions
interface AsyncProcessor<T, R> {
  process(input: T): Promise<R>;
}

class DataProcessor implements AsyncProcessor<string, number> {
  async process(input: string): Promise<number> {
    // Implementation goes here
    return input.length;
  }
}
```

**Example** Creating a typed API client:

```typescript
// Define response types
interface User {
  id: number;
  name: string;
  email: string;
}

interface Post {
  id: number;
  userId: number;
  title: string;
  body: string;
}

// API client with typed async methods
class ApiClient {
  private baseUrl: string;
  
  constructor(baseUrl: string) {
    this.baseUrl = baseUrl;
  }
  
  async getUser(id: number): Promise<User> {
    const response = await fetch(`${this.baseUrl}/users/${id}`);
    
    if (!response.ok) {
      throw new Error(`Failed to fetch user: ${response.statusText}`);
    }
    
    return await response.json() as User;
  }
  
  async getUserPosts(userId: number): Promise<Post[]> {
    const response = await fetch(`${this.baseUrl}/users/${userId}/posts`);
    
    if (!response.ok) {
      throw new Error(`Failed to fetch posts: ${response.statusText}`);
    }
    
    return await response.json() as Post[];
  }
  
  async createPost(userId: number, title: string, body: string): Promise<Post> {
    const response = await fetch(`${this.baseUrl}/posts`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({ userId, title, body })
    });
    
    if (!response.ok) {
      throw new Error(`Failed to create post: ${response.statusText}`);
    }
    
    return await response.json() as Post;
  }
}

// Usage
const api = new ApiClient('https://api.example.com');

async function getUserWithPosts(userId: number): Promise<{user: User, posts: Post[]}> {
  const user = await api.getUser(userId);
  const posts = await api.getUserPosts(userId);
  
  return { user, posts };
}
```

### Generic Async Types

TypeScript's generic types work seamlessly with async functions:

```typescript
// Generic async function
async function processItems<T, R>(
  items: T[],
  processor: (item: T) => Promise<R>
): Promise<R[]> {
  const results: R[] = [];
  
  for (const item of items) {
    results.push(await processor(item));
  }
  
  return results;
}

// Usage
interface Product {
  id: string;
  name: string;
}

async function fetchProductDetails(id: string): Promise<Product> {
  const response = await fetch(`https://api.example.com/products/${id}`);
  return await response.json() as Product;
}

// TypeScript infers the correct types
const productIds = ['p1', 'p2', 'p3'];
const products = await processItems(productIds, fetchProductDetails);
// products is inferred as Product[]
```

### Error Handling with Async/Await

Error handling is one of the major advantages of async/await over traditional Promise chains. TypeScript enhances this with type checking for caught errors.

```typescript
// Basic try/catch
async function fetchData(): Promise<string> {
  try {
    const response = await fetch('https://api.example.com/data');
    
    if (!response.ok) {
      throw new Error(`HTTP error: ${response.status}`);
    }
    
    return await response.text();
  } catch (error) {
    // TypeScript 4.0+ allows type checking on error
    if (error instanceof Error) {
      console.error(`Error fetching data: ${error.message}`);
    } else {
      console.error(`Unknown error: ${String(error)}`);
    }
    throw error; // Re-throw or return a default value
  }
}

// Error boundaries pattern
async function withErrorBoundary<T>(
  operation: () => Promise<T>,
  fallback: T
): Promise<T> {
  try {
    return await operation();
  } catch (error) {
    console.error('Operation failed:', error);
    return fallback;
  }
}

// Usage
const data = await withErrorBoundary(
  () => fetchData(),
  'Default data'
);
```

**Example** Creating a robust error handling utility:

```typescript
// Define custom error types
class ApiError extends Error {
  constructor(
    public statusCode: number,
    message: string,
    public details?: any
  ) {
    super(message);
    this.name = 'ApiError';
  }
}

class NetworkError extends Error {
  constructor(message: string, public request?: Request) {
    super(message);
    this.name = 'NetworkError';
  }
}

class TimeoutError extends Error {
  constructor(message: string, public timeoutMs: number) {
    super(message);
    this.name = 'TimeoutError';
  }
}

// Type guard functions
function isApiError(error: unknown): error is ApiError {
  return error instanceof Error && error.name === 'ApiError';
}

function isNetworkError(error: unknown): error is NetworkError {
  return error instanceof Error && error.name === 'NetworkError';
}

function isTimeoutError(error: unknown): error is TimeoutError {
  return error instanceof Error && error.name === 'TimeoutError';
}

// Enhanced fetch with error handling
async function safeFetch<T>(
  url: string,
  options?: RequestInit,
  timeoutMs: number = 10000
): Promise<T> {
  // Create abort controller for timeout
  const controller = new AbortController();
  const timeoutId = setTimeout(() => controller.abort(), timeoutMs);
  
  try {
    const response = await fetch(url, {
      ...options,
      signal: controller.signal
    });
    
    clearTimeout(timeoutId);
    
    if (!response.ok) {
      let details;
      try {
        details = await response.json();
      } catch {
        // Ignore if response body is not valid JSON
      }
      
      throw new ApiError(
        response.status,
        `API error: ${response.statusText}`,
        details
      );
    }
    
    return await response.json() as T;
  } catch (error) {
    clearTimeout(timeoutId);
    
    if (error instanceof DOMException && error.name === 'AbortError') {
      throw new TimeoutError(`Request timed out after ${timeoutMs}ms`, timeoutMs);
    }
    
    if (error instanceof TypeError) {
      throw new NetworkError('Network error occurred');
    }
    
    throw error; // Re-throw ApiError or other errors
  }
}

// Usage with proper error handling
async function getUserData(userId: string): Promise<User> {
  try {
    return await safeFetch<User>(`https://api.example.com/users/${userId}`);
  } catch (error) {
    if (isApiError(error)) {
      if (error.statusCode === 404) {
        throw new Error(`User with ID ${userId} not found`);
      } else {
        throw new Error(`API error: ${error.message}`);
      }
    } else if (isTimeoutError(error)) {
      throw new Error(`Request timed out after ${error.timeoutMs}ms`);
    } else if (isNetworkError(error)) {
      throw new Error('Network connection issue. Please check your internet connection');
    } else {
      throw new Error(`Unknown error: ${String(error)}`);
    }
  }
}
```

### Parallel Execution

One of the significant advantages of async/await is the ability to perform operations in parallel when appropriate.

```typescript
// Promise.all for parallel execution
async function fetchMultipleResources(): Promise<[string, object, number[]]> {
  const [textData, jsonData, numberData] = await Promise.all([
    fetch('https://api.example.com/text').then(r => r.text()),
    fetch('https://api.example.com/json').then(r => r.json()),
    fetch('https://api.example.com/numbers').then(r => r.json())
  ]);
  
  return [textData, jsonData, numberData];
}

// Promise.allSettled for handling potential failures
async function fetchResourcesSafely<T>(
  urls: string[]
): Promise<{ status: 'fulfilled' | 'rejected', value?: T, reason?: any }[]> {
  const promises = urls.map(url => 
    fetch(url).then(r => r.json() as T)
  );
  
  const results = await Promise.allSettled(promises);
  return results as any; // Type assertion to simplify
}

// Promise.any to get the first successful result
async function fetchFirstAvailable<T>(apis: string[]): Promise<T> {
  try {
    return await Promise.any(apis.map(api => 
      fetch(api).then(r => {
        if (!r.ok) throw new Error(`API ${api} failed`);
        return r.json() as T;
      })
    ));
  } catch (error) {
    if (error instanceof AggregateError) {
      throw new Error(`All APIs failed: ${error.errors.map(e => e.message).join(', ')}`);
    }
    throw error;
  }
}

// Using Promise.race for timeouts
async function fetchWithTimeout<T>(
  url: string, 
  timeoutMs: number
): Promise<T> {
  const timeoutPromise = new Promise<never>((_, reject) => {
    setTimeout(() => reject(new Error(`Request timed out after ${timeoutMs}ms`)), timeoutMs);
  });
  
  const dataPromise = fetch(url).then(r => r.json() as T);
  
  return Promise.race([dataPromise, timeoutPromise]);
}
```

**Example** Loading data for a dashboard:

```typescript
interface UserStats {
  id: string;
  visitCount: number;
  lastActive: string;
}

interface SystemStats {
  cpuUsage: number;
  memoryUsage: number;
  uptime: number;
}

interface ActivityLog {
  timestamp: string;
  action: string;
  userId?: string;
}

async function loadDashboardData(
  apiBaseUrl: string
): Promise<{
  userStats: UserStats[];
  systemStats: SystemStats;
  recentActivity: ActivityLog[];
  errors: string[];
}> {
  const errors: string[] = [];
  
  // Define fetch functions
  const fetchUserStats = async (): Promise<UserStats[]> => {
    try {
      const response = await fetch(`${apiBaseUrl}/users/stats`);
      if (!response.ok) throw new Error(`HTTP error ${response.status}`);
      return await response.json();
    } catch (error) {
      errors.push(`Failed to fetch user stats: ${error instanceof Error ? error.message : String(error)}`);
      return [];
    }
  };
  
  const fetchSystemStats = async (): Promise<SystemStats> => {
    try {
      const response = await fetch(`${apiBaseUrl}/system/stats`);
      if (!response.ok) throw new Error(`HTTP error ${response.status}`);
      return await response.json();
    } catch (error) {
      errors.push(`Failed to fetch system stats: ${error instanceof Error ? error.message : String(error)}`);
      return { cpuUsage: 0, memoryUsage: 0, uptime: 0 };
    }
  };
  
  const fetchRecentActivity = async (): Promise<ActivityLog[]> => {
    try {
      const response = await fetch(`${apiBaseUrl}/activity/recent`);
      if (!response.ok) throw new Error(`HTTP error ${response.status}`);
      return await response.json();
    } catch (error) {
      errors.push(`Failed to fetch activity logs: ${error instanceof Error ? error.message : String(error)}`);
      return [];
    }
  };
  
  // Fetch all data in parallel
  const [userStats, systemStats, recentActivity] = await Promise.all([
    fetchUserStats(),
    fetchSystemStats(),
    fetchRecentActivity()
  ]);
  
  return {
    userStats,
    systemStats,
    recentActivity,
    errors
  };
}
```

### Sequential vs Concurrent Operations

Understanding when to run operations sequentially versus concurrently is crucial for optimal performance.

```typescript
// Sequential execution (when operations depend on each other)
async function processUserData(userId: string): Promise<ProcessedUserData> {
  // Each step depends on the previous one
  const user = await fetchUser(userId);
  const permissions = await fetchUserPermissions(user.id);
  const enrichedUser = await enrichUserData(user, permissions);
  return processData(enrichedUser);
}

// Concurrent execution (when operations are independent)
async function loadUserProfile(userId: string): Promise<UserProfile> {
  // These operations don't depend on each other and can run in parallel
  const [user, posts, followers] = await Promise.all([
    fetchUser(userId),
    fetchUserPosts(userId),
    fetchUserFollowers(userId)
  ]);
  
  return {
    ...user,
    posts,
    followers
  };
}

// Controlled concurrency (batch processing)
async function processItems<T, R>(
  items: T[],
  processor: (item: T) => Promise<R>,
  concurrency: number = 5
): Promise<R[]> {
  const results: R[] = [];
  const chunks = [];
  
  // Split items into chunks
  for (let i = 0; i < items.length; i += concurrency) {
    chunks.push(items.slice(i, i + concurrency));
  }
  
  // Process chunks sequentially, but items within a chunk concurrently
  for (const chunk of chunks) {
    const chunkResults = await Promise.all(
      chunk.map(item => processor(item))
    );
    results.push(...chunkResults);
  }
  
  return results;
}
```

**Example** Building a file processing pipeline:

```typescript
interface FileMetadata {
  id: string;
  name: string;
  size: number;
  type: string;
}

interface ProcessedFile extends FileMetadata {
  processedUrl: string;
  thumbnailUrl: string;
  processingTime: number;
}

class FileProcessor {
  async processFiles(
    files: File[],
    concurrency: number = 3
  ): Promise<ProcessedFile[]> {
    // Split into chunks to control concurrency
    const chunks: File[][] = [];
    for (let i = 0; i < files.length; i += concurrency) {
      chunks.push(files.slice(i, i + concurrency));
    }
    
    const results: ProcessedFile[] = [];
    
    // Process each chunk with controlled concurrency
    for (const chunk of chunks) {
      const chunkResults = await Promise.all(
        chunk.map(file => this.processSingleFile(file))
      );
      results.push(...chunkResults);
    }
    
    return results;
  }
  
  private async processSingleFile(file: File): Promise<ProcessedFile> {
    // These steps must happen sequentially as they depend on previous results
    const startTime = Date.now();
    
    // Step 1: Upload file to server
    const metadata = await this.uploadFile(file);
    
    // Step 2: Trigger processing on server
    const processedData = await this.triggerProcessing(metadata.id);
    
    // Step 3: Generate thumbnail (can happen in parallel with Step 2)
    const thumbnailData = await this.generateThumbnail(file);
    
    const processingTime = Date.now() - startTime;
    
    return {
      ...metadata,
      processedUrl: processedData.url,
      thumbnailUrl: thumbnailData.url,
      processingTime
    };
  }
  
  private async uploadFile(file: File): Promise<FileMetadata> {
    // Simulate file upload
    await new Promise(resolve => setTimeout(resolve, 500));
    
    return {
      id: `file-${Math.random().toString(36).substr(2, 9)}`,
      name: file.name,
      size: file.size,
      type: file.type
    };
  }
  
  private async triggerProcessing(fileId: string): Promise<{ url: string }> {
    // Simulate server-side processing
    await new Promise(resolve => setTimeout(resolve, 1000));
    
    return {
      url: `https://example.com/processed/${fileId}`
    };
  }
  
  private async generateThumbnail(file: File): Promise<{ url: string }> {
    // Simulate thumbnail generation
    await new Promise(resolve => setTimeout(resolve, 300));
    
    return {
      url: `https://example.com/thumbnails/${file.name.replace(/\s/g, '-')}`
    };
  }
}

// Usage
const processor = new FileProcessor();
const processedFiles = await processor.processFiles(userFiles, 3);
```

### Handling Async Patterns in TypeScript

#### Async Iteration

TypeScript fully supports the async iterator protocol:

```typescript
// Async generator function
async function* generateAsyncSequence(start: number, end: number): AsyncGenerator<number> {
  for (let i = start; i <= end; i++) {
    // Simulate async delay
    await new Promise(resolve => setTimeout(resolve, 100));
    yield i;
  }
}

// Using async iteration
async function sumAsyncSequence(): Promise<number> {
  let sum = 0;
  
  // Using for-await-of loop
  for await (const num of generateAsyncSequence(1, 5)) {
    sum += num;
  }
  
  return sum;
}

// Creating an async iterable class
class AsyncCollection<T> implements AsyncIterable<T> {
  private items: T[];
  
  constructor(items: T[]) {
    this.items = [...items];
  }
  
  async *[Symbol.asyncIterator](): AsyncIterator<T> {
    for (const item of this.items) {
      // Simulate network delay
      await new Promise(resolve => setTimeout(resolve, 100));
      yield item;
    }
  }
  
  // Example async method using the iterator
  async map<R>(fn: (item: T) => Promise<R>): Promise<R[]> {
    const results: R[] = [];
    for await (const item of this) {
      results.push(await fn(item));
    }
    return results;
  }
}

// Usage
const collection = new AsyncCollection([1, 2, 3, 4, 5]);
const doubled = await collection.map(async num => num * 2);
console.log(doubled); // [2, 4, 6, 8, 10]
```

#### Cancellation Patterns

Managing cancellation is essential for resource-intensive async operations:

```typescript
// Using AbortController for cancellation
async function fetchWithCancellation<T>(
  url: string,
  signal: AbortSignal
): Promise<T> {
  const response = await fetch(url, { signal });
  
  if (!response.ok) {
    throw new Error(`HTTP error: ${response.status}`);
  }
  
  return await response.json() as T;
}

// Usage
const controller = new AbortController();
const signal = controller.signal;

// Cancel after 5 seconds
setTimeout(() => controller.abort(), 5000);

try {
  const data = await fetchWithCancellation<User[]>('https://api.example.com/users', signal);
  processUsers(data);
} catch (error) {
  if (error instanceof DOMException && error.name === 'AbortError') {
    console.log('Fetch was cancelled');
  } else {
    console.error('Fetch error:', error);
  }
}
```

#### Debouncing Async Operations

TypeScript implementation of debounced async functions:

```typescript
// Debounce utility for async functions
function debounce<T extends (...args: any[]) => Promise<any>>(
  fn: T,
  delay: number
): (...args: Parameters<T>) => Promise<ReturnType<T>> {
  let timeout: NodeJS.Timeout | undefined;
  
  return (...args: Parameters<T>): Promise<ReturnType<T>> => {
    return new Promise(resolve => {
      if (timeout) {
        clearTimeout(timeout);
      }
      
      timeout = setTimeout(async () => {
        const result = await fn(...args);
        resolve(result as ReturnType<T>);
      }, delay);
    });
  };
}

// Usage
const debouncedSearch = debounce(async (query: string): Promise<SearchResult[]> => {
  const response = await fetch(`https://api.example.com/search?q=${encodeURIComponent(query)}`);
  return await response.json();
}, 300);

// Then in an event handler
searchInput.addEventListener('input', async (e) => {
  const query = (e.target as HTMLInputElement).value;
  const results = await debouncedSearch(query);
  displayResults(results);
});
```

### Testing Async Code

TypeScript provides excellent tooling for testing async code:

```typescript
// Using Jest with TypeScript for async testing
describe('UserService', () => {
  let service: UserService;
  
  beforeEach(() => {
    service = new UserService();
  });
  
  // Testing async functions
  test('should fetch user by ID', async () => {
    // Arrange
    const userId = '123';
    const mockUser = { id: userId, name: 'Test User' };
    
    // Mock the fetch function
    global.fetch = jest.fn().mockResolvedValue({
      ok: true,
      json: async () => mockUser
    });
    
    // Act
    const result = await service.getUserById(userId);
    
    // Assert
    expect(result).toEqual(mockUser);
    expect(fetch).toHaveBeenCalledWith(`https://api.example.com/users/${userId}`);
  });
  
  // Testing error handling
  test('should handle API errors', async () => {
    // Arrange
    const userId = '123';
    
    // Mock a failed response
    global.fetch = jest.fn().mockResolvedValue({
      ok: false,
      status: 404,
      statusText: 'Not Found'
    });
    
    // Act & Assert
    await expect(service.getUserById(userId)).rejects.toThrow('API error: Not Found');
  });
  
  // Testing timeout behavior
  test('should time out after specified duration', async () => {
    // Arrange
    jest.useFakeTimers();
    
    const fetchPromise = service.fetchWithTimeout('https://slow-api.example.com', 1000);
    
    // Fast-forward time
    jest.advanceTimersByTime(1001);
    
    // Assert
    await expect(fetchPromise).rejects.toThrow('Request timed out');
    
    jest.useRealTimers();
  });
});
```

### Advanced Async Patterns

#### Async Queue Implementation

Managing a queue of async tasks with controlled concurrency:

```typescript
interface Task<T> {
  execute: () => Promise<T>;
  resolve: (value: T) => void;
  reject: (error: Error) => void;
}

class AsyncQueue {
  private queue: Task<any>[] = [];
  private activeCount = 0;
  private readonly concurrency: number;
  
  constructor(concurrency: number = 1) {
    this.concurrency = concurrency;
  }
  
  public async add<T>(task: () => Promise<T>): Promise<T> {
    return new Promise<T>((resolve, reject) => {
      this.queue.push({
        execute: task,
        resolve,
        reject
      });
      
      this.processQueue();
    });
  }
  
  private async processQueue(): Promise<void> {
    if (this.activeCount >= this.concurrency || this.queue.length === 0) {
      return;
    }
    
    this.activeCount++;
    const task = this.queue.shift()!;
    
    try {
      const result = await task.execute();
      task.resolve(result);
    } catch (error) {
      task.reject(error instanceof Error ? error : new Error(String(error)));
    } finally {
      this.activeCount--;
      this.processQueue();
    }
  }
  
  public get pending(): number {
    return this.queue.length;
  }
  
  public get active(): number {
    return this.activeCount;
  }
}

// Usage
const queue = new AsyncQueue(3); // Process 3 tasks concurrently

for (let i = 0; i < 10; i++) {
  queue.add(async () => {
    console.log(`Starting task ${i}`);
    await new Promise(resolve => setTimeout(resolve, Math.random() * 1000));
    console.log(`Completed task ${i}`);
    return i;
  }).then(result => {
    console.log(`Got result: ${result}`);
  });
}

console.log(`Queued tasks: ${queue.pending}`);
```

#### Retry Pattern

Implementing a robust retry mechanism for async operations:

```typescript
interface RetryOptions {
  maxAttempts: number;
  initialDelay: number;
  maxDelay: number;
  backoffFactor: number;
  retryableErrors?: Array<new (...args: any[]) => Error>;
}

async function withRetry<T>(
  operation: () => Promise<T>,
  options: RetryOptions
): Promise<T> {
  let lastError: Error;
  let delay = options.initialDelay;
  
  for (let attempt = 1; attempt <= options.maxAttempts; attempt++) {
    try {
      return await operation();
    } catch (error) {
      if (!(error instanceof Error)) {
        throw error; // Not retryable if not an Error
      }
      
      lastError = error;
      
      // Check if this error type is retryable
      if (options.retryableErrors && 
          !options.retryableErrors.some(errorType => error instanceof errorType)) {
        throw error; // Not a retryable error type
      }
      
      // Last attempt - give up
      if (attempt >= options.maxAttempts) {
        break;
      }
      
      console.log(`Attempt ${attempt} failed, retrying in ${delay}ms`);
      
      // Wait before next retry
      await new Promise(resolve => setTimeout(resolve, delay));
      
      // Calculate next delay with exponential backoff
      delay = Math.min(delay * options.backoffFactor, options.maxDelay);
    }
  }
  
  throw lastError!;
}

// Usage
class NetworkError extends Error {
  constructor(message: string) {
    super(message);
    this.name = 'NetworkError';
  }
}

class ServerError extends Error {
  constructor(message: string) {
    super(message);
    this.name = 'ServerError';
  }
}

async function fetchData(): Promise<string> {
  return withRetry(
    async () => {
      // Simulate unstable network
      const random = Math.random();
      
      if (random < 0.3) {
        throw new NetworkError('Connection failed');
      } else if (random < 0.6) {
        throw new ServerError('Server error');
      }
      
      return 'Success data';
    },
    {
      maxAttempts: 5,
      initialDelay: 300,
      maxDelay: 5000,
      backoffFactor: 2,
      retryableErrors: [NetworkError, ServerError]
    }
  );
}
```

### Best Practices for Async/Await

**Key Points**

- Always specify return types for async functions
- Handle errors appropriately with try/catch
- Avoid unnecessary sequential operations - use `Promise.all` for concurrent tasks
- Be careful with loops and async operations
- Consider cancellation mechanisms for long-running operations
- Use proper TypeScript typing for all async code
- Keep the async boundary as far out as possible

```typescript
// AVOID: Unnecessary awaits in a loop
async function processItems(items: number[]): Promise<number[]> {
  const results = [];
  for (const item of items) {
    // Each iteration waits for the previous to complete
    results.push(await processItem(item));
  }
  return results;
}

// BETTER: Parallel processing with Promise.all
async function processItemsParallel(items: number[]): Promise<number[]> {
  const promises = items.map(item => processItem(item));
  return await Promise.all(promises);
}

// AVOID: Forgetting error handling
async function fetchDataUnsafe(): Promise<Data> {
  const response = await fetch('https://api.example.com/data');
  const data = await response.json();
  return data; // No error handling!
}

// BETTER: Proper error handling
async function fetchDataSafe(): Promise<Data> {
  try {
    const response = await fetch('https://api.example.com/data');
    
    if (!response.ok) {
      throw new Error(`HTTP error: ${response.status}`);
    }
    
    const data = await response.json();
    return data;
  } catch (error) {
    console.error('Failed to fetch data:', error);
    throw new Error(
      `Failed to fetch data: ${error instanceof Error ? error.message : String(error)}`
    );
  }
}
```

### Conclusion

Async/await in TypeScript provides a powerful way to work with asynchronous operations while maintaining code readability and strong typing. By properly typing your async functions, handling errors gracefully, and understanding when to use parallel versus sequential execution, you can build highly efficient and robust asynchronous applications.

TypeScript's type system enhances async/await by providing compile-time safety for promises, making potential errors visible before runtime. When combined with proper error handling strategies and advanced patterns like queues and retries, TypeScript's async/await becomes an essential tool for modern application development.

For more advanced TypeScript concepts, consider exploring:

- RxJS for reactive async programming
- TypeScript concurrency patterns and worker threads
- WebSockets and real-time communication in TypeScript
- State management with async operations

---

## Advanced Asynchronous Patterns in TypeScript

### Introduction to Advanced Asynchronous Patterns

TypeScript provides powerful tools for handling asynchronous operations beyond basic Promises. Advanced patterns like Generators, Iterators, Observables, and various state management techniques can significantly improve code readability, maintainability, and performance when dealing with complex asynchronous workflows.

### Generators

Generators are special functions that can be paused and resumed, yielding multiple values over time. They're defined using the `function*` syntax and use the `yield` keyword.

**Key Points**

- Generator functions return an iterator when called
- Execution is paused at each `yield` statement
- State is preserved between yields
- Can be used to create infinite sequences
- Enable lazy evaluation of sequences

```typescript
function* countGenerator(): Generator<number> {
  let count = 0;
  while (true) {
    yield count++;
  }
}

// Usage
const counter = countGenerator();
console.log(counter.next().value); // 0
console.log(counter.next().value); // 1
console.log(counter.next().value); // 2
```

#### Error Handling in Generators

Generators can handle errors using try/catch blocks:

```typescript
function* generatorWithErrorHandling(): Generator<number> {
  try {
    yield 1;
    yield 2;
    throw new Error('Generator error');
    yield 3; // This line never executes
  } catch (error) {
    console.log('Error caught inside generator:', error.message);
    yield -1; // Error recovery value
  }
}

// Usage
const gen = generatorWithErrorHandling();
console.log(gen.next().value); // 1
console.log(gen.next().value); // 2
console.log(gen.next().value); // -1 (after logging the error message)
```

#### Generators for Asynchronous Operations

Generators paired with a runner function can simplify asynchronous code:

```typescript
function* fetchUserData(): Generator<Promise<any>, void, any> {
  try {
    const user = yield fetch('https://api.example.com/user').then(r => r.json());
    const posts = yield fetch(`https://api.example.com/posts?userId=${user.id}`).then(r => r.json());
    console.log('User:', user);
    console.log('Posts:', posts);
  } catch (error) {
    console.error('Error fetching data:', error);
  }
}

// Simple generator runner
function run(generator: Generator): Promise<any> {
  const iterator = generator;
  
  function handle(result: IteratorResult<any>): Promise<any> {
    if (result.done) return Promise.resolve(result.value);
    
    return Promise.resolve(result.value)
      .then(res => handle(iterator.next(res)))
      .catch(err => handle(iterator.throw(err)));
  }
  
  return handle(iterator.next());
}

// Usage
run(fetchUserData());
```

### Iterators

Iterators provide a way to access elements in a collection sequentially without exposing the underlying structure. In TypeScript, any object implementing the Iterator protocol can be iterated over.

**Key Points**

- Objects implementing the iterator protocol must have a `next()` method
- The `next()` method returns an object with `value` and `done` properties
- Custom iterators can be created for custom data structures
- Iterators work well with `for...of` loops

```typescript
class FibonacciSequence implements Iterable<number> {
  private limit: number;
  
  constructor(limit: number) {
    this.limit = limit;
  }
  
  [Symbol.iterator](): Iterator<number> {
    let prev = 0, curr = 1, count = 0;
    const limit = this.limit;
    
    return {
      next(): IteratorResult<number> {
        if (count >= limit) {
          return { value: undefined, done: true };
        }
        
        const value = prev;
        const next = prev + curr;
        prev = curr;
        curr = next;
        count++;
        
        return { value, done: false };
      }
    };
  }
}

// Usage
const fib = new FibonacciSequence(10);
for (const num of fib) {
  console.log(num);
}

// Using iterator manually
const iterator = fib[Symbol.iterator]();
let result = iterator.next();
while (!result.done) {
  console.log(result.value);
  result = iterator.next();
}
```

#### Async Iterators

TypeScript supports async iterators, allowing you to iterate over asynchronous data sources:

```typescript
class AsyncDataSource implements AsyncIterable<string> {
  private data: string[];
  
  constructor(data: string[]) {
    this.data = data;
  }
  
  [Symbol.asyncIterator](): AsyncIterator<string> {
    const data = this.data;
    let index = 0;
    
    return {
      async next(): Promise<IteratorResult<string>> {
        if (index >= data.length) {
          return { value: undefined, done: true };
        }
        
        // Simulate async operation
        await new Promise(resolve => setTimeout(resolve, 100));
        
        return {
          value: data[index++],
          done: false
        };
      }
    };
  }
}

// Usage with for await...of
async function processAsyncData() {
  const source = new AsyncDataSource(['one', 'two', 'three']);
  
  for await (const item of source) {
    console.log('Received:', item);
  }
}

processAsyncData();
```

### Observable Pattern

The Observable pattern provides a way to create streams of data or events that can be subscribed to by multiple observers. While not built into TypeScript, it's commonly implemented using libraries like RxJS.

**Key Points**

- Provides a publish-subscribe mechanism
- Handles multiple events over time (unlike Promises)
- Supports filtering, transformation, combination, and other operations
- Can be canceled via subscription
- Useful for event handling, real-time data, and UI interactions

```typescript
// Simple Observable implementation
class Observable<T> {
  private subscribers: Array<(value: T) => void> = [];
  
  subscribe(subscriber: (value: T) => void): { unsubscribe: () => void } {
    this.subscribers.push(subscriber);
    
    return {
      unsubscribe: () => {
        const index = this.subscribers.indexOf(subscriber);
        if (index > -1) {
          this.subscribers.splice(index, 1);
        }
      }
    };
  }
  
  next(value: T): void {
    this.subscribers.forEach(subscriber => subscriber(value));
  }
}

// Usage
const clickObservable = new Observable<MouseEvent>();

// Subscribe to clicks
const subscription = clickObservable.subscribe(event => {
  console.log('Click position:', event.clientX, event.clientY);
});

// Simulate clicks
document.addEventListener('click', (event) => {
  clickObservable.next(event);
});

// Later, to stop receiving updates
// subscription.unsubscribe();
```

#### RxJS Implementation

RxJS is a library that provides a comprehensive implementation of Observables:

```typescript
import { Observable, Subject, from, fromEvent } from 'rxjs';
import { map, filter, debounceTime, distinctUntilChanged } from 'rxjs/operators';

// Create an Observable from DOM events
const keyups = fromEvent<KeyboardEvent>(document.getElementById('search'), 'keyup');

// Process the event stream
const searchTerms = keyups.pipe(
  map(event => (event.target as HTMLInputElement).value),
  filter(term => term.length > 2),
  debounceTime(300),
  distinctUntilChanged()
);

// Subscribe to the processed stream
const subscription = searchTerms.subscribe(term => {
  console.log('Searching for:', term);
  // Perform search API call
});

// Later
subscription.unsubscribe();
```

#### Building a Simple Reactive State Store

Observables are excellent for state management in applications:

```typescript
import { BehaviorSubject } from 'rxjs';
import { map } from 'rxjs/operators';

interface AppState {
  user: { id: number; name: string } | null;
  isLoading: boolean;
  errors: string[];
}

class Store {
  private state$: BehaviorSubject<AppState>;
  
  constructor(initialState: AppState) {
    this.state$ = new BehaviorSubject<AppState>(initialState);
  }
  
  // Get current state
  getState(): AppState {
    return this.state$.getValue();
  }
  
  // Select part of state
  select<K extends keyof AppState>(key: K) {
    return this.state$.pipe(
      map(state => state[key])
    );
  }
  
  // Update state
  setState(partialState: Partial<AppState>): void {
    this.state$.next({
      ...this.state$.getValue(),
      ...partialState
    });
  }
  
  // Subscribe to state changes
  subscribe(listener: (state: AppState) => void) {
    const subscription = this.state$.subscribe(listener);
    return () => subscription.unsubscribe();
  }
}

// Usage
const store = new Store({
  user: null,
  isLoading: false,
  errors: []
});

// Subscribe to the entire state
const unsubscribe = store.subscribe(state => {
  console.log('State updated:', state);
});

// Subscribe to a specific slice of state
const userSubscription = store.select('user').subscribe(user => {
  console.log('User changed:', user);
});

// Update state
store.setState({ isLoading: true });
store.setState({ 
  user: { id: 1, name: 'John Doe' },
  isLoading: false
});

// Unsubscribe
unsubscribe();
userSubscription.unsubscribe();
```

### Managing Asynchronous State

Managing state across asynchronous operations can be challenging. TypeScript offers several patterns to handle this complexity.

#### State Machines

State machines are an excellent way to model complex asynchronous workflows:

```typescript
type FetchState = 
  | { status: 'idle' }
  | { status: 'loading' }
  | { status: 'success', data: any }
  | { status: 'error', error: Error };

class AsyncDataManager<T> {
  private state: FetchState = { status: 'idle' };
  private listeners: ((state: FetchState) => void)[] = [];
  
  getState(): FetchState {
    return this.state;
  }
  
  subscribe(listener: (state: FetchState) => void): () => void {
    this.listeners.push(listener);
    listener(this.state);
    
    return () => {
      this.listeners = this.listeners.filter(l => l !== listener);
    };
  }
  
  private setState(newState: FetchState): void {
    this.state = newState;
    this.listeners.forEach(listener => listener(this.state));
  }
  
  async fetchData(fetcher: () => Promise<T>): Promise<void> {
    this.setState({ status: 'loading' });
    
    try {
      const data = await fetcher();
      this.setState({ status: 'success', data });
    } catch (error) {
      this.setState({ status: 'error', error });
    }
  }
  
  reset(): void {
    this.setState({ status: 'idle' });
  }
}

// Usage
const userDataManager = new AsyncDataManager<User>();

userDataManager.subscribe(state => {
  switch (state.status) {
    case 'idle':
      console.log('Ready to fetch data');
      break;
    case 'loading':
      console.log('Loading...');
      break;
    case 'success':
      console.log('Data loaded:', state.data);
      break;
    case 'error':
      console.error('Error loading data:', state.error);
      break;
  }
});

// Fetch data
userDataManager.fetchData(async () => {
  const response = await fetch('https://api.example.com/user/1');
  return response.json();
});
```

#### Custom Hooks Pattern (React-inspired)

For frameworks like React, a custom hooks pattern can manage asynchronous state elegantly:

```typescript
function useAsync<T, E = string>(
  asyncFunction: () => Promise<T>,
  immediate = true
) {
  const [state, setState] = useState<{
    status: 'idle' | 'pending' | 'success' | 'error';
    data: T | null;
    error: E | null;
  }>({
    status: 'idle',
    data: null,
    error: null
  });

  const execute = useCallback(() => {
    setState({ status: 'pending', data: null, error: null });
    
    return asyncFunction()
      .then(response => {
        setState({ status: 'success', data: response, error: null });
        return response;
      })
      .catch(error => {
        setState({ status: 'error', data: null, error });
        throw error;
      });
  }, [asyncFunction]);

  useEffect(() => {
    if (immediate) {
      execute();
    }
  }, [execute, immediate]);

  return { execute, ...state };
}

// Usage (pseudocode for TypeScript illustration)
function UserProfile({ userId }: { userId: string }) {
  const { status, data: user, error } = useAsync(
    () => fetch(`/api/users/${userId}`).then(r => r.json())
  );

  if (status === 'pending') return <div>Loading...</div>;
  if (status === 'error') return <div>Error: {error}</div>;
  if (!user) return null;

  return <div>{user.name}</div>;
}
```

#### Cancelable Promises

Managing cancelable operations is crucial for preventing memory leaks and race conditions:

```typescript
interface CancelablePromise<T> extends Promise<T> {
  cancel: () => void;
}

function makeCancelable<T>(promise: Promise<T>): CancelablePromise<T> {
  let isCanceled = false;
  
  const wrappedPromise = new Promise<T>((resolve, reject) => {
    promise
      .then(val => (isCanceled ? reject({ isCanceled }) : resolve(val)))
      .catch(error => (isCanceled ? reject({ isCanceled }) : reject(error)));
  }) as CancelablePromise<T>;
  
  wrappedPromise.cancel = () => {
    isCanceled = true;
  };
  
  return wrappedPromise;
}

// Usage
class DataComponent {
  private currentRequest: CancelablePromise<any> | null = null;
  
  fetchData(id: string) {
    // Cancel previous request if exists
    if (this.currentRequest) {
      this.currentRequest.cancel();
    }
    
    this.currentRequest = makeCancelable(
      fetch(`https://api.example.com/data/${id}`).then(r => r.json())
    );
    
    return this.currentRequest
      .then(data => {
        console.log('Data received:', data);
        this.currentRequest = null;
        return data;
      })
      .catch(error => {
        if (error.isCanceled) {
          console.log('Request was canceled');
        } else {
          console.error('Error fetching data:', error);
        }
        this.currentRequest = null;
        throw error;
      });
  }
  
  cleanup() {
    if (this.currentRequest) {
      this.currentRequest.cancel();
      this.currentRequest = null;
    }
  }
}
```

#### AbortController API

Modern browsers provide the AbortController API for canceling fetch requests:

```typescript
class ApiClient {
  fetchWithTimeout(url: string, timeoutMs: number = 5000): Promise<Response> {
    const controller = new AbortController();
    const { signal } = controller;
    
    // Set timeout to abort
    const timeout = setTimeout(() => controller.abort(), timeoutMs);
    
    return fetch(url, { signal })
      .finally(() => clearTimeout(timeout));
  }
  
  async fetchMultiple(urls: string[]): Promise<Response[]> {
    const controller = new AbortController();
    const { signal } = controller;
    
    try {
      return await Promise.all(
        urls.map(url => fetch(url, { signal }))
      );
    } catch (error) {
      // If any request fails, abort all others
      controller.abort();
      throw error;
    }
  }
}

// Usage
const client = new ApiClient();
client.fetchWithTimeout('https://api.example.com/data')
  .then(response => response.json())
  .then(data => console.log('Data:', data))
  .catch(error => {
    if (error.name === 'AbortError') {
      console.log('Request timed out');
    } else {
      console.error('Request failed:', error);
    }
  });
```

### Advanced Asynchronous Control Flow

#### Sequential Execution of Async Tasks

When tasks need to be executed in sequence:

```typescript
async function executeSequentially<T>(
  tasks: Array<() => Promise<T>>
): Promise<T[]> {
  const results: T[] = [];
  
  for (const task of tasks) {
    const result = await task();
    results.push(result);
  }
  
  return results;
}

// Usage
const tasks = [
  () => fetchUser(1),
  () => fetchUser(2),
  () => fetchUser(3)
];

executeSequentially(tasks).then(users => {
  console.log('Users:', users);
});
```

#### Limiting Concurrency

When dealing with many async operations but wanting to limit concurrency:

```typescript
async function asyncPool<T, R>(
  concurrency: number,
  items: T[],
  iteratorFn: (item: T, index: number) => Promise<R>
): Promise<R[]> {
  const results: R[] = [];
  const executing: Promise<void>[] = [];
  let index = 0;
  
  for (const item of items) {
    const itemIndex = index++;
    
    // Create a promise that resolves when the task completes
    // and its result is added to results
    const p = Promise.resolve().then(() => iteratorFn(item, itemIndex))
      .then(result => {
        results[itemIndex] = result;
      });
    
    executing.push(p);
    
    // If we've reached the concurrency limit, wait for one to finish
    if (executing.length >= concurrency) {
      await Promise.race(executing.map(e => e.catch(() => {})));
      
      // Remove completed promises
      const completedIndex = executing.findIndex(p => p.status === 'fulfilled');
      if (completedIndex !== -1) {
        executing.splice(completedIndex, 1);
      }
    }
  }
  
  // Wait for all executing promises to finish
  await Promise.all(executing);
  
  return results;
}

// Usage
const urls = Array(20).fill(0).map((_, i) => `https://api.example.com/item/${i + 1}`);

asyncPool(5, urls, url => 
  fetch(url).then(r => r.json())
).then(results => {
  console.log('All results:', results);
});
```

#### Retry Logic

Adding retry logic to async operations:

```typescript
async function retryOperation<T>(
  operation: () => Promise<T>,
  retries: number = 3,
  delay: number = 300,
  backoff: number = 2
): Promise<T> {
  let attempts = 0;
  
  async function attempt(): Promise<T> {
    try {
      return await operation();
    } catch (error) {
      attempts++;
      
      if (attempts >= retries) {
        throw error;
      }
      
      const waitTime = delay * Math.pow(backoff, attempts - 1);
      console.log(`Retry attempt ${attempts}/${retries} after ${waitTime}ms`);
      
      await new Promise(resolve => setTimeout(resolve, waitTime));
      return attempt();
    }
  }
  
  return attempt();
}

// Usage
retryOperation(
  () => fetch('https://flaky-api.example.com/data').then(r => r.json()),
  5,
  500,
  1.5
)
.then(data => console.log('Data retrieved successfully:', data))
.catch(error => console.error('All retries failed:', error));
```

### Generators for Advanced Async Workflows

#### Handling Async Operations with Co-routines

Co-routines using generators provide an elegant way to handle complicated async workflows:

```typescript
type Co<T> = Generator<Promise<any>, T, any>;

function co<T>(gen: () => Co<T>): Promise<T> {
  const generator = gen();

  function next(value?: any): Promise<T> {
    const result = generator.next(value);
    
    if (result.done) {
      return Promise.resolve(result.value);
    }
    
    return Promise.resolve(result.value)
      .then(res => next(res))
      .catch(err => {
        return Promise.resolve(generator.throw(err)).then(next);
      });
  }
  
  return next();
}

// Usage
interface User { id: number; name: string; }
interface Post { id: number; title: string; userId: number; }

function* fetchUserAndPosts(userId: number): Co<{user: User, posts: Post[]}> {
  try {
    // Fetch user
    const user: User = yield fetch(`https://api.example.com/users/${userId}`)
      .then(r => r.json());
      
    // Fetch posts using the user ID
    const posts: Post[] = yield fetch(`https://api.example.com/posts?userId=${user.id}`)
      .then(r => r.json());
    
    return { user, posts };
  } catch (error) {
    console.error('Error in generator:', error);
    throw error;
  }
}

co(function* () {
  const { user, posts } = yield* fetchUserAndPosts(1);
  console.log(`User ${user.name} has ${posts.length} posts`);
  return { user, posts };
})
.then(result => console.log('Final result:', result))
.catch(error => console.error('Co execution failed:', error));
```

#### Async Generator Functions

TypeScript supports async generator functions:

```typescript
async function* fetchPaginatedData(
  baseUrl: string,
  pageSize: number = 10
): AsyncGenerator<any[], void, unknown> {
  let page = 1;
  let hasMore = true;
  
  while (hasMore) {
    const url = `${baseUrl}?page=${page}&pageSize=${pageSize}`;
    const response = await fetch(url);
    const data = await response.json();
    
    if (data.items.length > 0) {
      yield data.items;
      page++;
    } else {
      hasMore = false;
    }
  }
}

// Usage
async function processPaginatedData() {
  const dataGenerator = fetchPaginatedData('https://api.example.com/products');
  
  let totalProcessed = 0;
  
  for await (const items of dataGenerator) {
    console.log(`Processing ${items.length} items`);
    // Process items...
    totalProcessed += items.length;
  }
  
  console.log(`Finished processing ${totalProcessed} items total`);
}

processPaginatedData();
```

### Combining Async Patterns

Different async patterns can be combined to create powerful solutions:

```typescript
// Observable that uses generators internally
class LazyObservable<T> implements Observable<T> {
  private generator: () => Generator<T, void, unknown>;
  
  constructor(generator: () => Generator<T, void, unknown>) {
    this.generator = generator;
  }
  
  subscribe(observer: Observer<T>): Subscription {
    const iterator = this.generator();
    let stopped = false;
    
    const processNext = () => {
      if (stopped) return;
      
      try {
        const result = iterator.next();
        
        if (result.done) {
          observer.complete?.();
          return;
        }
        
        observer.next(result.value);
        setTimeout(processNext, 0);
      } catch (error) {
        observer.error?.(error);
      }
    };
    
    processNext();
    
    return {
      unsubscribe: () => {
        stopped = true;
      }
    };
  }
}

// Usage
function* numberGenerator() {
  let i = 0;
  while (i < 10) {
    yield i++;
  }
}

const observable = new LazyObservable(numberGenerator);

const subscription = observable.subscribe({
  next: value => console.log('Value:', value),
  complete: () => console.log('Complete!'),
  error: err => console.error('Error:', err)
});

// Later
// subscription.unsubscribe();
```

### Performance Considerations

#### Optimizing Async Operations

**Key Points**

- Use Promise.all for concurrent operations where order doesn't matter
- Use AbortController to cancel unnecessary requests
- Consider streaming for large data sets
- Implement proper error boundaries to prevent cascading failures
- Use memoization for expensive async operations

```typescript
// Cache expensive async operations
function memoizeAsync<T, R>(
  fn: (arg: T) => Promise<R>,
  keyFn: (arg: T) => string = JSON.stringify
): (arg: T) => Promise<R> {
  const cache = new Map<string, R>();
  
  return async (arg: T): Promise<R> => {
    const key = keyFn(arg);
    
    if (cache.has(key)) {
      return cache.get(key)!;
    }
    
    const result = await fn(arg);
    cache.set(key, result);
    return result;
  };
}

// Usage
const fetchUserMemoized = memoizeAsync(
  (id: number) => fetch(`https://api.example.com/users/${id}`).then(r => r.json()),
  id => `user-${id}`
);

// First call will fetch
fetchUserMemoized(1).then(user => console.log('User:', user));

// Second call with same ID will use cache
fetchUserMemoized(1).then(user => console.log('User (from cache):', user));
```

#### Batching API Requests

```typescript
class BatchingApi {
  private queue: Map<string, {
    resolve: (value: any) => void;
    reject: (error: any) => void;
  }[]> = new Map();
  
  private timeout: NodeJS.Timeout | null = null;
  private batchDelay: number;
  
  constructor(batchDelay: number = 50) {
    this.batchDelay = batchDelay;
  }
  
  fetch<T>(endpoint: string, id: string): Promise<T> {
    return new Promise<T>((resolve, reject) => {
      const key = `${endpoint}`;
      
      if (!this.queue.has(key)) {
        this.queue.set(key, []);
      }
      
      this.queue.get(key)!.push({ resolve, reject });
      
      if (!this.timeout) {
        this.timeout = setTimeout(() => this.processBatch(), this.batchDelay);
      }
    });
  }
  
  private async processBatch() {
    this.timeout = null;
    const currentQueue = new Map(this.queue);
    this.queue.clear();
    
    for (const [endpoint, requests] of currentQueue.entries()) {
      if (requests.length === 0) continue;
      
      try {
        const ids = requests.map(r => r.id).join(',');
        const response = await fetch(`${endpoint}?ids=${ids}`);
        const data = await response.json();
        
        // Distribute results back to individual requesters
        for (const request of requests) {
          request.resolve(data.find((item: any) => item.id === request.id));
        }
      } catch (error) {
        // Propagate error to all requesters
        for (const request of requests) {
          request.reject(error);
        }
      }
    }
  }
}

// Usage
const api = new BatchingApi();

// These calls will be batched together
api.fetch('https://api.example.com/users', '1').then(user => console.log('User 1:', user));
api.fetch('https://api.example.com/users', '2').then(user => console.log('User 2:', user));
api.fetch('https://api.example.com/users', '3').then(user => console.log('User 3:', user));
```

### Testing Asynchronous Patterns

Testing async code requires special techniques:

```typescript
// Jest-like test examples
describe('Async patterns', () => {
  test('Observable emits correct values', done => {
    const observable = new Observable<number>(observer => {
      observer.next(1);
      observer.next(2);
      observer.next(3);
      observer.complete();
      
      return { unsubscribe: () => {} };
    });
    
    const values: number[] = [];
    
    observable.subscribe({
      next: value => values.push(value),
      complete: () => {
        expect(values).toEqual([1, 2, 3]);
        done();
      }
    });
  });
  
  test('AsyncDataManager handles state transitions', async () => {
    const manager = new AsyncDataManager<string[]>();
    const states: string[] = [];
    
    manager.subscribe(state => {
      states.push(state.status);
    });
    
    const fetcher = jest.fn().mockResolvedValue(['item1', 'item2']);
    
    await manager.fetchData(fetcher);
    
    expect(states).toEqual(['idle', 'loading', 'success']);
    expect(fetcher).toHaveBeenCalledTimes(1);
    expect(manager.getState()).toEqual({
      status: 'success',
      data: ['item1', 'item2']
    });
  });
  
  test('Generator yields correct values', () => {
    function* testGenerator() {
      yield 1;
      yield 2;
      return 3;
    }
    
    const gen = testGenerator();
    expect(gen.next()).toEqual({ value: 1, done: false });
    expect(gen.next()).toEqual({ value: 2, done: false });
    expect(gen.next()).toEqual({ value: 3, done: true });
  });
});
```

### Real-World Examples

#### Building a Data Streaming API with Async Generators

```typescript
import * as fs from 'fs';
import * as http from 'http';

// Server-side streaming API
async function* streamData(
  filePath: string,
  chunkSize: number = 1024
): AsyncGenerator<Buffer, void, unknown> {
  const fileHandle = await fs.promises.open(filePath, 'r');
  const stats = await fs.promises.stat(filePath);
  const fileSize = stats.size;

  try {
    let bytesRead = 0;

    while (bytesRead < fileSize) {
      const buffer = Buffer.alloc(chunkSize);
      const result = await fileHandle.read(buffer, 0, chunkSize, bytesRead);

      bytesRead += result.bytesRead;

      if (result.bytesRead > 0) {
        yield buffer.slice(0, result.bytesRead);
      }

      if (result.bytesRead < chunkSize) {
        break;
      }
    }
  } finally {
    await fileHandle.close();
  }
}

// Usage (Node.js example)
async function handleStreamRequest(req: http.IncomingMessage, res: http.ServerResponse) {
  const filePath = './large-file.txt'; // Replace with actual file path

  res.setHeader('Content-Type', 'application/octet-stream');
  res.setHeader('Transfer-Encoding', 'chunked');

  try {
    for await (const chunk of streamData(filePath)) {
      res.write(chunk);
    }
    res.end();
  } catch (error) {
    console.error('Streaming error:', error);
    res.statusCode = 500;
    res.end('Internal Server Error');
  }
}

// Start server
const server = http.createServer((req, res) => {
  if (req.url === '/stream') {
    handleStreamRequest(req, res);
  } else {
    res.statusCode = 404;
    res.end('Not Found');
  }
});

server.listen(3000, () => {
  console.log('Server listening on http://localhost:3000');
});
```

---

# TypeScript Compiler API and Transformation

## TypeScript Compiler API

### Understanding the TypeScript Compiler API

The TypeScript Compiler API provides programmatic access to the TypeScript compiler, enabling developers to parse, analyze, transform, and generate TypeScript code. This powerful API opens up possibilities for creating custom tools, linters, code analyzers, and transformations that integrate deeply with TypeScript's type system.

**Key Points**

- The Compiler API exposes TypeScript's internal structures and algorithms
- It allows for static analysis without code execution
- It powers tools like the TypeScript Language Service
- It's the foundation for many TypeScript tools and editor integrations
- Available in the `typescript` package via `import * as ts from 'typescript'`

### Abstract Syntax Tree (AST)

The Abstract Syntax Tree (AST) is a tree representation of the syntactic structure of source code. TypeScript's compiler transforms source code into an AST to perform various operations like type checking, transformations, and code generation.

```typescript
import * as ts from 'typescript';

// Parse a simple TypeScript source file into an AST
function createAST(source: string): ts.SourceFile {
  return ts.createSourceFile(
    'sample.ts',       // fileName
    source,            // sourceText
    ts.ScriptTarget.ES2020,  // languageVersion
    true               // setParentNodes
  );
}

// Analyzing the AST by traversing nodes
function printAST(node: ts.Node, indent: string = ''): void {
  console.log(`${indent}${ts.SyntaxKind[node.kind]}`);
  
  node.forEachChild(child => {
    printAST(child, indent + '  ');
  });
}

// Example usage
const source = `
function greet(name: string): string {
  return "Hello, " + name + "!";
}
`;

const ast = createAST(source);
printAST(ast);
```

**Example** Extracting function information from AST:

```typescript
import * as ts from 'typescript';

interface FunctionInfo {
  name: string;
  parameters: Array<{
    name: string;
    type: string;
  }>;
  returnType: string;
  location: {
    line: number;
    character: number;
  };
}

function extractFunctionInfo(sourceFile: ts.SourceFile): FunctionInfo[] {
  const functions: FunctionInfo[] = [];
  
  // Visit all nodes in the AST
  function visit(node: ts.Node) {
    // Check if the node is a function declaration
    if (ts.isFunctionDeclaration(node) && node.name) {
      const name = node.name.text;
      
      // Extract parameters
      const parameters = node.parameters.map(param => {
        const paramName = param.name.getText(sourceFile);
        const paramType = param.type 
          ? param.type.getText(sourceFile) 
          : 'any';
          
        return {
          name: paramName,
          type: paramType
        };
      });
      
      // Extract return type
      const returnType = node.type 
        ? node.type.getText(sourceFile) 
        : 'any';
      
      // Get location info
      const { line, character } = sourceFile.getLineAndCharacterOfPosition(node.getStart());
      
      functions.push({
        name,
        parameters,
        returnType,
        location: { line, character }
      });
    }
    
    // Continue traversing the AST
    ts.forEachChild(node, visit);
  }
  
  // Start the traversal from the root node
  visit(sourceFile);
  
  return functions;
}

// Example usage
const source = `
function greet(name: string): string {
  return "Hello, " + name + "!";
}

function calculate(a: number, b: number): number {
  return a + b;
}
`;

const sourceFile = ts.createSourceFile(
  'example.ts',
  source,
  ts.ScriptTarget.ES2020,
  true
);

const functionInfos = extractFunctionInfo(sourceFile);
console.log(JSON.stringify(functionInfos, null, 2));
```

### Working with AST Nodes

TypeScript's API provides various utilities for working with AST nodes:

```typescript
import * as ts from 'typescript';

// Common node types and their recognition
function analyzeNode(node: ts.Node): void {
  if (ts.isIdentifier(node)) {
    console.log(`Found identifier: ${node.text}`);
  } else if (ts.isStringLiteral(node)) {
    console.log(`Found string literal: "${node.text}"`);
  } else if (ts.isNumericLiteral(node)) {
    console.log(`Found numeric literal: ${node.text}`);
  } else if (ts.isFunctionDeclaration(node)) {
    console.log(`Found function: ${node.name?.text || 'anonymous'}`);
  } else if (ts.isClassDeclaration(node)) {
    console.log(`Found class: ${node.name?.text || 'anonymous'}`);
  } else if (ts.isInterfaceDeclaration(node)) {
    console.log(`Found interface: ${node.name.text}`);
  } else if (ts.isTypeAliasDeclaration(node)) {
    console.log(`Found type alias: ${node.name.text}`);
  } else if (ts.isVariableDeclaration(node)) {
    console.log(`Found variable: ${node.name.getText()}`);
  }
}

// Searching for specific nodes
function findAllClassNames(sourceFile: ts.SourceFile): string[] {
  const classNames: string[] = [];
  
  function visit(node: ts.Node) {
    if (ts.isClassDeclaration(node) && node.name) {
      classNames.push(node.name.text);
    }
    
    ts.forEachChild(node, visit);
  }
  
  visit(sourceFile);
  return classNames;
}

// Getting detailed position information
function getNodePosition(node: ts.Node, sourceFile: ts.SourceFile): string {
  const { line, character } = sourceFile.getLineAndCharacterOfPosition(node.getStart());
  const endPos = sourceFile.getLineAndCharacterOfPosition(node.getEnd());
  return `Line ${line + 1}, character ${character + 1} to line ${endPos.line + 1}, character ${endPos.character + 1}`;
}

// Node kind mapping to readable strings
function getNodeKindName(kind: ts.SyntaxKind): string {
  return ts.SyntaxKind[kind];
}
```

### Creating Program Instances

The `Program` is a central object in the TypeScript Compiler API that represents an entire TypeScript program. It provides access to type checking, source files, and compiler options.

```typescript
import * as ts from 'typescript';
import * as path from 'path';
import * as fs from 'fs';

// Create a program from files and compiler options
function createProgram(rootFiles: string[], options: ts.CompilerOptions): ts.Program {
  return ts.createProgram(rootFiles, options);
}

// Create program from tsconfig.json
function createProgramFromConfig(tsconfigPath: string): ts.Program {
  const configFileName = path.resolve(tsconfigPath);
  const configFile = ts.readConfigFile(configFileName, ts.sys.readFile);
  
  const parsedCommandLine = ts.parseJsonConfigFileContent(
    configFile.config,
    ts.sys,
    path.dirname(configFileName)
  );
  
  return ts.createProgram({
    rootNames: parsedCommandLine.fileNames,
    options: parsedCommandLine.options,
    projectReferences: parsedCommandLine.projectReferences
  });
}

// Example usage
const program = createProgram(
  ['source1.ts', 'source2.ts'],
  {
    target: ts.ScriptTarget.ES2020,
    module: ts.ModuleKind.ESNext,
    strict: true
  }
);

// Or from tsconfig
const programFromConfig = createProgramFromConfig('./tsconfig.json');

// Get all source files in the program
const sourceFiles = program.getSourceFiles();
console.log(`Program contains ${sourceFiles.length} source files`);

// Type checking
const diagnostics = ts.getPreEmitDiagnostics(program);
diagnostics.forEach(diagnostic => {
  if (diagnostic.file) {
    const { line, character } = diagnostic.file.getLineAndCharacterOfPosition(diagnostic.start!);
    const message = ts.flattenDiagnosticMessageText(diagnostic.messageText, '\n');
    console.log(`${diagnostic.file.fileName} (${line + 1},${character + 1}): ${message}`);
  } else {
    console.log(ts.flattenDiagnosticMessageText(diagnostic.messageText, '\n'));
  }
});
```

**Example** Checking for type errors in a string:

```typescript
import * as ts from 'typescript';

function checkTypeErrors(sourceText: string): ts.Diagnostic[] {
  // Create in-memory file system
  const fileName = 'sample.ts';
  const compilerHost = ts.createCompilerHost({});
  
  // Override readFile and fileExists
  const originalReadFile = compilerHost.readFile;
  compilerHost.readFile = (filename) => {
    if (filename === fileName) {
      return sourceText;
    }
    return originalReadFile(filename);
  };
  
  const originalFileExists = compilerHost.fileExists;
  compilerHost.fileExists = (filename) => {
    if (filename === fileName) {
      return true;
    }
    return originalFileExists(filename);
  };
  
  // Create program with compiler options
  const program = ts.createProgram([fileName], {
    noEmitOnError: true,
    target: ts.ScriptTarget.ES2020,
    module: ts.ModuleKind.ESNext,
    strict: true
  }, compilerHost);
  
  // Get diagnostics
  return ts.getPreEmitDiagnostics(program);
}

// Sample usage
const source = `
function add(a: number, b: number): number {
  return a + b;
}

const result = add("5", 10); // Type error here
`;

const errors = checkTypeErrors(source);
errors.forEach(error => {
  if (error.file) {
    const { line, character } = error.file.getLineAndCharacterOfPosition(error.start!);
    const message = ts.flattenDiagnosticMessageText(error.messageText, '\n');
    console.log(`Line ${line + 1}, character ${character + 1}: ${message}`);
  }
});
```

### Working with Source Files

Source files are fundamental units in TypeScript programs, and the Compiler API provides extensive capabilities to work with them.

```typescript
import * as ts from 'typescript';
import * as fs from 'fs';

// Reading a source file from disk
function loadSourceFile(filePath: string, target: ts.ScriptTarget = ts.ScriptTarget.ES2020): ts.SourceFile {
  const content = fs.readFileSync(filePath, 'utf8');
  return ts.createSourceFile(
    filePath, 
    content, 
    target, 
    true
  );
}

// Creating a source file from a string
function createSourceFileFromString(
  content: string, 
  fileName: string = 'source.ts',
  target: ts.ScriptTarget = ts.ScriptTarget.ES2020
): ts.SourceFile {
  return ts.createSourceFile(fileName, content, target, true);
}

// Getting imports from a source file
function extractImports(sourceFile: ts.SourceFile): Array<{
  name: string;
  path: string;
  isTypeOnly: boolean;
}> {
  const imports: Array<{
    name: string;
    path: string;
    isTypeOnly: boolean;
  }> = [];
  
  ts.forEachChild(sourceFile, node => {
    if (ts.isImportDeclaration(node)) {
      const importPath = (node.moduleSpecifier as ts.StringLiteral).text;
      const isTypeOnly = node.importClause?.isTypeOnly || false;
      
      // Default import
      if (node.importClause?.name) {
        imports.push({
          name: node.importClause.name.text,
          path: importPath,
          isTypeOnly
        });
      }
      
      // Named imports
      if (node.importClause?.namedBindings) {
        if (ts.isNamedImports(node.importClause.namedBindings)) {
          node.importClause.namedBindings.elements.forEach(element => {
            const importName = element.name.text;
            const propertyName = element.propertyName?.text;
            
            imports.push({
              name: propertyName ? `${propertyName} as ${importName}` : importName,
              path: importPath,
              isTypeOnly
            });
          });
        }
        
        // Namespace import
        if (ts.isNamespaceImport(node.importClause.namedBindings)) {
          imports.push({
            name: `* as ${node.importClause.namedBindings.name.text}`,
            path: importPath,
            isTypeOnly
          });
        }
      }
    }
  });
  
  return imports;
}

// Extracting exported declarations
function extractExports(sourceFile: ts.SourceFile): string[] {
  const exports: string[] = [];
  
  ts.forEachChild(sourceFile, node => {
    // Exported variables, functions, classes, etc.
    if (
      (ts.isFunctionDeclaration(node) ||
       ts.isClassDeclaration(node) ||
       ts.isInterfaceDeclaration(node) ||
       ts.isTypeAliasDeclaration(node) ||
       ts.isVariableStatement(node)) &&
      node.modifiers?.some(m => m.kind === ts.SyntaxKind.ExportKeyword)
    ) {
      // For variable statements, need to extract each declaration
      if (ts.isVariableStatement(node)) {
        node.declarationList.declarations.forEach(decl => {
          if (ts.isIdentifier(decl.name)) {
            exports.push(decl.name.text);
          }
        });
      } 
      // For other declarations with a name property
      else if ('name' in node && node.name && ts.isIdentifier(node.name)) {
        exports.push(node.name.text);
      }
    }
    
    // Named exports
    if (ts.isExportDeclaration(node) && node.exportClause && ts.isNamedExports(node.exportClause)) {
      node.exportClause.elements.forEach(element => {
        exports.push(element.name.text);
      });
    }
  });
  
  return exports;
}

// Example usage
const sourceFile = createSourceFileFromString(`
import React from 'react';
import { useState, useEffect } from 'react';
import * as utils from './utils';
import type { User } from './types';

export function App() {
  return <div>Hello World</div>;
}

export class UserService {
  getUsers(): User[] {
    return [];
  }
}

export const API_URL = 'https://api.example.com';

export { createUser, updateUser } from './user-actions';
`);

const imports = extractImports(sourceFile);
console.log('Imports:', imports);

const exports = extractExports(sourceFile);
console.log('Exports:', exports);
```

### AST Transformation

One of the most powerful features of the TypeScript Compiler API is the ability to transform AST nodes, enabling code refactoring, optimization, and generation.

```typescript
import * as ts from 'typescript';

// Creating a transformer for TypeScript source code
function createTransformer<T extends ts.Node>(
  transformFn: (node: T) => ts.Node
): ts.TransformerFactory<ts.SourceFile> {
  return context => {
    const visit: ts.Visitor = node => {
      // Apply the transform function to nodes of the correct type
      node = ts.visitEachChild(node, visit, context);
      
      if (node.kind === ts.SyntaxKind.SourceFile) {
        return node;
      }
      
      return transformFn(node as T);
    };
    
    return sourceFile => ts.visitNode(sourceFile, visit) as ts.SourceFile;
  };
}

// Example transformation: Convert all string literals to uppercase
const uppercaseStringLiterals: ts.TransformerFactory<ts.SourceFile> = 
  createTransformer<ts.StringLiteral>((node: ts.StringLiteral) => {
    if (ts.isStringLiteral(node)) {
      return ts.factory.createStringLiteral(node.text.toUpperCase());
    }
    return node;
  });

// Example transformation: Add type annotations to function parameters
const addNumberTypeToParameters: ts.TransformerFactory<ts.SourceFile> = 
  createTransformer<ts.ParameterDeclaration>((node: ts.ParameterDeclaration) => {
    if (ts.isParameter(node) && !node.type) {
      return ts.factory.updateParameterDeclaration(
        node,
        node.decorators,
        node.modifiers,
        node.dotDotDotToken,
        node.name,
        node.questionToken,
        ts.factory.createKeywordTypeNode(ts.SyntaxKind.NumberKeyword),
        node.initializer
      );
    }
    return node;
  });

// Applying transformers to source code
function transformSourceCode(
  source: string, 
  transformers: ts.TransformerFactory<ts.SourceFile>[]
): string {
  const sourceFile = ts.createSourceFile(
    'sample.ts',
    source,
    ts.ScriptTarget.ES2020,
    true
  );
  
  const result = ts.transform(sourceFile, transformers);
  const printer = ts.createPrinter();
  
  return printer.printNode(
    ts.EmitHint.Unspecified,
    result.transformed[0],
    sourceFile
  );
}

// Example usage
const source = `
function greet(name) {
  return "Hello, " + name + "!";
}

const message = "Welcome to TypeScript";
`;

const transformed = transformSourceCode(
  source, 
  [uppercaseStringLiterals, addNumberTypeToParameters]
);

console.log(transformed);
// Output will have uppercase strings and number type annotations:
// function greet(name: number) {
//   return "HELLO, " + name + "!";
// }
//
// const message = "WELCOME TO TYPESCRIPT";
```

**Example** Converting regular functions to arrow functions:

```typescript
import * as ts from 'typescript';

function convertToArrowFunctions(sourceText: string): string {
  const sourceFile = ts.createSourceFile(
    'source.ts',
    sourceText,
    ts.ScriptTarget.ES2020,
    true
  );
  
  // Create transformer factory
  const transformer: ts.TransformerFactory<ts.SourceFile> = context => {
    return sourceFile => {
      const visitor: ts.Visitor = node => {
        // Function declaration to arrow function conversion
        if (ts.isFunctionDeclaration(node) && 
            node.name && 
            node.body && 
            !node.modifiers?.some(m => m.kind === ts.SyntaxKind.ExportKeyword)) {
          
          const arrowFunction = ts.factory.createArrowFunction(
            node.modifiers,
            node.typeParameters,
            node.parameters,
            node.type,
            ts.factory.createToken(ts.SyntaxKind.EqualsGreaterThanToken),
            node.body
          );
          
          const variableDeclaration = ts.factory.createVariableDeclaration(
            node.name,
            undefined,
            undefined,
            arrowFunction
          );
          
          const variableStatement = ts.factory.createVariableStatement(
            undefined,
            ts.factory.createVariableDeclarationList(
              [variableDeclaration],
              ts.NodeFlags.Const
            )
          );
          
          return variableStatement;
        }
        
        return ts.visitEachChild(node, visitor, context);
      };
      
      return ts.visitNode(sourceFile, visitor);
    };
  };
  
  // Apply transformation
  const result = ts.transform(sourceFile, [transformer]);
  const printer = ts.createPrinter({ newLine: ts.NewLineKind.LineFeed });
  
  return printer.printNode(
    ts.EmitHint.Unspecified,
    result.transformed[0],
    sourceFile
  );
}

// Example usage
const source = `
function add(a: number, b: number): number {
  return a + b;
}

export function multiply(a: number, b: number): number {
  return a * b;
}

const subtract = (a: number, b: number): number => {
  return a - b;
};
`;

const result = convertToArrowFunctions(source);
console.log(result);
// Expected output:
// const add = (a: number, b: number): number => {
//   return a + b;
// };
//
// export function multiply(a: number, b: number): number {
//   return a * b;
// }
//
// const subtract = (a: number, b: number): number => {
//   return a - b;
// };
```

### Type Checking and Analysis

The TypeScript Compiler API provides powerful facilities for type checking and analysis:

```typescript
import * as ts from 'typescript';

// Create a type checker
function createTypeChecker(program: ts.Program): ts.TypeChecker {
  return program.getTypeChecker();
}

// Get the type of a node
function getNodeType(
  node: ts.Node, 
  typeChecker: ts.TypeChecker
): string {
  const type = typeChecker.getTypeAtLocation(node);
  return typeChecker.typeToString(type);
}

// Check if a type is assignable to another
function isTypeAssignableTo(
  source: ts.Node,
  target: ts.Node,
  typeChecker: ts.TypeChecker
): boolean {
  const sourceType = typeChecker.getTypeAtLocation(source);
  const targetType = typeChecker.getTypeAtLocation(target);
  
  return typeChecker.isTypeAssignableTo(sourceType, targetType);
}

// Get all properties of a type
function getTypeProperties(
  typeNode: ts.TypeNode,
  typeChecker: ts.TypeChecker
): string[] {
  const type = typeChecker.getTypeFromTypeNode(typeNode);
  const properties = typeChecker.getPropertiesOfType(type);
  
  return properties.map(prop => prop.name);
}

// Find all references to a symbol
function findReferences(
  node: ts.Node,
  program: ts.Program
): ts.ReferenceEntry[] {
  const sourceFile = node.getSourceFile();
  const position = node.getStart();
  
  // Create language service host
  const languageServiceHost: ts.LanguageServiceHost = {
    getCompilationSettings: () => program.getCompilerOptions(),
    getScriptFileNames: () => program.getRootFileNames(),
    getScriptVersion: () => '0',
    getScriptSnapshot: fileName => {
      const sourceFile = program.getSourceFile(fileName);
      if (!sourceFile) {
        return undefined;
      }
      return ts.ScriptSnapshot.fromString(sourceFile.text);
    },
    getCurrentDirectory: () => process.cwd(),
    getDefaultLibFileName: options => ts.getDefaultLibFilePath(options),
    getScriptKind: () => ts.ScriptKind.TS,
    getScriptFileNames: () => program.getRootFileNames()
  };
  
  const languageService = ts.createLanguageService(languageServiceHost);
  
  return languageService.findReferences(sourceFile.fileName, position) || [];
}
```

**Example** Analyzing class hierarchy and interfaces:

```typescript
import * as ts from 'typescript';

// Interface for class information
interface ClassInfo {
  name: string;
  baseClasses: string[];
  implements: string[];
  properties: Array<{
    name: string;
    type: string;
    isPrivate: boolean;
  }>;
  methods: Array<{
    name: string;
    returnType: string;
    parameters: Array<{
      name: string;
      type: string;
    }>;
    isPrivate: boolean;
  }>;
}

function analyzeClasses(sourceText: string): ClassInfo[] {
  // Setup
  const sourceFile = ts.createSourceFile(
    'source.ts',
    sourceText,
    ts.ScriptTarget.ES2020,
    true
  );
  
  const options: ts.CompilerOptions = {
    target: ts.ScriptTarget.ES2020,
    module: ts.ModuleKind.ESNext
  };
  
  const host = ts.createCompilerHost(options);
  host.getSourceFile = (fileName: string) => {
    if (fileName === 'source.ts') {
      return sourceFile;
    }
    return undefined;
  };
  
  const program = ts.createProgram(['source.ts'], options, host);
  const typeChecker = program.getTypeChecker();
  const classInfos: ClassInfo[] = [];
  
  // Visit all nodes
  ts.forEachChild(sourceFile, (node) => {
    if (ts.isClassDeclaration(node) && node.name) {
      const classInfo: ClassInfo = {
        name: node.name.text,
        baseClasses: [],
        implements: [],
        properties: [],
        methods: []
      };
      
      // Get base class
      if (node.heritageClauses) {
        for (const clause of node.heritageClauses) {
          if (clause.token === ts.SyntaxKind.ExtendsKeyword) {
            for (const type of clause.types) {
              classInfo.baseClasses.push(type.expression.getText(sourceFile));
            }
          } else if (clause.token === ts.SyntaxKind.ImplementsKeyword) {
            for (const type of clause.types) {
              classInfo.implements.push(type.expression.getText(sourceFile));
            }
          }
        }
      }
      
      // Get class members
      for (const member of node.members) {
        const modifiers = member.modifiers || [];
        const isPrivate = modifiers.some(m => m.kind === ts.SyntaxKind.PrivateKeyword);
        
        if (ts.isPropertyDeclaration(member) && member.name) {
          const propertyName = member.name.getText(sourceFile);
          const propertyType = member.type 
            ? member.type.getText(sourceFile) 
            : 'any';
          
          classInfo.properties.push({
            name: propertyName,
            type: propertyType,
            isPrivate
          });
        }
        
        if (ts.isMethodDeclaration(member) && member.name) {
          const methodName = member.name.getText(sourceFile);
          const returnType = member.type 
            ? member.type.getText(sourceFile) 
            : 'any';
          
          const parameters = member.parameters.map(param => ({
            name: param.name.getText(sourceFile),
            type: param.type ? param.type.getText(sourceFile) : 'any'
          }));
          
          classInfo.methods.push({
            name: methodName,
            returnType,
            parameters,
            isPrivate
          });
        }
      }
      
      classInfos.push(classInfo);
    }
  });
  
  return classInfos;
}

// Example usage
const source = `
interface Vehicle {
  start(): void;
  stop(): void;
}

class Engine {
  power: number;
  
  constructor(power: number) {
    this.power = power;
  }
  
  start() {
    console.log('Engine started');
  }
}

class Car extends Engine implements Vehicle {
  private model: string;
  color: string;
  
  constructor(model: string, color: string, power: number) {
    super(power);
    this.model = model;
    this.color = color;
  }
  
  start(): void {
    console.log('Car started');
    super.start();
  }
  
  stop(): void {
    console.log('Car stopped');
  }
  
  private changeColor(newColor: string): void {
    this.color = newColor;
  }
}
`;

const classInfos = analyzeClasses(source);
console.log(JSON.stringify(classInfos, null, 2));
```

### Code Generation

Code generation is a powerful aspect of the TypeScript Compiler API that allows you to programmatically generate TypeScript or JavaScript code. This capability is essential for building code generators, migration tools, and automated refactoring systems.

**Key Points**

- The printer module handles converting AST nodes back to source code
- Code generation follows the same structure as AST transformation but focuses on emitting new code
- Generated code can be written to files, displayed to users, or further processed

#### Creating AST Nodes for Code Generation

```typescript
import * as ts from 'typescript';

// Create a simple function declaration
function generateSimpleFunction(name: string, paramName: string, body: ts.Statement[]): ts.FunctionDeclaration {
  return ts.factory.createFunctionDeclaration(
    /* decorators */ undefined,
    /* modifiers */ [ts.factory.createModifier(ts.SyntaxKind.ExportKeyword)],
    /* asteriskToken */ undefined,
    /* name */ ts.factory.createIdentifier(name),
    /* typeParameters */ undefined,
    /* parameters */ [
      ts.factory.createParameterDeclaration(
        /* decorators */ undefined,
        /* modifiers */ undefined,
        /* dotDotDotToken */ undefined,
        /* name */ ts.factory.createIdentifier(paramName),
        /* questionToken */ undefined,
        /* type */ ts.factory.createKeywordTypeNode(ts.SyntaxKind.StringKeyword),
        /* initializer */ undefined
      )
    ],
    /* returnType */ ts.factory.createKeywordTypeNode(ts.SyntaxKind.StringKeyword),
    /* body */ ts.factory.createBlock(body, true)
  );
}

// Generate a function body with return statement
const returnStatement = ts.factory.createReturnStatement(
  ts.factory.createBinaryExpression(
    ts.factory.createStringLiteral("Hello, "),
    ts.SyntaxKind.PlusToken,
    ts.factory.createIdentifier("name")
  )
);

// Generate the complete function
const greetingFunction = generateSimpleFunction("greet", "name", [returnStatement]);
```

#### Printing AST Nodes to Source Code

```typescript
import * as ts from 'typescript';

// Generate the AST node for a function (using previous example)
const greetingFunction = generateSimpleFunction("greet", "name", [returnStatement]);

// Create a source file to contain the function
const sourceFile = ts.factory.createSourceFile(
  [greetingFunction],
  ts.factory.createToken(ts.SyntaxKind.EndOfFileToken),
  ts.NodeFlags.None
);

// Create a printer
const printer = ts.createPrinter({ newLine: ts.NewLineKind.LineFeed });

// Print the AST to a string
const resultFile = printer.printNode(
  ts.EmitHint.Unspecified,
  sourceFile,
  ts.createSourceFile("output.ts", "", ts.ScriptTarget.Latest)
);

console.log(resultFile);
// Output:
// export function greet(name: string): string {
//     return "Hello, " + name;
// }
```

#### Generating Complete Source Files

```typescript
import * as ts from 'typescript';
import * as fs from 'fs';

function generateClassWithMethods(className: string): ts.ClassDeclaration {
  // Create a method
  const getterMethod = ts.factory.createMethodDeclaration(
    /* decorators */ undefined,
    /* modifiers */ [ts.factory.createModifier(ts.SyntaxKind.PublicKeyword)],
    /* asteriskToken */ undefined,
    /* name */ ts.factory.createIdentifier("getName"),
    /* questionToken */ undefined,
    /* typeParameters */ undefined,
    /* parameters */ [],
    /* returnType */ ts.factory.createKeywordTypeNode(ts.SyntaxKind.StringKeyword),
    /* body */ ts.factory.createBlock([
      ts.factory.createReturnStatement(
        ts.factory.createPropertyAccessExpression(
          ts.factory.createThis(),
          "name"
        )
      )
    ], true)
  );

  // Create a property
  const nameProperty = ts.factory.createPropertyDeclaration(
    /* decorators */ undefined,
    /* modifiers */ [ts.factory.createModifier(ts.SyntaxKind.PrivateKeyword)],
    /* name */ ts.factory.createIdentifier("name"),
    /* questionToken */ undefined,
    /* type */ ts.factory.createKeywordTypeNode(ts.SyntaxKind.StringKeyword),
    /* initializer */ ts.factory.createStringLiteral("Default")
  );

  // Create constructor
  const constructor = ts.factory.createConstructorDeclaration(
    /* decorators */ undefined,
    /* modifiers */ undefined,
    /* parameters */ [
      ts.factory.createParameterDeclaration(
        /* decorators */ undefined,
        /* modifiers */ undefined,
        /* dotDotDotToken */ undefined,
        /* name */ ts.factory.createIdentifier("name"),
        /* questionToken */ undefined,
        /* type */ ts.factory.createKeywordTypeNode(ts.SyntaxKind.StringKeyword),
        /* initializer */ undefined
      )
    ],
    /* body */ ts.factory.createBlock([
      ts.factory.createExpressionStatement(
        ts.factory.createBinaryExpression(
          ts.factory.createPropertyAccessExpression(
            ts.factory.createThis(),
            "name"
          ),
          ts.SyntaxKind.EqualsToken,
          ts.factory.createIdentifier("name")
        )
      )
    ], true)
  );
  
  // Create the class declaration
  return ts.factory.createClassDeclaration(
    /* decorators */ undefined,
    /* modifiers */ [ts.factory.createModifier(ts.SyntaxKind.ExportKeyword)],
    /* name */ ts.factory.createIdentifier(className),
    /* typeParameters */ undefined,
    /* heritageClauses */ undefined,
    /* members */ [nameProperty, constructor, getterMethod]
  );
}

// Generate a class
const personClass = generateClassWithMethods("Person");

// Create a source file with imports and the class
const importStatement = ts.factory.createImportDeclaration(
  /* decorators */ undefined,
  /* modifiers */ undefined,
  ts.factory.createImportClause(
    false,
    undefined,
    ts.factory.createNamedImports([
      ts.factory.createImportSpecifier(
        false,
        undefined,
        ts.factory.createIdentifier("Logger")
      )
    ])
  ),
  ts.factory.createStringLiteral("./logger")
);

const sourceFile = ts.factory.createSourceFile(
  [importStatement, personClass],
  ts.factory.createToken(ts.SyntaxKind.EndOfFileToken),
  ts.NodeFlags.None
);

// Print and save to file
const printer = ts.createPrinter({ newLine: ts.NewLineKind.LineFeed });
const result = printer.printNode(
  ts.EmitHint.Unspecified,
  sourceFile,
  ts.createSourceFile("output.ts", "", ts.ScriptTarget.Latest)
);

fs.writeFileSync("person.ts", result);
```

#### Generating Declaration Files (.d.ts)

```typescript
import * as ts from 'typescript';
import * as fs from 'fs';

function generateInterfaceDeclaration(): ts.InterfaceDeclaration {
  return ts.factory.createInterfaceDeclaration(
    /* decorators */ undefined,
    /* modifiers */ [ts.factory.createModifier(ts.SyntaxKind.ExportKeyword)],
    /* name */ ts.factory.createIdentifier("Config"),
    /* typeParameters */ undefined,
    /* heritageClauses */ undefined,
    /* members */ [
      ts.factory.createPropertySignature(
        /* modifiers */ undefined,
        /* name */ ts.factory.createIdentifier("apiKey"),
        /* questionToken */ undefined,
        /* type */ ts.factory.createKeywordTypeNode(ts.SyntaxKind.StringKeyword)
      ),
      ts.factory.createPropertySignature(
        /* modifiers */ undefined,
        /* name */ ts.factory.createIdentifier("timeout"),
        /* questionToken */ ts.factory.createToken(ts.SyntaxKind.QuestionToken),
        /* type */ ts.factory.createKeywordTypeNode(ts.SyntaxKind.NumberKeyword)
      ),
      ts.factory.createMethodSignature(
        /* modifiers */ undefined,
        /* name */ ts.factory.createIdentifier("log"),
        /* questionToken */ undefined,
        /* typeParameters */ undefined,
        /* parameters */ [
          ts.factory.createParameterDeclaration(
            /* decorators */ undefined,
            /* modifiers */ undefined,
            /* dotDotDotToken */ undefined,
            /* name */ ts.factory.createIdentifier("message"),
            /* questionToken */ undefined,
            /* type */ ts.factory.createKeywordTypeNode(ts.SyntaxKind.StringKeyword),
            /* initializer */ undefined
          )
        ],
        /* returnType */ ts.factory.createKeywordTypeNode(ts.SyntaxKind.VoidKeyword)
      )
    ]
  );
}

// Generate declarations
const interfaceDecl = generateInterfaceDeclaration();

// Create a source file
const sourceFile = ts.factory.createSourceFile(
  [interfaceDecl],
  ts.factory.createToken(ts.SyntaxKind.EndOfFileToken),
  ts.NodeFlags.None
);

// Print to a string
const printer = ts.createPrinter({ newLine: ts.NewLineKind.LineFeed });
const result = printer.printNode(
  ts.EmitHint.Unspecified,
  sourceFile,
  ts.createSourceFile("output.d.ts", "", ts.ScriptTarget.Latest)
);

fs.writeFileSync("config.d.ts", result);
```

### Language Service API

The Language Service API is a high-level interface built on top of the Compiler API designed for IDE-like functionality.

**Key Points**

- Provides intelligent code completion, error checking, and quick navigation
- Used by code editors like VS Code for TypeScript language features
- Offers efficient incremental compilation and analysis

#### Creating a Language Service

```typescript
import * as ts from 'typescript';
import * as fs from 'fs';
import * as path from 'path';

// Create a host for the language service
const createLanguageServiceHost = (files: { [fileName: string]: string }): ts.LanguageServiceHost => {
  return {
    getScriptFileNames: () => Object.keys(files),
    getScriptVersion: fileName => "1",
    getScriptSnapshot: fileName => {
      if (!files[fileName]) {
        return undefined;
      }
      return ts.ScriptSnapshot.fromString(files[fileName]);
    },
    getCurrentDirectory: () => process.cwd(),
    getCompilationSettings: () => ({
      target: ts.ScriptTarget.ES2020,
      module: ts.ModuleKind.CommonJS
    }),
    getDefaultLibFileName: options => ts.getDefaultLibFilePath(options),
    fileExists: fileName => files[fileName] !== undefined,
    readFile: fileName => files[fileName],
    readDirectory: ts.sys.readDirectory,
    directoryExists: ts.sys.directoryExists,
    getDirectories: ts.sys.getDirectories,
  };
};

// Example usage
const files = {
  "file.ts": `
    function greet(name: string) {
      return "Hello, " + name;
    }
    const message = greet("TypeScript");
  `
};

// Create the language service
const languageServiceHost = createLanguageServiceHost(files);
const languageService = ts.createLanguageService(languageServiceHost);

// Get diagnostics
const diagnostics = languageService.getSemanticDiagnostics("file.ts");
console.log("Diagnostics:", diagnostics);

// Get completions at a position
const completions = languageService.getCompletionsAtPosition("file.ts", 100, {});
console.log("Completions:", completions?.entries.map(entry => entry.name));
```

#### Implementing Quick Info and Hover

```typescript
import * as ts from 'typescript';

// Continuing from previous example with languageService
const quickInfo = languageService.getQuickInfoAtPosition("file.ts", 80);
if (quickInfo) {
  console.log("Quick Info:");
  console.log("- Display parts:", ts.displayPartsToString(quickInfo.displayParts));
  console.log("- Documentation:", ts.displayPartsToString(quickInfo.documentation || []));
}

// Find definition
const definitions = languageService.getDefinitionAtPosition("file.ts", 80);
if (definitions) {
  console.log("Definitions:");
  definitions.forEach(def => {
    console.log(`- ${def.fileName}:${def.textSpan.start}`);
  });
}
```

### Performance Optimization

Working with the TypeScript Compiler API efficiently requires attention to performance, especially for larger projects.

**Key Points**

- Reusing program instances improves performance for multiple operations
- Incremental compilation provides significant speedups for watch mode
- Memory management is critical for large-scale code manipulation

#### Incremental Compilation

```typescript
import * as ts from 'typescript';

// Create a builder for incremental compilation
function createIncrementalBuilder() {
  const host = ts.createIncrementalCompilerHost({
    target: ts.ScriptTarget.ES2020,
    module: ts.ModuleKind.CommonJS
  });
  
  // Store build info between compilations
  let builderProgram: ts.EmitAndSemanticDiagnosticsBuilderProgram;
  
  return {
    buildFile: (fileName: string, content: string) => {
      // Update the file content
      host.writeFile(fileName, content, false);
      
      // Create or update the builder program
      if (!builderProgram) {
        builderProgram = ts.createEmitAndSemanticDiagnosticsBuilderProgram(
          [fileName],
          {
            target: ts.ScriptTarget.ES2020,
            module: ts.ModuleKind.CommonJS,
            incremental: true
          },
          host,
          undefined, // Old program
          undefined  // Config file host
        );
      } else {
        builderProgram = builderProgram.getProgram().createEmitAndSemanticDiagnosticsBuilderProgram(
          [fileName],
          {
            target: ts.ScriptTarget.ES2020,
            module: ts.ModuleKind.CommonJS,
            incremental: true
          },
          host,
          builderProgram
        );
      }
      
      // Get and return diagnostics
      const diagnostics = [
        ...builderProgram.getSyntacticDiagnostics(),
        ...builderProgram.getSemanticDiagnostics()
      ];
      
      return {
        diagnostics,
        emit: () => builderProgram.emit()
      };
    }
  };
}

// Example usage
const builder = createIncrementalBuilder();
const result = builder.buildFile("file.ts", `
  function greet(name: string) {
    return "Hello, " + name;
  }
`);

console.log("Diagnostics:", result.diagnostics);
const emitResult = result.emit();
console.log("Emit result:", emitResult);
```

#### Memory Usage Optimization

```typescript
import * as ts from 'typescript';

// Function to process files in batches to manage memory
async function processLargeProject(fileNames: string[]) {
  const batchSize = 20;
  const batches = [];
  
  // Split files into batches
  for (let i = 0; i < fileNames.length; i += batchSize) {
    batches.push(fileNames.slice(i, i + batchSize));
  }
  
  const results = [];
  
  // Process each batch
  for (const batch of batches) {
    const program = ts.createProgram(batch, {
      target: ts.ScriptTarget.ES2020,
      module: ts.ModuleKind.CommonJS
    });
    
    // Process files in the batch
    for (const sourceFile of batch.map(file => program.getSourceFile(file))) {
      if (!sourceFile) continue;
      
      // Perform operations on the sourceFile
      const result = analyzeFile(sourceFile, program);
      results.push(result);
    }
    
    // Allow garbage collection between batches
    await new Promise(resolve => setTimeout(resolve, 0));
  }
  
  return results;
}

function analyzeFile(sourceFile: ts.SourceFile, program: ts.Program) {
  // Example analysis function
  const checker = program.getTypeChecker();
  let exportCount = 0;
  
  ts.forEachChild(sourceFile, node => {
    if (ts.isExportDeclaration(node) || 
        (node.modifiers && node.modifiers.some(m => m.kind === ts.SyntaxKind.ExportKeyword))) {
      exportCount++;
    }
  });
  
  return {
    fileName: sourceFile.fileName,
    exportCount
  };
}
```

### Integration with Build Systems

The Compiler API can be integrated with various build systems to create custom TypeScript compilation workflows.

**Key Points**

- Can be used with webpack, rollup, gulp, or custom build processes
- Enables custom transformations as part of the build pipeline
- Provides programmatic access to compilation options and outputs

#### Integration with Webpack

```typescript
// webpack.config.js
const path = require('path');
const ts = require('typescript');

// Custom transformer for webpack loader
function createTransformer() {
  return {
    before(program) {
      return context => sourceFile => {
        // Example: Add console.log to every function
        function visitor(node) {
          // Add console.log at the beginning of function bodies
          if (ts.isFunctionDeclaration(node) && node.body) {
            const consoleLog = ts.factory.createExpressionStatement(
              ts.factory.createCallExpression(
                ts.factory.createPropertyAccessExpression(
                  ts.factory.createIdentifier('console'),
                  'log'
                ),
                undefined,
                [ts.factory.createStringLiteral(`Function called: ${node.name?.text || 'anonymous'}`)]
              )
            );
            
            const newBody = ts.factory.createBlock(
              [consoleLog, ...node.body.statements],
              true
            );
            
            return ts.factory.updateFunctionDeclaration(
              node,
              node.decorators,
              node.modifiers,
              node.asteriskToken,
              node.name,
              node.typeParameters,
              node.parameters,
              node.type,
              newBody
            );
          }
          return ts.visitEachChild(node, visitor, context);
        }
        
        return ts.visitNode(sourceFile, visitor);
      };
    }
  };
}

module.exports = {
  entry: './src/index.ts',
  module: {
    rules: [
      {
        test: /\.ts$/,
        use: [
          {
            loader: 'ts-loader',
            options: {
              getCustomTransformers: () => ({
                before: [createTransformer().before(undefined)]
              })
            }
          }
        ],
        exclude: /node_modules/
      }
    ]
  },
  resolve: {
    extensions: ['.ts', '.js']
  },
  output: {
    filename: 'bundle.js',
    path: path.resolve(__dirname, 'dist')
  }
};
```

### Testing and Debugging

Testing and debugging tools using the TypeScript Compiler API can be crucial for developing robust TypeScript applications.

**Key Points**

- The Compiler API is useful for building testing utilities
- AST-based static analysis can find potential bugs
- Type checking can validate type safety in tests

#### Building a Simple Test Helper

```typescript
import * as ts from 'typescript';

// Function to compile and evaluate TypeScript code for testing
function evalTypeScript(code: string) {
  // Compile the TypeScript code
  const result = ts.transpileModule(code, {
    compilerOptions: {
      module: ts.ModuleKind.CommonJS,
      target: ts.ScriptTarget.ES2020
    }
  });
  
  // Create a function from the compiled code
  const evalFunction = new Function('require', 'module', 'exports', result.outputText);
  
  // Create module context
  const moduleExports = {};
  const moduleObject = { exports: moduleExports };
  
  // Execute the code
  evalFunction(require, moduleObject, moduleExports);
  
  return moduleObject.exports;
}

// Example usage
const testModule = evalTypeScript(`
  export function sum(a: number, b: number): number {
    return a + b;
  }
  
  export const constant = 42;
`);

// Now we can test the compiled module
console.log(testModule.sum(1, 2)); // Outputs: 3
console.log(testModule.constant);  // Outputs: 42
```

#### Creating a Type Checker Helper

```typescript
import * as ts from 'typescript';

// Function to verify type compatibility
function checkTypeCompatibility(sourceCode: string, expectedType: string) {
  // Create an in-memory compiler host
  const compilerHost = ts.createCompilerHost({});
  
  // Create source files
  const testFileName = 'test.ts';
  const files = {
    [testFileName]: `
      const testValue = ${sourceCode};
      const expectedType: ${expectedType} = testValue; // Should compile if types are compatible
    `
  };
  
  // Override the host methods to use our in-memory files
  compilerHost.getSourceFile = (fileName, languageVersion) => {
    if (files[fileName]) {
      return ts.createSourceFile(fileName, files[fileName], languageVersion);
    }
    return undefined;
  };
  
  compilerHost.fileExists = fileName => !!files[fileName];
  compilerHost.readFile = fileName => files[fileName] || '';
  
  // Create the program
  const program = ts.createProgram([testFileName], {
    noEmit: true,
    strict: true
  }, compilerHost);
  
  // Get diagnostics
  const diagnostics = [
    ...program.getSyntacticDiagnostics(),
    ...program.getSemanticDiagnostics()
  ];
  
  return {
    isCompatible: diagnostics.length === 0,
    diagnostics
  };
}

// Example usage
const result = checkTypeCompatibility('{ name: "John", age: 30 }', '{ name: string, age: number }');
console.log('Type compatibility:', result.isCompatible);
if (!result.isCompatible) {
  console.log('Errors:', result.diagnostics.map(d => d.messageText));
}
```

### Plugin Development

The TypeScript Compiler API enables creation of plugins for extending the compiler's functionality.

**Key Points**

- Compiler plugins can add custom transformations, diagnostics, and type checking
- Language service plugins can enhance editor features
- Plugins can be published to npm for wider use

#### Creating a Custom Language Service Plugin

```typescript
// languageServicePlugin.ts
import * as ts from 'typescript';

function init(modules: { typescript: typeof ts }) {
  const typescript = modules.typescript;
  
  function create(info: ts.server.PluginCreateInfo) {
    // Get the existing language service
    const languageService = info.languageService;
    
    // Create a proxy that intercepts calls to the language service
    const proxy: ts.LanguageService = Object.create(null);
    
    // Add your custom logic to the getCompletionsAtPosition method
    proxy.getCompletionsAtPosition = (fileName, position, options) => {
      // Get the original completions
      const originalCompletions = languageService.getCompletionsAtPosition(fileName, position, options);
      
      // Add custom completions
      if (originalCompletions) {
        const sourceFile = languageService.getProgram()?.getSourceFile(fileName);
        if (sourceFile) {
          // Add a custom completion for 'log'
          originalCompletions.entries.push({
            name: 'log',
            kind: typescript.ScriptElementKind.functionElement,
            sortText: '0',
            insertText: 'console.log($0)',
            replacementSpan: undefined,
            hasAction: false,
            source: undefined,
            isRecommended: true,
            isFromUncheckedFile: false,
            isPackageJsonImport: false,
            isImportStatementCompletion: false,
            isSnippet: true,
            kindModifiers: ''
          });
        }
      }
      return originalCompletions;
    };
    
    // Forward all other methods to the original language service
    for (const k of Object.keys(languageService) as Array<keyof ts.LanguageService>) {
      if (proxy[k] === undefined) {
        proxy[k] = (...args: Array<{}>) => {
          return (languageService[k] as any)(...args);
        };
      }
    }
    
    return proxy;
  }
  
  return { create };
}

export = init;
```

#### Creating a Custom Transformer Plugin

```typescript
// transformerPlugin.ts
import * as ts from 'typescript';

// Plugin that converts arrow functions to regular functions
function createArrowFunctionTransformer(program: ts.Program): ts.TransformerFactory<ts.SourceFile> {
  return context => {
    return sourceFile => {
      // Visitor function
      function visitor(node: ts.Node): ts.Node {
        if (ts.isArrowFunction(node)) {
          // Convert arrow function to regular function
          return ts.factory.createFunctionExpression(
            /* modifiers */ undefined,
            /* asteriskToken */ undefined,
            /* name */ undefined,
            /* typeParameters */ node.typeParameters,
            /* parameters */ node.parameters,
            /* type */ node.type,
            /* body */ ts.isBlock(node.body) 
              ? node.body 
              : ts.factory.createBlock([ts.factory.createReturnStatement(node.body)])
          );
        }
        return ts.visitEachChild(node, visitor, context);
      }
      
      return ts.visitNode(sourceFile, visitor);
    };
  };
}

export default function(program: ts.Program) {
  return {
    before: [createArrowFunctionTransformer(program)]
  };
}
```

### Real-World Applications

The TypeScript Compiler API has numerous practical applications in real-world development scenarios.

**Key Points**

- Building code generators for boilerplate reduction
- Creating documentation extractors for TypeScript code
- Implementing custom linting rules
- Developing migration tools between library versions

#### Documentation Generator Example

```typescript
import * as ts from 'typescript';
import * as fs from 'fs';
import * as path from 'path';

interface DocEntry {
  name: string;
  type: string;
  documentation: string;
  parameters?: DocEntry[];
  returnType?: string;
  members?: DocEntry[];
}

function generateDocumentation(fileNames: string[], outPath: string): void {
  // Build a program using the set of files
  const program = ts.createProgram(fileNames, {
    target: ts.ScriptTarget.ES2020,
    module: ts.ModuleKind.CommonJS
  });
  
  // Get the checker for type information
  const checker = program.getTypeChecker();
  const output: DocEntry[] = [];

  // Visit each source file
  for (const sourceFile of program.getSourceFiles()) {
    if (!fileNames.includes(sourceFile.fileName)) continue;
    
    // Walk the tree to find exports
    ts.forEachChild(sourceFile, node => {
      if (!isNodeExported(node)) return;
      
      if (ts.isClassDeclaration(node) && node.name) {
        output.push(serializeClass(node, checker));
      } else if (ts.isFunctionDeclaration(node) && node.name) {
        output.push(serializeFunction(node, checker));
      } else if (ts.isInterfaceDeclaration(node) && node.name) {
        output.push(serializeInterface(node, checker));
      }
    });
  }
  
  // Write the output to a markdown file
  fs.writeFileSync(outPath, generateMarkdown(output));
}

function isNodeExported(node: ts.Node): boolean {
  return (
    (ts.getCombinedModifierFlags(node as ts.Declaration) & ts.ModifierFlags.Export) !== 0 ||
    (!!node.parent && node.parent.kind === ts.SyntaxKind.SourceFile)
  );
}

function serializeClass(node: ts.ClassDeclaration, checker: ts.TypeChecker): DocEntry {
  const symbol = checker.getSymbolAtLocation(node.name!);
  const details = serializeSymbol(symbol!, checker);
  details.members = [];
  
  // Get members
  for (const member of node.members) {
    if (ts.isMethodDeclaration(member) && member.name) {
      details.members.push(serializeMethod(member, checker));
    } else if (ts.isPropertyDeclaration(member) && member.name) {
      details.members.push(serializeProperty(member, checker));
    }
  }
  
  return details;
}

function serializeMethod(node: ts.MethodDeclaration, checker: ts.TypeChecker): DocEntry {
  const symbol = checker.getSymbolAtLocation(node.name);
  const details = serializeSymbol(symbol!, checker);
  
  details.parameters = [];
  details.type = 'method';
  
  // Get parameters
  for (const param of node.parameters) {
    const paramSymbol = checker.getSymbolAtLocation(param.name);
    if (paramSymbol) {
      details.parameters.push(serializeSymbol(paramSymbol, checker));
    }
  }
  
  // Get return type
  if (node.type) {
    details.returnType = checker.typeToString(checker.getTypeFromTypeNode(node.type));
  }
  
  return details;
}

function serializeProperty(node: ts.PropertyDeclaration, checker: ts.TypeChecker): DocEntry {
  const symbol = checker.getSymbolAtLocation(node.name);
  const details = serializeSymbol(symbol!, checker);
  details.type = 'property';
  
  // Get property type
  if (node.type) {
    details.returnType = checker.typeToString(checker.getTypeFromTypeNode(node.type));
  }
  
  return details;
}

function serializeFunction(node: ts.FunctionDeclaration, checker: ts.TypeChecker): DocEntry {
  const symbol = checker.getSymbolAtLocation(node.name!);
  const details = serializeSymbol(symbol!, checker);
  details.parameters = [];
  details.type = 'function';
  
  // Get parameters
  for (const param of node.parameters) {
    const paramSymbol = checker.getSymbolAtLocation(param.name);
    if (paramSymbol) {
      details.parameters.push(serializeSymbol(paramSymbol, checker));
    }
  }
  
  // Get return type
  if (node.type) {
    details.returnType = checker.typeToString(checker.getTypeFromTypeNode(node.type));
  }
  
  return details;
}

function serializeInterface(node: ts.InterfaceDeclaration, checker: ts.TypeChecker): DocEntry {
  const symbol = checker.getSymbolAtLocation(node.name);
  const details = serializeSymbol(symbol!, checker);
  details.members = [];
  details.type = 'interface';
  
  // Get members
  for (const member of node.members) {
    if (ts.isPropertySignature(member) && member.name) {
      const memberSymbol = checker.getSymbol
```

---

## Custom Transformations in TypeScript

### Introduction to TypeScript Transformers

TypeScript's compiler API provides powerful mechanisms for programmatically analyzing and transforming code. Custom transformers allow you to hook into the TypeScript compilation process, enabling code generation, syntax transformation, and static analysis beyond what the built-in language features offer.

**Key Points**

- TypeScript transformers operate on the Abstract Syntax Tree (AST)
- Transformers can generate new code, modify existing code, or perform validation
- They integrate with the TypeScript compilation pipeline
- Transformers make advanced metaprogramming possible without runtime overhead

### Compiler API Fundamentals

Before diving into transformers, it's important to understand the TypeScript Compiler API's core components:

```typescript
import * as ts from "typescript";

// Create a program from source files
const program = ts.createProgram(["./src/file.ts"], {
  target: ts.ScriptTarget.ES2020,
  module: ts.ModuleKind.ESNext
});

// Get the TypeChecker - used for semantic analysis
const typeChecker = program.getTypeChecker();

// Get a specific source file from the program
const sourceFile = program.getSourceFile("./src/file.ts");

// Get diagnostics (errors/warnings)
const diagnostics = ts.getPreEmitDiagnostics(program);
```

### Writing Custom Transformers

Custom transformers are implemented as factory functions that return a transformer function:

```typescript
import * as ts from "typescript";

// A simple transformer factory function
function myTransformerFactory(program: ts.Program): ts.TransformerFactory<ts.SourceFile> {
  return (context: ts.TransformationContext) => {
    return (sourceFile: ts.SourceFile) => {
      // The transformation logic
      function visit(node: ts.Node): ts.Node {
        // Modify or replace nodes here
        
        // Example: Add comment to function declarations
        if (ts.isFunctionDeclaration(node) && node.name) {
          const newNode = ts.addSyntheticLeadingComment(
            node,
            ts.SyntaxKind.MultiLineCommentTrivia,
            ` Function: ${node.name.text} `,
            true
          );
          return newNode;
        }
        
        // Continue recursion by visiting each child node
        return ts.visitEachChild(node, visit, context);
      }
      
      // Start the recursive traversal at the source file root
      return ts.visitNode(sourceFile, visit);
    };
  };
}

// Using the transformer
const program = ts.createProgram(["./src/file.ts"], {/*compiler options*/});
const transformationResult = ts.transform(
  program.getSourceFiles(),
  [myTransformerFactory(program)]
);

// Get the transformed source files
const transformedSourceFiles = transformationResult.transformed;
```

### Custom Transformer Configuration with ts-node or ttypescript

For practical usage, transformers are often integrated using tools like `ttypescript` or custom loaders:

```json
// tsconfig.json with ttypescript
{
  "compilerOptions": {
    "target": "es2020",
    "module": "commonjs",
    "plugins": [
      { "transform": "./path/to/my-transformer.js" }
    ]
  }
}
```

Custom transformer registration with `ts-node`:

```typescript
// register.js
const tsNode = require('ts-node');
const myTransformer = require('./my-transformer');

tsNode.register({
  transformers: {
    before: [myTransformer.default]
  }
});
```

### Code Generation

One powerful application of transformers is automatic code generation:

#### Type-Safe Validators Generator

```typescript
// This transformer generates validation functions from interfaces
function validatorGeneratorFactory(program: ts.Program): ts.TransformerFactory<ts.SourceFile> {
  return context => {
    const typeChecker = program.getTypeChecker();
    
    return sourceFile => {
      const interfacesToProcess: ts.InterfaceDeclaration[] = [];
      
      // First pass: collect interfaces with @validate comment
      function collectInterfaces(node: ts.Node) {
        if (ts.isInterfaceDeclaration(node)) {
          const comments = ts.getLeadingCommentRanges(
            sourceFile.text, 
            node.pos
          );
          
          if (comments && comments.some(c => 
            sourceFile.text.substring(c.pos, c.end).includes('@validate'))) {
            interfacesToProcess.push(node);
          }
        }
        
        ts.forEachChild(node, collectInterfaces);
      }
      
      collectInterfaces(sourceFile);
      
      if (interfacesToProcess.length === 0) {
        return sourceFile;
      }
      
      // Generate validation functions for each interface
      const validatorFunctions = interfacesToProcess.map(interfaceDecl => {
        const interfaceName = interfaceDecl.name.text;
        const validatorName = `validate${interfaceName}`;
        
        const properties: ts.PropertySignature[] = [];
        interfaceDecl.members.forEach(member => {
          if (ts.isPropertySignature(member) && member.name) {
            properties.push(member);
          }
        });
        
        // Generate validation logic for each property
        const validationChecks = properties.map(prop => {
          const propName = prop.name.getText(sourceFile);
          const propType = typeChecker.getTypeAtLocation(prop.type!);
          
          let validationExpression: string;
          if (propType.flags & ts.TypeFlags.String) {
            validationExpression = `typeof obj.${propName} === 'string'`;
          } else if (propType.flags & ts.TypeFlags.Number) {
            validationExpression = `typeof obj.${propName} === 'number'`;
          } else if (propType.flags & ts.TypeFlags.Boolean) {
            validationExpression = `typeof obj.${propName} === 'boolean'`;
          } else {
            // Default fallback
            validationExpression = `obj.${propName} !== undefined`;
          }
          
          const isOptional = prop.questionToken !== undefined;
          if (isOptional) {
            return `(obj.${propName} === undefined || ${validationExpression})`;
          }
          return validationExpression;
        });
        
        // Create the validator function code
        return `
function ${validatorName}(obj: any): obj is ${interfaceName} {
  if (!obj || typeof obj !== 'object') return false;
  return ${validationChecks.join(' && ')};
}`;
      });
      
      // Create a new source file with the original content + validators
      const updatedText = sourceFile.text + '\n\n' + validatorFunctions.join('\n\n');
      const newSourceFile = ts.createSourceFile(
        sourceFile.fileName,
        updatedText,
        sourceFile.languageVersion,
        true
      );
      
      return newSourceFile;
    };
  };
}
```

#### Enum Extensions Generator

```typescript
// This transformer generates utility methods for enums
function enumUtilsTransformerFactory(): ts.TransformerFactory<ts.SourceFile> {
  return context => {
    return sourceFile => {
      // Find all enum declarations
      const enums: ts.EnumDeclaration[] = [];
      
      function collectEnums(node: ts.Node): void {
        if (ts.isEnumDeclaration(node)) {
          enums.push(node);
        }
        ts.forEachChild(node, collectEnums);
      }
      
      collectEnums(sourceFile);
      
      if (enums.length === 0) {
        return sourceFile;
      }
      
      // Generate utility functions for each enum
      const enumUtils = enums.map(enumDecl => {
        const enumName = enumDecl.name.text;
        
        return `
// Utility functions for ${enumName} enum
namespace ${enumName} {
  export function toArray(): Array<{ key: string; value: ${enumName} }> {
    return Object.keys(${enumName})
      .filter(key => isNaN(Number(key)))
      .map(key => ({ key, value: ${enumName}[key] as unknown as ${enumName} }));
  }

  export function toString(value: ${enumName}): string {
    return ${enumName}[value];
  }

  export function fromString(key: string): ${enumName} | undefined {
    const value = ${enumName}[key as keyof typeof ${enumName}];
    return typeof value === 'number' ? value : undefined;
  }
}`;
      });
      
      // Append the utility functions to the source file
      const updatedText = sourceFile.text + '\n\n' + enumUtils.join('\n\n');
      return ts.createSourceFile(
        sourceFile.fileName,
        updatedText,
        sourceFile.languageVersion,
        true
      );
    };
  };
}
```

### Visitors Pattern

The visitor pattern is central to TypeScript transformers. It provides a structured way to traverse and potentially modify an AST:

#### Advanced AST Visitor

```typescript
import * as ts from "typescript";

// A more structured visitor approach
function createVisitor(context: ts.TransformationContext, typeChecker: ts.TypeChecker) {
  const visitor: ts.Visitor = (node: ts.Node): ts.Node => {
    // Handle different node types
    if (ts.isClassDeclaration(node)) {
      return visitClass(node);
    }
    
    if (ts.isInterfaceDeclaration(node)) {
      return visitInterface(node);
    }
    
    if (ts.isFunctionDeclaration(node)) {
      return visitFunction(node);
    }
    
    // Continue traversal
    return ts.visitEachChild(node, visitor, context);
  };
  
  // Specialized visitors for different node types
  function visitClass(node: ts.ClassDeclaration): ts.ClassDeclaration {
    // Process class declaration
    // For example, add a decorator
    if (!node.modifiers?.some(m => m.kind === ts.SyntaxKind.AbstractKeyword)) {
      const newDecorator = ts.factory.createDecorator(
        ts.factory.createCallExpression(
          ts.factory.createIdentifier('Injectable'),
          undefined,
          []
        )
      );
      
      return ts.factory.updateClassDeclaration(
        node,
        [...(node.decorators || []), newDecorator],
        node.modifiers,
        node.name,
        node.typeParameters,
        node.heritageClauses,
        node.members
      );
    }
    
    return node;
  }
  
  function visitInterface(node: ts.InterfaceDeclaration): ts.InterfaceDeclaration {
    // Process interface declaration
    return node;
  }
  
  function visitFunction(node: ts.FunctionDeclaration): ts.FunctionDeclaration {
    // Process function declaration
    return node;
  }
  
  return visitor;
}

function myTransformerFactory(program: ts.Program): ts.TransformerFactory<ts.SourceFile> {
  return context => {
    const typeChecker = program.getTypeChecker();
    const visitor = createVisitor(context, typeChecker);
    
    return sourceFile => {
      return ts.visitNode(sourceFile, visitor) as ts.SourceFile;
    };
  };
}
```

#### Type-Aware Visitor

```typescript
import * as ts from "typescript";

// A visitor that utilizes TypeScript's type system
function createTypeAwareVisitor(
  context: ts.TransformationContext,
  typeChecker: ts.TypeChecker
) {
  const visitor: ts.Visitor = (node: ts.Node): ts.Node => {
    // Inspect function calls
    if (ts.isCallExpression(node)) {
      const signature = typeChecker.getResolvedSignature(node);
      if (signature) {
        const returnType = typeChecker.getReturnTypeOfSignature(signature);
        const typeString = typeChecker.typeToString(returnType);
        
        // Example: Add type assertion to Promise-returning functions
        if (typeString.includes('Promise<')) {
          return ts.factory.createAsExpression(
            node,
            ts.factory.createTypeReferenceNode(
              ts.factory.createIdentifier(typeString),
              undefined
            )
          );
        }
      }
    }
    
    // Continue traversal
    return ts.visitEachChild(node, visitor, context);
  };
  
  return visitor;
}
```

### Source Code Manipulation

Transformers excel at modifying source code in sophisticated ways:

#### Property Decorator Transformer

```typescript
function propertyDecoratorTransformerFactory(): ts.TransformerFactory<ts.SourceFile> {
  return context => {
    const { factory } = context;
    
    return sourceFile => {
      function visit(node: ts.Node): ts.Node {
        // Find class property with @logger decorator
        if (
          ts.isPropertyDeclaration(node) && 
          node.decorators?.some(d => 
            ts.isIdentifier(d.expression) && 
            d.expression.text === 'logger'
          )
        ) {
          // Get property name
          const propName = node.name.getText(sourceFile);
          
          // Create getter and setter with logging
          const getter = factory.createGetAccessorDeclaration(
            undefined,
            node.modifiers,
            node.name,
            [],
            node.type,
            factory.createBlock([
              factory.createReturnStatement(
                factory.createPropertyAccessExpression(
                  factory.createThis(),
                  factory.createIdentifier(`_${propName}`)
                )
              )
            ])
          );
          
          const setterParam = factory.createParameterDeclaration(
            undefined,
            undefined,
            undefined,
            factory.createIdentifier('value'),
            undefined,
            node.type
          );
          
          const setter = factory.createSetAccessorDeclaration(
            undefined,
            node.modifiers,
            node.name,
            [setterParam],
            factory.createBlock([
              factory.createExpressionStatement(
                factory.createCallExpression(
                  factory.createPropertyAccessExpression(
                    factory.createIdentifier('console'),
                    factory.createIdentifier('log')
                  ),
                  undefined,
                  [
                    factory.createStringLiteral(`Setting ${propName}:`),
                    factory.createIdentifier('value')
                  ]
                )
              ),
              factory.createExpressionStatement(
                factory.createBinaryExpression(
                  factory.createPropertyAccessExpression(
                    factory.createThis(),
                    factory.createIdentifier(`_${propName}`)
                  ),
                  factory.createToken(ts.SyntaxKind.EqualsToken),
                  factory.createIdentifier('value')
                )
              )
            ])
          );
          
          // Create the private backing field
          const backingField = factory.createPropertyDeclaration(
            undefined,
            [factory.createModifier(ts.SyntaxKind.PrivateKeyword)],
            factory.createIdentifier(`_${propName}`),
            undefined,
            node.type,
            node.initializer
          );
          
          // Return an array of nodes to replace the original node
          return [backingField, getter, setter];
        }
        
        return ts.visitEachChild(node, visit, context);
      }
      
      return ts.visitNode(sourceFile, visit);
    };
  };
}
```

#### Import Organizer Transformer

```typescript
function importOrganizerFactory(): ts.TransformerFactory<ts.SourceFile> {
  return context => {
    return sourceFile => {
      // Collect all imports
      const imports: ts.ImportDeclaration[] = [];
      const nonImportNodes: ts.Node[] = [];
      
      // Separate import statements from other nodes
      sourceFile.statements.forEach(node => {
        if (ts.isImportDeclaration(node)) {
          imports.push(node);
        } else {
          nonImportNodes.push(node);
        }
      });
      
      if (imports.length <= 1) {
        return sourceFile; // No need to reorganize
      }
      
      // Sort imports by module specifier
      const sortedImports = [...imports].sort((a, b) => {
        const textA = (a.moduleSpecifier as ts.StringLiteral).text;
        const textB = (b.moduleSpecifier as ts.StringLiteral).text;
        
        // Built-in modules first
        const aIsBuiltin = !textA.startsWith('./') && !textA.startsWith('../');
        const bIsBuiltin = !textB.startsWith('./') && !textB.startsWith('../');
        
        if (aIsBuiltin && !bIsBuiltin) return -1;
        if (!aIsBuiltin && bIsBuiltin) return 1;
        
        // Alphabetical sort
        return textA.localeCompare(textB);
      });
      
      // Create a new source file with sorted imports
      const newStatements = [...sortedImports, ...nonImportNodes];
      
      return ts.factory.updateSourceFile(
        sourceFile,
        newStatements,
        sourceFile.isDeclarationFile,
        sourceFile.referencedFiles,
        sourceFile.typeReferenceDirectives,
        sourceFile.hasNoDefaultLib,
        sourceFile.libReferenceDirectives
      );
    };
  };
}
```

### Practical Transformer Examples

#### JSX Component Analyzer

```typescript
function jsxAnalyzerFactory(program: ts.Program): ts.TransformerFactory<ts.SourceFile> {
  return context => {
    const typeChecker = program.getTypeChecker();
    
    return sourceFile => {
      // Skip non-JSX files
      if (!sourceFile.fileName.endsWith('.tsx')) {
        return sourceFile;
      }
      
      const componentInfo: {
        name: string;
        props: Array<{ name: string; type: string; required: boolean }>;
      }[] = [];
      
      function visit(node: ts.Node) {
        // Look for function components or class components
        if (ts.isFunctionDeclaration(node) && node.name) {
          analyzeComponent(node.name.text, node);
        } else if (
          ts.isVariableStatement(node) && 
          node.declarationList.declarations.length === 1
        ) {
          const declaration = node.declarationList.declarations[0];
          if (
            ts.isIdentifier(declaration.name) && 
            declaration.initializer && 
            ts.isArrowFunction(declaration.initializer)
          ) {
            analyzeComponent(declaration.name.text, declaration.initializer);
          }
        } else if (
          ts.isClassDeclaration(node) && 
          node.name &&
          node.heritageClauses?.some(clause => 
            clause.types.some(type => {
              const text = type.expression.getText(sourceFile);
              return text.includes('Component') || text.includes('PureComponent');
            })
          )
        ) {
          analyzeComponent(node.name.text, node);
        }
        
        ts.forEachChild(node, visit);
      }
      
      function analyzeComponent(name: string, node: ts.Node) {
        // Find the props parameter/type
        let propsType: ts.Type | undefined;
        
        if (ts.isFunctionLike(node) && node.parameters.length > 0) {
          const propsParam = node.parameters[0];
          if (propsParam.type) {
            propsType = typeChecker.getTypeAtLocation(propsParam.type);
          }
        } else if (ts.isClassDeclaration(node)) {
          // For class components, find the Props generic type
          const heritageClause = node.heritageClauses?.[0];
          if (heritageClause && heritageClause.types.length > 0) {
            const baseType = heritageClause.types[0];
            if (baseType.typeArguments?.[0]) {
              propsType = typeChecker.getTypeAtLocation(baseType.typeArguments[0]);
            }
          }
        }
        
        if (!propsType) return;
        
        // Extract props information
        const props: Array<{ name: string; type: string; required: boolean }> = [];
        
        const properties = typeChecker.getPropertiesOfType(propsType);
        properties.forEach(property => {
          const propType = typeChecker.getTypeOfSymbolAtLocation(
            property, 
            sourceFile
          );
          
          const isOptional = (property.flags & ts.SymbolFlags.Optional) !== 0;
          
          props.push({
            name: property.name,
            type: typeChecker.typeToString(propType),
            required: !isOptional
          });
        });
        
        if (props.length > 0) {
          componentInfo.push({ name, props });
        }
      }
      
      visit(sourceFile);
      
      // Generate documentation as a comment at the end of the file
      if (componentInfo.length > 0) {
        const componentDocs = componentInfo.map(comp => {
          const propsTable = comp.props.map(prop => 
            `| ${prop.name} | ${prop.type} | ${prop.required ? 'Yes' : 'No'} |`
          ).join('\n');
          
          return `
/*
 * Component: ${comp.name}
 * Props:
 * | Name | Type | Required |
 * |------|------|----------|
 ${propsTable}
 */`;
        }).join('\n');
        
        const updatedText = sourceFile.text + '\n\n' + componentDocs;
        return ts.createSourceFile(
          sourceFile.fileName,
          updatedText,
          sourceFile.languageVersion,
          true
        );
      }
      
      return sourceFile;
    };
  };
}
```

#### Runtime Type Check Injector

```typescript
function typeCheckInjectorFactory(program: ts.Program): ts.TransformerFactory<ts.SourceFile> {
  return context => {
    const typeChecker = program.getTypeChecker();
    const factory = context.factory;
    
    return sourceFile => {
      // Skip declaration files
      if (sourceFile.isDeclarationFile) {
        return sourceFile;
      }
      
      function visit(node: ts.Node): ts.Node {
        // Target function declarations with @typeCheck comment
        if (
          ts.isFunctionDeclaration(node) && 
          node.name &&
          hasTypeCheckComment(node, sourceFile)
        ) {
          return injectTypeChecks(node);
        }
        
        return ts.visitEachChild(node, visit, context);
      }
      
      function hasTypeCheckComment(node: ts.Node, sourceFile: ts.SourceFile): boolean {
        const commentRanges = ts.getLeadingCommentRanges(
          sourceFile.text, 
          node.pos
        );
        
        if (!commentRanges) return false;
        
        return commentRanges.some(range => {
          const comment = sourceFile.text.substring(range.pos, range.end);
          return comment.includes('@typeCheck');
        });
      }
      
      function injectTypeChecks(node: ts.FunctionDeclaration): ts.FunctionDeclaration {
        if (!node.parameters.length || !node.body) {
          return node;
        }
        
        // Generate runtime checks for each parameter
        const typeCheckStatements: ts.Statement[] = [];
        
        node.parameters.forEach(param => {
          if (!param.type || !ts.isIdentifier(param.name)) {
            return;
          }
          
          const paramName = param.name.text;
          const paramType = typeChecker.getTypeAtLocation(param.type);
          
          // Create runtime type checks based on TypeScript types
          if (paramType.flags & ts.TypeFlags.String) {
            typeCheckStatements.push(createTypeCheck(paramName, 'string'));
          } else if (paramType.flags & ts.TypeFlags.Number) {
            typeCheckStatements.push(createTypeCheck(paramName, 'number'));
          } else if (paramType.flags & ts.TypeFlags.Boolean) {
            typeCheckStatements.push(createTypeCheck(paramName, 'boolean'));
          } else if (paramType.flags & ts.TypeFlags.Object) {
            // For objects, check if it's an array or a regular object
            const typeString = typeChecker.typeToString(paramType);
            
            if (typeString.endsWith('[]') || typeString === 'Array<any>') {
              typeCheckStatements.push(createArrayCheck(paramName));
            } else {
              typeCheckStatements.push(createObjectCheck(paramName));
            }
          }
        });
        
        // If no checks were generated, return the original node
        if (typeCheckStatements.length === 0) {
          return node;
        }
        
        // Create a new function body with type checks at the beginning
        const newBody = factory.createBlock(
          [...typeCheckStatements, ...node.body.statements],
          true
        );
        
        return factory.updateFunctionDeclaration(
          node,
          node.decorators,
          node.modifiers,
          node.asteriskToken,
          node.name,
          node.typeParameters,
          node.parameters,
          node.type,
          newBody
        );
      }
      
      function createTypeCheck(paramName: string, expectedType: string): ts.Statement {
        // Create: if (typeof paramName !== 'expectedType') throw new Error(...)
        return factory.createIfStatement(
          factory.createBinaryExpression(
            factory.createTypeOfExpression(
              factory.createIdentifier(paramName)
            ),
            factory.createToken(ts.SyntaxKind.ExclamationEqualsEqualsToken),
            factory.createStringLiteral(expectedType)
          ),
          factory.createThrowStatement(
            factory.createNewExpression(
              factory.createIdentifier('Error'),
              undefined,
              [factory.createStringLiteral(
                `Parameter '${paramName}' must be of type '${expectedType}'`
              )]
            )
          ),
          undefined
        );
      }
      
      function createArrayCheck(paramName: string): ts.Statement {
        // Create: if (!Array.isArray(paramName)) throw new Error(...)
        return factory.createIfStatement(
          factory.createPrefixUnaryExpression(
            ts.SyntaxKind.ExclamationToken,
            factory.createCallExpression(
              factory.createPropertyAccessExpression(
                factory.createIdentifier('Array'),
                factory.createIdentifier('isArray')
              ),
              undefined,
              [factory.createIdentifier(paramName)]
            )
          ),
          factory.createThrowStatement(
            factory.createNewExpression(
              factory.createIdentifier('Error'),
              undefined,
              [factory.createStringLiteral(
                `Parameter '${paramName}' must be an array`
              )]
            )
          ),
          undefined
        );
      }
      
      function createObjectCheck(paramName: string): ts.Statement {
        // Create: if (paramName === null || typeof paramName !== 'object') throw new Error(...)
        return factory.createIfStatement(
          factory.createBinaryExpression(
            factory.createBinaryExpression(
              factory.createIdentifier(paramName),
              factory.createToken(ts.SyntaxKind.EqualsEqualsEqualsToken),
              factory.createNull()
            ),
            factory.createToken(ts.SyntaxKind.BarBarToken),
            factory.createBinaryExpression(
              factory.createTypeOfExpression(
                factory.createIdentifier(paramName)
              ),
              factory.createToken(ts.SyntaxKind.ExclamationEqualsEqualsToken),
              factory.createStringLiteral('object')
            )
          ),
          factory.createThrowStatement(
            factory.createNewExpression(
              factory.createIdentifier('Error'),
              undefined,
              [factory.createStringLiteral(
                `Parameter '${paramName}' must be an object`
              )]
            )
          ),
          undefined
        );
      }
      
      return ts.visitNode(sourceFile, visit);
    };
  };
}
```

### Building a Custom Transformer Pipeline

For complex transformations, it's often useful to build a pipeline of transformers:

```typescript
// transformer-pipeline.ts
import * as ts from "typescript";
import * as path from "path";
import * as fs from "fs";

// Import custom transformers
import { importOrganizerFactory } from "./transformers/import-organizer";
import { propertyDecoratorTransformerFactory } from "./transformers/property-decorator";
import { enumUtilsTransformerFactory } from "./transformers/enum-utils";

export function createTransformerProgram(
  rootFileNames: string[],
  options: ts.CompilerOptions,
  host?: ts.CompilerHost
) {
  // Create the TypeScript program
  const program = ts.createProgram(rootFileNames, options, host);
  
  // Define transformer factories
  const transformerFactories: ts.TransformerFactory<ts.SourceFile>[] = [
    importOrganizerFactory(),
    propertyDecoratorTransformerFactory(),
    enumUtilsTransformerFactory()
  ];
  
  // Create the emit function
  const emit = (writeFile?: ts.WriteFileCallback) => {
    const emitResult = program.emit(
      undefined, // sourceFile - undefined means all files
      writeFile,
      undefined, // cancellationToken
      false,     // emitOnlyDtsFiles
      {
        before: transformerFactories
      }
    );
    
    // Return diagnostics and emitResult
    const diagnostics = ts.getPreEmitDiagnostics(program).concat(emitResult.diagnostics);
    return {
      diagnostics,
      emitResult
    };
  };
  
  return {
    program,
    emit
  };
}

// Usage
const { program, emit } = createTransformerProgram(
  ["./src/index.ts"],
  {
    target: ts.ScriptTarget.ES2020,
    module: ts.ModuleKind.ESNext,
    outDir: "./dist"
  }
);

emit((fileName, text) => {
  fs.mkdirSync(path.dirname(fileName), { recursive: true });
  fs.writeFileSync(fileName, text);
});
```

### Integration with Build Tools

#### Webpack Integration

```typescript
// webpack.config.js
const path = require('path');

module.exports = {
  entry: './src/index.ts',
  module: {
    rules: [
      {
        test: /\.tsx?$/,
        use: [
          {
            loader: 'ts-loader',
            options: {
              getCustomTransformers: program => ({
                before: [
                  require('./transformers/my-transformer').default(program)
                ]
              })
            }
          }
        ],
        exclude: /node_modules/
      }
    ]
  },
  resolve: {
    extensions: ['.tsx', '.ts', '.js']
  },
  output: {
    filename: 'bundle.js',
    path: path.resolve(__dirname, 'dist')
  }
};
```

#### Rollup Integration

```javascript
// rollup.config.js
import typescript from '@rollup/plugin-typescript';
import { defineConfig } from 'rollup';
import path from 'path';
import { myTransformerFactory } from './transformers/my-transformer';

/**
 * Rollup config using a custom TypeScript transformer
 */
export default defineConfig({
  input: 'src/index.ts',
  output: {
    file: 'dist/bundle.js',
    format: 'esm',
    sourcemap: true // optional, but useful for debugging
  },
  plugins: [
    typescript({
      tsconfig: './tsconfig.json',
      transformers: {
        before: [myTransformerFactory]
      },
      // Ensures declaration files are emitted if needed
      declaration: true,
      declarationDir: path.resolve(__dirname, 'dist/types')
    })
  ]
});
```

**Notes:**

- `@rollup/plugin-typescript` uses the TypeScript compiler under the hood and allows customization via transformers.
- The `transformers.before` option hooks into the **TypeScript compiler pipeline**, inserting your transformer **before** the standard ones like type checking.
- `myTransformerFactory` should export a factory function that returns a `ts.TransformerFactory<ts.SourceFile>`.
    

---

**Example Transformer (Optional Reference):**

```ts
// transformers/my-transformer.ts
import * as ts from 'typescript';

export function myTransformerFactory(): ts.TransformerFactory<ts.SourceFile> {
  return context => {
    return sourceFile => {
      // Example: log and return file unmodified
      console.log(`Transforming: ${sourceFile.fileName}`);
      return sourceFile;
    };
  };
}
```

### Debugging Custom Transformers

Debugging TypeScript transformers can be challenging since they operate during the compilation process. Having proper debugging strategies is essential for transformer development.

**Key Points**

- Transformers operate at compile time, making them difficult to debug with regular tools
- Using logging and inspection techniques is crucial
- TypeScript provides diagnostic tools to help debug transformers
- Testing transformers in isolation simplifies debugging

Effective techniques for debugging custom transformers:

1. Console logging approach:
    
    ```typescript
    function createTransformer(program: ts.Program): ts.TransformerFactory<ts.SourceFile> {
      return context => {
        return sourceFile => {
          console.log(`Processing file: ${sourceFile.fileName}`);
          // Add more logging as needed
          return ts.visitNode(sourceFile, createVisitor(context, program));
        };
      };
    }
    ```
    
2. Print AST nodes:
    
    ```typescript
    function printNode(node: ts.Node): void {
      console.log({
        kind: ts.SyntaxKind[node.kind],
        pos: node.pos,
        end: node.end,
        text: node.getText(),
        flags: node.flags
      });
    }
    ```
    
3. Using TypeScript's debugging emit feature:
    
    ```typescript
    const result = ts.transform(sourceFile, [myTransformer], {
      debugMode: true
    });
    ```
    
4. Writing AST snapshots to files:
    
    ```typescript
    import * as fs from 'fs';
    
    function debugTransformerOutput(node: ts.Node, stage: string): void {
      const printer = ts.createPrinter({ newLine: ts.NewLineKind.LineFeed });
      const output = printer.printNode(
        ts.EmitHint.Unspecified,
        node,
        node.getSourceFile()
      );
      
      fs.writeFileSync(
        `debug-output-${stage}-${Date.now()}.ts`,
        output,
        'utf8'
      );
    }
    ```
    
5. Creating unit tests for transformers:
    
    ```typescript
    import * as ts from 'typescript';
    
    function testTransformer(
      input: string,
      transformer: ts.TransformerFactory<ts.SourceFile>
    ): string {
      const sourceFile = ts.createSourceFile(
        'test.ts',
        input,
        ts.ScriptTarget.Latest,
        true
      );
      
      const result = ts.transform(sourceFile, [transformer]);
      const printer = ts.createPrinter();
      
      return printer.printFile(result.transformed[0]);
    }
    
    const input = `function test() { console.log("Hello"); }`;
    const output = testTransformer(input, myCustomTransformer);
    console.log(output);
    ```
    

### Performance Considerations

When writing custom transformers, performance is a critical consideration as they can significantly impact build times.

**Key Points**

- Transformers run during every compilation, affecting build performance
- Inefficient transformers can cause major slowdowns in large projects
- Caching and memoization techniques can improve performance
- Node visit strategies affect performance significantly

Performance optimization techniques:

1. Use node maps for caching:
    
    ```typescript
    function createTransformer(): ts.TransformerFactory<ts.SourceFile> {
      // Cache processed nodes
      const processedNodes = new Map<ts.Node, ts.Node>();
      
      return context => {
        return sourceFile => {
          // Visitor function with caching
          const visitor: ts.Visitor = (node: ts.Node): ts.Node => {
            // Check cache first
            if (processedNodes.has(node)) {
              return processedNodes.get(node)!;
            }
            
            // Process the node
            let result = node;
            if (shouldTransform(node)) {
              result = transformNode(node);
            }
            
            // Cache result
            processedNodes.set(node, result);
            return result;
          };
          
          return ts.visitEachChild(sourceFile, visitor, context);
        };
      };
    }
    ```
    
2. Skip unnecessary node traversals:
    
    ```typescript
    function visitor(node: ts.Node): ts.Node {
      // Early exit condition
      if (!affectsThisNodeType(node)) {
        return node;
      }
      
      // Only recurse when necessary
      if (mightContainRelevantNodes(node)) {
        return ts.visitEachChild(node, visitor, context);
      }
      
      return node;
    }
    ```
    
3. Use TypeScript's incremental API:
    
    ```typescript
    const host = ts.createIncrementalCompilerHost(compilerOptions);
    const program = ts.createIncrementalProgram({
      rootNames: ['./src/index.ts'],
      options: compilerOptions,
      host
    });
    
    // Use transformer with incremental program
    const emitResult = program.emit(
      undefined, 
      undefined, 
      undefined, 
      undefined, 
      { before: [myTransformer] }
    );
    ```
    
4. Profile transformer performance:
    
    ```typescript
    function createProfiledTransformer(
      transformer: ts.TransformerFactory<ts.SourceFile>
    ): ts.TransformerFactory<ts.SourceFile> {
      return context => {
        return sourceFile => {
          const start = process.hrtime.bigint();
          const result = transformer(context)(sourceFile);
          const end = process.hrtime.bigint();
          
          console.log(
            `Transformer execution time for ${sourceFile.fileName}: 
            ${Number(end - start) / 1000000}ms`
          );
          
          return result;
        };
      };
    }
    ```
    

### Type-Aware Transformations

TypeScript transformers can leverage the type system to make more intelligent code transformations.

**Key Points**

- Type-aware transformers have access to the full TypeScript type system
- They can make transformation decisions based on inferred types
- This enables more powerful and precise transformations
- Type checking ensures transformations maintain type safety

Implementing type-aware transformers:

```typescript
function createTypeAwareTransformer(program: ts.Program): ts.TransformerFactory<ts.SourceFile> {
  // Get the type checker from the program
  const typeChecker = program.getTypeChecker();
  
  return context => {
    return sourceFile => {
      const visitor: ts.Visitor = node => {
        // Example: Transform only function calls with string arguments
        if (ts.isCallExpression(node)) {
          const signature = typeChecker.getResolvedSignature(node);
          if (signature) {
            const paramTypes = signature.getParameters().map(param => 
              typeChecker.getTypeOfSymbolAtLocation(param, node)
            );
            
            // Check if the first parameter is a string type
            if (paramTypes.length > 0 && 
                typeChecker.typeToString(paramTypes[0]) === 'string') {
              // Transform the call expression
              return transformStringFunctionCall(node, context);
            }
          }
        }
        
        return ts.visitEachChild(node, visitor, context);
      };
      
      return ts.visitNode(sourceFile, visitor);
    };
  };
}

function transformStringFunctionCall(
  node: ts.CallExpression, 
  context: ts.TransformationContext
): ts.Expression {
  // Transformation logic here
  // For example, add string validation
  if (node.arguments.length > 0 && ts.isStringLiteralLike(node.arguments[0])) {
    // Create a validation wrapper
    const validateFn = ts.factory.createIdentifier('validateString');
    return ts.factory.createCallExpression(
      node.expression,
      node.typeArguments,
      [
        ts.factory.createCallExpression(
          validateFn,
          undefined,
          [node.arguments[0]]
        ),
        ...node.arguments.slice(1)
      ]
    );
  }
  
  return node;
}
```

### Error Handling in Transformers

Proper error handling in transformers ensures that compilation failures provide meaningful diagnostics rather than cryptic errors.

**Key Points**

- Transformer errors can be difficult to trace and debug
- Well-structured error handling improves developer experience
- TypeScript provides diagnostic reporting mechanisms
- Custom error handling can catch and report transformer-specific issues

Implementing robust error handling:

```typescript
function createTransformerWithErrorHandling(
  program: ts.Program
): ts.TransformerFactory<ts.SourceFile> {
  return context => {
    return sourceFile => {
      try {
        // Store original source file for error reporting
        const originalFileName = sourceFile.fileName;
        
        const visitor: ts.Visitor = node => {
          try {
            // Transformation logic that might throw
            if (shouldTransform(node)) {
              return transformNode(node);
            }
            
            return ts.visitEachChild(node, visitor, context);
          } catch (error) {
            // Create diagnostic info including node position
            const { line, character } = 
              sourceFile.getLineAndCharacterOfPosition(node.getStart());
            
            const diagnostic: ts.Diagnostic = {
              category: ts.DiagnosticCategory.Error,
              code: 9999, // Custom error code
              file: sourceFile,
              start: node.getStart(),
              length: node.getWidth(),
              messageText: `Transformer error: ${error.message} at ${line}:${character}`
            };
            
            // Report the diagnostic
            context.addDiagnostic(diagnostic);
            
            // Return original node to continue compilation
            return node;
          }
        };
        
        return ts.visitNode(sourceFile, visitor);
      } catch (error) {
        // Handle source file level errors
        console.error(`Fatal transformer error in ${sourceFile.fileName}: ${error.message}`);
        // Return original source file to continue compilation
        return sourceFile;
      }
    };
  };
}
```

### Custom Transformer Testing Strategies

Comprehensive testing strategies ensure transformers work correctly across different TypeScript versions and code patterns.

**Key Points**

- Testing transformers requires different approaches than regular code
- Unit tests should verify both the transformation result and preserved functionality
- Integration tests ensure transformers work with the build pipeline
- Testing against multiple TypeScript versions ensures compatibility

Testing approach examples:

1. Basic unit testing framework:

```typescript
import * as ts from 'typescript';
import * as assert from 'assert';

function testTransformer(
  transformer: ts.TransformerFactory<ts.SourceFile>,
  inputCode: string,
  expectedOutputCode: string
) {
  // Create a source file from input code
  const sourceFile = ts.createSourceFile(
    'test.ts',
    inputCode,
    ts.ScriptTarget.Latest,
    true
  );
  
  // Apply the transformer
  const result = ts.transform(sourceFile, [transformer]);
  const transformedSourceFile = result.transformed[0];
  
  // Print the result
  const printer = ts.createPrinter();
  const actual = printer.printFile(transformedSourceFile);
  
  // Normalize whitespace for comparison
  const normalizedActual = actual.replace(/\s+/g, ' ').trim();
  const normalizedExpected = expectedOutputCode.replace(/\s+/g, ' ').trim();
  
  // Assert equality
  assert.strictEqual(normalizedActual, normalizedExpected);
}

// Example test
testTransformer(
  myTransformer,
  `function hello() { return "world"; }`,
  `function hello() { console.log("Transformed"); return "world"; }`
);
```

2. Testing compiled output execution:

```typescript
function testTransformerExecution(
  transformer: ts.TransformerFactory<ts.SourceFile>,
  inputCode: string,
  expectedOutput: any
) {
  // Apply transformer
  const sourceFile = ts.createSourceFile(
    'test.ts',
    inputCode,
    ts.ScriptTarget.Latest,
    true
  );
  
  const result = ts.transform(sourceFile, [transformer]);
  const transformedSourceFile = result.transformed[0];
  
  // Print to JavaScript
  const printer = ts.createPrinter();
  const jsCode = printer.printFile(transformedSourceFile);
  
  // Execute the transformed code
  const executeResult = new Function(`
    ${jsCode}
    return test();
  `)();
  
  // Verify the execution result
  assert.deepStrictEqual(executeResult, expectedOutput);
}
```

3. Snapshot testing approach:

```typescript
import * as fs from 'fs';
import * as path from 'path';

function snapshotTest(
  transformer: ts.TransformerFactory<ts.SourceFile>,
  testName: string,
  inputCode: string
) {
  const sourceFile = ts.createSourceFile(
    'test.ts',
    inputCode,
    ts.ScriptTarget.Latest,
    true
  );
  
  const result = ts.transform(sourceFile, [transformer]);
  const printer = ts.createPrinter();
  const actual = printer.printFile(result.transformed[0]);
  
  const snapshotDir = path.join(__dirname, '__snapshots__');
  fs.mkdirSync(snapshotDir, { recursive: true });
  
  const snapshotPath = path.join(snapshotDir, `${testName}.snap`);
  
  if (process.env.UPDATE_SNAPSHOTS === 'true' || !fs.existsSync(snapshotPath)) {
    fs.writeFileSync(snapshotPath, actual, 'utf8');
    console.log(`Updated snapshot: ${testName}`);
  } else {
    const expected = fs.readFileSync(snapshotPath, 'utf8');
    assert.strictEqual(
      actual, 
      expected, 
      `Transformer output doesn't match snapshot for "${testName}"`
    );
    console.log(`Passed: ${testName}`);
  }
}
```

### Security Considerations

Custom transformers can introduce security risks if they're not carefully designed, especially when processing untrusted code.

**Key Points**

- Transformers can inject code, potentially introducing vulnerabilities
- Input validation is critical when transforming code
- Transformers should avoid executing untrusted code during compilation
- Access to certain APIs should be restricted in transformers

Security best practices:

1. Validate inputs:
    
    ```typescript
    function createSecureTransformer(): ts.TransformerFactory<ts.SourceFile> {
      return context => {
        return sourceFile => {
          // Validate source file before transformation
          if (!isValidSourceFile(sourceFile)) {
            // Log warning and return original to avoid transformation
            console.warn(`Skipping potentially unsafe file: ${sourceFile.fileName}`);
            return sourceFile;
          }
          
          return ts.visitNode(sourceFile, createSecureVisitor(context));
        };
      };
    }
    
    function isValidSourceFile(sourceFile: ts.SourceFile): boolean {
      // Implement validation logic
      const hasUnsafePattern = /eval\s*\(|Function\s*\(|new\s+Function\s*\(/g.test(
        sourceFile.getText()
      );
      
      return !hasUnsafePattern;
    }
    ```
    
2. Sanitize generated code:
    
    ```typescript
    function sanitizeExpression(expr: string): string {
      // Remove potential code execution patterns
      return expr
        .replace(/eval\s*\(/g, '/* sanitized */')
        .replace(/new\s+Function/g, '/* sanitized */');
    }
    
    function createSafeStringLiteral(text: string): ts.StringLiteral {
      return ts.factory.createStringLiteral(sanitizeExpression(text));
    }
    ```
    
3. Avoid dynamic code execution in transformers:
    
    ```typescript
    // UNSAFE - never do this in a transformer
    function unsafeTransformer() {
      return context => {
        return sourceFile => {
          // This is extremely dangerous!
          const dynamicConfig = eval(`(${sourceFile.getText()})`);
          
          // Rest of transformer...
        };
      };
    }
    
    // SAFE alternative
    function safeTransformer() {
      return context => {
        return sourceFile => {
          // Use static analysis instead of execution
          const configObject = findConfigObjectInSourceFile(sourceFile);
          
          // Rest of transformer...
        };
      };
    }
    ```
    

### Advanced Plugin Systems

Creating a plugin system for transformers allows for modular, configurable transformations that can be combined and shared.

**Key Points**

- Plugin systems allow composable transformers
- Configuration options can customize transformer behavior
- Plugin discovery mechanisms enable dynamic loading
- Well-designed APIs simplify transformer development

Example of a transformer plugin system:

```typescript
// Plugin interface
interface TransformerPlugin {
  name: string;
  version: string;
  factory: (config?: any) => ts.TransformerFactory<ts.SourceFile>;
}

// Plugin registry
class TransformerPluginRegistry {
  private plugins = new Map<string, TransformerPlugin>();
  
  register(plugin: TransformerPlugin): void {
    this.plugins.set(plugin.name, plugin);
  }
  
  getPlugin(name: string): TransformerPlugin | undefined {
    return this.plugins.get(name);
  }
  
  createTransformerFactories(config: {
    [pluginName: string]: any
  }): Array<ts.TransformerFactory<ts.SourceFile>> {
    const factories: Array<ts.TransformerFactory<ts.SourceFile>> = [];
    
    for (const [name, pluginConfig] of Object.entries(config)) {
      const plugin = this.getPlugin(name);
      if (plugin) {
        factories.push(plugin.factory(pluginConfig));
      } else {
        console.warn(`Plugin "${name}" not found, skipping`);
      }
    }
    
    return factories;
  }
}

// Plugin usage
const registry = new TransformerPluginRegistry();

// Register plugins
registry.register({
  name: 'logger',
  version: '1.0.0',
  factory: (config = {}) => createLoggerTransformer(config)
});

registry.register({
  name: 'autoImport',
  version: '1.0.0',
  factory: (config = {}) => createAutoImportTransformer(config)
});

// Create transformers from config
const transformers = registry.createTransformerFactories({
  logger: { level: 'debug' },
  autoImport: { imports: ['react', 'lodash'] }
});

// Use with TypeScript compiler
const program = ts.createProgram(['./src/index.ts'], compilerOptions);
const emitResult = program.emit(
  undefined, 
  undefined, 
  undefined, 
  undefined, 
  { before: transformers }
);
```

These additional sections complete the comprehensive overview of TypeScript Custom Transformations, providing deeper insights into advanced techniques, performance optimization, debugging strategies, and practical patterns for large-scale transformer development.

---

# TypeScript with Frameworks and Libraries

## TypeScript with React

### Understanding TypeScript in React

TypeScript provides static type checking for JavaScript, offering significant advantages when building React applications. By detecting errors during development rather than runtime, TypeScript helps create more robust and maintainable React code. It also enhances developer experience with improved autocompletion, documentation, and refactoring capabilities.

### Setting Up a TypeScript React Project

You can create a new TypeScript React project using Create React App:

```bash
npx create-react-app my-app --template typescript
```

For existing projects, you can add TypeScript by installing necessary dependencies:

```bash
npm install --save typescript @types/node @types/react @types/react-dom @types/jest
```

Then create a `tsconfig.json` file in your project root with appropriate configuration:

```json
{
  "compilerOptions": {
    "target": "es5",
    "lib": ["dom", "dom.iterable", "esnext"],
    "allowJs": true,
    "skipLibCheck": true,
    "esModuleInterop": true,
    "allowSyntheticDefaultImports": true,
    "strict": true,
    "forceConsistentCasingInFileNames": true,
    "noFallthroughCasesInSwitch": true,
    "module": "esnext",
    "moduleResolution": "node",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "noEmit": true,
    "jsx": "react-jsx"
  },
  "include": ["src"]
}
```

### React Component Types

TypeScript offers multiple ways to define React components with proper typing.

#### Function Components

The most common approach is using function components with explicit typing:

```tsx
import React from 'react';

// Using React.FC (Function Component) type
const Greeting: React.FC<{ name: string }> = ({ name }) => {
  return <h1>Hello, {name}!</h1>;
};

// Or with explicit parameter typing
const GreetingAlt = ({ name }: { name: string }) => {
  return <h1>Hello, {name}!</h1>;
};
```

While `React.FC` was once popular, the current best practice is to avoid it because:

- It implicitly includes children in props even when not needed
- It doesn't work well with generic components
- It complicates component default props

#### Class Components

Although less common in modern React, class components can be typed with TypeScript:

```tsx
import React, { Component } from 'react';

interface GreetingProps {
  name: string;
}

interface GreetingState {
  count: number;
}

class Greeting extends Component<GreetingProps, GreetingState> {
  state = {
    count: 0
  };

  render() {
    return (
      <div>
        <h1>Hello, {this.props.name}!</h1>
        <p>You clicked {this.state.count} times</p>
        <button onClick={() => this.setState({ count: this.state.count + 1 })}>
          Click me
        </button>
      </div>
    );
  }
}
```

#### Higher Order Components

When creating Higher Order Components (HOCs), utilize generics for type safety:

```tsx
import React from 'react';

// HOC that adds a "theme" prop
function withTheme<T extends object>(Component: React.ComponentType<T & { theme: string }>) {
  return (props: T) => {
    const theme = "dark"; // Would normally come from context
    return <Component {...props} theme={theme} />;
  };
}

// Usage
const ThemedButton = withTheme(({ theme, label }: { theme: string; label: string }) => {
  return <button className={`btn-${theme}`}>{label}</button>;
});

// Now we can use ThemedButton without passing "theme"
<ThemedButton label="Click Me" />; // Type safe!
```

### Props and State Typing

#### Typing Props

Defining prop types with interfaces provides clear contracts for components:

```tsx
// Using interface for props definition
interface UserCardProps {
  name: string;
  email: string;
  age?: number; // Optional prop
  isAdmin: boolean;
  status: 'active' | 'suspended' | 'pending'; // Union type
  roles: string[];
  onProfileClick: (userId: string) => void; // Function prop
}

const UserCard = (props: UserCardProps) => {
  const { name, email, age, isAdmin, status, roles, onProfileClick } = props;
  
  return (
    <div className="user-card">
      <h3>{name} {isAdmin && '(Admin)'}</h3>
      <p>Email: {email}</p>
      {age && <p>Age: {age}</p>}
      <p>Status: {status}</p>
      <p>Roles: {roles.join(', ')}</p>
      <button onClick={() => onProfileClick(name)}>View Profile</button>
    </div>
  );
};
```

#### Default Props

Best practices for default props in TypeScript React:

```tsx
interface ButtonProps {
  label: string;
  primary?: boolean;
  disabled?: boolean;
  size?: 'small' | 'medium' | 'large';
}

const Button = ({
  label, 
  primary = false, 
  disabled = false, 
  size = 'medium'
}: ButtonProps) => {
  // Implementation using defaults
  return (
    <button 
      className={`btn-${size} ${primary ? 'btn-primary' : 'btn-secondary'}`}
      disabled={disabled}
    >
      {label}
    </button>
  );
};
```

#### Children Props

Type the children prop using React's built-in types:

```tsx
import React, { ReactNode } from 'react';

interface CardProps {
  title: string;
  children: ReactNode; // Can accept any valid JSX
}

const Card = ({ title, children }: CardProps) => {
  return (
    <div className="card">
      <h2>{title}</h2>
      <div className="card-content">
        {children}
      </div>
    </div>
  );
};

// Usage
<Card title="User Information">
  <p>This is the card content.</p>
  <button>Action</button>
</Card>
```

#### State Typing

In class components, state is typed in the component definition. For hooks, types are inferred or explicitly declared:

```tsx
import React, { useState } from 'react';

// State with type inference
const Counter = () => {
  const [count, setCount] = useState(0); // TypeScript infers number type
  
  return (
    <div>
      <p>Count: {count}</p>
      <button onClick={() => setCount(count + 1)}>Increment</button>
    </div>
  );
};

// Explicit state typing
interface User {
  id: number;
  name: string;
  isActive: boolean;
}

const UserProfile = () => {
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(false);

  const fetchUser = (id: number) => {
    setLoading(true);
    // Mock API call
    setTimeout(() => {
      setUser({
        id,
        name: 'John Doe',
        isActive: true
      });
      setLoading(false);
    }, 1000);
  };

  return (
    <div>
      {loading && <p>Loading...</p>}
      {user && (
        <div>
          <h2>{user.name}</h2>
          <p>ID: {user.id}</p>
          <p>Status: {user.isActive ? 'Active' : 'Inactive'}</p>
        </div>
      )}
      {!loading && !user && (
        <button onClick={() => fetchUser(1)}>Load User</button>
      )}
    </div>
  );
};
```

### Hooks with TypeScript

TypeScript enhances React hooks with strong typing, making them more predictable and safer to use.

#### useState

```tsx
// Basic usage with type inference
const [name, setName] = useState('');

// Explicit type definition
const [user, setUser] = useState<User | null>(null);

// For complex state with union types
type Status = 'idle' | 'loading' | 'success' | 'error';
const [status, setStatus] = useState<Status>('idle');

// For array state
const [items, setItems] = useState<string[]>([]);
```

#### useEffect

For `useEffect`, TypeScript ensures correct dependency types:

```tsx
const UserData = ({ userId }: { userId: string }) => {
  const [user, setUser] = useState<User | null>(null);
  
  useEffect(() => {
    // TypeScript ensures userId is a string
    const fetchUser = async () => {
      const response = await fetch(`/api/users/${userId}`);
      const data = await response.json();
      setUser(data);
    };
    
    fetchUser();
  }, [userId]); // Dependency correctly typed
  
  return user ? <div>{user.name}</div> : <div>Loading...</div>;
};
```

#### useReducer

TypeScript makes complex state management with reducers safer:

```tsx
type State = {
  count: number;
  isLoading: boolean;
  error: string | null;
};

// Discriminated union for action types
type Action = 
  | { type: 'INCREMENT'; payload: number }
  | { type: 'DECREMENT'; payload: number }
  | { type: 'RESET' }
  | { type: 'SET_LOADING'; payload: boolean }
  | { type: 'SET_ERROR'; payload: string };

const initialState: State = {
  count: 0,
  isLoading: false,
  error: null
};

function reducer(state: State, action: Action): State {
  switch (action.type) {
    case 'INCREMENT':
      return { ...state, count: state.count + action.payload };
    case 'DECREMENT':
      return { ...state, count: state.count - action.payload };
    case 'RESET':
      return { ...state, count: 0 };
    case 'SET_LOADING':
      return { ...state, isLoading: action.payload };
    case 'SET_ERROR':
      return { ...state, error: action.payload };
    default:
      // TypeScript ensures exhaustive check of all action types
      const _exhaustiveCheck: never = action;
      return state;
  }
}

function CounterWithReducer() {
  const [state, dispatch] = useReducer(reducer, initialState);

  return (
    <div>
      <p>Count: {state.count}</p>
      {state.isLoading && <p>Loading...</p>}
      {state.error && <p>Error: {state.error}</p>}
      <button onClick={() => dispatch({ type: 'INCREMENT', payload: 1 })}>
        Increment
      </button>
      <button onClick={() => dispatch({ type: 'DECREMENT', payload: 1 })}>
        Decrement
      </button>
      <button onClick={() => dispatch({ type: 'RESET' })}>
        Reset
      </button>
    </div>
  );
}
```

#### useRef

Type annotations for refs ensure correct DOM element access:

```tsx
import React, { useRef, useEffect } from 'react';

const InputFocus = () => {
  // For DOM elements
  const inputRef = useRef<HTMLInputElement>(null);
  
  // For mutable values that don't trigger re-renders
  const prevCountRef = useRef<number>(0);
  
  useEffect(() => {
    // Safe because we check if inputRef.current exists
    if (inputRef.current) {
      inputRef.current.focus();
    }
  }, []);
  
  return <input ref={inputRef} type="text" />;
};
```

#### useCallback and useMemo

Proper typing helps ensure correct parameter and return types:

```tsx
import React, { useState, useCallback, useMemo } from 'react';

interface Item {
  id: number;
  name: string;
}

const ItemList = () => {
  const [items, setItems] = useState<Item[]>([]);
  const [filter, setFilter] = useState('');
  
  // Type-safe callback function
  const handleAddItem = useCallback((name: string) => {
    const newItem: Item = {
      id: Date.now(),
      name
    };
    setItems(prev => [...prev, newItem]);
  }, []);
  
  // Type-safe memoized value
  const filteredItems = useMemo(() => {
    return items.filter(item => 
      item.name.toLowerCase().includes(filter.toLowerCase())
    );
  }, [items, filter]);
  
  return (
    <div>
      <input 
        value={filter} 
        onChange={(e) => setFilter(e.target.value)} 
        placeholder="Filter items" 
      />
      <button onClick={() => handleAddItem('New Item')}>Add Item</button>
      <ul>
        {filteredItems.map(item => (
          <li key={item.id}>{item.name}</li>
        ))}
      </ul>
    </div>
  );
};
```

#### Custom Hooks

TypeScript shines with custom hooks by enabling reusable, type-safe abstractions:

```tsx
import { useState, useEffect } from 'react';

// Custom hook with proper TypeScript typing
function useLocalStorage<T>(key: string, initialValue: T): [T, (value: T) => void] {
  // State to store our value
  const [storedValue, setStoredValue] = useState<T>(() => {
    try {
      // Get from local storage by key
      const item = window.localStorage.getItem(key);
      // Parse stored json or if none return initialValue
      return item ? JSON.parse(item) : initialValue;
    } catch (error) {
      // If error also return initialValue
      console.log(error);
      return initialValue;
    }
  });

  // Return a wrapped version of useState's setter function
  const setValue = (value: T) => {
    try {
      // Allow value to be a function so we have same API as useState
      const valueToStore =
        value instanceof Function ? value(storedValue) : value;
      // Save state
      setStoredValue(valueToStore);
      // Save to local storage
      window.localStorage.setItem(key, JSON.stringify(valueToStore));
    } catch (error) {
      console.log(error);
    }
  };

  return [storedValue, setValue];
}

// Usage
const UserSettings = () => {
  // Strong typing ensures theme can only be 'light' or 'dark'
  const [theme, setTheme] = useLocalStorage<'light' | 'dark'>('theme', 'light');
  
  return (
    <div>
      <p>Current theme: {theme}</p>
      <button onClick={() => setTheme(theme === 'light' ? 'dark' : 'light')}>
        Toggle Theme
      </button>
    </div>
  );
};
```

### Context API Typing

Context API in TypeScript requires proper typing for both the context value and provider.

#### Creating Typed Context

```tsx
import React, { createContext, useContext, useState, ReactNode } from 'react';

// Define the shape of context data
interface ThemeContextType {
  theme: 'light' | 'dark';
  toggleTheme: () => void;
}

// Create context with a default value
const ThemeContext = createContext<ThemeContextType | undefined>(undefined);

// Provider component with typed props
interface ThemeProviderProps {
  children: ReactNode;
  initialTheme?: 'light' | 'dark';
}

export const ThemeProvider = ({ 
  children, 
  initialTheme = 'light' 
}: ThemeProviderProps) => {
  const [theme, setTheme] = useState<'light' | 'dark'>(initialTheme);

  const toggleTheme = () => {
    setTheme(prevTheme => (prevTheme === 'light' ? 'dark' : 'light'));
  };

  // The value passed to the provider is type-checked
  const value: ThemeContextType = {
    theme,
    toggleTheme
  };

  return (
    <ThemeContext.Provider value={value}>
      {children}
    </ThemeContext.Provider>
  );
};

// Custom hook for using the theme context
export const useTheme = (): ThemeContextType => {
  const context = useContext(ThemeContext);
  if (context === undefined) {
    throw new Error('useTheme must be used within a ThemeProvider');
  }
  return context;
};
```

#### Using Typed Context

```tsx
// App.tsx
import React from 'react';
import { ThemeProvider } from './ThemeContext';
import ThemedButton from './ThemedButton';

const App = () => {
  return (
    <ThemeProvider initialTheme="light">
      <div className="app">
        <h1>Themed App</h1>
        <ThemedButton />
      </div>
    </ThemeProvider>
  );
};

// ThemedButton.tsx
import React from 'react';
import { useTheme } from './ThemeContext';

const ThemedButton = () => {
  const { theme, toggleTheme } = useTheme();
  
  return (
    <button 
      onClick={toggleTheme}
      className={`btn btn-${theme}`}
    >
      Current theme: {theme}. Click to toggle!
    </button>
  );
};
```

#### Complex Context with Multiple Values

For more complex applications, you can create separate contexts or combine them:

```tsx
import React, { createContext, useContext, useReducer, ReactNode } from 'react';

// User-related types
interface User {
  id: string;
  name: string;
  email: string;
}

type AuthState = {
  user: User | null;
  isAuthenticated: boolean;
  isLoading: boolean;
  error: string | null;
};

type AuthAction =
  | { type: 'LOGIN_START' }
  | { type: 'LOGIN_SUCCESS'; payload: User }
  | { type: 'LOGIN_FAILURE'; payload: string }
  | { type: 'LOGOUT' };

interface AuthContextType {
  state: AuthState;
  login: (email: string, password: string) => Promise<void>;
  logout: () => void;
}

// Create the context
const AuthContext = createContext<AuthContextType | undefined>(undefined);

// Initial state
const initialState: AuthState = {
  user: null,
  isAuthenticated: false,
  isLoading: false,
  error: null
};

// Reducer function
function authReducer(state: AuthState, action: AuthAction): AuthState {
  switch (action.type) {
    case 'LOGIN_START':
      return { ...state, isLoading: true, error: null };
    case 'LOGIN_SUCCESS':
      return { 
        ...state, 
        isLoading: false, 
        isAuthenticated: true, 
        user: action.payload 
      };
    case 'LOGIN_FAILURE':
      return { 
        ...state, 
        isLoading: false, 
        error: action.payload 
      };
    case 'LOGOUT':
      return initialState;
    default:
      return state;
  }
}

// Provider component
interface AuthProviderProps {
  children: ReactNode;
}

export const AuthProvider = ({ children }: AuthProviderProps) => {
  const [state, dispatch] = useReducer(authReducer, initialState);

  // Login function
  const login = async (email: string, password: string) => {
    try {
      dispatch({ type: 'LOGIN_START' });
      
      // Simulated API call
      const response = await new Promise<User>((resolve) => {
        setTimeout(() => {
          resolve({
            id: '123',
            name: 'John Doe',
            email
          });
        }, 1000);
      });
      
      dispatch({ type: 'LOGIN_SUCCESS', payload: response });
    } catch (error) {
      dispatch({ 
        type: 'LOGIN_FAILURE', 
        payload: error instanceof Error ? error.message : 'Unknown error' 
      });
    }
  };

  // Logout function
  const logout = () => {
    dispatch({ type: 'LOGOUT' });
  };

  const value = {
    state,
    login,
    logout
  };

  return (
    <AuthContext.Provider value={value}>
      {children}
    </AuthContext.Provider>
  );
};

// Custom hook
export const useAuth = (): AuthContextType => {
  const context = useContext(AuthContext);
  if (context === undefined) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
};
```

#### Using Multiple Contexts Together

```tsx
// App.tsx
import React from 'react';
import { ThemeProvider } from './ThemeContext';
import { AuthProvider } from './AuthContext';
import Dashboard from './Dashboard';

const App = () => {
  return (
    <AuthProvider>
      <ThemeProvider>
        <Dashboard />
      </ThemeProvider>
    </AuthProvider>
  );
};

// Dashboard.tsx
import React from 'react';
import { useAuth } from './AuthContext';
import { useTheme } from './ThemeContext';
import LoginForm from './LoginForm';
import UserProfile from './UserProfile';

const Dashboard = () => {
  const { state } = useAuth();
  const { theme } = useTheme();
  
  return (
    <div className={`dashboard dashboard-${theme}`}>
      <h1>Application Dashboard</h1>
      {state.isAuthenticated ? <UserProfile /> : <LoginForm />}
    </div>
  );
};
```

### Advanced TypeScript Features for React

#### Generic Components

Generic components provide flexibility while maintaining type safety:

```tsx
import React from 'react';

// Generic component that can display any data type
interface DataDisplayProps<T> {
  data: T;
  renderItem: (item: T) => React.ReactNode;
  fallback?: React.ReactNode;
}

function DataDisplay<T>({ 
  data, 
  renderItem, 
  fallback = <p>No data available</p> 
}: DataDisplayProps<T>) {
  if (!data) {
    return <>{fallback}</>;
  }
  
  return <>{renderItem(data)}</>;
}

// Usage
const UserDisplay = () => {
  const user = { id: 1, name: 'Alice', role: 'Admin' };
  
  return (
    <DataDisplay
      data={user}
      renderItem={(user) => (
        <div>
          <h3>{user.name}</h3>
          <p>Role: {user.role}</p>
        </div>
      )}
    />
  );
};

const NumberDisplay = () => {
  const count = 42;
  
  return (
    <DataDisplay
      data={count}
      renderItem={(num) => <span>The answer is {num}</span>}
      fallback={<span>No number provided</span>}
    />
  );
};
```

#### Type Guards with React

Type guards help narrow types in conditional rendering:

```tsx
type ResponseStatus = 'loading' | 'success' | 'error';

interface BaseState {
  status: ResponseStatus;
}

interface LoadingState extends BaseState {
  status: 'loading';
}

interface SuccessState extends BaseState {
  status: 'success';
  data: { id: string; name: string }[];
}

interface ErrorState extends BaseState {
  status: 'error';
  error: string;
}

type State = LoadingState | SuccessState | ErrorState;

// Type guard functions
function isLoading(state: State): state is LoadingState {
  return state.status === 'loading';
}

function isSuccess(state: State): state is SuccessState {
  return state.status === 'success';
}

function isError(state: State): state is ErrorState {
  return state.status === 'error';
}

// Component using type guards for conditional rendering
const DataFetcher = () => {
  const [state, setState] = useState<State>({ status: 'loading' });
  
  useEffect(() => {
    const fetchData = async () => {
      try {
        // Simulated API call
        const response = await fetch('/api/data');
        if (!response.ok) throw new Error('Failed to fetch');
        
        const data = await response.json();
        setState({ status: 'success', data });
      } catch (error) {
        setState({ 
          status: 'error', 
          error: error instanceof Error ? error.message : 'Unknown error' 
        });
      }
    };
    
    fetchData();
  }, []);
  
  // Conditional rendering with type narrowing
  if (isLoading(state)) {
    return <div>Loading...</div>;
  }
  
  if (isError(state)) {
    return <div>Error: {state.error}</div>;
  }
  
  if (isSuccess(state)) {
    return (
      <ul>
        {state.data.map(item => (
          <li key={item.id}>{item.name}</li>
        ))}
      </ul>
    );
  }
  
  // TypeScript can detect if you've handled all possible states
  // This line should be unreachable if all states are handled above
  const _exhaustiveCheck: never = state;
  return null;
};
```

### Event Handling with TypeScript

Properly typed event handlers improve safety and developer experience:

```tsx
import React, { ChangeEvent, FormEvent, MouseEvent, KeyboardEvent } from 'react';

interface LoginFormData {
  email: string;
  password: string;
}

const LoginForm = () => {
  const [formData, setFormData] = useState<LoginFormData>({
    email: '',
    password: ''
  });
  
  // Typed change event handler
  const handleChange = (e: ChangeEvent<HTMLInputElement>) => {
    const { name, value } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: value
    }));
  };
  
  // Typed submit event handler
  const handleSubmit = (e: FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    console.log('Form submitted:', formData);
  };
  
  // Typed click event handler
  const handleButtonClick = (e: MouseEvent<HTMLButtonElement>) => {
    console.log('Button clicked at:', e.clientX, e.clientY);
  };
  
  // Typed keyboard event handler
  const handleKeyPress = (e: KeyboardEvent<HTMLInputElement>) => {
    if (e.key === 'Enter') {
      console.log('Enter pressed in input');
    }
  };
  
  return (
    <form onSubmit={handleSubmit}>
      <div>
        <label htmlFor="email">Email:</label>
        <input
          type="email"
          id="email"
          name="email"
          value={formData.email}
          onChange={handleChange}
          onKeyPress={handleKeyPress}
          required
        />
      </div>
      <div>
        <label htmlFor="password">Password:</label>
        <input
          type="password"
          id="password"
          name="password"
          value={formData.password}
          onChange={handleChange}
          required
        />
      </div>
      <button type="submit" onClick={handleButtonClick}>
        Login
      </button>
    </form>
  );
};
```

### Utility Types for React Development

TypeScript provides useful utility types that can simplify React development:

```tsx
// Partial: Makes all properties optional
type PartialUser = Partial<User>;
// Useful for updates where only some properties change

// Required: Makes all properties required
type RequiredUser = Required<User>;
// Useful when ensuring all fields are provided

// Pick: Select specific properties
type UserCredentials = Pick<User, 'email' | 'password'>;
// Creates a type with only email and password from User

// Omit: Remove specific properties
type PublicUser = Omit<User, 'password' | 'token'>;
// Creates a type with all User properties except password and token

// Record: Create a dictionary type
type UserRoles = Record<string, string[]>;
// Creates a type with string keys and string[] values

// Example usage within React components
interface User {
  id: string;
  name: string;
  email: string;
  password: string;
  role: string;
  token?: string;
}

interface UpdateUserFormProps {
  user: User;
  onSave: (updatedUser: Partial<User>) => void;
}

const UpdateUserForm = ({ user, onSave }: UpdateUserFormProps) => {
  const [formData, setFormData] = useState<Partial<User>>({
    name: user.name,
    email: user.email
  });
  
  const handleSubmit = (e: FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    onSave(formData);
  };
  
  // Form implementation...
  return <form onSubmit={handleSubmit}>...</form>;
};

// Public profile component omitting sensitive data
const UserProfile = ({ user }: { user: User }) => {
  // Extract only public information
  const publicInfo: PublicUser = {
    id: user.id,
    name: user.name,
    email: user.email,
    role: user.role
  };
  
  return (
    <div>
      <h2>{publicInfo.name}</h2>
      <p>Email: {publicInfo.email}</p>
      <p>Role: {publicInfo.role}</p>
    </div>
  );
};
```

### Performance Optimization with TypeScript

TypeScript not only provides type safety for React applications but can also be leveraged to optimize performance. Using TypeScript effectively can help identify and resolve performance bottlenecks at compile time rather than at runtime.

#### Memoization with TypeScript

Memoization is a performance optimization technique that prevents unnecessary re-renders by caching results of expensive calculations or component renders.

```typescript
import React, { useMemo, useCallback, memo } from 'react';

// Strongly typed props with required and optional properties
interface ListItemProps {
  item: {
    id: number;
    title: string;
    description: string;
  };
  onSelect: (id: number) => void;
  isSelected?: boolean;
}

// Memoized component with properly typed props
const ListItem = memo(({ item, onSelect, isSelected = false }: ListItemProps) => {
  // Component logic
  console.log(`Rendering ListItem ${item.id}`);
  
  return (
    <div 
      className={`list-item ${isSelected ? 'selected' : ''}`}
      onClick={() => onSelect(item.id)}
    >
      <h3>{item.title}</h3>
      <p>{item.description}</p>
    </div>
  );
});

// Parent component with memoized callbacks and values
const ItemList: React.FC<{ items: Array<ListItemProps['item']> }> = ({ items }) => {
  const [selectedId, setSelectedId] = React.useState<number | null>(null);
  
  // Memoized callback with correct type
  const handleSelect = useCallback((id: number) => {
    setSelectedId(id);
  }, []);
  
  // Memoized expensive calculation with correct return type
  const processedItems = useMemo<Array<ListItemProps['item']>>(() => {
    console.log('Processing items');
    return items.map(item => ({
      ...item,
      title: item.title.toUpperCase()
    }));
  }, [items]);
  
  return (
    <div className="list-container">
      {processedItems.map(item => (
        <ListItem
          key={item.id}
          item={item}
          onSelect={handleSelect}
          isSelected={item.id === selectedId}
        />
      ))}
    </div>
  );
};
```

#### Type-Safe Lazy Loading

Type safety can be maintained while implementing lazy loading for components:

```typescript
import React, { Suspense, lazy, ComponentType } from 'react';

// Type-safe lazy loading
const LazyComponent = lazy<ComponentType<{ title: string }>>(
  () => import('./HeavyComponent')
);

interface AppProps {
  showHeavyComponent: boolean;
}

const App: React.FC<AppProps> = ({ showHeavyComponent }) => {
  return (
    <div>
      <h1>My App</h1>
      {showHeavyComponent && (
        <Suspense fallback={<div>Loading...</div>}>
          <LazyComponent title="Lazy Loaded Component" />
        </Suspense>
      )}
    </div>
  );
};
```

#### Optimizing Re-renders with TypeScript Discriminated Unions

TypeScript's discriminated unions can help optimize conditional rendering:

```typescript
// Discriminated union for component state
type ViewState = 
  | { status: 'loading' }
  | { status: 'error'; error: Error }
  | { status: 'success'; data: User[] };

interface User {
  id: string;
  name: string;
  email: string;
}

const UserDashboard: React.FC = () => {
  const [state, setState] = React.useState<ViewState>({ status: 'loading' });
  
  React.useEffect(() => {
    fetchUsers()
      .then(users => setState({ status: 'success', data: users }))
      .catch(error => setState({ status: 'error', error }));
  }, []);
  
  // Optimized rendering based on state type
  switch (state.status) {
    case 'loading':
      return <LoadingSpinner />;
    case 'error':
      return <ErrorMessage message={state.error.message} />;
    case 'success':
      return <UserList users={state.data} />;
  }
};
```

#### Virtual List Optimization with TypeScript

TypeScript helps create type-safe virtual list implementations:

```typescript
import React from 'react';

interface VirtualListProps<T> {
  items: T[];
  height: number;
  itemHeight: number;
  renderItem: (item: T, index: number) => React.ReactNode;
  keyExtractor: (item: T, index: number) => string;
}

function VirtualList<T>({
  items,
  height,
  itemHeight,
  renderItem,
  keyExtractor
}: VirtualListProps<T>) {
  const [scrollTop, setScrollTop] = React.useState(0);
  
  // Calculate which items should be visible
  const startIndex = Math.max(0, Math.floor(scrollTop / itemHeight));
  const endIndex = Math.min(items.length - 1, Math.floor((scrollTop + height) / itemHeight));
  
  const visibleItems = items.slice(startIndex, endIndex + 1);
  const totalHeight = items.length * itemHeight;
  
  const handleScroll = (e: React.UIEvent<HTMLDivElement>) => {
    setScrollTop(e.currentTarget.scrollTop);
  };
  
  return (
    <div
      style={{ height, overflow: 'auto' }}
      onScroll={handleScroll}
    >
      <div style={{ height: totalHeight, position: 'relative' }}>
        {visibleItems.map((item, relativeIndex) => {
          const absoluteIndex = startIndex + relativeIndex;
          return (
            <div
              key={keyExtractor(item, absoluteIndex)}
              style={{
                position: 'absolute',
                top: absoluteIndex * itemHeight,
                height: itemHeight,
                width: '100%'
              }}
            >
              {renderItem(item, absoluteIndex)}
            </div>
          );
        })}
      </div>
    </div>
  );
}

// Usage with strong typing
interface User {
  id: string;
  name: string;
  email: string;
}

const UserList: React.FC<{ users: User[] }> = ({ users }) => {
  return (
    <VirtualList<User>
      items={users}
      height={400}
      itemHeight={50}
      keyExtractor={(user) => user.id}
      renderItem={(user) => (
        <div className="user-item">
          <strong>{user.name}</strong>
          <div>{user.email}</div>
        </div>
      )}
    />
  );
};
```

#### Optimizing Component Props with TypeScript

Type-checking can identify unnecessary prop changes that might trigger re-renders:

```typescript
import React, { memo } from 'react';

// Props interface with strict typing
interface UserCardProps {
  user: {
    id: string;
    name: string;
    email: string;
    role: 'admin' | 'user' | 'guest';
  };
  onUserUpdate: (id: string, updates: Partial<Omit<UserCardProps['user'], 'id'>>) => void;
}

// Custom equality function with type safety
function areEqual(prevProps: UserCardProps, nextProps: UserCardProps): boolean {
  return (
    prevProps.user.id === nextProps.user.id &&
    prevProps.user.name === nextProps.user.name &&
    prevProps.user.email === nextProps.user.email &&
    prevProps.user.role === nextProps.user.role &&
    prevProps.onUserUpdate === nextProps.onUserUpdate
  );
}

// Memoized component with custom equality check
const UserCard = memo<UserCardProps>(({ user, onUserUpdate }) => {
  const handleNameChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    onUserUpdate(user.id, { name: e.target.value });
  };

  return (
    <div className="user-card">
      <h3>{user.name}</h3>
      <p>{user.email}</p>
      <span className="badge">{user.role}</span>
      <input
        type="text"
        value={user.name}
        onChange={handleNameChange}
        className="name-input"
      />
    </div>
  );
}, areEqual);
```

#### Reducing Bundle Size with Type-Only Imports

TypeScript allows type-only imports that don't add to your runtime bundle:

```typescript
// Regular import (adds to bundle)
import { SomeComponent } from './components';

// Type-only import (doesn't add to bundle)
import type { SomeComponentProps } from './components';

// Mixed imports
import { SomeComponent, type SomeComponentProps } from './components';

// Type-safe component that doesn't bloat your bundle
const MyComponent: React.FC<SomeComponentProps> = (props) => {
  return <SomeComponent {...props} extraProp={true} />;
};
```

#### Using const Assertions for Performance

Const assertions can help optimize React performance by allowing TypeScript to infer the narrowest type possible:

```typescript
// Without const assertion - type is { type: string, payload: string }
const regularAction = { type: 'USER_LOGGED_IN', payload: 'user123' };

// With const assertion - type is { type: 'USER_LOGGED_IN', payload: 'user123' }
const specificAction = { type: 'USER_LOGGED_IN', payload: 'user123' } as const;

// This allows for more specific type checking in reducer functions
type UserAction = typeof specificAction;

function userReducer(state: UserState, action: UserAction) {
  // TypeScript knows action.type is exactly 'USER_LOGGED_IN'
  // No need for string comparison
  switch (action.type) {
    case 'USER_LOGGED_IN':
      return { ...state, currentUser: action.payload, isLoggedIn: true };
    default:
      return state;
  }
}
```

#### Typed Webpack Code Splitting

TypeScript can help maintain type safety with code splitting:

```typescript
// Strongly typed dynamic imports
interface DynamicComponentProps {
  name: string;
}

// Returns a properly typed promise
const loadDynamicComponent = (): Promise<React.ComponentType<DynamicComponentProps>> => {
  return import('./DynamicComponent').then(module => module.default);
};

const DynamicComponentLoader: React.FC = () => {
  const [Component, setComponent] = React.useState<React.ComponentType<DynamicComponentProps> | null>(null);
  const [loading, setLoading] = React.useState(true);
  
  React.useEffect(() => {
    let mounted = true;
    
    loadDynamicComponent().then(LoadedComponent => {
      if (mounted) {
        setComponent(() => LoadedComponent);
        setLoading(false);
      }
    });
    
    return () => { mounted = false };
  }, []);
  
  if (loading) return <div>Loading...</div>;
  if (!Component) return <div>Failed to load component</div>;
  
  // Type-safe rendering of dynamically loaded component
  return <Component name="Dynamic Content" />;
};
```

### Testing React Components with TypeScript

TypeScript enhances testing by providing type checking for test cases and mocks, reducing runtime errors and improving test reliability.

#### Unit Testing Components with Jest and TypeScript

```typescript
import React from 'react';
import { render, screen, fireEvent } from '@testing-library/react';
import { Counter } from './Counter';

// Type definition for component props
interface CounterProps {
  initialCount?: number;
  step?: number;
  onCountChange?: (count: number) => void;
}

describe('Counter Component', () => {
  const renderCounter = (props: Partial<CounterProps> = {}) => {
    const defaultProps: CounterProps = {
      initialCount: 0,
      step: 1,
      onCountChange: jest.fn(),
    };
    return render(<Counter {...defaultProps} {...props} />);
  };

  it('should render with initial count', () => {
    renderCounter({ initialCount: 5 });
    expect(screen.getByText('Count: 5')).toBeInTheDocument();
  });

  it('should increment counter when increment button is clicked', () => {
    const onCountChange = jest.fn();
    renderCounter({ onCountChange });
    
    fireEvent.click(screen.getByText('+'));
    expect(screen.getByText('Count: 1')).toBeInTheDocument();
    expect(onCountChange).toHaveBeenCalledWith(1);
  });

  it('should use custom step value', () => {
    renderCounter({ step: 5 });
    
    fireEvent.click(screen.getByText('+'));
    expect(screen.getByText('Count: 5')).toBeInTheDocument();
  });
});
```

#### Type-Safe Component Mocking

```typescript
import React from 'react';
import { render, screen } from '@testing-library/react';
import { UserProfile } from './UserProfile';
import { UserService } from '../services/UserService';

// Mock the service with TypeScript
jest.mock('../services/UserService');

// Type the mocked service
const MockedUserService = UserService as jest.MockedClass<typeof UserService>;

describe('UserProfile Component', () => {
  beforeEach(() => {
    // Reset all mocks
    MockedUserService.mockClear();
    
    // Setup the mock implementation with correct types
    MockedUserService.prototype.getUserProfile.mockResolvedValue({
      id: '123',
      name: 'Test User',
      email: 'test@example.com',
      role: 'user'
    });
  });

  it('should fetch and display user profile', async () => {
    render(<UserProfile userId="123" />);
    
    // Verify loading state
    expect(screen.getByText('Loading...')).toBeInTheDocument();
    
    // Wait for the user data to load
    const userName = await screen.findByText('Test User');
    expect(userName).toBeInTheDocument();
    expect(screen.getByText('test@example.com')).toBeInTheDocument();
    
    // Verify service was called correctly
    expect(MockedUserService.prototype.getUserProfile).toHaveBeenCalledWith('123');
  });
});
```

### Scalable State Management with TypeScript

Type-safe state management is crucial for large React applications, and TypeScript helps ensure consistency and prevent errors.

#### Type-Safe Redux with TypeScript

```typescript
// Action types as string literals
const ADD_TODO = 'ADD_TODO';
const TOGGLE_TODO = 'TOGGLE_TODO';
const SET_VISIBILITY_FILTER = 'SET_VISIBILITY_FILTER';

// Type definitions
interface Todo {
  id: number;
  text: string;
  completed: boolean;
}

type VisibilityFilter = 'SHOW_ALL' | 'SHOW_COMPLETED' | 'SHOW_ACTIVE';

// Action interfaces
interface AddTodoAction {
  type: typeof ADD_TODO;
  payload: {
    text: string;
  };
}

interface ToggleTodoAction {
  type: typeof TOGGLE_TODO;
  payload: {
    id: number;
  };
}

interface SetVisibilityFilterAction {
  type: typeof SET_VISIBILITY_FILTER;
  payload: {
    filter: VisibilityFilter;
  };
}

// Union type for all actions
type TodoActionTypes = AddTodoAction | ToggleTodoAction | SetVisibilityFilterAction;

// State interface
interface TodoState {
  todos: Todo[];
  visibilityFilter: VisibilityFilter;
}

// Initial state
const initialState: TodoState = {
  todos: [],
  visibilityFilter: 'SHOW_ALL'
};

// Type-safe reducer
function todoReducer(state = initialState, action: TodoActionTypes): TodoState {
  switch (action.type) {
    case ADD_TODO:
      return {
        ...state,
        todos: [
          ...state.todos,
          {
            id: state.todos.length + 1,
            text: action.payload.text,
            completed: false
          }
        ]
      };
    case TOGGLE_TODO:
      return {
        ...state,
        todos: state.todos.map(todo =>
          todo.id === action.payload.id
            ? { ...todo, completed: !todo.completed }
            : todo
        )
      };
    case SET_VISIBILITY_FILTER:
      return {
        ...state,
        visibilityFilter: action.payload.filter
      };
    default:
      return state;
  }
}

// Type-safe action creators
function addTodo(text: string): AddTodoAction {
  return {
    type: ADD_TODO,
    payload: { text }
  };
}

function toggleTodo(id: number): ToggleTodoAction {
  return {
    type: TOGGLE_TODO,
    payload: { id }
  };
}

function setVisibilityFilter(filter: VisibilityFilter): SetVisibilityFilterAction {
  return {
    type: SET_VISIBILITY_FILTER,
    payload: { filter }
  };
}
```

#### Type-Safe Global State with TypeScript and Context API

```typescript
import React, { createContext, useContext, useReducer, ReactNode } from 'react';

// Define the state shape
interface User {
  id: string;
  name: string;
  email: string;
}

interface AppState {
  user: User | null;
  isAuthenticated: boolean;
  theme: 'light' | 'dark';
  language: 'en' | 'es' | 'fr';
}

// Define action types
type ActionType = 
  | { type: 'LOGIN_USER'; payload: User }
  | { type: 'LOGOUT_USER' }
  | { type: 'SET_THEME'; payload: 'light' | 'dark' }
  | { type: 'SET_LANGUAGE'; payload: 'en' | 'es' | 'fr' };

// Initial state
const initialState: AppState = {
  user: null,
  isAuthenticated: false,
  theme: 'light',
  language: 'en'
};

// Type-safe reducer
function appReducer(state: AppState, action: ActionType): AppState {
  switch (action.type) {
    case 'LOGIN_USER':
      return {
        ...state,
        user: action.payload,
        isAuthenticated: true
      };
    case 'LOGOUT_USER':
      return {
        ...state,
        user: null,
        isAuthenticated: false
      };
    case 'SET_THEME':
      return {
        ...state,
        theme: action.payload
      };
    case 'SET_LANGUAGE':
      return {
        ...state,
        language: action.payload
      };
    default:
      return state;
  }
}

// Create the context with proper types
interface AppContextType {
  state: AppState;
  dispatch: React.Dispatch<ActionType>;
}

const AppContext = createContext<AppContextType | undefined>(undefined);

// Provider component
interface AppProviderProps {
  children: ReactNode;
}

export const AppProvider: React.FC<AppProviderProps> = ({ children }) => {
  const [state, dispatch] = useReducer(appReducer, initialState);
  
  // Memoize the context value to prevent unnecessary renders
  const contextValue = React.useMemo(() => {
    return { state, dispatch };
  }, [state, dispatch]);
  
  return (
    <AppContext.Provider value={contextValue}>
      {children}
    </AppContext.Provider>
  );
};

// Custom hook for accessing the context
export function useAppContext(): AppContextType {
  const context = useContext(AppContext);
  if (context === undefined) {
    throw new Error('useAppContext must be used within an AppProvider');
  }
  return context;
}

// Example usage in a component
const UserProfile: React.FC = () => {
  const { state, dispatch } = useAppContext();
  
  const handleLogout = () => {
    dispatch({ type: 'LOGOUT_USER' });
  };
  
  const toggleTheme = () => {
    const newTheme = state.theme === 'light' ? 'dark' : 'light';
    dispatch({ type: 'SET_THEME', payload: newTheme });
  };
  
  if (!state.isAuthenticated) {
    return <div>Please log in</div>;
  }
  
  return (
    <div className={`profile ${state.theme}`}>
      <h2>{state.user?.name}</h2>
      <p>{state.user?.email}</p>
      <button onClick={toggleTheme}>
        Switch to {state.theme === 'light' ? 'Dark' : 'Light'} Mode
      </button>
      <button onClick={handleLogout}>Logout</button>
    </div>
  );
};
```

### Type-Safe Styling in React

TypeScript can improve CSS-in-JS solutions by providing type checking for styles and themes.

#### Styled Components with TypeScript

```typescript
import styled, { ThemeProvider, DefaultTheme } from 'styled-components';
import React from 'react';

// Define theme interface
interface MyTheme extends DefaultTheme {
  colors: {
    primary: string;
    secondary: string;
    background: string;
    text: string;
    error: string;
  };
  fontSizes: {
    small: string;
    medium: string;
    large: string;
    xlarge: string;
  };
  spacing: {
    xs: string;
    sm: string;
    md: string;
    lg: string;
    xl: string;
  };
  borderRadius: {
    small: string;
    medium: string;
    large: string;
    round: string;
  };
}

// Create and export theme
export const theme: MyTheme = {
  colors: {
    primary: '#0070f3',
    secondary: '#6c757d',
    background: '#ffffff',
    text: '#333333',
    error: '#d32f2f',
  },
  fontSizes: {
    small: '0.875rem',
    medium: '1rem',
    large: '1.25rem',
    xlarge: '1.5rem',
  },
  spacing: {
    xs: '0.25rem',
    sm: '0.5rem',
    md: '1rem',
    lg: '1.5rem',
    xl: '2rem',
  },
  borderRadius: {
    small: '0.25rem',
    medium: '0.5rem',
    large: '1rem',
    round: '50%',
  },
};

// Type for button variants
type ButtonVariant = 'primary' | 'secondary' | 'danger' | 'success';

// Props interface with TypeScript
interface ButtonProps {
  variant?: ButtonVariant;
  size?: 'small' | 'medium' | 'large';
  fullWidth?: boolean;
  disabled?: boolean;
}

// Type-safe styled component
const Button = styled.button<ButtonProps>`
  font-family: inherit;
  font-weight: 600;
  cursor: ${props => props.disabled ? 'not-allowed' : 'pointer'};
  display: inline-flex;
  align-items: center;
  justify-content: center;
  
  /* Size variants */
  font-size: ${props => {
    switch (props.size) {
      case 'small': return props.theme.fontSizes.small;
      case 'large': return props.theme.fontSizes.large;
      default: return props.theme.fontSizes.medium;
    }
  }};
  
  padding: ${props => {
    switch (props.size) {
      case 'small': return `${props.theme.spacing.xs} ${props.theme.spacing.sm}`;
      case 'large': return `${props.theme.spacing.md} ${props.theme.spacing.lg}`;
      default: return `${props.theme.spacing.sm} ${props.theme.spacing.md}`;
    }
  }};
  
  /* Color variants */
  background-color: ${props => {
    if (props.disabled) return props.theme.colors.secondary;
    switch (props.variant) {
      case 'secondary': return 'transparent';
      case 'danger': return '#f44336';
      case 'success': return '#4caf50';
      default: return props.theme.colors.primary;
    }
  }};
  
  color: ${props => {
    if (props.disabled) return '#aaaaaa';
    switch (props.variant) {
      case 'secondary': return props.theme.colors.primary;
      default: return '#ffffff';
    }
  }};
  
  border: ${props => 
    props.variant === 'secondary' 
      ? `1px solid ${props.theme.colors.primary}` 
      : 'none'
  };
  
  border-radius: ${props => props.theme.borderRadius.medium};
  width: ${props => props.fullWidth ? '100%' : 'auto'};
  opacity: ${props => props.disabled ? 0.7 : 1};
  
  &:hover {
    ${props => !props.disabled && `
      filter: brightness(110%);
    `}
  }
  
  &:active {
    ${props => !props.disabled && `
      transform: translateY(1px);
    `}
  }
`;

// Usage in a component
const App: React.FC = () => {
  return (
    <ThemeProvider theme={theme}>
      <div>
        <h1>Styled Components with TypeScript</h1>
        <Button>Default Button</Button>
        <Button variant="secondary" size="small">Secondary Small</Button>
        <Button variant="danger" size="large" fullWidth>
          Danger Large Full Width
        </Button>
        <Button disabled>Disabled Button</Button>
      </div>
    </ThemeProvider>
  );
};
```

#### CSS Modules with TypeScript

```typescript
// styles.module.css.d.ts
declare const styles: {
  readonly container: string;
  readonly header: string;
  readonly button: string;
  readonly buttonPrimary: string;
  readonly buttonSecondary: string;
  readonly active: string;
};

export default styles;

// Component.tsx
import React from 'react';
import styles from './styles.module.css';

interface ButtonProps {
  variant: 'primary' | 'secondary';
  active?: boolean;
  onClick?: () => void;
  children: React.ReactNode;
}

const Button: React.FC<ButtonProps> = ({
  variant = 'primary',
  active = false,
  onClick,
  children
}) => {
  const buttonClass = `
    ${styles.button}
    ${variant === 'primary' ? styles.buttonPrimary : styles.buttonSecondary}
    ${active ? styles.active : ''}
  `.trim();
  
  return (
    <button className={buttonClass} onClick={onClick}>
      {children}
    </button>
  );
};
```

### Accessibility with TypeScript

TypeScript can help enforce accessibility best practices in React applications.

#### Typed ARIA Attributes

```typescript
import React from 'react';

interface AccessibleButtonProps {
  onClick: () => void;
  label: string;
  isExpanded?: boolean;
  controlsId?: string;
  disabled?: boolean;
  children: React.ReactNode;
}

const AccessibleButton: React.FC<AccessibleButtonProps> = ({
  onClick,
  label,
  isExpanded,
  controlsId,
  disabled = false,
  children
}) => {
  // Type-safe ARIA attributes
  const ariaAttributes: React.AriaAttributes = {
    'aria-label': label,
    'aria-expanded': isExpanded,
    'aria-controls': controlsId,
    'aria-disabled': disabled
  };
  
  return (
    <button
      onClick={onClick}
      disabled={disabled}
      {...ariaAttributes}
    >
      {children}
    </button>
  );
};

// Usage
const App: React.FC = () => {
  const [isOpen, setIsOpen] = React.useState(false);
  
  return (
    <div>
      <AccessibleButton
        onClick={() => setIsOpen(!isOpen)}
        label="Toggle Menu"
        isExpanded={isOpen}
        controlsId="mainMenu"
      >
        Menu
      </AccessibleButton>
      
      <div id="mainMenu" hidden={!isOpen}>
        {/* Menu content */}
      </div>
    </div>
  );
};
```

### Server-Side Rendering with TypeScript

TypeScript improves type safety in server-side rendered React applications.

#### Next.js with TypeScript

```typescript
// pages/[slug].tsx
import { GetServerSideProps, NextPage } from 'next';
import React from 'react';

interface Article {
  id: number;
  title: string;
  content: string;
  publishedDate: string;
  author: {
    id: number;
    name: string;
  };
}

interface ArticlePageProps {
  article: Article | null;
  error?: string;
}

const ArticlePage: NextPage<ArticlePageProps> = ({ article, error }) => {
  if (error) {
    return <div className="error">{error}</div>;
  }
  
  if (!article) {
    return <div>Loading...</div>;
  }
  
  return (
    <article>
      <h1>{article.title}</h1>
      <div className="meta">
        By {article.author.name} on {new Date(article.publishedDate).toLocaleDateString()}
      </div>
      <div className="content" dangerouslySetInnerHTML={{ __html: article.content }} />
    </article>
  );
};

export const getServerSideProps: GetServerSideProps<ArticlePageProps> = async (context) => {
  const { slug } = context.params || {};
  
  try {
    // Type safety in API calls
    const response = await fetch(`https://api.example.com/articles/${slug}`);
    
    if (!response.ok) {
      // Handle errors with proper typing
      if (response.status === 404) {
        return { props: { article: null, error: 'Article not found' } };
      }
      throw new Error(`API error: ${response.status}`);
    }
    
    const article: Article = await response.json();
    
    return {
      props: { article }
    };
  } catch (error) {
    console.error('Failed to fetch article:', error);
    return {
      props: {
        article: null,
        error: 'Failed to load article'
      }
    };
  }
};

export default ArticlePage;
```

### Recommended Related Topics

- TypeScript Design Patterns for React Applications
- Advanced TypeScript Generic Components
- TypeScript Migration Strategies for Existing React Projects
- Building Component Libraries with TypeScript and React
- TypeScript with GraphQL and React
- End-to-End Type Safety with TypeScript, React, and Backend APIs
- TypeScript Custom Type Guards for React Components

---
## TypeScript with Node.js

### Introduction to TypeScript in Node.js Development

TypeScript has revolutionized Node.js development by bringing static typing to JavaScript, enhancing developer experience through improved tooling, code completion, and error detection during development rather than runtime. This powerful combination enables building robust, maintainable, and scalable server-side applications with increased confidence and productivity.

**Key Points**

- TypeScript is a superset of JavaScript that adds static typing
- Compiles to plain JavaScript that can run in any JavaScript runtime
- Provides early error detection and improved IDE support
- Enhances code documentation through explicit type definitions
- Facilitates easier refactoring and maintenance of large codebases

### Setting Up a TypeScript Node.js Project

Setting up a new TypeScript Node.js project involves initializing npm, installing TypeScript dependencies, and configuring the TypeScript compiler.

```bash
# Initialize a new Node.js project
npm init -y

# Install TypeScript and Node.js type definitions
npm install typescript @types/node --save-dev

# Initialize TypeScript configuration
npx tsc --init
```

The generated `tsconfig.json` file controls how TypeScript compiles your code. Here's a recommended configuration for Node.js projects:

```json
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "NodeNext",
    "moduleResolution": "NodeNext",
    "esModuleInterop": true,
    "strict": true,
    "outDir": "./dist",
    "rootDir": "./src",
    "sourceMap": true,
    "declaration": true,
    "resolveJsonModule": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "**/*.test.ts"]
}
```

Add useful npm scripts to your `package.json`:

```json
"scripts": {
  "build": "tsc",
  "start": "node dist/index.js",
  "dev": "ts-node-dev --respawn src/index.js",
  "lint": "eslint . --ext .ts"
}
```

### Type Definitions for Node.js

Working with Node.js in TypeScript requires proper type definitions for the Node.js API and modules. The `@types/node` package is essential for this purpose.

**Key Points**

- `@types/node` provides TypeScript definitions for all built-in Node.js modules
- TypeScript can infer types from these definitions, improving IntelliSense and catching errors
- The definitions are regularly updated to match the latest Node.js releases

Here's how you can use these definitions with Node.js built-in modules:

```typescript
import * as fs from 'fs';
import * as path from 'path';
import { IncomingMessage, ServerResponse } from 'http';

// TypeScript knows the exact shape of these objects
const readFile = async (filePath: string): Promise<string> => {
  const absolutePath = path.resolve(__dirname, filePath);
  return fs.promises.readFile(absolutePath, 'utf-8');
};

// Using Node.js HTTP types
function requestHandler(req: IncomingMessage, res: ServerResponse): void {
  res.writeHead(200, { 'Content-Type': 'application/json' });
  res.end(JSON.stringify({ message: 'Hello TypeScript!' }));
}
```

### Using External Modules with TypeScript

When working with external npm packages in TypeScript, you'll need their type definitions as well.

```typescript
// For packages with built-in TypeScript support (e.g., Axios)
import axios from 'axios';

// For packages without built-in TypeScript support, install @types
// npm install lodash @types/lodash --save
import * as _ from 'lodash';
```

If no type definitions exist for a package, you can create a declaration file:

```typescript
// src/types/untyped-module.d.ts
declare module 'untyped-module' {
  export function doSomething(param: string): boolean;
  export default class SomeClass {
    constructor(options?: { option1?: string });
    methodA(): void;
  }
}
```

### Express with TypeScript

Express is one of the most popular web frameworks for Node.js, and TypeScript adds type safety to Express applications.

**Key Points**

- Type definitions for Express improves middleware and route handler development
- Use of interfaces for request and response objects enhances code clarity
- Type-safe route parameters and query strings prevent runtime errors

First, install Express with its type definitions:

```bash
npm install express
npm install @types/express --save-dev
```

Basic Express setup with TypeScript:

```typescript
import express, { Request, Response, NextFunction } from 'express';

const app = express();
const PORT = process.env.PORT || 3000;

// Define interfaces for type safety
interface UserRequest extends Request {
  body: {
    username: string;
    email: string;
    password: string;
  }
}

// Middleware with proper types
const loggerMiddleware = (req: Request, res: Response, next: NextFunction) => {
  console.log(`${req.method} ${req.path}`);
  next();
};

app.use(express.json());
app.use(loggerMiddleware);

// Route with typed request body
app.post('/users', (req: UserRequest, res: Response) => {
  const { username, email, password } = req.body;
  
  if (!username || !email || !password) {
    return res.status(400).json({ error: 'Missing required fields' });
  }
  
  // Process user registration
  res.status(201).json({ message: 'User created', username });
});

// Typed route parameters
app.get('/users/:id', (req: Request<{ id: string }>, res: Response) => {
  const userId = req.params.id;
  
  // Fetch user by ID
  res.json({ id: userId, username: 'example_user' });
});

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
```

### Advanced Express Patterns with TypeScript

For larger applications, organizing Express routes and middleware with TypeScript becomes essential.

```typescript
// src/types/express/index.d.ts
import 'express';

declare global {
  namespace Express {
    interface Request {
      user?: {
        id: string;
        username: string;
        roles: string[];
      };
    }
  }
}
```

Implementing modular routes:

```typescript
// src/routes/user.routes.ts
import { Router } from 'express';
import { UserController } from '../controllers/user.controller';
import { authMiddleware } from '../middleware/auth.middleware';

const router = Router();
const userController = new UserController();

router.get('/', userController.getAllUsers);
router.get('/:id', userController.getUserById);
router.post('/', authMiddleware(['admin']), userController.createUser);
router.put('/:id', authMiddleware(['admin', 'user']), userController.updateUser);
router.delete('/:id', authMiddleware(['admin']), userController.deleteUser);

export default router;
```

Controller with TypeScript:

```typescript
// src/controllers/user.controller.ts
import { Request, Response } from 'express';
import { UserService } from '../services/user.service';

export class UserController {
  private userService = new UserService();

  public getAllUsers = async (req: Request, res: Response): Promise<void> => {
    try {
      const users = await this.userService.findAll();
      res.json(users);
    } catch (error) {
      res.status(500).json({ error: 'Failed to fetch users' });
    }
  };

  public getUserById = async (req: Request<{ id: string }>, res: Response): Promise<void> => {
    try {
      const user = await this.userService.findById(req.params.id);
      if (!user) {
        res.status(404).json({ error: 'User not found' });
        return;
      }
      res.json(user);
    } catch (error) {
      res.status(500).json({ error: 'Failed to fetch user' });
    }
  };

  // Other controller methods...
}
```

### Creating Typed APIs

Developing typed APIs with TypeScript ensures consistency between your API contracts and implementation.

**Key Points**

- Define interfaces for request/response bodies for type safety
- Use generics for reusable API components
- Create utility types for common API patterns
- Document API endpoints with JSDoc comments

Define shared models and interfaces:

```typescript
// src/models/user.model.ts
export interface User {
  id: string;
  username: string;
  email: string;
  createdAt: Date;
  updatedAt: Date;
}

export interface CreateUserDto {
  username: string;
  email: string;
  password: string;
}

export interface UpdateUserDto {
  username?: string;
  email?: string;
  password?: string;
}

// Generic API response types
export interface ApiResponse<T> {
  data: T;
  message: string;
  status: number;
}

export interface PaginatedResponse<T> {
  items: T[];
  total: number;
  page: number;
  limit: number;
  totalPages: number;
}
```

Implementing typed service class:

```typescript
// src/services/user.service.ts
import { User, CreateUserDto, UpdateUserDto, PaginatedResponse } from '../models/user.model';
import { DatabaseError } from '../errors/database.error';

export class UserService {
  public async findAll(page = 1, limit = 10): Promise<PaginatedResponse<User>> {
    try {
      // Implementation to fetch users from database
      const users: User[] = []; // Replace with actual database query
      const total = 100; // Replace with count query
      
      return {
        items: users,
        total,
        page,
        limit,
        totalPages: Math.ceil(total / limit)
      };
    } catch (error) {
      throw new DatabaseError('Failed to fetch users', error);
    }
  }

  public async findById(id: string): Promise<User | null> {
    try {
      // Implementation to fetch user by ID
      return null; // Replace with actual database query
    } catch (error) {
      throw new DatabaseError('Failed to fetch user', error);
    }
  }

  public async create(userData: CreateUserDto): Promise<User> {
    try {
      // Implementation to create user
      const newUser: User = {
        id: 'generated-id',
        username: userData.username,
        email: userData.email,
        createdAt: new Date(),
        updatedAt: new Date()
      };
      
      return newUser;
    } catch (error) {
      throw new DatabaseError('Failed to create user', error);
    }
  }

  // Other service methods...
}
```

### Error Handling with TypeScript

TypeScript enhances error handling through custom error classes and type checking.

```typescript
// src/errors/base.error.ts
export abstract class BaseError extends Error {
  public readonly statusCode: number;
  public readonly isOperational: boolean;

  constructor(
    message: string,
    statusCode: number,
    isOperational = true,
    stack = ''
  ) {
    super(message);
    this.statusCode = statusCode;
    this.isOperational = isOperational;
    
    if (stack) {
      this.stack = stack;
    } else {
      Error.captureStackTrace(this, this.constructor);
    }
  }
}

// src/errors/api.error.ts
import { BaseError } from './base.error';

export class ApiError extends BaseError {
  constructor(message: string, statusCode = 500) {
    super(message, statusCode);
  }
}

export class NotFoundError extends ApiError {
  constructor(message = 'Resource not found') {
    super(message, 404);
  }
}

export class BadRequestError extends ApiError {
  constructor(message = 'Bad request') {
    super(message, 400);
  }
}

// Express error handler middleware
import { Request, Response, NextFunction } from 'express';
import { BaseError } from '../errors/base.error';

export const errorHandler = (
  err: Error,
  req: Request,
  res: Response,
  next: NextFunction
): void => {
  if (err instanceof BaseError) {
    res.status(err.statusCode).json({
      status: 'error',
      message: err.message
    });
    return;
  }

  console.error('Unexpected error:', err);
  res.status(500).json({
    status: 'error',
    message: 'Internal server error'
  });
};
```

### Database Integration with TypeScript

TypeScript provides type safety when working with databases in Node.js applications.

**Example** Using TypeORM with TypeScript:

```typescript
// src/entities/user.entity.ts
import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, UpdateDateColumn } from 'typeorm';

@Entity('users')
export class UserEntity {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ unique: true })
  username: string;

  @Column({ unique: true })
  email: string;

  @Column()
  passwordHash: string;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}

// src/repositories/user.repository.ts
import { Repository, EntityRepository } from 'typeorm';
import { UserEntity } from '../entities/user.entity';
import { CreateUserDto } from '../models/user.model';

@EntityRepository(UserEntity)
export class UserRepository extends Repository<UserEntity> {
  public async createUser(userData: CreateUserDto): Promise<UserEntity> {
    const user = new UserEntity();
    user.username = userData.username;
    user.email = userData.email;
    user.passwordHash = 'hashed_password'; // Use a proper hashing function
    
    return this.save(user);
  }
  
  public async findByUsername(username: string): Promise<UserEntity | undefined> {
    return this.findOne({ where: { username } });
  }
}
```

### Testing TypeScript Node.js Applications

TypeScript enhances testability with type safety in unit and integration tests.

```typescript
// src/services/__tests__/user.service.test.ts
import { UserService } from '../user.service';
import { UserRepository } from '../../repositories/user.repository';
import { CreateUserDto } from '../../models/user.model';
import { NotFoundError } from '../../errors/api.error';

// Mock the repository
jest.mock('../../repositories/user.repository');

describe('UserService', () => {
  let userService: UserService;
  let userRepository: jest.Mocked<UserRepository>;

  beforeEach(() => {
    userRepository = new UserRepository() as jest.Mocked<UserRepository>;
    userService = new UserService(userRepository);
  });

  describe('createUser', () => {
    it('should create a new user', async () => {
      // Arrange
      const createUserDto: CreateUserDto = {
        username: 'testuser',
        email: 'test@example.com',
        password: 'password123'
      };
      
      const expectedUser = {
        id: 'test-id',
        username: 'testuser',
        email: 'test@example.com',
        createdAt: new Date(),
        updatedAt: new Date()
      };
      
      userRepository.createUser.mockResolvedValue(expectedUser as any);
      
      // Act
      const result = await userService.create(createUserDto);
      
      // Assert
      expect(userRepository.createUser).toHaveBeenCalledWith(expect.objectContaining({
        username: createUserDto.username,
        email: createUserDto.email
      }));
      expect(result).toEqual(expectedUser);
    });
  });

  describe('findById', () => {
    it('should find a user by id', async () => {
      // Arrange
      const userId = 'test-id';
      const expectedUser = {
        id: userId,
        username: 'testuser',
        email: 'test@example.com'
      };
      
      userRepository.findOne.mockResolvedValue(expectedUser as any);
      
      // Act
      const result = await userService.findById(userId);
      
      // Assert
      expect(userRepository.findOne).toHaveBeenCalledWith({ where: { id: userId } });
      expect(result).toEqual(expectedUser);
    });
    
    it('should throw NotFoundError when user does not exist', async () => {
      // Arrange
      const userId = 'non-existent-id';
      userRepository.findOne.mockResolvedValue(undefined);
      
      // Act & Assert
      await expect(userService.findById(userId)).rejects.toThrow(NotFoundError);
    });
  });
});
```

### Advanced TypeScript Features for Node.js

TypeScript offers advanced features that can be leveraged in Node.js development.

#### Type Guards and Type Narrowing

```typescript
// Custom type guard
function isUser(obj: any): obj is User {
  return (
    obj &&
    typeof obj === 'object' &&
    'id' in obj &&
    'username' in obj &&
    'email' in obj
  );
}

// Using type guards
function processEntity(entity: User | Organization): string {
  if (isUser(entity)) {
    // TypeScript knows entity is User here
    return `User: ${entity.username}`;
  } else {
    // TypeScript knows entity is Organization here
    return `Organization: ${entity.name}`;
  }
}
```

#### Utility Types for API Development

```typescript
// Using TypeScript utility types for API models
type UserResponse = Omit<User, 'password'>;
type UserWithRoles = User & { roles: string[] };
type OptionalUser = Partial<User>;
type ReadonlyUser = Readonly<User>;

// API response mapper
function mapToUserResponse(user: User): UserResponse {
  const { password, ...userWithoutPassword } = user;
  return userWithoutPassword;
}

// Ensuring immutability
function processUser(user: ReadonlyUser): void {
  // This would cause a TypeScript error
  // user.username = 'newname';
  
  // Instead, create a new object
  const updatedUser = { ...user, lastSeen: new Date() };
  // Process the updated user...
}
```

#### Decorators for Node.js Applications

```typescript
// Method decorator for logging
function LogMethod(target: any, propertyKey: string, descriptor: PropertyDescriptor) {
  const originalMethod = descriptor.value;
  
  descriptor.value = function(...args: any[]) {
    console.log(`Calling ${propertyKey} with arguments: ${JSON.stringify(args)}`);
    const result = originalMethod.apply(this, args);
    console.log(`Method ${propertyKey} returned: ${JSON.stringify(result)}`);
    return result;
  };
  
  return descriptor;
}

class UserController {
  @LogMethod
  public getUserInfo(userId: string) {
    return { id: userId, username: 'example' };
  }
}
```

### Performance Optimization with TypeScript

TypeScript can help identify and resolve performance issues in Node.js applications.

**Key Points**

- TypeScript helps detect memory leaks through proper typing
- Async/await patterns are type-safe and easier to maintain
- Proper typing of Promise chains improves readability and error handling

```typescript
// Memory-efficient stream processing with proper typing
import { Readable, Transform, Writable } from 'stream';
import { promisify } from 'util';
import * as fs from 'fs';

interface DataChunk {
  id: number;
  content: string;
}

const pipeline = promisify(require('stream').pipeline);

async function processLargeFile(filePath: string, outputPath: string): Promise<void> {
  const readStream = fs.createReadStream(filePath, { encoding: 'utf-8' });
  const writeStream = fs.createWriteStream(outputPath);
  
  const parseJson = new Transform({
    objectMode: true,
    transform(chunk: string, encoding: string, callback: Function) {
      try {
        const data = JSON.parse(chunk) as DataChunk;
        callback(null, data);
      } catch (error) {
        callback(error);
      }
    }
  });
  
  const processData = new Transform({
    objectMode: true,
    transform(data: DataChunk, encoding: string, callback: Function) {
      // Process the data
      const processed = {
        ...data,
        content: data.content.toUpperCase()
      };
      callback(null, JSON.stringify(processed) + '\n');
    }
  });
  
  try {
    await pipeline(readStream, parseJson, processData, writeStream);
    console.log('Processing completed');
  } catch (error) {
    console.error('Pipeline failed', error);
    throw error;
  }
}
```

### Debugging TypeScript Node.js Applications

TypeScript enhances the debugging experience through source maps and type information.

Configure debugging in VS Code with `.vscode/launch.json`:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "type": "node",
      "request": "launch",
      "name": "Debug TypeScript",
      "skipFiles": ["<node_internals>/**"],
      "program": "${workspaceFolder}/src/index.ts",
      "preLaunchTask": "tsc: build - tsconfig.json",
      "outFiles": ["${workspaceFolder}/dist/**/*.js"],
      "sourceMaps": true
    },
    {
      "type": "node",
      "request": "launch",
      "name": "Debug Current Test",
      "program": "${workspaceFolder}/node_modules/.bin/jest",
      "args": ["--runInBand", "${relativeFile}"],
      "console": "integratedTerminal",
      "internalConsoleOptions": "neverOpen",
      "disableOptimisticBPs": true
    }
  ]
}
```

### Deployment Considerations for TypeScript Node.js Applications

When deploying TypeScript Node.js applications, consider these approaches:

1. **Compile-then-deploy**: Build your TypeScript code to JavaScript before deployment
    
    ```bash
    npm run build
    # Deploy the contents of the dist folder
    ```
    
2. **Runtime transpilation**: Use ts-node in production (not recommended for performance-critical applications)
    
    ```bash
    npm install ts-node --save
    # Set NODE_ENV=production
    node -r ts-node/register src/index.ts
    ```
    
3. **Docker-based deployment**:
    
    ```dockerfile
    FROM node:18-alpine as builder
    WORKDIR /app
    COPY package*.json ./
    RUN npm ci
    COPY tsconfig.json ./
    COPY src/ ./src/
    RUN npm run build
    
    FROM node:18-alpine
    WORKDIR /app
    COPY package*.json ./
    RUN npm ci --production
    COPY --from=builder /app/dist ./dist
    CMD ["node", "dist/index.js"]
    ```
    

**Key Points**

- Always include source maps for error tracking
- Set appropriate NODE_ENV values
- Consider using process managers like PM2
- Implement health checks and monitoring

### Best Practices for TypeScript with Node.js

**Key Points**

- Use strict mode in TypeScript for maximum type safety
- Create domain-specific interfaces and types
- Leverage enums for constants and state management
- Use discriminated unions for type-safe handling of different states
- Document code with JSDoc comments for better IDE integration

```typescript
/**
 * Represents the current state of a job in the system.
 */
enum JobStatus {
  PENDING = 'pending',
  PROCESSING = 'processing',
  COMPLETED = 'completed',
  FAILED = 'failed'
}

/**
 * Base interface for all job types.
 */
interface JobBase {
  id: string;
  status: JobStatus;
  createdAt: Date;
  updatedAt: Date;
}

/**
 * Represents an email sending job.
 */
interface EmailJob extends JobBase {
  type: 'email';
  recipient: string;
  subject: string;
  body: string;
}

/**
 * Represents a file processing job.
 */
interface FileProcessingJob extends JobBase {
  type: 'file_processing';
  filePath: string;
  outputPath: string;
  processingOptions: {
    resize?: boolean;
    format?: 'jpg' | 'png' | 'webp';
  };
}

/**
 * Union type for all job types in the system.
 */
type Job = EmailJob | FileProcessingJob;

/**
 * Processes a job based on its type.
 * @param job The job to process
 * @returns A promise that resolves when the job is processed
 */
async function processJob(job: Job): Promise<void> {
  // Common job processing logic
  console.log(`Processing job ${job.id} with status ${job.status}`);
  
  // Type-specific processing using discriminated union
  switch (job.type) {
    case 'email':
      await sendEmail(job.recipient, job.subject, job.body);
      break;
    case 'file_processing':
      await processFile(job.filePath, job.outputPath, job.processingOptions);
      break;
    default:
      // Exhaustiveness check - will cause compile error if a job type is added without handling
      const exhaustiveCheck: never = job;
      throw new Error(`Unhandled job type: ${exhaustiveCheck}`);
  }
}
```

### Conclusion

TypeScript transforms Node.js development by bringing strong typing, better tooling, and improved code quality to server-side JavaScript. Its seamless integration with Express and other frameworks makes it an excellent choice for building robust APIs and web applications. By leveraging TypeScript's advanced features and adhering to best practices, developers can create maintainable, scalable, and reliable Node.js applications that are easier to develop, test, and deploy.

### Related Topics

- TypeScript with GraphQL for API development
- TypeScript with WebSockets for real-time applications
- Microservices architecture with TypeScript and Node.js
- TypeScript with serverless functions (AWS Lambda, Azure Functions)
- Advanced type manipulation techniques for complex domain models

---

## TypeScript with Other Frameworks

### TypeScript Integration with JavaScript Frameworks

TypeScript has become the language of choice for many modern JavaScript frameworks due to its strong typing system, enhanced IDE support, and improved developer experience. This comprehensive guide explores how TypeScript integrates with three popular frameworks: Angular, Vue, and Next.js.

### Angular with TypeScript

Angular was built with TypeScript integration in mind from its inception, making it one of the most seamless TypeScript experiences in the frontend ecosystem.

#### Architecture and Integration

Angular uses TypeScript as its primary language, with first-class support embedded throughout the framework. The Angular CLI automatically generates TypeScript files for components, services, directives, and other elements.

```typescript
import { Component } from '@angular/core';

@Component({
  selector: 'app-root',
  template: `
    <h1>{{ title }}</h1>
    <button (click)="incrementCounter()">Count: {{ counter }}</button>
  `
})
export class AppComponent {
  title: string = 'Angular with TypeScript';
  counter: number = 0;

  incrementCounter(): void {
    this.counter++;
  }
}
```

#### Type Safety in Templates

Angular offers template type checking with the `strictTemplates` compiler option, ensuring your templates are type-safe:

```typescript
// This will cause a compile-time error if the property doesn't exist
<div>{{ nonExistentProperty }}</div>

// Component class
export class MyComponent {
  // No 'nonExistentProperty' defined
  validProperty: string = 'Hello';
}
```

#### Angular-Specific TypeScript Features

Angular uses TypeScript decorators extensively for metadata:

```typescript
@Injectable({
  providedIn: 'root'
})
export class DataService {
  getData(): Observable<User[]> {
    return this.http.get<User[]>('/api/users');
  }
}
```

**Key Points**:

- Angular uses TypeScript by default for all components
- Type-checking extends to templates with strictTemplates
- Decorators provide metadata for the Angular dependency injection system
- Angular CLI generates TypeScript code for all Angular artifacts

### Vue with TypeScript

Vue has evolved to offer excellent TypeScript support, particularly with Vue 3's Composition API and improved type definitions.

#### Vue 3 Class-Based Approach

Vue supports class-based components with TypeScript:

```typescript
import { Options, Vue } from 'vue-class-component';

@Options({
  props: {
    message: String
  },
  template: '<div>{{ message }}</div>'
})
export default class HelloWorld extends Vue {
  message!: string;
}
```

#### Vue 3 Composition API

The Composition API provides superior TypeScript integration:

```typescript
<script lang="ts">
import { defineComponent, ref, computed } from 'vue';

export default defineComponent({
  props: {
    initialCount: {
      type: Number,
      default: 0
    }
  },
  setup(props) {
    const count = ref(props.initialCount);
    const doubleCount = computed(() => count.value * 2);

    function increment() {
      count.value++;
    }

    return {
      count,
      doubleCount,
      increment
    };
  }
});
</script>
```

#### Vue 3's Script Setup Syntax

The script setup syntax provides even cleaner TypeScript integration:

```typescript
<script setup lang="ts">
import { ref, computed } from 'vue';

// Props can be defined using TypeScript interfaces
defineProps<{
  initialCount: number;
}>();

const count = ref(0);
const doubleCount = computed(() => count.value * 2);

function increment(): void {
  count.value++;
}
</script>

<template>
  <button @click="increment">{{ count }}</button>
  <p>Double: {{ doubleCount }}</p>
</template>
```

#### Vue Type Augmentation

Vue allows extending existing types to add custom global properties:

```typescript
// vue-shim.d.ts
import Vue from 'vue';

declare module 'vue' {
  interface ComponentCustomProperties {
    $api: ApiService;
    $config: AppConfig;
  }
}
```

**Key Points**:

- Vue 3 was rewritten in TypeScript, providing first-class TypeScript support
- Composition API offers better TypeScript integration than Options API
- Script setup syntax simplifies using TypeScript with Vue components
- Supports defineProps with TypeScript interfaces and generics

### Next.js with TypeScript

Next.js, built on React, offers superb TypeScript integration with strong typing for its routing, data fetching, and server components.

#### Project Setup

Creating a TypeScript-based Next.js project:

```bash
npx create-next-app@latest my-app --typescript
```

#### Pages and API Routes

Next.js provides TypeScript types for pages, API routes, and server-side functions:

```typescript
// pages/index.tsx
import type { NextPage, GetStaticProps } from 'next';

interface HomeProps {
  products: Product[];
}

const Home: NextPage<HomeProps> = ({ products }) => {
  return (
    <div>
      {products.map(product => (
        <div key={product.id}>{product.name}</div>
      ))}
    </div>
  );
};

export const getStaticProps: GetStaticProps = async () => {
  const res = await fetch('https://api.example.com/products');
  const products = await res.json();
  
  return {
    props: { products },
    revalidate: 60
  };
};

export default Home;
```

#### API Route Types

Next.js provides types for API routes as well:

```typescript
// pages/api/users.ts
import type { NextApiRequest, NextApiResponse } from 'next';
import { User } from '../../types';

export default function handler(
  req: NextApiRequest,
  res: NextApiResponse<User[] | { error: string }>
) {
  if (req.method === 'GET') {
    // Return users
    res.status(200).json([{ id: 1, name: 'John' }]);
  } else {
    res.status(405).json({ error: 'Method not allowed' });
  }
}
```

#### App Router and React Server Components

Next.js 13+ app router provides type safety for server components:

```typescript
// app/page.tsx
import { Suspense } from 'react';
import type { Product } from '@/types';

async function getProducts(): Promise<Product[]> {
  const res = await fetch('https://api.example.com/products');
  return res.json();
}

export default async function ProductsPage() {
  const products = await getProducts();
  
  return (
    <div>
      <h1>Products</h1>
      <Suspense fallback={<p>Loading products...</p>}>
        {products.map(product => (
          <div key={product.id}>{product.name}</div>
        ))}
      </Suspense>
    </div>
  );
}
```

#### Configuration Types

TypeScript support extends to Next.js configuration:

```typescript
// next.config.ts
import { NextConfig } from 'next';

const config: NextConfig = {
  reactStrictMode: true,
  images: {
    domains: ['images.example.com'],
  },
  i18n: {
    locales: ['en', 'fr'],
    defaultLocale: 'en',
  }
};

export default config;
```

**Key Points**:

- Next.js provides TypeScript templates out of the box
- Type definitions for pages, API routes, and data fetching methods
- Strong typing support for both client and server components
- TypeScript configurations for Next.js-specific features like routing and image optimization

### Performance Considerations

TypeScript integration with these frameworks adds minimal runtime overhead since TypeScript is transpiled to JavaScript before deployment. However, it can affect build times and developer experience.

#### Build Performance

Each framework handles TypeScript compilation differently:

- Angular: Uses its own TypeScript compiler (ngc)
- Vue: Uses Vue's template compiler with TypeScript support
- Next.js: Uses SWC (Rust-based) compiler for faster TypeScript compilation

#### Development Workflow

TypeScript enhances the development workflow across all frameworks:

```typescript
// This would trigger a compiler error
function calculateTotal(items: { price: number }[]): number {
  return items.reduce((total, item) => total + item.price, 0);
}

// If called with incompatible data
calculateTotal([{ cost: 20 }]); // Error: Property 'price' is missing
```

### Cross-Framework Components and Libraries

TypeScript facilitates sharing code between frameworks through well-typed libraries:

```typescript
// shared/types.ts
export interface User {
  id: string;
  name: string;
  email: string;
}

// shared/validation.ts
export function validateEmail(email: string): boolean {
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
}
```

### Testing with TypeScript

TypeScript improves testing across all frameworks:

```typescript
// Angular testing
import { TestBed } from '@angular/core/testing';
import { UserService } from './user.service';

describe('UserService', () => {
  let service: UserService;

  beforeEach(() => {
    TestBed.configureTestingModule({});
    service = TestBed.inject(UserService);
  });

  it('should validate user data', () => {
    const user: User = { id: '1', name: 'John', email: 'invalid' };
    expect(service.validateUser(user)).toBeFalsy();
  });
});
```

### Migrating Existing Projects to TypeScript

Each framework has different migration paths:

#### Gradual Angular Migration

Angular projects can adopt TypeScript gradually:

```typescript
// Converting a JavaScript component to TypeScript
// Before: user.component.js
function UserComponent() {
  this.users = [];
}

// After: user.component.ts
interface User {
  id: string;
  name: string;
}

class UserComponent {
  users: User[] = [];
}
```

#### Vue Incremental Adoption

Vue projects can add TypeScript incrementally:

```typescript
// Adding TypeScript to a Vue file
<script lang="ts">
import { defineComponent } from 'vue';

export default defineComponent({
  data() {
    return {
      message: 'Hello' as string
    };
  },
  methods: {
    greet(name: string): string {
      return `${this.message}, ${name}!`;
    }
  }
});
</script>
```

#### Next.js Migration Strategy

Next.js projects can be migrated by adding TypeScript and gradually typing files:

```typescript
// Renaming .js files to .tsx and adding types
// pages/users.js → pages/users.tsx
import { useState, useEffect } from 'react';
import type { User } from '../types';

export default function Users() {
  const [users, setUsers] = useState<User[]>([]);
  
  useEffect(() => {
    async function fetchUsers() {
      const res = await fetch('/api/users');
      const data: User[] = await res.json();
      setUsers(data);
    }
    fetchUsers();
  }, []);
  
  return (
    <ul>
      {users.map(user => (
        <li key={user.id}>{user.name}</li>
      ))}
    </ul>
  );
}
```

### Advanced TypeScript Features

#### Leveraging TypeScript's Type System

All three frameworks benefit from TypeScript's advanced type features:

```typescript
// Angular example with advanced types
type InputSize = 'small' | 'medium' | 'large';

@Component({
  selector: 'app-input',
  template: `<input [class]="size" />`
})
export class InputComponent {
  @Input() size: InputSize = 'medium';
}
```

#### Decorators and Metadata

Angular and class-based Vue components leverage TypeScript decorators:

```typescript
// Angular service with decorated methods
@Injectable()
export class LoggingService {
  @LogMethod()
  logError(error: Error): void {
    console.error(`[${new Date().toISOString()}]`, error);
  }
}
```

#### Generic Components

TypeScript generics work well with all frameworks:

```typescript
// React/Next.js generic component
interface ListProps<T> {
  items: T[];
  renderItem: (item: T) => React.ReactNode;
}

function List<T>({ items, renderItem }: ListProps<T>) {
  return (
    <ul>
      {items.map((item, index) => (
        <li key={index}>{renderItem(item)}</li>
      ))}
    </ul>
  );
}

// Usage
<List<User>
  items={users}
  renderItem={(user) => user.name}
/>
```

### Framework-Specific Best Practices

#### Angular Best Practices

```typescript
// Use interfaces for models
export interface Product {
  id: string;
  name: string;
  price: number;
  category: string;
}

// Type-safe forms
import { FormBuilder, FormGroup, Validators } from '@angular/forms';

@Component({...})
export class ProductFormComponent {
  productForm: FormGroup;
  
  constructor(private fb: FormBuilder) {
    this.productForm = this.fb.group({
      name: ['', [Validators.required]],
      price: [0, [Validators.min(0)]],
      category: ['', [Validators.required]]
    });
  }
  
  get formControls() {
    return this.productForm.controls;
  }
}
```

#### Vue Best Practices

```typescript
// Vue 3 with strong typing
<script setup lang="ts">
import { ref } from 'vue';
import type { Product } from '@/types';

// Strongly typed props
defineProps<{
  product: Product;
  onSave: (product: Product) => void;
}>();

// Type-safe refs
const quantity = ref<number>(1);

// Event handlers with type safety
function handleIncrement(): void {
  quantity.value++;
}
</script>
```

#### Next.js Best Practices

```typescript
// Type-safe API calls
import useSWR from 'swr';
import type { User } from '@/types';

function useUser(id: string) {
  const { data, error } = useSWR<User, Error>(
    `/api/users/${id}`,
    async (url) => {
      const res = await fetch(url);
      if (!res.ok) throw new Error('Failed to fetch user');
      return res.json();
    }
  );

  return {
    user: data,
    isLoading: !error && !data,
    isError: error
  };
}
```

### Framework Comparison

#### Type Safety Level

- Angular: Very high (built for TypeScript)
- Vue 3: High (especially with Composition API)
- Next.js: High (leverages React's type system)

#### Learning Curve

- Angular: Steeper learning curve due to comprehensive framework features
- Vue: Moderate, with options for gradual TypeScript adoption
- Next.js: Moderate if familiar with React and TypeScript

#### Tooling Support

All three frameworks offer excellent tooling support:

- Angular: Angular CLI with built-in TypeScript support
- Vue: Vue CLI or Vite with TypeScript plugins
- Next.js: Built-in TypeScript support in create-next-app

**Example**:

```bash
# Angular
ng new my-app --strict

# Vue
vue create my-app
# Then select TypeScript in the options

# Next.js
npx create-next-app@latest my-app --typescript
```

### Future Trends

The integration of TypeScript with these frameworks continues to evolve:

- Angular is further embracing TypeScript features in template type checking
- Vue is improving TypeScript support in the Composition API and script setup
- Next.js is enhancing TypeScript support for server components and data fetching

**Key Points**:

- All three frameworks are moving toward stronger typing and better TypeScript integration
- Server-side rendering with type safety is becoming a focus across frameworks
- Type-safe API integrations continue to improve

### Related Topics and Resources

Consider exploring these related topics for a deeper understanding:

- State management with TypeScript (Redux, Vuex, NgRx)
- GraphQL type generation with TypeScript
- Testing frameworks with TypeScript
- Monorepos with TypeScript for cross-framework projects
- CSS-in-JS solutions with TypeScript support

---

# Performance Optimization

## Build Performance in TypeScript

### Understanding TypeScript Build Performance

TypeScript provides powerful static type checking and IDE support, but as projects grow, build times can become a bottleneck in the development workflow. Efficient build configuration is essential for maintaining developer productivity in large TypeScript projects.

**Key Points**

- Build performance directly impacts developer productivity
- TypeScript compilation involves several stages: parsing, type checking, transformation, and emitting JavaScript
- Different strategies address different parts of the build pipeline
- Modern TypeScript provides multiple optimization techniques

### TypeScript Compiler Internals

To optimize TypeScript build performance, it's helpful to understand how the TypeScript compiler (tsc) works:

1. **Parsing**: Source files are parsed into an Abstract Syntax Tree (AST)
2. **Type Checking**: The compiler creates a type system representation and validates it
3. **Transformation**: The AST is transformed according to configuration options
4. **Emitting**: JavaScript code, source maps, and declaration files are generated

The most time-consuming phase is typically type checking, especially in projects with complex type relationships.

### Incremental Compilation

Incremental compilation is one of the most effective ways to improve build performance by reusing information from previous compilations.

**Key Points**

- Enabled with the `incremental` flag in tsconfig.json
- Creates a `.tsbuildinfo` file to track dependency graphs and file changes
- Only recompiles files that have changed or are affected by changes
- Can significantly reduce build times in large projects

Enable incremental compilation in your tsconfig.json:

```json
{
  "compilerOptions": {
    "incremental": true,
    "tsBuildInfoFile": "./buildcache/.tsbuildinfo",
    // Other options...
  }
}
```

The `tsBuildInfoFile` option lets you specify where the build information is stored, which is useful for avoiding source control conflicts.

**Example** A project with 500 TypeScript files might take 10-15 seconds for a full build. With incremental compilation, subsequent builds after small changes might take only 1-2 seconds.

### Project References

Project references allow you to structure your TypeScript project into smaller, interconnected subprojects, each with its own tsconfig.json file.

**Key Points**

- Enables better code organization in large codebases
- Allows partial builds of only affected projects
- Enforces logical boundaries between components
- Works well with incremental compilation

Setting up project references involves:

1. Dividing your codebase into logical projects
2. Creating a tsconfig.json for each project
3. Using the `references` array to define dependencies between projects
4. Using the `composite` flag in referenced projects

```typescript
// Root tsconfig.json
{
  "files": [],
  "references": [
    { "path": "./packages/core" },
    { "path": "./packages/utils" },
    { "path": "./packages/api" }
  ]
}

// packages/core/tsconfig.json
{
  "compilerOptions": {
    "composite": true,
    "declaration": true,
    "outDir": "./dist",
    "rootDir": "./src",
    // Other options...
  },
  "include": ["src/**/*"]
}

// packages/api/tsconfig.json
{
  "compilerOptions": {
    "composite": true,
    "declaration": true,
    "outDir": "./dist",
    "rootDir": "./src",
    // Other options...
  },
  "references": [
    { "path": "../core" },
    { "path": "../utils" }
  ],
  "include": ["src/**/*"]
}
```

Building with project references:

```bash
# Build all projects
tsc -b

# Build specific project and dependencies
tsc -b packages/api

# Clean and build
tsc -b --clean packages/api
```

### Optimizing tsconfig.json

Your TypeScript configuration can significantly impact build performance. Here are the most important settings to consider:

**Key Points**

- Include only necessary files
- Use appropriate lib and target settings
- Disable unnecessary type checking options for development builds
- Consider separate configs for development and production

```json
{
  "compilerOptions": {
    // Performance-related options
    "incremental": true,
    "skipLibCheck": true,
    "sourceMap": false,
    "inlineSourceMap": false,

    // Limit type checking scope
    "types": ["node", "jest"],
    "skipDefaultLibCheck": true,
    
    // Essential type checking for development
    "noImplicitAny": true,
    "strictNullChecks": true,
    
    // Disable expensive checks during development
    "strict": false,
    "noUnusedLocals": false,
    "noUnusedParameters": false,
    
    // Output settings
    "target": "ES2020",
    "module": "ESNext",
    "moduleResolution": "node",
    "outDir": "./dist"
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "**/*.test.ts", "**/*.spec.ts"]
}
```

For production builds, you might want a separate, stricter configuration:

```json
{
  "extends": "./tsconfig.json",
  "compilerOptions": {
    "strict": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "sourceMap": true
  }
}
```

### Build Caching Strategies

Beyond TypeScript's built-in incremental compilation, you can implement additional caching strategies:

**Key Points**

- Use build tools with caching capabilities
- Implement file-based caching for expensive operations
- Consider distributed caching for CI environments

Example using a build cache with ts-loader in webpack:

```javascript
// webpack.config.js
module.exports = {
  // ...
  module: {
    rules: [
      {
        test: /\.tsx?$/,
        use: [
          {
            loader: 'ts-loader',
            options: {
              transpileOnly: true, // Skip type checking for faster builds
              experimentalWatchApi: true, // Use filesystem watching
              compilerOptions: {
                // Can override tsconfig options here
              }
            }
          }
        ],
        exclude: /node_modules/
      }
    ]
  },
  // Optional: Use cache for faster rebuilds
  cache: {
    type: 'filesystem',
    buildDependencies: {
      config: [__filename]
    }
  }
};
```

### TypeScript Watch Mode Optimizations

TypeScript's watch mode (`tsc --watch` or `tsc -w`) can be optimized for faster incremental builds during development.

**Key Points**

- Use the `watchOptions` in tsconfig.json to configure watch behavior
- Configure appropriate polling settings based on your development environment
- Optimize filesystem watching to reduce unnecessary rebuilds

```json
{
  "compilerOptions": {
    // Standard options...
  },
  "watchOptions": {
    "watchFile": "useFsEvents",
    "watchDirectory": "useFsEvents",
    "fallbackPolling": "dynamicPriority",
    "synchronousWatchDirectory": true,
    "excludeDirectories": ["**/node_modules", "dist"]
  }
}
```

### Parallelizing TypeScript Builds

For very large projects, parallelizing the build process can lead to significant performance improvements.

**Key Points**

- Project references inherently support parallel builds
- Use thread pools for parallelizing type checking
- Consider worker threads for CPU-intensive operations

Example using fork-ts-checker-webpack-plugin with multiple workers:

```javascript
// webpack.config.js
const ForkTsCheckerWebpackPlugin = require('fork-ts-checker-webpack-plugin');

module.exports = {
  // ...
  module: {
    rules: [
      {
        test: /\.tsx?$/,
        use: [
          {
            loader: 'ts-loader',
            options: {
              transpileOnly: true // Skip type checking in loader
            }
          }
        ],
        exclude: /node_modules/
      }
    ]
  },
  plugins: [
    new ForkTsCheckerWebpackPlugin({
      typescript: {
        diagnosticOptions: {
          semantic: true,
          syntactic: true
        },
        mode: 'write-references'
      },
      issue: {
        include: [
          { file: '../src/**/*.{ts,tsx}' }
        ],
        exclude: [
          { file: '**/*.spec.{ts,tsx}' }
        ]
      },
      // Run type checking in multiple processes
      async: true
    })
  ]
};
```

### Transpile-Only Mode

For the fastest possible builds during development, you can use transpile-only mode, which skips type checking entirely.

**Key Points**

- Significantly faster builds at the cost of type safety
- Best used in watch mode with a separate type checking process
- Can be combined with IDE type checking for real-time feedback

Example with ts-node for development:

```json
// package.json
{
  "scripts": {
    "start": "ts-node --transpile-only src/index.ts",
    "type-check": "tsc --noEmit",
    "build": "tsc"
  }
}
```

### Measuring and Profiling Build Performance

To effectively optimize build performance, you need to measure it first:

**Key Points**

- Use TypeScript's `--diagnostics` and `--extendedDiagnostics` flags
- Implement timing hooks in build scripts
- Profile memory usage to identify potential bottlenecks

```bash
# Get basic timing information
tsc --diagnostics

# Get detailed timing for compiler phases
tsc --extendedDiagnostics

# Generate a trace file for analysis
tsc --generateTrace trace_output_dir
```

Custom build timing script:

```typescript
// build-timer.ts
import { execSync } from 'child_process';
import * as fs from 'fs';

const startTime = Date.now();
console.log('Starting TypeScript build...');

try {
  execSync('tsc -p tsconfig.prod.json', { stdio: 'inherit' });
  const endTime = Date.now();
  const duration = (endTime - startTime) / 1000;
  
  console.log(`Build completed in ${duration.toFixed(2)} seconds`);
  
  // Append to build history
  fs.appendFileSync(
    'build-times.log',
    `${new Date().toISOString()},${duration.toFixed(2)}\n`
  );
} catch (error) {
  console.error('Build failed:', error);
  process.exit(1);
}
```

### Type-Checking in CI Pipelines

Continuous Integration (CI) pipelines can become bottlenecked by TypeScript compilation. Here are strategies to improve CI performance:

**Key Points**

- Cache TypeScript compilation artifacts between CI runs
- Run type checking in parallel with other CI tasks
- Use project references for partial builds in monorepos

Example GitHub Actions workflow with caching:

```yaml
name: TypeScript Build

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v3
    
    - name: Use Node.js
      uses: actions/setup-node@v3
      with:
        node-version: '18'
        
    - name: Cache node modules
      uses: actions/cache@v3
      with:
        path: ~/.npm
        key: ${{ runner.os }}-node-${{ hashFiles('**/package-lock.json') }}
        restore-keys: |
          ${{ runner.os }}-node-
          
    - name: Cache TypeScript incremental build
      uses: actions/cache@v3
      with:
        path: '**/buildcache'
        key: ${{ runner.os }}-tsbuild-${{ github.sha }}
        restore-keys: |
          ${{ runner.os }}-tsbuild-
          
    - name: Install dependencies
      run: npm ci
      
    - name: Build TypeScript
      run: npm run build
```

### Optimizing TypeScript in Monorepos

Monorepos present unique challenges for TypeScript build performance due to their size and interdependencies.

**Key Points**

- Leverage project references for clear dependency boundaries
- Use Nx, Rush, or Turborepo for intelligent caching and task orchestration
- Implement workspace-aware TypeScript configurations

Example using Nx for optimized TypeScript builds:

```typescript
// nx.json
{
  "npmScope": "my-org",
  "tasksRunnerOptions": {
    "default": {
      "runner": "@nrwl/nx-cloud",
      "options": {
        "cacheableOperations": ["build", "test", "lint"],
        "accessToken": "your-access-token"
      }
    }
  },
  "targetDefaults": {
    "build": {
      "dependsOn": ["^build"]
    }
  }
}

// workspace.json
{
  "version": 2,
  "projects": {
    "core": {
      "root": "packages/core",
      "sourceRoot": "packages/core/src",
      "projectType": "library",
      "targets": {
        "build": {
          "executor": "@nrwl/js:tsc",
          "outputs": ["{options.outputPath}"],
          "options": {
            "outputPath": "dist/packages/core",
            "tsConfig": "packages/core/tsconfig.lib.json",
            "packageJson": "packages/core/package.json",
            "main": "packages/core/src/index.ts"
          }
        }
      }
    },
    "api": {
      "root": "packages/api",
      "sourceRoot": "packages/api/src",
      "projectType": "application",
      "targets": {
        "build": {
          "executor": "@nrwl/node:webpack",
          "outputs": ["{options.outputPath}"],
          "options": {
            "outputPath": "dist/packages/api",
            "tsConfig": "packages/api/tsconfig.app.json",
            "main": "packages/api/src/main.ts"
          }
        }
      }
    }
  }
}
```

### Real-World Examples

Let's look at some real-world examples of TypeScript build performance optimizations:

**Example 1: Microsoft VS Code** VS Code is a large TypeScript codebase with over 300,000 lines of TypeScript code.

Build optimization techniques:

- Heavy use of project references
- Custom task orchestration
- Targeted incremental builds
- Separate configurations for different build purposes

**Example 2: Angular Framework** Angular uses a complex TypeScript build system to manage its monorepo structure.

Build optimization techniques:

- Bazel build system for fine-grained caching
- Custom TypeScript transformers
- Selective compilation based on affected files
- Parallelized type checking and transpilation

### Advanced Build Optimizations

For projects that have exhausted standard optimizations, consider these advanced techniques:

**Key Points**

- Custom TypeScript transformers for specialized code generation
- Language Service plugins for project-specific optimizations
- Targeted type checking with type-checking guard files

Example of a custom TypeScript transformer:

```typescript
// custom-transformer.ts
import * as ts from 'typescript';

export default function transformer(program: ts.Program): ts.TransformerFactory<ts.SourceFile> {
  return (context: ts.TransformationContext) => {
    return (sourceFile: ts.SourceFile) => {
      // Only transform specific files
      if (!sourceFile.fileName.includes('/src/')) {
        return sourceFile;
      }
      
      const visitor = (node: ts.Node): ts.Node => {
        // Example: Replace certain patterns for optimization
        if (ts.isCallExpression(node) && 
            ts.isPropertyAccessExpression(node.expression) &&
            node.expression.name.text === 'debugLog') {
          // Remove debug logs in production builds
          return ts.factory.createEmptyStatement();
        }
        
        return ts.visitEachChild(node, visitor, context);
      };
      
      return ts.visitNode(sourceFile, visitor);
    };
  };
}
```

Using the custom transformer with ts-loader:

```javascript
// webpack.config.js
const customTransformer = require('./custom-transformer').default;

module.exports = {
  // ...
  module: {
    rules: [
      {
        test: /\.tsx?$/,
        use: [
          {
            loader: 'ts-loader',
            options: {
              getCustomTransformers: program => ({
                before: [customTransformer(program)]
              })
            }
          }
        ]
      }
    ]
  }
};
```

### Conclusion

Optimizing TypeScript build performance is essential for maintaining developer productivity in large projects. By implementing incremental compilation, project references, and optimized tsconfig settings, most projects can achieve significant build time improvements. For more complex scenarios, advanced techniques like custom transformers and specialized build tools can provide additional optimizations.

The key is to match your optimization strategy to your specific project needs and development workflow, focusing on the areas that will provide the greatest benefit.

### Related Topics

- TypeScript bundlers (esbuild, swc, Vite) for faster development experience
- Migrating from tsc to faster TypeScript compilers
- Advanced TypeScript project architecture
- Memory optimization for TypeScript compiler
- TypeScript build visualization tools

---

## Runtime Performance

### Understanding Performance Optimization

Runtime performance optimization focuses on enhancing application speed, responsiveness, and resource efficiency. For web applications built with TypeScript, optimizing runtime performance ensures smoother user experiences, reduced loading times, and better scalability.

### Memory Management

Memory management is critical for preventing leaks, reducing garbage collection pauses, and maintaining consistent application performance over time.

#### Memory Leaks in TypeScript Applications

Memory leaks occur when references to objects are unintentionally retained after they're no longer needed:

```typescript
// Memory leak example
class ResourceManager {
  private heavyResources: Array<HeavyResource> = [];
  
  public loadResource(id: string): void {
    const resource = new HeavyResource(id);
    this.heavyResources.push(resource);
    // No mechanism to remove resources when they're no longer needed
  }
}
```

#### Closures and Event Listeners

Closure-related memory leaks are common in TypeScript applications:

```typescript
// Potential memory leak with closures and event listeners
function setupEventHandlers(element: HTMLElement, data: LargeData): void {
  element.addEventListener('click', () => {
    console.log(data); // Captures reference to data in closure
  });
  // No cleanup - if element persists but should release data, we have a leak
}

// Fixed version with cleanup
function setupEventHandlersFixed(element: HTMLElement, data: LargeData): () => void {
  const handler = () => {
    console.log(data);
  };
  
  element.addEventListener('click', handler);
  
  // Return cleanup function
  return () => {
    element.removeEventListener('click', handler);
  };
}
```

#### WeakMaps and WeakSets

TypeScript supports WeakMaps and WeakSets for better memory management:

```typescript
// Using WeakMap to prevent memory leaks
const resourceMetadata = new WeakMap<Element, ResourceData>();

function attachDataToElement(element: HTMLElement, data: ResourceData): void {
  resourceMetadata.set(element, data);
  // When element is garbage collected, the data will be too
}

// Contrast with a regular Map which would prevent garbage collection
const regularMap = new Map<Element, ResourceData>();
```

#### Profiling and Monitoring

TypeScript applications can be profiled using browser DevTools:

```typescript
// Adding performance marks in TypeScript
function processData(data: LargeData[]): ProcessedResult {
  performance.mark('processStart');
  
  // Processing logic here
  const result = data.map(item => transform(item));
  
  performance.mark('processEnd');
  performance.measure('processTime', 'processStart', 'processEnd');
  
  return result;
}
```

#### Memory Management in Framework Contexts

```typescript
// React with TypeScript - cleanup in useEffect
function DataComponent({ id }: { id: string }) {
  useEffect(() => {
    const controller = new AbortController();
    const signal = controller.signal;
    
    fetchData(id, { signal })
      .then(data => setState(data))
      .catch(err => setError(err));
    
    // Cleanup function prevents memory leaks
    return () => {
      controller.abort();
    };
  }, [id]);
}
```

**Key Points**:

- Use WeakMaps/WeakSets when mapping objects to additional data
- Always clean up event listeners, subscriptions, and intervals
- Implement proper disposal patterns for resources
- Profile memory usage to identify leaks

### Reducing Bundle Size

Smaller bundle sizes lead to faster load times, parse times, and execution times, especially on mobile devices with limited resources.

#### TypeScript Configuration for Smaller Output

Optimize your `tsconfig.json` for smaller output:

```json
{
  "compilerOptions": {
    "target": "es2020",
    "module": "esnext",
    "moduleResolution": "node",
    "importHelpers": true,
    "noEmitHelpers": true
  }
}
```

Using `importHelpers` with `tslib` reduces code duplication:

```typescript
// Without importHelpers
class MyClass extends BaseClass {
  // TypeScript emits helper functions for each class
}

// With importHelpers
import { __extends } from "tslib";
// TypeScript uses imported helpers instead of emitting them
```

#### Optimizing Dependencies

Analyze and optimize your dependencies:

```typescript
// Instead of importing full lodash
import _ from 'lodash'; // 💔 Imports everything

// Use specific imports
import throttle from 'lodash/throttle'; // ✅ Only imports what you need
```

Use bundle analysis tools:

```bash
# Install webpack-bundle-analyzer
npm install --save-dev webpack-bundle-analyzer

# Add to webpack config
const BundleAnalyzerPlugin = require('webpack-bundle-analyzer').BundleAnalyzerPlugin;
module.exports = {
  plugins: [
    new BundleAnalyzerPlugin()
  ]
};
```

#### Handling Assets and Media

Optimize assets loading:

```typescript
// Eager loading all images
import largeImage1 from '../assets/large-image-1.jpg';
import largeImage2 from '../assets/large-image-2.jpg';
// ...

// Better: Lazy load images as needed
const largeImage = (id: number) => import(`../assets/large-image-${id}.jpg`);

function loadImageWhenNeeded(id: number) {
  largeImage(id).then(module => {
    const img = document.createElement('img');
    img.src = module.default;
    document.body.appendChild(img);
  });
}
```

#### Modern Output Formats

Use modern JavaScript features and module formats:

```typescript
// tsconfig.json
{
  "compilerOptions": {
    "target": "es2020",
    "module": "esnext"
  }
}

// webpack.config.js output configuration
module.exports = {
  output: {
    filename: '[name].[contenthash].js',
    chunkFilename: '[name].[contenthash].js'
  }
};
```

**Key Points**:

- Use specific imports instead of importing entire libraries
- Analyze bundle content regularly to identify bloat
- Optimize asset loading and processing
- Configure TypeScript for minimal output

### Code Splitting

Code splitting divides your application into smaller chunks that can be loaded on demand, improving initial load performance and enabling more efficient caching.

#### Dynamic Imports in TypeScript

TypeScript 2.4+ supports dynamic imports for code splitting:

```typescript
// Static import loads at startup
import { HeavyComponent } from './HeavyComponent';

// Dynamic import loads on demand
const loadHeavyComponent = () => import('./HeavyComponent');

// Usage with async/await
async function renderWhenNeeded() {
  const { HeavyComponent } = await import('./HeavyComponent');
  const instance = new HeavyComponent();
  instance.render();
}
```

#### Route-Based Code Splitting

Implement route-based code splitting in different frameworks:

```typescript
// React with React Router and TypeScript
import { lazy, Suspense } from 'react';
import { Routes, Route } from 'react-router-dom';

// Lazy loaded components
const Home = lazy(() => import('./pages/Home'));
const Dashboard = lazy(() => import('./pages/Dashboard'));
const Settings = lazy(() => import('./pages/Settings'));

function App() {
  return (
    <Suspense fallback={<div>Loading...</div>}>
      <Routes>
        <Route path="/" element={<Home />} />
        <Route path="/dashboard" element={<Dashboard />} />
        <Route path="/settings" element={<Settings />} />
      </Routes>
    </Suspense>
  );
}
```

```typescript
// Angular with TypeScript
// app-routing.module.ts
import { NgModule } from '@angular/core';
import { Routes, RouterModule } from '@angular/router';

const routes: Routes = [
  {
    path: 'dashboard',
    loadChildren: () => import('./dashboard/dashboard.module').then(m => m.DashboardModule)
  },
  {
    path: 'settings',
    loadChildren: () => import('./settings/settings.module').then(m => m.SettingsModule)
  }
];

@NgModule({
  imports: [RouterModule.forRoot(routes)],
  exports: [RouterModule]
})
export class AppRoutingModule { }
```

```typescript
// Vue with TypeScript
// router.ts
import { createRouter, createWebHistory } from 'vue-router';
import type { RouteRecordRaw } from 'vue-router';

const routes: RouteRecordRaw[] = [
  {
    path: '/',
    component: () => import('./views/Home.vue')
  },
  {
    path: '/dashboard',
    component: () => import('./views/Dashboard.vue')
  }
];

const router = createRouter({
  history: createWebHistory(),
  routes
});

export default router;
```

#### Component-Level Code Splitting

Split individual components for more granular loading:

```typescript
// React with TypeScript
import { lazy, Suspense, useState } from 'react';

// Only load heavy component when needed
const HeavyDataTable = lazy(() => import('./components/HeavyDataTable'));

function Dashboard() {
  const [showTable, setShowTable] = useState(false);
  
  return (
    <div>
      <button onClick={() => setShowTable(true)}>Show Data Table</button>
      
      {showTable && (
        <Suspense fallback={<div>Loading table...</div>}>
          <HeavyDataTable />
        </Suspense>
      )}
    </div>
  );
}
```

#### Vendor Chunk Optimization

Separate application code from vendor code:

```typescript
// webpack.config.js with TypeScript
module.exports = {
  // ...
  optimization: {
    splitChunks: {
      chunks: 'all',
      maxInitialRequests: Infinity,
      minSize: 0,
      cacheGroups: {
        vendor: {
          test: /[\\/]node_modules[\\/]/,
          name(module) {
            // Get the name of the package
            const packageName = module.context.match(
              /[\\/]node_modules[\\/](.*?)([\\/]|$)/
            )[1];
            
            // Create nice chunk names
            return `vendor.${packageName.replace('@', '')}`;
          }
        }
      }
    }
  }
};
```

**Key Points**:

- Use dynamic imports for code splitting in TypeScript
- Implement route-based splitting for page components
- Split large components that aren't needed on initial load
- Optimize vendor chunks for better caching

### Tree Shaking with TypeScript

Tree shaking eliminates unused code from the final bundle, resulting in smaller file sizes and improved performance.

#### Enabling Tree Shaking in TypeScript

Configure TypeScript for effective tree shaking:

```json
// tsconfig.json
{
  "compilerOptions": {
    "module": "esnext",
    "moduleResolution": "node",
    "target": "es2015",
    "esModuleInterop": true
  }
}
```

#### Module Import Patterns

Use import patterns that enable tree shaking:

```typescript
// Bad: Imports entire module even if you only use one function
import * as utils from './utils';
utils.formatDate(new Date());

// Good: Only imports what's needed
import { formatDate } from './utils';
formatDate(new Date());
```

#### Side Effect Management

Manage side effects for better tree shaking:

```typescript
// package.json
{
  "name": "my-package",
  "sideEffects": false  // Or ["./src/polyfills.ts"]
}
```

Side effect examples:

```typescript
// This has side effects and can't be safely tree-shaken
import './polyfills';

// This modifies global Window and has side effects
import './extend-window';
window.customProperty = 'value';

// This pure function can be tree-shaken if unused
export function calculateTotal(items: { price: number }[]): number {
  return items.reduce((sum, item) => sum + item.price, 0);
}
```

#### Pure Function Annotations

Mark functions as pure in TypeScript:

```typescript
// Using /*@__PURE__*/ annotation for pure function calls
const result = /*@__PURE__*/ expensiveComputation(data);

// Without annotation, might not be removed if expensiveComputation isn't recognized as pure
```

#### TypeScript-Specific Tree Shaking Challenges

TypeScript introduces some challenges for tree shaking:

```typescript
// Enums can prevent optimal tree shaking
enum Direction {
  Up,
  Down,
  Left,
  Right
}

// Better for tree shaking:
const Direction = {
  Up: 'UP',
  Down: 'DOWN',
  Left: 'LEFT',
  Right: 'RIGHT'
} as const;

type Direction = typeof Direction[keyof typeof Direction];
```

#### Tree Shaking TypeScript Decorators

Decorators can complicate tree shaking:

```typescript
// Decorator factory creates closure that can prevent tree shaking
function Logger() {
  return function (target: any) {
    console.log(`Class: ${target.name}`);
  };
}

// Applied decorator might prevent class from being tree-shaken
@Logger()
class Example {
  // Class implementation
}
```

**Key Points**:

- Use ES modules with named exports/imports
- Configure TypeScript for ECMAScript modules
- Set appropriate sideEffects flags
- Use pure function annotations where needed
- Be cautious with TypeScript-specific features like decorators and enums

### Performance Measurement and Monitoring

To validate optimizations, measure performance consistently:

#### Browser Performance APIs

Use the Performance API from TypeScript:

```typescript
interface PerformanceMeasure {
  name: string;
  startTime: number;
  duration: number;
}

function measureExecution<T>(fn: () => T, name: string): T {
  performance.mark(`${name}-start`);
  const result = fn();
  performance.mark(`${name}-end`);
  performance.measure(name, `${name}-start`, `${name}-end`);
  
  // Log results
  const measures = performance.getEntriesByType('measure')
    .filter(measure => measure.name === name) as PerformanceMeasure[];
  
  console.log(`${name} took ${measures[0].duration.toFixed(2)}ms`);
  
  return result;
}

// Usage
const result = measureExecution(() => {
  // Expensive operation
  return processLargeDataSet(data);
}, 'data-processing');
```

#### Core Web Vitals Monitoring

Monitor Core Web Vitals in TypeScript applications:

```typescript
// Reporting Web Vitals in a React TypeScript app
import { getCLS, getFID, getLCP } from 'web-vitals';

function sendToAnalytics(metric: { name: string; value: number }) {
  // Send metrics to your analytics service
  console.log(metric);
}

// Report Core Web Vitals
getCLS(sendToAnalytics);
getFID(sendToAnalytics);
getLCP(sendToAnalytics);
```

#### Custom Performance Metrics

Create custom metrics for business-specific performance:

```typescript
// Define custom performance metrics
interface AppPerformanceMetrics {
  timeToInteractive: number;
  dataLoadTime: number;
  renderTime: number;
}

class PerformanceMonitor {
  private metrics: Partial<AppPerformanceMetrics> = {};
  
  startTiming(metric: keyof AppPerformanceMetrics): void {
    performance.mark(`${String(metric)}-start`);
  }
  
  endTiming(metric: keyof AppPerformanceMetrics): void {
    const metricName = String(metric);
    performance.mark(`${metricName}-end`);
    performance.measure(metricName, `${metricName}-start`, `${metricName}-end`);
    
    const entries = performance.getEntriesByName(metricName, 'measure');
    if (entries.length > 0) {
      this.metrics[metric] = entries[0].duration;
    }
  }
  
  getMetrics(): Partial<AppPerformanceMetrics> {
    return { ...this.metrics };
  }
  
  reportMetrics(): void {
    // Report to analytics service
    console.log('Performance metrics:', this.metrics);
  }
}
```

**Key Points**:

- Use browser Performance API for accurate timing
- Monitor key metrics like Core Web Vitals
- Create custom metrics for application-specific performance
- Implement consistent measurement practices

### Advanced Optimization Techniques

#### Virtualization for Large Lists

Implement virtualization for better performance with large datasets:

```typescript
// Using react-window with TypeScript
import { FixedSizeList } from 'react-window';
import AutoSizer from 'react-virtualized-auto-sizer';

interface ItemData {
  id: string;
  title: string;
}

interface RowProps {
  index: number;
  style: React.CSSProperties;
  data: ItemData[];
}

const Row = ({ index, style, data }: RowProps) => (
  <div style={style}>
    Item {index}: {data[index].title}
  </div>
);

function VirtualList({ items }: { items: ItemData[] }) {
  return (
    <div style={{ height: '100vh', width: '100%' }}>
      <AutoSizer>
        {({ height, width }) => (
          <FixedSizeList
            height={height}
            width={width}
            itemSize={35}
            itemCount={items.length}
            itemData={items}
          >
            {Row}
          </FixedSizeList>
        )}
      </AutoSizer>
    </div>
  );
}
```

#### Web Workers with TypeScript

Offload heavy processing to web workers:

```typescript
// worker.ts
const ctx: Worker = self as any;

ctx.addEventListener('message', (event) => {
  const { data, id } = event.data;
  
  // Perform heavy calculation
  const result = performExpensiveCalculation(data);
  
  // Send back result
  ctx.postMessage({ result, id });
});

function performExpensiveCalculation(data: number[]): number {
  return data.reduce((sum, val) => sum + Math.pow(val, 2), 0);
}

// main.ts
const worker = new Worker(new URL('./worker.ts', import.meta.url));

function calculateWithWorker(data: number[]): Promise<number> {
  return new Promise((resolve) => {
    const id = Date.now();
    
    // One-time handler for this specific calculation
    const handler = (event: MessageEvent) => {
      if (event.data.id === id) {
        worker.removeEventListener('message', handler);
        resolve(event.data.result);
      }
    };
    
    worker.addEventListener('message', handler);
    worker.postMessage({ data, id });
  });
}

// Usage
calculateWithWorker([1, 2, 3, 4, 5])
  .then(result => console.log('Result:', result));
```

#### Service Worker Caching

Implement service workers for runtime caching:

```typescript
// service-worker.ts
/// <reference lib="webworker" />

declare const self: ServiceWorkerGlobalScope;

const CACHE_NAME = 'app-cache-v1';
const ASSETS_TO_CACHE = [
  '/',
  '/index.html',
  '/main.js',
  '/styles.css'
];

self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then(cache => cache.addAll(ASSETS_TO_CACHE))
  );
});

self.addEventListener('fetch', (event) => {
  event.respondWith(
    caches.match(event.request)
      .then(cachedResponse => {
        // Return cached response if found
        if (cachedResponse) {
          return cachedResponse;
        }
        
        // Otherwise fetch from network
        return fetch(event.request)
          .then(response => {
            // Don't cache non-success responses
            if (!response || response.status !== 200) {
              return response;
            }
            
            // Clone the response to cache it for later
            const responseToCache = response.clone();
            caches.open(CACHE_NAME)
              .then(cache => {
                cache.put(event.request, responseToCache);
              });
            
            return response;
          });
      })
  );
});
```

#### Optimizing Re-renders in Framework Components

Optimize component rendering:

```typescript
// React optimizations with TypeScript
import React, { memo, useCallback, useMemo } from 'react';

interface UserCardProps {
  user: {
    id: string;
    name: string;
    email: string;
  };
  onSelect: (id: string) => void;
}

// Memoized component that only re-renders when props actually change
const UserCard = memo(({ user, onSelect }: UserCardProps) => {
  // Memoized callback to prevent recreating on parent renders
  const handleSelect = useCallback(() => {
    onSelect(user.id);
  }, [user.id, onSelect]);
  
  // Memoized computed value
  const displayName = useMemo(() => {
    return `${user.name} (${user.email.split('@')[0]})`;
  }, [user.name, user.email]);
  
  return (
    <div onClick={handleSelect}>
      <h3>{displayName}</h3>
    </div>
  );
});
```

```typescript
// Vue optimizations with TypeScript
<script setup lang="ts">
import { computed, defineProps, withDefaults } from 'vue';

interface Props {
  user: {
    id: string;
    name: string;
    email: string;
  };
  onSelect?: (id: string) => void;
}

const props = withDefaults(defineProps<Props>(), {
  onSelect: () => {}
});

// Computed property for expensive calculations
const displayName = computed(() => {
  return `${props.user.name} (${props.user.email.split('@')[0]})`;
});

function handleSelect(): void {
  props.onSelect(props.user.id);
}
</script>

<template>
  <div @click="handleSelect">
    <h3>{{ displayName }}</h3>
  </div>
</template>
```

**Key Points**:

- Use virtualization for long lists and tables
- Offload CPU-intensive work to web workers
- Implement service workers for caching
- Optimize component rendering with memoization

### Common Performance Pitfalls in TypeScript Applications

#### Type Systems and Runtime Performance

TypeScript's type system doesn't directly impact runtime performance:

```typescript
// This complex type doesn't affect runtime performance
type RecursivePartial<T> = {
  [P in keyof T]?: T[P] extends (infer U)[]
    ? RecursivePartial<U>[]
    : T[P] extends object
    ? RecursivePartial<T[P]>
    : T[P];
};

// At runtime, this is just a regular JavaScript object
interface ComplexState {
  user: {
    profile: {
      name: string;
      settings: Array<{
        id: string;
        value: unknown;
      }>;
    };
  };
}

// This is just a plain JavaScript object at runtime
const state: RecursivePartial<ComplexState> = {
  user: {
    profile: {
      name: 'John'
    }
  }
};
```

#### Avoiding String Enums

String enums can increase bundle size:

```typescript
// String enum adds extra code
enum LogLevel {
  INFO = "INFO",
  WARN = "WARN",
  ERROR = "ERROR"
}

// More bundle-efficient alternative
const LogLevel = {
  INFO: "INFO",
  WARN: "WARN",
  ERROR: "ERROR"
} as const;

type LogLevel = typeof LogLevel[keyof typeof LogLevel];
```

#### JSON Parsing and Stringifying

Optimize JSON handling:

```typescript
// Avoid redundant parsing/stringifying
function updateLocalStorage<T>(key: string, updater: (prev: T) => T): void {
  // Inefficient approach
  const data = JSON.parse(localStorage.getItem(key) || '{}');
  const updated = updater(data as T);
  localStorage.setItem(key, JSON.stringify(updated));
  
  // More efficient approach - parse once, stringify once
  let data: T;
  try {
    data = JSON.parse(localStorage.getItem(key) || '{}') as T;
  } catch {
    data = {} as T;
  }
  
  const updated = updater(data);
  localStorage.setItem(key, JSON.stringify(updated));
}
```

#### Improper Async/Await Usage

Async code can impact performance if not handled correctly:

```typescript
// Inefficient sequential async calls
async function fetchAllUserData(userIds: string[]): Promise<UserData[]> {
  const results: UserData[] = [];
  
  // Sequential execution - each waits for previous
  for (const id of userIds) {
    const userData = await fetchUserData(id);
    results.push(userData);
  }
  
  return results;
}

// More efficient parallel fetching
async function fetchAllUserDataParallel(userIds: string[]): Promise<UserData[]> {
  // Execute all promises in parallel
  const promises = userIds.map(id => fetchUserData(id));
  
  // Wait for all to complete
  return Promise.all(promises);
}
```

**Key Points**:

- TypeScript types don't affect runtime performance
- Optimize enum usage for smaller bundles
- Be cautious with JSON parsing/stringifying in performance-critical code
- Use Promise.all for concurrent operations

### Framework-Specific Performance Tips

#### React with TypeScript

```typescript
// Optimize context to prevent unnecessary renders
import { createContext, useContext, useState, useMemo, ReactNode } from 'react';

interface ThemeContextType {
  theme: 'light' | 'dark';
  toggleTheme: () => void;
}

const ThemeContext = createContext<ThemeContextType | undefined>(undefined);

export function ThemeProvider({ children }: { children: ReactNode }) {
  const [theme, setTheme] = useState<'light' | 'dark'>('light');
  
  // Memoize the context value to prevent unnecessary rerenders
  const contextValue = useMemo(() => {
    return {
      theme,
      toggleTheme: () => setTheme(prev => prev === 'light' ? 'dark' : 'light')
    };
  }, [theme]);
  
  return (
    <ThemeContext.Provider value={contextValue}>
      {children}
    </ThemeContext.Provider>
  );
}

export function useTheme() {
  const context = useContext(ThemeContext);
  if (context === undefined) {
    throw new Error('useTheme must be used within a ThemeProvider');
  }
  return context;
}
```

#### Angular with TypeScript

```typescript
// Optimize Angular change detection
import { Component, OnInit, ChangeDetectionStrategy, Input } from '@angular/core';

@Component({
  selector: 'app-data-grid',
  templateUrl: './data-grid.component.html',
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class DataGridComponent implements OnInit {
  @Input() data!: ReadonlyArray<DataItem>;
  
  // Implement trackBy for ngFor
  trackByFn(index: number, item: DataItem): string {
    return item.id;
  }
  
  ngOnInit(): void {
    // Initialization code
  }
}

// Template usage
// <tr *ngFor="let item of data; trackBy: trackByFn">
```

#### Vue with TypeScript

```typescript
// Vue 3 with performance optimizations
<script setup lang="ts">
import { ref, computed, onMounted, onUnmounted } from 'vue';

// Heavy CPU-bound calculation
const items = ref<number[]>([]);
const processedItems = computed(() => {
  console.log('Computing processed items');
  return items.value.map(item => expensiveProcess(item));
});

// Optimize event listeners
let resizeObserver: ResizeObserver | null = null;

onMounted(() => {
  // Use ResizeObserver instead of window resize
  resizeObserver = new ResizeObserver(entries => {
    // Handle resize logic
  });
  
  if (containerRef.value) {
    resizeObserver.observe(containerRef.value);
  }
});

onUnmounted(() => {
  // Clean up resources
  if (resizeObserver) {
    resizeObserver.disconnect();
    resizeObserver = null;
  }
});
</script>
```

**Key Points**:

- Use framework-specific optimization techniques
- Understand the rendering and update lifecycle of your framework
- Follow framework-specific best practices for performance
- Implement proper change detection strategies

### Future Performance Optimizations

#### WebAssembly Integration with TypeScript

```typescript
// TypeScript wrapper for WebAssembly module
interface WasmExports {
  fibonacci: (n: number) => number;
  factorialize: (n: number) => number;
}

async function loadWasmModule(): Promise<WasmExports> {
  const response = await fetch('/math-utils.wasm');
  const buffer = await response.arrayBuffer();
  const wasmModule = await WebAssembly.instantiate(buffer);
  
  return wasmModule.instance.exports as unknown as WasmExports;
}

// Usage in TypeScript
let wasmExports: WasmExports;

async function initWasm() {
  wasmExports = await loadWasmModule();
  console.log('WebAssembly module loaded');
}

function calculateFibonacci(n: number): number {
  if (!wasmExports) {
    throw new Error('WebAssembly module not loaded');
  }
  
  return wasmExports.fibonacci(n);
}
```

#### Leveraging Modern Browser APIs

```typescript
// Using modern browser APIs from TypeScript
async function processImage(file: File): Promise<ImageData> {
  // Create bitmap without DOM manipulation
  const bitmap = await createImageBitmap(file);
  
  // Use OffscreenCanvas for processing
  const canvas = new OffscreenCanvas(bitmap.width, bitmap.height);
  const ctx = canvas.getContext('2d');
  
  if (!ctx) {
    throw new Error('Could not get 2D context');
  }
  
  ctx.drawImage(bitmap, 0, 0);
  
  // Apply processing with filters
  ctx.filter = 'grayscale(1)';
  ctx.drawImage(bitmap, 0, 0);
  
  return ctx.getImageData(0, 0, bitmap.width, bitmap.height);
}
```

**Key Points**:

- WebAssembly can boost performance for CPU-intensive tasks
- Modern browser APIs can improve runtime performance
- Consider edge computing for distributed workloads
- Stay updated with new ECMAScript features for performance

### Related Topics

For further exploration, consider these related performance optimization topics:

- Server-side rendering (SSR) with TypeScript
- Static site generation for better performance
- Progressive Web App (PWA) implementation with TypeScript
- Browser rendering optimization techniques
- TypeScript compilation optimization and build tools
- Web Vitals optimization strategies
- Performance testing and regression prevention

---

# Advanced Configuration and Tools

## Advanced tsconfig Options

### Understanding tsconfig.json's Role in TypeScript Projects

The tsconfig.json file serves as the command center for TypeScript projects, controlling how the TypeScript compiler processes code. Beyond basic configuration, advanced options enable fine-tuned control over type checking, module resolution, and code generation. Mastering these options allows developers to optimize TypeScript for specific project requirements, from strict enterprise applications to flexible rapid prototyping.

**Key Points**

- tsconfig.json is the central configuration file for TypeScript projects
- Options can be tailored to specific project requirements and team preferences
- Advanced options affect type checking strictness, module resolution, and compilation behavior
- Well-configured tsconfig files improve code quality, performance, and developer experience

### Strict Mode Options

TypeScript's strict mode is a powerful feature that enables comprehensive static type checking. Rather than a single flag, strict mode encompasses multiple type-checking options that can be enabled individually or collectively.

**Key Points**

- The `strict` flag enables all strict type checking options
- Individual strict options can be enabled/disabled to customize type checking
- Strict mode catches more bugs at compile time but requires more explicit type annotations
- Recommended for new projects and projects where type safety is critical

```json
{
  "compilerOptions": {
    // Master switch for all strict type-checking options
    "strict": true,

    // Individual strict checking options
    "noImplicitAny": true,
    "strictNullChecks": true,
    "strictFunctionTypes": true,
    "strictBindCallApply": true,
    "strictPropertyInitialization": true,
    "noImplicitThis": true,
    "useUnknownInCatchVariables": true,
    "alwaysStrict": true
  }
}
```

#### noImplicitAny

The `noImplicitAny` flag prevents variables from being implicitly typed as `any` when TypeScript cannot infer a type.

```typescript
// Error with noImplicitAny: true
function process(data) { // Parameter 'data' implicitly has an 'any' type
  return data.length;
}

// Fixed version
function process(data: string[] | string) {
  return data.length;
}
```

#### strictNullChecks

With `strictNullChecks` enabled, `null` and `undefined` are not part of every type and must be explicitly handled.

```typescript
// Error with strictNullChecks: true
const element = document.getElementById('app');
element.innerHTML = 'Hello'; // Object is possibly 'null'

// Fixed versions
const element = document.getElementById('app');
if (element) {
  element.innerHTML = 'Hello';
}

// Or using non-null assertion (use with caution)
const element = document.getElementById('app')!;
element.innerHTML = 'Hello';

// Or using optional chaining
document.getElementById('app')?.innerHTML = 'Hello';
```

#### strictFunctionTypes

Enables more accurate checking of function parameter types using contravariance instead of bivariance.

```typescript
// With strictFunctionTypes: true
interface Animal {
  name: string;
}

interface Dog extends Animal {
  breed: string;
}

// Function types
type AnimalCallback = (animal: Animal) => void;
type DogCallback = (dog: Dog) => void;

let animalFn: AnimalCallback = (animal) => console.log(animal.name);
let dogFn: DogCallback = (dog) => console.log(dog.breed);

// This is valid - safe to pass more specific function where general one is expected
animalFn = dogFn; // Error with strictFunctionTypes

// This is unsafe - general function doesn't know how to handle Dog-specific properties
dogFn = animalFn; // OK with strictFunctionTypes: false, Error with true
```

#### strictBindCallApply

Ensures the built-in methods `Function.bind`, `Function.call`, and `Function.apply` are invoked with correct argument types.

```typescript
// With strictBindCallApply: true
function greet(name: string, age: number): string {
  return `Hello, ${name}! You are ${age} years old.`;
}

// Error: Expected 2 arguments, but got 1
greet.call(undefined, "John");

// Correct usage
greet.call(undefined, "John", 30);
```

#### strictPropertyInitialization

Ensures class properties are initialized in the constructor or have a definite assignment.

```typescript
// With strictPropertyInitialization: true
class User {
  name: string; // Error: Property 'name' has no initializer and is not definitely assigned
  email: string = ""; // OK: Has initializer
  role?: string; // OK: Optional property
  id!: number; // OK: Definite assignment assertion

  constructor() {
    this.name = "John"; // Would fix the error
  }
}
```

#### noImplicitThis

Flags 'this' expressions with an implied 'any' type.

```typescript
// With noImplicitThis: true
function sayHello() {
  console.log(`Hello, ${this.name}`); // Error: 'this' implicitly has type 'any'
}

// Fixed version
interface Person {
  name: string;
  sayHello(): void;
}

const person: Person = {
  name: "John",
  sayHello() {
    console.log(`Hello, ${this.name}`); // OK: 'this' has type Person
  }
};
```

#### useUnknownInCatchVariables

Makes the type of catch clause variables `unknown` instead of `any`.

```typescript
// With useUnknownInCatchVariables: true
try {
  // Some code that might throw
} catch (error) {
  console.log(error.message); // Error: Object is of type 'unknown'
  
  // Fixed versions
  if (error instanceof Error) {
    console.log(error.message); // OK
  }
  
  // Or type assertion (use with caution)
  console.log((error as Error).message);
}
```

#### alwaysStrict

Ensures files are parsed in ECMAScript strict mode and emit "use strict" directives.

```typescript
// With alwaysStrict: true
// TypeScript emits "use strict"; at the top of generated JS files
function doSomething() {
  // This code runs in strict mode
  // Prevents accidental globals, throws more errors, etc.
}
```

### Module Resolution Options

Module resolution is the process TypeScript uses to figure out what a module import refers to. TypeScript has sophisticated module resolution options for various environments and project structures.

**Key Points**

- Different module resolution strategies work best for different project types
- Path mapping enables custom import paths and project organization
- Base URLs and paths simplify imports in large projects
- Resolution affects both type checking and emitted JavaScript

```json
{
  "compilerOptions": {
    // Module system
    "module": "ESNext",
    "moduleResolution": "NodeNext",
    
    // Module resolution helpers
    "baseUrl": "./",
    "paths": {
      "@app/*": ["src/app/*"],
      "@core/*": ["src/core/*"],
      "@shared/*": ["src/shared/*"]
    },
    
    // Module interop settings
    "esModuleInterop": true,
    "allowSyntheticDefaultImports": true,
    
    // Type resolution
    "types": ["node", "jest"],
    "typeRoots": ["./node_modules/@types", "./src/types"],
    
    // Resolution modifiers
    "resolveJsonModule": true,
    "preserveSymlinks": false,
    "rootDir": "./src",
    "rootDirs": ["./src", "./generated"]
  }
}
```

#### moduleResolution

This option determines how TypeScript resolves modules. The main strategies are:

- `"node"`: Classic Node.js resolution strategy
- `"nodenext"`: Modern Node.js resolution (recommended for new projects)
- `"classic"`: TypeScript's original resolution algorithm (legacy)
- `"bundler"`: For bundler-based environments like Webpack, Vite, etc.

```typescript
// How imports are resolved with moduleResolution: "NodeNext"
import { Component } from './component'; // Resolves to component.ts/component.tsx/component.js/etc.
import { utils } from 'my-library'; // Checks node_modules, follows package.json "exports"

// With baseUrl and paths set
import { UserService } from '@app/services'; // Resolves to src/app/services.ts
```

#### baseUrl and paths

These options enable custom import path mapping:

```json
{
  "compilerOptions": {
    "baseUrl": "./",
    "paths": {
      "@app/*": ["src/app/*"],
      "@core/*": ["src/core/*"],
      "@assets/*": ["src/assets/*"],
      "lib/*": ["node_modules/library-name/dist/*"]
    }
  }
}
```

The above configuration allows imports like:

```typescript
// Instead of relative paths like this:
import { UserComponent } from '../../../app/components/user/user.component';

// You can use paths mapping:
import { UserComponent } from '@app/components/user/user.component';
```

#### typeRoots and types

These options control which type declaration files (.d.ts) are included in your project:

```json
{
  "compilerOptions": {
    "typeRoots": [
      "./node_modules/@types",
      "./src/types"
    ],
    "types": ["node", "jest", "custom-types"]
  }
}
```

- `typeRoots`: Specifies directories where TypeScript should look for type declarations
- `types`: Limits which packages from @types are included (if specified, only the listed packages are included)

Example of a custom type declaration file (src/types/custom-types.d.ts):

```typescript
declare module 'untyped-module' {
  export function doSomething(value: string): number;
  export default class Helper {
    static utility(input: number): string;
  }
}
```

#### resolveJsonModule

Allows importing JSON files directly as modules:

```json
{
  "compilerOptions": {
    "resolveJsonModule": true
  }
}
```

Usage:

```typescript
// Valid with resolveJsonModule: true
import config from './config.json';
console.log(config.apiUrl);
```

#### preserveSymlinks

Controls how TypeScript resolves symlinked packages:

```json
{
  "compilerOptions": {
    "preserveSymlinks": true
  }
}
```

When `true`, TypeScript won't follow symlinks when resolving modules, which can be important in monorepo setups using tools like Yarn workspaces or npm links.

### Advanced Compiler Flags

These options provide fine-grained control over how TypeScript compiles your code, affecting everything from error reporting to code generation.

**Key Points**

- Advanced compiler flags control TypeScript's behavior beyond basic type checking
- Options affect code quality, debugging, build performance, and output format
- Some flags are designed for specific use cases or environments
- Understanding these options enables optimizing TypeScript for specific project needs

```json
{
  "compilerOptions": {
    // Build quality flags
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "exactOptionalPropertyTypes": true,
    "noImplicitReturns": true,
    "noFallthroughCasesInSwitch": true,
    "noUncheckedIndexedAccess": true,
    
    // Emit modification flags
    "removeComments": true,
    "importHelpers": true,
    "downlevelIteration": true,
    "preserveConstEnums": true,
    "declarationMap": true,
    
    // Advanced JavaScript support
    "target": "ES2022",
    "lib": ["ES2022", "DOM", "DOM.Iterable"],
    "experimentalDecorators": true,
    "emitDecoratorMetadata": true,
    
    // Source maps and debugging
    "sourceMap": true,
    "inlineSources": true,
    "inlineSourceMap": false,
    "mapRoot": "./maps",
    
    // Build refinement
    "stripInternal": true,
    "noEmitHelpers": false,
    "preserveValueImports": true,
    "isolatedModules": true
  }
}
```

#### Code Quality Flags

These flags help enforce coding standards and catch potential bugs:

##### noUnusedLocals and noUnusedParameters

Flag unused variables and parameters:

```typescript
// With noUnusedLocals: true
function process() {
  const temp = "unused"; // Error: 'temp' is declared but never used
  return "result";
}

// With noUnusedParameters: true
function greet(name: string, age: number) { // Error: 'age' is declared but never used
  return `Hello, ${name}!`;
}

// Fixed with underscore prefix convention
function greet(name: string, _age: number) {
  return `Hello, ${name}!`;
}
```

##### exactOptionalPropertyTypes

Makes optional property types more precise:

```typescript
// With exactOptionalPropertyTypes: true
interface User {
  name: string;
  email?: string; // Must be string or undefined, not null
}

const user: User = {
  name: "John",
  email: null // Error with exactOptionalPropertyTypes: true
};
```

##### noImplicitReturns

Ensures all code paths in a function return a value:

```typescript
// With noImplicitReturns: true
function getStatus(code: number): string {
  if (code === 200) {
    return "OK";
  } else if (code === 404) {
    return "Not Found";
  }
  // Error: Not all code paths return a value
}

// Fixed version
function getStatus(code: number): string {
  if (code === 200) {
    return "OK";
  } else if (code === 404) {
    return "Not Found";
  }
  return "Unknown Status";
}
```

##### noFallthroughCasesInSwitch

Prevents accidentally falling through case statements in switch blocks:

```typescript
// With noFallthroughCasesInSwitch: true
function process(value: string): number {
  switch (value) {
    case "a":
      console.log("Found A");
      // Error: Fallthrough case in switch
    case "b":
      console.log("Found B");
      return 1;
    default:
      return 0;
  }
}

// Fixed version
function process(value: string): number {
  switch (value) {
    case "a":
      console.log("Found A");
      return 2; // Add return or break
    case "b":
      console.log("Found B");
      return 1;
    default:
      return 0;
  }
}
```

##### noUncheckedIndexedAccess

Makes indexed access (like array[index]) safer by adding undefined to the type:

```typescript
// With noUncheckedIndexedAccess: true
const array = [1, 2, 3];
const item = array[0]; // type is number | undefined

// This would cause an error
const sum = array[0] + array[1]; // Error: Object is possibly undefined

// Fixed versions
// Option 1: Non-null assertion (if you're certain)
const sum1 = array[0]! + array[1]!;

// Option 2: Runtime check
if (array[0] !== undefined && array[1] !== undefined) {
  const sum2 = array[0] + array[1];
}

// Option 3: Default value
const sum3 = (array[0] ?? 0) + (array[1] ?? 0);
```

#### Emit Modification Flags

These options change how JavaScript and declaration files are generated:

##### importHelpers

Uses the `tslib` package to import helper functions instead of generating them inline:

```json
{
  "compilerOptions": {
    "target": "ES5",
    "importHelpers": true
  }
}
```

First, install tslib:

```bash
npm install tslib --save
```

Effect on compiled code:

```typescript
// Original TypeScript
class Example {
  private readonly value: number;
  
  constructor(value: number) {
    this.value = value;
  }
}

// Compiled with importHelpers: false
var Example = /** @class */ (function () {
  function Example(value) {
    this.value = value;
  }
  return Example;
}());

// Compiled with importHelpers: true
import { __classPrivateFieldSet } from "tslib";
var _Example_value;
var Example = /** @class */ (function () {
  function Example(value) {
    _Example_value = { value: void 0 };
    __classPrivateFieldSet(this, _Example_value, value, "f");
  }
  return Example;
}());
```

##### downlevelIteration

Provides more accurate iteration when targeting older JavaScript versions:

```json
{
  "compilerOptions": {
    "target": "ES5",
    "downlevelIteration": true
  }
}
```

Effect on compiled code:

```typescript
// Original TypeScript
const set = new Set([1, 2, 3]);
for (const item of set) {
  console.log(item);
}

// Compiled with downlevelIteration: false
// May not correctly handle all iterables
var set = new Set([1, 2, 3]);
for (var _i = 0, set_1 = set; _i < set_1.length; _i++) {
  var item = set_1[_i];
  console.log(item);
}

// Compiled with downlevelIteration: true
// Correctly handles all iterables using Symbol.iterator
var __values = this && this.__values || function(o) { /* ... */ };
var set = new Set([1, 2, 3]);
try {
  for (var set_1 = __values(set), set_1_1 = set_1.next(); !set_1_1.done; set_1_1 = set_1.next()) {
    var item = set_1_1.value;
    console.log(item);
  }
}
catch (e_1_1) { /* error handling */ }
```

##### declarationMap

Generates source map files for .d.ts declaration files, enabling "Go to Definition" in editors across projects:

```json
{
  "compilerOptions": {
    "declaration": true,
    "declarationMap": true
  }
}
```

This is particularly useful for library authors, as it allows users of the library to jump directly to the TypeScript source code rather than just the declaration files.

#### Advanced JavaScript Support

These options control TypeScript's handling of modern JavaScript features:

##### experimentalDecorators and emitDecoratorMetadata

Enables support for legacy decorator syntax (primarily used with Angular, TypeORM, etc.):

```json
{
  "compilerOptions": {
    "target": "ES2016",
    "experimentalDecorators": true,
    "emitDecoratorMetadata": true
  }
}
```

Usage example:

```typescript
// With experimentalDecorators: true
function logged(target: any, key: string, descriptor: PropertyDescriptor) {
  const original = descriptor.value;
  descriptor.value = function(...args: any[]) {
    console.log(`Calling ${key} with`, args);
    return original.apply(this, args);
  };
  return descriptor;
}

class Calculator {
  @logged
  add(a: number, b: number): number {
    return a + b;
  }
}

// With emitDecoratorMetadata: true, reflection metadata is also generated
import "reflect-metadata";

function paramType(target: any, key: string, parameterIndex: number) {
  const types = Reflect.getMetadata("design:paramtypes", target, key);
  console.log(`Parameter ${parameterIndex} of ${key} is type:`, types[parameterIndex].name);
}

class UserService {
  getUser(@paramType id: number) {
    // Implementation
  }
}
```

##### useDefineForClassFields

Controls how class fields are emitted, matching ECMAScript standard behavior:

```json
{
  "compilerOptions": {
    "target": "ES2022",
    "useDefineForClassFields": true
  }
}
```

Effect on compiled code:

```typescript
// Original TypeScript
class Example {
  value = 123;
}

// Compiled with useDefineForClassFields: true
class Example {
  constructor() {
    Object.defineProperty(this, "value", {
      enumerable: true,
      configurable: true,
      writable: true,
      value: 123
    });
  }
}

// Compiled with useDefineForClassFields: false
class Example {
  constructor() {
    this.value = 123;
  }
}
```

#### Source Maps and Debugging

These options control how source maps are generated, which affects debugging experience:

##### sourceMap, inlineSources, and inlineSourceMap

Control source map generation for debugging:

```json
{
  "compilerOptions": {
    // External source maps (recommended for production)
    "sourceMap": true,
    
    // Include source content in source maps
    "inlineSources": true,
    
    // Inline source maps in JS files (not recommended with sourceMap)
    "inlineSourceMap": false
  }
}
```

Source maps allow debugging TypeScript code directly in browsers or Node.js, even though the executed code is JavaScript.

##### mapRoot

Specifies the location where debuggers should find source maps:

```json
{
  "compilerOptions": {
    "sourceMap": true,
    "mapRoot": "/maps"
  }
}
```

This is useful when your deployment process moves source maps to a specific location.

#### Build Refinement Flags

These flags provide additional control over the build process:

##### stripInternal

Prevents emitting declarations for declarations marked with `@internal`:

```json
{
  "compilerOptions": {
    "declaration": true,
    "stripInternal": true
  }
}
```

Usage example:

```typescript
/**
 * Public API function
 */
export function publicFunction(): string {
  return internalHelper();
}

/**
 * @internal
 */
export function internalHelper(): string {
  return "helper result";
}
```

With `stripInternal: true`, the generated `.d.ts` file won't include a declaration for `internalHelper`.

##### isolatedModules

Ensures each file can be transpiled in isolation:

```json
{
  "compilerOptions": {
    "isolatedModules": true
  }
}
```

This is important when using transpilers like Babel that process files independently. It disallows certain TypeScript features that require type checking across files:

```typescript
// Error with isolatedModules: true
export const value = 123;
export type Status = "active" | "inactive";

// This re-export won't work with isolatedModules
export * from "./types";

// Fixed version for isolatedModules
export { Status } from "./types";

// Or using const assertion for values
export const Status = {
  Active: "active",
  Inactive: "inactive"
} as const;
```

### Advanced Project Configuration

Beyond individual compiler options, TypeScript offers powerful project organization features:

#### extends

Allows one tsconfig to inherit from another:

```json
// tsconfig.base.json
{
  "compilerOptions": {
    "strict": true,
    "target": "ES2022",
    "module": "NodeNext"
  }
}

// tsconfig.app.json
{
  "extends": "./tsconfig.base.json",
  "compilerOptions": {
    "outDir": "./dist",
    "declaration": true
  },
  "include": ["src/**/*"],
  "exclude": ["**/*.test.ts"]
}

// tsconfig.test.json
{
  "extends": "./tsconfig.base.json",
  "compilerOptions": {
    "module": "CommonJS",
    "types": ["jest", "node"]
  },
  "include": ["src/**/*.test.ts"]
}
```

#### references

Supports project references for modular builds:

```json
// Root tsconfig.json
{
  "files": [],
  "references": [
    { "path": "./packages/common" },
    { "path": "./packages/server" },
    { "path": "./packages/client" }
  ]
}

// packages/server/tsconfig.json
{
  "compilerOptions": {
    "composite": true,
    "rootDir": "./src",
    "outDir": "./dist"
  },
  "references": [
    { "path": "../common" }
  ]
}
```

#### watchOptions

Fine-tunes TypeScript's watch mode:

```json
{
  "compilerOptions": {
    // Standard options
  },
  "watchOptions": {
    "watchFile": "useFsEvents",
    "watchDirectory": "useFsEvents",
    "fallbackPolling": "dynamicPriority",
    "synchronousWatchDirectory": true,
    "excludeDirectories": ["**/node_modules", "dist"]
  }
}
```

### Real-World tsconfig Examples

Here are some examples of tsconfig.json configurations tailored for specific project types:

#### Node.js API Project

```json
{
  "compilerOptions": {
    // Modern Node.js
    "target": "ES2022",
    "module": "NodeNext",
    "moduleResolution": "NodeNext",
    "lib": ["ES2022"],
    
    // Type checking
    "strict": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noImplicitReturns": true,
    "noFallthroughCasesInSwitch": true,
    
    // Module resolution
    "baseUrl": "./",
    "paths": {
      "@app/*": ["src/*"]
    },
    "resolveJsonModule": true,
    "types": ["node", "jest"],
    
    // Emit
    "outDir": "./dist",
    "declaration": true,
    "sourceMap": true,
    "importHelpers": true,
    "esModuleInterop": true,
    
    // Advanced
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "**/*.test.ts"]
}
```

#### React Frontend Project

```json
{
  "compilerOptions": {
    // Modern browser
    "target": "ES2022",
    "lib": ["DOM", "DOM.Iterable", "ESNext"],
    "module": "ESNext",
    "moduleResolution": "bundler",
    "jsx": "react-jsx",
    
    // Type checking
    "strict": true,
    "noFallthroughCasesInSwitch": true,
    
    // Module resolution
    "baseUrl": "./",
    "paths": {
      "@components/*": ["src/components/*"],
      "@hooks/*": ["src/hooks/*"],
      "@utils/*": ["src/utils/*"],
      "@assets/*": ["src/assets/*"]
    },
    "resolveJsonModule": true,
    "allowSyntheticDefaultImports": true,
    "esModuleInterop": true,
    
    // Working with bundlers
    "isolatedModules": true,
    "noEmit": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true
  },
  "include": ["src"],
  "references": [
    { "path": "./tsconfig.node.json" }
  ]
}
```

#### Monorepo Library Package

```json
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "ESNext",
    "moduleResolution": "NodeNext",
    "lib": ["ES2020"],
    
    // Required for project references
    "composite": true,
    "declaration": true,
    "declarationMap": true,
    "sourceMap": true,
    
    // Type checking
    "strict": true,
    "noImplicitReturns": true,
    "noFallthroughCasesInSwitch": true,
    "noImplicitOverride": true,
    
    // Emit
    "outDir": "./dist",
    "importHelpers": true,
    
    // Interop
    "esModuleInterop": true,
    "skipLibCheck": true
  },
  "include": ["src"],
  "references": [
    { "path": "../core" }
  ]
}
```

### Conclusion

Advanced tsconfig options provide granular control over TypeScript's behavior, enabling developers to tailor the type system and compilation process to their specific needs. Understanding these options helps in creating optimized configurations that balance type safety, flexibility, and performance requirements. By leveraging strict mode options for maximum type safety, configuring module resolution for your environment, and using advanced compiler flags to refine behavior, you can harness TypeScript's full potential to deliver robust, maintainable applications.

### Related Topics

- TypeScript project references for monorepos
- Custom TypeScript transformers
- TypeScript plugin development
- Optimizing build performance with advanced tsconfig
- Migration strategies for stricter TypeScript configurations

---

## Linting and Code Quality in TypeScript

### Understanding Linting in TypeScript

Linting is the process of analyzing code for potential errors, code style violations, and suspicious constructs. In TypeScript projects, linting enhances code quality by enforcing consistent coding practices and identifying issues before runtime.

**Key Points**

- Linting catches syntax errors and potential bugs
- Enforces consistent coding standards across team members
- Identifies TypeScript-specific issues like improper type usage
- Integrates with IDEs and CI/CD pipelines for continuous code quality

### ESLint with TypeScript

ESLint has become the standard linting tool for TypeScript projects, replacing TSLint which was deprecated in 2019.

#### Setting Up ESLint with TypeScript

To set up ESLint with TypeScript:

```bash
npm install --save-dev eslint @typescript-eslint/parser @typescript-eslint/eslint-plugin
```

Create a `.eslintrc.js` configuration file:

```javascript
module.exports = {
  parser: '@typescript-eslint/parser',
  plugins: ['@typescript-eslint'],
  extends: [
    'eslint:recommended',
    'plugin:@typescript-eslint/recommended'
  ],
  rules: {
    // Custom rules here
  }
};
```

#### Popular TypeScript ESLint Configurations

Several pre-configured rule sets are available:

- `eslint:recommended` - ESLint's built-in recommended rules
- `plugin:@typescript-eslint/recommended` - TypeScript-specific recommended rules
- `plugin:@typescript-eslint/recommended-requiring-type-checking` - Stricter rules that require type information

#### Type-Aware Linting

One major advantage of ESLint with TypeScript is type-aware linting:

```javascript
parserOptions: {
  project: './tsconfig.json', // Path to your TypeScript configuration
  tsconfigRootDir: __dirname,
}
```

This enables rules that leverage TypeScript's type system to catch more sophisticated issues.

### TSLint (Legacy)

TSLint was the original TypeScript linter but has been deprecated in favor of ESLint.

#### Migration from TSLint to ESLint

For projects still using TSLint:

```bash
npx tslint-to-eslint-config
```

This tool helps convert TSLint configurations to ESLint equivalents.

#### Why TSLint Was Deprecated

- Community consolidation around ESLint
- Performance issues with TSLint
- Duplicate effort maintaining two linting ecosystems

### Custom Lint Rules

Creating custom lint rules allows teams to enforce project-specific conventions.

#### Creating a Custom ESLint Rule for TypeScript

```typescript
// my-custom-rule.js
module.exports = {
  meta: {
    type: "suggestion",
    docs: {
      description: "Enforce specific TypeScript pattern",
    },
    fixable: "code"
  },
  create: function(context) {
    return {
      // AST node visitors
      TSInterfaceDeclaration(node) {
        // Rule implementation
      }
    };
  }
};
```

#### Sharing Custom Rules with Teams

Custom rules can be packaged and shared:

```bash
npm init -y
npm install --save-dev eslint
```

Structure for a shareable configuration:

```
eslint-config-my-rules/
├── index.js
├── package.json
└── rules/
    └── my-custom-rule.js
```

### Integration with Development Workflow

#### IDE Integration

Most modern IDEs support ESLint with TypeScript:

- VS Code: ESLint extension
- WebStorm: Built-in support
- Vim/Neovim: ALE or CoC ESLint

#### Pre-commit Hooks

Using Husky and lint-staged:

```json
// package.json
{
  "husky": {
    "hooks": {
      "pre-commit": "lint-staged"
    }
  },
  "lint-staged": {
    "*.{ts,tsx}": "eslint --fix"
  }
}
```

#### CI/CD Pipeline Integration

Example GitHub Actions workflow:

```yaml
name: Lint

on: [push, pull_request]

jobs:
  eslint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: '16'
      - run: npm ci
      - run: npm run lint
```

### Advanced ESLint Configuration

#### Combining with Prettier

```bash
npm install --save-dev eslint-config-prettier eslint-plugin-prettier prettier
```

`.eslintrc.js` configuration:

```javascript
module.exports = {
  extends: [
    'eslint:recommended',
    'plugin:@typescript-eslint/recommended',
    'prettier',
    'plugin:prettier/recommended'
  ],
  // Other configuration...
};
```

#### Project-Specific Rule Overrides

```javascript
module.exports = {
  // Base rules...
  overrides: [
    {
      files: ['src/legacy/**/*.ts'],
      rules: {
        '@typescript-eslint/no-explicit-any': 'off'
      }
    },
    {
      files: ['src/components/**/*.tsx'],
      rules: {
        'react/prop-types': 'off'
      }
    }
  ]
};
```

### Performance Optimization

#### Caching ESLint Results

```bash
eslint --cache --cache-location ./node_modules/.cache/eslint/ src/
```

Or in `package.json`:

```json
{
  "scripts": {
    "lint": "eslint --cache --cache-location ./node_modules/.cache/eslint/ src/"
  }
}
```

#### Selective Linting

For large codebases:

```bash
eslint --ext .ts,.tsx src/components
```

### Common TypeScript-Specific Rules

#### Strict Type Checking

```javascript
rules: {
  '@typescript-eslint/no-explicit-any': 'error',
  '@typescript-eslint/explicit-function-return-type': 'error',
  '@typescript-eslint/strict-boolean-expressions': 'error'
}
```

#### Nullability Handling

```javascript
rules: {
  '@typescript-eslint/no-non-null-assertion': 'error',
  '@typescript-eslint/no-unnecessary-condition': 'error'
}
```

### Industry Best Practices

#### Popular ESLint Configs for TypeScript

- AirBnB TypeScript: `eslint-config-airbnb-typescript`
- Google: `gts` (Google TypeScript Style)
- Standard with TypeScript: `eslint-config-standard-with-typescript`

#### Rule Categories for Different Project Types

- Libraries: Stricter rules for public APIs
- Applications: Focus on consistency and maintainability
- Monorepos: Configuration sharing with overrides for package-specific needs

### Troubleshooting

#### Common Issues and Solutions

1. Rules conflicting with Prettier:
    
    - Add `eslint-config-prettier` to turn off conflicting rules
2. Performance issues:
    
    - Use `--cache` flag
    - Run ESLint only on changed files
    - Disable resource-intensive rules selectively
3. False positives with type-aware linting:
    
    - Ensure tsconfig.json paths are correct
    - Check for excluded files in tsconfig.json

### Recommended Related Tools

- SonarQube/SonarLint - Static code analysis
- TypeScript Project References - For large codebases
- Rome - Unified frontend toolchain (linting, formatting, bundling)

---

## Integration and Automation

### Continuous Integration

Continuous Integration (CI) is a development practice where developers integrate code into a shared repository frequently, preferably several times a day. Each integration is verified by an automated build and automated tests.

**Key Points**

- CI helps detect errors quickly and locate them more easily
- TypeScript works exceptionally well with CI systems due to its static type checking
- Most CI providers support TypeScript natively or with minimal configuration
- A typical CI workflow for TypeScript includes linting, type checking, compiling, and testing

To set up a basic TypeScript CI pipeline, you'll need:

1. A `tsconfig.json` file with appropriate compiler options
2. Testing frameworks such as Jest, Mocha, or Vitest configured for TypeScript
3. Linting tools like ESLint with TypeScript plugins
4. A CI configuration file for your chosen platform

### GitHub Actions with TypeScript

GitHub Actions provides powerful automation and CI/CD capabilities directly within GitHub repositories, with excellent TypeScript support.

**Key Points**

- GitHub Actions uses YAML files stored in `.github/workflows/` directory
- TypeScript projects benefit from typed actions and strong tooling
- You can run type checking as a separate step in your workflow
- GitHub's ecosystem includes many pre-built actions for TypeScript projects

**Example**

Here's a basic GitHub Actions workflow for a TypeScript project:

```yaml
name: TypeScript CI

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest

    strategy:
      matrix:
        node-version: [16.x, 18.x, 20.x]

    steps:
    - uses: actions/checkout@v3
    - name: Use Node.js ${{ matrix.node-version }}
      uses: actions/setup-node@v3
      with:
        node-version: ${{ matrix.node-version }}
        cache: 'npm'
    - run: npm ci
    - run: npm run lint
    - run: npm run type-check
    - run: npm run build
    - run: npm test
```

For more complex TypeScript projects, you might want to add:

- Parallel job execution for faster builds
- Caching for node_modules and TypeScript compilation output
- Code coverage reporting
- Integration with deployment platforms

### Automated Testing

TypeScript enhances automated testing through its type system, making tests more robust and providing better editor support.

**Key Points**

- TypeScript works with all major JavaScript testing frameworks
- Type definitions improve test maintenance and refactoring
- You can leverage TypeScript features for more powerful mocking
- Testing libraries provide TypeScript-specific features

Testing frameworks compatible with TypeScript:

- Jest - Popular framework with built-in TypeScript support via `ts-jest`
- Mocha - Works with TypeScript via `ts-node`
- Vitest - Modern, Vite-native testing framework with first-class TypeScript support
- Cypress - End-to-end testing with TypeScript support
- Playwright - Browser automation with excellent TypeScript integration

**Example**

Here's a simple Jest test in TypeScript:

```typescript
// user.service.ts
export interface User {
  id: number;
  name: string;
  email: string;
}

export class UserService {
  getUser(id: number): Promise<User> {
    return fetch(`/api/users/${id}`)
      .then(response => response.json());
  }
}

// user.service.test.ts
import { UserService, User } from './user.service';

describe('UserService', () => {
  let service: UserService;
  
  beforeEach(() => {
    service = new UserService();
    global.fetch = jest.fn();
  });
  
  it('should fetch a user by id', async () => {
    const mockUser: User = { id: 1, name: 'Test User', email: 'test@example.com' };
    (global.fetch as jest.Mock).mockResolvedValueOnce({
      json: async () => mockUser
    });
    
    const user = await service.getUser(1);
    
    expect(global.fetch).toHaveBeenCalledWith('/api/users/1');
    expect(user).toEqual(mockUser);
  });
});
```

### Deployment Strategies

TypeScript projects can be deployed using various strategies, each with different trade-offs regarding build time, runtime performance, and deployment complexity.

**Key Points**

- TypeScript code must be transpiled to JavaScript before deployment
- Deployment artifacts may include source maps for debugging
- Different environments (development, staging, production) may have different TypeScript configurations
- TypeScript enhances deployment safety through type checking

Common deployment strategies for TypeScript projects:

1. Build-time compilation:
    
    - Compile TypeScript to JavaScript during the CI process
    - Deploy only the compiled JavaScript files
    - Fastest runtime performance but loses type information
2. Runtime transpilation:
    
    - Use tools like `ts-node` in production
    - Deploy TypeScript source code
    - Slower startup but preserves type information
    - Not recommended for most production environments
3. Bundle-based deployment:
    
    - Use bundlers like Webpack, Rollup, or esbuild
    - Create optimized bundles for different targets
    - Can include code splitting and tree-shaking
4. Serverless deployment:
    
    - Deploy TypeScript functions to serverless platforms
    - Each function is compiled and packaged separately
    - Enables fine-grained scaling and resource allocation

**Example**

A basic deployment pipeline for a TypeScript Node.js application:

```typescript
// Build script (build.ts)
import { exec } from 'child_process';
import fs from 'fs';
import path from 'path';

// Clean dist directory
if (fs.existsSync('./dist')) {
  fs.rmSync('./dist', { recursive: true });
}

// Compile TypeScript
exec('tsc --project tsconfig.prod.json', (error) => {
  if (error) {
    console.error(`Error compiling TypeScript: ${error}`);
    process.exit(1);
  }
  
  // Copy package.json to dist
  const pkg = JSON.parse(fs.readFileSync('./package.json', 'utf8'));
  // Remove devDependencies and scripts
  delete pkg.devDependencies;
  delete pkg.scripts;
  
  fs.writeFileSync(
    path.join('./dist', 'package.json'),
    JSON.stringify(pkg, null, 2)
  );
  
  console.log('Build completed successfully!');
});
```

For container-based deployments, you might use a multi-stage Dockerfile:

```dockerfile
# Build stage
FROM node:18-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY tsconfig*.json ./
COPY src ./src
RUN npm run build

# Production stage
FROM node:18-alpine
WORKDIR /app
COPY --from=build /app/dist ./dist
COPY --from=build /app/package*.json ./
RUN npm ci --only=production
EXPOSE 3000
CMD ["node", "dist/index.js"]
```

Related topics you might be interested in:

- Infrastructure as Code (IaC) with TypeScript (e.g., AWS CDK, Pulumi)
- Monorepo strategies for TypeScript projects
- Feature flags and canary releases with TypeScript
- Performance monitoring and error tracking for TypeScript applications

---

# TypeScript Ecosystem and Best Practices

## Type-Safe Libraries for TypeScript

### Understanding Type Safety in Libraries

Type safety in TypeScript libraries ensures that errors are caught during development rather than at runtime. A well-designed type-safe library leverages TypeScript's type system to provide compile-time guarantees, reducing bugs and improving developer experience.

**Key Points**

- Type-safe libraries prevent common runtime errors through compile-time checking
- They provide better IDE support with accurate autocompletion
- They make refactoring safer and more efficient
- They serve as self-documenting code through expressive types

### fp-ts: Functional Programming in TypeScript

fp-ts brings functional programming patterns to TypeScript, offering a comprehensive set of typed functional utilities that respect mathematical laws.

**Key Points**

- Implements algebraic data types like Option, Either, and Task
- Provides type-safe composition of functions and operations
- Follows category theory principles with functors, monads, etc.
- Enables pure, declarative coding style with immutability

### fp-ts Core Concepts

#### Higher-Kinded Types Simulation

Despite TypeScript not natively supporting higher-kinded types, fp-ts simulates them through clever type definitions:

```typescript
// HKT (Higher Kinded Type) representation
interface HKT<F, A> {
  readonly _F: F
  readonly _A: A
}

// Example: Option as a higher-kinded type
interface Option<A> extends HKT<'Option', A> {
  readonly _tag: 'None' | 'Some'
  readonly value: A
}
```

#### Functional Data Types

```typescript
import { pipe } from 'fp-ts/function'
import { Option, some, none, map, getOrElse } from 'fp-ts/Option'
import { flow } from 'fp-ts/function'

// Example: Working with Option type
const double = (n: number): number => n * 2
const toString = (n: number): string => n.toString()

// Composing functions in a type-safe way
const processValue = flow(
  double,
  toString,
  some
)

const result: Option<string> = processValue(5) // Some("10")

// Safely handling possibly undefined values
const getValue = (obj: { value?: number }): Option<number> =>
  obj.value === undefined ? none : some(obj.value)

const computeResult = (obj: { value?: number }): string =>
  pipe(
    getValue(obj),
    map(double),
    map(toString),
    getOrElse(() => 'No value')
  )
```

### io-ts: Runtime Type Validation

io-ts bridges the gap between compile-time type checking and runtime validation, ensuring that external data conforms to expected TypeScript types.

**Key Points**

- Creates runtime type validators that correspond to TypeScript types
- Provides useful error messages for validation failures
- Integrates seamlessly with fp-ts for functional error handling
- Enables safe parsing of JSON, API responses, and other external data

### io-ts Core Concepts

#### Codec Creation and Validation

```typescript
import * as t from 'io-ts'
import { pipe } from 'fp-ts/function'
import { fold } from 'fp-ts/Either'

// Define a runtime type that corresponds to a TypeScript interface
const User = t.type({
  id: t.number,
  name: t.string,
  email: t.string
})

// The static TypeScript type is automatically inferred
type User = t.TypeOf<typeof User>

// Validate external data at runtime
const validateUser = (input: unknown) => {
  return pipe(
    User.decode(input),
    fold(
      errors => {
        console.error('Validation failed:', errors)
        return null
      },
      validUser => validUser
    )
  )
}

// Example usage
const validData = { id: 1, name: 'John', email: 'john@example.com' }
const invalidData = { id: 'not-a-number', name: 123 }

const user1 = validateUser(validData)    // Returns the valid user
const user2 = validateUser(invalidData)  // Returns null and logs error
```

#### Advanced Type Combinations

```typescript
// Complex type definitions
const PositiveNumber = new t.Type<number, number, unknown>(
  'PositiveNumber',
  (u): u is number => t.number.is(u) && u > 0,
  (u, c) => 
    pipe(
      t.number.validate(u, c),
      chain(n => n > 0 ? t.success(n) : t.failure(u, c))
    ),
  t.identity
)

const Email = t.refinement(
  t.string,
  (s): s is string => /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/.test(s),
  'Email'
)

// Combined with other types
const AdvancedUser = t.type({
  id: PositiveNumber,
  name: t.string,
  email: Email,
  roles: t.array(t.string),
  metadata: t.partial({
    lastLogin: t.union([t.string, t.undefined]),
    preferences: t.record(t.string, t.unknown)
  })
})
```

### typesafe-actions: Type-Safe Redux

typesafe-actions provides type safety for Redux actions and reducers in TypeScript applications, eliminating common errors when working with Redux state management.

**Key Points**

- Creates fully typed action creators and reducers
- Infers action types automatically from action creators
- Simplifies Redux boilerplate while maintaining type safety
- Improves maintainability of Redux code with better type inference

### typesafe-actions Core Concepts

#### Type-Safe Action Creation

```typescript
import { createAction } from 'typesafe-actions'

// Define action types
export const ADD_TODO = 'todos/ADD'
export const TOGGLE_TODO = 'todos/TOGGLE'
export const REMOVE_TODO = 'todos/REMOVE'

// Define type-safe action creators
export const addTodo = createAction(ADD_TODO)<string>()
export const toggleTodo = createAction(TOGGLE_TODO)<number>()
export const removeTodo = createAction(REMOVE_TODO)<number>()

// The types are inferred automatically
const action1 = addTodo('Buy milk')
// { type: 'todos/ADD', payload: 'Buy milk' }

const action2 = toggleTodo(1)
// { type: 'todos/TOGGLE', payload: 1 }
```

#### Type-Safe Reducers

```typescript
import { createReducer } from 'typesafe-actions'
import { RootAction } from './actions'
import { addTodo, toggleTodo, removeTodo } from './actions'

export interface Todo {
  id: number
  text: string
  completed: boolean
}

export type TodosState = ReadonlyArray<Todo>

const initialState: TodosState = []

// Type-safe reducer
export const todosReducer = createReducer<TodosState, RootAction>(initialState)
  .handleAction(addTodo, (state, action) => [
    ...state,
    {
      id: state.length,
      text: action.payload,
      completed: false
    }
  ])
  .handleAction(toggleTodo, (state, action) => 
    state.map(todo => 
      todo.id === action.payload
        ? { ...todo, completed: !todo.completed }
        : todo
    )
  )
  .handleAction(removeTodo, (state, action) => 
    state.filter(todo => todo.id !== action.payload)
  )
```

### Integration Patterns and Best Practices

#### Combining fp-ts with io-ts

```typescript
import * as t from 'io-ts'
import { pipe } from 'fp-ts/function'
import { fold, TaskEither, tryCatch } from 'fp-ts/TaskEither'
import { sequenceS } from 'fp-ts/Apply'

// Define runtime types
const User = t.type({
  id: t.number,
  name: t.string
})

// API functions returning TaskEither (handles async and errors)
const fetchUser = (id: number): TaskEither<Error, unknown> => 
  tryCatch(
    () => fetch(`/api/users/${id}`).then(r => r.json()),
    reason => new Error(String(reason))
  )

// Combining validation with API calls
const getValidatedUser = (id: number) => 
  pipe(
    fetchUser(id),
    chain(data => 
      tryCatch(
        () => {
          const result = User.decode(data)
          if (result._tag === 'Left') {
            throw new Error('Invalid user data')
          }
          return result.right
        },
        reason => new Error(String(reason))
      )
    )
  )

// Usage with proper error handling
const program = pipe(
  getValidatedUser(123),
  fold(
    error => async () => console.error('Failed:', error.message),
    user => async () => console.log('User:', user)
  )
)

program()
```

#### Combining typesafe-actions with fp-ts

```typescript
import { createAction, ActionType } from 'typesafe-actions'
import { pipe } from 'fp-ts/function'
import { TaskEither, tryCatch, map } from 'fp-ts/TaskEither'

// Define actions
const fetchUserRequest = createAction('FETCH_USER_REQUEST')<number>()
const fetchUserSuccess = createAction('FETCH_USER_SUCCESS')<User>()
const fetchUserFailure = createAction('FETCH_USER_FAILURE')<Error>()

type UserActions = ActionType
  typeof fetchUserRequest | 
  typeof fetchUserSuccess | 
  typeof fetchUserFailure
>

// Define a function that returns a TaskEither for API calls
const fetchUserApi = (id: number): TaskEither<Error, User> =>
  pipe(
    tryCatch(
      () => fetch(`/api/users/${id}`).then(r => r.json()),
      reason => new Error(String(reason))
    ),
    chain(data => 
      pipe(
        User.decode(data),
        fold(
          () => left(new Error('Invalid user data')),
          right
        )
      )
    )
  )

// Redux middleware using fp-ts
const fetchUserMiddleware = ({ dispatch }: MiddlewareAPI) => (next: Dispatch) => (action: UserActions) => {
  next(action)
  
  if (fetchUserRequest.match(action)) {
    const userId = action.payload
    dispatch({ type: 'FETCH_USER_LOADING' })
    
    pipe(
      fetchUserApi(userId),
      fold(
        error => () => dispatch(fetchUserFailure(error)),
        user => () => dispatch(fetchUserSuccess(user))
      )
    )()
  }
}
```

### Advanced Type Safety Techniques

#### Branded Types with io-ts

```typescript
import * as t from 'io-ts'
import { brand, Branded } from 'io-ts'

// Create branded types for additional type safety
interface EmailBrand {
  readonly Email: unique symbol
}
type Email = Branded<string, EmailBrand>

// Runtime validators for branded types
const EmailCodec = t.brand(
  t.string,
  (s): s is Email => /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/.test(s),
  'Email'
)

// Use branded types in your domain models
const User = t.type({
  id: t.number,
  email: EmailCodec
})

type User = t.TypeOf<typeof User>

// Functions that use branded types get additional type safety
function sendEmail(email: Email, subject: string, body: string) {
  // Implementation...
}

// This works because we know the email is valid
function processUser(user: User) {
  sendEmail(user.email, 'Welcome', 'Hello there!')
}

// This would fail at compile time
// sendEmail('not-an-email', 'Subject', 'Body')
```

#### Higher-Order Components with typesafe-actions

```typescript
import { createAsyncAction } from 'typesafe-actions'

// Create reusable async action pattern
export function createApiAction<Req, Res, Err = Error>(baseType: string) {
  return createAsyncAction(
    `${baseType}_REQUEST`,
    `${baseType}_SUCCESS`,
    `${baseType}_FAILURE`
  )<Req, Res, Err>()
}

// Usage
const fetchUserAction = createApiAction<number, User>('FETCH_USER')
const fetchPostsAction = createApiAction<{ userId: number }, Post[]>('FETCH_POSTS')

// Type-safe dispatch
dispatch(fetchUserAction.request(123))
// { type: 'FETCH_USER_REQUEST', payload: 123 }

dispatch(fetchUserAction.success({ id: 123, name: 'John' }))
// { type: 'FETCH_USER_SUCCESS', payload: { id: 123, name: 'John' } }
```

### Performance Considerations

#### Optimizing Runtime Type Checks

```typescript
import * as t from 'io-ts'

// Define schema once and reuse
const commonFields = t.type({
  id: t.number,
  createdAt: t.string
})

// Extend base schemas (reuses validation logic)
const User = t.intersection([
  commonFields,
  t.type({
    name: t.string,
    email: t.string
  })
])

// Partial schemas for updates (improves performance)
const UserUpdate = t.partial(User.props)

// Caching validation results for frequently accessed data
const validationCache = new Map<string, any>()

function validateWithCache<A>(codec: t.Type<A>, data: unknown, cacheKey: string): A | null {
  if (validationCache.has(cacheKey)) {
    return validationCache.get(cacheKey)
  }
  
  const result = codec.decode(data)
  if (result._tag === 'Right') {
    validationCache.set(cacheKey, result.right)
    return result.right
  }
  
  return null
}
```

### Testing Type-Safe Libraries

```typescript
import * as t from 'io-ts'
import { isRight } from 'fp-ts/Either'
import { createAction } from 'typesafe-actions'

// Testing io-ts types
describe('User codec', () => {
  const User = t.type({
    id: t.number,
    name: t.string
  })
  
  test('validates correct user data', () => {
    const validUser = { id: 1, name: 'Alice' }
    const result = User.decode(validUser)
    expect(isRight(result)).toBe(true)
    if (isRight(result)) {
      expect(result.right).toEqual(validUser)
    }
  })
  
  test('fails on invalid user data', () => {
    const invalidUser = { id: 'not-a-number', name: 123 }
    const result = User.decode(invalidUser)
    expect(isRight(result)).toBe(false)
  })
})

// Testing typesafe-actions
describe('Todo actions', () => {
  const addTodo = createAction('ADD_TODO')<string>()
  
  test('creates properly typed action', () => {
    const action = addTodo('Test todo')
    expect(action).toEqual({
      type: 'ADD_TODO',
      payload: 'Test todo'
    })
  })
})
```

### Migration Strategies

#### Gradually Adopting Type-Safe Libraries

```typescript
// Step 1: Start with some basic io-ts types for critical data
const ApiResponse = t.type({
  status: t.union([t.literal('success'), t.literal('error')]),
  data: t.unknown
})

// Step 2: Introduce more specific types gradually
const UserResponse = t.intersection([
  ApiResponse,
  t.type({
    data: t.union([
      t.type({ 
        users: t.array(User) 
      }),
      t.type({ 
        error: t.string 
      })
    ])
  })
])

// Step 3: Create utility functions for common patterns
function validateApiResponse<T>(
  response: unknown, 
  dataCodec: t.Type<T>
): T | null {
  const result = pipe(
    ApiResponse.decode(response),
    chain(resp => {
      if (resp.status === 'error') {
        return left(new Error('API returned error'))
      }
      return dataCodec.decode(resp.data)
    })
  )
  
  return isRight(result) ? result.right : null
}
```

### Comparison with Other Approaches

#### Type-Safe Libraries vs Manual Type Definitions

**Manual Type Definitions**

```typescript
// Manual approach
interface User {
  id: number
  name: string
  email: string
}

function isUser(data: unknown): data is User {
  if (typeof data !== 'object' || data === null) return false
  
  const obj = data as Record<string, unknown>
  return (
    typeof obj.id === 'number' &&
    typeof obj.name === 'string' &&
    typeof obj.email === 'string'
  )
}

function fetchUser(id: number): Promise<User> {
  return fetch(`/api/users/${id}`)
    .then(r => r.json())
    .then(data => {
      if (!isUser(data)) {
        throw new Error('Invalid user data')
      }
      return data
    })
}
```

**With io-ts**

```typescript
// io-ts approach
const User = t.type({
  id: t.number,
  name: t.string,
  email: t.string
})

function fetchUser(id: number): TaskEither<Error, t.TypeOf<typeof User>> {
  return pipe(
    tryCatch(
      () => fetch(`/api/users/${id}`).then(r => r.json()),
      reason => new Error(String(reason))
    ),
    chain(data => 
      pipe(
        User.decode(data),
        fold(
          () => left(new Error('Invalid user data')),
          right
        )
      )
    )
  )
}
```

### Real-World Application Architecture

```typescript
// Combining all three libraries in a complete architecture
import * as t from 'io-ts'
import { pipe } from 'fp-ts/function'
import { TaskEither, tryCatch, chain } from 'fp-ts/TaskEither'
import { fold, Either, right, left } from 'fp-ts/Either'
import { createAction, createReducer, ActionType } from 'typesafe-actions'

// 1. Define runtime types with io-ts
const User = t.type({
  id: t.number,
  name: t.string,
  email: t.string
})

type User = t.TypeOf<typeof User>

// 2. Create API service with fp-ts
const api = {
  getUser: (id: number): TaskEither<Error, User> =>
    pipe(
      tryCatch(
        () => fetch(`/api/users/${id}`).then(r => r.json()),
        reason => new Error(String(reason))
      ),
      chain(data => 
        pipe(
          User.decode(data),
          fold(
            () => left(new Error('Invalid user data')),
            user => right(user)
          )
        )
      )
    )
}

// 3. Set up Redux with typesafe-actions
const userActions = {
  fetchRequest: createAction('users/FETCH_REQUEST')<number>(),
  fetchSuccess: createAction('users/FETCH_SUCCESS')<User>(),
  fetchFailure: createAction('users/FETCH_FAILURE')<Error>()
}

type UserAction = ActionType<typeof userActions>

interface UserState {
  data: User | null
  loading: boolean
  error: string | null
}

const initialState: UserState = {
  data: null,
  loading: false,
  error: null
}

const userReducer = createReducer<UserState, UserAction>(initialState)
  .handleAction(userActions.fetchRequest, state => ({
    ...state,
    loading: true,
    error: null
  }))
  .handleAction(userActions.fetchSuccess, (state, action) => ({
    ...state,
    data: action.payload,
    loading: false
  }))
  .handleAction(userActions.fetchFailure, (state, action) => ({
    ...state,
    loading: false,
    error: action.payload.message
  }))

// 4. Implement middleware that ties it all together
const fetchUserMiddleware = ({ dispatch }: MiddlewareAPI) => 
  (next: Dispatch) => 
  (action: UserAction) => {
    next(action)
    
    if (userActions.fetchRequest.match(action)) {
      const userId = action.payload
      
      pipe(
        api.getUser(userId),
        fold(
          error => () => dispatch(userActions.fetchFailure(error)),
          user => () => dispatch(userActions.fetchSuccess(user))
        )
      )()
    }
  }
```

### Future Trends in Type-Safe Libraries

As TypeScript continues to evolve, type-safe libraries are becoming more sophisticated and easier to use. Current trends include:

- Greater integration with TypeScript's template literal types for more precise string validation
- Enhancing editor support with custom JSDoc annotations
- Improved error reporting with detailed type information
- Adoption of pattern matching capabilities as they become available in TypeScript
- Runtime optimizations to reduce performance overhead of type checking

### Related Topics

- Zod: A newer alternative to io-ts with a more fluent API
- Effect-TS: An extension of fp-ts with more powerful effect handling
- ts-pattern: Type-safe exhaustive pattern matching
- Type-level programming techniques in TypeScript
- Implementing the IO monad for pure functional side effects

---

## Monorepos with TypeScript

### Introduction to TypeScript Monorepos

A monorepo (monolithic repository) is a development strategy where multiple projects or packages are stored in a single repository. When combined with TypeScript, monorepos offer powerful type safety across your entire codebase while maintaining separation of concerns. This approach has been adopted by major companies like Google, Facebook, and Microsoft to manage large-scale applications efficiently.

### Setting Up Monorepos

#### Tools for TypeScript Monorepos

There are several tools available for managing TypeScript monorepos:

- **Nx**: A powerful build system with built-in TypeScript support
- **Turborepo**: Optimized for high-performance builds and caching
- **Lerna**: One of the original monorepo management tools
- **pnpm Workspaces**: Lightweight solution with efficient package linking
- **Yarn Workspaces**: Integrated workspace management for Yarn users
- **npm Workspaces**: Native workspaces in npm 7+

#### Basic Monorepo Structure

```
my-monorepo/
├── package.json          # Root package.json
├── tsconfig.json         # Base TypeScript configuration
├── tsconfig.base.json    # Shared TypeScript settings
├── packages/
│   ├── common/           # Shared utilities and types
│   │   ├── package.json
│   │   ├── tsconfig.json # Extends base config
│   │   └── src/
│   ├── api/
│   │   ├── package.json
│   │   ├── tsconfig.json # Extends base config
│   │   └── src/
│   └── web/
│       ├── package.json
│       ├── tsconfig.json # Extends base config
│       └── src/
└── node_modules/         # Hoisted dependencies
```

#### Setting Up with Nx

```bash
# Install Nx globally
npm install -g nx

# Create a new Nx workspace
npx create-nx-workspace my-monorepo --preset=ts

# Add new packages
nx g @nrwl/js:lib common
nx g @nrwl/js:lib api
nx g @nrwl/js:lib web
```

#### Setting Up with Turborepo

```bash
# Create a new Turborepo
npx create-turbo@latest

# The structure is created automatically
# You can customize it according to your needs
```

#### Root tsconfig.json Example

```json
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "ESNext",
    "moduleResolution": "node",
    "esModuleInterop": true,
    "strict": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "declaration": true,
    "baseUrl": ".",
    "paths": {
      "@my-org/common": ["packages/common/src"],
      "@my-org/api": ["packages/api/src"],
      "@my-org/web": ["packages/web/src"]
    }
  },
  "exclude": ["**/node_modules", "**/dist"]
}
```

### Sharing Types Across Packages

#### Path Aliases and References

```json
// tsconfig.base.json
{
  "compilerOptions": {
    "baseUrl": ".",
    "paths": {
      "@my-org/*": ["packages/*/src"]
    }
  }
}

// packages/api/tsconfig.json
{
  "extends": "../../tsconfig.base.json",
  "compilerOptions": {
    "outDir": "./dist",
    "rootDir": "./src"
  },
  "references": [
    { "path": "../common" }
  ]
}
```

#### Package Exports and Imports

```typescript
// packages/common/src/index.ts
export interface User {
  id: string;
  name: string;
  email: string;
}

export enum UserRole {
  ADMIN = 'admin',
  USER = 'user'
}

// packages/api/src/users/service.ts
import { User, UserRole } from '@my-org/common';

export class UserService {
  createUser(name: string, email: string): User {
    // Implementation
    return { id: '123', name, email };
  }
}
```

#### Project References

TypeScript's project references enable faster builds and better organization:

```json
// packages/web/tsconfig.json
{
  "extends": "../../tsconfig.base.json",
  "compilerOptions": {
    "outDir": "./dist",
    "rootDir": "./src",
    "composite": true
  },
  "references": [
    { "path": "../common" }
  ]
}
```

Build with project references:

```bash
# Build all packages in correct order
tsc -b packages/web
```

#### Type-Only Imports

For performance optimization:

```typescript
// Only import types, not implementation
import type { User } from '@my-org/common';

// The function implementation doesn't rely on runtime code
function validateUser(user: User): boolean {
  return Boolean(user.id && user.name && user.email);
}
```

### Managing Dependencies

#### Package Management Strategies

- **Hoisting**: Most dependencies are lifted to the root node_modules
- **Nohoist**: Specific packages kept in local node_modules
- **Peer Dependencies**: Used for shared dependencies across packages

#### Root package.json

```json
{
  "name": "my-monorepo",
  "private": true,
  "workspaces": [
    "packages/*"
  ],
  "scripts": {
    "build": "tsc -b",
    "test": "jest",
    "lint": "eslint ."
  },
  "devDependencies": {
    "typescript": "^4.9.5",
    "eslint": "^8.38.0",
    "jest": "^29.5.0"
  }
}
```

#### Package-Specific Dependencies

```json
// packages/api/package.json
{
  "name": "@my-org/api",
  "version": "1.0.0",
  "main": "dist/index.js",
  "types": "dist/index.d.ts",
  "scripts": {
    "build": "tsc"
  },
  "dependencies": {
    "@my-org/common": "workspace:*",
    "express": "^4.18.2"
  }
}
```

#### Versioning Strategies

1. **Fixed versioning**: All packages share the same version
2. **Independent versioning**: Each package has its own version
3. **Graduated versioning**: Core packages move slowly, feature packages move quickly

#### Dependency Management with pnpm

```bash
# Install package in all workspaces
pnpm add -w typescript

# Install package in specific workspace
pnpm add express --filter @my-org/api

# Link workspace packages
pnpm add @my-org/common --filter @my-org/web --workspace
```

### Build Optimization

#### Incremental Builds

```json
// tsconfig.base.json
{
  "compilerOptions": {
    "incremental": true,
    "composite": true,
    "tsBuildInfoFile": "./buildcache/.tsbuildinfo"
  }
}
```

#### Parallel Building

With Turborepo:

```json
// turbo.json
{
  "pipeline": {
    "build": {
      "dependsOn": ["^build"],
      "outputs": ["dist/**"]
    },
    "test": {
      "dependsOn": ["build"],
      "outputs": []
    }
  }
}
```

#### Caching Strategies

```bash
# Turborepo with remote caching
npx turbo build --team="my-team" --token="xxx"

# Nx with computation caching
nx build web --skip-nx-cache=false
```

### Monorepo Best Practices

#### Consistent Code Style

```json
// Root .eslintrc.js
module.exports = {
  root: true,
  parser: '@typescript-eslint/parser',
  plugins: ['@typescript-eslint'],
  extends: [
    'eslint:recommended',
    'plugin:@typescript-eslint/recommended'
  ],
  rules: {
    // Custom rules
  }
};
```

#### Automated Testing

```json
// jest.config.js
module.exports = {
  projects: [
    '<rootDir>/packages/*/jest.config.js'
  ],
  collectCoverageFrom: [
    'packages/*/src/**/*.ts'
  ]
};
```

#### CI/CD Integration

```yaml
# .github/workflows/ci.yml
name: CI
on: [push]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: '18'
          cache: 'npm'
      - run: npm ci
      - run: npm run build
      - run: npm test
```

### Advanced TypeScript Features in Monorepos

#### Type Generation and Publishing

```json
// packages/common/package.json
{
  "name": "@my-org/common",
  "scripts": {
    "build": "tsc",
    "prepublishOnly": "npm run build"
  },
  "files": [
    "dist",
    "src"
  ],
  "types": "dist/index.d.ts"
}
```

#### API Extractor

Microsoft's API Extractor can generate a single declaration file:

```json
// api-extractor.json
{
  "$schema": "https://developer.microsoft.com/json-schemas/api-extractor/v7/api-extractor.schema.json",
  "mainEntryPointFilePath": "<projectFolder>/dist/index.d.ts",
  "dtsRollup": {
    "enabled": true,
    "untrimmedFilePath": "<projectFolder>/dist/index.d.ts"
  }
}
```

#### Type Testing

```typescript
// packages/common/src/__tests__/types.test.ts
import { expectType } from 'tsd';
import { User } from '../index';

// Type tests
test('User has correct structure', () => {
  expectType<User>({
    id: '123',
    name: 'John',
    email: 'john@example.com'
  });
});
```

### Common Issues and Solutions

#### Circular Dependencies

Problem: Package A depends on B, which depends on A.

Solution:

1. Create a separate package C that both A and B depend on
2. Use interfaces over concrete implementations
3. Use dependency injection

#### Version Conflicts

Problem: Different packages require different versions of the same dependency.

Solution:

1. Use peer dependencies
2. Update all packages to use compatible versions
3. For truly incompatible dependencies, use nohoist

#### Build Performance

Problem: Slow builds as the monorepo grows.

Solution:

1. Use incremental compilation
2. Implement caching
3. Use project references correctly
4. Consider task-based parallelization (e.g., Turborepo, Nx)

**Key Points**:

- Monorepos with TypeScript improve type safety across multiple packages while maintaining separation of concerns
- Project references in TypeScript enable faster builds and better code organization
- Path aliases make imports cleaner and more maintainable
- Package management tools like pnpm, Yarn workspaces, or npm workspaces simplify dependency management
- Build systems like Nx and Turborepo optimize the build process through caching and parallelization

### Real-World Examples

#### Example Monorepo Structure for a Full-Stack Application

```
my-fullstack-app/
├── package.json
├── tsconfig.base.json
├── turbo.json
├── apps/
│   ├── web/                 # React frontend
│   │   ├── package.json
│   │   ├── tsconfig.json
│   │   └── src/
│   │       ├── app.tsx
│   │       └── main.tsx
│   └── api/                 # Express backend
│       ├── package.json
│       ├── tsconfig.json
│       └── src/
│           ├── server.ts
│           └── routes/
├── packages/
│   ├── ui/                  # Shared UI components
│   │   ├── package.json
│   │   ├── tsconfig.json
│   │   └── src/
│   │       ├── button/
│   │       └── index.ts
│   ├── dto/                 # Data transfer objects
│   │   ├── package.json
│   │   ├── tsconfig.json
│   │   └── src/
│   │       ├── user.ts
│   │       └── index.ts
│   ├── config/              # Shared configuration
│   │   ├── package.json
│   │   ├── tsconfig.json
│   │   └── src/
│   │       ├── env.ts
│   │       └── index.ts
│   └── utils/               # Shared utilities
│       ├── package.json
│       ├── tsconfig.json
│       └── src/
│           ├── validation.ts
│           └── index.ts
└── tools/                   # Build and development tools
    ├── eslint-config/
    ├── typescript-config/
    └── scripts/
```

#### Example of Shared Types

```ts
// packages/dto/src/user.ts
export interface UserBase {
  id: string;
  email: string;
  username: string;
  createdAt: Date;
}

export interface UserWithProfile extends UserBase {
  profile: {
    firstName: string;
    lastName: string;
    avatar?: string;
  };
}

export type UserCreateInput = Omit<UserBase, 'id' | 'createdAt'> & {
  password: string;
  profile?: Omit<UserWithProfile['profile'], 'avatar'>;
};

export type UserUpdateInput = Partial<Omit<UserWithProfile, 'id' | 'createdAt'>>;

// packages/dto/src/index.ts
export * from './user';
export * from './auth';
export * from './product';

// packages/api/src/controllers/user.controller.ts
import { UserCreateInput, UserWithProfile } from '@my-org/dto';
import { validateUser } from '@my-org/utils';

export class UserController {
  async createUser(input: UserCreateInput): Promise<UserWithProfile> {
    // Validate input
    validateUser(input);
    
    // Create user logic...
    return {
      id: '123',
      email: input.email,
      username: input.username,
      createdAt: new Date(),
      profile: {
        firstName: input.profile?.firstName || '',
        lastName: input.profile?.lastName || ''
      }
    };
  }
}

// apps/web/src/features/user/create-user.tsx
import { useState } from 'react';
import { UserCreateInput } from '@my-org/dto';
import { Button } from '@my-org/ui';

export function CreateUserForm() {
  const [formData, setFormData] = useState<UserCreateInput>({
    email: '',
    username: '',
    password: '',
    profile: {
      firstName: '',
      lastName: ''
    }
  });
  
  // Form handling logic...
  
  return (
    <form>
      {/* Form fields */}
      <Button type="submit">Create User</Button>
    </form>
  );
}
```

#### Example of Managing Dependencies

```json
// Root package.json
{
  "name": "my-fullstack-app",
  "version": "0.0.0",
  "private": true,
  "workspaces": [
    "apps/*",
    "packages/*"
  ],
  "scripts": {
    "build": "turbo run build",
    "dev": "turbo run dev",
    "lint": "turbo run lint",
    "test": "turbo run test",
    "clean": "turbo run clean && rm -rf node_modules"
  },
  "devDependencies": {
    "@typescript-eslint/eslint-plugin": "^5.59.0",
    "@typescript-eslint/parser": "^5.59.0",
    "eslint": "^8.38.0",
    "eslint-config-prettier": "^8.8.0",
    "prettier": "^2.8.7",
    "turbo": "^1.9.3",
    "typescript": "^5.0.4"
  },
  "engines": {
    "node": ">=16.0.0"
  },
  "packageManager": "pnpm@8.0.0"
}

// turbo.json
{
  "$schema": "https://turbo.build/schema.json",
  "globalDependencies": ["**/.env.*local"],
  "pipeline": {
    "build": {
      "dependsOn": ["^build"],
      "outputs": ["dist/**", ".next/**", "!.next/cache/**"]
    },
    "lint": {
      "outputs": []
    },
    "test": {
      "dependsOn": ["build"],
      "outputs": ["coverage/**"],
      "inputs": ["src/**/*.tsx", "src/**/*.ts", "test/**/*.ts", "test/**/*.tsx"]
    },
    "dev": {
      "cache": false,
      "persistent": true
    },
    "clean": {
      "cache": false
    }
  }
}

// packages/ui/package.json
{
  "name": "@my-org/ui",
  "version": "0.1.0",
  "main": "./dist/index.js",
  "module": "./dist/index.mjs",
  "types": "./dist/index.d.ts",
  "files": ["dist"],
  "scripts": {
    "build": "tsup src/index.ts --format esm,cjs --dts",
    "dev": "tsup src/index.ts --format esm,cjs --watch --dts",
    "lint": "eslint src/",
    "test": "jest",
    "clean": "rm -rf dist .turbo node_modules"
  },
  "dependencies": {
    "react": "^18.2.0",
    "react-dom": "^18.2.0"
  },
  "devDependencies": {
    "@types/react": "^18.0.38",
    "@types/react-dom": "^18.0.11",
    "tsup": "^6.7.0",
    "typescript": "^5.0.4"
  }
}

// apps/web/package.json
{
  "name": "@my-org/web",
  "version": "0.1.0",
  "private": true,
  "scripts": {
    "dev": "vite",
    "build": "tsc && vite build",
    "preview": "vite preview",
    "lint": "eslint src/",
    "test": "vitest run",
    "clean": "rm -rf dist .turbo node_modules"
  },
  "dependencies": {
    "@my-org/ui": "workspace:*",
    "@my-org/dto": "workspace:*",
    "@my-org/utils": "workspace:*",
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "react-router-dom": "^6.10.0",
    "axios": "^1.3.6"
  },
  "devDependencies": {
    "@types/react": "^18.0.38",
    "@types/react-dom": "^18.0.11",
    "@vitejs/plugin-react": "^3.1.0",
    "typescript": "^5.0.4",
    "vite": "^4.3.1",
    "vitest": "^0.30.1"
  }
}
```

### Testing in TypeScript Monorepos

#### Test Setup Strategies

Creating consistent test environments across packages is crucial:

```typescript
// packages/test-utils/src/setup.ts
import { afterEach } from 'vitest';
import { cleanup } from '@testing-library/react';
import '@testing-library/jest-dom/extend-expect';

// Global teardown
afterEach(() => {
  cleanup();
});

// Global mocks
global.fetch = vi.fn();
```

#### Component Testing

```typescript
// packages/ui/src/button/__tests__/button.test.tsx
import { render, screen, fireEvent } from '@testing-library/react';
import { Button } from '../button';

describe('Button', () => {
  it('renders with text', () => {
    render(<Button>Click me</Button>);
    expect(screen.getByRole('button')).toHaveTextContent('Click me');
  });

  it('calls onClick when clicked', () => {
    const handleClick = vi.fn();
    render(<Button onClick={handleClick}>Click me</Button>);
    fireEvent.click(screen.getByRole('button'));
    expect(handleClick).toHaveBeenCalledTimes(1);
  });
});
```

#### Integration Testing

```typescript
// apps/web/src/features/auth/__tests__/login.test.tsx
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import { LoginForm } from '../login-form';
import { AuthProvider } from '../../../context/auth-context';

vi.mock('@my-org/api-client', () => ({
  login: vi.fn().mockResolvedValue({ token: 'fake-token' })
}));

describe('LoginForm', () => {
  it('submits credentials and redirects on success', async () => {
    render(
      <AuthProvider>
        <LoginForm />
      </AuthProvider>
    );
    
    fireEvent.change(screen.getByLabelText('Email'), {
      target: { value: 'user@example.com' }
    });
    
    fireEvent.change(screen.getByLabelText('Password'), {
      target: { value: 'password123' }
    });
    
    fireEvent.click(screen.getByRole('button', { name: /sign in/i }));
    
    await waitFor(() => {
      expect(window.location.pathname).toBe('/dashboard');
    });
  });
});
```

### Deploying TypeScript Monorepos

#### Build Optimization for Deployment

```json
// packages/tsconfig.build.json
{
  "extends": "../tsconfig.base.json",
  "compilerOptions": {
    "noEmit": false,
    "sourceMap": false,
    "declaration": true
  }
}
```

#### Deployment Scripts

```bash
#!/bin/bash
# scripts/deploy-api.sh

# Build the API and its dependencies
pnpm turbo run build --filter=@my-org/api...

# Copy deployment files
cp -r apps/api/dist/ deployment/
cp apps/api/package.json deployment/
cp apps/api/Dockerfile deployment/

# Execute deployment (e.g., to a cloud provider)
cd deployment && docker build -t my-api:latest . && docker push my-api:latest
```

#### Continuous Deployment Example

```yaml
# .github/workflows/deploy.yml
name: Deploy
on:
  push:
    branches: [main]
jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
        with:
          fetch-depth: 0
      - uses: pnpm/action-setup@v2
        with:
          version: 8
      - uses: actions/setup-node@v3
        with:
          node-version: 18
          cache: 'pnpm'
      
      - name: Install dependencies
        run: pnpm install
      
      - name: Build affected apps
        run: pnpm turbo run build --filter=[HEAD^1]...
      
      - name: Deploy API
        if: ${{ contains(steps.filter.outputs.changes, 'apps/api') }}
        run: ./scripts/deploy-api.sh
        env:
          AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
          AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
      
      - name: Deploy Web
        if: ${{ contains(steps.filter.outputs.changes, 'apps/web') }}
        run: ./scripts/deploy-web.sh
        env:
          VERCEL_TOKEN: ${{ secrets.VERCEL_TOKEN }}
```

### Advanced Monorepo Patterns

#### Module Federation

For large applications that need to be split into micro-frontends:

```javascript
// apps/shell/webpack.config.js
const { ModuleFederationPlugin } = require('webpack').container;

module.exports = {
  // ... webpack config
  plugins: [
    new ModuleFederationPlugin({
      name: 'shell',
      remotes: {
        dashboard: 'dashboard@http://localhost:3001/remoteEntry.js',
        profile: 'profile@http://localhost:3002/remoteEntry.js'
      },
      shared: {
        react: { singleton: true },
        'react-dom': { singleton: true }
      }
    })
  ]
};
```

#### Architectural Boundaries

```typescript
// packages/domain/src/user/index.ts
// Domain layer - business logic

export class User {
  constructor(
    public readonly id: string,
    public readonly email: string,
    public readonly username: string,
    private _isActive: boolean = false
  ) {}

  activate() {
    this._isActive = true;
    return this;
  }

  deactivate() {
    this._isActive = false;
    return this;
  }

  get isActive() {
    return this._isActive;
  }
}

// packages/infrastructure/src/repositories/user.repository.ts
// Infrastructure layer - data access

import { User } from '@my-org/domain';
import { PrismaClient } from '@prisma/client';

export class UserRepository {
  constructor(private prisma: PrismaClient) {}

  async findById(id: string): Promise<User | null> {
    const userData = await this.prisma.user.findUnique({
      where: { id }
    });

    if (!userData) return null;

    return new User(
      userData.id,
      userData.email,
      userData.username,
      userData.isActive
    );
  }
}
```

#### Feature Toggles

```typescript
// packages/config/src/features.ts
export const FEATURES = {
  NEW_USER_FLOW: process.env.FEATURE_NEW_USER_FLOW === 'true',
  BETA_DASHBOARD: process.env.FEATURE_BETA_DASHBOARD === 'true',
  DARK_MODE: true
};

// apps/web/src/components/user-registration.tsx
import { FEATURES } from '@my-org/config';
import { NewUserFlow } from './new-user-flow';
import { LegacyUserFlow } from './legacy-user-flow';

export function UserRegistration() {
  return FEATURES.NEW_USER_FLOW ? <NewUserFlow /> : <LegacyUserFlow />;
}
```

### Migration Strategies

#### Gradually Adopting a Monorepo

1. Start with a core package
2. Move shared code to separate packages
3. Establish clear dependencies between packages
4. Implement proper tooling

#### Migrating from JavaScript to TypeScript

1. Add TypeScript as a dev dependency
2. Create initial tsconfig.json
3. Rename files from .js to .ts (or .jsx to .tsx)
4. Add type definitions incrementally
5. Enable stricter TypeScript settings over time

#### Example Migration Plan

```
Phase 1: Setup & Infrastructure
- Set up monorepo tooling
- Create base tsconfig files
- Establish CI/CD pipelines

Phase 2: Core Libraries
- Migrate common utilities to TypeScript
- Create shared type definitions
- Update build processes

Phase 3: Applications
- Migrate applications one by one
- Update import paths to use workspace references
- Implement comprehensive testing

Phase 4: Optimization
- Optimize build performance
- Implement caching strategies
- Deploy with proper bundling and minification
```

### Conclusion

TypeScript monorepos provide substantial benefits for managing complex applications with multiple packages. By leveraging the type system across package boundaries, teams can build more maintainable and robust applications. The tools and patterns presented here offer a solid foundation for implementing your own TypeScript monorepo strategy.

When implemented correctly, a TypeScript monorepo can:

- Enforce type safety across package boundaries
- Simplify dependency management
- Enable code sharing while maintaining clear boundaries
- Improve developer experience with faster builds
- Enhance collaboration between teams working on different packages

**Key Points**:

- Choose the right tools based on your project scale (Nx for large projects, Turborepo for simpler setups)
- Establish clear architectural boundaries between packages
- Use project references to improve build performance
- Implement comprehensive testing across package boundaries
- Adopt incremental migration strategies when converting existing projects

### Additional Resources

- TypeScript Project References: [Official Documentation](https://www.typescriptlang.org/docs/handbook/project-references.html)
- Nx Documentation: [nx.dev](https://nx.dev/)
- Turborepo Documentation: [turbo.build](https://turbo.build/)
- pnpm Workspaces: [pnpm.io/workspaces](https://pnpm.io/workspaces)
- Microsoft's API Extractor: [api-extractor.com](https://api-extractor.com/)

---

## Emerging Patterns and Best Practices in TypeScript

### Branded Types

Branded types provide a way to create nominal typing in TypeScript's structural type system. They allow you to differentiate between types that would otherwise be structurally equivalent.

**Key Points**

- Creates type safety for primitive types like strings and numbers
- Prevents mixing of semantically different values with the same base type
- Enables compile-time validation without runtime overhead
- Improves API clarity by making the domain model more explicit

#### Basic Implementation

```typescript
// Creating branded types
type Brand<K, T> = K & { readonly __brand: unique symbol & T };

type UserId = Brand<string, { readonly __brand: unique symbol & "UserId" }>;
type ProductId = Brand<string, { readonly __brand: unique symbol & "ProductId" }>;

// Creating branded values
function createUserId(id: string): UserId {
  return id as UserId;
}

// Usage
const userId = createUserId("user-123");
const productId = createUserId("product-456") as unknown as ProductId;

// Type safety
function getUser(id: UserId) { /* ... */ }

getUser(userId); // Works
// getUser(productId); // Error: Argument of type 'ProductId' is not assignable to parameter of type 'UserId'
// getUser("raw-string"); // Error: Argument of type 'string' is not assignable to parameter of type 'UserId'
```

#### Advanced Branded Type Patterns

```typescript
// With validation
function createUserId(id: string): UserId {
  if (!id.startsWith("user-")) {
    throw new Error("Invalid user ID format");
  }
  return id as UserId;
}

// With template literal types (TS 4.1+)
type EmailAddress = Brand<`${string}@${string}.${string}`, "EmailAddress">;

// With numeric constraints
type PositiveNumber = Brand<number, "PositiveNumber">;

function createPositiveNumber(n: number): PositiveNumber {
  if (n <= 0) throw new Error("Number must be positive");
  return n as PositiveNumber;
}
```

### Nominal Typing Techniques

While TypeScript is structurally typed by default, several techniques can introduce nominal typing behaviors.

**Key Points**

- Prevents type confusion between structurally similar types
- Makes interfaces incompatible even with identical shapes
- Reduces accidental assignments between semantically different types
- Especially useful for domain-driven design

#### Using Unique Symbols

```typescript
declare const UserIdSymbol: unique symbol;
declare const OrderIdSymbol: unique symbol;

type UserId = string & { [UserIdSymbol]: never };
type OrderId = string & { [OrderIdSymbol]: never };

function processUser(id: UserId) { /* ... */ }

const userId = "user123" as UserId;
const orderId = "order456" as OrderId;

processUser(userId); // Works
// processUser(orderId); // Error
```

#### Class-Based Nominal Typing

```typescript
class EmailAddress {
  private __emailBrand: void;
  constructor(public readonly value: string) {
    if (!value.includes('@')) throw new Error('Invalid email');
  }
}

class Username {
  private __usernameBrand: void;
  constructor(public readonly value: string) {
    if (value.length < 3) throw new Error('Username too short');
  }
}

// Even though both have a 'value' property of type string, they're not compatible
function sendEmail(address: EmailAddress) { /* ... */ }

const email = new EmailAddress("user@example.com");
const username = new Username("johnsmith");

sendEmail(email); // Works
// sendEmail(username); // Error: Argument of type 'Username' is not assignable to parameter of type 'EmailAddress'
```

#### Enum-Like Pattern

```typescript
const PaymentMethod = {
  CreditCard: "credit-card" as const,
  PayPal: "paypal" as const,
  BankTransfer: "bank-transfer" as const,
} as const;

type PaymentMethodType = typeof PaymentMethod[keyof typeof PaymentMethod];

interface Payment {
  method: PaymentMethodType;
  amount: number;
}

// Type-safe payment method
const payment: Payment = {
  method: PaymentMethod.CreditCard, // Type-checked
  amount: 100
};

// payment.method = "cash"; // Error: Type '"cash"' is not assignable to type 'PaymentMethodType'
```

### Dependency Injection Patterns

Dependency injection in TypeScript provides cleaner, more testable, and more maintainable code architectures.

**Key Points**

- Promotes loose coupling between components
- Facilitates unit testing through mock dependencies
- Improves code reusability and modularity
- TypeScript's type system ensures correct implementation

#### Constructor Injection

```typescript
interface Logger {
  log(message: string): void;
}

interface Database {
  query(sql: string): Promise<any[]>;
}

class UserService {
  constructor(
    private logger: Logger,
    private database: Database
  ) {}
  
  async getUsers(): Promise<User[]> {
    this.logger.log("Fetching users");
    return this.database.query("SELECT * FROM users");
  }
}

// Usage
const consoleLogger: Logger = {
  log: (message) => console.log(message)
};

const sqlDatabase: Database = {
  query: async (sql) => {
    // Implementation
    return [];
  }
};

const userService = new UserService(consoleLogger, sqlDatabase);
```

#### Property Injection

```typescript
class UserController {
  @inject("UserService")
  private userService?: UserService;
  
  async getUsers() {
    if (!this.userService) {
      throw new Error("UserService not injected");
    }
    return this.userService.getUsers();
  }
}
```

#### DI Containers

```typescript
import { container, injectable, inject } from "tsyringe";

@injectable()
class UserRepository {
  async findAll(): Promise<User[]> {
    // Implementation
    return [];
  }
}

@injectable()
class UserService {
  constructor(
    @inject(UserRepository) private repository: UserRepository
  ) {}
  
  async getUsers(): Promise<User[]> {
    return this.repository.findAll();
  }
}

// Register dependencies
container.register("UserRepository", UserRepository);

// Resolve with dependencies injected
const userService = container.resolve(UserService);
```

#### Interface-Based DI with Abstract Factories

```typescript
interface UserRepositoryFactory {
  create(): UserRepository;
}

class UserService {
  private repository: UserRepository;
  
  constructor(repositoryFactory: UserRepositoryFactory) {
    this.repository = repositoryFactory.create();
  }
}
```

### State Management Patterns

TypeScript adds compile-time safety to state management approaches, creating more robust application architectures.

**Key Points**

- Type safety across state mutations and access
- Compiler assistance with refactoring state shapes
- Improved developer experience through autocompletion
- Enables advanced patterns like discriminated unions for state

#### Immutable State Pattern

```typescript
interface AppState {
  readonly users: ReadonlyArray<User>;
  readonly selectedUserId: string | null;
  readonly isLoading: boolean;
}

// State updater function
function updateState(state: AppState, updates: Partial<AppState>): AppState {
  return { ...state, ...updates };
}

// Usage
let state: AppState = { users: [], selectedUserId: null, isLoading: false };
state = updateState(state, { isLoading: true });
state = updateState(state, { users: [...state.users, newUser] });
```

#### Reducer Pattern (Redux-like)

```typescript
type Action = 
  | { type: "FETCH_USERS_START" }
  | { type: "FETCH_USERS_SUCCESS", payload: User[] }
  | { type: "FETCH_USERS_ERROR", error: Error }
  | { type: "SELECT_USER", userId: string };

function reducer(state: AppState, action: Action): AppState {
  switch (action.type) {
    case "FETCH_USERS_START":
      return { ...state, isLoading: true };
    case "FETCH_USERS_SUCCESS":
      return { ...state, users: action.payload, isLoading: false };
    case "FETCH_USERS_ERROR":
      return { ...state, error: action.error, isLoading: false };
    case "SELECT_USER":
      return { ...state, selectedUserId: action.userId };
    default:
      return state;
  }
}
```

#### State Machines with Discriminated Unions

```typescript
type AuthState = 
  | { status: "unauthenticated" }
  | { status: "authenticating", username: string }
  | { status: "authenticated", user: User }
  | { status: "error", error: string };

function transition(state: AuthState, event: AuthEvent): AuthState {
  switch (state.status) {
    case "unauthenticated":
      if (event.type === "LOGIN") {
        return { status: "authenticating", username: event.username };
      }
      break;
    case "authenticating":
      if (event.type === "AUTH_SUCCESS") {
        return { status: "authenticated", user: event.user };
      } else if (event.type === "AUTH_FAILURE") {
        return { status: "error", error: event.error };
      }
      break;
    // Handle other state transitions
  }
  return state;
}
```

#### Context-Based State Management

```typescript
// State definition with type-safe context
interface UserContextState {
  users: User[];
  selectedUser: User | null;
  isLoading: boolean;
  error: Error | null;
}

interface UserContextActions {
  fetchUsers(): Promise<void>;
  selectUser(userId: string): void;
  addUser(user: User): void;
}

const UserContext = React.createContext
  { state: UserContextState; actions: UserContextActions } | undefined
>(undefined);

// Type-safe hook
function useUserContext() {
  const context = React.useContext(UserContext);
  if (!context) {
    throw new Error("useUserContext must be used within a UserProvider");
  }
  return context;
}
```

### Advanced TypeScript Patterns

#### Type-Safe Event Emitter

```typescript
type Events = {
  'user:created': [user: User];
  'user:updated': [user: User, prevData: User];
  'error': [error: Error];
};

class TypedEventEmitter<T extends Record<string, any[]>> {
  private listeners: Partial<Record<keyof T, Function[]>> = {};

  on<K extends keyof T>(event: K, listener: (...args: T[K]) => void): this {
    if (!this.listeners[event]) {
      this.listeners[event] = [];
    }
    this.listeners[event]?.push(listener);
    return this;
  }

  emit<K extends keyof T>(event: K, ...args: T[K]): boolean {
    if (!this.listeners[event]) return false;
    this.listeners[event]?.forEach(listener => listener(...args));
    return true;
  }
}

// Usage
const emitter = new TypedEventEmitter<Events>();
emitter.on('user:created', (user) => {
  console.log(`User created: ${user.name}`);
});
```

#### Builder Pattern with Method Chaining

```typescript
class QueryBuilder<T> {
  private conditions: string[] = [];
  private limitValue?: number;
  private offsetValue?: number;

  where(condition: string): this {
    this.conditions.push(condition);
    return this;
  }

  limit(limit: number): this {
    this.limitValue = limit;
    return this;
  }

  offset(offset: number): this {
    this.offsetValue = offset;
    return this;
  }

  build(): string {
    let query = "SELECT * FROM items";
    
    if (this.conditions.length > 0) {
      query += ` WHERE ${this.conditions.join(" AND ")}`;
    }
    
    if (this.limitValue !== undefined) {
      query += ` LIMIT ${this.limitValue}`;
    }
    
    if (this.offsetValue !== undefined) {
      query += ` OFFSET ${this.offsetValue}`;
    }
    
    return query;
  }
}

// Usage with full type safety
const query = new QueryBuilder<User>()
  .where("age > 30")
  .limit(10)
  .offset(20)
  .build();
```

### Practical Implementations

#### Factory Pattern with Type Guards

```typescript
interface ShapeFactory {
  createCircle(radius: number): Circle;
  createRectangle(width: number, height: number): Rectangle;
  createTriangle(a: number, b: number, c: number): Triangle;
}

function isCircle(shape: Shape): shape is Circle {
  return (shape as Circle).radius !== undefined;
}

function isRectangle(shape: Shape): shape is Rectangle {
  return (shape as Rectangle).width !== undefined 
      && (shape as Rectangle).height !== undefined;
}

// Usage with type narrowing
function calculateArea(shape: Shape): number {
  if (isCircle(shape)) {
    return Math.PI * shape.radius * shape.radius;
  } else if (isRectangle(shape)) {
    return shape.width * shape.height;
  } else {
    // TypeScript knows this must be a Triangle
    const s = (shape.a + shape.b + shape.c) / 2;
    return Math.sqrt(s * (s - shape.a) * (s - shape.b) * (s - shape.c));
  }
}
```

#### Command Pattern with Type Safety

```typescript
interface Command<T = void> {
  execute(): T;
  undo(): void;
}

class AddUserCommand implements Command<User> {
  private addedUser?: User;
  
  constructor(
    private userService: UserService,
    private userData: UserDto
  ) {}
  
  execute(): User {
    this.addedUser = this.userService.add(this.userData);
    return this.addedUser;
  }
  
  undo(): void {
    if (this.addedUser) {
      this.userService.remove(this.addedUser.id);
    }
  }
}

// Command executor
class CommandProcessor {
  private history: Command[] = [];
  
  execute<T>(command: Command<T>): T {
    const result = command.execute();
    this.history.push(command);
    return result;
  }
  
  undoLast(): void {
    const command = this.history.pop();
    if (command) {
      command.undo();
    }
  }
}
```

### Recommended Related Topics

- TypeScript Decorators and metadata reflection
- Advanced mapped types for API responses
- Higher-order components with TypeScript generics
- Functional programming patterns in TypeScript
- Property-based testing of TypeScript interfaces