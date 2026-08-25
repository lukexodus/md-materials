## Pointer Arithmetic


Pointer arithmetic operates on the concept that pointers can be incremented, decremented, and compared based on the size of the data type they point to. When a pointer is incremented, it moves forward by the size of one element of its pointed-to type.

### Basic Arithmetic Operations

```c
int arr[] = {10, 20, 30, 40, 50};
int *ptr = arr;  // Points to first element

printf("ptr points to: %d\n", *ptr);        // 10
ptr++;           // Move to next integer (4 bytes forward)
printf("ptr points to: %d\n", *ptr);        // 20
ptr += 2;        // Move forward 2 integers (8 bytes)
printf("ptr points to: %d\n", *ptr);        // 40
```

**Key points** about pointer arithmetic:

- Adding 1 to a pointer advances it by sizeof(pointed-to-type) bytes
- Only addition, subtraction, and comparison operations are valid
- Multiplication and division are not permitted on pointers
- Pointer arithmetic is undefined when pointers go outside valid memory boundaries

### Pointer Differences and Comparisons

The difference between two pointers yields the number of elements between them:

```c
int arr[] = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10};
int *start = &arr[2];    // Points to arr[2]
int *end = &arr[7];      // Points to arr[7]

ptrdiff_t diff = end - start;    // diff = 5 (elements between)
printf("Elements between: %td\n", diff);
```

Pointer comparison enables range checking and boundary validation:

```c
int arr[10];
int *ptr = arr;
int *end_ptr = arr + 10;

while (ptr < end_ptr) {
    *ptr = 0;    // Initialize array elements
    ptr++;
}
```

### Advanced Arithmetic Examples

**Example** of traversing data structures with pointer arithmetic:

```c
#include <stdio.h>

void print_array_forward(int *arr, int size) {
    int *end = arr + size;
    while (arr < end) {
        printf("%d ", *arr);
        arr++;
    }
    printf("\n");
}

void print_array_backward(int *arr, int size) {
    int *ptr = arr + size - 1;    // Point to last element
    while (ptr >= arr) {
        printf("%d ", *ptr);
        ptr--;
    }
    printf("\n");
}

int main() {
    int numbers[] = {1, 2, 3, 4, 5};
    int size = sizeof(numbers) / sizeof(numbers[0]);
    
    print_array_forward(numbers, size);   // 1 2 3 4 5
    print_array_backward(numbers, size);  // 5 4 3 2 1
    
    return 0;
}
```

