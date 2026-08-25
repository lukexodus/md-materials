## malloc, calloc, realloc, free


Dynamic memory management in C provides runtime memory allocation and deallocation through a set of standard library functions that manipulate the heap memory region.

**malloc (Memory Allocation):** Allocates a block of uninitialized memory of specified size in bytes.

```c
#include <stdlib.h>

void* malloc(size_t size);
```

**Key Points:**

- Returns a void pointer to allocated memory or NULL if allocation fails
- Memory content is uninitialized and contains garbage values
- Must be paired with free() to prevent memory leaks
- Allocated memory is not automatically cleared

**Example:**

```c
int *ptr = (int*)malloc(5 * sizeof(int));
if (ptr == NULL) {
    fprintf(stderr, "Memory allocation failed\n");
    exit(1);
}

// Use the allocated memory
for (int i = 0; i < 5; i++) {
    ptr[i] = i + 1;
}

free(ptr);  // Release memory
ptr = NULL; // Avoid dangling pointer
```

**calloc (Contiguous Allocation):** Allocates memory for an array of elements and initializes all bytes to zero.

```c
void* calloc(size_t num_elements, size_t element_size);
```

**Key Points:**

- Takes two parameters: number of elements and size per element
- All allocated memory is initialized to zero
- Safer than malloc for array allocation as it prevents integer overflow
- Slightly slower than malloc due to initialization

**Example:**

```c
int *arr = (int*)calloc(10, sizeof(int));
if (arr == NULL) {
    fprintf(stderr, "Memory allocation failed\n");
    exit(1);
}

// All elements are already initialized to 0
for (int i = 0; i < 10; i++) {
    printf("%d ", arr[i]);  // Output: 0 0 0 0 0 0 0 0 0 0
}

free(arr);
```

**realloc (Reallocation):** Changes the size of previously allocated memory block, potentially moving it to a new location.

```c
void* realloc(void* ptr, size_t new_size);
```

**Key Points:**

- Can expand or shrink existing memory blocks
- May move memory to a new location if current location cannot accommodate new size
- Preserves existing data up to the minimum of old and new sizes
- Returns NULL if allocation fails, leaving original block unchanged
- Can be used with NULL pointer (behaves like malloc)

**Example:**

```c
int *arr = (int*)malloc(5 * sizeof(int));
// Initialize array
for (int i = 0; i < 5; i++) {
    arr[i] = i + 1;
}

// Expand array to 10 elements
int *temp = (int*)realloc(arr, 10 * sizeof(int));
if (temp == NULL) {
    fprintf(stderr, "Reallocation failed\n");
    free(arr);  // Original memory still valid
    exit(1);
}
arr = temp;

// Original data preserved, new elements uninitialized
for (int i = 5; i < 10; i++) {
    arr[i] = i + 1;
}

free(arr);
```

**free (Deallocation):** Releases previously allocated dynamic memory back to the system.

```c
void free(void* ptr);
```

**Key Points:**

- Must only be called on pointers returned by malloc, calloc, or realloc
- Calling free on the same pointer twice results in undefined behavior (double free)
- Calling free on NULL pointer is safe and does nothing
- Memory content remains unchanged after free, but accessing it is undefined behavior

**Example:**

```c
char *buffer = (char*)malloc(100);
if (buffer != NULL) {
    // Use buffer
    strcpy(buffer, "Hello, World!");
    printf("%s\n", buffer);
    
    free(buffer);
    buffer = NULL;  // Prevent accidental reuse
}
```

