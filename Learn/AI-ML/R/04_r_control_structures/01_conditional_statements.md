## Conditional Statements


R offers several mechanisms for conditional execution, each suited to different scenarios and data structures.

### if Statement

The basic if statement executes code when a condition is TRUE:

```r
x <- 10
if (x > 5) {
    print("x is greater than 5")
}
```

### if-else Statement

Provides alternative execution paths:

```r
temperature <- 25
if (temperature > 30) {
    print("It's hot")
} else {
    print("It's not hot")
}
```

### else if Chains

Handle multiple conditions sequentially:

```r
score <- 85
if (score >= 90) {
    grade <- "A"
} else if (score >= 80) {
    grade <- "B"
} else if (score >= 70) {
    grade <- "C"
} else {
    grade <- "F"
}
```

### ifelse Function

Vectorized conditional operation for vectors:

```r
numbers <- c(1, 5, 10, 15, 20)
result <- ifelse(numbers > 10, "High", "Low")
# Returns: "Low" "Low" "Low" "High" "High"
```

The ifelse function operates element-wise on vectors, making it more efficient than loops for vector operations.

