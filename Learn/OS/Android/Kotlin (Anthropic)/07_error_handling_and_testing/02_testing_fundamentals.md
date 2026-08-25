## Testing Fundamentals


### Unit Testing with JUnit

JUnit is the most widely used testing framework for Kotlin/JVM applications. Kotlin's interoperability with Java makes it seamless to use JUnit for writing comprehensive unit tests.

#### Basic JUnit Setup

To use JUnit in your Kotlin project, add the dependency to your build file:

```kotlin
// build.gradle.kts
dependencies {
    testImplementation("org.junit.jupiter:junit-jupiter:5.9.2")
    testImplementation("org.assertj:assertj-core:3.24.2")
}
```

#### Writing Basic Tests

```kotlin
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.Assertions.*
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.AfterEach
import org.junit.jupiter.api.DisplayName

class CalculatorTest {
    private lateinit var calculator: Calculator
    
    @BeforeEach
    fun setup() {
        calculator = Calculator()
    }
    
    @AfterEach
    fun teardown() {
        // Clean up resources if needed
    }
    
    @Test
    @DisplayName("Should add two positive numbers correctly")
    fun `should add two positive numbers`() {
        val result = calculator.add(5, 3)
        assertEquals(8, result)
    }
    
    @Test
    fun `should handle division by zero`() {
        assertThrows<ArithmeticException> {
            calculator.divide(10, 0)
        }
    }
    
    @Test
    fun `should multiply numbers correctly`() {
        val testCases = listOf(
            Triple(2, 3, 6),
            Triple(-2, 3, -6),
            Triple(0, 5, 0)
        )
        
        testCases.forEach { (a, b, expected) ->
            assertEquals(expected, calculator.multiply(a, b))
        }
    }
}
```

#### Parameterized Tests

JUnit 5 supports parameterized tests, which are particularly useful for testing multiple scenarios:

```kotlin
import org.junit.jupiter.params.ParameterizedTest
import org.junit.jupiter.params.provider.ValueSource
import org.junit.jupiter.params.provider.CsvSource
import org.junit.jupiter.params.provider.MethodSource

class ValidationTest {
    
    @ParameterizedTest
    @ValueSource(strings = ["user@example.com", "test@domain.org", "admin@company.co.uk"])
    fun `should validate correct email formats`(email: String) {
        assertTrue(EmailValidator.isValid(email))
    }
    
    @ParameterizedTest
    @CsvSource(
        "1, 1, 2",
        "2, 3, 5",
        "-1, 1, 0",
        "0, 0, 0"
    )
    fun `should add numbers correctly`(a: Int, b: Int, expected: Int) {
        assertEquals(expected, calculator.add(a, b))
    }
    
    @ParameterizedTest
    @MethodSource("passwordProvider")
    fun `should validate password strength`(password: String, expectedStrength: PasswordStrength) {
        assertEquals(expectedStrength, PasswordValidator.checkStrength(password))
    }
    
    companion object {
        @JvmStatic
        fun passwordProvider() = listOf(
            Arguments.of("123", PasswordStrength.WEAK),
            Arguments.of("password123", PasswordStrength.MEDIUM),
            Arguments.of("P@ssw0rd123!", PasswordStrength.STRONG)
        )
    }
}
```

### Kotlin-Specific Testing Features

#### Testing Data Classes

Kotlin's data classes provide automatic `equals()`, `hashCode()`, and `toString()` implementations that make testing more straightforward:

```kotlin
data class User(val id: Long, val name: String, val email: String)

class UserTest {
    @Test
    fun `should create user with correct properties`() {
        val user = User(1L, "John Doe", "john@example.com")
        
        assertEquals(1L, user.id)
        assertEquals("John Doe", user.name)
        assertEquals("john@example.com", user.email)
    }
    
    @Test
    fun `should compare users by value`() {
        val user1 = User(1L, "John", "john@example.com")
        val user2 = User(1L, "John", "john@example.com")
        
        assertEquals(user1, user2)
        assertEquals(user1.hashCode(), user2.hashCode())
    }
    
    @Test
    fun `should create copy with modified properties`() {
        val originalUser = User(1L, "John", "john@example.com")
        val updatedUser = originalUser.copy(name = "Jane")
        
        assertEquals("Jane", updatedUser.name)
        assertEquals(originalUser.id, updatedUser.id)
        assertEquals(originalUser.email, updatedUser.email)
    }
}
```

#### Testing Extension Functions

Extension functions can be tested like regular functions:

```kotlin
fun String.isValidEmail(): Boolean {
    return contains("@") && contains(".")
}

class ExtensionFunctionTest {
    @Test
    fun `should validate email format using extension function`() {
        assertTrue("user@example.com".isValidEmail())
        assertFalse("invalid-email".isValidEmail())
        assertFalse("user@".isValidEmail())
    }
}
```

#### Testing Sealed Classes

Sealed classes are excellent for representing finite sets of possibilities and can be tested comprehensively:

