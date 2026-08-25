## Observables


Observables represent asynchronous data streams that can emit zero or more values over time, optionally completing successfully or with an error. They embody the observer pattern in a functional reactive context, providing a unified abstraction for handling events, asynchronous operations, and data sequences.

**Observable Contract:**

An Observable maintains a contract with its observers through three types of notifications:

- **onNext** - Emits a new value to all subscribed observers
- **onError** - Signals an error condition, terminating the stream
- **onComplete** - Indicates successful completion with no more values

Once an Observable emits `onError` or `onComplete`, it terminates and emits no further values. This guarantees a clear lifecycle for stream processing.

**Creation Patterns:**

Observables can be constructed from various sources:

**From Values** - Direct emission of predetermined values:

```
Observable.just(1, 2, 3)
Observable.of("a", "b", "c")
```

**From Collections** - Converting existing data structures:

```
Observable.from([1, 2, 3, 4, 5])
Observable.fromIterable(list)
```

**From Events** - Wrapping event sources:

```
Observable.fromEvent(button, 'click')
Observable.fromPromise(asyncOperation)
```

**Custom Creation** - Using create operators for full control:

```
Observable.create(observer => {
    observer.onNext(value)
    observer.onComplete()
    return () => cleanup()
})
```

**Hot vs Cold Observables:**

Observables exhibit two distinct behavioral patterns regarding when they begin emitting values:

**Cold Observables** produce values only when subscribed to, with each subscription receiving its own independent execution. HTTP requests, database queries, and file reads typically manifest as cold Observables. Each subscriber triggers a new execution of the underlying data source.

**Hot Observables** produce values regardless of subscriptions, with subscribers receiving only values emitted after their subscription. Mouse movements, WebSocket connections, and shared timers exemplify hot Observables. Multiple subscribers share the same execution and receive the same values.

Converting between hot and cold uses sharing operators:

- `share()` - Multicasts cold Observable to multiple subscribers
- `publish()` - Converts to ConnectableObservable requiring manual connection
- `replay(n)` - Buffers n values for late subscribers

**Operator Composition:**

Observables gain power through composable operators that transform, filter, combine, and control streams:

**Transformation Operators:**

`map` - Transforms each emitted value through a projection function, creating a one-to-one mapping between input and output values.

`flatMap` - Projects each value to an Observable, then flattens the resulting Observables into a single stream. Critical for handling nested asynchronous operations. Does not preserve order if inner Observables complete at different times.

`concatMap` - Similar to flatMap but maintains strict ordering by waiting for each inner Observable to complete before subscribing to the next. Introduces potential latency but guarantees sequence preservation.

`switchMap` - Projects to inner Observables but cancels the previous inner Observable when a new value arrives. Useful for scenarios like search-as-you-type where only the latest result matters.

`scan` - Accumulates values over time, emitting each intermediate result. The streaming equivalent of reduce, maintaining running state.

**Filtering Operators:**

`filter` - Emits only values satisfying a predicate function, removing unwanted elements from the stream.

`take(n)` - Emits only the first n values, then completes. Useful for limiting stream length.

`skip(n)` - Ignores the first n values, emitting only subsequent elements.

`distinct` - Filters out duplicate values based on equality comparison or a key selector function.

`debounceTime(ms)` - Emits a value only after a specified time period has passed without another emission. Essential for rate-limiting rapid events like keyboard input.

`throttleTime(ms)` - Emits the first value, then ignores subsequent values for the specified duration. Useful for limiting update frequency.

**Combination Operators:**

`merge` - Combines multiple Observables into one by interleaving their emissions. Subscribes to all sources simultaneously.

`concat` - Sequentially concatenates Observables, subscribing to the next only after the previous completes.

`combineLatest` - When any Observable emits, combines the latest value from each source using a projection function. Requires all sources to have emitted at least once.

`withLatestFrom` - When the source Observable emits, combines with the latest values from other Observables without triggering on their emissions.

`zip` - Combines corresponding emissions from multiple Observables, emitting only when all sources have provided a value for that index. Creates strict pairing.

**Error Handling:**

Observables provide sophisticated error recovery mechanisms:

`catchError` - Intercepts errors and returns a fallback Observable, allowing graceful degradation or retry logic.

`retry(n)` - Resubscribes to the source Observable up to n times when errors occur, useful for transient failures.

`retryWhen` - Provides fine-grained control over retry logic, accepting a function that receives the error Observable and returns an Observable controlling retry timing.

**Scheduling and Concurrency:**

Observables decouple the definition of work from its execution context through schedulers:

`observeOn(scheduler)` - Controls which scheduler processes downstream operators and subscriber notifications. Commonly used to move processing off event threads.

`subscribeOn(scheduler)` - Controls which scheduler executes the Observable's subscription logic and upstream operators. Typically set once near the source.

Common scheduler types include:

- Immediate/synchronous schedulers for testing
- Event loop schedulers for UI frameworks
- Thread pool schedulers for concurrent operations
- Virtual time schedulers for time-based testing

**Subscription Management:**

Subscriptions to Observables return Subscription objects that enable cleanup and resource management:

```
const subscription = observable.subscribe(observer)
subscription.unsubscribe()
```

Unsubscribing signals that the observer no longer needs values, allowing the Observable to release resources, cancel network requests, or stop timers. Proper subscription management prevents memory leaks and resource exhaustion.

**Multicasting:**

By default, each subscription to a cold Observable creates an independent execution. Multicasting shares a single execution among multiple subscribers through subjects:

`multicast(subject)` - Connects the Observable through a subject, requiring manual `connect()` to begin.

`refCount()` - Automatically manages connection lifecycle based on subscriber count, connecting when the first subscriber arrives and disconnecting when the last leaves.

