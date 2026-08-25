## Performance Optimization Basics


Performance optimization in C involves understanding algorithmic complexity, memory access patterns, and compiler optimizations.

**Algorithmic Optimization**

```c
#include <stdio.h>
#include <time.h>
#include <string.h>

// O(n²) - inefficient approach
int inefficient_string_search(const char *text, const char *pattern) {
    int text_len = strlen(text);
    int pattern_len = strlen(pattern);
    int comparisons = 0;
    
    for (int i = 0; i <= text_len - pattern_len; i++) {
        comparisons++;
        if (strncmp(&text[i], pattern, pattern_len) == 0) {
            printf("Inefficient search comparisons: %d\n", comparisons);
            return i;
        }
    }
    printf("Inefficient search comparisons: %d\n", comparisons);
    return -1;
}

// Optimized approach with early termination
int optimized_string_search(const char *text, const char *pattern) {
    int text_len = strlen(text);
    int pattern_len = strlen(pattern);
    int comparisons = 0;
    
    for (int i = 0; i <= text_len - pattern_len; i++) {
        comparisons++;
        int j;
        for (j = 0; j < pattern_len; j++) {
            if (text[i + j] != pattern[j]) break;
        }
        if (j == pattern_len) {
            printf("Optimized search comparisons: %d\n", comparisons);
            return i;
        }
    }
    printf("Optimized search comparisons: %d\n", comparisons);
    return -1;
}

void demonstrate_algorithmic_optimization() {
    const char *text = "This is a long text string for searching patterns";
    const char *pattern = "patterns";
    
    printf("Searching for '%s' in text...\n", pattern);
    inefficient_string_search(text, pattern);
    optimized_string_search(text, pattern);
}
```

**Memory Access Optimization**

```c
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#define MATRIX_SIZE 1000

// Cache-unfriendly: column-major access
void matrix_multiply_slow(int a[][MATRIX_SIZE], int b[][MATRIX_SIZE], 
                         int result[][MATRIX_SIZE]) {
    for (int i = 0; i < MATRIX_SIZE; i++) {
        for (int j = 0; j < MATRIX_SIZE; j++) {
            result[i][j] = 0;
            for (int k = 0; k < MATRIX_SIZE; k++) {
                result[i][j] += a[i][k] * b[k][j];  // Poor cache locality
            }
        }
    }
}

// Cache-friendly: blocked access pattern
void matrix_multiply_fast(int a[][MATRIX_SIZE], int b[][MATRIX_SIZE], 
                         int result[][MATRIX_SIZE]) {
    const int block_size = 64;
    
    // Initialize result matrix
    for (int i = 0; i < MATRIX_SIZE; i++) {
        for (int j = 0; j < MATRIX_SIZE; j++) {
            result[i][j] = 0;
        }
    }
    
    // Blocked multiplication for better cache usage
    for (int ii = 0; ii < MATRIX_SIZE; ii += block_size) {
        for (int jj = 0; jj < MATRIX_SIZE; jj += block_size) {
            for (int kk = 0; kk < MATRIX_SIZE; kk += block_size) {
                // Process block
                for (int i = ii; i < ii + block_size && i < MATRIX_SIZE; i++) {
                    for (int j = jj; j < jj + block_size && j < MATRIX_SIZE; j++) {
                        for (int k = kk; k < kk + block_size && k < MATRIX_SIZE; k++) {
                            result[i][j] += a[i][k] * b[k][j];
                        }
                    }
                }
            }
        }
    }
}

void demonstrate_cache_optimization() {
    printf("Matrix multiplication optimization demo\n");
    printf("Note: Performance improvement depends on system cache architecture\n");
    // [Inference] Actual performance gains vary based on hardware cache sizes
}
```

**Loop Optimization Techniques**

```c
#include <stdio.h>

// Loop unrolling example
void process_array_unrolled(int *arr, int size) {
    int i;
    // Process 4 elements at a time
    for (i = 0; i < size - 3; i += 4) {
        arr[i] *= 2;
        arr[i + 1] *= 2;
        arr[i + 2] *= 2;
        arr[i + 3] *= 2;
    }
    // Handle remaining elements
    for (; i < size; i++) {
        arr[i] *= 2;
    }
}

// Strength reduction: replace expensive operations
void strength_reduction_example(int *arr, int size) {
    // Instead of: arr[i] = i * i * i;
    int cube = 0;
    int square = 0;
    for (int i = 0; i < size; i++) {
        arr[i] = cube;
        // Update for next iteration using addition instead of multiplication
        cube += 3 * square + 3 * i + 1;  // (i+1)³ = i³ + 3i² + 3i + 1
        square += 2 * i + 1;             // (i+1)² = i² + 2i + 1
    }
}
```

