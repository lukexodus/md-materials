## Functional Operations


### Collection Processing with Lambdas

Kotlin provides extensive functional programming capabilities for collection manipulation through higher-order functions and lambda expressions.

#### Basic Collection Operations

```kotlin
val numbers = listOf(1, 2, 3, 4, 5, 6, 7, 8, 9, 10)

// Transform elements
val doubled = numbers.map { it * 2 }  // [2, 4, 6, 8, 10, 12, 14, 16, 18, 20]
val strings = numbers.map { "Number: $it" }

// Filter elements
val evens = numbers.filter { it % 2 == 0 }  // [2, 4, 6, 8, 10]
val greaterThanFive = numbers.filter { it > 5 }  // [6, 7, 8, 9, 10]

// Reduce and fold operations
val sum = numbers.reduce { acc, n -> acc + n }  // 55
val product = numbers.fold(1) { acc, n -> acc * n }  // 3628800
```

#### Advanced Collection Operations

```kotlin
val people = listOf(
    Person("Alice", 30),
    Person("Bob", 25),
    Person("Charlie", 35),
    Person("Diana", 28)
)

// Group by criteria
val groupedByAge = people.groupBy { it.age >= 30 }
val groupedByFirstLetter = people.groupBy { it.name.first() }

// Partition into two groups
val (adults, young) = people.partition { it.age >= 30 }

// Sort operations
val sortedByAge = people.sortedBy { it.age }
val sortedByName = people.sortedWith(compareBy { it.name })

// Find operations
val firstAdult = people.find { it.age >= 30 }  // Alice
val allAdults = people.all { it.age >= 18 }    // true
val anyTeenager = people.any { it.age < 18 }   // false
```

#### Chaining Operations

```kotlin
val result = numbers
    .filter { it % 2 == 0 }
    .map { it * it }
    .sortedDescending()
    .take(3)
    .sum()  // Sum of squares of top 3 even numbers

// Complex processing pipeline
val processedData = people
    .filter { it.age >= 25 }
    .sortedBy { it.name }
    .map { "${it.name} (${it.age})" }
    .joinToString(", ")
```

#### Working with Nested Collections

```kotlin
val departments = listOf(
    Department("IT", listOf(
        Employee("Alice", 30),
        Employee("Bob", 25)
    )),
    Department("HR", listOf(
        Employee("Charlie", 35),
        Employee("Diana", 28)
    ))
)

// Flatten nested collections
val allEmployees = departments.flatMap { it.employees }
val allNames = departments.flatMap { dept -> 
    dept.employees.map { it.name }
}

// Associate operations
val employeesByDept = departments.associate { it.name to it.employees }
val employeeAges = allEmployees.associate { it.name to it.age }
```

**Key points:**

- Lambda expressions provide concise syntax for functional operations
- Operations can be chained for complex data processing pipelines
- `it` refers to the current element in single-parameter lambdas
- Collection operations are eager by default (process immediately)

### Scope Functions

Scope functions execute code blocks within the context of an object, each with different characteristics and use cases.

#### `let` Function

`let` executes a block with the object as parameter and returns the block result.

```kotlin
// Basic usage
val name: String? = "Kotlin"
val length = name?.let { it.length } ?: 0

// Chaining operations
val result = "Hello World"
    .let { it.uppercase() }
    .let { it.replace(" ", "_") }
    .let { "PREFIX_$it" }  // "PREFIX_HELLO_WORLD"

// Null safety
fun processString(str: String?) {
    str?.let { nonNullString ->
        println("Processing: $nonNullString")
        // Additional processing
    }
}
```

#### `run` Function

`run` executes a block in the context of the object and returns the block result.

```kotlin
// Object context
val person = Person("Alice", 30)
val info = person.run {
    "Name: $name, Age: $age, Adult: ${age >= 18}"
}

// Without object context
val result = run {
    val x = 10
    val y = 20
    x + y  // Returns 30
}

// Configuration and initialization
class DatabaseConfig {
    var host = ""
    var port = 0
    var database = ""
}

val config = DatabaseConfig().run {
    host = "localhost"
    port = 5432
    database = "myapp"
    this  // Return configured object
}
```

#### `with` Function

`with` executes a block with the object as receiver and returns the block result.

```kotlin
val person = Person("Bob", 25)
val description = with(person) {
    "Person details: $name is $age years old"
}

// Multiple operations on same object
val stringBuilder = StringBuilder()
val result = with(stringBuilder) {
    append("Hello")
    append(" ")
    append("World")
    toString()
}

// Canvas drawing example
with(canvas) {
    drawRect(0f, 0f, 100f, 100f, paint)
    drawCircle(50f, 50f, 25f, paint)
    drawText("Hello", 10f, 90f, textPaint)
}
```

