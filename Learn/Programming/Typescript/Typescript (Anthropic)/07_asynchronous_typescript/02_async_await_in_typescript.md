## Async/Await in TypeScript


### Understanding Async/Await

Async/await is a modern JavaScript feature fully supported in TypeScript that provides a cleaner syntax for working with Promises. It allows asynchronous code to be written in a style that appears synchronous, making it more readable and maintainable.

**Key Points**

- `async` and `await` are TypeScript/JavaScript keywords introduced in ES2017
- An `async` function always returns a Promise
- The `await` keyword can only be used inside `async` functions (or in top-level code in modern environments)
- TypeScript provides strong typing for async operations
- Async/await is syntactic sugar over Promises

### Typing Async Functions

TypeScript enhances async/await with static type checking, making your asynchronous code more robust.

```typescript
// Basic async function typing
async function fetchData(): Promise<string> {
  // TypeScript knows this function returns a Promise<string>
  const response = await fetch('https://api.example.com/data');
  const text = await response.text();
  return text; // TypeScript ensures this is a string
}

// Arrow function with async
const getData = async (): Promise<Record<string, any>> => {
  const response = await fetch('https://api.example.com/data');
  const data = await response.json();
  return data; // TypeScript ensures this matches the return type
};

// Async methods in classes
class DataService {
  async fetchUsers(): Promise<User[]> {
    const response = await fetch('https://api.example.com/users');
    const users = await response.json();
    return users as User[]; // Type assertion for the parsed JSON
  }
}

// Interface for async functions
interface AsyncProcessor<T, R> {
  process(input: T): Promise<R>;
}

class DataProcessor implements AsyncProcessor<string, number> {
  async process(input: string): Promise<number> {
    // Implementation goes here
    return input.length;
  }
}
```

**Example** Creating a typed API client:

```typescript
// Define response types
interface User {
  id: number;
  name: string;
  email: string;
}

interface Post {
  id: number;
  userId: number;
  title: string;
  body: string;
}

// API client with typed async methods
class ApiClient {
  private baseUrl: string;
  
  constructor(baseUrl: string) {
    this.baseUrl = baseUrl;
  }
  
  async getUser(id: number): Promise<User> {
    const response = await fetch(`${this.baseUrl}/users/${id}`);
    
    if (!response.ok) {
      throw new Error(`Failed to fetch user: ${response.statusText}`);
    }
    
    return await response.json() as User;
  }
  
  async getUserPosts(userId: number): Promise<Post[]> {
    const response = await fetch(`${this.baseUrl}/users/${userId}/posts`);
    
    if (!response.ok) {
      throw new Error(`Failed to fetch posts: ${response.statusText}`);
    }
    
    return await response.json() as Post[];
  }
  
  async createPost(userId: number, title: string, body: string): Promise<Post> {
    const response = await fetch(`${this.baseUrl}/posts`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({ userId, title, body })
    });
    
    if (!response.ok) {
      throw new Error(`Failed to create post: ${response.statusText}`);
    }
    
    return await response.json() as Post;
  }
}

// Usage
const api = new ApiClient('https://api.example.com');

async function getUserWithPosts(userId: number): Promise<{user: User, posts: Post[]}> {
  const user = await api.getUser(userId);
  const posts = await api.getUserPosts(userId);
  
  return { user, posts };
}
```

### Generic Async Types

TypeScript's generic types work seamlessly with async functions:

```typescript
// Generic async function
async function processItems<T, R>(
  items: T[],
  processor: (item: T) => Promise<R>
): Promise<R[]> {
  const results: R[] = [];
  
  for (const item of items) {
    results.push(await processor(item));
  }
  
  return results;
}

// Usage
interface Product {
  id: string;
  name: string;
}

async function fetchProductDetails(id: string): Promise<Product> {
  const response = await fetch(`https://api.example.com/products/${id}`);
  return await response.json() as Product;
}