```kotlin
sealed class Result<T> {
    data class Success<T>(val data: T) : Result<T>()
    data class Error<T>(val message: String) : Result<T>()
    data class Loading<T>(val progress: Int = 0) : Result<T>()
}

class ResultProcessor {
    fun <T> processResult(result: Result<T>): String {
        return when (result) {
            is Result.Success -> "Success: ${result.data}"
            is Result.Error -> "Error: ${result.message}"
            is Result.Loading -> "Loading: ${result.progress}%"
        }
    }
}

class ResultProcessorTest {
    private val processor = ResultProcessor()
    
    @Test
    fun `should handle success result`() {
        val result = Result.Success("Test data")
        assertEquals("Success: Test data", processor.processResult(result))
    }
    
    @Test
    fun `should handle error result`() {
        val result = Result.Error<String>("Network error")
        assertEquals("Error: Network error", processor.processResult(result))
    }
    
    @Test
    fun `should handle loading result`() {
        val result = Result.Loading<String>(50)
        assertEquals("Loading: 50%", processor.processResult(result))
    }
}
```

#### Testing Nullable Types

Kotlin's null safety features require specific testing approaches:

```kotlin
class UserService {
    fun findUserById(id: Long): User? {
        // Simulate database lookup
        return if (id > 0) User(id, "User $id", "user$id@example.com") else null
    }
    
    fun getUserDisplayName(user: User?): String {
        return user?.name ?: "Unknown User"
    }
}

class UserServiceTest {
    private val userService = UserService()
    
    @Test
    fun `should return user when id is valid`() {
        val user = userService.findUserById(1L)
        assertNotNull(user)
        assertEquals("User 1", user?.name)
    }
    
    @Test
    fun `should return null when id is invalid`() {
        val user = userService.findUserById(-1L)
        assertNull(user)
    }
    
    @Test
    fun `should handle null user gracefully`() {
        val displayName = userService.getUserDisplayName(null)
        assertEquals("Unknown User", displayName)
    }
}
```

### Mocking and Test Doubles

Test doubles are essential for isolating units under test from their dependencies. Kotlin works well with popular mocking frameworks.

#### MockK Framework

MockK is a Kotlin-native mocking framework that provides excellent support for Kotlin features:

```kotlin
// build.gradle.kts
dependencies {
    testImplementation("io.mockk:mockk:1.13.4")
}
```

```kotlin
import io.mockk.*

interface EmailService {
    fun sendEmail(to: String, subject: String, body: String): Boolean
}

class NotificationService(private val emailService: EmailService) {
    fun sendWelcomeEmail(user: User): Boolean {
        return emailService.sendEmail(
            to = user.email,
            subject = "Welcome!",
            body = "Welcome ${user.name}!"
        )
    }
}

class NotificationServiceTest {
    private val emailService = mockk<EmailService>()
    private val notificationService = NotificationService(emailService)
    
    @Test
    fun `should send welcome email successfully`() {
        val user = User(1L, "John", "john@example.com")
        
        every { emailService.sendEmail(any(), any(), any()) } returns true
        
        val result = notificationService.sendWelcomeEmail(user)
        
        assertTrue(result)
        verify { 
            emailService.sendEmail(
                to = "john@example.com",
                subject = "Welcome!",
                body = "Welcome John!"
            )
        }
    }
    
    @Test
    fun `should handle email sending failure`() {
        val user = User(1L, "John", "john@example.com")
        
        every { emailService.sendEmail(any(), any(), any()) } returns false
        
        val result = notificationService.sendWelcomeEmail(user)
        
        assertFalse(result)
    }
}
```

#### Mocking Kotlin Objects and Singletons

MockK can mock Kotlin objects and singletons:

```kotlin
object ConfigurationManager {
    fun getProperty(key: String): String? {
        // Read from configuration file
        return System.getProperty(key)
    }
}

class DatabaseConnection {
    fun connect(): String {
        val host = ConfigurationManager.getProperty("db.host") ?: "localhost"
        val port = ConfigurationManager.getProperty("db.port") ?: "5432"
        return "Connected to $host:$port"
    }
}

class DatabaseConnectionTest {
    @Test
    fun `should connect with custom configuration`() {
        mockkObject(ConfigurationManager)
        
        every { ConfigurationManager.getProperty("db.host") } returns "prod-server"
        every { ConfigurationManager.getProperty("db.port") } returns "3306"
        
        val connection = DatabaseConnection()
        val result = connection.connect()
        
        assertEquals("Connected to prod-server:3306", result)
        
        unmockkObject(ConfigurationManager)
    }
}
```

#### Spying on Real Objects

Sometimes you need to spy on real objects to verify interactions while keeping the original behavior:

```kotlin
class FileLogger {
    fun log(message: String) {
        println("Logging: $message")
        // Write to file
    }
}

class AuditService {
    private val logger = FileLogger()
    
    fun auditUserAction(userId: Long, action: String) {
        logger.log("User $userId performed: $action")
    }
}

class AuditServiceTest {
    @Test
    fun `should log user actions`() {
        val auditService = spyk(AuditService())
        
        auditService.auditUserAction(123L, "login")
        
        verify { auditService.auditUserAction(123L, "login") }
    }
}
```

