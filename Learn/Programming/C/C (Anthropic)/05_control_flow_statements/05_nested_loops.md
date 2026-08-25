## Nested Loops


Nested loops contain one or more loops inside another loop, useful for processing multi-dimensional data structures.

### Basic Nested Loop Structure

```c
for (outer_initialization; outer_condition; outer_increment) {
    for (inner_initialization; inner_condition; inner_increment) {
        // Inner loop body
    }
    // Outer loop body (after inner loop completes)
}
```

### Multiplication Table

```c
#include <stdio.h>

int main(void) {
    printf("Multiplication Table (1-10):\n\n");
    
    // Print header
    printf("    ");
    for (int i = 1; i <= 10; i++) {
        printf("%4d", i);
    }
    printf("\n");
    
    // Print separator
    printf("    ");
    for (int i = 1; i <= 10; i++) {
        printf("----");
    }
    printf("\n");
    
    // Print table
    for (int i = 1; i <= 10; i++) {
        printf("%2d |", i);
        for (int j = 1; j <= 10; j++) {
            printf("%4d", i * j);
        }
        printf("\n");
    }
    
    return 0;
}
```

### Pattern Printing

```c
#include <stdio.h>

int main(void) {
    int rows = 5;
    
    // Right triangle pattern
    printf("Right Triangle:\n");
    for (int i = 1; i <= rows; i++) {
        for (int j = 1; j <= i; j++) {
            printf("* ");
        }
        printf("\n");
    }
    
    // Pyramid pattern
    printf("\nPyramid:\n");
    for (int i = 1; i <= rows; i++) {
        // Print spaces
        for (int j = 1; j <= rows - i; j++) {
            printf(" ");
        }
        // Print stars
        for (int j = 1; j <= 2 * i - 1; j++) {
            printf("*");
        }
        printf("\n");
    }
    
    return 0;
}
```

### Matrix Operations

```c
#include <stdio.h>

int main(void) {
    int matrix[3][3] = {
        {1, 2, 3},
        {4, 5, 6},
        {7, 8, 9}
    };
    
    // Print matrix
    printf("Original Matrix:\n");
    for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
            printf("%d ", matrix[i][j]);
        }
        printf("\n");
    }
    
    // Calculate transpose
    int transpose[3][3];
    for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
            transpose[j][i] = matrix[i][j];
        }
    }
    
    printf("\nTranspose Matrix:\n");
    for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
            printf("%d ", transpose[i][j]);
        }
        printf("\n");
    }
    
    return 0;
}
```

### Nested Loops with Break and Continue

```c
#include <stdio.h>

int main(void) {
    // Find first pair that sums to target
    int numbers[] = {1, 3, 5, 7, 9, 2, 4, 6, 8};
    int size = 9;
    int target = 10;
    int found = 0;
    
    for (int i = 0; i < size && !found; i++) {
        for (int j = i + 1; j < size; j++) {
            if (numbers[i] + numbers[j] == target) {
                printf("Found pair: %d + %d = %d\n", 
                       numbers[i], numbers[j], target);
                found = 1;
                break;  // Break inner loop
            }
        }
    }
    
    if (!found) {
        printf("No pair found that sums to %d\n", target);
    }
    
    return 0;
}
```

### Prime Number Checker with Nested Loops

```c
#include <stdio.h>

int main(void) {
    int start = 2, end = 20;
    
    printf("Prime numbers between %d and %d:\n", start, end);
    
    for (int num = start; num <= end; num++) {
        int isPrime = 1;  // Assume prime
        
        // Check for factors
        for (int i = 2; i * i <= num; i++) {
            if (num % i == 0) {
                isPrime = 0;  // Not prime
                break;        // No need to check further
            }
        }
        
        if (isPrime && num > 1) {
            printf("%d ", num);
        }
    }
    printf("\n");
    
    return 0;
}
```

### Complex Nested Loop Example

```c
#include <stdio.h>

int main(void) {
    // Find all Pythagorean triplets (a, b, c) where a² + b² = c²
    // and a, b, c are positive integers less than 20
    
    printf("Pythagorean triplets (a² + b² = c²):\n");
    
    for (int a = 1; a < 20; a++) {
        for (int b = a; b < 20; b++) {  // b >= a to avoid duplicates
            for (int c = b; c < 20; c++) {  // c >= b
                if (a * a + b * b == c * c) {
                    printf("(%d, %d, %d): %d² + %d² = %d²\n", 
                           a, b, c, a, b, c);
                }
            }
        }
    }
    
    return 0;
}
```

**Key Points:**

- Control flow statements enable decision-making and repetition in programs
- Proper use of break and continue statements can optimize loop performance
- Nested structures increase complexity but provide powerful programming capabilities
- [Inference] Switch statements generally provide better performance than multiple if-else statements for discrete value comparisons
- Loop choice depends on whether the number of iterations is known beforehand (for) or depends on runtime conditions (while/do-while)
- Nested loops have multiplicative time complexity, requiring careful consideration for performance-critical applications

Understanding control flow statements is essential for creating efficient, readable, and maintainable C programs that can handle complex logic and data processing requirements.

---

