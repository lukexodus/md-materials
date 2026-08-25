## Function Parameters and Arguments


Parameters are variables declared in the function definition that receive values when the function is called. Arguments are the actual values passed to the function during invocation. C uses pass-by-value semantics, meaning arguments are copied into parameters, and modifications to parameters do not affect the original variables.

Parameter names in the declaration are optional but improve code readability. Parameter types must match argument types, or implicit conversion rules apply. Functions can have zero parameters, indicated by `void` in the parameter list or empty parentheses.

Array parameters are treated specially because arrays cannot be passed by value. Instead, array names decay to pointers, effectively passing the array's address. This allows functions to modify array contents but prevents knowledge of the array's size without additional parameters.

**Key points:**

- Parameters are function variables receiving argument values
- Pass-by-value copies arguments into parameters
- Parameter modifications don't affect original variables
- Array parameters decay to pointers
- Implicit type conversion applies to arguments

**Example:**

```c
#include <stdio.h>

void modify_value(int x) {
    x = 100;  // Only modifies local copy
    printf("Inside function: x = %d\n", x);
}

void modify_array(int arr[], int size) {
    arr[0] = 999;  // Modifies original array
    printf("Inside function: arr[0] = %d\n", arr[0]);
}

void print_info(char name[], int age, float height) {
    printf("Name: %s, Age: %d, Height: %.1f\n", name, age, height);
}

int main() {
    int number = 42;
    int numbers[] = {1, 2, 3, 4, 5};
    
    printf("Before function: number = %d\n", number);
    modify_value(number);
    printf("After function: number = %d\n", number);
    
    printf("Before function: numbers[0] = %d\n", numbers[0]);
    modify_array(numbers, 5);
    printf("After function: numbers[0] = %d\n", numbers[0]);
    
    print_info("John", 25, 5.9);
    
    return 0;
}
```

