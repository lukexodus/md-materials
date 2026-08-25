## Coroutines Basics


### Understanding Suspending Functions

Suspending functions are the foundation of Kotlin coroutines, allowing functions to pause execution without blocking the underlying thread. They can only be called from within a coroutine or another suspending function, marked with the `suspend` keyword.

```kotlin
suspend fun fetchUserData(userId: String): User {
    delay(1000) // Simulates network delay without blocking thread
    return userRepository.findById(userId)
}

suspend fun processData(): String {
    val data = fetchRemoteData() // Another suspending function
    return processResult(data)
}
```

When a suspending function encounters a suspension point (like `delay`), it pauses execution and releases the thread for other work. The coroutine runtime handles resuming execution when the suspension completes.

#### Suspension Points and Continuations

```kotlin
suspend fun demonstrateSuspension() {
    println("Before delay") // Executes immediately
    delay(1000) // Suspension point - thread is released
    println("After delay") // Resumes after delay
}

// Compiler transforms suspending functions using continuations
// Simplified representation:
fun demonstrateSuspension(continuation: Continuation<Unit>): Any? {
    // State machine implementation
    when (continuation.label) {
        0 -> {
            println("Before delay")
            return delay(1000, continuation)
        }
        1 -> {
            println("After delay")
            return Unit
        }
    }
}
```

#### Calling Suspending Functions

```kotlin
class UserService {
    // Suspending function can call other suspending functions
    suspend fun getUser(id: String): User {
        return withContext(Dispatchers.IO) {
            userRepository.findById(id)
        }
    }
    
    // Regular function cannot call suspending functions directly
    fun getUserSync(id: String): User {
        // This would cause compilation error:
        // return getUser(id)
        
        // Must use coroutine builder:
        return runBlocking {
            getUser(id)
        }
    }
}
```

### Coroutine Builders

Coroutine builders are functions that create and start coroutines. Each builder serves different purposes and has distinct characteristics.

#### Launch Builder

The `launch` builder creates a coroutine that runs concurrently with other code. It returns a `Job` object that can be used to control the coroutine's lifecycle.

```kotlin
import kotlinx.coroutines.*

fun main() {
    val job = GlobalScope.launch {
        repeat(5) { i ->
            println("Coroutine iteration $i")
            delay(500)
        }
    }
    
    // Main thread continues executing
    println("Main thread continues")
    
    // Wait for coroutine to complete
    runBlocking {
        job.join()
    }
}
```

#### Launch with Exception Handling

```kotlin
fun demonstrateLaunchExceptions() = runBlocking {
    val job = launch {
        try {
            delay(1000)
            throw RuntimeException("Something went wrong")
        } catch (e: Exception) {
            println("Caught in coroutine: ${e.message}")
        }
    }
    
    job.join()
    println("Main coroutine completed")
}
```

#### Async Builder

The `async` builder creates a coroutine that computes a value concurrently. It returns a `Deferred` object that can be awaited to get the result.

```kotlin
suspend fun fetchUserAsync(userId: String): Deferred<User> {
    return GlobalScope.async {
        delay(1000) // Simulate network call
        User(userId, "John Doe")
    }
}

fun demonstrateAsync() = runBlocking {
    val userDeferred = async { fetchUser("123") }
    val profileDeferred = async { fetchProfile("123") }
    
    // Both operations run concurrently
    val user = userDeferred.await()
    val profile = profileDeferred.await()
    
    println("User: $user, Profile: $profile")
}
```

#### Async vs Launch Comparison

```kotlin
fun compareAsyncAndLaunch() = runBlocking {
    // Using async for concurrent operations with results
    val time1 = measureTimeMillis {
        val deferred1 = async { computeValue(1) }
        val deferred2 = async { computeValue(2) }
        val result = deferred1.await() + deferred2.await()
        println("Async result: $result")
    }
    
    // Using launch for fire-and-forget operations
    val time2 = measureTimeMillis {
        val job1 = launch { performTask(1) }
        val job2 = launch { performTask(2) }
        joinAll(job1, job2)
    }
    
    println("Async time: $time1ms, Launch time: $time2ms")
}

suspend fun computeValue(n: Int): Int {
    delay(1000)
    return n * n
}
```

#### RunBlocking Builder

