## Kotlin Lambda Expressions


### Lambda Syntax and Usage

Lambda expressions are anonymous functions that can be treated as values, passed as arguments, or stored in variables. They provide a concise way to write functional code.

#### Basic Lambda Syntax

```kotlin
// Full lambda syntax
val sum = { x: Int, y: Int -> x + y }

// Lambda with single parameter
val square = { x: Int -> x * x }

// Lambda with inferred types
val numbers = listOf(1, 2, 3, 4, 5)
val doubled = numbers.map { it * 2 } // 'it' is implicit single parameter

// Multi-line lambda
val complexOperation = { x: Int, y: Int ->
    val temp = x * 2
    val result = temp + y
    result // Last expression is returned
}
```

#### Lambda Parameter Variations

```kotlin
// No parameters
val greeting = { println("Hello, World!") }

// Single parameter with 'it'
val isEven = { number: Int -> number % 2 == 0 }
val isEvenShort = { it % 2 == 0 } // Using 'it' for single parameter

// Multiple parameters
val multiply = { a: Int, b: Int -> a * b }

// Destructuring parameters
val pairs = listOf(1 to "one", 2 to "two", 3 to "three")
val descriptions = pairs.map { (number, word) -> "$number is $word" }

// Unused parameters
val processFirst = { first: String, _: String -> first.uppercase() }
```

#### Lambda Invocation

```kotlin
// Direct invocation
val result = { x: Int, y: Int -> x + y }(5, 3) // Returns 8

// Stored in variable
val operation = { x: Int, y: Int -> x * y }
val product = operation(4, 6) // Returns 24

// Using invoke operator
val calculator = { x: Int, y: Int -> x + y }
val sum = calculator.invoke(2, 3) // Returns 5
```

#### Trailing Lambda Syntax

```kotlin
// When lambda is last parameter, it can be outside parentheses
val filtered = numbers.filter({ it > 3 })
val filteredTrailing = numbers.filter { it > 3 } // Preferred style

// If lambda is only parameter, parentheses can be omitted
val doubled = numbers.map { it * 2 }

// Multiple lambdas
val result = numbers.fold(0, { acc, element -> acc + element })
val resultTrailing = numbers.fold(0) { acc, element -> acc + element }
```

**Key points:**

- Lambda syntax: `{ parameters -> body }`
- Use `it` for single parameter lambdas
- Trailing lambda syntax improves readability
- Last expression in lambda is automatically returned
- Type inference reduces boilerplate

### Higher-Order Functions

Higher-order functions are functions that take other functions as parameters or return functions. They enable powerful functional programming patterns.

#### Functions Taking Function Parameters

```kotlin
// Function accepting lambda parameter
fun processNumbers(numbers: List<Int>, operation: (Int) -> Int): List<Int> {
    return numbers.map(operation)
}

// Usage
val numbers = listOf(1, 2, 3, 4, 5)
val squared = processNumbers(numbers) { it * it }
val doubled = processNumbers(numbers) { it * 2 }

// Function with multiple function parameters
fun combineOperations(
    numbers: List<Int>,
    filter: (Int) -> Boolean,
    transform: (Int) -> Int
): List<Int> {
    return numbers.filter(filter).map(transform)
}

val result = combineOperations(
    numbers,
    { it % 2 == 0 }, // Filter even numbers
    { it * 10 }      // Multiply by 10
)
```

#### Functions Returning Functions

```kotlin
// Function returning a function
fun createMultiplier(factor: Int): (Int) -> Int {
    return { number -> number * factor }
}

val doubler = createMultiplier(2)
val tripler = createMultiplier(3)

val doubled = doubler(5) // Returns 10
val tripled = tripler(5) // Returns 15

// More complex function factory
fun createValidator(minLength: Int, maxLength: Int): (String) -> Boolean {
    return { text ->
        text.length >= minLength && text.length <= maxLength
    }
}

val passwordValidator = createValidator(8, 20)
val isValidPassword = passwordValidator("myPassword123") // Returns true
```

#### Built-in Higher-Order Functions

