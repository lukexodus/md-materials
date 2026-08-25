## Pointers to Pointers


Pointers to pointers create multiple levels of indirection, enabling complex data structures and dynamic memory management scenarios. A pointer to a pointer stores the address of another pointer variable.

### Double Pointer Declaration and Usage

```c
int value = 42;
int *ptr = &value;        // ptr points to value
int **ptr_to_ptr = &ptr;  // ptr_to_ptr points to ptr

// Accessing the value through double indirection
printf("Value: %d\n", **ptr_to_ptr);    // Outputs: 42

// Modifying through different levels
*ptr = 100;              // Changes value to 100
**ptr_to_ptr = 200;      // Also changes value to 200
```

**Example** of double pointer manipulation:

```c
#include <stdio.h>

void modify_pointer(int **ptr) {
    static int new_value = 999;
    *ptr = &new_value;    // Changes what the original pointer points to
}

int main() {
    int a = 10, b = 20;
    int *ptr = &a;
    
    printf("Initially ptr points to: %d\n", *ptr);    // 10
    
    modify_pointer(&ptr);
    printf("After modification ptr points to: %d\n", *ptr);    // 999
    
    return 0;
}
```

### Practical Applications of Double Pointers

Double pointers commonly appear in dynamic data structures and function parameter passing:

```c
#include <stdio.h>
#include <stdlib.h>

// Function to allocate memory and modify pointer
int create_array(int **arr, int size) {
    *arr = (int*)malloc(size * sizeof(int));
    if (*arr == NULL) {
        return 0;    // Allocation failed
    }
    
    // Initialize array
    for (int i = 0; i < size; i++) {
        (*arr)[i] = i * 2;
    }
    return 1;    // Success
}

int main() {
    int *numbers = NULL;
    int size = 5;
    
    if (create_array(&numbers, size)) {
        for (int i = 0; i < size; i++) {
            printf("%d ", numbers[i]);
        }
        printf("\n");
        free(numbers);
    }
    
    return 0;
}
```

### Multi-Level Pointers

C supports arbitrary levels of pointer indirection:

```c
int value = 42;
int *ptr1 = &value;
int **ptr2 = &ptr1;
int ***ptr3 = &ptr2;

printf("Value through ptr1: %d\n", *ptr1);      // 42
printf("Value through ptr2: %d\n", **ptr2);     // 42
printf("Value through ptr3: %d\n", ***ptr3);    // 42
```

**Key points** about pointers to pointers:

- Each additional level of indirection requires an additional * for dereferencing
- Double pointers enable functions to modify pointer variables themselves
- Memory allocation functions often use double pointers to return allocated addresses
- Complex data structures like linked lists and trees utilize multiple pointer levels