// TypeScript infers the correct types
const productIds = ['p1', 'p2', 'p3'];
const products = await processItems(productIds, fetchProductDetails);
// products is inferred as Product[]
```

### Error Handling with Async/Await

Error handling is one of the major advantages of async/await over traditional Promise chains. TypeScript enhances this with type checking for caught errors.

```typescript
// Basic try/catch
async function fetchData(): Promise<string> {
  try {
    const response = await fetch('https://api.example.com/data');
    
    if (!response.ok) {
      throw new Error(`HTTP error: ${response.status}`);
    }
    
    return await response.text();
  } catch (error) {
    // TypeScript 4.0+ allows type checking on error
    if (error instanceof Error) {
      console.error(`Error fetching data: ${error.message}`);
    } else {
      console.error(`Unknown error: ${String(error)}`);
    }
    throw error; // Re-throw or return a default value
  }
}

// Error boundaries pattern
async function withErrorBoundary<T>(
  operation: () => Promise<T>,
  fallback: T
): Promise<T> {
  try {
    return await operation();
  } catch (error) {
    console.error('Operation failed:', error);
    return fallback;
  }
}

// Usage
const data = await withErrorBoundary(
  () => fetchData(),
  'Default data'
);
```

**Example** Creating a robust error handling utility:

```typescript
// Define custom error types
class ApiError extends Error {
  constructor(
    public statusCode: number,
    message: string,
    public details?: any
  ) {
    super(message);
    this.name = 'ApiError';
  }
}

class NetworkError extends Error {
  constructor(message: string, public request?: Request) {
    super(message);
    this.name = 'NetworkError';
  }
}

class TimeoutError extends Error {
  constructor(message: string, public timeoutMs: number) {
    super(message);
    this.name = 'TimeoutError';
  }
}

// Type guard functions
function isApiError(error: unknown): error is ApiError {
  return error instanceof Error && error.name === 'ApiError';
}

function isNetworkError(error: unknown): error is NetworkError {
  return error instanceof Error && error.name === 'NetworkError';
}

function isTimeoutError(error: unknown): error is TimeoutError {
  return error instanceof Error && error.name === 'TimeoutError';
}

// Enhanced fetch with error handling
async function safeFetch<T>(
  url: string,
  options?: RequestInit,
  timeoutMs: number = 10000
): Promise<T> {
  // Create abort controller for timeout
  const controller = new AbortController();
  const timeoutId = setTimeout(() => controller.abort(), timeoutMs);
  
  try {
    const response = await fetch(url, {
      ...options,
      signal: controller.signal
    });
    
    clearTimeout(timeoutId);
    
    if (!response.ok) {
      let details;
      try {
        details = await response.json();
      } catch {
        // Ignore if response body is not valid JSON
      }
      
      throw new ApiError(
        response.status,
        `API error: ${response.statusText}`,
        details
      );
    }
    
    return await response.json() as T;
  } catch (error) {
    clearTimeout(timeoutId);
    
    if (error instanceof DOMException && error.name === 'AbortError') {
      throw new TimeoutError(`Request timed out after ${timeoutMs}ms`, timeoutMs);
    }
    
    if (error instanceof TypeError) {
      throw new NetworkError('Network error occurred');
    }
    
    throw error; // Re-throw ApiError or other errors
  }
}

