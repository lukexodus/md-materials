## Advanced Class Features


### Data Classes and Their Benefits

Data classes in Kotlin are specifically designed to hold data and automatically generate common functionality that would otherwise require boilerplate code in regular classes.

### Basic Data Class Declaration

```kotlin
data class User(
    val id: Int,
    val name: String,
    val email: String,
    val age: Int
)

// Automatically generated functions:
// - equals() and hashCode()
// - toString()
// - copy()
// - componentN() functions for destructuring
```

### Generated Functions Demonstration

```kotlin
fun demonstrateDataClassFeatures() {
    val user1 = User(1, "Alice", "alice@example.com", 25)
    val user2 = User(1, "Alice", "alice@example.com", 25)
    val user3 = User(2, "Bob", "bob@example.com", 30)
    
    // toString() - automatically generated
    println(user1) // User(id=1, name=Alice, email=alice@example.com, age=25)
    
    // equals() - structural equality
    println(user1 == user2) // true (same data)
    println(user1 == user3) // false (different data)
    
    // hashCode() - consistent with equals()
    println(user1.hashCode() == user2.hashCode()) // true
    
    // copy() - create modified copies
    val olderUser = user1.copy(age = 26)
    println(olderUser) // User(id=1, name=Alice, email=alice@example.com, age=26)
    
    // Destructuring declarations
    val (id, name, email, age) = user1
    println("User $id: $name ($email), age $age")
}
```

### Advanced Data Class Features

```kotlin
data class Product(
    val id: String,
    val name: String,
    val price: Double,
    val category: String,
    val inStock: Boolean = true,
    val tags: List<String> = emptyList()
) {
    // Data classes can have custom methods
    fun isExpensive(): Boolean = price > 100.0
    
    fun addTag(tag: String): Product = copy(tags = tags + tag)
    
    // Custom validation
    init {
        require(price >= 0) { "Price cannot be negative" }
        require(name.isNotBlank()) { "Product name cannot be blank" }
    }
}

// Using advanced features
fun demonstrateAdvancedDataClass() {
    val laptop = Product(
        id = "LT001",
        name = "Gaming Laptop",
        price = 1299.99,
        category = "Electronics",
        tags = listOf("gaming", "portable")
    )
    
    val updatedLaptop = laptop
        .copy(price = 1199.99)
        .addTag("on-sale")
    
    println("Is expensive: ${laptop.isExpensive()}")
    println("Updated product: $updatedLaptop")
}
```

### Data Class with Complex Types

```kotlin
data class Address(
    val street: String,
    val city: String,
    val zipCode: String,
    val country: String
)

data class Contact(
    val email: String,
    val phone: String?
)

data class Customer(
    val id: Long,
    val name: String,
    val address: Address,
    val contact: Contact,
    val orders: List<String> = emptyList()
) {
    fun addOrder(orderId: String): Customer = copy(orders = orders + orderId)
    
    fun updateAddress(newAddress: Address): Customer = copy(address = newAddress)
    
    fun updateContact(newContact: Contact): Customer = copy(contact = newContact)
}

// Nested data class usage
fun demonstrateNestedDataClasses() {
    val customer = Customer(
        id = 1001,
        name = "John Doe",
        address = Address("123 Main St", "Springfield", "12345", "USA"),
        contact = Contact("john@example.com", "+1-555-0123")
    )
    
    val updatedCustomer = customer
        .addOrder("ORD-001")
        .addOrder("ORD-002")
        .updateAddress(customer.address.copy(street = "456 Oak Ave"))
    
    println("Original: ${customer.address.street}")
    println("Updated: ${updatedCustomer.address.street}")
    println("Orders: ${updatedCustomer.orders}")
}
```

### Sealed Classes and When Expressions

Sealed classes represent restricted class hierarchies where all subclasses are known at compile time, making them perfect for representing finite sets of possibilities.

### Basic Sealed Class Declaration

```kotlin
sealed class Result<out T> {
    data class Success<T>(val data: T) : Result<T>()
    data class Error(val exception: Exception) : Result<Nothing>()
    object Loading : Result<Nothing>()
}

// Usage with when expressions
fun handleResult(result: Result<String>) {
    when (result) {
        is Result.Success -> println("Data: ${result.data}")
        is Result.Error -> println("Error: ${result.exception.message}")
        is Result.Loading -> println("Loading...")
        // No need for else clause - compiler knows all cases are covered
    }
}
```

### Advanced Sealed Class Example

