## Advanced Asynchronous Patterns in TypeScript


### Introduction to Advanced Asynchronous Patterns

TypeScript provides powerful tools for handling asynchronous operations beyond basic Promises. Advanced patterns like Generators, Iterators, Observables, and various state management techniques can significantly improve code readability, maintainability, and performance when dealing with complex asynchronous workflows.

### Generators

Generators are special functions that can be paused and resumed, yielding multiple values over time. They're defined using the `function*` syntax and use the `yield` keyword.

**Key Points**

- Generator functions return an iterator when called
- Execution is paused at each `yield` statement
- State is preserved between yields
- Can be used to create infinite sequences
- Enable lazy evaluation of sequences

```typescript
function* countGenerator(): Generator<number> {
  let count = 0;
  while (true) {
    yield count++;
  }
}

// Usage
const counter = countGenerator();
console.log(counter.next().value); // 0
console.log(counter.next().value); // 1
console.log(counter.next().value); // 2
```

#### Error Handling in Generators

Generators can handle errors using try/catch blocks:

```typescript
function* generatorWithErrorHandling(): Generator<number> {
  try {
    yield 1;
    yield 2;
    throw new Error('Generator error');
    yield 3; // This line never executes
  } catch (error) {
    console.log('Error caught inside generator:', error.message);
    yield -1; // Error recovery value
  }
}

// Usage
const gen = generatorWithErrorHandling();
console.log(gen.next().value); // 1
console.log(gen.next().value); // 2
console.log(gen.next().value); // -1 (after logging the error message)
```

#### Generators for Asynchronous Operations

Generators paired with a runner function can simplify asynchronous code:

```typescript
function* fetchUserData(): Generator<Promise<any>, void, any> {
  try {
    const user = yield fetch('https://api.example.com/user').then(r => r.json());
    const posts = yield fetch(`https://api.example.com/posts?userId=${user.id}`).then(r => r.json());
    console.log('User:', user);
    console.log('Posts:', posts);
  } catch (error) {
    console.error('Error fetching data:', error);
  }
}

// Simple generator runner
function run(generator: Generator): Promise<any> {
  const iterator = generator;
  
  function handle(result: IteratorResult<any>): Promise<any> {
    if (result.done) return Promise.resolve(result.value);
    
    return Promise.resolve(result.value)
      .then(res => handle(iterator.next(res)))
      .catch(err => handle(iterator.throw(err)));
  }
  
  return handle(iterator.next());
}

// Usage
run(fetchUserData());
```

### Iterators

Iterators provide a way to access elements in a collection sequentially without exposing the underlying structure. In TypeScript, any object implementing the Iterator protocol can be iterated over.

**Key Points**

- Objects implementing the iterator protocol must have a `next()` method
- The `next()` method returns an object with `value` and `done` properties
- Custom iterators can be created for custom data structures
- Iterators work well with `for...of` loops

```typescript
class FibonacciSequence implements Iterable<number> {
  private limit: number;
  
  constructor(limit: number) {
    this.limit = limit;
  }
  
  [Symbol.iterator](): Iterator<number> {
    let prev = 0, curr = 1, count = 0;
    const limit = this.limit;
    
    return {
      next(): IteratorResult<number> {
        if (count >= limit) {
          return { value: undefined, done: true };
        }
        
        const value = prev;
        const next = prev + curr;
        prev = curr;
        curr = next;
        count++;
        
        return { value, done: false };
      }
    };
  }
}

// Usage
const fib = new FibonacciSequence(10);
for (const num of fib) {
  console.log(num);
}

// Using iterator manually
const iterator = fib[Symbol.iterator]();
let result = iterator.next();
while (!result.done) {
  console.log(result.value);
  result = iterator.next();
}
```

#### Async Iterators

TypeScript supports async iterators, allowing you to iterate over asynchronous data sources:

```typescript
class AsyncDataSource implements AsyncIterable<string> {
  private data: string[];
  
