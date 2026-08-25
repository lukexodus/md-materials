## Macro Definitions


Macros are text replacements defined using `#define` that allow symbolic names for constants, expressions, or code fragments. The preprocessor performs literal text substitution wherever the macro name appears.

**Object-like Macros** Simple text replacements without parameters:

```c
#define PI 3.14159
#define MAX_BUFFER 1024
#define COMPANY_NAME "Tech Corp"
```

**Function-like Macros** Macros that accept parameters and can perform more complex substitutions:

```c
#define SQUARE(x) ((x) * (x))
#define MAX(a,b) ((a) > (b) ? (a) : (b))
#define PRINT_VAR(var) printf(#var " = %d\n", var)
```

**Stringification and Token Pasting**

- `#` operator converts macro parameter to string literal
- `##` operator concatenates tokens

```c
#define STR(x) #x
#define CONCAT(a,b) a##b
#define DECLARE_VAR(type, name) type var_##name
```

**Key Points**

- Parentheses around parameters prevent precedence issues
- Macro expansion is purely textual
- Multi-line macros use backslash continuation
- Macros can be undefined with `#undef`

**Examples**

```c
#define DEBUG_PRINT(fmt, ...) \
    do { \
        if (DEBUG_MODE) \
            printf("DEBUG: " fmt "\n", ##__VA_ARGS__); \
    } while(0)

#define SWAP(type, a, b) do { \
    type temp = a; \
    a = b; \
    b = temp; \
} while(0)
```

