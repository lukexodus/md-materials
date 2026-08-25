## Function Pointers


Function pointers are variables that store the address of functions, enabling indirect function calls and runtime function selection. The syntax for declaring function pointers specifies the return type and parameter list of the functions they can point to. Function pointers enable callbacks, function tables, and dynamic function dispatch.

Function pointer declaration follows the pattern: `return_type (*pointer_name)(parameter_types)`. The parentheses around `*pointer_name` are crucial to distinguish from functions returning pointers. Function pointers can be assigned function addresses using the function name or the address-of operator.

Arrays of function pointers create jump tables for efficient function selection based on indices or computed values. Function pointers can be passed as parameters to other functions, enabling callback mechanisms and generic programming techniques. Typedef can simplify complex function pointer declarations and improve code readability.

**Key points:**

- Store addresses of functions for indirect calls
- Declaration specifies return type and parameters
- Enable callbacks and dynamic function selection
- Arrays create function jump tables
- Typedef simplifies complex declarations

**Example:**

```c
#include <stdio.h>

// Functions to be pointed to
int add(int a, int b) {
    return a + b;
}

int subtract(int a, int b) {
    return a - b;
}

int multiply(int a, int b) {
    return a * b;
}

// Function taking function pointer as parameter
int calculate(int x, int y, int (*operation)(int, int)) {
    return operation(x, y);
}

// Callback function example
void process_array(int arr[], int size, void (*callback)(int)) {
    for (int i = 0; i < size; i++) {
        callback(arr[i]);
    }
}

void print_element(int value) {
    printf("%d ", value);
}

void print_square(int value) {
    printf("%d ", value * value);
}

// Typedef for cleaner syntax
typedef int (*MathOperation)(int, int);
typedef void (*ElementProcessor)(int);

int main() {
    // Basic function pointer usage
    int (*func_ptr)(int, int);
    
    func_ptr = add;
    printf("Addition: %d\n", func_ptr(5, 3));
    
    func_ptr = subtract;
    printf("Subtraction: %d\n", func_ptr(5, 3));
    
    // Function pointer as parameter
    int result1 = calculate(10, 4, add);
    int result2 = calculate(10, 4, multiply);
    printf("Calculate with add: %d\n", result1);
    printf("Calculate with multiply: %d\n", result2);
    
    // Array of function pointers (jump table)
    int (*operations[])(int, int) = {add, subtract, multiply};
    char* names[] = {"Add", "Subtract", "Multiply"};
    
    for (int i = 0; i < 3; i++) {
        int result = operations[i](8, 2);
        printf("%s: %d\n", names[i], result);
    }
    
    // Callback function demonstration
    int numbers[] = {1, 2, 3, 4, 5};
    int size = sizeof(numbers) / sizeof(numbers[0]);
    
    printf("Original array: ");
    process_array(numbers, size, print_element);
    printf("\n");
    
    printf("Squared values: ");
    process_array(numbers, size, print_square);
    printf("\n");
    
    // Using typedef for cleaner syntax
    MathOperation math_op = multiply;
    ElementProcessor processor = print_element;
    
    printf("Using typedef - multiplication: %d\n", math_op(6, 7));
    printf("Using typedef - processing: ");
    processor(42);
    printf("\n");
    
    return 0;
}
```

**Output:**

```
Addition: 8
Subtraction: 2
Calculate with add: 14
Calculate with multiply: 40
Add: 10
Subtract: 6
Multiply: 16
Original array: 1 2 3 4 5 
Squared values: 1 4 9 16 25 
Using typedef - multiplication: 42
Using typedef - processing: 42 
```

Functions serve as the primary building blocks for modular programming in C, enabling code reusability, abstraction, and organized program structure. Understanding parameter passing, scope rules, and advanced concepts like recursion and function pointers provides the foundation for implementing complex algorithms and software architectures.

---

