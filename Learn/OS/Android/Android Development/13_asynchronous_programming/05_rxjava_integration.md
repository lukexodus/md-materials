## RxJava Integration


[Inference] While coroutines are now the recommended approach, RxJava remains relevant in many existing projects and offers powerful reactive programming capabilities.

**Key Points:**

- Provides reactive streams and operators
- Excellent for complex event handling
- Rich set of transformation operators
- Good for reactive UI programming
- Higher learning curve compared to coroutines

**RxJava Setup and Basic Usage:**

```kotlin
// In build.gradle
dependencies {
    implementation 'io.reactivex.rxjava3:rxjava:3.1.6'
    implementation 'io.reactivex.rxjava3:rxandroid:3.0.2'
    implementation 'com.squareup.retrofit2:adapter-rxjava3:2.9.0'
}

class RxJavaExample {
    
    private val compositeDisposable = CompositeDisposable()
    
    fun basicObservableExample() {
        val observable = Observable.create<String> { emitter ->
            try {
                // Simulate background work
                Thread.sleep(1000)
                emitter.onNext("Data loaded")
                emitter.onComplete()
            } catch (e: Exception) {
                emitter.onError(e)
            }
        }
        
        val disposable = observable
            .subscribeOn(Schedulers.io()) // Background thread
            .observeOn(AndroidSchedulers.mainThread()) // UI thread
            .subscribe(
                { result -> updateUI(result) },
                { error -> handleError(error) },
                { onComplete() }
            )
        
        compositeDisposable.add(disposable)
    }
    
    fun networkRequestWithRx() {
        val disposable = Single.fromCallable {
            // Network operation
            performNetworkRequest()
        }
        .subscribeOn(Schedulers.io())
        .observeOn(AndroidSchedulers.mainThread())
        .subscribe(
            { result -> handleSuccess(result) },
            { error -> handleError(error) }
        )
        
        compositeDisposable.add(disposable)
    }
    
    // Complex operator chain
    fun complexDataProcessing() {
        val disposable = Observable.range(1, 10)
            .filter { it % 2 == 0 } // Only even numbers
            .map { it * 2 } // Double each number
            .flatMap { number ->
                // Convert each number to an observable
                Observable.just(number)
                    .delay(100, TimeUnit.MILLISECONDS)
                    .subscribeOn(Schedulers.computation())
            }
            .toList() // Collect all results
            .observeOn(AndroidSchedulers.mainThread())
            .subscribe { results ->
                displayResults(results)
            }
        
        compositeDisposable.add(disposable)
    }
    
    // Combining multiple sources
    fun combineMultipleSources() {
        val userObservable = Single.fromCallable { fetchUser() }
            .subscribeOn(Schedulers.io())
        
        val postsObservable = Single.fromCallable { fetchPosts() }
            .subscribeOn(Schedulers.io())
        
        val disposable = Single.zip(
            userObservable,
            postsObservable,
            BiFunction<User, List<String>, UserWithPosts> { user, posts ->
                UserWithPosts(user, posts)
            }
        )
        .observeOn(AndroidSchedulers.mainThread())
        .subscribe(
            { userWithPosts -> displayUserWithPosts(userWithPosts) },
            { error -> handleError(error) }
        )
        
        compositeDisposable.add(disposable)
    }
    
    private fun updateUI(result: String) { /* Update UI */ }
    private fun handleError(error: Throwable) { /* Handle error */ }
    private fun onComplete() { /* Handle completion */ }
    private fun handleSuccess(result: String) { /* Handle success */ }
    private fun performNetworkRequest(): String = "Network data"
    private fun displayResults(results: List<Int>) { /* Display results */ }
    private fun fetchUser(): User = User("1", "John")
    private fun fetchPosts(): List<String> = listOf("Post 1", "Post 2")
    private fun displayUserWithPosts(userWithPosts: UserWithPosts) { /* Display */ }
    
    data class UserWithPosts(val user: User, val posts: List<String>)
    
    fun cleanup() {
        compositeDisposable.clear()
    }
}

// RxJava with Repository pattern
class RxRepository {
    private val apiService: RxApiService = createApiService()
    
    fun getUser(id: String): Single<User> {
        return apiService.getUser(id)
            .subscribeOn(Schedulers.io())
            .retry(3) // Retry up to 3 times on failure
            .timeout(10, TimeUnit.SECONDS) // 10 second timeout
    }
    
    fun getUserWithCache(id: String): Observable<User> {
        val cacheSource = Observable.fromCallable { getCachedUser(id) }
            .filter { it != null }
            .cast(User::class.java)
        
        val networkSource = apiService.getUser(id)
            .toObservable()
            .doOnNext { user -> cacheUser(user) }
        
        return Observable.concat(cacheSource, networkSource)
            .subscribeOn(Schedulers.io())
    }
    
    fun searchWithDebounce(searchQuery: Observable<String>): Observable<List<SearchResult>> {
        return searchQuery
            .debounce(300, TimeUnit.MILLISECONDS) // Wait for pause in typing
            .distinctUntilChanged() // Only search if query changed
            .filter { it.length >= 2 } // Minimum query length
            .switchMap { query ->
                apiService.search(query)
                    .toObservable()
                    .onErrorReturn { emptyList() } // Return empty list on error
            }
            .subscribeOn(Schedulers.io())
    }
    
    private fun getCachedUser(id: String): User? = null
    private fun cacheUser(user: User) { /* Cache user */ }
    private fun createApiService(): RxApiService = TODO()
}

interface RxApiService {
    fun getUser(id: String): Single<User>
    fun search(query: String): Single<List<SearchResult>>
}

// RxJava in ViewModel
class RxViewModel : ViewModel() {
    
    private val repository = RxRepository()
    private val compositeDisposable = CompositeDisposable()
    
    private val _uiState = MutableLiveData<UiState>()
    val uiState: LiveData<UiState> = _uiState
    
    fun loadUser(id: String) {
        val disposable = repository.getUser(id)
            .observeOn(AndroidSchedulers.mainThread())
            .doOnSubscribe { _uiState.value = UiState.Loading }
            .subscribe(
                { user -> _uiState.value = UiState.Success(user) },
                { error -> _uiState.value = UiState.Error(error.message ?: "Unknown error") }
            )
        
        compositeDisposable.add(disposable)
    }
    
    fun setupSearch(searchObservable: Observable<String>) {
        val disposable = repository.searchWithDebounce(searchObservable)
            .observeOn(AndroidSchedulers.mainThread())
            .subscribe(
                { results -> handleSearchResults(results) },
                { error -> handleError(error) }
            )
        
        compositeDisposable.add(disposable)
    }
    
    private fun handleSearchResults(results: List<SearchResult>) {
        _uiState.value = UiState.Success(results)
    }
    
    private fun handleError(error: Throwable) {
        _uiState.value = UiState.Error(error.message ?: "Unknown error")
    }
    
    override fun onCleared() {
        super.onCleared()
        compositeDisposable.clear()
    }
}

// RxJava in Activity with proper lifecycle management
class RxActivity : AppCompatActivity() {
    
    private lateinit var binding: ActivityMainBinding
    private lateinit var viewModel: RxViewModel
    private val compositeDisposable = CompositeDisposable()
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityMainBinding.inflate(layoutInflater)
        setContentView(binding.root)
        
        setupSearchObservable()
        observeViewModel()
    }
    
    private fun setupSearchObservable() {
        // Create observable from EditText changes
        val searchObservable = RxTextView.textChanges(binding.searchEditText)
            .skip(1) // Skip initial empty value
            .map { it.toString().trim() }
        
        viewModel.setupSearch(searchObservable)
        
        // Button click observable
        val buttonClickObservable = RxView.clicks(binding.loadButton)
            .throttleFirst(1, TimeUnit.SECONDS) // Prevent rapid clicks
        
        val disposable = buttonClickObservable
            .subscribe { viewModel.loadUser("123") }
        
        compositeDisposable.add(disposable)
    }
    
    private fun observeViewModel() {
        viewModel.uiState.observe(this) { state ->
            when (state) {
                is UiState.Loading -> showLoading()
                is UiState.Success -> showSuccess(state.data)
                is UiState.Error -> showError(state.message)
            }
        }
    }
    
    private fun showLoading() { binding.progressBar.isVisible = true }
    private fun showSuccess(data: Any) { /* Show success */ }
    private fun showError(message: String) { /* Show error */ }
    
    override fun onDestroy() {
        super.onDestroy()
        compositeDisposable.clear()
    }
}

// Advanced RxJava patterns
class AdvancedRxPatterns {
    
    private val compositeDisposable = CompositeDisposable()
    
    // Polling with exponential backoff
    fun pollWithBackoff() {
        val disposable = Observable.interval(0, 1, TimeUnit.SECONDS)
            .flatMap { attempt ->
                performNetworkCall()
                    .toObservable()
                    .retryWhen { errors ->
                        errors.zipWith(
                            Observable.range(1, 5),
                            BiFunction<Throwable, Int, Int> { _, retryCount -> retryCount }
                        ).flatMap { retryCount ->
                            val delay = Math.pow(2.0, retryCount.toDouble()).toLong()
                            Observable.timer(delay, TimeUnit.SECONDS)
                        }
                    }
            }
            .subscribe(
                { result -> handleResult(result) },
                { error -> handleError(error) }
            )
        
        compositeDisposable.add(disposable)
    }
    
    // Circuit breaker pattern
    fun circuitBreakerExample() {
        var failureCount = 0
        val maxFailures = 3
        var circuitOpen = false
        var lastFailureTime = 0L
        val circuitTimeout = 30000L // 30 seconds
        
        val disposable = Observable.interval(5, TimeUnit.SECONDS)
            .flatMap {
                val currentTime = System.currentTimeMillis()
                
                when {
                    !circuitOpen -> {
                        // Circuit closed, normal operation
                        performNetworkCall().toObservable()
                            .doOnError {
                                failureCount++
                                if (failureCount >= maxFailures) {
                                    circuitOpen = true
                                    lastFailureTime = currentTime
                                }
                            }
                            .doOnNext {
                                failureCount = 0 // Reset on success
                            }
                    }
                    currentTime - lastFailureTime > circuitTimeout -> {
                        // Half-open state - try once
                        circuitOpen = false
                        failureCount = 0
                        performNetworkCall().toObservable()
                    }
                    else -> {
                        // Circuit open - fail fast
                        Observable.error(Exception("Circuit breaker is open"))
                    }
                }
            }
            .subscribe(
                { result -> handleResult(result) },
                { error -> handleError(error) }
            )
        
        compositeDisposable.add(disposable)
    }
    
    // Merge multiple data sources with priority
    fun mergeWithPriority() {
        val cacheSource = Single.fromCallable { getCacheData() }
            .subscribeOn(Schedulers.io())
            .delay(100, TimeUnit.MILLISECONDS) // Simulate cache delay
        
        val networkSource = Single.fromCallable { getNetworkData() }
            .subscribeOn(Schedulers.io())
            .delay(1000, TimeUnit.MILLISECONDS) // Simulate network delay
        
        val databaseSource = Single.fromCallable { getDatabaseData() }
            .subscribeOn(Schedulers.io())
            .delay(500, TimeUnit.MILLISECONDS) // Simulate database delay
        
        // Merge with priority: cache first, then database, then network
        val disposable = Single.concat(cacheSource, databaseSource, networkSource)
            .first("No data available")
            .observeOn(AndroidSchedulers.mainThread())
            .subscribe(
                { result -> displayData(result) },
                { error -> handleError(error) }
            )
        
        compositeDisposable.add(disposable)
    }
    
    // Custom operator for common transformations
    fun customOperatorExample() {
        val disposable = Observable.range(1, 10)
            .compose(applyCommonTransformations())
            .subscribe { result -> println(result) }
        
        compositeDisposable.add(disposable)
    }
    
    private fun applyCommonTransformations(): ObservableTransformer<Int, String> {
        return ObservableTransformer { upstream ->
            upstream
                .subscribeOn(Schedulers.computation())
                .filter { it > 5 }
                .map { "Processed: $it" }
                .observeOn(AndroidSchedulers.mainThread())
        }
    }
    
    // Error recovery strategies
    fun errorRecoveryStrategies() {
        val disposable = performRiskyOperation()
            .onErrorResumeNext { error ->
                when (error) {
                    is NetworkException -> getFallbackData()
                    is TimeoutException -> getCachedData()
                    else -> Single.error(error)
                }
            }
            .subscribe(
                { result -> handleSuccess(result) },
                { error -> handleFinalError(error) }
            )
        
        compositeDisposable.add(disposable)
    }
    
    private fun performNetworkCall(): Single<String> = Single.just("Network result")
    private fun handleResult(result: String) { println("Result: $result") }
    private fun handleError(error: Throwable) { println("Error: ${error.message}") }
    private fun getCacheData(): String = "Cache data"
    private fun getNetworkData(): String = "Network data"
    private fun getDatabaseData(): String = "Database data"
    private fun displayData(data: String) { println("Display: $data") }
    private fun performRiskyOperation(): Single<String> = Single.just("Risky result")
    private fun getFallbackData(): Single<String> = Single.just("Fallback data")
    private fun getCachedData(): Single<String> = Single.just("Cached data")
    private fun handleSuccess(result: String) { println("Success: $result") }
    private fun handleFinalError(error: Throwable) { println("Final error: ${error.message}") }
    
    class NetworkException(message: String) : Exception(message)
    class TimeoutException(message: String) : Exception(message)
    
    fun cleanup() {
        compositeDisposable.clear()
    }
}
```

