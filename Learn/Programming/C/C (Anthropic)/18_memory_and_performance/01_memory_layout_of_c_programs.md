## Memory Layout of C Programs


C programs follow a standardized memory layout that determines how different types of data are organized in memory during program execution.

**Memory Segments Overview**

```c
#include <stdio.h>
#include <stdlib.h>

// Text/Code segment - read-only executable code
void function_example() {
    printf("This function code is in text segment\n");
}

// Data segment - initialized global/static variables
int global_initialized = 42;
static int static_initialized = 100;

// BSS segment - uninitialized global/static variables
int global_uninitialized;
static int static_uninitialized;

int main() {
    // Stack segment - local variables, parameters, return addresses
    int local_variable = 10;
    char local_array[100];
    
    // Heap segment - dynamically allocated memory
    int *heap_memory = malloc(sizeof(int) * 10);
    
    printf("Memory Layout Analysis:\n");
    printf("Function address (text): %p\n", (void*)function_example);
    printf("Global initialized: %p\n", (void*)&global_initialized);
    printf("Global uninitialized: %p\n", (void*)&global_uninitialized);
    printf("Local variable (stack): %p\n", (void*)&local_variable);
    printf("Heap allocation: %p\n", (void*)heap_memory);
    
    free(heap_memory);
    return 0;
}
```

**Memory Segment Characteristics**

|Segment|Contents|Characteristics|Growth Direction|
|---|---|---|---|
|Text/Code|Program instructions|Read-only, shared|Fixed size|
|Data|Initialized globals/statics|Read-write, fixed size|N/A|
|BSS|Uninitialized globals/statics|Zero-initialized|N/A|
|Heap|Dynamic allocations|Read-write, variable size|Upward|
|Stack|Local variables, function calls|Read-write, LIFO|Downward|

**Memory Address Investigation**

```c
#include <stdio.h>
#include <stdlib.h>

int global_var = 123;
static int static_var = 456;

void analyze_stack_growth(int depth) {
    int stack_var = depth;
    printf("Depth %d - Stack variable at: %p\n", depth, (void*)&stack_var);
    
    if (depth > 0) {
        analyze_stack_growth(depth - 1);
    }
}

void analyze_memory_layout() {
    int local_var = 789;
    int *heap_ptr = malloc(sizeof(int));
    *heap_ptr = 999;
    
    printf("\nMemory Layout Analysis:\n");
    printf("Text segment (function): %p\n", (void*)analyze_memory_layout);
    printf("Data segment (global): %p\n", (void*)&global_var);
    printf("BSS segment (static): %p\n", (void*)&static_var);
    printf("Stack segment (local): %p\n", (void*)&local_var);
    printf("Heap segment (malloc): %p\n", (void*)heap_ptr);
    
    printf("\nStack growth demonstration:\n");
    analyze_stack_growth(3);
    
    free(heap_ptr);
}

int main() {
    analyze_memory_layout();
    return 0;
}
```

