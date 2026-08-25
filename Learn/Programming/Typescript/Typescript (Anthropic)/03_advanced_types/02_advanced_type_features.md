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