// Usage with proper error handling
async function getUserData(userId: string): Promise<User> {
  try {
    return await safeFetch<User>(`https://api.example.com/users/${userId}`);
  } catch (error) {
    if (isApiError(error)) {
      if (error.statusCode === 404) {
        throw new Error(`User with ID ${userId} not found`);
      } else {
        throw new Error(`API error: ${error.message}`);
      }
    } else if (isTimeoutError(error)) {
      throw new Error(`Request timed out after ${error.timeoutMs}ms`);
    } else if (isNetworkError(error)) {
      throw new Error('Network connection issue. Please check your internet connection');
    } else {
      throw new Error(`Unknown error: ${String(error)}`);
    }
  }
}
```

### Parallel Execution

One of the significant advantages of async/await is the ability to perform operations in parallel when appropriate.

```typescript
// Promise.all for parallel execution
async function fetchMultipleResources(): Promise<[string, object, number[]]> {
  const [textData, jsonData, numberData] = await Promise.all([
    fetch('https://api.example.com/text').then(r => r.text()),
    fetch('https://api.example.com/json').then(r => r.json()),
    fetch('https://api.example.com/numbers').then(r => r.json())
  ]);
  
  return [textData, jsonData, numberData];
}

// Promise.allSettled for handling potential failures
async function fetchResourcesSafely<T>(
  urls: string[]
): Promise<{ status: 'fulfilled' | 'rejected', value?: T, reason?: any }[]> {
  const promises = urls.map(url => 
    fetch(url).then(r => r.json() as T)
  );
  
  const results = await Promise.allSettled(promises);
  return results as any; // Type assertion to simplify
}

// Promise.any to get the first successful result
async function fetchFirstAvailable<T>(apis: string[]): Promise<T> {
  try {
    return await Promise.any(apis.map(api => 
      fetch(api).then(r => {
        if (!r.ok) throw new Error(`API ${api} failed`);
        return r.json() as T;
      })
    ));
  } catch (error) {
    if (error instanceof AggregateError) {
      throw new Error(`All APIs failed: ${error.errors.map(e => e.message).join(', ')}`);
    }
    throw error;
  }
}

// Using Promise.race for timeouts
async function fetchWithTimeout<T>(
  url: string, 
  timeoutMs: number
): Promise<T> {
  const timeoutPromise = new Promise<never>((_, reject) => {
    setTimeout(() => reject(new Error(`Request timed out after ${timeoutMs}ms`)), timeoutMs);
  });
  
  const dataPromise = fetch(url).then(r => r.json() as T);
  
  return Promise.race([dataPromise, timeoutPromise]);
}
```

**Example** Loading data for a dashboard:

```typescript
interface UserStats {
  id: string;
  visitCount: number;
  lastActive: string;
}

interface SystemStats {
  cpuUsage: number;
  memoryUsage: number;
  uptime: number;
}

interface ActivityLog {
  timestamp: string;
  action: string;
  userId?: string;
}

async function loadDashboardData(
  apiBaseUrl: string
): Promise<{
  userStats: UserStats[];
  systemStats: SystemStats;
  recentActivity: ActivityLog[];
  errors: string[];
}> {
  const errors: string[] = [];
  
  // Define fetch functions
  const fetchUserStats = async (): Promise<UserStats[]> => {
    try {
      const response = await fetch(`${apiBaseUrl}/users/stats`);
      if (!response.ok) throw new Error(`HTTP error ${response.status}`);
      return await response.json();
    } catch (error) {
      errors.push(`Failed to fetch user stats: ${error instanceof Error ? error.message : String(error)}`);
      return [];
    }
  };
  
  const fetchSystemStats = async (): Promise<SystemStats> => {
    try {
      const response = await fetch(`${apiBaseUrl}/system/stats`);
      if (!response.ok) throw new Error(`HTTP error ${response.status}`);
      return await response.json();
    } catch (error) {
      errors.push(`Failed to fetch system stats: ${error instanceof Error ? error.message : String(error)}`);
      return { cpuUsage: 0, memoryUsage: 0, uptime: 0 };
    }
  };
  
  const fetchRecentActivity = async (): Promise<ActivityLog[]> => {
    try {
      const response = await fetch(`${apiBaseUrl}/activity/recent`);
      if (!response.ok) throw new Error(`HTTP error ${response.status}`);
      return await response.json();
    } catch (error) {
      errors.push(`Failed to fetch activity logs: ${error instanceof Error ? error.message : String(error)}`);
      return [];
    }
  };
  
  // Fetch all data in parallel
  const [userStats, systemStats, recentActivity] = await Promise.all([
    fetchUserStats(),
    fetchSystemStats(),
    fetchRecentActivity()
  ]);
  
  return {
    userStats,
    systemStats,
    recentActivity,
    errors
  };
}
```

### Sequential vs Concurrent Operations

Understanding when to run operations sequentially versus concurrently is crucial for optimal performance.

```typescript
// Sequential execution (when operations depend on each other)
async function processUserData(userId: string): Promise<ProcessedUserData> {
  // Each step depends on the previous one
  const user = await fetchUser(userId);
  const permissions = await fetchUserPermissions(user.id);
  const enrichedUser = await enrichUserData(user, permissions);
  return processData(enrichedUser);
}

