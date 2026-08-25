## Aggregation and Summarization


### The `aggregate()` Function

`aggregate()` provides grouped summarization:

```r
# Sample data with groups
sales_data <- data.frame(
  region = c("North", "South", "North", "South", "North", "South"),
  product = c("A", "A", "B", "B", "A", "B"),
  sales = c(100, 150, 120, 180, 110, 160)
)

# Aggregate by single variable
aggregate(sales ~ region, data = sales_data, FUN = sum)
aggregate(sales ~ region, data = sales_data, FUN = mean)

# Aggregate by multiple variables
aggregate(sales ~ region + product, data = sales_data, FUN = sum)

# Multiple functions using custom function
aggregate(sales ~ region, data = sales_data, 
          FUN = function(x) c(mean = mean(x), sd = sd(x), count = length(x)))
```

### The `tapply()` Function

`tapply()` applies functions to subsets defined by factors:

```r
# Group by single factor
tapply(sales_data$sales, sales_data$region, sum)
tapply(sales_data$sales, sales_data$region, mean)

# Group by multiple factors
tapply(sales_data$sales, list(sales_data$region, sales_data$product), sum)
```

### Other Aggregation Functions

```r
# by() function - similar to tapply but returns a list
by(sales_data$sales, sales_data$region, summary)

# Built-in summary functions
summary(sales_data)         # Summary statistics for all columns
table(sales_data$region)    # Frequency counts
prop.table(table(sales_data$region))  # Proportions
```

