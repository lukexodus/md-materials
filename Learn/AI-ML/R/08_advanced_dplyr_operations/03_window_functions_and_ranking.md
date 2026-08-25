## Window Functions and Ranking


Window functions operate on groups of rows related to the current row:

### Ranking Functions

```r
mtcars %>%
  mutate(
    # Rankings
    mpg_rank = row_number(desc(mpg)),        # 1, 2, 3, 4...
    mpg_min_rank = min_rank(desc(mpg)),      # Handles ties: 1, 2, 2, 4...
    mpg_dense_rank = dense_rank(desc(mpg)),  # Handles ties: 1, 2, 2, 3...
    
    # Percentiles
    mpg_percent_rank = percent_rank(mpg),    # 0 to 1
    mpg_cume_dist = cume_dist(mpg),         # Cumulative distribution
    
    # Quantiles
    mpg_ntile = ntile(mpg, 4)               # Quartiles: 1, 2, 3, 4
  )
```

### Lead and Lag Functions

```r
# Time series operations
data %>%
  arrange(date) %>%
  mutate(
    prev_value = lag(value, n = 1),
    next_value = lead(value, n = 1),
    value_change = value - lag(value),
    pct_change = (value - lag(value)) / lag(value) * 100
  )

# Grouped lead/lag
data %>%
  group_by(group) %>%
  arrange(date) %>%
  mutate(
    prev_in_group = lag(value),
    next_in_group = lead(value)
  )
```

### Cumulative Functions

```r
mtcars %>%
  arrange(mpg) %>%
  mutate(
    cumulative_sum = cumsum(hp),
    cumulative_mean = cummean(hp),
    cumulative_min = cummin(hp),
    cumulative_max = cummax(hp)
  )
```

### Grouped Window Functions

```r
mtcars %>%
  group_by(cyl) %>%
  mutate(
    mpg_rank_in_group = row_number(desc(mpg)),
    mpg_vs_group_avg = mpg - mean(mpg),
    top_in_group = mpg == max(mpg)
  )
```