  constructor(data: string[]) {
    this.data = data;
  }
  
  [Symbol.asyncIterator](): AsyncIterator<string> {
    const data = this.data;
    let index = 0;
    
    return {
      async next(): Promise<IteratorResult<string>> {
        if (index >= data.length) {
          return { value: undefined, done: true };
        }
        
        // Simulate async operation
        await new Promise(resolve => setTimeout(resolve, 100));
        
        return {
          value: data[index++],
          done: false
        };
      }
    };
  }
}

// Usage with for await...of
async function processAsyncData() {
  const source = new AsyncDataSource(['one', 'two', 'three']);
  
  for await (const item of source) {
    console.log('Received:', item);
  }
}

processAsyncData();
```

### Observable Pattern

The Observable pattern provides a way to create streams of data or events that can be subscribed to by multiple observers. While not built into TypeScript, it's commonly implemented using libraries like RxJS.

**Key Points**

- Provides a publish-subscribe mechanism
- Handles multiple events over time (unlike Promises)
- Supports filtering, transformation, combination, and other operations
- Can be canceled via subscription
- Useful for event handling, real-time data, and UI interactions

```typescript
// Simple Observable implementation
class Observable<T> {
  private subscribers: Array<(value: T) => void> = [];
  
  subscribe(subscriber: (value: T) => void): { unsubscribe: () => void } {
    this.subscribers.push(subscriber);
    
    return {
      unsubscribe: () => {
        const index = this.subscribers.indexOf(subscriber);
        if (index > -1) {
          this.subscribers.splice(index, 1);
        }
      }
    };
  }
  
  next(value: T): void {
    this.subscribers.forEach(subscriber => subscriber(value));
  }
}

// Usage
const clickObservable = new Observable<MouseEvent>();

// Subscribe to clicks
const subscription = clickObservable.subscribe(event => {
  console.log('Click position:', event.clientX, event.clientY);
});

// Simulate clicks
document.addEventListener('click', (event) => {
  clickObservable.next(event);
});

// Later, to stop receiving updates
// subscription.unsubscribe();
```

#### RxJS Implementation

RxJS is a library that provides a comprehensive implementation of Observables:

```typescript
import { Observable, Subject, from, fromEvent } from 'rxjs';
import { map, filter, debounceTime, distinctUntilChanged } from 'rxjs/operators';

// Create an Observable from DOM events
const keyups = fromEvent<KeyboardEvent>(document.getElementById('search'), 'keyup');

// Process the event stream
const searchTerms = keyups.pipe(
  map(event => (event.target as HTMLInputElement).value),
  filter(term => term.length > 2),
  debounceTime(300),
  distinctUntilChanged()
);

// Subscribe to the processed stream
const subscription = searchTerms.subscribe(term => {
  console.log('Searching for:', term);
  // Perform search API call
});

// Later
subscription.unsubscribe();
```

#### Building a Simple Reactive State Store

Observables are excellent for state management in applications:

```typescript
import { BehaviorSubject } from 'rxjs';
import { map } from 'rxjs/operators';

interface AppState {
  user: { id: number; name: string } | null;
  isLoading: boolean;
  errors: string[];
}

class Store {
  private state$: BehaviorSubject<AppState>;
  
  constructor(initialState: AppState) {
    this.state$ = new BehaviorSubject<AppState>(initialState);
  }
  
  // Get current state
  getState(): AppState {
    return this.state$.getValue();
  }
  
  // Select part of state
  select<K extends keyof AppState>(key: K) {
    return this.state$.pipe(
      map(state => state[key])
    );
  }
  
  // Update state
  setState(partialState: Partial<AppState>): void {
    this.state$.next({
      ...this.state$.getValue(),
      ...partialState
    });
  }
  
  // Subscribe to state changes
  subscribe(listener: (state: AppState) => void) {
    const subscription = this.state$.subscribe(listener);
    return () => subscription.unsubscribe();
  }
}

