## Reshaping Data


### Wide to Long Format

Converting wide data (multiple columns per observation) to long format (one column per variable):

```r
# Sample wide data
wide_data <- data.frame(
  id = 1:3,
  name = c("Alice", "Bob", "Carol"),
  test1 = c(85, 92, 78),
  test2 = c(88, 89, 82),
  test3 = c(90, 94, 85)
)

# Using reshape() - base R approach
long_data <- reshape(wide_data, 
                     direction = "long",
                     varying = c("test1", "test2", "test3"),
                     v.names = "score",
                     timevar = "test",
                     times = c("test1", "test2", "test3"),
                     idvar = "id")
```

### Long to Wide Format

Converting long data back to wide format:

```r
# Convert back to wide
wide_again <- reshape(long_data,
                      direction = "wide",
                      v.names = "score",
                      timevar = "test",
                      idvar = "id")
```

### Manual Reshaping Techniques

For more control, you can manually reshape using indexing:

```r
# Create long format manually
ids <- rep(wide_data$id, 3)
names <- rep(wide_data$name, 3)
tests <- rep(c("test1", "test2", "test3"), each = 3)
scores <- c(wide_data$test1, wide_data$test2, wide_data$test3)

manual_long <- data.frame(id = ids, name = names, test = tests, score = scores)
```

