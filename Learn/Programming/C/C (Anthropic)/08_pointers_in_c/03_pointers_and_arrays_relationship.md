## Pointers and Arrays Relationship


Arrays and pointers share a fundamental relationship in C. An array name acts as a constant pointer to the first element of the array, and array indexing can be expressed through pointer arithmetic.

### Array-Pointer Equivalence

The array name represents the address of the first element:

```c
int arr[5] = {10, 20, 30, 40, 50};
int *ptr = arr;    // Equivalent to: int *ptr = &arr[0];

// These expressions are equivalent:
arr[2]     // Array subscript notation
*(arr + 2) // Pointer arithmetic notation
ptr[2]     // Pointer subscript notation
*(ptr + 2) // Pointer arithmetic with pointer variable
```

**Example** demonstrating array-pointer interchangeability:

```c
#include <stdio.h>

void print_array_methods(int *arr, int size) {
    printf("Using array notation: ");
    for (int i = 0; i < size; i++) {
        printf("%d ", arr[i]);
    }
    printf("\n");
    
    printf("Using pointer arithmetic: ");
    for (int i = 0; i < size; i++) {
        printf("%d ", *(arr + i));
    }
    printf("\n");
    
    printf("Using pointer increment: ");
    int *ptr = arr;
    for (int i = 0; i < size; i++) {
        printf("%d ", *ptr++);
    }
    printf("\n");
}

int main() {
    int numbers[] = {1, 2, 3, 4, 5};
    int size = sizeof(numbers) / sizeof(numbers[0]);
    
    print_array_methods(numbers, size);
    return 0;
}
```

### Multidimensional Arrays and Pointers

Multidimensional arrays create more complex pointer relationships:

```c
int matrix[3][4] = {
    {1, 2, 3, 4},
    {5, 6, 7, 8},
    {9, 10, 11, 12}
};

// matrix is a pointer to an array of 4 integers
int (*row_ptr)[4] = matrix;    // Points to first row

// Accessing elements through different methods
printf("%d\n", matrix[1][2]);           // Standard notation: 7
printf("%d\n", *(*(matrix + 1) + 2));   // Pointer arithmetic: 7
printf("%d\n", (*(row_ptr + 1))[2]);    // Mixed notation: 7
```

### String Handling with Pointers

Character arrays (strings) demonstrate practical pointer usage:

```c
char str[] = "Hello, World!";
char *ptr = str;

// Character-by-character processing
while (*ptr != '\0') {
    if (*ptr == 'o') {
        *ptr = '0';    // Replace 'o' with '0'
    }
    ptr++;
}
printf("%s\n", str);    // Output: Hell0, W0rld!
```

**Key points** about arrays and pointers:

- Array names are constant pointers and cannot be reassigned
- `sizeof(array)` returns total array size, `sizeof(pointer)` returns pointer size
- Arrays passed to functions decay to pointers, losing size information
- Pointer arithmetic provides efficient array traversal mechanisms

