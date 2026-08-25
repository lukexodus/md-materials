## Overview


**Data Types:**

- Numeric (integer and double)
- Character strings
- Logical (boolean) values
- Complex numbers

**Data Structures:**

- Vectors (creation, operations, indexing)
- Lists (named and nested)
- Matrices and arrays (multidimensional)
- Data frames and tibbles

**Special Values:**

- NULL (absence of data)
- NA (missing values)
- NaN (not a number)
- Inf (infinity)

**Type System:**

- Implicit and explicit coercion
- Conversion between types
- Testing functions

```r
# ============================================================================
# R DATA TYPES AND STRUCTURES - COMPREHENSIVE GUIDE
# ============================================================================

# ============================================================================
# 1. BASIC DATA TYPES
# ============================================================================

# NUMERIC TYPE
# ------------
# Integer and double (real numbers)
int_num <- 42L          # Integer (note the L suffix)
double_num <- 42.5      # Double/numeric
sci_notation <- 1.2e3   # Scientific notation (1200)

# Check type
class(int_num)          # "integer"
class(double_num)       # "numeric"
typeof(int_num)         # "integer"
typeof(double_num)      # "double"

# Numeric operations
x <- 10
y <- 3
x + y                   # Addition: 13
x - y                   # Subtraction: 7
x * y                   # Multiplication: 30
x / y                   # Division: 3.333333
x %% y                  # Modulo: 1
x %/% y                 # Integer division: 3
x ^ y                   # Exponentiation: 1000

# CHARACTER TYPE
# --------------
char1 <- "Hello"
char2 <- 'World'
char3 <- "123"          # Numbers as characters

# Character operations
paste(char1, char2)                    # "Hello World"
paste0(char1, char2)                   # "HelloWorld"
nchar(char1)                           # 5 (number of characters)
substr(char1, 1, 3)                    # "Hel"
toupper(char1)                         # "HELLO"
tolower(char1)                         # "hello"

# LOGICAL TYPE
# ------------
bool1 <- TRUE          # or T
bool2 <- FALSE         # or F
bool3 <- 5 > 3         # TRUE
bool4 <- 2 == 3        # FALSE

# Logical operations
!bool1                 # NOT: FALSE
bool1 & bool2          # AND: FALSE
bool1 | bool2          # OR: TRUE
bool1 && bool2         # Short-circuit AND: FALSE
bool1 || bool2         # Short-circuit OR: TRUE

# COMPLEX TYPE
# ------------
complex1 <- 3 + 4i
complex2 <- complex(real = 1, imaginary = 2)

# Complex operations
Re(complex1)           # Real part: 3
Im(complex1)           # Imaginary part: 4
Mod(complex1)          # Modulus: 5
Arg(complex1)          # Argument (angle)

# ============================================================================
# 2. VECTORS
# ============================================================================

# CREATING VECTORS
# ----------------
# c() function - combine
num_vec <- c(1, 2, 3, 4, 5)
char_vec <- c("a", "b", "c")
log_vec <- c(TRUE, FALSE, TRUE)

# Sequence functions
seq_vec1 <- 1:10                      # 1 to 10
seq_vec2 <- seq(0, 1, by = 0.1)      # 0 to 1 by 0.1
seq_vec3 <- seq(0, 1, length.out = 11) # 0 to 1, 11 points
rep_vec <- rep(c(1, 2), times = 3)    # Repeat: 1 2 1 2 1 2
rep_vec2 <- rep(c(1, 2), each = 3)    # Repeat: 1 1 1 2 2 2

# VECTOR PROPERTIES
# -----------------
length(num_vec)        # 5
names(num_vec)         # NULL (no names yet)
str(num_vec)           # Structure

# Named vectors
named_vec <- c(a = 1, b = 2, c = 3)
names(named_vec)       # "a" "b" "c"

# Add names to existing vector
names(num_vec) <- c("first", "second", "third", "fourth", "fifth")

# VECTOR INDEXING
# ---------------
num_vec[1]             # First element
num_vec[c(1, 3)]       # First and third elements
num_vec[-1]            # All except first
num_vec[1:3]           # First three elements
num_vec[num_vec > 2]   # Elements greater than 2
num_vec["first"]       # By name

# VECTOR OPERATIONS
# -----------------
vec1 <- c(1, 2, 3)
vec2 <- c(4, 5, 6)

vec1 + vec2            # Element-wise addition: 5 6 7
vec1 * vec2            # Element-wise multiplication: 4 10 18
vec1 + 10              # Scalar addition: 11 12 13

# Vector recycling (shorter vector repeated)
c(1, 2, 3, 4) + c(10, 20)  # 11 22 13 24

# Vector functions
sum(vec1)              # 6
mean(vec1)             # 2
max(vec1)              # 3
min(vec1)              # 1
which.max(vec1)        # 3 (index of maximum)
which(vec1 > 1)        # 2 3 (indices where condition is TRUE)

# ============================================================================
# 3. LISTS
# ============================================================================

# CREATING LISTS
# ---------------
# Lists can contain different data types
simple_list <- list(1, "hello", TRUE)
named_list <- list(numbers = c(1, 2, 3),
                   text = "hello",
                   logical = TRUE,
                   nested_list = list(a = 1, b = 2))

# LIST PROPERTIES
# ---------------
length(named_list)     # 4
names(named_list)      # "numbers" "text" "logical" "nested_list"
str(named_list)        # Structure

# LIST INDEXING
# -------------
# Single bracket returns list
named_list[1]          # List with first element
named_list["numbers"]  # List with "numbers" element

# Double bracket returns element itself
named_list[[1]]        # The vector c(1, 2, 3)
named_list[["numbers"]] # The vector c(1, 2, 3)
named_list$numbers     # The vector c(1, 2, 3) (dollar notation)

# Nested access
named_list$nested_list$a  # 1

# MODIFYING LISTS
# ---------------
named_list$new_element <- "added"
named_list[["another"]] <- c(7, 8, 9)
named_list$numbers[1] <- 99  # Modify element within list component

# Remove elements
named_list$new_element <- NULL
named_list[["another"]] <- NULL

# ============================================================================
# 4. MATRICES AND ARRAYS
# ============================================================================

# MATRICES
# --------
# Creating matrices
mat1 <- matrix(1:12, nrow = 3, ncol = 4)
mat2 <- matrix(1:12, nrow = 3, ncol = 4, byrow = TRUE)

# Matrix from vectors
vec_a <- c(1, 2, 3)
vec_b <- c(4, 5, 6)
mat3 <- cbind(vec_a, vec_b)  # Column bind
mat4 <- rbind(vec_a, vec_b)  # Row bind

# Matrix properties
dim(mat1)              # Dimensions: 3 4
nrow(mat1)             # Number of rows: 3
ncol(mat1)             # Number of columns: 4
dimnames(mat1)         # NULL (no row/column names)

# Add names
rownames(mat1) <- c("row1", "row2", "row3")
colnames(mat1) <- c("col1", "col2", "col3", "col4")

# MATRIX INDEXING
# ---------------
mat1[1, 2]             # Element at row 1, column 2
mat1[1, ]              # Entire first row
mat1[, 2]              # Entire second column
mat1[1:2, 2:3]         # Submatrix
mat1["row1", "col2"]   # By name

# MATRIX OPERATIONS
# -----------------
mat_a <- matrix(1:4, nrow = 2)
mat_b <- matrix(5:8, nrow = 2)

mat_a + mat_b          # Element-wise addition
mat_a * mat_b          # Element-wise multiplication
mat_a %*% mat_b        # Matrix multiplication
t(mat_a)               # Transpose

# Matrix functions
apply(mat1, 1, sum)    # Row sums
apply(mat1, 2, mean)   # Column means
rowSums(mat1)          # Row sums (faster)
colMeans(mat1)         # Column means (faster)

# ARRAYS (multidimensional)
# -------------------------
# Arrays are generalizations of matrices
arr <- array(1:24, dim = c(2, 3, 4))  # 2x3x4 array
dim(arr)               # 2 3 4
arr[1, 2, 3]           # Element at position [1,2,3]

# ============================================================================
# 5. DATA FRAMES
# ============================================================================

# CREATING DATA FRAMES
# --------------------
df <- data.frame(
  name = c("Alice", "Bob", "Charlie"),
  age = c(25, 30, 35),
  married = c(TRUE, FALSE, TRUE),
  stringsAsFactors = FALSE  # Don't convert strings to factors
)

# DATA FRAME PROPERTIES
# ---------------------
nrow(df)               # Number of rows: 3
ncol(df)               # Number of columns: 3
dim(df)                # Dimensions: 3 3
names(df)              # Column names
colnames(df)           # Column names (same as names())
rownames(df)           # Row names
str(df)                # Structure
summary(df)            # Summary statistics

# DATA FRAME INDEXING
# -------------------
df[1, 2]               # Row 1, column 2
df[1, ]                # First row (returns data frame)
df[, 2]                # Second column (returns vector)
df[, "age"]            # Column by name (returns vector)
df["age"]              # Column by name (returns data frame)
df$age                 # Column by name (returns vector)
df[["age"]]            # Column by name (returns vector)

# Multiple columns
df[c("name", "age")]
df[, c("name", "age")]

# Conditional indexing
df[df$age > 28, ]      # Rows where age > 28
df[df$married == TRUE, "name"]  # Names of married people

# MODIFYING DATA FRAMES
# ---------------------
df$salary <- c(50000, 60000, 70000)  # Add column
df[["bonus"]] <- df$salary * 0.1     # Add computed column

# Modify existing values
df$age[1] <- 26
df[df$name == "Bob", "age"] <- 31

# Remove columns
df$bonus <- NULL

# Add rows
new_row <- data.frame(name = "David", age = 28, married = FALSE, salary = 55000)
df <- rbind(df, new_row)

# TIBBLES (modern data frames)
# ----------------------------
# Note: Requires tidyverse/tibble package
# library(tibble)
# 
# tbl <- tibble(
#   x = 1:3,
#   y = c("a", "b", "c"),
#   z = x^2
# )
# 
# # Tibbles have better printing and stricter behavior
# # They don't convert strings to factors by default
# # They don't do partial matching of column names

# ============================================================================
# 6. FACTORS
# ============================================================================

# CREATING FACTORS
# ----------------
# Factors represent categorical data
colors <- c("red", "blue", "red", "green", "blue")
color_factor <- factor(colors)
print(color_factor)

# Check levels
levels(color_factor)   # "blue" "green" "red" (alphabetical)

# Specify levels explicitly
color_factor2 <- factor(colors, levels = c("red", "blue", "green"))
levels(color_factor2)  # "red" "blue" "green"

# ORDERED FACTORS
# ---------------
sizes <- c("small", "large", "medium", "small", "medium")
size_factor <- factor(sizes, 
                     levels = c("small", "medium", "large"), 
                     ordered = TRUE)
print(size_factor)

# Ordered comparisons work
size_factor[1] < size_factor[2]  # small < large: TRUE

# FACTOR OPERATIONS
# -----------------
# Convert to character
as.character(color_factor)

# Add new level
levels(color_factor) <- c(levels(color_factor), "yellow")

# Drop unused levels
color_factor_subset <- color_factor[1:3]  # Only has red, blue
droplevels(color_factor_subset)

# Relevel (change reference level)
relevel(color_factor, ref = "green")

# ============================================================================
# 7. SPECIAL VALUES: NULL, NA, NaN, Inf
# ============================================================================

# NULL - represents absence of data
# ----------------------------------
x <- NULL
is.null(x)             # TRUE
length(x)              # 0

# NA - missing values
# -------------------
y <- c(1, 2, NA, 4, 5)
is.na(y)               # FALSE FALSE TRUE FALSE FALSE
sum(y)                 # NA (any operation with NA gives NA)
sum(y, na.rm = TRUE)   # 12 (remove NA values)

# Different types of NA
na_char <- NA_character_
na_int <- NA_integer_
na_real <- NA_real_
na_log <- NA

# NaN - Not a Number
# ------------------
z <- 0/0
is.nan(z)              # TRUE
is.na(z)               # TRUE (NaN is a special case of NA)

# Inf - Infinity
# --------------
inf_val <- 1/0         # Inf
neg_inf <- -1/0        # -Inf
is.infinite(inf_val)   # TRUE
is.finite(inf_val)     # FALSE

# Testing functions
is.na(c(NA, NaN, 1))   # TRUE TRUE FALSE
is.nan(c(NA, NaN, 1))  # FALSE TRUE FALSE
is.finite(c(1, Inf, NA, NaN))  # TRUE FALSE FALSE FALSE

# ============================================================================
# 8. TYPE COERCION AND CONVERSION
# ============================================================================

# IMPLICIT COERCION
# -----------------
# R automatically converts types when needed
# Hierarchy: character > numeric > logical

mixed_vec <- c(TRUE, 1, "hello")  # All converted to character
print(mixed_vec)  # "TRUE" "1" "hello"

num_log <- c(TRUE, FALSE, 1, 0)   # Logical converted to numeric
print(num_log)    # 1 0 1 0

# EXPLICIT CONVERSION
# -------------------
# Numeric conversions
as.numeric(c("1", "2.5", "3"))     # 1.0 2.5 3.0
as.numeric(c(TRUE, FALSE))         # 1 0
as.integer(c(1.7, 2.9))           # 1 2 (truncation)

# Character conversions
as.character(c(1, 2, 3))          # "1" "2" "3"
as.character(c(TRUE, FALSE))      # "TRUE" "FALSE"

# Logical conversions
as.logical(c(1, 0, 2, -1))        # TRUE FALSE TRUE TRUE
as.logical(c("TRUE", "FALSE", "T", "F"))  # TRUE FALSE TRUE FALSE

# Factor conversions
nums <- c(1, 2, 1, 3, 2)
factor_nums <- as.factor(nums)
as.numeric(factor_nums)           # 1 2 1 3 2 (levels as numbers)
as.numeric(as.character(factor_nums))  # Original numbers

# TESTING TYPES
# --------------
x <- 42
is.numeric(x)          # TRUE
is.integer(x)          # FALSE (it's actually double)
is.character(x)        # FALSE
is.logical(x)          # FALSE

# More specific tests
is.double(x)           # TRUE
is.atomic(x)           # TRUE (atomic vector)
is.vector(x)           # TRUE

# For data structures
df_test <- data.frame(x = 1:3, y = letters[1:3])
is.data.frame(df_test) # TRUE
is.list(df_test)       # TRUE (data frames are special lists)

mat_test <- matrix(1:6, nrow = 2)
is.matrix(mat_test)    # TRUE
is.array(mat_test)     # TRUE (matrices are 2D arrays)

# ============================================================================
# SUMMARY AND BEST PRACTICES
# ============================================================================

# 1. Choose appropriate data structure:
#    - Vectors: homogeneous data, same type
#    - Lists: heterogeneous data, different types
#    - Data frames: rectangular data, like spreadsheets
#    - Matrices: numerical data, mathematical operations
#    - Factors: categorical data with fixed levels

# 2. Be aware of type coercion - R will convert types automatically

# 3. Use appropriate indexing method:
#    - [] for subsetting (returns same type)
#    - [[]] for extracting single elements
#    - $ for named elements (lists, data frames)

# 4. Handle missing values explicitly with na.rm or complete.cases()

# 5. Use factors for categorical data to save memory and enable
#    statistical functions that require categorical variables
```

---

