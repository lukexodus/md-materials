## Type Conversion and Casting


Type conversion occurs when values of one data type are converted to another. Implicit conversion (automatic) happens during arithmetic operations, assignments, and function calls following promotion rules. Explicit conversion (casting) uses cast operators to force specific type changes.

Implicit conversion follows a hierarchy: char and short promote to int, then to unsigned int, long, unsigned long, float, double. Mixed-type arithmetic promotes operands to the highest-ranking type involved. Assignment conversions may truncate or lose precision when assigning larger types to smaller ones.

Explicit casting uses parentheses with the target type: `(type)expression`. This allows precise control over conversions but can lead to data loss or unexpected results if used carelessly. Pointer casting enables type reinterpretation but requires careful consideration of alignment and size requirements.

**Key points:**

- Implicit conversion follows promotion hierarchy
- Mixed arithmetic promotes to highest type
- Assignment may truncate values
- Explicit casting forces specific conversion
- Casting can cause data loss
- Pointer casting changes interpretation

**Example:**

```c
#include <stdio.h>

int main() {
    // Implicit conversion
    int i = 10;
    float f = 3.14f;
    double result = i + f;    // i promoted to float, then double
    
    char c = 'A';
    int ascii = c;            // Implicit char to int
    
    // Explicit casting
    double d = 9.7;
    int truncated = (int)d;   // Explicit cast, loses decimal
    
    float division = (float)5 / 2;  // Cast to avoid integer division
    
    // Potential data loss
    int large = 300;
    char small = (char)large; // May cause overflow
    
    printf("Implicit conversion result: %f\n", result);
    printf("Character '%c' as integer: %d\n", c, ascii);
    printf("Truncated double %f to int: %d\n", d, truncated);
    printf("Float division 5/2: %f\n", division);
    printf("Large int %d as char: %d\n", large, small);
    
    // Demonstration of promotion in arithmetic
    char a = 10, b = 20;
    char sum = a + b;  // Actually computed as int, then truncated
    printf("Character arithmetic: %d + %d = %d\n", a, b, sum);
    
    return 0;
}
```

**Output:**

```
Implicit conversion result: 13.140000
Character 'A' as integer: 65
Truncated double 9.700000 to int: 9
Float division 5/2: 2.500000
Large int 300 as char: 44
Character arithmetic: 10 + 20 = 30
```

Understanding data types and syntax rules forms the foundation for all C programming. These concepts directly impact memory usage, program performance, and correctness of calculations throughout more advanced topics.

---

