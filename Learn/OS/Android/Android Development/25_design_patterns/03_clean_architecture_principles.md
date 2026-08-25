## Clean Architecture Principles


Clean Architecture promotes separation of concerns through layered architecture, making applications more maintainable, testable, and independent of external frameworks.

**Key Points:**

- **Presentation Layer**: UI components, ViewModels, and presentation logic
- **Domain Layer**: Business logic, use cases, and domain models
- **Data Layer**: Repositories, data sources, and data models
- Dependencies point inward (Dependency Inversion Principle)
- Inner layers know nothing about outer layers
- Business logic is independent of frameworks, databases, and UI
- Use cases encapsulate specific business operations

**Example:**

```kotlin
// Domain Layer
data class User(
    val id: UserId,
    val name: String,
    val email: Email
) {
    companion object {
        fun create(id: String, name: String, email: String): User {
            return User(
                id = UserId(id),
                name = name,
                email = Email(email)
            )
        }
    }
}

@JvmInline
value class UserId(val value: String) {
    init {
        require(value.isNotBlank()) { "User ID cannot be blank" }
    }
}

@JvmInline
value class Email(val value: String) {
    init {
        require(value.contains("@")) { "Invalid email format" }
    }
}

// Domain Repository Interface
interface UserRepository {
    suspend fun getUser(userId: UserId): Result<User>
    suspend fun saveUser(user: User): Result<Unit>
}

// Use Case
class GetUserUseCase @Inject constructor(
    private val repository: UserRepository
) {
    suspend operator fun invoke(userId: String): Result<User> {
        return try {
            val userIdVO = UserId(userId)
            repository.getUser(userIdVO)
        } catch (e: IllegalArgumentException) {
            Result.failure(e)
        }
    }
}

// Data Layer
@Entity(tableName = "users")
data class UserEntity(
    @PrimaryKey val id: String,
    val name: String,
    val email: String
)

data class UserDto(
    val id: String,
    val name: String,
    val email: String
)

// Data Repository Implementation
class UserRepositoryImpl @Inject constructor(
    private val remoteDataSource: UserRemoteDataSource,
    private val localDataSource: UserLocalDataSource,
    private val mapper: UserMapper
) : UserRepository {
    
    override suspend fun getUser(userId: UserId): Result<User> {
        return try {
            // Try remote first
            val userDto = remoteDataSource.getUser(userId.value)
            val user = mapper.toDomain(userDto)
            
            // Cache locally
            localDataSource.saveUser(mapper.toEntity(user))
            
            Result.success(user)
        } catch (e: Exception) {
            // Fallback to local
            try {
                val userEntity = localDataSource.getUser(userId.value)
                val user = mapper.toDomain(userEntity)
                Result.success(user)
            } catch (localException: Exception) {
                Result.failure(e)
            }
        }
    }
    
    override suspend fun saveUser(user: User): Result<Unit> {
        return try {
            val userDto = mapper.toDto(user)
            remoteDataSource.saveUser(userDto)
            
            val userEntity = mapper.toEntity(user)
            localDataSource.saveUser(userEntity)
            
            Result.success(Unit)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }
}

// Mapper
class UserMapper @Inject constructor() {
    fun toDomain(dto: UserDto): User {
        return User.create(dto.id, dto.name, dto.email)
    }
    
    fun toDomain(entity: UserEntity): User {
        return User.create(entity.id, entity.name, entity.email)
    }
    
    fun toDto(user: User): UserDto {
        return UserDto(user.id.value, user.name, user.email.value)
    }
    
    fun toEntity(user: User): UserEntity {
        return UserEntity(user.id.value, user.name, user.email.value)
    }
}

// Presentation Layer ViewModel
class UserViewModel @Inject constructor(
    private val getUserUseCase: GetUserUseCase
) : ViewModel() {
    
    private val _uiState = MutableLiveData<UserUiState>()
    val uiState: LiveData<UserUiState> = _uiState
    
    fun loadUser(userId: String) {
        _uiState.value = UserUiState.Loading
        
        viewModelScope.launch {
            getUserUseCase(userId)
                .onSuccess { user ->
                    _uiState.value = UserUiState.Success(user)
                }
                .onFailure { error ->
                    _uiState.value = UserUiState.Error(error.message ?: "Unknown error")
                }
        }
    }
}

sealed class UserUiState {
    object Loading : UserUiState()
    data class Success(val user: User) : UserUiState()
    data class Error(val message: String) : UserUiState()
}
```

