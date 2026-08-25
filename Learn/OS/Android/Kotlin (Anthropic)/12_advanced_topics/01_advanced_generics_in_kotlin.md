## Advanced Generics in Kotlin


### Higher-Kinded Types Concepts

Higher-kinded types represent types that take other types as parameters, creating abstractions over type constructors. While Kotlin doesn't have native higher-kinded types like Haskell or Scala, understanding these concepts helps with functional programming patterns and library design.

```kotlin
// Conceptual representation of higher-kinded types
// Kind * -> * (takes one type, returns another type)
interface Functor<F<*>> {
    fun <A, B> map(fa: F<A>, f: (A) -> B): F<B>
}

// Implementation for List (if Kotlin supported HKT)
class ListFunctor : Functor<List> {
    override fun <A, B> map(fa: List<A>, f: (A) -> B): List<B> = fa.map(f)
}
```

Kotlin achieves similar patterns through:

```kotlin
// Using sealed classes and generic interfaces
sealed class Either<out L, out R> {
    data class Left<out L>(val value: L) : Either<L, Nothing>()
    data class Right<out R>(val value: R) : Either<Nothing, R>()
}

// Generic operations
fun <L, R, T> Either<L, R>.map(f: (R) -> T): Either<L, T> = when (this) {
    is Either.Left -> this
    is Either.Right -> Either.Right(f(value))
}

// Type class pattern using interfaces
interface Mappable<T> {
    fun <R> map(f: (T) -> R): Mappable<R>
}
```

### Type Projections

Type projections allow you to work with generic types when you don't know the exact type parameter, using `out` (covariance) and `in` (contravariance) keywords.

#### Covariant Projections (out)

```kotlin
// Producer - can only produce T, not consume
class Producer<out T>(private val value: T) {
    fun produce(): T = value
    // fun consume(item: T) {} // Not allowed - would break covariance
}

// Usage with projections
fun processProducers(producers: List<Producer<out Any>>) {
    producers.forEach { producer ->
        val item = producer.produce()
        println(item)
    }
}

// Wildcard projections
fun copyFrom(source: Array<out Any>, dest: Array<Any>) {
    for (i in source.indices) {
        dest[i] = source[i]
    }
}
```

#### Contravariant Projections (in)

```kotlin
// Consumer - can only consume T, not produce
class Consumer<in T> {
    fun consume(item: T) {
        // Process item
    }
    // fun produce(): T // Not allowed - would break contravariance
}

// Usage
fun processConsumers(consumers: List<Consumer<in String>>) {
    consumers.forEach { consumer ->
        consumer.consume("Hello")
    }
}

// Contravariant function types
fun processCallback(callback: (String) -> Unit) {
    callback("Hello")
}

// Can pass more general callback
val generalCallback: (Any) -> Unit = { println(it) }
processCallback(generalCallback) // Works due to contravariance
```

#### Star Projections

```kotlin
// Star projection - unknown type
fun processUnknownList(list: List<*>) {
    // Can read as Any?
    list.forEach { item ->
        println(item?.toString())
    }
    // Cannot add items - type is unknown
}

// Complex projections
class Container<T> {
    private val items = mutableListOf<T>()
    
    fun add(item: T) = items.add(item)
    fun get(index: Int): T = items[index]
    fun size(): Int = items.size
}

fun mergeContainers(
    source: Container<out Number>,
    destination: Container<in Number>
) {
    for (i in 0 until source.size()) {
        destination.add(source.get(i))
    }
}
```

### Complex Generic Scenarios

#### Self-Referencing Generics

```kotlin
// Fluent builder pattern
abstract class Builder<T : Builder<T>> {
    abstract fun self(): T
    
    fun commonMethod(): T {
        // Common logic
        return self()
    }
}

class PersonBuilder : Builder<PersonBuilder>() {
    private var name: String = ""
    private var age: Int = 0
    
    override fun self(): PersonBuilder = this
    
    fun name(name: String): PersonBuilder {
        this.name = name
        return self()
    }
    
    fun age(age: Int): PersonBuilder {
        this.age = age
        return self()
    }
    
    fun build(): Person = Person(name, age)
}

// Usage
val person = PersonBuilder()
    .name("John")
    .age(25)
    .commonMethod()
    .build()
```

#### Multiple Type Parameters with Constraints

```kotlin
// Multiple bounds
interface Comparable<in T>
interface Serializable

fun <T> processItem(item: T) 
    where T : Comparable<T>, 
          T : Serializable,
          T : Any {
    // T must be comparable, serializable, and non-null
}

// Generic type relationships
class Repository<T, ID> where T : Entity<ID> {
    fun save(entity: T): T {
        // Save logic
        return entity
    }
    
    fun findById(id: ID): T? {
        // Find logic
        return null
    }
}

abstract class Entity<ID> {
    abstract val id: ID
}

data class User(override val id: Long, val name: String) : Entity<Long>()
```

#### Generic Type Inference Edge Cases

