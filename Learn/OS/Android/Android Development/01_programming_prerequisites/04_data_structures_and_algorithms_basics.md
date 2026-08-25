## Data Structures and Algorithms Basics


Understanding fundamental data structures and algorithms improves application performance, memory management, and problem-solving capabilities in Android development.

**Key Points:**

- Arrays, linked lists, stacks, and queues
- Hash tables and hash maps
- Trees (binary trees, binary search trees)
- Sorting algorithms (bubble sort, merge sort, quick sort)
- Searching algorithms (linear search, binary search)
- Time and space complexity analysis (Big O notation)
- Graph algorithms basics
- Dynamic programming concepts

**Example:**

```kotlin
class LRUCache<K, V>(private val capacity: Int) {
    private val cache = LinkedHashMap<K, V>(capacity, 0.75f, true)
    
    fun get(key: K): V? = cache[key]
    
    fun put(key: K, value: V) {
        if (cache.size >= capacity && !cache.containsKey(key)) {
            val firstKey = cache.keys.iterator().next()
            cache.remove(firstKey)
        }
        cache[key] = value
    }
}

// Binary search implementation
fun <T : Comparable<T>> binarySearch(array: Array<T>, target: T): Int {
    var left = 0
    var right = array.size - 1
    
    while (left <= right) {
        val mid = left + (right - left) / 2
        when {
            array[mid] == target -> return mid
            array[mid] < target -> left = mid + 1
            else -> right = mid - 1
        }
    }
    return -1
}
```

