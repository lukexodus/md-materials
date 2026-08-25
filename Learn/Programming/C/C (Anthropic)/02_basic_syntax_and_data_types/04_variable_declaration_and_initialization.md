## Variable Declaration and Initialization


Variables must be declared before use, specifying both the data type and identifier name. Declaration can occur at any point within a scope, but good practice places declarations at the beginning of blocks or as close to first use as possible.

Initialization can occur during declaration or separately through assignment. Uninitialized variables contain garbage values and should never be used before explicit assignment. Global and static variables are automatically initialized to zero, while automatic variables contain indeterminate values.

Multiple variables of the same type can be declared in a single statement using comma separation. The `const` qualifier creates read-only variables that cannot be modified after initialization.

**Key points:**

- Declaration specifies type and name
- Initialization assigns initial value
- Uninitialized locals contain garbage values
- Global/static variables auto-initialize to zero
- const qualifier prevents modification

**Example:**

```c
#include <stdio.h>

int global_var;  // Automatically initialized to 0

int main() {
    int a;                    // Uninitialized (garbage value)
    int b = 10;              // Initialized during declaration
    int c = 20, d = 30;      // Multiple initialization
    const int MAX = 100;     // Constant variable
    
    a = 5;                   // Assignment after declaration
    
    printf("a: %d, b: %d, c: %d, d: %d\n", a, b, c, d);
    printf("Global: %d, Constant: %d\n", global_var, MAX);
    
    return 0;
}
```

