## Multidimensional Array Parameter Handling

### Overview

Multidimensional array parameter handling refers to how programming languages pass arrays with more than one dimension into subprograms — what information the callee receives, how memory layout affects access, and what restrictions the language imposes on declaring such parameters. This is a persistently tricky area of language design because a multidimensional array is not just "more data" — it requires the callee to know the size or stride of at least one dimension to correctly compute element addresses, unless the language passes richer metadata.

### The Core Problem

A one-dimensional array parameter only needs a base address; the compiler can compute the address of element `i` as $base + i \times elementSize$. A two-dimensional array requires knowing how rows are laid out in memory. For row-major storage, the address of element $(i, j)$ in an array with $C$ columns is:

$$address(i, j) = base + (i \times C + j) \times elementSize$$

If the callee doesn't know $C$ (the number of columns, or more generally the extents of all dimensions except the first), it cannot correctly index into the array — even though it has a valid pointer to the data. This is the crux of why multidimensional parameter passing needs special handling: the "shape" of the array is as important as its starting address.

### C and C++: Row-Major Arrays with Explicit Bounds

In C, a true multidimensional array (as opposed to an array of pointers) is stored contiguously in row-major order. When passed as a parameter, an array decays to a pointer to its first element, but the compiler still needs the sizes of all dimensions except the leftmost to generate correct indexing code. C therefore requires the programmer to specify all dimensions except the first in the parameter declaration:

```c
void processMatrix(int mat[][10], int rows) {
    for (int i = 0; i < rows; i++) {
        for (int j = 0; j < 10; j++) {
            mat[i][j] = mat[i][j] * 2;
        }
    }
}
```

Here, `10` (the column count) must be a compile-time constant known to the function, because the compiler needs it to compute `mat[i][j]` as `*(mat + i*10 + j)`. The leftmost dimension (`rows`) is not needed by the compiler and is conventionally passed as a separate parameter, since C arrays carry no built-in size information.

C99 introduced **variable-length array (VLA) parameters**, letting the column size itself be a runtime parameter:

```c
void processMatrix(int rows, int cols, int mat[rows][cols]) {
    for (int i = 0; i < rows; i++)
        for (int j = 0; j < cols; j++)
            mat[i][j] *= 2;
}
```

This is legal because `rows` and `cols` are declared as parameters earlier in the parameter list, so the compiler can generate address arithmetic using their runtime values. [Inference] This VLA-parameter feature is less commonly used in production code than the fixed-size form, partly because VLAs raise concerns about stack allocation and were made optional in C11.

C++ inherits C's array-parameter rules for raw arrays, but idiomatic C++ typically avoids raw multidimensional arrays as parameters in favor of `std::vector<std::vector<T>>`, `std::array`, or a flattened 1D buffer with explicit dimension parameters, since these carry their own size metadata and avoid the fixed-dimension restriction.

### Row-Major vs. Column-Major Layout

The address formula above assumes row-major layout, used by C, C++, Java, Pascal, and most C-family languages. Fortran uses **column-major** layout, where the leftmost index varies fastest in memory:

$$address(i, j) = base + (j \times R + i) \times elementSize$$

where $R$ is the number of rows. This is not merely an internal detail — it affects how subprograms should traverse arrays for cache efficiency (looping over the fastest-varying index in the innermost loop) and matters when interfacing between languages (e.g., calling Fortran routines like BLAS/LAPACK from C or Python, which requires either transposing data or passing a layout flag).

