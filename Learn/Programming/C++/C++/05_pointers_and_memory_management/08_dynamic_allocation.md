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