```kotlin
sealed class NetworkResponse<out T> {
    data class Success<T>(val data: T, val statusCode: Int = 200) : NetworkResponse<T>()
    data class Error(val code: Int, val message: String) : NetworkResponse<Nothing>()
    object Timeout : NetworkResponse<Nothing>()
    object NetworkUnavailable : NetworkResponse<Nothing>()
    
    // Sealed classes can have abstract methods
    abstract fun isSuccessful(): Boolean
    
    // Common functionality
    fun log() {
        when (this) {
            is Success -> println("Success: $statusCode")
            is Error -> println("Error: $code - $message")
            is Timeout -> println("Request timed out")
            is NetworkUnavailable -> println("Network unavailable")
        }
    }
}

// Implementing abstract methods in subclasses
fun NetworkResponse<*>.isSuccessful(): Boolean = when (this) {
    is NetworkResponse.Success -> true
    else -> false
}
```

### Complex Sealed Class Hierarchy

```kotlin
sealed class PaymentMethod {
    data class CreditCard(
        val number: String,
        val expiryMonth: Int,
        val expiryYear: Int,
        val cvv: String
    ) : PaymentMethod()
    
    data class PayPal(val email: String) : PaymentMethod()
    
    data class BankTransfer(
        val accountNumber: String,
        val routingNumber: String,
        val bankName: String
    ) : PaymentMethod()
    
    object Cash : PaymentMethod()
}

sealed class PaymentResult {
    data class Success(val transactionId: String, val amount: Double) : PaymentResult()
    data class Failure(val reason: String, val errorCode: Int) : PaymentResult()
    data class Pending(val estimatedTime: String) : PaymentResult()
}

fun processPayment(method: PaymentMethod, amount: Double): PaymentResult {
    return when (method) {
        is PaymentMethod.CreditCard -> {
            // Validate credit card
            if (method.number.length == 16) {
                PaymentResult.Success("TXN-${System.currentTimeMillis()}", amount)
            } else {
                PaymentResult.Failure("Invalid card number", 400)
            }
        }
        is PaymentMethod.PayPal -> {
            PaymentResult.Pending("2-3 business days")
        }
        is PaymentMethod.BankTransfer -> {
            PaymentResult.Pending("1-2 business days")
        }
        is PaymentMethod.Cash -> {
            PaymentResult.Success("CASH-${System.currentTimeMillis()}", amount)
        }
    }
}
```

### Sealed Classes with Generic Types

```kotlin
sealed class Resource<out T> {
    object Loading : Resource<Nothing>()
    data class Success<T>(val data: T) : Resource<T>()
    data class Error(val message: String, val cause: Throwable? = null) : Resource<Nothing>()
}

// Extension functions for sealed classes
fun <T> Resource<T>.onSuccess(action: (T) -> Unit): Resource<T> {
    if (this is Resource.Success) action(data)
    return this
}

fun <T> Resource<T>.onError(action: (String) -> Unit): Resource<T> {
    if (this is Resource.Error) action(message)
    return this
}

fun <T> Resource<T>.onLoading(action: () -> Unit): Resource<T> {
    if (this is Resource.Loading) action()
    return this
}

// Usage example
fun handleApiResponse(response: Resource<List<User>>) {
    response
        .onLoading { println("Loading users...") }
        .onSuccess { users -> println("Loaded ${users.size} users") }
        .onError { error -> println("Failed to load users: $error") }
}
```

### Enum Classes and Their Use Cases

Enum classes represent a finite set of constants and can contain properties, methods, and implement interfaces.

### Basic Enum Declaration

```kotlin
enum class Direction {
    NORTH, SOUTH, EAST, WEST
}

// Enum with properties
enum class Priority(val level: Int) {
    LOW(1),
    MEDIUM(2),
    HIGH(3),
    CRITICAL(4)
}

// Using enums
fun demonstrateBasicEnums() {
    val direction = Direction.NORTH
    val priority = Priority.HIGH
    
    println("Direction: $direction")
    println("Priority: $priority (level: ${priority.level})")
    
    // Enum properties
    println("All directions: ${Direction.values().joinToString()}")
    println("Priority ordinal: ${priority.ordinal}")
}
```

### Advanced Enum Features

```kotlin
enum class HttpStatus(val code: Int, val description: String) {
    OK(200, "OK"),
    CREATED(201, "Created"),
    BAD_REQUEST(400, "Bad Request"),
    UNAUTHORIZED(401, "Unauthorized"),
    NOT_FOUND(404, "Not Found"),
    INTERNAL_SERVER_ERROR(500, "Internal Server Error");
    
    // Enum methods
    fun isSuccess(): Boolean = code in 200..299
    fun isClientError(): Boolean = code in 400..499
    fun isServerError(): Boolean = code in 500..599
    
    // Companion object for enum
    companion object {
        fun fromCode(code: Int): HttpStatus? = values().find { it.code == code }
        
        fun getSuccessStatuses(): List<HttpStatus> = values().filter { it.isSuccess() }
    }
}

// Usage example
fun handleHttpResponse(statusCode: Int) {
    val status = HttpStatus.fromCode(statusCode)
    
    when (status) {
        HttpStatus.OK -> println("Request successful")
        HttpStatus.NOT_FOUND -> println("Resource not found")
        HttpStatus.INTERNAL_SERVER_ERROR -> println("Server error occurred")
        null -> println("Unknown status code: $statusCode")
        else -> println("Status: ${status.description}")
    }
}
```

