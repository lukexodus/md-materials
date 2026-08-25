## Performance Considerations


**Key Points:**

- Vectorized operations outperform loops significantly
- Pre-allocate vectors/lists before loops when vectorization isn't possible
- Use apply family functions instead of loops when appropriate
- Profile code to identify bottlenecks
- Consider parallel processing for large datasets

**Example** of efficient loop structure:

```r
# Inefficient - grows vector
result <- c()
for (i in 1:10000) {
    result <- c(result, i^2)
}

# Efficient - pre-allocated
result <- numeric(10000)
for (i in 1:10000) {
    result[i] <- i^2
}

# Most efficient - vectorized
result <- (1:10000)^2
```

Understanding and properly implementing R's control structures enables efficient data manipulation, statistical computing, and algorithm implementation while maintaining code readability and performance.

---

