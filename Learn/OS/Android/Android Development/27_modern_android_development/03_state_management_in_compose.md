## State Management in Compose


Effective state management is crucial for building responsive and maintainable Compose applications. Compose provides several mechanisms for handling state, from simple local state to complex application-wide state management.

**Local State Management**

The `remember` function is used to store state that survives recomposition but is tied to the composition lifecycle. For simple state that can be lost when the composable is removed, `remember` is sufficient.

```kotlin
@Composable
fun Counter() {
    var count by remember { mutableStateOf(0) }
    
    Column {
        Text("Count: $count")
        Button(onClick = { count++ }) {
            Text("Increment")
        }
    }
}
```

For state that should survive configuration changes and process death, `rememberSaveable` provides automatic state saving and restoration.

```kotlin
@Composable
fun PersistentCounter() {
    var count by rememberSaveable { mutableStateOf(0) }
    
    // UI implementation
}
```

**State Hoisting**

State hoisting is a pattern where state is moved up to the lowest common ancestor of components that need to share it. This makes composables stateless and more reusable.

```kotlin
@Composable
fun CounterApp() {
    var count by remember { mutableStateOf(0) }
    
    CounterDisplay(
        count = count,
        onIncrement = { count++ },
        onDecrement = { count-- }
    )
}

@Composable
fun CounterDisplay(
    count: Int,
    onIncrement: () -> Unit,
    onDecrement: () -> Unit
) {
    Row {
        Button(onClick = onDecrement) { Text("-") }
        Text("$count", modifier = Modifier.padding(16.dp))
        Button(onClick = onIncrement) { Text("+") }
    }
}
```

**ViewModel Integration**

ViewModels provide a way to manage UI-related data that survives configuration changes. In Compose, ViewModels are typically injected using `viewModel()` or through dependency injection.

```kotlin
class UserProfileViewModel : ViewModel() {
    private val _userState = MutableLiveData<UserState>()
    val userState: LiveData<UserState> = _userState
    
    private val _uiState = mutableStateOf(UserProfileUiState())
    val uiState: State<UserProfileUiState> = _uiState
    
    fun loadUserProfile(userId: String) {
        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(isLoading = true)
            try {
                val user = repository.getUser(userId)
                _uiState.value = _uiState.value.copy(
                    user = user,
                    isLoading = false
                )
            } catch (e: Exception) {
                _uiState.value = _uiState.value.copy(
                    error = e.message,
                    isLoading = false
                )
            }
        }
    }
}

@Composable
fun UserProfileScreen(
    userId: String,
    viewModel: UserProfileViewModel = viewModel()
) {
    val uiState by viewModel.uiState
    
    LaunchedEffect(userId) {
        viewModel.loadUserProfile(userId)
    }
    
    when {
        uiState.isLoading -> LoadingSpinner()
        uiState.error != null -> ErrorMessage(uiState.error)
        uiState.user != null -> UserProfile(uiState.user)
    }
}
```

