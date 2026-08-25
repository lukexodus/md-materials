## `map` (Unordered Map)


In C++, `std::map` is a container provided by the Standard Template Library (STL) that stores elements in a sorted order based on keys. It allows for efficient retrieval, insertion, and deletion of key-value pairs.

### Key Features:

1. **Associative Lookup**: Provides efficient key-based lookup operations.
2. **Dynamic Size**: The size of a map can grow or shrink dynamically as elements are added or removed.
3. **Balanced Binary Search Tree**: Internally, `std::map` is typically implemented using a balanced binary search tree (usually a Red-Black Tree), which ensures efficient insertion, deletion, and search operations.

| Feature             | Description                                           |
| ------------------- | ----------------------------------------------------- |
| **Ordered**         | Elements are stored in **sorted order** (by key).     |
| **Key-Value Pairs** | Stores data as **`(key, value)`** pairs.              |
| **Unique Keys**     | Each key is **unique** (no duplicates).               |
| **Iterators**       | Provides bidirectional iterators (not random-access). |

#### Balanced Binary Search Trees

A **balanced binary search tree (BST)** is a type of binary search tree that maintains its height in a way that ensures efficient operations such as insertion, deletion, and search. The key characteristic of a balanced BST is that it keeps its height logarithmic relative to the number of nodes, which allows these operations to be performed in **O(log n)** time complexity.

**Characteristics of Balanced Binary Search Trees**

1. **Height-Balancing**:
    - In a balanced BST, the depth of the two subtrees of every node never differs by more than a certain amount (commonly 1). This ensures that the tree remains approximately balanced, preventing it from degenerating into a linked list.
2. **Self-Balancing**:
    - Many balanced BSTs, such as **AVL trees** and **Red-Black trees**, automatically adjust their structure during insertions and deletions to maintain balance. This self-balancing property is crucial for maintaining efficient performance
3. **Logarithmic Height**:
    - The height of a balanced BST is kept in logarithmic proportion to the number of nodes, which is essential for ensuring that operations remain efficient. For example, if a tree has `n` nodes, its height will be approximately `log(n)`.

**Types of Balanced Binary Search Trees**

1. **AVL Trees**:
    - AVL trees are a type of self-balancing BST where the difference in heights between the left and right subtrees (the balance factor) is at most 1 for every node. This strict balancing ensures that AVL trees are always balanced, leading to efficient operations.
2. **Red-Black Trees**:
    - Red-Black trees are another type of self-balancing BST that uses color properties (red and black) to maintain balance. They allow for a more relaxed balancing compared to AVL trees, which can lead to faster insertion and deletion operations in certain scenarios.
3. **Other Variants**:
    - There are other balanced trees, such as **2-3 trees** and **B-trees**, which are used in different contexts, particularly in databases and file systems.

### Example:

```cpp
#include <iostream>
#include <map>

int main() {
    std::map<int, std::string> myMap;

    // Inserting elements
    myMap.insert({1, "One"});
    myMap[2] = "Two";
    myMap[3] = "Three";

    // Accessing elements
    std::cout << "Value associated with key 2: " << myMap.at(2) << std::endl;

    // Iterating over elements
    for (auto it = myMap.begin(); it != myMap.end(); ++it) {
        std::cout << "Key: " << it->first << ", Value: " << it->second << std::endl;
    }
	// or...
	for (const auto& pair : mp) {
        std::cout << pair.first << ": " << pair.second << "\n";
    }

    // Erasing element
    myMap.erase(3);

    // Size check
    if (!myMap.empty()) {
        std::cout << "Size of map: " << myMap.size() << std::endl;
    }

    return 0;
}
```

### Common Methods in Vectors and Maps:

1. **`size()`**: Returns the number of elements in the container.
2. **`empty()`**: Checks if the container is empty.
3. **`clear()`**: Removes all elements from the container.
4. **Iterators**: Both vectors and maps support iterator-based traversal (`begin()`, `end()`, etc.).
5. **`operator[]`**: Allows access to elements by index (vectors) or key (maps).

### Methods:

1. **`insert`**: Inserts elements into the map.

```cpp
std::map<int, std::string> myMap;
myMap.insert(std::make_pair(1, "One"));
```

#### `std::make_pair`

`std::make_pair` is a utility function in C++ that simplifies the creation of `std::pair` objects. It is part of the C++ Standard Library and is particularly useful for constructing key-value pairs in associative containers like `std::map`.


1. **Type Deduction**:
    - One of the main advantages of `std::make_pair` is that it automatically deduces the types of the elements in the pair from the types of the arguments provided. This means you don't need to explicitly specify the types when creating a pair, making the code cleaner and less error-prone
- **Convenience**:
    - Using `make_pair` allows for a more concise syntax when creating pairs. Instead of manually specifying the types, you can simply pass the values, and the function will handle the rest.
- **Usage**:
    - The typical usage of `std::make_pair` is as follows:
        
