## Dynamic Memory Allocation Basics


Dynamic memory allocation allows programs to request memory during runtime rather than compile time. This capability enables flexible data structures that can grow and shrink based on program needs. The C standard library provides several functions for dynamic memory management through the `<stdlib.h>` header.

### Memory Allocation Functions

#### malloc()

The `malloc()` function allocates a specified number of bytes and returns a pointer to the allocated memory:

```c
void *malloc(size_t size);
```

**Example** of basic malloc usage:

```c
#include <stdio.h>
#include <stdlib.h>

int main() {
    int n = 5;
    int *arr = (int*)malloc(n * sizeof(int));
    
    if (arr == NULL) {
        fprintf(stderr, "Memory allocation failed\n");
        return 1;
    }
    
    // Initialize and use the allocated memory
    for (int i = 0; i < n; i++) {
        arr[i] = i * i;
        printf("%d ", arr[i]);
    }
    printf("\n");
    
    free(arr);    // Release allocated memory
    return 0;
}
```

#### calloc()

The `calloc()` function allocates memory for an array of elements and initializes all bytes to zero:

```c
void *calloc(size_t num_elements, size_t element_size);
```

```c
int *arr = (int*)calloc(10, sizeof(int));    // 10 integers, all set to 0
if (arr != NULL) {
    // All elements are guaranteed to be 0
    for (int i = 0; i < 10; i++) {
        printf("%d ", arr[i]);    // Outputs: 0 0 0 0 0 0 0 0 0 0
    }
    free(arr);
}
```

#### realloc()

The `realloc()` function changes the size of previously allocated memory:

```c
void *realloc(void *ptr, size_t new_size);
```

**Example** of dynamic array resizing:

```c
#include <stdio.h>
#include <stdlib.h>

int main() {
    int capacity = 2;
    int size = 0;
    int *arr = (int*)malloc(capacity * sizeof(int));
    
    if (arr == NULL) return 1;
    
    // Add elements, resizing as needed
    for (int i = 0; i < 10; i++) {
        if (size >= capacity) {
            capacity *= 2;
            int *temp = (int*)realloc(arr, capacity * sizeof(int));
            if (temp == NULL) {
                free(arr);
                return 1;
            }
            arr = temp;
            printf("Resized to capacity: %d\n", capacity);
        }
        arr[size++] = i;
    }
    
    printf("Final array: ");
    for (int i = 0; i < size; i++) {
        printf("%d ", arr[i]);
    }
    printf("\n");
    
    free(arr);
    return 0;
}
```

#### free()

The `free()` function releases previously allocated memory:

```c
void free(void *ptr);
```

### Memory Management Best Practices

**Error Checking and Null Pointer Handling:**

```c
#include <stdio.h>
#include <stdlib.h>

int *create_array(int size, int initial_value) {
    if (size <= 0) {
        return NULL;    // Invalid size
    }
    
    int *arr = (int*)malloc(size * sizeof(int));
    if (arr == NULL) {
        return NULL;    // Allocation failed
    }
    
    for (int i = 0; i < size; i++) {
        arr[i] = initial_value;
    }
    
    return arr;
}

void safe_free(void **ptr) {
    if (ptr != NULL && *ptr != NULL) {
        free(*ptr);
        *ptr = NULL;    // Prevent double-free errors
    }
}

int main() {
    int *numbers = create_array(5, 42);
    if (numbers != NULL) {
        for (int i = 0; i < 5; i++) {
            printf("%d ", numbers[i]);
        }
        printf("\n");
        
        safe_free((void**)&numbers);
        // numbers is now NULL, preventing accidental reuse
    }
    
    return 0;
}
```

### Dynamic Data Structures

Dynamic memory allocation enables flexible data structures:

**Example** of a simple dynamic string implementation:

```c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct {
    char *data;
    size_t length;
    size_t capacity;
} DynamicString;

DynamicString *create_string(void) {
    DynamicString *str = (DynamicString*)malloc(sizeof(DynamicString));
    if (str == NULL) return NULL;
    
    str->capacity = 16;
    str->data = (char*)malloc(str->capacity);
    if (str->data == NULL) {
        free(str);
        return NULL;
    }
    
    str->data[0] = '\0';
    str->length = 0;
    return str;
}

int append_char(DynamicString *str, char c) {
    if (str == NULL) return 0;
    
    if (str->length + 1 >= str->capacity) {
        size_t new_capacity = str->capacity * 2;
        char *new_data = (char*)realloc(str->data, new_capacity);
        if (new_data == NULL) return 0;
        
        str->data = new_data;
        str->capacity = new_capacity;
    }
    
    str->data[str->length++] = c;
    str->data[str->length] = '\0';
    return 1;
}

void destroy_string(DynamicString *str) {
    if (str != NULL) {
        free(str->data);
        free(str);
    }
}

int main() {
    DynamicString *str = create_string();
    if (str == NULL) return 1;
    
    const char *message = "Hello, Dynamic World!";
    for (int i = 0; message[i] != '\0'; i++) {
        if (!append_char(str, message[i])) {
            destroy_string(str);
            return 1;
        }
    }
    
    printf("String: %s\n", str->data);
    printf("Length: %zu, Capacity: %zu\n", str->length, str->capacity);
    
    destroy_string(str);
    return 0;
}
```

### Common Memory Management Errors

**Memory Leaks Prevention:**

```c
// Good practice: Always pair malloc with free
int *allocate_and_process(int size) {
    int *arr = (int*)malloc(size * sizeof(int));
    if (arr == NULL) return NULL;
    
    // Process data...
    
    // Caller responsible for freeing
    return arr;
}

// Usage with proper cleanup
int *data = allocate_and_process(100);
if (data != NULL) {
    // Use data...
    free(data);
    data = NULL;
}
```

**Dangling Pointer Prevention:**

```c
#include <stdio.h>
#include <stdlib.h>

void demonstrate_dangling_pointer() {
    int *ptr = (int*)malloc(sizeof(int));
    *ptr = 42;
    
    free(ptr);
    ptr = NULL;    // Prevent dangling pointer
    
    // ptr = NULL prevents accidental dereferencing
    if (ptr != NULL) {
        printf("%d\n", *ptr);    // This branch won't execute
    }
}
```

**Key points** about dynamic memory allocation:

- Always check return values from allocation functions for NULL
- Every `malloc()`, `calloc()`, or `realloc()` must have a corresponding `free()`
- Never access memory after calling `free()` on it
- Set freed pointers to NULL to prevent dangling pointer errors
- `realloc()` may move memory, so always assign its return value
- Dynamic allocation enables runtime-sized data structures

**Conclusion**

Pointers form the cornerstone of effective C programming, providing direct memory access and enabling sophisticated data manipulation techniques. Understanding pointer syntax, arithmetic operations, array relationships, multi-level indirection, function parameter passing, and dynamic memory management creates the foundation for advanced programming concepts. [Inference] Mastery of pointer concepts enables implementation of complex data structures, efficient algorithms, and system-level programming tasks that leverage C's low-level capabilities.

---

