## ViewPager with Fragments


ViewPager provides swipeable navigation between fragments, commonly used for tab-based interfaces, onboarding flows, or image galleries. ViewPager2, the modern implementation, offers improved performance and additional features compared to the original ViewPager.

### ViewPager2 Implementation

ViewPager2 uses RecyclerView internally, providing better performance and support for both horizontal and vertical orientation. It requires a FragmentStateAdapter to manage fragment creation and lifecycle.

**Example** of ViewPager2 with fragments:

```kotlin
// Fragment adapter
class TabFragmentAdapter(fragmentActivity: FragmentActivity) : FragmentStateAdapter(fragmentActivity) {
    
    private val fragments = listOf(
        HomeFragment(),
        ExploreFragment(),
        ProfileFragment()
    )
    
    private val fragmentTitles = listOf(
        "Home",
        "Explore", 
        "Profile"
    )
    
    override fun getItemCount(): Int = fragments.size
    
    override fun createFragment(position: Int): Fragment = fragments[position]
    
    fun getFragmentTitle(position: Int): String = fragmentTitles[position]
}

// Activity setup
class MainActivity : AppCompatActivity() {
    
    private lateinit var binding: ActivityMainBinding
    private lateinit var tabAdapter: TabFragmentAdapter
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityMainBinding.inflate(layoutInflater)
        setContentView(binding.root)
        
        setupViewPager()
        setupTabs()
    }
    
    private fun setupViewPager() {
        tabAdapter = TabFragmentAdapter(this)
        binding.viewPager.adapter = tabAdapter
        
        // Optional: Disable user swipe if needed
        binding.viewPager.isUserInputEnabled = true
        
        // Optional: Set offscreen page limit
        binding.viewPager.offscreenPageLimit = 1
    }
    
    private fun setupTabs() {
        TabLayoutMediator(binding.tabLayout, binding.viewPager) { tab, position ->
            tab.text = tabAdapter.getFragmentTitle(position)
            
            // Optional: Add icons
            val icons = arrayOf(
                R.drawable.ic_home,
                R.drawable.ic_explore,
                R.drawable.ic_profile
            )
            tab.setIcon(icons[position])
        }.attach()
    }
}
```

### Dynamic Fragment Management

For scenarios requiring dynamic fragment management based on data or user actions, implement an adapter that can handle fragment updates and data changes.

**Example** of dynamic ViewPager2 adapter:

```kotlin
class DynamicTabAdapter(
    fragmentActivity: FragmentActivity,
    private val dataProvider: TabDataProvider
) : FragmentStateAdapter(fragmentActivity) {
    
    private val fragmentCache = mutableMapOf<String, Fragment>()
    
    override fun getItemCount(): Int = dataProvider.getTabCount()
    
    override fun createFragment(position: Int): Fragment {
        val tabData = dataProvider.getTabData(position)
        val fragmentKey = "${tabData.type}_${tabData.id}"
        
        return fragmentCache.getOrPut(fragmentKey) {
            when (tabData.type) {
                TabType.LIST -> DataListFragment.newInstance(tabData.id)
                TabType.GRID -> DataGridFragment.newInstance(tabData.id)
                TabType.MAP -> MapViewFragment.newInstance(tabData.coordinates)
                else -> PlaceholderFragment.newInstance(tabData.title)
            }
        }
    }
    
    override fun getItemId(position: Int): Long {
        return dataProvider.getTabData(position).id.hashCode().toLong()
    }
    
    override fun containsItem(itemId: Long): Boolean {
        return dataProvider.getAllTabIds().any { it.hashCode().toLong() == itemId }
    }
    
    fun updateData() {
        notifyDataSetChanged()
    }
    
    fun addTab(tabData: TabData) {
        dataProvider.addTab(tabData)
        notifyItemInserted(dataProvider.getTabCount() - 1)
    }
    
    fun removeTab(position: Int) {
        val tabData = dataProvider.getTabData(position)
        val fragmentKey = "${tabData.type}_${tabData.id}"
        fragmentCache.remove(fragmentKey)
        
        dataProvider.removeTab(position)
        notifyItemRemoved(position)
    }
}

// Usage with data updates
class DynamicTabActivity : AppCompatActivity() {
    
    private lateinit var adapter: DynamicTabAdapter
    private lateinit var tabDataProvider: TabDataProvider
    
    private fun setupDynamicTabs() {
        tabDataProvider = TabDataProvider()
        adapter = DynamicTabAdapter(this, tabDataProvider)
        binding.viewPager.adapter = adapter
        
        // Setup tab layout with dynamic updates
        TabLayoutMediator(binding.tabLayout, binding.viewPager) { tab, position ->
            val tabData = tabDataProvider.getTabData(position)
            tab.text = tabData.title
            tab.setIcon(tabData.iconRes)
        }.attach()
    }
    
    private fun addNewTab(title: String, type: TabType) {
        val newTab = TabData(
            id = generateTabId(),
            title = title,
            type = type,
            iconRes = getIconForType(type)
        )
        
        adapter.addTab(newTab)
    }
}
```

