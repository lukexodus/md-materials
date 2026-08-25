## Array Manipulation


Array manipulation involves various operations for processing, searching, sorting, and modifying array elements.

**Common Operations:**

**Finding Maximum/Minimum:**

```c
int findMax(int arr[], int size) {
    int max = arr[0];
    for(int i = 1; i < size; i++) {
        if(arr[i] > max) {
            max = arr[i];
        }
    }
    return max;
}
```

**Array Reversal:**

```c
void reverseArray(int arr[], int size) {
    for(int i = 0; i < size/2; i++) {
        int temp = arr[i];
        arr[i] = arr[size-1-i];
        arr[size-1-i] = temp;
    }
}
```

**Linear Search:**

```c
int linearSearch(int arr[], int size, int target) {
    for(int i = 0; i < size; i++) {
        if(arr[i] == target) {
            return i;  // Return index if found
        }
    }
    return -1;  // Not found
}
```

**Bubble Sort:**

```c
void bubbleSort(int arr[], int size) {
    for(int i = 0; i < size-1; i++) {
        for(int j = 0; j < size-i-1; j++) {
            if(arr[j] > arr[j+1]) {
                int temp = arr[j];
                arr[j] = arr[j+1];
                arr[j+1] = temp;
            }
        }
    }
}
```

**Array Copying:**

```c
void copyArray(int source[], int dest[], int size) {
    for(int i = 0; i < size; i++) {
        dest[i] = source[i];
    }
}

// Using memcpy (from string.h)
#include <string.h>
memcpy(dest, source, size * sizeof(int));
```

**Key Points:**

- Most array operations require passing the array size as a separate parameter
- Array elements can be modified through index-based access
- Standard library functions like `memcpy`, `memset`, and `qsort` provide efficient array operations
- Multi-dimensional arrays require nested loops for complete traversal