### Enum with Abstract Methods

```kotlin
enum class Operation {
    ADD {
        override fun execute(a: Double, b: Double): Double = a + b
    },
    SUBTRACT {
        override fun execute(a: Double, b: Double): Double = a - b
    },
    MULTIPLY {
        override fun execute(a: Double, b: Double): Double = a * b
    },
    DIVIDE {
        override fun execute(a: Double, b: Double): Double {
            require(b != 0.0) { "Division by zero" }
            return a / b
        }
    };
    
    abstract fun execute(a: Double, b: Double): Double
    
    fun calculate(a: Double, b: Double): String {
        return try {
            "Result: ${execute(a, b)}"
        } catch (e: Exception) {
            "Error: ${e.message}"
        }
    }
}

// Using enum with abstract methods
fun demonstrateEnumOperations() {
    val operations = listOf(
        Triple(Operation.ADD, 5.0, 3.0),
        Triple(Operation.DIVIDE, 10.0, 0.0),
        Triple(Operation.MULTIPLY, 4.0, 2.5)
    )
    
    operations.forEach { (op, a, b) ->
        println("$op: ${op.calculate(a, b)}")
    }
}
```

### Enum Implementing Interfaces

```kotlin
interface Drawable {
    fun draw()
}

enum class Shape : Drawable {
    CIRCLE {
        override fun draw() = println("Drawing a circle")
    },
    SQUARE {
        override fun draw() = println("Drawing a square")
    },
    TRIANGLE {
        override fun draw() = println("Drawing a triangle")
    };
    
    // Common enum functionality
    fun getArea(size: Double): Double = when (this) {
        CIRCLE -> Math.PI * size * size
        SQUARE -> size * size
        TRIANGLE -> 0.5 * size * size
    }
}
```

### Object Declarations and Expressions

Object declarations create singleton instances, while object expressions create anonymous objects for immediate use.

### Object Declarations (Singletons)

```kotlin
// Singleton object
object DatabaseManager {
    private val connections = mutableMapOf<String, String>()
    
    fun connect(database: String): String {
        return connections.getOrPut(database) {
            "Connection to $database established"
        }
    }
    
    fun disconnect(database: String) {
        connections.remove(database)
        println("Disconnected from $database")
    }
    
    fun getActiveConnections(): List<String> = connections.keys.toList()
}

// Usage
fun demonstrateObjectDeclaration() {
    println(DatabaseManager.connect("UserDB"))
    println(DatabaseManager.connect("ProductDB"))
    println("Active connections: ${DatabaseManager.getActiveConnections()}")
    
    DatabaseManager.disconnect("UserDB")
    println("Remaining connections: ${DatabaseManager.getActiveConnections()}")
}
```

### Object Expressions (Anonymous Objects)

```kotlin
interface EventListener {
    fun onClick()
    fun onDoubleClick()
}

fun createButton(text: String): Any {
    return object : EventListener {
        val buttonText = text
        
        override fun onClick() {
            println("Button '$buttonText' clicked")
        }
        
        override fun onDoubleClick() {
            println("Button '$buttonText' double-clicked")
        }
        
        fun getButtonInfo() = "Button: $buttonText"
    }
}

// Object expressions for functional interfaces
fun demonstrateObjectExpressions() {
    val button = createButton("Submit")
    
    if (button is EventListener) {
        button.onClick()
        button.onDoubleClick()
    }
    
    // Object expression with multiple interfaces
    val multiHandler = object : EventListener, Runnable {
        override fun onClick() = println("Multi-handler click")
        override fun onDoubleClick() = println("Multi-handler double-click")
        override fun run() = println("Multi-handler running")
    }
    
    multiHandler.onClick()
    multiHandler.run()
}
```

### Object Expressions with Closures

```kotlin
fun createCounter(initial: Int = 0) = object {
    private var count = initial
    
    fun increment(): Int = ++count
    fun decrement(): Int = --count
    fun reset() { count = initial }
    fun getValue(): Int = count
}

fun createValidator(rules: List<String>) = object {
    private val validationRules = rules.toList()
    
    fun validate(input: String): Boolean {
        return validationRules.all { rule ->
            when (rule) {
                "not_empty" -> input.isNotEmpty()
                "min_length_3" -> input.length >= 3
                "contains_digit" -> input.any { it.isDigit() }
                "contains_uppercase" -> input.any { it.isUpperCase() }
                else -> true
            }
        }
    }
    
    fun getRules(): List<String> = validationRules
}
```

