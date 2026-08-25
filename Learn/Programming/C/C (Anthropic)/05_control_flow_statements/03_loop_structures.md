## Loop Structures


Loops enable repetitive execution of code blocks, essential for processing collections of data and implementing iterative algorithms.

### for Loop

The for loop provides initialization, condition checking, and increment/decrement in a single statement.

**Basic Syntax:**

```c
for (initialization; condition; increment/decrement) {
    // Loop body
}
```

**Execution Flow:**

1. Initialization (executed once)
2. Condition check (before each iteration)
3. Loop body execution
4. Increment/decrement
5. Return to step 2

**Basic Examples:**

```c
#include <stdio.h>

int main(void) {
    // Basic counting loop
    for (int i = 1; i <= 5; i++) {
        printf("Iteration %d\n", i);
    }
    
    // Countdown loop
    for (int i = 10; i >= 1; i--) {
        printf("Countdown: %d\n", i);
    }
    
    // Step increment
    for (int i = 0; i <= 20; i += 5) {
        printf("Value: %d\n", i);
    }
    
    return 0;
}
```

**Array Processing:**

```c
#include <stdio.h>

int main(void) {
    int numbers[] = {10, 20, 30, 40, 50};
    int size = sizeof(numbers) / sizeof(numbers[0]);
    int sum = 0;
    
    for (int i = 0; i < size; i++) {
        sum += numbers[i];
        printf("numbers[%d] = %d\n", i, numbers[i]);
    }
    
    printf("Sum: %d\n", sum);
    
    return 0;
}
```

**Infinite for Loop:**

```c
for (;;) {
    // Infinite loop - be careful!
    // Must have break condition inside
    if (some_condition) {
        break;
    }
}
```

### while Loop

The while loop continues execution as long as the specified condition remains true.

**Basic Syntax:**

```c
while (condition) {
    // Loop body
}
```

**Examples:**

```c
#include <stdio.h>

int main(void) {
    int count = 1;
    
    while (count <= 5) {
        printf("Count: %d\n", count);
        count++;
    }
    
    // Input validation
    int number;
    printf("Enter a positive number: ");
    scanf("%d", &number);
    
    while (number <= 0) {
        printf("Invalid input. Enter a positive number: ");
        scanf("%d", &number);
    }
    
    printf("You entered: %d\n", number);
    
    return 0;
}
```

**Factorial Calculation:**

```c
#include <stdio.h>

int main(void) {
    int n = 5;
    int factorial = 1;
    int temp = n;
    
    while (temp > 0) {
        factorial *= temp;
        temp--;
    }
    
    printf("Factorial of %d is %d\n", n, factorial);
    
    return 0;
}
```

### do-while Loop

The do-while loop executes the loop body at least once before checking the condition.

**Basic Syntax:**

```c
do {
    // Loop body
} while (condition);
```

**Examples:**

```c
#include <stdio.h>

int main(void) {
    int number;
    
    do {
        printf("Enter a number between 1 and 10: ");
        scanf("%d", &number);
        
        if (number < 1 || number > 10) {
            printf("Invalid input. Please try again.\n");
        }
    } while (number < 1 || number > 10);
    
    printf("You entered: %d\n", number);
    
    return 0;
}
```

**Menu System:**

```c
#include <stdio.h>

int main(void) {
    int choice;
    
    do {
        printf("\n=== MENU ===\n");
        printf("1. Option A\n");
        printf("2. Option B\n");
        printf("3. Option C\n");
        printf("0. Exit\n");
        printf("Enter choice: ");
        scanf("%d", &choice);
        
        switch (choice) {
            case 1:
                printf("You selected Option A\n");
                break;
            case 2:
                printf("You selected Option B\n");
                break;
            case 3:
                printf("You selected Option C\n");
                break;
            case 0:
                printf("Exiting program\n");
                break;
            default:
                printf("Invalid choice\n");
                break;
        }
    } while (choice != 0);
    
    return 0;
}
```

