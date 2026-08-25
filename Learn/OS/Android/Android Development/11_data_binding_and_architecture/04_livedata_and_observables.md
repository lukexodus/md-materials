## LiveData and Observables


LiveData is a lifecycle-aware observable data holder that automatically manages subscriptions based on the lifecycle state of observers.

**Key Points:**

- Automatically handles lifecycle management
- Prevents memory leaks
- Ensures UI updates only when active
- Supports transformation and combination operations
- Thread-safe by design

**LiveData Patterns:**

```kotlin
class NewsViewModel : ViewModel() {
    private val newsRepository = NewsRepository()
    
    // Basic LiveData
    private val _articles = MutableLiveData<List<Article>>()
    val articles: LiveData<List<Article>> = _articles
    
    // Transformation
    val articleTitles: LiveData<List<String>> = articles.map { articleList ->
        articleList.map { it.title }
    }
    
    // Conditional transformation
    private val _selectedCategory = MutableLiveData<String>()
    val selectedCategory: LiveData<String> = _selectedCategory
    
    val filteredArticles: LiveData<List<Article>> = selectedCategory.switchMap { category ->
        newsRepository.getArticlesByCategory(category)
    }
    
    // Combining multiple LiveData sources
    val combinedData: LiveData<NewsUiState> = 
        MediatorLiveData<NewsUiState>().apply {
            var articles: List<Article>? = null
            var loading: Boolean = false
            
            addSource(_articles) { articleList ->
                articles = articleList
                value = NewsUiState(articles, loading)
            }
            
            addSource(_loading) { isLoading ->
                loading = isLoading
                value = NewsUiState(articles, loading)
            }
        }
    
    // Custom LiveData
    class LocationLiveData(context: Context) : LiveData<Location>() {
        private val locationManager = context.getSystemService(Context.LOCATION_SERVICE) as LocationManager
        
        private val locationListener = LocationListener { location ->
            value = location
        }
        
        override fun onActive() {
            super.onActive()
            // Start location updates when there are active observers
            locationManager.requestLocationUpdates(
                LocationManager.GPS_PROVIDER, 
                0L, 0f, locationListener
            )
        }
        
        override fun onInactive() {
            super.onInactive()
            // Stop location updates when no active observers
            locationManager.removeUpdates(locationListener)
        }
    }
}
```

**StateFlow and SharedFlow (Modern Alternatives):**

```kotlin
class ModernViewModel : ViewModel() {
    // StateFlow - holds state and emits current value to new collectors
    private val _uiState = MutableStateFlow(UiState.Loading)
    val uiState: StateFlow<UiState> = _uiState.asStateFlow()
    
    // SharedFlow - doesn't hold state, only emits new values
    private val _events = MutableSharedFlow<Event>()
    val events: SharedFlow<Event> = _events.asSharedFlow()
    
    fun loadData() {
        viewModelScope.launch {
            _uiState.value = UiState.Loading
            try {
                val data = repository.getData()
                _uiState.value = UiState.Success(data)
            } catch (e: Exception) {
                _uiState.value = UiState.Error(e.message)
                _events.emit(Event.ShowError(e.message))
            }
        }
    }
}

// In Fragment/Activity
class MainActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Collect StateFlow
        lifecycleScope.launch {
            viewModel.uiState.collect { state ->
                when (state) {
                    is UiState.Loading -> showLoading()
                    is UiState.Success -> showData(state.data)
                    is UiState.Error -> showError(state.message)
                }
            }
        }
        
        // Collect SharedFlow for one-time events
        lifecycleScope.launch {
            viewModel.events.collect { event ->
                when (event) {
                    is Event.ShowError -> showSnackbar(event.message)
                    is Event.NavigateToDetails -> navigateToDetails()
                }
            }
        }
    }
}
```

