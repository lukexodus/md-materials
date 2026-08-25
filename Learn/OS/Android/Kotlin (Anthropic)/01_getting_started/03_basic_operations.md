## Basic Operations


### Arithmetic Operators

Kotlin supports standard arithmetic operators with both infix and function call syntax. The operators `+`, `-`, `*`, `/`, and `%` work on numeric types including Int, Long, Float, and Double.

```kotlin
val a = 10
val b = 3
val sum = a + b        // 13
val difference = a - b // 7
val product = a * b    // 30
val quotient = a / b   // 3 (integer division)
val remainder = a % b  // 1
```

**Key points:**

- Integer division truncates decimal portions
- Use floating-point types for precise division
- Operators are translated to function calls (`a + b` becomes `a.plus(b)`)
- Unary operators include `+`, `-`, `++`, `--`

### Comparison Operators

Comparison operators return Boolean values and include equality (`==`, `!=`) and relational (`<`, `>`, `<=`, `>=`) operators.

```kotlin
val x = 5
val y = 10
val isEqual = x == y        // false
val isNotEqual = x != y     // true
val isLess = x < y          // true
val isGreaterEqual = x >= y // false
```

**Key points:**

- `==` checks structural equality (calls `equals()`)
- `===` checks referential equality (same object instance)
- `!=` and `!==` are negations of equality operators
- Comparison operators can be overloaded for custom classes

### Logical Operators

Logical operators work with Boolean values and include AND (`&&`), OR (`||`), and NOT (`!`).

```kotlin
val condition1 = true
val condition2 = false
val andResult = condition1 && condition2  // false
val orResult = condition1 || condition2   // true
val notResult = !condition1               // false
```

**Key points:**

- `&&` and `||` are short-circuiting operators
- `and`, `or`, and `xor` are infix functions for Boolean operations
- Logical operators have precedence: `!` > `&&` > `||`

### Null Safety Basics

Kotlin's null safety system prevents null pointer exceptions at compile time through nullable and non-nullable types.

#### Safe Call Operator (`?.`)

The safe call operator allows safe access to properties and methods on nullable objects.

```kotlin
val name: String? = null
val length = name?.length  // Returns null instead of throwing exception
val upperCase = name?.uppercase()  // Chain safe calls
```

#### Not-Null Assertion Operator (`!!`)

The not-null assertion operator converts nullable types to non-nullable types but throws an exception if the value is null.

```kotlin
val name: String? = "Kotlin"
val length = name!!.length  // 6, but throws KotlinNullPointerException if name is null
```

#### Elvis Operator (`?:`)

The Elvis operator provides default values for null cases.

```kotlin
val name: String? = null
val displayName = name ?: "Unknown"  // "Unknown"
val length = name?.length ?: 0       // 0
```

**Key points:**

- Nullable types are declared with `?` suffix
- Safe calls return null if the receiver is null
- Use `!!` only when absolutely certain the value is not null
- Elvis operator enables concise null handling

### Basic Input/Output Operations

#### Standard Output

Kotlin provides several functions for console output.

```kotlin
print("Hello ")           // No newline
println("World!")         // With newline
printf("Number: %d", 42)  // Formatted output
```

#### Standard Input

Input operations typically use `readLine()` for console input.

```kotlin
print("Enter your name: ")
val name = readLine()  // Returns String? (nullable)
val safeName = readLine() ?: "Unknown"

print("Enter a number: ")
val number = readLine()?.toIntOrNull() ?: 0
```

#### File Operations

Basic file I/O operations for reading and writing files.

```kotlin
import java.io.File

// Reading files
val content = File("input.txt").readText()
val lines = File("input.txt").readLines()

// Writing files
File("output.txt").writeText("Hello, Kotlin!")
File("output.txt").appendText("\nNew line")
```

**Key points:**

- `readLine()` returns nullable String
- Always handle potential null values from input
- Use conversion functions with null safety (`toIntOrNull()`)
- File operations may throw exceptions - consider try-catch blocks

### Type Checking and Casting

#### Type Checking (`is`)

The `is` operator checks if an object is of a specific type.

```kotlin
fun processValue(value: Any) {
    if (value is String) {
        println("String length: ${value.length}")  // Smart cast
    }
    if (value is Int) {
        println("Integer value: $value")
    }
}
```

#### Type Casting (`as`)

The `as` operator performs explicit type casting.

```kotlin
val obj: Any = "Hello"
val str = obj as String        // Unsafe cast - throws exception if wrong type
val safeStr = obj as? String   // Safe cast - returns null if wrong type
```

#### Smart Casting

Kotlin automatically casts types after successful type checks.

```kotlin
fun handleValue(value: Any?) {
    if (value != null && value is String) {
        // value is automatically cast to String
        println(value.uppercase())
    }
}
```

**Key points:**

- `is` enables type checking and triggers smart casting
- `as` performs explicit casting but may throw `ClassCastException`
- `as?` provides safe casting, returning null on failure
- Smart casting eliminates need for explicit casting after type checks

### Operator Overloading

Kotlin allows custom classes to define operator behavior through specific function names.

```kotlin
data class Point(val x: Int, val y: Int) {
    operator fun plus(other: Point) = Point(x + other.x, y + other.y)
    operator fun minus(other: Point) = Point(x - other.x, y - other.y)
}

val p1 = Point(1, 2)
val p2 = Point(3, 4)
val sum = p1 + p2  // Point(4, 6)
```

**Key points:**

- Operator functions must be marked with `operator` keyword
- Each operator maps to a specific function name
- Operators can be overloaded for custom behavior
- Maintains readability while providing mathematical syntax

### Range Operations

Kotlin provides range operators for creating sequences of values.

```kotlin
val range1 = 1..10        // 1 to 10 inclusive
val range2 = 1 until 10   // 1 to 9 (exclusive end)
val range3 = 10 downTo 1  // 10 to 1 descending
val range4 = 1..10 step 2 // 1, 3, 5, 7, 9

// Range checks
val number = 5
if (number in 1..10) {
    println("Number is in range")
}
```

**Key points:**

- `..` creates inclusive ranges
- `until` creates ranges with exclusive end
- `downTo` creates descending ranges
- `step` modifies range increment
- `in` operator checks range membership

**Related topics:** Functions and lambdas, collections operations, string manipulation, exception handling, and control flow statements build upon these basic operations.

---

