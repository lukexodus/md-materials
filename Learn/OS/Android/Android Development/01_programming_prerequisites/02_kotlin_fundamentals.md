## Kotlin Fundamentals


Kotlin has become Google's preferred language for Android development, offering modern language features, null safety, and seamless Java interoperability. Mastering Kotlin accelerates development and reduces common programming errors.

**Key Points:**

- Null safety and nullable types
- Data classes and sealed classes
- Extension functions and higher-order functions
- Coroutines for asynchronous programming
- Lambda expressions and functional programming
- Smart casts and type inference
- Interoperability with Java code

**Example:**

```kotlin
data class User(val id: Int, val name: String, val email: String?)

class UserRepository {
    private val users = mutableListOf<User>()
    
    suspend fun fetchUser(id: Int): User? = withContext(Dispatchers.IO) {
        // Simulated network call
        delay(1000)
        users.find { it.id == id }
    }
    
    fun addUser(name: String, email: String? = null) {
        val newId = (users.maxOfOrNull { it.id } ?: 0) + 1
        users.add(User(newId, name, email))
    }
}
```