**Comparison of Asynchronous Approaches:**

```kotlin
class AsynchronousComparisonExample {
    
    // Handler approach - Low level, manual thread management
    fun handlerApproach() {
        val backgroundThread = HandlerThread("Worker")
        backgroundThread.start()
        
        val backgroundHandler = Handler(backgroundThread.looper)
        val mainHandler = Handler(Looper.getMainLooper())
        
        backgroundHandler.post {
            val result = performWork()
            mainHandler.post {
                updateUI(result)
            }
        }
    }
    
    // Executor approach - Better thread management
    fun executorApproach() {
        val executor = Executors.newSingleThreadExecutor()
        val mainHandler = Handler(Looper.getMainLooper())
        
        executor.execute {
            val result = performWork()
            mainHandler.post {
                updateUI(result)
            }
        }
    }
    
    // Coroutines approach - Modern, structured concurrency
    suspend fun coroutinesApproach() {
        val result = withContext(Dispatchers.IO) {
            performWork()
        }
        // Automatically switches to main thread in viewModelScope
        updateUI(result)
    }
    
    // RxJava approach - Reactive streams
    fun rxJavaApproach() {
        val disposable = Single.fromCallable { performWork() }
            .subscribeOn(Schedulers.io())
            .observeOn(AndroidSchedulers.mainThread())
            .subscribe { result -> updateUI(result) }
    }
    
    private fun performWork(): String = "Work completed"
    private fun updateUI(result: String) { println("UI updated: $result") }
}
```

