## Generics


### Generic Functions and Classes

Generics enable writing type-safe, reusable code that works with multiple types while maintaining compile-time type checking.

```kotlin
// Generic function
fun <T> swap(a: T, b: T): Pair<T, T> {
    return Pair(b, a)
}

// Usage
val swapped = swap(10, 20) // Type inferred as Pair<Int, Int>
val swappedStrings = swap("hello", "world") // Type inferred as Pair<String, String>

// Generic function with multiple type parameters
fun <T, R> transform(input: T, transformer: (T) -> R): R {
    return transformer(input)
}

val result = transform(42) { it.toString() } // String
val doubled = transform(5) { it * 2 } // Int

// Generic class
class Box<T>(private var value: T) {
    fun get(): T = value
    fun set(newValue: T) {
        value = newValue
    }
    
    fun <R> map(transform: (T) -> R): Box<R> {
        return Box(transform(value))
    }
}

// Usage
val intBox = Box(42)
val stringBox = intBox.map { it.toString() }
val doubledBox = intBox.map { it * 2 }

// Generic class with multiple type parameters
class Pair<T, U>(val first: T, val second: U) {
    fun <R> mapFirst(transform: (T) -> R): Pair<R, U> {
        return Pair(transform(first), second)
    }
    
    fun <R> mapSecond(transform: (U) -> R): Pair<T, R> {
        return Pair(first, transform(second))
    }
}

// Generic interface
interface Repository<T> {
    fun save(item: T)
    fun findById(id: String): T?
    fun findAll(): List<T>
    fun delete(id: String): Boolean
}

// Implementation
class UserRepository : Repository<User> {
    private val users = mutableMapOf<String, User>()
    
    override fun save(item: User) {
        users[item.id] = item
    }
    
    override fun findById(id: String): User? = users[id]
    override fun findAll(): List<User> = users.values.toList()
    override fun delete(id: String): Boolean = users.remove(id) != null
}

// Generic with nested classes
class Container<T> {
    private val items = mutableListOf<T>()
    
    fun add(item: T) {
        items.add(item)
    }
    
    inner class Iterator {
        private var index = 0
        
        fun hasNext(): Boolean = index < items.size
        fun next(): T = items[index++]
    }
    
    fun iterator(): Iterator = Iterator()
}
```

**Key points:**

- Generic functions use `<T>` syntax before function name
- Type parameters can be inferred from usage
- Generic classes can have multiple type parameters
- Generic methods can be defined within non-generic classes
- Inner classes have access to outer class's type parameters

### Type Parameters and Constraints

Type constraints limit which types can be used as generic arguments, ensuring type safety and enabling specific operations.

```kotlin
// Upper bound constraint
fun <T : Number> sum(a: T, b: T): Double {
    return a.toDouble() + b.toDouble()
}

// Multiple constraints
interface Printable {
    fun print()
}

fun <T> processItem(item: T) where T : Comparable<T>, T : Printable {
    item.print()
    // Can use Comparable methods
}

// Generic class with constraints
class SortedList<T : Comparable<T>> {
    private val items = mutableListOf<T>()
    
    fun add(item: T) {
        val index = items.binarySearch(item)
        val insertionPoint = if (index >= 0) index else -index - 1
        items.add(insertionPoint, item)
    }
    
    fun get(index: Int): T = items[index]
    fun size(): Int = items.size
}

// Generic constraints with multiple bounds
interface Named {
    val name: String
}

interface Identifiable {
    val id: String
}

class EntityProcessor<T> where T : Named, T : Identifiable {
    fun process(entity: T) {
        println("Processing entity: ${entity.name} (ID: ${entity.id})")
    }
}

// Star projection for unknown types
class Container<T>(private val items: MutableList<T>) {
    fun getItems(): List<T> = items.toList()
    
    // Function that works with any Container
    fun copyFrom(other: Container<*>) {
        // Can only read from other, not write
        println("Copying ${other.getItems().size} items")
    }
}

// Generic constraints with nullable types
class NullableContainer<T : Any?> {
    private var value: T? = null
    
    fun set(newValue: T?) {
        value = newValue
    }
    
    fun get(): T? = value
}

// Generic constraints with sealed classes
sealed class Result<out T>
data class Success<T>(val data: T) : Result<T>()
data class Error(val message: String) : Result<Nothing>()

fun <T : Any> processResult(result: Result<T>) {
    when (result) {
        is Success -> println("Success: ${result.data}")
        is Error -> println("Error: ${result.message}")
    }
}

// Generic with enum constraints
enum class Status { ACTIVE, INACTIVE, PENDING }

class StatusManager<T : Enum<T>>(private val enumClass: Class<T>) {
    fun getAllStatuses(): Array<T> = enumClass.enumConstants
    
    fun isValid(status: String): Boolean {
        return try {
            java.lang.Enum.valueOf(enumClass, status)
            true
        } catch (e: IllegalArgumentException) {
            false
        }
    }
}
```

