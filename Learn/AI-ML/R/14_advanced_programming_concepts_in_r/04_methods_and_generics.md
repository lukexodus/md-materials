## Methods and Generics


Generic functions provide a unified interface for different object types, enabling polymorphic behavior.

**Creating Generic Functions**

```r
# S3 generic
calculate_bonus <- function(x, ...) {
  UseMethod("calculate_bonus")
}

# S3 methods for different classes
calculate_bonus.Employee <- function(x, rate = 0.1, ...) {
  x$salary * rate
}

calculate_bonus.Manager <- function(x, rate = 0.15, ...) {
  base_bonus <- x$salary * rate
  team_bonus <- x$team_size * 1000
  return(base_bonus + team_bonus)
}
```

**Method Resolution** R's method dispatch system follows specific rules to determine which method to call:

1. Exact class match
2. Inheritance hierarchy (for S4)
3. Default method
4. Error if no method found

**Built-in Generics** R provides many built-in generic functions:

- `print()`, `summary()`, `plot()`
- `length()`, `names()`, `str()`
- Mathematical operations: `+`, `-`, `*`, `/`

