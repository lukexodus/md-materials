## Model-View-ViewModel (MVVM)


MVVM leverages Android's data binding and observable patterns, with ViewModel acting as a bridge between UI and data layers while surviving configuration changes.

**Key Points:**

- **Model**: Data layer handling business logic, repositories, and data sources
- **View**: UI layer (Activities, Fragments) that observes ViewModel
- **ViewModel**: Holds UI-related data, survives configuration changes, exposes observable data
- Uses LiveData, StateFlow, or Observable fields for reactive programming
- ViewModel never holds references to Views to prevent memory leaks
- Integrates seamlessly with Android Architecture Components

**Example:**

```kotlin
// Model
data class User(
    val id: String,
    val name: String,
    val email: String
)

class UserRepository @Inject constructor(
    private val apiService: ApiService,
    private val userDao: UserDao
) {
    suspend fun getUser(userId: String): User {
        return try {
            val user = apiService.getUser(userId)
            userDao.insertUser(user)
            user
        } catch (e: Exception) {
            userDao.getUser(userId) ?: throw e
        }
    }
}

// ViewModel
class UserViewModel @Inject constructor(
    private val repository: UserRepository,
    private val savedStateHandle: SavedStateHandle
) : ViewModel() {
    
    private val _uiState = MutableStateFlow(UserUiState())
    val uiState: StateFlow<UserUiState> = _uiState.asStateFlow()
    
    private val _events = Channel<UserEvent>()
    val events = _events.receiveAsFlow()
    
    init {
        val userId = savedStateHandle.get<String>("user_id")
        userId?.let { loadUser(it) }
    }
    
    fun loadUser(userId: String) {
        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(isLoading = true)
            
            try {
                val user = repository.getUser(userId)
                _uiState.value = _uiState.value.copy(
                    isLoading = false,
                    user = user,
                    error = null
                )
            } catch (e: Exception) {
                _uiState.value = _uiState.value.copy(
                    isLoading = false,
                    error = e.message
                )
                _events.send(UserEvent.ShowError(e.message ?: "Unknown error"))
            }
        }
    }
    
    fun retryLoad() {
        savedStateHandle.get<String>("user_id")?.let { loadUser(it) }
    }
}

data class UserUiState(
    val isLoading: Boolean = false,
    val user: User? = null,
    val error: String? = null
)

sealed class UserEvent {
    data class ShowError(val message: String) : UserEvent()
}

// View
class UserFragment : Fragment() {
    private var _binding: FragmentUserBinding? = null
    private val binding get() = _binding!!
    
    private val viewModel: UserViewModel by viewModels()
    
    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        _binding = FragmentUserBinding.inflate(inflater, container, false)
        return binding.root
    }
    
    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        
        observeUiState()
        observeEvents()
        
        binding.buttonRetry.setOnClickListener {
            viewModel.retryLoad()
        }
    }
    
    private fun observeUiState() {
        viewLifecycleOwner.lifecycleScope.launch {
            viewModel.uiState.collect { state ->
                binding.progressBar.isVisible = state.isLoading
                binding.buttonRetry.isVisible = state.error != null
                
                state.user?.let { user ->
                    binding.textViewName.text = user.name
                    binding.textViewEmail.text = user.email
                }
            }
        }
    }
    
    private fun observeEvents() {
        viewLifecycleOwner.lifecycleScope.launch {
            viewModel.events.collect { event ->
                when (event) {
                    is UserEvent.ShowError -> {
                        Snackbar.make(binding.root, event.message, Snackbar.LENGTH_LONG)
                            .show()
                    }
                }
            }
        }
    }
    
    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null
    }
}
```

