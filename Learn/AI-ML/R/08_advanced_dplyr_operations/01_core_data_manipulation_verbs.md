## Core Data Manipulation Verbs


### select Operations

The select function chooses columns from datasets using various selection methods:

```r
# Basic column selection
select(mtcars, mpg, cyl, hp)

# Range selection
select(mtcars, mpg:hp)

# Negative selection (exclude columns)
select(mtcars, -c(mpg, cyl))

# Helper functions
select(mtcars, starts_with("c"))
select(mtcars, ends_with("p"))
select(mtcars, contains("ar"))
select(mtcars, matches("^[aeiou]"))
select(mtcars, where(is.numeric))
select(mtcars, any_of(c("mpg", "nonexistent")))
select(mtcars, all_of(c("mpg", "cyl")))
```

Advanced select patterns:

```r
# Rename while selecting
select(mtcars, miles_per_gallon = mpg, cylinders = cyl)

# Reorder columns
select(mtcars, hp, everything())

# Select by position
select(mtcars, 1:3, last_col())
```

### filter Operations

Filter rows based on logical conditions:

```r
# Single condition
filter(mtcars, mpg > 20)

# Multiple conditions (AND)
filter(mtcars, mpg > 20, cyl == 4)
filter(mtcars, mpg > 20 & cyl == 4)

# OR conditions
filter(mtcars, mpg > 25 | hp > 200)

# Complex conditions
filter(mtcars, mpg > mean(mpg) & cyl %in% c(4, 6))

# String operations
filter(starwars, str_detect(name, "^A"))

# Missing value handling
filter(starwars, !is.na(height))

# Between operations
filter(mtcars, between(mpg, 15, 25))

# Near comparisons for floating point
filter(mtcars, near(mpg, 21, tol = 0.1))
```

### arrange Operations

Sort data by one or more variables:

```r
# Ascending order
arrange(mtcars, mpg)

# Descending order
arrange(mtcars, desc(mpg))

# Multiple variables
arrange(mtcars, cyl, desc(mpg))

# Custom ordering with factors
arrange(starwars, match(eye_color, c("blue", "brown", "green")))

# Arrange with missing values
arrange(starwars, desc(is.na(height)), height)
```

### mutate Operations

Create new variables or modify existing ones:

```r
# Basic mutations
mutate(mtcars, 
       mpg_squared = mpg^2,
       efficiency = mpg / hp)

# Conditional mutations
mutate(mtcars,
       efficiency_class = case_when(
         mpg > 25 ~ "High",
         mpg > 20 ~ "Medium",
         TRUE ~ "Low"
       ))

# Window functions in mutate
mutate(mtcars,
       mpg_rank = row_number(desc(mpg)),
       mpg_percentile = percent_rank(mpg),
       mpg_lag = lag(mpg),
       mpg_cumsum = cumsum(mpg))

# Multiple operations
mutate(mtcars,
       hp_per_cyl = hp / cyl,
       above_avg_hp = hp > mean(hp),
       .keep = "used",  # Keep only used columns
       .before = mpg)   # Position new columns
```

Advanced mutate patterns:

```r
# Conditional replacement
mutate(data, 
       value = if_else(condition, true_value, false_value),
       value_na = na_if(value, -999))

# Type conversions
mutate(data,
       across(where(is.character), as.factor),
       across(c(var1, var2), as.numeric))
```

