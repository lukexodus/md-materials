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

