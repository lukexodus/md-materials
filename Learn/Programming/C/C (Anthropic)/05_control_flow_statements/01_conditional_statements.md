## Conditional Statements


Conditional statements execute different code blocks based on boolean expressions, enabling programs to make decisions during runtime.

### if Statement

The if statement executes a block of code when a specified condition evaluates to true (non-zero).

**Basic Syntax:**

```c
if (condition) {
    // Code executed when condition is true
}
```

**Single Statement (without braces):**

```c
if (x > 0)
    printf("x is positive\n");
```

**Examples:**

```c
#include <stdio.h>

int main(void) {
    int age = 18;
    
    if (age >= 18) {
        printf("You are eligible to vote\n");
    }
    
    int temperature = 75;
    if (temperature > 80)
        printf("It's hot outside\n");
    
    return 0;
}
```

**Comparison Operators:**

- `==` : Equal to
- `!=` : Not equal to
- `>` : Greater than
- `<` : Less than
- `>=` : Greater than or equal to
- `<=` : Less than or equal to

**Logical Operators:**

- `&&` : Logical AND
- `||` : Logical OR
- `!` : Logical NOT

```c
int score = 85;
int attendance = 90;

if (score >= 80 && attendance >= 85) {
    printf("Excellent performance\n");
}

if (score < 60 || attendance < 75) {
    printf("Needs improvement\n");
}
```

### if-else Statement

The if-else statement provides an alternative execution path when the condition is false.

**Basic Syntax:**

```c
if (condition) {
    // Code executed when condition is true
} else {
    // Code executed when condition is false
}
```

**Examples:**

```c
#include <stdio.h>

int main(void) {
    int number = -5;
    
    if (number >= 0) {
        printf("Number is non-negative\n");
    } else {
        printf("Number is negative\n");
    }
    
    char grade = 'B';
    if (grade == 'A') {
        printf("Excellent work!\n");
    } else {
        printf("Keep trying for an A\n");
    }
    
    return 0;
}
```

### if-else if-else Chain

Multiple conditions can be tested sequentially using if-else if-else chains.

**Syntax:**

```c
if (condition1) {
    // Code for condition1
} else if (condition2) {
    // Code for condition2
} else if (condition3) {
    // Code for condition3
} else {
    // Default code
}
```

**Example:**

```c
#include <stdio.h>

int main(void) {
    int score = 87;
    
    if (score >= 90) {
        printf("Grade: A\n");
    } else if (score >= 80) {
        printf("Grade: B\n");
    } else if (score >= 70) {
        printf("Grade: C\n");
    } else if (score >= 60) {
        printf("Grade: D\n");
    } else {
        printf("Grade: F\n");
    }
    
    return 0;
}
```

### Nested if Statements

if statements can be nested inside other if statements to create more complex decision structures.

**Example:**

```c
#include <stdio.h>

int main(void) {
    int age = 25;
    int hasLicense = 1;  // 1 for true, 0 for false
    
    if (age >= 16) {
        if (hasLicense) {
            printf("You can drive\n");
        } else {
            printf("You need a license to drive\n");
        }
    } else {
        printf("You are too young to drive\n");
    }
    
    return 0;
}
```

**Complex Nested Example:**

```c
#include <stdio.h>

int main(void) {
    int year = 2024;
    
    if (year % 4 == 0) {
        if (year % 100 == 0) {
            if (year % 400 == 0) {
                printf("%d is a leap year\n", year);
            } else {
                printf("%d is not a leap year\n", year);
            }
        } else {
            printf("%d is a leap year\n", year);
        }
    } else {
        printf("%d is not a leap year\n", year);
    }
    
    return 0;
}
```

### Ternary Operator

The ternary operator provides a concise way to write simple if-else statements.

**Syntax:**

```c
condition ? expression_if_true : expression_if_false
```

**Examples:**

```c
#include <stdio.h>

int main(void) {
    int a = 10, b = 20;
    int max = (a > b) ? a : b;
    printf("Maximum: %d\n", max);
    
    int number = 7;
    printf("%d is %s\n", number, (number % 2 == 0) ? "even" : "odd");
    
    return 0;
}
```

