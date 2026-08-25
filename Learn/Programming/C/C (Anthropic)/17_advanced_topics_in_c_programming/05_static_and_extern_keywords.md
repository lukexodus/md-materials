## Static and Extern Keywords


The `static` and `extern` keywords control the visibility, linkage, and storage duration of variables and functions across compilation units.

**Static Keyword Usage**

**Static Variables in Functions** Static local variables retain their value between function calls:

```c
#include <stdio.h>

int counter() {
    static int count = 0;  // Initialized only once
    return ++count;
}

int main() {
    printf("%d\n", counter());  // Prints: 1
    printf("%d\n", counter());  // Prints: 2
    printf("%d\n", counter());  // Prints: 3
    return 0;
}
```

**Static Global Variables** Static global variables have internal linkage (file scope only):

```c
// file1.c
static int private_variable = 100;  // Not visible outside file1.c

static void private_function() {    // Not visible outside file1.c
    printf("This is private\n");
}

void public_function() {
    private_function();  // OK - same file
    printf("Private var: %d\n", private_variable);
}
```

**Extern Keyword Usage**

**External Variable Declarations**

```c
// globals.c - Definition
int global_counter = 0;
char global_buffer[1024];

// main.c - Declaration
extern int global_counter;
extern char global_buffer[];

int main() {
    global_counter = 42;
    strcpy(global_buffer, "Hello");
    return 0;
}
```

**External Function Declarations**

```c
// math.c
double calculate_pi() {
    return 3.14159265359;
}

// main.c
extern double calculate_pi();  // Declaration (optional for functions)

int main() {
    printf("PI = %f\n", calculate_pi());
    return 0;
}
```

**Examples**

**Module with Private State**

```c
// counter_module.c
static int internal_counter = 0;
static int max_value = 100;

// Private helper function
static void reset_if_needed() {
    if (internal_counter >= max_value) {
        internal_counter = 0;
    }
}

// Public interface functions
int increment_counter() {
    internal_counter++;
    reset_if_needed();
    return internal_counter;
}

int get_counter() {
    return internal_counter;
}

void set_max_value(int max) {
    max_value = max;
}
```

```c
// counter_module.h
#ifndef COUNTER_MODULE_H
#define COUNTER_MODULE_H

int increment_counter();
int get_counter();
void set_max_value(int max);

#endif
```

**Global Configuration System**

```c
// config.c
#include "config.h"

// Global configuration instance
app_settings_t g_settings = {
    .debug_mode = 0,
    .max_threads = 4,
    .buffer_size = 1024
};

// File-private validation function
static int validate_settings(const app_settings_t* settings) {
    return settings->max_threads > 0 && settings->buffer_size > 0;
}

int update_settings(const app_settings_t* new_settings) {
    if (!validate_settings(new_settings)) {
        return -1;
    }
    g_settings = *new_settings;
    return 0;
}
```

```c
// config.h
#ifndef CONFIG_H
#define CONFIG_H

typedef struct {
    int debug_mode;
    int max_threads;
    int buffer_size;
} app_settings_t;

// External declaration
extern app_settings_t g_settings;

// Function declarations
int update_settings(const app_settings_t* new_settings);

#endif
```

**Static Array Initialization**

```c
// lookup_table.c
// Static lookup table - internal linkage
static const int fibonacci_cache[] = {
    0, 1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144, 233, 377
};

static const size_t cache_size = sizeof(fibonacci_cache) / sizeof(fibonacci_cache[0]);

int get_fibonacci(int n) {
    if (n >= 0 && n < cache_size) {
        return fibonacci_cache[n];
    }
    return -1;  // Out of range
}
```

**Library State Management**

```c
// logger.c
#include <stdio.h>
#include <time.h>

static FILE* log_file = NULL;
static int log_level = 1;

// Private initialization
static int ensure_log_file() {
    if (!log_file) {
        log_file = fopen("application.log", "a");
        return log_file != NULL;
    }
    return 1;
}

// Public interface
int init_logger(const char* filename, int level) {
    if (log_file) {
        fclose(log_file);
    }
    
    log_file = fopen(filename, "a");
    log_level = level;
    return log_file != NULL;
}

void log_message(int level, const char* message) {
    if (level <= log_level && ensure_log_file()) {
        time_t now = time(NULL);
        fprintf(log_file, "[%s] %s\n", ctime(&now), message);
        fflush(log_file);
    }
}

void cleanup_logger() {
    if (log_file) {
        fclose(log_file);
        log_file = NULL;
    }
}
```

**Key Points**

- `static` at file scope creates internal linkage (private to file)
- `static` in functions creates persistent local variables
- `extern` declares variables/functions defined elsewhere
- One definition rule: exactly one definition per variable/function
- Header files should contain declarations, not definitions
- Static variables are zero-initialized by default
- External linkage allows sharing across compilation units

**Linkage Summary**

- **No linkage**: Local variables, function parameters
- **Internal linkage**: Static globals, static functions
- **External linkage**: Global variables, regular functions
- **extern** keyword provides external linkage declaration without definition

These advanced topics enable sophisticated C programming techniques including flexible function interfaces, robust command-line programs, system-aware applications, modular code organization, and proper encapsulation through controlled visibility and linkage.

---

