## multimap


### Overview

`multimap` is a container in the C++ Standard Library that stores **key-value pairs where duplicate keys are allowed**. Unlike `map`, which ensures unique keys, `multimap` allows multiple elements to have the same key. It is implemented as a balanced binary search tree (typically a **Red-Black Tree**) and provides **logarithmic (O(log n))** time complexity for insertion, deletion, and lookup.

### Syntax

```cpp
#include <iostream>
#include <map>

int main() {
    std::multimap<std::string, int> grades;
    
    // Inserting elements
    grades.insert({"Alice", 90});
    grades.insert({"Bob", 85});
    grades.insert({"Alice", 95}); // Duplicate key allowed

    // Iterating over elements
    for (const auto &pair : grades) {
        std::cout << pair.first << ": " << pair.second << std::endl;
    }
    
    return 0;
}
```

### Key Features

- **Allows Duplicate Keys:** Multiple elements can have the same key.
- **Ordered Storage:** Elements are stored in **sorted order** based on keys.
- **Logarithmic Complexity:** Insertions, deletions, and lookups take **O(log n)** time.

### Important Methods

#### Insert Elements

```cpp
grades.insert({"Charlie", 78});
grades.insert({"Charlie", 82}); // Multiple entries for "Charlie"
```

#### Find and Access Elements

```cpp
auto range = grades.equal_range("Alice");
for (auto it = range.first; it != range.second; ++it) {
    std::cout << it->first << ": " << it->second << std::endl;
}
```
##### `std::multimap::equal_range` Method

The `equal_range` method in `std::multimap` is a useful function that allows you to retrieve all elements associated with a specific key. This method is particularly beneficial when you want to find all entries that match a given key in a multimap, which can contain multiple values for the same key.

- **Return Type**: The `equal_range` method returns a pair of iterators. The first iterator points to the first element that is not less than the specified key, while the second iterator points to the first element that is greater than the key. This effectively defines a range of elements that have the specified key.
- **Usage**: The method can be called as follows:

 ```cpp
std::pair<iterator, iterator> equal_range(const Key& key);
```
    
#### Iterate Over Elements

```cpp
for (const auto &pair : grades) {
    std::cout << pair.first << ": " << pair.second << std::endl;
}
```

#### Erase Elements

```cpp
grades.erase("Bob"); // Removes all entries with key "Bob"
```

#### Count Elements with a Key

```cpp
std::cout << "Alice has " << grades.count("Alice") << " grades recorded." << std::endl;
```

---