```cpp
#include <iostream>
#include <utility> // for std::make_pair
#include <map>

int main() {
	std::map<int, std::string> myMap;
	myMap.insert(std::make_pair(1, "Apple")); // Using make_pair to create a pair
	myMap.insert(std::make_pair(2, "Banana"));

	for (const auto& pair : myMap) {
		std::cout << pair.first << ": " << pair.second << std::endl;
	}

	return 0;
}
```
        
**Comparison with `std::pair` Constructor**

While you can create a `std::pair` directly using its constructor, such as `std::pair<int, std::string>(1, "Apple")`, `std::make_pair` is often preferred for its simplicity and type deduction capabilities. The constructor requires you to specify the types explicitly, which can lead to verbosity and potential mismatches if the types are not correctly aligned.

2. **`erase`**: Removes elements from the map by key.

```cpp
myMap.erase(1);
```

3. **`find`**: Searches for an element with a specified key.

```cpp
auto it = myMap.find(1);
if (it != myMap.end()) {
    // Key found, access value: it->second
}
```

4. **`at`**: Accesses the element with the specified key and throws an exception if the key is not found.

```cpp
std::string value = myMap.at(1);
```

**`at` vs `find`**

- **Access Method**: `at` provides direct access to the value, while `find` provides an iterator to the key-value pair.
- **Error Handling**: `at` throws an exception (`std::out_of_range`) for non-existent keys, whereas `find` returns an iterator to `end()`.
- **Modification**: `at` allows direct modification of the value, while `find` requires dereferencing the iterator to modify the value.

5. **`count`**: Returns the number of elements with a specified key.

```cpp
std::map<int, std::string> mp = {{1, "One"}, {2, "Two"}};

std::cout << mp[1] << "\n";      // One
std::cout << mp.at(2) << "\n";   // Two
std::cout << (mp.count(3) ? "Exists" : "Not Found") << "\n";  // Not Found
```

Since `std::map` only allows unique keys, the `count` method will always return either:

- **1**: if the key exists in the map.
- **0**: if the key does not exist in the map.

6. **`size`**: Returns the number of elements in the map.

```cpp
int size = myMap.size();
```

7. **`empty`**: Checks if the map is empty.

```cpp
if (!myMap.empty()) {
    // Map is not empty
}
```

8. **Iterating Over Elements**:
    - Maps provide iterators to traverse through the elements in sorted order based on the keys.

```cpp
std::map<int, std::string> myMap;

// Insert some key-value pairs
myMap[1] = "One";
myMap[2] = "Two";
myMap[3] = "Three";

// Iterate over the map
for (auto it = myMap.begin(); it != myMap.end(); ++it) {
	std::cout << "Key: " << it->first << ", Value: " << it->second << std::endl;
}
```

9. **Clearing the Map**:
    - Removes all elements from the map.

```cpp
myMap.clear();
```

10. **`emplace`**: Constructs and inserts an element into the map in-place.

```cpp
myMap.emplace(5, "Five");
```

#### **`insert` vs `emplace`**

`map::insert`

- **Functionality**: The `insert` method requires an existing object of the type to be inserted. It takes either a single `std::pair` (representing a key-value pair) or two separate arguments (key and value).
- **Copying**: When you use `insert`, the object is copied into the map. This means that if you have a complex object, it will incur the overhead of copying it into the map.

`map::emplace`

- **Functionality**: The `emplace` method constructs the element in place using the provided arguments. It forwards the arguments to the constructor of the element type, which allows for more efficient insertion.
- **No Copying**: Since `emplace` constructs the object directly in the map, it avoids the overhead of copying or moving the object. This is particularly beneficial for objects that are expensive to copy.
- **Variadic Templates**: `emplace` can take multiple arguments, allowing you to construct the key-value pair directly without needing to create an intermediate object.

**(C) Iterators**

| **Method**    | **Description**                        |     |
| ------------- | -------------------------------------- | --- |
| `mp.begin()`  | Iterator to first element.             |     |
| `mp.end()`    | Iterator past the last element.        |     |
| `mp.rbegin()` | Reverse iterator to last element.      |     |
| `mp.rend()`   | Reverse iterator before first element. |     |

**Complexity**

- Average time complexity for insertion, deletion, and search operations is O(log n), where n is the number of elements in the map.
- The worst-case time complexity is also O(log n) for balanced trees.

### **`map` vs `unordered_map`**

|Feature|`std::map` (Ordered)|`std::unordered_map` (Hash Table)|
|---|---|---|
|**Sorting**|Sorted (BST)|Unordered (Hashing)|
|**Insertion/Lookup**|O(log n)|O(1) avg, O(n) worst|
|**Memory Usage**|Higher (Tree)|Lower (Hash Table)|
|**Use Case**|Sorted data, range queries|Fast lookups|

🔹 **Use `map` when sorting is needed**  
🔹 **Use `unordered_map` when speed matters**

---

