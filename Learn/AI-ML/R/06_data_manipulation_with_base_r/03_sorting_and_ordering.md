## Sorting and Ordering


### Vector Sorting

The `sort()` function returns sorted values:

```r
numbers <- c(3, 1, 4, 1, 5)
sort(numbers)                   # Ascending: 1, 1, 3, 4, 5
sort(numbers, decreasing = TRUE) # Descending: 5, 4, 3, 1, 1
```

### Ordering with `order()`

The `order()` function returns indices for sorted arrangement:

```r
order(numbers)                  # Indices for ascending sort: 2, 4, 1, 3, 5
numbers[order(numbers)]         # Same result as sort(numbers)

# Data frame ordering
df[order(df$age), ]             # Sort by age ascending
df[order(-df$score), ]          # Sort by score descending (note the minus sign)
df[order(df$age, -df$score), ]  # Sort by age, then score descending
```

### Specialized Sorting Functions

```r
# rank() returns ranks instead of sorted values
rank(c(3, 1, 4, 1, 5))         # 3, 1.5, 4, 1.5, 5 (average ranks for ties)

# rev() reverses order
rev(1:5)                        # 5, 4, 3, 2, 1
```