**Key points:**

- Upper bounds specified with `:` syntax
- Multiple constraints use `where` clause
- `Any` constraint excludes nullable types
- Star projection (`*`) for unknown types with read-only access
- Constraints enable calling specific methods on type parameters
- Sealed classes work well with generic constraints

### Variance

Variance defines how generic types with inheritance relationships relate to each other.

```kotlin
// Covariance - producer (out)
interface Producer<out T> {
    fun produce(): T
    // Cannot have T as parameter type
}

class AnimalProducer : Producer<Animal> {
    override fun produce(): Animal = Animal("Generic Animal")
}

class DogProducer : Producer<Dog> {
    override fun produce(): Dog = Dog("Buddy")
}

// Covariance allows assignment
val animalProducer: Producer<Animal> = DogProducer() // OK
val animal = animalProducer.produce() // Returns Dog, treated as Animal

// Contravariance - consumer (in)
interface Consumer<in T> {
    fun consume(item: T)
    // Cannot have T as return type
}

class AnimalConsumer : Consumer<Animal> {
    override fun consume(item: Animal) {
        println("Consuming animal: ${item.name}")
    }
}

// Contravariance allows assignment
val dogConsumer: Consumer<Dog> = AnimalConsumer() // OK
dogConsumer.consume(Dog("Rex")) // Animal consumer can handle Dog

// Invariance - both producer and consumer
interface Storage<T> {
    fun store(item: T)
    fun retrieve(): T
}

// Built-in variance examples
val strings: List<String> = listOf("a", "b", "c")
val objects: List<Any> = strings // OK - List is covariant

val mutableStrings: MutableList<String> = mutableListOf("a", "b")
// val mutableObjects: MutableList<Any> = mutableStrings // ERROR - MutableList is invariant

// Use-site variance
fun copyFrom(source: Array<out Any>, dest: Array<in Any>) {
    for (i in source.indices) {
        dest[i] = source[i]
    }
}

// Generic variance in practice
class Box<T>(private var value: T) {
    fun get(): T = value
    fun set(newValue: T) {
        value = newValue
    }
}

// Variance with functions
fun processProducers(producers: List<Producer<out Animal>>) {
    producers.forEach { producer ->
        val animal = producer.produce()
        println("Produced: ${animal.name}")
    }
}

fun processConsumers(consumers: List<Consumer<in Dog>>) {
    val dog = Dog("Max")
    consumers.forEach { consumer ->
        consumer.consume(dog)
    }
}

// Complex variance scenarios
interface Transformer<in T, out R> {
    fun transform(input: T): R
}

class StringToIntTransformer : Transformer<String, Int> {
    override fun transform(input: String): Int = input.length
}

// Variance with nullable types
class NullableProducer<out T : Any?> {
    fun produce(): T? = null
}

// Variance with collections
fun <T> copyList(source: List<out T>, destination: MutableList<in T>) {
    for (item in source) {
        destination.add(item)
    }
}
```

**Key points:**

- Covariance (`out`) allows subtype assignments for producers
- Contravariance (`in`) allows supertype assignments for consumers
- Invariance requires exact type match
- Use-site variance with `out` and `in` at call site
- Collections demonstrate variance principles
- Variance enables flexible API design

### Generic Type Erasure and Reified Types

Type erasure removes generic type information at runtime, but reified types in inline functions preserve this information.

