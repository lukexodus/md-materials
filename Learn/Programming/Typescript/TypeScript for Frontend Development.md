# TypeScript for Frontend Development

A comprehensive guide from first principles to production-ready patterns.

---

## Table of Contents

1. [What Is TypeScript and Why Does It Exist](#1-what-is-typescript-and-why-does-it-exist)
2. [The TypeScript Compiler and Type Checking](#2-the-typescript-compiler-and-type-checking)
3. [tsconfig Fundamentals](#3-tsconfig-fundamentals)
4. [Primitive Types](#4-primitive-types)
5. [Arrays and Tuples](#5-arrays-and-tuples)
6. [Objects and Interfaces](#6-objects-and-interfaces)
7. [Type Aliases vs Interfaces](#7-type-aliases-vs-interfaces)
8. [Special Types: any, unknown, never, void](#8-special-types-any-unknown-never-void)
9. [Null and Undefined](#9-null-and-undefined)
10. [Union Types and Literal Types](#10-union-types-and-literal-types)
11. [Intersection Types](#11-intersection-types)
12. [Enums vs Union Literals](#12-enums-vs-union-literals)
13. [Type Narrowing and Type Guards](#13-type-narrowing-and-type-guards)
14. [Type Assertions](#14-type-assertions)
15. [Functions](#15-functions)
16. [Generics](#16-generics)
17. [Mapped Types and Utility Types](#17-mapped-types-and-utility-types)
18. [Advanced Types](#18-advanced-types)
19. [TypeScript with React](#19-typescript-with-react)
20. [Typing Frontend APIs](#20-typing-frontend-apis)
21. [Forms and Events](#21-forms-and-events)
22. [State Management Patterns](#22-state-management-patterns)
23. [Real-World Project Patterns](#23-real-world-project-patterns)
24. [Best Practices and Anti-Patterns](#24-best-practices-and-anti-patterns)

---

## 1. What Is TypeScript and Why Does It Exist

### The problem TypeScript solves

JavaScript was designed for small scripts. It uses *dynamic typing*: variables have no declared type, and the interpreter figures things out at runtime. This is fine for a 50-line form validator. It becomes expensive at scale.

```js
// Pure JavaScript — this crashes at runtime, not at write-time
function getUser(id) {
  return fetch(`/api/users/${id}`).then(res => res.json());
}

const user = getUser(42);
console.log(user.nme); // typo — "nme" instead of "name"
// No error until you run the code and look at the console
```

The bug above is invisible until a user triggers it. In a large codebase with dozens of contributors, this class of error consumes serious time.

**Static typing** means types are checked *before the code runs* — at the moment you write it, in your editor. TypeScript adds a static type layer on top of JavaScript.

```ts
interface User {
  id: number;
  name: string;
  email: string;
}

async function getUser(id: number): Promise<User> {
  const res = await fetch(`/api/users/${id}`);
  return res.json();
}

const user = await getUser(42);
console.log(user.nme); // ERROR: Property 'nme' does not exist on type 'User'
// Red squiggle in your editor, before you run anything
```

### TypeScript is a superset of JavaScript

Every valid JavaScript file is valid TypeScript. You add types on top; TypeScript compiles them away, producing plain JavaScript that browsers and Node can run. The types are a *development-time tool only* — they have zero runtime presence.

```
Your TypeScript (.ts)  →  TypeScript Compiler (tsc)  →  JavaScript (.js)
```

### What TypeScript gives you

- **Catch errors before runtime.** Typos, wrong argument types, missing properties — flagged immediately.
- **Autocomplete and IntelliSense.** Your editor knows the shape of every object, so it can suggest properties and methods accurately.
- **Safe refactoring.** Rename a function parameter and TypeScript tells you every call site that breaks.
- **Self-documenting code.** A function signature like `(user: User, role: Role) => boolean` communicates intent that no comment could match.

### What TypeScript does *not* give you

- Runtime safety. Types are erased at compile time. If bad data arrives from an API at runtime, TypeScript cannot stop it — you need runtime validation (Zod, Yup, etc.) for that.
- Performance improvements. The compiled JavaScript is equivalent to handwritten JS.

---

## 2. The TypeScript Compiler and Type Checking

### How it works

The TypeScript compiler (`tsc`) reads your `.ts` files, checks types, and emits `.js` output. In practice, most frontend projects use a bundler (Vite, webpack) that handles the emit, while a separate type-check step (often `tsc --noEmit` in CI) validates types.

```bash
# Install TypeScript locally in a project
npm install --save-dev typescript

# Check types without emitting files
npx tsc --noEmit

# Emit JavaScript from TypeScript source
npx tsc
```

### Type inference

TypeScript can often figure out types without you writing them. This is called *inference*.

```ts
// You don't have to annotate this — TypeScript infers: number
const count = 42;

// TypeScript infers: string[]
const names = ['Alice', 'Bob', 'Carol'];

// TypeScript infers the return type: number
function add(a: number, b: number) {
  return a + b;
}
```

Write annotations where inference needs help, or where they serve as documentation. Don't annotate every single thing — that creates noise.

### Static vs dynamic typing side by side

```ts
// JavaScript (dynamic) — type confusion at runtime
function formatPrice(price) {
  return '$' + price.toFixed(2); // crashes if price is a string
}

formatPrice('free'); // Runtime error: price.toFixed is not a function

// TypeScript (static) — caught before running
function formatPrice(price: number): string {
  return '$' + price.toFixed(2);
}

formatPrice('free'); // Compile error: Argument of type 'string' is not assignable to parameter of type 'number'
```

---

## 3. tsconfig Fundamentals

`tsconfig.json` is the configuration file that controls how TypeScript compiles your project. Place it at the project root.

```json
{
  "compilerOptions": {
    "target": "ES2020",
    "lib": ["ES2020", "DOM", "DOM.Iterable"],
    "module": "ESNext",
    "moduleResolution": "bundler",
    "jsx": "react-jsx",
    "strict": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noFallthroughCasesInSwitch": true,
    "outDir": "./dist",
    "rootDir": "./src",
    "baseUrl": ".",
    "paths": {
      "@/*": ["src/*"]
    }
  },
  "include": ["src"],
  "exclude": ["node_modules", "dist"]
}
```

### Key options explained

`target` — What JavaScript version to output. `ES2020` is safe for modern browsers and Node 14+.

`lib` — Which built-in APIs TypeScript knows about. `DOM` includes `document`, `window`, `fetch`, etc.

`jsx` — How to handle JSX. `react-jsx` uses the modern JSX transform (React 17+), no `import React` needed.

`strict` — The most important flag. Enables a bundle of strict checks (see below).

`moduleResolution: "bundler"` — Matches how Vite/webpack resolve imports. Use `"node"` for Node-only projects.

`noUnusedLocals` / `noUnusedParameters` — Errors on declared-but-unused variables and parameters. Keeps code clean.

### Why strict mode matters

`"strict": true` enables several critical checks at once:

```json
// What "strict": true turns on:
"strictNullChecks": true,        // null/undefined must be handled explicitly
"strictFunctionTypes": true,     // stricter function parameter checking
"strictBindCallApply": true,     // correct types for .bind/.call/.apply
"noImplicitAny": true,           // variables can't silently become 'any'
"noImplicitThis": true,          // 'this' must have a known type
"strictPropertyInitialization": true  // class properties must be initialized
```

The most important of these is `strictNullChecks`. Without it, TypeScript allows `null` and `undefined` anywhere, which defeats a large portion of the value of using TypeScript at all.

**Always use `"strict": true` in new projects.** The extra discipline it requires upfront pays back many times over.

---

## 4. Primitive Types

TypeScript has type annotations for every JavaScript primitive.

```ts
// string
const firstName: string = 'Alice';
const greeting: string = `Hello, ${firstName}`;

// number — integers and floats share one type
const age: number = 30;
const price: number = 9.99;

// boolean
const isLoggedIn: boolean = true;
const hasPermission: boolean = false;

// bigint (large integers)
const largeId: bigint = 9007199254740993n;

// symbol
const key: symbol = Symbol('uniqueKey');
```

In practice, you rarely write these annotations explicitly — TypeScript infers them from the values. You write them when declaring variables without initializing them, or as function parameter and return types.

```ts
// These two are equivalent — prefer the inferred form
const name: string = 'Alice'; // explicit annotation
const name = 'Alice';         // inferred — TypeScript knows it's a string

// Parameter types always need annotation
function greet(name: string): string {
  return `Hello, ${name}`;
}
```

### Common mistake: confusing type annotations with values

```ts
// Wrong — this is a JavaScript class, not a type annotation
const name: String = 'Alice'; // capital S — the String wrapper object

// Correct — lowercase primitives
const name: string = 'Alice';
```

Always use lowercase `string`, `number`, `boolean` for primitives. The uppercase versions (`String`, `Number`, `Boolean`) refer to JavaScript wrapper objects and are almost never what you want.

---

## 5. Arrays and Tuples

### Arrays

Two equivalent syntaxes for typed arrays:

```ts
// Syntax 1: type followed by []
const names: string[] = ['Alice', 'Bob', 'Carol'];
const scores: number[] = [98, 87, 92];

// Syntax 2: generic Array<T>
const names: Array<string> = ['Alice', 'Bob', 'Carol'];
```

Prefer `string[]` for simple cases; `Array<T>` reads better with complex types.

```ts
// Array of objects
interface Product {
  id: number;
  name: string;
  price: number;
}

const products: Product[] = [
  { id: 1, name: 'Widget', price: 9.99 },
  { id: 2, name: 'Gadget', price: 24.99 },
];

// TypeScript knows what you get back from array methods
const expensiveProducts = products.filter(p => p.price > 10);
// TypeScript infers: Product[]

const firstProduct = products[0];
// TypeScript infers: Product (or Product | undefined with noUncheckedIndexedAccess)
```

### Readonly arrays

Prevent mutations on arrays you pass around:

```ts
function displayItems(items: readonly string[]): void {
  // items.push('extra'); // Error: Property 'push' does not exist on type 'readonly string[]'
  items.forEach(item => console.log(item)); // Fine — reading is allowed
}
```

### Tuples

A tuple is an array with a *fixed length* and *known type at each position*. JavaScript has no tuples — TypeScript models them using arrays.

```ts
// Declare a tuple: [latitude, longitude]
const coordinates: [number, number] = [51.5074, -0.1278];

const lat = coordinates[0]; // TypeScript knows: number
const lng = coordinates[1]; // TypeScript knows: number
const z   = coordinates[2]; // Error: Tuple type '[number, number]' of length '2' has no element at index '2'
```

**Named tuples** (TypeScript 4.0+) make the positions self-documenting:

```ts
type RGB = [red: number, green: number, blue: number];
const color: RGB = [255, 128, 0];
```

**When to use tuples:** The most common real-world use is as return types from custom hooks, matching React's `useState` pattern:

```ts
function useToggle(initial: boolean): [boolean, () => void] {
  const [value, setValue] = useState(initial);
  const toggle = () => setValue(v => !v);
  return [value, toggle];
}

const [isOpen, toggleOpen] = useToggle(false);
// isOpen: boolean
// toggleOpen: () => void
```

### Exercise

Define a type for a board game coordinate: a tuple of `[column: string, row: number]` (like chess notation `['e', 4]`). Write a function that takes such a coordinate and returns a display string like `"e4"`.

---

## 6. Objects and Interfaces

### Inline object types

You can type an object inline, but this gets repetitive:

```ts
function greetUser(user: { name: string; age: number }): string {
  return `Hello ${user.name}, you are ${user.age}`;
}
```

### Interfaces

An interface gives a reusable name to an object shape:

```ts
interface User {
  id: number;
  name: string;
  email: string;
  age: number;
}

function greetUser(user: User): string {
  return `Hello ${user.name}`;
}

const user: User = {
  id: 1,
  name: 'Alice',
  email: 'alice@example.com',
  age: 30,
};
```

TypeScript uses *structural typing*: an object is compatible with an interface if it has at least the required properties, regardless of where it came from. This is different from languages like Java where types must be explicitly declared.

```ts
interface HasName {
  name: string;
}

function printName(thing: HasName) {
  console.log(thing.name);
}

// Any object with a 'name' string property is compatible
printName({ name: 'Alice', age: 30, role: 'admin' }); // Fine
```

### Optional properties

```ts
interface UserProfile {
  id: number;
  name: string;
  bio?: string;        // optional — string | undefined
  avatarUrl?: string;  // optional
}

const user: UserProfile = {
  id: 1,
  name: 'Alice',
  // bio and avatarUrl are not required
};

// When using optional properties, narrow before using
if (user.bio) {
  console.log(user.bio.toUpperCase()); // Safe — TypeScript knows it's a string here
}
```

### Readonly properties

```ts
interface Config {
  readonly apiUrl: string;
  readonly timeout: number;
}

const config: Config = {
  apiUrl: 'https://api.example.com',
  timeout: 5000,
};

config.apiUrl = 'https://other.com'; // Error: Cannot assign to 'apiUrl' because it is a read-only property
```

### Extending interfaces

```ts
interface Animal {
  name: string;
  age: number;
}

interface Dog extends Animal {
  breed: string;
  isGoodBoy: boolean;
}

const dog: Dog = {
  name: 'Rex',
  age: 3,
  breed: 'Labrador',
  isGoodBoy: true,
};
```

### Index signatures

When you don't know the property names ahead of time:

```ts
interface StringMap {
  [key: string]: string;
}

const translations: StringMap = {
  hello: 'Hola',
  goodbye: 'Adiós',
  thanks: 'Gracias',
};

// Real-world example: component styles object
interface StyleProps {
  [className: string]: React.CSSProperties;
}
```

**Caution:** Index signatures weaken type safety because any key is allowed. Prefer known shapes where possible.

---

## 7. Type Aliases vs Interfaces

Both `type` and `interface` can describe the shape of an object. They have meaningful differences.

### Interfaces

```ts
interface User {
  id: number;
  name: string;
}

// Interfaces can be extended
interface AdminUser extends User {
  role: 'admin';
  permissions: string[];
}

// Interfaces can be merged (declaration merging)
interface Window {
  myCustomProperty: string; // Adds to the existing Window interface
}
```

### Type aliases

```ts
type User = {
  id: number;
  name: string;
};

// Types can describe anything interfaces cannot
type ID = string | number;
type Status = 'loading' | 'success' | 'error';
type Nullable<T> = T | null;
type Callback = () => void;

// Types compose with intersections
type AdminUser = User & {
  role: 'admin';
  permissions: string[];
};
```

### When to use which

Use `interface` for:
- Object shapes that represent domain models (`User`, `Product`, `Order`)
- Props and component APIs in React
- Anything that might be extended or implemented by a class
- Public library APIs (declaration merging is useful)

Use `type` for:
- Union types (`type Status = 'loading' | 'success' | 'error'`)
- Primitive aliases (`type UserID = string`)
- Computed types using utility types or conditionals
- Function types (`type Handler = (event: MouseEvent) => void`)
- Tuples

**The practical rule:** Use `interface` for objects; use `type` for everything else. When in doubt, `interface` is slightly preferred for object shapes because it produces better error messages and supports declaration merging.

```ts
// Prefer interface for component props
interface ButtonProps {
  label: string;
  onClick: () => void;
  disabled?: boolean;
  variant?: 'primary' | 'secondary';
}

// Prefer type for unions and computed types
type ButtonVariant = 'primary' | 'secondary' | 'ghost';
type ButtonSize = 'sm' | 'md' | 'lg';
```

---

## 8. Special Types: any, unknown, never, void

### `any`

`any` turns off type checking for a value. It's an escape hatch.

```ts
let value: any = 42;
value = 'now a string'; // Fine
value = { anything: 'goes' }; // Fine
value.nonExistentMethod(); // No error — TypeScript looks away
```

The problem: `any` is contagious. Anything that touches an `any` value loses type information. Avoid it except when incrementally migrating a JavaScript codebase.

### `unknown`

`unknown` is the safe counterpart to `any`. A value can be `unknown`, but you must *narrow* it before doing anything with it.

```ts
function processInput(input: unknown) {
  // Can't use input directly
  console.log(input.toUpperCase()); // Error: Object is of type 'unknown'

  // Must narrow first
  if (typeof input === 'string') {
    console.log(input.toUpperCase()); // Fine — TypeScript knows it's a string here
  }
}
```

**Use `unknown` instead of `any` when:**
- Receiving data from an external source (API responses, user input, `JSON.parse`)
- Writing a function that can accept truly any value but must handle it safely

```ts
// Bad — suppresses all type errors
function parseData(raw: any) {
  return raw.data.items; // Might crash at runtime — no protection
}

// Good — forces explicit handling
function parseData(raw: unknown) {
  if (
    typeof raw === 'object' &&
    raw !== null &&
    'data' in raw
  ) {
    // Now TypeScript knows raw has a 'data' property
    // Further narrowing needed for full safety
  }
}
```

### `never`

`never` represents a value that can *never* exist. It appears in two main situations:

**1. Functions that never return:**

```ts
function throwError(message: string): never {
  throw new Error(message);
  // No return — execution never reaches the end
}

function infiniteLoop(): never {
  while (true) {}
}
```

**2. Exhaustive checks in unions:**

```ts
type Shape = 'circle' | 'square' | 'triangle';

function getArea(shape: Shape): number {
  switch (shape) {
    case 'circle':  return Math.PI * 5 * 5;
    case 'square':  return 5 * 5;
    case 'triangle': return 0.5 * 5 * 5;
    default:
      // If you add a new shape and forget to handle it,
      // TypeScript errors here because 'shape' would be 'never'
      const _exhaustiveCheck: never = shape;
      return _exhaustiveCheck;
  }
}
```

### `void`

`void` means "this function returns nothing useful." It's used for callback return types and event handlers.

```ts
function logMessage(message: string): void {
  console.log(message);
  // No return statement (or returns undefined)
}

// Common in React event handlers
const handleClick: () => void = () => {
  setIsOpen(true);
};
```

**`void` vs `undefined`:** A function typed as `() => undefined` must explicitly `return undefined`. A function typed as `() => void` can return any value — it just signals to callers that the return value will be ignored.

---

## 9. Null and Undefined

JavaScript has both `null` (intentionally empty) and `undefined` (unset). TypeScript treats them as distinct types.

### With strict null checks

With `"strictNullChecks": true` (included in `strict`), `null` and `undefined` are not assignable to other types:

```ts
let name: string = 'Alice';
name = null;      // Error: Type 'null' is not assignable to type 'string'
name = undefined; // Error: Type 'undefined' is not assignable to type 'string'

// To allow null, use a union type
let name: string | null = 'Alice';
name = null; // Now fine
```

### Optional chaining (`?.`)

Before using a nullable value, you must handle the null case. Optional chaining is a JavaScript feature TypeScript understands:

```ts
interface User {
  name: string;
  address?: {
    city: string;
    country: string;
  };
}

const user: User = { name: 'Alice' };

// Without optional chaining — crashes if address is undefined
const city = user.address.city; // Error at runtime

// With optional chaining — returns undefined safely
const city = user.address?.city; // string | undefined
```

### Nullish coalescing (`??`)

Provide a fallback for `null` or `undefined`:

```ts
const displayName = user.name ?? 'Anonymous';
// If user.name is null or undefined, use 'Anonymous'
// Unlike || (or), ?? only triggers on null/undefined, not on 0, '', or false
```

### Non-null assertion (`!`)

Sometimes you know a value isn't null, but TypeScript doesn't. Use `!` to assert non-null. Use it sparingly.

```ts
// You're telling TypeScript: "Trust me, this is not null"
const element = document.getElementById('root')!;
element.innerHTML = 'Hello'; // No null check needed

// Risky — if getElementById returns null, this crashes at runtime
// Safer alternative:
const element = document.getElementById('root');
if (!element) throw new Error('Root element not found');
element.innerHTML = 'Hello';
```

---

## 10. Union Types and Literal Types

### Union types

A union type says a value can be one of several types, joined with `|`.

```ts
// A value that is either a string or a number
type StringOrNumber = string | number;

function formatId(id: string | number): string {
  if (typeof id === 'number') {
    return id.toString().padStart(6, '0');
  }
  return id;
}

formatId(42);     // '000042'
formatId('abc');  // 'abc'
```

### Literal types

A literal type restricts a value to a *specific* value, not just a general type.

```ts
// Not just any string — only these specific strings
type Direction = 'north' | 'south' | 'east' | 'west';
type HttpMethod = 'GET' | 'POST' | 'PUT' | 'DELETE' | 'PATCH';
type StatusCode = 200 | 201 | 400 | 401 | 403 | 404 | 500;

function navigate(direction: Direction): void {
  // direction is guaranteed to be one of the four values
}

navigate('north'); // Fine
navigate('up');    // Error: Argument of type '"up"' is not assignable to parameter of type 'Direction'
```

This is the most common pattern in frontend code for things like:
- Component variants (`'primary' | 'secondary' | 'ghost'`)
- Status values (`'idle' | 'loading' | 'success' | 'error'`)
- Theme names (`'light' | 'dark' | 'system'`)
- API method names

### Combining unions

```ts
type ID = string | number;
type NullableString = string | null;
type OptionalNumber = number | undefined;
type Result = string | number | boolean | null;
```

### `as const` — turning values into literal types

```ts
// Without as const: TypeScript infers string, not literal 'admin'
const role = 'admin'; // TypeScript infers: string

// With const declaration: TypeScript infers the literal
const role = 'admin' as const; // TypeScript infers: 'admin'

// Useful for objects — preserves exact values
const ROUTES = {
  home: '/',
  about: '/about',
  login: '/login',
} as const;

// ROUTES.home is typed as '/' not string
type Route = typeof ROUTES[keyof typeof ROUTES]; // '/' | '/about' | '/login'
```

---

## 11. Intersection Types

An intersection type combines multiple types into one. The result must satisfy *all* of them, using `&`.

```ts
interface HasTimestamps {
  createdAt: Date;
  updatedAt: Date;
}

interface HasId {
  id: string;
}

interface User {
  name: string;
  email: string;
}

// DatabaseUser must have all properties from all three
type DatabaseUser = User & HasId & HasTimestamps;

const user: DatabaseUser = {
  id: 'usr_123',
  name: 'Alice',
  email: 'alice@example.com',
  createdAt: new Date(),
  updatedAt: new Date(),
};
```

### Real-world use: enriching props

```ts
interface ButtonProps {
  label: string;
  onClick: () => void;
}

// Extend with all native button HTML attributes
type NativeButtonProps = ButtonProps & React.ButtonHTMLAttributes<HTMLButtonElement>;

function Button({ label, onClick, ...nativeProps }: NativeButtonProps) {
  return (
    <button onClick={onClick} {...nativeProps}>
      {label}
    </button>
  );
}

// Now accepts all standard button attributes
<Button label="Submit" onClick={handleSubmit} disabled={isLoading} type="submit" />
```

### Union vs Intersection

```ts
// Union — one OR the other
type AorB = A | B; // Must satisfy A, or B, or both

// Intersection — one AND the other
type AandB = A & B; // Must satisfy A AND B simultaneously
```

---

## 12. Enums vs Union Literals

TypeScript has enums, but they're often not the best choice for frontend code.

### Numeric enums (avoid in most cases)

```ts
enum Direction {
  North, // 0
  South, // 1
  East,  // 2
  West,  // 3
}

const dir: Direction = Direction.North;
console.log(dir); // 0 — the number, not the name
```

Problems: numeric enums compile to complex JavaScript, allow invalid numeric values, and serialize to numbers in JSON.

### String enums (better, but still has tradeoffs)

```ts
enum Status {
  Loading = 'LOADING',
  Success = 'SUCCESS',
  Error = 'ERROR',
}

const status: Status = Status.Loading;
console.log(status); // 'LOADING'
```

String enums are safer than numeric, but they still compile to a JavaScript object and require you to use the enum member syntax (`Status.Loading`), not the raw string.

### Union literals (recommended for most cases)

```ts
type Status = 'loading' | 'success' | 'error';

const status: Status = 'loading';
console.log(status); // 'loading' — no enum object in the compiled output
```

Benefits:
- Zero runtime overhead — erased completely at compile time
- Readable serialized values in JSON and network requests
- Easy to use inline without importing a separate enum object
- Works naturally with `switch` and narrowing

### When enums are still useful

Use enums when you need a *namespace* for a collection of related constants, especially if the constants are used as object keys or need reverse mapping. Use `const enum` for slight optimization (values are inlined at compile time).

```ts
// const enum — inlined at compile time, zero runtime overhead
const enum HttpStatus {
  OK = 200,
  Created = 201,
  BadRequest = 400,
  Unauthorized = 401,
  NotFound = 404,
}

if (response.status === HttpStatus.NotFound) {
  // Compiled to: if (response.status === 404)
}
```

---

## 13. Type Narrowing and Type Guards

### What narrowing is

When a variable has a union type, TypeScript tracks which branch of the union is active based on your code's control flow. This is called narrowing.

```ts
function printValue(value: string | number) {
  // Here, value is: string | number

  if (typeof value === 'string') {
    // Here, TypeScript narrows value to: string
    console.log(value.toUpperCase());
  } else {
    // Here, TypeScript narrows value to: number
    console.log(value.toFixed(2));
  }
}
```

### Narrowing techniques

**`typeof` — for primitives:**

```ts
function process(value: string | number | boolean) {
  if (typeof value === 'string') { /* string */ }
  if (typeof value === 'number') { /* number */ }
  if (typeof value === 'boolean') { /* boolean */ }
}
```

**`instanceof` — for class instances:**

```ts
function handleError(error: Error | string) {
  if (error instanceof Error) {
    console.log(error.message); // TypeScript knows it's an Error
  } else {
    console.log(error); // TypeScript knows it's a string
  }
}
```

**`in` — for checking object properties:**

```ts
interface Dog { bark(): void }
interface Cat { meow(): void }

function makeSound(animal: Dog | Cat) {
  if ('bark' in animal) {
    animal.bark(); // TypeScript narrows to Dog
  } else {
    animal.meow(); // TypeScript narrows to Cat
  }
}
```

**Equality narrowing:**

```ts
type Status = 'loading' | 'success' | 'error';

function handleStatus(status: Status) {
  if (status === 'loading') {
    // status is: 'loading'
    showSpinner();
  } else if (status === 'success') {
    // status is: 'success'
    showContent();
  } else {
    // status is: 'error'
    showError();
  }
}
```

**Truthiness narrowing:**

```ts
function greet(name: string | null) {
  if (name) {
    // name is: string (null is falsy, so it's excluded)
    console.log(`Hello, ${name}`);
  }
}
```

### Custom type guards

Sometimes the built-in narrowing isn't enough. You can write a function that tells TypeScript how to narrow a type.

The return type `value is SomeType` is a *type predicate* — it teaches TypeScript what the function's `true` result implies.

```ts
interface ApiUser {
  id: number;
  name: string;
  email: string;
}

// Custom type guard
function isApiUser(value: unknown): value is ApiUser {
  return (
    typeof value === 'object' &&
    value !== null &&
    'id' in value &&
    'name' in value &&
    'email' in value &&
    typeof (value as ApiUser).id === 'number' &&
    typeof (value as ApiUser).name === 'string' &&
    typeof (value as ApiUser).email === 'string'
  );
}

async function fetchUser(id: number) {
  const res = await fetch(`/api/users/${id}`);
  const data: unknown = await res.json();

  if (isApiUser(data)) {
    // TypeScript now knows data is ApiUser
    console.log(data.name);
  } else {
    throw new Error('Invalid API response shape');
  }
}
```

### Discriminated unions

A discriminated union is a union of object types where each member has a shared *discriminant* property with a unique literal type. It's one of the most powerful patterns in TypeScript.

```ts
type LoadingState = {
  status: 'loading';
};

type SuccessState = {
  status: 'success';
  data: User[];
};

type ErrorState = {
  status: 'error';
  message: string;
};

type FetchState = LoadingState | SuccessState | ErrorState;

function render(state: FetchState) {
  switch (state.status) {
    case 'loading':
      // state is: LoadingState
      return <Spinner />;
    case 'success':
      // state is: SuccessState — TypeScript knows state.data exists
      return <UserList users={state.data} />;
    case 'error':
      // state is: ErrorState — TypeScript knows state.message exists
      return <ErrorMessage message={state.message} />;
  }
}
```

This pattern eliminates an entire class of runtime errors. You can never accidentally access `state.data` when `state.status === 'loading'` because TypeScript won't allow it.

---

## 14. Type Assertions

Type assertions tell TypeScript "I know the type of this value better than you do." They use the `as` keyword.

```ts
const input = document.getElementById('search') as HTMLInputElement;
// Now TypeScript knows input has .value, .focus(), etc.
console.log(input.value);

// Alternative angle-bracket syntax (not usable in JSX files)
const input = <HTMLInputElement>document.getElementById('search');
```

### When assertions are acceptable

- Working with DOM elements where you know the specific element type
- Working with data that has already been validated at runtime
- Migration from JavaScript where you need to temporarily suppress errors

### When assertions are dangerous

```ts
// This compiles but crashes at runtime
const user = {} as User;
console.log(user.name.toUpperCase()); // Runtime error: Cannot read property of undefined
```

An assertion tells TypeScript to trust you. If you're wrong, you get runtime errors with no type-system protection.

### Double assertions

Sometimes TypeScript won't allow a direct assertion because the types are too different. You can assert through `unknown`, but this is a warning sign:

```ts
// When TypeScript rejects the direct assertion
const value = someFunction() as unknown as SpecificType;
```

If you find yourself doing this regularly, it's a sign the types are poorly designed.

### Prefer type guards over assertions

```ts
// Worse: assertion — no runtime safety
const user = apiResponse as User;

// Better: type guard — validates at runtime
if (isUser(apiResponse)) {
  // apiResponse is narrowed to User, and you've actually checked it
}
```

---

## 15. Functions

### Parameter and return type annotations

```ts
// Basic typed function
function add(a: number, b: number): number {
  return a + b;
}

// Arrow function
const multiply = (a: number, b: number): number => a * b;

// TypeScript can infer the return type — annotation is optional but good for documentation
function getUser(id: number) {
  return { id, name: 'Alice' }; // Inferred: { id: number; name: string }
}
```

### Optional and default parameters

```ts
// Optional parameter — must come after required ones
function greet(name: string, title?: string): string {
  return title ? `Hello, ${title} ${name}` : `Hello, ${name}`;
}

greet('Alice');          // 'Hello, Alice'
greet('Alice', 'Dr.');   // 'Hello, Dr. Alice'

// Default parameter — the type is inferred from the default value
function createUser(name: string, role: string = 'viewer'): User {
  return { name, role };
}

createUser('Alice');           // role defaults to 'viewer'
createUser('Bob', 'admin');    // role is 'admin'
```

### Rest parameters

```ts
function sum(...numbers: number[]): number {
  return numbers.reduce((total, n) => total + n, 0);
}

sum(1, 2, 3, 4, 5); // 15
```

### Function types

Describe the shape of a function as a value:

```ts
// Type alias for a function
type Formatter = (value: number) => string;

// Using the type
const formatPrice: Formatter = (value) => `$${value.toFixed(2)}`;
const formatPercent: Formatter = (value) => `${(value * 100).toFixed(1)}%`;

// In an interface
interface ButtonProps {
  onClick: () => void;
  onHover?: (event: MouseEvent) => void;
}
```

### Callback typing

```ts
// The callback type is declared inline
function processItems(
  items: string[],
  callback: (item: string, index: number) => void
): void {
  items.forEach(callback);
}

processItems(['a', 'b', 'c'], (item, i) => {
  console.log(`${i}: ${item}`);
});
```

### Overloads

Function overloads let you describe multiple call signatures for a single function:

```ts
// Overload signatures (declarations only)
function parse(value: string): number;
function parse(value: number): string;
// Implementation signature (not visible to callers)
function parse(value: string | number): string | number {
  if (typeof value === 'string') return parseInt(value, 10);
  return value.toString();
}

const num = parse('42');    // TypeScript knows this is: number
const str = parse(42);      // TypeScript knows this is: string
```

Overloads are useful but can usually be replaced with simpler union types. Use them when the return type depends on the argument type.

### Async functions and Promise typing

```ts
// Async function — return type is always Promise<T>
async function fetchUser(id: number): Promise<User> {
  const res = await fetch(`/api/users/${id}`);
  if (!res.ok) throw new Error(`HTTP error: ${res.status}`);
  return res.json() as Promise<User>;
}

// Using the async function
async function loadPage() {
  try {
    const user = await fetchUser(1);
    // user: User
    console.log(user.name);
  } catch (error) {
    // error: unknown — must narrow before using
    if (error instanceof Error) {
      console.error(error.message);
    }
  }
}
```

Note: `catch` block errors are typed as `unknown` in strict TypeScript. Always narrow before using them.

---

## 16. Generics

### Why generics exist

Consider this problem:

```ts
// You need an identity function for strings
function identityString(value: string): string {
  return value;
}

// And for numbers
function identityNumber(value: number): number {
  return value;
}

// This is repetition. What if you could write one function that works for any type?
```

A generic is a *type parameter* — a placeholder for a type that gets filled in when the function is called.

```ts
function identity<T>(value: T): T {
  return value;
}

identity('hello');   // T is inferred as string; returns string
identity(42);        // T is inferred as number; returns number
identity({ id: 1 }); // T is inferred as { id: number }; returns { id: number }
```

`T` is conventional but arbitrary. You could use any name. Common conventions: `T` (Type), `K` (Key), `V` (Value), `E` (Element), `R` (Return).

### Generic functions

```ts
// Return the first element of an array
function first<T>(arr: T[]): T | undefined {
  return arr[0];
}

const firstStr = first(['a', 'b', 'c']); // string | undefined
const firstNum = first([1, 2, 3]);        // number | undefined

// A more complete array utility
function last<T>(arr: T[]): T | undefined {
  return arr[arr.length - 1];
}

function take<T>(arr: T[], count: number): T[] {
  return arr.slice(0, count);
}
```

### Generic interfaces and types

```ts
// A container that holds any value
interface Box<T> {
  value: T;
  label: string;
}

const stringBox: Box<string> = { value: 'hello', label: 'greeting' };
const numberBox: Box<number> = { value: 42, label: 'answer' };

// API response wrapper — very common in frontend code
interface ApiResponse<T> {
  data: T;
  status: number;
  message: string;
  timestamp: string;
}

type UsersResponse = ApiResponse<User[]>;
type ProductResponse = ApiResponse<Product>;
```

### Generic constraints

Sometimes you need to constrain what types `T` can be — you need to know it has certain properties.

```ts
// T must have an 'id' property that is a string or number
function findById<T extends { id: string | number }>(
  items: T[],
  id: string | number
): T | undefined {
  return items.find(item => item.id === id);
}

const users = [
  { id: 1, name: 'Alice' },
  { id: 2, name: 'Bob' },
];

const user = findById(users, 1); // TypeScript knows: { id: number; name: string } | undefined
```

```ts
// Get a property from an object by key — K must be a key of T
function getProperty<T, K extends keyof T>(obj: T, key: K): T[K] {
  return obj[key];
}

const user = { id: 1, name: 'Alice', email: 'alice@example.com' };

const name = getProperty(user, 'name');  // string
const id   = getProperty(user, 'id');    // number
const bad  = getProperty(user, 'phone'); // Error: Argument of type '"phone"' is not assignable
```

### Multiple type parameters

```ts
function pair<A, B>(first: A, second: B): [A, B] {
  return [first, second];
}

const result = pair('hello', 42); // [string, number]

// Transform an object's values
function mapValues<K extends string, V, R>(
  obj: Record<K, V>,
  fn: (value: V, key: K) => R
): Record<K, R> {
  const result = {} as Record<K, R>;
  for (const key in obj) {
    result[key] = fn(obj[key], key);
  }
  return result;
}
```

### Generic default types

```ts
// T defaults to string if not specified
interface Input<T = string> {
  value: T;
  onChange: (value: T) => void;
}

type StringInput = Input;          // Input<string>
type NumberInput = Input<number>;  // Input<number>
```

---

## 17. Mapped Types and Utility Types

### What mapped types are

A mapped type creates a new type by transforming an existing one, iterating over its keys.

```ts
// Make all properties of T optional
type Optional<T> = {
  [K in keyof T]?: T[K];
};

// Make all properties of T readonly
type Immutable<T> = {
  readonly [K in keyof T]: T[K];
};

// Make all properties nullable
type Nullable<T> = {
  [K in keyof T]: T[K] | null;
};
```

TypeScript ships with many useful mapped types as built-in *utility types*.

### Built-in utility types

#### `Partial<T>` — makes all properties optional

```ts
interface User {
  id: number;
  name: string;
  email: string;
  age: number;
}

type PartialUser = Partial<User>;
// { id?: number; name?: string; email?: string; age?: number }

// Common use: update payloads
async function updateUser(id: number, updates: Partial<User>): Promise<User> {
  const res = await fetch(`/api/users/${id}`, {
    method: 'PATCH',
    body: JSON.stringify(updates),
  });
  return res.json();
}

updateUser(1, { name: 'Alice Updated' }); // Only sending what changed
```

#### `Required<T>` — makes all properties required

```ts
type RequiredUser = Required<Partial<User>>;
// All properties are required again
```

#### `Readonly<T>` — makes all properties readonly

```ts
type ReadonlyUser = Readonly<User>;

const user: ReadonlyUser = { id: 1, name: 'Alice', email: 'alice@example.com', age: 30 };
user.name = 'Bob'; // Error: Cannot assign to 'name' because it is a read-only property
```

#### `Pick<T, K>` — selects a subset of properties

```ts
type UserPreview = Pick<User, 'id' | 'name'>;
// { id: number; name: string }

// Useful for component props that only need part of a model
function UserCard({ id, name }: Pick<User, 'id' | 'name'>) {
  return <div>{id}: {name}</div>;
}
```

#### `Omit<T, K>` — removes specific properties

```ts
// When creating a user, we don't have an id yet
type CreateUserInput = Omit<User, 'id'>;
// { name: string; email: string; age: number }

async function createUser(input: CreateUserInput): Promise<User> {
  const res = await fetch('/api/users', {
    method: 'POST',
    body: JSON.stringify(input),
  });
  return res.json();
}
```

#### `Record<K, V>` — creates an object type with known key type and value type

```ts
// Map of user id to user object
type UserMap = Record<string, User>;

// Map of status to color
type StatusColors = Record<'loading' | 'success' | 'error', string>;

const colors: StatusColors = {
  loading: '#blue',
  success: '#green',
  error: '#red',
};
```

#### `Exclude<T, U>` and `Extract<T, U>` — filter union types

```ts
type AllStatus = 'loading' | 'success' | 'error' | 'idle';

// Remove certain members from a union
type ActiveStatus = Exclude<AllStatus, 'idle'>;
// 'loading' | 'success' | 'error'

// Keep only members assignable to a type
type StringOrBoolean = string | number | boolean;
type OnlyStringOrBoolean = Extract<StringOrBoolean, string | boolean>;
// string | boolean
```

#### `ReturnType<T>` — extract the return type of a function

```ts
function getUser() {
  return { id: 1, name: 'Alice', email: 'alice@example.com' };
}

type UserResult = ReturnType<typeof getUser>;
// { id: number; name: string; email: string }

// Useful when you don't control the function's type declaration
async function fetchProducts() {
  const res = await fetch('/api/products');
  return res.json() as Promise<Product[]>;
}

type FetchProductsResult = Awaited<ReturnType<typeof fetchProducts>>;
// Product[]
```

#### `Parameters<T>` — extract the parameter types of a function

```ts
function createButton(label: string, variant: 'primary' | 'secondary', disabled: boolean) {}

type CreateButtonParams = Parameters<typeof createButton>;
// [label: string, variant: 'primary' | 'secondary', disabled: boolean]

// Get the type of a specific parameter
type ButtonVariant = CreateButtonParams[1];
// 'primary' | 'secondary'
```

#### `NonNullable<T>` — remove null and undefined from a type

```ts
type MaybeString = string | null | undefined;
type DefinitelyString = NonNullable<MaybeString>;
// string
```

#### `Awaited<T>` — unwrap a Promise type

```ts
type WrappedUser = Promise<User>;
type UnwrappedUser = Awaited<WrappedUser>;
// User
```

---

## 18. Advanced Types

### Conditional types

A conditional type is like a ternary for types: `T extends U ? X : Y`.

```ts
// If T extends string, the type is true; otherwise false
type IsString<T> = T extends string ? true : false;

type A = IsString<string>;  // true
type B = IsString<number>;  // false
type C = IsString<'hello'>; // true (literal types extend string)
```

Real-world use: `NonNullable` is implemented as a conditional type:

```ts
type NonNullable<T> = T extends null | undefined ? never : T;
```

### The `infer` keyword

`infer` lets you capture a type from within a conditional type.

```ts
// Extract the element type from an array
type UnpackArray<T> = T extends Array<infer Element> ? Element : T;

type StringArray = string[];
type ElementType = UnpackArray<StringArray>; // string
type NumberElement = UnpackArray<number[]>;  // number
type Passthrough = UnpackArray<string>;      // string (not an array, so T itself)

// Extract the resolved type from a Promise
type Unwrap<T> = T extends Promise<infer R> ? R : T;

type UserPromise = Promise<User>;
type ResolvedUser = Unwrap<UserPromise>; // User
```

### Template literal types

TypeScript can construct new string types by combining literals — like template strings, but at the type level.

```ts
type EventName = 'click' | 'focus' | 'blur';

// Create 'onClick' | 'onFocus' | 'onBlur'
type EventHandlerName = `on${Capitalize<EventName>}`;
// 'onClick' | 'onFocus' | 'onBlur'

// CSS property pattern
type CSSProperty = 'margin' | 'padding' | 'border';
type CSSDirection = 'Top' | 'Right' | 'Bottom' | 'Left';

// Generate all directional variants
type CSSDirectionalProperty = `${CSSProperty}${CSSDirection}`;
// 'marginTop' | 'marginRight' | ... | 'borderLeft'
```

### Recursive types

Types that reference themselves — useful for tree structures, JSON, nested data:

```ts
// A JSON value can be any of these, including nested objects/arrays
type JSONValue =
  | string
  | number
  | boolean
  | null
  | JSONValue[]
  | { [key: string]: JSONValue };

// A file system tree
interface FileNode {
  name: string;
  type: 'file';
  size: number;
}

interface DirectoryNode {
  name: string;
  type: 'directory';
  children: (FileNode | DirectoryNode)[]; // Recursive
}

type FSNode = FileNode | DirectoryNode;
```

### Declaration files (`.d.ts`)

Declaration files describe the types of JavaScript code without including the implementation. They're used for:

- Typing third-party JavaScript libraries
- Describing global variables (from CDN scripts, etc.)
- Publishing types alongside a library

```ts
// types/analytics.d.ts
// Describes a script loaded globally via a <script> tag
declare const analytics: {
  track(event: string, properties?: Record<string, unknown>): void;
  identify(userId: string, traits?: Record<string, unknown>): void;
  page(name: string): void;
};

// Augmenting an existing module (adding a property to React)
declare module 'react' {
  interface HTMLAttributes<T> {
    // Add a custom data attribute type
    'data-testid'?: string;
  }
}
```

Most popular libraries include types directly. For those that don't, the community maintains `@types/*` packages:

```bash
npm install --save-dev @types/lodash
```

---

## 19. TypeScript with React

### Setting up

With Vite:

```bash
npm create vite@latest my-app -- --template react-ts
```

This generates a project with TypeScript configured for React.

### Typing function components

```tsx
// Simple component — no props
function Spinner() {
  return <div className="spinner" />;
}

// Component with props
interface WelcomeBannerProps {
  userName: string;
  isAdmin?: boolean;
}

function WelcomeBanner({ userName, isAdmin = false }: WelcomeBannerProps) {
  return (
    <div>
      <h1>Welcome, {userName}</h1>
      {isAdmin && <span>Admin</span>}
    </div>
  );
}
```

Prefer destructuring props with default values inline, rather than `React.FC<Props>`. The `React.FC` type was common in older codebases but has subtle issues (implicit `children` prop, generic component issues) and is now generally avoided.

### Typing children

```tsx
interface CardProps {
  title: string;
  children: React.ReactNode; // Accepts anything React can render
}

function Card({ title, children }: CardProps) {
  return (
    <div className="card">
      <h2>{title}</h2>
      {children}
    </div>
  );
}

// React.ReactNode accepts: JSX, strings, numbers, arrays, null, undefined, booleans
// Use it for any component that renders children
```

If you need a more specific children type:

```tsx
// Only accepts JSX elements, not strings/numbers
children: React.ReactElement

// Only a single child (not an array)
children: React.ReactElement<SomeProps>

// Function as children pattern
children: (value: string) => React.ReactNode
```

### Event typing

```tsx
function SearchInput() {
  const [query, setQuery] = useState('');

  // React.ChangeEvent<HTMLInputElement> — typed for input elements
  const handleChange = (event: React.ChangeEvent<HTMLInputElement>) => {
    setQuery(event.target.value);
  };

  // React.FormEvent<HTMLFormElement> — typed for form submit
  const handleSubmit = (event: React.FormEvent<HTMLFormElement>) => {
    event.preventDefault();
    performSearch(query);
  };

  // React.MouseEvent<HTMLButtonElement>
  const handleClear = (event: React.MouseEvent<HTMLButtonElement>) => {
    setQuery('');
  };

  return (
    <form onSubmit={handleSubmit}>
      <input value={query} onChange={handleChange} />
      <button type="button" onClick={handleClear}>Clear</button>
      <button type="submit">Search</button>
    </form>
  );
}
```

Common React event types:
- `React.ChangeEvent<HTMLInputElement>` — input, select, textarea onChange
- `React.FormEvent<HTMLFormElement>` — form onSubmit
- `React.MouseEvent<HTMLButtonElement>` — button onClick
- `React.KeyboardEvent<HTMLInputElement>` — keyboard events
- `React.FocusEvent<HTMLInputElement>` — focus and blur
- `React.DragEvent<HTMLDivElement>` — drag events

### useState typing

```tsx
// TypeScript infers the type from the initial value
const [count, setCount] = useState(0);      // number
const [name, setName] = useState('');        // string
const [open, setOpen] = useState(false);     // boolean

// Provide a type argument when inference isn't enough
const [user, setUser] = useState<User | null>(null);
// Without the type argument, null would be inferred — TypeScript would never know it can be a User

// For arrays, provide the type explicitly
const [items, setItems] = useState<Product[]>([]);

// Complex state
interface FilterState {
  search: string;
  category: string | null;
  sortBy: 'name' | 'price' | 'date';
  page: number;
}

const [filters, setFilters] = useState<FilterState>({
  search: '',
  category: null,
  sortBy: 'name',
  page: 1,
});
```

### useRef typing

```tsx
// DOM refs — pass the HTML element type, initialize with null
function TextInput() {
  const inputRef = useRef<HTMLInputElement>(null);

  const focusInput = () => {
    // inputRef.current can be null — check before using
    inputRef.current?.focus();
  };

  return (
    <div>
      <input ref={inputRef} />
      <button onClick={focusInput}>Focus</button>
    </div>
  );
}

// Mutable value refs (no DOM element, no null)
function Timer() {
  const intervalRef = useRef<number>(0);
  // intervalRef.current is always a number — no null check needed

  const start = () => {
    intervalRef.current = window.setInterval(() => tick(), 1000);
  };

  const stop = () => {
    clearInterval(intervalRef.current);
  };
}
```

### useContext typing

```tsx
// 1. Define the context value type
interface ThemeContextValue {
  theme: 'light' | 'dark';
  toggleTheme: () => void;
}

// 2. Create context with a default or null + assertion
const ThemeContext = createContext<ThemeContextValue | null>(null);

// 3. Custom hook to consume context — provides a clean error if used outside the provider
function useTheme(): ThemeContextValue {
  const context = useContext(ThemeContext);
  if (!context) {
    throw new Error('useTheme must be used within a ThemeProvider');
  }
  return context;
}

// 4. Provider component
function ThemeProvider({ children }: { children: React.ReactNode }) {
  const [theme, setTheme] = useState<'light' | 'dark'>('light');

  const toggleTheme = () => {
    setTheme(t => t === 'light' ? 'dark' : 'light');
  };

  return (
    <ThemeContext.Provider value={{ theme, toggleTheme }}>
      {children}
    </ThemeContext.Provider>
  );
}

// 5. Consuming
function Header() {
  const { theme, toggleTheme } = useTheme();
  return <button onClick={toggleTheme}>Current: {theme}</button>;
}
```

### useReducer typing

```tsx
// State and action types
interface CounterState {
  count: number;
  step: number;
}

type CounterAction =
  | { type: 'increment' }
  | { type: 'decrement' }
  | { type: 'setStep'; payload: number }
  | { type: 'reset' };

// The reducer — TypeScript exhaustively checks all action types
function counterReducer(state: CounterState, action: CounterAction): CounterState {
  switch (action.type) {
    case 'increment':
      return { ...state, count: state.count + state.step };
    case 'decrement':
      return { ...state, count: state.count - state.step };
    case 'setStep':
      return { ...state, step: action.payload }; // TypeScript knows payload exists
    case 'reset':
      return { count: 0, step: 1 };
  }
}

function Counter() {
  const [state, dispatch] = useReducer(counterReducer, { count: 0, step: 1 });

  return (
    <div>
      <p>Count: {state.count}</p>
      <button onClick={() => dispatch({ type: 'increment' })}>+</button>
      <button onClick={() => dispatch({ type: 'decrement' })}>-</button>
      <button onClick={() => dispatch({ type: 'setStep', payload: 5 })}>Step: 5</button>
    </div>
  );
}
```

### Custom hooks typing

```tsx
// Return type: tuple [value, setter] — explicit return type for clarity
function useLocalStorage<T>(key: string, initial: T): [T, (value: T) => void] {
  const [stored, setStored] = useState<T>(() => {
    try {
      const item = localStorage.getItem(key);
      return item ? JSON.parse(item) : initial;
    } catch {
      return initial;
    }
  });

  const setValue = (value: T) => {
    setStored(value);
    localStorage.setItem(key, JSON.stringify(value));
  };

  return [stored, setValue];
}

// Usage
const [darkMode, setDarkMode] = useLocalStorage('dark-mode', false);
// darkMode: boolean
// setDarkMode: (value: boolean) => void
```

### Generic React components

```tsx
// A list component that works for any item type
interface ListProps<T> {
  items: T[];
  renderItem: (item: T, index: number) => React.ReactNode;
  keyExtractor: (item: T) => string;
  emptyMessage?: string;
}

function List<T>({ items, renderItem, keyExtractor, emptyMessage = 'No items' }: ListProps<T>) {
  if (items.length === 0) return <p>{emptyMessage}</p>;

  return (
    <ul>
      {items.map((item, i) => (
        <li key={keyExtractor(item)}>{renderItem(item, i)}</li>
      ))}
    </ul>
  );
}

// Usage — T is inferred from the items array
<List
  items={users}
  renderItem={(user) => <span>{user.name}</span>}
  keyExtractor={(user) => user.id.toString()}
/>
```

### Common React type imports

```tsx
import type {
  ReactNode,         // Anything React can render
  ReactElement,      // A React JSX element specifically
  ComponentProps,    // Extract props from a component
  ComponentType,     // A component (function or class)
  CSSProperties,     // Inline style object type
  MouseEvent,        // (without React. prefix — from the DOM)
  ChangeEvent,
  FormEvent,
  KeyboardEvent,
  RefObject,         // { current: T | null }
  MutableRefObject,  // { current: T }
  Dispatch,          // Dispatch type from useReducer
  SetStateAction,    // Setter type from useState
} from 'react';

// Extract props from an existing component
type ButtonProps = ComponentProps<typeof Button>;
type DivProps = ComponentProps<'div'>; // Native HTML element
```

---

## 20. Typing Frontend APIs

### Basic fetch pattern

```ts
interface Post {
  id: number;
  title: string;
  body: string;
  userId: number;
}

async function fetchPost(id: number): Promise<Post> {
  const res = await fetch(`https://jsonplaceholder.typicode.com/posts/${id}`);

  if (!res.ok) {
    throw new Error(`HTTP ${res.status}: ${res.statusText}`);
  }

  // res.json() returns Promise<any> — we assert the type here
  // For production, validate the shape at runtime (see Zod section)
  return res.json() as Promise<Post>;
}
```

### API client pattern

Building a typed API client prevents scattered fetch calls across your codebase:

```ts
class ApiClient {
  private baseUrl: string;

  constructor(baseUrl: string) {
    this.baseUrl = baseUrl;
  }

  private async request<T>(
    path: string,
    options?: RequestInit
  ): Promise<T> {
    const res = await fetch(`${this.baseUrl}${path}`, {
      headers: {
        'Content-Type': 'application/json',
        ...options?.headers,
      },
      ...options,
    });

    if (!res.ok) {
      const error = await res.text();
      throw new ApiError(res.status, error);
    }

    return res.json() as Promise<T>;
  }

  async get<T>(path: string): Promise<T> {
    return this.request<T>(path);
  }

  async post<TBody, TResponse>(path: string, body: TBody): Promise<TResponse> {
    return this.request<TResponse>(path, {
      method: 'POST',
      body: JSON.stringify(body),
    });
  }

  async patch<TBody, TResponse>(path: string, body: TBody): Promise<TResponse> {
    return this.request<TResponse>(path, {
      method: 'PATCH',
      body: JSON.stringify(body),
    });
  }

  async delete<T>(path: string): Promise<T> {
    return this.request<T>(path, { method: 'DELETE' });
  }
}

class ApiError extends Error {
  constructor(
    public status: number,
    message: string
  ) {
    super(message);
    this.name = 'ApiError';
  }
}

// Usage
const api = new ApiClient('https://api.example.com');

const user = await api.get<User>('/users/1');
const newUser = await api.post<CreateUserInput, User>('/users', { name: 'Alice', email: '...' });
```

### Runtime validation with Zod

TypeScript types are erased at runtime. If an API returns unexpected data, your types won't protect you. Zod adds runtime validation that also produces TypeScript types.

```bash
npm install zod
```

```ts
import { z } from 'zod';

// Define a schema (runtime validator)
const UserSchema = z.object({
  id: z.number(),
  name: z.string(),
  email: z.string().email(),
  age: z.number().min(0).max(150).optional(),
});

// TypeScript type is automatically inferred from the schema
type User = z.infer<typeof UserSchema>;
// { id: number; name: string; email: string; age?: number | undefined }

async function fetchUser(id: number): Promise<User> {
  const res = await fetch(`/api/users/${id}`);
  const data: unknown = await res.json();

  // parse() throws if validation fails, returns typed data if it passes
  return UserSchema.parse(data);
}

// Using safeParse for graceful error handling
async function tryFetchUser(id: number) {
  const res = await fetch(`/api/users/${id}`);
  const data: unknown = await res.json();
  const result = UserSchema.safeParse(data);

  if (!result.success) {
    console.error('Invalid user data:', result.error.format());
    return null;
  }

  return result.data; // User — fully typed and validated
}
```

### Typing environment variables

```ts
// env.ts — centralize and type environment variables
const env = {
  apiUrl: import.meta.env.VITE_API_URL as string,
  apiKey: import.meta.env.VITE_API_KEY as string,
  isDevelopment: import.meta.env.DEV as boolean,
} as const;

// Validate at startup
if (!env.apiUrl) {
  throw new Error('VITE_API_URL is required');
}

export default env;
```

For stricter env typing, extend Vite's ImportMetaEnv:

```ts
// vite-env.d.ts
interface ImportMetaEnv {
  readonly VITE_API_URL: string;
  readonly VITE_API_KEY: string;
  readonly VITE_FEATURE_FLAGS: string;
}

interface ImportMeta {
  readonly env: ImportMetaEnv;
}
```

---

## 21. Forms and Events

### Controlled inputs

```tsx
function LoginForm() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState<string | null>(null);

  const handleEmailChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    setEmail(e.target.value);
  };

  const handlePasswordChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    setPassword(e.target.value);
  };

  const handleSubmit = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    setError(null);

    try {
      await login({ email, password });
    } catch (err) {
      if (err instanceof ApiError) {
        setError(err.message);
      }
    }
  };

  return (
    <form onSubmit={handleSubmit}>
      <input type="email" value={email} onChange={handleEmailChange} />
      <input type="password" value={password} onChange={handlePasswordChange} />
      {error && <p role="alert">{error}</p>}
      <button type="submit">Login</button>
    </form>
  );
}
```

### Typing select and textarea

```tsx
// Select element
const handleCategoryChange = (e: React.ChangeEvent<HTMLSelectElement>) => {
  setCategory(e.target.value);
};

// For typed select values, cast or validate:
type Category = 'tech' | 'design' | 'business';

const handleCategoryChange = (e: React.ChangeEvent<HTMLSelectElement>) => {
  setCategory(e.target.value as Category);
};

// Textarea
const handleDescriptionChange = (e: React.ChangeEvent<HTMLTextAreaElement>) => {
  setDescription(e.target.value);
};
```

### React Hook Form (typed usage)

```tsx
import { useForm, SubmitHandler } from 'react-hook-form';

interface LoginFormValues {
  email: string;
  password: string;
  rememberMe: boolean;
}

function LoginForm() {
  const {
    register,
    handleSubmit,
    formState: { errors, isSubmitting },
  } = useForm<LoginFormValues>({
    defaultValues: {
      email: '',
      password: '',
      rememberMe: false,
    },
  });

  const onSubmit: SubmitHandler<LoginFormValues> = async (data) => {
    // data is fully typed as LoginFormValues
    await login(data.email, data.password);
  };

  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      <input {...register('email', { required: 'Email is required' })} />
      {errors.email && <span>{errors.email.message}</span>}

      <input type="password" {...register('password', { required: true, minLength: 8 })} />

      <input type="checkbox" {...register('rememberMe')} />

      <button type="submit" disabled={isSubmitting}>Login</button>
    </form>
  );
}
```

---

## 22. State Management Patterns

### Context API

See the `useContext` section above for a full typed example. The key points:

- Create context with `createContext<ValueType | null>(null)`
- Wrap access in a custom hook that throws if context is null
- Type the provider's `value` prop to match the context type

### Zustand (typed store)

```ts
import { create } from 'zustand';

interface CartItem {
  id: string;
  name: string;
  price: number;
  quantity: number;
}

interface CartStore {
  items: CartItem[];
  total: number;
  addItem: (item: Omit<CartItem, 'quantity'>) => void;
  removeItem: (id: string) => void;
  updateQuantity: (id: string, quantity: number) => void;
  clearCart: () => void;
}

const useCartStore = create<CartStore>((set, get) => ({
  items: [],
  total: 0,

  addItem: (newItem) => set((state) => {
    const existing = state.items.find(i => i.id === newItem.id);
    const items = existing
      ? state.items.map(i => i.id === newItem.id ? { ...i, quantity: i.quantity + 1 } : i)
      : [...state.items, { ...newItem, quantity: 1 }];

    const total = items.reduce((sum, item) => sum + item.price * item.quantity, 0);
    return { items, total };
  }),

  removeItem: (id) => set((state) => {
    const items = state.items.filter(i => i.id !== id);
    const total = items.reduce((sum, item) => sum + item.price * item.quantity, 0);
    return { items, total };
  }),

  updateQuantity: (id, quantity) => set((state) => {
    const items = state.items.map(i => i.id === id ? { ...i, quantity } : i);
    const total = items.reduce((sum, item) => sum + item.price * item.quantity, 0);
    return { items, total };
  }),

  clearCart: () => set({ items: [], total: 0 }),
}));

// Usage
function CartIcon() {
  const { items, total } = useCartStore();
  return <span>{items.length} items · ${total.toFixed(2)}</span>;
}
```

### TanStack Query (typed queries)

```tsx
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';

// Typed query
function useUser(id: number) {
  return useQuery({
    queryKey: ['user', id],
    queryFn: (): Promise<User> => api.get(`/users/${id}`),
  });
  // Returns { data: User | undefined; isLoading: boolean; error: Error | null; ... }
}

// Typed mutation
function useUpdateUser() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: ({ id, updates }: { id: number; updates: Partial<User> }) =>
      api.patch<Partial<User>, User>(`/users/${id}`, updates),
    onSuccess: (updatedUser) => {
      // updatedUser is typed as User
      queryClient.setQueryData(['user', updatedUser.id], updatedUser);
    },
  });
}

function UserProfile({ id }: { id: number }) {
  const { data: user, isLoading, error } = useUser(id);
  const updateUser = useUpdateUser();

  if (isLoading) return <Spinner />;
  if (error) return <ErrorMessage message={error.message} />;
  if (!user) return null;

  // user is typed as User here
  return (
    <div>
      <h1>{user.name}</h1>
      <button onClick={() => updateUser.mutate({ id, updates: { name: 'Updated' } })}>
        Update
      </button>
    </div>
  );
}
```

---

## 23. Real-World Project Patterns

### Folder structure

```
src/
├── types/                  # Shared type definitions
│   ├── api.ts              # API response types, DTOs
│   ├── models.ts           # Domain models (User, Product, Order)
│   └── common.ts           # Shared utility types
├── components/
│   ├── ui/                 # Generic UI components (Button, Input, Modal)
│   │   ├── Button.tsx
│   │   └── Button.types.ts # Types co-located with component (for complex components)
│   └── features/           # Feature-specific components
│       └── UserCard/
│           ├── UserCard.tsx
│           └── UserCard.test.tsx
├── hooks/                  # Custom hooks
│   ├── useAuth.ts
│   └── useDebounce.ts
├── services/               # API clients and data access
│   ├── api.ts              # Base client
│   ├── users.ts            # User-specific API calls
│   └── products.ts
├── stores/                 # State management
│   └── cart.ts
└── utils/                  # Pure utility functions
    └── formatters.ts
```

### Domain models vs DTOs

*Domain models* are the shapes your application uses internally. *DTOs (Data Transfer Objects)* are the shapes that cross the network boundary. They are often different.

```ts
// types/api.ts — shapes that match the API response exactly
export interface UserDTO {
  user_id: number;           // snake_case from the API
  full_name: string;
  email_address: string;
  created_at: string;        // ISO string from JSON
  is_active: number;         // 0 or 1 from legacy API
}

// types/models.ts — shapes that are convenient for the application
export interface User {
  id: number;                // camelCase
  name: string;
  email: string;
  createdAt: Date;           // Parsed Date object
  isActive: boolean;         // Proper boolean
}

// services/users.ts — transform DTO to model
function transformUser(dto: UserDTO): User {
  return {
    id: dto.user_id,
    name: dto.full_name,
    email: dto.email_address,
    createdAt: new Date(dto.created_at),
    isActive: dto.is_active === 1,
  };
}
```

### Component prop design patterns

```tsx
// Pattern 1: Extend native HTML element props
interface InputProps extends React.InputHTMLAttributes<HTMLInputElement> {
  label: string;
  error?: string;
  hint?: string;
}

function Input({ label, error, hint, ...inputProps }: InputProps) {
  return (
    <div>
      <label>{label}</label>
      <input {...inputProps} aria-invalid={!!error} />
      {hint && <p className="hint">{hint}</p>}
      {error && <p className="error" role="alert">{error}</p>}
    </div>
  );
}

// Pattern 2: Polymorphic component (renders as different elements)
interface TextProps<T extends React.ElementType = 'span'> {
  as?: T;
  children: React.ReactNode;
  size?: 'sm' | 'md' | 'lg';
}

type PolymorphicTextProps<T extends React.ElementType> =
  TextProps<T> & Omit<React.ComponentPropsWithoutRef<T>, keyof TextProps<T>>;

function Text<T extends React.ElementType = 'span'>({
  as,
  children,
  size = 'md',
  ...rest
}: PolymorphicTextProps<T>) {
  const Component = as ?? 'span';
  return <Component className={`text-${size}`} {...rest}>{children}</Component>;
}

// Usage
<Text>Default span</Text>
<Text as="h1" size="lg">Heading</Text>
<Text as="p" id="description">Paragraph with id</Text>
```

### Naming conventions

```ts
// Interfaces: PascalCase noun
interface UserProfile {}
interface ApiResponse<T> {}

// Types: PascalCase noun
type UserID = string;
type Status = 'loading' | 'success' | 'error';

// Generic type parameters: single uppercase letter or descriptive PascalCase
function identity<T>(value: T): T {}
function mapValues<TKey extends string, TValue, TResult>() {}

// Props types: ComponentNameProps
interface ButtonProps {}
interface UserCardProps {}

// Enum (if used): PascalCase
enum HttpMethod { GET = 'GET', POST = 'POST' }

// Type-only imports (TypeScript 3.8+)
import type { User, Product } from './types/models';
```

---

## 24. Best Practices and Anti-Patterns

### Do: let TypeScript infer where it can

```ts
// Unnecessary annotation — TypeScript already knows this is a string
const name: string = 'Alice';

// Necessary annotation — TypeScript can't know what the function returns without it
// (actually it can here, but making it explicit is good documentation)
function getDisplayName(user: User): string {
  return user.displayName ?? user.name;
}
```

### Do: use `unknown` instead of `any` for uncertain data

```ts
// Avoid
function processData(data: any) { ... }

// Prefer
function processData(data: unknown) { ... }
```

### Do: prefer discriminated unions over boolean flags

```ts
// Avoid — ambiguous combinations (isLoading and data both truthy?)
interface BadState {
  isLoading: boolean;
  data: User[] | null;
  error: string | null;
}

// Prefer — each state is unambiguous
type FetchState<T> =
  | { status: 'idle' }
  | { status: 'loading' }
  | { status: 'success'; data: T }
  | { status: 'error'; message: string };
```

### Do: use `satisfies` for value checking with preserved types (TypeScript 4.9+)

```ts
// 'as' asserts a type but loses inference
const config = {
  theme: 'dark',
  language: 'en',
} as Record<string, string>;
// config.theme is now 'string', not 'dark'

// 'satisfies' validates the type but keeps the literal types
const config = {
  theme: 'dark',
  language: 'en',
} satisfies Record<string, string>;
// config.theme is still 'dark'
```

### Avoid: unnecessary type assertions

```ts
// Avoid — you're lying to TypeScript
const user = fetchedData as User;

// Prefer — actually validate
const user = UserSchema.parse(fetchedData);
// or
if (isUser(fetchedData)) { ... }
```

### Avoid: overly generic types

```ts
// Too generic — provides no value over 'object'
function process(data: Record<string, unknown>) {}

// Better — constrain to what you actually need
function process(data: { id: string; name: string }) {}
```

### Avoid: type assertions to work around type errors

```ts
// Using assertion to silence an error is a red flag
const element = document.querySelector('#app') as HTMLDivElement;
// What if it returns null? What if it's not a div?

// Better — handle the possible null
const element = document.querySelector('#app');
if (!(element instanceof HTMLDivElement)) {
  throw new Error('Expected #app to be a div');
}
```

### Avoid: `@ts-ignore` and `@ts-expect-error` except in tests

```ts
// @ts-ignore suppresses the error on the next line — avoid in production code
// @ts-expect-error is better (it fails if there is no error) — acceptable in tests
```

### Do: use `type` imports for types

```ts
// Signals clearly that these are types only — no runtime value
import type { User, Product } from './types';

// Avoids circular import issues and helps bundlers tree-shake
```

### Avoid: wrapping every return in a generic response type unnecessarily

```ts
// Overkill for internal functions
function getUsername(user: User): ApiResult<string> { ... }

// Fine for actual API boundaries
async function fetchUsers(): Promise<ApiResponse<User[]>> { ... }
```

### Understanding common TypeScript errors

**`Type 'X' is not assignable to type 'Y'`** — the types are incompatible. Check that the shape matches.

**`Object is possibly 'null' or 'undefined'`** — you haven't handled the null case. Add a null check or use `?.`.

**`Property 'X' does not exist on type 'Y'`** — typo in a property name, or the property doesn't exist on that type. Check the type definition.

**`Argument of type 'X' is not assignable to parameter of type 'Y'`** — passing the wrong type to a function. Check the function signature.

**`No overload matches this call`** — you're calling a function that has multiple overloads, and none match your arguments. Read each overload signature carefully.

**`Type 'X' does not satisfy the constraint 'Y'`** — a generic's argument doesn't meet the constraint defined with `extends`. Check what the constraint requires.

---

## Final Reference Card

```ts
// ─── Primitives ───────────────────────────────────────────────
let name: string = 'Alice';
let age: number = 30;
let active: boolean = true;

// ─── Arrays ───────────────────────────────────────────────────
let tags: string[] = ['ts', 'react'];
let matrix: number[][] = [[1, 2], [3, 4]];

// ─── Tuple ────────────────────────────────────────────────────
let coords: [number, number] = [0, 0];

// ─── Object / Interface ───────────────────────────────────────
interface User {
  id: number;
  name: string;
  email?: string;
  readonly createdAt: Date;
}

// ─── Type alias ───────────────────────────────────────────────
type Status = 'idle' | 'loading' | 'success' | 'error';
type UserID = string | number;

// ─── Union & Intersection ─────────────────────────────────────
type StringOrNumber = string | number;
type AdminUser = User & { role: 'admin' };

// ─── Function ─────────────────────────────────────────────────
function greet(name: string, title?: string): string { return '' }
const add = (a: number, b: number): number => a + b;
type Handler = (event: MouseEvent) => void;

// ─── Generics ─────────────────────────────────────────────────
function identity<T>(value: T): T { return value; }
interface Box<T> { value: T }

// ─── Utility Types ────────────────────────────────────────────
type P = Partial<User>;           // all optional
type R = Required<User>;          // all required
type RO = Readonly<User>;         // all readonly
type Preview = Pick<User, 'id' | 'name'>;
type Input = Omit<User, 'id' | 'createdAt'>;
type Map = Record<string, User>;
type Ret = ReturnType<typeof greet>;
type Params = Parameters<typeof greet>;

// ─── React ────────────────────────────────────────────────────
interface Props { label: string; onClick: () => void }
function Button({ label, onClick }: Props) { return null }

const [count, setCount] = useState<number>(0);
const [user, setUser] = useState<User | null>(null);
const ref = useRef<HTMLInputElement>(null);
const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {};
const handleSubmit = (e: React.FormEvent<HTMLFormElement>) => {};

// ─── Async ────────────────────────────────────────────────────
async function fetchUser(id: number): Promise<User> {
  const res = await fetch(`/api/users/${id}`);
  return res.json() as Promise<User>;
}
```

---

*This guide covers the TypeScript you will encounter in the vast majority of professional frontend work. The goal is not exhaustive language coverage but practical fluency — the ability to read, write, and debug real TypeScript in real React applications.*