The `runBlocking` builder creates a coroutine that blocks the current thread until completion. It's primarily used for bridging between blocking and non-blocking code.

```kotlin
fun main() {
    // Blocks main thread until coroutine completes
    runBlocking {
        delay(1000)
        println("World!")
    }
    println("Hello,") // This executes after the coroutine
}

// Common use case: Testing
class UserServiceTest {
    @Test
    fun testUserCreation() = runBlocking {
        val user = userService.createUser("testUser")
        assertEquals("testUser", user.name)
    }
}
```

### Coroutine Scope and Context

Coroutine scope defines the lifecycle and cancellation behavior of coroutines, while context provides configuration information like dispatcher and exception handling.

#### Coroutine Scope

```kotlin
class UserViewModel : ViewModel() {
    // ViewModelScope automatically cancels when ViewModel is cleared
    private val viewModelScope = CoroutineScope(
        SupervisorJob() + Dispatchers.Main.immediate
    )
    
    fun loadUser(userId: String) {
        viewModelScope.launch {
            try {
                val user = userRepository.getUser(userId)
                updateUI(user)
            } catch (e: Exception) {
                showError(e)
            }
        }
    }
    
    override fun onCleared() {
        super.onCleared()
        viewModelScope.cancel()
    }
}
```

#### Custom Scope Creation

```kotlin
class BackgroundTaskManager {
    private val scope = CoroutineScope(
        SupervisorJob() + 
        Dispatchers.IO + 
        CoroutineName("BackgroundTasks")
    )
    
    fun scheduleTask(task: suspend () -> Unit) {
        scope.launch {
            try {
                task()
            } catch (e: Exception) {
                handleTaskError(e)
            }
        }
    }
    
    fun shutdown() {
        scope.cancel()
    }
}
```

#### Coroutine Context

The coroutine context is a set of elements that define the coroutine's behavior, including dispatcher, job, exception handler, and debug information.

```kotlin
fun demonstrateContext() = runBlocking {
    val context = Job() + Dispatchers.IO + CoroutineName("MyCoroutine")
    
    launch(context) {
        println("Coroutine name: ${coroutineContext[CoroutineName]}")
        println("Dispatcher: ${coroutineContext[ContinuationInterceptor]}")
        println("Job: ${coroutineContext[Job]}")
    }
}
```

#### Context Inheritance and Modification

```kotlin
fun demonstrateContextInheritance() = runBlocking {
    println("Main context: ${coroutineContext[CoroutineName]}")
    
    launch(CoroutineName("Child")) {
        println("Child context: ${coroutineContext[CoroutineName]}")
        
        // Inherits parent context but overrides specific elements
        launch(Dispatchers.IO) {
            println("Grandchild context: ${coroutineContext[CoroutineName]}")
            println("Grandchild dispatcher: ${coroutineContext[ContinuationInterceptor]}")
        }
    }
}
```

### Structured Concurrency Principles

Structured concurrency ensures that coroutines are properly managed, preventing resource leaks and ensuring predictable cancellation behavior.

#### Parent-Child Relationships

```kotlin
fun demonstrateStructuredConcurrency() = runBlocking {
    val parentJob = launch {
        println("Parent started")
        
        val child1 = launch {
            delay(1000)
            println("Child 1 completed")
        }
        
        val child2 = launch {
            delay(2000)
            println("Child 2 completed")
        }
        
        // Parent waits for all children
        println("Parent waiting for children")
    }
    
    // If parent is cancelled, all children are cancelled
    delay(1500)
    parentJob.cancel()
    println("Parent cancelled")
}
```

#### Cancellation Propagation

```kotlin
fun demonstrateCancellationPropagation() = runBlocking {
    val parentJob = launch {
        try {
            launch {
                delay(1000)
                println("Child 1 completed")
            }
            
            launch {
                delay(2000)
                println("Child 2 completed")
            }
            
            delay(3000)
            println("Parent completed")
        } finally {
            println("Parent cleanup")
        }
    }
    
    delay(1500)
    parentJob.cancel("Manual cancellation")
    parentJob.join()
}
```

#### Exception Handling in Structured Concurrency

