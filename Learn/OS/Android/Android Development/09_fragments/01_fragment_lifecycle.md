## Fragment Lifecycle


The fragment lifecycle is more complex than the activity lifecycle because fragments must coordinate with their host activity while maintaining their own state management. Understanding this lifecycle is crucial for proper resource management and state handling.

### Lifecycle States and Methods

Fragments progress through multiple states during their existence, each triggering specific lifecycle methods that allow you to perform appropriate setup, cleanup, or state management operations.

**Key Lifecycle Methods:**

`onAttach()` - Called when the fragment is first attached to its context (activity). This is where you can obtain references to the host activity and perform initial setup that requires a context.

`onCreate()` - Similar to activity's onCreate(), this is where you initialize components that don't require a view, such as retained state, background tasks, or non-UI related setup.

`onCreateView()` - Creates and returns the view hierarchy associated with the fragment. This is where you inflate your layout and set up the UI structure.

`onViewCreated()` - Called immediately after onCreateView() when the view hierarchy has been created. This is the appropriate place to initialize UI components, set up listeners, and configure the view.

`onStart()` and `onResume()` - Called when the fragment becomes visible and interactive, respectively. These mirror the activity lifecycle states.

`onPause()`, `onStop()`, and `onDestroyView()` - Handle the reverse process as the fragment becomes inactive. `onDestroyView()` is particularly important as it's where you should clean up view-related resources.

`onDestroy()` and `onDetach()` - Final cleanup phases where you release resources and clear references to prevent memory leaks.

**Example** of fragment lifecycle implementation:

```kotlin
class UserProfileFragment : Fragment() {
    
    private var _binding: FragmentUserProfileBinding? = null
    private val binding get() = _binding!!
    
    private lateinit var userRepository: UserRepository
    
    override fun onAttach(context: Context) {
        super.onAttach(context)
        // Initialize context-dependent components
        userRepository = (context as MainActivity).userRepository
    }
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Initialize non-UI components
        setHasOptionsMenu(true)
        
        // Restore state if needed
        savedInstanceState?.let { bundle ->
            // Restore fragment state
        }
    }
    
    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        _binding = FragmentUserProfileBinding.inflate(inflater, container, false)
        return binding.root
    }
    
    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        
        // Setup UI components
        binding.saveButton.setOnClickListener {
            saveUserProfile()
        }
        
        // Observe data
        userRepository.currentUser.observe(viewLifecycleOwner) { user ->
            updateUI(user)
        }
    }
    
    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null // Prevent memory leaks
    }
    
    override fun onSaveInstanceState(outState: Bundle) {
        super.onSaveInstanceState(outState)
        // Save fragment state
        outState.putString("user_data", getCurrentUserData())
    }
    
    private fun updateUI(user: User) {
        binding.nameEditText.setText(user.name)
        binding.emailEditText.setText(user.email)
    }
    
    private fun saveUserProfile() {
        val user = User(
            name = binding.nameEditText.text.toString(),
            email = binding.emailEditText.text.toString()
        )
        userRepository.updateUser(user)
    }
    
    private fun getCurrentUserData(): String {
        return binding.nameEditText.text.toString()
    }
}
```

### ViewLifecycleOwner vs LifecycleOwner

Fragments provide two different lifecycle owners: the fragment's lifecycle and the view's lifecycle. The view lifecycle is destroyed and recreated when the fragment's view is destroyed (such as during fragment transactions), while the fragment lifecycle persists until the fragment itself is destroyed.

**Key Points:**

- Use `viewLifecycleOwner` for UI-related observers and operations
- Use fragment's `lifecycleOwner` for operations that should persist across view recreations
- Always clean up view references in `onDestroyView()` to prevent memory leaks
- [Unverified] View lifecycle helps prevent crashes when observing data after view destruction

