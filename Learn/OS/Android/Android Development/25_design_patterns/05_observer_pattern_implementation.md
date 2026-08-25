## Observer Pattern Implementation


The Observer pattern enables objects to notify multiple observers about state changes, facilitating loose coupling between components and reactive programming paradigms.

**Key Points:**

- Defines one-to-many dependency between objects
- Subject maintains list of observers and notifies them of changes
- Observers implement common interface for receiving notifications
- Android implementations include LiveData, StateFlow, and custom observables
- Supports both push and pull models for data updates
- Essential for reactive UI updates and event-driven architectures

**Example:**

```kotlin
// Generic Observer Pattern Implementation
interface Observer<T> {
    fun onChanged(data: T)
}

interface Observable<T> {
    fun addObserver(observer: Observer<T>)
    fun removeObserver(observer: Observer<T>)
    fun notifyObservers(data: T)
}

class Subject<T> : Observable<T> {
    private val observers = mutableSetOf<Observer<T>>()
    private var data: T? = null
    
    override fun addObserver(observer: Observer<T>) {
        observers.add(observer)
        // Immediately notify with current data if available
        data?.let { observer.onChanged(it) }
    }
    
    override fun removeObserver(observer: Observer<T>) {
        observers.remove(observer)
    }
    
    override fun notifyObservers(data: T) {
        this.data = data
        observers.forEach { it.onChanged(data) }
    }
    
    fun updateData(newData: T) {
        notifyObservers(newData)
    }
}

// Custom Observable for Android
class AndroidObservable<T> : LifecycleObserver {
    private val observers = mutableMapOf<LifecycleOwner, Observer<T>>()
    private var value: T? = null
    
    fun observe(owner: LifecycleOwner, observer: Observer<T>) {
        owner.lifecycle.addObserver(this)
        observers[owner] = observer
        value?.let { observer.onChanged(it) }
    }
    
    fun removeObserver(owner: LifecycleOwner) {
        observers.remove(owner)
        owner.lifecycle.removeObserver(this)
    }
    
    fun setValue(newValue: T) {
        value = newValue
        notifyActiveObservers()
    }
    
    private fun notifyActiveObservers() {
        value?.let { currentValue ->
            observers.entries.removeAll { (owner, _) ->
                if (owner.lifecycle.currentState == Lifecycle.State.DESTROYED) {
                    true
                } else if (owner.lifecycle.currentState.isAtLeast(Lifecycle.State.STARTED)) {
                    observers[owner]?.onChanged(currentValue)
                    false
                } else {
                    false
                }
            }
        }
    }
    
    @OnLifecycleEvent(Lifecycle.Event.ON_DESTROY)
    fun onDestroy(owner: LifecycleOwner) {
        removeObserver(owner)
    }
}

// Event Bus Implementation
sealed class Event {
    data class UserLoggedIn(val user: User) : Event()
    data class UserLoggedOut(val userId: String) : Event()
    data class NetworkError(val error: String) : Event()
}

class EventBus {
    private val observers = mutableSetOf<Observer<Event>>()
    
    fun subscribe(observer: Observer<Event>) {
        observers.add(observer)
    }
    
    fun unsubscribe(observer: Observer<Event>) {
        observers.remove(observer)
    }
    
    fun publish(event: Event) {
        observers.forEach { it.onChanged(event) }
    }
    
    companion object {
        @Volatile
        private var INSTANCE: EventBus? = null
        
        fun getInstance(): EventBus {
            return INSTANCE ?: synchronized(this) {
                INSTANCE ?: EventBus().also { INSTANCE = it }
            }
        }
    }
}

// StateFlow Observer Pattern
class StateManager<T>(initialState: T) {
    private val _state = MutableStateFlow(initialState)
    val state: StateFlow<T> = _state.asStateFlow()
    
    fun updateState(newState: T) {
        _state.value = newState
    }
    
    fun updateState(transform: (T) -> T) {
        _state.value = transform(_state.value)
    }
}

// Repository with Observer Pattern
class UserRepository @Inject constructor(
    private val apiService: ApiService,
    private val userDao: UserDao
) {
    private val _usersState = MutableStateFlow<List<User>>(emptyList())
    val usersState: StateFlow<List<User>> = _usersState.asStateFlow()
    
    private val _loadingState = MutableStateFlow(false)
    val loadingState: StateFlow<Boolean> = _loadingState.asStateFlow()
    
    private val eventBus = EventBus.getInstance()
    
    suspend fun loadUsers() {
        _loadingState.value = true
        
        try {
            val users = apiService.getUsers()
            userDao.insertUsers(users.map { it.toEntity() })
            _usersState.value = users
            eventBus.publish(Event.UserLoggedIn(users.first()))
        } catch (e: Exception) {
            eventBus.publish(Event.NetworkError(e.message ?: "Unknown error"))
        } finally {
            _loadingState.value = false
        }
    }
    
    fun observeUsers(): Flow<List<User>> {
        return userDao.getAllUsers().map { entities ->
            entities.map { it.toDomain() }
        }
    }
}

// ViewModel using Observer Pattern
class UserListViewModel @Inject constructor(
    private val repository: UserRepository
) : ViewModel(), Observer<Event> {
    
    private val _uiState = MutableStateFlow(UserListUiState())
    val uiState: StateFlow<UserListUiState> = _uiState.asStateFlow()
    
    private val eventBus = EventBus.getInstance()
    
    init {
        eventBus.subscribe(this)
        observeUsers()
        observeLoadingState()
    }
    
    private fun observeUsers() {
        viewModelScope.launch {
            repository.usersState.collect { users ->
                _uiState.value = _uiState.value.copy(users = users)
            }
        }
    }
    
    private fun observeLoadingState() {
        viewModelScope.launch {
            repository.loadingState.collect { isLoading ->
                _uiState.value = _uiState.value.copy(isLoading = isLoading)
            }
        }
    }
    
    override fun onChanged(event: Event) {
        when (event) {
            is Event.NetworkError -> {
                _uiState.value = _uiState.value.copy(
                    error = event.error,
                    isLoading = false
                )
            }
            is Event.UserLoggedIn -> {
                _uiState.value = _uiState.value.copy(error = null)
            }
            else -> { /* Handle other events */ }
        }
    }
    
    fun loadUsers() {
        viewModelScope.launch {
            repository.loadUsers()
        }
    }
    
    override fun onCleared() {
        super.onCleared()
        eventBus.unsubscribe(this)
    }
}

data class UserListUiState(
    val users: List<User> = emptyList(),
    val isLoading: Boolean = false,
    val error: String? = null
)

// Fragment implementing Observer
class UserListFragment : Fragment(), Observer<Event> {
    private val viewModel: UserListViewModel by viewModels()
    private val eventBus = EventBus.getInstance()
    
    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        
        eventBus.subscribe(this)
        
        viewLifecycleOwner.lifecycleScope.launch {
            viewModel.uiState.collect { state ->
                updateUI(state)
            }
        }
    }
    
    override fun onChanged(event: Event) {
        when (event) {
            is Event.UserLoggedOut -> {
                // Handle user logout
                findNavController().navigate(R.id.action_to_login)
            }
            else -> { /* Handle other events */ }
        }
    }
    
    private fun updateUI(state: UserListUiState) {
        // Update UI based on state
    }
    
    override fun onDestroyView() {
        super.onDestroyView()
        eventBus.unsubscribe(this)
    }
}
```

**Conclusion:** These design patterns form the foundation of robust Android applications. MVP provides clear separation of concerns with testable presenters, while MVVM leverages Android's reactive components for lifecycle-aware data binding. Clean Architecture ensures long-term maintainability through layered separation, Dependency Injection simplifies object creation and testing, and the Observer pattern enables reactive programming paradigms essential for modern Android development.

[Inference] The effectiveness of each pattern depends on project complexity, team expertise, and specific requirements. MVVM with Clean Architecture and Hilt typically provides the best balance for most Android applications, while MVP might be preferred for simpler projects or teams transitioning from legacy codebases.

---