// Concurrent execution (when operations are independent)
async function loadUserProfile(userId: string): Promise<UserProfile> {
  // These operations don't depend on each other and can run in parallel
  const [user, posts, followers] = await Promise.all([
    fetchUser(userId),
    fetchUserPosts(userId),
    fetchUserFollowers(userId)
  ]);
  
  return {
    ...user,
    posts,
    followers
  };
}

// Controlled concurrency (batch processing)
async function processItems<T, R>(
  items: T[],
  processor: (item: T) => Promise<R>,
  concurrency: number = 5
): Promise<R[]> {
  const results: R[] = [];
  const chunks = [];
  
  // Split items into chunks
  for (let i = 0; i < items.length; i += concurrency) {
    chunks.push(items.slice(i, i + concurrency));
  }
  
  // Process chunks sequentially, but items within a chunk concurrently
  for (const chunk of chunks) {
    const chunkResults = await Promise.all(
      chunk.map(item => processor(item))
    );
    results.push(...chunkResults);
  }
  
  return results;
}
```

**Example** Building a file processing pipeline:

```typescript
interface FileMetadata {
  id: string;
  name: string;
  size: number;
  type: string;
}

interface ProcessedFile extends FileMetadata {
  processedUrl: string;
  thumbnailUrl: string;
  processingTime: number;
}

class FileProcessor {
  async processFiles(
    files: File[],
    concurrency: number = 3
  ): Promise<ProcessedFile[]> {
    // Split into chunks to control concurrency
    const chunks: File[][] = [];
    for (let i = 0; i < files.length; i += concurrency) {
      chunks.push(files.slice(i, i + concurrency));
    }
    
    const results: ProcessedFile[] = [];
    
    // Process each chunk with controlled concurrency
    for (const chunk of chunks) {
      const chunkResults = await Promise.all(
        chunk.map(file => this.processSingleFile(file))
      );
      results.push(...chunkResults);
    }
    
    return results;
  }
  
  private async processSingleFile(file: File): Promise<ProcessedFile> {
    // These steps must happen sequentially as they depend on previous results
    const startTime = Date.now();
    
    // Step 1: Upload file to server
    const metadata = await this.uploadFile(file);
    
    // Step 2: Trigger processing on server
    const processedData = await this.triggerProcessing(metadata.id);
    
    // Step 3: Generate thumbnail (can happen in parallel with Step 2)
    const thumbnailData = await this.generateThumbnail(file);
    
    const processingTime = Date.now() - startTime;
    
    return {
      ...metadata,
      processedUrl: processedData.url,
      thumbnailUrl: thumbnailData.url,
      processingTime
    };
  }
  
  private async uploadFile(file: File): Promise<FileMetadata> {
    // Simulate file upload
    await new Promise(resolve => setTimeout(resolve, 500));
    
    return {
      id: `file-${Math.random().toString(36).substr(2, 9)}`,
      name: file.name,
      size: file.size,
      type: file.type
    };
  }
  
  private async triggerProcessing(fileId: string): Promise<{ url: string }> {
    // Simulate server-side processing
    await new Promise(resolve => setTimeout(resolve, 1000));
    
    return {
      url: `https://example.com/processed/${fileId}`
    };
  }
  
