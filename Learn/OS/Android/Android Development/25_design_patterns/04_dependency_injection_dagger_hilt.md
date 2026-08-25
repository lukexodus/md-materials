## Dependency Injection (Dagger/Hilt)


Dependency Injection provides dependencies to classes rather than having them create dependencies themselves, improving testability, modularity, and code maintainability.

**Key Points:**

- **Dagger**: Compile-time dependency injection framework using annotation processing
- **Hilt**: Google's opinionated DI solution built on Dagger, specifically for Android
- Reduces boilerplate code and handles Android component lifecycle
- Supports scopes for managing object lifetimes
- Enables easy testing through dependency replacement
- Provides compile-time verification of dependency graphs

**Example with Hilt:**

```kotlin
// Application class
@HiltAndroidApp
class MyApplication : Application()

// Module for providing dependencies
@Module
@InstallIn(SingletonComponent::class)
object NetworkModule {
    
    @Provides
    @Singleton
    fun provideOkHttpClient(): OkHttpClient {
        return OkHttpClient.Builder()
            .addInterceptor(HttpLoggingInterceptor().apply {
                level = HttpLoggingInterceptor.Level.BODY
            })
            .connectTimeout(30, TimeUnit.SECONDS)
            .readTimeout(30, TimeUnit.SECONDS)
            .build()
    }
    
    @Provides
    @Singleton
    fun provideRetrofit(okHttpClient: OkHttpClient): Retrofit {
        return Retrofit.Builder()
            .baseUrl("https://api.example.com/")
            .client(okHttpClient)
            .addConverterFactory(GsonConverterFactory.create())
            .build()
    }
    
    @Provides
    @Singleton
    fun provideApiService(retrofit: Retrofit): ApiService {
        return retrofit.create(ApiService::class.java)
    }
}

@Module
@InstallIn(SingletonComponent::class)
object DatabaseModule {
    
    @Provides
    @Singleton
    fun provideAppDatabase(@ApplicationContext context: Context): AppDatabase {
        return Room.databaseBuilder(
            context,
            AppDatabase::class.java,
            "app_database"
        ).build()
    }
    
    @Provides
    fun provideUserDao(database: AppDatabase): UserDao {
        return database.userDao()
    }
}

// Abstract module for binding interfaces
@Module
@InstallIn(SingletonComponent::class)
abstract class RepositoryModule {
    
    @Binds
    abstract fun bindUserRepository(
        userRepositoryImpl: UserRepositoryImpl
    ): UserRepository
}

// Repository with injected dependencies
@Singleton
class UserRepositoryImpl @Inject constructor(
    private val apiService: ApiService,
    private val userDao: UserDao,
    @IoDispatcher private val ioDispatcher: CoroutineDispatcher
) : UserRepository {
    
    override suspend fun getUsers(): Flow<List<User>> = withContext(ioDispatcher) {
        flow {
            try {
                val remoteUsers = apiService.getUsers()
                userDao.insertUsers(remoteUsers)
                emitAll(userDao.getAllUsers().map { entities ->
                    entities.map { it.toDomain() }
                })
            } catch (e: Exception) {
                emitAll(userDao.getAllUsers().map { entities ->
                    entities.map { it.toDomain() }
                })
            }
        }
    }
}

// ViewModel with injection
@HiltViewModel
class UsersViewModel @Inject constructor(
    private val repository: UserRepository
) : ViewModel() {
    
    private val _uiState = MutableStateFlow(UsersUiState())
    val uiState: StateFlow<UsersUiState> = _uiState.asStateFlow()
    
    init {
        loadUsers()
    }
    
    private fun loadUsers() {
        viewModelScope.launch {
            repository.getUsers()
                .catch { error ->
                    _uiState.value = _uiState.value.copy(
                        isLoading = false,
                        error = error.message
                    )
                }
                .collect { users ->
                    _uiState.value = _uiState.value.copy(
                        isLoading = false,
                        users = users,
                        error = null
                    )
                }
        }
    }
}

// Activity with injection
@AndroidEntryPoint
class MainActivity : AppCompatActivity() {
    
    private val viewModel: UsersViewModel by viewModels()
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Activity implementation
    }
}

// Fragment with injection
@AndroidEntryPoint
class UsersFragment : Fragment() {
    
    private val viewModel: UsersViewModel by viewModels()
    
    @Inject
    lateinit var analytics: Analytics
    
    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        analytics.trackScreenView("users_screen")
    }
}

// Custom scopes
@Scope
@Retention(AnnotationRetention.RUNTIME)
annotation class UserScope

@Module
@InstallIn(ActivityComponent::class)
object UserModule {
    
    @Provides
    @UserScope
    fun provideUserSession(): UserSession {
        return UserSession()
    }
}

// Qualifiers for multiple implementations
@Qualifier
@Retention(AnnotationRetention.RUNTIME)
annotation class RemoteDataSource

@Qualifier
@Retention(AnnotationRetention.RUNTIME)
annotation class LocalDataSource

@Module
@InstallIn(SingletonComponent::class)
object DataSourceModule {
    
    @Provides
    @RemoteDataSource
    fun provideRemoteUserDataSource(apiService: ApiService): UserDataSource {
        return RemoteUserDataSource(apiService)
    }
    
    @Provides
    @LocalDataSource
    fun provideLocalUserDataSource(userDao: UserDao): UserDataSource {
        return LocalUserDataSource(userDao)
    }
}
```

