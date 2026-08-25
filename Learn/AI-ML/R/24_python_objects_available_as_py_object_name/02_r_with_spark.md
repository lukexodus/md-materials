## R with Spark


Apache Spark integration enables R users to process massive datasets using distributed computing while maintaining familiar R syntax.

**Spark Connection and Configuration**

```r
library(sparklyr)
library(dplyr)

# Configure Spark
config <- spark_config()
config$spark.executor.memory <- "4g"
config$spark.executor.cores <- 2
config$spark.sql.adaptive.enabled <- "true"
config$spark.sql.adaptive.coalescePartitions.enabled <- "true"

# Connect to Spark cluster
sc <- spark_connect(
  master = "yarn",  # or "local[*]" for local mode
  app_name = "R-Analytics",
  config = config,
  version = "3.4.0"
)
```

**Data Loading and Management**

```r
# Read various data formats
parquet_data <- spark_read_parquet(sc, "parquet_table", "hdfs://path/to/data.parquet")
csv_data <- spark_read_csv(sc, "csv_table", "s3://bucket/data.csv", 
                          header = TRUE, infer_schema = TRUE)
delta_data <- spark_read_delta(sc, "delta_table", "s3://bucket/delta-table")

# Read from databases
jdbc_data <- spark_read_jdbc(sc, "db_table",
  options = list(
    url = "jdbc:postgresql://host:5432/db",
    dbtable = "large_table",
    user = "username",
    password = "password",
    numPartitions = 10
  )
)

# Copy local data to Spark (for smaller datasets)
local_to_spark <- copy_to(sc, mtcars, "mtcars_spark", overwrite = TRUE)
```

**Distributed Data Processing**

```r
# Large-scale data transformations
processed_data <- parquet_data %>%
  filter(event_date >= "2024-01-01") %>%
  mutate(
    event_month = date_format(event_date, "yyyy-MM"),
    value_category = case_when(
      value < 100 ~ "low",
      value < 1000 ~ "medium",
      TRUE ~ "high"
    )
  ) %>%
  group_by(event_month, user_segment, value_category) %>%
  summarise(
    total_events = n(),
    total_value = sum(value, na.rm = TRUE),
    avg_value = mean(value, na.rm = TRUE),
    unique_users = n_distinct(user_id)
  ) %>%
  arrange(desc(event_month), desc(total_value))

# Window functions for advanced analytics
user_analytics <- parquet_data %>%
  group_by(user_id) %>%
  arrange(event_date) %>%
  mutate(
    cumulative_value = sum(value) %>% cumsum(),
    value_rank = min_rank(desc(value)),
    days_since_first = datediff(event_date, first(event_date)),
    previous_value = lag(value, 1),
    value_change = value - previous_value
  ) %>%
  ungroup()
```

**Machine Learning with Spark MLlib**

```r
# Data preparation for ML
ml_data <- parquet_data %>%
  select(features = c("feature1", "feature2", "feature3"), target = "outcome") %>%
  sdf_sample(fraction = 0.1, replacement = FALSE, seed = 42) %>%
  na.omit()

# Feature engineering
ml_pipeline <- ml_pipeline(sc) %>%
  ft_vector_assembler(input_cols = c("feature1", "feature2", "feature3"),
                     output_col = "features") %>%
  ft_standard_scaler(input_col = "features", output_col = "scaled_features")

# Train models
rf_model <- ml_data %>%
  ml_random_forest_classifier(target ~ scaled_features, 
                             num_trees = 100,
                             max_depth = 10)

# Model evaluation
predictions <- ml_predict(rf_model, ml_data)
ml_metrics <- ml_binary_classification_evaluator(predictions, 
  label_col = "target",
  prediction_col = "prediction")
```

**Spark SQL Integration**

```r
# Register tables for SQL queries
DBI::dbWriteTable(sc, "events", parquet_data, temporary = TRUE)

# Execute Spark SQL
sql_result <- DBI::dbGetQuery(sc, "
  SELECT 
    user_segment,
    DATE_FORMAT(event_date, 'yyyy-MM') as month,
    COUNT(*) as event_count,
    SUM(value) as total_value,
    AVG(value) as avg_value
  FROM events 
  WHERE event_date >= '2024-01-01'
  GROUP BY user_segment, month
  ORDER BY month DESC, total_value DESC
")

# Complex analytical SQL
advanced_sql <- DBI::dbGetQuery(sc, "
  WITH user_metrics AS (
    SELECT 
      user_id,
      COUNT(*) as event_count,
      SUM(value) as lifetime_value,
      DATEDIFF(MAX(event_date), MIN(event_date)) as tenure_days
    FROM events
    GROUP BY user_id
  ),
  segmented_users AS (
    SELECT *,
      CASE 
        WHEN lifetime_value > 10000 THEN 'high_value'
        WHEN lifetime_value > 1000 THEN 'medium_value'
        ELSE 'low_value'
      END as value_segment
    FROM user_metrics
  )
  SELECT 
    value_segment,
    COUNT(*) as user_count,
    AVG(lifetime_value) as avg_ltv,
    PERCENTILE_APPROX(lifetime_value, 0.5) as median_ltv
  FROM segmented_users
  GROUP BY value_segment
")
```

**Performance Optimization**

```r
# Partitioning strategies
partitioned_data <- parquet_data %>%
  spark_write_parquet("s3://bucket/partitioned-data",
    mode = "overwrite",
    partition_by = c("year", "month"))

# Caching frequently used data
cached_data <- parquet_data %>%
  filter(event_date >= "2024-01-01") %>%
  compute("cached_events")

# Broadcast small lookup tables
small_lookup <- copy_to(sc, lookup_table, "lookup_broadcast")
broadcast_join <- large_table %>%
  left_join(broadcast(small_lookup), by = "key")

# Optimize joins
optimized_join <- large_table1 %>%
  repartition(100, "join_key") %>%
  left_join(
    large_table2 %>% repartition(100, "join_key"),
    by = "join_key"
  )
```

