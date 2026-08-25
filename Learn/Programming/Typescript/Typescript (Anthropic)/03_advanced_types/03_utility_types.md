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

