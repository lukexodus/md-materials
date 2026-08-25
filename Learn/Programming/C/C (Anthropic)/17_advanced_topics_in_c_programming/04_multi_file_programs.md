## Multi-file Programs


Multi-file programs organize code into separate compilation units, promoting modularity, reusability, and maintainability. This involves header files, implementation files, and proper linking.

**Project Structure**

```
project/
├── src/
│   ├── main.c
│   ├── utils.c
│   └── math_ops.c
├── include/
│   ├── utils.h
│   └── math_ops.h
└── Makefile
```

**Header File Design** Headers declare interfaces without implementation:

```c
// math_ops.h
#ifndef MATH_OPS_H
#define MATH_OPS_H

// Function declarations
double add(double a, double b);
double multiply(double a, double b);
int factorial(int n);

// External variable declaration
extern const double PI;

// Macro definitions
#define SQUARE(x) ((x) * (x))

#endif
```

**Implementation File**

```c
// math_ops.c
#include "math_ops.h"
#include <stdio.h>

// External variable definition
const double PI = 3.14159265359;

double add(double a, double b) {
    return a + b;
}

double multiply(double a, double b) {
    return a * b;
}

int factorial(int n) {
    if (n <= 1) return 1;
    return n * factorial(n - 1);
}
```

**Examples**

**Modular String Utilities**

```c
// string_utils.h
#ifndef STRING_UTILS_H
#define STRING_UTILS_H

#include <stddef.h>

// String manipulation functions
char* string_duplicate(const char* src);
char* string_concat(const char* str1, const char* str2);
void string_reverse(char* str);
int string_compare_ignore_case(const char* str1, const char* str2);

// String analysis functions
size_t count_words(const char* str);
size_t count_occurrences(const char* str, char ch);

#endif
```

```c
// string_utils.c
#include "string_utils.h"
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

char* string_duplicate(const char* src) {
    if (!src) return NULL;
    
    size_t len = strlen(src);
    char* copy = malloc(len + 1);
    if (copy) {
        strcpy(copy, src);
    }
    return copy;
}

char* string_concat(const char* str1, const char* str2) {
    if (!str1 || !str2) return NULL;
    
    size_t len1 = strlen(str1);
    size_t len2 = strlen(str2);
    char* result = malloc(len1 + len2 + 1);
    
    if (result) {
        strcpy(result, str1);
        strcat(result, str2);
    }
    return result;
}

size_t count_words(const char* str) {
    if (!str) return 0;
    
    size_t count = 0;
    int in_word = 0;
    
    while (*str) {
        if (isspace(*str)) {
            in_word = 0;
        } else if (!in_word) {
            in_word = 1;
            count++;
        }
        str++;
    }
    return count;
}
```

**Configuration Module**

```c
// config.h
#ifndef CONFIG_H
#define CONFIG_H

typedef struct {
    char* database_url;
    int max_connections;
    int timeout_seconds;
    int debug_mode;
} app_config_t;

// Configuration management
int load_config(const char* filename, app_config_t* config);
void free_config(app_config_t* config);
void print_config(const app_config_t* config);

#endif
```

**Main Program Integration**

```c
// main.c
#include <stdio.h>
#include <stdlib.h>
#include "math_ops.h"
#include "string_utils.h"
#include "config.h"

int main(int argc, char* argv[]) {
    // Use math operations
    printf("5 + 3 = %.2f\n", add(5.0, 3.0));
    printf("Factorial of 5: %d\n", factorial(5));
    printf("PI = %.6f\n", PI);
    
    // Use string utilities
    char* greeting = string_concat("Hello, ", "World!");
    if (greeting) {
        printf("Greeting: %s\n", greeting);
        printf("Word count: %zu\n", count_words(greeting));
        free(greeting);
    }
    
    // Load configuration
    app_config_t config;
    if (load_config("app.conf", &config) == 0) {
        print_config(&config);
        free_config(&config);
    }
    
    return 0;
}
```

**Makefile for Building**

```makefile
CC = gcc
CFLAGS = -Wall -Wextra -std=c99 -Iinclude
SRCDIR = src
SOURCES = $(wildcard $(SRCDIR)/*.c)
OBJECTS = $(SOURCES:.c=.o)
TARGET = myprogram

$(TARGET): $(OBJECTS)
	$(CC) $(OBJECTS) -o $(TARGET)

$(SRCDIR)/%.o: $(SRCDIR)/%.c
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -f $(SRCDIR)/*.o $(TARGET)

.PHONY: clean
```

**Key Points**

- Header files declare interfaces, implementation files define them
- Use include guards to prevent multiple inclusion
- Organize related functions into logical modules
- Maintain consistent naming conventions across files
- Document module interfaces clearly

