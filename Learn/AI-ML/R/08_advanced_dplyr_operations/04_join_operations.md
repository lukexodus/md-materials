## Join Operations


dplyr provides comprehensive joining capabilities for combining datasets:

### Inner Joins

Keep only rows with matches in both tables:

```r
# Basic inner join
inner_join(table1, table2, by = "id")

# Multiple join keys
inner_join(table1, table2, by = c("id", "category"))

# Different column names
inner_join(table1, table2, by = c("id" = "user_id"))
```

### Left Joins

Keep all rows from left table:

```r
# Keep all from table1
left_join(table1, table2, by = "id")

# Handle missing values
table1 %>%
  left_join(table2, by = "id") %>%
  mutate(value2 = coalesce(value2, 0))  # Replace NA with 0
```

### Right Joins

Keep all rows from right table:

```r
right_join(table1, table2, by = "id")
```

### Full Joins

Keep all rows from both tables:

```r
full_join(table1, table2, by = "id")
```

### Advanced Join Patterns

```r
# Multiple table joins
result <- table1 %>%
  left_join(table2, by = "id") %>%
  left_join(table3, by = "id") %>%
  left_join(table4, by = c("id", "category"))

# Conditional joins
left_join(table1, table2, by = "id", keep = TRUE) %>%
  filter(date.x <= date.y)

# Join with filtering
semi_join(table1, table2, by = "id")    # Rows in table1 with matches in table2
anti_join(table1, table2, by = "id")    # Rows in table1 without matches in table2
```

### Join Diagnostics

```r
# Check join results
table1 %>%
  left_join(table2, by = "id") %>%
  count(is.na(value_from_table2))  # Count missing joins

# Identify join problems
anti_join(table1, table2, by = "id") %>%  # Unmatched rows
  head()
```