**Performance Considerations:**

```kotlin
class PerformanceOptimizations {
    
    // Thread pool sizing recommendations
    companion object {
        // CPU-intensive tasks: Number of cores
        val CPU_INTENSIVE_POOL = Executors.newFixedThreadPool(
            Runtime.getRuntime().availableProcessors()
        )
        
        // I/O tasks: Higher number since threads often wait
        val IO_POOL = Executors.newFixedThreadPool(
            Runtime.getRuntime().availableProcessors() * 2
        )
        
        // Custom thread pool with proper configuration
        val CUSTOM_POOL = ThreadPoolExecutor(
            2, // Core pool size
            4, // Maximum pool size
            60L, TimeUnit.SECONDS, // Keep alive time
            LinkedBlockingQueue<Runnable>(100), // Bounded queue
            ThreadFactory { runnable ->
                Thread(runnable, "CustomWorker").apply {
                    isDaemon = true
                    priority = Thread.NORM_PRIORITY - 1
                }
            },
            ThreadPoolExecutor.CallerRunsPolicy() // Rejection policy
        )
    }
    
    // Memory leak prevention patterns
    class LeakSafeAsyncTask(context: Context) {
        private val contextRef = WeakReference(context)
        
        fun performTask() {
            Thread {
                val result = performBackgroundWork()
                
                // Check if context still exists
                contextRef.get()?.let { context ->
                    if (context is Activity && !context.isDestroyed) {
                        (context as Activity).runOnUiThread {
                            updateUI(result)
                        }
                    }
                }
            }.start()
        }
        
        private fun performBackgroundWork(): String = "Background work"
        private fun updateUI(result: String) { /* Update UI */ }
    }
    
    // Coroutines best practices for performance
    class OptimizedCoroutineUsage : ViewModel() {
        
        // Use appropriate dispatcher for the task
        suspend fun optimizedDataProcessing() {
            // I/O work
            val networkData = withContext(Dispatchers.IO) {
                fetchFromNetwork()
            }
            
            // CPU-intensive work
            val processedData = withContext(Dispatchers.Default) {
                processLargeDataset(networkData)
            }
            
            // UI work (automatic in viewModelScope)
            updateUI(processedData)
        }
        
        // Avoid creating too many coroutines
        suspend fun processItemsEfficiently(items: List<String>) {
            // Bad: Creates many coroutines
            // items.map { item -> async { processItem(item) } }
            
            // Good: Process in chunks
            items.chunked(10).forEach { chunk ->
                withContext(Dispatchers.Default) {
                    chunk.forEach { item -> processItem(item) }
                }
            }
        }
        
        // Use Flow for reactive data streams
        fun observeDataChanges(): Flow<List<String>> = flow {
            while (currentCoroutineContext().isActive) {
                val data = fetchLatestData()
                emit(data)
                delay(5000) // Poll every 5 seconds
            }
        }.flowOn(Dispatchers.IO)
        
        private suspend fun fetchFromNetwork(): String = "Network data"
        private suspend fun processLargeDataset(data: String): String = "Processed data"
        private fun updateUI(data: String) { /* Update UI */ }
        private suspend fun processItem(item: String) { /* Process item */ }
        private suspend fun fetchLatestData(): List<String> = listOf("Data")
    }
}
```