```kotlin
fun demonstrateExceptionHandling() = runBlocking {
    val handler = CoroutineExceptionHandler { _, exception ->
        println("Caught exception: ${exception.message}")
    }
    
    val scope = CoroutineScope(SupervisorJob() + handler)
    
    scope.launch {
        launch {
            delay(1000)
            throw RuntimeException("Child 1 failed")
        }
        
        launch {
            delay(2000)
            println("Child 2 completed successfully")
        }
    }
    
    delay(3000)
    scope.cancel()
}
```

#### Supervisor Job vs Regular Job

```kotlin
fun compareSupervisorJob() = runBlocking {
    println("=== Regular Job ===")
    val regularJob = launch {
        launch {
            delay(1000)
            throw RuntimeException("Child failed")
        }
        
        launch {
            delay(2000)
            println("This won't execute - parent cancelled")
        }
    }
    
    regularJob.join()
    
    println("\n=== Supervisor Job ===")
    val supervisorScope = CoroutineScope(SupervisorJob())
    
    supervisorScope.launch {
        launch {
            delay(1000)
            throw RuntimeException("Child failed")
        }
        
        launch {
            delay(2000)
            println("This will execute - supervisor isolates failures")
        }
    }
    
    delay(3000)
    supervisorScope.cancel()
}
```

### Practical Examples

#### Concurrent API Calls

```kotlin
class DataService {
    suspend fun fetchUserProfile(userId: String): UserProfile {
        return coroutineScope {
            val userDeferred = async { userApi.getUser(userId) }
            val preferencesDeferred = async { preferencesApi.getPreferences(userId) }
            val activityDeferred = async { activityApi.getRecentActivity(userId) }
            
            UserProfile(
                user = userDeferred.await(),
                preferences = preferencesDeferred.await(),
                recentActivity = activityDeferred.await()
            )
        }
    }
}
```

#### Timeout Handling

```kotlin
suspend fun fetchWithTimeout(url: String): String {
    return withTimeout(5000) {
        httpClient.get(url)
    }
}

suspend fun fetchWithTimeoutOrNull(url: String): String? {
    return withTimeoutOrNull(5000) {
        httpClient.get(url)
    }
}
```

#### Resource Management

```kotlin
class DatabaseService {
    private val scope = CoroutineScope(
        SupervisorJob() + 
        Dispatchers.IO + 
        CoroutineName("DatabaseService")
    )
    
    fun startPeriodicCleanup() {
        scope.launch {
            while (isActive) {
                try {
                    performCleanup()
                    delay(TimeUnit.HOURS.toMillis(1))
                } catch (e: Exception) {
                    logger.error("Cleanup failed", e)
                    delay(TimeUnit.MINUTES.toMillis(5)) // Retry after delay
                }
            }
        }
    }
    
    fun close() {
        scope.cancel()
    }
}
```

**Key points:**

- Suspending functions can pause execution without blocking threads
- Launch is for fire-and-forget operations, async is for concurrent computations
- RunBlocking bridges blocking and non-blocking code
- Coroutine scope manages lifecycle and cancellation
- Structured concurrency prevents resource leaks and ensures predictable behavior

**Example** of comprehensive coroutine usage:

```kotlin
class ImageProcessor {
    private val scope = CoroutineScope(SupervisorJob() + Dispatchers.Default)
    
    suspend fun processImages(imageUrls: List<String>): List<ProcessedImage> {
        return coroutineScope {
            imageUrls.map { url ->
                async {
                    try {
                        val image = downloadImage(url)
                        processImage(image)
                    } catch (e: Exception) {
                        logger.error("Failed to process image: $url", e)
                        null
                    }
                }
            }.awaitAll().filterNotNull()
        }
    }
    
    private suspend fun downloadImage(url: String): ByteArray {
        return withContext(Dispatchers.IO) {
            httpClient.get(url)
        }
    }
    
    private suspend fun processImage(imageData: ByteArray): ProcessedImage {
        return withContext(Dispatchers.Default) {
            // CPU-intensive image processing
            ImageUtils.process(imageData)
        }
    }
    
    fun shutdown() {
        scope.cancel()
    }
}
```

**Conclusion**

Coroutines basics provide the foundation for asynchronous programming in Kotlin. Understanding suspending functions, coroutine builders, scope management, and structured concurrency principles is essential for writing efficient, maintainable concurrent code. The key is to use the appropriate builder for each use case and ensure proper scope management to prevent resource leaks.

---

