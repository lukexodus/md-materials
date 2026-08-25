## Multi-Dimensional Arrays


Multi-dimensional arrays are arrays of arrays, creating a matrix-like structure with multiple indices for element access.

**Two-Dimensional Arrays:** Most common form, representing rows and columns like a matrix or table.

**Declaration Syntax:**

```c
data_type array_name[rows][columns];
```

**Memory Layout:** Elements are stored in row-major order, meaning all elements of the first row are stored first, followed by all elements of the second row, and so on.

**Three-Dimensional and Higher:**

```c
int cube[3][4][5];        // 3D array
int hypercube[2][3][4][5]; // 4D array
```

**Key Points:**

- Memory is allocated contiguously for all dimensions
- Row-major storage order affects performance in nested loops
- Only the first dimension size can be omitted in certain contexts
- Multi-dimensional arrays can be viewed as single-dimensional arrays with calculated indices

**Example:**

```c
int matrix[3][4];         // 3 rows, 4 columns

// Accessing elements
matrix[0][0] = 1;         // First row, first column
matrix[2][3] = 100;       // Third row, fourth column

// Nested loop traversal
for(int i = 0; i < 3; i++) {
    for(int j = 0; j < 4; j++) {
        matrix[i][j] = i * 4 + j + 1;
        printf("%3d ", matrix[i][j]);
    }
    printf("\n");
}

// Memory address calculation
// matrix[i][j] is at: base_address + (i * columns + j) * sizeof(data_type)
```

**Jagged Arrays:** [Inference] C doesn't directly support jagged arrays (arrays with varying row lengths), but they can be simulated using arrays of pointers.

