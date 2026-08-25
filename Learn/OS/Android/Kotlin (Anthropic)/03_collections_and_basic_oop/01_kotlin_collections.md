## Kotlin Collections


### Lists, Sets, and Maps

Kotlin provides three main collection types, each serving different purposes and offering both immutable and mutable variants.

#### Lists

Lists are ordered collections that allow duplicate elements and provide indexed access.

```kotlin
// Immutable list creation
val fruits = listOf("apple", "banana", "orange")
val numbers = listOf(1, 2, 3, 4, 5)
val mixedList = listOf("text", 42, true, 3.14)

// Mutable list creation
val mutableFruits = mutableListOf("apple", "banana")
val dynamicNumbers = mutableListOf<Int>()

// List operations
val firstFruit = fruits[0] // or fruits.first()
val lastFruit = fruits.last()
val size = fruits.size
val contains = fruits.contains("apple")
val index = fruits.indexOf("banana")
```

#### Sets

Sets are collections of unique elements without duplicates, useful for membership testing.

```kotlin
// Immutable set creation
val uniqueNumbers = setOf(1, 2, 3, 2, 1) // Result: [1, 2, 3]
val colors = setOf("red", "green", "blue")

// Mutable set creation
val mutableColors = mutableSetOf("red", "green")
val dynamicSet = mutableSetOf<String>()

// Set operations
val hasRed = colors.contains("red")
val union = setOf(1, 2, 3) union setOf(3, 4, 5) // [1, 2, 3, 4, 5]
val intersection = setOf(1, 2, 3) intersect setOf(2, 3, 4) // [2, 3]
val difference = setOf(1, 2, 3) - setOf(2, 3) // [1]
```

#### Maps

Maps store key-value pairs and provide fast lookups by key.

```kotlin
// Immutable map creation
val capitals = mapOf(
    "USA" to "Washington D.C.",
    "France" to "Paris",
    "Japan" to "Tokyo"
)

// Mutable map creation
val mutableCapitals = mutableMapOf("USA" to "Washington D.C.")
val dynamicMap = mutableMapOf<String, Int>()

// Map operations
val usCapital = capitals["USA"]
val keys = capitals.keys
val values = capitals.values
val entries = capitals.entries
val containsKey = capitals.containsKey("France")
val containsValue = capitals.containsValue("Paris")
```

**Key points:**

- Use `listOf()`, `setOf()`, `mapOf()` for immutable collections
- Use `mutableListOf()`, `mutableSetOf()`, `mutableMapOf()` for mutable collections
- Lists maintain insertion order and allow duplicates
- Sets automatically eliminate duplicates
- Maps provide O(1) average lookup time

### Mutable vs Immutable Collections

Understanding the distinction between mutable and immutable collections is crucial for writing safe and predictable code.

#### Immutable Collections

```kotlin
val immutableList = listOf(1, 2, 3)
// immutableList.add(4) // Compilation error - no add method

val immutableSet = setOf("a", "b", "c")
// immutableSet.remove("a") // Compilation error

val immutableMap = mapOf("key1" to "value1")
// immutableMap["key2"] = "value2" // Compilation error
```

#### Mutable Collections

```kotlin
val mutableList = mutableListOf(1, 2, 3)
mutableList.add(4)
mutableList.remove(2)
mutableList[0] = 10

val mutableSet = mutableSetOf("a", "b", "c")
mutableSet.add("d")
mutableSet.remove("a")

val mutableMap = mutableMapOf("key1" to "value1")
mutableMap["key2"] = "value2"
mutableMap.remove("key1")
```

#### Collection Interfaces Hierarchy

```kotlin
// Read-only interfaces
val readOnlyList: List<String> = mutableListOf("a", "b")
val readOnlySet: Set<String> = mutableSetOf("a", "b")
val readOnlyMap: Map<String, Int> = mutableMapOf("a" to 1)

// Mutable interfaces extend read-only ones
val mutableList: MutableList<String> = mutableListOf("a", "b")
val mutableSet: MutableSet<String> = mutableSetOf("a", "b")
val mutableMap: MutableMap<String, Int> = mutableMapOf("a" to 1)
```

#### Converting Between Types

