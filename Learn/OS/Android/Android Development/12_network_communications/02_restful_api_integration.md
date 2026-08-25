## RESTful API Integration


RESTful API integration involves implementing standard HTTP methods (GET, POST, PUT, DELETE) to perform CRUD operations on remote resources while following REST architectural principles.

### Repository Pattern Implementation

The repository pattern provides a clean abstraction layer between data sources and business logic, making API integration more maintainable and testable.

```kotlin
class UserRepository(
    private val apiService: ApiService,
    private val userDao: UserDao
) {
    suspend fun getUsers(): Resource<List<User>> {
        return try {
            val response = apiService.getUsers()
            if (response.isSuccessful) {
                response.body()?.let { users ->
                    userDao.insertUsers(users)
                    Resource.Success(users)
                } ?: Resource.Error("Empty response")
            } else {
                Resource.Error("HTTP ${response.code()}: ${response.message()}")
            }
        } catch (e: Exception) {
            Resource.Error(e.message ?: "Unknown error occurred")
        }
    }
    
    suspend fun createUser(user: User): Resource<User> {
        return try {
            val response = apiService.createUser(user)
            if (response.isSuccessful) {
                response.body()?.let { createdUser ->
                    userDao.insertUser(createdUser)
                    Resource.Success(createdUser)
                } ?: Resource.Error("Failed to create user")
            } else {
                Resource.Error("Creation failed: ${response.message()}")
            }
        } catch (e: Exception) {
            Resource.Error(e.message ?: "Network error")
        }
    }
}

sealed class Resource<T> {
    class Success<T>(val data: T) : Resource<T>()
    class Error<T>(val message: String) : Resource<T>()
    class Loading<T> : Resource<T>()
}
```

### Authentication Handling

Modern applications require robust authentication mechanisms, typically involving JWT tokens or OAuth protocols.

```kotlin
class AuthInterceptor(private val tokenManager: TokenManager) : Interceptor {
    override fun intercept(chain: Interceptor.Chain): Response {
        val originalRequest = chain.request()
        
        val token = tokenManager.getAccessToken()
        val authenticatedRequest = if (token != null) {
            originalRequest.newBuilder()
                .header("Authorization", "Bearer $token")
                .build()
        } else {
            originalRequest
        }
        
        val response = chain.proceed(authenticatedRequest)
        
        // Handle token refresh on 401 responses
        if (response.code == 401 && token != null) {
            response.close()
            return handleTokenRefresh(chain, originalRequest)
        }
        
        return response
    }
    
    private fun handleTokenRefresh(
        chain: Interceptor.Chain, 
        originalRequest: Request
    ): Response {
        synchronized(this) {
            val newToken = tokenManager.refreshToken()
            return if (newToken != null) {
                val newRequest = originalRequest.newBuilder()
                    .header("Authorization", "Bearer $newToken")
                    .build()
                chain.proceed(newRequest)
            } else {
                // Redirect to login
                chain.proceed(originalRequest)
            }
        }
    }
}
```

