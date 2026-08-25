## Pandas optimization


### Memory Layout and Data Type Efficiency

Standard Pandas behavior defaults to `int64` and `float64` regardless of actual data precision, and uses object pointers for strings, resulting in fragmented memory and cache misses.

- **Downcasting:** Enforce strict schema definitions. Downcast numeric types to the lowest viable precision (e.g., `float32`, `int8`) to reduce memory footprint by 50-87%. This directly improves CPU cache locality.
    
- **Categorical Dtypes:** For string columns with low cardinality (ratio of unique values to total rows < 0.5), convert `object` types to `category`. This replaces pointer arrays with a dense integer array mapped to a small lookup table, reducing memory usage and accelerating operations like `groupby` and `sort_values` from $O(N)$ string comparisons to $O(N)$ integer comparisons.
    
- **PyArrow Backend:** In Pandas 2.0+, favor the `pyarrow` backend over standard NumPy arrays for nullable integers and string operations. PyArrow eliminates the Python object overhead for strings and provides better support for missing values without coercion to float.
    

### Vectorization and Broadcasting

Explicit iteration in Python (loops, list comprehensions) incurs significant overhead due to type checking and the Global Interpreter Lock (GIL).

- **Eliminate Loops:** Replace `iterrows()` and `itertuples()` with vectorized NumPy/Pandas intrinsics. Vectorized operations push the loop execution to the C level, allowing for SIMD (Single Instruction, Multiple Data) optimizations.
    
- **Broadcasting:** Utilize NumPy broadcasting rules to align array dimensions implicitly during arithmetic operations. This avoids the creation of redundant intermediate copies of data.
    
- **Vectorized String Operations:** Avoid applying Python string methods via `.apply()`. Use the `.str` accessor methods which are optimized for array-level execution, though they often still involve loop-like overhead compared to numeric vectorization; for heavy string processing, consider offloading to compiled extensions or `pyarrow`.
    

### Method Chaining and Query Optimization

- **`eval()` and `query()`:** For complex boolean masking or arithmetic expressions involving large DataFrames, use `pd.eval()` and `df.query()`. These methods compile the expression into bytecode using `numexpr`, enabling efficient evaluation that avoids allocating intermediate arrays for every sub-expression (e.g., `df[mask1 & mask2]` creates temporary arrays; `df.query('col1 > 5 & col2 < 10')` does not).
    
- **Copy vs. View:** Explicitly handle `SettingWithCopyWarning`. Avoid chained indexing (e.g., `df[mask]['col'] = val`) as it is ambiguous whether a view or a copy is returned. Use `.loc[:, :]` to guarantee operations on the original DataFrame or explicitly `.copy()` when a standalone object is required.
    

### I/O Performance and Serialization

CSV is an inefficient, row-oriented, non-binary format that requires costly parsing and type inference.

- **Binary Formats:** Transition storage to columnar binary formats like **Parquet** or **Feather** (Apache Arrow). These support predicate pushdown (loading only necessary columns/rows), snappy compression, and preserve schema metadata, eliminating type inference overhead upon reload.
    
- **Chunking:** For datasets exceeding memory limits, avoid loading the entire DataFrame. Use the `chunksize` parameter in `read_csv` or `read_parquet` to process data in streams. Alternatively, leverage **Dask** or **Polars** for out-of-core lazy evaluation while maintaining a Pandas-like API.
    

### Custom Functions and compilation

- **Numba Integration:** When raw Python logic is unavoidable (e.g., complex window functions not supported by native Pandas), decorate functions with `@numba.jit`. This compiles Python bytecode to machine code (LLVM), allowing custom loops to run at C-speeds directly on NumPy arrays extracted from the DataFrame.
    
- **Cythonization:** For critical hotspots, write Cython extensions to interact directly with the C-API of the underlying NumPy arrays, bypassing the Python runtime entirely for the heavy lifting.

---

