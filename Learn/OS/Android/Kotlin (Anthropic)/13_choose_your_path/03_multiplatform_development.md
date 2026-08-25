## Multiplatform Development


### Kotlin Multiplatform Mobile (KMM)

Kotlin Multiplatform Mobile enables sharing code between iOS and Android applications while maintaining native performance and platform-specific capabilities. KMM allows developers to write business logic once and use it across platforms.

#### Project Structure

```kotlin
// Project structure
project/
├── shared/
│   ├── src/
│   │   ├── commonMain/kotlin/
│   │   ├── commonTest/kotlin/
│   │   ├── androidMain/kotlin/
│   │   ├── androidTest/kotlin/
│   │   ├── iosMain/kotlin/
│   │   └── iosTest/kotlin/
│   └── build.gradle.kts
├── androidApp/
│   └── src/main/kotlin/
├── iosApp/
│   └── iosApp/
└── build.gradle.kts
```

#### Shared Module Configuration

```kotlin
// shared/build.gradle.kts
kotlin {
    android {
        compilations.all {
            kotlinOptions {
                jvmTarget = "1.8"
            }
        }
    }
    
    listOf(
        iosX64(),
        iosArm64(),
        iosSimulatorArm64()
    ).forEach {
        it.binaries.framework {
            baseName = "shared"
        }
    }

    sourceSets {
        val commonMain by getting {
            dependencies {
                implementation("org.jetbrains.kotlinx:kotlinx-coroutines-core:1.6.4")
                implementation("org.jetbrains.kotlinx:kotlinx-serialization-json:1.4.1")
                implementation("io.ktor:ktor-client-core:2.1.3")
            }
        }
        
        val commonTest by getting {
            dependencies {
                implementation(kotlin("test"))
            }
        }
        
        val androidMain by getting {
            dependencies {
                implementation("io.ktor:ktor-client-android:2.1.3")
            }
        }
        
        val iosMain by getting {
            dependencies {
                implementation("io.ktor:ktor-client-darwin:2.1.3")
            }
        }
    }
}
```

#### Basic KMM Components

```kotlin
// commonMain - Shared business logic
class UserRepository(private val api: UserApi) {
    suspend fun getUser(id: String): User? {
        return try {
            api.fetchUser(id)
        } catch (e: Exception) {
            null
        }
    }
    
    suspend fun saveUser(user: User): Boolean {
        return try {
            api.saveUser(user)
            true
        } catch (e: Exception) {
            false
        }
    }
}

// Shared data models
@Serializable
data class User(
    val id: String,
    val name: String,
    val email: String,
    val profileImage: String?
)

// Shared use cases
class GetUserUseCase(private val repository: UserRepository) {
    suspend operator fun invoke(id: String): Result<User> {
        return try {
            val user = repository.getUser(id)
            if (user != null) {
                Result.success(user)
            } else {
                Result.failure(Exception("User not found"))
            }
        } catch (e: Exception) {
            Result.failure(e)
        }
    }
}
```

### Sharing Code Between Platforms

#### Common Code Organization

```kotlin
// Domain layer - Pure business logic
// commonMain/domain/
interface UserRepository {
    suspend fun getUser(id: String): User?
    suspend fun saveUser(user: User): Boolean
}

class UserInteractor(
    private val repository: UserRepository,
    private val validator: UserValidator
) {
    suspend fun updateUser(user: User): UserUpdateResult {
        return when (val validation = validator.validate(user)) {
            is ValidationResult.Valid -> {
                val success = repository.saveUser(user)
                if (success) UserUpdateResult.Success else UserUpdateResult.Error
            }
            is ValidationResult.Invalid -> UserUpdateResult.ValidationError(validation.errors)
        }
    }
}

// Validation logic
class UserValidator {
    fun validate(user: User): ValidationResult {
        val errors = mutableListOf<String>()
        
        if (user.name.isBlank()) {
            errors.add("Name cannot be empty")
        }
        
        if (!user.email.contains("@")) {
            errors.add("Invalid email format")
        }
        
        return if (errors.isEmpty()) {
            ValidationResult.Valid
        } else {
            ValidationResult.Invalid(errors)
        }
    }
}

sealed class ValidationResult {
    object Valid : ValidationResult()
    data class Invalid(val errors: List<String>) : ValidationResult()
}

sealed class UserUpdateResult {
    object Success : UserUpdateResult()
    object Error : UserUpdateResult()
    data class ValidationError(val errors: List<String>) : UserUpdateResult()
}
```

