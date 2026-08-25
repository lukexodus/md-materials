## Promise-Based Architecture


### Core Architecture Patterns

#### Promise Chain Architecture

Promise chains form the backbone of sequential asynchronous operations. Each `.then()` returns a new promise, enabling composition where the output of one operation feeds into the next. The chain maintains a single execution path with automatic error propagation through `.catch()` handlers.

```javascript
fetchUser(id)
  .then(user => fetchPermissions(user.id))
  .then(permissions => validateAccess(permissions))
  .then(access => loadResource(access))
  .catch(handleError);
```

The chain architecture enforces explicit data flow - transformations occur at each step, and errors bypass intermediate handlers until caught. This creates predictable execution sequences where state transformations are localized to individual promise handlers.

#### Promise Coordination Patterns

Multiple promises require coordination strategies based on dependency relationships:

**Parallel Execution** - `Promise.all()` waits for all promises to resolve, failing fast on the first rejection. This suits independent operations where all results are required:

```javascript
Promise.all([
  fetchUserData(id),
  fetchUserPosts(id),
  fetchUserFollowers(id)
]).then(([user, posts, followers]) => {
  // All data available simultaneously
});
```

**Race Conditions** - `Promise.race()` resolves or rejects with the first settled promise. This enables timeout implementations, fallback mechanisms, and competitive resource fetching:

```javascript
Promise.race([
  fetchFromPrimaryServer(),
  fetchFromBackupServer(),
  timeout(5000)
]);
```

**Partial Success Handling** - `Promise.allSettled()` waits for all promises regardless of outcome, returning status objects. This allows processing whatever succeeded while handling failures independently:

```javascript
const results = await Promise.allSettled(operations);
const succeeded = results.filter(r => r.status === 'fulfilled');
const failed = results.filter(r => r.status === 'rejected');
```

**First Success Pattern** - `Promise.any()` resolves with the first successful promise, ignoring rejections unless all fail. This suits redundant operations where any successful result suffices.

### State Management in Promise Architecture

#### Promise State Lifecycle

Promises exist in three states: pending (initial), fulfilled (successful completion), or rejected (failed). This state is immutable once settled - a fulfilled promise cannot transition to rejected or vice versa. The immutability guarantees prevent race conditions in state observation.

State transitions trigger registered handlers asynchronously. Even if a promise is already settled when `.then()` is called, the handler executes asynchronously on the next microtask checkpoint. This consistent asynchronous behavior prevents timing-dependent bugs.

#### Internal State Representation

[Inference] Promise implementations typically maintain internal slots for state, result value, and handler queues. When pending, the promise accumulates fulfillment and rejection handlers in queues. Upon settlement, the promise stores the result value and drains the handler queues, executing each callback with the stored value.

The internal state encapsulation ensures external code cannot directly mutate promise state - only the resolver function provided during promise construction can trigger state transitions.

#### State Observation Without Mutation

Promises expose state through handler registration rather than direct inspection. Code observes state changes by attaching callbacks that execute upon settlement. This observer pattern decouples state producers from consumers:

```javascript
const promise = asyncOperation();

// Consumer 1 observes eventual state
promise.then(handleSuccess);

// Consumer 2 observes same state independently
promise.then(processResult);

// Both receive the same settled value
```

Multiple observers receive the same settled value without interfering with each other. The promise memorizes its result, delivering it to all current and future observers.

### Error Handling Architecture

#### Error Propagation Mechanics

Errors in promise chains propagate automatically until caught. When a promise rejects or a `.then()` handler throws, the rejection travels down the chain bypassing fulfillment handlers until encountering a rejection handler:

```javascript
fetchData()
  .then(parseJSON)      // Throws on invalid JSON
  .then(validateSchema) // Skipped if parseJSON throws
  .then(processData)    // Skipped if validation fails
  .catch(handleError);  // Catches any upstream error
```

This creates implicit try-catch blocks around each handler. Synchronous exceptions automatically convert to promise rejections, unifying error handling for both sync and async failures.

#### Error Recovery Patterns

Rejection handlers can recover from errors by returning normal values, converting rejection back to fulfillment:

