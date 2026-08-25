## Range-based For Loop


A range-based for loop is a convenient and concise way to iterate over elements in a container, such as arrays, vectors, lists, and other sequence-like data structures.

Here's the syntax of a range-based for loop:

```cpp
for (auto element : container) {
    // Loop body
}
```

Where:
- `element` is a variable that represents each element of the container in each iteration.
- `container` is the collection of elements to iterate over.

The range-based for loop iterates over each element in the container sequentially, assigning the value of each element to the variable `element` in turn. It automatically handles the beginning and end of the container, making it simpler and less error-prone than traditional loop constructs.

```cpp
#include <iostream>
#include <vector>

int main() {
    std::vector<int> numbers = {1, 2, 3, 4, 5};

    // Iterate over each element in the vector
    for (auto num : numbers) {
        std::cout << num << " ";
    }
    std::cout << std::endl;

    return 0;
}
```

---