```kotlin
val numbers = listOf(1, 2, 3, 4, 5, 6, 7, 8, 9, 10)

// Collection operations
val evenNumbers = numbers.filter { it % 2 == 0 }
val squaredNumbers = numbers.map { it * it }
val sum = numbers.reduce { acc, n -> acc + n }
val product = numbers.fold(1) { acc, n -> acc * n }

// String operations
val text = "Hello, World!"
val processedText = text
    .filter { it.isLetter() }
    .map { it.uppercase() }
    .joinToString("")

// Scope functions
val person = Person("John", 25).apply {
    age = 26
    println("Updated age to $age")
}

val result = listOf(1, 2, 3).let { numbers ->
    numbers.map { it * 2 }.sum()
}
```

#### Custom Higher-Order Functions

```kotlin
// Retry mechanism
fun <T> retry(
    times: Int,
    operation: () -> T,
    onFailure: (Exception) -> Unit = {}
): T? {
    repeat(times) {
        try {
            return operation()
        } catch (e: Exception) {
            onFailure(e)
            if (it == times - 1) throw e
        }
    }
    return null
}

// Usage
val result = retry(3, 
    operation = { 
        // Some operation that might fail
        if (Math.random() > 0.7) "Success" else throw RuntimeException("Failed")
    },
    onFailure = { exception ->
        println("Attempt failed: ${exception.message}")
    }
)

// Timing function
fun <T> measureTime(operation: () -> T): Pair<T, Long> {
    val startTime = System.currentTimeMillis()
    val result = operation()
    val endTime = System.currentTimeMillis()
    return result to (endTime - startTime)
}

val (data, duration) = measureTime {
    (1..1000000).map { it * it }.sum()
}
```

**Key points:**

- Higher-order functions accept functions as parameters or return functions
- They enable code reuse and abstraction
- Built-in functions like `map`, `filter`, `fold` are higher-order functions
- Custom higher-order functions can encapsulate common patterns

### Function Types and Function Literals

Kotlin has a rich type system for functions, allowing them to be treated as first-class citizens.

#### Function Type Syntax

```kotlin
// Basic function types
val intToString: (Int) -> String = { it.toString() }
val twoIntsToInt: (Int, Int) -> Int = { x, y -> x + y }
val noParamsToUnit: () -> Unit = { println("Hello") }

// Function type with receiver
val stringExtension: String.() -> Int = { this.length }
val stringLength = "Hello".stringExtension() // Returns 5

// Nullable function types
val nullableFunction: ((Int) -> String)? = null
val safeCall = nullableFunction?.invoke(42)

// Function type with nullable return
val maybeInt: () -> Int? = { if (Math.random() > 0.5) 42 else null }
```

#### Function Type Parameters

```kotlin
// Function accepting function type parameter
fun applyOperation(x: Int, y: Int, operation: (Int, Int) -> Int): Int {
    return operation(x, y)
}

// Different ways to pass function arguments
val result1 = applyOperation(5, 3, { x, y -> x + y })
val result2 = applyOperation(5, 3) { x, y -> x * y }
val result3 = applyOperation(5, 3, Int::plus) // Method reference

// Higher-order function with multiple function parameters
fun processData(
    data: List<Int>,
    validator: (Int) -> Boolean,
    transformer: (Int) -> String,
    aggregator: (List<String>) -> String
): String {
    return data
        .filter(validator)
        .map(transformer)
        .let(aggregator)
}

val result = processData(
    data = listOf(1, 2, 3, 4, 5),
    validator = { it > 2 },
    transformer = { "Number: $it" },
    aggregator = { it.joinToString(", ") }
)
```

#### Function References

