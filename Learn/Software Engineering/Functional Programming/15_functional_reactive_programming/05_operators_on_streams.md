## Operators on Streams


Operators are pure functions that enable declarative transformation, filtering, combination, and manipulation of observable streams. They take an observable as input and return a new observable, allowing for composable and chainable operations without mutating the source stream.

**Transformation Operators:**

**map** - Transforms each emitted value by applying a projection function. Similar to Array.map but operates on values over time.

**scan** - Applies an accumulator function over the stream, emitting each intermediate result. Equivalent to Array.reduce but emits every accumulated value.

**buffer** - Collects emitted values into arrays based on a closing notifier observable or fixed boundaries.

**switchMap** - Projects each value to an observable and flattens the result, canceling the previous inner observable when a new value arrives. Critical for scenarios like search-as-you-type where only the latest request matters.

**mergeMap (flatMap)** - Projects each value to an observable and merges all inner observables concurrently without cancellation.

**concatMap** - Projects each value to an observable and subscribes to each inner observable sequentially, waiting for completion before moving to the next.

**exhaustMap** - Projects to an observable but ignores new values while the current inner observable is still active.

**Filtering Operators:**

**filter** - Emits only values that satisfy a predicate function.

**take** - Emits only the first n values then completes.

**takeUntil** - Emits values until a notifier observable emits, commonly used for cleanup and unsubscription logic.

**takeWhile** - Emits values while a predicate is true, completes when predicate becomes false.

**skip** - Ignores the first n values.

**debounceTime** - Emits a value only after a specified duration has passed without another emission. Essential for rate-limiting user input.

**throttleTime** - Emits a value then ignores subsequent values for a specified duration.

**distinct** - Emits only values that haven't been emitted before.

**distinctUntilChanged** - Emits only when the current value differs from the previous value.

**Combination Operators:**

**merge** - Combines multiple observables into one by emitting values from all sources concurrently.

**concat** - Subscribes to observables sequentially, waiting for each to complete before subscribing to the next.

**combineLatest** - Emits an array of the latest values from all input observables whenever any observable emits. Requires all observables to have emitted at least once.

**withLatestFrom** - Combines the source observable with the latest values from other observables, but only emits when the source emits.

**zip** - Combines values from multiple observables by index, emitting arrays of corresponding values. Waits for all observables to emit before producing output.

**forkJoin** - Waits for all input observables to complete, then emits an array of their last values. Equivalent to Promise.all for observables.

**Error Handling Operators:**

**catchError** - Intercepts errors and returns a new observable or rethrows. Allows graceful degradation or fallback values.

**retry** - Resubscribes to the source observable a specified number of times on error.

**retryWhen** - Provides fine-grained control over retry logic using a notifier observable.

**Utility Operators:**

**tap (do)** - Performs side effects for each emission without modifying the stream. Used for logging, debugging, or triggering external actions.

**delay** - Time-shifts emissions by a specified duration.

**timeout** - Errors if the observable doesn't emit within a specified timeframe.

**share** - Multicasts the source observable to multiple subscribers, converting cold to hot.

**Example:**

```javascript
source$
  .pipe(
    filter(x => x > 10),
    map(x => x * 2),
    debounceTime(300),
    switchMap(x => apiCall(x)),
    catchError(err => of(defaultValue)),
    takeUntil(destroy$)
  )
  .subscribe(result => console.log(result));
```

