## Switch Statements


Switch statements provide an efficient way to execute different code blocks based on the value of a variable or expression.

### Basic Switch Syntax

```c
switch (expression) {
    case constant1:
        // Code for constant1
        break;
    case constant2:
        // Code for constant2
        break;
    case constant3:
        // Code for constant3
        break;
    default:
        // Default code
        break;
}
```

### Switch Statement Rules

- Expression must evaluate to an integer type (int, char, enum)
- Case labels must be compile-time constants
- Each case should end with break to prevent fall-through
- default case is optional but recommended

**Basic Example:**

```c
#include <stdio.h>

int main(void) {
    char operator = '+';
    double num1 = 10.5, num2 = 3.2, result;
    
    switch (operator) {
        case '+':
            result = num1 + num2;
            printf("%.2f + %.2f = %.2f\n", num1, num2, result);
            break;
        case '-':
            result = num1 - num2;
            printf("%.2f - %.2f = %.2f\n", num1, num2, result);
            break;
        case '*':
            result = num1 * num2;
            printf("%.2f * %.2f = %.2f\n", num1, num2, result);
            break;
        case '/':
            if (num2 != 0) {
                result = num1 / num2;
                printf("%.2f / %.2f = %.2f\n", num1, num2, result);
            } else {
                printf("Error: Division by zero\n");
            }
            break;
        default:
            printf("Invalid operator\n");
            break;
    }
    
    return 0;
}
```

### Fall-Through Behavior

When break statements are omitted, execution continues to the next case (fall-through).

**Intentional Fall-Through:**

```c
#include <stdio.h>

int main(void) {
    int month = 2;
    int days;
    
    switch (month) {
        case 1: case 3: case 5: case 7: case 8: case 10: case 12:
            days = 31;
            break;
        case 4: case 6: case 9: case 11:
            days = 30;
            break;
        case 2:
            days = 28;  // Simplified, not considering leap years
            break;
        default:
            printf("Invalid month\n");
            return 1;
    }
    
    printf("Month %d has %d days\n", month, days);
    return 0;
}
```

### Multiple Case Labels

Multiple case labels can share the same code block:

```c
#include <stdio.h>

int main(void) {
    char grade = 'B';
    
    switch (grade) {
        case 'A':
        case 'a':
            printf("Excellent!\n");
            break;
        case 'B':
        case 'b':
            printf("Good job!\n");
            break;
        case 'C':
        case 'c':
            printf("Average performance\n");
            break;
        case 'D':
        case 'd':
            printf("Below average\n");
            break;
        case 'F':
        case 'f':
            printf("Failed\n");
            break;
        default:
            printf("Invalid grade\n");
            break;
    }
    
    return 0;
}
```

