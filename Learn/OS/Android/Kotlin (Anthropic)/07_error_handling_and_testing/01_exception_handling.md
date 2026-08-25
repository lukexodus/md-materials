## Exception Handling


### Try-Catch Expressions

Kotlin treats exception handling as expressions, meaning try-catch blocks can return values. This functional approach allows for more concise and expressive error handling compared to traditional statement-based systems.

```kotlin
val result = try {
    someRiskyOperation()
} catch (e: NumberFormatException) {
    "Invalid number format"
} catch (e: IllegalArgumentException) {
    "Invalid argument"
} finally {
    println("Cleanup operations")
}
```

The try expression evaluates to the last expression in the try block if no exception occurs, or the last expression in the matching catch block if an exception is caught. The finally block executes regardless of whether an exception occurs.

**Key points:**

- Try-catch can be used as expressions that return values
- Multiple catch blocks can handle different exception types
- The finally block is optional and always executes
- If no catch block matches the exception, it propagates up the call stack

### Exception Hierarchy

Kotlin's exception hierarchy mirrors Java's structure, with all exceptions inheriting from `Throwable`. The main distinction is between checked and unchecked exceptions, though Kotlin doesn't enforce checked exception handling at compile time.

```kotlin
// All exceptions inherit from Throwable
open class Throwable
├── Error (unchecked)
├── Exception
    ├── RuntimeException (unchecked)
    └── Other exceptions (checked in Java, but not enforced in Kotlin)
```

### Throwing Exceptions

Exceptions in Kotlin are thrown using the `throw` keyword. The throw expression has the type `Nothing`, which helps with type inference and control flow analysis.

```kotlin
fun validateAge(age: Int): Int {
    if (age < 0) {
        throw IllegalArgumentException("Age cannot be negative")
    }
    return age
}

// Using throw as an expression
val age = input.toIntOrNull() ?: throw IllegalArgumentException("Invalid age format")

// Multiple validation checks
fun processUser(name: String?, age: Int?) {
    val validName = name ?: throw IllegalArgumentException("Name is required")
    val validAge = age?.takeIf { it >= 0 } ?: throw IllegalArgumentException("Valid age required")
    
    // Process user...
}
```

### Custom Exception Classes

Creating custom exceptions allows for more specific error handling and better error reporting. Custom exceptions typically extend existing exception classes and can include additional context information.

```kotlin
// Simple custom exception
class NetworkException(message: String) : Exception(message)

// Exception with additional context
class ValidationException(
    message: String,
    val field: String,
    val value: Any?,
    cause: Throwable? = null
) : Exception(message, cause) {
    override fun toString(): String {
        return "ValidationException(field='$field', value=$value, message='$message')"
    }
}

// Exception with factory methods
class DatabaseException private constructor(
    message: String,
    val errorCode: Int,
    cause: Throwable? = null
) : Exception(message, cause) {
    
    companion object {
        fun connectionFailed(cause: Throwable) = 
            DatabaseException("Database connection failed", 1001, cause)
            
        fun queryTimeout(query: String) = 
            DatabaseException("Query timeout: $query", 1002)
            
        fun constraintViolation(constraint: String) = 
            DatabaseException("Constraint violation: $constraint", 1003)
    }
}
```

### Exception Handling Patterns

#### Elvis Operator with Exceptions

```kotlin
fun getUser(id: String): User {
    return userRepository.findById(id) 
        ?: throw UserNotFoundException("User not found: $id")
}
```

#### When Expression for Exception Handling

```kotlin
fun handleException(e: Exception): String {
    return when (e) {
        is NetworkException -> "Network error: ${e.message}"
        is ValidationException -> "Validation failed for ${e.field}: ${e.message}"
        is DatabaseException -> "Database error (${e.errorCode}): ${e.message}"
        else -> "Unknown error: ${e.message}"
    }
}
```

#### Result Pattern

```kotlin
sealed class Result<T> {
    data class Success<T>(val value: T) : Result<T>()
    data class Error<T>(val exception: Exception) : Result<T>()
}

fun safeOperation(): Result<String> {
    return try {
        val result = riskyOperation()
        Result.Success(result)
    } catch (e: Exception) {
        Result.Error(e)
    }
}
```

### Resource Management and Use Function

The `use` function provides automatic resource management, similar to Java's try-with-resources. It ensures resources are properly closed even if exceptions occur.

```kotlin
// Basic use function
file.inputStream().use { input ->
    // Process input stream
    input.read()
} // Stream is automatically closed

// Multiple resources
fun copyFile(source: File, destination: File) {
    source.inputStream().use { input ->
        destination.outputStream().use { output ->
            input.copyTo(output)
        }
    }
}
```

