## Aggregation and Grouping


### summarise Operations

Compute summary statistics:

```r
# Basic summaries
summarise(mtcars,
          mean_mpg = mean(mpg),
          median_hp = median(hp),
          sd_wt = sd(wt),
          n_cars = n())

# Multiple statistics per variable
summarise(mtcars,
          across(c(mpg, hp, wt), 
                 list(mean = mean, sd = sd, min = min, max = max)))

# Custom functions
summarise(mtcars,
          mpg_range = max(mpg) - min(mpg),
          efficiency_ratio = mean(mpg) / mean(hp))
```

### group_by Operations

Perform operations within groups:

```r
# Single grouping variable
mtcars %>%
  group_by(cyl) %>%
  summarise(mean_mpg = mean(mpg),
            count = n())

# Multiple grouping variables
mtcars %>%
  group_by(cyl, gear) %>%
  summarise(mean_mpg = mean(mpg),
            .groups = "keep")  # Control grouping behavior

# Grouped mutations
mtcars %>%
  group_by(cyl) %>%
  mutate(mpg_centered = mpg - mean(mpg),
         above_group_avg = mpg > mean(mpg))

# Grouped filtering
mtcars %>%
  group_by(cyl) %>%
  filter(mpg > mean(mpg))

# Complex grouping
starwars %>%
  group_by(homeworld, species) %>%
  summarise(avg_height = mean(height, na.rm = TRUE),
            count = n(),
            .groups = "drop")
```

Advanced grouping patterns:

```r
# Conditional grouping
group_by(data, if (condition) var1 else var2)

# Dynamic grouping
group_vars <- c("cyl", "gear")
mtcars %>% group_by(across(all_of(group_vars)))

# Nested grouping operations
mtcars %>%
  group_by(cyl) %>%
  group_modify(~ {
    .x %>% arrange(desc(mpg)) %>% slice_head(n = 2)
  })
```

