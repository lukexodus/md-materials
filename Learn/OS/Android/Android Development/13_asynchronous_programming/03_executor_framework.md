## Executor Framework


The Executor framework provides a more flexible and efficient way to manage background threads, replacing AsyncTask for many use cases.

**Key Points:**

- Better thread pool management
- More control over execution policies
- Supports various thread pool types
- Integrates well with modern Android architectures
- Can be combined with CompletableFuture for advanced scenarios

**Basic Executor Usage:**

```kotlin
class ExecutorExample {
    
    // Different types of executors
    private val singleThreadExecutor = Executors.newSingleThreadExecutor()
    private val fixedThreadPool = Executors.newFixedThreadPool(4)
    private val cachedThreadPool = Executors.newCachedThreadPool()
    private val scheduledExecutor = Executors.newScheduledThreadPool(2)
    
    // Main thread handler for UI updates
    private val mainHandler = Handler(Looper.getMainLooper())
    
    fun performBackgroundTask() {
        singleThreadExecutor.execute {
            // Background work
            val result = performComputation()
            
            // Update UI on main thread
            mainHandler.post {
                updateUI(result)
            }
        }
    }
    
    fun performMultipleParallelTasks() {
        val tasks = listOf("Task1", "Task2", "Task3", "Task4")
        
        tasks.forEach { task ->
            fixedThreadPool.submit {
                processTask(task)
            }
        }
    }
    
    fun performScheduledTask() {
        // Execute after delay
        scheduledExecutor.schedule({
            performPeriodicWork()
        }, 5, TimeUnit.SECONDS)
        
        // Execute periodically
        scheduledExecutor.scheduleAtFixedRate({
            performPeriodicWork()
        }, 0, 30, TimeUnit.SECONDS)
    }
    
    private fun performComputation(): String = "Computed result"
    private fun processTask(task: String) { /* Process task */ }
    private fun performPeriodicWork() { /* Periodic work */ }
    private fun updateUI(result: String) { /* Update UI */ }
    
    fun cleanup() {
        singleThreadExecutor.shutdown()
        fixedThreadPool.shutdown()
        cachedThreadPool.shutdown()
        scheduledExecutor.shutdown()
    }
}

// Custom ExecutorService with proper lifecycle management
class ManagedExecutorService {
    private val executor = ThreadPoolExecutor(
        2, // Core pool size
        4, // Maximum pool size
        60L, TimeUnit.SECONDS, // Keep alive time
        LinkedBlockingQueue<Runnable>(), // Work queue
        ThreadFactory { runnable ->
            Thread(runnable, "CustomWorker").apply {
                isDaemon = true
            }
        }
    )
    
    fun <T> submitTask(
        backgroundWork: () -> T,
        onResult: (T) -> Unit,
        onError: (Exception) -> Unit = {}
    ) {
        val mainHandler = Handler(Looper.getMainLooper())
        
        executor.submit {
            try {
                val result = backgroundWork()
                mainHandler.post { onResult(result) }
            } catch (e: Exception) {
                mainHandler.post { onError(e) }
            }
        }
    }
    
    fun shutdown() {
        executor.shutdown()
        try {
            if (!executor.awaitTermination(60, TimeUnit.SECONDS)) {
                executor.shutdownNow()
            }
        } catch (e: InterruptedException) {
            executor.shutdownNow()
        }
    }
}

// Usage in Activity/Fragment
class ExecutorActivity : AppCompatActivity() {
    
    private val managedExecutor = ManagedExecutorService()
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        performAsyncOperation()
    }
    
    private fun performAsyncOperation() {
        managedExecutor.submitTask(
            backgroundWork = {
                // This runs on background thread
                Thread.sleep(2000)
                fetchDataFromServer()
            },
            onResult = { data ->
                // This runs on main thread
                updateUI(data)
            },
            onError = { error ->
                // This runs on main thread
                showError(error.message)
            }
        )
    }
    
    private fun fetchDataFromServer(): String = "Server data"
    private fun updateUI(data: String) { /* Update UI */ }
    private fun showError(message: String?) { /* Show error */ }
    
    override fun onDestroy() {
        super.onDestroy()
        managedExecutor.shutdown()
    }
}
```

**CompletableFuture Integration:**

```kotlin
class CompletableFutureExample {
    
    private val executor = Executors.newFixedThreadPool(4)
    private val mainHandler = Handler(Looper.getMainLooper())
    
    fun performChainedOperations() {
        CompletableFuture
            .supplyAsync({ fetchUserData() }, executor)
            .thenCompose { user -> fetchUserPosts(user.id) }
            .thenCombine(
                CompletableFuture.supplyAsync({ fetchUserProfile(user.id) }, executor)
            ) { posts, profile ->
                UserDashboard(user, posts, profile)
            }
            .whenComplete { dashboard, exception ->
                mainHandler.post {
                    if (exception != null) {
                        handleError(exception)
                    } else {
                        displayDashboard(dashboard)
                    }
                }
            }
    }
    
    private fun fetchUserData(): User = User("1", "John")
    private fun fetchUserPosts(userId: String): CompletableFuture<List<Post>> = 
        CompletableFuture.supplyAsync({ listOf<Post>() }, executor)
    private fun fetchUserProfile(userId: String): UserProfile = UserProfile()
    private fun handleError(exception: Throwable) { /* Handle error */ }
    private fun displayDashboard(dashboard: UserDashboard) { /* Display dashboard */ }
    
    data class User(val id: String, val name: String)
    data class Post(val id: String, val content: String)
    data class UserProfile(val bio: String = "")
    data class UserDashboard(val user: User, val posts: List<Post>, val profile: UserProfile)
}
```