```javascript
fetchPrimaryData()
  .catch(err => {
    console.warn('Primary failed, using cache');
    return getCachedData(); // Recovery: rejection → fulfillment
  })
  .then(processData); // Receives either primary or cached data
```

Returning a rejected promise or throwing in a `.catch()` handler continues the error state, enabling error transformation:

```javascript
operation()
  .catch(err => {
    if (err.retryable) {
      return retry(operation);
    }
    throw new ApplicationError('Operation failed permanently', err);
  });
```

#### Unhandled Rejection Architecture

Promises without rejection handlers generate unhandled rejection events when rejected. [Inference] Runtime environments track promises without attached rejection handlers and emit warnings or events when such promises reject. This detection typically involves monitoring whether rejection handlers exist when a promise settles.

Modern environments provide `unhandledrejection` events (browsers) or `unhandledRejection` events (Node.js) that fire when rejections go unhandled, enabling centralized error logging:

```javascript
window.addEventListener('unhandledrejection', event => {
  console.error('Unhandled rejection:', event.reason);
  logToMonitoring(event.reason);
});
```

### Composition and Abstraction Patterns

#### Promise-Returning Function Design

Functions returning promises establish contracts about asynchronous completion. The returned promise represents the eventual outcome of the operation:

```javascript
function loadUserProfile(userId) {
  return fetch(`/api/users/${userId}`)
    .then(response => response.json())
    .then(data => new UserProfile(data));
}
```

This pattern enables composition where promise-returning functions call other promise-returning functions, building complex asynchronous workflows from simpler operations. The promise return type signals asynchronous behavior to callers without requiring callback parameters.

#### Higher-Order Promise Functions

Functions that accept promises as arguments or return promise-manipulating functions enable abstraction over asynchronous patterns:

```javascript
function timeout(ms) {
  return new Promise((resolve, reject) => {
    setTimeout(() => reject(new Error('Timeout')), ms);
  });
}

function withTimeout(promise, ms) {
  return Promise.race([promise, timeout(ms)]);
}

// Usage creates timeout-wrapped operations
const result = await withTimeout(slowOperation(), 5000);
```

These abstractions encapsulate cross-cutting concerns like timeouts, retries, and rate limiting without modifying core operation implementations.

#### Promise Middleware Patterns

Middleware architectures apply transformations or side effects to promise chains:

```javascript
function withLogging(promiseFn) {
  return function(...args) {
    console.log('Starting operation');
    return promiseFn(...args)
      .then(result => {
        console.log('Operation succeeded');
        return result;
      })
      .catch(err => {
        console.error('Operation failed');
        throw err;
      });
  };
}

const loggedFetch = withLogging(fetch);
```

This pattern separates concerns by wrapping promise-returning functions with additional behavior while preserving the promise interface.

### Async/Await as Architectural Sugar

#### Syntactic Transform to Promises

Async functions are promises with synchronous-looking syntax. An `async` function always returns a promise - returned values automatically wrap in `Promise.resolve()`, and thrown errors convert to rejections:

```javascript
async function fetchUserData(id) {
  const response = await fetch(`/api/users/${id}`);
  return response.json(); // Automatically wrapped in Promise.resolve()
}

// Equivalent to:
function fetchUserData(id) {
  return fetch(`/api/users/${id}`)
    .then(response => response.json());
}
```

The `await` keyword unwraps promises, pausing function execution until the promise settles. This creates sequential appearance while maintaining non-blocking behavior.

#### Error Handling Transformation

Try-catch blocks in async functions map to promise rejection handling:

```javascript
async function loadData() {
  try {
    const data = await fetchData();
    return processData(data);
  } catch (error) {
    return getDefaultData();
  }
}

// Promise equivalent:
function loadData() {
  return fetchData()
    .then(processData)
    .catch(getDefaultData);
}
```

This syntactic transformation makes error handling appear synchronous while preserving promise semantics. Uncaught exceptions in async functions become unhandled promise rejections.

#### Control Flow Preservation

Async/await maintains standard control flow constructs unavailable in promise chains:

