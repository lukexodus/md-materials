## Overview


R provides a comprehensive suite of operators and functions that form the foundation of data analysis and programming. Understanding these fundamental building blocks enables efficient data manipulation, calculation, and transformation across various data types and structures.

**Arithmetic and Logical Operators**

R supports standard arithmetic operations with vectorized capabilities, meaning operations apply element-wise across vectors and matrices. The primary arithmetic operators include addition (`+`), subtraction (`-`), multiplication (`*`), division (`/`), integer division (`%/%`), modulo (`%%`), and exponentiation (`^` or `**`). These operators follow standard mathematical precedence rules and can handle mixed data types through automatic type coercion.

```r
# Basic arithmetic
x <- c(10, 20, 30)
y <- c(2, 4, 6)
x + y  # Element-wise addition: 12, 24, 36
x^2    # Exponentiation: 100, 400, 900
x %/% y # Integer division: 5, 5, 5
```

Logical operators include AND (`&`, `&&`), OR (`|`, `||`), and NOT (`!`). The single versions (`&`, `|`) perform element-wise operations on vectors, while double versions (`&&`, `||`) evaluate only the first elements and return single logical values, commonly used in control structures.

```r
# Logical operations
a <- c(TRUE, FALSE, TRUE)
b <- c(FALSE, TRUE, TRUE)
a & b   # Element-wise AND: FALSE, FALSE, TRUE
a && b  # First element AND: FALSE
```

**Comparison Operators**

R provides six primary comparison operators: equal (`==`), not equal (`!=`), less than (`<`), less than or equal (`<=`), greater than (`>`), and greater than or equal (`>=`). These operators return logical vectors when applied to data structures and handle missing values (`NA`) by propagating them through comparisons.

```r
# Comparison examples
numbers <- c(1, 5, 10, 15)
numbers > 7    # Returns: FALSE FALSE TRUE TRUE
numbers == 10  # Returns: FALSE FALSE TRUE FALSE
```

Special comparison functions include `identical()` for exact object comparison, `all.equal()` for near-equality with tolerance, and `%in%` for membership testing. The `is.na()`, `is.null()`, and `is.finite()` functions handle special value detection.

**Mathematical Functions**

R includes extensive mathematical functions covering basic operations, trigonometry, logarithms, and statistical calculations. Basic mathematical functions include `abs()` for absolute values, `sqrt()` for square roots, `ceiling()`, `floor()`, and `round()` for rounding operations, and `sign()` for determining number signs.

```r
# Mathematical function examples
values <- c(-2.7, 0, 3.14, 5.8)
abs(values)     # Absolute values
round(values, 1) # Round to 1 decimal place
sqrt(abs(values)) # Square root of absolute values
```

Trigonometric functions include `sin()`, `cos()`, `tan()` and their inverse counterparts `asin()`, `acos()`, `atan()`. Logarithmic functions encompass `log()` (natural logarithm), `log10()` (base-10), `log2()` (base-2), and `exp()` for exponential calculations.

Statistical functions provide measures of central tendency and dispersion: `mean()`, `median()`, `mode()`, `var()`, `sd()`, `min()`, `max()`, `range()`, `quantile()`, and `summary()`. These functions typically include parameters for handling missing values through the `na.rm` argument.

**String Functions and Manipulation**

R offers comprehensive string manipulation capabilities through base functions and enhanced functionality in packages like `stringr`. Core string functions include `nchar()` for character counting, `substr()` and `substring()` for extraction, `paste()` and `paste0()` for concatenation, and `strsplit()` for splitting strings.

```r
# String manipulation examples
text <- c("Hello", "World", "R Programming")
nchar(text)  # Character counts: 5, 5, 13
paste(text, collapse = " ")  # "Hello World R Programming"
substr(text, 1, 3)  # Extract first 3 characters
```

Pattern matching and replacement functions include `grep()`, `grepl()` for pattern detection, `sub()` and `gsub()` for substitution, and `regexpr()` for regular expression matching. These functions support both fixed strings and regular expressions for complex pattern matching.

Case conversion functions `toupper()`, `tolower()`, and `tools::toTitleCase()` handle text formatting, while `trimws()` removes leading and trailing whitespace. String formatting utilizes `sprintf()` for C-style formatting and `format()` for general object formatting.

**Date and Time Functions**

R handles temporal data through several classes and associated functions. The base `Date` class represents calendar dates, while `POSIXct` and `POSIXlt` handle date-time combinations with time zones. Creation functions include `Sys.Date()` for current date, `Sys.time()` for current date-time, and `as.Date()`, `as.POSIXct()` for conversion from various formats.

```r
# Date and time examples
current_date <- Sys.Date()
current_time <- Sys.time()
custom_date <- as.Date("2024-01-15")
date_sequence <- seq(as.Date("2024-01-01"), as.Date("2024-12-31"), by = "month")
```

Date arithmetic enables calculations between dates, returning `difftime` objects that can be converted to various units. Functions like `weekdays()`, `months()`, `quarters()` extract components, while `strftime()` and `strptime()` handle formatting and parsing with custom format strings.

The `lubridate` package [Unverified - external package] provides enhanced date-time manipulation with intuitive function names like `ymd()`, `mdy()`, `year()`, `month()`, `day()` for easier date handling and arithmetic operations.

