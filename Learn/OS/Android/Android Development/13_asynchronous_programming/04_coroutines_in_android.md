## Coroutines in Android


Kotlin Coroutines provide the most modern and recommended approach for asynchronous programming in Android, offering structured concurrency and lifecycle integration.

**Key Points:**

- Built-in cancellation support
- Exception handling with structured concurrency
- Lifecycle-aware through lifecycle scopes
- Suspend functions enable sequential-looking asynchronous code
- Multiple dispatchers for different types of work

**Basic Coroutines Setup:**

```kotlin
// In build.gradle
dependencies {
    implementation 'org.jetbrains.kotlinx:kotlinx-coroutines-android:1.6.4'
    implementation 'androidx.lifecycle:lifecycle-viewmodel-ktx:2.6.2'
    implementation 'androidx.lifecycle:lifecycle-runtime-ktx:2.6.2'
}

class CoroutinesViewModel : ViewModel() {
    
    private val _uiState = MutableLiveData<UiState>()
    val uiState: LiveData<UiState> = _uiState
    
    // Using viewModelScope - automatically cancelled when ViewModel is cleared
    fun loadData() {
        viewModelScope.launch {
            _uiState.value = UiState.Loading
            
            try {
                // Sequential execution
                val user = fetchUser()
                val posts = fetchPosts(user.id)
                val profile = fetchProfile(user.id)
                
                _uiState.value = UiState.Success(UserData(user, posts, profile))
                
            } catch (e: Exception) {
                _uiState.value = UiState.Error(e.message ?: "Unknown error")
            }
        }
    }
    
    // Parallel execution with async
    fun loadDataParallel() {
        viewModelScope.launch {
            _uiState.value = UiState.Loading
            
            try {
                val user = fetchUser()
                
                // Start both operations concurrently
                val postsDeferred = async { fetchPosts(user.id) }
                val profileDeferred = async { fetchProfile(user.id) }
                
                // Wait for both to complete
                val posts = postsDeferred.await()
                val profile = profileDeferred.await()
                
                _uiState.value = UiState.Success(UserData(user, posts, profile))
                
            } catch (e: Exception) {
                _uiState.value = UiState.Error(e.message ?: "Unknown error")
            }
        }
    }
    
    // Different dispatchers for different types of work
    fun performMixedOperations() {
        viewModelScope.launch {
            // Network operation on IO dispatcher
            val networkData = withContext(Dispatchers.IO) {
                fetchFromNetwork()
            }
            
            // CPU-intensive work on Default dispatcher
            val processedData = withContext(Dispatchers.Default) {
                processData(networkData)
            }
            
            // UI update on Main dispatcher (automatic in viewModelScope)
            updateUI(processedData)
        }
    }
    
    private suspend fun fetchUser(): User = withContext(Dispatchers.IO) {
        delay(1000) // Simulate network delay
        User("1", "John Doe")
    }
    
    private suspend fun fetchPosts(userId: String): List<String> = withContext(Dispatchers.IO) {
        delay(800)
        listOf("Post 1", "Post 2", "Post 3")
    }
    
    private suspend fun fetchProfile(userId: String): String = withContext(Dispatchers.IO) {
        delay(500)
        "User profile data"
    }
    
    private suspend fun fetchFromNetwork(): String = withContext(Dispatchers.IO) {
        delay(2000)
        "Network data"
    }
    
    private suspend fun processData(data: String): String = withContext(Dispatchers.Default) {
        // CPU-intensive processing
        delay(1000)
        "Processed: $data"
    }
    
    private fun updateUI(data: String) {
        _uiState.value = UiState.Success(data)
    }
}

// Usage in Activity with lifecycleScope
class CoroutinesActivity : AppCompatActivity() {
    
    private lateinit var binding: ActivityMainBinding
    private lateinit var viewModel: CoroutinesViewModel
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityMainBinding.inflate(layoutInflater)
        setContentView(binding.root)
        
        // lifecycleScope is automatically cancelled when activity is destroyed
        lifecycleScope.launch {
            // This coroutine respects the activity lifecycle
            performStartupTasks()
        }
        
        // Observe ViewModel
        viewModel.uiState.observe(this) { state ->
            when (state) {
                is UiState.Loading -> showLoading()
                is UiState.Success -> showData(state.data)
                is UiState.Error -> showError(state.message)
            }
        }
    }
    
    private suspend fun performStartupTasks() {
        // Wait for activity to be in STARTED state
        lifecycle.whenStarted {
            initializeComponents()
        }
    }
    
    private suspend fun initializeComponents() {
        // Initialize components
    }
    
    private fun showLoading() { binding.progressBar.isVisible = true }
    private fun showData(data: Any) { /* Show data */ }
    private fun showError(message: String) { /* Show error */ }
}
```

**Advanced Coroutines Patterns:**

