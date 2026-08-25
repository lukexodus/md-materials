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

