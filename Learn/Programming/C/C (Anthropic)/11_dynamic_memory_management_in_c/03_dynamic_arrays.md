## Dynamic Arrays


Dynamic arrays provide flexible, resizable array structures that can grow or shrink during program execution.

**Basic Dynamic Array Implementation:**

```c
typedef struct {
    int *data;
    size_t size;        // Current number of elements
    size_t capacity;    // Maximum elements before reallocation
} DynamicArray;

DynamicArray* create_array(size_t initial_capacity) {
    DynamicArray *arr = (DynamicArray*)malloc(sizeof(DynamicArray));
    if (!arr) return NULL;
    
    arr->data = (int*)malloc(initial_capacity * sizeof(int));
    if (!arr->data) {
        free(arr);
        return NULL;
    }
    
    arr->size = 0;
    arr->capacity = initial_capacity;
    return arr;
}

void destroy_array(DynamicArray *arr) {
    if (arr) {
        free(arr->data);
        free(arr);
    }
}
```

**Array Expansion:**

```c
int resize_array(DynamicArray *arr, size_t new_capacity) {
    if (!arr || new_capacity < arr->size) return 0;
    
    int *temp = (int*)realloc(arr->data, new_capacity * sizeof(int));
    if (!temp) return 0;  // Reallocation failed
    
    arr->data = temp;
    arr->capacity = new_capacity;
    return 1;  // Success
}

int push_back(DynamicArray *arr, int value) {
    if (!arr) return 0;
    
    // Expand if necessary (double capacity)
    if (arr->size >= arr->capacity) {
        size_t new_capacity = arr->capacity * 2;
        if (!resize_array(arr, new_capacity)) {
            return 0;  // Expansion failed
        }
    }
    
    arr->data[arr->size] = value;
    arr->size++;
    return 1;
}
```

**Array Access and Modification:**

```c
int get_element(DynamicArray *arr, size_t index) {
    if (!arr || index >= arr->size) {
        fprintf(stderr, "Index out of bounds\n");
        return -1;  // Error value
    }
    return arr->data[index];
}

int set_element(DynamicArray *arr, size_t index, int value) {
    if (!arr || index >= arr->size) return 0;
    arr->data[index] = value;
    return 1;
}

void print_array(DynamicArray *arr) {
    if (!arr) return;
    printf("Array (size: %zu, capacity: %zu): ", arr->size, arr->capacity);
    for (size_t i = 0; i < arr->size; i++) {
        printf("%d ", arr->data[i]);
    }
    printf("\n");
}
```

**Usage Example:**

```c
int main() {
    DynamicArray *arr = create_array(2);
    if (!arr) {
        fprintf(stderr, "Failed to create array\n");
        return 1;
    }
    
    // Add elements
    for (int i = 1; i <= 10; i++) {
        push_back(arr, i * i);
        print_array(arr);
    }
    
    // Access elements
    printf("Element at index 5: %d\n", get_element(arr, 5));
    
    destroy_array(arr);
    return 0;
}
```

**Shrinking Arrays:**

```c
int pop_back(DynamicArray *arr) {
    if (!arr || arr->size == 0) return 0;
    
    arr->size--;
    
    // Shrink if array is less than 25% full
    if (arr->size > 0 && arr->size <= arr->capacity / 4) {
        resize_array(arr, arr->capacity / 2);
    }
    
    return 1;
}
```

**Key Points:**

- Dynamic arrays typically double capacity when full to amortize reallocation costs
- Shrinking strategies prevent memory waste in sparse arrays
- Always check return values of memory allocation functions
- Consider cache locality when designing growth strategies

