## String Literals vs `std::string`


### String Literals

- **Definition**: String literals are arrays of constant characters, typically enclosed in double quotes (`" "`).
- **Type**: They are of type `const char[]`.
- **Lifetime**: They have static storage duration, meaning they exist for the lifetime of the program.
- **Usage**: Commonly used for fixed, unmodifiable strings.
- **Example**:
    ```cpp
    const char* str = "Hello, world!";
    ```

### `std::string`

- **Definition**: `std::string` is a class provided by the C++ Standard Library that represents a sequence of characters.
- **Type**: It is a part of the `std` namespace and is defined as `std::basic_string<char>`.
- **Lifetime**: The lifetime of a `std::string` object is managed by its scope and can be dynamically allocated and deallocated.
- **Usage**: Preferred for strings that need to be modified, manipulated, or when more functionality is required.
- **Example**:
    ```cpp
    std::string str = "Hello, world!";
    ```

### Key Differences

1. **Mutability**:
    - String literals are immutable; you cannot change their content.
    - `std::string` objects are mutable; you can modify their content.
2. **Memory Management**:
    - String literals are stored in read-only memory and have a fixed size.
    - `std::string` objects manage their own memory and can grow or shrink dynamically.
3. **Functionality**:
    - String literals offer basic functionality.
    - `std::string` provides a rich set of member functions for manipulation, comparison, and more.
4. **Safety**:
    - String literals can lead to undefined behavior if not handled correctly (e.g., modifying a string literal).
    - `std::string` is safer and more flexible, reducing the risk of common errors like buffer overflows.

### Example Usage

Here’s an example demonstrating both:

```cpp
#include <iostream>
#include <string>

int main() {
    // String literal
    const char* literal = "Hello, world!";
    std::cout << literal << std::endl;

    // std::string
    std::string str = "Hello, world!";
    str += " How are you?";
    std::cout << str << std::endl;

    return 0;
}
```

***