```kotlin
// Top-level function reference
fun isEven(number: Int): Boolean = number % 2 == 0

val numbers = listOf(1, 2, 3, 4, 5)
val evenNumbers = numbers.filter(::isEven)

// Member function reference
class Calculator {
    fun add(x: Int, y: Int): Int = x + y
    fun multiply(x: Int, y: Int): Int = x * y
}

val calc = Calculator()
val addFunction: (Int, Int) -> Int = calc::add
val multiplyFunction: (Int, Int) -> Int = calc::multiply

// Extension function reference
fun String.isPalindrome(): Boolean = this == this.reversed()
val palindromeChecker: (String) -> Boolean = String::isPalindrome

// Property reference
data class Person(val name: String, val age: Int)
val people = listOf(Person("Alice", 25), Person("Bob", 30))
val names = people.map(Person::name)
val ages = people.map(Person::age)
```

#### Function Literals with Receivers

```kotlin
// Lambda with receiver
val stringBuilder: StringBuilder.() -> Unit = {
    append("Hello")
    append(" ")
    append("World")
}

val result = StringBuilder().apply(stringBuilder).toString()

// DSL-style usage
fun html(init: StringBuilder.() -> Unit): String {
    val sb = StringBuilder()
    sb.init()
    return sb.toString()
}

val htmlContent = html {
    append("<html>")
    append("<body>")
    append("Hello, World!")
    append("</body>")
    append("</html>")
}
```

**Key points:**

- Function types use `(ParamTypes) -> ReturnType` syntax
- Function types can be nullable, have receivers, or return nullable types
- Function references provide a way to reference existing functions
- Function literals with receivers enable DSL creation

### Closures and Capturing Variables

Closures are lambda expressions that capture variables from their surrounding scope, creating powerful and flexible programming patterns.

#### Variable Capture

```kotlin
// Capturing local variables
fun createCounter(): () -> Int {
    var count = 0
    return {
        count++
        count
    }
}

val counter = createCounter()
println(counter()) // 1
println(counter()) // 2
println(counter()) // 3

// Capturing multiple variables
fun createAccumulator(initial: Int): (Int) -> Int {
    var accumulator = initial
    return { value ->
        accumulator += value
        accumulator
    }
}

val acc = createAccumulator(10)
println(acc(5)) // 15
println(acc(3)) // 18
```

#### Modifying Captured Variables

```kotlin
// Mutable variable capture
fun demonstrateCapture() {
    var capturedVariable = 0
    
    val incrementer = {
        capturedVariable++
        println("Incremented to: $capturedVariable")
    }
    
    val doubler = {
        capturedVariable *= 2
        println("Doubled to: $capturedVariable")
    }
    
    incrementer() // Incremented to: 1
    doubler()     // Doubled to: 2
    incrementer() // Incremented to: 3
}

// Capturing in loops
fun createMultipleFunctions(): List<() -> Int> {
    val functions = mutableListOf<() -> Int>()
    
    for (i in 1..5) {
        // Each lambda captures its own copy of i
        functions.add { i * i }
    }
    
    return functions
}

val squareFunctions = createMultipleFunctions()
squareFunctions.forEach { println(it()) } // 1, 4, 9, 16, 25
```

#### Closure Patterns

```kotlin
// Memoization using closures
fun <T, R> memoize(fn: (T) -> R): (T) -> R {
    val cache = mutableMapOf<T, R>()
    return { input ->
        cache.getOrPut(input) { fn(input) }
    }
}

val expensiveOperation = { x: Int ->
    Thread.sleep(1000) // Simulate expensive operation
    x * x
}

val memoizedOperation = memoize(expensiveOperation)
println(memoizedOperation(5)) // Takes 1 second, returns 25
println(memoizedOperation(5)) // Returns immediately, returns 25

// Event handling with closures
class EventManager {
    private val handlers = mutableListOf<() -> Unit>()
    
    fun addHandler(handler: () -> Unit) {
        handlers.add(handler)
    }
    
    fun triggerEvent() {
        handlers.forEach { it() }
    }
}

fun setupEventHandlers() {
    val eventManager = EventManager()
    var clickCount = 0
    var lastClickTime = 0L
    
    eventManager.addHandler {
        clickCount++
        lastClickTime = System.currentTimeMillis()
        println("Click #$clickCount at $lastClickTime")
    }
    
    eventManager.addHandler {
        if (clickCount > 5) {
            println("Too many clicks!")
        }
    }
    
    // Trigger events
    repeat(7) {
        eventManager.triggerEvent()
        Thread.sleep(100)
    }
}
```