#### Custom Use Function Implementation

```kotlin
inline fun <T : AutoCloseable?, R> T.use(block: (T) -> R): R {
    var exception: Throwable? = null
    try {
        return block(this)
    } catch (e: Throwable) {
        exception = e
        throw e
    } finally {
        when {
            this == null -> {}
            exception == null -> close()
            else -> {
                try {
                    close()
                } catch (closeException: Throwable) {
                    exception.addSuppressed(closeException)
                }
            }
        }
    }
}
```

#### Database Connection Example

```kotlin
class DatabaseConnection : AutoCloseable {
    fun query(sql: String): ResultSet = TODO()
    override fun close() = TODO()
}

fun getUserData(userId: String): User {
    return DatabaseConnection().use { connection ->
        val resultSet = connection.query("SELECT * FROM users WHERE id = ?")
        User.fromResultSet(resultSet)
    } // Connection automatically closed
}
```

### Advanced Exception Handling

#### Suppressed Exceptions

```kotlin
fun demonstrateSuppressedExceptions() {
    try {
        AutoCloseable {
            throw RuntimeException("Resource cleanup failed")
        }.use {
            throw IllegalStateException("Main operation failed")
        }
    } catch (e: IllegalStateException) {
        println("Main exception: ${e.message}")
        e.suppressed.forEach { suppressed ->
            println("Suppressed: ${suppressed.message}")
        }
    }
}
```

#### Exception Chaining

```kotlin
fun processData(data: String) {
    try {
        parseData(data)
    } catch (e: ParseException) {
        throw ProcessingException("Failed to process data", e)
    }
}
```

#### Rethrowing with Context

```kotlin
fun serviceMethod() {
    try {
        lowLevelOperation()
    } catch (e: SQLException) {
        throw ServiceException("Service operation failed", e)
    }
}
```

### Best Practices

#### Exception Handling Strategy

```kotlin
// Don't catch exceptions you can't handle
fun badExample() {
    try {
        riskyOperation()
    } catch (e: Exception) {
        // Bad: Swallowing all exceptions
        println("Something went wrong")
    }
}

// Good: Handle specific exceptions appropriately
fun goodExample() {
    try {
        riskyOperation()
    } catch (e: ValidationException) {
        // Handle validation errors
        showValidationError(e)
    } catch (e: NetworkException) {
        // Handle network errors
        showNetworkError(e)
    }
    // Let other exceptions propagate
}
```

#### Fail-Fast Principle

```kotlin
class User(name: String, age: Int) {
    init {
        require(name.isNotBlank()) { "Name cannot be blank" }
        require(age >= 0) { "Age cannot be negative" }
    }
}
```

#### Precondition Checks

```kotlin
fun divide(a: Int, b: Int): Int {
    check(b != 0) { "Division by zero" }
    return a / b
}

fun processItems(items: List<String>) {
    checkNotNull(items) { "Items list cannot be null" }
    require(items.isNotEmpty()) { "Items list cannot be empty" }
    // Process items
}
```

**Example** of comprehensive exception handling:

```kotlin
class UserService {
    fun createUser(userData: UserData): User {
        return try {
            // Validate input
            validateUserData(userData)
            
            // Create user
            val user = User(userData.name, userData.email, userData.age)
            
            // Save to database
            userRepository.save(user)
            
            user
        } catch (e: ValidationException) {
            logger.warn("User validation failed: ${e.message}")
            throw UserCreationException("Invalid user data", e)
        } catch (e: DatabaseException) {
            logger.error("Database operation failed", e)
            throw UserCreationException("Failed to save user", e)
        } catch (e: Exception) {
            logger.error("Unexpected error during user creation", e)
            throw UserCreationException("User creation failed", e)
        }
    }
    
    private fun validateUserData(userData: UserData) {
        if (userData.name.isBlank()) {
            throw ValidationException("Name is required", "name", userData.name)
        }
        if (!userData.email.matches(EMAIL_REGEX)) {
            throw ValidationException("Invalid email format", "email", userData.email)
        }
        if (userData.age < 0) {
            throw ValidationException("Age cannot be negative", "age", userData.age)
        }
    }
}
```

**Conclusion**

Exception handling in Kotlin provides a powerful and flexible system for managing errors. The expression-based approach, combined with features like the `use` function and custom exception classes, enables developers to write robust, maintainable code. The key is to handle exceptions at the appropriate level, provide meaningful error messages, and ensure resources are properly managed.

---

