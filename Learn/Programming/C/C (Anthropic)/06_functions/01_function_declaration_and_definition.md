## Function Declaration and Definition


Function declaration establishes the function's interface, specifying its name, return type, and parameter list without providing the implementation. This forward declaration allows the compiler to verify function calls before encountering the actual definition. Function definition provides the complete implementation including the function body enclosed in braces.

The function signature consists of the return type, function name, and parameter list. Function names follow identifier rules and should be descriptive of their purpose. The return type can be any valid C data type or `void` for functions that do not return values. Parameter lists specify the data types and names of values the function accepts.

Function definitions can appear before or after their usage, but declarations must precede any function calls. Header files typically contain function declarations, while source files contain definitions. The `main()` function serves as the program entry point and has a special signature recognized by the runtime system.

**Key points:**

- Declaration specifies interface without implementation
- Definition provides complete function implementation
- Forward declarations enable calls before definition
- Function signature includes return type, name, parameters
- main() function serves as program entry point

**Example:**

```c
#include <stdio.h>

// Function declaration (prototype)
int add(int a, int b);
void print_message(void);
double calculate_area(double radius);

int main() {
    int sum = add(5, 3);
    print_message();
    double area = calculate_area(2.5);
    
    printf("Sum: %d\n", sum);
    printf("Area: %.2f\n", area);
    
    return 0;
}

// Function definitions
int add(int a, int b) {
    return a + b;
}

void print_message(void) {
    printf("Hello from function!\n");
}

double calculate_area(double radius) {
    const double PI = 3.14159;
    return PI * radius * radius;
}
```

