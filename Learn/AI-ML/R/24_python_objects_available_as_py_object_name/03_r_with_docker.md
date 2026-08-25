## R with Docker


Docker containerization enables reproducible R environments and simplifies deployment across different systems.

**Basic R Dockerfile**

```dockerfile
# Multi-stage build for optimized R container
FROM r-base:4.3.0 as builder

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    libpq-dev \
    unixodbc-dev \
    && rm -rf /var/lib/apt/lists/*

# Install R packages
COPY renv.lock /tmp/
RUN R -e "install.packages('renv'); renv::restore(lockfile='/tmp/renv.lock')"

# Production stage
FROM r-base:4.3.0 as production

# Copy installed packages
COPY --from=builder /usr/local/lib/R/site-library /usr/local/lib/R/site-library

# Copy application
WORKDIR /app
COPY . .

# Set up non-root user
RUN useradd -r -s /bin/false ruser
USER ruser

# Default command
CMD ["Rscript", "main.R"]
```

**Docker Compose for R Applications**

```yaml
version: '3.8'
services:
  r-app:
    build: .
    container_name: r-analytics
    environment:
      - DB_HOST=postgres
      - DB_PORT=5432
      - DB_NAME=analytics
      - SPARK_MASTER=spark://spark-master:7077
    volumes:
      - ./data:/app/data:ro
      - ./output:/app/output
    depends_on:
      - postgres
      - spark-master
    networks:
      - analytics-network

  postgres:
    image: postgres:13
    environment:
      POSTGRES_DB: analytics
      POSTGRES_USER: analyst
      POSTGRES_PASSWORD: secure_password
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - analytics-network

  spark-master:
    image: bitnami/spark:3.4.0
    environment:
      - SPARK_MODE=master
      - SPARK_MASTER_HOST=spark-master
    ports:
      - "8080:8080"
      - "7077:7077"
    networks:
      - analytics-network

volumes:
  postgres_data:

networks:
  analytics-network:
    driver: bridge
```

**R Application Configuration**

```r
# config.R - Environment-aware configuration
get_config <- function() {
  config <- list(
    database = list(
      host = Sys.getenv("DB_HOST", "localhost"),
      port = as.integer(Sys.getenv("DB_PORT", "5432")),
      name = Sys.getenv("DB_NAME", "analytics"),
      user = Sys.getenv("DB_USER", "analyst"),
      password = Sys.getenv("DB_PASSWORD", "password")
    ),
    spark = list(
      master = Sys.getenv("SPARK_MASTER", "local[*]"),
      app_name = Sys.getenv("SPARK_APP_NAME", "R-Analytics")
    ),
    logging = list(
      level = Sys.getenv("LOG_LEVEL", "INFO"),
      file = Sys.getenv("LOG_FILE", "/app/logs/app.log")
    )
  )
  
  return(config)
}

# main.R - Application entry point
source("config.R")
config <- get_config()

# Set up logging
library(logger)
log_threshold(config$logging$level)
log_appender(appender_file(config$logging$file))

# Application logic
tryCatch({
  log_info("Starting R application")
  
  # Database connection
  con <- dbConnect(
    RPostgres::Postgres(),
    host = config$database$host,
    port = config$database$port,
    dbname = config$database$name,
    user = config$database$user,
    password = config$database$password
  )
  
  # Main processing
  result <- process_data(con)
  
  log_info("Application completed successfully")
  
}, error = function(e) {
  log_error("Application failed: {e$message}")
  quit(status = 1)
}, finally = {
  if (exists("con")) dbDisconnect(con)
})
```

