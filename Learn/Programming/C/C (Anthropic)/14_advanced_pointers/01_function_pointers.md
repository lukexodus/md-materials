## Function Pointers


Function pointers store the memory address of functions, allowing functions to be passed as arguments, stored in data structures, and called indirectly.

**Declaration Syntax**

```c
return_type (*pointer_name)(parameter_types);
```

**Basic Function Pointer Usage**

```c
#include <stdio.h>

int add(int a, int b) {
    return a + b;
}

int multiply(int a, int b) {
    return a * b;
}

int main() {
    int (*operation)(int, int);  // Function pointer declaration
    
    operation = add;             // Assign function address
    printf("Add: %d\n", operation(5, 3));
    
    operation = multiply;        // Reassign to different function
    printf("Multiply: %d\n", operation(5, 3));
    
    return 0;
}
```

**Function Pointer Parameters**

```c
void process_array(int arr[], int size, int (*func)(int)) {
    for (int i = 0; i < size; i++) {
        arr[i] = func(arr[i]);
    }
}

int square(int x) {
    return x * x;
}

int double_value(int x) {
    return x * 2;
}

int main() {
    int numbers[] = {1, 2, 3, 4, 5};
    
    process_array(numbers, 5, square);      // Apply square function
    process_array(numbers, 5, double_value); // Apply double function
    
    return 0;
}
```

