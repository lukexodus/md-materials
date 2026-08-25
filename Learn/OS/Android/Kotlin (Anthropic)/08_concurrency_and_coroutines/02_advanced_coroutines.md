## Advanced Coroutines


### Channels for Communication

Channels in Kotlin provide a way for coroutines to communicate with each other by sending and receiving values. They act as a bridge between coroutines, enabling safe data transfer without shared mutable state.

#### Channel Types and Capacity

Channels come in different types based on their capacity and behavior. The `Channel()` function creates a rendezvous channel by default, which has zero capacity and requires both sender and receiver to be ready simultaneously. You can specify capacity using `Channel(capacity)` where capacity can be a specific number, `Channel.UNLIMITED` for unlimited buffering, or `Channel.CONFLATED` where new values replace old ones.

```kotlin
val channel = Channel<Int>()
val bufferedChannel = Channel<Int>(10)
val unlimitedChannel = Channel<Int>(Channel.UNLIMITED)
val conflatedChannel = Channel<Int>(Channel.CONFLATED)
```

#### Sending and Receiving

The `send()` function is a suspending function that sends values to the channel, while `receive()` suspends until a value is available. For non-blocking operations, use `trySend()` and `tryReceive()` which return immediately with a result indicating success or failure.

```kotlin
launch {
    channel.send(42)
    channel.close()
}

launch {
    for (value in channel) {
        println(value)
    }
}
```

#### Channel Closing and Completion

Channels should be closed when no more elements will be sent using `close()`. This allows receivers to know when to stop waiting for new values. The `isClosedForSend` and `isClosedForReceive` properties help determine channel state.

#### Producer and Actor Patterns

The producer builder creates a channel and launches a coroutine that sends values to it, returning a `ReceiveChannel`. The actor pattern processes incoming messages sequentially, providing a safe way to handle mutable state.

```kotlin
fun produceNumbers() = produce<Int> {
    var x = 1
    while (true) send(x++)
}

fun counterActor() = actor<CounterMsg> {
    var counter = 0
    for (msg in channel) {
        when (msg) {
            is IncCounter -> counter++
            is GetCounter -> msg.response.complete(counter)
        }
    }
}
```

### Flow for Reactive Programming

Flow is Kotlin's reactive stream implementation that represents a cold asynchronous data stream. Unlike channels, flows are cold streams that don't produce values until collected.

#### Flow Builders

The `flow` builder is the most fundamental way to create flows. It takes a suspending lambda that can emit values using the `emit()` function. Other builders include `flowOf()` for static values and `asFlow()` for converting collections.

```kotlin
val flow = flow {
    for (i in 1..5) {
        delay(100)
        emit(i)
    }
}

val staticFlow = flowOf(1, 2, 3, 4, 5)
val collectionFlow = listOf(1, 2, 3).asFlow()
```

#### Flow Operators

Flow provides numerous operators for transforming, filtering, and combining streams. The `map` operator transforms each emitted value, `filter` removes values based on a predicate, and `take` limits the number of emitted values.

```kotlin
flow.map { it * 2 }
    .filter { it > 5 }
    .take(3)
    .collect { println(it) }
```

Combining operators like `zip`, `combine`, and `merge` allow working with multiple flows. `zip` pairs values from two flows, `combine` emits whenever any flow emits, and `merge` flattens multiple flows into one.

#### Flow Context and Threading

Flows preserve context by default, meaning they execute in the same coroutine context where they're collected. The `flowOn` operator changes the context for upstream operations, while `launchIn` collects the flow in a specific scope.

```kotlin
flow {
    emit(Thread.currentThread().name)
}
.flowOn(Dispatchers.IO)
.collect { println(it) }
```

#### State Management with StateFlow and SharedFlow

`StateFlow` represents a state-holding observable flow that emits current and new state updates. It's hot, meaning it's always active and retains the latest value. `SharedFlow` is a hot flow that can replay a specified number of values to new subscribers.

```kotlin
class ViewModel {
    private val _state = MutableStateFlow(initialState)
    val state: StateFlow<State> = _state.asStateFlow()
    
    private val _events = MutableSharedFlow<Event>()
    val events: SharedFlow<Event> = _events.asSharedFlow()
}
```

#### Flow Exception Handling

Flow exceptions can be handled using the `catch` operator, which catches upstream exceptions and can emit replacement values. The `onEach` operator allows side effects without transforming values, useful for logging or debugging.