**Migration Strategies:**

```kotlin
// Migrating from AsyncTask to Coroutines
class MigrationExample {
    
    // Old AsyncTask approach (deprecated)
    @Suppress("DEPRECATION")
    private class OldAsyncTask : AsyncTask<String, Int, String>() {
        override fun doInBackground(vararg params: String): String {
            // Background work
            return "Result"
        }
        
        override fun onPostExecute(result: String) {
            // UI update
        }
    }
    
    // New coroutines approach
    class ModernViewModel : ViewModel() {
        fun performTask() {
            viewModelScope.launch {
                try {
                    val result = withContext(Dispatchers.IO) {
                        // Background work - same as doInBackground
                        performBackgroundWork()
                    }
                    // UI update - same as onPostExecute
                    updateUI(result)
                } catch (e: Exception) {
                    handleError(e)
                }
            }
        }
        
        private suspend fun performBackgroundWork(): String = "Result"
        private fun updateUI(result: String) { /* Update UI */ }
        private fun handleError(error: Exception) { /* Handle error */ }
    }
    
    // Migrating from RxJava to Coroutines
    class RxToCoroutinesMigration {
        
        // RxJava version
        fun rxJavaVersion(): Single<String> {
            return Single.fromCallable { fetchData() }
                .subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .map { data -> processData(data) }
        }
        
        // Coroutines version
        suspend fun coroutinesVersion(): String = withContext(Dispatchers.IO) {
            val data = fetchData()
            processData(data)
        }
        
        // RxJava chain to coroutines
        fun rxChainMigration() {
            // RxJava
            val disposable = fetchUser()
                .flatMap { user -> fetchPosts(user.id) }
                .subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe { posts -> displayPosts(posts) }
        }
        
        suspend fun coroutineChainMigration() {
            val user = withContext(Dispatchers.IO) { fetchUserSuspend() }
            val posts = withContext(Dispatchers.IO) { fetchPostsSuspend(user.id) }
            displayPosts(posts)
        }
        
        private fun fetchData(): String = "Data"
        private fun processData(data: String): String = "Processed: $data"
        private fun fetchUser(): Single<User> = Single.just(User("1", "John"))
        private fun fetchPosts(userId: String): Single<List<String>> = Single.just(listOf("Post"))
        private suspend fun fetchUserSuspend(): User = User("1", "John")
        private suspend fun fetchPostsSuspend(userId: String): List<String> = listOf("Post")
        private fun displayPosts(posts: List<String>) { /* Display posts */ }
    }
}
```

