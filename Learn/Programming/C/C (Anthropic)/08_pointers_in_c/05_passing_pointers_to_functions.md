## Passing Pointers to Functions


Passing pointers to functions enables functions to modify variables in the calling scope and provides efficient parameter passing for large data structures. C uses pass-by-value for all parameters, but passing a pointer's value allows indirect access to the original variable.

### Basic Pointer Parameter Passing

```c
#include <stdio.h>

void swap_values(int *a, int *b) {
    int temp = *a;
    *a = *b;
    *b = temp;
}

void increment_value(int *value) {
    (*value)++;
}

int main() {
    int x = 10, y = 20;
    
    printf("Before swap: x = %d, y = %d\n", x, y);
    swap_values(&x, &y);
    printf("After swap: x = %d, y = %d\n", x, y);
    
    printf("Before increment: x = %d\n", x);
    increment_value(&x);
    printf("After increment: x = %d\n", x);
    
    return 0;
}
```

### Array Parameters and Pointer Equivalence

When arrays are passed to functions, they decay to pointers, losing size information:

```c
#include <stdio.h>

// These function declarations are equivalent
void process_array1(int arr[]);
void process_array2(int arr[10]);    // Size ignored
void process_array3(int *arr);

void print_array(int *arr, int size) {
    for (int i = 0; i < size; i++) {
        printf("%d ", arr[i]);
    }
    printf("\n");
}

void modify_array(int *arr, int size) {
    for (int i = 0; i < size; i++) {
        arr[i] *= 2;
    }
}

int main() {
    int numbers[] = {1, 2, 3, 4, 5};
    int size = sizeof(numbers) / sizeof(numbers[0]);
    
    printf("Original array: ");
    print_array(numbers, size);
    
    modify_array(numbers, size);
    printf("Modified array: ");
    print_array(numbers, size);
    
    return 0;
}
```

### Function Pointers as Parameters

Functions themselves have addresses and can be passed as pointer parameters:

```c
#include <stdio.h>

int add(int a, int b) { return a + b; }
int multiply(int a, int b) { return a * b; }
int subtract(int a, int b) { return a - b; }

int calculate(int x, int y, int (*operation)(int, int)) {
    return operation(x, y);
}

int main() {
    int a = 10, b = 5;
    
    printf("%d + %d = %d\n", a, b, calculate(a, b, add));
    printf("%d * %d = %d\n", a, b, calculate(a, b, multiply));
    printf("%d - %d = %d\n", a, b, calculate(a, b, subtract));
    
    return 0;
}
```

### Const Correctness with Pointer Parameters

The `const` keyword provides protection against unintended modifications:

```c
#include <stdio.h>
#include <string.h>

// Function promises not to modify the string
int count_characters(const char *str, char target) {
    int count = 0;
    while (*str != '\0') {
        if (*str == target) {
            count++;
        }
        str++;
    }
    return count;
}

// Function can modify the array but not reassign the pointer
void initialize_array(int * const arr, int size, int value) {
    for (int i = 0; i < size; i++) {
        arr[i] = value;
    }
    // arr = NULL;  // Error: cannot modify const pointer
}

// Function cannot modify array contents or reassign pointer
void print_readonly_array(const int * const arr, int size) {
    for (int i = 0; i < size; i++) {
        printf("%d ", arr[i]);
        // arr[i] = 0;  // Error: cannot modify through const pointer
    }
    printf("\n");
    // arr = NULL;  // Error: cannot modify const pointer
}

int main() {
    char text[] = "Hello World";
    printf("Character 'l' appears %d times\n", count_characters(text, 'l'));
    
    int numbers[5];
    initialize_array(numbers, 5, 42);
    print_readonly_array(numbers, 5);
    
    return 0;
}
```

**Key points** about passing pointers to functions:

- Functions receive copies of pointer values, not the pointers themselves
- Modifications through dereferenced pointers affect original variables
- Array parameters automatically decay to pointers
- `const` qualifiers provide compile-time protection against modifications
- Function pointers enable callback mechanisms and polymorphic behavior

