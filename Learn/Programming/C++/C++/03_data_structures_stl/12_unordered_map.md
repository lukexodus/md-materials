## unordered_map


### Overview

`unordered_map` is a container in the C++ Standard Library that stores key-value pairs with **fast average O(1) lookup, insertion, and deletion** times. Unlike `map`, which is implemented as a balanced binary search tree (O(log n) operations), `unordered_map` is implemented using a **hash table**, making it much faster for most use cases.

### Syntax

```cpp
#include <iostream>
#include <unordered_map>

int main() {
    std::unordered_map<std::string, int> age;
    
    // Inserting key-value pairs
    age["Alice"] = 25;
    age["Bob"] = 30;
    
    // Accessing values
    std::cout << "Alice's age: " << age["Alice"] << std::endl;
    
    return 0;
}
```

### Key Features

- **Unordered Storage:** The order of elements is not guaranteed.
- **Fast Lookups:** Average O(1) time complexity due to hashing.
- **Key Uniqueness:** Each key must be unique; inserting a duplicate key will overwrite the previous value.

### Important Methods

#### Insert Elements

```cpp
umap.insert({"Charlie", 22}); // Using pair
umap["David"] = 40;           // Direct insertion
```

#### Find and Access Elements

```cpp
if (umap.find("Alice") != umap.end()) {
    std::cout << "Alice exists with age " << umap["Alice"] << std::endl;
}
```

#### Iterate Over Elements

```cpp
for (const auto &pair : umap) {
    std::cout << pair.first << ": " << pair.second << std::endl;
}
```

#### Erase Elements

```cpp
umap.erase("Bob"); // Removes key "Bob"
```

#### Size and Empty Check

```cpp
std::cout << "Size: " << umap.size() << std::endl;
std::cout << "Is empty? " << (umap.empty() ? "Yes" : "No") << std::endl;
```

### Hash Function and Custom Keys

By default, `unordered_map` uses `std::hash<KeyType>`. For custom key types, a custom hash function must be defined.

---

