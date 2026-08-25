## Multidimensional Arrays and Vectors


Two-dimensional arrays and vectors in C++ are useful for representing data structures like matrices, grids, tables, and other two-dimensional structures. Here's how they are defined and used:

### Two-Dimensional Arrays:

```cpp
const int ROWS = 3;
const int COLS = 4;
int matrix[ROWS][COLS]; // Declaration of a 3x4 integer array

// Initialization
matrix[0][0] = 1;
matrix[0][1] = 2;
// ...

// Accessing elements
int element = matrix[1][2];
```

### Multidimensional Arrays:

```cpp
const int ROWS = 3;
const int COLS = 4;
const int DEPTH = 2;
int cube[DEPTH][ROWS][COLS]; // Declaration of a 3D integer array

// Initialization
cube[0][0][0] = 1;
cube[1][2][3] = 2;
// ...

// Accessing elements
int element = cube[1][2][3];
```

### Two-Dimensional Vectors:

```cpp
#include <vector>
// Type Declaration
std::vector<std::vector<int>> matrix;

// Resizing and initializing the matrix
matrix.resize(ROWS, std::vector<int>(COLS, 0));

// Initialization
matrix[0][0] = 1;
matrix[0][1] = 2;
// ...

// Accessing elements
int element = matrix[1][2];
```

- **`ROWS`**: This specifies the number of rows in the matrix.
- **`std::vector<int>(COLS, 0)`**: This creates a vector of integers with `COLS` elements, each initialized to `0`.
- **`matrix.resize(ROWS, ...)`**: This resizes the `matrix` to have `ROWS` number of rows. Each row is initialized to a vector of `COLS` integers, all set to `0`.

### Multidimensional Vectors:

```cpp
#include <vector>
std::vector<std::vector<std::vector<int>>> cube;

// Resizing and initializing the cube
cube.resize(DEPTH, std::vector<std::vector<int>>(ROWS, std::vector<int>(COLS, 0)));

// Initialization
cube[0][0][0] = 1;
cube[1][2][3] = 2;
// ...

// Accessing elements
int element = cube[1][2][3];
```

- **`cube.resize(DEPTH, ...)`**:
    - **`DEPTH`**: Specifies the number of layers (depth) in the cube.
- **`std::vector<std::vector<int>>(ROWS, std::vector<int>(COLS, 0))`**:
    - **`ROWS`**: Specifies the number of rows in each layer.
    - **`std::vector<int>(COLS, 0)`**: Creates a vector of integers with `COLS` elements, each initialized to `0`.

**Benefits of Vectors over Arrays**:

- **Dynamic Size**: Vectors can dynamically resize, unlike arrays, which have fixed sizes.
- **Automatic Memory Management**: Vectors handle memory management automatically, unlike arrays, which require manual memory management.
- **Easier Iteration and Access**: Vectors provide convenient methods for iteration and access to elements.

---

