## Variable Argument Functions


Variable argument functions (variadic functions) accept a variable number of parameters using ellipsis notation (...). They provide flexibility for functions that need to handle different numbers of arguments, like printf() and scanf().

**Header Requirements** The `<stdarg.h>` header provides macros for accessing variable arguments:

- `va_list` - type to hold argument information
- `va_start()` - initialize argument list processing
- `va_arg()` - retrieve next argument
- `va_end()` - cleanup argument list processing

**Function Declaration Syntax**

```c
return_type function_name(fixed_params, ...);
```

At least one fixed parameter is required before the ellipsis. The fixed parameters help determine the number or types of variable arguments.

**Basic Implementation Pattern**

```c
#include <stdarg.h>
#include <stdio.h>

int sum_integers(int count, ...) {
    va_list args;
    va_start(args, count);  // count is last fixed parameter
    
    int total = 0;
    for (int i = 0; i < count; i++) {
        int value = va_arg(args, int);  // retrieve int argument
        total += value;
    }
    
    va_end(args);
    return total;
}

// Usage
int result = sum_integers(4, 10, 20, 30, 40);  // Returns 100
```

**Type Safety Considerations** Variable argument functions have no compile-time type checking for variable parameters. The programmer must ensure correct types and counts.

**Examples**

**Printf-style Function**

```c
void debug_printf(const char *format, ...) {
    va_list args;
    va_start(args, format);
    
    printf("[DEBUG] ");
    vprintf(format, args);  // Use v-variant for va_list
    printf("\n");
    
    va_end(args);
}
```

**Generic Data Processing**

```c
#include <stdarg.h>
#include <stdio.h>

typedef enum {
    TYPE_INT,
    TYPE_DOUBLE,
    TYPE_STRING
} data_type;

void print_values(int count, ...) {
    va_list args;
    va_start(args, count);
    
    for (int i = 0; i < count; i += 2) {
        data_type type = va_arg(args, data_type);
        
        switch (type) {
            case TYPE_INT:
                printf("Int: %d\n", va_arg(args, int));
                break;
            case TYPE_DOUBLE:
                printf("Double: %.2f\n", va_arg(args, double));
                break;
            case TYPE_STRING:
                printf("String: %s\n", va_arg(args, char*));
                break;
        }
    }
    
    va_end(args);
}

// Usage
print_values(6, TYPE_INT, 42, TYPE_DOUBLE, 3.14, TYPE_STRING, "Hello");
```

**Advanced Variadic Techniques**

```c
// Function that accepts different callback signatures
typedef void (*callback_t)(void);

void call_functions(int count, ...) {
    va_list args;
    va_start(args, count);
    
    for (int i = 0; i < count; i++) {
        callback_t func = va_arg(args, callback_t);
        func();
    }
    
    va_end(args);
}
```

**Key Points**

- At least one fixed parameter is required
- No automatic type conversion or checking
- Arguments undergo default promotions (float→double, char→int)
- Stack cleanup is caller's responsibility
- Not suitable for type-unsafe operations

