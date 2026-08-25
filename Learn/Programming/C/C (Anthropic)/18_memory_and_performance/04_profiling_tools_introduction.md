## Profiling Tools Introduction


Profiling helps identify performance bottlenecks and memory issues in C programs.

**Built-in Profiling with gprof**

```c
// compile_profile.sh example
/*
#!/bin/bash
gcc -pg -O2 -o program program.c
./program
gprof program gmon.out > analysis.txt
*/

#include <stdio.h>
#include <stdlib.h>

void expensive_function() {
    // Simulate expensive computation
    volatile int sum = 0;
    for (int i = 0; i < 1000000; i++) {
        sum += i * i;
    }
}

void another_function() {
    for (int i = 0; i < 100; i++) {
        expensive_function();
    }
}

int main() {
    printf("Starting profiling example...\n");
    another_function();
    printf("Profiling complete. Run 'gprof program gmon.out' to analyze.\n");
    return 0;
}
```

**Memory Profiling Concepts**

```c
#include <stdio.h>
#include <stdlib.h>

// Memory leak detection example
void demonstrate_memory_issues() {
    // Memory leak - allocated but never freed
    int *leaked_memory = malloc(1000 * sizeof(int));
    // Missing: free(leaked_memory);
    
    // Double free error (commented to prevent crash)
    int *ptr = malloc(100 * sizeof(int));
    free(ptr);
    // free(ptr);  // This would cause double-free error
    
    // Use after free (commented to prevent undefined behavior)
    // ptr[0] = 42;  // This would access freed memory
    
    // Buffer overflow
    char buffer[10];
    // strcpy(buffer, "This string is too long");  // Buffer overflow
    
    printf("Memory issues demonstration (see comments for problematic code)\n");
    printf("Use tools like valgrind to detect these issues:\n");
    printf("  valgrind --tool=memcheck --leak-check=full ./program\n");
}

// Custom memory tracking for debugging
typedef struct MemBlock {
    void *ptr;
    size_t size;
    const char *file;
    int line;
    struct MemBlock *next;
} MemBlock;

static MemBlock *allocated_blocks = NULL;

void* debug_malloc(size_t size, const char *file, int line) {
    void *ptr = malloc(size);
    if (ptr) {
        MemBlock *block = malloc(sizeof(MemBlock));
        if (block) {
            block->ptr = ptr;
            block->size = size;
            block->file = file;
            block->line = line;
            block->next = allocated_blocks;
            allocated_blocks = block;
        }
    }
    return ptr;
}

void debug_free(void *ptr) {
    MemBlock **current = &allocated_blocks;
    while (*current) {
        if ((*current)->ptr == ptr) {
            MemBlock *to_remove = *current;
            *current = (*current)->next;
            free(to_remove);
            free(ptr);
            return;
        }
        current = &(*current)->next;
    }
    printf("Warning: Attempting to free untracked pointer\n");
}

void print_memory_leaks() {
    MemBlock *current = allocated_blocks;
    if (!current) {
        printf("No memory leaks detected\n");
        return;
    }
    
    printf("Memory leaks detected:\n");
    while (current) {
        printf("  %zu bytes allocated at %s:%d\n", 
               current->size, current->file, current->line);
        current = current->next;
    }
}

#define DEBUG_MALLOC(size) debug_malloc(size, __FILE__, __LINE__)
#define DEBUG_FREE(ptr) debug_free(ptr)

int main() {
    demonstrate_memory_issues();
    
    // Example using debug memory tracking
    void *ptr1 = DEBUG_MALLOC(100);
    void *ptr2 = DEBUG_MALLOC(200);
    
    DEBUG_FREE(ptr1);
    // Intentionally not freeing ptr2 to demonstrate leak detection
    
    print_memory_leaks();
    
    return 0;
}
```