#### `apply` Function

`apply` executes a block in the context of the object and returns the object itself.

```kotlin
// Object configuration
val person = Person("Charlie", 35).apply {
    email = "charlie@example.com"
    phone = "123-456-7890"
}

// Builder pattern
val textView = TextView(context).apply {
    text = "Hello World"
    textSize = 16f
    setTextColor(Color.BLUE)
    gravity = Gravity.CENTER
}

// File operations
val file = File("data.txt").apply {
    createNewFile()
    writeText("Initial content")
}
```

#### `also` Function

`also` executes a block with the object as parameter and returns the object itself.

```kotlin
// Logging and debugging
val numbers = mutableListOf(1, 2, 3)
    .also { println("Initial list: $it") }
    .apply { add(4) }
    .also { println("After adding 4: $it") }
    .apply { removeAt(0) }
    .also { println("After removing first: $it") }

// Side effects
fun processData(data: String): String {
    return data
        .trim()
        .also { println("Trimmed: '$it'") }
        .uppercase()
        .also { println("Uppercase: '$it'") }
        .replace(" ", "_")
        .also { println("Final: '$it'") }
}
```

#### Scope Function Comparison

```kotlin
// Choosing the right scope function
val person = Person("Diana", 28)

// let - null safety, transformations
val nameLength = person.name?.let { it.length }

// run - object context, complex calculations
val isAdult = person.run { age >= 18 }

// with - multiple operations, no null safety
val info = with(person) { "$name ($age)" }

// apply - object configuration, fluent interface
val configuredPerson = person.apply { 
    email = "diana@example.com" 
}

// also - side effects, debugging
val processedPerson = person.also { 
    println("Processing: ${it.name}") 
}
```

**Key points:**

- `let` and `also` pass object as lambda parameter (`it`)
- `run`, `with`, and `apply` make object available as receiver (`this`)
- `let`, `run`, and `with` return lambda result
- `apply` and `also` return the original object
- Use for null safety, configuration, side effects, and transformations

### Sequence API for Lazy Evaluation

Sequences provide lazy evaluation for collection operations, processing elements on-demand rather than creating intermediate collections.

#### Creating Sequences

```kotlin
// From collections
val numbers = listOf(1, 2, 3, 4, 5)
val sequence = numbers.asSequence()

// Generate sequences
val infiniteSequence = generateSequence(1) { it + 1 }
val fibonacciSequence = generateSequence(1 to 1) { (a, b) -> b to a + b }
    .map { it.first }

// Sequence builders
val customSequence = sequence {
    yield(1)
    yield(2)
    yieldAll(listOf(3, 4, 5))
    yield(6)
}
```

#### Lazy vs Eager Evaluation

```kotlin
val numbers = (1..1000000).toList()

// Eager evaluation - creates intermediate collections
val eagerResult = numbers
    .filter { it % 2 == 0 }
    .map { it * it }
    .take(10)
    .toList()

// Lazy evaluation - processes elements on-demand
val lazyResult = numbers
    .asSequence()
    .filter { it % 2 == 0 }
    .map { it * it }
    .take(10)
    .toList()
```

#### Sequence Operations

```kotlin
val largeDataset = (1..100000).asSequence()

// Terminal operations trigger evaluation
val result = largeDataset
    .filter { it % 2 == 0 }
    .map { it * it }
    .take(10)
    .sum()  // Terminal operation

// Working with infinite sequences
val primes = generateSequence(2) { it + 1 }
    .filter { candidate ->
        (2 until candidate).none { candidate % it == 0 }
    }
    .take(10)
    .toList()
```

#### Performance Considerations

```kotlin
// Sequence performance benefits
fun performanceComparison() {
    val data = (1..10000).toList()
    
    // Multiple intermediate collections
    val listResult = data
        .filter { it % 2 == 0 }
        .map { it * it }
        .filter { it > 100 }
        .take(100)
    
    // Single pass through data
    val sequenceResult = data.asSequence()
        .filter { it % 2 == 0 }
        .map { it * it }
        .filter { it > 100 }
        .take(100)
        .toList()
}
```

**Key points:**

- Sequences process elements lazily, one at a time
- Intermediate operations are not executed until terminal operation
- More memory efficient for large datasets
- Ideal for processing pipelines with multiple transformations
- Use `asSequence()` for collections, `generateSequence()` for infinite sequences

### Function Composition Techniques

