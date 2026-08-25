## Database Integration


Integrating R with databases enables analysis of data that exceeds memory limitations and leverages database optimization.

**Database Connections**

```r
library(DBI)
library(RSQLite)

# SQLite connection
con <- dbConnect(RSQLite::SQLite(), "database.db")

# PostgreSQL connection
library(RPostgres)
con <- dbConnect(RPostgres::Postgres(),
                host = "localhost",
                port = 5432,
                dbname = "mydb",
                user = "username",
                password = "password")

# MySQL connection
library(RMySQL)
con <- dbConnect(RMySQL::MySQL(),
                host = "localhost",
                dbname = "mydb",
                user = "username",
                password = "password")
```

**Database Operations**

```r
# List tables
dbListTables(con)

# Execute queries
result <- dbGetQuery(con, "SELECT * FROM large_table LIMIT 1000")

# Chunked reading for large results
res <- dbSendQuery(con, "SELECT * FROM very_large_table")
while (!dbHasCompleted(res)) {
  chunk <- dbFetch(res, n = 10000)
  process_chunk(chunk)
}
dbClearResult(res)

# Write data to database
dbWriteTable(con, "new_table", data_frame, overwrite = TRUE)

# Close connection
dbDisconnect(con)
```

**dplyr Database Backend**

```r
library(dplyr)
library(dbplyr)

# Create database connection
con <- dbConnect(RSQLite::SQLite(), "database.db")
table_ref <- tbl(con, "large_table")

# Use dplyr syntax on database
result <- table_ref %>%
  filter(category == "A") %>%
  group_by(region) %>%
  summarise(
    count = n(),
    avg_value = mean(value, na.rm = TRUE)
  ) %>%
  arrange(desc(avg_value))

# View generated SQL
result %>% show_query()

# Collect results to R
local_result <- result %>% collect()
```

**Advanced Database Techniques**

```r
# Parameterized queries
safe_query <- function(user_id) {
  dbGetQuery(con, 
    "SELECT * FROM users WHERE id = ?",
    params = list(user_id)
  )
}

# Batch operations
dbBegin(con)
tryCatch({
  dbExecute(con, "INSERT INTO log VALUES (?, ?)", 
           params = list(c(1, 2, 3), c("A", "B", "C")))
  dbCommit(con)
}, error = function(e) {
  dbRollback(con)
  stop(e)
})
```

