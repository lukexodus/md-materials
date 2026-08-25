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