```kotlin
flow {
    emit(1)
    throw RuntimeException("Error")
}
.catch { e -> emit(-1) }
.collect { println(it) }
```

### Exception Handling in Coroutines

Exception handling in coroutines follows structured concurrency principles, where exceptions propagate through the coroutine hierarchy and can cancel parent and sibling coroutines.

#### Exception Propagation

Unhandled exceptions in coroutines propagate to their parent, potentially canceling the entire coroutine scope. This behavior ensures that failures don't go unnoticed and provides a clean failure model.

```kotlin
val scope = CoroutineScope(SupervisorJob())
scope.launch {
    launch {
        throw RuntimeException("Child failed")
    }
    delay(1000)
    println("This won't execute")
}
```

#### SupervisorJob and supervisorScope

`SupervisorJob` prevents child failures from canceling siblings, making it useful for scenarios where independent operations should continue even if others fail. The `supervisorScope` function creates a scope with supervisor behavior.

```kotlin
supervisorScope {
    launch {
        throw RuntimeException("This fails")
    }
    launch {
        delay(1000)
        println("This still executes")
    }
}
```

#### CoroutineExceptionHandler

`CoroutineExceptionHandler` provides a last-resort mechanism for handling uncaught exceptions. It only handles exceptions that would otherwise terminate the application and should be used sparingly.

```kotlin
val handler = CoroutineExceptionHandler { _, exception ->
    println("Caught $exception")
}

val scope = CoroutineScope(Job() + handler)
scope.launch {
    throw RuntimeException("Handled by exception handler")
}
```

#### Try-Catch in Coroutines

Regular try-catch blocks work within coroutine builders, but they only catch exceptions from the immediate suspending function, not from child coroutines. Use `runCatching` for functional exception handling.

```kotlin
try {
    val result = withContext(Dispatchers.IO) {
        // Suspending operation
        riskyOperation()
    }
} catch (e: Exception) {
    // Handle exception
}

val result = runCatching {
    riskyOperation()
}.getOrElse { defaultValue }
```

### Coroutine Cancellation and Timeouts

Coroutine cancellation is cooperative, meaning coroutines must check for cancellation and respond appropriately. This mechanism ensures resource cleanup and prevents runaway coroutines.

#### Cancellation Basics

Coroutines can be cancelled using the `cancel()` method on their job. Cancellation is immediate for suspending functions that check for cancellation, but compute-intensive code needs explicit cancellation checks.

```kotlin
val job = launch {
    repeat(1000) { i ->
        if (!isActive) return@launch
        // or ensureActive()
        println("Working $i")
        delay(100)
    }
}

delay(500)
job.cancel()
```

#### Cancellation Exceptions

When a coroutine is cancelled, it receives a `CancellationException`. This exception should generally not be caught or suppressed, as it's part of the normal cancellation mechanism.

```kotlin
launch {
    try {
        delay(1000)
    } catch (e: CancellationException) {
        println("Cancelled")
        throw e // Re-throw to complete cancellation
    }
}
```

#### Resource Cleanup

Use `try-finally` blocks or `use` function for resource cleanup in cancellable coroutines. The `finally` block executes even when the coroutine is cancelled, ensuring proper resource management.

```kotlin
launch {
    try {
        // Work with resources
        val resource = acquireResource()
        doWork(resource)
    } finally {
        // Cleanup always executes
        releaseResource()
    }
}
```

#### Timeouts

The `withTimeout` function automatically cancels the coroutine if it doesn't complete within the specified time. `withTimeoutOrNull` returns null instead of throwing an exception on timeout.

```kotlin
try {
    withTimeout(5000) {
        longRunningOperation()
    }
} catch (e: TimeoutCancellationException) {
    println("Operation timed out")
}

val result = withTimeoutOrNull(5000) {
    longRunningOperation()
} ?: "Default value"
```

#### Non-Cancellable Operations

Sometimes operations need to complete even during cancellation, such as cleanup code. Use `NonCancellable` context for such operations, but use it sparingly as it can prevent proper cancellation.

```kotlin
launch {
    try {
        cancellableWork()
    } finally {
        withContext(NonCancellable) {
            criticalCleanup()
        }
    }
}
```

**Key points**: Channels enable safe communication between coroutines with various capacity options and patterns. Flow provides reactive programming capabilities with extensive operators and context management. Exception handling follows structured concurrency with propagation and supervisor patterns. Cancellation is cooperative and requires explicit checks in compute-intensive code, with proper resource cleanup mechanisms.

---