#### Network Layer Sharing

```kotlin
// Common HTTP client
class ApiClient {
    private val client = HttpClient {
        install(ContentNegotiation) {
            json(Json {
                prettyPrint = true
                isLenient = true
                ignoreUnknownKeys = true
            })
        }
    }
    
    suspend fun get(url: String): String {
        return client.get(url).body()
    }
    
    suspend inline fun <reified T> getJson(url: String): T {
        return client.get(url).body()
    }
    
    suspend inline fun <reified T> postJson(url: String, data: T): String {
        return client.post(url) {
            contentType(ContentType.Application.Json)
            setBody(data)
        }.body()
    }
}

// Shared API service
class UserApiService(private val client: ApiClient) {
    suspend fun fetchUser(id: String): User {
        return client.getJson("https://api.example.com/users/$id")
    }
    
    suspend fun updateUser(user: User): User {
        return client.postJson("https://api.example.com/users/${user.id}", user)
    }
}
```

#### Database Abstraction

```kotlin
// Common database interface
interface UserDatabase {
    suspend fun insertUser(user: User)
    suspend fun getUserById(id: String): User?
    suspend fun getAllUsers(): List<User>
    suspend fun deleteUser(id: String)
}

// Repository implementation using database
class UserRepositoryImpl(
    private val database: UserDatabase,
    private val apiService: UserApiService
) : UserRepository {
    
    override suspend fun getUser(id: String): User? {
        // Try local first
        val localUser = database.getUserById(id)
        if (localUser != null) return localUser
        
        // Fetch from API
        return try {
            val remoteUser = apiService.fetchUser(id)
            database.insertUser(remoteUser)
            remoteUser
        } catch (e: Exception) {
            null
        }
    }
    
    override suspend fun saveUser(user: User): Boolean {
        return try {
            apiService.updateUser(user)
            database.insertUser(user)
            true
        } catch (e: Exception) {
            false
        }
    }
}
```

### Platform-Specific Implementations

#### Expect/Actual Mechanism

```kotlin
// commonMain - Declaration
expect class PlatformContext

expect fun getPlatformName(): String

expect class Logger {
    fun log(message: String)
    fun error(message: String, throwable: Throwable?)
}

expect class ImageLoader {
    suspend fun loadImage(url: String): PlatformImage
}

expect class PlatformImage
```

```kotlin
// androidMain - Android implementation
actual typealias PlatformContext = Context

actual fun getPlatformName(): String = "Android"

actual class Logger {
    actual fun log(message: String) {
        Log.d("KMM", message)
    }
    
    actual fun error(message: String, throwable: Throwable?) {
        Log.e("KMM", message, throwable)
    }
}

actual class ImageLoader {
    actual suspend fun loadImage(url: String): PlatformImage {
        // Use Coil or Glide for Android
        return PlatformImage(url)
    }
}

actual class PlatformImage(val url: String)
```

```kotlin
// iosMain - iOS implementation
import platform.UIKit.UIImage
import platform.Foundation.NSLog

actual typealias PlatformContext = Any

actual fun getPlatformName(): String = "iOS"

actual class Logger {
    actual fun log(message: String) {
        NSLog("KMM: $message")
    }
    
    actual fun error(message: String, throwable: Throwable?) {
        NSLog("KMM ERROR: $message - ${throwable?.message}")
    }
}

actual class ImageLoader {
    actual suspend fun loadImage(url: String): PlatformImage {
        // Use native iOS image loading
        return PlatformImage()
    }
}

actual class PlatformImage
```

#### Platform-Specific Dependencies

```kotlin
// Storage abstraction
expect class SecureStorage {
    suspend fun store(key: String, value: String)
    suspend fun retrieve(key: String): String?
    suspend fun delete(key: String)
}

// Android implementation
actual class SecureStorage(private val context: Context) {
    private val sharedPreferences = context.getSharedPreferences(
        "secure_prefs", 
        Context.MODE_PRIVATE
    )
    
    actual suspend fun store(key: String, value: String) {
        withContext(Dispatchers.IO) {
            sharedPreferences.edit().putString(key, value).apply()
        }
    }
    
    actual suspend fun retrieve(key: String): String? {
        return withContext(Dispatchers.IO) {
            sharedPreferences.getString(key, null)
        }
    }
    
    actual suspend fun delete(key: String) {
        withContext(Dispatchers.IO) {
            sharedPreferences.edit().remove(key).apply()
        }
    }
}

// iOS implementation
actual class SecureStorage {
    actual suspend fun store(key: String, value: String) {
        // Use iOS Keychain
        KeychainHelper.store(key, value)
    }
    
    actual suspend fun retrieve(key: String): String? {
        return KeychainHelper.retrieve(key)
    }
    
    actual suspend fun delete(key: String) {
        KeychainHelper.delete(key)
    }
}
```

