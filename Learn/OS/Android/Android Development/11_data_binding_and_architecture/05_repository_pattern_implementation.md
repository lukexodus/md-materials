## Repository Pattern Implementation


The Repository pattern provides a clean abstraction layer between the data sources and the rest of the application, centralizing data access logic.

**Key Points:**

- Abstracts data sources from business logic
- Provides a single source of truth
- Enables easy switching between data sources
- Facilitates testing with mock implementations
- Supports offline-first architecture

**Repository Structure:**

```kotlin
// Data classes
data class User(
    val id: String,
    val name: String,
    val email: String,
    val avatarUrl: String?
)

// Local data source interface
interface UserLocalDataSource {
    suspend fun getUser(id: String): User?
    suspend fun getUsers(): List<User>
    suspend fun insertUser(user: User)
    suspend fun updateUser(user: User)
    suspend fun deleteUser(id: String)
}

// Remote data source interface
interface UserRemoteDataSource {
    suspend fun getUser(id: String): User
    suspend fun getUsers(): List<User>
    suspend fun updateUser(user: User): User
}

// Repository interface
interface UserRepository {
    suspend fun getUser(id: String): User
    suspend fun getUsers(): List<User>
    suspend fun updateUser(user: User): User
    suspend fun refreshUsers()
}

// Repository implementation
class UserRepositoryImpl(
    private val localDataSource: UserLocalDataSource,
    private val remoteDataSource: UserRemoteDataSource,
    private val networkChecker: NetworkChecker
) : UserRepository {
    
    override suspend fun getUser(id: String): User {
        // Try local first
        localDataSource.getUser(id)?.let { return it }
        
        // Fetch from remote if not found locally
        return if (networkChecker.isNetworkAvailable()) {
            val user = remoteDataSource.getUser(id)
            localDataSource.insertUser(user)
            user
        } else {
            throw Exception("No network connection and user not found locally")
        }
    }
    
    override suspend fun getUsers(): List<User> {
        return if (networkChecker.isNetworkAvailable()) {
            try {
                refreshUsers()
                localDataSource.getUsers()
            } catch (e: Exception) {
                // Fallback to local data
                localDataSource.getUsers()
            }
        } else {
            localDataSource.getUsers()
        }
    }
    
    override suspend fun updateUser(user: User): User {
        return if (networkChecker.isNetworkAvailable()) {
            val updatedUser = remoteDataSource.updateUser(user)
            localDataSource.updateUser(updatedUser)
            updatedUser
        } else {
            // Cache the update locally for later sync
            localDataSource.updateUser(user)
            user
        }
    }
    
    override suspend fun refreshUsers() {
        val remoteUsers = remoteDataSource.getUsers()
        remoteUsers.forEach { user ->
            localDataSource.insertUser(user)
        }
    }
}

// Room implementation for local data source
@Dao
interface UserDao {
    @Query("SELECT * FROM users WHERE id = :id")
    suspend fun getUser(id: String): UserEntity?
    
    @Query("SELECT * FROM users")
    suspend fun getAllUsers(): List<UserEntity>
    
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertUser(user: UserEntity)
    
    @Update
    suspend fun updateUser(user: UserEntity)
    
    @Query("DELETE FROM users WHERE id = :id")
    suspend fun deleteUser(id: String)
}

class UserLocalDataSourceImpl(
    private val userDao: UserDao
) : UserLocalDataSource {
    
    override suspend fun getUser(id: String): User? {
        return userDao.getUser(id)?.toUser()
    }
    
    override suspend fun getUsers(): List<User> {
        return userDao.getAllUsers().map { it.toUser() }
    }
    
    override suspend fun insertUser(user: User) {
        userDao.insertUser(user.toEntity())
    }
    
    override suspend fun updateUser(user: User) {
        userDao.updateUser(user.toEntity())
    }
    
    override suspend fun deleteUser(id: String) {
        userDao.deleteUser(id)
    }
}

// Retrofit implementation for remote data source
interface UserApiService {
    @GET("users/{id}")
    suspend fun getUser(@Path("id") id: String): User
    
    @GET("users")
    suspend fun getUsers(): List<User>
    
    @PUT("users/{id}")
    suspend fun updateUser(@Path("id") id: String, @Body user: User): User
}

class UserRemoteDataSourceImpl(
    private val apiService: UserApiService
) : UserRemoteDataSource {
    
    override suspend fun getUser(id: String): User {
        return apiService.getUser(id)
    }
    
    override suspend fun getUsers(): List<User> {
        return apiService.getUsers()
    }
    
    override suspend fun updateUser(user: User): User {
        return apiService.updateUser(user.id, user)
    }
}
```

**Repository with Caching Strategy:**