// Usage
const store = new Store({
  user: null,
  isLoading: false,
  errors: []
});

// Subscribe to the entire state
const unsubscribe = store.subscribe(state => {
  console.log('State updated:', state);
});

// Subscribe to a specific slice of state
const userSubscription = store.select('user').subscribe(user => {
  console.log('User changed:', user);
});

// Update state
store.setState({ isLoading: true });
store.setState({ 
  user: { id: 1, name: 'John Doe' },
  isLoading: false
});

// Unsubscribe
unsubscribe();
userSubscription.unsubscribe();
```

### Managing Asynchronous State

Managing state across asynchronous operations can be challenging. TypeScript offers several patterns to handle this complexity.

#### State Machines

State machines are an excellent way to model complex asynchronous workflows:

```typescript
type FetchState = 
  | { status: 'idle' }
  | { status: 'loading' }
  | { status: 'success', data: any }
  | { status: 'error', error: Error };

class AsyncDataManager<T> {
  private state: FetchState = { status: 'idle' };
  private listeners: ((state: FetchState) => void)[] = [];
  
  getState(): FetchState {
    return this.state;
  }
  
  subscribe(listener: (state: FetchState) => void): () => void {
    this.listeners.push(listener);
    listener(this.state);
    
    return () => {
      this.listeners = this.listeners.filter(l => l !== listener);
    };
  }
  
  private setState(newState: FetchState): void {
    this.state = newState;
    this.listeners.forEach(listener => listener(this.state));
  }
  
  async fetchData(fetcher: () => Promise<T>): Promise<void> {
    this.setState({ status: 'loading' });
    
    try {
      const data = await fetcher();
      this.setState({ status: 'success', data });
    } catch (error) {
      this.setState({ status: 'error', error });
    }
  }
  
  reset(): void {
    this.setState({ status: 'idle' });
  }
}

// Usage
const userDataManager = new AsyncDataManager<User>();

userDataManager.subscribe(state => {
  switch (state.status) {
    case 'idle':
      console.log('Ready to fetch data');
      break;
    case 'loading':
      console.log('Loading...');
      break;
    case 'success':
      console.log('Data loaded:', state.data);
      break;
    case 'error':
      console.error('Error loading data:', state.error);
      break;
  }
});

// Fetch data
userDataManager.fetchData(async () => {
  const response = await fetch('https://api.example.com/user/1');
  return response.json();
});
```

#### Custom Hooks Pattern (React-inspired)

For frameworks like React, a custom hooks pattern can manage asynchronous state elegantly:

```typescript
function useAsync<T, E = string>(
  asyncFunction: () => Promise<T>,
  immediate = true
) {
  const [state, setState] = useState<{
    status: 'idle' | 'pending' | 'success' | 'error';
    data: T | null;
    error: E | null;
  }>({
    status: 'idle',
    data: null,
    error: null
  });

  const execute = useCallback(() => {
    setState({ status: 'pending', data: null, error: null });
    
    return asyncFunction()
      .then(response => {
        setState({ status: 'success', data: response, error: null });
        return response;
      })
      .catch(error => {
        setState({ status: 'error', data: null, error });
        throw error;
      });
  }, [asyncFunction]);

  useEffect(() => {
    if (immediate) {
      execute();
    }
  }, [execute, immediate]);

  return { execute, ...state };
}

// Usage (pseudocode for TypeScript illustration)
function UserProfile({ userId }: { userId: string }) {
  const { status, data: user, error } = useAsync(
    () => fetch(`/api/users/${userId}`).then(r => r.json())
  );

  if (status === 'pending') return <div>Loading...</div>;
  if (status === 'error') return <div>Error: {error}</div>;
  if (!user) return null;

  return <div>{user.name}</div>;
}
```

#### Cancelable Promises

Managing cancelable operations is crucial for preventing memory leaks and race conditions:

```typescript
interface CancelablePromise<T> extends Promise<T> {
  cancel: () => void;
}

