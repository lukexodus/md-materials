## set


### Overview

`set` is an **ordered, unique** collection in C++. It **stores elements in a sorted order** and ensures that **no duplicate elements exist**. It is implemented as a **self-balancing binary search tree** (usually a Red-Black Tree), making **search, insertion, and deletion operations efficient** with `O(log n)` complexity.

### Syntax

```cpp
#include <iostream>
#include <set>

int main() {
    std::set<int> s = {5, 1, 3, 2, 4};

    // Inserting elements
    s.insert(6);
    s.insert(2);  // Duplicate, ignored

    // Iterating over elements (always sorted)
    for (int num : s) {
        std::cout << num << " ";
    }

    return 0;
}
```

**Output:**

```
1 2 3 4 5 6
```

### Key Features

- **Ordered & Unique:** Elements are stored in sorted order (ascending by default).
- **Efficient Search, Insert, and Delete:** `O(log n)` complexity due to the underlying Red-Black Tree.
- **No Direct Access via Index:** Elements must be accessed through iterators.

### Important Methods

#### Inserting and Erasing Elements

```cpp
std::set<int> s = {10, 20, 30};
s.insert(25);  // Inserts 25
s.erase(20);   // Removes 20
```

#### Checking Existence

```cpp
if (s.count(10)) {   // Returns 1 if element exists, 0 otherwise
    std::cout << "10 is in the set\n";
}
```

or using `find()`:

```cpp
if (s.find(10) != s.end()) {
    std::cout << "10 is in the set\n";
}
```

#### Iterating Over a Set

```cpp
for (int num : s) {
    std::cout << num << " ";
}
```

or using iterators:

```cpp
for (auto it = s.begin(); it != s.end(); ++it) {
    std::cout << *it << " ";
}
```

#### Finding Lower and Upper Bounds

```cpp
auto lb = s.lower_bound(25); // First element >= 25
auto ub = s.upper_bound(25); // First element > 25
```

---

