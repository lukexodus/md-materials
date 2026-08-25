## Merging and Joining Data


### The `merge()` Function

Base R's `merge()` function performs database-style joins:

```r
df1 <- data.frame(id = 1:3, name = c("Alice", "Bob", "Carol"))
df2 <- data.frame(id = 2:4, score = c(85, 92, 78))

# Inner join (default)
merge(df1, df2, by = "id")              # Only matching IDs: 2, 3

# Left join
merge(df1, df2, by = "id", all.x = TRUE) # All rows from df1

# Right join  
merge(df1, df2, by = "id", all.y = TRUE) # All rows from df2

# Full outer join
merge(df1, df2, by = "id", all = TRUE)   # All rows from both

# Different column names
df3 <- data.frame(person_id = 2:4, score = c(85, 92, 78))
merge(df1, df3, by.x = "id", by.y = "person_id")
```

### Binding Operations

```r
# Row binding (same columns)
df_new <- data.frame(id = 4, name = "David")
rbind(df1, df_new)

# Column binding (same number of rows)
extra_col <- data.frame(city = c("NYC", "LA", "Chicago"))
cbind(df1, extra_col)
```