### ViewPager2 with Different Fragment Types

For complex applications, ViewPager2 can host different types of fragments based on data or user preferences, each with different layouts and functionality.

**Example** of mixed fragment types:

```kotlin
class MixedContentAdapter(
    fragment: Fragment,
    private val contentItems: List<ContentItem>
) : FragmentStateAdapter(fragment) {
    
    override fun getItemCount(): Int = contentItems.size
    
    override fun createFragment(position: Int): Fragment {
        return when (val item = contentItems[position]) {
            is ArticleContent -> ArticleFragment.newInstance(item.articleId)
            is VideoContent -> VideoPlayerFragment.newInstance(item.videoUrl)
            is GalleryContent -> ImageGalleryFragment.newInstance(item.imageUrls)
            is InteractiveContent -> InteractiveFragment.newInstance(item.config)
            else -> EmptyContentFragment()
        }
    }
    
    override fun getItemId(position: Int): Long {
        return contentItems[position].id.hashCode().toLong()
    }
    
    override fun containsItem(itemId: Long): Boolean {
        return contentItems.any { it.id.hashCode().toLong() == itemId }
    }
}

// Fragment implementations with specific functionality
class VideoPlayerFragment : Fragment() {
    
    companion object {
        fun newInstance(videoUrl: String): VideoPlayerFragment {
            return VideoPlayerFragment().apply {
                arguments = Bundle().apply {
                    putString("video_url", videoUrl)
                }
            }
        }
    }
    
    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        
        val videoUrl = arguments?.getString("video_url") ?: return
        setupVideoPlayer(videoUrl)
    }
    
    override fun onPause() {
        super.onPause()
        // Pause video playback when fragment is not visible
        pauseVideo()
    }
    
    private fun setupVideoPlayer(url: String) {
        // Video player setup implementation
    }
    
    private fun pauseVideo() {
        // Pause video implementation
    }
}
```

### Performance Optimization

ViewPager2 performance can be optimized through proper fragment management, lazy loading, and memory-conscious implementations.

**Key Points:**

- Use `offscreenPageLimit` judiciously to balance performance and memory usage
- Implement lazy loading for heavy content within fragments
- Clean up resources in fragment lifecycle methods
- Consider using `FragmentStateAdapter` over `FragmentPagerAdapter` for better memory management

**Example** of optimized ViewPager2 usage:

```kotlin
class OptimizedPagerAdapter(
    fragmentActivity: FragmentActivity
) : FragmentStateAdapter(fragmentActivity) {
    
    private val fragmentFactory = FragmentFactory()
    
    override fun getItemCount(): Int = TOTAL_PAGES
    
    override fun createFragment(position: Int): Fragment {
        // Create fragments lazily with minimal initial setup
        return fragmentFactory.createOptimizedFragment(position)
    }
    
    // Custom fragment factory for optimized creation
    private class FragmentFactory {
        fun createOptimizedFragment(position: Int): Fragment {
            return when (position) {
                0 -> LazyLoadingFragment.newInstance("page_0")
                1 -> CachedDataFragment.newInstance("page_1")
                else -> LightweightFragment.newInstance("page_$position")
            }
        }
    }
    
    companion object {
        private const val TOTAL_PAGES = 10
    }
}

// Lazy loading fragment implementation 
class LazyLoadingFragment : Fragment() {
	private var _binding: FragmentLazyLoadingBinding? = null
	private val binding get() = _binding!!
	
	private var hasLoadedData = false
	private val viewModel: LazyDataViewModel by viewModels()
	
	override fun onCreateView(
	    inflater: LayoutInflater,
	    container: ViewGroup?,
	    savedInstanceState: Bundle?
	): View {
	    _binding = FragmentLazyLoadingBinding.inflate(inflater, container, false)
	    return binding.root
	}
	
	override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
	    super.onViewCreated(view, savedInstanceState)
	    
	    // Don't load data immediately - wait for fragment to become visible
	    observeVisibilityAndLoadData()
	}
	
	private fun observeVisibilityAndLoadData() {
	    viewLifecycleOwner.lifecycle.addObserver(object : DefaultLifecycleObserver {
	        override fun onResume(owner: LifecycleOwner) {
	            // Only load data when fragment becomes visible for the first time
	            if (!hasLoadedData && isVisible) {
	                loadData()
	                hasLoadedData = true
	            }
	        }
	    })
	}
	
	private fun loadData() {
	    viewModel.loadExpensiveData()
	    
	    viewModel.data.observe(viewLifecycleOwner) { data ->
	        updateUI(data)
	    }
	}
	
	private fun updateUI(data: List<DataItem>) {
	    // Update UI with loaded data
	    binding.recyclerView.adapter = DataAdapter(data)
	    binding.loadingIndicator.isVisible = false
	}
	
	override fun onDestroyView() {
	    super.onDestroyView()
	    _binding = null
	}
	
	companion object {
	    fun newInstance(pageId: String): LazyLoadingFragment {
	        return LazyLoadingFragment().apply {
	            arguments = Bundle().apply {
	                putString("page_id", pageId)
	            }
	        }
	    }
	}
}

// ViewPager2 activity with optimized settings 
class OptimizedViewPagerActivity : AppCompatActivity() {
	private lateinit var binding: ActivityOptimizedViewPagerBinding
	
	override fun onCreate(savedInstanceState: Bundle?) {
	    super.onCreate(savedInstanceState)
	    binding = ActivityOptimizedViewPagerBinding.inflate(layoutInflater)
	    setContentView(binding.root)
	    
	    setupOptimizedViewPager()
	}
	
	private fun setupOptimizedViewPager() {
	    val adapter = OptimizedPagerAdapter(this)
	    binding.viewPager.adapter = adapter
	    
	    // Optimize ViewPager2 settings
	    binding.viewPager.apply {
	        // Keep only adjacent pages in memory
	        offscreenPageLimit = 1
	        
	        // Reduce overdraw during transitions
	        setPageTransformer { page, position ->
	            page.alpha = 1 - kotlin.math.abs(position)
	        }
	        
	        // Register callback to handle fragment visibility
	        registerOnPageChangeCallback(object : ViewPager2.OnPageChangeCallback() {
	            override fun onPageSelected(position: Int) {
	                super.onPageSelected(position)
	                // Notify current fragment about visibility
	                notifyFragmentVisibility(position)
	            }
	        })
	    }
	}
	
	private fun notifyFragmentVisibility(position: Int) {
	    val fragment = supportFragmentManager.fragments
	        .find { it.tag?.contains("f$position") == true }
	    
	    (fragment as? VisibilityAwareFragment)?.onBecameVisible()
	}
}

// Interface for fragments that need to handle visibility changes interface VisibilityAwareFragment { 
	fun onBecameVisible() 
	fun onBecameHidden()
}

````

### Nested Fragments in ViewPager2

ViewPager2 can contain fragments that themselves host child fragments, enabling complex nested navigation patterns while maintaining proper lifecycle management.

**Example** of nested fragment architecture:
```kotlin
// Parent fragment containing ViewPager2
class SectionContainerFragment : Fragment() {
    