### Testing Coroutines (Introduction)

Kotlin coroutines require special consideration when testing due to their asynchronous nature.

#### Basic Coroutine Testing

```kotlin
// build.gradle.kts
dependencies {
    testImplementation("org.jetbrains.kotlinx:kotlinx-coroutines-test:1.7.3")
}
```

```kotlin
import kotlinx.coroutines.*
import kotlinx.coroutines.test.*
import org.junit.jupiter.api.Test
import kotlin.test.assertEquals

class UserRepository {
    suspend fun fetchUser(id: Long): User {
        delay(1000) // Simulate network delay
        return User(id, "User $id", "user$id@example.com")
    }
}

class UserRepositoryTest {
    private val repository = UserRepository()
    
    @Test
    fun `should fetch user data`() = runTest {
        val user = repository.fetchUser(1L)
        
        assertEquals(1L, user.id)
        assertEquals("User 1", user.name)
    }
}
```

#### Testing with TestCoroutineScheduler

For more control over coroutine execution timing:

```kotlin
class DataSyncService {
    suspend fun syncData(): String {
        delay(5000) // Long operation
        return "Data synchronized"
    }
    
    suspend fun performPeriodicSync() {
        while (true) {
            syncData()
            delay(60000) // Wait 1 minute
        }
    }
}

class DataSyncServiceTest {
    private val service = DataSyncService()
    
    @Test
    fun `should complete sync operation`() = runTest {
        val result = service.syncData()
        assertEquals("Data synchronized", result)
    }
    
    @Test
    fun `should handle periodic sync timing`() = runTest {
        val job = launch {
            service.performPeriodicSync()
        }
        
        // Advance time by 5 seconds to complete first sync
        testScheduler.advanceTimeBy(5000)
        
        // Advance time by 1 minute to trigger second sync
        testScheduler.advanceTimeBy(60000)
        
        job.cancel()
    }
}
```

#### Testing Coroutine Exception Handling

```kotlin
class NetworkService {
    suspend fun fetchData(url: String): String {
        if (url.isEmpty()) {
            throw IllegalArgumentException("URL cannot be empty")
        }
        
        delay(1000)
        return "Data from $url"
    }
}

class NetworkServiceTest {
    private val service = NetworkService()
    
    @Test
    fun `should throw exception for empty URL`() = runTest {
        assertThrows<IllegalArgumentException> {
            service.fetchData("")
        }
    }
    
    @Test
    fun `should handle successful data fetch`() = runTest {
        val result = service.fetchData("https://api.example.com")
        assertEquals("Data from https://api.example.com", result)
    }
}
```

### Test Organization and Best Practices

#### Test Structure

Follow the Arrange-Act-Assert (AAA) pattern:

```kotlin
class OrderServiceTest {
    @Test
    fun `should calculate total price with tax`() {
        // Arrange
        val order = Order(
            items = listOf(
                OrderItem("Product A", 10.0, 2),
                OrderItem("Product B", 5.0, 1)
            )
        )
        val taxRate = 0.1
        val orderService = OrderService()
        
        // Act
        val total = orderService.calculateTotal(order, taxRate)
        
        // Assert
        assertEquals(27.5, total, 0.01)
    }
}
```

#### Test Naming Conventions

Use descriptive test names that clearly indicate the scenario being tested:

```kotlin
class UserValidatorTest {
    @Test
    fun `should return true when email has valid format`() { }
    
    @Test
    fun `should return false when email is missing at symbol`() { }
    
    @Test
    fun `should throw exception when email is null`() { }
}
```

#### Testing Edge Cases

Always test boundary conditions and edge cases:

```kotlin
class StringUtilsTest {
    @Test
    fun `should handle empty string`() {
        assertEquals("", StringUtils.capitalize(""))
    }
    
    @Test
    fun `should handle null string`() {
        assertNull(StringUtils.capitalize(null))
    }
    
    @Test
    fun `should handle single character string`() {
        assertEquals("A", StringUtils.capitalize("a"))
    }
}
```

**Key points:**

- Use JUnit 5 for modern testing features
- Leverage Kotlin's language features in tests (data classes, extension functions, etc.)
- Choose appropriate mocking frameworks (MockK for Kotlin-specific features)
- Use `runTest` for coroutine testing
- Follow consistent naming conventions and test structure
- Test both happy paths and edge cases

**Conclusion:** Effective testing in Kotlin combines JUnit's robust testing framework with Kotlin's expressive language features. By understanding how to test Kotlin-specific constructs like data classes, sealed classes, and coroutines, you can create comprehensive test suites that ensure code reliability and maintainability. The combination of proper mocking techniques and coroutine testing tools provides the foundation for testing even complex asynchronous applications.

---

