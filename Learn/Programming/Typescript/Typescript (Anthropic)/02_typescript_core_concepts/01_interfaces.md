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

