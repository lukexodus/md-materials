## Loop Structures


R provides three primary loop types for iterative operations.

### for Loops

Iterate over sequences or collections:

```r
# Iterate over vector
for (i in 1:5) {
    print(i^2)
}

# Iterate over list elements
fruits <- c("apple", "banana", "orange")
for (fruit in fruits) {
    print(paste("I like", fruit))
}

# Iterate with indices
for (i in seq_along(fruits)) {
    print(paste(i, ":", fruits[i]))
}
```

### while Loops

Execute while condition remains TRUE:

```r
counter <- 1
while (counter <= 5) {
    print(counter)
    counter <- counter + 1
}
```

### repeat Loops

Infinite loops requiring explicit break:

```r
counter <- 1
repeat {
    print(counter)
    counter <- counter + 1
    if (counter > 5) break
}
```

