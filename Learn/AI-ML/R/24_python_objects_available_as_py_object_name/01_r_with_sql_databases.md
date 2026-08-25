## R with SQL Databases


R's database integration capabilities enable analysis of large datasets stored in relational databases while leveraging SQL's optimization capabilities.

**Database Connection Management**

```r
library(DBI)
library(odbc)
library(RPostgres)

# PostgreSQL connection with connection pooling
create_pg_connection <- function() {
  dbConnect(
    RPostgres::Postgres(),
    host = Sys.getenv("DB_HOST"),
    port = Sys.getenv("DB_PORT"),
    dbname = Sys.getenv("DB_NAME"),
    user = Sys.getenv("DB_USER"),
    password = Sys.getenv("DB_PASSWORD"),
    sslmode = "require"
  )
}

# Connection pooling for production applications
library(pool)
pool <- dbPool(
  drv = RPostgres::Postgres(),
  host = "localhost",
  dbname = "production_db",
  user = "analyst",
  password = "secure_password",
  minSize = 1,
  maxSize = 10
)

# Always close connections properly
on.exit(poolClose(pool))
```

**Advanced SQL Operations**

```r
# Parameterized queries for security
safe_user_query <- function(user_id, start_date) {
  query <- "
    SELECT user_id, event_date, event_type, value
    FROM user_events 
    WHERE user_id = $1 AND event_date >= $2
    ORDER BY event_date
  "
  
  dbGetQuery(pool, query, params = list(user_id, start_date))
}

# Batch operations with transactions
batch_insert <- function(data_list) {
  conn <- poolCheckout(pool)
  dbBegin(conn)
  
  tryCatch({
    for (data_batch in data_list) {
      dbAppendTable(conn, "staging_table", data_batch)
    }
    dbCommit(conn)
  }, error = function(e) {
    dbRollback(conn)
    stop("Batch insert failed: ", e$message)
  }, finally = {
    poolReturn(conn)
  })
}
```

**Database-Backed Analytics with dplyr**

```r
library(dplyr)
library(dbplyr)

# Create table references
sales_db <- tbl(pool, "sales")
customers_db <- tbl(pool, "customers")
products_db <- tbl(pool, "products")

# Complex analytical queries
monthly_analysis <- sales_db %>%
  left_join(customers_db, by = "customer_id") %>%
  left_join(products_db, by = "product_id") %>%
  filter(
    sale_date >= "2024-01-01",
    customer_segment %in% c("premium", "enterprise")
  ) %>%
  mutate(
    sale_month = date_trunc("month", sale_date),
    revenue = quantity * unit_price
  ) %>%
  group_by(sale_month, product_category, customer_segment) %>%
  summarise(
    total_revenue = sum(revenue, na.rm = TRUE),
    total_quantity = sum(quantity, na.rm = TRUE),
    avg_order_value = mean(revenue, na.rm = TRUE),
    customer_count = n_distinct(customer_id),
    .groups = "drop"
  ) %>%
  arrange(desc(sale_month), desc(total_revenue))

# View generated SQL before execution
monthly_analysis %>% show_query()

# Execute and collect results
results <- monthly_analysis %>% collect()
```

**Stored Procedures and Functions**

```r
# Call stored procedures
call_stored_proc <- function(proc_name, ...) {
  params <- list(...)
  param_placeholders <- paste(rep("?", length(params)), collapse = ",")
  
  query <- paste0("CALL ", proc_name, "(", param_placeholders, ")")
  dbGetQuery(pool, query, params = params)
}

# Execute database functions
calculate_metrics <- function(start_date, end_date) {
  dbGetQuery(pool, "
    SELECT 
      calculate_revenue($1, $2) as revenue,
      calculate_growth_rate($1, $2) as growth_rate,
      calculate_customer_acquisition($1, $2) as new_customers
  ", params = list(start_date, end_date))
}
```

**Database Administration from R**

```r
# Create tables programmatically
create_analysis_table <- function() {
  dbExecute(pool, "
    CREATE TABLE IF NOT EXISTS analysis_results (
      id SERIAL PRIMARY KEY,
      analysis_date DATE NOT NULL,
      metric_name VARCHAR(100) NOT NULL,
      metric_value DECIMAL(15,2),
      segment VARCHAR(50),
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )
  ")
}

# Bulk data loading
bulk_load_data <- function(file_path, table_name) {
  temp_table <- paste0(table_name, "_temp")
  
  # Create temporary table
  dbExecute(pool, paste0("CREATE TEMP TABLE ", temp_table, " (LIKE ", table_name, ")"))
  
  # Load data
  dbWriteTable(pool, temp_table, read.csv(file_path), append = TRUE)
  
  # Validate and merge
  dbExecute(pool, paste0("
    INSERT INTO ", table_name, "
    SELECT * FROM ", temp_table, "
    WHERE data_quality_check(column_name) = TRUE
  "))
}
```

