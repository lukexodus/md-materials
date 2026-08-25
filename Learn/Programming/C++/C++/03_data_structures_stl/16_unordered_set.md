## unordered_set


### Overview

`unordered_set` is an **unordered, unique** collection in C++. It **stores elements in no particular order** and ensures that **no duplicate elements exist**. It is implemented using a **hash table**, providing an **average complexity of O(1)** for **search, insertion, and deletion** (compared to `O(log n)` in `set`).

### Syntax

```cpp
#include <iostream>
#include <unordered_set>

int main() {
    std::unordered_set<int> us = {5, 1, 3, 2, 4};

    // Inserting elements
    us.insert(6);
    us.insert(2);  // Duplicate, ignored

    // Iterating over elements (unordered)
    for (int num : us) {
        std::cout << num << " ";
    }

    return 0;
}
```

**Possible Output:**

```
3 1 5 2 4 6
```

(Note: The order **may vary** due to hashing.)

### Key Features

- **Unordered & Unique:** Elements are stored in an arbitrary order.
- **Faster Search, Insert, and Delete (O(1) on average):** Uses a hash table for efficient lookups.
- **No Direct Access via Index:** Elements must be accessed using iterators.
- **Slower in Worst Case (O(n)):** If many elements collide in the same hash bucket, operations may degrade to `O(n)`.

### Important Methods

#### Inserting and Erasing Elements

```cpp
std::unordered_set<int> us = {10, 20, 30};
us.insert(25);  // Inserts 25
us.erase(20);   // Removes 20
```

#### Checking Existence

```cpp
if (us.count(10)) {  // Returns 1 if element exists, 0 otherwise
    std::cout << "10 is in the set\n";
}
```

or using `find()`:

```cpp
if (us.find(10) != us.end()) {
    std::cout << "10 is in the set\n";
}
```

#### Iterating Over an Unordered Set

```cpp
for (int num : us) {
    std::cout << num << " ";
}
```

or using iterators:

```cpp
for (auto it = us.begin(); it != us.end(); ++it) {
    std::cout << *it << " ";
}
```

### Comparison: `set` vs. `unordered_set`

| Feature              | `set` (Ordered)   | `unordered_set` (Unordered)           |
| -------------------- | ----------------- | ------------------------------------- |
| Ordering             | Sorted order      | No specific order                     |
| Insertion Complexity | `O(log n)` (Tree) | `O(1)` (Hash Table)                   |
| Search Complexity    | `O(log n)`        | `O(1)` (Average), `O(n)` (Worst Case) |
| Duplicate Elements   | Not allowed       | Not allowed                           |
|                      |                   |                                       |

---

