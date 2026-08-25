## Return Values


Functions can return a single value to the calling code using the `return` statement. The return type must be declared in the function signature and can be any valid C data type except arrays (though pointers to arrays are allowed). Functions with `void` return type do not return values and may omit the return statement or use `return;` without a value.

The return statement immediately terminates function execution and transfers control back to the caller. Multiple return statements are allowed within a function, but only one executes per function call. Return values should match the declared return type, or implicit conversion applies.

Functions returning pointers must ensure the pointed-to memory remains valid after the function returns. Returning addresses of local variables creates dangling pointers and undefined behavior. Dynamic memory allocation or static variables provide valid return addresses.

**Key points:**

- return statement terminates function and returns value
- Return type must match function declaration
- Multiple return statements allowed per function
- void functions don't return values
- Returning local variable addresses creates undefined behavior

**Example:**

```c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int max(int a, int b) {
    if (a > b) {
        return a;
    } else {
        return b;
    }
}

double divide(double a, double b) {
    if (b == 0) {
        printf("Error: Division by zero\n");
        return 0.0;  // Error value
    }
    return a / b;
}

char* create_greeting(const char* name) {
    static char buffer[100];  // Static storage persists after return
    sprintf(buffer, "Hello, %s!", name);
    return buffer;
}

char* allocate_string(int length) {
    char* str = malloc(length * sizeof(char));
    if (str == NULL) {
        return NULL;  // Allocation failed
    }
    return str;  // Valid pointer to dynamically allocated memory
}

int main() {
    int maximum = max(15, 8);
    printf("Maximum: %d\n", maximum);
    
    double result = divide(10.0, 3.0);
    printf("Division result: %.2f\n", result);
    
    char* greeting = create_greeting("Alice");
    printf("%s\n", greeting);
    
    char* dynamic_str = allocate_string(50);
    if (dynamic_str != NULL) {
        strcpy(dynamic_str, "Dynamic allocation successful");
        printf("%s\n", dynamic_str);
        free(dynamic_str);  // Clean up
    }
    
    return 0;
}
```

