## Break and Continue Statements


Break and continue statements provide additional control over loop execution flow.

### break Statement

The break statement immediately exits the current loop or switch statement.

**In Loops:**

```c
#include <stdio.h>

int main(void) {
    // Break in for loop
    for (int i = 1; i <= 10; i++) {
        if (i == 6) {
            break;  // Exit loop when i equals 6
        }
        printf("%d ", i);
    }
    printf("\nLoop ended\n");
    
    // Break in while loop with search
    int numbers[] = {10, 25, 30, 45, 50};
    int target = 30;
    int found = 0;
    int i = 0;
    
    while (i < 5) {
        if (numbers[i] == target) {
            found = 1;
            break;
        }
        i++;
    }
    
    if (found) {
        printf("Found %d at position %d\n", target, i);
    } else {
        printf("Target not found\n");
    }
    
    return 0;
}
```

**In Switch Statement:**

```c
#include <stdio.h>

int main(void) {
    int day = 3;
    
    switch (day) {
        case 1:
            printf("Monday\n");
            break;  // Prevents fall-through
        case 2:
            printf("Tuesday\n");
            break;
        case 3:
            printf("Wednesday\n");
            break;  // Without this, would continue to case 4
        case 4:
            printf("Thursday\n");
            break;
        default:
            printf("Other day\n");
            break;
    }
    
    return 0;
}
```

### continue Statement

The continue statement skips the remaining code in the current iteration and moves to the next iteration.

**Examples:**

```c
#include <stdio.h>

int main(void) {
    // Skip even numbers
    printf("Odd numbers from 1 to 10: ");
    for (int i = 1; i <= 10; i++) {
        if (i % 2 == 0) {
            continue;  // Skip even numbers
        }
        printf("%d ", i);
    }
    printf("\n");
    
    // Skip negative numbers in sum calculation
    int numbers[] = {5, -3, 8, -1, 12, -7, 4};
    int sum = 0;
    int count = 0;
    
    for (int i = 0; i < 7; i++) {
        if (numbers[i] < 0) {
            continue;  // Skip negative numbers
        }
        sum += numbers[i];
        count++;
    }
    
    printf("Sum of positive numbers: %d\n", sum);
    printf("Count of positive numbers: %d\n", count);
    
    return 0;
}
```

**continue in while Loop:**

```c
#include <stdio.h>

int main(void) {
    int i = 0;
    
    while (i < 10) {
        i++;
        if (i % 3 == 0) {
            continue;  // Skip multiples of 3
        }
        printf("%d ", i);
    }
    printf("\n");
    
    return 0;
}
```