#### Platform-Specific UI Integration

```kotlin
// Shared ViewModel-like class
class UserViewModel(
    private val getUserUseCase: GetUserUseCase,
    private val logger: Logger
) {
    private val _userState = MutableStateFlow<UserState>(UserState.Loading)
    val userState = _userState.asStateFlow()
    
    fun loadUser(id: String) {
        CoroutineScope(Dispatchers.Main).launch {
            _userState.value = UserState.Loading
            
            try {
                val result = getUserUseCase(id)
                _userState.value = when {
                    result.isSuccess -> UserState.Success(result.getOrNull()!!)
                    else -> UserState.Error(result.exceptionOrNull()?.message ?: "Unknown error")
                }
            } catch (e: Exception) {
                logger.error("Failed to load user", e)
                _userState.value = UserState.Error(e.message ?: "Unknown error")
            }
        }
    }
}

sealed class UserState {
    object Loading : UserState()
    data class Success(val user: User) : UserState()
    data class Error(val message: String) : UserState()
}
```

### Multiplatform Architecture Patterns

#### Clean Architecture with KMM

```kotlin
// Domain layer (Pure Kotlin)
// entities/User.kt
data class User(
    val id: String,
    val name: String,
    val email: String
)

// repositories/UserRepository.kt
interface UserRepository {
    suspend fun getUser(id: String): Result<User>
    suspend fun saveUser(user: User): Result<Unit>
}

// usecases/GetUserUseCase.kt
class GetUserUseCase(private val repository: UserRepository) {
    suspend operator fun invoke(id: String): Result<User> {
        return repository.getUser(id)
    }
}

// Data layer
// datasources/UserDataSource.kt
interface UserDataSource {
    suspend fun fetchUser(id: String): User
    suspend fun saveUser(user: User)
}

// repositories/UserRepositoryImpl.kt
class UserRepositoryImpl(
    private val remoteDataSource: UserDataSource,
    private val localDataSource: UserDataSource
) : UserRepository {
    
    override suspend fun getUser(id: String): Result<User> {
        return try {
            // Try local first
            val localUser = runCatching { localDataSource.fetchUser(id) }
            if (localUser.isSuccess) {
                return localUser
            }
            
            // Fetch from remote
            val remoteUser = remoteDataSource.fetchUser(id)
            localDataSource.saveUser(remoteUser)
            Result.success(remoteUser)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }
    
    override suspend fun saveUser(user: User): Result<Unit> {
        return try {
            remoteDataSource.saveUser(user)
            localDataSource.saveUser(user)
            Result.success(Unit)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }
}
```

#### Dependency Injection Pattern

```kotlin
// DI container
class DIContainer {
    // Platform-specific dependencies
    private val logger: Logger by lazy { Logger() }
    private val secureStorage: SecureStorage by lazy { SecureStorage() }
    
    // Network dependencies
    private val apiClient: ApiClient by lazy { ApiClient() }
    private val userApiService: UserApiService by lazy { UserApiService(apiClient) }
    
    // Data sources
    private val remoteUserDataSource: UserDataSource by lazy { 
        RemoteUserDataSource(userApiService) 
    }
    private val localUserDataSource: UserDataSource by lazy { 
        LocalUserDataSource(secureStorage) 
    }
    
    // Repository
    private val userRepository: UserRepository by lazy {
        UserRepositoryImpl(remoteUserDataSource, localUserDataSource)
    }
    
    // Use cases
    val getUserUseCase: GetUserUseCase by lazy { GetUserUseCase(userRepository) }
    val saveUserUseCase: SaveUserUseCase by lazy { SaveUserUseCase(userRepository) }
    
    // ViewModels
    fun createUserViewModel(): UserViewModel {
        return UserViewModel(getUserUseCase, saveUserUseCase, logger)
    }
}

// Platform-specific initialization
// Android
class AndroidDIContainer(context: Context) : DIContainer() {
    override val secureStorage: SecureStorage = SecureStorage(context)
}

// iOS
class IosDIContainer : DIContainer() {
    override val secureStorage: SecureStorage = SecureStorage()
}
```