  private async generateThumbnail(file: File): Promise<{ url: string }> {
    // Simulate thumbnail generation
    await new Promise(resolve => setTimeout(resolve, 300));
    
    return {
      url: `https://example.com/thumbnails/${file.name.replace(/\s/g, '-')}`
    };
  }
}

// Usage
const processor = new FileProcessor();
const processedFiles = await processor.processFiles(userFiles, 3);
```

### Handling Async Patterns in TypeScript

#### Async Iteration

TypeScript fully supports the async iterator protocol:

```typescript
// Async generator function
async function* generateAsyncSequence(start: number, end: number): AsyncGenerator<number> {
  for (let i = start; i <= end; i++) {
    // Simulate async delay
    await new Promise(resolve => setTimeout(resolve, 100));
    yield i;
  }
}

// Using async iteration
async function sumAsyncSequence(): Promise<number> {
  let sum = 0;
  
  // Using for-await-of loop
  for await (const num of generateAsyncSequence(1, 5)) {
    sum += num;
  }
  
  return sum;
}

// Creating an async iterable class
class AsyncCollection<T> implements AsyncIterable<T> {
  private items: T[];
  
  constructor(items: T[]) {
    this.items = [...items];
  }
  
  async *[Symbol.asyncIterator](): AsyncIterator<T> {
    for (const item of this.items) {
      // Simulate network delay
      await new Promise(resolve => setTimeout(resolve, 100));
      yield item;
    }
  }
  
  // Example async method using the iterator
  async map<R>(fn: (item: T) => Promise<R>): Promise<R[]> {
    const results: R[] = [];
    for await (const item of this) {
      results.push(await fn(item));
    }
    return results;
  }
}

// Usage
const collection = new AsyncCollection([1, 2, 3, 4, 5]);
const doubled = await collection.map(async num => num * 2);
console.log(doubled); // [2, 4, 6, 8, 10]
```

#### Cancellation Patterns

Managing cancellation is essential for resource-intensive async operations:

```typescript
// Using AbortController for cancellation
async function fetchWithCancellation<T>(
  url: string,
  signal: AbortSignal
): Promise<T> {
  const response = await fetch(url, { signal });
  
  if (!response.ok) {
    throw new Error(`HTTP error: ${response.status}`);
  }
  
  return await response.json() as T;
}

// Usage
const controller = new AbortController();
const signal = controller.signal;

// Cancel after 5 seconds
setTimeout(() => controller.abort(), 5000);

try {
  const data = await fetchWithCancellation<User[]>('https://api.example.com/users', signal);
  processUsers(data);
} catch (error) {
  if (error instanceof DOMException && error.name === 'AbortError') {
    console.log('Fetch was cancelled');
  } else {
    console.error('Fetch error:', error);
  }
}
```

#### Debouncing Async Operations

TypeScript implementation of debounced async functions:

```typescript
// Debounce utility for async functions
function debounce<T extends (...args: any[]) => Promise<any>>(
  fn: T,
  delay: number
): (...args: Parameters<T>) => Promise<ReturnType<T>> {
  let timeout: NodeJS.Timeout | undefined;
  
  return (...args: Parameters<T>): Promise<ReturnType<T>> => {
    return new Promise(resolve => {
      if (timeout) {
        clearTimeout(timeout);
      }
      
      timeout = setTimeout(async () => {
        const result = await fn(...args);
        resolve(result as ReturnType<T>);
      }, delay);
    });
  };
}

// Usage
const debouncedSearch = debounce(async (query: string): Promise<SearchResult[]> => {
  const response = await fetch(`https://api.example.com/search?q=${encodeURIComponent(query)}`);
  return await response.json();
}, 300);

