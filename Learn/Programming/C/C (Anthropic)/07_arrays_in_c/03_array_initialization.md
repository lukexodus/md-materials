## Array Initialization


Arrays can be initialized at declaration time using various methods, providing initial values for some or all elements.

**Complete Initialization:**

```c
int numbers[5] = {10, 20, 30, 40, 50};
char vowels[5] = {'a', 'e', 'i', 'o', 'u'};
```

**Partial Initialization:** When fewer initializers are provided than array size, remaining elements are automatically set to zero.

```c
int arr[10] = {1, 2, 3};  // First 3 elements: 1,2,3; rest: 0
int zeros[5] = {0};       // All elements initialized to 0
```

**Size Inference:** Array size can be omitted when initializing, and the compiler determines size from the number of initializers.

```c
int data[] = {1, 2, 3, 4, 5};  // Size automatically becomes 5
char name[] = "Hello";          // Size becomes 6 (including null terminator)
```

**Multi-Dimensional Array Initialization:**

```c
int matrix[2][3] = {
    {1, 2, 3},
    {4, 5, 6}
};

// Alternative flat initialization
int matrix2[2][3] = {1, 2, 3, 4, 5, 6};

// Partial initialization
int sparse[3][3] = {{1}, {0, 2}, {0, 0, 3}};
```

**Designated Initializers (C99):** Allows initialization of specific array elements by index.

```c
int arr[10] = {[0] = 1, [5] = 10, [9] = 100};
int matrix[3][3] = {[1][1] = 5, [2][0] = 7};
```

**Key Points:**

- Uninitialized local arrays contain garbage values
- Global and static arrays are automatically initialized to zero
- String literals provide convenient initialization for character arrays
- Initialization lists must be compile-time constants

