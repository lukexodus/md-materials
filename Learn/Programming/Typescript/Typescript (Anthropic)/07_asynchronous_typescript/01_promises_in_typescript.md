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

