## Delegation and Properties


### Property Delegation

Kotlin's property delegation mechanism allows you to delegate the implementation of property getters and setters to another object using the `by` keyword. This powerful feature enables code reuse and separation of concerns by extracting common property behavior into reusable delegates.

The syntax for property delegation is straightforward:

```kotlin
class Example {
    var p: String by Delegate()
}
```

When you delegate a property, Kotlin generates code that calls the delegate's `getValue()` and `setValue()` methods (for var properties) or just `getValue()` (for val properties). The delegate must implement the appropriate operator functions.

### Built-in Delegates

#### Lazy Properties

Lazy properties are computed only on first access and then cached for subsequent calls. This is particularly useful for expensive computations or when you want to defer initialization until actually needed.

```kotlin
class DataProcessor {
    val expensiveData: List<String> by lazy {
        println("Computing expensive data...")
        // Simulate expensive computation
        Thread.sleep(1000)
        listOf("data1", "data2", "data3")
    }
}

fun main() {
    val processor = DataProcessor()
    println("Processor created")
    println(processor.expensiveData) // Computation happens here
    println(processor.expensiveData) // Uses cached value
}
```

**Key points:**

- Lazy properties are thread-safe by default
- You can specify thread safety mode: `LazyThreadSafetyMode.SYNCHRONIZED`, `PUBLICATION`, or `NONE`
- The lambda is executed at most once

#### Observable Properties

Observable properties notify listeners when their value changes. This is useful for implementing reactive patterns or data binding.

```kotlin
import kotlin.properties.Delegates

class User {
    var name: String by Delegates.observable("Initial") { property, oldValue, newValue ->
        println("Property ${property.name} changed from $oldValue to $newValue")
    }
    
    var age: Int by Delegates.vetoable(0) { property, oldValue, newValue ->
        println("Attempting to change ${property.name} from $oldValue to $newValue")
        newValue >= 0 // Only allow non-negative ages
    }
}

fun main() {
    val user = User()
    user.name = "John" // Triggers observer
    user.age = 25      // Triggers vetoable, change allowed
    user.age = -5      // Triggers vetoable, change rejected
    println("Final age: ${user.age}")
}
```

#### NotNull Delegate

The `notNull()` delegate is useful when you need to initialize a property later but want to ensure it's not null when accessed.

```kotlin
class Configuration {
    var databaseUrl: String by Delegates.notNull()
    
    fun initialize() {
        databaseUrl = "jdbc:mysql://localhost:3306/mydb"
    }
}
```

### Class Delegation

Class delegation allows a class to delegate the implementation of interfaces to another object. This provides a clean alternative to inheritance and enables composition-based design.

```kotlin
interface Printer {
    fun print(message: String)
}

class ConsolePrinter : Printer {
    override fun print(message: String) {
        println("Console: $message")
    }
}

class FilePrinter(private val filename: String) : Printer {
    override fun print(message: String) {
        println("File($filename): $message")
    }
}

class Logger(printer: Printer) : Printer by printer {
    fun logWithTimestamp(message: String) {
        val timestamp = System.currentTimeMillis()
        print("[$timestamp] $message")
    }
}

fun main() {
    val consoleLogger = Logger(ConsolePrinter())
    val fileLogger = Logger(FilePrinter("app.log"))
    
    consoleLogger.print("Hello World")
    fileLogger.logWithTimestamp("Application started")
}
```

**Key points:**

- Class delegation works with interfaces
- You can override specific methods while delegating others
- The delegated object is stored as a private field
- Multiple interfaces can be delegated to different objects

### Custom Property Delegates

You can create custom property delegates by implementing the `ReadOnlyProperty` interface (for val properties) or `ReadWriteProperty` interface (for var properties), or by providing operator functions.

#### Creating a Custom Delegate with Operator Functions

```kotlin
class LoggingDelegate<T>(private var value: T) {
    operator fun getValue(thisRef: Any?, property: KProperty<*>): T {
        println("Getting value of ${property.name}: $value")
        return value
    }
    
    operator fun setValue(thisRef: Any?, property: KProperty<*>, value: T) {
        println("Setting value of ${property.name} from ${this.value} to $value")
        this.value = value
    }
}

class Example {
    var data: String by LoggingDelegate("initial")
}

fun main() {
    val example = Example()
    println(example.data)
    example.data = "updated"
    println(example.data)
}
```

