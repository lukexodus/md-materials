## Conditional Execution Patterns


### switch Statement

Elegant multiple condition handling:

```r
operation <- "add"
x <- 10
y <- 5

result <- switch(operation,
    "add" = x + y,
    "subtract" = x - y,
    "multiply" = x * y,
    "divide" = x / y,
    "Unknown operation"
)
```

### Nested Conditionals

Complex decision trees:

```r
process_grade <- function(score, extra_credit=FALSE) {
    if (score >= 60) {
        if (extra_credit) {
            if (score >= 95) return("A+")
            else if (score >= 90) return("A")
            else return("A-")
        } else {
            if (score >= 90) return("A")
            else if (score >= 80) return("B")
            else return("C")
        }
    } else {
        return("F")
    }
}
```

### Vectorized Conditional Patterns

Using logical indexing for efficient conditional operations:

```r
data <- c(1, -5, 10, -3, 8, -2)

# Replace negative values with zero
data[data < 0] <- 0

# Complex conditional replacement
data <- ifelse(data > 5, "High", 
        ifelse(data > 2, "Medium", "Low"))
```

### Error Handling in Control Structures

```r
safe_division <- function(x, y) {
    if (y == 0) {
        warning("Division by zero")
        return(NA)
    } else {
        return(x / y)
    }
}
```