Function composition combines simple functions to create more complex operations.

#### Higher-Order Functions

```kotlin
// Function that takes another function as parameter
fun processNumbers(numbers: List<Int>, operation: (Int) -> Int): List<Int> {
    return numbers.map(operation)
}

// Function that returns another function
fun createMultiplier(factor: Int): (Int) -> Int {
    return { it * factor }
}

// Usage
val numbers = listOf(1, 2, 3, 4, 5)
val doubled = processNumbers(numbers, createMultiplier(2))
```

#### Function Composition Operators

```kotlin
// Composition using infix functions
infix fun <A, B, C> ((B) -> C).compose(f: (A) -> B): (A) -> C {
    return { a -> this(f(a)) }
}

infix fun <A, B, C> ((A) -> B).andThen(f: (B) -> C): (A) -> C {
    return { a -> f(this(a)) }
}

// Usage
val addOne: (Int) -> Int = { it + 1 }
val multiplyByTwo: (Int) -> Int = { it * 2 }
val square: (Int) -> Int = { it * it }

val composed = addOne andThen multiplyByTwo andThen square
val result = composed(3)  // ((3 + 1) * 2)^2 = 64
```

#### Currying and Partial Application

```kotlin
// Currying - converting multi-parameter function to chain of single-parameter functions
fun add(a: Int): (Int) -> Int = { b -> a + b }
fun multiply(a: Int): (Int) -> Int = { b -> a * b }

// Partial application
fun partiallyApply2<A, B, C>(f: (A, B) -> C, a: A): (B) -> C {
    return { b -> f(a, b) }
}

// Usage
val add5 = add(5)
val multiply3 = multiply(3)

val numbers = listOf(1, 2, 3, 4, 5)
val results = numbers.map(add5).map(multiply3)  // [18, 21, 24, 27, 30]
```

#### Pipeline Operations

```kotlin
// Pipeline operator
infix fun <T, R> T.pipe(f: (T) -> R): R = f(this)

// Usage
val result = "hello world"
    .pipe { it.uppercase() }
    .pipe { it.replace(" ", "_") }
    .pipe { "PREFIX_$it" }

// Complex data processing pipeline
data class User(val name: String, val age: Int, val email: String)

fun processUsers(users: List<User>): List<String> {
    return users
        .pipe { it.filter { user -> user.age >= 18 } }
        .pipe { it.sortedBy { user -> user.name } }
        .pipe { it.map { user -> "${user.name} <${user.email}>" } }
}
```

#### Functional Builders

```kotlin
// DSL for building processing pipelines
class ProcessingPipeline<T, R> {
    private val steps = mutableListOf<(Any) -> Any>()
    
    fun <U> map(transform: (T) -> U): ProcessingPipeline<T, U> {
        steps.add(transform as (Any) -> Any)
        return this as ProcessingPipeline<T, U>
    }
    
    fun filter(predicate: (T) -> Boolean): ProcessingPipeline<T, T> {
        steps.add { list -> (list as List<T>).filter(predicate) }
        return this
    }
    
    fun execute(input: T): R {
        return steps.fold(input as Any) { acc, step -> step(acc) } as R
    }
}

// Usage
val pipeline = ProcessingPipeline<List<Int>, List<String>>()
    .filter { it > 5 }
    .map { it * 2 }
    .map { "Result: $it" }

val result = pipeline.execute(listOf(1, 6, 3, 8, 2, 9))
```

#### Memoization

```kotlin
// Memoization for expensive computations
class Memoized<A, B>(val f: (A) -> B) : (A) -> B {
    private val cache = mutableMapOf<A, B>()
    
    override fun invoke(a: A): B {
        return cache.getOrPut(a) { f(a) }
    }
}

fun <A, B> ((A) -> B).memoized(): (A) -> B = Memoized(this)

// Usage
val expensiveFunction: (Int) -> Int = { n ->
    println("Computing for $n")
    Thread.sleep(1000)  // Simulate expensive computation
    n * n
}

val memoizedFunction = expensiveFunction.memoized()
println(memoizedFunction(5))  // Takes 1 second, prints "Computing for 5"
println(memoizedFunction(5))  // Instant, uses cached result
```

**Key points:**

- Function composition creates complex behavior from simple functions
- Higher-order functions enable flexible and reusable code
- Currying and partial application allow function specialization
- Pipeline operations improve code readability
- Memoization optimizes expensive computations through caching

**Related topics:** Coroutines and asynchronous programming, type-safe builders, domain-specific languages (DSLs), and advanced generics leverage these functional programming concepts.

---

