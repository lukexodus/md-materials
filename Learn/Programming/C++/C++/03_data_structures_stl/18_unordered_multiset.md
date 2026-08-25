## unordered_multiset


### Overview

`unordered_multiset` is an **unordered associative container** that **allows multiple occurrences of the same value**. It is implemented using a **hash table**, providing **O(1) average-time complexity** for **insertion, deletion, and search**, but **O(n) worst case** when hash collisions occur.

### Syntax

```cpp
#include <iostream>
#include <unordered_set>

int main() {
    std::unordered_multiset<int> ums;

    // Inserting elements
    ums.insert(10);
    ums.insert(20);
    ums.insert(10);  // Duplicate allowed
    ums.insert(30);

    // Iterating over the unordered_multiset
    for (int num : ums) {
        std::cout << num << " ";
    }
    std::cout << "\n";

    return 0;
}
```

**Output (order may vary due to hashing):**

```
10 20 10 30  
```

### Key Features

- **Unordered storage** (elements are not stored in any specific order).
- **Allows duplicate values** (unlike `unordered_set`).
- **Implemented using a hash table**, making operations **O(1) on average**.
- **Fast insertion, deletion, and lookup**, but **iteration order is unpredictable**.

### Important Methods

#### Inserting Elements

```cpp
std::unordered_multiset<int> ums;
ums.insert(10);
ums.insert(20);
ums.insert(10);  // Duplicate allowed
ums.emplace(30);
```

#### Finding and Counting Elements

```cpp
auto it = ums.find(10);  // Returns iterator to any occurrence of 10
if (it != ums.end()) {
    std::cout << "Found: " << *it << "\n";
}

int count = ums.count(10);  // Number of times 10 appears
std::cout << "10 appears " << count << " times\n";
```

#### Erasing Elements

```cpp
ums.erase(10);  // Removes all occurrences of 10
```

### Comparison: `unordered_set` vs. `unordered_multiset`

| Feature              | `unordered_set` (Unique Elements) | `unordered_multiset` (Duplicates Allowed) |
| -------------------- | --------------------------------- | ----------------------------------------- |
| Ordering             | Unordered                         | Unordered                                 |
| Duplicates           | Not allowed                       | Allowed                                   |
| Insertion Complexity | `O(1)` on average                 | `O(1)` on average                         |
| Search Complexity    | `O(1)` on average                 | `O(1)` on average                         |
| Iteration            | Unordered                         | Unordered                                 |

---