function makeCancelable<T>(promise: Promise<T>): CancelablePromise<T> {
  let isCanceled = false;
  
  const wrappedPromise = new Promise<T>((resolve, reject) => {
    promise
      .then(val => (isCanceled ? reject({ isCanceled }) : resolve(val)))
      .catch(error => (isCanceled ? reject({ isCanceled }) : reject(error)));
  }) as CancelablePromise<T>;
  
  wrappedPromise.cancel = () => {
    isCanceled = true;
  };
  
  return wrappedPromise;
}

// Usage
class DataComponent {
  private currentRequest: CancelablePromise<any> | null = null;
  
  fetchData(id: string) {
    // Cancel previous request if exists
    if (this.currentRequest) {
      this.currentRequest.cancel();
    }
    
    this.currentRequest = makeCancelable(
      fetch(`https://api.example.com/data/${id}`).then(r => r.json())
    );
    
    return this.currentRequest
      .then(data => {
        console.log('Data received:', data);
        this.currentRequest = null;
        return data;
      })
      .catch(error => {
        if (error.isCanceled) {
          console.log('Request was canceled');
        } else {
          console.error('Error fetching data:', error);
        }
        this.currentRequest = null;
        throw error;
      });
  }
  
  cleanup() {
    if (this.currentRequest) {
      this.currentRequest.cancel();
      this.currentRequest = null;
    }
  }
}
```

#### AbortController API

Modern browsers provide the AbortController API for canceling fetch requests:

```typescript
class ApiClient {
  fetchWithTimeout(url: string, timeoutMs: number = 5000): Promise<Response> {
    const controller = new AbortController();
    const { signal } = controller;
    
    // Set timeout to abort
    const timeout = setTimeout(() => controller.abort(), timeoutMs);
    
    return fetch(url, { signal })
      .finally(() => clearTimeout(timeout));
  }
  
  async fetchMultiple(urls: string[]): Promise<Response[]> {
    const controller = new AbortController();
    const { signal } = controller;
    
    try {
      return await Promise.all(
        urls.map(url => fetch(url, { signal }))
      );
    } catch (error) {
      // If any request fails, abort all others
      controller.abort();
      throw error;
    }
  }
}

// Usage
const client = new ApiClient();
client.fetchWithTimeout('https://api.example.com/data')
  .then(response => response.json())
  .then(data => console.log('Data:', data))
  .catch(error => {
    if (error.name === 'AbortError') {
      console.log('Request timed out');
    } else {
      console.error('Request failed:', error);
    }
  });
```

### Advanced Asynchronous Control Flow

#### Sequential Execution of Async Tasks

When tasks need to be executed in sequence:

```typescript
async function executeSequentially<T>(
  tasks: Array<() => Promise<T>>
): Promise<T[]> {
  const results: T[] = [];
  
  for (const task of tasks) {
    const result = await task();
    results.push(result);
  }
  
  return results;
}

// Usage
const tasks = [
  () => fetchUser(1),
  () => fetchUser(2),
  () => fetchUser(3)
];

executeSequentially(tasks).then(users => {
  console.log('Users:', users);
});
```

#### Limiting Concurrency

When dealing with many async operations but wanting to limit concurrency:

```typescript
async function asyncPool<T, R>(
  concurrency: number,
  items: T[],
  iteratorFn: (item: T, index: number) => Promise<R>
): Promise<R[]> {
  const results: R[] = [];
  const executing: Promise<void>[] = [];
  let index = 0;
  
  for (const item of items) {
    const itemIndex = index++;
    
    // Create a promise that resolves when the task completes
    // and its result is added to results
    const p = Promise.resolve().then(() => iteratorFn(item, itemIndex))
      .then(result => {
        results[itemIndex] = result;
      });
    
    executing.push(p);
    
    // If we've reached the concurrency limit, wait for one to finish
    if (executing.length >= concurrency) {
      await Promise.race(executing.map(e => e.catch(() => {})));
      
      // Remove completed promises
      const completedIndex = executing.findIndex(p => p.status === 'fulfilled');
      if (completedIndex !== -1) {
        executing.splice(completedIndex, 1);
      }
    }
  }
  
  // Wait for all executing promises to finish
  await Promise.all(executing);
  
  return results;
}

