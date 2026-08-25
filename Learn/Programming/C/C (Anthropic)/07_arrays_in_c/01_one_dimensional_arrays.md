## One-Dimensional Arrays


One-dimensional arrays are collections of elements of the same data type stored in contiguous memory locations, accessed using a single index.

**Declaration Syntax:**

```c
data_type array_name[size];
```

**Memory Layout:** Arrays are stored in consecutive memory addresses, where each element occupies the memory space required by its data type. The array name represents the address of the first element.

**Index Access:** Array elements are accessed using zero-based indexing, where the first element is at index 0 and the last element is at index (size-1).

**Key Points:**

- Array size must be a compile-time constant in standard C
- Array bounds are not checked at runtime - accessing out-of-bounds elements causes undefined behavior
- Array name without brackets represents the base address (pointer to first element)
- Arrays cannot be assigned as a whole using the assignment operator

**Example:**

```c
int numbers[5];           // Declaration of integer array
int ages[10] = {0};       // Declaration with initialization to zero
float prices[3];          // Declaration of float array

// Accessing elements
numbers[0] = 10;          // First element
numbers[4] = 50;          // Last element
int value = numbers[2];   // Reading element

// Memory addresses
printf("Base address: %p\n", numbers);
printf("Second element address: %p\n", &numbers[1]);
```

**Array Traversal:**

```c
int arr[5] = {1, 2, 3, 4, 5};
for(int i = 0; i < 5; i++) {
    printf("Element %d: %d\n", i, arr[i]);
}
```

