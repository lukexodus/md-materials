## Vectorized Operations vs Loops


R's strength lies in vectorized operations, which are generally more efficient than explicit loops.

### Vectorized Approach

```r
# Vectorized - preferred
numbers <- 1:1000000
squares <- numbers^2
```

### Loop Approach

```r
# Loop - less efficient
numbers <- 1:1000000
squares <- numeric(length(numbers))
for (i in seq_along(numbers)) {
    squares[i] <- numbers[i]^2
}
```

**Key Points:**

- Vectorized operations are typically 10-100 times faster than loops
- R's internal C implementations handle vectorized operations
- Memory allocation is more efficient with vectorized operations
- Code is more readable and concise

### When to Use Loops

Despite vectorization advantages, loops are necessary for:

- Complex conditional logic within iterations
- Operations that depend on previous iterations
- File processing or database operations
- When vectorization isn't straightforward

