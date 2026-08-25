## Strings (`string`)


Strings in C++ can be represented using the standard library's `std::string` class.

### Include Header

To use `std::string`, you need to include the `<string>` header file:

```cpp
#include <string>
```

### Declaration and Initialization

```cpp
std::string str;                // Empty string
std::string greeting = "Hello"; // Initialized string
std::string name("John");       // Another initialization
```

### String Operations

- **Concatenation**: Use the `+` operator or `append()` method.

    ```cpp
    std::string firstName = "John";
    std::string lastName = "Doe";
    std::string fullName = firstName + " " + lastName;
    ```

- **Accessing Characters**: Use the `[]` operator or `at()` method.

    ```cpp
    char firstChar = fullName[0];         // Access first character
    char lastChar = fullName.at(fullName.size() - 1); // Access last character
    ```

- **Length**: Use the `length()` or `size()` method to get the length of the string.

    ```cpp
    int length = fullName.length();        // or fullName.size()
    ```

- **Substrings**: Use the `substr()` method to get a substring.

    ```cpp
    std::string part = fullName.substr(0, 4); // Extract first four characters
    ```

- **Comparison**: Use comparison operators like `==`, `!=`, `<`, `>`, `<=`, `>=`.

    ```cpp
    if (str1 == str2) {
        // Strings are equal
    }
    ```

- **Iterating Over Characters**:

    ```cpp
    for (char c : fullName) {
        // Process each character
    }
    ```

### Input and Output:

- **Input**: Use `std::cin` for input.

    ```cpp
    std::string input;
    std::cin >> input;
    ```

- **Output**: Use `std::cout` for output.

    ```cpp
    std::cout << fullName << std::endl;
    ```

### String Manipulation:

- **Appending**: Use `append()` or `+=` operator.

    ```cpp
    str.append(" World");
    str += "!";
    ```

- **Erasing**: Use `erase()` method.

```cpp
std::string str = "Hello, World!";
str.erase(5, 7); // Removes ", World"
// Result: "Hello!"

// You can also erase a range of characters
// by providing iterators that specify the
// start and end of the range.
std::string str2 = "Hello, World!";
str2.erase(str2.begin() + 5, str2.end()); // Removes ", World!"
// Result: "Hello"
```

- **Finding Substrings**: Use `find()` method.

    ```cpp
    size_t found = str.find("Hello");
    if (found != std::string::npos) {
        // Substring found
    }
    ```

`std::string::npos` is a constant static member of the `std::string` class in C++. It represents the largest possible value for the `size_t` type, which is an unsigned integer type. *This value is typically used to indicate that a substring or character was not found within a string, or to denote the end of a string.*

### String Conversion:

- **C-Style Strings**: Convert `std::string` to C-style string using `c_str()` method.

    ```cpp
    const char* cString = str.c_str();
    ```

- **String to Int/Double**: Use `std::stoi` and `std::stod` for conversion.

    ```cpp
    int num = std::stoi(str);
    double d = std::stod(str);
    ```

### String Literal:

- Use double quotes `" "` to represent string literals.

    ```cpp
    const char* message = "Hello, World!";
    ```

***

