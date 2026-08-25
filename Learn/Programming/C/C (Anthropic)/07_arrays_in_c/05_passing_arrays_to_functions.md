## Passing Arrays to Functions


Arrays are passed to functions by reference (as pointers), meaning functions receive the memory address rather than a copy of the entire array.

**Function Parameter Syntax:**

```c
// These declarations are equivalent
void processArray(int arr[], int size);
void processArray(int *arr, int size);
void processArray(int arr[10], int size);  // Size ignored
```

**Array Decay:** When an array is passed to a function, it "decays" to a pointer to its first element. The function loses information about the original array size.

**Multi-Dimensional Arrays:**

```c
// 2D array - must specify all dimensions except the first
void process2D(int arr[][4], int rows);
void process2D(int (*arr)[4], int rows);  // Alternative syntax

// Using pointer to pointer (different memory layout)
void processPtrArray(int **arr, int rows, int cols);
```

**Key Points:**

- Functions cannot determine array size from the parameter alone
- Array modifications in functions affect the original array
- `sizeof` operator on array parameters returns pointer size, not array size
- Multi-dimensional arrays require column size specification in function parameters

**Example:**

```c
void printArray(int arr[], int size) {
    for(int i = 0; i < size; i++) {
        printf("%d ", arr[i]);
    }
    printf("\n");
}

void modifyArray(int arr[], int size) {
    for(int i = 0; i < size; i++) {
        arr[i] *= 2;  // Modifies original array
    }
}

int main() {
    int numbers[5] = {1, 2, 3, 4, 5};
    
    printArray(numbers, 5);     // Output: 1 2 3 4 5
    modifyArray(numbers, 5);
    printArray(numbers, 5);     // Output: 2 4 6 8 10
    
    return 0;
}
```

**Returning Arrays:** [Inference] Functions cannot directly return arrays, but can return pointers to arrays or use output parameters.

```c
// Return pointer to static array
int* createArray() {
    static int arr[5] = {1, 2, 3, 4, 5};
    return arr;
}

// Use output parameter
void fillArray(int result[], int size) {
    for(int i = 0; i < size; i++) {
        result[i] = i + 1;
    }
}
```

