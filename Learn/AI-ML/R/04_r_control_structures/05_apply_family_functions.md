## apply Family Functions


The apply family provides functional programming approaches to repetitive tasks.

### apply Function

Applies functions over array margins:

```r
# Create matrix
matrix_data <- matrix(1:12, nrow=3, ncol=4)

# Apply sum to rows (margin=1)
row_sums <- apply(matrix_data, 1, sum)

# Apply mean to columns (margin=2)
col_means <- apply(matrix_data, 2, mean)

# Apply custom function
apply(matrix_data, 2, function(x) max(x) - min(x))
```

### lapply Function

Applies functions to list elements, returns list:

```r
numbers_list <- list(a=1:5, b=6:10, c=11:15)
means <- lapply(numbers_list, mean)
```

### sapply Function

Simplifies lapply output when possible:

```r
# Returns vector instead of list
means_vector <- sapply(numbers_list, mean)
```

### vapply Function

Type-safe version of sapply:

```r
# Specify return type for safety
means_safe <- vapply(numbers_list, mean, FUN.VALUE=numeric(1))
```

### mapply Function

Multivariate version of sapply:

```r
# Apply function to multiple vectors simultaneously
vec1 <- c(1, 2, 3)
vec2 <- c(4, 5, 6)
result <- mapply(function(x, y) x + y, vec1, vec2)
```

### tapply Function

Applies functions to subsets defined by factors:

```r
# Group data by factor and apply function
data <- c(1, 2, 3, 4, 5, 6)
groups <- factor(c("A", "A", "B", "B", "C", "C"))
group_means <- tapply(data, groups, mean)
```