    private var _binding: FragmentSectionContainerBinding? = null
    private val binding get() = _binding!!
    
    private lateinit var sectionAdapter: SectionPagerAdapter
    
    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        _binding = FragmentSectionContainerBinding.inflate(inflater, container, false)
        return binding.root
    }
    
    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        
        setupNestedViewPager()
        setupNestedTabs()
    }
    
    private fun setupNestedViewPager() {
        // Use childFragmentManager for nested fragments
        sectionAdapter = SectionPagerAdapter(this)
        binding.nestedViewPager.adapter = sectionAdapter
        
        // Configure for nested environment
        binding.nestedViewPager.offscreenPageLimit = 1
        binding.nestedViewPager.isUserInputEnabled = true
    }
    
    private fun setupNestedTabs() {
        TabLayoutMediator(binding.nestedTabLayout, binding.nestedViewPager) { tab, position ->
            tab.text = sectionAdapter.getTabTitle(position)
        }.attach()
    }
    
    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null
    }
}

// Adapter for nested fragments
class SectionPagerAdapter(fragment: Fragment) : FragmentStateAdapter(fragment) {
    
    private val sections = listOf(
        "Overview",
        "Details", 
        "Reviews",
        "Related"
    )
    
    override fun getItemCount(): Int = sections.size
    
    override fun createFragment(position: Int): Fragment {
        return when (position) {
            0 -> OverviewFragment()
            1 -> DetailsFragment()
            2 -> ReviewsFragment()
            3 -> RelatedItemsFragment()
            else -> throw IllegalArgumentException("Invalid position: $position")
        }
    }
    
    fun getTabTitle(position: Int): String = sections[position]
}

// Child fragment within the nested ViewPager2
class OverviewFragment : Fragment(), VisibilityAwareFragment {
    
    private var _binding: FragmentOverviewBinding? = null
    private val binding get() = _binding!!
    
    private val viewModel: OverviewViewModel by viewModels()
    
    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        _binding = FragmentOverviewBinding.inflate(inflater, container, false)
        return binding.root
    }
    
    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        
        setupUI()
        observeData()
    }
    
    override fun onBecameVisible() {
        // Handle visibility in nested context
        refreshDataIfNeeded()
    }
    
    override fun onBecameHidden() {
        // Pause expensive operations
        pauseBackgroundTasks()
    }
    
    private fun setupUI() {
        binding.refreshLayout.setOnRefreshListener {
            viewModel.refreshOverview()
        }
    }
    
    private fun observeData() {
        viewModel.overviewData.observe(viewLifecycleOwner) { data ->
            updateOverviewUI(data)
            binding.refreshLayout.isRefreshing = false
        }
    }
    
    private fun refreshDataIfNeeded() {
        if (shouldRefreshData()) {
            viewModel.refreshOverview()
        }
    }
    
    private fun shouldRefreshData(): Boolean {
        // [Inference] Logic to determine if data refresh is needed
        return viewModel.isDataStale()
    }
    
    private fun updateOverviewUI(data: OverviewData) {
        binding.titleText.text = data.title
        binding.summaryText.text = data.summary
        binding.statisticsLayout.updateStats(data.statistics)
    }
    
    private fun pauseBackgroundTasks() {
        // Pause any ongoing background operations
        viewModel.pauseTasks()
    }
    
    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null
    }
}
````

### Advanced ViewPager2 Customization

ViewPager2 supports advanced customization including custom page transformations, orientation changes, and integration with complex navigation patterns.