Diagram illustrating the memory layout difference:

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 780 340">
  <text x="390" y="28" text-anchor="middle" font-size="18" font-weight="bold" fill="#1a1a1a">Row-Major vs. Column-Major Layout (svg_diagram)</text>

  <text x="195" y="58" text-anchor="middle" font-size="14" font-weight="bold" fill="#2c3e50">Row-Major (C, C++, Java)</text>
  <g font-size="12">
    <rect x="30" y="80" width="330" height="60" fill="none" stroke="#333" stroke-width="1.5" />
    <line x1="60" y1="80" x2="60" y2="140" stroke="#333" />
    <line x1="90" y1="80" x2="90" y2="140" stroke="#333" />
    <line x1="120" y1="80" x2="120" y2="140" stroke="#333" />
    <line x1="150" y1="80" x2="150" y2="140" stroke="#333" />
    <line x1="180" y1="80" x2="180" y2="140" stroke="#333" />
    <line x1="210" y1="80" x2="210" y2="140" stroke="#333" />
    <line x1="240" y1="80" x2="240" y2="140" stroke="#333" />
    <line x1="270" y1="80" x2="270" y2="140" stroke="#333" />
    <line x1="300" y1="80" x2="300" y2="140" stroke="#333" />
    <line x1="330" y1="80" x2="330" y2="140" stroke="#333" />

    <text x="45" y="115" text-anchor="middle">00</text>
    <text x="75" y="115" text-anchor="middle">01</text>
    <text x="105" y="115" text-anchor="middle">02</text>
    <text x="135" y="115" text-anchor="middle">10</text>
    <text x="165" y="115" text-anchor="middle">11</text>
    <text x="195" y="115" text-anchor="middle">12</text>
    <text x="225" y="115" text-anchor="middle">20</text>
    <text x="255" y="115" text-anchor="middle">21</text>
    <text x="285" y="115" text-anchor="middle">22</text>
    <text x="345" y="115" text-anchor="middle">...</text>

    <rect x="30" y="80" width="90" height="60" fill="#3498db" fill-opacity="0.15" stroke="none" />
    <rect x="120" y="80" width="90" height="60" fill="#e67e22" fill-opacity="0.15" stroke="none" />
    <rect x="210" y="80" width="90" height="60" fill="#2ecc71" fill-opacity="0.15" stroke="none" />

    <text x="195" y="165" text-anchor="middle" fill="#555">Row 0 stored fully, then Row 1, then Row 2</text>
    <text x="195" y="185" text-anchor="middle" fill="#555">addr(i,j) = base + (i*C + j)*size</text>
  </g>

  <text x="585" y="58" text-anchor="middle" font-size="14" font-weight="bold" fill="#2c3e50">Column-Major (Fortran)</text>
  <g font-size="12">
    <rect x="420" y="80" width="330" height="60" fill="none" stroke="#333" stroke-width="1.5" />
    <line x1="450" y1="80" x2="450" y2="140" stroke="#333" />
    <line x1="480" y1="80" x2="480" y2="140" stroke="#333" />
    <line x1="510" y1="80" x2="510" y2="140" stroke="#333" />
    <line x1="540" y1="80" x2="540" y2="140" stroke="#333" />
    <line x1="570" y1="80" x2="570" y2="140" stroke="#333" />
    <line x1="600" y1="80" x2="600" y2="140" stroke="#333" />
    <line x1="630" y1="80" x2="630" y2="140" stroke="#333" />
    <line x1="660" y1="80" x2="660" y2="140" stroke="#333" />
    <line x1="690" y1="80" x2="690" y2="140" stroke="#333" />
    <line x1="720" y1="80" x2="720" y2="140" stroke="#333" />

    <text x="435" y="115" text-anchor="middle">00</text>
    <text x="465" y="115" text-anchor="middle">10</text>
    <text x="495" y="115" text-anchor="middle">20</text>
    <text x="525" y="115" text-anchor="middle">01</text>
    <text x="555" y="115" text-anchor="middle">11</text>
    <text x="585" y="115" text-anchor="middle">21</text>
    <text x="615" y="115" text-anchor="middle">02</text>
    <text x="645" y="115" text-anchor="middle">12</text>
    <text x="675" y="115" text-anchor="middle">22</text>
    <text x="735" y="115" text-anchor="middle">...</text>

    <rect x="420" y="80" width="90" height="60" fill="#3498db" fill-opacity="0.15" stroke="none" />
    <rect x="510" y="80" width="90" height="60" fill="#e67e22" fill-opacity="0.15" stroke="none" />
    <rect x="600" y="80" width="90" height="60" fill="#2ecc71" fill-opacity="0.15" stroke="none" />

    <text x="585" y="165" text-anchor="middle" fill="#555">Col 0 stored fully, then Col 1, then Col 2</text>
    <text x="585" y="185" text-anchor="middle" fill="#555">addr(i,j) = base + (j*R + i)*size</text>
  </g>

  <text x="390" y="230" text-anchor="middle" font-size="13" fill="#555">Labels show (row,col). Colored blocks show which logical row/column is contiguous.</text>
  <text x="390" y="255" text-anchor="middle" font-size="13" font-weight="bold" fill="#c0392b">A subprogram receiving only a base pointer must know the layout convention</text>
  <text x="390" y="275" text-anchor="middle" font-size="13" font-weight="bold" fill="#c0392b">and the relevant extent (C or R) to index correctly.</text>
