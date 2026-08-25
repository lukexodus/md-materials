## Table of Contents: NumPy, Pandas, and Data Handling for Machine Learning

### NumPy Foundations and Array Mechanics

- ndarray internals, memory layout, strides, and dtypes
- Array creation methods and initialization patterns
- Indexing, slicing, and views versus copies
- Fancy indexing and boolean masking
- Broadcasting rules and shape compatibility
- Vectorization principles and avoiding explicit loops
- Universal functions (ufuncs) and elementwise operations
- Aggregation functions and axis-based reductions
- Reshaping, transposing, and flattening arrays
- Stacking, splitting, and concatenating arrays
- Structured arrays and record arrays

### NumPy Numerical Computing

- Linear algebra operations with numpy.linalg
- Matrix multiplication, dot products, and einsum
- Eigenvalues, eigenvectors, and matrix decompositions
- Solving linear systems and matrix inversion
- Random number generation and the Generator API
- Sampling distributions for simulation and ML use cases
- Polynomial fitting and numerical interpolation
- Sorting, searching, and set operations
- Handling NaN and infinite values in numerical arrays

### NumPy Performance and Internals

- Memory layout: C-order versus Fortran-order
- Understanding and avoiding unnecessary copies
- Vectorization versus loops for performance
- Profiling NumPy code and identifying bottlenecks
- Numba and just-in-time compilation with NumPy
- Memory-mapped arrays for large datasets
- Data type precision tradeoffs for ML pipelines

### Pandas Core Data Structures

- Series creation, indexing, and attributes
- DataFrame creation, indexing, and attributes
- Index objects and their role in alignment
- Label-based indexing with loc
- Position-based indexing with iloc
- Boolean indexing and query-based filtering
- MultiIndex and hierarchical indexing
- Data alignment and automatic index matching

### Data Loading and Output

- Reading and writing CSV files
- Reading and writing Excel files
- Reading and writing JSON files
- Reading and writing Parquet files
- Connecting to SQL databases with pandas
- Handling large files with chunked reading
- Working with compressed and remote data sources

### Data Cleaning and Preparation

- Detecting and handling missing data
- Imputation strategies for numerical and categorical data
- Removing duplicates and inconsistent records
- Type conversion and dtype optimization
- String cleaning and text normalization
- Handling outliers and anomalous values
- Renaming, reordering, and restructuring columns
- Working with datetime data and time zones

### Data Transformation

- Applying functions with apply, map, and applymap
- Vectorized string operations
- Binning and discretization of continuous variables
- Encoding categorical variables
- Creating derived and computed columns
- Sorting and ranking data
- Pivot tables and cross-tabulations
- Reshaping with melt, stack, and unstack

### Combining and Merging Data

- Concatenating DataFrames along axes
- Merge operations and join types
- Joining on indexes versus columns
- Handling overlapping columns and suffixes
- Combining data with mismatched schemas

### Grouping and Aggregation

- GroupBy mechanics and split-apply-combine
- Aggregation functions and custom aggregations
- Transform operations within groups
- Filtering groups based on conditions
- Multi-column and multi-level grouping
- Rolling, expanding, and windowed computations

### Time Series Handling

- DatetimeIndex creation and manipulation
- Resampling and frequency conversion
- Shifting, lagging, and lead features
- Rolling window statistics for time series
- Handling time zones and daylight saving transitions
- Working with irregular and missing timestamps

### Data Handling for Machine Learning Pipelines

- Structuring features and labels from raw data
- Train-test and train-validation-test splitting
- Feature scaling and normalization workflows
- Handling categorical features for model input
- Building reproducible preprocessing pipelines
- Avoiding data leakage during preprocessing
- Converting between pandas and NumPy for model input
- Batch generation and data loaders for training

### Performance and Scalability for Large Datasets

- Memory profiling and reducing DataFrame footprint
- Efficient dtype selection for large datasets
- Vectorized operations versus row-wise iteration
- Using categorical dtype for memory efficiency
- Parallel and out-of-core processing options
- Integration with Dask for distributed data handling

### Data Quality and Validation

- Schema validation for incoming datasets
- Consistency checks across data sources
- Detecting data drift between training and production data
- Logging and auditing data transformations
- Unit testing data pipelines

### Visualization for Data Exploration

- Built-in plotting methods in pandas
- Exploratory statistical summaries
- Correlation analysis and heatmaps
- Distribution and outlier visualization techniques