```kotlin
class AdvancedCoroutinesExample : ViewModel() {
    
    // Flow for reactive programming
    private val _searchQuery = MutableStateFlow("")
    val searchQuery: StateFlow<String> = _searchQuery
    
    val searchResults: StateFlow<List<SearchResult>> = searchQuery
        .debounce(300) // Wait for 300ms of inactivity
        .distinctUntilChanged() // Only emit when query actually changes
        .filter { it.length >= 2 } // Only search for queries with 2+ characters
        .flatMapLatest { query ->
            performSearch(query)
        }
        .stateIn(
            scope = viewModelScope,
            started = SharingStarted.WhileSubscribed(5000),
            initialValue = emptyList()
        )
    
    fun updateSearchQuery(query: String) {
        _searchQuery.value = query
    }
    
    private fun performSearch(query: String): Flow<List<SearchResult>> = flow {
        emit(emptyList()) // Show loading state
        
        try {
            val results = withContext(Dispatchers.IO) {
                searchRepository.search(query)
            }
            emit(results)
        } catch (e: Exception) {
            emit(emptyList()) // Handle error
        }
    }
    
    // Retry mechanism with exponential backoff
    suspend fun fetchWithRetry(maxRetries: Int = 3): String {
        repeat(maxRetries) { attempt ->
            try {
                return withContext(Dispatchers.IO) {
                    fetchDataFromServer()
                }
            } catch (e: Exception) {
                if (attempt < maxRetries - 1) {
                    val delay = (2.0.pow(attempt) * 1000).toLong()
                    delay(delay) // Exponential backoff
                } else {
                    throw e // Last attempt failed
                }
            }
        }
        error("Should not reach here")
    }
    
    // Timeout handling
    suspend fun fetchWithTimeout(): String {
        return withTimeout(5000) { // 5 second timeout
            withContext(Dispatchers.IO) {
                fetchDataFromServer()
            }
        }
    }
    
    // Cancellation handling
    suspend fun cancellableOperation(): String {
        return withContext(Dispatchers.IO) {
            for (i in 1..100) {
                ensureActive() // Check for cancellation
                
                // Simulate work
                delay(100)
                
                if (i % 10 == 0) {
                    println("Progress: $i%")
                }
            }
            "Operation completed"
        }
    }
    
    // Error handling with supervisorScope
    suspend fun parallelOperationsWithErrorHandling() {
        supervisorScope {
            val job1 = async { riskyOperation1() }
            val job2 = async { riskyOperation2() }
            val job3 = async { riskyOperation3() }
            
            // Collect results, handling failures individually
            val results = listOf(job1, job2, job3).mapNotNull { job ->
                try {
                    job.await()
                } catch (e: Exception) {
                    println("Operation failed: ${e.message}")
                    null
                }
            }
            
            processResults(results)
        }
    }
    
    private suspend fun riskyOperation1(): String = "Result 1"
    private suspend fun riskyOperation2(): String = throw Exception("Failed")
    private suspend fun riskyOperation3(): String = "Result 3"
    private suspend fun fetchDataFromServer(): String = "Server data"
    private fun processResults(results: List<String>) { /* Process results */ }
    
    private val searchRepository = SearchRepository()
}

// Repository using coroutines
class CoroutineRepository {
    private val apiService: ApiService = createApiService()
    private val database: Database = createDatabase()
    
    suspend fun getUser(id: String): User = withContext(Dispatchers.IO) {
        try {
            // Try network first
            val user = apiService.getUser(id)
            database.insertUser(user)
            user
        } catch (e: Exception) {
            // Fallback to cached data
            database.getUser(id) ?: throw e
        }
    }
    
    fun getUserStream(id: String): Flow<User> = flow {
        // Emit cached data first
        database.getUser(id)?.let { emit(it) }
        
        try {
            // Fetch fresh data
            val freshUser = apiService.getUser(id)
            database.insertUser(freshUser)
            emit(freshUser)
        } catch (e: Exception) {
            // Handle error or ignore if we have cached data
        }
    }.flowOn(Dispatchers.IO)
    
    private fun createApiService(): ApiService = TODO()
    private fun createDatabase(): Database = TODO()
}

interface ApiService {
    suspend fun getUser(id: String): User
}

interface Database {
    suspend fun getUser(id: String): User?
    suspend fun insertUser(user: User)
}

class SearchRepository {
    suspend fun search(query: String): List<SearchResult> {
        delay(500) // Simulate network delay
        return listOf(SearchResult(query))
    }
}

data class User(val id: String, val name: String)
data class SearchResult(val title: String)
data class UserData(val user: User, val posts: List<String>, val profile: String)

sealed class UiState {
    object Loading : UiState()
    data class Success(val data: Any) : UiState()
    data class Error(val message: String) : UiState()
}
```