</svg>

### Fortran: Dimension Passed Alongside the Array

Fortran subprograms conventionally receive array dimensions as separate arguments alongside the array itself, since traditional Fortran arrays (pre-90) are passed by reference without built-in bound metadata:

```fortran
SUBROUTINE PROCESS(MAT, ROWS, COLS)
  INTEGER ROWS, COLS
  REAL MAT(ROWS, COLS)
  INTEGER I, J
  DO I = 1, ROWS
    DO J = 1, COLS
      MAT(I, J) = MAT(I, J) * 2.0
    END DO
  END DO
END SUBROUTINE
```

Because Fortran uses column-major layout and the compiler is told `ROWS` explicitly, it can compute offsets correctly regardless of the matrix's actual runtime size, as long as `ROWS` is passed accurately. This convention — pass the array, then pass its bounds as ordinary integer parameters — became the de facto standard later formalized as **assumed-size** and **assumed-shape** arrays.

Modern Fortran (90 and later) improves on this with **assumed-shape arrays**, where the compiler automatically passes bound information as hidden metadata (a "dope vector" or array descriptor), removing the need for the programmer to pass dimensions manually:

```fortran
SUBROUTINE PROCESS(MAT)
  REAL, INTENT(INOUT) :: MAT(:,:)
  INTEGER :: I, J
  DO I = 1, SIZE(MAT, 1)
    DO J = 1, SIZE(MAT, 2)
      MAT(I, J) = MAT(I, J) * 2.0
    END DO
  END DO
END SUBROUTINE
```

The colon (`:`) in each dimension tells the compiler to accept any-sized array and to use the caller-supplied descriptor to determine actual extents via `SIZE()`. This is closer to how languages with dynamic arrays and dope vectors (below) handle the problem generally.

### Dope Vectors: The General Solution

Many language implementations solve the multidimensional-array problem generally using a **dope vector** (also called an array descriptor), a small runtime structure attached to the array that records:

- A pointer to the actual data
- The number of dimensions
- The extent (size) of each dimension
- The stride (memory distance between successive elements along each dimension)
- Sometimes the lower bound of each dimension, for languages that allow non-zero-based indexing (e.g., Ada, Pascal)

When such an array is passed to a subprogram, the dope vector itself (not just a raw pointer) is passed, giving the callee everything it needs to compute addresses for elements at any position without the caller manually supplying dimension arguments.

Diagram of a dope vector's structure:

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 700 260">
  <text x="350" y="26" text-anchor="middle" font-size="18" font-weight="bold" fill="#1a1a1a">Dope Vector Structure (svg_diagram)</text>

  <rect x="40" y="55" width="260" height="170" rx="6" fill="#f4f6f8" stroke="#333" stroke-width="1.5" />
  <text x="170" y="78" text-anchor="middle" font-size="13" font-weight="bold" fill="#2c3e50">Dope Vector (Descriptor)</text>

  <rect x="55" y="90" width="230" height="26" fill="#3498db" fill-opacity="0.15" stroke="#333" />
  <text x="65" y="107" font-size="12">data_ptr → base address</text>

  <rect x="55" y="118" width="230" height="26" fill="#e67e22" fill-opacity="0.15" stroke="#333" />
  <text x="65" y="135" font-size="12">num_dimensions = 2</text>

  <rect x="55" y="146" width="230" height="26" fill="#2ecc71" fill-opacity="0.15" stroke="#333" />
  <text x="65" y="163" font-size="12">extents = [rows, cols]</text>

  <rect x="55" y="174" width="230" height="26" fill="#9b59b6" fill-opacity="0.15" stroke="#333" />
  <text x="65" y="191" font-size="12">strides = [cols, 1]</text>

  <rect x="55" y="202" width="230" height="16" fill="#f1c40f" fill-opacity="0.15" stroke="#333" />
  <text x="65" y="214" font-size="11">lower_bounds (opt.)</text>

  <line x1="120" y1="103" x2="420" y2="103" stroke="#3498db" stroke-width="1.5" marker-end="url(#arrow1)" />
  <rect x="420" y="85" width="240" height="40" fill="#ecf0f1" stroke="#333" stroke-width="1.5" />
  <text x="540" y="110" text-anchor="middle" font-size="12">Actual contiguous array data</text>

  <text x="350" y="245" text-anchor="middle" font-size="13" fill="#555">Passing the descriptor (not just data_ptr) lets a callee compute any element's address</text>
