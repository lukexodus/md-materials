## Input/Output (cin, cout, cerr, clog)


C++ provides four standard streams for input and output operations:

- **`cin`** – Standard input stream (used for reading input).
- **`cout`** – Standard output stream (used for displaying output).
- **`cerr`** – Standard error stream (used for displaying errors, unbuffered).
- **`clog`** – Standard logging stream (used for logging messages, buffered).

### Standard Input (`cin`)

`std::cin` is used to read input from the standard input device (keyboard).

**Example:**

```cpp
#include <iostream>

int main() {
    int age;
    std::cout << "Enter your age: ";
    std::cin >> age;
    std::cout << "Your age is: " << age << std::endl;
    return 0;
}
```

#### `scanf` vs `std::cin`
##### scanf:

- **C Standard Library**: `scanf` is a function from the C standard library, used for formatted input.
- **Format Specifiers**: Requires format specifiers to indicate the type of data being read (%d for integers, %f for floats, %s for strings, etc.).
- **Buffering Issues**: `scanf` can have buffering issues, especially when mixing with other input methods like `fgets`.
- **Error Handling**: Limited error handling capabilities. It returns the number of successfully assigned input items, making error detection challenging.

Example:

```c
int num;
scanf("%d", &num);
```

##### std::cin:

- **C++ Standard Library**: `std::cin` is an input stream object from the C++ standard library, part of the `iostream` header.
- **Type Safety**: `std::cin` provides type-safe input, automatically converting input to the appropriate data type.
- **No Format Specifiers**: Does not require format specifiers like `scanf`. Data types are inferred based on the variable type.
- **Buffering**: `std::cin` handles input buffering internally, making it safer and more convenient to use.
- **Error Handling**: Provides better error handling through stream states. You can check the stream state using `std::cin.fail()` or `std::cin.eof()`.

Example:

```cpp
int num;
std::cin >> num;
```

**Usage**:

- `scanf` is commonly used in C programming for its simplicity and familiarity, especially in competitive programming or when reading formatted data from files.
- `std::cin` is preferred in C++ for its type safety, better error handling, and integration with the object-oriented features of C++.

### Standard Output (`cout`)

`std::cout` is used to print output to the console.

**Example:**

```cpp
#include <iostream>

int main() {
    std::cout << "Hello, World!" << std::endl;
    return 0;
}
```

#### `printf` vs `std::cout`

##### printf:

- **C Standard Library Function**: `printf` is a function from the C standard library, and it's also available in C++.
- **Formatted Output**: `printf` allows you to format output using format specifiers. For example, `%d` for integers, `%f` for floating-point numbers, `%s` for strings, etc.
- **Less Type Safety**: `printf` is less type-safe compared to `std::cout`. It relies on format specifiers to determine the types of the arguments passed to it.
- **Slower**: `printf` tends to be slower than `std::cout` because it performs runtime type checking and formatting.
- **No Namespace**: `printf` is not part of a namespace, so it's a global function.

Example `printf` usage in C:

```c
int number = 10;
printf("The number is: %d\n", number);
```

##### std::cout:

- **C++ Standard Library**: `std::cout` is part of the C++ standard library, specifically the iostream library.
- **Type-Safe**: `std::cout` is type-safe and provides type checking at compile time. It doesn't require format specifiers.
- **Object-Oriented**: `std::cout` is an object of type `std::ostream`, which allows for method chaining and extensibility.
- **Slower Compile Time**: `std::cout` tends to increase compile time due to its complex nature and template-based design.
- **Namespaced**: `std::cout` belongs to the `std` namespace.

Example `std::cout` usage in C++:

```cpp
int number = 10;
std::cout << "The number is: " << number << std::endl;
```

***

#### `\n` vs `std::endl`

##### \n (newline character):

- `\n` is a special character in C and C++ that represents a newline.
- It is a simple character that inserts a newline into the output stream.
- It does not flush the output buffer, meaning it may not immediately display the output to the console.

Example usage with `std::cout`:

```cpp
std::cout << "Hello\nWorld";
```

##### std::endl:

- `std::endl` is a manipulator in C++ that not only inserts a newline character but also flushes the output buffer.
- Flushing the buffer ensures that all output is immediately displayed on the console, which can be useful for real-time output or debugging purposes.
- Flushing the buffer can be relatively expensive in terms of performance, especially if it's done frequently.

Example usage with `std::cout`:

```cpp
std::cout << "Hello" << std::endl << "World";
```

### Standard Error (`cerr`)

`std::cerr` is used for error messages. Unlike `std::clog`, it is **unbuffered**, meaning output appears immediately.

**Example:**

```cpp
#include <iostream>

int main() {
    std::cerr << "Error: Invalid input!" << std::endl;
    return 1;
}
```

### Standard Log (`clog`)

`std::clog` is similar to `std::cerr` but **buffered**, meaning it may delay output for performance reasons.

**Example:**

```cpp
#include <iostream>

int main() {
    std::clog << "Logging some information..." << std::endl;
    return 0;
}
```

**Key Features**

- `cin` reads input from the user.
- `cout` prints formatted output.
- `cerr` is used for error messages (unbuffered).
- `clog` is used for logging (buffered).

***