### Companion Objects

Companion objects provide a way to add static-like functionality to classes and can implement interfaces.

### Basic Companion Object

```kotlin
class MathUtils {
    companion object {
        const val PI = 3.14159
        
        fun calculateCircleArea(radius: Double): Double {
            return PI * radius * radius
        }
        
        fun calculateRectangleArea(width: Double, height: Double): Double {
            return width * height
        }
    }
}

// Usage - looks like static methods
fun demonstrateCompanionObject() {
    println("Circle area: ${MathUtils.calculateCircleArea(5.0)}")
    println("Rectangle area: ${MathUtils.calculateRectangleArea(4.0, 6.0)}")
    println("PI value: ${MathUtils.PI}")
}
```

### Named Companion Objects

```kotlin
class User(val name: String, val email: String) {
    companion object Factory {
        fun createFromEmail(email: String): User {
            val name = email.substringBefore("@")
            return User(name, email)
        }
        
        fun createGuest(): User {
            return User("Guest", "guest@example.com")
        }
        
        fun isValidEmail(email: String): Boolean {
            return email.contains("@") && email.contains(".")
        }
    }
}

// Usage with named companion object
fun demonstrateNamedCompanionObject() {
    val user1 = User.createFromEmail("john.doe@example.com")
    val user2 = User.Factory.createGuest()
    
    println("User 1: ${user1.name}")
    println("User 2: ${user2.name}")
    println("Valid email: ${User.isValidEmail("test@example.com")}")
}
```

### Companion Objects Implementing Interfaces

```kotlin
interface JsonSerializable {
    fun toJson(): String
    fun fromJson(json: String): JsonSerializable
}

class Product(val name: String, val price: Double) {
    companion object : JsonSerializable {
        override fun toJson(): String {
            return "Companion object doesn't serialize"
        }
        
        override fun fromJson(json: String): Product {
            // Simplified JSON parsing
            val parts = json.removeSurrounding("{", "}")
                .split(",")
                .associate { 
                    val (key, value) = it.split(":")
                    key.trim().removeSurrounding("\"") to value.trim().removeSurrounding("\"")
                }
            
            return Product(
                parts["name"] ?: "Unknown",
                parts["price"]?.toDoubleOrNull() ?: 0.0
            )
        }
        
        fun createSampleProduct(): Product {
            return Product("Sample Product", 99.99)
        }
    }
    
    fun toJson(): String {
        return """{"name": "$name", "price": "$price"}"""
    }
}

// Usage
fun demonstrateCompanionObjectInterface() {
    val product = Product.createSampleProduct()
    val json = product.toJson()
    println("JSON: $json")
    
    val deserializedProduct = Product.fromJson(json)
    println("Deserialized: ${deserializedProduct.name} - ${deserializedProduct.price}")
}
```

### Advanced Companion Object Features

```kotlin
class ApiClient private constructor(private val baseUrl: String) {
    companion object {
        @Volatile
        private var INSTANCE: ApiClient? = null
        
        fun getInstance(baseUrl: String = "https://api.example.com"): ApiClient {
            return INSTANCE ?: synchronized(this) {
                INSTANCE ?: ApiClient(baseUrl).also { INSTANCE = it }
            }
        }
        
        // Extension function on companion object
        fun ApiClient.Companion.createTestInstance(): ApiClient {
            return ApiClient("https://test.api.example.com")
        }
    }
    
    fun makeRequest(endpoint: String): String {
        return "Request to $baseUrl$endpoint"
    }
}

// Using advanced companion object features
fun demonstrateAdvancedCompanionObject() {
    val client1 = ApiClient.getInstance()
    val client2 = ApiClient.getInstance()
    val testClient = ApiClient.createTestInstance()
    
    println("Same instance: ${client1 === client2}")
    println("Request: ${client1.makeRequest("/users")}")
    println("Test request: ${testClient.makeRequest("/test")}")
}
```

**Key Points:**

- Data classes automatically generate essential methods like `equals()`, `hashCode()`, `toString()`, and `copy()`
- Sealed classes provide type-safe representation of restricted class hierarchies with exhaustive when expressions
- Enum classes offer powerful ways to represent finite sets of constants with properties and methods
- Object declarations create thread-safe singletons, while object expressions create anonymous objects
- Companion objects provide static-like functionality and can implement interfaces for advanced patterns
- These features reduce boilerplate code while maintaining type safety and expressiveness

**Next Steps:** Explore delegation patterns with `by` keyword, advanced generic constraints, and inline classes for performance optimization.

---

