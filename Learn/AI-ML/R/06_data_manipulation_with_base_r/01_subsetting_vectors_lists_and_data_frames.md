## Subsetting Vectors, Lists, and Data Frames


### Vector Subsetting

Vectors can be subset using multiple methods:

**Positive indexing** selects specific elements by position:

```r
x <- c(10, 20, 30, 40, 50)
x[1]        # First element: 10
x[c(1, 3)]  # First and third: 10, 30
x[1:3]      # Range: 10, 20, 30
```

**Negative indexing** excludes specified positions:

```r
x[-1]       # All except first: 20, 30, 40, 50
x[-c(1,3)]  # All except first and third: 20, 40, 50
```

**Logical indexing** uses TRUE/FALSE conditions:

```r
x[x > 25]   # Elements greater than 25: 30, 40, 50
x[x %in% c(20, 40)]  # Elements matching values: 20, 40
```

**Named indexing** works with named vectors:

```r
names(x) <- c("a", "b", "c", "d", "e")
x["a"]      # Element named "a"
x[c("a", "c")]  # Multiple named elements
```

### List Subsetting

Lists require different operators for different access levels:

```r
my_list <- list(numbers = 1:5, letters = LETTERS[1:3], data = data.frame(x = 1:2, y = 3:4))

# Single bracket returns a list
my_list[1]          # Returns list with first element
my_list["numbers"]  # Returns list with named element

# Double bracket returns the actual element
my_list[[1]]        # Returns the vector 1:5
my_list[["numbers"]] # Same as above
my_list$numbers     # Dollar sign notation for named elements
```

### Data Frame Subsetting

Data frames combine characteristics of lists and matrices:

```r
df <- data.frame(name = c("Alice", "Bob", "Carol"), 
                 age = c(25, 30, 35), 
                 score = c(85, 92, 78))

# Column selection
df$name             # Single column as vector
df["name"]          # Single column as data frame
df[c("name", "age")] # Multiple columns

# Row selection
df[1, ]             # First row, all columns
df[1:2, ]           # First two rows

# Combined selection
df[1, "name"]       # Specific cell
df[1:2, c("name", "age")] # Subset of rows and columns
```

