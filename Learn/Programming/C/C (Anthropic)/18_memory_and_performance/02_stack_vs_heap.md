## Stack vs Heap


Understanding the differences between stack and heap memory is crucial for effective memory management and performance optimization.

**Stack Memory Characteristics**

```c
#include <stdio.h>
#include <string.h>

void stack_example() {
    // Stack allocation - automatic memory management
    char buffer[1024];              // Fast allocation
    int numbers[100];              // Contiguous memory
    struct { int x, y; } point;   // Compound types
    
    // Stack variables are automatically deallocated when function ends
    strcpy(buffer, "Stack allocated string");
    printf("Stack buffer: %s\n", buffer);
    
    // Stack overflow demonstration [Unverified - actual behavior may vary]
    // Uncommenting the following could cause stack overflow:
    // char huge_array[1000000];  // May exceed stack limits
}

void demonstrate_stack_lifetime() {
    int local_value = 42;
    printf("Local value: %d at address: %p\n", local_value, (void*)&local_value);
    
    // This pointer becomes invalid after function returns
    // Returning &local_value would create a dangling pointer
}

int main() {
    stack_example();
    demonstrate_stack_lifetime();
    // local_value is no longer accessible here
    
    return 0;
}
```

**Heap Memory Management**

```c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct {
    int id;
    char *name;
    float *scores;
    int score_count;
} Student;

Student* create_student(int id, const char *name, int score_count) {
    // Heap allocation for main structure
    Student *student = malloc(sizeof(Student));
    if (!student) return NULL;
    
    // Heap allocation for name string
    student->name = malloc(strlen(name) + 1);
    if (!student->name) {
        free(student);
        return NULL;
    }
    
    // Heap allocation for scores array
    student->scores = malloc(sizeof(float) * score_count);
    if (!student->scores) {
        free(student->name);
        free(student);
        return NULL;
    }
    
    // Initialize data
    student->id = id;
    strcpy(student->name, name);
    student->score_count = score_count;
    
    return student;
}

void destroy_student(Student *student) {
    if (student) {
        free(student->scores);  // Free in reverse order
        free(student->name);
        free(student);
    }
}

void heap_vs_stack_performance() {
    const int iterations = 1000000;
    clock_t start, end;
    
    // Stack allocation performance test
    start = clock();
    for (int i = 0; i < iterations; i++) {
        char buffer[100];  // Stack allocation
        buffer[0] = 'A';   // Minimal usage
    }
    end = clock();
    printf("Stack allocation time: %f seconds\n", 
           ((double)(end - start)) / CLOCKS_PER_SEC);
    
    // Heap allocation performance test
    start = clock();
    for (int i = 0; i < iterations; i++) {
        char *buffer = malloc(100);  // Heap allocation
        if (buffer) {
            buffer[0] = 'A';
            free(buffer);
        }
    }
    end = clock();
    printf("Heap allocation time: %f seconds\n", 
           ((double)(end - start)) / CLOCKS_PER_SEC);
}

int main() {
    // Demonstrate heap memory management
    Student *student = create_student(123, "John Doe", 5);
    if (student) {
        printf("Created student: ID=%d, Name=%s\n", 
               student->id, student->name);
        destroy_student(student);
    }
    
    // Performance comparison
    heap_vs_stack_performance();
    
    return 0;
}
```

**Stack vs Heap Comparison**

|Aspect|Stack|Heap|
|---|---|---|
|Speed|Very fast|Slower|
|Size limits|Limited (typically 1-8MB)|Limited by system memory|
|Management|Automatic|Manual (malloc/free)|
|Fragmentation|None|Can occur|
|Memory leaks|Impossible|Possible|
|Thread safety|Per-thread|Shared, needs synchronization|