```kotlin
val immutableList = listOf(1, 2, 3)
val mutableCopy = immutableList.toMutableList()

val mutableList = mutableListOf(1, 2, 3)
val immutableCopy = mutableList.toList()

// Creating defensive copies
fun processItems(items: List<String>): List<String> {
    return items.toList() // Creates a copy to prevent external modification
}
```

**Key points:**

- Immutable collections are thread-safe and prevent accidental modifications
- Mutable collections allow modifications but require careful handling in concurrent environments
- Use immutable collections by default, mutable only when necessary
- Collection interfaces provide read-only views even of mutable collections

### Collection Operations

Kotlin provides extensive functional programming capabilities for collection manipulation.

#### Filtering Operations

```kotlin
val numbers = listOf(1, 2, 3, 4, 5, 6, 7, 8, 9, 10)

// Basic filtering
val evenNumbers = numbers.filter { it % 2 == 0 }
val oddNumbers = numbers.filterNot { it % 2 == 0 }

// Filtering with index
val filteredWithIndex = numbers.filterIndexed { index, value ->
    index % 2 == 0 && value > 3
}

// Filtering non-null values
val nullableNumbers = listOf(1, null, 3, null, 5)
val nonNullNumbers = nullableNumbers.filterNotNull()

// Filtering by type
val mixedList = listOf(1, "hello", 3.14, "world", 42)
val strings = mixedList.filterIsInstance<String>()
```

#### Mapping Operations

```kotlin
val words = listOf("hello", "world", "kotlin")

// Basic mapping
val lengths = words.map { it.length }
val upperCase = words.map { it.uppercase() }

// Mapping with index
val indexedWords = words.mapIndexed { index, word ->
    "$index: $word"
}

// Flat mapping
val sentences = listOf("hello world", "kotlin programming")
val allWords = sentences.flatMap { it.split(" ") }

// Mapping non-null results
val nullableResults = words.mapNotNull { word ->
    if (word.length > 4) word.uppercase() else null
}
```

#### Reducing Operations

```kotlin
val numbers = listOf(1, 2, 3, 4, 5)

// Sum and product
val sum = numbers.sum()
val product = numbers.reduce { acc, n -> acc * n }

// Folding with initial value
val sumWithInitial = numbers.fold(10) { acc, n -> acc + n }
val concatenated = words.fold("") { acc, word -> acc + word }

// Finding elements
val firstEven = numbers.first { it % 2 == 0 }
val lastOdd = numbers.last { it % 2 == 1 }
val findResult = numbers.find { it > 3 } // Returns first match or null

// Aggregation operations
val max = numbers.maxOrNull()
val min = numbers.minOrNull()
val average = numbers.average()
```

#### Grouping and Partitioning

```kotlin
val words = listOf("apple", "banana", "apricot", "cherry", "avocado")

// Grouping by criteria
val groupedByLength = words.groupBy { it.length }
val groupedByFirstLetter = words.groupBy { it.first() }

// Partitioning
val (shortWords, longWords) = words.partition { it.length <= 5 }

// Chunking
val numbers = (1..10).toList()
val chunks = numbers.chunked(3)
```

#### Chaining Operations

```kotlin
val result = listOf(1, 2, 3, 4, 5, 6, 7, 8, 9, 10)
    .filter { it % 2 == 0 }
    .map { it * it }
    .filter { it > 10 }
    .sorted()
    .take(3)
```

**Key points:**

- Operations are lazy when possible and return new collections
- Use method chaining for readable data transformations
- `filter` removes elements, `map` transforms elements
- `reduce` requires non-empty collections, `fold` accepts initial values
- Operations like `find` return nullable results

### Array Basics and When to Use Them

Arrays in Kotlin are similar to arrays in other languages but with enhanced type safety and utility functions.

#### Array Creation

```kotlin
// Creating arrays
val intArray = arrayOf(1, 2, 3, 4, 5)
val stringArray = arrayOf("hello", "world", "kotlin")
val mixedArray = arrayOf(1, "hello", 3.14, true)

// Typed arrays
val typedIntArray: Array<Int> = arrayOf(1, 2, 3)
val nullableArray: Array<String?> = arrayOfNulls(5)

// Array creation with lambda
val squaredArray = Array(5) { i -> i * i }
val alphabetArray = Array(26) { i -> ('A' + i).toString() }
```

#### Primitive Arrays