#### State Management Pattern

```kotlin
// Shared state management
class AppState {
    private val _authState = MutableStateFlow<AuthState>(AuthState.Unauthenticated)
    val authState = _authState.asStateFlow()
    
    private val _userState = MutableStateFlow<UserState>(UserState.Loading)
    val userState = _userState.asStateFlow()
    
    fun updateAuthState(newState: AuthState) {
        _authState.value = newState
    }
    
    fun updateUserState(newState: UserState) {
        _userState.value = newState
    }
}

sealed class AuthState {
    object Unauthenticated : AuthState()
    data class Authenticated(val token: String) : AuthState()
    object Loading : AuthState()
}

// State manager
class StateManager(
    private val appState: AppState,
    private val authUseCase: AuthUseCase,
    private val getUserUseCase: GetUserUseCase
) {
    
    suspend fun login(email: String, password: String) {
        appState.updateAuthState(AuthState.Loading)
        
        val result = authUseCase.login(email, password)
        if (result.isSuccess) {
            val token = result.getOrNull()!!
            appState.updateAuthState(AuthState.Authenticated(token))
            loadCurrentUser()
        } else {
            appState.updateAuthState(AuthState.Unauthenticated)
        }
    }
    
    private suspend fun loadCurrentUser() {
        appState.updateUserState(UserState.Loading)
        
        val result = getUserUseCase.getCurrentUser()
        appState.updateUserState(
            if (result.isSuccess) {
                UserState.Success(result.getOrNull()!!)
            } else {
                UserState.Error(result.exceptionOrNull()?.message ?: "Failed to load user")
            }
        )
    }
}
```

#### Platform Integration Pattern

```kotlin
// Platform bridge
class PlatformBridge {
    fun shareText(text: String) {
        shareTextImpl(text)
    }
    
    fun openUrl(url: String) {
        openUrlImpl(url)
    }
    
    fun showNotification(title: String, message: String) {
        showNotificationImpl(title, message)
    }
}

// Expected platform implementations
expect fun shareTextImpl(text: String)
expect fun openUrlImpl(url: String)
expect fun showNotificationImpl(title: String, message: String)

// Android implementation
actual fun shareTextImpl(text: String) {
    val intent = Intent().apply {
        action = Intent.ACTION_SEND
        putExtra(Intent.EXTRA_TEXT, text)
        type = "text/plain"
    }
    // Start activity
}

actual fun openUrlImpl(url: String) {
    val intent = Intent(Intent.ACTION_VIEW, Uri.parse(url))
    // Start activity
}

actual fun showNotificationImpl(title: String, message: String) {
    // Use NotificationManager
}

// iOS implementation
actual fun shareTextImpl(text: String) {
    // Use UIActivityViewController
}

actual fun openUrlImpl(url: String) {
    // Use UIApplication.shared.open
}

actual fun showNotificationImpl(title: String, message: String) {
    // Use UNUserNotificationCenter
}
```

**Key points**:

- KMM enables sharing business logic while maintaining platform-specific UI and features
- Expect/actual mechanism provides platform-specific implementations with shared interfaces
- Clean architecture patterns work well with multiplatform development
- State management should be centralized in shared code
- Platform-specific features require careful abstraction design
- Dependency injection helps manage platform-specific dependencies

**Example** of a complete multiplatform feature:

```kotlin
// Complete feature implementation
class UserFeature(
    private val diContainer: DIContainer,
    private val platformBridge: PlatformBridge
) {
    private val viewModel = diContainer.createUserViewModel()
    
    suspend fun loadUser(id: String) {
        viewModel.loadUser(id)
    }
    
    fun shareUser(user: User) {
        platformBridge.shareText("Check out ${user.name}: ${user.email}")
    }
    
    fun openUserProfile(user: User) {
        platformBridge.openUrl("https://example.com/users/${user.id}")
    }
    
    fun observeUserState() = viewModel.userState
}
```

This architecture enables maximum code reuse while maintaining platform-specific capabilities and native performance characteristics.

---

