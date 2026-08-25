## Pipe Operator Usage and Best Practices


The pipe operator (%>%) creates readable data transformation pipelines:

### Basic Pipe Usage

```r
# Without pipes (nested)
result <- summarise(
  group_by(
    filter(mtcars, mpg > 20), 
    cyl
  ), 
  mean_hp = mean(hp)
)

# With pipes (linear)
result <- mtcars %>%
  filter(mpg > 20) %>%
  group_by(cyl) %>%
  summarise(mean_hp = mean(hp))
```

### Advanced Pipe Patterns

```r
# Complex data processing pipeline
result <- raw_data %>%
  # Data cleaning
  filter(!is.na(important_var)) %>%
  mutate(clean_var = str_trim(messy_var)) %>%
  
  # Feature engineering
  mutate(
    new_feature = case_when(
      condition1 ~ "A",
      condition2 ~ "B",
      TRUE ~ "C"
    ),
    scaled_feature = scale(numeric_var)[,1]
  ) %>%
  
  # Grouping and summarization
  group_by(category, new_feature) %>%
  summarise(
    across(c(var1, var2, var3), 
           list(mean = mean, sd = sd, n = ~ sum(!is.na(.x)))),
    .groups = "drop"
  ) %>%
  
  # Final formatting
  arrange(desc(var1_mean)) %>%
  mutate(across(ends_with("_mean"), round, digits = 2))
```

### Pipe Best Practices

**Key Points:**

- Use pipes for linear data transformations
- Break long pipes into logical chunks
- Assign intermediate results for complex operations
- Use meaningful variable names at each step
- Consider readability over brevity

```r
# Good: Clear, logical flow
clean_data <- raw_data %>%
  filter(!is.na(key_variable)) %>%
  mutate(transformed_var = log(original_var + 1)) %>%
  group_by(category) %>%
  filter(n() >= 10) %>%  # Keep groups with sufficient data
  ungroup()

summary_stats <- clean_data %>%
  group_by(treatment_group) %>%
  summarise(
    mean_response = mean(response_variable),
    se_response = sd(response_variable) / sqrt(n()),
    .groups = "drop"
  )
```

### Alternative Pipe Operators

```r
# Native pipe (R 4.1+)
mtcars |>
  filter(mpg > 20) |>
  summarise(mean_hp = mean(hp))

# Assignment pipe
mtcars %<>%
  filter(mpg > 20) %>%
  mutate(efficiency = mpg / hp)

# Tee pipe for side effects
mtcars %>%
  filter(mpg > 20) %T>%
  print() %>%  # Print intermediate result
  summarise(mean_hp = mean(hp))
```

**Example** of comprehensive dplyr workflow:

```r
# Complete data analysis pipeline
analysis_result <- sales_data %>%
  # Data validation and cleaning
  filter(
    !is.na(sales_amount),
    sales_amount > 0,
    between(sales_date, as.Date("2023-01-01"), as.Date("2023-12-31"))
  ) %>%
  
  # Feature engineering
  mutate(
    sales_month = floor_date(sales_date, "month"),
    sales_quarter = quarter(sales_date),
    high_value = sales_amount > quantile(sales_amount, 0.8),
    across(where(is.character), str_to_lower)
  ) %>%
  
  # Grouping and summarization
  group_by(region, sales_quarter) %>%
  summarise(
    across(c(sales_amount, profit_margin), 
           list(
             total = sum,
             mean = mean,
             median = median,
             q75 = ~ quantile(.x, 0.75)
           )),
    transaction_count = n(),
    high_value_pct = mean(high_value) * 100,
    .groups = "drop"
  ) %>%
  
  # Final transformations
  arrange(region, sales_quarter) %>%
  mutate(
    across(ends_with("_total"), scales::dollar),
    across(ends_with("_pct"), ~ round(.x, 1))
  )
```

These advanced dplyr operations provide a comprehensive toolkit for data manipulation, enabling efficient and readable data analysis workflows that scale from simple transformations to complex multi-step analyses.

---