// Usage
const urls = Array(20).fill(0).map((_, i) => `https://api.example.com/item/${i + 1}`);

asyncPool(5, urls, url => 
  fetch(url).then(r => r.json())
).then(results => {
  console.log('All results:', results);
});
```

#### Retry Logic

Adding retry logic to async operations:

```typescript
async function retryOperation<T>(
  operation: () => Promise<T>,
  retries: number = 3,
  delay: number = 300,
  backoff: number = 2
): Promise<T> {
  let attempts = 0;
  
  async function attempt(): Promise<T> {
    try {
      return await operation();
    } catch (error) {
      attempts++;
      
      if (attempts >= retries) {
        throw error;
      }
      
      const waitTime = delay * Math.pow(backoff, attempts - 1);
      console.log(`Retry attempt ${attempts}/${retries} after ${waitTime}ms`);
      
      await new Promise(resolve => setTimeout(resolve, waitTime));
      return attempt();
    }
  }
  
  return attempt();
}

// Usage
retryOperation(
  () => fetch('https://flaky-api.example.com/data').then(r => r.json()),
  5,
  500,
  1.5
)
.then(data => console.log('Data retrieved successfully:', data))
.catch(error => console.error('All retries failed:', error));
```

### Generators for Advanced Async Workflows

#### Handling Async Operations with Co-routines

Co-routines using generators provide an elegant way to handle complicated async workflows:

```typescript
type Co<T> = Generator<Promise<any>, T, any>;

function co<T>(gen: () => Co<T>): Promise<T> {
  const generator = gen();

  function next(value?: any): Promise<T> {
    const result = generator.next(value);
    
    if (result.done) {
      return Promise.resolve(result.value);
    }
    
    return Promise.resolve(result.value)
      .then(res => next(res))
      .catch(err => {
        return Promise.resolve(generator.throw(err)).then(next);
      });
  }
  
  return next();
}

// Usage
interface User { id: number; name: string; }
interface Post { id: number; title: string; userId: number; }

function* fetchUserAndPosts(userId: number): Co<{user: User, posts: Post[]}> {
  try {
    // Fetch user
    const user: User = yield fetch(`https://api.example.com/users/${userId}`)
      .then(r => r.json());
      
    // Fetch posts using the user ID
    const posts: Post[] = yield fetch(`https://api.example.com/posts?userId=${user.id}`)
      .then(r => r.json());
    
    return { user, posts };
  } catch (error) {
    console.error('Error in generator:', error);
    throw error;
  }
}

co(function* () {
  const { user, posts } = yield* fetchUserAndPosts(1);
  console.log(`User ${user.name} has ${posts.length} posts`);
  return { user, posts };
})
.then(result => console.log('Final result:', result))
.catch(error => console.error('Co execution failed:', error));
```

#### Async Generator Functions

TypeScript supports async generator functions:

```typescript
async function* fetchPaginatedData(
  baseUrl: string,
  pageSize: number = 10
): AsyncGenerator<any[], void, unknown> {
  let page = 1;
  let hasMore = true;
  
  while (hasMore) {
    const url = `${baseUrl}?page=${page}&pageSize=${pageSize}`;
    const response = await fetch(url);
    const data = await response.json();
    
    if (data.items.length > 0) {
      yield data.items;
      page++;
    } else {
      hasMore = false;
    }
  }
}

// Usage
async function processPaginatedData() {
  const dataGenerator = fetchPaginatedData('https://api.example.com/products');
  
  let totalProcessed = 0;
  
  for await (const items of dataGenerator) {
    console.log(`Processing ${items.length} items`);
    // Process items...
    totalProcessed += items.length;
  }
  
  console.log(`Finished processing ${totalProcessed} items total`);
}

