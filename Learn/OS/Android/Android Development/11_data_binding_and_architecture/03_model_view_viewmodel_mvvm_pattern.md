## Model-View-ViewModel (MVVM) Pattern


MVVM separates the user interface logic from business logic, with the ViewModel acting as a bridge between the View (UI) and Model (data layer).

**Key Points:**

- ViewModel survives configuration changes
- Provides clear separation of concerns
- Enables easier unit testing
- Supports reactive programming patterns
- Works seamlessly with Android Architecture Components

**ViewModel Implementation:**

```kotlin
class UserProfileViewModel(
    private val userRepository: UserRepository
) : ViewModel() {
    
    private val _user = MutableLiveData<User>()
    val user: LiveData<User> = _user
    
    private val _loading = MutableLiveData<Boolean>()
    val loading: LiveData<Boolean> = _loading
    
    private val _error = MutableLiveData<String>()
    val error: LiveData<String> = _error
    
    fun loadUser(userId: String) {
        viewModelScope.launch {
            _loading.value = true
            try {
                val user = userRepository.getUser(userId)
                _user.value = user
            } catch (e: Exception) {
                _error.value = e.message
            } finally {
                _loading.value = false
            }
        }
    }
    
    fun updateUser(user: User) {
        viewModelScope.launch {
            try {
                userRepository.updateUser(user)
                _user.value = user
            } catch (e: Exception) {
                _error.value = "Failed to update user: ${e.message}"
            }
        }
    }
}

// ViewModelFactory for dependency injection
class UserProfileViewModelFactory(
    private val userRepository: UserRepository
) : ViewModelProvider.Factory {
    
    @Suppress("UNCHECKED_CAST")
    override fun <T : ViewModel> create(modelClass: Class<T>): T {
        if (modelClass.isAssignableFrom(UserProfileViewModel::class.java)) {
            return UserProfileViewModel(userRepository) as T
        }
        throw IllegalArgumentException("Unknown ViewModel class")
    }
}
```

**ViewModel Usage in Activity/Fragment:**

```kotlin
class UserProfileFragment : Fragment() {
    private var _binding: FragmentUserProfileBinding? = null
    private val binding get() = _binding!!
    
    private lateinit var viewModel: UserProfileViewModel
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        val repository = UserRepository() // Usually injected
        val factory = UserProfileViewModelFactory(repository)
        viewModel = ViewModelProvider(this, factory)[UserProfileViewModel::class.java]
    }
    
    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        
        observeViewModel()
        setupDataBinding()
        
        val userId = arguments?.getString("user_id") ?: return
        viewModel.loadUser(userId)
    }
    
    private fun observeViewModel() {
        viewModel.user.observe(viewLifecycleOwner) { user ->
            binding.user = user
        }
        
        viewModel.loading.observe(viewLifecycleOwner) { isLoading ->
            binding.progressBar.isVisible = isLoading
        }
        
        viewModel.error.observe(viewLifecycleOwner) { error ->
            error?.let {
                Snackbar.make(binding.root, it, Snackbar.LENGTH_LONG).show()
            }
        }
    }
    
    private fun setupDataBinding() {
        binding.viewModel = viewModel
        binding.lifecycleOwner = viewLifecycleOwner
    }
}
```

