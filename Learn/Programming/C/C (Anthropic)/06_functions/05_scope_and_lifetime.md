## Scope and Lifetime


Scope defines the region of code where an identifier is visible and accessible. C has four scope levels: block scope (within braces), function scope (labels only), file scope (global), and function prototype scope (parameter names in declarations).

Block scope applies to variables declared within any set of braces, including function bodies, control structures, and arbitrary code blocks. Variables in inner blocks can hide variables in outer blocks with the same name. Function scope applies only to goto labels, which are visible throughout the entire function.

Lifetime refers to the duration an object exists in memory. Automatic variables have automatic storage duration, existing only while their scope is active. Static variables have static storage duration, existing for the entire program execution. Dynamic variables have allocated storage duration, controlled by malloc and free.

**Key points:**

- Scope determines identifier visibility regions
- Block scope applies within braces
- Inner scope variables hide outer scope
- Lifetime controls object memory duration
- Storage classes affect scope and lifetime

**Example:**

```c
#include <stdio.h>

int file_scope = 10;  // File scope

void demonstrate_scope() {
    int outer = 20;   // Block scope
    printf("Outer variable: %d\n", outer);
    
    {
        int inner = 30;      // Inner block scope
        int outer = 40;      // Hides outer scope 'outer'
        printf("Inner block - inner: %d, outer: %d\n", inner, outer);
        printf("File scope from inner: %d\n", file_scope);
    }
    
    printf("Back to outer block: %d\n", outer);
    // printf("%d\n", inner);  // Error: inner not in scope
}

void demonstrate_storage_classes() {
    static int static_var = 1;
    auto int auto_var = 2;      // 'auto' is default, rarely used
    register int reg_var = 3;   // Hint for register storage
    
    static_var++;
    auto_var++;
    reg_var++;
    
    printf("Static: %d, Auto: %d, Register: %d\n", 
           static_var, auto_var, reg_var);
}

int main() {
    printf("File scope: %d\n", file_scope);
    
    demonstrate_scope();
    
    // Demonstrate lifetime differences
    for (int i = 0; i < 3; i++) {
        demonstrate_storage_classes();
    }
    
    // Loop variable scope
    for (int loop_var = 0; loop_var < 2; loop_var++) {
        printf("Loop iteration: %d\n", loop_var);
    }
    // printf("%d\n", loop_var);  // Error: loop_var not in scope
    
    return 0;
}
```

