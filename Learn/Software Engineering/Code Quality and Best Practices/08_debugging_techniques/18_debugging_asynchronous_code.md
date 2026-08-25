## Debugging asynchronous code


Debugging asynchronous operations poses unique challenges due to the non-blocking nature of execution, where the call stack typically does not persist across asynchronous boundaries. Effective debugging requires specialized strategies to trace execution flow, identify race conditions, and manage state mutations occurring outside the immediate scope of execution.

**Key Points**

- **Non-Determinism:** Asynchronous code execution order is often non-deterministic, heavily relying on the event loop, network latency, and I/O scheduling. This makes reproducing bugs difficult (heisenbugs).
    
- **Lost Context:** Traditional stack traces often break at the point of the asynchronous call (e.g., `setTimeout`, `Promise.then`), obscuring the origin of the operation.
    
- **Unhandled Rejections:** Errors thrown inside asynchronous callbacks or rejected promises without catch blocks can fail silently or crash the process without meaningful logs.
    
- **Race Conditions:** Occur when the system's behavior depends on the sequence or timing of uncontrollable events, leading to inconsistent state if shared resources are accessed concurrently without synchronization.
    
- **Memory Leaks:** Improperly managed references in closures or event listeners can prevent garbage collection, causing leaks that are hard to trace in long-running async processes.
    

**Strategies and Techniques**

1. Enhanced Logging and Tracing

Standard logging is often insufficient. Structural logging that includes correlation IDs is essential for tracing a request across multiple asynchronous boundaries.

- **Correlation IDs:** Generate a unique ID at the entry point of a transaction and propagate it through every async step.
    
- **Timestamping:** High-resolution timestamps are critical for reconstructing the timeline of events.
    

2. Async/Await Stack Traces

Modern runtime environments (like V8 in Node.js) optimize async/await to provide better stack traces compared to raw Promises.

- **Zero-cost async stack traces:** Ensure the engine supports this feature. It links the asynchronous continuation to the call site, reconstructing the stack as if it were synchronous.
    
- **Avoid mixing patterns:** Sticking strictly to `async/await` rather than mixing it with `.then()` chains generally results in more readable and debuggable stack traces.
    

3. Promise Inspection

When debugging, the state of a Promise (Pending, Fulfilled, Rejected) is opaque.

- **Bluebird/Custom Implementations:** Some libraries offer inspection methods (`.isPending()`, `.value()`).
    
- **`Promise.allSettled`:** Use this instead of `Promise.all` when debugging bulk operations to identify which specific promises failed without short-circuiting the entire batch.
    

4. Detecting Unhandled Rejections

Register global handlers to catch errors that slip through local error handling logic.

- **Node.js:**
    
    JavaScript
    
    ```
    process.on('unhandledRejection', (reason, promise) => {
      console.error('Unhandled Rejection at:', promise, 'reason:', reason);
      // Application specific logging logic here.
    });
    ```
    
- **Browser:**
    
    JavaScript
    
    ```
    window.addEventListener('unhandledrejection', event => {
      console.error('Unhandled rejection (promise: ', event.promise, ', reason: ', event.reason, ').');
    });
    ```
    

**Example**

The following example demonstrates a common race condition where a variable is modified by two concurrent async functions, and how to debug/fix it using a mutex pattern or sequential execution.

_Buggy Code (Race Condition):_

JavaScript

```
let balance = 100;

const delay = (ms) => new Promise(resolve => setTimeout(resolve, ms));

async function withdraw(amount) {
  const currentBalance = balance;
  await delay(100); // Simulate I/O latency
  // By the time this resumes, 'balance' might have changed in another 'thread'
  balance = currentBalance - amount;
}

// Executing concurrently
Promise.all([withdraw(50), withdraw(50)]).then(() => {
  console.log(balance); // Expecting 0, but likely 50 due to stale read
});
```

Debugged/Fixed Code (Sequential):

To debug, logging the balance before and after the await is crucial to seeing the state divergence. To fix, enforce ordering.

JavaScript

```
// ... setup ...

async function atomicWithdraw(amount) {
  // Debug log
  console.log(`[Start] Withdraw ${amount}, Balance: ${balance}`);
  
  // In a real scenario, use a database transaction or a Mutex lock
  // For JS runtime, we can chain them or use a queue
  balance -= amount; 
  
  await delay(100); 
  console.log(`[End] Withdraw ${amount}, Balance: ${balance}`);
}

// Chain execution
(async () => {
    await atomicWithdraw(50);
    await atomicWithdraw(50);
    console.log(balance); // 0
})();
```

**Output**

Running the buggy code typically results in 50.

Running the fixed code results in 0.

**Best Practices for Debugging**

- **Linting Rules:** usage of `eslint-plugin-promise` can catch common errors like forgetting to return a promise or not handling errors.
    
    - `promise/catch-or-return`: Enforces that every promise chain has a `.catch()` clause or is returned.
        
    - `no-async-promise-executor`: Disallows passing an async function to the Promise constructor, which catches errors poorly.
        
- **Time Travel Debugging:** Tools like Replay.io or certain Redux middleware allow you to record execution and step back in time. This is invaluable for async code where reproducing the exact state at the time of failure is difficult.
    
- **Isolate Side Effects:** Keep asynchronous functions pure where possible. If a function only computes data and returns a Promise, it is easier to test and debug than one that modifies global state.
    
- **Timeout Guards:** Wrap async calls in a timeout promise. If an async operation hangs (e.g., a dropped network packet), the timeout ensures the system fails fast and provides a stack trace rather than hanging indefinitely.

---