#### Map-based Delegates

Kotlin provides built-in support for delegating properties to Map objects, which is useful for dynamic property access or JSON-like data structures.

```kotlin
class Person(private val map: MutableMap<String, Any>) {
    var name: String by map
    var age: Int by map
    
    constructor(name: String, age: Int) : this(mutableMapOf(
        "name" to name,
        "age" to age
    ))
}

fun main() {
    val person = Person("Alice", 30)
    println("Name: ${person.name}, Age: ${person.age}")
    
    person.name = "Bob"
    person.age = 25
    println("Updated - Name: ${person.name}, Age: ${person.age}")
}
```

### Advanced Delegate Patterns

#### Delegate Providers

For more complex scenarios, you can create delegate providers that create different delegates based on the property being delegated.

```kotlin
class ResourceDelegate<T>(private val key: String, private val defaultValue: T) {
    operator fun getValue(thisRef: Any?, property: KProperty<*>): T {
        // Simulate resource loading
        return loadResource(key) ?: defaultValue
    }
    
    private fun loadResource(key: String): T? {
        // Simulate resource loading logic
        @Suppress("UNCHECKED_CAST")
        return when (key) {
            "username" -> "admin" as T
            "timeout" -> 30 as T
            else -> null
        }
    }
}

fun resource(key: String, defaultValue: String) = ResourceDelegate(key, defaultValue)
fun resource(key: String, defaultValue: Int) = ResourceDelegate(key, defaultValue)

class AppConfig {
    val username: String by resource("username", "guest")
    val timeout: Int by resource("timeout", 10)
}
```

#### Conditional Delegates

You can create delegates that behave differently based on conditions.

```kotlin
class ConditionalDelegate<T>(
    private val condition: () -> Boolean,
    private val trueDelegate: T,
    private val falseDelegate: T
) {
    operator fun getValue(thisRef: Any?, property: KProperty<*>): T {
        return if (condition()) trueDelegate else falseDelegate
    }
}

class FeatureToggle {
    private var debugMode = false
    
    val logLevel: String by ConditionalDelegate(
        condition = { debugMode },
        trueDelegate = "DEBUG",
        falseDelegate = "INFO"
    )
    
    fun enableDebug() { debugMode = true }
    fun disableDebug() { debugMode = false }
}
```

### Property Delegates with Backing Fields

Sometimes you need to combine property delegates with custom logic while still maintaining a backing field.

```kotlin
class ValidatedProperty<T>(
    private var backingValue: T,
    private val validator: (T) -> Boolean
) {
    operator fun getValue(thisRef: Any?, property: KProperty<*>): T = backingValue
    
    operator fun setValue(thisRef: Any?, property: KProperty<*>, value: T) {
        if (validator(value)) {
            backingValue = value
        } else {
            throw IllegalArgumentException("Invalid value for ${property.name}: $value")
        }
    }
}

class BankAccount {
    var balance: Double by ValidatedProperty(0.0) { it >= 0 }
    
    fun deposit(amount: Double) {
        balance += amount
    }
    
    fun withdraw(amount: Double) {
        balance -= amount // May throw exception if result is negative
    }
}
```

### Performance Considerations

Property delegation introduces a small performance overhead due to the additional method calls. For performance-critical code, consider:

- Using lazy delegates only when the computation is genuinely expensive
- Avoiding excessive property access in tight loops
- Considering inline delegates for simple cases
- Profiling to determine if delegation overhead is significant

### Thread Safety

When implementing custom delegates, consider thread safety:

```kotlin
class ThreadSafeDelegate<T>(initialValue: T) {
    @Volatile
    private var value: T = initialValue
    
    operator fun getValue(thisRef: Any?, property: KProperty<*>): T = value
    
    operator fun setValue(thisRef: Any?, property: KProperty<*>, value: T) {
        this.value = value
    }
}
```

**Conclusion:** Kotlin's delegation mechanism provides a powerful way to implement common patterns like lazy initialization, property observation, and composition over inheritance. By understanding both built-in delegates and how to create custom ones, you can write more maintainable and reusable code while leveraging Kotlin's expressive syntax.

---