**Example** of advanced ViewPager2 customization:

```kotlin
class AdvancedViewPagerFragment : Fragment() {
    
    private var _binding: FragmentAdvancedViewPagerBinding? = null
    private val binding get() = _binding!!
    
    private lateinit var advancedAdapter: AdvancedPagerAdapter
    
    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        
        setupAdvancedViewPager()
        setupCustomTransitions()
        setupDynamicOrientation()
    }
    
    private fun setupAdvancedViewPager() {
        advancedAdapter = AdvancedPagerAdapter(this)
        binding.viewPager.adapter = advancedAdapter
        
        // Advanced configuration
        binding.viewPager.apply {
            offscreenPageLimit = ViewPager2.OFFSCREEN_PAGE_LIMIT_DEFAULT
            
            // Register comprehensive page change callback
            registerOnPageChangeCallback(object : ViewPager2.OnPageChangeCallback() {
                override fun onPageScrolled(
                    position: Int,
                    positionOffset: Float,
                    positionOffsetPixels: Int
                ) {
                    super.onPageScrolled(position, positionOffset, positionOffsetPixels)
                    
                    // Update UI elements based on scroll progress
                    updateScrollIndicator(position, positionOffset)
                    updateHeaderContent(position, positionOffset)
                }
                
                override fun onPageSelected(position: Int) {
                    super.onPageSelected(position)
                    
                    // Handle page selection
                    handlePageSelection(position)
                    updateNavigationButtons(position)
                }
                
                override fun onPageScrollStateChanged(state: Int) {
                    super.onPageScrollStateChanged(state)
                    
                    when (state) {
                        ViewPager2.SCROLL_STATE_IDLE -> {
                            // Enable certain UI interactions
                            enableUserInteractions(true)
                        }
                        ViewPager2.SCROLL_STATE_DRAGGING -> {
                            // Disable conflicting interactions during scroll
                            enableUserInteractions(false)
                        }
                        ViewPager2.SCROLL_STATE_SETTLING -> {
                            // Handle settling state
                            preparePageTransition()
                        }
                    }
                }
            })
        }
    }
    
    private fun setupCustomTransitions() {
        // Depth page transformer
        val depthTransformer = ViewPager2.PageTransformer { page, position ->
            when {
                position < -1 -> { // [-Infinity,-1)
                    page.alpha = 0f
                }
                position <= 0 -> { // [-1,0]
                    page.alpha = 1f
                    page.translationX = 0f
                    page.scaleX = 1f
                    page.scaleY = 1f
                }
                position <= 1 -> { // (0,1]
                    page.alpha = 1 - position
                    page.translationX = page.width * -position
                    val scaleFactor = 0.75f + (1 - 0.75f) * (1 - kotlin.math.abs(position))
                    page.scaleX = scaleFactor
                    page.scaleY = scaleFactor
                }
                else -> { // (1,+Infinity]
                    page.alpha = 0f
                }
            }
        }
        
        // Zoom out page transformer
        val zoomOutTransformer = ViewPager2.PageTransformer { page, position ->
            val MIN_SCALE = 0.85f
            val MIN_ALPHA = 0.5f
            
            when {
                position < -1 -> {
                    page.alpha = 0f
                }
                position <= 1 -> {
                    val scaleFactor = kotlin.math.max(MIN_SCALE, 1 - kotlin.math.abs(position))
                    val vertMargin = page.height * (1 - scaleFactor) / 2
                    val horzMargin = page.width * (1 - scaleFactor) / 2
                    
                    if (position < 0) {
                        page.translationX = horzMargin - vertMargin / 2
                    } else {
                        page.translationX = -horzMargin + vertMargin / 2
                    }
                    
                    page.scaleX = scaleFactor
                    page.scaleY = scaleFactor
                    page.alpha = MIN_ALPHA + (scaleFactor - MIN_SCALE) / (1 - MIN_SCALE) * (1 - MIN_ALPHA)
                }
                else -> {
                    page.alpha = 0f
                }
            }
        }
        
        // Apply transformer based on user preference or content type
        binding.viewPager.setPageTransformer(
            if (shouldUseDepthTransition()) depthTransformer else zoomOutTransformer
        )
    }
    
    private fun setupDynamicOrientation() {
        binding.orientationToggle.setOnClickListener {
            val currentOrientation = binding.viewPager.orientation
            val newOrientation = if (currentOrientation == ViewPager2.ORIENTATION_HORIZONTAL) {
                ViewPager2.ORIENTATION_VERTICAL
            } else {
                ViewPager2.ORIENTATION_HORIZONTAL
            }
            
            binding.viewPager.orientation = newOrientation
            updateUIForOrientation(newOrientation)
        }
    }
    
    private fun updateScrollIndicator(position: Int, positionOffset: Float) {
        val indicatorWidth = binding.scrollIndicator.width.toFloat()
        val totalPages = advancedAdapter.itemCount
        val indicatorItemWidth = indicatorWidth / totalPages
        
        val indicatorPosition = (position + positionOffset) * indicatorItemWidth
        binding.scrollIndicatorThumb.translationX = indicatorPosition
    }
    
    private fun updateHeaderContent(position: Int, positionOffset: Float) {
        // Interpolate between current and next page titles
        val currentTitle = advancedAdapter.getPageTitle(position)
        val nextTitle = if (position + 1 < advancedAdapter.itemCount) {
            advancedAdapter.getPageTitle(position + 1)
        } else {
            currentTitle
        }
        
        // Update header with smooth transition
        binding.headerTitle.text = if (positionOffset < 0.5f) currentTitle else nextTitle
        binding.headerTitle.alpha = 1f - kotlin.math.abs(positionOffset - 0.5f) * 2f
    }
    
    private fun handlePageSelection(position: Int) {
        // Update fragment-specific configurations
        val selectedFragment = getFragmentAtPosition(position)
        selectedFragment?.let { fragment ->
            when (fragment) {
                is MediaFragment -> {
                    // Configure for media playback
                    keepScreenOn(true)
                    hideSystemUI()
                }
                is InteractiveFragment -> {
                    // Configure for interactive content
                    keepScreenOn(false)
                    showSystemUI()
                }
                is ReadingFragment -> {
                    // Configure for reading
                    adjustBrightness(0.7f)
                    enableReaderMode()
                }
            }
        }
    }
    
    private fun updateNavigationButtons(position: Int) {
        binding.previousButton.isEnabled = position > 0
        binding.nextButton.isEnabled = position < advancedAdapter.itemCount - 1
        
        // Update button text based on content
        if (position == advancedAdapter.itemCount - 1) {
            binding.nextButton.text = getString(R.string.finish)
        } else {
            binding.nextButton.text = getString(R.string.next)
        }
    }
    
    private fun enableUserInteractions(enabled: Boolean) {
        binding.interactiveOverlay.isEnabled = enabled
        binding.actionButton.isEnabled = enabled
    }
    
    private fun preparePageTransition() {
        // Prepare next page content or preload data
        val currentPosition = binding.viewPager.currentItem
        val nextPosition = currentPosition + 1
        
        if (nextPosition < advancedAdapter.itemCount) {
            preloadPageContent(nextPosition)
        }
    }
    
    private fun shouldUseDepthTransition(): Boolean {
        // [Inference] Logic to determine appropriate transition type
        return advancedAdapter.getContentType() == ContentType.MEDIA
    }
    
    private fun updateUIForOrientation(orientation: Int) {
        when (orientation) {
            ViewPager2.ORIENTATION_HORIZONTAL -> {
                binding.orientationToggle.text = getString(R.string.switch_to_vertical)
                // Update layout constraints for horizontal scrolling
                updateLayoutForHorizontal()
            }
            ViewPager2.ORIENTATION_VERTICAL -> {
                binding.orientationToggle.text = getString(R.string.switch_to_horizontal)
                // Update layout constraints for vertical scrolling
                updateLayoutForVertical()
            }
        }
    }
    
    private fun getFragmentAtPosition(position: Int): Fragment? {
        return childFragmentManager.fragments.find { fragment ->
            fragment.tag?.contains("f$position") == true
        }
    }
    
    private fun keepScreenOn(keep: Boolean) {
        if (keep) {
            requireActivity().window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
        } else {
            requireActivity().window.clearFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
        }
    }
    
    private fun hideSystemUI() {
        requireActivity().window.decorView.systemUiVisibility = (
            View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY
            or View.SYSTEM_UI_FLAG_LAYOUT_STABLE
            or View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION
            or View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN
            or View.SYSTEM_UI_FLAG_HIDE_NAVIGATION
            or View.SYSTEM_UI_FLAG_FULLSCREEN
        )
    }
    
    private fun showSystemUI() {
        requireActivity().window.decorView.systemUiVisibility = View.SYSTEM_UI_FLAG_LAYOUT_STABLE
    }
    
    private fun adjustBrightness(brightness: Float) {
        val layoutParams = requireActivity().window.attributes
        layoutParams.screenBrightness = brightness
        requireActivity().window.attributes = layoutParams
    }
    
    private fun enableReaderMode() {
        // Configure UI for optimal reading experience
        binding.root.setBackgroundColor(ContextCompat.getColor(requireContext(), R.color.reader_background))
    }
    
    private fun preloadPageContent(position: Int) {
        // Preload content for smoother transitions
        val fragment = getFragmentAtPosition(position) as? PreloadableFragment
        fragment?.preloadContent()
    }
    
    private fun updateLayoutForHorizontal() {
        // Update constraints and margins for horizontal orientation
        val layoutParams = binding.scrollIndicator.layoutParams as ConstraintLayout.LayoutParams
        layoutParams.topToBottom = ConstraintLayout.LayoutParams.UNSET
        layoutParams.bottomToBottom = ConstraintLayout.LayoutParams.PARENT_ID
        binding.scrollIndicator.layoutParams = layoutParams
    }
    
    private fun updateLayoutForVertical() {
        // Update constraints and margins for vertical orientation
        val layoutParams = binding.scrollIndicator.layoutParams as ConstraintLayout.LayoutParams
        layoutParams.bottomToBottom = ConstraintLayout.LayoutParams.UNSET
        layoutParams.endToEnd = ConstraintLayout.LayoutParams.PARENT_ID
        binding.scrollIndicator.layoutParams = layoutParams
    }
}

// Advanced adapter with enhanced functionality
class AdvancedPagerAdapter(
    fragment: Fragment
) : FragmentStateAdapter(fragment) {
    
    private val contentItems = mutableListOf<ContentItem>()
    private val fragmentTitles = mutableListOf<String>()
    
    fun updateContent(items: List<ContentItem>) {
        contentItems.clear()
        contentItems.addAll(items)
        
        fragmentTitles.clear()
        fragmentTitles.addAll(items.map { it.title })
        
        notifyDataSetChanged()
    }
    
    override fun getItemCount(): Int = contentItems.size
    
    override fun createFragment(position: Int): Fragment {
        val item = contentItems[position]
        
        return when (item.type) {
            ContentType.TEXT -> TextContentFragment.newInstance(item.content)
            ContentType.MEDIA -> MediaFragment.newInstance(item.mediaUrl)
            ContentType.INTERACTIVE -> InteractiveFragment.newInstance(item.interactiveData)
            ContentType.WEB -> WebViewFragment.newInstance(item.webUrl)
            else -> PlaceholderFragment.newInstance(item.title)
        }
    }
    
    override fun getItemId(position: Int): Long {
        return contentItems[position].id.hashCode().toLong()
    }
    
    override fun containsItem(itemId: Long): Boolean {
        return contentItems.any { it.id.hashCode().toLong() == itemId }
    }
    
    fun getPageTitle(position: Int): String {
        return if (position < fragmentTitles.size) fragmentTitles[position] else ""
    }
    
    fun getContentType(): ContentType {
        // [Inference] Return predominant content type for UI optimization
        return contentItems.groupBy { it.type }
            .maxByOrNull { it.value.size }?.key ?: ContentType.TEXT
    }
    
    fun addContent(item: ContentItem) {
        contentItems.add(item)
        fragmentTitles.add(item.title)
        notifyItemInserted(contentItems.size - 1)
    }
    
    fun removeContent(position: Int) {
        if (position < contentItems.size) {
            contentItems.removeAt(position)
            fragmentTitles.removeAt(position)
            notifyItemRemoved(position)
        }
    }
}

// Interface for fragments that support preloading
interface PreloadableFragment {
    fun preloadContent()
    fun isContentReady(): Boolean
}

// Enhanced content fragment with preloading
class MediaFragment : Fragment(), PreloadableFragment {
    
    private var _binding: FragmentMediaBinding? = null
    private val binding get() = _binding!!
    
    private var mediaUrl: String? = null
    private var isPreloaded = false
    
    companion object {
        fun newInstance(mediaUrl: String): MediaFragment {
            return MediaFragment().apply {
                arguments = Bundle().apply {
                    putString("media_url", mediaUrl)
                }
            }
        }
    }
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        mediaUrl = arguments?.getString("media_url")
    }
    
    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        _binding = FragmentMediaBinding.inflate(inflater, container, false)
        return binding.root
    }
    
    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        
        if (isPreloaded) {
            displayPreloadedContent()
        } else {
            setupMediaPlayer()
        }
    }
    
    override fun preloadContent() {
        mediaUrl?.let { url ->
            // Preload media content in background
            lifecycleScope.launch {
                try {
                    preloadMediaData(url)
                    isPreloaded = true
                } catch (e: Exception) {
                    // Handle preloading error
                    handlePreloadError(e)
                }
            }
        }
    }
    
    override fun isContentReady(): Boolean = isPreloaded
    
    private fun setupMediaPlayer() {
        mediaUrl?.let { url ->
            // Setup media player with URL
            binding.mediaPlayer.setVideoPath(url)
            binding.mediaPlayer.setOnPreparedListener {
                binding.loadingIndicator.isVisible = false
                binding.mediaPlayer.start()
            }
        }
    }
    
    private fun displayPreloadedContent() {
        // Display already preloaded content
        binding.loadingIndicator.isVisible = false
        binding.mediaPlayer.start()
    }
    
    private suspend fun preloadMediaData(url: String) {
        // Implementation for preloading media data
        // This could involve caching, preparing media player, etc.
        withContext(Dispatchers.IO) {
            // Preload media content
        }
    }
    
    private fun handlePreloadError(error: Throwable) {
        // Handle preloading errors gracefully
        binding.errorView.isVisible = true
        binding.errorMessage.text = getString(R.string.preload_error)
    }
    
    override fun onPause() {
        super.onPause()
        binding.mediaPlayer.pause()
    }
    
    override fun onDestroyView() {
        super.onDestroyView()
        binding.mediaPlayer.stopPlayback()
        _binding = null
    }
}

// Data classes for content management
data class ContentItem(
    val id: String,
    val title: String,
    val type: ContentType,
    val content: String = "",
    val mediaUrl: String = "",
    val webUrl: String = "",
    val interactiveData: Map<String, Any> = emptyMap()
)

enum class ContentType {
    TEXT, MEDIA, INTERACTIVE, WEB
}
```

**Related Topics:** For complete fragment implementation, consider exploring Fragment Navigation Architecture Component for type-safe navigation between fragments, Jetpack Navigation's fragment destinations and safe args, Fragment Result API for modern fragment communication patterns, and MotionLayout integration with ViewPager2 for advanced animated transitions between fragment content.

---

