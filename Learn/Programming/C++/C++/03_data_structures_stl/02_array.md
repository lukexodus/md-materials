## `array`


### `std::array` Declaration:

`std::array` is a container class template provided by the C++ Standard Library. To use `std::array`, you need to include the `<array>` header file. Here's the basic syntax for declaring a `std::array`:

```cpp
#include <array>

std::array<type, size> arrayName;
```

For example, to declare a `std::array` of integers with 5 elements:

```cpp
#include <array>

std::array<int, 5> numbers;
```

### `std::array` Initialization:

`std::array` can be initialized similarly to built-in arrays in C++, using brace-initialization syntax. You can provide initial values for the elements enclosed in curly braces `{}`:

```cpp
std::array<int, 5> numbers = {1, 2, 3, 4, 5};
```

You can also partially initialize a `std::array`, leaving some elements uninitialized. In this case, the remaining elements are implicitly initialized to zero (for numeric types) or default-constructed (for other types).

**Example**:

Here's a complete example demonstrating `std::array` declaration, initialization, and typing:

```cpp
#include <iostream>
#include <array>

int main() {
    // Declaration and initialization of std::array
    std::array<int, 5> numbers = {1, 2, 3, 4, 5};

    // Typing: All elements are of type int

    // Output the elements of the std::array
    std::cout << "Array elements: ";
    for (int i = 0; i < 5; ++i) {
        std::cout << numbers[i] << " ";
    }
    std::cout << std::endl;

    return 0;
}
```

### Iterating Through `std::array`:

```cpp
#include <iostream>
#include <array>

int main() {
    std::array<int, 5> myArray = {1, 2, 3, 4, 5};

    // Using a range-based for loop
    for (int element : myArray) {
        std::cout << element << " ";
    }
    std::cout << std::endl;

    // Using iterators
    for (auto it = myArray.begin(); it != myArray.end(); ++it) {
        std::cout << *it << " ";
    }
    std::cout << std::endl;

    return 0;
}
```

### Methods

1. **`at`**: Accesses the element at a specified position, *with bounds checking*.

```cpp
std::array<int, 5> arr = {1, 2, 3, 4, 5};
int element = arr.at(2); // Retrieves the element at index 2
```

2. **`operator[]`**: Accesses the element at a specified position *without bounds checking*.

```cpp
int element = arr[2]; // Retrieves the element at index 2
```

3. **`front` and `back`**: Access the first and last elements of the array, respectively.

```cpp
int first = arr.front(); // Retrieves the first element
int last = arr.back();   // Retrieves the last element
```

4. **`fill`**: Assigns the same value to all elements of the array.

```cpp
arr.fill(0); // Fills the entire array with 0
```

5. **`size`**: Returns the number of elements in the array.

```cpp
size_t size = arr.size(); // Retrieves the size of the array
```

6. **`empty`**: Checks if the array is empty. Since `std::array` is always of fixed size, it will never be empty if its size is non-zero.

```cpp
bool isEmpty = arr.empty(); // Always returns false for std::array
```

7. **`data`**: Returns a pointer to the underlying array.

```cpp
int* ptr = arr.data(); // Retrieves a pointer to the underlying array
```

8. **`swap`**: Swaps the contents of two arrays of the same type and size.

```cpp
std::array<int, 5> arr1 = {1, 2, 3, 4, 5};
std::array<int, 5> arr2 = {6, 7, 8, 9, 10};
arr1.swap(arr2); // Swaps the contents of arr1 and arr2
```

9. **Comparison Operators**: `std::array` supports comparison operators (`==`, `!=`, `<`, `<=`, `>`, `>=`) for lexicographical comparison.

```cpp
std::array<int, 5> arr1 = {1, 2, 3, 4, 5};
std::array<int, 5> arr2 = {1, 2, 3, 4, 6};
if (arr1 < arr2) {
    // arr1 is lexicographically less than arr2
}
```

10. **Initialization**: `std::array` supports aggregate initialization and copy initialization.
```cpp
std::array<int, 5> arr1 = {1, 2, 3, 4, 5}; // Aggregate initialization
std::array<int, 5> arr2(arr1); // Copy initialization from another array
```

11. **`begin` and `end`**: Return iterators pointing to the first and past-the-end elements of the array, respectively.

```cpp
auto beginIterator = arr.begin(); // Iterator to the first element
auto endIterator = arr.end();     // Iterator past the last element
```

12. **`rbegin` and `rend`**: Return reverse iterators pointing to the last and before-the-first elements of the reversed array, respectively.

```cpp
array<int, 5> arr = {1, 2, 3, 4, 5};

auto rbeginIterator = arr.rbegin(); // Reverse iterator to the last element
auto rendIterator = arr.rend();     // Reverse iterator before the first element

for (auto it = rbeginIterator; it != rendIterator; ++it) {
	cout << *it << " ";
}
```

13. **`operator==` and `operator!=`**: Compares two arrays for equality and inequality, respectively.

```cpp
if (arr1 == arr2) {
    // Arrays are equal
}
if (arr1 != arr2) {
    // Arrays are not equal
}
```

---

