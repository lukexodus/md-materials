## Basic Project Structure and Compilation Process


### Main File (`main.cpp`):

```cpp
#include "example.h" // Include header file

int main() {
    greet("World"); // Call function declared in header file
    return 0;
}
```

- **Purpose**: `main.cpp` serves as the entry point of the program.
- **Usage**: It includes necessary header files and calls functions defined elsewhere.

### Header File (`example.h`):

```cpp
#ifndef EXAMPLE_H
#define EXAMPLE_H

#include <string>

void greet(const std::string& name); // Function declaration

#endif // EXAMPLE_H
```

- **Purpose**: `example.h` contains function prototypes and class declarations.
- **Content**: Declarations of functions and classes without implementations.
- **Include Guards**: Prevents multiple inclusion of the same header file.

### Implementation File (`example.cpp`):

```cpp
#include "example.h" // Include corresponding header file

#include <iostream>

void greet(const std::string& name) {
    std::cout << "Hello, " << name << "!" << std::endl;
}
```

- **Purpose**: `example.cpp` provides the implementations for functions declared in the header file.
- **Content**: Actual code for functions and classes declared in the header file.

### Linking and Compilation Process:

1. **Preprocessing**:
   - Preprocessor (`cpp`) resolves `#include` directives and macros.
   - Generates preprocessed source files (`*.i`).

2. **Compilation**:
   - Compiler (`g++`, `clang++`) compiles source files (`*.cpp`) into object files (`*.o`).
   - Each source file is compiled independently, translating C++ code into machine-readable object code.

3. **Linking**:
   - Linker (`ld`) links object files and libraries into a single executable (`a.out` by default).
   - Resolves external references, combines object code, and generates the final executable file.

### Compilation Commands:

- **Compile and Link**:
  ```bash
  g++ -o my_program main.cpp example.cpp
  ```
  - Compiles `main.cpp` and `example.cpp` into object files and links them together into `my_program`.

- **Separate Compilation**:
  ```bash
  g++ -c example.cpp
  g++ -o my_program main.cpp example.o
  ```
  - Compiles `example.cpp` into `example.o` (object file) separately, then links it with `main.cpp` into `my_program`.

***