```kotlin
// Specialized primitive arrays (more memory efficient)
val intArray = intArrayOf(1, 2, 3, 4, 5)
val doubleArray = doubleArrayOf(1.0, 2.0, 3.0)
val booleanArray = booleanArrayOf(true, false, true)
val charArray = charArrayOf('a', 'b', 'c')

// Creating primitive arrays with size
val zeros = IntArray(10) // Array of 10 zeros
val ones = IntArray(10) { 1 } // Array of 10 ones
val sequence = IntArray(10) { it } // [0, 1, 2, ..., 9]
```

#### Array Operations

```kotlin
val numbers = intArrayOf(1, 2, 3, 4, 5)

// Access and modification
val firstElement = numbers[0]
numbers[0] = 10

// Array properties
val size = numbers.size
val indices = numbers.indices
val isEmpty = numbers.isEmpty()

// Converting to collections
val list = numbers.toList()
val set = numbers.toSet()
val mutableList = numbers.toMutableList()

// Array iteration
for (number in numbers) {
    println(number)
}

for ((index, value) in numbers.withIndex()) {
    println("Index $index: $value")
}
```

#### Array vs Collection Operations

```kotlin
val array = arrayOf(1, 2, 3, 4, 5)
val list = listOf(1, 2, 3, 4, 5)

// Similar operations available on both
val filteredArray = array.filter { it > 2 } // Returns List<Int>
val filteredList = list.filter { it > 2 } // Returns List<Int>

val mappedArray = array.map { it * 2 } // Returns List<Int>
val mappedList = list.map { it * 2 } // Returns List<Int>

// Array-specific operations
val sortedArray = array.sorted() // Returns List<Int>
array.sort() // Sorts array in-place
```

#### When to Use Arrays

```kotlin
// Use arrays when:
// 1. Interoperating with Java code that expects arrays
fun processJavaArray(data: Array<String>) {
    // Java interop
}

// 2. Performance-critical code with primitive types
fun efficientMathOperation(data: IntArray): Int {
    var sum = 0
    for (i in data.indices) {
        sum += data[i] * data[i]
    }
    return sum
}

// 3. Fixed-size collections where size is known
fun createGrid(width: Int, height: Int): Array<Array<Int>> {
    return Array(height) { Array(width) { 0 } }
}

// 4. When you need mutable indexed access
fun bubbleSort(arr: IntArray) {
    for (i in 0 until arr.size - 1) {
        for (j in 0 until arr.size - i - 1) {
            if (arr[j] > arr[j + 1]) {
                val temp = arr[j]
                arr[j] = arr[j + 1]
                arr[j + 1] = temp
            }
        }
    }
}
```

#### Array vs List Comparison

```kotlin
// Arrays
val array = arrayOf(1, 2, 3)
// - Fixed size after creation
// - Mutable elements
// - Direct memory layout (primitive arrays)
// - Java interop friendly

// Lists
val list = listOf(1, 2, 3)
// - Can be truly immutable
// - More functional operations
// - Better for most use cases
// - Type-safe operations
```

**Key points:**

- Arrays have fixed size and mutable elements
- Use primitive arrays (`IntArray`, `DoubleArray`, etc.) for performance
- Lists are generally preferred over arrays in Kotlin
- Arrays are necessary for Java interoperability
- Array operations often return Lists, not Arrays

**Example:**

```kotlin
data class Student(val name: String, val grade: Int)

fun main() {
    val students = listOf(
        Student("Alice", 85),
        Student("Bob", 92),
        Student("Charlie", 78),
        Student("Diana", 96)
    )
    
    val analysis = students
        .filter { it.grade >= 80 }
        .map { "${it.name}: ${it.grade}" }
        .sorted()
        .joinToString(", ")
    
    println("High performers: $analysis")
    
    val gradesByFirstLetter = students
        .groupBy { it.name.first() }
        .mapValues { (_, students) -> students.map { it.grade }.average() }
    
    println("Average grades by first letter: $gradesByFirstLetter")
}
```

**Output:**

```
High performers: Alice: 85, Bob: 92, Diana: 96
Average grades by first letter: {A=85.0, B=92.0, C=78.0, D=96.0}
```

Understanding Kotlin collections is essential for effective data manipulation and functional programming. The rich set of operations available makes complex data transformations both readable and efficient.

---

