## Indexing and Filtering


### Conditional Filtering

Logical conditions create powerful filtering mechanisms:

```r
# Single conditions
df[df$age > 25, ]               # Rows where age > 25
df[df$name == "Alice", ]        # Rows where name equals "Alice"
df[df$score >= 80, ]            # Rows where score >= 80

# Multiple conditions with & (AND) and | (OR)
df[df$age > 25 & df$score > 80, ]   # Age > 25 AND score > 80
df[df$age < 30 | df$score > 90, ]   # Age < 30 OR score > 90

# Using %in% for multiple value matching
df[df$name %in% c("Alice", "Carol"), ]
```

### Advanced Filtering Functions

The `which()` function returns indices of TRUE values:

```r
which(df$age > 25)              # Returns row indices: 2, 3
df[which(df$age > 25), ]        # Same as df[df$age > 25, ]

# which.max() and which.min() find extreme values
which.max(df$score)             # Index of maximum score
which.min(df$age)               # Index of minimum age
```

The `subset()` function provides cleaner syntax:

```r
subset(df, age > 25)                    # Rows where age > 25
subset(df, age > 25, select = c(name, score))  # Specific columns
subset(df, age > 25 & score > 80)       # Multiple conditions
```

