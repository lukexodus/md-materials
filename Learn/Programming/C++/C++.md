# Syllabus

## **Phase 1: Fundamentals of C++**

### **Introduction to C++**

- History and Evolution of C++
- Why Use C++?
- Installation and Setup (Windows, Linux, macOS)
- First C++ Program: "Hello, World!"

### **Basic Syntax and Structure**

- Variables, Constants, and Data Types
- Operators: Arithmetic, Logical, Relational, Bitwise
- Input/Output (cin, cout, cerr, clog)
- Comments and Code Readability

### **Control Flow & Loops**

- Conditional Statements (if, else-if, switch)
- Loops (for, while, do-while)
- Nested and Infinite Loops
- Break and Continue Statements

---

## **Phase 2: Core C++ Concepts**

### **Functions and Modular Programming**

- Function Definition, Declaration, and Call
- Pass by Value vs. Pass by Reference
- Default Arguments, Function Overloading
- Inline Functions and Recursive Functions

### **Arrays and Strings**

- One-dimensional and Multi-dimensional Arrays
- Character Arrays and Strings
- String Manipulation Functions (strlen, strcpy, strcmp, etc.)
- Introduction to `std::string`

### **Pointers and Memory Management**

- Introduction to Pointers
- Pointer Arithmetic
- Dynamic Memory Allocation (`new` and `delete`)
- Smart Pointers (`unique_ptr`, `shared_ptr`, `weak_ptr`)

---

## **Phase 3: Object-Oriented Programming (OOP)**

### **Classes and Objects**

- Defining Classes and Objects
- Access Specifiers (public, private, protected)
- Constructors and Destructors
- Member Functions and `this` Pointer

### **Encapsulation, Inheritance, and Polymorphism**

- Encapsulation and Data Hiding
- Types of Inheritance (Single, Multiple, Multilevel, Hierarchical, Hybrid)
- Function Overriding and Virtual Functions
- Abstract Classes and Interfaces

### **Operator Overloading**

- Overloading Arithmetic and Relational Operators
- Overloading `[]`, `()`, `->`, `<<`, `>>`
- Friend Functions and Friend Classes

### **Templates and Generic Programming**

- Function Templates
- Class Templates
- Template Specialization and Variadic Templates

---

## **Phase 4: Advanced C++ Concepts**

### **Exception Handling**

- `try`, `catch`, `throw`
- Standard Exceptions (`std::exception`, `std::runtime_error`, etc.)
- Custom Exception Handling

### **File Handling**

- File Input and Output Streams (`fstream`, `ifstream`, `ofstream`)
- Reading and Writing Files
- Working with Binary Files

### **STL (Standard Template Library)**

- Containers (Vector, List, Set, Map, Stack, Queue)
- Iterators and Algorithms
- Lambda Functions
- Sorting, Searching, and Manipulating Collections

### **Multithreading and Concurrency**

- Thread Creation (`std::thread`)
- Mutex and Locking Mechanisms
- Condition Variables
- Thread Synchronization

---

## **Phase 5: Advanced Topics & Optimization**

### **Memory Management and Optimization**

- Stack vs. Heap Memory
- RAII (Resource Acquisition Is Initialization)
- Object Pooling
- Move Semantics and Rvalue References

### **Networking in C++**

- Sockets Programming (`boost::asio`)
- HTTP Requests (`libcurl`)
- Multithreaded Server and Client Applications

### **Game Development with C++**

- Introduction to Game Engines (SFML, SDL, Unreal Engine)
- 2D and 3D Graphics
- Physics Simulation

### **Embedded Systems and Low-Level Programming**

- Interfacing with Hardware
- Writing Device Drivers
- Embedded C++ Programming

---

## **Phase 6: Real-World Applications & Projects**

### **Building Real-World Applications**

- Console-based Applications
- GUI-based Applications (Qt, wxWidgets)
- System-level Programming

### **Project Ideas**

- Personal Finance Manager
- Chat Application
- Game Engine from Scratch
- Web Crawler in C++
- Simple Database Engine

---

## **Phase 7: Competitive Programming & C++ Best Practices**

### **Competitive Programming Techniques**

- Dynamic Programming in C++
- Graph Algorithms (`Dijkstra`, `A*`, `Floyd-Warshall`)
- Advanced Sorting and Searching Techniques
- Bit Manipulation and Mathematical Algorithms

### **Best Practices and Code Optimization**

- Writing Clean and Maintainable Code
- Effective Debugging Techniques
- Code Profiling and Performance Optimization
- Avoiding Memory Leaks and Undefined Behavior

---

## **Final Phase: Contributing to Open Source & Industry Readiness**

### **Contributing to Open Source**

- Understanding Open-Source Projects
- Working with GitHub
- Writing Documentation and Test Cases

### **Interview Preparation**

- C++ Interview Questions and Solutions
- System Design and Design Patterns
- Mock Interviews and Whiteboard Coding

---

# Preprocessing

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

## Mixing C Code With C++ Code

**Header Files**: Both C and C++ use header files for declarations and prototypes. C header files can be included in C++ code using `extern "C"` to inform the C++ compiler that the declarations follow C naming conventions.

```cpp
extern "C" {
  #include "c_header.h"
}
```


Example of mixing C and C++ code:

```cpp
// c_code.c
#include <stdio.h>

void c_function() {
    printf("This is a C function\n");
}

// cpp_code.cpp
#include <iostream>

extern "C" {
    void c_function(); // Declaration of the C function
}

int main() {
    std::cout << "This is a C++ function" << std::endl;
    c_function(); // Calling the C function
    return 0;
}
```

***

## Headers

In C++, headers are files containing declarations and definitions that can be included in other source files. They typically have the extension `.h` for C headers and `.hpp` for C++ headers.

Headers allow you to manage dependencies between different parts of your program by including necessary declarations and definitions.

```cpp
#include "myheader.h" // Include a custom header file
#include <iostream>   // Include a standard library header
```

### Preprocessor Directives:

Headers often contain preprocessor directives to prevent multiple inclusions and to ensure header files are included only once.

```cpp
#ifndef MYHEADER_H
#define MYHEADER_H

// Declarations and definitions

#endif
```

### Forward Declarations:

Headers may contain forward declarations of classes, functions, or variables used in other source files. Forward declarations in C++ are used to inform the compiler about the existence of an identifier (such as a class, function, or variable) before its actual definition.

```cpp
#include <iostream>

// Forward declaration of class B
class B;

class A {
public:
    void doSomething(B& b);
};

class B {
public:
    void doSomethingElse() {
        std::cout << "Doing something else!" << std::endl;
    }
};

void A::doSomething(B& b) {
    b.doSomethingElse();
}

int main() {
    A a;
    B b;
    a.doSomething(b);
    return 0;
}
```

In this example, `class B` is forward-declared before `class A` is defined. This allows `class A` to reference `class B` without needing the full definition of `class B` at that point.
### Inclusion Guards:

Headers often use inclusion guards to prevent multiple inclusions of the same header file in a translation unit.

```cpp
#ifndef MYHEADER_H
#define MYHEADER_H

// Declarations and definitions

#endif
```

---

## Compile Time vs Runtime

Compile time and runtime are two distinct phases in the lifecycle of a program, each with its own significance and tasks.

- Compile time is concerned with the translation of source code into machine code or intermediate representations by the compiler, while runtime involves the actual execution of the program.
- Compile-time tasks include syntax checking, type checking, and code generation, while runtime tasks involve dynamic behavior and interaction with the environment.
- Compile-time errors are detected by the compiler, while runtime errors occur during program execution.
- Understanding the distinction between compile time and runtime is essential for debugging, performance optimization, and software development in general.

![[Pasted image 20240819164346.png]]

***

# Syntax and Structure

## Signed vs Unsigned

In C++, integers can be either **signed** or **unsigned**, and this distinction affects their range and how they are represented in binary.

### 1. **Signed Integers**
   - **Signed integers** can represent both positive and negative numbers.
   - The most significant bit (MSB) in a signed integer is used to represent the sign of the number:
     - **0** for positive numbers.
     - **1** for negative numbers.
   - The binary representation of a signed integer typically uses **two's complement** format:
     - In two's complement, to represent a negative number, you invert all the bits of its positive counterpart and add 1.
     - For example, in an 8-bit system:
       - $+5$ is represented as `0000 0101`.
       - $-5$ is represented as `1111 1011` (invert `0000 0101` to `1111 1010` and add 1 to get `1111 1011`).
   - **Range**: For an $n$-bit signed integer:
     - Minimum value: $-2^{n-1}$
     - Maximum value: $2^{n-1} - 1$
   - Example: An 8-bit signed integer can range from $-128$ (`1000 0000`) to $127$ (`0111 1111`).

### 2. **Unsigned Integers**
   - **Unsigned integers** can only represent non-negative numbers.
   - All bits are used to represent the magnitude of the number, with no bit reserved for the sign.
   - **Range**: For an $n$-bit unsigned integer:
     - Minimum value: $0$
     - Maximum value: $2^n - 1$
   - Example: An 8-bit unsigned integer can range from $0$ (`0000 0000`) to $255$ (`1111 1111`).

### 3. **Binary Representation Examples**

#### **8-bit Signed Integer**
- **+5**: `0000 0101`
- **-5**: `1111 1011` (Two's complement of `0000 0101`)

#### **8-bit Unsigned Integer**
- **5**: `0000 0101`
- **255**: `1111 1111` (Highest possible value for 8-bit unsigned)

**Summary of Key Differences**:
- **Signed** integers use the MSB for the sign and can represent both positive and negative values.
- **Unsigned** integers use all bits for magnitude, allowing them to represent larger positive numbers but no negative numbers.

***
## Primitive Types

Integral types in C++ are data types that represent whole numbers (integers). These types store numeric values without any fractional or decimal part.

### **Integer Types**

- **`int`**: Basic integer type, typically 4 bytes in size.
- **`short`**: Short integer type, typically 2 bytes in size.
- **`long`**: Long integer type, typically 4 or 8 bytes depending on the system.
- **`long long`**: Extended long integer type, typically 8 bytes.
- **`unsigned int`**: Unsigned version of `int`, only positive values.
- **`unsigned short`**: Unsigned version of `short`.
- **`unsigned long`**: Unsigned version of `long`.
- **`unsigned long long`**: Unsigned version of `long long`.

#### Note:

##### 1 Bit:

- **Equivalence**: 2<sup>1</sup> = 2
- **Two States**: 0 or 1

##### 1 Byte (8 bits):

- **Equivalence**: 2<sup>8</sup> = 256
- **Signed**: -128 to 127
- **Unsigned**: 0 to 255

##### 2 Bytes (16 bits):

- **Equivalence**: 2<sup>16</sup> = 65,536
- **Signed: -32,768 to 32,767
- **Unsigned**: 0 to 65,535

##### 4 Bytes (32 bits):

- **Equivalence**: 2<sup>32</sup> = 4,294,967,296
- **Signed**: -2,147,483,648 to 2,147,483,647
- **Unsigned**: 0 to 4,294,967,295

##### 8 Bytes (64 bits):

- **Equivalence**: 2<sup>64</sup> = 18,446,744,073,709,551,616
- **Signed**: -9,223,372,036,854,775,808 to 9,223,372,036,854,775,807
- **Unsigned**: 0 to 18,446,744,073,709,551,615

### Floating-Point Types

- **`float`**: Single-precision floating-point type, typically 4 bytes.
- **`double`**: Double-precision floating-point type, typically 8 bytes.
- **`long double`**: Extended-precision floating-point type, size varies (typically 8, 12, or 16 bytes).

### Character Types

- **`char`**: Single character type, typically 1 byte.
- **`signed char`**: Signed version of `char`.
- **`unsigned char`**: Unsigned version of `char`.
- **`wchar_t`**: Wide character type, typically used for Unicode characters.
- **`char16_t`**: 16-bit character type, used for UTF-16 encoding.
- **`char32_t`**: 32-bit character type, used for UTF-32 encoding.

#### **`char`**

- **Size**: 1 byte
- **Signedness**: Implementation-defined (depends on compiler & platform)
- **Range**: Could be either `signed char` or `unsigned char`, depending on the system.
- **Use Case**: Typically used for storing characters (text data).
- **Example**:
    
    ```cpp
    char c = 'A';  // Stores character 'A'
    ```
    

---

#### **`signed char`**

- **Size**: 1 byte
- **Signedness**: Always **signed**
- **Range**: `-128` to `127` (for 8-bit systems)
- **Use Case**: Used for storing small signed integer values.
- **Example**:
    
    ```cpp
    signed char c = -5;  // Allowed
    signed char d = 130; // Overflow (if 8-bit, wraps around or undefined behavior)
    ```
    

---

#### **`unsigned char`**

- **Size**: 1 byte
- **Signedness**: Always **unsigned**
- **Range**: `0` to `255` (for 8-bit systems)
- **Use Case**: Used when storing raw binary data (e.g., buffers, images).
- **Example**:
    
    ```cpp
    unsigned char c = 250; // Allowed
    unsigned char d = -1;  // Wraps around to 255
    ```
    
---

```cpp
#include <iostream>
using namespace std;

int main() {
    cout << "char is signed? " << (char(-1) < 0) << endl;
    return 0;
}
```

If it prints `1`, `char` is **signed**. If `0`, `char` is **unsigned**.

---

#### **`wchar_t` (Wide Character)**

- **Size**: **Platform-dependent** (typically **2 bytes on Windows**, **4 bytes on Linux/macOS**).
- **Encoding**: Depends on platform, but often **UTF-16 (Windows)** or **UTF-32 (Linux/macOS)**.
- **Use Case**: Used for internationalization, where characters beyond ASCII are needed.
- **Example**:
    
    ```cpp
    #include <iostream>
    using namespace std;
    
    int main() {
        wchar_t w = L'Ω'; // 'Ω' is a Greek letter
        wcout << L"Wide character: " << w << endl;
        return 0;
    }
    ```
    
    **Note:** Use `wcout` for printing `wchar_t`.

---

#### **`char16_t` (16-bit Unicode Character)**

- **Size**: Always **2 bytes** (16 bits).
- **Encoding**: **UTF-16**.
- **Use Case**: Used for handling **Unicode** text where UTF-16 encoding is required.
    
- **Example**:
    
    ```cpp
    char16_t c16 = u'好'; // Chinese character "好"
    ```
    
    Unlike `wchar_t`, `char16_t` is **always** 2 bytes, making it more portable.
    

---

#### **`char32_t` (32-bit Unicode Character)**

- **Size**: Always **4 bytes** (32 bits).
- **Encoding**: **UTF-32**.
- **Use Case**: Used for handling **full Unicode characters** (including emojis).
    
- **Example**:
    
    ```cpp
    char32_t c32 = U'🌍'; // Unicode emoji
    ```
    
    `char32_t` can store **any** Unicode character in a single code unit.
    

---

**Comparison Table**

|Type|Size|Encoding|Typical Use|
|---|---|---|---|
|`char`|1 byte|ASCII/UTF-8|Standard text|
|`wchar_t`|Platform-dependent (2 or 4 bytes)|UTF-16 (Windows), UTF-32 (Linux)|International text|
|`char16_t`|2 bytes|UTF-16|Unicode text (UTF-16)|
|`char32_t`|4 bytes|UTF-32|Unicode text (UTF-32, full-range)|

### Boolean Type:

**bool**: Boolean type representing `true` or `false`, typically 1 byte.

### **Fixed-Width Integral Types (`<cstdint>`)**

To ensure consistent sizes across different systems, C++ provides **fixed-width integer types** in `<cstdint>`:

|Type|Size (bits)|Signed Range|
|---|---|---|
|`int8_t`|8|-128 to 127|
|`uint8_t`|8|0 to 255|
|`int16_t`|16|-32,768 to 32,767|
|`uint16_t`|16|0 to 65,535|
|`int32_t`|32|-2,147,483,648 to 2,147,483,647|
|`uint32_t`|32|0 to 4,294,967,295|
|`int64_t`|64|-9,223,372,036,854,775,808 to 9,223,372,036,854,775,807|
|`uint64_t`|64|0 to 18,446,744,073,709,551,615|

These are useful for **portable** code where exact bit sizes matter.

### Enumeration Types (`enum`)

Enumerations (`enum`) are also considered integral types. The underlying type defaults to `int`, but you can specify a different integral type.

```c++
enum Color { RED = 1, GREEN = 2, BLUE = 3 };
```

With enum class, the underlying type can be explicitly set:

```c++
enum class Direction : uint8_t { UP, DOWN, LEFT, RIGHT };
```

### Auto Type Deduction:

The `auto` keyword allows the compiler to automatically deduce the type of a variable based on its initializer. It's particularly useful when dealing with complex or template-based types.

```cpp
auto x = 10;         // Deduced as int
auto y = 3.14;       // Deduced as double
auto z = "Hello";    // Deduced as const char*
```

### Sizeof Operator:

The `sizeof` operator returns the size of a variable or a type in bytes. It's useful for determining the storage requirements of variables.

```cpp
sizeof(int);         // Returns the size of an int in bytes
sizeof(double);      // Returns the size of a double in bytes
sizeof(char);        // Returns the size of a char in bytes
```

### Size Type

`size_t` is a data type in C and C++ that is used to represent sizes of objects. It's an unsigned integer type defined in the `<cstddef>` header in C and `<stddef.h>` in C++. It's commonly used to represent the size of arrays, containers, and memory blocks.

```cpp
    size_t size = 10; // Represents the size of an array or container
    size_t size_of_int = sizeof(int);
```

### Void Type

- **`void`**: Represents the absence of type, often used in functions that do not return a value.

### Null Pointer Type

`nullptr_t` is the type of the `nullptr` keyword in C++. It represents a null pointer and is used to indicate the absence of a valid pointer.

1. **Only One Value**: `nullptr_t` can only hold `nullptr`.
2. **Implicitly Convertible**: It can be assigned to any pointer type but **not** to integral types.
3. **Prevents Ambiguity**: Unlike `NULL`, which is often `0`, `nullptr` ensures type safety.

```cpp
#include <iostream>
#include <type_traits>

int main() {
    std::nullptr_t np = nullptr;  // Declaring a nullptr_t variable

    int* p1 = nullptr;      // Valid: nullptr_t converts to int*
    double* p2 = nullptr;   // Valid: nullptr_t converts to double*

    // nullptr is not an integer
    // int x = nullptr;  // ❌ Error

    std::cout << "Type of np: " << typeid(np).name() << std::endl;
    return 0;
}
```

#### **Why Use `nullptr_t` Instead of `NULL`?**

- **Type Safety**: `NULL` is often `0`, leading to ambiguity between pointers and integers. `nullptr` is explicitly a pointer type.
    
- **Overload Resolution**: Consider this example:
    
    ```cpp
    void foo(int x) { std::cout << "int version\n"; }
    void foo(int* p) { std::cout << "pointer version\n"; }
    
    int main() {
        foo(0);       // Calls `foo(int)`, which may be unintended
        foo(nullptr); // Calls `foo(int*)`, correctly selecting the pointer overload
    }
    ```
    
    `NULL` (which is `0`) could incorrectly select `foo(int)`, but `nullptr` ensures `foo(int*)` is called.
    

**Conclusion**

- Use `nullptr` instead of `NULL` for modern C++ code.
- `nullptr_t` ensures strong **type safety** and **overload resolution**.
- It is **implicitly convertible** to any pointer type but **not to integral types**.

***

## Integer Prefixes and Suffixes

In C++, when dealing with integers, certain suffixes and prefixes like `L`, `u`, `0`, and `0x` can be used to define the type and base of an integer literal. Here's how each of these works:

### 1. **Suffixes: `L`, `u`, `UL`, etc.**

Suffixes are used to specify the type of an integer literal.

- **`L`**: Indicates that the literal is of type `long`.
  - Example: `42L` is a `long` integer with a value of 42.
- **`u`**: Indicates that the literal is of type `unsigned int`.
  - Example: `42u` is an `unsigned int` with a value of 42.
- **`UL`** or **`LU`**: Indicates that the literal is of type `unsigned long`.
  - Example: `42UL` or `42LU` is an `unsigned long` with a value of 42.
- **`LL`**: Indicates that the literal is of type `long long`.
  - Example: `42LL` is a `long long` integer with a value of 42.
- **`ULL`** or **`LLU`**: Indicates that the literal is of type `unsigned long long`.
  - Example: `42ULL` or `42LLU` is an `unsigned long long` with a value of 42.

### 2. **Prefixes: `0` and `0x`**

Prefixes define the base of the integer literal.

- **`0`**: Indicates that the literal is in **octal** (base 8).
  - Example: `042` represents the octal number `42`, which is equal to `34` in decimal.
- **`0x`**: Indicates that the literal is in **hexadecimal** (base 16).
  - Example: `0x2A` represents the hexadecimal number `2A`, which is equal to `42` in decimal.

### Combining Prefixes and Suffixes

You can combine these prefixes and suffixes to create literals of specific types and bases.

- **Hexadecimal Long**:
  - Example: `0x2AL` is a `long` integer in hexadecimal with a decimal value of `42`.
- **Unsigned Octal**:
  - Example: `042u` is an `unsigned int` with an octal value of `42`, which equals `34` in decimal.
- **Unsigned Long Long Hexadecimal**:
  - Example: `0xFFULL` is an `unsigned long long` with a hexadecimal value of `FF`, which equals `255` in decimal.

### Practical Examples

#### Example 1: Octal Literal
```cpp
int octal = 042; // 042 in octal is 34 in decimal
```

#### Example 2: Hexadecimal Unsigned Long
```cpp
unsigned long hex = 0x2AUL; // 0x2A in hexadecimal is 42 in decimal
```

#### Example 3: Unsigned Integer
```cpp
unsigned int number = 42u; // 42 as an unsigned integer
```

---

## Enumerations (`enum`)

Enums, short for enumerations, in C++ are user-defined data types that allow you to define sets of named constants. Enums provide a way to assign meaningful names to integral constants, making the code more readable and maintainable.

### Define an Enum:

```cpp
enum Color {
    RED,
    GREEN,
    BLUE
};
```

- In this example, `Color` is the name of the enum, and `RED`, `GREEN`, and `BLUE` are the enumerators or named constants.
- By default, the underlying type of enums is `int`, and each enumerator is assigned an integer value starting from 0.

### Assign Integer Values to Enumerators:

```cpp
enum Weekday {
    MONDAY = 1,
    TUESDAY,
    WEDNESDAY,
    THURSDAY,
    FRIDAY,
    SATURDAY,
    SUNDAY
};
```

- In this example, `MONDAY` is assigned the value 1, and subsequent enumerators are assigned increasing integer values by default (2, 3, 4, ...).

### Using Enums:

```cpp
Color paint = RED;
Weekday today = TUESDAY;

if (paint == RED) {
    std::cout << "Paint the wall red" << std::endl;
}

switch (today) {
    case MONDAY:
        std::cout << "Today is Monday" << std::endl;
        break;
    case TUESDAY:
        std::cout << "Today is Tuesday" << std::endl;
        break;
    // Handle other weekdays
    default:
        std::cout << "Unknown day" << std::endl;
}
```

- Enums can be used like any other integral type, including in conditional statements, switch statements, and variable assignments.

### Scoped Enums:

```cpp
enum class Status {
    OK,
    ERROR
};

Status systemStatus = Status::OK;

if (systemStatus == Status::OK) {
    std::cout << "System is running normally" << std::endl;
}
```

- Scoped enums introduce a new scoping mechanism, where enumerators are scoped within the enum name, preventing name clashes with other enums or variables.

### Benefits of Enums:

- **Readability**: Enums provide meaningful names for integral constants, improving code readability and maintainability.
- **Type Safety**: Enums provide type safety, preventing unintended assignments of arbitrary integer values.
- **Compiler Checking**: The compiler can catch errors related to enum usage, such as invalid enum values or type mismatches.

---
## `const` keyword

The `const` keyword is used to declare entities (variables, functions, etc.) as constant, indicating that their value cannot be changed after initialization.

### Constant Variables:

```cpp
const int SIZE = 10; // Declare a constant integer variable
```

In this example, `SIZE` is a constant integer variable, and its value cannot be modified once it's initialized.

### Benefits of `const`:

- **Safety**: Helps prevent accidental modification of variables.
- **Readability**: Clearly indicates intent and usage of entities.
- **Compiler Optimization**: Enables the compiler to perform optimizations, knowing that values won't change.

## Namespaces

In C++, namespaces are used to organize code into logical groups and to prevent naming conflicts. They provide a way to group related code together under a unique identifier.

### Namespace Declaration:

You declare a namespace using the `namespace` keyword followed by the namespace name and the code block containing the declarations within the namespace.

```cpp
namespace MyNamespace {
    // Declarations
    int var1;
    void function1();
}
```

### Accessing Namespaces:

You can access the members of a namespace using the scope resolution operator `::`. 

```cpp
MyNamespace::var1 = 10;
MyNamespace::function1();
```

### Nested Namespaces:

Namespaces can be nested within other namespaces to further organize code.

```cpp
namespace OuterNamespace {
    namespace InnerNamespace {
        // Declarations
    }
}
```

### Using Directive:

The `using` directive allows you to bring the entire namespace or specific members into scope, reducing the need for repetitive qualification.

```cpp
using namespace MyNamespace;
```

### Using Declaration:

The `using` declaration allows you to bring specific members from a namespace into the current scope.

```cpp
using MyNamespace::var1;
```

### Example

```cpp
#include <iostream>

namespace Math {
    const double PI = 3.14159;

    double square(double x) {
        return x * x;
    }
}

int main() {
    using namespace Math;

    std::cout << "PI: " << PI << std::endl;
    std::cout << "Square of 5: " << square(5) << std::endl;

    return 0;
}
```

---

### Anonymous Namespace

An **anonymous namespace** in C++ is a special kind of namespace without a name. It is used to limit the **scope** of functions, variables, and classes to the current translation unit (i.e., the current `.cpp` file). This makes them **internal** to the file, preventing external linkage.

---

#### **Syntax**

```cpp
#include <iostream>

namespace {  // Anonymous namespace
    int secretValue = 42;

    void display() {
        std::cout << "Secret value: " << secretValue << std::endl;
    }
}

int main() {
    display();  // Works fine
    return 0;
}
```

- The `secretValue` variable and `display()` function **can only be accessed within this file**.
- They **cannot be accessed from other files**, even if they include this `.cpp` file.

---

#### **Why Use Anonymous Namespaces?**

1. **Avoid Naming Conflicts**
    - Since elements inside an anonymous namespace are not visible outside the file, you prevent accidental name clashes.
2. **Internal Linkage (Like `static`)**
    - It works similarly to using `static` on global variables and functions in C.
    - Ensures functions and variables do not pollute the global namespace.
3. **Encapsulation & Security**
    - Prevents unintended access to internal implementation details.

---

#### **Anonymous Namespace vs `static` (at File Scope)**

|Feature|Anonymous Namespace|`static` (File Scope)|
|---|---|---|
|Scope|Limited to the file|Limited to the file|
|Usable for Variables|Yes|Yes|
|Usable for Functions|Yes|Yes|
|Usable for Classes|Yes|No|
|Name Clashes Avoided|Yes|No|

- `static` can only be applied to **variables and functions**, while an anonymous namespace can contain **variables, functions, and even classes**.

---

#### **Example: Preventing Name Conflicts**

##### **Without an Anonymous Namespace (Global Conflict)**

```cpp
// file1.cpp
#include <iostream>

void logMessage() {  // Might conflict with another function
    std::cout << "Logging from file1" << std::endl;
}

```

```cpp
// file2.cpp
#include <iostream>

void logMessage() {  // Name conflict if linked with file1.cpp
    std::cout << "Logging from file2" << std::endl;
}
```

When linking both `.cpp` files together, the **compiler will complain about duplicate function names**.

##### **With an Anonymous Namespace (No Conflict)**

```cpp
// file1.cpp
#include <iostream>

namespace {
    void logMessage() {  // No conflict since it's internal to file1.cpp
        std::cout << "Logging from file1" << std::endl;
    }
}

int main() {
    logMessage();
    return 0;
}
```

- Even if another `logMessage()` exists in another file, it **won't conflict** because it's inside an **anonymous namespace**.

***

## Standard Library (`std`)

`std` stands for the Standard Template Library (STL) in C++. It's a collection of classes and functions that are part of the C++ Standard Library. The `std` namespace encompasses the entire C++ Standard Library.

Here are some key points about `std`:

1. **Namespace**: `std` is a namespace that encapsulates all the components of the C++ Standard Library. By placing library components within the `std` namespace, it helps avoid naming conflicts with user-defined identifiers.

2. **Containers and Algorithms**: `std` provides various container classes like `std::vector`, `std::list`, `std::map`, `std::set`, etc., along with algorithms for manipulating these containers such as `std::sort`, `std::find`, `std::accumulate`, and many more.

3. **Iterators**: It offers iterator types and algorithms that work with iterators to provide a uniform interface for sequential access to elements in containers.

4. **Utilities and Functionalities**: `std` also includes utility classes like `std::pair`, `std::tuple`, `std::function`, and various other utilities like `std::move`, `std::swap`, `std::initializer_list`, etc.

5. **I/O Operations**: `std` provides facilities for input and output operations, including `std::cin`, `std::cout`, `std::cerr`, `std::ifstream`, `std::ofstream`, etc.

6. **Concurrency**: With C++11 and later standards, `std` includes components for multithreading and concurrency, such as `std::thread`, `std::mutex`, `std::atomic`, etc.

Example usage:

```cpp
#include <iostream>
#include <vector>
#include <algorithm>

int main() {
    // Using vector from the std namespace
    std::vector<int> vec = {3, 1, 4, 1, 5, 9, 2, 6};

    // Sorting the vector using std::sort algorithm
    std::sort(vec.begin(), vec.end());

    // Outputting the sorted vector using std::cout
    for (int elem : vec) {
        std::cout << elem << " ";
    }
    std::cout << std::endl;

    return 0;
}
```

In summary, `std` is the namespace that contains the C++ Standard Library, providing a wide range of functionalities and utilities for C++ programmers to use in their applications.

***

### **Stream Insertion and Extraction Operators**
- **Purpose:** These operators are used with input and output streams (like `cin` and `cout`) to read from and write to the console or other streams.

#### **`<<` (Stream Insertion Operator)**
- **Usage:** Used to send (insert) data to an output stream.
- **Example:**
  ```cpp
  std::cout << "Hello, World!" << std::endl;
  ```
  - **Explanation:** This code outputs the string "Hello, World!" followed by a newline. The `<<` operator inserts the string into the `cout` stream.

#### **`>>` (Stream Extraction Operator)**
- **Usage:** Used to extract (read) data from an input stream.
- **Example:**
  ```cpp
  int number;
  std::cin >> number;
  ```
  - **Explanation:** This code reads an integer from the user input and stores it in the variable `number`. The `>>` operator extracts the data from the `cin` stream.

### **Bitwise Shift Operators**
- **Purpose:** These operators are used to shift the bits of an integer value to the left or right. They are often used in low-level programming, bit manipulation, and performance-critical code.

#### **`<<` (Left Shift Operator)**
- **Usage:** Shifts the bits of an integer to the left by a specified number of positions. Each left shift effectively multiplies the number by 2.
- **Example:**
  ```cpp
  int x = 5; // Binary: 0000 0101
  int result = x << 2; // Binary: 0001 0100 (equivalent to 20)
  ```
  - **Explanation:** This code shifts the bits of `5` two positions to the left, resulting in `20` (in binary, `0001 0100`).

#### **`>>` (Right Shift Operator)**
- **Usage:** Shifts the bits of an integer to the right by a specified number of positions. Each right shift effectively divides the number by 2.
- **Example:**
  ```cpp
  int x = 20; // Binary: 0001 0100
  int result = x >> 2; // Binary: 0000 0101 (equivalent to 5)
  ```
  - **Explanation:** This code shifts the bits of `20` two positions to the right, resulting in `5` (in binary, `0000 0101`).

***

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

## Input Stream Error Handling

In C++, error handling for input and output streams is crucial to ensure that your program can handle unexpected situations gracefully. The standard input stream (`std::cin`), like other streams, has mechanisms to detect and manage errors during data input.

### **Stream States**
Streams in C++ can have different states that indicate whether operations have succeeded or encountered problems. These states are represented by flags in the stream. The most common states are:

1. **`goodbit`:** Indicates that no errors have occurred. The stream is in a good state.
2. **`eofbit`:** Indicates that the end of the input sequence has been reached. This happens when there is no more data to read from the stream.
3. **`failbit`:** Indicates that a logical error occurred during an I/O operation. For example, trying to read an integer where a string is expected will set this bit.
4. **`badbit`:** Indicates that a serious error occurred, such as a failure to read or write from a file or device.

### **Using `std::cin.fail()` and `std::cin.eof()`**

- **`std::cin.fail()`**
  - **Purpose:** Checks whether the `failbit` is set for the stream. This is commonly used to detect input errors, such as when the user inputs a value of the wrong type.
  - **Example:**
    ```cpp
    int num;
    std::cin >> num;

    if (std::cin.fail()) {
        std::cerr << "Error: Invalid input. Please enter a valid number." << std::endl;
        std::cin.clear(); // Clears the error flag
        std::cin.ignore(std::numeric_limits<std::streamsize>::max(), '\n'); // Discards the invalid input
    }
    ```
  - **Explanation:** If the user inputs something other than an integer, `std::cin.fail()` returns `true`, and the program can handle the error, such as by clearing the error state and discarding the invalid input.

- **`std::cin.eof()`**
  - **Purpose:** Checks whether the `eofbit` is set, indicating that the end of the input stream has been reached. This is useful for detecting the end of input in loops that read data until the end.
  - **Example:**
    ```cpp
    int num;
    while (std::cin >> num) {
        std::cout << "You entered: " << num << std::endl;
    }

    if (std::cin.eof()) {
        std::cout << "End of input reached." << std::endl;
    }
    ```
  - **Explanation:** This loop continues reading integers from the input until the end of the input stream is reached, at which point `std::cin.eof()` will return `true`, and the program can handle the end-of-input situation.

### **Clearing Stream State**
When an error occurs, the stream is put into a fail state, and further input operations will be ignored until the state is cleared. To reset the stream so that it can accept new input, you can use:

- **`std::cin.clear()`**
  - Clears all error flags (`failbit`, `badbit`, etc.) but does not remove the invalid input from the buffer.

- **`std::cin.ignore()`**
  - Skips characters in the input buffer, typically used after clearing the stream state to remove the invalid input.

### **Error Handling for Various Input Types in C++**

Handling errors properly ensures that your program can handle unexpected inputs without crashing. C++ provides several ways to handle errors, including **input validation**, **exception handling**, and **error codes**.

---

#### **1. Handling Integer Input Errors**

**Problem:** The user might enter a non-integer value (e.g., letters, symbols).

**Solution:** Use `std::cin.fail()` to check for invalid input.

```cpp
#include <iostream>
#include <limits>

int getIntInput() {
    int num;
    while (true) {
        std::cout << "Enter an integer: ";
        std::cin >> num;

        if (std::cin.fail()) {  // Input is not an integer
            std::cin.clear();  // Clear the error flag
            std::cin.ignore(std::numeric_limits<std::streamsize>::max(), '\n'); // Discard invalid input
            std::cout << "Invalid input. Please enter a valid integer.\n";
        } else {
            return num;
        }
    }
}

int main() {
    int value = getIntInput();
    std::cout << "You entered: " << value << std::endl;
    return 0;
}
```

- **What happens?**
    - If the user enters `"abc"`, `std::cin.fail()` triggers.
    - `std::cin.clear()` resets the error flag.
    - `std::cin.ignore(...)` removes the bad input from the buffer.

---

#### **2. Handling Floating-Point Input Errors**

**Problem:** The user might enter a non-numeric value.

**Solution:** Use the same approach as with integers.

```cpp
double getDoubleInput() {
    double num;
    while (true) {
        std::cout << "Enter a decimal number: ";
        std::cin >> num;

        if (std::cin.fail()) {
            std::cin.clear();
            std::cin.ignore(std::numeric_limits<std::streamsize>::max(), '\n');
            std::cout << "Invalid input. Please enter a valid decimal number.\n";
        } else {
            return num;
        }
    }
}

int main() {
    double value = getDoubleInput();
    std::cout << "You entered: " << value << std::endl;
    return 0;
}
```

---

#### **3. Handling Character Input Errors**

**Problem:** The user enters multiple characters instead of one.

**Solution:** Use `std::cin.get()` and `std::cin.ignore()`.

```cpp
char getCharInput() {
    char ch;
    while (true) {
        std::cout << "Enter a single character: ";
        std::cin >> ch;

        if (std::cin.peek() != '\n') {  // Check if more input is in the buffer
            std::cin.ignore(std::numeric_limits<std::streamsize>::max(), '\n');  // Discard extra input
            std::cout << "Invalid input. Please enter only one character.\n";
        } else {
            return ch;
        }
    }
}

int main() {
    char value = getCharInput();
    std::cout << "You entered: " << value << std::endl;
    return 0;
}
```

---

#### **4. Handling String Input Errors**

**Problem:** Handling empty input or trimming extra spaces.

**Solution:** Use `std::getline()` instead of `std::cin >>`.

```cpp
std::string getStringInput() {
    std::string input;
    while (true) {
        std::cout << "Enter a string: ";
        std::getline(std::cin, input);

        if (input.empty()) {
            std::cout << "Invalid input. String cannot be empty.\n";
        } else {
            return input;
        }
    }
}

int main() {
    std::string value = getStringInput();
    std::cout << "You entered: " << value << std::endl;
    return 0;
}
```

- `std::getline()` ensures the full input is captured, including spaces.
- `input.empty()` checks for empty input.


##### **Handling `std::cin >>` Before `std::getline()`**

When `std::cin >>` is used before `std::getline()`, **buffer issues** can occur because `std::cin >>` leaves a **newline (`\n`)** in the buffer, which `std::getline()` reads immediately.

```cpp
#include <iostream>
#include <string>

int main() {
    int age;
    std::string name;

    std::cout << "Enter your age: ";
    std::cin >> age; // Leaves '\n' in buffer

    std::cout << "Enter your full name: ";
    std::getline(std::cin, name);  // Reads leftover '\n'

    std::cout << "Hello, " << name << ", you are " << age << " years old!" << std::endl;
    return 0;
}
```

**Input & Output:**

```
Enter your age: 25
Enter your full name: Hello, , you are 25 years old!
```

- The name is empty **because `std::getline()` reads the leftover `\n`** from `std::cin >>`.

**Fix: Use `std::cin.ignore()`**

```cpp
std::cin.ignore(std::numeric_limits<std::streamsize>::max(), '\n');
```

**Fixed Code:**

```cpp
#include <iostream>
#include <string>
#include <limits>

int main() {
    int age;
    std::string name;

    std::cout << "Enter your age: ";
    std::cin >> age;
    std::cin.ignore(std::numeric_limits<std::streamsize>::max(), '\n');  // Discard leftover newline

    std::cout << "Enter your full name: ";
    std::getline(std::cin, name);

    std::cout << "Hello, " << name << ", you are " << age << " years old!" << std::endl;
    return 0;
}
```

**Corrected Output:**

```
Enter your age: 25
Enter your full name: John Doe
Hello, John Doe, you are 25 years old!
```

---

#### **5. Handling Boolean Input Errors**

**Problem:** The user enters something other than `1` or `0`.

**Solution:** Validate input manually.

```cpp
bool getBoolInput() {
    int choice;
    while (true) {
        std::cout << "Enter 1 (true) or 0 (false): ";
        std::cin >> choice;

        if (std::cin.fail() || (choice != 0 && choice != 1)) {
            std::cin.clear();
            std::cin.ignore(std::numeric_limits<std::streamsize>::max(), '\n');
            std::cout << "Invalid input. Enter 1 for true or 0 for false.\n";
        } else {
            return choice;
        }
    }
}

int main() {
    bool value = getBoolInput();
    std::cout << "You entered: " << std::boolalpha << value << std::endl;
    return 0;
}
```

---

#### **6. Handling Errors Using Exceptions**

**Problem:** You want to handle errors with `try-catch`.

**Solution:** Use `throw` inside a function and `catch` in `main()`.

```cpp
#include <iostream>
#include <stdexcept>  // Required for std::invalid_argument

int getPositiveInt() {
    int num;
    std::cout << "Enter a positive integer: ";
    std::cin >> num;

    if (std::cin.fail() || num <= 0) {
        throw std::invalid_argument("Invalid input: Must be a positive integer.");
    }

    return num;
}

int main() {
    try {
        int value = getPositiveInt();
        std::cout << "You entered: " << value << std::endl;
    } catch (const std::exception &e) {
        std::cout << "Error: " << e.what() << std::endl;
    }
    return 0;
}
```

- If the user enters `-5` or `"abc"`, an exception is thrown.
- `catch` handles the error without crashing the program.

---

**Conclusion**

| Input Type     | Error Handling Approach                                      |
| -------------- | ------------------------------------------------------------ |
| Integer        | `std::cin.fail()`, `std::cin.clear()`, `std::cin.ignore()`   |
| Floating-Point | Same as integer handling                                     |
| Character      | `std::cin.peek()`, `std::cin.ignore()` to handle extra input |
| String         | `std::getline()`, check for empty input                      |
| Boolean        | Validate manually (only `0` or `1` allowed)                  |
| Exceptions     | Use `throw` and `catch` for advanced error handling          |

Proper error handling makes your C++ programs more **robust** and **user-friendly**.

---

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

## **Bitwise Operators and Operations**

Bitwise operators work at the **bit level** and are used to manipulate individual bits of a number. These operators are **faster** and commonly used in **low-level programming, cryptography, and optimization techniques**.

---

### **Bitwise Operators in C++**

| Operator | Name        | Description                                                        |
| -------- | ----------- | ------------------------------------------------------------------ |
| `&`      | AND         | Sets a bit to `1` if both corresponding bits are `1`               |
| `        | `           | OR                                                                 |
| `^`      | XOR         | Sets a bit to `1` if bits are different (`1 ^ 0 = 1`, `0 ^ 1 = 1`) |
| `~`      | NOT         | Flips all bits (1s become 0s, 0s become 1s)                        |
| `<<`     | Left Shift  | Shifts bits left by `n` places, filling with 0s                    |
| `>>`     | Right Shift | Shifts bits right by `n` places, discarding bits                   |

---

### **Bitwise AND (`&`)**

**Formula:** `a & b`

```cpp
#include <iostream>
using namespace std;

int main() {
    int a = 5;  // 0101 in binary
    int b = 3;  // 0011 in binary
    cout << (a & b) << endl; // Output: 1 (0001)
    return 0;
}
```

✅ **Use Case:** Checking if a number is even (`num & 1 == 0` means even).

---

### **Bitwise OR (`|`)**

**Formula:** `a | b`

```cpp
int a = 5;  // 0101
int b = 3;  // 0011
cout << (a | b) << endl; // Output: 7 (0111)
```

✅ **Use Case:** Setting specific bits in a flag register.

---

### **Bitwise XOR (`^`)**

**Formula:** `a ^ b`

```cpp
int a = 5;  // 0101
int b = 3;  // 0011
cout << (a ^ b) << endl; // Output: 6 (0110)
```

✅ **Use Case:** Swapping numbers without a temporary variable.

```cpp
a = a ^ b;
b = a ^ b;
a = a ^ b;
```

---

### **Bitwise NOT (`~`)**

**Formula:** `~a`

```cpp
int a = 5;  // 0000 0101
cout << (~a) << endl; // Output: -6 (in 2’s complement form)
```

✅ **Use Case:** Negating bits or flipping bit values.

---

### **Left Shift (`<<`)**

**Formula:** `a << n` (Shifts bits `n` places to the left)

```cpp
int a = 5;  // 0000 0101
cout << (a << 1) << endl; // Output: 10 (0000 1010)
cout << (a << 2) << endl; // Output: 20 (0001 0100)
```

✅ **Use Case:** Fast multiplication by powers of `2`.  
Example: `x << 3` is the same as `x * 8`.

---

### **Right Shift (`>>`)**

**Formula:** `a >> n` (Shifts bits `n` places to the right)

```cpp
int a = 20;  // 0001 0100
cout << (a >> 1) << endl; // Output: 10 (0000 1010)
cout << (a >> 2) << endl; // Output: 5  (0000 0101)
```

✅ **Use Case:** Fast division by powers of `2`.  
Example: `x >> 3` is the same as `x / 8`.

---

### **Bitwise Tricks and Applications**

#### **1. Check if a Number is Even or Odd**

```cpp
if (num & 1) 
    cout << "Odd";
else 
    cout << "Even";
```

#### **2. Swap Two Numbers Without Using a Temporary Variable**

```cpp
a = a ^ b;
b = a ^ b;
a = a ^ b;
```

1. **First Operation**:

```cpp
a = a ^ b;
```
    
- This operation stores the result of `a XOR b` in `a`. At this point, `a` contains a value that represents both `a` and `b` without revealing either of them.
2. **Second Operation**:

```cpp
b = a ^ b;
```
    
- Here, we take the new value of `a` (which is `a XOR b`) and XOR it with `b`. The result of this operation is the original value of `a`. This is because:
	- `a XOR b XOR b` simplifies to `a` (since `b XOR b` equals `0` and `x XOR 0` equals `x`).
3. **Third Operation:**
```cpp
a = a ^ b;
```

- Finally, we take the new value of `b` (which is now the original value of `a`) and XOR it with the current value of `a` (which is `a XOR b`). The result of this operation is the original value of `b`. This works because:
    - `a XOR b XOR a` simplifies to `b` (for the same reason as above).

#### **3. Count the Number of 1s in a Binary Representation (Brian Kernighan's Algorithm)**

```cpp
int countOnes(int n) {
    int count = 0;
    while (n) {
        n = n & (n - 1);
        count++;
    }
    return count;
}
```

1. **Initialize `count` to 0** – This variable keeps track of the number of `1` bits in `n`.
2. **Loop while `n` is nonzero**:
    - `n & (n - 1)` removes the **rightmost set bit (1)** in `n`.
    - Each iteration decreases the number of `1`s in `n` until `n` becomes `0`.
    - Increment `count` after each operation.
3. **Return `count`**, which is the total number of `1`s in the binary representation of `n`.

**How `n = n & (n - 1)` Works**

- The expression `n & (n - 1)` clears the **rightmost set bit** (the lowest `1` bit) in `n`.

**Example Walkthrough**

Let's take `n = 13` (`1101` in binary).

1. **Initial:** `n = 1101`
    
    - `n - 1 = 1100`
    - `n & (n - 1) = 1101 & 1100 = 1100`
    - `count = 1`
2. **Next Iteration:** `n = 1100`
    
    - `n - 1 = 1011`
    - `n & (n - 1) = 1100 & 1011 = 1000`
    - `count = 2`
3. **Next Iteration:** `n = 1000`
    
    - `n - 1 = 0111`
    - `n & (n - 1) = 1000 & 0111 = 0000`
    - `count = 3`
4. **Exit Loop** (`n` becomes `0`), return `count = 3`.


#### **4. Check if a Number is a Power of Two**

```cpp
bool isPowerOfTwo(int n) {
    return (n > 0) && ((n & (n - 1)) == 0);
}
```


A number is a power of two if it has exactly **one** bit set in its binary representation. For example:

- $2^0 = 1$ → `0001`
- $2^1 = 2$ → `0010`
- $2^2 = 4$ → `0100`
- $2^3 = 8$ → `1000`

Each power of two has exactly **one** `1` in its binary form.

**How It Works**

```cpp
return (n > 0) && ((n & (n - 1)) == 0);
```

1. **`n > 0`**: Ensures that `n` is positive (powers of two are always positive).
2. **`(n & (n - 1)) == 0`**:
    - This expression clears the rightmost set bit.
    - If `n` is a power of two, it has exactly **one** set bit, so `n & (n - 1)` results in `0`.
    - If `n` is **not** a power of two, it has more than one `1` bit, and `n & (n - 1)` is **not** `0`.

**Example Walkthrough**

**Example 1: `n = 8` (Power of 2)**

- Binary: `1000`
- `n - 1 = 7` (`0111`)
- `n & (n - 1) = 1000 & 0111 = 0000`
- Returns **true**.

**Example 2: `n = 10` (Not a power of 2)**

- Binary: `1010`
- `n - 1 = 9` (`1001`)
- `n & (n - 1) = 1010 & 1001 = 1000`
- Returns **false**.

**Example 3: `n = 0`**

- `0 & (-1) = 0`, but `n > 0` is false.
- Returns **false**.

**Example 4: `n = -16`**

- Negative numbers are not powers of two.
- `n > 0` is false.
- Returns **false**.

#### **5. Set a Specific Bit**

```cpp
num |= (1 << pos);  // Set bit at 'pos' to 1
```

#### **6. Clear a Specific Bit**

```cpp
num &= ~(1 << pos);  // Clear bit at 'pos' (set to 0)
```

#### **7. Toggle a Bit**

```cpp
num ^= (1 << pos);  // Flip bit at 'pos'
```


#### **8. Counting Set Bits (Hamming Weight)**

✅ **Using Kernighan’s Algorithm**

```cpp
int countSetBits(int n) {
    int count = 0;
    while (n) {
        n &= (n - 1);  // Removes the rightmost set bit
        count++;
    }
    return count;
}
```

✅ **Example**:

```cpp
cout << countSetBits(7);  // Output: 3 (111 has 3 ones)
```

---

#### **9. Finding the Only Non-Repeating Element (XOR Trick)**

Given an array where every number appears twice except for one, find the unique number.  
✅ **Bitwise XOR Solution**

```cpp
int findUnique(vector<int>& nums) {
    int result = 0;
    for (int num : nums) {
        result ^= num;
    }
    return result;
}
```

✅ **Example**:

```cpp
vector<int> arr = {2, 3, 5, 3, 2};
cout << findUnique(arr);  // Output: 5
```

---

#### **10. Computing `x^y` (Exponentiation by Squaring)**

✅ **Efficient Power Calculation (O(log y))**

```cpp
long long power(long long x, long long y, long long mod) {
    long long result = 1;
    while (y > 0) {
        if (y & 1)  // If y is odd, multiply x
            result = (result * x) % mod;
        x = (x * x) % mod;  // Square x
        y >>= 1;  // Divide y by 2
    }
    return result;
}
```

✅ **Example**:

```cpp
cout << power(2, 10, 1000000007);  // Output: 1024
```

---

#### **11. Finding the Most Significant Set Bit**

✅ **Using `log2(n)`**

```cpp
int mostSignificantBit(int n) {
    return 1 << (31 - __builtin_clz(n));
}
```

✅ **Example**:

```cpp
cout << mostSignificantBit(18);  // Output: 16
```

---

#### **12. Greatest Common Divisor (GCD) Using Bitwise Operations**

✅ **Stein’s Algorithm (Binary GCD)**

```cpp
int gcd(int a, int b) {
    if (b == 0) return a;
    return gcd(b, a % b);
}
```

✅ **Example**:

```cpp
cout << gcd(48, 18);  // Output: 6
```

---

**Summary**

- **AND (`&`)** → Extract specific bits.
- **OR (`|`)** → Set specific bits.
- **XOR (`^`)** → Toggle bits, swap numbers.
- **NOT (`~`)** → Flip all bits.
- **Left Shift (`<<`)** → Multiply by `2^n`.
- **Right Shift (`>>`)** → Divide by `2^n`.

---

## Aliases

`typedef` and `using` are both C++ language features used to create aliases for existing data types, making code more readable, maintainable, and portable. 
### typedef

`typedef` is a keyword used to create an alias for an existing data type. It's particularly useful for defining custom names for complex data types or for making code more readable by providing descriptive aliases.

**Syntax:**
```cpp
typedef existing_type new_name;
```

**Example:**
```cpp
typedef int Int32; // Defines Int32 as an alias for int
typedef double Real; // Defines Real as an alias for double
```

### using

`using` is a newer C++ keyword which also creates aliases for existing data types. It offers some advantages over `typedef`, such as improved syntax for template aliases and compatibility with type inference.

**Syntax:**
```cpp
using new_name = existing_type;
```

**Example:**
```cpp
using Int32 = int; // Defines Int32 as an alias for int
using Real = double; // Defines Real as an alias for double
```

***

## Type Casting/Conversion

In C++, type casting (or type conversion) is the process of converting a value from one data type to another. This can happen either implicitly (automatically) or explicitly (manually by the programmer). Let's go over the different types of type casting in C++:

### 1. **Implicit Type Casting (Automatic Conversion)**
Implicit type casting occurs when the compiler automatically converts one data type to another. This usually happens when you mix different data types in an expression, or when you assign a value of one type to a variable of another type.

**Example:**
```cpp
int a = 10;
double b = a;  // Implicit conversion from int to double
```
In this example, `a` is an integer, but when assigned to `b`, it's automatically converted to a double.

### 2. **Explicit Type Casting (Manual Conversion)**
Explicit type casting is when the programmer manually converts a value from one type to another. C++ offers several ways to perform explicit type casting:

#### a. **C-Style Cast**
The C-style cast is the simplest form of casting and looks like this:
```cpp
int a = 10;
double b = (double)a;  // C-style cast from int to double
```

#### b. **Function-Style Cast**
This casting is similar to C-style but uses function notation:
```cpp
int a = 10;
double b = double(a);  // Function-style cast from int to double
```

#### c. **`static_cast`**
`static_cast` is a more specific and safer casting method. It is used when you want to convert between related types, like between integers and floating-point numbers, or between pointers of base and derived classes in inheritance.

**Example:**
```cpp
int a = 10;
double b = static_cast<double>(a);  // static_cast from int to double
```

#### d. **`dynamic_cast`**
`dynamic_cast` is primarily used for casting pointers or references to base class objects into pointers or references to derived class objects. It is only used in classes that have `virtual` functions (i.e., polymorphic classes).

**Example:**
```cpp
class Base { virtual void foo() {} };
class Derived : public Base {};
Base* basePtr = new Derived;
Derived* derivedPtr = dynamic_cast<Derived*>(basePtr);  // dynamic_cast to Derived
```

If the cast is not valid (e.g., if `basePtr` actually points to an object of some class other than `Derived`), `dynamic_cast` returns `nullptr` for pointers, and throws a `bad_cast` exception for references.

#### e. **`const_cast`**
`const_cast` is used to add or remove the `const` qualifier from a variable. It is often used when interacting with legacy code that requires non-const variables.

**Example:**
```cpp
const int a = 10;
int* b = const_cast<int*>(&a);  // const_cast removes const-ness
```

#### f. **`reinterpret_cast`**
`reinterpret_cast` is the most powerful and dangerous cast. It is used to cast one type to any other type, even if the types are completely unrelated. It's often used for low-level programming, like converting between pointers and integers.

**Example:**
```cpp
int a = 10;
void* ptr = reinterpret_cast<void*>(&a);  // reinterpret_cast to void*
int* b = reinterpret_cast<int*>(ptr);     // reinterpret_cast back to int*
```

### Important Notes:
- **Safety**: While explicit casts give you control, they can lead to errors if used incorrectly. For example, `reinterpret_cast` can be particularly dangerous because it can lead to undefined behavior if used improperly.
- **Use Cases**: Always prefer safer casting methods (`static_cast`, `dynamic_cast`) when possible, and use `reinterpret_cast` and `const_cast` only when absolutely necessary.

---

## **Scope Resolution**

The **scope resolution operator (`::`)** in C++ is used to access a member or function that is out of the current scope. It is particularly useful when handling **global and local variable conflicts, class inheritance, namespaces, and static members**.

---

### **Accessing Global Variables**

If a **local variable** has the same name as a **global variable**, the `::` operator allows access to the global variable.

✅ **Example:**

```cpp
#include <iostream>
using namespace std;

int x = 10; // Global variable

int main() {
    int x = 20; // Local variable
    cout << "Local x: " << x << endl;
    cout << "Global x: " << ::x << endl; // Accessing global x
}
```

**Output:**

```
Local x: 20
Global x: 10
```

---

### **Accessing Static Class Members**

Static members belong to the class rather than an instance, so they must be accessed using the class name and `::`.

✅ **Example:**

```cpp
class Test {
public:
    static int count; // Declaration
};

int Test::count = 5; // Definition

int main() {
    cout << "Static count: " << Test::count << endl;
}
```

**Output:**

```
Static count: 5
```

---

### **Defining Class Member Functions Outside the Class**

The `::` operator is used when defining **member functions outside the class definition**.

✅ **Example:**

```cpp
class MyClass {
public:
    void show(); // Function declaration
};

void MyClass::show() {  // Function definition using scope resolution
    cout << "Hello from MyClass" << endl;
}

int main() {
    MyClass obj;
    obj.show();
}
```

**Output:**

```
Hello from MyClass
```

---

### **Accessing Base Class Members in Inheritance**

When a derived class overrides a base class function, you can access the base class version using `::`.

✅ **Example:**

```cpp
class Parent {
public:
    void show() { cout << "Parent class\n"; }
};

class Child : public Parent {
public:
    void show() { cout << "Child class\n"; }
    void display() { Parent::show(); }  // Accessing base class function
};

int main() {
    Child obj;
    obj.show();
    obj.display();  // Calls Parent's show()
}
```

**Output:**

```
Child class
Parent class
```

---

### **Accessing Namespaces**

The `::` operator is used to access members inside a **specific namespace**.

✅ **Example:**

```cpp
#include <iostream>
namespace First {
    int x = 10;
}

namespace Second {
    int x = 20;
}

int main() {
    cout << "First::x: " << First::x << endl;
    cout << "Second::x: " << Second::x << endl;
}
```

**Output:**

```
First::x: 10
Second::x: 20
```

---

### **Key Points**

✅ **Use `::` to access global variables when shadowed by local variables.**  
✅ **Access static class members using `ClassName::member`.**  
✅ **Define class functions outside the class with `ClassName::FunctionName()`.**  
✅ **Access base class members in inheritance using `BaseClass::Function()`.**  
✅ **Use `::` to access specific namespaces in case of naming conflicts.**

***
# Data Structures & STL

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

## **Iterators**

Iterators in C++ are objects that allow traversal through containers like arrays, vectors, lists, and maps. They work similarly to pointers and provide a way to access container elements sequentially.

---

### **Types of Iterators**

C++ iterators can be categorized based on their functionality and direction:

| **Iterator Type**          | **Operations Supported**         | **Example Containers**     |
| -------------------------- | -------------------------------- | -------------------------- |
| **Input Iterator**         | Read-only, single-pass           | `istream_iterator`         |
| **Output Iterator**        | Write-only, single-pass          | `ostream_iterator`         |
| **Forward Iterator**       | Read/Write, single-pass          | `forward_list`             |
| **Bidirectional Iterator** | Read/Write, forward and backward | `list`, `map`              |
| **Random Access Iterator** | Read/Write, direct index access  | `vector`, `deque`, `array` |

---

### **Basic Iterator Usage**

**Example: Using Iterators with a `vector`**

```cpp
#include <iostream>
#include <vector>

int main() {
    std::vector<int> numbers = {10, 20, 30, 40, 50};

    // Declaring an iterator
    std::vector<int>::iterator it;

    // Traversing using an iterator
    for (it = numbers.begin(); it != numbers.end(); ++it) {
        std::cout << *it << " ";
    }
}
```

**Output:**

```
10 20 30 40 50
```

✅ **`begin()`** points to the first element, and **`end()`** points to **one past** the last element.

---

### **`auto` Keyword with Iterators**

Instead of writing `std::vector<int>::iterator`, you can use `auto`:

```cpp
for (auto it = numbers.begin(); it != numbers.end(); ++it) {
    std::cout << *it << " ";
}
```

---

### **Reverse Iterators**

To traverse a container **backwards**, use `rbegin()` and `rend()`:

```cpp
#include <iostream>
#include <vector>

int main() {
    std::vector<int> numbers = {10, 20, 30, 40, 50};

    for (auto it = numbers.rbegin(); it != numbers.rend(); ++it) {
        std::cout << *it << " ";
    }
}
```

**Output:**

```
50 40 30 20 10
```

---

### **Constant Iterators (`const_iterator`)**

If you don’t want to modify elements, use `const_iterator`:

```cpp
#include <iostream>
#include <vector>

int main() {
    std::vector<int> numbers = {10, 20, 30, 40, 50};

    for (std::vector<int>::const_iterator it = numbers.cbegin(); it != numbers.cend(); ++it) {
        std::cout << *it << " ";
        // *it = 100;  // ❌ Compilation error (cannot modify)
    }
}
```

---

### **Iterator Invalidation**

Be careful when modifying a container while iterating. Some operations **invalidate** iterators.

✅ **Example: Safe deletion using `erase()`**

```cpp
#include <iostream>
#include <vector>

int main() {
    std::vector<int> numbers = {10, 20, 30, 40, 50};

    for (auto it = numbers.begin(); it != numbers.end(); ) {
        if (*it == 30) {
            it = numbers.erase(it);  // `erase()` returns the next valid iterator
        } else {
            ++it;
        }
    }

    for (int num : numbers) {
        std::cout << num << " ";
    }
}
```

### **Output:**

```
10 20 40 50
```

❌ **Don't use an invalidated iterator (after `erase()`).**

**What is iterator invalidation?**

1. **What Happens During Invalidation**:
    - When a container is modified (for example, by adding or removing elements), the internal structure of the container may change. This can cause existing iterators to point to memory locations that are no longer valid.
    - For instance, if you remove an element from a vector, any iterators pointing to that element or any elements after it may become invalid.
2. **Types of Modifications That Cause Invalidation**:
    - **Insertion**: Adding elements can cause reallocation of memory, especially in dynamic arrays like `std::vector`. This can invalidate all iterators pointing to the vector.
    - **Deletion**: Removing elements can invalidate iterators pointing to the deleted element or any elements that follow it.
    - **Resizing**: Changing the size of a container can also lead to invalidation.
3. **Container-Specific Rules**:
    - Different containers have different rules regarding iterator invalidation. For example:
        - **`std::vector`**: Inserting or deleting elements can invalidate all iterators if the vector needs to reallocate memory.
        - **`std::list`**: Inserting or deleting elements does not invalidate iterators to other elements, as lists are implemented as linked structures.
        - **`std::deque`**: Similar to vectors, but the rules can vary based on the operation.
4. **Consequences of Using Invalidated Iterators**:
    - Using an invalidated iterator can lead to undefined behavior, which may manifest as crashes, incorrect data access, or other unpredictable outcomes.
5. **Best Practices**:
    - Always check the validity of iterators after modifying the container.
    - Use container-specific methods to safely manage iterators, such as `erase` returning a valid iterator to the next element after deletion.
    - Consider using higher-level abstractions or algorithms that manage iterators more safely.

Some operations **invalidate iterators** (make them unusable):

| **Operation** | **Affected Containers**   | **Invalidates Iterators?**   |
| ------------- | ------------------------- | ---------------------------- |
| `push_back()` | `vector`, `deque`         | Yes (if reallocation occurs) |
| `insert()`    | `vector`, `deque`, `list` | Yes                          |
| `erase()`     | `vector`, `deque`, `list` | Yes                          |
| `clear()`     | All containers            | Yes                          |

---

### **Random Access with Iterators (`vector`, `deque`, `array`)**

```cpp
std::vector<int>::iterator it = numbers.begin();
std::cout << *(it + 2);  // Access the 3rd element (random access)
```

This works only for **random access iterators**, like those in `vector` and `array`.

---

### **All Iterator Methods**

Iterators provide various methods/functions to traverse and manipulate elements in C++ containers. Below is a **comprehensive list** of iterator methods commonly used in C++ Standard Library (STL) containers.

---

#### **Common Iterator Methods**

These methods are available in **most containers** (`vector`, `list`, `map`, `set`, etc.).

| **Method**  | **Description**                                                   |
| ----------- | ----------------------------------------------------------------- |
| `begin()`   | Returns an iterator to the first element.                         |
| `end()`     | Returns an iterator **past the last element** (invalid position). |
| `rbegin()`  | Returns a reverse iterator to the **last** element.               |
| `rend()`    | Returns a reverse iterator **before the first** element.          |
| `cbegin()`  | Returns a **constant iterator** to the first element.             |
| `cend()`    | Returns a **constant iterator** past the last element.            |
| `crbegin()` | Returns a **constant reverse iterator** to the last element.      |
| `crend()`   | Returns a **constant reverse iterator** before the first element. |

✅ **Example:**

```cpp
#include <iostream>
#include <vector>

int main() {
    std::vector<int> nums = {10, 20, 30, 40, 50};

    auto it = nums.begin();    // Iterator to first element
    auto rit = nums.rbegin();  // Reverse iterator to last element

    std::cout << *it << "\n";   // 10
    std::cout << *rit << "\n";  // 50
}
```

---

#### **Iterator Operations**

Iterator objects support **pointer-like operations**:

| **Operation** | **Description**                                             |
| ------------- | ----------------------------------------------------------- |
| `*it`         | Dereference to access the value.                            |
| `it->member`  | Access struct/class members using iterator.                 |
| `++it`        | Move forward (prefix increment).                            |
| `it++`        | Move forward (postfix increment).                           |
| `--it`        | Move backward (prefix decrement).                           |
| `it--`        | Move backward (postfix decrement).                          |
| `it + n`      | Move forward `n` positions (random access iterators only).  |
| `it - n`      | Move backward `n` positions (random access iterators only). |
| `it1 - it2`   | Get distance between two iterators.                         |
| `it1 == it2`  | Compare iterators (equality check).                         |
| `it1 != it2`  | Compare iterators (inequality check).                       |

✅ **Example:**

```cpp
#include <iostream>
#include <vector>

#include <string>

class Person {
public:
    std::string name;
    Person(std::string n) : name(n) {}
};

int main() {
    std::vector<int> nums = {10, 20, 30, 40, 50};
    
    auto it = nums.begin();
    std::cout << *(it + 2) << "\n";  // 30 (Random Access)
    
    ++it;   // Move forward
    std::cout << *it << "\n";  // 20

	std::vector<Person> people = { Person("Alice"), Person("Bob"), Person("Charlie") };

    for (auto it = people.begin(); it != people.end(); ++it) {
        std::cout << it->name << std::endl; // Accessing the 'name' member
    }
}
```

---

#### **Special Methods for Different Containers**

Some **container-specific** iterator methods:

|**Method**|**Container**|**Description**|
|---|---|---|
|`insert(it, value)`|`vector`, `list`, `deque`|Inserts value at iterator position.|
|`erase(it)`|`vector`, `list`, `deque`|Removes element at iterator position.|
|`erase(it1, it2)`|`vector`, `list`, `deque`|Removes a range of elements.|
|`find(value)`|`set`, `map`, `unordered_map`|Returns iterator to the value (or `end()` if not found).|
|`lower_bound(value)`|`set`, `map`|Returns iterator to first element **≥ value**.|
|`upper_bound(value)`|`set`, `map`|Returns iterator to first element **> value**.|

✅ **Example: Erasing Elements Safely**

```cpp
#include <iostream>
#include <vector>

int main() {
    std::vector<int> nums = {10, 20, 30, 40, 50};

    auto it = nums.begin() + 2;  // Iterator to 30
    nums.erase(it);  // Remove 30

    for (int num : nums) {
        std::cout << num << " ";  // 10 20 40 50
    }
}
```

---

#### **Stream Iterators (`istream_iterator` and `ostream_iterator`)**

For reading/writing from streams:

✅ **Reading Input Using `istream_iterator`**

```cpp
#include <iostream>
#include <iterator>

int main() {
    std::istream_iterator<int> in(std::cin), end;
    int value = *in;  // Read integer input
    std::cout << "You entered: " << value << "\n";
}
```

✅ **Writing Output Using `ostream_iterator`**

```cpp
#include <iostream>
#include <iterator>
#include <vector>

int main() {
    std::vector<int> nums = {10, 20, 30};
    std::ostream_iterator<int> out(std::cout, " ");
    
    std::copy(nums.begin(), nums.end(), out);  // Print elements: 10 20 30
}
```

##### `std::copy`

`std::copy` is a standard algorithm in C++ that is used to copy elements from one range to another. It is part of the C++ Standard Library and is defined in the `<algorithm>` header. Here’s a detailed explanation of how it works and its usage.

**Function Signature**

The basic signature of `std::copy` is as follows:

```cpp
template<class InputIt, class OutputIt>
OutputIt copy(InputIt first, InputIt last, OutputIt d_first);
```

**Parameters**

- **`first`**: An iterator pointing to the beginning of the source range (the first element to copy).
- **`last`**: An iterator pointing to the end of the source range (one past the last element to copy).
- **`d_first`**: An iterator pointing to the beginning of the destination range where the elements will be copied.

**Return Value**

`std::copy` returns an iterator pointing to the end of the destination range, which is one past the last element copied. This allows you to easily determine where the copying has stopped.


***

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
## Multidimensional Arrays and Vectors

Two-dimensional arrays and vectors in C++ are useful for representing data structures like matrices, grids, tables, and other two-dimensional structures. Here's how they are defined and used:

### Two-Dimensional Arrays:

```cpp
const int ROWS = 3;
const int COLS = 4;
int matrix[ROWS][COLS]; // Declaration of a 3x4 integer array

// Initialization
matrix[0][0] = 1;
matrix[0][1] = 2;
// ...

// Accessing elements
int element = matrix[1][2];
```

### Multidimensional Arrays:

```cpp
const int ROWS = 3;
const int COLS = 4;
const int DEPTH = 2;
int cube[DEPTH][ROWS][COLS]; // Declaration of a 3D integer array

// Initialization
cube[0][0][0] = 1;
cube[1][2][3] = 2;
// ...

// Accessing elements
int element = cube[1][2][3];
```

### Two-Dimensional Vectors:

```cpp
#include <vector>
// Type Declaration
std::vector<std::vector<int>> matrix;

// Resizing and initializing the matrix
matrix.resize(ROWS, std::vector<int>(COLS, 0));

// Initialization
matrix[0][0] = 1;
matrix[0][1] = 2;
// ...

// Accessing elements
int element = matrix[1][2];
```

- **`ROWS`**: This specifies the number of rows in the matrix.
- **`std::vector<int>(COLS, 0)`**: This creates a vector of integers with `COLS` elements, each initialized to `0`.
- **`matrix.resize(ROWS, ...)`**: This resizes the `matrix` to have `ROWS` number of rows. Each row is initialized to a vector of `COLS` integers, all set to `0`.

### Multidimensional Vectors:

```cpp
#include <vector>
std::vector<std::vector<std::vector<int>>> cube;

// Resizing and initializing the cube
cube.resize(DEPTH, std::vector<std::vector<int>>(ROWS, std::vector<int>(COLS, 0)));

// Initialization
cube[0][0][0] = 1;
cube[1][2][3] = 2;
// ...

// Accessing elements
int element = cube[1][2][3];
```

- **`cube.resize(DEPTH, ...)`**:
    - **`DEPTH`**: Specifies the number of layers (depth) in the cube.
- **`std::vector<std::vector<int>>(ROWS, std::vector<int>(COLS, 0))`**:
    - **`ROWS`**: Specifies the number of rows in each layer.
    - **`std::vector<int>(COLS, 0)`**: Creates a vector of integers with `COLS` elements, each initialized to `0`.

**Benefits of Vectors over Arrays**:

- **Dynamic Size**: Vectors can dynamically resize, unlike arrays, which have fixed sizes.
- **Automatic Memory Management**: Vectors handle memory management automatically, unlike arrays, which require manual memory management.
- **Easier Iteration and Access**: Vectors provide convenient methods for iteration and access to elements.

---

## list

### Overview

`list` is a **doubly linked list** container in C++. It allows **efficient insertion and deletion** at both the beginning and the end, as well as in the middle of the sequence, making it useful when frequent modifications are needed. However, **random access (e.g., using an index like `vec[i]`) is not supported** since elements are not stored contiguously in memory.

`std::list` is implemented as a doubly linked list, where each element (node) contains pointers to both the previous and next elements. This allows for **constant time** insertion and deletion operations at any position in the list, provided you have an iterator pointing to that position. This means that you can insert or remove an element without needing to shift any other elements.

### Syntax

```cpp
#include <iostream>
#include <list>

int main() {
    std::list<int> numbers = {1, 2, 3, 4, 5};

    // Adding elements
    numbers.push_back(6);
    numbers.push_front(0);

    // Iterating over elements
    for (int num : numbers) {
        std::cout << num << " ";
    }

    return 0;
}
```

**Output:**

```
0 1 2 3 4 5 6
```

**Key Features**

- **Doubly Linked List:** Each element has pointers to both the previous and next elements.
- **Efficient Insertions & Deletions:** `O(1)` complexity at the beginning or end.
- **No Random Access:** Accessing elements requires iteration (`O(n)` complexity).

### Important Methods

#### Insert and Remove Elements

```cpp
std::list<int> lst = {10, 20, 30};
lst.push_back(40);   // Adds 40 at the end
lst.push_front(5);   // Adds 5 at the beginning
lst.insert(++lst.begin(), 15); // Inserts 15 at second position
lst.erase(--lst.end()); // Removes last element
lst.pop_front(); // Removes first element
lst.pop_back();  // Removes last element
```

#### Iterating Over a List

```cpp
for (int num : lst) {
    std::cout << num << " ";
}
```

#### Sorting and Reversing

```cpp
lst.sort();   // Sorts in ascending order
lst.reverse(); // Reverses the order of elements
```

#### Merging Two Lists

```cpp
std::list<int> list1 = {1, 3, 5};
std::list<int> list2 = {2, 4, 6};
list1.merge(list2); // Merges list2 into list1 (both must be sorted)
```

#### Removing Duplicates

```cpp
lst.unique(); // Removes consecutive duplicate elements
```

---

## **`forward_list`**

`std::forward_list` is a **singly linked list** in C++ that provides **fast insertion and deletion** at any position but does not support direct access like a vector or a `std::list`. Unlike `std::list`, it only maintains a **single pointer to the next node**, making it **memory efficient** but **less flexible** in bidirectional traversal.

---

### **Header File**

```cpp
#include <forward_list>
```

---

### **Creating a `forward_list`**

✅ **Basic Declaration and Initialization**

```cpp
#include <iostream>
#include <forward_list>
using namespace std;

int main() {
    forward_list<int> fl = {10, 20, 30, 40};

    for (int x : fl) cout << x << " ";
}
```

**Output:**

```
10 20 30 40
```

✅ **Default Constructor**

```cpp
forward_list<int> fl; // Empty forward_list
```

✅ **Custom Size with Default Values**

```cpp
forward_list<int> fl(5, 100); // 5 elements, each initialized to 100
```

---

### **Modifying a `forward_list`**

#### **Adding Elements**

✅ **`push_front(value)` – Insert at the front**

```cpp
fl.push_front(5);  // Adds 5 at the beginning
```

✅ **`emplace_front(value)` – Faster insertion at the front**

```cpp
fl.emplace_front(2);  // Similar to push_front but avoids extra copying
```

✅ **`insert_after(iterator, value)` – Insert after a given position**

```cpp
auto it = fl.before_begin(); // Iterator before first element
fl.insert_after(it, 15);  // Inserts 15 after first element
```

✅ **`emplace_after(iterator, value)` – Construct element after iterator**

```cpp
fl.emplace_after(it, 25);  // Faster insertion
```

#### **Removing Elements**

✅ **`pop_front()` – Remove first element**

```cpp
fl.pop_front();  // Removes the first element
```

✅ **`erase_after(iterator)` – Remove after a given position**

```cpp
fl.erase_after(fl.before_begin());  // Removes the element after the first
```

✅ **`remove(value)` – Remove all elements with a specific value**

```cpp
fl.remove(30);  // Removes all occurrences of 30
```

✅ **`remove_if(condition)` – Remove elements based on a condition**

```cpp
fl.remove_if([](int x) { return x % 2 == 0; }); // Removes all even numbers
```

---

### **Accessing Elements**

Since `forward_list` does not support random access (`[]` or `.at()`), we must **iterate over it manually**.

✅ **Using a Range-based Loop**

```cpp
for (int x : fl) cout << x << " ";
```

✅ **Using an Iterator**

```cpp
for (auto it = fl.begin(); it != fl.end(); ++it)
    cout << *it << " ";
```

---

### **Other Operations**

✅ **`assign()` – Assign new values**

```cpp
fl.assign({1, 2, 3, 4});
```

✅ **`reverse()` – Reverse the order**

```cpp
fl.reverse();
```

✅ **`sort()` – Sort in ascending order**

```cpp
fl.sort();
```

✅ **`merge(other_list)` – Merge two sorted lists**

```cpp
forward_list<int> fl2 = {5, 15, 25};
fl.merge(fl2);  // Both lists must be sorted
```

✅ **`unique()` – Remove consecutive duplicates**

```cpp
fl.unique();  // Removes consecutive duplicates only
```

---

### **Key Points**

✅ **`forward_list` is a singly linked list (more memory efficient than `list`).**  
✅ **Supports fast insertions and deletions but lacks random access.**  
✅ **Operations like `push_front()`, `pop_front()`, `insert_after()`, and `erase_after()` modify elements efficiently.**  
✅ **Sorting, merging, and reversing are available.**  
✅ **Ideal for scenarios requiring frequent insertions/deletions but not random access.**

🚀 **Use `forward_list` for optimized memory usage when you don’t need bidirectional traversal!**

---

## **Deque (Double-Ended Queue)**

The **`std::deque` (double-ended queue)** is a dynamic array-like container that allows **fast insertions and deletions from both ends**.

---

### **Key Features of `deque`**

| **Feature**                     | **Description**                                                                           |
| ------------------------------- | ----------------------------------------------------------------------------------------- |
| **Fast Insert/Remove**          | O(1) at both front and back (unlike `vector`, which is O(n) for front insertions).        |
| **Random Access**               | Provides **O(1) access** like `vector`.                                                   |
| **Dynamic Resizing**            | Grows automatically when needed, like `vector`.                                           |
| **Efficient Middle Operations** | Better than `vector`, but `list` is still better for frequent middle insertions/removals. |

---

### **Basic Usage of `deque`**

```cpp
#include <iostream>
#include <deque>

int main() {
    std::deque<int> dq = {10, 20, 30};

    dq.push_front(5);  // Insert at the front: {5, 10, 20, 30}
    dq.push_back(40);  // Insert at the back: {5, 10, 20, 30, 40}

    std::cout << "Front: " << dq.front() << "\n";  // 5
    std::cout << "Back: " << dq.back() << "\n";   // 40
}
```

---

### **`deque` Iterator Methods**

Like `vector`, `deque` supports **iterators**.

|**Method**|**Description**|
|---|---|
|`begin()`|Iterator to the first element.|
|`end()`|Iterator **past the last element**.|
|`rbegin()`|Reverse iterator to the last element.|
|`rend()`|Reverse iterator **before the first** element.|
|`cbegin()`|Constant iterator to the first element.|
|`cend()`|Constant iterator past the last element.|
|`crbegin()`|Constant reverse iterator to the last element.|
|`crend()`|Constant reverse iterator before the first element.|

✅ **Example: Using Iterators**

```cpp
#include <iostream>
#include <deque>

int main() {
    std::deque<int> dq = {10, 20, 30, 40};

    // Normal iteration
    for (auto it = dq.begin(); it != dq.end(); ++it) {
        std::cout << *it << " ";  // 10 20 30 40
    }

    std::cout << "\n";

    // Reverse iteration
    for (auto rit = dq.rbegin(); rit != dq.rend(); ++rit) {
        std::cout << *rit << " ";  // 40 30 20 10
    }
}
```

---

### **`deque` Methods**

#### **(A) Modifiers**

|**Method**|**Description**|
|---|---|
|`push_front(x)`|Insert `x` at the front.|
|`push_back(x)`|Insert `x` at the back.|
|`pop_front()`|Remove the first element.|
|`pop_back()`|Remove the last element.|
|`insert(it, x)`|Insert `x` at iterator `it` position.|
|`erase(it)`|Erase element at iterator `it` position.|
|`erase(it1, it2)`|Erase elements in the range `[it1, it2)`.|
|`clear()`|Remove all elements.|
|`resize(n)`|Resize `deque` to `n` elements.|

✅ **Example: Insertions and Deletions**

```cpp
#include <iostream>
#include <deque>

int main() {
    std::deque<int> dq = {10, 20, 30};

    dq.push_front(5);   // {5, 10, 20, 30}
    dq.push_back(40);   // {5, 10, 20, 30, 40}

    dq.pop_front();  // {10, 20, 30, 40}
    dq.pop_back();   // {10, 20, 30}

    dq.insert(dq.begin() + 1, 15);  // {10, 15, 20, 30}
    dq.erase(dq.begin());  // {15, 20, 30}

    for (int num : dq) {
        std::cout << num << " ";  // 15 20 30
    }
}
```

---

#### **(B) Access Methods**

|**Method**|**Description**|
|---|---|
|`front()`|Returns the first element.|
|`back()`|Returns the last element.|
|`at(i)`|Returns the element at index `i` with **bounds checking**.|
|`operator[i]`|Returns the element at index `i` **without bounds checking**.|

✅ **Example: Accessing Elements**

```cpp
#include <iostream>
#include <deque>

int main() {
    std::deque<int> dq = {10, 20, 30, 40};

    std::cout << dq.front() << "\n";  // 10
    std::cout << dq.back() << "\n";   // 40
    std::cout << dq[2] << "\n";       // 30
}
```

---

#### **(C) Capacity Methods**

| **Method**   | **Description**                                  |
| ------------ | ------------------------------------------------ |
| `size()`     | Returns the number of elements.                  |
| `max_size()` | Returns the maximum possible number of elements. |
| `empty()`    | Checks if `deque` is empty.                      |

✅ **Example: Checking Size and Emptiness**

```cpp
#include <iostream>
#include <deque>

int main() {
    std::deque<int> dq = {10, 20, 30};

    std::cout << dq.size() << "\n";  // 3
    std::cout << (dq.empty() ? "Empty" : "Not Empty") << "\n";  // Not Empty
}
```

---

### **`deque` vs `vector` vs `list`**

|**Feature**|**deque**|**vector**|**list**|
|---|---|---|---|
|**Random Access**|✅ Yes|✅ Yes|❌ No|
|**Fast Front Insert/Remove**|✅ Yes|❌ No|✅ Yes|
|**Fast Back Insert/Remove**|✅ Yes|✅ Yes|✅ Yes|
|**Memory Efficiency**|✅ Medium|✅ Best|❌ Worst|
|**Middle Insert/Remove**|✅ Medium|❌ Slow|✅ Fast|

👉 **Use `deque` when you need:**  
✅ **Fast insertions/removals at both ends** but still want **random access**.  
✅ A balance between **`vector` (fast access)** and **`list` (fast middle insertions)**.

---

**Summary**

✔ **`deque` is a hybrid of `vector` and `list`**, offering fast insertions/removals at both ends while allowing **O(1) random access**.  
✔ **Use `push_front()` and `push_back()`** for efficient insertions.  
✔ **Supports iterators** for traversal (`begin()`, `end()`, `rbegin()`, etc.).  
✔ **Middle insertions (`insert()`) are faster than `vector`, but `list` is still better**.  
✔ **Avoid using `deque` for large middle modifications** (use `list` instead).

---

## `map` (Unordered Map)

In C++, `std::map` is a container provided by the Standard Template Library (STL) that stores elements in a sorted order based on keys. It allows for efficient retrieval, insertion, and deletion of key-value pairs.

### Key Features:

1. **Associative Lookup**: Provides efficient key-based lookup operations.
2. **Dynamic Size**: The size of a map can grow or shrink dynamically as elements are added or removed.
3. **Balanced Binary Search Tree**: Internally, `std::map` is typically implemented using a balanced binary search tree (usually a Red-Black Tree), which ensures efficient insertion, deletion, and search operations.

| Feature             | Description                                           |
| ------------------- | ----------------------------------------------------- |
| **Ordered**         | Elements are stored in **sorted order** (by key).     |
| **Key-Value Pairs** | Stores data as **`(key, value)`** pairs.              |
| **Unique Keys**     | Each key is **unique** (no duplicates).               |
| **Iterators**       | Provides bidirectional iterators (not random-access). |

#### Balanced Binary Search Trees

A **balanced binary search tree (BST)** is a type of binary search tree that maintains its height in a way that ensures efficient operations such as insertion, deletion, and search. The key characteristic of a balanced BST is that it keeps its height logarithmic relative to the number of nodes, which allows these operations to be performed in **O(log n)** time complexity.

**Characteristics of Balanced Binary Search Trees**

1. **Height-Balancing**:
    - In a balanced BST, the depth of the two subtrees of every node never differs by more than a certain amount (commonly 1). This ensures that the tree remains approximately balanced, preventing it from degenerating into a linked list.
2. **Self-Balancing**:
    - Many balanced BSTs, such as **AVL trees** and **Red-Black trees**, automatically adjust their structure during insertions and deletions to maintain balance. This self-balancing property is crucial for maintaining efficient performance
3. **Logarithmic Height**:
    - The height of a balanced BST is kept in logarithmic proportion to the number of nodes, which is essential for ensuring that operations remain efficient. For example, if a tree has `n` nodes, its height will be approximately `log(n)`.

**Types of Balanced Binary Search Trees**

1. **AVL Trees**:
    - AVL trees are a type of self-balancing BST where the difference in heights between the left and right subtrees (the balance factor) is at most 1 for every node. This strict balancing ensures that AVL trees are always balanced, leading to efficient operations.
2. **Red-Black Trees**:
    - Red-Black trees are another type of self-balancing BST that uses color properties (red and black) to maintain balance. They allow for a more relaxed balancing compared to AVL trees, which can lead to faster insertion and deletion operations in certain scenarios.
3. **Other Variants**:
    - There are other balanced trees, such as **2-3 trees** and **B-trees**, which are used in different contexts, particularly in databases and file systems.

### Example:

```cpp
#include <iostream>
#include <map>

int main() {
    std::map<int, std::string> myMap;

    // Inserting elements
    myMap.insert({1, "One"});
    myMap[2] = "Two";
    myMap[3] = "Three";

    // Accessing elements
    std::cout << "Value associated with key 2: " << myMap.at(2) << std::endl;

    // Iterating over elements
    for (auto it = myMap.begin(); it != myMap.end(); ++it) {
        std::cout << "Key: " << it->first << ", Value: " << it->second << std::endl;
    }
	// or...
	for (const auto& pair : mp) {
        std::cout << pair.first << ": " << pair.second << "\n";
    }

    // Erasing element
    myMap.erase(3);

    // Size check
    if (!myMap.empty()) {
        std::cout << "Size of map: " << myMap.size() << std::endl;
    }

    return 0;
}
```

### Common Methods in Vectors and Maps:

1. **`size()`**: Returns the number of elements in the container.
2. **`empty()`**: Checks if the container is empty.
3. **`clear()`**: Removes all elements from the container.
4. **Iterators**: Both vectors and maps support iterator-based traversal (`begin()`, `end()`, etc.).
5. **`operator[]`**: Allows access to elements by index (vectors) or key (maps).

### Methods:

1. **`insert`**: Inserts elements into the map.

```cpp
std::map<int, std::string> myMap;
myMap.insert(std::make_pair(1, "One"));
```

#### `std::make_pair`

`std::make_pair` is a utility function in C++ that simplifies the creation of `std::pair` objects. It is part of the C++ Standard Library and is particularly useful for constructing key-value pairs in associative containers like `std::map`.


1. **Type Deduction**:
    - One of the main advantages of `std::make_pair` is that it automatically deduces the types of the elements in the pair from the types of the arguments provided. This means you don't need to explicitly specify the types when creating a pair, making the code cleaner and less error-prone
- **Convenience**:
    - Using `make_pair` allows for a more concise syntax when creating pairs. Instead of manually specifying the types, you can simply pass the values, and the function will handle the rest.
- **Usage**:
    - The typical usage of `std::make_pair` is as follows:
        
```cpp
#include <iostream>
#include <utility> // for std::make_pair
#include <map>

int main() {
	std::map<int, std::string> myMap;
	myMap.insert(std::make_pair(1, "Apple")); // Using make_pair to create a pair
	myMap.insert(std::make_pair(2, "Banana"));

	for (const auto& pair : myMap) {
		std::cout << pair.first << ": " << pair.second << std::endl;
	}

	return 0;
}
```
        
**Comparison with `std::pair` Constructor**

While you can create a `std::pair` directly using its constructor, such as `std::pair<int, std::string>(1, "Apple")`, `std::make_pair` is often preferred for its simplicity and type deduction capabilities. The constructor requires you to specify the types explicitly, which can lead to verbosity and potential mismatches if the types are not correctly aligned.

2. **`erase`**: Removes elements from the map by key.

```cpp
myMap.erase(1);
```

3. **`find`**: Searches for an element with a specified key.

```cpp
auto it = myMap.find(1);
if (it != myMap.end()) {
    // Key found, access value: it->second
}
```

4. **`at`**: Accesses the element with the specified key and throws an exception if the key is not found.

```cpp
std::string value = myMap.at(1);
```

**`at` vs `find`**

- **Access Method**: `at` provides direct access to the value, while `find` provides an iterator to the key-value pair.
- **Error Handling**: `at` throws an exception (`std::out_of_range`) for non-existent keys, whereas `find` returns an iterator to `end()`.
- **Modification**: `at` allows direct modification of the value, while `find` requires dereferencing the iterator to modify the value.

5. **`count`**: Returns the number of elements with a specified key.

```cpp
std::map<int, std::string> mp = {{1, "One"}, {2, "Two"}};

std::cout << mp[1] << "\n";      // One
std::cout << mp.at(2) << "\n";   // Two
std::cout << (mp.count(3) ? "Exists" : "Not Found") << "\n";  // Not Found
```

Since `std::map` only allows unique keys, the `count` method will always return either:

- **1**: if the key exists in the map.
- **0**: if the key does not exist in the map.

6. **`size`**: Returns the number of elements in the map.

```cpp
int size = myMap.size();
```

7. **`empty`**: Checks if the map is empty.

```cpp
if (!myMap.empty()) {
    // Map is not empty
}
```

8. **Iterating Over Elements**:
    - Maps provide iterators to traverse through the elements in sorted order based on the keys.

```cpp
std::map<int, std::string> myMap;

// Insert some key-value pairs
myMap[1] = "One";
myMap[2] = "Two";
myMap[3] = "Three";

// Iterate over the map
for (auto it = myMap.begin(); it != myMap.end(); ++it) {
	std::cout << "Key: " << it->first << ", Value: " << it->second << std::endl;
}
```

9. **Clearing the Map**:
    - Removes all elements from the map.

```cpp
myMap.clear();
```

10. **`emplace`**: Constructs and inserts an element into the map in-place.

```cpp
myMap.emplace(5, "Five");
```

#### **`insert` vs `emplace`**

`map::insert`

- **Functionality**: The `insert` method requires an existing object of the type to be inserted. It takes either a single `std::pair` (representing a key-value pair) or two separate arguments (key and value).
- **Copying**: When you use `insert`, the object is copied into the map. This means that if you have a complex object, it will incur the overhead of copying it into the map.

`map::emplace`

- **Functionality**: The `emplace` method constructs the element in place using the provided arguments. It forwards the arguments to the constructor of the element type, which allows for more efficient insertion.
- **No Copying**: Since `emplace` constructs the object directly in the map, it avoids the overhead of copying or moving the object. This is particularly beneficial for objects that are expensive to copy.
- **Variadic Templates**: `emplace` can take multiple arguments, allowing you to construct the key-value pair directly without needing to create an intermediate object.

**(C) Iterators**

| **Method**    | **Description**                        |     |
| ------------- | -------------------------------------- | --- |
| `mp.begin()`  | Iterator to first element.             |     |
| `mp.end()`    | Iterator past the last element.        |     |
| `mp.rbegin()` | Reverse iterator to last element.      |     |
| `mp.rend()`   | Reverse iterator before first element. |     |

**Complexity**

- Average time complexity for insertion, deletion, and search operations is O(log n), where n is the number of elements in the map.
- The worst-case time complexity is also O(log n) for balanced trees.

### **`map` vs `unordered_map`**

|Feature|`std::map` (Ordered)|`std::unordered_map` (Hash Table)|
|---|---|---|
|**Sorting**|Sorted (BST)|Unordered (Hashing)|
|**Insertion/Lookup**|O(log n)|O(1) avg, O(n) worst|
|**Memory Usage**|Higher (Tree)|Lower (Hash Table)|
|**Use Case**|Sorted data, range queries|Fast lookups|

🔹 **Use `map` when sorting is needed**  
🔹 **Use `unordered_map` when speed matters**

---

## unordered_map

### Overview

`unordered_map` is a container in the C++ Standard Library that stores key-value pairs with **fast average O(1) lookup, insertion, and deletion** times. Unlike `map`, which is implemented as a balanced binary search tree (O(log n) operations), `unordered_map` is implemented using a **hash table**, making it much faster for most use cases.

### Syntax

```cpp
#include <iostream>
#include <unordered_map>

int main() {
    std::unordered_map<std::string, int> age;
    
    // Inserting key-value pairs
    age["Alice"] = 25;
    age["Bob"] = 30;
    
    // Accessing values
    std::cout << "Alice's age: " << age["Alice"] << std::endl;
    
    return 0;
}
```

### Key Features

- **Unordered Storage:** The order of elements is not guaranteed.
- **Fast Lookups:** Average O(1) time complexity due to hashing.
- **Key Uniqueness:** Each key must be unique; inserting a duplicate key will overwrite the previous value.

### Important Methods

#### Insert Elements

```cpp
umap.insert({"Charlie", 22}); // Using pair
umap["David"] = 40;           // Direct insertion
```

#### Find and Access Elements

```cpp
if (umap.find("Alice") != umap.end()) {
    std::cout << "Alice exists with age " << umap["Alice"] << std::endl;
}
```

#### Iterate Over Elements

```cpp
for (const auto &pair : umap) {
    std::cout << pair.first << ": " << pair.second << std::endl;
}
```

#### Erase Elements

```cpp
umap.erase("Bob"); // Removes key "Bob"
```

#### Size and Empty Check

```cpp
std::cout << "Size: " << umap.size() << std::endl;
std::cout << "Is empty? " << (umap.empty() ? "Yes" : "No") << std::endl;
```

### Hash Function and Custom Keys

By default, `unordered_map` uses `std::hash<KeyType>`. For custom key types, a custom hash function must be defined.

---

## multimap

### Overview

`multimap` is a container in the C++ Standard Library that stores **key-value pairs where duplicate keys are allowed**. Unlike `map`, which ensures unique keys, `multimap` allows multiple elements to have the same key. It is implemented as a balanced binary search tree (typically a **Red-Black Tree**) and provides **logarithmic (O(log n))** time complexity for insertion, deletion, and lookup.

### Syntax

```cpp
#include <iostream>
#include <map>

int main() {
    std::multimap<std::string, int> grades;
    
    // Inserting elements
    grades.insert({"Alice", 90});
    grades.insert({"Bob", 85});
    grades.insert({"Alice", 95}); // Duplicate key allowed

    // Iterating over elements
    for (const auto &pair : grades) {
        std::cout << pair.first << ": " << pair.second << std::endl;
    }
    
    return 0;
}
```

### Key Features

- **Allows Duplicate Keys:** Multiple elements can have the same key.
- **Ordered Storage:** Elements are stored in **sorted order** based on keys.
- **Logarithmic Complexity:** Insertions, deletions, and lookups take **O(log n)** time.

### Important Methods

#### Insert Elements

```cpp
grades.insert({"Charlie", 78});
grades.insert({"Charlie", 82}); // Multiple entries for "Charlie"
```

#### Find and Access Elements

```cpp
auto range = grades.equal_range("Alice");
for (auto it = range.first; it != range.second; ++it) {
    std::cout << it->first << ": " << it->second << std::endl;
}
```
##### `std::multimap::equal_range` Method

The `equal_range` method in `std::multimap` is a useful function that allows you to retrieve all elements associated with a specific key. This method is particularly beneficial when you want to find all entries that match a given key in a multimap, which can contain multiple values for the same key.

- **Return Type**: The `equal_range` method returns a pair of iterators. The first iterator points to the first element that is not less than the specified key, while the second iterator points to the first element that is greater than the key. This effectively defines a range of elements that have the specified key.
- **Usage**: The method can be called as follows:

 ```cpp
std::pair<iterator, iterator> equal_range(const Key& key);
```
    
#### Iterate Over Elements

```cpp
for (const auto &pair : grades) {
    std::cout << pair.first << ": " << pair.second << std::endl;
}
```

#### Erase Elements

```cpp
grades.erase("Bob"); // Removes all entries with key "Bob"
```

#### Count Elements with a Key

```cpp
std::cout << "Alice has " << grades.count("Alice") << " grades recorded." << std::endl;
```

---

## unordered_multimap

### Overview

`unordered_multimap` is an **unordered associative container** that **allows multiple values for the same key**. It is implemented using a **hash table**, providing **O(1) average-time complexity** for **insertion, deletion, and search**, but **O(n) worst case** when hash collisions occur.

### Syntax

```cpp
#include <iostream>
#include <unordered_map>

int main() {
    std::unordered_multimap<std::string, int> umm;

    // Inserting key-value pairs
    umm.insert({"apple", 10});
    umm.insert({"banana", 5});
    umm.insert({"apple", 15});  // Duplicate key

    // Iterating over the unordered_multimap
    for (const auto& pair : umm) {
        std::cout << pair.first << " -> " << pair.second << "\n";
    }

    return 0;
}
```

**Output (order may vary due to hashing):**

```
apple -> 10  
banana -> 5  
apple -> 15  
```

### Key Features

- **Unordered storage** (keys are not stored in any specific order).
- **Allows duplicate keys** (unlike `unordered_map`).
- **Implemented using a hash table**, making operations **O(1) on average**.
- **Fast insertion, deletion, and lookup**, but **iteration order is unpredictable**.

### Important Methods

#### Inserting Elements

```cpp
std::unordered_multimap<std::string, int> umm;
umm.insert({"apple", 10});
umm.insert({"apple", 15});
umm.emplace("banana", 5);
```

#### Finding and Counting Elements

```cpp
auto it = umm.find("apple");  // Returns iterator to first occurrence of "apple"
if (it != umm.end()) {
    std::cout << "Found: " << it->first << " -> " << it->second << "\n";
}

int count = umm.count("apple");  // Number of times "apple" appears
std::cout << "Apple appears " << count << " times\n";
```

#### Accessing All Values for a Given Key

```cpp
auto range = umm.equal_range("apple");
for (auto it = range.first; it != range.second; ++it) {
    std::cout << it->first << " -> " << it->second << "\n";
}
```

#### Erasing Elements

```cpp
umm.erase("banana");  // Removes all pairs with key "banana"
```

### Comparison: `unordered_map` vs. `unordered_multimap`

| Feature              | `unordered_map` (Unique Keys) | `unordered_multimap` (Duplicates Allowed) |
| -------------------- | ----------------------------- | ----------------------------------------- |
| Ordering             | Unordered                     | Unordered                                 |
| Duplicates           | Not allowed                   | Allowed                                   |
| Insertion Complexity | `O(1)` on average             | `O(1)` on average                         |
| Search Complexity    | `O(1)` on average             | `O(1)` on average                         |
| Iteration            | Unordered                     | Unordered                                 |

---

## set

### Overview

`set` is an **ordered, unique** collection in C++. It **stores elements in a sorted order** and ensures that **no duplicate elements exist**. It is implemented as a **self-balancing binary search tree** (usually a Red-Black Tree), making **search, insertion, and deletion operations efficient** with `O(log n)` complexity.

### Syntax

```cpp
#include <iostream>
#include <set>

int main() {
    std::set<int> s = {5, 1, 3, 2, 4};

    // Inserting elements
    s.insert(6);
    s.insert(2);  // Duplicate, ignored

    // Iterating over elements (always sorted)
    for (int num : s) {
        std::cout << num << " ";
    }

    return 0;
}
```

**Output:**

```
1 2 3 4 5 6
```

### Key Features

- **Ordered & Unique:** Elements are stored in sorted order (ascending by default).
- **Efficient Search, Insert, and Delete:** `O(log n)` complexity due to the underlying Red-Black Tree.
- **No Direct Access via Index:** Elements must be accessed through iterators.

### Important Methods

#### Inserting and Erasing Elements

```cpp
std::set<int> s = {10, 20, 30};
s.insert(25);  // Inserts 25
s.erase(20);   // Removes 20
```

#### Checking Existence

```cpp
if (s.count(10)) {   // Returns 1 if element exists, 0 otherwise
    std::cout << "10 is in the set\n";
}
```

or using `find()`:

```cpp
if (s.find(10) != s.end()) {
    std::cout << "10 is in the set\n";
}
```

#### Iterating Over a Set

```cpp
for (int num : s) {
    std::cout << num << " ";
}
```

or using iterators:

```cpp
for (auto it = s.begin(); it != s.end(); ++it) {
    std::cout << *it << " ";
}
```

#### Finding Lower and Upper Bounds

```cpp
auto lb = s.lower_bound(25); // First element >= 25
auto ub = s.upper_bound(25); // First element > 25
```

---

## unordered_set

### Overview

`unordered_set` is an **unordered, unique** collection in C++. It **stores elements in no particular order** and ensures that **no duplicate elements exist**. It is implemented using a **hash table**, providing an **average complexity of O(1)** for **search, insertion, and deletion** (compared to `O(log n)` in `set`).

### Syntax

```cpp
#include <iostream>
#include <unordered_set>

int main() {
    std::unordered_set<int> us = {5, 1, 3, 2, 4};

    // Inserting elements
    us.insert(6);
    us.insert(2);  // Duplicate, ignored

    // Iterating over elements (unordered)
    for (int num : us) {
        std::cout << num << " ";
    }

    return 0;
}
```

**Possible Output:**

```
3 1 5 2 4 6
```

(Note: The order **may vary** due to hashing.)

### Key Features

- **Unordered & Unique:** Elements are stored in an arbitrary order.
- **Faster Search, Insert, and Delete (O(1) on average):** Uses a hash table for efficient lookups.
- **No Direct Access via Index:** Elements must be accessed using iterators.
- **Slower in Worst Case (O(n)):** If many elements collide in the same hash bucket, operations may degrade to `O(n)`.

### Important Methods

#### Inserting and Erasing Elements

```cpp
std::unordered_set<int> us = {10, 20, 30};
us.insert(25);  // Inserts 25
us.erase(20);   // Removes 20
```

#### Checking Existence

```cpp
if (us.count(10)) {  // Returns 1 if element exists, 0 otherwise
    std::cout << "10 is in the set\n";
}
```

or using `find()`:

```cpp
if (us.find(10) != us.end()) {
    std::cout << "10 is in the set\n";
}
```

#### Iterating Over an Unordered Set

```cpp
for (int num : us) {
    std::cout << num << " ";
}
```

or using iterators:

```cpp
for (auto it = us.begin(); it != us.end(); ++it) {
    std::cout << *it << " ";
}
```

### Comparison: `set` vs. `unordered_set`

| Feature              | `set` (Ordered)   | `unordered_set` (Unordered)           |
| -------------------- | ----------------- | ------------------------------------- |
| Ordering             | Sorted order      | No specific order                     |
| Insertion Complexity | `O(log n)` (Tree) | `O(1)` (Hash Table)                   |
| Search Complexity    | `O(log n)`        | `O(1)` (Average), `O(n)` (Worst Case) |
| Duplicate Elements   | Not allowed       | Not allowed                           |
|                      |                   |                                       |

---

## multiset

### Overview

`multiset` is an **ordered associative container** that allows **duplicate elements**. It stores elements in **sorted order**, like `set`, but **allows multiple occurrences** of the same value. It is implemented as a **self-balancing binary search tree (usually a Red-Black Tree)**, providing **O(log n) complexity** for **insertion, deletion, and search**.

### Syntax

```cpp
#include <iostream>
#include <set>

int main() {
    std::multiset<int> ms = {5, 1, 3, 2, 4, 3, 1};

    // Inserting elements
    ms.insert(6);
    ms.insert(3);  // Duplicate allowed

    // Iterating over elements (sorted)
    for (int num : ms) {
        std::cout << num << " ";
    }

    return 0;
}
```

**Output:**

```
1 1 2 3 3 3 4 5 6
```

### Key Features

- **Stores elements in sorted order** (ascending by default).
- **Allows duplicate values** (unlike `set`).
- **Implemented as a balanced BST**, making operations **O(log n)**.
- **No direct access via index**—use iterators.

### Important Methods

#### Inserting and Erasing Elements

```cpp
std::multiset<int> ms = {10, 20, 30};
ms.insert(20);  // Inserts another 20
ms.insert(25);  // Inserts 25

// Erase only one occurrence of 20
ms.erase(ms.find(20));

// Erase all occurrences of 10
ms.erase(10);
```

#### Counting Occurrences of an Element

```cpp
int count = ms.count(20);  // Returns number of times 20 appears
```

#### Finding Elements

```cpp
auto it = ms.find(20);  // Points to first occurrence of 20
if (it != ms.end()) {
    std::cout << "20 is in the multiset\n";
}
```

#### Iterating Over a multiset

```cpp
for (int num : ms) {
    std::cout << num << " ";
}
```

or using iterators:

```cpp
for (auto it = ms.begin(); it != ms.end(); ++it) {
    std::cout << *it << " ";
}
```

### Comparison: `set` vs. `multiset`

|Feature|`set` (Unique)|`multiset` (Duplicates Allowed)|
|---|---|---|
|Ordering|Sorted order|Sorted order|
|Duplicates|Not allowed|Allowed|
|Insertion Complexity|`O(log n)`|`O(log n)`|
|Search Complexity|`O(log n)`|`O(log n)`|
|Deletion Complexity|`O(log n)`|`O(log n)`|

---

## unordered_multiset

### Overview

`unordered_multiset` is an **unordered associative container** that **allows multiple occurrences of the same value**. It is implemented using a **hash table**, providing **O(1) average-time complexity** for **insertion, deletion, and search**, but **O(n) worst case** when hash collisions occur.

### Syntax

```cpp
#include <iostream>
#include <unordered_set>

int main() {
    std::unordered_multiset<int> ums;

    // Inserting elements
    ums.insert(10);
    ums.insert(20);
    ums.insert(10);  // Duplicate allowed
    ums.insert(30);

    // Iterating over the unordered_multiset
    for (int num : ums) {
        std::cout << num << " ";
    }
    std::cout << "\n";

    return 0;
}
```

**Output (order may vary due to hashing):**

```
10 20 10 30  
```

### Key Features

- **Unordered storage** (elements are not stored in any specific order).
- **Allows duplicate values** (unlike `unordered_set`).
- **Implemented using a hash table**, making operations **O(1) on average**.
- **Fast insertion, deletion, and lookup**, but **iteration order is unpredictable**.

### Important Methods

#### Inserting Elements

```cpp
std::unordered_multiset<int> ums;
ums.insert(10);
ums.insert(20);
ums.insert(10);  // Duplicate allowed
ums.emplace(30);
```

#### Finding and Counting Elements

```cpp
auto it = ums.find(10);  // Returns iterator to any occurrence of 10
if (it != ums.end()) {
    std::cout << "Found: " << *it << "\n";
}

int count = ums.count(10);  // Number of times 10 appears
std::cout << "10 appears " << count << " times\n";
```

#### Erasing Elements

```cpp
ums.erase(10);  // Removes all occurrences of 10
```

### Comparison: `unordered_set` vs. `unordered_multiset`

| Feature              | `unordered_set` (Unique Elements) | `unordered_multiset` (Duplicates Allowed) |
| -------------------- | --------------------------------- | ----------------------------------------- |
| Ordering             | Unordered                         | Unordered                                 |
| Duplicates           | Not allowed                       | Allowed                                   |
| Insertion Complexity | `O(1)` on average                 | `O(1)` on average                         |
| Search Complexity    | `O(1)` on average                 | `O(1)` on average                         |
| Iteration            | Unordered                         | Unordered                                 |

---

## stack

### Overview

A `stack` is a **container adapter** that follows the **LIFO (Last-In, First-Out) principle**. Elements are added and removed from the **top** only.

### Syntax

```cpp
#include <iostream>
#include <stack>

int main() {
    std::stack<int> s;

    // Pushing elements
    s.push(10);
    s.push(20);
    s.push(30);

    // Accessing top element
    std::cout << "Top: " << s.top() << "\n";  // 30

    // Popping elements
    s.pop();  // Removes 30
    std::cout << "Top after pop: " << s.top() << "\n";  // 20

    return 0;
}
```

**Output:**

```
Top: 30  
Top after pop: 20  
```

### Key Features

- **LIFO (Last-In, First-Out) order.**
- **Only allows access to the top element.**
- **Efficient push/pop operations (`O(1)`).**
- **Uses `deque` (default), `vector`, or `list` as the underlying container.**

### Important Methods

#### Pushing Elements

```cpp
s.push(42);  // Adds 42 to the top
```

#### Accessing the Top Element

```cpp
std::cout << s.top();  // Retrieves the top element without removing it
```

#### Popping Elements

```cpp
s.pop();  // Removes the top element
```

#### Checking Size

```cpp
std::cout << s.size();  // Returns number of elements in stack
```

#### Checking if Stack is Empty

```cpp
if (s.empty()) {
    std::cout << "Stack is empty\n";
}
```

### Custom Stack with `list` as Underlying Container

```cpp
std::stack<int, std::list<int>> s;
```

---

## queue

### Overview

A `queue` is a **FIFO (First-In, First-Out) container adapter** where elements are **added at the back** and **removed from the front**.

### Syntax

```cpp
#include <iostream>
#include <queue>

int main() {
    std::queue<int> q;

    // Enqueue elements
    q.push(10);
    q.push(20);
    q.push(30);

    // Front and back elements
    std::cout << "Front: " << q.front() << "\n";  // 10
    std::cout << "Back: " << q.back() << "\n";    // 30

    // Dequeue
    q.pop();  // Removes 10
    std::cout << "Front after pop: " << q.front() << "\n";  // 20

    return 0;
}
```

**Output:**

```
Front: 10  
Back: 30  
Front after pop: 20  
```

### Key Features

- **FIFO (First-In, First-Out) order.**
- **Efficient enqueue (`push`) and dequeue (`pop`) operations (`O(1)`).**
- **Only allows access to the front and back elements.**
- **Uses `deque` (default) or `list` as the underlying container.**

### Important Methods

#### Enqueue (Push to Back)

```cpp
q.push(42);  // Adds 42 to the back of the queue
```

#### Accessing Front and Back Elements

```cpp
std::cout << q.front();  // Retrieves the front element
std::cout << q.back();   // Retrieves the back element
```

#### Dequeue (Pop from Front)

```cpp
q.pop();  // Removes the front element
```

#### Checking Size

```cpp
std::cout << q.size();  // Returns number of elements in queue
```

#### Checking if Queue is Empty

```cpp
if (q.empty()) {
    std::cout << "Queue is empty\n";
}
```

### Custom Queue with `list` as Underlying Container

```cpp
std::queue<int, std::list<int>> q;
```

---

## priority_queue

### Overview

A `priority_queue` is a **heap-based container adapter** that **stores elements in sorted order** such that the largest (or smallest) element is always at the top.

By default, it is a **max-heap**, meaning the largest element has the highest priority.

### Syntax

```cpp
#include <iostream>
#include <queue>

int main() {
    std::priority_queue<int> pq;

    // Insert elements
    pq.push(10);
    pq.push(30);
    pq.push(20);

    // Retrieve the top element (highest priority)
    std::cout << "Top: " << pq.top() << "\n";  // 30

    // Remove the top element
    pq.pop();
    std::cout << "Top after pop: " << pq.top() << "\n";  // 20

    return 0;
}
```

**Output:**

```
Top: 30  
Top after pop: 20  
```

### Key Features

- **Uses a binary heap (by default, max-heap).**
- **Elements are sorted automatically on insertion.**
- **Retrieving (`top`) and removing (`pop`) the highest-priority element takes `O(log n)`.**
- **Efficient for scenarios requiring frequent access to the highest or lowest value.**

### Important Methods

#### Insert Element

```cpp
pq.push(42);  // Inserts 42 into the priority_queue
```

#### Retrieve the Highest Priority Element

```cpp
std::cout << pq.top();  // Returns the highest priority element
```

#### Remove the Highest Priority Element

```cpp
pq.pop();  // Removes the highest priority element
```

#### Check Size

```cpp
std::cout << pq.size();  // Returns the number of elements
```

#### Check if Empty

```cpp
if (pq.empty()) {
    std::cout << "Priority queue is empty\n";
}
```

### Min-Heap (Smallest Element First)

By default, `priority_queue` is a **max-heap** (largest element first). To create a **min-heap**, use `greater<T>`:

```cpp
std::priority_queue<int, std::vector<int>, std::greater<int>> minHeap;
```

**Example:**

```cpp
#include <iostream>
#include <queue>

int main() {
    std::priority_queue<int, std::vector<int>, std::greater<int>> minHeap;
    minHeap.push(10);
    minHeap.push(30);
    minHeap.push(20);

    std::cout << "Top: " << minHeap.top() << "\n";  // 10

    return 0;
}
```

**Output:**

```
Top: 10  
```

---

## **Algorithms**

C++ provides a powerful **Standard Library (`<algorithm>`)** that includes numerous algorithms designed to work seamlessly with **iterators**. These algorithms allow efficient manipulation and traversal of data structures like arrays, vectors, lists, and sets without directly handling raw loops.

---

### **Iterators and Their Role in Algorithms**

Iterators act as **generalized pointers** that allow traversal over elements of a container. They provide a **common interface** for algorithms to work across different data structures.

### **Types of Iterators**

1. **Input Iterator** → Reads data **once** (e.g., `istream_iterator`).
2. **Output Iterator** → Writes data **once** (e.g., `ostream_iterator`).
3. **Forward Iterator** → Traverses **forward only** (e.g., `std::forward_list`).
4. **Bidirectional Iterator** → Moves **forward and backward** (e.g., `std::list`).
5. **Random Access Iterator** → Supports **arithmetic operations** (e.g., `std::vector`).

---

### **Algorithms Using Iterators**

#### **Searching Algorithms**

Iterators allow search operations without manual loops.

✅ **`std::find`** → Finds the first occurrence of an element.

```cpp
#include <iostream>
#include <vector>
#include <algorithm>
using namespace std;

int main() {
    vector<int> vec = {10, 20, 30, 40, 50};
    auto it = find(vec.begin(), vec.end(), 30);
    
    if (it != vec.end()) cout << "Found at index: " << distance(vec.begin(), it);
    else cout << "Not found";
}
```

✅ **`std::find_if`** → Finds first element that satisfies a condition.

```cpp
#include <iostream>
#include <vector>
#include <algorithm>
using namespace std;

bool isEven(int num) { return num % 2 == 0; }

int main() {
    vector<int> vec = {3, 7, 2, 9, 6};
    auto it = find_if(vec.begin(), vec.end(), isEven);
    
    if (it != vec.end()) cout << "First even number: " << *it;
    else cout << "No even numbers";
}
```

---

#### **Sorting Algorithms**

Sorting algorithms efficiently rearrange elements in a range using iterators.

✅ **`std::sort`** → Sorts elements using **random access iterators** (like vectors).

```cpp
#include <iostream>
#include <vector>
#include <algorithm>
using namespace std;

int main() {
    vector<int> vec = {5, 2, 8, 1, 6};
    sort(vec.begin(), vec.end());  // Sort in ascending order

    for (int num : vec) cout << num << " ";
}
```

✅ **`std::stable_sort`** → Maintains **relative order** of equal elements.

```cpp
#include <iostream>
#include <vector>
#include <algorithm>
using namespace std;

struct Student {
    string name;
    int score;
};

bool compare(Student a, Student b) {
    return a.score < b.score;
}

int main() {
    vector<Student> students = {{"Alice", 90}, {"Bob", 85}, {"Eve", 85}};
    stable_sort(students.begin(), students.end(), compare);

    for (auto s : students) cout << s.name << " " << s.score << endl;
}
```

---

#### **Counting and Modifying Algorithms**

✅ **`std::count`** → Counts occurrences of a value.

```cpp
#include <iostream>
#include <vector>
#include <algorithm>
using namespace std;

int main() {
    vector<int> vec = {1, 2, 2, 3, 2, 4};
    cout << "Occurrences of 2: " << count(vec.begin(), vec.end(), 2);
}
```

✅ **`std::count_if`** → Counts elements that match a condition.

```cpp
#include <iostream>
#include <vector>
#include <algorithm>
using namespace std;

bool isOdd(int num) { return num % 2 != 0; }

int main() {
    vector<int> vec = {1, 2, 3, 4, 5};
    cout << "Odd numbers: " << count_if(vec.begin(), vec.end(), isOdd);
}
```

✅ **`std::replace`** → Replaces all occurrences of a value.

```cpp
#include <iostream>
#include <vector>
#include <algorithm>
using namespace std;

int main() {
    vector<int> vec = {1, 2, 3, 2, 4};
    replace(vec.begin(), vec.end(), 2, 99);

    for (int num : vec) cout << num << " ";
}
```

---

#### **Transformations and Accumulations**

✅ **`std::for_each`** → Applies a function to each element.

```cpp
#include <iostream>
#include <vector>
#include <algorithm>
using namespace std;

void print(int num) { cout << num * num << " "; }

int main() {
    vector<int> vec = {1, 2, 3, 4};
    for_each(vec.begin(), vec.end(), print);
}
```

✅ **`std::accumulate` (from `<numeric>`)** → Computes sum/product of elements.

```cpp
#include <iostream>
#include <vector>
#include <numeric>
using namespace std;

int main() {
    vector<int> vec = {1, 2, 3, 4};
    cout << "Sum: " << accumulate(vec.begin(), vec.end(), 0);
}
```

✅ **`std::transform`** → Applies a function to each element and stores the result.

```cpp
#include <iostream>
#include <vector>
#include <algorithm>
using namespace std;

int main() {
    vector<int> vec = {1, 2, 3, 4};
    vector<int> squared(vec.size());

    transform(vec.begin(), vec.end(), squared.begin(), [](int x) { return x * x; });

    for (int num : squared) cout << num << " ";
}
```

---

### **Key Points**

✅ **Iterators generalize algorithms**, making them applicable to different data structures.  
✅ **Searching algorithms** like `std::find` and `std::find_if` simplify element lookup.  
✅ **Sorting algorithms** like `std::sort` and `std::stable_sort` improve efficiency.  
✅ **Counting and modification algorithms** like `std::count` and `std::replace` provide flexible manipulation.  
✅ **Transformations and accumulations** like `std::transform` and `std::accumulate` help in functional-style programming.

---

## **Lambda Functions**

Lambda functions in C++ are **anonymous functions** that allow defining small, concise functions inline. They are useful for short operations that do not require a full function declaration. Introduced in **C++11**, lambdas have become an essential feature in **modern C++ programming**.

---

### **Syntax of a Lambda Function**

```cpp
[ capture_list ] ( parameters ) -> return_type { function_body };
```

- **`capture_list`** → Captures external variables (optional).
- **`parameters`** → Function parameters (like normal functions).
- **`return_type`** → (Optional) Return type of the lambda.
- **`function_body`** → The actual code of the lambda.

---

### **Basic Lambda Function**

✅ **Lambda that prints a message**

```cpp
#include <iostream>
using namespace std;

int main() {
    auto greet = []() { cout << "Hello, Lambda!" << endl; };
    greet();
}
```

✅ **Lambda that takes parameters and returns a value**

```cpp
#include <iostream>
using namespace std;

int main() {
    auto add = [](int a, int b) { return a + b; };
    cout << "Sum: " << add(5, 3);
}
```

---

### **Capturing Variables in Lambdas**

#### **1. Capture by Value (`[var]`)**

✅ **A snapshot of the variable’s value is taken (does not modify original variable).**

```cpp
#include <iostream>
using namespace std;

int main() {
    int x = 10;
    auto lambda = [x]() { cout << "Captured x: " << x << endl; };
    x = 20;  // Does not affect lambda
    lambda();
}
```

**Output:**

```
Captured x: 10
```

#### **2. Capture by Reference (`[&var]`)**

✅ **Modifies the original variable.**

```cpp
#include <iostream>
using namespace std;

int main() {
    int x = 10;
    auto lambda = [&x]() { x += 5; };
    lambda();
    cout << "Modified x: " << x << endl;
}
```

**Output:**

```
Modified x: 15
```

#### **3. Capture All Variables**

✅ **Capture everything by value (`[=]`) or by reference (`[&]`).**

```cpp
#include <iostream>
using namespace std;

int main() {
    int a = 5, b = 10;
    
    auto byValue = [=]() { cout << "a: " << a << ", b: " << b << endl; };
    auto byReference = [&]() { a *= 2; b *= 3; };

    byValue();
    byReference();
    cout << "Modified a: " << a << ", b: " << b << endl;
}
```

**Output:**

```
a: 5, b: 10
Modified a: 10, b: 30
```

---

### **Returning Values from a Lambda**

#### **1. Implicit Return Type**

✅ **C++ automatically deduces return type based on the expression.**

```cpp
auto multiply = [](int x, int y) { return x * y; };
```

#### **2. Explicit Return Type (`-> type`)**

✅ **Useful for complex return types.**

```cpp
auto divide = [](int a, int b) -> double { return (double)a / b; };
```

---

### **Using Lambdas with STL Algorithms**

#### **1. `std::sort` with a Lambda Comparator**

```cpp
#include <iostream>
#include <vector>
#include <algorithm>
using namespace std;

int main() {
    vector<int> nums = {4, 2, 8, 1, 5};

    sort(nums.begin(), nums.end(), [](int a, int b) { return a > b; });

    for (int num : nums) cout << num << " ";
}
```

**Output:**

```
8 5 4 2 1
```

#### **2. `std::for_each` to Apply a Function**

```cpp
#include <iostream>
#include <vector>
#include <algorithm>
using namespace std;

int main() {
    vector<int> nums = {1, 2, 3, 4, 5};

    for_each(nums.begin(), nums.end(), [](int &n) { n *= 2; });

    for (int num : nums) cout << num << " ";
}
```

**Output:**

```
2 4 6 8 10
```

#### **3. `std::count_if` with a Lambda Predicate**

```cpp
#include <iostream>
#include <vector>
#include <algorithm>
using namespace std;

int main() {
    vector<int> nums = {3, 6, 7, 10, 15, 18};

    int count = count_if(nums.begin(), nums.end(), [](int x) { return x % 3 == 0; });

    cout << "Count of multiples of 3: " << count;
}
```

**Output:**

```
Count of multiples of 3: 4
```

---

### **Key Points**

✅ **Lambdas allow inline, anonymous functions for quick operations.**  
✅ **Capturing variables lets lambdas use external scope.**  
✅ **STL algorithms benefit from lambdas for clean, efficient code.**  
✅ **Implicit and explicit return types offer flexibility.**  
✅ **Useful for functional programming and event-driven logic.**

---

## **Sorting, Searching, and Manipulating Collections**

C++ provides a rich set of functions for sorting, searching, and manipulating collections (containers like `vector`, `list`, `deque`, etc.) through the **Standard Template Library (STL)**. These operations improve performance and reduce the need for manual implementations.

---

### **Sorting Collections**

#### **Using `std::sort()` (Efficient QuickSort-based Algorithm)**

✅ **Sorts a range in ascending order (default)**

```cpp
#include <iostream>
#include <vector>
#include <algorithm> 
using namespace std;

int main() {
    vector<int> v = {5, 2, 9, 1, 5, 6};
    
    sort(v.begin(), v.end());  // Sorts in ascending order

    for (int x : v) cout << x << " ";
}
```

**Output:**

```
1 2 5 5 6 9
```

✅ **Sort in Descending Order**

```cpp
sort(v.begin(), v.end(), greater<int>());
```

✅ **Custom Comparator (Sort by Absolute Value)**

```cpp
sort(v.begin(), v.end(), [](int a, int b) { return abs(a) < abs(b); });
```

---

### **Searching in Collections**

#### **Using `std::binary_search()` (Fast Logarithmic Search)**

✅ **Check if an element exists (Requires Sorted Collection)**

```cpp
sort(v.begin(), v.end());
bool found = binary_search(v.begin(), v.end(), 5);
cout << (found ? "Found" : "Not Found");
```

#### **Using `std::find()` (Linear Search for Any Container)**

✅ **Find an Element in Any Collection**

```cpp
auto it = find(v.begin(), v.end(), 9);
if (it != v.end()) cout << "Element found at index " << distance(v.begin(), it);
```

#### **Using `std::lower_bound()` and `std::upper_bound()`**

✅ **Find First Occurrence of an Element (Sorted Collections Only)**

```cpp
auto it = lower_bound(v.begin(), v.end(), 5);  // First element >= 5
```

✅ **Find Next Greater Element After a Given Value**

```cpp
auto it = upper_bound(v.begin(), v.end(), 5);  // First element > 5
```

---

### **Manipulating Collections**

#### **Reversing a Collection**

✅ **Using `std::reverse()`**

```cpp
reverse(v.begin(), v.end());
```

#### **Rotating Elements**

✅ **Using `std::rotate()`**

```cpp
rotate(v.begin(), v.begin() + 2, v.end());  // Moves first 2 elements to the end
```

#### **Shuffling Elements (Randomizing Order)**

✅ **Using `std::shuffle()`**

```cpp
#include <random>
random_device rd;
mt19937 g(rd());
shuffle(v.begin(), v.end(), g);
```

#### **Removing Duplicates from Sorted Collection**

✅ **Using `std::unique()`**

```cpp
v.erase(unique(v.begin(), v.end()), v.end());
```

---

### **Key Points**

✅ **Use `std::sort()` for efficient sorting; it defaults to ascending order.**  
✅ **Use `std::binary_search()` for fast searches in sorted collections.**  
✅ **Use `std::find()` for searching in any container.**  
✅ **Use `std::reverse()`, `std::rotate()`, and `std::shuffle()` for collection manipulation.**  
✅ **Use `std::unique()` to remove consecutive duplicates efficiently.**

🚀 **These functions provide optimized performance, reducing the need for manual algorithms!**

---

## Structures (`struct`)

Structures in C++ are user-defined data types that allow you to group different variables together under a single name. They are used to represent records containing various types of data.

### Declaring a Structure:

```cpp
struct Person {
    std::string name;
    int age;
    float height;
};
```

- `struct` keyword is used to define a structure.
- `Person` is the structure tag or name.
- Inside the structure, you can declare variables of different data types.

### Creating Structure Variables:

```cpp
Person person1; // Declaration of a structure variable
```

### Accessing Structure Members:

```cpp
person1.name = "John";
person1.age = 25;
person1.height = 175.5;
```

- You can access structure members using the dot `.` operator.

### Initializing Structure Variables:

```cpp
Person person2 = {"Alice", 30, 160.0}; // Initializing structure variable during declaration
```

### Nested Structures:

```cpp
struct Address {
    std::string city;
    std::string country;
};

struct Person {
    std::string name;
    int age;
    Address address; // Nested structure
};

Person person;
person.name = "John Doe";
person.age = 30;
person.address.city = "Anytown";
person.address.country = "USA";
```

- Structures can contain other structures as members, allowing for complex data structures.

### Benefits of Structures:

- **Organization**: Group related data together for better organization and readability.
- **Abstraction**: Represent real-world entities or concepts in code.
- **Passing Data**: Pass structures to functions to encapsulate related data.

### Considerations:

- **Memory Allocation**: Each structure variable occupies memory based on the size of its members.
- **Access Control**: By default, structure members are public, but you can use access specifiers to control access.

***

## Array of Structures

Arrays of structures in C++ allow you to store multiple instances of a structure type in a contiguous block of memory. This is particularly useful when you need to work with collections of related data.

### Declaring a Structure:

```cpp
struct Person {
    std::string name;
    int age;
    float height;
};
```

### Declaring an Array of Structures:

```cpp
const int MAX_PERSONS = 100;
Person people[MAX_PERSONS]; // Array of structures
```

- This declares an array named `people` that can hold up to `MAX_PERSONS` instances of the `Person` structure.

### Initializing Array of Structures:

```cpp
Person people[MAX_PERSONS] = {
    {"John", 25, 175.5},
    {"Alice", 30, 160.0},
    // Add more instances as needed
};
```

### Accessing Elements in Array of Structures:

```cpp
people[0].name = "Bob";
people[0].age = 35;
people[0].height = 180.0;
```

- Access individual elements of the array using array indexing and set their values as needed.

### Iterating Through Array of Structures:

```cpp
for (int i = 0; i < MAX_PERSONS; ++i) {
    std::cout << "Person " << i + 1 << std::endl;
    std::cout << "Name: " << people[i].name << std::endl;
    std::cout << "Age: " << people[i].age << std::endl;
    std::cout << "Height: " << people[i].height << std::endl;
    std::cout << std::endl;
}
```

- Use a loop to iterate through the array and access each structure element.

### Dynamic Allocation of Array of Structures:

```cpp
Person* people = new Person[MAX_PERSONS];
```

- Dynamic allocation allows you to allocate memory for the array at runtime. Don't forget to deallocate memory using `delete[]` when done.

***

## Passing Structures to Functions

Passing structures to functions in C++ allows you to manipulate and operate on structure data within functions.

### Passing by Value:

```cpp
struct Person {
    std::string name;
    int age;
    float height;
};

void printPerson(Person person) {
    std::cout << "Name: " << person.name << std::endl;
    std::cout << "Age: " << person.age << std::endl;
    std::cout << "Height: " << person.height << std::endl;
}

int main() {
    Person p = {"John", 25, 175.5};
    printPerson(p);
    return 0;
}
```

- When passed by value, the function `printPerson` receives a copy of the structure. Changes made to the structure inside the function do not affect the original structure.

### Passing by Reference:

```cpp
void modifyPerson(Person& person) {
    person.age = 30;
    person.height = 180.0;
}

int main() {
    Person p = {"John", 25, 175.5};
    modifyPerson(p);
    printPerson(p); // Print modified person
    return 0;
}
```

- Passing by reference allows the function to directly modify the original structure. Changes made to the structure inside the function are reflected in the original structure.

### Passing by Pointer:

```cpp
void updatePerson(Person* personPtr) {
    personPtr->age = 30;
    personPtr->height = 180.0;
}

int main() {
    Person p = {"John", 25, 175.5};
    updatePerson(&p);
    printPerson(p); // Print updated person
    return 0;
}
```

- Passing a pointer to the structure allows the function to modify the original structure indirectly. Arrow (`->`) operator is used to access members through the pointer.

### Benefits:
- Passing structures to functions allows for modular and organized code.
- It enables functions to operate on data encapsulated within structures.
- Different methods of passing (by value, by reference, by pointer) offer flexibility based on requirements.

### Considerations:
- Passing by value creates a copy of the structure, which may have performance implications for large structures.
- Passing by reference and pointer allows direct modification of the original structure, so caution is needed to avoid unintended side effects.

---

## Bit-fields

Bit-fields in C++ allow you to control the number of bits used to represent each member of a structure. They are useful for compactly representing data where memory efficiency is critical. Here's how you can use bit-fields in C++:

### Define a Structure with Bit-Fields:

```cpp
struct Flags {
    unsigned int flag1 : 1; // 1 bit for flag1
    unsigned int flag2 : 1; // 1 bit for flag2
    unsigned int flag3 : 1; // 1 bit for flag3
    // Add more flags as needed
};
```

- In this example, each member `flag1`, `flag2`, `flag3`, etc., is assigned 1 bit, allowing for compact representation of boolean flags.

### Accessing and Setting Bit-Fields:

```cpp
Flags flags;
flags.flag1 = 1; // Set flag1 to true
flags.flag2 = 0; // Set flag2 to false
flags.flag3 = 1; // Set flag3 to true
```

- You can access and modify bit-fields just like regular structure members.

### Benefits of Bit-Fields:

- **Memory Efficiency**: Bit-fields allow you to conserve memory by using only the necessary number of bits to represent each member.

### Considerations:

- **Portability**: Bit-field behavior may vary between different compilers, especially concerning padding and alignment.
- **Limited Range**: The number of bits available for each member is limited by the underlying data type (`int`, `unsigned int`, etc.).
- **Complexity**: Bit-fields may introduce complexity, especially when dealing with non-standardized behavior across different compilers.


***
## Unions (`union`)

Unions in C++ allow you to define a data structure that can hold elements of different types in the same memory location. Unlike structures, where each member has its own memory space, all members of a union share the same memory location.

### Define a Union:

```cpp
union Data {
    int intValue;
    float floatValue;
    char stringValue[10];
};
```

- In this example, `Data` can hold either an integer, a floating-point number, or a string of characters, but not all simultaneously.
- All members of the union share the same memory location, and the size of the union is determined by the size of its largest member (`stringValue` in this case).

### Accessing Union Members:

```cpp
Data data;
data.intValue = 10; // Assign an integer value
std::cout << data.intValue << std::endl; // Access the integer value

data.floatValue = 3.14f; // Assign a floating-point value
std::cout << data.floatValue << std::endl; // Access the floating-point value

strcpy(data.stringValue, "Hello"); // Assign a string value
std::cout << data.stringValue << std::endl; // Access the string value
```

- When you assign a value to one member of the union, the contents of the other members become undefined. Only the last assigned member should be accessed.

### Use Cases for Unions:

1. **Memory Efficiency**: Unions can save memory by allowing different interpretations of the same memory location.
2. **Type Conversion**: Unions can be used for type conversion when the same memory needs to be interpreted in different ways.
3. **Interpretation of Binary Data**: Unions are useful when dealing with low-level binary data where the same memory needs to be interpreted differently based on context.

### Considerations:

- **Union Size**: The size of a union is determined by the size of its largest member.
- **Undefined Behavior**: Accessing non-active members of a union (those not most recently assigned) can lead to undefined behavior.
- **Type Safety**: Unions can lead to type safety issues if not used carefully, especially when interpreting data in different ways.

***

## Passing Unions To Functions

Passing unions to functions in C++ works similarly to passing structures or any other data type. Since unions can contain different types of data, it’s essential to handle them carefully, especially when dealing with the data they contain. Here’s a breakdown of how to pass unions to functions:

### 1. **Passing by Value**
   - When a union is passed by value, a copy of the union is made and passed to the function. Any changes made to the union inside the function do not affect the original union.
   - Example:

     ```cpp
     #include <iostream>

     union Data {
         int intValue;
         float floatValue;
     };

     void printUnionByValue(Data data) {
         std::cout << "Integer: " << data.intValue << std::endl;
     }

     int main() {
         Data myData;
         myData.intValue = 42;
         printUnionByValue(myData); // Passes a copy of myData
         return 0;
     }
     ```

### 2. **Passing by Pointer**
   - Passing a union by pointer allows the function to modify the original union. This method is useful if you want the function to update the union's contents.
   - Example:

     ```cpp
     #include <iostream>

     union Data {
         int intValue;
         float floatValue;
     };

     void setIntValue(Data* data, int value) {
         data->intValue = value; // Modifies the original union
     }

     int main() {
         Data myData;
         setIntValue(&myData, 100); // Passes a pointer to myData
         std::cout << "Integer: " << myData.intValue << std::endl;
         return 0;
     }
     ```

### 3. **Passing by Reference**
   - Passing a union by reference also allows the function to modify the original union. It's similar to passing by pointer but more convenient since you don’t need to use the arrow operator (`->`) to access members.
   - Example:

     ```cpp
     #include <iostream>

     union Data {
         int intValue;
         float floatValue;
     };

     void setFloatValue(Data& data, float value) {
         data.floatValue = value; // Modifies the original union
     }

     int main() {
         Data myData;
         setFloatValue(myData, 3.14f); // Passes a reference to myData
         std::cout << "Float: " << myData.floatValue << std::endl;
         return 0;
     }
     ```

**Key Points**:
- **Type Safety**: Unions are inherently type-unsafe because they can hold only one value at a time, and you need to ensure you're accessing the active member correctly.
- **Size Consideration**: When passing by value, be mindful that the entire union is copied, which could be inefficient if the union is large. Passing by reference or pointer avoids this overhead.
- **Member Access**: When using the union inside the function, you need to know which member is currently active to avoid accessing uninitialized or invalid data.

***

# Functions and Modular Programming

## **Pass by Value vs. Pass by Reference in C++**

When passing arguments to functions in C++, you can do so in two main ways: **Pass by Value** and **Pass by Reference**. Each method has different behaviors and use cases.

---

### **Pass by Value**

When a function is called with **pass by value**, a **copy** of the argument is created, and modifications inside the function do **not** affect the original variable.

**Example:**

```cpp
#include <iostream>
using namespace std;

void modifyValue(int x) {
    x = x * 2; // This change is local to the function
}

int main() {
    int num = 10;
    modifyValue(num);
    cout << "Value of num: " << num << endl; // Output: 10
    return 0;
}
```

**Key Points:**

- A **copy** of the argument is made.
- The original value remains **unchanged**.
- Useful for **small data types** or when you **don’t want** the function to modify the original variable.

---

### **Pass by Reference**

In **pass by reference**, the function receives a **reference** to the original variable, meaning changes inside the function will **affect** the original value.

**Example:**

```cpp
#include <iostream>
using namespace std;

void modifyValue(int &x) { // Reference parameter
    x = x * 2;
}

int main() {
    int num = 10;
    modifyValue(num);
    cout << "Value of num: " << num << endl; // Output: 20
    return 0;
}
```

**Key Points:**

- The function works with the **actual variable**, not a copy.
- Any **modifications inside** the function affect the **original variable**.
- Used when you **want** the function to modify the original variable.

---

### **Pass by Pointer (Similar to Pass by Reference)**

Another way to pass by reference is by using pointers.

**Example:**

```cpp
#include <iostream>
using namespace std;

void modifyValue(int *x) { // Pointer parameter
    *x = *x * 2;
}

int main() {
    int num = 10;
    modifyValue(&num);
    cout << "Value of num: " << num << endl; // Output: 20
    return 0;
}
```

**Key Points:**

- The function receives the **address** of the variable.
- The function modifies the **actual value** using the pointer.
- Useful for **dynamic memory allocation** and when dealing with arrays.

---

### **Comparison Table**

| Feature                   | Pass by Value | Pass by Reference | Pass by Pointer |
| ------------------------- | ------------- | ----------------- | --------------- |
| Copy of argument          | ✅ Yes         | ❌ No              | ❌ No            |
| Affects original variable | ❌ No          | ✅ Yes             | ✅ Yes           |
| Used for constants        | ✅ Yes         | ❌ No              | ❌ No            |
| Can pass NULL             | ❌ No          | ❌ No              | ✅ Yes           |
| Requires extra memory     | ✅ Yes         | ❌ No              | ❌ No            |

---

### **When to Use Which?**

✅ **Use Pass by Value** when:

- You **don’t want** to modify the original data.
- The variable is **small** (e.g., `int`, `char`, `float`).

✅ **Use Pass by Reference** when:

- You **want** to modify the original variable.
- You need better performance for **large data types** (e.g., `std::string`, `vector`).

✅ **Use Pass by Pointer** when:

- You need to **handle NULL values**.
- You’re working with **dynamic memory** or **arrays**.

## Passing Arrays to Functions

You can pass arrays to functions using different methods depending on whether you're working with raw arrays or vectors. Here's how you can pass arrays to functions:

### Passing Raw Arrays:

#### Method 1: Pass by Pointer

```cpp
void printArray(int* arr, int size) {
    for (int i = 0; i < size; ++i) {
        std::cout << arr[i] << " ";
    }
    std::cout << std::endl;
}

int main() {
    int arr[] = {1, 2, 3, 4, 5};
    int size = sizeof(arr) / sizeof(arr[0]);
    printArray(arr, size);
    return 0;
}
```

#### Method 2: Pass by Reference

```cpp
void printArray(int (&arr)[5]) { // Size must be specified
    for (int i = 0; i < 5; ++i) {
        std::cout << arr[i] << " ";
    }
    std::cout << std::endl;
}

int main() {
    int arr[] = {1, 2, 3, 4, 5};
    printArray(arr);
    return 0;
}
```

### Passing Vectors:

#### Method 1: Pass by Reference

```cpp
void printVector(const std::vector<int>& vec) {
    for (int num : vec) {
        std::cout << num << " ";
    }
    std::cout << std::endl;
}

int main() {
    std::vector<int> vec = {1, 2, 3, 4, 5};
    printVector(vec);
    return 0;
}
```

#### Method 2: Pass by Value (Copy)

```cpp
void modifyVector(std::vector<int> vec) {
    vec.push_back(6);
    for (int num : vec) {
        std::cout << num << " ";
    }
    std::cout << std::endl;
}

int main() {
    std::vector<int> vec = {1, 2, 3, 4, 5};
    modifyVector(vec);
    return 0;
}
```

### Considerations:

- When passing arrays, it's common to pass the size of the array as a separate parameter.
- When passing vectors by reference, use `const` to ensure that the function does not modify the vector.
- Passing by reference is generally more efficient than passing by value, especially for large containers.

---

## **Default Arguments**

Default arguments allow a function to be called with fewer parameters by providing default values.

**Syntax:**

```cpp
void greet(string name = "Guest") {
    cout << "Hello, " << name << "!" << endl;
}
```

**Example:**

```cpp
#include <iostream>
using namespace std;

void display(int a, int b = 10) { // Default value for b
    cout << "a: " << a << ", b: " << b << endl;
}

int main() {
    display(5);    // Output: a: 5, b: 10
    display(5, 20); // Output: a: 5, b: 20
    return 0;
}
```

**Key Points:**

- Default values are assigned **from right to left**.
- If a parameter has a default value, all parameters to its **right** must also have default values.
- Default arguments are **declared only in function prototypes**.

---

## Function Overloading

Function overloading in C++ is a feature that allows you to have multiple functions with the same name but different parameters within the same scope. The compiler differentiates these functions based on the number, type, and order of the parameters. This is particularly useful when you want to perform similar operations but with different types or numbers of arguments.

**Key Points of Function Overloading**:
1. **Same Name, Different Parameters:** All overloaded functions must have the same name, but they must differ in the parameter list (either in the number of parameters, their types, or both).
2. **Return Type:** The return type of the functions can be different, but it alone cannot be used to distinguish overloaded functions. The parameter list must be different.
3. **Compile-Time Polymorphism:** Function overloading is an example of compile-time polymorphism, meaning the decision about which function to call is made at compile time based on the arguments passed.

**Example of Function Overloading**:
```cpp
#include <iostream>
using namespace std;

// Function to add two integers
int add(int a, int b) {
    return a + b;
}

// Function to add three integers
int add(int a, int b, int c) {
    return a + b + c;
}

// Function to add two doubles
double add(double a, double b) {
    return a + b;
}

int main() {
    cout << "add(10, 20) = " << add(10, 20) << endl;           // Calls int add(int, int)
    cout << "add(10, 20, 30) = " << add(10, 20, 30) << endl;   // Calls int add(int, int, int)
    cout << "add(10.5, 20.5) = " << add(10.5, 20.5) << endl;   // Calls double add(double, double)
    return 0;
}
```

**Output**:
```
add(10, 20) = 30
add(10, 20, 30) = 60
add(10.5, 20.5) = 31
```

### How Function Overloading Works:
- **Matching Arguments:** When a function is called, the compiler looks for the function whose parameter list matches the arguments passed. If a match is found, that function is called.
- **Ambiguity:** If the compiler finds two or more functions that could match the call (e.g., due to implicit type conversions), it results in a compile-time error due to ambiguity.

### Overloading and Default Arguments:
When using function overloading, be cautious with default arguments. If two overloaded functions could potentially be called with the same set of arguments (considering default values), it might create ambiguity.

### Example of Potential Ambiguity:
```cpp
void func(int a, int b = 10) { /*...*/ }
void func(int a) { /*...*/ }
```
Calling `func(5);` in this scenario would be ambiguous, as it could match either of the overloaded functions.

### Benefits of Function Overloading:
- **Code Readability:** Makes the code easier to understand by using the same function name for similar operations.
- **Convenience:** Allows the programmer to define multiple functions that perform similar tasks but with different data types or parameters.

In summary, function overloading is a powerful tool in C++ that allows for more flexible and readable code by enabling functions with the same name to handle different types or numbers of arguments.

---

## Inline Functions

In C++, an `inline` function is a request to the compiler to replace the function call with the function's code at the call site, rather than performing a traditional function call. This can potentially improve performance by reducing the overhead associated with function calls.

### Characteristics of Inline Functions

1. **Definition and Declaration**

   **Declaration:**
   ```cpp
   inline int add(int a, int b);
   ```

   **Definition:**
   ```cpp
   inline int add(int a, int b) {
       return a + b;
   }
   ```

   The `inline` keyword is placed before the function definition, suggesting to the compiler that the function should be inlined where it is called.

2. **Benefits**

   - **Performance:** Eliminates the overhead of a function call, such as pushing arguments onto the stack and jumping to the function’s code. This can lead to faster execution, especially for small, frequently called functions.
   - **Optimization:** Can lead to further optimizations by the compiler, such as constant folding and propagation.

3. **Limitations and Considerations**

   - **Size Increase:** Inlining a function can increase the size of the binary (code bloat), as the function code is duplicated at each call site.
   - **Complex Functions:** The compiler might ignore the `inline` request for complex functions. Functions that contain loops, recursion, or large amounts of code are usually not inlined.
   - **Linkage:** Inline functions are usually defined in header files to ensure that the definition is available at each call site. They need to be visible to all translation units that call them.

4. **Usage**

   - **Small Functions:** Ideal for small functions, such as those that are simple getters or setters, or utility functions.
   - **Header Files:** Typically defined in header files to ensure that the compiler can inline the function wherever it is used.

   **Example:**
   ```cpp
   // utils.h
   inline int square(int x) {
       return x * x;
   }

   // main.cpp
   #include "utils.h"
   #include <iostream>

   int main() {
       std::cout << square(5) << std::endl; // Calls inline function
       return 0;
   }
   ```

5. **Compiler Discretion**

   - The `inline` keyword is a suggestion to the compiler, not a command. Modern compilers use sophisticated optimization techniques and may decide to inline or not inline a function based on their own criteria.

6. **Static Inline Functions**

   - **Definition:** Static inline functions are functions that are declared `inline` and `static`. They have internal linkage and are not visible outside the file in which they are defined.

   **Example:**
   ```cpp
   // file1.cpp
   static inline int add(int a, int b) {
       return a + b;
   }

   // file2.cpp
   static inline int multiply(int a, int b) {
       return a * b;
   }
   ```

   In this example, `add` and `multiply` are only visible within their respective files.

**Summary**

- **Inline Functions**: Suggested to the compiler for inlining at the call site to reduce function call overhead.
- **Benefits**: Improved performance for small functions by avoiding call overhead.
- **Limitations**: May lead to code bloat; compiler may ignore the `inline` request for complex functions.
- **Usage**: Suitable for small, frequently called functions, typically defined in header files.

---

## **Recursive Functions**

A **recursive function** is a function that **calls itself** to solve a problem. It **breaks down** a complex problem into smaller subproblems of the same type.

### **Structure of a Recursive Function**

1. **Base Case** – The condition that stops the recursion.
2. **Recursive Case** – The function calls itself with a smaller problem.

---

### **Example: Factorial of a Number**

Factorial (`n!`) is defined as:

$$
n! = n \times (n-1) \times (n-2) \times ... \times 1
$$

With the base case:

$$
0! = 1
$$

```cpp
#include <iostream>
using namespace std;

int factorial(int n) {
    if (n == 0) return 1;  // Base case
    return n * factorial(n - 1);  // Recursive case
}

int main() {
    cout << factorial(5);  // Output: 120
    return 0;
}
```

---

### **Example: Fibonacci Series**

The Fibonacci sequence is defined as:

$$
F(n) = F(n-1) + F(n-2)
$$

With base cases:

$$
F(0) = 0, \quad F(1) = 1
$$

```cpp
int fibonacci(int n) {
    if (n <= 1) return n;  // Base case
    return fibonacci(n - 1) + fibonacci(n - 2);  // Recursive case
}
```

---

### **Tail Recursion**

A recursive function is **tail-recursive** if the **last operation** is the recursive call.  
Example: Tail-recursive factorial (optimized):

```cpp
int factorialHelper(int n, int result) {
    if (n == 0) return result;  // Base case
    return factorialHelper(n - 1, n * result);  // Tail recursion
}

int factorial(int n) {
    return factorialHelper(n, 1);
}
```

**Benefits of Tail Recursion:**  
✅ Uses **less memory** (can be optimized into a loop).  
✅ **Avoids stack overflow** in deep recursion.

---

### **Recursion vs. Iteration**

|Feature|Recursion|Iteration|
|---|---|---|
|Function Calls|Yes|No|
|Space Complexity|High (stack usage)|Low|
|Performance|Slower (due to function calls)|Faster|
|Readability|More intuitive for divide-and-conquer problems|More efficient for simple loops|

---

### **When to Use Recursion?**

✅ Problems that can be broken into **smaller subproblems** (e.g., Trees, Graphs, Divide & Conquer).  
✅ **Mathematical computations** (Factorial, Fibonacci, Power, GCD).  
✅ **Backtracking problems** (Maze solving, N-Queens).

***

## Void Arguments

### 1. **Void Function Arguments**

When used in a function's parameter list, `void` indicates that the function does not take any parameters. This is often used for functions that don't require any input to perform their task.

**Example:**

```cpp
#include <iostream>

void greet() {
    std::cout << "Hello, world!" << std::endl;
}

int main() {
    greet(); // Calls the function that takes no arguments
    return 0;
}
```

In this example, `greet` is a function that does not take any arguments, and the `void` keyword is used to specify this.

### 2. **Void Pointers**

A `void` pointer (`void*`) is a special type of pointer that can point to any data type but does not have a specific type associated with it. This allows for flexible function arguments and can be used in scenarios where the type of data is not known at compile time.

**Example:**

```cpp
#include <iostream>

void printValue(void* ptr, char type) {
    if (type == 'i') {
        std::cout << *static_cast<int*>(ptr) << std::endl;
    } else if (type == 'f') {
        std::cout << *static_cast<float*>(ptr) << std::endl;
    }
}

int main() {
    int x = 10;
    float y = 5.5f;

    printValue(&x, 'i'); // Prints the integer value
    printValue(&y, 'f'); // Prints the float value

    return 0;
}
```

In this example:
- The `printValue` function uses a `void*` pointer to handle different data types.
- Inside the function, the `void*` pointer is cast to the appropriate type using `static_cast`.

### 3. **Void in Function Declarations (No Parameters)**

When declaring a function that takes no parameters, `void` is used to indicate that the function does not accept any arguments.

**Example:**

```cpp
#include <iostream>

void display(); // Function declaration

int main() {
    display(); // Function call
    return 0;
}

void display() {
    std::cout << "This function takes no arguments." << std::endl;
}
```

Here, `display` is declared with `void` to indicate that it does not take any parameters. This is a common way to explicitly specify that a function does not take arguments.

### 4. **Void in Template Functions**

In template functions, `void` can be used as a placeholder for type parameters when the function does not use the type parameter.

**Example:**

```cpp
#include <iostream>

template<typename T>
void print(const T& value) {
    std::cout << value << std::endl;
}

template<>
void print<void>(const void&) {
    std::cout << "Specialized print function for void." << std::endl;
}

int main() {
    print(10);       // Calls the generic template function
    print("Hello");  // Calls the generic template function
    print<void>(nullptr); // Calls the specialized template function
    return 0;
}
```

In this example:
- A generic `print` template function is defined for any type `T`.
- A specialization of `print` for `void` is provided.

**Summary**

- **Void as a Return Type**: Indicates a function does not return a value.
- **Void in Parameter Lists**: Used to specify functions that do not take any arguments.
- **Void Pointers (`void*`)**: Can point to any data type but require type casting to access the data.
- **Void in Templates**: Used in template specialization or when a type parameter is not required.

***

# Pointers and Memory Management

## Pointers

Pointer variables and operators allow for dynamic memory allocation, manipulation of memory addresses, and indirect access to variables. Here's an overview of pointer variables and common pointer operators:

### Declaring Pointer Variables:

```cpp
int* ptr; // Declares a pointer to an integer
char* charPtr; // Declares a pointer to a character
```

- Pointer variables store memory addresses of other variables.

### Initializing Pointers:

```cpp
int* ptr = nullptr; // Initializes pointer to null
int* ptr = &x; // Initializes pointer to the address of variable x
```

- It's a good practice to initialize pointers, especially when they are not immediately assigned valid addresses.

### Accessing Values via Pointers:

```cpp
int x = 10;
int* ptr = &x; // Pointer initialized to the address of x

std::cout << *ptr << std::endl; // Accesses the value of x through the pointer
```

- The `*` operator is used to dereference pointers and access the value stored at the memory address they point to.

### Pointer Arithmetic:

```cpp
int numbers[] = {1, 2, 3, 4, 5};
int* ptr = numbers; // Pointer to the beginning of the array

std::cout << *(ptr + 2) << std::endl; // Accesses the third element of the array
```

- Pointer arithmetic allows adding or subtracting integers from pointers to navigate through memory locations.

### Pointer Increment and Decrement:

```cpp
int* ptr = numbers; // Pointer to the beginning of the array

ptr++; // Moves the pointer to the next element in the array
```

- Incrementing a pointer moves it to the next memory location based on the size of the type it points to.

### Pointer Comparison:

```cpp
int* ptr1 = numbers;
int* ptr2 = &numbers[2];

if (ptr1 == ptr2) {
    // Pointers point to the same memory location
}
```

- Pointers can be compared for equality to check if they point to the same memory address.

### Null Pointer:

```cpp
int* ptr = nullptr; // Null pointer
```

- A null pointer does not point to any valid memory location. It's often used to indicate that a pointer does not currently point to anything.

### Pointer to Pointer:

```cpp
int x = 10;
int* ptr1 = &x;
int** ptr2 = &ptr1; // Pointer to a pointer

// Dereferencing pointer to pointer to access the value it points to
int value = **ptr2;
```

- Pointers can point to other pointers, allowing for multi-level indirection and dynamic memory management.

---

## References

In C++, a reference is an alias or alternative name for an existing variable. It provides a way to access and manipulate the same data as the original variable without creating a copy. Here's an overview of references in C++:

### Declaring References:

```cpp
int x = 10;
int& ref = x; // Reference to variable x
```

- The `&` symbol denotes that `ref` is a reference.
- References must be initialized when declared and cannot be reassigned to refer to another variable.

### Using References:

```cpp
int x = 10;
int& ref = x;

std::cout << ref << std::endl; // Prints the value of x through the reference

ref = 20; // Changes the value of x through the reference
std::cout << x << std::endl;   // Prints 20
```

- Modifying the reference also modifies the original variable.
- Any changes made to the reference are reflected in the original variable and vice versa.

### References as Function Parameters:

```cpp
void increment(int& num) {
    num++;
}

int main() {
    int x = 10;
    increment(x); // Passes x by reference
    std::cout << x << std::endl; // Prints 11
    return 0;
}
```

- Passing by reference allows functions to modify the original variables.
- Changes made to the parameter inside the function affect the original argument.

### Benefits of References:

- **Efficiency**: References avoid the overhead of copying large objects.
- **Convenience**: Provide a cleaner syntax for passing variables to functions.
- **Expressiveness**: Clearly indicate when a function can modify its arguments.

### Restrictions and Best Practices:

- **Initialization**: References must be initialized when declared and cannot be null.
- **Lifetime**: References must refer to valid objects throughout their lifetime.
- **Scope**: References are bound to the scope in which they are declared.

***

## References vs Pointers

### **1. Definition and Syntax**

- **References:**
  - A reference is an alias for another variable. Once a reference is initialized to a variable, it cannot be changed to refer to another variable.
  - **Syntax:**
    ```cpp
    int a = 10;
    int& ref = a;  // ref is a reference to a
    ```

- **Pointers:**
  - A pointer is a variable that stores the memory address of another variable. Pointers can be reassigned to point to different variables or `nullptr`.
  - **Syntax:**
    ```cpp
    int a = 10;
    int* ptr = &a;  // ptr is a pointer to a
    ```

### **2. Initialization**

- **References:**
  - A reference must be initialized when it is created. After initialization, it cannot be made to refer to a different variable.
  - **Example:**
    ```cpp
    int a = 10;
    int& ref = a;  // Must initialize a reference
    ```

- **Pointers:**
  - A pointer can be declared without initialization, and it can be reassigned to point to different variables at any time.
  - **Example:**
    ```cpp
    int a = 10;
    int* ptr;      // Uninitialized pointer (can be dangerous if used without initialization)
    ptr = &a;      // Pointer can be initialized later
    ```

### **3. Reassignment**

- **References:**
  - A reference cannot be reassigned after initialization. It always refers to the same variable.
  - **Example:**
    ```cpp
    int a = 10;
    int b = 20;
    int& ref = a;
    ref = b;  // This changes the value of a, not the reference. ref is still referring to a.
    ```

- **Pointers:**
  - A pointer can be reassigned to point to different variables during its lifetime.
  - **Example:**
    ```cpp
    int a = 10;
    int b = 20;
    int* ptr = &a;
    ptr = &b;  // Now ptr points to b
    ```

### **4. Dereferencing**

- **References:**
  - A reference is automatically dereferenced when you use it. There’s no need for an explicit dereference operator.
  - **Example:**
    ```cpp
    int a = 10;
    int& ref = a;
    ref = 20;  // Changes the value of a to 20
    ```

- **Pointers:**
  - To access the value that a pointer points to, you need to explicitly dereference the pointer using the `*` operator.
  - **Example:**
    ```cpp
    int a = 10;
    int* ptr = &a;
    *ptr = 20;  // Changes the value of a to 20
    ```

### **5. Null References vs. Null Pointers**

- **References:**
  - There is no concept of a "null reference" in C++. A reference must always refer to a valid object or variable. You cannot have a reference that refers to nothing.
  - **Example:** The following is illegal:
    ```cpp
    int& ref = nullptr;  // Error: cannot bind a non-const reference to nullptr
    ```

- **Pointers:**
  - Pointers can be null, meaning they point to nothing. This is useful for indicating that a pointer isn’t currently pointing to a valid object.
  - **Example:**
    ```cpp
    int* ptr = nullptr;  // ptr does not point to any valid memory
    ```

### **6. Memory Management**

- **References:**
  - References do not require explicit memory management. They do not occupy additional memory beyond what the variable they reference uses.
  - **Example:** No special handling needed for references.

- **Pointers:**
  - Pointers can point to dynamically allocated memory, which requires explicit management (allocation and deallocation).
  - **Example:**
    ```cpp
    int* ptr = new int(10);  // Dynamically allocate memory
    delete ptr;              // Deallocate memory to avoid memory leaks
    ```

### **7. Use Cases**

- **References:**
  - Use references when you want to pass variables to functions without copying them.
  - Ideal for function parameters and return values when you do not need to indicate that the object might not exist (i.e., no need for nullability).
  - **Example:**
    ```cpp
    void increment(int& x) {
        x++;  // Modifies the original variable
    }
    ```

- **Pointers:**
  - Use pointers when you need to manage dynamic memory, point to different objects, or indicate that a variable might not be assigned (null pointer).
  - Useful in data structures like linked lists, trees, and other dynamic structures where elements are linked using pointers.
  - **Example:**
    ```cpp
    void allocateMemory(int*& ptr) {
        ptr = new int(10);  // Allocates memory and modifies the pointer itself
    }
    ```

***

## Constant Pointers

In C++, a **constant pointer** (also known as a **pointer to a constant**) is a pointer that points to a constant value, meaning the value being pointed to cannot be modified through this pointer. However, the pointer itself can be changed to point to different addresses.

### Constant Pointer vs. Pointer to Constant

1. **Pointer to Constant (`const Type*`)**:
   - **Definition**: The data being pointed to is constant, meaning you cannot modify the data through this pointer.
   - **Syntax**: `const Type* ptr`
   - **Example**:
     ```cpp
     const int x = 10;
     const int* ptr = &x;
     // *ptr = 20; // Error: cannot modify the value pointed to by ptr
     ```
   - Here, `ptr` can point to different `const int` variables, but you cannot change the value of `x` through `ptr`.

2. **Constant Pointer (`Type* const`)**:
   - **Definition**: The pointer itself is constant, meaning you cannot change the address stored in the pointer after initialization, but you can modify the data at that address.
   - **Syntax**: `Type* const ptr`
   - **Example**:
     ```cpp
     int y = 20;
     int* const ptr = &y;
     *ptr = 30; // Allowed: modifying the value pointed to by ptr
     // ptr = &x; // Error: cannot change the address stored in ptr
     ```
   - Here, `ptr` will always point to the same `int` variable, but you can change the value of `y` through `ptr`.

3. **Constant Pointer to Constant (`const Type* const`)**:
   - **Definition**: Both the pointer and the data it points to are constant. You cannot modify the data through the pointer, and you cannot change the pointer to point to a different address.
   - **Syntax**: `const Type* const ptr`
   - **Example**:
     ```cpp
     const int z = 40;
     const int* const ptr = &z;
     // *ptr = 50; // Error: cannot modify the value pointed to by ptr
     // ptr = &x; // Error: cannot change the address stored in ptr
     ```
   - Here, `ptr` is fixed to always point to `z`, and `z` cannot be modified through `ptr`.

**Summary of Usage**

- **`const Type* ptr`**: Points to a `const` value (data cannot be modified through `ptr`).
- **`Type* const ptr`**: A `const` pointer (address stored in `ptr` cannot be changed).
- **`const Type* const ptr`**: Both the data and the pointer are `const` (neither the data nor the address can be changed).

### Practical Use Cases

- **Function Parameters**: When you want to ensure that a function does not modify the argument, you can use a `const` pointer to guarantee this:
  ```cpp
  void printValue(const int* ptr) {
      std::cout << *ptr << std::endl;
  }
  ```
- **Immutable Data Structures**: For data structures or objects that should not be modified, you use `const` pointers to prevent modification through pointers.

### Example Code

```cpp
#include <iostream>

void printValue(const int* ptr) {
    std::cout << "Value: " << *ptr << std::endl;
}

int main() {
    int a = 10;
    const int b = 20;
    const int* p1 = &a;  // Pointer to a non-const int
    const int* p2 = &b;  // Pointer to a const int
    
    // p1 can point to another int, but can't modify a
    *p1 = 15; // Allowed: modifying the value of a through p1
    
    // p2 cannot modify b, and cannot change to point to a non-const int
    // *p2 = 25; // Error: cannot modify the value of b through p2

    printValue(p1); // Output: Value: 15
    printValue(p2); // Output: Value: 20
    
    return 0;
}
```

In this example:
- `p1` can point to `a` and can modify `a` (because `a` is not `const`).
- `p2` cannot modify `b` and cannot point to a non-`const` integer.

***

## Array to Pointer Conversion

Converting an array to a pointer in C++ is quite straightforward because the name of an array is a pointer to its first element.

### Array to Pointer Conversion:

```cpp
int arr[] = {1, 2, 3, 4, 5};

// `arr` is already a pointer to the first element of the array
int* ptr = arr;
```

In this example, `arr` is the name of the array, and it automatically decays into a pointer to its first element when assigned to `ptr`.

### Using Pointers with Arrays:

You can use pointers to access elements of the array:

```cpp
int arr[] = {1, 2, 3, 4, 5};
int* ptr = arr; // Points to the first element of the array

for (int i = 0; i < 5; ++i) {
    std::cout << *(ptr + i) << " "; // Accesses each element using pointer arithmetic
}
```

Here, `ptr` points to the first element of the array, and you can use pointer arithmetic to access other elements.

### Array Elements using Pointer Syntax:

You can also use array syntax with pointers:

```cpp
int arr[] = {1, 2, 3, 4, 5};
int* ptr = arr; // Points to the first element of the array

for (int i = 0; i < 5; ++i) {
    std::cout << ptr[i] << " "; // Accesses each element using array syntax
}
```

In this case, `ptr[i]` is equivalent to `*(ptr + i)`.

### Benefits of Pointer Usage:

- **Efficiency**: Pointers offer efficient memory access and manipulation, especially for large arrays.
- **Flexibility**: Pointers allow dynamic memory allocation and deallocation.
- **Compatibility**: Many library functions and data structures in C++ rely on pointers for efficiency and flexibility.

***

## Cautions with Pointer Usage
### 1. Dangling Pointers:
   - **Issue**: Dangling pointers occur when a pointer points to memory that has been deallocated or no longer valid.
   - **Consequence**: Accessing data through dangling pointers can lead to undefined behavior, crashes, or security vulnerabilities.
   - **Prevention**: Set pointers to `nullptr` after memory deallocation and avoid accessing deallocated memory.

### 2. Memory Leaks:
   - **Issue**: Memory leaks occur when dynamically allocated memory is not properly deallocated.
   - **Consequence**: Over time, memory leaks can exhaust system resources, leading to performance degradation or application failure.
   - **Prevention**: Always match each `new` with a corresponding `delete` or use smart pointers for automatic memory management.

### 3. Undefined Behavior:
   - **Issue**: Improper use of pointers can result in undefined behavior, where the program's behavior is unpredictable.
   - **Consequence**: Undefined behavior can lead to program crashes, data corruption, or security vulnerabilities.
   - **Prevention**: Follow best practices for pointer usage, such as proper initialization, bounds checking, and avoiding pointer arithmetic unless necessary.

### 4. Memory Corruption:
   - **Issue**: Writing beyond the bounds of allocated memory or using uninitialized pointers can corrupt memory.
   - **Consequence**: Memory corruption can lead to program instability, crashes, or security vulnerabilities.
   - **Prevention**: Ensure proper bounds checking and initialization of pointers, and use tools like address sanitizers for detecting memory errors.

### 5. Ownership and Lifetime:
   - **Issue**: It's often unclear who owns and is responsible for managing dynamically allocated memory.
   - **Consequence**: Ownership ambiguity can lead to resource leaks, double frees, or access violations.
   - **Prevention**: Establish clear ownership and lifetime rules for dynamically allocated memory, and use smart pointers or RAII (Resource Acquisition Is Initialization) to manage ownership automatically.

### 6. Performance Overhead:
   - **Issue**: Using pointers for every data access can introduce performance overhead due to indirection and cache misses.
   - **Consequence**: Excessive use of pointers can degrade performance, especially in performance-critical applications.
   - **Prevention**: Minimize pointer usage where possible and prefer stack-based variables for short-lived objects.

### 7. Complex Debugging:
   - **Issue**: Pointer-related bugs can be challenging to debug, especially in large codebases or complex data structures.
   - **Consequence**: Debugging pointer-related issues can be time-consuming and require advanced debugging techniques.
   - **Prevention**: Use defensive programming practices, proper error handling, and code reviews to catch pointer-related issues early.


***
## Passing Pointers to Functions

Passing pointers to functions in C++ allows you to manipulate data within functions and enables functions to modify variables outside their scope.

### Passing Pointers as Function Parameters:

#### Pass by Value:

```cpp
void increment(int* numPtr) {
    (*numPtr)++; // Increment the value at the memory address pointed by numPtr
}

int main() {
    int x = 10;
    increment(&x); // Pass the address of x to the function
    std::cout << x << std::endl; // Prints 11
    return 0;
}
```

- In this example, `increment` takes a pointer to an integer as a parameter and increments the value at that memory address.

#### Pass by Reference:

```cpp
void increment(int& numRef) {
    numRef++; // Increment the value directly
}

int main() {
    int x = 10;
    increment(x); // Pass x by reference
    std::cout << x << std::endl; // Prints 11
    return 0;
}
```

- You can also pass pointers by reference to avoid explicit dereferencing within the function.

### Benefits of Passing Pointers to Functions:

- **Modifying Variables**: Functions can modify variables outside their scope by accessing their memory addresses.
- **Efficiency**: Passing pointers is more memory-efficient than passing large objects by value.
- **Dynamic Memory Allocation**: Pointers are commonly used to pass memory addresses allocated dynamically.

### Precautions and Best Practices:

- **Null Pointers**: Check for null pointers to avoid dereferencing null pointers, which can lead to undefined behavior.
- **Pointer Lifetime**: Ensure that the pointer being passed remains valid throughout the function call's lifetime.
- **Pointer Ownership**: Clarify ownership and responsibility for memory management when passing pointers to functions.

***

## Dynamic Allocation

Dynamic allocation in C++ allows you to allocate memory during program execution, enabling flexible memory management for objects whose size or lifetime cannot be determined at compile time. The two primary mechanisms for dynamic allocation are `new` and `delete`.

### Dynamic Memory Allocation with `new`:

```cpp
int* ptr = new int; // Allocates memory for a single integer
```

- The `new` operator dynamically allocates memory for an object of the specified type and returns a pointer to the allocated memory.

```cpp
int* arr = new int[5]; // Allocates memory for an array of 5 integers
```

- For arrays, `new` allocates memory for a contiguous block of elements and returns a pointer to the first element.

### Initializing Dynamic Memory:

```cpp
*ptr = 10; // Initializes the dynamically allocated integer
```

- After allocation, you can initialize the dynamically allocated memory by dereferencing the pointer and assigning a value.

```cpp
for (int i = 0; i < 5; ++i) {
    arr[i] = i + 1; // Initializes each element of the dynamically allocated array
}
```

- For arrays, you can initialize individual elements using array syntax.

### Dynamic Memory Deallocation with `delete`:

```cpp
delete ptr; // Deallocates memory for the single integer
```

- The `delete` operator releases the dynamically allocated memory, preventing memory leaks.

```cpp
delete[] arr; // Deallocates memory for the array of integers
```

- For arrays allocated with `new[]`, use `delete[]` to release the memory properly.

### Benefits of Dynamic Allocation:

- **Flexibility**: Dynamic allocation allows for variable-sized data structures and objects with dynamic lifetimes.
- **Efficiency**: Memory is allocated only when needed, optimizing memory usage.
- **Dynamic Data Structures**: Enables the creation of dynamic data structures like linked lists, trees, and dynamic arrays.

### Precautions and Best Practices:

- **Memory Management**: Ensure that dynamically allocated memory is deallocated to prevent memory leaks.

***

# Exception Handling

## **try, catch, throw**

Exception handling in C++ is done using `try`, `catch`, and `throw` statements. It allows a program to handle **runtime errors** (exceptions) gracefully instead of crashing.

---

### **Syntax of Exception Handling**

```cpp
try {
    // Code that may cause an exception
    throw exception_value;  // Throw an exception
} 
catch (exception_type variable) {
    // Handle the exception
}
```

---

### **Example: Division by Zero**

```cpp
#include <iostream>
using namespace std;

void divide(int a, int b) {
    if (b == 0) {
        throw "Division by zero error";  // Throw an exception
    }
    cout << "Result: " << a / b << endl;
}

int main() {
    try {
        divide(10, 0);  // This will cause an exception
    }
    catch (const char* msg) {  // Catch the thrown exception
        cout << "Exception: " << msg << endl;
    }
    return 0;
}
```

**Output:**

```
Exception: Division by zero error
```

---

### **Multiple Catch Blocks**

Different exception types can be caught separately.

```cpp
try {
    throw 10;
} 
catch (int e) {
    cout << "Integer exception: " << e << endl;
}
catch (double e) {
    cout << "Double exception: " << e << endl;
}
```

If an exception of type `int` is thrown, the first `catch` block executes.

---

### **Catching All Exceptions (`...`)**

The **ellipsis (`...`)** can catch any type of exception.

```cpp
try {
    throw 3.14;  
} 
catch (...) {  
    cout << "Exception caught!" << endl;
}
```

---

### **Custom Exception Class**

Exceptions can be handled using custom exception classes.

```cpp
class MyException : public exception {
public:
    const char* what() const throw() {
        return "Custom Exception Occurred!";
    }
};

int main() {
    try {
        throw MyException();
    } 
    catch (const exception& e) {
        cout << e.what() << endl;
    }
}
```

**Output:**

```
Custom Exception Occurred!
```

---

**Key Points**

✅ `throw` is used to **raise** an exception.  
✅ `try` **wraps** code that may cause an exception.  
✅ `catch` **handles** exceptions based on type.  
✅ Catch-all (`...`) is used to handle **unknown** exceptions.  
✅ Custom exceptions provide **detailed error handling**.

---

## **Standard Exceptions**

C++ provides several **standard exceptions** in the `<exception>` header. These exceptions are derived from the **`std::exception`** class and are used to handle common runtime errors.

---

### **Hierarchy of Standard Exceptions**

All standard exceptions are derived from `std::exception`:

```
std::exception
│── std::logic_error
│   ├── std::domain_error
│   ├── std::invalid_argument
│   ├── std::length_error
│   ├── std::out_of_range
│── std::runtime_error
│   ├── std::overflow_error
│   ├── std::underflow_error
│   ├── std::range_error
│   ├── std::system_error
│── std::bad_alloc
│── std::bad_cast
│── std::bad_typeid
│── std::bad_exception
```

---

## **std::logic_error and Its Derived Classes**

`std::logic_error` is a **compile-time detectable** exception type in C++. It is used for **errors caused by incorrect program logic**, meaning they should be fixed in code rather than handled dynamically at runtime.

---

### **1. `std::domain_error`**

Thrown when a function receives an **input that is outside its valid domain**.

**Example: Square Root of a Negative Number**

```cpp
#include <iostream>
#include <cmath>
#include <stdexcept>
using namespace std;

double safeSqrt(double x) {
    if (x < 0) throw domain_error("Negative number in sqrt()");
    return sqrt(x);
}

int main() {
    try {
        cout << safeSqrt(-4);
    }
    catch (const domain_error& e) {
        cout << "Exception: " << e.what() << endl;
    }
}
```

**Output:**

```
Exception: Negative number in sqrt()
```

---

### **2. `std::invalid_argument`**

Thrown when a function receives an **invalid argument** that does not meet its expected format.

**Example: Converting a Non-Numeric String to Integer**

```cpp
#include <iostream>
#include <stdexcept>
using namespace std;

int toInteger(const string& str) {
    if (str.empty() || !isdigit(str[0])) throw invalid_argument("Invalid number format");
    return stoi(str);
}

int main() {
    try {
        cout << toInteger("abc123");  // Invalid input
    }
    catch (const invalid_argument& e) {
        cout << "Exception: " << e.what() << endl;
    }
}
```

**Output:**

```
Exception: Invalid number format
```

---

### **3. `std::length_error`**

Thrown when an **operation exceeds the maximum allowable size** of a container or string.

**Example: Exceeding String Maximum Length**

```cpp
#include <iostream>
#include <stdexcept>
#include <string>
using namespace std;

int main() {
    try {
        string s;
        s.reserve(s.max_size() + 1);  // Too large
    }
    catch (const length_error& e) {
        cout << "Exception: " << e.what() << endl;
    }
}
}
```

**Output:**

```
Exception: basic_string::reserve
```

---

### **4. `std::out_of_range`**

Thrown when trying to **access an element beyond valid bounds** (e.g., using `.at()` on a vector or string).

**Example: Accessing an Invalid Index**

```cpp
#include <iostream>
#include <vector>
#include <stdexcept>
using namespace std;

int main() {
    try {
        vector<int> nums = {1, 2, 3};
        cout << nums.at(5);  // Out of range
    }
    catch (const out_of_range& e) {
        cout << "Exception: " << e.what() << endl;
    }
}
```

**Output:**

```
Exception: vector::_M_range_check: __n (which is 5) >= this->size() (which is 3)
```

---

**Key Points**

✅ **`std::domain_error`** → Used for mathematically **invalid inputs**.  
✅ **`std::invalid_argument`** → Used when **bad arguments** are passed to a function.  
✅ **`std::length_error`** → Used when **containers exceed their size limits**.  
✅ **`std::out_of_range`** → Used when **accessing elements beyond valid indices**.

---


## **std::runtime_error and Its Derived Classes**

`std::runtime_error` is a **runtime-detectable** exception type in C++. It is used for **errors that cannot be determined at compile-time** and typically arise due to system or computational issues.

### **`std::overflow_error`**

Thrown when a **mathematical overflow** occurs during computations.

**Example: Integer Overflow in Multiplication**

```cpp
#include <iostream>
#include <limits>
#include <stdexcept>
using namespace std;

int safeMultiply(int a, int b) {
    if (a > 0 && b > 0 && a > numeric_limits<int>::max() / b)
        throw overflow_error("Multiplication overflow");
    return a * b;
}

int main() {
    try {
        cout << safeMultiply(1'000'000, 3'000'000);
    }
    catch (const overflow_error& e) {
        cout << "Exception: " << e.what() << endl;
    }
}
```

**Output:**

```
Exception: Multiplication overflow
```

---

### **`std::underflow_error`**

Thrown when a **mathematical underflow** occurs (typically in floating-point operations).

**Example: Underflow in Floating-Point Division**

```cpp
#include <iostream>
#include <limits>
#include <stdexcept>
using namespace std;

double safeDivide(double a, double b) {
    if (b == 0) throw underflow_error("Division underflow");
    return a / b;
}

int main() {
    try {
        cout << safeDivide(1.0, numeric_limits<double>::max());
    }
    catch (const underflow_error& e) {
        cout << "Exception: " << e.what() << endl;
    }
}
```

**Output:**

```
Exception: Division underflow
```

---

### **`std::range_error`**

Thrown when a **calculated result is outside the valid range** but not necessarily causing an overflow.

**Example: Logarithm of a Negative Number**

```cpp
#include <iostream>
#include <cmath>
#include <stdexcept>
using namespace std;

double safeLog(double x) {
    if (x < 0) throw range_error("Logarithm of a negative number");
    return log(x);
}

int main() {
    try {
        cout << safeLog(-5);
    }
    catch (const range_error& e) {
        cout << "Exception: " << e.what() << endl;
    }
}
```

**Output:**

```
Exception: Logarithm of a negative number
```

---

### **`std::system_error`**

Thrown for **system-related errors** such as file operations or thread issues.

**Example: Opening a Non-Existent File**

```cpp
#include <iostream>
#include <fstream>
#include <system_error>
using namespace std;

int main() {
    try {
        ifstream file("nonexistent.txt");
        if (!file) throw system_error(error_code(), "File could not be opened");
    }
    catch (const system_error& e) {
        cout << "Exception: " << e.what() << endl;
    }
}
```

**Output:**

```
Exception: File could not be opened
```

---

**Key Points**  
✅ **`std::overflow_error`** → Used when **values exceed the maximum allowable limit**.  
✅ **`std::underflow_error`** → Used when **values become too small to be represented accurately**.  
✅ **`std::range_error`** → Used for **results that are out of an expected range**.  
✅ **`std::system_error`** → Used for **system-related issues (files, threads, etc.)**.

---

## **Other Standard Exceptions in C++**

C++ provides additional standard exceptions that handle **memory allocation, type casting, type identification, and unexpected exceptions**.

### **`std::bad_alloc`**

Thrown when **memory allocation fails** using `new`.

**Example: Failing to Allocate a Huge Memory Block**

```cpp
#include <iostream>
#include <new>  // std::bad_alloc
using namespace std;

int main() {
    try {
        int* arr = new int[1'000'000'000'000];  // Too large
    }
    catch (const bad_alloc& e) {
        cout << "Exception: " << e.what() << endl;
    }
}
```

**Output:**

```
Exception: std::bad_alloc
```

---

### **`std::bad_cast`**

Thrown when **dynamic casting fails** with `dynamic_cast<>` on polymorphic types.

**Example: Invalid Downcasting with `dynamic_cast`**

```cpp
#include <iostream>
#include <typeinfo>
using namespace std;

class Base { virtual void dummy() {} };
class Derived : public Base {};

int main() {
    try {
        Base* b = new Base();
        Derived* d = dynamic_cast<Derived*>(b);  // Invalid cast
        if (!d) throw bad_cast();
    }
    catch (const bad_cast& e) {
        cout << "Exception: " << e.what() << endl;
    }
}
```

**Output:**

```
Exception: std::bad_cast
```

---

### **`std::bad_typeid`**

Thrown when trying to **get the type of a null pointer** to a polymorphic base class.

**Example: Calling `typeid` on a Null Pointer**

```cpp
#include <iostream>
#include <typeinfo>
using namespace std;

class Base { virtual void dummy() {} };

int main() {
    try {
        Base* b = nullptr;
        cout << typeid(*b).name();  // Causes bad_typeid
    }
    catch (const bad_typeid& e) {
        cout << "Exception: " << e.what() << endl;
    }
}
```

**Output:**

```
Exception: std::bad_typeid
```

---

### **`std::bad_exception`**

Used to handle **unexpected exceptions** in `throw()` (deprecated in C++11, but still recognized).

**Example: Catching Unexpected Exceptions**

```cpp
#include <iostream>
#include <exception>
using namespace std;

void unexpectedHandler() {
    cout << "Unexpected exception caught!" << endl;
    throw;  // Rethrow
}

int main() {
    set_unexpected(unexpectedHandler);
    
    try {
        throw 42;  // Not declared in throw specifier
    }
    catch (const bad_exception& e) {
        cout << "Exception: " << e.what() << endl;
    }
}
```

**Output:**

```
Unexpected exception caught!
Exception: std::bad_exception
```

---

**Key Points**  
✅ **`std::bad_alloc`** → Used when **memory allocation fails**.  
✅ **`std::bad_cast`** → Used when **dynamic casting fails**.  
✅ **`std::bad_typeid`** → Used when **`typeid` is called on a null pointer**.  
✅ **`std::bad_exception`** → Used for **unexpected exceptions (legacy feature)**.

---

## **Custom Exception Handling**

C++ allows defining **custom exceptions** by creating user-defined exception classes. This provides **more descriptive error handling** and allows programmers to define **specific error scenarios** for their applications.

---

### **Creating a Custom Exception Class**

A custom exception class should:  
✔️ Inherit from `std::exception` (or any standard exception).  
✔️ Override the `what()` method to provide an error message.

**Example: Custom Division by Zero Exception**

```cpp
#include <iostream>
#include <exception>
using namespace std;

class DivisionByZeroException : public exception {
public:
    const char* what() const noexcept override {
        return "Error: Division by zero is not allowed!";
    }
};

double safeDivide(double a, double b) {
    if (b == 0) throw DivisionByZeroException();
    return a / b;
}

int main() {
    try {
        cout << safeDivide(10, 0);
    }
    catch (const DivisionByZeroException& e) {
        cout << "Exception: " << e.what() << endl;
    }
}
```

**Output:**

```
Exception: Error: Division by zero is not allowed!
```

---

### **Custom Exception with Additional Data**

Custom exceptions can store additional details like error codes.

**Example: Custom Exception with Error Code**

```cpp
#include <iostream>
#include <exception>
using namespace std;

class CustomException : public exception {
private:
    string message;
    int errorCode;
public:
    CustomException(string msg, int code) : message(move(msg)), errorCode(code) {}

    const char* what() const noexcept override {
        return message.c_str();
    }

    int getCode() const { return errorCode; }
};

int main() {
    try {
        throw CustomException("File not found", 404);
    }
    catch (const CustomException& e) {
        cout << "Exception: " << e.what() << " (Error Code: " << e.getCode() << ")" << endl;
    }
}
```

**Output:**

```
Exception: File not found (Error Code: 404)
```

---

### **Throwing and Catching Custom Exceptions**

✔️ Use `throw` to raise exceptions.  
✔️ Use `try-catch` to handle them.

**Example: Multiple Custom Exceptions**

```cpp
#include <iostream>
#include <exception>
using namespace std;

class InvalidInputException : public exception {
public:
    const char* what() const noexcept override {
        return "Invalid input detected!";
    }
};

class OutOfRangeException : public exception {
public:
    const char* what() const noexcept override {
        return "Value is out of range!";
    }
};

void checkValue(int value) {
    if (value < 0) throw InvalidInputException();
    if (value > 100) throw OutOfRangeException();
    cout << "Valid value: " << value << endl;
}

int main() {
    try {
        checkValue(-5);
    }
    catch (const InvalidInputException& e) {
        cout << "Exception: " << e.what() << endl;
    }
    catch (const OutOfRangeException& e) {
        cout << "Exception: " << e.what() << endl;
    }
}
```

**Output:**

```
Exception: Invalid input detected!
```

---

### **Key Points**

✅ Custom exceptions **extend `std::exception`** for consistency.  
✅ Override `what()` to provide **meaningful error messages**.  
✅ Store **additional information** (e.g., error codes, messages).  
✅ **Use multiple catch blocks** for handling different exceptions.

---

# File Handling

## Streams

Streams are sequences of characters that can be read from or written to. They abstract the source or destination of data, allowing you to perform input and output operations in a unified way.

**Standard Streams:**
  - **cin (Standard Input):** Used for reading input from the user.
  - **cout (Standard Output):** Used for writing output to the console.
  - **cerr (Standard Error):** Used for writing error messages to the console.

**Stream Manipulators:** These are special operators and functions used to control the behavior of streams, such as formatting output, setting precision, etc.

---

## **File Input and Output Streams (fstream, ifstream, ofstream)**

C++ provides **file handling** through the `<fstream>` library, which allows reading from and writing to files using **streams**.

### **Types of File Streams**

✔️ `ifstream` (input file stream) → **Reads from files**.  
✔️ `ofstream` (output file stream) → **Writes to files**.  
✔️ `fstream` (file stream) → **Reads and writes to files**.

---

### **Writing to a File (`ofstream`)**

Use `ofstream` to create and write to a file.

**Example: Writing Data to a File**

```cpp
#include <iostream>
#include <fstream>
using namespace std;

int main() {
    ofstream file("example.txt");  // Open file for writing
    if (!file) {
        cout << "Error opening file!" << endl;
        return 1;
    }
    
    file << "Hello, C++ File I/O!\n";  // Write to file
    file << "This is a second line.\n";

    file.close();  // Close file
    cout << "Data written successfully." << endl;
}
```

**Creates `example.txt` with:**

```
Hello, C++ File I/O!
This is a second line.
```

---

### **Reading from a File (`ifstream`)**

Use `ifstream` to read data from a file.

**Example: Reading a File Line by Line**

```cpp
#include <iostream>
#include <fstream>
using namespace std;

int main() {
    ifstream file("example.txt");  // Open file for reading
    if (!file) {
        cout << "Error opening file!" << endl;
        return 1;
    }

    string line;
    while (getline(file, line)) {  // Read line by line
        cout << line << endl;
    }

    file.close();  // Close file
}
```

**Output (if `example.txt` exists):**

```
Hello, C++ File I/O!
This is a second line.
```

---

### **Reading and Writing (`fstream`)**

Use `fstream` for both **reading and writing**.

**Example: Appending Text to a File**

```cpp
#include <iostream>
#include <fstream>
using namespace std;

int main() {
    fstream file("example.txt", ios::in | ios::out | ios::app);  // Open for read & append
    if (!file) {
        cout << "Error opening file!" << endl;
        return 1;
    }

    file << "Appending new data.\n";  // Append new text
    file.seekg(0);  // Move to beginning to read

    string line;
    cout << "Updated file contents:\n";
    while (getline(file, line)) {
        cout << line << endl;
    }

    file.close();  // Close file
}
```

**Updated `example.txt`:**

```
Hello, C++ File I/O!
This is a second line.
Appending new data.
```

---

### **File Open Modes (`ios::` Flags)**

You can control file operations using **modes**:  
✔️ `ios::in` → Open for reading.  
✔️ `ios::out` → Open for writing (overwrites existing content).  
✔️ `ios::app` → Append to file without overwriting.  
✔️ `ios::trunc` → Truncate (delete existing content).  
✔️ `ios::binary` → Open file in binary mode.

**Example: Writing Without Overwriting**

```cpp
ofstream file("data.txt", ios::app);  // Append mode
```

---

### **Checking File Status**

Use `.fail()` or `.is_open()` to check if a file opened successfully.

**Example: Checking if a File Exists Before Opening**

```cpp
ifstream file("missing.txt");
if (!file.is_open()) {
    cout << "File does not exist!" << endl;
}
```

---

### **Key Points**

✅ **`ofstream` writes**, **`ifstream` reads**, **`fstream` does both**.  
✅ Always **close files** after use with `.close()`.  
✅ Use **`ios::app`** to prevent overwriting files.  
✅ Use **`.fail()` or `.is_open()`** to check if a file exists.

***

## File Operations

File streams, opening modes, file operations, and error handling are essential aspects of file manipulation in C++. Here's a breakdown of each:

### File Streams:

- **File Streams:** In C++, file streams are represented by `ifstream`, `ofstream`, and `fstream` classes, which allow reading from and writing to files.
- **Header Files:** Include `<fstream>` to use file streams in your program.

### Opening Modes:

- **File Opening Modes:** When opening a file, you specify the mode, which determines the file's behavior.
  - **`std::ios::in`**: Open for reading.
  - **`std::ios::out`**: Open for writing.
  - **`std::ios::app`**: Append mode.
  - **`std::ios::ate`**: Set the initial position at the end of the file.
  - **`std::ios::binary`**: Open in binary mode.

### File Operations:

- **Opening Files:** Use the `open()` method to open a file stream and associate it with a file.
- **Closing Files:** Always close files after use using the `close()` method.
- **Reading from Files:** Use `>>` or `getline()` to read data from files.
- **Writing to Files:** Use `<<` to write data to files.

#### `getline()`

- **Usage**: Reads a line from an input stream until it encounters a newline character (`'\n'`) or a specified delimiter.
- **Syntax**: `std::getline(input_stream, string_variable, delimiter);`
- **Example**: Reading user input: `std::getline(std::cin, line);`
- **Delimiter**: Optional parameter specifying the character at which to stop reading.

`getline()` is handy for reading lines of text from input streams, such as standard input (`std::cin`) or files.

### Error Handling:

- **Error Checking:** Always check for errors after performing file operations to handle exceptions gracefully.
- **Use `is_open()`:** Check if a file is successfully opened before performing read or write operations.
- **Handle Errors:** Handle errors appropriately, such as by displaying error messages or taking corrective actions.

### Example:

```cpp
#include <iostream>
#include <fstream>

int main() {
    std::ofstream outfile("example.txt", std::ios::out | std::ios::app);
    if (outfile.is_open()) {
        outfile << "Hello, world!" << std::endl;
        outfile.close();
    } else {
        std::cerr << "Error opening file!" << std::endl;
        return 1;
    }

    std::ifstream infile("example.txt", std::ios::in);
    if (infile.is_open()) {
        std::string line;
        while (getline(infile, line)) {
            std::cout << line << std::endl;
        }
        infile.close();
    } else {
        std::cerr << "Error opening file!" << std::endl;
        return 1;
    }

    return 0;
}
```
### Best Practices:

- **Check for Errors:** Always check for errors after file operations to handle exceptions gracefully.
- **Close Files Properly:** Ensure that files are properly closed after use to prevent resource leaks.
- **Use Descriptive Error Messages:** Provide meaningful error messages to aid in troubleshooting.

***

### Bitwise OR Operator (`|`)

The **bitwise OR operator** (`|`) in C++ performs a bitwise comparison between two integer values, comparing each bit in the two operands. The result is a new integer where each bit is set to `1` if at least one of the corresponding bits in the operands is `1`, otherwise, the bit is set to `0`.


**Example**:

Let's say you have two 8-bit integers:

```cpp
int a = 12;  // In binary: 00001100
int b = 25;  // In binary: 00011001
```

When you perform the bitwise OR operation:

```cpp
int result = a | b;  // Result in binary: 00011101
```


**Key Points**:
- **Combining Flags/Options**: The bitwise OR operator is commonly used to combine flags or options, as seen in file I/O operations, where multiple settings can be combined into a single value.
- **Setting Bits**: It can be used to set specific bits in a number without altering the others.

**Example: Combining Flags**
```cpp
int flag1 = 0x01;  // 00000001 in binary
int flag2 = 0x02;  // 00000010 in binary
int combined = flag1 | flag2;  // 00000011 in binary
```

Here, `combined` would have both `flag1` and `flag2` set, which is often used in scenarios where multiple options or states are represented by individual bits.

**Practical Use Case: Permissions**
Consider file permissions, where different bits might represent read, write, and execute permissions:

```cpp
const int READ = 0x01;   // 0001
const int WRITE = 0x02;  // 0010
const int EXECUTE = 0x04; // 0100

int permissions = READ | WRITE;  // 0011
```

This `permissions` value now indicates that both read and write permissions are enabled.

**Practical Use Case: Modes**

When you see it used in the context of file streams, like in the `std::ofstream` constructor, it is used to combine multiple file mode flags. These flags determine how the file should be opened or accessed.

**Example Usage**

```cpp
std::ofstream outfile("example.txt", std::ios::out | std::ios::app);
```

**The Bitwise OR Operator (`|`):**

- The `|` operator combines these two flags so that both behaviors (`std::ios::out` and `std::ios::app`) are enabled when the file is opened.
- In other words, `std::ios::out | std::ios::app` opens the file for writing **and** ensures that any data written is appended to the end of the file, rather than overwriting existing content.

**Why Use `|`?**

Using the bitwise OR operator in this context allows you to specify multiple behaviors for file handling. The flags themselves are implemented as bit masks, so combining them with `|` results in a single value that contains all the specified modes.

***
## Random Access File I/O

Random access file I/O refers to the ability to read from or write to a file at any position, rather than sequentially from the beginning to the end. It allows you to navigate within the file and perform operations at specific locations, offering flexibility and efficiency in data manipulation. Here's how random access file I/O works in C++:

### Reading from a File Randomly:

1. **Open the File**: Use an input file stream (`std::ifstream`) and open the file in binary mode (`std::ios::binary`) to enable random access.
2. **Seek to a Position**: Use the `seekg()` method to move the file pointer to the desired position in the file.
3. **Read Data**: Use file input operations like `read()` to read data from the file at the current position.
4. **Process Data**: Process the data read from the file as needed.
5. **Close the File**: Close the file stream using the `close()` method to release system resources.

### Example (Reading from a File Randomly):

```cpp
#include <iostream>
#include <fstream>

int main() {
    std::ifstream infile("data.bin", std::ios::binary); // Open file for reading in binary mode
    if (!infile.is_open()) {
        std::cerr << "Error opening file!" << std::endl;
        return 1;
    }

    // Move file pointer to the 10th byte from the beginning
    infile.seekg(10, std::ios::beg);

    char buffer[100];
    infile.read(buffer, 100); // Read 100 bytes from the current position
    // Process the data read from the file

    infile.close(); // Close the file
    return 0;
}
```

`std::ios::beg` is a flag used in C++ file I/O operations to specify the beginning of a file as the reference point for seeking. It is part of the `std::ios` namespace, which contains various flags and constants related to file input and output.
### Writing to a File Randomly:

1. **Open/Create the File**: Use an output file stream (`std::ofstream`) and open/create the file in binary mode (`std::ios::binary`).
2. **Seek to a Position**: Use the `seekp()` method to move the file pointer to the desired position in the file.
3. **Write Data**: Use file output operations like `write()` to write data to the file at the current position.
4. **Close the File**: Close the file stream using the `close()` method to release system resources.

### Example (Writing to a File Randomly):

```cpp
#include <iostream>
#include <fstream>

int main() {
    std::ofstream outfile("output.bin", std::ios::binary); // Open file for writing in binary mode
    if (!outfile.is_open()) {
        std::cerr << "Error opening file!" << std::endl;
        return 1;
    }

    // Move file pointer to the 20th byte from the beginning
    outfile.seekp(20, std::ios::beg);

    char buffer[] = "Hello, world!";
    outfile.write(buffer, sizeof(buffer)); // Write data to the file at the current position

    outfile.close(); // Close the file
    return 0;
}
```

### Best Practices:
- Ensure proper error handling for file operations to handle exceptions gracefully.
- Use binary mode (`std::ios::binary`) for random access file I/O to prevent character conversion issues.
- Be mindful of the file pointer's position when performing random access operations.

---

## **Working with Binary Files**

Binary files store data in **raw binary format**, making them **faster and more efficient** than text files. C++ provides **`fstream`**, **`ifstream`**, and **`ofstream`** for handling binary files using **`ios::binary`** mode.

---

### **Writing to a Binary File**

Use `ofstream` with `ios::binary` to write raw data.

**Example: Writing a Structure to a Binary File**

```cpp
#include <iostream>
#include <fstream>
using namespace std;

struct Employee {
    char name[50];
    int age;
    double salary;
};

int main() {
    Employee emp = {"John Doe", 30, 55000.75};

    ofstream file("employee.dat", ios::binary);
    if (!file) {
        cout << "Error opening file!" << endl;
        return 1;
    }

    file.write(reinterpret_cast<char*>(&emp), sizeof(emp));  // Write binary data
    file.close();

    cout << "Data written to binary file." << endl;
}
```

**Creates `employee.dat` containing binary data.**

---

### **Reading from a Binary File**

Use `ifstream` with `ios::binary` to read raw data.

**Example: Reading a Binary File**

```cpp
#include <iostream>
#include <fstream>
using namespace std;

struct Employee {
    char name[50];
    int age;
    double salary;
};

int main() {
    Employee emp;

    ifstream file("employee.dat", ios::binary);
    if (!file) {
        cout << "Error opening file!" << endl;
        return 1;
    }

    file.read(reinterpret_cast<char*>(&emp), sizeof(emp));  // Read binary data
    file.close();

    cout << "Name: " << emp.name << "\nAge: " << emp.age << "\nSalary: " << emp.salary << endl;
}
```

**Output:**

```
Name: John Doe
Age: 30
Salary: 55000.75
```

---

### **Appending Data to a Binary File**

Use `ios::app | ios::binary` to add new data **without overwriting**.

**Example: Appending Another Employee Record**

```cpp
#include <iostream>
#include <fstream>
using namespace std;

struct Employee {
    char name[50];
    int age;
    double salary;
};

int main() {
    Employee emp = {"Jane Smith", 28, 62000.50};

    ofstream file("employee.dat", ios::app | ios::binary);  // Append mode
    if (!file) {
        cout << "Error opening file!" << endl;
        return 1;
    }

    file.write(reinterpret_cast<char*>(&emp), sizeof(emp));
    file.close();

    cout << "Data appended to binary file." << endl;
}
```

---

### **Reading Multiple Records from a Binary File**

Since binary files store **raw memory data**, we must read multiple records in a loop.

**Example: Reading All Employees from a Binary File**

```cpp
#include <iostream>
#include <fstream>
using namespace std;

struct Employee {
    char name[50];
    int age;
    double salary;
};

int main() {
    Employee emp;

    ifstream file("employee.dat", ios::binary);
    if (!file) {
        cout << "Error opening file!" << endl;
        return 1;
    }

    while (file.read(reinterpret_cast<char*>(&emp), sizeof(emp))) {  // Read each record
        cout << "Name: " << emp.name << "\nAge: " << emp.age << "\nSalary: " << emp.salary << endl;
        cout << "-----------------------------" << endl;
    }

    file.close();
}
```

---

### **Random Access in Binary Files**

✔️ **Seek to a specific position** using `.seekg()` (for reading) or `.seekp()` (for writing).  
✔️ **Tell the current position** using `.tellg()` (for reading) or `.tellp()` (for writing).

**Example: Modifying a Specific Record in a Binary File**

```cpp
#include <iostream>
#include <fstream>
using namespace std;

struct Employee {
    char name[50];
    int age;
    double salary;
};

int main() {
    fstream file("employee.dat", ios::in | ios::out | ios::binary);
    if (!file) {
        cout << "Error opening file!" << endl;
        return 1;
    }

    int recordNum = 1;  // Modify the second record (0-based index)
    Employee emp = {"Alice Brown", 35, 75000.00};

    file.seekp(recordNum * sizeof(Employee), ios::beg);  // Move to specific record
    file.write(reinterpret_cast<char*>(&emp), sizeof(emp));

    file.close();
    cout << "Record updated successfully." << endl;
}
```

---

### **Key Points**

✅ **Binary files store raw data** → Faster and more efficient.  
✅ Use `ios::binary` mode with `ifstream`, `ofstream`, or `fstream`.  
✅ `write()` and `read()` handle binary data.  
✅ `seekg()`, `seekp()` for **random access**.  
✅ Suitable for **structured data storage** like records, game saves, and serialized objects. 🚀

***

# Object-Oriented Programming
## Classes and objects

### Classes:

- **Definition**: A class is a blueprint or template for creating objects. It defines the attributes (data) and behaviors (methods) that all objects of that class will have.
- **Purpose**: Classes provide a way to model real-world entities and encapsulate their properties and behaviors into a single entity.
- **Syntax**:
  ```cpp
  class ClassName {
  private:
      // Private members
  public:
      // Public members
  };
  ```
- **Example**:
  ```cpp
  class Car {
  private:
      std::string brand;
      int year;
  public:
      void setBrand(std::string b);
      void setYear(int y);
  };
  ```

### Objects:

- **Definition**: An object is an instance of a class. It represents a specific entity with its own state (attributes) and behavior (methods).
- **Purpose**: Objects allow us to create and manipulate instances of classes, providing a way to interact with the data and behaviors defined in the class.
- **Syntax**:
  ```cpp
  ClassName objectName;
  ```
- **Example**:
  ```cpp
  Car myCar; // Creating an object of class Car
  ```

**Key Points**:

- **Attributes**: Also known as data members or fields, attributes represent the state of an object.
- **Methods**: Also known as member functions, methods define the behavior of an object and allow it to perform actions and manipulate its state.

**Example**:

```cpp
#include <iostream>
#include <string>

class Car {
private:
    std::string brand;
    int year;
public:
    void setBrand(std::string b) {
        brand = b;
    }
    void setYear(int y) {
        year = y;
    }
    void displayInfo() {
        std::cout << "Brand: " << brand << ", Year: " << year << std::endl;
    }
};

int main() {
    Car myCar; // Creating an object of class Car
    myCar.setBrand("Toyota");
    myCar.setYear(2022);
    myCar.displayInfo();
    return 0;
}
```

In this example, `Car` is a class that represents a car entity. We create an object `myCar` of the `Car` class and use its methods to set and display information about the car.

### Direct Initialization

- **Syntax**:
    - The syntax for direct initialization looks like this:
```cpp
ClassName objectName(); // This is a declaration, not an instantiation
ClassName objectName;    // This is default initialization
ClassName objectName();   // This is direct initialization
```
        
- **Default Constructor**:
    - If you use empty parentheses, such as `ClassName objectName();`, it calls the default constructor of the class. However, be cautious, as this can sometimes lead to confusion due to the "Most Vexing Parse," where the compiler interprets this as a function declaration instead of an object instantiation.
- **Function Declaration vs. Object Instantiation**:
    - It's important to note that `ClassName objectName();` is interpreted as a function declaration that returns an object of type `ClassName` and takes no parameters, rather than creating an instance of the class. To avoid this ambiguity, you can use the following syntax:
```cpp
ClassName objectName; // This creates an instance of ClassName
```

***

## **Access Specifiers (public, private, protected)**

Access specifiers in **C++** determine the **visibility** and **accessibility** of class members (variables and functions). The three main access specifiers are:

1. **`public`** – Accessible **everywhere**.
2. **`private`** – Accessible **only inside the same class**.
3. **`protected`** – Accessible **inside the class** and **derived classes**.

---

### **1. `public` Access Specifier**

- Members declared as `public` can be accessed **from anywhere** (inside or outside the class).
- Used when you want data/functions to be **openly accessible**.

**Example:**

```cpp
#include <iostream>
using namespace std;

class Car {
public:
    string brand;
    
    void showBrand() {
        cout << "Car brand: " << brand << endl;
    }
};

int main() {
    Car myCar;
    myCar.brand = "Toyota";  // Accessible outside the class
    myCar.showBrand();       // Accessible outside the class
    return 0;
}
```

**Output:**

```
Car brand: Toyota
```

---

### **2. `private` Access Specifier**

- Members declared as `private` **cannot** be accessed directly outside the class.
- Only **member functions** of the **same class** can access them.
- Used to **hide sensitive data** and enforce **encapsulation**.

**Example:**

```cpp
#include <iostream>
using namespace std;

class BankAccount {
private:
    double balance;  // Private member

public:
    void setBalance(double amount) {
        balance = amount;  // Accessible inside the class
    }

    void showBalance() {
        cout << "Account balance: $" << balance << endl;
    }
};

int main() {
    BankAccount account;
    // account.balance = 500;  // ❌ Error: Cannot access private member
    account.setBalance(500);   // ✅ Allowed via public function
    account.showBalance();     // ✅ Allowed
    return 0;
}
```

**Output:**

```
Account balance: $500
```

---

### **3. `protected` Access Specifier**

- Similar to `private`, but **allows access in derived (child) classes**.
- Used when **inheritance** is involved.

**Example:**

```cpp
#include <iostream>
using namespace std;

class Animal {
protected:
    string type;  // Protected member

public:
    void setType(string t) {
        type = t;
    }
};

class Dog : public Animal {
public:
    void showType() {
        cout << "Animal type: " << type << endl;  // Accessible in derived class
    }
};

int main() {
    Dog myDog;
    myDog.setType("Mammal");
    myDog.showType();
    // myDog.type = "Bird";  // ❌ Error: 'type' is protected
    return 0;
}
```

**Output:**

```
Animal type: Mammal
```

---

### **Comparison Table**

|Access Specifier|Accessible Inside Class|Accessible in Derived Class|Accessible Outside Class|
|---|---|---|---|
|`public`|✅ Yes|✅ Yes|✅ Yes|
|`private`|✅ Yes|❌ No|❌ No|
|`protected`|✅ Yes|✅ Yes|❌ No|

---

### **When to Use Which?**

✅ **Use `private`** when:

- You want to **hide implementation details** and **protect data**.
- You **don’t want** direct modification of variables.

✅ **Use `public`** when:

- You want to **allow external access** to a function or variable.
- You need **getter/setter** methods.

✅ **Use `protected`** when:

- You are **designing an inheritance hierarchy**.
- You want to **allow derived classes to access** base class members **without exposing them** publicly.

---

## Encapsulation

Encapsulation is achieved by bundling the data (attributes) and methods (behaviors) that operate on the data into a single unit (class). Access specifiers control the access levels of class members.

**Implementation**

```cpp
class Car {
private:
    std::string brand; // Private member
    int year;          // Private member
public:
    void setBrand(std::string b) {
        brand = b;     // Accessible within the class
    }
    std::string getBrand() {
        return brand;  // Accessible within the class
    }
};

int main() {
    Car myCar;
    myCar.setBrand("Toyota");  // Public method accessing private member
    std::cout << "Brand: " << myCar.getBrand() << std::endl;  // Public method accessing private member
    return 0;
}
```

- **Private**: Members are accessible only within the class.
- **Public**: Members are accessible from outside the class.
- **Protected**: Members are accessible within the class and its derived classes.

---

## Inheritance

Inheritance allows a class to inherit properties and behavior from another class. It promotes code reusability and establishes a hierarchical relationship between classes.

The derived class (subclass) inherits from the base class (superclass) and may add new attributes and methods or override existing ones. 

**Example**

```cpp
class Animal {
public:
    void sound() {
        std::cout << "Animal makes a sound." << std::endl;
    }
};

class Dog : public Animal {
public:
    void sound() {
        std::cout << "Dog barks." << std::endl;
    }
};

int main() {
    Dog myDog;
    myDog.sound(); // Calls sound() method of derived class
    return 0;
}
```

### **Types of Inheritance**

Inheritance is a key feature of **Object-Oriented Programming (OOP)** in C++ that allows a class to derive properties and behaviors from another class. This helps in **code reusability** and **extensibility**.

C++ supports five types of inheritance: **Single, Multiple, Multilevel, Hierarchical, and Hybrid.**

---

#### **Single Inheritance**

A **single derived class** inherits from **one base class**.

✅ **Example:**

```cpp
#include <iostream>
using namespace std;

class Parent {
public:
    void show() { cout << "Parent class\n"; }
};

class Child : public Parent {  // Single Inheritance
public:
    void display() { cout << "Child class\n"; }
};

int main() {
    Child obj;
    obj.show();    // Inherited function
    obj.display(); // Child's own function
}
```

**Output:**

```
Parent class
Child class
```

---

#### **Multiple Inheritance**

A **single derived class** inherits from **more than one base class**.

✅ **Example:**

```cpp
class A {
public:
    void showA() { cout << "Class A\n"; }
};

class B {
public:
    void showB() { cout << "Class B\n"; }
};

class C : public A, public B {  // Multiple Inheritance
public:
    void showC() { cout << "Class C\n"; }
};

int main() {
    C obj;
    obj.showA();
    obj.showB();
    obj.showC();
}
```

**Output:**

```
Class A
Class B
Class C
```

**⚠️ Ambiguity Issue in Multiple Inheritance:**  
If both parent classes have the **same function name**, use **scope resolution (`A::show()`)** in the derived class to resolve ambiguity.

---

#### **Multilevel Inheritance**

A class derives from another **derived class**, forming a **chain of inheritance**.

✅ **Example:**

```cpp
class A {
public:
    void showA() { cout << "Class A\n"; }
};

class B : public A {
public:
    void showB() { cout << "Class B\n"; }
};

class C : public B {  // Multilevel Inheritance
public:
    void showC() { cout << "Class C\n"; }
};

int main() {
    C obj;
    obj.showA();  // Inherited from A
    obj.showB();  // Inherited from B
    obj.showC();  // Own function
}
```

**Output:**

```
Class A
Class B
Class C
```

---

#### **Hierarchical Inheritance**

Multiple derived classes inherit from a **single base class**.

✅ **Example:**

```cpp
class Parent {
public:
    void showParent() { cout << "Parent class\n"; }
};

class Child1 : public Parent {
public:
    void showChild1() { cout << "Child1 class\n"; }
};

class Child2 : public Parent {
public:
    void showChild2() { cout << "Child2 class\n"; }
};

int main() {
    Child1 obj1;
    obj1.showParent();
    obj1.showChild1();

    Child2 obj2;
    obj2.showParent();
    obj2.showChild2();
}
```

**Output:**

```
Parent class
Child1 class
Parent class
Child2 class
```

---

#### **Hybrid Inheritance (Combination of Two or More Types)**

It is a mix of **multiple, multilevel, and hierarchical inheritance**.

✅ **Example:**

```cpp
class A {
public:
    void showA() { cout << "Class A\n"; }
};

class B : public A {
public:
    void showB() { cout << "Class B\n"; }
};

class C {
public:
    void showC() { cout << "Class C\n"; }
};

class D : public B, public C {  // Hybrid Inheritance
public:
    void showD() { cout << "Class D\n"; }
};

int main() {
    D obj;
    obj.showA();  // From A via B
    obj.showB();  // From B
    obj.showC();  // From C
    obj.showD();  // From D
}
```

**Output:**

```
Class A
Class B
Class C
Class D
```

**⚠️ Diamond Problem in Hybrid Inheritance:**  
When a class inherits from two classes that both inherit from the same base class, it creates ambiguity. Use **virtual inheritance** to solve this issue.

---

**Key Points**

✅ **Single Inheritance:** One base class, one derived class.  
✅ **Multiple Inheritance:** One derived class inherits from multiple base classes (can cause ambiguity).  
✅ **Multilevel Inheritance:** Inheritance chain (A → B → C).  
✅ **Hierarchical Inheritance:** One base class, multiple derived classes.  
✅ **Hybrid Inheritance:** Combination of two or more types, can lead to the **diamond problem** (resolved using virtual inheritance).

---

## **Abstract Classes and Interfaces**

C++ does not have a built-in `interface` keyword like Java, but it achieves similar functionality using **abstract classes** with **pure virtual functions**.

---

### **Abstract Classes**

An **abstract class** is a class that **cannot be instantiated**. It serves as a blueprint for derived classes and contains at least one **pure virtual function**.

#### **Pure Virtual Function Syntax**

```cpp
virtual returnType functionName(parameters) = 0;
```

**Example:**

```cpp
#include <iostream>
using namespace std;

class Shape {  // Abstract class
public:
    virtual void draw() = 0;  // Pure virtual function
};

class Circle : public Shape {
public:
    void draw() override {  // Implementing the pure virtual function
        cout << "Drawing a Circle" << endl;
    }
};

class Square : public Shape {
public:
    void draw() override {
        cout << "Drawing a Square" << endl;
    }
};

int main() {
    // Shape shape; ❌ Error: Cannot instantiate an abstract class
    Circle c;
    Square s;

    c.draw();  // Output: Drawing a Circle
    s.draw();  // Output: Drawing a Square

    return 0;
}
```

**Key Points:**

- Abstract classes **cannot be instantiated**.
- Derived classes **must override all pure virtual functions**.
- Used when a **common interface** is needed for multiple derived classes.

---

### **Interfaces in C++ (Using Abstract Classes)**

In C++, **interfaces** are implemented using **abstract classes with only pure virtual functions** (no data members or concrete functions).

**Example:**

```cpp
#include <iostream>
using namespace std;

class IAnimal {  // Interface (pure abstract class)
public:
    virtual void makeSound() = 0;  // Pure virtual function
};

class Dog : public IAnimal {
public:
    void makeSound() override {
        cout << "Bark! Bark!" << endl;
    }
};

class Cat : public IAnimal {
public:
    void makeSound() override {
        cout << "Meow! Meow!" << endl;
    }
};

int main() {
    Dog dog;
    Cat cat;

    dog.makeSound();  // Output: Bark! Bark!
    cat.makeSound();  // Output: Meow! Meow!

    return 0;
}
```

**Key Points:**

- **Interfaces** in C++ are **abstract classes with only pure virtual functions**.
- They define a **contract** that derived classes must follow.
- Unlike Java, C++ allows **multiple inheritance**, so a class can inherit multiple interfaces.

---

**Comparison Table**

|Feature|Abstract Class|Interface (Pure Abstract Class)|
|---|---|---|
|Can have variables|✅ Yes|❌ No|
|Can have function implementations|✅ Yes (non-pure virtual functions)|❌ No (only pure virtual functions)|
|Can be instantiated|❌ No|❌ No|
|Multiple inheritance|✅ Yes|✅ Yes|

---

**When to Use Which?**

✅ **Use Abstract Classes** when:

- You need **some** implemented methods.
- You want to provide **default functionality** in a base class.

✅ **Use Interfaces** when:

- You need a **strict contract** with only method declarations.
- You are designing **multiple inheritance** structures.

---

## Polymorphism

Polymorphism allows objects to take on multiple forms. It's achieved through function overriding and function overloading. It allows methods to be overridden in derived classes and enables functions to operate on objects of multiple classes through a common interface.

- **Function Overriding**: Redefining a base class function in a derived class with the same signature.
- **Function Overloading**: Defining multiple functions with the same name but different parameter lists.

### **Types of Polymorphism**

C++ supports two types:

1. **Compile-time Polymorphism (Static Binding)**
    - Function Overloading
    - Operator Overloading
    - Templates
2. **Run-time Polymorphism (Dynamic Binding)**
    - Function Overriding
    - Virtual Functions

---

### **Compile-time Polymorphism (Static Binding)**

#### **Function Overloading**

Multiple functions with the **same name** but different **parameter lists**.

✅ **Example:**

```cpp
#include <iostream>
using namespace std;

class Math {
public:
    int add(int a, int b) { return a + b; }
    double add(double a, double b) { return a + b; }  // Overloaded function
};

int main() {
    Math obj;
    cout << obj.add(5, 10) << endl;      // Calls int version
    cout << obj.add(2.5, 3.5) << endl;  // Calls double version
}
```

**Output:**

```
15
6
```

---

#### **Operator Overloading**

Allows operators to be redefined for **user-defined types**.

✅ **Example:**

```cpp
class Complex {
public:
    int real, imag;
    Complex(int r, int i) : real(r), imag(i) {}

    Complex operator+(const Complex& c) {  // Overloading +
        return Complex(real + c.real, imag + c.imag);
    }

    void show() { cout << real << " + " << imag << "i" << endl; }
};

int main() {
    Complex c1(3, 4), c2(2, 5);
    Complex c3 = c1 + c2;  // Using overloaded +
    c3.show();
}
```

**Output:**

```
5 + 9i
```

---

### **Run-time Polymorphism (Dynamic Binding)**

#### **Function Overriding**

A **derived class** provides a new definition for a **base class function** with the **same signature**.

✅ **Example:**

```cpp
class Parent {
public:
    virtual void show() { cout << "Parent class\n"; }
};

class Child : public Parent {
public:
    void show() override { cout << "Child class\n"; }  // Overriding base class function
};

int main() {
    Parent* p;
    Child obj;
    p = &obj;
    p->show();  // Calls Child's show() due to virtual function
}
```

**Output:**

```
Child class
```

---

#### **Virtual Functions**

A function in a **base class** marked with `virtual` ensures that the **derived class function** is called, even when accessed through a **base class pointer**.

✅ **Example:**

```cpp
class Animal {
public:
    virtual void makeSound() { cout << "Animal sound\n"; }
};

class Dog : public Animal {
public:
    void makeSound() override { cout << "Woof!\n"; }
};

int main() {
    Animal* a;
    Dog d;
    a = &d;
    a->makeSound();  // Calls Dog's makeSound() due to virtual function
}
```

**Output:**

```
Woof!
```

---

**Key Points**

✅ **Polymorphism allows functions to behave differently based on input or object type.**  
✅ **Compile-time polymorphism (static binding) includes function overloading and operator overloading.**  
✅ **Run-time polymorphism (dynamic binding) includes function overriding and virtual functions.**  
✅ **Use `virtual` for base class functions to enable overriding.**

---

## **Composition**

**Composition** is a type of object relationship in C++ where one class contains objects of another class as **data members**. It represents a **"has-a"** relationship and enables **code reuse and modular design**.

---

### **Key Characteristics**

✅ **Strong ownership** – The contained object (part) cannot exist independently of the containing object (whole).  
✅ **Lifetime dependency** – The contained object's lifecycle is tied to the owner.  
✅ **Used for code reusability** – Helps build complex objects by combining simpler ones.

---

### **Example: A Car Has an Engine**

A **Car** object contains an **Engine** object. The **Engine** is part of the Car and does not exist independently.

✅ **Example:**

```cpp
#include <iostream>
using namespace std;

class Engine {
public:
    void start() { cout << "Engine started\n"; }
};

class Car {
private:
    Engine engine;  // Car has an Engine (composition)
public:
    void startCar() {
        engine.start();  // Using Engine's function
        cout << "Car started\n";
    }
};

int main() {
    Car myCar;
    myCar.startCar();
}
```

**Output:**

```
Engine started
Car started
```

---

### **Composition vs. Inheritance**

|Feature|Composition|Inheritance|
|---|---|---|
|Relationship|"Has-a"|"Is-a"|
|Flexibility|More flexible, allows modular design|Less flexible, rigid hierarchy|
|Reusability|Can reuse classes without inheritance|Reuses base class methods but ties subclasses|
|Object Lifespan|Contained object depends on the owner|Derived class object can exist independently|

✅ **Use Composition** when an object **contains** another object but **is not** a subclass of it.  
✅ **Use Inheritance** when a class **extends** another class and maintains an **"is-a"** relationship.

---

**Key Points**

✅ **Composition enables modular design and code reusability.**  
✅ **It defines a "has-a" relationship, meaning objects contain other objects.**  
✅ **Contained objects exist only as long as the containing object exists.**  
✅ **Preferred over inheritance when objects are independent but related.**

---
## Virtual Functions

- **Declaration**: When a function is declared as `virtual` in a base class, it indicates that this function can be overridden in derived classes.
- **Polymorphism**: Virtual functions enable runtime polymorphism, allowing the compiler to determine the appropriate function to call based on the actual object type at runtime.
- **Syntax**:
  ```cpp
  virtual returnType functionName(parameters) [const] [override] = 0;
  ```
  - `returnType`: Return type of the function.
  - `functionName`: Name of the function.
  - `parameters`: Parameters of the function.
  - `const`: Optionally indicates that the function does not modify the object's state.
  - `override`: Optionally indicates that the function overrides a virtual function from the base class.
- **Pure Virtual Functions**: A pure virtual function is declared with `= 0` at the end of its declaration. It means that the function has no implementation in the base class and must be overridden in derived classes.

**Example**

```cpp
class Base {
public:
    virtual void display() const {
        std::cout << "Displaying from Base class" << std::endl;
    }
};

class Derived : public Base {
public:
    void display() const override {
        std::cout << "Displaying from Derived class" << std::endl;
    }
};

int main() {
    Base* basePtr;
    Derived derivedObj;

    basePtr = &derivedObj;
    basePtr->display(); // Calls the display() method of Derived class

    return 0;
}
```

In this example:
- `Base` class has a virtual function `display()`.
- `Derived` class overrides the `display()` function.
- In `main()`, a pointer of type `Base` points to an object of type `Derived`. The `display()` method called through this pointer resolves to the overridden function in `Derived` class at runtime, demonstrating runtime polymorphism.

**Use Cases**

- **Polymorphism**: Virtual functions enable polymorphic behavior, allowing derived classes to provide their own implementation.
- **Dynamic Binding**: Virtual functions support dynamic binding, where the appropriate function to call is determined at runtime based on the object's actual type.

***

## Abstract Classes

### Abstract Classes:

- An abstract class is a class that cannot be instantiated on its own.
- It may contain one or more pure virtual functions.
- Abstract classes serve as base classes for other classes.
- Abstract classes can define some methods with implementations alongside pure virtual functions.
- Classes derived from abstract classes must implement all pure virtual functions.

### Pure Virtual Functions:

- A pure virtual function is a virtual function that has no implementation in the base class.
- It is declared using the syntax `virtual returnType functionName() = 0;`.
- Any class containing a pure virtual function becomes an abstract class.
- Derived classes must override and provide implementations for all pure virtual functions to become concrete classes.

**Example**:

```cpp
#include <iostream>

// Abstract class (Interface)
class Shape {
public:
    // Pure virtual function (Interface method)
    virtual void draw() const = 0;
};

// `const` means this function does not modify the object.

// Concrete class implementing the Shape interface
class Circle : public Shape {
public:
    void draw() const override {
        std::cout << "Drawing a circle" << std::endl;
    }
};

// Concrete class implementing the Shape interface
class Square : public Shape {
public:
    void draw() const override {
        std::cout << "Drawing a square" << std::endl;
    }
};

int main() {
    Circle circle;
    Square square;

    // Polymorphic behavior
    Shape* shapes[] = {&circle, &square};
    for (auto shape : shapes) {
        shape->draw(); // Calls the appropriate draw() method based on the actual object type
    }

    return 0;
}
```

In this example:
- `Shape` is an abstract class defining an interface with a pure virtual function `draw()`.
- `Circle` and `Square` are concrete classes that implement the `Shape` interface by providing an implementation for the `draw()` method.
- In `main()`, we demonstrate polymorphic behavior by storing `Circle` and `Square` objects in an array of `Shape` pointers and calling the `draw()` method on each object through the base class pointer.

***

## Instantiating a Class

### Instantiating a Class Regularly:

- **Syntax**:
  ```cpp
  ClassName objectName(parameters);
  ```
- **Automatic Allocation**: Allocates memory for the object on the stack.
- **Lifetime**: Object exists until the end of the scope where it's declared.
- **Automatic Cleanup**: Memory is automatically deallocated when the object goes out of scope.
- **Usage**:
  ```cpp
  objectName.memberFunction(); // Accessing member functions and attributes using the '.' operator
  ```
- **Common Use Cases**:
  - Objects with short lifetimes, scoped within a function or block.
  - Objects that don't need to be dynamically allocated.
### Instantiating a Class as a Pointer:

- **Syntax**:
  ```cpp
  ClassName* pointerName = new ClassName(parameters);
  ```
- **Dynamic Allocation**: Allocates memory for the object on the heap.
- **Lifetime**: Object exists until explicitly deleted using `delete` keyword.
- **Ownership**: The programmer is responsible for managing the object's memory (deallocation).
- **Usage**:
  ```cpp
  pointerName->memberFunction(); // Accessing member functions and attributes using '->' operator
  delete pointerName; // Explicitly deallocating memory
  ```
- **Common Use Cases**:
  - Objects whose lifetimes need to extend beyond their scope.
  - Objects that are part of a data structure like linked lists or trees.

#### Polymorphic Behavior:

- Polymorphic behavior allows objects of different derived classes to be treated as objects of the base class.
- To achieve polymorphism, you typically use pointers or references to the base class.
- When you call a virtual function through a base class pointer or reference, the correct function implementation based on the actual derived class type is invoked at runtime (dynamic dispatch).

#### Storing Objects in Data Structures:

- You can store objects of a class (instantiated regularly) in a data structure without using pointers.
- However, if you want to store objects of derived classes polymorphically, you need to use pointers or references to the base class.
- Storing objects by value (regular instantiation) in a data structure can lead to object slicing, where the derived class-specific attributes are lost when stored in a container that expects objects of the base class type.

**Example**:

```cpp
#include <iostream>
#include <vector>

class Base {
public:
    virtual void print() const {
        std::cout << "Base" << std::endl;
    }
};

class Derived : public Base {
public:
    void print() const override {
        std::cout << "Derived" << std::endl;
    }
};

int main() {
    // Using pointers for polymorphic behavior
    std::vector<Base*> objects;
    objects.push_back(new Base());
    objects.push_back(new Derived());

    for (auto obj : objects) {
        obj->print(); // Calls the correct print() based on the object type
        delete obj;   // Clean up allocated memory
    }

    // Storing objects by value
    std::vector<Base> objectsByValue;
    Base baseObj;
    Derived derivedObj;

    objectsByValue.push_back(baseObj);    // Slicing occurs
    objectsByValue.push_back(derivedObj); // Slicing occurs

    for (const auto& obj : objectsByValue) {
        obj.print(); // Calls the Base::print() function for all objects
    }

    return 0;
}
```

In this example:
- We use pointers to `Base` to store objects of different derived classes in a vector polymorphically.
- We demonstrate object slicing when storing objects by value in a vector of the base class. Only the base class part of the objects is retained.

**Guidelines**:

- Prefer regular instantiation (`ClassName objectName`) when possible, as it simplifies memory management and reduces the risk of memory-related errors.
- Use pointers (`ClassName* pointerName`) when dynamic memory allocation is necessary or when polymorphic behavior is required.

***

## Constructors

In C++, a constructor is a special member function that is automatically called when an object of a class is created. The primary purpose of a constructor is to initialize the object's data members and to allocate any resources that the object might need during its lifetime.

**Key Points About Constructors**:

1. **Naming and Syntax:**
   - A constructor has the same name as the class.
   - It has no return type, not even `void`.
   - Constructors can be overloaded, meaning a class can have multiple constructors with different parameter lists.

   **Example:**
   ```cpp
   class MyClass {
   public:
       MyClass() {
           // Default constructor
       }
   };
   ```

2. **Types of Constructors:**

   a. **Default Constructor:**
   - A constructor that takes no arguments.
   - If you do not define any constructor for a class, the compiler automatically provides a default constructor.

   **Example:**
   ```cpp
   class MyClass {
   public:
       MyClass() {
           // Default constructor
       }
   };

   MyClass obj;  // Calls the default constructor
   ```

   b. **Parameterized Constructor:**
   - A constructor that takes one or more parameters.
   - Useful for initializing objects with specific values at the time of creation.

   **Example:**
   ```cpp
   class MyClass {
   private:
       int data;
   public:
       MyClass(int value) {
           data = value;  // Parameterized constructor
       }
   };

   MyClass obj(10);  // Calls the parameterized constructor with value 10
   ```

   c. **Copy Constructor:**
   - A constructor that initializes an object by copying data from another object of the same class.
   - The copy constructor is invoked when an object is initialized from another object, passed by value to a function, or returned from a function.

   **Example:**
   ```cpp
   class MyClass {
   private:
       int data;
   public:
       MyClass(int value) : data(value) {}  // Parameterized constructor

       MyClass(const MyClass& other) {
           data = other.data;  // Copy constructor
       }
   };

   MyClass obj1(10);
   MyClass obj2 = obj1;  // Calls the copy constructor
   ```

   d. **Move Constructor (C++11 and later):**
   - A move constructor transfers resources from one object to another, leaving the source object in a valid but unspecified state.
   - Useful for optimizing performance when an object is being moved rather than copied, especially when dealing with dynamic memory.

   **Example:**
   ```cpp
   class MyClass {
   private:
       int* data;
   public:
       MyClass(int value) : data(new int(value)) {}  // Parameterized constructor

       MyClass(MyClass&& other) noexcept {
           data = other.data;  // Move constructor
           other.data = nullptr;
       }
   };

   MyClass obj1(10);
   MyClass obj2 = std::move(obj1);  // Calls the move constructor
   ```

3. **Constructor Initialization List:**
   - A constructor can use an initialization list to initialize data members directly, often making the code more efficient.
   - The initialization list is placed after the constructor's parameters and before the constructor's body.

   **Example:**
   ```cpp
   class MyClass {
   private:
       int data;
   public:
       MyClass(int value) : data(value) {  // Initialization list
           // Constructor body
       }
   };
   ```

4. **Explicit Constructor:**
   - Constructors can be marked as `explicit` to prevent implicit conversions and copy-initialization, which can sometimes lead to unexpected behavior.
   
   **Example:**
   ```cpp
   class MyClass {
   public:
       explicit MyClass(int value) {
           // Explicit constructor
       }
   };

   MyClass obj1 = 10;  // Error: Cannot use implicit conversion
   MyClass obj2(10);   // OK: Direct initialization
   ```

5. **Constructor Overloading:**
   - You can overload constructors in a class by defining multiple constructors with different sets of parameters. This allows for creating objects in different ways.

   **Example:**
   ```cpp
   class MyClass {
   private:
       int data;
   public:
       MyClass() : data(0) {}          // Default constructor
       MyClass(int value) : data(value) {}  // Parameterized constructor
   };

   MyClass obj1;    // Calls default constructor
   MyClass obj2(10); // Calls parameterized constructor
   ```

6. **Destructors and Constructors:**
   - The constructor sets up the initial state of an object, while the destructor is responsible for cleaning up when the object is destroyed.

**Summary**:
- **Constructor Purpose:** To initialize an object when it is created.
- **Types:** Includes default, parameterized, copy, and move constructors.
- **Initialization List:** Provides a way to initialize members directly.
- **Explicit Keyword:** Prevents implicit conversions.
- **Overloading:** Allows multiple constructors with different parameters for flexible object initialization.

---

## Initialization List

In C++, an initialization list is a feature that allows you to initialize member variables of a class directly before the constructor's body executes. It provides a more efficient and sometimes necessary way to initialize class members, especially when dealing with constant members, reference members, or members of classes that don't have default constructors.

### Syntax of an Initialization List:

The initialization list is placed between the constructor's parameter list and the constructor's body. It is introduced by a colon `:` followed by a comma-separated list of member variables, each followed by the value or expression used to initialize it.

**Syntax:**
```cpp
ClassName::ConstructorName(parameters) : member1(value1), member2(value2), ... {
    // Constructor body
}
```

### Example of Initialization List:

Let's consider a simple example where a class has three member variables: an integer, a reference, and a constant integer.

```cpp
class MyClass {
private:
    int x;
    int& y;
    const int z;
public:
    MyClass(int a, int b, int c) : x(a), y(b), z(c) {
        // Constructor body (optional)
    }

    void printValues() {
        std::cout << "x: " << x << ", y: " << y << ", z: " << z << std::endl;
    }
};
```

### Why Use Initialization Lists?

1. **Efficiency:**
   - Using an initialization list can be more efficient than assigning values in the constructor body because it avoids the extra step of default construction followed by assignment. The member variables are directly initialized with the specified values.

   **Example:**
   ```cpp
   class MyClass {
   private:
       int x;
   public:
       MyClass(int value) : x(value) {  // Efficient initialization
       }
   };
   ```

   If `x` were initialized inside the constructor body like this:
   ```cpp
   MyClass(int value) {
       x = value;  // Less efficient, involves default construction + assignment
   }
   ```
   The initialization list approach is generally faster because `x` is constructed directly with `value`.

2. **Initialization of `const` Members:**
   - `const` member variables must be initialized at the time of object creation and cannot be assigned a value afterward. Therefore, they must be initialized in the initialization list.

   **Example:**
   ```cpp
   class MyClass {
   private:
       const int x;
   public:
       MyClass(int value) : x(value) {  // Must use initialization list
       }
   };
   ```

3. **Initialization of Reference Members:**
   - References in C++ must be initialized when they are created. Since they cannot be reassigned, they must be initialized in the initialization list.

   **Example:**
   ```cpp
   class MyClass {
   private:
       int& ref;
   public:
       MyClass(int& r) : ref(r) {  // Must use initialization list
       }
   };
   ```

4. **Initialization of Members with No Default Constructor:**
   - If a member variable is an object of a class that doesn't have a default constructor (a constructor with no parameters), it must be initialized using an initialization list.

   **Example:**
   ```cpp
   class AnotherClass {
   private:
       int a;
   public:
       AnotherClass(int value) : a(value) {}  // No default constructor
   };

   class MyClass {
   private:
       AnotherClass ac;
   public:
       MyClass(int value) : ac(value) {  // Must use initialization list
       }
   };
   ```

5. **Order of Initialization:**
   - The order of initialization in an initialization list is determined by the order in which the member variables are declared in the class, **not** by the order in which they appear in the initialization list.

   **Example:**
   ```cpp
   class MyClass {
   private:
       int x;
       int y;
   public:
       MyClass(int a, int b) : y(b), x(a) {  // x will still be initialized first
       }
   };
   ```

**Summary**:
- **Initialization Lists** are used to directly initialize class members before the constructor body executes.
- They are **necessary** for initializing `const` members, references, and members of types without default constructors.
- Using an initialization list can be **more efficient** because it avoids the extra step of default construction followed by assignment.
- The order of initialization is based on the order of declaration in the class, not the order in the initialization list.

***
## Destructors

**Key Points About Destructors**:

1. **Naming and Syntax:**
   - A destructor has the same name as the class, but it is preceded by a tilde `~`.
   - It takes no arguments and has no return type, not even `void`.

   **Example:**
   ```cpp
   class MyClass {
   public:
       ~MyClass() {
           // Destructor code here
       }
   };
   ```

2. **Automatic Invocation:**
   - A destructor is automatically called when:
     - An object goes out of scope (e.g., at the end of a block, like a function).
     - An object is explicitly deleted using the `delete` keyword for dynamically allocated objects.

3. **Resource Management:**
   - Destructors are often used to free resources that were acquired by the object, such as dynamically allocated memory.
   - If your class manages a resource, it should have a destructor to ensure that the resource is properly released.

   **Example with Dynamic Memory:**
   ```cpp
   class MyClass {
   private:
       int* data;
   public:
       MyClass(int size) {
           data = new int[size];  // Allocating memory
       }

       ~MyClass() {
           delete[] data;  // Releasing memory
       }
   };
   ```

4. **Order of Destruction:**
   - For local (stack-allocated) objects, destructors are called in the reverse order of their creation.
   - For class members, destructors are called in the reverse order of their declaration in the class.

5. **Base and Derived Classes:**
   - If a class is intended to be used as a base class, its destructor should be declared as `virtual`. This ensures that the destructor of the derived class is called when an object of the derived class is deleted through a pointer to the base class.

   **Example:**
   ```cpp
   class Base {
   public:
       virtual ~Base() {
           // Base class destructor
       }
   };

   class Derived : public Base {
   public:
       ~Derived() {
           // Derived class destructor
       }
   };

   void example() {
       Base* obj = new Derived();
       delete obj;  // Calls Derived's destructor, then Base's destructor
   }
   ```

6. **Rule of Three:**
   - If your class requires a destructor (usually because it manages resources like dynamic memory), it often also requires a copy constructor and a copy assignment operator. This is known as the Rule of Three.
   - With C++11, the Rule of Three is often extended to the Rule of Five, which includes the move constructor and move assignment operator.

7. **Default Destructor:**
   - If you do not explicitly define a destructor, the compiler generates a default destructor for you. This default destructor will properly clean up built-in types but won't manage any dynamically allocated resources, which may lead to memory leaks if your class allocates memory dynamically.

   **Example:**
   ```cpp
   class MyClass {
       // No explicit destructor defined
   };

   MyClass obj;  // Default destructor will be called automatically when obj goes out of scope
   ```

**Summary**:
- A destructor is a special member function in C++ that cleans up when an object is destroyed.
- It is automatically called when an object goes out of scope or is deleted.
- Destructors are essential for resource management, especially when dealing with dynamic memory.
- For classes intended to be base classes, always declare the destructor as `virtual` to ensure proper cleanup in derived classes.

***

## `this` Pointer

In C++, the `this` pointer is a hidden pointer that is automatically passed to non-static member functions of a class. It provides a way to access the calling object within its member functions. Here's a detailed overview of the `this` pointer:

### What is the `this` Pointer?

- **Definition:** The `this` pointer is a special pointer that points to the object for which a non-static member function is currently executing.
- **Type:** `this` is of type `T*`, where `T` is the class type. For example, in a class `MyClass`, `this` would be of type `MyClass*`.

### Usage of the `this` Pointer

1. **Accessing Member Variables and Functions**

   The `this` pointer allows you to access members of the class from within a member function. It is used implicitly to refer to the calling object.

   **Example:**
   ```cpp
   class MyClass {
   public:
       int value;

       void setValue(int value) {
           this->value = value; // 'this->value' refers to the member variable
       }

       void printValue() {
           std::cout << this->value << std::endl; // 'this->value' is the member variable
       }
   };
   ```

   In the `setValue` function, `this->value` distinguishes the member variable `value` from the parameter `value`.

2. **Returning the Current Object**

   You can use the `this` pointer to return the current object from a member function. This is useful for method chaining, where you want to call multiple member functions in a single statement.

   **Example:**
   ```cpp
   class MyClass {
   public:
       int value;

       MyClass& setValue(int value) {
           this->value = value;
           return *this; // Return the current object
       }

       void printValue() {
           std::cout << this->value << std::endl;
       }
   };

   int main() {
       MyClass obj;
       obj.setValue(10).printValue(); // Method chaining
       return 0;
   }
   ```

   Here, `setValue` returns a reference to the current object (`*this`), allowing `printValue` to be called immediately after `setValue`.

3. **Distinguishing Between Member Variables and Parameters**

   The `this` pointer is particularly useful for resolving naming conflicts between member variables and parameters.

   **Example:**
   ```cpp
   class MyClass {
   public:
       int value;

       void setValue(int value) {
           this->value = value; // 'this->value' is the member variable, 'value' is the parameter
       }
   };
   ```

   Without `this`, it would be ambiguous whether `value` refers to the member variable or the function parameter.

**Key Points**

- **Implicit Use:** The `this` pointer is implicit and automatically available in non-static member functions. It is not required to be explicitly used but can be if needed.
- **Static Member Functions:** Static member functions do not have a `this` pointer because they are not associated with any specific object. They belong to the class itself, not to any instance.

**Summary**

- **`this` Pointer:** A hidden pointer in C++ that points to the object for which a non-static member function is executing.
- **Usage:** Accessing member variables and functions, returning the current object for method chaining, resolving naming conflicts between parameters and member variables.
- **Static Member Functions:** Do not have a `this` pointer since they do not operate on a specific instance of the class.

---

# Operator Overloading

## **Overloading Arithmetic and Relational Operators**

C++ allows **operator overloading**, enabling **user-defined types** (classes) to use **arithmetic** and **relational** operators just like built-in types.

---

### **Overloading Arithmetic Operators**

Arithmetic operators (`+`, `-`, `*`, `/`, `%`) can be overloaded to perform operations on objects.

#### **Example: Overloading `+` for a Complex Number Class**

✅ **Example:**

```cpp
#include <iostream>
using namespace std;

class Complex {
public:
    int real, imag;
    
    Complex(int r, int i) : real(r), imag(i) {}

    // Overloading +
    Complex operator+(const Complex& c) {
        return Complex(real + c.real, imag + c.imag);
    }

    void show() { cout << real << " + " << imag << "i" << endl; }
};

int main() {
    Complex c1(3, 4), c2(1, 2);
    Complex c3 = c1 + c2;  // Using overloaded +
    c3.show();
}
```

**Output:**

```
4 + 6i
```

---

### **Overloading Relational Operators**

Relational operators (`==`, `!=`, `<`, `>`, `<=`, `>=`) can be overloaded to compare objects.

#### **Example: Overloading `==` for a Point Class**

✅ **Example:**

```cpp
class Point {
public:
    int x, y;
    
    Point(int a, int b) : x(a), y(b) {}

    // Overloading ==
    bool operator==(const Point& p) {
        return (x == p.x && y == p.y);
    }
};

int main() {
    Point p1(2, 3), p2(2, 3), p3(4, 5);

    cout << (p1 == p2) << endl;  // 1 (true)
    cout << (p1 == p3) << endl;  // 0 (false)
}
```

**Output:**

```
1
0
```

---

**Key Points**

✅ **Operator overloading makes custom types behave like built-in types.**  
✅ **Arithmetic operators can be overloaded for mathematical operations on objects.**  
✅ **Relational operators can be overloaded for object comparisons.**  
✅ **Operators should be overloaded as `const` member functions when they do not modify the object.**

---

## **Overloading `[]`, `()`, `->`, `<<`, and `>>` Operators**

C++ allows **overloading special operators** like `[]`, `()`, `->`, `<<`, and `>>` to extend functionality for **user-defined types** (classes).

---

### **Overloading `[]` (Subscript Operator)**

The subscript operator `[]` is often overloaded to access elements in **custom array-like structures**.

✅ **Example:** Implementing a **custom array class**

```cpp
#include <iostream>
using namespace std;

class Array {
private:
    int data[5];
public:
    Array() { for (int i = 0; i < 5; i++) data[i] = i * 10; }

    // Overloading []
    int& operator[](int index) {
        if (index < 0 || index >= 5) {
            throw out_of_range("Index out of range");
        }
        return data[index];
    }
};

int main() {
    Array arr;
    cout << arr[2] << endl;  // 20
    arr[2] = 50;
    cout << arr[2] << endl;  // 50
}
```

**Output:**

```
20
50
```

---

### **Overloading `()` (Function Call Operator)**

The function call operator `()` can be overloaded to make an object **callable like a function**.

✅ **Example:** Creating a **functor**

```cpp
class Multiply {
public:
    int operator()(int a, int b) {
        return a * b;
    }
};

int main() {
    Multiply mul;
    cout << mul(4, 5) << endl;  // 20
}
```

**Output:**

```
20
```

---

### **Overloading `->` (Arrow Operator)**

The arrow operator `->` is typically overloaded when using **smart pointers or proxy objects**.

✅ **Example:** Implementing a **custom smart pointer**

```cpp
class Demo {
public:
    void show() { cout << "Demo class\n"; }
};

class SmartPtr {
private:
    Demo* ptr;
public:
    SmartPtr(Demo* p) : ptr(p) {}

    // Overloading ->
    Demo* operator->() { return ptr; }
};

int main() {
    SmartPtr sp(new Demo());
    sp->show();  // Calls Demo::show()
}
```

**Output:**

```
Demo class
```

---

### **Overloading `<<` (Stream Insertion) and `>>` (Stream Extraction)**

These operators allow **custom objects** to be printed (`<<`) or read (`>>`) using **cin/cout**.

✅ **Example:** Overloading `<<` and `>>` for a **Point class**

```cpp
#include <iostream>
using namespace std;

class Point {
private:
    int x, y;
public:
    Point(int a = 0, int b = 0) : x(a), y(b) {}

    // Overloading >>
    friend istream& operator>>(istream& in, Point& p) {
        in >> p.x >> p.y;
        return in;
    }

    // Overloading <<
    friend ostream& operator<<(ostream& out, const Point& p) {
        out << "(" << p.x << ", " << p.y << ")";
        return out;
    }
};

int main() {
    Point p;
    cout << "Enter coordinates: ";
    cin >> p;  // Input format: x y
    cout << "Point: " << p << endl;
}
```

**Input:**

```
Enter coordinates: 3 4
```

**Output:**

```
Point: (3, 4)
```

---

**Key Points**

✅ **`[]` is used for custom array indexing.**  
✅ **`()` makes an object callable like a function.**  
✅ **`->` allows proxy objects to access members of another class.**  
✅ **`<<` and `>>` enable formatted input/output for user-defined types.**  
✅ **Overloading these operators makes objects more intuitive to use.**

---

## **Friend Functions and Friend Classes**

In C++, **friend functions** and **friend classes** allow non-member functions or other classes to access private and protected members of a class.

---

### **Friend Functions**

A **friend function** is a non-member function that has access to the **private** and **protected** members of a class.

#### **When to Use Friend Functions?**

✅ When **two or more classes** need to access each other's private members.  
✅ When implementing **operator overloading** that requires access to private data.  
✅ When a function needs to **access class internals** without being a member.

#### **Example: Accessing Private Members**

```cpp
#include <iostream>
using namespace std;

class Box {
private:
    int width;
public:
    Box(int w) : width(w) {}

    // Declare friend function
    friend void showWidth(Box b);
};

// Friend function definition
void showWidth(Box b) {
    cout << "Width: " << b.width << endl;
}

int main() {
    Box b(10);
    showWidth(b);  // Accessing private member
}
```

**Output:**

```
Width: 10
```

---

### **Friend Classes**

A **friend class** allows all of its member functions to access the **private** and **protected** members of another class.

#### **When to Use Friend Classes?**

✅ When **two tightly coupled classes** need to share private data.  
✅ When an **auxiliary/helper class** needs full access to another class.  
✅ When a class must allow another class to modify its internals **without inheritance**.

#### **Example: Making a Class a Friend**

```cpp
class Engine {
private:
    int horsepower;
public:
    Engine(int hp) : horsepower(hp) {}

    // Declare Car as a friend
    friend class Car;
};

class Car {
public:
    void showEnginePower(Engine e) {
        cout << "Engine Power: " << e.horsepower << " HP" << endl; // Access private member
    }
};

int main() {
    Engine e(250);
    Car c;
    c.showEnginePower(e);
}
```

**Output:**

```
Engine Power: 250 HP
```

---

### **Key Points**

✅ **Friend functions** are non-member functions that access private members.  
✅ **Friend classes** allow full access to another class’s private and protected members.  
✅ **Friendship is not inherited** – derived classes do not get access automatically.  
✅ **Use friend functions/classes only when necessary** to maintain encapsulation.

---

# Templates and Generic Programming

## **Function Templates**

A **function template** allows writing **generic functions** that work with different data types without rewriting the function for each type.

---

### **Syntax of Function Templates**

A function template is defined using the `template` keyword followed by **template parameters** inside angle brackets (`<>`).

```cpp
template <typename T>
T functionName(T arg) {
    // Function body
}
```

- `T` is a **placeholder** for a data type (e.g., `int`, `double`, `char`).
- `typename` and `class` are interchangeable in templates.

---

### **Example: Template for Finding Maximum**

✅ **Example:** A generic function to find the maximum of two values.

```cpp
#include <iostream>
using namespace std;

template <typename T>
T getMax(T a, T b) {
    return (a > b) ? a : b;
}

int main() {
    cout << getMax(10, 20) << endl;      // Works with int
    cout << getMax(5.5, 2.3) << endl;    // Works with double
    cout << getMax('a', 'z') << endl;    // Works with char
}
```

**Output:**

```
20
5.5
z
```

---

### **Function Templates with Multiple Parameters**

Templates can accept **multiple types** using multiple template parameters.

✅ **Example:** A function to swap two values of different types.

```cpp
template <typename T1, typename T2>
void swapValues(T1 &a, T2 &b) {
    cout << "Before swap: " << a << " " << b << endl;
    T1 temp = a;
    a = b;
    b = temp;
    cout << "After swap: " << a << " " << b << endl;
}

int main() {
    int x = 5;
    double y = 3.2;
    swapValues(x, y);
}
```

**Output:**

```
Before swap: 5 3.2
After swap: 3 5
```

---

**Key Points**

✅ **Function templates** allow writing generic functions for multiple data types.  
✅ The **`template` keyword** defines templates, and `typename` or `class` declares type placeholders.  
✅ **Multiple template parameters** can be used for functions handling multiple types.  
✅ The compiler generates **specific function versions** based on the types used during function calls.

---

## **Class Templates**

A **class template** allows creating **generic classes** that work with different data types, making code more reusable and flexible.

---

### **Syntax of Class Templates**

A class template is defined using the `template` keyword followed by **template parameters** inside angle brackets (`<>`).

```cpp
template <typename T>
class ClassName {
private:
    T data;
public:
    ClassName(T value) : data(value) {}  // Constructor
    void show() { cout << data << endl; } // Member function
};
```

- `T` is a **placeholder** for a data type.
- `typename` and `class` can be used interchangeably in templates.

---

### **Example: Generic Class for a Box**

✅ **Example:** A generic class that stores and displays a value.

```cpp
#include <iostream>
using namespace std;

template <typename T>
class Box {
private:
    T value;
public:
    Box(T val) : value(val) {}  
    void show() { cout << "Value: " << value << endl; }
};

int main() {
    Box<int> intBox(10);
    Box<double> doubleBox(5.5);
    Box<string> stringBox("Hello");

    intBox.show();
    doubleBox.show();
    stringBox.show();
}
```

**Output:**

```
Value: 10
Value: 5.5
Value: Hello
```

---

### **Class Templates with Multiple Parameters**

✅ **Example:** A class template with **two** data types.

```cpp
template <typename T1, typename T2>
class Pair {
private:
    T1 first;
    T2 second;
public:
    Pair(T1 a, T2 b) : first(a), second(b) {}
    void show() { cout << "First: " << first << ", Second: " << second << endl; }
};

int main() {
    Pair<int, double> p1(10, 3.14);
    Pair<string, char> p2("Alice", 'A');

    p1.show();
    p2.show();
}
```

**Output:**

```
First: 10, Second: 3.14
First: Alice, Second: A
```

---

**Key Points**

✅ **Class templates** allow creating **generic** classes that work with different data types.  
✅ The **`template` keyword** defines templates, and `typename` or `class` declares type placeholders.  
✅ **Multiple template parameters** can be used for handling multiple types.  
✅ The compiler **instantiates** specific class versions based on the types used.

---

## **Template Specialization and Variadic Templates**

C++ templates provide powerful features such as **template specialization** for handling specific cases and **variadic templates** for handling a variable number of template arguments.

---

## **Template Specialization**

Template specialization allows customizing the behavior of a **template** for a **specific data type**.

### **Syntax of Template Specialization**

```cpp
template <typename T>
class ClassName {
    // General template definition
};

// Specialized template for a specific type
template <>
class ClassName<SpecificType> {
    // Specialized behavior
};
```

---

### **Example: Template Specialization for `char` Type**

✅ **Example:** A generic class template that handles all types but has a special implementation for `char`.

```cpp
#include <iostream>
using namespace std;

// General template
template <typename T>
class Printer {
public:
    static void print(T value) {
        cout << "Value: " << value << endl;
    }
};

// Specialized template for `char`
template <>
class Printer<char> {
public:
    static void print(char value) {
        cout << "Character: '" << value << "'" << endl;
    }
};

int main() {
    Printer<int>::print(100);
    Printer<double>::print(3.14);
    Printer<char>::print('A');  // Uses specialized template
}
```

**Output:**

```
Value: 100
Value: 3.14
Character: 'A'
```

✅ **When to Use Template Specialization?**

- When a **specific data type** needs **different behavior** from the general template.
- When **optimizing performance** for particular types.

---

## **Variadic Templates**

Variadic templates allow **handling an arbitrary number of template parameters**, making templates more flexible.

### **Syntax of Variadic Templates**

```cpp
template <typename... Args>
class ClassName {
    // Variadic template definition
};
```

- `Args...` represents **a pack of types**.
- `sizeof...(Args)` gets the number of arguments.

### **Example: Variadic Function Template (Recursive Unpacking)**

✅ **Example:** A function template that prints multiple arguments.

```cpp
#include <iostream>
using namespace std;

// Base case: No arguments left to print
void print() {
    cout << "End of arguments." << endl;
}

// Variadic template function
template <typename First, typename... Rest>
void print(First first, Rest... rest) {
    cout << first << " ";
    print(rest...);  // Recursively call with remaining arguments
}

int main() {
    print(1, 2.5, "Hello", 'A');
}
```

**Output:**

```
1 2.5 Hello A End of arguments.
```

### **Example: Variadic Class Template**

✅ **Example:** A class template that stores a **tuple** of multiple types.

```cpp
#include <iostream>
#include <tuple>
using namespace std;

template <typename... Args>
class Data {
private:
    tuple<Args...> values;
public:
    Data(Args... args) : values(args...) {}

    void show() { cout << "Stored values in tuple!" << endl; }
};

int main() {
    Data<int, double, string> d(10, 3.14, "C++");
    d.show();
}
```

**Output:**

```
Stored values in tuple!
```

✅ **When to Use Variadic Templates?**

- When a **function/class** needs to handle **any number of parameters**.
- When designing **flexible, reusable** libraries.

---

**Key Points**

✅ **Template specialization** allows customizing templates for **specific data types**.  
✅ **Variadic templates** enable **handling multiple types dynamically**.  
✅ **Recursive unpacking** is a common technique for variadic functions.  
✅ **Use wisely** to balance flexibility and readability.

***

# Multithreading and Concurrency



---

# Debugging

**GDB (GNU Debugger)** is a powerful debugging tool commonly used for debugging C and C++ programs. It helps you control the execution of your program, set breakpoints, inspect variables, and trace program flow. Below is a comprehensive guide to using GDB for C++ debugging.

### 1. **Compiling with Debug Information**

Before you start debugging with GDB, compile your C++ program with the `-g` option to include debugging information.

```bash
g++ -g your_program.cpp -o your_program
```

### 2. **Starting GDB**

To start GDB, run:

```bash
gdb ./your_program
```

This will load the program into GDB. If you want to immediately start debugging with arguments:

```bash
gdb --args ./your_program arg1 arg2
```

### 3. **Basic Commands**

- **Run the program**:
  ```bash
  run [arguments]
  ```
  Starts executing your program. You can pass program arguments after `run`.

- **Breakpoints**:
  - **Set a breakpoint**:
    ```bash
    break main
    break 10  # Set breakpoint at line 10
    break your_function  # Set breakpoint at a function
    ```
  - **Delete a breakpoint**:
    ```bash
    delete 1  # Deletes the first breakpoint
    ```
  - **List all breakpoints**:
    ```bash
    info breakpoints
    ```
  - **Conditional breakpoints**:
    ```bash
    break 10 if i == 5
    ```

- **Continue execution**:
  ```bash
  continue
  ```
  Continues execution until the next breakpoint or program termination.

- **Step through code**:
  - **Step into a function**:
    ```bash
    step
    ```
  - **Step over a function** (i.e., execute it without stepping into it):
    ```bash
    next
    ```

- **Finish execution of a function**:
  ```bash
  finish
  ```
  This command allows you to run until the current function returns.

- **Exit GDB**:
  ```bash
  quit
  ```

### 4. **Inspecting Program State**

- **View variables**:
  - **Print a variable**:
    ```bash
    print variable_name
    ```
    Example:
    ```bash
    print i
    ```
  - **Print expression**:
    ```bash
    print 2 + 3
    ```
  - **Print value of `this` pointer in a class**:
    ```bash
    print *this
    ```

- **Examine memory**:
  - **Examine memory at a specific address**:
    ```bash
    x/nfu address
    ```
    where:
    - `n` is the number of units (optional)
    - `f` is the format (optional: `x` for hex, `d` for decimal, `s` for string, etc.)
    - `u` is the unit size (`b` for bytes, `h` for halfwords, `w` for words, etc.)

    Example:
    ```bash
    x/4xw &variable_name  # Examines memory for 4 words at variable address
    ```

- **Backtrace (show call stack)**:
  ```bash
  backtrace
  bt
  ```
  This shows the current function call stack, helping you understand how you arrived at the current point.

- **Frame switching**:
  - **Select a frame**:
    ```bash
    frame n  # Switch to frame number n
    ```
  - **Show the current frame**:
    ```bash
    info frame
    ```

### 5. **Advanced Features**

- **Watchpoints** (break on variable change):
  ```bash
  watch variable_name
  ```
  Stops execution when the variable is modified.

- **Conditional watchpoints**:
  ```bash
  watch variable_name if condition
  ```

- **Disassemble code**:
  ```bash
  disassemble function_name
  ```
  Shows the assembly code for a function.

- **TUI Mode** (Text User Interface for code and variables):
  ```bash
  gdb -tui ./your_program
  ```
  Or within GDB, press `Ctrl + X` followed by `A` to toggle TUI mode.

- **Set variable**:
  You can set the value of variables while debugging:
  ```bash
  set variable_name = value
  ```
  Example:
  ```bash
  set i = 10
  ```

### 6. **Debugging Optimized Code**

Optimized code can make debugging challenging. Variables might get optimized away or their values might not be what you expect. Compile your program with:

```bash
g++ -g -O1 your_program.cpp -o your_program
```

### 7. **Threads Debugging**

- **List threads**:
  ```bash
  info threads
  ```

- **Switch between threads**:
  ```bash
  thread thread_number
  ```

- **Breakpoints in threads**:
  ```bash
  break function_name thread thread_number
  ```

### 8. **Core Dumps**

If your program crashes and generates a core dump, you can use it to analyze the crash:

1. Enable core dumps (for Linux):
   ```bash
   ulimit -c unlimited
   ```
2. Run your program. If it crashes, a `core` file will be generated.
3. Debug using:
   ```bash
   gdb ./your_program core
   ```

### 9. **Scripting and Automation**

You can write GDB scripts to automate repetitive tasks. Here's an example of a simple GDB script (`debug.gdb`):

```bash
break main
run
backtrace
info locals
```

Run it as:

```bash
gdb -x debug.gdb ./your_program
```

### 10. **Common GDB Tips**

- **Show line numbers**:
  ```bash
  list  # Shows source code around the current line
  list 10  # Shows 10 lines of code starting from line 10
  ```

- **Debug shared libraries**:
  ```bash
  set follow-fork-mode child  # Debug child process (e.g., shared libraries)
  ```

- **Handling signals**:
  ```bash
  handle SIGSEGV stop  # Stop execution on a segmentation fault
  ```

**Summary of Key Commands**:

| Command               | Description                                           |
|-----------------------|-------------------------------------------------------|
| `break`               | Set a breakpoint                                      |
| `run`                 | Start program execution                               |
| `next`                | Step over function calls                              |
| `step`                | Step into function calls                              |
| `continue`            | Continue execution until the next breakpoint          |
| `print`               | Display variable or expression value                  |
| `backtrace` / `bt`    | Show current call stack                               |
| `watch`               | Stop execution when a variable changes                |
| `info`                | Get information (breakpoints, frames, variables, etc.)|

This should give you a solid foundation for debugging C++ programs using GDB. Let me know if you'd like examples for specific cases!

***
# Concepts

## Where Items Are Stored

In C++, different types of data and program components are stored in different areas of memory. Here’s a breakdown of where items are stored in a typical C++ program, covering compiled modules, registers, stack, and heap (free store):

### 1. **Compiled Modules**

- **Location**: On disk (e.g., in `.obj` or `.o` files for object code, `.exe` or `.out` files for executables).
- **Purpose**: Compiled modules contain machine code generated by the compiler from source code. They are not in memory during the compilation but are loaded into memory when the program is executed.
- **Contents**: They include compiled functions, global variables, static variables, and other symbols.

### 2. **Registers**

- **Location**: Inside the CPU.
- **Purpose**: Registers are used to hold temporary data and instructions while the CPU executes programs. They are the fastest storage available.
- **Types**:
  - **General-purpose registers**: Used for arithmetic, data manipulation, and addressing.
  - **Special-purpose registers**: Used for specific functions like program counters (PC), stack pointers (SP), and status registers.

**Example**:
```cpp
int add(int a, int b) {
    return a + b; // Registers hold the values of a, b, and the result during execution
}
```

### 3. **Stack**

- **Location**: A region of memory reserved for a program’s stack, managed by the operating system.
- **Purpose**: The stack is used for function call management, local variables, and storing return addresses. It operates in a Last In, First Out (LIFO) manner.
- **Characteristics**:
  - **Local Variables**: Variables declared inside functions are typically stored on the stack.
  - **Function Calls**: Includes the function parameters, return address, and local variables.
  - **Size**: Limited in size; excessive stack usage can lead to stack overflow.

**Example**:
```cpp
void func() {
    int x = 10; // Stored on the stack
    int y = 20;
}
```

### 4. **Heap (Free Store)**

- **Location**: A region of memory managed by the runtime system for dynamic memory allocation.
- **Purpose**: The heap is used for dynamic memory allocation, where the size and lifetime of data are determined at runtime.
- **Characteristics**:
  - **Dynamic Allocation**: Memory is allocated and deallocated explicitly using operators like `new` and `delete` (in C++), or functions like `malloc` and `free` (in C).
  - **Size**: Typically much larger than the stack; allows for large or dynamically sized data structures.
  - **Management**: Requires manual management of allocation and deallocation to avoid memory leaks and fragmentation.

**Example**:
```cpp
void createArray() {
    int* array = new int[100]; // Allocated on the heap
    // Use the array
    delete[] array; // Deallocated
}
```

**Summary**

- **Compiled Modules**: Stored on disk (e.g., in executable or object files) and loaded into memory when the program runs.
- **Registers**: Stored inside the CPU, used for fast temporary storage during execution.
- **Stack**: Managed by the OS for function calls, local variables, and execution context; has limited size.
- **Heap (Free Store)**: Managed by the runtime system for dynamic memory allocation; allows for large or variable-sized data.

***

## Duration of An Item

In C++, the duration of an item refers to the period during which a variable or object exists in memory and retains its value. There are three primary types of duration for items: global/static duration, local/automatic duration, and dynamic duration. Here’s a detailed explanation of each:

### 1. **Global/Static Duration**

**Definition:**
- Items with global or static duration are initialized when the program starts and destroyed when the program ends. Their lifespan extends throughout the entire execution of the program.

**Characteristics:**
- **Global Variables:** Declared outside of any function or class. They are accessible from any function or file (if declared with `extern`).
  
  **Example:**
  ```cpp
  int globalVar = 5; // Global variable with global duration

  void printGlobal() {
      std::cout << globalVar << std::endl; // Accesses the global variable
  }
  ```

- **Static Local Variables:** Declared inside a function with the `static` keyword. They retain their value between function calls.

  **Example:**
  ```cpp
  void counter() {
      static int count = 0; // Static local variable with static duration
      ++count;
      std::cout << count << std::endl;
  }
  ```

  In this example, `count` retains its value between calls to `counter`.

**Memory Location:**
- Stored in a specific area of memory, often called the data segment or BSS segment (for uninitialized static data).

### 2. **Local/Automatic Duration**

**Definition:**
- Items with local or automatic duration are created when a function is called and destroyed when the function exits. They only exist during the execution of the function or block in which they are defined.

**Characteristics:**
- **Local Variables:** Declared inside a function or block. They are created when the function/block is entered and destroyed when the function/block exits.

  **Example:**
  ```cpp
  void localDemo() {
      int localVar = 10; // Local variable with automatic duration
      std::cout << localVar << std::endl;
  }
  ```

  In this example, `localVar` is created when `localDemo` is called and destroyed when `localDemo` exits.

**Memory Location:**
- Stored on the stack. Each function call creates a new stack frame that holds these local variables.

### 3. **Dynamic Duration**

**Definition:**
- Items with dynamic duration are created and managed at runtime using dynamic memory allocation. They remain in memory until explicitly deallocated.

**Characteristics:**
- **Dynamic Allocation:** Memory is allocated using `new` (in C++) or `malloc` (in C). The allocated memory must be explicitly freed using `delete` (in C++) or `free` (in C).

  **Example:**
  ```cpp
  void dynamicDemo() {
      int* dynamicVar = new int; // Dynamic variable with dynamic duration
      *dynamicVar = 20;
      std::cout << *dynamicVar << std::endl;
      delete dynamicVar; // Explicitly deallocates memory
  }
  ```

  In this example, `dynamicVar` is created with `new` and its memory is released with `delete`.

**Memory Location:**
- Stored in the heap (free store). The heap is managed by the runtime system and can grow or shrink as needed, subject to system limits.

**Summary**

- **Global/Static Duration**: Variables are initialized at program start and destroyed at program end. They retain their value throughout the program's execution. Examples: global variables, static local variables.
- **Local/Automatic Duration**: Variables are created when a function is called and destroyed when the function exits. They exist only within the scope of the function or block. Examples: local variables.
- **Dynamic Duration**: Memory is allocated and managed explicitly at runtime. Variables persist until they are explicitly deallocated. Examples: dynamically allocated memory using `new` or `malloc`.

***
## Variable Scopes

In C++, the concept of scope refers to the region of a program where a particular identifier (e.g., variable or function name) is accessible. Different types of scopes control the visibility and lifetime of variables and functions. Here’s a detailed explanation of the various scopes in C++:

### 1. **File Scope**

**Definition:**
- File scope (also known as global scope) refers to the scope of identifiers declared outside of any functions or classes. These identifiers are accessible throughout the entire file in which they are declared and can be made accessible to other files using the `extern` keyword.

**Characteristics:**
- **Global Variables:** Variables declared outside of functions and classes.
- **Global Functions:** Functions declared outside of any class or function.

**Example:**
```cpp
// file1.cpp
int globalVar = 10; // File scope

void globalFunction() {
    // Can access globalVar
}
```

**Access from Other Files:**
```cpp
// file2.cpp
extern int globalVar; // Declaration of globalVar from file1.cpp

void anotherFunction() {
    // Can access globalVar
}
```

### 2. **Block Scope**

**Definition:**
- Block scope refers to identifiers declared inside a block of code enclosed by curly braces `{}`. These identifiers are only accessible within that block.

**Characteristics:**
- **Local Variables:** Variables declared inside a function or any block (e.g., loops, conditionals).
- **Parameters:** Parameters of functions and blocks have block scope.

**Example:**
```cpp
void exampleFunction() {
    int localVar = 5; // Block scope
    if (true) {
        int blockVar = 10; // Block scope
        // Can access localVar and blockVar
    }
    // Cannot access blockVar here
}
```

### 3. **Class Scope**

**Definition:**
- Class scope refers to identifiers declared within a class. These identifiers are accessible from within the class and its member functions.

**Characteristics:**
- **Member Variables:** Variables declared within a class.
- **Member Functions:** Functions declared within a class.
- **Access Specifiers:** Members can be public, protected, or private, affecting their accessibility.

**Example:**
```cpp
class MyClass {
public:
    int publicVar; // Class scope

private:
    int privateVar; // Class scope
    void privateMethod() { /*...*/ }
};
```

### 4. **Function Prototype Scope**

**Definition:**
- Function prototype scope refers to the scope within the prototype declaration of a function. It specifies the types of arguments and return type but does not define the function body.

**Characteristics:**
- **Function Parameters:** Variables declared within the function prototype.
- **Limited Scope:** The parameters are only visible within the function prototype.

**Example:**
```cpp
void myFunction(int a, double b); // Function prototype

// Parameters 'a' and 'b' are only visible in the function prototype
```

### 5. **Function Scope**

**Definition:**
- Function scope refers to identifiers declared within a function. These variables are only accessible within that function.

**Characteristics:**
- **Function Local Variables:** Variables declared inside the function body.
- **Function Parameters:** Parameters of the function are also in function scope.

**Example:**
```cpp
void myFunction(int a) {
    int localVar = 5; // Function scope
    // Can access a and localVar
    // Cannot access a or localVar outside this function
}
```

**Summary**

- **File Scope**: Identifiers declared outside functions and classes, accessible throughout the file and potentially across files (with `extern`).
- **Block Scope**: Identifiers declared within a block of code (e.g., inside a function or loop), accessible only within that block.
- **Class Scope**: Identifiers declared within a class, accessible within the class and its member functions, subject to access specifiers.
- **Function Prototype Scope**: The scope within the function prototype; parameters are visible only in the prototype.
- **Function Scope**: Identifiers declared within a function, accessible only within that function.

***

## Stack vs Heap

The stack and the heap are both regions of memory used for different purposes in a program. 

**Stack:**

- **Automatic Memory Allocation**: Memory allocated on the stack is automatically managed by the compiler.
- **Faster Access**: Access to stack memory is typically faster than access to heap memory because it follows a strict last-in-first-out (LIFO) order.
- **Limited Size**: The stack size is usually limited, and exceeding this limit can result in a stack overflow error.
- **Static Memory Allocation**: Memory allocation and deallocation on the stack happen at compile time.
- **Scope-bound Lifetime**: Variables declared on the stack have a scope-bound lifetime, meaning they exist only within the scope in which they are declared.
- **Local Variables**: Function parameters and local variables are typically stored on the stack.

**Heap:**

- **Dynamic Memory Allocation**: Memory allocated on the heap is managed manually by the programmer.
- **Slower Access**: Access to heap memory is generally slower than access to stack memory due to dynamic memory management overhead.
- **No Size Limitation**: The heap size is limited only by the available system memory.
- **Dynamic Memory Allocation**: Memory allocation and deallocation on the heap happen at runtime using functions like `malloc()` and `free()` (in C) or `new` and `delete` (in C++).
- **Flexible Lifetime**: Variables allocated on the heap have a flexible lifetime and can exist beyond the scope in which they were created.
- **Global Variables and Objects**: Objects and variables with dynamic lifetimes, such as objects created with `new` in C++ or dynamically allocated arrays, are typically stored on the heap.

**Choosing Between Stack and Heap:**

- **Use Stack for**:
  - Variables with known and limited lifetimes.
  - Variables whose lifetimes are determined by the scope in which they are declared.
- **Use Heap for**:
  - Objects with dynamic lifetimes, such as objects created during program execution.
  - Objects that need to be accessed beyond the scope in which they are created.
- **Considerations**: Choose the appropriate memory allocation method based on the scope, lifetime, and size requirements of your variables and objects.


***

## Static vs Dynamic Allocation

Static and dynamic allocation are two approaches to memory allocation in programming.

**Static Allocation:**

- **Memory Allocation at Compile Time**: Memory for variables is allocated at compile time.
- **Deterministic Lifetime**: Variables allocated statically have a fixed lifetime determined by the scope in which they are defined.
- **Limited Flexibility**: Size and number of statically allocated variables must be known at compile time.
- **Example**: Arrays, global variables, and variables declared with the `static` keyword in C/C++ are allocated statically.

**Dynamic Allocation:**

- **Memory Allocation at Runtime**: Memory for variables is allocated and deallocated at runtime.
- **Dynamic Lifetime**: Variables allocated dynamically have a flexible lifetime and can be created and destroyed as needed during program execution.
- **Flexibility**: Dynamic allocation allows for allocating memory based on runtime conditions and data requirements.
- **Memory Management Overhead**: Dynamic allocation requires explicit memory management using functions like `malloc()` and `free()` in C or `new` and `delete` in C++.
- **Potential for Memory Leaks and Dangling Pointers**: Improper use of dynamic memory allocation can lead to memory leaks and dangling pointers if not managed correctly.

**Use Cases:**

- **Static Allocation**:
  - Use for variables with fixed size and known lifetime.
  - Suitable for variables with a limited scope and predictable lifetime.
- **Dynamic Allocation**:
  - Use when the size or lifetime of variables cannot be determined at compile time.
  - Suitable for data structures like linked lists, trees, and dynamic arrays.
  - Useful for managing resources with variable lifetimes, such as objects created during program execution.

**Example (Dynamic Allocation in C++):**

```cpp
int* dynamicArray = new int[10]; // Dynamically allocated array of integers
// Use dynamicArray...
delete[] dynamicArray; // Deallocate memory when no longer needed
```

In this example, memory for the array is allocated dynamically at runtime using the `new` keyword. The memory is deallocated using `delete[]` when it's no longer needed.

**Considerations:**

- **Resource Management**: With dynamic allocation, it's essential to manage memory properly to avoid memory leaks and undefined behavior.
- **Performance**: Dynamic allocation may incur overhead due to memory management operations and fragmentation.
- **Flexibility**: Dynamic allocation offers flexibility in managing memory based on runtime conditions but requires careful handling to avoid issues like memory leaks and buffer overflows.


## Atomic Operations

Atomic operations in C++ are operations that are guaranteed to be indivisible and uninterruptible by other threads or processes. These operations ensure that when multiple threads are accessing or modifying a shared variable concurrently, the result is as if the operations occurred sequentially without interference from other threads.

**Examples of Atomic Operations in C++:**

1. **Atomic Load (`std::atomic_load`)**:
   - Atomically loads the current value of an atomic variable.
   
   ```cpp
   std::atomic<int> atomicVar(42);
   int value = std::atomic_load(&atomicVar);
   ```

2. **Atomic Store (`std::atomic_store`)**:
   - Atomically stores a new value into an atomic variable.
   
   ```cpp
   std::atomic<int> atomicVar;
   std::atomic_store(&atomicVar, 42);
   ```

3. **Atomic Exchange (`std::atomic_exchange`)**:
   - Atomically swaps the value of an atomic variable with a new value and returns the old value.
   
   ```cpp
   std::atomic<int> atomicVar(42);
   int oldValue = std::atomic_exchange(&atomicVar, 10);
   ```

4. **Atomic Compare-and-Exchange (`std::atomic_compare_exchange_weak` and `std::atomic_compare_exchange_strong`)**:
   - Atomically compares the value of an atomic variable with an expected value and exchanges it with a new value if the comparison succeeds.
   
   ```cpp
   std::atomic<int> atomicVar(42);
   int expected = 42;
   int newValue = 10;
   bool success = atomicVar.compare_exchange_weak(expected, newValue);
   ```

5. **Atomic Fetch-and-Add (`std::atomic_fetch_add`)**:
   - Atomically adds a value to the current value of an atomic variable and returns the old value.
   
   ```cpp
   std::atomic<int> atomicVar(42);
   int oldValue = std::atomic_fetch_add(&atomicVar, 5);
   ```

6. **Atomic Increment and Decrement (`std::atomic_fetch_add` and `std::atomic_fetch_sub`)**:
   - Atomically increments or decrements the value of an atomic variable by a specified amount and returns the old value.
   
   ```cpp
   std::atomic<int> atomicVar(42);
   int oldValue = std::atomic_fetch_add(&atomicVar, 1); // Increment
   int oldValue = std::atomic_fetch_sub(&atomicVar, 1); // Decrement
   ```

**Benefits of Atomic Operations:**

- Ensure thread safety and prevent data races in concurrent programs.
- Guarantee consistency and correctness when multiple threads access shared data.
- Offer performance benefits over traditional locking mechanisms in certain scenarios with low contention.

When working with multithreaded programs, atomic operations provide a powerful and efficient way to synchronize access to shared variables without the need for explicit locking. However, it's essential to use them correctly and understand their behavior to avoid subtle concurrency bugs.

---

## **RAII (Resource Acquisition Is Initialization) in C++**

### **What is RAII?**

RAII (**Resource Acquisition Is Initialization**) is a **C++ memory management** technique that ensures resources (memory, file handles, sockets, etc.) are **acquired in a constructor** and **automatically released in a destructor**.

RAII is primarily used to prevent **resource leaks** and enforce **exception safety** by **binding resource lifetimes to object lifetimes**.

---

### **How RAII Works**

RAII relies on **constructor/destructor pairs**:

- The **constructor** acquires the resource (e.g., allocates memory, opens a file).
- The **destructor** releases the resource (e.g., deallocates memory, closes a file).

Since **C++ automatically calls destructors when objects go out of scope**, this ensures that resources are properly released.

---

### **Example: Managing Dynamic Memory (Without RAII vs. With RAII)**

#### **❌ Without RAII (Memory Leak Risk)**

```cpp
#include <iostream>
using namespace std;

void allocateMemory() {
    int* arr = new int[10];  // Dynamically allocated array
    // ❌ No delete[] call → Memory Leak!
}

int main() {
    allocateMemory();
    return 0;  // Memory leak occurs!
}
```

- The `new` operator allocates memory, but since there's **no `delete[]` call**, the memory is **never freed**, causing a **leak**.

---

#### **✅ With RAII (Using a Smart Pointer)**

```cpp
#include <iostream>
#include <memory>  // For smart pointers
using namespace std;

void allocateMemory() {
    unique_ptr<int[]> arr = make_unique<int[]>(10);  // Automatically freed!
}

int main() {
    allocateMemory();  // No memory leak
    return 0;
}
```

- **`unique_ptr`** automatically releases memory when it goes out of scope.
- **No need** for manual `delete[]`.
- **Prevents memory leaks**.

---

### **RAII in File Handling**

#### **❌ Without RAII (File Not Closed Properly)**

```cpp
#include <iostream>
#include <fstream>
using namespace std;

void writeFile() {
    ofstream file("example.txt");
    if (!file.is_open()) {
        cout << "Failed to open file!" << endl;
        return;
    }
    file << "Hello, RAII!";
    // ❌ If an exception occurs, the file might not be closed properly!
}

int main() {
    writeFile();
    return 0;
}  // File may not close properly in case of an error!
```

---

#### **✅ With RAII (Using fstream)**

```cpp
#include <iostream>
#include <fstream>
using namespace std;

void writeFile() {
    ofstream file("example.txt");  // RAII handles file opening
    if (!file) {
        cout << "Failed to open file!" << endl;
        return;
    }
    file << "Hello, RAII!";  
}  // File automatically closed when going out of scope

int main() {
    writeFile();
    return 0;
}
```

- **`ofstream` automatically closes the file** when `file` goes out of scope.
- Prevents **file resource leaks**.

---

### **Implementing a Custom RAII Wrapper Class**

RAII can be implemented with **custom classes** that handle resources.

**Example: Managing Dynamic Memory with RAII**

```cpp
#include <iostream>
using namespace std;

class RAII_Array {
private:
    int* data;

public:
    // Constructor: Acquires resource
    RAII_Array(int size) {
        data = new int[size];
        cout << "Memory allocated!" << endl;
    }

    // Destructor: Releases resource
    ~RAII_Array() {
        delete[] data;
        cout << "Memory freed!" << endl;
    }
};

int main() {
    {
        RAII_Array arr(10);  // Memory allocated
    }  // Memory freed when arr goes out of scope

    return 0;
}
```

**Output:**

```
Memory allocated!
Memory freed!
```

- **Automatic memory cleanup** when the object goes out of scope.
- **No need** to manually delete the array.

---

### **RAII and Smart Pointers**

Modern C++ provides **smart pointers (`unique_ptr`, `shared_ptr`)** that use RAII for **safe resource management**.

**Example: Using `unique_ptr`**

```cpp
#include <iostream>
#include <memory>
using namespace std;

void useSmartPointer() {
    unique_ptr<int> ptr = make_unique<int>(100);
    cout << "Value: " << *ptr << endl;
}  // Automatically freed here!

int main() {
    useSmartPointer();
    return 0;
}
```

- **No manual `delete` required**.
- **Ensures proper cleanup**.

---

**Key Benefits of RAII**

✅ **Automatic resource management** (prevents memory leaks).  
✅ **Exception safety** (destructors are always called).  
✅ **Simplifies code** (no need for explicit `delete` calls).  
✅ **Works with multiple resource types** (memory, files, sockets).

---

## **Object Pooling**

**Object pooling** is a **design pattern** that helps manage objects efficiently by **reusing** them instead of creating and destroying them repeatedly. It is useful when object creation is expensive in terms of time or memory.

---

### **How Object Pooling Works**

1. **Preallocate** a set of objects in a pool.
2. **Reuse objects** from the pool instead of creating new ones.
3. **Return objects** to the pool after use.
4. **Efficient memory usage** and **faster performance** since objects are not frequently allocated and deallocated.

---

### **Example: Object Pool for Database Connections**

✅ **Example:** A simple object pool that manages database connections.

```cpp
#include <iostream>
#include <vector>
using namespace std;

class Connection {
public:
    Connection() { cout << "Connection Created\n"; }
    void use() { cout << "Using Connection\n"; }
};

class ConnectionPool {
private:
    vector<Connection*> pool;
public:
    ConnectionPool(int size) {
        for (int i = 0; i < size; ++i)
            pool.push_back(new Connection());
    }

    Connection* acquire() {
        if (!pool.empty()) {
            Connection* conn = pool.back();
            pool.pop_back();
            return conn;
        }
        return new Connection(); // Create a new one if pool is empty
    }

    void release(Connection* conn) {
        pool.push_back(conn);
    }

    ~ConnectionPool() {
        for (auto conn : pool) delete conn;
    }
};

int main() {
    ConnectionPool pool(2);

    Connection* c1 = pool.acquire();
    c1->use();

    Connection* c2 = pool.acquire();
    c2->use();

    pool.release(c1);
    pool.release(c2);

    Connection* c3 = pool.acquire();
    c3->use();  // Reuses a previously released connection

    return 0;
}
```

**Output:**

```
Connection Created
Connection Created
Using Connection
Using Connection
Using Connection
```

---

**Key Points**

✅ **Object pooling** improves performance by reusing objects.  
✅ **Preallocating** objects reduces memory allocation overhead.  
✅ **Returning objects** to the pool prevents frequent destruction and recreation.  
✅ Useful for **database connections, thread pools, game objects, network sockets, etc.**

---

## **Move Semantics and Rvalue References**

**Move semantics** optimize performance by **avoiding deep copies** when transferring ownership of resources. This is done using **rvalue references (`&&`)**, which allow **moving** instead of copying objects.

---

## **Rvalue References (`&&`)**

An **rvalue reference** allows binding to **temporary objects** (rvalues), enabling efficient resource transfers.

✅ **Example: Binding Rvalue References**

```cpp
#include <iostream>
using namespace std;

void func(int& x) { cout << "Lvalue reference\n"; }
void func(int&& x) { cout << "Rvalue reference\n"; }

int main() {
    int a = 10;
    func(a);     // Calls lvalue reference overload
    func(20);    // Calls rvalue reference overload
}
```

**Output:**

```
Lvalue reference
Rvalue reference
```

🔹 `int&` binds to **lvalues** (named variables).  
🔹 `int&&` binds to **rvalues** (temporary values like `20`).

---

## **Move Constructor and Move Assignment Operator**

Move semantics **transfer ownership** of resources instead of copying them. This is useful in **resource-intensive** operations (e.g., dynamic memory, file handles).

### **Move Constructor (`T(T&&)`)**

Moves resources from a temporary object, leaving the source in a valid but unspecified state.

### **Move Assignment (`operator=(T&&)`)**

Transfers resources from an existing object to another, avoiding deep copies.

✅ **Example: Move Semantics in Action**

```cpp
#include <iostream>
#include <cstring>
using namespace std;

class String {
private:
    char* data;
public:
    String(const char* str) {  // Constructor
        data = new char[strlen(str) + 1];
        strcpy(data, str);
        cout << "Created: " << data << endl;
    }

    // Move Constructor
    String(String&& other) noexcept {
        data = other.data;
        other.data = nullptr;
        cout << "Moved\n";
    }

    // Move Assignment Operator
    String& operator=(String&& other) noexcept {
        if (this != &other) {
            delete[] data;  // Clean up existing resource
            data = other.data;
            other.data = nullptr;
            cout << "Moved via Assignment\n";
        }
        return *this;
    }

    void show() { cout << (data ? data : "Empty") << endl; }

    ~String() { delete[] data; }
};

int main() {
    String s1("Hello");
    String s2 = move(s1); // Move Constructor
    s2.show();
    s1.show();  // Should be empty

    String s3("World");
    s3 = move(s2);  // Move Assignment
    s3.show();
    s2.show();  // Should be empty

    return 0;
}
```

**Output:**

```
Created: Hello
Moved
Hello
Empty
Created: World
Moved via Assignment
Hello
Empty
```

---

**Key Points**

✅ **Rvalue references (`&&`)** enable moving instead of copying.  
✅ **Move constructor (`T(T&&)`)** transfers ownership of resources.  
✅ **Move assignment operator (`operator=(T&&)`)** moves an existing object’s resources.  
✅ **Use `std::move(obj)`** to convert an lvalue into an rvalue for moving.


---

# Advanced

## Limiting Struct Sizes

Yes, there are several ways to limit the size of a `struct` in C++ beyond using bit-fields. Here are some techniques:

### 1. **Align and Pack the Structure**
   - **Problem:** By default, C++ may add padding between members of a `struct` to ensure proper alignment for the CPU architecture, which can increase the size of the `struct`.
   - **Solution:** Use compiler-specific directives to control the alignment and packing of the `struct`, which can reduce its size.
   - **Example (using GCC or Clang):**
     ```cpp
     struct __attribute__((packed)) MyStruct {
         char a;
         int b;
         short c;
     };
     ```
     - The `packed` attribute removes any padding, aligning the structure tightly.

   - **Example (using MSVC):**
     ```cpp
     #pragma pack(push, 1)
     struct MyStruct {
         char a;
         int b;
         short c;
     };
     #pragma pack(pop)
     ```
     - The `#pragma pack(push, 1)` directive forces the compiler to align the structure members on 1-byte boundaries, minimizing padding.

   - **Caution:** Removing padding can lead to inefficient memory access on some architectures, as misaligned data can be slower to access.

### 2. **Rearrange Structure Members**
   - **Problem:** The order of members in a `struct` can impact its size due to alignment requirements.
   - **Solution:** Rearrange members to minimize padding.
   - **Example:**
     ```cpp
     struct MyStruct {
         char a;
         short b;
         int c;
     };
     ```
     - This might have padding between `a` and `b` or `b` and `c`. You can rearrange it as:
     ```cpp
     struct MyStruct {
         int c;
         short b;
         char a;
     };
     ```
     - This order might reduce padding depending on the architecture, reducing the overall size.

### 3. **Use Smaller Data Types**
   - **Problem:** Larger data types occupy more space.
   - **Solution:** Use the smallest appropriate data type for each member.
   - **Example:**
     ```cpp
     struct MyStruct {
         uint8_t smallValue;  // Instead of int or char, use a smaller type
         uint16_t mediumValue;
     };
     ```
     - Using `uint8_t` (1 byte) instead of `int` (typically 4 bytes) for a small number can reduce the size of the `struct`.

### 4. **Use Unions**
   - **Problem:** Sometimes, multiple members of a `struct` are never used simultaneously, but they take up space.
   - **Solution:** Use a `union` inside the `struct` to overlap members that are mutually exclusive.
   - **Example:**
     ```cpp
     struct MyStruct {
         char type;
         union {
             int intValue;
             float floatValue;
         };
     };
     ```
     - The `union` allows `intValue` and `floatValue` to share the same memory, reducing the overall size of the `struct`.

### 5. **Eliminate Unnecessary Members**
   - **Problem:** Including more members than needed increases the size.
   - **Solution:** Remove or combine unnecessary members.
   - **Example:**
     ```cpp
     struct MyStruct {
         bool flag;
         bool anotherFlag;
         // Instead of two bools, use a single byte and bitwise operations to store flags
         char flags;
     };
     ```
     - Combining multiple `bool` members into a single `char` or `int` using bitwise operations can save space.

### 6. **Use `std::bitset`**
   - **Problem:** Storing multiple boolean flags individually can waste space.
   - **Solution:** Use `std::bitset` to pack multiple boolean values into a single integer.
   - **Example:**
     ```cpp
     #include <bitset>

     struct MyStruct {
         std::bitset<8> flags;  // Stores up to 8 boolean flags in a single byte
     };
     ```
     - `std::bitset` can pack multiple flags into a single integer, reducing the overall size of the `struct`.

### 7. **Use Dynamic Memory Allocation**
   - **Problem:** Large or optional members increase the size of the `struct`.
   - **Solution:** Use pointers to dynamically allocate memory only when needed.
   - **Example:**
     ```cpp
     struct MyStruct {
         int essentialValue;
         int* optionalArray;  // Dynamically allocate memory for this only if needed
     };
     ```
     - The `optionalArray` pointer only takes up the space of a pointer, and the actual memory for the array is allocated dynamically if necessary, potentially reducing the size of the `struct`.

### 8. **Use Empty Base Class Optimization (EBO)**
   - **Problem:** Inheritance from an empty base class can still take up space.
   - **Solution:** Use EBO, where some compilers optimize away the space taken by empty base classes.
   - **Example:**
     ```cpp
     struct Empty {};

     struct MyStruct : Empty {
         int value;
     };
     ```
     - The compiler can optimize away the space for `Empty`, so it doesn’t increase the size of `MyStruct`.

# Other Features (Miscellaneous)

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
## `static` Keyword

In C++, the `static` keyword has multiple uses, each affecting different aspects of variable and function storage, lifetime, and visibility. Here’s a detailed explanation of the different uses of `static`:

### 1. **Static Variables in Functions**

**Definition:**
- A static variable inside a function retains its value between function calls. It is initialized only once and exists for the lifetime of the program.

**Characteristics:**
- **Lifetime:** Exists from the first time it is initialized until the end of the program.
- **Visibility:** Only visible within the function where it is declared.

**Example:**
```cpp
void counter() {
    static int count = 0; // Static local variable
    ++count;
    std::cout << count << std::endl;
}
```

**Behavior:**
- The `count` variable retains its value between calls to `counter()`. Each call to `counter()` increments `count` from its previous value.

### 2. **Static Variables in Classes**

**Definition:**
- A static member variable of a class is shared among all instances of that class. It is not tied to any specific object.

**Characteristics:**
- **Lifetime:** Exists for the lifetime of the program, similar to global variables.
- **Visibility:** Can be accessed using the class name or an object of the class.

**Example:**
```cpp
class MyClass {
public:
    static int staticVar; // Static member variable
};

// Definition outside the class
int MyClass::staticVar = 0;

void updateStaticVar() {
    MyClass::staticVar = 5; // Accessed using the class name
}
```

**Behavior:**
- `staticVar` is shared across all instances of `MyClass` and can be accessed using the class name or any instance of the class.

### 3. **Static Member Functions in Classes**

**Definition:**
- A static member function belongs to the class rather than any specific object. It can only access static member variables and functions.

**Characteristics:**
- **Lifetime:** Exists for the lifetime of the program.
- **Visibility:** Can be called using the class name without needing an instance.

**Example:**
```cpp
class MyClass {
public:
    static void staticMethod() {
        std::cout << "Static method called" << std::endl;
    }
};

void callStaticMethod() {
    MyClass::staticMethod(); // Call using the class name
}
```

**Behavior:**
- `staticMethod` can be called without creating an instance of `MyClass`.

### 4. **Static Variables in Global Scope (File Scope)**

**Definition:**
- A global variable or function declared with `static` is restricted to the file in which it is declared. It is not visible outside of that file, providing internal linkage.

**Characteristics:**
- **Lifetime:** Exists for the lifetime of the program.
- **Visibility:** Limited to the file where it is declared, preventing name conflicts with global variables or functions in other files.

**Example:**
```cpp
// file1.cpp
static int fileVar = 10; // Static global variable

void fileFunction() {
    // Can access fileVar
}

// file2.cpp
extern void fileFunction(); // Declaration only
```

**Behavior:**
- `fileVar` in `file1.cpp` is not visible to `file2.cpp`, preventing potential conflicts.

**Summary**

- **Static Variables in Functions**: Retain their value across function calls and are only visible within the function.
- **Static Variables in Classes**: Shared among all instances of the class and accessible using the class name or an object.
- **Static Member Functions**: Belong to the class rather than any instance and can only access static members of the class.
- **Static Variables in Global Scope**: Have file scope, preventing visibility and linkage outside the file in which they are declared.

***

## `friend` Keyword

In C++, the `friend` keyword allows certain functions or classes to access private and protected members of a class. It is used to grant special access privileges that are not normally available to non-member functions or classes. Here’s a detailed explanation of the `friend` keyword:

### Characteristics of Friend Functions and Classes

1. **Friend Functions**

   **Definition:**
   - A function declared as a `friend` within a class can access the private and protected members of that class, even though it is not a member of the class.

   **Declaration:**
   ```cpp
   class MyClass {
   private:
       int privateValue;

   public:
       MyClass() : privateValue(0) {}
       // Friend function declaration
       friend void friendFunction(MyClass&);
   };
   
   // Friend function definition
   void friendFunction(MyClass& obj) {
       obj.privateValue = 10; // Can access privateValue because it's a friend
   }
   ```

   **Usage:**
   - **Access Privilege:** The friend function has access to the class’s private and protected members.
   - **Scope:** Friend functions are not member functions and do not have `this` pointers.

2. **Friend Classes**

   **Definition:**
   - A class declared as a `friend` of another class can access its private and protected members.

   **Declaration:**
   ```cpp
   class MyClass {
   private:
       int privateValue;

   public:
       MyClass() : privateValue(0) {}
       // Friend class declaration
       friend class FriendClass;
   };
   
   class FriendClass {
   public:
       void modifyValue(MyClass& obj) {
           obj.privateValue = 10; // Can access privateValue because FriendClass is a friend
       }
   };
   ```

   **Usage:**
   - **Access Privilege:** All member functions of the friend class can access the private and protected members of the class.
   - **Scope:** Friend classes are not members of the class they are friends with, but they are granted special access.

3. **Friend Functions in a Namespace**

   **Definition:**
   - Friend functions can also be declared within namespaces to provide access to private and protected members.

   **Declaration:**
   ```cpp
   namespace MyNamespace {
       class MyClass {
       private:
           int privateValue;

       public:
           MyClass() : privateValue(0) {}
           // Friend function declaration within the namespace
           friend void friendFunction(MyClass&);
       };

       void friendFunction(MyClass& obj) {
           obj.privateValue = 10; // Can access privateValue because it's a friend
       }
   }
   ```

   **Usage:**
   - **Access Privilege:** Same as with friend functions in a class; they can access private and protected members.

4. **Friend Member Functions**

   **Definition:**
   - A specific member function of another class can be granted friend status, allowing it to access private and protected members of the class.

   **Declaration:**
   ```cpp
   class MyClass {
   private:
       int privateValue;

   public:
       MyClass() : privateValue(0) {}

       // Friend member function of another class
       friend class FriendClass;
   };

   class FriendClass {
   public:
       void modifyValue(MyClass& obj) {
           obj.privateValue = 10; // Can access privateValue because of friend status
       }
   };
   ```

   **Usage:**
   - **Access Privilege:** The friend member function of another class can access private and protected members of the class.

**Key Points**

- **Friendship is not Inheritance:** Being a friend does not imply an inheritance relationship. Friendship is not transitive or inheritable.
- **Encapsulation and Design:** Using friends should be done carefully to avoid breaking encapsulation principles. It is often used to simplify access between classes or functions that are closely related.
- **Declaration vs. Definition:** Friend functions or classes must be declared within the class whose members they are allowed to access. The definition can be outside the class.

**Summary**

- **`friend` Keyword:** Allows non-member functions or classes to access private and protected members of a class.
- **Friend Functions:** Can access private and protected members of the class where they are declared as friends.
- **Friend Classes:** All member functions of a friend class can access private and protected members of the class.
- **Friend Functions in Namespaces:** Similar access privileges within the namespace.

---

# Competitive Programming Techniques

## **Dynamic Programming**

**Dynamic Programming (DP)** is an **optimization technique** used to solve problems by **breaking them down into smaller subproblems** and storing their results to avoid redundant computations. It is commonly used in **combinatorics, optimization, and graph problems**.

---

### **Types of Dynamic Programming**

1. **Top-Down (Memoization)** – Solving problems recursively while storing results.
2. **Bottom-Up (Tabulation)** – Iteratively solving subproblems and building up the final solution.

---

### **Top-Down Approach (Memoization)**

Uses **recursion + caching** to avoid recomputation.

✅ **Example: Fibonacci Sequence using Memoization**

```cpp
#include <iostream>
#include <vector>
using namespace std;

vector<int> memo(100, -1); // Initialize cache with -1

int fib(int n) {
    if (n <= 1) return n;
    if (memo[n] != -1) return memo[n]; // Return cached result
    return memo[n] = fib(n - 1) + fib(n - 2);
}

int main() {
    cout << "Fibonacci(10): " << fib(10) << endl;
    return 0;
}
```

**Output:**

```
Fibonacci(10): 55
```

🔹 Stores computed values to prevent redundant recursive calls.

---

### **Bottom-Up Approach (Tabulation)**

Uses **iteration** to build solutions from smaller subproblems.

✅ **Example: Fibonacci using Tabulation**

```cpp
#include <iostream>
using namespace std;

int fib(int n) {
    int dp[100] = {0, 1}; // Base cases
    for (int i = 2; i <= n; ++i)
        dp[i] = dp[i - 1] + dp[i - 2];
    return dp[n];
}

int main() {
    cout << "Fibonacci(10): " << fib(10) << endl;
    return 0;
}
```

**Output:**

```
Fibonacci(10): 55
```

🔹 Builds results iteratively, avoiding recursion overhead.

---

### **Optimized Space Complexity**

We only need the last two Fibonacci numbers instead of storing the entire array.

✅ **Example: Fibonacci with O(1) Space Complexity**

```cpp
#include <iostream>
using namespace std;

int fib(int n) {
    if (n <= 1) return n;
    int a = 0, b = 1, c;
    for (int i = 2; i <= n; ++i) {
        c = a + b;
        a = b;
        b = c;
    }
    return b;
}

int main() {
    cout << "Fibonacci(10): " << fib(10) << endl;
    return 0;
}
```

🔹 Uses **constant space (`O(1)`)** instead of storing all values.

---

### **Common Problems Solved Using DP**

✅ **Knapsack Problem**  
✅ **Longest Common Subsequence (LCS)**  
✅ **Longest Increasing Subsequence (LIS)**  
✅ **Coin Change Problem**  
✅ **Matrix Chain Multiplication**

---

# Best Practices and Code Optimization

## **Effective Debugging Techniques**

Debugging is a crucial skill for every programmer. Efficient debugging helps identify and fix errors quickly, improving code quality and performance.

---

### **1. Understanding the Problem**

✅ **Reproduce the issue** – Find the exact input or conditions that trigger the bug.  
✅ **Read error messages carefully** – They often provide hints about the issue.  
✅ **Check the logic flow** – Trace the expected vs. actual execution.

---

### **2. Using Debugging Tools**

✅ **GDB (GNU Debugger) for C++**

- Set breakpoints, inspect variables, and step through code.
- Example usage:
    
    ```sh
    g++ -g program.cpp -o program
    gdb ./program
    ```
    
- Inside GDB:
    
    ```
    break main      # Set a breakpoint at main
    run            # Start the program
    next           # Execute next line
    print varName  # Print variable value
    ```
    

✅ **IDE Debuggers (Visual Studio, CLion, Code::Blocks)**

- Allow breakpoints, stepping, and variable inspection.
- Visual representation of call stack and memory.

✅ **Valgrind (for Memory Issues)**

- Detects memory leaks and invalid accesses.
- Usage:
    
    ```sh
    valgrind --leak-check=full ./program
    ```
    

---

### **3. Print Debugging (Logging Output)**

✅ **Use `std::cout` to track execution flow and variable values**

```cpp
cout << "Debug: x = " << x << endl;
```

✅ **Use `cerr` for errors (stderr)**

```cpp
cerr << "Error: Invalid input" << endl;
```

✅ **Format logs clearly**

```cpp
cout << "[INFO] Loop iteration " << i << ", Value: " << arr[i] << endl;
```

---

### **4. Analyzing Core Dumps**

If a program crashes, analyzing a **core dump** can help.

```sh
ulimit -c unlimited  # Enable core dump
gdb ./program core   # Analyze core dump
```

---

### **5. Checking for Undefined Behavior**

✅ **Enable compiler warnings**

```sh
g++ -Wall -Wextra -Werror program.cpp
```

✅ **Use AddressSanitizer for runtime checks**

```sh
g++ -fsanitize=address -g program.cpp -o program
./program
```

---

### **6. Step-by-Step Debugging Approach**

✅ **Simplify the problem** – Isolate the issue by testing small code blocks.  
✅ **Use assertions**

```cpp
#include <cassert>
assert(x > 0 && "x should be positive");
```

✅ **Check edge cases** – Test boundary conditions.

---

### **7. Code Review and Rubber Duck Debugging**

✅ **Explain the code to someone (or even a rubber duck!)** – This helps in spotting mistakes.  
✅ **Take a break and revisit later** – Fresh eyes often catch errors.

---

## **Avoiding Memory Leaks and Undefined Behavior**

Memory management is critical in C++. Failing to handle memory properly can lead to **memory leaks, dangling pointers, and undefined behavior**, causing crashes or unpredictable program execution.

---

### **1. Preventing Memory Leaks**

A **memory leak** occurs when dynamically allocated memory is not released, leading to increasing memory usage over time.

✅ **Always `delete` dynamically allocated memory**

```cpp
int* ptr = new int(10);
delete ptr;  // Free the memory
ptr = nullptr;  // Avoid dangling pointer
```

✅ **Use Smart Pointers (`std::unique_ptr`, `std::shared_ptr`)**  
Smart pointers **automatically manage memory** and prevent leaks.

```cpp
#include <memory>
std::unique_ptr<int> ptr = std::make_unique<int>(10);  // No manual delete needed
```

✅ **Avoid memory leaks in loops**

```cpp
for (int i = 0; i < 100; i++) {
    int* ptr = new int(10);
    delete ptr;  // Free memory inside loop
}
```

✅ **Use `valgrind` to detect leaks**

```sh
valgrind --leak-check=full ./program
```

---

### **2. Avoiding Dangling Pointers**

A **dangling pointer** points to memory that has been freed.

❌ **Incorrect Usage**

```cpp
int* ptr = new int(10);
delete ptr;  // Memory freed
cout << *ptr;  // Undefined behavior! Accessing freed memory
```

✅ **Solution: Set pointers to `nullptr` after `delete`**

```cpp
int* ptr = new int(10);
delete ptr;
ptr = nullptr;  // Safe to check later
```

✅ **Use Smart Pointers** – They automatically clean up memory.

---

### **3. Avoiding Double `delete`**

Calling `delete` twice on the same pointer leads to **undefined behavior**.

❌ **Incorrect Usage**

```cpp
int* ptr = new int(10);
delete ptr;
delete ptr;  // ERROR: Double delete!
```

✅ **Solution: Set pointer to `nullptr`**

```cpp
int* ptr = new int(10);
delete ptr;
ptr = nullptr;  // Second delete has no effect
```

---

### **4. Avoiding Use of Uninitialized Pointers**

❌ **Incorrect Usage**

```cpp
int* ptr;  // Uninitialized
*ptr = 10;  // Undefined behavior
```

✅ **Solution: Initialize pointers**

```cpp
int* ptr = nullptr;
```

---

### **5. Preventing Buffer Overflows and Array Out-of-Bounds Access**

❌ **Incorrect Usage**

```cpp
int arr[5] = {1, 2, 3, 4, 5};
cout << arr[10];  // ERROR: Accessing out of bounds!
```

✅ **Solution: Use `std::vector` for safety**

```cpp
#include <vector>
std::vector<int> vec = {1, 2, 3, 4, 5};
cout << vec.at(4);  // Safe access
```

✅ **Use Bounds Checking Tools**  
Enable **AddressSanitizer** to catch out-of-bounds errors.

```sh
g++ -fsanitize=address -g program.cpp -o program
./program
```

---

### **6. Detecting and Avoiding Undefined Behavior**

**Undefined Behavior (UB)** happens when the program does something that is not well-defined by the C++ standard.

✅ **Common Causes of UB**

- Dereferencing `nullptr`
- Using an uninitialized variable
- Accessing out-of-bounds memory
- Signed integer overflow

✅ **Use Compiler Flags to Detect Issues**

```sh
g++ -Wall -Wextra -Werror program.cpp
```

✅ **Use Static Analysis Tools**

```sh
clang-tidy program.cpp
cppcheck program.cpp
```

---

### **7. Using RAII (Resource Acquisition Is Initialization)**

RAII ensures **automatic resource cleanup** using objects' destructors.

✅ **Example: Managing File Handles Safely**

```cpp
#include <fstream>
void writeFile() {
    std::ofstream file("data.txt");  // Automatically closed when out of scope
    file << "Hello, world!";
}  // No need for manual `close()`
```


***

# Practice
## Interpreting Complex Declarations and Definitions

#### Example 1: Function Pointer Declaration

**Declaration:**
```cpp
void (*funcPtr)(int, double);
```

**Interpretation:**
- `void (*funcPtr)(int, double);` declares a pointer `funcPtr` to a function.
- The function takes two parameters: an `int` and a `double`.
- The function returns `void` (no return value).

**Breakdown:**
- `void` – The return type of the function.
- `(*funcPtr)` – Indicates that `funcPtr` is a pointer.
- `(int, double)` – The function takes an `int` and a `double` as parameters.

#### Example 2: Pointer to a Constant Pointer

**Declaration:**
```cpp
const int* const* ptrToConstPtr;
```

**Interpretation:**
- `ptrToConstPtr` is a pointer to a constant pointer.
- The constant pointer points to a `const int`.

**Breakdown:**
- `const int*` – A pointer to a `const int`.
- `const*` – Indicates that the pointer itself is constant (cannot change to point elsewhere).
- `const int* const*` – `ptrToConstPtr` is a pointer to a `const int* const`.

#### Example 3: Template Class with Multiple Parameters

**Declaration:**
```cpp
template<typename T, typename U>
class MyClass {
    T member1;
    U member2;
public:
    MyClass(T t, U u);
    void display() const;
};
```

**Interpretation:**
- `MyClass` is a template class with two type parameters: `T` and `U`.
- It has two member variables: `member1` of type `T` and `member2` of type `U`.
- The class has a constructor taking parameters of type `T` and `U`.
- It also has a `display` method that does not modify the object (indicated by `const`).

**Breakdown:**
- `template<typename T, typename U>` – Declares a template with two type parameters.
- `class MyClass` – Defines a class template.
- `T member1;` – Member variable of type `T`.
- `U member2;` – Member variable of type `U`.
- `MyClass(T t, U u);` – Constructor with parameters of types `T` and `U`.
- `void display() const;` – Member function that does not modify the object.

#### Example 4: Function Overloading with Default Arguments

**Declaration:**
```cpp
void process(int a, double b = 0.0);
```

**Interpretation:**
- `process` is a function that takes an `int` and a `double` as parameters.
- The `double` parameter `b` has a default value of `0.0`.

**Breakdown:**
- `void` – The return type of the function.
- `process` – The name of the function.
- `(int a, double b = 0.0)` – Parameters of the function, with `b` having a default value.

#### Example 5: Nested Typedefs and Templates

**Declaration:**
```cpp
template<typename T>
class Wrapper {
public:
    typedef T ValueType;
    ValueType value;
};
```

**Interpretation:**
- `Wrapper` is a class template with a type parameter `T`.
- `ValueType` is a type alias (typedef) for `T` inside the class.
- `value` is a member variable of type `ValueType`, which is effectively `T`.

**Breakdown:**
- `template<typename T>` – Declares a template class with type parameter `T`.
- `typedef T ValueType;` – Creates an alias `ValueType` for type `T`.
- `ValueType value;` – Member variable of type `ValueType` (which is `T`).


### Example 5: Three-Dimensional Array

**Declaration:**
```cpp
float arr[2][3][4];
```

**Interpretation:**
- `arr` is a three-dimensional array of floats with dimensions 2x3x4.

**Breakdown:**
- `float` – The type of elements.
- `[2][3][4]` – Dimensions: 2 layers, each containing 3 rows and 4 columns.

**Access Example:**
```cpp
arr[1][2][3] = 7.5f; // Accesses the element in layer 1, row 2, column 3
```

### Example 6. **Pointer to a Pointer**

**Declaration:**
```cpp
int** ptr;
```

**Interpretation:**
- `ptr` is a pointer to a pointer to an integer.

**Breakdown:**
- `int*` – Pointer to an integer.
- `int**` – Pointer to a pointer to an integer.

**Usage Example:**
```cpp
int value = 10;
int* p1 = &value;
int** p2 = &p1;
```

Here:
- `p1` is a pointer to `value`.
- `p2` is a pointer to `p1`.

### Example 7: **Function Returning a Pointer to a Function**

**Declaration:**
```cpp
int (*funcPtr())(double);
```

**Interpretation:**
- `funcPtr` is a function that returns a pointer to a function taking a `double` and returning an `int`.

**Breakdown:**
- `int` – The return type of the function `funcPtr` returns.
- `(*funcPtr())` – `funcPtr` is a function.
- `(double)` – The function pointed to by `funcPtr` takes a `double` parameter.

**Usage Example:**
```cpp
int anotherFunction(double x) {
    return static_cast<int>(x);
}

int (*funcPtr())(double) {
    return anotherFunction;
}
```

### Example 8: Pointer to a Function with Array Parameter

**Declaration:**
```cpp
void (*funcPtr(int[5]))(double);
```

**Interpretation:**
- `funcPtr` is a function taking an array of 5 integers and returning a pointer to a function that takes a `double` and returns `void`.

**Breakdown:**
- `void (*funcPtr(int[5]))(double)` – `funcPtr` is a function that takes an array of 5 integers.
- `void (*)(double)` – The function returns a pointer to another function that takes a `double` and returns `void`.

**Usage Example:**
```cpp
void myFunction(double x) {
    std::cout << x << std::endl;
}

void (*anotherFunction(int arr[5]))(double) {
    return myFunction;
}
```

### General Approach to Interpreting Declarations

1. **Identify Basic Elements**: Determine the fundamental components such as type, pointers, references, and class templates.
2. **Use Parentheses and Operators**: Analyze how operators and parentheses group together to understand the order of precedence and associations.
3. **Break Down Step-by-Step**: Simplify the declaration by breaking it into smaller parts and understanding each part in isolation.
4. **Consult Documentation**: Refer to language references or documentation for complex cases or specific syntax.

***

# Enumerations

## Common Standard Libraries

In C++, several standard libraries are commonly used across different types of applications. These libraries provide essential functionalities that are fundamental to C++ programming. Here are some of the most commonly used default libraries:

### 1. **\<iostream\>**
- **Purpose:** Provides facilities for input and output (I/O) operations.
- **Common Uses:** 
  - `std::cout` for console output.
  - `std::cin` for console input.
  - `std::cerr` for error output.

### 2. **\<vector\>**
- **Purpose:** Defines the `std::vector` container, a dynamic array that can resize itself automatically.
- **Common Uses:** 
  - Managing a dynamic array of elements.
  - Accessing elements using indexing.
  - Adding and removing elements.

### 3. **\<string\>**
- **Purpose:** Provides support for handling strings through the `std::string` class.
- **Common Uses:** 
  - Manipulating sequences of characters.
  - String concatenation, comparison, and searching.
  - Converting between strings and other data types.

### 4. **\<algorithm\>**
- **Purpose:** Provides a collection of functions for performing various operations on data structures, such as sorting, searching, and modifying sequences.
- **Common Uses:** 
  - `std::sort` for sorting elements.
  - `std::find` for searching elements.
  - `std::copy`, `std::transform`, and others for modifying data.

### 5. **\<map> and <unordered_map>**
- **Purpose:** Define associative containers that store key-value pairs. `std::map` is ordered, while `std::unordered_map` is not.
- **Common Uses:** 
  - Storing and retrieving elements based on keys.
  - Implementing lookup tables, dictionaries, and associative arrays.

### 6. **\<set> and <unordered_set>**
- **Purpose:** Define containers that store unique elements. `std::set` is ordered, while `std::unordered_set` is not.
- **Common Uses:** 
  - Storing unique elements.
  - Efficiently checking if an element exists.

### 7. **\<deque>**
- **Purpose:** Defines `std::deque`, a double-ended queue that allows insertion and deletion of elements from both ends.
- **Common Uses:** 
  - Implementing queues or stacks.
  - Managing sequences where elements are frequently added or removed from both ends.

### 8. **\<list>**
- **Purpose:** Provides a doubly-linked list implementation through `std::list`.
- **Common Uses:** 
  - Managing sequences of elements with frequent insertions and deletions.
  - When random access is not needed.

### 9. **\<cmath>**
- **Purpose:** Provides mathematical functions.
- **Common Uses:** 
  - Trigonometric functions like `std::sin`, `std::cos`.
  - Power and exponentiation functions like `std::pow`, `std::exp`.
  - Basic operations like `std::sqrt` and `std::abs`.

### 10. **\<thread>**
- **Purpose:** Provides support for multithreading in C++.
- **Common Uses:** 
  - Creating and managing threads (`std::thread`).
  - Synchronizing access to shared resources (`std::mutex`, `std::lock_guard`).

### 11. **\<functional>**
- **Purpose:** Provides utilities for function objects, lambdas, and other callable objects.
- **Common Uses:** 
  - Using `std::function` to store and pass around functions.
  - Creating bind expressions with `std::bind`.

### 12. **\<chrono>**
- **Purpose:** Provides utilities for dealing with time.
- **Common Uses:** 
  - Measuring time intervals (`std::chrono::duration`).
  - Getting the current time (`std::chrono::system_clock`).

### 13. **\<memory>**
- **Purpose:** Provides facilities for dynamic memory management.
- **Common Uses:** 
  - Using smart pointers like `std::unique_ptr` and `std::shared_ptr` to manage dynamic memory safely.

### 14. **\<tuple>**
- **Purpose:** Allows grouping of multiple values of different types into a single object.
- **Common Uses:** 
  - Returning multiple values from a function.
  - Grouping related data without creating a custom structure.

### 15. **\<utility>**
- **Purpose:** Contains utility functions like `std::pair` and `std::move`.
- **Common Uses:** 
  - Returning two related values with `std::pair`.
  - Efficiently transferring resources with `std::move`.

### 16. **\<array>**
- **Purpose:** Provides a fixed-size array container through `std::array`.
- **Common Uses:**
  - Creating arrays with a fixed size known at compile-time.
  - Offers the benefits of an array with additional functionality like bounds checking.

### 17. **\<stack>**
- **Purpose:** Provides a stack container adapter.
- **Common Uses:**
  - Implementing a LIFO (Last In, First Out) data structure.
  - Managing a sequence where the last added element is the first to be removed.

### 18. **\<queue>**
- **Purpose:** Provides a queue container adapter.
- **Common Uses:**
  - Implementing a FIFO (First In, First Out) data structure.
  - Managing tasks or elements where the first added element is the first to be processed.

### 19. **\<bitset>**
- **Purpose:** Provides a container to manage a fixed-size sequence of bits.
- **Common Uses:**
  - Manipulating individual bits efficiently.
  - Performing operations like bitwise AND, OR, and XOR on sequences of bits.

### 20. **\<fstream>**
- **Purpose:** Provides facilities for file input and output operations.
- **Common Uses:**
  - Reading from and writing to files (`std::ifstream`, `std::ofstream`, `std::fstream`).
  - Handling text and binary files.

### 21. **\<iomanip>**
- **Purpose:** Provides facilities to control the formatting of input and output.
- **Common Uses:**
  - Setting precision for floating-point output (`std::setprecision`).
  - Formatting output with width and alignment (`std::setw`, `std::left`, `std::right`).

### 22. **\<locale>**
- **Purpose:** Provides support for localization, allowing programs to adapt to different cultural conventions.
- **Common Uses:**
  - Handling region-specific formatting of numbers, dates, and times.
  - Managing locale-specific input and output.

### 23. **\<random>**
- **Purpose:** Provides facilities to generate random numbers and perform random operations.
- **Common Uses:**
  - Generating random integers, floats, and other types (`std::mt19937`, `std::uniform_int_distribution`).
  - Creating random number generators with various distributions.

### 24. **\<type_traits>**
- **Purpose:** Provides templates that allow you to query and manipulate type information at compile-time.
- **Common Uses:**
  - Checking if a type is integral or floating-point (`std::is_integral`, `std::is_floating_point`).
  - Enabling or disabling template functions based on type traits (`std::enable_if`).

### 25. **\<numeric>**
- **Purpose:** Provides algorithms for performing numerical operations on sequences.
- **Common Uses:**
  - Accumulating values (`std::accumulate`).
  - Computing inner products (`std::inner_product`).
  - Performing partial sums (`std::partial_sum`).

### 26. **\<regex>**
- **Purpose:** Provides support for regular expressions.
- **Common Uses:**
  - Pattern matching within strings (`std::regex`, `std::regex_search`, `std::regex_match`).
  - Finding and replacing text in strings using regular expressions.

### 27. **\<cassert>**
- **Purpose:** Provides support for diagnostic output via the `assert` macro.
- **Common Uses:**
  - Performing runtime checks during debugging (`assert`).
  - Ensuring that conditions expected by the program are true during execution.

### 28. **\<cctype>**
- **Purpose:** Provides functions for character classification and conversion.
- **Common Uses:**
  - Checking if a character is a digit, letter, or whitespace (`std::isdigit`, `std::isalpha`).
  - Converting characters to upper or lower case (`std::toupper`, `std::tolower`).

### 29. **\<ctime>**
- **Purpose:** Provides functions for dealing with calendar time.
- **Common Uses:**
  - Getting the current time (`std::time`).
  - Converting time to and from string representations (`std::strftime`, `std::strptime`).

### 30. **\<exception>**
- **Purpose:** Provides support for exception handling.
- **Common Uses:**
  - Defining custom exception classes (`std::exception`).
  - Catching and handling exceptions in a consistent manner.

***

## Integers With Specific Bit Sizes

C++ also provides integer types with specific bit sizes through the `<cstdint>` header (introduced in C++11). These types guarantee a fixed width, ensuring portability across different platforms. Here are the integer types with specific bit sizes:

### 1. **Exact-Width Integer Types**
   - **`int8_t`**: 8-bit signed integer.
   - **`int16_t`**: 16-bit signed integer.
   - **`int32_t`**: 32-bit signed integer.
   - **`int64_t`**: 64-bit signed integer.

   - **`uint8_t`**: 8-bit unsigned integer.
   - **`uint16_t`**: 16-bit unsigned integer.
   - **`uint32_t`**: 32-bit unsigned integer.
   - **`uint64_t`**: 64-bit unsigned integer.

### 2. **Minimum-Width Integer Types**
   - **`int_least8_t`**: Signed integer with at least 8 bits.
   - **`int_least16_t`**: Signed integer with at least 16 bits.
   - **`int_least32_t`**: Signed integer with at least 32 bits.
   - **`int_least64_t`**: Signed integer with at least 64 bits.

   - **`uint_least8_t`**: Unsigned integer with at least 8 bits.
   - **`uint_least16_t`**: Unsigned integer with at least 16 bits.
   - **`uint_least32_t`**: Unsigned integer with at least 32 bits.
   - **`uint_least64_t`**: Unsigned integer with at least 64 bits.

### 3. **Fastest Minimum-Width Integer Types**
   - **`int_fast8_t`**: Fastest signed integer with at least 8 bits.
   - **`int_fast16_t`**: Fastest signed integer with at least 16 bits.
   - **`int_fast32_t`**: Fastest signed integer with at least 32 bits.
   - **`int_fast64_t`**: Fastest signed integer with at least 64 bits.

   - **`uint_fast8_t`**: Fastest unsigned integer with at least 8 bits.
   - **`uint_fast16_t`**: Fastest unsigned integer with at least 16 bits.
   - **`uint_fast32_t`**: Fastest unsigned integer with at least 32 bits.
   - **`uint_fast64_t`**: Fastest unsigned integer with at least 64 bits.

### 4. **Pointer Integer Types**
   - **`intptr_t`**: Signed integer type capable of holding a pointer.
   - **`uintptr_t`**: Unsigned integer type capable of holding a pointer.

### 5. **Greatest Width Integer Types**
   - **`intmax_t`**: Signed integer with the maximum width available on the platform.
   - **`uintmax_t`**: Unsigned integer with the maximum width available on the platform.

These types are particularly useful when you need precise control over the size and behavior of your integers, ensuring consistency and avoiding potential issues related to different hardware architectures. To use these types, include the `<cstdint>` header in your code:

```cpp
#include <cstdint>
```

***

# Reference

In C++, operators have specific **precedence** (priority) and **associativity** rules that determine how expressions are evaluated. Understanding these rules is crucial for writing correct and predictable code. Here’s a detailed breakdown of C++ operators including their precedence, associativity, arity (number of operands), and whether they can overlap.

## Operator Precedence and Associativity Table

| Operator                | Precedence | Associativity | Arity | Example      | Description                                            |
|-------------------------|------------|---------------|-------|--------------|--------------------------------------------------------|
| Scope resolution (`::`) | 1          | N/A           | 1     | `std::cout`   | Resolves the namespace scope                          |
| Member access (`.`)     | 2          | Left-to-Right | 2     | `obj.member`  | Accesses a member of an object                         |
| Member access (`->`)    | 2          | Left-to-Right | 2     | `ptr->member` | Accesses a member through a pointer                    |
| Function call (`()`)    | 2          | Left-to-Right | 1     | `func()`     | Calls a function                                      |
| Array subscript (`[]`)  | 2          | Left-to-Right | 2     | `arr[0]`     | Accesses an element of an array                        |
| Postfix increment (`++`)| 3          | Left-to-Right | 1     | `i++`        | Increments the value after its use                     |
| Postfix decrement (`--`)| 3          | Left-to-Right | 1     | `i--`        | Decrements the value after its use                     |
| Unary plus (`+`)        | 4          | Right-to-Left | 1     | `+x`         | Unary plus, has no effect on the value                 |
| Unary minus (`-`)       | 4          | Right-to-Left | 1     | `-x`         | Unary negation                                        |
| Logical NOT (`!`)       | 4          | Right-to-Left | 1     | `!x`         | Logical negation                                      |
| Bitwise NOT (`~`)       | 4          | Right-to-Left | 1     | `~x`         | Bitwise negation                                      |
| Prefix increment (`++`) | 4          | Right-to-Left | 1     | `++i`        | Increments the value before its use                    |
| Prefix decrement (`--`) | 4          | Right-to-Left | 1     | `--i`        | Decrements the value before its use                    |
| Type cast (`(type)`)    | 4          | Right-to-Left | 1     | `(int)x`     | Casts to a specific type                               |
| Pointer to member (`.*`) | 5         | Left-to-Right | 2     | `obj.*ptr`   | Accesses a member through a pointer to a member        |
| Pointer to member (`->*`) | 5        | Left-to-Right | 2     | `ptr->*mem`  | Accesses a member through a pointer to a member        |
| Multiplication (`*`)    | 6          | Left-to-Right | 2     | `a * b`      | Multiplies two values                                 |
| Division (`/`)          | 6          | Left-to-Right | 2     | `a / b`      | Divides two values                                   |
| Modulus (`%`)           | 6          | Left-to-Right | 2     | `a % b`      | Modulus operation                                    |
| Addition (`+`)          | 7          | Left-to-Right | 2     | `a + b`      | Adds two values                                      |
| Subtraction (`-`)       | 7          | Left-to-Right | 2     | `a - b`      | Subtracts two values                                 |
| Bitwise shift left (`<<`)| 8         | Left-to-Right | 2     | `a << b`     | Shifts bits to the left                              |
| Bitwise shift right (`>>`)| 8        | Left-to-Right | 2     | `a >> b`     | Shifts bits to the right                             |
| Relational less than (`<`)| 9        | Left-to-Right | 2     | `a < b`      | Checks if left is less than right                    |
| Relational greater than (`>`)| 9      | Left-to-Right | 2     | `a > b`      | Checks if left is greater than right                 |
| Relational less than or equal (`<=`)| 9 | Left-to-Right | 2     | `a <= b`     | Checks if left is less than or equal to right         |
| Relational greater than or equal (`>=`)| 9 | Left-to-Right | 2     | `a >= b`     | Checks if left is greater than or equal to right      |
| Equality (`==`)         | 10         | Left-to-Right | 2     | `a == b`     | Checks if two values are equal                       |
| Inequality (`!=`)       | 10         | Left-to-Right | 2     | `a != b`     | Checks if two values are not equal                   |
| Bitwise AND (`&`)       | 11         | Left-to-Right | 2     | `a & b`      | Bitwise AND operation                                |
| Bitwise XOR (`^`)       | 12         | Left-to-Right | 2     | `a ^ b`      | Bitwise XOR operation                                |
| Bitwise OR (`|`)        | 13         | Left-to-Right | 2     | `a | b`      | Bitwise OR operation                                 |
| Logical AND (`&&`)      | 14         | Left-to-Right | 2     | `a && b`     | Logical AND operation                                |
| Logical OR (`||`)       | 15         | Left-to-Right | 2     | `a || b`     | Logical OR operation                                 |
| Conditional (`?:`)      | 16         | Right-to-Left | 3     | `condition ? a : b` | Conditional expression                            |
| Assignment (`=`)        | 17         | Right-to-Left | 2     | `a = b`      | Assigns value of right to left                       |
| Compound assignment (`+=`, `-=`, etc.)| 17 | Right-to-Left | 2     | `a += b`     | Shorthand for assignment with operation              |
| Comma (`,`)             | 18         | Left-to-Right | 2     | `a, b`      | Separates expressions or function arguments          

### Key Concepts:

- **Precedence**: Determines the order in which operators are evaluated in an expression. Higher precedence operators are evaluated before lower precedence operators.
- **Associativity**: Determines the order in which operators of the same precedence level are evaluated. Most operators are left-to-right, but some (e.g., assignment) are right-to-left.
- **Arity**: Refers to the number of operands an operator takes. Operators can be unary (1 operand), binary (2 operands), or ternary (3 operands, e.g., the conditional operator `?:`).

### Overlap and Ambiguities

- **Overlapping Precedence**: Operators with the same precedence level are evaluated based on their associativity. For example, both `*` and `/` have the same precedence and are evaluated left-to-right.
- **Complex Expressions**: Parentheses `()` can be used to explicitly define the order of evaluation and avoid ambiguities in complex expressions.

### Example:

```cpp
int a = 5;
int b = 3;
int c = 2;
int result = a + b * c;  // Multiplication (*) has higher precedence than addition (+)
```

Here, `b * c` is evaluated first, then the result is added to `a`.

## C++ Versions

### **1. C++98 (ISO/IEC 14882:1998)**
- **Standardization:** The first standardized version of C++, based on the work of Bjarne Stroustrup.
- **Key Features:**
  - **Templates:** Introduced generic programming through templates.
  - **Exceptions:** Provided a mechanism for error handling.
  - **Namespaces:** Allowed grouping of entities to avoid name collisions.
  - **STL (Standard Template Library):** Introduced containers like `vector`, `list`, `map`, and algorithms.

### **2. C++03 (ISO/IEC 14882:2003)**
- **Standardization:** A bug-fix release of C++98, with no major new features.
- **Key Features:**
  - **Bug Fixes:** Resolved various issues and ambiguities in C++98.
  - **Library Updates:** Minor updates to the standard library, such as improved compatibility and better performance in some cases.

### **3. C++11 (ISO/IEC 14882:2011)**
- **Standardization:** A major update that modernized C++.
- **Key Features:**
  - **Auto Keyword:** Automatic type deduction with the `auto` keyword.
  - **Range-based for Loops:** Simplified iteration over containers.
  - **Lambda Expressions:** Introduced anonymous functions.
  - **Move Semantics:** Improved performance by allowing resources to be transferred rather than copied.
  - **Smart Pointers:** Added `std::shared_ptr` and `std::unique_ptr` for safer memory management.
  - **Threading Support:** Introduced multithreading support with `std::thread`, `std::mutex`, etc.
  - **Uniform Initialization:** A new syntax for initializing objects (`{}`).

### **4. C++14 (ISO/IEC 14882:2014)**
- **Standardization:** A minor update that improved upon C++11.
- **Key Features:**
  - **Generic Lambdas:** Allowed lambdas with auto parameters.
  - **Return Type Deduction:** Functions could now automatically deduce return types.
  - **Binary Literals:** Added support for binary literals (e.g., `0b1010`).
  - **Compile-time String Literals:** The `std::literals::string_literals` namespace was introduced for string literals.

### **5. C++17 (ISO/IEC 14882:2017)**
- **Standardization:** Another significant update with more language and library features.
- **Key Features:**
  - **std::optional:** Represented optional values, improving code safety.
  - **std::variant:** Provided a type-safe union.
  - **std::any:** A type-safe container for single values of any type.
  - **Structured Bindings:** Allowed unpacking of tuples or pairs into separate variables.
  - **if constexpr:** Enabled compile-time conditional compilation.
  - **std::filesystem:** Added filesystem manipulation capabilities.

### **6. C++20 (ISO/IEC 14882:2020)**
- **Standardization:** A major update that significantly expanded the language.
- **Key Features:**
  - **Concepts:** Provided constraints on template parameters.
  - **Ranges:** Simplified and enhanced the STL's iterator-based algorithms.
  - **Coroutines:** Introduced asynchronous programming support.
  - **Modules:** Allowed better organization of code by providing a new module system, reducing compile times.
  - **Three-way Comparison (Spaceship Operator `<=>`):** Simplified comparison operators.
  - **Calendar and Timezone Library:** Standardized date and time operations.

### **7. C++23 (ISO/IEC 14882:2023)**
- **Standardization:** The latest update, bringing more modern features.
- **Key Features:**
  - **Expanded Library Support:** Improved standard library utilities.
  - **Multithreading Enhancements:** Enhanced multithreading capabilities.
  - **Pattern Matching:** Introduced pattern matching (similar to switch-case on steroids).
  - **Static Reflection:** Provided compile-time introspection of code.
