## across Function for Column Operations


The across function enables operations across multiple columns:

### Basic across Usage

```r
# Apply function to multiple columns
mtcars %>%
  summarise(across(c(mpg, hp, wt), mean))

# Apply multiple functions
mtcars %>%
  summarise(across(c(mpg, hp, wt), 
                   list(mean = mean, sd = sd)))

# Use column selection helpers
mtcars %>%
  summarise(across(where(is.numeric), mean))

# Conditional operations
mtcars %>%
  mutate(across(where(is.numeric), ~ .x * 1000))
```

### Advanced across Patterns

```r
# Multiple transformations
mtcars %>%
  mutate(
    across(c(mpg, hp), ~ scale(.x)[,1], .names = "{.col}_scaled"),
    across(where(is.numeric), ~ .x > mean(.x), .names = "{.col}_above_avg")
  )

# Grouped across operations
mtcars %>%
  group_by(cyl) %>%
  summarise(
    across(c(mpg, hp, wt), 
           list(mean = ~ mean(.x), 
                sd = ~ sd(.x),
                n = ~ sum(!is.na(.x))),
           .names = "{.col}_{.fn}")
  )

# Conditional across with if_any and if_all
mtcars %>%
  filter(if_any(c(mpg, hp), ~ .x > mean(.x)))  # Any condition true

mtcars %>%
  filter(if_all(c(mpg, hp), ~ .x > 10))        # All conditions true
```

### across with Custom Functions

```r
# Custom function application
normalize <- function(x) (x - min(x)) / (max(x) - min(x))

mtcars %>%
  mutate(across(where(is.numeric), normalize, .names = "{.col}_norm"))

# Complex transformations
mtcars %>%
  mutate(across(c(mpg, hp), 
                ~ case_when(
                  .x > quantile(.x, 0.75) ~ "High",
                  .x > quantile(.x, 0.25) ~ "Medium",
                  TRUE ~ "Low"
                ),
                .names = "{.col}_category"))
```

