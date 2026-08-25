## Constants and Literals


Constants are fixed values that do not change during program execution. Literal constants are written directly in the source code, while symbolic constants are created using the `const` keyword or `#define` preprocessor directive.

Integer literals can be decimal (base 10), octal (base 8 with leading 0), or hexadecimal (base 16 with leading 0x). Floating-point literals contain decimal points or exponential notation. Character literals are enclosed in single quotes, while string literals use double quotes.

Suffix letters modify literal interpretation: 'L' for long integers, 'U' for unsigned, 'F' for float. Escape sequences represent special characters using backslash notation (\n for newline, \t for tab, \ for backslash).

**Key points:**

- Literals are constant values in source code
- Integer literals: decimal, octal, hexadecimal
- Floating literals with decimal point or exponent
- Character literals in single quotes
- String literals in double quotes
- Suffixes modify literal type

**Example:**

```c
#include <stdio.h>
#define PI 3.14159

int main() {
    // Integer literals
    int decimal = 42;
    int octal = 052;        // 42 in octal
    int hex = 0x2A;         // 42 in hexadecimal
    long big = 123456789L;
    unsigned int positive = 42U;
    
    // Floating-point literals
    float pi = 3.14159f;
    double precise = 3.141592653589793;
    double scientific = 1.23e-4;
    
    // Character and string literals
    char letter = 'A';
    char newline = '\n';
    char backslash = '\\';
    char quote = '\'';
    
    const int MAX_SIZE = 1000;
    
    printf("Decimal: %d, Octal: %d, Hex: %d\n", decimal, octal, hex);
    printf("PI constant: %f\n", PI);
    printf("Character: %c, ASCII: %d\n", letter, letter);
    
    return 0;
}
```

