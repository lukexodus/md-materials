## multiset


### Overview

`multiset` is an **ordered associative container** that allows **duplicate elements**. It stores elements in **sorted order**, like `set`, but **allows multiple occurrences** of the same value. It is implemented as a **self-balancing binary search tree (usually a Red-Black Tree)**, providing **O(log n) complexity** for **insertion, deletion, and search**.

### Syntax

```cpp
#include <iostream>
#include <set>

int main() {
    std::multiset<int> ms = {5, 1, 3, 2, 4, 3, 1};

    // Inserting elements
    ms.insert(6);
    ms.insert(3);  // Duplicate allowed

    // Iterating over elements (sorted)
    for (int num : ms) {
        std::cout << num << " ";
    }

    return 0;
}
```

**Output:**

```
1 1 2 3 3 3 4 5 6
```

### Key Features

- **Stores elements in sorted order** (ascending by default).
- **Allows duplicate values** (unlike `set`).
- **Implemented as a balanced BST**, making operations **O(log n)**.
- **No direct access via index**—use iterators.

### Important Methods

#### Inserting and Erasing Elements

```cpp
std::multiset<int> ms = {10, 20, 30};
ms.insert(20);  // Inserts another 20
ms.insert(25);  // Inserts 25

// Erase only one occurrence of 20
ms.erase(ms.find(20));

// Erase all occurrences of 10
ms.erase(10);
```

#### Counting Occurrences of an Element

```cpp
int count = ms.count(20);  // Returns number of times 20 appears
```

#### Finding Elements

```cpp
auto it = ms.find(20);  // Points to first occurrence of 20
if (it != ms.end()) {
    std::cout << "20 is in the multiset\n";
}
```

#### Iterating Over a multiset

```cpp
for (int num : ms) {
    std::cout << num << " ";
}
```

or using iterators:

```cpp
for (auto it = ms.begin(); it != ms.end(); ++it) {
    std::cout << *it << " ";
}
```

### Comparison: `set` vs. `multiset`

|Feature|`set` (Unique)|`multiset` (Duplicates Allowed)|
|---|---|---|
|Ordering|Sorted order|Sorted order|
|Duplicates|Not allowed|Allowed|
|Insertion Complexity|`O(log n)`|`O(log n)`|
|Search Complexity|`O(log n)`|`O(log n)`|
|Deletion Complexity|`O(log n)`|`O(log n)`|

---

