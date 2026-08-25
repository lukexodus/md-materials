## Communication Between Fragments


Effective fragment communication enables modular design while maintaining loose coupling between components. Android provides several patterns for fragment communication, each suitable for different scenarios.

### Fragment Result API

The Fragment Result API provides a modern, lifecycle-aware approach to fragment communication that replaces older callback patterns. It uses the fragment's lifecycle to automatically manage result delivery and cleanup.

**Example** of Fragment Result API:

```kotlin
// Fragment requesting data
class ProductListFragment : Fragment() {
    
    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        
        // Set up result listener
        setFragmentResultListener("filter_request") { _, bundle ->
            val selectedCategory = bundle.getString("category")
            val priceRange = bundle.getParcelable<PriceRange>("price_range")
            applyFilters(selectedCategory, priceRange)
        }
        
        binding.filterButton.setOnClickListener {
            // Navigate to filter fragment
            findNavController().navigate(R.id.action_to_filter_fragment)
        }
    }
    
    private fun applyFilters(category: String?, priceRange: PriceRange?) {
        // Update product list based on filters
        productAdapter.applyFilters(category, priceRange)
    }
}

// Fragment providing data
class FilterFragment : Fragment() {
    
    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        
        binding.applyButton.setOnClickListener {
            val result = Bundle().apply {
                putString("category", getSelectedCategory())
                putParcelable("price_range", getSelectedPriceRange())
            }
            
            // Send result back to requesting fragment
            setFragmentResult("filter_request", result)
            findNavController().popBackStack()
        }
    }
    
    private fun getSelectedCategory(): String {
        return binding.categorySpinner.selectedItem.toString()
    }
    
    private fun getSelectedPriceRange(): PriceRange {
        return PriceRange(
            min = binding.minPriceSlider.value.toInt(),
            max = binding.maxPriceSlider.value.toInt()
        )
    }
}
```

### Shared ViewModels

ViewModels shared between fragments provide a clean architecture pattern for maintaining state and facilitating communication. The shared ViewModel's scope determines which fragments can access the shared data.

**Example** of shared ViewModel communication:

```kotlin
// Shared ViewModel
class ShoppingCartViewModel : ViewModel() {
    
    private val _cartItems = MutableLiveData<List<CartItem>>()
    val cartItems: LiveData<List<CartItem>> = _cartItems
    
    private val _totalPrice = MutableLiveData<Double>()
    val totalPrice: LiveData<Double> = _totalPrice
    
    private val currentItems = mutableListOf<CartItem>()
    
    fun addItem(product: Product, quantity: Int) {
        val existingItem = currentItems.find { it.product.id == product.id }
        
        if (existingItem != null) {
            existingItem.quantity += quantity
        } else {
            currentItems.add(CartItem(product, quantity))
        }
        
        updateCart()
    }
    
    fun removeItem(productId: String) {
        currentItems.removeAll { it.product.id == productId }
        updateCart()
    }
    
    fun updateQuantity(productId: String, newQuantity: Int) {
        currentItems.find { it.product.id == productId }?.quantity = newQuantity
        updateCart()
    }
    
    private fun updateCart() {
        _cartItems.value = currentItems.toList()
        _totalPrice.value = currentItems.sumOf { it.product.price * it.quantity }
    }
}

// Fragment using shared ViewModel
class ProductDetailFragment : Fragment() {
    
    private val cartViewModel: ShoppingCartViewModel by activityViewModels()
    
    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        
        binding.addToCartButton.setOnClickListener {
            val quantity = binding.quantitySelector.value
            cartViewModel.addItem(currentProduct, quantity)
            
            // Show confirmation
            Snackbar.make(binding.root, "Added to cart", Snackbar.LENGTH_SHORT).show()
        }
        
        // Observe cart changes for UI updates
        cartViewModel.cartItems.observe(viewLifecycleOwner) { items ->
            updateCartBadge(items.size)
        }
    }
}

class CartFragment : Fragment() {
    
    private val cartViewModel: ShoppingCartViewModel by activityViewModels()
    
    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        
        cartViewModel.cartItems.observe(viewLifecycleOwner) { items ->
            cartAdapter.submitList(items)
            binding.emptyCartView.isVisible = items.isEmpty()
        }
        
        cartViewModel.totalPrice.observe(viewLifecycleOwner) { total ->
            binding.totalPriceText.text = "Total: $${String.format("%.2f", total)}"
        }
    }
}
```

### Interface-Based Communication

Interface-based communication provides compile-time safety and clear contracts between fragments and their host activities. This pattern is particularly useful for fragments that need to trigger activity-level operations.

**Example** of interface-based communication:

```kotlin
// Communication interface
interface FragmentActionListener {
    fun onNavigationRequested(destination: String, data: Bundle?)
    fun onDataChanged(dataType: String, data: Any)
    fun onErrorOccurred(error: String)
}

// Fragment implementing interface communication
class SettingsFragment : Fragment() {
    
    private var actionListener: FragmentActionListener? = null
    
    override fun onAttach(context: Context) {
        super.onAttach(context)
        actionListener = context as? FragmentActionListener
            ?: throw RuntimeException("$context must implement FragmentActionListener")
    }
    
    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        
        binding.profileButton.setOnClickListener {
            actionListener?.onNavigationRequested(
                "profile",
                Bundle().apply { putString("user_id", getCurrentUserId()) }
            )
        }
        
        binding.themeSwitch.setOnCheckedChangeListener { _, isChecked ->
            actionListener?.onDataChanged("theme", if (isChecked) "dark" else "light")
        }
    }
    
    override fun onDetach() {
        super.onDetach()
        actionListener = null
    }
}

// Activity implementing the interface
class MainActivity : AppCompatActivity(), FragmentActionListener {
    
    override fun onNavigationRequested(destination: String, data: Bundle?) {
        when (destination) {
            "profile" -> {
                val userId = data?.getString("user_id")
                navigateToProfile(userId)
            }
            // Handle other destinations
        }
    }
    
    override fun onDataChanged(dataType: String, data: Any) {
        when (dataType) {
            "theme" -> {
                val theme = data as String
                applyTheme(theme)
            }
            // Handle other data types
        }
    }
    
    override fun onErrorOccurred(error: String) {
        showErrorDialog(error)
    }
}
```