**User-Defined Functions**

R allows custom function creation using the `function` keyword, enabling code reusability and modularization. Functions consist of formal arguments, a function body containing executable code, and an optional return value. The basic syntax follows `function_name <- function(arguments) { body }`.

```r
# User-defined function example
calculate_bmi <- function(weight, height) {
  bmi <- weight / (height^2)
  return(bmi)
}

# Function with default parameters
greet_user <- function(name, greeting = "Hello") {
  message <- paste(greeting, name, "!")
  return(message)
}
```

Functions can include default parameter values, variable-length argument lists using `...`, and internal variable assignments. The `return()` statement explicitly returns values, though R returns the last evaluated expression by default. Functions create their own execution environments, affecting variable scope and accessibility.

**Function Arguments and Parameters**

R functions support various argument-passing mechanisms including positional, named, partial matching, and variable-length arguments. Positional arguments match by order, while named arguments use explicit parameter names for clarity and flexibility in argument ordering.

```r
# Argument examples
my_function <- function(a, b = 10, c = 20, ...) {
  result <- a + b + c
  extra_args <- list(...)
  return(list(result = result, extra = extra_args))
}

# Different calling methods
my_function(5)                    # Positional with defaults
my_function(5, c = 30)           # Named arguments
my_function(5, 15, 25, x = 1, y = 2)  # With additional arguments
```

The ellipsis (`...`) parameter captures additional arguments not explicitly defined, useful for creating flexible functions that pass arguments to other functions. Functions like `match.arg()` provide argument validation and partial matching capabilities for robust parameter handling.

Default parameter values can reference other parameters or call functions, enabling dynamic default behavior. Parameter validation can occur within function bodies using conditional statements and functions like `stop()`, `warning()`, and `missing()` to check argument presence.

**Scope and Environments**

R uses lexical scoping rules where variables are resolved based on where functions are defined, not where they are called. Each function execution creates a new environment with access to its parent environment, creating a hierarchy for variable resolution.

```r
# Scope demonstration
global_var <- 100

outer_function <- function(x) {
  local_var <- 50
  
  inner_function <- function(y) {
    # Can access x, local_var, and global_var
    return(x + local_var + global_var + y)
  }
  
  return(inner_function)
}
```

Variable lookup follows the search path from the current environment through parent environments to the global environment and attached packages. Functions can modify variables in parent environments using the `<<-` operator, though this practice requires careful consideration for code maintainability.

Environment manipulation functions include `environment()`, `parent.env()`, `ls()`, and `exists()` for examining and working with environments. The `local()` function creates temporary environments for variable isolation, while `with()` and `within()` provide convenient ways to evaluate expressions within specific data contexts.

**Key Points**

R's operator and function system provides vectorized operations by default, making it efficient for data analysis tasks. Understanding precedence rules, type coercion, and vectorization behavior is crucial for writing effective R code. String manipulation capabilities support both simple operations and complex pattern matching through regular expressions.

Date and time handling requires understanding different classes and their appropriate use cases, with base R providing fundamental functionality and specialized packages offering enhanced features. User-defined functions enable code organization and reusability, with flexible parameter systems supporting various programming patterns.

Scope and environment concepts are fundamental to understanding variable accessibility and function behavior in R, particularly important for writing complex functions and avoiding naming conflicts in larger projects.

**Example**

A comprehensive example demonstrating multiple concepts:

```r
# Data analysis function combining multiple concepts
analyze_sales <- function(sales_data, start_date = "2024-01-01", 
                         end_date = Sys.Date(), ...) {
  # Input validation
  if (missing(sales_data) || !is.data.frame(sales_data)) {
    stop("sales_data must be a data frame")
  }
  
  # Date filtering
  start_date <- as.Date(start_date)
  end_date <- as.Date(end_date)
  filtered_data <- sales_data[sales_data$date >= start_date & 
                             sales_data$date <= end_date, ]
  
  # Statistical calculations
  summary_stats <- list(
    total_sales = sum(filtered_data$amount, na.rm = TRUE),
    average_sale = mean(filtered_data$amount, na.rm = TRUE),
    median_sale = median(filtered_data$amount, na.rm = TRUE),
    sales_count = nrow(filtered_data),
    date_range = paste(start_date, "to", end_date)
  )
  
  # String formatting for report
  report <- sprintf(
    "Sales Analysis Report\n%s\nTotal Sales: $%.2f\nAverage Sale: $%.2f\nNumber of Sales: %d",
    summary_stats$date_range,
    summary_stats$total_sales,
    summary_stats$average_sale,
    summary_stats$sales_count
  )
  
  return(list(statistics = summary_stats, report = report))
}
```

**Conclusion**

R's basic operations and functions form a robust foundation for data analysis and statistical computing. Mastering these fundamentals enables efficient data manipulation, custom function development, and complex analytical workflows. The vectorized nature of R operations, combined with flexible function definitions and lexical scoping, provides powerful tools for both interactive analysis and production-level programming.

Understanding these core concepts facilitates progression to more advanced R topics including object-oriented programming, package development, and specialized analytical techniques. The combination of built-in functions and user-defined capabilities allows R users to tackle diverse analytical challenges while maintaining code clarity and reusability.

---

