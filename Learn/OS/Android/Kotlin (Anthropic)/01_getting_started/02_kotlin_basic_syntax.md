## Kotlin Basic Syntax


### Variables and Constants

Kotlin provides two keywords for declaring variables: `var` for mutable variables and `val` for immutable values (constants).

```kotlin
// Mutable variable
var name = "John"
name = "Jane" // This is allowed

// Immutable value (constant)
val age = 25
// age = 26 // This would cause a compilation error
```

**Key points:**

- Use `val` by default for immutability and thread safety
- Use `var` only when you need to reassign the variable
- `val` references are immutable, but the objects they point to can still be modified
- Late initialization is possible with `lateinit var` for non-null properties

### Data Types

Kotlin has a rich type system with both primitive and reference types that are unified under the hood.

#### Numeric Types

```kotlin
val byte: Byte = 127
val short: Short = 32767
val int: Int = 2147483647
val long: Long = 9223372036854775807L
val float: Float = 3.14f
val double: Double = 3.141592653589793
```

#### Character and Boolean Types

```kotlin
val char: Char = 'A'
val boolean: Boolean = true
```

#### String Type

```kotlin
val text: String = "Hello, Kotlin!"
val multilineText = """
    This is a
    multiline string
    with proper indentation
""".trimIndent()
```

#### Collections

```kotlin
val list = listOf(1, 2, 3, 4, 5)
val mutableList = mutableListOf("a", "b", "c")
val map = mapOf("key1" to "value1", "key2" to "value2")
val set = setOf(1, 2, 3, 2) // Will contain [1, 2, 3]
```

**Key points:**

- All types in Kotlin are objects - no primitive types at the language level
- Numbers are automatically boxed when needed
- Use appropriate suffixes: `L` for Long, `f` for Float
- Collections are immutable by default; use mutable versions when needed

### Type Inference and Explicit Typing

Kotlin's compiler can infer types in most cases, reducing boilerplate code while maintaining type safety.

```kotlin
// Type inference
val inferredInt = 42 // Inferred as Int
val inferredString = "Hello" // Inferred as String
val inferredList = listOf(1, 2, 3) // Inferred as List<Int>

// Explicit typing
val explicitInt: Int = 42
val explicitString: String = "Hello"
val explicitList: List<Int> = listOf(1, 2, 3)

// When explicit typing is necessary
val nullableString: String? = null
val emptyList: List<String> = emptyList()
```

#### Advanced Type Scenarios

```kotlin
// Generic type inference
val map = mapOf("a" to 1, "b" to 2) // Inferred as Map<String, Int>

// Lambda with inferred parameter types
val doubled = listOf(1, 2, 3).map { it * 2 } // 'it' is inferred as Int

// When compiler needs help
val result: Any = if (condition) "string" else 42
```

**Key points:**

- Kotlin's type inference is sophisticated and handles most scenarios
- Explicit typing improves readability in complex scenarios
- Use explicit typing for public APIs and when type isn't obvious
- Nullable types must be explicitly declared with `?`

### Comments and Documentation

Kotlin supports both single-line and multi-line comments, plus KDoc for documentation.

```kotlin
// Single-line comment
val x = 10 // End-of-line comment

/*
 * Multi-line comment
 * spanning multiple lines
 */
val y = 20

/**
 * KDoc documentation comment
 * 
 * This function calculates the sum of two numbers.
 * 
 * @param a The first number
 * @param b The second number
 * @return The sum of a and b
 * @throws IllegalArgumentException if either parameter is negative
 * @since 1.0
 * @author Your Name
 */
fun calculateSum(a: Int, b: Int): Int {
    require(a >= 0 && b >= 0) { "Parameters must be non-negative" }
    return a + b
}
```

#### Documentation Tags

```kotlin
/**
 * @param parameter description
 * @return return value description
 * @throws ExceptionType when this exception is thrown
 * @see RelatedClass
 * @since version
 * @author author name
 * @deprecated deprecation message
 * @sample fully.qualified.name.of.sample.function
 */
```

**Key points:**

- Use `//` for single-line comments
- Use `/* */` for multi-line comments
- Use `/** */` for KDoc documentation
- KDoc supports Markdown formatting
- Good documentation improves code maintainability

### String Templates and Interpolation

Kotlin provides powerful string templating capabilities for embedding expressions within strings.

#### Basic String Templates

```kotlin
val name = "Alice"
val age = 30

// Simple variable interpolation
val greeting = "Hello, $name!"
val info = "Name: $name, Age: $age"

// Expression interpolation
val calculation = "The result is ${10 + 5}"
val comparison = "Is adult: ${age >= 18}"
```

#### Advanced String Templates

```kotlin
// Property access
data class Person(val name: String, val age: Int)
val person = Person("Bob", 25)
val description = "Person: ${person.name} is ${person.age} years old"

// Function calls
fun getCurrentTime() = System.currentTimeMillis()
val timestamp = "Current time: ${getCurrentTime()}"

// Complex expressions
val numbers = listOf(1, 2, 3, 4, 5)
val summary = "Numbers: ${numbers.joinToString(", ")}, Sum: ${numbers.sum()}"
```

#### Raw Strings and Escaping

```kotlin
// Raw strings with triple quotes
val jsonTemplate = """
    {
        "name": "$name",
        "age": $age,
        "active": ${true}
    }
""".trimIndent()

// Escaping in regular strings
val withQuotes = "He said: \"Hello, $name!\""
val withSpecialChars = "Path: C:\\Users\\$name\\Documents"

// Dollar sign escaping
val price = "Price: \$${19.99}"
```

#### String Template Best Practices

```kotlin
// Use curly braces for complex expressions
val result = "${if (score >= 90) "A" else "B"}"

// Format numbers
val formatted = "Score: ${"%.2f".format(85.678)}"

// Multi-line templates
val email = """
    Dear $name,
    
    Your account balance is $${balance}.
    
    Best regards,
    The Team
""".trimIndent()
```

**Key points:**

- Use `$variable` for simple variable interpolation
- Use `${expression}` for complex expressions
- Raw strings with `"""` preserve formatting and don't require escaping
- String templates are evaluated at runtime
- Use `trimIndent()` to remove common leading whitespace from multi-line strings

**Example:**

```kotlin
fun main() {
    val user = "Developer"
    val tasks = listOf("coding", "testing", "documentation")
    val progress = 75.5
    
    val report = """
        Daily Report for $user
        =====================
        
        Tasks completed: ${tasks.joinToString(", ")}
        Progress: ${progress}%
        Status: ${if (progress >= 80) "Excellent" else "Good"}
        
        Generated at: ${System.currentTimeMillis()}
    """.trimIndent()
    
    println(report)
}
```

**Output:**

```
Daily Report for Developer
=====================

Tasks completed: coding, testing, documentation
Progress: 75.5%
Status: Good

Generated at: 1703123456789
```

These fundamental syntax elements form the foundation of Kotlin programming, enabling you to write clean, expressive, and type-safe code. Understanding these basics is essential before moving on to more advanced Kotlin features like functions, classes, and coroutines.

---

