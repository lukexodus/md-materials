## Functions


### Function Declaration and Syntax

Functions in Kotlin are declared using the `fun` keyword and follow a specific syntax pattern that emphasizes clarity and type safety.

### Basic Function Syntax

The fundamental structure of a Kotlin function includes the function keyword, name, parameters, return type, and body:

```kotlin
fun functionName(parameter1: Type1, parameter2: Type2): ReturnType {
    // function body
    return value
}
```

### Function Examples

```kotlin
// Simple function with no parameters
fun greetWorld(): String {
    return "Hello, World!"
}

// Function with parameters
fun addNumbers(a: Int, b: Int): Int {
    return a + b
}

// Function with multiple parameters of different types
fun createUserProfile(name: String, age: Int, isActive: Boolean): String {
    return "User: $name, Age: $age, Active: $isActive"
}

// Function with no return value (Unit type)
fun printMessage(message: String): Unit {
    println(message)
}

// Unit return type can be omitted
fun printMessage2(message: String) {
    println(message)
}
```

### Function Visibility Modifiers

Functions can have different visibility levels:

```kotlin
// Public function (default)
fun publicFunction() {
    println("Accessible from anywhere")
}

// Private function
private fun privateFunction() {
    println("Only accessible within the same file/class")
}

// Internal function
internal fun internalFunction() {
    println("Accessible within the same module")
}

// Protected function (only in classes)
protected fun protectedFunction() {
    println("Accessible within class and subclasses")
}
```

### Parameters and Return Types

### Parameter Types and Declarations

Kotlin functions require explicit type declarations for parameters, ensuring type safety at compile time:

```kotlin
// Basic parameter types
fun processData(
    text: String,
    number: Int,
    decimal: Double,
    flag: Boolean
): String {
    return "Processing: $text, $number, $decimal, $flag"
}

// Nullable parameters
fun handleOptionalData(data: String?): String {
    return data ?: "No data provided"
}

// Function type parameters
fun executeOperation(operation: (Int, Int) -> Int, a: Int, b: Int): Int {
    return operation(a, b)
}
```

### Return Types

Functions can return various types, including complex objects and nullable types:

```kotlin
// Returning primitive types
fun calculateArea(length: Double, width: Double): Double {
    return length * width
}

// Returning nullable types
fun findUserById(id: Int): User? {
    return if (id > 0) User(id, "John") else null
}

// Returning collections
fun getEvenNumbers(numbers: List<Int>): List<Int> {
    return numbers.filter { it % 2 == 0 }
}

// Returning custom objects
data class Result(val success: Boolean, val message: String)

fun validateInput(input: String): Result {
    return if (input.isNotBlank()) {
        Result(true, "Valid input")
    } else {
        Result(false, "Input cannot be empty")
    }
}
```

### Generic Functions

Functions can work with generic types for increased flexibility:

```kotlin
fun <T> findFirst(items: List<T>, predicate: (T) -> Boolean): T? {
    return items.firstOrNull(predicate)
}

fun <T, R> transform(input: T, transformer: (T) -> R): R {
    return transformer(input)
}
```

### Default Parameters and Named Arguments

### Default Parameters

Kotlin allows functions to have default parameter values, reducing the need for function overloading:

```kotlin
// Function with default parameters
fun createConnection(
    host: String = "localhost",
    port: Int = 8080,
    timeout: Int = 30000,
    useSSL: Boolean = false
): String {
    return "Connecting to $host:$port (SSL: $useSSL, Timeout: ${timeout}ms)"
}

// Usage examples
fun demonstrateDefaultParameters() {
    // Using all defaults
    println(createConnection())
    
    // Overriding some parameters
    println(createConnection("example.com"))
    
    // Overriding multiple parameters
    println(createConnection("example.com", 443, useSSL = true))
}
```

### Complex Default Parameters

Default parameters can be expressions and can reference other parameters:

```kotlin
fun generateReport(
    title: String,
    author: String = "Anonymous",
    timestamp: Long = System.currentTimeMillis(),
    format: String = "PDF",
    includeCharts: Boolean = format == "PDF"
): String {
    return "Report: $title by $author at $timestamp (Format: $format, Charts: $includeCharts)"
}

// Default parameters with collections
fun processItems(
    items: List<String>,
    separator: String = ", ",
    prefix: String = "[",
    suffix: String = "]",
    transform: (String) -> String = { it.uppercase() }
): String {
    return items.joinToString(separator, prefix, suffix, transform = transform)
}
```

### Named Arguments

Named arguments allow you to specify parameter values by name, improving code readability:

```kotlin
fun sendEmail(
    to: String,
    subject: String,
    body: String,
    cc: String? = null,
    bcc: String? = null,
    priority: String = "normal"
) {
    println("Sending email to $to with subject '$subject'")
}

fun demonstrateNamedArguments() {
    // Using named arguments for clarity
    sendEmail(
        to = "user@example.com",
        subject = "Important Update",
        body = "Please review the attached document",
        priority = "high"
    )
    
    // Mixed positional and named arguments
    sendEmail(
        "user@example.com",
        "Quick Question",
        body = "Can you help with this?",
        cc = "manager@example.com"
    )
}
```

### Single-Expression Functions

When a function returns a single expression, you can use the simplified syntax with the equals sign:

```kotlin
// Traditional function syntax
fun addTraditional(a: Int, b: Int): Int {
    return a + b
}

// Single-expression function
fun add(a: Int, b: Int): Int = a + b

// Type inference with single-expression functions
fun multiply(a: Int, b: Int) = a * b

// More complex single-expression functions
fun isEven(number: Int) = number % 2 == 0

fun getGreeting(name: String) = "Hello, $name!"

fun calculateDiscount(price: Double, percentage: Double) = price * (percentage / 100)
```

### Advanced Single-Expression Functions

Single-expression functions work well with functional programming concepts:

```kotlin
// Using when expression
fun getGrade(score: Int) = when {
    score >= 90 -> "A"
    score >= 80 -> "B"
    score >= 70 -> "C"
    score >= 60 -> "D"
    else -> "F"
}

// Using collection operations
fun getActiveUsers(users: List<User>) = users.filter { it.isActive }

fun getTotalPrice(items: List<Item>) = items.sumOf { it.price }

// Using let for null safety
fun processString(input: String?) = input?.let { it.trim().uppercase() } ?: "EMPTY"
```

### Local Functions and Scope

Local functions are functions defined inside other functions, providing encapsulation and code organization:

```kotlin
fun processUserData(userData: String): String {
    // Local function for validation
    fun isValidEmail(email: String): Boolean {
        return email.contains("@") && email.contains(".")
    }
    
    // Local function for formatting
    fun formatName(name: String): String {
        return name.trim().split(" ").joinToString(" ") { 
            it.lowercase().replaceFirstChar { char -> char.uppercase() }
        }
    }
    
    val parts = userData.split("|")
    if (parts.size != 2) return "Invalid format"
    
    val name = formatName(parts[0])
    val email = parts[1].trim()
    
    return if (isValidEmail(email)) {
        "User: $name, Email: $email"
    } else {
        "Invalid email format"
    }
}
```

### Local Functions with Closure

Local functions can access variables from their enclosing scope:

```kotlin
fun createCounter(initialValue: Int): () -> Int {
    var count = initialValue
    
    // Local function that captures the count variable
    fun increment(): Int {
        count++
        return count
    }
    
    return ::increment
}

fun demonstrateClosures() {
    val counter1 = createCounter(0)
    val counter2 = createCounter(100)
    
    println(counter1()) // 1
    println(counter1()) // 2
    println(counter2()) // 101
    println(counter1()) // 3
}
```

### Complex Local Function Example

