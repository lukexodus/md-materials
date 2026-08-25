## Code Optimization Techniques


Code optimization focuses on algorithmic efficiency, memory allocation patterns, and leveraging Android-specific performance characteristics to reduce CPU usage and improve application responsiveness.

**Algorithmic Complexity Optimization** Algorithm selection significantly impacts performance, particularly for data processing operations. Choosing appropriate data structures like HashMap for O(1) lookups versus ArrayList for sequential access patterns directly affects execution speed.

```kotlin
// Inefficient nested loop approach - O(n²)
fun findCommonElements(list1: List<String>, list2: List<String>): List<String> {
    val result = mutableListOf<String>()
    for (item1 in list1) {
        for (item2 in list2) {
            if (item1 == item2) {
                result.add(item1)
                break
            }
        }
    }
    return result
}

// Optimized using Set intersection - O(n + m)
fun findCommonElementsOptimized(list1: List<String>, list2: List<String>): List<String> {
    val set1 = list1.toSet()
    return list2.filter { it in set1 }
}
```

**Object Allocation Optimization** Reducing object creation frequency minimizes garbage collection pressure and improves performance, particularly in frequently executed code paths like drawing operations or data processing loops.

```kotlin
// Pool pattern for expensive object reuse
class ObjectPool<T>(private val factory: () -> T, private val reset: (T) -> Unit) {
    private val pool = mutableListOf<T>()
    
    fun acquire(): T {
        return if (pool.isNotEmpty()) {
            pool.removeAt(pool.size - 1)
        } else {
            factory()
        }
    }
    
    fun release(item: T) {
        reset(item)
        pool.add(item)
    }
}

// Usage for expensive bitmap operations
private val bitmapPool = ObjectPool(
    factory = { Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888) },
    reset = { bitmap -> bitmap.eraseColor(Color.TRANSPARENT) }
)
```

**String Concatenation Optimization** String operations in performance-critical code should use StringBuilder or string templates instead of repeated concatenation to avoid creating intermediate string objects.

```kotlin
// Inefficient string concatenation
fun buildQuery(filters: List<String>): String {
    var query = "SELECT * FROM table WHERE "
    for (i in filters.indices) {
        query += "${filters[i]} AND "
    }
    return query.dropLast(5)
}

// Optimized using StringBuilder
fun buildQueryOptimized(filters: List<String>): String {
    return buildString {
        append("SELECT * FROM table WHERE ")
        filters.forEachIndexed { index, filter ->
            append(filter)
            if (index < filters.size - 1) append(" AND ")
        }
    }
}
```

**Method Inlining and Call Overhead** Kotlin's inline functions eliminate function call overhead for higher-order functions, particularly beneficial for frequently called utility functions and lambda operations.

```kotlin
// Inline function reduces call overhead
inline fun <T> measureTime(block: () -> T): Pair<T, Long> {
    val startTime = System.nanoTime()
    val result = block()
    val endTime = System.nanoTime()
    return result to (endTime - startTime)
}

// Extension function optimization for collections
inline fun <T> Collection<T>.countWhere(predicate: (T) -> Boolean): Int {
    var count = 0
    for (element in this) {
        if (predicate(element)) count++
    }
    return count
}
```

**Lazy Initialization Patterns** Deferring expensive object creation until actually needed improves application startup time and reduces memory footprint for conditionally used components.

```kotlin
class ExpensiveResourceManager {
    private val expensiveResource by lazy {
        // Heavy initialization only when first accessed
        loadExpensiveResource()
    }
    
    private val computedData by lazy(LazyThreadSafetyMode.NONE) {
        // Single-threaded lazy initialization
        performExpensiveComputation()
    }
    
    fun getResource() = expensiveResource
}
```

**Primitive Collections** Using primitive-specialized collections like SparseArray instead of generic collections reduces boxing overhead and memory usage for numeric keys.

```kotlin
// Generic HashMap with boxing overhead
val genericMap = HashMap<Int, String>()

// SparseArray avoids Integer boxing
val sparseArray = SparseArray<String>()

// IntArray vs List<Int> for primitive arrays
val primitiveArray = IntArray(1000) // More memory efficient
val boxedList = List(1000) { 0 } // Higher memory overhead
```