</svg>

Languages that use dope vectors for array parameters — including Ada, Fortran 90+, and (conceptually) many managed-language runtimes — allow subprograms to accept arrays of unspecified dimension sizes and still index correctly, because the extent and stride information travels with the array reference itself.

### Java, C#, and Managed Languages: True Array Objects

In Java and C#, arrays are objects (reference types) with an intrinsic `length` property (Java) or `Length`/`GetLength()` (C#) that the runtime maintains automatically. This removes the "programmer must specify dimensions" burden entirely, because the array object itself carries its own size metadata analogous to a dope vector, managed by the runtime rather than the programmer.

Java, notably, does not have true multidimensional arrays in the C/Fortran sense — `int[][] matrix` is an array of array references (a "jagged array" structure), where each row is an independently allocated 1D array object that may even have a different length than other rows:

```java
void processMatrix(int[][] mat) {
    for (int i = 0; i < mat.length; i++) {
        for (int j = 0; j < mat[i].length; j++) {
            mat[i][j] *= 2;
        }
    }
}
```

Because each `mat[i]` is its own object with its own `length`, the method needs no externally supplied dimension parameters at all — every row can be queried for its own size at runtime. This is fundamentally different from C's fixed-shape row-major array and from Fortran's rectangular array with descriptor: Java's structure is inherently jagged-capable, and true rectangular multidimensional access is a special case rather than the norm.

C# supports both:
- **Jagged arrays** (`int[][]`), structured like Java's, an array of array references.
- **Rectangular arrays** (`int[,]`), a single contiguous block with `GetLength(0)` and `GetLength(1)` available on the array object.

```csharp
void ProcessMatrix(int[,] mat) {
    int rows = mat.GetLength(0);
    int cols = mat.GetLength(1);
    for (int i = 0; i < rows; i++)
        for (int j = 0; j < cols; j++)
            mat[i, j] *= 2;
}
```

Because the rectangular array object carries both dimension extents internally, `ProcessMatrix` needs no separate size parameters, unlike the C equivalent.

### Python: No Native Multidimensional Arrays

Python has no built-in multidimensional array type; nested lists (`list[list[...]]`) are jagged by default, similar in spirit to Java's array-of-arrays, and each sub-list's length is queried with `len()`:

```python
def process_matrix(mat):
    for i in range(len(mat)):
        for j in range(len(mat[i])):
            mat[i][j] *= 2
```

For genuinely rectangular, high-performance multidimensional arrays, Python code typically uses **NumPy**, whose `ndarray` carries a `.shape` attribute (tuple of extents) and `.strides` (byte distances per dimension) — effectively a dope vector implemented at the library level rather than the language level:

```python
def process_matrix(mat):
    rows, cols = mat.shape  # dope-vector-style metadata
    for i in range(rows):
        for j in range(cols):
            mat[i, j] *= 2
```

[Inference] Because NumPy is a library rather than a language feature, this illustrates that dope-vector-style array descriptors can be implemented entirely outside the core language, provided the language supports objects with attributes and operator overloading (`__getitem__` for the `mat[i, j]` syntax).

### Ada: Constrained and Unconstrained Array Parameters

