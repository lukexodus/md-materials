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

