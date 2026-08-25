## Arrays of Function Pointers


Arrays of function pointers enable function dispatch tables and polymorphic behavior.

**Function Dispatch Table**

```c
#include <stdio.h>

double add_op(double a, double b) { return a + b; }
double sub_op(double a, double b) { return a - b; }
double mul_op(double a, double b) { return a * b; }
double div_op(double a, double b) { return b != 0 ? a / b : 0; }

int main() {
    // Array of function pointers
    double (*operations[])(double, double) = {
        add_op, sub_op, mul_op, div_op
    };
    
    char operators[] = {'+', '-', '*', '/'};
    double a = 10.0, b = 3.0;
    
    for (int i = 0; i < 4; i++) {
        printf("%.2f %c %.2f = %.2f\n", 
               a, operators[i], b, operations[i](a, b));
    }
    
    return 0;
}
```

**Menu-Driven System**

```c
#include <stdio.h>

void option1() { printf("Option 1 selected\n"); }
void option2() { printf("Option 2 selected\n"); }
void option3() { printf("Option 3 selected\n"); }

int main() {
    void (*menu_functions[])(void) = {option1, option2, option3};
    char *menu_items[] = {"Option 1", "Option 2", "Option 3"};
    int choice;
    
    do {
        printf("\nMenu:\n");
        for (int i = 0; i < 3; i++) {
            printf("%d. %s\n", i + 1, menu_items[i]);
        }
        printf("0. Exit\nChoice: ");
        scanf("%d", &choice);
        
        if (choice >= 1 && choice <= 3) {
            menu_functions[choice - 1]();
        }
    } while (choice != 0);
    
    return 0;
}
```