```javascript
async function processItems(items) {
  const results = [];
  for (const item of items) {
    const result = await processItem(item);
    if (result.shouldContinue) {
      results.push(result);
    } else {
      break; // Early exit from async loop
    }
  }
  return results;
}
```

Loops, conditionals, and early returns work naturally with async/await but require complex promise chain construction. This makes async/await preferable for intricate control flow while simple chains remain clearer for linear pipelines.

### Memory and Performance Architecture

#### Promise Overhead Characteristics

Each promise allocates memory for state tracking, result storage, and handler queues. [Inference] Promise creation involves allocating objects for the promise itself and its resolver functions. Long promise chains create proportional memory pressure as each `.then()` generates a new promise object.

Handler queues grow with the number of attached callbacks. A single promise with many observers stores references to all handlers until settlement, after which handler references typically clear to allow garbage collection.

#### Microtask Queue Architecture

Promise handlers execute on the microtask queue, which processes between regular task execution. [Inference] When a promise settles, its handlers enqueue as microtasks. The event loop drains all microtasks before proceeding to the next task, ensuring promise handlers run before I/O callbacks or timers.

This guarantees that promise chains execute without interleaving from other asynchronous operations:

```javascript
Promise.resolve().then(() => console.log('Microtask 1'));
Promise.resolve().then(() => console.log('Microtask 2'));
setTimeout(() => console.log('Task'), 0);

// Output order: Microtask 1, Microtask 2, Task
// Microtasks drain completely before timer task executes
```

The microtask queue prioritization affects performance - long microtask sequences can delay rendering or I/O processing.

#### Promise Chain Optimization

Long chains can optimize through combination:

```javascript
// Multiple promise creations
fetch(url)
  .then(r => r.json())
  .then(data => data.users)
  .then(users => users[0]);

// Reduced allocations
fetch(url)
  .then(r => r.json())
  .then(data => data.users[0]);
```

Combining operations in single handlers reduces intermediate promise allocations. However, this trades allocation cost for handler complexity - balance depends on performance requirements.

#### Lazy Promise Execution

Promises execute immediately upon creation. [Inference] The executor function passed to `new Promise()` runs synchronously before the constructor returns:

```javascript
console.log('Before');
new Promise((resolve) => {
  console.log('Executor runs immediately');
  resolve();
});
console.log('After');

// Output: Before, Executor runs immediately, After
```

This differs from lazy evaluation patterns. For deferred execution, wrap promise creation in functions:

```javascript
function lazyOperation() {
  return new Promise((resolve) => {
    // Executor runs when function called, not when defined
    expensiveOperation();
    resolve();
  });
}

const operation = lazyOperation; // No execution yet
const promise = operation();     // Execution begins
```

### Cancellation and Resource Management

#### Promise Cancellation Challenges

Standard promises lack built-in cancellation. Once created, a promise continues until settlement. [Inference] This design choice stems from promise state immutability - cancellation would require a fourth state or special rejection handling, complicating the state model.

External cancellation requires coordination mechanisms:

```javascript
function cancellableOperation(signal) {
  return new Promise((resolve, reject) => {
    if (signal.aborted) {
      reject(new Error('Aborted'));
      return;
    }
    
    signal.addEventListener('abort', () => {
      reject(new Error('Aborted'));
    });
    
    performOperation().then(resolve);
  });
}

const controller = new AbortController();
const promise = cancellableOperation(controller.signal);

// Cancel the operation
controller.abort();
```

This pattern checks cancellation state externally rather than modifying promise internals.

#### Resource Cleanup Patterns

Promises don't provide cleanup hooks like `finally` does guaranteed cleanup:

```javascript
let resource;
openResource()
  .then(r => {
    resource = r;
    return processResource(resource);
  })
  .finally(() => {
    if (resource) {
      resource.close();
    }
  });
```

The `finally` handler executes regardless of fulfillment or rejection, enabling cleanup. However, it doesn't receive the settled value, preventing value-dependent cleanup logic.

For complex resource management, explicit patterns handle acquisition and release:

```javascript
async function withResource(resourceId, handler) {
  const resource = await acquireResource(resourceId);
  try {
    return await handler(resource);
  } finally {
    await releaseResource(resource);
  }
}

// Usage guarantees cleanup
await withResource('db-connection', async (conn) => {
  return conn.query('SELECT * FROM users');
});
```

### Integration Patterns

#### Promisification of Callback APIs

Legacy callback-based APIs convert to promises through wrapper functions:

```javascript
function promisify(callbackFn) {
  return function(...args) {
    return new Promise((resolve, reject) => {
      callbackFn(...args, (err, result) => {
        if (err) reject(err);
        else resolve(result);
      });
    });
  };
}

// Convert callback API
const readFileAsync = promisify(fs.readFile);
const contents = await readFileAsync('file.txt', 'utf8');
```

This pattern bridges callback conventions with promise architecture, enabling gradual migration of codebases.

#### Event-to-Promise Conversion

Single-occurrence events convert to promises for one-time asynchronous waiting:

```javascript
function waitForEvent(emitter, eventName, errorEvent = 'error') {
  return new Promise((resolve, reject) => {
    emitter.once(eventName, resolve);
    emitter.once(errorEvent, reject);
  });
}

// Usage waits for next occurrence
const result = await waitForEvent(socket, 'data');
```

This pattern suits scenarios where event represents completion rather than ongoing notifications.

#### Stream Processing Architecture

Promises integrate with streams through async iteration:

```javascript
async function processStream(stream) {
  for await (const chunk of stream) {
    await processChunk(chunk);
  }
}
```

Each iteration returns a promise that resolves with the next chunk, combining streaming and promise-based architectures. This enables backpressure handling where processing pauses until `processChunk` completes.

### Testing and Debugging Architecture

#### Promise Resolution Testing

Testing promise-based code requires waiting for settlement:

```javascript
test('async operation succeeds', async () => {
  const result = await asyncOperation();
  expect(result).toBe(expected);
});

// Or with explicit promise handling
test('async operation succeeds', () => {
  return asyncOperation().then(result => {
    expect(result).toBe(expected);
  });
});
```

Test frameworks recognize returned promises, waiting for settlement before concluding tests. Unhandled rejections cause test failures.

#### Rejection Testing Patterns

Testing error cases requires explicit rejection handling:

```javascript
test('operation rejects on invalid input', async () => {
  await expect(asyncOperation(invalidInput))
    .rejects
    .toThrow('Invalid input');
});

// Without async/await
test('operation rejects', () => {
  return asyncOperation().then(
    () => { throw new Error('Should have rejected'); },
    err => { expect(err.message).toBe('Expected error'); }
  );
});
```

The testing pattern inverts normal control flow - rejections become expected outcomes rather than failures.

#### Promise State Inspection

[Inference] Debugging often requires understanding promise state, but promises don't expose state inspection methods. Development tools provide promise state visualization, showing pending/fulfilled/rejected status and resolved values in debugger interfaces.

For programmatic inspection during testing, wrapper patterns track state:

```javascript
class InspectablePromise extends Promise {
  constructor(executor) {
    super((resolve, reject) => {
      this._state = 'pending';
      executor(
        value => { this._state = 'fulfilled'; resolve(value); },
        reason => { this._state = 'rejected'; reject(reason); }
      );
    });
  }
  
  getState() { return this._state; }
}
```

[Unverified] This approach may not work consistently across all environments due to promise subclassing limitations.

#### Timing and Race Condition Testing

Asynchronous timing creates test challenges. Deterministic testing requires controlling promise resolution order:

```javascript
function createControllablePromise() {
  let resolve, reject;
  const promise = new Promise((res, rej) => {
    resolve = res;
    reject = rej;
  });
  return { promise, resolve, reject };
}

test('handles race condition correctly', async () => {
  const { promise: p1, resolve: r1 } = createControllablePromise();
  const { promise: p2, resolve: r2 } = createControllablePromise();
  
  const result = Promise.race([p1, p2]);
  
  r2('second'); // Control which resolves first
  r1('first');
  
  expect(await result).toBe('second');
});
```

This pattern eliminates timing non-determinism by manually controlling resolution order.

---