```kotlin
fun analyzeText(text: String): Map<String, Any> {
    // Local function for word counting
    fun countWords(input: String): Int {
        return input.trim().split("\\s+".toRegex()).size
    }
    
    // Local function for character analysis
    fun analyzeCharacters(input: String): Map<String, Int> {
        var letters = 0
        var digits = 0
        var spaces = 0
        var others = 0
        
        for (char in input) {
            when {
                char.isLetter() -> letters++
                char.isDigit() -> digits++
                char.isWhitespace() -> spaces++
                else -> others++
            }
        }
        
        return mapOf(
            "letters" to letters,
            "digits" to digits,
            "spaces" to spaces,
            "others" to others
        )
    }
    
    // Local function for readability score
    fun calculateReadabilityScore(wordCount: Int, charCount: Int): Double {
        return if (wordCount > 0) charCount.toDouble() / wordCount else 0.0
    }
    
    val wordCount = countWords(text)
    val charAnalysis = analyzeCharacters(text)
    val readabilityScore = calculateReadabilityScore(wordCount, text.length)
    
    return mapOf(
        "wordCount" to wordCount,
        "characterAnalysis" to charAnalysis,
        "readabilityScore" to readabilityScore,
        "length" to text.length
    )
}
```

### Extension Functions Introduction

Extension functions allow you to add new functionality to existing classes without modifying their source code:

```kotlin
// Basic extension function
fun String.removeSpaces(): String {
    return this.replace(" ", "")
}

// Extension function with parameters
fun String.truncate(maxLength: Int): String {
    return if (this.length <= maxLength) this else this.substring(0, maxLength) + "..."
}

// Extension function for collections
fun List<Int>.sum(): Int {
    var total = 0
    for (item in this) {
        total += item
    }
    return total
}

// Usage examples
fun demonstrateExtensions() {
    val text = "Hello World"
    println(text.removeSpaces()) // "HelloWorld"
    println(text.truncate(5)) // "Hello..."
    
    val numbers = listOf(1, 2, 3, 4, 5)
    println(numbers.sum()) // 15
}
```

### Advanced Extension Functions

Extension functions can be more complex and work with generic types:

```kotlin
// Generic extension function
fun <T> List<T>.secondOrNull(): T? {
    return if (this.size >= 2) this[1] else null
}

// Extension function with receiver type
fun String.isValidEmail(): Boolean {
    val emailPattern = "^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
    return this.matches(emailPattern.toRegex())
}

// Extension function for custom classes
data class Person(val name: String, val age: Int)

fun Person.isAdult(): Boolean = this.age >= 18

fun Person.getAgeGroup(): String = when {
    age < 13 -> "Child"
    age < 20 -> "Teenager"
    age < 60 -> "Adult"
    else -> "Senior"
}
```

### Extension Functions with Scope

Extension functions can access only public members of the class they extend:

```kotlin
class BankAccount(private val balance: Double) {
    fun getBalance(): Double = balance
    
    fun deposit(amount: Double): BankAccount {
        return BankAccount(balance + amount)
    }
}

// Extension function - can only access public members
fun BankAccount.canAfford(amount: Double): Boolean {
    return this.getBalance() >= amount // Must use public getter
}

// Extension function with complex logic
fun BankAccount.getAccountStatus(): String {
    val balance = this.getBalance()
    return when {
        balance <= 0 -> "Overdrawn"
        balance < 100 -> "Low Balance"
        balance < 1000 -> "Normal"
        else -> "High Balance"
    }
}
```

### Nullable Receiver Extensions

Extension functions can be defined for nullable types:

```kotlin
fun String?.isNullOrEmpty(): Boolean {
    return this == null || this.isEmpty()
}

fun String?.orDefault(default: String): String {
    return this ?: default
}

// Usage
fun demonstrateNullableExtensions() {
    val nullString: String? = null
    val emptyString = ""
    val validString = "Hello"
    
    println(nullString.isNullOrEmpty()) // true
    println(emptyString.isNullOrEmpty()) // true
    println(validString.isNullOrEmpty()) // false
    
    println(nullString.orDefault("Default")) // "Default"
    println(validString.orDefault("Default")) // "Hello"
}
```

**Key Points:**

- Functions in Kotlin are first-class citizens with powerful syntax and type safety features
- Default parameters and named arguments reduce the need for function overloading and improve code readability
- Single-expression functions provide concise syntax for simple operations
- Local functions offer encapsulation and can access variables from their enclosing scope
- Extension functions allow you to add functionality to existing types without modifying their source code
- Proper use of function features leads to more maintainable and expressive code

**Next Steps:** Master higher-order functions and lambda expressions, explore scope functions (`let`, `run`, `with`, `apply`, `also`), and learn about inline functions for performance optimization.

---