```kotlin
// Type erasure problem
fun <T> isOfType(value: Any): Boolean {
    // return value is T // ERROR - cannot check erased type
    return false
}

// Reified types solution
inline fun <reified T> isOfType(value: Any): Boolean {
    return value is T
}

// Usage
val number = 42
val isInt = isOfType<Int>(number) // true
val isString = isOfType<String>(number) // false

// Reified types with class access
inline fun <reified T> createInstance(): T? {
    return try {
        T::class.java.newInstance()
    } catch (e: Exception) {
        null
    }
}

// Reified types with reflection
inline fun <reified T> getClassName(): String {
    return T::class.simpleName ?: "Unknown"
}

// Complex reified type usage
inline fun <reified T> filterByType(items: List<Any>): List<T> {
    return items.filterIsInstance<T>()
}

val mixedList = listOf(1, "hello", 2.5, "world", 42)
val strings = filterByType<String>(mixedList) // ["hello", "world"]
val numbers = filterByType<Int>(mixedList) // [1, 42]

// Reified types with JSON parsing
inline fun <reified T> parseJson(json: String): T? {
    return try {
        // Gson example (hypothetical)
        Gson().fromJson(json, T::class.java)
    } catch (e: Exception) {
        null
    }
}

// Generic array creation with reified types
inline fun <reified T> createArray(size: Int): Array<T?> {
    return arrayOfNulls<T>(size)
}

// Type erasure workarounds without reified
class TypeToken<T> {
    val type: Class<T>
    
    @Suppress("UNCHECKED_CAST")
    constructor() {
        val superclass = javaClass.genericSuperclass as ParameterizedType
        type = superclass.actualTypeArguments[0] as Class<T>
    }
}

// Usage with TypeToken
fun <T> createWithTypeToken(typeToken: TypeToken<T>): T? {
    return try {
        typeToken.type.newInstance()
    } catch (e: Exception) {
        null
    }
}

// Star projection with type erasure
fun printContainerInfo(container: Container<*>) {
    println("Container has ${container.size()} items")
    // Cannot access specific type information
}

// Reified types with higher-order functions
inline fun <reified T> Collection<*>.countOfType(): Int {
    return count { it is T }
}

val items = listOf(1, "hello", 2.5, "world", 42, true)
val stringCount = items.countOfType<String>() // 2
val intCount = items.countOfType<Int>() // 2

// Reified types with sealed classes
sealed class ApiResponse<out T>
data class Success<T>(val data: T) : ApiResponse<T>()
data class Error(val message: String) : ApiResponse<Nothing>()

inline fun <reified T> handleResponse(response: ApiResponse<*>): T? {
    return when (response) {
        is Success -> {
            if (response.data is T) response.data else null
        }
        is Error -> {
            println("Error: ${response.message}")
            null
        }
    }
}

// Runtime type information preservation
inline fun <reified T> analyzeType() {
    val clazz = T::class
    println("Type: ${clazz.simpleName}")
    println("Is data class: ${clazz.isData}")
    println("Is sealed: ${clazz.isSealed}")
    println("Constructors: ${clazz.constructors.size}")
}
```

**Key points:**

- Type erasure removes generic type info at runtime
- Reified types preserve type information in inline functions
- `reified` keyword enables runtime type checking
- Reified types enable generic array creation
- TypeToken pattern works around type erasure
- Star projection handles unknown types safely
- Reified types are limited to inline functions

### Advanced Generic Patterns

```kotlin
// Generic builder pattern
class QueryBuilder<T> {
    private val conditions = mutableListOf<String>()
    
    fun where(condition: String): QueryBuilder<T> {
        conditions.add(condition)
        return this
    }
    
    fun and(condition: String): QueryBuilder<T> {
        conditions.add("AND $condition")
        return this
    }
    
    fun build(): Query<T> {
        return Query(conditions.joinToString(" "))
    }
}

class Query<T>(val sql: String)

// Generic factory pattern
interface Factory<T> {
    fun create(): T
}

class DatabaseFactory<T>(private val creator: () -> T) : Factory<T> {
    override fun create(): T = creator()
}

// Generic visitor pattern
interface Visitor<T, R> {
    fun visit(item: T): R
}

class PrintVisitor : Visitor<Any, String> {
    override fun visit(item: Any): String = item.toString()
}

// Generic with delegation
class LazyValue<T>(private val initializer: () -> T) {
    private var value: T? = null
    
    fun get(): T {
        if (value == null) {
            value = initializer()
        }
        return value!!
    }
}

// Generic monad pattern
class Optional<T>(private val value: T?) {
    fun <R> map(transform: (T) -> R): Optional<R> {
        return if (value != null) {
            Optional(transform(value))
        } else {
            Optional(null)
        }
    }
    
    fun <R> flatMap(transform: (T) -> Optional<R>): Optional<R> {
        return if (value != null) {
            transform(value)
        } else {
            Optional(null)
        }
    }
    
    fun getOrElse(default: T): T = value ?: default
}

// Generic type-safe builders
class HtmlBuilder<T> {
    private val elements = mutableListOf<String>()
    
    fun tag(name: String, content: String): HtmlBuilder<T> {
        elements.add("<$name>$content</$name>")
        return this
    }
    
    fun build(): String = elements.joinToString("\n")
}

inline fun <reified T> html(block: HtmlBuilder<T>.() -> Unit): String {
    return HtmlBuilder<T>().apply(block).build()
}
```

**Key points:**

- Generic builders provide type-safe construction
- Factory pattern with generics enables flexible object creation
- Visitor pattern with generics supports type-safe operations
- Delegation with generics enables lazy evaluation
- Monad pattern with generics provides functional composition
- Type-safe builders combine generics with DSL patterns

**Important related topics:**

- Kotlin's standard library generic functions (map, filter, fold)
- Generic collections and their variance properties
- Generic serialization and deserialization patterns
- Performance implications of generic type erasure

---