```kotlin
class CachingUserRepository(
    private val localDataSource: UserLocalDataSource,
    private val remoteDataSource: UserRemoteDataSource,
    private val cacheTimeout: Long = TimeUnit.HOURS.toMillis(1)
) : UserRepository {
    
    private val lastFetchTime = mutableMapOf<String, Long>()
    
    override suspend fun getUser(id: String): User {
        val cachedUser = localDataSource.getUser(id)
        val lastFetch = lastFetchTime[id] ?: 0
        val now = System.currentTimeMillis()
        
        return if (cachedUser != null && (now - lastFetch) < cacheTimeout) {
            // Return cached data if still fresh
            cachedUser
        } else {
            // Fetch fresh data
            try {
                val freshUser = remoteDataSource.getUser(id)
                localDataSource.insertUser(freshUser)
                lastFetchTime[id] = now
                freshUser
            } catch (e: Exception) {
                // Return cached data if network fails
                cachedUser ?: throw e
            }
        }
    }
    
    override suspend fun getUsers(): List<User> {
        return try {
            val remoteUsers = remoteDataSource.getUsers()
            // Update local cache
            remoteUsers.forEach { user ->
                localDataSource.insertUser(user)
                lastFetchTime[user.id] = System.currentTimeMillis()
            }
            remoteUsers
        } catch (e: Exception) {
            // Fallback to cached data
            localDataSource.getUsers()
        }
    }
}
```

**Complete MVVM Architecture Example:**

```kotlin
// ViewModel using Repository
class UserListViewModel(
    private val userRepository: UserRepository
) : ViewModel() {
    
    private val _uiState = MutableStateFlow(UserListUiState())
    val uiState: StateFlow<UserListUiState> = _uiState.asStateFlow()
    
    init {
        loadUsers()
    }
    
    fun loadUsers() {
        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(isLoading = true)
            
            try {
                val users = userRepository.getUsers()
                _uiState.value = UserListUiState(
                    users = users,
                    isLoading = false,
                    error = null
                )
            } catch (e: Exception) {
                _uiState.value = UserListUiState(
                    users = emptyList(),
                    isLoading = false,
                    error = e.message
                )
            }
        }
    }
    
    fun refreshUsers() {
        viewModelScope.launch {
            try {
                userRepository.refreshUsers()
                loadUsers()
            } catch (e: Exception) {
                _uiState.value = _uiState.value.copy(error = e.message)
            }
        }
    }
}

data class UserListUiState(
    val users: List<User> = emptyList(),
    val isLoading: Boolean = false,
    val error: String? = null
)

// Fragment with complete setup
class UserListFragment : Fragment() {
    private var _binding: FragmentUserListBinding? = null
    private val binding get() = _binding!!
    
    private lateinit var viewModel: UserListViewModel
    private lateinit var adapter: UserAdapter
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setupViewModel()
    }
    
    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        _binding = FragmentUserListBinding.inflate(inflater, container, false)
        return binding.root
    }
    
    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        
        setupRecyclerView()
        setupDataBinding()
        observeViewModel()
    }
    
    private fun setupViewModel() {
        // In real app, use dependency injection
        val repository = UserRepositoryImpl(
            localDataSource = UserLocalDataSourceImpl(userDao),
            remoteDataSource = UserRemoteDataSourceImpl(apiService),
            networkChecker = NetworkChecker(requireContext())
        )
        
        val factory = UserListViewModelFactory(repository)
        viewModel = ViewModelProvider(this, factory)[UserListViewModel::class.java]
    }
    
    private fun setupRecyclerView() {
        adapter = UserAdapter { user ->
            // Handle user click
            findNavController().navigate(
                UserListFragmentDirections.actionToUserDetail(user.id)
            )
        }
        binding.recyclerView.adapter = adapter
    }
    
    private fun setupDataBinding() {
        binding.viewModel = viewModel
        binding.lifecycleOwner = viewLifecycleOwner
    }
    
    private fun observeViewModel() {
        viewLifecycleOwner.lifecycleScope.launch {
            viewModel.uiState.collect { state ->
                adapter.submitList(state.users)
                
                binding.progressBar.isVisible = state.isLoading
                binding.errorText.isVisible = state.error != null
                binding.errorText.text = state.error
            }
        }
    }
    
    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null
    }
}
```

This comprehensive architecture setup provides a solid foundation for Android applications with proper separation of concerns, testability, and maintainability. The combination of data binding, MVVM pattern, LiveData/StateFlow, and repository pattern creates a robust and scalable architecture that follows Android development best practices.

**Important Subtopics:**

- Dependency Injection with Hilt/Dagger
- Testing strategies for MVVM architecture
- Navigation Architecture Component
- WorkManager for background tasks
- Room database integration patterns

---

