## Error Handling


Robust error handling prevents code crashes and provides meaningful feedback to users.

**try() Function**

```r
# Basic try usage
result <- try({
  risky_operation <- log(-1)  # This will produce a warning
  return(risky_operation)
}, silent = TRUE)

# Check if error occurred
if (inherits(result, "try-error")) {
  cat("An error occurred:", attr(result, "condition")$message)
}
```

**tryCatch() Function**

```r
# Comprehensive error handling
safe_division <- function(x, y) {
  result <- tryCatch({
    if (y == 0) stop("Division by zero")
    x / y
  }, 
  error = function(e) {
    cat("Error:", e$message, "\n")
    return(NA)
  },
  warning = function(w) {
    cat("Warning:", w$message, "\n")
    return(x / y)
  },
  finally = {
    cat("Division operation completed\n")
  })
  
  return(result)
}
```

**Custom Error Classes**

```r
# Define custom error class
validation_error <- function(message) {
  structure(
    list(message = message, call = sys.call(-1)),
    class = c("validation_error", "error", "condition")
  )
}

# Function using custom error
validate_input <- function(x) {
  if (!is.numeric(x)) {
    stop(validation_error("Input must be numeric"))
  }
  if (any(x < 0)) {
    stop(validation_error("All values must be non-negative"))
  }
  return(TRUE)
}
```

**Error Handling Best Practices**

- Fail fast: Check inputs early in functions
- Provide informative error messages
- Use specific error types when appropriate
- Clean up resources in `finally` blocks
- Log errors for debugging purposes

