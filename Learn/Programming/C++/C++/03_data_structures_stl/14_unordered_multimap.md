## unordered_multimap


### Overview

`unordered_multimap` is an **unordered associative container** that **allows multiple values for the same key**. It is implemented using a **hash table**, providing **O(1) average-time complexity** for **insertion, deletion, and search**, but **O(n) worst case** when hash collisions occur.

### Syntax

```cpp
#include <iostream>
#include <unordered_map>

int main() {
    std::unordered_multimap<std::string, int> umm;

    // Inserting key-value pairs
    umm.insert({"apple", 10});
    umm.insert({"banana", 5});
    umm.insert({"apple", 15});  // Duplicate key

    // Iterating over the unordered_multimap
    for (const auto& pair : umm) {
        std::cout << pair.first << " -> " << pair.second << "\n";
    }

    return 0;
}
```

**Output (order may vary due to hashing):**

```
apple -> 10  
banana -> 5  
apple -> 15  
```

### Key Features

- **Unordered storage** (keys are not stored in any specific order).
- **Allows duplicate keys** (unlike `unordered_map`).
- **Implemented using a hash table**, making operations **O(1) on average**.
- **Fast insertion, deletion, and lookup**, but **iteration order is unpredictable**.

### Important Methods

#### Inserting Elements

```cpp
std::unordered_multimap<std::string, int> umm;
umm.insert({"apple", 10});
umm.insert({"apple", 15});
umm.emplace("banana", 5);
```

#### Finding and Counting Elements

```cpp
auto it = umm.find("apple");  // Returns iterator to first occurrence of "apple"
if (it != umm.end()) {
    std::cout << "Found: " << it->first << " -> " << it->second << "\n";
}

int count = umm.count("apple");  // Number of times "apple" appears
std::cout << "Apple appears " << count << " times\n";
```

#### Accessing All Values for a Given Key

```cpp
auto range = umm.equal_range("apple");
for (auto it = range.first; it != range.second; ++it) {
    std::cout << it->first << " -> " << it->second << "\n";
}
```

#### Erasing Elements

```cpp
umm.erase("banana");  // Removes all pairs with key "banana"
```

### Comparison: `unordered_map` vs. `unordered_multimap`

| Feature              | `unordered_map` (Unique Keys) | `unordered_multimap` (Duplicates Allowed) |
| -------------------- | ----------------------------- | ----------------------------------------- |
| Ordering             | Unordered                     | Unordered                                 |
| Duplicates           | Not allowed                   | Allowed                                   |
| Insertion Complexity | `O(1)` on average             | `O(1)` on average                         |
| Search Complexity    | `O(1)` on average             | `O(1)` on average                         |
| Iteration            | Unordered                     | Unordered                                 |

---

