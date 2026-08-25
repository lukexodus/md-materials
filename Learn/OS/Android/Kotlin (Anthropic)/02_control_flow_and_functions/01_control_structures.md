## Control Structures


### If Expressions

Kotlin's `if` is an expression that returns a value, not just a statement for control flow. This makes code more concise and functional in style.

```kotlin
// Basic if expression
val result = if (condition) "true branch" else "false branch"

// Multi-line if expression
val max = if (a > b) {
    println("Choose a")
    a
} else {
    println("Choose b")
    b
}

// If without else (returns Unit)
if (score > 90) println("Excellent!")

// Nested if expressions
val grade = if (score >= 90) "A"
            else if (score >= 80) "B"
            else if (score >= 70) "C"
            else "F"
```

**Key points:**

- `if` expressions must have an `else` branch when used as expressions
- The last expression in each branch becomes the return value
- Can be used anywhere an expression is expected
- Type inference works with if expressions

### When Expressions

The `when` expression is Kotlin's pattern matching construct, more powerful than traditional switch statements.

```kotlin
// Basic when expression
val description = when (x) {
    1 -> "One"
    2 -> "Two"
    3, 4 -> "Three or Four"
    in 5..10 -> "Between 5 and 10"
    else -> "Something else"
}

// When with arbitrary expressions
when {
    x.isOdd() -> print("x is odd")
    x.isEven() -> print("x is even")
    else -> print("x is funny")
}

// When with type checking
when (obj) {
    is String -> println("String of length ${obj.length}")
    is Int -> println("Integer value: $obj")
    is List<*> -> println("List with ${obj.size} elements")
    else -> println("Unknown type")
}

// When with ranges and collections
when (x) {
    in 1..10 -> println("x is in the range")
    in validNumbers -> println("x is valid")
    !in 10..20 -> println("x is outside the range")
    else -> println("none of the above")
}

// When without argument
when {
    x > 0 -> println("positive")
    x < 0 -> println("negative")
    else -> println("zero")
}
```

**Key points:**

- `when` expressions are exhaustive - all possible cases must be covered
- Can match values, ranges, types, and arbitrary conditions
- Multiple conditions can be combined with commas
- Smart casting occurs automatically in type-checked branches
- Can be used as statements or expressions

### For Loops and Ranges

Kotlin's `for` loops work with any iterable and provide powerful range operations.

```kotlin
// Basic for loop with range
for (i in 1..5) {
    println(i) // prints 1, 2, 3, 4, 5
}

// For loop with until (exclusive end)
for (i in 1 until 5) {
    println(i) // prints 1, 2, 3, 4
}

// For loop with step
for (i in 1..10 step 2) {
    println(i) // prints 1, 3, 5, 7, 9
}

// Downward for loop
for (i in 5 downTo 1) {
    println(i) // prints 5, 4, 3, 2, 1
}

// For loop with collections
val items = listOf("apple", "banana", "cherry")
for (item in items) {
    println(item)
}

// For loop with indices
for (i in items.indices) {
    println("$i: ${items[i]}")
}

// For loop with index and value
for ((index, value) in items.withIndex()) {
    println("$index: $value")
}

// For loop with maps
val map = mapOf("a" to 1, "b" to 2, "c" to 3)
for ((key, value) in map) {
    println("$key -> $value")
}

// Custom progressions
for (i in 2..10 step 2) {
    println(i) // prints 2, 4, 6, 8, 10
}
```

**Key points:**

- Ranges are inclusive by default (`..`) or exclusive with `until`
- `step` allows custom increments
- `downTo` creates descending ranges
- `indices` property provides valid index range for collections
- `withIndex()` returns index-value pairs
- Destructuring works in for loops

### While and Do-While Loops

Traditional loop constructs for condition-based iteration.

```kotlin
// While loop
var i = 0
while (i < 5) {
    println(i)
    i++
}

// Do-while loop (executes at least once)
var j = 0
do {
    println(j)
    j++
} while (j < 3)

// While with complex conditions
var input: String?
while (readLine().also { input = it } != "quit") {
    println("You entered: $input")
}

// Infinite loops with break
while (true) {
    val line = readLine() ?: break
    if (line.isEmpty()) break
    processLine(line)
}
```

**Key points:**

- `while` checks condition before execution
- `do-while` executes body at least once
- Can use complex conditions and assignments
- Often used with `break` for controlled termination

### Break and Continue with Labels

Kotlin supports labeled breaks and continues for controlling nested loop execution.

```kotlin
// Basic break and continue
for (i in 1..10) {
    if (i == 5) continue // skip 5
    if (i == 8) break    // stop at 8
    println(i)
}

// Labeled break in nested loops
outer@ for (i in 1..3) {
    inner@ for (j in 1..3) {
        if (i == 2 && j == 2) break@outer
        println("$i, $j")
    }
}

// Labeled continue
loop@ for (i in 1..5) {
    for (j in 1..3) {
        if (j == 2) continue@loop
        println("$i, $j")
    }
}

// Labels with when expressions
fun processNumbers(numbers: List<Int>) {
    processing@ for (num in numbers) {
        when {
            num < 0 -> continue@processing
            num == 0 -> break@processing
            num > 100 -> {
                println("Large number: $num")
                continue@processing
            }
            else -> println("Processing: $num")
        }
    }
}

// Labels with forEach
numbers.forEach lit@{ number ->
    if (number < 0) return@lit // continue to next iteration
    if (number == 0) return    // return from enclosing function
    println(number)
}
```

**Key points:**

- Labels are defined with `@` syntax
- `break@label` exits the labeled loop
- `continue@label` continues with next iteration of labeled loop
- Labels work with any expression, not just loops
- `return@label` in lambda expressions returns from the labeled scope

### Advanced Control Flow Patterns

```kotlin
// Elvis operator with control flow
val name = getName() ?: return "No name provided"

// Let with control flow
user?.let { u ->
    if (u.isValid()) {
        processUser(u)
    } else {
        return "Invalid user"
    }
}

// When with sealed classes
sealed class Result
object Success : Result()
data class Error(val message: String) : Result()

fun handleResult(result: Result) = when (result) {
    is Success -> println("Success!")
    is Error -> println("Error: ${result.message}")
}

// Try-catch as expression
val result = try {
    riskyOperation()
} catch (e: Exception) {
    "Error: ${e.message}"
}
```

**Key points:**

- Control structures integrate with Kotlin's null safety
- Sealed classes work excellently with `when` expressions
- Exception handling can be used as expressions
- Scope functions provide additional control flow options

### Performance Considerations

```kotlin
// Prefer when over multiple if-else for performance
// Good
when (value) {
    1 -> action1()
    2 -> action2()
    3 -> action3()
    else -> defaultAction()
}

// Less efficient for many conditions
if (value == 1) action1()
else if (value == 2) action2()
else if (value == 3) action3()
else defaultAction()

// Use ranges efficiently
val isValid = x in 1..100 // More efficient than x >= 1 && x <= 100

// Avoid creating unnecessary objects in loops
// Bad
for (i in 1..1000) {
    val list = mutableListOf<String>() // Creates new list each iteration
    // ...
}

// Good
val list = mutableListOf<String>()
for (i in 1..1000) {
    list.clear()
    // ...
}
```

**Key points:**

- `when` expressions are optimized for multiple conditions
- Range checks are optimized internally
- Avoid object creation in tight loops
- Consider using sequence operations for large datasets

---

