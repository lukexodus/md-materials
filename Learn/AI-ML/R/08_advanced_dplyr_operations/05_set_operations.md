## Set Operations


Combine datasets using set theory operations:

```r
# Union (all unique rows)
union(table1, table2)
union_all(table1, table2)  # Keep duplicates

# Intersection (common rows)
intersect(table1, table2)

# Difference (rows in table1 but not table2)
setdiff(table1, table2)

# Check equality
setequal(table1, table2)
```

