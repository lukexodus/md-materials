## First C Program Structure


Every C program follows a fundamental structure that includes preprocessor directives, function declarations, and the main function.

### Basic Program Template

```c
#include <stdio.h>  // Preprocessor directive

int main(void) {    // Main function
    printf("Hello, World!\n");  // Function call
    return 0;       // Return statement
}
```

### Program Components Breakdown

**Preprocessor Directives:**

- Begin with `#` symbol
- Processed before compilation
- `#include`: Insert header file contents
- `#define`: Create macros
- `#ifdef`, `#ifndef`: Conditional compilation

**Header Files:**

- `<stdio.h>`: Standard input/output functions
- `<stdlib.h>`: Standard library functions
- `<string.h>`: String manipulation functions
- `<math.h>`: Mathematical functions

**Main Function:**

- Program entry point
- Must return integer value
- `int main(void)`: No command-line arguments
- `int main(int argc, char *argv[])`: With command-line arguments

**Function Structure:**

```c
return_type function_name(parameter_list) {
    // Local variable declarations
    // Executable statements
    return value; // if return_type is not void
}
```

**Variable Declarations:**

- Must be declared before use (in C89/C90)
- C99 and later allow declarations anywhere
- Initialization can occur at declaration

**Comments:**

```c
// Single-line comment (C99 and later)
/* Multi-line comment
   Traditional C style */
```

### Extended Example

```c
#include <stdio.h>
#include <stdlib.h>

// Function prototype
int add_numbers(int a, int b);

int main(void) {
    int num1, num2, result;
    
    printf("Enter two integers: ");
    scanf("%d %d", &num1, &num2);
    
    result = add_numbers(num1, num2);
    
    printf("Sum: %d\n", result);
    
    return 0;
}

// Function definition
int add_numbers(int a, int b) {
    return a + b;
}
```

