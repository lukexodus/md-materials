## ANSI Standard (1988)


### **Function Characteristics in C:**

- Functions can return values of basic types, structures, unions, or pointers.
- Recursive function calls are allowed.
- Local variables are typically "automatic," created anew with each invocation.
- Function definitions cannot be nested, but variables can be declared in a block-structured fashion.
- Functions can exist in separate source files and are compiled separately.

### **Preprocessing Step:**
- Performs macro substitution on program text.
- Includes other source files.
- Allows for conditional compilation.

### **C as a "Low-Level" Language:**
- Deals with characters, numbers, and addresses, which are fundamental to computer architecture.
- Lacks built-in operations for composite objects like character strings, sets, lists, or arrays.
- Structures may be copied as a unit, but no direct operations manipulate entire arrays or strings.
- Defines no storage allocation beyond static definition and stack discipline.
- No built-in input/output facilities; file access and I/O must be handled by explicitly called functions provided by the implementation.

### **Function Declaration and Definition Syntax:**
- Function declarations can now include descriptions of function arguments, aiding compilers in detecting mismatched arguments.
- The syntax for function definitions changes accordingly.
### **Other Language Changes:**
- Structure assignment and enumerations are officially part of the language.
- Floating-point computations can be done in single precision.
- Clarification of arithmetic properties, especially for unsigned types.
- The preprocessor is more elaborate, facilitating advanced macro processing.
### **Standard Library**
- The ANSI standard defines a library to accompany C, specifying functions for various tasks.
- Functions include accessing the operating system (e.g., file I/O), formatted input/output, memory allocation, and string manipulation.
- Standard headers provide uniform access to function declarations and data types.
- The library's design is influenced by the standard I/O library of UNIX, ensuring compatible behavior across systems.

### **Tiny Run-Time Library:**
- Due to C's direct support for data types and control structures on most computers, the run-time library required for self-contained programs is small.
- Standard library functions are only called explicitly, so they can be avoided if not needed.
- Most standard library functions can be implemented in C and are portable across systems.

