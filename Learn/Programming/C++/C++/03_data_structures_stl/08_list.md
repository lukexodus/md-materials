## list


### Overview

`list` is a **doubly linked list** container in C++. It allows **efficient insertion and deletion** at both the beginning and the end, as well as in the middle of the sequence, making it useful when frequent modifications are needed. However, **random access (e.g., using an index like `vec[i]`) is not supported** since elements are not stored contiguously in memory.

`std::list` is implemented as a doubly linked list, where each element (node) contains pointers to both the previous and next elements. This allows for **constant time** insertion and deletion operations at any position in the list, provided you have an iterator pointing to that position. This means that you can insert or remove an element without needing to shift any other elements.

### Syntax

```cpp
#include <iostream>
#include <list>

int main() {
    std::list<int> numbers = {1, 2, 3, 4, 5};

    // Adding elements
    numbers.push_back(6);
    numbers.push_front(0);

    // Iterating over elements
    for (int num : numbers) {
        std::cout << num << " ";
    }

    return 0;
}
```

**Output:**

```
0 1 2 3 4 5 6
```

**Key Features**

- **Doubly Linked List:** Each element has pointers to both the previous and next elements.
- **Efficient Insertions & Deletions:** `O(1)` complexity at the beginning or end.
- **No Random Access:** Accessing elements requires iteration (`O(n)` complexity).

### Important Methods

#### Insert and Remove Elements

```cpp
std::list<int> lst = {10, 20, 30};
lst.push_back(40);   // Adds 40 at the end
lst.push_front(5);   // Adds 5 at the beginning
lst.insert(++lst.begin(), 15); // Inserts 15 at second position
lst.erase(--lst.end()); // Removes last element
lst.pop_front(); // Removes first element
lst.pop_back();  // Removes last element
```

#### Iterating Over a List

```cpp
for (int num : lst) {
    std::cout << num << " ";
}
```

#### Sorting and Reversing

```cpp
lst.sort();   // Sorts in ascending order
lst.reverse(); // Reverses the order of elements
```

#### Merging Two Lists

```cpp
std::list<int> list1 = {1, 3, 5};
std::list<int> list2 = {2, 4, 6};
list1.merge(list2); // Merges list2 into list1 (both must be sorted)
```

#### Removing Duplicates

```cpp
lst.unique(); // Removes consecutive duplicate elements
```

---