processPaginatedData();
```

### Combining Async Patterns

Different async patterns can be combined to create powerful solutions:

```typescript
// Observable that uses generators internally
class LazyObservable<T> implements Observable<T> {
  private generator: () => Generator<T, void, unknown>;
  
  constructor(generator: () => Generator<T, void, unknown>) {
    this.generator = generator;
  }
  
  subscribe(observer: Observer<T>): Subscription {
    const iterator = this.generator();
    let stopped = false;
    
    const processNext = () => {
      if (stopped) return;
      
      try {
        const result = iterator.next();
        
        if (result.done) {
          observer.complete?.();
          return;
        }
        
        observer.next(result.value);
        setTimeout(processNext, 0);
      } catch (error) {
        observer.error?.(error);
      }
    };
    
    processNext();
    
    return {
      unsubscribe: () => {
        stopped = true;
      }
    };
  }
}

// Usage
function* numberGenerator() {
  let i = 0;
  while (i < 10) {
    yield i++;
  }
}

const observable = new LazyObservable(numberGenerator);

const subscription = observable.subscribe({
  next: value => console.log('Value:', value),
  complete: () => console.log('Complete!'),
  error: err => console.error('Error:', err)
});

// Later
// subscription.unsubscribe();
```

### Performance Considerations

#### Optimizing Async Operations

**Key Points**

- Use Promise.all for concurrent operations where order doesn't matter
- Use AbortController to cancel unnecessary requests
- Consider streaming for large data sets
- Implement proper error boundaries to prevent cascading failures
- Use memoization for expensive async operations

```typescript
// Cache expensive async operations
function memoizeAsync<T, R>(
  fn: (arg: T) => Promise<R>,
  keyFn: (arg: T) => string = JSON.stringify
): (arg: T) => Promise<R> {
  const cache = new Map<string, R>();
  
  return async (arg: T): Promise<R> => {
    const key = keyFn(arg);
    
    if (cache.has(key)) {
      return cache.get(key)!;
    }
    
    const result = await fn(arg);
    cache.set(key, result);
    return result;
  };
}

// Usage
const fetchUserMemoized = memoizeAsync(
  (id: number) => fetch(`https://api.example.com/users/${id}`).then(r => r.json()),
  id => `user-${id}`
);

// First call will fetch
fetchUserMemoized(1).then(user => console.log('User:', user));

// Second call with same ID will use cache
fetchUserMemoized(1).then(user => console.log('User (from cache):', user));
```

#### Batching API Requests

```typescript
class BatchingApi {
  private queue: Map<string, {
    resolve: (value: any) => void;
    reject: (error: any) => void;
  }[]> = new Map();
  
  private timeout: NodeJS.Timeout | null = null;
  private batchDelay: number;
  
  constructor(batchDelay: number = 50) {
    this.batchDelay = batchDelay;
  }
  
  fetch<T>(endpoint: string, id: string): Promise<T> {
    return new Promise<T>((resolve, reject) => {
      const key = `${endpoint}`;
      
      if (!this.queue.has(key)) {
        this.queue.set(key, []);
      }
      
      this.queue.get(key)!.push({ resolve, reject });
      
      if (!this.timeout) {
        this.timeout = setTimeout(() => this.processBatch(), this.batchDelay);
      }
    });
  }
  
  private async processBatch() {
    this.timeout = null;
    const currentQueue = new Map(this.queue);
    this.queue.clear();
    
    for (const [endpoint, requests] of currentQueue.entries()) {
      if (requests.length === 0) continue;
      
      try {
        const ids = requests.map(r => r.id).join(',');
        const response = await fetch(`${endpoint}?ids=${ids}`);
        const data = await response.json();
        
        // Distribute results back to individual requesters
        for (const request of requests) {
          request.resolve(data.find((item: any) => item.id === request.id));
        }
      } catch (error) {
        // Propagate error to all requesters
        for (const request of requests) {
          request.reject(error);
        }
      }
    }
  }
}

