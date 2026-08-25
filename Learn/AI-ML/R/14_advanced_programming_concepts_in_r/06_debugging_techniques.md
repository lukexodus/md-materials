## Debugging Techniques


Effective debugging is crucial for developing robust R code. R provides several tools and techniques for identifying and fixing issues.

**Browser and Debug Functions**

```r
# Insert browser() for interactive debugging
my_function <- function(x, y) {
  browser()  # Execution stops here
  result <- x + y
  return(result)
}

# Debug a function
debug(my_function)
my_function(1, 2)  # Enters debug mode
undebug(my_function)
```

**Trace Function**

```r
# Trace function calls
trace(lm, tracer = quote(cat("lm called with", length(x), "observations\n")))
untrace(lm)

# Trace with custom code
trace(lm, exit = quote(cat("lm finished\n")))
```

**Options for Debugging**

```r
# Set debugging options
options(error = recover)  # Enter debugger on error
options(warn = 2)         # Convert warnings to errors
options(error = NULL)     # Reset error handling
```

**RStudio Debugging Features**

- Breakpoints in source editor
- Step through code execution
- Variable inspection
- Call stack navigation

**Debugging Strategies**

- Start with simple test cases
- Use `print()` statements strategically
- Check data types and structures with `str()`
- Validate assumptions with `stopifnot()`
- Use `browser()` at suspected problem locations

