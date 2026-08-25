## Big Data Tools


Specialized tools handle datasets that exceed single-machine capabilities through distributed computing and optimized data structures.

**data.table Package**

```r
library(data.table)

# Create data.table
dt <- data.table(
  id = 1:1000000,
  group = sample(LETTERS[1:5], 1000000, replace = TRUE),
  value = rnorm(1000000)
)

# Fast aggregation
result <- dt[, .(
  mean_value = mean(value),
  count = .N,
  sum_value = sum(value)
), by = group]

# Fast joins
dt2 <- data.table(group = LETTERS[1:5], weight = runif(5))
joined <- dt[dt2, on = "group"]

# Update by reference (no copy)
dt[, new_column := value * 2]
dt[group == "A", value := value * 1.1]

# Fast file I/O
fwrite(dt, "large_file.csv")
dt_read <- fread("large_file.csv")
```

**sparklyr for Apache Spark**

```r
library(sparklyr)
library(dplyr)

# Connect to Spark
sc <- spark_connect(master = "local", 
                   config = list(spark.executor.memory = "4g"))

# Copy data to Spark
spark_data <- copy_to(sc, large_local_data, "spark_table")

# Or read directly from files
spark_csv <- spark_read_csv(sc, "csv_data", "hdfs://path/to/large.csv")

# Use familiar dplyr syntax
result <- spark_data %>%
  filter(category %in% c("A", "B")) %>%
  group_by(region, category) %>%
  summarise(
    total = sum(amount),
    avg_value = mean(value)
  ) %>%
  arrange(desc(total))

# Machine learning with Spark
library(sparklyr.nested)
ml_model <- spark_data %>%
  ml_linear_regression(value ~ feature1 + feature2 + feature3)

# Collect results
local_result <- result %>% collect()

spark_disconnect(sc)
```

**Arrow Package for Columnar Data**

```r
library(arrow)

# Read Parquet files efficiently
parquet_data <- read_parquet("large_file.parquet")

# Work with Arrow datasets (multiple files)
dataset <- open_dataset("data_directory/")

# Query without loading full dataset
filtered_data <- dataset %>%
  filter(year >= 2020, category == "premium") %>%
  select(id, value, timestamp) %>%
  collect()

# Write partitioned datasets
write_dataset(large_data, 
              "partitioned_data/",
              partitioning = c("year", "month"))
```

