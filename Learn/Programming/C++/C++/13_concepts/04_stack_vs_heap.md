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

