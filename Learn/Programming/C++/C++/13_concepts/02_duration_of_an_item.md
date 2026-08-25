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
