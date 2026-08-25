## Memory Management


Effective memory management prevents system crashes and improves performance when working with large datasets.

**Memory Monitoring**

```r
# Check memory usage
memory.limit()          # Windows only
memory.size()           # Current memory usage
memory.size(max = TRUE) # Peak memory usage

# Object memory consumption
object.size(my_data)
format(object.size(my_data), units = "MB")

# Detailed memory profiling
library(pryr)
mem_used()              # Current memory usage
mem_change({            # Memory change during operation
  large_object <- matrix(rnorm(1000000), nrow = 1000)
})
```

**Memory Optimization Strategies**

```r
# Remove large objects immediately after use
large_temp <- expensive_computation()
result <- summarize_data(large_temp)
rm(large_temp)
gc()  # Force garbage collection

# Use appropriate data types
# Instead of numeric for integers
ids <- as.integer(1:1000000)  # 4 bytes per element
# Instead of character for factors
categories <- as.factor(rep(c("A", "B", "C"), 1000000))

# Avoid unnecessary copies
# Bad: creates copy
data$new_column <- transform_function(data$old_column)
# Better: modify in place when possible
data.table::set(data, j = "new_column", value = transform_function(data$old_column))
```

**Memory-Efficient Data Structures**

```r
# Use matrices instead of data frames for numeric data
numeric_matrix <- matrix(rnorm(1000000), nrow = 1000)  # More memory efficient
numeric_df <- data.frame(matrix(rnorm(1000000), nrow = 1000))  # Less efficient

# Sparse matrices for data with many zeros
library(Matrix)
sparse_data <- sparseMatrix(i = sample(1000, 100),
                           j = sample(1000, 100),
                           x = rnorm(100),
                           dims = c(1000, 1000))
```

**Copy-on-Write Optimization**

```r
# R uses copy-on-write semantics
original_data <- large_dataset
subset_data <- original_data[1:1000, ]  # No copy until modification

# Avoid unnecessary modifications that trigger copies
# Bad: triggers copy
original_data$temp <- NULL
# Better: work with views or references when possible
```