// Then in an event handler
searchInput.addEventListener('input', async (e) => {
  const query = (e.target as HTMLInputElement).value;
  const results = await debouncedSearch(query);
  displayResults(results);
});
```

### Testing Async Code

TypeScript provides excellent tooling for testing async code:

```typescript
// Using Jest with TypeScript for async testing
describe('UserService', () => {
  let service: UserService;
  
  beforeEach(() => {
    service = new UserService();
  });
  
  // Testing async functions
  test('should fetch user by ID', async () => {
    // Arrange
    const userId = '123';
    const mockUser = { id: userId, name: 'Test User' };
    
    // Mock the fetch function
    global.fetch = jest.fn().mockResolvedValue({
      ok: true,
      json: async () => mockUser
    });
    
    // Act
    const result = await service.getUserById(userId);
    
    // Assert
    expect(result).toEqual(mockUser);
    expect(fetch).toHaveBeenCalledWith(`https://api.example.com/users/${userId}`);
  });
  
  // Testing error handling
  test('should handle API errors', async () => {
    // Arrange
    const userId = '123';
    
    // Mock a failed response
    global.fetch = jest.fn().mockResolvedValue({
      ok: false,
      status: 404,
      statusText: 'Not Found'
    });
    
    // Act & Assert
    await expect(service.getUserById(userId)).rejects.toThrow('API error: Not Found');
  });
  
  // Testing timeout behavior
  test('should time out after specified duration', async () => {
    // Arrange
    jest.useFakeTimers();
    
    const fetchPromise = service.fetchWithTimeout('https://slow-api.example.com', 1000);
    
    // Fast-forward time
    jest.advanceTimersByTime(1001);
    
    // Assert
    await expect(fetchPromise).rejects.toThrow('Request timed out');
    
    jest.useRealTimers();
  });
});
```

### Advanced Async Patterns

#### Async Queue Implementation

Managing a queue of async tasks with controlled concurrency:

```typescript
interface Task<T> {
  execute: () => Promise<T>;
  resolve: (value: T) => void;
  reject: (error: Error) => void;
}

class AsyncQueue {
  private queue: Task<any>[] = [];
  private activeCount = 0;
  private readonly concurrency: number;
  
  constructor(concurrency: number = 1) {
    this.concurrency = concurrency;
  }
  
  public async add<T>(task: () => Promise<T>): Promise<T> {
    return new Promise<T>((resolve, reject) => {
      this.queue.push({
        execute: task,
        resolve,
        reject
      });
      
      this.processQueue();
    });
  }
  
  private async processQueue(): Promise<void> {
    if (this.activeCount >= this.concurrency || this.queue.length === 0) {
      return;
    }
    
    this.activeCount++;
    const task = this.queue.shift()!;
    
    try {
      const result = await task.execute();
      task.resolve(result);
    } catch (error) {
      task.reject(error instanceof Error ? error : new Error(String(error)));
    } finally {
      this.activeCount--;
      this.processQueue();
    }
  }
  
  public get pending(): number {
    return this.queue.length;
  }
  
  public get active(): number {
    return this.activeCount;
  }
}

// Usage
const queue = new AsyncQueue(3); // Process 3 tasks concurrently

for (let i = 0; i < 10; i++) {
  queue.add(async () => {
    console.log(`Starting task ${i}`);
    await new Promise(resolve => setTimeout(resolve, Math.random() * 1000));
    console.log(`Completed task ${i}`);
    return i;
  }).then(result => {
    console.log(`Got result: ${result}`);
  });
}

console.log(`Queued tasks: ${queue.pending}`);
```

#### Retry Pattern

Implementing a robust retry mechanism for async operations:

```typescript
interface RetryOptions {
  maxAttempts: number;
  initialDelay: number;
  maxDelay: number;
  backoffFactor: number;
  retryableErrors?: Array<new (...args: any[]) => Error>;
}

