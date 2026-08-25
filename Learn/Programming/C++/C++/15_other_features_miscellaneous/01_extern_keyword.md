## `extern` Keyword


In C++, the `extern` keyword is used to declare a variable or function that is defined in another translation unit (source file). It essentially tells the compiler that the declaration is referring to an entity that exists elsewhere, allowing for linkage across different files.

### Usage of `extern`

1. **Declaring Global Variables**

   When you declare a global variable with `extern`, you indicate that the variable's definition is located in another file.

   **Example:**

   - **File1.cpp** (Definition of the variable):
     ```cpp
     int globalVar = 42; // Definition of the global variable
     ```

   - **File2.cpp** (Declaration of the variable):
     ```cpp
     extern int globalVar; // Declaration of the global variable

     void printGlobal() {
         std::cout << globalVar << std::endl; // Uses the variable
     }
     ```

   In this example:
   - `globalVar` is defined in `File1.cpp` and declared with `extern` in `File2.cpp`.
   - This allows `File2.cpp` to use `globalVar` even though it is defined elsewhere.

2. **Declaring Functions**

   The `extern` keyword is often used to declare functions that are defined in other files.

   **Example:**

   - **File1.cpp** (Definition of the function):
     ```cpp
     void printMessage() {
         std::cout << "Hello from File1!" << std::endl;
     }
     ```

   - **File2.cpp** (Declaration of the function):
     ```cpp
     extern void printMessage(); // Declaration of the function

     void callPrint() {
         printMessage(); // Calls the function defined in File1.cpp
     }
     ```

   In this example:
   - `printMessage` is defined in `File1.cpp` and declared with `extern` in `File2.cpp`.
   - This allows `File2.cpp` to call `printMessage`, even though it is defined in a different file.

3. **`extern` and Linkage**

   By default, `extern` provides **external linkage**. This means that the declared entity can be accessed from any other file. If you want to declare a variable or function with internal linkage (limited to the file it is declared in), you can use the `static` keyword instead.

4. **Using `extern` with C++ Code**

   In C++, if you are working with code that needs to be compatible with C (e.g., when combining C and C++ code), you can use `extern "C"` to prevent C++ name mangling, ensuring that function names are not altered by the C++ compiler.

   **Example:**

   - **File1.cpp** (C++ Code):
     ```cpp
     extern "C" void printMessage(); // Declare a C function

     void callPrint() {
         printMessage(); // Calls the C function
     }
     ```

   - **File2.c** (C Code):
     ```c
     #include <stdio.h>

     void printMessage() {
         printf("Hello from File2!\n");
     }
     ```

   In this example:
   - `printMessage` is declared with `extern "C"` in C++ code to ensure it can be linked with C code.
   - The C function `printMessage` is defined in `File2.c`.

**Summary**

- **`extern`**: Used to declare variables and functions defined in other translation units.
- **Global Variables**: Allows sharing of variables between different files.
- **Functions**: Facilitates calling functions defined in other files.
- **Linkage**: By default, `extern` provides external linkage, meaning the declared entity is accessible from other files.
- **C and C++ Compatibility**: Use `extern "C"` to prevent C++ name mangling when linking with C code.

***
