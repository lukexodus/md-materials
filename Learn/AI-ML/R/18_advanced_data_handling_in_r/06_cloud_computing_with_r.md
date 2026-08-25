## Cloud Computing with R


Cloud platforms provide scalable computing resources and managed services for big data analytics.

**AWS Integration**

```r
# AWS S3 integration
library(aws.s3)
Sys.setenv("AWS_ACCESS_KEY_ID" = "your_key",
          "AWS_SECRET_ACCESS_KEY" = "your_secret",
          "AWS_DEFAULT_REGION" = "us-west-2")

# Read from S3
s3_data <- s3read_using(read.csv, bucket = "my-bucket", object = "data.csv")

# Write to S3
s3write_using(my_data, FUN = write.csv, bucket = "my-bucket", object = "output.csv")

# List S3 objects
bucket_contents <- get_bucket("my-bucket")
```

**Google Cloud Platform**

```r
# Google Cloud Storage
library(googleCloudStorageR)
gcs_auth("service-account.json")

# Download from GCS
gcs_get_object("data.csv", bucket = "my-gcs-bucket")

# BigQuery integration
library(bigrquery)
project <- "my-project"
sql <- "SELECT * FROM dataset.table LIMIT 1000"
result <- bq_project_query(project, sql)
data <- bq_table_download(result)
```

**Azure Integration**

```r
# Azure Blob Storage
library(AzureStor)
endpoint <- storage_endpoint("https://account.blob.core.windows.net", key = "key")
container <- storage_container(endpoint, "container-name")

# Download blob
storage_download(container, "data.csv", "local_data.csv")

# Azure ML integration [Unverified]
library(azuremlsdk)
workspace <- get_workspace("config.json")
```

**Databricks Integration**

```r
# Connect to Databricks cluster
library(SparkR)
sparkR.session(
  master = "databricks://databricks-instance",
  appName = "R-Analysis"
)

# Use Databricks-optimized Spark operations
df <- read.df("dbfs:/path/to/data", source = "delta")
processed <- df %>%
  filter(df$value > 100) %>%
  groupBy("category") %>%
  agg(mean = mean(df$value))
```

