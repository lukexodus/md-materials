## Memory Leaks and Debugging


Memory leaks occur when dynamically allocated memory is not properly deallocated, leading to gradual consumption of available memory resources.

**Common Causes of Memory Leaks:**

**Missing free() Calls:**

```c
void leaky_function() {
    int *ptr = (int*)malloc(100 * sizeof(int));
    // Function returns without calling free(ptr)
    return;  // Memory leak!
}
```

**Lost Pointers:**

```c
int *ptr = (int*)malloc(50 * sizeof(int));
ptr = (int*)malloc(100 * sizeof(int));  // First allocation lost!
free(ptr);  // Only frees second allocation
```

**Exception/Early Returns:**

```c
int process_data(int size) {
    int *data = (int*)malloc(size * sizeof(int));
    
    if (size <= 0) {
        return -1;  // Memory leak - free() not called
    }
    
    // Process data
    free(data);
    return 0;
}
```

**Detection Tools:**

**Valgrind (Linux/macOS):** [Unverified] Valgrind is a popular memory debugging tool that can detect memory leaks, buffer overflows, and other memory-related errors.

```bash
gcc -g -o program program.c
valgrind --leak-check=full ./program
```

**AddressSanitizer:** [Unverified] Built into GCC and Clang compilers for runtime memory error detection.

```bash
gcc -fsanitize=address -g -o program program.c
./program
```

**Manual Debugging Techniques:**

**Reference Counting:**

```c
static int allocation_count = 0;

void* debug_malloc(size_t size) {
    void *ptr = malloc(size);
    if (ptr) {
        allocation_count++;
        printf("Allocated: %p, Count: %d\n", ptr, allocation_count);
    }
    return ptr;
}

void debug_free(void *ptr) {
    if (ptr) {
        allocation_count--;
        printf("Freed: %p, Count: %d\n", ptr, allocation_count);
        free(ptr);
    }
}
```

**Memory Usage Tracking:**

```c
#include <stdio.h>
#include <stdlib.h>

typedef struct {
    void *ptr;
    size_t size;
    const char *file;
    int line;
} allocation_info;

static allocation_info allocations[1000];
static int alloc_index = 0;

#define MALLOC(size) debug_malloc(size, __FILE__, __LINE__)
#define FREE(ptr) debug_free(ptr, __FILE__, __LINE__)

void* debug_malloc(size_t size, const char *file, int line) {
    void *ptr = malloc(size);
    if (ptr && alloc_index < 1000) {
        allocations[alloc_index].ptr = ptr;
        allocations[alloc_index].size = size;
        allocations[alloc_index].file = file;
        allocations[alloc_index].line = line;
        alloc_index++;
    }
    return ptr;
}
```

**Key Points:**

- Always match every malloc/calloc/realloc with exactly one free
- Set pointers to NULL after freeing to avoid dangling references
- Use static analysis tools and runtime checkers during development
- Consider using higher-level languages or smart pointers for automatic memory management