// Usage
const api = new BatchingApi();

// These calls will be batched together
api.fetch('https://api.example.com/users', '1').then(user => console.log('User 1:', user));
api.fetch('https://api.example.com/users', '2').then(user => console.log('User 2:', user));
api.fetch('https://api.example.com/users', '3').then(user => console.log('User 3:', user));
```

### Testing Asynchronous Patterns

Testing async code requires special techniques:

```typescript
// Jest-like test examples
describe('Async patterns', () => {
  test('Observable emits correct values', done => {
    const observable = new Observable<number>(observer => {
      observer.next(1);
      observer.next(2);
      observer.next(3);
      observer.complete();
      
      return { unsubscribe: () => {} };
    });
    
    const values: number[] = [];
    
    observable.subscribe({
      next: value => values.push(value),
      complete: () => {
        expect(values).toEqual([1, 2, 3]);
        done();
      }
    });
  });
  
  test('AsyncDataManager handles state transitions', async () => {
    const manager = new AsyncDataManager<string[]>();
    const states: string[] = [];
    
    manager.subscribe(state => {
      states.push(state.status);
    });
    
    const fetcher = jest.fn().mockResolvedValue(['item1', 'item2']);
    
    await manager.fetchData(fetcher);
    
    expect(states).toEqual(['idle', 'loading', 'success']);
    expect(fetcher).toHaveBeenCalledTimes(1);
    expect(manager.getState()).toEqual({
      status: 'success',
      data: ['item1', 'item2']
    });
  });
  
  test('Generator yields correct values', () => {
    function* testGenerator() {
      yield 1;
      yield 2;
      return 3;
    }
    
    const gen = testGenerator();
    expect(gen.next()).toEqual({ value: 1, done: false });
    expect(gen.next()).toEqual({ value: 2, done: false });
    expect(gen.next()).toEqual({ value: 3, done: true });
  });
});
```

### Real-World Examples

#### Building a Data Streaming API with Async Generators

```typescript
import * as fs from 'fs';
import * as http from 'http';

// Server-side streaming API
async function* streamData(
  filePath: string,
  chunkSize: number = 1024
): AsyncGenerator<Buffer, void, unknown> {
  const fileHandle = await fs.promises.open(filePath, 'r');
  const stats = await fs.promises.stat(filePath);
  const fileSize = stats.size;

  try {
    let bytesRead = 0;

    while (bytesRead < fileSize) {
      const buffer = Buffer.alloc(chunkSize);
      const result = await fileHandle.read(buffer, 0, chunkSize, bytesRead);

      bytesRead += result.bytesRead;

      if (result.bytesRead > 0) {
        yield buffer.slice(0, result.bytesRead);
      }

      if (result.bytesRead < chunkSize) {
        break;
      }
    }
  } finally {
    await fileHandle.close();
  }
}

// Usage (Node.js example)
async function handleStreamRequest(req: http.IncomingMessage, res: http.ServerResponse) {
  const filePath = './large-file.txt'; // Replace with actual file path

  res.setHeader('Content-Type', 'application/octet-stream');
  res.setHeader('Transfer-Encoding', 'chunked');

  try {
    for await (const chunk of streamData(filePath)) {
      res.write(chunk);
    }
    res.end();
  } catch (error) {
    console.error('Streaming error:', error);
    res.statusCode = 500;
    res.end('Internal Server Error');
  }
}

// Start server
const server = http.createServer((req, res) => {
  if (req.url === '/stream') {
    handleStreamRequest(req, res);
  } else {
    res.statusCode = 404;
    res.end('Not Found');
  }
});

server.listen(3000, () => {
  console.log('Server listening on http://localhost:3000');
});
```

---

