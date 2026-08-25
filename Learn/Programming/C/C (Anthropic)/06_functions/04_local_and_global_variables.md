## Local and Global Variables


Local variables are declared within function bodies and exist only during function execution. They are stored on the stack and automatically destroyed when the function returns. Local variables hide global variables with the same name within their scope.

Global variables are declared outside all functions and exist for the entire program duration. They are stored in the data segment and initialized to zero by default. Global variables are accessible from any function following their declaration unless hidden by local variables.

Static local variables combine local scope with global lifetime. Declared with the `static` keyword inside functions, they retain their values between function calls. Static global variables have file scope, limiting their visibility to the current source file.

**Key points:**

- Local variables exist only during function execution
- Global variables exist for entire program duration
- Local variables hide globals with same name
- Static locals retain values between calls
- Static globals have file-only scope

**Example:**

```c
#include <stdio.h>

int global_counter = 0;  // Global variable

void increment_global() {
    global_counter++;
    printf("Global counter: %d\n", global_counter);
}

void demonstrate_local() {
    int global_counter = 100;  // Local variable hides global
    printf("Local counter: %d\n", global_counter);
}

void static_counter() {
    static int count = 0;  // Static local variable
    count++;
    printf("Static counter: %d\n", count);
}

void automatic_counter() {
    int count = 0;  // Automatic local variable
    count++;
    printf("Automatic counter: %d\n", count);
}

int main() {
    printf("Initial global: %d\n", global_counter);
    
    increment_global();
    increment_global();
    
    demonstrate_local();
    printf("Global after local demo: %d\n", global_counter);
    
    static_counter();
    static_counter();
    static_counter();
    
    automatic_counter();
    automatic_counter();
    automatic_counter();
    
    return 0;
}
```

