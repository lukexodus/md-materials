## vector


### Declaration:

To use `std::vector`, you need to include the `<vector>` header file. Here's the basic syntax for declaring a `std::vector`:

```cpp
#include <vector>

std::vector<type> vecName;
```

For example, to declare a `std::vector` of integers:

```cpp
#include <vector>

std::vector<int> numbers;
```

### Initialization:

You can initialize a `std::vector` in several ways:

1. **Default Initialization**: Creates an empty vector.

    ```cpp
    std::vector<int> numbers;
    ```

2. **Size Initialization**: Creates a vector with a specified size, filled with default-initialized elements.

    ```cpp
    std::vector<int> numbers(5); // Creates a vector with 5 elements, initialized to 0
    ```

3. **List Initialization**: Initializes a vector with specific values.

    ```cpp
    std::vector<int> numbers = {1, 2, 3, 4, 5};
    ```

### Methods:

`std::vector` provides several methods to manipulate its contents:

1. **size()**: Returns the number of elements in the vector.
2. **push_back()**: Adds an element to the end of the vector.
3. **pop_back()**: Removes the last element from the vector.
4. **at()**: Accesses an element at a specified index with bounds checking.
5. **front()**: Returns a reference to the first element.
6. **back()**: Returns a reference to the last element.
7. **clear()**: Removes all elements from the vector.
8. **empty()**: Checks if the vector is empty.
9. **erase()**: Removes elements from the vector at a specified position or range.
10. **insert()**: Inserts elements into the vector at a specified position.
11. **resize()**: Changes the size of the vector.

### push_back():

```cpp
std::vector<int> numbers;
numbers.push_back(6);
```

### pop_back():

```cpp
std::vector<int> numbers = {1, 2, 3, 4, 5};
numbers.pop_back();
```

### size():

```cpp
std::vector<int> numbers = {1, 2, 3, 4, 5};
int size = numbers.size();
```

### at():

```cpp
std::vector<int> numbers = {1, 2, 3, 4, 5};
int value = numbers.at(2);
```

### front():

```cpp
std::vector<int> numbers = {1, 2, 3, 4, 5};
int firstElement = numbers.front();
```

### back():

```cpp
std::vector<int> numbers = {1, 2, 3, 4, 5};
int lastElement = numbers.back();
```

### clear():

```cpp
std::vector<int> numbers = {1, 2, 3, 4, 5};
numbers.clear();
```

### empty():

```cpp
std::vector<int> numbers = {1, 2, 3, 4, 5};
bool isEmpty = numbers.empty();
```

### erase():

```cpp
std::vector<int> numbers = {1, 2, 3, 4, 5};
numbers.erase(numbers.begin() + 2); // Erase element at index 2
```

### insert():

```cpp
std::vector<int> numbers = {1, 2, 3, 4, 5};
numbers.insert(numbers.begin() + 2, 10); // Insert 10 at index 2
```

### resize():

```cpp
std::vector<int> numbers = {1, 2, 3, 4, 5};
numbers.resize(3); // Resize vector to 3 elements
```


### Example:

```cpp
#include <iostream>
#include <vector>

int main() {
    // Declare and initialize a vector
    std::vector<int> numbers = {1, 2, 3, 4, 5};

    // Add an element to the end of the vector
    numbers.push_back(6);

    // Remove the last element from the vector
    numbers.pop_back();

    // Output the elements of the vector
    for (int num : numbers) {
        std::cout << num << " ";
    }
    std::cout << std::endl;

    return 0;
}
```

***

### `array` vs `vector`

- Use `std::array` when you need a fixed-size container with known size at compile time, especially for small and fixed-size collections.
- Use `std::vector` when you need dynamic resizing, flexibility in size, or when the size is not known at compile time.
- Consider the overhead of dynamic memory allocation when choosing between `std::array` and `std::vector`. If the size is fixed and known at compile time, `std::array` can offer better performance and determinism.

***

