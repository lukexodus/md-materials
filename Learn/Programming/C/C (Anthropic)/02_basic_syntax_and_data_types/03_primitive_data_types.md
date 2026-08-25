## Primitive Data Types


C provides fundamental data types that represent basic values directly supported by the processor. Integer types include `char` (1 byte), `short` (2 bytes), `int` (4 bytes on most systems), and `long` (8 bytes on 64-bit systems). Floating-point types include `float` (4 bytes, single precision) and `double` (8 bytes, double precision).

Each integer type can be modified with `signed` or `unsigned` qualifiers, affecting the range of representable values. The `void` type represents the absence of a value and is used for functions that do not return values or for generic pointers.

Size and range vary by system architecture, but the `sizeof` operator provides exact byte sizes at runtime. The `limits.h` and `float.h` header files define minimum and maximum values for each type.

**Key points:**

- Integer types: char, short, int, long
- Floating-point types: float, double
- Size varies by architecture
- signed/unsigned modifiers available
- void represents absence of value

**Example:**

```c
#include <stdio.h>
#include <limits.h>

int main() {
    char c = 'A';
    short s = 32000;
    int i = 2147483647;
    long l = 9223372036854775807L;
    float f = 3.14159f;
    double d = 3.141592653589793;
    
    printf("char size: %zu bytes, range: %d to %d\n", 
           sizeof(char), CHAR_MIN, CHAR_MAX);
    printf("int size: %zu bytes, range: %d to %d\n", 
           sizeof(int), INT_MIN, INT_MAX);
    
    return 0;
}
```