Ada allows subprograms to accept arrays either with statically fixed bounds or, more flexibly, as **unconstrained array types**, where the actual bounds are supplied by the passed argument and made available via attributes like `'Range`, `'First`, and `'Last`:

```ada
procedure Process (Mat : in out Matrix) is
begin
   for I in Mat'Range(1) loop
      for J in Mat'Range(2) loop
         Mat(I, J) := Mat(I, J) * 2;
      end loop;
   end loop;
end Process;
```

Here `Matrix` is typically declared as an unconstrained type (`array (Integer range <>, Integer range <>) of Integer`), and the subprogram queries the actual bounds of whatever array was passed using `'Range` attributes — conceptually equivalent to consulting a dope vector, but exposed through language-level attributes rather than manual size parameters.

### Comparison Across Approaches

| Language | Multidimensional storage | How callee learns dimensions |
|---|---|---|
| C (fixed) | Row-major, contiguous | All but leftmost dimension hardcoded in parameter declaration |
| C (VLA, C99) | Row-major, contiguous | Prior parameters supply dimensions used in later parameter's type |
| Fortran (traditional) | Column-major, contiguous | Dimensions passed as separate explicit arguments |
| Fortran 90+ (assumed-shape) | Column-major, contiguous | Compiler-generated descriptor (dope vector) |
| Java | Array of array-objects (jagged) | `.length` queried per array object at runtime |
| C# (rectangular) | Row-major, contiguous | `.GetLength(n)` on the array object |
| Python (nested lists) | Jagged, list of lists | `len()` queried per sub-list |
| Python (NumPy) | Row- or column-major, configurable | `.shape` / `.strides` attributes (library-level dope vector) |
| Ada (unconstrained) | Contiguous, bounds-checked | `'Range`, `'First`, `'Last` attributes from the actual argument |

### Common Pitfalls

- **Row/column confusion across language boundaries**: passing a row-major array (e.g., from C or NumPy's default layout) into a Fortran or column-major-expecting routine without transposing or specifying a layout flag silently produces incorrect results rather than a crash, since the memory is valid but misinterpreted. [Unverified across all specific library implementations, but this is a well-documented class of bug in native/Fortran interop code.]
- **Jagged vs. rectangular mismatch**: code written assuming all rows of a Java or Python nested-list "matrix" have equal length will produce an `IndexOutOfBoundsException` or silent logic errors if a caller passes a genuinely jagged structure, since the language does not enforce rectangularity.
- **Fixed-dimension C parameters restricting reusability**: a function like `void f(int m[][10])` cannot be reused for a matrix with a different column count without either rewriting the signature or falling back to a flattened 1D array with explicit row/column parameters.
- **Stale dimension parameters**: in languages requiring manually passed dimension arguments (C, traditional Fortran), passing dimensions that don't match the actual array's allocated size is undefined or erroneous behavior that the language cannot detect at compile time or, in many cases, at runtime.

### Key Points

- The fundamental challenge is that address computation for element $(i, j)$ requires knowing at least one extent (row-major: column count; column-major: row count) beyond just a base address.
- Languages resolve this either by requiring the programmer to supply dimension information manually (C, traditional Fortran) or by attaching dimension metadata to the array itself at runtime via a dope vector or equivalent object property (Fortran 90+, Java, C#, Ada, NumPy).
- Row-major vs. column-major layout is a language-level (or library-level) convention that must match between caller and callee, especially across language boundaries via foreign-function interfaces.
- "True" contiguous rectangular arrays and "jagged" arrays-of-arrays are handled with different parameter mechanisms and have different pitfalls; many languages (Java, Python, C# jagged arrays) default to the jagged model for multidimensional structures.

### Related Topics

- Dope vectors and array descriptors in runtime systems
- Row-major vs. column-major layout and cache performance implications
- Array slicing and subarray parameter passing
- Foreign function interfaces and array layout interoperability (e.g., calling Fortran BLAS/LAPACK from C or Python)
- Bounds checking strategies for array parameters
- Pass-by-reference vs. pass-by-value semantics for aggregate types
- Generic/templated subprograms over array types (C++ templates, Ada generics)
- Flattened 1D array representations of multidimensional data