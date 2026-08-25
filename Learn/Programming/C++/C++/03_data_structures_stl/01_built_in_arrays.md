## Built-in Arrays


### Array Declaration:

In C++, an array is a fixed-size collection of elements of the same type. To declare an array, you specify the type of elements it will contain, followed by the array name and the size of the array in square brackets `[]`.

```cpp
type arrayName[arraySize];
```

For example, to declare an array of integers with 5 elements:

```cpp
int numbers[5];
```

### Array Initialization:

1. **Initializing at Declaration**: You can initialize the array when you declare it by enclosing the initial values in curly braces `{}`:

```cpp
int numbers[5] = {1, 2, 3, 4, 5};
```

2. **Partial Initialization**: You can partially initialize an array, leaving some elements uninitialized. In this case, the remaining elements are implicitly initialized to zero (for numeric types) or a null pointer (for pointer types):

```cpp
int numbers[5] = {1, 2}; // Initializes first two elements, rest are zero-initialized
```

3. **Designated Initializers (C++20)**: In C++20, you can specify the index of each element to initialize:

```cpp
int numbers[5] = { [2] = 3, [4] = 7 }; // Initializes elements at indices 2 and 4
```

Example:

```cpp
#include <iostream>

int main() {
    // Array declaration and initialization
    int numbers[5] = {1, 2, 3, 4, 5};

    // Array typing: All elements are of type int

    // Output the elements of the array
    std::cout << "Array elements: ";
    for (int i = 0; i < 5; ++i) {
        std::cout << numbers[i] << " ";
    }
    std::cout << std::endl;

    return 0;
}
```

***


