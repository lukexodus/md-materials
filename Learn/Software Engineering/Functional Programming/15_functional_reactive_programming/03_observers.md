## Observers


Observers represent the consumption side of reactive streams, defining how to react to emitted values, errors, and completion signals from Observables. They encapsulate the three notification handlers that process stream events.

**Observer Interface:**

An Observer consists of three optional callback functions:

**next** - Handles each value emitted by the Observable. This function executes for every successful emission, receiving the value as its parameter. The implementation determines how to process, display, or store the received data.

**error** - Handles error notifications from the Observable. When invoked, the stream terminates and no further notifications occur. Error handlers should implement recovery logic, user notification, or fallback behavior appropriate to the application context.

**complete** - Handles successful completion of the Observable. Signals that no more values will be emitted. Useful for cleanup operations, UI updates, or triggering dependent operations that should wait for stream completion.

**Observer Creation:**

Observers can be created in multiple forms:

**Full Observer Object:**

```
const observer = {
    next: value => console.log(value),
    error: err => console.error(err),
    complete: () => console.log('Done')
}
observable.subscribe(observer)
```

**Partial Observers** - Any subset of the three methods can be provided:

```
observable.subscribe({
    next: value => process(value),
    error: err => handleError(err)
})
```

**Function Arguments** - Pass handlers as separate function parameters:

```
observable.subscribe(
    value => console.log(value),
    err => console.error(err),
    () => console.log('Complete')
)
```

**Execution Context:**

Observers execute synchronously within the Observable's emission context unless schedulers intervene. When an Observable calls `observer.next(value)`, the next handler runs immediately before control returns to the Observable. This synchronous execution model provides predictable behavior but requires careful consideration:

Side effects in observers execute immediately during emission. Long-running observers block the Observable from emitting subsequent values. Synchronous exceptions in observer callbacks propagate to the Observable's error handling mechanism.

**Observer Safety:**

Properly implemented Observables enforce safety guarantees for observers:

**No Concurrent Calls** - An Observable must never invoke observer methods concurrently. All calls must be serialized, maintaining happens-before relationships.

**Terminal State Enforcement** - After `error` or `complete` is called, no further notifications occur. The Observable must prevent subsequent `next`, `error`, or `complete` calls.

**Single Terminal Notification** - An Observable calls either `error` or `complete` exactly once, never both.

These guarantees allow observers to maintain internal state without synchronization primitives, simplifying implementation.

**Observer State Management:**

Observers often maintain state across emissions to implement stateful processing:

**Accumulation** - Building up results over multiple emissions:

```
let sum = 0
const observer = {
    next: value => sum += value,
    complete: () => console.log(`Total: ${sum}`)
}
```

**Conditional Processing** - Altering behavior based on previous emissions:

```
let previousValue = null
const observer = {
    next: value => {
        if (previousValue !== null) {
            const delta = value - previousValue
            process(delta)
        }
        previousValue = value
    }
}
```

**Resource Management:**

Observers frequently need to manage resources that outlive individual emissions:

**Cleanup on Completion:**

```
const observer = {
    next: data => buffer.add(data),
    error: err => buffer.close(),
    complete: () => {
        buffer.flush()
        buffer.close()
    }
}
```

**Subscription Handling** - Observers receive a Subscription object when subscribing, enabling manual cleanup:

```
const subscription = observable.subscribe({
    next: value => {
        if (shouldStop(value)) {
            subscription.unsubscribe()
        }
    }
})
```

**Observer Chaining:**

Observers can be composed to create processing pipelines without modifying the source Observable:

```
const loggingObserver = {
    next: value => {
        console.log('Received:', value)
        actualObserver.next(value)
    },
    error: err => {
        console.error('Error:', err)
        actualObserver.error(err)
    },
    complete: () => {
        console.log('Completed')
        actualObserver.complete()
    }
}
```

This pattern enables cross-cutting concerns like logging, metrics, or validation without polluting domain logic.

**Error Recovery in Observers:**

Observer error handlers must decide how to respond to stream failures:

**Graceful Degradation** - Display cached data or default values when fresh data fails to load.

**User Notification** - Inform users of the error condition with appropriate messaging and recovery options.

**Retry Triggers** - Signal retry mechanisms or alternative data sources to attempt recovery.

**State Cleanup** - Reset UI state or clear invalid data resulting from the failed operation.

**Synchronous vs Asynchronous Observers:**

While observer callbacks execute synchronously by default, they can initiate asynchronous operations:

**Synchronous:**

```
{
    next: value => {
        const result = transform(value)
        display(result)
    }
}
```

**Asynchronous:**

```
{
    next: value => {
        saveToDatabase(value)
            .then(() => updateUI())
            .catch(err => handleError(err))
    }
}
```

[Inference] Asynchronous observers introduce complexity - the Observable continues emitting while the async operation executes, potentially creating ordering issues or resource contention. [Inference] Backpressure mechanisms or buffering strategies may be necessary to coordinate asynchronous observer processing with Observable emissions.

**Testing Observers:**

Test observers capture emissions for verification:

```
const testObserver = {
    values: [],
    errors: [],
    completed: false,
    next: value => testObserver.values.push(value),
    error: err => testObserver.errors.push(err),
    complete: () => testObserver.completed = true
}

observable.subscribe(testObserver)

// Assertions
assert(testObserver.values.length === 3)
assert(testObserver.completed === true)
```

**Observer Performance Considerations:**

Observer implementation directly impacts stream performance:

Minimize work in `next` handlers to maintain throughput. Heavy processing blocks the Observable from emitting subsequent values. [Inference] Consider offloading intensive operations to separate schedulers or worker threads.

Avoid throwing exceptions in observer callbacks. Exceptions terminate the stream and may leave resources in inconsistent states. Handle errors explicitly within the callback or return error signals.

[Inference] Be cautious with shared mutable state across multiple observers subscribing to the same Observable. Without coordination, race conditions may occur if the Observable emits on multiple threads.

