## R in Cloud Environments


Cloud platforms provide scalable infrastructure and managed services for R applications.

**AWS R Integration**

```r
# AWS SDK integration
library(paws)

# Initialize AWS services
s3 <- paws::s3()
ec2 <- paws::ec2()
rds <- paws::rds()

# S3 operations
upload_results <- function(local_file, bucket, key) {
  tryCatch({
    s3$put_object(
      Bucket = bucket,
      Key = key,
      Body = local_file
    )
    cat("Upload successful:", key)
  }, error = function(e) {
    cat("Upload failed:", e$message)
  })
}

# EC2 instance management
launch_compute_instance <- function(instance_type = "t3.large") {
  response <- ec2$run_instances(
    ImageId = "ami-0abcdef1234567890",  # R-optimized AMI
    MinCount = 1,
    MaxCount = 1,
    InstanceType = instance_type,
    KeyName = "my-key-pair",
    SecurityGroupIds = list("sg-12345678"),
    UserData = base64encode(charToRaw("#!/bin/bash\nRscript /home/ec2-user/analysis.R"))
  )
  
  return(response$Instances[[1]]$InstanceId)
}
```

**Google Cloud Platform Integration**

```r
# Google Cloud services
library(googleCloudStorageR)
library(bigrquery)
library(googleComputeEngineR)

# Authenticate
gcs_auth("service-account.json")

# BigQuery analytics
project <- "my-gcp-project"
dataset <- "analytics"

# Large-scale SQL on BigQuery
bq_query <- "
  SELECT 
    user_segment,
    COUNT(*) as user_count,
    SUM(revenue) as total_revenue
  FROM `project.dataset.user_events`
  WHERE event_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 30 DAY)
  GROUP BY user_segment
  ORDER BY total_revenue DESC
"

bq_result <- bq_project_query(project, bq_query)
data <- bq_table_download(bq_result)

# Compute Engine for scalable processing
vm_config <- list(
  template = gce_make_template(
    "r-analytics-template",
    image_project = "my-project",
    image_family = "r-4-3-0",
    machine_type = "n1-highmem-4",
    disk_size_gb = 100
  )
)

# Launch processing cluster
cluster_instances <- gce_make_cluster(
  template = vm_config$template,
  cluster_name = "r-cluster",
  instance_count = 5
)
```

**Azure Integration**

```r
# Azure services integration
library(AzureRMR)
library(AzureVM)
library(AzureStor)

# Authenticate with Azure
az <- create_azure_login()
sub <- az$get_subscription("subscription-id")
rg <- sub$get_resource_group("analytics-rg")

# Azure Blob Storage
blob_endpoint <- storage_endpoint(
  "https://account.blob.core.windows.net",
  key = Sys.getenv("AZURE_STORAGE_KEY")
)

container <- storage_container(blob_endpoint, "analytics-data")

# Batch processing with Azure Batch [Inference]
batch_pool <- create_batch_pool(
  pool_id = "r-processing-pool",
  vm_size = "Standard_D4s_v3",
  node_count = 10,
  image = "r-analytics:latest"
)
```

