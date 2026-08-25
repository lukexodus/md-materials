## Fragment Best Practices


Implementing fragments effectively requires following established patterns that promote maintainability, performance, and user experience quality.

### State Management and Configuration Changes

Proper state management ensures your fragments can survive configuration changes and process death while maintaining user data and UI state.

**Key Points:**

- Use `onSaveInstanceState()` to persist critical state
- Store large objects in ViewModels rather than instance state
- Implement proper view binding cleanup to prevent memory leaks
- Handle fragment recreation scenarios gracefully

**Example** of robust state management:

```kotlin
class ArticleReaderFragment : Fragment() {
    
    private var _binding: FragmentArticleReaderBinding? = null
    private val binding get() = _binding!!
    
    private val viewModel: ArticleReaderViewModel by viewModels()
    
    private var currentScrollPosition: Int = 0
    private var isBookmarked: Boolean = false
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Restore state
        savedInstanceState?.let { bundle ->
            currentScrollPosition = bundle.getInt("scroll_position", 0)
            isBookmarked = bundle.getBoolean("is_bookmarked", false)
        }
        
        // Get arguments
        arguments?.let { args ->
            val articleId = args.getString("article_id") ?: return@let
            viewModel.loadArticle(articleId)
        }
    }
    
    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        
        setupUI()
        observeData()
        
        // Restore scroll position
        if (currentScrollPosition > 0) {
            binding.scrollView.post {
                binding.scrollView.scrollTo(0, currentScrollPosition)
            }
        }
    }
    
    override fun onSaveInstanceState(outState: Bundle) {
        super.onSaveInstanceState(outState)
        
        // Save current state
        outState.putInt("scroll_position", binding.scrollView.scrollY)
        outState.putBoolean("is_bookmarked", isBookmarked)
    }
    
    override fun onDestroyView() {
        super.onDestroyView()
        // Save current scroll position before view destruction
        currentScrollPosition = binding.scrollView.scrollY
        _binding = null
    }
    
    private fun setupUI() {
        binding.bookmarkButton.setOnClickListener {
            toggleBookmark()
        }
        
        binding.shareButton.setOnClickListener {
            shareArticle()
        }
    }
    
    private fun observeData() {
        viewModel.article.observe(viewLifecycleOwner) { article ->
            updateUI(article)
        }
        
        viewModel.loadingState.observe(viewLifecycleOwner) { isLoading ->
            binding.progressBar.isVisible = isLoading
        }
    }
}
```

### Memory Management

Proper memory management prevents leaks and ensures smooth performance, particularly important for fragments that may be retained across configuration changes.

**Example** of memory-conscious fragment implementation:

```kotlin
class ImageGalleryFragment : Fragment() {
    
    private var _binding: FragmentImageGalleryBinding? = null
    private val binding get() = _binding!!
    
    private var imageAdapter: ImageAdapter? = null
    private val imageLoadingJobs = mutableSetOf<Job>()
    
    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        
        imageAdapter = ImageAdapter(
            onImageClick = { imageUrl -> openImageDetail(imageUrl) },
            onImageLoad = { job -> imageLoadingJobs.add(job) }
        )
        
        binding.recyclerView.adapter = imageAdapter
    }
    
    override fun onPause() {
        super.onPause()
        // Cancel ongoing image loading to save memory and bandwidth
        imageLoadingJobs.forEach { it.cancel() }
        imageLoadingJobs.clear()
    }
    
    override fun onDestroyView() {
        super.onDestroyView()
        
        // Clean up adapter reference
        binding.recyclerView.adapter = null
        imageAdapter = null
        
        // Cancel any remaining jobs
        imageLoadingJobs.forEach { it.cancel() }
        imageLoadingJobs.clear()
        
        _binding = null
    }
    
    private fun openImageDetail(imageUrl: String) {
        // Implementation
    }
}
```

### Error Handling and Edge Cases

Robust fragment implementation includes comprehensive error handling for network failures, data loading issues, and unexpected states.

**Example** of comprehensive error handling:

```kotlin
class DataListFragment : Fragment() {
    
    private val viewModel: DataListViewModel by viewModels()
    
    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        
        observeData()
        setupErrorHandling()
        
        // Initial data load with error handling
        viewModel.loadData()
    }
    
    private fun observeData() {
        viewModel.dataState.observe(viewLifecycleOwner) { state ->
            when (state) {
                is DataState.Loading -> showLoading()
                is DataState.Success -> showData(state.data)
                is DataState.Error -> showError(state.exception)
                is DataState.Empty -> showEmptyState()
            }
        }
    }
    
    private fun setupErrorHandling() {
        binding.retryButton.setOnClickListener {
            viewModel.retryLoad()
        }
        
        binding.swipeRefresh.setOnRefreshListener {
            viewModel.refreshData()
        }
    }
    
    private fun showError(exception: Throwable) {
        binding.swipeRefresh.isRefreshing = false
        
        val errorMessage = when (exception) {
            is NetworkException -> getString(R.string.network_error)
            is ServerException -> getString(R.string.server_error)
            is TimeoutException -> getString(R.string.timeout_error)
            else -> getString(R.string.generic_error)
        }
        
        binding.errorView.isVisible = true
        binding.errorMessage.text = errorMessage
        binding.dataRecyclerView.isVisible = false
    }
    
    private fun showEmptyState() {
        binding.emptyView.isVisible = true
        binding.dataRecyclerView.isVisible = false
        binding.errorView.isVisible = false
    }
}
```

