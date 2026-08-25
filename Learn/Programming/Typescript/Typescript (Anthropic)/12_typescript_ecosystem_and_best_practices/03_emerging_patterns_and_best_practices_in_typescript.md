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