**Testing Asynchronous Code:**

```kotlin
class AsynchronousTestingExample {
    
    // Testing coroutines
    @Test
    fun testCoroutines() = runTest {
        val viewModel = TestViewModel()
        
        viewModel.loadData()
        
        // Verify result
        assertEquals("Expected result", viewModel.result.value)
    }
    
    // Testing with TestCoroutineDispatcher (older approach)
    @Test
    fun testWithTestDispatcher() {
        val testDispatcher = UnconfinedTestDispatcher()
        
        runTest(testDispatcher) {
            val repository = TestRepository()
            val result = repository.getData()
            assertEquals("Test data", result)
        }
    }
    
    // Testing RxJava
    @Test
    fun testRxJava() {
        val testScheduler = TestScheduler()
        RxJavaPlugins.setIoSchedulerHandler { testScheduler }
        RxAndroidPlugins.setMainThreadSchedulerHandler { testScheduler }
        
        val repository = RxTestRepository()
        val testObserver = repository.getData().test()
        
        testScheduler.advanceTimeBy(1, TimeUnit.SECONDS)
        
        testObserver.assertComplete()
        testObserver.assertValue("Test data")
    }
    
    class TestViewModel : ViewModel() {
        private val _result = MutableLiveData<String>()
        val result: LiveData<String> = _result
        
        fun loadData() {
            viewModelScope.launch {
                _result.value = withContext(Dispatchers.IO) {
                    "Expected result"
                }
            }
        }
    }
    
    class TestRepository {
        suspend fun getData(): String = withContext(Dispatchers.IO) {
            delay(100)
            "Test data"
        }
    }
    
    class RxTestRepository {
        fun getData(): Single<String> {
            return Single.just("Test data")
                .delay(1, TimeUnit.SECONDS)
                .subscribeOn(Schedulers.io())
        }
    }
}
```

**Conclusion**

Modern Android development strongly favors Kotlin Coroutines for asynchronous programming due to their integration with Android Architecture Components, structured concurrency model, and simpler syntax. However, understanding the evolution from Handlers and AsyncTask through ExecutorService to Coroutines and RxJava provides valuable context for maintaining existing codebases and making informed architectural decisions.

**Important Subtopics:**

- WorkManager for guaranteed background execution
- Jetpack Compose integration with coroutines and flows
- Advanced Flow operators and transformation patterns
- Debugging asynchronous code and performance profiling
- Custom coroutine contexts and dispatchers
- Integration with dependency injection frameworks

---

