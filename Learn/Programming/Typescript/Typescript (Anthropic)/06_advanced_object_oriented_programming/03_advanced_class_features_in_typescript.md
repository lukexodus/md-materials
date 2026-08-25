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