#### Closure Scope and Lifecycle

```kotlin
// Understanding closure lifecycle
class ClosureExample {
    private var instanceVariable = "Instance"
    
    fun createClosure(): () -> String {
        val localVariable = "Local"
        var mutableLocal = 0
        
        return {
            mutableLocal++
            "Instance: $instanceVariable, Local: $localVariable, Count: $mutableLocal"
        }
    }
    
    fun demonstrateScope() {
        val closure1 = createClosure()
        val closure2 = createClosure()
        
        println(closure1()) // Instance: Instance, Local: Local, Count: 1
        println(closure1()) // Instance: Instance, Local: Local, Count: 2
        println(closure2()) // Instance: Instance, Local: Local, Count: 1
        
        instanceVariable = "Modified"
        println(closure1()) // Instance: Modified, Local: Local, Count: 3
    }
}

// Avoiding memory leaks with closures
class ResourceManager {
    private val resources = mutableListOf<String>()
    
    fun createProcessor(): (String) -> String {
        return { input ->
            // Be careful about capturing 'this' - it keeps the entire object alive
            processResource(input)
        }
    }
    
    private fun processResource(resource: String): String {
        return "Processed: $resource"
    }
}
```

#### Practical Closure Examples

```kotlin
// Configuration builder using closures
class DatabaseConfig {
    var host: String = "localhost"
    var port: Int = 5432
    var username: String = "user"
    var password: String = "password"
    
    fun configure(block: DatabaseConfig.() -> Unit) {
        this.block()
    }
}

fun createDatabaseConnection(config: DatabaseConfig.() -> Unit): DatabaseConfig {
    val dbConfig = DatabaseConfig()
    dbConfig.config()
    return dbConfig
}

val dbConfig = createDatabaseConnection {
    host = "production.db.com"
    port = 3306
    username = "admin"
    password = "secret123"
}

// Partial application using closures
fun <A, B, C> partial(fn: (A, B) -> C, a: A): (B) -> C {
    return { b -> fn(a, b) }
}

val multiply = { x: Int, y: Int -> x * y }
val multiplyByTwo = partial(multiply, 2)
val multiplyByTen = partial(multiply, 10)

println(multiplyByTwo(5))  // 10
println(multiplyByTen(5))  // 50
```

**Key points:**

- Closures capture variables from their surrounding scope
- Captured variables maintain their state between invocations
- Each closure instance has its own copy of captured variables
- Closures can modify captured mutable variables
- Be mindful of memory implications when capturing large objects

**Example:**

```kotlin
// Comprehensive example: Task scheduler with closures
class TaskScheduler {
    private val tasks = mutableListOf<() -> Unit>()
    
    fun schedule(delay: Long, task: () -> Unit) {
        val scheduledTask = {
            Thread.sleep(delay)
            task()
        }
        tasks.add(scheduledTask)
    }
    
    fun executeTasks() {
        tasks.forEach { it() }
        tasks.clear()
    }
}

fun main() {
    val scheduler = TaskScheduler()
    var taskCount = 0
    
    // Schedule tasks that capture and modify local variables
    repeat(3) { index ->
        scheduler.schedule(1000 * (index + 1)) {
            taskCount++
            println("Task $index executed (total: $taskCount)")
        }
    }
    
    // Create a closure that captures a complex state
    val messageBuilder = StringBuilder()
    val messageTask = {
        messageBuilder.append("Task completed at ${System.currentTimeMillis()}\n")
        println(messageBuilder.toString())
    }
    
    scheduler.schedule(2000, messageTask)
    scheduler.executeTasks()
}
```

**Output:**

```
Task 0 executed (total: 1)
Task 1 executed (total: 2)
Task completed at 1703123456789

Task 2 executed (total: 3)
```

Lambda expressions and closures are fundamental to Kotlin's functional programming capabilities, enabling elegant solutions to complex problems through function composition and state capture.

---