```kotlin
// Type inference with complex hierarchies
class Box<T>(val value: T)

fun <T> createBox(value: T): Box<T> = Box(value)

// Inference works
val stringBox = createBox("Hello") // Box<String>
val intBox = createBox(42) // Box<Int>

// Complex inference scenarios
fun <T> processMultiple(vararg items: T): List<T> = items.toList()

// Type inference with nullable types
fun <T> processNullable(item: T?): T? = item

// Requires explicit type when ambiguous
val result: String? = processNullable(null)

// Generic extension functions
fun <T> List<T>.secondOrNull(): T? = if (size > 1) this[1] else null

// Type inference with receivers
fun <T> T.applyIf(condition: Boolean, block: T.() -> T): T =
    if (condition) block() else this
```

### Phantom Types

Phantom types are type parameters that don't appear in the runtime representation but provide compile-time type safety.

#### State Machine with Phantom Types

```kotlin
// Phantom type for state tracking
sealed class State
object Uninitialized : State()
object Initialized : State()
object Running : State()
object Stopped : State()

class StateMachine<S : State> private constructor(
    private val data: String
) {
    companion object {
        fun create(): StateMachine<Uninitialized> = 
            StateMachine("")
    }
    
    // Only available in Uninitialized state
    fun initialize(data: String): StateMachine<Initialized> = 
        StateMachine(data)
    
    // Only available in Initialized state  
    fun StateMachine<Initialized>.start(): StateMachine<Running> =
        StateMachine(data)
    
    // Only available in Running state
    fun StateMachine<Running>.stop(): StateMachine<Stopped> =
        StateMachine(data)
    
    // Only available in Stopped state
    fun StateMachine<Stopped>.restart(): StateMachine<Running> =
        StateMachine(data)
}

// Usage - compiler enforces state transitions
val machine = StateMachine.create()
    .initialize("config")
    .start()
    .stop()
    .restart()
// machine.initialize("") // Compile error - not in correct state
```

#### Unit Types for Measurement

```kotlin
// Phantom types for units
sealed class Unit
object Meter : Unit()
object Foot : Unit()
object Celsius : Unit()
object Fahrenheit : Unit()

data class Measurement<U : Unit>(val value: Double) {
    operator fun plus(other: Measurement<U>): Measurement<U> =
        Measurement(value + other.value)
}

// Type-safe conversions
fun Measurement<Foot>.toMeters(): Measurement<Meter> =
    Measurement(value * 0.3048)

fun Measurement<Celsius>.toFahrenheit(): Measurement<Fahrenheit> =
    Measurement(value * 9/5 + 32)

// Usage
val distance1 = Measurement<Meter>(10.0)
val distance2 = Measurement<Meter>(5.0)
val totalDistance = distance1 + distance2 // Type-safe

val feetMeasurement = Measurement<Foot>(33.0)
val metersMeasurement = feetMeasurement.toMeters()

// val invalid = distance1 + feetMeasurement // Compile error
```

#### Capability-Based Security

```kotlin
// Phantom types for permissions
sealed class Permission
object ReadPermission : Permission()
object WritePermission : Permission()
object AdminPermission : Permission()

class SecureResource<P : Permission>(private val data: String) {
    
    // Only readable with read permission
    fun read(): String where P : ReadPermission = data
    
    // Only writable with write permission
    fun write(newData: String): SecureResource<P> where P : WritePermission =
        SecureResource(newData)
    
    // Only deletable with admin permission
    fun delete(): Unit where P : AdminPermission = Unit
}

// Permission granting
fun <P : Permission> grantPermission(resource: SecureResource<Permission>): SecureResource<P> =
    SecureResource(resource.toString())

// Usage
val resource: SecureResource<ReadPermission> = grantPermission(SecureResource("data"))
val content = resource.read() // Allowed

// val updated = resource.write("new") // Compile error - no write permission
```

**Key points**:

- Higher-kinded types enable powerful abstractions but require workarounds in Kotlin
- Type projections (`out`, `in`, `*`) provide flexibility while maintaining type safety
- Complex generic scenarios often involve multiple constraints and self-referencing types
- Phantom types provide compile-time guarantees without runtime overhead
- Understanding variance and projections is crucial for designing robust APIs

**Example** of combining these concepts:

```kotlin
// Advanced generic repository pattern
interface Repository<T, ID> where T : Entity<ID> {
    fun save(entity: T): T
    fun findById(id: ID): T?
    fun findAll(): List<T>
}

// Phantom type for query state
sealed class QueryState
object Unprepared : QueryState()
object Prepared : QueryState()

class TypedQuery<T, S : QueryState> private constructor(
    private val sql: String,
    private val parameters: Map<String, Any> = emptyMap()
) {
    companion object {
        fun <T> create(sql: String): TypedQuery<T, Unprepared> = 
            TypedQuery(sql)
    }
    
    fun bind(key: String, value: Any): TypedQuery<T, Prepared> =
        TypedQuery(sql, parameters + (key to value))
    
    fun execute(): List<T> where S : Prepared {
        // Execute query with parameters
        return emptyList()
    }
}
```

Understanding these advanced generic concepts enables building more expressive, type-safe APIs while maintaining runtime performance and compile-time guarantees.

---