async function withRetry<T>(
  operation: () => Promise<T>,
  options: RetryOptions
): Promise<T> {
  let lastError: Error;
  let delay = options.initialDelay;
  
  for (let attempt = 1; attempt <= options.maxAttempts; attempt++) {
    try {
      return await operation();
    } catch (error) {
      if (!(error instanceof Error)) {
        throw error; // Not retryable if not an Error
      }
      
      lastError = error;
      
      // Check if this error type is retryable
      if (options.retryableErrors && 
          !options.retryableErrors.some(errorType => error instanceof errorType)) {
        throw error; // Not a retryable error type
      }
      
      // Last attempt - give up
      if (attempt >= options.maxAttempts) {
        break;
      }
      
      console.log(`Attempt ${attempt} failed, retrying in ${delay}ms`);
      
      // Wait before next retry
      await new Promise(resolve => setTimeout(resolve, delay));
      
      // Calculate next delay with exponential backoff
      delay = Math.min(delay * options.backoffFactor, options.maxDelay);
    }
  }
  
  throw lastError!;
}

// Usage
class NetworkError extends Error {
  constructor(message: string) {
    super(message);
    this.name = 'NetworkError';
  }
}

class ServerError extends Error {
  constructor(message: string) {
    super(message);
    this.name = 'ServerError';
  }
}

async function fetchData(): Promise<string> {
  return withRetry(
    async () => {
      // Simulate unstable network
      const random = Math.random();
      
      if (random < 0.3) {
        throw new NetworkError('Connection failed');
      } else if (random < 0.6) {
        throw new ServerError('Server error');
      }
      
      return 'Success data';
    },
    {
      maxAttempts: 5,
      initialDelay: 300,
      maxDelay: 5000,
      backoffFactor: 2,
      retryableErrors: [NetworkError, ServerError]
    }
  );
}
```

### Best Practices for Async/Await

**Key Points**

- Always specify return types for async functions
- Handle errors appropriately with try/catch
- Avoid unnecessary sequential operations - use `Promise.all` for concurrent tasks
- Be careful with loops and async operations
- Consider cancellation mechanisms for long-running operations
- Use proper TypeScript typing for all async code
- Keep the async boundary as far out as possible

```typescript
// AVOID: Unnecessary awaits in a loop
async function processItems(items: number[]): Promise<number[]> {
  const results = [];
  for (const item of items) {
    // Each iteration waits for the previous to complete
    results.push(await processItem(item));
  }
  return results;
}

// BETTER: Parallel processing with Promise.all
async function processItemsParallel(items: number[]): Promise<number[]> {
  const promises = items.map(item => processItem(item));
  return await Promise.all(promises);
}

// AVOID: Forgetting error handling
async function fetchDataUnsafe(): Promise<Data> {
  const response = await fetch('https://api.example.com/data');
  const data = await response.json();
  return data; // No error handling!
}

// BETTER: Proper error handling
async function fetchDataSafe(): Promise<Data> {
  try {
    const response = await fetch('https://api.example.com/data');
    
    if (!response.ok) {
      throw new Error(`HTTP error: ${response.status}`);
    }
    
    const data = await response.json();
    return data;
  } catch (error) {
    console.error('Failed to fetch data:', error);
    throw new Error(
      `Failed to fetch data: ${error instanceof Error ? error.message : String(error)}`
    );
  }
}
```

### Conclusion

Async/await in TypeScript provides a powerful way to work with asynchronous operations while maintaining code readability and strong typing. By properly typing your async functions, handling errors gracefully, and understanding when to use parallel versus sequential execution, you can build highly efficient and robust asynchronous applications.

TypeScript's type system enhances async/await by providing compile-time safety for promises, making potential errors visible before runtime. When combined with proper error handling strategies and advanced patterns like queues and retries, TypeScript's async/await becomes an essential tool for modern application development.

For more advanced TypeScript concepts, consider exploring:

- RxJS for reactive async programming
- TypeScript concurrency patterns and worker threads
- WebSockets and real-time communication in TypeScript
- State management with async operations

---

