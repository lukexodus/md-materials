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

